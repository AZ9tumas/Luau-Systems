local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local inventoryScreenGui = playerGui:WaitForChild("Inventory")
local inventoryFrame: Frame = inventoryScreenGui:WaitForChild("InventoryFrame")

local UIManager_AnimSlabsM = require(script.Parent.UI_Anim)
local inventoryAnimations = UIManager_AnimSlabsM:ApplyAnimationSlabs(inventoryFrame)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode.E then
		if inventoryAnimations.debounce then
			return
		end
		if inventoryFrame.Visible then
			-- false
			inventoryAnimations:PlayAnimation(UIManager_AnimSlabsM.SlideDownAndFadeOut, function()
				inventoryFrame.Visible = false
			end)
		else
			inventoryFrame.Visible = true
			inventoryAnimations:PlayAnimation(UIManager_AnimSlabsM.SlideUpAndFadeIn)
		end
	end
end)
