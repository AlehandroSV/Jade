local M = {}

function M.snake_to_camel(str)
    return str:gsub("_(%w)", function(c)
        return c:upper()
    end)
end

function M.camel_to_snake(str)
    return str:gsub("(%u)", function(c)
        return "_" .. c:lower()
    end):gsub("^_", "")
end

function M.pluralize(str)
    if str:match("s$") then
        return str .. "es"
    end
    return str .. "s"
end

function M.singularize(str)
    if str:match("es$") then
        return str:sub(1, -3)
    end
    if str:match("s$") then
        return str:sub(1, -2)
    end
    return str
end

return M
