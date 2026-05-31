--[[
  File: Math.lua
  Layer: Utils
  Responsibility: Pure math utility functions
  used across all components and animations.
  Dependencies: none
  Public API: Math.Clamp, Math.Remap,
  Math.RoundToIncrement, Math.Lerp,
  Math.IsNaN, Math.Sign, Math.Percentage,
  Math.InverseLerp, Math.SmoothStep
]]

local Math = {}

-- Clamp value between min and max
function Math.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Remap value from one range to another
-- e.g. Remap(0.5, 0, 1, 0, 100) → 50
function Math.Remap(value, inMin, inMax, outMin, outMax)
    if inMax == inMin then return outMin end
    local t = (value - inMin) / (inMax - inMin)
    return outMin + t * (outMax - outMin)
end

-- Round a value to the nearest increment
-- e.g. RoundToIncrement(13, 5) → 15
function Math.RoundToIncrement(value, increment)
    if increment == 0 then return value end
    return math.round(value / increment) * increment
end

-- Linear interpolation
-- t: 0 → a, 1 → b
function Math.Lerp(a, b, t)
    return a + (b - a) * Math.Clamp(t, 0, 1)
end

-- Inverse linear interpolation
-- Returns t such that Lerp(a, b, t) == value
function Math.InverseLerp(a, b, value)
    if b == a then return 0 end
    return Math.Clamp((value - a) / (b - a), 0, 1)
end

-- Smooth step interpolation (smoother than lerp)
function Math.SmoothStep(a, b, t)
    t = Math.Clamp((t - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)
end

-- Returns true if value is NaN
function Math.IsNaN(value)
    return value ~= value
end

-- Returns sign of a number: -1, 0, or 1
function Math.Sign(value)
    if value > 0 then return 1
    elseif value < 0 then return -1
    else return 0
    end
end

-- Convert a value to a percentage string
-- e.g. Percentage(0.75) → "75%"
function Math.Percentage(value, decimals)
    decimals = decimals or 0
    local fmt = "%." .. decimals .. "f%%"
    return string.format(fmt, value * 100)
end

-- Map a slider value to a 0-1 progress
-- accounting for min/max/increment
function Math.SliderProgress(value, min, max)
    return Math.InverseLerp(min, max, value)
end

-- Snap a UDim2 position to a pixel grid
function Math.SnapToPixel(udim2)
    return UDim2.new(
        udim2.X.Scale,
        math.round(udim2.X.Offset),
        udim2.Y.Scale,
        math.round(udim2.Y.Offset)
    )
end

-- Distance between two Vector2 points
function Math.Distance(a, b)
    return (b - a).Magnitude
end

-- Returns true if value is within range (inclusive)
function Math.InRange(value, min, max)
    return value >= min and value <= max
end

return Math
