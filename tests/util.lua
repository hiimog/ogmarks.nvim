local M = {}

function M:timestamp()
    return os.date("%Y%m%d%H%M%S")
end

function M:createSpecFileName(specName)
    local processedSpecName = string.gsub(specName, " ", "_")
    return string.format("%s_%s", self:timestamp(), processedSpecName)
end

function M:createSpecLogName(specName)
    return self:createSpecFileName(specName) .. ".log"
end

function M:createSpecDbName(specName)
    return self:createSpecFileName(specName) .. ".db"
end

function M:defaultConfig(specName)
    local config = {
        db = {
            file = self:createSpecDbName(specName)
        },
        logging = {
            file = self:createSpecLogName(specName),
            level = "debug"
        }
    }
    return config
end

function M:openTextFile(vim, file)
    vim.cmd("e /src/ogmarks.nvim/tests/text/" .. file)
end

function M:openLorem(vim)
    self:openTextFile(vim, "lorem.txt")
end

function M:openLl(vim)
    self:openTextFile(vim, "ll.txt")
end

function M:openCountries(vim)
    self:openTextFile(vim, "countries.txt")
end

function M:setCursor(vim, row, col)
    vim.api.nvim_win_set_cursor(0, {row, col})
end

function M:delAllBuf(vim)
    for _, id in ipairs(vim.api.nvim_list_bufs()) do
        vim.api.nvim_buf_delete(id, {force=true})
    end
end

return M