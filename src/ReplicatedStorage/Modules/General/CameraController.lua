local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GeneralUI = require(script.Parent.GeneralUI)


-- Create the service:
local CameraController = Knit.CreateController {
    Name = "CameraController",
}

----------- Services -----------

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")


----------- Initiated Variables -----------

local camera = workspace.CurrentCamera

local blur = Instance.new("BlurEffect")
blur.Size = 15


----------- Public Functions -----------


function CameraController:ResetCameraToDefault()
	camera.CameraType = Enum.CameraType.Custom
end


-- Snappy way to toggle blur in and out
function CameraController:ToggleBlur(value, size)
	local targetSize = 25
	if size then
		targetSize = size
	end
	
	if value then
		blur.Size = 0
		blur.Parent = Lighting
		
		GeneralUI:SimpleTween(
			blur,
			{Size = targetSize},
			0.35
		)
	else
		local tween = GeneralUI:SimpleTween(
			blur,
			{Size = 0},
			0.35
		)
		
		tween.Completed:Connect(function()
			blur.Parent = nil
		end)
	end
end


-- Will tween the camera to part
-- If part is not provided, then will return a warning
function CameraController:CameraToPart(part, duration, easingStyle, easingDirection)
	camera.CameraType = Enum.CameraType.Scriptable

	local goal = {}
	
	if part then
		goal.CFrame = part.CFrame
	else
		warn("No target part given for the camera to tween to.")
		return
	end
	
	if not duration then
		duration = 1
	end
	
	if not easingStyle then
		easingStyle = Enum.EasingStyle.Quad
	end
	
	if not easingDirection then
		easingDirection = Enum.EasingDirection.Out
	end

	local tweenInfo = TweenInfo.new(
		duration,
		easingStyle,
		easingDirection
	)

	local tween = TweenService:Create(camera, tweenInfo, goal)
	tween:Play()
	
	return tween
end


function CameraController:KnitInit()

end


function CameraController:KnitStart()
	local cameraPositions = workspace:WaitForChild("CameraPositions")
	for index, item in ipairs(cameraPositions:GetChildren()) do

		if not item:IsA("BasePart") then
			continue
		end

		item:ClearAllChildren()
		item.Transparency = 1
	
	end
end


return CameraController
