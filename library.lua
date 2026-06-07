local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CurrentCamera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")

local Rise = {
    Flags = {}, 
}
Rise.__index = Rise

local Theme = {
    Background = Color3.fromRGB(18, 18, 22),      
    Sidebar = Color3.fromRGB(14, 14, 17),      
    ElementBG = Color3.fromRGB(24, 24, 28),    
    ElementHover = Color3.fromRGB(32, 32, 38), 
    Text = Color3.fromRGB(245, 245, 245),      
    SubText = Color3.fromRGB(140, 140, 140),   
    Accent1 = Color3.fromRGB(0, 212, 255),    
    Accent2 = Color3.fromRGB(0, 102, 255),    
}

local TWEEN_SPEED = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local IsPC = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled

local hasFilesystem = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function" and type(makefolder) == "function"

local function Create(className, properties)
    local inst = Instance.new(className)
    pcall(function() inst.BorderSizePixel = 0 end)
    for k, v in pairs(properties) do inst[k] = v end
    return inst
end

local function ApplyCorner(parent, radius)
    return Create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 6)})
end

local function ApplyRiseGradient(parent)
    return Create("UIGradient", {
        Parent = parent,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent1),
            ColorSequenceKeypoint.new(1, Theme.Accent2)
        }),
        Rotation = 45
    })
end

local function PlayTween(object, props)
    local tween = TweenService:Create(object, TWEEN_SPEED, props)
    tween:Play()
    return tween
end

local function MakeDraggable(dragHandle, targetFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function AddHoverFeedback(button)
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function() PlayTween(button, {BackgroundColor3 = Theme.ElementHover}) end)
    button.MouseLeave:Connect(function() PlayTween(button, {BackgroundColor3 = originalColor}) end)
end

local NotifyGui = Create("ScreenGui", {
    Name = "RiseNotifications", Parent = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui"), ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})
local NotifyLayout = Create("Frame", {
    Parent = NotifyGui, BackgroundTransparency = 1, Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(1, -320, 0, -20)
})
Create("UIListLayout", {
    Parent = NotifyLayout, Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Bottom
})

function Rise:Notification(opts)
    local Title = opts.Title or "Notification"
    local Desc = opts.Description or ""
    local Duration = opts.Duration or 3

    local NotifFrame = Create("Frame", {
        Parent = NotifyLayout, BackgroundColor3 = Theme.ElementBG, Size = UDim2.new(0, 280, 0, 60), Position = UDim2.new(1, 300, 0, 0), BackgroundTransparency = 1
    })
    ApplyCorner(NotifFrame, 6)
    
    local AccentLine = Create("Frame", {
        Parent = NotifFrame, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 3, 1, -16), Position = UDim2.new(0, 8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1
    })
    ApplyCorner(AccentLine, 4)
    ApplyRiseGradient(AccentLine)

    local TxtTitle = Create("TextLabel", {
        Parent = NotifFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 10), Size = UDim2.new(1, -30, 0, 16),
        Text = Title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1
    })
    local TxtDesc = Create("TextLabel", {
        Parent = NotifFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 28), Size = UDim2.new(1, -30, 0, 14),
        Text = Desc, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, TextWrapped = true
    })

    PlayTween(NotifFrame, {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0)})
    PlayTween(AccentLine, {BackgroundTransparency = 0})
    PlayTween(TxtTitle, {TextTransparency = 0})
    PlayTween(TxtDesc, {TextTransparency = 0})

    task.delay(Duration, function()
        PlayTween(NotifFrame, {BackgroundTransparency = 1, Position = UDim2.new(1, 300, 0, 0)})
        PlayTween(AccentLine, {BackgroundTransparency = 1})
        PlayTween(TxtTitle, {TextTransparency = 1})
        PlayTween(TxtDesc, {TextTransparency = 1})
        task.wait(0.3)
        NotifFrame:Destroy()
    end)
end

function Rise:SaveConfig(filename)
    if not hasFilesystem then return end
    pcall(function()
        if not isfolder("RiseConfigs") then makefolder("RiseConfigs") end
        local data = {}
        for flag, element in pairs(Rise.Flags) do
            if element.Type == "ColorPicker" then
                data[flag] = {R = element.Color.R, G = element.Color.G, B = element.Color.B}
            else
                data[flag] = element.CurrentValue
            end
        end
        writefile("RiseConfigs/" .. filename .. ".json", HttpService:JSONEncode(data))
        Rise:Notification({Title = "System", Description = "Configuration saved successfully.", Duration = 2})
    end)
end

function Rise:LoadConfig(filename)
    if not hasFilesystem then return end
    pcall(function()
        local path = "RiseConfigs/" .. filename .. ".json"
        if isfile(path) then
            local data = HttpService:JSONDecode(readfile(path))
            for flag, value in pairs(data) do
                if Rise.Flags[flag] then
                    if Rise.Flags[flag].Type == "ColorPicker" then
                        Rise.Flags[flag]:Set(Color3.new(value.R, value.G, value.B))
                    else
                        Rise.Flags[flag]:Set(value)
                    end
                end
            end
            Rise:Notification({Title = "System", Description = "Configuration loaded successfully.", Duration = 2})
        end
    end)
end

function Rise:CreateWindow(options)
    local WindowName = options.Name or "Rise"
    local UseKey = options.KeySystem or false
    local ExpectedKey = options.Key or ""
    local KeyLink = options.KeyLink or ""

    local TargetUI = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

    local ScreenGui = Create("ScreenGui", {
        Name = "RisePremium", Parent = TargetUI, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local LoadingFrame = Create("Frame", {
        Parent = ScreenGui, BackgroundColor3 = Theme.Background, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 300, 0, 150), ZIndex = 200
    })
    ApplyCorner(LoadingFrame, 8)
    
    local LoadingTitle = Create("TextLabel", {
        Parent = LoadingFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = WindowName,
        Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.Text, TextTransparency = 1
    })
    
    PlayTween(LoadingTitle, {TextTransparency = 0})
    task.wait(1.5)
    PlayTween(LoadingTitle, {TextTransparency = 1})
    PlayTween(LoadingFrame, {BackgroundTransparency = 1})
    task.wait(0.3)
    LoadingFrame:Destroy()

    local WindowFrame = Create("Frame", {
        Parent = ScreenGui, BackgroundColor3 = Theme.Background, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, math.min(650, CurrentCamera.ViewportSize.X - 20), 0, math.min(420, CurrentCamera.ViewportSize.Y - 20)),
        ClipsDescendants = true, Visible = not UseKey, BackgroundTransparency = 1
    })
    ApplyCorner(WindowFrame, 8)

    if not UseKey then PlayTween(WindowFrame, {BackgroundTransparency = 0}) end

    local OpenBtn = Create("TextButton", {
        Parent = ScreenGui, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 45, 0, 45),
        Position = UDim2.new(0, 20, 0, 20), Text = "RS", Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = Theme.Text, Visible = false, AutoButtonColor = false
    })
    ApplyCorner(OpenBtn, 100)
    
    local isDraggingOpenBtn = false
    local openDragStartPos = nil
    local openFrameStartPos = nil
    local openBtnMoved = false

    OpenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingOpenBtn = true
            openBtnMoved = false
            openDragStartPos = input.Position
            openFrameStartPos = OpenBtn.Position
            
            local releaseConnection
            releaseConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDraggingOpenBtn = false
                    releaseConnection:Disconnect()
                    if not openBtnMoved then
                        WindowFrame.Visible = true
                        OpenBtn.Visible = false
                    end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDraggingOpenBtn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - openDragStartPos
            if delta.Magnitude > 5 then
                openBtnMoved = true
            end
            OpenBtn.Position = UDim2.new(
                openFrameStartPos.X.Scale, openFrameStartPos.X.Offset + delta.X,
                openFrameStartPos.Y.Scale, openFrameStartPos.Y.Offset + delta.Y
            )
        end
    end)

    local function ToggleUI(state)
        WindowFrame.Visible = state
        if not (UseKey and ScreenGui:FindFirstChild("KeyWindow")) then OpenBtn.Visible = not state end
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then
            if UseKey and ScreenGui:FindFirstChild("KeyWindow") then return end
            ToggleUI(not WindowFrame.Visible)
        end
    end)

    local Topbar = Create("Frame", {Parent = WindowFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35), ZIndex = 10})
    MakeDraggable(Topbar, WindowFrame)

    Create("TextLabel", {
        Parent = Topbar, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0, 250, 1, 0),
        Text = WindowName, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left
    })

    local MinBtn = Create("TextButton", {
        Parent = Topbar, BackgroundTransparency = 1, Position = UDim2.new(1, -70, 0, 0), Size = UDim2.new(0, 35, 1, 0),
        Text = "-", Font = Enum.Font.GothamMedium, TextSize = 18, TextColor3 = Theme.SubText
    })
    MinBtn.Activated:Connect(function() ToggleUI(false) end)

    local CloseBtn = Create("TextButton", {
        Parent = Topbar, BackgroundTransparency = 1, Position = UDim2.new(1, -35, 0, 0), Size = UDim2.new(0, 35, 1, 0),
        Text = "X", Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.SubText
    })
    CloseBtn.Activated:Connect(function() ScreenGui:Destroy() end)
    if IsPC then CloseBtn.Visible = false MinBtn.Position = UDim2.new(1, -35, 0, 0) end

    local Sidebar = Create("Frame", {
        Parent = WindowFrame, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 160, 1, 0), Position = UDim2.new(0, 0, 0, 0)
    })
    ApplyCorner(Sidebar, 8)
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 15, 1, 0), Position = UDim2.new(1, -15, 0, 0)})

    local ProfileFrame = Create("Frame", {
        Parent = Sidebar, BackgroundColor3 = Theme.ElementBG, Size = UDim2.new(1, -16, 0, 42), Position = UDim2.new(0, 8, 0, 45)
    })
    ApplyCorner(ProfileFrame, 6)

    local Avatar = Create("ImageLabel", {
        Parent = ProfileFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 8, 0.5, -12),
        Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    })
    ApplyCorner(Avatar, 100)

    Create("TextLabel", {
        Parent = ProfileFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 38, 0, 7), Size = UDim2.new(1, -42, 0, 14),
        Text = LocalPlayer.DisplayName, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("TextLabel", {
        Parent = ProfileFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 38, 0, 21), Size = UDim2.new(1, -42, 0, 12),
        Text = "@" .. LocalPlayer.Name, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left
    })

    local TabScroll = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -100), Position = UDim2.new(0, 0, 0, 95), ScrollBarThickness = 0
    })
    Create("UIListLayout", {Parent = TabScroll, Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center})

    local ContentContainer = Create("Frame", {
        Parent = WindowFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -165, 1, -40), Position = UDim2.new(0, 165, 0, 40)
    })

    if UseKey then
        local KeyWindow = Create("Frame", {
            Name = "KeyWindow", Parent = ScreenGui, BackgroundColor3 = Theme.Background, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 360, 0, 250), ZIndex = 100, BackgroundTransparency = 1
        })
        ApplyCorner(KeyWindow, 8)
        PlayTween(KeyWindow, {BackgroundTransparency = 0})

        local KeyTopbar = Create("Frame", {Parent = KeyWindow, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)})
        MakeDraggable(KeyTopbar, KeyWindow)
        local KeyClose = Create("TextButton", {
            Parent = KeyTopbar, BackgroundTransparency = 1, Position = UDim2.new(1, -35, 0, 0), Size = UDim2.new(0, 35, 1, 0), Text = "X", Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.SubText
        })
        KeyClose.Activated:Connect(function() ScreenGui:Destroy() end)
        if IsPC then KeyClose.Visible = false end

        Create("TextLabel", {
            Parent = KeyWindow, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 30),
            Text = "Key System", Font = Enum.Font.GothamMedium, TextSize = 20, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Center
        })

        local Subtitle = Create("TextLabel", {
            Parent = KeyWindow, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 58), Size = UDim2.new(1, 0, 0, 20),
            Text = "Enter Key To Access", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Center
        })

        local KeyInput = Create("TextBox", {
            Parent = KeyWindow, BackgroundColor3 = Theme.Sidebar, Position = UDim2.new(0, 25, 0, 100), Size = UDim2.new(1, -50, 0, 48),
            PlaceholderText = "Enter Key...", Text = "", Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText
        })
        ApplyCorner(KeyInput, 6)

        local GetBtn = Create("TextButton", {
            Parent = KeyWindow, BackgroundColor3 = Theme.Sidebar, Position = UDim2.new(0, 25, 0, 170), Size = UDim2.new(0, 145, 0, 40),
            Text = "Get Key", Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text, AutoButtonColor = false
        })
        ApplyCorner(GetBtn, 6) AddHoverFeedback(GetBtn)

        local CheckBtn = Create("TextButton", {
            Parent = KeyWindow, BackgroundColor3 = Theme.Sidebar, Position = UDim2.new(1, -170, 0, 170), Size = UDim2.new(0, 145, 0, 40),
            Text = "Check Key", Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text, AutoButtonColor = false
        })
        ApplyCorner(CheckBtn, 6) AddHoverFeedback(CheckBtn)

        CheckBtn.Activated:Connect(function()
            if KeyInput.Text == ExpectedKey then
                Subtitle.Text = "Verified." Subtitle.TextColor3 = Theme.Text task.wait(0.4) 
                PlayTween(KeyWindow, {BackgroundTransparency = 1})
                task.wait(0.3)
                KeyWindow:Destroy() 
                PlayTween(WindowFrame, {BackgroundTransparency = 0})
                ToggleUI(true)
            else
                Subtitle.Text = "Invalid Key." task.wait(1.2) Subtitle.Text = "Enter Key To Access"
            end
        end)
        GetBtn.Activated:Connect(function() pcall(function() setclipboard(KeyLink) end) GetBtn.Text = "Copied!" task.wait(1.5) GetBtn.Text = "Get Key" end)
    end

    local function BuildElementsAPI(TargetParent, IsNested)
        local API = {}
        local WidthScale = IsNested and 1 or 1
        local WidthOffset = IsNested and -20 or 0
        local XPos = IsNested and 10 or 0

        local function CreateElementRow(name, desc)
            local RowFrame = Create("Frame", {
                Parent = TargetParent, BackgroundColor3 = IsNested and Theme.Sidebar or Theme.ElementBG, 
                Size = UDim2.new(WidthScale, WidthOffset, 0, 50), Position = UDim2.new(0, XPos, 0, 0), ClipsDescendants = true
            })
            ApplyCorner(RowFrame, 6)
            Create("TextLabel", {
                Parent = RowFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 8), Size = UDim2.new(1, -160, 0, 16),
                Text = name, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left
            })
            if desc then
                Create("TextLabel", {
                    Parent = RowFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 24), Size = UDim2.new(1, -160, 0, 14),
                    Text = desc, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            return RowFrame
        end

        function API:CreateSection(title)
            Create("TextLabel", {
                Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(WidthScale, WidthOffset, 0, 24), Position = UDim2.new(0, XPos, 0, 0),
                Text = title, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function API:CreateButton(opts)
            local Row = CreateElementRow(opts.Name, opts.Description)
            local Btn = Create("TextButton", {
                Parent = Row, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 130, 0, 30), Position = UDim2.new(1, -140, 0, 10), Text = opts.ButtonText or "Execute", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text, AutoButtonColor = false
            })
            ApplyCorner(Btn, 5) AddHoverFeedback(Btn)
            Btn.Activated:Connect(function()
                if opts.Callback then pcall(opts.Callback) end
                PlayTween(Btn, {BackgroundColor3 = Theme.Accent2})
                task.wait(0.15)
                PlayTween(Btn, {BackgroundColor3 = Theme.Sidebar})
            end)
        end

        function API:CreateToggle(opts)
            local Row = CreateElementRow(opts.Name, opts.Description)
            opts.CurrentValue = opts.CurrentValue or false
            opts.Type = "Toggle"
            if opts.Flag then Rise.Flags[opts.Flag] = opts end

            local Switch = Create("TextButton", {
                Parent = Row, BackgroundColor3 = opts.CurrentValue and Color3.fromRGB(255, 255, 255) or Theme.Sidebar, Size = UDim2.new(0, 38, 0, 20), Position = UDim2.new(1, -52, 0, 15), Text = "", AutoButtonColor = false
            })
            ApplyCorner(Switch, 10)
            ApplyRiseGradient(Switch)
            
            local Ball = Create("Frame", {
                Parent = Switch, BackgroundColor3 = opts.CurrentValue and Theme.Background or Theme.SubText, Size = UDim2.new(0, 12, 0, 12), Position = opts.CurrentValue and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            })
            ApplyCorner(Ball, 100)

            local function SetState(state)
                opts.CurrentValue = state
                PlayTween(Switch, {BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Theme.Sidebar})
                PlayTween(Ball, {Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = state and Theme.Background or Theme.SubText})
                if opts.Callback then pcall(opts.Callback, state) end
            end

            function opts:Set(state) SetState(state) end
            Switch.Activated:Connect(function() SetState(not opts.CurrentValue) end)
            return opts
        end

        function API:CreateSlider(opts)
            local hasDesc = opts.Description ~= nil and opts.Description ~= ""
            local Row = CreateElementRow(opts.Name, opts.Description)
            Row.Size = UDim2.new(WidthScale, WidthOffset, 0, hasDesc and 60 or 50)
            opts.CurrentValue = math.clamp(opts.CurrentValue or opts.Range[1], opts.Range[1], opts.Range[2])
            opts.Type = "Slider"
            if opts.Flag then Rise.Flags[opts.Flag] = opts end

            local ValText = Create("TextLabel", {
                Parent = Row, BackgroundTransparency = 1, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0, hasDesc and 10 or 6),
                Text = tostring(opts.CurrentValue), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Right
            })

            local Track = Create("TextButton", {
                Parent = Row, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, hasDesc and 44 or 34), Text = "", AutoButtonColor = false
            })
            ApplyCorner(Track, 10)
            
            local Fill = Create("Frame", {
                Parent = Track, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(math.clamp((opts.CurrentValue - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1), 0, 1, 0)
            })
            ApplyCorner(Fill, 10)
            ApplyRiseGradient(Fill)

            local dragging = false
            local function update(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local val = math.clamp(math.floor(((opts.Range[1] + (pos * (opts.Range[2] - opts.Range[1]))) - opts.Range[1]) / opts.Increment + 0.5) * opts.Increment + opts.Range[1], opts.Range[1], opts.Range[2])
                PlayTween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}) ValText.Text = tostring(val)
                opts.CurrentValue = val
                if opts.Callback then pcall(opts.Callback, val) end
            end

            Track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true update(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)

            function opts:Set(val)
                opts.CurrentValue = math.clamp(val, opts.Range[1], opts.Range[2])
                local pos = math.clamp((opts.CurrentValue - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1)
                PlayTween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}) ValText.Text = tostring(opts.CurrentValue)
                if opts.Callback then pcall(opts.Callback, opts.CurrentValue) end
            end
            return opts
        end

        function API:CreateDropdown(opts)
            local Row = CreateElementRow(opts.Name, opts.Description)
            opts.Options = opts.Options or {}
            opts.CurrentValue = opts.CurrentValue or opts.Options[1]
            opts.Type = "Dropdown"
            if opts.Flag then Rise.Flags[opts.Flag] = opts end
            local open = false

            local MainBox = Create("TextButton", {
                Parent = Row, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 130, 0, 30), Position = UDim2.new(1, -140, 0, 10), Text = "", AutoButtonColor = false
            })
            ApplyCorner(MainBox, 5) AddHoverFeedback(MainBox)

            local DisplayText = Create("TextLabel", {
                Parent = MainBox, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -25, 1, 0),
                Text = tostring(opts.CurrentValue), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left
            })
            local Arrow = Create("TextLabel", {
                Parent = MainBox, BackgroundTransparency = 1, Position = UDim2.new(1, -20, 0, 0), Size = UDim2.new(0, 10, 1, 0), Text = "v", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText
            })

            local DropContainer = Create("Frame", {
                Parent = Row, BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 0), Position = UDim2.new(0, 14, 0, 50), ClipsDescendants = true
            })
            local ListLayout = Create("UIListLayout", {Parent = DropContainer, Padding = UDim.new(0, 4)})

            local function SetupOptions()
                for _, child in ipairs(DropContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                for _, option in ipairs(opts.Options) do
                    local OptBtn = Create("TextButton", {
                        Parent = DropContainer, BackgroundColor3 = (option == opts.CurrentValue) and Theme.ElementHover or Theme.Sidebar, Size = UDim2.new(1, 0, 0, 28), Text = "  " .. option,
                        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
                    })
                    ApplyCorner(OptBtn, 4) AddHoverFeedback(OptBtn)
                    OptBtn.Activated:Connect(function()
                        opts.CurrentValue = option
                        DisplayText.Text = option open = false
                        PlayTween(Row, {Size = UDim2.new(WidthScale, WidthOffset, 0, 50)})
                        PlayTween(DropContainer, {Size = UDim2.new(1, -28, 0, 0)})
                        PlayTween(Arrow, {Rotation = 0})
                        for _, c in ipairs(DropContainer:GetChildren()) do if c:IsA("TextButton") then c.BackgroundColor3 = Theme.Sidebar end end
                        OptBtn.BackgroundColor3 = Theme.ElementHover
                        if opts.Callback then pcall(opts.Callback, option) end
                    end)
                end
            end
            SetupOptions()

            MainBox.Activated:Connect(function()
                open = not open
                local targetHeight = open and (50 + ListLayout.AbsoluteContentSize.Y + 10) or 50
                PlayTween(Row, {Size = UDim2.new(WidthScale, WidthOffset, 0, targetHeight)})
                PlayTween(DropContainer, {Size = UDim2.new(1, -28, 0, open and ListLayout.AbsoluteContentSize.Y or 0)})
                PlayTween(Arrow, {Rotation = open and 180 or 0})
            end)

            function opts:Set(val)
                opts.CurrentValue = val
                DisplayText.Text = tostring(val)
                if opts.Callback then pcall(opts.Callback, val) end
            end
            function opts:Refresh(newList)
                opts.Options = newList
                SetupOptions()
            end
            return opts
        end

        function API:CreateColorPicker(opts)
            local Row = CreateElementRow(opts.Name, opts.Description)
            opts.Color = opts.Color or Color3.fromRGB(255, 255, 255)
            opts.Type = "ColorPicker"
            if opts.Flag then Rise.Flags[opts.Flag] = opts end

            local ChannelBlock = Create("TextButton", {
                Parent = Row, BackgroundColor3 = opts.Color, Size = UDim2.new(0, 50, 0, 26), Position = UDim2.new(1, -64, 0, 12), Text = "", AutoButtonColor = false
            })
            ApplyCorner(ChannelBlock, 5)

            local OpenState = false
            local ExpandPanel = Create("Frame", {
                Parent = Row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 120), Position = UDim2.new(0, 0, 0, 50), ClipsDescendants = true
            })

            local HueSlider = Create("TextButton", {
                Parent = ExpandPanel, BackgroundColor3 = Theme.Text, Size = UDim2.new(1, -28, 0, 15), Position = UDim2.new(0, 14, 0, 10), Text = "", AutoButtonColor = false
            })
            ApplyCorner(HueSlider, 4)
            Create("UIGradient", {
                Parent = HueSlider,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
            })
            
            local HueCursor = Create("Frame", {
                Parent = HueSlider, BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
                Size = UDim2.new(0, 4, 1, 4), Position = UDim2.new(0, 0, 0.5, -2), AnchorPoint = Vector2.new(0.5, 0.5)
            })
            Create("UIStroke", {Parent = HueCursor, Color = Color3.fromRGB(0, 0, 0), Thickness = 1})

            local SVMap = Create("TextButton", {
                Parent = ExpandPanel, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(1, -28, 0, 70), Position = UDim2.new(0, 14, 0, 35), Text = "", AutoButtonColor = false
            })
            ApplyCorner(SVMap, 4)
            
            local HueOverlay = Create("Frame", {
                Parent = SVMap, BackgroundColor3 = Color3.fromRGB(255, 0, 0), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0
            })
            ApplyCorner(HueOverlay, 4)
            Create("UIGradient", {Parent = HueOverlay, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})})
            
            local ValOverlay = Create("Frame", {
                Parent = SVMap, BackgroundColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0
            })
            ApplyCorner(ValOverlay, 4)
            Create("UIGradient", {Parent = ValOverlay, Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})})
            
            local SVCursor = Create("Frame", {
                Parent = SVMap, BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
                Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 2
            })
            ApplyCorner(SVCursor, 100)
            Create("UIStroke", {Parent = SVCursor, Color = Color3.fromRGB(0, 0, 0), Thickness = 1})

            local h, s, v = opts.Color:ToHSV()

            local function UpdateColor()
                opts.Color = Color3.fromHSV(h, s, v)
                HueOverlay.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                ChannelBlock.BackgroundColor3 = opts.Color
                if opts.Callback then pcall(opts.Callback, opts.Color) end
            end

            local draggingHue, draggingSV = false, false
            
            local function UpdateHue(input)
                local percent = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                HueCursor.Position = UDim2.new(percent, 0, 0.5, 0)
                h = percent 
                UpdateColor()
            end
            
            local function UpdateSV(input)
                local px = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                local py = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                SVCursor.Position = UDim2.new(px, 0, py, 0)
                s = px 
                v = 1 - py 
                UpdateColor()
            end

            HueSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHue = true UpdateHue(input) end end)
            SVMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = true UpdateSV(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHue = false draggingSV = false end end)
            UserInputService.InputChanged:Connect(function(input) 
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if draggingHue then UpdateHue(input) elseif draggingSV then UpdateSV(input) end 
                end 
            end)

            ChannelBlock.Activated:Connect(function()
                OpenState = not OpenState
                PlayTween(Row, {Size = UDim2.new(WidthScale, WidthOffset, 0, OpenState and 180 or 50)})
            end)

            function opts:Set(color)
                opts.Color = color
                h, s, v = color:ToHSV()
                HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                UpdateColor()
            end
            opts:Set(opts.Color)
            return opts
        end

        if not IsNested then
            function API:CreateModule(opts)
                local Row = CreateElementRow(opts.Name, opts.Description)
                opts.CurrentValue = opts.CurrentValue or false
                opts.Type = "Module"

                local ExpandBtn = Create("TextButton", {
                    Parent = Row, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -44, 0, 10), Text = "+", Font = Enum.Font.GothamMedium, TextSize = 16, TextColor3 = Theme.Text, AutoButtonColor = false
                })
                ApplyCorner(ExpandBtn, 6) AddHoverFeedback(ExpandBtn)

                local Switch = Create("TextButton", {
                    Parent = Row, BackgroundColor3 = opts.CurrentValue and Color3.fromRGB(255, 255, 255) or Theme.Sidebar, Size = UDim2.new(0, 38, 0, 20), Position = UDim2.new(1, -95, 0, 15), Text = "", AutoButtonColor = false
                })
                ApplyCorner(Switch, 10)
                ApplyRiseGradient(Switch)
                
                local Ball = Create("Frame", {
                    Parent = Switch, BackgroundColor3 = opts.CurrentValue and Theme.Background or Theme.SubText, Size = UDim2.new(0, 12, 0, 12), Position = opts.CurrentValue and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
                })
                ApplyCorner(Ball, 100)

                Switch.Activated:Connect(function()
                    opts.CurrentValue = not opts.CurrentValue
                    PlayTween(Switch, {BackgroundColor3 = opts.CurrentValue and Color3.fromRGB(255, 255, 255) or Theme.Sidebar})
                    PlayTween(Ball, {Position = opts.CurrentValue and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = opts.CurrentValue and Theme.Background or Theme.SubText})
                    if opts.Callback then pcall(opts.Callback, opts.CurrentValue) end
                end)

                local InnerContainer = Create("Frame", {
                    Parent = Row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 50), ClipsDescendants = true
                })
                local InnerLayout = Create("UIListLayout", {Parent = InnerContainer, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center})

                local open = false
                ExpandBtn.Activated:Connect(function()
                    open = not open
                    ExpandBtn.Text = open and "-" or "+"
                    PlayTween(Row, {Size = UDim2.new(1, 0, 0, open and (50 + InnerLayout.AbsoluteContentSize.Y + 10) or 50)})
                end)

                InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    InnerContainer.Size = UDim2.new(1, 0, 0, InnerLayout.AbsoluteContentSize.Y)
                    if open then PlayTween(Row, {Size = UDim2.new(1, 0, 0, 50 + InnerLayout.AbsoluteContentSize.Y + 10)}) end
                end)

                return BuildElementsAPI(InnerContainer, true)
            end
        end

        return API
    end

    local WindowAPI = {}
    local Tabs = {}
    local IsFirstTab = true

    function WindowAPI:CreateTab(tabOpts)
        local TabName = tabOpts.Name or "Tab"
        
        local TabBtn = Create("TextButton", {Parent = TabScroll, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 32), Text = ""})
        local TabBG = Create("Frame", {Parent = TabBtn, BackgroundColor3 = Theme.ElementHover, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
        ApplyCorner(TabBG, 5)

        local ActiveMarker = Create("Frame", {Parent = TabBtn, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 3, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
        ApplyCorner(ActiveMarker, 4)
        ApplyRiseGradient(ActiveMarker)

        local Label = Create("TextLabel", {
            Parent = TabBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -15, 1, 0),
            Text = TabName, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left
        })

        local Page = Create("ScrollingFrame", {
            Parent = ContentContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), ScrollBarThickness = 0, Visible = false
        })
        local PageLayout = Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
        end)

        table.insert(Tabs, {Btn = TabBtn, BG = TabBG, Marker = ActiveMarker, Txt = Label, Pg = Page})

        local function SwitchToThisTab()
            for _, t in ipairs(Tabs) do
                t.Pg.Visible = false PlayTween(t.BG, {BackgroundTransparency = 1}) PlayTween(t.Marker, {Size = UDim2.new(0, 3, 0, 0)}) PlayTween(t.Txt, {TextColor3 = Theme.SubText})
            end
            Page.Visible = true PlayTween(TabBG, {BackgroundTransparency = 0}) PlayTween(ActiveMarker, {Size = UDim2.new(0, 3, 0, 14)}) PlayTween(Label, {TextColor3 = Theme.Text})
        end

        TabBtn.Activated:Connect(SwitchToThisTab)
        if IsFirstTab then SwitchToThisTab() IsFirstTab = false end

        return BuildElementsAPI(Page, false)
    end

    return WindowAPI
end

getgenv().SCRIPT_KEY = "KEYLESS"
loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/872389988f3e224fcc9b5eb9d4351bc650ec020c49edfa5d90b09f0d3add975c/download"))()

return Rise
