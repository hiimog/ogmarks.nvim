local M = {}

local function defaults()
    return {
        id = nil, 
        row = 1,
        rowText = "",
        name = "",
        desc = "",
        tags = {},
    }
end

local function validate(values)
    values = values or {}
    local errors = {}
    local choose = function(a, b) if a == nil then return b else return a end end

    return #errors > 0 and errors or nil
end

return M