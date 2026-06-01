--[[
  File: Keybind.lua
  Layer: Components/Widgets
  Responsibility: Keybind capture widget row.
  Visual code by Gemini, integrated into
  LuxwareUI architecture by Claude.
  Fixes: scoped connections, theme integration,
  global listener properly disconnected on destroy.
  Dependencies: core/EventBus, animation/Animator,
  animation/Transitions, theme/ThemeManager
  Public API: Keybind.new(parent, config) → handle
]]

local UserInputService = game:GetService("UserInputService")
local Animator         = require(script.Parent.Parent.Parent.animation.Animator)
local Transitions      = require(script.Parent.Parent.Parent.animation.Transitions)
local EventBus         = require(script.Parent.Parent.Parent.core.EventBus)
local ThemeManager     = require(script.Parent.Parent.Parent.theme.ThemeManager)

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(parent, config)
    config = config or {}
    local self       = setmetatable({}, Keybind)
    local T          = ThemeManager.GetAll()
    local isListening = false

    self._currentKey  = config.CurrentKeybind or "RightShift"
    self._flag        = config.Flag
    self._callback    = config.Callback
    self._connections = {}

    local Row = Instance.new("Frame")
    Row.Name             = "Keybind_" .. (config.Name or "Keybind")
    Row.Size             = UDim2.new(1, 0, 0, T.RowHeight)
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
    Padding.PaddingLeft  = UDim.new(0, T.ComponentPadH)
    Padding.PaddingRight = UDim.new(0, T.ComponentPadH)
    Padding.Parent = Row

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size               = UDim2.new(0.5, 0, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font               = Enum.Font.GothamMedium
    NameLabel.Text               = config.Name or "Keybind"
    NameLabel.TextColor3         = T.TextPrimary
    NameLabel.TextSize           = T.SizeLG
    NameLabel.TextXAlignment     = Enum.TextXAlignment.Left
    NameLabel.Parent             = Row

    local BindBtn = Instance.new("TextButton")
    BindBtn.Size             = UDim2.fromOffset(0, 26)
    BindBtn.AutomaticSize    = Enum.AutomaticSize.X
    BindBtn.Position         = UDim2.new(1, 0, 0.5, -13)
    BindBtn.AnchorPoint      = Vector2.new(1, 0)
    BindBtn.BackgroundColor3 = T.SurfaceHover
    BindBtn.AutoButtonColor  = false
    BindBtn.Font             = Enum.Font.GothamMedium
    BindBtn.Text             = "[" .. self._currentKey .. "]"
    BindBtn.TextColor3       = T.TextSecondary
    BindBtn.TextSize         = T.SizeSM
    BindBtn.Parent           = Row

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0)
    BtnCorner.Parent = BindBtn

    local BtnPad = Instance.new("UIPadding")
    BtnPad.PaddingLeft  = UDim.new(0, 10)
    BtnPad.PaddingRight = UDim.new(0, 10)
    BtnPad.Parent = BindBtn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color        = T.Border
    BtnStroke.Thickness    = 1
    BtnStroke.Transparency = T.StrokeTransparency
    BtnStroke.Parent = BindBtn

    local function SetListening(state)
        isListening = state
        if state then
            BindBtn.Text = "..."
            Animator.Tween(BindBtn, Transitions.Focus, {
                BackgroundColor3 = T.Accent,
                TextColor3 = T.TextOnAccent,
            })
            Animator.Tween(BtnStroke, Transitions.Focus, { Transparency = 1 })
        else
            BindBtn.Text = "[" .. self._currentKey .. "]"
            Animator.Tween(BindBtn, Transitions.Blur, {
                BackgroundColor3 = T.SurfaceHover,
                TextColor3 = T.TextSecondary,
            })
            Animator.Tween(BtnStroke, Transitions.Blur, {
                Transparency = T.StrokeTransparency
            })
        end
    end

    table.insert(self._connections, BindBtn.MouseButton1Click:Connect(function()
        SetListening(true)
    end))

    -- Scoped global listener — stored so it can be disconnected
    local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not isListening or gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            self._currentKey = input.KeyCode.Name
            SetListening(false)
            if self._flag then
                EventBus.Fire(EventBus.Events.COMPONENT_CHANGED, {
                    flag  = self._flag,
                    value = self._currentKey,
                })
            end
            if self._callback then
                task.spawn(self._callback, input.KeyCode)
            end
        end
    end)
    table.insert(self._connections, inputConn)

    -- Hover
    table.insert(self._connections, Row.MouseEnter:Connect(function()
        Animator.Play(Row, "Hover", { BackgroundColor3 = T.SurfaceHover })
    end))
    table.insert(self._connections, Row.MouseLeave:Connect(function()
        Animator.Play(Row, "HoverOut", { BackgroundColor3 = T.SurfaceLight })
    end))

    -- Theme
    self._themeSubId = ThemeManager.Subscribe(function(tokens)
        Row.BackgroundColor3  = tokens.SurfaceLight
        Stroke.Color          = tokens.Border
        NameLabel.TextColor3  = tokens.TextPrimary
        if not isListening then
            BindBtn.BackgroundColor3 = tokens.SurfaceHover
            BindBtn.TextColor3       = tokens.TextSecondary
        end
    end)

    self._row = Row

    local handle = {}
    function handle:Set(key) self._currentKey = key; BindBtn.Text = "[" .. key .. "]" end
    function handle:Get() return self._currentKey end
    function handle:Destroy()
        ThemeManager.Unsubscribe(self._themeSubId)
        for _, c in ipairs(self._connections) do c:Disconnect() end
        if self._row then self._row:Destroy() end
    end
    handle._currentKey  = self._currentKey
    handle._connections = self._connections
    handle._themeSubId  = self._themeSubId
    handle._row         = self._row
    return handle
end

return Keybind
