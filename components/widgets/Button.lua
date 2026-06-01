--[[
  File: Button.lua
  Layer: Components/Widgets
  Responsibility: Button widget row.
  Visual code by Gemini, integrated into
  LuxwareUI architecture by Claude.
  Dependencies: core/EventBus, animation/Animator,
  animation/Transitions, theme/ThemeManager
  Public API: Button.new(parent, config) → handle
]]

local Animator     = require(script.Parent.Parent.Parent.animation.Animator)
local Transitions  = require(script.Parent.Parent.Parent.animation.Transitions)
local EventBus     = require(script.Parent.Parent.Parent.core.EventBus)
local ThemeManager = require(script.Parent.Parent.Parent.theme.ThemeManager)

local Button = {}
Button.__index = Button

function Button.new(parent, config)
    config = config or {}
    local self      = setmetatable({}, Button)
    local T         = ThemeManager.GetAll()
    local hasDesc   = config.Description and config.Description ~= ""
    local rowHeight = hasDesc and 52 or 40

    self._callback    = config.Callback
    self._connections = {}

    -- Root (TextButton so entire row is clickable)
    local Row = Instance.new("TextButton")
    Row.Name             = "Button_" .. (config.Name or "Button")
    Row.Size             = UDim2.new(1, 0, 0, rowHeight)
    Row.BackgroundColor3 = T.SurfaceLight
    Row.AutoButtonColor  = false
    Row.Text             = ""
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
    Padding.PaddingLeft  = UDim.new(0, T.ComponentPadH)
    Padding.PaddingRight = UDim.new(0, T.ComponentPadH)
    Padding.Parent = Row

    -- Icon
    local iconOffset = 0
    if config.Icon and config.Icon ~= "" then
        local Icon = Instance.new("TextLabel")
        Icon.Size                = UDim2.fromOffset(18, 18)
        Icon.Position            = UDim2.new(0, 0, 0.5, -9)
        Icon.BackgroundTransparency = 1
        Icon.Text                = config.Icon
        Icon.TextSize            = 14
        Icon.TextColor3          = T.Accent
        Icon.Font                = Enum.Font.GothamBold
        Icon.Parent              = Row
        iconOffset = 26
    end

    -- Name
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size               = UDim2.new(1, -iconOffset, 0, 16)
    NameLabel.Position           = UDim2.new(0, iconOffset, 0, hasDesc and 8 or (rowHeight / 2 - 8))
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font               = Enum.Font.GothamMedium
    NameLabel.Text               = config.Name or "Button"
    NameLabel.TextColor3         = T.TextPrimary
    NameLabel.TextSize           = T.SizeLG
    NameLabel.TextXAlignment     = Enum.TextXAlignment.Left
    NameLabel.Parent             = Row

    if hasDesc then
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size               = UDim2.new(1, -iconOffset, 0, 14)
        DescLabel.Position           = UDim2.new(0, iconOffset, 0, 26)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Font               = Enum.Font.Gotham
        DescLabel.Text               = config.Description
        DescLabel.TextColor3         = T.TextSecondary
        DescLabel.TextSize           = T.SizeSM
        DescLabel.TextXAlignment     = Enum.TextXAlignment.Left
        DescLabel.Parent             = Row
    end

    -- Hover / Click
    table.insert(self._connections, Row.MouseEnter:Connect(function()
        Animator.Play(Row, "Hover", { BackgroundColor3 = T.SurfaceHover })
    end))
    table.insert(self._connections, Row.MouseLeave:Connect(function()
        Animator.Play(Row, "HoverOut", { BackgroundColor3 = T.SurfaceLight })
    end))
    table.insert(self._connections, Row.MouseButton1Click:Connect(function()
        Animator.Pulse(Row, T.AccentDim, T.SurfaceLight)
        if self._callback then task.spawn(self._callback) end
    end))

    -- Theme
    self._themeSubId = ThemeManager.Subscribe(function(tokens)
        Row.BackgroundColor3 = tokens.SurfaceLight
        Stroke.Color         = tokens.Border
        NameLabel.TextColor3 = tokens.TextPrimary
    end)

    self._row = Row

    local handle = {}
    function handle:Set(name) NameLabel.Text = name end
    function handle:Destroy()
        ThemeManager.Unsubscribe(self._themeSubId)
        for _, c in ipairs(self._connections) do c:Disconnect() end
        if self._row then self._row:Destroy() end
    end
    handle._connections = self._connections
    handle._themeSubId  = self._themeSubId
    handle._row         = self._row
    return handle
end

return Button
