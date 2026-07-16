describe("i18n", function()
    local i18n = require("jade.i18n")

    before_each(function()
        i18n.setLocale("en")
    end)

    it("has default locale", function()
        assert.are.equal("en", i18n.getLocale())
    end)

    it("can change locale", function()
        i18n.setLocale("pt-br")
        assert.are.equal("pt-br", i18n.getLocale())
    end)

    it("translates to English", function()
        i18n.setLocale("en")
        assert.are.equal("No active transaction", i18n.t("transaction_not_active"))
    end)

    it("translates to Portuguese", function()
        i18n.setLocale("pt-br")
        assert.are.equal("Nenhuma transação ativa", i18n.t("transaction_not_active"))
    end)

    it("formats string with arguments", function()
        i18n.setLocale("en")
        local result = i18n.t("driver_not_found", "mysql")
        assert.are.equal("Unknown driver: mysql", result)
    end)

    it("falls back to English", function()
        i18n.setLocale("fr")
        local result = i18n.t("transaction_not_active")
        assert.are.equal("No active transaction", result)
    end)

    it("returns key if not found", function()
        i18n.setLocale("en")
        local result = i18n.t("nonexistent_key")
        assert.are.equal("nonexistent_key", result)
    end)

    it("shorthand t works", function()
        i18n.setLocale("en")
        assert.are.equal("No active transaction", i18n.t("transaction_not_active"))
    end)
end)
