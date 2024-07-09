local GeneralTween = {}

----------- Services -----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")


----------- Initiated Variables -----------


----------- Public Functions -----------


--[[
	@returns Tween

	Simple tween for any item.
	Mainly used to condense the entire tweening process into one function.
]]
function GeneralTween:SimpleTween(
	item : any,
	goal: {},
	duration: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?
)

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

	local tween = TweenService:Create(item, tweenInfo, goal)
	tween:Play()
	
	return tween
end



return GeneralTween
