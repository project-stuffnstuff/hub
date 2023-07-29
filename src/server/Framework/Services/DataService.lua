local Replicated = game:GetService("ReplicatedStorage")
local Scripts = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Shared = Replicated:WaitForChild("Shared")
local ProfileTemplate = require(Shared.ProfileTemplate)

local Packages = Replicated:WaitForChild("Packages")
local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)
local Promise = require(Packages.Promise)
local ProfileService = require(Packages.ProfileService)

local Protected = Scripts:WaitForChild("Protected")
local ReplicaService = require(Protected.ReplicaService)
local ReplicaProfile = require(Protected.ReplicaProfileClass)

local ReplicaProfileToken = ReplicaService.NewClassToken("PlayerProfile")

local ProfileStore = ProfileService.GetProfileStore(
    "PlayerData",
    ProfileTemplate
)

local GameProfiles = {}

-- < Profile Functions >
local function LoadProfileAsync(player: Player)
    return Promise.new(function(resolve, reject)
        local store = if RunService:IsStudio() then ProfileStore.Mock
                            else ProfileStore
        local profile = store:LoadProfileAsync(
            `Profile_{player.UserId}`,
            "ForceLoad"
        )
        if profile ~= nil then
            profile:AddUserId(player.UserId)
            profile:Reconcile()
            profile:ListenToRelease(function()
                GameProfiles[player].Replica:Destroy()
                GameProfiles[player] = nil
                player:Kick()
            end)
            if player:IsA("Player") then
                local player_profile = {
                    Profile = profile;
                    Replica = ReplicaService.NewReplica({
                        ClassToken = ReplicaProfileToken;
                        Tags = {Player = player};
                        Data = profile.Data;
                        Replication = "All";
                    });
                    _player = player;
                }
                setmetatable(player_profile, ReplicaProfile)
                GameProfiles[player] = player_profile
                return resolve(player_profile)
            else
                profile:Release()
            end
        else
            return reject("Could not load profile")
        end
    end):catch(warn)
end

local function ReleaseProfileAsync(player: Player)
	return Promise.new(function(resolve, reject)
		local profile = GameProfiles[player]
		if profile ~= nil then
			profile.Profile:Release()
			return resolve()
		else
			return reject()
		end 
	end)
end

local function GetProfileAsync(player: Player)
    return Promise.new(function(resolve, reject)
        local profile = GameProfiles[player]
        if profile ~= nil then
            return resolve(profile)
        end
        return reject("Unable to fetch profile")
    end):catch(warn)
end

local service = Knit.CreateService {
    Name = "DataService";
    ProfileLoaded = Signal.new();
}

function service:LoadProfile(player: Player)
    local req, profile = Promise.retry(LoadProfileAsync, 3, player):await()
    if (req) then
        service.ProfileLoaded:Fire(player, profile)
        return profile
    else
        error(profile)
    end
end

function service:GetProfileAsync(player: Player)
    return GetProfileAsync(player)
end

function service:GetProfile(player: Player)
    return GameProfiles[player]
end

function service:ReleaseProfileAsync(player: Player)
    return ReleaseProfileAsync(player)
end

function service:KnitStart()
    
end

return service