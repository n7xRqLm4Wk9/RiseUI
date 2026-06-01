--[[
  File: light.lua
  Layer: Theme/Tokens
  Responsibility: Pearl White light theme semantic
  token map. Same semantic keys as dark.lua but
  mapped to light palette values. Based directly
  on the Pearl White UI screenshot reference.
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
    _name       = "PearlWhite",
    _isDark     = false,

    -- ============================================================
    -- BACKGROUND COLORS
    -- ============================================================
    Background      = P.Pearl100,        -- Light grey window bg
    Surface         = P.Pearl200,        -- Sidebar bg
    SurfaceLight    = P.Pearl0,          -- Component bg (white)
    SurfaceHover    = P.Pearl300,        -- Hover state
    SurfaceActive   = P.Pearl400,        -- Pressed state
    SurfaceOverlay  = P.Pearl50,         -- Dropdown bg

    -- ============================================================
    -- BORDER COLORS
    -- ============================================================
    Border          = P.Pearl300,
    BorderLight     = P.Pearl200,
    BorderGlow      = P.Violet300,
    BorderFocus     = P.Violet500,

    -- ============================================================
    -- ACCENT COLORS
    -- ============================================================
    Accent          = P.Violet500,
    AccentLight     = P.Violet400,
    AccentDim       = P.Violet600,
    AccentBg        = P.Violet50,
    AccentText      = P.Violet700,

    -- ============================================================
    -- TEXT COLORS
    -- ============================================================
    TextPrimary     = P.Pearl700,        -- Dark text on light bg
    TextSecondary   = P.Pearl600,
    TextFaint       = P.Pearl500,
    TextAccent      = P.Violet600,
    TextOnAccent    = P.White,
    TextDisabled    = P.Pearl400,

    -- ============================================================
    -- STATUS COLORS
    -- ============================================================
    Success         = P.Green600,
    SuccessBg       = Color3.fromRGB(220, 250, 230),
    Error           = P.Red600,
    ErrorBg         = Color3.fromRGB(255, 220, 220),
    Warning         = P.Yellow600,
    WarningBg       = Color3.fromRGB(255, 245, 200),
    Info            = P.Blue600,
    InfoBg          = Color3.fromRGB(220, 235, 255),

    -- ============================================================
    -- COMPONENT-SPECIFIC COLORS
    -- ============================================================
    ToggleOn        = P.Violet500,
    ToggleOff       = P.Pearl300,
    ToggleKnob      = P.White,

    SliderFill      = P.Violet500,
    SliderTrack     = P.Pearl300,
    SliderThumb     = P.White,
    SliderThumbBorder = P.Violet500,

    TabActive       = P.Pearl0,
    TabInactive     = P.Transparent,
    TabIndicator    = P.Violet500,
    TabTextActive   = P.Pearl700,
    TabTextInactive = P.Pearl600,

    InputBg         = P.Pearl0,
    InputBorder     = P.Pearl300,
    InputBorderFocus = P.Violet500,
    InputText       = P.Pearl700,
    InputPlaceholder = P.Pearl500,

    DropdownBg      = P.Pearl0,
    DropdownItemHover = P.Pearl100,
    DropdownItemActive = P.Pearl200,
    DropdownSelected = P.Violet50,
    DropdownSelectedText = P.Violet600,

    NotifBg         = P.Pearl0,
    NotifBorder     = P.Pearl300,

    DialogBg        = P.Pearl0,
    DialogOverlay   = Color3.fromRGB(100, 100, 120),
    DialogOverlayTransparency = 0.6,

    KeySystemBg     = P.Pearl0,
    KeySystemOverlay = Color3.fromRGB(100, 100, 120),

    SectionHeaderText = P.Pearl500,
    SectionDivider  = P.Pearl300,

    ScrollBar       = P.Violet400,

    -- ============================================================
    -- SPACING
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
    StrokeTransparency       = 0.4,
    StrokeTransparencySubtle = 0.6,
    StrokeTransparencyAccent = 0.2,
    GlowTransparency         = 0.85,
}
