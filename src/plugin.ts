import { OgMark } from './types';
import { NvimPlugin } from 'neovim'

export class Plugin {
    public ogmarks: OgMark[];
    private nvimPlugin: NvimPlugin;

    constructor(nvim: NvimPlugin) {
        this.ogmarks = [];
        this.nvimPlugin = nvim;
    }

    public async sayHi() {
        await this.nvimPlugin.nvim.setLine("hi from ogmarks.nvim!")
    }

    public async registerCommands() {
        this.nvimPlugin.registerCommand("FindMe", async () => {
            this.sayHi()
        })
    }
}