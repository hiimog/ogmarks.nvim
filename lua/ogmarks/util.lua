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

-- return (0-indexed) absolute path, row, col
function M.getCursor()
    local file = vim.api.nvim_buf_get_name(0)
    local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
    return file, row - 1, col
end

function M.where(tbl, func)
    local res = {}
    for key, value in pairs(tbl) do
        if func(key, value) then res[key] = value end
    end
    return res
end

return M