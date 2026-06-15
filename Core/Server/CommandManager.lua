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
    if not message:sub(1, 1) == Config.Prefix then return end
    
    local args = message:sub(2):split(" ")
    local cmdName = args[1]:lower()
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
            
            local success, result = pcall(function()
                return command.Callback(player, args)
            end)
            
            if success then
                if result == false then
                    -- Command failed internally (e.g., player not found)
                    LogManager.AddLog("Errors", {User = player.Name, Command = cmdName, Error = "Target not found"})
                else
                    -- Command succeeded
                    -- UI Notification for success is usually handled in the command itself for specific targeting
                end
            else
                -- Execution error
                local Remote = ReplicatedStorage:FindFirstChild("NexusAdmin_Notify")
                if Remote then
                    Remote:FireClient(player, "Command Error", "An error occurred: " .. tostring(result))
                end
                warn("Error executing command " .. cmdName .. ": " .. result)
            end
        else
            -- Notify insufficient permissions
        end
    end
end

return CommandManager
