return function(config, log)
    local M = {
        _log = log
    }
    local List = require("pl.List")
    local s = require("ogmarks.schema")
    local sqlite = require("lsqlite3")
    local tablex = require("pl.tablex")
    local types = require("pl.types")

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

    M.deleteAllOgMarkTagsSql = [[ 
        DELETE FROM ogmarkTag WHERE ogmarkId = :id;
    ]]

    M.tryDeleteOgMarkSql = [[
        DELETE FROM ogmark WHERE id = :id;
    ]]

    M.deleteByRowSql = [[
        DELETE FROM ogmark WHERE absolutePath = :absolutePath AND row = :row
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
            if count == 1 then return end
        end
        local ddlStmts = List{ self.ogmarkTableDdl, self.tagTableDdl, self.ogmarkTagTableDdl }
        for sql in ddlStmts:iter() do 
            self._log:assert(self._db:exec(sql) == sqlite.OK, "Failed to execute ddl statement: " .. self._db:errmsg())
        end
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
        self._log:debug("data._createTags() creating tags: %s", vim.inspect(tags))
        tags = tags or {}
        for _, tag in ipairs(tags) do
            if not self._tagIds[tag] then
                self._log:debug("data._createTags() creating %s", tag)
                local stmt = self._db:prepare(self.insertTagSql)
                self._log:assert(stmt:bind_names({name = tag}) == sqlite.OK, "Failed to bind parameters for inserting tag: " .. self._db:errmsg())
                self._log:assert(stmt:step() == sqlite.DONE, "Failed to insert tag: " .. self._db:errmsg())
                local id = stmt:last_insert_rowid()
                self._tagIds[tag] = id
                self._tagNames[id] = tag
            end
        end
    end

    function M:create(ogmark)
        self._log:debug("data.create() creating %s", vim.inspect(ogmark))
        local err = s.CheckSchema(ogmark, self.ogmarkSchema)
        self._log:debug("data.create check schema result: %s", vim.inspect(err))
        self._log:assert(err == nil, string.format("%s", err))

        self:_createTags(ogmark.tags)
        local stmt = self._db:prepare(self.insertOgMarkSql)
        self._log:assert(stmt:bind_names(ogmark) == sqlite.OK, "Failed to set parameters for ogmark table: " .. self._db:errmsg())
        self._log:assert(stmt:step() == sqlite.DONE, "Failed to insert ogmark: " .. self._db:errmsg())
        ogmark.id = stmt:last_insert_rowid()

        for _, tag in ipairs(ogmark.tags or {}) do
            stmt = self._db:prepare(self.insertOgMarkTagSql)
            local tagId = self._tagIds[tag]
            self._log:assert(stmt:bind_names({ogmarkId = ogmark.id, tagId = tagId}) == sqlite.OK, "Failed to set parameters for ogmarkTag table: " .. self._db:errmsg())
            self._log:assert(stmt:step() == sqlite.DONE, "Failed to insert into ogmarkTag: " .. self._db:errmsg())
        end

        local newOgMark = self:findOgMark(ogmark.id)
        return self._log:assert(newOgMark, "Could not find newly created ogmark")
    end
    
    function M:findOgMark(id)
        local stmt = self._db:prepare(self.findOgMarkSql)
        -- todo: don't assert here, do the type check
        self._log:assert(stmt:bind_names({id = id}) == sqlite.OK, "Failed to bind parameters to find ogmark: " .. self._db:errmsg())
        local res = stmt:step()
        if res == sqlite.DONE then return nil end
        self._log:assert(res == sqlite.ROW, "Failed execute sql to find ogmark: " .. self._db:errmsg())
        local ogmark = stmt:get_named_values()
        ogmark.tags = {}
        stmt = self._db:prepare(self.getTagsForOgMarkSql)
        stmt:bind_names({id = id})
        for tag in stmt:urows() do
            table.insert(ogmark.tags, tag)
        end
        return ogmark
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
        return ogmarksForFile
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
        ogmark.tags = ogmark.tags or {}
        local stmt = self._db:prepare(self.updateOgMarkSql)
        stmt:bind_names(ogmark)
        self._log:assert(stmt:step() == sqlite.DONE, "Update ogmark failed: " .. self._db:errmsg())
        self:_createTags(ogmark.tags)
        stmt = self._db:prepare(self.deleteAllOgMarkTagsSql)
        self._log:assert(stmt:step() == sqlite.DONE, "Update og mark failed deleting existing tags: " .. self._db:errmsg())
        for _, tag in ipairs(ogmark.tags) do 
            stmt = self._db:prepare(self.insertOgMarkTagSql)
            local tagId = self._tagIds[tag]
            self._log:assert(stmt:bind_names({ogmarkId = ogmark.id, tagId = tagId}) == sqlite.OK, "Failed to bind parameters to create ogmarkTag: " .. self._db:errmsg())
            self._log:assert(stmt:step() == sqlite.DONE, "Failed to insert into ogmarkTag to update ogmark: " .. self._db:errmsg())
        end
    end

    function M:tryDelete(id)
        self._log:debug("data.tryDelete(%d)", id)
        if not types.is_type(id, "number") or not types.is_integer(id) then return end
        local stmt = self._db:prepare(self.tryDeleteOgMarkSql)
        stmt:bind_names({id = id})
        self._log:assert(stmt:step() == sqlite.DONE, "Failed to delete ogmark with id=%d", id)
    end

    function M:delete(id)
        self._log:debug("data.delete(%d)", id)
        local stmt = self._db:prepare(self.tryDeleteOgMarkSql)
        self._log:assert(stmt:bind_names({id = id}) == sqlite.OK, "Failed to bind id to delete sql statement")
        self._log:assert(stmt:step() == sqlite.DONE, "Failed to delete ogmark with id=%d", id)
        local numChanges = self:_numChanges()
        self._log:assert(numChanges == 1, "Failed to delete ogmark: number of changes to be 1, but got %d", numChanges)
    end

    function M:_numChanges()
        for numChanges in self._db:urows("SELECT changes()") do
            return numChanges
        end
    end

    function M:dispose()
        self._db:close()
    end

    local db, _, errMsg = sqlite.open(config.db.file)
    if db == nil then return nil, errMsg end
    M._db = db

    M:_ensureCreated()
    M:_populateTags()

    return M
end