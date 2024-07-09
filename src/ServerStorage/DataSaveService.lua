local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local TableUtil = require(ReplicatedStorage.Util:FindFirstChild("table-util", true))
local DataStoreService = game:GetService("DataStoreService")
local Modules = ReplicatedStorage.Source.Modules


-- Create the service:
local DataSaveService = Knit.CreateService {
    Name = "DataSaveService",
    Client = {
        DataUpdated = Knit.CreateSignal(),
    }
}

----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------

local DataVersion = DataStoreService:GetDataStore("V_1.0")

----------------------------------------------
-------------- Client Methods ----------------
----------------------------------------------


function DataSaveService.Client:GetData(player : Player?, dataName : string?)
    return self.Server:GetData(player, dataName)
end


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


function DataSaveService:GetData(player : Player?, dataName : string?)
    local entry : string? = self.PlayerStats[player.Name]
    if not entry then
        warn("No player of that name has data")
        return nil
    end

    local targetData : string? = entry[dataName]
    if not targetData then
        warn("No data of that name")
        return nil
    end

    return targetData
end


function DataSaveService:SetData(
    player : Player,
    dataName : string,
    newData : any
)

    local entry : string? = self.PlayerStats[player.Name]
    if not entry then
        warn("No player of that name has data")
        return nil
    end

    local targetData : string? = entry[dataName]
    if not targetData then
        warn("No data of that name: ", dataName)
        return nil
    end

    self.PlayerStats[player.Name][dataName] = newData

    -- Let the client know when the player's stats has been updated.
    self.Client.DataUpdated:Fire(
        player,
        self.PlayerStats[player.Name]
    )
end


function DataSaveService:ResetData(player : Player?)
    self.PlayerStats[player.Name] = TableUtil.Copy(self.Template, true)
end


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------



function DataSaveService:_onPlayerJoin(player)
	local pID = "Player_" .. player.UserId
	local data
	local success, err = pcall(function()
		data = DataVersion:GetAsync(pID)
	end)

	if not data then
        data = TableUtil.Copy(self.Template, true)
    end

    for key, value in pairs(self.Template) do
        if not data[key] then
            data[key] = value
        end
    end

    self.PlayerStats[player.Name] = data
end


function DataSaveService:_onPlayerLeave(player)
	local pID = "Player_" .. player.UserId
	local data = self.PlayerStats[player.Name]
	
	local success, err = pcall(function()
		data = DataVersion:SetAsync(pID, data)
	end)
		
	if success then
		print("Data saved: ", player.Name)
	end
end



----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function DataSaveService:KnitInit()

end

function DataSaveService:KnitStart()
    self.Template = {
        ["SavedMaxHealth"] = "10",
        ["SavedMaxStamina"] = "4",
        ["SavedMaxMana"] = "100",
        ["SavedMaxSpells"] = 4,
        ["Coins"] = 0,
        --["HasPlayedBefore"] = "No",
    }

    self.PlayerStats = {
    }

    game.Players.PlayerAdded:Connect(function(player)
        self:_onPlayerJoin(player)
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        self:_onPlayerLeave(player)
    end)
end


return DataSaveService