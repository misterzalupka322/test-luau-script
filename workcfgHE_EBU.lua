-- Hyperion UI Remake v7 (Fixed Transparency & CanvasGroup)
-- Optimized for Roblox
-- Updated with ESP Modules
-- Added: FOV Changer, Aspect Ratio Changer, Free Camera, Flash Progress, Inf Item Charges

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

--// Global State for UI Logic
local OpenedDropdown = nil
local LastMouseBehavior = Enum.MouseBehavior.Default
local LastMouseIconEnabled = true

--// UI Elements Tracking for Configs
local UI_Elements = {
    Toggles = {},
    Sliders = {},
    Keys = {},
    ESPToggles = {},
    ESPSizeToggles = {},
    PlayerActions = {}
}

--// ESP States Storage
local ESPStates = {
    Survivor = {
        Chams = {Enabled = false, Color = Color3.fromHex("#AFEEEE"), Outline = Color3.new(0,0,0)},
        Skeleton = {Enabled = false, Color = Color3.fromHex("#AFEEEE"), Outline = Color3.new(0,0,0)},
        Names = {Enabled = false, Color = Color3.fromHex("#AFEEEE"), Outline = Color3.new(0,0,0), Size = "Auto"},
        Distance = {Enabled = false, Color = Color3.fromHex("#AFEEEE"), Outline = Color3.new(0,0,0), Size = "Auto"}
    },
    Killer = {
        Chams = {Enabled = false, Color = Color3.fromHex("#A5260A"), Outline = Color3.new(0,0,0)},
        Skeleton = {Enabled = false, Color = Color3.fromHex("#A5260A"), Outline = Color3.new(0,0,0)},
        Names = {Enabled = false, Color = Color3.fromHex("#A5260A"), Outline = Color3.new(0,0,0), Size = "Auto"},
        Distance = {Enabled = false, Color = Color3.fromHex("#A5260A"), Outline = Color3.new(0,0,0), Size = "Auto"},
        Killerlight = {Enabled = false, Color = Color3.fromHex("#FF0000"), Outline = Color3.new(0,0,0)}
    },
    Objects = {
        Chests = {Enabled = false, Color = Color3.fromHex("#CD5700"), Outline = Color3.new(0,0,0)},
        Hatch = {Enabled = false, Color = Color3.fromHex("#7B3F00"), Outline = Color3.new(0,0,0)},
        Lockers = {Enabled = false, Color = Color3.fromHex("#CD5700"), Outline = Color3.new(0,0,0)},
        Hooks = {Enabled = false, Color = Color3.fromHex("#A5260A"), Outline = Color3.new(0,0,0)},
        Pallets = {Enabled = false, Color = Color3.fromHex("#DAD871"), Outline = Color3.new(0,0,0)},
        Windows = {Enabled = false, Color = Color3.fromHex("#DAD871"), Outline = Color3.new(0,0,0)},
        Exits = {Enabled = false, Color = Color3.fromHex("#969696"), Outline = Color3.new(0,0,0)},
        Totems = {Enabled = false, Color = Color3.fromHex("#FFFDDF"), Outline = Color3.new(0,0,0)},
        Generators = {Enabled = false, Color = Color3.fromHex("#1E1112"), Outline = Color3.new(0,0,0)},
        GeneratorsProgress = {Enabled = false}
    }
}

--// Дополнительные состояния
local MiscStates = {
    FOVChanger = {Enabled = false, Value = 70},
    AspectRatioChanger = {Enabled = false, Value = 0.70},
    FreeCamera = {Enabled = false},
    FlashProgress = {Enabled = false},
    InfItemCharges = {Enabled = false},
	OutfitChanger = {Enabled = false}
}

--// ESP Modules Storage
local ESPModules = {
    Survivor = {
        Chams = {Highlights = {}},
        Skeleton = {Lines = {}, Connection = nil},
        Names = {Labels = {}, Connection = nil},
        Distance = {Labels = {}, Connection = nil}
    },
    Killer = {
        Chams = {Highlights = {}},
        Skeleton = {Lines = {}, Connection = nil},
        Names = {Labels = {}, Connection = nil},
        Distance = {Labels = {}, Connection = nil},
        Killerlight = {Connection = nil}
    },
    Objects = {
        Chests = {Highlights = {}},
        Hatch = {Highlights = {}},
        Lockers = {Highlights = {}},
        Hooks = {Highlights = {}},
        Pallets = {Highlights = {}},
        Windows = {Highlights = {}},
        Exits = {Highlights = {}},
        Totems = {Highlights = {}},
        Generators = {Highlights = {}},
        GeneratorsProgress = {Billboards = {}, Connection = nil}
    }
}

--// Theme Configuration
local Theme = {
    Background = Color3.fromRGB(28, 30, 35),
    Sidebar    = Color3.fromRGB(22, 24, 28),
    Panel      = Color3.fromRGB(34, 36, 41),
    Accent     = Color3.fromRGB(211, 47, 47),
    Text       = Color3.fromRGB(255, 255, 255),
    SubText    = Color3.fromRGB(150, 150, 150),
    Input      = Color3.fromRGB(24, 26, 30),
    Divider    = Color3.fromRGB(45, 47, 52)
}

local RageModules = {
    BlockHooks = {Connection = nil},
    FinishGens = {Connection = nil},
    GateNeverOpen = {Connection = nil},
    NeverFinishGens = {Connection = nil},
    LungeDuration = {Connection = nil, Value = 0.6}
}

--// Helper XYETA
local function Create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do inst[k] = v end
    if children then
        for _, child in pairs(children) do child.Parent = inst end
    end
    return inst
end

local function MakeDraggable(dragObj, moveObj)
    local dragging, dragInput, dragStart, startPos
    dragObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = moveObj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragObj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            moveObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// Функция определения команды игрока
local function getPlayerTeam(player)
    if player.Team then
        local teamName = player.Team.Name
        if teamName:lower():find("killer") then
            return "Killer"
        elseif teamName:lower():find("survivor") then
            return "Survivor"
        end
    end
    
    local role = player:GetAttribute("Role") or player:GetAttribute("Team")
    if role then
        role = tostring(role):lower()
        if role:find("killer") then
            return "Killer"
        elseif role:find("survivor") then
            return "Survivor"
        end
    end
    
    return "Survivor"
end

    local function FromHex(hex)
        hex = hex:gsub("#", "")
        if #hex == 6 then
            local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
            if r and g and b then return Color3.fromRGB(r, g, b) end
        end
        return nil
    end
	
--// Таблица сокращений названий клавиш
local KeyShortcuts = {
    ["LeftControl"] = "LCtrl",  ["RightControl"] = "RCtrl",
    ["LeftShift"]   = "LShift", ["RightShift"]   = "RShift",
    ["LeftAlt"]     = "LAlt",   ["RightAlt"]     = "RAlt",
    ["CapsLock"]    = "Caps",   ["Return"]       = "Enter",
    ["Backspace"]   = "Back",   ["PageUp"]       = "PgUp",
    ["PageDown"]    = "PgDn",   ["Delete"]       = "Del",
    ["Insert"]      = "Ins",    ["Home"]         = "Home",
    ["End"]         = "End",    ["Space"]        = "Space",

    ["One"] = "1", ["Two"] = "2", ["Three"] = "3", ["Four"] = "4",
    ["Five"] = "5", ["Six"] = "6", ["Seven"] = "7", ["Eight"] = "8",
    ["Nine"] = "9", ["Zero"] = "0"
}

-- Функция для получения красивого имени клавиши
local function GetKeyName(keyCode)
    if not keyCode or keyCode == Enum.KeyCode.Unknown then 
        return "None" 
    end
    return KeyShortcuts[keyCode.Name] or keyCode.Name
end

--// ESP XYETA

-- Killer Chams
local function updateKillerChams(enabled, color, outlineColor)
    -- Очищаем старые Highlights
    for _, highlight in pairs(ESPModules.Killer.Chams.Highlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    ESPModules.Killer.Chams.Highlights = {}
    
    if not enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            if getPlayerTeam(player) == "Killer" then
                local highlight = Instance.new("Highlight")
                highlight.Name = "Killer_ESP_Highlight"
                highlight.Adornee = character
                highlight.FillColor = color
                highlight.OutlineColor = outlineColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0.3
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = character
                
                table.insert(ESPModules.Killer.Chams.Highlights, highlight)
            end
        end
    end
end

-- Survivor Chams
local function updateSurvivorChams(enabled, color, outlineColor)
    for _, highlight in pairs(ESPModules.Survivor.Chams.Highlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    ESPModules.Survivor.Chams.Highlights = {}
    
    if not enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            if getPlayerTeam(player) == "Survivor" then
                local highlight = Instance.new("Highlight")
                highlight.Name = "Survivor_ESP_Highlight"
                highlight.Adornee = character
                highlight.FillColor = color
                highlight.OutlineColor = outlineColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0.3
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = character
                
                table.insert(ESPModules.Survivor.Chams.Highlights, highlight)
            end
        end
    end
end

-- Killer Skeleton
local function updateKillerSkeleton(enabled, color, outlineColor)
    if ESPModules.Killer.Skeleton.Connection then
        ESPModules.Killer.Skeleton.Connection:Disconnect()
        ESPModules.Killer.Skeleton.Connection = nil
    end
    
    for _, line in pairs(ESPModules.Killer.Skeleton.Lines) do
        if line then line:Destroy() end
    end
    ESPModules.Killer.Skeleton.Lines = {}
    
    if not enabled then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KillerSkeletonGUI"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local R15_STRUCTURE = {
        {"Head", "UpperTorso"}, 
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    }
    
    ESPModules.Killer.Skeleton.Connection = RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local hum = char:FindFirstChild("Humanoid")
                
                if hum and hum.Health > 0 and getPlayerTeam(player) == "Killer" then
                    for i, connection in ipairs(R15_STRUCTURE) do
                        local partA = char:FindFirstChild(connection[1])
                        local partB = char:FindFirstChild(connection[2])
                        
                        if partA and partB then
                            local posA, visA = workspace.CurrentCamera:WorldToViewportPoint(partA.Position)
                            local posB, visB = workspace.CurrentCamera:WorldToViewportPoint(partB.Position)
                            
                            -- ОБНОВЛЕНИЕ: Проверяем, что ОБЕ точки в поле зрения
                            if visA and visB then
                                local line = ESPModules.Killer.Skeleton.Lines[player.Name .. i]
                                if not line then
                                    line = Instance.new("Frame")
                                    line.Name = "Killer_Skeleton_Line"
                                    line.BackgroundColor3 = color
                                    line.BorderSizePixel = 0
                                    line.AnchorPoint = Vector2.new(0.5, 0.5)
                                    line.Parent = screenGui
                                    ESPModules.Killer.Skeleton.Lines[player.Name .. i] = line
                                end
                                
                                local start2d = Vector2.new(posA.X, posA.Y)
                                local end2d = Vector2.new(posB.X, posB.Y)
                                local diff = end2d - start2d
                                
                                line.Size = UDim2.new(0, diff.Magnitude, 0, 1.5)
                                line.Position = UDim2.new(0, start2d.X + (diff.X / 2), 0, start2d.Y + (diff.Y / 2))
                                line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
                                line.Visible = true
                            else
                                -- Скрываем линию, если игрок не в поле зрения
                                local line = ESPModules.Killer.Skeleton.Lines[player.Name .. i]
                                if line then
                                    line.Visible = false
                                end
                            end
                        else
                            -- Скрываем линию, если части тела не найдены
                            local line = ESPModules.Killer.Skeleton.Lines[player.Name .. i]
                            if line then
                                line.Visible = false
                            end
                        end
                    end
                else
                    -- Скрываем все линии, если игрок мертв или не убийца
                    for i = 1, #R15_STRUCTURE do
                        local line = ESPModules.Killer.Skeleton.Lines[player.Name .. i]
                        if line then
                            line.Visible = false
                        end
                    end
                end
            else
                -- Скрываем все линии, если игрок вышел
                for i = 1, #R15_STRUCTURE do
                    local line = ESPModules.Killer.Skeleton.Lines[player.Name .. i]
                    if line then
                        line.Visible = false
                    end
                end
            end
        end
    end)
end

-- Survivor Skeleton
local function updateSurvivorSkeleton(enabled, color, outlineColor)
    if ESPModules.Survivor.Skeleton.Connection then
        ESPModules.Survivor.Skeleton.Connection:Disconnect()
        ESPModules.Survivor.Skeleton.Connection = nil
    end
    
    for _, line in pairs(ESPModules.Survivor.Skeleton.Lines) do
        if line then line:Destroy() end
    end
    ESPModules.Survivor.Skeleton.Lines = {}
    
    if not enabled then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SurvivorSkeletonGUI"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local R15_STRUCTURE = {
        {"Head", "UpperTorso"}, 
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    }
    
    ESPModules.Survivor.Skeleton.Connection = RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local hum = char:FindFirstChild("Humanoid")
                
                if hum and hum.Health > 0 and getPlayerTeam(player) == "Survivor" then
                    for i, connection in ipairs(R15_STRUCTURE) do
                        local partA = char:FindFirstChild(connection[1])
                        local partB = char:FindFirstChild(connection[2])
                        
                        if partA and partB then
                            local posA, visA = workspace.CurrentCamera:WorldToViewportPoint(partA.Position)
                            local posB, visB = workspace.CurrentCamera:WorldToViewportPoint(partB.Position)
                            
                            -- ОБНОВЛЕНИЕ: Проверяем, что ОБЕ точки в поле зрения
                            if visA and visB then
                                local line = ESPModules.Survivor.Skeleton.Lines[player.Name .. i]
                                if not line then
                                    line = Instance.new("Frame")
                                    line.Name = "Survivor_Skeleton_Line"
                                    line.BackgroundColor3 = color
                                    line.BorderSizePixel = 0
                                    line.AnchorPoint = Vector2.new(0.5, 0.5)
                                    line.Parent = screenGui
                                    ESPModules.Survivor.Skeleton.Lines[player.Name .. i] = line
                                end
                                
                                local start2d = Vector2.new(posA.X, posA.Y)
                                local end2d = Vector2.new(posB.X, posB.Y)
                                local diff = end2d - start2d
                                
                                line.Size = UDim2.new(0, diff.Magnitude, 0, 1.5)
                                line.Position = UDim2.new(0, start2d.X + (diff.X / 2), 0, start2d.Y + (diff.Y / 2))
                                line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
                                line.Visible = true
                            else
                                -- Скрываем линию, если игрок не в поле зрения
                                local line = ESPModules.Survivor.Skeleton.Lines[player.Name .. i]
                                if line then
                                    line.Visible = false
                                end
                            end
                        else
                            -- Скрываем линию, если части тела не найдены
                            local line = ESPModules.Survivor.Skeleton.Lines[player.Name .. i]
                            if line then
                                line.Visible = false
                            end
                        end
                    end
                else
                    -- Скрываем все линии, если игрок мертв или не выживший
                    for i = 1, #R15_STRUCTURE do
                        local line = ESPModules.Survivor.Skeleton.Lines[player.Name .. i]
                        if line then
                            line.Visible = false
                        end
                    end
                end
            else
                -- Скрываем все линии, если игрок вышел
                for i = 1, #R15_STRUCTURE do
                    local line = ESPModules.Survivor.Skeleton.Lines[player.Name .. i]
                    if line then
                        line.Visible = false
                    end
                end
            end
        end
    end)
end

-- Killer Names (ИСПРАВЛЕННАЯ ВЕРСИЯ)
local function updateKillerNames(enabled, color, outlineColor, size)
    if ESPModules.Killer.Names.Connection then
        ESPModules.Killer.Names.Connection:Disconnect()
        ESPModules.Killer.Names.Connection = nil
    end
    
    for _, label in pairs(ESPModules.Killer.Names.Labels) do
        if label then label:Destroy() end
    end
    ESPModules.Killer.Names.Labels = {}
    
    if not enabled then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KillerNamesESP"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local textSize = 16
    if size ~= "Auto" and type(size) == "number" then
        textSize = math.clamp(size, 10, 30)
    end
    
    ESPModules.Killer.Names.Connection = RunService.RenderStepped:Connect(function()
        -- Создаем временный список активных игроков
        local activePlayers = {}
        for _, player in pairs(Players:GetPlayers()) do
            activePlayers[player] = true
        end
        
        -- Очищаем метки для игроков, которых больше нет в игре
        for player, label in pairs(ESPModules.Killer.Names.Labels) do
            if not activePlayers[player] and label then
                label:Destroy()
                ESPModules.Killer.Names.Labels[player] = nil
            end
        end
        
        -- Обновляем метки для активных игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and LocalPlayer.Character then
                local character = player.Character
                local head = character:FindFirstChild("Head")
                local humanoid = character:FindFirstChild("Humanoid")
                local localHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if head and humanoid and humanoid.Health > 0 and localHrp and getPlayerTeam(player) == "Killer" then
                    local label = ESPModules.Killer.Names.Labels[player]
                    if not label then
                        label = Instance.new("TextLabel")
                        label.Name = "Killer_" .. player.Name
                        label.Parent = screenGui
                        label.BackgroundTransparency = 1
                        label.Size = UDim2.new(0, 200, 0, 28)
                        label.TextColor3 = color
                        label.Font = Enum.Font.RobotoMono
                        label.TextSize = textSize
                        label.TextStrokeColor3 = outlineColor
                        label.TextStrokeTransparency = 0.3
                        label.Text = player.Name
                        ESPModules.Killer.Names.Labels[player] = label
                    end
                    
                    local namePosition = head.Position + Vector3.new(0, 3.5, 0)
                    local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(namePosition)
                    
                    if onScreen then
                        label.Position = UDim2.new(0, vector.X - 100, 0, vector.Y)
                        label.Visible = true
                    else
                        label.Visible = false
                    end
                else
                    if ESPModules.Killer.Names.Labels[player] then
                        ESPModules.Killer.Names.Labels[player].Visible = false
                    end
                end
            else
                if ESPModules.Killer.Names.Labels[player] then
                    ESPModules.Killer.Names.Labels[player].Visible = false
                end
            end
        end
    end)
end

-- Survivor Names (ИСПРАВЛЕННАЯ ВЕРСИЯ)
local function updateSurvivorNames(enabled, color, outlineColor, size)
    if ESPModules.Survivor.Names.Connection then
        ESPModules.Survivor.Names.Connection:Disconnect()
        ESPModules.Survivor.Names.Connection = nil
    end
    
    for _, label in pairs(ESPModules.Survivor.Names.Labels) do
        if label then label:Destroy() end
    end
    ESPModules.Survivor.Names.Labels = {}
    
    if not enabled then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SurvivorNamesESP"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local textSize = 14
    if size ~= "Auto" and type(size) == "number" then
        textSize = math.clamp(size, 10, 30)
    end
    
    ESPModules.Survivor.Names.Connection = RunService.RenderStepped:Connect(function()
        -- Создаем временный список активных игроков
        local activePlayers = {}
        for _, player in pairs(Players:GetPlayers()) do
            activePlayers[player] = true
        end
        
        -- Очищаем метки для игроков, которых больше нет в игре
        for player, label in pairs(ESPModules.Survivor.Names.Labels) do
            if not activePlayers[player] and label then
                label:Destroy()
                ESPModules.Survivor.Names.Labels[player] = nil
            end
        end
        
        -- Обновляем метки для активных игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and LocalPlayer.Character then
                local character = player.Character
                local head = character:FindFirstChild("Head")
                local humanoid = character:FindFirstChild("Humanoid")
                local localHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if head and humanoid and humanoid.Health > 0 and localHrp and getPlayerTeam(player) == "Survivor" then
                    local label = ESPModules.Survivor.Names.Labels[player]
                    if not label then
                        label = Instance.new("TextLabel")
                        label.Name = "Survivor_" .. player.Name
                        label.Parent = screenGui
                        label.BackgroundTransparency = 1
                        label.Size = UDim2.new(0, 200, 0, 28)
                        label.TextColor3 = color
                        label.Font = Enum.Font.RobotoMono
                        label.TextSize = textSize
                        label.TextStrokeColor3 = outlineColor
                        label.TextStrokeTransparency = 0.5
                        label.Text = player.Name
                        ESPModules.Survivor.Names.Labels[player] = label
                    end
                    
                    local namePosition = head.Position + Vector3.new(0, 3.0, 0)
                    local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(namePosition)
                    
                    if onScreen then
                        label.Position = UDim2.new(0, vector.X - 100, 0, vector.Y)
                        label.Visible = true
                    else
                        label.Visible = false
                    end
                else
                    if ESPModules.Survivor.Names.Labels[player] then
                        ESPModules.Survivor.Names.Labels[player].Visible = false
                    end
                end
            else
                if ESPModules.Survivor.Names.Labels[player] then
                    ESPModules.Survivor.Names.Labels[player].Visible = false
                end
            end
        end
    end)
end

-- Killer Distance (ИСПРАВЛЕННАЯ ВЕРСИЯ)
local function updateKillerDistance(enabled, color, outlineColor, size)
    if ESPModules.Killer.Distance.Connection then
        ESPModules.Killer.Distance.Connection:Disconnect()
        ESPModules.Killer.Distance.Connection = nil
    end
    
    for _, label in pairs(ESPModules.Killer.Distance.Labels) do
        if label then label:Destroy() end
    end
    ESPModules.Killer.Distance.Labels = {}
    
    if not enabled then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KillerDistanceESP"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local textSize = 12
    if size ~= "Auto" and type(size) == "number" then
        textSize = math.clamp(size, 8, 24)
    end
    
    ESPModules.Killer.Distance.Connection = RunService.RenderStepped:Connect(function()
        -- Создаем временный список активных игроков
        local activePlayers = {}
        for _, player in pairs(Players:GetPlayers()) do
            activePlayers[player] = true
        end
        
        -- Очищаем метки для игроков, которых больше нет в игре
        for player, label in pairs(ESPModules.Killer.Distance.Labels) do
            if not activePlayers[player] and label then
                label:Destroy()
                ESPModules.Killer.Distance.Labels[player] = nil
            end
        end
        
        -- Обновляем метки для активных игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and LocalPlayer.Character then
                local character = player.Character
                local humanoid = character:FindFirstChild("Humanoid")
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local localHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if hrp and humanoid and humanoid.Health > 0 and localHrp and getPlayerTeam(player) == "Killer" then
                    local label = ESPModules.Killer.Distance.Labels[player]
                    if not label then
                        label = Instance.new("TextLabel")
                        label.Name = "Killer_Distance_" .. player.Name
                        label.Parent = screenGui
                        label.BackgroundTransparency = 1
                        label.Size = UDim2.new(0, 120, 0, 25)
                        label.TextColor3 = color
                        label.Font = Enum.Font.RobotoMono
                        label.TextSize = textSize
                        label.TextStrokeColor3 = outlineColor
                        label.TextStrokeTransparency = 0.5
                        ESPModules.Killer.Distance.Labels[player] = label
                    end
                    
                    local footPosition = hrp.Position - Vector3.new(0, 2.5, 0)
                    local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(footPosition)
                    
                    if onScreen then
                        local distanceStuds = (hrp.Position - localHrp.Position).Magnitude
                        local distanceMeters = math.floor(distanceStuds / 3.57)
                        label.Text = distanceMeters .. " m"
                        label.Position = UDim2.new(0, vector.X - 60, 0, vector.Y)
                        label.Visible = true
                    else
                        label.Visible = false
                    end
                else
                    if ESPModules.Killer.Distance.Labels[player] then
                        ESPModules.Killer.Distance.Labels[player].Visible = false
                    end
                end
            else
                if ESPModules.Killer.Distance.Labels[player] then
                    ESPModules.Killer.Distance.Labels[player].Visible = false
                end
            end
        end
    end)
end

-- Survivor Distance (ИСПРАВЛЕННАЯ ВЕРСИЯ)
local function updateSurvivorDistance(enabled, color, outlineColor, size)
    if ESPModules.Survivor.Distance.Connection then
        ESPModules.Survivor.Distance.Connection:Disconnect()
        ESPModules.Survivor.Distance.Connection = nil
    end
    
    for _, label in pairs(ESPModules.Survivor.Distance.Labels) do
        if label then label:Destroy() end
    end
    ESPModules.Survivor.Distance.Labels = {}
    
    if not enabled then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SurvivorDistanceESP"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local textSize = 12
    if size ~= "Auto" and type(size) == "number" then
        textSize = math.clamp(size, 8, 24)
    end
    
    ESPModules.Survivor.Distance.Connection = RunService.RenderStepped:Connect(function()
        -- Создаем временный список активных игроков
        local activePlayers = {}
        for _, player in pairs(Players:GetPlayers()) do
            activePlayers[player] = true
        end
        
        -- Очищаем метки для игроков, которых больше нет в игре
        for player, label in pairs(ESPModules.Survivor.Distance.Labels) do
            if not activePlayers[player] and label then
                label:Destroy()
                ESPModules.Survivor.Distance.Labels[player] = nil
            end
        end
        
        -- Обновляем метки для активных игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and LocalPlayer.Character then
                local character = player.Character
                local humanoid = character:FindFirstChild("Humanoid")
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local localHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if hrp and humanoid and humanoid.Health > 0 and localHrp and getPlayerTeam(player) == "Survivor" then
                    local label = ESPModules.Survivor.Distance.Labels[player]
                    if not label then
                        label = Instance.new("TextLabel")
                        label.Name = "Survivor_Distance_" .. player.Name
                        label.Parent = screenGui
                        label.BackgroundTransparency = 1
                        label.Size = UDim2.new(0, 120, 0, 25)
                        label.TextColor3 = color
                        label.Font = Enum.Font.RobotoMono
                        label.TextSize = textSize
                        label.TextStrokeColor3 = outlineColor
                        label.TextStrokeTransparency = 0.5
                        ESPModules.Survivor.Distance.Labels[player] = label
                    end
                    
                    local footPosition = hrp.Position - Vector3.new(0, 2.5, 0)
                    local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(footPosition)
                    
                    if onScreen then
                        local distanceStuds = (hrp.Position - localHrp.Position).Magnitude
                        local distanceMeters = math.floor(distanceStuds / 3.57)
                        label.Text = distanceMeters .. " m"
                        label.Position = UDim2.new(0, vector.X - 60, 0, vector.Y)
                        label.Visible = true
                    else
                        label.Visible = false
                    end
                else
                    if ESPModules.Survivor.Distance.Labels[player] then
                        ESPModules.Survivor.Distance.Labels[player].Visible = false
                    end
                end
            else
                if ESPModules.Survivor.Distance.Labels[player] then
                    ESPModules.Survivor.Distance.Labels[player].Visible = false
                end
            end
        end
    end)
end

-- Custom Killerlight
local function updateKillerlight(enabled, color, outlineColor)
    if ESPModules.Killer.Killerlight.Connection then
        ESPModules.Killer.Killerlight.Connection:Disconnect()
        ESPModules.Killer.Killerlight.Connection = nil
    end
    
    if not enabled then return end
    
    ESPModules.Killer.Killerlight.Connection = RunService.Heartbeat:Connect(function()
        -- Workspace Beams
        local beamsFolder = workspace:FindFirstChild("Beams")
        if beamsFolder then
            for _, part in ipairs(beamsFolder:GetDescendants()) do
                if part:IsA("BasePart") and string.find(part.Name:lower(), "redstain") then
                    part.Color = color
                end
            end
        end
        
        -- Players
        for _, player in pairs(Players:GetPlayers()) do
            local character = player.Character
            if character and character:FindFirstChild("Head") then
                local head = character.Head
                for _, child in ipairs(head:GetChildren()) do
                    if child:IsA("SurfaceLight") and string.find(child.Name:lower(), "redstain") then
                        child.Color = color
                    end
                end
            end
        end
    end)
end

-- Object ESP Functions
local function updateObjectESP(objectType, enabled, color, outlineColor)
    if ESPModules.Objects[objectType] and ESPModules.Objects[objectType].Highlights then
        for _, highlight in pairs(ESPModules.Objects[objectType].Highlights) do
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end
        ESPModules.Objects[objectType].Highlights = {}
    end
    
    if not enabled then return end
    
    local baseNames = {
        Chests = "Chest",
        Hatch = "Hatch",
        Lockers = "Hiding_Spot",
        Hooks = "Hook",
        Pallets = "Pallet",
        Windows = "Window",
        Exits = "Wall_Mount",
        Totems = "Totem",
        Generators = "Generator"
    }
    
    local exactMatch = {
        Chests = false,
        Hatch = true,
        Lockers = false,
        Hooks = false,
        Pallets = false,
        Windows = false,
        Exits = true,
        Totems = false,
        Generators = false
    }
    
    local baseName = baseNames[objectType]
    if not baseName then return end
    
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("BasePart") or descendant:IsA("Model") then
            local name = descendant.Name
            
            local match = false
            if exactMatch[objectType] then
                if name == baseName then
                    match = true
                end
            else
                if string.find(name, baseName) == 1 then
                    match = true
                end
            end
            
            if match then
                local highlight = Instance.new("Highlight")
                highlight.Name = objectType .. "_ESP_Highlight"
                highlight.Adornee = descendant
                highlight.FillColor = color
                highlight.OutlineColor = outlineColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0.3
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = descendant
                
                table.insert(ESPModules.Objects[objectType].Highlights, highlight)
            end
        end
    end
end

-- Generators Progress (ИСПРАВЛЕННАЯ ВЕРСИЯ БЕЗ PRINT)
local function updateGeneratorsProgress(enabled)
    -- Останавливаем предыдущее соединение если было
    if ESPModules.Objects.GeneratorsProgress.Connection then
        ESPModules.Objects.GeneratorsProgress.Connection:Disconnect()
        ESPModules.Objects.GeneratorsProgress.Connection = nil
    end
    
    -- Удаляем все существующие BillboardGui
    for _, billboard in pairs(ESPModules.Objects.GeneratorsProgress.Billboards) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    ESPModules.Objects.GeneratorsProgress.Billboards = {}
    
    -- Удаляем ScreenGui если он есть
    if ESPModules.Objects.GeneratorsProgress.ScreenGui then
        ESPModules.Objects.GeneratorsProgress.ScreenGui:Destroy()
        ESPModules.Objects.GeneratorsProgress.ScreenGui = nil
    end
    
    if not enabled then return end
    
    -- Создаем ScreenGui для отображения Billboard
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GeneratorsProgressGUI"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Функция для получения прогресса генератора
    local function getGeneratorProgress(generator)
        if not generator or not generator.Parent then
            return 0
        end
        
        -- Ищем атрибуты
        for attrName, attrValue in pairs(generator:GetAttributes()) do
            if type(attrValue) == "number" then
                local attrLower = attrName:lower()
                if attrLower:find("progress") or attrLower:find("value") or attrLower:find("repair") then
                    local value = attrValue
                    -- Если значение 0-1000, конвертируем в проценты
                    if value <= 1000 and value >= 0 then
                        return math.floor((value / 1000) * 100)
                    end
                    -- Если уже 0-100
                    if value <= 100 and value >= 0 then
                        return math.floor(value)
                    end
                end
            end
        end
        
        -- Ищем NumberValue/IntValue
        for _, child in pairs(generator:GetDescendants()) do
            if (child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("StringValue")) then
                local childName = child.Name:lower()
                if childName:find("progress") or childName:find("value") then
                    local value = tonumber(child.Value) or 0
                    if value <= 1000 and value >= 0 then
                        return math.floor((value / 1000) * 100)
                    end
                    if value <= 100 and value >= 0 then
                        return math.floor(value)
                    end
                end
            end
        end
        
        return 0
    end
    
    -- Находим все генераторы
    local generators = {}
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") and string.find(descendant.Name:lower(), "generator") then
            table.insert(generators, descendant)
        end
    end
    
    -- Функция для получения позиции генератора
    local function getGeneratorPosition(generator)
        if not generator then return Vector3.new(0, 0, 0) end
        
        -- Пробуем разные части генератора
        local head = generator:FindFirstChild("Head")
        if head then return head.Position end
        
        local panel = generator:FindFirstChild("Panel")
        if panel and panel:IsA("BasePart") then return panel.Position end
        
        local primaryPart = generator.PrimaryPart
        if primaryPart then return primaryPart.Position end
        
        -- Ищем любую BasePart
        for _, child in pairs(generator:GetChildren()) do
            if child:IsA("BasePart") then
                return child.Position
            end
        end
        
        -- Если ничего не нашли, возвращаем позицию модели
        return generator:GetPivot().Position
    end
    
    -- Функция создания TextLabel для прогресса
    local function createProgressLabel(generator)
        if not generator then return nil end
        
        local label = Instance.new("TextLabel")
        label.Name = "GeneratorProgress_" .. generator.Name
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0, 70, 0, 22)
        label.Text = "0%"
        label.TextColor3 = Color3.fromRGB(153, 153, 153)
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.TextSize = 13
        label.Font = Enum.Font.GothamSemibold
        label.Visible = false
        label.Parent = screenGui
        
        -- Сохраняем ссылку
        ESPModules.Objects.GeneratorsProgress.Billboards[generator] = label
        
        return label
    end
    
    -- Создаем метки для всех генераторов
    for _, generator in ipairs(generators) do
        if generator and generator.Parent then
            createProgressLabel(generator)
        end
    end
    
    -- Запускаем цикл обновления позиций и прогресса
    ESPModules.Objects.GeneratorsProgress.Connection = RunService.RenderStepped:Connect(function()
        for generator, label in pairs(ESPModules.Objects.GeneratorsProgress.Billboards) do
            if generator and generator.Parent and label and label.Parent then
                -- Получаем прогресс
                local progress = getGeneratorProgress(generator)
                
                -- Получаем позицию генератора в мировых координатах
                local position = getGeneratorPosition(generator)
                
                -- Конвертируем мировые координаты в экранные
                local camera = workspace.CurrentCamera
                local screenPoint, onScreen = camera:WorldToViewportPoint(position + Vector3.new(0, 2.5, 0))
                
                if onScreen then
                    -- Обновляем позицию и текст
                    label.Position = UDim2.new(0, screenPoint.X - 35, 0, screenPoint.Y)
                    label.Text = tostring(progress) .. "%"
                    
                    -- Меняем цвет в зависимости от прогресса
                    if progress == 0 then
                        label.TextColor3 = Color3.fromRGB(153, 153, 153)
                    elseif progress < 25 then
                        label.TextColor3 = Color3.fromRGB(255, 50, 50)
                    elseif progress < 50 then
                        label.TextColor3 = Color3.fromRGB(255, 165, 0)
                    elseif progress < 75 then
                        label.TextColor3 = Color3.fromRGB(255, 255, 0)
                    else
                        label.TextColor3 = Color3.fromRGB(50, 255, 50)
                    end
                    
                    label.Visible = true
                else
                    label.Visible = false
                end
            else
                -- Удаляем несуществующую метку
                if label then
                    label:Destroy()
                end
                ESPModules.Objects.GeneratorsProgress.Billboards[generator] = nil
            end
        end
    end)
    
    -- Сохраняем ссылку на ScreenGui для последующего удаления
    ESPModules.Objects.GeneratorsProgress.ScreenGui = screenGui
end

--// RAGE XYETA 

--// Функция для Block All Hooks
local function updateBlockHooks(enabled)
    if RageModules.BlockHooks.Connection then
        RageModules.BlockHooks.Connection:Disconnect()
        RageModules.BlockHooks.Connection = nil
    end
    
    if not enabled then return end
    
    local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
    local Cheat = RemoteStorage:WaitForChild('NewPropertie')
    
    local function Obfuscate(TYPE, VALUE1, VALUE2)
        local tablev = {}
        local List = {"Bbh1O", "D9v8", "Dbh1O", "Dvh1O", "Dhv8"}
        
        TYPE = string.lower(TYPE)
        
        if TYPE == 'string' then
            TYPE = 'S101'
        elseif TYPE == 'object' then
            TYPE = 'O101'
        elseif TYPE == 'number' then
            TYPE = 'I101'
        elseif TYPE == 'bool' then
            TYPE = 'B101'
        elseif TYPE == "destroy" or TYPE == "REMOVE" then
            VALUE2 = nil
            TYPE = "D101"
        end
        
        local Packaged = {
            ['C22'] = TYPE;
            ['C21'] = VALUE1;
            ['C20'] = VALUE2;
        }
        
        for _,key in pairs(List) do
            tablev[key] = Packaged
        end
        
        Cheat:FireServer(tablev)
    end
    
    RageModules.BlockHooks.Connection = game:GetService("RunService").RenderStepped:Connect(function()
        for i, Objs in pairs(workspace:GetChildren()) do
            if Objs:IsA("Model") and (string.match(Objs.Name, "Exit") or string.match(Objs.Name, "Hook") or string.match(Objs.Name,"Generator") and (Objs:FindFirstChild("Panel") ~= nil)) then
                if string.match(Objs.Name, "Hook") then
                    Obfuscate('bool',Objs["Panel"]["Blocked"],true)
                    Obfuscate('bool',Objs["Panel"]["Used"],true)
                end
            end
        end
    end)
end

--// Функция для Finish All Gens
local function updateFinishGens(enabled)
    if RageModules.FinishGens.Connection then
        RageModules.FinishGens.Connection:Disconnect()
        RageModules.FinishGens.Connection = nil
    end
    
    if not enabled then return end
    
    local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
    local Cheat = RemoteStorage:WaitForChild('NewPropertie')
    
    local function Obfuscate(TYPE, VALUE1, VALUE2)
        local tablev = {}
        local List = {"Bbh1O", "D9v8", "Dbh1O", "Dvh1O", "Dhv8"}
        
        TYPE = string.lower(TYPE)
        
        if TYPE == 'string' then
            TYPE = 'S101'
        elseif TYPE == 'object' then
            TYPE = 'O101'
        elseif TYPE == 'number' then
            TYPE = 'I101'
        elseif TYPE == 'bool' then
            TYPE = 'B101'
        elseif TYPE == "destroy" or TYPE == "REMOVE" then
            VALUE2 = nil
            TYPE = "D101"
        end
        
        local Packaged = {
            ['C22'] = TYPE;
            ['C21'] = VALUE1;
            ['C20'] = VALUE2;
        }
        
        for _,key in pairs(List) do
            tablev[key] = Packaged
        end
        
        Cheat:FireServer(tablev)
    end
    
    RageModules.FinishGens.Connection = game:GetService("RunService").RenderStepped:Connect(function()
        for i, Objs in pairs(workspace:GetChildren()) do
            if Objs:IsA("Model") and (string.match(Objs.Name, "Pallet") or string.match(Objs.Name, "Window") or string.match(Objs.Name,"Generator") and (Objs:FindFirstChild("Panel") ~= nil)) then
                if string.match(Objs.Name, "Generator") then
                    Obfuscate('number',Objs["Panel"]["Progress"],1000)
                end
            end
        end
    end)
end

--// Функция для Gate Never Open
local function updateGateNeverOpen(enabled)
    if RageModules.GateNeverOpen.Connection then
        RageModules.GateNeverOpen.Connection:Disconnect()
        RageModules.GateNeverOpen.Connection = nil
    end
    
    if not enabled then return end
    
    local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
    local Cheat = RemoteStorage:WaitForChild('NewPropertie')
    
    local function Obfuscate(TYPE, VALUE1, VALUE2)
        local tablev = {}
        local List = {"Bbh1O", "D9v8", "Dbh1O", "Dvh1O", "Dhv8"}
        
        TYPE = string.lower(TYPE)
        
        if TYPE == 'string' then
            TYPE = 'S101'
        elseif TYPE == 'object' then
            TYPE = 'O101'
        elseif TYPE == 'number' then
            TYPE = 'I101'
        elseif TYPE == 'bool' then
            TYPE = 'B101'
        elseif TYPE == "destroy" or TYPE == "REMOVE" then
            VALUE2 = nil
            TYPE = "D101"
        end
        
        local Packaged = {
            ['C22'] = TYPE;
            ['C21'] = VALUE1;
            ['C20'] = VALUE2;
        }
        
        for _,key in pairs(List) do
            tablev[key] = Packaged
        end
        
        Cheat:FireServer(tablev)
    end
    
    RageModules.GateNeverOpen.Connection = game:GetService("RunService").RenderStepped:Connect(function()
        for i, Objs in pairs(workspace:GetChildren()) do
            if Objs:IsA("Model") and (string.match(Objs.Name, "Exit") or string.match(Objs.Name, "Window") or string.match(Objs.Name,"Generator") and (Objs:FindFirstChild("Panel") ~= nil)) then
                if string.match(Objs.Name, "Exit") then
                    Obfuscate('number',Objs["Panel"]["Progress"],0)
                end
            end
        end
    end)
end

--// Функция для Never Finish Gens
local function updateNeverFinishGens(enabled)
    if RageModules.NeverFinishGens.Connection then
        RageModules.NeverFinishGens.Connection:Disconnect()
        RageModules.NeverFinishGens.Connection = nil
    end
    
    if not enabled then return end
    
    local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
    local Cheat = RemoteStorage:WaitForChild('NewPropertie')
    
    local function Obfuscate(TYPE, VALUE1, VALUE2)
        local tablev = {}
        local List = {"Bbh1O", "D9v8", "Dbh1O", "Dvh1O", "Dhv8"}
        
        TYPE = string.lower(TYPE)
        
        if TYPE == 'string' then
            TYPE = 'S101'
        elseif TYPE == 'object' then
            TYPE = 'O101'
        elseif TYPE == 'number' then
            TYPE = 'I101'
        elseif TYPE == 'bool' then
            TYPE = 'B101'
        elseif TYPE == "destroy" or TYPE == "REMOVE" then
            VALUE2 = nil
            TYPE = "D101"
        end
        
        local Packaged = {
            ['C22'] = TYPE;
            ['C21'] = VALUE1;
            ['C20'] = VALUE2;
        }
        
        for _,key in pairs(List) do
            tablev[key] = Packaged
        end
        
        Cheat:FireServer(tablev)
    end
    
    RageModules.NeverFinishGens.Connection = game:GetService("RunService").RenderStepped:Connect(function()
        for i, Objs in pairs(workspace:GetChildren()) do
            if Objs:IsA("Model") and (string.match(Objs.Name, "Pallet") or string.match(Objs.Name, "Window") or string.match(Objs.Name,"Generator") and (Objs:FindFirstChild("Panel") ~= nil)) then
                if string.match(Objs.Name, "Generator") then
                    Obfuscate('number',Objs["Panel"]["Progress"],0)
                end
            end
        end
    end)
end

--// Функция для Lunge Duration
local function updateLungeDuration(enabled, value)
    if RageModules.LungeDuration.Connection then
        RageModules.LungeDuration.Connection:Disconnect()
        RageModules.LungeDuration.Connection = nil
    end
    
    RageModules.LungeDuration.Value = value or 0.6
    
    if not enabled then return end
    
    local playerName = LocalPlayer.Name
    
    RageModules.LungeDuration.Connection = game:GetService("RunService").Heartbeat:Connect(function()
        local success, result = pcall(function()
            local ugc = game:FindFirstChild("Ugc") or game:GetService("Workspace"):FindFirstChild("Ugc") or game:GetService("Players")
            local playersObj = ugc:FindFirstChild("Players") or (ugc.ClassName == "Players" and ugc)
            
            if playersObj then
                local playerObj = playersObj:FindFirstChild(playerName)
                if playerObj then
                    local playerValues = playerObj:FindFirstChild("PlayerValues")
                    if playerValues then
                        playerValues:SetAttribute("LungeDuration", RageModules.LungeDuration.Value)
                    end
                end
            end
        end)
    end)
end

--// Функция для Hit Someone (исправленная)
local function hitPlayer(player)
    if typeof(player) == "table" then
        -- Если передали таблицу (All)
        for _, p in ipairs(player) do
            if p and p ~= LocalPlayer and p.Character then
                game.ReplicatedStorage:WaitForChild("-LockerAuras"):WaitForChild("Hatchet_Event"):FireServer(p)
            end
        end
    else
        -- Если передали одного игрока
        if player and player ~= LocalPlayer and player.Character then
            game.ReplicatedStorage:WaitForChild("-LockerAuras"):WaitForChild("Hatchet_Event"):FireServer(player)
        end
    end
end

--// Функции для Fly
local flyEnabled = false
local flyConnection, noclipConnection

local function toggleFlight()
    flyEnabled = not flyEnabled
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if flyEnabled then
        if humanoid then humanoid.PlatformStand = true end
        if root then root.Velocity = Vector3.new(0, 0, 0) end
        
        flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if flyEnabled and LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local camera = workspace.CurrentCamera
                
                if root and camera then
                    local forward = camera.CFrame.LookVector
                    local right = camera.CFrame.RightVector
                    local up = Vector3.new(0, 1, 0)
                    
                    local direction = Vector3.new(0, 0, 0)
                    local speed = 25
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + forward end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - forward end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + right end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - right end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + up end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - up end
                    
                    if direction.Magnitude > 0 then
                        direction = direction.Unit * speed
                        root.Velocity = direction
                    else
                        root.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if humanoid then humanoid.PlatformStand = false end
        if root then root.Velocity = Vector3.new(0, 0, 0) end
    end
end

local noclipEnabled = false
local noclipConnection = nil

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if noclipEnabled then
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                -- Агрессивно отключаем ВСЕ коллизии
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.CanTouch = false
                        part.CanQuery = false
                        
                        -- Используем сеттеры через pcall для обхода защиты
                        pcall(function() part.CollisionGroupId = 0 end)
                    end
                end
                
                -- Также для объектов в радиусе 50 studs
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:IsA("BasePart") and (obj.Position - character:GetPivot().Position).Magnitude < 50 then
                        obj.CanCollide = false
                        obj.CanTouch = false
                    end
                end
            end
        end)
    end
end

--// Функция для Stun Killer (исправленная - применяется при каждом нажатии бинда)
local stunKillerEnabled = false
local stunKillerConnection = nil

local function applyStunKillerNow()
    if not stunKillerEnabled then return end
    
    local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
    local Cheat = RemoteStorage:WaitForChild('NewPropertie')
    
    local function Obfuscate(TYPE, VALUE1, VALUE2)
        local tablev = {}
        local List = {"Bbh1O", "D9v8", "Dbh1O", "Dvh1O", "Dhv8"}
        
        TYPE = string.lower(TYPE)
        
        if TYPE == 'string' then
            TYPE = 'S101'
        elseif TYPE == 'object' then
            TYPE = 'O101'
        elseif TYPE == 'number' then
            TYPE = 'I101'
        elseif TYPE == 'bool' then
            TYPE = 'B101'
        elseif TYPE == "destroy" or TYPE == "REMOVE" then
            VALUE2 = nil
            TYPE = "D101"
        end
        
        local Packaged = {
            ['C22'] = TYPE;
            ['C21'] = VALUE1;
            ['C20'] = VALUE2;
        }
        
        for _,key in pairs(List) do
            tablev[key] = Packaged
        end
        
        Cheat:FireServer(tablev)
    end
    
    -- Станим всех убийц
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local isKiller = false
            
            -- Проверяем команду разными способами
            if player.Team and player.Team.Name:lower():find("killer") then
                isKiller = true
            else
                local role = player:GetAttribute("Role") or player:GetAttribute("Team")
                if role and tostring(role):lower():find("killer") then
                    isKiller = true
                end
            end
            
            if isKiller then
                -- Ищем объекты с дополнительными проверками
                local backpack = player:FindFirstChild("Backpack")
                if backpack then
                    local scripts = backpack:FindFirstChild("Scripts")
                    if scripts then
                        local values = scripts:FindFirstChild("values")
                        if values then
                            local stunned = values:FindFirstChild("Stunned")
                            if stunned then
                                -- Применяем стан только если нашли все объекты
                                if stunned:FindFirstChild("Kind") then
                                    Obfuscate("string", stunned.Kind, "Wiggle")
                                end
                                Obfuscate("bool", stunned, true)
                            end
                        end
                    end
                end
            end
        end
    end
end

--// Функции для Hook, PickUp, Drop
local function hookPlayer(player)
    if typeof(player) == "table" then
        for _, p in ipairs(player) do
            if p and p ~= LocalPlayer and p.Character then
                local hook = nil
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name:match("^Hook%d+$") and obj:IsA("Model") then
                        hook = obj
                        break
                    end
                end
                
                if not hook then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name:find("Hook") and obj:IsA("Model") then
                            hook = obj
                            break
                        end
                    end
                end
                
                if hook then
                    local remoteStorage = game.ReplicatedStorage:WaitForChild("RemoteEvents")
                    local ServerEvent = remoteStorage:WaitForChild("Server_Event")
                    ServerEvent:FireServer("Hook", "Hook", p.Character, hook)
                end
            end
        end
    else
        if player and player ~= LocalPlayer and player.Character then
            local hook = nil
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name:match("^Hook%d+$") and obj:IsA("Model") then
                    hook = obj
                    break
                end
            end
            
            if not hook then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name:find("Hook") and obj:IsA("Model") then
                        hook = obj
                        break
                    end
                end
            end
            
            if hook then
                local remoteStorage = game.ReplicatedStorage:WaitForChild("RemoteEvents")
                local ServerEvent = remoteStorage:WaitForChild("Server_Event")
                ServerEvent:FireServer("Hook", "Hook", player.Character, hook)
            end
        end
    end
end

local function pickupPlayer(player)
    if typeof(player) == "table" then
        for _, p in ipairs(player) do
            if p and p ~= LocalPlayer and p.Character then
                local remoteStorage = game.ReplicatedStorage:WaitForChild("RemoteEvents")
                local ServerEvent = remoteStorage:WaitForChild("Server_Event")
                ServerEvent:FireServer("Carry", "Pickup_Default", p)
            end
        end
    else
        if player and player ~= LocalPlayer and player.Character then
            local remoteStorage = game.ReplicatedStorage:WaitForChild("RemoteEvents")
            local ServerEvent = remoteStorage:WaitForChild("Server_Event")
            ServerEvent:FireServer("Carry", "Pickup_Default", player)
        end
    end
end

local function dropPlayer(player)
    if typeof(player) == "table" then
        for _, p in ipairs(player) do
            if p and p ~= LocalPlayer and p.Character then
                local remoteStorage = game.ReplicatedStorage:WaitForChild("RemoteEvents")
                local ServerEvent = remoteStorage:WaitForChild("Server_Event")
                ServerEvent:FireServer("Carry", "Drop_Default", p)
            end
        end
    else
        if player and player ~= LocalPlayer and player.Character then
            local remoteStorage = game.ReplicatedStorage:WaitForChild("RemoteEvents")
            local ServerEvent = remoteStorage:WaitForChild("Server_Event")
            ServerEvent:FireServer("Carry", "Drop_Default", player)
        end
    end
end

--// LEGIT XYETA

-- Fixed Speed Changer (Toggle/Hold биндер)
local fixedSpeedEnabled = false
local fixedSpeedValue = 15
local fixedSpeedOriginalValue = 15
local fixedSpeedConnection = nil

local function updateFixedSpeedChanger(enabled, value)
    fixedSpeedEnabled = enabled
    fixedSpeedValue = value or fixedSpeedValue
    
    if fixedSpeedConnection then
        fixedSpeedConnection:Disconnect()
        fixedSpeedConnection = nil
    end
    
    if enabled then
        fixedSpeedConnection = RunService.Heartbeat:Connect(function()
            local player = Players.LocalPlayer
            local playerName = player.Name
            
            local success = pcall(function()
                local ugc = game:FindFirstChild("Ugc") or 
                           game:GetService("Workspace"):FindFirstChild("Ugc") or 
                           game:GetService("Players")
                
                local playersObj = ugc:FindFirstChild("Players") or 
                                   (ugc.ClassName == "Players" and ugc)
                
                if playersObj then
                    local playerObj = playersObj:FindFirstChild(playerName)
                    if playerObj then
                        local playerValues = playerObj:FindFirstChild("PlayerValues")
                        if playerValues then
                            playerValues:SetAttribute("Speed", fixedSpeedValue)
                        end
                    end
                end
            end)
        end)
    else
        -- Восстанавливаем стандартную скорость
        local player = Players.LocalPlayer
        local playerName = player.Name
        
        pcall(function()
            local ugc = game:FindFirstChild("Ugc") or 
                       game:GetService("Workspace"):FindFirstChild("Ugc") or 
                       game:GetService("Players")
            
            local playersObj = ugc:FindFirstChild("Players") or 
                               (ugc.ClassName == "Players" and ugc)
            
            if playersObj then
                local playerObj = playersObj:FindFirstChild(playerName)
                if playerObj then
                    local playerValues = playerObj:FindFirstChild("PlayerValues")
                    if playerValues then
                        playerValues:SetAttribute("Speed", fixedSpeedOriginalValue)
                    end
                end
            end
        end)
    end
end

-- Vault Speed Changer (Тоггл + слайдер)
local vaultSpeedEnabled = false
local vaultSpeedValue = 1.0 -- Стандартное значение 1
local vaultSpeedConnection = nil

local function updateVaultSpeedChanger(enabled, value)
    vaultSpeedEnabled = enabled
    vaultSpeedValue = value or vaultSpeedValue
    
    if vaultSpeedConnection then
        vaultSpeedConnection:Disconnect()
        vaultSpeedConnection = nil
    end
    
    if enabled then
        vaultSpeedConnection = RunService.Heartbeat:Connect(function()
            local player = Players.LocalPlayer
            local playerName = player.Name
            
            local success = pcall(function()
                local ugc = game:FindFirstChild("Ugc") or 
                           game:GetService("Workspace"):FindFirstChild("Ugc") or 
                           game:GetService("Players")
                
                local playersObj = ugc:FindFirstChild("Players") or 
                                   (ugc.ClassName == "Players" and ugc)
                
                if playersObj then
                    local playerObj = playersObj:FindFirstChild(playerName)
                    if playerObj then
                        local playerValues = playerObj:FindFirstChild("PlayerValues")
                        if playerValues then
                            playerValues:SetAttribute("WindowVaultSpeed", vaultSpeedValue)
                        end
                    end
                end
            end)
        end)
    end
end

local function teleportForward()
    local player = Players.LocalPlayer
    local char = player.Character
    if not char then return end
    
    local look = char:GetPivot().LookVector
    local newPos = char:GetPivot().Position + look * 12
    char:PivotTo(CFrame.new(newPos + Vector3.new(0,2,0)) * char:GetPivot().Rotation)
end

-- NAF (No Anims Freeze) - только Toggle режим
local nafEnabled = false
local nafConnection = nil
local nafMonitorConnection = nil
local nafLastPlatformStand = false
local nafLastAnchored = false

local function updateNAF(enabled)
    nafEnabled = enabled
    
    if nafConnection then
        nafConnection:Disconnect()
        nafConnection = nil
    end
    
    if nafMonitorConnection then
        nafMonitorConnection:Disconnect()
        nafMonitorConnection = nil
    end
    
    if enabled then
        nafConnection = RunService.Heartbeat:Connect(function()
            local player = Players.LocalPlayer
            local char = player.Character
            if not char then return end
            
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local rootPart = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            
            if humanoid and rootPart then
                -- Сохраняем состояния только при первом включении
                if not nafLastPlatformStand and not nafLastAnchored then
                    nafLastPlatformStand = humanoid.PlatformStand
                    nafLastAnchored = rootPart.Anchored
                end
                
                -- Включаем движение
                humanoid.PlatformStand = false
                rootPart.Anchored = false
                rootPart.CanCollide = true
                
                -- Принудительно меняем состояние
                humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                task.wait(0.05)
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
        
        -- Мониторинг для поддержания состояния
        nafMonitorConnection = RunService.Heartbeat:Connect(function()
            local player = Players.LocalPlayer
            local char = player.Character
            if not char then return end
            
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local rootPart = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            
            if humanoid and rootPart then
                if humanoid.PlatformStand == true then
                    humanoid.PlatformStand = false
                end
                
                if rootPart.Anchored == true then
                    rootPart.Anchored = false
                end
            end
        end)
    else
        -- Восстанавливаем предыдущие состояния
        local player = Players.LocalPlayer
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local rootPart = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            
            if humanoid then
                humanoid.PlatformStand = nafLastPlatformStand
            end
            
            if rootPart then
                rootPart.Anchored = nafLastAnchored
            end
            
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
            
            nafLastPlatformStand = false
            nafLastAnchored = false
        end
    end
end


--// Emote Wheel (VISUAL 1:1 REPLICA + FIXED LOGIC)
local emoteWheelGui = nil
local emoteWheelConnections = {}

-- Добавь это в MiscStates, если нет:
EmoteWheel = {Enabled = false}

local function updateEmoteWheel(enabled)
    -- Очистка старого (чтобы не дублировалось)
    if emoteWheelGui then 
        if emoteWheelGui.Parent then emoteWheelGui:Destroy() end
        emoteWheelGui = nil 
    end
    for _, conn in pairs(emoteWheelConnections) do conn:Disconnect() end
    emoteWheelConnections = {}

    if enabled then
        -- 1. Создание GUI (Точь-в-точь как в оригинале)
        emoteWheelGui = Instance.new("ScreenGui")
        emoteWheelGui.Name = "EmoteWheel"
        emoteWheelGui.ResetOnSpawn = false
        
        -- Попытка в CoreGui (как в оригинале), иначе PlayerGui
        local success, _ = pcall(function() 
            emoteWheelGui.Parent = game:GetService("CoreGui") 
        end)
        if not success then 
            emoteWheelGui.Parent = LocalPlayer:WaitForChild("PlayerGui") 
        end

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundTransparency = 1
        bg.Visible = false
        bg.Parent = emoteWheelGui

        -- 2. Данные страниц (Оригинальный список)
        local pages = {
            {
                {name = "Griddy", id = 71864055176836},
                {name = "TakeTheL", id = 107795487146601},
                {name = "SnoopsWalk", id = 110204898807330},
                {name = "ElectroShuffle", id = 138727713064496},
                {name = "Twerk", id = 71683179159204},
                {name = "PopularVibe", id = 93062298566806},
                {name = "OrangeJustice", id = 95127716920692},
                {name = "Floss", id = 80550101607592},
                {name = "Fresh", id = 137039451581216}
            },
            {
                {name = "CaliforniaGirls", id = 96463900850916},
                {name = "GetSturdy", id = 102571052202995},
                {name = "CoffinWalkout", id = 126771729094882},
                {name = "TheRobot", id = 83514960413286},
                {name = "RusDance", id = 119473524290403},
                {name = "SlalomStyle", id = 137139412185781},
                {name = "Zany", id = 90683763183723},
                {name = "ElectroSwing", id = 137750876111662},
                {name = "BillyBounce", id = 133394554631338}
            },
            {
                {name = "DiscoFever", id = 77383821395491},
                {name = "Condition", id = 107828342516230},
                {name = "Drunk", id = 95689071082560},
                {name = "Rollie", id = 125146305865250},
                {name = "Xavier", id = 111079103818250},
                {name = "Flying", id = 127571436160081},
                {name = "Backflip", id = 133675142555339},
                {name = "FestaNoBrasil", id = 82516443009513},
                {name = "RideDaPony", id = 119284187579961}
            },
            {
                {name = "PeacemakerBounce", id = 111906563478881},
                {name = "WhatYouWant", id = 115781688996859},
                {name = "RaceCar", id = 72382226286301},
                {name = "IcySpicyJumping", id = 118896295981144},
                {name = "Shake", id = 103913447080306},
                {name = "BoogieDown", id = 99662142344622},
                {name = "DefaultDance", id = 101011728520473},
                {name = "Rambunctious", id = 129991743366120},
                {name = "Macaroni", id = 71693227925289}
            },
        }

        local currentPage = 1
        local currentTrack = nil
        local buttons = {}
        
        -- Текст страницы (как в оригинале)
        local pageText = Instance.new("TextLabel")
        pageText.Size = UDim2.new(0, 200, 0, 30)
        pageText.Position = UDim2.new(0.5, -100, 0.95, 0)
        pageText.BackgroundTransparency = 1
        pageText.Text = "1/"..#pages
        pageText.TextColor3 = Color3.new(1, 1, 1)
        pageText.Font = Enum.Font.SourceSansBold
        pageText.TextSize = 24
        pageText.Visible = false
        pageText.Parent = bg

        -- 3. Создание кнопок (Круговое меню, радиус 200, 9 кнопок)
        local radius = 200
        local step = 360/9

        for i = 1, 9 do
            local btn = Instance.new("ImageButton")
            btn.Size = UDim2.new(0, 110, 0, 110)
            btn.BackgroundTransparency = 1
            btn.Image = "rbxassetid://3570695787"
            btn.ImageColor3 = Color3.fromRGB(70, 70, 70)
            btn.ImageTransparency = 0.4
            btn.ScaleType = Enum.ScaleType.Slice
            btn.SliceCenter = Rect.new(128, 128, 128, 128)
            btn.Visible = false
            btn.Parent = bg

            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.new(1, 1, 1)
            txt.Font = Enum.Font.SourceSansBold
            txt.TextSize = 22
            txt.TextScaled = false
            txt.Parent = btn

            local ang = math.rad(step * (i - 1) - 90)
            btn.Position = UDim2.new(0.5, math.cos(ang) * radius, 0.5, math.sin(ang) * radius)
            btn.AnchorPoint = Vector2.new(0.5, 0.5)

            table.insert(buttons, {button = btn, text = txt, connection = nil})
        end

        -- 4. Логика
        local function stopEmote()
            if currentTrack then
                currentTrack:Stop()
                currentTrack = nil
            end
        end

        local function playEmote(id)
            stopEmote()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if not hum then return end
            
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. id
            currentTrack = hum:LoadAnimation(anim)
            currentTrack.Priority = Enum.AnimationPriority.Action4 -- Высокий приоритет (как в оригинале)
            currentTrack:Play()
        end

        -- Функция закрытия (Использует глобальные переменные из testr.txt для стабильности)
        local function closeMenu()
            bg.Visible = false
            pageText.Visible = false
            UserInputService.MouseBehavior = LastMouseBehavior 
            UserInputService.MouseIconEnabled = LastMouseIconEnabled
        end
        
        local function openMenu()
            bg.Visible = true
            pageText.Visible = true
            
            LastMouseBehavior = UserInputService.MouseBehavior
            LastMouseIconEnabled = UserInputService.MouseIconEnabled
            
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end

        local function updatePage()
            local pageData = pages[currentPage]
            if not pageData then return end
            
            pageText.Text = currentPage .. "/" .. #pages

            for i = 1, 9 do
                local btnData = buttons[i]
                local emoteData = pageData[i]
                
                if emoteData then
                    btnData.button.Visible = true
                    btnData.text.Text = emoteData.name:gsub("([A-Z])", " %1"):sub(2):gsub(" ", "\n")
                    
                    if btnData.connection then btnData.connection:Disconnect() end
                    
                    btnData.connection = btnData.button.MouseButton1Click:Connect(function()
                        playEmote(emoteData.id)
                        closeMenu()
                    end)
                else
                    btnData.button.Visible = false
                end
            end
        end

        -- Центральная кнопка (стоп) - Большая и прозрачная, как в оригинале
        local centerBtn = Instance.new("TextButton")
        centerBtn.Size = UDim2.new(0, 300, 0, 300)
        centerBtn.Position = UDim2.new(0.5, -150, 0.5, -150)
        centerBtn.BackgroundTransparency = 1
        centerBtn.Text = ""
        centerBtn.Visible = false -- Она включается вместе с меню
        centerBtn.Parent = bg
        
        local stopConn = centerBtn.MouseButton1Click:Connect(function()
            stopEmote()
            closeMenu()
        end)
        table.insert(emoteWheelConnections, stopConn)

        -- Колесико мыши
        local wheelConn = UserInputService.InputChanged:Connect(function(input, gp)
            if gp then return end -- Важное исправление: игнорировать, если игра обрабатывает ввод
            if not bg.Visible then return end
            
            if input.UserInputType == Enum.UserInputType.MouseWheel then
                if input.Position.Z > 0 then
                    currentPage = currentPage - 1
                    if currentPage < 1 then currentPage = #pages end
                else
                    currentPage = currentPage + 1
                    if currentPage > #pages then currentPage = 1 end
                end
                updatePage()
            end
        end)
        table.insert(emoteWheelConnections, wheelConn)

        -- Клавиша активации (например G, настрой под свой бинд)
        local keyConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.B then -- <--- БИНД ТУТ
                if bg.Visible then
                    closeMenu()
                    centerBtn.Visible = false
                else
                    updatePage()
                    openMenu()
                    centerBtn.Visible = true
                end
            end
        end)
        table.insert(emoteWheelConnections, keyConn)
        
        -- Инициализация первой страницы
        updatePage()
    end
end

-- Force Self-Care
local selfCareEnabled = false

local function updateSelfCare(enabled)
    selfCareEnabled = enabled
    
    if enabled then
        -- Запускаем скрипт force-selfcare.txt
        local success, result = pcall(function()
            local Player = Players.LocalPlayer
            local Character = Player.Character or Player.CharacterAdded:Wait()
            local Data = Player:WaitForChild("Data")
            local Perks = Data:WaitForChild("Perks")
            local SurvivorPerks = Perks:WaitForChild("Survivor")
            
            if not SurvivorPerks:FindFirstChild("SelfCare") then
                local selfCarePerk = Instance.new("IntValue")
                selfCarePerk.Name = "SelfCare"
                selfCarePerk.Value = 3
                selfCarePerk:SetAttribute("Slot", "Slot1")
                selfCarePerk.Parent = SurvivorPerks
            end
        end)
        
        if not success then
            warn("Failed to add Self-Care:", result)
        end
    else
        -- Удаляем перк Self-Care
        local Player = Players.LocalPlayer
        pcall(function()
            local Data = Player:WaitForChild("Data")
            local Perks = Data:WaitForChild("Perks")
            local SurvivorPerks = Perks:WaitForChild("Survivor")
            
            local selfCarePerk = SurvivorPerks:FindFirstChild("SelfCare")
            if selfCarePerk then
                selfCarePerk:Destroy()
            end
        end)
    end
end

-- No Collisions
local noCollisionEnabled = false
local noCollisionConnection = nil

local function updateNoCollision(enabled)
    noCollisionEnabled = enabled
    
    if noCollisionConnection then
        noCollisionConnection:Disconnect()
        noCollisionConnection = nil
    end
    
    if enabled then
        -- Удаляем CrouchPrevention
        local P = Players.LocalPlayer.PlayerGui
        pcall(function()
            local crouchPrevention = P:FindFirstChild("CrouchPrevention")
            if crouchPrevention then
                crouchPrevention:Destroy()
            end
        end)
        
        -- Запускаем цикл отключения коллизий
        noCollisionConnection = RunService.Heartbeat:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player == Players.LocalPlayer then continue end
                
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        -- Восстанавливаем коллизии
        for _, player in pairs(Players:GetPlayers()) do
            if player == Players.LocalPlayer then continue end
            
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end

-- Old Animations
local oldAnimationsEnabled = false
local originalAnimations = {}

local function updateOldAnimations(enabled)
    oldAnimationsEnabled = enabled
    
    if enabled then
        -- Сохраняем оригинальные анимации
        local animFolder = game.ReplicatedStorage.Game_Assets.Animations.Movement.Survivor
        for _, anim in pairs(animFolder:GetChildren()) do
            if not originalAnimations[anim.Name] then
                originalAnimations[anim.Name] = {
                    AnimationId = anim.AnimationId,
                    Speed = anim:GetAttribute("Speed")
                }
            end
        end
        
        -- Применяем старые анимации
        local l = {
            ["Default_Crawl_Idle"] = "rbxassetid://16866513397",
            ["Default_Crawl_Walk"] = "rbxassetid://14288523957",
            ["Default_Crouch_Idle"] = "rbxassetid://13417701666",
            ["Default_Crouch_Walk"] = "rbxassetid://13417637304",
            ["Default_Idle"] = "rbxassetid://15929411259",
            ["Default_Injured_Crouch_Idle"] = "rbxassetid://13417692019",
            ["Default_Injured_Crouch_Walk"] = "rbxassetid://13417640847",
            ["Default_Injured_Idle"] = "rbxassetid://13417291384",
            ["Default_Injured_Run"] = "rbxassetid://13417228721",
            ["Default_Injured_Walk"] = "rbxassetid://13417654211",
            ["Default_Run"] = "rbxassetid://13988521481",
            ["Default_Walk"] = "rbxassetid://13417592417",
            ["Medkit_Injured_Run"] = "rbxassetid://8497951749",
            ["Medkit_Run"] = "rbxassetid://13417682705"
        }
        
        local b = {
            ["Default_Crawl_Idle"] = 0.15,
            ["Default_Crawl_Walk"] = 0.45,
            ["Default_Crouch_Idle"] = 0.15,
            ["Default_Crouch_Walk"] = 0.15,
            ["Default_Idle"] = 1,
            ["Default_Injured_Crouch_Idle"] = 1,
            ["Default_Injured_Crouch_Walk"] = 0.15,
            ["Default_Injured_Idle"] = 1,
            ["Default_Injured_Run"] = 0.32,
            ["Default_Injured_Walk"] = 0.1,
            ["Default_Run"] = 0.07000000000000001,
            ["Default_Walk"] = 0.15,
            ["Medkit_Injured_Run"] = 0.15,
            ["Medkit_Run"] = 0.06
        }
        
        for animName, animId in pairs(l) do
            local anim = animFolder:FindFirstChild(animName)
            if anim then
                anim.AnimationId = animId
                anim:SetAttribute("Speed", b[animName])
            end
        end
    else
        -- Восстанавливаем оригинальные анимации
        local animFolder = game.ReplicatedStorage.Game_Assets.Animations.Movement.Survivor
        for animName, data in pairs(originalAnimations) do
            local anim = animFolder:FindFirstChild(animName)
            if anim then
                anim.AnimationId = data.AnimationId
                if data.Speed then
                    anim:SetAttribute("Speed", data.Speed)
                else
                    anim:SetAttribute("Speed", nil)
                end
            end
        end
    end
end

--// MISC XYETA

-- FOV Changer (ИСПРАВЛЕННАЯ - диапазон 40-200)
local fovConnection = nil
local function updateFOVChanger(enabled, value)
    MiscStates.FOVChanger.Enabled = enabled
    MiscStates.FOVChanger.Value = value or MiscStates.FOVChanger.Value
    
    if fovConnection then
        fovConnection:Disconnect()
        fovConnection = nil
    end
    
    if enabled then
        fovConnection = RunService.RenderStepped:Connect(function()
            Camera.FieldOfView = MiscStates.FOVChanger.Value
        end)
    else
        Camera.FieldOfView = 70
    end
end

-- Aspect Ratio Changer (ИСПРАВЛЕННАЯ - диапазон 0.25-1.15, сотые)
local aspectRatioConnection = nil
local function updateAspectRatioChanger(enabled, value)
    MiscStates.AspectRatioChanger.Enabled = enabled
    MiscStates.AspectRatioChanger.Value = value or MiscStates.AspectRatioChanger.Value
    
    if aspectRatioConnection then
        aspectRatioConnection:Disconnect()
        aspectRatioConnection = nil
    end
    
    if enabled then
        aspectRatioConnection = RunService.RenderStepped:Connect(function()
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, MiscStates.AspectRatioChanger.Value, 0, 0, 0, 1)
        end)
    end
end

-- Free Camera (ИСПРАВЛЕННАЯ - полностью отключает бинды)
local freeCameraEnabled = false
local freeCameraContextActions = {}
local freeCameraToggleFunction = nil

local function updateFreeCamera(enabled)
    MiscStates.FreeCamera.Enabled = enabled
    freeCameraEnabled = enabled
    
    if enabled then
        -- Загружаем и запускаем скрипт Free Camera
        local freeCamScript = [[
            -- Функция для активации/деактивации Free Camera извне
            local _FreeCamEnabled = false
            local _FreeCamConnections = {}
            
            function _ToggleFreeCamFromExternal(state)
                _FreeCamEnabled = state
                if not state then
                    -- Отключаем все соединения
                    for _, conn in pairs(_FreeCamConnections) do
                        conn:Disconnect()
                    end
                    _FreeCamConnections = {}
                    
                    -- Отключаем рендерстеп
                    RunService:UnbindFromRenderStep("Freecam")
                    
                    -- Восстанавливаем камеру
                    Camera.CameraType = Enum.CameraType.Custom
                    if LocalPlayer.Character then
                        Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
                    end
                    
                    -- Отвязываем все действия ContextActionService
                    local actionNames = {
                        "FreecamKeyboard", "FreecamMousePan", "FreecamMouseWheel",
                        "FreecamGamepadButton", "FreecamGamepadTrigger", "FreecamGamepadThumbstick",
                        "FreecamToggle"
                    }
                    
                    for _, actionName in pairs(actionNames) do
                        pcall(function()
                            ContextActionService:UnbindAction(actionName)
                        end)
                    end
                end
                return true
            end
        ]]
        
        -- Выполняем настройку перед загрузкой основного скрипта
        loadstring(freeCamScript)()
        
        -- Теперь загружаем основной скрипт
        local success, mainScript = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/misterzalupka322/test-luau-script/refs/heads/main/freec.txt"))()
        end)
        
        if success and mainScript then
            -- Сохраняем ссылку на функцию отключения
            freeCameraToggleFunction = _ToggleFreeCamFromExternal
        else
            warn("Free Camera script failed to load:", mainScript)
        end
    else
        -- Отключаем Free Camera через сохраненную функцию
        if freeCameraToggleFunction then
            pcall(function() freeCameraToggleFunction(false) end)
            freeCameraToggleFunction = nil
        end
        
        -- Дополнительная очистка на всякий случай
        pcall(function()
            RunService:UnbindFromRenderStep("Freecam")
        end)
        
        -- Отвязываем все возможные действия ContextActionService
        local actionNames = {
            "FreecamKeyboard", "FreecamMousePan", "FreecamMouseWheel",
            "FreecamGamepadButton", "FreecamGamepadTrigger", "FreecamGamepadThumbstick",
            "FreecamToggle"
        }
        
        for _, actionName in pairs(actionNames) do
            pcall(function()
                ContextActionService:UnbindAction(actionName)
            end)
        end
        
        -- Восстанавливаем камеру
        pcall(function()
            Camera.CameraType = Enum.CameraType.Custom
            if LocalPlayer.Character then
                Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
            end
            Camera.FieldOfView = 70
        end)
        
        -- Удаляем GUI Free Camera если есть
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui.Name == "FreeCamera" or gui.Name == "Freecam" then
                    gui:Destroy()
                end
            end
        end
        
        -- Восстанавливаем мышь
        UserInputService.MouseIconEnabled = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

-- Flash Progress (ИСПРАВЛЕННАЯ - можно выключать и удалять GUI)
local flashProgressScreenGui = nil
local flashProgressScriptConnection = nil
local function updateFlashProgress(enabled)
    MiscStates.FlashProgress.Enabled = enabled
    
    if enabled then
        -- Загружаем скрипт Flash Progress
        local success, flashScript = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/misterzalupka322/test-luau-script/refs/heads/main/funpay.lua"))()
        end)
        
        if success and flashScript then
            flashProgressScriptConnection = flashScript
        else
            warn("Flash Progress script failed to load:", flashScript)
        end
    else
        -- Уничтожаем интерфейс Flash Progress
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui.Name == "HyperionBlindUI_Perfect" or gui.Name == "FlashProgressGUI" then
                    gui:Destroy()
                end
            end
        end
        
        if flashProgressScriptConnection then
            flashProgressScriptConnection = nil
        end
    end
end

-- Inf Item Charges
local infChargesConnection = nil
local function updateInfItemCharges(enabled)
    MiscStates.InfItemCharges.Enabled = enabled
    
    if infChargesConnection then
        infChargesConnection:Disconnect()
        infChargesConnection = nil
    end
    
    if enabled then
        infChargesConnection = RunService.RenderStepped:Connect(function()
            local V = LocalPlayer.Character
            if V then
                local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
                local Cheat = RemoteStorage:WaitForChild('NewPropertie')
                
                local function Obfuscate(TYPE, VALUE1, VALUE2)
                    local tablev = {}
                    local List = {"Bbh1O", "D9v8", "Dbh1O", "Dvh1O", "Dhv8"}
                    
                    TYPE = string.lower(TYPE)
                    if TYPE == 'string' then TYPE = 'S101'
                    elseif TYPE == 'object' then TYPE = 'O101'
                    elseif TYPE == 'number' then TYPE = 'I101'
                    elseif TYPE == 'bool' then TYPE = 'B101'
                    elseif TYPE == "destroy" or TYPE == "REMOVE" then
                        VALUE2 = nil
                        TYPE = "D101"
                    end
                    
                    local Packaged = {
                        ['C22'] = TYPE;
                        ['C21'] = VALUE1;
                        ['C20'] = VALUE2;
                    }
                    
                    for _,key in pairs(List) do
                        tablev[key] = Packaged
                    end
                    
                    Cheat:FireServer(tablev)
                end
                
                for d, L in pairs(V:GetChildren()) do
                    if L:IsA("Model") and L:GetAttribute("Tool") then
                        L:SetAttribute("Progress", 1000)
                        local Bool = L:FindFirstChildWhichIsA("BoolValue")
                        if Bool ~= nil and Bool.Value == true then
                            Obfuscate("bool", Bool, false)
                        end
                    end
                end
            end
        end)
    end
end
-- Outfit Changer GUI
local outfitChangerScriptConnection = nil
local function updateOutfitChanger(enabled)
    MiscStates.OutfitChanger.Enabled = enabled
    
    if enabled then
        -- Загружаем скрипт Outfit Changer
        local success, outfitScript = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/misterzalupka322/test-luau-script/main/oc.lua"))()
        end)
        
        if success and outfitScript then
            outfitChangerScriptConnection = outfitScript
        else
            warn("Outfit Changer script failed to load:", outfitScript)
        end
    else
        -- Уничтожаем интерфейс Outfit Changer
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        if playerGui then
            -- Удаляем по имени GUI из скрипта
            local cosmeticGui = playerGui:FindFirstChild("CosmeticInjectorGUI")
            if cosmeticGui then
                cosmeticGui:Destroy()
            end
            
            -- Также удаляем дополнительные фреймы, которые могли быть созданы
            local sideFrame = game:GetService("CoreGui"):FindFirstChild("SideFrame")
            local cosmeticFrame = game:GetService("CoreGui"):FindFirstChild("CosmeticFrame")
            
            if sideFrame then sideFrame:Destroy() end
            if cosmeticFrame then cosmeticFrame:Destroy() end
        end
        
        -- Очищаем соединения
        if outfitChangerScriptConnection then
            -- Если скрипт возвращает функцию для очистки, вызываем ее
            if type(outfitChangerScriptConnection) == "function" then
                pcall(function() outfitChangerScriptConnection() end)
            end
            outfitChangerScriptConnection = nil
        end
        
        -- Дополнительная очистка в PlayerGui
        task.wait(0.1) -- Даем время на очистку
        if playerGui then
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui.Name == "CosmeticInjectorGUI" or 
                   gui.Name:find("OutfitChanger") or 
                   gui.Name:find("Cosmetic") then
                    gui:Destroy()
                end
            end
        end
    end
end


--// UI SETUP XYETA 

--// UI Setup
local ScreenGui = Create("ScreenGui", {
    Name = "HyperionV7_Final",
    Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local Main = Create("CanvasGroup", {
    Name = "Main",
    Parent = ScreenGui,
    BackgroundColor3 = Theme.Background,
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(750, 550), 
    AnchorPoint = Vector2.new(0.5, 0.5),
    GroupTransparency = 1, -- Start invisible
    Visible = false
}, { Create("UICorner", {CornerRadius = UDim.new(0, 10)}) })

MakeDraggable(Main, Main)

local CurrentTab = nil 
local CurrentSubTab = nil 
local Tabs = {}
local Pages = {}
local PageColumns = {}
local SubTabContainers = {}
local SubTabs = {}

local Sidebar = Create("Frame", {
    Parent = Main,
    BackgroundColor3 = Theme.Sidebar,
    Size = UDim2.new(0, 180, 1, 0),
    ZIndex = 2
}, {
    Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
    Create("Frame", {
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -5, 0, 0),
        Size = UDim2.new(0, 5, 1, 0),
        ZIndex = 2
    })
})

Create("TextLabel", {
    Parent = Sidebar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 20),
    Size = UDim2.new(0, 140, 0, 30),
    Font = Enum.Font.GothamBold,
    Text = "yeban.cc 1.1",
    TextColor3 = Theme.Accent,
    TextSize = 22,
    TextXAlignment = Enum.TextXAlignment.Left
}, {
    Create("Frame", {
        BackgroundColor3 = Color3.new(1,1,1),
        Size = UDim2.fromOffset(4, 4),
        Position = UDim2.new(0, -8, 0.5, -2)
    }, { Create("UICorner", {CornerRadius = UDim.new(1,0)}) })
})

local Nav = Create("ScrollingFrame", { 
    Parent = Sidebar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 80),
    Size = UDim2.new(1, -20, 1, -160), 
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0,0,0,0)
}, { Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}) })

local Content = Create("Frame", {
    Parent = Main,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 190, 0, 10),
    Size = UDim2.new(1, -200, 1, -20)
})

local Header = Create("Frame", {Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,60)})
Create("TextLabel", {
    Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(0,200,0,30),
    Font = Enum.Font.GothamBold, Text = "Hello, " .. LocalPlayer.DisplayName, TextColor3 = Theme.Text, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Left
})
Create("TextLabel", {
    Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,30), Size = UDim2.new(0,200,0,20),
    Font = Enum.Font.Gotham, Text = "Welcome Back!", TextColor3 = Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
})

local SearchBoxInput
local function UpdateSearch(text)
    text = text:lower()
    local activePage = nil
    for name, page in pairs(Pages) do
        if page.Visible then activePage = page break end
    end
    
    if not activePage then return end
    
    local pageData = PageColumns[activePage]
    if not pageData then return end
    
    local leftCol = pageData.LeftCol
    local rightCol = pageData.RightCol
    
    local function FilterList(list)
        if not list then return end
        for _, panel in pairs(list:GetChildren()) do
            if panel:IsA("Frame") then
                local foundInPanel = false
                local title = panel:FindFirstChild("Title")
                if title and title:IsA("TextLabel") and title.Text:lower():find(text) then
                    foundInPanel = true
                end
                
                local container = panel:FindFirstChild("Container")
                if container then
                    for _, item in pairs(container:GetChildren()) do
                        if item:IsA("Frame") then
                            local itemText = item:FindFirstChild("ItemName")
                            if itemText and itemText.Text:lower():find(text) then
                                item.Visible = true
                                foundInPanel = true
                            elseif itemText then
                                item.Visible = false
                            end
                        end
                    end
                end
                panel.Visible = foundInPanel or (text == "")
            end
        end
    end
    
    FilterList(leftCol)
    FilterList(rightCol)
end

local SearchBar = Create("Frame", {
    Parent = Header, BackgroundColor3 = Theme.Input, Position = UDim2.new(1,-200,0,10), Size = UDim2.new(0,200,0,35)
}, {
    Create("UICorner", {CornerRadius = UDim.new(0,8)}),
    Create("TextLabel", {
        BackgroundTransparency = 1, 
        Size = UDim2.new(0,35,1,0), 
        Text = "🔍",
        TextColor3 = Theme.SubText, 
        TextSize = 14, 
        Font = Enum.Font.Gotham
    })
})
SearchBoxInput = Create("TextBox", {
    Parent = SearchBar,
    BackgroundTransparency = 1, Position = UDim2.new(0,35,0,0), Size = UDim2.new(1,-40,1,0),
    Font = Enum.Font.Gotham, PlaceholderText = "Search", Text = "", TextColor3 = Theme.Text, 
    TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false
})
SearchBoxInput:GetPropertyChangedSignal("Text"):Connect(function()
    UpdateSearch(SearchBoxInput.Text)
end)

local function AnimateContainer(container, show)
    if not container then return end
    local childrenCount = 0
    for _, c in pairs(container:GetChildren()) do
        if c:IsA("TextButton") then childrenCount = childrenCount + 1 end
    end
    local targetHeight = (childrenCount * 30) + (math.max(0, childrenCount - 1) * 2) + 5
    if show then
        container.Visible = true
        TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, targetHeight)
        }):Play()
    else
        TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 0)
        }):Play()
    end
end

local function SwitchTab(tabName, isSubTab)
    -- Функция анимации перехода страниц
    local function AnimatePageTransition(targetPageName)
        for name, page in pairs(Pages) do
            if name == targetPageName then
                -- Подготовка новой страницы
                page.Visible = true
                page.GroupTransparency = 1
                
                -- ИСПРАВЛЕНИЕ: Начальная позиция анимации (70 + 20 = 90)
                page.Position = UDim2.new(0, 0, 0, 90) 
                
                -- Запускаем анимацию появления (выезжает вверх на позицию 70)
                TweenService:Create(page, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    GroupTransparency = 0,
                    Position = UDim2.new(0, 0, 0, 70) -- ИСПРАВЛЕНИЕ: Конечная позиция ровно под шапкой
                }):Play()
            else
                -- Скрываем старые страницы
                page.Visible = false
            end
        end
    end

    if not isSubTab then
        -- Логика для ГЛАВНЫХ вкладок
        if CurrentTab == tabName and SubTabContainers[tabName] then return end
        
        CurrentTab = tabName
        
        for name, btn in pairs(Tabs) do
            local active = (name == tabName)
            
            -- Анимация кнопок
            local targetBgTransparency = active and 0 or 1
            local targetTextColor = active and Theme.Text or Color3.fromRGB(120, 120, 120)
            
            TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundTransparency = targetBgTransparency,
                BackgroundColor3 = active and Theme.Accent or Color3.new(1,1,1)
            }):Play()
            
            if btn:FindFirstChild("Content") then
                TweenService:Create(btn.Content, TweenInfo.new(0.3), {TextColor3 = targetTextColor}):Play()
            end
            
            if SubTabContainers[name] then
                AnimateContainer(SubTabContainers[name], active)
            end
        end
        
        if not SubTabContainers[tabName] then
            AnimatePageTransition(tabName)
            SearchBoxInput.Text = ""
        else
            local container = SubTabContainers[tabName]
            if container then
                local firstSubTabBtn = nil
                for _, child in pairs(container:GetChildren()) do
                    if child:IsA("TextButton") then firstSubTabBtn = child break end
                end
                if firstSubTabBtn then
                    local contentLabel = firstSubTabBtn:FindFirstChild("PageId")
                    if contentLabel then SwitchTab(contentLabel.Text, true) end
                end
            end
        end
        
    else
        -- Логика для ПОДВКЛАДОК
        CurrentSubTab = tabName
        
        for name, btn in pairs(SubTabs) do
            local pageIdLabel = btn:FindFirstChild("PageId")
            local pageId = pageIdLabel and pageIdLabel.Text or ""
            local active = (pageId == tabName)
            
            if btn:FindFirstChild("Content") then
                local targetColor = active and Theme.Text or Color3.fromRGB(140, 140, 140)
                TweenService:Create(btn.Content, TweenInfo.new(0.3), {TextColor3 = targetColor}):Play()
            end
            
            if btn:FindFirstChild("Indicator") then
                TweenService:Create(btn.Indicator, TweenInfo.new(0.3), {
                    BackgroundTransparency = active and 0 or 1,
                    Size = active and UDim2.fromOffset(3, 18) or UDim2.fromOffset(2, 14)
                }):Play()
            end
        end
        
        AnimatePageTransition(tabName)
        SearchBoxInput.Text = ""
    end
end

local function CreateTabButton(text, hasSubTabs)
    local btn = Create("TextButton", {
        Parent = Nav, BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40), Text = "", AutoButtonColor = false
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 8)}) })
    btn.MouseButton1Click:Connect(function() SwitchTab(text) end)
    Create("TextLabel", {
        Name = "Content", Parent = btn, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -15, 1, 0), Font = Enum.Font.GothamBold, Text = text,
        TextColor3 = Color3.fromRGB(120,120,120), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
    })
    Tabs[text] = btn
    if hasSubTabs then
        local subContainer = Create("Frame", {
            Name = text.."_SubContainer", Parent = Nav, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true, Visible = false
        }, {
            Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}),
            Create("UIPadding", {PaddingLeft = UDim.new(0, 10)})
        })
        SubTabContainers[text] = subContainer
        return subContainer
    end
    return nil
end

local function CreateSubTabButton(parent, text, pageIdOverride)
    local targetPageId = pageIdOverride or text
    local btn = Create("TextButton", {
        Parent = parent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Text = "", AutoButtonColor = false
    })
    Create("TextLabel", { Name = "PageId", Parent = btn, Visible = false, Text = targetPageId })
    local indicator = Create("Frame", {
        Name = "Indicator", Parent = btn, BackgroundColor3 = Theme.Accent, Position = UDim2.new(0, 5, 0.5, -7),
        Size = UDim2.fromOffset(2, 14), BackgroundTransparency = 1
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 2)}) })
    Create("TextLabel", {
        Name = "Content", Parent = btn, BackgroundTransparency = 1, Position = UDim2.new(0, 25, 0, 0),
        Size = UDim2.new(1, -25, 1, 0), Font = Enum.Font.GothamMedium, Text = text,
        TextColor3 = Color3.fromRGB(140, 140, 140), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
    })
    btn.MouseButton1Click:Connect(function() SwitchTab(targetPageId, true) end)
    SubTabs[targetPageId] = btn 
    return btn
end

local function CreatePage(name)
    local page = Create("CanvasGroup", {
        Name = name, 
        Parent = Content, 
        BackgroundTransparency = 1, 
        -- ИСПРАВЛЕНИЕ: Ставим позицию 70, чтобы не перекрывать Header
        Position = UDim2.new(0, 0, 0, 70),
        -- ИСПРАВЛЕНИЕ: Вычитаем 70 из высоты, чтобы не вылезало снизу
        Size = UDim2.new(1, 0, 1, -70), 
        Visible = false, 
        GroupTransparency = 1, 
        ClipsDescendants = true,
        BorderSizePixel = 0
    })
    
    local scroll = Create("ScrollingFrame", {
        Parent = page, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0), 
        ScrollBarThickness = 0, 
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local left = Create("Frame", {
        Parent = scroll, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(0.48, 0, 1, 0)
    }, {
        Create("UIListLayout", {Padding = UDim.new(0, 15), SortOrder = Enum.SortOrder.LayoutOrder})
    })
    
    local right = Create("Frame", {
        Parent = scroll, 
        BackgroundTransparency = 1, 
        Position = UDim2.new(0.52, 0, 0, 0), 
        Size = UDim2.new(0.48, 0, 1, 0)
    }, {
        Create("UIListLayout", {Padding = UDim.new(0, 15), SortOrder = Enum.SortOrder.LayoutOrder})
    })
    
    PageColumns[page] = { LeftCol = left, RightCol = right }
    Pages[name] = page
    return left, right
end

local function AddPanel(parent, title)
    local p = Create("Frame", {Parent = parent, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y}, {
        Create("UICorner", {CornerRadius = UDim.new(0,8)}),
        Create("UIPadding", {PaddingTop = UDim.new(0,15), PaddingBottom = UDim.new(0,15), PaddingLeft = UDim.new(0,15), PaddingRight = UDim.new(0,15)})
    })
    Create("TextLabel", {Name="Title", Parent = p, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Font = Enum.Font.GothamBold, Text = title, TextColor3 = Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})
    local cont = Create("Frame", {Name="Container", Parent = p, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,30), Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y}, {Create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})})
    return cont
end

--// UI COMPONENTS XYETA

local function AddPlayerAction(parent, name, callback)
    local selectedPlayer = "All"
    local isProcessing = false
    local isOpen = false

    local Holder = Create("Frame", { Parent = parent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25), ZIndex = 10 })

    -- Сохраняем Label в переменную для анимации цвета
    local Label = Create("TextLabel", {
        Name = "ItemName",
        Parent = Holder,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = name,
        TextColor3 = Theme.SubText, -- Начальный цвет (тусклый)
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local DropdownBtn = Create("TextButton", {
        Parent = Holder,
        BackgroundColor3 = Theme.Input,
        Position = UDim2.new(0.4, 0, 0, 0),
        Size = UDim2.new(0.48, 0, 1, 0),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 11
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })

    local DisplayText = Create("TextLabel", {
        Parent = DropdownBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "All",
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })

    local Arrow = Create("TextLabel", {
        Parent = DropdownBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Text = "▼",
        TextColor3 = Theme.SubText,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        ZIndex = 12
    })

    local ListContainer = Create("Frame", {
        Parent = Holder,
        BackgroundColor3 = Theme.Input,
        Position = UDim2.new(0.4, 0, 1, 3),
        Size = UDim2.new(0.48, 0, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 100 
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})
    })

    local function CloseDropdown(instant)
        isOpen = false
        if instant then
            Arrow.Rotation = 0
            ListContainer.Size = UDim2.new(0.48, 0, 0, 0)
            ListContainer.Visible = false
            Holder.ZIndex = 10
        else
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
            local closeTween = TweenService:Create(ListContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0.48, 0, 0, 0)})
            closeTween:Play()
            closeTween.Completed:Connect(function()
                if not isOpen then ListContainer.Visible = false Holder.ZIndex = 10 end
            end)
        end
    end

    DropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            CloseDropdown()
            OpenedDropdown = nil
        else
            if OpenedDropdown then OpenedDropdown(true) end
            isOpen = true
            OpenedDropdown = CloseDropdown
            Holder.ZIndex = 100
            ListContainer.Visible = true
            
            for _, child in pairs(ListContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            local targets = {"All"}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then table.insert(targets, p.Name) end
            end

            for _, targetName in ipairs(targets) do
                local b = Create("TextButton", {
                    Parent = ListContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 25),
                    Text = "  " .. targetName,
                    TextColor3 = Theme.SubText,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 101
                })
                b.MouseButton1Click:Connect(function()
                    selectedPlayer = targetName
                    DisplayText.Text = targetName
                    CloseDropdown()
                    OpenedDropdown = nil
                end)
            end
            
            local targetHeight = math.min(#targets * 25, 150)
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 180}):Play()
            TweenService:Create(ListContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0.48, 0, 0, targetHeight)}):Play()
        end
    end)

    -- ЧЕКБОКС
    local CheckboxFrame = Create("Frame", {
        Parent = Holder,
        BackgroundColor3 = Theme.Input,
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.fromOffset(18, 18),
        ZIndex = 11
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })

    local Fill = Create("Frame", {
        Parent = CheckboxFrame,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 12
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 2)}) })

    local ActionBtn = Create("TextButton", {
        Parent = CheckboxFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 13
    })

    ActionBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        isProcessing = true

        -- АНИМАЦИЯ ВКЛЮЧЕНИЯ: Чекбокс + Текст
        TweenService:Create(Fill, TweenInfo.new(0.2), {Size = UDim2.fromOffset(12, 12)}):Play()
        TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
        
        if callback then
            if selectedPlayer == "All" then
                local allOthers = {}
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer then table.insert(allOthers, p) end
                end
                callback(allOthers, true)
            else
                callback(Players:FindFirstChild(selectedPlayer), false)
            end
        end

        task.delay(0.5, function()
            -- АНИМАЦИЯ ВЫКЛЮЧЕНИЯ: Чекбокс + Текст (возврат к SubText)
            TweenService:Create(Fill, TweenInfo.new(0.2), {Size = UDim2.fromOffset(0, 0)}):Play()
            TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Theme.SubText}):Play()
            isProcessing = false
        end)
    end)

    return Holder
end

local function AddESPToggle(parent, name, defaultColor, callback)
    local enabled = false
    local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
    local outlineColor = Color3.fromRGB(0, 0, 0)
    
    local Holder = Create("Frame", { Parent = parent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25) })
    
    local RowBtn = Create("TextButton", { 
        Parent = Holder, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, 0, 1, 0), 
        Text = "", 
        ZIndex = 1, 
        AutoButtonColor = false 
    })
    
    local Label = Create("TextLabel", { 
        Name = "ItemName",
        Parent = Holder, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(0.4, 0, 1, 0), 
        Font = Enum.Font.GothamMedium, 
        Text = name, 
        TextColor3 = enabled and Theme.Text or Theme.SubText,
        TextSize = 12, 
        TextXAlignment = Enum.TextXAlignment.Left, 
        ZIndex = 2 
    })

    local Controls = Create("Frame", { 
        Parent = Holder, 
        BackgroundTransparency = 1, 
        Position = UDim2.new(1, 0, 0, 0), 
        Size = UDim2.new(0, 160, 1, 0), 
        AnchorPoint = Vector2.new(1, 0), 
        ZIndex = 10, 
        Active = true 
    })
    
    Create("UIListLayout", { 
        Parent = Controls, 
        SortOrder = Enum.SortOrder.LayoutOrder, 
        FillDirection = Enum.FillDirection.Horizontal, 
        HorizontalAlignment = Enum.HorizontalAlignment.Right, 
        VerticalAlignment = Enum.VerticalAlignment.Center, 
        Padding = UDim.new(0, 14) 
    })

    local Checkbox = Create("Frame", { 
        Parent = Controls, 
        BackgroundColor3 = Theme.Input, 
        Size = UDim2.fromOffset(18, 18), 
        LayoutOrder = 3 
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })
    
    local CheckFill = Create("Frame", { 
        Parent = Checkbox, 
        BackgroundColor3 = Theme.Accent, 
        Position = UDim2.new(0.5, 0, 0.5, 0), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        Size = enabled and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 2)}) })

    local ColorCircle = Create("ImageButton", { 
        Parent = Controls, 
        BackgroundColor3 = currentColor, 
        Size = UDim2.fromOffset(16, 16), 
        LayoutOrder = 2, 
        ZIndex = 15, 
        AutoButtonColor = false, 
        Active = true, 
        Image = "" 
    }, { 
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}), 
        Create("UIStroke", { Name = "Stroke", Color = outlineColor, Thickness = 1.5 }) 
    })
    local Stroke = ColorCircle:FindFirstChild("Stroke")

    local HexInput = Create("TextBox", { 
        Parent = Controls, 
        BackgroundColor3 = Theme.Input, 
        Size = UDim2.new(0, 0, 0, 18), 
        Visible = false, 
        Text = "", 
        PlaceholderText = "#HEX", 
        TextColor3 = Color3.new(1,1,1), 
        Font = Enum.Font.Gotham, 
        TextSize = 10, 
        LayoutOrder = 1, 
        ClipsDescendants = true, 
        ZIndex = 15 
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })

    -- Функция для конвертации Color3 в HEX
    local function Color3ToHex(color)
        local r = math.floor(color.r * 255)
        local g = math.floor(color.g * 255)
        local b = math.floor(color.b * 255)
        return string.format("#%02X%02X%02X", r, g, b)
    end

    local function Toggle()
        enabled = not enabled
        TweenService:Create(CheckFill, TweenInfo.new(0.2), {
            Size = enabled and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
        }):Play()
        TweenService:Create(Label, TweenInfo.new(0.2), {
            TextColor3 = enabled and Theme.Text or Theme.SubText
        }):Play()
        if callback then 
            callback(enabled, currentColor, outlineColor) 
        end
    end

    RowBtn.MouseButton1Click:Connect(Toggle)

    HexInput:GetPropertyChangedSignal("Text"):Connect(function()
        local text = HexInput.Text
        local clean = text:gsub("[^%x]", ""):sub(1, 6):upper()
        local formatted = "#" .. clean
        
        if text ~= formatted then
            HexInput.Text = formatted
            HexInput.CursorPosition = #formatted + 1
        end
    end)

    ColorCircle.MouseButton1Click:Connect(function()
        if HexInput.Visible then return end
        HexInput.Visible = true 
        HexInput.Text = Color3ToHex(currentColor)
        HexInput:CaptureFocus()
        TweenService:Create(HexInput, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 65, 0, 18)
        }):Play()
    end)

    ColorCircle.MouseButton2Click:Connect(function()
        outlineColor = (outlineColor == Color3.new(0,0,0)) and Color3.new(1,1,1) or Color3.new(0,0,0)
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = outlineColor}):Play()
        if callback then 
            callback(enabled, currentColor, outlineColor) 
        end
    end)

    HexInput.FocusLost:Connect(function(enter)
        if enter then
            local nc = FromHex(HexInput.Text)
            if nc then 
                currentColor = nc 
                TweenService:Create(ColorCircle, TweenInfo.new(0.3), {
                    BackgroundColor3 = currentColor
                }):Play() 
            end
        end
        local t = TweenService:Create(HexInput, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 18)
        })
        t:Play() 
        t.Completed:Connect(function() 
            HexInput.Visible = false 
        end)
        if callback then 
            callback(enabled, currentColor, outlineColor) 
        end
    end)

    -- Сохраняем элемент для конфигов
    local elementId = name .. "_ESP"
    UI_Elements.ESPToggles[elementId] = {
        holder = Holder,
        name = name,
        getState = function()
            return {
                enabled = enabled,
                color = {r = currentColor.r, g = currentColor.g, b = currentColor.b},
                outlineColor = {r = outlineColor.r, g = outlineColor.g, b = outlineColor.b}
            }
        end,
        setState = function(state)
            enabled = state.enabled
            currentColor = Color3.new(state.color.r, state.color.g, state.color.b)
            outlineColor = Color3.new(state.outlineColor.r, state.outlineColor.g, state.outlineColor.b)
            
            -- Обновляем визуал
            CheckFill.Size = enabled and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
            Label.TextColor3 = enabled and Theme.Text or Theme.SubText
            ColorCircle.BackgroundColor3 = currentColor
            Stroke.Color = outlineColor
            
            -- Вызываем коллбек
            if callback then 
                callback(enabled, currentColor, outlineColor) 
            end
        end
    }

    return Holder
end

local function AddESPSizeToggle(parent, name, defaultColor, callback)
    local enabled = false
    local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
    local outlineColor = Color3.fromRGB(0, 0, 0)
    local selectedSize = "Auto"
    
    local Holder = Create("Frame", { 
        Parent = parent, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, 0, 0, 25), 
        ZIndex = 10 
    })
    
    local RowBtn = Create("TextButton", { 
        Parent = Holder, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, 0, 1, 0), 
        Text = "", 
        ZIndex = 1, 
        AutoButtonColor = false 
    })
    
    local Label = Create("TextLabel", { 
        Parent = Holder, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(0.4, 0, 1, 0), 
        Font = Enum.Font.GothamMedium, 
        Text = name, 
        TextColor3 = enabled and Theme.Text or Theme.SubText,
        TextSize = 12, 
        TextXAlignment = Enum.TextXAlignment.Left, 
        ZIndex = 2 
    })

    local Controls = Create("Frame", { 
        Parent = Holder, 
        BackgroundTransparency = 1, 
        Position = UDim2.new(1, 0, 0.5, 0), 
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 0, 1, 0), 
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 10 
    })
    
    Create("UIListLayout", { 
        Parent = Controls, 
        SortOrder = Enum.SortOrder.LayoutOrder, 
        FillDirection = Enum.FillDirection.Horizontal, 
        HorizontalAlignment = Enum.HorizontalAlignment.Right, 
        VerticalAlignment = Enum.VerticalAlignment.Center, 
        Padding = UDim.new(0, 14) 
    })

    local Checkbox = Create("Frame", { 
        Parent = Controls, 
        BackgroundColor3 = Theme.Input, 
        Size = UDim2.fromOffset(18, 18), 
        LayoutOrder = 10 
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })
    
    local CheckFill = Create("Frame", { 
        Parent = Checkbox, 
        BackgroundColor3 = Theme.Accent, 
        Position = UDim2.new(0.5, 0, 0.5, 0), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        Size = enabled and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 2)}) })

    local ColorCircle = Create("ImageButton", { 
        Parent = Controls, 
        BackgroundColor3 = currentColor, 
        Size = UDim2.fromOffset(16, 16), 
        LayoutOrder = 9, 
        ZIndex = 15, 
        AutoButtonColor = false, 
        Active = true, 
        Image = "" 
    }, { 
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}), 
        Create("UIStroke", { Name = "Stroke", Color = outlineColor, Thickness = 1.5 }) 
    })
    local Stroke = ColorCircle:FindFirstChild("Stroke")

    local HexInput = Create("TextBox", { 
        Parent = Controls, 
        BackgroundColor3 = Theme.Input, 
        Size = UDim2.new(0, 0, 0, 18), 
        Visible = false, 
        Text = "", 
        PlaceholderText = "#HEX", 
        TextColor3 = Color3.new(1,1,1), 
        Font = Enum.Font.Gotham, 
        TextSize = 10, 
        LayoutOrder = 8, 
        ClipsDescendants = true, 
        ZIndex = 20 
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })

    local SizeInput = Create("TextBox", { 
        Parent = Controls, 
        BackgroundColor3 = Theme.Input, 
        Size = UDim2.fromOffset(40, 18), 
        Text = selectedSize, 
        TextColor3 = Theme.Text, 
        Font = Enum.Font.Gotham, 
        TextSize = 10, 
        LayoutOrder = 7,
        ZIndex = 20, 
        ClearTextOnFocus = true,
        ClipsDescendants = true 
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })

    -- Функция для конвертации Color3 в HEX
    local function Color3ToHex(color)
        local r = math.floor(color.r * 255)
        local g = math.floor(color.g * 255)
        local b = math.floor(color.b * 255)
        return string.format("#%02X%02X%02X", r, g, b)
    end

    local function Toggle()
        enabled = not enabled
        TweenService:Create(CheckFill, TweenInfo.new(0.2), {
            Size = enabled and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
        }):Play()
        TweenService:Create(Label, TweenInfo.new(0.2), {
            TextColor3 = enabled and Theme.Text or Theme.SubText
        }):Play()
        if callback then 
            callback(enabled, currentColor, outlineColor, selectedSize) 
        end
    end

    RowBtn.MouseButton1Click:Connect(Toggle)

    SizeInput:GetPropertyChangedSignal("Text"):Connect(function()
        if #SizeInput.Text > 5 then 
            SizeInput.Text = SizeInput.Text:sub(1, 5) 
        end
    end)

    SizeInput.FocusLost:Connect(function()
        local val = SizeInput.Text:gsub("[^%d]", "") 
        local num = tonumber(val)
        if num and num >= 1 and num <= 99 then
            selectedSize = num
            SizeInput.Text = num .. "px"
        else
            selectedSize = "Auto"
            SizeInput.Text = "Auto"
        end
        if callback then 
            callback(enabled, currentColor, outlineColor, selectedSize) 
        end
    end)

    HexInput:GetPropertyChangedSignal("Text"):Connect(function()
        local text = HexInput.Text
        local clean = text:gsub("[^%x]", ""):sub(1, 6):upper()
        local formatted = "#" .. clean
        if text ~= formatted then 
            HexInput.Text = formatted 
            HexInput.CursorPosition = #formatted + 1 
        end
    end)

    ColorCircle.MouseButton1Click:Connect(function()
        if HexInput.Visible then return end
        HexInput.Visible = true 
        HexInput.Text = Color3ToHex(currentColor)
        HexInput:CaptureFocus()
        TweenService:Create(HexInput, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 65, 0, 18)
        }):Play()
    end)

    ColorCircle.MouseButton2Click:Connect(function()
        outlineColor = (outlineColor == Color3.new(0,0,0)) and Color3.new(1,1,1) or Color3.new(0,0,0)
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = outlineColor}):Play()
        if callback then 
            callback(enabled, currentColor, outlineColor, selectedSize) 
        end
    end)

    HexInput.FocusLost:Connect(function(enter)
        if enter then
            local nc = FromHex(HexInput.Text)
            if nc then 
                currentColor = nc 
                TweenService:Create(ColorCircle, TweenInfo.new(0.3), {
                    BackgroundColor3 = currentColor
                }):Play() 
            end
        end
        local t = TweenService:Create(HexInput, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 18)
        })
        t:Play() 
        t.Completed:Connect(function() 
            HexInput.Visible = false 
        end)
        if callback then 
            callback(enabled, currentColor, outlineColor, selectedSize) 
        end
    end)

    -- Сохраняем элемент для конфигов
    local elementId = name .. "_ESPSize"
    UI_Elements.ESPSizeToggles[elementId] = {
        holder = Holder,
        name = name,
        getState = function()
            return {
                enabled = enabled,
                color = {r = currentColor.r, g = currentColor.g, b = currentColor.b},
                outlineColor = {r = outlineColor.r, g = outlineColor.g, b = outlineColor.b},
                size = selectedSize
            }
        end,
        setState = function(state)
            enabled = state.enabled
            currentColor = Color3.new(state.color.r, state.color.g, state.color.b)
            outlineColor = Color3.new(state.outlineColor.r, state.outlineColor.g, state.outlineColor.b)
            selectedSize = state.size or "Auto"
            
            -- Обновляем визуал
            CheckFill.Size = enabled and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
            Label.TextColor3 = enabled and Theme.Text or Theme.SubText
            ColorCircle.BackgroundColor3 = currentColor
            Stroke.Color = outlineColor
            SizeInput.Text = selectedSize == "Auto" and "Auto" or tostring(selectedSize) .. "px"
            
            -- Вызываем коллбек
            if callback then 
                callback(enabled, currentColor, outlineColor, selectedSize) 
            end
        end
    }

    return Holder
end

local function AddKey(parent, name, options)
    if typeof(options) == "EnumItem" then 
        options = {key = options} 
    end
    options = options or {}
    
    local defaultKey = options.key or Enum.KeyCode.Unknown
    local defaultMode = options.mode or "Toggle"
    local defaultState = options.state or false
    local callback = options.callback or function() end
    local onlyToggle = options.onlyToggle or false
    
    local currentKey = defaultKey
    local currentMode = defaultMode
    local currentState = defaultState
    local functionActive = false
    local keyConnection
    local keyUpConnection
    local isListening = false
    local listeningConnection
    
    local f = Create("Frame", {
        Parent = parent, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, 0, 0, 25)
    })

    local NameLabel = Create("TextLabel", {
        Name = "ItemName",
        Parent = f,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -130, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = name,
        TextColor3 = currentState and Theme.Text or Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local box = Create("Frame", {
        Parent = f,
        BackgroundColor3 = Theme.Input,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(18, 18),
        AnchorPoint = Vector2.new(1, 0.5)
    }, { 
        Create("UICorner", {CornerRadius = UDim.new(0, 4)}) 
    })

    local redSquare = Create("Frame", {
        Parent = box,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = currentState and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5)
    }, { 
        Create("UICorner", {CornerRadius = UDim.new(0, 2)}) 
    })

    local toggleBtn = Instance.new("TextButton", box)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.Text = ""
    
    local function updateState(newState)
        currentState = newState
        TweenService:Create(redSquare, TweenInfo.new(0.2), {
            Size = currentState and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
        }):Play()
        TweenService:Create(NameLabel, TweenInfo.new(0.2), {
            TextColor3 = currentState and Theme.Text or Theme.SubText
        }):Play()
        
        if not currentState and functionActive then
            functionActive = false
            callback(false)
        end
    end

    local function createConnections()
        if keyConnection then
            keyConnection:Disconnect()
            keyConnection = nil
        end
        if keyUpConnection then
            keyUpConnection:Disconnect()
            keyUpConnection = nil
        end
        
        if currentKey ~= Enum.KeyCode.Unknown and currentState then
            if currentMode == "Toggle" then
                keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                        if input.UserInputState == Enum.UserInputState.Begin then
                            functionActive = not functionActive
                            callback(functionActive)
                        end
                    end
                end)
            elseif currentMode == "Hold" then
                keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                        if input.UserInputState == Enum.UserInputState.Begin then
                            callback(true)
                        end
                    end
                end)
                
                keyUpConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                        if input.UserInputState == Enum.UserInputState.End then
                            callback(false)
                        end
                    end
                end)
            end
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        updateState(not currentState)
        createConnections()
    end)

    local keyBtn = Create("TextButton", {
        Parent = f,
        BackgroundColor3 = Theme.Input,
        Position = UDim2.new(1, -25, 0.5, 0),
        Size = UDim2.fromOffset(50, 18),
        AnchorPoint = Vector2.new(1, 0.5),
        Text = GetKeyName(currentKey),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.SubText,
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 4)})
    })

    local modeBtn
    if not onlyToggle then
        modeBtn = Create("TextButton", {
            Parent = f,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -80, 0.5, 0),
            Size = UDim2.fromOffset(40, 18),
            AnchorPoint = Vector2.new(1, 0.5),
            Text = currentMode,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = Theme.SubText
        })

        modeBtn.MouseButton1Click:Connect(function()
            if functionActive then
                functionActive = false
                callback(false)
            end
            
            currentMode = (currentMode == "Toggle") and "Hold" or "Toggle"
            modeBtn.Text = currentMode
            createConnections()
        end)
    else
        currentMode = "Toggle"
    end
    
    keyBtn.MouseButton1Click:Connect(function()
        if isListening then return end
        isListening = true
        keyBtn.Text = "..."
        keyBtn.TextColor3 = Theme.Accent
        
        if listeningConnection then
            listeningConnection:Disconnect()
            listeningConnection = nil
        end
        
        listeningConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                    currentKey = Enum.KeyCode.Unknown
                else
                    currentKey = input.KeyCode
                end

                keyBtn.Text = GetKeyName(currentKey)
                keyBtn.TextColor3 = Theme.SubText
                isListening = false
                if listeningConnection then
                    listeningConnection:Disconnect()
                    listeningConnection = nil
                end
                createConnections()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                isListening = false
                keyBtn.Text = GetKeyName(currentKey)
                keyBtn.TextColor3 = Theme.SubText
                if listeningConnection then
                    listeningConnection:Disconnect()
                    listeningConnection = nil
                end
            end
        end)
    end)
    
    createConnections()
    
    f.Destroying:Connect(function()
        if keyConnection then
            keyConnection:Disconnect()
            keyConnection = nil
        end
        if keyUpConnection then
            keyUpConnection:Disconnect()
            keyUpConnection = nil
        end
        if listeningConnection then
            listeningConnection:Disconnect()
            listeningConnection = nil
        end
    end)

    -- Сохраняем элемент для конфигов
    local elementId = name .. "_Key"
    UI_Elements.Keys[elementId] = {
        holder = f,
        name = name,
        getState = function()
            return {
                key = currentKey.Name,
                mode = currentMode,
                state = currentState
            }
        end,
        setState = function(state)
            currentKey = Enum.KeyCode[state.key] or Enum.KeyCode.Unknown
            currentMode = state.mode
            currentState = state.state
            
            -- Обновляем визуал
            redSquare.Size = currentState and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
            NameLabel.TextColor3 = currentState and Theme.Text or Theme.SubText
            keyBtn.Text = GetKeyName(currentKey)
            
            if modeBtn then
                modeBtn.Text = currentMode
            end
            
            -- Пересоздаем соединения
            createConnections()
            
            -- Если состояние активно, вызываем коллбек
            if currentState then
                if currentMode == "Toggle" then
                    functionActive = true
                    callback(true)
                end
            end
        end
    }

    return f
end

local function AddOneTimeToggle(parent, name, callback)
    local enabled = false
    local f = Create("Frame", {Parent = parent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25)})
    
    local itemNameLabel = Create("TextLabel", {
        Name = "ItemName", 
        Parent = f, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(0.6, 0, 1, 0), 
        Font = Enum.Font.GothamMedium, 
        Text = name, 
        TextColor3 = Theme.SubText, 
        TextSize = 12, 
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local box = Create("Frame", {
        Parent = f, 
        BackgroundColor3 = Theme.Input, 
        Position = UDim2.new(1, 0, 0.5, 0), 
        Size = UDim2.fromOffset(18, 18), 
        AnchorPoint = Vector2.new(1, 0.5)
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
    
    local redSquare = Create("Frame", {
        Parent = box, 
        BackgroundColor3 = Theme.Accent, 
        Position = UDim2.new(0.5, 0, 0.5, 0), 
        Size = UDim2.fromOffset(0, 0), 
        AnchorPoint = Vector2.new(0.5, 0.5)
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 2)})})
    
    local btn = Instance.new("TextButton", f)
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""
    
    btn.MouseButton1Click:Connect(function()
        if not enabled then
            enabled = true
            TweenService:Create(redSquare, TweenInfo.new(0.2), {Size = UDim2.fromOffset(12, 12)}):Play()
            TweenService:Create(itemNameLabel, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
            if callback then callback(true) end
        end
    end)
    
    return f
end

local function AddSlider(parent, name, minValue, maxValue, defaultValue, callback)
    local currentValue = defaultValue
    
    local f = Create("Frame", {
        Parent = parent, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, 0, 0, 25)
    })
    
    local LeftContainer = Create("Frame", {
        Parent = f,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.35, 0, 1, 0)
    })
    
    local NameLabel = Create("TextLabel", {
        Name = "ItemName", 
        Parent = LeftContainer, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(0.6, 0, 1, 0), 
        Font = Enum.Font.GothamMedium, 
        Text = name, 
        TextColor3 = Theme.Text, 
        TextSize = 12, 
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local ValueLabel = Create("TextLabel", {
        Parent = LeftContainer, 
        BackgroundTransparency = 1, 
        Position = UDim2.new(0.6, 0, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        Font = Enum.Font.Gotham, 
        Text = tostring(defaultValue), 
        TextColor3 = Theme.SubText, 
        TextSize = 12, 
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local bg = Create("Frame", {
        Parent = f, 
        BackgroundColor3 = Theme.Input, 
        Position = UDim2.new(0.35, 10, 0.5, -3),
        Size = UDim2.new(0.65, -10, 0, 6)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })

    local initialPos = (defaultValue - minValue) / (maxValue - minValue)
    
    local fill = Create("Frame", {
        Parent = bg, 
        BackgroundColor3 = Theme.Accent, 
        Size = UDim2.new(initialPos, 0, 1, 0)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })

    local handle = Create("Frame", {
        Parent = fill, 
        BackgroundColor3 = Theme.Accent, 
        Position = UDim2.new(1, 0, 0.5, 0), 
        Size = UDim2.fromOffset(10, 10),
        AnchorPoint = Vector2.new(0.5, 0.5)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}), 
        Create("UIStroke", {Color = Theme.Sidebar, Thickness = 2})
    })

    local isDragging = false
    local dragStart = Vector2.new(0, 0)
    local startPos = 0
    
    local bgBtn = Create("TextButton", {
        Parent = bg,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 3, 0),
        Position = UDim2.new(0, 0, -1, 0),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5
    })

    local function UpdateSlide(input)
        if not isDragging then return end
        
        local mousePos = input.Position
        local bgAbsolutePos = bg.AbsolutePosition
        local bgAbsoluteSize = bg.AbsoluteSize
        
        local pos = math.clamp((mousePos.X - bgAbsolutePos.X) / bgAbsoluteSize.X, 0, 1)
        
        local value = minValue + (pos * (maxValue - minValue))
        
        local isDecimalRange = (maxValue - minValue <= 10) or (minValue % 1 ~= 0) or (maxValue % 1 ~= 0)
        
        if isDecimalRange then
            local precision = 1
            if name == "CAR itself" then
                precision = 2
            end
            
            value = math.floor(value * (10 ^ precision) + 0.5) / (10 ^ precision)
            ValueLabel.Text = string.format("%."..precision.."f", value)
        else
            value = math.round(value)
            ValueLabel.Text = tostring(value)
        end
        
        currentValue = value
        
        TweenService:Create(fill, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
            Size = UDim2.new(pos, 0, 1, 0)
        }):Play()
        
        if callback then
            callback(value)
        end
    end

    bgBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            isDragging = true
            dragStart = input.Position
            startPos = fill.Size.X.Scale
            
            TweenService:Create(handle, TweenInfo.new(0.15), {
                Size = UDim2.fromOffset(12, 12)
            }):Play()
            
            UpdateSlide(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
            UpdateSlide(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then 
            isDragging = false
            
            TweenService:Create(handle, TweenInfo.new(0.15), {
                Size = UDim2.fromOffset(10, 10)
            }):Play()
        end
    end)
    
    bgBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            isDragging = false
            TweenService:Create(handle, TweenInfo.new(0.15), {
                Size = UDim2.fromOffset(10, 10)
            }):Play()
        end
    end)
    
    -- Сохраняем элемент для конфигов
    local elementId = name .. "_Slider"
    UI_Elements.Sliders[elementId] = {
        holder = f,
        name = name,
        getState = function()
            return {
                value = currentValue,
                min = minValue,
                max = maxValue
            }
        end,
        setState = function(state)
            currentValue = state.value
            
            -- Обновляем визуал
            local pos = (currentValue - minValue) / (maxValue - minValue)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            
            local isDecimalRange = (maxValue - minValue <= 10) or (minValue % 1 ~= 0) or (maxValue % 1 ~= 0)
            if isDecimalRange then
                local precision = 1
                if name == "CAR itself" then
                    precision = 2
                end
                ValueLabel.Text = string.format("%."..precision.."f", currentValue)
            else
                ValueLabel.Text = tostring(currentValue)
            end
            
            -- Вызываем коллбек
            if callback then
                callback(currentValue)
            end
        end
    }

    return f
end

local function AddToggle(parent, name, on, callback)
    local enabled = on
    
    local f = Create("Frame", {
        Parent = parent, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, 0, 0, 25)
    })
    
    local itemNameLabel = Create("TextLabel", {
        Name = "ItemName", 
        Parent = f, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(0.6, 0, 1, 0), 
        Font = Enum.Font.GothamMedium, 
        Text = name, 
        TextColor3 = enabled and Theme.Text or Theme.SubText, 
        TextSize = 12, 
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local box = Create("Frame", {
        Parent = f, 
        BackgroundColor3 = Theme.Input, 
        Position = UDim2.new(1, 0, 0.5, 0), 
        Size = UDim2.fromOffset(18, 18), 
        AnchorPoint = Vector2.new(1, 0.5)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 4)})
    })
    
    local redSquare = Create("Frame", {
        Parent = box, 
        BackgroundColor3 = Theme.Accent, 
        Position = UDim2.new(0.5, 0, 0.5, 0), 
        Size = enabled and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0), 
        AnchorPoint = Vector2.new(0.5, 0.5)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 2)})
    })
    
    local btn = Instance.new("TextButton", f)
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""
    
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(redSquare, TweenInfo.new(0.2), {
            Size = enabled and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
        }):Play()
        TweenService:Create(itemNameLabel, TweenInfo.new(0.2), {
            TextColor3 = enabled and Theme.Text or Theme.SubText
        }):Play()
        if callback then 
            callback(enabled) 
        end
    end)
    
    -- Сохраняем элемент для конфигов
    local elementId = name .. "_Toggle"
    UI_Elements.Toggles[elementId] = {
        holder = f,
        name = name,
        getState = function()
            return { enabled = enabled }
        end,
        setState = function(state)
            enabled = state.enabled
            
            -- Обновляем визуал
            redSquare.Size = enabled and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
            itemNameLabel.TextColor3 = enabled and Theme.Text or Theme.SubText
            
            -- Вызываем коллбек
            if callback then
                callback(enabled)
            end
        end
    }
    
    return f
end

--//TABS XYETA
local MainTab = CreateTabButton("Main", true)
CreateSubTabButton(MainTab, "Legit") 
CreateSubTabButton(MainTab, "Rage")
local VisualsTab = CreateTabButton("Visuals", true)
CreateSubTabButton(VisualsTab, "Main", "VisualsMain") 
CreateSubTabButton(VisualsTab, "Misc", "VisualsMisc")
local ConfigsTab = CreateTabButton("Configs", false)

local L_Left, L_Right = CreatePage("Legit") 
local MovementPanel = AddPanel(L_Left, "Movement")

AddKey(MovementPanel, "Speed Changer", {
    mode = "Toggle", -- Можно изменить на Hold
    callback = function(state)
        updateFixedSpeedChanger(state, fixedSpeedValue)
    end
})

AddSlider(MovementPanel, "SC itself", 5, 30, 15, function(value)
    fixedSpeedValue = value
    if fixedSpeedEnabled then
        updateFixedSpeedChanger(true, value)
    end
end)

AddToggle(MovementPanel, "VaultSpeed Changer", false, function(state)
    updateVaultSpeedChanger(state, vaultSpeedValue)
end)

AddSlider(MovementPanel, "VSC itself", 0.01, 1.23, 1.0, function(value)
    vaultSpeedValue = math.floor(value * 100) / 100
    if vaultSpeedEnabled then
        updateVaultSpeedChanger(true, vaultSpeedValue)
    end
end)

AddKey(MovementPanel, "12stud Teleport", {
    mode = "Toggle",
    callback = function(state)
        if state then
            teleportForward()
        end
		onlyToggle = true
    end
})

AddKey(MovementPanel, "NAF", {
    mode = "Toggle",
    callback = function(state)
        updateNAF(state)
    end,
    onlyToggle = true
})

local UnnamedPanel = AddPanel(L_Right, "Unnamed")

AddToggle(UnnamedPanel, "Emote Wheel (B)", false, function(state)
    updateEmoteWheel(state)
end)

AddToggle(UnnamedPanel, "Force Self-Care", false, function(state)
    updateSelfCare(state)
end)

AddKey(UnnamedPanel, "No Collisions", {
    mode = "Toggle",
    callback = function(state)
        updateNoCollision(state)
    end
})

AddToggle(UnnamedPanel, "Old Animations", false, function(state)
    updateOldAnimations(state)
end)


local R_Left, R_Right = CreatePage("Rage")
local SurvivorSide = AddPanel(R_Left, "Survivor Side")

AddOneTimeToggle(SurvivorSide, "Break All Hooks (BUGGY)", function(enabled)
    updateBlockHooks(enabled)
end)

AddOneTimeToggle(SurvivorSide, "Finish All Gens", function(enabled)
    updateFinishGens(enabled)
end)

AddKey(SurvivorSide, "Fly", {
    mode = "Toggle", 
    callback = function(state)
        if state == true and not flyEnabled then
            toggleFlight()
        elseif state == false and flyEnabled then
            toggleFlight()
        end
    end
})

AddKey(SurvivorSide, "Noclip", {
    mode = "Toggle", 
    callback = function(state)
        if state == true then
            -- При нажатии ВКЛЮЧАЕМ
            if not noclipEnabled then
                noclipEnabled = true
                -- Запускаем цикл NoClip
                noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                    local character = LocalPlayer.Character
                    if character then
                        for _, part in ipairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                                part.CanTouch = false
                                part.CanQuery = false
                            end
                        end
                    end
                end)
                warn("[NoClip] Включен (Hold)")
            end
        else
            -- При отпускании ВЫКЛЮЧАЕМ
            if noclipEnabled then
                noclipEnabled = false
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
                -- Восстанавливаем коллизии
                local character = LocalPlayer.Character
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                            part.CanTouch = true
                            part.CanQuery = true
                        end
                    end
                end
                warn("[NoClip] Выключен (Hold)")
            end
        end
    end
})

AddPlayerAction(SurvivorSide, "Hit Someone", function(players, isAll)
    if isAll then
        hitPlayer(players)
    else
        hitPlayer(players)
    end
end)

AddKey(SurvivorSide, "Stun Killer", {
    mode = "Toggle",
    callback = function(state)
        -- Включаем/выключаем функцию
        stunKillerEnabled = state
        
        -- Если функция включена, применяем стан сразу при нажатии
        if state == true then
            applyStunKillerNow()
            
            -- Создаем соединение, которое будет применять стан при каждом последующем нажатии бинда
            if stunKillerConnection then
                stunKillerConnection:Disconnect()
            end
            
            -- Соединение для отслеживания нажатий клавиши
            local keyPressed = false
            stunKillerConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed or not stunKillerEnabled then return end
                
                -- Получаем текущий бинд из UI элемента (нужно найти его в UI_Elements.Keys)
                local elementId = "Stun Killer_Key"
                local keyElement = UI_Elements.Keys[elementId]
                if keyElement and keyElement.getState then
                    local state = keyElement.getState()
                    local currentKey = Enum.KeyCode[state.key]
                    
                    -- Проверяем, что нажата именно эта клавиша
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                        if not keyPressed then
                            keyPressed = true
                            applyStunKillerNow()
                        end
                    end
                end
            end)
            
            -- Сбрасываем флаг при отпускании клавиши
            local keyUpConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    keyPressed = false
                end
            end)
            
            -- Сохраняем соединение для очистки
            table.insert(stunKillerConnection, keyUpConnection)
        else
            -- Отключаем соединения при выключении
            if stunKillerConnection then
                if type(stunKillerConnection) == "table" then
                    for _, conn in ipairs(stunKillerConnection) do
                        if conn then
                            conn:Disconnect()
                        end
                    end
                else
                    stunKillerConnection:Disconnect()
                end
                stunKillerConnection = nil
            end
        end
    end,
    onlyToggle = true
})

local KillerSide = AddPanel(R_Right, "Killer Side")

AddOneTimeToggle(KillerSide, "Gate Never Open", function(enabled)
    updateGateNeverOpen(enabled)
end)

AddOneTimeToggle(KillerSide, "Never Finish Gens", function(enabled)
    updateNeverFinishGens(enabled)
end)

AddPlayerAction(KillerSide, "Hook Someone", function(players, isAll)
    if isAll then
        hookPlayer(players)
    else
        hookPlayer(players)
    end
end)

AddPlayerAction(KillerSide, "PickUpSomeone", function(players, isAll)
    if isAll then
        pickupPlayer(players)
    else
        pickupPlayer(players)
    end
end)

AddPlayerAction(KillerSide, "Drop Someone", function(players, isAll)
    if isAll then
        dropPlayer(players)
    else
        dropPlayer(players)
    end
end)

local LungeToggleEnabled = false
AddToggle(KillerSide, "Custom Lunge Duration", false, function(enabled)
    LungeToggleEnabled = enabled
    updateLungeDuration(enabled, RageModules.LungeDuration.Value)
end)

AddSlider(KillerSide, "CLD itself", 0.5, 10.0, 0.6, function(value)
    RageModules.LungeDuration.Value = value
    
    -- Если тоггл включен, сразу применяем
    if LungeToggleEnabled then
        updateLungeDuration(true, value)
    end
end)


local V_Left, V_Right = CreatePage("VisualsMain")
local SurvivorESP = AddPanel(V_Left, "Survivors ESP")

AddESPToggle(SurvivorESP, "Chams", Color3.fromHex("#AFEEEE"), function(enabled, color, outlineColor)
    ESPStates.Survivor.Chams = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateSurvivorChams(enabled, color, outlineColor)
end)

AddESPToggle(SurvivorESP, "Skeleton", Color3.fromHex("#AFEEEE"), function(enabled, color, outlineColor)
    ESPStates.Survivor.Skeleton = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateSurvivorSkeleton(enabled, color, outlineColor)
end)

AddESPSizeToggle(SurvivorESP, "Names", Color3.fromHex("#AFEEEE"), function(enabled, color, outlineColor, selectedSize)
    ESPStates.Survivor.Names = {Enabled = enabled, Color = color, Outline = outlineColor, Size = selectedSize}
    updateSurvivorNames(enabled, color, outlineColor, selectedSize)
end)

AddESPSizeToggle(SurvivorESP, "Distance", Color3.fromHex("#AFEEEE"), function(enabled, color, outlineColor, selectedSize)
    ESPStates.Survivor.Distance = {Enabled = enabled, Color = color, Outline = outlineColor, Size = selectedSize}
    updateSurvivorDistance(enabled, color, outlineColor, selectedSize)
end)

local KillerESP = AddPanel(V_Left, "Killer ESP")

AddESPToggle(KillerESP, "Chams", Color3.fromHex("#A5260A"), function(enabled, color, outlineColor)
    ESPStates.Killer.Chams = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateKillerChams(enabled, color, outlineColor)
end)

AddESPToggle(KillerESP, "Skeleton", Color3.fromHex("#A5260A"), function(enabled, color, outlineColor)
    ESPStates.Killer.Skeleton = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateKillerSkeleton(enabled, color, outlineColor)
end)

AddESPSizeToggle(KillerESP, "Names", Color3.fromHex("#A5260A"), function(enabled, color, outlineColor, selectedSize)
    ESPStates.Killer.Names = {Enabled = enabled, Color = color, Outline = outlineColor, Size = selectedSize}
    updateKillerNames(enabled, color, outlineColor, selectedSize)
end)

AddESPSizeToggle(KillerESP, "Distance", Color3.fromHex("#A5260A"), function(enabled, color, outlineColor, selectedSize)
    ESPStates.Killer.Distance = {Enabled = enabled, Color = color, Outline = outlineColor, Size = selectedSize}
    updateKillerDistance(enabled, color, outlineColor, selectedSize)
end)

AddESPToggle(KillerESP, "Custom Killerlight", Color3.fromHex("#FF0000"), function(enabled, color, outlineColor)
    ESPStates.Killer.Killerlight = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateKillerlight(enabled, color, outlineColor)
end)

local ObjectHighlight = AddPanel(V_Right, "Object Highlight")

AddESPToggle(ObjectHighlight, "Chests", Color3.fromHex("#CD5700"), function(enabled, color, outlineColor)
    ESPStates.Objects.Chests = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateObjectESP("Chests", enabled, color, outlineColor)
end)

AddESPToggle(ObjectHighlight, "Hatch", Color3.fromHex("#7B3F00"), function(enabled, color, outlineColor)
    ESPStates.Objects.Hatch = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateObjectESP("Hatch", enabled, color, outlineColor)
end)

AddESPToggle(ObjectHighlight, "Lockers", Color3.fromHex("#CD5700"), function(enabled, color, outlineColor)
    ESPStates.Objects.Lockers = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateObjectESP("Lockers", enabled, color, outlineColor)
end)

AddESPToggle(ObjectHighlight, "Hooks", Color3.fromHex("#A5260A"), function(enabled, color, outlineColor)
    ESPStates.Objects.Hooks = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateObjectESP("Hooks", enabled, color, outlineColor)
end)

AddESPToggle(ObjectHighlight, "Pallets", Color3.fromHex("#DAD871"), function(enabled, color, outlineColor)
    ESPStates.Objects.Pallets = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateObjectESP("Pallets", enabled, color, outlineColor)
end)

AddESPToggle(ObjectHighlight, "Windows", Color3.fromHex("#DAD871"), function(enabled, color, outlineColor)
    ESPStates.Objects.Windows = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateObjectESP("Windows", enabled, color, outlineColor)
end)

AddESPToggle(ObjectHighlight, "Exits", Color3.fromHex("#969696"), function(enabled, color, outlineColor)
    ESPStates.Objects.Exits = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateObjectESP("Exits", enabled, color, outlineColor)
end)

AddESPToggle(ObjectHighlight, "Totems", Color3.fromHex("#FFFDDF"), function(enabled, color, outlineColor)
    ESPStates.Objects.Totems = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateObjectESP("Totems", enabled, color, outlineColor)
end)

AddESPToggle(ObjectHighlight, "Generators", Color3.fromHex("#1E1112"), function(enabled, color, outlineColor)
    ESPStates.Objects.Generators = {Enabled = enabled, Color = color, Outline = outlineColor}
    updateObjectESP("Generators", enabled, color, outlineColor)
end)

AddToggle(ObjectHighlight, "Generators Progress", false, function(enabled)
    ESPStates.Objects.GeneratorsProgress = {Enabled = enabled}
    updateGeneratorsProgress(enabled)
end)


local VM_Left, VM_Right = CreatePage("VisualsMisc")
local CameraPanel = AddPanel(VM_Left, "Camera")

AddToggle(CameraPanel, "FOV Changer", false, function(state)
    updateFOVChanger(state, MiscStates.FOVChanger.Value)
end)

AddSlider(CameraPanel, "FOV", 1, 120, 70, function(value)
    MiscStates.FOVChanger.Value = value
    if MiscStates.FOVChanger.Enabled then
        updateFOVChanger(true, value)
    end
end)

AddToggle(CameraPanel, "Custom Aspect Ratio", false, function(state)
    updateAspectRatioChanger(state, MiscStates.AspectRatioChanger.Value)
end)

AddSlider(CameraPanel, "CAR itself", 0.25, 1.15, 0.75, function(value)
    MiscStates.AspectRatioChanger.Value = value
    if MiscStates.AspectRatioChanger.Enabled then
        updateAspectRatioChanger(true, value)
    end
end)

AddToggle(CameraPanel, "Free Camera (SHIFT + P)", false, function(state)
    updateFreeCamera(state)
end)

local InterfacesPanel = AddPanel(VM_Left, "Interfaces")

AddToggle(InterfacesPanel, "Show Flash Progress", false, function(state)
    updateFlashProgress(state)
end)

local OtherPanel = AddPanel(VM_Right, "Other")

AddToggle(OtherPanel, "Inf Item Charges", false, function(state)
    updateInfItemCharges(state)
end)

AddToggle(OtherPanel, "Outfit Changer GUI", false, function(state)
    updateOutfitChanger(state)
end)

--//CFG XYETA
local ConfigExtension = ".json"
local ConfigFolder = "Hyperion_Configs"

-- Проверка доступности файловых функций
local function IsFileFunctionsAvailable()
    return pcall(function() 
        return readfile and writefile and delfile and isfile and listfiles 
    end)
end

-- Создание папки для конфигов
local function EnsureConfigFolder()
    if IsFileFunctionsAvailable() then
        if not isfolder(ConfigFolder) then
            makefolder(ConfigFolder)
        end
    end
end

-- Получение списка конфигов
local function GetConfigList()
    if not IsFileFunctionsAvailable() then
        return {"test"}
    end
    
    local configs = {}
    EnsureConfigFolder()
    
    local success, files = pcall(function()
        return listfiles(ConfigFolder)
    end)
    
    if success and files then
        for _, file in ipairs(files) do
            if file:sub(-5):lower() == ".json" then
                local fileName = file:match("[^\\/]+$")
                table.insert(configs, fileName)
            end
        end
    end
    
    if #configs == 0 then
        return {"Legit_V1.json", "HvH_Public.json", "Private_Cfg.json"}
    end
    
    return configs
end

-- Сохранение конфига
local function SaveConfig(filename)
    if not IsFileFunctionsAvailable() then
        warn("File functions not available")
        return false
    end
    
    local configData = {
        version = "1.0",
        timestamp = os.time(),
        
        -- Состояния ESP
        ESPStates = ESPStates,
        
        -- Состояния Misc
        MiscStates = MiscStates,
        
        -- Состояния Rage
        RageModules = RageModules,
        
        -- Состояния Legit
        LegitStates = {
            fixedSpeedEnabled = fixedSpeedEnabled,
            fixedSpeedValue = fixedSpeedValue,
            vaultSpeedEnabled = vaultSpeedEnabled,
            vaultSpeedValue = vaultSpeedValue,
            nafEnabled = nafEnabled,
            selfCareEnabled = selfCareEnabled,
            noCollisionEnabled = noCollisionEnabled,
            oldAnimationsEnabled = oldAnimationsEnabled
        },
        
        -- Состояния UI элементов
        UIStates = {
            Toggles = {},
            Sliders = {},
            Keys = {},
            ESPToggles = {},
            ESPSizeToggles = {}
        }
    }
    
    -- Сохраняем состояния UI элементов
    for id, element in pairs(UI_Elements.Toggles) do
        configData.UIStates.Toggles[id] = element.getState()
    end
    
    for id, element in pairs(UI_Elements.Sliders) do
        configData.UIStates.Sliders[id] = element.getState()
    end
    
    for id, element in pairs(UI_Elements.Keys) do
        configData.UIStates.Keys[id] = element.getState()
    end
    
    for id, element in pairs(UI_Elements.ESPToggles) do
        configData.UIStates.ESPToggles[id] = element.getState()
    end
    
    for id, element in pairs(UI_Elements.ESPSizeToggles) do
        configData.UIStates.ESPSizeToggles[id] = element.getState()
    end
    
    local json = HttpService:JSONEncode(configData)
    
    EnsureConfigFolder()
    local filePath = ConfigFolder .. "/" .. filename
    
    local success, err = pcall(function()
        writefile(filePath, json)
    end)
    
    return success, err
end

-- Загрузка конфига (с правильным порядком)
local function LoadConfig(filename)
    if not IsFileFunctionsAvailable() then
        warn("File functions not available")
        return false
    end
    
    local filePath = ConfigFolder .. "/" .. filename
    
    if not isfile(filePath) then
        warn("Config file does not exist: " .. filePath)
        return false
    end
    
    local success, configData = pcall(function()
        local json = readfile(filePath)
        return HttpService:JSONDecode(json)
    end)
    
    if not success or not configData then
        warn("Failed to load config")
        return false
    end
    
    -- Шаг 1: Загружаем ESP состояния (самые важные)
    if configData.ESPStates then
        for category, values in pairs(configData.ESPStates) do
            if ESPStates[category] then
                for key, state in pairs(values) do
                    if ESPStates[category][key] then
                        for prop, value in pairs(state) do
                            if typeof(value) == "table" and value.r and value.g and value.b then
                                ESPStates[category][key][prop] = Color3.new(value.r, value.g, value.b)
                            else
                                ESPStates[category][key][prop] = value
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Шаг 2: Загружаем UI элементы
    if configData.UIStates then
        -- ESP тогглы (должны быть перед применением ESP)
        if configData.UIStates.ESPToggles then
            for id, state in pairs(configData.UIStates.ESPToggles) do
                if UI_Elements.ESPToggles[id] then
                    UI_Elements.ESPToggles[id].setState(state)
                end
            end
        end
        
        -- ESP Size тогглы
        if configData.UIStates.ESPSizeToggles then
            for id, state in pairs(configData.UIStates.ESPSizeToggles) do
                if UI_Elements.ESPSizeToggles[id] then
                    UI_Elements.ESPSizeToggles[id].setState(state)
                end
            end
        end
    end
    
    -- Шаг 3: Применяем ESP (после загрузки всех настроек ESP)
    task.wait(0.01)
    for category, states in pairs(ESPStates) do
        for name, state in pairs(states) do
            if category == "Survivor" then
                if name == "Chams" then
                    updateSurvivorChams(state.Enabled, state.Color, state.Outline)
                elseif name == "Skeleton" then
                    updateSurvivorSkeleton(state.Enabled, state.Color, state.Outline)
                elseif name == "Names" then
                    updateSurvivorNames(state.Enabled, state.Color, state.Outline, state.Size)
                elseif name == "Distance" then
                    updateSurvivorDistance(state.Enabled, state.Color, state.Outline, state.Size)
                end
            elseif category == "Killer" then
                if name == "Chams" then
                    updateKillerChams(state.Enabled, state.Color, state.Outline)
                elseif name == "Skeleton" then
                    updateKillerSkeleton(state.Enabled, state.Color, state.Outline)
                elseif name == "Names" then
                    updateKillerNames(state.Enabled, state.Color, state.Outline, state.Size)
                elseif name == "Distance" then
                    updateKillerDistance(state.Enabled, state.Color, state.Outline, state.Size)
                elseif name == "Killerlight" then
                    updateKillerlight(state.Enabled, state.Color, state.Outline)
                end
            elseif category == "Objects" then
                if name == "GeneratorsProgress" then
                    updateGeneratorsProgress(state.Enabled)
                else
                    updateObjectESP(name, state.Enabled, state.Color, state.Outline)
                end
            end
        end
    end
    
    -- Шаг 4: Загружаем остальные UI элементы
    if configData.UIStates then
        -- Тогглы
        if configData.UIStates.Toggles then
            for id, state in pairs(configData.UIStates.Toggles) do
                if UI_Elements.Toggles[id] then
                    UI_Elements.Toggles[id].setState(state)
                end
            end
        end
        
        -- Слайдеры
        if configData.UIStates.Sliders then
            for id, state in pairs(configData.UIStates.Sliders) do
                if UI_Elements.Sliders[id] then
                    UI_Elements.Sliders[id].setState(state)
                end
            end
        end
        
        -- Ключи
        if configData.UIStates.Keys then
            for id, state in pairs(configData.UIStates.Keys) do
                if UI_Elements.Keys[id] then
                    UI_Elements.Keys[id].setState(state)
                end
            end
        end
    end
    
    -- Шаг 5: Загружаем Rage состояния
    if configData.RageModules then
        for name, module in pairs(configData.RageModules) do
            if RageModules[name] then
                if module.Value then
                    RageModules[name].Value = module.Value
                end
                
                -- Применяем Rage состояния
                if name == "BlockHooks" then
                    updateBlockHooks(module.Enabled)
                elseif name == "FinishGens" then
                    updateFinishGens(module.Enabled)
                elseif name == "GateNeverOpen" then
                    updateGateNeverOpen(module.Enabled)
                elseif name == "NeverFinishGens" then
                    updateNeverFinishGens(module.Enabled)
                elseif name == "LungeDuration" then
                    updateLungeDuration(module.Enabled, module.Value)
                end
            end
        end
    end
    
    -- Шаг 6: Загружаем Legit состояния
    if configData.LegitStates then
        fixedSpeedEnabled = configData.LegitStates.fixedSpeedEnabled or false
        fixedSpeedValue = configData.LegitStates.fixedSpeedValue or 15
        vaultSpeedEnabled = configData.LegitStates.vaultSpeedEnabled or false
        vaultSpeedValue = configData.LegitStates.vaultSpeedValue or 1.0
        nafEnabled = configData.LegitStates.nafEnabled or false
        selfCareEnabled = configData.LegitStates.selfCareEnabled or false
        noCollisionEnabled = configData.LegitStates.noCollisionEnabled or false
        oldAnimationsEnabled = configData.LegitStates.oldAnimationsEnabled or false
        
        -- Применяем Legit состояния
        updateFixedSpeedChanger(fixedSpeedEnabled, fixedSpeedValue)
        updateVaultSpeedChanger(vaultSpeedEnabled, vaultSpeedValue)
        updateNAF(nafEnabled)
        updateSelfCare(selfCareEnabled)
        updateNoCollision(noCollisionEnabled)
        updateOldAnimations(oldAnimationsEnabled)
    end
    
    -- Шаг 7: Загружаем Misc состояния (кроме FOV и Aspect Ratio)
    if configData.MiscStates then
        for name, state in pairs(configData.MiscStates) do
            if MiscStates[name] then
                MiscStates[name] = state
                
                -- Пока не применяем FOV и Aspect Ratio
                if name ~= "FOVChanger" and name ~= "AspectRatioChanger" then
                    if name == "FreeCamera" then
                        updateFreeCamera(state.Enabled)
                    elseif name == "FlashProgress" then
                        updateFlashProgress(state.Enabled)
                    elseif name == "InfItemCharges" then
                        updateInfItemCharges(state.Enabled)
                    elseif name == "OutfitChanger" then
                        updateOutfitChanger(state.Enabled)
                    end
                end
            end
        end
    end
    
    -- Шаг 8: В САМОМ КОНЦЕ применяем FOV и Aspect Ratio
    if configData.MiscStates then
        local fovState = configData.MiscStates["FOVChanger"]
        local aspectState = configData.MiscStates["AspectRatioChanger"]
        
        if fovState then
            task.wait(0.05) -- Небольшая задержка для стабильности
            updateFOVChanger(fovState.Enabled, fovState.Value)
        end
        
        if aspectState then
            task.wait(0.05) -- Небольшая задержка для стабильности
            updateAspectRatioChanger(aspectState.Enabled, aspectState.Value)
        end
    end
    
    return true
end

-- Удаление конфига
local function DeleteConfig(filename)
    if not IsFileFunctionsAvailable() then
        warn("File functions not available")
        return false
    end
    
    local filePath = ConfigFolder .. "/" .. filename
    
    if not isfile(filePath) then
        warn("Config file does not exist: " .. filePath)
        return false
    end
    
    local success, err = pcall(function()
        delfile(filePath)
    end)
    
    return success, err
end

-- Функция для создания UI конфигов
local function AddConfigContent(Parent)
    local ConfigUI = {}

    -- Основной контейнер
    local Container = Create("Frame", {
        Parent = Parent,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 1
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
    })

    -- 1. ШАПКА ВЫПАДАЮЩЕГО СПИСКА
    local DropdownOpen = false
    
    local DropdownBtn = Create("TextButton", {
        Parent = Container,
        BackgroundColor3 = Theme.Input,
        Size = UDim2.new(1, 0, 0, 32),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
        LayoutOrder = 1
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = Theme.Divider, Thickness = 1})
    })

    local DropdownLabel = Create("TextLabel", {
        Parent = DropdownBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "Select Config",
        TextColor3 = Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6
    })

    local DropdownArrow = Create("ImageLabel", {
        Parent = DropdownBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = "rbxassetid://6031091004",
        ImageColor3 = Theme.SubText,
        ZIndex = 6
    })

    -- 2. ПЛАВАЮЩИЙ КОНТЕЙНЕР
    local FloatingHolder = Create("Frame", {
        Parent = Container,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 50,
        LayoutOrder = 2
    })

    local ListStroke = Create("UIStroke", {
        Color = Theme.Divider, 
        Thickness = 1,
        Transparency = 1
    })

    local DropdownList = Create("ScrollingFrame", {
        Parent = FloatingHolder,
        BackgroundColor3 = Theme.Input,
        Position = UDim2.new(0, 0, 0, 5),
        Size = UDim2.new(1, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 51,
        ClipsDescendants = true,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        ListStroke,
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder, 
            Padding = UDim.new(0, 2)
        })
    })

    -- 3. ПОЛЕ ВВОДА
    local Input = Create("TextBox", {
        Parent = Container,
        BackgroundColor3 = Theme.Input,
        Size = UDim2.new(1, 0, 0, 32),
        Text = "",
        PlaceholderText = "Config name..." .. ConfigExtension,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        LayoutOrder = 3,
        ZIndex = 1
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = Theme.Divider, Thickness = 1}),
        Create("UIPadding", {PaddingLeft = UDim.new(0, 10)})
    })

    -- Логика ввода
    Input:GetPropertyChangedSignal("Text"):Connect(function()
        local text = Input.Text
        
        if text:sub(-5):lower() ~= ConfigExtension then
            local cleanText = text:gsub(ConfigExtension, "")
            if #cleanText > 20 then
                cleanText = cleanText:sub(1, 20)
            end
            Input.Text = cleanText .. ConfigExtension
            Input.CursorPosition = #cleanText + 1
        else
            local cleanText = text:gsub(ConfigExtension, "")
            if #cleanText > 20 then
                cleanText = cleanText:sub(1, 20)
                Input.Text = cleanText .. ConfigExtension
                Input.CursorPosition = #cleanText + 1
            end
        end
    end)

    -- 4. КНОПКИ
    local BtnContainer = Create("Frame", {
        Parent = Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        LayoutOrder = 4,
        ZIndex = 1
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, 
            Padding = UDim.new(0, 6), 
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
    })

    local function AddSmallBtn(text, color)
        local btn = Create("TextButton", {
            Parent = BtnContainer,
            BackgroundColor3 = Theme.Input,
            Size = UDim2.new(0.31, 0, 1, 0),
            Text = text,
            Font = Enum.Font.GothamBold,
            TextColor3 = color,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 1
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Create("UIStroke", {Color = Theme.Divider, Thickness = 1})
        })
        
        btn.MouseEnter:Connect(function() 
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Sidebar
            }):Play() 
        end)
        
        btn.MouseLeave:Connect(function() 
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Input
            }):Play() 
        end)
        
        return btn
    end

    ConfigUI.SaveBtn = AddSmallBtn("Save", Theme.Accent)
    ConfigUI.LoadBtn = AddSmallBtn("Load", Theme.Text)
    ConfigUI.DeleteBtn = AddSmallBtn("Delete", Color3.fromRGB(240, 70, 70))
    ConfigUI.Input = Input

    -- ЛОГИКА АНИМАЦИЙ
    local function ToggleDropdown(shouldOpen)
        DropdownOpen = shouldOpen
        local itemCount = #DropdownList:GetChildren() - 3
        local contentHeight = math.clamp(itemCount * 30, 0, 150)

        if shouldOpen then
            DropdownList.Visible = true
            TweenService:Create(DropdownArrow, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
                Rotation = 180
            }):Play()
            TweenService:Create(DropdownList, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, contentHeight)
            }):Play()
            TweenService:Create(ListStroke, TweenInfo.new(0.2), {
                Transparency = 0
            }):Play()
        else
            TweenService:Create(DropdownArrow, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
                Rotation = 0
            }):Play()
            TweenService:Create(ListStroke, TweenInfo.new(0.1), {
                Transparency = 1
            }):Play()
            local closeTween = TweenService:Create(DropdownList, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, 0)
            })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                if not DropdownOpen then 
                    DropdownList.Visible = false 
                end
            end)
        end
    end

    local function UpdateList()
        for _, v in pairs(DropdownList:GetChildren()) do 
            if v:IsA("TextButton") then 
                v:Destroy() 
            end 
        end
        
        local configs = GetConfigList()
        
        for _, name in ipairs(configs) do
            local item = Create("TextButton", {
                Parent = DropdownList,
                BackgroundTransparency = 1,
                BackgroundColor3 = Theme.Sidebar,
                Size = UDim2.new(1, 0, 0, 28),
                Text = "  " .. name,
                Font = Enum.Font.Gotham,
                TextColor3 = Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = 52
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 4)})
            })

            item.MouseEnter:Connect(function()
                TweenService:Create(item, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.5, 
                    TextColor3 = Theme.Text
                }):Play()
            end)
            
            item.MouseLeave:Connect(function()
                TweenService:Create(item, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1, 
                    TextColor3 = Theme.SubText
                }):Play()
            end)

            item.MouseButton1Click:Connect(function()
                Input.Text = name
                DropdownLabel.Text = name
                DropdownLabel.TextColor3 = Theme.Text
                ToggleDropdown(false)
            end)
        end
        DropdownList.CanvasSize = UDim2.new(0, 0, 0, #configs * 30)
    end

    DropdownBtn.MouseButton1Click:Connect(function()
        if not DropdownOpen then 
            UpdateList() 
        end
        ToggleDropdown(not DropdownOpen)
    end)
    
    -- Кнопки действий
    ConfigUI.SaveBtn.MouseButton1Click:Connect(function()
        local filename = Input.Text
        if filename == "" or filename == ConfigExtension then
            warn("Please enter a valid config name")
            return
        end
        
        if not filename:sub(-5):lower() == ConfigExtension then
            filename = filename .. ConfigExtension
        end
        
        local success, err = SaveConfig(filename)
        if success then
            warn("Config saved: " .. filename)
            UpdateList()
        else
            warn("Failed to save config: " .. tostring(err))
        end
    end)
    
    ConfigUI.LoadBtn.MouseButton1Click:Connect(function()
        local filename = Input.Text
        if filename == "" then
            warn("Please select a config")
            return
        end
        
        if not filename:sub(-5):lower() == ConfigExtension then
            filename = filename .. ConfigExtension
        end
        
        local success = LoadConfig(filename)
        if success then
            warn("Config loaded: " .. filename)
        else
            warn("Failed to load config")
        end
    end)
    
    ConfigUI.DeleteBtn.MouseButton1Click:Connect(function()
        local filename = Input.Text
        if filename == "" then
            warn("Please select a config")
            return
        end
        
        if not filename:sub(-5):lower() == ConfigExtension then
            filename = filename .. ConfigExtension
        end
        
        local success, err = DeleteConfig(filename)
        if success then
            warn("Config deleted: " .. filename)
            Input.Text = ""
            DropdownLabel.Text = "Select Config"
            DropdownLabel.TextColor3 = Theme.SubText
            UpdateList()
        else
            warn("Failed to delete config: " .. tostring(err))
        end
    end)
    
    -- Инициализация
    UpdateList()
    
    return ConfigUI
end

--//CFG TAB XYETA
local C_Left, C_Right = CreatePage("Configs")
local ConfigManagerPanel = AddPanel(C_Left, "Manager") 

AddConfigContent(ConfigManagerPanel)

--//XZ
SwitchTab("Main")

--//ESP CLEANER AFTER PLAYER LEFT XYETA
Players.PlayerRemoving:Connect(function(player)
    -- Удаляем линии скелета
    for key, line in pairs(ESPModules.Killer.Skeleton.Lines) do
        if string.find(key, player.Name) == 1 then
            line:Destroy()
            ESPModules.Killer.Skeleton.Lines[key] = nil
        end
    end
    
    for key, line in pairs(ESPModules.Survivor.Skeleton.Lines) do
        if string.find(key, player.Name) == 1 then
            line:Destroy()
            ESPModules.Survivor.Skeleton.Lines[key] = nil
        end
    end
    
    -- Удаляем метки имен
    if ESPModules.Killer.Names.Labels[player] then
        ESPModules.Killer.Names.Labels[player]:Destroy()
        ESPModules.Killer.Names.Labels[player] = nil
    end
    
    if ESPModules.Survivor.Names.Labels[player] then
        ESPModules.Survivor.Names.Labels[player]:Destroy()
        ESPModules.Survivor.Names.Labels[player] = nil
    end
    
    -- Удаляем метки дистанции
    if ESPModules.Killer.Distance.Labels[player] then
        ESPModules.Killer.Distance.Labels[player]:Destroy()
        ESPModules.Killer.Distance.Labels[player] = nil
    end
    
    if ESPModules.Survivor.Distance.Labels[player] then
        ESPModules.Survivor.Distance.Labels[player]:Destroy()
        ESPModules.Survivor.Distance.Labels[player] = nil
    end
    
    -- Удаляем Chams highlights
    for i, highlight in pairs(ESPModules.Killer.Chams.Highlights) do
        if highlight and highlight.Adornee and highlight.Adornee:IsDescendantOf(player) then
            highlight:Destroy()
            ESPModules.Killer.Chams.Highlights[i] = nil
        end
    end
    
    for i, highlight in pairs(ESPModules.Survivor.Chams.Highlights) do
        if highlight and highlight.Adornee and highlight.Adornee:IsDescendantOf(player) then
            highlight:Destroy()
            ESPModules.Survivor.Chams.Highlights[i] = nil
        end
    end
end)

--//MENU XYETA

task.spawn(function()
    repeat task.wait() until LocalPlayer and LocalPlayer.DisplayName ~= nil
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local success, content = pcall(function() return Players:GetUserThumbnailAsync(userId, thumbType, thumbSize) end)
    if not success then content = "rbxasset://textures/ui/GuiImagePlaceholder.png" end
    local displayName = LocalPlayer.DisplayName or LocalPlayer.Name

    Create("Frame", {
        Parent = Sidebar, BackgroundColor3 = Theme.Input, Size = UDim2.new(0, 160, 0, 50),
        Position = UDim2.new(0, 10, 1, -70), ZIndex = 10
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("ImageLabel", { Name = "AvatarImage", BackgroundColor3 = Theme.Divider, Image = content, Position = UDim2.new(0, 5, 0, 5), Size = UDim2.fromOffset(40, 40), ZIndex = 11 }, { Create("UICorner", {CornerRadius = UDim.new(0, 6)}), Create("UIStroke", {Color = Theme.Accent, Thickness = 1}) }),
        Create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 55, 0, 5), Size = UDim2.new(0, 95, 0, 20), Font = Enum.Font.GothamBold, Text = displayName, TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 11 }),
        Create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 55, 0, 25), Size = UDim2.new(0, 95, 0, 20), Font = Enum.Font.Gotham, Text = "Member", TextColor3 = Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
    })
end)

--// FIXED: MENU ANIMATION & CANVASGROUP TRANSPARENCY
local IsVisible = true
local ActiveTween = nil

local function ToggleMenu(state)
    if ActiveTween then ActiveTween:Cancel() end
    
    if state then
        -- СОХРАНЯЕМ И РАЗБЛОКИРУЕМ КУРСОР (поведение + иконка)
        LastMouseBehavior = UserInputService.MouseBehavior
        LastMouseIconEnabled = UserInputService.MouseIconEnabled
        
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        
        Main.Visible = true
        -- Только изменение прозрачности, размер не трогаем (он фиксирован после интро)
        ActiveTween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            GroupTransparency = 0 -- 0 = полностью видимо
        })
        ActiveTween:Play()
    else
        -- ВОЗВРАЩАЕМ КУРСОР В ПРЕДЫДУЩЕЕ СОСТОЯНИЕ
        UserInputService.MouseBehavior = LastMouseBehavior
        UserInputService.MouseIconEnabled = LastMouseIconEnabled
        
        ActiveTween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            GroupTransparency = 1 -- 1 = полностью невидимо
        })
        ActiveTween:Play()
        ActiveTween.Completed:Connect(function(status)
            if status == Enum.PlaybackState.Completed and not IsVisible then
                Main.Visible = false
            end
        end)
    end
end

UserInputService.InputBegan:Connect(function(input, gpe) 
    if input.KeyCode == Enum.KeyCode.RightShift then 
        IsVisible = not IsVisible
        ToggleMenu(IsVisible)
    end 
end)

--//INTRO XYETA
LastMouseBehavior = UserInputService.MouseBehavior
LastMouseIconEnabled = UserInputService.MouseIconEnabled

UserInputService.MouseBehavior = Enum.MouseBehavior.Default
UserInputService.MouseIconEnabled = true

Main.Size = UDim2.new(0, 750, 0, 0)
Main.Visible = true
TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(750, 550),
    GroupTransparency = 0
}):Play()
