--[[
  File: Color.lua
  Layer: Utils
  Responsibility: All color manipulation, 
  conversion, and analysis functions.
  Dependencies: none
  Public API: Color.HSVtoRGB, Color.RGBtoHSV,
  Color.HexToColor3, Color.Color3ToHex,
  Color.Lerp, Color.Darken, Color.Lighten,
  Color.ContrastRatio, Color.IsDark
]]

local Color = {}

-- HSV (0-1 each) → Color3
function Color.HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if     i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    return Color3.new(r, g, b)
end

-- Color3 → HSV (0-1 each)
function Color.RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local d   = max - min
    local h, s, v = 0, 0, max
    if max ~= 0 then
        s = d / max
    end
    if d ~= 0 then
        if max == r then
            h = (g - b) / d % 6
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, v
end

-- "#RRGGBB" or "RRGGBB" → Color3
function Color.HexToColor3(hex)
    hex = hex:gsub("#", "")
    if #hex ~= 6 then
        return Color3.new(1, 1, 1)
    end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if not r or not g or not b then
        return Color3.new(1, 1, 1)
    end
    return Color3.fromRGB(r, g, b)
end

-- Color3 → "#RRGGBB"
function Color.Color3ToHex(color)
    return string.format(
        "#%02X%02X%02X",
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

-- Linearly interpolate between two Color3s
-- t: 0 → a, 1 → b
function Color.Lerp(a, b, t)
    t = math.clamp(t, 0, 1)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

-- Darken a Color3 by a factor (0-1)
-- factor 0.2 = 20% darker
function Color.Darken(color, factor)
    factor = math.clamp(factor, 0, 1)
    local h, s, v = Color.RGBtoHSV(color)
    v = math.clamp(v - v * factor, 0, 1)
    return Color.HSVtoRGB(h, s, v)
end

-- Lighten a Color3 by a factor (0-1)
-- factor 0.2 = 20% lighter
function Color.Lighten(color, factor)
    factor = math.clamp(factor, 0, 1)
    local h, s, v = Color.RGBtoHSV(color)
    v = math.clamp(v + (1 - v) * factor, 0, 1)
    return Color.HSVtoRGB(h, s, v)
end

-- Relative luminance of a Color3 (WCAG formula)
local function Luminance(color)
    local function Channel(c)
        if c <= 0.03928 then
            return c / 12.92
        else
            return ((c + 0.055) / 1.055) ^ 2.4
        end
    end
    return 0.2126 * Channel(color.R)
         + 0.7152 * Channel(color.G)
         + 0.0722 * Channel(color.B)
end

-- Contrast ratio between two Color3s (WCAG)
-- Returns value between 1 and 21
-- 4.5+ passes AA, 7+ passes AAA
function Color.ContrastRatio(a, b)
    local la = Luminance(a)
    local lb = Luminance(b)
    local lighter = math.max(la, lb)
    local darker  = math.min(la, lb)
    return (lighter + 0.05) / (darker + 0.05)
end

-- Returns true if a color is perceptually dark
-- Useful for deciding text color on a background
function Color.IsDark(color)
    return Luminance(color) < 0.179
end

-- Blend two Color3s using normal blend mode
-- alpha: 0 = fully a, 1 = fully b
function Color.Blend(a, b, alpha)
    return Color.Lerp(a, b, alpha)
end

-- Desaturate a Color3 by factor (0-1)
function Color.Desaturate(color, factor)
    factor = math.clamp(factor, 0, 1)
    local h, s, v = Color.RGBtoHSV(color)
    s = math.clamp(s - s * factor, 0, 1)
    return Color.HSVtoRGB(h, s, v)
end

-- Clamp each channel of a Color3 to valid range
function Color.Clamp(color)
    return Color3.new(
        math.clamp(color.R, 0, 1),
        math.clamp(color.G, 0, 1),
        math.clamp(color.B, 0, 1)
    )
end

return Color
