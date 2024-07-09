local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules

-- Create the service:
local CollisionService = Knit.CreateService {
    Name = "CollisionService",
    Client = {
    },
}


----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------



-- Item #1 cannot collide with anything in List #2
-- Example ["Trees] = ["Apples", "Pears", "Bananas"]
-- Trees cannot collide with apples, pears, or bananas.
local COLLIDERS : table = {
    ["Characters"] = {"Characters"}
}


----------------------------------------------
-------------- Client Methods ----------------
----------------------------------------------


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

function CollisionService:SetModelCollisionGroup(model : Model?, groupName : string?)
    for _, item in ipairs(model:GetDescendants()) do
        if not item:IsA("BasePart") then
            continue
        end

        item.CollisionGroup = groupName
    end
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

function CollisionService:_disableCollisions(key : string?, givenTable : table?)
    for _, item in ipairs(givenTable) do
        PhysicsService:CollisionGroupSetCollidable(key, item, false)
    end
end

----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function CollisionService:KnitInit()

end

function CollisionService:KnitStart()
    for key, value in pairs(COLLIDERS) do
        PhysicsService:RegisterCollisionGroup(key)
    end

    for key, value in pairs(COLLIDERS) do
        self:_disableCollisions(key, value)
    end
end


return CollisionService