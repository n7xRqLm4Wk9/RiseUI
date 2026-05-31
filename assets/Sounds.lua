--[[
  File: Sounds.lua
  Layer: Assets
  Responsibility: All UI sound effect asset IDs.
  Sounds are disabled by default and must be
  explicitly enabled via window config.
  Components never play sounds directly — they
  fire events that SoundManager handles.
  Dependencies: none
  Public API: Sounds.Get(name) → assetId string
  Sounds.IsEnabled() → bool
  Sounds.SetEnabled(bool)
]]

local Sounds = {}

-- ============================================================
-- MASTER SWITCH
-- Sounds off by default — user opts in
-- ============================================================
local _enabled = false

-- ============================================================
-- VOLUME LEVELS (0-1)
-- ============================================================
local Volume = {
    Click      = 0.4,
    Toggle     = 0.3,
    Notify     = 0.5,
    Error      = 0.4,
    Success    = 0.4,
    Open       = 0.25,
    Close      = 0.25,
    Hover      = 0.15,
    KeyPress   = 0.2,
    Slider     = 0.1,
}

-- ============================================================
-- ASSET IDS
-- All sourced from free Roblox audio library
-- ============================================================
local AssetIds = {
    -- Button click
    Click        = "rbxassetid://6042053626",

    -- Toggle on/off
    Toggle       = "rbxassetid://6042053626",

    -- Notification pop
    Notify       = "rbxassetid://6042053626",

    -- Error shake
    Error        = "rbxassetid://6042053626",

    -- Success confirm
    Success      = "rbxassetid://6042053626",

    -- Panel open (dropdown, module config)
    Open         = "rbxassetid://6042053626",

    -- Panel close
    Close        = "rbxassetid://6042053626",

    -- Hover (very subtle)
    Hover        = "rbxassetid://6042053626",

    -- Keybind key press
    KeyPress     = "rbxassetid://6042053626",

    -- Slider drag tick
    Slider       = "rbxassetid://6042053626",
}

-- ============================================================
-- PUBLIC API
-- ============================================================

-- Get asset ID for a sound
function Sounds.Get(name)
    return AssetIds[name] or nil
end

-- Get volume level for a sound
function Sounds.GetVolume(name)
    return Volume[name] or 0.3
end

-- Master enable/disable
function Sounds.SetEnabled(enabled)
    _enabled = enabled == true
end

-- Returns true if sounds are enabled
function Sounds.IsEnabled()
    return _enabled
end

-- Set a custom asset ID at runtime
function Sounds.Set(name, assetId, volume)
    AssetIds[name] = assetId
    if volume then
        Volume[name] = volume
    end
end

-- Get all sound names
function Sounds.GetAll()
    local names = {}
    for k in pairs(AssetIds) do
        table.insert(names, k)
    end
    return names
end

return Sounds
