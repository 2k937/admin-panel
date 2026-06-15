local BanManager = {}
local DataStore = require(script.Parent.DataStore)
local Players = game:GetService("Players")

local BanCache = {} -- [UserId] = { Reason, BannedAt, Duration, Permanent }

local function isBanned(userId)
    local banData = BanCache[userId]
    if not banData then
        return false
    end

    if banData.Permanent then
        return true
    end

    local currentTime = os.time()
    local banExpireTime = (banData.BannedAt or 0) + (banData.Duration or 0)

    if currentTime < banExpireTime then
        return true
    else
        BanCache[userId] = nil
        local key = banData.IsGlobal and "GlobalBan_" .. userId or "Ban_" .. userId
        DataStore.Delete(key)
        return false
    end
end

function BanManager.BanPlayer(userId, reason, duration, isGlobal)
    -- duration: nil or 0 = permanent, number = seconds
    local isPermanent = (duration == nil or duration == 0)
    local banData = {
        Reason = reason or "Banned by an admin.",
        BannedAt = os.time(),
        Duration = duration or 0,
        Permanent = isPermanent,
        IsGlobal = isGlobal == true
    }

    local key = isGlobal and "GlobalBan_" .. userId or "Ban_" .. userId
    BanCache[userId] = banData
    DataStore.Save(key, banData)

    local player = Players:GetPlayerByUserId(userId)
    if player then
        local kickMessage = (isGlobal and "[GLOBAL BAN] " or "[BAN] ") .. reason
        if not isPermanent then
            local durationMinutes = math.floor(duration / 60)
            kickMessage = kickMessage .. " (Duration: " .. durationMinutes .. " minutes)"
        end
        player:Kick(kickMessage)
    end

    return true
end

function BanManager.UnbanPlayer(userId, isGlobal)
    BanCache[userId] = nil
    DataStore.Delete("Ban_" .. userId)
    if isGlobal ~= false then
        DataStore.Delete("GlobalBan_" .. userId)
    end
    return true
end

function BanManager.IsBanned(userId)
    return isBanned(userId)
end

function BanManager.GetBanInfo(userId)
    local banData = BanCache[userId]
    if not banData then
        return nil
    end

    if not banData.Permanent then
        local currentTime = os.time()
        local banExpireTime = banData.BannedAt + banData.Duration
        if currentTime >= banExpireTime then
            BanCache[userId] = nil
            DataStore.Delete("Ban_" .. userId)
            return nil
        end
    end

    return banData
end

function BanManager.LoadBans()
    -- Load all bans from DataStore (called on server startup)
    -- This is a placeholder; actual implementation depends on DataStore design
end

function BanManager.CheckPlayerOnJoin(player)
    -- Check local cache first
    local banInfo = BanManager.GetBanInfo(player.UserId)
    
    -- If not in cache, check Global DataStore
    if not banInfo then
        local globalData, success = DataStore.Get("GlobalBan_" .. player.UserId)
        if success and globalData then
            banInfo = globalData
            BanCache[player.UserId] = globalData
        end
    end

    if banInfo then
        local isGlobal = banInfo.IsGlobal == true
        local kickMessage = (isGlobal and "[GLOBAL BAN] " or "[BAN] ") .. (banInfo.Reason or "No reason provided.")
        
        if not banInfo.Permanent then
            local currentTime = os.time()
            local banExpireTime = banInfo.BannedAt + banInfo.Duration
            local remainingSeconds = banExpireTime - currentTime
            
            if remainingSeconds <= 0 then
                -- Ban expired
                BanManager.UnbanPlayer(player.UserId, isGlobal)
                return false
            end
            
            local minutes = math.floor(remainingSeconds / 60)
            local seconds = remainingSeconds % 60
            kickMessage = kickMessage .. " (Expires in " .. minutes .. "m " .. seconds .. "s)"
        end
        
        player:Kick(kickMessage)
        return true
    end
    return false
end

function BanManager.GetAllBans()
    -- Returns all active and inactive bans
    local allBans = {}
    for userId, banData in pairs(BanCache) do
        table.insert(allBans, {
            UserId = userId,
            Reason = banData.Reason,
            BannedAt = banData.BannedAt,
            Duration = banData.Duration,
            Permanent = banData.Permanent,
            ExpiresAt = banData.BannedAt + banData.Duration
        })
    end
    return allBans
end

function BanManager.GetActiveBans()
    -- Returns only active bans
    local activeBans = {}
    local currentTime = os.time()

    for userId, banData in pairs(BanCache) do
        if banData.Permanent then
            table.insert(activeBans, {
                UserId = userId,
                Reason = banData.Reason,
                BannedAt = banData.BannedAt,
                Duration = banData.Duration,
                Permanent = true,
                Status = "Permanent"
            })
        else
            local banExpireTime = banData.BannedAt + banData.Duration
            if currentTime < banExpireTime then
                local remainingSeconds = banExpireTime - currentTime
                table.insert(activeBans, {
                    UserId = userId,
                    Reason = banData.Reason,
                    BannedAt = banData.BannedAt,
                    Duration = banData.Duration,
                    Permanent = false,
                    RemainingTime = remainingSeconds,
                    Status = "Temporary"
                })
            end
        end
    end

    return activeBans
end

function BanManager.GetBansByPlayer(userId)
    -- Returns ban info for a specific player
    if BanCache[userId] then
        local banData = BanCache[userId]
        return {
            UserId = userId,
            Reason = banData.Reason,
            BannedAt = banData.BannedAt,
            Duration = banData.Duration,
            Permanent = banData.Permanent
        }
    end
    return nil
end

return BanManager
