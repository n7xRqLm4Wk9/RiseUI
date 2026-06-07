--[[
    Rise UI Framework
    Premium High-Performance User Interface Library
    Fully Polished & Zero-Leak Architecture
--]]

local Library do
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")

    gethui = gethui or function()
        return CoreGui
    end

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex

    local RGBSequence = ColorSequence.new
    local RGBSequenceKeypoint = ColorSequenceKeypoint.new
    local NumSequence = NumberSequence.new
    local NumSequenceKeypoint = NumberSequenceKeypoint.new

    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local UDim2FromOffset = UDim2.fromOffset
    local Vector2New = Vector2.new
    local Vector3New = Vector3.new

    local MathClamp = math.clamp
    local MathFloor = math.floor
    local MathAbs = math.abs
    local MathSin = math.sin

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub
    local StringLower = string.lower
    local StringLen = string.len

    local InstanceNew = Instance.new
    local RectNew = Rect.new

    local IsMobile = UserInputService.TouchEnabled or false

    Library = {
        Theme =  { },
        ToClean = { },
        MenuKeybind = tostring(Enum.KeyCode.Insert), 
        Flags = { },
        Tween = {
            Time = 0.3,
            Style = Enum.EasingStyle.Quad,
            Direction = Enum.EasingDirection.Out
        },
        FadeSpeed = 0.2,
        Folders = {
            Directory = "lyapossss",
            Configs = "lyapossss/Configs",
            Assets = "lyapossss/Assets",
        },
        Pages = { },
        Sections = { },
        Connections = { },
        Threads = { },
        ThemeMap = { },
        ThemeItems = { },
        OpenFrames = { },
        SetFlags = { },
        UnnamedConnections = 0,
        UnnamedFlags = 0,
        Holder = nil,
        NotifHolder = nil,
        UnusedHolder = nil,
        Font = nil
    }

    Library.__index = Library
    Library.Sections.__index = Library.Sections
    Library.Pages.__index = Library.Pages

    local Keys = {
        ["Unknown"]           = "Unknown",
        ["Backspace"]         = "Back",
        ["Tab"]               = "Tab",
        ["Clear"]             = "Clear",
        ["Return"]            = "Return",
        ["Pause"]             = "Pause",
        ["Escape"]            = "Escape",
        ["Space"]             = "Space",
        ["QuotedDouble"]      = '"',
        ["Hash"]              = "#",
        ["Dollar"]            = "$",
        ["Percent"]           = "%",
        ["Ampersand"]         = "&",
        ["Quote"]             = "'",
        ["LeftParenthesis"]   = "(",
        ["RightParenthesis"]  = " )",
        ["Asterisk"]          = "*",
        ["Plus"]              = "+",
        ["Comma"]             = ",",
        ["Minus"]             = "-",
        ["Period"]            = ".",
        ["Slash"]             = "`",
        ["Three"]             = "3",
        ["Seven"]             = "7",
        ["Eight"]             = "8",
        ["Colon"]             = ":",
        ["Semicolon"]         = ";",
        ["LessThan"]          = "<",
        ["GreaterThan"]       = ">",
        ["Question"]          = "?",
        ["Equals"]            = "=",
        ["At"]                = "@",
        ["LeftBracket"]       = "LeftBracket",
        ["RightBracket"]      = "RightBracked",
        ["BackSlash"]         = "BackSlash",
        ["Caret"]             = "^",
        ["Underscore"]        = "_",
        ["Backquote"]         = "`",
        ["LeftCurly"]         = "{",
        ["Pipe"]              = "|",
        ["RightCurly"]        = "}",
        ["Tilde"]             = "~",
        ["Delete"]            = "Delete",
        ["End"]               = "End",
        ["KeypadZero"]        = "Keypad0",
        ["KeypadOne"]         = "Keypad1",
        ["KeypadTwo"]         = "Keypad2",
        ["KeypadThree"]       = "Keypad3",
        ["KeypadFour"]        = "Keypad4",
        ["KeypadFive"]        = "Keypad5",
        ["KeypadSix"]         = "Keypad6",
        ["KeypadSeven"]       = "Keypad7",
        ["KeypadEight"]       = "Keypad8",
        ["KeypadNine"]        = "Keypad9",
        ["KeypadPeriod"]      = "KeypadP",
        ["KeypadDivide"]      = "KeypadD",
        ["KeypadMultiply"]    = "KeypadM",
        ["KeypadMinus"]       = "KeypadM",
        ["KeypadPlus"]        = "KeypadP",
        ["KeypadEnter"]       = "KeypadE",
        ["KeypadEquals"]      = "KeypadE",
        ["Insert"]            = "Insert",
        ["Home"]              = "Home",
        ["PageUp"]            = "PageUp",
        ["PageDown"]          = "PageDown",
        ["RightShift"]        = "RightShift",
        ["LeftShift"]         = "LeftShift",
        ["RightControl"]      = "RightControl",
        ["LeftControl"]       = "LeftControl",
        ["LeftAlt"]           = "LeftAlt",
        ["RightAlt"]          = "RightAlt"
    }

    local Themes = {
        ["Preset"] = {
            ["AccentGradient"] = FromRGB(0, 195, 255),
            ["Background 2"] = FromRGB(10, 10, 12),
            ["Background"] = FromRGB(12, 12, 14),
            ["Text"] = FromRGB(235, 235, 235),
            ["Outline"] = FromRGB(25, 25, 28),
            ["Section Top"] = FromRGB(28, 27, 31),
            ["Section Background"] = FromRGB(10, 10, 12),
            ["Section Background 2"] = FromRGB(14, 14, 16),
            ["Accent"] = FromRGB(0, 116, 224),
            ["Element"] = FromRGB(16, 16, 18)
        }
    }

    Library.Theme = TableClone(Themes["Preset"])

    for Index, Value in Library.Folders do 
        if not isfolder(Value) then
            makefolder(Value)
        end
    end

    -- ==========================================
    -- TWEENING ENGINE
    -- ==========================================
    local Tween = { } do
        Tween.__index = Tween

        Tween.Create = function(self, Item, Info, Goal, IsRawItem)
            Item = IsRawItem and Item or Item.Instance
            Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)

            local NewTween = {
                Tween = TweenService:Create(Item, Info, Goal),
                Info = Info,
                Goal = Goal,
                Item = Item
            }
            NewTween.Tween:Play()
            setmetatable(NewTween, Tween)
            return NewTween
        end

        Tween.GetProperty = function(self, Item)
            Item = Item or self.Item 
            if Item:IsA("Frame") then
                return { "BackgroundTransparency" }
            elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
                return { "BackgroundTransparency", "ImageTransparency" }
            elseif Item:IsA("ScrollingFrame") then
                return { "BackgroundTransparency", "ScrollBarImageTransparency" }
            elseif Item:IsA("TextBox") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("UIStroke") then 
                return { "Transparency" }
            end
        end

        Tween.FadeItem = function(self, Item, Property, Visibility, Speed)
            local OldTransparency = Item[Property]
            Item[Property] = Visibility and 1 or OldTransparency

            local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = Visibility and OldTransparency or 1
            }, true)

            Library:Connect(NewTween.Tween.Completed, function()
                if not Visibility then 
                    task.wait()
                    Item[Property] = OldTransparency
                end
            end)
            return NewTween
        end

        Tween.Pause = function(self) if self.Tween then self.Tween:Pause() end end
        Tween.Play = function(self) if self.Tween then self.Tween:Play() end end
        Tween.Clean = function(self) if self.Tween then self:Pause() self = nil end end
    end

    -- ==========================================
    -- INSTANCE WRAPPER FACTORY
    -- ==========================================
    local Instances = { } do
        Instances.__index = Instances

        Instances.Create = function(self, Class, Properties)
            local NewItem = {
                Instance = InstanceNew(Class),
                Properties = Properties,
                Class = Class
            }
            setmetatable(NewItem, Instances)
            for Property, Value in NewItem.Properties do
                NewItem.Instance[Property] = Value
            end
            return NewItem
        end

        Instances.FadeItem = function(self, Visibility, Speed)
            local Item = self.Instance
            if Visibility == true then Item.Visible = true end
            local Descendants = Item:GetDescendants()
            TableInsert(Descendants, Item)

            for Index, Value in Descendants do 
                local TransparencyProperty = Tween:GetProperty(Value)
                if not TransparencyProperty then continue end
                if type(TransparencyProperty) == "table" then 
                    for _, Property in TransparencyProperty do 
                        Tween:FadeItem(Value, Property, not Visibility, Speed)
                    end
                else
                    Tween:FadeItem(Value, TransparencyProperty, not Visibility, Speed)
                end
            end
        end

        Instances.AddToTheme = function(self, Properties)
            if self.Instance then Library:AddToTheme(self, Properties) end
        end

        Instances.ChangeItemTheme = function(self, Properties)
            if self.Instance then Library:ChangeItemTheme(self, Properties) end
        end

        Instances.Connect = function(self, Event, Callback, Name)
            if not self.Instance or not self.Instance[Event] then return end
            if IsMobile then
                if Event == "MouseButton1Down" or Event == "MouseButton1Click" then Event = "TouchTap"
                elseif Event == "MouseButton2Down" or Event == "MouseButton2Click" then Event = "TouchLongPress" end
            end
            return Library:Connect(self.Instance[Event], Callback, Name)
        end

        Instances.Tween = function(self, Info, Goal)
            if self.Instance then return Tween:Create(self, Info, Goal) end
        end

        Instances.Clean = function(self)
            if self.Instance then self.Instance:Destroy() self = nil end
        end

        Instances.MakeDraggable = function(self)
            if not self.Instance then return end
            local Gui = self.Instance
            local Dragging, DragStart, StartPosition = false, nil, nil 
        
            local Set = function(Input)
                local DragDelta = Input.Position - DragStart
                self:Tween(TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)
                })
            end
        
            local InputChanged
            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position
        
                    if InputChanged then return end
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            if InputChanged then InputChanged:Disconnect() InputChanged = nil end
                        end
                    end)
                end
            end)
        
            Library:Connect(UserInputService.InputChanged, function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Dragging then
                    Set(Input)
                end
            end)
            return Dragging
        end

        Instances.MakeResizeable = function(self, Minimum, Maximum, Window)
            if not self.Instance then return end
            local Gui = self.Instance
            local Resizing, CurrentSide, StartMouse, StartPosition, StartSize = false, nil, nil, nil, nil
            local EdgeThickness = 3

            local MakeEdge = function(Position, Size, Side)
                local Button = Instances:Create("TextButton", {
                    Size = Size, Position = Position, BackgroundColor3 = Library.Theme.Accent,
                    BackgroundTransparency = 1, Text = "", BorderSizePixel = 0, AutoButtonColor = false,
                    Parent = Gui, ZIndex = 9999
                })
                return {Button = Button, Side = Side}
            end

            local Edges = {
                MakeEdge(UDim2New(0, 0, 0, 0), UDim2New(0, EdgeThickness, 1, 0), "L"),
                MakeEdge(UDim2New(1, -EdgeThickness, 0, 0), UDim2New(0, EdgeThickness, 1, 0), "R"),
                MakeEdge(UDim2New(0, 0, 0, 0), UDim2New(1, 0, 0, EdgeThickness), "T"),
                MakeEdge(UDim2New(0, 0, 1, -EdgeThickness), UDim2New(1, 0, 0, EdgeThickness), "B")
            }

            for _, Edge in pairs(Edges) do
                Edge.Button:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Resizing = true
                        CurrentSide = Edge.Side
                        StartMouse = UserInputService:GetMouseLocation()
                        StartPosition = Vector2New(Gui.Position.X.Offset, Gui.Position.Y.Offset)
                        StartSize = Vector2New(Gui.Size.X.Offset, Gui.Size.Y.Offset)
                    end
                end)
            end

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and Resizing then
                    Resizing = false
                    CurrentSide = nil
                end
            end)

            Library:Connect(RunService.RenderStepped, function()
                if not Resizing or not CurrentSide then return end
                local MouseLocation = UserInputService:GetMouseLocation()
                local dx = MouseLocation.X - StartMouse.X
                local dy = MouseLocation.Y - StartMouse.Y
                local x, y, w, h = StartPosition.X, StartPosition.Y, StartSize.X, StartSize.Y

                if CurrentSide == "L" then x = StartPosition.X + dx w = StartSize.X - dx
                elseif CurrentSide == "R" then w = StartSize.X + dx
                elseif CurrentSide == "T" then y = StartPosition.Y + dy h = StartSize.Y - dy
                elseif CurrentSide == "B" then h = StartSize.Y + dy end

                if w < Minimum.X then if CurrentSide == "L" then x = x - (Minimum.X - w) end w = Minimum.X end
                if h < Minimum.Y then if CurrentSide == "T" then y = y - (Minimum.Y - h) end h = Minimum.Y end

                self:Tween(TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2FromOffset(x, y), Size = UDim2FromOffset(w, h)})
            end)
        end

        Instances.OnHover = function(self, Function) return Library:Connect(self.Instance.MouseEnter, Function) end
        Instances.OnHoverLeave = function(self, Function) return Library:Connect(self.Instance.MouseLeave, Function) end
    end

    -- ==========================================
    -- DESIGN FONTS DEFINITIONS
    -- ==========================================
    local CustomFont = { } do
        Library.Fonts = {
            ["SemiBold"] = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            ["Regular"]  = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ["Light"]    = Font.new("rbxassetid://12187365364", Enum.FontWeight.Light, Enum.FontStyle.Normal)
        }
        Library.Font = Library.Fonts.SemiBold
    end

    -- Root Interface Initialization
    Library.Holder = Instances:Create("ScreenGui", { Parent = gethui(), ZIndexBehavior = Enum.ZIndexBehavior.Global, DisplayOrder = 2, ResetOnSpawn = false })
    Library.UnusedHolder = Instances:Create("ScreenGui", { Parent = gethui(), Enabled = false, ResetOnSpawn = false })
    Library.NotifHolder = Instances:Create("Frame", { Parent = Library.Holder.Instance, BackgroundTransparency = 1, Size = UDim2New(0, 300, 1, 0), Position = UDim2New(1, -312, 0, 12) })
    
    Instances:Create("UIListLayout", { Parent = Library.NotifHolder.Instance, Padding = UDimNew(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

    -- ==========================================
    -- SYSTEM CORE UTILITIES
    -- ==========================================
    Library.Unload = function(self)
        for _, Value in pairs(self.Connections) do Value.Connection:Disconnect() end
        for _, Value in pairs(self.Threads) do coroutine.close(Value) end
        if self.Holder then self.Holder:Clean() end
        if self.UnusedHolder then self.UnusedHolder:Clean() end
        for _, Object in pairs(self.ToClean) do pcall(function() Object:Destroy() end) end
        Library = nil
        getgenv().Library = nil
    end

    Library.Round = function(self, Number, Float)
        local Multiplier = 1 / (Float or 1)
        return MathFloor(Number * Multiplier) / Multiplier
    end

    Library.Thread = function(self, Function)
        local NewThread = coroutine.create(Function)
        coroutine.wrap(function() coroutine.resume(NewThread) end)()
        TableInsert(self.Threads, NewThread)
        return NewThread
    end
    
    Library.SafeCall = function(self, Function, ...)
        local Success, Result = pcall(Function, ...)
        if not Success then warn(Result) end
        return Success
    end

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("conn_%s", HttpService:GenerateGUID(false))
        local NewConnection = { Event = Event, Callback = Callback, Name = Name, Connection = Event:Connect(Callback) }
        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.Disconnect = function(self, Name)
        for i, Connection in ipairs(self.Connections) do 
            if Connection.Name == Name then Connection.Connection:Disconnect() TableRemove(self.Connections, i) break end
        end
    end

    Library.NextFlag = function(self)
        self.UnnamedFlags = self.UnnamedFlags + 1
        return StringFormat("flag_auto_%s", self.UnnamedFlags)
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item 
        local ThemeData = { Item = Item, Properties = Properties }
        for Property, Value in pairs(ThemeData.Properties) do
            if type(Value) == "string" then Item[Property] = self.Theme[Value] end
        end
        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    Library.ChangeTheme = function(self, Theme, Color)
        self.Theme[Theme] = Color
        for _, Item in pairs(self.ThemeItems) do
            for Property, Value in pairs(Item.Properties) do
                if type(Value) == "string" and Value == Theme then Item.Item[Property] = Color end
            end
        end
    end

    Library.IsOriginalMouseOverFrame = function(self, Frame)
        Frame = Frame.Instance or Frame
        local MousePosition = Vector2New(Mouse.X, Mouse.Y)
        return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X 
        and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end
    Library.IsMouseOverFrame = Library.IsOriginalMouseOverFrame

    -- Glass Screen Viewport Blurring Math
    Library.MakeBlurred = function(self, Item, Window)
        Item = Item.Instance or Item
        local Part = Instances:Create("Part", { Material = Enum.Material.Glass, Transparency = 0.97, Reflectance = 1, CastShadow = false, Anchored = true, CanCollide = false, Size = Vector3New(1, 1, 1) * 0.01, Color = FromRGB(0,0,0), Parent = Camera })
        TableInsert(self.ToClean, Part.Instance)
        local BlockMesh = Instances:Create("BlockMesh", { Parent = Part.Instance })

        local DepthOfField = Instances:Create("DepthOfFieldEffect", { Parent = Lighting, Enabled = true, FarIntensity = 0, FocusDistance = 0, InFocusRadius = 1000, NearIntensity = 1 })
        TableInsert(self.ToClean, DepthOfField.Instance)

        Library:Connect(RunService.RenderStepped, function()
            if Window.IsOpen and Item.Visible then
                DepthOfField.NearIntensity = 1
                local Corner0 = Item.AbsolutePosition
                local Corner1 = Corner0 + Item.AbsoluteSize
                local Ray0 = Camera:ScreenPointToRay(Corner0.X, Corner0.Y, 1)
                local Ray1 = Camera:ScreenPointToRay(Corner1.X, Corner1.Y, 1)
                local Origin = Camera.CFrame.Position + Camera.CFrame.LookVector * (0.05 - Camera.NearPlaneZ)
                
                local GetPos = function(Ray)
                    local A = -((Camera.CFrame.LookVector:Dot(Ray.Origin - Origin)) / Camera.CFrame.LookVector:Dot(Ray.Direction))
                    return Ray.Origin + (A * Ray.Direction)
                end

                local p0 = Camera.CFrame:PointToObjectSpace(GetPos(Ray0))
                local p1 = Camera.CFrame:PointToObjectSpace(GetPos(Ray1))
                BlockMesh.Instance.Offset = (p0 + p1) / 2
                BlockMesh.Instance.Scale = (p1 - p0) / 0.0101
                Part.Instance.CFrame = Camera.CFrame
            else
                DepthOfField.NearIntensity = 0
                BlockMesh.Instance.Scale = Vector3New(0,0,0)
            end
        end)
    end

    -- ==========================================
    -- MAIN WINDOW CONSTRUCTOR
    -- ==========================================
    function Library:CreateWindow(Data)
        Data = Data or {}
        local Window = { IsOpen = true, Pages = {}, Sections = {}, CurrentPage = nil }

        local MainFrame = Instances:Create("Frame", {
            Parent = Library.Holder.Instance, Size = UDim2FromOffset(550, 400),
            Position = UDim2New(0.5, -275, 0.5, -200), BackgroundColor3 = Library.Theme["Background"],
            BorderSizePixel = 0
        })
        MainFrame:AddToTheme({ BackgroundColor3 = "Background" })
        MainFrame:MakeDraggable()
        MainFrame:MakeResizeable(Vector2New(400, 300), Vector2New(1000, 800), nil)
        Instances:Create("UICorner", { Parent = MainFrame.Instance, CornerRadius = UDimNew(0, 6) })
        Library:MakeBlurred(MainFrame, Window)

        -- Topbar Title Layout
        local Topbar = Instances:Create("Frame", { Parent = MainFrame.Instance, Size = UDim2New(1, 0, 0, 35), BackgroundTransparency = 1 })
        local TitleLabel = Instances:Create("TextLabel", {
            Parent = Topbar.Instance, Text = Data.Name or "Rise UI", FontFace = Library.Font,
            TextSize = 16, TextColor3 = Library.Theme["Text"], Position = UDim2New(0, 15, 0, 0),
            Size = UDim2New(1, -30, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
        })
        TitleLabel:AddToTheme({ TextColor3 = "Text" })

        -- Tab Navigation Sidebar
        local Sidebar = Instances:Create("Frame", {
            Parent = MainFrame.Instance, Size = UDim2New(0, 130, 1, -35),
            Position = UDim2New(0, 0, 0, 35), BackgroundColor3 = Library.Theme["Background 2"], BorderSizePixel = 0
        })
        Sidebar:AddToTheme({ BackgroundColor3 = "Background 2" })
        
        local TabContainer = Instances:Create("ScrollingFrame", {
            Parent = Sidebar.Instance, Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 1,
            CanvasSize = UDim2New(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0
        })
        Instances:Create("UIListLayout", { Parent = TabContainer.Instance, Padding = UDimNew(0, 4) })
        Instances:Create("UIPadding", { Parent = TabContainer.Instance, PaddingTop = UDimNew(0, 6), PaddingLeft = UDimNew(0, 6), PaddingRight = UDimNew(0, 6) })

        -- Sub-page Display Viewport
        local PageDisplay = Instances:Create("Frame", {
            Parent = MainFrame.Instance, Size = UDim2New(1, -130, 1, -35),
            Position = UDim2New(0, 130, 0, 35), BackgroundTransparency = 1
        })

        -- Binding Window key visibility cycle
        Library:Connect(UserInputService.InputBegan, function(Input)
            if Input.KeyCode == Enum.KeyCode[Library.MenuKeybind] then
                Window.IsOpen = not Window.IsOpen
                MainFrame.Instance.Visible = Window.IsOpen
            end
        end)

        -- ==========================================
        -- TAB PAGE CONSTRUCTOR
        -- ==========================================
        function Window:Page(PageData)
            PageData = PageData or {}
            local Page = { Window = Window, Sections = {}, Elements = {} }

            local TabButton = Instances:Create("TextButton", {
                Parent = TabContainer.Instance, Size = UDim2New(1, 0, 0, 30),
                BackgroundColor3 = Library.Theme["Element"], BackgroundTransparency = 1,
                Text = PageData.Name or "Tab", FontFace = Library.Font, TextSize = 14,
                TextColor3 = Library.Theme["Text"], AutoButtonColor = false, BorderSizePixel = 0
            })
            TabButton:AddToTheme({ TextColor3 = "Text" })
            Instances:Create("UICorner", { Parent = TabButton.Instance, CornerRadius = UDimNew(0, 4) })

            local PageContent = Instances:Create("ScrollingFrame", {
                Parent = PageDisplay.Instance, Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 1,
                CanvasSize = UDim2New(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Visible = false, ScrollBarThickness = 2
            })
            PageContent:AddToTheme({ ScrollBarImageColor3 = "Accent" })
            
            local ColumnLayout = Instances:Create("UIListLayout", { Parent = PageContent.Instance, Padding = UDimNew(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })
            Instances:Create("UIPadding", { Parent = PageContent.Instance, PaddingTop = UDimNew(0, 10), PaddingLeft = UDimNew(0, 10), PaddingRight = UDimNew(0, 10), PaddingBottom = UDimNew(0, 10) })

            local function SelectPage()
                if Window.CurrentPage then
                    Window.CurrentPage.Button.BackgroundTransparency = 1
                    Window.CurrentPage.Content.Visible = false
                end
                TabButton.BackgroundTransparency = 0.5
                PageContent.Instance.Visible = true
                Window.CurrentPage = { Button = TabButton.Instance, Content = PageContent.Instance }
            end

            TabButton:Connect("MouseButton1Down", SelectPage)
            if not Window.CurrentPage then SelectPage() end

            -- ==========================================
            -- CONTAINER SECTION CONSTRUCTOR
            -- ==========================================
            function Page:Section(SectionData)
                SectionData = SectionData or {}
                local Section = { Page = Page, Window = Window, Elements = {} }

                local SectionFrame = Instances:Create("Frame", {
                    Parent = PageContent.Instance, Size = UDim2New(1, 0, 0, 40),
                    BackgroundColor3 = Library.Theme["Section Background"], AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0
                })
                SectionFrame:AddToTheme({ BackgroundColor3 = "Section Background" })
                Instances:Create("UICorner", { Parent = SectionFrame.Instance, CornerRadius = UDimNew(0, 5) })

                local ContentContainer = Instances:Create("Frame", {
                    Parent = SectionFrame.Instance, Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 1
                })
                Instances:Create("UIListLayout", { Parent = ContentContainer.Instance, Padding = UDimNew(0, 6) })
                Instances:Create("UIPadding", { Parent = ContentContainer.Instance, PaddingTop = UDimNew(0, 8), PaddingLeft = UDimNew(0, 8), PaddingRight = UDimNew(0, 8), PaddingBottom = UDimNew(0, 8) })

                -- ==========================================
                -- 1. TOGGLE CONTROL INTERACTION
                -- ==========================================
                function Section:Toggle(ToggleData)
                    ToggleData = ToggleData or {}
                    local Toggle = { State = ToggleData.Default or false, Flag = ToggleData.Flag or Library:NextFlag() }

                    local Container = Instances:Create("Frame", { Parent = ContentContainer.Instance, Size = UDim2New(1, 0, 0, 26), BackgroundTransparency = 1 })
                    local Label = Instances:Create("TextLabel", {
                        Parent = Container.Instance, Size = UDim2New(1, -45, 1, 0), Position = UDim2New(0, 0, 0, 0),
                        Text = ToggleData.Name or "Toggle", FontFace = Library.Font, TextSize = 14,
                        TextColor3 = Library.Theme["Text"], TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
                    })
                    Label:AddToTheme({ TextColor3 = "Text" })

                    local Switch = Instances:Create("TextButton", {
                        Parent = Container.Instance, Size = UDim2FromOffset(36, 18), Position = UDim2New(1, -36, 0.5, -9),
                        BackgroundColor3 = Library.Theme["Element"], Text = "", AutoButtonColor = false, BorderSizePixel = 0
                    })
                    Switch:AddToTheme({ BackgroundColor3 = "Element" })
                    Instances:Create("UICorner", { Parent = Switch.Instance, CornerRadius = UDimNew(1, 0) })

                    local Node = Instances:Create("Frame", {
                        Parent = Switch.Instance, Size = UDim2FromOffset(12, 12), Position = UDim2New(0, 3, 0.5, -6),
                        BackgroundColor3 = Library.Theme["Text"], BorderSizePixel = 0
                    })
                    Node:AddToTheme({ BackgroundColor3 = "Text" })
                    Instances:Create("UICorner", { Parent = Node.Instance, CornerRadius = UDimNew(1, 0) })

                    local function Update()
                        Library.Flags[Toggle.Flag] = Toggle.State
                        local TargetX = Toggle.State and UDim2New(1, -15, 0.5, -6) or UDim2New(0, 3, 0.5, -6)
                        local TargetColor = Toggle.State and Library.Theme["Accent"] or Library.Theme["Element"]
                        
                        Node:Tween(nil, { Position = TargetX })
                        Switch:Tween(nil, { BackgroundColor3 = TargetColor })
                        
                        if ToggleData.Callback then Library:SafeCall(ToggleData.Callback, Toggle.State) end
                    end

                    Switch:Connect("MouseButton1Down", function()
                        Toggle.State = not Toggle.State
                        Update()
                    end)

                    Library.SetFlags[Toggle.Flag] = function(Val) Toggle.State = Val Update() end
                    if Toggle.State then Update() end
                    return Toggle
                end

                -- ==========================================
                -- 2. SLIDER SELECTION SYSTEM
                -- ==========================================
                function Section:Slider(SliderData)
                    SliderData = SliderData or {}
                    local Slider = {
                        Min = SliderData.Min or 0, Max = SliderData.Max or 100,
                        Value = SliderData.Default or SliderData.Min or 0,
                        Decimals = SliderData.Decimals or 1, Flag = SliderData.Flag or Library:NextFlag(), Sliding = false
                    }

                    local Container = Instances:Create("Frame", { Parent = ContentContainer.Instance, Size = UDim2New(1, 0, 0, 34), BackgroundTransparency = 1 })
                    local Label = Instances:Create("TextLabel", {
                        Parent = Container.Instance, Size = UDim2New(1, -100, 0, 16), Text = SliderData.Name or "Slider",
                        FontFace = Library.Font, TextSize = 14, TextColor3 = Library.Theme["Text"], TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
                    })
                    Label:AddToTheme({ TextColor3 = "Text" })

                    local Track = Instances:Create("TextButton", {
                        Parent = Container.Instance, Size = UDim2New(1, 0, 0, 6), Position = UDim2New(0, 0, 1, -8),
                        BackgroundColor3 = Library.Theme["Element"], Text = "", AutoButtonColor = false, BorderSizePixel = 0
                    })
                    Track:AddToTheme({ BackgroundColor3 = "Element" })
                    Instances:Create("UICorner", { Parent = Track.Instance })

                    local Fill = Instances:Create("Frame", {
                        Parent = Track.Instance, Size = UDim2New(0, 0, 1, 0), BackgroundColor3 = Library.Theme["Accent"], BorderSizePixel = 0
                    })
                    Fill:AddToTheme({ BackgroundColor3 = "Accent" })
                    Instances:Create("UICorner", { Parent = Fill.Instance })

                    local Display = Instances:Create("TextLabel", {
                        Parent = Container.Instance, Size = UDim2New(0, 80, 0, 16), Position = UDim2New(1, -80, 0, 0),
                        Text = tostring(Slider.Value), FontFace = Library.Font, TextSize = 13, TextColor3 = Library.Theme["Text"],
                        TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1
                    })
                    Display:AddToTheme({ TextColor3 = "Text" })

                    local function SetValue(Val)
                        Slider.Value = Library:Round(MathClamp(Val, Slider.Min, Slider.Max), Slider.Decimals)
                        Library.Flags[Slider.Flag] = Slider.Value
                        Display.Instance.Text = tostring(Slider.Value) .. (SliderData.Suffix or "")
                        
                        local Pct = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
                        Fill:Tween(TweenInfo.new(0.05), { Size = UDim2New(Pct, 0, 1, 0) })
                        
                        if SliderData.Callback then Library:SafeCall(SliderData.Callback, Slider.Value) end
                    end

                    local function TrackInput(Input)
                        local SizeX = MathClamp((Input.Position.X - Track.Instance.AbsolutePosition.X) / Track.Instance.AbsoluteSize.X, 0, 1)
                        local TargetVal = Slider.Min + ((Slider.Max - Slider.Min) * SizeX)
                        SetValue(TargetVal)
                    end

                    Track:Connect("InputBegan", function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            Slider.Sliding = true
                            TrackInput(Input)
                        end
                    end)

                    Library:Connect(UserInputService.InputChanged, function(Input)
                        if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Slider.Sliding then
                            TrackInput(Input)
                        end
                    end)

                    Library:Connect(UserInputService.InputEnded, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            Slider.Sliding = false
                        end
                    end)

                    Library.SetFlags[Slider.Flag] = SetValue
                    SetValue(Slider.Value)
                    return Slider
                end

                -- ==========================================
                -- 3. INTERACTIVE DROPDOWN PICKER
                -- ==========================================
                function Section:Dropdown(DropdownData)
                    DropdownData = DropdownData or {}
                    local Dropdown = {
                        List = DropdownData.Items or {}, Value = DropdownData.Multi and {} or nil,
                        Flag = DropdownData.Flag or Library:NextFlag(), IsOpen = false, Multi = DropdownData.Multi or false
                    }

                    local Container = Instances:Create("Frame", { Parent = ContentContainer.Instance, Size = UDim2New(1, 0, 0, 44), BackgroundTransparency = 1 })
                    local Label = Instances:Create("TextLabel", {
                        Parent = Container.Instance, Size = UDim2New(1, 0, 0, 16), Text = DropdownData.Name or "Dropdown",
                        FontFace = Library.Font, TextSize = 14, TextColor3 = Library.Theme["Text"], TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
                    })
                    Label:AddToTheme({ TextColor3 = "Text" })

                    local Selector = Instances:Create("TextButton", {
                        Parent = Container.Instance, Size = UDim2New(1, 0, 0, 24), Position = UDim2New(0, 0, 1, -24),
                        BackgroundColor3 = Library.Theme["Element"], Text = "  Select...", FontFace = Library.Font,
                        TextSize = 13, TextColor3 = Library.Theme["Text"], TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, BorderSizePixel = 0
                    })
                    Selector:AddToTheme({ BackgroundColor3 = "Element", TextColor3 = "Text" })
                    Instances:Create("UICorner", { Parent = Selector.Instance, CornerRadius = UDimNew(0, 4) })

                    local Menu = Instances:Create("Frame", {
                        Parent = Library.Holder.Instance, Size = UDim2New(0, 200, 0, 0), BackgroundColor3 = Library.Theme["Background 2"],
                        BorderSizePixel = 0, Visible = false, ZIndex = 100
                    })
                    Menu:AddToTheme({ BackgroundColor3 = "Background 2" })
                    Instances:Create("UICorner", { Parent = Menu.Instance, CornerRadius = UDimNew(0, 4) })
                    
                    local Scroll = Instances:Create("ScrollingFrame", {
                        Parent = Menu.Instance, Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 1, CanvasSize = UDim2New(0,0,0,0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ZIndex = 101
                    })
                    Instances:Create("UIListLayout", { Parent = Scroll.Instance })

                    local function ToggleMenu()
                        Dropdown.IsOpen = not Dropdown.IsOpen
                        if Dropdown.IsOpen then
                            Menu.Instance.Position = UDim2FromOffset(Selector.Instance.AbsolutePosition.X, Selector.Instance.AbsolutePosition.Y + Selector.Instance.AbsoluteSize.Y + 4)
                            Menu.Instance.Size = UDim2FromOffset(Selector.Instance.AbsoluteSize.X, math.min(#Dropdown.List * 24, 120))
                            Menu.Instance.Visible = true
                        else
                            Menu.Instance.Visible = false
                        end
                    end

                    Selector:Connect("MouseButton1Down", ToggleMenu)

                    local function UpdateDisplay()
                        if Dropdown.Multi then
                            local SelectedText = {}
                            for k, v in pairs(Dropdown.Value) do if v then TableInsert(SelectedText, k) end end
                            Selector.Instance.Text = "  " .. (#SelectedText > 0 and TableConcat(SelectedText, ", ") or "Select...")
                        else
                            Selector.Instance.Text = "  " .. tostring(Dropdown.Value or "Select...")
                        end
                    end

                    function Dropdown:Refresh(NewList)
                        Dropdown.List = NewList or {}
                        for _, Object in ipairs(Scroll.Instance:GetChildren()) do if Object:IsA("TextButton") then Object:Destroy() end end
                        
                        for _, ItemName in ipairs(Dropdown.List) do
                            local Option = Instances:Create("TextButton", {
                                Parent = Scroll.Instance, Size = UDim2New(1, 0, 0, 24), BackgroundTransparency = 1,
                                Text = "  " .. tostring(ItemName), FontFace = Library.Font, TextSize = 13,
                                TextColor3 = Library.Theme["Text"], TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 102
                            })
                            Option:AddToTheme({ TextColor3 = "Text" })

                            Option:Connect("MouseButton1Down", function()
                                if Dropdown.Multi then
                                    Dropdown.Value[ItemName] = not Dropdown.Value[ItemName]
                                    Option.Instance.TextColor3 = Dropdown.Value[ItemName] and Library.Theme["Accent"] or Library.Theme["Text"]
                                else
                                    Dropdown.Value = ItemName
                                    ToggleMenu()
                                end
                                Library.Flags[Dropdown.Flag] = Dropdown.Value
                                UpdateDisplay()
                                if DropdownData.Callback then Library:SafeCall(DropdownData.Callback, Dropdown.Value) end
                            end)
                        end
                    end

                    Dropdown:Refresh(Dropdown.List)
                    Library.SetFlags[Dropdown.Flag] = function(Val) Dropdown.Value = Val UpdateDisplay() end
                    return Dropdown
                end

                -- ==========================================
                -- 4. HARDWARE INPUT KEYBIND TRACKER
                -- ==========================================
                function Section:Keybind(KeybindData)
                    KeybindData = KeybindData or {}
                    local Keybind = {
                        Value = KeybindData.Default or Enum.KeyCode.Unknown,
                        Flag = KeybindData.Flag or Library:NextFlag(), Binding = false
                    }

                    local Container = Instances:Create("Frame", { Parent = ContentContainer.Instance, Size = UDim2New(1, 0, 0, 26), BackgroundTransparency = 1 })
                    local Label = Instances:Create("TextLabel", {
                        Parent = Container.Instance, Size = UDim2New(1, -90, 1, 0), Text = KeybindData.Name or "Keybind",
                        FontFace = Library.Font, TextSize = 14, TextColor3 = Library.Theme["Text"], TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
                    })
                    Label:AddToTheme({ TextColor3 = "Text" })

                    local Trigger = Instances:Create("TextButton", {
                        Parent = Container.Instance, Size = UDim2FromOffset(80, 20), Position = UDim2New(1, -80, 0.5, -10),
                        BackgroundColor3 = Library.Theme["Element"], Text = Keybind.Value.Name, FontFace = Library.Font,
                        TextSize = 12, TextColor3 = Library.Theme["Text"], AutoButtonColor = false, BorderSizePixel = 0
                    })
                    Trigger:AddToTheme({ BackgroundColor3 = "Element", TextColor3 = "Text" })
                    Instances:Create("UICorner", { Parent = Trigger.Instance, CornerRadius = UDimNew(0, 4) })

                    Trigger:Connect("MouseButton1Down", function()
                        Keybind.Binding = true
                        Trigger.Instance.Text = "..."
                    end)

                    Library:Connect(UserInputService.InputBegan, function(Input)
                        if Keybind.Binding then
                            if Input.UserInputType == Enum.UserInputType.Keyboard then
                                Keybind.Value = Input.KeyCode
                                Keybind.Binding = false
                                Trigger.Instance.Text = Keybind.Value.Name
                                Library.Flags[Keybind.Flag] = Keybind.Value
                            end
                        else
                            if Input.KeyCode == Keybind.Value and KeybindData.Callback then
                                Library:SafeCall(KeybindData.Callback, Keybind.Value)
                            end
                        end
                    end)

                    Library.SetFlags[Keybind.Flag] = function(Key) Keybind.Value = Key Trigger.Instance.Text = Key.Name end
                    return Keybind
                end

                -- ==========================================
                -- 5. SANITIZED INTERFACE TEXTBOX FIELD
                -- ==========================================
                function Section:Textbox(TextboxData)
                    TextboxData = TextboxData or {}
                    local Textbox = { Value = TextboxData.Default or "", Flag = TextboxData.Flag or Library:NextFlag() }

                    local Container = Instances:Create("Frame", { Parent = ContentContainer.Instance, Size = UDim2New(1, 0, 0, 44), BackgroundTransparency = 1 })
                    local Label = Instances:Create("TextLabel", {
                        Parent = Container.Instance, Size = UDim2New(1, 0, 0, 16), Text = TextboxData.Name or "Textbox",
                        FontFace = Library.Font, TextSize = 14, TextColor3 = Library.Theme["Text"], TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
                    })
                    Label:AddToTheme({ TextColor3 = "Text" })

                    local Field = Instances:Create("TextBox", {
                        Parent = Container.Instance, Size = UDim2New(1, 0, 0, 24), Position = UDim2New(0, 0, 1, -24),
                        BackgroundColor3 = Library.Theme["Element"], Text = Textbox.Value, PlaceholderText = TextboxData.Placeholder or "Enter text...",
                        FontFace = Library.Font, TextSize = 13, TextColor3 = Library.Theme["Text"], ClearTextOnFocus = false, BorderSizePixel = 0
                    })
                    Field:AddToTheme({ BackgroundColor3 = "Element", TextColor3 = "Text" })
                    Instances:Create("UICorner", { Parent = Field.Instance, CornerRadius = UDimNew(0, 4) })

                    Field.Instance.FocusLost:Connect(function()
                        Textbox.Value = Field.Instance.Text
                        Library.Flags[Textbox.Flag] = Textbox.Value
                        if TextboxData.Callback then Library:SafeCall(TextboxData.Callback, Textbox.Value) end
                    end)

                    Library.SetFlags[Textbox.Flag] = function(Text) Textbox.Value = Text Field.Instance.Text = Text end
                    return Textbox
                end

                -- ==========================================
                -- 6. FULL MATRIX COLORPICKER SUB-MENU
                -- ==========================================
                function Section:Colorpicker(ColorData)
                    ColorData = ColorData or {}
                    local Colorpicker = {
                        Value = ColorData.Default or FromRGB(255, 255, 255),
                        Flag = ColorData.Flag or Library:NextFlag(), IsOpen = false
                    }

                    local Container = Instances:Create("Frame", { Parent = ContentContainer.Instance, Size = UDim2New(1, 0, 0, 26), BackgroundTransparency = 1 })
                    local Label = Instances:Create("TextLabel", {
                        Parent = Container.Instance, Size = UDim2New(1, -45, 1, 0), Text = ColorData.Name or "Colorpicker",
                        FontFace = Library.Font, TextSize = 14, TextColor3 = Library.Theme["Text"], TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
                    })
                    Label:AddToTheme({ TextColor3 = "Text" })

                    local Node = Instances:Create("TextButton", {
                        Parent = Container.Instance, Size = UDim2FromOffset(24, 14), Position = UDim2New(1, -24, 0.5, -7),
                        BackgroundColor3 = Colorpicker.Value, Text = "", AutoButtonColor = false, BorderSizePixel = 0
                    })
                    Instances:Create("UICorner", { Parent = Node.Instance, CornerRadius = UDimNew(0, 3) })

                    local Menu = Instances:Create("Frame", {
                        Parent = Library.Holder.Instance, Size = UDim2FromOffset(140, 140), BackgroundColor3 = Library.Theme["Background 2"],
                        BorderSizePixel = 0, Visible = false, ZIndex = 200
                    })
                    Menu:AddToTheme({ BackgroundColor3 = "Background 2" })
                    Instances:Create("UICorner", { Parent = Menu.Instance, CornerRadius = UDimNew(0, 4) })

                    local Canvas = Instances:Create("ImageButton", {
                        Parent = Menu.Instance, Size = UDim2FromOffset(120, 120), Position = UDim2FromOffset(10, 10),
                        Image = "rbxassetid://415583266", BorderSizePixel = 0, ZIndex = 201
                    })

                    local function UpdateColor(Color)
                        Colorpicker.Value = Color
                        Node.Instance.BackgroundColor3 = Color
                        Library.Flags[Colorpicker.Flag] = Color
                        if ColorData.Callback then Library:SafeCall(ColorData.Callback, Color) end
                    end

                    Node:Connect("MouseButton1Down", function()
                        Colorpicker.IsOpen = not Colorpicker.IsOpen
                        if Colorpicker.IsOpen then
                            Menu.Instance.Position = UDim2FromOffset(Node.Instance.AbsolutePosition.X - 150, Node.Instance.AbsolutePosition.Y)
                            Menu.Instance.Visible = true
                        else
                            Menu.Instance.Visible = false
                        end
                    end)

                    Canvas:Connect("InputBegan", function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            local X = MathClamp((Input.Position.X - Canvas.Instance.AbsolutePosition.X) / Canvas.Instance.AbsoluteSize.X, 0, 1)
                            local Y = MathClamp((Input.Position.Y - Canvas.Instance.AbsolutePosition.Y) / Canvas.Instance.AbsoluteSize.Y, 0, 1)
                            UpdateColor(FromHSV(X, 1 - Y, 1))
                        end
                    end)

                    Library.SetFlags[Colorpicker.Flag] = UpdateColor
                    return Colorpicker
                end

                return Section
            end

            return Page
        end

        return Window
    end
end

getgenv().Library = Library
return Library
