describe("Security - Validator", function()
    local validator = require("jade.security.validator")

    it("validates column names", function()
        assert.is_true(validator.validateColumnName("users"))
        assert.is_true(validator.validateColumnName("user_name"))
        assert.is_true(validator.validateColumnName("_id"))
    end)

    it("rejects invalid column names", function()
        assert.has_error(function() validator.validateColumnName("user-name") end)
        assert.has_error(function() validator.validateColumnName("user name") end)
        assert.has_error(function() validator.validateColumnName("123users") end)
    end)

    it("validates table names", function()
        assert.is_true(validator.validateTableName("users"))
        assert.is_true(validator.validateTableName("user_posts"))
    end)

    it("rejects invalid table names", function()
        assert.has_error(function() validator.validateTableName("user-table") end)
        assert.has_error(function() validator.validateTableName("123table") end)
    end)

    it("validates order direction", function()
        assert.is_true(validator.validateOrderDirection("ASC"))
        assert.is_true(validator.validateOrderDirection("DESC"))
        assert.is_true(validator.validateOrderDirection("asc"))
        assert.is_true(validator.validateOrderDirection("desc"))
    end)

    it("rejects invalid order direction", function()
        assert.has_error(function() validator.validateOrderDirection("UP") end)
        assert.has_error(function() validator.validateOrderDirection("DOWN") end)
    end)

    it("validates pagination", function()
        assert.is_true(validator.validatePagination(1, 20))
        assert.is_true(validator.validatePagination(5, 100))
    end)

    it("rejects invalid pagination", function()
        assert.has_error(function() validator.validatePagination(0, 20) end)
        assert.has_error(function() validator.validatePagination(-1, 20) end)
        assert.has_error(function() validator.validatePagination(1, 0) end)
        assert.has_error(function() validator.validatePagination(1, 2000) end)
    end)

    it("validates query length", function()
        assert.is_true(validator.validateQueryLength("SELECT * FROM users"))
    end)

    it("rejects long queries", function()
        local long_query = string.rep("a", 200000)
        assert.has_error(function() validator.validateQueryLength(long_query) end)
    end)

    it("validates parameter count", function()
        assert.is_true(validator.validateParameterCount({1, 2, 3}))
    end)

    it("rejects too many parameters", function()
        local many_params = {}
        for i = 1, 2000 do
            many_params[i] = i
        end
        assert.has_error(function() validator.validateParameterCount(many_params) end)
    end)
end)
