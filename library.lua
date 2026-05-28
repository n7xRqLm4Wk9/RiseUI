-- [[ LuxwareUI Library | Professional UI Framework ]] --
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Luxware = {}
Luxware.__index = Luxware

-- [ Protection & Parent Setup ]
local parentTarget = nil
pcall(function() parentTarget = CoreGui end)
if not parentTarget then parentTarget = LocalPlayer:WaitForChild("PlayerGui") end

-- [ Utility Functions ]
local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local delta = input.Position - DragStart
            TweenService:Create(object, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

local function CreateUIElement(className, properties)
    local el = Instance.new(className)
    for k, v in pairs(properties) do el[k] = v end
    return el
end

-- [ Main Library Initiation ]
function Luxware:CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or "LuxwareUI"
    local UseKeySystem = options.KeySystem or false
    local ExpectedKey = options.Key or "LUXWARE-TEST"
    local GetKeyLink = options.KeyLink or "https://discord.gg/yourlink"

    local LuxGUI = CreateUIElement("ScreenGui", {Name = "LuxwareUI", Parent = parentTarget, ResetOnSpawn = false})
    
    -- Expose destroy method
    function Luxware:Destroy()
        LuxGUI:Destroy()
    end

    -- [ Key System UI (Matches 1000106352.jpg) ]
    local KeyFrame = CreateUIElement("Frame", {
        Name = "KeyFrame", Parent = LuxGUI, BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.new(0.5, -175, 0.5, -125), Size = UDim2.new(0, 350, 0, 250),
        Visible = UseKeySystem, Active = true
    })
    CreateUIElement("UICorner", {Parent = KeyFrame, CornerRadius = UDim.new(0, 8)})
    CreateUIElement("UIStroke", {Parent = KeyFrame, Color = Color3.fromRGB(40, 40, 40), Thickness = 1})
    MakeDraggable(KeyFrame, KeyFrame)

    local KeyTitle = CreateUIElement("TextLabel", {
        Parent = KeyFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 15),
        Size = UDim2.new(1, 0, 0, 25), Font = Enum.Font.GothamBold, Text = "Key System",
        TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 18
    })
    local CloseKey = CreateUIElement("TextButton", {
        Parent = KeyFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0, 10),
        Size = UDim2.new(0, 20, 0, 20), Font = Enum.Font.GothamBold, Text = "X",
        TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 16
    })
    CloseKey.MouseButton1Click:Connect(function() LuxGUI:Destroy() end)

    local KeySub = CreateUIElement("TextLabel", {
        Parent = KeyFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.Gotham, Text = "🔑 Enter Key To Access The Script",
        TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 13
    })

    local KeyBox = CreateUIElement("TextBox", {
        Parent = KeyFrame, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Position = UDim2.new(0.5, -140, 0, 90),
        Size = UDim2.new(0, 280, 0, 45), Font = Enum.Font.Gotham, PlaceholderText = "Enter Key...",
        Text = "", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14
    })
    CreateUIElement("UICorner", {Parent = KeyBox, CornerRadius = UDim.new(0, 6)})

    local GetKeyBtn = CreateUIElement("TextButton", {
        Parent = KeyFrame, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Position = UDim2.new(0.5, -140, 0, 155),
        Size = UDim2.new(0, 135, 0, 40), Font = Enum.Font.Gotham, Text = "Get Key", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14
    })
    CreateUIElement("UICorner", {Parent = GetKeyBtn, CornerRadius = UDim.new(0, 6)})

    local CheckKeyBtn = CreateUIElement("TextButton", {
        Parent = KeyFrame, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Position = UDim2.new(0.5, 5, 0, 155),
        Size = UDim2.new(0, 135, 0, 40), Font = Enum.Font.Gotham, Text = "Check Key", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14
    })
    CreateUIElement("UICorner", {Parent = CheckKeyBtn, CornerRadius = UDim.new(0, 6)})

    -- [ Main UI Initialization ]
    local MainFrame = CreateUIElement("Frame", {
        Name = "MainFrame", Parent = LuxGUI, BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.new(0.5, -250, 0.5, -175), Size = UDim2.new(0, 500, 0, 350),
        Visible = not UseKeySystem, Active = true, ClipsDescendants = true
    })
    CreateUIElement("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    CreateUIElement("UIStroke", {Parent = MainFrame, Color = Color3.fromRGB(40, 40, 40), Thickness = 1})
    MakeDraggable(MainFrame, MainFrame)

    local LeftPanel = CreateUIElement("Frame", {
        Parent = MainFrame, BackgroundColor3 = Color3.fromRGB(25, 25, 25), Size = UDim2.new(0, 130, 1, 0), BorderSizePixel = 0
    })
    local Title = CreateUIElement("TextLabel", {
        Parent = LeftPanel, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0,0,0,5),
        Font = Enum.Font.GothamBold, Text = WindowName, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 16
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

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then
            if UseKeySystem and KeyFrame.Visible then return end -- Don't toggle if key sys is active
            Luxware:SetVisible(not WindowIsVisible)
        end
    end)

    -- Key System Functions
    GetKeyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(GetKeyLink) end)
        KeySub.Text = "Link copied to clipboard!"
        task.wait(2)
        KeySub.Text = "🔑 Enter Key To Access The Script"
    end)

    CheckKeyBtn.MouseButton1Click:Connect(function()
        if KeyBox.Text == ExpectedKey then
            KeySub.Text = "Key Verified!"
            KeySub.TextColor3 = Color3.fromRGB(50, 255, 50)
            task.wait(0.5)
            KeyFrame.Visible = false
            Luxware:SetVisible(true)
        else
            KeySub.Text = "Invalid Key!"
            KeySub.TextColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(1.5)
            KeySub.Text = "🔑 Enter Key To Access The Script"
            KeySub.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end)

    -- Notifier
    local NoteContainer = CreateUIElement("Frame", {
        Parent = LuxGUI, BackgroundTransparency = 1, Position = UDim2.new(1, -220, 1, -150), Size = UDim2.new(0, 200, 0, 130)
    })
    CreateUIElement("UIListLayout", {Parent = NoteContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), VerticalAlignment = Enum.VerticalAlignment.Bottom})

    function Luxware:Notify(data)
        local nFrame = CreateUIElement("Frame", {
            Parent = NoteContainer, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1
        })
        CreateUIElement("UICorner", {Parent = nFrame, CornerRadius = UDim.new(0, 6)})
        local nTitle = CreateUIElement("TextLabel", {
            Parent = nFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold, Text = data.Title, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1
        })
        local nContent = CreateUIElement("TextLabel", {
            Parent = nFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -20, 0, 30),
            Font = Enum.Font.Gotham, Text = data.Content, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextTransparency = 1
        })
        TweenService:Create(nFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        TweenService:Create(nTitle, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(nContent, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        task.delay(data.Duration or 3, function()
            TweenService:Create(nFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(nTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(nContent, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            task.wait(0.3)
            nFrame:Destroy()
        end)
    end

    -- Tab System
    local tabs = {}
    local firstTab = true

    function Luxware:CreateTab(tabName)
        local TabBtn = CreateUIElement("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.Gotham, Text = tabName, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 14
        })
        local Page = CreateUIElement("ScrollingFrame", {
            Parent = RightPanel, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2, Visible = firstTab
        })
        local PageLayout = CreateUIElement("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        if firstTab then TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); firstTab = false end
        table.insert(tabs, {Btn = TabBtn, Pg = Page})

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in ipairs(tabs) do
                t.Pg.Visible = false
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)

        local TabElements = {}

        function TabElements:CreateSection(name)
            local Sec = CreateUIElement("TextLabel", {
                Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.GothamBold, Text = name, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function TabElements:CreateLabel(text)
            local Lbl = CreateUIElement("TextLabel", {
                Parent = Page, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(1, 0, 0, 35),
                Font = Enum.Font.Gotham, Text = "  " .. text, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
            CreateUIElement("UICorner", {Parent = Lbl, CornerRadius = UDim.new(0, 6)})
        end

        function TabElements:CreateButton(opts)
            local Btn = CreateUIElement("TextButton", {
                Parent = Page, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(1, 0, 0, 35),
                Font = Enum.Font.Gotham, Text = opts.Name, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13
            })
            CreateUIElement("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
            Btn.MouseButton1Click:Connect(function() opts.Callback() end)
        end

        function TabElements:CreateToggle(opts)
            local state = opts.CurrentValue or false
            local TglFrame = CreateUIElement("TextButton", {
                Parent = Page, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(1, 0, 0, 35), Text = "", AutoButtonColor = false
            })
            CreateUIElement("UICorner", {Parent = TglFrame, CornerRadius = UDim.new(0, 6)})
            CreateUIElement("TextLabel", {
                Parent = TglFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                Font = Enum.Font.Gotham, Text = opts.Name, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
            local TglBox = CreateUIElement("Frame", {
                Parent = TglFrame, BackgroundColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 60),
                Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10)
            })
            CreateUIElement("UICorner", {Parent = TglBox, CornerRadius = UDim.new(1, 0)})
            local TglCircle = CreateUIElement("Frame", {
                Parent = TglBox, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            })
            CreateUIElement("UICorner", {Parent = TglCircle, CornerRadius = UDim.new(1, 0)})

            TglFrame.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(TglBox, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 60)}):Play()
                TweenService:Create(TglCircle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                opts.Callback(state)
            end)
        end

        function TabElements:CreateSlider(opts)
            local val = opts.CurrentValue or opts.Range[1]
            local SldFrame = CreateUIElement("Frame", {
                Parent = Page, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(1, 0, 0, 50)
            })
            CreateUIElement("UICorner", {Parent = SldFrame, CornerRadius = UDim.new(0, 6)})
            CreateUIElement("TextLabel", {
                Parent = SldFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 25), Position = UDim2.new(0, 10, 0, 0),
                Font = Enum.Font.Gotham, Text = opts.Name, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
            local ValTxt = CreateUIElement("TextLabel", {
                Parent = SldFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 50, 0, 25), Position = UDim2.new(1, -60, 0, 0),
                Font = Enum.Font.Gotham, Text = tostring(val), TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right
            })
            local SldBG = CreateUIElement("TextButton", {
                Parent = SldFrame, BackgroundColor3 = Color3.fromRGB(50, 50, 50), Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 35), Text = ""
            })
            CreateUIElement("UICorner", {Parent = SldBG, CornerRadius = UDim.new(1, 0)})
            local SldFill = CreateUIElement("Frame", {
                Parent = SldBG, BackgroundColor3 = Color3.fromRGB(100, 100, 255), Size = UDim2.new((val - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1, 0)
            })
            CreateUIElement("UICorner", {Parent = SldFill, CornerRadius = UDim.new(1, 0)})

            local dragging = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - SldBG.AbsolutePosition.X) / SldBG.AbsoluteSize.X, 0, 1)
                val = math.floor(((pos * (opts.Range[2] - opts.Range[1])) + opts.Range[1]) / opts.Increment + 0.5) * opts.Increment
                val = math.clamp(val, opts.Range[1], opts.Range[2])
                TweenService:Create(SldFill, TweenInfo.new(0.1), {Size = UDim2.new((val - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1, 0)}):Play()
                ValTxt.Text = tostring(val)
                opts.Callback(val)
            end

            SldBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
            end)
        end

        function TabElements:CreateKeybind(opts)
            local currentKey = opts.CurrentKey or Enum.KeyCode.E
            local KbFrame = CreateUIElement("Frame", {
                Parent = Page, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(1, 0, 0, 35)
            })
            CreateUIElement("UICorner", {Parent = KbFrame, CornerRadius = UDim.new(0, 6)})
            CreateUIElement("TextLabel", {
                Parent = KbFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                Font = Enum.Font.Gotham, Text = opts.Name, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
            local KbBtn = CreateUIElement("TextButton", {
                Parent = KbFrame, BackgroundColor3 = Color3.fromRGB(50, 50, 50), Size = UDim2.new(0, 80, 0, 25),
                Position = UDim2.new(1, -90, 0.5, -12.5), Font = Enum.Font.GothamBold, Text = currentKey.Name, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12
            })
            CreateUIElement("UICorner", {Parent = KbBtn, CornerRadius = UDim.new(0, 4)})

            local binding = false
            KbBtn.MouseButton1Click:Connect(function()
                binding = true
                KbBtn.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    KbBtn.Text = currentKey.Name
                    binding = false
                elseif not binding and input.KeyCode == currentKey then
                    opts.Callback()
                end
            end)
        end

        function TabElements:CreateColorPicker(opts)
            local clr = opts.Color or Color3.fromRGB(255, 255, 255)
            local CpFrame = CreateUIElement("Frame", {
                Parent = Page, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(1, 0, 0, 35)
            })
            CreateUIElement("UICorner", {Parent = CpFrame, CornerRadius = UDim.new(0, 6)})
            CreateUIElement("TextLabel", {
                Parent = CpFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                Font = Enum.Font.Gotham, Text = opts.Name, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Simplified RGB Input for pro hubs
            local function makeBox(xPos, initialVal)
                local box = CreateUIElement("TextBox", {
                    Parent = CpFrame, BackgroundColor3 = Color3.fromRGB(50, 50, 50), Size = UDim2.new(0, 25, 0, 25),
                    Position = UDim2.new(1, xPos, 0.5, -12.5), Font = Enum.Font.Gotham, Text = tostring(math.floor(initialVal*255)),
                    TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12
                })
                CreateUIElement("UICorner", {Parent = box, CornerRadius = UDim.new(0, 4)})
                return box
            end

            local RBox = makeBox(-100, clr.R)
            local GBox = makeBox(-70, clr.G)
            local BBox = makeBox(-40, clr.B)

            local function updateColor()
                local r, g, b = tonumber(RBox.Text) or 255, tonumber(GBox.Text) or 255, tonumber(BBox.Text) or 255
                clr = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
                opts.Callback(clr)
            end

            RBox.FocusLost:Connect(updateColor); GBox.FocusLost:Connect(updateColor); BBox.FocusLost:Connect(updateColor)
        end

        return TabElements
    end

    return Luxware
end

return Luxware
