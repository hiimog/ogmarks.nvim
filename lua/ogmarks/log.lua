local config = require("ogmarks.config")
local util = require("ogmarks.util")
local M = {}

local levels = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4, 
    off = 5
}

M.level = "debug"

local function makeLogFunc(level)
    return function(msg, ...)
        if levels[level] < levels[M.level] then return end
        M.file:write(string.format(msg, ...))
    end
end

M.debug = makeLogFunc("debug")
M.info = makeLogFunc("info")
M.warn = makeLogFunc("warn")
M.error = makeLogFunc("error")
function M:setLevel(level)
    assert(levels[level], string.format("Invalid log level: %s", level))
    self.level = level
end

return M