return function(config)
    local vim = vim
    local logFac = require("ogmarks.log")
    local cfg = require("ogmarks.config")
    local dataFac = require("ogmarks.data")
    local tablex = require("pl.tablex")
    local List = require("pl.List")
    local s = require("ogmarks.schema")

    local M = {}

    function M:createMark(mark)
        mark.id = nil
        mark.created = os.date("%Y%m%d%H%M%S")
        mark.updated = mark.created
        self.log:debug("ogmarks.createMark(): Creating mark: \n%s", vim.inspect(mark))
        return self.data:createMark(mark)
    end

    -- load all marks into memory
    function M:init()
        self.log:debug("ogmarks.init() starting")
        local marks = M.log:assert(M.data:getAllMarks())
        M._allMarks = marks
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
                M.log:debug("ogmarks._bufferPlaceAll() mark id=%d has row=%d is past last line=%d", mark.id, mark.row, lastLine)
            else
                M.log:debug("ogmarks._bufferPlaceAll() mark id=%d being placed on row=%d in buf id=%d with filename=%s", mark.id, mark.row, bufId, mark.absolutePath)
                vim.api.nvim_buf_set_extmark(bufId, M._namespaceId, mark.row, 0, { id = mark.id })
            end
        end
    end

    function M:_saveBufferMarks(bufId)
        local allExtMarks = vim.api.nvim_buf_get_extmarks(bufId, self._namespaceId, 0, -1, {details=true})
        self.log:info("ogmarks._saveBufferMarks() got all extmarks from buffer=%d\n%s", bufId, vim.inspect(allExtMarks))
        for _, mark in ipairs(allExtMarks) do
            self.data:updateMark()
        end
    end

    function M:createMarkAtCurPos(markParams)
        markParams = markParams or {}
        local position = vim.fn.getcurpos()
        local _, lnum, col, off, curswant = table.unpack(position)
        local row = lnum - 1
        self.log:debug("ogmarks._createMarkAtCurPos() Current row: \n%s", vim.inspect(row))
        markParams.absolutePath = vim.api.nvim_buf_get_name(0)
        markParams.row = row
        markParams.rowText = vim.api.nvim_buf_get_lines(0, row, row+1, true)[0]
        self.log:debug("ogmarks._createMarkAtCurPos() Creating mark at current position: \n%s", vim.inspect(markParams))
        local newMark, err = self:createMark(markParams)
        if err then self.log:error("Failed to create mark: %s", err) end
        return newMark, err
    end

    M._fileMarks = {} -- absolute path to list of marks
    M._marks = {} -- id to mark
    M.config = cfg.create(config)
    assert(cfg.validate(M.config))

    M.log = logFac(M.config)
    M.log:info("ogmarks() ogmarks plugin loading with configuration:\n%s", vim.inspect(M.config))
    M.data = M.log:assert(dataFac(M.config))
    M:init()

    return M
end
