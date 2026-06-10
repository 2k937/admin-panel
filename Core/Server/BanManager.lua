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
    local banExpireTime = banData.BannedAt + banData.Duration

    if currentTime < banExpireTime then
        return true
    else
        BanCache[userId] = nil
        DataStore.Delete("Ban_" .. userId)
        return false
    end
end

function BanManager.BanPlayer(userId, reason, duration)
    -- duration: nil or 0 = permanent, number = seconds
    local isPermanent = (duration == nil or duration == 0)
    local banData = {
        Reason = reason or "Banned by an admin.",
        BannedAt = os.time(),
        Duration = duration or 0,
        Permanent = isPermanent
    }

    BanCache[userId] = banData
    DataStore.Save("Ban_" .. userId, banData)

    local player = Players:GetPlayerByUserId(userId)
    if player then
        local kickMessage = "Banned: " .. reason
        if not isPermanent then
            local durationMinutes = math.floor(duration / 60)
            kickMessage = kickMessage .. " (Duration: " .. durationMinutes .. " minutes)"
        end
        player:Kick(kickMessage)
    end

    return true
end

function BanManager.UnbanPlayer(userId)
    BanCache[userId] = nil
    DataStore.Delete("Ban_" .. userId)
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
    if isBanned(player.UserId) then
        local banInfo = BanManager.GetBanInfo(player.UserId)
        local kickMessage = "Banned: " .. (banInfo.Reason or "No reason provided.")
        if not banInfo.Permanent then
            local currentTime = os.time()
            local banExpireTime = banInfo.BannedAt + banInfo.Duration
            local remainingSeconds = banExpireTime - currentTime
            if remainingSeconds > 0 then
                local minutes = math.floor(remainingSeconds / 60)
                local seconds = remainingSeconds % 60
                kickMessage = kickMessage .. " (Expires in " .. minutes .. "m " .. seconds .. "s)"
            end
        end
        player:Kick(kickMessage)
        return true
    end
    return false
end

return BanManager
