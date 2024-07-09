--!strict
--[[
    Resolves an Alpha between 0 and 1 from a TweenInfo and elapsed time
]]
local TweenService = game:GetService("TweenService")

local function ResolveTweenAlpha(
    info: TweenInfo,
    elapsed: number
): (number, boolean)
    local cycleLength
    if info.Reverses then
        cycleLength = info.DelayTime + info.Time * 2
    else
        cycleLength = info.DelayTime + info.Time
    end
    local totalCycles = info.RepeatCount + 1
    local cycleElapsed = elapsed % cycleLength
    local cycleNumber = math.floor(elapsed / cycleLength)

    -- if we're past the total cycles, snap to the final value and return
    if cycleNumber >= totalCycles then
        return if info.Reverses then 0 else 1, true
    end

    local inReverse = info.Reverses
        and (cycleElapsed >= info.DelayTime + info.Time)

    local alpha
    if cycleElapsed < info.DelayTime and not inReverse then
        alpha = 0
    else
        local timePosition
        if inReverse then
            timePosition = 2 * info.Time - cycleElapsed - info.DelayTime
        else
            timePosition = cycleElapsed - info.DelayTime
        end
        alpha = TweenService:GetValue(
            math.clamp(timePosition, 0, info.Time) / info.Time,
            info.EasingStyle,
            info.EasingDirection
        )
    end

    return alpha, false
end
return ResolveTweenAlpha