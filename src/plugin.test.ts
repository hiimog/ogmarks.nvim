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
        nvim.on("request", (method: string, args: any[]) => {
            requests.push([method, args])
        })
        nvim.on("notification", (method: string, args: any[]) => {
            notifications.push([method, args])
        })
    })

    beforeEach(() => {
        requests = [];
        notifications = []
    })

    it("should load", () => {
        //const p = new Plugin()
    })
})