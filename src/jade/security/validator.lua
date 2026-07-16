local M = {}

-- Maximum query length (prevent memory exhaustion)
M.MAX_QUERY_LENGTH = 100000

-- Maximum parameter count
M.MAX_PARAMETERS = 1000

-- Maximum string length
M.MAX_STRING_LENGTH = 65536

-- Maximum IN clause items
M.MAX_IN_ITEMS = 1000

-- Validate query length
function M.validateQueryLength(sql)
    if #sql > M.MAX_QUERY_LENGTH then
        error("Query exceeds maximum length: " .. #sql .. " > " .. M.MAX_QUERY_LENGTH)
    end
    return true
end

-- Validate parameter count
function M.validateParameterCount(bindings)
    if bindings and #bindings > M.MAX_PARAMETERS then
        error("Too many parameters: " .. #bindings .. " > " .. M.MAX_PARAMETERS)
    end
    return true
end

-- Validate string length
function M.validateStringLength(value, max_length)
    max_length = max_length or M.MAX_STRING_LENGTH
    if type(value) == "string" and #value > max_length then
        error("String exceeds maximum length: " .. #value .. " > " .. max_length)
    end
    return true
end

-- Validate IN clause
function M.validateInClause(values)
    if type(values) ~= "table" then
        error("IN clause requires a table")
    end
    if #values > M.MAX_IN_ITEMS then
        error("IN clause has too many items: " .. #values .. " > " .. M.MAX_IN_ITEMS)
    end
    return true
end

-- Validate column name (prevent injection through identifiers)
function M.validateColumnName(name)
    if type(name) ~= "string" then
        error("Column name must be a string")
    end

    -- Allow only alphanumeric and underscore
    if not name:match("^[%a_][%w_]*$") then
        error("Invalid column name: " .. name)
    end

    -- Check length
    if #name > 64 then
        error("Column name too long: " .. #name)
    end

    return true
end

-- Validate table name
function M.validateTableName(name)
    if type(name) ~= "string" then
        error("Table name must be a string")
    end

    -- Allow only alphanumeric and underscore
    if not name:match("^[%a_][%w_]*$") then
        error("Invalid table name: " .. name)
    end

    -- Check length
    if #name > 64 then
        error("Table name too long: " .. #name)
    end

    return true
end

-- Validate order direction
function M.validateOrderDirection(direction)
    local valid = { ASC = true, DESC = true, asc = true, desc = true }
    if not valid[direction] then
        error("Invalid order direction: " .. tostring(direction))
    end
    return true
end

-- Validate pagination parameters
function M.validatePagination(page, per_page)
    if page and (type(page) ~= "number" or page < 1) then
        error("Invalid page number: " .. tostring(page))
    end
    if per_page and (type(per_page) ~= "number" or per_page < 1 or per_page > 1000) then
        error("Invalid per_page value: " .. tostring(per_page))
    end
    return true
end

return M
