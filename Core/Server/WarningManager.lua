local WarningManager = {}
local DataStore = require(script.Parent.DataStore)
local Players = game:GetService("Players")

local WarningCache = {} -- [UserId] = { { Reason, ModeratorName, ModeratorId, Timestamp }, ... }

function WarningManager.WarnPlayer(userId, reason, moderatorName, moderatorId)
    if not WarningCache[userId] then
        WarningCache[userId] = {}
    end

    local warning = {
        Reason = reason or "No reason provided.",
        ModeratorName = moderatorName or "Unknown",
        ModeratorId = moderatorId or 0,
        Timestamp = os.time()
    }

    table.insert(WarningCache[userId], warning)
    DataStore.Save("Warnings_" .. userId, WarningCache[userId])

    return #WarningCache[userId]
end

function WarningManager.GetPlayerWarnings(userId)
    if not WarningCache[userId] then
        return {}
    end
    return WarningCache[userId]
end

function WarningManager.GetWarningCount(userId)
    if not WarningCache[userId] then
        return 0
    end
    return #WarningCache[userId]
end

function WarningManager.ClearWarnings(userId)
    WarningCache[userId] = nil
    DataStore.Delete("Warnings_" .. userId)
    return true
end

function WarningManager.RemoveWarning(userId, warningIndex)
    if not WarningCache[userId] or warningIndex < 1 or warningIndex > #WarningCache[userId] then
        return false
    end

    table.remove(WarningCache[userId], warningIndex)
    if #WarningCache[userId] == 0 then
        WarningCache[userId] = nil
        DataStore.Delete("Warnings_" .. userId)
    else
        DataStore.Save("Warnings_" .. userId, WarningCache[userId])
    end

    return true
end

function WarningManager.LoadPlayerWarnings(userId)
    -- Load warnings from DataStore (called on player join)
    -- Placeholder for actual DataStore implementation
end

function WarningManager.NotifyPlayerWarned(player, moderatorName, reason, warningCount)
    local Remote = game:GetService("ReplicatedStorage"):FindFirstChild("NexusAdmin_Warning")
    if not Remote then
        Remote = Instance.new("RemoteEvent")
        Remote.Name = "NexusAdmin_Warning"
        Remote.Parent = game:GetService("ReplicatedStorage")
    end
    Remote:FireClient(player, moderatorName, reason, warningCount)
end

return WarningManager
