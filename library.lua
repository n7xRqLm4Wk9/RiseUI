--[[
    RiseUI Premium Client Framework 6.0
    An ironclad, modular, zero-asset UI rendering engine engineered for Roblox.
    Features integrated hardware state saving, multi-platform touch/mouse scaling,
    and synchronous vector graphics gradient maps.
--]]

local Library = {
    Theme = {
        Background = Color3.fromRGB(10, 10, 14),
        Sidebar = Color3.fromRGB(6, 6, 9),
        Card = Color3.fromRGB(16, 16, 22),
        CardHover = Color3.fromRGB(22, 22, 30),
        CardEnabled = Color3.fromRGB(18, 16, 32), -- Velvet shadow tint
        ElementBg = Color3.fromRGB(11, 11, 15),
        Text = Color3.fromRGB(245, 245, 252),
        SubText = Color3.fromRGB(140, 140, 155),
        CategoryText = Color3.fromRGB(95, 95, 110),
        Stroke = Color3.fromRGB(26, 26, 32),
        
        -- Signature Rise 6.0 Premium Gradient Matrix
        RiseGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(43, 115, 255)),   -- Sapphire Blue
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(125, 65, 255)), -- Amethyst Purple
            ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 50, 255))    -- Magenta Neon
        }),
        SliderGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 130, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 60, 255))
        }),
        NotificationGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 230, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 50, 255))
        })
    },
    Connections = {},
    Modules = {},
    Flags = {},
    Elements = {}, -- Active memory reference pointers for real-time config patching
    Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
    FontBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
    FontItalic = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Italic),
}

-- Core Service Caching
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local IS_MOBILE = UserInputService.TouchEnabled
local ConfigFolder = "RiseUI_Premium_Configs"
local ConfigFile = ConfigFolder .. "/client_profile.json"

-- =============================================================================
-- SYSTEM INTERNAL UTILITY CORE
-- =============================================================================
local function Create(Class, Properties)
    local Inst = Instance.new(Class)
    for k, v in pairs(Properties) do Inst[k] = v end
    return Inst
end

local function Tween(Inst, Goal, Time, Style, Dir)
    local Info = TweenInfo.new(Time or 0.25, Style or Enum.EasingStyle.Quart, Dir or Enum.EasingDirection.Out)
    local T = TweenService:Create(Inst, Info, Goal)
    T:Play()
    return T
end

local function ApplyGradient(Parent, ColorSeq, Rotation)
    return Create("UIGradient", {
        Color = ColorSeq,
        Rotation = Rotation or 0,
        Parent = Parent
    })
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

-- =============================================================================
-- SERIALIZED JSON CONFIGURATION SYSTEM
-- =============================================================================
local function InitializeFileSystem()
    if makefolder and isfolder and not isfolder(ConfigFolder) then
        pcall(makefolder, ConfigFolder)
    end
end

function Library:SaveConfig()
    if writefile then
        local EncodedData = HttpService:JSONEncode(self.Flags)
        pcall(writefile, ConfigFile, EncodedData)
    end
end

function Library:LoadConfig()
    if readfile and isfile and isfile(ConfigFile) then
        local Success, Data = pcall(readfile, ConfigFile)
        if Success then
            local DecodedTable = HttpService:JSONDecode(Data)
            if type(DecodedTable) == "table" then
                for FlagName, SavedValue in pairs(DecodedTable) do
                    self.Flags[FlagName] = SavedValue
                    if self.Elements[FlagName] then
                        task.spawn(self.Elements[FlagName], SavedValue)
                    end
                end
            end
        end
    end
end

-- =============================================================================
-- HIGH-FIDELITY GRADIENT TOAST NOTIFICATION ENGINE
-- =============================================================================
local NotificationGui = Create("ScreenGui", { Name = "RiseHUD_Notifications", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
local NotificationHolder = Create("Frame", {
    Parent = NotificationGui, Size = UDim2.new(0, 290, 1, -40), Position = UDim2.new(1, -20, 0, 25), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1
})
Create("UIListLayout", { Parent = NotificationHolder, VerticalAlignment = Enum.VerticalAlignment.Bottom, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })

function Library:Notify(TitleText, DescText, Duration)
    Duration = Duration or 3.5

    local Toast = Create("Frame", {
        Parent = NotificationHolder, Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = self.Theme.Background, BorderSizePixel = 0, Position = UDim2.new(1, 310, 0, 0)
    })
    Create("UICorner", { Parent = Toast, CornerRadius = UDim.new(0, 6) })
    
    local ToastStroke = Create("UIStroke", { Parent = Toast, Color = Color3.fromRGB(255, 255, 255), Thickness = 1.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    ApplyGradient(ToastStroke, self.Theme.NotificationGradient, 45)

    local LeftStrip = Create("Frame", { Parent = Toast, Size = UDim2.new(0, 4, 1, 0), BorderSizePixel = 0 })
    Create("UICorner", { Parent = LeftStrip, CornerRadius = UDim.new(0, 6) })
    ApplyGradient(LeftStrip, self.Theme.RiseGradient, 90)

    Create("TextLabel", {
        Parent = Toast, Size = UDim2.new(1, -24, 0, 16), Position = UDim2.new(0, 14, 0, 8),
        Text = TitleText:upper(), FontFace = self.FontBold, TextSize = 12, TextColor3 = self.Theme.Text, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("TextLabel", {
        Parent = Toast, Size = UDim2.new(1, -24, 0, 14), Position = UDim2.new(0, 14, 0, 26),
        Text = DescText, FontFace = self.Font, TextSize = 11, TextColor3 = self.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
    })

    Tween(Toast, {Position = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    task.delay(Duration, function()
        if Toast and Toast.Parent then
            local SlideOut = Tween(Toast, {Position = UDim2.new(1, 310, 0, 0)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            SlideOut.Completed:Connect(function() Toast:Destroy() end)
        end
    end)
end

-- =============================================================================
-- INTERFACE WINDOW CONSTRUCTOR (Adaptive Layout Matrix)
-- =============================================================================
function Library:CreateWindow(Options)
    InitializeFileSystem()
    local Window = { Tabs = {}, CurrentTab = nil, Toggled = true }

    -- Scaled structural profiles optimized via mobile configuration viewports
    local WindowSize = IS_MOBILE and UDim2.fromOffset(495, 290) or UDim2.fromOffset(670, 420)
    local WindowPos = IS_MOBILE and UDim2.new(0.5, -247, 0.5, -116) or UDim2.new(0.5, -335, 0.5, -210)

    local RiseMainGui = Create("ScreenGui", { Name = "RiseUI_Framework", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false })
    local MainFrame = Create("Frame", {
        Parent = RiseMainGui, Size = WindowSize, Position = WindowPos, BackgroundColor3 = self.Theme.Background, BorderSizePixel = 0
    })
    Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 8) })
    
    local CoreStroke = Create("UIStroke", { Parent = MainFrame, Color = Color3.fromRGB(255, 255, 255), Thickness = 1.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    ApplyGradient(CoreStroke, self.Theme.RiseGradient, 135)
    MakeDraggable(MainFrame)

    -- Left Navigation Sidebar Panel
    local SidebarWidth = IS_MOBILE and 125 or 160
    local Sidebar = Create("Frame", { Parent = MainFrame, Size = UDim2.new(0, SidebarWidth, 1, 0), BackgroundColor3 = self.Theme.Sidebar, BorderSizePixel = 0 })
    Create("UICorner", { Parent = Sidebar, CornerRadius = UDim.new(0, 8) })
    Create("Frame", { Parent = Sidebar, Size = UDim2.new(0, 15, 1, 0), Position = UDim2.new(1, -15, 0, 0), BackgroundColor3 = self.Theme.Sidebar, BorderSizePixel = 0 })

    local HeaderHeight = IS_MOBILE and 46 or 60
    local BrandingFrame = Create("Frame", { Parent = Sidebar, Size = UDim2.new(1, 0, 0, HeaderHeight), BackgroundTransparency = 1 })
    
    local BrandingLabel = Create("TextLabel", {
        Parent = BrandingFrame, Size = UDim2.new(1, -15, 0, 20), Position = UDim2.new(0, 16, 0.5, -10),
        Text = "RISE PREMIUM", FontFace = self.FontBold, TextSize = IS_MOBILE and 15 or 19, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
    })
    ApplyGradient(BrbrandingLabel, self.Theme.RiseGradient, 0)

    local TabNavigationScroll = Create("ScrollingFrame", {
        Parent = Sidebar, Size = UDim2.new(1, 0, 1, -HeaderHeight), Position = UDim2.new(0, 0, 0, HeaderHeight),
        BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Create("UIListLayout", { Parent = TabNavigationScroll, Padding = UDim.new(0, 3) })
    Create("UIPadding", { Parent = TabNavigationScroll, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

    -- Canvas Workspace Setup
    local ContainerArea = Create("Frame", { Parent = MainFrame, Size = UDim2.new(1, -SidebarWidth, 1, 0), Position = UDim2.new(0, SidebarWidth, 0, 0), BackgroundTransparency = 1 })
    local FilterHeaderBar = Create("Frame", { Parent = ContainerArea, Size = UDim2.new(1, 0, 0, HeaderHeight), BackgroundTransparency = 1 })
    
    local SearchInput = Create("TextBox", {
        Parent = FilterHeaderBar, Size = UDim2.new(1, -30, 0, 26), Position = UDim2.new(0, 16, 0.5, -13),
        BackgroundTransparency = 1, Text = "", PlaceholderText = "Search active registers...",
        FontFace = self.Font, TextSize = IS_MOBILE and 12 or 14, TextColor3 = self.Theme.Text, PlaceholderColor3 = self.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left
    })

    local PageViewDeck = Create("Frame", { Parent = ContainerArea, Size = UDim2.new(1, 0, 1, -HeaderHeight), Position = UDim2.new(0, 0, 0, HeaderHeight), BackgroundTransparency = 1 })

    -- Global Interactive System Intercepts (Desktop Keybind Bindings)
    UserInputService.InputBegan:Connect(function(Input, Processed)
        if not Processed and Input.KeyCode == Enum.KeyCode.RightShift then
            Window.Toggled = not Window.Toggled
            MainFrame.Visible = Window.Toggled
        end
    end)

    -- Floating Mobile Recovery Watermark Menu Button Setup
    local ScreenTouchWatermark = Create("TextButton", {
        Parent = RiseMainGui, Size = UDim2.fromOffset(100, 26), Position = UDim2.new(0, 12, 0, 6),
        BackgroundColor3 = self.Theme.Background, Text = "RISE MENU", FontFace = self.FontBold, TextSize = 10, TextColor3 = self.Theme.Text
    })
    Create("UICorner", { Parent = ScreenTouchWatermark, CornerRadius = UDim.new(0, 4) })
    local WatermarkStroke = Create("UIStroke", { Parent = ScreenTouchWatermark, Color = Color3.fromRGB(255, 255, 255), Thickness = 1 })
    ApplyGradient(WatermarkStroke, self.Theme.RiseGradient, 0)
    
    ScreenTouchWatermark.MouseButton1Click:Connect(function()
        Window.Toggled = not Window.Toggled
        MainFrame.Visible = Window.Toggled
    end)

    -- Matrix Dynamic Query Searching Loop Real-time Connections
    SearchInput.GetPropertyChangedSignal(SearchInput, "Text"):Connect(function()
        local NormalQuery = string.lower(SearchInput.Text)
        for _, ModuleRecord in pairs(Library.Modules) do
            if Window.CurrentTab and ModuleRecord.TabName ~= Window.CurrentTab.Name then continue end
            if NormalQuery == "" or string.find(string.lower(ModuleRecord.Name), NormalQuery) or string.find(string.lower(ModuleRecord.Description), NormalQuery) then
                ModuleRecord.Frame.Visible = true
            else
                ModuleRecord.Frame.Visible = false
            end
        end
    end)

    -- =============================================================================
    -- TAB LAYOUT ARCHITECTURE
    -- =============================================================================
    function Window:MakeTab(TabOptions)
        local Tab = { Name = TabOptions.Name, Elements = {} }
        
        local TabSelectionBtn = Create("TextButton", {
            Parent = TabNavigationScroll, Size = UDim2.new(1, 0, 0, IS_MOBILE and 30 or 35), BackgroundColor3 = Library.Theme.Card, BackgroundTransparency = 1, Text = "", AutoButtonColor = false
        })
        Create("UICorner", { Parent = TabSelectionBtn, CornerRadius = UDim.new(0, 5) })
        
        local LeftIndicatorStrip = Create("Frame", {
            Parent = TabSelectionBtn, Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        })
        ApplyGradient(LeftIndicatorStrip, Library.Theme.RiseGradient, 90)

        local TabTextTitle = Create("TextLabel", {
            Parent = TabSelectionBtn, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 14, 0, 0),
            Text = TabOptions.Name:upper(), FontFace = Library.FontBold, TextSize = IS_MOBILE and 11 or 12, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
        })

        local TabContentScrollCanvas = Create("ScrollingFrame", {
            Parent = PageViewDeck, Size = UDim2.new(1, 0, 1, -5), BackgroundTransparency = 1,
            ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false
        })
        Create("UIListLayout", { Parent = TabContentScrollCanvas, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
        Create("UIPadding", { Parent = TabContentScrollCanvas, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingBottom = UDim.new(0, 12) })

        local function MountTabAction()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Btn, {BackgroundTransparency = 1})
                Tween(Window.CurrentTab.Indicator, {Size = UDim2.new(0, 3, 0, 0)})
                Tween(Window.CurrentTab.Title, {TextColor3 = Library.Theme.SubText})
            end
            Window.CurrentTab = Tab
            Tab.Page.Visible = true
            Tween(TabSelectionBtn, {BackgroundTransparency = 0.4})
            Tween(LeftIndicatorStrip, {Size = UDim2.new(0, 3, 0, 18)})
            Tween(TabTextTitle, {TextColor3 = Library.Theme.Text})
            SearchInput.Text = ""
        end

        TabSelectionBtn.MouseButton1Click:Connect(MountTabAction)
        Tab.Btn = TabSelectionBtn Tab.Page = TabContentScrollCanvas Tab.Indicator = LeftIndicatorStrip Tab.Title = TabTextTitle
        if not Window.CurrentTab then MountTabAction() end

        -- =============================================================================
        -- PREMIUM MASTER MODULE RENDERING FRAME (Gradient Processing Core)
        -- =============================================================================
        function Tab:MakeModule(ModOptions)
            local Module = { 
                Name = ModOptions.Name, 
                Description = ModOptions.Description, 
                TabName = Tab.Name, 
                Enabled = ModOptions.Default or false, 
                Expanded = false, 
                Flag = ModOptions.Flag or ModOptions.Name 
            }
            
            if Library.Flags[Module.Flag] == nil then 
                Library.Flags[Module.Flag] = Module.Enabled 
            else 
                Module.Enabled = Library.Flags[Module.Flag] 
            end

            local CustomCardBoundsHeight = IS_MOBILE and 44 or 50
            local ModuleCardFrame = Create("Frame", { Parent = TabContentScrollCanvas, Size = UDim2.new(1, 0, 0, CustomCardBoundsHeight), BackgroundColor3 = Library.Theme.Card, ClipsDescendants = true, AutomaticSize = Enum.AutomaticSize.Y })
            Create("UICorner", { Parent = ModuleCardFrame, CornerRadius = UDim.new(0, 6) })
            
            local ComponentOutlineStroke = Create("UIStroke", { Parent = ModuleCardFrame, Color = Library.Theme.Stroke, Thickness = 1.1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
            local ModuleGradientOutline = ApplyGradient(ComponentOutlineStroke, Library.Theme.RiseGradient, 0)
            ModuleGradientOutline.Enabled = Module.Enabled

            local ModuleInteractiveHeader = Create("TextButton", { Parent = ModuleCardFrame, Size = UDim2.new(1, 0, 0, CustomCardBoundsHeight), BackgroundTransparency = 1, Text = "" })
            
            local ModuleTextLabel = Create("TextLabel", {
                Parent = ModuleInteractiveHeader, Size = UDim2.new(0, 0, 0, 14), Position = UDim2.new(0, 14, 0, 6),
                Text = ModOptions.Name, FontFace = Library.FontBold, TextSize = IS_MOBILE and 12 or 14, TextColor3 = Library.Theme.Text, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X
            })
            local InlineCategoryTag = Create("TextLabel", {
                Parent = ModuleInteractiveHeader, Size = UDim2.new(0, 0, 0, 14), Text = "[" .. (ModOptions.Category or "Combat") .. "]", 
                FontFace = Library.Font, TextSize = IS_MOBILE and 10 or 11, TextColor3 = Library.Theme.CategoryText, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X
            })
            
            local function DynamicallyComputeSpacing()
                InlineCategoryTag.Position = UDim2.new(0, 20 + ModuleTextLabel.AbsoluteSize.X, 0, 6)
            end
            ModuleTextLabel.Changed:Connect(DynamicallyComputeSpacing)
            DynamicallyComputeSpacing()

            Create("TextLabel", {
                Parent = ModuleInteractiveHeader, Size = UDim2.new(1, -60, 0, 12), Position = UDim2.new(0, 14, 0, IS_MOBILE and 23 or 27),
                Text = ModOptions.Description or "", FontFace = Library.Font, TextSize = IS_MOBILE and 10 or 11, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
            })

            -- Zero-Icon Geometric Submenu Toggle Indicator
            local DropdownExpandActionLabel = Create("TextLabel", {
                Parent = ModuleInteractiveHeader, Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -30, 0.5, -12),
                BackgroundTransparency = 1, Text = "[+]", FontFace = Library.FontBold, TextSize = 13, TextColor3 = Library.Theme.SubText, TextYAlignment = Enum.TextYAlignment.Center
            })

            local SubComponentLayoutContainer = Create("Frame", { Parent = ModuleCardFrame, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, CustomCardBoundsHeight), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Visible = false })
            Create("UIListLayout", { Parent = SubComponentLayoutContainer, Padding = UDim.new(0, 6) })
            Create("UIPadding", { Parent = SubComponentLayoutContainer, PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingBottom = UDim.new(0, 10) })

            local function MutateModuleState(SkipCallback)
                Library.Flags[Module.Flag] = Module.Enabled
                Tween(ModuleCardFrame, {BackgroundColor3 = Module.Enabled and Library.Theme.CardEnabled or Library.Theme.Card})
                ModuleGradientOutline.Enabled = Module.Enabled
                ComponentOutlineStroke.Color = Module.Enabled and Color3.fromRGB(255, 255, 255) or Library.Theme.Stroke
                
                if not SkipCallback and ModOptions.Callback then 
                    task.spawn(ModOptions.Callback, Module.Enabled) 
                end
                Library:SaveConfig()
            end

            ModuleInteractiveHeader.MouseButton1Click:Connect(function()
                Module.Enabled = not Module.Enabled
                MutateModuleState(false)
            end)
            
            DropdownExpandActionLabel.InputBegan:Connect(function(InputInput)
                if InputInput.UserInputType == Enum.UserInputType.MouseButton1 or InputInput.UserInputType == Enum.UserInputType.Touch then
                    Module.Expanded = not Module.Expanded
                    SubComponentLayoutContainer.Visible = Module.Expanded
                    DropdownExpandActionLabel.Text = Module.Expanded and "[-]" or "[+]"
                    DropdownExpandActionLabel.TextColor3 = Module.Expanded and Color3.fromRGB(255, 255, 255) or Library.Theme.SubText
                end
            end)

            Library.Elements[Module.Flag] = function(TargetValueData)
                Module.Enabled = TargetValueData
                MutateModuleState(true)
            end

            Module.Frame = ModuleCardFrame
            table.insert(Library.Modules, Module)
            MutateModuleState(true)

            -- =============================================================================
            -- FACTORY ELEMENT INTERNALS: SLIDER COMPONENT
            -- =============================================================================
            function Module:AddSlider(SliderConfigurationOptions)
                local Slider = { 
                    Value = SliderConfigurationOptions.Default or SliderConfigurationOptions.Min, 
                    Flag = SliderConfigurationOptions.Flag or SliderConfigurationOptions.Name, 
                    Sliding = false 
                }
                
                if Library.Flags[Slider.Flag] == nil then 
                    Library.Flags[Slider.Flag] = Slider.Value 
                else 
                    Slider.Value = Library.Flags[Slider.Flag] 
                end

                local SliderHostFrame = Create("Frame", { Parent = SubComponentLayoutContainer, Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1 })
                
                Create("TextLabel", {
                    Parent = SliderHostFrame, Size = UDim2.new(1, -70, 0, 12), Position = UDim2.new(0, 0, 0, 2),
                    Text = SliderConfigurationOptions.Name, FontFace = Library.Font, TextSize = 11, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
                })
                local DynamicValueLabel = Create("TextLabel", {
                    Parent = SliderHostFrame, Size = UDim2.new(0, 70, 0, 12), Position = UDim2.new(1, -70, 0, 2),
                    Text = tostring(Slider.Value), FontFace = Library.FontBold, TextSize = 11, TextColor3 = Library.Theme.Text, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right
                })
                local SlideRailTrackButton = Create("TextButton", {
                    Parent = SliderHostFrame, Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 1, -4), BackgroundColor3 = Library.Theme.ElementBg, Text = "", AutoButtonColor = false
                })
                Create("UICorner", { Parent = SlideRailTrackButton, CornerRadius = UDim.new(1, 0) })
                
                local FillTrackVisualFrame = Create("Frame", { Parent = SlideRailTrackButton, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 })
                Create("UICorner", { Parent = FillTrackVisualFrame, CornerRadius = UDim.new(1, 0) })
                ApplyGradient(FillTrackVisualFrame, Library.Theme.SliderGradient, 0)

                local function RecomputeSliderScaleMath(RawValueData, SkipCallbackExecution)
                    local MathematicalFactor = 10 ^ (SliderConfigurationOptions.Decimals or 0)
                    Slider.Value = math.clamp(math.floor(RawValueData * MathematicalFactor) / MathematicalFactor, SliderConfigurationOptions.Min, SliderConfigurationOptions.Max)
                    DynamicValueLabel.Text = tostring(Slider.Value) .. (SliderConfigurationOptions.Suffix or "")
                    
                    local PercentageRatio = (Slider.Value - SliderConfigurationOptions.Min) / (SliderConfigurationOptions.Max - SliderConfigurationOptions.Min)
                    Tween(FillTrackVisualFrame, {Size = UDim2.new(PercentageRatio, 0, 1, 0)}, 0.05)
                    
                    Library.Flags[Slider.Flag] = Slider.Value
                    if not SkipCallbackExecution and SliderConfigurationOptions.Callback then 
                        task.spawn(SliderConfigurationOptions.Callback, Slider.Value) 
                    end
                    Library:SaveConfig()
                end

                SlideRailTrackButton.InputBegan:Connect(function(InteractionEventInput)
                    if InteractionEventInput.UserInputType == Enum.UserInputType.MouseButton1 or InteractionEventInput.UserInputType == Enum.UserInputType.Touch then
                        Slider.Sliding = true
                        local CurrentPercentage = math.clamp((InteractionEventInput.Position.X - SlideRailTrackButton.AbsolutePosition.X) / SlideRailTrackButton.AbsoluteSize.X, 0, 1)
                        RecomputeSliderScaleMath(SliderConfigurationOptions.Min + (SliderConfigurationOptions.Max - SliderConfigurationOptions.Min) * CurrentPercentage, false)
                    end
                end)
                UserInputService.InputChanged:Connect(function(InteractionEventInput)
                    if Slider.Sliding and (InteractionEventInput.UserInputType == Enum.UserInputType.MouseMovement or InteractionEventInput.UserInputType == Enum.UserInputType.Touch) then
                        local CurrentPercentage = math.clamp((InteractionEventInput.Position.X - SlideRailTrackButton.AbsolutePosition.X) / SlideRailTrackButton.AbsoluteSize.X, 0, 1)
                        RecomputeSliderScaleMath(SliderConfigurationOptions.Min + (SliderConfigurationOptions.Max - SliderConfigurationOptions.Min) * CurrentPercentage, false)
                    end
                end)
                UserInputService.InputEnded:Connect(function(InteractionEventInput)
                    if InteractionEventInput.UserInputType == Enum.UserInputType.MouseButton1 or InteractionEventInput.UserInputType == Enum.UserInputType.Touch then 
                        Slider.Sliding = false 
                    end
                end)

                Library.Elements[Slider.Flag] = function(TargetInjectedUpdateValue) 
                    RecomputeSliderScaleMath(TargetInjectedUpdateValue, true) 
                end
                RecomputeSliderScaleMath(Slider.Value, true)
            end

            -- =============================================================================
            -- FACTORY ELEMENT INTERNALS: TOGGLE SUB-COMPONENT
            -- =============================================================================
            function Module:AddToggle(ToggleConfigurationOptions)
                local Toggle = { State = ToggleConfigurationOptions.Default or false, Flag = ToggleConfigurationOptions.Flag or ToggleConfigurationOptions.Name }
                if Library.Flags[Toggle.Flag] == nil then Library.Flags[Toggle.Flag] = Toggle.State else Toggle.State = Library.Flags[Toggle.Flag] end

                local ToggleRowHostButton = Create("TextButton", { Parent = SubComponentLayoutContainer, Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "" })
                Create("TextLabel", {
                    Parent = ToggleRowHostButton, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 0, 0, 0),
                    Text = ToggleConfigurationOptions.Name, FontFace = Library.Font, TextSize = 11, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
                })
                local CheckboxBoundaryFrame = Create("Frame", { Parent = ToggleRowHostButton, Size = UDim2.fromOffset(13, 13), Position = UDim2.new(1, -13, 0.5, -6), BackgroundColor3 = Library.Theme.ElementBg })
                Create("UICorner", { Parent = CheckboxBoundaryFrame, CornerRadius = UDim.new(0, 3) })
                
                local CheckboxStrokeBorder = Create("UIStroke", { Parent = CheckboxBoundaryFrame, Color = Library.Theme.Stroke, Thickness = 1 })
                local CheckboxGradientMapping = ApplyGradient(CheckboxStrokeBorder, Library.Theme.RiseGradient, 0)
                CheckboxGradientMapping.Enabled = Toggle.State

                local ToggleStatusColorFillFrame = Create("Frame", { Parent = CheckboxBoundaryFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })
                Create("UICorner", { Parent = ToggleStatusColorFillFrame, CornerRadius = UDim.new(0, 3) })
                ApplyGradient(ToggleStatusColorFillFrame, Library.Theme.RiseGradient, 45)

                local function RecomputeToggleVisualStates(SkipCallbackExecution)
                    Library.Flags[Toggle.Flag] = Toggle.State
                    Tween(ToggleStatusColorFillFrame, {BackgroundTransparency = Toggle.State and 0 or 1}, 0.1)
                    CheckboxGradientMapping.Enabled = Toggle.State
                    CheckboxStrokeBorder.Color = Toggle.State and Color3.fromRGB(255, 255, 255) or Library.Theme.Stroke
                    
                    if not SkipCallbackExecution and ToggleConfigurationOptions.Callback then 
                        task.spawn(ToggleConfigurationOptions.Callback, Toggle.State) 
                    end
                    Library:SaveConfig()
                end

                ToggleRowHostButton.MouseButton1Click:Connect(function() 
                    Toggle.State = not Toggle.State 
                    RecomputeToggleVisualStates(false) 
                end)
                Library.Elements[Toggle.Flag] = function(TargetInjectedUpdateValue) 
                    Toggle.State = TargetInjectedUpdateValue 
                    RecomputeToggleVisualStates(true) 
                end
                RecomputeToggleVisualStates(true)
            end

            -- =============================================================================
            -- FACTORY ELEMENT INTERNALS: DROPDOWN COMPONENT (Multi / Single Mode)
            -- =============================================================================
            function Module:AddDropdown(DropdownConfigurationOptions)
                local Dropdown = {
                    List = DropdownConfigurationOptions.Options or {},
                    Selected = {},
                    Multi = DropdownConfigurationOptions.Multi or false,
                    Flag = DropdownConfigurationOptions.Flag or DropdownConfigurationOptions.Name,
                    Open = false
                }

                if Library.Flags[Dropdown.Flag] == nil then
                    Library.Flags[Dropdown.Flag] = DropdownConfigurationOptions.Default or (Dropdown.Multi and {} or "")
                end
                
                local RawInitialConfigCache = Library.Flags[Dropdown.Flag]
                if Dropdown.Multi then
                    if type(RawInitialConfigCache) == "table" then Dropdown.Selected = RawInitialConfigCache end
                else
                    if type(RawInitialConfigCache) == "string" then Dropdown.Selected = { [RawInitialConfigCache] = true } end
                end

                local DropdownHostBaseContainerFrame = Create("Frame", { Parent = SubComponentLayoutContainer, Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
                Create("TextLabel", { Parent = DropdownHostBaseContainerFrame, Size = UDim2.new(1, 0, 0, 12), Text = DropdownConfigurationOptions.Name, FontFace = Library.Font, TextSize = 11, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
                
                local DropdownSelectorTriggerButton = Create("TextButton", { Parent = DropdownHostBaseContainerFrame, Size = UDim2.new(1, 0, 0, 22), Position = UDim2.new(0, 0, 0, 16), BackgroundColor3 = Library.Theme.ElementBg, Text = "", AutoButtonColor = false })
                Create("UICorner", { Parent = DropdownSelectorTriggerButton, CornerRadius = UDim.new(0, 4) })
                local DropdownFrameBorderStroke = Create("UIStroke", { Parent = DropdownSelectorTriggerButton, Color = Library.Theme.Stroke, Thickness = 1 })

                local SelectionDisplayStringTextLabel = Create("TextLabel", { Parent = DropdownSelectorTriggerButton, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 10, 0, 0), Text = "None", FontFace = Library.Font, TextSize = 11, TextColor3 = Library.Theme.Text, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
                local DropdownChevronStateIndicator = Create("TextLabel", { Parent = DropdownSelectorTriggerButton, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -22, 0, 0), Text = "v", FontFace = Library.FontBold, TextSize = 10, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1 })

                local CollapsibleOptionsScrollCanvas = Create("ScrollingFrame", { Parent = DropdownHostBaseContainerFrame, Size = UDim2.new(1, 0, 0, 85), Position = UDim2.new(0, 0, 0, 42), BackgroundColor3 = Library.Theme.ElementBg, Visible = false, ScrollBarThickness = 1, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y })
                Create("UICorner", { Parent = CollapsibleOptionsScrollCanvas, CornerRadius = UDim.new(0, 4) })
                local OptionsMenuOutlineBorderStroke = Create("UIStroke", { Parent = CollapsibleOptionsScrollCanvas, Color = Library.Theme.Stroke, Thickness = 1 })
                Create("UIListLayout", { Parent = CollapsibleOptionsScrollCanvas, Padding = UDim.new(0, 2) })

                local function RecomputeRefreshSelectionLayouts(SkipCallbacks)
                    local SubstringAccumulatorList = {}
                    for _, OptionNameKey in ipairs(Dropdown.List) do
                        if Dropdown.Selected[OptionNameKey] then
                            table.insert(SubstringAccumulatorList, OptionNameKey)
                        end
                    end
                    
                    local OutputDisplayString = #SubstringAccumulatorList > 0 and table.concat(SubstringAccumulatorList, ", ") or "None"
                    SelectionDisplayStringTextLabel.Text = OutputDisplayString
                    
                    if Dropdown.Multi then
                        Library.Flags[Dropdown.Flag] = Dropdown.Selected
                        if not SkipCallbacks and DropdownConfigurationOptions.Callback then task.spawn(DropdownConfigurationOptions.Callback, Dropdown.Selected) end
                    else
                        local CoreSelectionSingleValue = SubstringAccumulatorList[1] or ""
                        Library.Flags[Dropdown.Flag] = CoreSelectionSingleValue
                        if not SkipCallbacks and DropdownConfigurationOptions.Callback then task.spawn(DropdownConfigurationOptions.Callback, CoreSelectionSingleValue) end
                    end
                    Library:SaveConfig()
                end

                local function GenerateOptionsMatrixDeck()
                    for _, ChildNodeItem in ipairs(CollapsibleOptionsScrollCanvas:GetChildren()) do
                        if ChildNodeItem:IsA("TextButton") then ChildNodeItem:Destroy() end
                    end

                    for _, OptionItemNameString in ipairs(Dropdown.List) do
                        local OptionRowButton = Create("TextButton", { Parent = CollapsibleOptionsScrollCanvas, Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = Library.Theme.Card, BackgroundTransparency = 1, Text = "", AutoButtonColor = false })
                        local ActiveRowTextLabel = Create("TextLabel", { Parent = OptionRowButton, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), Text = OptionItemNameString, FontFace = Library.Font, TextSize = 11, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
                        
                        if Dropdown.Selected[OptionItemNameString] then
                            ActiveRowTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            OptionRowButton.BackgroundTransparency = 0.8
                        end

                        OptionRowButton.MouseButton1Click:Connect(function()
                            if Dropdown.Multi then
                                Dropdown.Selected[OptionItemNameString] = not Dropdown.Selected[OptionItemNameString]
                            else
                                table.clear(Dropdown.Selected)
                                Dropdown.Selected[OptionItemNameString] = true
                                Dropdown.Open = false
                                CollapsibleOptionsScrollCanvas.Visible = false
                                DropdownChevronStateIndicator.Text = "v"
                            end
                            GenerateOptionsMatrixDeck()
                            RecomputeRefreshSelectionLayouts(false)
                        end)
                    end
                end

                DropdownSelectorTriggerButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    CollapsibleOptionsScrollCanvas.Visible = Dropdown.Open
                    DropdownChevronStateIndicator.Text = Dropdown.Open and "^" or "v"
                end)

                Library.Elements[Dropdown.Flag] = function(TargetInjectedUpdateValue)
                    if Dropdown.Multi then
                        if type(TargetInjectedUpdateValue) == "table" then Dropdown.Selected = TargetInjectedUpdateValue end
                    else
                        if type(TargetInjectedUpdateValue) == "string" then
                            table.clear(Dropdown.Selected)
                            if TargetInjectedUpdateValue ~= "" then Dropdown.Selected[TargetInjectedUpdateValue] = true end
                        end
                    end
                    GenerateOptionsMatrixDeck()
                    RecomputeRefreshSelectionLayouts(true)
                end

                GenerateOptionsMatrixDeck()
                RecomputeRefreshSelectionLayouts(true)
            end

            -- =============================================================================
            -- FACTORY ELEMENT INTERNALS: KEYBIND UTILITY ARCHITECTURE
            -- =============================================================================
            function Module:AddKeybind(KeybindConfigurationOptions)
                local Keybind = {
                    Value = KeybindConfigurationOptions.Default or Enum.KeyCode.Unknown,
                    Flag = KeybindConfigurationOptions.Flag or KeybindConfigurationOptions.Name,
                    Binding = false
                }

                if Library.Flags[Keybind.Flag] == nil then
                    Library.Flags[Keybind.Flag] = Keybind.Value.Name
                else
                    Keybind.Value = Enum.KeyCode[Library.Flags[Keybind.Flag]] or Enum.KeyCode.Unknown
                end

                local KeybindRowHostFrame = Create("Frame", { Parent = SubComponentLayoutContainer, Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1 })
                Create("TextLabel", { Parent = KeybindRowHostFrame, Size = UDim2.new(1, -80, 1, 0), Text = KeybindConfigurationOptions.Name, FontFace = Library.Font, TextSize = 11, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
                
                local KeybindTriggerCaptureButton = Create("TextButton", { Parent = KeybindRowHostFrame, Size = UDim2.fromOffset(75, 16), Position = UDim2.new(1, -75, 0.5, -8), BackgroundColor3 = Library.Theme.ElementBg, Text = Keybind.Value.Name:upper(), FontFace = Library.FontBold, TextSize = 9, TextColor3 = Library.Theme.Text })
                Create("UICorner", { Parent = KeybindTriggerCaptureButton, CornerRadius = UDim.new(0, 3) })
                local CaptureOutlineStroke = Create("UIStroke", { Parent = KeybindTriggerCaptureButton, Color = Library.Theme.Stroke, Thickness = 1 })

                KeybindTriggerCaptureButton.MouseButton1Click:Connect(function()
                    Keybind.Binding = true
                    KeybindTriggerCaptureButton.Text = "..."
                    CaptureOutlineStroke.Color = Color3.fromRGB(255, 255, 255)
                end)

                UserInputService.InputBegan:Connect(function(CapturedInputEvent, EngineProcessedEvent)
                    if Keybind.Binding and not EngineProcessedEvent then
                        if CapturedInputEvent.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind.Binding = false
                            Keybind.Value = CapturedInputEvent.KeyCode
                            KeybindTriggerCaptureButton.Text = Keybind.Value.Name:upper()
                            CaptureOutlineStroke.Color = Library.Theme.Stroke
                            
                            Library.Flags[Keybind.Flag] = Keybind.Value.Name
                            Library:SaveConfig()
                            if KeybindConfigurationOptions.Callback then task.spawn(KeybindConfigurationOptions.Callback, Keybind.Value) end
                        end
                    elseif not EngineProcessedEvent and CapturedInputEvent.KeyCode == Keybind.Value then
                        Module.Enabled = not Module.Enabled
                        Library.Elements[Module.Flag](Module.Enabled)
                    end
                end)

                Library.Elements[Keybind.Flag] = function(TargetInjectedUpdateValue)
                    Keybind.Value = Enum.KeyCode[TargetInjectedUpdateValue] or Enum.KeyCode.Unknown
                    KeybindTriggerCaptureButton.Text = Keybind.Value.Name:upper()
                end
            end

            -- =============================================================================
            -- FACTORY ELEMENT INTERNALS: COLOR PICKER ENGINE
            -- =============================================================================
            function Module:AddColorPicker(PickerConfigurationOptions)
                local Picker = {
                    Value = PickerConfigurationOptions.Default or Color3.fromRGB(255, 255, 255),
                    Flag = PickerConfigurationOptions.Flag or PickerConfigurationOptions.Name,
                    Rainbow = false
                }

                if Library.Flags[Picker.Flag] == nil then
                    Library.Flags[Picker.Flag] = { Picker.Value.R, Picker.Value.G, Picker.Value.B }
                else
                    local SavedRgbCache = Library.Flags[Picker.Flag]
                    Picker.Value = Color3.new(SavedRgbCache[1], SavedRgbCache[2], SavedRgbCache[3])
                end

                local PickerRowHostFrame = Create("Frame", { Parent = SubComponentLayoutContainer, Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1 })
                Create("TextLabel", { Parent = PickerRowHostFrame, Size = UDim2.new(1, -40, 1, 0), Text = PickerConfigurationOptions.Name, FontFace = Library.Font, TextSize = 11, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
                
                local ColorPreviewBlockButton = Create("TextButton", { Parent = PickerRowHostFrame, Size = UDim2.fromOffset(26, 13), Position = UDim2.new(1, -26, 0.5, -6), BackgroundColor3 = Picker.Value, Text = "" })
                Create("UICorner", { Parent = ColorPreviewBlockButton, CornerRadius = UDim.new(0, 3) })
                local PreviewBlockBorderStroke = Create("UIStroke", { Parent = ColorPreviewBlockButton, Color = Library.Theme.Stroke, Thickness = 1 })

                local ExpandedColorSlidersPanelFrame = Create("Frame", { Parent = SubComponentLayoutContainer, Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Library.Theme.ElementBg, Visible = false })
                Create("UICorner", { Parent = ExpandedColorSlidersPanelFrame, CornerRadius = UDim.new(0, 4) })
                Create("UIListLayout", { Parent = ExpandedColorSlidersPanelFrame, Padding = UDim.new(0, 2) })
                Create("UIPadding", { Parent = ExpandedColorSlidersPanelFrame, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 4) })

                local function RecomputeColorOutputPipeline(SkipCallbacks)
                    ColorPreviewBlockButton.BackgroundColor3 = Picker.Value
                    Library.Flags[Picker.Flag] = { Picker.Value.R, Picker.Value.G, Picker.Value.B }
                    if not SkipCallbacks and PickerConfigurationOptions.Callback then task.spawn(PickerConfigurationOptions.Callback, Picker.Value) end
                    Library:SaveConfig()
                end

                local function SpawnInternalColorChannelSlider(ChannelName, ChannelMin, ChannelMax, InitialChannelValue, UpdateChannelCallback)
                    local ChannelRowFrame = Create("Frame", { Parent = ExpandedColorSlidersPanelFrame, Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1 })
                    Create("TextLabel", { Parent = ChannelRowFrame, Size = UDim2.new(0, 15, 1, 0), Text = ChannelName, FontFace = Library.FontBold, TextSize = 9, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1 })
                    
                    local SliderChannelRailButton = Create("TextButton", { Parent = ChannelRowFrame, Size = UDim2.new(1, -20, 0, 3), Position = UDim2.new(0, 20, 0.5, -1), BackgroundColor3 = Library.Theme.Card, Text = "", AutoButtonColor = false })
                    local SliderChannelFillFrame = Create("Frame", { Parent = SliderChannelRailButton, Size = UDim2.new(InitialChannelValue / ChannelMax, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(200, 200, 200), BorderSizePixel = 0 })
                    
                    local SlidingActiveState = false
                    local function RecomputeSliderChannelInput(RawInputPositionX)
                        local PercentageRatio = math.clamp((RawInputPositionX - SliderChannelRailButton.AbsolutePosition.X) / SliderChannelRailButton.AbsoluteSize.X, 0, 1)
                        SliderChannelFillFrame.Size = UDim2.new(PercentageRatio, 0, 1, 0)
                        UpdateChannelCallback(ChannelMin + (ChannelMax - ChannelMin) * PercentageRatio)
                    end

                    SliderChannelRailButton.InputBegan:Connect(function(InputEvent)
                        if InputEvent.UserInputType == Enum.UserInputType.MouseButton1 or InputEvent.UserInputType == Enum.UserInputType.Touch then
                            SlidingActiveState = true RecomputeSliderChannelInput(InputEvent.Position.X)
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(InputEvent)
                        if SlidingActiveState and (InputEvent.UserInputType == Enum.UserInputType.MouseMovement or InputEvent.UserInputType == Enum.UserInputType.Touch) then
                            RecomputeSliderChannelInput(InputEvent.Position.X)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(InputEvent)
                        if InputEvent.UserInputType == Enum.UserInputType.MouseButton1 or InputEvent.UserInputType == Enum.UserInputType.Touch then SlidingActiveState = false end
                    end)
                end

                ColorPreviewBlockButton.MouseButton1Click:Connect(function()
                    ExpandedColorSlidersPanelFrame.Visible = not ExpandedColorSlidersPanelFrame.Visible
                end)

                SpawnInternalColorChannelSlider("R", 0, 1, Picker.Value.R, function(ValueR) Picker.Value = Color3.new(ValueR, Picker.Value.G, Picker.Value.B) RecomputeColorOutputPipeline(false) end)
                SpawnInternalColorChannelSlider("G", 0, 1, Picker.Value.G, function(ValueG) Picker.Value = Color3.new(Picker.Value.R, ValueG, Picker.Value.B) RecomputeColorOutputPipeline(false) end)
                SpawnInternalColorChannelSlider("B", 0, 1, Picker.Value.B, function(ValueB) Picker.Value = Color3.new(Picker.Value.R, Picker.Value.G, ValueB) RecomputeColorOutputPipeline(false) end)

                Library.Elements[Picker.Flag] = function(TargetInjectedUpdateValue)
                    if type(TargetInjectedUpdateValue) == "table" then
                        Picker.Value = Color3.new(TargetInjectedUpdateValue[1], TargetInjectedUpdateValue[2], TargetInjectedUpdateValue[3])
                        RecomputeColorOutputPipeline(true)
                    end
                end

                RecomputeColorOutputPipeline(true)
            end

            -- =============================================================================
            -- FACTORY ELEMENT INTERNALS: TEXTBOX SELECTION INTERCEPT
            -- =============================================================================
            function Module:AddTextBox(TextboxConfigurationOptions)
                local Textbox = { Value = TextboxConfigurationOptions.Default or "", Flag = TextboxConfigurationOptions.Flag or TextboxConfigurationOptions.Name }
                if Library.Flags[Textbox.Flag] == nil then Library.Flags[Textbox.Flag] = Textbox.Value else Textbox.Value = Library.Flags[Textbox.Flag] end

                local TextboxRowHostFrame = Create("Frame", { Parent = SubComponentLayoutContainer, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1 })
                Create("TextLabel", { Parent = TextboxRowHostFrame, Size = UDim2.new(1, 0, 0, 12), Text = TextboxConfigurationOptions.Name, FontFace = Library.Font, TextSize = 11, TextColor3 = Library.Theme.SubText, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
                
                local RealTextInputField = Create("TextBox", {
                    Parent = TextboxRowHostFrame, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 14),
                    BackgroundColor3 = Library.Theme.ElementBg, Text = Textbox.Value, PlaceholderText = TextboxConfigurationOptions.Placeholder or "Type structural parameter...",
                    FontFace = Library.Font, TextSize = 11, TextColor3 = Library.Theme.Text, PlaceholderColor3 = Library.Theme.CategoryText, ClearTextOnFocus = false
                })
                Create("UICorner", { Parent = RealTextInputField, CornerRadius = UDim.new(0, 4) })
                local TextfieldOutlineBorderStroke = Create("UIStroke", { Parent = RealTextInputField, Color = Library.Theme.Stroke, Thickness = 1 })

                RealTextInputField.FocusLost:Connect(function(EnterKeyPressed)
                    Textbox.Value = RealTextInputField.Text
                    Library.Flags[Textbox.Flag] = Textbox.Value
                    if TextboxConfigurationOptions.Callback then task.spawn(TextboxConfigurationOptions.Callback, Textbox.Value, EnterKeyPressed) end
                    Library:SaveConfig()
                end)

                Library.Elements[Textbox.Flag] = function(TargetInjectedUpdateValue)
                    Textbox.Value = TargetInjectedUpdateValue
                    RealTextInputField.Text = TargetInjectedUpdateValue
                end
            end

            -- =============================================================================
            -- FACTORY ELEMENT INTERNALS: INSTANT EXECUTE BUTTON COMPONENT
            -- =============================================================================
            function Module:AddButton(ButtonConfigurationOptions)
                local ButtonRowTrigger = Create("TextButton", {
                    Parent = SubComponentLayoutContainer, Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = Library.Theme.ElementBg,
                    Text = ButtonConfigurationOptions.Name:upper(), FontFace = Library.FontBold, TextSize = 10, TextColor3 = Library.Theme.Text, AutoButtonColor = false
                })
                Create("UICorner", { Parent = ButtonRowTrigger, CornerRadius = UDim.new(0, 4) })
                local ButtonOutlineBorderStroke = Create("UIStroke", { Parent = ButtonRowTrigger, Color = Library.Theme.Stroke, Thickness = 1 })

                ButtonRowTrigger.MouseButton1Click:Connect(function()
                    Tween(ButtonRowTrigger, {BackgroundColor3 = Library.Theme.CardHover}, 0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    task.delay(0.08, function() Tween(ButtonRowTrigger, {BackgroundColor3 = Library.Theme.ElementBg}, 0.1) end)
                    if ButtonConfigurationOptions.Callback then task.spawn(ButtonConfigurationOptions.Callback) end
                end)
            end

            return Module
        end
        return Tab
    end
    
    task.spawn(function() Library:LoadConfig() end)
    return Window
end

return Library
