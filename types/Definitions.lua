--[[
  File: Definitions.lua
  Layer: Types
  Responsibility: Shared type contracts and
  documented interfaces for all config tables,
  component handles, and internal data shapes.
  Acts as the single source of truth for the
  public API shape across the entire library.
  Dependencies: none
  Public API: Type documentation only —
  no runtime logic in this file.
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WINDOW CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  LuxwareUI:CreateWindow({
    Name            : string        -- Window title
    LoadingTitle    : string?       -- Subtitle under title
    Icon            : string?       -- Emoji or asset id
    Theme           : string?       -- "Default"|"Midnight"|"Neon"|"PearlWhite"|"AMOLED"
    Transparent     : boolean?      -- Enable transparency
    ConfigurationSaving : {
      Enabled       : boolean
      FolderName    : string?
      FileName      : string
    }?
    KeySystem       : KeySystemConfig?
  }) → WindowHandle
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  KEY SYSTEM CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  KeySystemConfig = {
    Title           : string        -- Key system dialog title
    SubTitle        : string?       -- Instruction text
    JnkieURL        : string        -- Full jnkie checkpoint URL
    EnableHWID      : boolean?      -- Bind key to player (default true)
    SaveKey         : boolean?      -- Save key locally (default true)
    Periodic        : boolean?      -- Recheck every 30min (default true)
    OnSuccess       : function?     -- Called when key passes
    OnFail          : function?     -- Called with reason string
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TAB CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WindowHandle:CreateTab({
    Name            : string        -- Tab label
    Icon            : string?       -- Icon key from Icons.lua or emoji
  }) → TabHandle
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SECTION CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TabHandle:CreateSection(name: string) → SectionHandle
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  BUTTON CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SectionHandle:CreateButton({
    Name            : string        -- Button label
    Description     : string?       -- Subtext below label
    Icon            : string?       -- Icon key or emoji
    Callback        : function      -- Called on click
  }) → ButtonHandle

  ButtonHandle = {
    Set             : (name: string) → void
    Destroy         : () → void
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TOGGLE CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SectionHandle:CreateToggle({
    Name            : string        -- Toggle label
    Description     : string?       -- Subtext
    Icon            : string?       -- Icon key or emoji
    CurrentValue    : boolean?      -- Default state (false)
    Flag            : string?       -- Key in LuxwareUI.Flags
    Callback        : function?     -- Called with (bool)
  }) → ToggleHandle

  ToggleHandle = {
    Set             : (value: boolean) → void
    Get             : () → boolean
    Destroy         : () → void
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SLIDER CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SectionHandle:CreateSlider({
    Name            : string        -- Slider label
    Description     : string?       -- Subtext
    Range           : {number, number}  -- {min, max}
    Increment       : number?       -- Step size (default 1)
    CurrentValue    : number?       -- Default value
    Flag            : string?       -- Key in LuxwareUI.Flags
    Suffix          : string?       -- Unit label e.g. "px" "ms"
    Callback        : function?     -- Called with (number)
  }) → SliderHandle

  SliderHandle = {
    Set             : (value: number) → void
    Get             : () → number
    Destroy         : () → void
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  INPUT CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SectionHandle:CreateInput({
    Name            : string        -- Input label
    Description     : string?       -- Subtext
    PlaceholderText : string?       -- Placeholder
    CurrentValue    : string?       -- Default value
    EnterPressOnly  : boolean?      -- Only fire on Enter
    ClearTextOnFocus: boolean?      -- Clear on focus (default true)
    NumbersOnly     : boolean?      -- Restrict to numbers
    MaxLength       : number?       -- Max character limit
    Flag            : string?       -- Key in LuxwareUI.Flags
    Callback        : function?     -- Called with (string)
  }) → InputHandle

  InputHandle = {
    Set             : (value: string) → void
    Get             : () → string
    Destroy         : () → void
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DROPDOWN CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SectionHandle:CreateDropdown({
    Name            : string        -- Dropdown label
    Description     : string?       -- Subtext
    Options         : {string}      -- List of options
    CurrentOption   : string|{string}? -- Default selection
    MultipleOptions : boolean?      -- Allow multi-select
    Flag            : string?       -- Key in LuxwareUI.Flags
    Callback        : function?     -- Called with (string|{string})
  }) → DropdownHandle

  DropdownHandle = {
    Set             : (value: string|{string}) → void
    Get             : () → string|{string}
    Refresh         : (options: {string}) → void
    Destroy         : () → void
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  COLOR PICKER CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SectionHandle:CreateColorPicker({
    Name            : string        -- Picker label
    Description     : string?       -- Subtext
    Color           : Color3?       -- Default color
    Flag            : string?       -- Key in LuxwareUI.Flags
    Callback        : function?     -- Called with (Color3)
  }) → ColorPickerHandle

  ColorPickerHandle = {
    Set             : (color: Color3) → void
    Get             : () → Color3
    Destroy         : () → void
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  KEYBIND CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SectionHandle:CreateKeybind({
    Name            : string        -- Keybind label
    Description     : string?       -- Subtext
    CurrentKeybind  : string?       -- Default key name
    HoldToInteract  : boolean?      -- Hold vs tap
    Flag            : string?       -- Key in LuxwareUI.Flags
    Callback        : function?     -- Called with (KeyCode)
  }) → KeybindHandle

  KeybindHandle = {
    Set             : (key: string) → void
    Get             : () → string
    Destroy         : () → void
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  LABEL CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SectionHandle:CreateLabel({
    Text            : string        -- Label text
    Icon            : string?       -- Icon key or emoji
    Color           : Color3?       -- Override text color
  }) → LabelHandle

  LabelHandle = {
    Set             : (text: string) → void
    Destroy         : () → void
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  COMPONENT TOGGLE CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  A toggle row with a ⋯ button that opens an
  inline config panel containing any widgets.

  SectionHandle:CreateComponentToggle({
    Name            : string        -- Label
    Description     : string?       -- Subtext
    Flag            : string?       -- Toggle flag key
    CurrentValue    : boolean?      -- Default toggle state
    Callback        : function?     -- Called with (bool)
    Config          : {             -- Inline config widgets
      {
        Type        : "Toggle"|"Slider"|"Dropdown"|
                      "ColorPicker"|"Input"|"Keybind"
        Name        : string
        Flag        : string?
        -- plus all type-specific fields above
      }
    }
  }) → ComponentToggleHandle

  ComponentToggleHandle = {
    Set             : (value: boolean) → void
    Get             : () → boolean
    SetConfig       : (flag: string, value: any) → void
    GetConfig       : (flag: string) → any
    Destroy         : () → void
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MODULE CONFIG CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  A collapsible panel that groups related widgets
  under a named header. Returns a SectionHandle
  so all widget creation methods work inside it.

  SectionHandle:CreateModuleConfig({
    Name            : string        -- Panel header label
    Icon            : string?       -- Icon key or emoji
    DefaultOpen     : boolean?      -- Start expanded (false)
  }) → SectionHandle
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  NOTIFICATION CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  LuxwareUI:Notify({
    Title           : string        -- Notification title
    Content         : string        -- Body text
    Duration        : number?       -- Seconds (default 4)
    Type            : string?       -- "info"|"success"|"error"|"warning"
    Icon            : string?       -- Override icon
  })

  WindowHandle:Notify(config)      -- Same API, window-scoped
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DIALOG CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WindowHandle:Dialog({
    Title           : string        -- Dialog title
    Content         : string        -- Body text
    Buttons         : {
      {
        Title       : string        -- Button label
        Accent      : boolean?      -- Highlight this button
        Callback    : function      -- Called on click
      }
    }
  })
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  THEME CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  LuxwareUI:SetTheme(nameOrTable)

  nameOrTable: string → built-in preset name
    "Default" | "Midnight" | "Neon" |
    "PearlWhite" | "AMOLED"

  nameOrTable: table → partial semantic override
  {
    -- Colors
    Background      : Color3?
    Surface         : Color3?
    SurfaceLight    : Color3?
    SurfaceHover    : Color3?
    Border          : Color3?
    BorderGlow      : Color3?
    Accent          : Color3?
    AccentLight     : Color3?
    AccentDim       : Color3?
    TextPrimary     : Color3?
    TextSecondary   : Color3?
    TextFaint       : Color3?
    Success         : Color3?
    Error           : Color3?
    Warning         : Color3?
    Info            : Color3?
    ToggleOn        : Color3?
    ToggleOff       : Color3?
    SliderFill      : Color3?

    -- Spacing (numbers, pixels)
    SidebarWidth    : number?
    ComponentHeight : number?
    PaddingH        : number?
    PaddingV        : number?
    SectionGap      : number?
    ItemGap         : number?

    -- Shape
    RadiusWindow    : number?
    RadiusComponent : number?
    RadiusSmall     : number?
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SAVE MANAGER CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Configured via WindowConfig.ConfigurationSaving:
  {
    Enabled         : boolean       -- Master on/off
    FolderName      : string?       -- Subfolder name
    FileName        : string        -- Config file name
  }

  Saved file shape (internal, do not edit manually):
  {
    _version        : number        -- Schema version
    _savedAt        : number        -- Unix timestamp
    [flagKey]       : any           -- All flag values
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WINDOW HANDLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WindowHandle = {
    CreateTab       : (config) → TabHandle
    Notify          : (config) → void
    Dialog          : (config) → void
    Destroy         : () → void
  }
]]

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  LUXWAREUI ROOT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  LuxwareUI = {
    CreateWindow    : (config) → WindowHandle
    KeySystem       : (config) → void
    SetTheme        : (nameOrTable) → void
    Notify          : (config) → void
    Flags           : { [string]: any }
    Version         : string
  }
]]

-- No runtime code below this line.
-- This file is documentation only.
return {}
