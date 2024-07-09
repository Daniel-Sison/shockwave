local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules
local GeneralUI = require(Modules.General.GeneralUI)
local TweenService = game:GetService("TweenService")

-- Create the service:
local NotificationController = Knit.CreateController {
    Name = "NotificationController",
}


local NotificationService

local player = game:GetService("Players").LocalPlayer

----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function NotificationController:Notify(text)
    local notificationUI = ReplicatedStorage.Assets.UI.NotificationUI:Clone()

    local textLabel = notificationUI:WaitForChild("TextLabel")
    textLabel.Text = text

    notificationUI.Parent = player.PlayerGui

    local otherNotifications = self:_countNotifications()

    self:_tweenText(notificationUI, textLabel, otherNotifications)
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

function NotificationController:_tweenText(notificationUI, text, count)
    
    local tweenInfo = TweenInfo.new(
        1, -- Time
        Enum.EasingStyle.Quint, -- EasingStyle
        Enum.EasingDirection.Out, -- EasingDirection
        0, -- RepeatCount (when less than zero the tween will loop indefinitely)
        false, -- Reverses (tween will reverse once reaching it's goal)
        0 -- DelayTime
    )
    
    
    local goals1 = {}
    goals1.TextStrokeTransparency = 0
    goals1.TextTransparency = 0
    
    
    local goals2 = {}
    goals2.TextStrokeTransparency = 1
    goals2.TextTransparency = 1
    
    local tween = TweenService:Create(text, tweenInfo, goals1)
    tween:Play()
    text:TweenSizeAndPosition(text.Size, UDim2.new(text.Position.X.Scale,0,0.7 - count,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 1)

    
    tween.Completed:Connect(function()

        task.delay(1, function()
            local tween2 = TweenService:Create(text, tweenInfo, goals2)
            tween2:Play()

            text:TweenSizeAndPosition(
                text.Size,
                UDim2.new(text.Position.X.Scale,0,0.8,0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quint, 
                1
            )
            
            tween2.Completed:Connect(function()
                notificationUI:Destroy()
            end)
        end)

    end)
end

function NotificationController:_countNotifications()
	local count = 0
	for index, otherGui in ipairs(player.PlayerGui:GetChildren()) do
		if otherGui.Name == "NotificationUI" then
			count += 1
		end
	end
	
	return count * 0.05 
end

----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function NotificationController:KnitInit()
    NotificationService = Knit.GetService("NotificationService")
end

function NotificationController:KnitStart()
    NotificationService.NotifyClient:Connect(function(text : string?)
        self:Notify(text)
    end)
end


return NotificationController
