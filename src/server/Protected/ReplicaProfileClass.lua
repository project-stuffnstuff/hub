local Replicated = game:GetService("ReplicatedStorage")
local Shared = Replicated:WaitForChild("Shared")
local Logger = require(Shared.Log)

local replica = {}
replica.__index = replica

local _CONFIG = {
    MaxCurrency = 99999999999999
}

function replica:GetRealData()
    return self.Profile.Data
end

function replica:GetData()
    return self.Replica.Data
end

function replica:IsActive()
    return self.Profile ~= nil
end

function replica:GetCurrency(key: string?)
    local data = self.Replica.Data
    local currency = data.Currency
    if (not key) then
        return currency
    end
    if not currency[key] then
        return nil
    else
        return currency[key]
    end
end

function replica:SetCurrency(key: string, value: number)
    local data = self:GetCurrency(key)
    if data >= _CONFIG.MaxCurrency then
        Logger:Snitch(self)
        return false
    end
    self.Replica:SetValue({"Currency", key}, math.round(math.clamp(value, 0, _CONFIG.MaxCurrency)))
    return true
end

function replica:IncreaseCurrency(key: string, dt: number)
    local data = self:GetCurrency(key)
    if data then
        self:SetCurrency(key, data * dt)
        return true
    end
    return false
end

return replica