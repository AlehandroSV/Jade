local Proxy = {}
Proxy.__index = function(self, key)
    local data = rawget(self, "_data")
    if data and data[key] ~= nil then
        return data[key]
    end

    local method = rawget(Proxy, key)
    if method then
        return method
    end

    return nil
end

function Proxy.new(relation, owner)
    return setmetatable({
        _relation = relation,
        _owner = owner,
        _data = nil,
        _loaded = false,
    }, Proxy)
end

function Proxy:load()
    if self._loaded then
        return self._data
    end

    local relation = self._relation
    local target = relation.target
    local driver = target._driver

    if not driver then
        error("Cannot load relation: no driver configured")
    end

    local value
    if relation.type == "belongsTo" then
        -- owner has foreign_key, load target by that key
        local foreign_key_value = self._owner[relation.foreign_key]
        if foreign_key_value then
            value = target:find(foreign_key_value)
        end
    elseif relation.type == "hasOne" then
        -- target has foreign_key pointing to owner
        local Condition = require("jade.query.condition")
        local where = Condition.new(relation.foreign_key, "=", self._owner.id, target._table)
        local results = target:where(where):limit(1):get()
        value = results[1]
    elseif relation.type == "hasMany" then
        local Condition = require("jade.query.condition")
        local where = Condition.new(relation.foreign_key, "=", self._owner.id, target._table)
        value = target:where(where):get()
    elseif relation.type == "foreign_key" then
        -- owner has foreign_key, load target
        local foreign_key_value = self._owner[relation.foreign_key]
        if foreign_key_value then
            value = target:find(foreign_key_value)
        end
    end

    self._data = value
    self._loaded = true
    return value
end

function Proxy:isLoaded()
    return self._loaded
end

function Proxy:getData()
    if not self._loaded then
        self:load()
    end
    return self._data
end

return Proxy
