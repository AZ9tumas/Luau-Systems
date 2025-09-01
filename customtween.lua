local RunService = game:GetService("RunService")

local CustomTweenService = {}

local supportedTypes = {
	["number"] = true,
	["UDim2"] = true,
}

local function interpolate(start, goal, alpha)
	local typeName = typeof(start)
	if typeName ~= typeof(goal) then
		error("Type mismatch for interpolation: " .. typeName)
	end
	if not supportedTypes[typeName] then
		error("Unsupported property type: " .. typeName)
	end

	if typeName == "number" then
		return start + (goal - start) * alpha
	else  -- UDim2
		return start:Lerp(goal, alpha)
	end
end

local SINE_TABLE_RESOLUTION = 100
local SINE_TABLE = {}
for i = 0, SINE_TABLE_RESOLUTION do
	SINE_TABLE[i] = math.sin((i / SINE_TABLE_RESOLUTION) * math.pi / 2)
end

local function get_eased_alpha(alpha)
	local scaled = alpha * SINE_TABLE_RESOLUTION
	local idx = math.floor(scaled)
	local frac = scaled - idx

	if idx >= SINE_TABLE_RESOLUTION then
		return 1
	end

	return SINE_TABLE[idx] + frac * (SINE_TABLE[idx + 1] - SINE_TABLE[idx])
end

function CustomTweenService:Create(instance, tweenInfo, propertyTable)
	local tween = {}

	local startValues = {}
	local goalValues = propertyTable
	local connection
	local startTime
	local elapsedWhenPaused = 0
	local completed = Instance.new("BindableEvent")
	tween.Completed = completed.Event

	local function stopAndFire(isCompleted)
		if connection then
			connection:Disconnect()
			connection = nil
		end
		if isCompleted then
			completed:Fire()
		end
		elapsedWhenPaused = 0
	end

	function tween:Play()
		if connection then
			return  -- Already playing
		end

		if elapsedWhenPaused == 0 then
			-- Capture (or recapture after complete/cancel)
			for prop in pairs(goalValues) do
				startValues[prop] = instance[prop]
			end
		end

		local now = os.clock()
		startTime = now - elapsedWhenPaused

		connection = RunService.Heartbeat:Connect(function()
			now = os.clock()
			local elapsed = now - startTime

			if elapsed < tweenInfo.DelayTime then
				return
			end

			local tweenElapsed = elapsed - tweenInfo.DelayTime
			local alpha = tweenElapsed / tweenInfo.Time

			if alpha >= 1 then
				alpha = 1
				for prop, goal in pairs(goalValues) do
					instance[prop] = interpolate(startValues[prop], goal, alpha)
				end
				stopAndFire(true)
				return
			end

			local eased = get_eased_alpha(alpha)

			for prop, goal in pairs(goalValues) do
				local start = startValues[prop]
				instance[prop] = interpolate(start, goal, eased)
			end
		end)
	end

	function tween:Pause()
		if not connection then
			return
		end

		local now = os.clock()
		elapsedWhenPaused = now - startTime
		connection:Disconnect()
		connection = nil
	end

	function tween:Cancel()
		stopAndFire(false)
	end

	return tween
end

return CustomTweenService
