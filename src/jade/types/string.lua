local Column = require("jade.schema.column")

local String = {}
String.__index = String

setmetatable(String, {
    __index = Column,
    __call = function(_, length)
        return Column.new(nil, "string", length or 255)
    end,
})

return String
