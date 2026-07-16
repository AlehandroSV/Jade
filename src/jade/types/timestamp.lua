local Column = require("jade.schema.column")

local Timestamp = {}
Timestamp.__index = Timestamp

setmetatable(Timestamp, {
    __index = Column,
    __call = function(_)
        return Column.new(nil, "timestamp")
    end,
})

return Timestamp
