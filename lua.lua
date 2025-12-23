local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Workspace = game:GetService("Workspace")

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

--// ESP Variables
local ESP = {
    Highlights = {},
    ObjectSettings = {},
    Enabled = false
}

--// Watermark Variables
local Watermark = {
    Enabled = false,
    ScreenGui = nil,
    Connection = nil,
    MainFrame = nil,
    WatermarkLabel = nil
}

--// Noclip Variables
local Noclip = {
    Enabled = false,
    NoclipConnection = nil,
    ClipState = false,
    Hotkey = "-",
    floatName = "HumanoidRootPart"
}

--// Dash Variables
local Dash = {
    Enabled = false,
    dashCooldown = false,
    dashCooldownTime = 1.5,
    dashPower = 40,
    Hotkey = "-"
}

--// VaultSpeed Variables
local VaultSpeed = {
    Enabled = false,
    SpeedValue = 0.2,
    MinValue = 0.1,
    MaxValue = 2.0
}

--// StunKiller Variables
local StunKiller = {
    Enabled = false,
    Hotkey = "-"
}

--// NoAnimsFreeze Variables
local NoAnimsFreeze = {
    Enabled = false,
    Hotkey = "-"
}

--// EmoteWheel Variables
local EmoteWheel = {
    Enabled = false,
    Hotkey = "B",
    ScreenGui = nil,
    Bg = nil,
    CurrentPage = 1,
    LastTrack = nil,
    Buttons = {},
    Pages = {
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
        }
    },
    PageText = nil,
    PreviousMouseBehavior = nil,
    PreviousMouseIconEnabled = nil
}

--// Bind List Variables
local BindList = {
    Enabled = false,
    ScreenGui = nil,
    MainFrame = nil,
    Container = nil,
    Toggles = {},
    DragEnabled = true
}

-- Camera Settings
local CameraSettings = {
    EnableFOV = false,
    FOV = 90,
    EnableAspectRatio = false,
    AspectRatio = 1,
    DefaultFOV = workspace.CurrentCamera.FieldOfView
}

-- Aspect Ratio Variables
local aspectRatioConnection = nil
local lastAspectRatio = 1

-- Настройки объектов для ESP с отдельными enabled полями
ESP.ObjectSettings = {
    ["Chests"] = {
        baseName = "Chest",
        exactMatch = false,
        color = Color3.fromHex("#CD5700"),
        enabled = false
    },
    ["Generators"] = {
        baseName = "Generator",
        exactMatch = false,
        color = Color3.fromHex("#1E1112"),
        enabled = false
    },
    ["Hatch"] = {
        baseName = "Hatch",
        exactMatch = true,
        color = Color3.fromHex("#7B3F00"),
        enabled = false
    },
    ["Lockers"] = {
        baseName = "Hiding_Spot",
        exactMatch = false,
        color = Color3.fromHex("#CD5700"),
        enabled = false
    },
    ["Hooks"] = {
        baseName = "Hook",
        exactMatch = false,
        color = Color3.fromHex("#A5260A"),
        enabled = false
    },
    ["Killer"] = {
        baseName = "Killer",
        exactMatch = true,
        color = Color3.fromHex("#A5260A"),
        enabled = false
    },
    ["Pallets"] = {
        baseName = "Pallet",
        exactMatch = false,
        color = Color3.fromHex("#DAD871"),
        enabled = false
    },
    ["Survivors"] = {
        baseName = "Survivor",
        exactMatch = true,
        color = Color3.fromHex("#AFEEEE"),
        enabled = false
    },
    ["Exits"] = {
        baseName = "Wall_Mount",
        exactMatch = true,
        color = Color3.fromHex("#969696"),
        enabled = false
    },
    ["Windows"] = {
        baseName = "Window",
        exactMatch = false,
        color = Color3.fromHex("#DAD871"),
        enabled = false
    },
    ["Totems"] = {
        baseName = "Totem",
        exactMatch = false,
        color = Color3.fromHex("#FFFDDF"),
        enabled = false
    }
}

--// Noclip Functions - WORKING VERSION
local function enableNoclip()
    if Noclip.NoclipConnection then
        Noclip.NoclipConnection:Disconnect()
    end
    
    Noclip.Enabled = true
    
    Noclip.NoclipConnection = RunService.Stepped:Connect(function()
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if Noclip.NoclipConnection then
        Noclip.NoclipConnection:Disconnect()
        Noclip.NoclipConnection = nil
    end
    
    Noclip.Enabled = false
    
    local character = LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function toggleNoclip()
    if Noclip.Enabled then
        disableNoclip()
    else
        enableNoclip()
    end
end

--// Helper function to check hotkey matches
local function isHotkeyMatch(input, hotkey)
    if hotkey == "-" then return false end
    
    -- Check for mouse buttons
    if hotkey == "MouseButton1" then
        return input.UserInputType == Enum.UserInputType.MouseButton1
    elseif hotkey == "MouseButton2" then
        return input.UserInputType == Enum.UserInputType.MouseButton2
    elseif hotkey == "MouseButton3" then
        return input.UserInputType == Enum.UserInputType.MouseButton3
    end
    
    -- Check for keyboard keys
    if input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode.Name == hotkey
    end
    
    return false
end

--// StunKiller Functions
local function stunKiller()
    if not StunKiller.Enabled then return end
    
    local success, result = pcall(function()
        local RemoteStorage = game:GetService('ReplicatedStorage'):WaitForChild('RemoteEvents')
        local Cheat = RemoteStorage:WaitForChild('NewPropertie')

        local Obfuscate = function(TYPE, VALUE1, VALUE2)
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

        for ds, b in pairs(game.Players:GetPlayers()) do
            if b.Team == game.Teams.Killer then
                Obfuscate("string",b.Backpack.Scripts.values.Stunned.Kind,"Wiggle")
                Obfuscate("bool",b.Backpack.Scripts.values.Stunned,true)
            end
        end
    end)
end

--// NoAnimsFreeze Variables
local movementEnabled = false
local lastPlatformStandState = false
local lastAnchoredState = false
local character, humanoid, rootPart
local monitorConnection = nil

local function updateCharacterReferences()
    character = LocalPlayer.Character
    if character then
        humanoid = character:FindFirstChildOfClass("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    end
end

local function enableMovement()
    if not character or not humanoid then 
        updateCharacterReferences()
        if not character or not humanoid then return false end
    end
    
    lastPlatformStandState = humanoid.PlatformStand
    if rootPart then
        lastAnchoredState = rootPart.Anchored
    end
    
    humanoid.PlatformStand = false
    
    if rootPart then
        rootPart.Anchored = false
        rootPart.CanCollide = true
    end
    
    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    task.wait(0.05)
    humanoid:ChangeState(Enum.HumanoidStateType.Running)
    
    if monitorConnection then
        monitorConnection:Disconnect()
    end
    
    monitorConnection = RunService.Heartbeat:Connect(function()
        if not character or not humanoid then return end
        
        if humanoid.PlatformStand == true then
            humanoid.PlatformStand = false
        end
        
        if rootPart and rootPart.Anchored == true then
            rootPart.Anchored = false
        end
    end)
    
    movementEnabled = true
    return true
end

local function disableMovement()
    if not character or not humanoid then 
        updateCharacterReferences()
        if not character or not humanoid then return false end
    end
    
    if monitorConnection then
        monitorConnection:Disconnect()
        monitorConnection = nil
    end
    
    humanoid.PlatformStand = lastPlatformStandState
    
    if rootPart then
        rootPart.Anchored = lastAnchoredState
    end
    
    humanoid:ChangeState(Enum.HumanoidStateType.Running)
    
    movementEnabled = false
    return true
end

local function toggleNoAnimsFreeze()
    if movementEnabled then
        disableMovement()
    else
        enableMovement()
    end
end

--// Dash Functions
local function performDash()
    if Dash.dashCooldown or not Dash.Enabled then return end
    Dash.dashCooldown = true
    
    local character = LocalPlayer.Character
    if not character then Dash.dashCooldown = false return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart and humanoid.Health > 0 then
        local lookVector = rootPart.CFrame.LookVector
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(40000, 0, 40000)
        bodyVelocity.Velocity = lookVector * Dash.dashPower
        bodyVelocity.P = 10000
        bodyVelocity.Parent = rootPart
        
        task.delay(0.1, function()
            if bodyVelocity then bodyVelocity:Destroy() end
        end)
        
        rootPart.Velocity = rootPart.Velocity + (lookVector * Dash.dashPower)
    end
    
    task.delay(Dash.dashCooldownTime, function() Dash.dashCooldown = false end)
end

--// VaultSpeed Functions
local function setVaultSpeed()
    if not VaultSpeed.Enabled then return end
    
    local success, result = pcall(function()
        local ugc = game:FindFirstChild("Ugc")
        if not ugc then
            ugc = game:GetService("Workspace"):FindFirstChild("Ugc")
        end
        
        if not ugc then
            ugc = game:GetService("Players")
        end
        
        local playersObj = ugc:FindFirstChild("Players")
        if playersObj then
        else
            if ugc.ClassName == "Players" then
                playersObj = ugc
            else
                return false, "Players not found"
            end
        end
        
        local playerObj = playersObj:FindFirstChild(LocalPlayer.Name)
        if not playerObj then
            return false, "Player not found"
        end
        
        local playerValues = playerObj:FindFirstChild("PlayerValues")
        if not playerValues then
            return false, "PlayerValues not found"
        end
        
        playerValues:SetAttribute("WindowVaultSpeed", VaultSpeed.SpeedValue)
        
        local newValue = playerValues:GetAttribute("WindowVaultSpeed")
        if newValue == VaultSpeed.SpeedValue then
            return true, "Success"
        else
            return false, "Value not set"
        end
    end)
end

--// Watermark Functions
local function enableWatermark()
    if Watermark.Enabled then return end
    
    if Watermark.ScreenGui then
        Watermark.ScreenGui:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WatermarkUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 0, 0, 26)
    MainFrame.Position = UDim2.new(1, -30, 0, -30)
    MainFrame.AnchorPoint = Vector2.new(1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BackgroundTransparency = 0.6
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame
    
    local WatermarkLabel = Instance.new("TextLabel")
    WatermarkLabel.Name = "Watermark"
    WatermarkLabel.Size = UDim2.new(0, 0, 1, 0)
    WatermarkLabel.Position = UDim2.new(0, 0, 0, 0)
    WatermarkLabel.BackgroundTransparency = 1
    WatermarkLabel.Text = "0fps | 0ms"
    WatermarkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    WatermarkLabel.Font = Enum.Font.Code
    WatermarkLabel.TextSize = 14
    WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
    WatermarkLabel.AutomaticSize = Enum.AutomaticSize.X
    WatermarkLabel.Parent = MainFrame
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, 8)
    UIPadding.PaddingRight = UDim.new(0, 8)
    UIPadding.Parent = WatermarkLabel
    
    local fps = 0
    local ping = 0
    local frameCount = 0
    local lastUpdate = time()
    
    local function updateStats()
        frameCount = frameCount + 1
        
        local currentTime = time()
        if currentTime - lastUpdate >= 0.5 then
            fps = math.floor(frameCount / (currentTime - lastUpdate))
            frameCount = 0
            lastUpdate = currentTime
            
            local success, result = pcall(function()
                return LocalPlayer:GetNetworkPing()
            end)
            
            if success then
                ping = math.floor(result * 1000)
                if ping > 999 then
                    ping = 999
                    WatermarkLabel.Text = string.format("%dfps | %d+ms", fps, ping)
                else
                    WatermarkLabel.Text = string.format("%dfps | %dms", fps, ping)
                end
            else
                ping = 0
                WatermarkLabel.Text = string.format("%dfps | %dms", fps, ping)
            end
        end
    end
    
    WatermarkLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        MainFrame.Size = UDim2.new(0, WatermarkLabel.TextBounds.X + 16, 0, 26)
    end)
    
    local connection = RunService.Heartbeat:Connect(updateStats)
    
    Watermark.ScreenGui = ScreenGui
    Watermark.MainFrame = MainFrame
    Watermark.WatermarkLabel = WatermarkLabel
    Watermark.Connection = connection
    Watermark.Enabled = true
    
    task.spawn(function()
        task.wait(0.1)
        MainFrame.Size = UDim2.new(0, WatermarkLabel.TextBounds.X + 16, 0, 26)
    end)
end

local function disableWatermark()
    if not Watermark.Enabled then return end
    
    if Watermark.Connection then
        Watermark.Connection:Disconnect()
        Watermark.Connection = nil
    end
    
    if Watermark.ScreenGui then
        Watermark.ScreenGui:Destroy()
        Watermark.ScreenGui = nil
    end
    
    Watermark.MainFrame = nil
    Watermark.WatermarkLabel = nil
    Watermark.Enabled = false
end

--// Bind List Functions
local function CreateRow(name, defaultState)
    if not BindList.Container then return nil end
    
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 14)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = #BindList.Container:GetChildren()
    Row.Parent = BindList.Container
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Text = name
    NameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font = Enum.Font.Code
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Row
    
    local StateLabel = Instance.new("TextLabel")
    StateLabel.Size = UDim2.new(0.4, 0, 1, 0)
    StateLabel.Position = UDim2.new(0.6, 0, 0, 0)
    StateLabel.BackgroundTransparency = 1
    StateLabel.Font = Enum.Font.Code
    StateLabel.TextSize = 13
    StateLabel.TextXAlignment = Enum.TextXAlignment.Right
    StateLabel.Parent = Row
    
    BindList.Toggles[name] = {
        NameLabel = NameLabel,
        StateLabel = StateLabel,
        Enabled = defaultState
    }
    
    local function UpdateVisuals(animate)
        local data = BindList.Toggles[name]
        if not data then return end
        
        local text = data.Enabled and "[on]" or "[off]"
        local stateTargetColor = data.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 100, 100)
        local nameTargetColor = data.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
        
        data.StateLabel.Text = text
        
        if animate then
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(data.StateLabel, tweenInfo, {TextColor3 = stateTargetColor}):Play()
            TweenService:Create(data.NameLabel, tweenInfo, {TextColor3 = nameTargetColor}):Play()
        else
            data.StateLabel.TextColor3 = stateTargetColor
            data.NameLabel.TextColor3 = nameTargetColor
        end
    end
    
    BindList.Toggles[name].UpdateVisuals = UpdateVisuals
    UpdateVisuals(false)
    
    return Row
end

local function UpdateBindList()
    if not BindList.Enabled or not BindList.Container then return end
    
    -- Очищаем контейнер
    for _, child in pairs(BindList.Container:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    BindList.Toggles = {}
    
    -- Функции для отображения в Bind List:
    -- Dash: отображается если есть бинд
    if Dash.Hotkey ~= "-" then
        CreateRow("Dash", Dash.Enabled)
    end
    
    -- Stun Killer: отображается если есть бинд
    if StunKiller.Hotkey ~= "-" then
        CreateRow("Stun Killer", StunKiller.Enabled)
    end
    
    -- Noclip: отображается если есть бинд
    if Noclip.Hotkey ~= "-" then
        CreateRow("Noclip", Noclip.Enabled)
    end
    
    -- No Anims Freeze: отображается как "NAF" если есть бинд
    if NoAnimsFreeze.Hotkey ~= "-" then
        CreateRow("NAF", movementEnabled)
    end
    
    -- Emote Wheel: отображается если есть бинд
    if EmoteWheel.Hotkey ~= "-" then
        CreateRow("Emote Wheel", EmoteWheel.Enabled)
    end
    
    -- Обновляем размер MainFrame в зависимости от количества строк
    local rowCount = #BindList.Container:GetChildren()
    if rowCount > 0 then
        BindList.MainFrame.Size = UDim2.new(0, 150, 0, 26 + (rowCount * 18))
    else
        BindList.MainFrame.Size = UDim2.new(0, 150, 0, 0)
    end
end

local function enableBindList()
    if BindList.Enabled then return end
    
    if BindList.ScreenGui then
        BindList.ScreenGui:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeybindsUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 150, 0, 110)
    MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame
    
    local HeaderBG = Instance.new("Frame")
    HeaderBG.Name = "Header"
    HeaderBG.Size = UDim2.new(1, 0, 0, 26)
    HeaderBG.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    HeaderBG.BackgroundTransparency = 0
    HeaderBG.BorderSizePixel = 0
    HeaderBG.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = HeaderBG
    
    local HeaderFiller = Instance.new("Frame")
    HeaderFiller.Name = "Filler"
    HeaderFiller.Size = UDim2.new(1, 0, 0.5, 0)
    HeaderFiller.Position = UDim2.new(0, 0, 0.5, 0)
    HeaderFiller.BackgroundColor3 = HeaderBG.BackgroundColor3
    HeaderFiller.BorderSizePixel = 0
    HeaderFiller.Parent = HeaderBG
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = "keybinds"
    Title.Size = UDim2.new(1, 0, 1, -2)
    Title.Position = UDim2.new(0, 0, 0, 1)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.ZIndex = 5
    Title.Parent = HeaderBG
    
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Size = UDim2.new(1, 0, 0, 1)
    Separator.Position = UDim2.new(0, 0, 0, 26)
    Separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Separator.BackgroundTransparency = 0.9
    Separator.BorderSizePixel = 0
    Separator.ZIndex = 4
    Separator.Parent = MainFrame
    
    local Container = Instance.new("Frame")
    Container.Name = "ListContainer"
    Container.Size = UDim2.new(1, -16, 1, -34)
    Container.Position = UDim2.new(0, 8, 0, 32)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame
    
    local UIList = Instance.new("UIListLayout")
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 4)
    UIList.Parent = Container
    
    BindList.ScreenGui = ScreenGui
    BindList.MainFrame = MainFrame
    BindList.Container = Container
    BindList.Enabled = true
    
    UpdateBindList()
    
    -- Drag functionality
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    MainFrame.InputBegan:Connect(function(input)
        if not BindList.DragEnabled then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function disableBindList()
    if not BindList.Enabled then return end
    
    if BindList.ScreenGui then
        BindList.ScreenGui:Destroy()
        BindList.ScreenGui = nil
    end
    
    BindList.MainFrame = nil
    BindList.Container = nil
    BindList.Toggles = {}
    BindList.Enabled = false
end

local function updateBindListVisuals()
    if not BindList.Enabled then return end
    
    -- Обновляем состояния функций
    if BindList.Toggles["Dash"] then
        BindList.Toggles["Dash"].Enabled = Dash.Enabled
        BindList.Toggles["Dash"].UpdateVisuals(true)
    end
    
    if BindList.Toggles["Stun Killer"] then
        BindList.Toggles["Stun Killer"].Enabled = StunKiller.Enabled
        BindList.Toggles["Stun Killer"].UpdateVisuals(true)
    end
    
    if BindList.Toggles["Noclip"] then
        BindList.Toggles["Noclip"].Enabled = Noclip.Enabled
        BindList.Toggles["Noclip"].UpdateVisuals(true)
    end
    
    if BindList.Toggles["NAF"] then
        BindList.Toggles["NAF"].Enabled = movementEnabled
        BindList.Toggles["NAF"].UpdateVisuals(true)
    end
    
    if BindList.Toggles["Emote Wheel"] then
        BindList.Toggles["Emote Wheel"].Enabled = EmoteWheel.Enabled
        BindList.Toggles["Emote Wheel"].UpdateVisuals(true)
    end
end

--// Helper Functions
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

--// FOV Functions
local function applyFOV()
    if CameraSettings.EnableFOV then
        workspace.CurrentCamera.FieldOfView = CameraSettings.FOV
    else
        workspace.CurrentCamera.FieldOfView = CameraSettings.DefaultFOV
    end
end

--// Aspect Ratio Functions
local function applyAspectRatio()
    if CameraSettings.EnableAspectRatio then
        local camera = workspace.CurrentCamera
        camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, CameraSettings.AspectRatio, 0, 0, 0, 1)
    end
end

local function setupAspectRatioLoop()
    if aspectRatioConnection then
        aspectRatioConnection:Disconnect()
        aspectRatioConnection = nil
    end
    
    if CameraSettings.EnableAspectRatio then
        aspectRatioConnection = RunService.RenderStepped:Connect(function()
            applyAspectRatio()
        end)
    end
end

--// ESP Functions
local function clearAllHighlights()
    for _, highlight in pairs(ESP.Highlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    ESP.Highlights = {}
end

local function findObjects()
    local foundObjects = {}
    
    for objName, settings in pairs(ESP.ObjectSettings) do
        if settings.enabled then
            local objects = {}
            
            for _, descendant in pairs(Workspace:GetDescendants()) do
                if descendant:IsA("BasePart") or descendant:IsA("Model") then
                    local name = descendant.Name
                    
                    if settings.exactMatch then
                        if name == settings.baseName then
                            table.insert(objects, descendant)
                        end
                    else
                        if string.find(name, settings.baseName) == 1 then
                            table.insert(objects, descendant)
                        end
                    end
                end
            end
            
            if #objects > 0 then
                foundObjects[objName] = {
                    objects = objects,
                    color = settings.color
                }
            end
        end
    end
    
    return foundObjects
end

local function getPlayerTeam(player)
    if player.Team then
        local teamName = player.Team.Name
        if teamName == "Killer" or teamName == "KILLER" then
            return "Killer"
        elseif teamName == "Survivor" or teamName == "SURVIVOR" then
            return "Survivor"
        end
    end
    
    local role = player:GetAttribute("Role") or player:GetAttribute("Team")
    if role == "Killer" or role == "KILLER" or role == "killer" then
        return "Killer"
    elseif role == "Survivor" or role == "SURVIVOR" or role == "survivor" then
        return "Survivor"
    end
    
    return "Survivor"
end

local function createHighlight(object, color)
    if not object or not object.Parent then return nil end
    
    if object:IsDescendantOf(LocalPlayer.Character) then
        return nil
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = object
    
    return highlight
end

local function updateESP()
    if not ESP.Enabled then
        clearAllHighlights()
        return
    end
    
    clearAllHighlights()
    
    local foundObjects = findObjects()
    
    for objType, data in pairs(foundObjects) do
        for _, object in pairs(data.objects) do
            if object and object.Parent then
                local highlight = createHighlight(object, data.color)
                if highlight then
                    table.insert(ESP.Highlights, highlight)
                end
            end
        end
    end
    
    if ESP.ObjectSettings.Killer.enabled or ESP.ObjectSettings.Survivors.enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local team = getPlayerTeam(player)
                
                if ESP.ObjectSettings.Killer.enabled and team == "Killer" then
                    local highlight = createHighlight(character, ESP.ObjectSettings.Killer.color)
                    if highlight then
                        table.insert(ESP.Highlights, highlight)
                    end
                elseif ESP.ObjectSettings.Survivors.enabled and team == "Survivor" then
                    local highlight = createHighlight(character, ESP.ObjectSettings.Survivors.color)
                    if highlight then
                        table.insert(ESP.Highlights, highlight)
                    end
                end
            end
        end
    end
end

--// UI Setup
local ScreenGui = Create("ScreenGui", {
	Name = "HyperionV2",
	Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local Main = Create("CanvasGroup", { -- Меняем Frame на CanvasGroup
	Name = "Main",
	Parent = ScreenGui,
	BackgroundColor3 = Theme.Background,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(750, 550),
	AnchorPoint = Vector2.new(0.5, 0.5),
	ClipsDescendants = true,
	Visible = true,
	GroupTransparency = 0 -- 0 = полностью видно
}, { Create("UICorner", {CornerRadius = UDim.new(0, 10)}) })

MakeDraggable(Main, Main)

--// State Variables
local CurrentTab = nil
local Tabs = {}
local Pages = {}
local PageColumns = {}

--// Sidebar
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
	Text = "yeban.cc",
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

local Nav = Create("Frame", {
	Parent = Sidebar,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 10, 0, 80),
	Size = UDim2.new(1, -20, 0, 300)
}, { Create("UIListLayout", {Padding = UDim.new(0, 8)}) })

--// Content Area
local Content = Create("Frame", {
	Parent = Main,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 190, 0, 10),
	Size = UDim2.new(1, -200, 1, -20)
})

-- Header
local Header = Create("Frame", {Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,60)})
Create("TextLabel", {
	Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(0,200,0,30),
	Font = Enum.Font.GothamBold, Text = "Hello, " .. LocalPlayer.DisplayName, TextColor3 = Theme.Text, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Left
})
Create("TextLabel", {
	Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,30), Size = UDim2.new(0,200,0,20),
	Font = Enum.Font.Gotham, Text = "Welcome Back!", TextColor3 = Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
})

-- Search Logic
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
		Text = "",
		TextColor3 = Theme.SubText, 
		TextSize = 16, 
		Font = Enum.Font.Gotham
	})
})
SearchBoxInput = Create("TextBox", {
	Parent = SearchBar,
	BackgroundTransparency = 1, Position = UDim2.new(0,35,0,0), Size = UDim2.new(1,-40,1,0),
	Font = Enum.Font.Gotham, PlaceholderText = "Search", Text = "", TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false
})
SearchBoxInput:GetPropertyChangedSignal("Text"):Connect(function()
	UpdateSearch(SearchBoxInput.Text)
end)
--// Modified Tab System with Smooth Transitions
local function SwitchTab(tabName)
    -- Если нажали на ту же самую вкладку, ничего не делаем
    if CurrentTab == tabName then return end
    
    local oldTabName = CurrentTab
    CurrentTab = tabName
    
    -- 1. Обновляем визуальный стиль кнопок (Цвета и иконки)
    for name, btn in pairs(Tabs) do
        local active = (name == tabName)
        -- Используем TweenService и для кнопок для красоты
        local buttonGoal = {
            BackgroundColor3 = active and Theme.Accent or Color3.new(1,1,1),
            BackgroundTransparency = active and 0 or 1
        }
        TweenService:Create(btn, TweenInfo.new(0.3), buttonGoal):Play()
        
        local textGoal = {TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(120,120,120)}
        TweenService:Create(btn.Content, TweenInfo.new(0.3), textGoal):Play()
        TweenService:Create(btn.Icon, TweenInfo.new(0.3), textGoal):Play()
    end

    -- 2. Анимация страниц (Content)
    local newPage = Pages[tabName]
    local oldPage = Pages[oldTabName]
    
    -- Настройки анимации
    local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    -- Позиции
    local centerPos = UDim2.new(0, 0, 0, 70) -- Позиция в центре (как в оригинале CreatePage)
    local leftPos = UDim2.new(-2, 0, 0, 70)  -- Уезжает влево
    local rightPos = UDim2.new(0.5, 0, 0, 70)  -- Приезжает справа

    -- Анимируем старую страницу (если она есть)
    if oldPage then
        local tweenOut = TweenService:Create(oldPage, tweenInfo, {Position = leftPos})
        tweenOut:Play()
        
        -- Скрываем старую страницу после завершения анимации, чтобы не нагружать рендер
        task.delay(0.35, function()
            if CurrentTab ~= oldTabName then -- Проверка на случай быстрого переключения
                oldPage.Visible = false
                oldPage.Position = centerPos -- Возвращаем на место (скрытую)
            end
        end)
    end

    -- Анимируем новую страницу
    if newPage then
        newPage.Visible = true      -- Делаем видимой
        newPage.Position = rightPos -- Ставим справа за экраном
        
        local tweenIn = TweenService:Create(newPage, tweenInfo, {Position = centerPos})
        tweenIn:Play()
    end
    
    -- Очищаем поиск при смене вкладки
    SearchBoxInput.Text = ""
end

local function CreateTabButton(text, icon)
	local btn = Create("TextButton", {
		Parent = Nav,
		BackgroundColor3 = Color3.new(1,1,1),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
		Text = "",
		AutoButtonColor = false
	}, { Create("UICorner", {CornerRadius = UDim.new(0, 8)}) })
	
	btn.MouseButton1Click:Connect(function() SwitchTab(text) end)
	
	local lbl = Create("TextLabel", {
		Name = "Content",
		Parent = btn,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 40, 0, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = Color3.fromRGB(120,120,120),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local ico = Create("TextLabel", {
		Name = "Icon",
		Parent = btn,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 40, 1, 0),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = Color3.fromRGB(120,120,120),
		TextSize = 18
	})
	
	Tabs[text] = btn
end

--// Page Construction
local function CreatePage(name)
	local page = Create("Frame", {
		Name = name,
		Parent = Content,
		BackgroundTransparency = 1,
		Position = UDim2.new(0,0,0,70),
		Size = UDim2.new(1,0,1,-70),
		Visible = false,
		ClipsDescendants = true
	})
	
	local scroll = Create("ScrollingFrame", {
		Parent = page,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,1,0),
		CanvasSize = UDim2.new(0,0,0,0),
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})
	
	local left = Create("Frame", {
		Parent = scroll, 
		BackgroundTransparency = 1, 
		Size = UDim2.new(0.45, 0, 1, 0)
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 15), 
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	})
	
	local right = Create("Frame", {
		Parent = scroll, 
		BackgroundTransparency = 1, 
		Position = UDim2.new(0.47, 0, 0, 0),
		Size = UDim2.new(0.53, 0, 1, 0)
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 15), 
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	})
	
	PageColumns[page] = {
		LeftCol = left,
		RightCol = right
	}
	
	Pages[name] = page
	return left, right
end

--// Bottom Gradient Fade
local FadeFrame = Create("Frame", {
	Parent = Content,
	BackgroundColor3 = Theme.Background,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, -12),
	Size = UDim2.new(1, 0, 0, 17),
	ZIndex = 5
}, {
	Create("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0)
		})
	})
})

--// Components Generators
local function AddPanel(parent, title)
	local p = Create("Frame", {Parent = parent, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y}, {
		Create("UICorner", {CornerRadius = UDim.new(0,8)}),
		Create("UIPadding", {PaddingTop = UDim.new(0,15), PaddingBottom = UDim.new(0,15), PaddingLeft = UDim.new(0,15), PaddingRight = UDim.new(0,15)})
	})
	local t = Create("TextLabel", {Name="Title", Parent = p, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Font = Enum.Font.GothamBold, Text = title, TextColor3 = Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})
	local cont = Create("Frame", {Name="Container", Parent = p, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,30), Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y}, {Create("UIListLayout", {Padding = UDim.new(0,12), SortOrder = Enum.SortOrder.LayoutOrder})})
	return cont
end

--// Измененная функция AddToggle для поддержки callback
local function AddToggle(parent, name, on, callback)
	local f = Create("Frame", {
		Parent = parent, 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1,0,0,20)
	})
	
	local itemNameLabel = Create("TextLabel", {
		Name = "ItemName",
		Parent = f,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = name,
		TextColor3 = on and Theme.Text or Theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center
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
		Size = on and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5)
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 2)})
	})
	
	local btn = Instance.new("TextButton", f)
	btn.BackgroundTransparency = 1
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.Text = ""
	
	btn.MouseButton1Click:Connect(function()
		on = not on
		
		TweenService:Create(redSquare, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = on and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)
		}):Play()
		
		TweenService:Create(itemNameLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextColor3 = on and Theme.Text or Theme.SubText
		}):Play()
		
		if callback then
			callback(on)
		end
	end)
	
	return f
end

--// Функция для добавления однократного переключателя Old Anims
local function AddOldAnimsToggle(parent)
    local f = Create("Frame", {
        Parent = parent, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1,0,0,20)
    })
    
    local itemNameLabel = Create("TextLabel", {
        Name = "ItemName",
        Parent = f,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = "Old Anims*",
        TextColor3 = Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
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
        Size = UDim2.fromOffset(0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 2)})
    })
    
    local hasBeenActivated = false
    
    local btn = Instance.new("TextButton", f)
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""
    
    btn.MouseButton1Click:Connect(function()
        if not hasBeenActivated then
            hasBeenActivated = true
            
            TweenService:Create(redSquare, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(12, 12)
            }):Play()
            
            TweenService:Create(itemNameLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = Theme.Text
            }):Play()
            
            -- Выполняем скрипт для замены анимаций
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

            local success, errorMsg = pcall(function()
                for i, D in pairs(game.ReplicatedStorage.Game_Assets.Animations.Movement.Survivor:GetChildren()) do
                    D.AnimationId = l[D.Name]
                    D:SetAttribute("Speed", b[D.Name])
                end
            end)
            
            if not success then
                warn("Ошибка при применении Old Anims: " .. tostring(errorMsg))
            end
        end
    end)
    
    return f
end

--// Функция для добавления текстовой метки
local function AddLabel(parent, text)
    local f = Create("Frame", {
        Parent = parent, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1,0,0,20)
    })
    
    local label = Create("TextLabel", {
        Parent = f,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = Theme.SubText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    return f
end

--// Упрощенная функция AddSlider для перетаскивания за кружок
local function AddSlider(parent, name, minVal, maxVal, defaultVal, showValue, callback, decimals)
    local f = Create("Frame", {
        Parent = parent, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1,0,0,20)
    })
    
    Create("TextLabel", {
        Name="ItemName", 
        Parent = f, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(0.4,0,1,0), 
        Font = Enum.Font.GothamMedium, 
        Text = name, 
        TextColor3 = Theme.Text, 
        TextSize = 12, 
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueText = nil
    if showValue then
        valueText = Create("TextLabel", {
            Name = "ValueText",
            Parent = f,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.4, 0, 0, 0),
            Size = UDim2.new(0.15, 0, 1, 0),
            Font = Enum.Font.Gotham,
            Text = string.format("%." .. (decimals or 1) .. "f", defaultVal),
            TextColor3 = Theme.SubText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Center
        })
    end
    
    local sliderPosition = showValue and 0.55 or 0.4
    local sliderSize = showValue and 0.45 or 0.6
    
    local bg = Create("Frame", {
        Name = "SliderBG",
        Parent = f, 
        BackgroundColor3 = Theme.Input, 
        Position = UDim2.new(sliderPosition,0,0.5,-3), 
        Size = UDim2.new(sliderSize,0,0,6)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1,0)})
    })
    
    local startPercent = (defaultVal - minVal) / (maxVal - minVal)
    
    local fill = Create("Frame", {
        Name = "SliderFill",
        Parent = bg, 
        BackgroundColor3 = Theme.Accent, 
        Size = UDim2.new(startPercent,0,1,0)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1,0)})
    })
    
    local thumb = Create("Frame", {
        Name = "SliderThumb",
        Parent = fill, 
        BackgroundColor3 = Theme.Accent,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(10,10)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1,0)}), 
        Create("UIStroke", {
            Color = Theme.Sidebar,
            Thickness = 2
        })
    })
    
    local isDragging = false
    local originalThumbSize = UDim2.fromOffset(10, 10)
    local pressedThumbSize = UDim2.fromOffset(14, 14)
    
    local function UpdateSlide(mouseX)
        local percent = math.clamp((mouseX - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local value = minVal + (maxVal - minVal) * percent
        
        local multiplier = 10 ^ (decimals or 1)
        value = math.floor(value * multiplier) / multiplier
        
        fill.Size = UDim2.new(percent, 0, 1, 0)
        
        if showValue and valueText then
            valueText.Text = string.format("%." .. (decimals or 1) .. "f", value)
        end
        
        if callback then
            callback(value)
        end
    end
    
    local sliderButton = Instance.new("TextButton", bg)
    sliderButton.BackgroundTransparency = 1
    sliderButton.Size = UDim2.new(1, 0, 1, 0)
    sliderButton.Position = UDim2.new(0, 0, 0, 0)
    sliderButton.Text = ""
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            UpdateSlide(input.Position.X)
            
            TweenService:Create(thumb, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = pressedThumbSize
            }):Play()
        end
    end)
    
    local thumbButton = Instance.new("TextButton", thumb)
    thumbButton.BackgroundTransparency = 1
    thumbButton.Size = UDim2.new(1, 0, 1, 0)
    thumbButton.Text = ""
    
    thumbButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            
            TweenService:Create(thumb, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = pressedThumbSize
            }):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlide(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            isDragging = false
            
            TweenService:Create(thumb, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = originalThumbSize
            }):Play()
        end
    end)
    
    return f
end

--// Переделанная функция AddKey для биндов
local function AddKey(parent, name, defaultKey, callback)
    local f = Create("Frame", {
        Parent = parent, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1,0,0,20)
    })
    
    Create("TextLabel", {
        Name="ItemName", 
        Parent = f, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(0.6,0,1,0), 
        Font = Enum.Font.GothamMedium, 
        Text = name, 
        TextColor3 = Theme.Text, 
        TextSize = 12, 
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local currentKey = defaultKey or "-"
    local isListening = false
    
    local keyFrame = Create("Frame", {
        Parent = f, 
        BackgroundColor3 = Theme.Input, 
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 60, 1, 0)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0,4)}),
        Create("TextLabel", {
            Name = "KeyText",
            BackgroundTransparency = 1, 
            Position = UDim2.new(0,0,0,0), 
            Size = UDim2.new(1,0,1,0), 
            Font = Enum.Font.Gotham, 
            Text = currentKey, 
            TextColor3 = Theme.SubText, 
            TextSize = 11, 
            TextXAlignment = Enum.TextXAlignment.Center
        })
    })
    
    local function updateKeyText()
        local keyTextLabel = keyFrame:FindFirstChild("KeyText")
        if keyTextLabel then
            keyTextLabel.Text = currentKey
        end
    end
    
    local function startListening()
        if isListening then return end
        
        isListening = true
        currentKey = "..."
        updateKeyText()
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.Backspace then
                currentKey = "-"
            elseif input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = tostring(input.KeyCode.Name)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                currentKey = "MouseButton1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                currentKey = "MouseButton2"
            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                currentKey = "MouseButton3"
            end
            
            isListening = false
            updateKeyText()
            
            if callback then
                callback(currentKey)
            end
            
            connection:Disconnect()
        end)
    end
    
    local btn = Instance.new("TextButton", keyFrame)
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""
    
    btn.MouseButton1Click:Connect(function()
        startListening()
    end)
    
    return f
end

--// EMOTEWHEEL FUNCTIONS INTEGRATION
local function initializeEmoteWheelUI()
    if EmoteWheel.ScreenGui then
        EmoteWheel.ScreenGui:Destroy()
    end
    
    EmoteWheel.ScreenGui = Instance.new("ScreenGui")
    EmoteWheel.ScreenGui.Name = "EmoteWheel"
    EmoteWheel.ScreenGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui
    
    EmoteWheel.Bg = Instance.new("Frame")
    EmoteWheel.Bg.Size = UDim2.new(1,0,1,0)
    EmoteWheel.Bg.BackgroundTransparency = 1
    EmoteWheel.Bg.Visible = false
    EmoteWheel.Bg.Parent = EmoteWheel.ScreenGui
    
    -- Текст страницы (только номер)
    EmoteWheel.PageText = Instance.new("TextLabel")
    EmoteWheel.PageText.Size = UDim2.new(0, 200, 0, 30)
    EmoteWheel.PageText.Position = UDim2.new(0.5, -100, 0.95, 0)
    EmoteWheel.PageText.BackgroundTransparency = 1
    EmoteWheel.PageText.Text = "1/"..#EmoteWheel.Pages
    EmoteWheel.PageText.TextColor3 = Color3.new(1, 1, 1)
    EmoteWheel.PageText.Font = Enum.Font.SourceSansBold
    EmoteWheel.PageText.TextSize = 24
    EmoteWheel.PageText.Visible = false
    EmoteWheel.PageText.Parent = EmoteWheel.Bg
    
    -- Создаем 9 кнопок с хранением соединений
    EmoteWheel.Buttons = {}
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
        btn.Parent = EmoteWheel.Bg

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

        table.insert(EmoteWheel.Buttons, {button = btn, text = txt, connection = nil})
    end
    
    -- Центральная кнопка «стоп»
    EmoteWheel.CenterBtn = Instance.new("TextButton")
    EmoteWheel.CenterBtn.Size = UDim2.new(0, 300, 0, 300)
    EmoteWheel.CenterBtn.Position = UDim2.new(0.5, -150, 0.5, -150)
    EmoteWheel.CenterBtn.BackgroundTransparency = 1
    EmoteWheel.CenterBtn.Text = ""
    EmoteWheel.CenterBtn.Visible = false
    EmoteWheel.CenterBtn.Parent = EmoteWheel.Bg
    
    EmoteWheel.CenterBtn.MouseButton1Click:Connect(function()
        EmoteWheel.Bg.Visible = false
        EmoteWheel.PageText.Visible = false
        EmoteWheel.CenterBtn.Visible = false
        UserInputService.MouseBehavior = EmoteWheel.PreviousMouseBehavior
        UserInputService.MouseIconEnabled = EmoteWheel.PreviousMouseIconEnabled
        
        if EmoteWheel.LastTrack then
            EmoteWheel.LastTrack:Stop()
            EmoteWheel.LastTrack = nil
        end
    end)
end

local function stopEmote()
    if EmoteWheel.LastTrack then
        EmoteWheel.LastTrack:Stop()
        EmoteWheel.LastTrack = nil
    end
end

local function playEmote(id)
    stopEmote()
    local hum = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
    if not hum then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. id
    EmoteWheel.LastTrack = hum:LoadAnimation(anim)
    EmoteWheel.LastTrack.Priority = Enum.AnimationPriority.Action4
    EmoteWheel.LastTrack:Play()
end

local function updateEmotePage()
    local pageData = EmoteWheel.Pages[EmoteWheel.CurrentPage]
    if not pageData then return end

    for i = 1, 9 do
        local btnData = EmoteWheel.Buttons[i]
        local emoteData = pageData[i]
        
        if emoteData then
            btnData.button.Visible = true
            btnData.text.Text = emoteData.name:gsub("([A-Z])", " %1"):sub(2):gsub(" ", "\n")
            
            if btnData.connection then
                btnData.connection:Disconnect()
                btnData.connection = nil
            end
            
            btnData.connection = btnData.button.MouseButton1Click:Connect(function()
                EmoteWheel.Bg.Visible = false
                EmoteWheel.PageText.Visible = false
                EmoteWheel.CenterBtn.Visible = false
                UserInputService.MouseBehavior = EmoteWheel.PreviousMouseBehavior
                UserInputService.MouseIconEnabled = EmoteWheel.PreviousMouseIconEnabled
                playEmote(emoteData.id)
            end)
        else
            btnData.button.Visible = false
            if btnData.connection then
                btnData.connection:Disconnect()
                btnData.connection = nil
            end
        end
    end
    
    EmoteWheel.PageText.Text = EmoteWheel.CurrentPage .. "/" .. #EmoteWheel.Pages
end

local function openEmoteMenu()
    if not EmoteWheel.ScreenGui then return end
    
    EmoteWheel.Bg.Visible = true
    EmoteWheel.PageText.Visible = true
    EmoteWheel.CenterBtn.Visible = true
    
    EmoteWheel.PreviousMouseBehavior = UserInputService.MouseBehavior
    EmoteWheel.PreviousMouseIconEnabled = UserInputService.MouseIconEnabled
    
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
    
    updateEmotePage()
end

local function closeEmoteMenu()
    if not EmoteWheel.ScreenGui then return end
    
    EmoteWheel.Bg.Visible = false
    EmoteWheel.PageText.Visible = false
    EmoteWheel.CenterBtn.Visible = false
    
    UserInputService.MouseBehavior = EmoteWheel.PreviousMouseBehavior
    UserInputService.MouseIconEnabled = EmoteWheel.PreviousMouseIconEnabled
end

local function toggleEmoteMenu()
    if EmoteWheel.Bg and EmoteWheel.Bg.Visible then
        closeEmoteMenu()
    else
        openEmoteMenu()
    end
end

local function handleWheelScroll(input)
    if not EmoteWheel.Bg or not EmoteWheel.Bg.Visible then return end
    if input.Position.Z > 0 then
        if EmoteWheel.CurrentPage > 1 then
            EmoteWheel.CurrentPage = EmoteWheel.CurrentPage - 1
            updateEmotePage()
        end
    elseif input.Position.Z < 0 then
        if EmoteWheel.CurrentPage < #EmoteWheel.Pages then
            EmoteWheel.CurrentPage = EmoteWheel.CurrentPage + 1
            updateEmotePage()
        end
    end
end

--// Constructing the UI Content

-- Create Tabs (только Visuals и Movement)
CreateTabButton("Visuals", "")
CreateTabButton("Movement", "")

-- 1. VISUALS TAB
local V_Left, V_Right = CreatePage("Visuals")

-- Левая колонка: ESP
local Esp = AddPanel(V_Left, "ESP")

-- Главный переключатель ESP
AddToggle(Esp, "Enabled", false, function(state)
    ESP.Enabled = state
    updateESP()
end)

-- Все остальные переключатели ESP
AddToggle(Esp, "Chests", false, function(state)
    ESP.ObjectSettings["Chests"].enabled = state
    if ESP.Enabled then
        updateESP()
    end
end)

AddToggle(Esp, "Generators", false, function(state)
    ESP.ObjectSettings["Generators"].enabled = state
    if ESP.Enabled then
        updateESP()
    end
end)

AddToggle(Esp, "Hatch", false, function(state)
    ESP.ObjectSettings["Hatch"].enabled = state
    if ESP.Enabled then
        updateESP()
    end
end)

AddToggle(Esp, "Lockers", false, function(state)
    ESP.ObjectSettings["Lockers"].enabled = state
    if ESP.Enabled then
        updateESP()
    end
end)

AddToggle(Esp, "Hooks", false, function(state)
    ESP.ObjectSettings["Hooks"].enabled = state
    if ESP.Enabled then
        updateESP()
    end
end)

AddToggle(Esp, "Killer", false, function(state)
    ESP.ObjectSettings["Killer"].enabled = state
    if ESP.Enabled then
        updateESP()
    end
end)

AddToggle(Esp, "Survivors", false, function(state)
    ESP.ObjectSettings["Survivors"].enabled = state
    if ESP.Enabled then
        updateESP()
    end
end)

AddToggle(Esp, "Pallets", false, function(state)
    ESP.ObjectSettings["Pallets"].enabled = state
    if ESP.Enabled then
        updateESP()
    end
end)

AddToggle(Esp, "Exits", false, function(state)
    ESP.ObjectSettings["Exits"].enabled = state
    if ESP.Enabled then
        updateESP()
    end
end)

AddToggle(Esp, "Windows", false, function(state)
    ESP.ObjectSettings["Windows"].enabled = state
    if ESP.Enabled then
        updateESP()
    end
end)

AddToggle(Esp, "Totems", false, function(state)
    ESP.ObjectSettings["Totems"].enabled = state
    if ESP.Enabled then
        updateESP()
    end
end)

-- Правая колонка: Camera
local Camera = AddPanel(V_Right, "Camera")

-- Включение FOV
AddToggle(Camera, "Enable FOV", false, function(state)
    CameraSettings.EnableFOV = state
    applyFOV()
end)

-- Слайдер FOV с отображением значения (максимум 120)
AddSlider(Camera, "FOV", 60, 120, 90, true, function(value)
    CameraSettings.FOV = value
    if CameraSettings.EnableFOV then
        applyFOV()
    end
end, 0)

-- Включение Aspect Ratio
AddToggle(Camera, "Enable Aspect Ratio", false, function(state)
    CameraSettings.EnableAspectRatio = state
    
    if state then
        setupAspectRatioLoop()
    else
        if aspectRatioConnection then
            aspectRatioConnection:Disconnect()
            aspectRatioConnection = nil
        end
    end
end)

-- Слайдер Aspect Ratio с отображением значения (максимум 1.15)
AddSlider(Camera, "Aspect Ratio", 0.05, 1.15, 1, true, function(value)
    CameraSettings.AspectRatio = value
    if CameraSettings.EnableAspectRatio then
        setupAspectRatioLoop()
    end
end, 2)

-- Добавляем панель Other под Camera
local Other = AddPanel(V_Right, "Other")

-- Watermark переключатель
AddToggle(Other, "Watermark", false, function(state)
    if state then
        enableWatermark()
    else
        disableWatermark()
    end
end)

-- Bind List переключатель
AddToggle(Other, "Bind List", false, function(state)
    if state then
        enableBindList()
    else
        disableBindList()
    end
end)

-- 2. MOVEMENT TAB
local M_Left, M_Right = CreatePage("Movement")

-- Отключить скроллбар для этой страницы
local movementPage = Pages["Movement"]
if movementPage then
    local scrollFrame = movementPage:FindFirstChildOfClass("ScrollingFrame")
    if scrollFrame then
        scrollFrame.ScrollBarThickness = 0
        scrollFrame.ScrollingEnabled = false
    end
end

local MainPanel = AddPanel(M_Left, "Main")

-- Noclip переключатель
AddToggle(MainPanel, "Noclip", false, function(state)
    if state then
        enableNoclip()
    else
        disableNoclip()
    end
    updateBindListVisuals()
    UpdateBindList()
end)

-- Hotkey для Noclip
AddKey(MainPanel, "Hotkey", "-", function(key)
    Noclip.Hotkey = key
    UpdateBindList()
    updateBindListVisuals()
end)

-- Dash переключатель
AddToggle(MainPanel, "Dash", false, function(state)
    Dash.Enabled = state
    updateBindListVisuals()
    UpdateBindList()
end)

-- Hotkey для Dash
AddKey(MainPanel, "Hotkey", "-", function(key)
    Dash.Hotkey = key
    UpdateBindList()
    updateBindListVisuals()
end)

-- VaultSpeed переключатель
AddToggle(MainPanel, "VaultSpeed", false, function(state)
    VaultSpeed.Enabled = state
    if state then
        setVaultSpeed()
    end
end)

-- Слайдер для VaultSpeed (0.1 - 2.0)
AddSlider(MainPanel, "Amount", 0.1, 2.0, 0.2, true, function(value)
    VaultSpeed.SpeedValue = value
    if VaultSpeed.Enabled then
        setVaultSpeed()
    end
end, 1)

-- Добавляем категорию Other под Main
local OtherMovementPanel = AddPanel(M_Left, "Other")

-- Stun Killer переключатель
AddToggle(OtherMovementPanel, "Stun Killer", false, function(state)
    StunKiller.Enabled = state
    updateBindListVisuals()
    UpdateBindList()
end)

-- Hotkey для Stun Killer
AddKey(OtherMovementPanel, "Hotkey", "-", function(key)
    StunKiller.Hotkey = key
    UpdateBindList()
    updateBindListVisuals()
end)

-- No Anims Freeze переключатель
AddToggle(OtherMovementPanel, "No Anims Freeze", false, function(state)
    NoAnimsFreeze.Enabled = state
    if state then
        enableMovement()
    else
        disableMovement()
    end
    updateBindListVisuals()
    UpdateBindList()
end)

-- Hotkey для No Anims Freeze
AddKey(OtherMovementPanel, "Hotkey", "-", function(key)
    NoAnimsFreeze.Hotkey = key
    UpdateBindList()
    updateBindListVisuals()
end)

-- Добавляем категорию Misc в ПРАВУЮ колонку
local MiscMovementPanel = AddPanel(M_Right, "Misc")

-- Old Anims переключатель (однократное включение)
AddOldAnimsToggle(MiscMovementPanel)

-- Emote Wheel переключатель
AddToggle(MiscMovementPanel, "Emote Wheel", false, function(state)
    EmoteWheel.Enabled = state
    if state then
        if not EmoteWheel.ScreenGui then
            initializeEmoteWheelUI()
        end
        EmoteWheel.ScreenGui.Enabled = true
    else
        if EmoteWheel.ScreenGui then
            EmoteWheel.ScreenGui.Enabled = false
        end
    end
    updateBindListVisuals()
    UpdateBindList()
end)

-- Текст под переключателем
AddLabel(MiscMovementPanel, "* Enable before Match starts.")

-- Initialize - открываем вкладку Visuals при инжекте
SwitchTab("Visuals")

-- Profile Avatar Logic
task.spawn(function()
    repeat task.wait() until LocalPlayer and LocalPlayer.DisplayName ~= nil
    
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    
    local success, content = pcall(function()
        return Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    end)
    
    if not success then
        content = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    end
    
    local displayName = LocalPlayer.DisplayName
    if displayName == "" or displayName == nil then
        displayName = LocalPlayer.Name
    end    

    local ProfileFrame = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Input,
        Size = UDim2.new(0, 160, 0, 50),
        Position = UDim2.new(0, 10, 1, -70),
        ZIndex = 10
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("ImageLabel", {
            Name = "AvatarImage",
            BackgroundColor3 = Theme.Divider,
            BackgroundTransparency = 0,
            Image = content,
            Position = UDim2.new(0, 5, 0, 5),
            Size = UDim2.fromOffset(40, 40),
            ZIndex = 11
        }, { 
            Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Create("UIStroke", {
                Color = Theme.Accent,
                Thickness = 1
            })
        }),
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 55, 0, 5),
            Size = UDim2.new(0, 95, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = displayName,
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 11
        }),
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 55, 0, 25),
            Size = UDim2.new(0, 95, 0, 20),
            Font = Enum.Font.Gotham,
            Text = "Member",
            TextColor3 = Theme.SubText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11
        })
    })
    
    LocalPlayer:GetPropertyChangedSignal("DisplayName"):Connect(function()
        if ProfileFrame and ProfileFrame:FindFirstChild("AvatarImage") then
            local newContent = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
            ProfileFrame.AvatarImage.Image = newContent
        end
    end)
end)

--// Toggle Menu Logic
local IsVisible = true
local ToggleDebounce = false -- Чтобы нельзя было спамить кнопку

UserInputService.InputBegan:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.RightShift and not ToggleDebounce then
		ToggleDebounce = true
		IsVisible = not IsVisible
		
		if IsVisible then
			-- ОТКРЫТИЕ (Fade In)
			Main.Visible = true
			-- Сначала ставим полную прозрачность, если вдруг она не такая
			-- Main.GroupTransparency = 1 
			
			local tween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				GroupTransparency = 0 -- Становится видимым
			})
			tween:Play()
			tween.Completed:Wait()
		else
			-- ЗАКРЫТИЕ (Fade Out)
			local tween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				GroupTransparency = 1 -- Становится прозрачным
			})
			tween:Play()
			tween.Completed:Wait()
			Main.Visible = false -- Полностью выключаем после анимации
		end
		
		ToggleDebounce = false
	end
end)
--// Hotkey System для всех функций
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Проверка горячей клавиши для Noclip
    if isHotkeyMatch(input, Noclip.Hotkey) then
        toggleNoclip()
        updateBindListVisuals()
        UpdateBindList()
    end
    
    -- Проверка горячей клавиши для Dash
    if isHotkeyMatch(input, Dash.Hotkey) then
        performDash()
        updateBindListVisuals()
        UpdateBindList()
    end
    
    -- Проверка горячей клавиши для StunKiller
    if isHotkeyMatch(input, StunKiller.Hotkey) then
        stunKiller()
        updateBindListVisuals()
        UpdateBindList()
    end
    
    -- Проверка горячей клавиши для NoAnimsFreeze
    if isHotkeyMatch(input, NoAnimsFreeze.Hotkey) then
        toggleNoAnimsFreeze()
        updateBindListVisuals()
        UpdateBindList()
    end
    
    -- Проверка горячей клавиши для Emote Wheel
    if isHotkeyMatch(input, EmoteWheel.Hotkey) and EmoteWheel.Enabled then
        toggleEmoteMenu()
    end
end)

--// Wheel scroll for Emote Wheel
UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        handleWheelScroll(input)
    end
end)

if EmoteWheel.Bg then
    EmoteWheel.Bg.InputChanged:Connect(handleWheelScroll)
end

--// Death/Respawn Detection
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    wait(1)
    
    if CameraSettings.EnableFOV then
        applyFOV()
    end
    
    if Noclip.Enabled then
        disableNoclip()
        updateBindListVisuals()
        UpdateBindList()
    end
    
    Dash.dashCooldown = false
    
    -- Обновляем ссылки для NoAnimsFreeze
    updateCharacterReferences()
    
    -- Если NoAnimsFreeze был включен, применяем его к новому персонажу
    if NoAnimsFreeze.Enabled and movementEnabled then
        task.wait(0.5)
        enableMovement()
        updateBindListVisuals()
        UpdateBindList()
    end
end)

--// Инициализация NoAnimsFreeze при старте
if LocalPlayer.Character then
    updateCharacterReferences()
end

--// Intro
Main.Size = UDim2.new(0, 750, 0, 0)
TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(750, 550)}):Play()

--// FOV Protection Loop
RunService.RenderStepped:Connect(function()
    if CameraSettings.EnableFOV and workspace.CurrentCamera.FieldOfView ~= CameraSettings.FOV then
        workspace.CurrentCamera.FieldOfView = CameraSettings.FOV
    end
end)
