import { NvimPlugin,  } from 'neovim';

export default function(plugin: NvimPlugin) {
    plugin.setOptions({dev: true})
    plugin.registerFunction("TestFunc", () => {
        plugin.nvim.outWrite("hi!")
    })
}