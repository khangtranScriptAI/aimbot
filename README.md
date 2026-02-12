-- LocalScript (đặt trong StarterPlayerScripts hoặc StarterGui)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LockOnGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,120,0,40)
button.Position = UDim2.new(0,20,0,200)
button.Text = "Lock: OFF"
button.BackgroundColor3 = Color3.fromRGB(40,40,40)
button.TextColor3 = Color3.new(1,1,1)
button.Parent = screenGui

-- ===== LOCK SYSTEM =====
local locking = false
local target = nil

-- Tìm player gần nhất
local function getNearestPlayer()
local character = player.Character
if not character or not character:FindFirstChild("HumanoidRootPart") then
return nil
end

```
local myRoot = character.HumanoidRootPart
local nearest = nil
local shortestDistance = math.huge

for _, plr in pairs(Players:GetPlayers()) do
	if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		
		local root = plr.Character.HumanoidRootPart
		local distance = (root.Position - myRoot.Position).Magnitude
		
		if distance < shortestDistance then
			shortestDistance = distance
			nearest = plr
		end
	end
end

return nearest
```

end

-- Toggle nút
button.MouseButton1Click:Connect(function()
locking = not locking

```
if locking then
	target = getNearestPlayer()
	button.Text = "Lock: ON"
else
	target = nil
	button.Text = "Lock: OFF"
end
```

end)

-- Camera aim vào body
RunService.RenderStepped:Connect(function()
if locking and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then

```
	local targetRoot = target.Character.HumanoidRootPart
	
	camera.CFrame = CFrame.new(
		camera.CFrame.Position,
		targetRoot.Position
	)
	
else
	target = nil
end
```

end)
