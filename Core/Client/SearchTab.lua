local SearchTab = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function SearchTab.GetAccessibleCommands(playerLevel)
    -- Request command list from server
    local GetCommands = ReplicatedStorage:FindFirstChild("NexusAdmin_GetCommands")
    if GetCommands then
        local success, commands = pcall(function()
            return GetCommands:InvokeServer()
        end)
        if success and commands then
            return commands
        end
    end
    return {}
end

function SearchTab.SearchCommands(query, commands)
    -- Client-side search filtering
    local results = {}
    local lowerQuery = query:lower()

    for _, cmd in ipairs(commands) do
        if cmd.Name:lower():find(lowerQuery, 1, true) or 
           (cmd.Description and cmd.Description:lower():find(lowerQuery, 1, true)) then
            table.insert(results, cmd)
        end
    end

    return results
end

function SearchTab.FilterCommandsByCategory(commands, category)
    -- Filter commands by category
    local categoryMap = {
        moderation = {"kick", "ban", "unban", "mute", "unmute", "jail", "unjail", "warn"},
        utility = {"teleport", "fly", "noclip", "heal", "kill", "announce", "message", "pm"},
        admin = {"rank", "unrank", "tag", "untag", "shutdown", "viewinfo", "bring", "goto"},
        all = {}
    }

    if category == "all" then
        return commands
    end

    local categoryCommands = categoryMap[category] or {}
    local filtered = {}

    for _, cmd in ipairs(commands) do
        for _, categoryCmd in ipairs(categoryCommands) do
            if cmd.Name == categoryCmd then
                table.insert(filtered, cmd)
                break
            end
        end
    end

    return filtered
end

function SearchTab.SortCommandsByLevel(commands)
    -- Sort commands by required level (ascending)
    table.sort(commands, function(a, b)
        return a.Level < b.Level
    end)
    return commands
end

function SearchTab.GetCommandDetails(commandName)
    -- Request detailed command info from server
    local GetCommandInfo = ReplicatedStorage:FindFirstChild("NexusAdmin_GetCommandInfo")
    if GetCommandInfo then
        local success, info = pcall(function()
            return GetCommandInfo:InvokeServer(commandName)
        end)
        if success and info then
            return info
        end
    end
    return nil
end

return SearchTab
