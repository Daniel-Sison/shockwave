local GeneralUI = {}

----------- Services -----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

----------- Initiated Variables -----------

local player = game.Players.LocalPlayer


----------- Public Functions -----------

-- This is used to save the original and hidden locations of a designated frame.
-- It is not a required method to use this module, but it is very helpful.
function GeneralUI:Configure(frame : Frame?, hiddenPos : UDim2?)
	frame:SetAttribute("OriginPosition", frame.Position)
	frame:SetAttribute("OriginSize", frame.Size)
	
	if hiddenPos then
		frame:SetAttribute("HiddenPosition", hiddenPos)
	end

	for _, button in ipairs(frame:GetDescendants()) do
		if button:IsA("ImageButton") or button:IsA("TextButton") then

			local db1 = true
			button.MouseEnter:Connect(function()
				if not db1 then
					return
				end

				db1 = false

				if SoundService:FindFirstChild("MouseHover") then
					SoundService.MouseHover:Play()
				end
				
				task.delay(0.1, function()
					db1 = true
				end)
			end)

			local db2 = true
			button.MouseLeave:Connect(function()
				if not db2 then
					return
				end

				db2 = false

				if SoundService:FindFirstChild("MouseHover") then
					SoundService.MouseHover:Play()
				end
				
				task.delay(0.1, function()
					db2 = true
				end)
			end)
			
			button.Activated:Connect(function()
				SoundService.MouseClick:Play()
			end)
		end
	end
end


-- This will find the appropriate UI in the ReplicatedStorage
-- Assuming there is a folder called "UI" in the ReplicatedStorage that holds GUIs.
function GeneralUI:PlayUI(targetName : string?)
	local gui : ScreenGui? = ReplicatedStorage.UI:FindFirstChild(targetName)
	
	if not gui then
		warn("The target GUI cannot be found.")
		return
	end
	
	gui:Clone().Parent = player.PlayerGui
end


-- Call the tween on the UI
-- If only the frame and goal are passed as parameters, 
-- then the function will default to what is provided.
function GeneralUI:SimpleTween(frame, goal, duration, easingStyle, easingDirection)
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

	local tween = TweenService:Create(frame, tweenInfo, goal)
	tween:Play()
	
	return tween
end



return GeneralUI
