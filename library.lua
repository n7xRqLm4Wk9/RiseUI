--[[
    LuxwareUI - Premium Monolithic Script Interface
    Optimized for Delta Executor (PC & Mobile Platform Architecture)
    Aesthetic: Pure AMOLED Black (#0D0D0D) & High-Contrast Minimalist
--]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Secure UI Injection (Bypasses protect_gui syntax errors)
local CoreGui = game:GetService("CoreGui")
local ParentContainer = Instance.new("ScreenGui")
ParentContainer.Name = "LuxwareUI_Framework"
ParentContainer.ResetOnSpawn = false

local success = pcall(function()
    local get_hui = gethui or function() return CoreGui end
    ParentContainer.Parent = get_hui()
end)
if not success then
    ParentContainer.Parent = CoreGui
end

-- Visual Constant Declarations
local Theme = {
    MainBg = Color3.fromRGB(13, 13, 13),        -- #0D0D0D Pure AMOLED
    SidebarBg = Color3.fromRGB(17, 17, 17),     -- #111111 Slightly Lighter
    Surface = Color3.fromRGB(22, 22, 22),       -- #161616 Component Background
    Border = Color3.fromRGB(31, 31, 31),        -- #1F1F1F Faint Border
    BorderLight = Color3.fromRGB(60, 60, 60),   -- Focused/Active states
    TextWhite = Color3.fromRGB(255, 255, 255),  -- High Contrast Primary
    TextGrey = Color3.fromRGB(150, 150, 150),   -- Muted Secondary
    Accent = Color3.fromRGB(255, 255, 255),     -- Pure White Accent Highlight
    DarkHighlight = Color3.fromRGB(28, 28, 28), -- Active sidebar item surface
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium
}

local Icons = {
    house    = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/house.png",
    settings = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/settings.png",
    search   = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/search.png",
    x        = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/x.png",
    minus    = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/minus.png",
    chevron_down = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/chevron-down.png",
    chevron_up   = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/chevron-up.png",
    bell     = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/bell.png",
    palette  = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/palette.png",
    keyboard = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/keyboard.png",
    eye      = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/eye.png",
    eye_off  = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/eye-off.png",
    lock     = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/lock.png",
    lock_open = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/lock-open.png",
    ellipsis = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/ellipsis-vertical.png",
    sliders  = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/sliders-horizontal.png",
    rotate   = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/rotate-cw.png",
    check    = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/check.png",
    warning  = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/triangle-alert.png",
    message  = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/message-circle.png",
    grip     = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/grip-vertical.png",
}

-- Library Base Setup
local LuxwareUI = {
    Flags = {},
    Configuration = { Enabled = false, FileName = "luxware_config" },
    Closed = false,
    Modules = {},
    NotificationQueue = nil
}

local function GetImageAsset(url)
    return url
end

-- Inline Utility Library for Fast GUI Instantiation
local UI = {}
function UI.Frame(parent, props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.BackgroundColor3 = props.Bg or Theme.MainBg
    f.Size = props.Size or UDim2.new(1, 0, 1, 0)
    f.Position = props.Pos or UDim2.new(0, 0, 0, 0)
    if props.Name then f.Name = props.Name end
    f.Parent = parent
    return f
end

function UI.Border(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    stroke.Parent = parent
    return stroke
end

function UI.Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = parent
    return c
end

function UI.TextLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = props.Font or Theme.Font
    l.TextSize = props.Size or 14
    l.TextColor3 = props.Color or Theme.TextWhite
    l.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
    l.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
    l.Text = props.Text or ""
    l.Size = props.FrameSize or UDim2.new(1, 0, 1, 0)
    l.Position = props.Pos or UDim2.new(0, 0, 0, 0)
    if props.Name then l.Name = props.Name end
    l.Parent = parent
    return l
end

function UI.Image(parent, props)
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Image = GetImageAsset(props.Image or "")
    img.Size = props.Size or UDim2.new(0, 16, 0, 16)
    img.Position = props.Pos or UDim2.new(0, 0, 0, 0)
    if props.Color then img.ImageColor3 = props.Color end
    if props.Name then img.Name = props.Name end
    img.Parent = parent
    return img
end

function UI.Button(parent, props)
    local b = Instance.new("TextButton")
    b.BackgroundTransparency = 1
    b.Text = ""
    b.Size = props.Size or UDim2.new(1, 0, 1, 0)
    b.Position = props.Pos or UDim2.new(0, 0, 0, 0)
    if props.Name then b.Name = props.Name end
    b.Parent = parent
    return b
end

-- Safely scopes UserInput events to prevent memory leaks across components
local function BindDragLogic(triggerElement, updateCallback)
    local connection, releaseConnection
    triggerElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateCallback(input)
            
            connection = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    updateCallback(moveInput)
                end
            end)
            
            releaseConnection = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    if connection then connection:Disconnect() end
                    if releaseConnection then releaseConnection:Disconnect() end
                end
            end)
        end
    end)
end

local function MakeDraggable(dragHandle, dragTarget)
    local dragStart, startPos
    BindDragLogic(dragHandle, function(input)
        if input.UserInputState == Enum.UserInputState.Begin then
            dragStart = input.Position
            startPos = dragTarget.Position
        elseif input.UserInputState == Enum.UserInputState.Change then
            local delta = input.Position - dragStart
            dragTarget.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Global Configuration Save/Load Layer
function LuxwareUI:SaveSettings()
    if not LuxwareUI.Configuration.Enabled then return end
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(LuxwareUI.Flags)
    end)
    if success and writefile then
        writefile(LuxwareUI.Configuration.FileName .. ".json", encoded)
    end
end

function LuxwareUI:LoadSettings()
    if not LuxwareUI.Configuration.Enabled then return end
    if readfile and isfile and isfile(LuxwareUI.Configuration.FileName .. ".json") then
        local raw = readfile(LuxwareUI.Configuration.FileName .. ".json")
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if success then
            for k, v in pairs(decoded) do
                LuxwareUI.Flags[k] = v
            end
        end
    end
end

-- High Performance Notification System Container Sub-module
local function CreateNotificationEngine()
    local tray = Instance.new("Frame")
    tray.Name = "NotificationTray"
    tray.Size = UDim2.new(0, 300, 1, -20)
    tray.Position = UDim2.new(1, -310, 0, 10)
    tray.BackgroundTransparency = 1
    tray.Parent = ParentContainer

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding = UDim.new(0, 8)
    layout.Parent = tray

    return {
        Tray = tray,
        Push = function(data)
            local titleText = data.Title or "Notification"
            local contentText = data.Content or ""
            local duration = data.Duration or 4
            local nType = data.Type or "info"

            local card = UI.Frame(tray, { Bg = Theme.MainBg, Size = UDim2.new(1, 0, 0, 65) })
            UI.Border(card, Theme.Border)
            UI.Corner(card, 4)
            card.ClipsDescendants = true
            card.BackgroundTransparency = 1

            local typeIcon = Icons.bell
            if nType == "success" then typeIcon = Icons.check
            elseif nType == "error" then typeIcon = Icons.x
            elseif nType == "warning" then typeIcon = Icons.warning
            end

            local icon = UI.Image(card, { Image = typeIcon, Size = UDim2.new(0, 18, 0, 18), Pos = UDim2.new(0, 12, 0, 12) })
            local tLabel = UI.TextLabel(card, { Text = titleText, Font = Theme.FontBold, Size = 13, FrameSize = UDim2.new(1, -40, 0, 16), Pos = UDim2.new(0, 38, 0, 12) })
            local cLabel = UI.TextLabel(card, { Text = contentText, Color = Theme.TextGrey, Size = 12, FrameSize = UDim2.new(1, -40, 0, 24), Pos = UDim2.new(0, 38, 0, 28) })
            cLabel.TextWrapped = true

            local indicator = UI.Frame(card, { Bg = Theme.Accent, Size = UDim2.new(0, 3, 1, 0) })

            -- Entrance sequence Animations
            TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { BackgroundTransparency = 0 }):Play()
            task.wait(duration)
            
            -- Close animation cycle
            local closeTween = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                card:Destroy()
            end)
        end
    }
end

-- Adaptive Key Validation Interface
function LuxwareUI:KeySystem(cfg)
    local title = cfg.Title or "Verification Required"
    local targetKey = cfg.Key or ""
    local grabUrl = cfg.GrabKey or ""
    local callback = cfg.Callback

    local hwid = "HWID_" .. tostring(LocalPlayer.UserId)

    local screen = UI.Frame(ParentContainer, { Bg = Color3.fromRGB(8, 8, 8), Size = UDim2.new(1, 0, 1, 0) })
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local window = UI.Frame(screen, { Bg = Theme.MainBg, Size = UDim2.new(0, 340, 0, 240), Pos = UDim2.new(0,50,0,50) })
    window.Position = UDim2.new(0.5, -170, 0.5, -120)
    UI.Border(window, Theme.Border)
    UI.Corner(window, 6)

    local header = UI.TextLabel(window, { Text = title, Font = Theme.FontBold, Size = 16, FrameSize = UDim2.new(1, -24, 0, 40), Pos = UDim2.new(0, 12, 0, 10) })
    local sub = UI.TextLabel(window, { Text = "Device: " .. hwid, Color = Theme.TextGrey, Size = 11, FrameSize = UDim2.new(1, -24, 0, 16), Pos = UDim2.new(0, 12, 0, 42) })

    local boxContainer = UI.Frame(window, { Bg = Theme.Surface, Size = UDim2.new(1, -24, 0, 36), Pos = UDim2.new(0, 12, 0, 80) })
    UI.Border(boxContainer, Theme.Border)
    UI.Corner(boxContainer, 4)
    
    local textBox = Instance.new("TextBox")
    textBox.BackgroundTransparency = 1
    textBox.Size = UDim2.new(1, -20, 1, 0)
    textBox.Position = UDim2.new(0, 10, 0, 0)
    textBox.Font = Theme.Font
    textBox.TextSize = 13
    textBox.TextColor3 = Theme.TextWhite
    textBox.PlaceholderText = "Enter Access Key Here..."
    textBox.PlaceholderColor3 = Theme.TextGrey
    textBox.Text = ""
    textBox.Parent = boxContainer

    textBox.Focused:Connect(function() TweenService:Create(boxContainer:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), { Color = Theme.TextWhite }):Play() end)
    textBox.FocusLost:Connect(function() TweenService:Create(boxContainer:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), { Color = Theme.Border }):Play() end)

    local checkBtn = UI.Frame(window, { Bg = Theme.Surface, Size = UDim2.new(0, 150, 0, 36), Pos = UDim2.new(0, 12, 0, 135) })
    UI.Border(checkBtn, Theme.Border)
    UI.Corner(checkBtn, 4)
    UI.TextLabel(checkBtn, { Text = "Submit Key", Font = Theme.FontMedium, Size = 13, XAlign = Enum.TextXAlignment.Center })
    local cClick = UI.Button(checkBtn, {})

    local grabBtn = UI.Frame(window, { Bg = Theme.Surface, Size = UDim2.new(0, 150, 0, 36), Pos = UDim2.new(1, -162, 0, 135) })
    UI.Border(grabBtn, Theme.Border)
    UI.Corner(grabBtn, 4)
    UI.TextLabel(grabBtn, { Text = "Get Key Link", Font = Theme.FontMedium, Size = 13, Color = Theme.TextGrey, XAlign = Enum.TextXAlignment.Center })
    local gClick = UI.Button(grabBtn, {})

    local status = UI.TextLabel(window, { Text = "", Color = Theme.TextGrey, Size = 12, XAlign = Enum.TextXAlignment.Center, FrameSize = UDim2.new(1, -24, 0, 20), Pos = UDim2.new(0, 12, 0, 190) })

    cClick.MouseButton1Click:Connect(function()
        if textBox.Text == targetKey then
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            status.Text = "Authentication Successful!"
            task.wait(0.6)
            screen:Destroy()
            if callback then callback(true) end
        else
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            status.Text = "Invalid Key, Please try again."
        end
    end)

    gClick.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(grabUrl)
            status.Text = "Link copied to clipboard structure!"
        else
            status.Text = grabUrl
        end
    end)

    while screen.Parent do task.wait(1) end
end

-- Primary Execution Window Construction Function
function LuxwareUI:CreateWindow(config)
    local winName = config.Name or "Luxware Premium Library"
    local loadingTitle = config.LoadingTitle or ""
    
    if config.ConfigurationSaving then
        LuxwareUI.Configuration.Enabled = config.ConfigurationSaving.Enabled or false
        LuxwareUI.Configuration.FileName = config.ConfigurationSaving.FileName or "luxware_config"
    end
    LuxwareUI:LoadSettings()

    LuxwareUI.NotificationQueue = CreateNotificationEngine()

    -- Platform Adaptation Logic (Delta Exec PC vs Mobile Layout Scaling)
    local isMobile = UserInputService.TouchEnabled
    local winSize = isMobile and UDim2.new(0, 340, 0, 460) or UDim2.new(0, 560, 0, 520)

    local mainFrame = UI.Frame(ParentContainer, { Bg = Theme.MainBg, Size = UDim2.new(0, 0, 0, 0) })
    mainFrame.Position = UDim2.new(0.5, -winSize.X.Offset/2, 0.5, -winSize.Y.Offset/2)
    mainFrame.ClipsDescendants = true
    UI.Border(mainFrame, Theme.Border)
    UI.Corner(mainFrame, 6)

    -- Entrance Spring Tween
    TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = winSize }):Play()

    -- Sidebar container initialization
    local sidebar = UI.Frame(mainFrame, { Bg = Theme.SidebarBg, Size = UDim2.new(0, 140, 1, 0) })
    UI.Frame(sidebar, { Bg = Theme.Border, Size = UDim2.new(0, 1, 1, 0), Pos = UDim2.new(1, -1, 0, 0) })

    local brandFrame = UI.Frame(sidebar, { Bg = Color3.fromRGB(0,0,0), Size = UDim2.new(1, 0, 0, 50) })
    brandFrame.BackgroundTransparency = 1
    UI.TextLabel(brandFrame, { Text = winName, Font = Theme.FontBold, Size = 14, FrameSize = UDim2.new(1, -20, 0, 20), Pos = UDim2.new(0, 12, 0, 10) })
    UI.TextLabel(brandFrame, { Text = loadingTitle, Font = Theme.Font, Size = 10, Color = Theme.TextGrey, FrameSize = UDim2.new(1, -20, 0, 14), Pos = UDim2.new(0, 12, 0, 28) })

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.Size = UDim2.new(1, 0, 1, -60)
    tabScroll.Position = UDim2.new(0, 0, 0, 60)
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.ScrollBarThickness = 0
    tabScroll.Parent = sidebar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabScroll

    -- Right Content System Container Context
    local contentArea = UI.Frame(mainFrame, { Bg = Theme.MainBg, Size = UDim2.new(1, -140, 1, 0), Pos = UDim2.new(0, 140, 0, 0) })
    
    local topBar = UI.Frame(contentArea, { Bg = Theme.MainBg, Size = UDim2.new(1, 0, 0, 40) })
    local currentTabTitle = UI.TextLabel(topBar, { Text = "Dashboard", Font = Theme.FontBold, Size = 14, Pos = UDim2.new(0, 16, 0, 0) })

    -- Drag mapping onto header structure
    MakeDraggable(topBar, mainFrame)
    MakeDraggable(brandFrame, mainFrame)

    -- Controller Core Triggers
    local minBtn = UI.Image(topBar, { Image = Icons.minus, Size = UDim2.new(0, 14, 0, 14), Pos = UDim2.new(1, -54, 0, 13), Color = Theme.TextGrey })
    local minClick = UI.Button(minBtn, { Size = UDim2.new(1.5,0,1.5,0), Pos = UDim2.new(-0.25,0,-0.25,0) })
    
    local closeBtn = UI.Image(topBar, { Image = Icons.x, Size = UDim2.new(0, 14, 0, 14), Pos = UDim2.new(1, -28, 0, 13), Color = Theme.TextGrey })
    local closeClick = UI.Button(closeBtn, { Size = UDim2.new(1.5,0,1.5,0), Pos = UDim2.new(-0.25,0,-0.25,0) })

    local minimized = false
    minClick.MouseButton1Click:Connect(function()
        minimized = not minimized
        TweenService:Create(contentArea, TweenInfo.new(0.3), { Size = minimized and UDim2.new(1, -140, 0, 40) or UDim2.new(1, -140, 1, 0) }):Play()
        TweenService:Create(sidebar, TweenInfo.new(0.3), { Size = minimized and UDim2.new(0, 140, 0, 40) or UDim2.new(0, 140, 1, 0) }):Play()
    end)

    closeClick.MouseButton1Click:Connect(function()
        LuxwareUI.Closed = true
        local closing = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) })
        closing:Play()
        closing.Completed:Connect(function() mainFrame:Destroy() end)
    end)

    local containerStack = UI.Frame(contentArea, { Bg = Theme.MainBg, Size = UDim2.new(1, 0, 1, -40), Pos = UDim2.new(0, 0, 0, 40) })

    local WindowAPI = {}
    local tabsList = {}
    local sequenceId = 0

    function WindowAPI:Notify(data)
        if LuxwareUI.NotificationQueue then
            task.spawn(LuxwareUI.NotificationQueue.Push, data)
        end
    end

    function WindowAPI:CreateTab(tabName, iconAsset)
        sequenceId = sequenceId + 1
        local currentTabId = sequenceId

        local tabButtonFrame = UI.Frame(tabScroll, { Bg = Color3.fromRGB(0,0,0), Size = UDim2.new(1, -12, 0, 34), Pos = UDim2.new(0, 6, 0, 0) })
        tabButtonFrame.BackgroundTransparency = 1
        tabButtonFrame.LayoutOrder = currentTabId

        local activeLeftBar = UI.Frame(tabButtonFrame, { Bg = Theme.Accent, Size = UDim2.new(0, 2, 1, 0) })
        activeLeftBar.Visible = false

        local icon = UI.Image(tabButtonFrame, { Image = iconAsset or Icons.house, Size = UDim2.new(0, 16, 0, 16), Pos = UDim2.new(0, 12, 0, 9), Color = Theme.TextGrey })
        local label = UI.TextLabel(tabButtonFrame, { Text = tabName, Color = Theme.TextGrey, Font = Theme.FontMedium, Size = 12, FrameSize = UDim2.new(1, -38, 1, 0), Pos = UDim2.new(0, 34, 0, 0) })
        local clickTrigger = UI.Button(tabButtonFrame, {})

        -- Dedicated Canvas Space
        local tabCanvas = Instance.new("ScrollingFrame")
        tabCanvas.BackgroundTransparency = 1
        tabCanvas.BorderSizePixel = 0
        tabCanvas.Size = UDim2.new(1, 0, 1, 0)
        tabCanvas.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabCanvas.ScrollBarThickness = 2
        tabCanvas.ScrollBarImageColor3 = Theme.Border
        tabCanvas.Visible = false
        tabCanvas.Parent = containerStack

        local canvasPadding = Instance.new("UIPadding")
        canvasPadding.PaddingLeft = UDim.new(0, 16)
        canvasPadding.PaddingRight = UDim.new(0, 16)
        canvasPadding.PaddingTop = UDim.new(0, 12)
        canvasPadding.PaddingBottom = UDim.new(0, 30)
        canvasPadding.Parent = tabCanvas

        local canvasLayout = Instance.new("UIListLayout")
        canvasLayout.SortOrder = Enum.SortOrder.LayoutOrder
        canvasLayout.Padding = UDim.new(0, 10)
        canvasLayout.Parent = tabCanvas

        canvasLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabCanvas.CanvasSize = UDim2.new(0, 0, 0, canvasLayout.AbsoluteContentSize.Y + 40)
        end)

        local function Select()
            for _, t in pairs(tabsList) do
                t.ButtonFrame.BackgroundTransparency = 1
                t.LeftBar.Visible = false
                t.Icon.ImageColor3 = Theme.TextGrey
                t.Label.TextColor3 = Theme.TextGrey
                t.Canvas.Visible = false
            end
            tabButtonFrame.BackgroundTransparency = 0
            tabButtonFrame.BackgroundColor3 = Theme.DarkHighlight
            activeLeftBar.Visible = true
            icon.ImageColor3 = Theme.TextWhite
            label.TextColor3 = Theme.TextWhite
            tabCanvas.Visible = true
            currentTabTitle.Text = tabName
        end

        clickTrigger.MouseButton1Click:Connect(Select)
        
        table.insert(tabsList, {
            ButtonFrame = tabButtonFrame,
            LeftBar = activeLeftBar,
            Icon = icon,
            Label = label,
            Canvas = tabCanvas
        })

        if #tabsList == 1 then Select() end

        -- Component Container Factory Method Matrix
        local SectionAPI = {}

        function SectionAPI:CreateSection(secName)
            local sectionContainer = UI.Frame(tabCanvas, { Bg = Color3.fromRGB(0,0,0), Size = UDim2.new(1, 0, 0, 0) })
            sectionContainer.BackgroundTransparency = 1
            sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
            
            local secLayout = Instance.new("UIListLayout")
            secLayout.SortOrder = Enum.SortOrder.LayoutOrder
            secLayout.Padding = UDim.new(0, 4)
            secLayout.Parent = sectionContainer

            local secHeader = UI.Frame(sectionContainer, { Bg = Color3.fromRGB(0,0,0), Size = UDim2.new(1, 0, 0, 24) })
            secHeader.BackgroundTransparency = 1
            UI.TextLabel(secHeader, { Text = secName, Font = Theme.FontMedium, Size = 13, Color = Theme.TextWhite })

            local SectionMethods = {}

            -- 1. BUTTON FACTORY
            function SectionMethods:CreateButton(bCfg)
                local name = bCfg.Name or "Interaction"
                local cb = bCfg.Callback

                local element = UI.Frame(sectionContainer, { Bg = Theme.Surface, Size = UDim2.new(1, 0, 0, 36) })
                UI.Border(element, Theme.Border)
                UI.Corner(element, 4)
                
                local txt = UI.TextLabel(element, { Text = name, Font = Theme.FontMedium, Size = 13, XAlign = Enum.TextXAlignment.Center })
                local click = UI.Button(element, {})

                click.MouseEnter:Connect(function() TweenService:Create(element, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(30,30,30) }):Play() end)
                click.MouseLeave:Connect(function() TweenService:Create(element, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Surface }):Play() end)
                
                click.MouseButton1Click:Connect(function()
                    txt.Position = UDim2.new(0, 2, 0, 0)
                    task.wait(0.05)
                    txt.Position = UDim2.new(0, 0, 0, 0)
                    if cb then pcall(cb) end
                end)
                return element
            end

            -- 2. TOGGLE FACTORY
            function SectionMethods:CreateToggle(tCfg)
                local name = tCfg.Name or "Toggle Switch"
                local flag = tCfg.Flag
                local cb = tCfg.Callback
                local current = tCfg.CurrentValue or false

                if flag and LuxwareUI.Flags[flag] ~= nil then
                    current = LuxwareUI.Flags[flag]
                end

                local element = UI.Frame(sectionContainer, { Bg = Color3.fromRGB(0,0,0), Size = UDim2.new(1, 0, 0, 32) })
                element.BackgroundTransparency = 1

                local box = UI.Frame(element, { Bg = Theme.Surface, Size = UDim2.new(0, 14, 0, 14), Pos = UDim2.new(0, 4, 0, 9) })
                UI.Corner(box, 2)
                local boxBorder = UI.Border(box, Theme.Border)

                local label = UI.TextLabel(element, { Text = name, Size = 13, Pos = UDim2.new(0, 28, 0, 0), FrameSize = UDim2.new(1, -60, 1, 0) })
                local opt = UI.Image(element, { Image = Icons.ellipsis, Size = UDim2.new(0, 14, 0, 14), Pos = UDim2.new(1, -18, 0, 9), Color = Theme.TextGrey })

                local click = UI.Button(element, {})

                local function RenderState()
                    if current then
                        box.BackgroundColor3 = Theme.TextWhite
                        boxBorder.Color = Theme.TextWhite
                    else
                        box.BackgroundColor3 = Theme.Surface
                        boxBorder.Color = Theme.Border
                    end
                    if flag then LuxwareUI.Flags[flag] = current LuxwareUI:SaveSettings() end
                end

                click.MouseButton1Click:Connect(function()
                    current = not current
                    RenderState()
                    if cb then pcall(cb, current) end
                end)

                RenderState()
                return element
            end

            -- 3. SLIDER FACTORY
            function SectionMethods:CreateSlider(sCfg)
                local name = sCfg.Name or "Adjustment Range"
                local min = sCfg.Range[1] or 0
                local max = sCfg.Range[2] or 100
                local inc = sCfg.Increment or 1
                local flag = sCfg.Flag
                local cb = sCfg.Callback
                local current = sCfg.CurrentValue or min

                if flag and LuxwareUI.Flags[flag] ~= nil then
                    current = LuxwareUI.Flags[flag]
                end

                local element = UI.Frame(sectionContainer, { Bg = Color3.fromRGB(0,0,0), Size = UDim2.new(1, 0, 0, 48) })
                element.BackgroundTransparency = 1

                local title = UI.TextLabel(element, { Text = name, Size = 13, FrameSize = UDim2.new(0.7, 0, 0, 20) })
                local valLabel = UI.TextLabel(element, { Text = tostring(current) .. "/" .. tostring(max), Color = Theme.TextGrey, Size = 12, XAlign = Enum.TextXAlignment.Right, FrameSize = UDim2.new(0.3, 0, 0, 20), Pos = UDim2.new(0.7, 0, 0, 0) })

                local track = UI.Frame(element, { Bg = Theme.Surface, Size = UDim2.new(1, -8, 0, 6), Pos = UDim2.new(0, 4, 0, 28) })
                UI.Corner(track, 3)
                local trackBorder = UI.Border(track, Theme.Border)
                local fill = UI.Frame(track, { Bg = Theme.TextWhite, Size = UDim2.new(0, 0, 1, 0) })
                UI.Corner(fill, 3)

                local thumb = UI.Frame(track, { Bg = Theme.TextWhite, Size = UDim2.new(0, 12, 0, 12), Pos = UDim2.new(0, 0, 0.5, -6) })
                UI.Corner(thumb, 6)

                BindDragLogic(track, function(input)
                    local selectPos = input.Position.X
                    local trackAbsPos = track.AbsolutePosition.X
                    local trackAbsSize = track.AbsoluteSize.X
                    local ratio = math.clamp((selectPos - trackAbsPos) / trackAbsSize, 0, 1)
                    
                    local rawVal = min + (ratio * (max - min))
                    local snapped = math.floor(rawVal / inc + 0.5) * inc
                    current = math.clamp(snapped, min, max)

                    valLabel.Text = tostring(current) .. "/" .. tostring(max)
                    fill.Size = UDim2.new(ratio, 0, 1, 0)
                    thumb.Position = UDim2.new(ratio, -6, 0.5, -6)

                    if flag then LuxwareUI.Flags[flag] = current LuxwareUI:SaveSettings() end
                    if cb then pcall(cb, current) end
                end)

                local initRatio = (current - min) / (max - min)
                fill.Size = UDim2.new(initRatio, 0, 1, 0)
                thumb.Position = UDim2.new(initRatio, -6, 0.5, -6)

                return element
            end

            -- 4. DROPDOWN FACTORY
            function SectionMethods:CreateDropdown(dCfg)
                local name = dCfg.Name or "Selection Matrix"
                local options = dCfg.Options or {}
                local flag = dCfg.Flag
                local cb = dCfg.Callback
                local current = dCfg.CurrentOption or options[1]

                if flag and LuxwareUI.Flags[flag] ~= nil then
                    current = LuxwareUI.Flags[flag]
                end

                local expanded = false

                local element = UI.Frame(sectionContainer, { Bg = Theme.Surface, Size = UDim2.new(1, 0, 0, 36) })
                element.ClipsDescendants = true
                UI.Border(element, Theme.Border)
                UI.Corner(element, 4)

                local sLabel = UI.TextLabel(element, { Text = current, Size = 13, Pos = UDim2.new(0, 12, 0, 0), FrameSize = UDim2.new(1, -40, 0, 36) })
                local chevron = UI.Image(element, { Image = Icons.chevron_down, Size = UDim2.new(0, 14, 0, 14), Pos = UDim2.new(1, -24, 0, 11), Color = Theme.TextGrey })

                local trigger = UI.Button(element, { Size = UDim2.new(1, 0, 0, 36) })

                local listContainer = UI.Frame(element, { Bg = Theme.MainBg, Size = UDim2.new(1, 0, 0, #options * 30), Pos = UDim2.new(0, 0, 0, 36) })
                local listLayout = Instance.new("UIListLayout")
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Parent = listContainer

                local function RebuildRows()
                    for _, row in pairs(listContainer:GetChildren()) do
                        if row:IsA("Frame") then row:Destroy() end
                    end
                    for i, opt in pairs(options) do
                        local row = UI.Frame(listContainer, { Bg = Theme.Surface, Size = UDim2.new(1, 0, 0, 30) })
                        row.LayoutOrder = i
                        local rLabel = UI.TextLabel(row, { Text = opt, Size = 12, Color = (opt == current and Theme.TextWhite or Theme.TextGrey), Pos = UDim2.new(0, 16, 0, 0) })
                        local rClick = UI.Button(row, {})
                        
                        rClick.MouseButton1Click:Connect(function()
                            current = opt
                            sLabel.Text = current
                            expanded = false
                            element.Size = UDim2.new(1, 0, 0, 36)
                            chevron.Image = GetImageAsset(Icons.chevron_down)
                            if flag then LuxwareUI.Flags[flag] = current LuxwareUI:SaveSettings() end
                            if cb then pcall(cb, current) end
                            RebuildRows()
                        end)
                    end
                end

                trigger.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    if expanded then
                        element.Size = UDim2.new(1, 0, 0, 36 + (#options * 30))
                        chevron.Image = GetImageAsset(Icons.chevron_up)
                    else
                        element.Size = UDim2.new(1, 0, 0, 36)
                        chevron.Image = GetImageAsset(Icons.chevron_down)
                    end
                end)

                RebuildRows()
                return element
            end

            -- 5. INPUT FACTORY
            function SectionMethods:CreateInput(iCfg)
                local name = iCfg.Name or "Input Processing"
                local placeholder = iCfg.PlaceholderText or "Type query..."
                local cb = iCfg.Callback

                local element = UI.Frame(sectionContainer, { Bg = Color3.fromRGB(0,0,0), Size = UDim2.new(1, 0, 0, 56) })
                element.BackgroundTransparency = 1

                local label = UI.TextLabel(element, { Text = name, Color = Theme.TextGrey, Size = 11, FrameSize = UDim2.new(1, 0, 0, 16) })
                local boxWrapper = UI.Frame(element, { Bg = Theme.Surface, Size = UDim2.new(1, 0, 0, 36), Pos = UDim2.new(0, 0, 0, 20) })
                local stroke = UI.Border(boxWrapper, Theme.Border)
                UI.Corner(boxWrapper, 4)

                local box = Instance.new("TextBox")
                box.BackgroundTransparency = 1
                box.Size = UDim2.new(1, -24, 1, 0)
                box.Position = UDim2.new(0, 12, 0, 0)
                box.Font = Theme.Font
                box.TextSize = 13
                box.TextColor3 = Theme.TextWhite
                box.PlaceholderText = placeholder
                box.PlaceholderColor3 = Theme.TextGrey
                box.Text = ""
                box.Parent = boxWrapper

                box.Focused:Connect(function() TweenService:Create(stroke, TweenInfo.new(0.2), { Color = Theme.TextWhite }):Play() end)
                box.FocusLost:Connect(function()
                    TweenService:Create(stroke, TweenInfo.new(0.2), { Color = Theme.Border }):Play()
                    if cb then pcall(cb, box.Text) end
                end)

                return element
            end

            -- 6. KEYBIND FACTORY
            function SectionMethods:CreateKeybind(kCfg)
                local name = kCfg.Name or "Trigger Bind"
                local current = kCfg.CurrentKeybind or "None"
                local cb = kCfg.Callback

                local element = UI.Frame(sectionContainer, { Bg = Color3.fromRGB(0,0,0), Size = UDim2.new(1, 0, 0, 32) })
                element.BackgroundTransparency = 1

                local label = UI.TextLabel(element, { Text = name, Size = 13, FrameSize = UDim2.new(0.6, 0, 1, 0) })
                
                local displayBox = UI.Frame(element, { Bg = Theme.Surface, Size = UDim2.new(0, 80, 0, 24), Pos = UDim2.new(1, -84, 0, 4) })
                local stroke = UI.Border(displayBox, Theme.Border)
                UI.Corner(displayBox, 4)
                
                local dText = UI.TextLabel(displayBox, { Text = tostring(current), Size = 12, XAlign = Enum.TextXAlignment.Center })

                local click = UI.Button(displayBox, {})
                local listening = false
                local listenConnection

                click.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    dText.Text = "..."
                    stroke.Color = Theme.TextWhite

                    listenConnection = UserInputService.InputBegan:Connect(function(input, processed)
                        if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            current = input.KeyCode.Name
                            dText.Text = tostring(current)
                            stroke.Color = Theme.Border
                            if cb then pcall(cb, input.KeyCode) end
                            if listenConnection then listenConnection:Disconnect() end
                        end
                    end)
                end)

                return element
            end

            -- 7. COLOR PICKER FACTORY
            function SectionMethods:CreateColorPicker(cCfg)
                local name = cCfg.Name or "Color Pipeline"
                local current = cCfg.Color or Color3.fromRGB(255, 255, 255)
                local cb = cCfg.Callback

                local element = UI.Frame(sectionContainer, { Bg = Color3.fromRGB(0,0,0), Size = UDim2.new(1, 0, 0, 32) })
                element.ClipsDescendants = true
                element.BackgroundTransparency = 1

                local label = UI.TextLabel(element, { Text = name, Size = 13, FrameSize = UDim2.new(0.6, 0, 0, 32) })
                
                local swatch = UI.Frame(element, { Bg = current, Size = UDim2.new(0, 40, 0, 22), Pos = UDim2.new(1, -44, 0, 5) })
                UI.Border(swatch, Theme.Border)
                UI.Corner(swatch, 4)
                
                local trigger = UI.Button(swatch, {})
                local expanded = false

                -- Secondary Canvas Generation
                local canvasBox = UI.Frame(element, { Bg = Theme.Surface, Size = UDim2.new(1, -8, 0, 110), Pos = UDim2.new(0, 4, 0, 36) })
                UI.Border(canvasBox, Theme.Border)
                UI.Corner(canvasBox, 4)

                local svMap = UI.Frame(canvasBox, { Bg = Color3.fromHSV(0, 1, 1), Size = UDim2.new(0, 120, 0, 90), Pos = UDim2.new(0, 10, 0, 10) })
                local svWhite = Instance.new("ImageLabel")
                svWhite.Size = UDim2.new(1, 0, 1, 0)
                svWhite.Image = "rbxassetid://4155801252" -- SV Gradient
                svWhite.Parent = svMap
                
                local svBlack = Instance.new("ImageLabel")
                svBlack.Size = UDim2.new(1, 0, 1, 0)
                svBlack.Image = "rbxassetid://4155801390" -- Black blending layout asset map
                svBlack.Parent = svMap

                local hueBar = UI.Frame(canvasBox, { Bg = Color3.fromRGB(255,255,255), Size = UDim2.new(1, -160, 0, 16), Pos = UDim2.new(0, 145, 0, 10) })
                local hGrad = Instance.new("UIGradient")
                hGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
                })
                hGrad.Parent = hueBar

                local currentH, currentS, currentV = current:ToHSV()

                local function RecomputeColor()
                    local finalColor = Color3.fromHSV(currentH, currentS, currentV)
                    swatch.BackgroundColor3 = finalColor
                    svMap.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
                    if cb then pcall(cb, finalColor) end
                end

                trigger.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    element.Size = expanded and UDim2.new(1, 0, 0, 156) or UDim2.new(1, 0, 0, 32)
                end)

                -- Fast tracking pointer interactions seamlessly detached 
                BindDragLogic(svMap, function(input)
                    local x = math.clamp((input.Position.X - svMap.AbsolutePosition.X) / svMap.AbsoluteSize.X, 0, 1)
                    local y = math.clamp(1 - ((input.Position.Y - svMap.AbsolutePosition.Y) / svMap.AbsoluteSize.Y), 0, 1)
                    currentS = x
                    currentV = y
                    RecomputeColor()
                end)

                BindDragLogic(hueBar, function(input)
                    currentH = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    RecomputeColor()
                end)

                RecomputeColor()
                return element
            end

            -- 8. LABEL FACTORY
            function SectionMethods:CreateLabel(lCfg)
                local labelTxt = type(lCfg) == "table" and (lCfg.Name or lCfg.Text) or tostring(lCfg)
                local element = UI.Frame(sectionContainer, { Bg = Color3.fromRGB(0,0,0), Size = UDim2.new(1, 0, 0, 28) })
                element.BackgroundTransparency = 1
                UI.TextLabel(element, { Text = labelTxt, Color = Theme.TextGrey, Size = 13 })
                return element
            end

            return SectionMethods
        end

        return SectionAPI
    end

    return WindowAPI
end

return LuxwareUI
