local M = {}

function M.createTrackerTable(driver)
    local sql = [[
        CREATE TABLE IF NOT EXISTS _jade_migrations (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) UNIQUE NOT NULL,
            applied_at TIMESTAMPTZ DEFAULT NOW()
        )
    ]]
    return driver:execute(sql)
end

function M.getAppliedMigrations(driver)
    local sql = "SELECT name FROM _jade_migrations ORDER BY id"
    local result = driver:execute(sql)
    local applied = {}
    for _, row in ipairs(result) do
        applied[row.name] = true
    end
    return applied
end

function M.recordMigration(driver, name)
    local sql = "INSERT INTO _jade_migrations (name) VALUES (?)"
    return driver:execute(sql, { name })
end

function M.removeMigration(driver, name)
    local sql = "DELETE FROM _jade_migrations WHERE name = ?"
    return driver:execute(sql, { name })
end

function M.getLastApplied(driver, count)
    count = count or 1
    local sql = "SELECT name FROM _jade_migrations ORDER BY id DESC LIMIT " .. tostring(count)
    local result = driver:execute(sql)
    local names = {}
    for _, row in ipairs(result) do
        names[#names + 1] = row.name
    end
    return names
end

return M
