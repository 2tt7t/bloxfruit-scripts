-- إعداد المتغيرات
getgenv().AutoFruit = false

-- GUI بسيطة بزر تفعيل
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.Text = "تجميع الفواكه: مفعل"
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22

-- زر التبديل
ToggleButton.MouseButton1Click:Connect(function()
    getgenv().AutoFruit = not getgenv().AutoFruit
    ToggleButton.Text = "تجميع الفواكه: " .. (getgenv().AutoFruit and "مفعل" or "مغلق")
end)

-- دالة السيرفر هوب
function serverHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId

    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=2&limit=100")).data

    for _, v in pairs(servers) do
        if v.playing < v.maxPlayers then
            TeleportService:TeleportToPlaceInstance(PlaceId, v.id, game.Players.LocalPlayer)
            break
        end
    end
end

-- دالة البحث والتجميع
spawn(function()
    while wait(5) do
        if getgenv().AutoFruit then
            local fruitFound = false
            for _, obj in pairs(game.Workspace:GetDescendants()) do
                if obj:IsA("Tool") and string.find(obj.Name:lower(), "fruit") then
                    fruitFound = true
                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(obj)
                    wait(1)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", obj.Name)
                    wait(2)
                    serverHop()
                    break
                end
            end
            if not fruitFound then
                serverHop()
            end
        end
    end
end)

-- السكربت يعيد تشغيل نفسه بعد السيرفر هوب
local ScriptURL = "https://raw.githubusercontent.com/2tt7t/bloxfruit-scripts/main/autofruit.lua"
local queue_on_teleport = queue_on_teleport or syn and syn.queue_on_teleport or queueonteleport or fluxus and fluxus.queue_on_teleport

if queue_on_teleport then
    queue_on_teleport('loadstring(game:HttpGet("'..ScriptURL..'"))()')
end
