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
    return function(self, msg, ...)
        if levels[level] < levels[M.level] then return end
        local body = string.format(msg, ...)
        self._file:write(level .. ":" .. util.timestamp() .. ":" .. body .. "\n")
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

function M:assert(condition, errMsg)
    if not condition then 
        self:error(errMsg)
        assert(condition, errMsg)
    end
end

function M:init()
    self._file = assert(io.open(config.logging.file, "a"))
end

return M
