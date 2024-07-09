local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules
local GeneralUI = require(ReplicatedStorage.Source.Modules.General.GeneralUI)

local AtmosphereService = Knit.CreateService {
    Name = "AtmosphereService",
}


----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------


local Lighting = game:GetService("Lighting")
local Clouds

----------------------------------------------
-------------- Client Methods ----------------
----------------------------------------------




----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------



function AtmosphereService:SetBrightNight()
    GeneralUI:SimpleTween(
        Lighting,
        {ClockTime = 20.1},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        workspace.Terrain,
        {WaterColor = Color3.fromRGB(17, 102, 176)},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        Clouds,
        {Cover = 0.818, Density = 0.364},
        self.TransitionTime
    )

    return self:_replaceCurrentAtmosphere("FoggyMorning")
end



function AtmosphereService:SetDarkNight()
    GeneralUI:SimpleTween(
        Lighting,
        {ClockTime = 23.1},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        workspace.Terrain,
        {WaterColor = Color3.fromRGB(17, 102, 176)},
        self.TransitionTime
    )

    return self:_replaceCurrentAtmosphere("DarkNight")
end


function AtmosphereService:SetClearDay()
    GeneralUI:SimpleTween(
        Lighting,
        {ClockTime = 14.5},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        workspace.Terrain,
        {WaterColor = Color3.fromRGB(17, 102, 176)},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        Clouds,
        {Cover = 0.709, Density = 0.127},
        self.TransitionTime
    )

    return self:_replaceCurrentAtmosphere("RegularDay")
end



function AtmosphereService:SetCloudyDay()
    GeneralUI:SimpleTween(
        Lighting,
        {ClockTime = 14.5},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        workspace.Terrain,
        {WaterColor = Color3.fromRGB(17, 102, 176)},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        Clouds,
        {Cover = 0.818, Density = 0.364},
        self.TransitionTime
    )

    return self:_replaceCurrentAtmosphere("CloudyDay")
end



function AtmosphereService:SetDusk()
    GeneralUI:SimpleTween(
        Lighting,
        {ClockTime = 17.58},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        workspace.Terrain,
        {WaterColor = Color3.fromRGB(150, 131, 55)},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        Clouds,
        {Cover = 0.709, Density = 0.127},
        self.TransitionTime
    )

    return self:_replaceCurrentAtmosphere("Sunset")
end



function AtmosphereService:SetDawn()
    GeneralUI:SimpleTween(
        Lighting,
        {ClockTime = 7.4},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        workspace.Terrain,
        {WaterColor = Color3.fromRGB(41, 124, 150)},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        Clouds,
        {Cover = 0.709, Density = 0.127},
        self.TransitionTime
    )

    return self:_replaceCurrentAtmosphere("Sunset")
end


function AtmosphereService:SetDefault()
    GeneralUI:SimpleTween(
        Lighting,
        {ClockTime = 17.5},
        self.TransitionTime
    )

    GeneralUI:SimpleTween(
        Clouds,
        {Cover = 0, Density = 0},
        self.TransitionTime
    )

    return self:_replaceCurrentAtmosphere("Default")
end



----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------

function AtmosphereService:_replaceCurrentAtmosphere(targetAtmosphereName: string)
    
    local atmospheres = ReplicatedStorage.Assets.Atmospheres
    
    local newAtmos = atmospheres:FindFirstChild(targetAtmosphereName)
    if not newAtmos then
        return
    end

    local currentAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if not currentAtmosphere then
        return
    end

    local tween = GeneralUI:SimpleTween(
        currentAtmosphere,
        {
            Density = newAtmos.Density,
            Offset = newAtmos.Offset,
            Color = newAtmos.Color,
            Decay = newAtmos.Decay,
            Glare = newAtmos.Glare,
            Haze = newAtmos.Haze,
        },
        self.TransitionTime
    )

    return tween
end


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function AtmosphereService:KnitInit()

end

function AtmosphereService:KnitStart()
    self.TransitionTime = 10
    self.MinuteLength = 60

    Clouds = Instance.new("Clouds")
    Clouds.Parent = workspace.Terrain

    --self:SetDefault()
end


return AtmosphereService
