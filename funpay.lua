
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- // 1. ДИЗАЙН (HYPERION) //
local Theme = {
    Background = Color3.fromRGB(28, 30, 35),
    Sidebar    = Color3.fromRGB(22, 24, 28),
    Panel      = Color3.fromRGB(34, 36, 41),
    Accent     = Color3.fromRGB(211, 47, 47),
    Text       = Color3.fromRGB(255, 255, 255),
    SubText    = Color3.fromRGB(150, 150, 150),
    Divider    = Color3.fromRGB(45, 47, 52)
}

-- // 2. СОЗДАНИЕ МЕНЮ //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HyperionBlindUI_Perfect"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 85)
MainFrame.Position = UDim2.new(0.5, -130, 0.8, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Divider
MainStroke.Thickness = 1.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Перетаскивание
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    TweenService:Create(MainFrame, TweenInfo.new(0.05), {
        Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    }):Play()
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- Тексты
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, -20, 0, 20)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "SCANNING..."
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.Text
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local PercentLabel = Instance.new("TextLabel")
PercentLabel.Parent = MainFrame
PercentLabel.Size = UDim2.new(0, 60, 0, 20)
PercentLabel.Position = UDim2.new(1, -70, 0, 8)
PercentLabel.BackgroundTransparency = 1
PercentLabel.Text = "0%"
PercentLabel.Font = Enum.Font.GothamBold
PercentLabel.TextColor3 = Theme.Accent
PercentLabel.TextSize = 14
PercentLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Полоска (11px)
local BarBackground = Instance.new("Frame")
BarBackground.Parent = MainFrame
BarBackground.Size = UDim2.new(1, -20, 0, 11) 
BarBackground.Position = UDim2.new(0, 10, 0, 38)
BarBackground.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
BarBackground.BorderSizePixel = 0
Instance.new("UICorner", BarBackground).CornerRadius = UDim.new(1, 0)

-- Заливка
local BarFill = Instance.new("Frame")
BarFill.Parent = BarBackground
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Theme.Accent
BarFill.BorderSizePixel = 0
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.Size = UDim2.new(1, -20, 0, 15)
StatusLabel.Position = UDim2.new(0, 10, 0, 60)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Waiting..."
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextColor3 = Theme.SubText
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- // 3. ЛОГИКА (ОРИГИНАЛЬНЫЕ ФУНКЦИИ ПОИСКА) //

-- Та же самая функция поиска убийцы
local function findKillerWithFlashZone()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= LocalPlayer then
            local character = otherPlayer.Character
            if character then
                if character:FindFirstChild("Flash_Zone") then 
                    return otherPlayer, character 
                end
                for _, descendant in pairs(character:GetDescendants()) do
                    if descendant.Name == "Flash_Zone" then 
                        return otherPlayer, character 
                    end
                end
            end
        end
    end
    return nil, nil
end

-- Та же самая функция поиска скрипта
local function findKillerBlindScript(killer)
    if not killer then return nil end
    local locations = {
        killer:FindFirstChild("Backpack"), 
        killer:FindFirstChild("PlayerScripts"), 
        killer.Character
    }
    
    for _, location in pairs(locations) do
        if location then
            -- Ищем папку Scripts
            local scripts = location:FindFirstChild("Scripts")
            if scripts then
                local blindScript = scripts:FindFirstChild("BlindScript")
                if blindScript then return blindScript end
                
                -- Рекурсивный поиск внутри папки Scripts
                for _, child in pairs(scripts:GetDescendants()) do
                    if child:IsA("Script") and (child:FindFirstChild("Brightness") or child:FindFirstChild("Blinded")) then
                        return child
                    end
                end
            end
            
            -- Ищем напрямую в локации
            for _, child in pairs(location:GetChildren()) do
                if child:IsA("Script") and (child:FindFirstChild("Brightness") or child:FindFirstChild("Blinded")) then
                    return child
                end
            end
        end
    end
    return nil
end

-- Переменные для хранения
local currentKiller = nil
local currentBlindScript = nil
local lastSearchTime = 0

RunService.RenderStepped:Connect(function()
    
    -- === ЧАСТЬ 1: ПОИСК (РАЗ В 0.5 СЕКУНДЫ) ===
    -- Мы не ищем маньяка каждый кадр, чтобы не лагало, но обновляем часто
    if tick() - lastSearchTime > 0.5 then
        lastSearchTime = tick()
        
        -- Если мы уже нашли скрипт, проверяем, жив ли он
        if currentKiller and currentBlindScript and currentBlindScript.Parent then
            -- Всё ок, ничего не делаем, просто продолжаем читать данные
        else
            -- Если потеряли цель, ищем заново (Логика "Работающего скрипта")
            local killer, character = findKillerWithFlashZone()
            if killer and character then
                local blindScript = findKillerBlindScript(killer)
                
                if blindScript then
                    currentKiller = killer
                    currentBlindScript = blindScript
                else
                    -- Запасной поиск в персонаже (как было в оригинале)
                    for _, descendant in pairs(character:GetDescendants()) do
                        if descendant:IsA("Script") and descendant:FindFirstChild("Brightness") then
                            currentKiller = killer
                            currentBlindScript = descendant
                            break
                        end
                    end
                end
            else
                currentKiller = nil
                currentBlindScript = nil
            end
        end
    end

    -- === ЧАСТЬ 2: ОБНОВЛЕНИЕ GUI (МГНОВЕННО / КАЖДЫЙ КАДР) ===
    if currentKiller and currentBlindScript then
        MainFrame.Visible = true
        Title.Text = string.upper(currentKiller.Name)
        
        -- Читаем значения напрямую (без getsenv, как в оригинале)
        local brightnessObj = currentBlindScript:FindFirstChild("Brightness")
        local blindedObj = currentBlindScript:FindFirstChild("Blinded")
        
        local progress = 0
        local isBlinded = false
        
        if brightnessObj then progress = tonumber(brightnessObj.Value) or 0 end
        if blindedObj then isBlinded = blindedObj.Value end
        
        progress = math.clamp(progress, 0, 100)
        
        -- ОЧЕНЬ БЫСТРАЯ АНИМАЦИЯ (0.05 сек) - Создает эффект плавности без задержки
        TweenService:Create(BarFill, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
            Size = UDim2.new(progress / 100, 0, 1, 0)
        }):Play()
        
        PercentLabel.Text = math.floor(progress) .. "%"
        
        -- Цвета
        if isBlinded or progress >= 99 then
            StatusLabel.Text = "STATUS: BLINDED!"
            StatusLabel.TextColor3 = Theme.Accent
            BarFill.BackgroundColor3 = Theme.Accent
            
            local pulse = (math.sin(tick() * 15) + 1) / 2
            MainStroke.Color = Theme.Divider:Lerp(Theme.Accent, pulse)
        elseif progress > 0 then
            StatusLabel.Text = "STATUS: FLASHING..."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
            BarFill.BackgroundColor3 = Theme.Accent
            MainStroke.Color = Theme.Divider
        else
            StatusLabel.Text = "STATUS: IDLE"
            StatusLabel.TextColor3 = Theme.SubText
            MainStroke.Color = Theme.Divider
        end
    else
        Title.Text = "SEARCHING..."
        PercentLabel.Text = "--"
        StatusLabel.Text = "Target Lost..."
        TweenService:Create(BarFill, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 1, 0)}):Play()
        MainStroke.Color = Theme.Divider
    end
end)
