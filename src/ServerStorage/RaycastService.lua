local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules

-- Create the service:
local RaycastService = Knit.CreateService {
    Name = "RaycastService",
    Client = {
    },
}


----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------


----------------------------------------------
-------------- Client Methods ----------------
----------------------------------------------



----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------

--[[
    @param originPoint Vector3
    @param destinationPoiont Vector3
    @param ignoreList {}
    @param filterType Enum.RaycastFilterType

    Create a raycast between two points, returns results.
]]
function RaycastService:Cast(
    originPoint : Vector3,
    destinationPoint : Vector3,
    ignoreList : {}?,
    filterType : Enum.RaycastFilterType?
): RaycastResult?

    local raycastParams = RaycastParams.new()

    if not filterType then
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    else
        raycastParams.FilterType = filterType
    end
    
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.IgnoreWater = true

    --	print("Object/terrain hit:", raycastResult.Instance:GetFullName())
    --	print("Hit position:", raycastResult.Position)
    --	print("Name of Parent:", raycastResult.Instance.Parent.Name)
    --	print("Material hit:", raycastResult.Material.Name)

    return workspace:Raycast(
        originPoint,
        destinationPoint - originPoint,
        raycastParams
    )
end


-- Checks to see if Part 1 is facing Part 2
function RaycastService:IsFacing(part1 : BasePart, part2 : BasePart)
    if not part1 then
        warn("Part1 not provided")
        return false
    end

    if not part2 then
        warn("Part2 not provided")
        return false
    end

    local unitVector : number = (part2.Position - part1.Position).Unit
    local direction : number = part1.CFrame.LookVector

    local dotProduct : number = unitVector:Dot(direction)
    if dotProduct > 0.1 then
        return true
    end

	return false
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function RaycastService:KnitInit()

end

function RaycastService:KnitStart()

end


return RaycastService