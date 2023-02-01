local util = require("tests.util")

describe("creating marks", function() 
    it("should create an ogmark in the configured database", function()
        local sqlite = require("lsqlite3")
        local config = {
            db = {
                file = util:createSpecDbName("should create an ogmark")
            },
            logging = {
                file = util:createSpecLogName("should create an ogmark"),
                level = "debug"
            }
        }
        local og = require("ogmarks")(config)
        -- load lorem ipsum
        vim.cmd(":e tests/text/lorem.txt")

        -- goto the 4th line: mea ad idque decore docendi.
        vim.api.nvim_win_set_cursor(0, {4, 0})

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
end)