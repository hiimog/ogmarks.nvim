local ogmarks = require("ogmarks")
local util = require("tests.util")
local ogmarksUtil = require("ogmarks.util")
local spy = require("luassert.spy")
local vim = vim

describe("loading ogmarks", function ()
    local config = util:defaultConfig("loading ogmarks")
    config.projectDir = "/src/ogmarks.nvim/tests/dummy/"
    ogmarks:setup(config)
    it("should be able to load all marks for buffer", function ()
        ogmarks:loadProj("lorem")
        util:openLorem(vim)
        ogmarks:bufLoad(0)
        local extmarks = vim.api.nvim_buf_get_extmarks(0, ogmarks._namespace, 0, -1, {details = false})
        assert.are.same(3, #extmarks)
    end)

    util:delAllBuf(vim)

    it("should open the file and go to the line when loading a specific mark", function ()
        ogmarks:loadProj("ll")
        ogmarks:loadMark(2)
        local line = vim.fn.getline(".")
        assert.are.same("drwxrwxr-x 9 og og 4.0K Jan 30 21:22 .git/", line)
    end)
end)