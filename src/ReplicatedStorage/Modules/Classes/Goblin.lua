
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Enemy = require(script.Parent.Enemy)

local Goblin = {}
Goblin.__index = Goblin
setmetatable(Goblin, Enemy)

----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
--------------- Constructor ------------------
----------------------------------------------



function Goblin.new(position : Vector3?, isAlly : boolean?)
	local self = Enemy.new("Goblin", position, isAlly)
	setmetatable(self, Goblin)

	self.StartingHealth = 8
	self.CoinDropAmount = math.random(5, 8)
	self.DeathSoundName = "YodaDeath"

	return self
end


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------



return Goblin