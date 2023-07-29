local Replicated = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = Replicated:WaitForChild("Packages")
local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)

local service = Knit.CreateService {
    Name = "PlayerService";
    PlayerSpawned = Signal.new();
}

local DataService

function service:KnitStart()
    DataService = Knit.GetService("DataService")

    DataService.ProfileLoaded:Connect(function(player, profile)
        print(player, profile)
    end)

    Players.PlayerAdded:Connect(function(player)
        DataService:LoadProfile(player)
    end)
end

return service