local M = {}
local Set = require("pl.Set")

local function defaults()
    return {
        id = nil, 
        row = 1,
        rowText = "",
        name = "",
        desc = "",
        tags = Set{},
    }
end

local function validate(values)
    values = values or {}
    local errors = {}
    
    return #errors > 0 and errors or nil
end

return M