local Driver = {}
Driver.__index = Driver

-- Abstract methods (must be implemented by drivers)
-- connect(config)
-- disconnect()
-- execute(sql, bindings)
-- generateSelect(query) -> sql, bindings
-- generateInsert(table_name, data, entity) -> sql, bindings
-- generateUpdate(table_name, data, where) -> sql, bindings
-- generateDelete(table_name, where) -> sql, bindings
-- mapType(column_type) -> db_type_string

function Driver.new()
    return setmetatable({}, Driver)
end

function Driver:connect(config)
    error("Driver:connect() not implemented")
end

function Driver:disconnect()
    error("Driver:disconnect() not implemented")
end

function Driver:execute(sql, bindings)
    error("Driver:execute() not implemented")
end

function Driver:generateSelect(query)
    error("Driver:generateSelect() not implemented")
end

function Driver:generateInsert(table_name, data, entity)
    error("Driver:generateInsert() not implemented")
end

function Driver:generateUpdate(table_name, data, where)
    error("Driver:generateUpdate() not implemented")
end

function Driver:generateDelete(table_name, where)
    error("Driver:generateDelete() not implemented")
end

function Driver:mapType(column_type)
    error("Driver:mapType() not implemented")
end

return Driver
