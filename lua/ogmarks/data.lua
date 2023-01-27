return function(config)
    local M = {}
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

    M.markTableDdl = [[
        CREATE TABLE mark (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            absolutePath TEXT NOT NULL,
            created TEXT NOT NULL,
            description TEXT NOT NULL,
            name TEXT NOT NULL,
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

    M.markTagTableDdl = [[ 
        CREATE TABLE markTag (
            markId INTEGER,
            tagId INTEGER,
            PRIMARY KEY (markId, tagId),
            FOREIGN KEY(markId) REFERENCES mark(id) ON DELETE CASCADE,
            FOREIGN KEY(tagId) REFERENCES tag(id) ON DELETE CASCADE
        );
    ]]

    M.insertMarkSql = [[ 
        INSERT INTO mark (created, description, name, row, rowText, updated)
        VALUES (:created, :description, :name, :row, :rowText, :updated);
    ]]

    M.insertTagSql = [[
        INSERT INTO tag (name) VALUES (:name);
    ]]

    M.getAllTagsSql = [[
        SELECT id, name FROM tag ORDER BY id;
    ]]

    M.insertMarkTagSql = [[
        INSERT INTO markTag (markId, tagId) VALUES (:markId, :tagId);
    ]]

    M.getAllMarksSql = [[
        SELECT * FROM mark;
    ]]

    M.getAllMarkTagSql = [[
        SELECT mt.markId, t.name FROM markTag mt JOIN tag t ON mt.tagId = t.id;
    ]]

    M.getTagsForMarkSql = [[
        SELECT t.name FROM markTag mt JOIN tag t ON mt.tagId = t.id WHERE mt.markId = :id;
    ]]

    M.markSchema = s.Record {
        id = s.Optional(s.Integer),
        absolutePath = s.String,
        created = s.Integer,
        description = s.Optional(s.String),
        name = s.String,
        row = s.Integer,
        rowText = s.String,
        tags = s.Collection(s.String),
        updated = s.Integer,
    }

    M.findMarkSql = [[
        SELECT * FROM mark WHERE id = :id;
    ]]

    function M:_ensureCreated()
        for count in self._db:urows("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='mark';") do
            if count == 1 then return true, nil end
        end
        local ddlStmts = List{ self.markTableDdl, self.tagTableDdl, self.markTagTableDdl }
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

    function M:createMark(mark)
        local err = s.CheckSchema(mark, self.markSchema)
        if err then return nil, err end

        err = self._createTags(mark.tags)
        if err then return nil, "Failed to create tags: " .. err end

        local stmt = self._db:prepare(self.insertMarkSql)
        local res = stmt:bind_names(mark)
        if res ~= sqlite.OK then return nil, "Failed to set parameters for mark table: " .. self._db:errmsg() end
        res = stmt:step()
        if res ~= sqlite.DONE then return nil, "Failed to insert mark: " .. self._db:errmsg() end
        mark.id = stmt:last_insert_rowid()

        for _, tag in ipairs(mark.tags or {}) do
            stmt = self._db:prepare(self.insertMarkTagSql)
            local tagId = self._tagIds[tag]
            res = stmt:bind_names({markId = mark.id, tagId = tagId})
            if res ~= sqlite.OK then return nil, "Failed to set parameters for markTag table: " .. self._db:errmsg() end
            res = stmt.step()
            if res ~= sqlite.DONE then return nil, "Failed to insert into markTag: " .. self._db:errmsg() end
        end

        local newMark, err = self:findMark(mark.id)
        if not newMark then return nil, "Failed to create mark: " .. err end
        return newMark, nil
    end
    
    function M:findMark(id)
        local stmt = self._db.prepare(self.findMarkSql)
        stmt.bind_names({id = id})
        local result = stmt.step()
        if result == sqlite.DONE then return nil, string.format("No mark found with id=%d", id) end
        if result ~= sqlite.ROW then return nil,  "Failed finding mark by id: " .. self._db:errmsg() end
        local mark = result.get_named_values()
        mark.tags = List()
        stmt = self._db.prepare(self.getTagsForMarkSql)
        stmt.bind_names({id = id})
        for tag in stmt:urows() do
            mark.tags:append(tag)
        end
        return mark, nil
    end

    function M:getAllTags()
        return tablex.keys(self._tagIds)
    end

    function M:getAllMarks()
        local marks = {}
        for mark in self._db:nrows(self.getAllMarksSql) do
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

        for markId, tag in self._db:urows(self.getAllMarkTagSql) do
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