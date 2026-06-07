--[[
    LuxwareUI / Project Flow - Premium Interface Framework
    Engineered for PC & Mobile Cross-Compatibility
    Architecture: Senior-Level Monolithic Object-Oriented Setup
--]]

local Library = {}

-- ==========================================
-- 1. GLOBAL CACHING & SERVICES
-- ==========================================
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")

local gethui = gethui or function() return CoreGui end
local LocalPlayer = Players.LocalPlayer

-- Math & Table Constants
local MathClamp = math.clamp
local MathFloor = math.floor
local MathRound = math.round
local TableInsert = table.insert
local TableFind = table.find

-- Color & UI Constants
local Color3RGB = Color3.fromRGB
local Color3HSV = Color3.fromHSV
local UDim2New = UDim2.new
local UDimNew = UDim.new
local Vector2New = Vector2.new

-- ==========================================
-- 2. THEME & UTILITIES
-- ==========================================
local Theme = {
    Background = Color3RGB(15, 15, 15),
    Surface = Color3RGB(22, 22, 22),
    SurfaceLight = Color3RGB(30, 30, 30),
    Accent = Color3RGB(255, 255, 255),
    Text = Color3RGB(240, 240, 240),
    TextMuted = Color3RGB(150, 150, 150),
    Border = Color3RGB(40, 40, 40),
    Warning = Color3RGB(255, 180, 50),
    Error = Color3RGB(255, 80, 80),
    Success = Color3RGB(80, 255, 100)
}

Library.Flags = {}
Library.UnsavedFlags = {}
Library.Connections = {}
Library.IsMobile = UserInputService.TouchEnabled

local function Create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    if properties and properties.Parent then
        inst.Parent = properties.Parent
    end
    return inst
end

local function Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

-- Universal PC & Mobile Dragging Logic
local function MakeDraggable(dragHandle, target)
    local dragging, dragInput, mousePos, framePos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = target.Position

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
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            target.Position = UDim2New(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- ==========================================
-- 3. NOTIFICATION & WATERMARK SYSTEM
-- ==========================================
Library.NotificationLayer = Create("ScreenGui", {
    Name = "Luxware_Notifications",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = gethui()
})

local NotificationContainer = Create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2New(0, 300, 1, -40),
    Position = UDim2New(1, -320, 0, 20),
    Parent = Library.NotificationLayer
})

Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDimNew(0, 10),
    Parent = NotificationContainer
})

function Library:Notify(data)
    local title = data.Title or "Notification"
    local text = data.Content or ""
    local duration = data.Duration or 5

    local card = Create("Frame", {
        BackgroundColor3 = Theme.Background,
        Size = UDim2New(1, 40, 0, 0), -- Starts offset to right
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = NotificationContainer
    }, {
        Create("UICorner", { CornerRadius = UDimNew(0, 6) }),
        Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
        Create("UIPadding", { PaddingTop = UDimNew(0, 10), PaddingBottom = UDimNew(0, 10), PaddingLeft = UDimNew(0, 15), PaddingRight = UDimNew(0, 15) })
    })

    local titleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2New(1, 0, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })

    local contentLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2New(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2New(0, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = Theme.TextMuted,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })

    -- Slide in
    Tween(card, { Size = UDim2New(1, 0, 0, card.AbsoluteSize.Y) }, 0.4, Enum.EasingStyle.Back)
    
    task.delay(duration, function()
        local out = Tween(card, { Size = UDim2New(1, 40, 0, card.AbsoluteSize.Y), BackgroundTransparency = 1 }, 0.3)
        titleLabel.TextTransparency = 1
        contentLabel.TextTransparency = 1
        card:FindFirstChildOfClass("UIStroke").Transparency = 1
        out.Completed:Connect(function() card:Destroy() end)
    end)
end

function Library:SetWatermark(text, visible)
    if not Library.WatermarkFrame then
        Library.WatermarkFrame = Create("Frame", {
            BackgroundColor3 = Theme.Background,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 26),
            Position = UDim2New(0, 20, 0, 20),
            Parent = Library.NotificationLayer
        }, {
            Create("UICorner", { CornerRadius = UDimNew(0, 4) }),
            Create("UIStroke", { Color = Theme.Border }),
            Create("UIPadding", { PaddingLeft = UDimNew(0, 10), PaddingRight = UDimNew(0, 10) }),
            Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 1, 0),
                Font = Enum.Font.GothamMedium,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Text = text or "LuxwareUI"
            })
        })
    end
    Library.WatermarkFrame.Label.Text = text
    Library.WatermarkFrame.Visible = visible
end

-- ==========================================
-- 4. CORE UI FRAMEWORK
-- ==========================================
function Library:CreateWindow(config)
    local WindowName = config.Name or "LuxwareUI"
    local ConfigFolder = config.Folder or "LuxwareConfigs"
    local ConfigSaving = config.SaveConfig or false

    local CoreContainer = Create("ScreenGui", {
        Name = "LuxwareUI_Core",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = gethui()
    })

    local MainSize = Library.IsMobile and UDim2New(0, 360, 0, 280) or UDim2New(0, 600, 0, 400)
    
    local MainFrame = Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Theme.Background,
        Size = MainSize,
        Position = UDim2New(0.5, -MainSize.X.Offset/2, 0.5, -MainSize.Y.Offset/2),
        ClipsDescendants = true,
        Parent = CoreContainer
    }, {
        Create("UICorner", { CornerRadius = UDimNew(0, 8) }),
        Create("UIStroke", { Color = Theme.Border, Thickness = 1 })
    })

    local Topbar = Create("Frame", {
        Name = "Topbar",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2New(1, 0, 0, 35),
        Parent = MainFrame
    }, {
        Create("TextLabel", {
            Text = WindowName,
            Font = Enum.Font.GothamBold,
            TextColor3 = Theme.Text,
            TextSize = 14,
            Size = UDim2New(1, -20, 1, 0),
            Position = UDim2New(0, 15, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        }),
        Create("Frame", {
            BackgroundColor3 = Theme.Border,
            Size = UDim2New(1, 0, 0, 1),
            Position = UDim2New(0, 0, 1, 0),
            BorderSizePixel = 0
        })
    })
    
    MakeDraggable(Topbar, MainFrame)

    local TabContainer = Create("Frame", {
        Name = "Tabs",
        BackgroundTransparency = 1,
        Size = UDim2New(1, 0, 0, 30),
        Position = UDim2New(0, 0, 0, 36),
        Parent = MainFrame
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        Create("Frame", { -- Bottom border for tabs
            BackgroundColor3 = Theme.Border,
            Size = UDim2New(1, 0, 0, 1),
            Position = UDim2New(0, 0, 1, -1),
            BorderSizePixel = 0,
            ZIndex = 0
        })
    })

    local ContentContainer = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2New(1, 0, 1, -66),
        Position = UDim2New(0, 0, 0, 66),
        Parent = MainFrame
    })

    local Window = {
        Tabs = {},
        CurrentTab = nil
    }

    -- Configuration Manager Built-in
    function Window:SaveConfig()
        if not ConfigSaving then return end
        if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
        local success, err = pcall(function()
            writefile(ConfigFolder .. "/auto_save.json", HttpService:JSONEncode(Library.Flags))
        end)
        if err then warn("Luxware Config Save Error:", err) end
    end

    function Window:LoadConfig()
        if not ConfigSaving then return end
        if isfile(ConfigFolder .. "/auto_save.json") then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(ConfigFolder .. "/auto_save.json"))
            end)
            if success and data then
                for flag, value in pairs(data) do
                    Library.Flags[flag] = value
                end
            end
        end
    end

    Window:LoadConfig()

    -- ==========================================
    -- 5. TAB CREATION
    -- ==========================================
    function Window:CreateTab(name)
        local Tab = { Name = name, Elements = {} }
        
        local TabButton = Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2New(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = "",
            Parent = TabContainer
        })

        local TabText = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2New(1, 0, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = name,
            TextColor3 = Theme.TextMuted,
            TextSize = 13,
            Parent = TabButton
        }, {
            Create("UIPadding", { PaddingLeft = UDimNew(0, 15), PaddingRight = UDimNew(0, 15) })
        })

        local ActiveIndicator = Create("Frame", {
            BackgroundColor3 = Theme.Accent,
            Size = UDim2New(1, 0, 0, 2),
            Position = UDim2New(0, 0, 1, -2),
            Visible = false,
            Parent = TabButton
        })

        local Canvas = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2New(1, 0, 1, 0),
            CanvasSize = UDim2New(0, 0, 0, 0),
            ScrollBarThickness = Library.IsMobile and 2 or 4,
            ScrollBarImageColor3 = Theme.Border,
            Visible = false,
            Parent = ContentContainer
        }, {
            Create("UIPadding", { PaddingTop = UDimNew(0, 10), PaddingBottom = UDimNew(0, 10), PaddingLeft = UDimNew(0, 10), PaddingRight = UDimNew(0, 10) }),
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDimNew(0, 8) })
        })

        Canvas.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Canvas.CanvasSize = UDim2New(0, 0, 0, Canvas.UIListLayout.AbsoluteContentSize.Y + 20)
        end)

        function Tab:Show()
            for _, t in pairs(Window.Tabs) do
                t.Indicator.Visible = false
                t.Text.TextColor3 = Theme.TextMuted
                t.Canvas.Visible = false
            end
            ActiveIndicator.Visible = true
            TabText.TextColor3 = Theme.Accent
            Canvas.Visible = true
            Window.CurrentTab = Tab
        end

        TabButton.MouseButton1Click:Connect(function() Tab:Show() end)

        Tab.Button = TabButton
        Tab.Text = TabText
        Tab.Indicator = ActiveIndicator
        Tab.Canvas = Canvas
        TableInsert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then Tab:Show() end

        -- ==========================================
        -- 6. ELEMENT FACTORIES (Inside Tab)
        -- ==========================================
        function Tab:CreateSection(secName)
            local Section = {}
            
            local SecFrame = Create("Frame", {
                BackgroundColor3 = Theme.Surface,
                Size = UDim2New(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Canvas
            }, {
                Create("UICorner", { CornerRadius = UDimNew(0, 6) }),
                Create("UIStroke", { Color = Theme.Border }),
                Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDimNew(0, 2) }),
                Create("UIPadding", { PaddingBottom = UDimNew(0, 6) })
            })

            local SecLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2New(1, -20, 0, 30),
                Position = UDim2New(0, 10, 0, 0),
                Font = Enum.Font.GothamMedium,
                Text = secName,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SecFrame
            })

            local function AddElementContainer()
                return Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 32),
                    Parent = SecFrame
                }, { Create("UIPadding", { PaddingLeft = UDimNew(0, 10), PaddingRight = UDimNew(0, 10) }) })
            end

            function Section:CreateButton(cfg)
                local Container = AddElementContainer()
                local Btn = Create("TextButton", {
                    BackgroundColor3 = Theme.SurfaceLight,
                    Size = UDim2New(1, 0, 1, -4),
                    Position = UDim2New(0, 0, 0, 2),
                    AutoButtonColor = false,
                    Text = "",
                    Parent = Container
                }, {
                    Create("UICorner", { CornerRadius = UDimNew(0, 4) }),
                    Create("UIStroke", { Color = Theme.Border }),
                    Create("TextLabel", {
                        BackgroundTransparency = 1, Size = UDim2New(1, 0, 1, 0),
                        Font = Enum.Font.GothamMedium, Text = cfg.Name, TextColor3 = Theme.Text, TextSize = 13
                    })
                })

                Btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Tween(Btn, { BackgroundColor3 = Theme.Border }, 0.1)
                    end
                end)
                Btn.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Tween(Btn, { BackgroundColor3 = Theme.SurfaceLight }, 0.1)
                        if cfg.Callback then task.spawn(cfg.Callback) end
                    end
                end)
            end

            function Section:CreateToggle(cfg)
                local Container = AddElementContainer()
                local State = Library.Flags[cfg.Flag] ~= nil and Library.Flags[cfg.Flag] or (cfg.Default or false)
                Library.Flags[cfg.Flag] = State

                Create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2New(1, -50, 1, 0),
                    Font = Enum.Font.Gotham, Text = cfg.Name, TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })

                local ToggleBox = Create("Frame", {
                    BackgroundColor3 = State and Theme.Accent or Theme.SurfaceLight,
                    Size = UDim2New(0, 20, 0, 20),
                    Position = UDim2New(1, -20, 0.5, -10),
                    Parent = Container
                }, {
                    Create("UICorner", { CornerRadius = UDimNew(0, 4) }),
                    Create("UIStroke", { Color = State and Theme.Accent or Theme.Border })
                })

                local Btn = Create("TextButton", { Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = Container })

                Btn.MouseButton1Click:Connect(function()
                    State = not State
                    Library.Flags[cfg.Flag] = State
                    Window:SaveConfig()
                    
                    Tween(ToggleBox, { BackgroundColor3 = State and Theme.Accent or Theme.SurfaceLight }, 0.2)
                    Tween(ToggleBox.UIStroke, { Color = State and Theme.Accent or Theme.Border }, 0.2)
                    
                    if cfg.Callback then task.spawn(cfg.Callback, State) end
                end)
            end

            function Section:CreateSlider(cfg)
                local Container = AddElementContainer()
                Container.Size = UDim2New(1, 0, 0, 45)
                
                local Min, Max, Inc = cfg.Range[1], cfg.Range[2], cfg.Increment or 1
                local Value = Library.Flags[cfg.Flag] ~= nil and Library.Flags[cfg.Flag] or (cfg.Default or Min)
                Library.Flags[cfg.Flag] = Value

                local Label = Create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2New(1, 0, 0, 15), Position = UDim2New(0, 0, 0, 5),
                    Font = Enum.Font.Gotham, Text = cfg.Name, TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
                
                local ValueLabel = Create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2New(1, 0, 0, 15), Position = UDim2New(0, 0, 0, 5),
                    Font = Enum.Font.GothamMedium, Text = tostring(Value), TextColor3 = Theme.TextMuted, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Container
                })

                local Track = Create("Frame", {
                    BackgroundColor3 = Theme.SurfaceLight, Size = UDim2New(1, 0, 0, 6), Position = UDim2New(0, 0, 0, 30),
                    Parent = Container
                }, { Create("UICorner", { CornerRadius = UDimNew(1, 0) }), Create("UIStroke", { Color = Theme.Border }) })

                local Fill = Create("Frame", {
                    BackgroundColor3 = Theme.Accent, Size = UDim2New((Value - Min)/(Max - Min), 0, 1, 0),
                    Parent = Track
                }, { Create("UICorner", { CornerRadius = UDimNew(1, 0) }) })

                local function Update(input)
                    local percent = MathClamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local rawVal = Min + (percent * (Max - Min))
                    Value = MathRound(rawVal / Inc) * Inc
                    Value = MathClamp(Value, Min, Max)
                    
                    Fill.Size = UDim2New((Value - Min)/(Max - Min), 0, 1, 0)
                    ValueLabel.Text = tostring(Value)
                    Library.Flags[cfg.Flag] = Value
                    Window:SaveConfig()
                    if cfg.Callback then task.spawn(cfg.Callback, Value) end
                end

                local dragging = false
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        Update(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        Update(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
            end

            function Section:CreateDropdown(cfg)
                local Container = AddElementContainer()
                Container.ClipsDescendants = true
                
                local Options = cfg.Options or {}
                local Current = Library.Flags[cfg.Flag] ~= nil and Library.Flags[cfg.Flag] or (cfg.Default or Options[1])
                Library.Flags[cfg.Flag] = Current

                local DropFrame = Create("TextButton", {
                    BackgroundColor3 = Theme.SurfaceLight, Size = UDim2New(1, 0, 0, 26), Position = UDim2New(0, 0, 0, 3), AutoButtonColor = false, Text = "",
                    Parent = Container
                }, {
                    Create("UICorner", { CornerRadius = UDimNew(0, 4) }),
                    Create("UIStroke", { Color = Theme.Border }),
                    Create("TextLabel", { BackgroundTransparency=1, Size=UDim2New(1,-30,1,0), Position=UDim2New(0,10,0,0), Font=Enum.Font.Gotham, Text=cfg.Name .. " : " .. tostring(Current), TextColor3=Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Name="Title" }),
                    Create("TextLabel", { BackgroundTransparency=1, Size=UDim2New(0,20,1,0), Position=UDim2New(1,-20,0,0), Font=Enum.Font.GothamBold, Text="+", TextColor3=Theme.TextMuted, TextSize=14, Name="Icon" })
                })

                local ListLayout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDimNew(0, 2) })
                local ItemContainer = Create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2New(1, 0, 0, 0), Position = UDim2New(0, 0, 0, 32), ClipsDescendants = true,
                    Parent = Container
                }, { ListLayout })

                local isOpen = false

                local function Rebuild()
                    for _, v in pairs(ItemContainer:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    for _, opt in pairs(Options) do
                        local btn = Create("TextButton", {
                            BackgroundColor3 = Theme.Background, Size = UDim2New(1, 0, 0, 24), AutoButtonColor = false, Text = "", Parent = ItemContainer
                        }, {
                            Create("UICorner", { CornerRadius = UDimNew(0, 4) }),
                            Create("TextLabel", { BackgroundTransparency=1, Size=UDim2New(1,-10,1,0), Position=UDim2New(0,10,0,0), Font=Enum.Font.Gotham, Text=opt, TextColor3=opt == Current and Theme.Accent or Theme.TextMuted, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left })
                        })
                        btn.MouseButton1Click:Connect(function()
                            Current = opt
                            Library.Flags[cfg.Flag] = Current
                            Window:SaveConfig()
                            DropFrame.Title.Text = cfg.Name .. " : " .. tostring(Current)
                            if cfg.Callback then task.spawn(cfg.Callback, Current) end
                            Rebuild()
                            
                            -- Auto-close
                            isOpen = false
                            Tween(DropFrame.Icon, { Rotation = 0 }, 0.2)
                            Tween(Container, { Size = UDim2New(1, 0, 0, 32) }, 0.2)
                        end)
                    end
                end

                DropFrame.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    Tween(DropFrame.Icon, { Rotation = isOpen and 45 or 0 }, 0.2)
                    Tween(Container, { Size = UDim2New(1, 0, 0, isOpen and 32 + (#Options * 26) or 32) }, 0.2)
                    if isOpen then Rebuild() end
                end)
                
                Rebuild()
            end

            function Section:CreateKeybind(cfg)
                local Container = AddElementContainer()
                local Key = Library.Flags[cfg.Flag] ~= nil and Library.Flags[cfg.Flag] or cfg.Default
                Library.Flags[cfg.Flag] = Key

                Create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2New(1, -80, 1, 0), Font = Enum.Font.Gotham, Text = cfg.Name, TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Container
                })

                local BindBtn = Create("TextButton", {
                    BackgroundColor3 = Theme.SurfaceLight, Size = UDim2New(0, 70, 0, 22), Position = UDim2New(1, -70, 0.5, -11), Text = "", Parent = Container
                }, {
                    Create("UICorner", { CornerRadius = UDimNew(0, 4) }), Create("UIStroke", { Color = Theme.Border }),
                    Create("TextLabel", { BackgroundTransparency=1, Size=UDim2New(1,0,1,0), Font=Enum.Font.GothamMedium, Text=Key and Key.Name or "None", TextColor3=Theme.Text, TextSize=12, Name="KeyText" })
                })

                local listening = false
                BindBtn.MouseButton1Click:Connect(function()
                    listening = true
                    BindBtn.KeyText.Text = "..."
                    BindBtn.UIStroke.Color = Theme.Accent
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        Key = input.KeyCode
                        Library.Flags[cfg.Flag] = Key
                        Window:SaveConfig()
                        BindBtn.KeyText.Text = Key.Name
                        Tween(BindBtn.UIStroke, { Color = Theme.Border }, 0.2)
                    elseif not gpe and input.KeyCode == Key and cfg.Callback then
                        task.spawn(cfg.Callback)
                    end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Library
