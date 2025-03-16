local Tinkr, blink = ...

local lerp = blink.lerp

local frame_cache = {}

local alerts = {
	normal = {},
	big = {}
}

-- _G.alerts = alerts

local unlockerType = Tinkr.type

local tickerCallbacks = {}
local function addTickerCallback(callback)
	tinsert(tickerCallbacks, callback)
end
local function removeTickerCallback(callback)
	for index, existing in ipairs(tickerCallbacks) do
		if callback == existing then
			tremove(tickerCallbacks, index)
			break
		end
	end
end

C_Timer.NewTicker(0.05, function()
	for _, callback in ipairs(tickerCallbacks) do
		callback()
	end
end)

local anchors = {
	big = CreateFrame("Frame"),
	normal = CreateFrame("Frame"),
}
blink.alertAnchors = anchors

anchors.normal:SetPoint("CENTER", WorldFrame, "CENTER", 0, 210)
anchors.normal:SetHeight(15)
anchors.normal:SetWidth(200)
anchors.normal:SetFrameStrata("HIGH")
anchors.normal:SetMovable(true)
anchors.normal:Hide()

anchors.big:SetPoint("CENTER", WorldFrame, "CENTER", 0, 195)
anchors.big:SetHeight(15)
anchors.big:SetWidth(200)
anchors.big:SetFrameStrata("HIGH")
anchors.big:SetMovable(true)
anchors.big:Hide()

-- blink.alertAnchor = CreateFrame("Frame")
-- blink.alertAnchor:SetPoint("CENTER", WorldFrame, "CENTER", 0, 200)
-- blink.alertAnchor:SetHeight(15)
-- blink.alertAnchor:SetWidth(200)
-- blink.alertAnchor:SetFrameStrata("HIGH")
-- blink.alertAnchor:SetMovable(true)
-- blink.alertAnchor:Hide()

local moveEnd = {
	big = GetTime() + 0.2,
	normal = GetTime() + 0.2
} 
local moveAnimationTime = {
	big = 0.2,
	normal = 0.2
}

local bigGap = 14
local gap = 10

local deepcomp = blink.deepCompare

local updateMoveInits = function(list, big)
	for i=#list, 1, -1 do
		local alert = list[i]
		if alert then
			alert.startY = select(5,alert:GetPoint()) + (big and -bigGap or gap)
		end
	end
end

local function blinkAlert(...)

	if blink.saved.disableAlerts then return true end
	
	local args = {...}
	local options, texture, big = ...

	local duplicateAlert
	for _, list in pairs(alerts) do
		for _, alert in ipairs(list) do
			if deepcomp(alert.args, args) then
				duplicateAlert = duplicateAlert or alert
			end
		end
	end

	local message

	if type(options) == "string" then
		message = options
		options = {}
	end

	local time = GetTime()
	local framerate = GetFramerate()

	message = message or options.message or options.msg
	local texture = texture or options.texture or options.id

	-- animation times
	local fadeOut = options.fadeOut or 0.3
	local fadeIn = options.fadeIn or 0.175

	big = big or options.big

	-- delay between fade in and fade out
	local duration = options.duration and options.duration + fadeIn + fadeOut or 1 + fadeIn + fadeOut + (big and 0.4 or 0)

	-- highlight: remove the circular mask, make the bg border more prominent
	local highlight = options.highlight

	local imgScale = options.imgScale or 1
	local imgX = options.imgX or 0
	local imgY = options.imgY or 0

	-- max alpha value of frame
	local targetAlpha = options.targetAlpha or 1
	-- start alpha of frame (post-animation alpha is always 0)
	local startAlpha = options.startAlpha or 0
	-- scale in
	local scaleIn = options.scaleIn or fadeIn / 1.5
	-- max scale
	local targetScale = options.targetScale or 1
	-- start scale
	local startScale = options.startScale or 0.1
	-- bg color
	local bgColor = options.bgColor
	-- alert h/w
	local height = options.height or 38 + (big and 4 or 0)
	local width = 350

	local fontSize = options.fontSize or big and 17 or 15

	local listKey = big and "big" or "normal"

	if duplicateAlert then
		duplicateAlert.alpha = targetAlpha
		duplicateAlert:SetAlpha(targetAlpha)
		duplicateAlert.endTime = time + duration + fadeOut
		return duplicateAlert
	end

	--no duplicates
	if type(message) == "string" then
		for _, v in ipairs(alerts[listKey]) do
			if v.text == message 
			and v.id == texture then
				v.alpha = targetAlpha
				v:SetAlpha(targetAlpha)
				v.endTime = time + duration
				return true
			end
		end
	end
	
	local existingHeight = big and -bigGap or gap
	-- for k, v in pairs(alerts) do
	-- 	existingHeight = existingHeight + v:GetHeight() + gap
	-- end

	local alert = CreateFrame("Frame", nil, nil, "BackdropTemplate")
	
	alert.startY = existingHeight
	alert:SetPoint("CENTER",anchors[listKey],"CENTER",0,alert.startY)
	alert:SetHeight(height)
	alert:SetWidth(width)
	alert.id = texture

	alert.args = {...}

	updateMoveInits(alerts[listKey], big)
	moveEnd[listKey] = time + (fadeIn * 0.3)
	moveAnimationTime[listKey] = fadeIn * 0.3

	local r, g, b, a, defaultColor = 0, 0, 0, 0.4, true
	if bgColor then
		local givenA
		if type(bgColor) == "string" then
			r, g, b, givenA = unpack(blink.rgbColors[bgColor])
			defaultColor = false
		else
			r, g, b, givenA = unpack(bgColor)
			defaultColor = false
		end
		if givenA then
			a = givenA
		end
	end
	
	-- alert:SetBackdrop({
	-- 	bgFile = "Interface\\Buttons\\WHITE8X8",
	-- 	edgeFile = "Interface\\Buttons\\WHITE8X8",
	-- 	tile = false, tileSize = 0, edgeSize = 0,
	-- 	insets = { left = 0, top = 0, right = 0, bottom = 0 }
	-- })
	-- alert:SetBackdropColor(r,g,b,0.1)
	-- alert:SetBackdropBorderColor(r*.6, g*.6, b*.6,0)
	-- alert:SetMovable(true)
	-- alert:SetScript("OnMouseUp",function(self) self:StopMovingOrSizing() end)
	-- alert:SetScript("OnMouseDown",function(self) self:StartMoving() end)

	alert:SetAlpha(startAlpha)
	alert:SetScale(startScale)
	alert.currentScale = startScale
	alert.currentAlpha = startAlpha
	
	alert:SetClampedToScreen(true)

	alert.fontString = alert:CreateFontString('awflAlertTxt', "OVERLAY")
	alert.fontString:SetFont("Fonts/OpenSans-Bold.ttf", fontSize, options.outline or '')
	
	-- fallback to frizqt if no good font
	local currentFont, currentSize = alert.fontString:GetFont()
	if not currentFont or currentSize == 0 then
		alert.fontString:SetFont("Fonts/FRIZQT__.TTF", fontSize, '')
	end

	alert.fontString:SetShadowOffset(2,-3)
	alert.fontString:SetShadowColor(0.01, 0.01, 0.01, 0.57)
	alert.fontString:SetPoint("CENTER",alert,"CENTER",0,0)
	alert.fontString:SetJustifyV("MIDDLE");
	alert.fontString:SetJustifyH("LEFT");
	alert.fontString:SetText(message)

	alert.text = message

	if texture or options.textureLiteral then
		local t = options.textureLiteral or C_Spell.GetSpellTexture(texture)
		if t then

			local tWidth = alert:GetHeight() + 2 - gap
			local tHeight = alert:GetHeight() + 2 - gap
			
			if highlight then
				tWidth = tWidth * 0.8
				tHeight = tHeight * 0.8
			end

			-- if bgColor then
			-- end
			alert.texture = alert:CreateTexture(nil, "OVERLAY")
			alert.texture:SetTexture(t)
			alert.texture:ClearAllPoints()
			alert.texture:SetWidth(tWidth * imgScale)
			alert.texture:SetHeight(tHeight * imgScale)
			alert.texture:SetPoint("LEFT",alert.fontString,"LEFT",-(tWidth + gap - 2) + imgX - (highlight and 4 or 0),0 + imgY)
			-- alert.texture:SetVertexColor(r,g,b,1)
			alert.texture:SetRotation(-0.05)
			-- alert.texture:SetMask("Interface/ChatFrame/UI-ChatIcon-HotS")
			-- alert.texture:SetColorTexture(0, 0, 0, 0.5) -- black, 50% opacity

			local p1, f, p2, x, y = alert.texture:GetPoint()

			x = x - imgX
			y = y - imgY

			local circleW, circleH = tWidth - 6, tHeight - 6
			
			if not highlight then
				alert.textureCircle = alert:CreateTexture('awflAlertTxtureBackdrop', "ARTWORK")
				alert.textureCircle:SetTexture(t)
				alert.textureCircle:SetWidth(circleW + 3)
				alert.textureCircle:SetHeight(circleH + 3)
				alert.textureCircle:SetColorTexture(r,g,b,a)
				alert.textureCircle:SetPoint(p1, f, p2, x + 1.25, y)

				alert.textureCircleMask = alert:CreateMaskTexture()
				alert.textureCircleMask:SetAllPoints(alert.textureCircle)
				alert.textureCircleMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

				alert.textureCircle:AddMaskTexture(alert.textureCircleMask)

				-- alert.mask = alert:CreateMaskTexture()
				-- alert.mask:SetAllPoints(alert)
				-- alert.mask:SetHeight(tHeight)
				-- alert.mask:Setdth(tWidth)
				-- alert.mask:SetTexture("Interface\\Buttons\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

				alert.mask2 = alert:CreateMaskTexture()
				alert.mask2:SetPoint(p1, f, p2, x + 2.5, y)
				alert.mask2:SetWidth(circleW)
				alert.mask2:SetHeight(circleH)
				alert.mask2:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

				-- alert.texture:AddMaskTexture(alert.mask)
				alert.texture:AddMaskTexture(alert.mask2)
			else
				alert.border = alert:CreateTexture(nil, "OVERLAY")
				alert.border:SetPoint("CENTER", alert.texture, "CENTER", 0, 0)
				alert.border:SetWidth(tWidth * imgScale * 2)
				alert.border:SetHeight(tHeight * imgScale * 2)
				alert.border:SetTexture("Interface/BUTTONS/CheckButtonHilight-Blue")

				if not defaultColor then
					-- modify border color with SetVertexColor
					alert.border:SetVertexColor(r,g,b,1)
				end
			end

		end
	end

	local function callback()
		local function deleteSelf()
			removeTickerCallback(callback)
		end
		if not tContains(alerts[listKey], alert) then
			alert:SetAlpha(0)
			alert:Hide()
			-- removeAlertFrame(alert)
			deleteSelf()
		end
	end

	addTickerCallback(callback)

	alert.fadeInStart = time
	alert.fadeInEnd = time + fadeIn

	alert.scaleInStart = time
	alert.scaleInEnd = time + scaleIn

	alert.endTime = time + duration
	alert.fadeOutEnd = function() return alert.endTime + fadeOut end

	function alert:fadeOut()
		if alert.currentAlpha <= 0 then return end
		local timePct = 1 - ((self.fadeOutEnd() - GetTime())/fadeOut)
		local completion = blink.cubicBezier(timePct,0,.11,.35,.9) -- fade out bezier
		if timePct < 1.35 and timePct > -0.25 then
			local alpha = lerp(targetAlpha, 0, completion)
			if alpha < 0 then alpha = 0 end
			if alert.currentAlpha == alpha then return end
			self:SetAlpha(alpha)
			self.currentAlpha = alpha
		end
	end

	function alert:fadeIn()
		if alert.currentAlpha >= targetAlpha then return end
		local timePct = 1 - ((self.fadeInEnd - GetTime())/fadeIn)
		local completion = max(min(1,blink.cubicBezier(timePct,0,.25,.65,1)),0) -- fade in bezier
		if timePct < 1.35 and timePct > -0.25 then
			local alpha = lerp(startAlpha, targetAlpha, completion)
			if targetAlpha == 0 and alpha < 0 then alpha = 0 end
			if targetAlpha ~= 0 and alpha > targetAlpha then alpha = targetAlpha end
			if alert.currentAlpha == alpha then return end
			self:SetAlpha(alpha)
			self.currentAlpha = alpha
		end
	end

	-- /run blink.alert("test"..math.random(1,100), 118)
	
	function alert:scaleIn()
		local timePct = 1 - ((self.scaleInEnd - GetTime())/scaleIn)
		if timePct >= 1 then 
			self:SetScale(1)
			self.currentScale = 1
			return 
		end
		local completion = blink.cubicBezier(timePct,.11,.8,1.2,1) -- fade in bezier
		if timePct < 1.5 and timePct > -0.25 then
			local scale = lerp(startScale, targetScale, completion)
			if targetScale == 0 and scale < 0 then scale = 0 end
			self:SetScale(scale)
			self.currentScale = scale
		end
	end

	function alert:move(targetY)
		local p1, p2, p3, x, y = self:GetPoint()
		local timePct = 1 - ((moveEnd[listKey] - GetTime())/moveAnimationTime[listKey])
		if timePct >= 1 then 
			self:SetPoint(p1, p2, p3, x, targetY)
			return 
		end
		local completion = blink.cubicBezier(timePct,0,.11,.49,.3,1) -- fade in bezier
		local thisY = lerp(self.startY, targetY, completion)
		-- if thisY > targetY then thisY = targetY end
		self:SetPoint(p1, p2, p3, x, thisY)
	end

	tinsert(alerts[listKey], alert)

	return alert

end

local function convertOptions(...)
	local options, texture, big = ...
	if type(options) == "string" then
		options = {
			message = options,
			texture = texture,
			big = big
		}
	end
	return options
end

blink.alert = setmetatable({
	short = function(...) 
		local options = convertOptions(...)
		options.duration = 0.05
		return blinkAlert(options)
	end,
	red = function(...) 
		local options = convertOptions(...)
		options.bgColor = {245/255, 60/255, 60/255, 0.9}
		return blinkAlert(options)
	end,
	yellow = function(...) 
		local options = convertOptions(...)
		options.bgColor = {225/255, 195/255, 30/255, 0.9}
		return blinkAlert(options)
	end,
	blue = function(...) 
		local options = convertOptions(...)
		options.bgColor = {144/255, 144/255, 255/255, 0.95}
		return blinkAlert(options)
	end,
	big = function(...) 
		local options = convertOptions(...)
		options.big = true
		return blinkAlert(options)
	end,
}, {
	__call = function(_, ...) return blinkAlert(...) end
})

local updateAlerts = function(list, big)
	local time = blink.time or GetTime()

	for i=#list, 1, -1 do
		local alert = list[i]
		if alert then
			if time > alert.fadeOutEnd() then
				alert:SetAlpha(0)
				alert:Hide()
				tremove(list, i)
			elseif time > alert.endTime then
				alert:fadeOut()
			elseif time > alert.fadeInStart then
				alert:fadeIn()
				alert:scaleIn()
			end
		end
	end

	local totalHeight = big and -bigGap or gap
	for i=#list,1,-1 do
		local alert = list[i]
		if alert then
			alert:move(totalHeight)
			totalHeight = totalHeight + (big and -(alert:GetHeight() / 2) or alert:GetHeight() / 2) + (big and -bigGap or gap)
		end
	end

	if big then
		if #list >= 4 then
			for i=1, #list - 4 do
				list[i]:SetAlpha(0)
				list[i]:Hide()
				tremove(list, i)
			end
		end
	end

end

CreateFrame("Frame"):SetScript("OnUpdate", function()
	updateAlerts(alerts.normal)
	updateAlerts(alerts.big, true)
end)