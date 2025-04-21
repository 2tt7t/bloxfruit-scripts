-- Legendary Sword Dealer Detector by Red
-- يظهر تنبيه على الشاشة إذا التاجر موجود في السيرفر

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function checkDealer()
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") then
            local head = npc:FindFirstChild("Head")
            if head:FindFirstChild("Overhead") then
                local title = head.Overhead:FindFirstChildOfClass("BillboardGui")
                if title and title:FindFirstChild("TextLabel") then
                    local text = title.TextLabel.Text:lower()
                    if text:find("legendary sword dealer") then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- واجهة عرض الرسالة
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Label = Instance.new("TextLabel", ScreenGui)
Label.Size = UDim2.new(0, 400, 0, 50)
Label.Position = UDim2.new(0.5, -200, 0, 50)
Label.TextSize = 24
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.BackgroundTransparency = 0.5
Label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Label.Visible = false
Label.Text = "Legendary Sword Dealer is HERE!"

-- تحديث كل ثانية
RunService.RenderStepped:Connect(function()
    local found = checkDealer()
    Label.Visible = found
end)