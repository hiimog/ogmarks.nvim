local M = {}

function M.timestamp()
    return os.date("%Y%m%d%H%M%S")
end

function M.fileExists(file)
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
    local res = {}
    local bufIds = vim.api.nvim_list_bufs()
    for _, bufId in ipairs(bufIds) do
        res[bufId] = func(bufId)
    end
    return res
end

function M.forEachTab(func)
    local tabIds = vim.api.nvim_list_tabpages()
    local res = {}
    for _, tabId in ipairs(tabIds) do
        res[tabId] = func(tabId)
    end
    return res
end

function M.forEachWin(func)
    local winIds = vim.api.nvim_list_wins()
    local res = {}
    for _, winId in ipairs(winIds) do
        res[winId] = func(winId)
    end
    return res
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

function M.count(tbl, func)
    local cnt = 0
    for key, value in pairs(tbl) do
        if func(key, value) then cnt = cnt + 1 end
    end
    return cnt
end

function M.map(tbl, func)
    local res = {}
    for key, value in pairs(tbl) do
        res[key] = func(key, value)
    end
    return res
end

-- 0 indexed
function M.getLine(bufId, line)
    return vim.api.nvim_buf_get_lines(bufId, line, line+1, true)
end

function M.pwd()
    local proc = assert(io.popen("pwd", "r"))
    local res = proc:read("a")
    return res
end

return M