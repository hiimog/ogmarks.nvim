return function(config)
    local M = {}
    local List = require("pl.List")
    local s = require("ogmarks.data")
    local Set = require("pl.Set")
    local sqlite = require("lsqlite3")
    local tablex = require("pl.tablex")
    local types = require("ogmarks.types")

    -- init
    M._tagIds = {}
    M._tagNames = {}

    function M:_ensureCreated()
        for count in self._db:urows("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='mark';") do
            if count == 1 then return true, nil end
        end
        local ddlStmts = List{ types.markTableDdl, types.tagTableDdl, types.markTagTableDdl }
        for sql in ddlStmts:iter() do 
            local res = self._db:exec(sql)
            if res ~= sqlite.OK then return false, "Failed to execute ddl statement: " .. self._db:errmsg() end
        end
        return true, nil
    end

    function M:_populateTags()
        local stmt = self._db:prepare(types.getAllTagsSql)
        self._tagIds = {}
        self._tagNames = {}
        for id, name in stmt:urows() do
            self._tagIds[name] = id
            self._tagNames[id] = name
        end
    end


    -- create only if they don't exist
    function M:_createTags(tags)
        for _, tag in ipairs(tags) do
            if not self._tagIds[tag] then
                local stmt = self._db:prepare(types.insertTagSql)
                local res = stmt:bind_names({name = tag})
                if res ~= sqlite.OK then return self._db:errmsg() end
                res = stmt:step()
                if res ~= sqlite.DONE then return self._db:errmsg() end
                local id = stmt:last_insert_rowid()
                self._tagIds[tag] = id
                self._tagNames[id] = tag
            end
        end
        return nil
    end

    function M:createMark(mark)
        local err = s.CheckSchema(mark, types.markSchema)
        if err then return nil, "Failed to create mark: " .. err end

        err = self._createTags(mark.tags)
        if err then return nil, "Failed to create tags: " .. err end

        local stmt = self._db:prepare(types.insertMarkSql)
        local res = stmt:bind_names(mark)
        if res ~= sqlite.OK then return nil, "Failed to set parameters for mark table: " .. self._db:errmsg() end
        res = stmt:step()
        if res ~= sqlite.DONE then return nil, "Failed to insert mark: " .. self._db:errmsg() end
        mark.id = stmt:last_insert_rowid()

        for _, tag in ipairs(mark.tags or {}) do
            stmt = self._db:prepare(types.insertMarkTagSql)
            local tagId = self._tagIds[tag]
            res = stmt:bind_names({markId = mark.id, tagId = tagId})
            if res ~= sqlite.OK then return nil, "Failed to set parameters for markTag table: " .. self._db:errmsg() end
            res = stmt.step()
            if res ~= sqlite.DONE then return nil, "Failed to insert into markTag: " .. self._db:errmsg() end
        end
    end

    function M:getAllTags()
        return tablex.keys(self._tagIds)
    end

    function M:getAllMarks()
        local marks = {}
        for mark in self._db:nrows(types.getAllMarksSql) do
            marks[mark.id] = {
                id = mark.id,
                absolutePath = mark.absolutePath,
                created = mark.created,
                description = mark.description,
                name = mark.name,
                row = mark.row,
                rowText = mark.rowText,
                tags = List(),
                updated = mark.updated,
            }
        end

        for markId, tag in self._db:urows(types.getAllMarkTagSql) do
            marks[markId].tags:append(tag)
        end

        return marks, nil
    end

    local db, _, errMsg = sqlite.open(config.db.file)
    if db == nil then return nil, errMsg end
    M._db = db

    local _, err = M:_ensureCreated()
    if err then return nil, "Failed to ensure db created: " .. err end

    M:_populateTags()

    return M, nil
end