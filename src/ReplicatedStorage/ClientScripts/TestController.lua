local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage.Source.Modules
local GeneralUI = require(Modules.General.GeneralUI)
local Fusion = require(ReplicatedStorage.Packages.Fusion)


-- Create the service:
local TestController = Knit.CreateController {
    Name = "TestController",
}

----------------------------------------------
------------- Static Variables ---------------
----------------------------------------------

local TestService

local Trove = require(ReplicatedStorage.Util:FindFirstChild(
    "trove",
    true
))


----------------------------------------------
-------------- Public Methods ----------------
----------------------------------------------


----------------------------------------------
-------------- Private Methods ---------------
----------------------------------------------


----------------------------------------------
-------------- Lifetime Methods --------------
----------------------------------------------

function TestController:KnitInit()
    TestService = Knit.GetService("TestService")
end

function TestController:KnitStart()
    -- Client talking to server
    TestService:GetSomethingFromClient():andThen(function(data)
        print("My data: ", data)
    end):catch(warn)

    -- From server to client
    TestService.TestDataChanged:Connect(function(points)
        print("Data has been updated!!:", points)
    end)
end


return TestController
