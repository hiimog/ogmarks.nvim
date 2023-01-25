local s = require("lua.thirdparty.schema")
local M = {}

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
        created INTEGER NOT NULL,
        description TEXT NOT NULL,
        name TEXT NOT NULL,
        row INTEGER NOT NULL,
        rowText TEXT NOT NULL,
        updated INTEGER
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
        CONSTRAINT pkMarkTag PRIMARY KEY (markId, tagId)
        CONSTRAINT fkMarkId REFERENCES mark(id) ON DELETE CASCADE,
        CONSTRAINT fkTagId REFERENCES tag(id) ON DELETE CASCADE
    )
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

return M