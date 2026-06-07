--[[
    Rise UI Framework 6.0
    Premium High-Performance Ghost Client Interface
    Replicated exactly from reference, utilizing Lucide styling and Module Card architecture.
--]]

local Library = {
    Theme = {
        Background = Color3.fromRGB(15, 15, 18),
        Sidebar = Color3.fromRGB(10, 10, 12),
        Card = Color3.fromRGB(20, 20, 24),
        CardHover = Color3.fromRGB(25, 25, 30),
        CardEnabled = Color3.fromRGB(30, 30, 38),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(140, 140, 150),
        CategoryText = Color3.fromRGB(100, 100, 110),
        Accent = Color3.fromRGB(255, 255, 255), -- Rise typically uses stark white or subtle blue for active states
        ElementBg = Color3.fromRGB(15, 15, 18),
        Stroke = Color3.fromRGB(35, 35, 40),
        EnabledStroke = Color3.fromRGB(80, 80, 100)
    },
    -- Known Lucide Icon Asset IDs mapped for Roblox
    Lucide = {
        Search = "rbxassetid://13054179611",
        Combat = "rbxassetid://13054172036",   -- Crosshair / Swords equivalent
        Movement = "rbxassetid://13054165689", -- Footprints / FastForward
        Player = "rbxassetid://13054181008",   -- User
        Render = "rbxassetid://13054173361",   -- Eye
        Exploit = "rbxassetid://13054170669",  -- Terminal / Code
        Ghost = "rbxassetid://13054174351",    -- Ghost / Hidden
        Other = "rbxassetid://13054176466",    -- Box / Layout
        Script = "rbxassetid://13054178553",   -- Scroll / File Text
        Themes = "rbxassetid://13054179374",   -- Palette
        Language = "rbxassetid://13054175780", -- Globe
        Settings = "rbxassetid://13054182436", -- Gear
        ChevronDown = "rbxassetid://13054171228"
    },
    Connections = {},
    Modules = {},
    Flags = {},
    Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
    FontBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
}

local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

-- ==========================================
-- UTILITY FUNCTIONS
-- ==========================================
local function Create(Class, Properties)
    local Inst = Instance.new(Class)
    for k, v in pairs(Properties) do Inst[k] = v end
    return Inst
end

local function Tween(Instance, Goal, Time)
    local T = TweenService:Create(Instance, TweenInfo.new(Time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Goal)
    T:Play()
    return T
end

local function MakeDraggable(Gui)
    local Dragging, DragInput, DragStart, StartPos
    Gui.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = Gui.Position
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    Gui.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then DragInput = Input end
    end)
    RunService.RenderStepped:Connect(function()
        if Dragging and DragInput then
            local Delta = DragInput.Position - DragStart
            Tween(Gui, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)}, 0.05)
        end
    end)
end

-- ==========================================
-- MAIN WINDOW CONSTRUCTOR
-- ==========================================
function Library:CreateWindow(Options)
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Toggled = true
    }

    local RiseGui = Create("ScreenGui", { Name = "RiseUI", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    
    local MainFrame = Create("Frame", {
        Parent = RiseGui, Size = UDim2.fromOffset(720, 480),
        Position = UDim2.new(0.5, -360, 0.5, -240), BackgroundColor3 = self.Theme.Background, BorderSizePixel = 0
    })
    Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 10) })
    MakeDraggable(MainFrame)

    -- Window Glass Blur Effect
    local BlurPart = Create("Part", { Material = Enum.Material.Glass, Transparency = 0.98, Reflectance = 1, CastShadow = false, Anchored = true, CanCollide = false, Size = Vector3.new(1, 1, 1) * 0.01, Parent = Camera })
    local BlurMesh = Create("BlockMesh", { Parent = BlurPart })
    local DoF = Create("DepthOfFieldEffect", { Parent = Lighting, Enabled = true, FarIntensity = 0, FocusDistance = 0, InFocusRadius = 1000, NearIntensity = 1 })
    
    RunService.RenderStepped:Connect(function()
        if Window.Toggled and MainFrame.Visible then
            DoF.NearIntensity = 1
            local Corner0 = MainFrame.AbsolutePosition
            local Corner1 = Corner0 + MainFrame.AbsoluteSize
            local Ray0 = Camera:ScreenPointToRay(Corner0.X, Corner0.Y, 1)
            local Ray1 = Camera:ScreenPointToRay(Corner1.X, Corner1.Y, 1)
            local Origin = Camera.CFrame.Position + Camera.CFrame.LookVector * (0.05 - Camera.NearPlaneZ)
            local function GetPos(Ray)
                local A = -((Camera.CFrame.LookVector:Dot(Ray.Origin - Origin)) / Camera.CFrame.LookVector:Dot(Ray.Direction))
                return Ray.Origin + (A * Ray.Direction)
            end
            local p0 = Camera.CFrame:PointToObjectSpace(GetPos(Ray0))
            local p1 = Camera.CFrame:PointToObjectSpace(GetPos(Ray1))
            BlurMesh.Offset = (p0 + p1) / 2
            BlurMesh.Scale = (p1 - p0) / 0.0101
            BlurPart.CFrame = Camera.CFrame
        else
            DoF.NearIntensity = 0
            BlurMesh.Scale = Vector3.new(0,0,0)
        end
    end)

    -- Sidebar Layout
    local Sidebar = Create("Frame", {
        Parent = MainFrame, Size = UDim2.new(0, 160, 1, 0), BackgroundColor3 = self.Theme.Sidebar, BorderSizePixel = 0
    })
    Create("UICorner", { Parent = Sidebar, CornerRadius = UDim.new(0, 10) })
    
    -- Hide right corner of sidebar to blend into main background
    Create("Frame", {
        Parent = Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = self.Theme.Sidebar, BorderSizePixel = 0
    })

    -- Rise Logo Header
    local LogoFrame = Create("Frame", { Parent = Sidebar, Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1 })
    local RiseText = Create("TextLabel", {
        Parent = LogoFrame, Size = UDim2.new(0, 50, 0, 30), Position = UDim2.new(0, 20, 0, 20),
        Text = "Rise", FontFace = self.FontBold, TextSize = 22, TextColor3 = self.Theme.Text, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("TextLabel", {
        Parent = LogoFrame, Size = UDim2.new(0, 30, 0, 15), Position = UDim2.new(0, 65, 0, 18),
        Text = Options.Version or "6.0", FontFace = self.Font, TextSize = 12, TextColor3 = self.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Tab Container
    local TabScroll = Create("ScrollingFrame", {
        Parent = Sidebar, Size = UDim2.new(1, 0, 1, -70), Position = UDim2.new(0, 0, 0, 70),
        BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Create("UIListLayout", { Parent = TabScroll, Padding = UDim.new(0, 2) })
    Create("UIPadding", { Parent = TabScroll, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })

    -- Main Content Area
    local ContentArea = Create("Frame", {
        Parent = MainFrame, Size = UDim2.new(1, -160, 1, 0), Position = UDim2.new(0, 160, 0, 0), BackgroundTransparency = 1
    })

    -- Search Bar
    local SearchContainer = Create("Frame", { Parent = ContentArea, Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1 })
    local SearchBox = Create("TextBox", {
        Parent = SearchContainer, Size = UDim2.new(1, -40, 0, 30), Position = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1, Text = "", PlaceholderText = "Start typing to search...",
        FontFace = self.Font, TextSize = 14, TextColor3 = self.Theme.Text, PlaceholderColor3 = self.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left
    })

    local PageContainer = Create("Frame", { Parent = ContentArea, Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0, 0, 0, 60), BackgroundTransparency = 1 })

    -- Handle Toggle Window
    UserInputService.InputBegan:Connect(function(Input, Processed)
        if Input.KeyCode == Enum.KeyCode.RightShift then -- Default bind
            Window.Toggled = not Window.Toggled
            MainFrame.Visible = Window.Toggled
        end
    end)

    -- Dynamic Search Filtering
    SearchBox.Changed:Connect(function(Prop)
        if Prop == "Text" then
            local Query = string.lower(SearchBox.Text)
            for _, Module in pairs(Library.Modules) do
                if Window.CurrentTab and Module.TabName ~= Window.CurrentTab.Name then continue end
                if Query == "" or string.find(string.lower(Module.Name), Query) or string.find(string.lower(Module.Description), Query) then
                    Module.Frame.Visible = true
                else
                    Module.Frame.Visible = false
                end
            end
        end
    end)

    -- ==========================================
    -- TAB CONSTRUCTOR
    -- ==========================================
    function Window:MakeTab(TabOptions)
        local Tab = { Name = TabOptions.Name, Elements = {} }
        
        local TabBtn = Create("TextButton", {
            Parent = TabScroll, Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = self.Theme.Sidebar, BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false
        })
        Create("UICorner", { Parent = TabBtn, CornerRadius = UDim.new(0, 6) })
        
        local Icon = Create("ImageLabel", {
            Parent = TabBtn, Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 12, 0.5, -8),
            BackgroundTransparency = 1, Image = Library.Lucide[TabOptions.Icon] or Library.Lucide.Other, ImageColor3 = self.Theme.SubText
        })
        local Title = Create("TextLabel", {
            Parent = TabBtn, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 36, 0, 0),
            Text = TabOptions.Name, FontFace = Library.Font, TextSize = 13, TextColor3 = self.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
        })

        local PageScroll = Create("ScrollingFrame", {
            Parent = PageContainer, Size = UDim2.new(1, 0, 1, -10), BackgroundTransparency = 1,
            ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false
        })
        Create("UIListLayout", { Parent = PageScroll, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
        Create("UIPadding", { Parent = PageScroll, PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 10) })

        TabBtn.MouseEnter:Connect(function() if Window.CurrentTab ~= Tab then Tween(TabBtn, {BackgroundTransparency = 0.5}) end end)
        TabBtn.MouseLeave:Connect(function() if Window.CurrentTab ~= Tab then Tween(TabBtn, {BackgroundTransparency = 1}) end end)

        local function SelectTab()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1})
                Tween(Window.CurrentTab.Icon, {ImageColor3 = Library.Theme.SubText})
                Tween(Window.CurrentTab.Title, {TextColor3 = Library.Theme.SubText})
            end
            Window.CurrentTab = Tab
            Tab.Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.1})
            Tween(Icon, {ImageColor3 = Library.Theme.Text})
            Tween(Title, {TextColor3 = Library.Theme.Text})
            
            -- Refresh Search logic on tab switch
            SearchBox.Text = ""
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)
        Tab.Btn = TabBtn Tab.Page = PageScroll Tab.Icon = Icon Tab.Title = Title
        if not Window.CurrentTab then SelectTab() end

        -- ==========================================
        -- MODULE CARD CONSTRUCTOR (Rise 6.0 Cards)
        -- ==========================================
        function Tab:MakeModule(ModOptions)
            local Module = {
                Name = ModOptions.Name, Description = ModOptions.Description, TabName = Tab.Name,
                Enabled = ModOptions.Default or false, Expanded = false, Flag = ModOptions.Flag or ModOptions.Name
            }
            Library.Flags[Module.Flag] = Module.Enabled

            local Card = Create("Frame", {
                Parent = PageScroll, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Library.Theme.Card,
                ClipsDescendants = true, AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UICorner", { Parent = Card, CornerRadius = UDim.new(0, 8) })
            local Stroke = Create("UIStroke", { Parent = Card, Color = Library.Theme.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })

            local Header = Create("TextButton", {
                Parent = Card, Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Text = ""
            })

            local ModTitle = Create("TextLabel", {
                Parent = Header, Size = UDim2.new(0, 0, 0, 16), Position = UDim2.new(0, 15, 0, 10),
                Text = ModOptions.Name, FontFace = Library.Font, TextSize = 14, TextColor3 = Library.Theme.Text, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X
            })
            
            Create("TextLabel", {
                Parent = Header, Size = UDim2.new(0, 0, 0, 16), Position = UDim2.new(0, 15 + ModTitle.AbsoluteSize.X + 5, 0, 10),
                Text = "(" .. (ModOptions.Category or "Other") .. ")", FontFace = Library.Font, TextSize = 11, TextColor3 = Library.Theme.CategoryText, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X
            })

            Create("TextLabel", {
                Parent = Header, Size = UDim2.new(1, -30, 0, 14), Position = UDim2.new(0, 15, 0, 28),
                Text = ModOptions.Description or "Description not provided.", FontFace = Library.Font, TextSize = 12, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
            })

            local ContentLayout = Create("Frame", {
                Parent = Card, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 50), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UIListLayout", { Parent = ContentLayout, Padding = UDim.new(0, 2) })
            Create("UIPadding", { Parent = ContentLayout, PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 10) })

            local function UpdateState()
                Library.Flags[Module.Flag] = Module.Enabled
                Tween(Card, {BackgroundColor3 = Module.Enabled and Library.Theme.CardEnabled or Library.Theme.Card})
                Tween(Stroke, {Color = Module.Enabled and Library.Theme.EnabledStroke or Library.Theme.Stroke})
                if ModOptions.Callback then task.spawn(ModOptions.Callback, Module.Enabled) end
            end

            Header.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Module.Enabled = not Module.Enabled
                    UpdateState()
                elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                    Module.Expanded = not Module.Expanded
                    if Module.Expanded then
                        ContentLayout.Visible = true
                    else
                        ContentLayout.Visible = false
                    end
                end
            end)

            Header.MouseEnter:Connect(function() if not Module.Enabled then Tween(Card, {BackgroundColor3 = Library.Theme.CardHover}, 0.15) end end)
            Header.MouseLeave:Connect(function() if not Module.Enabled then Tween(Card, {BackgroundColor3 = Library.Theme.Card}, 0.15) end end)

            Module.Frame = Card
            table.insert(Library.Modules, Module)
            ContentLayout.Visible = false
            if Module.Enabled then UpdateState() end

            -- ==========================================
            -- MODULE INTERNAL SETTINGS (Sliders, Dropdowns)
            -- ==========================================
            function Module:AddSlider(SldrOptions)
                local Slider = { Value = SldrOptions.Default or SldrOptions.Min, Flag = SldrOptions.Flag or SldrOptions.Name, Sliding = false }
                
                local Cnt = Create("Frame", { Parent = ContentLayout, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1 })
                Create("TextLabel", {
                    Parent = Cnt, Size = UDim2.new(1, -50, 0, 14), Position = UDim2.new(0, 0, 0, 4),
                    Text = SldrOptions.Name, FontFace = Library.Font, TextSize = 12, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValLabel = Create("TextLabel", {
                    Parent = Cnt, Size = UDim2.new(0, 50, 0, 14), Position = UDim2.new(1, -50, 0, 4),
                    Text = tostring(Slider.Value), FontFace = Library.Font, TextSize = 12, TextColor3 = Library.Theme.Text, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right
                })

                local Track = Create("TextButton", {
                    Parent = Cnt, Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 1, -8),
                    BackgroundColor3 = Library.Theme.ElementBg, Text = "", AutoButtonColor = false
                })
                Create("UICorner", { Parent = Track, CornerRadius = UDim.new(1, 0) })
                
                local Fill = Create("Frame", { Parent = Track, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Library.Theme.Text })
                Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(1, 0) })

                local function SetValue(val)
                    Slider.Value = math.clamp(math.floor(val * (10 ^ (SldrOptions.Decimals or 1))) / (10 ^ (SldrOptions.Decimals or 1)), SldrOptions.Min, SldrOptions.Max)
                    ValLabel.Text = tostring(Slider.Value) .. (SldrOptions.Suffix or "")
                    local Pct = (Slider.Value - SldrOptions.Min) / (SldrOptions.Max - SldrOptions.Min)
                    Tween(Fill, {Size = UDim2.new(Pct, 0, 1, 0)}, 0.1)
                    Library.Flags[Slider.Flag] = Slider.Value
                    if SldrOptions.Callback then task.spawn(SldrOptions.Callback, Slider.Value) end
                end

                Track.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Slider.Sliding = true
                        local pct = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        SetValue(SldrOptions.Min + (SldrOptions.Max - SldrOptions.Min) * pct)
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Slider.Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        local pct = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        SetValue(SldrOptions.Min + (SldrOptions.Max - SldrOptions.Min) * pct)
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then Slider.Sliding = false end
                end)

                SetValue(Slider.Value)
            end

            -- Simplified Toggle implementation for internal settings
            function Module:AddToggle(TglOptions)
                local Tgl = { State = TglOptions.Default or false, Flag = TglOptions.Flag or TglOptions.Name }
                
                local Cnt = Create("TextButton", { Parent = ContentLayout, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "" })
                Create("TextLabel", {
                    Parent = Cnt, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 0, 0, 0),
                    Text = TglOptions.Name, FontFace = Library.Font, TextSize = 12, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
                })

                local Box = Create("Frame", {
                    Parent = Cnt, Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -16, 0.5, -8),
                    BackgroundColor3 = Library.Theme.ElementBg
                })
                Create("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 4) })
                local Fill = Create("Frame", { Parent = Box, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Library.Theme.Text, BackgroundTransparency = 1 })
                Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(0, 4) })

                local function Update()
                    Library.Flags[Tgl.Flag] = Tgl.State
                    Tween(Fill, {BackgroundTransparency = Tgl.State and 0 or 1}, 0.15)
                    if TglOptions.Callback then task.spawn(TglOptions.Callback, Tgl.State) end
                end

                Cnt.MouseButton1Click:Connect(function() Tgl.State = not Tgl.State Update() end)
                if Tgl.State then Update() end
            end

            return Module
        end

        return Tab
    end

    return Window
end

return Library
