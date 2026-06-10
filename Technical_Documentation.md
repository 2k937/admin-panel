# Nexus Admin Technical Documentation

## Architecture
Nexus Admin follows a modular architecture designed for performance and scalability in Roblox.

### Server-Side Components
- **Main.lua**: Entry point, handles player connections and command execution.
- **CommandManager.lua**: Registers and validates commands, checking permissions against `Config`.
- **RankManager.lua**: Manages player levels, custom ranks, and data persistence.
- **LogManager.lua**: Captures command, join, and punishment logs.
- **AntiExploit.lua**: Provides server-side checks for common exploits.
- **DataStore.lua**: Handles all database interactions with Roblox DataStoreService.

### Client-Side Components
- **ClientMain.lua**: Handles UI toggling, flight mechanics, and local command suggestions.
- **MainUI.lua**: Defines the structure and theme of the admin panel.

### Shared Components
- **Config.lua**: Central configuration for prefix, default ranks, and command levels.

## Command System
Every command is registered with a `RequiredLevel`. The `CommandManager` ensures that only players with a `RankLevel >= RequiredLevel` can execute it. 

### Target Selectors
- `all`: Targets everyone in the server.
- `others`: Targets everyone except the executor.
- `me`: Targets only the executor.
- `<name>`: Partial name or display name matching.

## Custom Rank System
Creators can define custom ranks via the UI or by editing the `Config` module. Ranks include:
- `Name`: Display name of the rank.
- `Level`: Numerical permission level (0-100).
- `Color`: UI and chat color.
- `Icon`: Asset ID for the rank icon.

## Security
- **Server-Side Validation**: All commands are validated on the server.
- **Data Integrity**: Ranks are saved using unique UserIds to prevent spoofing.
- **Anti-Exploit**: Basic movement and humanoid property checks.
