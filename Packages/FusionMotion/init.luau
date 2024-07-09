--!strict
--[=[


]=]

local Alpha = require(script.Alpha)
local Stopwatch = require(script.Stopwatch)
local Timer = require(script.Timer)
local Eased = require(script.Eased)
local Tween = require(script.Tween)

export type Alpha = Alpha.Alpha
export type Stopwatch = Stopwatch.Stopwatch

local FusionMotion = {}

FusionMotion.Alpha = Alpha.new
FusionMotion.Stopwatch = Stopwatch.new
FusionMotion.Timer = Timer.new
FusionMotion.Eased = Eased
FusionMotion.Tween = Tween.new

return FusionMotion