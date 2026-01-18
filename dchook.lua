local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer

-- ================== CONFIG ==================
local webhook = ""
local sent = false
local startTime = os.time()
local lastHeartbeat = os.clock()

-- ================== GUI ==================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.4, 0.3)
frame.Position = UDim2.fromScale(0.3, 0.3)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.2)
title.Text = "Webhook Monitor"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local input = Instance.new("TextBox", frame)
input.Position = UDim2.fromScale(0.05,0.3)
input.Size = UDim2.fromScale(0.9,0.25)
input.PlaceholderText = "Paste Discord Webhook URL"
input.TextScaled = true
input.BackgroundColor3 = Color3.fromRGB(40,40,40)
input.TextColor3 = Color3.new(1,1,1)

local status = Instance.new("TextLabel", frame)
status.Position = UDim2.fromScale(0.05,0.6)
status.Size = UDim2.fromScale(0.9,0.15)
status.Text = "Status: Idle"
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1
status.TextScaled = true

local btn = Instance.new("TextButton", frame)
btn.Position = UDim2.fromScale(0.25,0.78)
btn.Size = UDim2.fromScale(0.5,0.18)
btn.Text = "TEST & START"
btn.TextScaled = true
btn.BackgroundColor3 = Color3.fromRGB(0,170,0)
btn.TextColor3 = Color3.new(1,1,1)

-- ================== WEBHOOK FUNCTION ==================
local function sendWebhook(title, color, msg)
	if webhook == "" then
		status.Text = "❌ Webhook kosong"
		return
	end

	local data = {
		username = "Roblox Monitor",
		embeds = {{
			title = title,
			color = color,
			description = msg,
			fields = {
				{ name = "User", value = player.Name, inline = true },
				{ name = "UserId", value = player.UserId, inline = true },
				{ name = "PlaceId", value = game.PlaceId, inline = false }
			},
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
		}}
	}

	local success, err = pcall(function()
		HttpService:PostAsync(
			webhook,
			HttpService:JSONEncode(data),
			Enum.HttpContentType.ApplicationJson,
			false,
			{
				["User-Agent"] = "RobloxWebhookClient/1.0"
			}
		)
	end)

	if success then
		status.Text = "✅ Webhook terkirim"
	else
		status.Text = "❌ Gagal: " .. tostring(err)
	end
end

-- ================== BUTTON ==================
btn.MouseButton1Click:Connect(function()
	webhook = input.Text
	sendWebhook("🟢 Script Started", 65280, "Webhook berhasil terhubung")
end)

-- ================== DISCONNECT DETECT ==================
GuiService.ErrorMessageChanged:Connect(function(msg)
	if sent then return end
	sent = true
	sendWebhook("🔴 Disconnected", 16711680, msg)
end)

player.AncestryChanged:Connect(function(_, parent)
	if not parent and not sent then
		sent = true
		sendWebhook("🔴 Player Left", 16711680, "Player left game")
	end
end)

RunService.Heartbeat:Connect(function()
	lastHeartbeat = os.clock()
end)
