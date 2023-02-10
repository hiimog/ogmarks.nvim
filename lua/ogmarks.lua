local config = require("ogmarks.config")
local data = require("ogmarks.data")
local log = require("ogmarks.log")
local M = {}

function M:setup(values)
    if values == nil then return end
    assert(type(values) == "table", "values must be a table")
    values.logging = values.logging or {}
    if values.logging.level ~= nil then config.logging.level = values.logging.level end
    if values.logging.file ~= nil then config.logging.file = values.logging.file end
    if values.projectDir ~= nil then config.projectDir = values.projectDir end
    log:init()
    log:info("ogmarks starting")
    data:init()
end

function M:load(project)
    log:info("Loading project: %s", project)
    if data.project then
        data:save()
    end
    data:load(project)
end

return M
