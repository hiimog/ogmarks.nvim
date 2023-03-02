import { OgMark } from './types';
import { NeovimClient } from 'neovim'

export class Plugin {
    public ogmarks: OgMark[];
    private nvim: NeovimClient;

    constructor(nvim: NeovimClient) {
        this.ogmarks = [];
        this.nvim = nvim;
    }
}