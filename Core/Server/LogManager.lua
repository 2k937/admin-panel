local LogManager = {}
local DataStore = require(script.Parent.DataStore)

local Logs = {
    Commands = {},
    Joins = {},
    Punishments = {}
}

function LogManager.AddLog(type, data)
    table.insert(Logs[type], {
        Time = os.time(),
        Data = data
    })
    
    -- Keep only last 100 logs in memory
    if #Logs[type] > 100 then
        table.remove(Logs[type], 1)
    end
end

function LogManager.GetLogs(type)
    return Logs[type]
end

return LogManager
