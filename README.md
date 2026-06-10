# Nexus Admin

Nexus Admin is a modern and customizable Roblox admin system with server-side permission checks, protected owner access, and optional group-rank panel access.

## Features

Nexus Admin includes a dark-themed admin interface scaffold, permanent rank storage through DataStores, command permission checks, welcome notifications for authorized users, and silent rejection for guests who do not have panel access. The latest access system adds an automatic **Place Owner** role and configurable **group-rank access** for group-managed games.

## Installation

1. Download the latest `NexusAdmin.rbxmx` from the [Releases](https://github.com/2k937/admin-panel/releases) page.
2. Drag and drop the file into **Roblox Studio**.
3. Move the `NexusAdmin` folder to `ServerScriptService`.
4. Publish your game and enable **API Services** if you are using DataStores.

## Default Ranks

| Rank Name | Level | Description |
|---|---:|---|
| Place Owner | 255 | Automatic protected owner role for the user who owns the place or the owner of the group that owns the place. This role cannot be manually edited or replaced. |
| Creator | 100 | High-level creator access for manually configured staff. |
| Head Admin | 80 | Senior administrator access. |
| Admin | 60 | Standard moderation access. |
| Moderator | 40 | Basic moderation access. |
| Helper | 20 | Minimum default panel access. |
| Player | 0 | No admin panel access. |

## Place Owner Access

The **Place Owner** role is detected automatically by `RankManager.lua`. If the place is owned by an individual user, the player whose `UserId` matches `game.CreatorId` receives level `255`. If the place is owned by a Roblox group, the system attempts to resolve the group owner through `GroupService:GetGroupInfoAsync(game.CreatorId)` and grants that owner level `255`.

This role is protected. Calls to `SetPlayerRank` will not overwrite the Place Owner, and `CreateCustomRank` will not replace the protected Place Owner rank level.

## Group-Rank Panel Access

Group-rank access is configured in `Core/Shared/Config.lua`. It is disabled by default so existing games keep their current behavior until the owner enables it.

```lua
Access = {
    MinimumPanelLevel = 20,

    GroupRanks = {
        Enabled = true,
        Groups = {
            { GroupId = 123456, MinimumRank = 200, Level = 60, Name = "Group Admin" },
            { GroupId = 123456, MinimumRank = 100, Level = 20, Name = "Group Helper" }
        }
    }
}
```

| Field | Meaning |
|---|---|
| `GroupId` | Roblox group ID to check. |
| `MinimumRank` | Minimum Roblox group rank number required for access. |
| `Level` | Nexus Admin permission level granted when the rule matches. |
| `Name` | Display name returned to the client for welcome and UI metadata. |

If a player has both a saved manual rank and a matching group-rank rule, the system uses the higher effective level. The server still validates every command, so client-side UI changes cannot grant extra permissions.

## Usage

The default command prefix is `:`. The default panel keybind is `;`, and only users who resolve to level `20` or higher can open the panel. Guests who do not meet the minimum access requirement are silently rejected.

Created by Nexus Team.
