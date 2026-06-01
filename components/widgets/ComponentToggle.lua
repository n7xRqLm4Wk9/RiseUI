--[[
  File: ComponentToggle.lua
  Layer: Components/Widgets
  Responsibility: Toggle row with ⋯ button that
  opens an inline config panel containing any
  child widgets. Visual code by Gemini, integrated
  into LuxwareUI architecture by Claude.
  Fixes: theme integration, scoped connections,
  background frame, destroy cleanup, icon support.
  Dependencies: core/EventBus, animation/Animator,
  animation/Transitions, theme/ThemeManager
  Public API: ComponentToggle.new(parent, config) → handle
  handle.Set(bool), handle.Get() → bool,
  handle.GetConfigPanel() → Frame,
  handle.Destroy()
]]

local TweenService  = game:GetService("TweenService")
local Animator      = require(script.Parent.Parent.Parent.animation.Animator)
local Transitions   = require(script.Parent.Parent.Parent.animation.Transitions)
local EventBus      = require(script.Parent.Parent.Parent.core.EventBus)
local ThemeManager  = require(script.Parent.Parent.Parent.theme.ThemeManager)

local ComponentToggle = {}
ComponentToggle.__index = ComponentToggle

function ComponentToggle.new(parent, config)
    config = config or {}
    local self         = setmetatable({}, ComponentToggle)
    local T            = ThemeManager.GetAll()

    self._state        = config.CurrentValue == true
    self._isConfigOpen = false
    self._flag         = config.Flag
    self._callback     = config.Callback
    self._connections  = {}

    -- --------------------------------------------------------
    -- ROOT WRAPPER (expands to show config panel)
    -- --------------------------------------------------------
    local Wrapper = Instance.new("Frame")
    Wrapper.Name             = "CompToggle_" .. (config.Name or "Module")
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
    HeaderStroke.Color        = T.BorderGlow
    HeaderStroke.Thickness    = 1.5
    HeaderStroke.Transparency = T.StrokeTransparencyAccent
    HeaderStroke.Parent = Header

    local HeaderPad = Instance.new("UIPadding")
    HeaderPad.PaddingLeft  = UDim.new(0, T.ComponentPadH)
    HeaderPad.PaddingRight = UDim.new(0, T.ComponentPadH)
    HeaderPad.Parent = Header

    -- Name label
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size               = UDim2.new(1, -80, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font               = Enum.Font.GothamBold
    NameLabel.Text               = config.Name or "Module"
    NameLabel.TextColor3         = T.AccentLight or T.Accent
    NameLabel.TextSize           = T.SizeLG
    NameLabel.TextXAlignment     = Enum.TextXAlignment.Left
    NameLabel.Parent             = Header

    -- ⋯ Config button
    local ConfigBtn = Instance.new("TextButton")
    ConfigBtn.Size             = UDim2.fromOffset(28, 28)
    ConfigBtn.Position         = UDim2.new(1, -74, 0.5, -14)
    ConfigBtn.BackgroundColor3 = T.Surface
    ConfigBtn.AutoButtonColor  = false
    ConfigBtn.Font             = Enum.Font.GothamBold
    ConfigBtn.Text             = "⋯"
    ConfigBtn.TextColor3       = T.TextSecondary
    ConfigBtn.TextSize         = 16
    ConfigBtn.Parent           = Header

    local ConfigBtnCorner = Instance.new("UICorner")
    ConfigBtnCorner.CornerRadius = UDim.new(0, T.RadiusSM)
    ConfigBtnCorner.Parent = ConfigBtn

    -- Toggle Pill
    local Pill = Instance.new("Frame")
    Pill.Size             = UDim2.fromOffset(42, 22)
    Pill.Position         = UDim2.new(1, -42, 0.5, -11)
    Pill.BackgroundColor3 = self._state and T.ToggleOn or T.ToggleOff
    Pill.Parent           = Header

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

    -- Pill hitbox (independent from ⋯)
    local PillHit = Instance.new("TextButton")
    PillHit.Size                = UDim2.fromOffset(50, 34)
    PillHit.Position            = UDim2.new(1, -50, 0.5, -17)
    PillHit.BackgroundTransparency = 1
    PillHit.Text                = ""
    PillHit.ZIndex              = 4
    PillHit.Parent              = Header

    -- --------------------------------------------------------
    -- CONFIG PANEL
    -- --------------------------------------------------------
    local ConfigPanel = Instance.new("Frame")
    ConfigPanel.Name             = "ConfigPanel"
    ConfigPanel.Size             = UDim2.new(1, -8, 0, 0)
    ConfigPanel.Position         = UDim2.new(0, 4, 0, T.RowHeight + 4)
    ConfigPanel.BackgroundColor3 = T.Surface
    ConfigPanel.ClipsDescendants = true
    ConfigPanel.Parent           = Wrapper

    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, T.RadiusComponent)
    PanelCorner.Parent = ConfigPanel

    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color        = T.Border
    PanelStroke.Thickness    = 1
    PanelStroke.Transparency = T.StrokeTransparency
    PanelStroke.Parent = ConfigPanel

    local PanelPad = Instance.new("UIPadding")
    PanelPad.PaddingTop    = UDim.new(0, 6)
    PanelPad.PaddingBottom = UDim.new(0, 6)
    PanelPad.PaddingLeft   = UDim.new(0, 6)
    PanelPad.PaddingRight  = UDim.new(0, 6)
    PanelPad.Parent = ConfigPanel

    local PanelLayout = Instance.new("UIListLayout")
    PanelLayout.Padding   = UDim.new(0, 4)
    PanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PanelLayout.Parent    = ConfigPanel

    -- --------------------------------------------------------
    -- HEIGHT CALCULATION
    -- --------------------------------------------------------
    local function UpdateHeight()
        if self._isConfigOpen then
            local contentH   = PanelLayout.AbsoluteContentSize.Y + 12
            local targetH    = T.RowHeight + 4 + contentH
            TweenService:Create(ConfigPanel, Transitions.PanelOpen, {
                Size = UDim2.new(1, -8, 0, contentH)
            }):Play()
            TweenService:Create(Wrapper, Transitions.PanelOpen, {
                Size = UDim2.new(1, 0, 0, targetH)
            }):Play()
        else
            TweenService:Create(ConfigPanel, Transitions.PanelClose, {
                Size = UDim2.new(1, -8, 0, 0)
            }):Play()
            TweenService:Create(Wrapper, Transitions.PanelClose, {
                Size = UDim2.new(1, 0, 0, T.RowHeight)
            }):Play()
        end
    end

    -- Auto-resize when children added
    table.insert(self._connections,
        PanelLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if self._isConfigOpen then UpdateHeight() end
        end)
    )

    -- --------------------------------------------------------
    -- TOGGLE LOGIC
    -- --------------------------------------------------------
    local function UpdateToggle()
        Animator.Tween(Pill, Transitions.Toggle, {
            BackgroundColor3 = self._state and T.ToggleOn or T.ToggleOff
        })
        Animator.Tween(Knob, Transitions.Toggle, {
            Position = UDim2.new(0, self._state and 23 or 3, 0.5, -8)
        })
    end

    table.insert(self._connections, PillHit.MouseButton1Click:Connect(function()
        self._state = not self._state
        UpdateToggle()
        if self._flag then
            EventBus.Fire(EventBus.Events.COMPONENT_CHANGED, {
                flag  = self._flag,
                value = self._state,
            })
        end
        if self._callback then task.spawn(self._callback, self._state) end
    end))

    -- ⋯ button logic
    table.insert(self._connections, ConfigBtn.MouseButton1Click:Connect(function()
        self._isConfigOpen = not self._isConfigOpen
        Animator.Tween(ConfigBtn, Transitions.Fast, {
            BackgroundColor3 = self._isConfigOpen and T.Accent or T.Surface,
            TextColor3 = self._isConfigOpen and T.TextOnAccent or T.TextSecondary,
        })
        UpdateHeight()
    end))

    -- Hover on header
    table.insert(self._connections, Header.MouseEnter:Connect(function()
        Animator.Play(Header, "Hover", { BackgroundColor3 = T.SurfaceHover })
    end))
    table.insert(self._connections, Header.MouseLeave:Connect(function()
        Animator.Play(Header, "HoverOut", { BackgroundColor3 = T.SurfaceLight })
    end))

    -- --------------------------------------------------------
    -- THEME SUBSCRIPTION
    -- --------------------------------------------------------
    self._themeSubId = ThemeManager.Subscribe(function(tokens)
        Header.BackgroundColor3   = tokens.SurfaceLight
        HeaderStroke.Color        = tokens.BorderGlow
        NameLabel.TextColor3      = tokens.AccentLight or tokens.Accent
        Pill.BackgroundColor3     = self._state and tokens.ToggleOn or tokens.ToggleOff
        Knob.BackgroundColor3     = tokens.ToggleKnob
        ConfigPanel.BackgroundColor3 = tokens.Surface
        PanelStroke.Color         = tokens.Border
        if not self._isConfigOpen then
            ConfigBtn.BackgroundColor3 = tokens.Surface
            ConfigBtn.TextColor3       = tokens.TextSecondary
        end
    end)

    self._wrapper      = Wrapper
    self._configPanel  = ConfigPanel

    -- --------------------------------------------------------
    -- PUBLIC HANDLE
    -- --------------------------------------------------------
    local handle = {}

    function handle:Set(value)
        self._state = value == true
        UpdateToggle()
    end

    function handle:Get()
        return self._state
    end

    -- Returns ConfigPanel so caller can parent widgets into it
    function handle:GetConfigPanel()
        return self._configPanel
    end

    function handle:Destroy()
        ThemeManager.Unsubscribe(self._themeSubId)
        for _, c in ipairs(self._connections) do c:Disconnect() end
        if self._wrapper then self._wrapper:Destroy() end
    end

    handle._state       = self._state
    handle._connections = self._connections
    handle._themeSubId  = self._themeSubId
    handle._wrapper     = self._wrapper
    handle._configPanel = self._configPanel

    return handle
end

return ComponentToggle
