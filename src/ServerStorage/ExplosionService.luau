local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules

-- Create the service:
local ExplosionService = Knit.CreateService {
    Name = "ExplosionService",
    Client = {
    },
}


----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------

local SoundService
local CharacterService

local GeneralUI = require(Modules.General.GeneralUI)
local ParticleHandler = require(Modules.General.ParticleHandler)

----------------------------------------------
-------------- Client Methods ----------------
----------------------------------------------



----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function ExplosionService:Knockback(
    originPosition: Vector3,
    targetPart : BasePart,
    power : number,
    duration: number,
    upDraft: number
)

    local direction = targetPart.Position - originPosition

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e8,1e8,1e8)
    bv.Velocity = (direction * power) + Vector3.new(0, upDraft or 5, 0)
    bv.Parent = targetPart
    game.Debris:AddItem(bv, duration or 0.3)
end


--[[
    @param particleName is not required if explosionSettings.default == true
    @param position (required)

    @param explosionSettings.range (required - note this is RADIUS not diameter)

    Will STOP thread until explosion size finished. Reccomended to use TASK.SPAWN
    Returns all hit humanoids (table)
]]
function ExplosionService:Create(
    particleName: string,
    position: Vector3,
    explosionSettings: {
        ["targetFolder"]: Folder?,
        ["damage"]: number?,
        ["knockback"]: number,
        ["range"]: number,
        ["default"]: boolean?,
        ["sounds"]: {string},
    }
)

    if not explosionSettings then
        explosionSettings = {}
    end
    
    local explosionPart

    if particleName then
        explosionPart = ParticleHandler:PlayParticleAtPosition(
            particleName, position, {["Dust"] = {5, 0.1}}
        )
    elseif explosionSettings.default then
        explosionPart = ParticleHandler:PlayParticleAtPosition(
            "Explosion_Outer", position, {["Dust"] = {5, 0.1}}
        )
    end

    local radius = explosionSettings.range or 10
    local explosionSize: number = radius * 2

    explosionPart.Size = Vector3.new(0.01, 0.01, 0.01)
    
    if explosionSettings.sounds then
        for _, soundName in ipairs(explosionSettings.sounds) do
            SoundService:PlaySoundInPart(soundName, explosionPart)
        end
    elseif explosionSettings.default then
        SoundService:PlaySoundInPart("LaserExplosion", explosionPart)

        self:_defaultExplosionEffects(position, explosionSize)
    end

    local grow = GeneralUI:SimpleTween(
        explosionPart,
        {Size = Vector3.new(explosionSize, explosionSize, explosionSize)},
        0.4,
        Enum.EasingStyle.Elastic,
        Enum.EasingDirection.Out
    )

    grow.Completed:Wait()

    local targetFolder = explosionSettings.targetFolder
    if not targetFolder then
        targetFolder = workspace.Enemies
    end

    local targetCharacters : table = CharacterService:GetAllCharactersNear(
        explosionPart.Position,
        radius,
        {},
        targetFolder
    )

    CharacterService:DamageCharacters(
        targetCharacters,
        explosionSettings.damage or 0
    )

    CharacterService:ApplyToCharacters(targetCharacters, function(
        targetModel : Model?,
        targetHumanoid: Humanoid?,
        targetRoot : BasePart?
    )
        self:Knockback(
            explosionPart.Position,
            targetRoot,
            explosionSettings.knockback or 4
        )
    end)


    GeneralUI:SimpleTween(
        explosionPart,
        {Size = Vector3.new(0.01, 0.01, 0.01)},
        0.35,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In
    )

    return targetCharacters
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

function ExplosionService:_defaultExplosionEffects(
    position: Vector3,
    explosionSize: number
)

    local glowCore, glowTween = ParticleHandler:CreateStaticParticle(
        "Explosion_GlowCore",
        position,
        10,
        {
            addSize = Vector3.new(5, 5, 5),
            easingStyle = Enum.EasingStyle.Elastic,
            duration = 0.4
        }
    )

    -- local spinRing, spinTween = ParticleHandler:CreateStaticParticle(
    --     "Explosion_SpinRing",
    --     position,
    --     10,
    --     {
    --         addSize = Vector3.new(
    --             explosionSize * 0.75,
    --             explosionSize * 0.75,
    --             explosionSize * 0.75
    --         ),
    --         multiplyCFrame = CFrame.fromEulerAnglesXYZ(
    --             0,
    --             math.rad(360),
    --             0
    --         ),
    --         easingStyle = Enum.EasingStyle.Elastic,
    --         duration = 3
    --     }
    -- )

    glowTween.Completed:Connect(function()
        GeneralUI:SimpleTween(
            glowCore,
            {Size = Vector3.new(0.01, 0.01, 0.01)},
            0.35,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
        )

        -- GeneralUI:SimpleTween(
        --     spinRing,
        --     {
        --         Size = Vector3.new(0.01, 0.01, 0.01),
        --         CFrame = spinRing.CFrame * CFrame.fromEulerAnglesXYZ(
        --             0,
        --             math.rad(360),
        --             0
        --         ),
        --     },
        --     0.35,
        --     Enum.EasingStyle.Quad,
        --     Enum.EasingDirection.In
        -- )

        task.wait(0.4)
        glowCore:Destroy()
        -- spinRing:Destroy()
    end)
end

----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function ExplosionService:KnitInit()
    SoundService = Knit.GetService("SoundService")
    CharacterService = Knit.GetService("CharacterService")
end

function ExplosionService:KnitStart()

end


return ExplosionService