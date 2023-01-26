local s = require("ogmarks.schema")
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
            file = "/tmp/ogmarks.db",
        },
        logging = {
            file = "/tmp/ogmarks.log",
            level = "debug",
        },
    }
end

function M.validate(config)
    local err = s.CheckSchema(config, configSchema)
    if err then return false, err end
    return true, nil
end

-- applies config to the defeaults
function M.create(config)
    config = config or {}
    config.db = config.db or {}
    config.logging = config.logging or {}
    local choose = function(a, b)
        if a ~= nil then return a end
        return b
    end
    local defaults = M.defaults()
    defaults.db.file = choose(config.db.file, defaults.db.file)
    defaults.logging.file = choose(config.logging.file, defaults.logging.file)
    defaults.logging.level = choose(config.logging.level, defaults.logging.level)
    return defaults
end

return M