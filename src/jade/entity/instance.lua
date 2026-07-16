local Instance = {}
Instance.__index = function(self, key)
    local method = rawget(Instance, key)
    if method then
        return method
    end

    -- Access data fields
    if self._data and self._data[key] ~= nil then
        return self._data[key]
    end

    return nil
end

function Instance.new(entity, data)
    return setmetatable({
        _entity = entity,
        _data = data or {},
    }, Instance)
end

function Instance:update(data)
    local id = self._data.id
    if not id then
        error("Cannot update instance without id")
    end
    self._entity:update(id, data)
    for k, v in pairs(data) do
        self._data[k] = v
    end
    return self
end

function Instance:delete()
    local id = self._data.id
    if not id then
        error("Cannot delete instance without id")
    end
    return self._entity:delete(id)
end

function Instance:save()
    if self._data.id then
        return self:update(self._data)
    else
        local result = self._entity:create(self._data)
        self._data = result._data
        return self
    end
end

function Instance:refresh()
    local id = self._data.id
    if not id then
        error("Cannot refresh instance without id")
    end
    local fresh = self._entity:find(id)
    if fresh then
        self._data = fresh._data
    end
    return self
end

function Instance:toTable()
    local copy = {}
    for k, v in pairs(self._data) do
        copy[k] = v
    end
    return copy
end

return Instance
