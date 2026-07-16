require("jade.util.compat")

local Jade = {
    _VERSION = require("jade._VERSION"),
}

-- i18n
Jade.i18n = require("jade.i18n")

-- Types
Jade.String = require("jade.types.string")
Jade.Integer = require("jade.types.integer")
Jade.Boolean = require("jade.types.boolean")
Jade.Text = require("jade.types.text")
Jade.Timestamp = require("jade.types.timestamp")
Jade.Float = require("jade.types.float")
Jade.Decimal = require("jade.types.decimal")
Jade.UUID = require("jade.types.uuid")
Jade.Date = require("jade.types.date")

-- Entity
Jade.Entity = require("jade.entity")

-- Relations
Jade.Relations = require("jade.entity.relations")

-- Migration
Jade.migration = require("jade.migration")

-- Transaction
Jade.transaction = require("jade.transaction.manager")

-- Soft Delete
Jade.SoftDelete = require("jade.entity.soft_delete")

-- Security
Jade.security = require("jade.security")

-- Driver registry
Jade.drivers = require("jade.driver")

-- Config
Jade.config = require("jade.config")

-- Utility
Jade.log = require("jade.util.log")
Jade.inflection = require("jade.util.inflection")

-- Current driver instance
local current_driver = nil

function Jade.configure(opts)
    -- Set locale if provided
    if opts.locale then
        Jade.i18n.setLocale(opts.locale)
    end

    if opts.database then
        Jade.config.set(opts)
    end

    local db = opts.database or opts
    local driver_name = db.driver or "postgresql"

    local DriverClass = Jade.drivers.get(driver_name)
    current_driver = DriverClass.new()
    current_driver:connect(db)

    return current_driver
end

function Jade.driver()
    if not current_driver then
        error(Jade.i18n.t("not_configured"))
    end
    return current_driver
end

function Jade.disconnect()
    if current_driver then
        current_driver:disconnect()
        current_driver = nil
    end
end

function Jade.raw(sql, ...)
    return { _raw = sql, _bindings = { ... } }
end

-- Shorthand Entity constructor that auto-configures the driver
local original_entity = Jade.Entity
Jade.Entity = function(table_name, columns)
    local entity = original_entity.new(table_name, columns)
    if current_driver then
        entity:configure(current_driver)
    end
    return entity
end

return Jade
