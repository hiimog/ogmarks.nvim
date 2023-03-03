import { NvimPlugin } from 'neovim';
import {Plugin} from './plugin';
export default async function(plugin: NvimPlugin) {
    const ogMarks = new Plugin(plugin)
    await ogMarks.registerCommands()
}