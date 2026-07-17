local LuaLS = {}

-- Map Jade types to LuaLS type annotations
local type_map = {
    string = "string",
    text = "string",
    integer = "number",
    bigint = "number",
    float = "number",
    decimal = "number",
    boolean = "boolean",
    timestamp = "string",
    date = "string",
    uuid = "string",
    json = "table",
}

--- Generate LuaLS type annotation for a column
---@param name string Column name
---@param col table Column definition
---@return string
function LuaLS.generateColumnType(name, col)
    local lua_type = type_map[col.type] or "any"
    return string.format("---@field %s %s", name, lua_type)
end

--- Generate LuaLS type annotation for an entity
---@param entity table Entity definition
---@return string
function LuaLS.generateEntityType(entity)
    local lines = {}

    -- Entity class type
    local entity_name = entity._table:gsub("^%l", string.upper) -- capitalize
    lines[#lines + 1] = string.format("---@class %s", entity_name)

    -- Column fields
    for name, col in pairs(entity._columns) do
        lines[#lines + 1] = LuaLS.generateColumnType(name, col)
    end

    -- Relation fields
    if entity._relations then
        for name, rel in pairs(entity._relations) do
            local target_entity = rel.target
            if target_entity then
                local target_name = target_entity._table:gsub("^%l", string.upper)
                if rel.type == "hasMany" or rel.type == "hasAndBelongsToMany" or rel.type == "hasManyThrough" then
                    lines[#lines + 1] = string.format("---@field %s %s[]", name, target_name)
                else
                    lines[#lines + 1] = string.format("---@field %s %s?", name, target_name)
                end
            end
        end
    end

    return table.concat(lines, "\n")
end

--- Generate LuaLS type annotation for a query result
---@param entity table Entity definition
---@return string
function LuaLS.generateQueryType(entity)
    local entity_name = entity._table:gsub("^%l", string.upper)
    return string.format("---@alias %sQuery Query<%s>", entity_name, entity_name)
end

--- Generate LuaLS type annotation for query builder methods
---@return string
function LuaLS.generateQueryMethods()
    return [[---@class Query<T>
---@field where fun(self: Query<T>, condition: Condition): Query<T>
---@field orderBy fun(self: Query<T>, column: string, direction?: string): Query<T>
---@field limit fun(self: Query<T>, n: number): Query<T>
---@field offset fun(self: Query<T>, n: number): Query<T>
---@field select fun(self: Query<T>, ...: string): Query<T>
---@field include fun(self: Query<T>, relation: string): Query<T>
---@field distinct fun(self: Query<T>): Query<T>
---@field join fun(self: Query<T>, table: string, on: Condition): Query<T>
---@field leftJoin fun(self: Query<T>, table: string, on: Condition): Query<T>
---@field groupBy fun(self: Query<T>, ...: string): Query<T>
---@field having fun(self: Query<T>, condition: Condition): Query<T>
---@field get fun(self: Query<T>): T[]
---@field first fun(self: Query<T>): T?
---@field find fun(self: Query<T>, id: number): T?
---@field count fun(self: Query<T>): number
---@field sum fun(self: Query<T>, column: string): number
---@field average fun(self: Query<T>, column: string): number
---@field min fun(self: Query<T>, column: string): number
---@field max fun(self: Query<T>, column: string): number
---@field paginate fun(self: Query<T>, options: table): PaginatedResult<T>]]
end

--- Generate LuaLS type annotation for Condition
---@return string
function LuaLS.generateConditionType()
    return [[---@class Condition
---@field eq fun(self: Expression, value: any): Condition
---@field neq fun(self: Expression, value: any): Condition
---@field lt fun(self: Expression, value: any): Condition
---@field le fun(self: Expression, value: any): Condition
---@field gt fun(self: Expression, value: any): Condition
---@field ge fun(self: Expression, value: any): Condition
---@field like fun(self: Expression, value: string): Condition
---@field isNull fun(self: Expression): Condition
---@field isNotNull fun(self: Expression): Condition
---@field band fun(self: Condition, other: Condition): Condition
---@field bor fun(self: Condition, other: Condition): Condition]]
end

--- Generate LuaLS type annotation for Expression
---@return string
function LuaLS.generateExpressionType()
    return [[---@class Expression
---@field eq fun(self: Expression, value: any): Condition
---@field neq fun(self: Expression, value: any): Condition
---@field lt fun(self: Expression, value: any): Condition
---@field le fun(self: Expression, value: any): Condition
---@field gt fun(self: Expression, value: any): Condition
---@field ge fun(self: Expression, value: any): Condition
---@field like fun(self: Expression, value: string): Condition
---@field isNull fun(self: Expression): Condition
---@field isNotNull fun(self: Expression): Condition]]
end

--- Generate LuaLS type annotation for Instance
---@param entity table Entity definition
---@return string
function LuaLS.generateInstanceType(entity)
    local entity_name = entity._table:gsub("^%l", string.upper)
    local lines = {}

    lines[#lines + 1] = string.format("---@class %sInstance", entity_name)

    -- Column fields
    for name, col in pairs(entity._columns) do
        local lua_type = type_map[col.type] or "any"
        if col._primary_key then
            lines[#lines + 1] = string.format("---@field %s %s", name, lua_type)
        else
            lines[#lines + 1] = string.format("---@field %s %s", name, lua_type)
        end
    end

    -- Methods
    lines[#lines + 1] = "---@field save fun(self: " .. entity_name .. "Instance): " .. entity_name .. "Instance"
    lines[#lines + 1] = "---@field destroy fun(self: " .. entity_name .. "Instance): " .. entity_name .. "Instance"
    lines[#lines + 1] = "---@field update fun(self: " .. entity_name .. "Instance, data: table): " .. entity_name .. "Instance"
    lines[#lines + 1] = "---@field toTable fun(self: " .. entity_name .. "Instance): table"

    return table.concat(lines, "\n")
end

--- Generate LuaLS type annotation for Entity static methods
---@param entity table Entity definition
---@return string
function LuaLS.generateEntityStaticType(entity)
    local entity_name = entity._table:gsub("^%l", string.upper)
    local instance_name = entity_name .. "Instance"

    local lines = {}
    lines[#lines + 1] = string.format("---@alias %sStatic", entity_name)
    lines[#lines + 1] = string.format("---| {")
    lines[#lines + 1] = string.format("---| create: fun(data: table): %s", instance_name)
    lines[#lines + 1] = string.format("---| update: fun(id: number, data: table): %s", instance_name)
    lines[#lines + 1] = string.format("---| delete: fun(id: number): %s", instance_name)
    lines[#lines + 1] = string.format("---| where: fun(condition: Condition): Query<%s>", instance_name)
    lines[#lines + 1] = string.format("---| orderBy: fun(column: string, direction?: string): Query<%s>", instance_name)
    lines[#lines + 1] = string.format("---| limit: fun(n: number): Query<%s>", instance_name)
    lines[#lines + 1] = string.format("---| offset: fun(n: number): Query<%s>", instance_name)
    lines[#lines + 1] = string.format("---| select: fun(...: string): Query<%s>", instance_name)
    lines[#lines + 1] = string.format("---| include: fun(relation: string): Query<%s>", instance_name)
    lines[#lines + 1] = string.format("---| get: fun(): %s[]", instance_name)
    lines[#lines + 1] = string.format("---| first: fun(): %s?", instance_name)
    lines[#lines + 1] = string.format("---| find: fun(id: number): %s?", instance_name)
    lines[#lines + 1] = string.format("---| count: fun(): number")
    lines[#lines + 1] = string.format("---| sum: fun(column: string): number")
    lines[#lines + 1] = string.format("---| average: fun(column: string): number")
    lines[#lines + 1] = string.format("---| min: fun(column: string): number")
    lines[#lines + 1] = string.format("---| max: fun(column: string): number")
    lines[#lines + 1] = string.format("---| paginate: fun(options: table): PaginatedResult<%s>", instance_name)
    lines[#lines + 1] = string.format("}")

    return table.concat(lines, "\n")
end

--- Generate complete LuaLS type definitions for all entities
---@param entities table Array of entity definitions
---@return string
function LuaLS.generateAll(entities)
    local lines = {}

    -- Header
    lines[#lines + 1] = "---@meta"
    lines[#lines + 1] = "--- Auto-generated LuaLS type definitions for Jade ORM"
    lines[#lines + 1] = "--- Do not edit manually"
    lines[#lines + 1] = ""

    -- Base types
    lines[#lines + 1] = LuaLS.generateQueryMethods()
    lines[#lines + 1] = ""
    lines[#lines + 1] = LuaLS.generateConditionType()
    lines[#lines + 1] = ""
    lines[#lines + 1] = LuaLS.generateExpressionType()
    lines[#lines + 1] = ""

    -- Entity types
    for _, entity in ipairs(entities) do
        local entity_name = entity._table:gsub("^%l", string.upper)

        -- Entity class
        lines[#lines + 1] = LuaLS.generateEntityType(entity)
        lines[#lines + 1] = ""

        -- Instance type
        lines[#lines + 1] = LuaLS.generateInstanceType(entity)
        lines[#lines + 1] = ""

        -- Query type
        lines[#lines + 1] = LuaLS.generateQueryType(entity)
        lines[#lines + 1] = ""

        -- Static methods type
        lines[#lines + 1] = LuaLS.generateEntityStaticType(entity)
        lines[#lines + 1] = ""
    end

    return table.concat(lines, "\n")
end

return LuaLS
