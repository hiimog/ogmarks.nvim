local vim = vim
local config = require("ogmarks.config")
local log = require("ogmarks.log")
local util = require("ogmarks.util")
local M = {
    _project = nil,
    _namespace = nil,
    _augroup = nil,
    _projectPath = nil
}

-- handle >5.1 unpack deprecation
---@diagnostic disable-next-line: deprecated
table.unpack = table.unpack or unpack

local NAME_PATTERN = "^[a-zA-Z0-9_-]+$"

function M:setup(values)
    values = values or {}
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

function M:createAutoCmds()
    self._augroup = vim.api.nvim_create_augroup("ogmarks", {
            clear = true,
        })
end

function M:new(name, opts)
    opts = opts or {}
    log:assert(self:_isValidProjName(name), "Project name is invalid")
    log:assert(not self:_projExists(name), "Project already exists")
    self._projectPath = self:_createProjAbsPath(name)
    log:info("Creating new project: %s", self._projectPath)
    self._project = self:_createBaseProjStruct(name)
    self:save()
end

function M:mark()
    log:assert(self._project, "ogmarks can only be created for active projects")
    local newMark = self:_initMarkForCurPos()
    log:debug("Creating mark %s:%d", newMark.absPath, newMark.row)
    table.insert(self._project.ogmarks, newMark)
    self:save()
    self:loadMark(newMark.id)
    return newMark
end

function M:save()
    log:assert(self._project, "Cannot save when no project is open or project name is deleted")
    local file, err = io.open(self._projectPath, "w+")
    log:assert(file ~= nil, "Failed to open project file for saving: " .. (err or ""))
    if not file then return end
    file:write(self:_createProjJson())
    file:flush()
    file:close()
end

function M:loadProj(name)
    log:info("Loading project: %s", name)
    log:assert(self:_projExists(name), "Project not found")
    local text = self:_readFile(self:_createProjAbsPath(name))
    self._project = vim.json.decode(text)
end

function M:bufLoad(bufId)
    log:assert(self._project, "Project must be open")
    local bufName = vim.api.nvim_buf_get_name(bufId)
    local ogmarks = util.where(self._project.ogmarks, function(k, v)
            return v.absPath == bufName
        end)
    for _, ogmark in pairs(ogmarks) do
        vim.api.nvim_buf_set_extmark(bufId, self._namespace, ogmark.row, 0, {
            id = ogmark.id,
            sign_text = "🔖"
        })
    end
end

function M:delExtMark(id)
    util.forEachBuf(function(bufId)
        vim.api.nvim_buf_del_extmark(bufId, self._namespace, id)
    end)
end

function M:delExtMarks()
    util.forEachBuf(function(bufId)
        local extMarks = vim.api.nvim_buf_get_extmarks(bufId, self._namespace, 0, -1, { details = false })
        for _, tuple in ipairs(extMarks) do
            local id, row, col = table.unpack(tuple)
            log:debug("Deleting extmark buf=%d id=%d row=%d col=%d", bufId, id, row, col)
            vim.api.nvim_buf_del_extmark(bufId, self._namespace, id)
        end
    end)
end

function M:loadMark(id)
    log:debug("Loading mark id=%d", id)
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
    vim.api.nvim_win_set_cursor(0, { ogmark.row + 1, 0 })
    log:debug("Mark loaded: \n%s", vim.inspect(ogmark))
end

function M:_readFile(file)
    local f, err = io.open(file, "r")
    log:assert(f, "Failed to open file: " .. (err or ""))
    f = f or {} -- satisfy diagnostic
    local text = f:read("*a")
    f:close()
    return text
end

function M:_initMarkForCurPos()
    local absPath, row, col = util.getCursor()
    local newMark = self:_createBaseMarkStruct()
    newMark.row = row
    newMark.absPath = absPath
    newMark.rowText = vim.fn.getline(".")
    newMark.id = #self._project.ogmarks + 1
    return newMark
end

function M:_createBaseMarkStruct()
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

function M:_isValidProjName(name)
    if name == nil or type(name) ~= "string" then return false end
    return string.match(name, NAME_PATTERN) ~= nil
end

function M:_projExists(name)
    local absPath = self:_createProjAbsPath(name)
    return util.exists(absPath)
end

function M:_createProjAbsPath(name)
    return config.projectDir .. "/" .. name .. ".json"
end

function M:_createBaseProjStruct(name)
    return {
        name = name,
        ogmarks = {},
        tags = {},
        config = {}
    }
end

function M:_createProjJson()
    log:assert(self._project, "Cannot create project json when project isn't open")
    return vim.json.encode(self._project)
end

function M:_updateBufMarksPos(bufId)
    bufId = bufId or 0
    log:assert(self._project, "Cannot update buffer ogmarks when no project is open")
    local absPath = vim.api.nvim_buf_get_name(bufId)
    log:assert(absPath ~= "", "Cannot update buffer ogmarks for buffer with no backing file")
    local bufExtMarks = vim.api.nvim_buf_get_extmarks(bufId, self._namespace, 0, -1, {})
    for _, extMark in ipairs(bufExtMarks) do
        local id, row, col = table.unpack(extMark)
        local ogmark = self._project.ogmarks[id]
        log:assert(ogmark, "ExtMark id=%d found without corresponding ogmark", id)
        ogmark.row = row
        ogmark.rowText = vim.api.nvim_buf_get_lines(bufId, row, row+1, false)[1]
        ogmark.updated = util.timestamp()
    end
end

function M:_updateAllMarkPos()
    log:assert(self._project, "Cannot update mark positions when no project is open")
    for _, ogmark in ipairs(self._project.ogmarks) do
        vim.cmd("edit " .. ogmark.absPath)
        local extmark = vim.api.nvim_buf_get_extmark_by_id(0, self._namespace, ogmark.id, {})
        if #extmark == 0 then
            log:warn("ogmark id=%d did not have corresponding extmark - this is potentially because of data corruption")
        else
            local row, col = table.unpack(extmark)
            local rowText = vim.fn.getline(row + 1)
            log:debug("Updating ogmark id=%d to have row=%d and rowText=%s", ogmark.id, row, rowText)
            ogmark.row = row
            ogmark.rowText = rowText
        end
    end
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
    },
    config = {

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
    },
    "config": {

    }
}
]]
