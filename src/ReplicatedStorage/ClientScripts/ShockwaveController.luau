local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules
local UtilityModule = require(Modules.UtilityModule)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Trove = require(ReplicatedStorage.Util:FindFirstChild(
    "trove",
    true
))

-- Create the service:
local ShockwaveController = Knit.CreateController {
    Name = "ShockwaveController",
}

----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------

local CharacterController
local ShockwaveService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function ShockwaveController:KnitInit()
    CharacterController = Knit.GetController("CharacterController")
    ShockwaveService = Knit.GetService("ShockwaveService")
end

function ShockwaveController:KnitStart()
    local inputInfo = {
        inputType = Enum.UserInputType.Keyboard,
        inputKeyCode = Enum.KeyCode.E
    }

    --[[
        This function basically watches for input based on given info.
    ]]
    CharacterController:WatchForInput(inputInfo, function()
        --[[
            Although we are creating a debounce here in the client,
            There will be a cooldown system in the server to verify it as well.
        ]]
        UtilityModule:CreateDebounce(
            "ShockwaveKeypressDebounce",
            2.5,
            function()
                ShockwaveService:RequestShockwave()
            end
        )
    end)
end


return ShockwaveController
