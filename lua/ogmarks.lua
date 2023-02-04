return function(config)
    local vim = vim
    local cfg = require("ogmarks.config")
    local dataFac = require("ogmarks.data")
    local logFac = require("ogmarks.log")

    local M = {}

    local function now()
        return os.date("%Y%m%d%H%M%S")
    end

    function M:createOgMark(ogmark)
        ogmark.id = nil
        ogmark.created = now()
        ogmark.updated = ogmark.created
        ogmark.tags = ogmark.tags or {}
        self._log:debug("ogmarks.createOgMark(): Creating ogmark: \n%s", vim.inspect(ogmark))
        local newOgMark = self._data:createOgMark(ogmark)
        local isGood, err = pcall(function() self:_createExtMark(newOgMark) end)
        if not isGood then
            self._data:tryDelete(newOgMark.id)
            self._log:assert(false, "Failed to create extmark for ogmark: "..err)
        end
        return newOgMark
    end

    function M:_createExtMark(ogmark)
        vim.api.nvim_buf_set_extmark(0, self._namespaceId, ogmark.row, 0, {
            id = ogmark.id,
            sign_text = "🔖"
        })
    end

    function M:place()
        local bufIds = vim.api.nvim_list_bufs()
        for _, id in ipairs(bufIds) do
            M:_placeBufOgMarks(id)
        end
    end

    function M:_placeBufOgMarks(bufId)
        local bufferAbsolutePath = self._log:assert(vim.api.nvim_buf_get_name(bufId), "Can oly create ogmarks for files on disk")
        local ogmarks = self._data:getOgMarksForFile(bufferAbsolutePath)
        self._log:info("Placing %d marks in %s", #table, bufferAbsolutePath)
        if not ogmarks then self._log:debug("No ogmarks for %s", bufferAbsolutePath) return end
        local numLines = vim.api.nvim_buf_line_count(bufId)
        for _, ogmark in ipairs(ogmarks) do
            if ogmark.row >= numLines then 
                M._log:debug("ogmarks._bufferPlaceAll() ogmark id=%d has row=%d is past last line=%d", ogmark.id, ogmark.row, numLines)
            else
                M._log:debug("ogmarks._bufferPlaceAll() ogmark id=%d being placed on row=%d in buf id=%d with filename=%s", ogmark.id, ogmark.row, bufId, ogmark.absolutePath)
                self:_createExtMark(ogmark)
            end
        end
    end

    function M:updateOgMarks()
        local buffers = vim.api.nvim_list_bufs()
        for _, bufId in ipairs(buffers) do
            self:_updateBufOgMarks(bufId)
        end
    end

    function M:_updateBufOgMarks(bufId)
        local allExtMarks = vim.api.nvim_buf_get_extmarks(bufId, self._namespaceId, 0, -1, {details=true})
        self._log:debug("ogmarks._saveBufferMarks() got all extmarks from buffer=%d\n%s", bufId, vim.inspect(allExtMarks))
        for _, extMark in ipairs(allExtMarks) do
            local extMarkId, row, col, extra = table.unpack(extMark)
            local ogmark = self._data:findOgMark(extMarkId)
            ogmark.row = row
            self._data:updateOgMark(ogmark)
        end
    end

    function M:createOgMarkAtCurPos(ogmarkParams)
        ogmarkParams = ogmarkParams or {}
        local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
        self._log:debug("ogmarks.createOgMarkAtCurPos() at (%d, %d)", row, col)
        ogmarkParams.absolutePath = vim.api.nvim_buf_get_name(0)
        print("absPath = " .. ogmarkParams.absolutePath)
        self._log:assert(ogmarkParams.absolutePath ~= "", "OgMarks can only be created for files")
        ogmarkParams.row = row - 1
        ogmarkParams.rowText = vim.fn.getline(".")
        ogmarkParams.tags = ogmarkParams.tags or {}
        ogmarkParams.name = ogmarkParams.name or ""
        self._log:debug("ogmarks.createOgMarkAtCurPos() Creating ogmark at current position: \n%s", vim.inspect(ogmarkParams))
        return self:createOgMark(ogmarkParams)
    end

    function M:_loadMarkForBuf(bufId)
        local absolutePath = vim.api.nvim_buf_get_name(bufId)
        local ogmarksForFile = self._data:getOgMarksForFile(absolutePath)
        self._log:debug("ogmarks._loadMarkForBuf(%d) = \n%s", bufId, vim.inspect(ogmarksForFile))
        for _, ogmark in ipairs(ogmarksForFile) do
            self:_createExtMark(ogmark)
        end
    end

    function M:focusOgMark(ogmarkId)
        --self._log:assert(vim.api.nvim_win_is_valid(winId), "Window id=%d is invalid", winId)
        local ogMark = self._data:findOgMark(ogmarkId)
        self._log:debug("ogmarks.focusOgMark(%d) = \n%s", ogmarkId, vim.inspect(ogMark))
        if ogMark == nil then return end
        local row = ogMark.row + 1
        vim.cmd(":e " .. ogMark.absolutePath)
        self:_createExtMark(ogMark)
        vim.api.nvim_win_set_cursor(0, {row, 0})
    end

    function M:dispose()
        self._log:info("Shutting down plugin")
        self._data:dispose()
        self._log:dispose()
    end

    M._config = cfg.create(config)
    assert(cfg.validate(M._config))

    M._log = logFac(M._config)
    M._log:info("ogmarks() ogmarks plugin loading with configuration:\n%s", vim.inspect(M._config))
    M._data = M._log:assert(dataFac(M._config, M._log))
    M._namespaceId = vim.api.nvim_create_namespace("ogmarks")

    return M
end
