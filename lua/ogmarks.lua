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

local function confirmDelete()
    return {
        short = "y",
        long = "yes",
        description = "confirm the deletion",
    }
end

local commands = {
    --function M:cmdProjectList()
    --function M:cmdProjectLoad --loadbufs
    --function M:cmdProjectFix --distance 10 --edit-distance 5
    --function M:cmdProjectDelete
    --function M:cmdProjectRename
    --function M:cmdMarkTag foo bar biz baz
    --function M:cmdMarkDelete
    --function M:cmdMarkAnnotate this is more information about the mark
    {
        name = "ProjectLoad",
        desc = "Load a project",
        flags = {
            {
                short = "o",
                long = "openall",
                desc = "Open all marked files in the current window"
            }
        },
        arguments = {
            {
                name = "name",
                placeholder = "name",
                desc = "name of the project",
                cardinality = "1"
            }
        },
        handler = function(self, event)
            log:debug(function() return "Project load event:\n" .. vim.json.encode(event) end)
            local parsed = self:_cmdProjectLoadParseArgs(event.fargs)
            log:debug("Parsed load args:\n%s", vim.inspect(parsed))
            self:_projLoad(parsed.name)
            if parsed.openall then
                local seen = {}
                self:iter():each(function(ogmark)
                    if seen[ogmark.absPath] then return end
                    seen[ogmark.absPath] = true
                    vim.cmd("edit " .. ogmark.absPath)
                end)
            end
            util.forEachBuf(function(bufId)
                self:_bufSetExtMarks(bufId)
            end)
        end
    },
    {
        name = "ProjectCreate",
        desc = "Create a new project",
        options = {
            {
                short = "i",
                long = "icon",
                desc = "default symbol for all new marks"
            },
        },
        arguments = {
            {
                name = "name",
                placeholder = "name",
                desc = "name of the new project",
                cardinality = "1"
            }
        },
        handler = function(self, event)
            log:debug(function() return "Project creation event:\n" .. vim.json.encode(event) end)
            local parsed = self:_cmdProjectCreateParseArgs(event.fargs)
            local name = parsed.name
            self:_validateProjName(name)
            log:assert(not self:projExists(name), "Project already exists")
            self._proj = self:projCreate(name)
            self._projFile = self:_projFileName(name)
            self:projSave()
        end
    },
    {
        name = "ProjectList",
        desc = "List projects that can be loaded",
        handler = function(self, event)
            local i, t, popen = 0, {}, io.popen
            local pfile = popen('ls -a "'..config.projectDir..'"')
            log:assert(pfile, "Failed to list files")
            for filename in pfile:lines() do
                i = i + 1
                t[i] = filename
            end
            pfile:close()
            return t
        end
    },
    {
        name = "ProjectDelete",
        desc = "Delete a project",
        flags = {
            confirmDelete()
        },
        arguments = {
            {
                name = "name",
                placeholder = "name",
                desc = "name of the project to delete",
                cardinality = "1"
            }
        },
        handler = function(self, event)

        end
    },
    {
        name = "MarkCreate",
        desc = "Create OgMark at the current cursor position",
        options = {
            {
                short = "t",
                long = "tags",
                placeholder = "tag+",
                desc = "tags to add to the mark"
            },
            {
                short = "i",
                long = "icon",
                placeholder = "👉",
                desc = "symbol for the OgMark"
            },
        },
        arguments = {
            {
                name = "desc",
                placeholder = "description",
                desc = "description for the mark",
                cardinality = "+"
            }
        },
        handler = function(self, event)
            log:debug(function() return "Mark creation event:\n" .. vim.json.encode(event) end)
            self:_validateProjActive()
            local parsed = self:_cmdMarkCreateParseArgs(event.fargs)
            log:debug("Parsed mark create args:\n%s", vim.inspect(parsed))
            local newOgMark = self:_createOgMarkAtCursor()
            newOgMark.desc = table.concat(parsed.desc, " ") -- description entered plainly will be a table here
            log:debug("New mark created: \n%s", vim.inspect(newOgMark))
            table.insert(self._proj.ogmarks, newOgMark)
            self:_setExtMark(0, newOgMark)
            self:projSave()
        end
    },
    {
        name = "MarkDelete",
        desc = "Delete the mark at the cursor",
        flags = {
            confirmDelete()
        },
        arguments = {
            {
                name = "name",
                placeholder = "name",
                desc = "name of the project to delete",
                cardinality = "1"
            }
        },
    },
    {
        name = "MarkInfo",
        desc = "Print information about created OgMarks",
        handler = function(self, event)
            log:debug(function() return "Mark info event:\n" .. vim.json.encode(event) end)
            self:_validateProjActive()
            local ogMark = self:_getOgMarkAtCursor()
            log:assert(ogMark, "No OgMark found at position")
            self:_printOgMark(ogMark)
        end
    },
    {
        name = "MarkUpdate",
        desc = "update OgMark tags, description, icon, etc",
        options = {
            {
                short = "t",
                long = "tags",
                desc = "update the associated tags"
            },
            {
                short = "i",
                long = "icon",
                desc = "letter, symbol, emoji that will appear next to the breakpoint"
            }
        },
        arguments = {
            {
                name = "desc",
                placeholder = "description",
                desc = "desc to use for the OgMark",
                cardinality = "+"
            }
        }
    }
}

function M:augroupCreate()
    self._augroupId = vim.api.nvim_create_augroup("ogmarks", { clear = true })
    vim.api.nvim_create_autocmd("BufReadPost", {
        group = self._augroupId,
        desc = "Set extmarks when file is opened",
        callback = function(event)
            if not self._proj then return end
            self:_bufSetExtMarks(event.buf)
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
    for _, cmd in ipairs(commands) do
        log:debug(function() return string.format("Creating command %s\n%s", cmd.name, vim.inspect(cmd)) end)
        self["_cmd" .. cmd.name .. "ParseArgs"] = self:_createCommandParseArgsFunction(cmd)
        vim.api.nvim_create_user_command(config.commandPrefix .. cmd.name, function(event)
            cmd.handler(self, event)
        end, {
            desc = cmd.desc,
            nargs = "*",
            force = true,
        })
    end
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
    local res = util.fileExists(path)
    local trueFalse = "false"
    if res then trueFalse = "true" end
    log:debug("Project exists: %s\n%s\n%s = %s", util.pwd(), name, path, trueFalse)
    return res
end

function M:projSave()
    self:_validateProjActive()
    local file, err = io.open(self._projFile, "w+")
    log:assert(file, function() return "Failed to open project file for writing: " .. err end)
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
    log:debug("Final config: %s", vim.inspect(config))
    self:commandsCreate()
    self:augroupCreate()
end

function M:_bufSetExtMarks(bufId)
    local file = vim.api.nvim_buf_get_name(bufId)
    if file == "" then
        log:debug("Buffer is not backed by a file id=%d", bufId)
        return
    end
    self:iter()
        :filter(function(ogmark) return ogmark.absPath == file end)
        :foreach(function(ogmark)
            log:debug("Setting extmark for ogmark id=%d for buffer id=%d", ogmark.id, bufId)
            self:_setExtMark(bufId, ogmark)
        end)
end

-- function only updates - it does not save anything to disk
function M:_bufUpdateMarks(bufId)
    local file = vim.api.nvim_buf_get_name(bufId)
    if file == "" then return end
    self:iter()
        :filter(function(ogmark) return ogmark.absPath == file end)
        :foreach(function(ogmark)
            local extmark = vim.api.nvim_buf_get_extmark_by_id(bufId, self._namespaceId, ogmark.id, {})
            if #extmark == 0 then
                log:warn("Failed to find ogmark id=%d on buf id=%d for file=%s", ogmark.id, bufId, file)
                return
            end
            local line, col = table.unpack(extmark)
            ogmark.row = line
            ogmark.rowText = util.getLine(bufId, line)
            ogmark.updated = util:timestamp()
        end)
end

-- assumes that ogmark is for this buffer
function M:_setExtMark(bufId, ogmark)
    vim.api.nvim_buf_set_extmark(bufId, self._namespaceId, ogmark.row, 0, {
        id = ogmark.id,
        sign_text = ogmark.icon or self._proj.icon or config.icon
    })
end

function M:_createCommandParseArgsFunction(cmd)
    return function(_self, args)
        local parser = argparse(cmd.name)
        for _, flag in ipairs(cmd.flags or {}) do
            parser:flag("-" .. flag.short .. " --" .. flag.long, flag.desc)
        end
        for _, opt in ipairs(cmd.options or {}) do
            parser:option("-" .. opt.short .. " --" .. opt.long, opt.desc)
        end
        for _, arg in ipairs(cmd.arguments or {}) do
            parser:argument(arg.name, arg.desc):args(arg.cardinality)
        end
        local isParsed, parsedOrError = parser:pparse(args)
        local helpText = parser:get_usage()
        log:assert(isParsed, "Error parsing args: %s\n%s", parsedOrError, helpText)
        return parsedOrError
    end
end

function M:_createOgMarkAtCursor()
    local file, row, col = util.getCursor()
    local rowText = util.getLine(0, row)
    local ts = util:timestamp()
    return {
        absPath = file,
        created = ts,
        desc = nil,
        id = #self._proj.ogmarks + 1,
        row = row,
        rowText = rowText,
        updated = ts,
    }
end

function M:_getOgMarkAtCursor()
    self:_validateProjActive()
    local file, row, col = util.getCursor()
    local extMarks = vim.api.nvim_buf_get_extmarks(0, self._namespaceId, row, row + 1, {})
    if #extMarks == 0 then return nil end
    local id = extMarks[1].id
    return self._proj.ogmarks[id]
end

-- does nothing with setting up commands or creating extmarks -it only
-- loads the file from disk and parses it setting up the project fields
function M:_projLoad(name)
    self:_validateProjName(name)
    if name == (self._proj or {}).name then
        log:debug("Attempt to reopen the current project: %s", name)
        return
    end
    log:assert(self:projExists(name), "Project does not exist")
    self._projFile = self:_projFileName(name)
    local isGood, err = pcall(function()
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
        vim.api.nvim_buf_delete(bufId, { force = true })
    end)

    util.forEachWin(function(winId)
        local isGood, err = pcall(function() vim.api.nvim_win_close(winId, true) end)
        if not isGood and string.find(err or "", "Cannot close last window") ~= nil then return end
    end)

    self._augroupId = nil
    self._namespaceId = nil
    self._projFile = nil
    self._proj = nil
    log:dispose()
end

function M:_projToJson()
    return vim.json.encode(self._proj)
end

function M:_projFromFile(path)
    local file, err = io.open(path, "r")
    log:assert(file, function() return "Failed to open project file: " .. err end)
    if not file then return end
    local json = file:read("a")
    return self:_projFromJson(json)
end

function M:_projFromJson(json)
    return vim.json.decode(json)
end

function M:_projFileName(name)
    self:_validateProjName(name)
    if config.projectDir:sub(#config.projectDir) == "/" then
        return config.projectDir .. name .. ".json"
    end
    return config.projectDir .. "/" .. name .. ".json"
end

function M:_validateProjName(name)
    local nameErr = s.CheckSchema(name, schemaProjName)
    log:assert(nameErr == nil, function() return "Invalid project name: " .. s.FormatOutput(nameErr) end)
end

function M:_validateProjActive()
    log:assert(self._proj, "No active project")
    log:assert(self._projFile, "Project exists, but no filename -this is a bug")
end

function M:_printOgMark(ogMark)
    log:assert(ogMark, "OgMark must be provided for printing")
    local tags = table.concat(ogMark.tags or {}, ", ")
    local text = string.format([[ID: %d
DESC: %s
TAGS: %s
FILE: %s
ROW: %d
TEXT: %s
]], ogMark.id, ogMark.desc, tags, ogMark.absPath, ogMark.row, ogMark.rowText)
    print(text)
    return text
end

return M
