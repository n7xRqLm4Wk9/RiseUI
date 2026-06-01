--[[
  File: ThemeManager.lua
  Layer: Theme
  Responsibility: Runtime theme management.
  Owns the active theme token table, resolves
  semantic keys to concrete values, notifies all
  subscribed components when theme changes, and
  supports live theme switching with zero restarts.
  Dependencies: core/EventBus, all token files,
  all preset files
  Public API: ThemeManager.SetTheme,
  ThemeManager.Resolve, ThemeManager.GetAll,
  ThemeManager.Subscribe, ThemeManager.GetName,
  ThemeManager.IsDark
]]

-- ============================================================
-- REQUIRES
-- ============================================================
local EventBus = require(script.Parent.Parent.core.EventBus)

-- Token files
local TokenDark   = require(script.Parent.tokens.dark)
local TokenLight  = require(script.Parent.tokens.light)
local TokenAmoled = require(script.Parent.tokens.amoled)

-- Preset files
local PresetDefault    = require(script.Parent.presets.Default)
local PresetMidnight   = require(script.Parent.presets.Midnight)
local PresetNeon       = require(script.Parent.presets.Neon)
local PresetPearlWhite = require(script.Parent.presets.PearlWhite)
local PresetAMOLED     = require(script.Parent.presets.AMOLED)

local Table = require(script.Parent.Parent.utils.Table)

-- ============================================================
-- PRESET REGISTRY
-- Maps string names to preset tables
-- ============================================================
local PRESETS = {
    ["Default"]    = PresetDefault,
    ["default"]    = PresetDefault,
    ["Dark"]       = PresetDefault,
    ["dark"]       = PresetDefault,
    ["Midnight"]   = PresetMidnight,
    ["midnight"]   = PresetMidnight,
    ["Neon"]       = PresetNeon,
    ["neon"]       = PresetNeon,
    ["PearlWhite"] = PresetPearlWhite,
    ["pearlwhite"] = PresetPearlWhite,
    ["Pearl"]      = PresetPearlWhite,
    ["pearl"]      = PresetPearlWhite,
    ["Light"]      = PresetPearlWhite,
    ["light"]      = PresetPearlWhite,
    ["AMOLED"]     = PresetAMOLED,
    ["amoled"]     = PresetAMOLED,
    ["Amoled"]     = PresetAMOLED,
}

-- ============================================================
-- INTERNAL STATE
-- ============================================================
local ThemeManager   = {}
local _activeTheme   = Table.DeepCopy(PresetDefault)
local _subscribers   = {}
local _nextSubId     = 0

-- ============================================================
-- INTERNAL HELPERS
-- ============================================================

local function GenerateSubId()
    _nextSubId = _nextSubId + 1
    return "sub_" .. _nextSubId
end

--[[
  Merge a partial override table onto the active theme.
  Only overrides keys present in the override table.
  All other tokens remain from the base preset.
]]
local function ApplyOverrides(base, overrides)
    local result = Table.ShallowCopy(base)
    for k, v in pairs(overrides) do
        -- Skip internal metadata keys
        if not k:sub(1,1) == "_" then
            result[k] = v
        else
            result[k] = v
        end
    end
    return result
end

--[[
  Notify all subscribers that the theme has changed.
  Passes the full resolved token map.
]]
local function NotifySubscribers()
    -- Notify via EventBus (for components using EventBus.On)
    EventBus.Fire(EventBus.Events.THEME_CHANGED, _activeTheme)

    -- Also call direct subscribers (for components that
    -- subscribed via ThemeManager.Subscribe directly)
    for _, sub in pairs(_subscribers) do
        local ok, err = pcall(sub, _activeTheme)
        if not ok then
            warn("[LuxwareUI ThemeManager] Subscriber error: " .. tostring(err))
        end
    end
end

-- ============================================================
-- PUBLIC API
-- ============================================================

--[[
  Set the active theme.
  Accepts either a preset name string or a partial
  override table merged on top of current theme.

  @param nameOrTable  string|table
    string: preset name e.g. "AMOLED", "PearlWhite"
    table:  partial semantic token overrides
]]
function ThemeManager.SetTheme(nameOrTable)
    if type(nameOrTable) == "string" then
        -- Load named preset
        local preset = PRESETS[nameOrTable]
        if not preset then
            warn("[LuxwareUI ThemeManager] Unknown preset: '" .. nameOrTable .. "'. Using Default.")
            preset = PresetDefault
        end
        _activeTheme = Table.DeepCopy(preset)

    elseif type(nameOrTable) == "table" then
        -- Apply partial overrides onto current theme
        _activeTheme = ApplyOverrides(_activeTheme, nameOrTable)

    else
        warn("[LuxwareUI ThemeManager] SetTheme expects string or table.")
        return
    end

    NotifySubscribers()
end

--[[
  Resolve a semantic token key to its concrete value.
  Returns nil if key not found — components should
  have fallback values for this case.

  @param key  string  Semantic token name e.g. "Accent"
  @return     any     Resolved value (Color3, number, etc.)
]]
function ThemeManager.Resolve(key)
    local value = _activeTheme[key]
    if value == nil then
        warn("[LuxwareUI ThemeManager] Unknown token: '" .. key .. "'")
    end
    return value
end

--[[
  Get the full resolved token map.
  Returns a copy — modifying it does not affect the theme.

  @return  table
]]
function ThemeManager.GetAll()
    return Table.ShallowCopy(_activeTheme)
end

--[[
  Subscribe to theme change events.
  Handler is called immediately with current theme,
  then again on every subsequent theme change.

  @param handler  function  Called with (tokenMap)
  @return         string    Subscriber ID for unsubscribing
]]
function ThemeManager.Subscribe(handler)
    assert(type(handler) == "function", "ThemeManager.Subscribe: handler must be a function")

    local id = GenerateSubId()
    _subscribers[id] = handler

    -- Call immediately with current theme
    local ok, err = pcall(handler, _activeTheme)
    if not ok then
        warn("[LuxwareUI ThemeManager] Initial subscribe call error: " .. tostring(err))
    end

    return id
end

--[[
  Unsubscribe from theme change events.

  @param subscriberId  string  ID returned by Subscribe()
]]
function ThemeManager.Unsubscribe(subscriberId)
    _subscribers[subscriberId] = nil
end

--[[
  Get the name of the currently active theme.

  @return  string
]]
function ThemeManager.GetName()
    return _activeTheme._name or "Unknown"
end

--[[
  Returns true if the current theme is dark.

  @return  boolean
]]
function ThemeManager.IsDark()
    return _activeTheme._isDark == true
end

--[[
  Get a list of all available preset names.

  @return  {string}
]]
function ThemeManager.GetPresets()
    local seen   = {}
    local result = {}
    for _, preset in pairs(PRESETS) do
        local name = preset._name
        if name and not seen[name] then
            seen[name] = true
            table.insert(result, name)
        end
    end
    return result
end

--[[
  Reset to the default theme.
]]
function ThemeManager.Reset()
    ThemeManager.SetTheme("Default")
end

--[[
  Clear all direct subscribers.
  Called on library destroy.
]]
function ThemeManager.ClearSubscribers()
    _subscribers = {}
    _nextSubId   = 0
end

-- ============================================================
-- CONVENIENCE SHORTHAND
-- ThemeManager.T("Accent") is faster to type than Resolve
-- ============================================================
ThemeManager.T = ThemeManager.Resolve

return ThemeManager
