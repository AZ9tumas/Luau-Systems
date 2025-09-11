local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local gunHandler = require(Modules:WaitForChild("GunHandler"))
local akmModel = ReplicatedStorage:WaitForChild("AKM")

local myAKM = gunHandler.New(akmModel)
myAKM:Equip()

local isEquipped = true

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent or not isEquipped then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		myAKM:shoot(true)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if not isEquipped then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		myAKM:stopShoot()
	end
end)
