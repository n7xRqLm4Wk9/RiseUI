--[[
  File: Animator.lua
  Layer: Animation
  Responsibility: Centralized tween and spring
  factory. All components use this instead of
  calling TweenService directly. Caches active
  tweens per instance+property and cancels stale
  ones before creating new tweens — preventing
  accumulation on rapidly updated elements.
  Dependencies: animation/Transitions.lua
  Public API: Animator.Tween, Animator.Play,
  Animator.Cancel, Animator.CancelInstance,
  Animator.Shake, Animator.Pulse, Animator.FadeIn,
  Animator.FadeOut, Animator.SlideIn
]]

local TweenService  = game:GetService("TweenService")
local Transitions   = require(script.Parent.Transitions)
local Animator      = {}

-- ============================================================
-- TWEEN CACHE
-- { [instance]: { [propertyKey]: Tween } }
-- Weak keys so destroyed instances get GC'd
-- ============================================================
local _cache = setmetatable({}, { __mode = "k" })

-- ============================================================
-- INTERNAL HELPERS
-- ============================================================

local function GetCacheKey(properties)
    local keys = {}
    for k in pairs(properties) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return table.concat(keys, "_")
end

local function CancelCached(instance, cacheKey)
    if not _cache[instance] then return end
    local tween = _cache[instance][cacheKey]
    if tween then
        tween:Cancel()
        _cache[instance][cacheKey] = nil
    end
end

local function CacheTween(instance, cacheKey, tween)
    if not _cache[instance] then
        _cache[instance] = {}
    end
    _cache[instance][cacheKey] = tween
end

-- ============================================================
-- CORE TWEEN FACTORY
-- ============================================================

--[[
  Create and play a tween on an instance.
  Automatically cancels any existing tween on
  the same instance+properties before playing.

  @param instance    Instance     Target Roblox instance
  @param tweenInfo   TweenInfo    Animation parameters
  @param properties  table        Property name → target value
  @param onComplete  function?    Called when tween completes
  @return            Tween
]]
function Animator.Tween(instance, tweenInfo, properties, onComplete)
    if not instance or not instance.Parent then return end

    local cacheKey = GetCacheKey(properties)

    -- Cancel existing tween for these properties
    CancelCached(instance, cacheKey)

    -- Create new tween
    local tween = TweenService:Create(instance, tweenInfo, properties)

    -- Cache it
    CacheTween(instance, cacheKey, tween)

    -- Completion handler
    if onComplete then
        tween.Completed:Once(function(state)
            if state == Enum.PlaybackState.Completed then
                onComplete()
            end
        end)
    end

    -- Auto-remove from cache when done
    tween.Completed:Once(function()
        if _cache[instance] then
            _cache[instance][cacheKey] = nil
        end
    end)

    tween:Play()
    return tween
end

--[[
  Play a named transition preset on an instance.
  Shorthand for Animator.Tween with a preset name.

  @param instance    Instance
  @param presetName  string     Name from Transitions.lua
  @param properties  table
  @param onComplete  function?
  @return            Tween
]]
function Animator.Play(instance, presetName, properties, onComplete)
    local info = Transitions.Get(presetName)
    return Animator.Tween(instance, info, properties, onComplete)
end

--[[
  Cancel all active tweens on an instance.

  @param instance  Instance
]]
function Animator.CancelInstance(instance)
    if not _cache[instance] then return end
    for _, tween in pairs(_cache[instance]) do
        pcall(function() tween:Cancel() end)
    end
    _cache[instance] = nil
end

--[[
  Cancel a specific tween on an instance by property set.

  @param instance    Instance
  @param properties  table  Same properties table used in Tween()
]]
function Animator.Cancel(instance, properties)
    if not properties then
        Animator.CancelInstance(instance)
        return
    end
    local cacheKey = GetCacheKey(properties)
    CancelCached(instance, cacheKey)
end

-- ============================================================
-- COMPOUND ANIMATIONS
-- Higher-level animations built from basic tweens
-- ============================================================

--[[
  Shake an instance horizontally.
  Used for wrong key entry, invalid input.

  @param instance   Instance   Frame to shake
  @param intensity  number?    Pixel offset (default 8)
  @param count      number?    Shake repetitions (default 3)
]]
function Animator.Shake(instance, intensity, count)
    intensity = intensity or 8
    count     = count     or 3

    local originalPos = instance.Position
    local shakeInfo   = Transitions.Get("KeySystemShake")

    local function DoShake(i, direction)
        if i > count * 2 then
            -- Return to original position
            Animator.Tween(instance, Transitions.Get("Fast"), {
                Position = originalPos
            })
            return
        end
        local offset = (i % 2 == 0) and intensity or -intensity
        Animator.Tween(instance, shakeInfo, {
            Position = UDim2.new(
                originalPos.X.Scale,
                originalPos.X.Offset + offset,
                originalPos.Y.Scale,
                originalPos.Y.Offset
            )
        }, function()
            DoShake(i + 1, -direction)
        end)
    end

    DoShake(1, 1)
end

--[[
  Pulse an instance's background color to accent and back.
  Used for button press feedback.

  @param instance      Instance
  @param accentColor   Color3
  @param originalColor Color3
]]
function Animator.Pulse(instance, accentColor, originalColor)
    Animator.Tween(instance, Transitions.Get("Press"), {
        BackgroundColor3 = accentColor
    }, function()
        Animator.Tween(instance, Transitions.Get("Release"), {
            BackgroundColor3 = originalColor
        })
    end)
end

--[[
  Fade an instance in from fully transparent.

  @param instance     Instance
  @param targetAlpha  number?    Target transparency (default 0)
  @param presetName   string?    Transition preset (default "Default")
  @param onComplete   function?
]]
function Animator.FadeIn(instance, targetAlpha, presetName, onComplete)
    targetAlpha = targetAlpha or 0
    local info  = Transitions.Get(presetName or "Default")

    -- Determine correct property
    local prop
    if instance:IsA("Frame") or instance:IsA("ImageLabel") or instance:IsA("TextLabel") then
        prop = "BackgroundTransparency"
    elseif instance:IsA("TextButton") then
        prop = "BackgroundTransparency"
    end

    if prop then
        Animator.Tween(instance, info, { [prop] = targetAlpha }, onComplete)
    end
end

--[[
  Fade an instance out to fully transparent.

  @param instance   Instance
  @param presetName string?   Transition preset
  @param onComplete function?
]]
function Animator.FadeOut(instance, presetName, onComplete)
    local info = Transitions.Get(presetName or "Default")
    local prop

    if instance:IsA("Frame") or instance:IsA("ImageLabel")
    or instance:IsA("TextLabel") or instance:IsA("TextButton") then
        prop = "BackgroundTransparency"
    end

    if prop then
        Animator.Tween(instance, info, { [prop] = 1 }, onComplete)
    end
end

--[[
  Slide an instance in from a direction.

  @param instance   Instance
  @param direction  string     "left"|"right"|"top"|"bottom"
  @param distance   number?    Pixels to slide from (default 20)
  @param presetName string?
  @param onComplete function?
]]
function Animator.SlideIn(instance, direction, distance, presetName, onComplete)
    distance  = distance  or 20
    presetName = presetName or "WindowEnter"
    local info = Transitions.Get(presetName)
    local pos  = instance.Position

    local startPos
    if direction == "left" then
        startPos = UDim2.new(pos.X.Scale, pos.X.Offset - distance, pos.Y.Scale, pos.Y.Offset)
    elseif direction == "right" then
        startPos = UDim2.new(pos.X.Scale, pos.X.Offset + distance, pos.Y.Scale, pos.Y.Offset)
    elseif direction == "top" then
        startPos = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset - distance)
    else -- bottom
        startPos = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + distance)
    end

    instance.Position = startPos
    Animator.Tween(instance, info, { Position = pos }, onComplete)
end

--[[
  Scale an instance in from zero size.
  Used for dialog and key system entrance.

  @param instance    Instance
  @param targetSize  UDim2     Final size
  @param presetName  string?
  @param onComplete  function?
]]
function Animator.ScaleIn(instance, targetSize, presetName, onComplete)
    presetName = presetName or "DialogEnter"
    local info = Transitions.Get(presetName)

    local center = instance.AnchorPoint
    instance.Size = UDim2.new(
        targetSize.X.Scale, 0,
        targetSize.Y.Scale, 0
    )
    Animator.Tween(instance, info, { Size = targetSize }, onComplete)
end

--[[
  Rotate a chevron/arrow icon.
  Used for dropdown and panel open/close.

  @param instance    Instance
  @param degrees     number    Target rotation (0=closed, 180=open)
  @param presetName  string?
]]
function Animator.Rotate(instance, degrees, presetName)
    local info = Transitions.Get(presetName or "Fast")
    Animator.Tween(instance, info, { Rotation = degrees })
end

-- ============================================================
-- HOVER HELPERS
-- Convenience wrappers for the most common hover pattern
-- ============================================================

--[[
  Wire up hover color change on a button/frame.

  @param instance     Instance
  @param normalColor  Color3
  @param hoverColor   Color3
  @return             { disconnect: function }  Call to remove listeners
]]
function Animator.HoverColor(instance, normalColor, hoverColor)
    local conn1 = instance.MouseEnter:Connect(function()
        Animator.Play(instance, "Hover", { BackgroundColor3 = hoverColor })
    end)
    local conn2 = instance.MouseLeave:Connect(function()
        Animator.Play(instance, "HoverOut", { BackgroundColor3 = normalColor })
    end)
    return {
        disconnect = function()
            conn1:Disconnect()
            conn2:Disconnect()
        end
    }
end

--[[
  Get count of cached tweens.
  Useful for debugging memory usage.

  @return  number
]]
function Animator.CacheSize()
    local count = 0
    for _, instanceCache in pairs(_cache) do
        for _ in pairs(instanceCache) do
            count = count + 1
        end
    end
    return count
end

return Animator
