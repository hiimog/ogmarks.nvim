describe("delete", function ()
    local util = require("tests.util")
    local config = util:defaultConfig("delete")
    local og = require("ogmarks")(config)
    local sqlite = require("lsqlite3")
    local stringx = require("pl.stringx")
    local vim = vim
    require("tests.customAssertions")

    local function countById(id)
        local stmt = og._data._db:prepare("SELECT COUNT(*) FROM ogmark WHERE id = :id")
        stmt:bind_names({id = id})
        for count in stmt:urows() do 
            return count
        end
    end

    it("should error if deleting ogmark by id that does not exist", function ()
        util:openTextFile(vim, "lorem.txt")
        assert.has_error_like(function ()
            og:delete(2)
        end, function (e)
            return stringx.lfind(e or "", "Failed to delete") ~= nil
        end)
    end)

    it("should not error if trying to delete at current position, but no ogmark exists", function ()
        assert.has_no.error(function ()
            og:deleteHere()
        end)
    end)

    it("should remove ogmark from database on delete", function ()
        local ogMark = og:createHere()
        og:delete(ogMark.id)
        assert.are.same(0, countById(ogMark.id))
    end)

    it("should remove ogmark at the current line", function ()
        local ogMark = og:createHere()
        assert.is_not_nil(og._data:findOgMark(ogMark.id))
        og:deleteHere()
        assert.are.same(0, countById(ogMark.id))
    end)
end)