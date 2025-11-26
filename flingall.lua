local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local rt = {}

-- Настройки
local Settings = {
    Enabled = false,
    FloorOffset = -1.1,
    Duration = 2,
    WaitTime = 0.03,
    LoopWait = 0.20
}

local Whitelist = {}

-- Функция проверки Elite
function rt:IsElite() : (boolean)
    if Player:GetAttribute("Elite") then
        return true
    end
    return false
end

-- Функция проверки жив ли игрок
local function isPlayerAlive(player)
    if not player then return false end
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            return true
        end
    end
    return false
end

-- Функция медленного перемещения
local function moveToPositionSlowly(targetPosition: Vector3, duration: number)
    local character = rt:Character()
    if not character or not character.Parent then return false end
    
    rt.humanoidRootPart = character.PrimaryPart
    if not rt.humanoidRootPart then return false end
    
    local startPosition = rt.humanoidRootPart.Position
    local startTime = tick()
    local maxDuration = math.max(duration * 1.5, 3)
    
    local lyingRotation = CFrame.Angles(math.rad(90), 0, 0)
    local floorOffset = Settings.FloorOffset
    
    while rt.isRunning and rt.roundActive do
        local elapsedTime = tick() - startTime
        
        if elapsedTime > maxDuration then
            return false
        end
        
        local alpha = math.min(elapsedTime / duration, 1)
        
        if not character or not character.Parent or not rt.humanoidRootPart then
            return false
        end
        
        local success = pcall(function()
            local currentPos = startPosition:Lerp(targetPosition, alpha)
            local offsetPos = currentPos + Vector3.new(0, floorOffset, 0)
            character:PivotTo(CFrame.new(offsetPos) * lyingRotation)
        end)
        
        if not success then
            return false
        end

        if alpha >= 1 then
            break
        end

        task.wait()
    end
    
    return true
end

-- Функция Fling
local function Fling(TargetPlayer)
    -- ЗАЩИТА: Не флингать самого себя
    if TargetPlayer == Player then
        return
    end
    
    local success, error = pcall(function()
        local Character = Player.Character
        if not Character then return end
        
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid then return end
        
        local RootPart = Humanoid.RootPart
        if not RootPart then return end

        local TCharacter = TargetPlayer.Character
        if not TCharacter then return end
        
        local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
        if not THumanoid then return end
        
        local TRootPart = THumanoid.RootPart
        local THead = TCharacter:FindFirstChild("Head")
        local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
        local Handle = Accessory and Accessory:FindFirstChild("Handle")

        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        
        if THumanoid.Sit then
            return
        end
        
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
        
        local function FPos(BasePart, Pos, Ang)
            if not (RootPart and RootPart.Parent and BasePart and BasePart.Parent) then
                return false
            end
            
            pcall(function()
                RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end)
            
            return true
        end
        
        local function SFBasePart(BasePart)
            if not BasePart then return end
            
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0

            repeat
                if not Settings.Enabled then break end
                
                if not (RootPart and RootPart.Parent and THumanoid and THumanoid.Parent and BasePart and BasePart.Parent) then
                    break
                end
                
                local basePartVelocity = BasePart.Velocity
                if not basePartVelocity then break end
                
                if basePartVelocity.Magnitude < 50 then
                    Angle = Angle + 100

                    if not FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * basePartVelocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * basePartVelocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * basePartVelocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * basePartVelocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0)) then break end
                    task.wait()
                else
                    if not FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)) then break end
                    task.wait()
                    
                    if not TRootPart or not TRootPart.Parent then break end
                    
                    if not FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0)) then break end
                    task.wait()

                    if not FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)) then break end
                    task.wait()
                end
            until not BasePart.Parent or BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or TargetPlayer.Character ~= TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end
        
        pcall(function()
            workspace.FallenPartsDestroyHeight = 0/0
        end)
        
        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        
        pcall(function()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        end)
        
        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            if BV then BV:Destroy() end
            return
        end
        
        if BV and BV.Parent then
            BV:Destroy()
        end
        
        pcall(function()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        end)
        
        pcall(function()
            workspace.CurrentCamera.CameraSubject = Humanoid
        end)
        
        if getgenv().OldPos and RootPart and RootPart.Parent then
            repeat
                local canContinue = pcall(function()
                    RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                    Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                    Humanoid:ChangeState("GettingUp")
                    table.foreach(Character:GetChildren(), function(_, x)
                        if x:IsA("BasePart") then
                            x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                        end
                    end)
                end)
                
                if not canContinue then break end
                task.wait()
            until not RootPart.Parent or (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        end
        
        pcall(function()
            workspace.FallenPartsDestroyHeight = workspace.FallenPartsDestroyHeight
        end)
        
        getgenv().OldPos = nil
    end)
end

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local WhitelistFrame = Instance.new("Frame")
local WhitelistTitle = Instance.new("TextLabel")
local WhitelistInput = Instance.new("TextBox")
local AddButton = Instance.new("TextButton")
local RemoveButton = Instance.new("TextButton")
local WhitelistScroll = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")

-- Настройка GUI
ScreenGui.Name = "FlingGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Fling Script Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = MainFrame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 20

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeButton

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0.5, -100, 0, 60)
ToggleButton.Size = UDim2.new(0, 200, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "Запустить Fling"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0, 110)
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Статус: Выключено"
StatusLabel.TextColor3 = Color3.fromRGB(220, 50, 50)
StatusLabel.TextSize = 14

WhitelistFrame.Name = "WhitelistFrame"
WhitelistFrame.Parent = MainFrame
WhitelistFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
WhitelistFrame.BorderSizePixel = 0
WhitelistFrame.Position = UDim2.new(0, 10, 0, 150)
WhitelistFrame.Size = UDim2.new(1, -20, 1, -160)

local WLCorner = Instance.new("UICorner")
WLCorner.CornerRadius = UDim.new(0, 8)
WLCorner.Parent = WhitelistFrame

WhitelistTitle.Name = "WhitelistTitle"
WhitelistTitle.Parent = WhitelistFrame
WhitelistTitle.BackgroundTransparency = 1
WhitelistTitle.Size = UDim2.new(1, 0, 0, 30)
WhitelistTitle.Font = Enum.Font.GothamBold
WhitelistTitle.Text = "Белый список"
WhitelistTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
WhitelistTitle.TextSize = 14

WhitelistInput.Name = "WhitelistInput"
WhitelistInput.Parent = WhitelistFrame
WhitelistInput.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
WhitelistInput.BorderSizePixel = 0
WhitelistInput.Position = UDim2.new(0, 10, 0, 40)
WhitelistInput.Size = UDim2.new(1, -20, 0, 30)
WhitelistInput.Font = Enum.Font.Gotham
WhitelistInput.PlaceholderText = "Введите имя игрока..."
WhitelistInput.Text = ""
WhitelistInput.TextColor3 = Color3.fromRGB(255, 255, 255)
WhitelistInput.TextSize = 12

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = WhitelistInput

AddButton.Name = "AddButton"
AddButton.Parent = WhitelistFrame
AddButton.BackgroundColor3 = Color3.fromRGB(50, 220, 100)
AddButton.BorderSizePixel = 0
AddButton.Position = UDim2.new(0, 10, 0, 80)
AddButton.Size = UDim2.new(0.48, -10, 0, 30)
AddButton.Font = Enum.Font.GothamBold
AddButton.Text = "Добавить"
AddButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AddButton.TextSize = 12

local AddCorner = Instance.new("UICorner")
AddCorner.CornerRadius = UDim.new(0, 6)
AddCorner.Parent = AddButton

RemoveButton.Name = "RemoveButton"
RemoveButton.Parent = WhitelistFrame
RemoveButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
RemoveButton.BorderSizePixel = 0
RemoveButton.Position = UDim2.new(0.52, 0, 0, 80)
RemoveButton.Size = UDim2.new(0.48, -10, 0, 30)
RemoveButton.Font = Enum.Font.GothamBold
RemoveButton.Text = "Удалить"
RemoveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RemoveButton.TextSize = 12

local RemCorner = Instance.new("UICorner")
RemCorner.CornerRadius = UDim.new(0, 6)
RemCorner.Parent = RemoveButton

WhitelistScroll.Name = "WhitelistScroll"
WhitelistScroll.Parent = WhitelistFrame
WhitelistScroll.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
WhitelistScroll.BorderSizePixel = 0
WhitelistScroll.Position = UDim2.new(0, 10, 0, 120)
WhitelistScroll.Size = UDim2.new(1, -20, 1, -130)
WhitelistScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
WhitelistScroll.ScrollBarThickness = 4

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = WhitelistScroll

UIListLayout.Parent = WhitelistScroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Функции управления
local function UpdateWhitelistDisplay()
    for _, child in pairs(WhitelistScroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    for name, _ in pairs(Whitelist) do
        local label = Instance.new("TextLabel")
        label.Parent = WhitelistScroll
        label.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
        label.BorderSizePixel = 0
        label.Size = UDim2.new(1, -10, 0, 25)
        label.Font = Enum.Font.Gotham
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        
        local LabelCorner = Instance.new("UICorner")
        LabelCorner.CornerRadius = UDim.new(0, 4)
        LabelCorner.Parent = label
    end
    
    WhitelistScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

-- Кнопка включения/выключения
ToggleButton.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    
    if Settings.Enabled then
        ToggleButton.Text = "Остановить Fling"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 220, 100)
        StatusLabel.Text = "Статус: Включено"
        StatusLabel.TextColor3 = Color3.fromRGB(50, 220, 100)
    else
        ToggleButton.Text = "Запустить Fling"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        StatusLabel.Text = "Статус: Выключено"
        StatusLabel.TextColor3 = Color3.fromRGB(220, 50, 50)
    end
end)

-- Добавление в белый список
AddButton.MouseButton1Click:Connect(function()
    local name = WhitelistInput.Text
    if name and name ~= "" then
        Whitelist[name:lower()] = true
        WhitelistInput.Text = ""
        UpdateWhitelistDisplay()
    end
end)

-- Удаление из белого списка
RemoveButton.MouseButton1Click:Connect(function()
    local name = WhitelistInput.Text
    if name and name ~= "" then
        Whitelist[name:lower()] = nil
        WhitelistInput.Text = ""
        UpdateWhitelistDisplay()
    end
end)

-- Закрытие GUI
CloseButton.MouseButton1Click:Connect(function()
    Settings.Enabled = false
    ScreenGui:Destroy()
end)

-- Минимизация
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 350, 0, 40)
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 350, 0, 400)
        MinimizeButton.Text = "-"
    end
end)

-- Основной цикл
task.spawn(function()
    while true do
        if Settings.Enabled then
            for _, player in pairs(Players:GetPlayers()) do
                -- ЗАЩИТА: пропускаем себя и игроков из белого списка
                if player and player ~= Player and player.Name and Whitelist[player.Name:lower()] and isPlayerAlive(Player) then
                    Fling(player)
                    task.wait(Settings.WaitTime)
                end
            end
        end
        task.wait(Settings.LoopWait)
    end
end)

print("Fling Script загружен! Elite статус:", rt:IsElite())
