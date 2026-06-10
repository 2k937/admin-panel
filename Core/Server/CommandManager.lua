local CommandManager = {}
local Config = require(script.Parent.Parent.Shared.Config)
local RankManager = require(script.Parent.RankManager)

local Commands = {}

function CommandManager.RegisterCommand(name, level, callback, description)
    Commands[name] = {
        Level = level,
        Callback = callback,
        Description = description,
        Enabled = true
    }
end

function CommandManager.Execute(player, message)
    if typeof(message) ~= "string" or message:sub(1, 1) ~= Config.Prefix then
        return
    end

    local args = message:sub(2):split(" ")
    local cmdName = args[1] and args[1]:lower() or ""
    table.remove(args, 1)

    -- Check Aliases
    if Config.Aliases[cmdName] then
        cmdName = Config.Aliases[cmdName]
    end

    local command = Commands[cmdName]
    if command and command.Enabled then
        local playerLevel = RankManager.GetPlayerRank(player)
        local requiredLevel = Config.CommandLevels[cmdName] or command.Level

        if playerLevel >= requiredLevel then
            local LogManager = require(script.Parent.LogManager)
            LogManager.AddLog("Commands", {
                User = player.Name,
                Command = cmdName,
                Args = args
            })

            local success, err = pcall(function()
                command.Callback(player, args)
            end)
            if not success then
                warn("Error executing command " .. cmdName .. ": " .. err)
            end
        else
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local notify = ReplicatedStorage:FindFirstChild("NexusAdmin_Notify")
            if notify then
                notify:FireClient(player, "Nexus Admin", "Insufficient permissions for :" .. cmdName)
            end
        end
    end
end

return CommandManager
