# Nexus Admin

Nexus Admin is a modern, high-performance, and feature-rich Roblox admin system. It features a sleek dark-themed interface, advanced security, persistent data storage, and a powerful command system.

## ✨ Key Features

- **Modern UI Redesign**: Completely redesigned interface with smooth animations and a clean aesthetic.
- **Advanced Anti-Exploit**: Smart detection for Speed, Fly, NoClip, God Mode, and Teleport hacks.
- **Anti-Backdoor Protection**: Automatic permanent bans for players attempting to use backdoors or unauthorized script injections.
- **Persistent Ban System**: Support for both **Timed Bans** (e.g., 10m, 2h, 1d) and **Permanent Bans**, all saved to DataStores.
- **Custom Tags System**: Overhead player tags with customizable names, colors, and icons (Level 80+).
- **Command Search Tab**: A dedicated tab to search and learn about every command, including descriptions and usage guides.
- **Smart Hierarchy**: Higher ranks automatically have access to all commands from lower ranks.
- **Group-Rank Integration**: Easy-to-configure group-based permissions.
- **Place Owner Protection**: Automatic, un-editable top-level access for the game or group owner.

## 🚀 Installation

1. Download the latest `NexusAdmin.rbxmx` from the [Releases](https://github.com/2k937/admin-panel/releases) page.
2. Drag and drop the file into **Roblox Studio**.
3. Move the `NexusAdmin` folder to `ServerScriptService`.
4. Publish your game and enable **API Services** (Game Settings > Security > Allow HTTP Requests & Enable Studio Access to API Services).

## 📊 Default Ranks

| Rank Name | Level | Description |
|---|---:|---|
| Place Owner | 255 | Automatic protected owner role for the game/group owner. |
| Creator | 100 | Full creator access for staff. |
| Head Admin | 80 | Senior administrator access (can manage tags and ranks). |
| Admin | 60 | Standard moderation access. |
| Moderator | 40 | Basic moderation access. |
| Helper | 20 | Minimum access to open the admin panel. |
| Player | 0 | Standard player with no access. |

## ⚙️ Configuration

### Group-Rank Access
Configured in `Core/Shared/Config.lua`. You can set a custom level higher than 255 to bypass Place Owner restrictions if desired.

```lua
GroupRanks = {
    Enabled = true,
    Groups = {
        { GroupId = 1234567, RoleNumber = 255, Level = 100, Name = "Group Owner" },
        { GroupId = 1234567, RoleNumber = 200, Level = 80, Name = "Group Admin" }
    }
}
```

### Anti-Exploit
Fully configurable detection settings in `Config.lua`. You can choose whether to Log, Warn, Kick, or Ban detected exploiters.

## 🛠 Commands

| Command | Usage | Level |
|---|---|---:|
| `:ban` | `:ban <player> <duration> <reason>` | 60 |
| `:warn` | `:warn <player> <reason>` | 40 |
| `:tag` | `:tag <player> <name> [color] [icon]` | 80 |
| `:rank` | `:rank <player> <level>` | 80 |
| `:viewinfo` | `:viewinfo <player>` | 40 |
| `:bring` | `:bring <player/all>` | 60 |
| `:goto` | `:goto <player>` | 60 |
| `:bans` | `:bans` | 40 |
| `:warnings` | `:warnings <player>` | 40 |

*Use the **Search Tab** in the admin panel for a full list of commands and usage guides.*

## 🔒 Security

Nexus Admin uses server-side validation for every action. Client-side UI changes or remote event spoofing cannot bypass permission levels. All sensitive data (Bans, Ranks, Tags) is stored securely using Roblox DataStores.

---
Created by Nexus Team.
