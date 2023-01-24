return function(config)
    local data = {}
    local sqlite = require("lsqlite3")

    local db, _, errMsg = sqlite.open(config.db.file)
    if errMsg ~= nil then return nil, errMsg end

    data._db = db

    return data, nil
end