describe("Event System", function()
    local Entity = require("jade.entity")
    local Integer = require("jade.types.integer")
    local String = require("jade.types.string")
    local Boolean = require("jade.types.boolean")
    local Events = require("jade.entity.events")

    before_each(function()
        Events.clear()
    end)

    describe("Entity:events()", function()
        it("defines custom events for an entity", function()
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
                name = String(120),
            })
            User:events({"login", "password_changed"})
            assert.is_not_nil(User._events)
        end)

        it("returns self for chaining", function()
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
            })
            local result = User:events({"login"})
            assert.are.equal(User, result)
        end)
    end)

    describe("Entity:fire()", function()
        it("fires a custom event", function()
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
                name = String(120),
            })
            User:configure({})
            local fired = false
            local fired_data = nil

            Events.on("users.login", function(data)
                fired = true
                fired_data = data
            end)

            User:fire("login", { user_id = 1, ip = "127.0.0.1" })
            assert.is_true(fired)
            assert.are.equal(1, fired_data.user_id)
            assert.are.equal("127.0.0.1", fired_data.ip)
        end)

        it("fires event with multiple handlers", function()
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
            })
            User:configure({})
            local count = 0

            Events.on("users.login", function(data)
                count = count + 1
            end)

            Events.on("users.login", function(data)
                count = count + 1
            end)

            User:fire("login", {})
            assert.are.equal(2, count)
        end)

        it("returns self for chaining", function()
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
            })
            User:configure({})
            local result = User:fire("test", {})
            assert.are.equal(User, result)
        end)
    end)

    describe("jade.on()", function()
        it("registers a global event handler", function()
            local Jade = require("jade.init")
            local fired = false

            Jade.on("users.created", function(data)
                fired = true
            end)

            local User = Jade.Entity("users", {
                id = Integer():primaryKey(),
                name = String(120),
            })

            local mock_driver = {
                generateInsert = function(self, table_name, data, entity)
                    return "INSERT INTO users (name) VALUES (?) RETURNING *", { "John" }
                end,
                execute = function(self, sql, bindings)
                    return { { id = 1, name = "John" } }
                end,
            }
            User:configure(mock_driver)

            User:create({ name = "John" })
            assert.is_true(fired)
        end)

        it("handles event with data", function()
            local Jade = require("jade.init")
            local received_data = nil

            Jade.on("users.created", function(data)
                received_data = data
            end)

            local User = Jade.Entity("users", {
                id = Integer():primaryKey(),
                name = String(120),
            })

            local mock_driver = {
                generateInsert = function(self, table_name, data, entity)
                    return "INSERT INTO users (name) VALUES (?) RETURNING *", { "John" }
                end,
                execute = function(self, sql, bindings)
                    return { { id = 1, name = "John" } }
                end,
            }
            User:configure(mock_driver)

            User:create({ name = "John" })
            assert.is_not_nil(received_data)
            assert.is_not_nil(received_data.instance)
        end)
    end)

    describe("Built-in events", function()
        it("fires 'created' event on create", function()
            local Entity = require("jade.entity")
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
                name = String(120),
            })
            local fired = false

            Events.on("users.created", function(data)
                fired = true
            end)

            local mock_driver = {
                generateInsert = function(self, table_name, data, entity)
                    return "INSERT INTO users (name) VALUES (?) RETURNING *", { "John" }
                end,
                execute = function(self, sql, bindings)
                    return { { id = 1, name = "John" } }
                end,
            }
            User:configure(mock_driver)

            User:create({ name = "John" })
            assert.is_true(fired)
        end)

        it("fires 'updated' event on update", function()
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
                name = String(120),
            })
            local fired = false

            Events.on("users.updated", function(data)
                fired = true
            end)

            local mock_driver = {
                generateUpdate = function(self, table_name, data, where)
                    return "UPDATE users SET name = ? WHERE id = ? RETURNING *", { "Jane", 1 }
                end,
                execute = function(self, sql, bindings)
                    return { { id = 1, name = "Jane" } }
                end,
            }
            User:configure(mock_driver)

            User:update(1, { name = "Jane" })
            assert.is_true(fired)
        end)

        it("fires 'deleted' event on delete", function()
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
                name = String(120),
            })
            local fired = false

            Events.on("users.deleted", function(data)
                fired = true
            end)

            local mock_driver = {
                generateDelete = function(self, table_name, where)
                    return "DELETE FROM users WHERE id = ? RETURNING *", { 1 }
                end,
                execute = function(self, sql, bindings)
                    return { { id = 1, name = "John" } }
                end,
            }
            User:configure(mock_driver)

            User:delete(1)
            assert.is_true(fired)
        end)
    end)

    describe("Custom events", function()
        it("fires custom event defined via events()", function()
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
                name = String(120),
            })
            User:events({"login", "password_changed"})
            User:configure({})
            local fired = false

            Events.on("users.login", function(data)
                fired = true
            end)

            User:fire("login", { user_id = 1 })
            assert.is_true(fired)
        end)

        it("fires multiple custom events independently", function()
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
            })
            User:events({"login", "logout"})
            User:configure({})
            local login_fired = false
            local logout_fired = false

            Events.on("users.login", function(data)
                login_fired = true
            end)

            Events.on("users.logout", function(data)
                logout_fired = true
            end)

            User:fire("login", {})
            assert.is_true(login_fired)
            assert.is_false(logout_fired)

            User:fire("logout", {})
            assert.is_true(logout_fired)
        end)
    end)

    describe("Event handler errors", function()
        it("propagates handler errors", function()
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
            })
            User:configure({})

            Events.on("users.test", function(data)
                error("handler failed")
            end)

            local ok, err = pcall(function()
                User:fire("test", {})
            end)
            assert.is_false(ok)
            assert.is_truth(string.find(err, "handler failed"))
        end)
    end)

    describe("Events.clear()", function()
        it("removes all event handlers", function()
            local User = Entity.new("users", {
                id = Integer():primaryKey(),
            })
            User:configure({})
            local fired = false

            Events.on("users.test", function(data)
                fired = true
            end)

            Events.clear()

            local ok = pcall(function()
                User:fire("test", {})
            end)
            assert.is_true(ok)
            assert.is_false(fired)
        end)
    end)
end)
