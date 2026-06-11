local TagManager = {}
local Config = require(script.Parent.Parent.Shared.Config)
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local PlayerTags = {} -- [UserId] = { Name = "", Color = Color3, Icon = "" }
local TagDataStore = nil

local function initDataStore()
    if not TagDataStore then
        local success, ds = pcall(function()
            return DataStoreService:GetDataStore("NexusAdmin_Tags")
        end)
        if success then
            TagDataStore = ds
        end
    end
end

function TagManager.SetPlayerTag(userId, tagName, tagColor, icon)
    if not Config.Tags.Enabled then
        return false
    end

    if not tagName or tagName == "" then
        return false
    end

    if #tagName > Config.Tags.MaxTagLength then
        return false
    end

    PlayerTags[userId] = {
        Name = tagName,
        Color = tagColor or Color3.fromRGB(255, 255, 255),
        Icon = icon or ""
    }

    -- Save to DataStore
    initDataStore()
    if TagDataStore then
        local success = pcall(function()
            TagDataStore:SetAsync("Tag_" .. userId, {
                Name = tagName,
                Color = { tagColor.R, tagColor.G, tagColor.B },
                Icon = icon or ""
            })
        end)
        return success
    end

    return true
end

function TagManager.RemovePlayerTag(userId)
    if not Config.Tags.Enabled then
        return false
    end

    PlayerTags[userId] = nil

    -- Remove from DataStore
    initDataStore()
    if TagDataStore then
        local success = pcall(function()
            TagDataStore:RemoveAsync("Tag_" .. userId)
        end)
        return success
    end

    return true
end

function TagManager.GetPlayerTag(userId)
    if not Config.Tags.Enabled then
        return nil
    end

    return PlayerTags[userId]
end

function TagManager.LoadPlayerTag(userId)
    if not Config.Tags.Enabled then
        return nil
    end

    initDataStore()
    if TagDataStore then
        local success, tagData = pcall(function()
            return TagDataStore:GetAsync("Tag_" .. userId)
        end)

        if success and tagData then
            local color = Color3.fromRGB(tagData.Color[1] * 255, tagData.Color[2] * 255, tagData.Color[3] * 255)
            PlayerTags[userId] = {
                Name = tagData.Name,
                Color = color,
                Icon = tagData.Icon or ""
            }
            return PlayerTags[userId]
        end
    end

    return nil
end

function TagManager.GetAllPlayerTags()
    if not Config.Tags.Enabled then
        return {}
    end

    return PlayerTags
end

function TagManager.LoadAllTags()
    if not Config.Tags.Enabled then
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        TagManager.LoadPlayerTag(player.UserId)
    end
end

return TagManager
