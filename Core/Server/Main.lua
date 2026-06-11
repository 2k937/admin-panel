local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandManager = require(script.Parent.CommandManager)
local RankManager = require(script.Parent.RankManager)
local BanManager = require(script.Parent.BanManager)
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

local function notifyPlayer(player, title, text)
    local Remote = ReplicatedStorage:FindFirstChild("NexusAdmin_Notify")
    if not Remote then
        Remote = Instance.new("RemoteEvent")
        Remote.Name = "NexusAdmin_Notify"
        Remote.Parent = ReplicatedStorage
    end
    Remote:FireClient(player, title, text)
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
        if commandString:sub(1, 1) ~= Config.Prefix then
            finalCmd = Config.Prefix .. commandString
        end
        CommandManager.Execute(player, finalCmd)
    end
end)

Players.PlayerAdded:Connect(function(player)
    -- Check if player is banned
    if BanManager.CheckPlayerOnJoin(player) then
        return
    end

    player.Chatted:Connect(function(message)
        CommandManager.Execute(player, message)
    end)

    -- Load manual rank, then resolve effective owner/group/manual access.
    local level = RankManager.LoadPlayerRank(player)
    local permission = RankManager.GetPermissionData(player)

    if permission.CanOpen then
        -- Welcome notification for admins and group-rank users.
        task.wait(2) -- Wait for client to load
        notifyPlayer(player, "Welcome, " .. player.DisplayName, "Rank: " .. permission.RankName .. " (Level " .. tostring(level) .. ")")
    end
end)

print("Nexus Admin Initialized Successfully")

ExecuteTabRemote.OnServerEvent:Connect(function(player, targetName, command)
    if typeof(targetName) ~= "string" or typeof(command) ~= "string" then
        return
    end

    local permission = RankManager.GetPermissionData(player)
    if permission.CanOpen then
        -- Build the command with target
        local finalCmd = Config.Prefix .. command .. " " .. targetName
        CommandManager.Execute(player, finalCmd)
    end
end)
