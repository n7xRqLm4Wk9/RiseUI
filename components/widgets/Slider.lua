--[[
  File: Slider.lua
  Layer: Components/Widgets
  Responsibility: Slider widget row.
  Visual code by Gemini, integrated into
  LuxwareUI architecture by Claude.
  Fixes: scoped connections, theme integration,
  background frame, destroy cleanup.
  Dependencies: core/EventBus, animation/Animator,
  animation/Transitions, theme/ThemeManager
  Public API: Slider.new(parent, config) → handle
  handle.Set(number), handle.Get() → number,
  handle.Destroy()
]]

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Animator         = require(script.Parent.Parent.Parent.animation.Animator)
local Transitions      = require(script.Parent.Parent.Parent.animation.Transitions)
local EventBus         = require(script.Parent.Parent.Parent.core.EventBus)
local ThemeManager     = require(script.Parent.Parent.Parent.theme.ThemeManager)
local MathUtil         = require(script.Parent.Parent.Parent.utils.Math)

local Slider = {}
Slider.__index = Slider

function Slider.new(parent, config)
    config = config or {}
    local self      = setmetatable({}, Slider)
    local T         = ThemeManager.GetAll()
    local Min       = config.Range and config.Range[1] or 0
    local Max       = config.Range and config.Range[2] or 100
    local Inc       = config.Increment or 1
    local Suffix    = config.Suffix or ""
    local isDragging = false

    self._value       = math.clamp(config.CurrentValue or Min, Min, Max)
    self._flag        = config.Flag
    self._callback    = config.Callback
    self._connections = {}

    -- --------------------------------------------------------
    -- ROOT FRAME
    -- --------------------------------------------------------
    local Row = Instance.new("Frame")
    Row.Name             = "Slider_" .. (config.Name or "Slider")
    Row.Size             = UDim2.new(1, 0, 0, T.RowHeightSlider)
    Row.BackgroundColor3 = T.SurfaceLight
    Row.Parent           = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, T.RadiusComponent)
    Corner.Parent = Row

    local Stroke = Instance.new("UIStroke")
    Stroke.Color        = T.Border
    Stroke.Thickness    = 1
    Stroke.Transparency = T.StrokeTransparency
    Stroke.Parent = Row

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft   = UDim.new(0, T.ComponentPadH)
    Padding.PaddingRight  = UDim.new(0, T.ComponentPadH)
    Padding.PaddingTop    = UDim.new(0, 10)
    Padding.PaddingBottom = UDim.new(0, 10)
    Padding.Parent = Row

    -- --------------------------------------------------------
    -- TOP ROW: NAME + VALUE
    -- --------------------------------------------------------
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size               = UDim2.new(0.6, 0, 0, 16)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font               = Enum.Font.GothamMedium
    NameLabel.Text               = config.Name or "Slider"
    NameLabel.TextColor3         = T.TextPrimary
    NameLabel.TextSize           = T.SizeLG
    NameLabel.TextXAlignment     = Enum.TextXAlignment.Left
    NameLabel.Parent             = Row

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size              = UDim2.new(0.4, 0, 0, 16)
    ValueLabel.Position          = UDim2.new(0.6, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Font              = Enum.Font.GothamBold
    ValueLabel.Text              = tostring(self._value) .. Suffix
    ValueLabel.TextColor3        = T.Accent
    ValueLabel.TextSize          = T.SizeSM
    ValueLabel.TextXAlignment    = Enum.TextXAlignment.Right
    ValueLabel.Parent            = Row

    -- --------------------------------------------------------
    -- TRACK
    -- --------------------------------------------------------
    local Track = Instance.new("Frame")
    Track.Size             = UDim2.new(1, 0, 0, 6)
    Track.Position         = UDim2.new(0, 0, 1, -6)
    Track.AnchorPoint      = Vector2.new(0, 1)
    Track.BackgroundColor3 = T.SliderTrack
    Track.Parent           = Row

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local pct = MathUtil.SliderProgress(self._value, Min, Max)

    local Fill = Instance.new("Frame")
    Fill.Size             = UDim2.new(pct, 0, 1, 0)
    Fill.BackgroundColor3 = T.SliderFill
    Fill.Parent           = Track

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Thumb = Instance.new("Frame")
    Thumb.Size             = UDim2.fromOffset(14, 14)
    Thumb.AnchorPoint      = Vector2.new(0.5, 0.5)
    Thumb.Position         = UDim2.new(pct, 0, 0.5, 0)
    Thumb.BackgroundColor3 = T.SliderThumb
    Thumb.ZIndex           = 3
    Thumb.Parent           = Track

    local ThumbCorner = Instance.new("UICorner")
    ThumbCorner.CornerRadius = UDim.new(1, 0)
    ThumbCorner.Parent = Thumb

    local ThumbStroke = Instance.new("UIStroke")
    ThumbStroke.Color     = T.SliderThumbBorder
    ThumbStroke.Thickness = 2
    ThumbStroke.Parent    = Thumb

    -- --------------------------------------------------------
    -- DRAG HITBOX (larger than track for easier mobile touch)
    -- --------------------------------------------------------
    local Hitbox = Instance.new("TextButton")
    Hitbox.Size                = UDim2.new(1, 0, 0, 30)
    Hitbox.Position            = UDim2.new(0, 0, 1, -24)
    Hitbox.BackgroundTransparency = 1
    Hitbox.Text                = ""
    Hitbox.ZIndex              = 4
    Hitbox.Parent              = Row

    -- --------------------------------------------------------
    -- UPDATE LOGIC
    -- --------------------------------------------------------
    local function UpdateSlider(inputX)
        local relX  = math.clamp(
            inputX - Track.AbsolutePosition.X,
            0,
            Track.AbsoluteSize.X
        )
        local rawPct   = relX / Track.AbsoluteSize.X
        local rawVal   = Min + (Max - Min) * rawPct
        self._value    = MathUtil.RoundToIncrement(
            math.clamp(rawVal, Min, Max),
            Inc
        )
        local snappedPct = MathUtil.SliderProgress(self._value, Min, Max)

        TweenService:Create(Fill, Transitions.SliderFill, {
            Size = UDim2.new(snappedPct, 0, 1, 0)
        }):Play()
        TweenService:Create(Thumb, Transitions.SliderFill, {
            Position = UDim2.new(snappedPct, 0, 0.5, 0)
        }):Play()

        ValueLabel.Text = tostring(self._value) .. Suffix

        if self._callback then
            task.spawn(self._callback, self._value)
        end
        if self._flag then
            EventBus.Fire(EventBus.Events.COMPONENT_CHANGED, {
                flag  = self._flag,
                value = self._value,
            })
        end
    end

    -- --------------------------------------------------------
    -- INPUT EVENTS (scoped)
    -- --------------------------------------------------------
    table.insert(self._connections, Hitbox.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            UpdateSlider(inp.Position.X)
        end
    end))

    local moveConn = UserInputService.InputChanged:Connect(function(inp)
        if isDragging and (
            inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch
        ) then
            UpdateSlider(inp.Position.X)
        end
    end)
    table.insert(self._connections, moveConn)

    local endConn = UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    table.insert(self._connections, endConn)

    -- --------------------------------------------------------
    -- THEME SUBSCRIPTION
    -- --------------------------------------------------------
    self._themeSubId = ThemeManager.Subscribe(function(tokens)
        Row.BackgroundColor3   = tokens.SurfaceLight
        Stroke.Color           = tokens.Border
        NameLabel.TextColor3   = tokens.TextPrimary
        ValueLabel.TextColor3  = tokens.Accent
        Track.BackgroundColor3 = tokens.SliderTrack
        Fill.BackgroundColor3  = tokens.SliderFill
        Thumb.BackgroundColor3 = tokens.SliderThumb
        ThumbStroke.Color      = tokens.SliderThumbBorder
    end)

    self._row = Row

    -- --------------------------------------------------------
    -- PUBLIC HANDLE
    -- --------------------------------------------------------
    local handle = {}

    function handle:Set(val)
        self._value = math.clamp(
            MathUtil.RoundToIncrement(val, Inc),
            Min, Max
        )
        local p = MathUtil.SliderProgress(self._value, Min, Max)
        Fill.Size      = UDim2.new(p, 0, 1, 0)
        Thumb.Position = UDim2.new(p, 0, 0.5, 0)
        ValueLabel.Text = tostring(self._value) .. Suffix
    end

    function handle:Get()
        return self._value
    end

    function handle:Destroy()
        ThemeManager.Unsubscribe(self._themeSubId)
        for _, c in ipairs(self._connections) do
            c:Disconnect()
        end
        if self._row then self._row:Destroy() end
    end

    handle._value       = self._value
    handle._connections = self._connections
    handle._themeSubId  = self._themeSubId
    handle._row         = self._row

    return handle
end

return Slider
