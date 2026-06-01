--[[
  File: Neon.lua
  Layer: Theme/Presets
  Responsibility: High-contrast neon cyan preset.
  Bright cyan/teal accent on pure dark backgrounds.
  High energy feel for action-oriented scripts.
  Dependencies: theme/tokens/dark.lua
  Public API: returns preset table
]]

local Dark = require(script.Parent.Parent.tokens.dark)

-- Start from dark base
local Neon = {}
for k, v in pairs(Dark) do
    Neon[k] = v
end

-- Override to neon cyan
Neon._name        = "Neon"
Neon._presetBase  = "dark"

Neon.Accent       = Color3.fromRGB( 0, 220, 200)
Neon.AccentLight  = Color3.fromRGB(60, 240, 220)
Neon.AccentDim    = Color3.fromRGB( 0, 140, 128)
Neon.AccentBg     = Color3.fromRGB( 0,  25,  22)
Neon.AccentText   = Color3.fromRGB(180, 255, 250)

-- Pure dark backgrounds, slightly cooler
Neon.Background   = Color3.fromRGB(10,  12,  12)
Neon.Surface      = Color3.fromRGB(14,  18,  18)
Neon.SurfaceLight = Color3.fromRGB(20,  26,  26)
Neon.SurfaceHover = Color3.fromRGB(26,  34,  34)
Neon.Border       = Color3.fromRGB(30,  50,  48)
Neon.BorderLight  = Color3.fromRGB(22,  38,  36)
Neon.BorderGlow   = Color3.fromRGB( 0, 120, 110)

-- Update component colors
Neon.ToggleOn           = Color3.fromRGB( 0, 220, 200)
Neon.SliderFill         = Color3.fromRGB( 0, 220, 200)
Neon.SliderThumbBorder  = Color3.fromRGB( 0, 220, 200)
Neon.TabIndicator       = Color3.fromRGB( 0, 220, 200)
Neon.InputBorderFocus   = Color3.fromRGB( 0, 220, 200)
Neon.BorderFocus        = Color3.fromRGB( 0, 220, 200)
Neon.ScrollBar          = Color3.fromRGB( 0, 160, 145)
Neon.TextAccent         = Color3.fromRGB(100, 240, 228)
Neon.DropdownSelected   = Color3.fromRGB( 0,  25,  22)
Neon.DropdownSelectedText = Color3.fromRGB(100, 240, 228)

-- Neon glow feel — more vibrant status colors
Neon.Success      = Color3.fromRGB( 80, 240, 160)
Neon.Error        = Color3.fromRGB(255,  80, 100)
Neon.Warning      = Color3.fromRGB(255, 220,  50)

return Neon
