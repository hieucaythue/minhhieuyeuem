local ESPEnabled = false
local ESPHandles = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Cấu hình ESP
local ESPConfig = {
    Colors = {
        Items = Color3.fromRGB(255, 105, 105),    -- Màu đỏ nhạt cho Items
        Animals = Color3.fromRGB(170, 85, 255),   -- Màu tím cho Animals
        NightEnemies = Color3.fromRGB(85, 170, 255), -- Màu xanh dương cho NightEnemies
        Zombies = Color3.fromRGB(85, 255, 85)     -- Màu xanh lá cho Zombies
    },
    Settings = {
        OutlineTransparency = 0.2,  -- Độ trong suốt viền
        FillTransparency = 0.6,     -- Độ trong suốt phần tô
        TextSize = 16,              -- Kích thước chữ
        BillboardSize = UDim2.new(0, 120, 0, 50), -- Tăng kích thước để chứa khoảng cách
        LineThickness = 1,          -- Độ dày của đường kẻ
        LineTransparency = 0        -- Độ trong suốt của đường kẻ
    }
}

local function CreateESP(object, color, category)
    if not object or not object.PrimaryPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_ProHighlight"
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = ESPConfig.Settings.FillTransparency
    highlight.OutlineTransparency = ESPConfig.Settings.OutlineTransparency
    highlight.Parent = object

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_ProBillboard"
    billboard.Adornee = object.PrimaryPart
    billboard.Size = ESPConfig.Settings.BillboardSize
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = object

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Text = object.Name
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.TextColor3 = color
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextSize = ESPConfig.Settings.TextSize
    nameLabel.Font = Enum.Font.SourceSansSemibold
    nameLabel.TextStrokeTransparency = 0.4
    nameLabel.TextStrokeColor3 = Color3.fromRGB(20, 20, 20)
    nameLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Text = "0 studs"
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.TextColor3 = color
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextSize = ESPConfig.Settings.TextSize - 2 -- Nhỏ hơn một chút
    distanceLabel.Font = Enum.Font.SourceSansSemibold
    distanceLabel.TextStrokeTransparency = 0.4
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(20, 20, 20)
    distanceLabel.Parent = billboard

    local line = Instance.new("CylinderHandleAdornment")
    line.Name = "ESP_Line"
    line.Adornee = object.PrimaryPart
    line.Height = 0.1
    line.Radius = ESPConfig.Settings.LineThickness / 10
    line.Color3 = color
    line.Transparency = ESPConfig.Settings.LineTransparency
    line.Parent = object
    line.AlwaysOnTop = true

    ESPHandles[object] = {
        Highlight = highlight,
        Billboard = billboard,
        NameLabel = nameLabel,
        DistanceLabel = distanceLabel,
        Line = line
    }
end

local function ClearESP()
    for obj, handles in pairs(ESPHandles) do
        if handles.Highlight then handles.Highlight:Destroy() end
        if handles.Billboard then handles.Billboard:Destroy() end
        if handles.Line then handles.Line:Destroy() end
    end
    ESPHandles = {}
end

local function UpdateESP()
    ClearESP()

    local runtimeItems = Workspace:FindFirstChild("RuntimeItems")
    if runtimeItems then
        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") then
                CreateESP(item, ESPConfig.Colors.Items, "Items")
            end
        end
    end

    local baseplates = Workspace:FindFirstChild("Baseplates")
    if baseplates and #baseplates:GetChildren() >= 2 then
        local secondBaseplate = baseplates:GetChildren()[2]
        local centerBaseplate = secondBaseplate and secondBaseplate:FindFirstChild("CenterBaseplate")
        local animals = centerBaseplate and centerBaseplate:FindFirstChild("Animals")
        if animals then
            for _, animal in ipairs(animals:GetDescendants()) do
                if animal:IsA("Model") then
                    CreateESP(animal, ESPConfig.Colors.Animals, "Animals")
                end
            end
        end
    end

    local nightEnemies = Workspace:FindFirstChild("NightEnemies")
    if nightEnemies then
        for _, enemy in ipairs(nightEnemies:GetDescendants()) do
            if enemy:IsA("Model") then
                CreateESP(enemy, ESPConfig.Colors.NightEnemies, "NightEnemies")
            end
        end
    end

    local destroyedHouse = Workspace:FindFirstChild("RandomBuildings") and Workspace.RandomBuildings:FindFirstChild("DestroyedHouse")
    local zombiePart = destroyedHouse and destroyedHouse:FindFirstChild("StandaloneZombiePart")
    local zombies = zombiePart and zombiePart:FindFirstChild("Zombies")
    if zombies then
        for _, zombie in ipairs(zombies:GetChildren()) do
            if zombie:IsA("Model") then
                CreateESP(zombie, ESPConfig.Colors.Zombies, "Zombies")
            end
        end
    end
end

local function UpdateLinesAndDistance()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for obj, handles in pairs(ESPHandles) do
        if obj and obj.PrimaryPart and handles.Line and handles.DistanceLabel then
            local targetPos = obj.PrimaryPart.Position
            local playerPos = rootPart.Position
            local distance = (playerPos - targetPos).Magnitude

            handles.DistanceLabel.Text = math.floor(distance) .. " Met"

            local direction = (targetPos - playerPos).Unit
            local length = distance
            handles.Line.CFrame = CFrame.new(playerPos + direction * (length / 2), playerPos)
            handles.Line.Height = length
        end
    end
end

local function AutoUpdateESP()
    while ESPEnabled do
        UpdateESP()
        UpdateLinesAndDistance()
        task.wait(0.5)
    end
end

local CoreGui = game:GetService("CoreGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.Parent = CoreGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 30)
toggleButton.Position = UDim2.new(0.5, -50, 0.95, -40)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "ESP: OFF"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.Draggable = true -- Bật tính năng kéo thả
toggleButton.Active = true -- Đảm bảo nút có thể tương tác
toggleButton.Parent = screenGui

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1
uiStroke.Color = Color3.fromRGB(100, 100, 100)
uiStroke.Parent = toggleButton

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 5)
uiCorner.Parent = toggleButton

toggleButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    toggleButton.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    toggleButton.BackgroundColor3 = ESPEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(30, 30, 30)
    
    if ESPEnabled then
        UpdateESP()
        coroutine.wrap(AutoUpdateESP)()
    else
        ClearESP()
    end
end)

Workspace.DescendantAdded:Connect(function(descendant)
    if ESPEnabled and descendant:IsA("Model") then
        task.wait(0.1) -- Đợi một chút để đảm bảo đối tượng được khởi tạo hoàn toàn
        UpdateESP()
    end
end)

Players.PlayerRemoving:Connect(function()
    ClearESP()
    screenGui:Destroy()
end)

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        UpdateLinesAndDistance()
    end
end)
