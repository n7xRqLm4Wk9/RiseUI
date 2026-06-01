--[[
  File: Transitions.lua
  Layer: Animation
  Responsibility: Named TweenInfo presets for
  every UI interaction type. Single source of
  truth for all timing decisions. Components
  never hardcode TweenInfo — they reference
  a named transition from this file.
  Dependencies: none
  Public API: Transitions.Get(name) → TweenInfo
  Transitions.Hover, Transitions.Enter,
  Transitions.Exit, Transitions.Spring, etc.
]]

local Transitions = {}

-- ============================================================
-- TWEEN INFO PRESETS
-- Every named transition used in the library.
-- ============================================================
local _presets = {

    -- --------------------------------------------------------
    -- HOVER STATES
    -- Very fast — must feel instant
    -- --------------------------------------------------------
    Hover = TweenInfo.new(
        0.12,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    HoverOut = TweenInfo.new(
        0.18,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- CLICK / PRESS STATES
    -- Fastest possible — immediate feedback
    -- --------------------------------------------------------
    Press = TweenInfo.new(
        0.05,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    ),

    Release = TweenInfo.new(
        0.15,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- TOGGLE ANIMATIONS
    -- Smooth pill slide
    -- --------------------------------------------------------
    Toggle = TweenInfo.new(
        0.20,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- FOCUS STATES
    -- Input border glow
    -- --------------------------------------------------------
    Focus = TweenInfo.new(
        0.18,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    Blur = TweenInfo.new(
        0.25,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- PANEL OPEN / CLOSE
    -- Dropdown, ColorPicker, ModuleConfig, ComponentToggle
    -- --------------------------------------------------------
    PanelOpen = TweenInfo.new(
        0.35,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ),

    PanelClose = TweenInfo.new(
        0.22,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- WINDOW ENTER / EXIT
    -- Main window appearing and disappearing
    -- --------------------------------------------------------
    WindowEnter = TweenInfo.new(
        0.45,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ),

    WindowExit = TweenInfo.new(
        0.28,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.In
    ),

    WindowMinimize = TweenInfo.new(
        0.30,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- TAB SWITCHING
    -- --------------------------------------------------------
    TabSwitch = TweenInfo.new(
        0.20,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    TabIndicator = TweenInfo.new(
        0.25,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- NOTIFICATION
    -- Toast slide in and out
    -- --------------------------------------------------------
    NotifyEnter = TweenInfo.new(
        0.40,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ),

    NotifyExit = TweenInfo.new(
        0.25,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.In
    ),

    NotifyProgress = TweenInfo.new(
        0,  -- Duration set dynamically from config
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- DIALOG
    -- Modal scale in from center
    -- --------------------------------------------------------
    DialogEnter = TweenInfo.new(
        0.35,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ),

    DialogExit = TweenInfo.new(
        0.22,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.In
    ),

    -- --------------------------------------------------------
    -- KEY SYSTEM
    -- --------------------------------------------------------
    KeySystemEnter = TweenInfo.new(
        0.45,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ),

    KeySystemExit = TweenInfo.new(
        0.28,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.In
    ),

    KeySystemShake = TweenInfo.new(
        0.08,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- SLIDER
    -- Fill and thumb position
    -- --------------------------------------------------------
    SliderFill = TweenInfo.new(
        0.04,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- THEME CHANGE
    -- Color transitions when switching theme
    -- --------------------------------------------------------
    ThemeChange = TweenInfo.new(
        0.30,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- COLOR PICKER
    -- --------------------------------------------------------
    ColorPickerOpen = TweenInfo.new(
        0.35,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ),

    ColorPickerClose = TweenInfo.new(
        0.22,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    -- --------------------------------------------------------
    -- GENERIC
    -- --------------------------------------------------------
    Fast = TweenInfo.new(
        0.15,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    Default = TweenInfo.new(
        0.25,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    Slow = TweenInfo.new(
        0.40,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    Spring = TweenInfo.new(
        0.40,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ),

    Linear = TweenInfo.new(
        0.20,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    ),
}

-- ============================================================
-- PUBLIC API
-- ============================================================

--[[
  Get a named TweenInfo preset.

  @param name  string  Preset name
  @return      TweenInfo|nil
]]
function Transitions.Get(name)
    local preset = _presets[name]
    if not preset then
        warn("[LuxwareUI Transitions] Unknown preset: '" .. name .. "'. Using Default.")
        return _presets.Default
    end
    return preset
end

--[[
  Create a custom TweenInfo with a duration override
  on a named preset's style.

  @param name      string  Base preset name
  @param duration  number  Override duration in seconds
  @return          TweenInfo
]]
function Transitions.WithDuration(name, duration)
    local base = _presets[name] or _presets.Default
    return TweenInfo.new(
        duration,
        base.EasingStyle,
        base.EasingDirection,
        base.RepeatCount,
        base.Reverses,
        base.DelayTime
    )
end

-- ============================================================
-- DIRECT REFERENCES
-- Components can do Transitions.Hover instead of Get("Hover")
-- ============================================================
for name, info in pairs(_presets) do
    Transitions[name] = info
end

return Transitions
