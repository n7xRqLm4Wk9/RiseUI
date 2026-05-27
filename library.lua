--[[
	CyphraUI - Custom Roblox UI Library
	Version 1.0.0
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

-- ─── Theme ───────────────────────────────────────────────────────────────────

local THEME = {
	Background = Color3.fromRGB(26, 26, 46),   -- #1a1a2e
	Surface    = Color3.fromRGB(22, 33, 62),   -- #16213e
	Card       = Color3.fromRGB(15, 52, 96),   -- #0f3460
	Accent     = Color3.fromRGB(233, 69, 96),  -- #e94560
	Text       = Color3.fromRGB(238, 238, 238),-- #eeeeee
	SubText    = Color3.fromRGB(136, 136, 136),-- #888888
	Stroke     = Color3.fromRGB(50, 50, 70),
	Success    = Color3.fromRGB(76, 175, 80),  -- #4caf50
}

-- ─── Tween helpers ───────────────────────────────────────────────────────────

local function tween(obj, info, goals)
	TweenService:Create(obj, info, goals):Play()
end

local FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local MEDIUM = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local SLOW   = TweenInfo.new(0.30, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- ─── UI helpers ──────────────────────────────────────────────────────────────

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

-- ─── Config helpers ──────────────────────────────────────────────────────────

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
		elseif tonumber(v) then
			result[k] = tonumber(v)
		else
			result[k] = v:match('"(.*)"') or v
		end
	end
	return result
end

-- ─── Library object ──────────────────────────────────────────────────────────

local CyphraUI = {}
CyphraUI.__index = CyphraUI

CyphraUI._flags      = {}
CyphraUI._configOpts = {}

-- ─── CreateWindow ────────────────────────────────────────────────────────────

function CyphraUI:CreateWindow(settings)
	local windowName    = settings.Name           or "CyphraUI"
	local loadTitle     = settings.LoadingTitle   or "Loading..."
	local loadSub       = settings.LoadingSubtitle or ""
	local configOpts    = settings.ConfigurationSaving or { Enabled = false }

	CyphraUI._configOpts = configOpts

	local gui = make("ScreenGui", {
		Name           = "CyphraUI",
		ResetOnSpawn   = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not ok then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	local loadFrame = make("Frame", {
		Name            = "LoadFrame",
		Size            = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		ZIndex          = 100,
	}, gui)

	local loadTitle_ = make("TextLabel", {
		Size             = UDim2.new(0, 400, 0, 40),
		Position         = UDim2.new(0.5, -200, 0.5, -40),
		BackgroundTransparency = 1,
		Text             = loadTitle,
		TextColor3       = THEME.Text,
		Font             = Enum.Font.GothamBold,
		TextSize         = 22,
		ZIndex           = 101,
	}, loadFrame)

	local loadSub_ = make("TextLabel", {
		Size             = UDim2.new(0, 400, 0, 24),
		Position         = UDim2.new(0.5, -200, 0.5, 8),
		BackgroundTransparency = 1,
		Text             = loadSub,
		TextColor3       = THEME.SubText,
		Font             = Enum.Font.Gotham,
		TextSize         = 14,
		ZIndex           = 101,
	}, loadFrame)

	local loadBar = make("Frame", {
		Size             = UDim2.new(0, 0, 0, 3),
		Position         = UDim2.new(0.5, -150, 0.5, 46),
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 101,
	}, loadFrame)
	addCorner(loadBar, 2)

	task.spawn(function()
		tween(loadBar, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 300, 0, 3) })
		task.wait(1)
		tween(loadFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 })
		task.wait(0.4)
		loadFrame:Destroy()
	end)

	local shadow = make("ImageLabel", {
		Name             = "Shadow",
		Size             = UDim2.new(0, 620, 0, 440),
		Position         = UDim2.new(0.5, -310, 0.5, -200),
		BackgroundTransparency = 1,
		Image            = "rbxassetid://1316045217",
		ImageColor3      = Color3.new(0, 0, 0),
		ImageTransparency = 0.5,
		ScaleType        = Enum.ScaleType.Slice,
		SliceCenter      = Rect.new(10, 10, 118, 118),
		ZIndex           = 0,
	}, gui)

	local window = make("Frame", {
		Name             = "Window",
		Size             = UDim2.new(0, 580, 0, 400),
		Position         = UDim2.new(0.5, -290, 0.5, -200),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
	}, gui)
	addCorner(window, 12)
	addStroke(window, THEME.Stroke, 1)

	local grad = make("UIGradient", {
		Rotation = 90,
		Color    = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 58)),
			ColorSequenceKeypoint.new(1, THEME.Background),
		}),
	}, window)

	local titleBar = make("Frame", {
		Name             = "TitleBar",
		Size             = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel  = 0,
	}, window)

	local dot = make("Frame", {
		Size             = UDim2.new(0, 8, 0, 8),
		Position         = UDim2.new(0, 14, 0.5, -4),
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel  = 0,
	}, titleBar)
	addCorner(dot, 4)

	local titleLabel = make("TextLabel", {
		Size             = UDim2.new(1, -140, 1, 0),
		Position         = UDim2.new(0, 30, 0, 0),
		BackgroundTransparency = 1,
		Text             = windowName,
		TextColor3       = THEME.Text,
		Font             = Enum.Font.GothamBold,
		TextSize         = 15,
		TextXAlignment   = Enum.TextXAlignment.Left,
	}, titleBar)

	local versionBadge = make("TextLabel", {
		Size             = UDim2.new(0, 36, 0, 18),
		Position         = UDim2.new(0, titleLabel.Position.X.Offset + 4, 0.5, -9),
		BackgroundColor3 = THEME.Card,
		Text             = "v1.0",
		TextColor3       = THEME.SubText,
		Font             = Enum.Font.Gotham,
		TextSize         = 11,
	}, titleBar)
	addCorner(versionBadge, 4)

	local function makeControlBtn(text, xOffset, callback)
		local btn = make("TextButton", {
			Size             = UDim2.new(0, 28, 0, 28),
			Position         = UDim2.new(1, xOffset, 0.5, -14),
			BackgroundColor3 = THEME.Card,
			Text             = text,
			TextColor3       = THEME.Text,
			Font             = Enum.Font.GothamBold,
			TextSize         = 14,
			BorderSizePixel  = 0,
		}, titleBar)
		addCorner(btn, 6)
		btn.MouseButton1Click:Connect(callback)
		btn.MouseEnter:Connect(function()
			tween(btn, FAST, { BackgroundColor3 = THEME.Accent })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, FAST, { BackgroundColor3 = THEME.Card })
		end)
		return btn
	end

	local minimized = false
	local closeBtn  = makeControlBtn("×", -8,  function() gui:Destroy() end)
	local minBtn    = makeControlBtn("−", -42, function()
		minimized = not minimized
		tween(window, MEDIUM, {
			Size = minimized and UDim2.new(0, 580, 0, 44) or UDim2.new(0, 580, 0, 400)
		})
	end)

	local dragging, dragStart, startPos = false, nil, nil

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			dragStart = input.Position
			startPos  = window.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
			shadow.Position = UDim2.new(
				window.Position.X.Scale, window.Position.X.Offset - 20,
				window.Position.Y.Scale, window.Position.Y.Offset - 20
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	local sidebar = make("Frame", {
		Name             = "Sidebar",
		Size             = UDim2.new(0, 140, 1, -44),
		Position         = UDim2.new(0, 0, 0, 44),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel  = 0,
	}, window)

	make("UIListLayout", {
		SortOrder       = Enum.SortOrder.LayoutOrder,
		Padding         = UDim.new(0, 2),
		FillDirection   = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, sidebar)

	addPadding(sidebar, 6, 4, 6, 4)

	local content = make("Frame", {
		Name             = "Content",
		Size             = UDim2.new(1, -140, 1, -44),
		Position         = UDim2.new(0, 140, 0, 44),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
	}, window)

	make("Frame", {
		Size             = UDim2.new(0, 1, 1, -44),
		Position         = UDim2.new(0, 140, 0, 44),
		BackgroundColor3 = THEME.Stroke,
		BorderSizePixel  = 0,
	}, window)

	local windowObj = {
		_gui      = gui,
		_window   = window,
		_sidebar  = sidebar,
		_content  = content,
		_tabs     = {},
		_active   = nil,
	}

	local notifContainer = make("Frame", {
		Name             = "Notifications",
		Size             = UDim2.new(0, 280, 1, 0),
		Position         = UDim2.new(1, -290, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
	}, gui)

	make("UIListLayout", {
		SortOrder       = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding         = UDim.new(0, 6),
		FillDirection   = Enum.FillDirection.Vertical,
	}, notifContainer)

	addPadding(notifContainer, 12, 0, 12, 0)

	function windowObj:CreateTab(name)
		local isFirst = #self._tabs == 0

		local tabBtn = make("TextButton", {
			Size             = UDim2.new(1, -8, 0, 32),
			BackgroundColor3 = isFirst and THEME.Accent or Color3.fromRGB(0,0,0),
			BackgroundTransparency = isFirst and 0 or 1,
			Text             = name,
			TextColor3       = isFirst and THEME.Text or THEME.SubText,
			Font             = Enum.Font.GothamSemibold,
			TextSize         = 13,
			BorderSizePixel  = 0,
			LayoutOrder      = #self._tabs + 1,
		}, sidebar)
		addCorner(tabBtn, 6)

		local page = make("ScrollingFrame", {
			Name             = "Page_" .. name,
			Size             = UDim2.new(1, 0, 1, 0),
			Position         = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel  = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = THEME.Accent,
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
					BackgroundColor3       = active and THEME.Accent or Color3.fromRGB(0,0,0),
					BackgroundTransparency = active and 0 or 1,
					TextColor3             = active and THEME.Text or THEME.SubText,
				})
			end
		end)

		tabBtn.MouseEnter:Connect(function()
			if tabObj._page.Visible then return end
			tween(tabBtn, FAST, { BackgroundTransparency = 0.7, BackgroundColor3 = THEME.Card })
		end)
		tabBtn.MouseLeave:Connect(function()
			if tabObj._page.Visible then return end
			tween(tabBtn, FAST, { BackgroundTransparency = 1 })
		end)

		local function newCard(height)
			tabObj._order += 1
			local card = make("Frame", {
				Size             = UDim2.new(1, 0, 0, height),
				BackgroundColor3 = THEME.Card,
				BorderSizePixel  = 0,
				LayoutOrder      = tabObj._order,
				AutomaticSize    = Enum.AutomaticSize.Y,
			}, page)
			addCorner(card, 8)
			addStroke(card, THEME.Stroke, 1)
			return card
		end

		function tabObj:CreateSection(name)
			tabObj._order += 1
			local sectionFrame = make("Frame", {
				Size             = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				LayoutOrder      = tabObj._order,
			}, page)

			make("TextLabel", {
				Size             = UDim2.new(1, -16, 1, -8),
				Position         = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				Text             = name:upper(),
				TextColor3       = THEME.Accent,
				Font             = Enum.Font.GothamBold,
				TextSize         = 11,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, sectionFrame)

			make("Frame", {
				Size             = UDim2.new(1, -16, 0, 1),
				Position         = UDim2.new(0, 8, 1, -1),
				BackgroundColor3 = THEME.Accent,
				BackgroundTransparency = 0.6,
				BorderSizePixel  = 0,
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

			local card = newCard(40)
			card.AutomaticSize = Enum.AutomaticSize.None

			make("TextLabel", {
				Size             = UDim2.new(1, -70, 1, 0),
				Position         = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text             = name,
				TextColor3       = THEME.Text,
				Font             = Enum.Font.Gotham,
				TextSize         = 13,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, card)

			local pill = make("Frame", {
				Size             = UDim2.new(0, 40, 0, 20),
				Position         = UDim2.new(1, -52, 0.5, -10),
				BackgroundColor3 = current and THEME.Accent or THEME.Stroke,
				BorderSizePixel  = 0,
			}, card)
			addCorner(pill, 10)

			local knob = make("Frame", {
				Size             = UDim2.new(0, 16, 0, 16),
				Position         = current and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
				BackgroundColor3 = THEME.Text,
				BorderSizePixel  = 0,
			}, pill)
			addCorner(knob, 8)

			local toggleObj = { CurrentValue = current }

			if flag then CyphraUI._flags[flag] = current end

			local function setState(val, fire)
				toggleObj.CurrentValue = val
				if flag then CyphraUI._flags[flag] = val end
				tween(pill, FAST, { BackgroundColor3 = val and THEME.Accent or THEME.Stroke })
				tween(knob, FAST, { Position = val and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) })
				if fire then pcall(cb, val) end
			end

			local btn = make("TextButton", {
				Size             = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text             = "",
				BorderSizePixel  = 0,
			}, card)
			btn.MouseButton1Click:Connect(function()
				setState(not toggleObj.CurrentValue, true)
			end)

			return toggleObj
		end

		function tabObj:CreateSlider(settings)
			local name    = settings.Name         or "Slider"
			local range   = settings.Range        or {16, 200}
			local min_v   = range[1] or range.Min or 0
			local max_v   = range[2] or range.Max or 100
			local inc     = settings.Increment    or 1
			local current = settings.CurrentValue or min_v
			local flag    = settings.Flag
			local cb      = settings.Callback     or function() end

			if flag and CyphraUI._flags[flag] ~= nil then
				current = CyphraUI._flags[flag]
			end
			current = math.clamp(current, min_v, max_v)

			local card = newCard(54)
			card.AutomaticSize = Enum.AutomaticSize.None

			local nameLabel = make("TextLabel", {
				Size             = UDim2.new(1, -16, 0, 20),
				Position         = UDim2.new(0, 12, 0, 6),
				BackgroundTransparency = 1,
				Text             = name .. ": " .. tostring(current),
				TextColor3       = THEME.Text,
				Font             = Enum.Font.Gotham,
				TextSize         = 13,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, card)

			local track = make("Frame", {
				Size             = UDim2.new(1, -24, 0, 6),
				Position         = UDim2.new(0, 12, 0, 34),
				BackgroundColor3 = THEME.Stroke,
				BorderSizePixel  = 0,
			}, card)
			addCorner(track, 3)

			local fill = make("Frame", {
				Size             = UDim2.new((current - min_v) / (max_v - min_v), 0, 1, 0),
				BackgroundColor3 = THEME.Accent,
				BorderSizePixel  = 0,
			}, track)
			addCorner(fill, 3)

			local sliderObj = { CurrentValue = current }
			if flag then CyphraUI._flags[flag] = current end

			local function setValue(val, fire)
				if inc > 0 then
					val = math.round((val - min_v) / inc) * inc + min_v
				end
				val = math.clamp(val, min_v, max_v)
				sliderObj.CurrentValue = val
				if flag then CyphraUI._flags[flag] = val end
				nameLabel.Text = name .. ": " .. tostring(val)
				tween(fill, FAST, { Size = UDim2.new((val - min_v) / (max_v - min_v), 0, 1, 0) })
				if fire then pcall(cb, val) end
			end

			local draggingSlider = false

			local function getValueFromInput(input)
				local trackPos  = track.AbsolutePosition.X
				local trackSize = track.AbsoluteSize.X
				local rel       = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
				return min_v + rel * (max_v - min_v)
			end

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
					draggingSlider = true
					setValue(getValueFromInput(input), true)
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if not draggingSlider then return end
				if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then
					setValue(getValueFromInput(input), true)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
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
				Size             = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = THEME.Accent,
				Text             = name,
				TextColor3       = THEME.Text,
				Font             = Enum.Font.GothamBold,
				TextSize         = 13,
				BorderSizePixel  = 0,
				LayoutOrder      = tabObj._order,
			}, page)
			addCorner(btn, 6)

			btn.MouseEnter:Connect(function()
				tween(btn, FAST, { BackgroundColor3 = Color3.fromRGB(
					math.min(255, THEME.Accent.R * 255 + 20),
					math.min(255, THEME.Accent.G * 255 + 20),
					math.min(255, THEME.Accent.B * 255 + 20)
				)})
			end)
			btn.MouseLeave:Connect(function()
				tween(btn, FAST, { BackgroundColor3 = THEME.Accent })
			end)
			btn.MouseButton1Click:Connect(function()
				pcall(cb)
			end)
		end

		function tabObj:CreateDropdown(settings)
			local name    = settings.Name          or "Dropdown"
			local options = settings.Options        or {}
			local current = settings.CurrentOption  or (options[1] or "")
			local flag    = settings.Flag
			local cb      = settings.Callback       or function() end

			if flag and CyphraUI._flags[flag] ~= nil then
				current = CyphraUI._flags[flag]
			end

			tabObj._order += 1

			local wrapper = make("Frame", {
				Size             = UDim2.new(1, 0, 0, 40),
				BackgroundTransparency = 1,
				BorderSizePixel  = 0,
				LayoutOrder      = tabObj._order,
				ClipsDescendants = false,
			}, page)

			local headerCard = make("Frame", {
				Size             = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = THEME.Card,
				BorderSizePixel  = 0,
			}, wrapper)
			addCorner(headerCard, 8)
			addStroke(headerCard, THEME.Stroke, 1)

			make("TextLabel", {
				Size             = UDim2.new(0.5, 0, 1, 0),
				Position         = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text             = name,
				TextColor3       = THEME.Text,
				Font             = Enum.Font.Gotham,
				TextSize         = 13,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, headerCard)

			local selectedLabel = make("TextLabel", {
				Size             = UDim2.new(0.45, -24, 1, 0),
				Position         = UDim2.new(0.5, 0, 0, 0),
				BackgroundTransparency = 1,
				Text             = current .. "  ▼",
				TextColor3       = THEME.SubText,
				Font             = Enum.Font.Gotham,
				TextSize         = 13,
				TextXAlignment   = Enum.TextXAlignment.Right,
			}, headerCard)

			local listFrame = make("Frame", {
				Size             = UDim2.new(1, 0, 0, #options * 30),
				Position         = UDim2.new(0, 0, 0, 42),
				BackgroundColor3 = THEME.Surface,
				BorderSizePixel  = 0,
				Visible          = false,
				ZIndex           = 10,
			}, wrapper)
			addCorner(listFrame, 6)
			addStroke(listFrame, THEME.Stroke, 1)

			make("UIListLayout", {
				SortOrder     = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
			}, listFrame)

			local dropObj = { CurrentOption = current }
			local expanded = false

			if flag then CyphraUI._flags[flag] = current end

			for i, opt in ipairs(options) do
				local optBtn = make("TextButton", {
					Size             = UDim2.new(1, 0, 0, 30),
					BackgroundColor3 = THEME.Surface,
					BackgroundTransparency = 0,
					Text             = opt,
					TextColor3       = THEME.Text,
					Font             = Enum.Font.Gotham,
					TextSize         = 13,
					BorderSizePixel  = 0,
					LayoutOrder      = i,
					ZIndex           = 11,
				}, listFrame)

				optBtn.MouseEnter:Connect(function()
					tween(optBtn, FAST, { BackgroundColor3 = THEME.Card })
				end)
				optBtn.MouseLeave:Connect(function()
					tween(optBtn, FAST, { BackgroundColor3 = THEME.Surface })
				end)
				optBtn.MouseButton1Click:Connect(function()
					dropObj.CurrentOption = opt
					if flag then CyphraUI._flags[flag] = opt end
					selectedLabel.Text = opt .. "  ▼"
					expanded = false
					listFrame.Visible = false
					wrapper.Size = UDim2.new(1, 0, 0, 40)
					pcall(cb, opt)
				end)
			end

			local headerBtn = make("TextButton", {
				Size             = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text             = "",
				BorderSizePixel  = 0,
				ZIndex           = 5,
			}, headerCard)

			headerBtn.MouseButton1Click:Connect(function()
				expanded = not expanded
				listFrame.Visible = expanded
				if expanded then
					wrapper.Size = UDim2.new(1, 0, 0, 40 + 6 + #options * 30)
					selectedLabel.Text = dropObj.CurrentOption .. "  ▲"
				else
					wrapper.Size = UDim2.new(1, 0, 0, 40)
					selectedLabel.Text = dropObj.CurrentOption .. "  ▼"
				end
			end)

			return dropObj
		end

		function tabObj:CreateColorPicker(settings)
			local name  = settings.Name     or "Color"
			local color = settings.Color    or THEME.Accent
			local flag  = settings.Flag
			local cb    = settings.Callback or function() end

			tabObj._order += 1

			local PRESETS = {
				Color3.fromRGB(233, 69,  96),
				Color3.fromRGB(76,  175, 80),
				Color3.fromRGB(33,  150, 243),
				Color3.fromRGB(255, 193, 7),
				Color3.fromRGB(156, 39,  176),
				Color3.fromRGB(255, 87,  34),
				Color3.fromRGB(0,   188, 212),
				Color3.fromRGB(238, 238, 238),
			}

			local card = make("Frame", {
				Size             = UDim2.new(1, 0, 0, 130),
				BackgroundColor3 = THEME.Card,
				BorderSizePixel  = 0,
				LayoutOrder      = tabObj._order,
			}, page)
			addCorner(card, 8)
			addStroke(card, THEME.Stroke, 1)

			make("TextLabel", {
				Size             = UDim2.new(1, -60, 0, 40),
				Position         = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text             = name,
				TextColor3       = THEME.Text,
				Font             = Enum.Font.Gotham,
				TextSize         = 13,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, card)

			local colorCircle = make("Frame", {
				Size             = UDim2.new(0, 24, 0, 24),
				Position         = UDim2.new(1, -40, 0, 8),
				BackgroundColor3 = color,
				BorderSizePixel  = 0,
			}, card)
			addCorner(colorCircle, 12)
			addStroke(colorCircle, THEME.Stroke, 1)

			local presetRow = make("Frame", {
				Size             = UDim2.new(1, -24, 0, 28),
				Position         = UDim2.new(0, 12, 0, 48),
				BackgroundTransparency = 1,
				BorderSizePixel  = 0,
			}, card)

			make("UIListLayout", {
				FillDirection  = Enum.FillDirection.Horizontal,
				Padding        = UDim.new(0, 4),
				SortOrder      = Enum.SortOrder.LayoutOrder,
			}, presetRow)

			local cpObj = { Color = color }
			if flag then CyphraUI._flags[flag] = { color.R, color.G, color.B } end

			local function setColor(c, fire)
				cpObj.Color = c
				colorCircle.BackgroundColor3 = c
				if flag then CyphraUI._flags[flag] = { c.R, c.G, c.B } end
				if fire then pcall(cb, c) end
			end

			for i, preset in ipairs(PRESETS) do
				local dot = make("TextButton", {
					Size             = UDim2.new(0, 22, 0, 22),
					BackgroundColor3 = preset,
					Text             = "",
					BorderSizePixel  = 0,
					LayoutOrder      = i,
				}, presetRow)
				addCorner(dot, 11)
				dot.MouseButton1Click:Connect(function()
					setColor(preset, true)
				end)
			end

			make("TextLabel", {
				Size             = UDim2.new(0, 36, 0, 20),
				Position         = UDim2.new(0, 12, 0, 86),
				BackgroundTransparency = 1,
				Text             = "RGB:",
				TextColor3       = THEME.SubText,
				Font             = Enum.Font.Gotham,
				TextSize         = 12,
			}, card)

			local rgbBox = make("TextBox", {
				Size             = UDim2.new(1, -60, 0, 24),
				Position         = UDim2.new(0, 52, 0, 84),
				BackgroundColor3 = THEME.Surface,
				Text             = math.floor(color.R * 255) .. ", " .. math.floor(color.G * 255) .. ", " .. math.floor(color.B * 255),
				TextColor3       = THEME.Text,
				Font             = Enum.Font.Code,
				TextSize         = 12,
				ClearTextOnFocus = false,
				BorderSizePixel  = 0,
			}, card)
			addCorner(rgbBox, 4)
			addStroke(rgbBox, THEME.Stroke, 1)

			rgbBox.FocusLost:Connect(function()
				local r, g, b = rgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
				if r and g and b then
					local c = Color3.fromRGB(
						math.clamp(tonumber(r), 0, 255),
						math.clamp(tonumber(g), 0, 255),
						math.clamp(tonumber(b), 0, 255)
					)
					setColor(c, true)
				end
			end)

			return cpObj
		end

		return tabObj
	end

	function windowObj:Notify(settings)
		local title    = settings.Title    or ""
		local content  = settings.Content  or ""
		local duration = settings.Duration or 3

		local notif = make("Frame", {
			Size             = UDim2.new(1, 0, 0, 0),
			AutomaticSize    = Enum.AutomaticSize.Y,
			BackgroundColor3 = THEME.Surface,
			BorderSizePixel  = 0,
			Position         = UDim2.new(1.1, 0, 0, 0),
		}, notifContainer)
		addCorner(notif, 8)
		addStroke(notif, THEME.Stroke, 1)

		local accentBar = make("Frame", {
			Size             = UDim2.new(0, 3, 1, 0),
			BackgroundColor3 = THEME.Accent,
			BorderSizePixel  = 0,
		}, notif)
		addCorner(accentBar, 2)

		make("TextLabel", {
			Size             = UDim2.new(1, -16, 0, 20),
			Position         = UDim2.new(0, 12, 0, 8),
			BackgroundTransparency = 1,
			Text             = title,
			TextColor3       = THEME.Text,
			Font             = Enum.Font.GothamBold,
			TextSize         = 13,
			TextXAlignment   = Enum.TextXAlignment.Left,
		}, notif)

		make("TextLabel", {
			Size             = UDim2.new(1, -16, 0, 0),
			Position         = UDim2.new(0, 12, 0, 30),
			AutomaticSize    = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text             = content,
			TextColor3       = THEME.SubText,
			Font             = Enum.Font.Gotham,
			TextSize         = 12,
			TextXAlignment   = Enum.TextXAlignment.Left,
			TextWrapped      = true,
		}, notif)

		addPadding(notif, 0, 0, 10, 0)

		tween(notif, SLOW, { Position = UDim2.new(0, 0, 0, 0) })

		task.delay(duration, function()
			tween(notif, MEDIUM, { Position = UDim2.new(1.1, 0, 0, 0) })
			task.wait(0.35)
			pcall(function() notif:Destroy() end)
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
