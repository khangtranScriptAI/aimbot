-- LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,120,0,120)
frame.Position = UDim2.new(0,20,0,200)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = gui

local lockButton = Instance.new("TextButton")
lockButton.Size = UDim2.new(1,0,1,0)
lockButton.Text = "OFF"
lockButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
lockButton.TextColor3 = Color3.new(1,1,1)
lockButton.TextScaled = true
lockButton.Parent = frame

local moveToggle = Instance.new("TextButton")
moveToggle.Size = UDim2.new(0.5,0,0.5,0)
moveToggle.Position = UDim2.new(1,-60,0,-60)
moveToggle.Text = "M"
moveToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
moveToggle.TextColor3 = Color3.new(1,1,1)
moveToggle.TextScaled = true
moveToggle.Parent = frame

-- Drag
local dragging = false
local dragInput
local dragStart
local startPos
local movable = true

local function update(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

frame.InputBegan:Connect(function(input)
	if not movable then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

moveToggle.MouseButton1Click:Connect(function()
	movable = not movable
	moveToggle.Text = movable and "M" or "L"
end)

-- Lock System
local locking = false
local target = nil
local heightOffset = 0
local distanceOffset = 10

local function getNearestPlayer()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	local myRoot = char.HumanoidRootPart
	local nearest
	local dist = math.huge

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local mag = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
			if mag < dist then
				dist = mag
				nearest = plr
			end
		end
	end

	return nearest
end

lockButton.MouseButton1Click:Connect(function()
	locking = not locking

	if locking then
		target = getNearestPlayer()
		lockButton.Text = "ON"

		local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if myRoot then
			local offset = camera.CFrame.Position - myRoot.Position
			heightOffset = offset.Y
			distanceOffset = Vector3.new(offset.X,0,offset.Z).Magnitude
		end

	else
		target = nil
		lockButton.Text = "OFF"
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = player.Character:WaitForChild("Humanoid")
	end
end)

RunService.RenderStepped:Connect(function()
	if locking and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		
		local myChar = player.Character
		if not myChar then return end
		
		local myRoot = myChar:FindFirstChild("HumanoidRootPart")
		local targetRoot = target.Character.HumanoidRootPart
		
		if myRoot then
			camera.CameraType = Enum.CameraType.Scriptable

			local dir = (targetRoot.Position - myRoot.Position).Unit
			local camPos = myRoot.Position
				- (dir * distanceOffset)
				+ Vector3.new(0,heightOffset,0)

			camera.CFrame = CFrame.new(
				camPos,
				targetRoot.Position
			)
		end
	end
end)
