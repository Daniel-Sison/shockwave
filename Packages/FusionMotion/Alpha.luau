--!strict
--[=[
    @class FusionMotion.Alpha

    A computed fusion state that maps from 0 to 1, with many helper methods to
    create further observables that support a full tween animation.

    Based on an observable subclass from the Dec library
    (https://dec.ambergracesoftware.com/api/Alpha). Dec is licensed under the
    MIT open-source license.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PolymorphicLerp = require(script.Parent.PolymorphicLerp)

export type Alpha = Fusion.StateObject<number> & {
    slice: (
        self: Alpha,
        start: number,
        finish: number
    ) -> Alpha,
    curve: (
        self: Alpha,
        easingStyle: Enum.EasingStyle,
        easingDirection: Enum.EasingDirection?
    ) -> Alpha,
    lerp: <T>(
        self: Alpha,
        start: T,
        finish: T
    ) -> Fusion.Computed<T>,
    invert: (self: Alpha) -> Alpha,
}

local Alpha = {}
Alpha.__index = {}
local superMethods = getmetatable(
    Fusion.Computed(function()
        return nil
    end) :: any
).__index
for k, v in superMethods do
    if k == "set" then
        continue
    end
    (Alpha.__index :: any)[k] = v
end

--[=[
    @method slice
    @within FusionMotion.Alpha
    @param startAlpha number -- The start value for the slice.
    @param endAlpha number -- The end value for the slice.
    @return FusionMotion.Alpha -- The sliced Alpha Observable.

    Creates a slice of the current Alpha Observable that starts at startAlpha
    (maps to 0) and ends at endAlpha (maps to 1).

    Useful for slicing up animation sequences into smaller slices.
]=]
function Alpha.__index.slice(
    self: Alpha,
    start: number,
    finish: number
): Alpha
    return Alpha.new(
        self,
        start,
        finish
    )
end

--[=[
    @method invert
    @within FusionMotion.Alpha
    @return FusionMotion.Alpha -- The inverted Alpha observable.

    Creates a new Alpha observable that maps 0 to 1 and 1 to 0 from the original
    observable. Useful for reversing animations, output values, etc.
]=]
function Alpha.__index.invert(
    self: Alpha
): Alpha
    return Alpha.new(
        self,
        1,
        0
    )
end

--[=[
    @method curve
    @within FusionMotion.Alpha
    @param easingStyle Enum.EasingStyle? -- Optional easing style.
    @param easingDirection Enum.EasingDirection? -- Optional easing direction.
    @return FusionMotion.Alpha -- The interpolated Alpha observable.

    Creates a new Alpha observable that interpolates between 0 and 1 using
    the given easing style and direction. Useful for creating non-linear
    animations.
]=]
function Alpha.__index.curve(
    self: Alpha,
    easingStyle: Enum.EasingStyle,
    easingDirection: Enum.EasingDirection?
): Alpha
    local result: Alpha = Fusion.Computed(function()
        local currentAlpha = self:get()
        return TweenService:GetValue(
            currentAlpha,
            easingStyle,
            easingDirection or Enum.EasingDirection.Out
        )
    end) :: any
    setmetatable(result, Alpha :: any)

    return result
end

--[=[
    @method lerp
    @within FusionMotion.Alpha
    @param startValue T -- The start value for the lerp.
    @param goalValue T -- The goal value for the lerp.
    @return Fusion.StateObject<T> -- The lerped observable.

    Creates a new observable that outputs an interpolated value between the 
    start value and goal value based on the current Alpha value.
]=]
function Alpha.__index.lerp<T>(
    self: Alpha,
    start: T,
    finish: T
): Fusion.StateObject<T>
    local lerp = PolymorphicLerp(typeof(start))
    local result: Fusion.Computed<T> = Fusion.Computed(function()
        local currentAlpha = self:get()
        return lerp(start, finish, currentAlpha)
    end) :: any

    return result
end

--[=[
    @function Alpha
    @within FusionMotion
    @param sourceState Dec.Fusion.StateObject<number> -- The source state to derive an alpha from.
    @param sourceRangeMin number -- The number in source state to maps to 0
    @param sourceRangeMax number -- The number in source state to maps to 1
    @return FusionMotion.Alpha -- The new Alpha observable.

    Creates a new Alpha observable with the provided initial value.
]=]
function Alpha.new(
    sourceNumber: Fusion.StateObject<number>,
    boundsMin: number,
    boundsMax: number
): Alpha
    local self: Alpha = Fusion.Computed(function()
        local currentSourceNumber = sourceNumber:get()
        local alphaUnclamped = (currentSourceNumber - boundsMin)
            / (boundsMax - boundsMin)
        if alphaUnclamped ~= alphaUnclamped then
            return boundsMin
        end
        return math.clamp(alphaUnclamped, 0, 1)
    end) :: any
    setmetatable(self, Alpha :: any)

    return self
end

return Alpha