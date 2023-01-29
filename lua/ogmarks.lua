return function(config)
    local vim = vim
    local logFac = require("ogmarks.log")
    local cfg = require("ogmarks.config")
    local dataFac = require("ogmarks.data")
    local tablex = require("pl.tablex")
    local List = require("pl.List")
    local s = require("ogmarks.schema")

    local M = {}

    function M:createOgMark(ogmark)
        ogmark.id = nil
        ogmark.created = os.date("%Y%m%d%H%M%S")
        ogmark.updated = ogmark.created
        self.log:debug("ogmarks.createOgMark(): Creating ogmark: \n%s", vim.inspect(ogmark))
        local newOgMark, err = self.data:createOgMark(ogmark)
        if err then return nil, "Create ogmark failed: " .. err end
        self:_createExtMark(newOgMark)
    end

    function M:_createExtMark(ogmark)
        vim.api.nvim_buf_set_extmark(0, self._namespaceId, ogmark.row, 0, {
            id = ogmark.id,
            sign_text = "🔖"
        })
    end

    function M:init()
        self.log:debug("ogmarks.init() starting")
        if not M._namespaceId then
            M._namespaceId = vim.api.nvim_create_namespace("ogmarks")
        end
    end

    function M:place()
        local bufIds = vim.api.nvim_list_bufs()
        for _, id in ipairs(bufIds) do
            M:_bufferPlaceAll(id)
        end
    end

    function M:_bufferPlaceAll(bufId)
        local bufferAbsolutePath = vim.api.nvim_buf_get_name(bufId)
        if not bufferAbsolutePath then return true, nil end
        local ogmarks = self._fileMarks[bufferAbsolutePath]
        if not ogmarks then return true, nil end
        local lastLine = vim.api.nvim_buf_line_count(bufId)
        for _, ogmark in ipairs(ogmarks) do
            if ogmark.row > lastLine then 
                M.log:debug("ogmarks._bufferPlaceAll() ogmark id=%d has row=%d is past last line=%d", ogmark.id, ogmark.row, lastLine)
            else
                M.log:debug("ogmarks._bufferPlaceAll() ogmark id=%d being placed on row=%d in buf id=%d with filename=%s", ogmark.id, ogmark.row, bufId, ogmark.absolutePath)
                self:_createExtMark(ogmark)
            end
        end
    end

    function M:_saveBufferOgMarks(bufId)
        local allExtMarks = vim.api.nvim_buf_get_extmarks(bufId, self._namespaceId, 0, -1, {details=true})
        self.log:info("ogmarks._saveBufferMarks() got all extmarks from buffer=%d\n%s", bufId, vim.inspect(allExtMarks))
        for _, ogmark in ipairs(allExtMarks) do
            self.data:updateMark(ogmark)
        end
    end

    function M:createOgMarkAtCurPos(ogmarkParams)
        ogmarkParams = ogmarkParams or {}
        local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
        self.log:debug("ogmarks.createOgMarkAtCurPos() at (%d, %d)", row, col)
        ogmarkParams.absolutePath = vim.api.nvim_buf_get_name(0)
        ogmarkParams.row = row - 1
        ogmarkParams.rowText = vim.api.nvim_buf_get_lines(0, row, row+1, true)[1]
        ogmarkParams.tags = ogmarkParams.tags or {}
        ogmarkParams.name = ogmarkParams.name or ""
        self.log:debug("ogmarks.createOgMarkAtCurPos() Creating ogmark at current position: \n%s", vim.inspect(ogmarkParams))
        local newMark, err = self:createOgMark(ogmarkParams)
        if err then self.log:error("Failed to create ogmark: %s", err) end
        return newMark, err
    end

    function M:_loadMarkForBuf(bufId)
        local absolutePath = vim.api.nvim_buf_get_name(bufId)
        local ogmarksForFile = self.data:getOgMarksForFile(absolutePath)
        self.log:debug("ogmarks._loadMarkForBuf(%d) = \n%s", bufId, vim.inspect(ogmarksForFile))
        for _, ogmark in ipairs(ogmarksForFile) do
            self:_createExtMark(ogmark)
        end
    end

    M._fileMarks = {}
    M._ogmarks = {}
    M.config = cfg.create(config)
    assert(cfg.validate(M.config))

    M.log = logFac(M.config)
    M.log:info("ogmarks() ogmarks plugin loading with configuration:\n%s", vim.inspect(M.config))
    M.data = M.log:assert(dataFac(M.config))
    M:init()

    return M
end
