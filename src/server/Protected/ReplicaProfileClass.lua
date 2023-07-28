local replica = {}
replica.__index = replica

function replica:IsActive()
    return self
end

return replica