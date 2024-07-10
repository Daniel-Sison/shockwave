local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Modules = ReplicatedStorage.Source.Modules
local UtilityModule = require(Modules.UtilityModule)
local Trove = require(ReplicatedStorage.Util:FindFirstChild(
    "trove",
    true
))

-- Create the service:
local CharacterController = Knit.CreateController {
    Name = "CharacterController",
}

----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------



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



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function CharacterController:KnitInit()
    -- Connections will get stored in the trove to be cleaned later
    self.Trove = Trove.new()
end


function CharacterController:KnitStart()
    
end


return CharacterController
