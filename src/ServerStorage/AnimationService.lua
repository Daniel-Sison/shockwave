local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules


local AnimationService = Knit.CreateService {
    Name = "AnimationService",
}

----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------


----------------------------------------------
-------------- Client Methods ----------------
----------------------------------------------

function AnimationService.Client:PlayAnimation(player, humanoid, animationID)
    self.Server:PlayAnimation(humanoid, animationID)
end

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

--[[
    @param humanoid Humanoid
    @param animationID string
    @return AnimationTrack | nil

    Plays an animation on a given humanoid.
    Automatically cleans up the animation when it is finished playing.

    Returns AnimationTrack, will return nil if function fails
]]
function AnimationService:PlayAnimation(
    humanoid : Humanoid?,
    animationID : string?
): AnimationTrack | nil

    local animator : Animator? = humanoid:FindFirstChild("Animator")
    if not animator then
        warn("Animator doesn't exist inside humanoid")
        return
    end

    local animation : Animation? = Instance.new("Animation")
    animation.AnimationId = animationID

    local animationTrack : AnimationTrack? = animator:LoadAnimation(animation)
    animationTrack.Looped = false
	animationTrack:Play()

    animationTrack.Stopped:Once(function()
        animation:Destroy()
        animationTrack:Destroy()
    end)

    return animationTrack
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function AnimationService:KnitInit()

end

function AnimationService:KnitStart()
    
end


return AnimationService