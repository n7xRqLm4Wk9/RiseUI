--[[
  File: ColorPicker.lua
  Layer: Components/Widgets
  Responsibility: Color picker widget with SV
  canvas, hue bar, and hex input.
  Visual code by Gemini, integrated into
  LuxwareUI architecture by Claude.
  Fixes: hue direction, scoped connections,
  hex input box added, theme integration,
  destroy cleanup.
  Dependencies: core/EventBus, animation/Animator,
  animation/Transitions, theme/ThemeManager,
  utils/Color
  Public API: ColorPicker.new(parent, config) → handle
  handle.Set(Color3), handle.Get() → Color3,
  handle.Destroy()
]]

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Animator         = require(script.Parent.Parent.Parent.animation.Animator)
local Transitions      = require(script.Parent.Parent.Parent.animation.Transitions)
local EventBus         = require(script.Parent.Parent.Parent.core.EventBus)
local ThemeManager     = require(script.Parent.Parent.Parent.theme.ThemeManager)
local ColorUtil        = require(script.Parent.Parent.Parent.utils.Color)

local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(parent, config)
    config = config or {}
    local self      = setmetatable({}, ColorPicker)
    local T         = ThemeManager.GetAll()

    local startColor = config.Color or Color3.fromRGB(255, 100, 100)
    local H, S, V   = ColorUtil.RGBtoHSV(startColor)

    self._color       = startColor
    self._H, self._S, self._V = H, S, V
    self._flag        = config.Flag
    self._callback    = config.Callback
    self._connections = {}
    self._isOpen      = false

    -- --------------------------------------------------------
    -- ROOT WRAPPER
    -- --------------------------------------------------------
    local Wrapper = Instance.new("Frame")
    Wrapper.Name             = "ColorPicker_" .. (config.Name or "Color")
    Wrapper.Size             = UDim2.new(1, 0, 0, T.RowHeight)
    Wrapper.BackgroundTransparency = 1
    Wrapper.ClipsDescendants = true
    Wrapper.Parent           = parent

    -- --------------------------------------------------------
    -- HEADER ROW
    -- --------------------------------------------------------
    local Header = Instance.new("Frame")
    Header.Size             = UDim2.new(1, 0, 0, T.RowHeight)
    Header.BackgroundColor3 = T.SurfaceLight
    Header.Parent           = Wrapper

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, T.RadiusComponent)
    HeaderCorner.Parent = Header

    local HeaderStroke = Instance.new("UIStroke")
    HeaderStroke.Color        = T.Border
    HeaderStroke.Thickness    = 1
    HeaderStroke.Transparency = T.StrokeTransparency
    HeaderStroke.Parent = Header

    local HeaderPad = Instance.new("UIPadding")
    HeaderPad.PaddingLeft  = UDim.new(0, T.ComponentPadH)
    HeaderPad.PaddingRight = UDim.new(0, T.ComponentPadH)
    HeaderPad.Parent = Header

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size               = UDim2.new(1, -46, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font               = Enum.Font.GothamMedium
    NameLabel.Text               = config.Name or "Color Picker"
    NameLabel.TextColor3         = T.TextPrimary
    NameLabel.TextSize           = T.SizeLG
    NameLabel.TextXAlignment     = Enum.TextXAlignment.Left
    NameLabel.Parent             = Header

    local Swatch = Instance.new("Frame")
    Swatch.Size             = UDim2.fromOffset(28, 28)
    Swatch.Position         = UDim2.new(1, -28, 0.5, -14)
    Swatch.BackgroundColor3 = self._color
    Swatch.Parent           = Header

    local SwatchCorner = Instance.new("UICorner")
    SwatchCorner.CornerRadius = UDim.new(0, 6)
    SwatchCorner.Parent = Swatch

    local SwatchStroke = Instance.new("UIStroke")
    SwatchStroke.Color     = T.Border
    SwatchStroke.Thickness = 2
    SwatchStroke.Parent    = Swatch

    -- --------------------------------------------------------
    -- PICKER PANEL
    -- --------------------------------------------------------
    local Panel = Instance.new("Frame")
    Panel.Size             = UDim2.new(1, 0, 0, 230)
    Panel.Position         = UDim2.new(0, 0, 0, T.RowHeight + 4)
    Panel.BackgroundColor3 = T.SurfaceOverlay or T.Surface
    Panel.Parent           = Wrapper

    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, T.RadiusComponent)
    PanelCorner.Parent = Panel

    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color        = T.Border
    PanelStroke.Thickness    = 1
    PanelStroke.Transparency = T.StrokeTransparency
    PanelStroke.Parent = Panel

    local PanelPad = Instance.new("UIPadding")
    PanelPad.PaddingTop    = UDim.new(0, 10)
    PanelPad.PaddingBottom = UDim.new(0, 10)
    PanelPad.PaddingLeft   = UDim.new(0, 10)
    PanelPad.PaddingRight  = UDim.new(0, 10)
    PanelPad.Parent = Panel

    -- SV Canvas
    local SVCanvas = Instance.new("ImageButton")
    SVCanvas.Size             = UDim2.new(1, 0, 0, 130)
    SVCanvas.BackgroundColor3 = ColorUtil.HSVtoRGB(H, 1, 1)
    SVCanvas.Image            = "rbxassetid://4155801252"
    SVCanvas.AutoButtonColor  = false
    SVCanvas.Parent           = Panel

    local SVCorner = Instance.new("UICorner")
    SVCorner.CornerRadius = UDim.new(0, 6)
    SVCorner.Parent = SVCanvas

    local SVCursor = Instance.new("Frame")
    SVCursor.Size             = UDim2.fromOffset(14, 14)
    SVCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
    SVCursor.Position         = UDim2.new(S, 0, 1 - V, 0)
    SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SVCursor.ZIndex           = 3
    SVCursor.Parent           = SVCanvas

    local SVCursorCorner = Instance.new("UICorner")
    SVCursorCorner.CornerRadius = UDim.new(1, 0)
    SVCursorCorner.Parent = SVCursor

    local SVCursorStroke = Instance.new("UIStroke")
    SVCursorStroke.Color     = Color3.fromRGB(0, 0, 0)
    SVCursorStroke.Thickness = 1.5
    SVCursorStroke.Parent    = SVCursor

    -- Hue Bar
    local HueBar = Instance.new("Frame")
    HueBar.Size             = UDim2.new(1, 0, 0, 16)
    HueBar.Position         = UDim2.new(0, 0, 0, 140)
    HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HueBar.Parent           = Panel

    local HueCorner = Instance.new("UICorner")
    HueCorner.CornerRadius = UDim.new(0, 4)
    HueCorner.Parent = HueBar

    local HueGradient = Instance.new("UIGradient")
    HueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,     Color3.fromRGB(255,   0,   0)),
        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255,   0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(  0, 255,   0)),
        ColorSequenceKeypoint.new(0.500, Color3.fromRGB(  0, 255, 255)),
        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(  0,   0, 255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,   0, 255)),
        ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255,   0,   0)),
    })
    HueGradient.Parent = HueBar

    local HueCursor = Instance.new("Frame")
    HueCursor.Size             = UDim2.new(0, 6, 1, 4)
    HueCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
    HueCursor.Position         = UDim2.new(H, 0, 0.5, 0)
    HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HueCursor.ZIndex           = 3
    HueCursor.Parent           = HueBar

    local HueCursorCorner = Instance.new("UICorner")
    HueCursorCorner.CornerRadius = UDim.new(0, 2)
    HueCursorCorner.Parent = HueCursor

    local HueCursorStroke = Instance.new("UIStroke")
    HueCursorStroke.Color     = Color3.fromRGB(0, 0, 0)
    HueCursorStroke.Thickness = 1
    HueCursorStroke.Parent    = HueCursor

    -- Preview + Hex row
    local PreviewRow = Instance.new("Frame")
    PreviewRow.Size             = UDim2.new(1, 0, 0, 28)
    PreviewRow.Position         = UDim2.new(0, 0, 0, 166)
    PreviewRow.BackgroundTransparency = 1
    PreviewRow.Parent           = Panel

    local Preview = Instance.new("Frame")
    Preview.Size             = UDim2.fromOffset(28, 28)
    Preview.BackgroundColor3 = self._color
    Preview.Parent           = PreviewRow

    local PreviewCorner = Instance.new("UICorner")
    PreviewCorner.CornerRadius = UDim.new(0, 6)
    PreviewCorner.Parent = Preview

    local PreviewStroke = Instance.new("UIStroke")
    PreviewStroke.Color     = T.Border
    PreviewStroke.Thickness = 1.5
    PreviewStroke.Parent    = Preview

    local HexBox = Instance.new("TextBox")
    HexBox.Size               = UDim2.new(1, -38, 1, 0)
    HexBox.Position           = UDim2.fromOffset(36, 0)
    HexBox.BackgroundColor3   = T.InputBg or T.SurfaceLight
    HexBox.Font               = Enum.Font.Code
    HexBox.Text               = ColorUtil.Color3ToHex(self._color)
    HexBox.TextColor3         = T.TextPrimary
    HexBox.TextSize           = 13
    HexBox.ClearTextOnFocus   = false
    HexBox.Parent             = PreviewRow

    local HexCorner = Instance.new("UICorner")
    HexCorner.CornerRadius = UDim.new(0, 6)
    HexCorner.Parent = HexBox

    local HexPad = Instance.new("UIPadding")
    HexPad.PaddingLeft  = UDim.new(0, 8)
    HexPad.PaddingRight = UDim.new(0, 8)
    HexPad.Parent = HexBox

    -- --------------------------------------------------------
    -- INTERNAL UPDATER
    -- --------------------------------------------------------
    local function Apply()
        self._color = ColorUtil.HSVtoRGB(self._H, self._S, self._V)
        SVCanvas.BackgroundColor3 = ColorUtil.HSVtoRGB(self._H, 1, 1)
        SVCursor.Position         = UDim2.new(self._S, 0, 1 - self._V, 0)
        HueCursor.Position        = UDim2.new(self._H, 0, 0.5, 0)
        Swatch.BackgroundColor3   = self._color
        Preview.BackgroundColor3  = self._color
        HexBox.Text               = ColorUtil.Color3ToHex(self._color)

        if self._callback then task.spawn(self._callback, self._color) end
        if self._flag then
            EventBus.Fire(EventBus.Events.COMPONENT_CHANGED, {
                flag  = self._flag,
                value = self._color,
            })
        end
    end

    -- --------------------------------------------------------
    -- DRAG LOGIC (scoped connections)
    -- --------------------------------------------------------
    local draggingSV  = false
    local draggingHue = false

    table.insert(self._connections, SVCanvas.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            draggingSV = true
            local rel = inp.Position - SVCanvas.AbsolutePosition
            self._S = math.clamp(rel.X / SVCanvas.AbsoluteSize.X, 0, 1)
            self._V = 1 - math.clamp(rel.Y / SVCanvas.AbsoluteSize.Y, 0, 1)
            Apply()
        end
    end))

    local hueHitbox = Instance.new("TextButton")
    hueHitbox.Size                = UDim2.fromScale(1, 1)
    hueHitbox.BackgroundTransparency = 1
    hueHitbox.Text                = ""
    hueHitbox.ZIndex              = 4
    hueHitbox.Parent              = HueBar

    table.insert(self._connections, hueHitbox.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            self._H = math.clamp(
                (inp.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X,
                0, 1
            )
            Apply()
        end
    end))

    local moveConn = UserInputService.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            if draggingSV then
                local rel = inp.Position - SVCanvas.AbsolutePosition
                self._S = math.clamp(rel.X / SVCanvas.AbsoluteSize.X, 0, 1)
                self._V = 1 - math.clamp(rel.Y / SVCanvas.AbsoluteSize.Y, 0, 1)
                Apply()
            elseif draggingHue then
                self._H = math.clamp(
                    (inp.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X,
                    0, 1
                )
                Apply()
            end
        end
    end)
    table.insert(self._connections, moveConn)

    local endConn = UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            draggingSV  = false
            draggingHue = false
        end
    end)
    table.insert(self._connections, endConn)

    -- Hex input
    table.insert(self._connections, HexBox.FocusLost:Connect(function()
        local color = ColorUtil.HexToColor3(HexBox.Text)
        self._H, self._S, self._V = ColorUtil.RGBtoHSV(color)
        Apply()
    end))

    -- Open/close toggle
    local HitArea = Instance.new("TextButton")
    HitArea.Size                = UDim2.fromScale(1, 1)
    HitArea.BackgroundTransparency = 1
    HitArea.Text                = ""
    HitArea.ZIndex              = 4
    HitArea.Parent              = Header

    table.insert(self._connections, HitArea.MouseButton1Click:Connect(function()
        self._isOpen = not self._isOpen
        local totalH = T.RowHeight + 4 + 230
        if self._isOpen then
            TweenService:Create(Wrapper, Transitions.ColorPickerOpen, {
                Size = UDim2.new(1, 0, 0, totalH)
            }):Play()
        else
            TweenService:Create(Wrapper, Transitions.ColorPickerClose, {
                Size = UDim2.new(1, 0, 0, T.RowHeight)
            }):Play()
        end
    end))

    -- Theme
    self._themeSubId = ThemeManager.Subscribe(function(tokens)
        Header.BackgroundColor3  = tokens.SurfaceLight
        HeaderStroke.Color       = tokens.Border
        NameLabel.TextColor3     = tokens.TextPrimary
        Panel.BackgroundColor3   = tokens.SurfaceOverlay or tokens.Surface
        HexBox.BackgroundColor3  = tokens.InputBg or tokens.SurfaceLight
        HexBox.TextColor3        = tokens.TextPrimary
    end)

    self._wrapper = Wrapper

    -- --------------------------------------------------------
    -- PUBLIC HANDLE
    -- --------------------------------------------------------
    local handle = {}

    function handle:Set(color)
        self._color = color
        self._H, self._S, self._V = ColorUtil.RGBtoHSV(color)
        Apply()
    end

    function handle:Get()
        return self._color
    end

    function handle:Destroy()
        ThemeManager.Unsubscribe(self._themeSubId)
        for _, c in ipairs(self._connections) do c:Disconnect() end
        if self._wrapper then self._wrapper:Destroy() end
    end

    handle._color       = self._color
    handle._connections = self._connections
    handle._themeSubId  = self._themeSubId
    handle._wrapper     = self._wrapper
    handle._H = self._H
    handle._S = self._S
    handle._V = self._V

    return handle
end

return ColorPicker
