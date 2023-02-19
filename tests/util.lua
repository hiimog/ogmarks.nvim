local fn = require("lua.thirdparty.fun")
local vim = vim 

local M = {}

function M.timestamp()
    return os.date("%Y%m%d%H%M%S")
end


function M.defaultConfig()
    return {
        logging = {
            file = "/tmp/"..M.timestamp()..".log",
            level = "debug"
        },
        projectDir = "/tmp/",
    }
end

function M.lorem(row)
    vim.cmd("edit /src/ogmarks.nvim/tests/text/lorem.txt")
    if row ~= nil then vim.cmd(tostring(row)) end   
end

return M
