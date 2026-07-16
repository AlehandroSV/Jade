local M = {}

-- Lua version detection
M.isLua51 = (string.find(_VERSION, "5.1") ~= nil)
M.isLuaJIT = (jit ~= nil)
M.isLua52Plus = not M.isLua51

-- Polyfills for Lua 5.1
if not table.pack then
    function table.pack(...)
        return { n = select("#", ...), ... }
    end
end

if not table.unpack then
    table.unpack = unpack
end

-- Safe unpack that respects table.n
function M.unpack(t, i, j)
    i = i or 1
    j = j or t.n or #t
    return table.unpack(t, i, j)
end

return M
