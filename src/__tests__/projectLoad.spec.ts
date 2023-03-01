import { Neovim, workspace, events, BufEvents } from 'coc.nvim';
import { attach, Plugin, NvimPlugin, NeovimClient } from 'neovim';
import * as cp from 'child_process';
import path from 'path';
const startupVim = path.resolve(__dirname, 'startup.vim');
let neovimProc: cp.ChildProcess;
let client: NeovimClient;
beforeAll(async () => {
  neovimProc = cp.spawn('nvim', ['-u', startupVim, '-i', 'NONE', '--embed'], {
    cwd: __dirname,
  });
  client = attach({ proc: neovimProc });
  await new Promise((resolve) => setTimeout(resolve, 3 * 1000))

});

afterAll(() => {
    client.quit()
})

describe('project load', () => {
  it('should load without error', async () => {
    await client.command('CocInfo')
    const line = await client.getLine()
    expect(line).toEqual("bufId=1")
  });
});
