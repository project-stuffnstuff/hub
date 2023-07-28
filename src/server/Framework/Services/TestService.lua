local Replicated = game:GetService("ReplicatedStorage")

local Packages = Replicated:WaitForChild("Packages")
local Knit = require(Packages.Knit)

local service = Knit.CreateService {
    Name = "TestService";
}

function service:KnitStart()
    
end

return service