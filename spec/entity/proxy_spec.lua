describe("Proxy", function()
    local Entity = require("jade.entity")
    local Proxy = require("jade.entity.proxy")
    local Integer = require("jade.types.integer")
    local String = require("jade.types.string")
    local Relations = require("jade.entity.relations")

    local User
    local Post

    before_each(function()
        User = Entity.new("users", {
            id = Integer():primaryKey(),
            name = String(120),
        })

        Post = Entity.new("posts", {
            id = Integer():primaryKey(),
            title = String(255),
            user_id = Integer(),
        })
    end)

    it("creates proxy for relation", function()
        local relation = Relations.belongsTo(User)
        local owner = { id = 1, user_id = 5 }
        local proxy = Proxy.new(relation, owner)
        assert.is_false(proxy:isLoaded())
    end)

    it("loads data on demand", function()
        local relation = Relations.belongsTo(User)
        local owner = { id = 1, user_id = 5 }

        -- Mock the find method
        User.find = function(self, id)
            return { id = id, name = "User " .. id }
        end
        User._driver = true

        local proxy = Proxy.new(relation, owner)
        local data = proxy:load()
        assert.is_true(proxy:isLoaded())
        assert.are.equal(5, data.id)
    end)

    it("caches loaded data", function()
        local relation = Relations.belongsTo(User)
        local owner = { id = 1, user_id = 5 }
        local call_count = 0

        User.find = function(self, id)
            call_count = call_count + 1
            return { id = id, name = "User " .. id }
        end
        User._driver = true

        local proxy = Proxy.new(relation, owner)
        proxy:load()
        proxy:load()
        assert.are.equal(1, call_count)
    end)
end)
