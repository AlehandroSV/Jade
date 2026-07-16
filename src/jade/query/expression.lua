local Expression = {}
Expression.__index = Expression

function Expression.new(column_name, table_name)
    return setmetatable({
        _column = column_name,
        _table = table_name,
    }, Expression)
end

function Expression:eq(value)
    local Condition = require("jade.query.condition")
    local val = type(value) == "table" and value._value or value
    return Condition.new(self._column, "=", val, self._table)
end

function Expression:lt(value)
    local Condition = require("jade.query.condition")
    local val = type(value) == "table" and value._value or value
    return Condition.new(self._column, "<", val, self._table)
end

function Expression:le(value)
    local Condition = require("jade.query.condition")
    local val = type(value) == "table" and value._value or value
    return Condition.new(self._column, "<=", val, self._table)
end

function Expression:gt(value)
    local Condition = require("jade.query.condition")
    local val = type(value) == "table" and value._value or value
    return Condition.new(self._column, ">", val, self._table)
end

function Expression:ge(value)
    local Condition = require("jade.query.condition")
    local val = type(value) == "table" and value._value or value
    return Condition.new(self._column, ">=", val, self._table)
end

function Expression:neq(value)
    local Condition = require("jade.query.condition")
    local val = type(value) == "table" and value._value or value
    return Condition.new(self._column, "!=", val, self._table)
end

function Expression:like(value)
    local Condition = require("jade.query.condition")
    return Condition.new(self._column, "LIKE", value, self._table)
end

function Expression:isIn(values)
    local Condition = require("jade.query.condition")
    return Condition.new(self._column, "IN", values, self._table)
end

function Expression:isNull()
    local Condition = require("jade.query.condition")
    return Condition.new(self._column, "IS", nil, self._table)
end

function Expression:isNotNull()
    local Condition = require("jade.query.condition")
    return Condition.new(self._column, "IS NOT", nil, self._table)
end

return Expression
