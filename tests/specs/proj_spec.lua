local ogmarks = require("ogmarks")
local util = require("tests.util")
local ogmarksutil = require("ogmarks.util")

describe("project create", function ()
    local cfg = util.defaultConfig()
    ogmarks:setup(cfg)
    
    it("should create a project using a single positional value", function ()
        ogmarks:cmdProjectCreate({
            fargs = {"test"}
        })
        local path = cfg.projectDir.."/test.json"
        local exists = ogmarksutil.fileExists(path)
        assert.is_true(exists)
    end)

    it("should error if creating a new project with the same name as an existing project", function ()
        
    end)
end)