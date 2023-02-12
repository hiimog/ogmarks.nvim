local ogmarks = require("ogmarks")
local util = require("tests.util")
local ogmarksUtil = require("ogmarks.util")
local spy = require("luassert.spy")
local vim = vim

describe("loading projects", function ()
    local config = util:defaultConfig("loading ogmarks")
    config.projectDir = "/src/ogmarks.nvim/tests/dummy/"
    ogmarks:setup(config)
    it("", function ()
        ogmarks:load("lorem")
    end)
end)