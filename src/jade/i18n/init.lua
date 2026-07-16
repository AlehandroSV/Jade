local M = {}

local current_locale = "en"
local translations = {}

function M.setLocale(locale)
    current_locale = locale
    translations = {}
end

function M.getLocale()
    return current_locale
end

function M.load(locale)
    local path = "jade.i18n." .. locale
    local ok, data = pcall(require, path)
    if ok then
        translations[locale] = data
    else
        -- Fallback to English
        if locale ~= "en" then
            M.load("en")
        end
    end
end

function M.translate(key, ...)
    -- Load translations if not loaded
    if not translations[current_locale] then
        M.load(current_locale)
    end

    local template = translations[current_locale] and translations[current_locale][key]
    if not template then
        -- Fallback to English
        if not translations["en"] then
            M.load("en")
        end
        template = translations["en"] and translations["en"][key]
    end

    if not template then
        return key
    end

    -- Format with arguments
    local args = { ... }
    if #args > 0 then
        -- Use unpack for Lua 5.1, table.unpack for 5.2+
        local unpack_fn = table.unpack or unpack
        return template:format(unpack_fn(args))
    end

    return template
end

-- Shorthand
M.t = M.translate

return M
