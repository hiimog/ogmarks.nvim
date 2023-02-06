local util = require("tests.util")
require("tests.customAssertions")

describe("creating marks", function() 
    local sqlite = require("lsqlite3")
    local stringx = require("pl.stringx")
    before_each(function() util:delAllBuf(vim) end)
    it("should create an ogmark in the configured database", function()
        local config = util:defaultConfig("should create an ogmark in the configured database")
        local og = require("ogmarks")(config)
        -- load lorem ipsum
        util:openTextFile(vim, "lorem.txt")

        -- goto the 4th line: mea ad idque decore docendi.
        util:setCursor(vim, 4, 0)

        -- create the ogmark
        local ogMark = og:createHere({
            name = "a title",
            description = "an ogmark created for a test",
            tags = {
                "foo",
                "bar"
            }
        })
        assert.is_not_nil(ogMark)
---@diagnostic disable-next-line: need-check-nil
        assert.are.same(ogMark.id, 1)
        assert.are.same(ogMark.rowText, "mea ad idque decore docendi.")
        assert.are.same(ogMark.tags, {"foo", "bar"})
        og:dispose()

        local db = sqlite.open(config.db.file)
        local stmt = db:prepare("SELECT * FROM ogmark;")
        stmt:step()
        local values = stmt:get_named_values()
        
        values.tags = {}
        for tag in db:urows("SELECT t.name FROM tag t JOIN ogmarkTag ot ON t.id = ot.tagId WHERE ot.ogmarkId = 1;") do
            table.insert(values.tags, tag)
        end
        assert.are.same(ogMark, values)
    end)

    describe("out of bounds", function()
        local config = util:defaultConfig("out of bounds")
        local og = require("ogmarks")(config)
        util:openTextFile(vim, "countries.txt")
        local badOgMark = {
            absolutePath = vim.api.nvim_buf_get_name(0),
            row = 9999,
            rowText = "",
            name = "bad",
        }
        it("should should error with a message about creating extmark", function ()
            assert.has_error_like(function() og:create(badOgMark) end, function (e) 
                return stringx.lfind(e, "Failed to create extmark") ~= nil 
            end)
        end)
        it("should not have the mark in the database", function ()
            local db = sqlite.open(config.db.file)
            for count in db:urows("SELECT COUNT(*) FROM ogmark;") do
                assert.are.equal(0, count)
            end
        end)
    end)

    it("should fail for buffers not backed by a file", function()
        local config = util:defaultConfig("should fail for buffers not backed by file")
        local og = require("ogmarks")(config)
        vim.cmd("enew")
        assert.has_error(function() og:createHere() end, "OgMarks can only be created for files")
    end)
end)