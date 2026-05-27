--[[
	CyphraUI - Example Script
	Demonstrates all available components across three tabs.
--]]

local CyphraUI = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/n7xRqLm4Wk9/CyphraUI/main/library.lua"
))()

-- ─── Create window ───────────────────────────────────────────────────────────

local Window = CyphraUI:CreateWindow({
	Name            = "Cyphra Hub",
	LoadingTitle    = "Cyphra Hub",
	LoadingSubtitle = "Loading components...",
	ConfigurationSaving = {
		Enabled    = true,
		FolderName = "CyphraHub",
		FileName   = "config",
	},
})

-- ─── Combat tab ──────────────────────────────────────────────────────────────

local CombatTab = Window:CreateTab("Combat")

CombatTab:CreateSection("Aimbot")

local AimbotToggle = CombatTab:CreateToggle({
	Name         = "Enable Aimbot",
	CurrentValue = false,
	Flag         = "AimbotEnabled",
	Callback     = function(value)
		print("[Combat] Aimbot:", value)
	end,
})

local FOVSlider = CombatTab:CreateSlider({
	Name         = "FOV Radius",
	Range        = {20, 80},
	Increment    = 1,
	CurrentValue = 50,
	Flag         = "AimbotFOV",
	Callback     = function(value)
		print("[Combat] FOV set to:", value)
	end,
})

local TargetDropdown = CombatTab:CreateDropdown({
	Name          = "Target Part",
	Options       = {"Head", "Torso"},
	CurrentOption = "Head",
	Flag          = "AimbotPart",
	Callback      = function(option)
		print("[Combat] Target part:", option)
	end,
})

CombatTab:CreateSection("Triggerbot")

CombatTab:CreateToggle({
	Name         = "Enable Triggerbot",
	CurrentValue = false,
	Flag         = "TriggerbotEnabled",
	Callback     = function(value)
		print("[Combat] Triggerbot:", value)
	end,
})

CombatTab:CreateSlider({
	Name         = "Trigger Delay (ms)",
	Range        = {0, 500},
	Increment    = 10,
	CurrentValue = 100,
	Flag         = "TriggerbotDelay",
	Callback     = function(value)
		print("[Combat] Trigger delay:", value)
	end,
})

-- ─── Visuals tab ─────────────────────────────────────────────────────────────

local VisualsTab = Window:CreateTab("Visuals")

VisualsTab:CreateSection("ESP")

local ESPToggle = VisualsTab:CreateToggle({
	Name         = "Enable ESP",
	CurrentValue = false,
	Flag         = "ESPEnabled",
	Callback     = function(value)
		print("[Visuals] ESP:", value)
	end,
})

local BoxToggle = VisualsTab:CreateToggle({
	Name         = "Box ESP",
	CurrentValue = true,
	Flag         = "BoxEnabled",
	Callback     = function(value)
		print("[Visuals] Box ESP:", value)
	end,
})

VisualsTab:CreateToggle({
	Name         = "Skeleton ESP",
	CurrentValue = false,
	Flag         = "SkeletonEnabled",
	Callback     = function(value)
		print("[Visuals] Skeleton:", value)
	end,
})

VisualsTab:CreateToggle({
	Name         = "Tracers",
	CurrentValue = false,
	Flag         = "TracersEnabled",
	Callback     = function(value)
		print("[Visuals] Tracers:", value)
	end,
})

VisualsTab:CreateSection("Appearance")

local ESPColorPicker = VisualsTab:CreateColorPicker({
	Name     = "ESP Color",
	Color    = Color3.fromRGB(233, 69, 96),
	Flag     = "ESPColor",
	Callback = function(color)
		print("[Visuals] ESP color changed:", color)
	end,
})

VisualsTab:CreateSection("World")

VisualsTab:CreateToggle({
	Name         = "Fullbright",
	CurrentValue = false,
	Flag         = "Fullbright",
	Callback     = function(value)
		if value then
			game:GetService("Lighting").Brightness = 10
		else
			game:GetService("Lighting").Brightness = 2
		end
	end,
})

VisualsTab:CreateSlider({
	Name         = "Field of View",
	Range        = {60, 120},
	Increment    = 1,
	CurrentValue = 70,
	Flag         = "FOV",
	Callback     = function(value)
		workspace.CurrentCamera.FieldOfView = value
	end,
})

-- ─── Settings tab ────────────────────────────────────────────────────────────

local SettingsTab = Window:CreateTab("Settings")

SettingsTab:CreateSection("Configuration")

SettingsTab:CreateButton({
	Name     = "Save Configuration",
	Callback = function()
		CyphraUI:SaveConfiguration()
		Window:Notify({
			Title   = "Config Saved",
			Content = "Your settings have been saved successfully.",
			Duration = 3,
		})
	end,
})

SettingsTab:CreateButton({
	Name     = "Load Configuration",
	Callback = function()
		CyphraUI:LoadConfiguration()
		Window:Notify({
			Title   = "Config Loaded",
			Content = "Your saved settings have been restored.",
			Duration = 3,
		})
	end,
})

SettingsTab:CreateSection("Info")

SettingsTab:CreateToggle({
	Name         = "Show Notifications",
	CurrentValue = true,
	Flag         = "ShowNotifs",
	Callback     = function(value)
		print("[Settings] Notifications:", value)
	end,
})

SettingsTab:CreateSection("Danger Zone")

SettingsTab:CreateButton({
	Name     = "Destroy UI",
	Callback = function()
		Window:Destroy()
	end,
})

-- ─── Startup notification ────────────────────────────────────────────────────

task.wait(1.2)   -- let the loading animation finish

Window:Notify({
	Title    = "Cyphra Hub",
	Content  = "Script loaded successfully. Enjoy!",
	Duration = 4,
})
