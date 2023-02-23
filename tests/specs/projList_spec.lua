local ogmarks = require("ogmarks")
local util = require("tests.util")
local ogmarksutil = require("ogmarks.util")

describe("project list", function ()
    local cfg = util.defaultConfig()
    cfg.projectDir = "/src/ogmarks.nvim/tests/dummy/"
    ogmarks:setup(cfg)
    
    it("should only show files with valid project file names", function()
        vim.cmd("redir @z")
        vim.cmd("OgMarksProjectList")
        vim.cmd("redir end")
        local output = vim.fn.getreg("z")
        local trimmed = ogmarksutil.trim(output)
        assert.are.same("autocmd_spec, ll, lorem, multifile", trimmed)
    end)
end)