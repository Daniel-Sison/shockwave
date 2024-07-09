local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules

-- Create the service:
local SoundService = Knit.CreateService {
    Name = "SoundService",
}


----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------

local MAIN_SOUND_FOLDER = ReplicatedStorage.Assets:WaitForChild("Sounds")

----------------------------------------------
-------------- Client Methods ----------------
----------------------------------------------

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


function SoundService:PlaySoundInPart(
    soundName : string?,
    part : BasePart | Vector3,
    playOnRemove : boolean
)

	local targetSound = MAIN_SOUND_FOLDER:FindFirstChild(
        soundName,
        true
    )
    if not targetSound then
        warn("Could not find specified sound")
        return
    end

    if not part then
        warn("No part given for sound in part")
        return
    end

    local savedPosition

    if typeof(part) == "Vector3" then
        savedPosition = part

        part = Instance.new("Part")
        part.Name = "SoundEmitterPart"
        part.Size = Vector3.new(1, 1, 1)
        part.Anchored = true
        part.Position = savedPosition
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.Transparency = 1
        part.Parent = workspace.EffectStorage
    end

    local sound = targetSound:Clone()
	sound.Parent = part

    if playOnRemove then
        sound.PlayOnRemove = true
        return sound
    end

	sound:Play()
    sound.Ended:Once(function()
        sound:Destroy()

        if savedPosition then
            part:Destroy()
        end
    end)

    return sound
end



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function SoundService:KnitInit()

end

function SoundService:KnitStart()

end


return SoundService