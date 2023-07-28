local Replicated = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera

local Packages = Replicated:WaitForChild("Packages")
local Knit = require(Packages.Knit)
local WaitFor = require(Packages.WaitFor)
local Signal = require(Packages.Signal)

local controller = Knit.CreateController {
    Name = "CameraController";
}

function controller:Set(target: Vector3|CFrame, lookAt: Vector3?)
    Camera.CameraType = Enum.CameraType.Scriptable
    if (lookAt) and typeof(target) == "Vector3" then
        Camera.CFrame = CFrame.lookAt(target, lookAt)
    else
        Camera.CFrame = target
    end
end

function controller:SetPart(target: BasePart)
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = target.CFrame
end

return controller