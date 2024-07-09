--!strict
--[=[
    @class FusionMotion.Tween

    A computed fusion state that outputs a number between 0 and 1, with play/
    pause time controls.
]=]
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Alpha = require(script.Parent.Alpha)
local PolymorphicLerp = require(script.Parent.PolymorphicLerp)
local ResolveTweenAlpha = require(script.Parent.ResolveTweenAlpha)

type Alpha = Alpha.Alpha
export type Tween = Fusion.StateObject<number> & {
    toAlpha: (self: Tween) -> Alpha,
    lerp: <T>(
        self: Tween,
        startValue: T,
        endValue: T
    ) -> Fusion.StateObject<T>,
    play: (self: Tween) -> (),
    pause: (self: Tween) -> (),
    Destroy: (self: Tween) -> (),
    _setInternal: (self: Tween, elapsed: number) -> (),
    _info: TweenInfo,
    _playTask: RBXScriptConnection?,
    _timeControls: Fusion.Value<{
        playing: boolean,
        startClockTime: number,
        resumeElapsedTime: number?,
    }>
}

local Tween = {}
Tween.__index = {}
local superMethods = getmetatable(Fusion.Value(0) :: any).__index
for k, v in superMethods do
    (Tween.__index :: any)[k] = v
end

-- Override "Set" function and use an internal set function
Tween.__index._setInternal = (Tween.__index :: any).set
Tween.__index.set = nil

--[[
    @return FusionMotion.Alpha - An Alpha observable derived from the current
    state. The values remain the same, but the Alpha curve/slice methods are
    exposed.
]]
function Tween.__index.toAlpha(self: Tween)
    return Alpha.new(
        self,
        0,
        1
    )
end

--[[
    @return Fusion.StateObject<T> - The interpolated Observable.

    Creates an observable that outputs an interpolated value between
    the start value and end value based on the current elapsed time.
]]
function Tween.__index.lerp<T>(
    self: Tween,
    startValue: T,
    endValue: T
): Fusion.StateObject<T>
    local lerp = PolymorphicLerp(typeof(startValue))
    return Fusion.Computed(function()
        local alpha = self:get()
        return lerp(startValue, endValue, alpha)
    end)
end


local function stopPlayTask(self: Tween)
    if self._playTask then
        self._playTask:Disconnect()
        self._playTask = nil
    end
end
local function startPlayTask(self: Tween)
    if self._playTask then
        return
    end
    self._playTask = RunService.Heartbeat:Connect(function()
        local currentTimeControls = self._timeControls:get()
        if not currentTimeControls.playing then
            stopPlayTask(self)
            return
        end

        local elapsed = os.clock() - currentTimeControls.startClockTime
        local alpha, isFinished = ResolveTweenAlpha(
            self._info,
            elapsed
        )
        if isFinished then
            stopPlayTask(self)
            self._timeControls:set({
                playing = false,
                startClockTime = 0,
            })
            self:_setInternal(alpha)
            return
        end
        self:_setInternal(alpha)
    end)
end

--[[
    @return void

    Starts playing the Tween. The Tween observable will update with a new alpha
    value every heartbeat in real-time until it finishes or is paused.
]]
function Tween.__index.play(self: Tween)
    local currentTimeControls = self._timeControls:get()
    if currentTimeControls.playing then
        return
    end
    local startClockTime = os.clock()
    if currentTimeControls.resumeElapsedTime then
        startClockTime -= currentTimeControls.resumeElapsedTime
    end
    self._timeControls:set({
        playing = true,
        startClockTime = startClockTime,
    })
    startPlayTask(self)
end

--[[
    @return void

    Stops the Tween at its current position and resets the alpha value to 0.
    When resumed, the tween will restart from the beginning.
]]
function Tween.__index.cancel(self: Tween)
    local currentTimeControls = self._timeControls:get()
    if not currentTimeControls.playing then
        return
    end
    stopPlayTask(self)
    self._timeControls:set({
        playing = false,
        startClockTime = 0,
    })
    self:_setInternal(0)
end

--[[
    @return void

    Pauses the Tween at its current position. When resumed, the tween will
    continue at its current elapsed time position.
]]
function Tween.__index.pause(self: Tween)
    local currentTimeControls = self._timeControls:get()
    if not currentTimeControls.playing then
        return
    end
    local elapsed = os.clock() - currentTimeControls.startClockTime
    stopPlayTask(self)
    self._timeControls:set({
        playing = false,
        startClockTime = 0,
        resumeElapsedTime = elapsed,
    })
    self:_setInternal(elapsed)
end

--[[
    @return void

    Cleans up the Stopwatch, stopping its playback and destroying any internal
    listeners
]]
function Tween.__index.Destroy(self: Tween)
    stopPlayTask(self)
end

--[=[
    @function Tween
    @within FusionMotion
    @param info TweenInfo -- The tween info to use for the Tween.
    @return FusionMotion.Tween -- The new Tween observable.

    Creates a new Tween observable, which is a Fusion StateObject that outputs a
    number between 0 and 1 in realtime based on the provided tween info, and has
    controls for controlling realtime playback.

    To use like a tween object, call tween:play(), then use
    tween:lerp(startProperty, endProperty) to compute each property that needs
    to be tweened on a fusion-managed object.
]=]
function Tween.new(info: TweenInfo): Tween
    local self: Tween = Fusion.Value(0) :: any
    self._timeControls = Fusion.Value({
        playing = false,
        startClockTime = 0,
    })
    self._info = info
    setmetatable(self, Tween :: any)

    return self
end

return Tween