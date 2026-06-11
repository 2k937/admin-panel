-- This is a representation of the UI structure.
-- In Roblox, this would be a ScreenGui with various Frames.

local UI = {
    Name = "NexusAdminUI",
    Theme = "Dark",
    Components = {
        Sidebar = {
            Dashboard = "rbxassetid://0",
            Admins = "rbxassetid://0",
            Ranks = "rbxassetid://0",
            Commands = "rbxassetid://0",
            Logs = "rbxassetid://0",
            Settings = "rbxassetid://0",
            Execute = "rbxassetid://0"
        },
        MainFrame = {
            Title = "Nexus Admin",
            Subtitle = "Modern Dashboard",
            Content = {}
        },
        Dashboard = {
            Title = "Welcome",
            UserProfile = {
                DisplayName = "",
                UserId = 0,
                Rank = "",
                Level = 0,
                AccessSource = "ManualRank"
            },
            Stats = {
                PlayersOnline = 0,
                AdminsOnline = 0,
                BannedPlayers = 0,
                CommandsExecuted = 0
            }
        },
        WarningNotification = {
            Title = "You Have Been Warned",
            ModeratorName = "",
            Reason = "",
            WarningCount = 0,
            BackgroundColor = Color3.fromRGB(255, 100, 100),
            TextColor = Color3.fromRGB(255, 255, 255),
            Duration = 5
        },
        ExecuteTab = {
            Title = "Execute Commands",
            TargetSelection = {
                Title = "Select Target",
                PlayerList = {},
                SelectedPlayer = nil
            },
            CommandInput = {
                Placeholder = "Enter command (e.g., kick, ban, warn)",
                Value = ""
            },
            TargetInfo = {
                Avatar = "",
                Username = "",
                Rank = "",
                UserId = 0,
                Level = 0
            },
            ExecuteButton = {
                Text = "Execute",
                Enabled = false
            }
        }
    }
}

function UI.CreateModernButton(text, color)
    -- Logic for creating a sleek button with hover effects
end

function UI.CreateDashboard(permissionData)
    -- Logic for building the dashboard with stats and user profile info
    -- permissionData contains: Level, RankName, IsPlaceOwner, AccessSource, GroupId, GroupRank
    if permissionData then
        UI.Components.Dashboard.UserProfile.Rank = permissionData.RankName or "Unknown"
        UI.Components.Dashboard.UserProfile.Level = permissionData.Level or 0
        UI.Components.Dashboard.UserProfile.AccessSource = permissionData.AccessSource or "ManualRank"
    end
end

function UI.CreateAdminButton(permissionData)
    -- Logic for a sleek, modern floating button (e.g., at the bottom right)
    -- This button allows mobile users to easily open the panel
    -- permissionData is passed for profile display
end

function UI.ShowMessage(title, text, sender)
    -- Logic for showing a global message overlay
end

function UI.ShowPM(text, sender)
    -- Logic for showing a private message box with a reply button
end

function UI.ShowWarning(moderatorName, reason, warningCount)
    -- Modern clean warning notification UI
    -- Displays: "You Have Been Warned by [Moderator]"
    -- Shows reason and warning count
    -- Auto-dismisses after 5 seconds
    return {
        Title = "You Have Been Warned",
        ModeratorName = moderatorName,
        Reason = reason,
        WarningCount = warningCount,
        Message = "You have been warned by " .. moderatorName .. " for: " .. reason .. "\nTotal Warnings: " .. warningCount
    }
end

function UI.GetDashboardContent(player, permissionData)
    -- Returns dashboard content with user profile and welcome message
    return {
        WelcomeText = "Welcome, " .. (player.DisplayName or player.Name),
        UserId = player.UserId,
        Rank = permissionData.RankName or "Player",
        Level = permissionData.Level or 0,
        IsPlaceOwner = permissionData.IsPlaceOwner or false,
        AccessSource = permissionData.AccessSource or "ManualRank"
    }
end

function UI.CreateExecuteTab(players)
    -- Creates the Execute tab with player list
    UI.Components.ExecuteTab.TargetSelection.PlayerList = players
    return UI.Components.ExecuteTab
end

function UI.SelectTargetPlayer(player)
    -- Updates the target info when a player is selected
    UI.Components.ExecuteTab.SelectedPlayer = player
    UI.Components.ExecuteTab.TargetInfo.Username = player.Name
    UI.Components.ExecuteTab.TargetInfo.UserId = player.UserId
    UI.Components.ExecuteTab.TargetInfo.Avatar = "https://www.roblox.com/bust-thumbnails/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
    UI.Components.ExecuteTab.ExecuteButton.Enabled = true
    return UI.Components.ExecuteTab.TargetInfo
end

function UI.UpdateTargetRankInfo(rankName, level)
    -- Updates the target's rank information
    UI.Components.ExecuteTab.TargetInfo.Rank = rankName
    UI.Components.ExecuteTab.TargetInfo.Level = level
end

function UI.GetExecuteTabState()
    -- Returns the current state of the Execute tab
    return {
        SelectedPlayer = UI.Components.ExecuteTab.SelectedPlayer,
        Command = UI.Components.ExecuteTab.CommandInput.Value,
        TargetInfo = UI.Components.ExecuteTab.TargetInfo
    }
end

return UI
