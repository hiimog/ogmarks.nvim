return function(config, log)
    local M = {
        _log = log
    }
    local List = require("pl.List")
    local s = require("ogmarks.schema")
    local sqlite = require("lsqlite3")
    local tablex = require("pl.tablex")

    -- init
    M._tagIds = {}
    M._tagNames = {}

    -- M.projectTableDdl = [[
    --     CREATE TABLE project (
    --         id INTEGER PRIMARY KEY AUTOINCREMENT,
    --         name TEXT NOT NULL UNIQUE,
    --         projectRoot TEXT NOT NULL,
    --     )
    -- ]]

    M.ogmarkTableDdl = [[
        CREATE TABLE ogmark (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            absolutePath TEXT,
            created TEXT NOT NULL,
            description TEXT,
            name TEXT,
            row INTEGER NOT NULL,
            rowText TEXT NOT NULL,
            updated TEXT NOT NULL
        );
    ]]

    M.tagTableDdl = [[
        CREATE TABLE tag (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
        );
    ]]

    M.ogmarkTagTableDdl = [[ 
        CREATE TABLE ogmarkTag (
            ogmarkId INTEGER,
            tagId INTEGER,
            PRIMARY KEY (ogmarkId, tagId),
            FOREIGN KEY(ogmarkId) REFERENCES ogmark(id) ON DELETE CASCADE,
            FOREIGN KEY(tagId) REFERENCES tag(id) ON DELETE CASCADE
        );
    ]]

    M.insertOgMarkSql = [[ 
        INSERT INTO ogmark (absolutePath, created, description, name, row, rowText, updated)
        VALUES (:absolutePath, :created, :description, :name, :row, :rowText, :updated);
    ]]

    M.insertTagSql = [[
        INSERT INTO tag (name) VALUES (:name);
    ]]

    M.getAllTagsSql = [[
        SELECT id, name FROM tag ORDER BY id;
    ]]

    M.insertOgMarkTagSql = [[
        INSERT INTO ogmarkTag (ogmarkId, tagId) VALUES (:ogmarkId, :tagId);
    ]]

    M.getAllOgMarksSql = [[
        SELECT * FROM ogmark;
    ]]

    M.getAllOgMarkTagSql = [[
        SELECT mt.ogmarkId, t.name FROM ogmarkTag mt JOIN tag t ON mt.tagId = t.id;
    ]]

    M.getTagsForOgMarkSql = [[
        SELECT t.name FROM ogmarkTag mt JOIN tag t ON mt.tagId = t.id WHERE mt.ogmarkId = :id;
    ]]

    M.findOgMarkSql = [[
        SELECT * FROM ogmark WHERE id = :id;
    ]]

    M.getOgMarksForFileSql = [[
        SELECT * FROM ogmark WHERE absolutePath = :absolutePath;
    ]]

    M.updateOgMarkSql = [[
        UPDATE ogmark SET
            absolutePath = :absolutePath,
            created = :created,
            description = :description,
            name = :name,
            row = :row,
            rowText = :rowText,
            updated = :updated
        WHERE id = :id;
    ]]

    M.ogmarkSchema = s.Record {
        id = s.Optional(s.Integer),
        absolutePath = s.String,
        created = s.String,
        description = s.Optional(s.String),
        name = s.String,
        row = s.Integer,
        rowText = s.String,
        tags = s.Collection(s.String),
        updated = s.String,
    }


    function M:_ensureCreated()
        for count in self._db:urows("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='ogmark';") do
            if count == 1 then return true, nil end
        end
        local ddlStmts = List{ self.ogmarkTableDdl, self.tagTableDdl, self.ogmarkTagTableDdl }
        for sql in ddlStmts:iter() do 
            local res = self._db:exec(sql)
            if res ~= sqlite.OK then return false, "Failed to execute ddl statement: " .. self._db:errmsg() end
        end
        return true, nil
    end

    function M:_populateTags()
        local stmt = self._db:prepare(self.getAllTagsSql)
        self._tagIds = {}
        self._tagNames = {}
        for id, name in stmt:urows() do
            self._tagIds[name] = id
            self._tagNames[id] = name
        end
    end


    -- create only if they don't exist
    function M:_createTags(tags)
        tags = tags or {}
        for _, tag in ipairs(tags) do
            if not self._tagIds[tag] then
                local stmt = self._db:prepare(self.insertTagSql)
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

    function M:createOgMark(ogmark)
        local err = s.CheckSchema(ogmark, self.ogmarkSchema)
        if err then return nil, err end

        err = self._createTags(ogmark.tags)
        if err then return nil, "Failed to create tags: " .. err end

        local stmt = self._db:prepare(self.insertOgMarkSql)
        local res = stmt:bind_names(ogmark)
        if res ~= sqlite.OK then return nil, "Failed to set parameters for ogmark table: " .. self._db:errmsg() end
        res = stmt:step()
        if res ~= sqlite.DONE then return nil, "Failed to insert ogmark: " .. self._db:errmsg() end
        ogmark.id = stmt:last_insert_rowid()

        for _, tag in ipairs(ogmark.tags or {}) do
            stmt = self._db:prepare(self.insertOgMarkTagSql)
            local tagId = self._tagIds[tag]
            res = stmt:bind_names({ogmarkId = ogmark.id, tagId = tagId})
            if res ~= sqlite.OK then return nil, "Failed to set parameters for ogmarkTag table: " .. self._db:errmsg() end
            res = stmt:step()
            if res ~= sqlite.DONE then return nil, "Failed to insert into ogmarkTag: " .. self._db:errmsg() end
        end

        local newOgMark, err = self:findOgMark(ogmark.id)
        if not newOgMark then return nil, "Failed to create ogmark: " .. err end
        return newOgMark, nil
    end
    
    function M:findOgMark(id)
        local stmt = self._db:prepare(self.findOgMarkSql)
        stmt:bind_names({id = id})
        local result = stmt:step()
        if result == sqlite.DONE then return nil, string.format("No ogmark found with id=%d", id) end
        if result ~= sqlite.ROW then return nil,  "Failed finding ogmark by id: " .. self._db:errmsg() end
        local ogmark = stmt:get_named_values()
        ogmark.tags = List()
        stmt = self._db:prepare(self.getTagsForOgMarkSql)
        stmt:bind_names({id = id})
        for tag in stmt:urows() do
            ogmark.tags:append(tag)
        end
        return ogmark, nil
    end

    function M:getAllTags()
        return tablex.keys(self._tagIds)
    end

    function M:getOgMarksForFile(absolutePath)
        local stmt = self._db:prepare(self.getOgMarksForFileSql)
        stmt:bind_names({absolutePath = absolutePath})
        local ogmarksForFile = {}
        for ogmark in stmt:nrows() do 
            table.insert(ogmarksForFile, ogmark)
        end
        return ogmarksForFile, nil
    end

    function M:getAllOgMarks()
        local ogmarks = {}
        for ogmark in self._db:nrows(self.getAllOgMarksSql) do
            ogmarks[ogmark.id] = {
                id = ogmark.id,
                absolutePath = ogmark.absolutePath,
                created = ogmark.created,
                description = ogmark.description,
                name = ogmark.name,
                row = ogmark.row,
                rowText = ogmark.rowText,
                tags = List(),
                updated = ogmark.updated,
            }
        end

        for ogmarkId, tag in self._db:urows(self.getAllOgMarkTagSql) do
            ogmarks[ogmarkId].tags:append(tag)
        end

        return ogmarks, nil
    end

    function M:updateOgMark(ogmark)
        local stmt = self._db:prepare(self.updateOgMarkSql)
        stmt.bind_names(ogmark)
        local res = stmt:step()
        if res == sqlite.ERROR then return nil, "Update failed: " .. self._db:errmsg() end
        if res ~= sqlite.DONE then return nil, "Update failed" end

    end

    local db, _, errMsg = sqlite.open(config.db.file)
    if db == nil then return nil, errMsg end
    M._db = db

    local _, err = M:_ensureCreated()
    if err then return nil, "Failed to ensure db created: " .. err end

    M:_populateTags()

    return M, nil
end