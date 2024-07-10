local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UtilityModule = {}
local Trove = require(ReplicatedStorage.Util:FindFirstChild(
    "trove",
    true
))


--[[
    @param uniqueKey string | Instance
    @param debounceDelay (how long before debounce blocker is disabled or reset)
]]
function UtilityModule:CreateDebounce(
    uniqueKey: string | Instance,
    debounceDelay: number?,
    callback: any
)
    if not self.DebounceList then
        self.DebounceList = {}
    end

    if self.DebounceList[uniqueKey] then
        return
    end

    self.DebounceList[uniqueKey] = true
    task.delay(debounceDelay or 1, function()
        self.DebounceList[uniqueKey] = nil
    end)

    callback()
end


return UtilityModule