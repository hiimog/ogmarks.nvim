import { Neovim, workspace, events, BufEvents } from 'coc.nvim';
import { attach, Plugin, NvimPlugin, NeovimClient } from 'neovim';
import * as cp from 'child_process';
import path from 'path';
const startupVim = path.resolve(__dirname, 'vimrc');
let neovimProc: cp.ChildProcess;
let client: NeovimClient;

beforeAll(() => {
  neovimProc = cp.spawn('nvim', ['-u', startupVim, '-i', 'NONE', '--embed'], {
    cwd: __dirname,
  });
  client = attach({ proc: neovimProc });
});

describe('project load', () => {
    it("should load without error", async() => {
        expect(async () => await client.command("CocCommand ogmarks.nvim.Command")).not.toThrowError()
    })
});
