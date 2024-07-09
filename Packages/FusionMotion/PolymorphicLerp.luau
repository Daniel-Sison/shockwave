--!strict

export type LerpFunction = (a: any, b: any, alpha: number) -> any

local function mathExpresionLerp(start: any, finish: any, alpha: number): any
    return start + (finish - start) * alpha
end
local function classMethodLerp(start: any, finish: any, alpha: number): any
    return start:Lerp(finish, alpha)
end
local typeToInterpolator: {[string]: LerpFunction} = {
    number = mathExpresionLerp,
    Vector2 = mathExpresionLerp,
    Vector2int16 = mathExpresionLerp,
    Vector3 = mathExpresionLerp,
    Vector3int16 = mathExpresionLerp,
    CFrame = classMethodLerp,
    Color3 = classMethodLerp,
    UDim = function(a: UDim, b: UDim, alpha)
        return UDim.new(
            mathExpresionLerp(a.Scale, b.Scale, alpha),
            mathExpresionLerp(a.Offset, b.Offset, alpha)
        )
    end,
    UDim2 = function(a: UDim2, b: UDim2, alpha)
        return UDim2.new(
            mathExpresionLerp(a.X.Scale, b.X.Scale, alpha),
            mathExpresionLerp(a.X.Offset, b.X.Offset, alpha),
            mathExpresionLerp(a.Y.Scale, b.Y.Scale, alpha),
            mathExpresionLerp(a.Y.Offset, b.Y.Offset, alpha)
        )
    end,
    -- Follows the conventions of TweenService. This is useful for tweening:
    -- { Visible = false }
    boolean = function(a: boolean, b: boolean, alpha)
        if a ~= b then
            return alpha < 1
        end
        return a
    end,
    Rect = function(a: Rect, b: Rect, alpha)
        return Rect.new(
            mathExpresionLerp(a.Min.X, b.Min.X, alpha),
            mathExpresionLerp(a.Min.Y, b.Min.Y, alpha),
            mathExpresionLerp(a.Max.X, b.Max.X, alpha),
            mathExpresionLerp(a.Max.Y, b.Max.Y, alpha)
        )
    end,
}

--[[
    @param datatype: string - The typeof name of the data type to interpolate.
    @returns LerpFunction - The function that can interpolate the data type.

    Returns an interpolation function for the given data type. Largely Based off
    of util code from the Dec library, which is licensed as public domain.
]]
local function PolymorphicLerp(datatype: string): LerpFunction
    local lerp = typeToInterpolator[datatype]
    if not lerp then
        error("Data type '" .. datatype .. "' cannot be interpolated!")
    end
    return lerp
end

return PolymorphicLerp
