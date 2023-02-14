:lua og = require("ogmarks")
:lua og:createAutoCmds()
:lua og:setup({projectDir="/tmp/"})
:lua og:new("test")
:e tests/text/lorem.txt
:4
:lua og:mark()