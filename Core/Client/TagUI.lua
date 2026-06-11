local TagUI = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local function createTagLabel(player, tagData)
    if not tagData or not tagData.Name then
        return nil
    end

    local screenGui = Instance.new("BillboardGui")
    screenGui.Name = "TagBillboard_" .. player.UserId
    screenGui.Size = UDim2.new(6, 0, 2, 0)
    screenGui.MaxDistance = 100
    screenGui.StudsOffset = Vector3.new(0, 3, 0)

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TagLabel"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundColor3 = tagData.Color
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = (tagData.Icon or "") .. " " .. tagData.Name
    textLabel.BackgroundTransparency = 0.2
    textLabel.BorderSizePixel = 0

    -- Modern rounded corners effect
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = textLabel

    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.Parent = textLabel

    textLabel.Parent = screenGui

    local char = player.Character
    if char and char:FindFirstChild("Head") then
        screenGui.Adornee = char.Head
        screenGui.Parent = char.Head
    end

    return screenGui
end

function TagUI.RenderPlayerTag(player, tagData)
    if not player or not player.Character then
        return
    end

    local head = player.Character:FindFirstChild("Head")
    if not head then
        return
    end

    -- Remove existing tag
    local existingTag = head:FindFirstChild("TagBillboard_" .. player.UserId)
    if existingTag then
        existingTag:Destroy()
    end

    -- Create new tag if data exists
    if tagData then
        createTagLabel(player, tagData)
    end
end

function TagUI.RemovePlayerTag(player)
    if not player or not player.Character then
        return
    end

    local head = player.Character:FindFirstChild("Head")
    if not head then
        return
    end

    local existingTag = head:FindFirstChild("TagBillboard_" .. player.UserId)
    if existingTag then
        existingTag:Destroy()
    end
end

function TagUI.UpdateAllPlayerTags(allTags)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            local tagData = allTags[player.UserId]
            TagUI.RenderPlayerTag(player, tagData)
        end
    end
end

return TagUI
