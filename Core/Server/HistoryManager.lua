local HistoryManager = {}
local DataStore = require(script.Parent.DataStore)
local Players = game:GetService("Players")

local PlayerSessions = {} -- [UserId] = { JoinTime = number }

function HistoryManager.OnPlayerJoin(player)
    PlayerSessions[player.UserId] = {
        JoinTime = os.time()
    }
    
    -- Load existing history
    local history, success = DataStore.Get("History_" .. player.UserId)
    if not success or not history then
        history = {
            FirstJoin = os.time(),
            LastJoin = os.time(),
            TotalJoins = 0,
            TotalPlayTime = 0,
            Logins = {}
        }
    end
    
    history.LastJoin = os.time()
    history.TotalJoins = (history.TotalJoins or 0) + 1
    
    -- Keep only last 10 login timestamps to save space
    table.insert(history.Logins, 1, os.time())
    if #history.Logins > 10 then
        table.remove(history.Logins, 11)
    end
    
    DataStore.Save("History_" .. player.UserId, history)
end

function HistoryManager.OnPlayerLeave(player)
    local session = PlayerSessions[player.UserId]
    if session then
        local playTime = os.time() - session.JoinTime
        
        local history, success = DataStore.Get("History_" .. player.UserId)
        if success and history then
            history.TotalPlayTime = (history.TotalPlayTime or 0) + playTime
            DataStore.Save("History_" .. player.UserId, history)
        end
        
        PlayerSessions[player.UserId] = nil
    end
end

function HistoryManager.GetPlayerHistory(userId)
    local history, success = DataStore.Get("History_" .. userId)
    if success and history then
        -- Add current session time if player is online
        local session = PlayerSessions[userId]
        if session then
            history.CurrentSessionTime = os.time() - session.JoinTime
        end
        return history
    end
    return nil
end

return HistoryManager
