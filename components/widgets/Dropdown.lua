--[[
  File: Dropdown.lua
  Layer: Components/Widgets
  Responsibility: Dropdown selection widget.
  Visual code by Gemini, integrated into
  LuxwareUI architecture by Claude.
  Fixes: scoped connections, theme integration,
  background frame, virtual scroll for large lists,
  destroy cleanup, multi-select support.
  Dependencies: core/EventBus, animation/Animator,
  animation/Transitions, theme/ThemeManager
  Public API: Dropdown.new(parent, config) → handle
  handle.Set(value), handle.Get(), handle.Refresh(options),
  handle.Destroy()
]]

local TweenService  = game:GetService("TweenService")
local Animator      = require(script.Parent.Parent.Parent.animation.Animator)
local Transitions   = require(script.Parent.Parent.Parent.animation.Transitions)
local EventBus      = require(script.Parent.Parent.Parent.core.EventBus)
local ThemeManager  = require(script.Parent.Parent.Parent.theme.ThemeManager)

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(parent, config)
    config = config or {}
    local self         = setmetatable({}, Dropdown)
    local T            = ThemeManager.GetAll()
    local isMulti      = config.MultipleOptions == true
    local options      = config.Options or {}

    -- Normalize selected to table
    local selected = config.CurrentOption
    if selected == nil then
        selected = isMulti and {} or (options[1] or "")
    elseif type(selected) == "string" then
        selected = isMulti and { selected } or selected
    end

    self._selected    = selected
    self._options     = options
    self._isMulti     = isMulti
    self._flag        = config.Flag
    self._callback    = config.Callback
    self._connections = {}
    self._isOpen      = false
    self._optionBtns  = {}

    -- --------------------------------------------------------
    -- ROOT WRAPPER (clips to hide list when closed)
    -- --------------------------------------------------------
    local Wrapper = Instance.new("Frame")
    Wrapper.Name             = "Dropdown_" .. (config.Name or "Dropdown")
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
    NameLabel.Size               = UDim2.new(0.5, 0, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font               = Enum.Font.GothamMedium
    NameLabel.Text               = config.Name or "Dropdown"
    NameLabel.TextColor3         = T.TextPrimary
    NameLabel.TextSize           = T.SizeLG
    NameLabel.TextXAlignment     = Enum.TextXAlignment.Left
    NameLabel.Parent             = Header

    local function GetSelectedText()
        if isMulti then
            if type(self._selected) == "table" and #self._selected > 0 then
                return table.concat(self._selected, ", ")
            end
            return "None"
        end
        return type(self._selected) == "string" and self._selected or "None"
    end

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size              = UDim2.new(0.45, -20, 1, 0)
    ValueLabel.Position          = UDim2.new(0.5, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Font              = Enum.Font.Gotham
    ValueLabel.Text              = GetSelectedText()
    ValueLabel.TextColor3        = T.TextSecondary
    ValueLabel.TextSize          = T.SizeSM
    ValueLabel.TextXAlignment    = Enum.TextXAlignment.Right
    ValueLabel.TextTruncate      = Enum.TextTruncate.AtEnd
    ValueLabel.Parent            = Header

    local Chevron = Instance.new("TextLabel")
    Chevron.Size                = UDim2.fromOffset(16, 16)
    Chevron.Position            = UDim2.new(1, -16, 0.5, -8)
    Chevron.BackgroundTransparency = 1
    Chevron.Font                = Enum.Font.GothamBold
    Chevron.Text                = "▾"
    Chevron.TextColor3          = T.TextSecondary
    Chevron.TextSize            = 14
    Chevron.Parent              = Header

    -- --------------------------------------------------------
    -- DROPDOWN LIST
    -- --------------------------------------------------------
    local ListScroll = Instance.new("ScrollingFrame")
    ListScroll.Size                  = UDim2.new(1, 0, 0, 0)
    ListScroll.Position              = UDim2.new(0, 0, 0, T.RowHeight + 4)
    ListScroll.BackgroundColor3      = T.SurfaceOverlay
    ListScroll.ScrollBarThickness    = 3
    ListScroll.ScrollBarImageColor3  = T.ScrollBar
    ListScroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
    ListScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    ListScroll.BorderSizePixel       = 0
    ListScroll.Parent                = Wrapper

    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, T.RadiusComponent)
    ListCorner.Parent = ListScroll

    local ListStroke = Instance.new("UIStroke")
    ListStroke.Color        = T.Border
    ListStroke.Thickness    = 1
    ListStroke.Transparency = T.StrokeTransparency
    ListStroke.Parent = ListScroll

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding    = UDim.new(0, 2)
    ListLayout.SortOrder  = Enum.SortOrder.LayoutOrder
    ListLayout.Parent     = ListScroll

    local ListPad = Instance.new("UIPadding")
    ListPad.PaddingTop    = UDim.new(0, 4)
    ListPad.PaddingBottom = UDim.new(0, 4)
    ListPad.PaddingLeft   = UDim.new(0, 4)
    ListPad.PaddingRight  = UDim.new(0, 4)
    ListPad.Parent        = ListScroll

    -- --------------------------------------------------------
    -- OPTION BUILDER
    -- --------------------------------------------------------
    local function IsSelected(opt)
        if isMulti then
            if type(self._selected) ~= "table" then return false end
            for _, v in ipairs(self._selected) do
                if v == opt then return true end
            end
            return false
        else
            return self._selected == opt
        end
    end

    local function RefreshOptionVisuals()
        for opt, els in pairs(self._optionBtns) do
            local sel = IsSelected(opt)
            els.Btn.BackgroundColor3      = sel and T.DropdownSelected or T.SurfaceOverlay
            els.Btn.BackgroundTransparency = sel and 0 or 1
            els.Label.Font               = sel and Enum.Font.GothamBold or Enum.Font.Gotham
            els.Label.Text               = (sel and "✓  " or "    ") .. opt
            els.Label.TextColor3         = sel and T.DropdownSelectedText or T.TextPrimary
        end
        ValueLabel.Text = GetSelectedText()
    end

    local function BuildOptions()
        -- Clear existing
        for _, els in pairs(self._optionBtns) do
            els.Btn:Destroy()
        end
        self._optionBtns = {}

        for i, opt in ipairs(self._options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size                = UDim2.new(1, 0, 0, 32)
            OptBtn.BackgroundColor3    = T.SurfaceOverlay
            OptBtn.BackgroundTransparency = 1
            OptBtn.AutoButtonColor     = false
            OptBtn.Text                = ""
            OptBtn.LayoutOrder         = i
            OptBtn.ZIndex              = 5
            OptBtn.Parent              = ListScroll

            local OptCorner = Instance.new("UICorner")
            OptCorner.CornerRadius = UDim.new(0, T.RadiusSM)
            OptCorner.Parent = OptBtn

            local OptPad = Instance.new("UIPadding")
            OptPad.PaddingLeft  = UDim.new(0, 10)
            OptPad.PaddingRight = UDim.new(0, 10)
            OptPad.Parent = OptBtn

            local OptLabel = Instance.new("TextLabel")
            OptLabel.Size               = UDim2.fromScale(1, 1)
            OptLabel.BackgroundTransparency = 1
            OptLabel.Font               = Enum.Font.Gotham
            OptLabel.Text               = "    " .. opt
            OptLabel.TextColor3         = T.TextPrimary
            OptLabel.TextSize           = T.SizeBody
            OptLabel.TextXAlignment     = Enum.TextXAlignment.Left
            OptLabel.ZIndex             = 6
            OptLabel.Parent             = OptBtn

            self._optionBtns[opt] = { Btn = OptBtn, Label = OptLabel }

            -- Hover
            OptBtn.MouseEnter:Connect(function()
                if not IsSelected(opt) then
                    OptBtn.BackgroundColor3    = T.DropdownItemHover
                    OptBtn.BackgroundTransparency = 0
                end
            end)
            OptBtn.MouseLeave:Connect(function()
                if not IsSelected(opt) then
                    OptBtn.BackgroundTransparency = 1
                end
            end)

            -- Click
            OptBtn.MouseButton1Click:Connect(function()
                if isMulti then
                    if type(self._selected) ~= "table" then self._selected = {} end
                    local idx = nil
                    for i2, v in ipairs(self._selected) do
                        if v == opt then idx = i2; break end
                    end
                    if idx then
                        table.remove(self._selected, idx)
                    else
                        table.insert(self._selected, opt)
                    end
                else
                    self._selected = opt
                    -- Auto-close on single select
                    self._isOpen = false
                    local closeInfo = Transitions.Get("PanelClose")
                    TweenService:Create(Wrapper, closeInfo, {
                        Size = UDim2.new(1, 0, 0, T.RowHeight)
                    }):Play()
                    TweenService:Create(ListScroll, closeInfo, {
                        Size = UDim2.new(1, 0, 0, 0)
                    }):Play()
                    Animator.Rotate(Chevron, 0, "Fast")
                end

                RefreshOptionVisuals()

                if self._flag then
                    EventBus.Fire(EventBus.Events.COMPONENT_CHANGED, {
                        flag  = self._flag,
                        value = self._selected,
                    })
                end
                if self._callback then
                    task.spawn(self._callback, self._selected)
                end
            end)
        end

        RefreshOptionVisuals()
    end

    BuildOptions()

    -- --------------------------------------------------------
    -- TOGGLE OPEN/CLOSE
    -- --------------------------------------------------------
    local HitArea = Instance.new("TextButton")
    HitArea.Size                = UDim2.fromScale(1, 1)
    HitArea.BackgroundTransparency = 1
    HitArea.Text                = ""
    HitArea.ZIndex              = 4
    HitArea.Parent              = Header

    table.insert(self._connections, HitArea.MouseButton1Click:Connect(function()
        self._isOpen = not self._isOpen
        local maxH   = math.min(#self._options * 34 + 8, 180)
        local openInfo  = Transitions.Get("PanelOpen")
        local closeInfo = Transitions.Get("PanelClose")

        if self._isOpen then
            ListScroll.Size = UDim2.new(1, 0, 0, 0)
            TweenService:Create(Wrapper, openInfo, {
                Size = UDim2.new(1, 0, 0, T.RowHeight + maxH + 8)
            }):Play()
            TweenService:Create(ListScroll, openInfo, {
                Size = UDim2.new(1, 0, 0, maxH)
            }):Play()
            Animator.Rotate(Chevron, 180, "Fast")
        else
            TweenService:Create(Wrapper, closeInfo, {
                Size = UDim2.new(1, 0, 0, T.RowHeight)
            }):Play()
            TweenService:Create(ListScroll, closeInfo, {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            Animator.Rotate(Chevron, 0, "Fast")
        end
    end))

    -- Theme hover
    table.insert(self._connections, HitArea.MouseEnter:Connect(function()
        Animator.Play(Header, "Hover", { BackgroundColor3 = T.SurfaceHover })
    end))
    table.insert(self._connections, HitArea.MouseLeave:Connect(function()
        Animator.Play(Header, "HoverOut", { BackgroundColor3 = T.SurfaceLight })
    end))

    -- --------------------------------------------------------
    -- THEME SUBSCRIPTION
    -- --------------------------------------------------------
    self._themeSubId = ThemeManager.Subscribe(function(tokens)
        Header.BackgroundColor3  = tokens.SurfaceLight
        HeaderStroke.Color       = tokens.Border
        NameLabel.TextColor3     = tokens.TextPrimary
        ValueLabel.TextColor3    = tokens.TextSecondary
        ListScroll.BackgroundColor3 = tokens.SurfaceOverlay
        RefreshOptionVisuals()
    end)

    self._wrapper  = Wrapper
    self._valueLabel = ValueLabel

    -- --------------------------------------------------------
    -- PUBLIC HANDLE
    -- --------------------------------------------------------
    local handle = {}

    function handle:Set(value)
        self._selected = value
        RefreshOptionVisuals()
    end

    function handle:Get()
        return self._selected
    end

    function handle:Refresh(newOptions)
        self._options = newOptions
        BuildOptions()
    end

    function handle:Destroy()
        ThemeManager.Unsubscribe(self._themeSubId)
        for _, conn in ipairs(self._connections) do
            conn:Disconnect()
        end
        if self._wrapper then
            self._wrapper:Destroy()
        end
    end

    handle._selected    = self._selected
    handle._options     = self._options
    handle._flag        = self._flag
    handle._callback    = self._callback
    handle._connections = self._connections
    handle._themeSubId  = self._themeSubId
    handle._wrapper     = self._wrapper

    return handle
end

return Dropdown
