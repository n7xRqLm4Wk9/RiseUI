--[[
  File: Easing.lua
  Layer: Animation
  Responsibility: Custom easing curve definitions
  not available in Roblox's Enum.EasingStyle.
  Pure math functions — no Roblox services.
  Used by Animator for non-tween interpolation
  such as manual spring physics and value lerping.
  Dependencies: none
  Public API: Easing.Linear, Easing.QuartOut,
  Easing.BackOut, Easing.ElasticOut,
  Easing.BounceOut, Easing.Spring
]]

local Easing = {}

-- ============================================================
-- STANDARD CURVES
-- All functions take t (0-1) and return a value (0-1)
-- ============================================================

function Easing.Linear(t)
    return t
end

-- Quad
function Easing.QuadIn(t)
    return t * t
end

function Easing.QuadOut(t)
    return t * (2 - t)
end

function Easing.QuadInOut(t)
    if t < 0.5 then return 2 * t * t end
    return -1 + (4 - 2 * t) * t
end

-- Quart
function Easing.QuartIn(t)
    return t * t * t * t
end

function Easing.QuartOut(t)
    t = t - 1
    return 1 - t * t * t * t
end

function Easing.QuartInOut(t)
    if t < 0.5 then return 8 * t * t * t * t end
    t = t - 1
    return 1 - 8 * t * t * t * t
end

-- Quint
function Easing.QuintOut(t)
    t = t - 1
    return 1 + t * t * t * t * t
end

-- Expo
function Easing.ExpoOut(t)
    if t == 1 then return 1 end
    return 1 - math.pow(2, -10 * t)
end

function Easing.ExpoIn(t)
    if t == 0 then return 0 end
    return math.pow(2, 10 * (t - 1))
end

-- Sine
function Easing.SineOut(t)
    return math.sin(t * math.pi / 2)
end

function Easing.SineIn(t)
    return 1 - math.cos(t * math.pi / 2)
end

function Easing.SineInOut(t)
    return -(math.cos(math.pi * t) - 1) / 2
end

-- ============================================================
-- SPRING & BACK CURVES
-- These overshoot and settle — used for UI entrances
-- ============================================================

-- Back out — slight overshoot then settle
-- c1 controls overshoot amount (1.70158 = default)
function Easing.BackOut(t, c1)
    c1 = c1 or 1.70158
    local c3 = c1 + 1
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
end

function Easing.BackIn(t, c1)
    c1 = c1 or 1.70158
    local c3 = c1 + 1
    return c3 * t * t * t - c1 * t * t
end

function Easing.BackInOut(t, c1)
    c1 = c1 or 1.70158
    local c2 = c1 * 1.525
    if t < 0.5 then
        return (math.pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2)) / 2
    else
        return (math.pow(2 * t - 2, 2) * ((c2 + 1) * (2 * t - 2) + c2) + 2) / 2
    end
end

-- Elastic out — bouncy spring feel
-- amplitude and period control the spring character
function Easing.ElasticOut(t, amplitude, period)
    amplitude = amplitude or 1
    period    = period    or 0.3
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    local s = period / (2 * math.pi) * math.asin(1 / amplitude)
    return amplitude * math.pow(2, -10 * t)
        * math.sin((t - s) * (2 * math.pi) / period) + 1
end

function Easing.ElasticIn(t, amplitude, period)
    amplitude = amplitude or 1
    period    = period    or 0.3
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    local s = period / (2 * math.pi) * math.asin(1 / amplitude)
    return -(amplitude * math.pow(2, 10 * (t - 1))
        * math.sin((t - 1 - s) * (2 * math.pi) / period))
end

-- ============================================================
-- BOUNCE
-- ============================================================

function Easing.BounceOut(t)
    local n1 = 7.5625
    local d1 = 2.75
    if t < 1 / d1 then
        return n1 * t * t
    elseif t < 2 / d1 then
        t = t - 1.5 / d1
        return n1 * t * t + 0.75
    elseif t < 2.5 / d1 then
        t = t - 2.25 / d1
        return n1 * t * t + 0.9375
    else
        t = t - 2.625 / d1
        return n1 * t * t + 0.984375
    end
end

function Easing.BounceIn(t)
    return 1 - Easing.BounceOut(1 - t)
end

-- ============================================================
-- SPRING PHYSICS SIMULATION
-- More realistic spring than Back easing
-- ============================================================

--[[
  Simulate a damped spring.

  @param t        number  Progress 0-1
  @param stiffness number  Spring stiffness (default 200)
  @param damping   number  Damping coefficient (default 20)
  @return          number  Spring value (may overshoot 1)
]]
function Easing.Spring(t, stiffness, damping)
    stiffness = stiffness or 200
    damping   = damping   or 20

    local omega = math.sqrt(stiffness)
    local zeta  = damping / (2 * omega)

    if zeta < 1 then
        -- Underdamped (oscillates)
        local omegaD = omega * math.sqrt(1 - zeta * zeta)
        return 1 - math.exp(-zeta * omega * t)
            * (math.cos(omegaD * t) + (zeta * omega / omegaD) * math.sin(omegaD * t))
    else
        -- Overdamped (no oscillation)
        return 1 - math.exp(-omega * t) * (1 + omega * t)
    end
end

-- ============================================================
-- SMOOTH STEP VARIANTS
-- ============================================================

function Easing.SmoothStep(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end

function Easing.SmootherStep(t)
    t = math.clamp(t, 0, 1)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

-- ============================================================
-- UTILITY
-- ============================================================

--[[
  Reverse any easing function.
  e.g. Easing.Reverse(Easing.QuartOut)(t) gives QuartIn behavior

  @param fn  function  Easing function to reverse
  @return    function
]]
function Easing.Reverse(fn)
    return function(t, ...)
        return 1 - fn(1 - t, ...)
    end
end

--[[
  Mirror an easing: in for first half, out for second half.

  @param fnIn   function
  @param fnOut  function
  @return       function
]]
function Easing.Mirror(fnIn, fnOut)
    fnOut = fnOut or fnIn
    return function(t, ...)
        if t < 0.5 then
            return fnIn(t * 2, ...) / 2
        else
            return 1 - fnOut((1 - t) * 2, ...) / 2
        end
    end
end

return Easing
