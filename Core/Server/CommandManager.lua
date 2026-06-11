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
    if typeof(message) ~= "string" or #message < 2 or message:sub(1, 1) ~= Config.Prefix then
        return
    end

    local commandString = message:sub(2)
    if not commandString or commandString == "" then
        return
    end

    local args = commandString:split(" ")
    local cmdName = args[1] and args[1]:lower() or ""
    if cmdName == "" then
        return
    end
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

function CommandManager.GetAllCommands()
    -- Returns all registered commands with their metadata
    local commandList = {}
    for name, cmd in pairs(Commands) do
        table.insert(commandList, {
            Name = name,
            Level = Config.CommandLevels[name] or cmd.Level,
            Description = cmd.Description or "No description available",
            Enabled = cmd.Enabled
        })
    end
    return commandList
end

function CommandManager.GetCommandInfo(cmdName)
    -- Returns detailed info about a specific command
    if Config.Aliases[cmdName] then
        cmdName = Config.Aliases[cmdName]
    end

    local cmd = Commands[cmdName]
    if not cmd then
        return nil
    end

    return {
        Name = cmdName,
        Level = Config.CommandLevels[cmdName] or cmd.Level,
        Description = cmd.Description or "No description available",
        Enabled = cmd.Enabled,
        Usage = ":" .. cmdName .. " [args]"
    }
end

function CommandManager.SearchCommands(query, playerLevel)
    -- Search for commands by name or description
    local results = {}
    local lowerQuery = query:lower()

    for name, cmd in pairs(Commands) do
        local requiredLevel = Config.CommandLevels[name] or cmd.Level
        
        -- Only show commands the player can use (hierarchy: higher rank can use lower commands)
        if playerLevel >= requiredLevel then
            if name:lower():find(lowerQuery, 1, true) or 
               (cmd.Description and cmd.Description:lower():find(lowerQuery, 1, true)) then
                table.insert(results, {
                    Name = name,
                    Level = requiredLevel,
                    Description = cmd.Description or "No description available",
                    CanUse = playerLevel >= requiredLevel
                })
            end
        end
    end

    return results
end

function CommandManager.GetAccessibleCommands(playerLevel)
    -- Returns all commands accessible to a player based on their level
    local accessible = {}
    
    for name, cmd in pairs(Commands) do
        local requiredLevel = Config.CommandLevels[name] or cmd.Level
        
        -- Higher ranks can use lower-level commands (hierarchy enforcement)
        if playerLevel >= requiredLevel then
            table.insert(accessible, {
                Name = name,
                Level = requiredLevel,
                Description = cmd.Description or "No description available",
                Enabled = cmd.Enabled
            })
        end
    end

    return accessible
end

return CommandManager
