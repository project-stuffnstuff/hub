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
local function LoadProfileAsync(userId: number, useLive: boolean?)
    local player = Players:GetPlayerByUserId(userId)
    return Promise.new(function(resolve, reject)
        local store = if (not useLive) and RunService:IsStudio() then ProfileStore.Mock
                            else ProfileStore
        local profile = store:LoadProfileAsync(
            `Profile_{userId}`,
            "ForceLoad"
        )
        if profile ~= nil then
            profile:AddUserId(userId)
            profile:Reconcile()
            profile:ListenToRelease(function()
                if GameProfiles[userId] then
                    local prof = GameProfiles[userId]
                    if (prof.Replica) then
                        prof.Replica:Destroy()
                    end
                    GameProfiles[userId] = nil
                end
                if (player) then
                    player:Kick()
                end
            end)
            local player_profile = {
                Profile = profile;
                Replica = if player then ReplicaService.NewReplica({
                    ClassToken = ReplicaProfileToken;
                    Tags = {Player = player};
                    Data = profile.Data;
                    Replication = "All";
                }) else nil;
                _player = player or nil
            }
            setmetatable(player_profile, ReplicaProfile)
            GameProfiles[userId] = player_profile
            return resolve(player_profile)
        else
            return reject("Could not load profile")
        end
    end):catch(warn)
end

local function ReleaseProfileAsync(userId: number)
	return Promise.new(function(resolve, reject)
		local profile = GameProfiles[userId]
		if profile ~= nil then
			profile.Profile:Release()
            if (profile.Replica) then
                profile.Replica:Destroy()
            end
			return resolve()
		else
			return reject()
		end 
	end):catch(warn)
end

local function GetProfileAsync(userId: number)
    return Promise.new(function(resolve, reject)
        local profile = GameProfiles[userId]
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

function service:LoadProfile(userId: number, useLive: boolean?)
    local req, profile = Promise.retry(LoadProfileAsync, 3, userId, useLive):await()
    if (req) then
        service.ProfileLoaded:Fire(profile._player, profile)
        return profile
    else
        error(profile)
    end
end

function service:GetProfileAsync(userId: number)
    return GetProfileAsync(userId)
end

function service:GetProfile(userId: number)
    return GameProfiles[userId]
end

function service:ReleaseProfileAsync(userId: number)
    return ReleaseProfileAsync(userId)
end

function service:KnitStart()
    
end

return service