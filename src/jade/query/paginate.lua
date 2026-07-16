local M = {}

function M.paginate(query, options)
    options = options or {}
    local page = options.page or 1
    local per_page = options.perPage or 20
    local total = options.total

    -- Calculate offset
    local offset = (page - 1) * per_page

    local items = {}

    -- Only query if query is provided
    if query then
        -- Get total count if not provided
        if not total then
            total = query:count()
        end

        -- Get items for this page
        items = query:limit(per_page):offset(offset):get()
    else
        -- Use provided total or default
        total = total or 0
    end

    -- Calculate last page
    local last_page = math.ceil(total / per_page)

    return {
        items = items,
        total = total,
        page = page,
        per_page = per_page,
        last_page = last_page,
        has_next = page < last_page,
        has_prev = page > 1,
    }
end

function M.nextPage(result)
    if result.has_next then
        return result.page + 1
    end
    return nil
end

function M.prevPage(result)
    if result.has_prev then
        return result.page - 1
    end
    return nil
end

return M
