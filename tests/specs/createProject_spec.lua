local ogmarks = require("ogmarks")
local util = require("util")


describe("project creation", function()
    local config = util:defaultConfig("project creation")
    ogmarks:setup(config)
    it("should error if no name is given", function()

    end)
end)
