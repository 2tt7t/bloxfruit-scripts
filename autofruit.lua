local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- إعدادات السكربت
local settings = {
    AutoCollect = true,   -- تفعيل تجميع الفواكه
    AutoHop = true,       -- تفعيل السيرفر هوب إذا ما فيه فواكه
    AntiAFK = true,       -- منع الطرد من اللعبة
    AntiDrown = true      -- حماية من الغرق
}

-- منع الطرد بسبب الـ AFK
if settings.AntiAFK then
    task.spawn(function()
        while wait(60) do
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "Space", false, game)
        end
    end)
end

-- حماية من الموت في الماء
if settings.AntiDrown then
    task.spawn(function()
        while wait(1) do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if char.HumanoidRootPart.Position.Y < -10 then
                    char.HumanoidRootPart.Velocity = Vector3.new(0, 100, 0)
                end
            end
        end
    end)
end
-- تنبيه عند وجود فاكهة
local function notify(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "فاكهة!",
        Text = text,
        Duration = 4
    })
end

-- طيران سريع إلى الفاكهة
local function flyTo(position)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for i = 1, 30 do
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(position), 0.3)
        wait(0.01)
    end
end

-- تجميع الفواكه وتخزينها في الشنطة
local function collectFruits()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") and string.lower(obj.Name):find("fruit") then
            local dist = (hrp.Position - obj.Handle.Position).Magnitude
            notify(obj.Name .. " (" .. math.floor(dist) .. "m)")

            flyTo(obj.Handle.Position)

            -- تجهيز واستلام الأداة
            LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(obj)
            wait(0.5)

            -- تخزينها في الشنطة
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", obj.Name)
            wait(1)
        end
    end
end
-- الانتقال إلى سيرفر جديد
local function serverHop()
    local pid = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. pid .. "/servers/Public?limit=100&sortOrder=Asc"
    local data = HttpService:JSONDecode(game:HttpGet(url)).data

    for _, server in pairs(data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(pid, server.id, LocalPlayer)
            break
        end
    end
end

-- التكرار كل 5 ثواني
task.spawn(function()
    while wait(5) do
        pcall(function()
            collectFruits()

            -- نشوف إذا ما فيه ولا فاكهة
            local found = false
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Tool") and string.lower(obj.Name):find("fruit") then
                    found = true
                    break
                end
            end

            -- إذا ما فيه فواكه يروح سيرفر ثاني
            if not found and settings.AutoHop then
                serverHop()
            end
        end)
    end
end)
-- رابط السكربت في GitHub (بدله برابطك إذا غيرت)
local ScriptURL = "https://raw.githubusercontent.com/2tt7t/bloxfruit-scripts/main/autofruit.lua"

-- تشغيل تلقائي بعد السيرفر هوب
local queue_on_teleport = queue_on_teleport or syn and syn.queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queue_on_teleport then
    queue_on_teleport('loadstring(game:HttpGet("' .. ScriptURL .. '"))()')
end

-- تأكيد
print("سكربت ثامر اشتغل بنجاح")