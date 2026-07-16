describe("Pagination", function()
    local paginate = require("jade.query.paginate")

    it("calculates pagination metadata", function()
        local result = paginate.paginate(nil, {
            page = 2,
            perPage = 10,
            total = 55,
        })
        assert.are.equal(2, result.page)
        assert.are.equal(10, result.per_page)
        assert.are.equal(55, result.total)
        assert.are.equal(6, result.last_page)
        assert.is_true(result.has_next)
        assert.is_true(result.has_prev)
    end)

    it("first page has no prev", function()
        local result = paginate.paginate(nil, {
            page = 1,
            perPage = 10,
            total = 55,
        })
        assert.is_false(result.has_prev)
        assert.is_true(result.has_next)
    end)

    it("last page has no next", function()
        local result = paginate.paginate(nil, {
            page = 6,
            perPage = 10,
            total = 55,
        })
        assert.is_true(result.has_prev)
        assert.is_false(result.has_next)
    end)

    it("returns next page number", function()
        local result = { page = 2, has_next = true }
        assert.are.equal(3, paginate.nextPage(result))
    end)

    it("returns nil for last page next", function()
        local result = { page = 6, has_next = false }
        assert.is_nil(paginate.nextPage(result))
    end)

    it("returns previous page number", function()
        local result = { page = 3, has_prev = true }
        assert.are.equal(2, paginate.prevPage(result))
    end)

    it("returns nil for first page prev", function()
        local result = { page = 1, has_prev = false }
        assert.is_nil(paginate.prevPage(result))
    end)

    it("defaults to page 1 and 20 per page", function()
        local result = paginate.paginate(nil, { total = 100 })
        assert.are.equal(1, result.page)
        assert.are.equal(20, result.per_page)
        assert.are.equal(5, result.last_page)
    end)
end)
