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
            Settings = "rbxassetid://0"
        },
        MainFrame = {
            Title = "Nexus Admin",
            Subtitle = "Modern Dashboard",
            Content = {}
        }
    }
}

function UI.CreateModernButton(text, color)
    -- Logic for creating a sleek button with hover effects
end

function UI.CreateDashboard()
    -- Logic for building the dashboard with stats
end

function UI.ShowMessage(title, text, sender)
    -- Logic for showing a global message overlay
end

function UI.ShowPM(text, sender)
    -- Logic for showing a private message box with a reply button
end

return UI
