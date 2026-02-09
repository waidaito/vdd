local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

local flySpeed = 400
local p1, p2, p3 = Vector3.new(146.96, 3.30, -136.51), Vector3.new(2429.40, 3.35, -139.51), Vector3.new(2615.39, -2.70, 5.14)
local isMoving, autoFarmEnabled = false, true
local wasEnabledBeforeDeath = false

local function SetAnchor(state)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.Anchored = state end
end

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
            local hrp = model and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart"))
            if hrp and (hrp.Position - root.Position).Magnitude <= 500 then
                table.insert(found, hrp.Position)
            end
        end
        if #found >= 3 then break end
    end
    return found
end

local function SmoothFly(targetPos)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not autoFarmEnabled or not hrp.Parent then return end
    
    isMoving = true
    SetAnchor(false)
    workspace.Gravity = 0
    
    local noclipLoop = runService.Stepped:Connect(function()
        if char and hrp.Parent then SetNoclip() hrp.Velocity = Vector3.zero end
    end)
    
    while autoFarmEnabled and hrp.Parent do
        local currentPos = hrp.Position
        if (targetPos - currentPos).Magnitude < 5 then break end
        local dt = runService.Heartbeat:Wait()
        hrp.CFrame = CFrame.new(currentPos + ((targetPos - currentPos).Unit * (flySpeed * dt)), targetPos)
    end
    
    if noclipLoop then noclipLoop:Disconnect() end
    if hrp and hrp.Parent then 
        hrp.Velocity = Vector3.zero 
        hrp.CFrame = CFrame.new(targetPos) 
        if autoFarmEnabled then SetAnchor(true) end
    end
    workspace.Gravity = 196.2
    isMoving = false
end

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.BackgroundColor3, Main.Size, Main.Position, Main.Active, Main.Draggable = Color3.fromRGB(20, 20, 25), UDim2.fromOffset(250, 110), UDim2.new(0.5, -125, 0.4, 0), true, true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel", Main)
TitleLabel.Text, TitleLabel.Size, TitleLabel.Position, TitleLabel.TextColor3, TitleLabel.BackgroundTransparency, TitleLabel.Font, TitleLabel.TextSize, TitleLabel.TextXAlignment = "WAI", UDim2.new(1, -20, 0, 40), UDim2.new(0, 15, 0, 0), Color3.new(1, 1, 1), 1, Enum.Font.GothamBold, 16, Enum.TextXAlignment.Left

local ToggleContainer = Instance.new("Frame", Main)
ToggleContainer.Size, ToggleContainer.Position, ToggleContainer.BackgroundColor3 = UDim2.new(0, 220, 0, 50), UDim2.new(0.5, -110, 0.5, -5), Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", ToggleContainer).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel", ToggleContainer)
StatusLabel.Text, StatusLabel.Size, StatusLabel.Position, StatusLabel.TextColor3, StatusLabel.BackgroundTransparency, StatusLabel.Font, StatusLabel.TextSize, StatusLabel.TextXAlignment = "STATUS: ON", UDim2.new(1, -70, 1, 0), UDim2.new(0, 12, 0, 0), Color3.new(1, 1, 1), 1, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton", ToggleContainer)
ToggleBtn.Size, ToggleBtn.Position, ToggleBtn.BackgroundColor3, ToggleBtn.Text = UDim2.new(0, 46, 0, 24), UDim2.new(1, -58, 0.5, -12), Color3.fromRGB(60, 160, 60), ""
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local Circle = Instance.new("Frame", ToggleBtn)
Circle.Size, Circle.Position, Circle.BackgroundColor3 = UDim2.new(0, 18, 0, 18), UDim2.new(1, -21, 0.5, -9), Color3.new(1, 1, 1)
Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

local function UpdateUI()
    StatusLabel.Text = autoFarmEnabled and "STATUS: ON" or "STATUS: OFF"
    tweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(80, 80, 85)}):Play()
    tweenService:Create(Circle, TweenInfo.new(0.2), {Position = autoFarmEnabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
end

local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = Main.Position end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) dragging = false end)

function MainLoop()
    while autoFarmEnabled do
        SmoothFly(p1)
        if not autoFarmEnabled then break end
        SmoothFly(p2)
        if not autoFarmEnabled then break end
        if CheckTsunami() then 
            SetAnchor(true)
            repeat task.wait(0.5) until not CheckTsunami() or not autoFarmEnabled 
        end
        SmoothFly(p3)
        if not autoFarmEnabled then break end
        local npcs = GetNearbyNPCs()
        for _, npcPos in ipairs(npcs) do
            if not autoFarmEnabled then break end
            if CheckTsunami() then 
                SmoothFly(p3) 
                repeat task.wait(0.5) until not CheckTsunami() or not autoFarmEnabled 
            end
            SmoothFly(npcPos) task.wait(0.6)
        end
        if not autoFarmEnabled then break end
        SmoothFly(p2)
        if not autoFarmEnabled then break end
        SmoothFly(p1)
        task.wait(0.5)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    UpdateUI()
    if autoFarmEnabled then 
        task.spawn(MainLoop) 
    else 
        isMoving = false 
        SetAnchor(false)
        workspace.Gravity = 196.2 
    end
end)

player.CharacterAdded:Connect(function()
    wasEnabledBeforeDeath = autoFarmEnabled
    autoFarmEnabled = false
    isMoving = false
    workspace.Gravity = 196.2
    UpdateUI()
    
    if wasEnabledBeforeDeath then
        task.wait(15)
        autoFarmEnabled = true
        UpdateUI()
        task.spawn(MainLoop)
    end
end)

task.spawn(MainLoop)
if autoFarmEnabled then SetAnchor(true) end
