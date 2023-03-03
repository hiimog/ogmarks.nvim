import { Plugin } from "./plugin"
import { ChildProcess, spawn } from 'child_process'
import { attach, NeovimClient } from "neovim";


describe("Plugin", () => {
    let neovimProc: ChildProcess;
    let nvim: NeovimClient;
    let requests:[string, any[]][] = [];
    let notifications: [string, any[]][] = [];
    beforeAll(() => {
        neovimProc = spawn("nvim", ["--embed"], {
        })
        nvim = attach({proc: neovimProc})
    })

    afterAll(() => {
        nvim.quit()
        neovimProc.kill()
    })

    beforeEach(() => {
        requests = [];
        notifications = []
    })

    it("should load", async () => {
        const got = await nvim.call("abs", [-1])
        expect(got).toEqual(1)
    })

    it("should load plugin", async() => {
    })
})