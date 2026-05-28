-- [[ LuxwareUI Library | Professional UI Framework ]] --
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Luxware = {}
Luxware.__index = Luxware

local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Panel = Color3.fromRGB(25, 25, 25),
    Surface = Color3.fromRGB(30, 30, 30),
    SurfaceLight = Color3.fromRGB(50, 50, 50),
    Border = Color3.fromRGB(40, 40, 40),
    Text = Color3.fromRGB(255, 255, 255),
    MutedText = Color3.fromRGB(180, 180, 180),
    SoftText = Color3.fromRGB(200, 200, 200),
    DimText = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(100, 100, 255),
    Success = Color3.fromRGB(50, 255, 50),
    Error = Color3.fromRGB(255, 50, 50),
    ToggleOn = Color3.fromRGB(100, 255, 100),
    ToggleOff = Color3.fromRGB(60, 60, 60),
}

local DEFAULT_KEY_PROMPT = "🔑 Enter Key To Access The Script"
local TWEEN_FAST = TweenInfo.new(0.1)
local TWEEN_DEFAULT = TweenInfo.new(0.2)
local TWEEN_FADE = TweenInfo.new(0.3)
local TWEEN_DRAG = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

-- [ Protection & Parent Setup ]
local parentTarget = nil
pcall(function() parentTarget = CoreGui end)
if not parentTarget then parentTarget = LocalPlayer:WaitForChild("PlayerGui") end

-- [ Utility Functions ]
local function CreateUIElement(className, properties)
    local el = Instance.new(className)
    for k, v in pairs(properties) do el[k] = v end
    return el
end

local function IsPointerInput(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function IsPointerMovement(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function TrackConnection(registerConnection, signal, callback)
    local connection = signal:Connect(callback)
    if registerConnection then registerConnection(connection) end
    return connection
end

local function PlayTween(object, tweenInfo, properties)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function RunCallback(callback, ...)
    if callback then callback(...) end
end

local function AddCorner(parent, radius)
    return CreateUIElement("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 6)})
end

local function AddPillCorner(parent)
    return CreateUIElement("UICorner", {Parent = parent, CornerRadius = UDim.new(1, 0)})
end

local function AddStroke(parent, color, thickness)
    return CreateUIElement("UIStroke", {Parent = parent, Color = color or Theme.Border, Thickness = thickness or 1})
end

local function CreateControlFrame(parent, height)
    local frame = CreateUIElement("Frame", {
        Parent = parent,
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, height or 35)
    })
    AddCorner(frame)
    return frame
end

local function CreateControlButton(parent, height)
    local button = CreateUIElement("TextButton", {
        Parent = parent,
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, height or 35),
        Text = "",
        AutoButtonColor = false
    })
    AddCorner(button)
    return button
end

local function CreateControlLabel(parent, text, rightPadding)
    return CreateUIElement("TextLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -(rightPadding or 10), 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
end

local function MakeDraggable(topbarobject, object, registerConnection)
    local dragging, dragInput, dragStart, startPosition

    TrackConnection(registerConnection, topbarobject.InputBegan, function(input)
        if IsPointerInput(input) then
            dragging = true
            dragStart = input.Position
            startPosition = object.Position
            TrackConnection(registerConnection, input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    TrackConnection(registerConnection, topbarobject.InputChanged, function(input)
        if IsPointerMovement(input) then dragInput = input end
    end)

    TrackConnection(registerConnection, UserInputService.InputChanged, function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            PlayTween(object, TWEEN_DRAG, {
                Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
            })
        end
    end)
end

-- [ Main Library Initiation ]
function Luxware:CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or "LuxwareUI"
    local UseKeySystem = options.KeySystem or false
    local ExpectedKey = options.Key or "LUXWARE-TEST"
    local GetKeyLink = options.KeyLink or "https://discord.gg/yourlink"
    local connections = {}
    local destroyed = false
    local LuxGUI

    local function registerConnection(connection)
        table.insert(connections, connection)
        return connection
    end

    local function isInterfaceAlive()
        return not destroyed and LuxGUI and LuxGUI.Parent ~= nil
    end

    LuxGUI = CreateUIElement("ScreenGui", {Name = "LuxwareUI", Parent = parentTarget, ResetOnSpawn = false})
    
    -- Expose destroy method
    function Luxware:Destroy()
        if destroyed then return end
        destroyed = true

        for _, connection in ipairs(connections) do
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end
        table.clear(connections)

        if LuxGUI then LuxGUI:Destroy() end
    end

    -- [ Key System UI (Matches 1000106352.jpg) ]
    local KeyFrame = CreateUIElement("Frame", {
        Name = "KeyFrame", Parent = LuxGUI, BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -175, 0.5, -125), Size = UDim2.new(0, 350, 0, 250),
        Visible = UseKeySystem, Active = true
    })
    AddCorner(KeyFrame, 8)
    AddStroke(KeyFrame)
    MakeDraggable(KeyFrame, KeyFrame, registerConnection)

    local KeyTitle = CreateUIElement("TextLabel", {
        Parent = KeyFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 15),
        Size = UDim2.new(1, 0, 0, 25), Font = Enum.Font.GothamBold, Text = "Key System",
        TextColor3 = Theme.Text, TextSize = 18
    })
    local CloseKey = CreateUIElement("TextButton", {
        Parent = KeyFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0, 10),
        Size = UDim2.new(0, 20, 0, 20), Font = Enum.Font.GothamBold, Text = "X",
        TextColor3 = Theme.DimText, TextSize = 16
    })
    registerConnection(CloseKey.MouseButton1Click:Connect(function() Luxware:Destroy() end))

    local KeySub = CreateUIElement("TextLabel", {
        Parent = KeyFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.Gotham, Text = DEFAULT_KEY_PROMPT,
        TextColor3 = Theme.MutedText, TextSize = 13
    })

    local KeyBox = CreateUIElement("TextBox", {
        Parent = KeyFrame, BackgroundColor3 = Theme.Surface, Position = UDim2.new(0.5, -140, 0, 90),
        Size = UDim2.new(0, 280, 0, 45), Font = Enum.Font.Gotham, PlaceholderText = "Enter Key...",
        Text = "", TextColor3 = Theme.Text, TextSize = 14
    })
    AddCorner(KeyBox)

    local GetKeyBtn = CreateUIElement("TextButton", {
        Parent = KeyFrame, BackgroundColor3 = Theme.Surface, Position = UDim2.new(0.5, -140, 0, 155),
        Size = UDim2.new(0, 135, 0, 40), Font = Enum.Font.Gotham, Text = "Get Key", TextColor3 = Theme.Text, TextSize = 14
    })
    AddCorner(GetKeyBtn)

    local CheckKeyBtn = CreateUIElement("TextButton", {
        Parent = KeyFrame, BackgroundColor3 = Theme.Surface, Position = UDim2.new(0.5, 5, 0, 155),
        Size = UDim2.new(0, 135, 0, 40), Font = Enum.Font.Gotham, Text = "Check Key", TextColor3 = Theme.Text, TextSize = 14
    })
    AddCorner(CheckKeyBtn)

    -- [ Main UI Initialization ]
    local MainFrame = CreateUIElement("Frame", {
        Name = "MainFrame", Parent = LuxGUI, BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -250, 0.5, -175), Size = UDim2.new(0, 500, 0, 350),
        Visible = not UseKeySystem, Active = true, ClipsDescendants = true
    })
    AddCorner(MainFrame, 8)
    AddStroke(MainFrame)
    MakeDraggable(MainFrame, MainFrame, registerConnection)

    local LeftPanel = CreateUIElement("Frame", {
        Parent = MainFrame, BackgroundColor3 = Theme.Panel, Size = UDim2.new(0, 130, 1, 0), BorderSizePixel = 0
    })
    local Title = CreateUIElement("TextLabel", {
        Parent = LeftPanel, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0,0,0,5),
        Font = Enum.Font.GothamBold, Text = WindowName, TextColor3 = Theme.Text, TextSize = 16
    })
    local TabContainer = CreateUIElement("ScrollingFrame", {
        Parent = LeftPanel, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -50), ScrollBarThickness = 0
    })
    CreateUIElement("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})

    local RightPanel = CreateUIElement("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 140, 0, 10), Size = UDim2.new(1, -150, 1, -20)
    })

    -- Toggle Logic (Right Shift)
    local WindowIsVisible = not UseKeySystem
    function Luxware:SetVisible(state)
        WindowIsVisible = state
        MainFrame.Visible = state
    end

    registerConnection(UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then
            if UseKeySystem and KeyFrame.Visible then return end -- Don't toggle if key sys is active
            Luxware:SetVisible(not WindowIsVisible)
        end
    end))

    -- Key System Functions
    registerConnection(GetKeyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(GetKeyLink) end)
        KeySub.Text = "Link copied to clipboard!"
        task.wait(2)
        if isInterfaceAlive() then KeySub.Text = DEFAULT_KEY_PROMPT end
    end))

    registerConnection(CheckKeyBtn.MouseButton1Click:Connect(function()
        if KeyBox.Text == ExpectedKey then
            KeySub.Text = "Key Verified!"
            KeySub.TextColor3 = Theme.Success
            task.wait(0.5)
            if isInterfaceAlive() then
                KeyFrame.Visible = false
                Luxware:SetVisible(true)
            end
        else
            KeySub.Text = "Invalid Key!"
            KeySub.TextColor3 = Theme.Error
            task.wait(1.5)
            if isInterfaceAlive() then
                KeySub.Text = DEFAULT_KEY_PROMPT
                KeySub.TextColor3 = Theme.MutedText
            end
        end
    end))

    -- Notifier
    local NoteContainer = CreateUIElement("Frame", {
        Parent = LuxGUI, BackgroundTransparency = 1, Position = UDim2.new(1, -220, 1, -150), Size = UDim2.new(0, 200, 0, 130)
    })
    CreateUIElement("UIListLayout", {Parent = NoteContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), VerticalAlignment = Enum.VerticalAlignment.Bottom})

    function Luxware:Notify(data)
        data = data or {}

        local nFrame = CreateUIElement("Frame", {
            Parent = NoteContainer, BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1
        })
        AddCorner(nFrame)
        local nTitle = CreateUIElement("TextLabel", {
            Parent = nFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold, Text = data.Title, TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1
        })
        local nContent = CreateUIElement("TextLabel", {
            Parent = nFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -20, 0, 30),
            Font = Enum.Font.Gotham, Text = data.Content, TextColor3 = Theme.SoftText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextTransparency = 1
        })
        PlayTween(nFrame, TWEEN_FADE, {BackgroundTransparency = 0})
        PlayTween(nTitle, TWEEN_FADE, {TextTransparency = 0})
        PlayTween(nContent, TWEEN_FADE, {TextTransparency = 0})
        task.delay(data.Duration or 3, function()
            if not isInterfaceAlive() or not nFrame.Parent then return end
            PlayTween(nFrame, TWEEN_FADE, {BackgroundTransparency = 1})
            PlayTween(nTitle, TWEEN_FADE, {TextTransparency = 1})
            PlayTween(nContent, TWEEN_FADE, {TextTransparency = 1})
            task.wait(0.3)
            if nFrame.Parent then nFrame:Destroy() end
        end)
    end

    -- Tab System
    local tabs = {}
    local firstTab = true

    function Luxware:CreateTab(tabName)
        local TabBtn = CreateUIElement("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.Gotham, Text = tabName, TextColor3 = Theme.DimText, TextSize = 14
        })
        local Page = CreateUIElement("ScrollingFrame", {
            Parent = RightPanel, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2, Visible = firstTab
        })
        local PageLayout = CreateUIElement("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        
        registerConnection(PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end))

        if firstTab then TabBtn.TextColor3 = Theme.Text; firstTab = false end
        table.insert(tabs, {Btn = TabBtn, Pg = Page})

        registerConnection(TabBtn.MouseButton1Click:Connect(function()
            for _, t in ipairs(tabs) do
                t.Pg.Visible = false
                PlayTween(t.Btn, TWEEN_DEFAULT, {TextColor3 = Theme.DimText})
            end
            Page.Visible = true
            PlayTween(TabBtn, TWEEN_DEFAULT, {TextColor3 = Theme.Text})
        end))

        local TabElements = {}

        function TabElements:CreateSection(name)
            local Sec = CreateUIElement("TextLabel", {
                Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.GothamBold, Text = name, TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function TabElements:CreateLabel(text)
            local Lbl = CreateUIElement("TextLabel", {
                Parent = Page, BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, 0, 0, 35),
                Font = Enum.Font.Gotham, Text = "  " .. text, TextColor3 = Theme.SoftText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
            AddCorner(Lbl)
        end

        function TabElements:CreateButton(opts)
            opts = opts or {}

            local Btn = CreateUIElement("TextButton", {
                Parent = Page, BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, 0, 0, 35),
                Font = Enum.Font.Gotham, Text = opts.Name, TextColor3 = Theme.Text, TextSize = 13
            })
            AddCorner(Btn)
            registerConnection(Btn.MouseButton1Click:Connect(function() RunCallback(opts.Callback) end))
        end

        function TabElements:CreateToggle(opts)
            opts = opts or {}

            local state = opts.CurrentValue or false
            local TglFrame = CreateControlButton(Page)
            CreateControlLabel(TglFrame, opts.Name, 50)
            local TglBox = CreateUIElement("Frame", {
                Parent = TglFrame, BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
                Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10)
            })
            AddPillCorner(TglBox)
            local TglCircle = CreateUIElement("Frame", {
                Parent = TglBox, BackgroundColor3 = Theme.Text, Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            })
            AddPillCorner(TglCircle)

            registerConnection(TglFrame.MouseButton1Click:Connect(function()
                state = not state
                PlayTween(TglBox, TWEEN_DEFAULT, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff})
                PlayTween(TglCircle, TWEEN_DEFAULT, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                RunCallback(opts.Callback, state)
            end))
        end

        function TabElements:CreateSlider(opts)
            opts = opts or {}

            local val = opts.CurrentValue or opts.Range[1]
            local SldFrame = CreateControlFrame(Page, 50)
            CreateUIElement("TextLabel", {
                Parent = SldFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 25), Position = UDim2.new(0, 10, 0, 0),
                Font = Enum.Font.Gotham, Text = opts.Name, TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
            local ValTxt = CreateUIElement("TextLabel", {
                Parent = SldFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 50, 0, 25), Position = UDim2.new(1, -60, 0, 0),
                Font = Enum.Font.Gotham, Text = tostring(val), TextColor3 = Theme.SoftText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right
            })
            local SldBG = CreateUIElement("TextButton", {
                Parent = SldFrame, BackgroundColor3 = Theme.SurfaceLight, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 35), Text = ""
            })
            AddPillCorner(SldBG)
            local SldFill = CreateUIElement("Frame", {
                Parent = SldBG, BackgroundColor3 = Theme.Accent, Size = UDim2.new((val - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1, 0)
            })
            AddPillCorner(SldFill)

            local dragging = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - SldBG.AbsolutePosition.X) / SldBG.AbsoluteSize.X, 0, 1)
                val = math.floor(((pos * (opts.Range[2] - opts.Range[1])) + opts.Range[1]) / opts.Increment + 0.5) * opts.Increment
                val = math.clamp(val, opts.Range[1], opts.Range[2])
                PlayTween(SldFill, TWEEN_FAST, {Size = UDim2.new((val - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1, 0)})
                ValTxt.Text = tostring(val)
                RunCallback(opts.Callback, val)
            end

            registerConnection(SldBG.InputBegan:Connect(function(input)
                if IsPointerInput(input) then
                    dragging = true; updateSlider(input)
                end
            end))
            registerConnection(UserInputService.InputEnded:Connect(function(input)
                if IsPointerInput(input) then dragging = false end
            end))
            registerConnection(UserInputService.InputChanged:Connect(function(input)
                if dragging and IsPointerMovement(input) then updateSlider(input) end
            end))
        end

        function TabElements:CreateKeybind(opts)
            opts = opts or {}

            local currentKey = opts.CurrentKey or Enum.KeyCode.E
            local KbFrame = CreateControlFrame(Page)
            CreateControlLabel(KbFrame, opts.Name, 100)
            local KbBtn = CreateUIElement("TextButton", {
                Parent = KbFrame, BackgroundColor3 = Theme.SurfaceLight, Size = UDim2.new(0, 80, 0, 25),
                Position = UDim2.new(1, -90, 0.5, -12.5), Font = Enum.Font.GothamBold, Text = currentKey.Name, TextColor3 = Theme.Text, TextSize = 12
            })
            AddCorner(KbBtn, 4)

            local binding = false
            registerConnection(KbBtn.MouseButton1Click:Connect(function()
                binding = true
                KbBtn.Text = "..."
            end))

            registerConnection(UserInputService.InputBegan:Connect(function(input)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    KbBtn.Text = currentKey.Name
                    binding = false
                elseif not binding and input.KeyCode == currentKey then
                    RunCallback(opts.Callback)
                end
            end))
        end

        function TabElements:CreateColorPicker(opts)
            opts = opts or {}

            local clr = opts.Color or Theme.Text
            local CpFrame = CreateControlFrame(Page)
            CreateControlLabel(CpFrame, opts.Name, 100)
            
            -- Simplified RGB Input for pro hubs
            local function makeBox(xPos, initialVal)
                local box = CreateUIElement("TextBox", {
                    Parent = CpFrame, BackgroundColor3 = Theme.SurfaceLight, Size = UDim2.new(0, 25, 0, 25),
                    Position = UDim2.new(1, xPos, 0.5, -12.5), Font = Enum.Font.Gotham, Text = tostring(math.floor(initialVal*255)),
                    TextColor3 = Theme.Text, TextSize = 12
                })
                AddCorner(box, 4)
                return box
            end

            local RBox = makeBox(-100, clr.R)
            local GBox = makeBox(-70, clr.G)
            local BBox = makeBox(-40, clr.B)

            local function updateColor()
                local r, g, b = tonumber(RBox.Text) or 255, tonumber(GBox.Text) or 255, tonumber(BBox.Text) or 255
                clr = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
                RunCallback(opts.Callback, clr)
            end

            registerConnection(RBox.FocusLost:Connect(updateColor))
            registerConnection(GBox.FocusLost:Connect(updateColor))
            registerConnection(BBox.FocusLost:Connect(updateColor))
        end

        return TabElements
    end

    return Luxware
end

return Luxware
