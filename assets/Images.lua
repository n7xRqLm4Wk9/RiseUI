--[[
  File: Images.lua
  Layer: Assets
  Responsibility: All non-icon image asset IDs
  used for UI chrome — gradients, glows, noise
  textures, color picker canvases, and decorative
  elements. Nothing visual is hardcoded outside
  this file.
  Dependencies: none
  Public API: Images.Get(name) → assetId string
]]

local Images = {}

-- ============================================================
-- ROBLOX ASSET IDS
-- These are stock Roblox assets that are always available
-- No upload required for these
-- ============================================================
local AssetIds = {

    -- --------------------------------------------------------
    -- COLOR PICKER
    -- Used inside ColorPicker widget
    -- --------------------------------------------------------

    -- Saturation/Value canvas (white to color gradient)
    ColorPickerSV      = "rbxassetid://4155801252",

    -- Hue bar gradient (full spectrum)
    -- We generate this via UIGradient in code, no asset needed
    ColorPickerHue     = nil,

    -- --------------------------------------------------------
    -- GRADIENTS & GLOWS
    -- Used for window glow effects and backgrounds
    -- --------------------------------------------------------

    -- Radial gradient (for glow behind accent elements)
    RadialGlow         = "rbxassetid://4996891970",

    -- Soft vignette overlay
    Vignette           = "rbxassetid://1513441309",

    -- Horizontal gradient (for sidebar fade)
    GradientHorizontal = "rbxassetid://2454009026",

    -- Vertical gradient (for scroll fade)
    GradientVertical   = "rbxassetid://2454009026",

    -- --------------------------------------------------------
    -- NOISE & TEXTURE
    -- Used for subtle surface texture on premium feel
    -- --------------------------------------------------------

    -- Fine noise texture (very low opacity overlay)
    Noise              = "rbxassetid://6880375671",

    -- --------------------------------------------------------
    -- WINDOW CHROME
    -- Decorative elements
    -- --------------------------------------------------------

    -- Rounded rectangle mask (for clipping)
    RoundMask          = "rbxassetid://5028857084",

    -- Drop shadow (used behind window frame)
    DropShadow         = "rbxassetid://1316045217",

    -- --------------------------------------------------------
    -- KEY SYSTEM
    -- --------------------------------------------------------

    -- Key icon for key system overlay
    KeyIcon            = "rbxassetid://6031094689",

    -- --------------------------------------------------------
    -- NOTIFICATION
    -- --------------------------------------------------------

    -- Checkmark for success notification
    NotifSuccess       = "rbxassetid://6035047391",

    -- X for error notification
    NotifError         = "rbxassetid://6031302495",

    -- Info circle for info notification
    NotifInfo          = "rbxassetid://6035047018",

    -- Warning triangle for warning notification
    NotifWarning       = "rbxassetid://6031068421",
}

-- ============================================================
-- PUBLIC API
-- ============================================================

-- Get an image asset ID by name
-- Returns nil if not found
function Images.Get(name)
    return AssetIds[name] or nil
end

-- Get with fallback if primary is nil
function Images.GetOrFallback(name, fallback)
    return AssetIds[name] or fallback or nil
end

-- Set an asset ID at runtime
function Images.Set(name, assetId)
    AssetIds[name] = assetId
end

-- Returns true if asset is defined and non-nil
function Images.Has(name)
    return AssetIds[name] ~= nil
end

-- Get all defined image names
function Images.GetAll()
    local names = {}
    for k in pairs(AssetIds) do
        table.insert(names, k)
    end
    return names
end

return Images
