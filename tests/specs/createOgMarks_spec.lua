local util = require("tests.util")
require("tests.customAssertions")

describe("creating marks", function() 
    local sqlite = require("lsqlite3")
    local stringx = require("pl.stringx")

    it("should create an ogmark in the configured database", function()
        local config = util:defaultConfig("should create an ogmark in the configured database")
        local og = require("ogmarks")(config)
        -- load lorem ipsum
        util:openTextFile(vim, "lorem.txt")

        -- goto the 4th line: mea ad idque decore docendi.
        util:setCursor(vim, 4, 0)

        -- create the ogmark
        local ogMark = og:createOgMarkAtCurPos({
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

    it("should error when trying to create a mark out of bounds", function()
        local config = util:defaultConfig("should error when trying to create a mark out of bound")
        local og = require("ogmarks")(config)
        util:openTextFile(vim, "countries.txt")
        local badOgMark = {
            absolutePath = vim.api.nvim_buf_get_name(0),
            row = 9999,
            rowText = "",
            name = "bad",
        }
        assert.has_error_like(function() og:createOgMark(badOgMark) end, function (e) return stringx.lfind(e, "Failed to create extmark") >= 0 end)
    end)
end)