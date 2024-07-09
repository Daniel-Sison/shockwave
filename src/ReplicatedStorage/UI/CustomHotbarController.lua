local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Modules = ReplicatedStorage.Source.Modules
local GeneralUI = require(Modules.General.GeneralUI)
local Util = ReplicatedStorage.Util

local FusionMotion = require(ReplicatedStorage.Packages.FusionMotion)

-- Create the service:
local CustomHotbarController = Knit.CreateController {
    Name = "CustomHotbarController",
}


----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------

local player = game.Players.LocalPlayer

local CameraController
local SoundController


local selectedSlot = Fusion.Value(nil :: Instance?)

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

-- This will run every time the slot is selected
function CustomHotbarController:SlotSelected(slot : Frame)
    if selectedSlot:get() == slot then
        selectedSlot:set(nil)
    else
        selectedSlot:set(slot)
    end
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

function CustomHotbarController:_createButtons()
    for i = 1, 9 do
        local slot: Frame = self.Template:Clone()
        slot.Name = "Slot_" .. tostring(i)
        slot.Parent = self.Container

        slot:SetAttribute("OriginSize", slot.Size)
        slot:SetAttribute("SlotNumber", i)

        self.CurrentButtons[slot.Name] = slot

        self:_configureSlot(slot)
        self:_configureButton(slot:WaitForChild("TextButton"), slot)
    end
end


function CustomHotbarController:_configureSlot(slot : Frame)
    Fusion.Hydrate(slot) {
        Visible = true,
        Size = FusionMotion.Eased(Fusion.Computed(function()
            local currentIsSelected = selectedSlot:get()
            if currentIsSelected == slot then
                return slot:GetAttribute("OriginSize") + UDim2.fromScale(0.1, 0.1)
            else
                return slot:GetAttribute("OriginSize")
            end
        end), TweenInfo.new(0.05))
    }

    Fusion.Hydrate(slot:WaitForChild("UIStroke")) {
        Enabled = Fusion.Computed(function()
            if selectedSlot:get() == slot then
                return true
            else
                return false
            end
        end)
    }
end


function CustomHotbarController:_configureButton(textButton : TextButton, slot: Frame)
    Fusion.Hydrate(textButton) {
        [Fusion.OnEvent("Activated")] = function()
            self:SlotSelected(slot)
        end
    }
end


function CustomHotbarController:_setupNumberInputs()
    local numberToWord : string = {
        Enum.KeyCode.One,
        Enum.KeyCode.Two,
        Enum.KeyCode.Three,
        Enum.KeyCode.Four,
        Enum.KeyCode.Five,
        Enum.KeyCode.Six,
        Enum.KeyCode.Seven,
        Enum.KeyCode.Eight,
        Enum.KeyCode.Nine,
    }

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not self.Gui.Enabled then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end

        if not table.find(numberToWord, input.KeyCode) then
            return
        end


        UserInputService.InputEnded:Once(function(endedInput)
            if endedInput.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end

            local positionInTable : number = table.find(numberToWord, endedInput.KeyCode)
            if not positionInTable then
                return
            end

            local key = "Slot_" .. positionInTable
            self:SlotSelected(self.CurrentButtons[key])
        end)
    end)
end

----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function CustomHotbarController:KnitInit()
    CameraController = Knit.GetController("CameraController")
    SoundController = Knit.GetController("SoundController")
end

function CustomHotbarController:KnitStart()
    local targetName = string.gsub(script.Name, "Controller", "")
    self.Gui = player.PlayerGui:WaitForChild(targetName)

    self.Container = self.Gui:WaitForChild("Container")
    
    self.Template = self.Container:WaitForChild("SampleSpell")
    self.Template.Visible = false

    self.CurrentButtons = {}

    -- Create the hotbar buttons
    self:_createButtons()
    self:_setupNumberInputs()


    -- Configure the UI
    GeneralUI:Configure(
        self.Container,
        self.Container.Position + UDim2.fromScale(0, -0.5)
    )
end


return CustomHotbarController
