local JadeError = require("jade.errors.base")

local IntrospectionError = setmetatable({}, { __index = JadeError })
IntrospectionError.__index = IntrospectionError

function IntrospectionError.new(code, message, details)
    local self = JadeError.new(code, message, details)
    setmetatable(self, IntrospectionError)
    return self
end

return IntrospectionError
