return function(config)
    local M = {}
    local file, err = io.open(config.logging.file, "a+")
    if err then return nil, "Failed to open log file: " .. err end
    M._file = file
    M._level = config.logging.level
    M._levels = {
        off = 0,
        debug = 1,
        info = 2,
        warn = 3,
        error = 4,
    }
    function M:_log(level, msg, ...)
        if  M._levels[level] < M._levels[M._level] then return end
        M._file:write(string.format(msg, ...))
        M._file:flush()
    end

    function M:debug(msg, ...) self:_log("debug", msg, ...) end
    function M:info(msg, ...) self:_log("info", msg, ...) end
    function M:warn(msg, ...) self:_log("warn", msg, ...) end
    function M:error(msg, ...) self:_log("error", msg, ...) end
    function M:assert(res, err)
        if err then self:error(err) end
        return assert(res, err)
    end
    return M, nil
end