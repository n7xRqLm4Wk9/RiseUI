-- [[ LuxwareUI Library | Premium "Island" Framework (Fully Expanded Source) ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Luxware = {}
Luxware.__index = Luxware

-- // Premium Dark Mode Palette
local Theme = {
    Background = Color3.fromRGB(12, 12, 12),     -- Deepest dark for the outer shell
    Panel = Color3.fromRGB(18, 18, 18),          -- Elevated card background
    Surface = Color3.fromRGB(24, 24, 24),        -- Interactable elements
    SurfaceLight = Color3.fromRGB(32, 32, 32),   -- Hover states / accents
    Border = Color3.fromRGB(38, 38, 38),         -- Subtle, clean outlines
    Text = Color3.fromRGB(255, 255, 255),
    MutedText = Color3.fromRGB(160, 160, 160),
    SoftText = Color3.fromRGB(210, 210, 210),
    DimText = Color3.fromRGB(120, 120, 120),
    Accent = Color3.fromRGB(90, 145, 240),       -- Premium soft blue
    Success = Color3.fromRGB(60, 185, 95),
    Error = Color3.fromRGB(235, 75, 75),
    ToggleOn = Color3.fromRGB(90, 145, 240),
    ToggleOff = Color3.fromRGB(45, 45, 45),
}

local DEFAULT_KEY_PROMPT = "🔑 Enter Access Token"
local POINTER_DRAG_THRESHOLD = 8

-- // Premium Snappy Easing
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_DEFAULT = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_FADE = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- // Protection & Parent Setup
local parentTarget = nil
pcall(function()
    parentTarget = CoreGui
end)

if not parentTarget then 
    parentTarget = LocalPlayer:WaitForChild("PlayerGui") 
end

-- // Utility: Element Creation
local function CreateUIElement(className, properties)
    local el = Instance.new(className)
    for k, v in pairs(properties) do 
        el[k] = v 
    end
    return el
end

-- // Utility: Input Recognition
local function IsPointerDown(input) 
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch 
end

local function IsPointerMove(input) 
    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch 
end

local function IsPointerUp(input, pointerInput, pointerType)
    if not pointerType then 
        return false 
    end
    if pointerType == Enum.UserInputType.Touch then 
        return input == pointerInput 
    end
    return input.UserInputType == pointerType
end

local function PointerMoveMatches(input, pointerInput, pointerType)
    if not pointerType or not IsPointerMove(input) then 
        return false 
    end
    if pointerType == Enum.UserInputType.Touch then 
        return input == pointerInput 
    end
    return input.UserInputType == Enum.UserInputType.MouseMovement
end

local function PointerDeltaMagnitude(startPosition, currentPosition)
    local delta = currentPosition - startPosition
    return math.sqrt(delta.X * delta.X + delta.Y * delta.Y), delta
end

-- // Utility: Connections & Animations
local function TrackConnection(registerConnection, signal, callback)
    local connection = signal:Connect(callback)
    if registerConnection then 
        registerConnection(connection) 
    end
    return connection
end

local function PlayTween(object, tweenInfo, properties)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play() 
    return tween
end

local function RunCallback(callback, ...)
    if callback then 
        local status, err = pcall(callback, ...)
        if not status then 
            warn("[LuxwareUI Error]: " .. tostring(err)) 
        end
    end
end

-- // Utility: Styling
local function ClearCorners(parent)
    for _, child in ipairs(parent:GetChildren()) do 
        if child:IsA("UICorner") then 
            child:Destroy() 
        end 
    end
end

local function AddCorner(parent, radius)
    ClearCorners(parent)
    return CreateUIElement("UICorner", {
        Parent = parent, 
        CornerRadius = UDim.new(0, radius or 6)
    })
end

local function AddPillCorner(parent)
    ClearCorners(parent)
    return CreateUIElement("UICorner", {
        Parent = parent, 
        CornerRadius = UDim.new(1, 0)
    })
end

local function AddStroke(parent, color, thickness)
    return CreateUIElement("UIStroke", {
        Parent = parent, 
        Color = color or Theme.Border, 
        Thickness = thickness or 1
    })
end

-- // Utility: Standardized Components
local function CreateControlFrame(parent, height)
    local frame = CreateUIElement("Frame", {
        Parent = parent, 
        BackgroundColor3 = Theme.Surface, 
        Size = UDim2.new(1, 0, 0, height or 38)
    })
    AddCorner(frame, 6) 
    AddStroke(frame) 
    return frame
end

local function CreateControlButton(parent, height)
    local button = CreateUIElement("TextButton", {
        Parent = parent, 
        BackgroundColor3 = Theme.Surface, 
        Size = UDim2.new(1, 0, 0, height or 38), 
        Text = "", 
        AutoButtonColor = false
    })
    AddCorner(button, 6) 
    AddStroke(button) 
    return button
end

local function CreateControlLabel(parent, text, rightPadding)
    return CreateUIElement("TextLabel", {
        Parent = parent, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, -(rightPadding or 10), 1, 0), 
        Position = UDim2.new(0, 12, 0, 0),
        Font = Enum.Font.GothamMedium, 
        Text = text, 
        TextColor3 = Theme.SoftText, 
        TextSize = 13, 
        TextXAlignment = Enum.TextXAlignment.Left
    })
end

-- // Utility: Dragging Framework
local function MakeDraggable(dragObject, object, registerConnection)
    local pointerDown = false
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPosition = nil
    local dragInputType = nil

    if dragObject then dragObject.Active = true end
    if object then object.Active = true end

    local function update(input)
        if not pointerDown or not PointerMoveMatches(input, dragInput, dragInputType) then 
            return 
        end
        local distance, delta = PointerDeltaMagnitude(dragStart, input.Position)
        if not dragging then
            if distance < POINTER_DRAG_THRESHOLD then 
                return 
            end
            dragging = true
        end
        PlayTween(object, TWEEN_FAST, {
            Position = UDim2.new(
                startPosition.X.Scale, 
                startPosition.X.Offset + delta.X, 
                startPosition.Y.Scale, 
                startPosition.Y.Offset + delta.Y
            )
        })
    end

    TrackConnection(registerConnection, dragObject.InputBegan, function(input)
        if not IsPointerDown(input) then return end
        pointerDown = true
        dragging = false
        dragInput = input
        dragInputType = input.UserInputType
        dragStart = input.Position
        startPosition = object.Position
    end)

    TrackConnection(registerConnection, UserInputService.InputChanged, update)

    TrackConnection(registerConnection, UserInputService.InputEnded, function(input)
        if IsPointerUp(input, dragInput, dragInputType) then 
            pointerDown = false
            dragging = false
            dragInput = nil
            dragInputType = nil 
        end
    end)
end

-- // Utility: Hover & Click Feedbacks
local function AddButtonFeedback(button, registerConnection, baseColor, hoverColor, pressedColor)
    button.AutoButtonColor = false
    local defaultColor = baseColor or button.BackgroundColor3
    local overColor = hoverColor or Theme.SurfaceLight
    local downColor = pressedColor or Theme.Border
    local hovering = false

    TrackConnection(registerConnection, button.MouseEnter, function() 
        hovering = true 
        PlayTween(button, TWEEN_FAST, {BackgroundColor3 = overColor}) 
    end)

    TrackConnection(registerConnection, button.MouseLeave, function() 
        hovering = false 
        PlayTween(button, TWEEN_FAST, {BackgroundColor3 = defaultColor}) 
    end)

    TrackConnection(registerConnection, button.InputBegan, function(input) 
        if IsPointerDown(input) then 
            PlayTween(button, TWEEN_FAST, {BackgroundColor3 = downColor}) 
        end 
    end)

    TrackConnection(registerConnection, button.InputEnded, function(input) 
        if IsPointerDown(input) then 
            PlayTween(button, TWEEN_FAST, {BackgroundColor3 = hovering and overColor or defaultColor}) 
        end 
    end)
end

-- // ========================================== //
-- // Main Library Initializer
-- // ========================================== //

function Luxware:CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or "LuxwareUI"
    local UseKeySystem = options.KeySystem or false
    local ExpectedKey = options.Key or "LUXWARE-TEST"
    local GetKeyLink = options.KeyLink or "https://discord.gg/luxware"
    
    local connections = {}
    local destroyed = false

    local function registerConnection(conn) 
        table.insert(connections, conn) 
        return conn 
    end

    local LuxGUI = CreateUIElement("ScreenGui", {
        Name = "Luxware_" .. tostring(math.random(100,999)), 
        Parent = parentTarget, 
        ResetOnSpawn = false, 
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, 
        DisplayOrder = 999
    })
    
    local WindowAPI = {}

    function WindowAPI:Destroy()
        if destroyed then return end 
        destroyed = true
        
        for _, conn in ipairs(connections) do 
            if conn and conn.Connected then 
                conn:Disconnect() 
            end 
        end
        
        table.clear(connections)
        
        if LuxGUI then 
            LuxGUI:Destroy() 
        end
    end

    -- // Main UI Base (Island Design)
    local MainFrame = CreateUIElement("Frame", {
        Name = "MainFrame", 
        Parent = LuxGUI, 
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -250, 0.5, -175), 
        Size = UDim2.new(0, 520, 0, 360), 
        Visible = not UseKeySystem, 
        Active = true, 
        ZIndex = 1
    })
    AddCorner(MainFrame, 8) 
    AddStroke(MainFrame, Theme.Border, 1)

    -- // Top Drag Area
    local DragHandle = CreateUIElement("Frame", {
        Parent = MainFrame, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, -80, 0, 40), 
        Active = true, 
        ZIndex = 20
    })
    MakeDraggable(DragHandle, MainFrame, registerConnection)

    -- // Top Bar Frame
    local TopBar = CreateUIElement("Frame", {
        Parent = MainFrame, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, 0, 0, 40), 
        ZIndex = 10
    })
    
    CreateUIElement("TextLabel", {
        Parent = TopBar, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, -110, 1, 0), 
        Position = UDim2.new(0, 16, 0, 0), 
        Font = Enum.Font.GothamBold, 
        Text = WindowName, 
        TextColor3 = Theme.Text, 
        TextSize = 14, 
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- // Window Controls
    local MinimizeButton = CreateUIElement("TextButton", {
        Parent = TopBar, 
        BackgroundColor3 = Theme.Background, 
        Size = UDim2.new(0, 26, 0, 26), 
        Position = UDim2.new(1, -66, 0.5, -13), 
        Font = Enum.Font.GothamMedium, 
        Text = "−", 
        TextColor3 = Theme.DimText, 
        TextSize = 16
    })
    AddCorner(MinimizeButton, 6) 
    AddStroke(MinimizeButton) 
    AddButtonFeedback(MinimizeButton, registerConnection, Theme.Background, Theme.Surface, Theme.SurfaceLight)
    
    local CloseButton = CreateUIElement("TextButton", {
        Parent = TopBar, 
        BackgroundColor3 = Theme.Background, 
        Size = UDim2.new(0, 26, 0, 26), 
        Position = UDim2.new(1, -34, 0.5, -13), 
        Font = Enum.Font.GothamMedium, 
        Text = "✕", 
        TextColor3 = Theme.DimText, 
        TextSize = 12
    })
    AddCorner(CloseButton, 6) 
    AddStroke(CloseButton) 
    AddButtonFeedback(CloseButton, registerConnection, Theme.Background, Theme.Error, Color3.fromRGB(180, 50, 50))

    -- // Left Tab Container (Transparent)
    local LeftPanel = CreateUIElement("Frame", {
        Parent = MainFrame, 
        BackgroundTransparency = 1, 
        Position = UDim2.new(0, 0, 0, 40), 
        Size = UDim2.new(0, 140, 1, -40), 
        ZIndex = 2
    })
    
    local TabContainer = CreateUIElement("ScrollingFrame", {
        Parent = LeftPanel, 
        BackgroundTransparency = 1, 
        Position = UDim2.new(0, 12, 0, 0), 
        Size = UDim2.new(1, -24, 1, -16), 
        ScrollBarThickness = 0, 
        ZIndex = 3
    })
    
    CreateUIElement("UIListLayout", {
        Parent = TabContainer, 
        SortOrder = Enum.SortOrder.LayoutOrder, 
        Padding = UDim.new(0, 6)
    })

    -- // Right Content Island
    local RightPanel = CreateUIElement("Frame", {
        Parent = MainFrame, 
        BackgroundColor3 = Theme.Panel, 
        Position = UDim2.new(0, 140, 0, 40), 
        Size = UDim2.new(1, -152, 1, -52), 
        ZIndex = 2
    })
    AddCorner(RightPanel, 6) 
    AddStroke(RightPanel)

    -- // Open/Minimize Button
    local OpenButton = CreateUIElement("TextButton", {
        Name = "LuxOpen", 
        Parent = LuxGUI, 
        BackgroundColor3 = Theme.Background, 
        Position = UDim2.new(0, 20, 0.5, -20), 
        Size = UDim2.new(0, 40, 0, 40), 
        Visible = false, 
        Active = true, 
        ZIndex = 100, 
        Font = Enum.Font.GothamBold, 
        Text = "LW", 
        TextColor3 = Theme.Text, 
        TextSize = 14
    })
    AddCorner(OpenButton, 8) 
    AddStroke(OpenButton, Theme.Border) 
    MakeDraggable(OpenButton, OpenButton, registerConnection)

    -- // Visibility Control
    local WindowIsVisible = not UseKeySystem
    
    function WindowAPI:SetVisible(state)
        WindowIsVisible = state 
        MainFrame.Visible = state
        
        local keyFrameActive = UseKeySystem and LuxGUI:FindFirstChild("KeyFrame") and LuxGUI.KeyFrame.Visible
        OpenButton.Visible = not state and not keyFrameActive
    end

    TrackConnection(registerConnection, MinimizeButton.Activated, function() 
        WindowAPI:SetVisible(false) 
    end)

    TrackConnection(registerConnection, CloseButton.Activated, function() 
        WindowAPI:Destroy() 
    end)

    TrackConnection(registerConnection, OpenButton.Activated, function() 
        WindowAPI:SetVisible(true) 
    end)

    TrackConnection(registerConnection, UserInputService.InputBegan, function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then
            local keyFrameActive = UseKeySystem and LuxGUI:FindFirstChild("KeyFrame") and LuxGUI.KeyFrame.Visible
            if keyFrameActive then return end
            WindowAPI:SetVisible(not WindowIsVisible)
        end
    end)

    -- // Key System Handling
    if UseKeySystem then
        local KeyFrame = CreateUIElement("Frame", {
            Name = "KeyFrame", 
            Parent = LuxGUI, 
            BackgroundColor3 = Theme.Background, 
            Position = UDim2.new(0.5, -160, 0.5, -100), 
            Size = UDim2.new(0, 320, 0, 200), 
            Visible = true, 
            Active = true, 
            ZIndex = 10
        })
        AddCorner(KeyFrame, 8) 
        AddStroke(KeyFrame) 
        MakeDraggable(KeyFrame, KeyFrame, registerConnection)

        CreateUIElement("TextLabel", {
            Parent = KeyFrame, 
            BackgroundTransparency = 1, 
            Position = UDim2.new(0, 0, 0, 16), 
            Size = UDim2.new(1, 0, 0, 25), 
            Font = Enum.Font.GothamBold, 
            Text = "Authentication", 
            TextColor3 = Theme.Text, 
            TextSize = 15
        })

        local KeySub = CreateUIElement("TextLabel", {
            Parent = KeyFrame, 
            BackgroundTransparency = 1, 
            Position = UDim2.new(0, 0, 0, 40), 
            Size = UDim2.new(1, 0, 0, 20), 
            Font = Enum.Font.Gotham, 
            Text = DEFAULT_KEY_PROMPT, 
            TextColor3 = Theme.MutedText, 
            TextSize = 12
        })

        local KeyBox = CreateUIElement("TextBox", {
            Parent = KeyFrame, 
            BackgroundColor3 = Theme.Surface, 
            Position = UDim2.new(0, 24, 0, 75), 
            Size = UDim2.new(1, -48, 0, 42), 
            Font = Enum.Font.Gotham, 
            PlaceholderText = "Paste token here...", 
            Text = "", 
            TextColor3 = Theme.Text, 
            TextSize = 13
        })
        AddCorner(KeyBox, 6) 
        AddStroke(KeyBox)

        local CheckBtn = CreateUIElement("TextButton", {
            Parent = KeyFrame, 
            BackgroundColor3 = Theme.Accent, 
            Position = UDim2.new(0, 24, 0, 135), 
            Size = UDim2.new(0, 130, 0, 36), 
            Font = Enum.Font.GothamBold, 
            Text = "Verify", 
            TextColor3 = Color3.fromRGB(20,20,20), 
            TextSize = 13
        })
        AddCorner(CheckBtn, 6) 
        AddButtonFeedback(CheckBtn, registerConnection, Theme.Accent, Color3.fromRGB(110, 165, 255), Color3.fromRGB(70, 125, 220))

        local GetBtn = CreateUIElement("TextButton", {
            Parent = KeyFrame, 
            BackgroundColor3 = Theme.Surface, 
            Position = UDim2.new(1, -154, 0, 135), 
            Size = UDim2.new(0, 130, 0, 36), 
            Font = Enum.Font.GothamMedium, 
            Text = "Get Key", 
            TextColor3 = Theme.Text, 
            TextSize = 13
        })
        AddCorner(GetBtn, 6) 
        AddStroke(GetBtn) 
        AddButtonFeedback(GetBtn, registerConnection, Theme.Surface, Theme.SurfaceLight, Theme.Border)

        TrackConnection(registerConnection, CheckBtn.Activated, function()
            if KeyBox.Text == ExpectedKey then
                KeySub.Text = "Access Granted" 
                KeySub.TextColor3 = Theme.Success 
                task.wait(0.4)
                if not destroyed then 
                    KeyFrame.Visible = false 
                    WindowAPI:SetVisible(true) 
                end
            else
                KeySub.Text = "Invalid Token" 
                KeySub.TextColor3 = Theme.Error 
                task.wait(1.5)
                if not destroyed then 
                    KeySub.Text = DEFAULT_KEY_PROMPT 
                    KeySub.TextColor3 = Theme.MutedText 
                end
            end
        end)

        TrackConnection(registerConnection, GetBtn.Activated, function()
            pcall(function() setclipboard(GetKeyLink) end) 
            GetBtn.Text = "Copied!" 
            task.wait(1.5) 
            if not destroyed then 
                GetBtn.Text = "Get Key" 
            end
        end)
    end

    -- // Notifier System
    local NoteContainer = CreateUIElement("Frame", {
        Parent = LuxGUI, 
        BackgroundTransparency = 1, 
        Position = UDim2.new(1, -240, 1, -160), 
        Size = UDim2.new(0, 220, 0, 140)
    })
    
    CreateUIElement("UIListLayout", {
        Parent = NoteContainer, 
        SortOrder = Enum.SortOrder.LayoutOrder, 
        Padding = UDim.new(0, 8), 
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })

    function WindowAPI:Notify(data)
        data = data or {}
        
        local nFrame = CreateUIElement("Frame", {
            Parent = NoteContainer, 
            BackgroundColor3 = Theme.Surface, 
            Size = UDim2.new(1, 0, 0, 65), 
            BackgroundTransparency = 1
        })
        AddCorner(nFrame, 6) 
        AddStroke(nFrame)

        local nTitle = CreateUIElement("TextLabel", {
            Parent = nFrame, 
            BackgroundTransparency = 1, 
            Position = UDim2.new(0, 14, 0, 8), 
            Size = UDim2.new(1, -28, 0, 20), 
            Font = Enum.Font.GothamBold, 
            Text = data.Title or "Notification", 
            TextColor3 = Theme.Text, 
            TextSize = 13, 
            TextXAlignment = Enum.TextXAlignment.Left, 
            TextTransparency = 1
        })

        local nContent = CreateUIElement("TextLabel", {
            Parent = nFrame, 
            BackgroundTransparency = 1, 
            Position = UDim2.new(0, 14, 0, 28), 
            Size = UDim2.new(1, -28, 0, 28), 
            Font = Enum.Font.Gotham, 
            Text = data.Content or "", 
            TextColor3 = Theme.SoftText, 
            TextSize = 12, 
            TextXAlignment = Enum.TextXAlignment.Left, 
            TextWrapped = true, 
            TextTransparency = 1
        })
        
        PlayTween(nFrame, TWEEN_FADE, {BackgroundTransparency = 0}) 
        PlayTween(nTitle, TWEEN_FADE, {TextTransparency = 0}) 
        PlayTween(nContent, TWEEN_FADE, {TextTransparency = 0})
        
        task.delay(data.Duration or 3, function()
            if destroyed or not nFrame.Parent then return end
            
            PlayTween(nFrame, TWEEN_FADE, {BackgroundTransparency = 1}) 
            PlayTween(nTitle, TWEEN_FADE, {TextTransparency = 1}) 
            PlayTween(nContent, TWEEN_FADE, {TextTransparency = 1})
            
            task.wait(0.3) 
            
            if nFrame.Parent then 
                nFrame:Destroy() 
            end
        end)
    end

    -- // Tab Setup Layer
    local tabs = {}
    local firstTab = true

    function WindowAPI:CreateTab(tabName)
        local TabBtn = CreateUIElement("TextButton", {
            Parent = TabContainer, 
            BackgroundTransparency = 1, 
            Size = UDim2.new(1, 0, 0, 32), 
            Font = Enum.Font.GothamMedium, 
            Text = tabName, 
            TextColor3 = Theme.DimText, 
            TextSize = 13
        })

        local Page = CreateUIElement("ScrollingFrame", {
            Parent = RightPanel, 
            BackgroundTransparency = 1, 
            Position = UDim2.new(0, 12, 0, 12), 
            Size = UDim2.new(1, -24, 1, -24), 
            ScrollBarThickness = 2, 
            ScrollBarImageColor3 = Theme.Border, 
            Visible = firstTab
        })

        local PageLayout = CreateUIElement("UIListLayout", {
            Parent = Page, 
            SortOrder = Enum.SortOrder.LayoutOrder, 
            Padding = UDim.new(0, 8)
        })
        
        TrackConnection(registerConnection, PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() 
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 4) 
        end)

        if firstTab then 
            TabBtn.TextColor3 = Theme.Text 
            firstTab = false 
        end

        table.insert(tabs, {
            Btn = TabBtn, 
            Pg = Page
        })

        TrackConnection(registerConnection, TabBtn.Activated, function()
            for _, t in ipairs(tabs) do 
                t.Pg.Visible = false 
                PlayTween(t.Btn, TWEEN_FAST, {TextColor3 = Theme.DimText}) 
            end
            Page.Visible = true 
            PlayTween(TabBtn, TWEEN_FAST, {TextColor3 = Theme.Text})
        end)

        local TabElements = {}

        -- // Elements: Section
        function TabElements:CreateSection(name)
            CreateUIElement("TextLabel", {
                Parent = Page, 
                BackgroundTransparency = 1, 
                Size = UDim2.new(1, 0, 0, 24), 
                Font = Enum.Font.GothamBold, 
                Text = name, 
                TextColor3 = Theme.Accent, 
                TextSize = 12, 
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        -- // Elements: Label
        function TabElements:CreateLabel(text)
            local Lbl = CreateUIElement("TextLabel", {
                Parent = Page, 
                BackgroundColor3 = Theme.Surface, 
                Size = UDim2.new(1, -4, 0, 36), 
                Font = Enum.Font.GothamMedium, 
                Text = "  " .. text, 
                TextColor3 = Theme.SoftText, 
                TextSize = 13, 
                TextXAlignment = Enum.TextXAlignment.Left
            })
            AddCorner(Lbl, 6) 
            AddStroke(Lbl)
        end

        -- // Elements: Button
        function TabElements:CreateButton(opts)
            local Btn = CreateControlButton(Page, 38)
            CreateControlLabel(Btn, opts.Name or "Button")
            
            AddButtonFeedback(Btn, registerConnection, Theme.Surface, Theme.SurfaceLight, Theme.Border)
            
            TrackConnection(registerConnection, Btn.Activated, function() 
                RunCallback(opts.Callback) 
            end)
        end

        -- // Elements: Toggle
        function TabElements:CreateToggle(opts)
            local state = opts.CurrentValue or false
            
            local TglFrame = CreateControlButton(Page, 38)
            CreateControlLabel(TglFrame, opts.Name or "Toggle", 54)
            
            local TglBox = CreateUIElement("Frame", {
                Parent = TglFrame, 
                BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff, 
                Size = UDim2.new(0, 38, 0, 20), 
                Position = UDim2.new(1, -48, 0.5, -10)
            })
            AddPillCorner(TglBox)

            local TglCircle = CreateUIElement("Frame", {
                Parent = TglBox, 
                BackgroundColor3 = Theme.Text, 
                Size = UDim2.new(0, 14, 0, 14), 
                Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            })
            AddPillCorner(TglCircle)

            AddButtonFeedback(TglFrame, registerConnection, Theme.Surface, Theme.SurfaceLight, Theme.Border)
            
            TrackConnection(registerConnection, TglFrame.Activated, function()
                state = not state
                PlayTween(TglBox, TWEEN_FAST, {
                    BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
                })
                PlayTween(TglCircle, TWEEN_FAST, {
                    Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                })
                RunCallback(opts.Callback, state)
            end)
        end

        -- // Elements: Slider
        function TabElements:CreateSlider(opts)
            local range = opts.Range or {0, 100}
            local minV = tonumber(range[1]) or 0
            local maxV = tonumber(range[2]) or 100
            
            if maxV < minV then 
                minV, maxV = maxV, minV 
            end
            
            local inc = tonumber(opts.Increment) or 1
            local val = math.clamp(opts.CurrentValue or minV, minV, maxV)
            
            local SldFrame = CreateControlFrame(Page, 52)
            
            CreateUIElement("TextLabel", {
                Parent = SldFrame, 
                BackgroundTransparency = 1, 
                Size = UDim2.new(1, -10, 0, 24), 
                Position = UDim2.new(0, 12, 0, 2), 
                Font = Enum.Font.GothamMedium, 
                Text = opts.Name or "Slider", 
                TextColor3 = Theme.SoftText, 
                TextSize = 13, 
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValTxt = CreateUIElement("TextLabel", {
                Parent = SldFrame, 
                BackgroundTransparency = 1, 
                Size = UDim2.new(0, 50, 0, 24), 
                Position = UDim2.new(1, -62, 0, 2), 
                Font = Enum.Font.GothamMedium, 
                Text = tostring(val), 
                TextColor3 = Theme.DimText, 
                TextSize = 12, 
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local SldBG = CreateUIElement("TextButton", {
                Parent = SldFrame, 
                BackgroundColor3 = Theme.Background, 
                Size = UDim2.new(1, -24, 0, 6), 
                Position = UDim2.new(0, 12, 0, 34), 
                Text = "", 
                AutoButtonColor = false, 
                Active = true
            })
            AddPillCorner(SldBG) 
            AddStroke(SldBG)
            
            local SldFill = CreateUIElement("Frame", {
                Parent = SldBG, 
                BackgroundColor3 = Theme.Accent, 
                Size = UDim2.new(math.clamp((val - minV) / (maxV - minV), 0, 1), 0, 1, 0), 
                BorderSizePixel = 0
            })
            AddPillCorner(SldFill)

            local dragging = false
            local sliderInput = nil
            local sliderInputType = nil

            local function updateSlider(input)
                if SldBG.AbsoluteSize.X <= 0 then return end
                
                local pos = math.clamp((input.Position.X - SldBG.AbsolutePosition.X) / SldBG.AbsoluteSize.X, 0, 1)
                val = math.clamp(math.floor(((minV + (pos * (maxV - minV))) - minV) / inc + 0.5) * inc + minV, minV, maxV)
                
                PlayTween(SldFill, TWEEN_FAST, {
                    Size = UDim2.new(pos, 0, 1, 0)
                }) 
                
                ValTxt.Text = tostring(val)
                RunCallback(opts.Callback, val)
            end

            TrackConnection(registerConnection, SldBG.InputBegan, function(input) 
                if IsPointerDown(input) then 
                    dragging = true
                    sliderInput = input
                    sliderInputType = input.UserInputType 
                    updateSlider(input) 
                end 
            end)

            TrackConnection(registerConnection, UserInputService.InputEnded, function(input) 
                if IsPointerUp(input, sliderInput, sliderInputType) then 
                    dragging = false
                    sliderInput = nil
                    sliderInputType = nil 
                end 
            end)

            TrackConnection(registerConnection, UserInputService.InputChanged, function(input) 
                if dragging and PointerMoveMatches(input, sliderInput, sliderInputType) then 
                    updateSlider(input) 
                end 
            end)
        end

        -- // Elements: Dropdown
        function TabElements:CreateDropdown(opts)
            local list = opts.Options or {}
            local open = false

            local DpFrame = CreateControlFrame(Page, 38) 
            DpFrame.ClipsDescendants = true
            
            local DpBtn = CreateUIElement("TextButton", {
                Parent = DpFrame, 
                BackgroundTransparency = 1, 
                Size = UDim2.new(1, 0, 0, 38), 
                Text = ""
            })
            
            local Lbl = CreateControlLabel(DpBtn, opts.Name or "Dropdown", 40)
            
            local Ind = CreateUIElement("TextLabel", {
                Parent = DpBtn, 
                BackgroundTransparency = 1, 
                Position = UDim2.new(1, -30, 0, 0), 
                Size = UDim2.new(0, 20, 1, 0), 
                Font = Enum.Font.Gotham, 
                Text = "▼", 
                TextColor3 = Theme.DimText, 
                TextSize = 11
            })

            local OptsScroll = CreateUIElement("ScrollingFrame", {
                Parent = DpFrame, 
                BackgroundTransparency = 1, 
                Position = UDim2.new(0, 6, 0, 38), 
                Size = UDim2.new(1, -12, 0, math.min(#list * 28, 112)), 
                ScrollBarThickness = 2, 
                ScrollBarImageColor3 = Theme.SurfaceLight, 
                CanvasSize = UDim2.new(0, 0, 0, #list * 28)
            })
            
            CreateUIElement("UIListLayout", {
                Parent = OptsScroll, 
                Padding = UDim.new(0, 2)
            })

            local function toggleMenu()
                open = not open
                PlayTween(DpFrame, TWEEN_FAST, {
                    Size = open and UDim2.new(1, -4, 0, 44 + OptsScroll.Size.Y.Offset) or UDim2.new(1, -4, 0, 38)
                })
                Ind.Text = open and "▲" or "▼"
            end

            for _, choice in ipairs(list) do
                local cBtn = CreateUIElement("TextButton", {
                    Parent = OptsScroll, 
                    BackgroundColor3 = Theme.Background, 
                    Size = UDim2.new(1, -4, 0, 26), 
                    Font = Enum.Font.Gotham, 
                    Text = "   " .. tostring(choice), 
                    TextColor3 = Theme.SoftText, 
                    TextSize = 12, 
                    TextXAlignment = Enum.TextXAlignment.Left, 
                    AutoButtonColor = false
                })
                
                AddCorner(cBtn, 4) 
                AddButtonFeedback(cBtn, registerConnection, Theme.Background, Theme.Surface, Theme.SurfaceLight)
                
                TrackConnection(registerConnection, cBtn.Activated, function()
                    toggleMenu() 
                    Lbl.Text = (opts.Name or "Dropdown") .. " - " .. tostring(choice)
                    RunCallback(opts.Callback, choice)
                end)
            end
            
            TrackConnection(registerConnection, DpBtn.Activated, toggleMenu)
        end

        -- // Elements: TextBox
        function TabElements:CreateTextBox(opts)
            local BoxFrame = CreateControlFrame(Page, 38)
            CreateControlLabel(BoxFrame, opts.Name or "TextBox", 140)
            
            local Input = CreateUIElement("TextBox", {
                Parent = BoxFrame, 
                BackgroundColor3 = Theme.Background, 
                Size = UDim2.new(0, 120, 0, 26), 
                Position = UDim2.new(1, -130, 0.5, -13), 
                Font = Enum.Font.Gotham, 
                PlaceholderText = opts.Placeholder or "Type...", 
                Text = "", 
                TextColor3 = Theme.Text, 
                TextSize = 12, 
                ClearTextOnFocus = false
            })
            AddCorner(Input, 4) 
            AddStroke(Input)

            TrackConnection(registerConnection, Input.FocusLost, function(enterPressed)
                RunCallback(opts.Callback, Input.Text, enterPressed)
                if opts.Clear then 
                    Input.Text = "" 
                end
            end)
        end

        -- // Elements: Keybind
        function TabElements:CreateKeybind(opts)
            local currentKey = opts.CurrentKey or Enum.KeyCode.E
            
            local KbFrame = CreateControlFrame(Page, 38)
            CreateControlLabel(KbFrame, opts.Name or "Keybind", 100)
            
            local KbBtn = CreateUIElement("TextButton", {
                Parent = KbFrame, 
                BackgroundColor3 = Theme.Background, 
                Size = UDim2.new(0, 80, 0, 26), 
                Position = UDim2.new(1, -90, 0.5, -13), 
                Font = Enum.Font.GothamBold, 
                Text = currentKey.Name, 
                TextColor3 = Theme.SoftText, 
                TextSize = 12
            })
            AddCorner(KbBtn, 4) 
            AddStroke(KbBtn)

            local binding = false
            AddButtonFeedback(KbBtn, registerConnection, Theme.Background, Theme.Surface, Theme.Border)
            
            TrackConnection(registerConnection, KbBtn.Activated, function() 
                binding = true 
                KbBtn.Text = "..." 
            end)

            TrackConnection(registerConnection, UserInputService.InputBegan, function(input, gp)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode 
                    KbBtn.Text = currentKey.Name 
                    binding = false
                elseif not binding and not gp and input.KeyCode == currentKey then
                    RunCallback(opts.Callback)
                end
            end)
        end

        -- // Elements: ColorPicker
        function TabElements:CreateColorPicker(opts)
            local clr = opts.Color or Color3.fromRGB(255, 255, 255)
            
            local CpFrame = CreateControlFrame(Page, 42)
            CreateControlLabel(CpFrame, opts.Name or "Color Picker", 110)
            
            local function makeBox(xPos, initialVal)
                local box = CreateUIElement("TextBox", {
                    Parent = CpFrame, 
                    BackgroundColor3 = Theme.Background, 
                    Size = UDim2.new(0, 26, 0, 26), 
                    Position = UDim2.new(1, xPos, 0.5, -13), 
                    Font = Enum.Font.Gotham, 
                    Text = tostring(math.floor(initialVal * 255)), 
                    TextColor3 = Theme.Text, 
                    TextSize = 12, 
                    ClearTextOnFocus = false
                })
                AddCorner(box, 4) 
                AddStroke(box) 
                return box
            end

            local RBox = makeBox(-100, clr.R) 
            local GBox = makeBox(-68, clr.G) 
            local BBox = makeBox(-36, clr.B)

            local function updateColor()
                local r = tonumber(RBox.Text) or 255
                local g = tonumber(GBox.Text) or 255
                local b = tonumber(BBox.Text) or 255
                
                clr = Color3.fromRGB(
                    math.clamp(r, 0, 255), 
                    math.clamp(g, 0, 255), 
                    math.clamp(b, 0, 255)
                )
                
                RBox.Text = tostring(math.clamp(r, 0, 255)) 
                GBox.Text = tostring(math.clamp(g, 0, 255)) 
                BBox.Text = tostring(math.clamp(b, 0, 255))
                
                RunCallback(opts.Callback, clr)
            end

            TrackConnection(registerConnection, RBox.FocusLost, updateColor)
            TrackConnection(registerConnection, GBox.FocusLost, updateColor)
            TrackConnection(registerConnection, BBox.FocusLost, updateColor)
        end

        return TabElements
    end
    
    return WindowAPI
end

return Luxware
