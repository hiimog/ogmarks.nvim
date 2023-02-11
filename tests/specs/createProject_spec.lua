local ogmarks = require("ogmarks")
local util = require("tests.util")

describe("project creation", function()
    local config = util:defaultConfig("project creation")
    ogmarks:setup(config)
    local projectNameMustBeLike = "can only contain alpha numeric, '-' and '_' characters"
    it("should error if invalid name is given", function()
        local testCases = {
            {nil, "cannot be nil"},
            {"", "must have a length"},
            {" ", "cannot contain spaces"},
            {"*", projectNameMustBeLike},
            {"$", projectNameMustBeLike},
            {"foo bar", "cannot contain spaces"},
        }
        for caseNum, testCase in ipairs(testCases) do
            local projectName, because = table.unpack(testCase)
            local isGood, err = pcall(function() ogmarks:new(projectName) end)
            assert.is_false(isGood, string.format("%d: Project name %s", caseNum, because))
            assert.not_nil(string.find(err or "", "Project name"), string.format("%d: Error should mention project name but got %s", caseNum, err))
        end
    end)
end)
