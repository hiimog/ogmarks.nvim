set rtp^=/src/ogmarks.nvim
set rtp^=/src/ogmarks.nvim/tests/thirdparty/plenary.nvim
runtime plugin/plenary.vim 

lua require("plenary.busted")