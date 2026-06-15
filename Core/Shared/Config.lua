local Config = {
    -- Core Settings
    Prefix = ":",
    SystemName = "Nexus Admin",
    ThemeColor = Color3.fromRGB(45, 45, 45),
    AccentColor = Color3.fromRGB(0, 170, 255),

    -- Access & Permissions
    Access = {
        MinimumPanelLevel = 20,
        PlaceOwner = {
            Enabled = true,
            Level = 255,
            Name = "Place Owner",
            Color = Color3.fromRGB(255, 0, 0),
            Icon = "rbxassetid://0"
        },
        GroupRanks = {
            Enabled = false,
            Groups = {}
        }
    },

    -- Rank Definitions
    DefaultRanks = {
        [255] = {Name = "Place Owner", Level = 255, Color = Color3.fromRGB(255, 0, 0), Icon = "rbxassetid://0", Protected = true},
        [100] = {Name = "Creator", Level = 100, Color = Color3.fromRGB(255, 0, 0), Icon = "rbxassetid://0"},
        [80] = {Name = "Head Admin", Level = 80, Color = Color3.fromRGB(255, 120, 0), Icon = "rbxassetid://0"},
        [60] = {Name = "Admin", Level = 60, Color = Color3.fromRGB(255, 255, 0), Icon = "rbxassetid://0"},
        [40] = {Name = "Moderator", Level = 40, Color = Color3.fromRGB(0, 255, 0), Icon = "rbxassetid://0"},
        [20] = {Name = "Helper", Level = 20, Color = Color3.fromRGB(0, 255, 255), Icon = "rbxassetid://0"},
        [0] = {Name = "Player", Level = 0, Color = Color3.fromRGB(255, 255, 255), Icon = "rbxassetid://0"}
    },

    -- Command Permissions
    CommandLevels = {
        -- Moderation
        kick = 40,
        ban = 60,
        gban = 80,
        unban = 60,
        warn = 20,
        warnings = 40,
        mute = 40,
        unmute = 40,
        jail = 40,
        unjail = 40,
        
        -- Communication
        announce = 60,
        message = 60,
        pm = 20,
        
        -- Player Management
        viewinfo = 40,
        history = 40,
        rank = 80,
        unrank = 80,
        bring = 60,
        goto = 60,
        bans = 40,
        
        -- World & Fun
        gravity = 80,
        time = 80,
        globalwalkspeed = 80,
        globaljumppower = 80,
        shutdown = 100,
        teleport = 60,
        fly = 60,
        noclip = 60,
        heal = 40,
        kill = 20,
        explode = 60,
        
        -- UI Systems
        tag = 80,
        untag = 80
    },

    -- Aliases
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

    -- Anti-Exploit Settings
    AntiExploit = {
        Enabled = true,
        AdminExemptLevel = 60,
        SpeedCheck = { Enabled = true, MaxSpeed = 50, Threshold = 100, CheckInterval = 0.5 },
        FlightCheck = { Enabled = true, MaxAirTime = 10, CheckInterval = 0.3 },
        NoClipCheck = { Enabled = true, CheckInterval = 0.5 },
        GodModeCheck = { Enabled = true, CheckInterval = 1 },
        TeleportCheck = { Enabled = true, MaxTeleportDistance = 500, CheckInterval = 0.5 },
        HumanoidStateCheck = { Enabled = true, CheckInterval = 0.5 },
        Actions = { Kick = true, Ban = false, BanDuration = 3600, Warn = true, Log = true },
        SuspiciousTracking = { Enabled = true, MaxWarnings = 3, ResetTime = 300 }
    },

    -- Tags System
    Tags = {
        Enabled = true,
        MinimumLevelToAssign = 80,
        MaxTagLength = 20,
        DefaultColor = Color3.fromRGB(0, 170, 255)
    }
}

return Config
