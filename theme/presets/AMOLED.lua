--[[
  File: AMOLED.lua
  Layer: Theme/Presets
  Responsibility: Pure AMOLED black preset.
  Based directly on the AMOLED UI screenshot.
  Maximum battery savings on OLED displays.
  Dependencies: theme/tokens/amoled.lua
  Public API: returns preset table
]]

local Amoled = require(script.Parent.Parent.tokens.amoled)

local AMOLED = {}
for k, v in pairs(Amoled) do
    AMOLED[k] = v
end

AMOLED._name       = "AMOLED"
AMOLED._presetBase = "amoled"

return AMOLED
