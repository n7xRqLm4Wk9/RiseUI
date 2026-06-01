--[[
  File: Midnight.lua
  Layer: Theme/Presets
  Responsibility: Midnight blue preset.
  Deep navy accent replacing violet.
  Slightly warmer dark backgrounds.
  Dependencies: theme/tokens/dark.lua
  Public API: returns preset table
]]

local Dark = require(script.Parent.Parent.tokens.dark)
local Base = require(script.Parent.Parent.tokens.base)
local P    = Base.Palette

-- Start from dark base
local Midnight = {}
for k, v in pairs(Dark) do
    Midnight[k] = v
end

-- Override accent family to deep blue
Midnight._name        = "Midnight"
Midnight._presetBase  = "dark"

Midnight.Accent       = Color3.fromRGB(60,  120, 255)
Midnight.AccentLight  = Color3.fromRGB(90,  150, 255)
Midnight.AccentDim    = Color3.fromRGB(30,   70, 180)
Midnight.AccentBg     = Color3.fromRGB( 8,   15,  40)
Midnight.AccentText   = Color3.fromRGB(180, 210, 255)

-- Slightly warmer/bluer backgrounds
Midnight.Background   = Color3.fromRGB(10,  12,  20)
Midnight.Surface      = Color3.fromRGB(14,  17,  28)
Midnight.SurfaceLight = Color3.fromRGB(20,  24,  38)
Midnight.SurfaceHover = Color3.fromRGB(26,  30,  48)
Midnight.Border       = Color3.fromRGB(35,  42,  70)
Midnight.BorderLight  = Color3.fromRGB(28,  34,  58)
Midnight.BorderGlow   = Color3.fromRGB(40,  80, 180)

-- Update component colors to match
Midnight.ToggleOn           = Color3.fromRGB(60,  120, 255)
Midnight.SliderFill         = Color3.fromRGB(60,  120, 255)
Midnight.SliderThumbBorder  = Color3.fromRGB(60,  120, 255)
Midnight.TabIndicator       = Color3.fromRGB(60,  120, 255)
Midnight.InputBorderFocus   = Color3.fromRGB(60,  120, 255)
Midnight.BorderFocus        = Color3.fromRGB(60,  120, 255)
Midnight.ScrollBar          = Color3.fromRGB(40,   90, 200)
Midnight.TextAccent         = Color3.fromRGB(120, 175, 255)
Midnight.DropdownSelected   = Color3.fromRGB( 8,   15,  40)
Midnight.DropdownSelectedText = Color3.fromRGB(120, 175, 255)

return Midnight
