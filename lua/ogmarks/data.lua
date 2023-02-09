--[[
LUA

{
    project = "helloworld"
    ogmarks = {
        {
            id = 1, 
            name = "main config",
            desc = "Where the initial configuration happens from command line values and from environment values",
            row = 12,
            text = "  config.args = sys.argv[1:]",
            absolutePath = "/src/myproject/main.py",
            created = "20230206165944",
            updated = "20230206165944"
        },
        {
            id = 2,
            deleted = true
        },
        {
            id = 3,
            name = "run loop",
            desc = "Where main starts run loop",
            row = 14,
            text = "    run(config).wait()",
            absolutePath = "/src/myproject/main.py",
            created = "20230206166135",
            updated = "20230206166942"
        }
    },
    tags = {
        "config": { 1 },
        "main": { 1, 3 }
    }
}

JSON

{
    "project": "helloworld",
    "ogmarks": [
        {
            "id": 1,
            "name": "main config",
            "desc": "Where the initial configuration happens from command line values and from environment values",
            "row": 12,
            "text": "  config.args = sys.argv[1:]",
            "absolutePath": "/src/myproject/main.py",
            "created": "20230206165944",
            "updated": "20230206165944"
        },
        {
            "id": 2,
            "deleted": true
        },
        {
            "id": 3,
            "name": "run loop",
            "desc": "Where main starts run loop",
            "row": 14,
            "text": "    run(config).wait()",
            "absolutePath": "/src/myproject/main.py",
            "created": "20230206166135",
            "updated": "20230206166942"
        }
    ],
    "tags": {
        "config": [1],
        "main": [1, 3]
    }
}
]]
local config = require("ogmarks.config")
local log = require("ogmarks.log")
local M = {}
M._project = nil

function M:init()
    os.execute("mkdir -p "..config.projectDir)
end

function M:save()
    
end

return M
