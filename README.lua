```lua
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

-- GUI AIM (chính) 120x60
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,120,0,60)
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

-- GUI MOVE (nhỏ) 60x60
local moveGui = Instance.new("Frame")
moveGui.Size = UDim2.new(0,60,0,60)
moveGui.Position = UDim2.new(0,200,0,200)
moveGui.BackgroundColor3 = Color3.fromRGB(60,60,60)
moveGui.BorderSizePixel = 0
moveGui.Parent = gui

local moveToggle = Instance.new("TextButton")
moveToggle.Size = UDim2.new(1,0,1,0)
moveToggle.Text = "Unlock"
moveToggle.BackgroundTransparency = 1
moveToggle.TextColor3 = Color3.new(1,1,1)
moveToggle.TextScaled = true
moveToggle.Parent = moveGui

--================ DRAG FUNCTION =================--

local function makeDrag(guiObject, canDrag)

    local dragging = false
    local dragStart
    local startPos

    guiObject.InputBegan:Connect(function(input)

        if canDrag and not canDrag() then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then

            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--================ DRAG APPLY =================--

local movable = true

makeDrag(frame, function()
    return movable
end)

makeDrag(moveGui, function()
    return true
end)

moveToggle.MouseButton1Click:Connect(function()
    movable = not movable
    moveToggle.Text = movable and "Unlock" or "Lock"
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
```
