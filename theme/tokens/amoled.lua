--[[
  File: amoled.lua
  Layer: Theme/Tokens
  Responsibility: Pure AMOLED black theme.
  Deepest possible blacks for OLED screens.
  Maximizes battery savings on OLED displays.
  Higher contrast than standard dark theme.
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
    _name       = "AMOLED",
    _isDark     = true,

    -- ============================================================
    -- BACKGROUND COLORS
    -- Pure blacks for OLED battery efficiency
    -- ============================================================
    Background      = P.Black,           -- True black
    Surface         = P.Neutral975,      -- Near-black sidebar
    SurfaceLight    = P.Neutral950,      -- Component bg
    SurfaceHover    = P.Neutral925,      -- Hover state
    SurfaceActive   = P.Neutral900,      -- Pressed state
    SurfaceOverlay  = P.Neutral975,      -- Dropdown bg

    -- ============================================================
    -- BORDER COLORS
    -- Subtler borders — high contrast from pure black
    -- ============================================================
    Border          = Color3.fromRGB(28, 28, 40),
    BorderLight     = Color3.fromRGB(22, 22, 32),
    BorderGlow      = P.Violet800,
    BorderFocus     = P.Violet500,

    -- ============================================================
    -- ACCENT COLORS
    -- Slightly more vibrant on pure black
    -- ============================================================
    Accent          = P.Violet500,
    AccentLight     = P.Violet400,
    AccentDim       = P.Violet800,
    AccentBg        = Color3.fromRGB(10, 8, 30),
    AccentText      = P.Violet200,

    -- ============================================================
    -- TEXT COLORS
    -- Higher contrast on pure black
    -- ============================================================
    TextPrimary     = P.Neutral0,        -- Pure white text
    TextSecondary   = P.Neutral200,
    TextFaint       = P.Neutral400,
    TextAccent      = P.Violet300,
    TextOnAccent    = P.White,
    TextDisabled    = P.Neutral600,

    -- ============================================================
    -- STATUS COLORS
    -- ============================================================
    Success         = P.Green400,
    SuccessBg       = Color3.fromRGB(5, 25, 12),
    Error           = P.Red400,
    ErrorBg         = Color3.fromRGB(30, 5, 5),
    Warning         = P.Yellow400,
    WarningBg       = Color3.fromRGB(30, 22, 0),
    Info            = P.Blue400,
    InfoBg          = Color3.fromRGB(5, 15, 35),

    -- ============================================================
    -- COMPONENT-SPECIFIC COLORS
    -- ============================================================
    ToggleOn        = P.Violet500,
    ToggleOff       = Color3.fromRGB(28, 28, 45),
    ToggleKnob      = P.White,

    SliderFill      = P.Violet500,
    SliderTrack     = P.Neutral950,
    SliderThumb     = P.White,
    SliderThumbBorder = P.Violet500,

    TabActive       = P.Neutral975,
    TabInactive     = P.Transparent,
    TabIndicator    = P.Violet500,
    TabTextActive   = P.Neutral0,
    TabTextInactive = P.Neutral300,

    InputBg         = P.Neutral975,
    InputBorder     = Color3.fromRGB(28, 28, 40),
    InputBorderFocus = P.Violet500,
    InputText       = P.Neutral0,
    InputPlaceholder = P.Neutral500,

    DropdownBg      = P.Neutral975,
    DropdownItemHover = P.Neutral950,
    DropdownItemActive = P.Neutral925,
    DropdownSelected = Color3.fromRGB(10, 8, 30),
    DropdownSelectedText = P.Violet300,

    NotifBg         = P.Neutral975,
    NotifBorder     = Color3.fromRGB(28, 28, 40),

    DialogBg        = P.Neutral975,
    DialogOverlay   = P.Black,
    DialogOverlayTransparency = 0.45,

    KeySystemBg     = P.Neutral975,
    KeySystemOverlay = P.Black,

    SectionHeaderText = P.Neutral400,
    SectionDivider  = Color3.fromRGB(22, 22, 32),

    ScrollBar       = P.Violet700,

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
    StrokeTransparency       = 0.6,
    StrokeTransparencySubtle = 0.75,
    StrokeTransparencyAccent = 0.4,
    GlowTransparency         = 0.80,
}
