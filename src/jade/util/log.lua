local M = {}

local debug_mode = false

function M.setDebug(enabled)
    debug_mode = enabled
end

function M.sql(sql, bindings)
    if debug_mode then
        print("[SQL] " .. sql)
        if bindings and #bindings > 0 then
            print("[BINDINGS] " .. table.concat(bindings, ", "))
        end
    end
end

function M.info(msg)
    print("[INFO] " .. msg)
end

function M.error(msg)
    io.stderr:write("[ERROR] " .. msg .. "\n")
end

return M
