local Relations = {}

function Relations.ForeignKey(target_entity, options)
    options = options or {}
    local foreign_key = options.foreign_key
    if not foreign_key then
        -- Convention: singularized target table name + _id
        local inflection = require("jade.util.inflection")
        foreign_key = inflection.singularize(target_entity._table) .. "_id"
    end

    return {
        type = "foreign_key",
        target = target_entity,
        foreign_key = foreign_key,
        onDelete = options.onDelete or "CASCADE",
        onUpdate = options.onUpdate or "CASCADE",
    }
end

function Relations.hasMany(source_entity, target_entity, options)
    options = options or {}
    local foreign_key = options.foreign_key
    if not foreign_key then
        local inflection = require("jade.util.inflection")
        foreign_key = inflection.singularize(source_entity._table) .. "_id"
    end

    return {
        type = "hasMany",
        source = source_entity,
        target = target_entity,
        foreign_key = foreign_key,
    }
end

function Relations.hasOne(source_entity, target_entity, options)
    options = options or {}
    local foreign_key = options.foreign_key
    if not foreign_key then
        local inflection = require("jade.util.inflection")
        foreign_key = inflection.singularize(source_entity._table) .. "_id"
    end

    return {
        type = "hasOne",
        source = source_entity,
        target = target_entity,
        foreign_key = foreign_key,
    }
end

function Relations.belongsTo(target_entity, options)
    options = options or {}
    local foreign_key = options.foreign_key
    if not foreign_key then
        local inflection = require("jade.util.inflection")
        foreign_key = inflection.singularize(target_entity._table) .. "_id"
    end

    return {
        type = "belongsTo",
        target = target_entity,
        foreign_key = foreign_key,
    }
end

return Relations
