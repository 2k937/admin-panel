local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandManager = require(script.Parent.CommandManager)
local RankManager = require(script.Parent.RankManager)
local BanManager = require(script.Parent.BanManager)
local AntiExploit = require(script.Parent.AntiExploit)
local TagManager = require(script.Parent.TagManager)
local HistoryManager = require(script.Parent.HistoryManager)
local Config = require(script.Parent.Parent.Shared.Config)
require(script.Parent.CommandsList)

local GetPermission = Instance.new("RemoteFunction")
GetPermission.Name = "NexusAdmin_GetPermission"
GetPermission.Parent = ReplicatedStorage

local ExecuteCommand = Instance.new("RemoteEvent")
ExecuteCommand.Name = "NexusAdmin_ExecuteCommand"
ExecuteCommand.Parent = ReplicatedStorage

local MessageEvent = Instance.new("RemoteEvent")
MessageEvent.Name = "NexusAdmin_Message"
MessageEvent.Parent = ReplicatedStorage

local PMEvent = Instance.new("RemoteEvent")
PMEvent.Name = "NexusAdmin_PM"
PMEvent.Parent = ReplicatedStorage

local FlyEvent = Instance.new("RemoteEvent")
FlyEvent.Name = "NexusAdmin_Fly"
FlyEvent.Parent = ReplicatedStorage

local NoClipEvent = Instance.new("RemoteEvent")
NoClipEvent.Name = "NexusAdmin_NoClip"
NoClipEvent.Parent = ReplicatedStorage

local ExecuteTabRemote = Instance.new("RemoteEvent")
ExecuteTabRemote.Name = "NexusAdmin_Execute"
ExecuteTabRemote.Parent = ReplicatedStorage

local GetCommands = Instance.new("RemoteFunction")
GetCommands.Name = "NexusAdmin_GetCommands"
GetCommands.Parent = ReplicatedStorage

local GetCommandInfo = Instance.new("RemoteFunction")
GetCommandInfo.Name = "NexusAdmin_GetCommandInfo"
GetCommandInfo.Parent = ReplicatedStorage

local GetPlayerDetails = Instance.new("RemoteFunction")
GetPlayerDetails.Name = "NexusAdmin_GetPlayerDetails"
GetPlayerDetails.Parent = ReplicatedStorage

local GetWorldSettings = Instance.new("RemoteFunction")
GetWorldSettings.Name = "NexusAdmin_GetWorldSettings"
GetWorldSettings.Parent = ReplicatedStorage

local NotifyEvent = Instance.new("RemoteEvent")
NotifyEvent.Name = "NexusAdmin_Notify"
NotifyEvent.Parent = ReplicatedStorage

local function notifyPlayer(player, title, text, type)
    NotifyEvent:FireClient(player, title, text, type or "info")
end

GetPermission.OnServerInvoke = function(player)
    return RankManager.GetPermissionData(player)
end

ExecuteCommand.OnServerEvent:Connect(function(player, commandString)
    if typeof(commandString) ~= "string" then
        return
    end

    local permission = RankManager.GetPermissionData(player)
    if permission.CanOpen then
        -- Add prefix if missing to use the same logic as chat commands.
        local finalCmd = commandString
        local prefix = Config.Prefix or ":"
        if commandString:sub(1, 1) ~= prefix then
            finalCmd = prefix .. commandString
        end
        CommandManager.Execute(player, finalCmd)
    end
end)

Players.PlayerAdded:Connect(function(player)
    -- Check if player is banned
    if BanManager.CheckPlayerOnJoin(player) then
        return
    end

    -- Track history
    HistoryManager.OnPlayerJoin(player)

    -- Start Anti-Exploit monitoring
    AntiExploit.StartMonitoring(player)
    AntiExploit.MonitorBackdoor(player)

    player.Chatted:Connect(function(message)
        CommandManager.Execute(player, message)
    end)

    -- Load manual rank, then resolve effective owner/group/manual access.
    local level = RankManager.LoadPlayerRank(player)
    local permission = RankManager.GetPermissionData(player)

    -- Load player tag if it exists
    TagManager.LoadPlayerTag(player.UserId)

    if permission.CanOpen then
        -- Welcome notification for admins and group-rank users.
        task.wait(2) -- Wait for client to load
        notifyPlayer(player, "Welcome, " .. player.DisplayName, "Rank: " .. permission.RankName .. " (Level " .. tostring(level) .. ")")
    end
end)

Players.PlayerRemoving:Connect(function(player)
    HistoryManager.OnPlayerLeave(player)
    AntiExploit.StopMonitoring(player)
end)

print("Nexus Admin Initialized Successfully")

ExecuteTabRemote.OnServerEvent:Connect(function(player, targetName, command)
    if typeof(targetName) ~= "string" or typeof(command) ~= "string" then
        return
    end

    local permission = RankManager.GetPermissionData(player)
    if permission.CanOpen then
        -- Build the command with target
        local prefix = Config.Prefix or ":"
        local finalCmd = prefix .. command .. " " .. targetName
        CommandManager.Execute(player, finalCmd)
    end
end)

GetCommands.OnServerInvoke = function(player)
    local playerLevel = RankManager.GetPlayerRank(player)
    return CommandManager.GetAccessibleCommands(playerLevel)
end

GetCommandInfo.OnServerInvoke = function(player, commandName)
    return CommandManager.GetCommandInfo(commandName)
end

GetPlayerDetails.OnServerInvoke = function(player, targetUserId)
    local permission = RankManager.GetPermissionData(player)
    if not permission.CanOpen then return nil end
    
    local WarningManager = require(script.Parent.WarningManager)
    
    return {
        History = HistoryManager.GetPlayerHistory(targetUserId),
        BanInfo = BanManager.GetBanInfo(targetUserId),
        Warnings = WarningManager.GetPlayerWarnings(targetUserId)
    }
end

GetWorldSettings.OnServerInvoke = function(player)
    local permission = RankManager.GetPermissionData(player)
    if permission.Level < 80 then return nil end
    
    local WorldManager = require(script.Parent.WorldManager)
    return WorldManager.GetSettings()
end
