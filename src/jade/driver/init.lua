local drivers = {}

local function register(name, module)
    drivers[name] = module
end

local function get(name)
    local driver = drivers[name]
    if not driver then
        error("Unknown driver: " .. tostring(name))
    end
    return driver
end

register("postgresql", require("jade.driver.postgresql"))
register("mysql", require("jade.driver.mysql"))

return {
    register = register,
    get = get,
}
