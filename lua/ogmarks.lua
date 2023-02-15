local util = require("ogmarks.util")
local log = require("ogmarks.log")
local fn = require("lua.thirdparty.fun")
local config = require("ogmarks.config")
local s = require("lua.thirdparty.schema")
local argparse = require("lua.thirdparty.argparse")

local M = {
    _project = nil,
    _projectFile = nil,
}

local schemaProjName = s.Pattern("^[a-zA-Z0-9_-]+$")
local schemaSetup = s.Record {
    projectDir = s.Optional(s.String),
    logging = s.Optional(s.Record {
        file = s.Optional(s.String),
        level = s.Optional(s.OneOf("debug", "info", "warn", "error"))
    })
}

function M:iter()
    local source = {}
    if self._project then source = self._project.ogmarks end
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
    local file, err = io.open(self._projectFile, "w+")
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
    assert(cfgErr == nil, function() return "Config invalid: " .. cfgErr end)
    if cfg.projectDir then config.projectDir = cfg.projectDir end
    if cfg.logging.file then config.logging.file = cfg.logging.file end
    if cfg.logging.level then config.logging.level = cfg.logging.level end
    util.mkDir(config.projectDir)
    log:init() -- can use logging after this
end

function M:cmdProjectCreate(event)
    log:assert(self._project == nil, "Save any open buffers and restart nvim to create a new project")
    local parsed = self:_cmdProjectCreateParseArgs(event.fargs)
    local name = parsed.name;
    self:_validateProjName(name)
    log:assert(not self:projExists(name), "Project already exists")
    self._project = self:projCreate(name)
    self._projectFile = self:_projFileName(name)
    self:projSave()
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
 

function M:_cmdProjectCreateParseArgs(args)
    local parser = argparse("ProjectCreate")
    parser:argument("name", "name of the new project"):args(1)
    local isParsed, parsedOrError = parser:pparse(args)
    local helpText = parser:get_usage()
    log:assert(isParsed, "Error parsing arguments: %s\n%s", parsedOrError, helpText)
    return parsedOrError
end

function M:_projToJson()
    return vim.json.encode(self._project)
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
    log:assert(nameErr == nil, function() return "Invalid project name: " .. nameErr end)
end

function M:_validateProjActive()
    log:assert(self._project, "No active project")
    log:assert(self._projectFile, "Project exists, but no filename -this is a bug")
end

return M