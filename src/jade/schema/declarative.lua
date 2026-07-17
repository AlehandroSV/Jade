local Inflection = require("jade.util.inflection")
local Schema = require("jade.schema")
local Entity = require("jade.entity")

local Declarative = {}

-- Convention configuration
Declarative.conventions = {
    -- Table name: pluralize model name
    tableName = function(model_name)
        return Inflection.pluralize(model_name:lower())
    end,

    -- Primary key: id field with auto increment
    primaryKey = function()
        return { type = "integer", primary_key = true, auto_increment = true }
    end,

    -- Timestamps: created_at and updated_at
    timestamps = function()
        return {
            created_at = { type = "timestamp", default_now = true },
            updated_at = { type = "timestamp", default_now = true },
        }
    end,

    -- Foreign key: model_name_id
    foreignKey = function(model_name)
        return model_name:lower() .. "_id"
    end,

    -- Validations from constraints
    validations = function(constraints)
        local validations = {}
        if constraints.notNull then
            validations.presence = true
        end
        if constraints.unique then
            validations.uniqueness = true
        end
        return validations
    end,
}

-- Type mapping from simple names to column definitions
Declarative.typeMap = {
    string = { type = "string", length = 255 },
    text = { type = "text" },
    integer = { type = "integer" },
    bigint = { type = "bigint" },
    float = { type = "float" },
    decimal = { type = "decimal", precision = 10, scale = 2 },
    boolean = { type = "boolean" },
    timestamp = { type = "timestamp" },
    date = { type = "date" },
    uuid = { type = "uuid" },
    json = { type = "json" },
}

-- Parse a simple type string into a column definition
function Declarative.parseType(type_str)
    -- Check if it's a simple type name
    if Declarative.typeMap[type_str] then
        return Declarative.typeMap[type_str]
    end

    -- Check if it's a type with length: string(120)
    local type_name, length = type_str:match("^(%w+)%((%d+)%)$")
    if type_name and Declarative.typeMap[type_name] then
        local col = Declarative.typeMap[type_name]
        return { type = col.type, length = tonumber(length) }
    end

    -- Check if it's a decimal with precision: decimal(10,2)
    local dec_type, precision, scale = type_str:match("^(decimal)%((%d+),(%d+)%)$")
    if dec_type then
        return { type = "decimal", precision = tonumber(precision), scale = tonumber(scale) }
    end

    -- Default to string
    return { type = "string", length = 255 }
end

-- Parse a field definition
function Declarative.parseField(field_name, field_def)
    local column = {
        name = field_name,
        type = nil,
        length = nil,
        precision = nil,
        scale = nil,
        primary_key = false,
        unique = false,
        not_null = false,
        default = nil,
        default_now = false,
        references = nil,
        validations = {},
    }

    -- If field_def is a string, parse it as a type
    if type(field_def) == "string" then
        local parsed = Declarative.parseType(field_def)
        column.type = parsed.type
        column.length = parsed.length
        column.precision = parsed.precision
        column.scale = parsed.scale
        return column
    end

    -- If field_def is a table, use the definition directly
    if type(field_def) == "table" then
        column.type = field_def.type or "string"
        column.length = field_def.length
        column.precision = field_def.precision
        column.scale = field_def.scale
        column.primary_key = field_def.primary_key or false
        column.unique = field_def.unique or false
        column.not_null = field_def.not_null or field_def.notNull or false
        column.default = field_def.default
        column.default_now = field_def.default_now or field_def.defaultNow or false
        column.references = field_def.references
        return column
    end

    return column
end

-- Parse a model definition
function Declarative.parseModel(model_name, model_def)
    local model = {
        name = model_name,
        tableName = nil,
        fields = {},
        options = {},
        validations = {},
        relations = {},
    }

    -- Determine table name
    if model_def.table then
        model.tableName = model_def.table
    else
        model.tableName = Declarative.conventions.tableName(model_name)
    end

    -- Parse fields
    for field_name, field_def in pairs(model_def) do
        -- Skip special keys
        if field_name ~= "table" and field_name ~= "timestamps" and
           field_name ~= "softDeletes" and field_name ~= "validations" and
           field_name ~= "relations" then
            local field = Declarative.parseField(field_name, field_def)
            model.fields[field_name] = field
        end
    end

    -- Add timestamps if enabled
    if model_def.timestamps ~= false then
        local timestamps = Declarative.conventions.timestamps()
        for name, def in pairs(timestamps) do
            if not model.fields[name] then
                model.fields[name] = {
                    name = name,
                    type = def.type,
                    default_now = def.default_now,
                }
            end
        end
    end

    -- Add primary key if not defined
    local has_pk = false
    for _, field in pairs(model.fields) do
        if field.primary_key then
            has_pk = true
            break
        end
    end
    if not has_pk then
        local pk = Declarative.conventions.primaryKey()
        model.fields.id = {
            name = "id",
            type = pk.type,
            primary_key = pk.primary_key,
        }
    end

    -- Parse validations
    if model_def.validations then
        model.validations = model_def.validations
    end

    -- Parse relations
    if model_def.relations then
        model.relations = model_def.relations
    end

    -- Store options
    model.options.timestamps = model_def.timestamps ~= false
    model.options.softDeletes = model_def.softDeletes or false

    return model
end

-- Parse a complete schema definition
function Declarative.parse(schema_def)
    local schema = {
        models = {},
        options = schema_def.options or {},
    }

    for model_name, model_def in pairs(schema_def) do
        if model_name ~= "options" then
            schema.models[model_name] = Declarative.parseModel(model_name, model_def)
        end
    end

    return schema
end

-- Generate entity from parsed model
function Declarative.generateEntity(model)
    local columns = {}

    for field_name, field in pairs(model.fields) do
        local col_type = field.type

        -- Create column based on type
        local col = require("jade.schema.column").new(nil, col_type, field.length)
        col._name = field_name
        col._table = model.tableName

        if field.primary_key then
            col:primaryKey()
        end
        if field.unique then
            col:unique()
        end
        if field.not_null then
            col:notNull()
        end
        if field.default ~= nil then
            col:default(field.default)
        end
        if field.default_now then
            col:defaultNow()
        end
        if field.references then
            col:references(field.references.table, field.references.column)
        end

        columns[field_name] = col
    end

    -- Create entity
    local entity = Entity.new(model.tableName, columns)

    -- Add validations
    for field_name, validations in pairs(model.validations) do
        if columns[field_name] then
            for validation_type, options in pairs(validations) do
                entity:validates(field_name, validation_type, options)
            end
        end
    end

    return entity
end

-- Generate migration from parsed schema
function Declarative.generateMigration(schema, migration_name)
    local migration = {
        name = migration_name or ("create_" .. table.concat(Declarative.getTableNames(schema), "_and_")),
        up = function(driver)
            for model_name, model in pairs(schema.models) do
                Declarative.createTableFromModel(driver, model)
            end
        end,
        down = function(driver)
            for model_name, model in pairs(schema.models) do
                Schema.dropTable(driver, model.tableName)
            end
        end,
    }

    return migration
end

-- Get table names from schema
function Declarative.getTableNames(schema)
    local names = {}
    for _, model in pairs(schema.models) do
        names[#names + 1] = model.tableName
    end
    return names
end

-- Create table from model definition
function Declarative.createTableFromModel(driver, model)
    local Table = require("jade.schema.table")
    local tbl = Table.new(model.tableName)

    -- Add columns
    for field_name, field in pairs(model.fields) do
        tbl:column(field_name, field.type, {
            length = field.length,
            precision = field.precision,
            scale = field.scale,
            primary_key = field.primary_key,
            unique = field.unique,
            null = not field.not_null,
            default = field.default,
            default_now = field.default_now,
        })
    end

    -- Add foreign keys from relations
    for _, relation in pairs(model.relations) do
        if relation.type == "belongsTo" then
            local fk_field = Declarative.conventions.foreignKey(relation.model)
            if not model.fields[fk_field] then
                tbl:column(fk_field, "integer", { null = true })
            end
            tbl:foreignKey({
                column = fk_field,
                references_table = Declarative.conventions.tableName(relation.model),
                references_column = "id",
                on_delete = relation.on_delete or "SET NULL",
            })
        end
    end

    -- Execute CREATE TABLE
    local sql = tbl:toSQL(driver)
    driver:execute(sql)

    -- Execute CREATE INDEX statements
    local index_statements = tbl:indexSQL()
    for _, idx_sql in ipairs(index_statements) do
        driver:execute(idx_sql)
    end

    return true
end

-- Create a schema definition helper function
function Declarative.define(schema_fn)
    local schema_def = {}
    local builder = {
        model = function(self, name, def)
            schema_def[name] = def
            return self
        end,
        options = function(self, opts)
            schema_def.options = opts
            return self
        end,
        build = function(self)
            return schema_def
        end,
    }

    setmetatable(builder, { __index = Declarative })
    schema_fn(builder)
    return Declarative.parse(schema_def)
end

-- Compare two schemas and generate diff
function Declarative.diff(old_schema, new_schema)
    local diff = {
        tables_to_create = {},
        tables_to_drop = {},
        tables_to_alter = {},
    }

    -- Find tables to create (in new but not in old)
    for model_name, model in pairs(new_schema.models) do
        if not old_schema.models[model_name] then
            diff.tables_to_create[#diff.tables_to_create + 1] = model
        end
    end

    -- Find tables to drop (in old but not in new)
    for model_name, model in pairs(old_schema.models) do
        if not new_schema.models[model_name] then
            diff.tables_to_drop[#diff.tables_to_drop + 1] = model
        end
    end

    -- Find tables to alter (in both but different)
    for model_name, new_model in pairs(new_schema.models) do
        local old_model = old_schema.models[model_name]
        if old_model then
            local changes = Declarative.diffModels(old_model, new_model)
            if changes then
                diff.tables_to_alter[#diff.tables_to_alter + 1] = {
                    model = new_model,
                    changes = changes,
                }
            end
        end
    end

    return diff
end

-- Compare two models and return changes
function Declarative.diffModels(old_model, new_model)
    local changes = {
        columns_to_add = {},
        columns_to_drop = {},
        columns_to_alter = {},
    }

    -- Find columns to add
    for field_name, field in pairs(new_model.fields) do
        if not old_model.fields[field_name] then
            changes.columns_to_add[#changes.columns_to_add + 1] = field
        end
    end

    -- Find columns to drop
    for field_name, field in pairs(old_model.fields) do
        if not new_model.fields[field_name] then
            changes.columns_to_drop[#changes.columns_to_drop + 1] = field
        end
    end

    -- Find columns to alter
    for field_name, new_field in pairs(new_model.fields) do
        local old_field = old_model.fields[field_name]
        if old_field then
            if Declarative.diffFields(old_field, new_field) then
                changes.columns_to_alter[#changes.columns_to_alter + 1] = {
                    old = old_field,
                    new = new_field,
                }
            end
        end
    end

    -- Check if there are any changes
    if #changes.columns_to_add == 0 and #changes.columns_to_drop == 0 and #changes.columns_to_alter == 0 then
        return nil
    end

    return changes
end

-- Compare two fields and return true if they are different
function Declarative.diffFields(old_field, new_field)
    return old_field.type ~= new_field.type or
           old_field.length ~= new_field.length or
           old_field.primary_key ~= new_field.primary_key or
           old_field.unique ~= new_field.unique or
           old_field.not_null ~= new_field.not_null or
           old_field.default ~= new_field.default or
           old_field.default_now ~= new_field.default_now
end

return Declarative
