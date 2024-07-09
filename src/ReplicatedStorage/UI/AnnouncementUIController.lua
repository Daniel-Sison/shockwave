local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Modules = ReplicatedStorage.Source.Modules
local GeneralUI = require(Modules.General.GeneralUI)
local Util = ReplicatedStorage.Util


-- Create the service:
local AnnouncementUIController = Knit.CreateController {
    Name = "AnnouncementUIController",
}

local player = game.Players.LocalPlayer

local NotificationService

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function AnnouncementUIController:PlayScreen(titleText : string, descText : string)
    self.Container.BackgroundTransparency = 1

    self.LoadingText.Text = descText
    self.Title.Text = titleText

    self.LoadingText.Position = self.LoadingText:GetAttribute("HiddenPosition")
    self.Title.Position = self.Title:GetAttribute("HiddenPosition")

    self.Title.TextTransparency = 0
    self.LoadingText.TextTransparency = 0

    self.Gui.Enabled = true

    game:GetService("SoundService").TitleDescIn:Play()
    --CameraController:ToggleBlur(true)

    GeneralUI:SimpleTween(
        self.Container,
        {BackgroundTransparency = 0.3},
        0.5
    )

    local first = GeneralUI:SimpleTween(
        self.LoadingText,
        {Position = self.LoadingText:GetAttribute("OriginPosition")},
        0.35,
        Enum.EasingStyle.Quad
    )

    first.Completed:Connect(function()
        GeneralUI:SimpleTween(
            self.LoadingText,
            {Position = self.LoadingText:GetAttribute("OriginPosition") + UDim2.new(-1, 0, 0, 0)},
            70,
            Enum.EasingStyle.Linear
        )
    end)

    local second = GeneralUI:SimpleTween(
        self.Title,
        {Position = self.Title:GetAttribute("OriginPosition")},
        0.35,
        Enum.EasingStyle.Quad
    )

    second.Completed:Connect(function()
        GeneralUI:SimpleTween(
            self.Title,
            {Position = self.Title:GetAttribute("OriginPosition") + UDim2.new(1, 0, 0, 0)},
            70,
            Enum.EasingStyle.Linear
        )
    end)
end


function AnnouncementUIController:CloseScreen(soundToPlay)
    if soundToPlay then
        local sound = game:GetService("SoundService"):FindFirstChild(soundToPlay)
        if sound then
            sound:Play()
        end
    end

    GeneralUI:SimpleTween(
        self.Title,
        {TextTransparency = 1},
        1
    )

    GeneralUI:SimpleTween(
        self.LoadingText,
        {TextTransparency = 1},
        1
    )

    local tween : Tween? = GeneralUI:SimpleTween(
        self.Container,
        {BackgroundTransparency = 1},
        1
    )

    tween.Completed:Connect(function()
        self.Gui.Enabled = false
    end)

    --CameraController:ToggleBlur(false)
end



function AnnouncementUIController:Close()
    return nil
end

function AnnouncementUIController:IsOpen()
    return nil
end



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function AnnouncementUIController:KnitInit()
    NotificationService = Knit.GetService("NotificationService")
end

function AnnouncementUIController:KnitStart()
    local targetName = string.gsub(script.Name, "Controller", "")
    self.Gui = player.PlayerGui:WaitForChild(targetName)
    self.Gui.Enabled = false

    self.Container = self.Gui:WaitForChild("Container")
    self.LoadingText = self.Container:WaitForChild("LoadingText")
    self.Title = self.Container:WaitForChild("Title")

    GeneralUI:Configure(self.LoadingText, self.LoadingText.Position + UDim2.new(1, 0, 0, 0))
    GeneralUI:Configure(self.Title, self.LoadingText.Position + UDim2.new(-1, 0, 0, 0))

    NotificationService.Announce:Connect(function(
        titleText : string,
        descText : string,
        soundToPlay : string,
        paddingTime : number
    )

        self:PlayScreen(titleText, descText)
        task.wait(paddingTime or 3)
        self:CloseScreen(soundToPlay)
    end)
end


return AnnouncementUIController
