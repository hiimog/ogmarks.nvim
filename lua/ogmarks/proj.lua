local util = require("ogmarks.util")
local log = require("ogmarks.log")

local M = {
    _project = nil,
    _projectFile = nil,
}

function M:forEach(func)
    local res = {}
    if not self._project then return res end
    for id, ogmark in ipairs(self._project.ogmarks) 
    return res
end

return M