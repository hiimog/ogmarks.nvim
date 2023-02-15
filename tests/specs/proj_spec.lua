local ogmarks = require("ogmarks")
local util = require("tests.util")

describe("project", function ()
    local cfg = util.defaultConfig()
    ogmarks:setup(cfg)
    it("should error if creating a new project with the same name as an existing project", function ()
        
    end)
end)