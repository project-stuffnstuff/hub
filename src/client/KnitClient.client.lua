local Replicated = game:GetService("ReplicatedStorage")

local Packages = Replicated:WaitForChild("Packages")
local Knit = require(Packages.Knit)

local PlayerScripts = script.Parent
local Framework = PlayerScripts:WaitForChild("Framework")
local Components = Framework:WaitForChild("Components")
local Controllers = Framework:WaitForChild("Controllers")

for _, m in ipairs(Controllers:GetDescendants()) do
    if m:IsA("ModuleScript") and not m:GetAttribute("KnitIgnore") then
        require(m)
    end
end
Knit.Start():andThen(function()
    for _, m in ipairs(Components:GetDescendants()) do
        if m:IsA("ModuleScript") and not m:GetAttribute("KnitIgnore") then
            require(m)
        end
    end
end)