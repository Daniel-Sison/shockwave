--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PolymorphicLerp = require(script.Parent.PolymorphicLerp)
local ResolveTweenAlpha = require(script.Parent.ResolveTweenAlpha)
local Fusion = require(ReplicatedStorage.Packages.Fusion)


type EasingFrame<T> = {
    startClockTime: number,
    startValue: T,
    goalValue: T,
}

local function getCurrent<T>(
    easingFrame: EasingFrame<T>,
    lerp: (T, T, number) -> T,
    info: TweenInfo
): (T, boolean)
    local elapsed = os.clock() - easingFrame.startClockTime
    local alpha, isFinished = ResolveTweenAlpha(info, elapsed)

    return lerp(
        easingFrame.startValue,
        easingFrame.goalValue,
        alpha
    ), isFinished
end

--[=[
    @function Eased
    @within FusionMotion
    @param inputValue Fusion.StateObject<T> -- The value to be eased. When this changes, the easing will restart from its current value.
    @param info TweenInfo -- The TweenInfo to use for the easing.
    @return Fusion.StateObject<T> -- The eased value.

    Creates an eased fusion observablue that will tween to the value of the
    input value from its current value, whenever the input changes, in realtime.

    Based on an observable subclass from the Dec library
    (https://dec.ambergracesoftware.com/api/Eased). Dec is licensed under the
    MIT open-source license.
]=]
local Eased = function<T>(
    inputValue: Fusion.StateObject<T>,
    info: TweenInfo
): Fusion.StateObject<T>
    local lerp = PolymorphicLerp(typeof(inputValue:get()))
    local easingFrame: EasingFrame<T> = {
        startClockTime = 0,
        startValue = inputValue:get(),
        goalValue = inputValue:get(),
    }

    local outValue = Fusion.Value(inputValue:get())

    local updateConn: RBXScriptConnection? = nil
    local function stopEasing()
        if not updateConn then
            return
        end
        updateConn:Disconnect()
        updateConn = nil
    end
    local function startEasing()
        if updateConn then
            return
        end
        updateConn = RunService.Heartbeat:Connect(function()
            local current, isDone = getCurrent(easingFrame, lerp, info)
            outValue:set(current)
            if isDone then
                stopEasing()
            end
        end)
    end

    Fusion.Observer(inputValue):onChange(function()
        easingFrame.startClockTime = os.clock()
        easingFrame.startValue = easingFrame.goalValue
        easingFrame.goalValue = inputValue:get()
        startEasing()
    end)

    return outValue
end

return Eased