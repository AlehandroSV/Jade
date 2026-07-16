local Column = require("jade.schema.column")

local Decimal = {}
Decimal.__index = Decimal

setmetatable(Decimal, {
    __index = Column,
    __call = function(_, precision, scale)
        local col = Column.new(nil, "decimal")
        col.precision = precision or 10
        col.scale = scale or 2
        return col
    end,
})

return Decimal
