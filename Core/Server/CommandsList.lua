local CommandManager = require(script.Parent.CommandManager)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getPlayers(str, executor)
    if not str then return {} end
    if str == "all" then return Players:GetPlayers() end
    if str == "others" then
        local others = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= executor then table.insert(others, p) end
        end
        return others
    end
    if str == "me" then return {executor} end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #str) == str:lower() or p.DisplayName:lower():sub(1, #str) == str:lower() then
            return {p}
        end
    end
    return {}
end

local function notify(player, title, text)
    local Remote = ReplicatedStorage:FindFirstChild("NexusAdmin_Notify")
    if Remote then Remote:FireClient(player, title, text) end
end

-- Kick/Ban
CommandManager.RegisterCommand("kick", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    local reason = table.concat(args, " ", 2) or "Kicked by an admin."
    for _, target in pairs(targets) do
        target:Kick(reason)
    end
end, "Kicks the specified player(s)")

CommandManager.RegisterCommand("ban", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    local reason = table.concat(args, " ", 2) or "Banned by an admin."
    for _, target in pairs(targets) do
        target:Kick("Banned: " .. reason)
        -- Save to Ban DataStore
    end
end, "Bans the specified player(s)")

-- Moderation
CommandManager.RegisterCommand("mute", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        -- Logic to disable chat
    end
end, "Mutes player")

CommandManager.RegisterCommand("unmute", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        -- Logic to enable chat
    end
end, "Unmutes player")

-- Movement/Stats
CommandManager.RegisterCommand("fly", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        ReplicatedStorage:WaitForChild("NexusAdmin_Fly"):FireClient(target, true)
    end
end, "Enables flight")

CommandManager.RegisterCommand("unfly", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        ReplicatedStorage:WaitForChild("NexusAdmin_Fly"):FireClient(target, false)
    end
end, "Disables flight")

CommandManager.RegisterCommand("noclip", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        ReplicatedStorage:WaitForChild("NexusAdmin_NoClip"):FireClient(target, true)
    end
end, "Enables noclip")

CommandManager.RegisterCommand("clip", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        ReplicatedStorage:WaitForChild("NexusAdmin_NoClip"):FireClient(target, false)
    end
end, "Disables noclip")

-- Communication
CommandManager.RegisterCommand("announce", 60, function(executor, args)
    local msg = table.concat(args, " ")
    ReplicatedStorage:WaitForChild("NexusAdmin_Message"):FireAllClients("Announcement", msg, executor.Name)
end, "Global announcement")

CommandManager.RegisterCommand("message", 60, function(executor, args)
    local msg = table.concat(args, " ")
    ReplicatedStorage:WaitForChild("NexusAdmin_Message"):FireAllClients("Message", msg, executor.Name)
end, "Global message")

CommandManager.RegisterCommand("pm", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    local msg = table.concat(args, " ", 2)
    for _, target in pairs(targets) do
        ReplicatedStorage:WaitForChild("NexusAdmin_PM"):FireClient(target, msg, executor.Name)
    end
end, "Private message")

-- Fun/Misc
CommandManager.RegisterCommand("explode", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local exp = Instance.new("Explosion")
            exp.Position = target.Character.HumanoidRootPart.Position
            exp.Parent = game.Workspace
        end
    end
end, "Explodes player")

-- Add all other commands similarly...
return true
