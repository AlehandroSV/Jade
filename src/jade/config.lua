local M = {}

local config = nil

function M.load(path)
    local config_path = path or "jade.config.lua"
    local loader, err = loadfile(config_path)
    if not loader then
        error("Failed to load config: " .. tostring(err))
    end
    config = loader()
    return config
end

function M.get()
    if not config then
        error("Jade not configured. Call jade.configure() first.")
    end
    return config
end

function M.set(new_config)
    config = new_config
end

return M
