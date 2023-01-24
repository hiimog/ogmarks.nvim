local M = {}
local vim = vim
local logLevels = {
    debug = true,
    info = true,
    warn = true,
    error = true,
    off = true,
}


function M.defaults()
    return {
        db = {
            file = vim.fn.stdpath("data") .. "/ogmarks.db",
        },
        logging = {
            file = vim.fn.stdpath("log") .. "/ogmarks.log",
            level = "warn",
        },
    }
end

function M.validate(config)
    config = config or {}
    config.db = config.db or {}
    config.logging = config.logging or {}
    local errors = {}
    if config.db.file and type(config.db.file) ~= "string" then table.insert(errors, "db.file must be a string") end
    if config.logging.file and type(config.db.file) ~= "string" then table.insert(errors, "logging.file must be a string") end
    if config.logging.level and logLevels[config.logging.level] == nil then table.insert(errors, "logging.level must be one of debug, info, warn, error, off") end
    return #errors > 0 and errors or nil
end

-- applies config to the defeaults
function M.apply(config)
    config = config or {}
    config.db = config.db or {}
    config.logging = config.logging or {}
    local choose = function(a, b)
        if a ~= nil then return a end
        return b
    end
    local defaults = M.defaults()
    defaults.db.file = choose(config.db.file, defaults.db.file)
    defaults.logging.file = choose(config.logging.file, defaults.db.file)
    defaults.logging.level = choose(config.logging.level, defaults.logging.level)
    return defaults
end