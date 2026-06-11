local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local MainUI = require(script.Parent.Parent.UI.MainUI)

local PermissionData = nil
local PanelInstance = nil
local AdminButton = nil
local IsPanelOpen = false

-- Create the main screen GUI container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusAdmin_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local function canOpenFromPermission(permission)
    if typeof(permission) == "table" then
        PermissionData = permission
        return permission.CanOpen == true
    end
    return permission == true
end

local function getPermission()
    local permissionRemote = ReplicatedStorage:WaitForChild("NexusAdmin_GetPermission", 5)
    if not permissionRemote then
        return false
    end

    local success, permission = pcall(function()
        return permissionRemote:InvokeServer()
    end)

    return success and canOpenFromPermission(permission)
end

local function togglePanel()
    if not PermissionData then
        if not getPermission() then return end
    end

    if not PanelInstance then
        -- Initialize the Dashboard UI
        local dashboardData = MainUI.CreateModernDashboard({
            Name = Player.Name,
            DisplayName = Player.DisplayName,
            UserId = Player.UserId,
            Rank = PermissionData.RankName,
            Level = PermissionData.Level,
            IsPlaceOwner = PermissionData.IsPlaceOwner,
            AccessSource = PermissionData.AccessSource
        })
        
        -- In a real Roblox environment, we would build the UI objects here.
        -- For this revamp, we'll simulate the container.
        PanelInstance = Instance.new("Frame")
        PanelInstance.Name = "MainPanel"
        PanelInstance.Size = UDim2.new(0, 600, 0, 400)
        PanelInstance.Position = UDim2.new(0.5, -300, 0.5, -200)
        PanelInstance.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        PanelInstance.BorderSizePixel = 0
        PanelInstance.Visible = false
        PanelInstance.Parent = ScreenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = PanelInstance
    end

    IsPanelOpen = not IsPanelOpen
    PanelInstance.Visible = IsPanelOpen
    
    if IsPanelOpen then
        -- Play open animation
        PanelInstance.GroupTransparency = 1
        TweenService:Create(PanelInstance, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
    end
end

-- Initialize Admin Button
task.spawn(function()
    if getPermission() then
        local buttonData = MainUI.CreateAdminButton(PermissionData)
        
        AdminButton = Instance.new("TextButton")
        AdminButton.Name = "AdminToggleButton"
        AdminButton.Size = buttonData.Size
        AdminButton.Position = buttonData.Position
        AdminButton.AnchorPoint = buttonData.AnchorPoint
        AdminButton.BackgroundColor3 = buttonData.BackgroundColor
        AdminButton.Text = buttonData.Label
        AdminButton.TextColor3 = buttonData.TextColor
        AdminButton.Font = Enum.Font.GothamBold
        AdminButton.TextSize = 14
        AdminButton.Parent = ScreenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = buttonData.CornerRadius
        corner.Parent = AdminButton
        
        AdminButton.MouseButton1Click:Connect(togglePanel)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Semicolon then
        togglePanel()
    end
end)

-- Remote Event Handling
ReplicatedStorage:WaitForChild("NexusAdmin_Notify").OnClientEvent:Connect(function(title, text)
    -- Create a notification using MainUI logic
    print("NOTIFICATION: [" .. title .. "] " .. text)
end)

ReplicatedStorage:WaitForChild("NexusAdmin_Message").OnClientEvent:Connect(function(title, text, sender)
    print("GLOBAL MESSAGE from " .. sender .. ": [" .. title .. "] " .. text)
end)

ReplicatedStorage:WaitForChild("NexusAdmin_PM").OnClientEvent:Connect(function(text, sender)
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
