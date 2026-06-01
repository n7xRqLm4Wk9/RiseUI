--[[
  File: Toggle.lua
  Layer: Components/Widgets
  Responsibility: Toggle switch widget row.
  Visual code by Gemini, integrated into
  LuxwareUI architecture by Claude.
  Fixes applied: scoped connections, theme
  integration, background frame, hover state,
  description-aware sizing, destroy cleanup.
  Dependencies: core/EventBus, animation/Animator,
  animation/Transitions, theme/ThemeManager
  Public API: Toggle.new(parent, config) → handle
  handle.Set(bool), handle.Get() → bool,
  handle.Destroy()
]]

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Animator         = require(script.Parent.Parent.Parent.animation.Animator)
local Transitions      = require(script.Parent.Parent.Parent.animation.Transitions)
local EventBus         = require(script.Parent.Parent.Parent.core.EventBus)
local ThemeManager     = require(script.Parent.Parent.Parent.theme.ThemeManager)

local Toggle = {}
Toggle.__index = Toggle

--[[
  Create a new Toggle widget.

  @param parent  Instance  Parent frame (section content)
  @param config  table
    config.Name         string
    config.Description  string?
    config.Icon         string?   rbxassetid or emoji
    config.CurrentValue boolean?
    config.Flag         string?
    config.Callback     function?
  @return  handle table
]]
function Toggle.new(parent, config)
    config = config or {}
    local self      = setmetatable({}, Toggle)
    local T         = ThemeManager.GetAll()
    local hasDesc   = config.Description and config.Description ~= ""
    local rowHeight = hasDesc and T.RowHeightLG or T.RowHeight

    self._state       = config.CurrentValue == true
    self._flag        = config.Flag
    self._callback    = config.Callback
    self._connections = {}

    -- --------------------------------------------------------
    -- ROOT FRAME
    -- --------------------------------------------------------
    local Row = Instance.new("Frame")
    Row.Name             = "Toggle_" .. (config.Name or "Toggle")
    Row.Size             = UDim2.new(1, 0, 0, rowHeight)
    Row.BackgroundColor3 = T.SurfaceLight
    Row.Parent           = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, T.RadiusComponent)
    Corner.Parent = Row

    local Stroke = Instance.new("UIStroke")
    Stroke.Color       = T.Border
    Stroke.Thickness   = 1
    Stroke.Transparency = T.StrokeTransparency
    Stroke.Parent = Row

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft  = UDim.new(0, T.ComponentPadH)
    Padding.PaddingRight = UDim.new(0, T.ComponentPadH)
    Padding.Parent = Row

    -- --------------------------------------------------------
    -- ICON (optional)
    -- --------------------------------------------------------
    local iconOffset = 0
    if config.Icon and config.Icon ~= "" then
        local Icon = Instance.new("TextLabel")
        Icon.Size                = UDim2.fromOffset(18, 18)
        Icon.Position            = UDim2.new(0, 0, 0.5, -9)
        Icon.BackgroundTransparency = 1
        Icon.Text                = config.Icon
        Icon.TextSize            = 14
        Icon.TextColor3          = T.TextSecondary
        Icon.Font                = Enum.Font.GothamBold
        Icon.Parent              = Row
        iconOffset = 26
    end

    -- --------------------------------------------------------
    -- LABELS
    -- --------------------------------------------------------
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size               = UDim2.new(1, -(52 + iconOffset), 0, 16)
    NameLabel.Position           = UDim2.new(0, iconOffset, 0, hasDesc and 8 or (rowHeight / 2 - 8))
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font               = Enum.Font.GothamMedium
    NameLabel.Text               = config.Name or "Toggle"
    NameLabel.TextColor3         = T.TextPrimary
    NameLabel.TextSize           = T.SizeLG
    NameLabel.TextXAlignment     = Enum.TextXAlignment.Left
    NameLabel.Parent             = Row

    if hasDesc then
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size               = UDim2.new(1, -(52 + iconOffset), 0, 14)
        DescLabel.Position           = UDim2.new(0, iconOffset, 0, 26)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Font               = Enum.Font.Gotham
        DescLabel.Text               = config.Description
        DescLabel.TextColor3         = T.TextSecondary
        DescLabel.TextSize           = T.SizeSM
        DescLabel.TextXAlignment     = Enum.TextXAlignment.Left
        DescLabel.TextWrapped        = true
        DescLabel.Parent             = Row
    end

    -- --------------------------------------------------------
    -- TOGGLE PILL
    -- --------------------------------------------------------
    local Pill = Instance.new("Frame")
    Pill.Size             = UDim2.fromOffset(42, 22)
    Pill.Position         = UDim2.new(1, -42, 0.5, -11)
    Pill.BackgroundColor3 = self._state and T.ToggleOn or T.ToggleOff
    Pill.Parent           = Row

    local PillCorner = Instance.new("UICorner")
    PillCorner.CornerRadius = UDim.new(1, 0)
    PillCorner.Parent = Pill

    local Knob = Instance.new("Frame")
    Knob.Size             = UDim2.fromOffset(16, 16)
    Knob.Position         = UDim2.new(0, self._state and 23 or 3, 0.5, -8)
    Knob.BackgroundColor3 = T.ToggleKnob
    Knob.Parent           = Pill

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    -- --------------------------------------------------------
    -- CLICK HITBOX
    -- --------------------------------------------------------
    local HitArea = Instance.new("TextButton")
    HitArea.Size                = UDim2.fromScale(1, 1)
    HitArea.BackgroundTransparency = 1
    HitArea.Text                = ""
    HitArea.ZIndex              = 3
    HitArea.Parent              = Row

    -- --------------------------------------------------------
    -- INTERNAL UPDATE
    -- --------------------------------------------------------
    local function UpdateVisual()
        Animator.Tween(Pill, Transitions.Toggle, {
            BackgroundColor3 = self._state and T.ToggleOn or T.ToggleOff
        })
        Animator.Tween(Knob, Transitions.Toggle, {
            Position = UDim2.new(0, self._state and 23 or 3, 0.5, -8)
        })
    end

    -- --------------------------------------------------------
    -- HOVER
    -- --------------------------------------------------------
    table.insert(self._connections, HitArea.MouseEnter:Connect(function()
        Animator.Play(Row, "Hover", { BackgroundColor3 = T.SurfaceHover })
    end))
    table.insert(self._connections, HitArea.MouseLeave:Connect(function()
        Animator.Play(Row, "HoverOut", { BackgroundColor3 = T.SurfaceLight })
    end))

    -- --------------------------------------------------------
    -- CLICK
    -- --------------------------------------------------------
    table.insert(self._connections, HitArea.MouseButton1Click:Connect(function()
        self._state = not self._state
        UpdateVisual()

        -- Update flag
        if self._flag then
            EventBus.Fire(EventBus.Events.COMPONENT_CHANGED, {
                flag  = self._flag,
                value = self._state,
            })
        end

        if self._callback then
            task.spawn(self._callback, self._state)
        end
    end))

    -- --------------------------------------------------------
    -- THEME SUBSCRIPTION
    -- --------------------------------------------------------
    self._themeSubId = ThemeManager.Subscribe(function(tokens)
        Row.BackgroundColor3  = tokens.SurfaceLight
        Stroke.Color          = tokens.Border
        NameLabel.TextColor3  = tokens.TextPrimary
        Pill.BackgroundColor3 = self._state and tokens.ToggleOn or tokens.ToggleOff
        Knob.BackgroundColor3 = tokens.ToggleKnob
    end)

    self._row = Row
    self._pill = Pill
    self._knob = Knob

    -- --------------------------------------------------------
    -- PUBLIC HANDLE
    -- --------------------------------------------------------
    local handle = {}

    function handle:Set(value)
        self._state = value == true
        UpdateVisual()
        if self._flag then
            EventBus.Fire(EventBus.Events.COMPONENT_CHANGED, {
                flag  = self._flag,
                value = self._state,
            })
        end
    end

    function handle:Get()
        return self._state
    end

    function handle:Destroy()
        ThemeManager.Unsubscribe(self._themeSubId)
        for _, conn in ipairs(self._connections) do
            conn:Disconnect()
        end
        self._connections = {}
        if self._row then
            self._row:Destroy()
            self._row = nil
        end
    end

    -- bind self methods to handle
    handle._state      = self._state
    handle._flag       = self._flag
    handle._callback   = self._callback
    handle._connections = self._connections
    handle._themeSubId = self._themeSubId
    handle._row        = self._row

    return handle
end

return Toggle
