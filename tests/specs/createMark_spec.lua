---@diagnostic disable: duplicate-set-field
local ogmarks = require("ogmarks")
local util = require("tests.util")
local ogmarksUtil = require("ogmarks.util")
local spy = require("luassert.spy")
local vim = vim

describe("marking lines", function ()
    local config = util:defaultConfig("marking lines")
    ogmarks:setup(config)

    it("should error if there is no active project", function ()
        assert.has_error(function ()
            ogmarks:newMark()
        end, "ogmarks can only be created for active projects")
    end)

    ogmarks:newProj("marking_lines")
    local goodTimestamp = ogmarksUtil.timestamp
    ogmarksUtil.timestamp = function() return "42" end
    it("should create a mark at the current position", function ()
        util:openLorem(vim)
        local saveSpy = spy.on(ogmarks,"save")
        local mark = ogmarks:newMark()
        assert.are.same({
            id = 1,
            absPath = "/src/ogmarks.nvim/tests/text/lorem.txt",
            name = nil,
            row = 0,
            rowText = "Lorem ipsum dolor sit amet, admodum urbanitas qui ne, explicari reprimique ius te. Quodsi suscipit iracundia ad eum. Dicit vocibus contentiones in usu, ",
            description = nil,
            created = "42",
            updated = "42"
        }, mark)

        local extMarks = vim.api.nvim_buf_get_extmarks(0, ogmarks._namespace, 0, -1, {details = false})
        assert.are.same(1, #extMarks)
        assert.spy(saveSpy).was.called()
    end)
end)