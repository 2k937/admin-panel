local Config = {
    -- Default Settings
    Prefix = ":",
    SystemName = "Nexus Admin",
    ThemeColor = Color3.fromRGB(45, 45, 45),
    AccentColor = Color3.fromRGB(0, 170, 255),

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

        -- Optional group-rank panel access. Add entries like:
        -- { GroupId = 123456, MinimumRank = 200, Level = 60, Name = "Group Admin" }
        GroupRanks = {
            Enabled = false,
            Groups = {}
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
        unban = 60,
        warn = 20,
        mute = 40,
        unmute = 40,
        jail = 40,
        unjail = 40,
        freeze = 40,
        unfreeze = 40,
        fly = 60,
        unfly = 60,
        noclip = 60,
        clip = 60,
        speed = 40,
        jump = 40,
        heal = 40,
        damage = 60,
        god = 60,
        ungod = 60,
        bring = 40,
        goto = 40,
        teleport = 40,
        respawn = 40,
        explode = 60,
        sparkles = 40,
        fire = 40,
        smoke = 40,
        invisible = 60,
        visible = 60,
        size = 60,
        fling = 60,
        sit = 40,
        unsit = 40,
        lock = 80,
        unlock = 80,
        shutdown = 100,
        announce = 60,
        message = 60,
        pm = 40,
        view = 40,
        unview = 40,
        kill = 20,
        rank = 80,
        unrank = 80,
        warn = 40,
        warnings = 40,
        viewinfo = 40,
        bring = 60,
        goto = 60
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

    -- Anti-Exploit Settings
    AntiExploit = {
        Enabled = true,
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
    }
}

return Config
