local Column = require("jade.schema.column")

local Text = {}
Text.__index = Text

setmetatable(Text, {
    __index = Column,
    __call = function(_)
        return Column.new(nil, "text")
    end,
})

return Text
