--[[
  File: PearlWhite.lua
  Layer: Theme/Presets
  Responsibility: Pearl White light theme preset.
  Based directly on the Pearl White UI screenshot.
  Clean minimal light theme for daytime use.
  Dependencies: theme/tokens/light.lua
  Public API: returns preset table
]]

local Light = require(script.Parent.Parent.tokens.light)

local PearlWhite = {}
for k, v in pairs(Light) do
    PearlWhite[k] = v
end

PearlWhite._name       = "PearlWhite"
PearlWhite._presetBase = "light"

return PearlWhite
