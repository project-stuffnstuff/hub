local RunService = game:GetService("RunService")

local logger = {}

function logger:Log(...)
    if RunService:IsClient() then
        print("[CLIENT]", ...)
    else
        print("[SERVER]", ...)
    end
end

function logger:Snitch(data: any)
    print(data)
end

return logger