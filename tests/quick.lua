vim.cmd([[lua og = require("ogmarks")()]])
vim.cmd("e tests/text/lorem.txt")
vim.cmd("lua og:createHere()")