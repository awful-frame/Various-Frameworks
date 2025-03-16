local Tinkr, blink = ...
local tinsert, tremove, floor = tinsert, tremove, floor
local bin, lerp, cubic_bezier = blink.bin, blink.lerp, blink.cubicBezier
local min, max, pairs, ipairs = min, max, pairs, ipairs
local type, strsub, strlen = type, strsub, strlen
local fmod, rawset = math.fmod, rawset

local function rgb2hex(rgb)
	local hexadecimal = '|cFF'
	if #rgb > 3 then rgb[4] = nil end
	for key, value in pairs(rgb) do
		if type(value) == "number" then 
			value = value * 255

			local hex = ''

			while(value > 0)do
				local index = fmod(value, 16) + 1
				value = floor(value / 16)
				hex = strsub('0123456789ABCDEF', index, index) .. hex			
			end

			if strlen(hex) == 0 then
				hex = '00'
			elseif strlen(hex) == 1 then
				hex = '0' .. hex
			end

			hexadecimal = hexadecimal .. hex
		end
	end

	return hexadecimal
end

local function norm(a)
	return min(max(a, 0), 1)
end

-- ui object: 
-- each time new UI is created, save all properties to list here
-- 'opening' new UI by slashcmd or from dropdown list populates UI with all elements and applies accent colors
-- spec change listener to allow certain elements to only render for certain specs?

local list = {}

local UI = { 
	-- colors = {
		-- title = {{r,g,b}, {r,g,b}}, -- 2 colors for dual-tone title
	-- 	primary = {r,g,b},
	-- 	accent = {r,g,b},
	-- },
	-- tab = {},
	-- tabs = {} -- tabs will be full of tabs and their respective elements
	backdrops = {
		main = {
			bgFile = "Interface\\Buttons\\WHITE8X8",
			-- edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeFile = "Interface\\Buttons\\WHITE8X8",
			tile = true,
			tileEdge = true,
			tileSize = 16,
			-- edgeSize = 16,
			edgeSize = 3,
			insets = { left = 3, right = 3, top = 3, bottom = 3 }
		},
		tooltip = {
			bgFile = "Interface\\Buttons\\WHITE8X8",
			edgeFile = "Interface\\Buttons\\WHITE8X8",
			tile = true,
			tileEdge = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 3, right = 3, top = 3, bottom = 3 }
		},
		white = {
			bgFile = "Interface\\Buttons\\WHITE8X8",
			tile = true,
			tileEdge = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 3, right = 3, top = 3, bottom = 3 }
		},
		thumb = {
			tile = true,
			tileEdge = true,
			tileSize = 16,
			edgeSize = 4,
			insets = { top = 6, left = 0, right = 0, bottom = 6 }
		}
	},
	width = 325,
	height = 195,
}
UI.__index = UI

-- tab is subobject of UI dev uses to create new tabs and underlying elements
local TAB = { }
TAB.__index = TAB

local scrollSpeed = 8
local scrollSpaceMod = 8
local scrollSpaceBottomPadding = 60
local blinkOrange = {255, 140, 15}
local blinkFontNormal = blink.createFont(14)
local blinkFont = blinkFontNormal:GetFont() --"Fonts/FRIZQT__.TTF" --"Fonts/OpenSans-Bold.ttf"

local function adjust_color(rgb)
	if rgb.adjusted then return rgb end
	for key, color in ipairs(rgb) do
		if type(color) == "table" then
			if not color.adjusted then
				for key2, color2 in ipairs(color) do
					if key2 ~= 4 then
						rgb[key][key2] = color2 / 255
					end
				end
				color.adjusted = true
			end
		elseif key ~= 4 then
			rgb[key] = rgb[key] / 255
			rgb.adjusted = true
		end
	end
	return rgb
end

function UI:New(name, options)

	if type(name) ~= "string" then return false end

	if list[name] then
		blink.print("UI with that name [" .. name .."] already exists! Please choose another name...", true) 
		return false 
	end
	
	if type(options) ~= "table" then
		blink.print("UI [" .. name .."] must have valid options! Please pass table of options to 2nd arg 'options'...", true)
		return false
	end

	if not options.title then
		blink.print("UI [" .. name .."] must have a title! Please add the title property to 2nd arg 'options'...", true)
		return false
	end

	local ui = options
	ui.name = name

	if not ui.scale then ui.scale = 1 end

	if not ui.shadows then ui.shadows = {} end
	if not ui.shadows.primary then ui.shadows.primary = {0, 0, 0, 0.25, 1.25, -1.25} end

	if ui.colors and not ui.colors_adjusted then
		for k, v in pairs(ui.colors) do
			ui.colors[k] = adjust_color(v)
		end
		ui.colors_adjusted = true
	end

	-- general_padding_right
	if not ui.el_padding_right then ui.el_padding_right = 20 end

	if not ui.colors then ui.colors = {} end
	if not ui.colors.accent then ui.colors.accent = adjust_color(blinkOrange) end
	if not ui.colors.background then ui.colors.background = {0.06, 0.06, 0.04, 0.85} end
	if not ui.colors.elMod then ui.colors.elMod = 0.6 end
	if not ui.colors.elAlpha then ui.colors.elAlpha = 0.9 end
	if not ui.colors.tertiary then ui.colors.tertiary = {0.7,0.7,0.7,0.35} end
	if not ui.colors.primary then ui.colors.primary = {1, 1, 1, 1} end

	-- ui.colors = options.colors
	-- ui.title = options.title
	-- ui.width = options.width
	-- ui.sidebar = options.sidebar
	-- ui.height = options.height
	-- ui.tabs_w = options.tabs_w

	ui.sections = {}
	local cfg = blink.NewConfig(name, options.pw)
	ui.saved = setmetatable({}, { __index = cfg, __newindex = getmetatable(cfg).__newindex })

	if ui.subSettings then
		for _, key in ipairs(ui.subSettings) do
			if not ui.saved[key] then
				local newCfg = blink.NewConfig(ui.name.."_"..key)
				rawset(ui.saved, key, newCfg)
			end
		end
	end

	ui.cmd = blink.Command(options.cmd or name, true, options.pw)
	setmetatable(ui, UI)

	-- tab object
	ui.tab = { ui = ui }
	ui.tab.__index = ui.tab
	setmetatable(ui.tab, TAB)

	list[name] = ui

	ui:Render()

	return ui, ui.saved, ui.cmd

end

-- group object
-- create tabs under group, same as normal tab object but...
	-- 1.) has special attributes that apply changes to the ui
		-- can change ui colors & title
	-- 2.) is indented to the right a bit, to show it's under the group
-- group.open, default to true ?
-- group:Collapse() -- hides all tabs in group and rerenders
-- group:Expand() -- shows all tabs in group and rerenders

local GROUP = {}
GROUP.__index = GROUP

function UI:Group(options)
	local group = options
	if options.colors then
		for k,v in pairs(options.colors) do
			group.colors[k] = adjust_color(v)
		end
	end
	group.tabs = {}
	group.group = group
	group.ui = self
	group.uid = math.random(0, 999999)
	group.open = true
	setmetatable(group, GROUP)
	self.tabs = self.tabs or self:CreateTabList()
	tinsert(self.tabs, group)
	self:Rerender()
	return group
end

function GROUP:Tab(name, cfg)
	-- create new tab, add to list of tabs..
	local tab = {}
	local ui = self.ui
	tab.__index = ui.tab
	tab.parent = ui.frame.tabs
	tab.uid = math.random(0, 999999)
	tab.name = name
	tab.elements = {}
	tab.scrollPos = {}
	tab.inGroup = self

	if type(cfg) == "string" then
		if not ui.saved[cfg] then
			local newCfg = blink.NewConfig(ui.name.."_"..cfg)
			rawset(ui.saved, cfg, newCfg)
			tab.saved = newCfg
		else
			tab.saved = ui.saved[cfg]
		end
	end

	setmetatable(tab, ui.tab)

	tinsert(self.tabs, tab)

	self.ui:Rerender()

	return tab
end

function GROUP:ContainsTab(uid)
	for _, tab in ipairs(self.tabs) do
		if tab.uid == uid then
			return tab
		end
	end
end

function GROUP:Expand()
	if self.open then return false end
	self.group.open = true
	self.ui:Rerender(true)
end

function GROUP:Collapse()
	if not self.open then return false end
	self.group.open = false
	self.ui:Rerender(true)
end

function GROUP:Toggle()
	if not self.open then
		self:Expand()
	else
		self:Collapse()
	end
end

function UI:Tab(name, cfg)

	-- create new tab, add to list of tabs..
	local tab = {}
	tab.__index = self.tab
	tab.parent = self.frame.tabs
	tab.name = name
	tab.uid = math.random(0,999999)
	tab.elements = {}
	tab.scrollPos = {}

	if type(cfg) == "string" then
		if not self.saved[cfg] then
			local newCfg = blink.NewConfig(self.name.."_"..cfg)
			rawset(self.saved, cfg, newCfg)
			tab.saved = self.saved[cfg]
		else
			tab.saved = self.saved[cfg]
		end
	end

	setmetatable(tab, self.tab)
	self.tabs = self.tabs or self:CreateTabList()
	for _, tab in ipairs(self.tabs) do
		if tab.name == name then
			blink.print("Tab with that name [" .. name .."] already exists! Please choose another name...", true)
			return false
		end
	end
	tinsert(self.tabs, tab)

	self:Rerender()

	return tab

end

function TAB:Checkbox(name, var, tooltip)
	
	local saved = self.saved or self.ui.saved

	local el = {}
	el.type = "checkbox"
	el.saved = saved
	el.uid = math.random(0,999999)

	if type(name) == "table" then 
		el.var = name.var
		el.tooltip = name.tooltip
		el.name = name.text or name.name
		el.default = name.default
	else
		el.var = var
		el.tooltip = tooltip
		el.name = name
	end

	if type(el.text) ~= "string" and type(el.name) ~= "string" then
		return blink.print("required field [text] {string} missing in Checkbox creation")
	end
	if type(el.var) ~= "string" then
		return blink.print("required field [var] {string} missing in Checkbox creation")
	end

	if saved[el.var] == nil then
		saved[el.var] = el.default or false
	end

	tinsert(self.elements, el)
	-- rerender
	if self.ui.currentTab and self.ui.currentTab.name == self.name then
		self.ui:Rerender() 
	end
	return el
end

function TAB:Slider(options)
	if not options.var then return blink.print("You must provide variable for the slider value to be saved under", true) end
	local saved = self.saved or self.ui.saved
	local el = options
	el.type = "slider"
	el.saved = saved
	el.uid = math.random(0,999999)
	el.text = el.text or el.label
	el.name = options.name or options.text or options.label
	if type(el.var) ~= "string" then
		return blink.print("required field [var] {string} missing in Slider creation")
	end
	el.min = el.min or 0
	el.max = el.max or 100
	el.step = el.step or 1
	if type(el.min) ~= "number" then
		return blink.print("required field [min] {number} missing in Slider creation")
	end
	if type(el.max) ~= "number" then
		return blink.print("required field [max] {number} missing in Slider creation")
	end
	if el.default and type(el.default) ~= "number" then
		return blink.print("invalid value type for field [default] {number} in Slider creation")
	end
	if saved[el.var] == nil then
		saved[el.var] = el.default or el.value or el.min
	end
	tinsert(self.elements, el)
	-- rerender
	if self.ui.currentTab and self.ui.currentTab.name == self.name then
		self.ui:Rerender() 
	end
	return el
end

function TAB:Dropdown(options)
	if not options.var then return blink.print("You must provide variable for the dropdown value to be saved under", true) end
	local saved = self.saved or self.ui.saved
	local el = options
	el.type = el.multi and "multiDropdown" or "dropdown"
	el.saved = saved
	el.uid = math.random(0,999999)
	el.name = options.name or options.header or options.text
	if type(el.var) ~= "string" then
		return blink.print("required field [var] {string} missing in Dropdown creation")
	end
	if saved[el.var] == nil then
		if el.default then
			if el.multi then
				if type(el.default) ~= "table" then
					return blink.print("invalid value type for field [default] {table} missing in Multi-Dropdown creation")
				end
				saved[el.var] = {}
				for _, option in ipairs(el.default) do
					local optionByValue
					if el.options then
						for i=1,#el.options do
							if el.options[i].value == option then
								optionByValue = el.options[i]
								break
							end
						end
					end
					saved[el.var][option] = type(optionByValue) == "table" and optionByValue.tvalue or true
				end
			else
				saved[el.var] = el.default
			end
		else
			if el.multi then
				saved[el.var] = {}
			end
		end
	end
	tinsert(self.elements, el)
	-- rerender
	if self.ui.currentTab and self.ui.currentTab.name == self.name then
		self.ui:Rerender() 
	end
	return el
end

function TAB:Text(options)
	local el = options
	el.type = "text"
	el.uid = math.random(0, 999999)
	el.name = el.name or el.text
	tinsert(self.elements, el)
	-- rerender
	if self.ui.currentTab and self.ui.currentTab.name == self.name then
		self.ui:Rerender() 
	end
	return el
end

function TAB:Separator(options)
	local el = options or {}
	el.type = "text"
	el.uid = math.random(0, 999999)
	-- one '_' for each of options.width
	el.width = el.w or el.width or self.ui.separatorWidth or 45
	el.name = string.rep("_", el.width)
	el.paddingBottom = el.paddingBottom or 14
	el.text = el.name
	tinsert(self.elements, el)
	-- rerender
	if self.ui.currentTab and self.ui.currentTab.name == self.name then
		self.ui:Rerender() 
	end
end
TAB.Seperator = TAB.Separator
TAB.Sep = TAB.Separator

function TAB:Element(options)
	if type(options.factory) ~= "function" then return print("You must provide .factory function that builds and returns an instance of your custom element") end
	if type(options.category) ~= "string" then return print("You must supply .category for UI to identify the type of element") end
	local el = {}
	el.type = "custom_element"
	el.category = frame.category
	el.frame = frame
	el.uid = math.random(0, 999999)
	tinsert(self.elements, el)
	-- rerender
	if self.ui.currentTab and self.ui.currentTab.name == self.name then
		self.ui:Rerender() 
	end
end

-- frame pool
local frameCache = {
    tab = {},
    checkbox = {},
		slider = {},
		dropdown = {},
		multiDropdown = {},
		dropdownMenu = {},
		dropdownMenuScrollFrame = {},
		dropdownScrollChild = {},
		dropdownButton = {},
		dropdownLabel = {},
		text = {},
		secondarySliderThumb = {},
}

local function defaultFrame(type)
	return type == "tab" and CreateFrame("Button", nil, nil, nil, "UIPanelButtonTemplate")
	or type == "checkbox" and CreateFrame("CheckButton")
	or type == "slider" and CreateFrame("Slider", 'blink-slider-' .. math.random(0,99999999), nil, "OptionsSliderTemplate")
	or type == "dropdown" and CreateFrame("Button")
	or type == "multiDropdown" and CreateFrame("Button")
	or type == "dropdownMenu" and CreateFrame("Frame")
	or type == "dropdownMenuScrollFrame" and CreateFrame("ScrollFrame", nil, nil, "UIPanelScrollFrameTemplate")
	or type == "dropdownScrollChild" and CreateFrame("Frame")
	or type == "dropdownButton" and CreateFrame("Button")
	or type == "dropdownLabel" and CreateFrame("Button")
	or type == "text" and CreateFrame("Button")
	or type == "secondarySliderThumb" and CreateFrame("Frame")
end

local function getFrame(parent, ftype)
	local frame = tremove(frameCache[ftype]) or defaultFrame(ftype)
	frame:Show()
	if parent then
		frame:SetParent(parent)
	end
	return frame
end

function UI:CreateTabList()
	local uiRef = self
	return setmetatable({}, {
		__index = function(self, key)
			return uiRef:FindTabObject(key)
		end
	})
end

-- gui section constructor
function UI:CreateSection(alias, width, offsetX, offsetY, paddingLeft)
		
	offsetY = offsetY or 12
	offsetX = offsetX or 12
	paddingLeft = paddingLeft or 0

	-- frame creation as given alias assigned to 's'ection
	local f = self.frame
	local s = CreateFrame("Frame", f, BackdropTemplate)
	f[alias] = s
	s:SetParent(f)
	s.elements = {}
	s.tabs = UI:CreateTabList()
	s.ui = self
	s.name = alias

	-- backdrop (testing / visibility)
	-- Mixin(s, BackdropTemplateMixin)
	-- s:SetBackdrop(UI.backdrops.main)

	-- frame size
	s:SetHeight(f:GetHeight() - offsetY)
	s:SetWidth(width - paddingLeft)
	s:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", offsetX + paddingLeft, 0)

	-- scroll state
	s.scroll = {
		pos = 1,
		history = {},
		momentum = {},
		frame = CreateFrame("Slider",string.random(12),s,"OptionsSliderTemplate")
	}

	function s:reset(keepPos)
		-- this section's viewport height
		s.vh = s:GetHeight()
		-- this section's total height post overflow child element calc
		s.sh = s:GetHeight()
		-- total viewport height in use
		s.uh = 0
		-- total viewport height overflow (deficit of 'uh'-'vh') [default 1 to have valid slider range]
		s.overflow = 1
		-- bgleh
		s.tabs = UI:CreateTabList()
		s.elements = {}
		-- scroll state
		s.scroll.pos = keepPos and self.scroll.pos or 1
	end

	s:reset()

	local slider = s.scroll.frame
	Mixin(slider, BackdropTemplateMixin)
	slider:ClearAllPoints()
	slider:SetPoint("RIGHT",s,"RIGHT",-2,5)
	slider:SetFrameStrata("HIGH")
	slider:SetOrientation('VERTICAL')
	slider:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
	slider:SetBackdrop(nil)
	slider:SetBackdropColor(0,0,0,0)
	slider:SetBackdropBorderColor(1,1,1,0.6)
	if slider.NineSlice then
		slider.NineSlice:Hide()
	end
	slider.Thumb:SetHeight( ((s.vh / s.sh) * s:GetHeight())-20 )
	slider.Thumb:SetWidth(2)

	local r,g,b
	if self.currentTabAccentColors or self.colors.accent then
		r,g,b = unpack(self.currentTabAccentColors or self.colors.accent)
	else
		r,g,b = unpack(blinkOrange)
	end

	slider.Thumb:SetVertexColor(r, g, b, 1)
	slider.ThumbPos = { slider.Thumb:GetPoint() }
	Mixin(slider.Thumb, BackdropTemplateMixin)
	slider.Thumb:SetBackdrop(slider_thumb_bd)
	slider:SetWidth(3)
	slider:SetHeight(s.vh - 10)
	slider:SetMinMaxValues(1, s.overflow * scrollSpaceMod + scrollSpaceBottomPadding)
	slider:SetValue(s.scroll.pos)
	slider:SetScript("OnValueChanged",function(self) 
			s.scroll.pos = self:GetValue()
	end)
	slider:SetValueStep(1)
	getglobal(slider:GetName().."Low"):SetText("")
	getglobal(slider:GetName().."High"):SetText("")

	local selfRef = self

	-- on updatez
	s:SetScript("OnUpdate", function(self)

		local scrollSpacePadding = s.sh > s.vh and scrollSpaceBottomPadding or -7

		-- update overflow val
		s.overflow = (s.sh - s.vh + 1) -- * scrollSpeed (ghetto shit i was doing w/ squid?)
		-- update height of slider thumb based on ratio of scrollable height to viewport height
		slider.Thumb:SetHeight( ((s.vh / s.sh) * s:GetHeight())-20 )
		-- slider min/max values
		slider:SetMinMaxValues(1,s.overflow * scrollSpaceMod + scrollSpacePadding)

		-- faux scroll mechanism
		s.hovering = MouseIsOver(self)
		local momentum_value = 0
		local last_direction
		local momentum_modifier = 0.475
		local time = GetTime()
		-- iterate backwards to consider newest input first & make sharp directional changes
		for i = #s.scroll.momentum, 1, -1 do
				
			local m = s.scroll.momentum[i]
			local direction = m.direction
			local ends = m.ends

			local val = (ends - time) / 0.6

			if val < 0 then
				tremove(s.scroll.momentum,i)
			else
				last_direction = direction
				if i == 1 then -- newest input
					if direction == "DOWN" then
						if last_direction ~= "DOWN" then
							momentum_value = 0
							momentum_modifier = 0
							momentum_value = momentum_value + val
						else
							momentum_value = momentum_value + val
							momentum_modifier = momentum_modifier + 0.2
						end
					else
						if last_direction ~= "UP" then
							momentum_value = 0
							momentum_modifier = 0
							momentum_value = momentum_value - val
						else
							momentum_value = momentum_value - val
							momentum_modifier = momentum_modifier + 0.2
						end
					end
				else
					if direction == "DOWN" then
						momentum_value = momentum_value + val
						momentum_modifier = momentum_modifier + 1
					else
						momentum_value = momentum_value - val
						momentum_modifier = momentum_modifier + 1
					end
				end
			end

		end

		momentum_value = momentum_value * momentum_modifier -- value multiplier, the amount of scrolling each point of momentum will do!

		if abs(momentum_value) > 0 then
			slider:SetValue(slider:GetValue() + momentum_value)
			-- print(slider:GetValue())
		end

		-- hide slider thumb when scrollable space is near zero
		if (s.vh / s.sh) >= 0.98 then
			slider.Thumb:Hide()
		else
			slider.Thumb:Show()
		end

		-- store scroll pos per-tab 
		local tab = selfRef.currentTab
		if tab and tab.scrollPos then
			tab.scrollPos[alias] = s.scroll.pos
		end

	end)

	-- mousewheel event
	s:SetScript("OnMouseWheel", function(self,event)
		if event == -1 then -- mouse wheel down
			tinsert(s.scroll.momentum,{direction = "DOWN", ends = GetTime() + 0.6})
		elseif event == 1 then
			tinsert(s.scroll.momentum,{direction = "UP", ends = GetTime() + 0.6})
		end
	end)

	-- 'clear' method, 'wipes' all elements from section
	function s:Clear(keepPos)
		if s.tabs then
			for _, tab in ipairs(s.tabs) do
				tab:SetAlpha(0)
				tab:Hide()
				tinsert(frameCache["tab"], tab)
			end
		end
		if s.elements then
			for _, element in ipairs(s.elements) do
				-- close elements that should close on cleanup
				if element.SetOpen then
					element:SetOpen(false)
				end
				-- cleanup elements that have the method
				if element.CleanUp then
					element:CleanUp()
				end
				element:Hide()
				tinsert(frameCache[element.type], element)
			end
		end
		s:reset(keepPos)
	end

	function s:RepositionElements(fromIndex)
		local els = self.elements
		self.uh = 0
		for i, el in ipairs(els) do
			local above2 = els[i - 2]
			local above = els[i - 1]
			local horizontal
			if above then
				local p1, _, _, x, y = above:GetPoint()
				-- put checkboxes in a row when there's room
				local resolved
				if el.type == "checkbox" and above.type == "checkbox" then
					-- make sure it's not a 3rd one being added to row (no support for multi-wrapping)
					if not above2 or above2.type ~= "checkbox" or select(5, above2:GetPoint()) ~= y then
						local el_w = el:GetWidth() + el.txt:GetWidth() + el.textGap
						local tw = above:GetWidth() + above.txt:GetWidth() + above.textGap + el_w
						
						if tw <= self:GetWidth() - self.ui.el_padding_right then
							horizontal = true
							resolved = true
							local offset = self:GetWidth() - (el_w + self.ui.el_padding_right)
							el:SetPoint(p1, offset, y)
							el.originalPos = { el:GetPoint() }
						end
					end
				end
				-- otherwise
				if not resolved then
					local hh = above.height -- trust the tinder height? :P
					local bp = above.padding.bottom
					local offset = hh + bp + el.padding.top
					el:SetPoint(p1, 0 + el.padding.left, y-offset)
					el.originalPos = { el:GetPoint() }
				end
			else
				el:SetPoint("TOPLEFT",self,"TOPLEFT",0 + el.padding.left,0)
				el.originalPos = { el:GetPoint() }
			end
			if not horizontal then
				local totalHeight = el.height + el.padding.top + el.padding.bottom
				self.uh = self.uh + totalHeight
				if self.uh >= self.vh then
					self.sh = self.uh
				end
			end
		end
	end

	function s:AddElement(el)
		local els = self.elements
		
		local horizontal

		if #els > 0 then
			local above = els[#els]
			local p1, _, _, x, y = above:GetPoint()

			-- put checkboxes in a row when there's room
			local resolved
			if el.type == "checkbox" and above.type == "checkbox" then
				-- make sure it's not a 3rd one being added to row (no support for multi-wrapping)
				if not els[#els - 1] or els[#els - 1].type ~= "checkbox" or select(5, els[#els - 1]:GetPoint()) ~= y then
					local el_w = el:GetWidth() + el.txt:GetWidth() + el.textGap
					local tw = above:GetWidth() + above.txt:GetWidth() + above.textGap + el_w
					
					if tw <= self:GetWidth() - self.ui.el_padding_right then
						horizontal = true
						resolved = true
						local offset = self:GetWidth() - (el_w + self.ui.el_padding_right)
						el:SetPoint(p1, offset, y)
						el.originalPos = { el:GetPoint() }
					end
				end
			end
			-- otherwise
			if not resolved then
				local hh = above.height -- trust the tinder height? :P
				local bp = above.padding.bottom
				local offset = hh + bp + el.padding.top
				el:SetPoint(p1, 0 + el.padding.left, y-offset)
				el.originalPos = { el:GetPoint() }
			end
		else
			el:SetPoint("TOPLEFT",self,"TOPLEFT",0 + el.padding.left,0)
			el.originalPos = { el:GetPoint() }
		end

		if not horizontal then
			local totalHeight = el.height + el.padding.top + el.padding.bottom
			self.uh = self.uh + totalHeight
			if self.uh >= self.vh then
				self.sh = self.uh
			end
		end

		tinsert(els, el)
	end

	return s

end

function UI:Render()
	if self.frame then return end

	-- the mainframe 😎
	local f = CreateFrame("Button", "UIParent", BackdropTemplate)
	self.frame = f
	f.ui = self
	Mixin(f, BackdropTemplateMixin)
	f:SetBackdrop(self.backdrops.main)
	f:SetParent(nil)
	local mr, mg, mb, ma = unpack(self.colors.background)
	f:SetBackdropColor(mr, mg, mb, ma)
	f:SetBackdropBorderColor(mr, mg, mb, ma); 
	f:SetHeight(self.height)
	f:SetWidth(self.width)
	local sv = self.saved
	local p1, pframe, p2, x, y = sv.ui_p1, sv.ui_pframe, sv.ui_p2, sv.ui_x, sv.ui_y
	f:SetPoint(p1 or "CENTER", "UIParent", p2 or "CENTER", x or math.random(-300, 300), y or math.random(-100, 100))
	f:SetFrameStrata("HIGH")
	f:SetMovable(true)
	f:SetScript("OnMouseUp",function(self) 
		self:StopMovingOrSizing() 
		sv.ui_p1, sv.ui_pframe, sv.ui_p2, sv.ui_x, sv.ui_y = self:GetPoint()
	end)
	f:SetScript("OnMouseDown",function(self) 
		self:StartMoving()
		sv.ui_p1, sv.ui_pframe, sv.ui_p2, sv.ui_x, sv.ui_y = self:GetPoint()
	end)

	--! Animate in/out !--
	local animation = {
		duration = 0.25,
		y_offset = 30
	}

	function f:SetOpen(open)
		local delay = 0
		if self.animating then
			if not self.secondAnimation then
				open = not open
				delay = self.animating.ends - GetTime() + 3/GetFramerate()
				self.animating.ends = self.animating.ends + delay
				self.secondAnimation = true
			else 
				return
			end
		else
			self.secondAnimation = false
		end

		delay = max(delay, 0)
		local function animate()
			if open and not f:IsShown() then f:Show() end
			local time = GetTime()
			local anim = {
				open = open,
				point = {f:GetPoint()},
				started = time,
				ends = time + animation.duration,
			}
			f.animating = anim
			local p1, pframe, p2, start_x, start_y = unpack(anim.point)
			local y_offset = open and animation.y_offset or -animation.y_offset
			local dur = animation.duration
			local ends = anim.ends
			local function tick(self)
				time = GetTime()

				-- animation over, cancel ticker and stop animating
				if time >= ends then
					self:Cancel()
					f.animating = nil
					if not open then
						f:Hide()
					end
					return true
				end
				
				local pct_complete = 1 - ((ends - time) / dur)
				local target_y = start_y + y_offset
				local target_a = open and 1 or 0.01
				local start_a = open and 0.01 or 1
				-- local target_scale = open and 1 or 0.8
				-- local start_scale = open and 0.8 or 1
				
				local completion = cubic_bezier(pct_complete,.13,1.1,1.2,1.3) --cubic_bezier(pct_complete,0,0.1,1.6,1.39)
				local alpha = norm(lerp(start_a, target_a, completion))
				local y = lerp(start_y, target_y, completion)
				-- local scale = min(1, lerp(start_scale, target_scale, completion))

				-- f:SetScale(scale)
				f:SetAlpha(alpha)
				f:SetPoint(p1, "UIParent", p2, start_x, y)
			end
			C_Timer.NewTicker(0, tick)
		end

		C_Timer.After(delay, animate)
		
	end

	-- slashcmd to open the UI
	self.cmd:New(function(msg)
		if msg:gsub(" ", "") == "" then
			if f:IsShown() then
				f:SetOpen(false)
			else
				f:SetOpen(true)
			end
			return true
		end
	end)

	-- multi title
	function self:UpdateTitle(colors, title)
		title = title or self.title
		colors = colors or self.colors
		if type(title) == "table" then
			local tSize = title.size
			C_Timer.After(0.1, function()
				for i, value in ipairs(title) do
					
					local r, g, b 
					if colors.title and colors.title[i] then
						r, g, b = unpack(colors.title[i])
					else
						r, g, b = unpack(self.colors.primary)
					end

					if not f['title'..i] then 
						f['title' .. i] = f:CreateFontString('tfontstringz', "OVERLAY")
					end
					local t = f['title' .. i]
					
					-- if title is table, see if they set font size for this txt
					local isTable = type(value) == "table"
					local size = isTable and value.size or tSize or 14
					local text = value
					if isTable then text = value.text end

					t:SetFont(blinkFont, size, '')
					t:SetText(text)

					-- first txt
					if i == 1 then
						t:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -12)
					else
						local prevText = f['title' .. i - 1]
						local _, _, _, x, y = prevText:GetPoint()
						local w = prevText:GetWidth() + 0.2
						t:SetPoint("TOPLEFT", f, "TOPLEFT", x + w, y)
					end

					t:SetTextColor(r,g,b)
				end
			end)
		-- single title
		elseif type(title) == "string" then
			
			local r, g, b 
			if colors.title then
				r, g, b = unpack(colors.title)
			elseif colors.primary then
				r, g, b = unpack(colors.primary)
			else
				r, g, b = 1, 1, 1
			end
			if not f.title then
				f.title = f:CreateFontString('ftitle2z', "OVERLAY")
			end
			local t = f.title
			local size = self.titleSize or 14

			t:SetFont(blinkFont, size, '')
			t:SetText(title)
			t:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -12)
			t:SetTextColor(r,g,b)
			
		end

		-- update scrollbar color as well
		local r, g, b = unpack(colors.accent or self.colors.accent)
		for _, section in ipairs(self.sections) do
			if section.scroll and section.scroll.frame then
				section.scroll.frame.Thumb:SetVertexColor(r, g, b, 1)
				if section.scroll.frame.NineSlice then
					section.scroll.frame.NineSlice:Hide()
				end
			end	
		end
	end
	self:UpdateTitle()

	-- exit button
	f.exit = CreateFrame("BUTTON", '', f)

	f.exitCircle = f:CreateTexture('fexitbttn', "OVERLAY")
	f.exitCircle:SetTexture(C_Spell.GetSpellTexture(118))
	f.exitCircle:SetWidth(6)
	f.exitCircle:SetHeight(6)
	f.exitCircle:SetColorTexture(1,82/255,82/255,1)
	f.exitCircle:SetPoint("TOPRIGHT", f, "TOPRIGHT", -13, -13)

	f.exitCircleMask = f:CreateMaskTexture()
	f.exitCircleMask:SetAllPoints(f.exitCircle)
	f.exitCircleMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

	f.exitCircle:AddMaskTexture(f.exitCircleMask)

	f.exit:SetAlpha(0)
	f.exit:SetSize(18,18)
	f.exit:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
	f.exit:RegisterForClicks("AnyUp")
	f.exit:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	f.exit:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	f.exit:SetScript("OnClick", function() f:SetOpen(false) end)
	f.exit:SetScript("OnEnter", function() f.exitCircle:SetColorTexture(1,125/255,125/255,1) end)
	f.exit:SetScript("OnLeave", function() f.exitCircle:SetColorTexture(1,82/255,82/255,1) end)

	-- ui sections (tabs, elements) - FIXME MAKE THIS PCT BASED FOR VARIABLE SECTIONS!
	

	local title_width = 0
	if f.title then
		title_width = title_width + f.title:GetWidth()
	end
	for i=1,30 do if f['title'..i] then
		title_width = title_width + f['title'..i]:GetWidth()
	end end

	local tabs_w = self.tabs_w or max(110, title_width + 25) -- or 110

	local w = f:GetWidth()

	if tabs_w > 110 then
		f:SetWidth(w + tabs_w - 110)
		w = w + tabs_w - 110
	end

	local y_offset = 40
	local x_offset = 0
	
	local padding = 10

	-- lighter accent dual tone ui, looks kinda nice :)
	if self.sidebar ~= false then
		f.tertiaryAccent =  CreateFrame("Frame", f, BackdropTemplate)
		f.tertiaryAccent:SetParent(f)
		f.tertiaryAccent:SetFrameStrata("LOW")
		Mixin(f.tertiaryAccent, BackdropTemplateMixin)
		local sr, sg, sb, sa = unpack(self.colors.tertiary)
		f.tertiaryAccent:SetBackdrop(self.backdrops.white)
		f.tertiaryAccent:SetBackdropColor(sr, sg, sb, sa)
		-- f.tertiaryAccent:SetBackdropBorderColor(0.6,0,0.4,0.3)
		f.tertiaryAccent:SetHeight(f:GetHeight())
		f.tertiaryAccent:SetWidth(tabs_w + 1)
		f.tertiaryAccent:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)
	end

	local tabsFrame = self:CreateSection("tabs", tabs_w, x_offset, y_offset)

	w = w - tabs_w
	x_offset = x_offset + tabsFrame:GetWidth()

	local elementsFrame = self:CreateSection("view", w, x_offset, y_offset, padding)

	tinsert(self.sections, elementsFrame)

	-- close all appropriate elements when frame is clicked
	f:SetScript("OnClick", function(self)
		for _, section in ipairs(self.ui.sections) do
			for _, element in ipairs(section.elements) do
				if element.SetOpen then
					element:SetOpen(false)
				end
			end
		end
	end)

	f:SetScale(self.scale or 1)
	if not self.show then
		f:Hide()
	end

end

local function createPadding(padding)
	padding = padding or {}
	padding.top = padding.top or 0
	padding.bottom = padding.bottom or 0
	padding.left = padding.left or 0
	padding.right = padding.right or 0
	return padding
end

-- render tab group
function UI:RenderGroup(group, padding)
	self:RenderTab(group, padding)
	if group.open then
		for _, tab in ipairs(group.tabs) do
			local p = {}
			for k,v in pairs(padding) do p[k] = v end
			self:RenderTab(tab, p)
		end
	end
end

local function resetTab(tab)
	tab.name = nil
	tab.group = nil
	tab.elements = nil
	tab.tabs = nil
	tab.group = nil
	tab.Collapse = nil
	tab.Expand = nil
	tab.init = nil
	tab.uid = nil
	tab.tooltip = nil
end

-- render tab
function UI:RenderTab(info, padding)
	
	parent = self.frame.tabs -- tabs section
	parent.tabs = parent.tabs or self:CreatTabList()
	local tab = getFrame(parent, "tab") -- CreateFrame("Button", nil, parent, nil, "UIPanelButtonTemplate")
	tab:SetFrameStrata("HIGH")
	local name = info.name
	tab.UI = self
	resetTab(tab)
	tab.uid = info.uid
	tab.group = info.group
	tab.name = name
	tab.elements = info.elements
	tab.inGroup = info.inGroup

	-- vertical space taken by frame, not including 'padding'
	local height = 13
	tab.height = height

	-- if any padding, save under tab
	tab.padding = createPadding(padding)
	tab.padding.left = tab.padding.left + bin(tab.inGroup) * 4

	local selfRef = self

	local function onClick()
		selfRef:SetTab(tab)
	end

	tab:SetText(name)
	if not tab.group then
		tab:SetScript("OnClick", onClick)
	else
		tab:SetScript("OnClick", function(self, event)
			info:Toggle()
		end)
	end
	tab:GetFontString():SetFont(blinkFont, height, '')
	local tr, tg, tb, ta = unpack(self.colors.primary)
	tab:GetFontString():SetTextColor(tr, tg, tb, ta or 1)

	tab:GetFontString():SetSize(parent:GetWidth(), height)
	-- tab:GetFontString():SetWidth(parent:GetWidth())
	tab:GetFontString():SetPoint("LEFT", 0, 0)
	tab:GetFontString():SetPoint("RIGHT", -tab:GetWidth() + parent:GetWidth() - self.el_padding_right, 0)
	tab:GetFontString():SetJustifyV("MIDDLE")
	tab:GetFontString():SetJustifyH("LEFT")

	tab:SetSize(parent:GetWidth() - self.el_padding_right, height)
	
	-- place this element below existing elements
	if #parent.tabs > 0 then
		-- directly below above element .. height + bottom padding of above element
		local above = parent.tabs[#parent.tabs]
		local p1, _, _, x, y = above:GetPoint()
		local hh = above:GetHeight()
		local bp = above.padding.bottom
		local offset = hh + bp
		tab:SetPoint(p1,tab.padding.left,y-offset)
		tab.originalPos = {tab:GetPoint()}
	else
		-- init padding top pushes element down
		tab:SetPoint("TOPLEFT", parent, "TOPLEFT", 0 + tab.padding.left - tab.padding.right, 0 + tab.padding.top)
		tab.originalPos = {tab:GetPoint()}
	end

	function tab:SetInteractive(enabled)
		self:SetEnabled(enabled)
		self:EnableMouse(enabled)
	end

	tab:SetScript("OnUpdate",function()
		if not tab.init then tab.init = true return end
		local p1, parent, p2, x, y = unpack(tab.originalPos)

		local y_adjusted = y + parent.scroll.pos / scrollSpaceMod
		tab:SetPoint(p1, parent, p2, x, y_adjusted)

		local y_abs = abs(y_adjusted)
		
		local distanceToBottom = parent.vh - y_abs - tab.height

		local fadeRangeBottom = 6
		local fadeRangeTop = 14
		local bottomOutFadeInRange = 105
		
		-- fade out top
		if y_adjusted > 0 then
			local desiredAlpha = norm(0.95 - (y_adjusted-tab.height/2)/fadeRangeTop)
			tab:SetAlpha(desiredAlpha)
		-- fade out bottom
		elseif distanceToBottom < tab.height + fadeRangeBottom then
			local remainingScrollSpace = (parent.overflow * scrollSpaceMod + scrollSpaceBottomPadding) - parent.scroll.pos
			tab:SetAlpha( norm(distanceToBottom / (tab.height + fadeRangeBottom) + norm((-remainingScrollSpace + bottomOutFadeInRange)/100) ))
		-- normal range
		else
			tab:SetAlpha(1)
		end

		if tab:GetAlpha() <= 0.25 then
				tab:SetInteractive(false)
		else
				tab:SetInteractive(true)
		end

		-- current tab accent color
		local cuid = self.currentTab and self.currentTab.uid
		if cuid == tab.uid 
		or tab.group and tab.group:ContainsTab(cuid) then
			local r,g,b
			local grouped = tab.group or tab.inGroup
			if grouped and grouped.colors and grouped.colors.accent then
				r,g,b = unpack(grouped.colors.accent)
			elseif self.colors and self.colors.accent then
				r,g,b = unpack(self.colors.accent)
			else
				r,g,b = unpack(blinkOrange)
			end
			tab:GetFontString():SetTextColor(r,g,b,1)
		elseif not MouseIsOver(tab) then
			local r,g,b
			local pr, pg, pb
			if self.colors then
				if self.colors.accent then
					r,g,b = unpack(self.colors.accent)
				else
					r,g,b = 1,1,1
				end
				if self.colors.primary then
					pr, pg, pb = unpack(self.colors.primary)
				end
			end
			tab:GetFontString():SetTextColor(tr, tg, tb, ta or 1)
		end

	end)

	local r,g,b
	local grouped = tab.group or tab.inGroup
	if grouped and grouped.colors and grouped.colors.accent then
		r,g,b = unpack(grouped.colors.accent)
	elseif self.colors and self.colors.accent then
		r,g,b = unpack(self.colors.accent)
	else
		r,g,b = unpack(blinkOrange)
	end

	tab:SetScript("OnEnter", function(self) 
		self:GetFontString():SetTextColor(r*1.2, g*1.2, b*1.2, 0.95)
		-- self:GetFontString():SetFont(blinkFont, height + 0.5)
	end)
	-- tab:SetScript("OnLeave", function(self) 
	-- 	self:GetFontString():SetTextColor(1, 1, 1, 1) 
	-- 	-- self:GetFontString():SetFont(blinkFont, height)
	-- end)

	tinsert(parent.tabs, tab)

	local totalHeight = height + tab.padding.top + tab.padding.bottom
	parent.uh = parent.uh + totalHeight
	if parent.uh >= parent.vh then
		-- scrollable height is just used height..?
		parent.sh = parent.uh -- parent.sh + totalHeight
	end

	return tab

end

function UI:ShowTooltip(text)

	if not text then return end

	if self.frame.animating and not self.frame.animating.open then return end

	local mr, mg, mb, ma = unpack(self.colors.background)

	-- GameTooltip:ApplyBackdrop(nil)

	GameTooltip:SetOwner(self.frame);
	GameTooltip:SetAnchorType("ANCHOR_TOPLEFT",0,2);

	Mixin(GameTooltip, BackdropTemplateMixin)
	GameTooltip:SetBackdrop(self.backdrops.main)
	GameTooltip:SetBackdropColor(mr,mg,mb,ma or 0.7)
	GameTooltip:SetBackdropBorderColor(mr,mg,mb,ma or 0.7)
	-- GameTooltip.NineSlice:SetBorderColor(0,0,0,0)
	-- GameTooltip.NineSlice:SetCenterColor(0,0,0,0)
	GameTooltip.NineSlice:Hide()
	-- GameTooltip:ApplyBackdrop()

	local color = rgb2hex(self.colors.primary)
	
	GameTooltip:AddLine(color .. text, nil, nil, nil, true)
	GameTooltip:SetWidth(self.frame:GetWidth())
	GameTooltip:SetMinimumWidth(self.frame:GetWidth() + 30)
	
	-- GameTooltipText:SetFont("Fonts\\FRIZQT__.TTF", 4)

	local sr, sg, sb, sa, sx, sy = unpack(self.shadows.primary)

	for i=1,GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft"..tostring(i)]
		line:SetFont(blinkFont, 10.5, '')
		line:SetJustifyH("LEFT")
		line:SetShadowColor(sr, sg, sb, sa)
		line:SetShadowOffset(sx, sy)
	end 

	GameTooltip:SetScale(self.scale)

	GameTooltip:Show()

end

function UI:HideTooltip()
	GameTooltip:SetBackdrop(nil)
	GameTooltip.NineSlice:Show()
	GameTooltipText:SetFont("Fonts\\FRIZQT__.TTF", 12, '')
	for i=1,GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft"..tostring(i)]
		line:SetFont("Fonts\\FRIZQT__.TTF", 13, '')
		line:SetJustifyH("LEFT")
	end 
	GameTooltip:Hide()
end

local function FauxScroll(self)
	-- faux scroll mechanism
	local p1, pframe, p2, x, y = unpack(self.originalPos)

	local y_adjusted = y + self.parent.scroll.pos / scrollSpaceMod
	self:SetPoint(p1, pframe, p2, x, y_adjusted)

	local y_abs = abs(y_adjusted)
	
	local distanceToBottom = self.parent.vh - y_abs - self.height

	local fadeRangeBottom = 12
	local fadeRangeTop = 6
	local bottomOutFadeInRange = 105
	
	if not self.pauseAlpha or GetTime() - self.pauseAlpha > 2/GetFramerate() then
		-- fade out top
		if y_adjusted > 0 then
			self:SetAlpha(norm(1 - y_adjusted/max(fadeRangeTop,(fadeRangeTop + 24 - (self.height / 2)))))
		-- fade out bottom
		elseif distanceToBottom < fadeRangeBottom then
			local remainingScrollSpace = (self.parent.overflow * scrollSpaceMod + scrollSpaceBottomPadding) - self.parent.scroll.pos
			self:SetAlpha( 
				norm(distanceToBottom / (fadeRangeBottom) + max(0, (-remainingScrollSpace + bottomOutFadeInRange)/100 ))
			)
		-- normal range
		else
			self:SetAlpha(1)
		end
	end

	if self:GetAlpha() <= 0.25 then
		self:SetInteractive(false)
	else
		self:SetInteractive(true)
	end
end

local function round(val, step)
	return floor(val/step)*step
end

local events = {
	--! General Events !--
	OnEnter = function(self)
		if self.tooltip then
			self.ui:ShowTooltip(self.tooltip)
		end
	end,
	OnLeave = function(self)
		if self.tooltip then
			self.ui:HideTooltip(self.tooltip)
		end
	end,
	--! Checkbox Events !--
	checkbox = {
		OnClick = function(self)
			if self:GetChecked() then
				self.saved[self.var] = true
			else
				self.saved[self.var] = false
			end
		end,
		OnUpdate = function(self)
			-- value changed from external source
			local val = self.saved[self.var]
			if val ~= nil and val ~= self:GetChecked() then
				self:SetChecked(val)
			end
			FauxScroll(self)
		end,
	},
	--! Slider Events !--
	slider = {
		OnUpdate = function(self)
			local val = self.saved[self.var]
			if val ~= nil and val ~= round(self:GetValue(), self.step) then
				self:SetValue(round(self:GetValue(), self.step))
			end
			FauxScroll(self)
		end,
		OnValueChanged = function(self, event)
			local v = round(self:GetValue(), self.step)
			self.saved[self.var] = v
			self.TEXT:SetText(self.text .. ": " .. self.valueColor .. v .. (self.valueType and self.valueType or self.percentage and "%" or ""))
		end,
	},
	--! Dropdown Events !--
	dropdown = {
		OnClick = function(self, event)
			if event == "LeftButton" then
				self:SetOpen()
			elseif event == "RightButton" then
				if not self.multi then
					if not self.default then
						self:SetSelected(nil)
					else
						self:SetSelected(self.default)
					end
				else
					self:SetSelected(nil)
				end
			end
		end,
		OnUpdate = function(self)

			-- value changed from external source
			local val = self.saved[self.var]

			--! single selection dropdown !--
			if not self.multi then
				if val ~= nil and val ~= self.value then
					local option = self:FindOptionByValue(val)
					if option then
						self:SetSelected(option)
					end
				elseif self.value ~= nil and val == nil then
					self:SetSelected(nil)
				end
			--! mulit selec dropdown !--
			else
				if self.placeholder then
					if #self.labels == 0 then
						self.label:Show()
					else
						self.label:Hide()
					end
				end
			end

			local sb = self.scroll.frame.ScrollBar
			-- hide scrollup/down buttons
			if sb.ScrollUpButton:IsShown() or sb.ScrollDownButton:IsShown() then
				
				sb.ScrollUpButton:Hide()
				sb.ScrollDownButton:Hide()

			end

			-- make sure color matches value type
			if not self.multi then
				if self.labelType ~= self.colorType then
					self.colorType = self.labelType
					local r,g,b,a = unpack(self.ui.colors.primary)
					if self.labelType == "value" then
						self.label:SetTextColor(r,g,b,a or 1)
					elseif self.labelType == "placeholder" then
						self.label:SetTextColor(r*0.8, g*0.8, b*0.8, 1)
					end
				end
			end

			-- hide scrollbar if scrollspace < frame height
			if self.scroll.child:GetHeight() <= self.scroll.frame:GetHeight() then
				sb:Hide()
			end

			FauxScroll(self)
		end,
	},
	--! Text Events !--
	text = {
		OnUpdate = function(self)
			FauxScroll(self)
		end,
	}
}

local DropdownMethods = {
	CleanUp = function(self)
		if self.label then
			self.label:Hide()
		end
		for _, label in ipairs(self.labels) do
			label.text:Hide()
			label:Hide()
			tinsert(frameCache.dropdownLabel, label)
		end
	end,
	ClearMenuButtons = function(self)
		if not self.buttons then return end
		for _, button in ipairs(self.buttons) do
			if button.txt then
				button.txt:Hide()
			end
			button:Hide()
			tinsert(frameCache.dropdownButton, button)
		end
	end,
	RerenderDropdownMenu = function(self)
		self:ClearMenuButtons()
		self.buttons = {}
		local dropdownRef = self
		local menu_padding = self.menu_padding
		local button_height = self.button_height
		local total_height = menu_padding
		local ui = self.ui
		local r,g,b = unpack(ui.currentTabAccentColors or ui.colors.accent)
		local pr, pg, pb, pa = unpack(ui.colors.primary)
		local ar, ag, ab, aa = unpack(ui.colors.tertiary)
		local mr, mg, mb, ma = unpack(ui.colors.background)
		local sr, sg, sb, sa, sx, sy = unpack(ui.shadows.primary)
		for _, option in ipairs(self.options) do
			if type(self.selected) ~= "table" or not self.selected[option.value] then
				local button = getFrame(self.scroll.child, "dropdownButton")--CreateFrame("Button", nil, scr.child)
				button.ui = self.ui
				if option.tooltip then
					button.tooltip = option.tooltip
					button:SetScript("OnEnter", events.OnEnter)
					button:SetScript("OnLeave", events.OnLeave)
				else
					button:SetScript("OnEnter", function() end)
					button:SetScript("OnLeave", function() end)
				end
				button:SetPoint("TOP", self.scroll.child, "TOP", 0, -total_height)
				button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
				button:GetHighlightTexture():SetVertexColor(r/1.4,g/1.4,b/1.4,0.2)
				button:GetHighlightTexture():ClearAllPoints()
				button:GetHighlightTexture():SetPoint("LEFT", -6, 0)
				button:GetHighlightTexture():SetPoint("RIGHT", 2, 0)
				button:GetHighlightTexture():SetPoint("TOP", 0, 0)
				button:GetHighlightTexture():SetPoint("BOTTOM", 0, 0)
				-- button:GetHighlightTexture():SetPoint("LEFT", 0)
				button:SetWidth(self.scroll.child:GetWidth() - ui.el_padding_right)
				button:SetHeight(button_height)
				button:SetScript("OnClick", function(self, event) dropdownRef:SetSelected(self.option) end)
				button.option = option
				button.txt = button:CreateFontString('', "OVERLAY", nil)
				button.txt:ClearAllPoints()
				button.txt:SetFont(blinkFont, 9, '')
				button.txt:SetText(option.label)
				button.txt:SetWidth(button:GetWidth())
				button.txt:SetJustifyH("LEFT")
				button.txt:SetPoint("LEFT", 4, 0)
				button.txt:SetPoint("RIGHT", -20, 0)
				button.txt:SetHeight(button:GetHeight())
				local cr, cg, cb, ca = pr, pg, pb, pa
				button.txt:SetTextColor(r,g,b,norm(ca or 1))
				-- button.txt:SetTextColor(cr, cg, cb, ca or 1)
				button.txt:SetShadowColor(sr, sg, sb, sa / 4)
				button.txt:SetShadowOffset(sx, sy)
				tinsert(self.buttons, button)
				total_height = total_height + button_height
			end
		end
		self.scroll.child:SetHeight(total_height + menu_padding)
		self.scroll.frame:SetHeight(min(button_height * 5 + menu_padding * 2, total_height + menu_padding))
		local sb = self.scroll.frame.ScrollBar
		sb.ThumbTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
		sb.ThumbTexture:SetVertexColor(r,g,b,1)
		sb.ThumbTexture:SetWidth(3)
		sb.ThumbTexture:SetHeight(32)
		sb:ClearAllPoints()
		sb:SetHeight(self.scroll.frame:GetHeight() - 8)
		sb:SetWidth(2)
		sb:SetPoint("RIGHT", -1, 0)
	end,
	SetOpen = function(self, ...)
		local args = {...}
		local open = args[#args]
		if open ~= nil then
			self.open = open
		else
			self.open = not self.open
		end
		
		if self.open then

			-- close other open dropdowns first
			for _, element in ipairs(self.parent.elements) do
				if element.SetOpen and element.uid ~= self.uid then
					element:SetOpen(false)
				end
			end

			self.menu:Show()
			self.arrow:SetRotation(rad(0))
			self.arrow:SetPoint("RIGHT", self, "RIGHT", self.initArrowX, self.initArrowY)
		else
			self.menu:Hide()
			self.arrow:SetRotation(rad(90))
			self.arrow:SetPoint("RIGHT", self, "RIGHT", self.initArrowX, self.initArrowY)
		end
	end,
	RemoveLabel = function(self, option, skipRecalc)
		if not option then return end
		for k, label in ipairs(self.labels) do
			if label.option and label.option.value == option.value then
				label:Hide()
				tinsert(frameCache.dropdownLabel, self)
				tremove(self.labels, k)
				if not skipRecalc then
					self:RearrangeLabels()
				end
			end
		end
	end,
	RearrangeLabels = function(self)
		local prev_lines_added = self.lines_added
		self.lines_added = 0
		self:SetHeight(self.original_height)
		self.height = self.original_height
		local pwidth = self:GetWidth()
		local x = self.label_padding
		local y = -self.label_padding * 2
		local prev_y = -self.label_padding * 2
		for i, label in ipairs(self.labels) do

			local height_updated
			if pwidth - x - label:GetWidth() - self.label_padding <= self.label_container_padding_right then
				x = self.label_padding
				y = y - self.label_line_height
				height_updated = true
			end

			label:SetPoint("TOPLEFT", x + self.label_padding, y)

			-- if abs(y-prev_y) < 2 then
				x = x + label:GetWidth() + self.label_padding
			-- end
			prev_y = y

			if height_updated then
				local prev_height = self:GetHeight()
				self:SetHeight(prev_height + self.label_line_height)
				self.height = self.height + self.label_line_height
				self.lines_added = self.lines_added + 1 
				if self.scroll then
					self.scroll.frame:SetPoint("TOP", 0, -self:GetHeight())
				end
			end

		end

		if self.lines_added ~= prev_lines_added then
			self:SetHeight(self.original_height + (self.lines_added * self.label_line_height))
			if self.scroll then
				self.scroll.frame:SetPoint("TOP", 0, -self:GetHeight())
			end
			self.parent:RepositionElements()
		end
	end,
	AppendLabel = function(self, option)
		
		if not option then return end

		local r,g,b,a = unpack(self.ui.currentTabAccentColors or self.ui.colors.accent)
		local sr, sg, sb, sa, sx, sy = unpack(self.ui.shadows.primary)

		local label = CreateFrame("Button") --getFrame(nil, "dropdownLabel")
		label:ClearAllPoints()
		-- for some reason, grabbing a button from frame pool and trying to set parent to the dropdown
		-- throws an infinite loop error, but creating new button works fine... uhhhhhhhhhh?
		label:SetParent(self)
		Mixin(label, BackdropTemplateMixin)
		label:SetBackdrop(self.ui.backdrops.main)
		label:SetBackdropBorderColor(r,g,b,0.6)
		label:SetBackdropColor(r,g,b,0.6)

		label.option = option
		label.parent = self
		label:RegisterForClicks("AnyUp")
		label:SetScript("OnClick", function(self, event)
			self.parent:Deselect(self.option)
		end)
		label:SetScript("OnEnter", function()
			events.OnEnter(self)
		end)
		label:SetScript("OnLeave", function()
			events.OnLeave(self)
		end)

		local cur_w = self.label_padding
		local cur_y = -self.label_padding * 2
		local prev_y
		for i=#self.labels,1,-1 do
			local label = self.labels[i]
			local this_x, this_y = select(4, label:GetPoint())
			local this_w = label:GetWidth()
			cur_y = this_y
			if not prev_y or abs(prev_y-this_y) < 2 then
				cur_w = cur_w + this_w + self.label_padding
				prev_y = this_y
			else
				cur_y = prev_y
				break
			end
		end

		local text = label:CreateFontString()
		label.text = text
		text:SetFont(blinkFont, floor(self.label_height * 0.6), '')
		text:SetText(option.label)
		text:SetShadowColor(sr, sg, sb, sa / 1.5)
		text:SetShadowOffset(sx, sy)
		text:SetHeight(self.label_height)

		-- temp arbitrary long width so we can determine font string length
		label:SetWidth(1000)
		label:SetHeight(self.label_height)

		local pwidth = self:GetWidth()
		-- check if only 1-2 labels this row and allow it to stretch a bit
		local labelWidth = min(pwidth / 2 - 10, text:GetWidth() + self.label_padding * 2)
		local height_updated
		if pwidth - cur_w - labelWidth - self.label_padding <= self.label_container_padding_right then
			cur_w = self.label_padding
			cur_y = cur_y - self.label_line_height
			height_updated = true
		end

		label:SetWidth(labelWidth)

		-- text:ClearAllPoints()
		-- text:Hide()

		-- text = label:CreateFontString()
		-- text:SetFont(blinkFont, self.label_height * 0.6)
		-- text:SetText(val)
		text:SetPoint("LEFT", 4, 0)
		text:SetPoint("RIGHT", -4, 0)
		-- text:Show()

		label:SetPoint("TOPLEFT", cur_w + self.label_padding, cur_y)
		
		tinsert(self.labels, label)

		if height_updated then
			local prev_height = self:GetHeight()
			self:SetHeight(prev_height + self.label_line_height)
			self.height = self.height + self.label_line_height
			self.lines_added = self.lines_added + 1 
			if self.scroll then
				self.scroll.frame:SetPoint("TOP", 0, -self:GetHeight())
			end
			self.parent:RepositionElements()
		end
		-- work backwards from latest label, add width of all labels + spacing on that y axis to 'taken width'
		-- when not enough space for a label, wrap + increase height, then re-calc viewport height (move dropdown scroll parent accordingly??)
		-- add label to self.labels table
	end,
	-- UpdateLabels = function(self)

	-- 	-- wipe existing labels
	-- 	for k, label in ipairs(self.labels) do
	-- 		self:RemoveLabel(label)
	-- 	end
	-- 	-- add labels for each selected option
	-- 	for value, _ in pairs(self.selected) do
	-- 		local option = self:FindOptionByValue(value)
	-- 		if option then
	-- 			self:AppendLabel(option)
	-- 		end
	-- 	end

	-- end,
	SetSelected = function(self, option)

		if type(option) == "string" or type(option) == "number" or type(option) == "table" and not option.value then
			option = self:FindOptionByValue(option)
		end

		if self.multi then

			self.selected = self.selected or {}
			local wasSelected

			if option then
				
				if self.selected[option.value] then wasSelected = true end
				if option.tvalue then
					self.selected[option.value] = option.tvalue
				else
					self.selected[option.value] = true
				end
			-- nah, mdd header should not clear all selected options when right clicked
			-- else
			-- 	self.selected = {}
			end

			self.saved[self.var] = self.selected

			if not wasSelected then
				self:AppendLabel(option)
				self:RerenderDropdownMenu()
			end

			-- close dropdown if no more options are left
			local remains = 0
			for _, option in ipairs(self.options) do
				if not self.selected[option.value] then
					remains = remains + 1
				end
			end
			if remains == 0 then self:SetOpen(false) end
		else
			self.selected = option
			if self.label then
				self.label:SetText(option and option.label or self.placeholder or "")
				self.labelType = option and "value" or "placeholder"
				self.value = option and option.value or nil
				self.saved[self.var] = option and option.value or nil
			end
			self:SetOpen(false)
		end

	end,
	Deselect = function(self, option)

		if type(option) == "string" or type(option) == "number" or type(option) == "table" and not option.value then
			option = self:FindOptionByValue(option)
		end

		if self.multi then
			if option then
				local new = {}
				for k, v in pairs(self.selected) do
					new[k] = v
				end
				new[option.value] = nil
				self.saved[self.var] = new
				self.selected[option.value] = nil
				self:RemoveLabel(option)
				self:RerenderDropdownMenu()
			end
		end

	end,
	FindOptionByValue = function(self, val)
		for _, option in ipairs(self.options) do
			if option.value == val then
				return option
			end
		end
	end
}

function TAB:RenderElement(el)
	
	local ui = self.ui
	local frame = ui.frame
	local parent = frame.view -- future multi-column potench (self.ui.sections[1])
	local text = el.text or el.name
	local var = el.var -- hook value setting function(s) to update element on external val change
	local saved = el.saved
	local padding = el.padding
	local tooltip = el.tooltip
	local default = el.default -- default setting

	local r,g,b = unpack(ui.currentTabAccentColors or ui.colors.accent)
	local pr, pg, pb, pa = unpack(ui.colors.primary)
	local ar, ag, ab, aa = unpack(ui.colors.tertiary)
	local mr, mg, mb, ma = unpack(ui.colors.background)
	local sr, sg, sb, sa, sx, sy = unpack(ui.shadows.primary)

	-- frame and all shared attributes
	local element = getFrame(parent, el.type)
	element.tooltip = nil
	element.name = nil
	for k, v in pairs(el) do
		element[k] = v
	end
	-- element.type = el.type
	-- element.tooltip = el.tooltip
	element.parent = parent
	element.saved = saved
	element.var = var
	element.ui = ui
	-- padding set for all elements
	element.padding = createPadding(padding)
	-- disables interactiveness of element when out of view
	function element:SetInteractive(enabled)
		if self.SetEnabled then
			self:SetEnabled(enabled)
		end
		self:EnableMouse(enabled)
	end

	--! CHECKBOX !--
	if el.type == "checkbox" then
		
		local box = element

		-- total vertical space taken by frame, not including 'padding'
		local height = 10.4
		box.height = height
		box.textGap = 5
		box.padding.top = 5
		box.padding.bottom = 5

		box:SetSize(height, height)
		box:SetNormalTexture("Interface\\Buttons\\WHITE8X8") 
		-- box:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up") 
		box:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD") 
		box:GetHighlightTexture():SetVertexColor(0.3,0.3,0.3,0.3)

		box.checkedTexture = box:CreateTexture('fchktxtr', "ARTWORK")
		box.checkedTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
		box.checkedTexture:SetColorTexture(r, g, b, 1)
		box.checkedTexture:SetWidth(9)
		box.checkedTexture:SetHeight(9)
		box.checkedTexture:SetPoint("CENTER", box, "CENTER", -0.00072, 0)
		box.checkedTexture:Hide()

		box.mask = box:CreateMaskTexture()
		box.mask:SetAllPoints(box.checkedTexture)
		-- box.mask:SetTexture("Interface\\Buttons\\UI-CheckBox-Up", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		box.mask:SetTexture("Interface\\Buttons\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

		-- use accent color here...
		box.border = box:CreateTexture('fchktxtr', "BORDER")
		box.border:SetTexture("Interface\\Buttons\\WHITE8X8")

		local br,bg,bb = unpack(ui.currentTabAccentColors or ui.colors.accent)
		box.border:SetColorTexture(br, bg, bb, 0.7)
		box.border:SetWidth(11.65)
		box.border:SetHeight(11.65)
		box.border:SetPoint("CENTER", box, "CENTER", -0.00032, 0)

		box:SetCheckedTexture(box.checkedTexture)
		-- box:GetNormalTexture():SetVertexColor(r*1.6,g*1.6,b*1.6,0.85)
		box:GetNormalTexture():SetVertexColor(mr,mg,mb,0.9)

		box.checkedTexture:AddMaskTexture(box.mask)

		box:SetFrameStrata("HIGH")
		box:SetChecked(saved[var]) -- set checked based on current value

		if default == true then
			if saved[var] == nil then
				box:SetChecked(default)
				saved[var] = default
			end
		end

		box:SetScript("OnClick", events.checkbox.OnClick)

		if box.tooltip then
			box:SetScript("OnEnter",events.OnEnter)
			box:SetScript("OnLeave",events.OnLeave)
		end

		box:SetScript("OnUpdate", events.checkbox.OnUpdate)

		box:SetText(text)
		box:GetFontString():SetFont(blinkFont, 9, '')
		box:GetFontString():SetShadowColor(sr, sg, sb, sa)
		box:GetFontString():SetShadowOffset(sx, sy)

		local est_char_w = 8

		local txt = box:GetFontString()
		-- -- third of w
		-- if strlen(text) < parent:GetWidth() / (est_char_w * 3) then
		-- 	txt:SetSize(parent:GetWidth() / 3 - 2, 20)
		-- 	txt:SetPoint("LEFT",parent:GetWidth() / 3 - 2, 0)
		-- --half of w
		-- else
		if strlen(text) < parent:GetWidth() / est_char_w then
			-- txt:SetSize(parent:GetWidth() / 2 - 6, 20)
			-- txt:SetPoint("LEFT", parent:GetWidth() / 2 - 6, -0.75)
		else
			-- txt:SetSize(parent:GetWidth() - 14,20)
			-- txt:SetPoint("LEFT", parent:GetWidth() - 14, -0.75)
		end

		txt:SetTextColor(pr, pg, pb, pa or 1)

		txt:SetHeight(20)
		txt:SetPoint("LEFT", min(parent:GetWidth() - 14, strlen(text) * est_char_w), -0.75)
		txt:SetPoint("RIGHT", box.textGap, -0.75)
		txt:SetJustifyV("MIDDLE")
		txt:SetJustifyH("LEFT")

		box.txt = txt

		-- start at 0 alpha frame 1 for less janky transition between tabs
		box:SetAlpha(0)
		box.pauseAlpha = GetTime()

		-- ahh so much nicer
		parent:AddElement(box)

	--! SLIDER !--
	elseif el.type == "slider" then

		local slider = element

		Mixin(slider, BackdropTemplateMixin)
		slider:ClearAllPoints()

		slider.min = el.min
		slider.max = el.max
		slider.value = saved[var] or el.value or el.default or el.min
		slider.step = el.step or 1
		slider.percentage = el.percentage
		slider.valueType = el.valueType
		slider.low = (el.low or el.min) .. (slider.valueType and slider.valueType or slider.percentage and "%" or "")
		slider.high = (el.high or el.max) .. (slider.valueType and slider.valueType or slider.percentage and "%" or "")
		slider.text = el.text

		local margin = -2

		slider.height = 24
		slider.padding.top = 24

		-- reduce top padding if prev el is slider / dropdown
		local prevElement = parent.elements[#parent.elements]
		if prevElement and (prevElement.type == "slider" or prevElement.type == "dropdown") then
			slider.padding.top = slider.padding.top - 6
		end

		slider.padding.bottom = 6
		slider.padding.left = margin
		-- slider.padding.right = margin / 2

		slider:ClearAllPoints()
		slider:SetBackdrop(ui.backdrops.white)
		slider:SetBackdropColor(mr * ui.colors.elMod, mg * ui.colors.elMod, mb * ui.colors.elMod, ui.colors.elAlpha)

		local ts = 10
		slider.thumbSize = ts

		if slider.NineSlice then
			slider.NineSlice:Hide()
		end

		slider.thumbTexture = slider:CreateTexture("sliderBnThing", "ARTWORK")
		slider.thumbTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
		slider.thumbTexture:SetWidth(ts)
		slider.thumbTexture:SetHeight(ts)
		slider.thumbTexture:SetColorTexture(r,g,b,1)
		slider.thumbTexture:ClearAllPoints()
		slider.thumbMask = slider:CreateMaskTexture()
		slider.thumbMask:SetAllPoints(slider.thumbTexture)
		slider.thumbMask:SetTexture("Interface/Masks/CircleMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		
		slider.thumbTexture:AddMaskTexture(slider.thumbMask)

		slider:SetThumbTexture(slider.thumbTexture)

		slider:SetScript("OnMouseDown", function(self) 
			self.thumbTexture:SetWidth(ts + 1) 
			self.thumbTexture:SetHeight(ts + 1)
			self.thumbTexture:SetColorTexture(r*1.05,g*1.05,b*1.05,1)
		end)
		slider:SetScript("OnMouseUp", function(self) 
			self.thumbTexture:SetWidth(ts) 
			self.thumbTexture:SetHeight(ts) 
			self.thumbTexture:SetColorTexture(r,g,b,1)
		end)

		-- _G.slider = slider

		-- if el.range then
		-- 	if not slider.secondaryThumb then
		-- 		local thumb = getFrame(slider, "secondarySliderThumb")
		-- 		-- thumb:SetWidth(8)
		-- 		-- thumb:SetHeight(8)
		-- 		thumb:SetMovable(true)
		-- 		thumb:SetFrameStrata("HIGH")
		-- 		thumb:SetPoint("LEFT", 0, 0)
		-- 		thumb:SetPoint("RIGHT", 0, 0)
		-- 		thumb.texture = thumb:CreateTexture(thumb, "HIGH")
		-- 		thumb.texture:SetPoint("CENTER", 0, 0)
		-- 		thumb.texture:SetWidth(8)
		-- 		thumb.texture:SetHeight(8)
		-- 		thumb:SetScript("OnMouseUp",function(self) 
		-- 			self:StopMovingOrSizing()
		-- 			local p1, pframe, p2, x, y = self:GetPoint()
		-- 			y = 0
		-- 			if x > slider:GetWidth() then
		-- 				x = slider:GetWidth()
		-- 			end
		-- 			self:SetPoint(p1, pframe, p2, x, y)
		-- 		end)
		-- 		thumb:SetScript("OnMouseDown",function(self) 
		-- 			self:StartMoving()
		-- 			local p1, pframe, p2, x, y = self:GetPoint()
		-- 		end)
		-- 		slider.secondaryThumb = thumb
		-- 	end
		-- 	slider.secondaryThumb.texture:SetTexture(slider.thumbTexture)
		-- elseif slider.secondaryThumb then
		-- 	slider.secondaryThumb:Hide()
		-- end

		slider:SetWidth(parent:GetWidth() - ui.el_padding_right - margin)
		slider:SetHeight(8)
		slider:SetMinMaxValues(slider.min, slider.max)
		slider:SetValueStep(slider.step)
		slider:SetValue(slider.value)

		local LOW = getglobal(slider:GetName()..'Low') --_G[name .. 'Low']
		local HIGH = getglobal(slider:GetName()..'High') --_G[name .. 'High']
		local TEXT = getglobal(slider:GetName()..'Text') -- _G[name .. 'Text']
		slider.TEXT = TEXT
		
		local valueColor = rgb2hex({r,g,b})
		slider.valueColor = valueColor

		LOW:SetText(slider.low)
		LOW:SetFont(blinkFont, 7, '')
		HIGH:SetText(slider.high)
		HIGH:SetFont(blinkFont, 7, '')
		TEXT:SetText(slider.text .. ": " .. valueColor .. slider.value .. (slider.valueType and slider.valueType or slider.percentage and "%" or ""))
		TEXT:SetFont(blinkFont, 9, '')

		TEXT:SetSize(slider:GetWidth(), 12)
		TEXT:SetJustifyV("MIDDLE")
		TEXT:SetJustifyH("LEFT")

		if not TEXT.moved then
			local anchor, _, _, x, y = TEXT:GetPoint()
			TEXT:SetPoint(anchor, x + 2, y + 14)
			TEXT:SetTextColor(pr, pg, pb, 1)
			TEXT:SetShadowColor(sr, sg, sb, sa)
			TEXT:SetShadowOffset(sx, sy)
			TEXT.moved = true
		end

		if not LOW.moved then
			local anchor, _, _, x, y = LOW:GetPoint()
			LOW:SetPoint(anchor, x + 7, y - 15)
			LOW:SetTextColor(ar, ag, ab, max(aa, 0.65))
			LOW:SetShadowColor(sr, sg, sb, sa / 3)
			LOW:SetShadowOffset(sx, sy)
			LOW.moved = true
		end

		if not HIGH.moved then
			local anchor, _, _, x, y = HIGH:GetPoint()
			HIGH:SetPoint(anchor, x - 7, y - 15)
			HIGH:SetTextColor(ar, ag, ab, max(aa, 0.65))
			HIGH:SetShadowColor(sr, sg, sb, sa / 3)
			HIGH:SetShadowOffset(sx, sy)
			HIGH.moved = true
		end

		slider:SetScript("OnUpdate", events.slider.OnUpdate)
		slider:SetScript("OnValueChanged", events.slider.OnValueChanged)

		if slider.tooltip then
			slider:SetScript("OnEnter",events.OnEnter)
			slider:SetScript("OnLeave",events.OnLeave)
		end

		slider:SetAlpha(0)
		slider.pauseAlpha = GetTime()

		parent:AddElement(slider)
	
	elseif el.type == "dropdown" or el.type == "multiDropdown" then

		local dropdown = element
		dropdown:SetFrameStrata("HIGH")
		Mixin(dropdown, BackdropTemplateMixin)
		dropdown:SetBackdrop(ui.backdrops.main)

		dropdown:SetBackdropColor(mr,mg,mb,norm(ma * 1.15))
		dropdown:SetBackdropBorderColor(mr, mg, mb, norm(ma * 1.15))
		-- dropdown:SetBackdropColor(mr * ui.colors.elMod, mg * ui.colors.elMod, mb * ui.colors.elMod, ui.colors.elAlpha)
		-- dropdown:SetBackdropBorderColor(mr * ui.colors.elMod, mg * ui.colors.elMod, mb * ui.colors.elMod, ui.colors.elAlpha)
		dropdown:SetWidth(parent:GetWidth() - ui.el_padding_right)
		
		dropdown.multi = el.multi
		dropdown.labels = {}
		dropdown.label_height = 12
		dropdown.label_padding = 5
		dropdown.label_container_padding_right = 25
		dropdown.label_line_height = 16
		dropdown.lines_added = 0
		dropdown.header = el.header or el.text or el.name
		dropdown.original_height = 30
		dropdown.height = dropdown.original_height
		dropdown.max_height = dropdown.height + dropdown.label_line_height * 2
		dropdown:SetHeight(dropdown.height)
		dropdown.padding.bottom = 8
		dropdown.padding.top = 6 + bin(dropdown.header) * 16

		-- reduce top padding if prev el is slider / dropdown
		local prevElement = parent.elements[#parent.elements]
		if prevElement and (prevElement.type == "slider" or prevElement.type == "dropdown") then
			dropdown.padding.top = dropdown.padding.top - 8
		end

		dropdown.placeholder = el.placeholder
		dropdown.options = el.options
		dropdown.default = el.default

		-- set these after current selections are all sorted out
		dropdown.valid_options = {}

		for k, v in pairs(DropdownMethods) do
			dropdown[k] = v
		end

		dropdown:RegisterForClicks("AnyUp")
		dropdown:SetScript("OnClick", events.dropdown.OnClick)

		if dropdown.tooltip then
			dropdown:SetScript("OnEnter", events.OnEnter)
			dropdown:SetScript("OnLeave", events.OnLeave)
		end

		dropdown.initArrowX = -12
		dropdown.initArrowY = 0

		if dropdown.header then
			local header = dropdown.text
			if not header then
				header = dropdown:CreateFontString()
				header:SetFont(blinkFont, 9, '')
				header:ClearAllPoints()
				header:SetHeight(10)
				local y_offset = dropdown:GetHeight()
				header:SetPoint("LEFT", 0, 0)
				header:SetPoint("RIGHT", -28, 0)
				header:SetPoint("TOP", 0, 14)
				header:SetJustifyH("LEFT")
				dropdown.text = header
			else
				header:Show()
			end
			header:SetText(dropdown.header)
			header:SetShadowColor(sr, sg, sb, sa)
			header:SetShadowOffset(sx, sy)
			header:SetTextColor(pr, pg, pb, pa or 1)
		else
			local header = dropdown.text
			if header then
				header:Hide()
			end
		end
		--! Multi Dropdown Selection Badges !--
		if dropdown.multi then
			-- add defaults to selected if saved var doesn't already exist
			if not saved[var] then
				dropdown.selected = {}
				if dropdown.default then
					for k, v in pairs(dropdown.default) do
						dropdown.selected[v] = true
					end
				end
				saved[var] = dropdown.selected
			else
				dropdown.selected = saved[var]
			end
			-- establish initial labels from any selected options
			for selection in pairs(dropdown.selected) do
				local option = dropdown:FindOptionByValue(selection)
				if option then
					dropdown:AppendLabel(option)
				end 
			end

			if dropdown.placeholder then
				dropdown.label = dropdown:CreateFontString()
				dropdown.label:SetFont(blinkFont, 9, '')
				dropdown.label:ClearAllPoints()
				dropdown.label:SetHeight(10)
				dropdown.label:SetPoint("LEFT", 10, 0)
				dropdown.label:SetPoint("RIGHT", -28, 0)
				dropdown.label:SetJustifyH("LEFT")
				dropdown.label:SetShadowColor(sr, sg, sb, sa / 3)
				dropdown.label:SetShadowOffset(sx, sy)
	
				dropdown.label:SetTextColor(pr*0.8,pg*0.8,pb*0.8,1)
				dropdown.label:SetText(dropdown.placeholder)
				dropdown.label:Hide()
			end

		--! Normal Dropdown Label !--
		else
			local label = dropdown.label
			if not label then
				label = dropdown:CreateFontString()
				label:SetFont(blinkFont, 9, '')
				label:ClearAllPoints()
				label:SetHeight(10)
				label:SetPoint("LEFT", 10, 0)
				label:SetPoint("RIGHT", -28, 0)
				label:SetJustifyH("LEFT")
				label:SetShadowColor(sr, sg, sb, sa / 3)
				label:SetShadowOffset(sx, sy)
				dropdown.label = label
			end
			label:Show()
			if dropdown.value then
				dropdown.labelType = "value"
			else
				dropdown.labelType = "placeholder"
			end
			dropdown.colorType = dropdown.labelType
			if dropdown.labelType == "value" then
				label:SetTextColor(pr,pg,pb,1)
			else
				label:SetTextColor(pr*0.8,pg*0.8,pb*0.8,1)
			end
			label:SetText(dropdown.value or dropdown.placeholder)
		end

		if not dropdown.arrow then
			dropdown.arrow = dropdown:CreateTexture('ddartxr', "ARTWORK")
			dropdown.arrow:SetTexture("Interface\\Buttons\\WHITE8X8")
			dropdown.arrow:SetWidth(3)
			dropdown.arrow:SetHeight(7)
			-- dropdown.arrow:SetMask("Interface\\OPTIONSFRAME\\VoiceChat-Play", "CLAMPTOBLACKADDITIVE")
			-- dropdown.arrow:SetRotation(rad(270))
			dropdown.arrow:SetRotation(rad(90))
			dropdown.arrow:SetVertexColor(r * 1.02, g * 1.02, b * 1.02, 1)
			dropdown.arrow:SetPoint("RIGHT", dropdown, "RIGHT", dropdown.initArrowX, dropdown.initArrowY)
		else
			dropdown.arrow:Show()
		end

		dropdown.menu = getFrame(dropdown, "dropdownMenu")
		dropdown.menu:ClearAllPoints()
		dropdown.menu:SetAllPoints(dropdown)
		dropdown.menu:SetFrameStrata("TOOLTIP")

		local scr = {}
		dropdown.scroll = scr

		scr.frame = getFrame(dropdown.menu, "dropdownMenuScrollFrame")
		scr.frame:ClearAllPoints()
		scr.frame:SetPoint("TOP", 0, -dropdown:GetHeight())
		scr.frame:SetWidth(dropdown:GetWidth())
		Mixin(scr.frame, BackdropTemplateMixin)
		scr.frame:SetBackdrop(UI.backdrops.main)
		scr.frame:SetBackdropColor(mr, mg, mb, 0.92)
		scr.frame:SetBackdropBorderColor(mr, mg, mb, 0.92)

		local menu_padding = 6
		local button_height = 24

		dropdown.menu_padding = menu_padding
		dropdown.button_height = button_height

		scr.frame:SetScript("OnMousewheel", function(self, event)
			local step = button_height
			local cur = scr.frame:GetVerticalScroll()
			local max_scroll = ceil(scr.frame:GetVerticalScrollRange())
			local new = max(0, min(max_scroll, cur + step * -event))
			if self.resetNextUp and event == 1 then
				new = new - 3
				self.resetNextUp = nil
			end
			if max_scroll - new <= menu_padding and self.ScrollBar:IsShown() then 
				new = max_scroll + 3
				self.resetNextUp = true
				-- have to do this twice to fix visual bug lol
				scr.frame:SetVerticalScroll(new)
			end
			scr.frame:SetVerticalScroll(new)
		end)

		scr.child = getFrame(nil, "dropdownScrollChild") --CreateFrame("Frame")
		scr.child:ClearAllPoints()
		scr.child:SetWidth(dropdown:GetWidth())
		scr.frame:SetScrollChild(scr.child)

		dropdown:RerenderDropdownMenu()

		dropdown:SetAlpha(0)
		dropdown.pauseAlpha = GetTime()

		dropdown.menu:Hide()

		if not dropdown.multi then
			-- restore selection from saved variable
			if saved[var] then
				local option = dropdown:FindOptionByValue(saved[var])
				if option then
					dropdown:SetSelected(option)
				end
			end
			-- set default if none
			if dropdown.default and not dropdown.selected then
				local option = dropdown:FindOptionByValue(dropdown.default)
				if option then
					dropdown:SetSelected(option)
				end
			end
		end

		dropdown.init = true
		dropdown:SetScript("OnUpdate", events.dropdown.OnUpdate)

		parent:AddElement(dropdown)

	elseif el.type == "text" then

		local container = element
		
		local size = el.size or el.header and 12 or 9

		container:SetWidth(parent:GetWidth() - ui.el_padding_right)
		container:SetHeight(size)

		if not container.fontString then
			container.fontString = container:CreateFontString(nil, "ARTWORK")		
		end
		container.fontString:SetFont(blinkFont, size, '')
		container.fontString:SetText(container.text)
		container.fontString:SetTextColor(pr,pg,pb,pa)
		container.fontString:SetPoint("LEFT", 0, 0)
		container.fontString:SetPoint("RIGHT", 0, 0)
		container.fontString:SetJustifyH("LEFT")
		
		container.height = container:GetHeight()
		container.padding.top = el.paddingTop or 5 + bin(el.header) * 5
		container.padding.bottom = el.paddingBottom or 5 + bin(el.header) * 2
		container.padding.left = el.paddingLeft or 0
		container.padding.right = el.paddingRight or 0

		container:SetScript("OnUpdate", events.text.OnUpdate)

		if el.OnClick then
			container:SetScript("OnClick", el.OnClick)
		else	
			container:SetScript("OnClick", function() end)
		end
		parent:AddElement(container)

	end

end

function UI:FindTabObject(name)
	if not name then return end
	for _, tab in ipairs(self.tabs) do
		if tab and tab.group then
			for _, subTab in ipairs(tab.tabs) do
				if subTab and (subTab.uid == name or subTab.name == name) then
					return subTab
				end
			end
		end
		if tab and (tab.uid == name or tab.name == name) then
			return tab
		end
	end
end

function UI:SetTab(tab)
	
	-- collapse / expand groups
	if tab.group then
		if tab.open then
			tab:Collapse()
		else
			tab:Expand()
		end
		return
	end 

	-- normal tabs	
	if not tab.RenderElement then
		tab = self:FindTabObject(tab.uid)
	end
	self.currentTab = tab

	self.currentTabAccentColors = nil
	local ct = self.currentTab
	if ct and ct.inGroup then
		if ct.inGroup.colors and ct.inGroup.colors.accent then
			self.currentTabAccentColors = ct.inGroup.colors.accent
		end
		self:UpdateTitle(ct.inGroup.colors, ct.inGroup.title)
	else
		self:UpdateTitle()
	end
	
	for _, section in ipairs(self.sections) do
		section:Clear()
	end
	if tab.elements then
		for _, element in ipairs(tab.elements) do
			tab:RenderElement(element)
		end
	end

	if tab.inGroup and not tab.rerendered then
		for _, section in ipairs(self.sections) do
			section:Clear()
		end
		if tab.elements then
			for _, element in ipairs(tab.elements) do
				tab:RenderElement(element)
			end
		end
		tab.rerendered = true
	end

	for _, section in ipairs(self.sections) do
		if tab.scrollPos then
			local cv = tab.scrollPos[section.name]
			if cv then
				section.scroll.pos = cv
				C_Timer.After(0, function()
					section.scroll.frame:SetValue(cv)
					tab.scrollPos[section.name] = cv
				end)
			end
		end
	end

end

function UI:Rerender(keepPos)
	self.frame.tabs:Clear(keepPos)
	if not keepPos then
		self.currentTab = nil
	end
	for i, tab in ipairs(self.tabs) do
		if tab.group then
			self:RenderGroup(tab, { bottom = 3, left = 12 })
		else
			self:RenderTab(tab, { bottom = 3, left = 12 })
		end
	end
	if not keepPos then
		self:SetTab(self:FindTabObject(self.defaultTab) or self.tabs[1])
	end
end

-- status frame
local StatusFrame = {}
StatusFrame.__index = StatusFrame

function UI:StatusFrame(options)

	if not self.StatusFramesList then
		self.StatusFramesList = {}
	end

	local sfl = self.StatusFramesList
	local sfl_length = #sfl
	local sf_var = "sf"..sfl_length

	local saved
	if options.use then
		local cfg = options.use
		if type(cfg) == "string" then
			if not self.saved[cfg] then
				local newCfg = blink.NewConfig(self.name.."_"..cfg)
				rawset(self.saved, cfg, newCfg)
				saved = newCfg
			else
				saved = self.saved[cfg]
			end
		end
	else
		saved = self.saved
	end

	local sf = options or {}
	sf.sf_var = sf_var
	sf.maxWidth = sf.maxWidth or 250
	sf.__index = StatusFrame
	sf.ui = self
	sf.fontSize = sf.fontSize or 12
	sf.colors = sf.colors or {}
	sf.saved = saved
	sf.colors.value = adjust_color((sf.colors.value or {100,245,100,1}))
	sf.colors.enabled = adjust_color((sf.colors.enabled or sf.colors.value))
	sf.colors.disabled = adjust_color((sf.colors.disabled or {245,100,100,1}))
	sf.colors.primary = adjust_color((sf.colors.primary or {255,255,255,1}))
	sf.colors.background = adjust_color((sf.colors.background or {0, 0, 0, 1}))
	sf.uid = math.random(0,999999)
	sf.elements = {}
	sf.padding = options.padding or 8
	setmetatable(sf, StatusFrame)

	local f = CreateFrame("Frame")
	Mixin(f, BackdropTemplateMixin)
	f:SetMovable(true)
	f:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing() 
		saved[sf_var.."p1"], saved[sf_var.."pframe"], saved[sf_var.."p2"], saved[sf_var.."x"], saved[sf_var.."y"] = self:GetPoint()
	end)
	f:SetScript("OnMouseDown",function(self)
		if saved.sf_locked then return end
		self:StartMoving()
	end)
	f:SetBackdrop(self.backdrops.main)
	local r,g,b,a = unpack(sf.colors.background)
	f:SetBackdropColor(r,g,b,a)
	f:SetBackdropBorderColor(r,g,b,a)

	function sf:IsShown()
		return f:IsShown()
	end
	function sf:Hide()
		return f:Hide()
	end
	function sf:Show()
		return f:Show()
	end

	f:SetScript("OnEnter", function(self)
		self.lock:SetAlpha(0.75)
		local thisAlpha = max(0, min(1, 0.2 + a * 2.5)) or 1
		self:SetBackdropColor(r,g,b,thisAlpha,thisAlpha)
		self:SetBackdropBorderColor(r,g,b,thisAlpha,thisAlpha)
	end)

	f:SetScript("OnLeave", function(self)
		self.lock:SetAlpha(0)
		self:SetBackdropColor(r,g,b,a or 0)
		self:SetBackdropBorderColor(r,g,b,a or 0)
	end)

	f:SetWidth(100)
	f:SetHeight(100)

	local p1, pframe, p2, x, y = saved[sf_var.."p1"], saved[sf_var.."pframe"], saved[sf_var.."p2"], saved[sf_var.."x"], saved[sf_var.."y"]
	f:SetPoint(p1 or "CENTER", "UIParent", p2 or "CENTER", x or 0, y or -100)

	local lock = CreateFrame("Button", f)
	lock:SetParent(f)
	lock:SetWidth(12)
	lock:SetHeight(12)
	lock:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	lock:SetFrameStrata("TOOLTIP")

	function lock:SetIconColor(locked)
		local r,g,b,a
		if locked then
			r,g,b,a = 1,0.4,0.1,1
		else
			r,g,b,a = 0.4,1,0.2,1
		end
		self.icon:SetVertexColor(r,g,b,a)
	end

	lock:SetScript("OnEnter", function(self)
		self:SetAlpha(1)
	end)
	lock:SetScript("OnLeave", function(self)
		self:SetAlpha(0)
	end)
	lock:SetScript("OnClick", function(self)
		saved.sf_locked = not saved.sf_locked
		if saved.sf_locked then
			f:EnableMouse(false)
			blink.alert("Frame |cFFffa463Locked")
		else 
			f:EnableMouse(true)
			blink.alert("Frame |cFFa1ff6eUnlocked")
		end
		self:SetIconColor(saved.sf_locked)
	end)
	lock:SetAlpha(0)
	lock.icon = lock:CreateTexture('locktxtrklo', "ARTWORK")
	lock.icon:SetAllPoints(lock)
	lock.icon:SetTexture("Interface\\PetBattles\\PetBattle-LockIcon")
	lock:SetIconColor(saved.sf_locked)
	f.lock = lock
	f:EnableMouse(not saved.sf_locked)

	-- updates
	f.updateCallbacks = {}
	f:SetScript("OnUpdate", function(self)
		-- auto wrap elements & update text values
		-- handle height/width conformity
		sf:Update()
		-- callbacks
		for i=1,#self.updateCallbacks do
			self.updateCallbacks[i](self)
		end
	end)

	tinsert(self.StatusFramesList, sf)
	sf.frame = f

	return sf

end

function StatusFrame:String(options)

	if type(options) ~= "table" then return false end
	if type(options.var) ~= "string" then return false end

	local saved = self.saved
	local initText = type(saved[options.var]) == "string" and saved[options.var] or ""

	local f = self.frame
	local txt = f:CreateFontString()
	txt.type = "string"
	txt.var = options.var

	txt:SetFont(blinkFont, 12, '')
	txt:SetText(initText)
	local r,g,b,a = unpack(self.colors.primary)
	txt:SetTextColor(r,g,b,a)
	self:AddElement(txt)

	return txt

end

function StatusFrame:Toggle(options)

	if type(options) ~= "table" then return false end
	if type(options.var) ~= "string" then return false end

	local sf = self
	local saved = self.saved

	local f = self.frame

	local txt
	if options.onClick then
		txt = CreateFrame("Button", f)
		txt:SetParent(f)
		txt.onClick = true
		txt.txt = txt:CreateFontString()
		txt:SetFrameStrata("HIGH")
		txt.txt:SetPoint("CENTER", txt, "CENTER", 0, 0)
		txt:SetWidth(1000)
		txt:SetHeight(20)
	else
		txt = f:CreateFontString()
	end
	
	txt.type = "toggle"
	txt.var = options.var
	txt.label = options.label
	txt.valueText = options.valueText

	function txt:Update()
		local str = self.label .. " "
		local vtext = self.valueText
		local val = saved[self.var]

		if type(vtext) == "function" then
			local res = vtext(val)
			if res and tostring(res) then
				local hexColor = rgb2hex(sf.colors.value)
				str = str .. hexColor .. tostring(res)
			else
				str = ""
			end
		else
			if type(val) == "string" or type(val) == "number" then
				local hexColor = rgb2hex(sf.colors.value)
				str = str .. hexColor .. val .. "|r"
			elseif val then
				local hexColor = rgb2hex(sf.colors.enabled)
				str = str .. hexColor .. "Enabled" .. "|r"
			else
				local hexColor = rgb2hex(sf.colors.disabled)
				str = str .. hexColor .. "Disabled" .. "|r"
			end
		end

		local f = self.onClick and self.txt or self
		f:SetText(str)
	end

	if options.onClick then
		txt:RegisterForClicks("LeftButtonUp")

		function txt:UpdateWidth()
			self:SetWidth(self.txt:GetWidth())
			self:SetHeight(self.txt:GetHeight())
		end

		txt:SetScript("OnClick", function(self)
			options.onClick(self)
			self:Update()
			self:UpdateWidth()
		end)
		txt:SetScript("OnUpdate", function(self)
			self:UpdateWidth()
		end)
	end

	local actualText = txt.onClick and txt.txt or txt
	actualText:SetFont(blinkFont, 12, '')
	actualText:SetText(initText)
	local r,g,b,a = unpack(self.colors.primary)
	actualText:SetTextColor(r,g,b,a)

	self:AddElement(txt)

	return txt

end

function StatusFrame:Button(options)

	if type(options) ~= "table" then blink.print("Please pass options as table to StatusFrame:Button") return false end
	if type(options.var) ~= "string" then blink.print("Please pass var as string in StatusFrame:Button options") return false end
	if not options.spellId and not options.spellID then blink.print("Please pass spellId as number or function in StatusFrame:Button options") return false end

	local parent = self.frame
	local shouldShow = options.shouldShow
	
	local btnParent = CreateFrame("Button", parent)

	local btn = CreateFrame("Button", btnParent)
	btnParent.btn = btn

	local textureFrame = CreateFrame("Frame", nil, btn)

	local spellId, spellName = options.spellId or options.spellID, options.spellName

	local functionalSpellId = type(spellId) == "function"

	local text = options.text
	local textSize = options.textSize or 11
	local size = options.size or 30

	btnParent:SetSize(size, size)
	btnParent:SetParent(parent)
	
	btn:SetSize(size, size)
	btn:SetParent(btnParent)
	btn:SetPoint("CENTER", 0 ,0)
	btn.sf = self
	
	btn:EnableMouse(true)
	btn:SetClampedToScreen(true)

	-- This is what your button texture looks like
	btn:SetNormalTexture(C_Spell.GetSpellTexture(functionalSpellId and spellId() or spellId))
	
	btn.saved = self.saved
	btnParent.saved = self.saved

	local var = options.var
	local varState = self.saved[var]

	function btnParent:Update()
		local val = self.saved[var]

		if functionalSpellId then
			btn:SetNormalTexture(C_Spell.GetSpellTexture(spellId()))
		end

		if shouldShow then
			if shouldShow(val) then
				self:Show()
			else
				self:Hide()
			end
		end

		if type(text) == "string" then
			-- set button subtext to text
			if textureFrame.text:GetText() ~= text then
				textureFrame.text:SetText(text)
			end
		elseif type(text) == "table" then
			-- set button subtext to text.enabled/disabled based on var state
			if self.saved[var] then
				if textureFrame.text:GetText() ~= text.enabled then
					textureFrame.text:SetText(text.enabled)
				end
			else
				if textureFrame.text:GetText() ~= text.disabled then
					textureFrame.text:SetText(text.disabled)
				end
			end
		elseif type(text) == "function" then
			-- set button subtext to text(varState)
			local text = text(self.saved[var])
			if textureFrame.text:GetText() ~= text then
				textureFrame.text:SetText(text)
			end
		end

		if textureFrame.text:GetText() ~= "" then
			btnParent:SetWidth(max(textureFrame.text:GetStringWidth(), size))
		end

		if not val then
			textureFrame.texture:SetTexture([[Interface\GLUES\CREDITS\Arakkoa1]])
		else
			textureFrame.texture:SetTexture([[Interface/BUTTONS/CheckButtonHilight-Blue]])
		end
		
	end

	btn:SetScript("OnMouseDown", function(self)
		if IsShiftKeyDown() then
			local btn = self
			local sf = self.sf
			local f = sf.frame
			f:StartMoving()
			C_Timer.NewTicker(0, function(self)
				btn.ignoreClicks = GetTime()
				if not IsMouseButtonDown("LeftButton") then
					f:StopMovingOrSizing()
					local sf_var = sf.sf_var
					local saved = sf.saved
					saved[sf_var.."p1"], saved[sf_var.."pframe"], saved[sf_var.."p2"], saved[sf_var.."x"], saved[sf_var.."y"] = f:GetPoint()
					self:Cancel()
				end
			end)
			return
		end
	end)

	btn:SetScript("OnClick", function(self)
		if self.ignoreClicks and GetTime() - self.ignoreClicks < 0.1 then return end 
		
		if not options.disableValueToggle then
			if not self.saved[var] then
				self.saved[var] = true
				-- This is the highlight effect of your button while enabled
				textureFrame.texture:SetTexture([[Interface/BUTTONS/CheckButtonHilight-Blue]])
			else
				self.saved[var] = false
				textureFrame.texture:SetTexture([[Interface\GLUES\CREDITS\Arakkoa1]])
			end
		end

		if type(text) == "string" then
			-- set button subtext to text
			textureFrame.text:SetText(text)
		elseif type(text) == "table" then
			-- set button subtext to text.enabled/disabled based on var state
			if self.saved[var] then
				textureFrame.text:SetText(text.enabled)
			else
				textureFrame.text:SetText(text.disabled)
			end
		elseif type(text) == "function" then
			-- set button subtext to text(varState)
			textureFrame.text:SetText(text(self.saved[var]))
		end

		if textureFrame.text:GetText() ~= "" then
			btnParent:SetWidth(max(textureFrame.text:GetStringWidth(), size))
		end

		if options.onClick then
			options.onClick()
		end
		
	end)
	
	size = size + 5
	textureFrame:SetWidth(size * 1.8)
	textureFrame:SetHeight(size * 1.8)
	textureFrame:SetPoint("CENTER")
	textureFrame.texture = textureFrame:CreateTexture(nil, "OVERLAY")
	textureFrame.texture:SetAllPoints()
	textureFrame.texture:SetWidth(size * 1.8)
	textureFrame.texture:SetHeight(size * 1.8)
	textureFrame.texture:SetAlpha(1)

	textureFrame.text = textureFrame:CreateFontString(nil, "OVERLAY")
	textureFrame.text:SetFont(blinkFont, textSize, '')
	textureFrame.text:SetPoint("BOTTOM", 0, -1)
	textureFrame.text:SetTextColor(1, 1, 1, 1)
	
	if type(text) == "string" then
		-- set button subtext to text
		textureFrame.text:SetText(text)
	elseif type(text) == "table" then
		-- set button subtext to text.enabled/disabled based on var state
		if self.saved[var] then
			textureFrame.text:SetText(text.enabled)
		else
			textureFrame.text:SetText(text.disabled)
		end
	elseif type(text) == "function" then
		-- set button subtext to text(varState)
		textureFrame.text:SetText(text(self.saved[var]))
	end

	if textureFrame.text:GetText() ~= "" then
		btnParent:SetWidth(max(textureFrame.text:GetStringWidth(), size))
	end

	if not varState then
		textureFrame.texture:SetTexture([[Interface\GLUES\CREDITS\Arakkoa1]])
	else
		textureFrame.texture:SetTexture([[Interface/BUTTONS/CheckButtonHilight-Blue]])
	end

	self:AddElement(btnParent)

	return btnParent

end

function StatusFrame:AddElement(el)
	local f = self.frame
	local prev = self.elements[#self.elements]
	while prev and not prev:IsShown() do
		prev = self.elements[#self.elements - 1]
	end
	local p1, pframe, p2, x, y = "TOPLEFT", f, "TOPLEFT", self.padding, -self.padding
	if prev then
		p1, pframe, p2, x, y = prev:GetPoint()
		x = x + prev:GetWidth() + self.padding
	end
	el:SetPoint(p1, pframe, p2, x, y)
	tinsert(self.elements, el)
end

function StatusFrame:WrapElements()

	local f = self.frame

	-- return total height at end, use to apply height in Update
	local max_width = self.maxWidth
	local width, height = self.padding, self.padding * 2
	local longest_prev_width = 0
	local prev_y, prev_x, prev_w = 0, 0, 0
	local highest_this_y, remaining_w_this_y = 0, max_width
	local hidden_elements = 0

	for i, el in ipairs(self.elements) do 

		if el:IsShown() then
			local el_h = el:GetHeight()
			local el_w = el:GetWidth()

			-- width calcs
			local x, y = prev_x + prev_w, prev_y
			-- wrap to new row when out of width
			if i - hidden_elements > 1 then
				if self.column or remaining_w_this_y - el_w - self.padding < self.padding then
					y = y - (highest_this_y + self.padding)
					height = height + (self.column and el_h or highest_this_y) - (self.padding / 2)
					highest_this_y = el_h
					x = 0
					prev_x = 0
					remaining_w_this_y = max_width
					longest_prev_width = max(longest_prev_width, width)
					width = self.padding
				end
			end

			width = width + el_w + self.padding

			-- if i < 5 then
			-- 	print(i, el:GetText(), el_w, width, remaining_w_this_y)
			-- end

			el:SetPoint("TOPLEFT", f, "TOPLEFT", x + self.padding, y - self.padding)

			-- add tallest el on this y axis to height calc
			if y ~= prev_y then
				height = height + el_h
				highest_this_y = el_h
			elseif el_h > highest_this_y then
				height = height + el_h - highest_this_y
				highest_this_y = el_h
			end

			-- remove remaining w from this y
			remaining_w_this_y = remaining_w_this_y - el_w - self.padding
			prev_x = x + el_w + self.padding
			prev_y = y
		else
			hidden_elements = hidden_elements + 1
		end

	end
	
	return max(longest_prev_width, width), height

end

function StatusFrame:Update()
	
	local frame, saved = self.frame, self.ui.saved
	
	-- iterate elements
	for _, el in ipairs(self.elements) do 
		-- update text for variables that have changed
		if el.type == "string" then
			el:SetText(saved[el.var])
		end
		-- update method where it exists
		if el.Update then
			el:Update()
		end
	end

	local width, height = self:WrapElements()

	-- update dimensions of frame
	frame:SetHeight(height)
	frame:SetWidth(width)

end

-- export ui object for external use
blink.UI = UI

-- local backdrop = {
-- 	bgFile = "Interface\\Buttons\\WHITE8X8",
-- 	tile = true,
-- 	tileEdge = true,
-- 	tileSize = 16
-- }

-- local f = CreateFrame("Frame")
-- Mixin(f, BackdropTemplateMixin)
-- f:SetBackdrop(backdrop)
-- f:SetBackdropColor(0,0,0,0.75)
-- f:SetWidth(250)
-- f:SetHeight(200)
-- f:SetPoint("CENTER", 0, 0)

-- f.s = CreateFrame("Frame", f)
-- Mixin(f.s, BackdropTemplateMixin)
-- f.s:SetBackdrop(UI.backdrops.main)
-- f.s:SetBackdropColor(0,0,0,0.5)
-- f.s:SetWidth(150)
-- f.s:SetHeight(5)
-- f.s:SetPoint("CENTER", 0, 0)

-- local s = f.s

-- s.t = CreateFrame("Frame", s)
-- s.t:SetWidth(8)
-- s.t:SetHeight(8)
-- s.t:SetParent(s)
-- s.t:SetPoint("LEFT", s, "LEFT", 0, 0)
-- s.t:SetMovable(true)
-- s.t:SetScript("OnUpdate", function(self)

-- end)

-- function f.s:bound(x)
-- 	return max(0, min(x, self:GetWidth()))
-- end

-- s.t:SetScript("OnMouseUp",function(self)
-- 	-- on release, set final point to deficit of original pos & (x,y) delta
-- 	local _, _, _, x, y = self:GetPoint()
-- 	self:StopMovingOrSizing()
-- 	local ogp1, ogpframe, ogp2, ogx, ogy = unpack(self.moving.pos1)
-- 	local _, _, _, rx, ry = unpack(self.moving.pos2)
-- 	local dx = x - rx
-- 	local dy = y - ry
-- 	self:SetPoint(ogp1, ogpframe, ogp2, f.s:bound(ogx + dx), 0)
-- end)
-- s.t:SetScript("OnMouseDown",function(self)
-- 	-- grab first pos relative to slider frame
-- 	self.moving = {
-- 		pos1 = {self:GetPoint()}
-- 	}
-- 	self:StartMoving()
-- 	-- grab init pos relative to screen
-- 	self.moving.pos2 = {self:GetPoint()}
-- end)

-- f.tt = s.t:CreateTexture(s.t, "HIGH")
-- f.tt:SetTexture("Interface\\Buttons\\WHITE8X8")
-- f.tt:SetWidth(8)
-- f.tt:SetHeight(8)
-- f.tt:SetColorTexture(1,0.6,0.1,1)
-- f.tt:SetAllPoints(s.t)
-- -- f.tt:ClearAllPoints()
-- f.tm = f:CreateMaskTexture()
-- f.tm:SetAllPoints(f.tt)
-- f.tm:SetTexture("Interface/Masks/CircleMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

-- f.tt:AddMaskTexture(f.tm)

-- f.tt:SetTexture(f.tt)
