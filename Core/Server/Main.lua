local Players = game:GetService("Players")
local CommandManager = require(script.Parent.CommandManager)
local RankManager = require(script.Parent.RankManager)
require(script.Parent.CommandsList)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetPermission = Instance.new("RemoteFunction")
GetPermission.Name = "NexusAdmin_GetPermission"
GetPermission.Parent = ReplicatedStorage

local ExecuteCommand = Instance.new("RemoteEvent")
ExecuteCommand.Name = "NexusAdmin_ExecuteCommand"
ExecuteCommand.Parent = ReplicatedStorage

GetPermission.OnServerInvoke = function(player)
    local level = RankManager.GetPlayerRank(player)
    return level >= 20 -- Minimum level to open panel (Helper)
end

ExecuteCommand.OnServerEvent:Connect(function(player, commandString)
    -- This allows executing commands from the UI without the prefix
    local level = RankManager.GetPlayerRank(player)
    if level >= 20 then
        -- Add prefix if missing to use the same logic
        local finalCmd = commandString
        if commandString:sub(1, 1) ~= Config.Prefix then
            finalCmd = Config.Prefix .. commandString
        end
        CommandManager.Execute(player, finalCmd)
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        CommandManager.Execute(player, message)
    end)
    
    -- Load rank
    local level = RankManager.GetPlayerRank(player)
    print(player.Name .. " joined with rank level: " .. level)
end)

print("Nexus Admin Initialized Successfully")
