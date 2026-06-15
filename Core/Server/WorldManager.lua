local WorldManager = {}
local Lighting = game:GetService("Lighting")

local CurrentSettings = {
    Gravity = workspace.Gravity,
    TimeOfDay = Lighting.TimeOfDay,
    WalkSpeed = 16,
    JumpPower = 50
}

function WorldManager.SetGravity(value)
    workspace.Gravity = value
    CurrentSettings.Gravity = value
end

function WorldManager.SetTime(value)
    Lighting.TimeOfDay = value
    CurrentSettings.TimeOfDay = value
end

function WorldManager.SetGlobalWalkSpeed(value)
    CurrentSettings.WalkSpeed = value
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
end

function WorldManager.SetGlobalJumpPower(value)
    CurrentSettings.JumpPower = value
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = value
            player.Character.Humanoid.UseJumpPower = true
        end
    end
end

function WorldManager.GetSettings()
    return CurrentSettings
end

return WorldManager
