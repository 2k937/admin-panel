local Config = {
    ThemeColor = Color3.fromRGB(25, 25, 25),
    SecondaryColor = Color3.fromRGB(35, 35, 35),
    AccentColor = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamMedium
}

local UI = {}

function UI.CreateMainFrame()
    -- Main Container
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusAdmin_Panel"
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 700, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
    MainFrame.BackgroundColor3 = Config.ThemeColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- UICorner for modern rounded look
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = MainFrame
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Config.SecondaryColor
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 6)
    SidebarCorner.Parent = Sidebar
    
    -- Logo / Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.BackgroundTransparency = 1
    Title.Text = "Nexus Admin"
    Title.TextColor3 = Config.AccentColor
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Sidebar
    
    -- Content Area
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -180, 1, 0)
    Content.Position = UDim2.new(0, 180, 0, 0)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame
    
    return ScreenGui
end

function UI.CreateAdminButton()
    -- Modern floating toggle button
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusAdmin_Toggle"
    
    local Button = Instance.new("ImageButton")
    Button.Size = UDim2.new(0, 50, 0, 50)
    Button.Position = UDim2.new(1, -70, 1, -70)
    Button.BackgroundColor3 = Config.ThemeColor
    Button.Image = "rbxassetid://0" -- Modern Icon
    Button.BorderSizePixel = 0
    Button.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0) -- Circular
    Corner.Parent = Button
    
    return ScreenGui
end

function UI.Notify(title, text, type)
    -- Modern Notification
    -- Success: White accent
    -- Error: Subtle red or gray
end

return UI
