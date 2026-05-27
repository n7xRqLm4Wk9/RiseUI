--[[
	CyphraUI - Custom Roblox UI Library
	Version 1.1.0
	Rayfield/Fluent Inspired (Black & White Monochromatic Theme)
	Made by Cyphra
	MIT License
--]]

-- ─── Services ────────────────────────────────────────────────────────────────

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ─── Fluent / Rayfield Inspired Monochromatic Theme ──────────────────────────

local THEME = {
	Background = Color3.fromRGB(10, 10, 10),    -- Rich Pure Black
	Surface    = Color3.fromRGB(18, 18, 18),    -- Dark Charcoal
	Card       = Color3.fromRGB(28, 28, 28),    -- Element Card Background
	Accent     = Color3.fromRGB(255, 255, 255),-- Clean Crisp White Accent
	Text       = Color3.fromRGB(245, 245, 245),-- High Contrast Text
	SubText    = Color3.fromRGB(140, 140, 140),-- Muted Muted Gray Text
	Stroke     = Color3.fromRGB(40, 40, 40),    -- Subtle Boundaries
	Success    = Color3.fromRGB(255, 255, 255),
}

-- ─── Tween Helpers ───────────────────────────────────────────────────────────

local function tween(obj, info, goals)
	TweenService:Create(obj, info, goals):Play()
end

local FAST   = TweenInfo.new(0.15, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local MEDIUM = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local SLOW   = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- ─── UI Creation Utilities ───────────────────────────────────────────────────

local function make(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		obj[k] = v
	end
	if parent then obj.Parent = parent end
	return obj
end

local function addCorner(parent, radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

local function addStroke(parent, color, thickness)
	return make("UIStroke", {
		Color     = color or THEME.Stroke,
		Thickness = thickness or 1,
	}, parent)
end

local function addPadding(parent, top, right, bottom, left)
	return make("UIPadding", {
		PaddingTop    = UDim.new(0, top    or 6),
		PaddingRight  = UDim.new(0, right  or 8),
		PaddingBottom = UDim.new(0, bottom or 6),
		PaddingLeft   = UDim.new(0, left   or 8),
	}, parent)
end

-- ─── Serialization Config Helpers ────────────────────────────────────────────

local function jsonEncode(t)
	local parts = {}
	for k, v in pairs(t) do
		local val
		if type(v) == "boolean" then
			val = tostring(v)
		elseif type(v) == "number" then
			val = tostring(v)
		elseif type(v) == "string" then
			val = '"' .. v:gsub('"', '\\"') .. '"'
		elseif type(v) == "table" then
			val = "[" .. table.concat(v, ",") .. "]"
		else
			val = '"unsupported"'
		end
		table.insert(parts, '"' .. tostring(k) .. '":' .. val)
	end
	return "{" .. table.concat(parts, ",") .. "}"
end

local function jsonDecode(s)
	local result = {}
	for k, v in s:gmatch('"([^"]+)":([^,}]+)') do
		v = v:match("^%s*(.-)%s*$")
		if v == "true" then
			result[k] = true
		elseif v == "false" then
			result[k] = false
		elseif v:match("^%[(.-)%]$") then
			local tbl = {}
			for num in v:gmatch("([^,]+)") do
				table.insert(tbl, tonumber(num) or num)
			end
			result[k] = tbl
		elseif tonumber(v) then
			result[k] = tonumber(v)
		else
			result[k] = v:match('"(.*)"') or v
		end
	end
	return result
end

-- ─── Main Framework Initialization ───────────────────────────────────────────

local CyphraUI = {}
CyphraUI.__index = CyphraUI

CyphraUI._flags      = {}
CyphraUI._configOpts = {}

-- ─── Window Construction ─────────────────────────────────────────────────────

function CyphraUI:CreateWindow(settings)
	local windowName    = settings.Name           or "CyphraUI"
	local loadTitle     = settings.LoadingTitle   or "CyphraUI"
	local loadSub       = settings.LoadingSubtitle or "Loading Framework..."
	local configOpts    = settings.ConfigurationSaving or { Enabled = false }

	CyphraUI._configOpts = configOpts

	local gui = make("ScreenGui", {
		Name           = "CyphraUI",
		ResetOnSpawn   = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not ok then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	-- Loading Animation Panel
	local loadFrame = make("Frame", {
		Name            = "LoadFrame",
		Size            = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		ZIndex          = 100,
	}, gui)

	local loadTitle_ = make("TextLabel", {
		Size             = UDim2.new(0, 400, 0, 40),
		Position         = UDim2.new(0.5, -200, 0.5, -30),
		BackgroundTransparency = 1,
		Text             = loadTitle,
		TextColor3       = THEME.Text,
		Font             = Enum.Font.GothamBold,
		TextSize         = 24,
		ZIndex           = 101,
	}, loadFrame)

	local loadSub_ = make("TextLabel", {
		Size             = UDim2.new(0, 400, 0, 24),
		Position         = UDim2.new(0.5, -200, 0.5, 10),
		BackgroundTransparency = 1,
		Text             = loadSub,
		TextColor3       = THEME.SubText,
		Font             = Enum.Font.Gotham,
		TextSize         = 13,
		ZIndex           = 101,
	}, loadFrame)

	local loadBarBg = make("Frame", {
		Size             = UDim2.new(0, 260, 0, 4),
		Position         = UDim2.new(0.5, -130, 0.5, 46),
		BackgroundColor3 = THEME.Card,
		BorderSizePixel  = 0,
		ZIndex           = 101,
	}, loadFrame)
	addCorner(loadBarBg, 2)

	local loadBar = make("Frame", {
		Size             = UDim2.new(0, 0, 0, 4),
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 102,
	}, loadBarBg)
	addCorner(loadBar, 2)

	task.spawn(function()
		tween(loadBar, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0) })
		task.wait(0.8)
		tween(loadFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
		tween(loadTitle_, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })
		tween(loadSub_, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })
		tween(loadBarBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
		tween(loadBar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
		task.wait(0.25)
		loadFrame:Destroy()
	end)

	-- Main Sizing Framework Configuration
	local window = make("Frame", {
		Name             = "Window",
		Size             = UDim2.new(0, 500, 0, 330), -- Polished smaller and compact proportions
		Position         = UDim2.new(0.5, -250, 0.5, -165),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
	}, gui)
	addCorner(window, 9)
	addStroke(window, THEME.Stroke, 1)

	local titleBar = make("Frame", {
		Name             = "TitleBar",
		Size             = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel  = 0,
	}, window)

	local titleLabel = make("TextLabel", {
		Size             = UDim2.new(1, -140, 1, 0),
		Position         = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		Text             = windowName,
		TextColor3       = THEME.Text,
		Font             = Enum.Font.GothamBold,
		TextSize         = 14,
		TextXAlignment   = Enum.TextXAlignment.Left,
	}, titleBar)

	local sidebar = make("Frame", {
		Name             = "Sidebar",
		Size             = UDim2.new(0, 130, 1, -44),
		Position         = UDim2.new(0, 0, 0, 44),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel  = 0,
	}, window)

	local content = make("Frame", {
		Name             = "Content",
		Size             = UDim2.new(1, -130, 1, -44),
		Position         = UDim2.new(0, 130, 0, 44),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
	}, window)

	local borderLine = make("Frame", {
		Size             = UDim2.new(0, 1, 1, -44),
		Position         = UDim2.new(0, 130, 0, 44),
		BackgroundColor3 = THEME.Stroke,
		BorderSizePixel  = 0,
	}, window)

	local function makeControlBtn(text, xOffset, callback)
		local btn = make("TextButton", {
			Size             = UDim2.new(0, 24, 0, 24),
			Position         = UDim2.new(1, xOffset, 0.5, -12),
			BackgroundColor3 = THEME.Card,
			Text             = text,
			TextColor3       = THEME.Text,
			Font             = Enum.Font.GothamBold,
			TextSize         = 13,
			BorderSizePixel  = 0,
		}, titleBar)
		addCorner(btn, 6)
		addStroke(btn, THEME.Stroke, 1)
		btn.MouseButton1Click:Connect(callback)
		btn.MouseEnter:Connect(function()
			tween(btn, FAST, { BackgroundColor3 = THEME.Accent, TextColor3 = THEME.Background })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, FAST, { BackgroundColor3 = THEME.Card, TextColor3 = THEME.Text })
		end)
		return btn
	end

	-- Minimize & Close System Callback Implementations
	local minimized = false
	local closeBtn  = makeControlBtn("×", -12,  function() gui:Destroy() end)
	local minBtn    = makeControlBtn("−", -42, function()
		minimized = not minimized
		
		-- Hide layout blocks gracefully during minimizing transformations
		if minimized then
			sidebar.Visible = false
			content.Visible = false
			borderLine.Visible = false
			tween(window, FAST, { Size = UDim2.new(0, 500, 0, 44) })
		else
			tween(window, FAST, { Size = UDim2.new(0, 500, 0, 330) })
			task.delay(0.1, function()
				sidebar.Visible = true
				content.Visible = true
				borderLine.Visible = true
			end)
		end
	end)

	-- Dragging Architecture Handler Implementation
	local dragging, dragStart, startPos = false, nil, nil
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			dragStart = input.Position
			startPos  = window.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	make("UIListLayout", {
		SortOrder       = Enum.SortOrder.LayoutOrder,
		Padding         = UDim.new(0, 3),
		FillDirection   = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, sidebar)
	addPadding(sidebar, 6, 6, 6, 6)

	local windowObj = {
		_gui      = gui,
		_window   = window,
		_sidebar  = sidebar,
		_content  = content,
		_tabs     = {},
		_active   = nil,
	}

	-- Notifications Layout Array
	local notifContainer = make("Frame", {
		Name             = "Notifications",
		Size             = UDim2.new(0, 260, 1, 0),
		Position         = UDim2.new(1, -270, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
	}, gui)

	make("UIListLayout", {
		SortOrder       = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding         = UDim.new(0, 6),
	}, notifContainer)
	addPadding(notifContainer, 12, 12, 12, 12)

	-- ── Tab Module Creation Logic ──
	function windowObj:CreateTab(name)
		local isFirst = #self._tabs == 0

		local tabBtn = make("TextButton", {
			Size             = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = isFirst and THEME.Card or Color3.fromRGB(0,0,0),
			BackgroundTransparency = isFirst and 0 or 1,
			Text             = name,
			TextColor3       = isFirst and THEME.Text or THEME.SubText,
			Font             = Enum.Font.GothamSemibold,
			TextSize         = 12,
			BorderSizePixel  = 0,
			LayoutOrder      = #self._tabs + 1,
		}, sidebar)
		addCorner(tabBtn, 5)

		local page = make("ScrollingFrame", {
			Name             = "Page_" .. name,
			Size             = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel  = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = THEME.Stroke,
			Visible          = isFirst,
			CanvasSize       = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, content)

		local listLayout = make("UIListLayout", {
			SortOrder     = Enum.SortOrder.LayoutOrder,
			Padding       = UDim.new(0, 6),
			FillDirection = Enum.FillDirection.Vertical,
		}, page)
		addPadding(page, 10, 10, 10, 10)

		local tabObj = {
			_page    = page,
			_btn     = tabBtn,
			_window  = self,
			_order   = 0,
		}

		local allTabs = self._tabs
		table.insert(allTabs, tabObj)

		tabBtn.MouseButton1Click:Connect(function()
			for _, t in ipairs(allTabs) do
				local active = (t == tabObj)
				t._page.Visible = active
				tween(t._btn, FAST, {
					BackgroundColor3       = active and THEME.Card or Color3.fromRGB(0,0,0),
					BackgroundTransparency = active and 0 or 1,
					TextColor3             = active and THEME.Text or THEME.SubText,
				})
			end
		end)

		local function newCard(height)
			tabObj._order += 1
			local card = make("Frame", {
				Size             = UDim2.new(1, 0, 0, height),
				BackgroundColor3 = THEME.Surface,
				BorderSizePixel  = 0,
				LayoutOrder      = tabObj._order,
			}, page)
			addCorner(card, 6)
			addStroke(card, THEME.Stroke, 1)
			return card
		end

		function tabObj:CreateSection(name)
			tabObj._order += 1
			local sectionFrame = make("Frame", {
				Size             = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				LayoutOrder      = tabObj._order,
			}, page)

			make("TextLabel", {
				Size             = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text             = name:upper(),
				TextColor3       = THEME.SubText,
				Font             = Enum.Font.GothamBold,
				TextSize         = 10,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, sectionFrame)
		end

		function tabObj:CreateToggle(settings)
			local name    = settings.Name         or "Toggle"
			local current = settings.CurrentValue or false
			local flag    = settings.Flag
			local cb      = settings.Callback     or function() end

			if flag and CyphraUI._flags[flag] ~= nil then
				current = CyphraUI._flags[flag]
			end

			local card = newCard(38)

			make("TextLabel", {
				Size             = UDim2.new(1, -60, 1, 0),
				Position         = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text             = name,
				TextColor3       = THEME.Text,
				Font             = Enum.Font.Gotham,
				TextSize         = 13,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, card)

			local pill = make("Frame", {
				Size             = UDim2.new(0, 34, 0, 18),
				Position         = UDim2.new(1, -46, 0.5, -9),
				BackgroundColor3 = current and THEME.Accent or THEME.Card,
				BorderSizePixel  = 0,
			}, card)
			addCorner(pill, 9)
			addStroke(pill, THEME.Stroke, 1)

			local knob = make("Frame", {
				Size             = UDim2.new(0, 14, 0, 14),
				Position         = current and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
				BackgroundColor3 = current and THEME.Background or THEME.SubText,
				BorderSizePixel  = 0,
			}, pill)
			addCorner(knob, 7)

			local toggleObj = { CurrentValue = current }
			if flag then CyphraUI._flags[flag] = current end

			local function setState(val, fire)
				toggleObj.CurrentValue = val
				if flag then CyphraUI._flags[flag] = val end
				tween(pill, FAST, { BackgroundColor3 = val and THEME.Accent or THEME.Card })
				tween(knob, FAST, { 
					Position = val and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
					BackgroundColor3 = val and THEME.Background or THEME.SubText
				})
				if fire then pcall(cb, val) end
			end

			local btn = make("TextButton", {
				Size             = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text             = "",
			}, card)
			btn.MouseButton1Click:Connect(function()
				setState(not toggleObj.CurrentValue, true)
			end)

			return toggleObj
		end

		function tabObj:CreateSlider(settings)
			local name    = settings.Name         or "Slider"
			local range   = settings.Range        or {0, 100}
			local min_v   = range[1] or 0
			local max_v   = range[2] or 100
			local inc     = settings.Increment    or 1
			local current = settings.CurrentValue or min_v
			local flag    = settings.Flag
			local cb      = settings.Callback     or function() end

			if flag and CyphraUI._flags[flag] ~= nil then
				current = CyphraUI._flags[flag]
			end
			current = math.clamp(current, min_v, max_v)

			local card = newCard(48)

			local nameLabel = make("TextLabel", {
				Size             = UDim2.new(1, -24, 0, 20),
				Position         = UDim2.new(0, 12, 0, 4),
				BackgroundTransparency = 1,
				Text             = name,
				TextColor3       = THEME.Text,
				Font             = Enum.Font.Gotham,
				TextSize         = 13,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, card)

			local valueLabel = make("TextLabel", {
				Size             = UDim2.new(0, 60, 0, 20),
				Position         = UDim2.new(1, -72, 0, 4),
				BackgroundTransparency = 1,
				Text             = tostring(current),
				TextColor3       = THEME.SubText,
				Font             = Enum.Font.Code,
				TextSize         = 12,
				TextXAlignment   = Enum.TextXAlignment.Right,
			}, card)

			local track = make("Frame", {
				Size             = UDim2.new(1, -24, 0, 4),
				Position         = UDim2.new(0, 12, 0, 32),
				BackgroundColor3 = THEME.Card,
				BorderSizePixel  = 0,
			}, card)
			addCorner(track, 2)

			local fill = make("Frame", {
				Size             = UDim2.new((current - min_v) / (max_v - min_v), 0, 1, 0),
				BackgroundColor3 = THEME.Accent,
				BorderSizePixel  = 0,
			}, track)
			addCorner(fill, 2)

			local sliderObj = { CurrentValue = current }
			if flag then CyphraUI._flags[flag] = current end

			local function setValue(val, fire)
				if inc > 0 then
					val = math.round((val - min_v) / inc) * inc + min_v
				end
				val = math.clamp(val, min_v, max_v)
				sliderObj.CurrentValue = val
				if flag then CyphraUI._flags[flag] = val end
				valueLabel.Text = tostring(val)
				tween(fill, FAST, { Size = UDim2.new((val - min_v) / (max_v - min_v), 0, 1, 0) })
				if fire then pcall(cb, val) end
			end

			local draggingSlider = false
			local function updateSlider(input)
				local trackPos  = track.AbsolutePosition.X
				local trackSize = track.AbsoluteSize.X
				local rel       = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
				setValue(min_v + rel * (max_v - min_v), true)
			end

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingSlider = true
					updateSlider(input)
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateSlider(input)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingSlider = false
				end
			end)

			return sliderObj
		end

		function tabObj:CreateButton(settings)
			local name = settings.Name     or "Button"
			local cb   = settings.Callback or function() end

			tabObj._order += 1
			local btn = make("TextButton", {
				Size             = UDim2.new(1, 0, 0, 34),
				BackgroundColor3 = THEME.Card,
				Text             = name,
				TextColor3       = THEME.Text,
				Font             = Enum.Font.GothamSemibold,
				TextSize         = 13,
				BorderSizePixel  = 0,
				LayoutOrder      = tabObj._order,
			}, page)
			addCorner(btn, 6)
			addStroke(btn, THEME.Stroke, 1)

			btn.MouseEnter:Connect(function() tween(btn, FAST, { BackgroundColor3 = THEME.Stroke }) end)
			btn.MouseLeave:Connect(function() tween(btn, FAST, { BackgroundColor3 = THEME.Card }) end)
			btn.MouseButton1Click:Connect(function() pcall(cb) end)
		end

		function tabObj:CreateDropdown(settings)
			local name    = settings.Name          or "Dropdown"
			local options = settings.Options        or {}
			local current = settings.CurrentOption  or ""
			local flag    = settings.Flag
			local cb      = settings.Callback       or function() end

			if flag and CyphraUI._flags[flag] ~= nil then
				current = CyphraUI._flags[flag]
			end

			tabObj._order += 1

			local wrapper = make("Frame", {
				Size             = UDim2.new(1, 0, 0, 38),
				BackgroundTransparency = 1,
				LayoutOrder      = tabObj._order,
			}, page)

			local hCard = make("Frame", {
				Size             = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = THEME.Surface,
				BorderSizePixel  = 0,
			}, wrapper)
			addCorner(hCard, 6)
			addStroke(hCard, THEME.Stroke, 1)

			make("TextLabel", {
				Size             = UDim2.new(0.5, 0, 1, 0),
				Position         = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text             = name,
				TextColor3       = THEME.Text,
				Font             = Enum.Font.Gotham,
				TextSize         = 13,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, hCard)

			local sLabel = make("TextLabel", {
				Size             = UDim2.new(0.5, -12, 1, 0),
				Position         = UDim2.new(0.5, 0, 0, 0),
				BackgroundTransparency = 1,
				Text             = (current == "" and "Select Options" or current) .. "  ▼",
				TextColor3       = THEME.SubText,
				Font             = Enum.Font.Gotham,
				TextSize         = 12,
				TextXAlignment   = Enum.TextXAlignment.Right,
			}, hCard)

			local listFrame = make("Frame", {
				Size             = UDim2.new(1, 0, 0, #options * 28),
				Position         = UDim2.new(0, 0, 0, 42),
				BackgroundColor3 = THEME.Card,
				BorderSizePixel  = 0,
				Visible          = false,
				ZIndex           = 15,
			}, wrapper)
			addCorner(listFrame, 6)
			addStroke(listFrame, THEME.Stroke, 1)

			make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, listFrame)

			local dropObj = { CurrentOption = current }
			local expanded = false
			if flag then CyphraUI._flags[flag] = current end

			for i, opt in ipairs(options) do
				local oBtn = make("TextButton", {
					Size             = UDim2.new(1, 0, 0, 28),
					BackgroundTransparency = 1,
					Text             = opt,
					TextColor3       = THEME.Text,
					Font             = Enum.Font.Gotham,
					TextSize         = 12,
					LayoutOrder      = i,
					ZIndex           = 16,
				}, listFrame)

				oBtn.MouseEnter:Connect(function() oBtn.BackgroundTransparency = 0.9 oBtn.BackgroundColor3 = THEME.Accent end)
				oBtn.MouseLeave:Connect(function() oBtn.BackgroundTransparency = 1 end)
				oBtn.MouseButton1Click:Connect(function()
					dropObj.CurrentOption = opt
					if flag then CyphraUI._flags[flag] = opt end
					sLabel.Text = opt .. "  ▼"
					expanded = false
					listFrame.Visible = false
					wrapper.Size = UDim2.new(1, 0, 0, 38)
					pcall(cb, opt)
				end)
			end

			local hBtn = make("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, hCard)
			hBtn.MouseButton1Click:Connect(function()
				expanded = not expanded
				listFrame.Visible = expanded
				if expanded then
					wrapper.Size = UDim2.new(1, 0, 0, 42 + (#options * 28))
					sLabel.Text = (dropObj.CurrentOption == "" and "Select Options" or dropObj.CurrentOption) .. "  ▲"
				else
					wrapper.Size = UDim2.new(1, 0, 0, 38)
					sLabel.Text = (dropObj.CurrentOption == "" and "Select Options" or dropObj.CurrentOption) .. "  ▼"
				end
			end)

			return dropObj
		end

		function tabObj:CreateColorPicker(settings)
			local name  = settings.Name     or "Color Picker"
			local color = settings.Color    or THEME.Accent
			local flag  = settings.Flag
			local cb    = settings.Callback or function() end

			if flag and CyphraUI._flags[flag] ~= nil then
				local cached = CyphraUI._flags[flag]
				color = Color3.new(cached[1], cached[2], cached[3])
			end

			local card = newCard(72)

			make("TextLabel", {
				Size             = UDim2.new(1, -60, 0, 34),
				Position         = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text             = name,
				TextColor3       = THEME.Text,
				Font             = Enum.Font.Gotham,
				TextSize         = 13,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, card)

			local cCircle = make("Frame", {
				Size             = UDim2.new(0, 18, 0, 18),
				Position         = UDim2.new(1, -32, 0, 8),
				BackgroundColor3 = color,
				BorderSizePixel  = 0,
			}, card)
			addCorner(cCircle, 9)

			local rgbBox = make("TextBox", {
				Size             = UDim2.new(1, -24, 0, 24),
				Position         = UDim2.new(0, 12, 0, 38),
				BackgroundColor3 = THEME.Card,
				Text             = math.floor(color.R * 255) .. ", " .. math.floor(color.G * 255) .. ", " .. math.floor(color.B * 255),
				TextColor3       = THEME.Text,
				Font             = Enum.Font.Code,
				TextSize         = 11,
				ClearTextOnFocus = false,
				BorderSizePixel  = 0,
			}, card)
			addCorner(rgbBox, 5)
			addStroke(rgbBox, THEME.Stroke, 1)

			local cpObj = { Color = color }
			if flag then CyphraUI._flags[flag] = { color.R, color.G, color.B } end

			local function setColor(c, fire)
				cpObj.Color = c
				cCircle.BackgroundColor3 = c
				if flag then CyphraUI._flags[flag] = { c.R, c.G, c.B } end
				if fire then pcall(cb, c) end
			end

			rgbBox.FocusLost:Connect(function()
				local r, g, b = rgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
				if r and g and b then
					local c = Color3.fromRGB(math.clamp(tonumber(r),0,255), math.clamp(tonumber(g),0,255), math.clamp(tonumber(b),0,255))
					setColor(c, true)
				else
					rgbBox.Text = math.floor(cpObj.Color.R * 255) .. ", " .. math.floor(cpObj.Color.G * 255) .. ", " .. math.floor(cpObj.Color.B * 255)
				end
			end)

			return cpObj
		end

		return tabObj
	end

	-- ── Toast Popup System ──
	function windowObj:Notify(settings)
		local title    = settings.Title    or "System"
		local content  = settings.Content  or ""
		local duration = settings.Duration or 3

		local notif = make("Frame", {
			Size             = UDim2.new(1, 0, 0, 50),
			BackgroundColor3 = THEME.Surface,
			BorderSizePixel  = 0,
		}, notifContainer)
		addCorner(notif, 6)
		addStroke(notif, THEME.Stroke, 1)

		local bar = make("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0 }, notif)
		addCorner(bar, 1)

		make("TextLabel", {
			Size             = UDim2.new(1, -20, 0, 20),
			Position         = UDim2.new(0, 12, 0, 6),
			BackgroundTransparency = 1,
			Text             = title,
			TextColor3       = THEME.Text,
			Font             = Enum.Font.GothamBold,
			TextSize         = 12,
			TextXAlignment   = Enum.TextXAlignment.Left,
		}, notif)

		make("TextLabel", {
			Size             = UDim2.new(1, -20, 0, 18),
			Position         = UDim2.new(0, 12, 0, 24),
			BackgroundTransparency = 1,
			Text             = content,
			TextColor3       = THEME.SubText,
			Font             = Enum.Font.Gotham,
			TextSize         = 11,
			TextXAlignment   = Enum.TextXAlignment.Left,
		}, notif)

		notif.Size = UDim2.new(0, 0, 0, 50)
		tween(notif, FAST, { Size = UDim2.new(1, 0, 0, 50) })

		task.delay(duration, function()
			tween(notif, FAST, { BackgroundTransparency = 1 })
			task.wait(0.15)
			notif:Destroy()
		end)
	end

	function windowObj:Destroy()
		pcall(function() gui:Destroy() end)
	end

	if configOpts.Enabled then
		task.defer(function() CyphraUI:LoadConfiguration() end)
	end

	return windowObj
end

-- ─── SaveConfiguration ───────────────────────────────────────────────────────

function CyphraUI:SaveConfiguration()
	local opts = CyphraUI._configOpts
	if not opts or not opts.Enabled then return end
	local folder = opts.FolderName or "CyphraUI"
	local file   = opts.FileName   or "config"
	pcall(function()
		if not isfolder(folder) then makefolder(folder) end
		writefile(folder .. "/" .. file .. ".json", jsonEncode(CyphraUI._flags))
	end)
end

-- ─── LoadConfiguration ───────────────────────────────────────────────────────

function CyphraUI:LoadConfiguration()
	local opts = CyphraUI._configOpts
	if not opts or not opts.Enabled then return end
	local folder = opts.FolderName or "CyphraUI"
	local file   = opts.FileName   or "config"
	pcall(function()
		if isfile(folder .. "/" .. file .. ".json") then
			local data = jsonDecode(readfile(folder .. "/" .. file .. ".json"))
			for k, v in pairs(data) do
				CyphraUI._flags[k] = v
			end
		end
	end)
end

return CyphraUI
