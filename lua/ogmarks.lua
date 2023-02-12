local vim = vim
local config = require("ogmarks.config")
local log = require("ogmarks.log")
local util = require("ogmarks.util")
local M = {
    _project = nil,
    _namespace = nil
}

-- handle >5.1 unpack deprecation
---@diagnostic disable-next-line: deprecated
table.unpack = table.unpack or unpack

local NAME_PATTERN = "^[a-zA-Z0-9_-]+$"

function M:setup(values)
    if values == nil then return end
    assert(type(values) == "table", "values must be a table")
    values.logging = values.logging or {}
    if values.logging.level ~= nil then config.logging.level = values.logging.level end
    if values.logging.file ~= nil then config.logging.file = values.logging.file end
    if values.projectDir ~= nil then config.projectDir = values.projectDir end
    log:init()
    log:info("ogmarks starting")
    util.mkDir(config.projectDir)
    self._namespace = vim.api.nvim_create_namespace("ogmarks")
end

function M:load(name)
    log:info("Loading project: %s", name)
    log:assert(self:exists(name), "Project not found")
end

function M:delExtMark(id)
    util.forEachBuf(function (bufId)
        vim.api.nvim_buf_del_extmark(bufId, self._namespace, id)
    end)
end

function M:delExtMarks()
    util.forEachBuf(function (bufId)
        local extMarks = vim.api.nvim_buf_get_extmarks(bufId, self._namespace, 0, -1, {details = false})
        for _, tuple in ipairs(extMarks) do
            local id, row, col = table.unpack(tuple)
            log:debug("Deleting extmark buf=%d id=%d row=%d col=%d", bufId, id, row, col)
            vim.api.nvim_buf_del_extmark(bufId, self._namespace, id)
        end
    end)
end

function M:new(name)
    log:assert(self:isValid(name), "Project name is invalid")
    log:assert(not self:exists(name), "Project already exists")
    local absPath = self:createProjectAbsPath(name)
    log:info("Creating new project: %s", absPath)
    self._project = self:baseProjectStrucure(name)
    local json = vim.json.encode(self._project)
    local file = log:assert(io.open(self:createProjectAbsPath(self._project.name), "w+"), "Failed to open file for new project")
    if not file then return end
    file:write(json)
    file:close()
    self:load(name)
end

function M:markHere()
    log:assert(self._project, "ogmarks can only be created for active projects")
    local newMark = self:_initializeMarkForCurPos()
    log:debug("Creating mark %s:%d", newMark.absPath, newMark.row)
    table.insert(self._project.ogmarks, newMark)
    self:save()
    self:createExtMark(newMark.id)
    return newMark
end

function M:createExtMark(id)
    log:debug("Creating extmark for ogmark id=%d", id)
    log:assert(self._project, "Cannot create extmark when no project is active")
    assert(id > 0 and id <= #self._project.ogmarks, "id must be in the range [1, %d]", #self._project.ogmarks)
    local ogmark = self._project.ogmarks[id]
    assert(not ogmark.deleted, "Cannot create extmark for deleted ogmarks")
    assert(util.exists(ogmark.absPath), "ogmark's file does not exist")
    vim.cmd("edit " .. ogmark.absPath)
    vim.api.nvim_buf_set_extmark(0, self._namespace, ogmark.row, 0, {
        id = ogmark.id,
        sign_text = "🔖"
    })
end

function M:_initializeMarkForCurPos()
    local absPath, row, col = util.currentPosition()
    local newMark = self:baseMark()
    newMark.row = row
    newMark.absPath = absPath
    newMark.rowText = vim.fn.getline(".")
    newMark.id = #self._project.ogmarks + 1
    return newMark
end

function M:baseMark()
    local ts = util.timestamp()
    return {
        id = nil,
        absPath = nil,
        name = nil,
        row = nil,
        rowText = nil,
        description = nil,
        created = ts,
        updated = ts
    }
end

function M:isValid(name)
    if name == nil or type(name) ~= "string" then return false end
    return string.match(name, NAME_PATTERN) ~= nil
end

function M:save()
    log:assert(self._project and self._project.name, "Invalid state: project must be open with valid name")
    local file = log:assert(io.open(self:createProjectAbsPath(self._project.name), "w+"))
    if not file then return end
    local json = vim.json.encode(self._project)
    file:write(json)
    file:close()
end

function M:exists(name)
    local absPath = self:createProjectAbsPath(name)
    return util.exists(absPath)
end

function M:createProjectAbsPath(name)
    return config.projectDir .. name .. ".json"
end

function M:baseProjectStrucure(name)
    return {
        name = name,
        ogmarks = {},
        tags = {}
    }
end

return M


--[[
LUA

{
    name = "helloworld"
    ogmarks = {
        {
            id = 1,
            name = "main config",
            desc = "Where the initial configuration happens from command line values and from environment values",
            row = 12,
            text = "  config.args = sys.argv[1:]",
            absolutePath = "/src/myproject/main.py",
            created = "20230206165944",
            updated = "20230206165944"
        },
        {
            id = 2,
            deleted = true
        },
        {
            id = 3,
            name = "run loop",
            desc = "Where main starts run loop",
            row = 14,
            text = "    run(config).wait()",
            absolutePath = "/src/myproject/main.py",
            created = "20230206166135",
            updated = "20230206166942"
        }
    },
    tags = {
        "config": { 1 },
        "main": { 1, 3 }
    }
}

JSON

{
    "name": "helloworld",
    "ogmarks": [
        {
            "id": 1,
            "name": "main config",
            "desc": "Where the initial configuration happens from command line values and from environment values",
            "row": 12,
            "text": "  config.args = sys.argv[1:]",
            "absolutePath": "/src/myproject/main.py",
            "created": "20230206165944",
            "updated": "20230206165944"
        },
        {
            "id": 2,
            "deleted": true
        },
        {
            "id": 3,
            "name": "run loop",
            "desc": "Where main starts run loop",
            "row": 14,
            "text": "    run(config).wait()",
            "absolutePath": "/src/myproject/main.py",
            "created": "20230206166135",
            "updated": "20230206166942"
        }
    ],
    "tags": {
        "config": [1],
        "main": [1, 3]
    }
}
]]
