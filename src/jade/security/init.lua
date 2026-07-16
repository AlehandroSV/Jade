local M = {}

-- Sanitizer module
M.sanitizer = require("jade.security.sanitizer")

-- Validator module
M.validator = require("jade.security.validator")

-- Initialize security module
function M.init(options)
    options = options or {}

    -- Set limits
    if options.max_query_length then
        M.validator.MAX_QUERY_LENGTH = options.max_query_length
    end

    if options.max_parameters then
        M.validator.MAX_PARAMETERS = options.max_parameters
    end

    if options.max_string_length then
        M.validator.MAX_STRING_LENGTH = options.max_string_length
    end

    if options.max_in_items then
        M.validator.MAX_IN_ITEMS = options.max_in_items
    end
end

-- Validate input before query execution
function M.validateInput(data, schema)
    if not data or not schema then
        return true
    end

    for key, value in pairs(data) do
        -- Validate column name
        M.validator.validateColumnName(key)

        -- Find column definition
        local col_def = schema[key]
        if col_def then
            -- Validate type
            if not M.sanitizer.validateType(value, col_def.type) then
                error("Type mismatch for column '" .. key .. "': expected " .. col_def.type)
            end

            -- Validate string length
            if type(value) == "string" and col_def.length then
                M.validator.validateStringLength(value, col_def.length)
            end

            -- Check for SQL injection in string values
            if type(value) == "string" then
                local is_dangerous, reason = M.sanitizer.detectSQLInjection(value)
                if is_dangerous then
                    error("SQL injection detected in '" .. key .. "': " .. reason)
                end
            end
        end
    end

    return true
end

-- Safe query builder with security checks
function M.safeQuery(query)
    -- Validate query length
    M.validator.validateQueryLength(query)

    return query
end

-- Safe parameter binding
function M.safeBindings(bindings)
    -- Validate parameter count
    M.validator.validateParameterCount(bindings)

    return bindings
end

return M
