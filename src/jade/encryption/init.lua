local M = {}

-- Encryption configuration
local enc_config = {
    key = nil,
    algorithm = "aes",  -- "aes" for database-native encryption
    database_encrypted = false,
    fields = {},
    -- PostgreSQL: requires pgcrypto extension
    -- MySQL: uses AES_ENCRYPT/AES_DECRYPT
    -- SQLite: NOT supported (use SQLCipher or external encryption)
}

-- Column-level encryption markers
local encrypted_columns = {}

-- Configure encryption
function M.configure(opts)
    if opts.key then enc_config.key = opts.key end
    if opts.algorithm then enc_config.algorithm = opts.algorithm end
    if opts.database_encrypted ~= nil then enc_config.database_encrypted = opts.database_encrypted end
    if opts.fields then enc_config.fields = opts.fields end
end

-- Get config
function M.getConfig()
    return enc_config
end

-- Mark a column as encrypted
function M.markColumn(entity_name, column_name)
    if not encrypted_columns[entity_name] then
        encrypted_columns[entity_name] = {}
    end
    encrypted_columns[entity_name][column_name] = true
end

-- Check if a column should be encrypted
function M.isEncrypted(entity_name, column_name)
    if encrypted_columns[entity_name] and encrypted_columns[entity_name][column_name] then
        return true
    end
    if enc_config.database_encrypted then
        return true
    end
    if enc_config.fields[entity_name] then
        for _, field in ipairs(enc_config.fields[entity_name]) do
            if field == column_name then return true end
        end
    end
    return false
end

-- Get fields that should be encrypted for an entity
function M.getEncryptedFields(entity_name, columns)
    local fields = {}

    -- From column-level markers
    if encrypted_columns[entity_name] then
        for col in pairs(encrypted_columns[entity_name]) do
            fields[col] = true
        end
    end

    -- From database-wide encryption
    if enc_config.database_encrypted then
        for col_name in pairs(columns) do
            fields[col_name] = true
        end
    end

    -- From field-specific config
    if enc_config.fields[entity_name] then
        for _, field in ipairs(enc_config.fields[entity_name]) do
            fields[field] = true
        end
    end

    return fields
end

-- Get the encryption key
function M.getKey()
    return enc_config.key
end

-- Check if encryption is enabled
function M.isEnabled()
    return enc_config.key ~= nil and enc_config.key ~= ""
end

--- Wrap a column reference with encryption function for INSERT/UPDATE
--- @param column_ref string The quoted column reference (e.g., '"email"')
--- @param driver table The database driver
--- @return string SQL fragment with encryption
function M.wrapEncrypt(column_ref, driver)
    if not M.isEnabled() then
        return column_ref
    end

    local key = enc_config.key
    local driver_type = driver._driver_type or "postgresql"

    if driver_type == "postgresql" then
        -- PostgreSQL: pgcrypto extension required
        -- CREATE EXTENSION IF NOT EXISTS pgcrypto;
        return string.format("pgp_sym_encrypt(%s::text, '%s')", column_ref, key:gsub("'", "''"))
    elseif driver_type == "mysql" then
        -- MySQL: native AES_ENCRYPT
        return string.format("AES_ENCRYPT(%s, '%s')", column_ref, key:gsub("'", "''"))
    else
        -- SQLite and others: no native encryption support
        error("Database encryption is not supported for " .. driver_type .. ". Use PostgreSQL with pgcrypto or MySQL.")
    end
end

--- Wrap a column reference with decryption function for SELECT
--- @param column_ref string The quoted column reference (e.g., '"email"')
--- @param driver table The database driver
--- @param as_name string Optional alias for the decrypted column
--- @return string SQL fragment with decryption
function M.wrapDecrypt(column_ref, driver, as_name)
    if not M.isEnabled() then
        return column_ref
    end

    local key = enc_config.key
    local driver_type = driver._driver_type or "postgresql"
    local alias = as_name and (" AS " .. as_name) or ""

    if driver_type == "postgresql" then
        -- PostgreSQL: pgcrypto extension required
        return string.format("pgp_sym_decrypt(%s, '%s')%s", column_ref, key:gsub("'", "''"), alias)
    elseif driver_type == "mysql" then
        -- MySQL: native AES_DECRYPT (returns binary, need CAST)
        return string.format("CAST(AES_DECRYPT(%s, '%s') AS CHAR)%s", column_ref, key:gsub("'", "''"), alias)
    else
        error("Database decryption is not supported for " .. driver_type .. ". Use PostgreSQL with pgcrypto or MySQL.")
    end
end

--- Check if a SELECT item needs decryption wrapping
--- @param item string|table The select item
--- @param entity_name string The entity/table name
--- @param columns table The entity columns
--- @param driver table The database driver
--- @return string, table The resolved SQL fragment and any bindings
function M.resolveSelectItem(item, entity_name, columns, driver)
    if not M.isEnabled() then
        return nil, nil  -- No encryption, use default handling
    end

    if type(item) == "string" then
        -- Check if this column is encrypted
        if M.isEncrypted(entity_name, item) then
            local Quoting = require("jade.util.quoting")
            local col_ref = Quoting.quoteIdentifier(item)
            return M.wrapDecrypt(col_ref, driver, Quoting.quoteIdentifier(item)), {}
        end
    elseif type(item) == "table" and item._column then
        -- Expression with column reference
        if M.isEncrypted(entity_name, item._column) then
            local Quoting = require("jade.util.quoting")
            local col_ref = Quoting.quoteIdentifier(item._column)
            local alias = item._alias and (" AS " .. Quoting.quoteIdentifier(item._alias)) or ""
            return M.wrapDecrypt(col_ref, driver, nil) .. alias, {}
        end
    end

    return nil, nil  -- Not encrypted, use default handling
end

--- Prepare data for INSERT by wrapping encrypted columns
--- @param data table The input data
--- @param entity_name string The entity/table name
--- @param columns table The entity columns
--- @param driver table The database driver
--- @return table, table Modified data with encryption markers, and bindings
function M.prepareInsert(data, entity_name, columns, driver)
    if not M.isEnabled() then
        return data, {}
    end

    local fields = M.getEncryptedFields(entity_name, columns)
    local result = {}
    local bindings = {}
    local encrypt_cols = {}

    for k, v in pairs(data) do
        if fields[k] then
            -- Mark this column for encryption in SQL generation
            encrypt_cols[k] = true
            result[k] = v  -- Keep the raw value, driver will wrap with encryption
        else
            result[k] = v
        end
    end

    return result, encrypt_cols
end

--- Prepare data for UPDATE by wrapping encrypted columns
--- @param data table The input data
--- @param entity_name string The entity/table name
--- @param columns table The entity columns
--- @param driver table The database driver
--- @return table, table Modified data with encryption markers, and bindings
function M.prepareUpdate(data, entity_name, columns, driver)
    return M.prepareInsert(data, entity_name, columns, driver)  -- Same logic
end

-- Clear config (for testing)
function M.clear()
    enc_config = {
        key = nil,
        algorithm = "aes",
        database_encrypted = false,
        fields = {},
    }
    encrypted_columns = {}
end

return M
