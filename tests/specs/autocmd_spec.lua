local ogmarks = require("ogmarks")
local util = require("tests.util")
local ogmarksUtil = require("ogmarks.util")
local spy = require("luassert.spy")
local vim = vim

describe("ogmarks autocmds", function ()
    local config = util:defaultConfig("loading ogmarks")
    config.projectDir = "/src/ogmarks.nvim/tests/dummy/"
    ogmarks:setup(config)
    ogmarks:createAutoCmds()
    ogmarks:loadProj("autocmd_spec")
    it("should autoload marks when opening files", function ()
        util:openLl(vim)
        local extMarks = vim.api.nvim_buf_get_extmarks(0, ogmarks._namespace, 0, -1, {})
        assert.are.same({
            {1, 1, 0},
            {2, 2, 0}
        }, extMarks)
    end)

    it("should update project file when saving the buffer", function()
        vim.cmd("norm 5O")
        vim.cmd("w")
                
    end)
end)