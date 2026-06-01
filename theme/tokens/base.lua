--[[
  File: base.lua
  Layer: Theme/Tokens
  Responsibility: Primitive design tokens.
  Raw values only — no semantic meaning here.
  Every concrete value in the entire library
  traces back to a token defined in this file.
  Semantic token files (dark/light/amoled) map
  meaningful names onto these primitives.
  Dependencies: none
  Public API: Base.Palette, Base.Space,
  Base.Radius, Base.FontSize, Base.Font,
  Base.Stroke, Base.Transition
]]

local Base = {}

-- ============================================================
-- COLOR PALETTE
-- Full range of every color used in the library.
-- Named by hue + shade number (100=lightest, 950=darkest)
-- ============================================================
Base.Palette = {

    -- Violet (primary accent family)
    Violet50  = Color3.fromRGB(245, 243, 255),
    Violet100 = Color3.fromRGB(221, 214, 254),
    Violet200 = Color3.fromRGB(196, 181, 253),
    Violet300 = Color3.fromRGB(167, 139, 250),
    Violet400 = Color3.fromRGB(139, 122, 255),
    Violet500 = Color3.fromRGB(100,  90, 255),  -- Primary accent
    Violet600 = Color3.fromRGB( 79,  70, 229),
    Violet700 = Color3.fromRGB( 60,  55, 180),
    Violet800 = Color3.fromRGB( 45,  40, 140),
    Violet900 = Color3.fromRGB( 30,  27,  90),
    Violet950 = Color3.fromRGB( 18,  16,  54),

    -- Neutral (greys — used for backgrounds, text, borders)
    Neutral0   = Color3.fromRGB(255, 255, 255),  -- Pure white
    Neutral50  = Color3.fromRGB(240, 240, 255),  -- Text primary (slight blue tint)
    Neutral100 = Color3.fromRGB(210, 210, 230),
    Neutral200 = Color3.fromRGB(180, 180, 200),
    Neutral300 = Color3.fromRGB(140, 140, 165),  -- Text secondary
    Neutral400 = Color3.fromRGB(100, 100, 130),
    Neutral500 = Color3.fromRGB( 80,  80, 105),  -- Text faint
    Neutral600 = Color3.fromRGB( 60,  60,  85),
    Neutral700 = Color3.fromRGB( 40,  40,  58),  -- Border
    Neutral750 = Color3.fromRGB( 32,  32,  48),  -- Border light
    Neutral800 = Color3.fromRGB( 24,  24,  34),  -- Surface light
    Neutral850 = Color3.fromRGB( 20,  20,  28),
    Neutral900 = Color3.fromRGB( 18,  18,  25),  -- Surface
    Neutral925 = Color3.fromRGB( 15,  15,  21),
    Neutral950 = Color3.fromRGB( 13,  13,  18),  -- Background (AMOLED)
    Neutral975 = Color3.fromRGB(  8,   8,  12),  -- Pure AMOLED black

    -- Pearl (light theme family)
    Pearl0    = Color3.fromRGB(255, 255, 255),
    Pearl50   = Color3.fromRGB(250, 250, 252),
    Pearl100  = Color3.fromRGB(242, 242, 247),   -- Light background
    Pearl200  = Color3.fromRGB(230, 230, 238),   -- Light surface
    Pearl300  = Color3.fromRGB(210, 210, 222),   -- Light border
    Pearl400  = Color3.fromRGB(180, 180, 200),   -- Light border strong
    Pearl500  = Color3.fromRGB(120, 120, 150),   -- Light text dim
    Pearl600  = Color3.fromRGB( 60,  60,  90),   -- Light text secondary
    Pearl700  = Color3.fromRGB( 30,  30,  60),   -- Light text primary
    Pearl800  = Color3.fromRGB( 15,  15,  40),

    -- Semantic status colors
    Green400  = Color3.fromRGB( 74, 222, 128),
    Green500  = Color3.fromRGB( 34, 197,  94),
    Green600  = Color3.fromRGB( 22, 163,  74),

    Red400    = Color3.fromRGB(248, 113, 113),
    Red500    = Color3.fromRGB(239,  68,  68),
    Red600    = Color3.fromRGB(220,  38,  38),

    Yellow400 = Color3.fromRGB(250, 204,  21),
    Yellow500 = Color3.fromRGB(234, 179,   8),
    Yellow600 = Color3.fromRGB(202, 138,   4),

    Blue400   = Color3.fromRGB( 96, 165, 250),
    Blue500   = Color3.fromRGB( 59, 130, 246),
    Blue600   = Color3.fromRGB( 37, 99,  235),

    -- Pure
    White     = Color3.fromRGB(255, 255, 255),
    Black     = Color3.fromRGB(  0,   0,   0),
    Transparent = Color3.fromRGB(0, 0, 0),
}

-- ============================================================
-- SPACING SCALE
-- All spacing values in pixels.
-- Components use these for padding, gaps, margins.
-- ============================================================
Base.Space = {
    [2]  =  2,
    [4]  =  4,
    [6]  =  6,
    [8]  =  8,
    [10] = 10,
    [12] = 12,
    [14] = 14,
    [16] = 16,
    [20] = 20,
    [24] = 24,
    [28] = 28,
    [32] = 32,
    [40] = 40,
    [48] = 48,
}

-- ============================================================
-- CORNER RADIUS SCALE
-- All radius values in pixels.
-- ============================================================
Base.Radius = {
    None   =  0,
    XS     =  4,
    SM     =  6,
    MD     =  8,
    LG     = 10,
    XL     = 12,
    XXL    = 14,
    Full   = 999,  -- Perfect pill/circle
}

-- ============================================================
-- FONT SIZE SCALE
-- TextSize values used across all components.
-- ============================================================
Base.FontSize = {
    XS   = 10,  -- Hint, caption
    SM   = 11,  -- Description, label
    MD   = 12,  -- Secondary body
    Base = 13,  -- Primary body
    LG   = 14,  -- Component name
    XL   = 15,  -- Tab header
    XXL  = 16,  -- Section title
    H3   = 18,
    H2   = 20,
    H1   = 24,
}

-- ============================================================
-- FONT WEIGHTS
-- Roblox Enum.Font values mapped to weight names.
-- ============================================================
Base.Font = {
    Thin       = Enum.Font.Gotham,
    Regular    = Enum.Font.Gotham,
    Medium     = Enum.Font.GothamMedium,
    SemiBold   = Enum.Font.GothamSemibold,
    Bold       = Enum.Font.GothamBold,
    Code       = Enum.Font.Code,
}

-- ============================================================
-- STROKE THICKNESS
-- UIStroke thickness values.
-- ============================================================
Base.Stroke = {
    Thin    = 1,
    Default = 1.5,
    Thick   = 2,
}

-- ============================================================
-- COMPONENT DIMENSIONS
-- Fixed heights and widths for UI components.
-- ============================================================
Base.Size = {
    -- Row heights
    RowSM       = 36,  -- Compact row
    RowMD       = 44,  -- Standard row (toggle, button, dropdown)
    RowLG       = 54,  -- Row with description
    RowSlider   = 56,  -- Slider row
    RowInput    = 54,  -- Input row

    -- Sidebar
    SidebarPC   = 140,
    SidebarMD   = 120,
    SidebarSM   = 110,

    -- Window
    WindowW_PC  = 560,
    WindowH_PC  = 520,
    WindowW_SM  = 340,
    WindowH_SM  = 460,

    -- Toggle pill
    PillW       = 42,
    PillH       = 22,
    KnobSize    = 16,

    -- Icons
    IconSM      = 14,
    IconMD      = 18,
    IconLG      = 22,

    -- Color swatch
    SwatchSM    = 22,
    SwatchMD    = 28,

    -- Title bar
    TitleBarH   = 46,

    -- Notification
    NotifW      = 280,
    NotifH      = 70,
}

-- ============================================================
-- ANIMATION TIMING
-- TweenInfo presets used across all animations.
-- ============================================================
Base.Transition = {
    -- Duration in seconds
    Fast    = 0.15,
    Default = 0.25,
    Slow    = 0.35,
    Enter   = 0.40,
    Exit    = 0.25,

    -- Easing styles
    Ease    = Enum.EasingStyle.Quart,
    Spring  = Enum.EasingStyle.Back,
    Linear  = Enum.EasingStyle.Linear,
    Bounce  = Enum.EasingStyle.Bounce,
}

-- ============================================================
-- Z-INDEX LAYERS
-- Consistent layering across all UI elements.
-- ============================================================
Base.ZIndex = {
    Base        =  1,
    Component   =  2,
    Overlay     =  5,
    Dropdown    = 10,
    Dialog      = 20,
    KeySystem   = 30,
    Notification= 40,
    TopMost     = 50,
}

return Base
