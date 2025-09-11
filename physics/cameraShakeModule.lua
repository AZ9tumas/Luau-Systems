-- ReplicatedStorage/Modules/CameraShakeModule.lua

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local CameraShakeModule = {}

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ActiveShakes = {}
local IsUpdateLoopRunning = false
local PreviousShakeCFrame = CFrame.new()

local function update_camera_shake(deltaTime)
	local totalRotationalOffset = CFrame.new()
	local totalPositionalOffset = CFrame.new()

	for id, shakeData in pairs(ActiveShakes) do
		local decayRate = shakeData.DecayRate
		local timeRemaining = shakeData.TimeLeft

		-- The alpha for lerping should be based on a consistent rate, adjusted for the frame time.
		local decayAlpha = math.clamp(1 - (1 - decayRate) ^ (deltaTime * 60), 0, 1)
		shakeData.CurrentMagnitude = shakeData.CurrentMagnitude:Lerp(Vector3.new(), decayAlpha)
		shakeData.TimeLeft = timeRemaining - deltaTime

		if shakeData.TimeLeft <= 0 or shakeData.CurrentMagnitude.Magnitude < 0.01 then
			ActiveShakes[id] = nil
		else
			if shakeData.ShakeType == "Rotational" then
				totalRotationalOffset = totalRotationalOffset * CFrame.Angles(
					math.rad(shakeData.CurrentMagnitude.X),
					math.rad(shakeData.CurrentMagnitude.Y),
					math.rad(shakeData.CurrentMagnitude.Z)
				)
			elseif shakeData.ShakeType == "Positional" then
				totalPositionalOffset = totalPositionalOffset * CFrame.new(shakeData.CurrentMagnitude)
			end
		end
	end

	local currentShakeCFrame = totalPositionalOffset * totalRotationalOffset

	-- The core logic: remove the last frame's shake and apply the new one.
	Camera.CFrame = Camera.CFrame * PreviousShakeCFrame:Inverse() * currentShakeCFrame
	PreviousShakeCFrame = currentShakeCFrame

	-- If no shakes remain, stop the update loop.
	if not next(ActiveShakes) then
		IsUpdateLoopRunning = false
		RunService:UnbindFromRenderStep("CameraShake")
	end
end

local function add_shake_effect(magnitude, duration, decay_rate, shake_type)
	print("okay")
	local newShake = {
		CurrentMagnitude = magnitude,
		Duration = duration,
		DecayRate = decay_rate,
		ShakeType = shake_type,
		TimeLeft = duration,
	}
	table.insert(ActiveShakes, newShake)

	-- If the update loop isn't running, start it and reset the state.
	if not IsUpdateLoopRunning then
		IsUpdateLoopRunning = true
		PreviousShakeCFrame = CFrame.new()
		RunService:BindToRenderStep("CameraShake", Enum.RenderPriority.Camera.Value + 5, update_camera_shake)
	end
end

function CameraShakeModule.rotational_shake(magnitude: Vector3, duration: number, decay_rate: number)
	add_shake_effect(magnitude, duration, decay_rate, "Rotational")
end

function CameraShakeModule.positional_kickback(magnitude: Vector3, duration: number, decay_rate: number)
	add_shake_effect(magnitude, duration, decay_rate, "Positional")
end

function CameraShakeModule.apply_camera_mode_changes(is_equipped: boolean)
	if not LocalPlayer then return end

	if is_equipped then
		LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	else
		LocalPlayer.CameraMode = Enum.CameraMode.Classic
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

return CameraShakeModule
