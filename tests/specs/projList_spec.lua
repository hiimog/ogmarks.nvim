local ogmarks = require("ogmarks")
local util = require("tests.util")
local ogmarksutil = require("ogmarks.util")

describe("project list", function ()
    local cfg = util.defaultConfig()
    cfg.projectDir = "/src/ogmarks.nvim/tests/dummy/"
    ogmarks:setup(cfg)
    
    it("should only show files with valid project file names", function()
        
    end)
end)