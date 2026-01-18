local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local running = true

local CONFIG = {
	FPS_LIMIT = 60,
	ULTRA_FPS = 30,
	EXTREME_FPS = 20,
	CHECK_INTERVAL = 0.5
}

local STATE = "NORMAL"
local connections = {}
local cache = {
	parts = {},
	effects = {},
	terrain = workspace:FindFirstChildOfClass("Terrain")
}

-- Cache existing objects
local function buildCache()
	for _,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			table.insert(cache.parts, v)
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail")
			or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Beam") then
			table.insert(cache.effects, v)
		end
	end
end

buildCache()

-- Listen new objects
connections.desc = workspace.DescendantAdded:Connect(function(v)
	if v:IsA("BasePart") then
		table.insert(cache.parts, v)
	elseif v:IsA("ParticleEmitter") or v:IsA("Trail")
		or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Beam") then
		table.insert(cache.effects, v)
	end
end)

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FPSStabilizer"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,260,0,300)
main.Position = UDim2.new(0,15,0.5,-150)
main.BackgroundColor3 = Color3.fromRGB(28,28,28)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "FPS STABILIZER"
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
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 16
fpsLabel.TextColor3 = Color3.new(1,1,1)
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

-- Optimization
local function applyUltra()
	settings().Rendering.QualityLevel = 1
	Lighting.GlobalShadows = false
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
end

local function applyExtreme()
	applyUltra()
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
end

-- FPS Counter
local frames = 0
local fps = 60
local last = tick()

connections.render = RunService.RenderStepped:Connect(function()
	frames += 1
	local now = tick()
	if now - last >= 1 then
		fps = frames
		frames = 0
		last = now
	end
end)

-- Controller Loop
task.spawn(function()
	while running do
		local newState

		if fps <= CONFIG.EXTREME_FPS then
			newState = "EXTREME"
		elseif fps <= CONFIG.ULTRA_FPS then
			newState = "ULTRA"
		else
			newState = "NORMAL"
		end

		if newState ~= STATE then
			STATE = newState
			if STATE == "EXTREME" then
				applyExtreme()
				statusLabel.Text = "Heavy optimization"
			elseif STATE == "ULTRA" then
				applyUltra()
				statusLabel.Text = "Optimizing"
			else
				statusLabel.Text = "Stable"
			end
		end

		fpsLabel.Text = "FPS: " .. fps
		modeLabel.Text = "Mode: " .. STATE

		if CONFIG.FPS_LIMIT > 0 and fps > CONFIG.FPS_LIMIT then
			task.wait(1 / CONFIG.FPS_LIMIT)
		end

		task.wait(CONFIG.CHECK_INTERVAL)
	end
end)

-- Cleanup
close.MouseButton1Click:Connect(function()
	running = false
	for _,c in pairs(connections) do
		pcall(function() c:Disconnect() end)
	end
	gui:Destroy()
end)
