import { NvimPlugin,  } from 'neovim';
import { Plugin } from './plugin';

export default function(plugin: NvimPlugin) {
    const ogMarksPlugin = new Plugin([]);
    plugin.registerFunction("TestPlugin", () => {
        plugin.nvim.outWrite("hi!")
    })
}