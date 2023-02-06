describe("delete", function ()
    local util = require("tests.util")
    local config = util:defaultConfig("delete")
    local og = require("ogmarks")(config)
    local sqlite = require("lsqlite3")
    local stringx = require("pl.stringx")
    local vim = vim
    require("tests.customAssertions")

    it("should error if trying to delete ogmark by id that does not exist", function ()
        util:openTextFile(vim, "lorem.txt")
        assert.has_error_like(function ()
            og:delete(2)
        end, function (e)
            return stringx.lfind(e or "", "Failed to delete") ~= nil
        end)
    end)
end)