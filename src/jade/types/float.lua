local Column = require("jade.schema.column")

local Float = {}
Float.__index = Float

setmetatable(Float, {
    __index = Column,
    __call = function(_)
        return Column.new(nil, "float")
    end,
})

return Float
