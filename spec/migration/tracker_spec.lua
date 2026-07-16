describe("Migration Tracker", function()
    local tracker = require("jade.migration.tracker")

    -- Mock driver
    local mock_driver
    local migrations_table

    before_each(function()
        migrations_table = {}
        mock_driver = {
            execute = function(self, sql, bindings)
                -- Track SQL calls
                if sql:match("CREATE TABLE") then
                    return {}
                elseif sql:match("INSERT INTO _jade_migrations") then
                    migrations_table[#migrations_table + 1] = { name = bindings[1] }
                    return {}
                elseif sql:match("DELETE FROM _jade_migrations") then
                    for i, row in ipairs(migrations_table) do
                        if row.name == bindings[1] then
                            table.remove(migrations_table, i)
                            break
                        end
                    end
                    return {}
                elseif sql:match("SELECT name FROM _jade_migrations ORDER BY id DESC") then
                    local limit = tonumber(sql:match("LIMIT (%d+)")) or #migrations_table
                    local result = {}
                    local count = 0
                    for i = #migrations_table, 1, -1 do
                        count = count + 1
                        if count > limit then break end
                        result[#result + 1] = { name = migrations_table[i].name }
                    end
                    return result
                elseif sql:match("SELECT name FROM _jade_migrations") then
                    return migrations_table
                end
                return {}
            end,
        }
    end)

    it("creates tracker table", function()
        local result = tracker.createTrackerTable(mock_driver)
        assert.is_not_nil(result)
    end)

    it("records migration", function()
        tracker.recordMigration(mock_driver, "20260715120000_create_users.lua")
        assert.are.equal(1, #migrations_table)
        assert.are.equal("20260715120000_create_users.lua", migrations_table[1].name)
    end)

    it("gets applied migrations", function()
        tracker.recordMigration(mock_driver, "20260715120000_create_users.lua")
        tracker.recordMigration(mock_driver, "20260715120001_create_posts.lua")
        local applied = tracker.getAppliedMigrations(mock_driver)
        assert.is_true(applied["20260715120000_create_users.lua"])
        assert.is_true(applied["20260715120001_create_posts.lua"])
    end)

    it("removes migration", function()
        tracker.recordMigration(mock_driver, "20260715120000_create_users.lua")
        tracker.removeMigration(mock_driver, "20260715120000_create_users.lua")
        local applied = tracker.getAppliedMigrations(mock_driver)
        assert.is_falsy(applied["20260715120000_create_users.lua"])
    end)

    it("gets last applied", function()
        tracker.recordMigration(mock_driver, "20260715120000_create_users.lua")
        tracker.recordMigration(mock_driver, "20260715120001_create_posts.lua")
        tracker.recordMigration(mock_driver, "20260715120002_create_comments.lua")
        local last = tracker.getLastApplied(mock_driver, 2)
        assert.are.equal(2, #last)
        assert.are.equal("20260715120002_create_comments.lua", last[1])
        assert.are.equal("20260715120001_create_posts.lua", last[2])
    end)
end)
