```lua
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "LockOnGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- MAIN (CIRCLE)
local mainBtn = Instance.new("TextButton")
mainBtn.Size = UDim2.new(0,60,0,60)
mainBtn.Position = UDim2.new(0.5,-30,0.6,-30)
mainBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
mainBtn.Text = ""
mainBtn.Parent = gui

Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1,0)

-- TOGGLE (RECTANGLE)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,100,0,40)
toggleBtn.Position = UDim2.new(0.5,50,0.6,-20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
toggleBtn.Text = "Unlock"
toggleBtn.TextScaled = true
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Parent = gui

Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)

local mainCanDrag = true

local function dragify(Frame, canDrag)

    local dragToggle = false
    local dragStart
    local startPos

    local function updateInput(input)
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    Frame.InputBegan:Connect(function(input)

        if canDrag and not canDrag() then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragToggle = true
            dragStart = input.Position
            startPos = Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragToggle and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            updateInput(input)
        end
    end)
end

dragify(mainBtn, function()
    return mainCanDrag
end)

dragify(toggleBtn, function()
    return true
end)

toggleBtn.MouseButton1Click:Connect(function()

    mainCanDrag = not mainCanDrag

    if mainCanDrag then
        toggleBtn.Text = "Unlock"
    else
        toggleBtn.Text = "Lock"
    end

end)
```
