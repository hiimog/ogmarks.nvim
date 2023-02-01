local util = require("tests.util")
local vim = vim
describe("loading ogmarks", function()
    it("should load a mark from an existing database", function()
        local config = {
            db = {
                file = "tests/dbs/lorem_line_4.db"
            },
            logging = {
                file = util:createSpecLogName("should load a mark from an existing database"),
                level = "debug"
            }
        }
        local og = require("ogmarks")(config)
        og:focusOgMark(1)
        assert.are.same("mea ad idque decore docendi.", vim.fn.getline("."))
    end)

    it("should jump back and forth between marks on the same page", function()
        local config = {
            db = {
                file = "tests/dbs/lorem_line_4_8_10.db"
            },
            logging = {
                file = util:createSpecLogName("should jump back and forth between marks on the same page"),
                level = "debug"
            }
        }
        local og = require("ogmarks")(config)
        og:focusOgMark(1)
        assert.are.same("mea ad idque decore docendi.", vim.fn.getline("."))
        og:focusOgMark(2)
        assert.are.same("tincidunt. Ad exerci aperiam mel, ludus choro mediocrem sea ea, nec tacimates iudicabit in.", vim.fn.getline("."))
        og:focusOgMark(3)
        assert.are.same("Probo dicunt accusamus ei ius, quem error nullam ea sea, nam an blandit iracundia. Et mel latine probatus postulant. Amet zril cu mel, ea mea tempor sententiae, an reque gubergren nam.", vim.fn.getline("."))
    end)
end)