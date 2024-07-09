local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules

-- Create the service:
local NotificationService = Knit.CreateService {
    Name = "NotificationService",
    Client = {
        NotifyClient = Knit.CreateSignal(),
        Announce = Knit.CreateSignal(),
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


function NotificationService:Notify(playerOrPlayers : any?, text : string?)
    if not playerOrPlayers then
        return
    end

    if not text then
        return
    end

    if typeof(playerOrPlayers) == "Instance" and playerOrPlayers:IsA("Player") then
        self.Client.NotifyClient:Fire(playerOrPlayers, text)
        return
    end

    if typeof(playerOrPlayers) == "table" then
        for index, player in ipairs(playerOrPlayers) do
            self.Client.NotifyClient:Fire(player, text)
        end
    end
end


function NotificationService:Announce(
    players : {Player?},
    titleText : string,
    descText : string,
    soundToPlay : string
)

    for _, player in ipairs(players) do
        self.Client.Announce:Fire(
            player,
            titleText,
            descText,
            soundToPlay
        )
    end
end

----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function NotificationService:KnitInit()

end

function NotificationService:KnitStart()
    
end


return NotificationService