--[[
  File: Icons.lua
  Layer: Assets
  Responsibility: Named map of all icon asset IDs
  and their GitHub raw URLs. Components reference
  icons by name only — never by raw ID directly.
  Includes emoji fallbacks for every icon in case
  an asset fails to load or hasn't been uploaded yet.
  Dependencies: none
  Public API: Icons.Get(name) → assetId string
  Icons.GetEmoji(name) → emoji string
  Icons.GetURL(name) → GitHub raw URL string
]]

local Icons = {}

-- ============================================================
-- GITHUB RAW BASE URL
-- Update this if the repo moves
-- ============================================================
local GITHUB_BASE = "https://raw.githubusercontent.com/n7xRqLm4Wk9/LuxwareUI/main/assets/icons/"

-- ============================================================
-- ROBLOX ASSET IDS
-- Upload each PNG to create.roblox.com/assets
-- then paste the returned asset ID here
-- Format: "rbxassetid://000000000000"
-- ============================================================
local AssetIds = {
    ["bell"]               = "rbxassetid://REPLACE_ME",
    ["chevron-down"]       = "rbxassetid://REPLACE_ME",
    ["chevron-up"]         = "rbxassetid://REPLACE_ME",
    ["circle-plus"]        = "rbxassetid://REPLACE_ME",
    ["ellipsis-vertical"]  = "rbxassetid://REPLACE_ME",
    ["eye-off"]            = "rbxassetid://REPLACE_ME",
    ["eye"]                = "rbxassetid://REPLACE_ME",
    ["grip-vertical"]      = "rbxassetid://REPLACE_ME",
    ["house"]              = "rbxassetid://REPLACE_ME",
    ["keyboard"]           = "rbxassetid://REPLACE_ME",
    ["lock-open"]          = "rbxassetid://REPLACE_ME",
    ["lock"]               = "rbxassetid://REPLACE_ME",
    ["message-circle"]     = "rbxassetid://REPLACE_ME",
    ["minus"]              = "rbxassetid://REPLACE_ME",
    ["palette"]            = "rbxassetid://REPLACE_ME",
    ["rotate-cw"]          = "rbxassetid://REPLACE_ME",
    ["search"]             = "rbxassetid://REPLACE_ME",
    ["settings"]           = "rbxassetid://REPLACE_ME",
    ["sliders-horizontal"] = "rbxassetid://REPLACE_ME",
    ["toggle-left"]        = "rbxassetid://REPLACE_ME",
    ["toggle-right"]       = "rbxassetid://REPLACE_ME",
    ["triangle-alert"]     = "rbxassetid://REPLACE_ME",
    ["x"]                  = "rbxassetid://REPLACE_ME",
}

-- ============================================================
-- GITHUB RAW URLS
-- Used as fallback when asset IDs aren't set yet
-- ============================================================
local GitHubURLs = {
    ["bell"]               = GITHUB_BASE .. "bell.png",
    ["chevron-down"]       = GITHUB_BASE .. "chevron-down.png",
    ["chevron-up"]         = GITHUB_BASE .. "chevron-up.png",
    ["circle-plus"]        = GITHUB_BASE .. "circle-plus.png",
    ["ellipsis-vertical"]  = GITHUB_BASE .. "ellipsis-vertical.png",
    ["eye-off"]            = GITHUB_BASE .. "eye-off.png",
    ["eye"]                = GITHUB_BASE .. "eye.png",
    ["grip-vertical"]      = GITHUB_BASE .. "grip-vertical.png",
    ["house"]              = GITHUB_BASE .. "house.png",
    ["keyboard"]           = GITHUB_BASE .. "keyboard.png",
    ["lock-open"]          = GITHUB_BASE .. "lock-open.png",
    ["lock"]               = GITHUB_BASE .. "lock.png",
    ["message-circle"]     = GITHUB_BASE .. "message-circle.png",
    ["minus"]              = GITHUB_BASE .. "minus.png",
    ["palette"]            = GITHUB_BASE .. "palette.png",
    ["rotate-cw"]          = GITHUB_BASE .. "rotate-cw.png",
    ["search"]             = GITHUB_BASE .. "search.png",
    ["settings"]           = GITHUB_BASE .. "settings.png",
    ["sliders-horizontal"] = GITHUB_BASE .. "sliders-horizontal.png",
    ["toggle-left"]        = GITHUB_BASE .. "toggle-left.png",
    ["toggle-right"]       = GITHUB_BASE .. "toggle-right.png",
    ["triangle-alert"]     = GITHUB_BASE .. "triangle-alert.png",
    ["x"]                  = GITHUB_BASE .. "x.png",
}

-- ============================================================
-- EMOJI FALLBACKS
-- Used when no asset ID or URL is available
-- ============================================================
local EmojiFallbacks = {
    ["bell"]               = "🔔",
    ["chevron-down"]       = "▾",
    ["chevron-up"]         = "▴",
    ["circle-plus"]        = "➕",
    ["ellipsis-vertical"]  = "⋯",
    ["eye-off"]            = "🙈",
    ["eye"]                = "👁",
    ["grip-vertical"]      = "⠿",
    ["house"]              = "🏠",
    ["keyboard"]           = "⌨",
    ["lock-open"]          = "🔓",
    ["lock"]               = "🔒",
    ["message-circle"]     = "💬",
    ["minus"]              = "─",
    ["palette"]            = "🎨",
    ["rotate-cw"]          = "🔄",
    ["search"]             = "🔍",
    ["settings"]           = "⚙️",
    ["sliders-horizontal"] = "🎚",
    ["toggle-left"]        = "◎",
    ["toggle-right"]       = "●",
    ["triangle-alert"]     = "⚠️",
    ["x"]                  = "✕",
}

-- ============================================================
-- SEMANTIC ALIASES
-- Map friendly component names to icon keys
-- so components don't need to know exact filenames
-- ============================================================
local Aliases = {
    -- Navigation
    home         = "house",
    close        = "x",
    minimize     = "minus",
    reload       = "rotate-cw",
    add          = "circle-plus",

    -- Components
    toggle_on    = "toggle-right",
    toggle_off   = "toggle-left",
    dropdown     = "chevron-down",
    color        = "palette",
    keybind      = "keyboard",
    slider       = "sliders-horizontal",
    input_show   = "eye",
    input_hide   = "eye-off",
    drag         = "grip-vertical",
    more         = "ellipsis-vertical",

    -- Overlays
    notification = "bell",
    dialog       = "message-circle",
    warning      = "triangle-alert",
    locked       = "lock",
    unlocked     = "lock-open",
}

-- ============================================================
-- PUBLIC API
-- ============================================================

-- Resolve an alias or direct key to the canonical key
local function Resolve(name)
    return Aliases[name] or name
end

-- Returns true if asset ID has been filled in
local function IsUploaded(key)
    local id = AssetIds[key]
    return id ~= nil and id ~= "rbxassetid://REPLACE_ME"
end

-- Get the best available image source for an icon
-- Priority: AssetId → GitHub URL → nil
function Icons.Get(name)
    local key = Resolve(name)
    if IsUploaded(key) then
        return AssetIds[key]
    end
    return GitHubURLs[key] or nil
end

-- Get just the rbxassetid (nil if not uploaded)
function Icons.GetAssetId(name)
    local key = Resolve(name)
    if IsUploaded(key) then
        return AssetIds[key]
    end
    return nil
end

-- Get the GitHub raw URL for an icon
function Icons.GetURL(name)
    local key = Resolve(name)
    return GitHubURLs[key] or nil
end

-- Get the emoji fallback for an icon
function Icons.GetEmoji(name)
    local key = Resolve(name)
    return EmojiFallbacks[key] or "□"
end

-- Returns true if icon has a valid uploaded asset ID
function Icons.IsReady(name)
    local key = Resolve(name)
    return IsUploaded(key)
end

-- Get all icon names (canonical keys)
function Icons.GetAll()
    local names = {}
    for k in pairs(AssetIds) do
        table.insert(names, k)
    end
    return names
end

-- Set an asset ID at runtime (for dynamic loading)
function Icons.SetAssetId(name, assetId)
    local key = Resolve(name)
    AssetIds[key] = assetId
end

return Icons
