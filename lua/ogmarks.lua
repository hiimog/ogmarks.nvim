local util = require("ogmarks.util")
local log = require("ogmarks.log")
local fn = require("lua.thirdparty.fun")
local config = require("ogmarks.config")
local s = require("lua.thirdparty.schema")
local argparse = require("lua.thirdparty.argparse")

local M = {
    _proj = nil,
    _projFile = nil,
    _namespaceId = nil,
    _augroupId = nil
}

local schemaProjName = s.Pattern("^[a-zA-Z0-9_-]+$")
local schemaSetup = s.Record {
    projectDir = s.Optional(s.String),
    logging = s.Optional(s.Record {
        file = s.Optional(s.String),
        level = s.Optional(s.OneOf("debug", "info", "warn", "error"))
    })
}

function M:augroupCreate()
    self._augroupId = vim.api.nvim_create_augroup("ogmarks", { clear = true})
    vim.api.nvim_create_autocmd("BufReadPost", {
        group = self._augroupId,
        desc = "Set extmarks when file is opened",
        callback = function(event)
            if not self._proj then return end
            self:_bufLoadMarks(event.buf)
        end
    })
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = self._augroupId,
        desc = "Update ogmarks for buffer when written",
        callback = function(event)
            if not self._proj then return end
            self:_bufUpdateMarks(event.buf)
            self:projSave()
        end
    })
end

function M:commandsCreate()
    vim.api.nvim_create_user_command(config.commandPrefix.."ProjectCreate", function (event)
        self:cmdProjectCreate(event)
    end, {
        desc = "Create a new project",
        nargs = 1,
    })
    vim.api.nvim_create_user_command(config.commandPrefix.."ProjectLoad", function(event)
        self:cmdProjectLoad(event)
    end, {
        desc = "Load a project from disk",
        nargs = 1,
    })
end

function M:iter()
    local source = {}
    if self._proj then source = self._proj.ogmarks or {} end
    return fn.filter(function(ogmark) return not ogmark.deleted end, source)
end

function M:projCreate(name)
    self:_validateProjName(name)
    return {
        name = name,
        ogmarks = {},
        tags = {},
        settings = {}
    }
end

function M:projExists(name)
    self:_validateProjName(name)
    local path = self:_projFileName(name)
    return util.fileExists(path)
end

function M:projSave()
    self:_validateProjActive()
    local file, err = io.open(self._projFile, "w+")
    log:assert(file, function() return "Failed to open project file for writing: "..err end)
    if not file then return end
    local json = self:_projToJson()
    file:write(json)
    file:close()
end

function M:setup(cfg)
    cfg = cfg or {}
    cfg.logging = cfg.logging or {}
    local cfgErr = s.CheckSchema(cfg, schemaSetup)
    assert(cfgErr == nil, function() return "Config invalid: " .. s.FormatOutput(cfgErr) end)
    if cfg.projectDir then config.projectDir = cfg.projectDir end
    if cfg.logging.file then config.logging.file = cfg.logging.file end
    if cfg.logging.level then config.logging.level = cfg.logging.level end
    self._namespaceId = vim.api.nvim_create_namespace("ogmarks")
    util.mkDir(config.projectDir)
    log:init() -- can use logging after this
    self:commandsCreate()
    self:augroupCreate()
end

function M:cmdProjectCreate(event)
    log:assert(self._proj == nil, "Save any open buffers and restart nvim to create a new project")
    local parsed = self:_cmdProjectCreateParseArgs(event.fargs)
    local name = parsed.name
    self:_validateProjName(name)
    log:assert(not self:projExists(name), "Project already exists")
    self._proj = self:projCreate(name)
    self._projFile = self:_projFileName(name)
    self:projSave()
end

function M:cmdProjectLoad(event)
    log:assert(self._projFile == nil, "Project is open, save all work and restart nvim")
    local parsed = self:_cmdProjectLoadParseArgs(event.fargs)
    self:_projLoad(parsed.file)
    util.forEachBuf(function (bufId)
        self:_bufLoadMarks(bufId)
    end)
end

--function M:cmdProjectList()
--function M:cmdProjectLoad --loadbufs
--function M:cmdProjectFix --distance 10 --edit-distance 5
--function M:cmdProjectDelete
--function M:cmdProjectRename
--function M:cmdMarkCreate program start
--function M:cmdMarkTag foo bar biz baz
--function M:cmdMarkDelete
--function M:cmdMarkAnnotate this is more information about the mark
 

function M:_bufLoadMarks(bufId)
    local file = vim.api.nvim_buf_get_name(bufId)
    if file == "" then 
        log:debug("Buffer is not backed by a file id=%d", bufId)
        return
    end
    self:iter()
        :filter(function(ogmark) return ogmark.absPath == file end)
        :foreach(function (ogmark)
            log:debug("Setting ogmark id=%d for buffer id=%d", ogmark.id, bufId)
            self:_setExtMark(bufId, ogmark)
        end)
end

-- function only updates - it does not save anything to disk
function M:_bufUpdateMarks(bufId)
    local file = vim.api.nvim_buf_get_name(bufId)
    if file == "" then return end
    self:iter()
        :filter(function(ogmark) return ogmark.absPath == file end)
        :foreach(function (ogmark)
            local extmark = vim.api.nvim_buf_get_extmark_by_id(bufId, self._namespaceId, ogmark.id, {})
            if #extmark == 0 then
                log:warn("Failed to find ogmark id=%d on buf id=%d for file=%s", ogmark.id, bufId, file)
                return
            end
            local line, col = table.unpack(extmark)
            ogmark.row = line
            ogmark.rowText = util.getLine(bufId, line)
            ogmark.update = util.timestamp()
        end)
end

-- assumes that ogmark is for this buffer
function M:_setExtMark(bufId, ogmark)
    vim.api.nvim_buf_set_extmark(bufId, self._namespaceId, ogmark.row, 0, {
        id = ogmark.id,
        sign_text = ogmark.icon or self._proj.icon or config.icon
    })
end

function M:_cmdProjectCreateParseArgs(args)
    local parser = argparse("ProjectCreate")
    parser:argument("name", "name of the new project"):args(1)
    local isParsed, parsedOrError = parser:pparse(args)
    local helpText = parser:get_usage()
    log:assert(isParsed, "Error parsing arguments: %s\n%s", parsedOrError, helpText)
    return parsedOrError
end

function M:_cmdProjectLoadParseArgs(args)
    local parser = argparse("ProjectLoad")
    parser:argument("name", "name of the project"):args(1)
    local isParsed, parsedOrError = parser:pparse(args)
    local helpText = parser:get_usage()
    log:assert(isParsed, "Error parsing arguments: %s\n%s", parsedOrError, helpText)
    return parsedOrError
end

-- does nothing with setting up commands or creating extmarks -it only
-- loads the file from disk and parses it setting up the project fields
function M:_projLoad(name)
    self:_validateProjName(name)
    log:assert(self:projExists(name), "Project does not exist")
    self._projFile = self:_projFileName(name)
    local isGood, err = pcall(function ()
        self._proj = self:_projFromFile(self._projFile)
    end)
    if not isGood then
        self._projFile = nil 
        self._proj = nil
    end
end

function M:_nuke()
    if self._augroupId then
        -- delete all commands
        vim.api.nvim_del_augroup_by_id(self._augroupId)
    end

    util.forEachBuf(function(bufId)
        -- delete all extmarks and highlights and force close the buffer
        if not self._namespaceId then return end
        vim.api.nvim_buf_clear_namespace(bufId, self._namespaceId, 0, -1)
        vim.api.nvim_buf_delete(bufId, {force=true})
    end)

    util.forEachWin(function(winId)
        local isGood, err = pcall(function() vim.api.nvim_win_close(winId, true) end)
        if not isGood and string.find(err or "", "Cannot close last window") ~= nil then return end
    end)

    vim.api.nvim_del_user_command(config.commandPrefix.."ProjectCreate")

    self._augroupId = nil 
    self._namespaceId = nil
    self._projFile = nil
    self._proj = nil
    log:dispose()
end

function M:_projToJson()
    return vim.json.encode(self._proj)
end

function M:_projFromFile(file)
    local opened, err = io.open(file, "r")
    log:assert(opened, function() return "Failed to open project file: " .. err end)
    if not opened then return end
    local json = opened:read("a")
    return self:_projFromJson(json)
end

function M:_projFromJson(json)
    return vim.json.decode(json)
end

function M:_projFileName(name)
    self:_validateProjName(name)
    return config.projectDir.."/"..name..".json"
end

function M:_validateProjName(name)
    local nameErr = s.CheckSchema(name, schemaProjName)
    log:assert(nameErr == nil, function() return "Invalid project name: " .. s.FormatOutput(nameErr) end)
end

function M:_validateProjActive()
    log:assert(self._proj, "No active project")
    log:assert(self._projFile, "Project exists, but no filename -this is a bug")
end

return M