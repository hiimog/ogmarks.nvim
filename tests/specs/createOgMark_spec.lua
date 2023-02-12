local ogmarks = require("ogmarks")
local util = require("tests.util")
local ogmarksUtil = require("ogmarks.util")
local vim = vim

describe("marking lines", function ()
    local config = util:defaultConfig("marking lines")
    ogmarks:setup(config)
    ogmarks:new("marking_lines")
    it("should create a mark at the current position", function ()
        util:openLorem(vim)
        local goodTimestamp = ogmarksUtil.timestamp
        ogmarksUtil.timestamp = function() return "42" end
        local mark = ogmarks:markHere()
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
    end)
end)