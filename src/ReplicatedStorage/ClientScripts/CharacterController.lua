local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules
local GeneralUI = require(Modules.General.GeneralUI)
local Fusion = require(ReplicatedStorage.Packages.Fusion)


-- Create the service:
local CharacterController = Knit.CreateController {
    Name = "CharacterController",
}

----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------

local CharacterService
local DataSaveService
local DefaultAnimationController

local Trove = require(ReplicatedStorage.Util:FindFirstChild(
    "trove",
    true
))

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


--[[
    @param inputType Enum.UserInputType
    @param callback function

    Sets up local player inputs.
]]
function CharacterController:WatchForInput(
    inputInfo: {
        inputType: Enum.UserInputType,
        inputKeyCode: Enum.KeyCode
    },
    callback
): any

    local beingPressed = Fusion.Value(false)
    local connection = UserInputService.InputBegan:Connect(function(
        input: InputObject,
        gameProcessed: boolean
    )

        -- We want to ignore inputs when player is chatting, etc.
        if gameProcessed then
            return
        end
    
        if input.UserInputType ~= inputInfo.inputType then
            return
        end

        if inputInfo.inputKeyCode and input.KeyCode then
            if input.KeyCode ~= inputInfo.inputKeyCode then
                return
            end
        end

        beingPressed:set(true)
    
        local inputEnded
        inputEnded = UserInputService.InputEnded:Connect(function(
            input: Enum.UserInputType
        )

            if input.UserInputType ~= inputInfo.inputType then
                return
            end

            if inputInfo.inputKeyCode and input.KeyCode then
                if input.KeyCode ~= inputInfo.inputKeyCode then
                    return
                end
            end

            if inputEnded then
                inputEnded:Disconnect()
                inputEnded = nil
            end

            beingPressed:set(false)

            callback()
        end)
    end)

    self.Trove:Add(connection)
    self.Trove:Add(function()
        beingPressed = nil
    end)

    return beingPressed
end



--[[
    Clean up all of the connections made by watching the inputs.
]]
function CharacterController:ClearConnections()
    self.Trove:Clean()
end




function CharacterController:GetAllCharacters(): {Model?}
    local characters = {}
    for _, player in ipairs(game.Players:GetChildren()) do
        if not player.Character then
            continue
        end

        table.insert(characters, player.Character)
    end
    return characters
end



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function CharacterController:KnitInit()
    CharacterService = Knit.GetService("CharacterService")
    DataSaveService = Knit.GetService("DataSaveService")
    DefaultAnimationController = Knit.GetController("DefaultAnimationController")

    -- Connections will get stored in the trove to be cleaned later
    self.Trove = Trove.new()

    -- This variable is a fusion value, other things are able to listen to this
    -- variable being changed.
    self.PlayerData = Fusion.Value({})
end


function CharacterController:KnitStart()
    CharacterService.CharacterUpdated:Connect(function(character : Model?)
        local humanoid = character:WaitForChild("Humanoid")
        workspace.CurrentCamera.CameraSubject = humanoid

        DefaultAnimationController:Setup(character)
    end)

    -- When server's player stats are updated, send that data directly to the client.
    DataSaveService.DataUpdated:Connect(function(playerStats: {})
        self.PlayerData:set(playerStats)
    end)
end


return CharacterController
