-- LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--================ GUI =================--

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- GUI AIM (to)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,120,0,120)
frame.Position = UDim2.new(0,20,0,200)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Parent = gui

local lockButton = Instance.new("TextButton")
lockButton.Size = UDim2.new(1,0,1,0)
lockButton.Text = "OFF"
lockButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
lockButton.TextColor3 = Color3.new(1,1,1)
lockButton.TextScaled = true
lockButton.BorderSizePixel = 0
lockButton.Parent = frame

-- GUI MOVE (nhỏ – kéo tự do)
local moveGui = Instance.new("Frame")
moveGui.Size = UDim2.new(0,40,0,40)
moveGui.Position = UDim2.new(0,200,0,200)
moveGui.BackgroundColor3 = Color3.fromRGB(60,60,60)
moveGui.BorderSizePixel = 0
moveGui.Parent = gui

local moveToggle = Instance.new("TextButton")
moveToggle.Size = UDim2.new(1,0,1,0)
moveToggle.Text = "M"
moveToggle.BackgroundTransparency = 1
moveToggle.TextColor3 = Color3.new(1,1,1)
moveToggle.TextScaled = true
moveToggle.Parent = moveGui

--================ DRAG MOVE GUI (nhỏ) =================--

local draggingMove = false
local dragStartMove, startPosMove

moveGui.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingMove = true
		dragStartMove = input.Position
		startPosMove = moveGui.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				draggingMove = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if draggingMove and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStartMove
		moveGui.Position = UDim2.new(
			startPosMove.X.Scale,
			startPosMove.X.Offset + delta.X,
			startPosMove.Y.Scale,
			startPosMove.Y.Offset + delta.Y
		)
	end
end)

--================ DRAG AIM GUI =================--

local movable = true
local draggingAim = false
local dragStartAim, startPosAim

frame.InputBegan:Connect(function(input)
	if not movable then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingAim = true
		dragStartAim = input.Position
		startPosAim = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				draggingAim = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if draggingAim and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStartAim
		frame.Position = UDim2.new(
			startPosAim.X.Scale,
			startPosAim.X.Offset + delta.X,
			startPosAim.Y.Scale,
			startPosAim.Y.Offset + delta.Y
		)
	end
end)

moveToggle.MouseButton1Click:Connect(function()
	movable = not movable
	moveToggle.Text = movable and "M" or "L"
end)

--================ LOCK SYSTEM =================--

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
		if plr ~= player
		and plr.Character
		and plr.Character:FindFirstChild("HumanoidRootPart")
		and plr.Character:FindFirstChild("Humanoid")
		and plr.Character.Humanoid.Health > 0 then

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
	if not locking then return end

	local myChar = player.Character
	if not myChar then return end
	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	-- target chết / out → đổi nearest
	if not target
	or not target.Character
	or not target.Character:FindFirstChild("HumanoidRootPart")
	or target.Character:FindFirstChild("Humanoid").Health <= 0 then

		target = getNearestPlayer()
	end

	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local targetRoot = target.Character.HumanoidRootPart

		camera.CameraType = Enum.CameraType.Scriptable

		local dir = (targetRoot.Position - myRoot.Position).Unit
		local camPos =
			myRoot.Position
			- (dir * distanceOffset)
			+ Vector3.new(0,heightOffset,0)

		camera.CFrame = CFrame.new(camPos, targetRoot.Position)
	end
end)
