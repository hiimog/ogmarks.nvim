local config = require("ogmarks.config")
local M = {}

function M:setup(values)
    if values == nil then return end
    assert(type(values) == "table", "values must be a table")
    values.logging = values.logging or {}
    if values.logging.level ~= nil then config.logging.level = values.logging.level end
    if values.logging.file ~= nil then config.logging.file = values.logging.file end
end

return M