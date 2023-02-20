local ogmarks = require("ogmarks")
local util = require("tests.util")
local ogmarksutil = require("ogmarks.util")

describe("mark create", function ()
    local cfg = util.defaultConfig()
    ogmarks:setup(cfg)
    ogmarksutil._timestamp = "1"
    vim.cmd("OgMarksProjectCreate markcreate")

    it("should create a mark at current active cursor", function ()
        util.lorem(5)
        vim.cmd("OgMarksMarkCreate the fifth line")
        
        local expected = {
            row = 4,
            rowText = "Postea oblique nam ex. Eum dictas eirmod ex, ut putant malorum liberavisse eos. Utamur officiis maiestatis qui cu, ne diam augue possit sed. ",
            absPath = "/src/ogmarks.nvim/tests/text/lorem.txt",
            desc = "the fifth line",
            created = "1",
            updated = "1",
            id = 1,
        }

        assert.are.same(expected, ogmarks._proj.ogmarks[1])
    end)
end)