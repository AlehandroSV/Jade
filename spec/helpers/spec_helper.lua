local function add_src_to_path()
    local script_path = debug.getinfo(1, "S").source:sub(2)
    local dir = script_path:match("(.*[/\\])")
    package.path = dir .. "../../src/?.lua;" .. package.path
    package.path = dir .. "../../src/?/init.lua;" .. package.path
end

add_src_to_path()
