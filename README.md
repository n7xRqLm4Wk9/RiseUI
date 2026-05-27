# CyphraUI — Custom Roblox UI Library

![Version](https://img.shields.io/badge/version-1.0.0-e94560?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Roblox-red?style=flat-square)

A lightweight, mobile-friendly UI library for Roblox script hubs. Built for the Cyphra Hub ecosystem.

---

## Features

- 🪟 Draggable window with minimize/close
- 🗂️ Tab-based navigation
- 🔘 Toggle switches with smooth animation
- 🎚️ Sliders with value display
- 🖱️ Buttons with hover effects
- 📋 Dropdown menus
- 🎨 Color pickers
- 📌 Section headers
- 🔔 Toast notifications
- 💾 Configuration save/load
- 📱 Mobile touch support
- 📦 No external dependencies

---

## Installation

```lua
local CyphraUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/n7xRqLm4Wk9/CyphraUI/main/library.lua"))()
```

---

## Quick Start

```lua
local CyphraUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/n7xRqLm4Wk9/CyphraUI/main/library.lua"))()

local Window = CyphraUI:CreateWindow({
    Name = "My Script",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Please wait",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyScript",
        FileName = "config",
    },
})

local Tab = Window:CreateTab("Main")

Tab:CreateToggle({
    Name = "Enable Feature",
    CurrentValue = false,
    Flag = "FeatureToggle",
    Callback = function(value)
        print("Feature:", value)
    end,
})
```

---

## API Reference

### `CyphraUI:CreateWindow(settings)` → `Window`

Creates the main UI window.

| Parameter | Type | Description |
|-----------|------|-------------|
| `Name` | string | Window title |
| `LoadingTitle` | string | Text shown on the loading screen |
| `LoadingSubtitle` | string | Subtitle shown on the loading screen |
| `ConfigurationSaving.Enabled` | bool | Whether to auto-save/load config |
| `ConfigurationSaving.FolderName` | string | Folder name for saved config |
| `ConfigurationSaving.FileName` | string | File name for saved config |

---

### `Window:CreateTab(name)` → `Tab`

Adds a tab to the sidebar.

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Tab label |

---

### `Tab:CreateSection(name)`

Creates a styled section header inside a tab.

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Section label (displayed in accent color) |

---

### `Tab:CreateToggle(settings)` → `Toggle`

Creates an animated on/off toggle.

| Parameter | Type | Description |
|-----------|------|-------------|
| `Name` | string | Label text |
| `CurrentValue` | bool | Initial state |
| `Flag` | string | Key used for config saving |
| `Callback` | function(bool) | Called when toggled |

Returns a `Toggle` object with `.CurrentValue` property.

---

### `Tab:CreateSlider(settings)` → `Slider`

Creates a draggable value slider.

| Parameter | Type | Description |
|-----------|------|-------------|
| `Name` | string | Label text |
| `Range` | `{Min, Max}` | Value range |
| `Increment` | number | Snap step size |
| `CurrentValue` | number | Initial value |
| `Flag` | string | Key used for config saving |
| `Callback` | function(number) | Called when value changes |

Returns a `Slider` object with `.CurrentValue` property.

---

### `Tab:CreateButton(settings)`

Creates a clickable button.

| Parameter | Type | Description |
|-----------|------|-------------|
| `Name` | string | Button label |
| `Callback` | function() | Called on click |

---

### `Tab:CreateDropdown(settings)` → `Dropdown`

Creates a dropdown selection menu.

| Parameter | Type | Description |
|-----------|------|-------------|
| `Name` | string | Label text |
| `Options` | string[] | Array of option strings |
| `CurrentOption` | string | Initially selected option |
| `Flag` | string | Key used for config saving |
| `Callback` | function(string) | Called when selection changes |

Returns a `Dropdown` object with `.CurrentOption` property.

---

### `Tab:CreateColorPicker(settings)` → `ColorPicker`

Creates a color selection element.

| Parameter | Type | Description |
|-----------|------|-------------|
| `Name` | string | Label text |
| `Color` | Color3 | Initial color |
| `Flag` | string | Key used for config saving |
| `Callback` | function(Color3) | Called when color changes |

Returns a `ColorPicker` object with `.Color` property.

---

### `Window:Notify(settings)`

Shows a toast notification.

| Parameter | Type | Description |
|-----------|------|-------------|
| `Title` | string | Notification title |
| `Content` | string | Body text |
| `Duration` | number | Seconds before auto-dismiss |
| `Image` | number | Optional Roblox asset ID for icon |

---

### `CyphraUI:SaveConfiguration()`

Saves all flagged element values to the configured JSON file.

---

### `CyphraUI:LoadConfiguration()`

Loads saved configuration and restores all flagged element values.

---

### `Window:Destroy()`

Completely removes the UI and cleans up all connections.

---

## Design

CyphraUI uses the **Cyphra Red** dark color scheme:

| Name | Hex | Usage |
|------|-----|-------|
| Background | `#1a1a2e` | Main window background |
| Surface | `#16213e` | Sidebar and secondary panels |
| Card | `#0f3460` | Component cards |
| Accent | `#e94560` | Active states, buttons, highlights |
| Text | `#eeeeee` | Primary text |
| SubText | `#888888` | Secondary / hint text |
| Success | `#4caf50` | Positive states |

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Credits

Made by **Cyphra**
