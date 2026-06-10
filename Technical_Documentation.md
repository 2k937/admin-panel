# Nexus Admin Technical Documentation

## Architecture

Nexus Admin follows a modular Roblox architecture with server-side permission enforcement. The server owns all rank, owner, group-rank, and command-execution decisions, while the client only receives permission metadata for display and panel toggling.

### Server-Side Components

| Component | Responsibility |
|---|---|
| `Main.lua` | Creates remotes, returns permission metadata, handles player joins, and forwards verified panel command requests. |
| `CommandManager.lua` | Registers commands, parses command messages, resolves aliases, and checks required permission levels. |
| `RankManager.lua` | Resolves effective permission levels from Place Owner, group-rank, and saved manual rank sources. |
| `DataStore.lua` | Persists manual rank assignments. |
| `LogManager.lua` | Stores in-memory command, join, and punishment logs. |
| `AntiExploit.lua` | Provides a foundation for server-side exploit checks. |

### Client-Side Components

| Component | Responsibility |
|---|---|
| `ClientMain.lua` | Requests permission metadata from the server, toggles the panel, initializes the admin button, and handles client-only effects. |
| `MainUI.lua` | Defines the admin panel theme and UI scaffold. |

### Shared Components

| Component | Responsibility |
|---|---|
| `Config.lua` | Stores rank definitions, command permission levels, aliases, Place Owner settings, and group-rank access rules. |

## Permission Resolution

`RankManager.GetPermissionData(player)` returns a structured permission table containing `CanOpen`, `Level`, `RankName`, `IsPlaceOwner`, `Protected`, `AccessSource`, and optional group metadata. This makes the access model explicit and gives the UI enough information to show the user’s access source without trusting the client for enforcement.

| Access Source | Resolution Rule | Notes |
|---|---|---|
| Place Owner | Individual place owner or group owner of the game receives the configured Place Owner level. | This role is automatic and protected from manual rank edits. |
| Group Rank | Configured group rules grant a permission level when `player:GetRankInGroup(GroupId) >= MinimumRank`. | Disabled by default and enabled in `Config.Access.GroupRanks`. |
| Manual Rank | Saved DataStore rank loaded by `LoadPlayerRank`. | Used for traditional admin assignments. |

When more than one non-owner access source applies, the highest effective level is used. Place Owner access takes priority and returns the protected owner role.

## Place Owner Protection

The Place Owner role is configured in `Config.Access.PlaceOwner` and defaults to level `255`. For user-owned places, `RankManager.IsPlaceOwner` checks `player.UserId == game.CreatorId`. For group-owned places, the manager attempts to resolve the group owner through Roblox group information and also falls back to rank `255` in the owning group.

The Place Owner role is intentionally not editable. `RankManager.SetPlayerRank` rejects attempts to overwrite the owner user, and `RankManager.CreateCustomRank` rejects custom ranks that attempt to replace the protected Place Owner level.

## Group-Rank Access

Group-rank access is configured in `Config.Access.GroupRanks`. The feature is disabled by default. A rule grants a Nexus Admin level to any player whose Roblox group rank meets or exceeds the configured minimum rank.

```lua
GroupRanks = {
    Enabled = true,
    Groups = {
        { GroupId = 123456, MinimumRank = 200, Level = 60, Name = "Group Admin" }
    }
}
```

| Rule Field | Description |
|---|---|
| `GroupId` | The Roblox group ID to inspect. |
| `MinimumRank` | The minimum group rank number required to match the rule. |
| `Level` | The Nexus Admin permission level granted by the rule. |
| `Name` | The rank name shown in permission metadata and welcome messages. |

## Command System

Every command is registered with a required level. `CommandManager.Execute` rejects messages without the configured prefix, resolves aliases, compares the player’s effective rank against the command level, and executes the callback only on the server. The panel command remote also calls into the same command manager, so chat commands and panel commands share the same permission path.

## Security

All command authorization remains server-side. The client may request permission metadata and show UI elements, but it cannot grant access to itself because `Main.lua`, `CommandManager.lua`, and `RankManager.lua` recompute permissions on the server for every command request. Guest users below the configured panel level cannot open the panel, and the Place Owner role cannot be manually removed or overwritten by rank-management code.
