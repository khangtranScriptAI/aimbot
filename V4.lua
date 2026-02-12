--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "LockOnGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--// =========================
-- NÚT TRÒN (MAIN)
-- =========================
local mainBtn = Instance.new("TextButton")
mainBtn.Size = UDim2.new(0,60,0,60)
mainBtn.Position = UDim2.new(0.5,-30,0.6,-30)
mainBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
mainBtn.Text = ""
mainBtn.Active = true
mainBtn.Draggable = false
mainBtn.Parent = gui

local cornerMain = Instance.new("UICorner")
cornerMain.CornerRadius = UDim.new(1,0)
cornerMain.Parent = mainBtn

--// =========================
-- NÚT CHỮ NHẬT (LOCK/UNLOCK)
-- =========================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,90,0,35)
toggleBtn.Position = UDim2.new(0,-110,0.5,-17)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
toggleBtn.Text = "Unlock"
toggleBtn.TextScaled = true
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Active = true
toggleBtn.Draggable = false
toggleBtn.Parent = mainBtn

local cornerToggle = Instance.new("UICorner")
cornerToggle.CornerRadius = UDim.new(0,8)
cornerToggle.Parent = toggleBtn

--// =========================
-- TRẠNG THÁI
-- =========================
local mainCanDrag = true

--// =========================
-- HÀM DRAG CHUẨN (PC + MOBILE)
-- =========================
local function makeDraggable(guiObject, canDragFunc)

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    guiObject.InputBegan:Connect(function(input)
        if canDragFunc and not canDragFunc() then return end

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

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

--// DRAG
makeDraggable(mainBtn, function()
    return mainCanDrag
end)

makeDraggable(toggleBtn, function()
    return true -- luôn drag được
end)

--// =========================
-- LOCK / UNLOCK
-- =========================
toggleBtn.MouseButton1Click:Connect(function()

    mainCanDrag = not mainCanDrag

    if mainCanDrag then
        toggleBtn.Text = "Unlock"
    else
        toggleBtn.Text = "Lock"
    end

end)
```
