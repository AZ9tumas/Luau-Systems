local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local inventoryScreenGui = playerGui:WaitForChild("Inventory")
local inventoryFrame : Frame = inventoryScreenGui:WaitForChild("InventoryFrame")
local tabFrame : Frame =  inventoryFrame:WaitForChild("Tabs")
local headerItemsFrame = inventoryFrame:WaitForChild("Header_Items")
local headerQuestsFrame = inventoryFrame:WaitForChild("Header_Quests")
local headerRecipesFrame = inventoryFrame:WaitForChild("Header_Recipes")

local UIManager_AnimSlabsM = require(script.Parent.AnimationManager)
local inventoryAnimations = UIManager_AnimSlabsM:ApplyAnimationSlabs(inventoryFrame)

local tabChildFrames : {[string] : UIManager_AnimSlabsM.Slab} = {}
for _, v in pairs({"Items", "Quests", "Recipes"}) do
	-- main frame
	tabChildFrames[v] = UIManager_AnimSlabsM:ApplyAnimationSlabs(tabFrame:FindFirstChild(v) :: Frame)
	-- header frame
	tabChildFrames["Header_"..v] = UIManager_AnimSlabsM:ApplyAnimationSlabs(inventoryFrame:FindFirstChild("Header_"..v))
end

local function makeInvisible(stuff : {}, exception)
	for i, v : Frame in pairs(stuff) do
		if v:IsA("Frame") and v ~= exception then v.Visible = false end
	end
end

local stuff = {headerItemsFrame, headerQuestsFrame, headerRecipesFrame}
local lastOpened : UIManager_AnimSlabsM.Slab = tabChildFrames["Items"]
for _, v in pairs(stuff) do
	for _, child in v:GetChildren() do
		if child:IsA("ImageButton") then
			child.MouseButton1Click:Connect(function()
				if lastOpened.UIObject.Name == child.Name then return end
				local correspondingFrameAnim : UIManager_AnimSlabsM.Slab = tabChildFrames[child.Name]
				local correspondingHeaderAnim : UIManager_AnimSlabsM.Slab = tabChildFrames["Header_"..child.Name]
				
				tabChildFrames["Header_"..lastOpened.UIObject.Name]:PlayAnimation(UIManager_AnimSlabsM.FadeOutChildren, function()
					makeInvisible(stuff, correspondingHeaderAnim.UIObject)
					correspondingHeaderAnim.UIObject.Visible = true
					correspondingHeaderAnim:PlayAnimation(UIManager_AnimSlabsM.FadeInChildren)
				end)
				
				lastOpened:PlayAnimation(UIManager_AnimSlabsM.SlideDownAndFadeOutChildren, function()
					makeInvisible(tabFrame:GetChildren(), correspondingFrameAnim.UIObject)
					correspondingFrameAnim.UIObject.Visible = true
					correspondingFrameAnim:PlayAnimation(UIManager_AnimSlabsM.SlideUpAndFadeInChildren)
					
					lastOpened = correspondingFrameAnim
				end)
			end)
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.KeyCode == Enum.KeyCode.E then
		if inventoryAnimations.debounce then return end
		if inventoryFrame.Visible then
			-- false
			inventoryAnimations:PlayAnimation(UIManager_AnimSlabsM.SlideDownAndFadeOutChildren, function()
				inventoryFrame.Visible = false
			end)
		else
			inventoryFrame.Visible = true
			inventoryAnimations:PlayAnimation(UIManager_AnimSlabsM.SlideUpAndFadeInChildren)
		end
	end
end)

