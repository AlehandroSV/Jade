local M = {}

function M.setup(entity, options)
    options = options or {}
    local column = options.column or "deleted_at"

    -- Add deleted_at column to entity
    local Timestamp = require("jade.types.timestamp")
    entity._columns[column] = Timestamp():defaultNow()
    entity._columns[column]._name = column
    entity._columns[column]._table = entity._table

    -- Store soft delete config
    entity._soft_delete = {
        column = column,
    }

    -- Override delete to do soft delete
    local original_create = entity.create
    entity.create = function(self, data)
        data[column] = nil
        return original_create(self, data)
    end

    -- Add soft delete methods
    function entity:forceDelete(id)
        local Condition = require("jade.query.condition")
        local where = Condition.new("id", "=", id, self._table)
        local sql, bindings = self._driver:generateDelete(self._table, where)
        return self._driver:execute(sql, bindings)
    end

    function entity:withTrashed()
        return Query.new(self)
    end

    function entity:onlyTrashed()
        local Condition = require("jade.query.condition")
        local where = Condition.new(column, "IS NOT", nil, self._table)
        return Query.new(self):where(where)
    end

    function entity:restore(id)
        local data = {}
        data[column] = nil
        return self:update(id, data)
    end

    return entity
end

function M.isSoftDeleted(entity)
    return entity._soft_delete ~= nil
end

function M.getSoftDeleteColumn(entity)
    if entity._soft_delete then
        return entity._soft_delete.column
    end
    return nil
end

return M
