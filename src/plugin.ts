import { OgMark } from './types';

export class Plugin {
    public ogmarks: OgMark[];

    constructor(ogmarks: OgMark[]) {
        this.ogmarks = ogmarks;
    }
}