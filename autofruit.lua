local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- ملف الحفظ
local configFile = "thamer_config.json"
local settings = {
    AutoCollect = true,
    AutoHop = false,
    MaxPerformance = true,
    AntiAFK = true,
    AntiDrown = true
}

if isfile and readfile and isfile(configFile) then
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(configFile))
    end)
    if success and typeof(data) == "table" then
        for k, v in pairs(data) do
            settings[k] = v
        end
    end
end

local function saveSettings()
    if writefile then
        writefile(configFile, HttpService:JSONEncode(settings))
    end
end

if settings.AntiAFK then
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Space", false, game)
    task.spawn(function()
        while true do
            wait(170)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "Space", false, game)
        end
    end)
end

if settings.MaxPerformance then
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 end
        if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
    end
end

if settings.AntiDrown then
    task.spawn(function()
        while true do
            wait(1)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if char.HumanoidRootPart.Position.Y < -10 then
                    char.HumanoidRootPart.Velocity = Vector3.new(0, 100, 0)
                end
            end
        end
    end)
end

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ThamerFruitGui"

local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 80, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 200)
toggleButton.Text = "فتح"
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0, 10, 0, 240)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.BorderSizePixel = 1
mainFrame.Visible = false

local function createToggle(name, default, pos, callback)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0, 280, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = name .. ": " .. (default and "ON" or "OFF")
    btn.MouseButton1Click:Connect(function()
        settings[name] = not settings[name]
        btn.Text = name .. ": " .. (settings[name] and "ON" or "OFF")
        saveSettings()
        if callback then callback(settings[name]) end
    end)
end

createToggle("AutoCollect", settings.AutoCollect, 10)
createToggle("AutoHop", settings.AutoHop, 50)
createToggle("MaxPerformance", settings.MaxPerformance, 90)
createToggle("AntiAFK", settings.AntiAFK, 130)
createToggle("AntiDrown", settings.AntiDrown, 170)

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    toggleButton.Text = mainFrame.Visible and "إغلاق" or "فتح"
end)

local function notify(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "تنبيه فاكهة",
        Text = text,
        Duration = 5
    })
end

local function createESP(obj, label)
    local gui = Instance.new("BillboardGui", obj)
    gui.Name = "FruitESP"
    gui.Size = UDim2.new(0, 100, 0, 40)
    gui.AlwaysOnTop = true
    gui.Adornee = obj
    local txt = Instance.new("TextLabel", gui)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = label
    txt.TextColor3 = Color3.fromRGB(255, 0, 0)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
end

local function flyTo(pos)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for i = 1, 20 do
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(pos), 0.25)
        wait(0.01)
    end
end

local function collectFruits()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") and string.lower(obj.Name):find("fruit") then
            local dist = (hrp.Position - obj.Handle.Position).Magnitude
            notify(obj.Name .. " (" .. math.floor(dist) .. "m)")
            if not obj:FindFirstChild("FruitESP") then
                createESP(obj, obj.Name .. " (" .. math.floor(dist) .. "m)")
            end
            if settings.AutoCollect then
                flyTo(obj.Handle.Position)
                LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(obj)
                wait(1)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", obj.Name)
                wait(1)
            end
        end
    end
end

local function serverHop()
    local pid = game.PlaceId
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. pid .. "/servers/Public?limit=100&sortOrder=Asc")).data
    for _, v in pairs(servers) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(pid, v.id, LocalPlayer)
            break
        end
    end
end

task.spawn(function()
    while wait(5) do
        pcall(function()
            collectFruits()
            local fruits = workspace:GetDescendants()
            local found = false
            for _, obj in pairs(fruits) do
                if obj:IsA("Tool") and string.lower(obj.Name):find("fruit") then
                    found = true break
                end
            end
            if not found and settings.AutoHop then
                serverHop()
            end
        end)
    end
end)

local ScriptURL = "https://raw.githubusercontent.com/yourusername/yourrepo/main/autofruit.lua"
local queue_on_teleport = queue_on_teleport or syn and syn.queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queue_on_teleport then
    queue_on_teleport('loadstring(game:HttpGet("'..ScriptURL..'"))()')
end
