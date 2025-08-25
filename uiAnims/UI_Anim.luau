local TweenService = game:GetService("TweenService")

local animSlabs = {}

export type AnimatableGuiObject = Frame | TextButton | ImageButton | TextLabel | ImageLabel | ScrollingFrame

export type Slab = {
	UIObject: AnimatableGuiObject,
	_originalStates: { [AnimatableGuiObject]: {} },

	debounce: boolean,

	PlayAnimation: (self: Slab, animationFunction: (any) -> TweenInfo, additionalFunction: (any) -> ()) -> (),

	RegisterAnimation: (self: Slab, animationFunction: (any) -> TweenInfo, event: RBXScriptSignal) -> (),
}

function animSlabs.FadeInChildren(slab: Slab)
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	for child, originalState in pairs(slab._originalStates) do
		if originalState.BackgroundTransparency ~= nil then
			child.BackgroundTransparency = 1
		end
		if originalState.TextTransparency ~= nil then
			child.TextTransparency = 1
		end
		if originalState.ImageTransparency ~= nil then
			child.ImageTransparency = 1
		end

		local tween = TweenService:Create(child, tweenInfo, {
			BackgroundTransparency = originalState.BackgroundTransparency,
			TextTransparency = originalState.TextTransparency,

			ImageTransparency = originalState.ImageTransparency,
		})

		tween:Play()
	end

	return tweenInfo
end

function animSlabs.FadeOutChildren(slab: Slab)
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	for child, originalState in pairs(slab._originalStates) do
		local goal = {}
		local hasProperties = false

		if pcall(function()
			return child.BackgroundTransparency
		end) then
			goal.BackgroundTransparency = 1
			hasProperties = true
		end
		if pcall(function()
			return child.TextTransparency
		end) then
			goal.TextTransparency = 1
			hasProperties = true
		end

		if pcall(function()
			return child.ImageTransparency
		end) then
			goal.ImageTransparency = 1
			hasProperties = true
		end

		if hasProperties then
			local tween = TweenService:Create(child, tweenInfo, goal)

			tween:Play()
		end
	end

	return tweenInfo
end

function animSlabs.SlideUpAndFadeIn(slab: Slab)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	local originalStates = slab._originalStates

	for child, originalState in pairs(originalStates) do
		if originalState.Position then
			child.Position = originalState.Position + UDim2.fromOffset(0, 20)
		end
		if originalState.BackgroundTransparency ~= nil then
			child.BackgroundTransparency = 1
		end

		if originalState.TextTransparency ~= nil then
			child.TextTransparency = 1
		end
		if originalState.ImageTransparency ~= nil then
			child.ImageTransparency = 1
		end

		local tween = TweenService:Create(child, tweenInfo, originalState)
		tween:Play()
	end

	return tweenInfo
end

function animSlabs.SlideDownAndFadeOut(slab: Slab)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)

	local originalStates = slab._originalStates

	for child, originalState in pairs(originalStates) do
		local goal = {}

		if originalState.Position then
			goal.Position = originalState.Position + UDim2.fromOffset(0, 20)
		end
		if originalState.BackgroundTransparency ~= nil then
			goal.BackgroundTransparency = 1
		end
		if originalState.TextTransparency ~= nil then
			goal.TextTransparency = 1
		end
		if originalState.ImageTransparency ~= nil then
			goal.ImageTransparency = 1
		end

		local tween = TweenService:Create(child, tweenInfo, goal)
		tween:Play()
	end

	return tweenInfo
end

local slabMethods = {}
local slabMetatable = { __index = slabMethods }

function slabMethods:PlayAnimation(animationFunction, additionalFunc)
	if self.debounce then
		return
	end

	print(self.debounce, "...animating.")
	self.debounce = true

	local info: TweenInfo = animationFunction(self)

	task.delay(info.Time, function()
		self.debounce = false

		-- after everything is done
		if additionalFunc then
			additionalFunc()
		end
	end)
end

function slabMethods:RegisterAnimation(animationFunction, event)
	if not event or not event.Connect then
		warn("Attempted to register an animation to an invalid event.")

		return
	end

	event:Connect(function(...)
		self:PlayAnimation(animationFunction, ...)
	end)
end

function animSlabs:ApplyAnimationSlabs(target: AnimatableGuiObject)
	if not target then
		error("ApplyAnimationSlabs requires a valid GuiObject.", 2)
	end

	local originalStates = {}
	local stuff = target:GetDescendants()

	table.insert(stuff, target)
	for _, child in ipairs(stuff) do
		local properties = {}

		if pcall(function()
			return child.Position
		end) then
			properties.Position = child.Position
		end
		if pcall(function()
			return child.BackgroundTransparency
		end) then
			properties.BackgroundTransparency = child.BackgroundTransparency
		end
		if pcall(function()
			return child.TextTransparency
		end) then
			properties.TextTransparency = child.TextTransparency
		end
		if pcall(function()
			return child.ImageTransparency
		end) then
			properties.ImageTransparency = child.ImageTransparency
		end

		originalStates[child] = properties
	end

	local registeredObj = {
		UIObject = target,
		_originalStates = originalStates,
		debounce = false,
	}

	return setmetatable(registeredObj, slabMetatable)
end

return animSlabs
