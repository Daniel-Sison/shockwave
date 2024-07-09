local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Modules = ReplicatedStorage.Source.Modules
local GeneralUI = require(Modules.General.GeneralUI)
local Util = ReplicatedStorage.Util


-- Create the service:
local UIControllerTemplate = Knit.CreateController {
    Name = "UIControllerTemplate",
}


----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------

local player = game.Players.LocalPlayer

local CameraController
local SoundController


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function UIControllerTemplate:KnitInit()
    CameraController = Knit.GetController("CameraController")
    SoundController = Knit.GetController("SoundController")
end

function UIControllerTemplate:KnitStart()
    local targetName = string.gsub(script.Name, "Controller", "")
    self.Gui = player.PlayerGui:WaitForChild(targetName)
end


return UIControllerTemplate
