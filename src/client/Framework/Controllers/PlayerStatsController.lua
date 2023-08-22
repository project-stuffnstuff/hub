local Replicated = game:GetService("ReplicatedStorage")

local Shared = Replicated:WaitForChild("Shared")
local luatable = require(Shared.LuaTable)

local Packages = Replicated:WaitForChild("Packages")
local Knit = require(Packages.Knit)
local WaitFor = require(Packages.WaitFor)
local Signal = require(Packages.Signal)
local TableUtil = require(Packages.TableUtil)
local ReplicaService = require(Packages.ReplicaService)

local controller = Knit.CreateController {
    Name = "PlayerStatsController";
}

local ReplicaController

function controller:KnitStart()
    ReplicaController = Knit.GetController("ReplicaController")

    --[[
        action is one of;
        - SetValue, SetValues
        - ArrayInsert, ArraySet, ArrayRemove
    ]]
    ReplicaController.DataChanged:Connect(function(action: string, path: string, newValue: any)
        print(action, path, newValue)
    end)
end

return controller