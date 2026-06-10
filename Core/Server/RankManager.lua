local RankManager = {}
local Config = require(script.Parent.Parent.Shared.Config)

local PlayerRanks = {} -- [UserId] = RankLevel
local CustomRanks = {} -- [Level] = RankData

function RankManager.Init()
    -- Load from DataStore in real implementation
end

function RankManager.GetPlayerRank(player)
    if player.UserId == game.CreatorId then return 255 end -- Highest possible internal level
    return PlayerRanks[player.UserId] or 0
end

function RankManager.SetPlayerRank(userId, level)
    PlayerRanks[userId] = level
    local DataStore = require(script.Parent.DataStore)
    DataStore.Save("Rank_" .. userId, level)
    
    local Players = game:GetService("Players")
    local target = Players:GetPlayerByUserId(userId)
    if target then
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local rankData = RankManager.GetRankData(level)
        ReplicatedStorage:WaitForChild("NexusAdmin_Notify"):FireClient(target, "Rank Updated", "You have been ranked to: " .. rankData.Name)
    end
end

function RankManager.LoadPlayerRank(player)
    local DataStore = require(script.Parent.DataStore)
    local savedLevel, success = DataStore.Get("Rank_" .. player.UserId)
    if success and savedLevel then
        PlayerRanks[player.UserId] = savedLevel
        return savedLevel
    end
    return 0
end

function RankManager.CreateCustomRank(name, level, color, icon)
    CustomRanks[level] = {
        Name = name,
        Level = level,
        Color = color,
        Icon = icon
    }
end

function RankManager.GetRankData(level)
    return CustomRanks[level] or Config.DefaultRanks[level]
end

return RankManager
