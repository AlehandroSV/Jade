describe("LuaLS Type Generation", function()
    local LuaLS = require("jade.types.luals")
    local Entity = require("jade.entity")
    local Integer = require("jade.types.integer")
    local String = require("jade.types.string")
    local Boolean = require("jade.types.boolean")
    local Timestamp = require("jade.types.timestamp")
    local Text = require("jade.types.text")

    local User
    local Post

    before_each(function()
        User = Entity.new("users", {
            id = Integer():primaryKey(),
            name = String(120),
            email = String():unique(),
            active = Boolean():default(true),
            bio = Text(),
            created_at = Timestamp():defaultNow(),
        })

        Post = Entity.new("posts", {
            id = Integer():primaryKey(),
            title = String(200),
            content = Text(),
            user_id = Integer(),
            published = Boolean():default(false),
            created_at = Timestamp():defaultNow(),
        })

        -- Add relations
        User:hasMany(Post)
        Post:belongsTo(User)
    end)

    describe("generateColumnType", function()
        it("generates type for integer column", function()
            local result = LuaLS.generateColumnType("id", { type = "integer" })
            assert.are.equal("---@field id number", result)
        end)

        it("generates type for string column", function()
            local result = LuaLS.generateColumnType("name", { type = "string" })
            assert.are.equal("---@field name string", result)
        end)

        it("generates type for boolean column", function()
            local result = LuaLS.generateColumnType("active", { type = "boolean" })
            assert.are.equal("---@field active boolean", result)
        end)

        it("generates type for text column", function()
            local result = LuaLS.generateColumnType("bio", { type = "text" })
            assert.are.equal("---@field bio string", result)
        end)

        it("generates type for timestamp column", function()
            local result = LuaLS.generateColumnType("created_at", { type = "timestamp" })
            assert.are.equal("---@field created_at string", result)
        end)

        it("generates type for unknown column", function()
            local result = LuaLS.generateColumnType("data", { type = "unknown" })
            assert.are.equal("---@field data any", result)
        end)
    end)

    describe("generateEntityType", function()
        it("generates entity class with columns", function()
            local result = LuaLS.generateEntityType(User)
            assert.is_truth(string.find(result, "---@class Users"))
            assert.is_truth(string.find(result, "---@field id number"))
            assert.is_truth(string.find(result, "---@field name string"))
            assert.is_truth(string.find(result, "---@field email string"))
            assert.is_truth(string.find(result, "---@field active boolean"))
        end)

        it("generates entity with relations", function()
            local result = LuaLS.generateEntityType(User)
            assert.is_truth(string.find(result, "posts"))
            assert.is_truth(string.find(result, "Post"))
        end)

        it("generates belongsTo relation as optional", function()
            local result = LuaLS.generateEntityType(Post)
            assert.is_truth(string.find(result, "users"))
            assert.is_truth(string.find(result, "Users"))
        end)
    end)

    describe("generateQueryType", function()
        it("generates query type alias", function()
            local result = LuaLS.generateQueryType(User)
            assert.are.equal("---@alias UsersQuery Query<Users>", result)
        end)
    end)

    describe("generateQueryMethods", function()
        it("generates query builder methods", function()
            local result = LuaLS.generateQueryMethods()
            assert.is_truth(string.find(result, "---@class Query<T>"))
            assert.is_truth(string.find(result, "where"))
            assert.is_truth(string.find(result, "orderBy"))
            assert.is_truth(string.find(result, "limit"))
            assert.is_truth(string.find(result, "get"))
            assert.is_truth(string.find(result, "first"))
            assert.is_truth(string.find(result, "find"))
            assert.is_truth(string.find(result, "count"))
        end)
    end)

    describe("generateConditionType", function()
        it("generates condition class", function()
            local result = LuaLS.generateConditionType()
            assert.is_truth(string.find(result, "---@class Condition"))
            assert.is_truth(string.find(result, "eq"))
            assert.is_truth(string.find(result, "neq"))
            assert.is_truth(string.find(result, "lt"))
            assert.is_truth(string.find(result, "gt"))
            assert.is_truth(string.find(result, "like"))
            assert.is_truth(string.find(result, "isNull"))
        end)
    end)

    describe("generateExpressionType", function()
        it("generates expression class", function()
            local result = LuaLS.generateExpressionType()
            assert.is_truth(string.find(result, "---@class Expression"))
            assert.is_truth(string.find(result, "eq"))
            assert.is_truth(string.find(result, "neq"))
        end)
    end)

    describe("generateInstanceType", function()
        it("generates instance type with columns", function()
            local result = LuaLS.generateInstanceType(User)
            assert.is_truth(string.find(result, "---@class UsersInstance"))
            assert.is_truth(string.find(result, "---@field id number"))
            assert.is_truth(string.find(result, "---@field name string"))
        end)

        it("generates instance with methods", function()
            local result = LuaLS.generateInstanceType(User)
            assert.is_truth(string.find(result, "save"))
            assert.is_truth(string.find(result, "destroy"))
            assert.is_truth(string.find(result, "update"))
            assert.is_truth(string.find(result, "toTable"))
        end)
    end)

    describe("generateEntityStaticType", function()
        it("generates static methods type", function()
            local result = LuaLS.generateEntityStaticType(User)
            assert.is_truth(string.find(result, "---@alias UsersStatic"))
            assert.is_truth(string.find(result, "create"))
            assert.is_truth(string.find(result, "update"))
            assert.is_truth(string.find(result, "delete"))
            assert.is_truth(string.find(result, "where"))
            assert.is_truth(string.find(result, "find"))
            assert.is_truth(string.find(result, "count"))
        end)
    end)

    describe("generateAll", function()
        it("generates complete type definitions", function()
            local result = LuaLS.generateAll({ User, Post })
            assert.is_truth(string.find(result, "---@meta"))
            assert.is_truth(string.find(result, "---@class Users"))
            assert.is_truth(string.find(result, "---@class Posts"))
            assert.is_truth(string.find(result, "---@class Query<T>"))
            assert.is_truth(string.find(result, "---@class Condition"))
            assert.is_truth(string.find(result, "---@class Expression"))
        end)

        it("generates all entity types", function()
            local result = LuaLS.generateAll({ User, Post })
            assert.is_truth(string.find(result, "---@class Users"))
            assert.is_truth(string.find(result, "---@class UsersInstance"))
            assert.is_truth(string.find(result, "---@alias UsersQuery"))
            assert.is_truth(string.find(result, "---@alias UsersStatic"))
            assert.is_truth(string.find(result, "---@class Posts"))
            assert.is_truth(string.find(result, "---@class PostsInstance"))
            assert.is_truth(string.find(result, "---@alias PostsQuery"))
            assert.is_truth(string.find(result, "---@alias PostsStatic"))
        end)
    end)
end)
