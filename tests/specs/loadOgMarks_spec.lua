local util = require("tests.util")
local vim = vim
describe("loading ogmarks", function()
    it("should load a mark from an existing database", function()
        local config = {
            db = {
                file = "tests/dbs/lorem_line_4.db"
            },
            logging = {
                file = util:createSpecLogName("should create an ogmark"),
                level = "debug"
            }
        }
        local og = require("ogmarks")(config)
        og:focusOgMark(1)
        assert.are.same("mea ad idque decore docendi.", vim.fn.getline("."))
    end)
end)