describe("Migration Generator", function()
    local generator = require("jade.migration.generator")
    local Column = require("jade.schema.column")

    it("generates CREATE TABLE statement", function()
        local columns = {
            id = Column.new(nil, "integer"):primaryKey(),
            name = Column.new(nil, "string", 120):notNull(),
        }
        local sql = generator.generateCreateTable("users", columns)
        assert.is_truth(string.find(sql, "Jade.createTable"))
        assert.is_truth(string.find(sql, "users"))
        assert.is_truth(string.find(sql, "primaryKey"))
        assert.is_truth(string.find(sql, "notNull"))
    end)

    it("generates DROP TABLE statement", function()
        local sql = generator.generateDropTable("users")
        assert.is_truth(string.find(sql, "Jade.dropTable"))
        assert.is_truth(string.find(sql, "users"))
    end)

    it("generates ADD COLUMN statement", function()
        local col = Column.new(nil, "string", 255)
        local sql = generator.generateAddColumn("users", "email", col)
        assert.is_truth(string.find(sql, "Jade.addColumn"))
        assert.is_truth(string.find(sql, "users"))
        assert.is_truth(string.find(sql, "email"))
    end)

    it("generates DROP COLUMN statement", function()
        local sql = generator.generateDropColumn("users", "email")
        assert.is_truth(string.find(sql, "Jade.dropColumn"))
        assert.is_truth(string.find(sql, "users"))
        assert.is_truth(string.find(sql, "email"))
    end)

    it("generates full migration from diff", function()
        local diff = {
            create_tables = {
                {
                    name = "users",
                    columns = {
                        id = Column.new(nil, "integer"):primaryKey(),
                        name = Column.new(nil, "string", 120),
                    },
                },
            },
            drop_tables = {},
            add_columns = {},
            drop_columns = {},
            modify_columns = {},
        }

        local up, down = generator.generateMigration("create_users", diff)
        assert.is_truth(string.find(up, "Jade.createTable"))
        assert.is_truth(string.find(down, "Jade.dropTable"))
    end)
end)
