local CommandManager = require(script.Parent.CommandManager)
local Players = game:GetService("Players")

local function getPlayers(str, executor)
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

-- Kick Command
CommandManager.RegisterCommand("kick", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    local reason = args[2] or "Kicked by an admin."
    for _, target in pairs(targets) do
        target:Kick(reason)
    end
end, "Kicks the specified player(s)")

-- Ban Command
CommandManager.RegisterCommand("ban", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    local reason = args[2] or "Banned by an admin."
    for _, target in pairs(targets) do
        -- In real implementation, add to DataStore ban list
        target:Kick("Banned: " .. reason)
    end
end, "Bans the specified player(s)")

-- Heal Command
CommandManager.RegisterCommand("heal", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = target.Character.Humanoid.MaxHealth
        end
    end
end, "Heals the specified player(s)")

-- Speed Command
CommandManager.RegisterCommand("speed", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    local speed = tonumber(args[2]) or 16
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.WalkSpeed = speed
        end
    end
end, "Sets the walkspeed of specified player(s)")

-- Jump Command
CommandManager.RegisterCommand("jump", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    local power = tonumber(args[2]) or 50
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.JumpPower = power
        end
    end
end, "Sets the jump power of specified player(s)")

-- Fly Command
CommandManager.RegisterCommand("fly", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        -- Remote event to client for flight
    end
end, "Makes the specified player(s) fly")

-- Respawn Command
CommandManager.RegisterCommand("respawn", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        target:LoadCharacter()
    end
end, "Respawns the specified player(s)")

-- Shutdown Command
CommandManager.RegisterCommand("shutdown", 100, function(executor, args)
    for _, p in pairs(Players:GetPlayers()) do
        p:Kick("Server shutting down.")
    end
end, "Shuts down the server")

-- Announce Command
CommandManager.RegisterCommand("announce", 60, function(executor, args)
    local msg = table.concat(args, " ")
    -- Remote event to all clients to show announcement
end, "Sends a global announcement")

-- Visible / Invisible
CommandManager.RegisterCommand("invisible", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        if target.Character then
            for _, part in pairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
        end
    end
end, "Makes player invisible")

CommandManager.RegisterCommand("visible", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        if target.Character then
            for _, part in pairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    if part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 0
                    end
                end
            end
        end
    end
end, "Makes player visible")

-- Add more commands as needed...
return true

-- Freeze / Unfreeze
CommandManager.RegisterCommand("freeze", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.Anchored = true
        end
    end
end, "Freezes player")

CommandManager.RegisterCommand("unfreeze", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.Anchored = false
        end
    end
end, "Unfreezes player")

-- Jail / Unjail
CommandManager.RegisterCommand("jail", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        -- Implementation: Create a cage around the player
    end
end, "Jails player")

-- God / Ungod
CommandManager.RegisterCommand("god", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.MaxHealth = math.huge
            target.Character.Humanoid.Health = math.huge
        end
    end
end, "Gives god mode")

CommandManager.RegisterCommand("ungod", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.MaxHealth = 100
            target.Character.Humanoid.Health = 100
        end
    end
end, "Removes god mode")

-- Bring / Goto
CommandManager.RegisterCommand("bring", 40, function(executor, args)
    local targets = getPlayers(args[1], executor)
    if executor.Character and executor.Character:FindFirstChild("HumanoidRootPart") then
        local pos = executor.Character.HumanoidRootPart.CFrame
        for _, target in pairs(targets) do
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                target.Character.HumanoidRootPart.CFrame = pos * CFrame.new(0, 0, -5)
            end
        end
    end
end, "Brings player to you")

CommandManager.RegisterCommand("goto", 40, function(executor, args)
    local target = getPlayers(args[1], executor)[1]
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        if executor.Character and executor.Character:FindFirstChild("HumanoidRootPart") then
            executor.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
        end
    end
end, "Teleports you to player")

-- Fling
CommandManager.RegisterCommand("fling", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(math.random(-500, 500), 500, math.random(-500, 500))
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Parent = hrp
            game:GetService("Debris"):AddItem(bodyVelocity, 0.5)
        end
    end
end, "Flings player")

-- Explosions, Sparkles, Fire, Smoke
CommandManager.RegisterCommand("explode", 60, function(executor, args)
    local targets = getPlayers(args[1], executor)
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local explosion = Instance.new("Explosion")
            explosion.Position = target.Character.HumanoidRootPart.Position
            explosion.Parent = game.Workspace
        end
    end
end, "Explodes player")

-- Rank Command
CommandManager.RegisterCommand("rank", 80, function(executor, args)
    local targetName = args[1]
    local newLevel = tonumber(args[2])
    
    if not targetName or not newLevel then return end
    
    local RankManager = require(script.Parent.RankManager)
    local executorLevel = RankManager.GetPlayerRank(executor)
    
    -- Hierarchy Check: Cannot rank someone to a level higher than or equal to yourself
    if newLevel >= executorLevel then
        -- Notify: Cannot set rank higher than or equal to your own
        return
    end
    
    local targets = getPlayers(targetName, executor)
    for _, target in pairs(targets) do
        local targetCurrentLevel = RankManager.GetPlayerRank(target)
        
        -- Hierarchy Check: Cannot rank someone who is already higher than or equal to you
        if targetCurrentLevel < executorLevel then
            RankManager.SetPlayerRank(target.UserId, newLevel)
            -- Notify target and executor
        end
    end
end, "Ranks a player permanently")

-- Unrank Command
CommandManager.RegisterCommand("unrank", 80, function(executor, args)
    local targetName = args[1]
    if not targetName then return end
    
    local RankManager = require(script.Parent.RankManager)
    local executorLevel = RankManager.GetPlayerRank(executor)
    
    local targets = getPlayers(targetName, executor)
    for _, target in pairs(targets) do
        local targetCurrentLevel = RankManager.GetPlayerRank(target)
        
        -- Hierarchy Check: Cannot unrank someone who is higher than or equal to you
        if targetCurrentLevel < executorLevel then
            RankManager.SetPlayerRank(target.UserId, 0)
            -- Notify target and executor
        end
    end
end, "Removes a player's rank permanently")
