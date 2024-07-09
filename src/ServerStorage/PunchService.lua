local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Knit = require(ReplicatedStorage.Packages.Knit)


local PunchService = Knit.CreateService {
    Name = "PunchService",
}


local AnimationService
local CharacterService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


function PunchService:RunPunch(character : Model?, count : number?)
    local attackerHumanoid : Humanoid? = character:FindFirstChild("Humanoid")
    if not attackerHumanoid then
        warn("No humanoid in given character")
        return
    end

    local attackerRoot : BasePart = character:FindFirstChild("HumanoidRootPart")
    if not attackerRoot then
        return
    end

    local leftHand : BasePart? = character:FindFirstChild("LeftHand")
    local rightHand : BasePart? = character:FindFirstChild("RightHand")
    
    if not leftHand or not rightHand then
        warn("Left/Right handd missing")
        return
    end

    
    local targetList

    if count % 2 == 0 then
        AnimationService:PlayAnimation(attackerHumanoid, self.LeftHandPunchID)
        task.wait(0.25)
        targetList = CharacterService:GetAllCharactersNear(
            leftHand.Position,
            5,
            {character}
        )
    else
        AnimationService:PlayAnimation(attackerHumanoid, self.RightHandPunchID)
        task.wait(0.25)
        targetList = CharacterService:GetAllCharactersNear(
            rightHand.Position,
            5,
            {character}
        )
    end

    if not targetList then
        warn("No targetlist")
        return
    end

    if #targetList < 1 then
        return
    end

    for _, model in ipairs(targetList) do
        self:ShowHitEffect(model, attackerRoot, count)
        self:DealDamage(model)
    end
end

function PunchService:DealDamage(targetCharacter : Model?)
    if not targetCharacter then
        return
    end

    local targetHum = targetCharacter:FindFirstChild("Humanoid") 
    if not targetHum then
        return
    end

    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart") 
    if not targetRoot then
        return
    end

    local damage = 5
    local afterDamage =  targetHum.Health - damage

    if afterDamage <= 10 then
        targetHum.Health = 10
    else
        targetHum:TakeDamage(damage)
    end
end


function PunchService:LoadTool(character : Model?, tool : Tool?)
    local debounce = true
    local count = 0

    self.AllConnections[tool] = tool.Activated:Connect(function()
        if not debounce then
            return
        end

        debounce = false
        count += 1

        self:RunPunch(character, count)

        if count >= 4 then
            count = 0
        end

        task.delay(0.25, function()
            debounce = true
        end)
    end)
end


function PunchService:UnloadTool(character : Model?, tool : Tool?)
    if self.AllConnections[tool] then
        self.AllConnections[tool]:Disconnect()
        self.AllConnections[tool] = nil
    end
end


function PunchService:ShowHitEffect(
    targetCharacter : Model?,
    attackerRoot : BasePart?,
    count : number?
)

	if not targetCharacter then
        return
    end

    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart") 
    if not targetRoot then
        return
    end

    local times = 0
    repeat
        times = times + 1
        self:CreateBallEffect(
            count,
            targetRoot, 
            targetRoot.CFrame * CFrame.new(math.random(-1,1),math.random(-1,1),math.random(-1,1))
        )
    until times >= 4

    local GoreFX = Assets.Effects.Combat.Gore:Clone()
    GoreFX.Parent = targetRoot
    GoreFX:Emit(1)
    game.Debris:AddItem(GoreFX, 1)

    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://3932506183"
    Sound.Parent = targetRoot
    Sound.PlaybackSpeed = math.random(93, 107) / 100
    Sound:Play()
    Sound.Ended:Connect(function(soundId)
        Sound:Destroy()
    end)

    if count == 4 then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e8,1e8,1e8)
        bv.Velocity = attackerRoot.CFrame.lookVector * 30
        bv.Parent = targetCharacter.HumanoidRootPart
        game.Debris:AddItem(bv, 0.3) 

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://4810749120"
        sound.Parent = targetRoot
        sound.PlaybackSpeed = math.random(93,107)/100
        sound:Play()
        game.Debris:AddItem(sound,3)
    end
end


function PunchService:CreateBallEffect(count : number?, target : BasePart?, pos : Vector3?)
        local hiteffect = Assets.Effects.Combat.Thing:Clone()
        hiteffect.CFrame = pos
        hiteffect.CFrame =  CFrame.new(hiteffect.Position, target.Position) 
        
        if count == 4 then
			hiteffect.BrickColor = BrickColor.new("Neon orange")
		end
        
        hiteffect.Parent = target

        game.Debris:AddItem(hiteffect, 1)
        game:GetService("TweenService"):Create(
            hiteffect,
            TweenInfo.new(
                0.5,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.InOut
            ),
            {
                CFrame = hiteffect.CFrame + hiteffect.CFrame.lookVector * -7,
                Transparency = 1,
                Size = Vector3.new(0.087, 0.08, 3.35)
            }
        ):Play()

    return hiteffect
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function PunchService:KnitInit()
    AnimationService = Knit.GetService("AnimationService")
    CharacterService = Knit.GetService("CharacterService")
end

function PunchService:KnitStart()
    self.AllConnections = {}

    self.LeftHandPunchID = "rbxassetid://5755181566"
    self.RightHandPunchID = "rbxassetid://5755182323"
end


return PunchService