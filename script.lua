--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()

--// SETTINGS
local speed = 3
local distance = 6
local orbiting = false
local angle = 0
local target = nil

--// GUI MINI
local gui = Instance.new("ScreenGui", game.CoreGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 150, 0, 130)
frame.Position = UDim2.new(0, 10, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0

-- PLAYER BTN
local playerBtn = Instance.new("TextButton", frame)
playerBtn.Size = UDim2.new(1, -10, 0, 25)
playerBtn.Position = UDim2.new(0, 5, 0, 5)
playerBtn.Text = "Player"
playerBtn.TextScaled = true

-- DROPDOWN
local dropdown = Instance.new("Frame", frame)
dropdown.Size = UDim2.new(1, -10, 0, 0)
dropdown.Position = UDim2.new(0, 5, 0, 30)
dropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
dropdown.ClipsDescendants = true

local open = false

playerBtn.MouseButton1Click:Connect(function()
	open = not open
	dropdown.Size = open and UDim2.new(1,-10,0,60) or UDim2.new(1,-10,0,0)
end)

local function refreshPlayers()
	dropdown:ClearAllChildren()
	local y = 0
	
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= lp then
			local btn = Instance.new("TextButton", dropdown)
			btn.Size = UDim2.new(1,0,0,20)
			btn.Position = UDim2.new(0,0,0,y)
			btn.Text = plr.Name
			btn.TextScaled = true
			
			btn.MouseButton1Click:Connect(function()
				target = plr
				playerBtn.Text = plr.Name
				open = false
				dropdown.Size = UDim2.new(1,-10,0,0)
			end)
			
			y += 20
		end
	end
end

refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

-- SPEED
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, -10, 0, 20)
speedBox.Position = UDim2.new(0, 5, 0, 95)
speedBox.Text = "S:3"
speedBox.TextScaled = true

-- DISTANCE
local distBox = Instance.new("TextBox", frame)
distBox.Size = UDim2.new(1, -10, 0, 20)
distBox.Position = UDim2.new(0, 5, 0, 70)
distBox.Text = "D:6"
distBox.TextScaled = true

-- TOGGLE
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -10, 0, 25)
toggle.Position = UDim2.new(0, 5, 0, 115)
toggle.Text = "OFF"
toggle.TextScaled = true

toggle.MouseButton1Click:Connect(function()
	orbiting = not orbiting
	toggle.Text = orbiting and "ON" or "OFF"
end)

-- UPDATE
speedBox.FocusLost:Connect(function()
	local v = tonumber(speedBox.Text:match("%d+"))
	if v then speed = v end
end)

distBox.FocusLost:Connect(function()
	local v = tonumber(distBox.Text:match("%d+"))
	if v then distance = v end
end)

-- LOOP
RunService.RenderStepped:Connect(function(dt)
	if orbiting and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		
		local myHRP = character:FindFirstChild("HumanoidRootPart")
		local targetHRP = target.Character.HumanoidRootPart
		
		if myHRP then
			angle += speed * dt
			
			local offset = Vector3.new(
				math.cos(angle)*distance,
				0,
				math.sin(angle)*distance
			)
			
			myHRP.CFrame = CFrame.new(targetHRP.Position + offset, targetHRP.Position)
		end
	end
end)