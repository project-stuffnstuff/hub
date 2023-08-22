local Replicated = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Packages = Replicated:WaitForChild("Packages")
local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)

local SaveProfile = true

local service = Knit.CreateService {
    Name = "PlayerService";
    PlayerSpawned = Signal.new();
}

local DataService

function service.Client:ProcessInteraction(client: Player, data: {})
    print(client, data)
end

function service:KnitStart()
    DataService = Knit.GetService("DataService")

    DataService.ProfileLoaded:Connect(function(player, profile)
        
    end)

    Players.PlayerAdded:Connect(function(player)
        DataService:LoadProfile(player.UserId, SaveProfile)
    end)

    Players.PlayerRemoving:Connect(function(player)
        DataService:ReleaseProfileAsync(player.UserId)
    end)
end

return service