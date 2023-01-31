set rtp^=/src/ogmarks.nvim
set rtp^=/src/ogmarks.nvim/tests/thirdparty/plenary.nvim
set rtp^=/src/ogmarks.nvim/tests/thirdparty/plenary.nvim/lua
runtime /src/ogmarks.nvim/tests/thirdparty/plenary.nvim/plugin/plenary.vim

lua require("plenary.busted")
