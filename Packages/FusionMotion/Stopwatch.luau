--!strict
--[=[
	@class FusionMotion.Stopwatch
	
	A computed fusion state that elapses in realtime, has start/stop/pause
	controls, and has other utility methods that can be used to create further
	observables that support a wide range of dynamic animations in Fusion.

	Based on an observable subclass from the Dec library
	(https://dec.ambergracesoftware.com/api/Stopwatch). Dec is licensed under
	the MIT open-source license.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Alpha = require(script.Parent.Alpha)

type Alpha = Alpha.Alpha
export type Stopwatch = Fusion.StateObject<number> & {
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
	play: (self: Stopwatch) -> (),
	pause: (self: Stopwatch) -> (),
	stop: (self: Stopwatch) -> (),
	setTimePosition: (
		self: Stopwatch,
		newTimePosition: number
	) -> (),
	Destroy: (self: Stopwatch) -> (),
	_setInternal: (self: Stopwatch, newTimePosition: number) -> (),
	_maxDuration: number,
	_playTask: RBXScriptConnection?,
	_timeControls: Fusion.Value<{
		playing: boolean,
		startClockTime: number,
		resumeClockTime: number,
	}>
}

local Stopwatch = {}
Stopwatch.__index = {}
local superMethods = getmetatable(Fusion.Value(0) :: any).__index
for k, v in superMethods do
	(Stopwatch.__index :: any)[k] = v
end

-- Override "Set" function and use an internal set function
Stopwatch.__index._setInternal = (Stopwatch.__index :: any).set
Stopwatch.__index.set = nil
function Stopwatch.__index.setTimePosition(
	self: Stopwatch,
	newTimePosition: number
)
	local maxDuration = self._maxDuration
	if (newTimePosition < 0) or (newTimePosition ~= newTimePosition) then
		newTimePosition = 0
	elseif newTimePosition > maxDuration then
		newTimePosition = maxDuration
	end
	local currentTimeControls = self._timeControls:get()
	self._timeControls:set({
		playing = currentTimeControls.playing,
		startClockTime = if currentTimeControls.playing
			then os.clock() - newTimePosition
			else 0,
		resumeClockTime = if currentTimeControls.playing
			then 0
			else newTimePosition,
	})
	self:_setInternal(newTimePosition)
end

--[=[
    @method slicealpha
    @within FusionMotion.Stopwatch
    @return FusionMotion.Alpha -- The sliced Alpha Observable.

    Creates a new [FusionMotion.Alpha] Observable that starts at the start
    duration (maps to 0) and ends at 0 (maps to 1).

    Useful for slicing up animation sequences into smaller slices.
]=]
function Stopwatch.__index.slicealpha(
	self: Stopwatch,
	param1: number,
	param2: number?
)
	local startElapsed = if param2 then param1 else 0
	local endElapsed = param2 or param1
	return Alpha.new(
		self,
		startElapsed,
		endElapsed
	)
end

--[=[
    @method lerp
    @within FusionMotion.Stopwatch
    @return Fusion.StateObject<T> -- The interpolated Observable.

    Creates an observable that outputs an interpolated value between
    the start value and end value based on the current elapsed time.
]=]
function Stopwatch.__index.lerp<T>(
	self: Stopwatch,
	startValue: T,
	endValue: T
): Fusion.StateObject<T>
	return self:alpha():lerp(startValue, endValue)
end

--[=[
    @method curvedalpha
    @within FusionMotion.Stopwatch
    @return FusionMotion.Alpha -- The interpolated Alpha Observable.

    Creates a new [FusionMotion.Alpha] Observable that interpolates between 0
    and 1 using the given easing style and direction. Useful for creating
    non-linear animations.
]=]
function Stopwatch.__index.curvedalpha(
	self: Stopwatch,
	easingStyle: Enum.EasingStyle,
	easingDirection: Enum.EasingDirection?
)
	return self:alpha():curve(easingStyle, easingDirection)
end


--[=[
    @method alpha
    @within FusionMotion.Stopwatch
    @return FusionMotion.Alpha

    Derives an [FusionMotion.Alpha] observable object that maps the elapsed time
    from 0 (start) to 1 (finish)
]=]
function Stopwatch.__index.alpha(self: Stopwatch)
	return Alpha.new(self, 0, self._maxDuration)
end

local function stopPlayTask(self: Stopwatch)
	if self._playTask then
		self._playTask:Disconnect()
		self._playTask = nil
	end
end
local function startPlayTask(self: Stopwatch)
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
		if elapsed >= self._maxDuration then
			stopPlayTask(self)
			self._timeControls:set({
				playing = false,
				startClockTime = 0,
				resumeClockTime = 0,
			})
			self:_setInternal(self._maxDuration)
			return
		end
		self:_setInternal(elapsed)
	end)
end

--[=[
    @method play
    @within FusionMotion.Stopwatch
    @return void

    Starts playing the Stopwatch. The Stopwatch observable will update with new
    values every heartbeat in real-time until it finishes or is stopped.
]=]
function Stopwatch.__index.play(self: Stopwatch)
	local currentTimeControls = self._timeControls:get()
	if currentTimeControls.playing then
		self:setTimePosition(0)
		return
	end
	self._timeControls:set({
		playing = true,
		startClockTime = os.clock() - currentTimeControls.resumeClockTime,
		resumeClockTime = 0,
	})
	startPlayTask(self)
end

--[=[
    @method pause
    @within FusionMotion.Stopwatch
    @return void

    Stops the Stopwatch at its current position. The Stopwatch can be resumed
    from this position by calling `:play()` again.
]=]
function Stopwatch.__index.pause(self: Stopwatch)
	local currentTimeControls = self._timeControls:get()
	if not currentTimeControls.playing then
		return
	end
	local elapsed = os.clock() - currentTimeControls.startClockTime
	if elapsed > self._maxDuration then
		elapsed = self._maxDuration
	end
	stopPlayTask(self)
	self._timeControls:set({
		playing = false,
		startClockTime = 0,
		resumeClockTime = elapsed,
	})
	self:_setInternal(elapsed)
end

--[=[
    @method stop
    @within FusionMotion.Stopwatch
    @return void

    Stops the Stopwatch and sets the elapsed time back to 0
]=]
function Stopwatch.__index.stop(self: Stopwatch)
	local currentTimeControls = self._timeControls:get()
	if not currentTimeControls.playing then
		return
	end
	stopPlayTask(self)
	self._timeControls:set({
		playing = false,
		startClockTime = 0,
		resumeClockTime = 0,
	})
	self:_setInternal(0)
end

--[=[
    @method Destroy
    @within FusionMotion.Stopwatch
    @return void

    Cleans up the Stopwatch, stopping its playback and destroying any internal
    listeners
]=]
function Stopwatch.__index.Destroy(self: Stopwatch)
	stopPlayTask(self)
end

--[=[
	@function Stopwatch
	@within FusionMotion
	@param maxDuration number -- The maximum duration of the stopwatch.
	@return FusionMotion.Stopwatch -- The new Stopwatch observable.

	Creates a new Stopwatch observable, which ends at the specified duration.
	Stopwatch is a Fusion StateObject with added methods for controlling the
	playback of the stopwatch.
]=]
function Stopwatch.new(
	maxDuration: number
): Stopwatch
	local self: Stopwatch = Fusion.Value(0) :: any
	self._timeControls = Fusion.Value({
		playing = false,
		startClockTime = 0,
		resumeClockTime = 0,
	})
	self._maxDuration = maxDuration
	setmetatable(self, Stopwatch :: any)

	return self
end

return Stopwatch