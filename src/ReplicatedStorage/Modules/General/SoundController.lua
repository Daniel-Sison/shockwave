local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


-- Create the service:
local SoundController = Knit.CreateController {
    Name = "SoundController",
}


----------- Services -----------

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")


----------- Initiated Variables -----------

local player = game.Players.LocalPlayer

local MAIN_SOUND_FOLDER = game:GetService("SoundService")

----------- Public Functions -----------

function SoundController:PlaySoundInPart(
	soundName : string?,
	part : BasePart?,
	destroyAfterPlay : boolean?,
	playOnPartDestroyed: boolean?
)

	local targetSound = MAIN_SOUND_FOLDER:FindFirstChild(soundName)
    if not targetSound then
		targetSound = ReplicatedStorage.Assets.Sounds:FindFirstChild(soundName)
		if not targetSound then
			warn("Could not find specified sound")
			return
		end
    end

    local sound = targetSound:Clone()
	sound.Parent = part

	if playOnPartDestroyed then
		sound.PlayOnRemove = true
		return sound
	end

	sound:Play()

    if destroyAfterPlay then
        sound.Ended:Once(function()
            sound:Destroy()
        end)
    end

   return sound
end


function SoundController:PlaySound(
	targetName : string?,
	fadeOutOtherSounds : boolean?,
	fadeIn : boolean?,
	seconds : number?
)
	
	-- If the targetSound cannot be found, then return
	local targetSound : Sound? = MAIN_SOUND_FOLDER:FindFirstChild(targetName, true)
	if not targetSound then
		return
	end
	
	-- Will fade out all other sounds IN SOUNDSERVICE if this is set to true
	if fadeOutOtherSounds then
		self:FadeOutOtherSounds(targetSound)
	end
	
	
	if fadeIn then
		targetSound.Volume = 0

		local goal = {Volume = targetSound:GetAttribute("OriginVolume")}

		local tweenInfo = TweenInfo.new(
			1,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		local tween = TweenService:Create(targetSound, tweenInfo, goal)
		tween:Play()
	else
		if targetSound:GetAttribute("OriginVolume") then
			targetSound.Volume = targetSound:GetAttribute("OriginVolume")
		end
	end
	
	-- The time position for the sound to start at
	if seconds then
		targetSound.TimePosition = seconds
	end

	targetSound:Play()
	
	-- Return targetsound in case an event needs to be connected
	return targetSound
end



function SoundController:FadeOutOtherSounds(ignoreSound : Sound?)
	for _, sound in ipairs(MAIN_SOUND_FOLDER:GetDescendants()) do
		
		-- Ignore playing sounds
		if not sound.Playing then
			continue
		end
		
		-- Ignore sounds that are NOT music
		if not sound.Looped then
			continue
		end
		
		-- Ignore targeted sound
		if sound == ignoreSound then
			continue
		end
		
		local goal = {Volume = 0}
        local savedVolume = sound.Volume
		
		local tweenInfo = TweenInfo.new(
			1,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		local tween = TweenService:Create(sound, tweenInfo, goal)
		tween:Play()
		
		tween.Completed:Connect(function()
			sound:Stop()
            sound.Volume = savedVolume
		end)
	end
end


----------- Private Functions -----------



return SoundController
