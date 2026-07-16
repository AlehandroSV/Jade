local Column = require("jade.schema.column")

local Integer = {}
Integer.__index = Integer

setmetatable(Integer, {
    __index = Column,
    __call = function(_)
        return Column.new(nil, "integer")
    end,
})

return Integer
