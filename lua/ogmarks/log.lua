local config = require("ogmarks.config")
local util = require("ogmarks.util")
local M = {
    _file = nil,
    _level = nil,
}

local levels = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4, 
    off = 5
}

local function makeLogFunc(level)
    return function(self, msg, ...)
        if levels[level] < levels[self._level] then return end
        local body = nil 
        if type(msg) == "function" then 
            body = msg()
        else 
            body = string.format(msg, ...)
        end
        self._file:write(level .. ":" .. util.timestamp() .. ":" .. body .. "\n")
        self._file:flush()
    end
end

M.debug = makeLogFunc("debug")
M.info = makeLogFunc("info")
M.warn = makeLogFunc("warn")
M.error = makeLogFunc("error")

function M:setLevel(level)
    assert(levels[level], string.format("Invalid log level: %s", level))
    self._level = level
end

function M:assert(condition, errMsg, ...)
    if not condition then 
        self:error(errMsg, ...)
        errMsg = string.format(errMsg, ...)
        assert(condition, errMsg)
    end
end

function M:init()
    self._file = assert(io.open(config.logging.file, "a"))
    self._level = config.logging.level
end

function M:dispose()
    if not self._file then return end
    self._file:close()
    self._file = nil
    self:setLevel("off")
end

return M
