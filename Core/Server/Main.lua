local Players = game:GetService("Players")
local CommandManager = require(script.Parent.CommandManager)
local RankManager = require(script.Parent.RankManager)
require(script.Parent.CommandsList)

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        CommandManager.Execute(player, message)
    end)
    
    -- Load rank
    local level = RankManager.GetPlayerRank(player)
    print(player.Name .. " joined with rank level: " .. level)
end)

print("Nexus Admin Initialized Successfully")
