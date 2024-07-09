local module = {}


function module:NoWallBetween(originPoint : Vector3?, destinationPoint : Vector3?, ignoreList : Table?, filterType)
	local raycastResult

    local raycastParams = RaycastParams.new()
    if not filterType then
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    else
        raycastParams.FilterType = filterType
    end
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.IgnoreWater = true

    raycastResult = workspace:Raycast(originPoint, destinationPoint - originPoint, raycastParams)

    if raycastResult then
        --	print("Object/terrain hit:", raycastResult.Instance:GetFullName())
        --	print("Hit position:", raycastResult.Position)
        --	print("Name of Parent:", raycastResult.Instance.Parent.Name)
        --	print("Material hit:", raycastResult.Material.Name)
        return false, raycastResult
    else
        --	print("Nothing was hit!")
        return true, nil
    end

	
	return false, nil
end


function module:IsFacing(model1, model2)
	-- checks for if model 1 is facing model 2
	local h1 = model1:FindFirstChild("Head")
	local h2 = model2:FindFirstChild("Head")
	if h1 and h2 then
		local unitVector = (h2.Position - h1.Position).Unit
		local dir = h1.CFrame.LookVector

		local dotProduct = unitVector:Dot(dir)
		if dotProduct > 0.1 then
			return true
		end
	end

	return false
end



return module
