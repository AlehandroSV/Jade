local Events = {}

-- Global event handlers registry
local global_handlers = {}

-- Track registered event names per entity
local entity_events = {}

--- Register a global event handler
--- @param event_name string The event name (e.g. "user.created")
--- @param handler function The handler function
function Events.on(event_name, handler)
    if not global_handlers[event_name] then
        global_handlers[event_name] = {}
    end
    table.insert(global_handlers[event_name], handler)
end

--- Define custom events for an entity
--- @param entity table The entity to define events for
--- @param event_names table Array of event name strings
function Events.define(entity, event_names)
    local key = entity._table
    if not entity_events[key] then
        entity_events[key] = {}
    end
    for _, name in ipairs(event_names) do
        entity_events[key][name] = true
    end
    entity._events = entity_events[key]
end

--- Fire an event
--- @param entity table The entity firing the event
--- @param event_name string The event name
--- @param data table The event data
function Events.fire(entity, event_name, data)
    data = data or {}
    local full_name = entity._table .. "." .. event_name

    local handlers = global_handlers[full_name]
    if handlers then
        for _, handler in ipairs(handlers) do
            local ok, err = pcall(handler, data)
            if not ok then
                error("Event handler error (" .. full_name .. "): " .. tostring(err))
            end
        end
    end
end

--- Remove all event handlers (useful for testing)
function Events.clear()
    global_handlers = {}
    entity_events = {}
end

return Events
