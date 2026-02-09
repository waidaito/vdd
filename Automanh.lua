local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

local flySpeed = 450
local p1 = Vector3.new(146.96, 3.30, -136.51) 
local p2 = Vector3.new(2429.40, 3.35, -139.51)
local p3 = Vector3.new(2615.39, -2.70, 5.14)

local isMoving = false
local autoFarmEnabled = true

local function CheckTsunami()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local parts = workspace:GetPartBoundsInRadius(root.Position, 200)
    for _, part in ipairs(parts) do
        local n = part.Name
        if n:find("Hitbox") or n == "Tsunakimi" or n == "Wave" then return true end
    end
    return false
end

local function SetNoclip()
    local char = player.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end

local function GetNearbyNPCs()
    local found = {}
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return found end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("TextLabel") and (v.Text:lower():find("divine") or v.Text:lower():find("celestial") or v.Text:lower():find("secret")) then
            local model = v:FindFirstAncestorOfClass("Model")
            if model then
                local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
                if hrp then
                    if (hrp.Position - root.Position).Magnitude <= 700 then table.insert(found, hrp.Position) end
                end
            end
        end
        if #found >= 3 then break end
    end
    return found
end

local function SmoothFly(targetPos)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not isMoving or not hrp.Parent then return end
    workspace.Gravity = 0
    local noclipLoop = runService.Stepped:Connect(function()
        if char and hrp.Parent then SetNoclip() hrp.Velocity = Vector3.zero end
    end)
    while isMoving and hrp.Parent do
        local currentPos = hrp.Position
        local dist = (targetPos - currentPos).Magnitude
        if dist < 5 then break end
        local dt = runService.Heartbeat:Wait()
        local direction = (targetPos - currentPos).Unit
        hrp.CFrame = CFrame.new(currentPos + (direction * (flySpeed * dt)), targetPos)
    end
    if noclipLoop then noclipLoop:Disconnect() end
    if hrp and hrp.Parent then hrp.Velocity = Vector3.zero hrp.CFrame = CFrame.new(targetPos) end
    workspace.Gravity = 196.2
end

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Size = UDim2.fromOffset(250, 110)
Main.Position = UDim2.new(0.5, -125, 0.4, 0)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel", Main)
TitleLabel.Text = "WAI"
TitleLabel.Size = UDim2.new(1, -20, 0, 40)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local ToggleContainer = Instance.new("Frame", Main)
ToggleContainer.Size = UDim2.new(0, 220, 0, 50)
ToggleContainer.Position = UDim2.new(0.5, -110, 0.5, -5)
ToggleContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", ToggleContainer).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel", ToggleContainer)
StatusLabel.Text = "STATUS: ON"
StatusLabel.Size = UDim2.new(1, -70, 1, 0)
StatusLabel.Position = UDim2.new(0, 12, 0, 0)
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton", ToggleContainer)
ToggleBtn.Size = UDim2.new(0, 46, 0, 24)
ToggleBtn.Position = UDim2.new(1, -58, 0.5, -12)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
ToggleBtn.Text = ""
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local Circle = Instance.new("Frame", ToggleBtn)
Circle.Size = UDim2.new(0, 18, 0, 18)
Circle.Position = UDim2.new(1, -21, 0.5, -9)
Circle.BackgroundColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

local function MainLoop()
    while autoFarmEnabled do
        isMoving = true
        SmoothFly(p1)
        if not autoFarmEnabled then break end
        SmoothFly(p2)
        if not autoFarmEnabled then break end
        if CheckTsunami() then repeat task.wait(0.5) until not CheckTsunami() or not autoFarmEnabled end
        SmoothFly(p3)
        if not autoFarmEnabled then break end
        local npcs = GetNearbyNPCs()
        for _, npcPos in ipairs(npcs) do
            if not autoFarmEnabled then break end
            if CheckTsunami() then SmoothFly(p3) repeat task.wait(0.5) until not CheckTsunami() or not autoFarmEnabled end
            SmoothFly(npcPos) 
            task.wait(0.7)
        end
        if not autoFarmEnabled then break end
        SmoothFly(p3)
        SmoothFly(p2)
        SmoothFly(p1)
        task.wait(0.5)
    end
end

local function UpdateUI()
    StatusLabel.Text = autoFarmEnabled and "STATUS: ON" or "STATUS: OFF"
    tweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(80, 80, 85)}):Play()
    tweenService:Create(Circle, TweenInfo.new(0.2), {Position = autoFarmEnabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
end

ToggleBtn.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    UpdateUI()
    if autoFarmEnabled then task.spawn(MainLoop) else isMoving = false workspace.Gravity = 196.2 end
end)

player.CharacterAdded:Connect(function()
    workspace.Gravity = 196.2
    if autoFarmEnabled then
        isMoving = false
        task.wait(15) 
        if autoFarmEnabled then task.spawn(MainLoop) end
    end
end)

task.spawn(MainLoop)
