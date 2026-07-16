describe("Instance", function()
    local Entity = require("jade.entity")
    local Instance = require("jade.entity.instance")
    local Integer = require("jade.types.integer")
    local String = require("jade.types.string")

    local User

    before_each(function()
        User = Entity.new("users", {
            id = Integer():primaryKey(),
            name = String(120),
        })
    end)

    it("creates instance with data", function()
        local inst = Instance.new(User, { id = 1, name = "Lucas" })
        assert.are.equal(1, inst._data.id)
        assert.are.equal("Lucas", inst._data.name)
    end)

    it("accesses data via __index", function()
        local inst = Instance.new(User, { id = 1, name = "Lucas" })
        assert.are.equal(1, inst.id)
        assert.are.equal("Lucas", inst.name)
    end)

    it("updates data in place", function()
        local inst = Instance.new(User, { id = 1, name = "Lucas" })
        inst._data.name = "Novo Nome"
        assert.are.equal("Novo Nome", inst.name)
    end)

    it("converts to table", function()
        local inst = Instance.new(User, { id = 1, name = "Lucas" })
        local t = inst:toTable()
        assert.are.same({ id = 1, name = "Lucas" }, t)
        -- Ensure it's a copy
        t.id = 999
        assert.are.equal(1, inst.id)
    end)
end)
