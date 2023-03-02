import { NvimPlugin,  } from 'neovim';

export default function(plugin: NvimPlugin) {
    plugin.registerFunction("TestPlugin", () => {
        plugin.nvim.outWrite("hi!")
    })
}