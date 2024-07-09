local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules

local ShowDamageService = Knit.CreateService {
    Name = "ShowDamageService",
}

----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------


----------------------------------------------
-------------- Client Methods ----------------
----------------------------------------------


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function ShowDamageService:ConnectHumanoid(humanoid : Humanoid?)
    local previousHealth = humanoid.MaxHealth

    local died = false
    local connection = humanoid.HealthChanged:Connect(function()
        if died then
            return
        end

        if humanoid.Health <= 0 then
            died = true
        end

        local chosenColor = Color3.fromRGB(245, 137, 23)
        local inFront = "-"

        if humanoid.Health > 0 and humanoid.Health > previousHealth then
            chosenColor = Color3.fromRGB(71, 194, 71)
            inFront = "+"
        end

        local root = humanoid.Parent:FindFirstChild("HumanoidRootPart") or
            humanoid.Parent:FindFirstChild("Core")
        if not root then
            warn("No root")
            return
        end

        local damageTaken = math.round(previousHealth - humanoid.Health)
        damageTaken = math.abs(damageTaken)
        
        self:Show(inFront .. tostring(damageTaken), root, chosenColor)

        previousHealth = humanoid.Health
    end)

    humanoid.Destroying:Once(function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end)

    humanoid.Died:Once(function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end)
end




function ShowDamageService:Show(
    damageTaken : string?,
    item : BasePart?,
    colorGiven : Color3?,
    guiSize : UDim2
)

	local tweenInfo = TweenInfo.new(
        1,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.InOut
    )

	local damageIndicatorGui = Instance.new("BillboardGui")
	damageIndicatorGui.AlwaysOnTop = true
    damageIndicatorGui.MaxDistance = 150

    self:_showHighlight(item)

	game.Debris:AddItem(damageIndicatorGui, 3)

    if not guiSize then
        damageIndicatorGui.Size = UDim2.new(4.5, 0, 4.5, 0) -- originally 1.5
    else
        damageIndicatorGui.Size = guiSize
    end
	
	local offsetX = math.random(-10, 10)/10
	local offsetY = math.random(-10, 10)/10
	local offsetZ = math.random(-10, 10)/10
	damageIndicatorGui.StudsOffset = Vector3.new(offsetX, offsetY, offsetZ)

	local damageIndicatorLabel = Instance.new("TextLabel")

	damageIndicatorLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	damageIndicatorLabel.Position = UDim2.new(0.5, 0, 0.5, 0)

	damageIndicatorLabel.TextScaled = true
	damageIndicatorLabel.BackgroundTransparency = 1
	damageIndicatorLabel.Font = Enum.Font.GothamBlack

	damageIndicatorLabel.Text = damageTaken
	damageIndicatorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	damageIndicatorLabel.Size = UDim2.new(0, 0, 0, 0)

	damageIndicatorLabel.Parent = damageIndicatorGui
	
	damageIndicatorGui.Parent = item
	damageIndicatorLabel:TweenSize(UDim2.new(1, 0, 1, 0), "InOut", "Quint", 0.3)

	damageIndicatorLabel.TextColor3 = colorGiven

	task.delay(0.3, function()
		local guiUpTween = TweenService:Create(
            damageIndicatorGui,
            tweenInfo,
            {
                StudsOffset = damageIndicatorGui.StudsOffset + Vector3.new(
                    0,
                    1.5,
                    0
                )
            }
        )
		local textFadeTween = TweenService:Create(
            damageIndicatorLabel,
            tweenInfo,
            {TextTransparency = 1}
        )

		guiUpTween:Play()
		textFadeTween:Play()

		textFadeTween.Completed:Connect(function()
			damageIndicatorGui:Destroy()
		end)
	end)
end 


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


function ShowDamageService:_showHighlight(item : BasePart)
    task.defer(function()
        local currentSelected = item
        local parentModel = currentSelected:FindFirstAncestorOfClass("Model")

        if not parentModel then
            return
        end

        if parentModel:FindFirstChild("HitFlash") then
            return
        end

        local highlight = ReplicatedStorage.Assets.Effects.TookDamage:Clone()
        highlight.Name = "HitFlash"
        highlight.Parent = parentModel
        highlight.Adornee = parentModel

        task.delay(0.1, function()
            highlight:Destroy()
        end)
    end)
end


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function ShowDamageService:KnitInit()

end

function ShowDamageService:KnitStart()

end


return ShowDamageService