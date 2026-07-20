describe("Named Scopes", function()
    local Entity = require("jade.entity")
    local Integer = require("jade.types.integer")
    local String = require("jade.types.string")
    local Boolean = require("jade.types.boolean")

    it("defines a scope", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
            active = Boolean(),
        })
        User:scope("active", function(q)
            return q:where(User.active:eq(true))
        end)
        assert.is_not_nil(User._scopes.active)
        assert.is_function(User._scopes.active)
    end)

    it("invokes a scope via scope(name)", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
            active = Boolean(),
        })
        User:scope("active", function(q)
            return q:where(User.active:eq(true))
        end)
        local q = User:scope("active")
        assert.is_not_nil(q)
        assert.is_not_nil(q._where)
        assert.are.equal(1, #q._where)
    end)

    it("scope applies conditions correctly", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
            active = Boolean(),
            name = String(120),
        })
        User:scope("active", function(q)
            return q:where(User.active:eq(true))
        end)
        local q = User:scope("active")
        local cond = q._where[1]
        assert.are.equal("active", cond.column)
        assert.are.equal("=", cond.op)
        assert.are.equal(true, cond.value)
    end)

    it("scope with arguments applies conditions", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
            age = Integer(),
        })
        User:scope("older_than", function(q, age)
            return q:where(User.age:gt(age))
        end)
        local q = User:scope("older_than", 30)
        local cond = q._where[1]
        assert.are.equal("age", cond.column)
        assert.are.equal(">", cond.op)
        assert.are.equal(30, cond.value)
    end)

    it("scope returns a query that is chainable", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
            active = Boolean(),
            age = Integer(),
        })
        User:scope("active", function(q)
            return q:where(User.active:eq(true))
        end)
        User:scope("older_than", function(q, age)
            return q:where(User.age:gt(age))
        end)
        -- Chain two scopes
        local q = User:scope("active")
        q = User:scope("older_than", 30):where(q._where[1])
        assert.is_not_nil(q)
        assert.are.equal(2, #q._where)
    end)

    it("scope returns self for chaining with query methods", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
            active = Boolean(),
            name = String(120),
        })
        User:scope("active", function(q)
            return q:where(User.active:eq(true))
        end)
        local q = User:scope("active"):limit(10)
        assert.is_not_nil(q)
        assert.are.equal(10, q._limit)
        assert.are.equal(1, #q._where)
    end)

    it("scope can be defined with multiple conditions", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
            active = Boolean(),
            age = Integer(),
            name = String(120),
        })
        User:scope("active_adults", function(q)
            q = q:where(User.active:eq(true))
            q = q:where(User.age:gt(18))
            return q
        end)
        local q = User:scope("active_adults")
        assert.are.equal(2, #q._where)
    end)

    it("multiple scopes can be defined independently", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
            active = Boolean(),
            name = String(120),
        })
        User:scope("active", function(q)
            return q:where(User.active:eq(true))
        end)
        User:scope("named", function(q)
            return q:where(User.name:isNotNull())
        end)
        local q1 = User:scope("active")
        local q2 = User:scope("named")
        assert.are.equal(1, #q1._where)
        assert.are.equal(1, #q2._where)
        assert.are.equal("active", q1._where[1].column)
        assert.are.equal("name", q2._where[1].column)
    end)

    it("scope returning nil still returns a query", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
        })
        User:scope("noop", function(q)
            return q
        end)
        local q = User:scope("noop")
        assert.is_not_nil(q)
        assert.are.equal(0, #q._where)
    end)

    it("scope can set limit", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
            active = Boolean(),
        })
        User:scope("active", function(q)
            return q:where(User.active:eq(true)):limit(5)
        end)
        local q = User:scope("active")
        assert.are.equal(5, q._limit)
        assert.are.equal(1, #q._where)
    end)

    it("column access still works alongside scopes", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
            active = Boolean(),
        })
        User:scope("active", function(q)
            return q:where(User.active:eq(true))
        end)
        -- Column access returns Expression
        local expr = User.active
        assert.is_not_nil(expr)
        assert.are.equal("active", expr._column)
        -- Scope invocation returns Query
        local q = User:scope("active")
        assert.is_not_nil(q._where)
    end)

    it("scope definition is chainable", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
            active = Boolean(),
            age = Integer(),
        })
        User:scope("active", function(q)
            return q:where(User.active:eq(true))
        end):scope("older_than", function(q, age)
            return q:where(User.age:gt(age))
        end)
        assert.is_not_nil(User._scopes.active)
        assert.is_not_nil(User._scopes.older_than)
    end)

    it("invoking undefined scope returns empty query", function()
        local User = Entity.new("users", {
            id = Integer():primaryKey(),
        })
        local q = User:scope("nonexistent")
        assert.is_not_nil(q)
        assert.are.equal(0, #q._where)
    end)
end)
