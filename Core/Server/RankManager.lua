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
    -- Save to DataStore
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
