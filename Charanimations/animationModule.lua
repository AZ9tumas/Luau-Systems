--[[
	@module AnimationController
	@author az9
	@date August 12, 2023

]]

local AnimationController = {}

-- Private cache: Keyed by character instance for isolation across scripts/characters.
local characterCaches = {}
--[[
{

	character : Model = {
		tracks : {name : AnimationTrack},
		animator: Animator,
		latestName: string
	},
}
]]

-- get or create cache for a character.
local function getCache(character: Model)
	if not characterCaches[character] then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			warn("AnimationController: No Humanoid found in character.")
			return nil
		end
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then
			warn("AnimationController: No Animator found in Humanoid.")
			return nil
		end
		characterCaches[character] = {
			tracks = {},
			latestName = nil,
			animator = animator
		}
	end
	return characterCaches[character]
end

local function loadTrack(cache, character: Model, animName: string): AnimationTrack?
	local animationsFolder = character:FindFirstChild("Animations")
	if not animationsFolder then
		warn("AnimationController: No 'Animations' folder found under character.")
		return nil
	end
	local animInstance = animationsFolder:FindFirstChild(animName)
	if not animInstance or not animInstance:IsA("Animation") then
		warn(string.format("AnimationController: No Animation named '%s' found in Animations folder.", animName))
		return nil
	end
	if not cache.tracks[animName] then
		cache.tracks[animName] = (cache.animator :: Animator):LoadAnimation(animInstance)
	end
	return cache.tracks[animName]
end

--[[
	Plays an animation by name, loading it dynamically from the character's Animations folder.
	Parameters:
	- character (Model): The character to play on.
	- animName (string): Name of the animation (matches folder child name).
	- fadeTime (number?): Optional fade time (default 0.1).
	- priority (Enum.AnimationPriority?): Optional priority (default Action).
	- looped (boolean?): Optional looped flag (default false).
	- speed (number?): Optional playback speed (default 1).
	Returns: The AnimationTrack played, or nil on failure.
	Updates the latest animation tracker.
]]
function AnimationController.PlayAnimation(character: Model, animName: string, fadeTime: number?, priority: Enum.AnimationPriority?, looped: boolean?, speed: number?): AnimationTrack?
	local cache = getCache(character)
	if not cache then return nil end

	local track = loadTrack(cache, character, animName)
	if not track then return nil end

	track.Priority = priority or Enum.AnimationPriority.Action
	track.Looped = looped or false
	track:Play(fadeTime or 0.1, 1, speed or 1)
	
	cache.latestName = animName
	return track
end

--[[
	Stops a specific animation by name if it's playing.
	Parameters:
	- character (Model): The character.
	- animName (string): Name of the animation to stop.
	- fadeTime (number?): Optional fade time (default 0.1).
	Returns: true if stopped, false if not found/playing.
	If this was the latest, clears the latest tracker.
]]
function AnimationController.StopAnimation(character: Model, animName: string, fadeTime: number?): boolean
	local cache = getCache(character)
	if not cache or not cache.tracks[animName] then return false end

	local track = cache.tracks[animName]
	if track.IsPlaying then
		track:Stop(fadeTime or 0.1)
		if cache.latestName == animName then
			cache.latestName = nil
		end
		return true
	end
	return false
end

--[[
	Stops all cached animations on the character.
	Parameters:
	- character (Model): The character.
	- fadeTime (number?): Optional fade time for all (default 0.1).
	Clears the latest tracker.
]]
function AnimationController.StopAllAnimations(character: Model, fadeTime: number?)
	local cache = getCache(character)
	if not cache then return end

	for _, track in pairs(cache.tracks) do
		if track.IsPlaying then
			track:Stop(fadeTime or 0.1)
		end
	end
	cache.latestName = nil
end

--[[
	Returns the name of the latest played animation, or nil if none.
	Parameters:
	- character (Model): The character.
	Returns: string? latest animation name.
]]
function AnimationController.GetCurrentAnimation(character: Model): string?
	local cache = getCache(character)
	return cache and cache.latestName or nil
end

return AnimationController
