local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules
local GeneralTween = require(Modules.General.GeneralTween)


local CharacterService = Knit.CreateService {
    Name = "CharacterService",
    Client = {
        CharacterUpdated = Knit.CreateSignal(),
    },
}


----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------

local CollisionService
local ShowDamageService
local PunchService

----------------------------------------------
-------------- Client Methods ----------------
----------------------------------------------



----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------



function CharacterService:MoveAllPlayersTo(givenCFrame: CFrame)
    for _, player in ipairs(game.Players:GetChildren()) do
        if not player then
            continue
        end

        if not player.Character then
            continue
        end

        player.Character:PivotTo(givenCFrame)
    end
end

--[[
    @param playersOrCharacters {Player?, Model?}
    @param attribute string?
    @param attributeValue any?
    @param callback

    Example:
        CharacterService:ApplyToAllWithAttribute(
            CharacterService:GetAllCharacters(),
            "Status",
            "Alive",
            function(playerOrCharacter: Player | Model)
                -- something here
            end
        )
]]
function CharacterService:ApplyToAllWithAttribute(
    playersOrCharacters: {Player?},
    attribute: string?,
    attributeValue: any?,
    callback: any
)

    for _, player in ipairs(playersOrCharacters) do
        if not player then
            continue
        end

        if attribute and attributeValue then
            if not player:GetAttribute(attribute) == attributeValue then
                continue
            end
        end

        callback(player)
    end
end


function CharacterService:GetAllCharacters(): {Model?}
    local characters = {}
    for _, player in ipairs(game.Players:GetChildren()) do
        if not player.Character then
            continue
        end

        table.insert(characters, player.Character)
    end
    return characters
end




function CharacterService:GetNearestCharacter(
    position : Vector3,
    range : number?,
    ignoreList : table?,
    container : any?
)

    local dist = range
    if not dist then
        dist = 100
    end

    local targetCharacter = nil

    local targetContainer : WorldRoot? = workspace
    if container then
        targetContainer = container
    end

    if not ignoreList then
        ignoreList = {}
    end

    for index, model in ipairs(targetContainer:GetChildren()) do
        if not model:IsA("Model") then
            continue
        end

        if table.find(ignoreList, model) then
            continue
        end

        local humanoid : Humanoid? = model:FindFirstChild("Humanoid")
        local root : BasePart? = model:FindFirstChild("HumanoidRootPart")

        if not humanoid or not root then
            continue
        end

        if humanoid.Health <= 0 then
            continue
        end

        if (root.Position - position).Magnitude < dist then
            targetCharacter = model
            dist = (root.Position - position).Magnitude
        end
    end

    return targetCharacter
end



function CharacterService:GetAllCharactersNear(
    position : Vector3,
    range : number?,
    ignoreList : table?,
    container : any?
): table?

    local dist = range
    if not dist then
        dist = 100
    end

    local targetTable = {}

    local targetContainer : WorldRoot? = workspace
    if container then
        targetContainer = container
    end

    if not ignoreList then
        ignoreList = {}
    end

    if not dist then
        dist = math.huge
    end

    for _, model in ipairs(targetContainer:GetChildren()) do
        if not model:IsA("Model") then
            continue
        end

        if table.find(ignoreList, model) then
            continue
        end

        local humanoid : Humanoid? = model:FindFirstChild("Humanoid")
        local root : BasePart? = model:FindFirstChild("HumanoidRootPart")

        if not humanoid or not root then
            continue
        end

        if humanoid.Health <= 0 then
            continue
        end

        if (root.Position - position).Magnitude < dist then
            table.insert(targetTable, model)
        end
    end

    return targetTable
end



--[[
    @params character Model

    Build a ragdoll
]]
function CharacterService:BuildRagdoll(character: Model?)
    local ragdollScript = ReplicatedStorage:FindFirstChild(
        "buildRagdoll"
    )
    if not ragdollScript then
        warn("Couldn't find ragdoll script")
        return
    end

    local buildRagdoll = require(ragdollScript)

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        warn("No humanoid in this given model")
        return
    end

    buildRagdoll(humanoid)
end



--[[
    @param characters
    @param damage

    damage all characters in the table. checks for humannoid and health
]]
function CharacterService:DamageCharacters(characters : table, damage: number)
    for _, model in ipairs(characters) do
        if not model then
            continue
        end

        if not model:IsDescendantOf(workspace) then
            continue
        end

        local humanoid = model:FindFirstChild("Humanoid")
        if not humanoid then
            continue
        end

        if humanoid.Health <= 0 then
            continue
        end

        humanoid:TakeDamage(damage)
    end
end


--[[
    @param characters
    @param callback (function)

    Apply a function to all the given characters.
    If the model doeosn't have a humanoid or root, wont apply the function
]]
function CharacterService:ApplyToCharacters(characters : table, callback)
    for _, model in ipairs(characters) do
        local humanoid = model:FindFirstChild("Humanoid")
        if not humanoid then
            continue
        end

        local root = model:FindFirstChild("HumanoidRootPart")
        if not root then
            continue
        end

        callback(model, humanoid, root)
    end
end




function CharacterService:AnchorEntireModel(model: Model, state: boolean)
    for _, part in ipairs(model:GetDescendants()) do
        if not part:IsA("BasePart") then
            continue
        end

        part.Anchored = state
    end
end


--[[
    Set becomeTransparent to false to REVERT the transparency change
]]
function CharacterService:ChangeCharacterTransparency(
    casterCharacter: Model?,
    becomeTransparent: boolean,
    settings: {
        transparency: number,
    }?
): Tween?

    if not settings then
        settings = {}
    end

    if not casterCharacter then
        warn("no given casterchar")
        return
    end

    local tween

    for _, part in ipairs(casterCharacter:GetDescendants()) do
        if not part:IsA("BasePart") and not part:IsA("Decal") then
            continue
        end

        if part.Name == "HumanoidRootPart" then
            continue
        end

        if not part:GetAttribute("OriginTransparency") then
            part:SetAttribute(
                "OriginTransparency",
                part.Transparency
            )
        end

        local targetTransparency = settings.transparency or 1
        if not becomeTransparent then
            targetTransparency = part:GetAttribute("OriginTransparency")
        end

        tween = GeneralTween:SimpleTween(
            part,
            {Transparency = targetTransparency},
            0.25,
            Enum.EasingStyle.Linear
        )
    end

    return tween
end




--[[
    @returns the new character model

    Will turn player's character into a different character
]]
function CharacterService:SetCharacter(
    player : Player,
    characterName : string,
    cFrameOffset: CFrame
): Model?

    local characterFolder : Folder = ReplicatedStorage.Assets.Characters
    local targetNewBody = characterFolder:FindFirstChild(characterName)

    if not targetNewBody then
        warn("Coulnt find the body: ", characterName)
        return
    end

    if not player.Character then
        return
    end

    targetNewBody = targetNewBody:Clone()
    targetNewBody.PrimaryPart = targetNewBody:WaitForChild("HumanoidRootPart")
    targetNewBody.Name = player.Name
    targetNewBody.Parent = workspace

    if cFrameOffset then
        targetNewBody:PivotTo(player.Character:GetPivot() * cFrameOffset)
    else
        targetNewBody:PivotTo(player.Character:GetPivot())
    end
    
    player.Character = targetNewBody
    self:ConfigureCharacter(targetNewBody, player)

    self.Client.CharacterUpdated:Fire(player, targetNewBody)

    return targetNewBody
end


function CharacterService:ConfigureCharacter(character: Model, player : Player)
    local humanoid : Humanoid? = character:WaitForChild("Humanoid")
    local root : BasePart? = character:WaitForChild("HumanoidRootPart")

    CollisionService:SetModelCollisionGroup(character, "Characters")
    ShowDamageService:ConnectHumanoid(humanoid)

    -- self:BuildRagdoll(character)

    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
    humanoid.DisplayName = player.DisplayName


    humanoid.Died:Once(function()
        -- Stuff in here possibly
    end)


    task.delay(1, function()
        local healthScript : Script = character:FindFirstChild("Health")
        if not healthScript then
            return
        end

        healthScript:Destroy()
    end)
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function CharacterService:KnitInit()
    CollisionService = Knit.GetService("CollisionService")
    ShowDamageService = Knit.GetService("ShowDamageService")
    PunchService = Knit.GetService("PunchService")
end


function CharacterService:KnitStart()
    game:GetService("Players").PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character : Model?)
            self:ConfigureCharacter(character, player)
        end)
    end)
end


return CharacterService