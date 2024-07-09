--!strict
--[=[
    @class FusionMotion.Timer

    A computed fusion state that counts down in realtime, has start/stop/pause
    controls, and has other utility methods that can be used to create further
    observables that support a wide range of dynamic animations in Fusion.

    Design draws heavy inspiration from the Dec library's motion observables
    (https://dec.ambergracesoftware.com/api/Timer). Dec is licensed under the
    MIT open-source license.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Stopwatch = require(script.Parent.Stopwatch)

type Stopwatch = Stopwatch.Stopwatch
local Alpha = require(script.Parent.Alpha)

type Alpha = Alpha.Alpha
export type Timer = Fusion.StateObject<number> & {
    slicealpha: (
        self: Stopwatch,
        startTime: number,
        endTime: number
    ) -> Alpha,
    lerp: <T>(
        self: Stopwatch,
        startValue: T,
        endValue: T
    ) -> Fusion.StateObject<T>,
    curvedalpha: (
        self: Stopwatch,
        easingStyle: Enum.EasingStyle,
        easingDirection: Enum.EasingDirection?
    ) -> Alpha,
    alpha: (self: Stopwatch) -> Alpha,
    play: (self: Timer) -> (),
    pause: (self: Timer) -> (),
    stop: (self: Timer) -> (),
    setTimeRemaining: (
        self: Timer,
        newTimeLeft: number
    ) -> (),
    Destroy: (self: Timer) -> (),
    _stopwatch: Stopwatch,
}

local Timer = {}
Timer.__index = {}
local superMethods = getmetatable(
    Fusion.Computed(function()
        return nil
    end) :: any
).__index
for k, v in superMethods do
    (Timer.__index :: any)[k] = v
end
Timer.__index.set = nil

function Timer.__index.setTimeRemaining(
    self: Timer,
    newTimeRemaining: number
)
    self._stopwatch:setTimePosition(
        self._stopwatch._maxDuration - newTimeRemaining
    )
end

--[=[
    @method play
    @within FusionMotion.Timer
    @return void

    Starts playing the Timer. The Timer observable will update with new
    values every heartbeat in real-time until it finishes or is stopped.
]=]
function Timer.__index.play(
    self: Timer
)
    self._stopwatch:play()
end

--[=[
    @method pause
    @within FusionMotion.Timer
    @return void

    Stops the Timer at its current position. The Timer can be resumed
    from this position by calling `:play()` again.
]=]
function Timer.__index.pause(
    self: Timer
)
    self._stopwatch:pause()
end

--[=[
    @method stop
    @within FusionMotion.Timer
    @return void

    Stops the Timer and sets the elapsed time back to the timer's start time.
]=]
function Timer.__index.stop(
    self: Timer
)
    self._stopwatch:stop()
end

--[=[
    @method Destroy
    @within FusionMotion.Timer
    @return void

    Cleans up the Timer, stopping its playback and destroying any internal
    listeners
]=]
function Timer.__index.Destroy(
    self: Timer
)
    self._stopwatch:Destroy()
end


--[=[
    @method alpha
    @within FusionMotion.Timer
    @return FusionMotion.Alpha

    Derives an [FusionMotion.Alpha] observable object that maps the duration
    from 0 (start) to 1 (finish)
]=]
function Timer.__index.alpha(
    self: Timer
): Alpha
    return self._stopwatch:alpha()
end


--[=[
    @method slicealpha
    @within FusionMotion.Timer
    @return FusionMotion.Alpha -- The sliced Alpha Observable.

    Creates a new [FusionMotion.Alpha] Observable that starts at the start
    duration (maps to 0) and ends at 0 (maps to 1).

    Useful for slicing up animation sequences into smaller slices.
]=]
function Timer.__index.slicealpha(
    self: Timer,
    startTime: number,
    endTime: number
): Alpha
    return self._stopwatch:slicealpha(self._stopwatch._maxDuration - startTime,
        self._stopwatch._maxDuration - endTime)
end

--[=[
    @method lerp
    @within FusionMotion.Timer
    @return Fusion.StateObject<T> -- The interpolated Observable.

    Creates an observable that outputs an interpolated value between
    the start value and end value based on the current remaining time.
]=]
function Timer.__index.lerp<T>(
    self: Timer,
    startValue: T,
    endValue: T
): Fusion.StateObject<T>
    return self._stopwatch:lerp(startValue, endValue)
end

--[=[
    @method curvedalpha
    @within FusionMotion.Timer
    @return FusionMotion.Alpha -- The interpolated Alpha Observable.

    Creates a new [FusionMotion.Alpha] Observable that interpolates between 0
    and 1 using the given easing style and direction. Useful for creating
    non-linear animations.
]=]
function Timer.__index.curvedalpha(
    self: Timer,
    easingStyle: Enum.EasingStyle,
    easingDirection: Enum.EasingDirection?
): Alpha
    return self._stopwatch:curvedalpha(easingStyle, easingDirection)
end

--[=[
    @function Timer
    @within FusionMotion
    @param duration number -- The duration of the timer.
    @return FusionMotion.Timer -- The new Timer observable.

    Creates a new Timer observable, which ends at the specified duration.
    Timer is a Fusion StateObject with added methods for controlling the
    playback of the timer.
]=]
function Timer.new(
    maxDuration: number
): Timer
    local stopwatch = Stopwatch.new(maxDuration)
    local self: Timer = Fusion.Computed(function()
        local elapsed = stopwatch:get()

        return math.clamp(maxDuration - elapsed, 0, maxDuration)
    end) :: any
    setmetatable(self, Timer)

    self._stopwatch = Stopwatch.new(maxDuration)

    return self
end

return Timer