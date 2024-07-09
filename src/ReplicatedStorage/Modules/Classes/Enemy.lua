
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")


local Enemy = {}
Enemy.__index = Enemy


----------------------------------------------
---------------- CONSTANTS -------------------
----------------------------------------------


----------------------------------------------
--------------- Constructor ------------------
----------------------------------------------


function Enemy.new(bodyName : string?, spawnPosition : Vector3?)
    local self = {}
    setmetatable(self, Enemy)

    self.Body = Assets:FindFirstChild(bodyName):Clone()

    return self
end


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------



return Enemy