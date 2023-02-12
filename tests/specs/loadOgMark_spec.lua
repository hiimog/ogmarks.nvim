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
        ogmarks:load("lorem")
        util:openLorem(vim)
        ogmarks:loadForBuf(0)
        local extmarks = vim.api.nvim_buf_get_extmarks(0, ogmarks._namespace, 0, -1, {details = false})
        assert.are.same(3, #extmarks)
    end)
end)