local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local originalIcon = mouse.Icon
local viewmodelHandler = require(script.Parent.ViewModelHandler)
local CameraShakeModule = require(ReplicatedStorage.Modules.CameraShake)

local handler = {}
local gun = {}

function handler.New(gunModel)
	local newgun = {
		gunModel = gunModel,
		clonedGun = nil,
		viewModel = viewmodelHandler.new(),

		isShooting = false,
		continuousFireConn = nil,
		fireRate = 0.1,
		fireCooldown = 0,
	}

	return setmetatable(newgun, {__index = gun})
end

function gun:_applyRecoil()
	local Recoil = {
		Camera = {
			Impulse = {
				Pitch = {Min = 50, Max = 250},
				Yaw = {Min = -100, Max = 100},
			},
		},
		ViewModel = {
			Impulse = {
				Pitch = {Min = 350, Max = 600}, 
				Yaw = {Min = -150, Max = 150},
			},
		}
	}

	local camData = Recoil.Camera.Impulse
	local camRecoilImpulse = Vector3.new(
		math.random() * (camData.Pitch.Max - camData.Pitch.Min) + camData.Pitch.Min,
		math.random() * (camData.Yaw.Max - camData.Yaw.Min) + camData.Yaw.Min,
		0
	)
	CameraShakeModule.spring_recoil(camRecoilImpulse)

	local vmData = Recoil.ViewModel.Impulse
	local vmRecoilImpulse = Vector3.new(
		math.random() * (vmData.Pitch.Max - vmData.Pitch.Min) + vmData.Pitch.Min,
		math.random() * (vmData.Yaw.Max - vmData.Yaw.Min) + vmData.Yaw.Min,
		0
	)
	self.viewModel:applyRecoilImpulse(vmRecoilImpulse)
end

function gun:Equip()
	mouse.Icon = 'rbxassetid://117431027'
	self.clonedGun = self.gunModel:Clone()
	self.clonedGun.Parent = self.viewModel.model
	
	local gripMotor = Instance.new("Motor6D")
	gripMotor.Name = "GunGrip"
	gripMotor.Part0 = self.viewModel.model.RightArm
	gripMotor.Part1 = self.clonedGun.Handle
	gripMotor.C1 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(-90), math.rad(-90))
	gripMotor.Parent = self.viewModel.model.RightArm
	
	self.viewModel:Enable()
	CameraShakeModule.apply_camera_mode_changes(true)
end

function gun:Unequip()
	self:stopShoot()
	mouse.Icon = originalIcon

	self.viewModel:Disable()
	if self.clonedGun then
		self.clonedGun:Destroy()
		self.clonedGun = nil
	end
	CameraShakeModule.apply_camera_mode_changes(false)
end

function gun:handleDamange()
	print("yeah time to damage")
end

function gun:shoot(continuous)
	if not continuous then
		self:_applyRecoil()
		self:handleDamange()
		return
	end
	if self.isShooting then return end

	self.isShooting = true
	self.fireCooldown = 0

	self.continuousFireConn = RunService.Heartbeat:Connect(function(dt)
		self.fireCooldown = self.fireCooldown - dt

		if self.fireCooldown <= 0 then
			self.fireCooldown = self.fireRate
			self:_applyRecoil()
			self:handleDamange()
		end
	end)
end

function gun:stopShoot()
	if not self.isShooting then return end
	self.isShooting = false

	if self.continuousFireConn then
		self.continuousFireConn:Disconnect()
		self.continuousFireConn = nil
	end
end

return handler
