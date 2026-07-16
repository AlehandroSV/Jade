local Column = require("jade.schema.column")

local UUID = {}
UUID.__index = UUID

setmetatable(UUID, {
    __index = Column,
    __call = function(_)
        return Column.new(nil, "uuid")
    end,
})

return UUID
