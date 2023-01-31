local util = require("tests.util")

describe("create marks", function() 
    it("should create an ogmark", function()
        local config = {
            db = {
                file = util:createSpecDbName("should create an ogmark")
            },
            log = {
                file = util:createSpecLogName("should create an ogmark")
            }
        }
        local og = require("ogmarks")(config)
        vim.cmd(":e tests/text/lorem.txt")
    end)
end)