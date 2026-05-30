-- [[ LuxwareUI Library | Rayfield-Level UI Framework ]] --
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local Luxware = {}
Luxware.__index = Luxware
Luxware.Flags = {}

local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Window = Color3.fromRGB(18, 18, 18),
    Panel = Color3.fromRGB(21, 21, 21),
    Surface = Color3.fromRGB(27, 27, 27),
    SurfaceLight = Color3.fromRGB(37, 37, 37),
    Elevated = Color3.fromRGB(44, 44, 44),
    Border = Color3.fromRGB(58, 58, 58),
    Text = Color3.fromRGB(255, 255, 255),
    SoftText = Color3.fromRGB(220, 220, 220),
    MutedText = Color3.fromRGB(170, 170, 170),
    DimText = Color3.fromRGB(120, 120, 120),
    Accent = Color3.fromRGB(238, 238, 238),
    AccentText = Color3.fromRGB(18, 18, 18),
    Error = Color3.fromRGB(185, 185, 185),
    Success = Color3.fromRGB(235, 235, 235),
}

local Radius = {
    Window = 14,
    Section = 12,
    Notification = 12,
    Button = 10,
    Input = 10,
    Dropdown = 10,
    ColorPicker = 10,
}

local DEFAULT_KEY_PROMPT = "🔑 Enter Key To Access The Script"
local POINTER_DRAG_THRESHOLD = 8
local TWEEN_FAST = TweenInfo.new(0.10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local TWEEN_MED = TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local TWEEN_SLOW = TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local TWEEN_SPRING = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local parentTarget = nil
pcall(function() parentTarget = CoreGui end)
if not parentTarget and LocalPlayer then parentTarget = LocalPlayer:WaitForChild("PlayerGui") end

local function CreateUIElement(className, properties)
    local el = Instance.new(className)
    for k, v in pairs(properties or {}) do el[k] = v end
    return el
end

local function TrackConnection(registerConnection, signal, callback)
    local connection = signal:Connect(callback)
    if registerConnection then registerConnection(connection) end
    return connection
end

local function PlayTween(object, tweenInfo, properties)
    if not object or not object.Parent then return nil end
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function RunCallback(callback, ...)
    if callback then task.spawn(callback, ...) end
end

local function ClampText(value)
    if value == nil then return "" end
    return tostring(value)
end

local function IsPointerDown(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function IsPointerMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function IsPointerUp(input, pointerInput, pointerType)
    if not pointerType then return false end
    if pointerType == Enum.UserInputType.Touch then return input == pointerInput end
    return input.UserInputType == pointerType
end

local function PointerMoveMatches(input, pointerInput, pointerType)
    if not pointerType or not IsPointerMove(input) then return false end
    if pointerType == Enum.UserInputType.Touch then return input == pointerInput end
    return input.UserInputType == Enum.UserInputType.MouseMovement
end

local function PointerDistanceAndDelta(startPosition, currentPosition)
    local delta = currentPosition - startPosition
    return math.sqrt(delta.X * delta.X + delta.Y * delta.Y), delta
end

local function ClearChildrenOfClass(parent, className)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA(className) then child:Destroy() end
    end
end

local function AddCorner(parent, radius)
    ClearChildrenOfClass(parent, "UICorner")
    return CreateUIElement("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius)})
end

local function AddPillCorner(parent)
    ClearChildrenOfClass(parent, "UICorner")
    return CreateUIElement("UICorner", {Parent = parent, CornerRadius = UDim.new(1, 0)})
end

local function AddStroke(parent, color, thickness, transparency)
    ClearChildrenOfClass(parent, "UIStroke")
    local stroke = CreateUIElement("UIStroke", {
        Parent = parent,
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    })
    pcall(function() stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
    return stroke
end

local function AddPadding(parent, left, right, top, bottom)
    ClearChildrenOfClass(parent, "UIPadding")
    return CreateUIElement("UIPadding", {
        Parent = parent,
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
    })
end

local function MakeRounded(parent, radius, strokeColor, strokeTransparency)
    parent.ClipsDescendants = true
    AddCorner(parent, radius)
    if strokeColor then AddStroke(parent, strokeColor, 1, strokeTransparency) end
    return parent
end

local function SetCanvasFromLayout(scroller, layout, extra)
    scroller.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (extra or 0))
end

local function ConnectActivated(button, registerConnection, callback)
    return TrackConnection(registerConnection, button.Activated, callback)
end

local function AddButtonFeedback(button, registerConnection, baseColor, hoverColor, pressedColor)
    button.AutoButtonColor = false
    local resting = baseColor or button.BackgroundColor3
    local hovering = false

    TrackConnection(registerConnection, button.MouseEnter, function()
        hovering = true
        PlayTween(button, TWEEN_FAST, {BackgroundColor3 = hoverColor or Theme.SurfaceLight})
    end)

    TrackConnection(registerConnection, button.MouseLeave, function()
        hovering = false
        PlayTween(button, TWEEN_FAST, {BackgroundColor3 = resting})
    end)

    TrackConnection(registerConnection, button.InputBegan, function(input)
        if IsPointerDown(input) then
            PlayTween(button, TWEEN_FAST, {BackgroundColor3 = pressedColor or Theme.Elevated})
        end
    end)

    TrackConnection(registerConnection, button.InputEnded, function(input)
        if IsPointerDown(input) then
            PlayTween(button, TWEEN_FAST, {BackgroundColor3 = hovering and (hoverColor or Theme.SurfaceLight) or resting})
        end
    end)
end

local function AddRipple(button, registerConnection)
    TrackConnection(registerConnection, button.InputBegan, function(input)
        if not IsPointerDown(input) then return end
        local ripple = CreateUIElement("Frame", {
            Parent = button,
            BackgroundColor3 = Theme.Text,
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, input.Position.X - button.AbsolutePosition.X, 0, input.Position.Y - button.AbsolutePosition.Y),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = (button.ZIndex or 1) + 2,
        })
        AddPillCorner(ripple)
        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        PlayTween(ripple, TWEEN_SLOW, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1})
        task.delay(0.24, function()
            if ripple.Parent then ripple:Destroy() end
        end)
    end)
end

local function CreateText(parent, text, size, weight, color, xAlign)
    return CreateUIElement("TextLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = weight or Enum.Font.Gotham,
        Text = text or "",
        TextColor3 = color or Theme.Text,
        TextSize = size or 13,
        TextXAlignment = xAlign or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local function MakeDraggable(dragObject, object, registerConnection)
    local pointerDown = false
    local dragging = false
    local dragInput = nil
    local dragInputType = nil
    local dragStart = nil
    local startPosition = nil

    dragObject.Active = true
    object.Active = true

    TrackConnection(registerConnection, dragObject.InputBegan, function(input)
        if not IsPointerDown(input) then return end
        pointerDown = true
        dragging = false
        dragInput = input
        dragInputType = input.UserInputType
        dragStart = input.Position
        startPosition = object.Position
    end)

    TrackConnection(registerConnection, UserInputService.InputChanged, function(input)
        if not pointerDown or not PointerMoveMatches(input, dragInput, dragInputType) then return end
        local distance, delta = PointerDistanceAndDelta(dragStart, input.Position)
        if not dragging then
            if distance < POINTER_DRAG_THRESHOLD then return end
            dragging = true
        end
        object.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end)

    TrackConnection(registerConnection, UserInputService.InputEnded, function(input)
        if IsPointerUp(input, dragInput, dragInputType) then
            pointerDown = false
            dragging = false
            dragInput = nil
            dragInputType = nil
        end
    end)
end

local function ColorToHex(color)
    local r = math.clamp(math.floor(color.R * 255 + 0.5), 0, 255)
    local g = math.clamp(math.floor(color.G * 255 + 0.5), 0, 255)
    local b = math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

local function ColorToRGBText(color)
    return string.format("%d, %d, %d", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end

local function ParseHex(text)
    local clean = tostring(text or ""):gsub("#", "")
    if #clean ~= 6 then return nil end
    local r = tonumber(clean:sub(1, 2), 16)
    local g = tonumber(clean:sub(3, 4), 16)
    local b = tonumber(clean:sub(5, 6), 16)
    if not r or not g or not b then return nil end
    return Color3.fromRGB(r, g, b)
end

local function ParseRGB(text)
    local values = {}
    for number in tostring(text or ""):gmatch("%d+") do
        table.insert(values, tonumber(number))
    end
    if #values < 3 then return nil end
    return Color3.fromRGB(math.clamp(values[1], 0, 255), math.clamp(values[2], 0, 255), math.clamp(values[3], 0, 255))
end

local function GetKeyCodeByName(name)
    for _, item in ipairs(Enum.KeyCode:GetEnumItems()) do
        if item.Name == tostring(name) then return item end
    end
    return nil
end

local function DeepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do copy[k] = DeepCopy(v) end
    return copy
end

local function SerializeConfig(config)
    local ok, encoded = pcall(function() return HttpService:JSONEncode(config) end)
    return ok and encoded or "{}"
end

function Luxware:SetTheme(themeOverrides)
    for key, value in pairs(themeOverrides or {}) do
        if Theme[key] ~= nil then Theme[key] = value end
    end
end

function Luxware:GetTheme()
    return DeepCopy(Theme)
end

function Luxware:CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or options.Title or "LuxwareUI"
    local UseKeySystem = options.KeySystem or false
    local ExpectedKey = options.Key or "LUXWARE-TEST"
    local GetKeyLink = options.KeyLink or "https://discord.gg/yourlink"
    local connections = {}
    local destroyed = false
    local tabs = {}
    local flags = {}
    local controlsByFlag = {}
    local notificationQueue = {}
    local activeNotifications = 0
    local maxNotifications = options.MaxNotifications or 4
    local selectedTab = nil
    local LuxGUI

    local Window = {}
    Window.Flags = flags

    local function registerConnection(connection)
        table.insert(connections, connection)
        return connection
    end

    local function isInterfaceAlive()
        return not destroyed and LuxGUI and LuxGUI.Parent ~= nil
    end

    local function registerFlag(flag, value)
        if flag then
            flags[flag] = value
            Luxware.Flags[flag] = value
        end
    end

    local function getFlag(flag)
        if not flag then return nil end
        return flags[flag]
    end

    local function bindFlag(flag, entry)
        if flag and entry then controlsByFlag[flag] = entry end
    end

    LuxGUI = CreateUIElement("ScreenGui", {
        Name = "LuxwareUI",
        Parent = parentTarget,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
        IgnoreGuiInset = false,
    })

    function Window:Destroy()
        if destroyed then return end
        destroyed = true
        for _, connection in ipairs(connections) do
            if connection and connection.Connected then connection:Disconnect() end
        end
        table.clear(connections)
        if LuxGUI then LuxGUI:Destroy() end
    end

    function Luxware:Destroy()
        Window:Destroy()
    end

    local KeyFrame = CreateUIElement("Frame", {
        Name = "KeyFrame",
        Parent = LuxGUI,
        BackgroundColor3 = Theme.Window,
        Position = UDim2.new(0.5, -190, 0.5, -135),
        Size = UDim2.new(0, 380, 0, 270),
        Visible = UseKeySystem,
        Active = true,
        ClipsDescendants = true,
        ZIndex = 60,
    })
    MakeRounded(KeyFrame, Radius.Window, Theme.Border)
    MakeDraggable(KeyFrame, KeyFrame, registerConnection)

    CreateText(KeyFrame, "Key System", 18, Enum.Font.GothamBold, Theme.Text, Enum.TextXAlignment.Center).Position = UDim2.new(0, 0, 0, 18)
    local CloseKey = CreateUIElement("TextButton", {
        Parent = KeyFrame,
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(1, -42, 0, 12),
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 18,
        AutoButtonColor = false,
        Active = true,
        ZIndex = 65,
    })
    MakeRounded(CloseKey, Radius.Button, Theme.Border)
    AddButtonFeedback(CloseKey, registerConnection, Theme.Surface, Theme.SurfaceLight, Theme.Elevated)
    ConnectActivated(CloseKey, registerConnection, function() Window:Destroy() end)

    local KeySub = CreateUIElement("TextLabel", {
        Parent = KeyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 56),
        Size = UDim2.new(1, -48, 0, 22),
        Font = Enum.Font.Gotham,
        Text = DEFAULT_KEY_PROMPT,
        TextColor3 = Theme.MutedText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local KeyBox = CreateUIElement("TextBox", {
        Parent = KeyFrame,
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(0, 30, 0, 104),
        Size = UDim2.new(1, -60, 0, 46),
        Font = Enum.Font.Gotham,
        PlaceholderText = "Enter key...",
        PlaceholderColor3 = Theme.DimText,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 14,
        ClearTextOnFocus = false,
    })
    MakeRounded(KeyBox, Radius.Input, Theme.Border)
    AddPadding(KeyBox, 12, 12)

    local GetKeyBtn = CreateUIElement("TextButton", {
        Parent = KeyFrame,
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(0, 30, 0, 174),
        Size = UDim2.new(0.5, -36, 0, 42),
        Font = Enum.Font.GothamMedium,
        Text = "Get Key",
        TextColor3 = Theme.Text,
        TextSize = 14,
        AutoButtonColor = false,
    })
    MakeRounded(GetKeyBtn, Radius.Button, Theme.Border)
    AddButtonFeedback(GetKeyBtn, registerConnection, Theme.Surface, Theme.SurfaceLight, Theme.Elevated)

    local CheckKeyBtn = CreateUIElement("TextButton", {
        Parent = KeyFrame,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0.5, 6, 0, 174),
        Size = UDim2.new(0.5, -36, 0, 42),
        Font = Enum.Font.GothamMedium,
        Text = "Check Key",
        TextColor3 = Theme.AccentText,
        TextSize = 14,
        AutoButtonColor = false,
    })
    MakeRounded(CheckKeyBtn, Radius.Button, Theme.Border)
    AddButtonFeedback(CheckKeyBtn, registerConnection, Theme.Accent, Theme.SoftText, Theme.Text)

    local MainFrame = CreateUIElement("Frame", {
        Name = "MainFrame",
        Parent = LuxGUI,
        BackgroundColor3 = Theme.Window,
        Position = UDim2.new(0.5, -330, 0.5, -235),
        Size = UDim2.new(0, options.Width or 660, 0, options.Height or 470),
        Visible = not UseKeySystem,
        Active = true,
        ClipsDescendants = true,
        ZIndex = 1,
    })
    MakeRounded(MainFrame, Radius.Window, Theme.Border)
    CreateUIElement("UISizeConstraint", {Parent = MainFrame, MinSize = Vector2.new(520, 360), MaxSize = Vector2.new(1000, 760)})

    local ResizeHandle = CreateUIElement("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(0, 26, 0, 26),
        Active = true,
        ZIndex = 40,
    })
    local resizeMark = CreateUIElement("TextLabel", {
        Parent = ResizeHandle,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 0, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = "⌟",
        TextColor3 = Theme.DimText,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        Active = false,
        ZIndex = 41,
    })
    local resizing = false
    local resizeInput = nil
    local resizeInputType = nil
    local resizeStart = nil
    local resizeStartSize = nil
    TrackConnection(registerConnection, ResizeHandle.InputBegan, function(input)
        if not IsPointerDown(input) then return end
        resizing = true
        resizeInput = input
        resizeInputType = input.UserInputType
        resizeStart = input.Position
        resizeStartSize = MainFrame.AbsoluteSize
        PlayTween(resizeMark, TWEEN_FAST, {TextColor3 = Theme.Text})
    end)
    TrackConnection(registerConnection, UserInputService.InputChanged, function(input)
        if not resizing or not PointerMoveMatches(input, resizeInput, resizeInputType) then return end
        local _, delta = PointerDistanceAndDelta(resizeStart, input.Position)
        MainFrame.Size = UDim2.new(0, math.clamp(resizeStartSize.X + delta.X, 520, 1000), 0, math.clamp(resizeStartSize.Y + delta.Y, 360, 760))
    end)
    TrackConnection(registerConnection, UserInputService.InputEnded, function(input)
        if IsPointerUp(input, resizeInput, resizeInputType) then
            resizing = false
            resizeInput = nil
            resizeInputType = nil
            PlayTween(resizeMark, TWEEN_FAST, {TextColor3 = Theme.DimText})
        end
    end)

    local TopBar = CreateUIElement("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Window,
        Size = UDim2.new(1, 0, 0, 54),
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 20,
    })
    TopBar.ClipsDescendants = true

    local DragHandle = CreateUIElement("Frame", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -124, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Active = true,
        ZIndex = 21,
    })
    MakeDraggable(DragHandle, MainFrame, registerConnection)

    local Title = CreateUIElement("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 22, 0, 0),
        Size = UDim2.new(1, -150, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = WindowName,
        TextColor3 = Theme.Text,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 22,
        Active = false,
    })

    local Controls = CreateUIElement("Frame", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.new(0, 76, 0, 34),
        ZIndex = 30,
    })
    local controlsLayout = CreateUIElement("UIListLayout", {Parent = Controls, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

    local MinimizeButton = CreateUIElement("TextButton", {
        Parent = Controls,
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(0, 34, 0, 34),
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = Theme.Text,
        TextSize = 18,
        AutoButtonColor = false,
        Active = true,
        ZIndex = 31,
        LayoutOrder = 1,
    })
    MakeRounded(MinimizeButton, Radius.Button, Theme.Border)
    AddButtonFeedback(MinimizeButton, registerConnection, Theme.Surface, Theme.SurfaceLight, Theme.Elevated)

    local CloseButton = CreateUIElement("TextButton", {
        Parent = Controls,
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(0, 34, 0, 34),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 18,
        AutoButtonColor = false,
        Active = true,
        ZIndex = 31,
        LayoutOrder = 2,
    })
    MakeRounded(CloseButton, Radius.Button, Theme.Border)
    AddButtonFeedback(CloseButton, registerConnection, Theme.Surface, Theme.SurfaceLight, Theme.Elevated)

    local Sidebar = CreateUIElement("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Panel,
        Position = UDim2.new(0, 12, 0, 66),
        Size = UDim2.new(0, 166, 1, -78),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    })
    MakeRounded(Sidebar, Radius.Section, Theme.Border)

    local SearchBox = CreateUIElement("TextBox", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 0, 36),
        Font = Enum.Font.Gotham,
        PlaceholderText = "Search controls...",
        PlaceholderColor3 = Theme.DimText,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 12,
        ClearTextOnFocus = false,
        ZIndex = 4,
    })
    MakeRounded(SearchBox, Radius.Input, Theme.Border)
    AddPadding(SearchBox, 10, 10)

    local TabContainer = CreateUIElement("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 56),
        Size = UDim2.new(1, -16, 1, -64),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    local tabLayout = CreateUIElement("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
    TrackConnection(registerConnection, tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() SetCanvasFromLayout(TabContainer, tabLayout, 8) end)

    local ContentPanel = CreateUIElement("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Panel,
        Position = UDim2.new(0, 190, 0, 66),
        Size = UDim2.new(1, -202, 1, -78),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    })
    MakeRounded(ContentPanel, Radius.Section, Theme.Border)

    local PageHolder = CreateUIElement("Frame", {
        Parent = ContentPanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 12),
        Size = UDim2.new(1, -24, 1, -24),
        ClipsDescendants = true,
        ZIndex = 3,
    })

    local OpenButton = CreateUIElement("TextButton", {
        Name = "LuxwareOpenButton",
        Parent = LuxGUI,
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(0, 24, 0.5, -26),
        Size = UDim2.new(0, 58, 0, 52),
        Visible = false,
        Active = true,
        ZIndex = 100,
        Font = Enum.Font.GothamBold,
        Text = "Open",
        TextColor3 = Theme.Text,
        TextSize = 13,
        AutoButtonColor = false,
    })
    MakeRounded(OpenButton, Radius.Button, Theme.Border)
    AddButtonFeedback(OpenButton, registerConnection, Theme.Surface, Theme.SurfaceLight, Theme.Elevated)

    local openPointerDown = false
    local openDragging = false
    local openWasDragged = false
    local openInput = nil
    local openInputType = nil
    local openStart = nil
    local openPosition = nil

    TrackConnection(registerConnection, OpenButton.InputBegan, function(input)
        if not IsPointerDown(input) then return end
        openPointerDown = true
        openDragging = false
        openWasDragged = false
        openInput = input
        openInputType = input.UserInputType
        openStart = input.Position
        openPosition = OpenButton.Position
    end)

    TrackConnection(registerConnection, UserInputService.InputChanged, function(input)
        if not openPointerDown or not PointerMoveMatches(input, openInput, openInputType) then return end
        local distance, delta = PointerDistanceAndDelta(openStart, input.Position)
        if not openDragging then
            if distance < POINTER_DRAG_THRESHOLD then return end
            openDragging = true
            openWasDragged = true
        end
        OpenButton.Position = UDim2.new(openPosition.X.Scale, openPosition.X.Offset + delta.X, openPosition.Y.Scale, openPosition.Y.Offset + delta.Y)
    end)

    TrackConnection(registerConnection, UserInputService.InputEnded, function(input)
        if IsPointerUp(input, openInput, openInputType) then
            openPointerDown = false
            openDragging = false
            openInput = nil
            openInputType = nil
        end
    end)

    local WindowIsVisible = not UseKeySystem
    function Window:SetVisible(state)
        WindowIsVisible = state
        MainFrame.Visible = state
        OpenButton.Visible = not state and not (UseKeySystem and KeyFrame.Visible)
    end
    function Luxware:SetVisible(state) Window:SetVisible(state) end

    ConnectActivated(MinimizeButton, registerConnection, function()
        if UseKeySystem and KeyFrame.Visible then return end
        Window:SetVisible(false)
    end)

    ConnectActivated(CloseButton, registerConnection, function() Window:Destroy() end)

    ConnectActivated(OpenButton, registerConnection, function()
        if openDragging then return end
        if openWasDragged then
            openWasDragged = false
            return
        end
        Window:SetVisible(true)
    end)

    TrackConnection(registerConnection, UserInputService.InputBegan, function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            if UseKeySystem and KeyFrame.Visible then return end
            Window:SetVisible(not WindowIsVisible)
        end
    end)

    AddButtonFeedback(GetKeyBtn, registerConnection, Theme.Surface, Theme.SurfaceLight, Theme.Elevated)
    AddButtonFeedback(CheckKeyBtn, registerConnection, Theme.Accent, Theme.SoftText, Theme.Text)

    ConnectActivated(GetKeyBtn, registerConnection, function()
        pcall(function() setclipboard(GetKeyLink) end)
        KeySub.Text = "Link copied to clipboard."
        task.delay(2, function()
            if isInterfaceAlive() then KeySub.Text = DEFAULT_KEY_PROMPT end
        end)
    end)

    ConnectActivated(CheckKeyBtn, registerConnection, function()
        if KeyBox.Text == ExpectedKey then
            KeySub.Text = "Key verified."
            KeySub.TextColor3 = Theme.Success
            task.delay(0.45, function()
                if isInterfaceAlive() then
                    KeyFrame.Visible = false
                    Window:SetVisible(true)
                end
            end)
        else
            KeySub.Text = "Invalid key."
            KeySub.TextColor3 = Theme.Error
            task.delay(1.4, function()
                if isInterfaceAlive() then
                    KeySub.Text = DEFAULT_KEY_PROMPT
                    KeySub.TextColor3 = Theme.MutedText
                end
            end)
        end
    end)

    local NoteContainer = CreateUIElement("Frame", {
        Parent = LuxGUI,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 300, 1, -40),
        ZIndex = 150,
    })
    local noteLayout = CreateUIElement("UIListLayout", {Parent = NoteContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom})

    local function processNotifications()
        if activeNotifications >= maxNotifications or #notificationQueue == 0 or not isInterfaceAlive() then return end
        activeNotifications = activeNotifications + 1
        local data = table.remove(notificationQueue, 1)
        local duration = data.Duration or 4
        local frame = CreateUIElement("Frame", {
            Parent = NoteContainer,
            BackgroundColor3 = Theme.Surface,
            Size = UDim2.new(1, 0, 0, 82),
            Position = UDim2.new(1, 28, 0, 0),
            BackgroundTransparency = 0,
            ClipsDescendants = true,
            ZIndex = 151,
        })
        MakeRounded(frame, Radius.Notification, Theme.Border)
        local title = CreateUIElement("TextLabel", {
            Parent = frame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 10),
            Size = UDim2.new(1, -28, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = data.Title or "Notification",
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 152,
        })
        local content = CreateUIElement("TextLabel", {
            Parent = frame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 32),
            Size = UDim2.new(1, -28, 0, 28),
            Font = Enum.Font.Gotham,
            Text = data.Content or "",
            TextColor3 = Theme.SoftText,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 152,
        })
        local progressBg = CreateUIElement("Frame", {Parent = frame, BackgroundColor3 = Theme.Border, Position = UDim2.new(0, 14, 1, -12), Size = UDim2.new(1, -28, 0, 4), BorderSizePixel = 0, ZIndex = 152})
        AddPillCorner(progressBg)
        local progress = CreateUIElement("Frame", {Parent = progressBg, BackgroundColor3 = Theme.Accent, Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 153})
        AddPillCorner(progress)
        frame.Position = UDim2.new(1, 28, 0, 0)
        PlayTween(frame, TWEEN_MED, {Position = UDim2.new(0, 0, 0, 0)})
        PlayTween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 1, 0)})
        task.delay(duration, function()
            if frame.Parent then
                PlayTween(frame, TWEEN_MED, {Position = UDim2.new(1, 28, 0, 0), BackgroundTransparency = 1})
                PlayTween(title, TWEEN_MED, {TextTransparency = 1})
                PlayTween(content, TWEEN_MED, {TextTransparency = 1})
                task.wait(0.18)
                if frame.Parent then frame:Destroy() end
            end
            activeNotifications = math.max(activeNotifications - 1, 0)
            processNotifications()
        end)
    end

    function Window:Notify(data)
        table.insert(notificationQueue, data or {})
        processNotifications()
    end
    function Luxware:Notify(data) Window:Notify(data) end

    local function filterControls(query)
        local q = string.lower(query or "")
        for _, tab in ipairs(tabs) do
            for _, control in ipairs(tab.Controls) do
                local match = q == "" or string.find(string.lower(control.SearchText or ""), q, 1, true) ~= nil
                if control.Frame then control.Frame.Visible = match end
            end
            SetCanvasFromLayout(tab.Page, tab.Layout, 18)
        end
    end
    TrackConnection(registerConnection, SearchBox:GetPropertyChangedSignal("Text"), function() filterControls(SearchBox.Text) end)

    local function selectTab(tab)
        if selectedTab == tab then return end
        selectedTab = tab
        for _, item in ipairs(tabs) do
            local active = item == tab
            item.PageGroup.Visible = true
            PlayTween(item.PageGroup, TWEEN_MED, {Position = active and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 16, 0, 0), GroupTransparency = active and 0 or 1})
            PlayTween(item.Button, TWEEN_MED, {BackgroundColor3 = active and Theme.SurfaceLight or Theme.Panel})
            PlayTween(item.Label, TWEEN_MED, {TextColor3 = active and Theme.Text or Theme.MutedText})
            PlayTween(item.Indicator, TWEEN_MED, {Size = active and UDim2.new(0, 3, 1, -14) or UDim2.new(0, 3, 0, 0), BackgroundTransparency = active and 0 or 1})
            if not active then
                task.delay(0.18, function()
                    if selectedTab ~= item and item.PageGroup then item.PageGroup.Visible = false end
                end)
            end
        end
    end

    local function createBaseControl(tab, titleText, height, rightPadding)
        local holder = CreateUIElement("Frame", {
            Parent = tab.Page,
            BackgroundColor3 = Theme.Surface,
            Size = UDim2.new(1, 0, 0, height or 46),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ZIndex = 5,
        })
        MakeRounded(holder, Radius.Button, Theme.Border)
        local titleLabel = CreateUIElement("TextLabel", {
            Parent = holder,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -(rightPadding or 24), 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = titleText or "Control",
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
        })
        local entry = {Frame = holder, Label = titleLabel, SearchText = titleText or ""}
        table.insert(tab.Controls, entry)
        return holder, titleLabel, entry
    end

    function Window:CreateTab(tabName, icon)
        local tab = {Name = tabName or "Tab", Icon = icon, Controls = {}}
        local tabButton = CreateUIElement("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Theme.Panel,
            Size = UDim2.new(1, 0, 0, 42),
            Font = Enum.Font.GothamMedium,
            Text = "",
            AutoButtonColor = false,
            Active = true,
            ClipsDescendants = true,
            ZIndex = 4,
        })
        MakeRounded(tabButton, Radius.Button, nil)
        AddButtonFeedback(tabButton, registerConnection, Theme.Panel, Theme.Surface, Theme.SurfaceLight)
        local indicator = CreateUIElement("Frame", {Parent = tabButton, BackgroundColor3 = Theme.Accent, Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 3, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 6})
        AddPillCorner(indicator)
        local tabText = CreateUIElement("TextLabel", {
            Parent = tabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = icon and (tostring(icon) .. "  " .. tab.Name) or tab.Name,
            TextColor3 = Theme.MutedText,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
        })
        local page = CreateUIElement("CanvasGroup", {
            Parent = PageHolder,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 16, 0, 0),
            Visible = false,
            GroupTransparency = 1,
            ClipsDescendants = true,
            ZIndex = 4,
        })
        local scroller = CreateUIElement("ScrollingFrame", {
            Parent = page,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Border,
            BorderSizePixel = 0,
            ZIndex = 4,
        })
        local layout = CreateUIElement("UIListLayout", {Parent = scroller, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        CreateUIElement("UIPadding", {Parent = scroller, PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 16)})
        TrackConnection(registerConnection, layout:GetPropertyChangedSignal("AbsoluteContentSize"), function() SetCanvasFromLayout(scroller, layout, 22) end)

        tab.Button = tabButton
        tab.Label = tabText
        tab.Indicator = indicator
        tab.PageGroup = page
        tab.Page = scroller
        tab.Layout = layout
        table.insert(tabs, tab)

        ConnectActivated(tabButton, registerConnection, function() selectTab(tab) end)
        if #tabs == 1 then selectTab(tab) end

        local TabElements = {}

        function TabElements:CreateSection(name)
            local section = CreateUIElement("Frame", {Parent = scroller, BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, 0, 0, 36), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 5})
            MakeRounded(section, Radius.Section, Theme.Border)
            local label = CreateUIElement("TextLabel", {Parent = section, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -28, 1, 0), Font = Enum.Font.GothamBold, Text = name or "Section", TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6})
            local entry = {Frame = section, Label = label, SearchText = name or ""}
            table.insert(tab.Controls, entry)
            function entry:Set(newName)
                label.Text = ClampText(newName)
                entry.SearchText = label.Text
            end
            return entry
        end

        function TabElements:CreateDivider()
            local divider = CreateUIElement("Frame", {Parent = scroller, BackgroundColor3 = Theme.Border, Size = UDim2.new(1, 0, 0, 1), BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 5})
            local entry = {Frame = divider, SearchText = "divider"}
            table.insert(tab.Controls, entry)
            return entry
        end

        function TabElements:CreateLabel(text)
            local holder, label, entry = createBaseControl(tab, text or "Label", 42, 24)
            label.Font = Enum.Font.Gotham
            label.TextColor3 = Theme.SoftText
            function entry:Set(newText)
                label.Text = ClampText(newText)
                entry.SearchText = label.Text
            end
            return entry
        end

        function TabElements:CreateParagraph(opts)
            opts = opts or {}
            local holder = CreateUIElement("Frame", {Parent = scroller, BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, 0, 0, 92), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 5})
            MakeRounded(holder, Radius.Section, Theme.Border)
            local titleLabel = CreateUIElement("TextLabel", {Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 10), Size = UDim2.new(1, -28, 0, 20), Font = Enum.Font.GothamBold, Text = opts.Title or opts.Name or "Paragraph", TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6})
            local body = CreateUIElement("TextLabel", {Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 34), Size = UDim2.new(1, -28, 1, -44), Font = Enum.Font.Gotham, Text = opts.Content or opts.Text or "", TextColor3 = Theme.SoftText, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 6})
            local entry = {Frame = holder, Title = titleLabel, Content = body, SearchText = (opts.Title or "") .. " " .. (opts.Content or opts.Text or "")}
            table.insert(tab.Controls, entry)
            function entry:Set(newTitle, newContent)
                if newContent == nil then
                    body.Text = ClampText(newTitle)
                else
                    titleLabel.Text = ClampText(newTitle)
                    body.Text = ClampText(newContent)
                end
                entry.SearchText = titleLabel.Text .. " " .. body.Text
            end
            return entry
        end

        function TabElements:CreateButton(opts)
            opts = opts or {}
            local button = CreateUIElement("TextButton", {Parent = scroller, BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, 0, 0, 46), Font = Enum.Font.GothamMedium, Text = opts.Name or "Button", TextColor3 = Theme.Text, TextSize = 13, AutoButtonColor = false, ClipsDescendants = true, Active = true, ZIndex = 5})
            MakeRounded(button, Radius.Button, Theme.Border)
            AddButtonFeedback(button, registerConnection, Theme.Surface, Theme.SurfaceLight, Theme.Elevated)
            AddRipple(button, registerConnection)
            ConnectActivated(button, registerConnection, function() RunCallback(opts.Callback) end)
            local entry = {Frame = button, SearchText = opts.Name or "Button"}
            table.insert(tab.Controls, entry)
            function entry:Set(newName) button.Text = ClampText(newName); entry.SearchText = button.Text end
            return entry
        end

        function TabElements:CreateToggle(opts)
            opts = opts or {}
            local state = opts.CurrentValue or opts.Default or false
            local holder, label, entry = createBaseControl(tab, opts.Name or "Toggle", 50, 84)
            holder.Active = true
            local track = CreateUIElement("Frame", {Parent = holder, BackgroundColor3 = state and Theme.Accent or Theme.Elevated, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.new(0, 48, 0, 26), BorderSizePixel = 0, ZIndex = 7})
            AddPillCorner(track)
            AddStroke(track, Theme.Border)
            local thumb = CreateUIElement("Frame", {Parent = track, BackgroundColor3 = state and Theme.AccentText or Theme.Text, Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), BorderSizePixel = 0, ZIndex = 8})
            AddPillCorner(thumb)
            local function setToggle(newState, callback)
                state = not not newState
                registerFlag(opts.Flag, state)
                PlayTween(track, TWEEN_MED, {BackgroundColor3 = state and Theme.Accent or Theme.Elevated})
                PlayTween(thumb, TWEEN_SPRING, {Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10), BackgroundColor3 = state and Theme.AccentText or Theme.Text})
                if callback ~= false then RunCallback(opts.Callback, state) end
            end
            AddButtonFeedback(holder, registerConnection, Theme.Surface, Theme.SurfaceLight, Theme.Elevated)
            ConnectActivated(holder, registerConnection, function() setToggle(not state, true) end)
            setToggle(state, false)
            bindFlag(opts.Flag, entry)
            function entry:Set(value) setToggle(value, true) end
            function entry:Get() return state end
            return entry
        end

        function TabElements:CreateSlider(opts)
            opts = opts or {}
            local range = opts.Range or {0, 100}
            local minValue = tonumber(range[1]) or 0
            local maxValue = tonumber(range[2]) or 100
            if maxValue < minValue then minValue, maxValue = maxValue, minValue end
            local increment = tonumber(opts.Increment) or 1
            if increment <= 0 then increment = 1 end
            local value = math.clamp(opts.CurrentValue or opts.Default or minValue, minValue, maxValue)
            local holder, label, entry = createBaseControl(tab, opts.Name or "Slider", 68, 70)
            local valueLabel = CreateUIElement("TextLabel", {Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(1, -68, 0, 0), Size = UDim2.new(0, 54, 0, 34), Font = Enum.Font.GothamMedium, Text = tostring(value), TextColor3 = Theme.SoftText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 7})
            local hitbox = CreateUIElement("Frame", {Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 40), Size = UDim2.new(1, -28, 0, 18), Active = true, ZIndex = 7})
            local track = CreateUIElement("Frame", {Parent = hitbox, BackgroundColor3 = Theme.Elevated, Position = UDim2.new(0, 0, 0.5, -4), Size = UDim2.new(1, 0, 0, 8), BorderSizePixel = 0, ZIndex = 7})
            AddPillCorner(track)
            local fill = CreateUIElement("Frame", {Parent = track, BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, ZIndex = 8})
            AddPillCorner(fill)
            local thumb = CreateUIElement("Frame", {Parent = hitbox, BackgroundColor3 = Theme.Text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 18, 0, 18), BorderSizePixel = 0, ZIndex = 9})
            AddPillCorner(thumb)
            AddStroke(thumb, Theme.Background)

            local dragging = false
            local dragInput = nil
            local dragType = nil
            local function valueToPos(raw)
                if maxValue == minValue then return 0 end
                return math.clamp((raw - minValue) / (maxValue - minValue), 0, 1)
            end
            local function roundValue(raw)
                return math.clamp(math.floor((raw - minValue) / increment + 0.5) * increment + minValue, minValue, maxValue)
            end
            local function render(pos)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                thumb.Position = UDim2.new(pos, 0, 0.5, 0)
                valueLabel.Text = tostring(value)
            end
            local function setValue(newValue, callback, directPos)
                value = roundValue(newValue)
                registerFlag(opts.Flag, value)
                render(directPos or valueToPos(value))
                if callback ~= false then RunCallback(opts.Callback, value) end
            end
            local function updateFromInput(input)
                if hitbox.AbsoluteSize.X <= 0 then return end
                local pos = math.clamp((input.Position.X - hitbox.AbsolutePosition.X) / hitbox.AbsoluteSize.X, 0, 1)
                setValue(minValue + ((maxValue - minValue) * pos), true, pos)
            end
            TrackConnection(registerConnection, hitbox.InputBegan, function(input)
                if not IsPointerDown(input) then return end
                dragging = true
                dragInput = input
                dragType = input.UserInputType
                PlayTween(thumb, TWEEN_FAST, {Size = UDim2.new(0, 20, 0, 20)})
                updateFromInput(input)
            end)
            TrackConnection(registerConnection, UserInputService.InputChanged, function(input)
                if dragging and PointerMoveMatches(input, dragInput, dragType) then updateFromInput(input) end
            end)
            TrackConnection(registerConnection, UserInputService.InputEnded, function(input)
                if IsPointerUp(input, dragInput, dragType) then
                    dragging = false
                    dragInput = nil
                    dragType = nil
                    PlayTween(thumb, TWEEN_FAST, {Size = UDim2.new(0, 18, 0, 18)})
                end
            end)
            TrackConnection(registerConnection, hitbox.MouseEnter, function() PlayTween(track, TWEEN_FAST, {BackgroundColor3 = Theme.Border}) end)
            TrackConnection(registerConnection, hitbox.MouseLeave, function() if not dragging then PlayTween(track, TWEEN_FAST, {BackgroundColor3 = Theme.Elevated}) end end)
            setValue(value, false)
            bindFlag(opts.Flag, entry)
            function entry:Set(newValue) setValue(newValue, true) end
            function entry:Get() return value end
            return entry
        end

        function TabElements:CreateTextbox(opts)
            opts = opts or {}
            local holder, label, entry = createBaseControl(tab, opts.Name or "Textbox", 58, 190)
            local box = CreateUIElement("TextBox", {Parent = holder, BackgroundColor3 = Theme.SurfaceLight, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.new(0, 174, 0, 36), Font = Enum.Font.Gotham, PlaceholderText = opts.PlaceholderText or opts.Placeholder or "Enter text...", PlaceholderColor3 = Theme.DimText, Text = opts.CurrentValue or opts.Default or "", TextColor3 = Theme.Text, TextSize = 12, ClearTextOnFocus = opts.ClearTextOnFocus or false, ZIndex = 7})
            MakeRounded(box, Radius.Input, Theme.Border)
            AddPadding(box, 10, 10)
            local stroke = box:FindFirstChildOfClass("UIStroke")
            local function submit(enterPressed)
                registerFlag(opts.Flag, box.Text)
                RunCallback(opts.Callback, box.Text, enterPressed)
                if enterPressed then RunCallback(opts.SubmitCallback or opts.OnSubmit, box.Text) end
            end
            TrackConnection(registerConnection, box.Focused, function() if stroke then PlayTween(stroke, TWEEN_FAST, {Color = Theme.Accent}) end end)
            TrackConnection(registerConnection, box.FocusLost, submit)
            TrackConnection(registerConnection, box:GetPropertyChangedSignal("Text"), function()
                registerFlag(opts.Flag, box.Text)
                RunCallback(opts.ChangedCallback or opts.OnChange, box.Text)
            end)
            registerFlag(opts.Flag, box.Text)
            bindFlag(opts.Flag, entry)
            function entry:Set(text) box.Text = ClampText(text); registerFlag(opts.Flag, box.Text) end
            function entry:Get() return box.Text end
            return entry
        end

        local function createDropdown(opts, multi)
            opts = opts or {}
            local values = opts.Options or opts.Values or {}
            local selected = multi and {} or (opts.CurrentOption or opts.CurrentValue or values[1])
            if multi and type(opts.CurrentOption) == "table" then
                for _, item in ipairs(opts.CurrentOption) do selected[item] = true end
            end
            local holder, label, entry = createBaseControl(tab, opts.Name or (multi and "Multi Dropdown" or "Dropdown"), 52, 190)
            holder.ClipsDescendants = true
            local main = CreateUIElement("TextButton", {Parent = holder, BackgroundColor3 = Theme.SurfaceLight, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 8), Size = UDim2.new(0, 174, 0, 36), Font = Enum.Font.Gotham, Text = "", AutoButtonColor = false, ClipsDescendants = true, Active = true, ZIndex = 8})
            MakeRounded(main, Radius.Dropdown, Theme.Border)
            AddButtonFeedback(main, registerConnection, Theme.SurfaceLight, Theme.Elevated, Theme.Border)
            local text = CreateUIElement("TextLabel", {Parent = main, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -32, 1, 0), Font = Enum.Font.Gotham, TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 9})
            local arrow = CreateUIElement("TextLabel", {Parent = main, BackgroundTransparency = 1, Position = UDim2.new(1, -26, 0, 0), Size = UDim2.new(0, 20, 1, 0), Font = Enum.Font.GothamBold, Text = "⌄", TextColor3 = Theme.MutedText, TextSize = 14, ZIndex = 9})
            local search = CreateUIElement("TextBox", {Parent = holder, BackgroundColor3 = Theme.SurfaceLight, Position = UDim2.new(0, 14, 0, 54), Size = UDim2.new(1, -28, 0, 32), Font = Enum.Font.Gotham, PlaceholderText = "Search...", PlaceholderColor3 = Theme.DimText, Text = "", TextColor3 = Theme.Text, TextSize = 12, ClearTextOnFocus = false, Visible = opts.Searchable or false, ZIndex = 8})
            MakeRounded(search, Radius.Input, Theme.Border)
            AddPadding(search, 10, 10)
            local list = CreateUIElement("ScrollingFrame", {Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, (opts.Searchable and 92 or 54)), Size = UDim2.new(1, -28, 0, 0), CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Border, BorderSizePixel = 0, ZIndex = 8})
            local listLayout = CreateUIElement("UIListLayout", {Parent = list, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
            local expanded = false
            local optionButtons = {}
            local function selectedList()
                local output = {}
                for option, enabled in pairs(selected) do if enabled then table.insert(output, option) end end
                table.sort(output, function(a, b) return tostring(a) < tostring(b) end)
                return output
            end
            local function displayText()
                if multi then
                    local listValue = selectedList()
                    return #listValue > 0 and table.concat(listValue, ", ") or "Select..."
                end
                return selected and tostring(selected) or "Select..."
            end
            local function updateButtonText()
                text.Text = displayText()
                registerFlag(opts.Flag, multi and selectedList() or selected)
            end
            local function resizeList()
                local count = 0
                local query = string.lower(search.Text or "")
                for _, info in ipairs(optionButtons) do
                    local visible = query == "" or string.find(string.lower(tostring(info.Value)), query, 1, true) ~= nil
                    info.Button.Visible = visible
                    if visible then count = count + 1 end
                end
                local listHeight = math.min(count * 34 + math.max(count - 1, 0) * 6, opts.MaxHeight or 150)
                local targetHeight = expanded and ((opts.Searchable and 98 or 60) + listHeight) or 52
                PlayTween(holder, TWEEN_MED, {Size = UDim2.new(1, 0, 0, targetHeight)})
                PlayTween(list, TWEEN_MED, {Size = UDim2.new(1, -28, 0, expanded and listHeight or 0)})
                list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 6)
                arrow.Text = expanded and "⌃" or "⌄"
            end
            local function makeOption(option)
                local btn = CreateUIElement("TextButton", {Parent = list, BackgroundColor3 = Theme.SurfaceLight, Size = UDim2.new(1, 0, 0, 34), Font = Enum.Font.Gotham, Text = tostring(option), TextColor3 = Theme.Text, TextSize = 12, AutoButtonColor = false, Active = true, ZIndex = 9})
                MakeRounded(btn, Radius.Dropdown, Theme.Border)
                AddButtonFeedback(btn, registerConnection, Theme.SurfaceLight, Theme.Elevated, Theme.Border)
                ConnectActivated(btn, registerConnection, function()
                    if multi then
                        selected[option] = not selected[option]
                        btn.BackgroundColor3 = selected[option] and Theme.Elevated or Theme.SurfaceLight
                        updateButtonText()
                        RunCallback(opts.Callback, selectedList())
                    else
                        selected = option
                        updateButtonText()
                        RunCallback(opts.Callback, selected)
                        expanded = false
                        resizeList()
                    end
                end)
                table.insert(optionButtons, {Button = btn, Value = option})
            end
            for _, option in ipairs(values) do makeOption(option) end
            ConnectActivated(main, registerConnection, function() expanded = not expanded; resizeList() end)
            TrackConnection(registerConnection, search:GetPropertyChangedSignal("Text"), resizeList)
            TrackConnection(registerConnection, listLayout:GetPropertyChangedSignal("AbsoluteContentSize"), resizeList)
            updateButtonText()
            resizeList()
            bindFlag(opts.Flag, entry)
            function entry:Set(value)
                if multi then
                    selected = {}
                    if type(value) == "table" then for _, item in ipairs(value) do selected[item] = true end end
                    RunCallback(opts.Callback, selectedList())
                else
                    selected = value
                    RunCallback(opts.Callback, selected)
                end
                updateButtonText()
            end
            function entry:Get() return multi and selectedList() or selected end
            function entry:Refresh(newValues, keepCurrent)
                values = newValues or {}
                for _, info in ipairs(optionButtons) do if info.Button.Parent then info.Button:Destroy() end end
                table.clear(optionButtons)
                if not keepCurrent then selected = multi and {} or values[1] end
                for _, option in ipairs(values) do makeOption(option) end
                updateButtonText()
                resizeList()
            end
            return entry
        end

        function TabElements:CreateDropdown(opts)
            opts = opts or {}
            return createDropdown(opts, opts.MultiSelect or opts.Multiple or opts.Multi)
        end
        function TabElements:CreateMultiDropdown(opts) return createDropdown(opts, true) end

        function TabElements:CreateKeybind(opts)
            opts = opts or {}
            local mode = opts.Mode or "Toggle"
            local key = opts.CurrentKey or opts.Key or Enum.KeyCode.E
            local active = opts.Default or false
            local binding = false
            local holder, label, entry = createBaseControl(tab, opts.Name or "Keybind", 54, 190)
            local modeText = CreateUIElement("TextLabel", {Parent = holder, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -104, 0.5, 0), Size = UDim2.new(0, 72, 0, 34), Font = Enum.Font.Gotham, Text = mode, TextColor3 = Theme.MutedText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 7})
            local bindButton = CreateUIElement("TextButton", {Parent = holder, BackgroundColor3 = Theme.SurfaceLight, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.new(0, 82, 0, 34), Font = Enum.Font.GothamMedium, Text = key.Name, TextColor3 = Theme.Text, TextSize = 12, AutoButtonColor = false, Active = true, ZIndex = 7})
            MakeRounded(bindButton, Radius.Button, Theme.Border)
            AddButtonFeedback(bindButton, registerConnection, Theme.SurfaceLight, Theme.Elevated, Theme.Border)
            ConnectActivated(bindButton, registerConnection, function()
                binding = true
                bindButton.Text = "Press..."
            end)
            TrackConnection(registerConnection, UserInputService.InputBegan, function(input, gameProcessed)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode
                    bindButton.Text = key.Name
                    binding = false
                    registerFlag(opts.Flag, key.Name)
                    RunCallback(opts.ChangedCallback or opts.OnChanged, key)
                    return
                end
                if gameProcessed or binding or input.KeyCode ~= key then return end
                if mode == "Hold" then
                    active = true
                    RunCallback(opts.Callback, true)
                elseif mode == "Always" then
                    RunCallback(opts.Callback, true)
                else
                    active = not active
                    RunCallback(opts.Callback, active)
                end
            end)
            TrackConnection(registerConnection, UserInputService.InputEnded, function(input)
                if mode == "Hold" and input.KeyCode == key then
                    active = false
                    RunCallback(opts.Callback, false)
                end
            end)
            if mode == "Always" then
                TrackConnection(registerConnection, RunService.RenderStepped, function() RunCallback(opts.Callback, true) end)
            end
            registerFlag(opts.Flag, key.Name)
            bindFlag(opts.Flag, entry)
            function entry:Set(newKey)
                if typeof and typeof(newKey) == "EnumItem" then
                    key = newKey
                else
                    local parsedKey = GetKeyCodeByName(newKey)
                    if parsedKey then key = parsedKey end
                end
                bindButton.Text = key.Name
                registerFlag(opts.Flag, key.Name)
            end
            function entry:SetMode(newMode) mode = newMode or mode; modeText.Text = mode end
            function entry:Get() return key end
            return entry
        end

        function TabElements:CreateColorPicker(opts)
            opts = opts or {}
            local color = opts.Color or opts.CurrentColor or Theme.Accent
            local transparency = math.clamp(opts.Transparency or 0, 0, 1)
            local hue, saturation, value = Color3.toHSV(color)
            local holder = CreateUIElement("Frame", {Parent = scroller, BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, 0, 0, 254), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 5})
            MakeRounded(holder, Radius.ColorPicker, Theme.Border)
            local titleLabel = CreateUIElement("TextLabel", {Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 10), Size = UDim2.new(1, -76, 0, 22), Font = Enum.Font.GothamMedium, Text = opts.Name or "Color Picker", TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6})
            local preview = CreateUIElement("Frame", {Parent = holder, BackgroundColor3 = color, Position = UDim2.new(1, -56, 0, 10), Size = UDim2.new(0, 42, 0, 42), BorderSizePixel = 0, ZIndex = 7})
            MakeRounded(preview, Radius.ColorPicker, Theme.Border)
            local svSquare = CreateUIElement("Frame", {Parent = holder, BackgroundColor3 = Color3.fromHSV(hue, 1, 1), Position = UDim2.new(0, 14, 0, 42), Size = UDim2.new(0, 190, 0, 138), Active = true, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 6})
            MakeRounded(svSquare, Radius.ColorPicker, Theme.Border)
            local satOverlay = CreateUIElement("Frame", {Parent = svSquare, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, Active = false, ZIndex = 7})
            AddCorner(satOverlay, Radius.ColorPicker)
            CreateUIElement("UIGradient", {Parent = satOverlay, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})})
            local valOverlay = CreateUIElement("Frame", {Parent = svSquare, BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, Active = false, ZIndex = 8})
            AddCorner(valOverlay, Radius.ColorPicker)
            CreateUIElement("UIGradient", {Parent = valOverlay, Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})})
            local svMarker = CreateUIElement("Frame", {Parent = svSquare, BackgroundTransparency = 1, Position = UDim2.new(saturation, -7, 1 - value, -7), Size = UDim2.new(0, 14, 0, 14), Active = false, ZIndex = 10})
            AddPillCorner(svMarker)
            AddStroke(svMarker, Color3.new(1, 1, 1), 2)
            local rightAreaX = 220
            local hueBar = CreateUIElement("Frame", {Parent = holder, BackgroundColor3 = Theme.SurfaceLight, Position = UDim2.new(0, rightAreaX, 0, 68), Size = UDim2.new(1, -rightAreaX - 14, 0, 14), Active = true, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 6})
            AddPillCorner(hueBar)
            AddStroke(hueBar, Theme.Border)
            CreateUIElement("UIGradient", {Parent = hueBar, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)), ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)), ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)), ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)), ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))})})
            local hueMarker = CreateUIElement("Frame", {Parent = hueBar, BackgroundColor3 = Theme.Text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(hue, 0, 0.5, 0), Size = UDim2.new(0, 10, 0, 22), Active = false, BorderSizePixel = 0, ZIndex = 9})
            MakeRounded(hueMarker, Radius.Input, Theme.Background)
            local alphaBar = CreateUIElement("Frame", {Parent = holder, BackgroundColor3 = Theme.SurfaceLight, Position = UDim2.new(0, rightAreaX, 0, 110), Size = UDim2.new(1, -rightAreaX - 14, 0, 14), Active = true, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 6})
            AddPillCorner(alphaBar)
            AddStroke(alphaBar, Theme.Border)
            local alphaFill = CreateUIElement("Frame", {Parent = alphaBar, BackgroundColor3 = Theme.Accent, Size = UDim2.new(1 - transparency, 0, 1, 0), BorderSizePixel = 0, Active = false, ZIndex = 7})
            AddPillCorner(alphaFill)
            local alphaMarker = CreateUIElement("Frame", {Parent = alphaBar, BackgroundColor3 = Theme.Text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1 - transparency, 0, 0.5, 0), Size = UDim2.new(0, 10, 0, 22), Active = false, BorderSizePixel = 0, ZIndex = 9})
            MakeRounded(alphaMarker, Radius.Input, Theme.Background)
            local rgbBox = CreateUIElement("TextBox", {Parent = holder, BackgroundColor3 = Theme.SurfaceLight, Position = UDim2.new(0, rightAreaX, 0, 148), Size = UDim2.new(1, -rightAreaX - 14, 0, 34), Font = Enum.Font.Gotham, Text = ColorToRGBText(color), PlaceholderText = "255, 255, 255", PlaceholderColor3 = Theme.DimText, TextColor3 = Theme.Text, TextSize = 12, ClearTextOnFocus = false, ZIndex = 7})
            MakeRounded(rgbBox, Radius.Input, Theme.Border)
            AddPadding(rgbBox, 10, 10)
            local hexBox = CreateUIElement("TextBox", {Parent = holder, BackgroundColor3 = Theme.SurfaceLight, Position = UDim2.new(0, rightAreaX, 0, 190), Size = UDim2.new(1, -rightAreaX - 14, 0, 34), Font = Enum.Font.Gotham, Text = ColorToHex(color), PlaceholderText = "#FFFFFF", PlaceholderColor3 = Theme.DimText, TextColor3 = Theme.Text, TextSize = 12, ClearTextOnFocus = false, ZIndex = 7})
            MakeRounded(hexBox, Radius.Input, Theme.Border)
            AddPadding(hexBox, 10, 10)
            CreateUIElement("TextLabel", {Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, rightAreaX, 0, 48), Size = UDim2.new(1, -rightAreaX - 14, 0, 16), Font = Enum.Font.Gotham, Text = "Hue", TextColor3 = Theme.MutedText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7})
            CreateUIElement("TextLabel", {Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, rightAreaX, 0, 90), Size = UDim2.new(1, -rightAreaX - 14, 0, 16), Font = Enum.Font.Gotham, Text = "Transparency", TextColor3 = Theme.MutedText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7})
            local entry = {Frame = holder, SearchText = opts.Name or "Color Picker"}
            table.insert(tab.Controls, entry)
            local suppressText = false
            local function fire()
                registerFlag(opts.Flag, {Hex = ColorToHex(color), RGB = ColorToRGBText(color), Transparency = transparency})
                RunCallback(opts.Callback, color, transparency)
            end
            local function render(shouldFire)
                color = Color3.fromHSV(hue, saturation, value)
                svSquare.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                preview.BackgroundColor3 = color
                svMarker.Position = UDim2.new(saturation, -7, 1 - value, -7)
                hueMarker.Position = UDim2.new(hue, 0, 0.5, 0)
                alphaFill.Size = UDim2.new(1 - transparency, 0, 1, 0)
                alphaMarker.Position = UDim2.new(1 - transparency, 0, 0.5, 0)
                suppressText = true
                rgbBox.Text = ColorToRGBText(color)
                hexBox.Text = ColorToHex(color)
                suppressText = false
                if shouldFire then fire() end
            end
            local function connectDrag(target, updater)
                local dragging = false
                local dragInput = nil
                local dragType = nil
                TrackConnection(registerConnection, target.InputBegan, function(input)
                    if not IsPointerDown(input) then return end
                    dragging = true
                    dragInput = input
                    dragType = input.UserInputType
                    updater(input)
                end)
                TrackConnection(registerConnection, UserInputService.InputChanged, function(input)
                    if dragging and PointerMoveMatches(input, dragInput, dragType) then updater(input) end
                end)
                TrackConnection(registerConnection, UserInputService.InputEnded, function(input)
                    if IsPointerUp(input, dragInput, dragType) then
                        dragging = false
                        dragInput = nil
                        dragType = nil
                    end
                end)
            end
            connectDrag(svSquare, function(input)
                if svSquare.AbsoluteSize.X <= 0 or svSquare.AbsoluteSize.Y <= 0 then return end
                saturation = math.clamp((input.Position.X - svSquare.AbsolutePosition.X) / svSquare.AbsoluteSize.X, 0, 1)
                value = 1 - math.clamp((input.Position.Y - svSquare.AbsolutePosition.Y) / svSquare.AbsoluteSize.Y, 0, 1)
                render(true)
            end)
            connectDrag(hueBar, function(input)
                if hueBar.AbsoluteSize.X <= 0 then return end
                hue = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                render(true)
            end)
            connectDrag(alphaBar, function(input)
                if alphaBar.AbsoluteSize.X <= 0 then return end
                transparency = 1 - math.clamp((input.Position.X - alphaBar.AbsolutePosition.X) / alphaBar.AbsoluteSize.X, 0, 1)
                render(true)
            end)
            TrackConnection(registerConnection, rgbBox.FocusLost, function()
                if suppressText then return end
                local parsed = ParseRGB(rgbBox.Text)
                if parsed then
                    hue, saturation, value = Color3.toHSV(parsed)
                    render(true)
                else
                    rgbBox.Text = ColorToRGBText(color)
                end
            end)
            TrackConnection(registerConnection, hexBox.FocusLost, function()
                if suppressText then return end
                local parsed = ParseHex(hexBox.Text)
                if parsed then
                    hue, saturation, value = Color3.toHSV(parsed)
                    render(true)
                else
                    hexBox.Text = ColorToHex(color)
                end
            end)
            render(false)
            bindFlag(opts.Flag, entry)
            function entry:Set(newColor, newTransparency)
                if type(newColor) == "table" then
                    if newColor.Hex then
                        local parsed = ParseHex(newColor.Hex)
                        if parsed then hue, saturation, value = Color3.toHSV(parsed) end
                    end
                    if newColor.Transparency ~= nil then transparency = math.clamp(newColor.Transparency, 0, 1) end
                else
                    if newColor then hue, saturation, value = Color3.toHSV(newColor) end
                    if newTransparency ~= nil then transparency = math.clamp(newTransparency, 0, 1) end
                end
                render(true)
            end
            function entry:Get() return color, transparency end
            return entry
        end

        tab.Elements = TabElements
        return TabElements
    end

    function Window:GetConfig()
        return DeepCopy(flags)
    end

    function Window:LoadConfig(config)
        if type(config) == "string" then
            local ok, decoded = pcall(function() return HttpService:JSONDecode(config) end)
            config = ok and decoded or {}
        end
        for key, value in pairs(config or {}) do
            if controlsByFlag[key] and controlsByFlag[key].Set then
                controlsByFlag[key]:Set(value)
            else
                registerFlag(key, value)
            end
        end
        return true
    end

    function Window:SaveConfig(path)
        local serialized = SerializeConfig(flags)
        if path and writefile then pcall(function() writefile(path, serialized) end) end
        return serialized
    end

    function Window:LoadConfigFile(path)
        if path and readfile and isfile and isfile(path) then
            local ok, data = pcall(function() return readfile(path) end)
            if ok then return Window:LoadConfig(data) end
        end
        return false
    end

    for _, autoTab in ipairs(options.Tabs or {}) do
        Window:CreateTab(autoTab.Name or autoTab[1] or "Tab", autoTab.Icon or autoTab[2])
    end

    return Window
end

return Luxware
