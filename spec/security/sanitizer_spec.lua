describe("Security - SQL Injection Detection", function()
    local sanitizer = require("jade.security.sanitizer")

    it("detects simple SQL injection", function()
        local is_dangerous = sanitizer.detectSQLInjection("' OR '1'='1")
        assert.is_true(is_dangerous)
    end)

    it("detects UNION injection", function()
        local is_dangerous = sanitizer.detectSQLInjection("1 UNION SELECT * FROM users")
        assert.is_true(is_dangerous)
    end)

    it("detects DROP TABLE injection", function()
        local is_dangerous = sanitizer.detectSQLInjection("'; DROP TABLE users; --")
        assert.is_true(is_dangerous)
    end)

    it("detects comment injection", function()
        local is_dangerous = sanitizer.detectSQLInjection("1'--")
        assert.is_true(is_dangerous)
    end)

    it("allows normal strings", function()
        local is_dangerous = sanitizer.detectSQLInjection("John Doe")
        assert.is_false(is_dangerous)
    end)

    it("allows strings with quotes", function()
        local is_dangerous = sanitizer.detectSQLInjection("It's a test")
        assert.is_false(is_dangerous)
    end)

    it("allows numbers", function()
        local is_dangerous = sanitizer.detectSQLInjection(123)
        assert.is_false(is_dangerous)
    end)

    it("detects SLEEP injection", function()
        local is_dangerous = sanitizer.detectSQLInjection("1' AND SLEEP(5)--")
        assert.is_true(is_dangerous)
    end)

    it("detects BENCHMARK injection", function()
        local is_dangerous = sanitizer.detectSQLInjection("1' AND BENCHMARK(1000000,SHA1('test'))--")
        assert.is_true(is_dangerous)
    end)
end)
