local logFac = require("ogmarks.log")
local config = require("ogmarks.config")

return function(cfg)
    cfg = config.apply(cfg)
    local errors = config.validate(cfg)
    assert(errors == nil, errors)

    local log = logFac(cfg)
    log:info("hello!")
end