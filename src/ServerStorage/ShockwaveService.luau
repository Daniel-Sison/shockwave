local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules
local UtilityModule = require(Modules.UtilityModule)
local Trove = require(ReplicatedStorage.Util:FindFirstChild(
    "trove",
    true
))


-- Create the service:
local ShockwaveService = Knit.CreateService {
    Name = "ShockwaveService",
    Client = {
        TestDataChanged = Knit.CreateSignal(), -- Create the signal
    },
}


----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------

----------------------------------------------
-------------- Client Methods ----------------
----------------------------------------------


function ShockwaveService.Client:RequestShockwave(player: Player)
    self.Server:RequestShockwave(player)
end


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

--[[
    @param player Player

    Since this function is being requested by the client,
    everything has to be verified by the server.
]]
function ShockwaveService:RequestShockwave(player: Player)
    if not player then
        warn("Failed to provide player as an argument")
        return
    end

    if typeof(player) ~= "Instance" then
        warn("Argument provided is not an instance")
        return
    end

    if not player:IsA("Player") then
        warn("Argument provided is not a player")
        return
    end

    local character = player.Character
    if not character then
        return
    end

    --[[
        If the ability is not on cooldown and ready, then
        it will cast.
    ]]
    if not self:_isAbilityReady(character) then
        return
    end

    self:CastShockwave(player, character)
end

--[[
    @param player Player
    @param character Model
    
    Cast the shockwave, which applies impulses to any nearby parts.
]]
function ShockwaveService:CastShockwave(player: Player, character: Model)
    if not player then
        return
    end

    if not character then
        return
    end

    --[[
        This function is responsible for applying the impulse to
        the specified part.

        The power of the impulse is calculated based
        on the part's total mass as well.
    ]]
    local function applyImpulse(
        part: BasePart, 
        characterPosition: Vector3
    )
        if not part then
            return
        end

        if not characterPosition then
            return
        end

        local mass = part:GetMass()
        local direction = (part.Position - characterPosition).Unit
        local upForce = Vector3.new(0, 0.5, 0)
        local power = 200

        part:SetNetworkOwner(nil)

        part:ApplyImpulse(
            (direction + upForce) *
            power *
            mass
        )
    end

    -- Apply the cooldown on the character
    self:_applyCooldown(character)

    -- Get all of the possible parts to cast the impulse on
    for _, part in ipairs(workspace.AffectedParts:GetChildren()) do
        if not part:IsA("BasePart") then
            continue
        end

        if part.Anchored then
            continue
        end

        local characterPosition = character:GetPivot().Position
        local partPosition = part.Position

        -- We don't want to affect all of the parts, just the ones
        -- within a certain range.
        if (characterPosition - partPosition).Magnitude > 100 then
            continue
        end

        applyImpulse(part, characterPosition)
    end
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

--[[
    @param character Model
    @returns boolean
    
    Checks to see if the ability is ready.
    Returns true or false.
]]
function ShockwaveService:_isAbilityReady(character: Model)
    if not character then
        return false
    end

    if not character:IsDescendantOf(workspace) then
        return false
    end

    if character:GetAttribute("ShockwaveCooldown") then
        return false
    end

    return true
end

--[[
    @param character Model
    
    Apply the cooldown on the character using an attribute.
    We want to avoid using task.wait,
    so we use task.delay here in order to not "pause" the thread.
]]
function ShockwaveService:_applyCooldown(character: Model)
    if not character then
        return
    end
    
    if not character:IsDescendantOf(workspace) then
        return
    end

    character:SetAttribute("ShockwaveCooldown", true)

    task.delay(2.5, function()
        character:SetAttribute("ShockwaveCooldown", nil)
    end)
end


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function ShockwaveService:KnitInit()

end

function ShockwaveService:KnitStart()
    --[[
        Allow players to run fast for
        easier and more efficient testing.
    ]]

    if not RunService:IsStudio() then
        return
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character: Model)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.WalkSpeed = 50
        end)
    end)
end


return ShockwaveService