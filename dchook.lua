local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local webhook = ""
local sent = false
local startTime = os.time()
local lastHeartbeat = os.clock()
local lastPing = 0

-- GUI
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "WebhookMonitor"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.35, 0.25)
frame.Position = UDim2.fromScale(0.33, 0.35)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1, 0.2)
title.BackgroundTransparency = 1
title.Text = "Webhook Monitor"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local input = Instance.new("TextBox", frame)
input.Position = UDim2.fromScale(0.05, 0.3)
input.Size = UDim2.fromScale(0.9, 0.25)
input.PlaceholderText = "Paste Discord Webhook URL"
input.Text = ""
input.ClearTextOnFocus = false
input.BackgroundColor3 = Color3.fromRGB(35,35,35)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextScaled = true

local saveBtn = Instance.new("TextButton", frame)
saveBtn.Position = UDim2.fromScale(0.1, 0.65)
saveBtn.Size = UDim2.fromScale(0.35, 0.22)
saveBtn.Text = "SAVE"
saveBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextScaled = true

local hideBtn = Instance.new("TextButton", frame)
hideBtn.Position = UDim2.fromScale(0.55, 0.65)
hideBtn.Size = UDim2.fromScale(0.35, 0.22)
hideBtn.Text = "HIDE"
hideBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
hideBtn.TextColor3 = Color3.new(1,1,1)
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextScaled = true

local function sendWebhook(title, color, reason)
	if webhook == "" then return end

	local data = {
		username = "Monitor",
		embeds = {{
			title = title,
			color = color,
			fields = {
				{ name = "User", value = player.Name, inline = true },
				{ name = "UserId", value = player.UserId, inline = true },
				{ name = "Status", value = reason, inline = false },
				{ name = "Ping", value = lastPing .. " ms", inline = true },
				{ name = "Uptime", value = os.time() - startTime .. "s", inline = true },
				{ name = "PlaceId", value = game.PlaceId, inline = false }
			},
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
		}}
	}

	pcall(function()
		HttpService:PostAsync(webhook, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
	end)
end

-- BUTTONS
saveBtn.MouseButton1Click:Connect(function()
	webhook = input.Text
	sendWebhook("🟢 Script Started", 65280, "Monitoring Active")
end)

hideBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

-- DETECT
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

task.spawn(function()
	while task.wait(3) do
		pcall(function()
			local stat = Stats.Network.ServerStatsItem["Data Ping"]
			lastPing = math.floor(stat:GetValue())
		end)
	end
end)
