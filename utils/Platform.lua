--[[
  File: Platform.lua
  Layer: Utils
  Responsibility: Device and platform detection,
  screen size breakpoints, and input capability
  checks for responsive layout decisions.
  Dependencies: none (reads Roblox services)
  Public API: Platform.IsMobile, Platform.IsTablet,
  Platform.IsPC, Platform.GetScreenSize,
  Platform.GetBreakpoint, Platform.IsTouchEnabled,
  Platform.IsGamepad, Platform.IsKeyboard,
  Platform.Responsive
]]

local UserInputService = game:GetService("UserInputService")
local GuiService       = game:GetService("GuiService")
local Platform         = {}

-- Breakpoint thresholds in pixels
local BREAKPOINTS = {
    SM = 480,   -- phone
    MD = 768,   -- tablet
    LG = 1024,  -- desktop
}

-- Cache screen size to avoid repeated calls
local _screenSize = nil
local function GetScreenSize()
    if not _screenSize then
        local camera = workspace.CurrentCamera
        if camera then
            _screenSize = camera.ViewportSize
        else
            _screenSize = Vector2.new(1920, 1080)
        end
    end
    return _screenSize
end

-- Invalidate cache when viewport changes
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    _screenSize = nil
end)
if workspace.CurrentCamera then
    workspace.CurrentCamera
        :GetPropertyChangedSignal("ViewportSize")
        :Connect(function()
            _screenSize = nil
        end)
end

-- Get current screen size as Vector2
function Platform.GetScreenSize()
    return GetScreenSize()
end

-- Get screen width
function Platform.GetScreenWidth()
    return GetScreenSize().X
end

-- Get screen height
function Platform.GetScreenHeight()
    return GetScreenSize().Y
end

-- Returns current breakpoint string
-- "sm" = phone, "md" = tablet, "lg" = desktop
function Platform.GetBreakpoint()
    local width = GetScreenSize().X
    if width <= BREAKPOINTS.SM then
        return "sm"
    elseif width <= BREAKPOINTS.MD then
        return "md"
    else
        return "lg"
    end
end

-- Returns true if touch is primary input
function Platform.IsTouchEnabled()
    return UserInputService.TouchEnabled
end

-- Returns true if a keyboard is available
function Platform.IsKeyboard()
    return UserInputService.KeyboardEnabled
end

-- Returns true if a gamepad is connected
function Platform.IsGamepad()
    return UserInputService.GamepadEnabled
end

-- Returns true if running on a phone
function Platform.IsMobile()
    local width = GetScreenSize().X
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and width <= BREAKPOINTS.MD
end

-- Returns true if running on a tablet
function Platform.IsTablet()
    local width = GetScreenSize().X
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and width > BREAKPOINTS.SM
        and width <= BREAKPOINTS.LG
end

-- Returns true if running on a PC/desktop
function Platform.IsPC()
    return UserInputService.KeyboardEnabled
        and UserInputService.MouseEnabled
end

-- Returns true if device has a mouse
function Platform.HasMouse()
    return UserInputService.MouseEnabled
end

-- Get inset size (accounts for notches, safe areas)
function Platform.GetSafeInset()
    return GuiService:GetGuiInset()
end

-- Responsive value selector
-- Pass a table with sm/md/lg keys
-- Returns the value for current breakpoint
-- e.g. Platform.Responsive({sm=10, md=14, lg=18})
function Platform.Responsive(values)
    local bp = Platform.GetBreakpoint()
    if bp == "sm" and values.sm then
        return values.sm
    elseif bp == "md" then
        return values.md or values.sm
    else
        return values.lg or values.md or values.sm
    end
end

return Platform
