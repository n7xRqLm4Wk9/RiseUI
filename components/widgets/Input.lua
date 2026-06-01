--[[
  File: Input.lua
  Layer: Components/Widgets
  Responsibility: Text input widget row.
  Visual code by Gemini, integrated into
  LuxwareUI architecture by Claude.
  Fixes: theme integration, scoped connections,
  password masking via dot characters, destroy.
  Dependencies: core/EventBus, animation/Animator,
  animation/Transitions, theme/ThemeManager
  Public API: Input.new(parent, config) → handle
]]

local Animator     = require(script.Parent.Parent.Parent.animation.Animator)
local Transitions  = require(script.Parent.Parent.Parent.animation.Transitions)
local EventBus     = require(script.Parent.Parent.Parent.core.EventBus)
local ThemeManager = require(script.Parent.Parent.Parent.theme.ThemeManager)

local Input = {}
Input.__index = Input

function Input.new(parent, config)
    config = config or {}
    local self      = setmetatable({}, Input)
    local T         = ThemeManager.GetAll()
    local isPassword = config.IsPassword == true
    local isMasked   = isPassword

    self._flag        = config.Flag
    self._callback    = config.Callback
    self._connections = {}

    local Row = Instance.new("Frame")
    Row.Name             = "Input_" .. (config.Name or "Input")
    Row.Size             = UDim2.new(1, 0, 0, 54)
    Row.BackgroundTransparency = 1
    Row.Parent           = parent

    -- Label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size               = UDim2.new(1, 0, 0, 14)
    TitleLabel.Position           = UDim2.new(0, 4, 0, 4)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font               = Enum.Font.GothamMedium
    TitleLabel.Text               = config.Name or "Input"
    TitleLabel.TextColor3         = T.TextSecondary
    TitleLabel.TextSize           = T.SizeMD or 12
    TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
    TitleLabel.Parent             = Row

    -- Box
    local BoxContainer = Instance.new("Frame")
    BoxContainer.Size             = UDim2.new(1, 0, 0, 30)
    BoxContainer.Position         = UDim2.new(0, 0, 0, 22)
    BoxContainer.BackgroundColor3 = T.InputBg
    BoxContainer.Parent           = Row

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, T.RadiusSM)
    BoxCorner.Parent = BoxContainer

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color       = T.InputBorder
    BoxStroke.Thickness   = 1
    BoxStroke.Parent = BoxContainer

    local BoxPad = Instance.new("UIPadding")
    BoxPad.PaddingLeft  = UDim.new(0, 8)
    BoxPad.PaddingRight = UDim.new(0, isPassword and 34 or 8)
    BoxPad.Parent = BoxContainer

    local TextBox = Instance.new("TextBox")
    TextBox.Size               = UDim2.fromScale(1, 1)
    TextBox.BackgroundTransparency = 1
    TextBox.Font               = Enum.Font.Gotham
    TextBox.PlaceholderText    = config.PlaceholderText or "Enter value..."
    TextBox.PlaceholderColor3  = T.InputPlaceholder
    TextBox.Text               = config.CurrentValue or ""
    TextBox.TextColor3         = T.InputText
    TextBox.TextSize           = T.SizeBody
    TextBox.TextXAlignment     = Enum.TextXAlignment.Left
    TextBox.ClearTextOnFocus   = config.ClearTextOnFocus ~= false
    TextBox.Parent             = BoxContainer

    -- Password mask label
    local MaskLabel = Instance.new("TextLabel")
    MaskLabel.Size               = UDim2.fromScale(1, 1)
    MaskLabel.BackgroundTransparency = 1
    MaskLabel.Font               = Enum.Font.Gotham
    MaskLabel.Text               = ""
    MaskLabel.TextColor3         = T.InputText
    MaskLabel.TextSize           = T.SizeBody
    MaskLabel.TextXAlignment     = Enum.TextXAlignment.Left
    MaskLabel.Visible            = isPassword
    MaskLabel.Parent             = BoxContainer

    if isPassword then
        TextBox.TextTransparency = 1
        local EyeBtn = Instance.new("TextButton")
        EyeBtn.Size                = UDim2.fromOffset(28, 28)
        EyeBtn.Position            = UDim2.new(1, -2, 0.5, 0)
        EyeBtn.AnchorPoint         = Vector2.new(1, 0.5)
        EyeBtn.BackgroundTransparency = 1
        EyeBtn.Text                = "👁"
        EyeBtn.TextSize            = 13
        EyeBtn.TextColor3          = T.TextSecondary
        EyeBtn.Parent              = BoxContainer

        table.insert(self._connections, EyeBtn.MouseButton1Click:Connect(function()
            isMasked = not isMasked
            TextBox.TextTransparency = isMasked and 1 or 0
            MaskLabel.Visible        = isMasked
            EyeBtn.TextColor3        = isMasked and T.TextSecondary or T.Accent
        end))
    end

    -- Focus glow
    table.insert(self._connections, TextBox.Focused:Connect(function()
        Animator.Tween(BoxStroke, Transitions.Focus, { Color = T.InputBorderFocus })
    end))
    table.insert(self._connections, TextBox.FocusLost:Connect(function(enter)
        Animator.Tween(BoxStroke, Transitions.Blur, { Color = T.InputBorder })
        if (enter or not config.EnterPressOnly) and self._callback then
            task.spawn(self._callback, TextBox.Text)
        end
        if self._flag then
            EventBus.Fire(EventBus.Events.COMPONENT_CHANGED, {
                flag  = self._flag,
                value = TextBox.Text,
            })
        end
    end))

    -- Password masking
    if isPassword then
        table.insert(self._connections, TextBox:GetPropertyChangedSignal("Text"):Connect(function()
            if isMasked then
                local len = utf8.len(TextBox.Text) or #TextBox.Text
                MaskLabel.Text = string.rep("•", len)
            end
        end))
    end

    -- Theme
    self._themeSubId = ThemeManager.Subscribe(function(tokens)
        BoxContainer.BackgroundColor3 = tokens.InputBg
        BoxStroke.Color               = tokens.InputBorder
        TextBox.TextColor3            = tokens.InputText
        TextBox.PlaceholderColor3     = tokens.InputPlaceholder
        TitleLabel.TextColor3         = tokens.TextSecondary
    end)

    self._row     = Row
    self._textbox = TextBox

    local handle = {}
    function handle:Set(val) TextBox.Text = val end
    function handle:Get() return TextBox.Text end
    function handle:Destroy()
        ThemeManager.Unsubscribe(self._themeSubId)
        for _, c in ipairs(self._connections) do c:Disconnect() end
        if self._row then self._row:Destroy() end
    end
    handle._connections = self._connections
    handle._themeSubId  = self._themeSubId
    handle._row         = self._row
    handle._textbox     = self._textbox
    return handle
end

return Input
