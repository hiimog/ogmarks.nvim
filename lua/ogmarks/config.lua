local vim = vim
local M =  {}
M.logging = {
    level = "debug",
    file = "/tmp/ogmarks.log"
}
M.projectDir = vim.fn.stdpath("data") .. "/ogmarks"
M.cmdPrefix = "OgMarks"

return M
