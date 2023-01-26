return function(config)
    local vim = vim
    local logFac = require("ogmarks.log")
    local cfg = require("ogmarks.config")
    local dataFac = require("ogmarks.data")
    local tablex = require("pl.tablex")
    local List = require("pl.List")

    local M = {}
    M._fileMarks = {} -- absolute path to list of marks
    M._marks = {} -- id to mark
    M.config = cfg.create(config)
    assert(cfg.validate(M.config))

    M.log = logFac(M.config)
    M.log:info("ogmarks plugin loading with configuration:\n%s", M.config)

    M.data = M.log:assert(dataFac(M.config))

    -- load all marks into memory
    function M:init()
        local marks = M.log:assert(M.data:getAllMarks())
        M._fileMarks = {}
        for _, mark in ipairs(marks) do
            M._fileMarks[mark.absolutePath] = M._fileMarks[mark.absolutePath] or List()
            M._fileMarks[mark.absolutePath]:append(mark)
        end
        if not M._namespaceId then
            M._namespaceId = vim.api.nvim_create_namespace("ogmarks")
        end
    end

    -- place marks on active buffers
    function M:place()
        local bufIds = vim.api.nvim_list_bufs()
        for _, id in ipairs(bufIds) do
            M:_bufferPlaceAll(id)
        end
    end

    function M:_bufferPlaceAll(bufId)
        local bufferAbsolutePath = vim.api.nvim_buf_get_name(bufId)
        if not bufferAbsolutePath then return true, nil end
        local marks = self._fileMarks[bufferAbsolutePath]
        if not marks then return true, nil end
        local lastLine = vim.api.nvim_buf_line_count(bufId)
        for _, mark in ipairs(marks) do
            if mark.row > lastLine then 
                M.log:debug("mark id=%d has row=%d is past last line=%d", mark.id, mark.row, lastLine)
            else
                M.log:debug("mark id=%d being placed on row=%d in buf id=%d with filename=%s", mark.id, mark.row, bufId, mark.absolutePath)
                vim.api.nvim_buf_set_extmark(bufId, M._namespaceId, mark.row, 0, { id = mark.id })
            end
        end
    end

    function M:_saveBufferMarks(bufId)
        
    end

    return M
end
