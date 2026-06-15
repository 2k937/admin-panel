-- Modern UI Components for Nexus Admin
local UI = {}

-- Modern Color Scheme
local Colors = {
    Primary = Color3.fromRGB(45, 45, 45),
    Secondary = Color3.fromRGB(55, 55, 55),
    Accent = Color3.fromRGB(0, 170, 255),
    Success = Color3.fromRGB(0, 200, 100),
    Warning = Color3.fromRGB(255, 150, 0),
    Danger = Color3.fromRGB(255, 50, 50),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(200, 200, 200)
}

-- Modern Warning Notification UI
function UI.CreateModernWarning(moderatorName, reason, warningCount)
    return {
        Type = "Warning",
        Title = "⚠️ You Have Been Warned",
        Moderator = moderatorName,
        Reason = reason,
        WarningCount = warningCount,
        
        -- Modern styling
        BackgroundColor = Colors.Danger,
        TextColor = Colors.Text,
        BorderColor = Color3.fromRGB(255, 100, 100),
        BorderSize = 2,
        CornerRadius = 12,
        Padding = 20,
        
        -- Animation
        FadeInDuration = 0.3,
        DisplayDuration = 5,
        FadeOutDuration = 0.3,
        
        -- Content
        Content = {
            Title = "⚠️ You Have Been Warned",
            Subtitle = "Warned by: " .. moderatorName,
            Body = "Reason: " .. reason,
            Footer = "Total Warnings: " .. warningCount,
            Icon = "rbxassetid://0"
        }
    }
end

-- Modern Announcement UI
function UI.CreateModernAnnouncement(title, message, sender)
    return {
        Type = "Announcement",
        Title = title,
        Message = message,
        Sender = sender,
        
        -- Modern styling
        BackgroundColor = Colors.Accent,
        TextColor = Colors.Text,
        BorderColor = Color3.fromRGB(0, 200, 255),
        BorderSize = 2,
        CornerRadius = 12,
        Padding = 20,
        
        -- Animation
        SlideInDuration = 0.4,
        DisplayDuration = 8,
        SlideOutDuration = 0.4,
        
        -- Content
        Content = {
            Title = title,
            Body = message,
            Sender = "📢 " .. sender,
            Icon = "rbxassetid://0"
        }
    }
end

-- Modern Private Message UI
function UI.CreateModernPM(sender, message)
    return {
        Type = "PrivateMessage",
        Sender = sender,
        Message = message,
        
        -- Modern styling
        BackgroundColor = Colors.Secondary,
        TextColor = Colors.Text,
        BorderColor = Colors.Accent,
        BorderSize = 2,
        CornerRadius = 12,
        Padding = 15,
        
        -- Animation
        PopInDuration = 0.3,
        DisplayDuration = 10,
        PopOutDuration = 0.3,
        
        -- Content
        Content = {
            Title = "💬 Private Message",
            Sender = "From: " .. sender,
            Body = message,
            ActionButtons = {
                {
                    Text = "Reply",
                    Color = Colors.Accent,
                    Action = "reply"
                },
                {
                    Text = "Close",
                    Color = Colors.TextDim,
                    Action = "close"
                }
            }
        }
    }
end

-- Modern Dashboard UI
function UI.CreateModernDashboard(playerData)
    return {
        Type = "Dashboard",
        
        -- Modern styling
        BackgroundColor = Colors.Primary,
        TextColor = Colors.Text,
        AccentColor = Colors.Accent,
        CornerRadius = 12,
        
        -- Header
        Header = {
            Title = "Welcome, " .. (playerData.DisplayName or playerData.Name),
            Subtitle = "Nexus Admin Panel",
            Icon = "rbxassetid://0"
        },
        
        -- User Profile Section
        UserProfile = {
            DisplayName = playerData.DisplayName or playerData.Name,
            UserId = playerData.UserId,
            Rank = playerData.Rank or "Player",
            Level = playerData.Level or 0,
            IsPlaceOwner = playerData.IsPlaceOwner or false,
            AccessSource = playerData.AccessSource or "Manual Rank",
            
            -- Modern card styling
            CardColor = Colors.Secondary,
            CardBorderColor = Colors.Accent,
            CardBorderSize = 1,
            CardCornerRadius = 8,
            CardPadding = 15
        },
        
        -- Stats Section
        Stats = {
            {
                Label = "Players Online",
                Value = 0,
                Icon = "👥",
                Color = Colors.Accent
            },
            {
                Label = "Admins Online",
                Value = 0,
                Icon = "🛡️",
                Color = Colors.Success
            },
            {
                Label = "Banned Players",
                Value = 0,
                Icon = "🚫",
                Color = Colors.Danger
            },
            {
                Label = "Commands Executed",
                Value = 0,
                Icon = "⚡",
                Color = Colors.Warning
            }
        },
        
        -- Quick Actions
        QuickActions = {
            {
                Name = "Execute",
                Icon = "⚙️",
                Color = Colors.Accent,
                Action = "execute"
            },
            {
                Name = "Bans",
                Icon = "🚫",
                Color = Colors.Danger,
                Action = "bans"
            },
            {
                Name = "Warnings",
                Icon = "⚠️",
                Color = Colors.Warning,
                Action = "warnings"
            },
            {
                Name = "History",
                Icon = "📜",
                Color = Colors.Success,
                Action = "history"
            },
            {
                Name = "World",
                Icon = "🌍",
                Color = Color3.fromRGB(100, 200, 100),
                Action = "world"
            },
            {
                Name = "Settings",
                Icon = "⚙️",
                Color = Colors.TextDim,
                Action = "settings"
            }
        }
    }
end

function UI.CreatePlayerDetailsView(historyData, banData, warningData)
    return {
        Type = "PlayerDetails",
        Title = "Player Management",
        
        -- Modern styling
        BackgroundColor = Colors.Primary,
        TextColor = Colors.Text,
        AccentColor = Colors.Accent,
        CornerRadius = 12,
        
        -- Data
        History = historyData,
        BanStatus = banData,
        Warnings = warningData,
        
        -- Sections
        Sections = {
            {
                Name = "Statistics",
                Icon = "📊",
                Items = {
                    { Label = "Total Joins", Value = historyData.TotalJoins or 0 },
                    { Label = "Total Playtime", Value = math.floor((historyData.TotalPlayTime or 0) / 60) .. " mins" },
                    { Label = "First Joined", Value = os.date("%Y-%m-%d", historyData.FirstJoin or 0) },
                    { Label = "Last Joined", Value = os.date("%Y-%m-%d", historyData.LastJoin or 0) }
                }
            },
            {
                Name = "Moderation",
                Icon = "🛡️",
                Items = {
                    { Label = "Ban Status", Value = banData and (banData.Permanent and "Permanent" or "Temporary") or "None" },
                    { Label = "Warnings", Value = #warningData .. " warnings" }
                },
                Actions = {
                    { Name = "Warn", Color = Colors.Warning, Action = "warn" },
                    { Name = "Ban", Color = Colors.Danger, Action = "ban" },
                    { Name = "Global Ban", Color = Color3.fromRGB(150, 0, 0), Action = "globalban" }
                }
            }
        }
    }
end

function UI.CreateWorldSettingsView(currentSettings)
    return {
        Type = "WorldSettings",
        Title = "Live Game Settings",
        Subtitle = "Manage server environment (Level 80+ only)",
        
        -- Modern styling
        BackgroundColor = Colors.Primary,
        TextColor = Colors.Text,
        AccentColor = Colors.Accent,
        CornerRadius = 12,
        
        -- Controls
        Controls = {
            {
                Name = "Environment",
                Icon = "🌤️",
                Items = {
                    { Label = "Gravity", Type = "Slider", Min = 0, Max = 500, Value = currentSettings.Gravity, Action = "SetGravity" },
                    { Label = "Time of Day", Type = "TextInput", Placeholder = "e.g., 12:00:00", Value = currentSettings.TimeOfDay, Action = "SetTime" }
                }
            },
            {
                Name = "Global Physics",
                Icon = "🏃",
                Items = {
                    { Label = "Global WalkSpeed", Type = "Slider", Min = 0, Max = 100, Value = currentSettings.WalkSpeed, Action = "SetGlobalWalkSpeed" },
                    { Label = "Global JumpPower", Type = "Slider", Min = 0, Max = 200, Value = currentSettings.JumpPower, Action = "SetGlobalJumpPower" }
                }
            }
        }
    }
end

-- Modern Notification UI
function UI.CreateModernNotification(title, message, notificationType)
    local typeColors = {
        success = Colors.Success,
        error = Colors.Danger,
        warning = Colors.Warning,
        info = Colors.Accent
    }
    
    return {
        Type = "Notification",
        Title = title,
        Message = message,
        NotificationType = notificationType or "info",
        
        -- Modern styling
        BackgroundColor = typeColors[notificationType or "info"] or Colors.Accent,
        TextColor = Colors.Text,
        BorderColor = Color3.fromRGB(255, 255, 255),
        BorderSize = 1,
        CornerRadius = 8,
        Padding = 12,
        
        -- Animation
        FadeInDuration = 0.2,
        DisplayDuration = 4,
        FadeOutDuration = 0.2,
        
        -- Content
        Content = {
            Title = title,
            Body = message,
            Icon = "rbxassetid://0"
        }
    }
end

-- Modern Button Component
function UI.CreateModernButton(text, color, action)
    return {
        Type = "Button",
        Text = text,
        Color = color or Colors.Accent,
        HoverColor = Color3.fromRGB(
            math.min(color.R * 1.2, 1),
            math.min(color.G * 1.2, 1),
            math.min(color.B * 1.2, 1)
        ),
        PressedColor = Color3.fromRGB(
            math.max(color.R * 0.8, 0),
            math.max(color.G * 0.8, 0),
            math.max(color.B * 0.8, 0)
        ),
        TextColor = Colors.Text,
        CornerRadius = 8,
        Padding = 12,
        BorderSize = 0,
        Action = action
    }
end

-- Modern Tab Component
function UI.CreateModernTab(name, icon, content)
    return {
        Type = "Tab",
        Name = name,
        Icon = icon,
        Content = content,
        
        -- Modern styling
        BackgroundColor = Colors.Secondary,
        ActiveColor = Colors.Accent,
        InactiveColor = Colors.TextDim,
        CornerRadius = 8,
        Padding = 10
    }
end

-- Modern Tag Management UI
function UI.CreateTagManagementPanel()
    return {
        Type = "TagManagement",
        Title = "Player Tags",
        Subtitle = "Manage custom player tags (Level 80+ only)",
        
        -- Modern styling
        BackgroundColor = Colors.Primary,
        TextColor = Colors.Text,
        AccentColor = Colors.Accent,
        CornerRadius = 12,
        
        -- Sections
        Sections = {
            {
                Name = "Assign Tag",
                Icon = "🏷️",
                Fields = {
                    {
                        Label = "Player",
                        Type = "PlayerSelect",
                        Placeholder = "Select a player"
                    },
                    {
                        Label = "Tag Name",
                        Type = "TextInput",
                        Placeholder = "e.g., Moderator, Developer",
                        MaxLength = 20
                    },
                    {
                        Label = "Tag Color",
                        Type = "ColorPicker",
                        DefaultColor = Colors.Accent
                    },
                    {
                        Label = "Tag Icon (Optional)",
                        Type = "TextInput",
                        Placeholder = "e.g., 🛡️, ⚙️",
                        MaxLength = 2
                    }
                },
                Action = "AssignTag",
                ButtonText = "Assign Tag",
                ButtonColor = Colors.Success
            },
            {
                Name = "Remove Tag",
                Icon = "❌",
                Fields = {
                    {
                        Label = "Player",
                        Type = "PlayerSelect",
                        Placeholder = "Select a player"
                    }
                },
                Action = "RemoveTag",
                ButtonText = "Remove Tag",
                ButtonColor = Colors.Danger
            },
            {
                Name = "Active Tags",
                Icon = "📋",
                Type = "TagList",
                Content = {
                    -- Dynamically populated with current tags
                    -- Format: { PlayerName = "...", UserId = ..., TagName = "...", TagColor = Color3, Icon = "..." }
                }
            }
        }
    }
end

function UI.CreateTagCard(playerName, userId, tagName, tagColor, icon)
    return {
        Type = "TagCard",
        PlayerName = playerName,
        UserId = userId,
        TagName = tagName,
        TagColor = tagColor,
        Icon = icon or "",
        
        -- Modern styling
        CardColor = Colors.Secondary,
        CardBorderColor = tagColor,
        CardBorderSize = 2,
        CardCornerRadius = 8,
        CardPadding = 12,
        
        -- Actions
        Actions = {
            {
                Name = "Edit",
                Icon = "✏️",
                Color = Colors.Accent,
                Action = "EditTag"
            },
            {
                Name = "Remove",
                Icon = "🗑️",
                Color = Colors.Danger,
                Action = "RemoveTag"
            }
        }
    }
end

-- Modern Command Search Tab UI
function UI.CreateCommandSearchTab()
    return {
        Type = "CommandSearch",
        Title = "Commands",
        Subtitle = "Search and learn about available commands",
        
        -- Modern styling
        BackgroundColor = Colors.Primary,
        TextColor = Colors.Text,
        AccentColor = Colors.Accent,
        CornerRadius = 12,
        
        -- Search Bar
        SearchBar = {
            Placeholder = "Search commands by name or description...",
            BackgroundColor = Colors.Secondary,
            TextColor = Colors.Text,
            CornerRadius = 8,
            Padding = 12,
            BorderColor = Colors.Accent,
            BorderSize = 1
        },
        
        -- Filter Options
        Filters = {
            {
                Name = "All Commands",
                Icon = "📋",
                Action = "all"
            },
            {
                Name = "Moderation",
                Icon = "🛡️",
                Action = "moderation"
            },
            {
                Name = "Utility",
                Icon = "⚙️",
                Action = "utility"
            },
            {
                Name = "Admin",
                Icon = "👑",
                Action = "admin"
            }
        }
    }
end

function UI.CreateCommandCard(commandName, level, description, canUse)
    return {
        Type = "CommandCard",
        CommandName = commandName,
        RequiredLevel = level,
        Description = description,
        CanUse = canUse,
        
        -- Modern styling
        CardColor = canUse and Colors.Secondary or Color3.fromRGB(80, 40, 40),
        CardBorderColor = canUse and Colors.Accent or Colors.Danger,
        CardBorderSize = 2,
        CardCornerRadius = 8,
        CardPadding = 15,
        
        -- Content
        Content = {
            Title = ":" .. commandName,
            Subtitle = "Required Level: " .. level,
            Body = description,
            Status = canUse and "✅ Available" or "🔒 Locked",
            StatusColor = canUse and Colors.Success or Colors.Danger
        },
        
        -- Action
        CopyButton = {
            Text = "Copy Command",
            Color = Colors.Accent,
            Action = "CopyCommand"
        }
    }
end

function UI.CreateCommandDetailView(commandName, level, description, usage, examples)
    return {
        Type = "CommandDetail",
        CommandName = commandName,
        RequiredLevel = level,
        
        -- Modern styling
        BackgroundColor = Colors.Primary,
        TextColor = Colors.Text,
        AccentColor = Colors.Accent,
        CornerRadius = 12,
        
        -- Sections
        Sections = {
            {
                Title = "Command",
                Content = ":" .. commandName,
                Icon = "📝"
            },
            {
                Title = "Description",
                Content = description,
                Icon = "📖"
            },
            {
                Title = "Usage",
                Content = usage or ":" .. commandName .. " [args]",
                Icon = "💡",
                CodeBlock = true
            },
            {
                Title = "Required Level",
                Content = tostring(level),
                Icon = "🔐"
            },
            {
                Title = "Examples",
                Content = examples or "No examples available",
                Icon = "📚",
                CodeBlock = true
            }
        }
    }
end

-- Floating Admin Button (toggle for mobile/PC accessibility)
function UI.CreateAdminButton(permissionData)
    return {
        Type = "AdminButton",
        Label = "Admin",
        Icon = "🛡️",
        Level = permissionData and permissionData.Level or 0,
        RankName = permissionData and permissionData.RankName or "Player",

        -- Modern styling
        BackgroundColor = Colors.Accent,
        TextColor = Colors.Text,
        CornerRadius = 8,
        Size = UDim2.new(0, 80, 0, 36),
        Position = UDim2.new(1, -90, 1, -50),
        AnchorPoint = Vector2.new(1, 1),

        -- Action
        Action = "TogglePanel"
    }
end

-- Modern Logs Tab UI
function UI.CreateLogsTab()
    return {
        Type = "Logs",
        Title = "Audit Logs",
        Subtitle = "Review server actions and command usage",
        
        -- Modern styling
        BackgroundColor = Colors.Primary,
        TextColor = Colors.Text,
        AccentColor = Colors.Accent,
        CornerRadius = 12,
        
        -- Log Categories
        Categories = {
            {
                Name = "Command Logs",
                Icon = "⚡",
                Action = "get_command_logs"
            },
            {
                Name = "Punishment Logs",
                Icon = "🚫",
                Action = "get_punishment_logs"
            },
            {
                Name = "Join Logs",
                Icon = "👥",
                Action = "get_join_logs"
            }
        }
    }
end

-- Modern Log Entry Component
function UI.CreateLogEntry(timestamp, user, action, details)
    return {
        Type = "LogEntry",
        Timestamp = timestamp,
        User = user,
        Action = action,
        Details = details,
        
        -- Modern styling
        BackgroundColor = Colors.Secondary,
        TextColor = Colors.Text,
        AccentColor = Colors.Accent,
        CornerRadius = 8,
        Padding = 10,
        
        -- Content
        TimeStr = os.date("%H:%M:%S", timestamp),
        HeaderText = user .. " executed " .. action,
        BodyText = details
    }
end

return UI
