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
    local BanManager = require(script.Parent.BanManager)
    local targetName = args[1]
    local durationStr = args[2]
    local reason = table.concat(args, " ", 3) or "Banned by an admin."

    if not targetName then
        notify(executor, "Nexus Admin", "Usage: :ban <player> [duration|permanent] [reason]")
        return
    end

    local targets = getPlayers(targetName, executor)
    if #targets == 0 then
        notify(executor, "Nexus Admin", "Player not found.")
        return
    end

    local duration = nil
    if durationStr then
        if durationStr:lower() == "permanent" or durationStr:lower() == "perm" then
            duration = 0
        else
            local timeValue = tonumber(durationStr:match("^(%d+)"))
            if timeValue then
                local timeUnit = durationStr:match("([smhd])$") or "m"
                if timeUnit == "s" then
                    duration = timeValue
                elseif timeUnit == "m" then
                    duration = timeValue * 60
                elseif timeUnit == "h" then
                    duration = timeValue * 3600
                elseif timeUnit == "d" then
                    duration = timeValue * 86400
                end
            end
        end
    end

    for _, target in pairs(targets) do
        BanManager.BanPlayer(target.UserId, reason, duration)
        notify(executor, "Nexus Admin", "Banned " .. target.Name)
    end
end, "Bans the specified player(s) - Usage: :ban <player> [duration|permanent] [reason]")

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

-- Rank Management
CommandManager.RegisterCommand("rank", 80, function(executor, args)
    local RankManager = require(script.Parent.RankManager)
    local targetName = args[1]
    local rankLevel = tonumber(args[2])

    if not targetName or not rankLevel then
        notify(executor, "Nexus Admin", "Usage: :rank <player> <level>")
        return
    end

    local targets = getPlayers(targetName, executor)
    if #targets == 0 then
        notify(executor, "Nexus Admin", "Player not found.")
        return
    end

    for _, target in pairs(targets) do
        local executorLevel = RankManager.GetPlayerRank(executor)
        local targetLevel = RankManager.GetPlayerRank(target)

        if executorLevel <= targetLevel then
            notify(executor, "Nexus Admin", "You cannot rank a player equal to or higher than your rank.")
            return
        end

        if rankLevel >= executorLevel then
            notify(executor, "Nexus Admin", "You cannot rank a player to your level or higher.")
            return
        end

        if RankManager.IsProtectedPlayer(target) then
            notify(executor, "Nexus Admin", "You cannot rank the Place Owner.")
            return
        end

        local success, err = RankManager.SetPlayerRank(target.UserId, rankLevel)
        if success then
            notify(executor, "Nexus Admin", "Ranked " .. target.Name .. " to level " .. rankLevel)
            notify(target, "Nexus Admin", "You have been ranked to level " .. rankLevel)
        else
            notify(executor, "Nexus Admin", "Error: " .. (err or "Unknown error"))
        end
    end
end, "Ranks a player to a specified level")

CommandManager.RegisterCommand("unrank", 80, function(executor, args)
    local RankManager = require(script.Parent.RankManager)
    local targetName = args[1]

    if not targetName then
        notify(executor, "Nexus Admin", "Usage: :unrank <player>")
        return
    end

    local targets = getPlayers(targetName, executor)
    if #targets == 0 then
        notify(executor, "Nexus Admin", "Player not found.")
        return
    end

    for _, target in pairs(targets) do
        local executorLevel = RankManager.GetPlayerRank(executor)
        local targetLevel = RankManager.GetPlayerRank(target)

        if executorLevel <= targetLevel then
            notify(executor, "Nexus Admin", "You cannot unrank a player equal to or higher than your rank.")
            return
        end

        if RankManager.IsProtectedPlayer(target) then
            notify(executor, "Nexus Admin", "You cannot unrank the Place Owner.")
            return
        end

        local success, err = RankManager.SetPlayerRank(target.UserId, 0)
        if success then
            notify(executor, "Nexus Admin", "Unranked " .. target.Name)
            notify(target, "Nexus Admin", "You have been unranked.")
        else
            notify(executor, "Nexus Admin", "Error: " .. (err or "Unknown error"))
        end
    end
end, "Removes rank from a player")

-- Kill Command
CommandManager.RegisterCommand("kill", 20, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = 0
        end
    end
end, "Kills the specified player(s)")

-- Warning System
CommandManager.RegisterCommand("warn", 40, function(executor, args)
    local WarningManager = require(script.Parent.WarningManager)
    local targetName = args[1]
    local reason = table.concat(args, " ", 2) or "No reason provided."

    if not targetName then
        notify(executor, "Nexus Admin", "Usage: :warn <player> [reason]")
        return
    end

    local targets = getPlayers(targetName, executor)
    if #targets == 0 then
        notify(executor, "Nexus Admin", "Player not found.")
        return
    end

    for _, target in pairs(targets) do
        local warningCount = WarningManager.WarnPlayer(target.UserId, reason, executor.DisplayName, executor.UserId)
        WarningManager.NotifyPlayerWarned(target, executor.DisplayName, reason, warningCount)
        notify(executor, "Nexus Admin", "Warned " .. target.Name .. " (Total: " .. warningCount .. " warnings)")
    end
end, "Warns a player")

CommandManager.RegisterCommand("warnings", 40, function(executor, args)
    local WarningManager = require(script.Parent.WarningManager)
    local targetName = args[1]

    if not targetName then
        notify(executor, "Nexus Admin", "Usage: :warnings <player>")
        return
    end

    local targets = getPlayers(targetName, executor)
    if #targets == 0 then
        notify(executor, "Nexus Admin", "Player not found.")
        return
    end

    for _, target in pairs(targets) do
        local warnings = WarningManager.GetPlayerWarnings(target.UserId)
        local warningCount = #warnings

        if warningCount == 0 then
            notify(executor, "Nexus Admin", target.Name .. " has no warnings.")
        else
            local warningList = target.Name .. " has " .. warningCount .. " warning(s):\n"
            for i, warning in ipairs(warnings) do
                local timestamp = os.date("%Y-%m-%d %H:%M:%S", warning.Timestamp)
                warningList = warningList .. "\n" .. i .. ". [" .. timestamp .. "] by " .. warning.ModeratorName .. ": " .. warning.Reason
            end
            notify(executor, "Nexus Admin", warningList)
        end
    end
end, "Shows warnings for a player")

-- Player Info & Teleportation
CommandManager.RegisterCommand("viewinfo", 40, function(executor, args)
    local targetName = args[1]

    if not targetName then
        notify(executor, "Nexus Admin", "Usage: :viewinfo <player>")
        return
    end

    local targets = getPlayers(targetName, executor)
    if #targets == 0 then
        notify(executor, "Nexus Admin", "Player not found.")
        return
    end

    for _, target in pairs(targets) do
        local info = "Player Info: " .. target.Name .. "\n"
        info = info .. "Display Name: " .. target.DisplayName .. "\n"
        info = info .. "User ID: " .. target.UserId .. "\n"
        info = info .. "Account Age: " .. math.floor((os.time() - target.AccountAge) / 86400) .. " days\n"

        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local pos = target.Character.HumanoidRootPart.Position
            info = info .. "Position: X=" .. math.floor(pos.X) .. ", Y=" .. math.floor(pos.Y) .. ", Z=" .. math.floor(pos.Z) .. "\n"
        end

        if target.Character and target.Character:FindFirstChild("Humanoid") then
            info = info .. "Health: " .. math.floor(target.Character.Humanoid.Health) .. " / " .. math.floor(target.Character.Humanoid.MaxHealth)
        end

        notify(executor, "Nexus Admin", info)
    end
end, "Shows player information")

CommandManager.RegisterCommand("bring", 60, function(executor, args)
    local targetName = args[1]

    if not targetName then
        notify(executor, "Nexus Admin", "Usage: :bring <player|all>")
        return
    end

    local targets = getPlayers(targetName, executor)
    if #targets == 0 then
        notify(executor, "Nexus Admin", "Player not found.")
        return
    end

    if not executor.Character or not executor.Character:FindFirstChild("HumanoidRootPart") then
        notify(executor, "Nexus Admin", "You must have a character to use this command.")
        return
    end

    local executorPos = executor.Character.HumanoidRootPart.Position

    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.CFrame = CFrame.new(executorPos + Vector3.new(5, 0, 0))
            notify(target, "Nexus Admin", "You have been brought to " .. executor.DisplayName)
        end
    end

    notify(executor, "Nexus Admin", "Brought " .. #targets .. " player(s)")
end, "Brings player(s) to you")

CommandManager.RegisterCommand("goto", 60, function(executor, args)
    local targetName = args[1]

    if not targetName then
        notify(executor, "Nexus Admin", "Usage: :goto <player>")
        return
    end

    local targets = getPlayers(targetName, executor)
    if #targets == 0 then
        notify(executor, "Nexus Admin", "Player not found.")
        return
    end

    if not executor.Character or not executor.Character:FindFirstChild("HumanoidRootPart") then
        notify(executor, "Nexus Admin", "You must have a character to use this command.")
        return
    end

    local target = targets[1]
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        executor.Character.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(5, 0, 0))
        notify(executor, "Nexus Admin", "Teleported to " .. target.DisplayName)
    end
end, "Teleports you to a player")

return true

CommandManager.RegisterCommand("bans", 40, function(executor, args)
    local BanManager = require(script.Parent.BanManager)
    local activeBans = BanManager.GetActiveBans()

    if #activeBans == 0 then
        notify(executor, "Nexus Admin", "No active bans.")
        return
    end

    local banList = "Active Bans (" .. #activeBans .. "):\n"
    for i, ban in ipairs(activeBans) do
        local timestamp = os.date("%Y-%m-%d %H:%M:%S", ban.BannedAt)
        local status = ban.Status or "Unknown"

        if ban.Permanent then
            banList = banList .. "\n" .. i .. ". [PERMANENT] UserID: " .. ban.UserId .. " - Reason: " .. ban.Reason .. " (Banned: " .. timestamp .. ")"
        else
            local remainingTime = ban.RemainingTime or 0
            local hours = math.floor(remainingTime / 3600)
            local minutes = math.floor((remainingTime % 3600) / 60)
            banList = banList .. "\n" .. i .. ". [TEMPORARY] UserID: " .. ban.UserId .. " - Reason: " .. ban.Reason .. " (Expires in: " .. hours .. "h " .. minutes .. "m)"
        end
    end

    notify(executor, "Nexus Admin", banList)
end, "Shows all active bans")
