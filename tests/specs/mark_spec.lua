local ogmarks = require("ogmarks")
local util = require("tests.util")
local ogmarksutil = require("ogmarks.util")
local customAssert = require("tests.customAssertions")

describe("mark create", function ()
    local cfg = util.defaultConfig()
    ogmarks:setup(cfg)
    
    vim.cmd("OgMarksProjectCreate markcreate")

    it("should create a mark at current active cursor", function ()
        util.lorem(5)
        vim.cmd("OgMarksMarkCreate the fifth line")
        assert.are.same(1, #ogmarks._proj.ogmarks)
        assert.are.same(4, ogmarks._proj.ogmarks[1].row)
        assert.are.same("the fifth line", ogmarks._proj.ogmarks[1].desc)
            
        local expected = {
            row = 4,
            rowText = "",
            absPath = "/src/ogmarks.nvim/tests/text/lorem.txt",
            desc = "the fifth line",
            created = "42",
            updated = "43",
            id = 1,
        }
    end)
end)