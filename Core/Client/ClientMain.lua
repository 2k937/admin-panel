local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- UI Keybind (default ';')
local function togglePanel()
    -- Request permission level from server
    local canOpen = ReplicatedStorage:WaitForChild("NexusAdmin_GetPermission"):InvokeServer()
    if canOpen then
        -- Toggle Admin Panel Visibility
        print("Opening Admin Panel")
    else
        print("You do not have permission to open the Admin Panel")
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Semicolon then
        togglePanel()
    end
end)

-- Command Suggestions logic
-- Flight logic
-- Notifications logic
