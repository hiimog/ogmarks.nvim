local vim = vim
local M =  {
    logging = {
        level = "debug",
        file = "/tmp/ogmarks.log"
    },
    projectDir = vim.fn.stdpath("data") .. "/ogmarks",
    commandPrefix = "OgMarks",
}

return M
