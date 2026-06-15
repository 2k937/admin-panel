local Config = {
    -- Default Settings
    Prefix = ":",
    SystemName = "Nexus Admin",
    ThemeColor = Color3.fromRGB(45, 45, 45),
    AccentColor = Color3.fromRGB(0, 170, 255),

    -- Tags System (Overhead player tags)
    Tags = {
        Enabled = true,
        MinimumLevelToAssign = 80,
        MaxTagLength = 20,
        DefaultTags = {}
    },

    -- Access Settings
    Access = {
        -- Minimum admin level required to open the panel from saved/manual ranks.
        MinimumPanelLevel = 20,

        -- Automatic protected owner role. This role is detected from the Roblox place owner
        -- and cannot be manually assigned, removed, or overwritten by rank-management code.
        PlaceOwner = {
            Enabled = true,
            Level = 255,
            Name = "Place Owner",
            Color = Color3.fromRGB(255, 0, 0),
            Icon = "rbxassetid://0"
        },

        -- Simplified Group-Rank Configuration
        -- Format: { GroupId = <group_id>, RoleNumber = <role_number>, Level = <level>, Name = "<name>" }
        -- Example: { GroupId = 123456, RoleNumber = 255, Level = 100, Name = "Owner" }
        -- Set Level higher than 255 (Place Owner) if you want this rank to bypass Place Owner restrictions
        GroupRanks = {
            Enabled = false,
            Groups = {
                -- Add your groups here like this:
                -- { GroupId = 123456, RoleNumber = 255, Level = 100, Name = "Group Owner" },
                -- { GroupId = 123456, RoleNumber = 200, Level = 80, Name = "Group Admin" },
            }
        }
    },

    -- Default Ranks
    DefaultRanks = {
        [255] = {Name = "Place Owner", Level = 255, Color = Color3.fromRGB(255, 0, 0), Icon = "rbxassetid://0", Protected = true},
        [100] = {Name = "Creator", Level = 100, Color = Color3.fromRGB(255, 0, 0), Icon = "rbxassetid://0"},
        [80] = {Name = "Head Admin", Level = 80, Color = Color3.fromRGB(255, 120, 0), Icon = "rbxassetid://0"},
        [60] = {Name = "Admin", Level = 60, Color = Color3.fromRGB(255, 255, 0), Icon = "rbxassetid://0"},
        [40] = {Name = "Moderator", Level = 40, Color = Color3.fromRGB(0, 255, 0), Icon = "rbxassetid://0"},
        [20] = {Name = "Helper", Level = 20, Color = Color3.fromRGB(0, 255, 255), Icon = "rbxassetid://0"},
        [0] = {Name = "Player", Level = 0, Color = Color3.fromRGB(255, 255, 255), Icon = "rbxassetid://0"}
    },

    -- Command Permission Overrides (Level)
    CommandLevels = {
        kick = 40,
        ban = 60,
        gban = 80,
        unban = 60,
        warn = 20,
        mute = 40,
        unmute = 40,
        jail = 40,
        unjail = 40,
        announce = 60,
        message = 60,
        pm = 20,
        shutdown = 100,
        teleport = 60,
        fly = 60,
        noclip = 60,
        heal = 40,
        kill = 20,
        rank = 80,
        unrank = 80,
        warnings = 40,
        viewinfo = 40,
        bring = 60,
        goto = 60,
        bans = 40,
        tag = 80,
        untag = 80,
        history = 40,
        gravity = 80,
        time = 80,
        globalwalkspeed = 80,
        globaljumppower = 80
    },

    -- Command Aliases
    Aliases = {
        k = "kick",
        b = "ban",
        m = "mute",
        tp = "teleport",
        h = "heal",
        sh = "shutdown",
        to = "goto",
        info = "viewinfo"
    },

    -- Access Settings
    Access = {
        MinimumPanelLevel = 20,
        PlaceOwner = {
            Enabled = true,
            Level = 255,
            Name = "Place Owner"
        }
    },

    -- Anti-Exploit Settings
    AntiExploit = {
        Enabled = true,
        AdminExemptLevel = 60,
        SpeedCheck = {
            Enabled = true,
            MaxSpeed = 50,
            Threshold = 100,
            CheckInterval = 0.5
        },
        FlightCheck = {
            Enabled = true,
            MaxAirTime = 10,
            CheckInterval = 0.3
        },
        NoClipCheck = {
            Enabled = true,
            CheckInterval = 0.5
        },
        GodModeCheck = {
            Enabled = true,
            CheckInterval = 1
        },
        TeleportCheck = {
            Enabled = true,
            MaxTeleportDistance = 500,
            CheckInterval = 0.5
        },
        HumanoidStateCheck = {
            Enabled = true,
            CheckInterval = 0.5
        },
        Actions = {
            Kick = true,
            Ban = false,
            BanDuration = 3600,
            Warn = true,
            Log = true
        },
        AdminExemptLevel = 60,
        SuspiciousTracking = {
            Enabled = true,
            MaxWarnings = 3,
            ResetTime = 300
        }
    },

    -- Player Tag Settings
    Tags = {
        Enabled = true,
        MaxTagLength = 20,
        DefaultColor = Color3.fromRGB(0, 170, 255)
    },

    -- Default Rank Definitions
    DefaultRanks = {
        [0] = { Name = "Player", Level = 0 },
        [20] = { Name = "Moderator", Level = 20 },
        [40] = { Name = "Admin", Level = 40 },
        [60] = { Name = "Super Admin", Level = 60 },
        [80] = { Name = "Head Admin", Level = 80 },
        [100] = { Name = "Creator", Level = 100 },
        [255] = { Name = "Place Owner", Level = 255 }
    },

    -- Core Settings
    Prefix = ":"
}

return Config
