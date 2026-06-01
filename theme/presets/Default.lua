--[[
  File: Default.lua
  Layer: Theme/Presets
  Responsibility: Default LuxwareUI preset.
  Uses the dark token set as-is with no overrides.
  This is what loads when no theme is specified.
  Dependencies: theme/tokens/dark.lua
  Public API: returns preset table
]]

local Dark = require(script.Parent.Parent.tokens.dark)

-- Default preset is just the dark theme
-- No overrides needed
local Default = {}
for k, v in pairs(Dark) do
    Default[k] = v
end

Default._name        = "Default"
Default._presetBase  = "dark"

return Default
