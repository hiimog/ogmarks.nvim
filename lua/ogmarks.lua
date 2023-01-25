local logFac = require("ogmarks.log")
local cfg = require("ogmarks.config")
local dataFac = require("ogmarks.data")

return function(config)
    local M = {}
    M.config = cfg.apply(config)
    assert(cfg.validate(config))

    M.log = logFac(config)
    M.log:info("ogmarks plugin loading")

    local data = assert(dataFac(config))

    return M
end