getgenv().AutoCollect = true
getgenv().AutoHop = true

-- شاشة المعلومات
local gui = Instance.new("ScreenGui", game.CoreGui)

local infoLabel = Instance.new("TextLabel", gui)
infoLabel.Size = UDim2.new(0, 400, 0, 100)
infoLabel.Position = UDim2.new(0, 10, 0, 10)
infoLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.SourceSansBold
infoLabel.Text = "Waiting..."

-- زر تفعيل AutoCollect
local btn1 = Instance.new("TextButton", gui)
btn1.Size = UDim2.new(0, 200, 0, 40)
btn1.Position = UDim2.new(0, 10, 0, 120)
btn1.Text = "Auto Collect: ON"
btn1.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
btn1.Font = Enum.Font.SourceSansBold
btn1.TextSize = 18
btn1.MouseButton1Click:Connect(function()
	getgenv().AutoCollect = not getgenv().AutoCollect
	btn1.Text = "Auto Collect: " .. (getgenv().AutoCollect and "ON" or "OFF")
end)

-- زر تفعيل AutoHop
local btn2 = Instance.new("TextButton", gui)
btn2.Size = UDim2.new(0, 200, 0, 40)
btn2.Position = UDim2.new(0, 10, 0, 170)
btn2.Text = "Auto Hop: ON"
btn2.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
btn2.Font = Enum.Font.SourceSansBold
btn2.TextSize = 18
btn2.MouseButton1Click:Connect(function()
	getgenv().AutoHop = not getgenv().AutoHop
	btn2.Text = "Auto Hop: " .. (getgenv().AutoHop and "ON" or "OFF")
end)

-- ESP
local function createESP(obj, text)
	local BillboardGui = Instance.new("BillboardGui")
	local NameLabel = Instance.new("TextLabel")
	BillboardGui.Name = "FruitESP"
	BillboardGui.Parent = obj
	BillboardGui.Adornee = obj
	BillboardGui.Size = UDim2.new(0, 100, 0, 40)
	BillboardGui.AlwaysOnTop = true
	NameLabel.Parent = BillboardGui
	NameLabel.Size = UDim2.new(1, 0, 1, 0)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Text = text
	NameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	NameLabel.TextScaled = true
	NameLabel.Font = Enum.Font.SourceSansBold
end

-- تحديث المعلومات
function updateInfo()
	local plr = game.Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local fruitList = {}
	for _, obj in pairs(game.Workspace:GetDescendants()) do
		if obj:IsA("Tool") and string.find(obj.Name:lower(), "fruit") then
			local dist = hrp and math.floor((hrp.Position - obj.Position).Magnitude) or 0
			table.insert(fruitList, obj.Name .. " (" .. dist .. "m)")
			if not obj:FindFirstChild("FruitESP") then
				createESP(obj, obj.Name .. " (" .. dist .. "m)")
			else
				obj.FruitESP.TextLabel.Text = obj.Name .. " (" .. dist .. "m)"
			end
		end
	end
	if #fruitList > 0 then
		infoLabel.Text = "Fruits: " .. #fruitList .. "\n" .. table.concat(fruitList, ", ")
	else
		infoLabel.Text = "No fruits found"
	end
end

-- السيرفر هوب
function serverHop()
	local HttpService = game:GetService("HttpService")
	local TeleportService = game:GetService("TeleportService")
	local PlaceId = game.PlaceId
	local found = false
	local cursor = ""
	repeat
		local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?limit=100&sortOrder=Asc&cursor=" .. cursor)
		local data = HttpService:JSONDecode(req)
		for _, v in pairs(data.data) do
			if v.playing < v.maxPlayers and v.id ~= game.JobId then
				TeleportService:TeleportToPlaceInstance(PlaceId, v.id, game.Players.LocalPlayer)
				found = true
				break
			end
		end
		cursor = data.nextPageCursor or ""
	until found or cursor == ""
end

-- المهام الرئيسية
spawn(function()
	while wait(5) do
		updateInfo()
		local found = false
		for _, obj in pairs(game.Workspace:GetDescendants()) do
			if obj:IsA("Tool") and string.find(obj.Name:lower(), "fruit") then
				found = true
				if getgenv().AutoCollect then
					game.Players.LocalPlayer.Character.Humanoid:EquipTool(obj)
					wait(1)
					game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", obj.Name)
				end
				break
			end
		end
		if not found and getgenv().AutoHop then
			wait(1)
			serverHop()
		end
	end
end)

-- إعادة التشغيل تلقائياً بعد السيرفر هوب
local ScriptURL = "https://raw.githubusercontent.com/2tt7t/bloxfruit-scripts/main/autofruit.lua"
local queue_on_teleport = queue_on_teleport or syn and syn.queue_on_teleport or queueonteleport or fluxus and fluxus.queue_on_teleport
if queue_on_teleport then
	queue_on_teleport('loadstring(game:HttpGet("'..ScriptURL..'"))()')
end
