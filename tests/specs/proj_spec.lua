local ogmarks = require("ogmarks")
local util = require("tests.util")
local ogmarksutil = require("ogmarks.util")
local customAssert = require("tests.customAssertions")

describe("project create", function ()
    local cfg = util.defaultConfig()
    ogmarks:setup(cfg)
    
    it("should create a project using a single positional value", function ()
        vim.cmd("OgMarksProjectCreate test")
        local path = cfg.projectDir.."/test.json"
        local exists = ogmarksutil.fileExists(path)
        assert.is_true(exists)
    end)

    ogmarks:_nuke()
    ogmarks:setup(cfg)

    it("should error if trying to create a duplicate project", function ()
        assert.has_error_like(function()
            vim.cmd("OgMarksProjectCreate test")
        end, function(err)
            return string.find(err, "Project already exists") ~= nil
        end)
    end)

    it("should load an existing project by name", function ()
        vim.cmd("OgMarksProjectLoad test")
        assert.not_nil(ogmarks._projFile)
        assert.are.same("test", ogmarks._proj.name)
        assert.are.same("/tmp/test.json", ogmarks._projFile)
    end)
    
    ogmarks:_nuke()
    cfg.projectDir = "/src/ogmarks.nvim/tests/dummy/"
    ogmarks:setup(cfg)

    it("should open all ogmarks in a project if using --openall", function ()
        vim.cmd("OgMarksProjectLoad --openall multifile")
        local bufCount = #vim.api.nvim_list_bufs()
        assert.are.same(bufCount, 2)
    end)
end)