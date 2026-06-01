--[[
  File: Label.lua
  Layer: Components/Widgets
  Responsibility: Read-only label widget row.
  Visual code by Gemini, integrated into
  LuxwareUI architecture by Claude.
  Dependencies: theme/ThemeManager
  Public API: Label.new(parent, config) → handle
  handle.Set(text), handle.Destroy()
]]

local ThemeManager = require(script.Parent.Parent.Parent.theme.ThemeManager)

local Label = {}
Label.__index = Label

function Label.new(parent, config)
    config = config or {}
    local self = setmetatable({}, Label)
    local T    = ThemeManager.GetAll()

    local Row = Instance.new("Frame")
    Row.Name             = "Label_" .. (config.Text or "Label")
    Row.Size             = UDim2.new(1, 0, 0, 34)
    Row.BackgroundColor3 = T.SurfaceLight
    Row.BackgroundTransparency = 0.6
    Row.Parent           = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, T.RadiusComponent)
    Corner.Parent = Row

    local Stroke = Instance.new("UIStroke")
    Stroke.Color        = T.Border
    Stroke.Thickness    = 1
    Stroke.Transparency = T.StrokeTransparencySubtle
    Stroke.Parent = Row

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft  = UDim.new(0, config.AccentBar and 14 or T.ComponentPadH)
    Padding.PaddingRight = UDim.new(0, T.ComponentPadH)
    Padding.Parent = Row

    -- Optional left accent bar
    if config.AccentBar then
        local Bar = Instance.new("Frame")
        Bar.Size             = UDim2.fromOffset(3, 16)
        Bar.Position         = UDim2.new(0, 4, 0.5, -8)
        Bar.BackgroundColor3 = T.Accent
        Bar.Parent           = Row
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(1, 0)
        BarCorner.Parent = Bar
    end

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size               = UDim2.fromScale(1, 1)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font               = Enum.Font.Gotham
    TextLabel.Text               = config.Text or ""
    TextLabel.TextColor3         = config.Color or T.TextSecondary
    TextLabel.TextSize           = T.SizeBody
    TextLabel.TextXAlignment     = Enum.TextXAlignment.Left
    TextLabel.TextWrapped        = true
    TextLabel.Parent             = Row

    -- Theme
    self._themeSubId = ThemeManager.Subscribe(function(tokens)
        Stroke.Color       = tokens.Border
        TextLabel.TextColor3 = config.Color or tokens.TextSecondary
    end)

    self._row       = Row
    self._textLabel = TextLabel

    local handle = {}
    function handle:Set(text) TextLabel.Text = text end
    function handle:Destroy()
        ThemeManager.Unsubscribe(self._themeSubId)
        if self._row then self._row:Destroy() end
    end
    handle._themeSubId = self._themeSubId
    handle._row        = self._row
    handle._textLabel  = self._textLabel
    return handle
end

return Label
