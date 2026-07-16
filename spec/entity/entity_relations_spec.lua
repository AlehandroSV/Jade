describe("Entity with Relations", function()
    local Entity = require("jade.entity")
    local Integer = require("jade.types.integer")
    local String = require("jade.types.string")

    local User
    local Post

    before_each(function()
        User = Entity.new("users", {
            id = Integer():primaryKey(),
            name = String(120),
        })

        Post = Entity.new("posts", {
            id = Integer():primaryKey(),
            title = String(255),
            user_id = Integer(),
        })
    end)

    it("registers belongsTo relation", function()
        Post:belongsTo(User)
        assert.is_not_nil(Post._relations["users"])
        assert.are.equal("belongsTo", Post._relations["users"].type)
    end)

    it("registers hasMany relation", function()
        User:hasMany(Post)
        assert.is_not_nil(User._relations["posts"])
        assert.are.equal("hasMany", User._relations["posts"].type)
    end)

    it("registers hasOne relation", function()
        User:hasOne(Post)
        assert.is_not_nil(User._relations["posts"])
        assert.are.equal("hasOne", User._relations["posts"].type)
    end)

    it("registers foreignKey relation", function()
        Post:foreignKey(User)
        assert.is_not_nil(Post._relations["users"])
        assert.are.equal("foreign_key", Post._relations["users"].type)
    end)

    it("chains multiple relation definitions", function()
        local Comment = Entity.new("comments", {
            id = Integer():primaryKey(),
            body = String(),
            post_id = Integer(),
        })

        Comment:belongsTo(Post)
        Comment:belongsTo(User)

        assert.is_not_nil(Comment._relations["posts"])
        assert.is_not_nil(Comment._relations["users"])
    end)
end)
