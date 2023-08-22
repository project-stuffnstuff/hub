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
    Name = "ReplicaController";
    DataChanged = Signal.new();
}

function controller:KnitStart()
    ReplicaService.RequestData()
    ReplicaService.ReplicaOfClassCreated("PlayerProfile", function(replica)
        replica:ListenToRaw(function(action_name, path_array, params)
            controller.DataChanged:Fire(action_name, table.concat(path_array, "."), params)
        end)
    end)
end

return controller