local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- UI Keybind (default ';')
local function togglePanel()
    -- Request permission level from server
    local success, canOpen = pcall(function()
        return ReplicatedStorage:WaitForChild("NexusAdmin_GetPermission", 1):InvokeServer()
    end)
    
    if success and canOpen then
        -- Toggle Admin Panel Visibility
        -- (Actual UI visibility logic here)
    end
    -- If not canOpen, do absolutely nothing (no notifications, no prints)
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
ReplicatedStorage:WaitForChild("NexusAdmin_Notify").OnClientEvent:Connect(function(title, text)
    -- Logic to show a modern notification on the screen
    print("NOTIFICATION: [" .. title .. "] " .. text)
end)

ReplicatedStorage:WaitForChild("NexusAdmin_Message").OnClientEvent:Connect(function(title, text, sender)
    -- Show global message UI
    print("GLOBAL MESSAGE from " .. sender .. ": [" .. title .. "] " .. text)
end)

ReplicatedStorage:WaitForChild("NexusAdmin_PM").OnClientEvent:Connect(function(text, sender)
    -- Show private message UI
    print("PM from " .. sender .. ": " .. text)
end)

local flying = false
local speed = 50
local bv, bg

ReplicatedStorage:WaitForChild("NexusAdmin_Fly").OnClientEvent:Connect(function(enabled)
    flying = enabled
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    if flying then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        
        task.spawn(function()
            while flying do
                local cam = workspace.CurrentCamera
                local moveDir = char.Humanoid.MoveDirection
                bv.Velocity = (cam.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, moveDir.Z)) * speed) + Vector3.new(0, (UserInputService:IsKeyDown(Enum.KeyCode.Space) and speed or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and speed or 0), 0)
                bg.CFrame = cam.CFrame
                task.wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
    else
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end)

ReplicatedStorage:WaitForChild("NexusAdmin_NoClip").OnClientEvent:Connect(function(enabled)
    -- Toggle noclip logic
end)
