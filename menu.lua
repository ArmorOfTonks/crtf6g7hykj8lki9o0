--[[
    MODERN CHEAT MENU V8.0
    Полностью переработанная версия с библиотекой UI
    
    ОСОБЕННОСТИ:
    - Современный дизайн с плавными анимациями
    - RGB настройки для всех цветов
    - Расширенные настройки Night Mode
    - Улучшенная производительность
    - Новая система вкладок с прокруткой
    - Выдача денег, гемов, кэша и алмазов с визуальными эффектами
    - Click TP и невидимость
    - Настройка гравитации
    - Улучшенный TriggerBot и RapidFire для всех оружий
    - Murder Mystery 2 ESP с определением ролей
    - Троллинг игроков
    - Копирование инструментов игроков

    АКТИВАЦИЯ: Клавиша INSERT или правый CTRL
]]

-- ====================================================================
-- СЕРВИСЫ И ПЕРЕМЕННЫЕ
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")

-- Глобальные переменные
local activeConnections = {}
local savedValues = {}
local espData = {}
local menuVisible = false

-- ====================================================================
-- КОНФИГУРАЦИЯ
-- ====================================================================

local Config = {
    -- UI Цвета
    BackgroundColor = Color3.fromRGB(20, 20, 25),
    SecondaryColor = Color3.fromRGB(30, 30, 35),
    AccentColor = Color3.fromRGB(120, 100, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(180, 180, 190),
    ToggleOn = Color3.fromRGB(100, 200, 100),
    ToggleOff = Color3.fromRGB(60, 60, 70),
    
    -- Визуальные эффекты
    ESPEnemyColor = Color3.fromRGB(255, 80, 80),
    ESPTeamColor = Color3.fromRGB(80, 150, 255),
    NightAmbient = Color3.fromRGB(10, 10, 15),
    
    -- Настройки
    UITransparency = 0.05,
    AnimationSpeed = 0.3,
    
    -- Игровые значения
    SpeedMultiplier = 2.5,
    JumpMultiplier = 2.0,
    FlightSpeed = 50,
    FOVValue = 120,
    AimbotFOV = 100,
    AimbotSmoothness = 0.15,
    GravityValue = 196.2,
    
    -- Новые настройки
    TriggerBotDelay = 0.1,
    RapidFireSpeed = 0,
    
    -- Настройки валют
    MoneyAmount = 1000,
    CashAmount = 500,
    GemAmount = 100,
    DiamondAmount = 50,
    XPAmount = 100,
    LevelAmount = 1,
    
    -- Настройки RGB
    RGBBackground = false,
    RGBSpeed = 1,
    
    -- Настройки Murder Mystery 2
    MM2InnocentColor = Color3.fromRGB(0, 255, 0),
    MM2MurdererColor = Color3.fromRGB(255, 0, 0),
    MM2SheriffColor = Color3.fromRGB(0, 0, 255),
}

-- ====================================================================
-- БИБЛИОТЕКА UI
-- ====================================================================

local Library = {}
Library.__index = Library

function Library:Create()
    local self = setmetatable({}, Library)
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Создание главного GUI
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ModernCheatMenu"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Проверка наличия PlayerGui
    if not LocalPlayer:FindFirstChild("PlayerGui") then
        repeat wait() until LocalPlayer:FindFirstChild("PlayerGui")
    end
    self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Главный фрейм
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 750, 0, 550)
    self.MainFrame.Position = UDim2.new(0.5, -375, 0.5, -275)
    self.MainFrame.BackgroundColor3 = Config.BackgroundColor
    self.MainFrame.BackgroundTransparency = Config.UITransparency
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Visible = false
    self.MainFrame.Parent = self.ScreenGui
    
    -- Закругление углов
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = self.MainFrame
    
    -- Градиент фона
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Config.BackgroundColor),
        ColorSequenceKeypoint.new(1, Config.SecondaryColor)
    }
    Gradient.Rotation = 45
    Gradient.Parent = self.MainFrame
    
    -- Свечение
    self.Glow = Instance.new("ImageLabel")
    self.Glow.Name = "Glow"
    self.Glow.BackgroundTransparency = 1
    self.Glow.Position = UDim2.new(0, -15, 0, -15)
    self.Glow.Size = UDim2.new(1, 30, 1, 30)
    self.Glow.ZIndex = 0
    self.Glow.Image = "rbxassetid://3570695787"
    self.Glow.ImageColor3 = Config.AccentColor
    self.Glow.ImageTransparency = 0.7
    self.Glow.ScaleType = Enum.ScaleType.Slice
    self.Glow.SliceCenter = Rect.new(100, 100, 100, 100)
    self.Glow.Parent = self.MainFrame
    
    -- Заголовок
    self.Header = Instance.new("Frame")
    self.Header.Name = "Header"
    self.Header.Size = UDim2.new(1, 0, 0, 60)
    self.Header.BackgroundColor3 = Config.SecondaryColor
    self.Header.BackgroundTransparency = 0.3
    self.Header.BorderSizePixel = 0
    self.Header.Parent = self.MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = self.Header
    
    -- Название
    self.Title = Instance.new("TextLabel")
    self.Title.Size = UDim2.new(1, -100, 1, 0)
    self.Title.Position = UDim2.new(0, 20, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = "⚡ MODERN CHEAT MENU V8.0"
    self.Title.TextColor3 = Config.TextColor
    self.Title.Font = Enum.Font.GothamBold
    self.Title.TextSize = 20
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.Parent = self.Header
    
    -- Кнопка закрытия
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Size = UDim2.new(0, 45, 0, 45)
    self.CloseButton.Position = UDim2.new(1, -55, 0, 7)
    self.CloseButton.BackgroundColor3 = Config.SecondaryColor
    self.CloseButton.Text = "✕"
    self.CloseButton.TextColor3 = Config.TextColor
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.TextSize = 22
    self.CloseButton.Parent = self.Header
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = self.CloseButton
    
    -- Контейнер вкладок (теперь с прокруткой)
    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Size = UDim2.new(0, 160, 1, -70)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 70)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ScrollBarThickness = 4
    self.TabContainer.ScrollBarImageColor3 = Config.AccentColor
    self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabContainer.Parent = self.MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 10)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = self.TabContainer
    
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
    end)
    
    -- Контейнер содержимого
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Size = UDim2.new(1, -180, 1, -80)
    self.ContentContainer.Position = UDim2.new(0, 170, 0, 70)
    self.ContentContainer.BackgroundColor3 = Config.SecondaryColor
    self.ContentContainer.BackgroundTransparency = 0.5
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = self.MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 10)
    ContentCorner.Parent = self.ContentContainer
    
    -- Функционал закрытия
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Перетаскивание
    self:MakeDraggable()
    
    -- Запуск RGB анимации если включено
    if Config.RGBBackground then
        self:StartRGBAnimation()
    end
    
    return self
end

function Library:MakeDraggable()
    local dragging, dragInput, dragStart, startPos
    
    self.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    RunService.Heartbeat:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            
            TweenService:Create(self.MainFrame, TweenInfo.new(0.1), {
                Position = newPos
            }):Play()
        end
    end)
end

function Library:Toggle()
    menuVisible = not menuVisible
    
    if menuVisible then
        self.MainFrame.Visible = true
        self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
        
        TweenService:Create(self.MainFrame, TweenInfo.new(Config.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 750, 0, 550)
        }):Play()
        
        print("✓ Menu Opened")
    else
        TweenService:Create(self.MainFrame, TweenInfo.new(Config.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        task.wait(Config.AnimationSpeed)
        self.MainFrame.Visible = false
        
        print("✕ Menu Closed")
    end
end

-- Функция RGB анимации
function Library:StartRGBAnimation()
    if activeConnections.RGBAnimation then
        activeConnections.RGBAnimation:Disconnect()
    end
    
    activeConnections.RGBAnimation = RunService.Heartbeat:Connect(function()
        if not Config.RGBBackground then return end
        
        local time = tick() * Config.RGBSpeed
        local r = (math.sin(time) + 1) / 2
        local g = (math.sin(time + 2) + 1) / 2
        local b = (math.sin(time + 4) + 1) / 2
        
        local rgbColor = Color3.new(r, g, b)
        
        -- Обновляем свечение
        self.Glow.ImageColor3 = rgbColor
        
        -- Обновляем акцентный цвет для некоторых элементов
        Config.AccentColor = rgbColor
    end)
end

function Library:StopRGBAnimation()
    if activeConnections.RGBAnimation then
        activeConnections.RGBAnimation:Disconnect()
        activeConnections.RGBAnimation = nil
    end
end

function Library:CreateTab(name, icon)
    local Tab = {}
    
    -- Кнопка вкладки
    Tab.Button = Instance.new("TextButton")
    Tab.Button.Size = UDim2.new(1, 0, 0, 45)
    Tab.Button.BackgroundColor3 = Config.SecondaryColor
    Tab.Button.BackgroundTransparency = 0.3
    Tab.Button.Text = ""
    Tab.Button.Parent = self.TabContainer
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Tab.Button
    
    -- Иконка и текст
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = icon .. " " .. name
    Label.TextColor3 = Config.SubTextColor
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Tab.Button
    
    -- Индикатор активности
    Tab.Indicator = Instance.new("Frame")
    Tab.Indicator.Size = UDim2.new(0, 3, 0, 0)
    Tab.Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    Tab.Indicator.AnchorPoint = Vector2.new(0, 0.5)
    Tab.Indicator.BackgroundColor3 = Config.AccentColor
    Tab.Indicator.BorderSizePixel = 0
    Tab.Indicator.Parent = Tab.Button
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Tab.Indicator
    
    -- Контейнер содержимого вкладки
    Tab.Content = Instance.new("ScrollingFrame")
    Tab.Content.Size = UDim2.new(1, -20, 1, -20)
    Tab.Content.Position = UDim2.new(0, 10, 0, 10)
    Tab.Content.BackgroundTransparency = 1
    Tab.Content.BorderSizePixel = 0
    Tab.Content.ScrollBarThickness = 5
    Tab.Content.ScrollBarImageColor3 = Config.AccentColor
    Tab.Content.Visible = false
    Tab.Content.Parent = self.ContentContainer
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 12)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = Tab.Content
    
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Tab.Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Функция активации вкладки
    function Tab:Activate()
        for _, tab in pairs(self.Library.Tabs) do
            tab.Content.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
            TweenService:Create(tab.Indicator, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 3, 0, 0)
            }):Play()
            tab.Button:FindFirstChild("TextLabel").TextColor3 = Config.SubTextColor
        end
        
        Tab.Content.Visible = true
        TweenService:Create(Tab.Button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
        TweenService:Create(Tab.Indicator, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 3, 0, 35)
        }):Play()
        Label.TextColor3 = Config.TextColor
        
        self.Library.CurrentTab = Tab
    end
    
    Tab.Library = self
    
    -- Переключение вкладок
    Tab.Button.MouseButton1Click:Connect(function()
        Tab:Activate()
    end)
    
    -- Добавление методов вкладки
    function Tab:AddToggle(name, callback)
        local Toggle = {}
        Toggle.State = false
        
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
        ToggleFrame.BackgroundColor3 = Config.BackgroundColor
        ToggleFrame.BackgroundTransparency = 0.5
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = Tab.Content
    
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 8)
        ToggleCorner.Parent = ToggleFrame
    
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Config.TextColor
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.TextSize = 15
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame
    
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 50, 0, 28)
        ToggleButton.Position = UDim2.new(1, -60, 0.5, -14)
        ToggleButton.BackgroundColor3 = Config.ToggleOff
        ToggleButton.Text = ""
        ToggleButton.Parent = ToggleFrame
    
        local ToggleButtonCorner = Instance.new("UICorner")
        ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
        ToggleButtonCorner.Parent = ToggleButton
    
        local ToggleCircle = Instance.new("Frame")
        ToggleCircle.Size = UDim2.new(0, 22, 0, 22)
        ToggleCircle.Position = UDim2.new(0, 3, 0.5, -11)
        ToggleCircle.BackgroundColor3 = Config.TextColor
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Parent = ToggleButton
    
        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(1, 0)
        CircleCorner.Parent = ToggleCircle
    
        function Toggle:Set(state)
            Toggle.State = state
            
            if state then
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Config.ToggleOn
                }):Play()
                TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                    Position = UDim2.new(1, -25, 0.5, -11)
                }):Play()
                print("✓ Enabled:", name)
            else
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Config.ToggleOff
                }):Play()
                TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                    Position = UDim2.new(0, 3, 0.5, -11)
                }):Play()
                print("✕ Disabled:", name)
            end
            
            if callback then
                callback(state)
            end
        end
    
        ToggleButton.MouseButton1Click:Connect(function()
            Toggle:Set(not Toggle.State)
        end)
    
        return Toggle
    end
    
    function Tab:AddSlider(name, min, max, default, callback)
        local Slider = {}
        Slider.Value = default or min
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 70)
        SliderFrame.BackgroundColor3 = Config.BackgroundColor
        SliderFrame.BackgroundTransparency = 0.5
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = Tab.Content
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 8)
        SliderCorner.Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Size = UDim2.new(1, -30, 0, 25)
        SliderLabel.Position = UDim2.new(0, 15, 0, 8)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = name .. ": " .. Slider.Value
        SliderLabel.TextColor3 = Config.TextColor
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.TextSize = 14
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame
        
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Size = UDim2.new(1, -30, 0, 8)
        SliderTrack.Position = UDim2.new(0, 15, 0, 45)
        SliderTrack.BackgroundColor3 = Config.SecondaryColor
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Parent = SliderFrame
        
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = SliderTrack
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        SliderFill.BackgroundColor3 = Config.AccentColor
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderTrack
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = SliderFill
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Size = UDim2.new(1, 0, 1, 0)
        SliderButton.BackgroundTransparency = 1
        SliderButton.Text = ""
        SliderButton.Parent = SliderTrack
        
        local dragging = false
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        RunService.RenderStepped:Connect(function()
            if dragging then
                local mouse = UserInputService:GetMouseLocation()
                local percent = math.clamp((mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                Slider.Value = math.floor(min + (max - min) * percent)
                
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                SliderLabel.Text = name .. ": " .. Slider.Value
                
                if callback then
                    callback(Slider.Value)
                end
            end
        end)
        
        return Slider
    end
    
    function Tab:AddColorPicker(name, default, callback)
        local ColorPicker = {}
        ColorPicker.Color = default or Color3.new(1, 1, 1)
        
        local PickerFrame = Instance.new("Frame")
        PickerFrame.Size = UDim2.new(1, 0, 0, 50)
        PickerFrame.BackgroundColor3 = Config.BackgroundColor
        PickerFrame.BackgroundTransparency = 0.5
        PickerFrame.BorderSizePixel = 0
        PickerFrame.Parent = Tab.Content
        
        local PickerCorner = Instance.new("UICorner")
        PickerCorner.CornerRadius = UDim.new(0, 8)
        PickerCorner.Parent = PickerFrame
        
        local PickerLabel = Instance.new("TextLabel")
        PickerLabel.Size = UDim2.new(1, -70, 1, 0)
        PickerLabel.Position = UDim2.new(0, 15, 0, 0)
        PickerLabel.BackgroundTransparency = 1
        PickerLabel.Text = name
        PickerLabel.TextColor3 = Config.TextColor
        PickerLabel.Font = Enum.Font.Gotham
        PickerLabel.TextSize = 15
        PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
        PickerLabel.Parent = PickerFrame
        
        local ColorDisplay = Instance.new("Frame")
        ColorDisplay.Size = UDim2.new(0, 40, 0, 30)
        ColorDisplay.Position = UDim2.new(1, -55, 0.5, -15)
        ColorDisplay.BackgroundColor3 = ColorPicker.Color
        ColorDisplay.BorderSizePixel = 0
        ColorDisplay.Parent = PickerFrame
        
        local DisplayCorner = Instance.new("UICorner")
        DisplayCorner.CornerRadius = UDim.new(0, 6)
        DisplayCorner.Parent = ColorDisplay
        
        local ColorButton = Instance.new("TextButton")
        ColorButton.Size = UDim2.new(1, 0, 1, 0)
        ColorButton.BackgroundTransparency = 1
        ColorButton.Text = ""
        ColorButton.Parent = ColorDisplay
        
        -- Простой RGB ввод через TextBox
        local RGBInput = Instance.new("TextBox")
        RGBInput.Size = UDim2.new(0, 160, 0, 35)
        RGBInput.Position = UDim2.new(0.5, -80, 0.5, -17)
        RGBInput.BackgroundColor3 = Config.SecondaryColor
        RGBInput.Text = string.format("%d, %d, %d", ColorPicker.Color.R * 255, ColorPicker.Color.G * 255, ColorPicker.Color.B * 255)
        RGBInput.TextColor3 = Config.TextColor
        RGBInput.Font = Enum.Font.Gotham
        RGBInput.TextSize = 13
        RGBInput.PlaceholderText = "R, G, B (0-255)"
        RGBInput.Visible = false
        RGBInput.Parent = PickerFrame
        
        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 6)
        InputCorner.Parent = RGBInput
        
        ColorButton.MouseButton1Click:Connect(function()
            RGBInput.Visible = not RGBInput.Visible
        end)
        
        RGBInput.FocusLost:Connect(function()
            local r, g, b = RGBInput.Text:match("^(%d+),%s*(%d+),%s*(%d+)$")
            if r and g and b then
                r, g, b = tonumber(r), tonumber(g), tonumber(b)
                if r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
                    ColorPicker.Color = Color3.fromRGB(r, g, b)
                    ColorDisplay.BackgroundColor3 = ColorPicker.Color
                    if callback then callback(ColorPicker.Color) end
                end
            end
        end)
        
        return ColorPicker
    end
    
    function Tab:AddButton(name, callback)
        local ButtonFrame = Instance.new("TextButton")
        ButtonFrame.Size = UDim2.new(1, 0, 0, 45)
        ButtonFrame.BackgroundColor3 = Config.AccentColor
        ButtonFrame.BackgroundTransparency = 0.2
        ButtonFrame.Text = name
        ButtonFrame.TextColor3 = Config.TextColor
        ButtonFrame.Font = Enum.Font.GothamBold
        ButtonFrame.TextSize = 15
        ButtonFrame.BorderSizePixel = 0
        ButtonFrame.Parent = Tab.Content
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 8)
        ButtonCorner.Parent = ButtonFrame
        
        ButtonFrame.MouseButton1Click:Connect(function()
            TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {
                BackgroundTransparency = 0
            }):Play()
            
            task.wait(0.1)
            
            TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.2
            }):Play()
            
            if callback then
                callback()
            end
        end)
        
        return ButtonFrame
    end
    
    function Tab:AddSection(name)
        local Section = Instance.new("TextLabel")
        Section.Size = UDim2.new(1, 0, 0, 35)
        Section.BackgroundTransparency = 1
        Section.Text = "━━━ " .. name .. " ━━━"
        Section.TextColor3 = Config.AccentColor
        Section.Font = Enum.Font.GothamBold
        Section.TextSize = 13
        Section.Parent = Tab.Content
    end
    
    function Tab:AddTextBox(name, placeholder, callback)
        local TextBoxFrame = Instance.new("Frame")
        TextBoxFrame.Size = UDim2.new(1, 0, 0, 55)
        TextBoxFrame.BackgroundColor3 = Config.BackgroundColor
        TextBoxFrame.BackgroundTransparency = 0.5
        TextBoxFrame.BorderSizePixel = 0
        TextBoxFrame.Parent = Tab.Content
        
        local TextBoxCorner = Instance.new("UICorner")
        TextBoxCorner.CornerRadius = UDim.new(0, 8)
        TextBoxCorner.Parent = TextBoxFrame
        
        local TextBoxLabel = Instance.new("TextLabel")
        TextBoxLabel.Size = UDim2.new(1, -20, 0, 25)
        TextBoxLabel.Position = UDim2.new(0, 10, 0, 5)
        TextBoxLabel.BackgroundTransparency = 1
        TextBoxLabel.Text = name
        TextBoxLabel.TextColor3 = Config.TextColor
        TextBoxLabel.Font = Enum.Font.Gotham
        TextBoxLabel.TextSize = 13
        TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextBoxLabel.Parent = TextBoxFrame
        
        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(1, -20, 0, 28)
        TextBox.Position = UDim2.new(0, 10, 0, 30)
        TextBox.BackgroundColor3 = Config.SecondaryColor
        TextBox.TextColor3 = Config.TextColor
        TextBox.Font = Enum.Font.Gotham
        TextBox.TextSize = 13
        TextBox.PlaceholderText = placeholder
        TextBox.Text = ""
        TextBox.Parent = TextBoxFrame
        
        local TextBoxInnerCorner = Instance.new("UICorner")
        TextBoxInnerCorner.CornerRadius = UDim.new(0, 6)
        TextBoxInnerCorner.Parent = TextBox
        
        TextBox.FocusLost:Connect(function()
            if callback then
                callback(TextBox.Text)
            end
        end)
        
        return TextBox
    end
    
    table.insert(self.Tabs, Tab)
    
    -- Активировать первую вкладку
    if not self.CurrentTab then
        Tab:Activate()
    end
    
    return Tab
end

-- ====================================================================
-- ФУНКЦИИ ЧИТ-МЕНЮ
-- ====================================================================

local CheatFunctions = {}

-- Улучшенная функция для поиска параметров оружия
local function FindWeaponValue(tool, names, valueType)
    local searchPaths = {
        tool,
        tool:FindFirstChild("Configurations"),
        tool:FindFirstChild("Config"),
        tool:FindFirstChild("Settings"),
        tool:FindFirstChild("Stats"),
        tool:FindFirstChild("Handle"),
        tool:FindFirstChild("GunScript"),
        tool:FindFirstChild("WeaponScript"),
        tool:FindFirstChild("ModuleScript"),
        tool:FindFirstChild("LocalScript")
    }
    
    for _, path in pairs(searchPaths) do
        if path then
            for _, name in pairs(names) do
                local found = path:FindFirstChild(name)
                if found then
                    if valueType == "number" and (found:IsA("NumberValue") or found:IsA("IntValue") or found:IsA("IntConstrainedValue")) then
                        return found
                    elseif valueType == "script" and found:IsA("ModuleScript") then
                        return found
                    elseif valueType == "any" then
                        return found
                    end
                end
            end
        end
    end
    return nil
end

-- === ДВИЖЕНИЕ ===

function CheatFunctions.SpeedHack(enabled)
    if enabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            savedValues.WalkSpeed = char.Humanoid.WalkSpeed
            char.Humanoid.WalkSpeed = savedValues.WalkSpeed * Config.SpeedMultiplier
        end
    else
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") and savedValues.WalkSpeed then
            char.Humanoid.WalkSpeed = savedValues.WalkSpeed
        end
    end
end

function CheatFunctions.Flight(enabled)
    if enabled then
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local BV = Instance.new("BodyVelocity")
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BV.Velocity = Vector3.zero
        BV.Parent = char.HumanoidRootPart
        savedValues.FlightBV = BV
        
        activeConnections.Flight = RunService.Heartbeat:Connect(function()
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            local direction = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += char.HumanoidRootPart.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= char.HumanoidRootPart.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= char.HumanoidRootPart.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += char.HumanoidRootPart.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= Vector3.new(0, 1, 0) end
            
            BV.Velocity = direction.Unit * Config.FlightSpeed
        end)
    else
        if activeConnections.Flight then
            activeConnections.Flight:Disconnect()
            activeConnections.Flight = nil
        end
        if savedValues.FlightBV then
            savedValues.FlightBV:Destroy()
            savedValues.FlightBV = nil
        end
    end
end

function CheatFunctions.JumpPower(enabled)
    if enabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            savedValues.JumpPower = char.Humanoid.JumpPower
            char.Humanoid.JumpPower = savedValues.JumpPower * Config.JumpMultiplier
        end
    else
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") and savedValues.JumpPower then
            char.Humanoid.JumpPower = savedValues.JumpPower
        end
    end
end

function CheatFunctions.InfiniteJump(enabled)
    if enabled then
        activeConnections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if activeConnections.InfiniteJump then
            activeConnections.InfiniteJump:Disconnect()
            activeConnections.InfiniteJump = nil
        end
    end
end

function CheatFunctions.Noclip(enabled)
    if enabled then
        activeConnections.Noclip = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if activeConnections.Noclip then
            activeConnections.Noclip:Disconnect()
            activeConnections.Noclip = nil
        end
    end
end

function CheatFunctions.ClickTeleport(enabled)
    if enabled then
        activeConnections.ClickTP = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                local mouse = LocalPlayer:GetMouse()
                local target = mouse.Hit.Position
                
                char.HumanoidRootPart.CFrame = CFrame.new(target + Vector3.new(0, 3, 0))
                
                local part = Instance.new("Part")
                part.Size = Vector3.new(2, 2, 2)
                part.Position = target
                part.Anchored = true
                part.CanCollide = false
                part.Material = Enum.Material.Neon
                part.BrickColor = BrickColor.new("Bright violet")
                part.Parent = workspace
                
                local pointLight = Instance.new("PointLight")
                pointLight.Brightness = 10
                pointLight.Range = 15
                pointLight.Color = Color3.new(0.5, 0, 1)
                pointLight.Parent = part
                
                game:GetService("Debris"):AddItem(part, 1)
            end
        end)
        print("✓ Click TP включен - кликните ЛКМ для телепортации")
    else
        if activeConnections.ClickTP then
            activeConnections.ClickTP:Disconnect()
            activeConnections.ClickTP = nil
            print("✕ Click TP отключен")
        end
    end
end

function CheatFunctions.ChangeGravity(value)
    Config.GravityValue = value
    workspace.Gravity = value
    print("🌍 Гравитация установлена: " .. value)
end

function CheatFunctions.ResetGravity()
    local defaultGravity = 196.2
    Config.GravityValue = defaultGravity
    workspace.Gravity = defaultGravity
    print("🔄 Гравитация сброшена к стандартной: " .. defaultGravity)
end

function CheatFunctions.LowGravity()
    Config.GravityValue = 50
    workspace.Gravity = 50
    print("⬇️ Низкая гравитация: 50")
end

function CheatFunctions.ZeroGravity()
    Config.GravityValue = 0
    workspace.Gravity = 0
    print("🚀 Нулевая гравитация: 0")
end

function CheatFunctions.HighGravity()
    Config.GravityValue = 500
    workspace.Gravity = 500
    print("⬆️ Высокая гравитация: 500")
end

-- === ВИЗУАЛЫ ===

local lastESPUpdate = 0

function CheatFunctions.ESP(enabled)
    if enabled then
        activeConnections.ESP = RunService.RenderStepped:Connect(function()
            local currentTime = tick()
            
            if currentTime - lastESPUpdate < 2 then
                return
            end
            
            lastESPUpdate = currentTime
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if not espData[player] then
                        espData[player] = {}
                    end
                    
                    local char = player.Character
                    local root = char.HumanoidRootPart
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    
                    local color = Config.ESPEnemyColor
                    if Teams and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                        color = Config.ESPTeamColor
                    end
                    
                    if not espData[player].Box then
                        local box = Instance.new("BillboardGui")
                        box.Size = UDim2.new(4, 0, 5, 0)
                        box.AlwaysOnTop = true
                        box.Parent = root
                        
                        local frame = Instance.new("Frame")
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        frame.BackgroundTransparency = 1
                        frame.BorderSizePixel = 2
                        frame.BorderColor3 = color
                        frame.Parent = box
                        
                        espData[player].Box = box
                    else
                        espData[player].Box.Frame.BorderColor3 = color
                    end
                    
                    if not espData[player].Name then
                        local nameTag = Instance.new("BillboardGui")
                        nameTag.Size = UDim2.new(0, 200, 0, 50)
                        nameTag.StudsOffset = Vector3.new(0, 3, 0)
                        nameTag.AlwaysOnTop = true
                        nameTag.Parent = root
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = player.Name
                        label.TextColor3 = color
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 14
                        label.TextStrokeTransparency = 0.5
                        label.Parent = nameTag
                        
                        espData[player].Name = nameTag
                    else
                        espData[player].Name.TextLabel.TextColor3 = color
                    end
                    
                    if humanoid and not espData[player].Health then
                        local healthBar = Instance.new("BillboardGui")
                        healthBar.Size = UDim2.new(0, 50, 0, 4)
                        healthBar.StudsOffset = Vector3.new(0, 2.5, 0)
                        healthBar.AlwaysOnTop = true
                        healthBar.Parent = root
                        
                        local bg = Instance.new("Frame")
                        bg.Size = UDim2.new(1, 0, 1, 0)
                        bg.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
                        bg.Parent = healthBar
                        
                        local fill = Instance.new("Frame")
                        fill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                        fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        fill.BorderSizePixel = 0
                        fill.Parent = bg
                        
                        espData[player].Health = healthBar
                    elseif humanoid and espData[player].Health then
                        local fill = espData[player].Health.Frame.Frame
                        fill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                    end
                end
            end
        end)
    else
        if activeConnections.ESP then
            activeConnections.ESP:Disconnect()
            activeConnections.ESP = nil
        end
        
        for player, data in pairs(espData) do
            for _, obj in pairs(data) do
                if obj and obj.Parent then
                    obj:Destroy()
                end
            end
        end
        espData = {}
    end
end

function CheatFunctions.GlowESP(enabled)
    if enabled then
        activeConnections.GlowESP = RunService.RenderStepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not espData[player] then
                        espData[player] = {}
                    end
                    
                    local color = Config.ESPEnemyColor
                    if Teams and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                        color = Config.ESPTeamColor
                    end
                    
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not espData[player][part] then
                                local highlight = Instance.new("Highlight")
                                highlight.FillColor = color
                                highlight.OutlineColor = color
                                highlight.FillTransparency = 0.5
                                highlight.OutlineTransparency = 0
                                highlight.Parent = part
                                espData[player][part] = highlight
                            else
                                espData[player][part].FillColor = color
                                espData[player][part].OutlineColor = color
                            end
                        end
                    end
                end
            end
        end)
    else
        if activeConnections.GlowESP then
            activeConnections.GlowESP:Disconnect()
            activeConnections.GlowESP = nil
        end
        
        for player, data in pairs(espData) do
            for _, obj in pairs(data) do
                if obj and obj.Parent then
                    obj:Destroy()
                end
            end
        end
        espData = {}
    end
end

function CheatFunctions.Fullbright(enabled)
    if enabled then
        savedValues.Ambient = Lighting.Ambient
        savedValues.Brightness = Lighting.Brightness
        savedValues.OutdoorAmbient = Lighting.OutdoorAmbient
        
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = savedValues.Ambient or Color3.fromRGB(138, 138, 138)
        Lighting.Brightness = savedValues.Brightness or 1
        Lighting.OutdoorAmbient = savedValues.OutdoorAmbient or Color3.fromRGB(138, 138, 138)
    end
end

function CheatFunctions.NightMode(enabled)
    if enabled then
        savedValues.TimeOfDay = Lighting.TimeOfDay
        savedValues.NightAmbient = Lighting.Ambient
        savedValues.NightOutdoorAmbient = Lighting.OutdoorAmbient
        
        Lighting.TimeOfDay = "00:00:00"
        Lighting.Ambient = Config.NightAmbient
        Lighting.OutdoorAmbient = Config.NightAmbient
        Lighting.FogEnd = 100000
    else
        Lighting.TimeOfDay = savedValues.TimeOfDay or "14:00:00"
        Lighting.Ambient = savedValues.NightAmbient or Color3.fromRGB(138, 138, 138)
        Lighting.OutdoorAmbient = savedValues.NightOutdoorAmbient or Color3.fromRGB(138, 138, 138)
    end
end

function CheatFunctions.DeleteSky(enabled)
    if enabled then
        savedValues.Sky = Lighting:FindFirstChildOfClass("Sky")
        if savedValues.Sky then
            savedValues.Sky.Parent = nil
        end
        
        savedValues.Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if savedValues.Atmosphere then
            savedValues.Atmosphere.Parent = nil
        end
        
        savedValues.Clouds = workspace:FindFirstChildOfClass("Clouds")
        if savedValues.Clouds then
            savedValues.Clouds.Parent = nil
        end
    else
        if savedValues.Sky then
            savedValues.Sky.Parent = Lighting
        end
        if savedValues.Atmosphere then
            savedValues.Atmosphere.Parent = Lighting
        end
        if savedValues.Clouds then
            savedValues.Clouds.Parent = workspace
        end
    end
end

function CheatFunctions.FOVChanger(enabled)
    if enabled then
        savedValues.FOV = Camera.FieldOfView
        Camera.FieldOfView = Config.FOVValue
    else
        Camera.FieldOfView = savedValues.FOV or 70
    end
end

-- === БОЕВЫЕ ===

local FOVCircle
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 64
    FOVCircle.Radius = Config.AimbotFOV
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = false
else
    warn("Drawing library not available - FOV Circle disabled")
end

function CheatFunctions.ShowFOV(enabled)
    if not FOVCircle then return end
    
    FOVCircle.Visible = enabled
    if enabled then
        activeConnections.FOVCircle = RunService.RenderStepped:Connect(function()
            local viewportSize = Camera.ViewportSize
            FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            FOVCircle.Radius = Config.AimbotFOV
            FOVCircle.Color = Config.AccentColor
        end)
    else
        if activeConnections.FOVCircle then
            activeConnections.FOVCircle:Disconnect()
            activeConnections.FOVCircle = nil
        end
    end
end

function CheatFunctions.Aimbot(enabled)
    if enabled then
        activeConnections.Aimbot = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                return
            end
            
            local nearestPlayer = nil
            local shortestDistance = math.huge
            local viewportSize = Camera.ViewportSize
            local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    
                    if head and humanoid and humanoid.Health > 0 then
                        if Teams and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
                            continue
                        end
                        
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        
                        if onScreen then
                            local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
                            local distanceFromCenter = (screenPoint - screenCenter).Magnitude
                            
                            if distanceFromCenter <= Config.AimbotFOV and distanceFromCenter < shortestDistance then
                                local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1000)
                                local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                                
                                if hit and hit:IsDescendantOf(player.Character) then
                                    nearestPlayer = head
                                    shortestDistance = distanceFromCenter
                                end
                            end
                        end
                    end
                end
            end
            
            if nearestPlayer then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, nearestPlayer.Position)
                local smoothness = math.clamp(Config.AimbotSmoothness, 0.05, 1)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
            end
        end)
    else
        if activeConnections.Aimbot then
            activeConnections.Aimbot:Disconnect()
            activeConnections.Aimbot = nil
        end
    end
end

-- Улучшенный TriggerBot для всех оружий
function CheatFunctions.TriggerBot(enabled)
    if enabled then
        activeConnections.TriggerBot = RunService.RenderStepped:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            if not mouse.Target then return end
            
            local target = mouse.Target
            local character = target.Parent

            if character and character:FindFirstChild("Humanoid") then
                local player = Players:GetPlayerFromCharacter(character)
                
                if player and player ~= LocalPlayer then
                    if Teams and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
                        return
                    end
                    
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        mouse1click()
                        task.wait(Config.TriggerBotDelay)
                    end
                end
            end
        end)
        print("✓ TriggerBot включен для всех оружий")
    else
        if activeConnections.TriggerBot then
            activeConnections.TriggerBot:Disconnect()
            activeConnections.TriggerBot = nil
            print("✕ TriggerBot отключен")
        end
    end
end

-- Улучшенный RapidFire для всех оружий
function CheatFunctions.RapidFire(enabled)
    if enabled then
        activeConnections.RapidFire = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                local delayNames = {
                    "Cooldown", "FireRate", "FireDelay", "Delay", "ReloadTime", 
                    "AttackSpeed", "AttackDelay", "ShotDelay", "FireCooldown",
                    "AutoFireDelay", "BurstDelay", "ShootDelay"
                }
                
                for _, name in pairs(delayNames) do
                    local delayValue = FindWeaponValue(tool, {name}, "number")
                    if delayValue then
                        delayValue.Value = Config.RapidFireSpeed
                    end
                end
            end
        end)
        print("✓ RapidFire включен для всех оружий")
    else
        if activeConnections.RapidFire then
            activeConnections.RapidFire:Disconnect()
            activeConnections.RapidFire = nil
            print("✕ RapidFire отключен")
        end
    end
end

function CheatFunctions.SilentAim(enabled)
    if enabled then
        print("⚠️ Silent Aim включен")
        
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "FindPartOnRayWithIgnoreList" and savedValues.SilentTarget then
                local origin = args[1].Origin
                local direction = (savedValues.SilentTarget.Position - origin).Unit
                local newRay = Ray.new(origin, direction * 1000)
                
                args[1] = newRay
                return oldNamecall(self, unpack(args))
            end
            
            return oldNamecall(self, ...)
        end)
        
        savedValues.SilentAimHook = oldNamecall
        
        activeConnections.SilentAim = RunService.RenderStepped:Connect(function()
            local nearestPlayer = nil
            local shortestDistance = math.huge
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    
                    if head and humanoid and humanoid.Health > 0 then
                        if Teams and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
                            continue
                        end
                        
                        local distance = (Camera.CFrame.Position - head.Position).Magnitude
                        if distance < 500 and distance < shortestDistance then
                            nearestPlayer = head
                            shortestDistance = distance
                        end
                    end
                end
            end
            
            savedValues.SilentTarget = nearestPlayer
        end)
    else
        if activeConnections.SilentAim then
            activeConnections.SilentAim:Disconnect()
            activeConnections.SilentAim = nil
        end
        
        if savedValues.SilentAimHook then
            hookmetamethod(game, "__namecall", savedValues.SilentAimHook)
            savedValues.SilentAimHook = nil
        end
        
        savedValues.SilentTarget = nil
        print("✕ Silent Aim отключен")
    end
end

function CheatFunctions.InfiniteAmmo(enabled)
    if enabled then
        activeConnections.InfiniteAmmo = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                local ammoNames = {
                    "Ammo", "CurrentAmmo", "Magazine", "Clip", "Bullets", 
                    "CurrentMagazine", "MagazineAmmo", "MaxAmmo", "AmmoCount",
                    "BulletCount", "Shells", "Rounds"
                }
                
                for _, name in pairs(ammoNames) do
                    local ammoValue = FindWeaponValue(tool, {name}, "number")
                    if ammoValue then
                        if name:lower():find("max") or name:lower():find("magazine") then
                            ammoValue.Value = 999
                        else
                            ammoValue.Value = 999
                        end
                    end
                end
            end
        end)
    else
        if activeConnections.InfiniteAmmo then
            activeConnections.InfiniteAmmo:Disconnect()
            activeConnections.InfiniteAmmo = nil
        end
    end
end

function CheatFunctions.NoRecoil(enabled)
    if enabled then
        activeConnections.NoRecoil = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                local recoilNames = {
                    "Recoil", "RecoilControl", "RecoilAmount", "Kickback", 
                    "CameraRecoil", "VerticalRecoil", "HorizontalRecoil",
                    "RecoilX", "RecoilY", "RecoilZ", "GunKick"
                }
                
                for _, name in pairs(recoilNames) do
                    local recoilValue = FindWeaponValue(tool, {name}, "number")
                    if recoilValue then
                        recoilValue.Value = 0
                    end
                end
                
                if Camera:FindFirstChild("CameraShake") then
                    Camera.CameraShake:Destroy()
                end
            end
        end)
    else
        if activeConnections.NoRecoil then
            activeConnections.NoRecoil:Disconnect()
            activeConnections.NoRecoil = nil
        end
    end
end

function CheatFunctions.NoSpread(enabled)
    if enabled then
        activeConnections.NoSpread = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                local spreadNames = {"Spread", "Accuracy", "Inaccuracy", "Deviation", "BulletSpread"}
                
                for _, name in pairs(spreadNames) do
                    local spreadValue = FindWeaponValue(tool, {name}, "number")
                    if spreadValue then
                        if name:lower():find("accuracy") then
                            spreadValue.Value = 100
                        else
                            spreadValue.Value = 0
                        end
                    end
                end
            end
        end)
    else
        if activeConnections.NoSpread then
            activeConnections.NoSpread:Disconnect()
            activeConnections.NoSpread = nil
        end
    end
end

function CheatFunctions.InstantHit(enabled)
    if enabled then
        activeConnections.InstantHit = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                local speedNames = {
                    "BulletSpeed", "ProjectileSpeed", "Speed", "Velocity", 
                    "MuzzleVelocity", "ShotSpeed", "BulletVelocity"
                }
                
                for _, name in pairs(speedNames) do
                    local speedValue = FindWeaponValue(tool, {name}, "number")
                    if speedValue then
                        speedValue.Value = 10000
                    end
                end
            end
        end)
    else
        if activeConnections.InstantHit then
            activeConnections.InstantHit:Disconnect()
            activeConnections.InstantHit = nil
        end
    end
end

function CheatFunctions.AntiCooldown(enabled)
    if enabled then
        print("⚡ AntiCooldown включен")
        
        activeConnections.AntiCooldown = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    CheatFunctions.RemoveToolCooldowns(tool)
                end
            end
            
            local equippedTool = char:FindFirstChildOfClass("Tool")
            if equippedTool then
                CheatFunctions.RemoveToolCooldowns(equippedTool)
            end
        end)
    else
        if activeConnections.AntiCooldown then
            activeConnections.AntiCooldown:Disconnect()
            activeConnections.AntiCooldown = nil
            print("✕ AntiCooldown отключен")
        end
    end
end

function CheatFunctions.RemoveToolCooldowns(tool)
    if not tool then return end
    
    local cooldownNames = {
        "Cooldown", "FireRate", "FireDelay", "Delay", "ReloadTime", 
        "AttackSpeed", "AttackDelay", "ShotDelay", "FireCooldown",
        "AutoFireDelay", "BurstDelay", "ShootDelay", "CooldownTime"
    }
    
    for _, name in pairs(cooldownNames) do
        local cooldownValue = FindWeaponValue(tool, {name}, "number")
        if cooldownValue then
            cooldownValue.Value = 0
        end
    end
    
    for _, gui in pairs(tool:GetDescendants()) do
        if gui:IsA("GuiObject") and (gui.Name:lower():find("cooldown") or gui.Name:lower():find("reload")) then
            gui.Visible = false
        end
    end
end

function CheatFunctions.KillAura(enabled)
    if enabled then
        activeConnections.KillAura = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and root and humanoid.Health > 0 then
                        if Teams and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
                            continue
                        end
                        
                        local distance = (char.HumanoidRootPart.Position - root.Position).Magnitude
                        
                        if distance < 20 then
                            tool:Activate()
                            
                            pcall(function()
                                humanoid:TakeDamage(humanoid.MaxHealth)
                            end)
                            
                            task.wait(0.05)
                        end
                    end
                end
            end
        end)
    else
        if activeConnections.KillAura then
            activeConnections.KillAura:Disconnect()
            activeConnections.KillAura = nil
        end
    end
end

function CheatFunctions.AutoParry(enabled)
    if enabled then
        activeConnections.AutoParry = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    
                    if root and tool then
                        local distance = (char.HumanoidRootPart.Position - root.Position).Magnitude
                        
                        if distance < 15 then
                            local myTool = char:FindFirstChildOfClass("Tool")
                            if myTool then
                                if myTool:FindFirstChild("Block") then
                                    pcall(function()
                                        myTool.Block:Fire()
                                    end)
                                end
                                
                                myTool:Activate()
                            end
                            
                            task.wait(0.1)
                        end
                    end
                end
            end
        end)
    else
        if activeConnections.AutoParry then
            activeConnections.AutoParry:Disconnect()
            activeConnections.AutoParry = nil
        end
    end
end

-- === ЗАЩИТА ===

function CheatFunctions.GodMode(enabled)
    if enabled then
        print("🛡️ Включение God Mode...")
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            savedValues.GodModeMaxHealth = humanoid.MaxHealth
            savedValues.GodModeHealth = humanoid.Health
            
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
        
        local ff = Instance.new("ForceField")
        ff.Visible = false
        ff.Parent = char
        savedValues.GodModeForceField = ff
        
        savedValues.GodModeConnections = {}
        
        local function preventDamage(part)
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Material = Enum.Material.Neon
                part.Transparency = 0.7
            end
        end
        
        for _, part in pairs(char:GetDescendants()) do
            preventDamage(part)
        end
        
        table.insert(savedValues.GodModeConnections, char.DescendantAdded:Connect(preventDamage))
        
        table.insert(savedValues.GodModeConnections, game:GetService("ReplicatedStorage").ChildAdded:Connect(function(child)
            if child:IsA("RemoteEvent") and (child.Name:lower():find("damage") or child.Name:lower():find("hit")) then
                local oldFire = child.FireServer
                child.FireServer = function(self, ...)
                    local args = {...}
                    if args[1] == LocalPlayer or (args[2] and args[2] == LocalPlayer) then
                        print("🚫 Заблокирован урон через " .. child.Name)
                        return nil
                    end
                    return oldFire(self, ...)
                end
            end
        end))
        
        table.insert(savedValues.GodModeConnections, RunService.Heartbeat:Connect(function()
            if char and char:FindFirstChildOfClass("Humanoid") then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                
                if humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
                
                if humanoid:GetState() == Enum.HumanoidStateType.Dead then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end))
        
        pcall(function()
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part:SetNetworkOwner(nil)
                end
            end
        end)
        
        print("✅ God Mode включен")
        
    else
        print("🛡️ Отключение God Mode...")
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if savedValues.GodModeMaxHealth then
                humanoid.MaxHealth = savedValues.GodModeMaxHealth
            end
            if savedValues.GodModeHealth then
                humanoid.Health = math.min(humanoid.Health, humanoid.MaxHealth)
            end
        end
        
        if savedValues.GodModeForceField then
            savedValues.GodModeForceField:Destroy()
            savedValues.GodModeForceField = nil
        end
        
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.Material = Enum.Material.Plastic
                    part.Transparency = 0
                end
            end
        end
        
        if savedValues.GodModeConnections then
            for _, connection in pairs(savedValues.GodModeConnections) do
                connection:Disconnect()
            end
            savedValues.GodModeConnections = {}
        end
        
        pcall(function()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part:SetNetworkOwner(LocalPlayer)
                    end
                end
            end
        end)
        
        print("✕ God Mode отключен")
    end
end

function CheatFunctions.SuperGodMode(enabled)
    if enabled then
        print("🌟 Включение Super God Mode...")
        
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "FireServer" or method == "InvokeServer" then
                local name = tostring(self):lower()
                if name:find("damage") or name:find("hit") or name:find("kill") or name:find("death") then
                    for _, arg in pairs(args) do
                        if arg == LocalPlayer or (type(arg) == "string" and arg:lower():find(LocalPlayer.Name:lower())) then
                            print("🚫 Заблокирован урон через " .. name)
                            return nil
                        end
                    end
                end
            end
            
            return oldNamecall(self, ...)
        end)
        
        savedValues.SuperGodHook = oldNamecall
        
        savedValues.SuperGodConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                
                humanoid.Health = humanoid.MaxHealth
                
                if humanoid.Health <= 0 then
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end)
        
        print("✅ Super God Mode включен")
        
    else
        print("🌟 Отключение Super God Mode...")
        
        if savedValues.SuperGodHook then
            hookmetamethod(game, "__namecall", savedValues.SuperGodHook)
            savedValues.SuperGodHook = nil
        end
        
        if savedValues.SuperGodConnection then
            savedValues.SuperGodConnection:Disconnect()
            savedValues.SuperGodConnection = nil
        end
        
        print("✕ Super God Mode отключен")
    end
end

function CheatFunctions.AntiAFK(enabled)
    if enabled then
        activeConnections.AntiAFK = RunService.Heartbeat:Connect(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    else
        if activeConnections.AntiAFK then
            activeConnections.AntiAFK:Disconnect()
            activeConnections.AntiAFK = nil
        end
    end
end

function CheatFunctions.AntiRagdoll(enabled)
    if enabled then
        activeConnections.AntiRagdoll = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                if char:FindFirstChild("Ragdolled") then
                    char.Ragdolled:Destroy()
                end
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
                        v:Destroy()
                    end
                end
            end
        end)
    else
        if activeConnections.AntiRagdoll then
            activeConnections.AntiRagdoll:Disconnect()
            activeConnections.AntiRagdoll = nil
        end
    end
end

function CheatFunctions.AntiStun(enabled)
    if enabled then
        activeConnections.AntiStun = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.PlatformStand = false
            end
        end)
    else
        if activeConnections.AntiStun then
            activeConnections.AntiStun:Disconnect()
            activeConnections.AntiStun = nil
        end
    end
end

function CheatFunctions.AntiSlow(enabled)
    if enabled then
        activeConnections.AntiSlow = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                if savedValues.WalkSpeed and char.Humanoid.WalkSpeed < savedValues.WalkSpeed then
                    char.Humanoid.WalkSpeed = savedValues.WalkSpeed
                end
            end
        end)
    else
        if activeConnections.AntiSlow then
            activeConnections.AntiSlow:Disconnect()
            activeConnections.AntiSlow = nil
        end
    end
end

function CheatFunctions.AutoHeal(enabled)
    if enabled then
        activeConnections.AutoHeal = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                if char.Humanoid.Health < char.Humanoid.MaxHealth * 0.5 then
                    char.Humanoid.Health = char.Humanoid.MaxHealth
                end
            end
        end)
    else
        if activeConnections.AutoHeal then
            activeConnections.AutoHeal:Disconnect()
            activeConnections.AutoHeal = nil
        end
    end
end

function CheatFunctions.InfiniteStamina(enabled)
    if enabled then
        activeConnections.InfiniteStamina = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v.Name == "Stamina" and v:IsA("NumberValue") then
                        v.Value = 100
                    end
                end
            end
        end)
    else
        if activeConnections.InfiniteStamina then
            activeConnections.InfiniteStamina:Disconnect()
            activeConnections.InfiniteStamina = nil
        end
    end
end

function CheatFunctions.RemoveDebuffs(enabled)
    if enabled then
        activeConnections.RemoveDebuffs = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, effect in pairs(char:GetDescendants()) do
                    if effect.Name:lower():find("debuff") or 
                       effect.Name:lower():find("slow") or 
                       effect.Name:lower():find("stun") or
                       effect.Name:lower():find("poison") or
                       effect.Name:lower():find("burn") then
                        effect:Destroy()
                    end
                end
            end
        end)
    else
        if activeConnections.RemoveDebuffs then
            activeConnections.RemoveDebuffs:Disconnect()
            activeConnections.RemoveDebuffs = nil
        end
    end
end

function CheatFunctions.AntiKnockback(enabled)
    if enabled then
        activeConnections.AntiKnockback = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                char.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if activeConnections.AntiKnockback then
            activeConnections.AntiKnockback:Disconnect()
            activeConnections.AntiKnockback = nil
        end
    end
end

function CheatFunctions.ForceField(enabled)
    if enabled then
        local char = LocalPlayer.Character
        if char then
            local ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = char
            savedValues.ForceField = ff
        end
    else
        if savedValues.ForceField then
            savedValues.ForceField:Destroy()
            savedValues.ForceField = nil
        end
    end
end

function CheatFunctions.Invisibility(enabled)
    if enabled then
        local char = LocalPlayer.Character
        if char then
            savedValues.OriginalTransparency = {}
            
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    savedValues.OriginalTransparency[part] = part.Transparency
                    part.Transparency = 1
                elseif part:IsA("Decal") then
                    savedValues.OriginalTransparency[part] = part.Transparency
                    part.Transparency = 1
                end
            end
            
            if char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CastShadow = false
            end
            
            local effectPart = Instance.new("Part")
            effectPart.Size = Vector3.new(4, 4, 4)
            effectPart.Position = char.HumanoidRootPart.Position
            effectPart.Anchored = true
            effectPart.CanCollide = false
            effectPart.Material = Enum.Material.Neon
            effectPart.BrickColor = BrickColor.new("Institutional white")
            effectPart.Transparency = 0.7
            effectPart.Parent = workspace
            
            local pointLight = Instance.new("PointLight")
            pointLight.Brightness = 3
            pointLight.Range = 10
            pointLight.Color = Color3.new(1, 1, 1)
            pointLight.Parent = effectPart
            
            savedValues.InvisibilityEffect = effectPart
            
            activeConnections.Invisibility = RunService.Heartbeat:Connect(function()
                if char and char:FindFirstChild("HumanoidRootPart") then
                    effectPart.Position = char.HumanoidRootPart.Position
                end
            end)
            
            print("✓ Невидимость включена")
        end
    else
        local char = LocalPlayer.Character
        if char and savedValues.OriginalTransparency then
            for part, transparency in pairs(savedValues.OriginalTransparency) do
                if part and part.Parent then
                    part.Transparency = transparency
                end
            end
            
            if char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CastShadow = true
            end
            
            if savedValues.InvisibilityEffect then
                savedValues.InvisibilityEffect:Destroy()
                savedValues.InvisibilityEffect = nil
            end
            
            if activeConnections.Invisibility then
                activeConnections.Invisibility:Disconnect()
                activeConnections.Invisibility = nil
            end
            
            print("✕ Невидимость отключена")
        end
    end
end

-- === РЕСУРСЫ ===
function CheatFunctions.ShowMoneyEffect(amount)
    if not LocalPlayer.Character then return end
    
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        for i = 1, 8 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.3, 0.3, 0.3)
            part.Position = root.Position + Vector3.new(math.random(-4, 4), math.random(1, 4), math.random(-4, 4))
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.new("Bright green")
            part.Parent = workspace
            
            local pointLight = Instance.new("PointLight")
            pointLight.Brightness = 3
            pointLight.Range = 8
            pointLight.Color = Color3.new(0, 1, 0)
            pointLight.Parent = part
            
            game:GetService("Debris"):AddItem(part, 2)
        end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.Adornee = root
        billboard.Parent = root
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "+" .. amount .. " 💵"
        textLabel.TextColor3 = Color3.new(0, 1, 0)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 20
        textLabel.TextStrokeTransparency = 0.5
        textLabel.Parent = billboard
        
        spawn(function()
            for i = 1, 25 do
                billboard.StudsOffset = Vector3.new(0, 2 + i * 0.15, 0)
                textLabel.TextTransparency = i / 25
                wait(0.05)
            end
            billboard:Destroy()
        end)
    end
end

function CheatFunctions.AddMoney(amount)
    local amount = amount or Config.MoneyAmount
    print("💰 Попытка добавить деньги:", amount)
    
    local moneyLocations = {
        LocalPlayer,
        LocalPlayer.Character,
        workspace,
        game:GetService("ReplicatedStorage"),
        game:GetService("ServerStorage")
    }
    
    local moneyNames = {
        "Money", "Cash", "Coins", "Gold", "Points", "Credits", "Dollars",
        "Currency", "Funds", "Balance", "Wallet", "Bank"
    }
    
    for _, location in pairs(moneyLocations) do
        if location then
            for _, moneyName in pairs(moneyNames) do
                local moneyValue = location:FindFirstChild(moneyName)
                if moneyValue and (moneyValue:IsA("NumberValue") or moneyValue:IsA("IntValue")) then
                    moneyValue.Value = moneyValue.Value + amount
                    print("✅ Добавлено денег (" .. moneyName .. "): " .. amount)
                end
                
                for _, child in pairs(location:GetDescendants()) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                        for _, name in pairs(moneyNames) do
                            if child.Name:lower():find(name:lower()) then
                                child.Value = child.Value + amount
                                print("✅ Добавлено денег (" .. child.Name .. "): " .. amount)
                            end
                        end
                    end
                end
            end
        end
    end
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("money") or name:find("cash") or name:find("coin") then
                pcall(function()
                    obj:FireServer(amount)
                    print("✅ Отправлен запрос через RemoteEvent: " .. obj.Name)
                end)
            end
        end
    end
    
    CheatFunctions.ShowMoneyEffect(amount)
end

function CheatFunctions.ShowCashEffect(amount)
    if not LocalPlayer.Character then return end
    
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        for i = 1, 6 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.4, 0.4, 0.4)
            part.Position = root.Position + Vector3.new(math.random(-3, 3), math.random(2, 5), math.random(-3, 3))
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.new("Bright yellow")
            part.Parent = workspace
            
            local pointLight = Instance.new("PointLight")
            pointLight.Brightness = 4
            pointLight.Range = 9
            pointLight.Color = Color3.new(1, 1, 0)
            pointLight.Parent = part
            
            game:GetService("Debris"):AddItem(part, 2)
        end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Adornee = root
        billboard.Parent = root
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "+" .. amount .. " 💰"
        textLabel.TextColor3 = Color3.new(1, 1, 0)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 22
        textLabel.TextStrokeTransparency = 0.5
        textLabel.Parent = billboard
        
        spawn(function()
            for i = 1, 25 do
                billboard.StudsOffset = Vector3.new(0, 2.5 + i * 0.15, 0)
                textLabel.TextTransparency = i / 25
                wait(0.05)
            end
            billboard:Destroy()
        end)
    end
end

function CheatFunctions.AddCash(amount)
    local amount = amount or Config.CashAmount
    print("💰 Попытка добавить Cash:", amount)
    
    local cashNames = {
        "Cash", "Money", "Coins", "Bucks", "Dollars", "Funds",
        "Currency", "Bank", "Wallet", "Balance"
    }
    
    for _, cashName in pairs(cashNames) do
        local cashValue = LocalPlayer:FindFirstChild(cashName)
        if cashValue and (cashValue:IsA("NumberValue") or cashValue:IsA("IntValue")) then
            cashValue.Value = cashValue.Value + amount
            print("✅ Добавлено Cash (" .. cashName .. "): " .. amount)
        end
        
        if LocalPlayer.Character then
            local charCash = LocalPlayer.Character:FindFirstChild(cashName)
            if charCash and (charCash:IsA("NumberValue") or charCash:IsA("IntValue")) then
                charCash.Value = charCash.Value + amount
                print("✅ Добавлено Cash (" .. cashName .. "): " .. amount)
            end
        end
    end
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("cash") or name:find("money") or name:find("coin") then
                pcall(function()
                    obj:FireServer(amount)
                    print("✅ Отправлен запрос Cash через RemoteEvent: " .. obj.Name)
                end)
            end
        elseif obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("cash") or name:find("money") then
                pcall(function()
                    obj:InvokeServer(amount)
                    print("✅ Отправлен запрос Cash через RemoteFunction: " .. obj.Name)
                end)
            end
        end
    end
    
    CheatFunctions.ShowCashEffect(amount)
end

function CheatFunctions.ShowGemEffect(amount)
    if not LocalPlayer.Character then return end
    
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        for i = 1, 5 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.5, 0.5, 0.5)
            part.Position = root.Position + Vector3.new(math.random(-3, 3), math.random(2, 5), math.random(-3, 3))
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.new("Bright blue")
            part.Parent = workspace
            
            local pointLight = Instance.new("PointLight")
            pointLight.Brightness = 5
            pointLight.Range = 10
            pointLight.Color = Color3.new(0, 0.5, 1)
            pointLight.Parent = part
            
            game:GetService("Debris"):AddItem(part, 2)
        end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = root
        billboard.Parent = root
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "+" .. amount .. " 💎"
        textLabel.TextColor3 = Color3.new(0, 0.5, 1)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 24
        textLabel.TextStrokeTransparency = 0.5
        textLabel.Parent = billboard
        
        spawn(function()
            for i = 1, 30 do
                billboard.StudsOffset = Vector3.new(0, 3 + i * 0.1, 0)
                textLabel.TextTransparency = i / 30
                wait(0.05)
            end
            billboard:Destroy()
        end)
    end
end

function CheatFunctions.AddGems(amount)
    local amount = amount or Config.GemAmount
    print("💎 Попытка добавить гемы:", amount)
    
    local gemNames = {
        "Gems", "Gem", "Robux", "PremiumCurrency", "Premium", 
        "Diamonds", "Diamond", "Crystals", "Crystal", "Tokens"
    }
    
    for _, gemName in pairs(gemNames) do
        local gemValue = LocalPlayer:FindFirstChild(gemName)
        if gemValue and (gemValue:IsA("NumberValue") or gemValue:IsA("IntValue")) then
            gemValue.Value = gemValue.Value + amount
            print("✅ Добавлено гемов (" .. gemName .. "): " .. amount)
        end
        
        if LocalPlayer.Character then
            local charGem = LocalPlayer.Character:FindFirstChild(gemName)
            if charGem and (charGem:IsA("NumberValue") or charGem:IsA("IntValue")) then
                charGem.Value = charGem.Value + amount
                print("✅ Добавлено гемов (" .. gemName .. "): " .. amount)
            end
        end
    end
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("gem") or name:find("premium") or name:find("robux") or name:find("diamond") then
                pcall(function()
                    obj:FireServer(amount)
                    print("✅ Отправлен запрос гемов через RemoteEvent: " .. obj.Name)
                end)
            end
        elseif obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("gem") or name:find("premium") or name:find("robux") then
                pcall(function()
                    obj:InvokeServer(amount)
                    print("✅ Отправлен запрос гемов через RemoteFunction: " .. obj.Name)
                end)
            end
        end
    end
    
    CheatFunctions.ShowGemEffect(amount)
end

function CheatFunctions.ShowDiamondEffect(amount)
    if not LocalPlayer.Character then return end
    
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        for i = 1, 7 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.6, 0.6, 0.6)
            part.Position = root.Position + Vector3.new(math.random(-4, 4), math.random(1, 5), math.random(-4, 4))
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Glass
            part.BrickColor = BrickColor.new("Bright bluish green")
            part.Parent = workspace
            
            local pointLight = Instance.new("PointLight")
            pointLight.Brightness = 6
            pointLight.Range = 12
            pointLight.Color = Color3.new(0, 1, 1)
            pointLight.Parent = part
            
            game:GetService("Debris"):AddItem(part, 2)
        end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = root
        billboard.Parent = root
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "+" .. amount .. " 💠"
        textLabel.TextColor3 = Color3.new(0, 1, 1)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 26
        textLabel.TextStrokeTransparency = 0.5
        textLabel.Parent = billboard
        
        spawn(function()
            for i = 1, 30 do
                billboard.StudsOffset = Vector3.new(0, 3 + i * 0.12, 0)
                textLabel.TextTransparency = i / 30
                wait(0.05)
            end
            billboard:Destroy()
        end)
    end
end

function CheatFunctions.AddDiamonds(amount)
    local amount = amount or Config.DiamondAmount
    print("💠 Попытка добавить алмазы:", amount)
    
    local diamondNames = {
        "Diamonds", "Diamond", "Gems", "Gem", "Crystals", "Crystal",
        "Premium", "PremiumCurrency", "Robux"
    }
    
    for _, diamondName in pairs(diamondNames) do
        local diamondValue = LocalPlayer:FindFirstChild(diamondName)
        if diamondValue and (diamondValue:IsA("NumberValue") or diamondValue:IsA("IntValue")) then
            diamondValue.Value = diamondValue.Value + amount
            print("✅ Добавлено алмазов (" .. diamondName .. "): " .. amount)
        end
        
        if LocalPlayer.Character then
            local charDiamond = LocalPlayer.Character:FindFirstChild(diamondName)
            if charDiamond and (charDiamond:IsA("NumberValue") or charDiamond:IsA("IntValue")) then
                charDiamond.Value = charDiamond.Value + amount
                print("✅ Добавлено алмазов (" .. diamondName .. "): " .. amount)
            end
        end
    end
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("diamond") or name:find("gem") or name:find("premium") or name:find("crystal") then
                pcall(function()
                    obj:FireServer(amount)
                    print("✅ Отправлен запрос алмазов через RemoteEvent: " .. obj.Name)
                end)
            end
        elseif obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("diamond") or name:find("gem") or name:find("premium") then
                pcall(function()
                    obj:InvokeServer(amount)
                    print("✅ Отправлен запрос алмазов через RemoteFunction: " .. obj.Name)
                end)
            end
        end
    end
    
    CheatFunctions.ShowDiamondEffect(amount)
end

function CheatFunctions.AddXP(amount)
    local amount = amount or Config.XPAmount
    print("📈 Попытка добавить XP:", amount)
    
    local xpNames = {"XP", "Experience", "Exp", "Level", "Score"}
    
    for _, xpName in pairs(xpNames) do
        local xpValue = LocalPlayer:FindFirstChild(xpName)
        if xpValue and (xpValue:IsA("NumberValue") or xpValue:IsA("IntValue")) then
            xpValue.Value = xpValue.Value + amount
            print("✅ Добавлено XP (" .. xpName .. "): " .. amount)
        end
        
        if LocalPlayer.Character then
            local charXP = LocalPlayer.Character:FindFirstChild(xpName)
            if charXP and (charXP:IsA("NumberValue") or charXP:IsA("IntValue")) then
                charXP.Value = charXP.Value + amount
                print("✅ Добавлено XP (" .. xpName .. "): " .. amount)
            end
        end
    end
end

function CheatFunctions.SetLevel(level)
    local level = level or Config.LevelAmount
    print("🎯 Попытка установить уровень:", level)
    
    local levelNames = {"Level", "Lvl", "Rank"}
    
    for _, levelName in pairs(levelNames) do
        local levelValue = LocalPlayer:FindFirstChild(levelName)
        if levelValue and (levelValue:IsA("NumberValue") or levelValue:IsA("IntValue")) then
            levelValue.Value = level
            print("✅ Установлен уровень (" .. levelName .. "): " .. level)
        end
    end
end

function CheatFunctions.AddRebirth(amount)
    local amount = amount or 1
    print("🔄 Попытка добавить Rebirth:", amount)
    
    local rebirthNames = {
        "Rebirth", "Rebirths", "Prestige", "Prestiges", 
        "Ascension", "Ascensions", "Reset", "Resets",
        "Cycle", "Cycles", "Era", "Eras", "Age", "Ages"
    }
    
    local success = false
    
    for _, rebirthName in pairs(rebirthNames) do
        local rebirthValue = LocalPlayer:FindFirstChild(rebirthName)
        if rebirthValue and (rebirthValue:IsA("NumberValue") or rebirthValue:IsA("IntValue")) then
            rebirthValue.Value = rebirthValue.Value + amount
            print("✅ Добавлен Rebirth (" .. rebirthName .. "): " .. amount)
            success = true
        end
        
        if LocalPlayer.Character then
            local charRebirth = LocalPlayer.Character:FindFirstChild(rebirthName)
            if charRebirth and (charRebirth:IsA("NumberValue") or charRebirth:IsA("IntValue")) then
                charRebirth.Value = charRebirth.Value + amount
                print("✅ Добавлен Rebirth (" .. rebirthName .. "): " .. amount)
                success = true
            end
        end
    end
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("rebirth") or name:find("prestige") or name:find("ascension") or name:find("reset") then
                pcall(function()
                    obj:FireServer(amount)
                    obj:FireServer("rebirth")
                    obj:FireServer("prestige")
                    print("✅ Отправлен запрос Rebirth через RemoteEvent: " .. obj.Name)
                    success = true
                end)
            end
        elseif obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("rebirth") or name:find("prestige") or name:find("ascension") then
                pcall(function()
                    obj:InvokeServer(amount)
                    obj:InvokeServer("rebirth")
                    print("✅ Отправлен запрос Rebirth через RemoteFunction: " .. obj.Name)
                    success = true
                end)
            end
        end
    end
    
    pcall(function()
        local brainrotEvents = {
            "RebirthEvent", "PrestigeEvent", "AscensionEvent", "ResetEvent",
            "Rebirth", "Prestige", "Ascension"
        }
        
        for _, eventName in pairs(brainrotEvents) do
            local event = game:GetService("ReplicatedStorage"):FindFirstChild(eventName)
            if event and event:IsA("RemoteEvent") then
                event:FireServer(amount)
                print("✅ Отправлен запрос через " .. eventName)
                success = true
            end
        end
        
        local bladeBallEvents = {
            "Rebirths", "Prestiges", "Upgrade", "Upgrades"
        }
        
        for _, eventName in pairs(bladeBallEvents) do
            local event = game:GetService("ReplicatedStorage"):FindFirstChild(eventName)
            if event and event:IsA("RemoteEvent") then
                event:FireServer(amount)
                print("✅ Отправлен запрос через " .. eventName)
                success = true
            end
        end
    end)
    
    if success then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 250, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 4, 0)
            billboard.Adornee = root
            billboard.Parent = root
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "+" .. amount .. " 🔄 REBIRTH"
            textLabel.TextColor3 = Color3.new(1, 0.5, 0)
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextSize = 28
            textLabel.TextStrokeTransparency = 0.3
            textLabel.Parent = billboard
            
            spawn(function()
                for i = 1, 35 do
                    billboard.StudsOffset = Vector3.new(0, 4 + i * 0.1, 0)
                    textLabel.TextTransparency = i / 35
                    wait(0.05)
                end
                billboard:Destroy()
            end)
        end
    else
        print("❌ Rebirth не найден в этой игре")
    end
end

function CheatFunctions.UnlockAllItems()
    print("🎁 Попытка разблокировать все предметы")
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("unlock") or name:find("purchase") or name:find("buy") then
                pcall(function()
                    obj:FireServer("all")
                    obj:FireServer("everything")
                    print("✅ Отправлен запрос разблокировки: " .. obj.Name)
                end)
            end
        end
    end
end

function CheatFunctions.TeleportToSpawn()
    print("🏠 Телепортация к спавну")
    
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local spawns = workspace:FindFirstChild("Spawn") or workspace:FindFirstChild("SpawnLocation")
        if spawns then
            character.HumanoidRootPart.CFrame = spawns.CFrame + Vector3.new(0, 5, 0)
            print("✅ Телепортирован к спавну")
        else
            character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
            print("✅ Телепортирован в центр карты")
        end
    end
end

function CheatFunctions.ServerHop()
    print("🔄 Попытка перейти на другой сервер")
    
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    
    pcall(function()
        TeleportService:Teleport(placeId)
        print("✅ Запрос на смену сервера отправлен")
    end)
end

-- === НОВЫЕ ФУНКЦИИ ДЛЯ ТРОЛЛИНГА ===
function CheatFunctions.TeleportToPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            print("✅ Телепортирован к игроку: " .. playerName)
        end
    else
        print("❌ Игрок не найден: " .. playerName)
    end
end

function CheatFunctions.BringPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            targetPlayer.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
            print("✅ Привел игрока: " .. playerName)
        end
    else
        print("❌ Игрок не найден: " .. playerName)
    end
end

function CheatFunctions.SpamChat(playerName, message)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer then
        for i = 1, 10 do
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
                "/w " .. playerName .. " " .. message .. " [" .. i .. "]",
                "All"
            )
            wait(0.5)
        end
        print("✅ Спам отправлен игроку: " .. playerName)
    else
        print("❌ Игрок не найден: " .. playerName)
    end
end

function CheatFunctions.FreezePlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character then
        for _, part in pairs(targetPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
        print("✅ Заморозил игрока: " .. playerName)
    else
        print("❌ Игрок не найден: " .. playerName)
    end
end

function CheatFunctions.UnfreezePlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character then
        for _, part in pairs(targetPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
        print("✅ Разморозил игрока: " .. playerName)
    else
        print("❌ Игрок не найден: " .. playerName)
    end
end

function CheatFunctions.KillPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character then
        local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
            print("✅ Убил игрока: " .. playerName)
        end
    else
        print("❌ Игрок не найден: " .. playerName)
    end
end

function CheatFunctions.AnnoyPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedValues.AnnoyingPlayer = targetPlayer
        savedValues.AnnoyingConnection = RunService.Heartbeat:Connect(function()
            if savedValues.AnnoyingPlayer and savedValues.AnnoyingPlayer.Character then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = savedValues.AnnoyingPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                end
            end
        end)
        print("✅ Начинаю надоедать игроку: " .. playerName)
    else
        print("❌ Игрок не найден: " .. playerName)
    end
end

function CheatFunctions.StopAnnoying()
    if savedValues.AnnoyingConnection then
        savedValues.AnnoyingConnection:Disconnect()
        savedValues.AnnoyingConnection = nil
        savedValues.AnnoyingPlayer = nil
        print("✕ Прекратил надоедать")
    end
end

-- === MURDER MYSTERY 2 GLOW ESP ===
local MM2GlowESPEnabled = false
local MM2Highlights = {}

-- Цвета для ролей
local MM2_COLORS = {
    Innocent = Color3.fromRGB(0, 255, 0),    -- Зеленый
    Sheriff = Color3.fromRGB(0, 100, 255),   -- Синий
    Murderer = Color3.fromRGB(255, 0, 0)     -- Красный
}

-- Функция определения роли игрока
local function GetMM2PlayerRole(player)
    if player.Character then
        local backpack = player.Backpack
        local character = player.Character
        
        -- Проверяем инвентарь и персонажа на наличие оружия
        if backpack:FindFirstChild("Knife") or character:FindFirstChild("Knife") then
            return "Murderer"
        elseif backpack:FindFirstChild("Gun") or character:FindFirstChild("Gun") then
            return "Sheriff"
        else
            return "Innocent"
        end
    end
    return "Innocent"
end

-- Функция создания подсветки
local function CreateMM2Highlight(character)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.Parent = character
    return highlight
end

-- Обновление цвета подсветки
local function UpdateMM2Highlight(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    local character = player.Character
    local highlight = MM2Highlights[player]
    
    if not highlight or not highlight.Parent then
        highlight = CreateMM2Highlight(character)
        MM2Highlights[player] = highlight
    end
    
    if MM2GlowESPEnabled then
        local role = GetMM2PlayerRole(player)
        highlight.FillColor = MM2_COLORS[role]
        highlight.Enabled = true
    else
        highlight.Enabled = false
    end
end

-- Удаление подсветки при смерти персонажа
local function OnMM2CharacterAdded(player, character)
    if MM2Highlights[player] then
        MM2Highlights[player]:Destroy()
        MM2Highlights[player] = nil
    end
    
    character:WaitForChild("Humanoid").Died:Connect(function()
        if MM2Highlights[player] then
            MM2Highlights[player]:Destroy()
            MM2Highlights[player] = nil
        end
    end)
    
    wait(0.5)
    UpdateMM2Highlight(player)
end

-- Инициализация для всех игроков
local function SetupMM2Player(player)
    if player.Character then
        OnMM2CharacterAdded(player, player.Character)
    end
    
    player.CharacterAdded:Connect(function(character)
        OnMM2CharacterAdded(player, character)
    end)
end

-- Функция включения/выключения Glow ESP
function CheatFunctions.MM2GlowESP(enabled)
    MM2GlowESPEnabled = enabled
    
    if enabled then
        -- Подключение к новым игрокам
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                SetupMM2Player(player)
            end
        end
        
        Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                SetupMM2Player(player)
            end
        end)
        
        -- Удаление при выходе игрока
        Players.PlayerRemoving:Connect(function(player)
            if MM2Highlights[player] then
                MM2Highlights[player]:Destroy()
                MM2Highlights[player] = nil
            end
        end)
        
        -- Постоянное обновление (проверка смены оружия)
        activeConnections.MM2GlowESP = RunService.Heartbeat:Connect(function()
            for player, _ in pairs(MM2Highlights) do
                if player and player.Parent and player.Character then
                    UpdateMM2Highlight(player)
                end
            end
        end)
        
        print("✓ MM2 Glow ESP включен")
        print("Зеленый = Невинный | Синий = Шериф | Красный = Убийца")
    else
        if activeConnections.MM2GlowESP then
            activeConnections.MM2GlowESP:Disconnect()
            activeConnections.MM2GlowESP = nil
        end
        
        -- Удаляем все подсветки
        for player, highlight in pairs(MM2Highlights) do
            if highlight then
                highlight:Destroy()
            end
        end
        MM2Highlights = {}
        
        print("✕ MM2 Glow ESP отключен")
    end
end

-- === НОВЫЕ ФУНКЦИИ MM2 ===

-- 1. Автоматическое уклонение от убийцы
function CheatFunctions.MM2AutoAvoid(enabled)
    if enabled then
        activeConnections.MM2AutoAvoid = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            -- Ищем убийцу среди игроков
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local role = GetMM2PlayerRole(player)
                    if role == "Murderer" then
                        local murdererPos = player.Character.HumanoidRootPart.Position
                        local myPos = char.HumanoidRootPart.Position
                        local distance = (murdererPos - myPos).Magnitude
                        
                        if distance < 20 then -- Если убийца ближе 20 studs
                            -- Отпрыгиваем от убийцы
                            local direction = (myPos - murdererPos).Unit
                            char.HumanoidRootPart.Velocity = direction * 50
                            
                            if distance < 10 then
                                -- Телепортируемся если слишком близко
                                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 10, 0)
                            end
                        end
                    end
                end
            end
        end)
        print("✓ Авто-уклонение от убийцы включено")
    else
        if activeConnections.MM2AutoAvoid then
            activeConnections.MM2AutoAvoid:Disconnect()
            activeConnections.MM2AutoAvoid = nil
            print("✕ Авто-уклонение от убийцы отключено")
        end
    end
end

-- 2. Подсветка оружия на карте
function CheatFunctions.MM2WeaponESP(enabled)
    if enabled then
        activeConnections.MM2WeaponESP = RunService.Heartbeat:Connect(function()
            -- Ищем оружие на карте
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("revolver")) then
                    if not espData[item] then
                        espData[item] = {}
                        
                        local highlight = Instance.new("Highlight")
                        highlight.FillColor = MM2_COLORS.Sheriff
                        highlight.OutlineColor = MM2_COLORS.Sheriff
                        highlight.FillTransparency = 0.3
                        highlight.OutlineTransparency = 0
                        highlight.Parent = item
                        
                        local billboard = Instance.new("BillboardGui")
                        billboard.Size = UDim2.new(0, 200, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = item
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = "🔫 Оружие"
                        label.TextColor3 = MM2_COLORS.Sheriff
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 14
                        label.TextStrokeTransparency = 0.5
                        label.Parent = billboard
                        
                        espData[item].Highlight = highlight
                        espData[item].Billboard = billboard
                    end
                end
            end
        end)
        print("✓ Подсветка оружия включена")
    else
        if activeConnections.MM2WeaponESP then
            activeConnections.MM2WeaponESP:Disconnect()
            activeConnections.MM2WeaponESP = nil
        end
        
        -- Удаляем подсветку оружия
        for item, data in pairs(espData) do
            if typeof(item) == "Instance" and item:IsA("Tool") then
                if data.Highlight then data.Highlight:Destroy() end
                if data.Billboard then data.Billboard:Destroy() end
                espData[item] = nil
            end
        end
        print("✕ Подсветка оружия отключена")
    end
end

-- 3. Автоматический подбор оружия
function CheatFunctions.MM2AutoPickup(enabled)
    if enabled then
        activeConnections.MM2AutoPickup = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            -- Проверяем, есть ли у нас уже оружие
            local hasWeapon = false
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("revolver")) then
                    hasWeapon = true
                    break
                end
            end
            
            if not hasWeapon then
                -- Ищем ближайшее оружие
                local nearestWeapon = nil
                local shortestDistance = math.huge
                
                for _, item in pairs(workspace:GetDescendants()) do
                    if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("revolver")) then
                        if item:FindFirstChild("Handle") then
                            local distance = (char.HumanoidRootPart.Position - item.Handle.Position).Magnitude
                            if distance < 15 and distance < shortestDistance then
                                nearestWeapon = item
                                shortestDistance = distance
                            end
                        end
                    end
                end
                
                -- Подбираем оружие
                if nearestWeapon then
                    char.HumanoidRootPart.CFrame = CFrame.new(nearestWeapon.Handle.Position)
                    wait(0.1)
                    firetouchinterest(char.HumanoidRootPart, nearestWeapon.Handle, 0)
                    firetouchinterest(char.HumanoidRootPart, nearestWeapon.Handle, 1)
                end
            end
        end)
        print("✓ Авто-подбор оружия включен")
    else
        if activeConnections.MM2AutoPickup then
            activeConnections.MM2AutoPickup:Disconnect()
            activeConnections.MM2AutoPickup = nil
            print("✕ Авто-подбор оружия отключен")
        end
    end
end

-- === НОВЫЕ ФУНКЦИИ ДЛЯ TROLL PLAYER ===

function CheatFunctions.CreateFakePlayer()
    local char = LocalPlayer.Character
    if not char then return end

    local fakePlayer = Instance.new("Part")
    fakePlayer.Name = "FakePlayer"
    fakePlayer.Size = Vector3.new(2, 6, 1)
    fakePlayer.Position = char.HumanoidRootPart.Position + Vector3.new(5, 0, 5)
    fakePlayer.Anchored = true
    fakePlayer.CanCollide = false
    fakePlayer.Material = Enum.Material.Neon
    fakePlayer.BrickColor = BrickColor.new("Bright pink")
    fakePlayer.Parent = workspace

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(1, 0, 1)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.Parent = fakePlayer

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = fakePlayer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "FAKE PLAYER 👻"
    label.TextColor3 = Color3.new(1, 0, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = billboard

    game:GetService("Debris"):AddItem(fakePlayer, 30)
    print("✅ Fake player created")
end

function CheatFunctions.RainbowPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if not targetPlayer or not targetPlayer.Character then return end

    savedValues.RainbowPlayer = targetPlayer
    savedValues.RainbowConnection = RunService.Heartbeat:Connect(function()
        if savedValues.RainbowPlayer and savedValues.RainbowPlayer.Character then
            local time = tick()
            local r = (math.sin(time * 2) + 1) / 2
            local g = (math.sin(time * 2 + 2) + 1) / 2
            local b = (math.sin(time * 2 + 4) + 1) / 2
            
            for _, part in pairs(savedValues.RainbowPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = Color3.new(r, g, b)
                    part.Material = Enum.Material.Neon
                end
            end
        end
    end)
    print("✅ Rainbow effect applied to: " .. playerName)
end

function CheatFunctions.StopRainbowEffect()
    if savedValues.RainbowConnection then
        savedValues.RainbowConnection:Disconnect()
        savedValues.RainbowConnection = nil
        savedValues.RainbowPlayer = nil
        print("✕ Rainbow effect stopped")
    end
end

-- === НОВЫЕ ФУНКЦИИ ДЛЯ TOOLS ===

function CheatFunctions.CopyTool(playerName, toolName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if not targetPlayer then
        print("❌ Player not found: " .. playerName)
        return
    end

    local targetCharacter = targetPlayer.Character
    if not targetCharacter then
        print("❌ Player character not found")
        return
    end

    -- Ищем инструмент у игрока
    local targetTool = nil
    
    -- Сначала проверяем в инвентаре
    for _, tool in pairs(targetPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (toolName == nil or tool.Name:lower():find(toolName:lower())) then
            targetTool = tool
            break
        end
    end

    -- Затем проверяем в руках
    if not targetTool then
        for _, tool in pairs(targetCharacter:GetChildren()) do
            if tool:IsA("Tool") and (toolName == nil or tool.Name:lower():find(toolName:lower())) then
                targetTool = tool
                break
            end
        end
    end

    if not targetTool then
        print("❌ Tool not found for player: " .. playerName)
        return
    end

    -- Копируем инструмент
    local clonedTool = targetTool:Clone()
    clonedTool.Parent = LocalPlayer.Backpack
    
    print("✅ Copied tool: " .. clonedTool.Name .. " from " .. playerName)
    return clonedTool
end

function CheatFunctions.CopyAllTools(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if not targetPlayer then
        print("❌ Player not found: " .. playerName)
        return
    end

    local toolsCopied = 0
    
    -- Копируем все инструменты из инвентаря
    for _, tool in pairs(targetPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local clonedTool = tool:Clone()
            clonedTool.Parent = LocalPlayer.Backpack
            toolsCopied = toolsCopied + 1
        end
    end

    -- Копируем инструмент в руках
    if targetPlayer.Character then
        for _, tool in pairs(targetPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local clonedTool = tool:Clone()
                clonedTool.Parent = LocalPlayer.Backpack
                toolsCopied = toolsCopied + 1
            end
        end
    end

    print("✅ Copied " .. toolsCopied .. " tools from " .. playerName)
    return toolsCopied
end

function CheatFunctions.StealTools(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if not targetPlayer then
        print("❌ Player not found: " .. playerName)
        return
    end

    local toolsStolen = 0
    
    -- "Крадем" инструменты (копируем и удаляем у цели)
    if targetPlayer.Character then
        for _, tool in pairs(targetPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local clonedTool = tool:Clone()
                clonedTool.Parent = LocalPlayer.Backpack
                tool:Destroy()
                toolsStolen = toolsStolen + 1
            end
        end
    end

    -- Также из инвентаря
    for _, tool in pairs(targetPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local clonedTool = tool:Clone()
            clonedTool.Parent = LocalPlayer.Backpack
            tool:Destroy()
            toolsStolen = toolsStolen + 1
        end
    end

    print("✅ Stole " .. toolsStolen .. " tools from " .. playerName)
    return toolsStolen
end

function CheatFunctions.GiveAllTools()
    -- Даем себе все возможные инструменты из ServerStorage/ReplicatedStorage
    local toolsGiven = 0
    
    local searchLocations = {
        game:GetService("ServerStorage"),
        game:GetService("ReplicatedStorage"),
        workspace
    }
    
    for _, location in pairs(searchLocations) do
        for _, tool in pairs(location:GetDescendants()) do
            if tool:IsA("Tool") then
                local clonedTool = tool:Clone()
                clonedTool.Parent = LocalPlayer.Backpack
                toolsGiven = toolsGiven + 1
            end
        end
    end

    print("✅ Gave " .. toolsGiven .. " tools to yourself")
    return toolsGiven
end

-- === НОВЫЕ ФУНКЦИИ ДЛЯ TELEPORT ===

function CheatFunctions.TeleportToPosition(x, y, z)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
        print("✅ Телепортирован к позиции: " .. x .. ", " .. y .. ", " .. z)
    end
end

function CheatFunctions.SavePosition(name)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedValues.SavedPositions = savedValues.SavedPositions or {}
        savedValues.SavedPositions[name] = char.HumanoidRootPart.Position
        print("✅ Позиция сохранена: " .. name)
    end
end

function CheatFunctions.LoadPosition(name)
    if savedValues.SavedPositions and savedValues.SavedPositions[name] then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(savedValues.SavedPositions[name])
            print("✅ Телепортирован к сохраненной позиции: " .. name)
        end
    else
        print("❌ Сохраненная позиция не найдена: " .. name)
    end
end

-- === НОВЫЕ ФУНКЦИИ ДЛЯ FUN ===

function CheatFunctions.ChangeSize(scale)
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * scale
            end
        end
        print("✅ Размер изменен: " .. scale)
    end
end

function CheatFunctions.WalkOnWater(enabled)
    if enabled then
        activeConnections.WalkOnWater = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local ray = Ray.new(char.HumanoidRootPart.Position, Vector3.new(0, -10, 0))
                local hit, position = workspace:FindPartOnRay(ray, char)
                
                if hit and hit.Name:lower():find("water") then
                    char.HumanoidRootPart.Position = Vector3.new(
                        char.HumanoidRootPart.Position.X,
                        position.Y + 5,
                        char.HumanoidRootPart.Position.Z
                    )
                end
            end
        end)
        print("✅ Хождение по воде включено")
    else
        if activeConnections.WalkOnWater then
            activeConnections.WalkOnWater:Disconnect()
            activeConnections.WalkOnWater = nil
            print("✕ Хождение по воде отключено")
        end
    end
end

function CheatFunctions.SuperJump()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = 200
        char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        print("✅ Супер прыжок активирован")
    end
end

-- === НОВЫЕ ФУНКЦИИ ДЛЯ SERVER ===

function CheatFunctions.ListPlayers()
    print("📊 Список игроков на сервере:")
    for _, player in pairs(Players:GetPlayers()) do
        local status = "Alive"
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health <= 0 then
                status = "Dead"
            end
        else
            status = "No Character"
        end
        print("👤 " .. player.Name .. " | " .. status)
    end
end

function CheatFunctions.RejoinServer()
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    
    pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, game.JobId)
        print("✅ Переподключение к серверу")
    end)
end

-- ====================================================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА
-- ====================================================================

local UI = Library:Create()

-- === ВКЛАДКА: ДВИЖЕНИЕ ===
local MovementTab = UI:CreateTab("Movement", "🏃")

MovementTab:AddSection("Основные функции")

MovementTab:AddToggle("Speed Hack", function(state)
    CheatFunctions.SpeedHack(state)
end)

MovementTab:AddToggle("Flight", function(state)
    CheatFunctions.Flight(state)
end)

MovementTab:AddToggle("Jump Power", function(state)
    CheatFunctions.JumpPower(state)
end)

MovementTab:AddToggle("Infinite Jump", function(state)
    CheatFunctions.InfiniteJump(state)
end)

MovementTab:AddToggle("Noclip", function(state)
    CheatFunctions.Noclip(state)
end)

MovementTab:AddToggle("Click TP", function(state)
    CheatFunctions.ClickTeleport(state)
end)

MovementTab:AddSection("Настройки гравитации")

MovementTab:AddSlider("Gravity", 0, 500, 196, function(value)
    CheatFunctions.ChangeGravity(value)
end)

MovementTab:AddButton("Reset Gravity", function()
    CheatFunctions.ResetGravity()
end)

MovementTab:AddButton("Low Gravity", function()
    CheatFunctions.LowGravity()
end)

MovementTab:AddButton("Zero Gravity", function()
    CheatFunctions.ZeroGravity()
end)

MovementTab:AddButton("High Gravity", function()
    CheatFunctions.HighGravity()
end)

-- === ВКЛАДКА: ВИЗУАЛЫ ===
local VisualsTab = UI:CreateTab("Visuals", "👁️")

VisualsTab:AddSection("ESP и подсветка")

VisualsTab:AddToggle("ESP", function(state)
    CheatFunctions.ESP(state)
end)

VisualsTab:AddToggle("Glow ESP", function(state)
    CheatFunctions.GlowESP(state)
end)

VisualsTab:AddSection("Освещение и окружение")

VisualsTab:AddToggle("Fullbright", function(state)
    CheatFunctions.Fullbright(state)
end)

VisualsTab:AddToggle("Night Mode", function(state)
    CheatFunctions.NightMode(state)
end)

VisualsTab:AddToggle("Delete Sky", function(state)
    CheatFunctions.DeleteSky(state)
end)

VisualsTab:AddToggle("FOV Changer", function(state)
    CheatFunctions.FOVChanger(state)
end)

VisualsTab:AddSection("Настройки FOV")

VisualsTab:AddSlider("FOV Value", 70, 120, 120, function(value)
    Config.FOVValue = value
    if Camera.FieldOfView ~= 70 then
        Camera.FieldOfView = value
    end
end)

-- === ВКЛАДКА: БОЕВЫЕ ===
local CombatTab = UI:CreateTab("Combat", "⚔️")

CombatTab:AddSection("Прицеливание и стрельба")

CombatTab:AddToggle("Aimbot", function(state)
    CheatFunctions.Aimbot(state)
end)

CombatTab:AddToggle("TriggerBot", function(state)
    CheatFunctions.TriggerBot(state)
end)

CombatTab:AddToggle("Silent Aim", function(state)
    CheatFunctions.SilentAim(state)
end)

CombatTab:AddToggle("Rapid Fire", function(state)
    CheatFunctions.RapidFire(state)
end)

CombatTab:AddSection("Модификации оружия")

CombatTab:AddToggle("Infinite Ammo", function(state)
    CheatFunctions.InfiniteAmmo(state)
end)

CombatTab:AddToggle("No Recoil", function(state)
    CheatFunctions.NoRecoil(state)
end)

CombatTab:AddToggle("No Spread", function(state)
    CheatFunctions.NoSpread(state)
end)

CombatTab:AddToggle("Instant Hit", function(state)
    CheatFunctions.InstantHit(state)
end)

CombatTab:AddToggle("AntiCooldown", function(state)
    CheatFunctions.AntiCooldown(state)
end)

CombatTab:AddSection("Ближний бой")

CombatTab:AddToggle("Kill Aura", function(state)
    CheatFunctions.KillAura(state)
end)

CombatTab:AddToggle("Auto Parry", function(state)
    CheatFunctions.AutoParry(state)
end)

CombatTab:AddSection("Настройки Aimbot")

CombatTab:AddSlider("Aimbot FOV", 50, 200, 100, function(value)
    Config.AimbotFOV = value
    if FOVCircle then
        FOVCircle.Radius = value
    end
end)

CombatTab:AddSlider("Aimbot Smoothness", 5, 50, 15, function(value)
    Config.AimbotSmoothness = value / 100
end)

CombatTab:AddToggle("Show FOV Circle", function(state)
    CheatFunctions.ShowFOV(state)
end)

CombatTab:AddSection("Настройки TriggerBot")

CombatTab:AddSlider("TriggerBot Delay", 1, 20, 10, function(value)
    Config.TriggerBotDelay = value / 100
end)

CombatTab:AddSection("Настройки Rapid Fire")

CombatTab:AddSlider("Rapid Fire Speed", 0, 10, 0, function(value)
    Config.RapidFireSpeed = value
end)

-- === ВКЛАДКА: ЗАЩИТА ===
local DefenseTab = UI:CreateTab("Defense", "🛡️")

DefenseTab:AddSection("Бессмертие и здоровье")

DefenseTab:AddToggle("God Mode", function(state)
    CheatFunctions.GodMode(state)
end)

DefenseTab:AddToggle("Super God Mode", function(state)
    CheatFunctions.SuperGodMode(state)
end)

DefenseTab:AddToggle("Auto Heal", function(state)
    CheatFunctions.AutoHeal(state)
end)

DefenseTab:AddSection("Защита от эффектов")

DefenseTab:AddToggle("Anti AFK", function(state)
    CheatFunctions.AntiAFK(state)
end)

DefenseTab:AddToggle("Anti Ragdoll", function(state)
    CheatFunctions.AntiRagdoll(state)
end)

DefenseTab:AddToggle("Anti Stun", function(state)
    CheatFunctions.AntiStun(state)
end)

DefenseTab:AddToggle("Anti Slow", function(state)
    CheatFunctions.AntiSlow(state)
end)

DefenseTab:AddToggle("Anti Knockback", function(state)
    CheatFunctions.AntiKnockback(state)
end)

DefenseTab:AddSection("Дополнительная защита")

DefenseTab:AddToggle("Infinite Stamina", function(state)
    CheatFunctions.InfiniteStamina(state)
end)

DefenseTab:AddToggle("Remove Debuffs", function(state)
    CheatFunctions.RemoveDebuffs(state)
end)

DefenseTab:AddToggle("Force Field", function(state)
    CheatFunctions.ForceField(state)
end)

DefenseTab:AddToggle("Invisibility", function(state)
    CheatFunctions.Invisibility(state)
end)

-- === ВКЛАДКА: РЕСУРСЫ ===
local ResourcesTab = UI:CreateTab("Resources", "💰")

ResourcesTab:AddSection("Деньги и валюта")

ResourcesTab:AddSlider("Сумма денег", 100, 100000, 1000, function(value)
    Config.MoneyAmount = value
end)

ResourcesTab:AddButton("Добавить деньги", function()
    CheatFunctions.AddMoney(Config.MoneyAmount)
end)

ResourcesTab:AddButton("Добавить 10.000$", function()
    CheatFunctions.AddMoney(10000)
end)

ResourcesTab:AddButton("Добавить 100.000$", function()
    CheatFunctions.AddMoney(100000)
end)

ResourcesTab:AddButton("Максимальные деньги", function()
    CheatFunctions.AddMoney(999999)
end)

ResourcesTab:AddSection("Cash (Кэш)")

ResourcesTab:AddSlider("Количество Cash", 50, 50000, 500, function(value)
    Config.CashAmount = value
end)

ResourcesTab:AddButton("Добавить Cash", function()
    CheatFunctions.AddCash(Config.CashAmount)
end)

ResourcesTab:AddButton("Добавить 5.000 Cash", function()
    CheatFunctions.AddCash(5000)
end)

ResourcesTab:AddButton("Добавить 50.000 Cash", function()
    CheatFunctions.AddCash(50000)
end)

ResourcesTab:AddButton("Максимальный Cash", function()
    CheatFunctions.AddCash(999999)
end)

ResourcesTab:AddSection("Гемы и алмазы")

ResourcesTab:AddSlider("Количество гемов", 10, 5000, 100, function(value)
    Config.GemAmount = value
end)

ResourcesTab:AddButton("Добавить гемы", function()
    CheatFunctions.AddGems(Config.GemAmount)
end)

ResourcesTab:AddButton("Добавить 500 гемов", function()
    CheatFunctions.AddGems(500)
end)

ResourcesTab:AddButton("Добавить 5000 гемов", function()
    CheatFunctions.AddGems(5000)
end)

ResourcesTab:AddButton("Максимальные гемы", function()
    CheatFunctions.AddGems(99999)
end)

ResourcesTab:AddSlider("Количество алмазов", 5, 2500, 50, function(value)
    Config.DiamondAmount = value
end)

ResourcesTab:AddButton("Добавить алмазы", function()
    CheatFunctions.AddDiamonds(Config.DiamondAmount)
end)

ResourcesTab:AddButton("Добавить 250 алмазов", function()
    CheatFunctions.AddDiamonds(250)
end)

ResourcesTab:AddButton("Добавить 2500 алмазов", function()
    CheatFunctions.AddDiamonds(2500)
end)

ResourcesTab:AddButton("Максимальные алмазы", function()
    CheatFunctions.AddDiamonds(99999)
end)

ResourcesTab:AddSection("Опыт и уровни")

ResourcesTab:AddSlider("Количество XP", 10, 1000, 100, function(value)
    Config.XPAmount = value
end)

ResourcesTab:AddButton("Добавить XP", function()
    CheatFunctions.AddXP(Config.XPAmount)
end)

ResourcesTab:AddButton("Добавить 1000 XP", function()
    CheatFunctions.AddXP(1000)
end)

ResourcesTab:AddSlider("Уровень", 1, 100, 1, function(value)
    Config.LevelAmount = value
end)

ResourcesTab:AddButton("Установить уровень", function()
    CheatFunctions.SetLevel(Config.LevelAmount)
end)

ResourcesTab:AddButton("Максимальный уровень", function()
    CheatFunctions.SetLevel(100)
end)

ResourcesTab:AddSection("Rebirth System")

ResourcesTab:AddButton("Добавить 1 Rebirth", function()
    CheatFunctions.AddRebirth(1)
end)

ResourcesTab:AddButton("Добавить 10 Rebirth", function()
    CheatFunctions.AddRebirth(10)
end)

ResourcesTab:AddButton("Добавить 100 Rebirth", function()
    CheatFunctions.AddRebirth(100)
end)

ResourcesTab:AddButton("Максимальные Rebirth", function()
    CheatFunctions.AddRebirth(999)
end)

ResourcesTab:AddSection("Другие функции")

ResourcesTab:AddButton("Разблокировать все предметы", function()
    CheatFunctions.UnlockAllItems()
end)

ResourcesTab:AddButton("Телепорт к спавну", function()
    CheatFunctions.TeleportToSpawn()
end)

ResourcesTab:AddButton("Сменить сервер", function()
    CheatFunctions.ServerHop()
end)

ResourcesTab:AddSection("Быстрый доступ")

ResourcesTab:AddTextBox("Своя сумма денег", "Введите сумму", function(text)
    local amount = tonumber(text)
    if amount then
        CheatFunctions.AddMoney(amount)
    end
end)

ResourcesTab:AddTextBox("Свой Cash", "Введите количество", function(text)
    local amount = tonumber(text)
    if amount then
        CheatFunctions.AddCash(amount)
    end
end)

ResourcesTab:AddTextBox("Свои гемы", "Введите количество", function(text)
    local amount = tonumber(text)
    if amount then
        CheatFunctions.AddGems(amount)
    end
end)

ResourcesTab:AddTextBox("Свои алмазы", "Введите количество", function(text)
    local amount = tonumber(text)
    if amount then
        CheatFunctions.AddDiamonds(amount)
    end
end)

ResourcesTab:AddTextBox("Свой уровень", "Введите уровень", function(text)
    local level = tonumber(text)
    if level then
        CheatFunctions.SetLevel(level)
    end
end)

ResourcesTab:AddTextBox("Свой Rebirth", "Введите количество", function(text)
    local rebirths = tonumber(text)
    if rebirths then
        CheatFunctions.AddRebirth(rebirths)
    end
end)

-- === ВКЛАДКА: MURDER MYSTERY 2 ===
local MM2Tab = UI:CreateTab("Murder Mystery 2", "🔪")

MM2Tab:AddSection("Основные функции")

MM2Tab:AddToggle("Glow ESP", function(state)
    CheatFunctions.MM2GlowESP(state)
end)

MM2Tab:AddSection("Система оружия")

MM2Tab:AddButton("Auto Pickup Gun", function()
    CheatFunctions.MM2PickupGun()
end)

MM2Tab:AddToggle("Auto Pickup Gun Enabled", function(state)
    CheatFunctions.MM2AutoPickup(state)
end)

MM2Tab:AddSection("Манипуляция ролями")

MM2Tab:AddButton("Increase Murderer Chance", function()
    CheatFunctions.MM2IncreaseRoleChance("murderer")
end)

MM2Tab:AddButton("Increase Sheriff Chance", function()
    CheatFunctions.MM2IncreaseRoleChance("sheriff")
end)

MM2Tab:AddButton("Force Murderer Role", function()
    CheatFunctions.MM2ForceRole("murderer")
end)

MM2Tab:AddButton("Force Sheriff Role", function()
    CheatFunctions.MM2ForceRole("sheriff")
end)

MM2Tab:AddSection("ESP и визуальные эффекты")

MM2Tab:AddToggle("Weapon ESP", function(state)
    CheatFunctions.MM2WeaponESP(state)
end)

MM2Tab:AddToggle("Auto Avoid Murderer", function(state)
    CheatFunctions.MM2AutoAvoid(state)
end)

MM2Tab:AddSection("Продвинутые функции")

MM2Tab:AddButton("Reveal All Roles", function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = GetMM2PlayerRole(player)
            print("🎭 " .. player.Name .. " is: " .. role)
        end
    end
end)

MM2Tab:AddButton("Find Nearest Gun", function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local nearestGun = nil
    local shortestDistance = math.huge
    
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("revolver")) then
            if item:FindFirstChild("Handle") then
                local distance = (char.HumanoidRootPart.Position - item.Handle.Position).Magnitude
                if distance < shortestDistance then
                    nearestGun = item
                    shortestDistance = distance
                end
            end
        end
    end
    
    if nearestGun then
        print("🔫 Nearest gun at distance: " .. math.floor(shortestDistance))
        char.HumanoidRootPart.CFrame = CFrame.new(nearestGun.Handle.Position)
    else
        print("❌ No guns found")
    end
end)

-- === ВКЛАДКА: TROLL PLAYER ===
local TrollTab = UI:CreateTab("Troll Player", "😈")

TrollTab:AddSection("Target Selection")

local playerTextBox = TrollTab:AddTextBox("Player Name", "Enter player name", function(playerName)
    savedValues.TrollTarget = playerName
end)

TrollTab:AddSection("Телепортация")

TrollTab:AddButton("Teleport To Player", function()
    if savedValues.TrollTarget then
        CheatFunctions.TeleportToPlayer(savedValues.TrollTarget)
    else
        print("❌ Please enter a player name first")
    end
end)

TrollTab:AddButton("Bring Player To Me", function()
    if savedValues.TrollTarget then
        CheatFunctions.BringPlayer(savedValues.TrollTarget)
    else
        print("❌ Please enter a player name first")
    end
end)

TrollTab:AddSection("Контроль игрока")

TrollTab:AddButton("Freeze Player", function()
    if savedValues.TrollTarget then
        CheatFunctions.FreezePlayer(savedValues.TrollTarget)
    else
        print("❌ Please enter a player name first")
    end
end)

TrollTab:AddButton("Unfreeze Player", function()
    if savedValues.TrollTarget then
        CheatFunctions.UnfreezePlayer(savedValues.TrollTarget)
    else
        print("❌ Please enter a player name first")
    end
end)

TrollTab:AddButton("Kill Player", function()
    if savedValues.TrollTarget then
        CheatFunctions.KillPlayer(savedValues.TrollTarget)
    else
        print("❌ Please enter a player name first")
    end
end)

TrollTab:AddSection("Надоедание")

TrollTab:AddButton("Start Annoying Player", function()
    if savedValues.TrollTarget then
        CheatFunctions.AnnoyPlayer(savedValues.TrollTarget)
    else
        print("❌ Please enter a player name first")
    end
end)

TrollTab:AddButton("Stop Annoying", function()
    CheatFunctions.StopAnnoying()
end)

TrollTab:AddButton("Spam Player", function()
    if savedValues.TrollTarget then
        CheatFunctions.SpamChat(savedValues.TrollTarget, "You're being trolled! 😈")
    else
        print("❌ Please enter a player name first")
    end
end)

TrollTab:AddSection("Визуальный троллинг")

TrollTab:AddButton("Create Fake Player", function()
    CheatFunctions.CreateFakePlayer()
end)

TrollTab:AddButton("Rainbow Player", function()
    if savedValues.TrollTarget then
        CheatFunctions.RainbowPlayer(savedValues.TrollTarget)
    else
        print("❌ Please enter a player name first")
    end
end)

TrollTab:AddButton("Stop Rainbow Effect", function()
    CheatFunctions.StopRainbowEffect()
end)

TrollTab:AddSection("Быстрый доступ к игрокам")

local function UpdatePlayerList()
    if savedValues.PlayerButtons then
        for _, button in pairs(savedValues.PlayerButtons) do
            if button and button.Parent then
                button:Destroy()
            end
        end
    end
    savedValues.PlayerButtons = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local button = TrollTab:AddButton("🎯 " .. player.Name, function()
                savedValues.TrollTarget = player.Name
                print("✅ Selected player: " .. player.Name)
            end)
            table.insert(savedValues.PlayerButtons, button)
        end
    end
end

-- Обновляем список при подключении/отключении игроков
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- Инициализация списка при загрузке
UpdatePlayerList()

-- === ВКЛАДКА: TOOLS ===
local ToolsTab = UI:CreateTab("Tools", "🛠️")

ToolsTab:AddSection("Копирование инструментов")

local toolPlayerTextBox = ToolsTab:AddTextBox("Player Name", "Enter player name", function(playerName)
    savedValues.ToolTarget = playerName
end)

local toolNameTextBox = ToolsTab:AddTextBox("Tool Name (Optional)", "Enter tool name", function(toolName)
    savedValues.ToolName = toolName
end)

ToolsTab:AddButton("Copy Specific Tool", function()
    if savedValues.ToolTarget then
        CheatFunctions.CopyTool(savedValues.ToolTarget, savedValues.ToolName)
    else
        print("❌ Please enter a player name first")
    end
end)

ToolsTab:AddButton("Copy All Tools", function()
    if savedValues.ToolTarget then
        CheatFunctions.CopyAllTools(savedValues.ToolTarget)
    else
        print("❌ Please enter a player name first")
    end
end)

ToolsTab:AddButton("Steal Tools", function()
    if savedValues.ToolTarget then
        CheatFunctions.StealTools(savedValues.ToolTarget)
    else
        print("❌ Please enter a player name first")
    end
end)

ToolsTab:AddButton("Give All Tools", function()
    CheatFunctions.GiveAllTools()
end)

ToolsTab:AddSection("Быстрый доступ к игрокам")

local function UpdateToolsPlayerList()
    if savedValues.ToolsPlayerButtons then
        for _, button in pairs(savedValues.ToolsPlayerButtons) do
            if button and button.Parent then
                button:Destroy()
            end
        end
    end
    savedValues.ToolsPlayerButtons = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local button = ToolsTab:AddButton("🎯 " .. player.Name, function()
                savedValues.ToolTarget = player.Name
                print("✅ Selected player for tools: " .. player.Name)
            end)
            table.insert(savedValues.ToolsPlayerButtons, button)
        end
    end
end

-- Обновляем список при подключении/отключении игроков
Players.PlayerAdded:Connect(UpdateToolsPlayerList)
Players.PlayerRemoving:Connect(UpdateToolsPlayerList)

-- Инициализация списка при загрузке
UpdateToolsPlayerList()

ToolsTab:AddSection("Информация об инструментах")

ToolsTab:AddButton("Show My Tools", function()
    local backpack = LocalPlayer.Backpack
    local character = LocalPlayer.Character
    
    print("🛠️ Your Tools:")
    
    local toolCount = 0
    
    -- Инструменты в инвентаре
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            print("- " .. tool.Name .. " (Backpack)")
            toolCount = toolCount + 1
        end
    end
    
    -- Инструменты в руках
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                print("- " .. tool.Name .. " (Equipped)")
                toolCount = toolCount + 1
            end
        end
    end
    
    print("📊 Total tools: " .. toolCount)
end)

ToolsTab:AddButton("Show Player Tools", function()
    if savedValues.ToolTarget then
        local targetPlayer = Players:FindFirstChild(savedValues.ToolTarget)
        if targetPlayer then
            local backpack = targetPlayer.Backpack
            local character = targetPlayer.Character
            
            print("🛠️ " .. savedValues.ToolTarget .. "'s Tools:")
            
            local toolCount = 0
            
            -- Инструменты в инвентаре
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    print("- " .. tool.Name .. " (Backpack)")
                    toolCount = toolCount + 1
                end
            end
            
            -- Инструменты в руках
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        print("- " .. tool.Name .. " (Equipped)")
                        toolCount = toolCount + 1
                    end
                end
            end
            
            print("📊 Total tools: " .. toolCount)
        else
            print("❌ Player not found")
        end
    else
        print("❌ Please enter a player name first")
    end
end)

-- === ВКЛАДКА: TELEPORT ===
local TeleportTab = UI:CreateTab("Teleport", "📍")

TeleportTab:AddSection("Позиции на карте")

TeleportTab:AddButton("Teleport to Spawn", function()
    CheatFunctions.TeleportToSpawn()
end)

TeleportTab:AddButton("Teleport to Center", function()
    CheatFunctions.TeleportToPosition(0, 100, 0)
end)

TeleportTab:AddButton("Teleport to Sky", function()
    CheatFunctions.TeleportToPosition(0, 1000, 0)
end)

TeleportTab:AddSection("Сохранение позиций")

local positionNameTextBox = TeleportTab:AddTextBox("Position Name", "Enter position name", function(text)
    savedValues.PositionName = text
end)

TeleportTab:AddButton("Save Current Position", function()
    if savedValues.PositionName then
        CheatFunctions.SavePosition(savedValues.PositionName)
    else
        print("❌ Please enter a position name first")
    end
end)

TeleportTab:AddButton("Load Saved Position", function()
    if savedValues.PositionName then
        CheatFunctions.LoadPosition(savedValues.PositionName)
    else
        print("❌ Please enter a position name first")
    end
end)

TeleportTab:AddSection("Быстрые позиции")

TeleportTab:AddButton("Save Position 1", function()
    CheatFunctions.SavePosition("Position1")
end)

TeleportTab:AddButton("Load Position 1", function()
    CheatFunctions.LoadPosition("Position1")
end)

TeleportTab:AddButton("Save Position 2", function()
    CheatFunctions.SavePosition("Position2")
end)

TeleportTab:AddButton("Load Position 2", function()
    CheatFunctions.LoadPosition("Position2")
end)

-- === ВКЛАДКА: FUN ===
local FunTab = UI:CreateTab("Fun", "🎮")

FunTab:AddSection("Изменение персонажа")

FunTab:AddButton("Small Size", function()
    CheatFunctions.ChangeSize(0.5)
end)

FunTab:AddButton("Normal Size", function()
    CheatFunctions.ChangeSize(1)
end)

FunTab:AddButton("Big Size", function()
    CheatFunctions.ChangeSize(2)
end)

FunTab:AddButton("Giant Size", function()
    CheatFunctions.ChangeSize(5)
end)

FunTab:AddSection("Особые способности")

FunTab:AddToggle("Walk on Water", function(state)
    CheatFunctions.WalkOnWater(state)
end)

FunTab:AddButton("Super Jump", function()
    CheatFunctions.SuperJump()
end)

FunTab:AddSection("Развлечения")

FunTab:AddButton("Create Fake Player", function()
    CheatFunctions.CreateFakePlayer()
end)

FunTab:AddButton("Rainbow Effect", function()
    if savedValues.TrollTarget then
        CheatFunctions.RainbowPlayer(savedValues.TrollTarget)
    else
        print("❌ Please select a player first in Troll tab")
    end
end)

-- === ВКЛАДКА: SERVER ===
local ServerTab = UI:CreateTab("Server", "🌐")

ServerTab:AddSection("Информация о сервере")

ServerTab:AddButton("List Players", function()
    CheatFunctions.ListPlayers()
end)

ServerTab:AddButton("Show Server Info", function()
    print("📊 Server Information:")
    print("👥 Players: " .. #Players:GetPlayers())
    print("🆔 Place ID: " .. game.PlaceId)
    print("🔧 Job ID: " .. game.JobId)
end)

ServerTab:AddSection("Управление сервером")

ServerTab:AddButton("Rejoin Server", function()
    CheatFunctions.RejoinServer()
end)

ServerTab:AddButton("Server Hop", function()
    CheatFunctions.ServerHop()
end)

ServerTab:AddSection("Быстрый доступ к игрокам")

local function UpdateServerPlayerList()
    if savedValues.ServerPlayerButtons then
        for _, button in pairs(savedValues.ServerPlayerButtons) do
            if button and button.Parent then
                button:Destroy()
            end
        end
    end
    savedValues.ServerPlayerButtons = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local button = ServerTab:AddButton("👤 " .. player.Name, function()
                savedValues.TrollTarget = player.Name
                print("✅ Selected player: " .. player.Name)
            end)
            table.insert(savedValues.ServerPlayerButtons, button)
        end
    end
end

-- Обновляем список при подключении/отключении игроков
Players.PlayerAdded:Connect(UpdateServerPlayerList)
Players.PlayerRemoving:Connect(UpdateServerPlayerList)

-- Инициализация списка при загрузке
UpdateServerPlayerList()

-- === ВКЛАДКА: НАСТРОЙКИ ===
local SettingsTab = UI:CreateTab("Settings", "⚙️")

SettingsTab:AddSection("UI Colors")

SettingsTab:AddColorPicker("Accent Color", Config.AccentColor, function(color)
    Config.AccentColor = color
    print("✓ Accent color changed")
end)

SettingsTab:AddColorPicker("Background Color", Config.BackgroundColor, function(color)
    Config.BackgroundColor = color
    print("✓ Background color changed")
end)

SettingsTab:AddSection("RGB Settings")

SettingsTab:AddToggle("RGB Background Glow", function(state)
    Config.RGBBackground = state
    if state then
        UI:StartRGBAnimation()
        print("✓ RGB Background enabled")
    else
        UI:StopRGBAnimation()
        UI.Glow.ImageColor3 = Config.AccentColor
        print("✕ RGB Background disabled")
    end
end)

SettingsTab:AddSlider("RGB Speed", 1, 10, 1, function(value)
    Config.RGBSpeed = value
end)

SettingsTab:AddSection("ESP Colors")

SettingsTab:AddColorPicker("Enemy ESP Color", Config.ESPEnemyColor, function(color)
    Config.ESPEnemyColor = color
end)

SettingsTab:AddColorPicker("Team ESP Color", Config.ESPTeamColor, function(color)
    Config.ESPTeamColor = color
end)

SettingsTab:AddSection("Night Mode Settings")

SettingsTab:AddColorPicker("Night Ambient", Config.NightAmbient, function(color)
    Config.NightAmbient = color
    if savedValues.TimeOfDay == "00:00:00" then
        Lighting.Ambient = color
        Lighting.OutdoorAmbient = color
    end
end)

SettingsTab:AddSection("Movement Settings")

SettingsTab:AddSlider("Speed Multiplier", 1, 5, 2.5, function(value)
    Config.SpeedMultiplier = value
end)

SettingsTab:AddSlider("Jump Multiplier", 1, 3, 2, function(value)
    Config.JumpMultiplier = value
end)

SettingsTab:AddSlider("Flight Speed", 10, 100, 50, function(value)
    Config.FlightSpeed = value
end)

SettingsTab:AddSection("Actions")

SettingsTab:AddButton("Reset Position", function()
    UI.MainFrame.Position = UDim2.new(0.5, -375, 0.5, -275)
    print("✓ UI position reset")
end)

SettingsTab:AddButton("Destroy Menu", function()
    UI.ScreenGui:Destroy()
    print("✓ Menu destroyed")
end)

-- ====================================================================
-- ГОРЯЧИЕ КЛАВИШИ
-- ====================================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl then
        UI:Toggle()
    end
end)

-- ====================================================================
-- ИНИЦИАЛИЗАЦИЯ
-- ====================================================================

print("════════════════════════════════════════")
print("   MODERN CHEAT MENU V8.0 LOADED")
print("   Press INSERT or RIGHT CTRL to toggle")
print("════════════════════════════════════════")

-- Автоматически открыть меню при загрузке
task.wait(1)
UI:Toggle()
