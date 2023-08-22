local Players = game:GetService("Players")

local utils = {}

function utils:CreatePrompt()
    
end

function utils:PlayerLookup(id: Player|string|number)
    if typeof(id) == "Instance" then
        if id:IsA("Player") then
            return id
        end
    elseif typeof(id) == "string" then
        for _,p in Players:GetPlayers() do
            if p.Name == id then
                return id
            end
        end
    end
end

return utils