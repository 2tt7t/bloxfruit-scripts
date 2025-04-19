local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========== CONFIG ==========
local AutoHop = true
local AutoCollect = true

-- ========== UI ==========
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FruitFarmGui"

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 200, 0, 170)
mainFrame.Position = UDim2.new(0, 10, 0, 200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.BorderSizePixel = 1

local function createButton(txt, posY, callback)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0, 180, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.MouseButton1Click:Connect(callback)
end

createButton("البحر الأول", 10, function()
    TeleportService:Teleport(2753915549) -- First Sea
end)

createButton("البحر الثاني", 50, function()
    TeleportService:Teleport(4442272183) -- Second Sea
end)

createButton("البحر الثالث", 90, function()
    TeleportService:Teleport(7449423635) -- Third Sea
end)

-- ========== TELEPORT TO FRUIT ==========
local function flyTo(pos)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for i = 1, 25 do
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(pos), 0.3)
        wait(0.01)
    end
end

-- ========== COLLECT ==========
local function collectFruits()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") and string.lower(obj.Name):find("fruit") then
            flyTo(obj.Handle.Position)
            LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(obj)
            wait(0.5)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", obj.Name)
            wait(1)
        end
    end
end

-- ========== SERVER HOP ==========
local function serverHop()
    local pid = game.PlaceId
    local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. pid .. "/servers/Public?limit=100")).data
    for _, s in pairs(data) do
        if s.id ~= game.JobId and s.playing < s.maxPlayers then
            TeleportService:TeleportToPlaceInstance(pid, s.id, LocalPlayer)
            break
        end
    end
end

-- ========== MAIN LOOP ==========
task.spawn(function()
    while wait(5) do
        pcall(function()
            if AutoCollect then
                collectFruits()
            end

            local found = false
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Tool") and string.lower(obj.Name):find("fruit") then
                    found = true
                    break
                end
            end

            if not found and AutoHop then
                serverHop()
            end
        end)
    end
end)

-- ========== AUTO RELOAD ==========
local ScriptURL = "https://raw.githubusercontent.com/2tt7t/bloxfruit-scripts/main/autofruit.lua"
local queue_on_teleport = queue_on_teleport or syn and syn.queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queue_on_teleport then
    queue_on_teleport('loadstring(game:HttpGet("' .. ScriptURL .. '"))()')
end

print("سكربت الفواكه شغال يالوحش")