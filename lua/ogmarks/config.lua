local s = require("thirdparty.schema")
local Set = require("pl.Set")
local M = {}

local configSchema = s.Record {
    db = s.Record {
        file = s.String,
    },
    logging = s.Record {
        file = s.String,
        level = s.OneOf("off", "debug", "info", "warn", "error"),
    }
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
    local err = s.CheckSchema(config, configSchema)
    if err then return false, err end
    return true, nil
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

return M