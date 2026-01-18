local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local running = true

local config = {
	FPSLimit = 45,
	ExtremeFPS = 20,
	UltraFPS = 30,
	AutoMode = true
}

local cache = {
	parts = {},
	effects = {},
	terrain = workspace:FindFirstChildOfClass("Terrain")
}

for _,v in ipairs(workspace:GetDescendants()) do
	if v:IsA("BasePart") then
		table.insert(cache.parts, v)
	elseif v:IsA("ParticleEmitter") or v:IsA("Trail")
		or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Beam") then
		table.insert(cache.effects, v)
	end
end

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FPSStabilizer"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,260,0,310)
main.Position = UDim2.new(0,15,0.5,-155)
main.BackgroundColor3 = Color3.fromRGB(28,28,28)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "FPS STABILIZER PRO"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(40,40,40)

local close = Instance.new("TextButton", title)
close.Size = UDim2.new(0,40,1,0)
close.Position = UDim2.new(1,-40,0,0)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255,80,80)
close.BackgroundTransparency = 1

local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,0,0,45)
content.Size = UDim2.new(1,0,1,-45)
content.BackgroundTransparency = 1

local fpsLabel = Instance.new("TextLabel", content)
fpsLabel.Size = UDim2.new(1,-20,0,30)
fpsLabel.Position = UDim2.new(0,10,0,0)
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 16
fpsLabel.BackgroundTransparency = 1

local modeLabel = Instance.new("TextLabel", content)
modeLabel.Size = UDim2.new(1,-20,0,30)
modeLabel.Position = UDim2.new(0,10,0,35)
modeLabel.Font = Enum.Font.Gotham
modeLabel.TextSize = 14
modeLabel.TextColor3 = Color3.fromRGB(180,180,180)
modeLabel.BackgroundTransparency = 1

local statusLabel = Instance.new("TextLabel", content)
statusLabel.Size = UDim2.new(1,-20,0,30)
statusLabel.Position = UDim2.new(0,10,0,70)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.TextColor3 = Color3.fromRGB(150,150,150)
statusLabel.BackgroundTransparency = 1

local function optimizeUltra()
	pcall(function()
		settings().Rendering.QualityLevel = 1
		Lighting.GlobalShadows = false
		Lighting.Brightness = 1
		Lighting.FogEnd = 1e6

		if cache.terrain then
			cache.terrain.WaterWaveSize = 0
			cache.terrain.WaterWaveSpeed = 0
			cache.terrain.WaterTransparency = 1
		end

		for _,v in ipairs(cache.parts) do
			v.Material = Enum.Material.Plastic
			v.CastShadow = false
		end

		for _,v in ipairs(cache.effects) do
			v.Enabled = false
		end
	end)
end

local function optimizeExtreme()
	optimizeUltra()
	pcall(function()
		Lighting.EnvironmentDiffuseScale = 0
		Lighting.EnvironmentSpecularScale = 0
	end)
end

local frames = 0
local last = tick()
local fps = 60

RunService.RenderStepped:Connect(function()
	frames += 1
	local now = tick()
	if now - last >= 1 then
		fps = frames
		frames = 0
		last = now
	end
end)

task.spawn(function()
	while running do
		fpsLabel.Text = "FPS: " .. fps

		if fps < config.ExtremeFPS then
			modeLabel.Text = "Mode: EXTREME"
			statusLabel.Text = "Heavy optimization"
			optimizeExtreme()
		elseif fps < config.UltraFPS then
			modeLabel.Text = "Mode: ULTRA"
			statusLabel.Text = "Optimizing"
			optimizeUltra()
		else
			modeLabel.Text = "Mode: NORMAL"
			statusLabel.Text = "Stable"
		end

		if config.FPSLimit > 0 then
			RunService:Set3dRenderingEnabled(false)
			task.wait(1 / config.FPSLimit)
			RunService:Set3dRenderingEnabled(true)
		end

		task.wait(0.4)
	end
end)

close.MouseButton1Click:Connect(function()
	running = false
	gui:Destroy()
end)	Lighting.Brightness = 1
	Lighting.FogEnd = 1e6

	local t = workspace:FindFirstChildOfClass("Terrain")
	if t then
		t.WaterWaveSize = 0
		t.WaterWaveSpeed = 0
		t.WaterTransparency = 1
	end

	for _,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Material = Enum.Material.Plastic
			v.Reflectance = 0
			v.CastShadow = false
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Beam") then
			v.Enabled = false
		end
	end
end

local function extreme()
	ultra()
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
end

local last = tick()
local buffer = {}

local function fps()
	local now = tick()
	local f = 1 / (now - last)
	last = now
	return f
end

task.spawn(function()
	while true do
		local f = fps()
		table.insert(buffer, f)
		if #buffer > 15 then
			table.remove(buffer, 1)
		end

		local avg = 0
		for _,v in ipairs(buffer) do
			avg += v
		end
		avg /= #buffer

		fpsLabel.Text = "FPS: " .. math.floor(avg)

		if avg < 20 then
			modeLabel.Text = "Mode: EXTREME"
			statusLabel.Text = "Status: Heavy optimization"
			extreme()
		elseif avg < 30 then
			modeLabel.Text = "Mode: ULTRA"
			statusLabel.Text = "Status: Optimizing"
			ultra()
		else
			modeLabel.Text = "Mode: NORMAL"
			statusLabel.Text = "Status: Stable"
		end

		task.wait(0.4)
	end
end)

local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	content.Visible = not minimized
	main.Size = minimized and UDim2.new(0,260,0,40) or UDim2.new(0,260,0,300)
	minimize.Text = minimized and "+" or "-"
end)
