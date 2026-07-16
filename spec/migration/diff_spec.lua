describe("Migration Diff", function()
    local diff = require("jade.migration.diff")

    it("detects new tables", function()
        local current = { tables = {} }
        local desired = {
            tables = {
                { name = "users", columns = {} },
            },
        }
        local result = diff.compare(current, desired)
        assert.are.equal(1, #result.create_tables)
        assert.are.equal("users", result.create_tables[1].name)
    end)

    it("detects tables to drop", function()
        local current = {
            tables = {
                { name = "old_table", columns = {} },
            },
        }
        local desired = { tables = {} }
        local result = diff.compare(current, desired)
        assert.are.equal(1, #result.drop_tables)
        assert.are.equal("old_table", result.drop_tables[1])
    end)

    it("detects new columns", function()
        local current = {
            tables = {
                { name = "users", columns = {} },
            },
        }
        local desired = {
            tables = {
                {
                    name = "users",
                    columns = {
                        { name = "email", type = "string", length = 255 },
                    },
                },
            },
        }
        local result = diff.compare(current, desired)
        assert.are.equal(1, #result.add_columns)
        assert.are.equal("users", result.add_columns[1].table)
        assert.are.equal("email", result.add_columns[1].column.name)
    end)

    it("detects columns to drop", function()
        local current = {
            tables = {
                {
                    name = "users",
                    columns = {
                        { name = "old_field", type = "string" },
                    },
                },
            },
        }
        local desired = {
            tables = {
                { name = "users", columns = {} },
            },
        }
        local result = diff.compare(current, desired)
        assert.are.equal(1, #result.drop_columns)
        assert.are.equal("users", result.drop_columns[1].table)
        assert.are.equal("old_field", result.drop_columns[1].column)
    end)

    it("detects column changes", function()
        local current = {
            tables = {
                {
                    name = "users",
                    columns = {
                        { name = "name", type = "string", length = 100 },
                    },
                },
            },
        }
        local desired = {
            tables = {
                {
                    name = "users",
                    columns = {
                        { name = "name", type = "string", length = 255 },
                    },
                },
            },
        }
        local result = diff.compare(current, desired)
        assert.are.equal(1, #result.modify_columns)
    end)

    it("reports empty diff when equal", function()
        local schema = {
            tables = {
                {
                    name = "users",
                    columns = {
                        { name = "id", type = "integer" },
                    },
                },
            },
        }
        local result = diff.compare(schema, schema)
        assert.is_true(diff.isEmpty(result))
    end)

    it("converts diff to string", function()
        local result = {
            create_tables = { { name = "users" } },
            drop_tables = {},
            add_columns = {},
            drop_columns = {},
            modify_columns = {},
        }
        local str = diff.toString(result)
        assert.is_truth(string.find(str, "CREATE TABLE users"))
    end)
end)
