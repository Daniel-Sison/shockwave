local UtilityModule = {}



--[[
    Creates a "ghost" (no colllision/query) basepart.
    Does not set it's parent or position.
]]
function UtilityModule:CreatePart(): BasePart
    local part = Instance.new("Part")
    part.Size = Vector3.new(1,1,1)
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Anchored = true
    part.Transparency = 1
    part.Material = Enum.Material.Plastic
    
    return part
end



--[[
    @param part
    @param promptSettings {}?

    Returns the prompt
]]
function UtilityModule:CreatePrompt(
    part: BasePart | Attachment,
    promptSettings: {
        actionText: string?,
        objectText: string?,
        holdDuration: number?,
    }?
): ProximityPrompt

    local prompt = Instance.new("ProximityPrompt")
    if promptSettings then
        prompt.ActionText = promptSettings.actionText or "ActionText"
        prompt.ObjectText = promptSettings.objectText or "ObjectText"
        prompt.HoldDuration = promptSettings.holdDuration or 0.25
    end

    prompt.RequiresLineOfSight = false
    prompt.Parent = part

    return prompt
end




--[[
    @param originPart BasePart -- the core or origin part
    @param partToWeld BasePart -- the part being welded
    @param partSettings {}

    Welds a part to an origin part.
    Will set the "partToWeld" as massless on default.
]]
function UtilityModule:CreateWeld(
    originPart: BasePart,
    partToWeld: BasePart,
    partSettings: {
        anchored: boolean,
        canCollide: boolean,
        canTouch: boolean,
        canQuery: boolean
    }?
): WeldConstraint

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = originPart
    weld.Part1 = partToWeld
    weld.Parent = partToWeld

    partToWeld.Massless = true

    if not partSettings then
        partSettings = {}
    end

    partToWeld.Anchored = partSettings.anchored or false
    partToWeld.CanCollide = partSettings.canCollide or false
    partToWeld.CanTouch = partSettings.canTouch or false
    partToWeld.CanQuery = partSettings.canQuery or false

    return weld
end


return UtilityModule