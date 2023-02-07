return function(config)
    local vim = vim
    local cfg = require("ogmarks.config")
    local dataFac = require("ogmarks.data")
    local logFac = require("ogmarks.log")

    local M = {}

    local function now()
        return os.date("%Y%m%d%H%M%S")
    end

    function M:place()
        local bufIds = vim.api.nvim_list_bufs()
        for _, id in ipairs(bufIds) do
            M:_placeBufOgMarks(id)
        end
    end

    function M:create(ogmark)
        ogmark.id = nil
        ogmark.created = now()
        ogmark.updated = ogmark.created
        ogmark.tags = ogmark.tags or {}
        local newOgMark = self._data:create(ogmark)
        local isGood, err = pcall(function() self:_createExtMark(newOgMark) end)
        if not isGood then
            self._data:tryDelete(newOgMark.id)
            self._log:assert(false, "Failed to create extmark for ogmark: "..err)
        end
        return newOgMark
    end

    function M:createHere(ogmarkParams)
        ogmarkParams = ogmarkParams or {}
        local absolutePath, row, col = self:_getPosition()
        self._log:debug("ogmarks.createHere() at %s:(%d, %d)", absolutePath, row, col)
        self._log:assert(absolutePath ~= "", "OgMarks can only be created for files")
        ogmarkParams.absolutePath = absolutePath
        ogmarkParams.row = row
        ogmarkParams.rowText = vim.fn.getline(".")
        ogmarkParams.tags = ogmarkParams.tags or {}
        ogmarkParams.name = ogmarkParams.name or ""
        return self:create(ogmarkParams)
    end

    function M:delete(id)
        self._log:info("Deleting ogmark with id=%d", id)
        self._data:delete(id)
        for _, bufId in ipairs(vim.api.nvim_list_bufs()) do
            vim.api.nvim_buf_del_extmark(bufId, self._namespaceId, id)
        end
    end

    function M:deleteHere()
        local extMarks = self:_getExtMarksHere() or {}
        self._log:debug("ogmarks.deleteHere() found extMarks: \n%s", vim.inspect(extMarks))
        for _, extMark in ipairs(extMarks) do
            local extMarkId, row, col, extra = table.unpack(extMark)
            local ogmark = self._data:findOgMark(extMarkId)
            self._log:assert(ogmark, "extmark found, but corresponding ogmark was not: %id", extMarkId)
            self._log:debug("ogmarks.deleteHere() deleting ogmark\n%s", vim.inspect(ogmark))
            self:delete(extMarkId)
        end
    end

    function M:saveRowChanges()
        local buffers = vim.api.nvim_list_bufs()
        for _, bufId in ipairs(buffers) do
            self:_saveBufRowChanges(bufId)
        end
    end

    function M:focus(ogmarkId)
        --self._log:assert(vim.api.nvim_win_is_valid(winId), "Window id=%d is invalid", winId)
        local ogMark = self._data:findOgMark(ogmarkId)
        self._log:debug("ogmarks.focus(%d) = \n%s", ogmarkId, vim.inspect(ogMark))
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

    -- returns 0 based row
    function M:_getPosition()
        local absolutePath = vim.api.nvim_buf_get_name(0)
        local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
        return absolutePath, row - 1, col
    end

    function M:_getExtMarksHere()
        local absolutePath, row, col = self:_getPosition()
        self._log:debug("ogmarks._getExtMarksHere() = %s:(%d,%d)", absolutePath, row, col)
        local extMarks = vim.api.nvim_buf_get_extmarks(0, self._namespaceId, {row, 0}, {row+1, 0}, {details=true})
        self._log:debug("ogmarks._getExtMarksHere() found %d:\n%s", #extMarks, vim.inspect(extMarks))
        return extMarks
    end

    function M:_createExtMark(ogmark)
        vim.api.nvim_buf_set_extmark(0, self._namespaceId, ogmark.row, 0, {
            id = ogmark.id,
            sign_text = "🔖"
        })
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

    function M:_saveBufRowChanges(bufId)
        local allExtMarks = vim.api.nvim_buf_get_extmarks(bufId, self._namespaceId, 0, -1, {details=true})
        self._log:debug("ogmarks._saveBufferMarks() got all extmarks from buffer=%d\n%s", bufId, vim.inspect(allExtMarks))
        for _, extMark in ipairs(allExtMarks) do
            local extMarkId, row, col, extra = table.unpack(extMark)
            local ogmark = self._data:findOgMark(extMarkId)
            ogmark.row = row
            self._data:updateOgMark(ogmark)
        end
    end

    function M:_loadBufOgMark(bufId)
        local absolutePath = vim.api.nvim_buf_get_name(bufId)
        local ogmarksForFile = self._data:getOgMarksForFile(absolutePath)
        self._log:debug("ogmarks._loadBufOgMark(%d) = \n%s", bufId, vim.inspect(ogmarksForFile))
        for _, ogmark in ipairs(ogmarksForFile) do
            self:_createExtMark(ogmark)
        end
    end

    M._config = cfg.create(config)
    assert(cfg.validate(M._config))

    M._log = logFac(M._config)
    M._log:info("ogmarks() ogmarks plugin loading with configuration:\n%s", vim.inspect(M._config))
    M._data = M._log:assert(dataFac(M._config, M._log))
    M._namespaceId = vim.api.nvim_create_namespace("ogmarks")

    return M
end
