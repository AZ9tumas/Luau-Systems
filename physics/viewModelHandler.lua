local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera

local handler = {}
local viewmodel = {}

local VIEWMODEL_OFFSET = CFrame.new(0, -0.7, 0)

function handler.new()
	local newmodel = {
		model = ReplicatedStorage:WaitForChild("Viewmodel"):Clone(),
		rbxConn = nil,

		springPosition = Vector3.new(),
		springVelocity = Vector3.new(),
		isSpringActive = false,
	}

	if not newmodel.model.PrimaryPart then
		newmodel.model.PrimaryPart = newmodel.model:FindFirstChild("HumanoidRootPart")
		warn("ViewModel's PrimaryPart was not set in Studio. Defaulting to HumanoidRootPart.")
	end

	return setmetatable(newmodel, {__index = viewmodel})
end

function viewmodel:applyRecoilImpulse(impulse)
	local impulseInRadians = Vector3.new(
		math.rad(impulse.X),
		math.rad(impulse.Y),
		math.rad(impulse.Z)
	)
	self.springVelocity = self.springVelocity + impulseInRadians
	self.isSpringActive = true
end

function viewmodel:Enable()
	if self.rbxConn then return end
	
	self.model.Parent = Camera

	self.rbxConn = RunService.RenderStepped:Connect(function(dt)
		local baseCFrame = Camera.CFrame --* VIEWMODEL_OFFSET
		local finalCFrame = baseCFrame

		if self.isSpringActive then
			local stiffness = 300
			local damping = 30
			
			if self.springPosition.Magnitude < 0.001 and self.springVelocity.Magnitude < 0.001 then
				self.isSpringActive = false
				self.springPosition = Vector3.new()
				self.springVelocity = Vector3.new()
			else
				local springForce = -stiffness * self.springPosition
				local dampingForce = -damping * self.springVelocity
				local totalForce = springForce + dampingForce

				self.springVelocity = self.springVelocity + totalForce * dt
				self.springPosition = self.springPosition + self.springVelocity * dt
			end
		end
		local recoilRotation = CFrame.Angles(self.springPosition.X, self.springPosition.Y, self.springPosition.Z)
		finalCFrame = baseCFrame * recoilRotation

		self.model:SetPrimaryPartCFrame(finalCFrame)
	end)
end

function viewmodel:Disable()
	if not self.rbxConn then return end
	if not self.model then return end
	
	self.model:Destroy()

	self.rbxConn:Disconnect()
	self.rbxConn = nil

	self.isSpringActive = false
	self.springPosition = Vector3.new()
	self.springVelocity = Vector3.new()
end

return handler
