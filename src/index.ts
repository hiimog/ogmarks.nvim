import { NvimPlugin,  } from 'neovim';

export default function(plugin: NvimPlugin) {
    plugin.nvim.outWrite("THIS IS A START")
    plugin.setOptions({dev: true})
    plugin.registerCommand("FindMe", async () => {
        await plugin.nvim.setLine("you found me")
    })
    plugin.registerFunction("TestFunc", async () => {
        await plugin.nvim.setLine("test func")
    })
}