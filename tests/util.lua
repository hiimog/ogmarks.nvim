local M = {}

function M:timestamp()
    return os.date("%Y%m%d%H%M%S")
end

function M:createSpecFileName(specName)
    local processedSpecName = string.gsub(specName, " ", "_")
    return string.format("%s_%s", self:timestamp(), processedSpecName)
end

function M:createSpecLogName(specName)
    return self:createSpecFileName(specName) .. ".log"
end

function M:createSpecDbName(specName)
    return self:createSpecFileName(specName) .. ".db"
end

return M