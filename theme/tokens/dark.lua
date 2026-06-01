--[[
  File: dark.lua
  Layer: Theme/Tokens
  Responsibility: Dark theme semantic token map.
  Maps human-readable intent names to primitive
  base tokens. Components ONLY reference semantic
  names — never raw Color3 values directly.
  This is the default LuxwareUI theme.
  Dependencies: theme/tokens/base.lua
  Public API: returns semantic token table
]]

local Base = require(script.Parent.base)
local P    = Base.Palette
local S    = Base.Space
local R    = Base.Radius
local F    = Base.FontSize
local Fnt  = Base.Font
local Sz   = Base.Size
local T    = Base.Transition

return {

    -- ============================================================
    -- IDENTITY
    -- ============================================================
    _name       = "Dark",
    _isDark     = true,

    -- ============================================================
    -- BACKGROUND COLORS
    -- ============================================================
    Background      = P.Neutral950,      -- Main window bg
    Surface         = P.Neutral900,      -- Sidebar, panels
    SurfaceLight    = P.Neutral800,      -- Component bg, inputs
    SurfaceHover    = P.Neutral750,      -- Hover state bg
    SurfaceActive   = P.Neutral700,      -- Pressed state bg
    SurfaceOverlay  = P.Neutral925,      -- Dropdown, overlay bg

    -- ============================================================
    -- BORDER COLORS
    -- ============================================================
    Border          = P.Neutral700,      -- Default border
    BorderLight     = P.Neutral750,      -- Subtle border
    BorderGlow      = P.Violet700,       -- Accent border glow
    BorderFocus     = P.Violet500,       -- Focused input border

    -- ============================================================
    -- ACCENT COLORS
    -- ============================================================
    Accent          = P.Violet500,       -- Primary accent
    AccentLight     = P.Violet400,       -- Hover accent
    AccentDim       = P.Violet700,       -- Pressed/dim accent
    AccentBg        = P.Violet950,       -- Accent tinted background
    AccentText      = P.Violet100,       -- Text on accent bg

    -- ============================================================
    -- TEXT COLORS
    -- ============================================================
    TextPrimary     = P.Neutral50,       -- Main text
    TextSecondary   = P.Neutral300,      -- Secondary/dim text
    TextFaint       = P.Neutral500,      -- Placeholder, hint
    TextAccent      = P.Violet400,       -- Accent colored text
    TextOnAccent    = P.White,           -- Text on accent bg
    TextDisabled    = P.Neutral600,      -- Disabled state text

    -- ============================================================
    -- STATUS COLORS
    -- ============================================================
    Success         = P.Green400,
    SuccessBg       = Color3.fromRGB(20, 50, 30),
    Error           = P.Red400,
    ErrorBg         = Color3.fromRGB(50, 20, 20),
    Warning         = P.Yellow400,
    WarningBg       = Color3.fromRGB(50, 40, 10),
    Info            = P.Blue400,
    InfoBg          = Color3.fromRGB(15, 30, 55),

    -- ============================================================
    -- COMPONENT-SPECIFIC COLORS
    -- ============================================================
    ToggleOn        = P.Violet500,
    ToggleOff       = Color3.fromRGB(50, 50, 72),
    ToggleKnob      = P.White,

    SliderFill      = P.Violet500,
    SliderTrack     = P.Neutral800,
    SliderThumb     = P.White,
    SliderThumbBorder = P.Violet500,

    TabActive       = P.Neutral800,
    TabInactive     = P.Transparent,
    TabIndicator    = P.Violet500,
    TabTextActive   = P.Neutral50,
    TabTextInactive = P.Neutral300,

    InputBg         = P.Neutral800,
    InputBorder     = P.Neutral700,
    InputBorderFocus = P.Violet500,
    InputText       = P.Neutral50,
    InputPlaceholder = P.Neutral500,

    DropdownBg      = P.Neutral900,
    DropdownItemHover = P.Neutral800,
    DropdownItemActive = P.Neutral750,
    DropdownSelected = P.Violet950,
    DropdownSelectedText = P.Violet400,

    NotifBg         = P.Neutral900,
    NotifBorder     = P.Neutral700,

    DialogBg        = P.Neutral900,
    DialogOverlay   = Color3.fromRGB(0, 0, 0),
    DialogOverlayTransparency = 0.5,

    KeySystemBg     = P.Neutral900,
    KeySystemOverlay = Color3.fromRGB(0, 0, 0),

    SectionHeaderText = P.Neutral500,
    SectionDivider  = P.Neutral700,

    ScrollBar       = P.Violet600,

    -- ============================================================
    -- SPACING (inherits from base — can override per theme)
    -- ============================================================
    PaddingH        = S[14],
    PaddingV        = S[10],
    ComponentPadH   = S[14],
    ComponentPadV   = S[10],
    SectionGap      = S[6],
    ItemGap         = S[6],
    SidebarPadH     = S[8],
    SidebarPadV     = S[6],

    -- ============================================================
    -- SHAPE
    -- ============================================================
    RadiusWindow    = R.XXL,
    RadiusComponent = R.LG,
    RadiusSM        = R.SM,
    RadiusXS        = R.XS,
    RadiusPill      = R.Full,

    -- ============================================================
    -- TYPOGRAPHY
    -- ============================================================
    FontTitle       = Fnt.Bold,
    FontBody        = Fnt.Regular,
    FontMedium      = Fnt.Medium,
    FontSemiBold    = Fnt.SemiBold,
    FontBold        = Fnt.Bold,
    FontCode        = Fnt.Code,

    SizeTitle       = F.XL,
    SizeBody        = F.Base,
    SizeSM          = F.SM,
    SizeXS          = F.XS,
    SizeLG          = F.LG,

    -- ============================================================
    -- DIMENSIONS
    -- ============================================================
    SidebarWidth    = Sz.SidebarPC,
    RowHeight       = Sz.RowMD,
    RowHeightLG     = Sz.RowLG,
    RowHeightSlider = Sz.RowSlider,
    TitleBarHeight  = Sz.TitleBarH,

    -- ============================================================
    -- ANIMATION
    -- ============================================================
    TransitionFast    = T.Fast,
    TransitionDefault = T.Default,
    TransitionSlow    = T.Slow,
    EasingDefault     = T.Ease,
    EasingSpring      = T.Spring,

    -- ============================================================
    -- TRANSPARENCY VALUES
    -- ============================================================
    StrokeTransparency       = 0.5,
    StrokeTransparencySubtle = 0.7,
    StrokeTransparencyAccent = 0.3,
    GlowTransparency         = 0.75,
}
