return function(config)
    local logger = {}
    logger._file = io.open(config.logging.file, "a+")
    logger._level = config.logging.level
    logger._levels = {
        off = 0,
        debug = 1,
        info = 2,
        warn = 3,
        error = 4,
    }
    local function log(level, msg)
        if  logger._levels[level] < logger._levels[logger._level] then return end
        logger._file:write(msg)
        logger._file:flush()
    end

    function logger:debug(msg) log("debug", msg) end
    function logger:info(msg) log("info", msg) end
    function logger:warn(msg) log("warn", msg) end
    function logger:error(msg) log("error", msg) end
    
    return logger
end