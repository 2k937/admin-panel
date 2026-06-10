local RankManager = {}
local Config = require(script.Parent.Parent.Shared.Config)
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")

local PlayerRanks = {} -- [UserId] = RankLevel
local CustomRanks = {} -- [Level] = RankData
local CachedGroupOwnerUserId = nil
local CachedGroupOwnerLoaded = false

local function getPlaceOwnerConfig()
    local access = Config.Access or {}
    local placeOwner = access.PlaceOwner or {}
    return {
        Enabled = placeOwner.Enabled ~= false,
        Level = placeOwner.Level or 255,
        Name = placeOwner.Name or "Place Owner",
        Color = placeOwner.Color or Color3.fromRGB(255, 0, 0),
        Icon = placeOwner.Icon or "rbxassetid://0"
    }
end

local function getGroupOwnerUserId()
    if CachedGroupOwnerLoaded then
        return CachedGroupOwnerUserId
    end

    CachedGroupOwnerLoaded = true
    if game.CreatorType ~= Enum.CreatorType.Group then
        return nil
    end

    local success, groupInfo = pcall(function()
        return GroupService:GetGroupInfoAsync(game.CreatorId)
    end)

    if success and groupInfo and groupInfo.Owner and groupInfo.Owner.Id then
        CachedGroupOwnerUserId = groupInfo.Owner.Id
    end

    return CachedGroupOwnerUserId
end

local function getBestGroupAccess(player)
    local groupRankConfig = ((Config.Access or {}).GroupRanks or {})
    if groupRankConfig.Enabled ~= true or not groupRankConfig.Groups then
        return nil
    end

    local bestAccess = nil

    for _, rule in ipairs(groupRankConfig.Groups) do
        local groupId = tonumber(rule.GroupId)
        local minimumRank = tonumber(rule.MinimumRank) or 0
        local accessLevel = tonumber(rule.Level) or ((Config.Access or {}).MinimumPanelLevel or 20)

        if groupId and groupId > 0 then
            local success, playerGroupRank = pcall(function()
                return player:GetRankInGroup(groupId)
            end)

            if success and playerGroupRank >= minimumRank and playerGroupRank > 0 then
                if not bestAccess or accessLevel > bestAccess.Level then
                    bestAccess = {
                        Level = accessLevel,
                        Name = rule.Name or ("Group Rank " .. tostring(playerGroupRank)),
                        GroupId = groupId,
                        GroupRank = playerGroupRank,
                        MinimumRank = minimumRank
                    }
                end
            end
        end
    end

    return bestAccess
end

function RankManager.Init()
    -- Load from DataStore in real implementation
end

function RankManager.IsPlaceOwner(player)
    local placeOwner = getPlaceOwnerConfig()
    if not placeOwner.Enabled or not player then
        return false
    end

    if game.CreatorType == Enum.CreatorType.User then
        return player.UserId == game.CreatorId
    end

    if game.CreatorType == Enum.CreatorType.Group then
        local ownerUserId = getGroupOwnerUserId()
        if ownerUserId and player.UserId == ownerUserId then
            return true
        end

        -- Fallback: Roblox group owners normally have rank 255 in their group.
        local success, rank = pcall(function()
            return player:GetRankInGroup(game.CreatorId)
        end)
        return success and rank >= 255
    end

    return false
end

function RankManager.IsProtectedPlayer(player)
    return RankManager.IsPlaceOwner(player)
end

function RankManager.IsProtectedUserId(userId)
    if game.CreatorType == Enum.CreatorType.User and userId == game.CreatorId then
        return true
    end

    if game.CreatorType == Enum.CreatorType.Group then
        local ownerUserId = getGroupOwnerUserId()
        return ownerUserId ~= nil and userId == ownerUserId
    end

    return false
end

function RankManager.GetManualRank(userId)
    return PlayerRanks[userId] or 0
end

function RankManager.GetGroupAccess(player)
    return getBestGroupAccess(player)
end

function RankManager.GetPlayerRank(player)
    if RankManager.IsPlaceOwner(player) then
        return getPlaceOwnerConfig().Level
    end

    local manualLevel = RankManager.GetManualRank(player.UserId)
    local groupAccess = RankManager.GetGroupAccess(player)
    local groupLevel = groupAccess and groupAccess.Level or 0

    return math.max(manualLevel, groupLevel)
end

function RankManager.SetPlayerRank(userId, level)
    if RankManager.IsProtectedUserId(userId) then
        return false, "The Place Owner role is automatic and cannot be edited."
    end

    PlayerRanks[userId] = level
    local DataStore = require(script.Parent.DataStore)
    DataStore.Save("Rank_" .. userId, level)

    local target = Players:GetPlayerByUserId(userId)
    if target then
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local rankData = RankManager.GetRankData(level)
        ReplicatedStorage:WaitForChild("NexusAdmin_Notify"):FireClient(target, "Nexus Admin", "You have been ranked to " .. rankData.Name)
    end

    return true
end

function RankManager.LoadPlayerRank(player)
    if RankManager.IsPlaceOwner(player) then
        return getPlaceOwnerConfig().Level
    end

    local DataStore = require(script.Parent.DataStore)
    local savedLevel, success = DataStore.Get("Rank_" .. player.UserId)
    if success and savedLevel then
        PlayerRanks[player.UserId] = savedLevel
    end

    return RankManager.GetPlayerRank(player)
end

function RankManager.CreateCustomRank(name, level, color, icon)
    local placeOwner = getPlaceOwnerConfig()
    if level == placeOwner.Level then
        return false, "The Place Owner rank is protected and cannot be replaced."
    end

    CustomRanks[level] = {
        Name = name,
        Level = level,
        Color = color,
        Icon = icon
    }

    return true
end

function RankManager.GetRankData(level)
    local placeOwner = getPlaceOwnerConfig()
    if level == placeOwner.Level then
        return {
            Name = placeOwner.Name,
            Level = placeOwner.Level,
            Color = placeOwner.Color,
            Icon = placeOwner.Icon,
            Protected = true
        }
    end

    return CustomRanks[level] or Config.DefaultRanks[level] or Config.DefaultRanks[0]
end

function RankManager.GetPermissionData(player)
    local isPlaceOwner = RankManager.IsPlaceOwner(player)
    local groupAccess = RankManager.GetGroupAccess(player)
    local manualLevel = RankManager.GetManualRank(player.UserId)
    local level = RankManager.GetPlayerRank(player)
    local rankData = RankManager.GetRankData(level)
    local minimumPanelLevel = ((Config.Access or {}).MinimumPanelLevel or 20)
    local accessSource = "ManualRank"
    local rankName = rankData.Name

    if isPlaceOwner then
        accessSource = "PlaceOwner"
    elseif groupAccess and groupAccess.Level >= manualLevel then
        accessSource = "GroupRank"
        rankName = groupAccess.Name
    end

    return {
        CanOpen = isPlaceOwner or level >= minimumPanelLevel,
        Level = level,
        RankName = rankName,
        IsPlaceOwner = isPlaceOwner,
        Protected = rankData.Protected == true,
        AccessSource = accessSource,
        GroupId = groupAccess and groupAccess.GroupId or nil,
        GroupRank = groupAccess and groupAccess.GroupRank or nil
    }
end

return RankManager
