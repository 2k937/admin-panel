-- ExecuteTab.lua - Handles the Execute tab UI and command execution
local ExecuteTab = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local selectedPlayer = nil
local selectedCommand = ""

function ExecuteTab.CreatePlayerCard(player, rankInfo)
    -- Creates a visual card for a player with avatar, username, and rank
    return {
        PlayerId = player.UserId,
        PlayerName = player.Name,
        DisplayName = player.DisplayName,
        Avatar = "https://www.roblox.com/bust-thumbnails/image?userId=" .. player.UserId .. "&width=420&height=420&format=png",
        Rank = rankInfo.RankName or "Player",
        Level = rankInfo.Level or 0,
        OnClick = function()
            ExecuteTab.SelectPlayer(player, rankInfo)
        end
    }
end

function ExecuteTab.SelectPlayer(player, rankInfo)
    -- Updates the selected player and displays their info
    selectedPlayer = player
    return {
        Username = player.Name,
        DisplayName = player.DisplayName,
        UserId = player.UserId,
        Rank = rankInfo.RankName or "Player",
        Level = rankInfo.Level or 0,
        Avatar = "https://www.roblox.com/bust-thumbnails/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
    }
end

function ExecuteTab.GetPlayerList()
    -- Returns all online players with their rank info
    local playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(playerList, {
                Player = player,
                Card = ExecuteTab.CreatePlayerCard(player, { RankName = "Player", Level = 0 })
            })
        end
    end
    return playerList
end

function ExecuteTab.ExecuteCommand(command)
    -- Sends the command to the server for execution on the selected player
    if not selectedPlayer then
        print("No player selected")
        return false
    end

    if not command or command == "" then
        print("No command entered")
        return false
    end

    -- Send command to server
    local ExecuteRemote = ReplicatedStorage:FindFirstChild("NexusAdmin_Execute")
    if ExecuteRemote then
        ExecuteRemote:FireServer(selectedPlayer.Name, command)
        return true
    end

    return false
end

function ExecuteTab.GetSelectedPlayer()
    return selectedPlayer
end

function ExecuteTab.SetCommand(cmd)
    selectedCommand = cmd
end

function ExecuteTab.GetCommand()
    return selectedCommand
end

return ExecuteTab
