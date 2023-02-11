local M = {}

function M.timestamp()
    return os.date("%Y%m%d%H%M%S")
end

function M.exists(file)
    local file = io.open(file, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

function M.mkDir(dir)
    os.execute("mkdir -p " .. dir)
end

function M.forEachBuf(func)
    local bufIds = vim.api.nvim_list_bufs()
    for _, bufId in ipairs(bufIds) do
        func(bufId)
    end
end

return M