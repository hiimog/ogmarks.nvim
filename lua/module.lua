local logFac = require("ogmarks.log")
local config = require("ogmarks.config")

return function(cfg)
    local errors = config.validate(cfg)
    assert(errors, table.concat(errors, ", "))
    cfg = config.apply(cfg)

    local log = logFac(cfg)
end