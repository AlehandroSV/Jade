local Column = require("jade.schema.column")

local Date = {}
Date.__index = Date

setmetatable(Date, {
    __index = Column,
    __call = function(_)
        return Column.new(nil, "date")
    end,
})

return Date
