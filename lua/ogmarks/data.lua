return function(config)
    local data = {}
    local sqlite = require("lsqlite3")

    local db, errCode, errMsg = sqlite.open(config.db.file)

    return data
end