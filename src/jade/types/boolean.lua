local Column = require("jade.schema.column")

local Boolean = {}
Boolean.__index = Boolean

setmetatable(Boolean, {
    __index = Column,
    __call = function(_)
        return Column.new(nil, "boolean")
    end,
})

return Boolean
