local M = {}

function M:timestamp()
    return os.date("%Y%m%d%H%M%S")
end

return M