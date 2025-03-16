local MainEnv,HFSubs = ...
local _G, unlocker, extraAPI, LYEnv = _G, nil, {}, {}
if not IsPlayerInWorld() then
	return
end
local function Load()
	local username, LYL = nil, {}	
	if MainEnv.Common then
		MainEnv.Util.Evaluator:EmplaceGlobals("TinkrAPI")
		TRACE_LINE = TinkrAPI.TraceLine
		TinkrAPI.TraceLine = function(...)
			local x, y, z = TRACE_LINE(...)
			if x ~= 0 then
				return x, y, z
			else
				return
			end
		end
		extraAPI = {
			GetAppDirectory = function() return "configs" end,
			UnitCombatReach = TinkrAPI.ObjectCombatReach,
			ObjectIsUnit = function(...) return TinkrAPI.ObjectType(...) == 5 or TinkrAPI.ObjectType(...) == 6 end,
			GetObjectWithGUID = function(...)
				local objects = TinkrAPI.Objects()
				for i, object in ipairs(objects) do
					if UnitIsVisible(object) and UnitGUID(object) == ... then
						return object:unit()
					end
				end
			end,
			UnitCastingTarget = function(...) return TinkrAPI.ObjectCastingTarget(...):unit() end,
			UnitTarget = function(...) return TinkrAPI.ObjectTarget(...):unit() end,
			GetSpecByDescriptor = TinkrAPI.ObjectSpecializationID,
			ClickPosition = TinkrAPI.Click,
			GetAnglesBetweenObjects = function(obj1,obj2)
				local X1, Y1, Z1 = TinkrAPI.ObjectPosition(obj1)
				local X2, Y2, Z2 = TinkrAPI.ObjectPosition(obj2)
				return math.atan2(Y2 - Y1, X2 - X1) % (math.pi * 2), math.atan((Z1 - Z2) / math.sqrt(math.pow(X1 - X2, 2) + math.pow(Y1 - Y2, 2))) % math.pi
			end,
			ObjectIsFacing = function(obj1,obj2)
				local Facing = TinkrAPI.ObjectRotation(obj1)
				local AngleToUnit = extraAPI.GetAnglesBetweenObjects(obj1,obj2)
				local AngleDifference = Facing > AngleToUnit and Facing - AngleToUnit or AngleToUnit - Facing
				local ShortestAngle = AngleDifference < math.pi and AngleDifference or math.pi * 2 - AngleDifference
				return ShortestAngle < math.pi / 2
			end,
			ObjectFacing = TinkrAPI.ObjectRotation,
			ObjectIsGameObject = function(...) return TinkrAPI.ObjectType(...) == 8 end,
			GetObjectCount = function() return #TinkrAPI.Objects() end,
			GetObjectWithIndex = function(...) return TinkrAPI.Objects()[...] end,
			ObjectIsBehind = function(obj1,obj2) return not extraAPI.ObjectIsFacing(obj2,obj1) end,
			GetDistanceBetweenObjects = TinkrAPI.ObjectDistance,
			UnitCreator = function(...) return TinkrAPI.ObjectCreator(...):unit() end,
			ObjectInteract = TinkrAPI.RightClickObject,
			GetCurrentAccount = TinkrAPI.GetAccountId,
			UnitMovementFlags = TinkrAPI.ObjectMovementFlag,
			GetMissileCount = function() return #TinkrAPI.Missiles()  end,
			GetMissileWithIndex = function(...) return TinkrAPI.Missiles()[...] end,
			GetKeyStatus = TinkrAPI.GetKeyState,
			IncrementAppleCount = function(...) return end,
		}
		unlocker = "tinkr"
	elseif MainEnv.Require then
		GetAppDirectory = function() return "" end
		UnitCombatReach = CombatReach
		ObjectIsUnit = function(...) return ObjectType(...) == 5 or ObjectType(...) == 6 end
		GetObjectWithGUID = ObjectPointer
		UnitCastingTarget = CastTarget
		GetSpecByDescriptor = UnitSpecializationID
		GetAnglesBetweenObjects = function(obj1,obj2)
			local X1, Y1, Z1 = ObjectPosition(obj1)
			local X2, Y2, Z2 = ObjectPosition(obj2)
			return math.atan2(Y2 - Y1, X2 - X1) % (math.pi * 2), math.atan((Z1 - Z2) / math.sqrt(math.pow(X1 - X2, 2) + math.pow(Y1 - Y2, 2))) % math.pi
		end
		ObjectIsFacing = function(obj1,obj2)
			local Facing = ObjectRotation(obj1)
			local AngleToUnit = GetAnglesBetweenObjects(obj1,obj2)
			local AngleDifference = Facing > AngleToUnit and Facing - AngleToUnit or AngleToUnit - Facing
			local ShortestAngle = AngleDifference < math.pi and AngleDifference or math.pi * 2 - AngleDifference
			return ShortestAngle < math.pi / 2
		end
		ObjectIsGameObject = function(...) return ObjectType(...) == 8 end
		GetObjectCount = function() return #Objects() end
		GetObjectWithIndex = ObjectByIndex
		ObjectIsBehind = function(obj1,obj2) return not ObjectIsFacing(obj2,obj1) end
		GetDistanceBetweenObjects = Distance
		UnitCreator = ObjectCreator
		FaceDirection = SetPlayerFacing
		ObjectId = ObjectID
		GetCurrentAccount = GetWowAccount
		UnitMovementFlags = UnitMovementFlag
		GetKeyStatus = function(...) if GetKeyState(...) ~= 0 then return true end end
		IncrementAppleCount = function(...) return end
		Ascend_Stop = AscendStop
		AscendStop = function (...) return Unlock(Ascend_Stop,...) end
		Attack_Target = AttackTarget
		AttackTarget = function (...) return Unlock(Attack_Target,...) end
		Camera_Or_Select_Or_MoveStart = CameraOrSelectOrMoveStart
		CameraOrSelectOrMoveStart = function (...) return Unlock(Camera_Or_Select_Or_MoveStart,...) end
		Camera_Or_Select_Or_MoveStop = CameraOrSelectOrMoveStop
		CameraOrSelectOrMoveStop = function (...) return Unlock(Camera_Or_Select_Or_MoveStop,...) end
		Cancel_Shapeshift_Form = CancelShapeshiftForm
		CancelShapeshiftForm = function (...) return Unlock(Cancel_Shapeshift_Form,...) end
		Cancel_Unit_Buff = CancelUnitBuff
		CancelUnitBuff = function (...) return Unlock(Cancel_Unit_Buff,...) end
		Cast_Shapeshift_Form = CastShapeshiftForm
		CastShapeshiftForm = function (...) return Unlock(Cast_Shapeshift_Form,...) end
		Force_Quit = ForceQuit
		ForceQuit = function (...) return Unlock(Force_Quit,...) end
		Jump_Or_Ascend_Start = JumpOrAscendStart
		JumpOrAscendStart = function (...) return Unlock(Jump_Or_Ascend_Start,...) end
		Move_And_Steer_Stop = MoveAndSteerStop
		MoveAndSteerStop = function (...) return Unlock(Move_And_Steer_Stop,...) end
		Move_Backward_Start = MoveBackwardStart
		MoveBackwardStart = function (...) return Unlock(Move_Backward_Start,...) end
		Move_Backward_Stop = MoveBackwardStop
		MoveBackwardStop = function (...) return Unlock(Move_Backward_Stop,...) end
		Move_Forward_Start = MoveForwardStart
		MoveForwardStart = function (...) return Unlock(Move_Forward_Start,...) end
		Move_Forward_Stop = MoveForwardStop
		MoveForwardStop = function (...) return Unlock(Move_Forward_Stop,...) end
		Pet_Follow = PetFollow
		PetFollow = function (...) return Unlock(Pet_Follow,...) end
		Pet_Move_To = PetMoveTo
		PetMoveTo = function (...) return Unlock(Pet_Move_To,...) end
		Pet_Stop_Attack = PetStopAttack
		PetStopAttack = function (...) return Unlock(Pet_Stop_Attack,...) end
		Pitch_Up_Stop = PitchUpStop
		PitchUpStop = function (...) return Unlock(Pitch_Up_Stop,...) end
		Pitch_Down_Stop = PitchDownStop
		PitchDownStop = function (...) return Unlock(Pitch_Down_Stop,...) end
		Spell_Cancel_Queued_Spell = SpellCancelQueuedSpell
		SpellCancelQueuedSpell = function (...) return Unlock(Spell_Cancel_Queued_Spell,...) end
		Spell_Stop_Casting = SpellStopCasting
		SpellStopCasting = function (...) return Unlock(Spell_Stop_Casting,...) end
		Spell_Stop_Targeting = SpellStopTargeting
		SpellStopTargeting = function (...) return Unlock(Spell_Stop_Targeting,...) end
		Strafe_Left_Start = StrafeLeftStart
		StrafeLeftStart = function (...) return Unlock(Strafe_Left_Start,...) end
		Strafe_Left_Stop = StrafeLeftStop
		StrafeLeftStop = function (...) return Unlock(Strafe_Left_Stop,...) end
		Strafe_Right_Start = StrafeRightStart
		StrafeRightStart = function (...) return Unlock(Strafe_Right_Start,...) end
		Strafe_Right_Stop = StrafeRightStop
		StrafeRightStop = function (...) return Unlock(Strafe_Right_Stop,...) end
		Turn_Left_Start = TurnLeftStart
		TurnLeftStart = function (...) return Unlock(Turn_Left_Start,...) end
		Turn_Left_Stop = TurnLeftStop
		TurnLeftStop = function (...) return Unlock(Turn_Left_Stop,...) end
		Turn_Or_Action_Start = TurnOrActionStart
		TurnOrActionStart = function (...) return Unlock(Turn_Or_Action_Start,...) end
		Turn_Or_Action_Stop = TurnOrActionStop
		TurnOrActionStop = function (...) return Unlock(Turn_Or_Action_Stop,...) end
		Turn_Right_Start = TurnRightStart
		TurnRightStart = function (...) return Unlock(Turn_Right_Start,...) end
		Turn_Right_Stop = TurnRightStop
		TurnRightStop = function (...) return Unlock(Turn_Right_Stop,...) end
		unlocker = "NN"
	elseif MainEnv.GetUnitPosition then
		TRACE_LINE = MainEnv.TraceLine
		MainEnv.TraceLine = function(...)
			local hit, hitx, hity, hitz = TRACE_LINE(...)
			if hit ~= 0 then
				return hitx, hity, hitz
			else
				return
			end
		end
		extraAPI = {
			ObjectPosition = function(...) return MainEnv.GetUnitPosition(...) end,
			GetCurrentAccount = function(...) return select(2,MainEnv.GetWowAccountId()) end,
			ObjectFacing = MainEnv.UnitFacing,
			GetAppDirectory = MainEnv.GetExeDirectory,
			ObjectIsUnit = function(...) return MainEnv.ObjectType(...) == 5 or MainEnv.ObjectType(...) == 6 end,
			GetObjectWithGUID = function(...) return ... end,
			GetSpecByDescriptor = MainEnv.UnitSpecializationID,
			GetAnglesBetweenObjects = function(obj1,obj2)
				local X1, Y1, Z1 = MainEnv.GetUnitPosition(obj1)
				local X2, Y2, Z2 = MainEnv.GetUnitPosition(obj2)
				return math.atan2(Y2 - Y1, X2 - X1) % (math.pi * 2), math.atan((Z1 - Z2) / math.sqrt(math.pow(X1 - X2, 2) + math.pow(Y1 - Y2, 2))) % math.pi
			end,
			ObjectIsFacing = function(obj1,obj2)
				local Facing = MainEnv.UnitFacing(obj1)
				local AngleToUnit = extraAPI.GetAnglesBetweenObjects(obj1,obj2)
				local AngleDifference = Facing > AngleToUnit and Facing - AngleToUnit or AngleToUnit - Facing
				local ShortestAngle = AngleDifference < math.pi and AngleDifference or math.pi * 2 - AngleDifference
				return ShortestAngle < math.pi / 2
			end,
			ObjectIsGameObject = function(...) return MainEnv.ObjectType(...) == 8 end,
			ObjectIsBehind = function(obj1,obj2) return not extraAPI.ObjectIsFacing(obj2,obj1) end,
			GetDistanceBetweenObjects = function(obj1,obj2)
				local X1, Y1, Z1 = MainEnv.GetUnitPosition(obj1)
				local X2, Y2, Z2 = MainEnv.GetUnitPosition(obj2)
				return math.sqrt((X2-X1)^2 + (Y2-Y1)^2 + (Z2-Z1)^2)
			end,
			UnitCreator = MainEnv.UnitCreatedBy,
			ObjectId = MainEnv.ObjectID,
			ObjectInteract = function(...) Interact(UnitGUID(...)) end,
			ObjectHeight = MainEnv.UnitHeight,
			UnitMovementFlags = MainEnv.GetUnitMovementFlags,
			GetKeyStatus = MainEnv.GetKeyState,
            IncrementAppleCount = MainEnv.IncAppleCount,
		}
		unlocker = "daemon"
	else
        EnableUnlocker(true)
		extraAPI = {
			ObjectIsUnit = function(...) return MainEnv.ObjectIsType(...,MainEnv.GetObjectTypeFlagsTable().Unit) end,
			GetSpecByDescriptor = function(...) return MainEnv.ObjectDescriptor(...,MainEnv.GetObjectDescriptorsTable().CGPlayerData__currentSpecID,MainEnv.GetValueTypesTable().UInt) end,
			ObjectInteract = function(...) C_PlayerInteractionManager.InteractUnit(...) end,
			GetKeyStatus = MainEnv.GetKeyState
		}
		unlocker = "MB"
	end
	
	-- core/drawing
	local sin, cos, atan, atan2, sqrt, rad = math.sin, math.cos, math.atan, math.atan2, math.sqrt, math.rad
	local onDrawTicker
	local graphics = {}
	graphics.drawing = {}
	local function IsOnScreen(x,y)
		return x <= GetScreenWidth() and y <= GetScreenHeight()
	end
	local WorldToScreen_Original = WorldToScreen
	local function WorldToScreen(wX,wY,wZ)
		local sX,sY,a,b,c = nil,nil,1,1,0
		if unlocker == "MB" then
			_,sX,sY = WorldToScreen_Original(wX,wY,wZ)
			a = GetScreenWidth()*UIParent:GetEffectiveScale()
			b = GetScreenHeight()*UIParent:GetEffectiveScale()
			c = WorldFrame:GetTop()-(sY or 1)*b
		else
			sX,sY = WorldToScreen_Original(wX,wY,wZ)
			c = (sY or 1)*b
		end
		if sX and sY then
			return sX*a,-c
		elseif sX then
			return sX*a,sY
		elseif sY then
			return sX,sY*b
		else
			return sX,sY
		end
	end
	function graphics.drawing:SetColor(r, g, b, a)
		private.line.r = r * 0.00390625
		private.line.g = g * 0.00390625
		private.line.b = b * 0.00390625
		if a then
			private.line.a = a * 0.01
		else
			private.line.a = 1
		end
	end
	function graphics.drawing:SetColorRaw(r, g, b, a)
		private.line.r = r
		private.line.g = g
		private.line.b = b
		private.line.a = a
	end
	function graphics.drawing:SetWidth(w)
		private.line.w = w
	end
	function graphics.drawing:Line(sx, sy, sz, ex, ey, ez)
		if not sx or not ex then return end
		local sx, sy = WorldToScreen(sx, sy, sz)
		local ex, ey = WorldToScreen(ex, ey, ez)
		if not sx or not sy or not ex or not ey then return end
		graphics.drawing:Draw2DLine(sx, sy, ex, ey)
	end
	local function rotateX(cx, cy, cz, px, py, pz, r)
		if not r then
			return px, py, pz
		end
		local s = sin(r)
		local c = cos(r)
		px, py, pz = px - cx, py - cy, pz - cz
		local x = px + cx
		local y = ((py * c - pz * s) + cy)
		local z = ((py * s + pz * c) + cz)
		return x, y, z
	end
	local function rotateY(cx, cy, cz, px, py, pz, r)
		if not r then
			return px, py, pz
		end
		local s = sin(r)
		local c = cos(r)
		px, py, pz = px - cx, py - cy, pz - cz
		local x = ((pz * s + px * c) + cx)
		local y = py + cy
		local z = ((pz * c - px * s) + cz)
		return x, y, z
	end
	local function rotateZ(cx, cy, cz, px, py, pz, r)
		if not r then
			return px, py, pz
		end
		local s = sin(r)
		local c = cos(r)
		px, py, pz = px - cx, py - cy, pz - cz
		local x = ((px * c - py * s) + cx)
		local y = ((px * s + py * c) + cy)
		local z = pz + cz
		return x, y, z
	end
	function graphics.drawing:Array(vectors, x, y, z, rotationX, rotationY, rotationZ)
		for _, vector in ipairs(vectors) do
			local sx, sy, sz = x + vector[1], y + vector[2], z + vector[3]
			local ex, ey, ez = x + vector[4], y + vector[5], z + vector[6]
			if rotationX then
				sx, sy, sz = rotateX(x, y, z, sx, sy, sz, rotationX)
				ex, ey, ez = rotateX(x, y, z, ex, ey, ez, rotationX)
			end
			if rotationY then
				sx, sy, sz = rotateY(x, y, z, sx, sy, sz, rotationY)
				ex, ey, ez = rotateY(x, y, z, ex, ey, ez, rotationY)
			end
			if rotationZ then
				sx, sy, sz = rotateZ(x, y, z, sx, sy, sz, rotationZ)
				ex, ey, ez = rotateZ(x, y, z, ex, ey, ez, rotationZ)
			end
			local sx, sy = WorldToScreen(sx, sy, sz)
			local ex, ey = WorldToScreen(ex, ey, ez)
			if not sx or not sy or not ex or not ey then return end
			graphics.drawing:Draw2DLine(sx, sy, ex, ey)
		end
	end
	function graphics.drawing:Draw2DLine(sx, sy, ex, ey)
		if not sx or not sy or not ex or not ey then
			return
		end
		local L = tremove(private.lines)
		if not L then
			L = CreateFrame("Frame", private.canvas)
			L.line = L:CreateLine()
			L.line:SetDrawLayer("BACKGROUND")
		end
		L.line:SetThickness(private.line.w)
		L.line:SetColorTexture(private.line.r, private.line.g, private.line.b, private.line.a)
		tinsert(private.lines_used, L)
		L:ClearAllPoints()
		if (sx > ex and sy > ey) or (sx < ex and sy < ey) then
			L:SetPoint("TOPRIGHT", private.canvas, "TOPLEFT", sx, sy)
			L:SetPoint("BOTTOMLEFT", private.canvas, "TOPLEFT", ex, ey)
			L.line:SetStartPoint('TOPRIGHT')
			L.line:SetEndPoint('BOTTOMLEFT')
		elseif sx < ex and sy > ey then
			L:SetPoint("TOPLEFT", private.canvas, "TOPLEFT", sx, sy)
			L:SetPoint("BOTTOMRIGHT", private.canvas, "TOPLEFT", ex, ey)
			L.line:SetStartPoint('TOPLEFT')
			L.line:SetEndPoint('BOTTOMRIGHT')
		elseif sx > ex and sy < ey then
			L:SetPoint("TOPRIGHT", private.canvas, "TOPLEFT", sx, sy)
			L:SetPoint("BOTTOMLEFT", private.canvas, "TOPLEFT", ex, ey)
			L.line:SetStartPoint('TOPLEFT')
			L.line:SetEndPoint('BOTTOMRIGHT')
		else
			L:SetPoint("TOPLEFT", private.canvas, "TOPLEFT", sx, sy)
			L:SetPoint("BOTTOMLEFT", private.canvas, "TOPLEFT", sx, ey)
			L.line:SetStartPoint('TOPLEFT')
			L.line:SetEndPoint('BOTTOMLEFT')
		end
		L:Show()
	end
	local flags = bit.bor(0x100)
	local full_circle = rad(365)
	local small_circle_step = rad(3)
	function graphics.drawing:Circle(x, y, z, size)
		local lx, ly, nx, ny, fx, fy
		for v = 0, full_circle, small_circle_step do
			nx, ny = WorldToScreen( (x + cos(v) * size), (y + sin(v) * size), z )
			if not IsOnScreen(nx,ny) then return end
			if not nx or not ny then return end
			graphics.drawing:Draw2DLine(lx, ly, nx, ny)
			lx, ly = nx, ny
		end
	end
	function graphics.drawing:GroundCircle(x, y, z, size)
		local lx, ly, nx, ny, fx, fy, fz
		if not x or not y or not z then
			return
		end
		for v = 0, full_circle, small_circle_step do
			fx, fy, fz = TraceLine( (x + cos(v) * size), (y + sin(v) * size), z + 100, (x + cos(v) * size), (y + sin(v) * size), z - 100, flags )
			if not fx then
				fx, fy, fz = (x + cos(v) * size), (y + sin(v) * size), z
			end
			nx, ny = WorldToScreen( (fx + cos(v) * size), (fy + sin(v) * size), fz )
			if not IsOnScreen(nx,ny) then return end
			if not nx or not ny then return end
			graphics.drawing:Draw2DLine(lx, ly, nx, ny)
			lx, ly = nx, ny
		end
	end
	function graphics.drawing:Arc(x, y, z, size, arc, rotation)
		local lx, ly, nx, ny, fx, fy
		local half_arc = arc * 0.5
		local ss = (arc / half_arc)
		local as, ae = -half_arc, half_arc
		for v = as, ae, ss do
			nx, ny = WorldToScreen( (x + cos(rotation + rad(v)) * size), (y + sin(rotation + rad(v)) * size), z )
			if not IsOnScreen(nx,ny) then return end
			if not nx or not ny then return end
			if lx and ly then
				graphics.drawing:Draw2DLine(lx, ly, nx, ny)
			else
				fx, fy = nx, ny
			end
			lx, ly = nx, ny
		end
		local px, py = WorldToScreen(x, y, z)
		if not IsOnScreen(px,py) then return end
		if not px or not py then return end
		graphics.drawing:Draw2DLine(px, py, lx, ly)
		graphics.drawing:Draw2DLine(px, py, fx, fy)
	end
	local font = CreateFont("graphicsDrawingFont")
	font:CopyFontObject("GameFontNormalSmall")
	function graphics.drawing:Texture(config, x, y, z, alphaA)
		local function Distance(ax, ay, az, bx, by, bz)
			return math.sqrt(((bx - ax) * (bx - ax)) + ((by - ay) * (by - ay)) + ((bz - az) * (bz - az)))
		end
		local texture, width, height = config.texture, config.width, config.height
		local left, right, top, bottom, scale = config.left, config.right, config.top, config.bottom, config.scale
		local alpha = config.alpha or alphaA
		if not texture or not width or not height or not x or not y or not z then return end
		if not left or not right or not top or not bottom then
			left = 0
			right = 1
			top = 0
			bottom = 1
		end
		if not scale then
			local cx, cy, cz = GetCameraPosition()
			scale = width / Distance(x, y, z, cx, cy, cz)
		end
		local sx, sy = WorldToScreen(x, y, z)
		if not IsOnScreen(sx,sy) then return end
		if not sx or not sy then return end
		local w = width * scale
		local h = height * scale
		sx = sx - w * 0.5
		sy = sy + h * 0.5
		local ex, ey = sx + w, sy - h
		local T = tremove(private.textures) or false
		if T == false then
			T = private.canvas:CreateTexture(nil, "BACKGROUND")
			T:SetDrawLayer(private.level)
			T:SetTexture(private.texture)
		end
		tinsert(private.textures_used, T)
		T:ClearAllPoints()
		T:SetTexCoord(left, right, top, bottom)
		T:SetTexture(texture)
		T:SetWidth(width)
		T:SetHeight(height)
		T:SetPoint("TOPLEFT", private.canvas, "TOPLEFT", sx, sy)
		T:SetPoint("BOTTOMRIGHT", private.canvas, "TOPLEFT", ex, ey)
		T:SetVertexColor(1, 1, 1, 1)
		if alpha and type(alpha) == "number" then T:SetAlpha(alpha) else T:SetAlpha(1) end
		T:Show()
	end
	local i = 0
	local time_since_last_interact = 0
	function graphics.drawing:Text(text, x, y, z, refid, refobj)
		local sx, sy = WorldToScreen(x, y, z)
		if not IsOnScreen(sx,sy) then return end
		if not sx or not sy then return end
		local B = tremove(private.buttons)
		local font = tremove(private.fonts)
		if not B then
			B = CreateFrame("Button", "graphicsDrawingButton" .. i, private.canvas, "UIPanelButtonTemplate")
			B:DisableDrawLayer("BACKGROUND")
			B.refobj = refobj
			B:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
				local down, toggled = GetKeyStatus(0x1)
				if down then
					local distance = GetDistanceBetweenObjects("player", self.refobj)
					if distance and distance <= 7 and GetTime() - time_since_last_interact > 0.300 then
						time_since_last_interact = GetTime()
						C_PlayerInteractionManager.InteractUnit(self.refobj)
					end
					if not UnitIsFriend(self.refobj, "player") then
						TargetUnit(self.refobj)
					end
				end
				if unlocker == "MB" then
					local text = GetTooltipForId(refid)
					if not text then return end
					GameTooltip:AddLine(text)
					GameTooltip:Show()
				end
			end)
			B:SetScript("OnLeave", function() GameTooltip:ClearLines() GameTooltip:Hide() end)
		end
		B.refobj = refobj
		if not font then
			font = CreateFont("graphicsfont" .. i)
		end
		font:SetTextColor(private.line.r, private.line.g, private.line.b, private.line.a)
		font:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
		B:SetNormalFontObject(font)
		B:SetText(text)
		B:SetPoint("TOPLEFT", private.canvas, "TOPLEFT", sx - (B:GetWidth() * 0.5), sy + (B:GetHeight() * 0.5))
		B:Show()
		tinsert(private.buttons_used, B)
		tinsert(private.fonts_used, font)
		i = i + 1
	end
	function graphics.drawing:Camera()
		local fX, fY, fZ = ObjectPosition("player")
		local sX, sY, sZ = GetCameraPosition()
		return sX, sY, sZ, atan2(sY - fY, sX - fX), atan((sZ - fZ) / sqrt(((fX - sX) ^ 2) + ((fY - sY) ^ 2)))
	end
	local function clearCanvas()
		for j = #private.lines_used, 1, - 1 do
			private.lines_used[j]:Hide()
			tinsert(private.lines, tremove(private.lines_used))
		end
		for j = #private.buttons_used, 1, - 1 do
			private.buttons_used[j]:Hide()
			tinsert(private.buttons, tremove(private.buttons_used))
		end
		for j = #private.textures_used, 1, - 1 do
			private.textures_used[j]:Hide()
			tinsert(private.textures, tremove(private.textures_used))
		end
		for j = #private.fonts_used, 1, -1 do
			tinsert(private.fonts, tremove(private.fonts_used))
		end
		i = 0
	end
	local function OnDrawUpdate()
		if private and IsPlayerInWorld() then
			clearCanvas()
			for _, callback in pairs(private.callbacks) do
				callback()
			end
		end
	end
	local function StopDrawing()
		if not onDrawTicker then return end
		onDrawTicker:Cancel()
	end
	function graphics:AddDrawingCallback(key, callback)
		private.callbacks[key] = callback
	end
	function graphics:RemoveDrawingCallback(key)
		private.callbacks[key] = nil
	end
	function graphics:InitDrawing()
		if not private then
			private = {line = {r = 0, g = 1, b = 0, a = 1, w = 1},
					   callbacks = {},
					   canvas = CreateFrame("Frame", WorldFrame),
					   lines = {},
					   lines_used = {},
					   buttons = {},
					   buttons_used = {},
					   fonts = {},
					   fonts_used = {},
					   textures = {},
					   level = "BACKGROUND",
					   textures_used = {}}
			private.canvas:SetAllPoints(WorldFrame)
			private.canvas:SetScript("OnUpdate", OnDrawUpdate)
		end
	end
	function graphics:DestroyDrawing()
		StopDrawing()
		clearCanvas()
		private = nil
	end
	function graphics:GetDrawingObject()
		return private
	end
	graphics:InitDrawing()

	function RunSecurityCheck()
		if unlocker ~= "MB" then
			return true
		end
		local a,b = GetSystemErrorCode()
		if a and a == 5 then
			TerminateCurrentProcess()
		end
	end
	function tunpack(t)
		local function table_unpack(t,i,n)
			i = i or 1
			n = n or #t
			if i <= n then
				return t[i], table_unpack(t, i + 1, n)
			end
		end
		local result = {}
		if t then
			for _, key in pairs(t) do
				result[#result + 1] = key
			end
			return table_unpack(result,1,#result)
		end
	end
	function GetSpellInfo(SpellName)
		local tSpell = C_Spell.GetSpellInfo(SpellName)
		return tSpell and C_Spell.GetSpellInfo(SpellName).name
	end
	
	function LYDeathKnightBlood()
		local function BloddrinkPause()
			if UnitChannelInfo("player") == DKBloddrink then
				return true
			end
		end
		if CommonKick(DKKick,"magic","kick",true) or
		CommonKick(DKStrangulate,"magic","alt",LYMode ~= "PvE") or
		DKReflectIncCC() or
		LYReflect(DKAMS,true) or
		DKCancelLichborn() or
		DKSimulStealCC() or
		PauseRotation or
		DefensiveOnPlayer(DKEatPet,nil,LYDKEatPetHP,nil,nil,true) or
		DefensiveOnPlayer(DKRuneTap,nil,LYDKRuneTapHP,LYDKRuneTapBurst,LYDKRuneTapHealer,not HaveBuff("player",DKRuneTap)) or
		DefensiveOnPlayer(DKVamBlood,nil,LYDKVamBloodHP,LYDKVamBloodBurst,LYDKVamBloodHealer,true) or
		DefensiveOnPlayer(DKLichborn,nil,LYDKLichbornHP,nil,nil,LYUP > 29) or
		TauntPvP(DKTaunt,841) or
		Taunt(DKTaunt) or
		DefensiveOnTeam(DKAMS,nil,LYDKAMSHP,LYDKAMSBurst,30,LYDKAMSTeammate and IsPvPTalentInUse(5592)) or
		DefensiveOnPlayer(DKAMS,nil,LYDKAMSHP,LYDKAMSBurst,LYDKAMSHealer,true) or
		ConditionalSpell(DKDeathAdvance,LYMode ~= "PvE" and GCDCheck(DKDeathAdvance) and CalculateHP(LYEnemyTarget) < LYDKDeathAdvanceHP and not IsInDistance(LYEnemyTarget,8) and not IsRooted("player") and HaveDebuff("player",listSlows)) or
		BRDeadFriend() or
		DKSummonPet() or
		AntiStealth(DKTaunt) or
		TotemStomp({DKHeartStrike,DKDeathStrike},{DKCoil,DKDeathCaress},30) or
		CommonKick(DKGrip,"magic","move",LYDKGripKick) or
		CommonKick(DKAsphyx,"phys","alt",LYDKAsphyxKick) or
		DKSacPet() or
		DKWalkPause() or
		DKSimulFire() or
		DefensiveOnTeam(DKAMZ,"WIZARD",LYDKAMZHP,LYDKAMZBurst,30,true) or
		StunCC(DKAsphyx,"phys",LYDKAsphyxDR,LYDKAsphyxHealer,LYDKAsphyxHealerHP,LYDKAsphyxTeamBurst,LYDKAsphyxDPS,LYDKAsphyxDPSHP,LYDKAsphyxDPSBurst,LYDKAsphyxCont,LYDKAsphyxFocus) or
		ConditionalSpell(DKWrWalk,LYMode ~= "PvE" and GCDCheck(DKWrWalk) and (IsRooted("player",LYDKWrWalkTime) or (HaveDebuff("player",listSlows) and CalculateHP(LYEnemyTarget) < LYDKWrWalkHP)) and UnitIsVisible(LYEnemyTarget) and not inRange(DKFStrike,LYEnemyTarget)) or
		SlowTarget(DKChains,"magic",nil,LYSlowAlways) or
		Peel(DKChains,"magic",LYPeelAny,LYPeelHealer) or
		CommonAttack(DKReaper,"magic",true,DKDeathStrike,true,nil,nil,nil,40) or
		ConditionalSpell(DKDanceWeapon,GCDCheck(DKDanceWeapon) and BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",DKDeathStrike)) or
		BloddrinkPause() or
		CommonAttack(DKBonestorm,"phys",nil,DKDeathStrike,GCDCheck(DKBonestorm) and LYUP > 79 and CalculateHP("player") < 85 and EnemiesAroundUnit(10) > 2) or
		CommonAttack(DKBloodBoil,"phys",nil,DKDeathStrike,GCDCheck(DKBloodBoil) and SpellChargesCheck(DKBloodBoil) and not BreakCCAroundUnit("player",12)) or
		DKLichbornHeal() or
		CommonAttack(DKDeathStrike,"phys",true,DKDeathStrike,(CalculateHP("player") < 75 or HaveBuff("player",DKDarkSuccor) or LYUP > 99)) or
		DefensiveOnPlayer(DKTombstone,nil,LYDKTombHP,LYDKTombBurst,LYDKTombHealer,GCDCheck(DKTombstone) and BuffCount("player",DKBoneShiled) > 4 and LYUP < 60) or
		PlayerDefensiveOnEnemy(DKMarkBlood,"MELEE","phys",nil,nil,nil,true) or
		CommonAttack(DKDeathChain,"magic",true,DKDeathChain,LYMode ~= "PvE",1,DKDeathChain) or
		AOEAttack(DKDecay,8,DKDeathStrike,LYDKDecay,not IsTalentInUse(316916) or not HaveBuff("player",DKDecay)) or
		CommonAttack(DKMarrowrend,"phys",true,DKMarrowrend,GCDCheck(DKMarrowrend) and BuffCount("player",DKBoneShiled,4) < 8 and (not HaveBuff("player",DKDanceWeapon) or BuffCount("player",DKBoneShiled,4) < 3)) or
		CommonAttack(DKBloodBoil,"phys",nil,DKDeathStrike,not BreakCCAroundUnit("player",12)) or
		CommonAttack(DKDeathCaress,"magic",true,DKDeathCaress,not GCDCheck(DKBloodBoil),8,DKBloodPlague) or
		CommonAttack(DKBloddrink,"magic",true,DKBloddrink,CalculateHP("player") < 90) or
		ConditionalSpell(DKAbomLimb,GCDCheck(DKAbomLimb) and UnitAffectingCombat("player") and EnemiesAroundUnit(15) > 2) or
		CommonAttack(DKHeartStrike,"phys",true,DKDeathStrike,true) or
		CommonAttack(DKConsumption,"phys",true,DKDeathStrike,CalculateHP("player") < 85) or
		CommonAttack(DKCoil,"magic",true,DKCoil,GCDCheck(DKCoil) and LYUP == LYUPMax) or
		ConnecTarget(DKGrip,LYDKGripBurst,LYDKGripHP) then
			return true
		end
	end
	function LYDeathKnightFrost()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"magic",DKFStrike) then
				if GCDCheck(DKAP) and LYUP <= LYUPMax - 30 and DKRuneCount() < 4 then
					LY_Print(DKAP,"green", DKAP)
					LYQueueSpell(DKAP)
					return true
				end
				if GCDCheck(DKPillar) then
					LYQueueSpell(DKPillar)
					LY_Print(DKPillar,"green",DKPillar)
					return true
				end
				if GCDCheck(DKFArt) and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(DKFArt,LYEnemyTarget,"face")
					LY_Print(DKFArt,"green",DKFArt)
					return true
				end
				if GCDCheck(DKAbomLimb) then
					LYQueueSpell(DKAbomLimb)
					LY_Print(DKAbomLimb,"green",DKAbomLimb)
					return true
				end
				if GCDCheck(DKSindra) and not HaveBuff("player",DKSindra) and LYFacingCheck(LYEnemyTarget) then
					if LYUP > 79 then
						CastSpellByName(DKSindra)
						LY_Print(DKSindra,"green",DKSindra)
						return true
					else
						DoNotUsePower = 80
					end
				end
			end
		end
		local function Blast()
			if GCDCheck(DKHBlast) and LYStyle ~= "Utilities only" then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and inRange(DKChains,LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and not BreakCCAroundUnit(LYEnemies[i],10) and (EnemiesAroundUnit(8,LYEnemies[i]) > 2 or (UnitIsPlayer(LYEnemies[i]) and CalculateHP(LYEnemies[i]) < 25)) and LYFacingCheck(LYEnemies[i]) then
						LYQueueSpell(DKHBlast,LYEnemies[i])
						return true
					end
				end
			end
		end
		if CommonKick(DKKick,"magic","kick",true) or
		CommonKick(DKStrangulate,"magic","alt",LYMode ~= "PvE") or
		DKReflectIncCC() or
		LYReflect(DKAMS,true) or
		DKSimulStealCC() or
		DKCancelLichborn() or
		TauntCC(DKTaunt) or
		PauseRotation or
		DefensiveOnPlayer(DKEatPet,nil,LYDKEatPetHP,nil,nil,true) or
		DefensiveOnTeam(DKAMS,nil,LYDKAMSHP,LYDKAMSBurst,30,LYDKAMSTeammate and IsPvPTalentInUse(5591)) or
		DefensiveOnPlayer(DKAMS,nil,LYDKAMSHP,LYDKAMSBurst,LYDKAMSHealer,true) or
		DefensiveOnPlayer(DKLichborn,nil,LYDKLichbornHP,nil,nil,LYUP > 29) or
		ConditionalSpell(DKDeathAdvance,LYMode ~= "PvE" and GCDCheck(DKDeathAdvance) and CalculateHP(LYEnemyTarget) < LYDKDeathAdvanceHP and not IsInDistance(LYEnemyTarget,8) and not IsRooted("player") and HaveDebuff("player",listSlows)) or
		BRDeadFriend() or
		DKSummonPet() or
		AntiStealth(DKChains) or
		TotemStomp({DKFStrike,DKObliterate},{DKCoil,DKHBlast},30) or
		CommonKick(DKGrip,"magic","move",LYDKGripKick) or
		CommonKick(DKBlindSleet,"magic","alt",LYDKBlindSleetKick,8) or
		CommonKick(DKAsphyx,"phys","alt",LYDKAsphyxKick) or
		DKSacPet() or
		DKWalkPause() or
		DKSimulFire() or
		DefensiveOnTeam(DKAMZ,"WIZARD",LYDKAMZHP,LYDKAMZBurst,30,true) or
		StunCC(DKAsphyx,"phys",LYDKAsphyxDR,LYDKAsphyxHealer,LYDKAsphyxHealerHP,LYDKAsphyxTeamBurst,LYDKAsphyxDPS,LYDKAsphyxDPSHP,LYDKAsphyxDPSBurst,LYDKAsphyxCont,LYDKAsphyxFocus) or
		ControlCC(DKBlindSleet,nil,LYDKBlindSleetDR,LYDKBlindSleetHealer,LYDKBlindSleetHealerHP,LYDKBlindSleetTeamBurst,LYDKBlindSleetDPS,LYDKBlindSleetDPSHP,LYDKBlindSleetDPSBurst,LYDKBlindSleetCont,LYDKBlindSleetFocus,nil,8) or
		SlowTarget(DKChains,"magic",nil,LYSlowAlways) or
		Peel(DKChains,"magic",LYPeelAny,LYPeelHealer) or
		ConditionalSpell(DKWrWalk,LYMode ~= "PvE" and GCDCheck(DKWrWalk) and (IsRooted("player",LYDKWrWalkTime) or (HaveDebuff("player",listSlows) and CalculateHP(LYEnemyTarget) < LYDKWrWalkHP)) and UnitIsVisible(LYEnemyTarget) and not inRange(DKFStrike,LYEnemyTarget)) or
		Burst() or
		DKLichbornHeal() or
		CommonAttack(DKDeathStrike,"phys",true,DKDeathStrike,not DoNotUsePower and (CalculateHP("player") < LYDKDeathStrikeHP or HaveBuff("player",DKDarkSuccor) or LYHDPS or (LYDKDeathStrikeBurst and CalculateHP("player") < 70 and EnemyIsTargetingUnit("player",EnemyIsBursting())))) or
		ConditionalSpell(DKSindra,DoNotUsePower and LYUP >= DoNotUsePower and inRange(DKFStrike,LYEnemyTarget) and SpellAttackTypeCheck(LYEnemyTarget,"magic") and not HaveBuff("player",DKSindra)) or
		AOEAttack(DKDecay,8,DKFStrike,LYDKDecay,not IsTalentInUse(316916) or not HaveBuff("player",DKDecay)) or
		CommonAttack(DKReaper,"magic",true,DKDeathStrike,true,nil,nil,nil,40) or
		CommonAttack(DKChillStreak,"magic",true,DKCoil,HaveBuff("player",DKPillar),nil,nil,2) or
		CommonAttack(DKHBlast,"magic",true,DKChains,HaveBuff("player",DKFFog) and not BreakCCAroundUnit()) or
		CommonAttack(DKFStrike,"magic",true,DKFStrike,(not HaveBuff("player",DKKillMashine) or not GCDCheck(DKObliterate) or LYUP > 79) and not DoNotUsePower and not HaveBuff("player",DKSindra) and not LYHDPS and DKRuneCount() < 6 and CalculateHP("player") > LYDKDeathStrikeHP) or
		CommonAttack(DKChains,"magic",true,DKChains,IsTalentInUse(281208) and ((HaveBuff("player",DKUnhStr) and BuffCount("player",DKColdHeart) > 9) or BuffCount("player",DKColdHeart) > 19)) or
		CommonAttack(DKGlac,"magic",true,DKFStrike,(not HaveBuff("player",DKKillMashine) or not GCDCheck(DKObliterate)) and not DoNotUsePower and not HaveBuff("player",DKSindra) and not LYHDPS) or
		CommonAttack(DKWinter,"magic",true,DKFStrike,GCDCheck(DKWinter) and (IsPvPTalentInUse(3743) or not HaveBuff("player",DKPillar))) or
		CommonAttack(DKScythe,"magic",true,DKFStrike,GCDCheck(DKScythe) and HaveBuff("player",DKKillMashine) and not BreakCCAroundUnit("player",10),nil,nil,2) or
		CommonAttack(DKScythe,"magic",true,DKFStrike,GCDCheck(DKScythe) and not BreakCCAroundUnit("player",10),nil,nil,3) or
		CommonAttack(DKHBlast,"magic",true,DKChains,IsTalentInUse(281238) and HaveBuff("player",DKPillar) and not HaveBuff("player",DKKillMashine) and not BreakCCAroundUnit()) or
		CommonAttack(DKObliterate,"phys",true,DKFStrike,true) or
		Blast() or
		CommonAttack(DKCoil,"magic",true,DKCoil,GCDCheck(DKCoil) and not LYHDPS and ((CalculateHP("player") > LYDKDeathStrikeHP + 10 or LYUP > 79) or LYMode == "PvE")) or
		ConnecTarget(DKGrip,LYDKGripBurst,LYDKGripHP) then
			return true
		end
	end
	function LYDeathKnightUnh()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"magic",DKScourge) then
				if GCDCheck(DKUnhBlight) and not BreakCCAroundUnit("player",10) then
					LYQueueSpell(DKUnhBlight)
					LY_Print(DKUnhBlight,"green",DKUnhBlight)
					return true
				end
				if GCDCheck(DKDeadArmy) and LYDKDeadArmy and (UnitIsBoss(LYEnemyTarget) or UnitIsPlayer(LYEnemyTarget)) then
					LYQueueSpell(DKDeadArmy)
					LY_Print(DKDeadArmy,"green",DKDeadArmy)
					return true
				end
				if GCDCheck(DKTransform) and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and UnitAffectingCombat("pet") then
					LY_Print(DKTransform,"green",DKTransform)
					LYQueueSpell(DKTransform)
					return true
				end
				if GCDCheck(DKAbomLimb) then
					LYQueueSpell(DKAbomLimb)
					LY_Print(DKAbomLimb,"green",DKAbomLimb)
					return true
				end
				if GCDCheck(DKAbomination) and UnitIsPlayer(LYEnemyTarget) and IsPvPTalentInUse(3747) and not BreakCCAroundUnit(LYEnemyTarget,15) then
					LYQueueSpell(DKAbomination,LYEnemyTarget)
					LY_Print(DKAbomination,"green",DKAbomination)
					return true
				end
				if GCDCheck(DKUnhFrenzy) then
					LYQueueSpell(DKUnhFrenzy)
					LY_Print(DKUnhFrenzy,"green",DKUnhFrenzy)
					return true
				end
				if GCDCheck(DKSumGarg) then
					LYQueueSpell(DKSumGarg)
					LY_Print(DKSumGarg,"green",DKSumGarg)
					return true
				end
				if GCDCheck(DKApocalypse) and DebuffCount(LYEnemyTarget,DKFestWound) > 3 and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(DKApocalypse,LYEnemyTarget)
					LY_Print(DKApocalypse,"green",DKApocalypse)
					return true
				end
				if GCDCheck(DKVileContag) and DebuffCount(LYEnemyTarget,DKFestWound) > 2 and DebuffCount(LYEnemyTarget,DKFestWound) >= EnemiesAroundUnit(DKDeathStrike) then
					LYQueueSpell(DKVileContag)
					LY_Print(DKVileContag,"green",DKVileContag)
					return true
				end
			end
		end
		local function Scourge(func)
			if LYStyle ~= "Utilities only" and GCDCheck(DKScourge) and func and (not IsBursting() or not GCDCheck(DKApocalypse)) and LYUP < 90 then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and inRange(DKScourge,LYEnemies[i]) and HaveDebuff(LYEnemies[i],DKFestWound,0.5,"player") and LYFacingCheck(LYEnemies[i]) then
						LYQueueSpell(DKScourge,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function FestStrike()
			if GCDCheck(DKFestStrike) and LYStyle ~= "Utilities only" and LYUP < 80 then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and inRange(DKDeathStrike,LYEnemies[i]) and DebuffCount(LYEnemies[i],DKFestWound) < 4 and LYFacingCheck(LYEnemies[i]) then
						LYQueueSpell(DKFestStrike,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function PetKick()
			if GCDCheck(DKPetJump) and LYKickPause == 0 and HaveBuff("pet",DKTransform) then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) then
						local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
						local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(LYEnemies[i])
						local modified
						if channelName then
							castName = channelName
							castStartTime = channelStartTime
							castEndTime = channelEndTime
							castInterruptable = channelInterruptable
							modified = true
						end
						if castName and not castInterruptable and ValidKick(LYEnemies[i],castName) then
							local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
							local castTime = castEndTime - castStartTime
							local currentPercent = timeSinceStart / castTime * 100
							if (currentPercent > KickTime - 10 or (modified and timeSinceStart > KickDelayFixed)) and castTime > LYKickMin and SpellAttackTypeCheck(LYEnemies[i],"phys") and IsInDistance("pet",32,LYEnemies[i]) and currentPercent < 95 then
								LYKickPause = GetTime()
								if not IsInDistance("pet",5,LYEnemies[i]) then
									LYCurrentSpellName = nil
									LYQueueSpell(DKPetJump,LYEnemies[i])
									LY_Print(DKPetJump .. " " .. castName,"green",DKPetJump)
									return true
								elseif PetBehTimer < GetTime() then
									PetBehTimer = GetTime() + 1
									local x,y,z = ObjectPosition(LYEnemies[i])
									if InLineOfSightPointToUnit(x + 6,y,z,"pet") then
										PetMoveTo()
										ClickPosition(x + 6,y,z)
									elseif InLineOfSightPointToUnit(x,y + 6,z,"pet") then
										PetMoveTo()
										ClickPosition(x,y + 6,z)
									elseif InLineOfSightPointToUnit(x - 6,y,z,"pet") then
										PetMoveTo()
										ClickPosition(x - 6,y,z)
									elseif InLineOfSightPointToUnit(x,y - 6,z,"pet") then
										PetMoveTo()
										ClickPosition(x,y - 6,z)
									end
									return true
								end
							end
						end
					end
				end
			end
		end
		if CommonKick(DKKick,"magic","kick",true) or
		CommonKick(DKStrangulate,"magic","alt",LYMode ~= "PvE") or
		PetKick() or
		CommonKick(DKGnaw,"phys","alt",LYDKPetStunKick and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet"),20) or
		DKReflectIncCC() or
		DKCancelLichborn() or
		LYReflect(DKAMS,true) or
		DKSimulStealCC() or
		TauntCC(DKTaunt) or
		PauseRotation or
		DefensiveOnPlayer(DKEatPet,nil,LYDKEatPetHP,nil,nil,true) or
		PetBehaviour() or
		DefensiveOnTeam(DKAMS,nil,LYDKAMSHP,LYDKAMSBurst,30,LYDKAMSTeammate and IsPvPTalentInUse(5590)) or
		DefensiveOnPlayer(DKAMS,nil,LYDKAMSHP,LYDKAMSBurst,LYDKAMSHealer,true) or
		DefensiveOnPlayer(DKLichborn,nil,LYDKLichbornHP,nil,nil,LYUP > 29) or
		ConditionalSpell(DKDeathAdvance,LYMode ~= "PvE" and GCDCheck(DKDeathAdvance) and ((UnitIsPlayer(LYEnemyTarget) and LYMode == "Outworld") or LYMode == "PvP") and CalculateHP(LYEnemyTarget) < LYDKDeathAdvanceHP and not IsInDistance(LYEnemyTarget,8) and not IsRooted("player") and HaveDebuff("player",listSlows)) or
		BRDeadFriend() or
		DKSummonPet() or
		AntiStealth(DKOutbreak) or
		DKAntiDrink() or
		TotemStomp({DKFestStrike,DKScourge},{DKClawShad,DKCoil,DKOutbreak},30) or
		CommonKick(DKGrip,"magic","move",LYDKGripKick) or
		CommonKick(DKBlindSleet,"magic","alt",LYDKBlindSleetKick,8) or
		CommonKick(DKAsphyx,"phys","alt",LYDKAsphyxKick) or
		DKSacPet() or
		DKWalkPause() or
		DKSimulFire() or
		DefensiveOnTeam(DKAMZ,"WIZARD",LYDKAMZHP,LYDKAMZBurst,30,true) or
		StunCC(DKAsphyx,"magic",LYDKAsphyxDR,LYDKAsphyxHealer,LYDKAsphyxHealerHP,LYDKAsphyxTeamBurst,LYDKAsphyxDPS,LYDKAsphyxDPSHP,LYDKAsphyxDPSBurst,LYDKAsphyxCont,LYDKAsphyxFocus) or
		ControlCC(DKBlindSleet,nil,LYDKBlindSleetDR,LYDKBlindSleetHealer,LYDKBlindSleetHealerHP,LYDKBlindSleetTeamBurst,LYDKBlindSleetDPS,LYDKBlindSleetDPSHP,LYDKBlindSleetDPSBurst,LYDKBlindSleetCont,LYDKBlindSleetFocus,nil,8) or
		SlowTarget(DKChains,"magic",nil,LYSlowAlways) or
		Peel(DKChains,"magic",LYPeelAny,LYPeelHealer) or
		ConditionalSpell(DKWrWalk,LYMode ~= "PvE" and GCDCheck(DKWrWalk) and ((UnitIsPlayer(LYEnemyTarget) and LYMode == "Outworld") or LYMode == "PvP") and (IsRooted("player",LYDKWrWalkTime) or (HaveDebuff("player",listSlows) and CalculateHP(LYEnemyTarget) < LYDKWrWalkHP)) and UnitIsVisible(LYEnemyTarget) and not inRange(DKFStrike,LYEnemyTarget)) or
		Burst() or
		DKLichbornHeal() or
		CommonAttack(DKDeathStrike,"phys",true,DKDeathStrike,(CalculateHP("player") < LYDKDeathStrikeHP or HaveBuff("player",DKDarkSuccor) or LYHDPS or (LYDKDeathStrikeBurst and CalculateHP("player") < 70 and EnemyIsTargetingUnit("player",EnemyIsBursting())))) or
		AOEAttack(DKDecay,8,DKDeathStrike,LYDKDecay,not IsTalentInUse(316916) or not HaveBuff("player",DKDecay)) or
		CommonAttack(DKReaper,"magic",true,DKDeathStrike,true,nil,nil,nil,40) or
		Scourge(not IsTalentInUse(390175) or not HaveBuff("player",DKPlagueBring,1.5)) or
		ConditionalSpell(DKEpidemic,GCDCheck(DKEpidemic) and ((not LYHDPS and LYUP > 79) or HaveBuff("player",DKSuddenDoom)) and EnemiesAroundUnitDoTed(nil,nil,DKVirPlague) >= LYDKEpidemic) or
		FestStrike() or
		CommonAttackTarget(DKApocalypse,"magic",true,IsTalentInUse(276837) and IsPvPTalentInUse(3746) and DebuffCount(LYEnemyTarget,DKFestWound) > 3 and inRange(DKDeathStrike,LYEnemyTarget)) or
		CommonAttack(DKCoil,"magic",true,DKCoil,(not LYHDPS and LYUP > 79) or HaveBuff("player",DKSuddenDoom)) or
		CommonAttack(DKOutbreak,"magic",true,DKOutbreak,true,3,DKVirPlague) or
		Scourge(true) or
		ConditionalSpell(DKEpidemic,GCDCheck(DKEpidemic) and not LYHDPS and (LYMode ~= "PvP" or CalculateHP("player") > LYDKDeathStrikeHP) and EnemiesAroundUnitDoTed(nil,nil,DKVirPlague) >= LYDKEpidemic) or
		CommonAttack(DKCoil,"magic",true,DKCoil,not LYHDPS and (LYMode ~= "PvP" or CalculateHP("player") > LYDKDeathStrikeHP)) or
		CommonAttack(DKReanimat,"magic",nil,DKReanimat,LYMode == "PvP" and #LYEnemies < 4 and DKRuneCount() > 4) or
		ConnecTarget(DKGrip,LYDKGripBurst,LYDKGripHP) then
			return true
		end
	end
	function LYDemonHunterHavoc()
		local function FelRush()
			if GCDCheck(DHFelRush) and LYDHFelRushDPS and not IsMoving() and not IsRooted() and UnitIsVisible(LYEnemyTarget) and inRange(DHChaosStrk,LYEnemyTarget) and ((IsTalentInUse(347461) and HaveBuff("player",DHUnboundChaos)) or (IsTalentInUse(206476) and not HaveBuff("player",DHMomentum))) then
				if C_Spell.GetSpellCooldown(DHFelRush).startTime == 0 then
					if not IsTalentInUse(427794) then
						MoveBackwardStart()
						JumpOrAscendStart()
					end
					CastSpellByName(DHFelRush)
					PauseGCD = GetTime() + 1.2
					if not IsTalentInUse(427794) then
						C_Timer.After(1, function() MoveBackwardStop() AscendStop() end)
					end
				end
				return true
			end
		end
		local function RainFromAboveAttack()
			if HaveBuff("player",DHRainAbove) and UnitIsVisible(LYEnemyTarget) then
				OverrideActionBarButton1:Click("LeftButton",true)
				PauseGCD = GetTime() + 0.1
				return true
			end
		end
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",DHGlaive) then
				if GCDCheck(DHBurst) and not HaveBuff("player",DHBurst) and not IsRooted() then
					if UnitIsBoss(LYEnemyTarget) then
						LYQueueSpell(DHBurst,"player")
						LY_Print(DHBurst,"green",DHBurst)
						return true
					else
						LYQueueSpell(DHBurst,LYEnemyTarget)
						LY_Print(DHBurst,"green",DHBurst)
						return true
					end
				end
				if GCDCheck(DHFelErupt) and LYDHFelEruptBurst and inRange(DHFelErupt,LYEnemyTarget) and not UnitIsCCed(LYEnemyTarget) and CheckUnitDR(LYEnemyTarget,"stun") and (LYUP > 59 or CheckRole(LYEnemyTarget) ~= "HEALER") and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(DHFelErupt,LYEnemyTarget)
					LY_Print(DHFelErupt,"green",DHFelErupt)
					return true
				end
				if GCDCheck(DHHunt) and not IsRooted() and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(DHHunt,LYEnemyTarget)
					LY_Print(DHHunt,"green",DHHunt)
					return true
				end
				if GCDCheck(DHFelBar) and EnemiesAroundUnit(10) >= LYDHFelBar then
					if LYUP > 80 then
						LYQueueSpell(DHFelBar)
						LY_Print(DHFelBar,"green",DHFelBar)
						DoNotUsePower = nil
						return true
					elseif not DoNotUsePower then
						DoNotUsePower = 80
					end
				end
			end
		end
		local function EyeBeam()
			if GCDCheck(DHEyeBeam) and (not IsTalentInUse(203550) or LYUP < 61) and LYStyle ~= "Utilities only" and SpellAttackTypeCheck(LYEnemyTarget,"magic") and IsInDistance(LYEnemyTarget,15) and EnemiesAroundUnit(DHChaosStrk,nil,nil,true) >= LYDHEyeBeamCast and (not IsMoving() or LYDHEyeBeamMove) then
				LYQueueSpell(DHEyeBeam,LYEnemyTarget,"force")
				return true
			end
		end
		local function Kick()
			if GCDCheck(DHKick) and LYKickPause == 0 and (LYMode ~= "PvE" or not UnitChannelInfo("player")) then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) then
						local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
						local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(LYEnemies[i])
						local modified = nil
						if channelName then
							castName = channelName
							castStartTime = channelStartTime
							castEndTime = channelEndTime
							castInterruptable = channelInterruptable
							modified = true
						end
						if castName and not castInterruptable and SpellAttackTypeCheck(LYEnemies[i],"magic") and ValidKick(LYEnemies[i],castName) then
							local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
							local castTime = castEndTime - castStartTime
							local currentPercent = timeSinceStart / castTime * 100
							local castTimeLeft = castTime - timeSinceStart
							if castTime > LYKickMin and currentPercent < 95 then
								if inRange(DHKick,LYEnemies[i]) then
									if currentPercent > KickTime or (modified and timeSinceStart > KickDelayFixed) then
										LYSpellStopCasting()
										LYQueueSpell(DHKick,LYEnemies[i],"face")
										LYKickPause = GetTime()
										LY_Print(DHKick.." "..castName,"green",DHKick)
										return true
									end
								elseif LYDHFelRushKick and GCDCheck(DHFelRush) and not IsRooted() and IsInDistance(LYEnemies[i],30) and currentPercent > 20 and castTimeLeft < 500 then
									LYSpellStopCasting()
									DHFelRushTarget(LYEnemies[i])
									LY_Print(DHFelRush.." to kick","green",DHFelRush)
									return true
								end
							end
						end
					end
				end
			end
		end
		local function VengGlimseCC()
			if GCDCheck(DHVengRetreat) and LYMode ~= "PvE" and IsPvPTalentInUse(813) and LYKickPause == 0 and (EnemyHPBelow(LYDHVengRetreatCCHP) or (LYDHVengRetreatCCBurst and IsBursting())) then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
						local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
						if castName and tContains(listRefl,castName) and PlayerIsSpellTarget(LYEnemies[i]) and CheckUnitDRSpell("player",castName) then
							local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
							local castTime = castEndTime - castStartTime
							local currentPercent = timeSinceStart / castTime * 100
							if currentPercent > 70 then
								CastSpellByName(DHVengRetreat)
								LYKickPause = GetTime()
								LY_Print(DHVengRetreat.." "..castName,"green",DHVengRetreat)
							end
						end
					end
				end
			end
		end
		local function Glaive()
			if GCDCheck(DHGlaive) and LYStyle ~= "Utilities only" and UnitAffectingCombat("player") and not BreakCCAroundUnit() then
				if IsTalentInUse(391189) then
					for i=1,#LYEnemies do
						if ValidEnemyUnit(LYEnemies[i]) and inRange(DHGlaive,LYEnemies[i]) and not HaveDebuff(LYEnemies[i],DHBurnWound,4,"player") and LYFacingCheck(LYEnemies[i]) then
							LYQueueSpell(DHGlaive,LYEnemies[i])
							return true
						end
					end
				end
				if ValidEnemyUnit(LYEnemyTarget) and inRange(DHGlaive,LYEnemyTarget) and (not IsTalentInUse(388106) or not HaveDebuff(LYEnemyTarget,DHSoulrend,2,"player")) and LYFacingCheck(LYEnemies[i]) then
					LYQueueSpell(DHGlaive,LYEnemyTarget)
					return true
				end
			end
		end
		if ConditionalSpell(DHFelRush,IsSpellOverlayed(195072) and IsTalentInUse(427794)) or
		TauntCC(DHTaunt) or
		Kick() or
		DHGlideKnocks() or
		VengGlimseCC() or
		PauseRotation or
		CommonAttackTarget(DHFelblade,"phys",true,UnitIsVisible(LYEnemyTarget) and inRange(DHFelblade,LYEnemyTarget) and LYLastSpellName == DHVengRetreat and LYDHFelbladeVR) or
		DefensiveOnPlayer(DHBlur,nil,LYDHBlurHP,LYDHBlurBurst,LYDHBlurHealer,true) or
		AntiStealth(DHTaunt) or
		DHFelRushEvade() or
		TripleCC(DHStun,LYDHStunAOE,8) or
		DHSigilMisKick() or
		CommonKick(DHImprison,"magic","alt",LYDHImprisonKick) or
		CommonKick(DHStun,"magic","alt",LYDHStunKick,8) or
		CommonKick(DHFelErupt,"magic","alt",LYDHFelEruptKick) or
		TotemStomp({DHChaosStrk,DHDemonBite},{DHGlaive},30) or
		PurgeEssential(DHConsumeMagic) or
		DHReverseMagic() or
		StunCC(DHFelErupt,"magic",LYDHFelEruptDR,LYDHFelEruptHealer,LYDHFelEruptHealerHP,LYDHFelEruptTeamBurst,LYDHFelEruptDPS,LYDHFelEruptDPSHP,LYDHFelEruptDPSBurst,LYDHFelEruptCont,LYDHFelEruptFocus) or
		StunCC(DHStun,"magic",LYDHStunDR,LYDHStunHealer,LYDHStunHealerHP,LYDHStunTeamBurst,LYDHStunDPS,LYDHStunDPSHP,LYDHStunDPSBurst,LYDHStunCont,LYDHStunFocus,8) or
		ControlCC(DHImprison,"magic",LYDHImprDR,LYDHImprHealer,LYDHImprHealerHP,LYDHImprTeamBurst,LYDHImprDPS,LYDHImprDPSHP,LYDHImprDPSBurst,LYDHImprCont,LYDHImprFocus) or
		FearCC(DHSigilMisery,"magic",LYDHSigMisDR,LYDHSigMisHealer,LYDHSigMisHealerHP,LYDHSigMisTeamBurst,LYDHSigMisDPS,LYDHSigMisDPSHP,LYDHSigMisDPSBurst,nil,nil,nil,30) or
		Burst() or
		DefensiveOnPlayer(DHRainAbove,"MELEE",LYDHRainAboveHP,LYDHRainAboveBurst,LYDHRainAboveHealer,LYMode ~= "PvE" and not HaveBuff("player",DHBurst)) or
		DefensiveOnPlayer(DHNetherwalk,nil,LYDHNWalkHP,LYDHNWalkBurst,LYDHNWalkHealer,true) or
		DefensiveOnTeam(DHDarkness,nil,LYDHDarknessHP,LYDHDarknessBurst,7,true) or
		RainFromAboveAttack() or
		FelRush() or
		EyeBeam() or
		AOEAttack(DHElysian,8,DHGlaive,LYDHElysianAOE,LYDHElysianAOE > 1) or
		CommonAttackTarget(DHSigilFlame,"magic",true,inRange(DHChaosStrk,LYEnemyTarget) and not IsMoving(LYEnemyTarget) and not HaveDebuff(LYEnemyTarget,DHSigilFlame,2)) or
		CommonAttackTarget(DHElysian,"magic",true,GCDCheck(DHElysian) and LYDHElysianAOE == 1 and inRange(DHChaosStrk,LYEnemyTarget) and not IsMoving(LYEnemyTarget)) or
		CommonAttack(DHImmoAura,"magic",nil,DHChaosStrk,LYUP < 80 and not BreakCCAroundUnit("player",9)) or
		CommonAttack(DHGlTempest,"phys",nil,DHChaosStrk,not DoNotUsePower and not BreakCCAroundUnit("player",11)) or
		CommonAttack(DHEssBreak,"phys",true,DHChaosStrk,not BreakCCAroundUnit("player",9,true) and CDLeft(DHEyeBeam) > 4 and GCDCheck(DHBladeDance)) or
		ConditionalSpell(DHBladeDance,GCDCheck(DHBladeDance) and not DoNotUsePower and EnemiesAroundUnit(8) > 2) or
		Glaive(DHGlaive,"phys",true,inRange(DHGlaive,LYEnemyTarget) and UnitAffectingCombat("player") and not BreakCCAroundUnit() and (not IsTalentInUse(388106) or not HaveDebuff(LYEnemyTarget,DHSoulrend,1.5,"player"))) or
		CommonAttack(DHBladeDance,"phys",nil,DHChaosStrk,not DoNotUsePower and (IsTalentInUse(206416) or IsTalentInUse(389978) or IsTalentInUse(389687)) and not BreakCCAroundUnit("player",9)) or
		CommonAttack(DHChaosStrk,"phys",true,DHChaosStrk,not DoNotUsePower) or
		CommonAttackTarget(DHFelblade,"phys",true,UnitIsVisible(LYEnemyTarget) and inRange(DHFelblade,LYEnemyTarget) and (not LYDHFelbladeMelee or inRange(DHChaosStrk,LYEnemyTarget)) and (((CalculateHP(LYEnemyTarget) < LYDHFelbladeHP or (LYDHFelbladeBurst and IsBursting())) and not ObjectIsBehind(LYEnemyTarget,"player") and not HaveBuff("player",DHDarkness)) or inRange(DHChaosStrk,LYEnemyTarget)) and LYUP < 80 and not IsRooted()) or
		DHConsumeMagicCast() or
		ConditionalSpell(DHVengRetreat,LYDHVengRetreat and GCDCheck(DHVengRetreat) and not IsMoving() and IsTalentInUse(389688) and UnitIsVisible(LYEnemyTarget) and not HaveBuff("player",DHPrepared) and LYUP < 40 and not IsRooted() and inRange(DHChaosStrk,LYEnemyTarget)) or
		CommonAttack(DHDemonBite,"phys",true,DHChaosStrk,not IsTalentInUse(203555)) then
			return true
		end
	end
	function LYDemonHunterVeng()
		if CommonKick(DHKick,"phys","kick",not UnitChannelInfo("player") or LYMode ~= "PvE") or
		DHGlideKnocks() or
		PauseRotation or
		ConditionalSpell(DHBurst,GCDCheck(DHBurst) and CalculateHP("player") < LYDHMetaTank and FriendIsUnderAttack("player")) or
		ConditionalSpell(DHDemonSpike,GCDCheck(DHDemonSpike) and not HaveBuff("player",DHDemonSpike,2) and CalculateHP("player") < 90 and FriendIsUnderAttack("player","MELEE")) or
		TauntPvP(DHTaunt,1220) or
		Taunt(DHTaunt) or
		AntiStealth(DHGlaive) or
		DHFelRushEvade() or
		TripleCC(DHStun,LYDHStunAOE,8) or
		DHSigilMisKick() or
		CommonKick(DHImprison,"phys","alt",LYDHImprisonKick) or
		CommonKick(DHStun,"magic","alt",LYDHStunKick,8) or
		CommonAttack(DHIlGrasp,"magic",nil,DHGlaive,LYMode ~= "PvE" and UnitChannelInfo("player") == DHIlGrasp) or
		TotemStomp({DHShear,DHSoulCleave},{DHGlaive},30) or
		PurgeEssential(DHConsumeMagic) or
		DHReverseMagic() or
		StunCC(DHStun,"magic",LYDHStunDR,LYDHStunHealer,LYDHStunHealerHP,LYDHStunTeamBurst,LYDHStunDPS,LYDHStunDPSHP,LYDHStunDPSBurst,LYDHStunCont,LYDHStunFocus,8) or
		ControlCC(DHImprison,"magic",LYDHImprDR,LYDHImprHealer,LYDHImprHealerHP,LYDHImprTeamBurst,LYDHImprDPS,LYDHImprDPSHP,LYDHImprDPSBurst,LYDHImprCont,LYDHImprFocus) or
		FearCC(DHSigilMisery,"magic",LYDHSigMisDR,LYDHSigMisHealer,LYDHSigMisHealerHP,LYDHSigMisTeamBurst,LYDHSigMisDPS,LYDHSigMisDPSHP,LYDHSigMisDPSBurst,nil,nil,nil,30) or
		CommonAttack(DHFelDevas,"magic",true,DHKick,CalculateHP("player") < LYDHFelDevasHP and not IsMoving(),nil,nil,LYDHFelDevasAOE) or
		DefensiveOnEnemy(DHSigilSilence,"WIZARD","magic",LYDHSigSilenHP,LYDHSigSilenBurst,30,true) or
		DefensiveOnEnemy(DHSigilChains,"MELEE","magic",LYDHSigChainHP,LYDHSigChainBurst,30,true) or
		DefensiveOnEnemy(DHIlGrasp,"MELEE","magic",LYDHIlGraspHP,LYDHIlGraspBurst,nil,LYMode ~= "PvE" and UnitChannelInfo("player") ~= DHIlGrasp) or
		PlayerDefensiveOnEnemy(DHFieryBrand,nil,nil,LYDHFieryBrandHP,LYDHFieryBrandBurst,30,true) or
		CommonAttackTarget(DHSoulCarve,"magic",true,GCDCheck(DHSoulCarve) and inRange(DHSoulCleave,LYEnemyTarget) and (not IsTalentInUse(389958) or DebuffCount(LYEnemyTarget,DHFrailty) > 5) and (not IsTalentInUse(389958) or HaveDebuff(LYEnemyTarget,DHFieryBrand))) or
		AOEAttack(DHElysian,8,DHGlaive,LYDHElysianAOE,true) or
		CommonAttackTarget(DHElysian,"magic",true,GCDCheck(DHElysian) and LYDHElysianAOE == 1 and inRange(DHGlaive,LYEnemyTarget) and (IsRooted(LYEnemyTarget,1) or UnitIsCCed(LYEnemyTarget,1) or UnitIsBoss(LYEnemyTarget)) and not IsMoving(LYEnemyTarget)) or
		CommonAttack(DHImmoAura,"magic",nil,DHKick,LYUP < 80 and not BreakCCAroundUnit("player",9)) or
		ConditionalSpell(DHBulkExtr,GCDCheck(DHBulkExtr) and FriendIsUnderAttack("player") and EnemiesAroundUnit(8) > 2) or
		CommonAttack(DHSpiritBomb,"magic",nil,DHKick,true,6,DLYrailty) or
		CommonAttackTarget(DHHunt,"magic",true,GCDCheck(DHHunt) and not IsMoving() and inRange(DHGlaive,LYEnemyTarget) and not IsRooted() and CalculateHP("player") < 80 and (UnitIsPlayer(LYEnemyTarget) or UnitIsBoss(LYEnemyTarget) or CalculateHP("player") < 50) and UnitAffectingCombat(LYEnemyTarget)) or
		CommonAttack(DHSoulCleave,"phys",true,DHSoulCleave,true) or
		AOEAttack(DHSigilFlame,8,DHGlaive,2,true) or
		CommonAttackTarget(DHSigilFlame,"magic",true,inRange(DHGlaive,LYEnemyTarget) and (IsRooted(LYEnemyTarget,2) or UnitIsCCed(LYEnemyTarget,2) or (LYMode == "PvE" and UnitIsBoss(LYEnemyTarget))) and not IsMoving(LYEnemyTarget) and not HaveDebuff(LYEnemyTarget,DHSigilFlame,2)) or
		CommonAttack(DHGlaive,"phys",true,DHGlaive,UnitAffectingCombat("player") and not BreakCCAroundUnit()) or
		CommonAttackTarget(DHFelblade,"phys",true,UnitIsVisible(LYEnemyTarget) and inRange(DHFelblade,LYEnemyTarget) and (not LYDHFelbladeMelee or inRange(DHSoulCleave,LYEnemyTarget)) and (((CalculateHP(LYEnemyTarget) < LYDHFelbladeHP or (LYDHFelbladeBurst and IsBursting())) and not ObjectIsBehind(LYEnemyTarget,"player") and not HaveBuff("player",DHDarkness)) or inRange(DHChaosStrk,LYEnemyTarget)) and LYUP < 80 and not IsRooted()) or
		DHConsumeMagicCast() or
		CommonAttackTarget(DHInfStrike,"magic",true,UnitIsVisible(LYEnemyTarget) and IsTalentInUse(320416) and not IsMoving() and SpellChargesCheck(DHInfStrike) and inRange(DHSoulCleave,LYEnemyTarget) and not ObjectIsBehind(LYEnemyTarget,"player") and not IsRooted()) or
		CommonAttack(DHShear,"phys",true,DHSoulCleave,true) then
			return true
		end
	end
	function LYDruidBalance()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"magic",DrMF) then
				if GCDCheck(DrEluneWar) and not HaveBuff("player",DrEluneWar) then
					LYQueueSpell(DrEluneWar)
					LY_Print(DrEluneWar,"green",DrEluneWar)
					return true
				end
				if IsTalentInUse(102560) and GCDCheck(DrIncElune) then
					LYQueueSpell(DrIncElune,LYEnemyTarget)
					LY_Print(DrIncElune,"green",DrIncElune)
					return true
				end
				if GCDCheck(DrTreants) then
					LYQueueSpell(DrTreants,LYEnemyTarget)
					LY_Print(DrTreants,"green",DrTreants)
					return true
				end
				if GCDCheck(DrEluneWrath) and LYUP < 60 then
					LYQueueSpell(DrEluneWrath,LYEnemyTarget)
					LY_Print(DrEluneWrath,"green",DrEluneWrath)
					return true
				end
				if IsTalentInUse(391528) and GCDCheck(DrConvSpirit) and not EnemyCanKick() then
					StopMoving()
					LYQueueSpell(DrConvSpirit)
					LY_Print(DrConvSpirit,"green",DrConvSpirit)
					return true
				end
			end
		end
		local function Inner()
			if GCDCheck(DrInner) and LYDrInner and (LYMode ~= "PvP" or EnemyIsBursting()) then
				for i=1,#LYTeamHealers do
					if UnitIsVisible(LYTeamHealers[i]) and inRange(DrInner,LYTeamHealers[i]) and (LYMode == "PvP" or IsBursting(LYTeamHealers[i])) then
						LYQueueSpell(DrInner,LYTeamHealers[i])
						LY_Print(DrInner.." @team healer","green",DrInner)
						return true
					end
				end
			end
		end
		local function ShiftRoot()
			if GCDCheck(DrCat) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and IsRooted() and not UnitIsVisible(LYEnemyTarget) then
				if GetShapeshiftForm() == 0 or HaveBuff("player",DrOwl) then
					LYQueueSpell(DrOwl)
					return true
				elseif GetShapeshiftForm() == 1 then
					LYQueueSpell(DrBear)
					return true
				elseif GetShapeshiftForm() == 2 then
					LYQueueSpell(DrCat)
					return true
				elseif GetShapeshiftForm() == 3 then
					LYQueueSpell(DrTravel)
					return true
				end
			end
		end
		local function Form()
			if GCDCheck(DrBear) and LYStyle ~= "Utilities only" then
				if LYMode ~= "PvE" and ((FriendIsUnderAttack("player","MELEE",LYDrBearHP,LYDrBearBurst) and (not LYDrBearHealer or not TeamHealerCanInteract())) or LYStayForm) and not HaveBuff("player",{DrBers,DrIncJungle}) then
					if GetShapeshiftForm() ~= 1 then
						LYQueueSpell(DrBear)
						return true
					end
				elseif GCDCheck(DrOwl) and GetShapeshiftForm() ~= 3 and not HaveBuff("player",{DrOwl,DrRegen,DrDash}) and not LYStayForm then
					LYQueueSpell(DrOwl)
					return true
				end
			end
		end
		local function SolarRootSave()
			if GCDCheck(DrMasRoot) and LYMode ~= "PvE" and GCDCheck(DrSolar) then
				for i=1,#LYTeamPlayers do
					local enemy = FriendIsUnderAttack(LYTeamPlayers[i],nil,LYDrSolarHP,LYDrSolarBurst)
					if UnitIsVisible(enemy) and IsWizzard(enemy) and SpellAttackTypeCheck(enemy,"magic") and inRange(DrSolar,enemy) and CheckUnitDR(enemy,"root") and not HaveBuff(enemy,listISlows) and not UnitIsCCed(enemy,LYGCDTime) and not EnemyIsUnderAttack(enemy) then
						LYQueueSpell(DrSolar,enemy)
						LY_Print(DrSolar.." + " ..DrMasRoot,"green",DrSolar)
						return true
					end
				end
			end
		end
		local function BeamCC()
			if GCDCheck(DrSolar) and GCDCheck(DrMasRoot) and (EnemyHPBelow(LYDrSolarCCHP) or (LYDrSolarCCBurst and TeamIsBursting())) then
				for i=1,#LYEnemyHealers do
					if UnitIsVisible(LYEnemyHealers[i]) and SpellAttackTypeCheck(LYEnemyHealers[i],"magic") and inRange(DrSolar,LYEnemyHealers[i]) and CheckUnitDR(LYEnemyHealers[i],"root") and not UnitIsCCed(LYEnemyHealers[i],LYGCDTime) and not EnemyIsUnderAttack(LYEnemyHealers[i]) and not HaveBuff(LYEnemyHealers[i],listISlows) then
						LYQueueSpell(DrSolar,LYEnemyHealers[i])
						LY_Print(DrSolar.." @enemy healer","green",DrSolar)
						return true
					end
				end
			end
		end
		local function RootBeam()
			if CDCheck(DrMasRoot) and LYMode ~= "PvE" and UnitChannelInfo("player") ~= DrConvSpirit then
				for i=1,#LYEnemies do
					if inRange(DrSolar,LYEnemies[i]) and HaveDebuff(LYEnemies[i],DrSolar,3,"player") and CheckUnitDR(LYEnemies[i],"root",1) and not HaveBuff(LYEnemies[i],listISlows) and not IsRooted(LYEnemies[i]) then
						LYSpellStopCasting()
						LYQueueSpell(DrMasRoot,LYEnemies[i])
						LY_Print(DrMasRoot.." @"..DrSolar,"green",DrMasRoot)
						return true
					end
				end
			end
		end
		local function NewMoon()
			if GCDCheck(DrBArt) and LYStyle ~= "Utilities only" and not IsMoving() then
				local tSpell = C_Spell.GetSpellInfo(DrBArt)
				if (tSpell.spellID == 1392545 and LYUP < 90) or (tSpell.spellID == 1392543 and LYUP < 80) or (tSpell.spellID == 1392542 and LYUP < 60) then
					for i=1,#LYEnemies do
						if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and inRange(DrBArt,LYEnemies[i]) and LYFacingCheck(LYEnemies[i]) then
							LYQueueSpell(DrBArt,LYEnemies[i])
							return true
						end
					end
				end
			end
		end
		local function ApplyDoTs()
			if #LYEnemyTotems > 0 then
				return
			end
			if (GCDCheck(DrMF) or GCDCheck(DrSF)) and LYStyle ~= "Utilities only" then
				if LYDoTUnits ~= 0 then
					local count = 0
					for i=1,#LYEnemies do
						if inRange(DrMF,LYEnemies[i]) and HaveAllDebuffs(LYEnemies[i],{DrMF,DrSF},5,"player") then
							count = count + 1
						end
					end
					if count >= LYDoTUnits then
						return
					end
				end
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and inRange(DrMF,LYEnemies[i]) then
						if GCDCheck(DrMF) and not HaveDebuff(LYEnemies[i],DrMF,6,"player") and (not IsTalentInUse(279620) or not BreakCCAroundUnit(LYEnemies[i],17)) then
							LYQueueSpell(DrMF,LYEnemies[i])
							return true
						elseif GCDCheck(DrSF) and not HaveDebuff(LYEnemies[i],DrSF,5,"player") and not BreakCCAroundUnit(LYEnemies[i],9) then
							LYQueueSpell(DrSF,LYEnemies[i])
							return true
						end
					end
				end
			end
		end
		if CommonKick(DrSolar,"magic","kick",not UnitChannelInfo("player")) or
		CommonKick(DrTyphoon,"magic","move",LYDrTyphKick and not UnitChannelInfo("player"),15) or
		CommonKick(DrDesor,"phys","alt",LYDrDesorKick and not UnitChannelInfo("player"),9) or
		CommonKick(DrBash,"phys","alt",LYDrBashKick,10) or
		RootBeam() or
		DrAntiHibr() or
		AntiReflect(DrSoothe) or
		PauseRotation or
		ConditionalSpell(DrRenewal,FriendIsUnderAttack("player") and CalculateHP("player") < LYDrRenew) or
		ConditionalSpell(DrStealth,LYDrStealth and not HaveBuff("player",{ArenaPrepBuff, HordeFlag, AlyFlag, DrStealth}) and GetTime()-LastStealth > 1 and not IsMounted() and (GetShapeshiftForm() == 0 or GetShapeshiftForm() == 2) and not UnitAffectingCombat("player") and not HaveDebuff("player",listDoTs)) or
		ConditionalSpell(DrNVigil,IsBursting()) or
		BRDeadFriend() or
		AntiStealth(DrMF) or
		LYDispelAlwaysF(DrDispelCurst) or
		DrHealMode() or
		TotemStomp(nil,{DrWrath,DrSFire,DrMF,DrSF},45) or
		BreakCCMG(DrRejuv,true) or
		Inner() or
		DefensiveOnEnemy(DrFSwarm,"MELEE","magic",LYDrFWarmHP,LYDrFWarmBurst,nil,LYMode ~= "PvE") or
		SolarRootSave() or
		DrSwiftMend() or
		CommonHeal(DrRejuv,((LYMode ~= "PvE" and LYZoneType ~= "pvp") or not UnitAffectingCombat("player")) and not EnemyHPBelow(30),LYDrRejuvHP,4) or
		CommonHeal(DrRegr,((LYMode ~= "PvE" and LYZoneType ~= "pvp") or not UnitAffectingCombat("player")) and not IsMoving() and not EnemyHPBelow(30),LYDrRegrHP) or
		Form() or
		FearCC(DrClone,"magic",LYDrCloneDR,LYDrCloneHealer,LYDrCloneHealerHP,LYDrCloneBurst,LYDrCloneDPS,LYDrCloneDPSHP,LYDrCloneDPSBurst,LYDrCloneCont,LYDrCloneFocus,true) or
		StunCC(DrBash,"phys",LYDrBashDR,LYDrBashHealer,LYDrBashHealerHP,LYDrBashBurst,LYDrBashDPS,LYDrBashDPSHP,LYDrBashDPSBurst,LYDrBashChain,LYDrBashFocus,10) or
		BeamCC() or
		ShiftRoot() or
		DefensiveOnTeam(DrThorns,"MELEE",LYDrThornsHP,LYDrThornsBurst,nil,LYMode ~= "PvE") or
		PurgeEnrage(DrSoothe,true) or
		DefensiveOnEnemy(DrVortex,"MELEE","magic",LYDrVortexHP,LYDrVortexBurst,30,LYMode ~= "PvE" and IsMoving()) or
		AOEAttack(DrWildMush,10,DrMF,3,true) or
		ApplyDoTs() or
		CommonAttack(DrStelFlare,"magic",true,DrStelFlare,not IsMoving(),7,DrStelFlare) or
		Burst() or
		ConditionalSpell(DrSFall,GCDCheck(DrSFall) and ((not DoNotUsePower and EnemiesAroundUnit(DrMF) >= LYDrSFallCount and (not IsTalentInUse(202345) or HaveBuff("player",DrStarlord) or LYUP > 90)) or HaveBuff("player",DrOneth))) or
		CommonAttack(DrSSurge,"magic",true,DrSSurge,GCDCheck(DrSSurge) and ((not DoNotUsePower and EnemiesAroundUnit(DrMF) < LYDrSFallCount and (not IsTalentInUse(202345) or HaveBuff("player",DrStarlord) or LYUP > 90)) or HaveBuff("player",DrOneth2))) or
		CommonAttack(DrSFire,"magic",true,DrSFire,HaveBuff("player",{DrEmpowered,DrEluneWar})) or
		NewMoon() or
		CommonAttackTarget(DrWildMush,"magic",true,GCDCheck(DrWildMush) and inRange(DrMF,LYEnemyTarget) and SpellChargesCheck(DrWildMush)) or
		CommonAttack(DrWrath,"magic",true,DrMF,not IsMoving() and ((HaveBuff("player",DrSEclipse) and (not HaveBuff("player",DrIncElune) or EnemiesAroundUnit(8,LYEnemyTarget) < 3)) or not GCDCheck(DrSFire))) or
		AOEAttack(DrSFire,10,DrMF,2,not IsMoving() and (HaveBuff("player",DrLEclipse) or not GCDCheck(DrWrath))) or
		CommonAttack(DrSFire,"magic",true,DrMF,not IsMoving() and (HaveBuff("player",DrLEclipse) or not GCDCheck(DrWrath))) or
		CommonAttack(DrWrath,"magic",true,DrMF,not IsMoving() and LYMode ~= "PvP",nil,nil,3) or
		CommonAttack(DrSFire,"magic",true,DrMF,not IsMoving()) or
		AOEHeal(DrWGrowth,30,80,3,(LYZoneType == "arena" or not UnitAffectingCombat("player")) and not IsMoving()) or
		LYDispelAllF(DrDispelCurst) or
		UpdateDoTs(DrMF) or
		AutoBuffParty(DrMarkWild) then
			return true
		end
	end
	function LYDruidFeral()
		local rdpsTotem = {}
		if IsTalentInUse(155580) then
			rdpsTotem = {DrMF}
		end
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",DrShred) then
				if GCDCheck(DrBers) then
					LYQueueSpell(DrBers)
					LY_Print(DrBers,"green",DrBers)
					return true
				end
				if GCDCheck(DrConvSpirit) then
					StopMoving()
					LYQueueSpell(DrConvSpirit)
					LY_Print(DrConvSpirit,"green",DrConvSpirit)
					return true
				end
			end
		end
		local function Form()
			if GCDCheck(DrCat) and LYStyle ~= "Utilities only" then
				if LYMode ~= "PvE" and ((FriendIsUnderAttack("player","MELEE",LYDrBearHP,LYDrBearBurst) and (not LYDrBearHealer or not TeamHealerCanInteract())) or LYStayForm) and not HaveBuff("player",{DrBers,DrIncJungle}) then
					if GetShapeshiftForm() ~= 1 then
						LYQueueSpell(DrBear)
						return true
					end
				elseif (GetShapeshiftForm() == 0 or GetShapeshiftForm() == 1) and not LYStayForm and GetShapeshiftForm() ~= 2 and not HaveBuff("player",{DrRegen,ArenaPrepBuff}) and (LYLastSpellName ~= DrClone or not IsPvPTalentInUse(5593)) then
					LYQueueSpell(DrCat)
					return true
				end
			end
		end
		local function StampedPvP()
			if GCDCheck(DrStamped) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and IsPvPTalentInUse(203) then
				for i=1,#LYTeamHealers do
					if IsInDistance(LYTeamHealers[i],15) and ((IsRooted(LYTeamHealers[i],2) and HaveDebuff(LYTeamHealers[i],DrSolar)) or (CalculateHP(LYTeamHealers[i]) < LYDrFreedomHealHP and HaveDebuff(LYTeamHealers[i],listSlows) and FriendIsUnderAttack(LYTeamHealers[i]) and IsMoving(LYTeamHealers[i]))) then
						LYQueueSpell(DrStamped)
						LY_Print(DrStamped.." @team healer","green",DrStamped)
						return true
					end
				end
				if LYDrFreedomSlow then
					for i=1,#LYTeamPlayers do
						if CheckRole(LYTeamPlayers[i]) == "MELEE" and IsInDistance(LYTeamPlayers[i],15) and select(2,UnitClass(LYTeamPlayers[i])) ~= "DRUID" then
							local target = UnitTarget(LYTeamPlayers[i])
							if UnitIsVisible(target) and UnitCanAttack(LYTeamPlayers[i],target) and ((CalculateHP(target) < LYDrFreedomTarHP and HaveDebuff(LYTeamPlayers[i],listSlows) and not IsInDistance(LYTeamPlayers[i],7,target)) or HaveDebuff(LYTeamPlayers[i],listDispelRoots,LYDrFreedomRoot)) then
								LYQueueSpell(DrStamped)
								LY_Print(DrStamped.." @DPS teammate","green")
								return true
							end
						end
					end
				end
			end
		end
		local function RegrowthInstant(prio)
			if GCDCheck(DrRegr) and LYStyle ~= "Utilities only" and HaveBuff("player",DrPredatory) then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 90 and (not LYDPSSelfHeal or UnitIsUnit("player",LYTeamPlayers[i])) and (not prio or (LYMode ~= "PvE" and CalculateHP(LYTeamPlayers[i]) < 50)) then
						LYQueueSpell(DrRegr,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function RakeStun()
			if GetShapeshiftForm() == 2 and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and GCDCheck(DrStealth) and GCDCheck(DrRake) and HaveBuff("player",{DrIncJungle,DrSudAmbush}) and SpellAttackTypeCheck(LYEnemyTarget,"phys") and inRange(DrShred,LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and CheckUnitDR(LYEnemyTarget,"stun") and not UnitIsKicked(LYEnemyTarget) and not UnitIsCCed(LYEnemyTarget) and LYFacingCheck(LYEnemyTarget) then
				StopAttack()
				CastSpellByName(DrStealth)
				LY_ForceCast("[@"..LYEnemyTarget.."] "..DrRake)
				LY_Print(DrRake.." stun","green",DrRake)
				return true
			end
		end
		local function MaimCC()
			local function UnitIsCCable(pointer)
				if SpellAttackTypeCheck(pointer,"phys") and inRange(DrMaim,pointer) and CheckUnitDR(pointer,"stun",LYDrMaimDR) and not HaveBuff(pointer,{WrBS,PrHolyWard}) and not UnitIsKicked(pointer) and not UnitIsCCed(pointer,LYGCDTime) then
					return true
				end
			end
			if GetShapeshiftForm() == 2 and LYMode ~= "PvE" and GCDCheck(DrMaim) and LYCP > 4 and LYDrMaimHealer and (EnemyHPBelow(LYDrMaimHealerHP) or (LYDrMaimTeamBurst and TeamIsBursting())) then
				for i=1,#LYEnemyHealers do
					if UnitIsCCable(LYEnemyHealers[i]) and LYFacingCheck(LYEnemyHealers[i]) then
						LYQueueSpell(DrMaim,LYEnemyHealers[i])
						LY_Print(DrMaim.." @enemy healer","green",DrMaim)
						return true
					end
				end
			end
		end
		local function Root()
			if GCDCheck(DrRoots) and LYMode ~= "PvE" and HaveBuff("player",DrPredatory) then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and inRange(DrRoots,LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic")	and ((UnitIsVisible(LYEnemyTarget) and not UnitIsUnit(LYEnemyTarget,LYEnemies[i]) and CheckRole(LYEnemies[i]) == "MELEE") or (CalculateHP(LYEnemyTarget) < 35 and not IsInDistance(LYEnemyTarget,10))) and not HaveBuff(LYEnemies[i],listIRoot) and CheckUnitDR(LYEnemies[i],"root",1) and not UnitIsCCed(LYEnemies[i],LYGCDTime) and not IsRooted(LYEnemies[i],LYGCDTime) then
						LYQueueSpell(DrRoots,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function LowUnits()
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and inRange(DrFBite,LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"phys") and CalculateHP(LYEnemies[i]) < LYDrFBite and LYFacingCheck(LYEnemies[i]) then
					return true
				end
			end
		end
		local function ShiftSlow(rootOnly)
			if LYMode ~= "PvE" and (IsRooted() or (not rootOnly and IsMoving() and HaveDebuff("player",listShiftSlow))) and ((LYEnemyTarget and UnitIsVisible(LYEnemyTarget) and not inRange(DrShred, LYEnemyTarget)) or not LYEnemyTarget and EnemiesAroundUnit(8) <= 0) then
				if DrSwiftMend() or CommonHeal(DrRejuv,true,100,4) or ConditionalSpell(DrBear,true) then
					LY_Print("Shifted for slow/root","red")
					return true
				end
			end
		end
		local function ShouldPWrath()
			local enemiesAroundDoted = EnemiesAroundUnitDoTed(8,nil,DrRip,nil,4)
			local enemiesAround = EnemiesAroundUnit(8, "player")
			if ((not LYDrFBiteBurst or not IsBursting()) and not (CalculateHP(LYEnemyTarget) < LYDrFBite)) and enemiesAround >= 3 then
				return true
			end
			if not (enemiesAround > 1 and enemiesAround > enemiesAroundDoted) then
				return
			end
			if enemiesAround >= 3 or not HaveDebuff(LYEnemyTarget, DrRip, 4) then
				return true
			end
			return ((not LYDrFBiteBurst or not IsBursting()) and not (CalculateHP(LYEnemyTarget) < LYDrFBite))
		end
		local function CPLessThanMax()
			return LYCP < 5 and LYLastSpellName ~= DrFeralFrenzy
		end
		if DrAntiHibr() or
		PauseRotation or
		ConditionalSpell(DrStealth,LYDrStealth and not HaveBuff("player",{ArenaPrepBuff,HordeFlag,AlyFlag,DrStealth}) and GetTime()-LastStealth > 1 and not IsMounted() and (GetShapeshiftForm() == 0 or GetShapeshiftForm() == 2) and not UnitAffectingCombat("player") and not HaveDebuff("player",listDoTs)) or
		ConditionalSpell(DrRenewal,FriendIsUnderAttack("player") and CalculateHP("player") < LYDrRenew) or
		DefensiveOnPlayer(DrSurvInst,nil,LYDrSurvHP,LYDrSurvBurst,LYDrSurvHealer,not HaveBuff("player",{DrIronfur,DrRegen})) or
		ConditionalSpell(DrNVigil,IsBursting()) or
		BRDeadFriend() or
		LYDispelAlwaysF(DrDispelCurst) or
		DrKickPlayers() or
		CommonKick(DrTyphoon,"magic","move",LYDrTyphKick,15) or
		CommonKick(DrDesor,"phys","alt",LYDrDesorKick,9) or
		CommonKick(DrBash,"phys","alt",LYDrBashKick,5) or
		CommonKick(DrMaim,"phys","alt",LYMode ~= "PvE" and GetShapeshiftForm() == 2 and LYDrMaimKick) or
		BreakCCMG(DrRejuv,true) or
		AntiReflect(DrSoothe) or
		DrHealMode() or
		TotemStomp({DrShred},rdpsTotem,30) or
		StunCC(DrBash,"phys",LYDrBashDR,LYDrBashHealer,LYDrBashHealerHP,LYDrBashBurst,LYDrBashDPS,LYDrBashDPSHP,LYDrBashDPSBurst,LYDrBashChain,LYDrBashFocus,5) or
		MaimCC() or
		FearCC(DrDesor,"magic",LYDrDesorDR,LYDrDesorHealer,LYDrDesorHealerHP,LYDrDesorBurst,LYDrDesorDPS,LYDrDesorDPSHP,LYDrDesorDPSBurst,LYDrDesorChain,LYDrDesorFocus,nil,9) or
		StampedPvP() or
		DefensiveOnEnemy(DrMaim,nil,"phys",LYDrMaimDPSHP,LYDrMaimDPSBurst,nil,LYMode ~= "PvE" and LYDrMaimDPS and GetShapeshiftForm() == 2 and (LYCP > 4 or IsPvPTalentInUse(604))) or
		DefensiveOnTeam(DrThorns,"MELEE",LYDrThornsHP,LYDrThornsBurst,nil,LYMode ~= "PvE") or
		RakeStun() or
		RegrowthInstant(true) or
		DrSwiftMend() or
		CommonHeal(DrRejuv,((LYMode ~= "PvE" and LYZoneType ~= "pvp") or not UnitAffectingCombat("player")),LYDrRejuvHP,4) or
		Form() or
		DrBearAction() or
		CommonHeal(DrRegr,((LYMode ~= "PvE" and LYZoneType ~= "pvp") or not UnitAffectingCombat("player")) and not IsMoving() and GetShapeshiftForm() ~= 1,LYDrRegrHP) or
		GetShapeshiftForm() ~= 2 or
		ConditionalSpell(DrTF,GCDCheck(DrTF) and UnitIsVisible(LYEnemyTarget) and inRange(DrShred,LYEnemyTarget) and not HaveBuff("player",DrTF) and ((LYUP <= LYUPMax - 50 and LYCP > 3) or (LYMode ~= "PvP") or (LYCP > 3 and LYDrTFAggressive and IsBursting() and not IsSpellKnown(391888)))) or
		DrQueueStun() or
		Burst() or
		CommonAttack(DrFBite,"phys",true,DrFBite,GCDCheck(DrFBite) and HaveBuff("player",DrAttunement)) or
		CommonAttackTarget(DrFeralFrenzy,"phys",true,LYCP < 2 and inRange(DrMangle,LYEnemyTarget) and HaveBuff("player",DrTF) and not HaveBuff("player",DrAttunement)) or
		ConditionalSpell(DrThrash,LYMode ~= "PvP" and GCDCheck(DrThrash) and CPLessThanMax() and EnemiesAroundUnit(8,"player",DrThrash) > 4) or
		CommonAttack(DrRake,"phys",true,DrShred,CPLessThanMax() and not HaveBuff("player",DrSudAmbush),5,155722) or
		ConditionalSpell(DrThrash,CPLessThanMax() and GCDCheck(DrThrash) and EnemiesAroundUnitDoTed(8,nil,{DrThrash}) < EnemiesAroundUnit(8)) or
		ConditionalSpell(DrSwipe,LYMode ~= "PvP" and CPLessThanMax() and GCDCheck(DrSwipe) and EnemiesAroundUnitDoTed(8,nil,{DrRip,DrRake,DrThrash}) > 2) or
		ConditionalSpell(DrPrimWrath,LYCP > 4 and not UnitIsVisible(LYNextStun) and GCDCheck(DrPrimWrath) and ShouldPWrath()) or
		CommonAttack(DrRip,"phys",true,DrShred,not DoNotUsePower and GCDCheck(DrRip) and not AllEnemyHealCCed() and not UnitIsVisible(LYNextStun) and LYCP > 4 and not LowUnits() and(not LYDrFBiteBurst or not IsBursting() or not HaveDebuff(LYEnemyTarget, DrRip, 7)),7, DrRip) or
		CommonAttackTarget(DrMaim,"phys",true,not DoNotUsePower and LYCP > 4 and inRange(DrMaim,LYEnemyTarget) and not UnitIsVisible(LYNextStun) and HaveBuff("player",DrIronJaws) and CheckUnitDR(LYEnemyTarget,"stun")) or
		CommonAttack(DrFBite,"phys",true,DrFBite,not DoNotUsePower and not UnitIsVisible(LYNextStun) and ((LYCP > 4 and (LYUP > 49 or (HaveBuff("player",DrIncJungle) and LYUP > 39))) or HaveBuff("player",DrApexPred))) or
		CommonAttack(DrBrSlash,"phys",true,DrShred,CPLessThanMax() and not BreakCCAroundUnit("player",8)) or
		CommonAttack(DrMF,"magic",nil,DrSoothe,LYUP > 35 and IsTalentInUse(155580) and CPLessThanMax(),4,DrMF) or
		CommonAttack(DrShred,"phys",true,DrShred,GCDCheck(DrShred) and ((CPLessThanMax()) or BuffTimeLeft("player",DrClearCast) < LYGCDTime or LYUP > LYUPMax - 5)) or
		CommonAttack(DrMF,"magic",nil,DrSoothe,IsTalentInUse(155580) and GCDCheck(DrMF) and ((CPLessThanMax() and LYUP > 75) or LYUP > LYUPMax - 5)) or
		ShiftSlow(true) or
		Root() or
		RegrowthInstant() or
		PurgeEnrage(DrSoothe,true) or
		LYDispelAllF(DrDispelCurst) or
		DefensiveOnEnemy(DrVortex,"MELEE","magic",LYDrVortexHP,LYDrVortexBurst,30,LYMode ~= "PvE" and IsMoving()) or
		ShiftSlow()	or
		FearCC(DrClone,"magic",LYDrCloneDR,LYDrCloneHealer,LYDrCloneHealerHP,LYDrCloneBurst,LYDrCloneDPS,LYDrCloneDPSHP,LYDrCloneDPSBurst,LYDrCloneCont,LYDrCloneFocus,true) or
		AutoBuffParty(DrMarkWild) then
			return true
		end
	end
	function LYDruidGuard()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",DrMangle) then
				if GCDCheck(DrBers) then
					LYQueueSpell(DrBers)
					LY_Print(DrBers,"green")
					return true
				end
				if GCDCheck(DrIncUrsoc) then
					LYQueueSpell(DrIncUrsoc)
					LY_Print(DrIncUrsoc,"green")
					return true
				end
				if GCDCheck(DrGArt) then
					LYQueueSpell(DrGArt)
					LY_Print(DrGArt,"green")
					return true
				end
			end
		end
		local function Root()
			if GCDCheck(DrRoots) and LYMode ~= "PvE" and IsPvPTalentInUse(195) then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and inRange(DrRoots,LYEnemies[i]) and CheckRole(LYEnemies[i]) == "MELEE" and (not UnitIsVisible(LYEnemyTarget) or not UnitIsUnit(LYEnemyTarget,LYEnemies[i])) and not HaveBuff(LYEnemies[i],listIRoot) and CheckUnitDR(LYEnemies[i],"root",1) and not EnemyIsUnderAttack(LYEnemies[i]) then
						LYQueueSpell(DrRoots,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function StampedPvP()
			if GCDCheck(DrStamped) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and LYDrFreedomSlow then
				for i=1,#LYTeamPlayers do
					if IsInDistance(LYTeamPlayers[i],15) and select(2,UnitClass(LYTeamPlayers[i])) ~= "DRUID" and CheckRole(LYTeamPlayers[i]) == "MELEE" and HaveDebuff(LYTeamPlayers[i],listShiftSlow,3) then
						local target = UnitTarget(LYTeamPlayers[i])
						if UnitIsVisible(target) and UnitCanAttack(LYTeamPlayers[i],target) and not IsInDistance(LYTeamPlayers[i],7,target) and CalculateHP(target) < LYDrFreedomTarHP then
							LYQueueSpell(DrStamped)
							return true
						end
					end
				end
			end
		end
		local function ShiftSnare()
			if GCDCheck(DrBear) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and IsRooted() and not IsInDistance(LYEnemyTarget,LYDrBearRoot) and not HaveBuff("player",listFlags) then
				if GetShapeshiftForm() == 0 or GetShapeshiftForm() == 1 then
					LYQueueSpell(DrBear)
					return true
				elseif GetShapeshiftForm() == 2 then
					LYQueueSpell(DrCat)
					return true
				elseif HaveBuff("player",DrOwl) then
					LYQueueSpell(DrOwl)
					return true
				end
			end
		end
		local function Pulver()
			if GCDCheck(DrPulver) and LYStyle ~= "Utilities only" then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"phys") and inRange(DrPulver,LYEnemies[i]) and DebuffCount(LYEnemies[i],DrThrash) == 2 and LYFacingCheck(LYEnemies[i]) then
						LYQueueSpell(DrPulver,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function MangleOrThrash()
			if LYMode ~= "PvP" then
				if CommonAttack(DrThrash,"phys",true,DrMangle,EnemiesAroundUnitDoTed(DrMangle,"player",DrThrash,nil,nil,3) ~= EnemiesAroundUnit(8)) or CommonAttack(DrMangle,"phys",true,DrMangle,not (HaveBuff("player",DrIncUrsoc) and (HaveBuff("player",DrToothAndClaw) or EnemiesAroundUnit(8) > 3)) and LYUP <= LYUPMax - 10) then
					return true
				end
			elseif CommonAttack(DrMangle,"phys",true,DrMangle,not (HaveBuff("player",DrIncUrsoc) and HaveDebuff(LYEnemyTarget,DrInfectedWound) and (LYUP > 40 or GCDCheck(DrMaul)))) or CommonAttack(DrThrash,"phys",true,DrMangle,EnemiesAroundUnitDoTed(DrMangle,"player",DrThrash,nil,nil,3) ~= EnemiesAroundUnit(8) and not (HaveBuff("player",DrIncUrsoc) and (LYUP > 40 or GCDCheck(DrMaul)))) then
				return true
			end
		end
		local function RazeMaul()
			if GCDCheck(DrMaul) and LYStyle ~= "Utilities only" and (not FriendIsUnderAttack("player") or LYUP > 54 or HaveBuff("player",DrToothAndClaw) or IsBursting()) then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"phys") and inRange(DrMangle,LYEnemies[i]) and LYFacingCheck(LYEnemies[i]) then
						if GCDCheck(DrRaze) and EnemiesAroundUnit(8,LYEnemies[i]) > 1 then
							LYQueueSpell(DrRaze,LYEnemies[i])
							return true
						else
							LYQueueSpell(DrMaul,LYEnemies[i])
							return true
						end
					end
				end
			end
		end
		if DrAntiHibr() or
		PauseRotation or
		ConditionalSpell(DrStealth,LYDrStealth and not HaveBuff("player",{ArenaPrepBuff, HordeFlag, AlyFlag, DrStealth}) and GetTime()-LastStealth > 1 and not IsMounted() and (GetShapeshiftForm() == 0 or GetShapeshiftForm() == 2) and not UnitAffectingCombat("player") and not HaveDebuff("player",listDoTs)) or
		DefensiveOnPlayer(DrSurvInst,nil,LYDrSurvHP,LYDrSurvBurst,LYDrSurvHealer,true) or
		ConditionalSpell(DrIronfur,GCDCheck(DrIronfur) and (not HaveBuff("player",DrIronfur,1) or LYUP == LYUPMax) and FriendIsUnderAttack("player")) or
		ConditionalSpell(DrRenewal,GCDCheck(DrRenewal) and FriendIsUnderAttack("player") and CalculateHP("player") < LYDrRenew) or
		TauntPvP(DrTaunt,842) or
		Taunt(DrTaunt) or
		ConditionalSpell(DrNVigil,TeamMembersAroundUnit(nil,"player",80) > 2) or
		BRDeadFriend() or
		AntiStealth(DrMF) or
		LYDispelAlwaysF(DrDispelCurst) or
		CommonKick(DrKick,"phys","kick",GetShapeshiftForm() == 1 and not IsRooted()) or
		CommonKick(DrTyphoon,"magic","move",LYDrTyphKick,15) or
		CommonKick(DrDesor,"phys","alt",LYDrDesorKick,9) or
		CommonKick(DrOverrun,"phys","alt",LYMode ~= "PvE" and GetShapeshiftForm() == 1 and LYDrOverrunKick and not IsRooted()) or
		CommonKick(DrBash,"phys","alt",LYDrBashKick,5) or
		DrHealMode() or
		TotemStomp({DrMangle,DrMaul},{DrMF},40) or
		StampedPvP() or
		ShiftSnare() or
		StunCC(DrBash,"phys",LYDrBashDR,LYDrBashHealer,LYDrBashHealerHP,LYDrBashBurst,LYDrBashDPS,LYDrBashDPSHP,LYDrBashDPSBurst,LYDrBashChain,LYDrBashFocus,5) or
		Root() or
		DefensiveOnTeam(DrDemoRoar,"MELEE",LYDrDemRoarHP,LYDrDemRoarBurst,10,LYMode ~= "PvE") or
		DrSwiftMend() or
		CommonHeal(DrRejuv,((LYMode ~= "PvE" and LYZoneType ~= "pvp") or not UnitAffectingCombat("player")),LYDrRejuvHP,4) or
		CommonHeal(DrRegr,((LYMode ~= "PvE" and LYZoneType ~= "pvp") or not UnitAffectingCombat("player")) and not IsMoving(),LYDrRegrHP) or
		ConditionalSpell(DrBear,GetShapeshiftForm() ~= 3 and GetShapeshiftForm() ~= 1 and not LYStayForm) or
		ConditionalSpell(DrRegen,CalculateHP("player") < 75 and not HaveBuff("player",DrRegen) and (not IsPvPTalentInUse(192) or LYUP < 50)) or
		PurgeEnrage(DrSoothe,true) or
		DefensiveOnEnemy(DrVortex,"MELEE","magic",LYDrVortexHP,LYDrVortexBurst,30,LYMode ~= "PvE" and IsMoving()) or
		Burst() or
		CommonAttack(DrThrash,"phys",true,DrMangle,true,nil,nil,2) or
		Pulver() or
		CommonAttack(DrConvSpirit,"phys",true,DrMangle,not IsMoving(),nil,nil,3) or
		MangleOrThrash() or
		ConditionalSpell(DrBristFlur,LYUP < 20 and GCDCheck(DrBristFlur) and FriendIsUnderAttack("player")) or
		CommonHeal(DrRegr,HaveBuff("player",DrDreamCen),90) or
		CommonAttack(DrMF,"magic",true,DrMF,LYUP < LYUPMax and (not IsTalentInUse(372567) or not BreakCCAroundUnit()),4,DrMF) or
		RazeMaul() or
		CommonHeal(DrRejuv,true,LYDrRejuvHP,4) or
		FearCC(DrClone,"magic",LYDrCloneDR,LYDrCloneHealer,LYDrCloneHealerHP,LYDrCloneBurst,LYDrCloneDPS,LYDrCloneDPSHP,LYDrCloneDPSBurst,LYDrCloneCont,LYDrCloneFocus,true) or
		LYDispelAllF(DrDispelCurst) or
		CommonAttack(DrSwipe,"phys",true,DrMangle,true) or
		AutoBuffParty(DrMarkWild) then
			return true
		end
	end
	function LYDruidRestor()
		local function ShiftCC()
			if LYMode ~= "PvE" and not HaveBuff("player",DrIncTree) and CheckUnitDR("player","control",2) then
				for i=1,#LYEnemies do
					if inRange(DrMF,LYEnemies[i]) then
						local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
						if castName and tContains(listShiftCC,castName) and PlayerIsSpellTarget(LYEnemies[i]) then
							local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
							local castTime = (castEndTime - castStartTime)
							local currentPercent = timeSinceStart / castTime * 100
							if currentPercent > 40 then
								if GetShapeshiftForm() == 0 then
									LYSpellStopCasting()
									LYQueueSpell(DrBear)
									LY_Print(DrBear.." "..castName,"green",DrBear)
								end
								return true
							end
						end
					end
				end
			end
		end
		local function FlourCC()
			if LYMode ~= "PvE" and CDCheck(DrFlour) and UnitIsVisible(LYTeamPlayers[1]) and not UnitIsUnit(LYTeamPlayers[1],"player") and CalculateHP(LYTeamPlayers[1]) < LYDrFlourCCHP and HaveAllBuffs(LYTeamPlayers[1],listRDruHoTs,1) then
				for i=1,#LYEnemies do
					if inRange(DrMF,LYEnemies[i]) then
						local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
						if castName and CheckUnitDRSpell("player",castName) and PlayerIsSpellTarget(LYEnemies[i]) then
							local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
							local castTime = (castEndTime - castStartTime)
							local currentPercent = timeSinceStart / castTime * 100
							if currentPercent > 70 then
								LYSpellStopCasting()
								LYQueueSpell(DrFlour)
								LY_Print(DrFlour.." "..castName,"green",DrFlour)
								return true
							end
						end
					end
				end
			end
		end
		local function IBCC()
			if LYMode ~= "PvE" and CDCheck(DrIBark) and ValidFriendUnit(LYTeamPlayers[1]) and not UnitIsUnit(LYTeamPlayers[1],"player") and CalculateHP(LYTeamPlayers[1]) < LYDrIrBarkCCHP then
				for i=1,#LYEnemies do
					if inRange(DrMF,LYEnemies[i]) then
						local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
						if castName and CheckUnitDRSpell("player",castName) and PlayerIsSpellTarget(LYEnemies[i]) then
							local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
							local castTime = (castEndTime - castStartTime)
							local currentPercent = timeSinceStart / castTime * 100
							if currentPercent > 80 then
								LYSpellStopCasting()
								LYQueueSpell(DrIBark)
								LY_Print(DrIBark.." "..castName,"green",DrIBark)
								return true
							end
						end
					end
				end
			end
		end
		local function RootTree()
			if GCDCheck(DrRoots) and LYMode ~= "PvE" and HaveBuff("player",DrIncTreeForm) then
				for i=1,#LYEnemies do
					if inRange(DrRoots,LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and CheckRole(LYEnemies[i]) == "MELEE" and CheckUnitDR(LYEnemies[i],"root",1) and not HaveBuff(LYEnemies[i],listIRoot) and not UnitIsCCed(LYEnemies[i]) and not IsRooted(LYEnemies[i]) then
						LYQueueSpell(DrRoots,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function BearDef()
			if LYStyle ~= "Utilities only" and not HaveBuff("player",DrIncTree) then
				if LYMode ~= "PvE" and FriendIsUnderAttack("player") and HaveAllBuffs("player",listRDruHoTs,3) then
					if GCDCheck(DrBear) and GetShapeshiftForm() ~= 1 then
						LYQueueSpell(DrBear)
					end
					return true
				elseif GetShapeshiftForm() ~= 0 and not LYStayForm and not LYHDPS then
					CancelShapeshiftForm()
				end
			end
		end
		local function PreHot()
			if not IsStealthed() and not GCDCheck(DrRejuv) and LYZoneType == "arena" and not UnitAffectingCombat("player") and CalculateMP("player") > 95 and not HaveBuff("player",ArenaPrepBuff) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and (not HaveBuff(LYTeamPlayers[i],DrRejuv,4,"player") or (IsTalentInUse(155675) and not HaveBuff(LYTeamPlayers[i],DrGerm,4,"player"))) then
						LYQueueSpell(DrRejuv,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function Inner()
			if GCDCheck(DrInner) and LYStyle ~= "Utilities only" and UnitAffectingCombat("player") and ((C_Spell.IsSpellUsable(DrRegr) and not IsMoving()) or HaveBuff("player",DrIncTree) or (LYMode ~= "PvP" and CalculateMP("player") < 80 and PartyHPBelow(50))) then
				CastSpellByName(DrInner,"player")
				LY_Print(DrInner,"green")
				return true
			end
		end
		local function Overgrowth()
			if GCDCheck(DrOvergrowth) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],listRDruHoTs) and CalculateHP(LYTeamPlayers[i]) < LYDrOvergrHP then
						LYQueueSpell(DrOvergrowth,LYTeamPlayers[i])
						LY_Print(DrOvergrowth,"green")
						return true
					end
				end
			end
		end
		local function FlourHeal()
			if GCDCheck(DrFlour) and LYStyle ~= "Utilities only" and (PlayerOutOfCC() or LYMode == "PvE") then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < LYDrFlourHP and HaveAllBuffs(LYTeamPlayers[i],listRDruHoTs,1) and FriendIsUnderAttack(LYTeamPlayers[i]) then
						LYQueueSpell(DrFlour)
						LY_Print(DrFlour,"green")
						return true
					end
				end
			end
		end
		local function LBloom()
			if GCDCheck(DrLBloom) and LYStyle ~= "Utilities only" then
				if IsTalentInUse(274902) and UnitAffectingCombat("player") then
					if not HaveBuff("player",DrLBloom,4,"player") then
						LYQueueSpell(DrLBloom,"player")
						return true
					elseif not IsTalentInUse(392301) then
						return
					end
				end
				if IsTalentInUse(392301) then
					if LYMode == "PvE" then
						for i=1,#LYTeamPlayers do
							if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 95 and not HaveBuff(LYTeamPlayers[i],DrLBloom,4,"player") and UnitIsTank(LYTeamPlayers[i]) and UnitAffectingCombat(LYTeamPlayers[i]) then
								LYQueueSpell(DrLBloom,LYTeamPlayers[i])
								return true
							end
						end
					else
						local t
						for i=1,#LYTeamPlayers do
							if ValidFriendUnit(LYTeamPlayers[i]) and HaveBuff(LYTeamPlayers[i],DrLBloom,5,"player") and (not IsTalentInUse(274902) or not UnitIsUnit("player",LYTeamPlayers[i])) then
								t = LYTeamPlayers[i]
							end
						end
						for i=1,#LYTeamPlayers do
							if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 95 and not HaveBuff(LYTeamPlayers[i],DrLBloom,5,"player") and FriendIsUnderAttack(LYTeamPlayers[i]) and (not t or CalculateHP(LYTeamPlayers[i]) + 15 < CalculateHP(t)) then
								LYQueueSpell(DrLBloom,LYTeamPlayers[i])
								return true
							end
						end
					end
				else
					local LBUnit = AnyFriendHasBuff(DrLBloom,5)
					for i=1,#LYTeamPlayers do
						if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 95 and not HaveBuff(LYTeamPlayers[i],DrLBloom,5,"player") and (LYMode ~= "PvE" or UnitIsTank(LYTeamPlayers[i])) and (not UnitIsVisible(LBUnit) or (CalculateHP(LYTeamPlayers[i]) + 15 < CalculateHP(LBUnit))) then
							LYQueueSpell(DrLBloom,LYTeamPlayers[i])
							return true
						end
					end
				end
			end
		end
		local function LBloomPvP()
			if GCDCheck(DrLBloom) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and IsPvPTalentInUse(835) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and HaveBuff(LYTeamPlayers[i],DrLBloom,1,"player") and BuffCount(LYTeamPlayers[i],DrFocusGrowth) < 3 then
						LYQueueSpell(DrLBloom,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function Germ()
			if GCDCheck(DrRejuv) and LYStyle ~= "Utilities only" and IsTalentInUse(155675) and (not HaveBuff("player",DrSoulOfForest) or IsMoving()) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 80 and CanHoTSafe(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],DrGerm,5,"player") and (LYMode ~= "PvE" or UnitIsTank(LYTeamPlayers[i])) then
						LYQueueSpell(DrRejuv,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function EfflorPvP()
			if GCDCheck(DrMush) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and not HaveBuff("player",DrMush) and IsPvPTalentInUse(59) and LYDrEflorSlowHP ~= 0 then
				for i=1,#LYTeamPlayers do
					local target = UnitTarget(LYTeamPlayers[i])
					if ValidFriendUnit(LYTeamPlayers[i]) and select(2,UnitClass(LYTeamPlayers[i])) ~= "DRUID" and (HaveDebuff(LYTeamPlayers[i],listShiftSlow,3) or IsRooted(LYTeamPlayers[i],2)) and UnitIsVisible(target) and UnitCanAttack(LYTeamPlayers[i],target) and ((CheckRole(LYTeamPlayers[i]) == "MELEE" and not IsInDistance(LYTeamPlayers[i],6,target)) or (CheckRole(LYTeamPlayers[i]) == "RDPS" and not InLineOfSight(LYTeamPlayers[i],target))) and CalculateHP(target) < LYDrEflorSlowHP then
						LYQueueSpell(DrMush,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function DPSMode()
			if LYHDPS then
				if IsTalentInUse(197625) then
					if GCDCheck(DrOwl) and not HaveBuff("player",DrOwl) then
						LYSpellStopCasting()
						LYQueueSpell(DrOwl)
						return true
					end
				elseif GetShapeshiftForm() ~= 2 and EnemiesAroundUnit(10) > 0 then
					LYSpellStopCasting()
					LYQueueSpell(DrCat)
					return true
				end
				if DrCatAction() or
				DrOwlAction()
				then
					return true
				end
			end
		end
		local function Invigor()
			if GCDCheck(DrInvigor) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 70 and HaveAllBuffs(LYTeamPlayers[i],{DrRejuv,DrLBloom}) then
						LYQueueSpell(DrInvigor,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function Nourish()
			if GCDCheck(DrNourish) and LYStyle ~= "Utilities only" then
				for i=1, #LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 80 then
						if IsTalentInUse(400531) then
							if HaveBuff(LYTeamPlayers[i],listRDruHoTs,0,"player") then
								LYQueueSpell(DrNourish,LYTeamPlayers[i])
								return true
							end
						elseif IsTalentInUse(400533)  then
							if (BuffCount("player", 400534) >= 3 or CalculateHP(LYTeamPlayers[i]) < 50) then
								LYQueueSpell(DrNourish,LYTeamPlayers[i])
								return true
							end
						else
							LYQueueSpell(DrNourish,LYTeamPlayers[i])
							return true
						end
					end
				end
			end
		end
		local function Tranq()
			if GCDCheck(DrTranq) and not IsMoving() and (not EnemyCanKick() or IsPvPTalentInUse(5387)) and (TeamMembersAroundUnit(nil,"player",50) >= LYDrTranqCount or PartyHPBelow(LYDrTranqHP)) then
				StopMoving(true)
				LYQueueSpell(DrTranq)
				return true
			end
		end
		if LYDispel(DrDispel) or
		DrAntiHibr() or
		ShiftCC() or
		FlourCC() or
		IBCC() or
		CommonKick(DrTyphoon,"magic","move",LYDrTyphKick and not UnitChannelInfo("player"),15) or
		CommonKick(DrDesor,"phys","alt",LYDrDesorKick and not UnitChannelInfo("player"),9) or
		CommonKick(DrBash,"phys","alt",LYDrBashKick,5) or
		AntiStealth(DrMF) or
		PauseRotation or
		ConditionalSpell(DrStealth,LYDrStealth and not HaveBuff("player",{ArenaPrepBuff, HordeFlag, AlyFlag, DrStealth}) and LYLastSpellName ~= DrStealth and GetTime()-LastStealth > 1 and not IsMounted() and (GetShapeshiftForm() == 0 or GetShapeshiftForm() == 2) and not UnitAffectingCombat("player") and not HaveDebuff("player",listDoTs)) or
		ConditionalSpell(DrRenewal,GCDCheck(DrRenewal) and FriendIsUnderAttack("player") and CalculateHP("player") < LYDrRenew) or
		DefensiveOnTeam(DrIBark,nil,LYDrIrBarkHP,LYDrIrBarkBurst,nil,true) or
		ConditionalSpell(DrBear,LYMode ~= "PvE" and CDLeft(DrRejuv) > 2 and CalculateMP("player") > 10 and GetShapeshiftForm() ~= 1 and not HaveBuff("player",DrIncTreeForm)) or
		DefensiveOnTeam(DrNS,nil,LYDrNS,nil,nil,IsMoving()) or
		Inner() or
		ConditionalSpell(DrNVigil,EnemyIsBursting() or HaveBuff("player",DrIncTree)) or
		BRDeadFriend() or
		ResDeadFriend() or
		PreHot() or
		DPSMode() or
		FlourHeal() or
		DefensiveOnTeam(DrCenWard,nil,LYDrCenWardHP,LYDrCenWardBurst,nil,true) or
		Overgrowth() or
		CommonHeal(DrRegr,HaveBuff("player",{DrNS,DrIncTree}),LYDrRegrNSHP) or
		CommonHeal(DrIncTree,not HaveBuff("player",DrIncTreeForm),LYDrIncTreeHP) or
		DrSwiftMend() or
		Invigor() or
		LBloom() or
		AOEHeal(DrWGrowth,30,LYDrWGrowthHP,LYDrWGrowthCount,(IsPvPTalentInUse(1215) or not IsMoving())) or
		AOEHeal(DrMush,10,LYDrEfflorHP,LYDrEfflorCount,not HaveBuff("player",DrMush)) or
		CommonHeal(DrRejuv,(not HaveBuff("player",DrSoulOfForest) or IsMoving()),95,5) or
		Germ() or
		ConditionalSpell(DrIncTree,HaveBuff("player",DrIncTreeForm) and not HaveBuff("player",DrIncTree)) or
		RootTree() or
		EfflorPvP() or
		StunCC(DrBash,"phys",LYDrBashDR,LYDrBashHealer,LYDrBashHealerHP,LYDrBashBurst,LYDrBashDPS,LYDrBashDPSHP,LYDrBashDPSBurst,LYDrBashChain,LYDrBashFocus,5) or
		DefensiveOnTeam(DrThorns,"MELEE",LYDrThornsHP,LYDrThornsBurst,nil,LYMode ~= "PvE") or
		DefensiveOnEnemy(DrVortex,"MELEE","magic",LYDrVortexHP,LYDrVortexBurst,30,LYMode ~= "PvE" and IsMoving()) or
		Tranq() or
		ConditionalSpell(DrIncTree,GCDCheck(DrIncTree) and not HaveBuff("player",DrIncTreeForm) and TeamMembersAroundUnit(nil,"player",LYDrIncTreeAOEHP) >= LYDrIncTreeAOEUnits) or
		ConditionalSpell(DrBear,LYMode ~= "PvE" and (IsRooted() or HaveDebuff("player",listShiftSlow)) and (GetShapeshiftForm() ~= 1 or not FriendIsUnderAttack("player","MELEE")) and not HaveBuff("player",DrIncTreeForm)) or
		BearDef() or
		CommonHeal(DrConvSpirit,not IsMoving() and not EnemyCanKick(),35) or
		FearCC(DrClone,"magic",LYDrCloneDR,LYDrCloneHealer,LYDrCloneHealerHP,LYDrCloneBurst,LYDrCloneDPS,LYDrCloneDPSHP,LYDrCloneDPSBurst,LYDrCloneCont,LYDrCloneFocus,true) or
		Nourish() or
		LBloomPvP() or
		PurgeEnrage(DrSoothe,true) or
		TotemStomp(nil,{DrWrath,DrMF},40) or
		CommonHeal(DrRegr,not IsMoving() and HaveBuff("player",DrOmen),90) or
		CommonHeal(DrRegr,not IsMoving() and LYZoneType ~= "arena",65,3) or
		CommonHeal(DrRegr,not IsMoving(),LYDrRegrHP) or
		DrOwlAction() or
		AutoBuffParty(DrMarkWild) then
			return true
		end
	end
	function LYEvokerDevas()
		local function Landslide()
			if GCDCheck(EvLandslide) and LYMode ~= "PvE" then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and ((CalculateHP(LYEnemies[i]) < 35 and not IsInDistance(LYEnemies[i],10))) and not HaveBuff(LYEnemies[i],listIRoot) and CheckUnitDR(LYEnemies[i],"root",1) and not UnitIsCCed(LYEnemies[i],LYGCDTime) and not IsRooted(LYEnemies[i],LYGCDTime) then
						LYQueueSpell(EvLandslide,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",EvAzureStrk) then
				if GCDCheck(EvDeepBreath) then
					LYQueueSpell(EvDeepBreath,LYEnemyTarget)
					LY_Print(EvDeepBreath,"green",EvDeepBreath)
					return true
				end
				if GCDCheck(EvDragonrage) and not BreakCCAroundUnit() then
					LYQueueSpell(EvDragonrage)
					LY_Print(EvDragonrage,"green",EvDragonrage)
					return true
				end
			end
		end
		if CommonKick(EvKick,"magic","kick",true) or
		CommonKick(EvTailSwipe,"magic","alt",EvTailSwipeKick,8) or
		CastBeforeSpell(EvOppresRoar,EvSleepWalk) or
		EvTimeStopCC() or
		EvReleaseEmpowered() or
		ConditionalSpell(EvTipScales,GCDCheck(EvEternSurge) and (CalculateHP(LYEnemyTarget) < LYEvTipScalesHP or (IsBursting() and LYEvTipScalesBurst))) or
		EvNullShroudCast() or
		PauseRotation or
		ConditionalSpell(EvTimeStop,LYLastSpellName == EvTimeStop and not PartyHPBelow(LYEvTimeStopHP)) or
		LYDispelAllF(EvDispelDPS) or
		LYDispelAllF(EvCauterFlame) or
		EvVerdEmbraceCast() or
		CommonHeal(EvEmerBlos,true,LYEvEmerBlosHP) or
		CommonHeal(EvLivFlame,(not IsMoving() or HaveBuff("player",EvHover)),LYEvLivFlameHP) or
		CommonHeal(EvTimeStop,true,LYEvTimeStopHP) or
		DefensiveOnPlayer(EvObsidScales,nil,LYEvObsidScalesHP,LYEvObsidScalesBurst,LYEvObsidScalesHealer,true) or
		DefensiveOnPlayer(EvRenewBlaze,nil,LYEvRenewBlazeHP,LYEvRenewBlazeBurst,nil,true) or
		ControlCC(EvSleepWalk,"magic",LYEvSleepWalkDR,LYEvSleepWalkHealer,LYEvSleepWalkHealerHP,LYEvSleepWalkTeamBurst,LYEvSleepWalkDPS,LYEvSleepWalkDPSHP,LYEvSleepWalkDPSBurst,LYEvSleepWalkCont,LYEvSleepWalkFocus) or
		TotemStomp(nil,{EvAzureStrk},25) or
		Landslide() or
		CommonAttack(EvUnravel,"magic",true,EvUnravel,true) or
		ConditionalSpell(EvHover,not HaveBuff("player",EvHover) and IsMoving() and IsBursting()) or
		Burst() or
		CommonAttack(EvFirestorm,"magic",true,EvAzureStrk,LYMode ~= "PvP" and not UnitAffectingCombat("player") and (not IsMoving() or HaveBuff("player",EvHover))) or
		CommonAttackTarget(EvFireBreath,"magic",true,GCDCheck(EvFireBreath) and inRange(EvAzureStrk,LYEnemyTarget) and (not IsMoving() or HaveBuff("player",EvTipScales))) or
		CommonAttackTarget(EvEternSurge,"magic",true,GCDCheck(EvEternSurge) and inRange(EvEternSurge,LYEnemyTarget) and (not IsMoving() or HaveBuff("player",EvTipScales))) or
		CommonAttackTarget(EvShatStar,"magic",true,GCDCheck(EvShatStar) and inRange(EvShatStar,LYEnemyTarget)) or
		CommonAttackTarget(EvPyre,"magic",true,GCDCheck(EvPyre) and BuffCount("player",EvChargedBlast) == 20 and inRange(EvPyre,LYEnemyTarget) and EnemiesAroundUnit(8,LYEnemyTarget) > 1) or
		CommonAttack(EvLivFlame,"magic",true,EvLivFlame,HaveBuff("player",EvBurnout)) or
		CommonAttack(EvAzureStrk,"magic",true,EvAzureStrk,HaveBuff("player",EvDragonrage) and not HaveBuff("player",EvEssenceBurst) and not BreakCCAroundUnit(30)) or
		CommonAttack(EvFirestorm,"magic",true,EvAzureStrk,LYMode ~= "PvP" and not HaveBuff("player",EvEssenceBurst) and (not IsMoving() or HaveBuff("player",EvHover)),nil,nil,1) or
		CommonAttackTarget(EvPyre,"magic",true,GCDCheck(EvPyre) and inRange(EvPyre,LYEnemyTarget) and EnemiesAroundUnit(8,LYEnemyTarget) > 2) or
		CommonAttack(EvDisintegr,"magic",true,EvDisintegr,(not IsMoving() or HaveBuff("player",EvHover))) or
		CommonAttack(EvAzureStrk,"magic",true,EvAzureStrk,not BreakCCAroundUnit(30)) or
		CommonAttack(EvLivFlame,"magic",true,EvLivFlame,(not IsMoving() or HaveBuff("player",EvHover))) or
		EvSourceMagicCast() or
		AutoBuffParty(EvBlessBronze) then
			return true
		end
	end
	function LYEvokerPreserv()
		if CommonKick(EvKick,"magic","kick",true) or
		CommonKick(EvWingBuf,"magic","alt",EvWingBufKick,8) or
		CommonKick(EvTailSwipe,"magic","alt",EvTailSwipeKick,8) or
		CastBeforeSpell(EvOppresRoar,EvSleepWalk) or
		EvTimeStopCC() or
		ConditionalSpell(EvTipScales,GCDCheck(EvDreamBreath) and PartyHPBelow(LYEvTipScalesHP)) or
		LYDispel(EvDispel) or
		EvReleaseEmpowered() or
		ConditionalSpell(EvHover,EnemyIsBursting() and LYLastSpellName == EvVerdEmbrace and not HaveBuff("player",EvHover)) or
		EvNullShroudCast() or
		PauseRotation or
		ConditionalSpell(EvTimeStop,LYLastSpellName == EvTimeStop and not PartyHPBelow(LYEvTimeStopHP)) or
		DefensiveOnPlayer(EvObsidScales,nil,LYEvObsidScalesHP,LYEvObsidScalesBurst,LYEvObsidScalesHealer,true) or
		DefensiveOnPlayer(EvRenewBlaze,nil,LYEvRenewBlazeHP,LYEvRenewBlazeBurst,nil,true) or
		DefensiveOnTeam(EvTimeDilation,nil,LYEvTimeDilationHP,LYEvTimeDilationBurst,nil,true) or
		DefensiveOnTeam(EvRewind,nil,LYEvRewindHP,nil,nil,true) or
		DefensiveOnTeam(EvStasis,nil,30,true,nil,not HaveBuff("player",{370537,370562})) or
		ConditionalSpell(EvStasis,HaveBuff("player",370562) and PartyHPBelow(50)) or
		CommonHeal(EvCauterFlame,true,35) or
		CommonHeal(EvRescue,IsTalentInUse(370888),35) or
		CommonAttack(EvChronoLoop,"magic",true,EvChronoLoop,true,nil,nil,nil,20) or
		CommonHeal(EvRevers,true,90,2) or
		CommonHeal(EvEcho,not HaveBuff("player",EvEcho),90) or
		AOEHeal(EvEmerBlos,30,85,3,true) or
		EvVerdEmbraceCast() or
		CommonHeal(EvTimeStop,true,LYEvTimeStopHP) or
		CommonHeal(EvDreamFlight,true,LYEvDreamFlightHP) or
		CommonHeal(EvDreamProject,not HaveDebuff("player",WlUnstable),LYEvDreamProjectHP) or
		CommonHeal(EvEmerCommun,true,LYEvEmerCommunHP) or
		CommonHeal(EvDreamBreath,(not IsMoving() or HaveBuff("player",EvTipScales)),LYEvDreamBreathHP) or
		CommonHeal(EvSpiritbloom,(not IsMoving() or HaveBuff("player",EvTipScales)),LYEvSpiritBloomHP) or
		ControlCC(EvSleepWalk,"magic",LYEvSleepWalkDR,LYEvSleepWalkHealer,LYEvSleepWalkHealerHP,LYEvSleepWalkTeamBurst,LYEvSleepWalkDPS,LYEvSleepWalkDPSHP,LYEvSleepWalkDPSBurst,LYEvSleepWalkCont,LYEvSleepWalkFocus) or
		CommonHeal(EvTempAnomaly,true,85) or
		CommonHeal(EvLivFlame,(not IsMoving() or HaveBuff("player",EvHover)),85) or
		CommonAttack(EvUnravel,"magic",true,EvUnravel,true) or
		TotemStomp(nil,{EvAzureStrk},25) or
		CommonAttackTarget(EvFireBreath,"magic",true,LYHDPS and inRange(EvAzureStrk,LYEnemyTarget) and (not IsMoving() or HaveBuff("player",EvTipScales))) or
		CommonAttack(EvDisintegr,"magic",true,EvDisintegr,LYHDPS and (not IsMoving() or HaveBuff("player",EvHover))) or
		CommonAttack(EvAzureStrk,"magic",true,EvAzureStrk,LYHDPS and not BreakCCAroundUnit(30) and EnemiesAroundUnit(8, LYEnemyTarget) > 1) or
		CommonAttack(EvLivFlame,"magic",true,EvLivFlame,LYHDPS and (not IsMoving() or HaveBuff("player",EvHover))) or
		CommonAttack(EvAzureStrk,"magic",true,EvAzureStrk,LYHDPS and not BreakCCAroundUnit(30)) or
		EvSourceMagicCast() or
		AutoBuffParty(EvBlessBronze) then
			return true
		end
	end
	function LYEvokerAug()
		local function PrescCast()
			if GCDCheck(EvPresc) then
				if not HaveBuff("player",EvPresc) then
					if UnitAffectingCombat("player") then
						LYQueueSpell(EvPresc,"player")
						return true
					end
				else
					for i=1,#LYTeamPlayers do
						if ValidFriendUnit(LYTeamPlayers[i]) and CheckRole(LYTeamPlayers[i]) ~= "HEALER" and not UnitIsTank(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],EvPresc) and UnitAffectingCombat(LYTeamPlayers[i]) then
							LYQueueSpell(EvPresc,LYTeamPlayers[i])
							return true
						end
					end
				end
			end
		end
		local function BlistScale()
			if GCDCheck(EvBlistScale) and LYStyle ~= "Utilities only" then
				if LYMode == "PvE" then
					for i=1,#LYTeamPlayers do
						if ValidFriendUnit(LYTeamPlayers[i]) and UnitAffectingCombat(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],EvBlistScale,0,"player") and UnitIsTank(LYTeamPlayers[i]) then
							LYQueueSpell(EvBlistScale,LYTeamPlayers[i])
							return true
						end
					end
				else
					local BSUnit = AnyFriendHasBuff(EvBlistScale,5)
					for i=1,#LYTeamPlayers do
						if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 95 and FriendIsUnderAttack(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],EvBlistScale,0,"player") and (not UnitIsVisible(BSUnit) or (CalculateHP(LYTeamPlayers[i]) + 15 < CalculateHP(BSUnit))) then
							LYQueueSpell(EvBlistScale,LYTeamPlayers[i])
							return true
						end
					end
				end
			end
		end
		if CommonKick(EvKick,"magic","kick",true) or
		EvTimeStopCC() or
		EvReleaseEmpowered() or
		ConditionalSpell(EvTipScales,(GCDCheck(EvFireBreath) or GCDCheck(EvUpheaval)) and (CalculateHP(LYEnemyTarget) < LYEvTipScalesHP or (IsBursting() and LYEvTipScalesBurst)) and HaveBuff("player",EvEbonMight)) or
		EvNullShroudCast() or
		PauseRotation or
		ConditionalSpell(EvTimeStop,LYLastSpellName == EvTimeStop and not PartyHPBelow(LYEvTimeStopHP)) or
		LYDispelAllF(EvDispelDPS) or
		LYDispelAllF(EvCauterFlame) or
		EvVerdEmbraceCast() or
		CommonHeal(EvEmerBlos,true,LYEvEmerBlosHP) or
		CommonHeal(EvLivFlame,(not IsMoving() or HaveBuff("player",EvHover)),LYEvLivFlameHP) or
		CommonHeal(EvTimeStop,true,LYEvTimeStopHP) or
		DefensiveOnPlayer(EvObsidScales,nil,LYEvObsidScalesHP,LYEvObsidScalesBurst,LYEvObsidScalesHealer,true) or
		DefensiveOnPlayer(EvRenewBlaze,nil,LYEvRenewBlazeHP,LYEvRenewBlazeBurst,nil,true) or
		ControlCC(EvSleepWalk,"magic",LYEvSleepWalkDR,LYEvSleepWalkHealer,LYEvSleepWalkHealerHP,LYEvSleepWalkTeamBurst,LYEvSleepWalkDPS,LYEvSleepWalkDPSHP,LYEvSleepWalkDPSBurst,LYEvSleepWalkCont,LYEvSleepWalkFocus) or
		TotemStomp(nil,{EvAzureStrk},25) or
		PrescCast() or
		CommonAttackTarget(EvBreathEon,"magic",true,GCDCheck(EvBreathEon) and BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"magic",EvAzureStrk)) or
		ConditionalSpell(EvEbonMight,GCDCheck(EvFireBreath) and UnitAffectingCombat("player") and not HaveBuff("player",EvEbonMight,3) and (not IsMoving() or HaveBuff("player",EvTipScales))) or
		CommonAttackTarget(EvFireBreath,"magic",true,GCDCheck(EvFireBreath) and HaveBuff("player",EvEbonMight) and inRange(EvAzureStrk,LYEnemyTarget) and (not IsMoving() or HaveBuff("player",EvTipScales))) or
		CommonAttackTarget(EvUpheaval,"magic",true,GCDCheck(EvUpheaval) and HaveBuff("player",EvEbonMight) and inRange(EvAzureStrk,LYEnemyTarget) and (not IsMoving() or HaveBuff("player",EvTipScales)) and not BreakCCAroundUnit(10,LYEnemyTarget)) or
		CommonAttack(EvUnravel,"magic",true,EvUnravel,true) or
		ConditionalSpell(EvHover,not HaveBuff("player",EvHover) and IsMoving() and IsBursting()) or
		BlistScale() or
		CommonAttack(EvLivFlame,"magic",true,EvLivFlame,HaveBuff("player",EvLeapFlame) and (not IsMoving() or HaveBuff("player",EvHover))) or
		CommonAttack(EvErupt,"magic",true,EvErupt,not IsMoving() or HaveBuff("player",EvHover)) or
		CommonAttack(EvLivFlame,"magic",true,EvLivFlame,not IsMoving() or HaveBuff("player",EvHover)) or
		CommonAttack(EvAzureStrk,"magic",true,EvAzureStrk,not BreakCCAroundUnit(30)) or
		EvSourceMagicCast() or
		ConditionalSpell(EvBlackAttun,GCDCheck(EvBlackAttun) and not HaveBuff("player",{EvBlackAttun,EvBronzeAttun})) or
		AutoBuffParty(EvBlessBronze) then
			return true
		end
	end
	function LYHunterBM()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",HnArcane) then
				if GCDCheck(HnChimaeralSting) then
					local chimaeraTarget = LYEnemyTarget
					if #LYEnemyHealers > 0 then
						chimaeraTarget = LYEnemyHealer
					end
					if LYFacingCheck(chimaeraTarget) then
						LYQueueSpell(HnChimaeralSting,chimaeraTarget)
						LY_Print(HnChimaeralSting,"green",HnChimaeralSting)
						return true
					end
				end
				if GCDCheck(HnBloodshed) then
					LYQueueSpell(HnBloodshed)
					LY_Print(HnBloodshed,"green",HnBloodshed)
					return true
				end
				if GCDCheck(HnDeathChak) then
					LYQueueSpell(HnDeathChak,LYEnemyTarget)
					LY_Print(HnDeathChak,"green",HnDeathChak)
					return true
				end
				if GCDCheck(HnBestWrath) and (not IsTalentInUse(193532) or C_Spell.GetSpellCharges(HnBarbShot).currentCharges == 0) then
					LYQueueSpell(HnBestWrath)
					LY_Print(HnBestWrath,"green",HnBestWrath)
					return true
				end
				if GCDCheck(HnCallWild) then
					LYQueueSpell(HnCallWild,LYEnemyTarget)
					LY_Print(HnCallWild,"green",HnCallWild)
					return true
				end
				if GCDCheck(HnCrows) and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(HnCrows,LYEnemyTarget)
					LY_Print(HnCrows,"green",HnCrows)
					return true
				end
				if GCDCheck(HnBasil) then
					LYQueueSpell(HnBasil,LYEnemyTarget)
					LY_Print(HnBasil,"green",HnBasil)
					return true
				end
			end
		end
		local function SpiritMend()
			if GCDCheck(HnSpiritMend) and LYStyle ~= "Utilities only" and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and not UnitIsCCed("pet") then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 85 and IsInDistance("pet",20,LYTeamPlayers[i]) and InLineOfSight("pet",LYTeamPlayers[i]) then
						CastSpellByName(HnSpiritMend,LYTeamPlayers[i])
						return
					end
				end
			end
		end
		local function BarbPrio()
			if IsTalentInUse(257944) and BuffTimeLeft("player",HnThrill) < 2 and CDLeft(HnBarbShot) < LYGCDTime and LYStyle ~= "Utilities only" then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"phys") and inRange(HnBarbShot,LYEnemies[i]) and LYFacingCheck(LYEnemies[i]) then
						LYQueueSpell(HnBarbShot,LYEnemies[i])
						return true
					end
				end
			end
		end
		if CommonKick(HnKick2,"phys","kick",true) or
		CommonKick(HnScatter,"phys","alt",LYHnScatKick and LYMode ~= "PvE") or
		CommonKick(HnIntimid,"phys","alt",LYHnIntimidKick) or
		HnFDCC() or
		HnFDDPS() or
		HnFDKarma() or
		DefensiveOnPlayer(HnDeter,nil,LYHnDeterHP,LYHnDeterBurst,LYHnDeterHealer,true) or
		PauseRotation or
		DefensiveOnPlayer(HnSurvFit,nil,LYHnSurvFitHP,LYHnSurvFitBurst,LYHnSurvFitHealer,true) or
		DefensiveOnPlayer(HnFortBear,nil,LYHnFortBearHP,nil,nil,true) or
		PetBehaviour() or
		HnFDDef() or
		DefensiveOnTeam(HnTaunt,"WIZARD",LYHnTauntHP,LYHnTauntBurst,nil,LYMode ~= "PvE" and IsPvPTalentInUse(1214) and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and IsInDistance("pet",10)) or
		FreedomCast(HnFreedom,LYHnFreedomHeal,LYHnFreedomHP,LYHnFreedomRoot,LYHnFreedomDPS,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and not UnitIsCCed("pet")) or
		SpiritMend() or
		HnPlayDeadCC() or
		HnTauntPvE() or
		BarbPrio() or
		AntiStealth(HnHuntMark) or
		ConditionalSpell(HnRevPet,UnitIsDeadOrGhost("pet") and not IsMoving() and LYLastFailedSpell ~= HnRevPet) or
		HnCallPetFunc() or
		HnExploseKick() or
		TotemStomp(nil,{HnCobra},40) or
		PurgeForce(HnPurge) or
		PurgeEssential(HnPurge) or
		HnTrapCC() or
		StunCC(HnIntimid,"phys",LYHnIntimidDR,LYHnIntimidHealer,LYHnIntimidHealerHP,LYHnIntimidTeamBurst,LYHnIntimidDPS,LYHnIntimidDPSHP,LYHnIntimidDPSBurst,nil,nil,5) or
		StunCC(HnBindShot,"magic",LYHnBindShotDR,LYHnBindShotHealer,LYHnBindShotHealerHP,LYHnBindShotTeamBurst,LYHnBindShotDPS,LYHnBindShotDPSHP,LYHnBindShotDPSBurst,LYHnBindShotCont,nil,35) or
		FearCC(HnScatter,"phys",LYHnScatDR,LYHnScatHealer,LYHnScatHealerHP,LYHnScatTeamBurst,LYHnScatDPS,LYHnScatDPSHP,LYHnScatDPSBurst,LYHnScatCont,LYHnScatFocus) or
		HnBinding() or
		HnExploseBinding() or
		ConditionalSpell(HnHeal,GCDCheck(HnHeal) and CalculateHP("player") < LYHnExhil and FriendIsUnderAttack("player") and (not LYHnExhilHealer or not TeamHealerCanInteract())) or
		DefensiveOnTeam(HnHiExpTrap,"MELEE",LYHnHiExpTrapHP,LYHnHiExpTrapBurst,nil,true) or
		SlowTarget(HnConcus,"phys",40,LYSlowAlways) or
		Peel(HnConcus,"phys",LYPeelAny,LYPeelHealer,40) or
		Peel(HnRootTrap,"phys",LYPeelAny,LYPeelHealer,40) or
		HnScareBeastBurst() or
		HnMark() or
		Burst() or
		CommonAttack(HnMulti,"phys",true,HnArcane,not DoNotUsePower and not BreakCCAroundUnit() and not HaveBuff("player",HnBeastCleave,1.5),nil,nil,2) or
		HnKillShotCast() or
		ConditionalSpell(HnBestWrath,IsTalentInUse(231548) and (not IsTalentInUse(193532) or C_Spell.GetSpellCharges(HnBarbShot).currentCharges == 0) and InEnemySight()) or
		HnKillCommand(IsTalentInUse(269737) and SpellChargesCheck(HnKillCom) and (not UnitIsVisible("pet") or LYUP > 40 or EnemiesAroundUnit(8,"target") < 3)) or
		CommonAttack(HnBarbShot,"phys",true,HnBarbShot,(not IsTalentInUse(199530) or not BreakCCAroundUnit("pet",10)) and (not IsTalentInUse(257944) or (BuffCount("player",HnThrill) < 2 and CDLeft(HnBestWrath) < 12) or SpellChargesCheck(HnBarbShot) or BuffTimeLeft("player",HnThrill) < 3 or (IsTalentInUse(231548) and IsTalentInUse(193532) and CDLeft(HnBestWrath) < 12)) and LYUP < 90) or
		CommonAttack(HnDireBeast,"phys",nil,HnDireBeast,LYUP > 29 and not HaveBuff("player",HnDireBeast)) or
		HnKillCommand(true) or
		HnCastSteelTrap() or
		CommonAttack(HnSerpent,"magic",true,HnSerpent,true,5,HnSerpent) or
		CommonAttack(HnBarrage,"phys",true,HnArcane,not BreakCCAroundUnit(nil,nil,true)) or
		CommonAttack(HnCrows,"phys",nil,HnCrows,LYMode ~= "PvP",nil,nil,nil,30) or
		CommonAttackTarget(HnExplosive,"magic",nil,inRange(HnExplosive,LYEnemyTarget) and not BreakCCAroundUnit(LYEnemyTarget,10)) or
		ConditionalSpell(HnHealPet,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and (CalculateHP("pet") < 25 or (LYMode == "PvP" and CalculateHP("pet") < 85) or (IsTalentInUse(343242) and UnitIsCCed("pet",4))) and not HaveBuff("pet",HnHealPet) and InLineOfSight("pet") and inRange(HnHealPet,"pet")) or
		AOEAttack(HnHawk,10,HnKick2,2,LYMode ~= "PvE") or
		ConditionalSpell(HnWildKing,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and CalculateHP("pet") < 20) or
		PurgePassive(HnPurge) or
		CommonAttack(HnCobra,"phys",true,HnArcane,not DoNotUsePower and LYUP > 40) or
		CommonAttack(HnArcane,"magic",true,HnArcane,not DoNotUsePower and (not UnitIsVisible("pet") or LYUP > 40 or EnemiesAroundUnit(8,"target") < 3)) then
			return true
		end
	end
	function LYHunterMM()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",HnSteady) then
				if GCDCheck(HnChimaeralSting) then
					local chimaeraTarget = LYEnemyTarget
					if #LYEnemyHealers > 0 then
						chimaeraTarget = LYEnemyHealer
					end
					if LYFacingCheck(chimaeraTarget) then
						LYQueueSpell(HnChimaeralSting,chimaeraTarget)
						LY_Print(HnChimaeralSting,"green",HnChimaeralSting)
						return true
					end
				end
				if GCDCheck(HnCrows) and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(HnCrows,LYEnemyTarget)
					LY_Print(HnCrows,"green",HnCrows)
					return true
				end
				if GCDCheck(HnDeathChak) then
					LYQueueSpell(HnDeathChak,LYEnemyTarget)
					LY_Print(HnDeathChak,"green",HnDeathChak)
					return true
				end
				if GCDCheck(HnSalvo) then
					CastSpellByName(HnSalvo)
					LY_Print(HnSalvo,"green",HnSalvo)
				end
				if GCDCheck(HnVolley) then
					LYQueueSpell(HnVolley,LYEnemyTarget)
					LY_Print(HnVolley,"green",HnVolley)
					return true
				end
				if GCDCheck(HnTrueShot) then
					LYQueueSpell(HnTrueShot)
					LY_Print(HnTrueShot,"green",HnTrueShot)
					return true
				end
			end
		end
		local function Aimed()
			if GCDCheck(HnAimed) and LYStyle ~= "Utilities only" and not DoNotUsePower and (not IsMoving() or HaveBuff("player",HnLockAndLoad)) then
				local canAim = not HaveBuff("player",HnPrecShout) or HaveBuff("player",HnTrueShot)
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"phys") and inRange(HnAimed,LYEnemies[i]) and ((HaveBuff("player",HnTrickShot) and EnemiesAroundUnit(8,LYEnemies[i]) >= 2) or (IsTalentInUse(260228) and CalculateHP(LYEnemies[i]) > 70) or canAim) and LYFacingCheck(LYEnemies[i]) then
						LYQueueSpell(HnAimed,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function RapidFire()
			if GCDCheck(HnRapidFire) and LYStyle ~= "Utilities only" and LYUP < 85 and (LYMode ~= "PvP" or not IsTalentInUse(260402) or LYHnRapidFire) and (not HaveBuff("player",HnTrueShot) or LYMode == "PvP" or not GCDCheck(HnAimed) or (IsMoving() and not HaveBuff("player",HnLockAndLoad))) then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"phys") and inRange(HnArcane,LYEnemies[i]) and (HaveBuff("player",HnTrickShot) or EnemiesAroundUnit(8,LYEnemies[i]) < 3 or not IsTalentInUse(257621)) and LYFacingCheck(LYEnemies[i]) then
						LYQueueSpell(HnRapidFire,LYEnemies[i])
						return true
					end
				end
			end
		end
		if CommonKick(HnKick2,"phys","kick",true) or
		CommonKick(HnScatter,"phys","alt",LYHnScatKick and LYMode ~= "PvE") or
		HnExploseKick() or
		CommonKick(HnBurstShot,"phys","alt",LYHnBurstShotKick,8) or
		CommonKick(HnIntimid,"phys","alt",LYHnIntimidKick) or
		HnFDDPS() or
		HnFDKarma() or
		HnFDCC() or
		DefensiveOnPlayer(HnDeter,nil,LYHnDeterHP,LYHnDeterBurst,LYHnDeterHealer,true) or
		PauseRotation or
		DefensiveOnPlayer(HnSurvFit,nil,LYHnSurvFitHP,LYHnSurvFitBurst,LYHnSurvFitHealer,true) or
		DefensiveOnPlayer(HnFortBear,nil,LYHnFortBearHP,nil,nil,true) or
		PetBehaviour() or
		HnFDDef() or
		FreedomCast(HnFreedom,LYHnFreedomHeal,LYHnFreedomHP,LYHnFreedomRoot,LYHnFreedomDPS,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and not UnitIsCCed("pet")) or
		HnPlayDeadCC() or
		HnTauntPvE() or
		CommonAttack(HnSteady,"phys",true,HnSteady,IsTalentInUse(193533) and LYLastSpellName == HnSteady and not HaveBuff("player",{HnStdFoc,HnTrueShot},3)) or
		AntiStealth(HnHuntMark) or
		ConditionalSpell(HnRevPet,UnitIsDeadOrGhost("pet") and not IsMoving() and LYLastFailedSpell ~= HnRevPet) or
		HnCallPetFunc() or
		TotemStomp(nil,{HnArcane,HnSteady},45) or
		PurgeForce(HnPurge) or
		PurgeEssential(HnPurge) or
		HnTrapCC() or
		StunCC(HnIntimid,"phys",LYHnIntimidDR,LYHnIntimidHealer,LYHnIntimidHealerHP,LYHnIntimidTeamBurst,LYHnIntimidDPS,LYHnIntimidDPSHP,LYHnIntimidDPSBurst,nil,nil,5) or
		StunCC(HnBindShot,"magic",LYHnBindShotDR,LYHnBindShotHealer,LYHnBindShotHealerHP,LYHnBindShotTeamBurst,LYHnBindShotDPS,LYHnBindShotDPSHP,LYHnBindShotDPSBurst,LYHnBindShotCont,nil,35) or
		FearCC(HnScatter,"phys",LYHnScatDR,LYHnScatHealer,LYHnScatHealerHP,LYHnScatTeamBurst,LYHnScatDPS,LYHnScatDPSHP,LYHnScatDPSBurst,LYHnScatCont,LYHnScatFocus) or
		HnBinding() or
		HnExploseBinding() or
		ConditionalSpell(HnHeal,GCDCheck(HnHeal) and CalculateHP("player") < LYHnExhil and FriendIsUnderAttack("player") and (not LYHnExhilHealer or not TeamHealerCanInteract())) or
		DefensiveOnTeam(HnHiExpTrap,"MELEE",LYHnHiExpTrapHP,LYHnHiExpTrapBurst,nil,true) or
		SlowTarget(HnConcus,"phys",45,LYSlowAlways) or
		Peel(HnConcus,"phys",LYPeelAny,LYPeelHealer,45) or
		Peel(HnRootTrap,"phys",LYPeelAny,LYPeelHealer,40) or
		PlayerDefensiveOnEnemy(HnBurstShot,"MELEE","phys",LYHnBurstShotHP,LYHnBurstShotHPBurst,8,LYMode ~= "PvE") or
		HnScareBeastBurst() or
		HnMark() or
		Burst() or
		AOEAttack(HnVolley,8,HnArcane,LYHnVolleyAOE,not LYBurstMacro and not HaveBuff("player",HnTrueShot)) or
		HnKillShotCast() or
		CommonAttack(HnSteady,"phys",true,HnSteady,LYUP < 80 and IsTalentInUse(193533) and not HaveBuff("player",{HnStdFoc,HnTrueShot})) or
		CommonAttackTarget(HnSniperShot,"phys",true,inRange(HnSniperShot,LYEnemyTarget) and not IsMoving() and UnitIsCCed(LYEnemyTarget,3)) or
		CommonAttack(HnCrows,"phys",nil,HnCrows,LYMode ~= "PvP",nil,nil,nil,30) or
		CommonAttackTarget(HnExplosive,"magic",nil,inRange(HnExplosive,LYEnemyTarget) and not BreakCCAroundUnit(LYEnemyTarget,10)) or
		CommonAttack(HnBarrage,"phys",true,HnSteady,not BreakCCAroundUnit(nil,nil,true)) or
		CommonAttack(HnMulti,"phys",true,HnArcane,not DoNotUsePower and not BreakCCAroundUnit() and not HaveBuff("player",HnTrickShot),nil,nil,3) or
		RapidFire() or
		Aimed() or
		HnCastSteelTrap() or
		CommonAttack(HnSerpent,"magic",true,HnSerpent,true,5,HnSerpent) or
		ConditionalSpell(HnHealPet,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and (CalculateHP("pet") < 25 or (LYMode == "PvP" and CalculateHP("pet") < 85) or (IsTalentInUse(343242) and UnitIsCCed("pet",4))) and not HaveBuff("pet",HnHealPet) and InLineOfSight("pet") and inRange(HnHealPet,"pet")) or
		CommonAttack(HnMulti,"phys",true,HnArcane,not DoNotUsePower and not BreakCCAroundUnit() and (TimeToEnergy(LYUPMax) < 2 or CDLeft(HnAimed) > TimeToEnergy(55) or IsMoving()),nil,nil,3) or
		CommonAttack(HnArcane,"magic",true,HnArcane,not DoNotUsePower and IsTalentInUse(342049),nil,nil,2) or
		CommonAttack(HnArcane,"magic",true,HnArcane,not DoNotUsePower and (not IsTalentInUse(342049) or not BreakCCAroundUnit()) and (TimeToEnergy(LYUPMax) < 2 or CDLeft(HnAimed) > TimeToEnergy(55) or IsMoving() or (HaveBuff("player",HnPrecShout) and not IsTalentInUse(260228)))) or
		CommonAttack(HnArcane,"magic",true,HnArcane,not DoNotUsePower and (not IsTalentInUse(342049) or not BreakCCAroundUnit()) and HaveBuff("player",HnPrecShout) and IsTalentInUse(260228),nil,nil,nil,70) or
		ConditionalSpell(HnWildKing,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and CalculateHP("pet") < 20) or
		PurgePassive(HnPurge) or
		CommonAttack(HnSteady,"phys",true,HnSteady,true) then
			return true
		end
	end
	function LYHunterSurv()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",HnRaptor) then
				if GCDCheck(HnChimaeralSting) then
					local chimaeraTarget = LYEnemyTarget
					if #LYEnemyHealers > 0 then
						chimaeraTarget = LYEnemyHealer
					end
					if LYFacingCheck(chimaeraTarget) then
						LYQueueSpell(HnChimaeralSting,chimaeraTarget)
						LY_Print(HnChimaeralSting,"green",HnChimaeralSting)
						return true
					end
				end
				if GCDCheck(HnDeathChak) then
					LYQueueSpell(HnDeathChak,LYEnemyTarget)
					LY_Print(HnDeathChak,"green",HnDeathChak)
					return true
				end
				if GCDCheck(HnCrows) and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(HnCrows)
					LY_Print(HnCrows,"green",HnCrows)
					return true
				end
				if GCDCheck(HnCoordAttack) then
					LYQueueSpell(HnCoordAttack)
					LY_Print(HnCoordAttack,"green",HnCoordAttack)
					return true
				end
			end
		end
		local function BandageDoTs()
			if LYMode ~= "PvE" and GCDCheck(HnMendBand) and not IsMoving() then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and HaveDebuff(LYTeamPlayers[i],listBandage,8) and inRange(HnMendBand,LYTeamPlayers[i]) then
						LYQueueSpell(HnMendBand,LYTeamPlayers[i])
						LY_Print(HnMendBand.." DoTs","green",HnMendBand)
						return true
					end
				end
			end
		end
		if CommonKick(HnKick,"phys","kick",true) or
		CommonKick(HnScatter,"phys","alt",LYHnScatKick and LYMode ~= "PvE") or
		HnExploseKick() or
		CommonKick(HnIntimid,"phys","alt",LYHnIntimidKick) or
		HnFDCC() or
		HnFDDPS() or
		HnFDKarma() or
		PauseRotation or
		DefensiveOnPlayer(HnDeter,nil,LYHnDeterHP,LYHnDeterBurst,LYHnDeterHealer,true) or
		DefensiveOnPlayer(HnSurvFit,nil,LYHnSurvFitHP,LYHnSurvFitBurst,LYHnSurvFitHealer,true) or
		DefensiveOnPlayer(HnFortBear,nil,LYHnFortBearHP,nil,nil,true) or
		PetBehaviour() or
		HnFDDef() or
		FreedomCast(HnFreedom,LYHnFreedomHeal,LYHnFreedomHP,LYHnFreedomRoot,LYHnFreedomDPS,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and not UnitIsCCed("pet")) or
		ConditionalSpell(HnEagleBurst,GCDCheck(HnRaptor) and GCDCheck(HnEagleBurst) and UnitIsVisible(LYEnemyTarget) and SpellAttackTypeCheck(LYEnemyTarget,"phys") and inRange(HnHarpoon,LYEnemyTarget) and CalculateHP(LYEnemyTarget) < LYHnEagleBurstHP and LYFacingCheck(LYEnemyTarget)) or
		HnPlayDeadCC() or
		HnTauntPvE() or
		AntiStealth(HnHuntMark) or
		ConditionalSpell(HnRevPet,UnitIsDeadOrGhost("pet") and not IsMoving() and LYLastFailedSpell ~= HnRevPet) or
		HnCallPetFunc() or
		TotemStomp({HnRaptor}) or
		PurgeForce(HnPurge) or
		PurgeEssential(HnPurge) or
		HnTrapCC() or
		StunCC(HnIntimid,"phys",LYHnIntimidDR,LYHnIntimidHealer,LYHnIntimidHealerHP,LYHnIntimidTeamBurst,LYHnIntimidDPS,LYHnIntimidDPSHP,LYHnIntimidDPSBurst,nil,nil,5) or
		StunCC(HnBindShot,"magic",LYHnBindShotDR,LYHnBindShotHealer,LYHnBindShotHealerHP,LYHnBindShotTeamBurst,LYHnBindShotDPS,LYHnBindShotDPSHP,LYHnBindShotDPSBurst,LYHnBindShotCont,nil,35) or
		FearCC(HnScatter,"phys",LYHnScatDR,LYHnScatHealer,LYHnScatHealerHP,LYHnScatTeamBurst,LYHnScatDPS,LYHnScatDPSHP,LYHnScatDPSBurst,LYHnScatCont,LYHnScatFocus) or
		HnBinding() or
		HnExploseBinding() or
		ConditionalSpell(HnHeal,GCDCheck(HnHeal) and CalculateHP("player") < LYHnExhil and FriendIsUnderAttack("player") and(not LYHnExhilHealer or not TeamHealerCanInteract())) or
		DefensiveOnTeam(HnHiExpTrap,"MELEE",LYHnHiExpTrapHP,LYHnHiExpTrapBurst,nil,true) or
		Disarm(HnTarTrap,LYHnTarTrapHP,LYHnTarTrapBurst,nil,nil,40) or
		SlowTarget(HnWingClip,"phys",nil,LYSlowAlways) or
		SlowTarget(HnConcus,"phys",45,LYSlowAlways) or
		Peel(HnWingClip,"phys",LYPeelAny,LYPeelHealer) or
		Peel(HnConcus,"phys",LYPeelAny,LYPeelHealer,45) or
		Peel(HnRootTrap,"phys",LYPeelAny,LYPeelHealer,40) or
		Peel(HnTrackerNet,"phys",LYPeelAny,LYPeelHealer) or
		HnScareBeastBurst() or
		HnMark() or
		Burst() or
		HnKillShotCast() or
		CommonAttackTarget(HnWildFireBomb,"magic",true,inRange(HnWildFireBomb,LYEnemyTarget) and not BreakCCAroundUnit(LYEnemyTarget,10) and (SpellChargesCheck(HnWildFireBomb) or HaveBuff("player",HnMadBomb) or IsBursting() or EnemiesAroundUnit(8,LYEnemyTarget) > 2)) or
		HnKillCommand((IsTalentInUse(260248) and not HaveBuff("player",HnPredator)) or (IsTalentInUse(269737) and SpellChargesCheck(HnKillCom) and LYUP < 70)) or
		CommonAttackTarget(HnFlank,"phys",true,GCDCheck(HnFlank) and IsInDistance("pet",15,LYEnemyTarget) and not UnitIsCCed("pet") and LYUP < 60 and not IsRooted("pet") and inRange(HnFlank,LYEnemyTarget)) or
		CommonAttack(HnChakrams,"phys",true,HnChakrams,not DoNotUsePower and not BreakCCAroundUnit()) or
		CommonAttack(HnCrows,"phys",nil,HnCrows,LYMode ~= "PvP",nil,nil,nil,30) or
		CommonAttackTarget(HnExplosive,"magic",nil,inRange(HnExplosive,LYEnemyTarget) and not BreakCCAroundUnit(LYEnemyTarget,10)) or
		CommonAttack(HnFuryEagle,"phys",true,HnRaptor,not BreakCCAroundUnit("player",10)) or
		HnKillCommand(LYUP < 70) or
		CommonAttack(HnButchery,"phys",true,HnRaptor,not DoNotUsePower and not BreakCCAroundUnit("player",10),nil,nil,3) or
		CommonAttack(HnRaptor,"phys",true,HnRaptor,not DoNotUsePower and IsTalentInUse(259387)) or
		ConditionalSpell(HnHealPet,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and (CalculateHP("pet") < 25 or (LYMode == "PvP" and CalculateHP("pet") < 85) or (IsTalentInUse(343242) and UnitIsCCed("pet",4))) and not HaveBuff("pet",HnHealPet) and InLineOfSight("pet") and inRange(HnHealPet,"pet")) or
		HnKillCommand(true) or
		HnCastSteelTrap() or
		CommonAttack(HnSerpent,"magic",true,HnSerpent,true,5,HnSerpent) or
		CommonAttack(HnRaptor,"phys",true,HnRaptor,not DoNotUsePower) or
		ConditionalSpell(HnWildKing,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and CalculateHP("pet") < 20) or
		CommonAttackTarget(HnHarpoon,"phys",true,LYHnHarpoon and LYMode ~= "PvE" and IsTalentInUse(265895) and inRange(HnHarpoon,LYEnemyTarget)) or
		PurgePassive(HnPurge) or
		BandageDoTs() then
			return true
		end
	end
	function LYMageArc()
		local function Burst()
			if not IsMoving() and BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,nil,MgArcBlast) then
				if GCDCheck(MgEvoc) and not IsMoving() then
					LYQueueSpell(MgEvoc)
					LY_Print(MgEvoc,"green",MgEvoc)
					return true
				end
				if GCDCheck(MgIceFloes) and not HaveBuff("player",MgIceFloes) then
					LYQueueSpell(MgIceFloes)
					LY_Print(MgIceFloes,"green",MgIceFloes)
					return true
				end
				if GCDCheck(MgRingFire) and (not IsMoving() or HaveBuff("player",MgIceFloes)) then
					LYQueueSpell(MgRingFire, LYEnemyTarget)
					LY_Print(MgRingFire,"green",MgRingFire)
					return true
				end
				if GCDCheck(MgArcPower) then
					LYQueueSpell(MgArcPower,LYEnemyTarget)
					LY_Print(MgArcPower,"green",MgArcPower)
					return true
				end
				if GCDCheck(MgMirImage) and LYMgMirImageDPS then
					LYQueueSpell(MgMirImage)
					LY_Print(MgMirImage,"green",MgMirImage)
					return true
				end
				if GCDCheck(MgPoM) and LYUP > 3 then
					CastSpellByName(MgPoM)
					LY_Print(MgPoM,"green",MgPoM)
				end
				if GCDCheck(MgTouchMagi) and LYUP < 1 and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(MgTouchMagi,LYEnemyTarget)
					LY_Print(MgTouchMagi,"green",MgTouchMagi)
				end
			end
		end
		local function ArcOrb()
			if GCDCheck(MgArcOrb) and LYStyle ~= "Utilities only" and not BreakCCAroundUnit() and LYUP < 4 then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and inRange(MgArcBlast,LYEnemies[i]) and (UnitIsPlayer(LYEnemies[i]) or EnemiesAroundUnit(8,LYEnemies[i]) > 1 or UnitIsBoss(LYEnemies[i])) and IsLookingAt(LYEnemies[i]) then
						LYQueueSpell(MgArcOrb,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function ManaGem()
			if LYLastSpellName == MgArcPower and IsUsableItem(36799) and GetItemCooldown(36799) == 0 then
				UseItemByName(36799)
			end
		end
		if ManaGem() or
		CommonKick(MgKick,nil,"kick",true) or
		CommonKick(MgSupernova,nil,"move",true) or
		CommonKick(MgDB,nil,"alt",LYMgDBKick,8) or
		CastKick(MgPoly,LYMgPolyKick,"control") or
		ConditionalSpell(MgAlterTime,CalculateHP("player") < 10 and HaveBuff("player",MgAlterTime)) or
		AntiReflect(MgFBlast) or
		AntiStealth(MgBarrage) or
		PauseRotation or
		DefensiveOnPlayer(MgTempShield,nil,LYMgTempShieldHP,LYMgTempShieldBurst,LYMgTempShieldHealer,LYMode ~= "PvE") or
		DefensiveOnPlayer(MgAlterTime,nil,nil,LYMgAlterTimeBurst,LYMgAlterTimeHealer,not HaveBuff("player",MgAlterTime) and LYLastSpellName ~= MgAlterTime and CalculateHP("player") > 40 and GetTime() - LastAlterTime > 3) or
		DefensiveOnTeam(MgMassBar,nil,LYMgMassBarHP,LYMgMassBarBurst,nil,true) or
		MgBlastWaveKnockback() or
		AvoidGapCloser(MgBlastWave,true,8,"magic") or
		AvoidGapCloser(MgNova,true, 8,"magic") or
		AvoidGapCloser(MgDB,true,8,"magic",true) or
		LYDispelAlwaysF(MgDispel) or
		ConditionalSpell(MgPrizBar,LYMode ~= "PvE" and GCDCheck(MgPrizBar) and EnemyIsTargetingUnit("player") and not HaveBuff("player",MgPrizBar)) or
		TotemStomp(nil,{MgFBlast,MgBarrage,MgMissile,MgArcBlast},40) or
		PurgeForce(MgPurge) or
		PurgeEssential(MgPurge) or
		DefensiveOnPlayer(MgGreatInv,nil,LYMgGreatInvHP,LYMgGreatInvBurst,LYMgGreatInvHealer,LYMode ~= "PvE") or
		DefensiveOnPlayer(MgMirImage,nil,LYMgMirImageHP,LYMgMirImageBurst,LYMgMirImageHealer,true) or
		ControlCC(MgRingFrost,nil,LYMgRingFrostDR,LYMgRingFrostHealer,LYMgRingFrostHealerHP,LYMgRingFrostTeamBurst,LYMgRingFrostDPS,LYMgRingFrostDPSHP,LYMgRingFrostDPSBurst,LYMgRingFrostCont,LYMgRingFrostFocus,nil,40) or
		ControlCC(MgPoly,nil,LYMgPolyDR,LYMgPolyHealer,LYMgPolyHealerHP,LYMgPolyTeamBurst,LYMgPolyDPS,LYMgPolyDPSHP,LYMgPolyDPSBurst,LYMgPolyCont,LYMgPolyFocus,true,nil,(LYMgPolyWhileBurst and LYUP < 3 and not HaveBuff("player",DrClearCast))) or
		FearCC(MgDB,nil,LYMgDBDR,LYMgDBHealer,LYMgDBHealerHP,LYMgDBTeamBurst,LYMgDBDPS,LYMgDBDPSHP,LYMgDBDPSBurst,LYMgDBCont,nil,nil,8,LYMgDBWhileBurst) or
		SlowTarget(MgSlow,nil,nil,LYSlowAlways) or
		Peel(MgSlow,nil,LYPeelAny,LYPeelHealer) or
		Peel(MgBlastWave,nil,LYPeelAny,LYPeelHealer,8) or
		Peel(MgNova,nil,LYPeelAny,LYPeelHealer) or
		ConditionalSpell(MgDisplace,LYMgDisplace) or
		AutoBuffParty(MgArcInt) or
		Burst() or
		CommonAttack(MgBarrage,nil,true,MgBarrage,not BreakCCAroundUnit() and CalculateMP("player") < LYMgBarrage and LYUP > 3 and DebuffTimeLeft(LYEnemyTarget, MgTouchMagi) < 2) or
		CommonAttack(MgMissile,nil,true,MgMissile,(not IsMoving() or HaveBuff("player",MgIceFloes)) and HaveBuff("player",DrClearCast)) or
		CommonAttack(MgRadiantSpark,nil,true,MgKick,(not IsMoving() or HaveBuff("player",MgIceFloes))) or
		CommonAttack(MgArcBlast,nil,true,MgArcBlast,LYZoneType ~= "arena" and (not IsMoving() or HaveBuff("player",MgIceFloes)) and HaveBuff("player",MgArcPower)) or
		CommonAttack(MgBarrage,nil,true,MgBarrage,not BreakCCAroundUnit() and CalculateMP("player") < LYMgBarrage and LYUP > 3 and (not IsBursting() or not C_Spell.IsSpellUsable(MgArcBlast) or BuffCount("player",MgArcHarmony) > 9 or IsMoving())) or
		ArcOrb() or
		CommonAttack(MgSupernova,nil,true,MgSupernova,true,nil,nil,2) or
		CommonAttack(MgMissile,nil,true,MgMissile,LYZoneType == "arena" and (not IsMoving() or HaveBuff("player",MgIceFloes))) or
		ConditionalSpell(MgShiftingPower,GCDCheck(MgShiftingPower) and (not IsMoving() or HaveBuff("player",MgIceFloes)) and EnemiesAroundUnit(15) > 2) or
		ConditionalSpell(MgArcExp,EnemiesAroundUnit(10) > 2) or
		CommonAttack(MgArcBlast,nil,true,MgArcBlast,(not IsMoving() or HaveBuff("player",MgPoM))) or
		ConditionalSpell(MgEvoc,not C_Spell.IsSpellUsable(MgMissile) and not IsMoving() and not InEnemySight()) or
		ConditionalSpell(MgArcFam,not HaveBuff("player",MgArcFam)) or
		LYDispelAllF(MgDispel) then
			return true
		end
	end
	function LYMageFire()
		local function StopCast()
			if (UnitCastingInfo("player") == MgFireBall or (UnitCastingInfo("player") == MgScorch and (not IsTalentInUse(269644) or CalculateHP(GetSpellDestUnit("player")) > 30))) and LYStyle ~= "Utilities only" and HaveBuff("player",MgHeatUp) and CDCheck(MgFBlast) and LYLastSpellName ~= MgFBlast then
				LYSpellStopCasting()
				return true
			end
			if HaveBuff("player",MgPyroProc) and (UnitCastingInfo("player") == MgFireBall or UnitCastingInfo("player") == MgScorch) and LYStyle ~= "Utilities only" then
				LYSpellStopCasting()
				return true
			end
		end
		local function DB()
			if GCDCheck(MgDB) and (HaveBuff("player",MgCombust) or IsTalentInUse(235870)) and LYStyle ~= "Utilities only" and HaveBuff("player",MgHeatUp) then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and IsInDistance(LYEnemies[i],8) and IsLookingAt(LYEnemies[i]) then
						LYQueueSpell(MgDB,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,nil,MgFireBall) then
				if GCDCheck(MgIceFloes) and not HaveBuff("player",MgIceFloes) then
					LYQueueSpell(MgIceFloes)
					LY_Print(MgIceFloes,"green",MgIceFloes)
					return true
				end
				if GCDCheck(MgRingFire) and not HaveBuff("player",MgCombust) and (not IsMoving() or HaveBuff("player",MgIceFloes)) then
					LYQueueSpell(MgRingFire,LYEnemyTarget)
					LY_Print(MgRingFire,"green",MgRingFire)
					return true
				end
				if GCDCheck(MgMirImage) and LYMgMirImageDPS then
					LYQueueSpell(MgMirImage)
					LY_Print(MgMirImage,"green",MgMirImage)
					return true
				end
				if GCDCheck(MgCombust) and not HaveBuff("player",MgCombust) then
					CastSpellByName(MgCombust)
					LY_Print(MgCombust,"green",MgCombust)
				end
			end
		end
		if CommonKick(MgKick,nil,"kick",true) or
		CommonKick(MgDB,nil,"alt",LYMgDBKick,8) or
		CastKick(MgPoly,LYMgPolyKick,"control") or
		CommonAttack(MgFBlast,nil,true,MgKick,(HaveBuff("player",MgHeatUp) or HaveBuff("player",MgCombust)) and not HaveBuff("player",MgPyroProc) and (LYLastSpellName ~= MgDB or not IsTalentInUse(235870)) and LYLastSpellName ~= MgFBlast and (LYLastSpellName ~= MgFrArt or not HaveBuff("player",MgCombust))) or
		StopCast() or
		ConditionalSpell(MgAlterTime,CalculateHP("player") < 10 and HaveBuff("player",MgAlterTime)) or
		AntiReflect(MgFrArt) or
		AntiStealth(MgFBlast) or
		PauseRotation or
		DefensiveOnPlayer(MgTempShield,nil,LYMgTempShieldHP,LYMgTempShieldBurst,LYMgTempShieldHealer,LYMode ~= "PvE") or
		DefensiveOnPlayer(MgAlterTime,nil,nil,LYMgAlterTimeBurst,LYMgAlterTimeHealer,not HaveBuff("player",MgAlterTime) and LYLastSpellName ~= MgAlterTime and CalculateHP("player") > 40 and GetTime() - LastAlterTime > 3) or
		DefensiveOnTeam(MgMassBar,nil,LYMgMassBarHP,LYMgMassBarBurst,nil,true) or
		MgBlastWaveKnockback() or
		AvoidGapCloser(MgBlastWave,true,8,"magic") or
		AvoidGapCloser(MgNova,true,8,"magic") or
		AvoidGapCloser(MgDB,true,8,"magic",true) or
		LYDispelAlwaysF(MgDispel) or
		TotemStomp(nil,{MgFrArt,MgFBlast,MgScorch},40) or
		PurgeForce(MgPurge) or
		PurgeEssential(MgPurge) or
		DefensiveOnPlayer(MgGreatInv,nil,LYMgGreatInvHP,LYMgGreatInvBurst,LYMgGreatInvHealer,LYMode ~= "PvE") or
		DefensiveOnPlayer(MgMirImage,nil,LYMgMirImageHP,LYMgMirImageBurst,LYMgMirImageHealer,true) or
		ControlCC(MgRingFrost,nil,LYMgRingFrostDR,LYMgRingFrostHealer,LYMgRingFrostHealerHP,LYMgRingFrostTeamBurst,LYMgRingFrostDPS,LYMgRingFrostDPSHP,LYMgRingFrostDPSBurst,LYMgRingFrostCont,LYMgRingFrostFocus,nil,40) or
		ControlCC(MgPoly,nil,LYMgPolyDR,LYMgPolyHealer,LYMgPolyHealerHP,LYMgPolyTeamBurst,LYMgPolyDPS,LYMgPolyDPSHP,LYMgPolyDPSBurst,LYMgPolyCont,LYMgPolyFocus,true,nil,(LYMgPolyWhileBurst and not HaveBuff("player", MgCombust)))  or
		FearCC(MgDB,nil,LYMgDBDR,LYMgDBHealer,LYMgDBHealerHP,LYMgDBTeamBurst,LYMgDBDPS,LYMgDBDPSHP,LYMgDBDPSBurst,LYMgDBCont,nil,nil,8,LYMgDBWhileBurst) or
		SlowTarget(MgSlow,nil,nil,LYSlowAlways) or
		Peel(MgBlastWave,nil,LYPeelAny,LYPeelHealer,8) or
		Peel(MgNova,nil,LYPeelAny,LYPeelHealer,8) or
		Peel(MgSlow,nil,LYPeelAny,LYPeelHealer) or
		Burst() or
		CommonAttack(MgFlameStrike,nil,nil,MgFireBall,HaveBuff("player",MgPyroProc) or (not IsMoving() and LYMode ~= "PvP" and HaveBuff("player",MgFurySunKing)),nil,nil,LYMgFlameStrike) or
		CommonAttack(MgPyroblast,nil,true,MgPyroblast,HaveBuff("player",MgPyroProc) or (not IsMoving() and LYMode ~= "PvP" and HaveBuff("player",MgFurySunKing) and LYLastSpellName ~= MgPyroblast)) or
		ConditionalSpell(MgBlazBar,GCDCheck(MgBlazBar) and EnemyIsTargetingUnit("player") and not HaveBuff("player",MgBlazBar)) or
		ConditionalSpell(MgBlastWave,GCDCheck(MgBlastWave) and EnemiesAroundUnit(8) > 2) or
		AOEAttack(MgMeteor,8,MgFireBall,3,true) or
		ConditionalSpell(MgShiftingPower,GCDCheck(MgShiftingPower) and (not IsMoving() or HaveBuff("player",MgIceFloes)) and not GCDCheck(MgFBlast) and CDLeft(MgCombust) > 15 and not HaveBuff("player",MgCombust)) or
		ConditionalSpell(MgDB,GCDCheck(MgDB) and EnemiesAroundUnit(8,"player",nil,true) > 2) or
		CommonAttack(MgFrArt,nil,true,MgFireBall,not BreakCCAroundUnit() and HaveBuff("player",MgCombust)) or
		DB() or
		CommonAttackTarget(MgLivBomb,nil,true,inRange(MgLivBomb,LYEnemyTarget) and (LYZoneType ~= "arena" or #LYEnemies == 1)) or
		CommonAttackTarget(MgMeteor,nil,nil,GCDCheck(MgMeteor) and inRange(MgFireBall,LYEnemyTarget) and not BreakCCAroundUnit(LYEnemyTarget,10) and (UnitIsStunned(LYEnemyTarget,2) or IsRooted(LYEnemyTarget,2) or UnitIsBoss(LYEnemyTarget))) or
		CommonAttack(MgScorch,nil,true,MgScorch,IsTalentInUse(269644),nil,nil,nil,30) or
		CommonAttackTarget(MgGrPyro,nil,true,GCDCheck(MgGrPyro) and (not IsMoving() or HaveBuff("player",MgIceFloes)) and inRange(MgGrPyro,LYEnemyTarget) and not HaveBuff("player",MgCombust) and (UnitIsCCed(LYEnemyTarget,3) or IsRooted(LYEnemyTarget,3))) or
		CommonAttack(MgFlameStrike,nil,nil,MgFireBall,(not IsMoving() or HaveBuff("player",MgIceFloes)) and not HaveBuff("player",MgCombust),nil,nil,LYMgFlameStrike) or
		CommonAttack(MgFireBall,nil,true,MgFireBall,(not IsMoving() or HaveBuff("player",MgIceFloes)) and (not HaveBuff("player",MgCombust) or HaveBuff("player",MgTinder))) or
		CommonAttack(MgFrArt,nil,true,MgFireBall,not BreakCCAroundUnit()) or
		ConditionalSpell(MgArcExp,IsMoving() and EnemiesAroundUnit(10) > 4) or
		LYDispelAllF(MgDispel) or
		AutoBuffParty(MgArcInt) or
		CommonAttack(MgScorch,nil,true,MgScorch,true) then
			return true
		end
	end
	function LYMageFrost()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,nil,MgFBolt) then
				if GCDCheck(MgIceFloes) and not HaveBuff("player",MgIceFloes) then
					LYQueueSpell(MgIceFloes)
					LY_Print(MgIceFloes,"green",MgIceFloes)
					return true
				end
				if GCDCheck(MgRingFire) and (not IsMoving() or HaveBuff("player",MgIceFloes)) then
					LYQueueSpell(MgRingFire, LYEnemyTarget)
					LY_Print(MgRingFire,"green",MgRingFire)
					return true
				end
				if GCDCheck(MgFrostBomb) then
					LYQueueSpell(MgFrostBomb, LYEnemyTarget)
					LY_Print(MgFrostBomb,"green",MgFrostBomb)
				end
				if GCDCheck(MgVeins) then
					CastSpellByName(MgVeins)
					LY_Print(MgVeins,"green",MgVeins)
				end
				if GCDCheck(MgMirImage) and LYMgMirImageDPS then
					LYQueueSpell(MgMirImage)
					LY_Print(MgMirImage,"green",MgMirImage)
					return true
				end
				if GCDCheck(MgOrb) then
					LYQueueSpell(MgOrb,LYEnemyTarget)
					LY_Print(MgOrb,"green",MgOrb)
					return true
				end
			end
		end
		local function ConeCold()
			if GCDCheck(MgConeCold) and LYStyle ~= "Utilities only" then
				if IsTalentInUse(417493) and IsTalentInUse(84714) and IsTalentInUse(153595) and CDLeft(MgOrb) > 20 and CDLeft(MgComet) > 20 and EnemiesAroundUnit(7,"player",nil,true,true) > 0 then
					LYQueueSpell(MgConeCold,LYEnemies[i])
					return true
				end
				if LYMode ~= "PvE" and HaveBuff("player",MgBurstCold) and not IsTalentInUse(417493) then
					for i=1,#LYEnemies do
						if ValidEnemyUnit(LYEnemies[i]) and IsInDistance(LYEnemies[i],7) and LYFacingCheck(LYEnemies[i]) then
							LYQueueSpell(MgConeCold,LYEnemies[i])
							LY_Print("To Slow Enemy","green",MgConeCold)
							return true
						end
					end
				end
			end
		end
		if CommonKick(MgKick,nil,"kick",true) or
		CommonKick(MgDB,nil,"kick",LYMgDBKick,8) or
		CastKick(MgPoly,LYMgPolyKick,"control") or
		ConditionalSpell(MgAlterTime,CalculateHP("player") < 10 and HaveBuff("player",MgAlterTime)) or
		AntiReflect(MgFBlast) or
		ConditionalSpell(MgColdSnap,GCDCheck(MgLance) and not GCDCheck(MgBlock) and not HaveDebuff("player",MgHypo) and CalculateHP("player") < LYMgBlockHP) or
		ConditionalSpell(MgIceFloes,GCDCheck(MgIceFloes) and IsMoving() and UnitAffectingCombat("player") and BuffCount("player",MgIcicles) > 4 and not HaveBuff("player",MgIceFloes) and SpellChargesCheck(MgIceFloes)) or
		AntiStealth(MgPurge) or
		PauseRotation or
		DefensiveOnPlayer(MgTempShield,nil,LYMgTempShieldHP,LYMgTempShieldBurst,LYMgTempShieldHealer,LYMode ~= "PvE") or
		DefensiveOnPlayer(MgAlterTime,nil,nil,LYMgAlterTimeBurst,LYMgAlterTimeHealer,not HaveBuff("player",MgAlterTime) and LYLastSpellName ~= MgAlterTime and CalculateHP("player") > 40 and GetTime() - LastAlterTime > 3) or
		DefensiveOnTeam(MgMassBar,nil,LYMgMassBarHP,LYMgMassBarBurst,nil,true) or
		MgBlastWaveKnockback() or
		AvoidGapCloser(MgBlastWave,true,8,"magic") or
		AvoidGapCloser(MgNova,true, 8,"magic") or
		AvoidGapCloser(MgDB,true,8,"magic",true) or
		LYDispelAlwaysF(MgDispel) or
		ConditionalSpell(MgIceBarier,GCDCheck(MgIceBarier) and EnemyIsTargetingUnit("player") and not HaveBuff("player",MgIceBarier)) or
		TotemStomp(nil,{MgFBlast,MgLance},40) or
		PurgeForce(MgPurge) or
		PurgeEssential(MgPurge) or
		DefensiveOnPlayer(MgGreatInv,nil,LYMgGreatInvHP,LYMgGreatInvBurst,LYMgGreatInvHealer,LYMode ~= "PvE") or
		DefensiveOnPlayer(MgMirImage,nil,LYMgMirImageHP,LYMgMirImageBurst,LYMgMirImageHealer,true) or
		ControlCC(MgRingFrost,nil,LYMgRingFrostDR,LYMgRingFrostHealer,LYMgRingFrostHealerHP,LYMgRingFrostTeamBurst,LYMgRingFrostDPS,LYMgRingFrostDPSHP,LYMgRingFrostDPSBurst,LYMgRingFrostCont,LYMgRingFrostFocus,nil,40) or
		ControlCC(MgPoly,nil,LYMgPolyDR,LYMgPolyHealer,LYMgPolyHealerHP,LYMgPolyTeamBurst,LYMgPolyDPS,LYMgPolyDPSHP,LYMgPolyDPSBurst,LYMgPolyCont,LYMgPolyFocus,true,nil,(LYMgPolyWhileBurst and not HaveBuff("player",MgFingers) and BuffCount("player",MgIcicles) < 4)) or
		FearCC(MgDB,nil,LYMgDBDR,LYMgDBHealer,LYMgDBHealerHP,LYMgDBTeamBurst,LYMgDBDPS,LYMgDBDPSHP,LYMgDBDPSBurst,LYMgDBCont,nil,nil,8,LYMgDBWhileBurst) or
		SlowTarget(MgConeCold,nil,8,LYSlowAlways and not IsTalentInUse(417493)) or
		SlowTarget(MgSlow,nil,nil,LYSlowAlways) or
		Peel(MgBlastWave,nil,LYPeelAny,LYPeelHealer,8) or
		Peel(MgNova,nil,LYPeelAny,LYPeelHealer,8) or
		Peel(MgPetFreeze,nil,LYPeelAny,LYPeelHealer,8) or
		Peel(MgSlow,nil,LYPeelAny,LYPeelHealer) or
		AutoBuffParty(MgArcInt) or
		Burst() or
		CommonAttack(MgFBolt,nil,true,MgFBolt,HaveBuff("player",MgIceForm,1.4) and (not IsMoving() or HaveBuff("player",MgIceFloes))) or
		CommonAttackTarget(MgGlacSpike,nil,true,inRange(MgFBolt,LYEnemyTarget) and BuffCount("player",MgIcicles) > 4 and not HaveBuff("player",{MgFingers,MgBrainFreeze}) and (not IsMoving() or HaveBuff("player",MgIceFloes)) and HaveDebuff(LYEnemyTarget,MgWintChill)) or
		CommonAttackTarget(MgFlurry,nil,true,HaveBuff("player",MgBrainFreeze) and inRange(MgFBolt,LYEnemyTarget) and not HaveDebuff(LYEnemyTarget,MgWintChill) and (LYLastSpellName == MgFBolt or LYLastSpellName == MgGlacSpike or BuffCount("player",MgIcicles) > 3)) or
		ConeCold() or
		CommonAttackTarget(MgBlizz,nil,nil,HaveBuff("player",MgFreezRain) and inRange(MgFBolt,LYEnemyTarget) and not BreakCCAroundUnit(LYEnemyTarget,10)) or
		CommonAttackTarget(MgComet,nil,true,inRange(MgFBolt,LYEnemyTarget) and HaveDebuff(LYEnemyTarget,MgWintChill)) or
		CommonAttackTarget(MgRayFrost,nil,true,inRange(MgFBolt,LYEnemyTarget) and (not IsMoving() or HaveBuff("player",MgIceFloes)) and HaveDebuff(LYEnemyTarget,MgWintChill) and not HaveBuff("player",MgFingers)) or
		CommonAttackTarget(MgLance,nil,true,inRange(MgFBolt,LYEnemyTarget) and (HaveBuff("player",MgFingers) or HaveDebuff(LYEnemyTarget,MgWintChill))) or
		ConditionalSpell(MgShiftingPower,not IsMoving() and CDLeft(MgOrb) > 12 and CDLeft(MgRayFrost) > 12 and CDLeft(MgVeins) > 12 and UnitAffectingCombat("player")) or
		AOEAttack(MgBlizz,10,MgFBolt,3,not IsMoving()) or
		CommonAttackTarget(MgOrb,nil,true,not GCDCheck(MgRayFrost) and not HaveBuff("player",MgFingers)) or
		ConditionalSpell(MgEle,(not UnitIsVisible("pet") or UnitIsDeadOrGhost("pet")) and CalculateHP("player") > 40) or
		CommonAttack(MgFBolt,nil,true,MgFBolt,(not IsMoving() or HaveBuff("player",MgIceFloes))) or
		CommonAttack(MgIceNova,nil,true,MgFBolt,LYMode == "PvE",nil,nil,3) or
		ConditionalSpell(MgArcExp,IsMoving() and EnemiesAroundUnit(10) > 4) or
		CommonAttack(MgLance,nil,true,MgFBolt,IsMoving()) or
		LYDispelAllF(MgDispel) then
			return true
		end
	end
	function LYMonkBrew()
		local function PureBrew()
			if GCDCheck(MnPureBrew) and LYMnPureBrew ~= 0 and UnitStagger("player") > UnitHealthMax("player")*LYMnPureBrew/100 then
				LYQueueSpell(MnPureBrew)
				return true
			end
		end
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",MnBlackoutStr) then
				if GCDCheck(MnInvNiu) then
					LYQueueSpell(MnInvNiu)
					return true
				end
				if GCDCheck(MnWeaponOrder) then
					LYQueueSpell(MnWeaponOrder)
					return true
				end
			end
		end
		if CommonKick(MnKick,"phys","kick",true) or
		MnDifMagicBuffs() or
		PauseRotation or
		PureBrew() or
		ConditionalSpell(MnChiBrew,LYUP < 25 and GCDCheck(MnChiBrew) and inRange(MnBlackoutStr,LYEnemyTarget) and C_Spell.GetSpellCharges(MnPureBrew).currentCharges < 1 and CDLeft(MnCelBrew) > 30) or
		DefensiveOnPlayer(MnFortElix,nil,LYMnFortElixHP,LYMnFortElixBurst,LYMnFortElixHealer,true) or
		TauntPvP(MnTaunt,843) or
		Taunt(MnTaunt) or
		MnKillShotCast() or
		AntiStealth(MnLightning) or
		CommonKick(MnSap,"all","alt",LYMnSapKick) or
		CommonKick(MnRingPeace,"phys","move",LYMnRingPeaceKick,40) or
		CommonKick(MnLegSwip,"phys","alt",LYMnLegSwipKick,5) or
		LYDispelAlwaysF(MnDetox) or
		TotemStomp({MnBlackoutStr,MnJab}) or
		MnRingPeaceOut() or
		ControlCC(MnSap,"all",LYMnSapDR,LYMnSapHealer,LYMnSapHealerHP,LYMnSapTeamBurst,LYMnSapDPS,LYMnSapDPSHP,LYMnSapDPSBurst,LYMnSapCont,LYMnSapFocus,true) or
		StunCC(MnLegSwip,"phys",LYMnLegSwipDR,LYMnLegSwipHealer,LYMnLegSwipHealerHP,LYMnLegSwipTeamBurst,LYMnLegSwipDPS,LYMnLegSwipDPSHP,LYMnLegSwipDPSBurst,LYMnLegSwipCont,LYMnLegSwipFocus,5) or
		DefensiveOnPlayer(MnTP,nil,LYMnTPHP,LYMnTPBurst,LYMnTPHealer,LYMode ~= "PvE" and TPX and GCDCheck(MnTP) and (not InLineOfSightPointToUnit(TPX,TPY,TPZ) or GetDistancePointToUnit(TPX,TPY,TPZ) > 25) and GetDistancePointToUnit(TPX,TPY,TPZ) < 40) or
		DefensiveOnEnemy(MnExplKeg,"MELEE","phys",LYMnExplKegHP,LYMnExplKegBurst,nil,true) or
		DefensiveOnTeam(MnGuardian,nil,LYMnGuardianHP,LYMnGuardianBurst,15,LYMode ~= "PvE") or
		MnSoothingViv() or
		FreedomCast(MnFreedom,LYMnFreedomHeal,LYMnFreedomHP,LYMnFreedomRoot,LYMnFreedomDPS,true) or
		DefensiveOnPlayer(MnCelBrew,nil,LYMnCelBrewHP,LYMnCelBrewBurst,LYMnCelBrewHealer,(not IsTalentInUse(322510) or HaveBuff("player",MnPureChi))) or
		MnCastStatue(MnBlOxStatue,LYMode ~= "PvP" and not IsMoving()) or
		AOEAttack(MnExplKeg,8,MnLightning,LYMnExplKegCount,true) or
		AOEAttack(MnWhiteTiger,8,MnLightning,3,true) or
		Burst() or
		CommonAttack(MnBlackoutStr,"phys",true,MnBlackoutStr,not HaveBuff("player",MnElusBraw,LYGCDTime)) or
		CommonAttack(MnKegSmash,"phys",true,MnKegSmash,not BreakCCAroundUnit("player",8,true) and (not IsTalentInUse(418359) or BuffCount("player",MnPressAdv) < 10 or EnemiesAroundUnit(MnBlackoutStr) > 2)) or
		ConditionalSpell(MnSpin,not BreakCCAroundUnit("player",10) and inRange(MnBlackoutStr,LYEnemyTarget) and HaveBuff("player",MnCelFlames)) or
		CommonAttack(MnBreath,"magic",true,MnBlackoutStr,true) or
		CommonAttack(MnJadeWind,"magic",nil,MnBlackoutStr,not HaveBuff("player",MnJadeWind,2)) or
		CommonAttack(MnSunKick,"phys",true,MnSunKick,true) or
		CommonAttack(MnBlackoutStr,"phys",true,MnBlackoutStr,true) or
		CommonAttack(MnChiWave,"magic",nil,MnChiWave,not BreakCCAroundUnit() and (LYMode ~= "PvE" or IsInBossFight())) or
		CommonAttack(MnBoneBrew,"magic",nil,MnBlackoutStr,GCDCheck(MnBoneBrew),nil,nil,3) or
		ConditionalSpell(MnChiBurst,GCDCheck(MnChiBurst) and inRange(MnBlackoutStr,LYEnemyTarget) and not IsMoving() and LYFacingCheck(LYEnemyTarget)) or
		ConditionalSpell(MnSpin,EnemiesAroundUnit(MnBlackoutStr) >= LYMnSpin) or
		CommonAttack(MnJab,"phys",true,MnBlackoutStr,not IsTalentInUse(418359) and TimeToEnergy(65) < CDLeft(MnKegSmash)) or
		CommonAttackTarget(MnBoneBrew,"magic",true,GCDCheck(MnBoneBrew) and inRange(MnBlackoutStr,LYEnemyTarget) and (UnitIsBoss(LYEnemyTarget) or (UnitIsPlayer(LYEnemyTarget) and CalculateHP(LYEnemyTarget) < 50)) and UnitAffectingCombat(LYEnemyTarget)) or
		LYDispelAllF(MnDetox)then
			return true
		end
	end
	function LYMonkMist()
		local function StopCast()
			if LYStyle ~= "Utilities only" and (UnitCastingInfo("player") == MnEMist or UnitCastingInfo("player") == MnUplift) then
				LYSpellStopCasting()
				return true
			end
		end
		local function SoothingMist()
			if GCDCheck(MnSoothMist) and LYStyle ~= "Utilities only" and not IsMoving() then
				for i=1,#LYTeamPlayers do
					if not UnitChannelInfo("player") then
						if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 98 and (LYMode ~= "PvE" or UnitIsTank(LYTeamPlayers[i]) or CalculateHP(LYTeamPlayers[i]) < 85) then
							if LYMode ~= "PvE" and GCDCheck(MnZenTea) and PartyHPBelow(LYMnZenTea) and EnemyCanKick() then
								CastSpellByName(MnZenTea)
							end
							LYSpellStopCasting()
							LYQueueSpell(MnSoothMist,LYTeamPlayers[i])
							return true
						end
					elseif UnitChannelInfo("player") == MnSoothMist and UnitIsVisible(MnSMistUnit) and ((CalculateHP(LYTeamPlayers[i]) + 10 < CalculateHP(MnSMistUnit)) or CalculateHP(MnSMistUnit) > 99) then
						LYSpellStopCasting()
						return true
					end
				end
			end
		end
		local function ChiBurst()
			if GCDCheck(MnChiBurst) and LYStyle ~= "Utilities only" and not IsMoving() then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 85 and (UnitIsUnit("player",LYTeamPlayers[i]) or not UnitsCCedOnPathTo(LYTeamPlayers[i])) and IsLookingAt(LYTeamPlayers[i]) then
						LYQueueSpell(MnChiBurst,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function Sphere(prio)
			if GCDCheck(MnSphere) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and LYLastSpellName ~= MnSphere then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and ((not prio and CalculateHP(LYTeamPlayers[i]) < 90) or (prio and HaveDebuff(LYTeamPlayers[i],{WlUnstable,PrVTouch}))) and not IsMoving(LYTeamPlayers[i]) then
						LYQueueSpell(MnSphere,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function EMist()
			if GCDCheck(MnEMist) and LYStyle ~= "Utilities only" and (UnitChannelInfo("player") == MnSoothMist or BuffCount("player",MnChiJiBuff) > 2 or HaveBuff("player",MnThunderTea)) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 90 and not HaveBuff(LYTeamPlayers[i],MnEMist,2,"player") then
						if GCDCheck(MnThunderTea) and CalculateHP(LYTeamPlayers[i]) < 50 and not HaveBuff("player",MnThunderTea) then
							CastSpellByName(MnThunderTea)
						end
						LYQueueSpell(MnEMist,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function Uplift()
			if GCDCheck(MnUplift) and LYStyle ~= "Utilities only" then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 85 and (HaveBuff(LYTeamPlayers[i],MnSoothMist,0.5,"player") or HaveBuff("player",MnVivaViv)) then
						LYQueueSpell(MnUplift,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function PreHot()
			if GCDCheck(MnRenewMist) and LYZoneType == "arena" and not UnitAffectingCombat("player") and CalculateMP("player") > 95 and not HaveBuff("player",ArenaPrepBuff) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],MnRenewMist,5,"player") then
						LYQueueSpell(MnRenewMist,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function ZenSphere()
			if GCDCheck(MnZenSphere) then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and FriendIsUnderAttack(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],MnSphereHope) then
						local SHUnit = AnyFriendHasBuff(MnSphereHope)
						if not UnitIsVisible(SHUnit) or (CalculateHP(LYTeamPlayers[i]) + 15 < CalculateHP(SHUnit)) then
							LYQueueSpell(MnZenSphere,LYTeamPlayers[i])
							return true
						end
					end
				end
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and EnemyIsUnderAttack(LYEnemies[i]) and not HaveBuff(LYTeamPlayers[i],MnSphereDespair) then
						local SDUnit = AnyEnemyHasDebuff(MnSphereDespair)
						if not UnitIsVisible(SDUnit) or (CalculateHP(LYEnemies[i]) + 15 < CalculateHP(SDUnit)) then
							LYQueueSpell(MnZenSphere,LYEnemies[i])
							return true
						end
					end
				end
			end
		end
		local function ZenPulse()
			if GCDCheck(MnDzen) then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 90 and FriendIsUnderAttack(LYTeamPlayers[i],"MELEE") then
						LYQueueSpell(MnDzen,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function CheckChiJiActive()
			if IsTalentInUse(325197) and UnitAffectingCombat("player") then
				for i=1,4 do
					local totem = select(5,GetTotemInfo(i))
					if totem and totem == 877514 then
						return true
					end
				end
			end
		end
		local function CancelSpin()
			if UnitChannelInfo("player") == MnSpin and PartyHPBelow(60) then
				SpellStopCasting()
				return true
			end
		end
		local function FaelStomp()
			if GCDCheck(MnFaelStomp) and LYStyle ~= "Utilities only" and not IsMoving() and not BreakCCAroundUnit() and ((IsTalentInUse(388740) and not HaveBuff("player",MnAncConc)) or (IsTalentInUse(388023) and not HaveBuff("player",MnAncTeach,1))) and not HaveBuff("player",MnFaelStomp) then
				local range = MnSap
				if not IsTalentInUse(115078) then
					range = 19
				end
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and inRange(range,LYEnemies[i]) then
						LYQueueSpell(MnFaelStomp,LYEnemies[i],"force")
						return true
					end
				end
			end
		end
		if CancelSpin() or
		LYDispel(MnDispel) or
		StopCast() or
		TauntCC(MnTaunt) or
		CommonKick(MnKick,"phys","kick",true) or
		CommonKick(MnSap,"all","alt",LYMnSapKick) or
		CommonKick(MnRingPeace,"phys","move",LYMnRingPeaceKick,40) or
		MnDifMagicBuffs() or
		MnKillShotCast() or
		AntiStealth(MnLightning) or
		TripleCC(MnLegSwip,LYMnLegSwipTrpl,5) or
		CommonKick(MnLegSwip,"phys","alt",LYMnLegSwipKick,5) or
		CastBeforeSpell(MnThunderTea,MnSunKick,(LYHDPS or HaveBuff("player",MnAncTeach)) and not HaveBuff("player",MnThunderTea)) or
		PauseRotation or
		DefensiveOnTeam(MnCocoon,nil,LYMnCocoonHP,LYMnCocoonBurst,nil,true) or
		DefensiveOnPlayer(MnFortElix,nil,LYMnFortElixHP,LYMnFortElixBurst,LYMnFortElixHealer,LYMode ~= "PvE") or
		DefensiveOnPlayer(MnDifMagic,"WIZARD",LYMnDifMagHP,LYMnDifMagBurst,LYMnDifMagHealer,true) or
		ResDeadFriend() or
		PreHot() or
		ConditionalSpell(MnInvokeChi,LYHDPS and EnemiesAroundUnit(MnJab) > 0) or
		ConditionalSpell(MnRefWind,GCDCheck(MnRefWind) and TeamMembersAroundUnit(10,"player",85) >= 3) or
		ConditionalSpell(MnRevival,GCDCheck(MnRevival) and (PartyHPBelow(LYMnRevivalHP) or TeamMembersAroundUnit(nil,"player",LYMnRevivalAOEHP) >= LYMnRevivalAOE)) or
		ConditionalSpell(MnRestoral,GCDCheck(MnRestoral) and (PartyHPBelow(LYMnRestoralHP) or TeamMembersAroundUnit(nil,"player",LYMnRestoralAOEHP) >= LYMnRestoralAOE)) or
		ConditionalSpell(MnInvokeYulon,GCDCheck(MnInvokeYulon) and ((EnemyIsBursting() and LYMnInvokeYulonBurst) or PartyHPBelow(LYMnInvokeYulonHP) or TeamMembersAroundUnit(nil,"player",LYMnInvokeYulonAOEHP) >= LYMnInvokeYulonAOE)) or
		MnRingPeaceOut() or
		SlowTarget(MnDisable,"phys",nil,LYSlowAlways or (IsTalentInUse(388193) and IsTalentInUse(388023))) or
		CommonAttackTarget(MnDisable,"phys",true,LYMode ~= "PvE" and LYMnDisableRoot and UnitIsPlayer(LYEnemyTarget) and inRange(MnDisable,LYEnemyTarget) and HaveDebuff(LYEnemyTarget,MnDisable,LYGCDTime) and not UnitIsCCed(LYEnemyTarget) and (IsBursting(LYEnemyTarget) or IsBursting()) and IsMoving(LYEnemyTarget) and CheckUnitDR(LYEnemyTarget,"root")) or
		ControlCC(MnSap,"all",LYMnSapDR,LYMnSapHealer,LYMnSapHealerHP,LYMnSapTeamBurst,LYMnSapDPS,LYMnSapDPSHP,LYMnSapDPSBurst,LYMnSapCont,LYMnSapFocus,true) or
		StunCC(MnLegSwip,"phys",LYMnLegSwipDR,LYMnLegSwipHealer,LYMnLegSwipHealerHP,LYMnLegSwipTeamBurst,LYMnLegSwipDPS,LYMnLegSwipDPSHP,LYMnLegSwipDPSBurst,LYMnLegSwipCont,LYMnLegSwipFocus,5) or
		Disarm(MnDisarm,LYMnDisarmHP,LYMnDisarmBurst,LYMnDisarmHealer,LYMnDisarmFocus) or
		DefensiveOnPlayer(MnTP,nil,LYMnTPHP,LYMnTPBurst,LYMnTPHealer,LYMode ~= "PvE" and TPX and (not InLineOfSightPointToUnit(TPX,TPY,TPZ) or GetDistancePointToUnit(TPX,TPY,TPZ) > 25) and GetDistancePointToUnit(TPX,TPY,TPZ) < 40) or
		FreedomCast(MnFreedom,LYMnFreedomHeal,LYMnFreedomHP,LYMnFreedomRoot,LYMnFreedomDPS,true) or
		CommonHeal(MnRenewMist,(not PartyHPBelow(50) or IsMoving()),95,6) or
		ConditionalSpell(MnMTea,GCDCheck(MnMTea) and CalculateMP("player") < 90 and UnitAffectingCombat("player") and not PartyHPBelow(70)) or
		FaelStomp() or
		CommonAttack(MnWhiteTiger,"phys",true,MnSunKick,LYHDPS) or
		CommonAttack(MnSunKick,"phys",true,MnSunKick,LYHDPS or HaveBuff("player",MnAncTeach) or CheckChiJiActive() or IsTalentInUse(274909)) or
		CommonAttack(MnBlackout,"phys",true,MnBlackout,(LYHDPS or HaveBuff("player",MnAncTeach) or CheckChiJiActive()) and (not IsTalentInUse(116645) or BuffCount("player",MnTeachMonaster) > 3)) or
		ConditionalSpell(MnSpin,not PartyHPBelow(70) and (LYHDPS or (IsTalentInUse(388779) and HaveBuff("player",MnFaelStomp)) or CheckChiJiActive()) and ((not HaveBuff("player",MnAncTeach) and EnemiesAroundUnit(7) > 1) or (HaveBuff("player",MnAncTeach) and EnemiesAroundUnit(7) > 2))) or
		CommonAttack(MnJab,"phys",true,MnBlackout,LYHDPS or HaveBuff("player",MnAncTeach)) or
		ConditionalSpell(MnInvokeChi,IsTalentInUse(388023) and EnemiesAroundUnit(MnJab) > 0) or
		Sphere(true) or
		CommonHeal(MnSheilun,not IsMoving() and GCDCheck(MnSheilun) and C_Spell.GetSpellCastCount(MnSheilun) > 9 and (not PartyHPBelow(35) or not EnemyCanKick()),75) or
		EMist() or
		SoothingMist() or
		MnCastStatue(MnStatue,true) or
		Uplift() or
		ZenSphere() or
		ChiBurst() or
		CommonHeal(MnChiWave,true,90) or
		ZenPulse() or
		Sphere() or
		TotemStomp({MnBlackout,MnSunKick,MnJab}) or
		CommonAttack(MnSunKick,"phys",true,MnSunKick,CalculateMP("player") > LYHealerDPS) or
		CommonAttack(MnBlackout,"phys",true,MnBlackout,CalculateMP("player") > LYHealerDPS) or
		CommonAttack(MnJab,"phys",true,MnJab,CalculateMP("player") > LYHealerDPS) or
		CommonAttack(MnLightning,"magic",true,MnLightning,LYHDPS) then
			return true
		end
	end
	function LYMonkWind()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",MnBlackout) then
				if GCDCheck(MnXuen) then
					LYQueueSpell(MnXuen,LYEnemyTarget)
					LY_Print(MnXuen,"green",MnXuen)
					return true
				end
				if GCDCheck(MnCopy) and not HaveBuff("player",MnCopy) and IsGCDReady() then
					LYQueueSpell(MnCopy,LYEnemyTarget)
					LY_Print(MnCopy,"green",MnCopy)
					return true
				end
				if GCDCheck(MnSerenity) then
					LYQueueSpell(MnSerenity,LYEnemyTarget)
					LY_Print(MnSerenity,"green",MnSerenity)
					return true
				end
				if GCDCheck(MnTigerBrew) and LYMnTigerBrewBurst and not HaveBuff("player",247483) then
					LYQueueSpell(MnTigerBrew)
					LY_Print(MnTigerBrew,"green",MnTigerBrew)
					return true
				end
				if GCDCheck(MnWhiteTiger) and not BreakCCAroundUnit() then
					LYQueueSpell(MnWhiteTiger,LYEnemyTarget)
					LY_Print(MnWhiteTiger,"green",MnWhiteTiger)
					return true
				end
			end
		end
		local function FocusCopiesOnTarget()
			if GCDCheck(MnCopy) and HaveBuff("player",MnCopy) and UnitIsVisible(LYEnemyTarget) then
				CastSpellByName(MnCopy,LYEnemyTarget)
				return true
			end
		end
		local function JadeWindCancel()
			if HaveBuff("player",MnJadeWind) and LYStyle ~= "Utilities only" and EnemiesAroundUnit(10) < 2 then
				CancelBuffByName(MnJadeWind)
			end
		end
		local function RootTarget()
			if GCDCheck(MnDisable) and LYMode ~= "PvE" and LYMnDisableRoot and UnitIsVisible(LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and inRange(MnDisable,LYEnemyTarget) and SpellAttackTypeCheck(LYEnemyTarget,"phys") and HaveDebuff(LYEnemyTarget,MnDisable,LYGCDTime) and not UnitIsCCed(LYEnemyTarget) and (IsBursting(LYEnemyTarget) or IsBursting()) and IsMoving(LYEnemyTarget) and CheckUnitDR(LYEnemyTarget,"root") and LYFacingCheck(LYEnemyTarget) then
				LYQueueSpell(MnDisable,LYEnemyTarget)
				return true
			end
		end
		local function FaelStomp()
			if GCDCheck(MnFaelStomp) and not BreakCCAroundUnit() then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and inRange(MnBlackout,LYEnemies[i]) and (not HaveBuff("player",MnFaelStomp) or (IsTalentInUse(391412) and not not HaveDebuff(LYEnemies[i],MnFaelExp))) and LYFacingCheck(LYEnemies[i]) then
						LYQueueSpell(MnFaelStomp,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function Spin()
			if GCDCheck(MnSpin) and LYLastSpellName ~= MnSpin and not DoNotUsePower and GCDCheck(MnSpin) and (HaveBuff("player",MnDanceChi) or (CDLeft(MnFists) > 2 and EnemiesAroundUnit(8) >= LYMnSpin)) and not BreakCCAroundUnit("player",10) and inRange(MnBlackout,LYEnemyTarget) then
				if GCDCheck(MnBoneBrew) then
					LYQueueSpell(MnBoneBrew,"player")
					return true
				end
				LYQueueSpell(MnSpin)
				return true
			end
		end
		if CommonKick(MnKick,"phys","kick",LYMode ~= "PvE" or not UnitChannelInfo("player")) or
		TauntCC(MnTaunt) or
		MnDifMagicBuffs() or
		PauseRotation or
		MnKillShotCast() or
		JadeWindCancel() or
		DefensiveOnPlayer(MnFortElix,nil,LYMnFortElixHP,LYMnFortElixBurst,LYMnFortElixHealer,LYMode ~= "PvE") or
		DefensiveOnPlayer(MnDifMagic,"WIZARD",LYMnDifMagHP,LYMnDifMagBurst,LYMnDifMagHealer,true) or
		CommonKick(MnSap,"all","alt",LYMnSapKick) or
		CommonKick(MnRingPeace,"phys","move",LYMnRingPeaceKick,40) or
		CommonKick(MnLegSwip,"phys","alt",LYMnLegSwipKick,5) or
		FocusCopiesOnTarget() or
		AntiStealth(MnLightning) or
		TripleCC(MnLegSwip,LYMnLegSwipTrpl,5) or
		LYDispelAlwaysF(MnDetox) or
		TotemStomp({MnBlackout,MnJab}) or
		BreakCCMG(MnChiWave,true) or
		MnRingPeaceOut() or
		SlowTarget(MnDisable,"phys",nil,LYSlowAlways) or
		RootTarget() or
		ControlCC(MnSap,"all",LYMnSapDR,LYMnSapHealer,LYMnSapHealerHP,LYMnSapTeamBurst,LYMnSapDPS,LYMnSapDPSHP,LYMnSapDPSBurst,LYMnSapCont,LYMnSapFocus,true) or
		StunCC(MnLegSwip,"phys",LYMnLegSwipDR,LYMnLegSwipHealer,LYMnLegSwipHealerHP,LYMnLegSwipTeamBurst,LYMnLegSwipDPS,LYMnLegSwipDPSHP,LYMnLegSwipDPSBurst,LYMnLegSwipCont,LYMnLegSwipFocus,5) or
		DefensiveOnPlayer(MnTP,nil,LYMnTPHP,LYMnTPBurst,LYMnTPHealer,LYMode ~= "PvE" and TPX and GCDCheck(MnTP) and (not InLineOfSightPointToUnit(TPX,TPY,TPZ) or GetDistancePointToUnit(TPX,TPY,TPZ) > 25) and GetDistancePointToUnit(TPX,TPY,TPZ) < 40) or
		MnSoothingViv() or
		PlayerDefensiveOnEnemy(MnKarma,nil,"magic",LYMnKarmaHP,LYMnKarmaBurst,nil,true) or
		Disarm(MnDisarm,LYMnDisarmHP,LYMnDisarmBurst,LYMnDisarmHealer,LYMnDisarmFocus) or
		Peel(MnDisable,"phys",LYPeelAny,LYPeelHealer) or
		FreedomCast(MnFreedom,LYMnFreedomHeal,LYMnFreedomHP,LYMnFreedomRoot,LYMnFreedomDPS,true) or
		FaelStomp() or
		Burst() or
		CommonAttack(MnJab,"phys",true,MnJab,IsPvPTalentInUse(3734) and LYLastSpellName ~= MnJab and not HaveBuff("player",MnAlphaTiger) and (LYCP < LYCPMax - 1 or HaveBuff("player",MnSerenity)),0,MnChanllenged) or
		CommonAttack(MnStrkWindlord,"phys",true,MnBlackout,true) or
		CommonAttackTarget(MnFists,"phys",true,inRange(MnBlackout,LYEnemyTarget) and (UnitIsPlayer(LYEnemyTarget) or LYMode ~= "PvP") and not BreakCCAroundUnit("player",10,true) and not DoNotUsePower) or
		CommonAttack(MnDragPunch,"phys",nil,MnBlackout,not IsMoving() and not BreakCCAroundUnit("player",8)) or
		ConditionalSpell(MnJadeWind,GCDCheck(MnJadeWind) and not HaveBuff("player",MnJadeWind) and EnemiesAroundUnit(8) > 2) or
		Spin() or
		CommonAttack(MnBlackout,"phys",true,MnBlackout,LYLastSpellName ~= MnBlackout and not DoNotUsePower and HaveBuff("player",MnBlackReinf)) or
		CommonAttack(MnSunKick,"phys",true,MnSunKick,not GCDCheck(MnFists) and not DoNotUsePower) or
		CommonAttack(MnJab,"phys",true,MnJab,(LYLastSpellName ~= MnJab or DoNotUsePower) and LYCP < LYCPMax - 1 and not HaveBuff("player",MnSerenity)) or
		CommonAttack(MnBlackout,"phys",true,MnBlackout,LYLastSpellName ~= MnBlackout and not DoNotUsePower and ((CDLeft(MnSunKick) > 1 and CDLeft(MnFists) > 1 and (LYUP > 30 or LYCP == LYCPMax)) or BuffCount("player",MnTeachMonaster) > 2 or HaveBuff("player",{MnComboBlackout,MnSerenity}))) or
		ConditionalSpell(MnChiBurst,GCDCheck(MnChiBurst) and UnitIsVisible(LYEnemyTarget) and inRange(MnBlackout,LYEnemyTarget) and not IsMoving() and LYFacingCheck(LYEnemyTarget)) or
		CommonAttack(MnChiWave,"magic",nil,MnChiWave,not BreakCCAroundUnit() and (not IsBursting() or EnemiesAroundUnit(MnJab) < 1)) or
		CommonAttack(MnJab,"phys",true,MnJab,LYCP < 2) or
		CommonAttack(MnLightning,"magic",true,MnLightning,not IsMoving() and BuffCount("player",MnEmpCapac) > 19) or
		LYDispelAllF(MnDetox) then
			return true
		end
	end
	function LYPaladinHoly()
		local function Beacon()
			if GCDCheck(PlBeacon) and LYPlBeacon and not IsTalentInUse(200025) then
				if LYPlBeaconSelf and not HaveBuff("player",{PlBeacon,PlBeacon2},0,"player") then
					if IsTalentInUse(156910) then
						LYQueueSpell(PlBeacon2,"player")
						return true
					else
						LYQueueSpell(PlBeacon,"player")
						return true
					end
				end
				if not IsTalentInUse(156910) and LYPlBeaconSelf then
					return
				end
				local beac1 = AnyFriendHasBuff(PlBeacon)
				local beac2 = nil
				if IsTalentInUse(156910) then
					beac2 = AnyFriendHasBuff(PlBeacon2)
				end
				if LYMode ~= "PvP" then
					if not UnitIsVisible(beac1) then
						for i=1,#LYTeamPlayers do
							if UnitIsVisible(LYTeamPlayers[i]) and UnitIsTank(LYTeamPlayers[i],"main") and not HaveBuff(LYTeamPlayers[i],PlBeacon2,0,"player") then
								LYQueueSpell(PlBeacon,LYTeamPlayers[i])
								return true
							end
						end
					end
					if IsTalentInUse(156910) and not LYPlBeaconSelf and not UnitIsVisible(beac2) then
						if LYZoneType == "raid" then
							for i=1,#LYTeamPlayers do
								if UnitIsVisible(LYTeamPlayers[i]) and UnitIsTank(LYTeamPlayers[i],"off") and not HaveBuff(LYTeamPlayers[i],PlBeacon,0,"player") then
									LYQueueSpell(PlBeacon2,LYTeamPlayers[i])
									return true
								end
							end
						elseif not HaveBuff("player",PlBeacon,0,"player") then
							LYQueueSpell(PlBeacon2,"player")
							return true
						end
					end
				else
					if not UnitIsVisible(beac1) or CalculateHP(beac1) > 90 then
						for i=1,#LYTeamPlayers do
							if (FriendIsUnderAttack(LYTeamPlayers[i]) or HaveBuff(LYTeamPlayers[i],ArenaPrepBuff)) and not HaveBuff(LYTeamPlayers[i],{PlBeacon,PlBeacon2},0,"player") and (not UnitIsVisible(beac1) or CalculateHP(LYTeamPlayers[i]) + 20 < CalculateHP(beac1)) then
								LYQueueSpell(PlBeacon,LYTeamPlayers[i])
								return true
							end
						end
					end
					if IsTalentInUse(156910) and not LYPlBeaconSelf and (not UnitIsVisible(beac2) or CalculateHP(beac2) > 90) then
						for i=1,#LYTeamPlayers do
							if (FriendIsUnderAttack(LYTeamPlayers[i]) or HaveBuff(LYTeamPlayers[i],ArenaPrepBuff)) and not HaveBuff(LYTeamPlayers[i],{PlBeacon,PlBeacon2},0,"player") and (not UnitIsVisible(beac2) or CalculateHP(LYTeamPlayers[i]) + 20 < CalculateHP(beac2)) then
								LYQueueSpell(PlBeacon2,LYTeamPlayers[i])
								return true
							end
						end
					end
				end
			end
		end
		local function Martyr(hp)
			if GCDCheck(PlMartyr) and LYZoneType ~= "raid" and LYStyle ~= "Utilities only" then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < hp and CalculateHP(LYTeamPlayers[i]) + 15 < CalculateHP("player") then
						LYQueueSpell(PlMartyr,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function LightDawn()
			if GCDCheck(PlLightDawn) and LYStyle ~= "Utilities only" then
				local dist = 14
				if IsTalentInUse(387879) then
					dist = 40
				end
				local count = TeamMembersAroundUnit(dist,"player",85,nil,true)
				if count > 2 or (count > 0 and BuffCount("player",PlDarkDawn) > 4) then
					LYQueueSpell(PlLightDawn)
					return true
				end
			end
		end
		local function ConsRoot()
			if GCDCheck(PlConsec) and IsPvPTalentInUse(3618) then
				if HaveDebuff("player",listDispelRoots,2) then
					LYQueueSpell(PlConsec)
					return true
				end
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and HaveDebuff(LYTeamPlayers[i],listDispelRoots,LYDispelRoot) and CheckRole(LYTeamPlayers[i]) == "MELEE" and select(2,UnitClass(LYTeamPlayers[i])) ~= "DRUID" and IsInDistance(LYTeamPlayers[i],8) then
						LYQueueSpell(PlConsec)
						return true
					end
				end
			end
		end
		local function Blessings()
			if not IsTalentInUse(388007) then
				return
			end
			if GCDCheck(PlBlessSpr) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and FriendIsUnderAttack(LYTeamPlayers[i]) and UnitIsPlayer(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],listPlSBlessings) and (UnitIsTank(LYTeamPlayers[i]) or (LYMode ~= "PvE" and CalculateHP(LYTeamPlayers[i]) < 50)) then
						LYQueueSpell(PlBlessSpr,LYTeamPlayers[i])
						LY_Print(PlBlessSpr.." @team member","green",PlBlessSpr)
						return true
					end
				end
			elseif GCDCheck(PlBlessWin) then
				if UnitAffectingCombat("player") and CalculateMP("player") < 80 and not HaveBuff("player",listPlSBlessings) then
					LYQueueSpell(PlBlessWin,"player")
					return true
				end
			elseif GCDCheck(PlBlessAut) then
				if CDLeft(PlWings) > 45 and not HaveBuff("player",listPlSBlessings) then
					LYQueueSpell(PlBlessAut,"player")
					LY_Print(PlBlessAut.." @self","green",PlBlessAut)
					return true
				end
			elseif GCDCheck(PlBlessSum) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and IsBursting(LYTeamPlayers[i]) and not IsWizzard(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],listPlSBlessings) then
						LYQueueSpell(PlBlessSum,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		if LYDispel(PlDispel) or
		CommonKick(PlKick,"magic","kick",true) or
		PlSacCC() or
		TauntCC(PlTaunt) or
		PlLoHCast() or
		AntiStealth(PlShock) or
		CommonKick(PlHoJ,"magic","alt",LYPlHoJKick) or
		CommonKick(PlBlind,"magic","alt",LYPlBlindKick,9) or
		TripleCC(PlBlind,LYPlBlindAOE,9) or
		StunCC(PlHoJ,"magic",LYPlHoJDR,LYPlHoJHealer,LYPlHoJHealerHP,LYPlHoJTeamBurst,LYPlHoJDPS,LYPlHoJDPSHP,LYPlHoJDPSBurst,LYPlHoJCont,LYPlHoJFocus) or
		FearCC(PlBlind,"magic",LYPlBlindDR,LYPlBlindHealer,LYPlBlindHealerHP,LYPlBlindTeamBurst,LYPlBlindDPS,LYPlBlindDPSHP,LYPlBlindDPSBurst,nil,nil,nil,9) or
		PauseRotation or
		ConditionalSpell(PlDivFavor,LYMode ~= "PvE" and GCDCheck(PlDivFavor) and not IsMoving() and PartyHPBelow(LYPlDivFavor) and HaveBuff("player",PlLightInf) and not HaveBuff("player",PlBuble)) or
		PlSacHP() or
		DefensiveOnTeam(PlWings,nil,LYPlWingsHP,LYPlWingsBurst,nil,not HaveBuff("player",listHPalBurst)) or
		ConditionalSpell(PlWings,GCDCheck(PlWings) and not HaveBuff("player",listHPalBurst) and TeamMembersAroundUnit(nil,"player",LYPlWingsAOEHP) >= LYPlWingsAOEUnits) or
		DefensiveOnTeam(PlAvenger,nil,LYPlAvenHP,LYPlAvenBurst,nil,not HaveBuff("player",listHPalBurst)) or
		ConditionalSpell(PlAvenger,GCDCheck(PlAvenger) and not HaveBuff("player",listHPalBurst) and TeamMembersAroundUnit(nil,"player",LYPlAvengAOEHP) >= LYPlAvenAOEUnits) or
		CommonHeal(PlHandDiv,not HaveBuff("player",listHPalBurst) and not IsMoving(),LYPlHandDivHP) or
		BRDeadFriend() or
		ResDeadFriend() or
		CommonAttack(PlJudg,"magic",true,PlJudg,(HaveBuff("player",PlAvenCrus) or LYHDPS)) or
		CommonAttack(PlCrusader,"phys",true,PlCrusader,(HaveBuff("player",PlAvenCrus) or LYHDPS)) or
		CommonAttack(PlShock,"magic",true,PlShock,LYHDPS) or
		CommonAttack(PlWrathHam,"magic",true,PlWrathHam,((LYHDPS and HaveBuff("player",PlWings)) or HaveBuff("player",PlVeneration)) and LYUP < 5) or
		CommonAttack(PlShieldRight,"magic",true,PlCrusader,LYHDPS and LYMode ~= "PvP") or
		PlCastSearingGlare() or
		DefensiveOnTeam(PlMA,nil,LYPlMAHP,LYPlMABurst,nil,not HaveBuff("player",listHPalBurst)) or
		DefensiveOnTeam(PlTyrDev,nil,LYPlTyrDevHP,LYPlTyrDevBurst,nil,not HaveBuff("player",listHPalBurst) and not IsMoving()) or
		ConditionalSpell(PlMA,GCDCheck(PlMA) and not HaveBuff("player",listHPalBurst) and TeamMembersAroundUnit(nil,"player",LYPlMAAOEHP) >= LYPlMAAOEUnits) or
		CommonHeal(PlShock,true,35) or
		CommonHeal(PlGlory,true,35) or
		LightDawn() or
		CommonHeal(PlHolyLight,not IsMoving() and HaveBuff("player",{PlDivFavor,PlHandDiv}),90) or
		AOEHeal(PlTyrDev,nil,LYPlTyrDevAOEHP,LYPlTyrDevAOEUnits,not IsMoving()) or
		AOEHeal(PlBeacon,30,85,3,IsTalentInUse(200025)) or
		AOEHeal(PlHolyPrizm,15,85,3,true) or
		AOEHeal(PlDivToll,30,85,3,true) or
		CommonHeal(PlFlash,not IsMoving() and HaveBuff("player",PlLightInf),LYPlFlash) or
		CommonHeal(PlShock,LYUP < 5,95) or
		CommonHeal(PlGlory,true,LYPlGloryHP) or
		CommonHeal(PlDivToll,true,50) or
		CommonHeal(PlHolyPrizm,not BreakCCAroundUnit("player",15),80) or
		CommonHeal(PlSacShield,true,95) or
		CommonHeal(PlBarFaith,true,95) or
		FreedomCast(PlFreedom,LYPlFreedomHeal,LYPlFreedomHP,LYPlFreedomRoot,LYPlFreedomDPS,true) or
		ConsRoot() or
		Martyr(LYPlMartyr) or
		Blessings() or
		TotemStomp({PlCrusader},{PlJudg,PlShock},30) or
		PlWrathHamCast() or
		CommonAttack(PlShieldRight,"magic",true,PlCrusader,LYMode ~= "PvP" and LYUP > 4) or
		CommonAttack(PlCrusader,"phys",true,PlCrusader,CalculateMP("player") > LYHealerDPS and (LYUP < 5 or (not GCDCheck(PlShock) and IsTalentInUse(196926)))) or
		ControlCC(PlRep,"magic",LYPlRepDR,LYPlRepHealer,LYPlRepHealerHP,LYPlRepTeamBurst,LYPlRepDPS,LYPlRepDPSHP,LYPlRepDPSBurst,LYPlRepCont,LYPlRepFocus,true) or
		Beacon() or
		CommonHeal(PlShock,IsTalentInUse(325966),95,PlGlimmer) or
		CommonAttack(PlJudg,"magic",true,PlJudg,true) or
		ConditionalSpell(PlConsec,GCDCheck(PlConsec) and UnitAffectingCombat("player") and not IsMoving() and ((IsTalentInUse(379008) and not HaveBuff("player",PlConsec)) or EnemiesAroundUnit(PlCrusader,"player",PlConsec) > 0)) or
		CommonHeal(PlHolyLight,not IsMoving(),LYPlHolyLight) or
		Martyr(85) or
		PlAuras() then
			return true
		end
	end
	function LYPaladinProt()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",PlJudg) then
				if GCDCheck(PlWings) then
					LYQueueSpell(PlWings)
					LY_Print(PlWings,"green")
					return true
				end
				if GCDCheck(PlAvenger) then
					LYQueueSpell(PlAvenger)
					LY_Print(PlAvenger,"green")
					return true
				end
				if GCDCheck(PlBastLight) then
					LYQueueSpell(PlBastLight)
					LY_Print(PlBastLight,"green")
					return true
				end
				if GCDCheck(PlMomGlory) and CDLeft(PlAvShield) > 10 then
					LYQueueSpell(PlMomGlory)
					LY_Print(PlMomGlory,"green")
					return true
				end
			end
		end
		local function FreedomConsec()
			if GCDCheck(PlConsec) and LYStyle ~= "Utilities only" and IsPvPTalentInUse(90) and not BreakCCAroundUnit("player",12) then
				for i=1,#LYTeamPlayers do
					if HaveDebuff(LYTeamPlayers[i],listShiftSlow) and IsInDistance(LYTeamPlayers[i],10) then
						LYQueueSpell(PlConsec)
						return true
					end
				end
			end
		end
		if CommonKick(PlKick,"magic","kick",true) or
		PlSacCC() or
		CastKick(PlRep,LYPlRepKick,"control") or
		PlLoHCast() or
		PauseRotation or
		DefensiveOnPlayer(PlDefender,nil,LYPlDefenderHP,LYPlDefenderBurst,LYPlDefenderHealer,true) or
		DefensiveOnPlayer(PlGuardKings,nil,LYPlGuardKingsHP,LYPlGuardKingsBurst,LYPlGuardKingsHealer,not IsPvPTalentInUse(94)) or
		DefensiveOnTeam(PlGuardKings,nil,LYPlGuardKingsHP,LYPlGuardKingsBurst,nil,LYMode ~= "PvE" and IsPvPTalentInUse(94)) or
		BRDeadFriend() or
		PlSacHP() or
		TauntPvP(PlTaunt,844) or
		Taunt(PlTaunt) or
		AntiStealth(PlJudg) or
		CommonKick(PlHoJ,"magic","alt",LYPlHoJKick) or
		CommonKick(PlBlind,"magic","alt",LYPlBlindKick,9) or
		LYDispelAlwaysF(PlRDispel) or
		TotemStomp({PlCrusader},{PlJudg,PlAvShield},30) or
		FreedomCast(PlFreedom,LYPlFreedomHeal,LYPlFreedomHP,LYPlFreedomRoot,LYPlFreedomDPS,true) or
		TripleCC(PlBlind,LYPlBlindAOE,9) or
		StunCC(PlHoJ,"magic",LYPlHoJDR,LYPlHoJHealer,LYPlHoJHealerHP,LYPlHoJTeamBurst,LYPlHoJDPS,LYPlHoJDPSHP,LYPlHoJDPSBurst,LYPlHoJCont,LYPlHoJFocus) or
		ControlCC(PlRep,"magic",LYPlRepDR,LYPlRepHealer,LYPlRepHealerHP,LYPlRepTeamBurst,LYPlRepDPS,LYPlRepDPSHP,LYPlRepDPSBurst,LYPlRepCont,LYPlRepFocus,true) or
		FearCC(PlBlind,"magic",LYPlBlindDR,LYPlBlindHealer,LYPlBlindHealerHP,LYPlBlindTeamBurst,LYPlBlindDPS,LYPlBlindDPSHP,LYPlBlindDPSBurst,nil,nil,nil,9) or
		PlCastSearingGlare() or
		CommonHeal(PlBastLight,LYUP < 3,LYPlGloryHP) or
		CommonHeal(PlGlory,true,LYPlGloryHP) or
		CommonHeal(PlFlash,not IsMoving() and LYHDPS,90) or
		Burst() or
		ConditionalSpell(PlShVirtue,LYMode ~= "PvE" and GCDCheck(PlShVirtue) and GCDCheck(PlAvShield) and UnitIsVisible(LYEnemyTarget) and (IsWizzard(LYEnemyTarget) or CheckRole(LYEnemyTarget) == "HEALER") and not UnitIsCCed(LYEnemyTarget)) or
		CommonAttack(PlDivToll,"magic",true,PlAvShield,true,nil,nil,3) or
		CommonAttack(PlAvShield,"magic",true,PlAvShield,not BreakCCAroundUnit("player")) or
		CommonAttack(PlShieldRight,"magic",true,PlKick,GCDCheck(PlShieldRight) and (not HaveBuff("player",PlShieldRight,1) or (IsTalentInUse(280373) and BuffCount("player",PlRedoubt,3) < 3)) and (HaveBuff("player",PlAvenValor) or CDLeft(PlAvShield) > LYGCDTime)) or
		PlWrathHamCast() or
		CommonAttack(PlJudg,"magic",true,PlJudg,true) or
		CommonAttack(PlConsec,"magic",nil,PlKick,(not IsMoving() or LYMode == "PvP") and not BreakCCAroundUnit("player",12) and not HaveBuff("player",PlConsec)) or
		CommonHeal(PlGlory,HaveBuff(PlShinLight),95) or
		CommonAttack(PlCrusader,"magic",true,PlKick,(HaveBuff("player",PlConsec) or SpellChargesCheck(PlCrusader))) or
		ConditionalSpell(PlEyeTyr,GCDCheck(PlEyeTyr) and (EnemiesAroundUnit(PlKick) > 2 or IsInBossFight())) or
		FreedomConsec() or
		CommonHeal(PlFlash,LYMode ~= "PvE" and not IsMoving() and not HaveBuff("player",PlWings),LYPlFlash) or
		LYDispelAllF(PlRDispel) or
		PlAuras() then
			return true
		end
	end
	function LYPaladinRet()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",PlJudg) then
				if GCDCheck(PlWings) then
					LYQueueSpell(PlWings)
					LY_Print(PlWings,"green",PlWings)
					return true
				end
				if GCDCheck(PlAvenger) then
					LYQueueSpell(PlAvenger)
					LY_Print(PlAvenger,"green",PlAvenger)
					return true
				end
			end
		end
		local function Sanctuary()
			local function DispelSanc(pointer)
				for i=1,40 do
					local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
					if tBuff and tBuff.name then
						if tContains(listSacCC,tBuff.name) and tBuff.expirationTime - GetTime() >= LYPlSancSec and (LYReaction == 0 or tBuff.expirationTime - GetTime() < tBuff.duration - LYReaction/1000) then
							return true
						end
					else
						return
					end
				end
			end
			if GCDCheck(PlSanctuary) and LYMode == "PvP" then
				if PartyHPBelow(LYPlSancTeamHP) then
					for i=1,#LYTeamHealers do
						if UnitIsVisible(LYTeamHealers[i]) and DispelSanc(LYTeamHealers[i]) then
							LYSpellStopCasting()
							LYQueueSpell(PlSanctuary,LYTeamHealers[i])
							LY_Print(PlSanctuary.." @team healer","green",PlSanctuary)
							return true
						end
					end
				end
				if #LYTeamHealersAll == 0 or LYPlSancDPS then
					for i=1,#LYTeamPlayers do
						if UnitIsVisible(LYTeamPlayers[i]) and DispelSanc(LYTeamPlayers[i]) and (EnemyHPBelow(LYPlSancEnemyHP) or (LYPlSancBurst and IsBursting(LYTeamPlayers[i]))) then
							LYSpellStopCasting()
							LYQueueSpell(PlSanctuary,LYTeamPlayers[i])
							LY_Print(PlSanctuary.." @DPS teammate","green",PlSanctuary)
							return true
						end
					end
				end
			end
		end
		local function JudgDivPun()
			if GCDCheck(PlJudg) and LYPlJudgUnit and LYUP < 5 and ValidEnemyUnit(LYPlJudgUnit) and SpellAttackTypeCheck(LYPlJudgUnit,"magic") and inRange(PlJudg,LYPlJudgUnit) and InLineOfSight(LYPlJudgUnit) and LYFacingCheck(LYPlJudgUnit) then
				LYQueueSpell(PlJudg,LYPlJudgUnit)
				return true
			end
		end
		if CommonKick(PlKick,"magic","kick",true) or
		Sanctuary() or
		CastKick(PlRep,LYPlRepKick,"control") or
		PlSacCC() or
		TauntCC(PlTaunt) or
		PlLoHCast() or
		PauseRotation or
		PlSacHP() or
		AntiStealth(PlJudg) or
		CommonKick(PlHoJ,"magic","alt",LYPlHoJKick) or
		CommonKick(PlBlind,"magic","alt",LYPlBlindKick,9) or
		BRDeadFriend() or
		LYDispelAlwaysF(PlRDispel) or
		TotemStomp({PlCrusader,PlVerdict},{PlJudg},30) or
		BreakCCMG(PlGlory,true) or
		TripleCC(PlBlind,LYPlBlindAOE,9) or
		StunCC(PlHoJ,"magic",LYPlHoJDR,LYPlHoJHealer,LYPlHoJHealerHP,LYPlHoJTeamBurst,LYPlHoJDPS,LYPlHoJDPSHP,LYPlHoJDPSBurst,LYPlHoJCont,LYPlHoJFocus) or
		ControlCC(PlRep,"magic",LYPlRepDR,LYPlRepHealer,LYPlRepHealerHP,LYPlRepTeamBurst,LYPlRepDPS,LYPlRepDPSHP,LYPlRepDPSBurst,LYPlRepCont,LYPlRepFocus,true) or
		FearCC(PlBlind,"magic",LYPlBlindDR,LYPlBlindHealer,LYPlBlindHealerHP,LYPlBlindTeamBurst,LYPlBlindDPS,LYPlBlindDPSHP,LYPlBlindDPSBurst,nil,nil,nil,9) or
		PlCastSearingGlare() or
		CommonHeal(PlGlory,LYHDPS or HaveBuff("player",PlRoyalDec),90) or
		CommonHeal(PlFlash,((LYMode ~= "PvE" and (BuffCount("player",PlSelflessHeal) > 3 or HaveBuff("player",PlSerBless))) or (not IsMoving() and LYHDPS)),90) or
		CommonHeal(PlGlory,LYMode ~= "PvE" and not DoNotUsePower and not IsBursting(),LYPlGloryHP) or
		CommonHeal(PlGlory,LYMode ~= "PvE" and HaveBuff("player",{PlWings,PlHolywar}),25) or
		FreedomCast(PlFreedom,LYPlFreedomHeal,LYPlFreedomHP,LYPlFreedomRoot,LYPlFreedomDPS,true) or
		SlowTarget(PlHindrace,"magic",nil,LYSlowAlways) or
		Peel(PlHindrace,"magic",LYPeelAny,LYPeelHealer) or
		Burst() or
		DefensiveOnPlayer(PlShieldVeng,nil,LYPlShVengHP,LYPlShVengBurst,LYPlShVengHealer,not HaveBuff("player",{PlBubble,PlBoP})) or
		DefensiveOnPlayer(PlEye,"MELEE",LYPlEyeHP,LYPlEyeBurst,LYPlEyeHealer,not HaveBuff("player",{PlBubble,PlBoP})) or
		CommonAttackTarget(PlExSent,"magic",true,GCDCheck(PlExSent) and inRange(PlCrusader,LYEnemyTarget) and (not IsTalentInUse(255937) or GCDCheck(PlRArt))) or
		CommonAttackTarget(PlFinReckon,"magic",true,GCDCheck(PlFinReckon) and inRange(PlJudg,LYEnemyTarget) and (not IsTalentInUse(406158) or LYUP < 3) and (not IsTalentInUse(255937) or GCDCheck(PlRArt) or LYMode ~= "PvP")) or
		CommonAttackTarget(PlDivToll,"magic",true,GCDCheck(PlDivToll) and (LYUP < 2 or not inRange(PlVerdict,LYEnemyTarget)) and inRange(PlJudg,LYEnemyTarget) and (not IsTalentInUse(343527) or HaveDebuff(LYEnemyTarget,PlExSent,LYGCDTime,"player")) and (not IsTalentInUse(343721) or HaveDebuff(LYEnemyTarget,PlFinReckon,LYGCDTime,"player") or LYMode ~= "PvP")) or
		CommonAttackTarget(PlRArt,"magic",true,GCDCheck(PlRArt) and inRange(PlCrusader,LYEnemyTarget) and not BreakCCAroundUnit("player",12,true) and LYUP < 3 and (not IsTalentInUse(343527) or HaveDebuff(LYEnemyTarget,PlExSent,LYGCDTime,"player")) and (not IsTalentInUse(343721) or HaveDebuff(LYEnemyTarget,PlFinReckon,LYGCDTime,"player") or LYMode ~= "PvP")) or
		CommonAttack(PlDivToll,"magic",true,PlJudg,LYUP < 2,nil,nil,3) or
		PlWrathHamCast() or
		CommonAttack(PlJustVeng,"magic",true,PlJustVeng,IsBursting() and LYMode == "pvp") or
		CommonAttack(PlVerdict,"magic",true,PlVerdict,IsBursting() and LYMode == "pvp") or
		CommonAttack(PlCrusader,"phys",true,PlCrusader,LYUP < 5) or
		CommonAttack(PlBladeJust,"magic",true,PlBladeJust,LYUP < 4) or
		JudgDivPun() or
		CommonAttack(PlJudg,"magic",true,PlJudg,LYUP < 5) or
		ConditionalSpell(PlDivStorm,((EnemiesAroundUnit(8) > 1 and LYZoneType ~= "arena" and LYStyle == "All units"and BuffCount("player",PlDivArb) < 25) or (inRange(PlCrusader,LYEnemyTarget) and HaveBuff("player",PlEmpyrean) and not BreakCCAroundUnit("player",10)))) or
		CommonAttack(PlJustVeng,"magic",true,PlJustVeng,true) or
		CommonAttack(PlVerdict,"magic",true,PlVerdict,true) or
		CommonAttack(PlJudg,"magic",true,PlJudg,LYZoneType == "arena",nil,nil,nil,30) or
		CommonAttack(PlBladeJust,"magic",true,PlBladeJust,LYZoneType == "arena",nil,nil,nil,35) or
		CommonAttack(PlConsec,"magic",nil,PlCrusader,not BreakCCAroundUnit("player",9) and not IsMoving()) or
		ConditionalSpell(PlDivSteed,LYMode ~= "PvE" and GCDCheck(PlDivSteed) and UnitIsVisible(LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and SpellChargesCheck(PlDivSteed) and IsMoving() and ObjectIsFacing("player",LYEnemyTarget) and not inRange(PlJudg,LYEnemyTarget) and CalculateHP(LYEnemyTarget) < 50) or
		CommonHeal(PlFlash,LYMode ~= "PvE" and not IsMoving() and not HaveBuff("player",{PlWings,PlHolywar}),LYPlFlash) or
		LYDispelAllF(PlRDispel) or
		PlAuras() then
			return true
		end
	end
	function LYPriestDisc()
		local function Shield()
			if GCDCheck(PrShield) and LYStyle ~= "Utilities only" then
				if HaveBuff("player",PrRapture) then
					for i=1,#LYTeamPlayers do
						if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 90 and (LYZoneType ~= "raid" or UnitIsTank(LYTeamPlayers[i])) and not HaveBuff(LYTeamPlayers[i],PrShield,0,"player") and FriendIsUnderAttack(LYTeamPlayers[i]) then
							LYQueueSpell(PrShield,LYTeamPlayers[i])
							return true
						end
					end
				else
					for i=1,#LYTeamPlayers do
						if ValidFriendUnit(LYTeamPlayers[i]) and (LYZoneType ~= "raid" or UnitIsTank(LYTeamPlayers[i])) and not HaveDebuff(LYTeamPlayers[i],PrWeakSoul) and not HaveBuff(LYTeamPlayers[i],PrShield,0,"player") and ((CalculateHP(LYTeamPlayers[i]) < 95 and (FriendIsUnderAttack(LYTeamPlayers[i]) or (LYZoneType == "arena" and CalculateHP(LYTeamPlayers[i]) < 85) or HaveBuff("player",PrDarkAngel,2))) or (IsPvPTalentInUse(109) and #LYTeamPlayers > 2 and TeamMembersAroundUnit(nil,nil,nil,PrAton) < 3)) then
							LYQueueSpell(PrShield,LYTeamPlayers[i])
							return true
						end
					end
				end
			end
		end
		local function PreHot()
			if GCDCheck(PrShield) and LYZoneType == "arena" and InEnemySight() and CalculateMP("player") > 95 then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and not HaveDebuff(LYTeamPlayers[i],PrWeakSoul) and not HaveBuff(LYTeamPlayers[i],PrAton,2,"player") then
						LYQueueSpell(PrShield,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function DarkAngel()
			if GCDCheck(PrDarkAngel) and LYMode ~= "PvE" and ((LYPrDarkAngelBurst and TeamIsBursting()) or EnemyHPBelow(LYPrDarkAngelHP)) then
				if LYZoneType == "arena" and TeamMembersAroundUnit(nil,"player",nil,PrAton) > 0 then
					if GCDCheck(PrShield) then
						for i=1,#LYTeamPlayers do
							if ValidFriendUnit(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],PrAton,5,"player") and not HaveDebuff(LYTeamPlayers[i],PrWeakSoul) then
								LYQueueSpell(PrShield,LYTeamPlayers[i])
								return true
							end
						end
					end
				else
					LYQueueSpell(PrDarkAngel)
					return true
				end
			end
		end
		local function DoT()
			if #LYEnemyTotems > 0 then
				return
			end
			local dotspell = PrSWP
			if IsTalentInUse(204197) then
				dotspell = PrPWicked
			end
			if GCDCheck(dotspell) and LYStyle ~= "Utilities only" then
				if LYDoTUnits ~= 0 then
					local count = 0
					for i=1,#LYEnemies do
						if inRange(PrSWP,LYEnemies[i]) and HaveDebuff(LYEnemies[i],dotspell,5,"player") then
							count = count + 1
						end
					end
					if count >= LYDoTUnits then
						return
					end
				end
				local dotUnit = nil
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and inRange(PrSWP,LYEnemies[i]) then
						if not HaveDebuff(LYEnemies[i],dotspell,0,"player") then
							LYQueueSpell(PrSWP,LYEnemies[i])
							return true
						elseif not dotUnit and not HaveDebuff(LYEnemies[i],dotspell,5,"player") then
							dotUnit = LYEnemies[i]
						end
					end
				end
				for i=1,#LYEnemyMinors do
					if ValidEnemyUnit(LYEnemyMinors[i]) and inRange(PrSWP,LYEnemyMinors[i]) and not HaveDebuff(LYEnemyMinors[i],dotspell,0,"player") then
						LYQueueSpell(PrSWP,LYEnemyMinors[i])
						return true
					end
				end
				if dotUnit then
					LYQueueSpell(PrSWP,dotUnit)
					return true
				end
			end
		end
		local function InnerLight()
			if (PartyHPBelow(LYPrInnerLightHP) or LYStayForm == PrInnerLight or (not HaveBuff("player", PrInnerShadow) and not GCDCheck(PrInnerShadow))) and not HaveBuff("player", PrInnerLight) and GCDCheck(PrInnerLight) then
				LYQueueSpell(PrInnerLight)
				return true
			elseif not LYStayForm and not HaveBuff("player", PrInnerShadow) and GCDCheck(PrInnerShadow) then
				LYQueueSpell(PrInnerShadow)
				return true
			end
		end
		if LYDispel(PrDispel) or
		CommonKick(PrFear,nil,"alt",LYPrFearKick,8) or
		PrSWDCC() or
		PrShift() or
		PrGripCC() or
		LYReflect(PrFade,IsPvPTalentInUse(5570)) or
		TripleCC(PrFear,LYPrFearTripple,8) or
		PrFadeIncFear() or
		FearCC(PrFear,nil,LYPrFearDR,LYPrFearHealer,LYPrFearHealerHP,LYPrFearTeamBurst,LYPrFearDPS,LYPrFearDPSHP,LYPrFearDPSBurst,LYPrFearCont,LYPrFearFocus,nil,7) or
		AntiStealth(PrSWP) or
		PauseRotation or
		PrMDImunes() or
		PrMDCC() or
		ResDeadFriend() or
		PurgeEssential(PrPurge) or
		PurgeForce(PrPurge) or
		ConditionalSpell(PrDespPrayer,GCDCheck(PrDespPrayer) and CalculateHP("player") < LYPrDespPrayer and FriendIsUnderAttack("player")) or
		AutoBuffParty(PrBuff) or
		DarkAngel() or
		CommonAttack(PrSWD,nil,nil,PrSWP,not PartyHPBelow(35) or LYMode == "PvP",nil,nil,nil,20) or
		CommonAttack(PrSWP,nil,nil,PrSWP,LYHDPS and IsTalentInUse(204197),6,PrPWicked) or
		CommonAttack(PrSWP,nil,nil,PrSWP,LYHDPS and not IsTalentInUse(204197),5,PrSWP) or
		CommonAttack(PrMindBlast,nil,true,PrMindBlast,LYHDPS and not IsMoving()) or
		CommonAttack(PrPenance,nil,true,PrPenance,LYHDPS) or
		CommonAttack(PrUltPenance,nil,true,PrMindBlast,LYHDPS and not IsMoving()) or
		CommonAttack(PrSmite,nil,true,PrSmite,LYHDPS and not IsMoving()) or
		PreHot() or
		CommonHeal(PrPWLife,true,35) or
		AOEHeal(PrHolyNova,12,85,3,BuffCount("player",PrRhapsody) > 19) or
		ConditionalSpell(PrHalo,not IsMoving() and GCDCheck(PrHalo) and TeamMembersAroundUnit(30,"player",85) > 2 and not BreakCCAroundUnit()) or
		AOEHeal(PrPWRad,30,LYPrPWRadAOEHP,LYPrPWRadAOECount,GCDCheck(PrPWRad) and (IsPvPTalentInUse(114) or not IsMoving())) or
		ConditionalSpell(PrEvangel,LYLastSpellName == PrPWRad) or
		AOEHeal(PrUltPenance,nil,LYPrUltPenanceAOEHP,LYPrUltPenanceAOECount,not IsMoving()) or
		CommonHeal(PrFlash,HaveBuff("player",PrSurgeLight),85) or
		Shield() or
		ConditionalSpell(PrVampEmbrace,LYPrVampEmbraceSync and HaveBuff("player",PrShadCoven)) or
		CommonAttackTarget(PrPenance,nil,nil,inRange(PrPenance,LYEnemyTarget) and (HaveBuff("player",373183) or HaveBuff("player",PrShadCoven) or ((not IsTalentInUse(204197) or HaveDebuff(LYEnemyTarget,PrPWicked,1,"player")) and not PartyHPBelow(LYPrPenance) and (#LYTeamPlayers == 1 or AnyFriendHasBuff(PrAton,2))))) or
		CommonHeal(PrPenance,true,85) or
		PrMindGames() or
		CommonHeal(PrPWRad,(IsPvPTalentInUse(114) or not IsMoving()) and LYLastSpellName ~= PrPWRad,LYPrPWRadHP) or
		ConditionalSpell(PrHolyNova,BuffCount("player",PrRhapsody) > 19 and TeamMembersAroundUnit(10,"player",50) > 0 and not BreakCCAroundUnit()) or
		PrThoughtstealCast() or
		DefensiveOnTeam(PrPWB,nil,LYPrPWBHP,LYPrPWBBurst,nil,LYLastSpellName ~= PrTeeth) or
		DefensiveOnTeam(PrRapture,nil,LYPrRapturHP,LYPrRapturBurst,nil,true) or
		DefensiveOnTeam(PrArchangel,nil,LYPrArcHP,LYPrArcBurst,nil,LYMode ~= "PvE") or
		DefensiveOnTeam(PrVampEmbrace,nil,LYPrVampEmbraceHP,LYPrVampEmbraceBurst,nil,InEnemySight()) or
		CommonHeal(PrUltPenance,not IsMoving(),LYPrUltPenanceHP) or
		PrRenewCast(PrAton) or
		PrDivineStar() or
		PrInfusionCast() or
		PrShackleDK() or
		PrShackleAbom() or
		TotemStomp(nil,{PrSmite},40) or
		PrFeatherCast() or
		CommonAttack(PrPet,nil,nil,PrPet,(TeamIsBursting() or CalculateMP("player") < 80 or LYHDPS) and (GCDCheck(PrPenance) or not IsTalentInUse(314867))) or
		CommonHeal(PrFlash,not IsMoving(),LYPrFlash) or
		ControlCC(PrMC,nil,LYPrMCDR,LYPrMCHealer,LYPrMCHealerHP,LYPrMCTeamBurst,LYPrMCDPS,LYPrMCDPSHP,LYPrMCDPSBurst,nil,LYPrMCFocus) or
		DoT() or
		CommonAttack(PrMindBlast,nil,true,PrMindBlast,not IsMoving()) or
		CommonAttack(PrPenance,nil,true,PrPenance,GCDCheck(PrPenance) and (#LYTeamPlayers == 1 or AnyFriendHasBuff(PrAton,2))) or
		CommonAttack(PrSmite,nil,true,PrSmite,not IsMoving()) or
		PrMindSootheCast() or
		PurgePassive(PrPurge) or
		InnerLight() then
			return true
		end
	end
	function LYPriestHoly()
		local function PrayerMending()
			if GCDCheck(PrPrayerMending) and LYStyle ~= "Utilities only" then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and ((CalculateHP(LYTeamPlayers[i]) < 95 and FriendIsUnderAttack(LYTeamPlayers[i])) or UnitIsTank(LYTeamPlayers[i])) and not HaveBuff(LYTeamPlayers[i],PrPrayerMending) then
						LYQueueSpell(PrPrayerMending,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function Shield(hp)
			if GCDCheck(PrShield) and LYStyle ~= "Utilities only" then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < hp and FriendIsUnderAttack(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],PrShield,0,"player") and not HaveDebuff(LYTeamPlayers[i],PrWeakSoul) then
						LYQueueSpell(PrShield,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function SpiritRedem()
			if GCDCheck(215769) and LYMode ~= "PvE" and IsPvPTalentInUse(124) then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and not UnitIsUnit(LYTeamPlayers[i],"player") and FriendIsUnderAttack(LYTeamPlayers[i],nil,LYPrSpiritRedemHP,LYPrSpiritRedemBurst) and (LYStackDef or not HaveBuff(LYTeamPlayers[i],listDef)) then
						LYSpellStopCasting()
						LYCurrentSpellName = PrSpiritRedem
						CastSpellByID(215769)
						LY_Print(PrSpiritRedem.." @teammate","green",PrSpiritRedem)
						return true
					end
				end
			end
		end
		if LYDispel(PrDispel) or
		CommonKick(PrFear,nil,"alt",LYPrFearKick,8) or
		PrSWDCC() or
		PrGripCC() or
		PrShift() or
		LYReflect(PrFade,IsPvPTalentInUse(5569)) or
		LYReflect(PrHolyWard,PartyHPBelow(LYPrHolyWard)) or
		AntiStealth(PrPurge) or
		CommonKick(PrChas,"magic","alt",LYPrChasKick) or
		TripleCC(PrFear,LYPrFearTripple,8) or
		PrFadeIncFear() or
		FearCC(PrFear,nil,LYPrFearDR,LYPrFearHealer,LYPrFearHealerHP,LYPrFearTeamBurst,LYPrFearDPS,LYPrFearDPSHP,LYPrFearDPSBurst,LYPrFearCont,LYPrFearFocus,nil,7) or
		PauseRotation or
		PrMDImunes() or
		PrMDCC() or
		DefensiveOnTeam(PrRayHope,nil,LYPrRayHopeHP,LYPrRayHopeBurst,nil,LYMode ~= "PvE") or
		ResDeadFriend() or
		DefensiveOnPlayer(PrDivAscen,"MELEE",70,LYPrDivAscenHP,LYPrDivAscenBurst,true) or
		ConditionalSpell(PrDespPrayer,GCDCheck(PrDespPrayer) and CalculateHP("player") < LYPrDespPrayer and FriendIsUnderAttack("player")) or
		PurgeEssential(PrPurge) or
		CommonAttack(PrSWD,nil,nil,PrSWP,not PartyHPBelow(35) or LYMode == "PvP",nil,nil,nil,20) or
		CommonAttack(PrSWP,nil,nil,PrSWP,LYHDPS,5,PrSWP) or
		CommonAttack(PrHolyFire,nil,true,PrSmite,LYHDPS and not IsMoving()) or
		ConditionalSpell(PrEmpBlaze,LYHDPS) or
		CommonAttack(PrSmite,nil,true,PrSmite,not IsMoving() and LYHDPS) or
		PurgeForce(PrPurge) or
		ConditionalSpell(PrHalo,not IsMoving() and GCDCheck(PrHalo) and (IsInBossFight() or LYMode ~= "PvE") and TeamMembersAroundUnit(30,"player",85) > 2 and not BreakCCAroundUnit()) or
		ConditionalSpell(PrDivHymn,GCDCheck(PrDivHymn) and TeamMembersAroundUnit(nil,"player",LYPrDivHymnAOEHP) >= LYPrDivHymnAOEUnits and (not InEnemySight() or LYMode == "PvE") and UnitAffectingCombat("player")) or
		AOEHeal(PrHolyNova,12,85,3,BuffCount("player",PrRhapsody) > 19) or
		AOEHeal(PrCircle,12,90,3,true) or
		AOEHeal(PrSanctify,10,LYPrSanctifyHP,LYPrSanctifyAOE,true) or
		AOEHeal(PrPrayerHealing,nil,80,5,LYZoneType ~= "arena" and not IsMoving()) or
		AOEHeal(PrSalvation,nil,LYPrSalvationHP,LYPrSalvationAOE,true) or
		PrDivineStar() or
		StunCC(PrChas,nil,LYPrChasDR,LYPrChasHealer,LYPrChasHealerHP,LYPrChasTeamBurst,LYPrChasDPS,LYPrChasDPSHP,LYPrChasDPSBurst,LYPrChasCont,LYPrChasFocus) or
		CommonHeal(PrFlash,HaveBuff("player",{PrSurgeLight,PrSpiritRedem}),85) or
		DefensiveOnTeam(PrApotheosis,nil,LYPrApothHP,LYPrApothBurst,nil,CDLeft(PrSeren) > 10) or
		DefensiveOnTeam(PrDivWord,nil,LYPrDivWordHP,LYPrDivWordBurst,nil,CDLeft(PrSeren) < 5) or
		CommonHeal(PrPWLife,true,35) or
		CommonHeal(PrSeren,true,60) or
		PrayerMending() or
		ConditionalSpell(PrHolyNova,BuffCount("player",PrRhapsody) > 19 and TeamMembersAroundUnit(10,"player",50) > 0 and not BreakCCAroundUnit()) or
		Shield(35) or
		SpiritRedem() or
		PrRenewCast(PrRenew) or
		CommonHeal(PrSanctify,true,LYPrSanctifyHPS) or
		CommonHeal(PrCircle,true,35) or
		CommonHeal(PrHeal,not IsMoving() and BuffCount("player",PrLightweav) > 1,35) or
		CommonHeal(PrFlash,not IsMoving(),35) or
		PrInfusionCast() or
		PrMindGames() or
		PrThoughtstealCast() or
		PrShackleDK() or
		CommonHeal(PrGreatHeal,GCDCheck(PrGreatHeal) and not IsMoving() and not EnemyCanKick(),65) or
		CommonHeal(PrHeal,not IsMoving() and (LYMode ~= "PvP" or BuffCount("player",PrLightweav) > 1 or not EnemyCanKick() ),85) or
		CommonHeal(PrFlash,not IsMoving(),LYPrFlash) or
		AutoBuffParty(PrBuff) or
		TotemStomp(nil,{PrHolyFire,PrSmite,PrSWP},40) or
		PrFeatherCast() or
		PrShackleAbom() or
		ControlCC(PrMC,nil,LYPrMCDR,LYPrMCHealer,LYPrMCHealerHP,LYPrMCTeamBurst,LYPrMCDPS,LYPrMCDPSHP,LYPrMCDPSBurst,nil,LYPrMCFocus) or
		CommonAttack(PrPet,nil,nil,PrPet,TeamIsBursting() or CalculateMP("player") < 80) or
		CommonAttack(PrHolyFire,nil,true,PrSmite,(CalculateMP("player") > LYHealerDPS and not IsMoving()) or HaveBuff("player",PrEmpBlaze)) or
		CommonAttack(PrSWP,nil,nil,PrSWP,CalculateMP("player") > LYHealerDPS,5,PrSWP) or
		CommonAttack(PrSmite,nil,true,PrSmite,not IsMoving() and CalculateMP("player") > LYHealerDPS) or
		ConditionalSpell(PrSymbolHope,CalculateMP("player") < 75 and not PartyHPBelow(75) and (not InEnemySight() or (UnitAffectingCombat("player") and LYMode == "PvE"))) or
		ConditionalSpell(PrEmpBlaze,InEnemySight() and CDLeft(PrChas) > 10) or
		PrMindSootheCast() or
		PurgePassive(PrPurge) then
			return true
		end
	end
	function LYPriestShadow()
		local rdpsTotem = {PrSWP}
		if HaveBuff("player",PrShadIns) then
			rdpsTotem = {PrMindBlast,PrSWP}
		end
		local function Form()
			if GetShapeshiftForm() ~= 1 and GCDCheck(PrShadowForm) then
				CastShapeshiftForm(1)
			end
		end
		local function Silence()
			if CDCheck(PrSilence) and LYMode ~= "PvE" and EnemyHPBelow(LYPrSilence) then
				for i=1,#LYEnemyHealers do
					if ValidEnemyUnit(LYEnemyHealers[i]) and inRange(PrSilence,LYEnemyHealers[i]) and CheckUnitDR(LYEnemyHealers[i],"silence") and not UnitIsCCed(LYEnemyHealers[i]) then
						LYQueueSpell(PrSilence,LYEnemyHealers[i])
						return true
					end
				end
			end
		end
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,nil,PrSWP) then
				if GCDCheck(PrPet) then
					LYQueueSpell(PrPet,LYEnemyTarget)
					LY_Print(PrPet,"green",PrPet)
					return true
				end
				if GCDCheck(PrPsyfiend) and UnitIsPlayer(LYEnemyTarget) then
					LYQueueSpell(PrPsyfiend)
					LY_Print(PrPsyfiend,"green",PrPsyfiend)
					return true
				end
				if GCDCheck(PrInfusion) and LYPrInfusionBurst then
					if IsTalentInUse(373466) then
						CastSpellByName(PrInfusion,ReturnTeamMate(true))
						LY_Print(PrInfusion,"green",PrInfusion)
					else
						CastSpellByName(PrInfusion,"player")
						LY_Print(PrInfusion,"green",PrInfusion)
					end
				end
				if GCDCheck(PrVoidErup) and (not IsMoving() or IsPvPTalentInUse(739)) and not HaveBuff("player",PrVoidform) then
					LYQueueSpell(PrVoidErup,LYEnemyTarget)
					LY_Print(PrVoidErup,"green",PrVoidErup)
					return true
				end
				if GCDCheck(PrDarkAscension) then
					LYQueueSpell(PrDarkAscension)
					LY_Print(PrDarkAscension,"green", PrDarkAscension)
					return true
				end
				if GCDCheck(PrMindGame) and not IsMoving() then
					LYQueueSpell(PrMindGame,LYEnemyTarget)
					LY_Print(PrMindGame,"green",PrMindGame)
					return true
				end
				if GCDCheck(PrDamn) and not HaveDebuff(LYEnemyTarget,PrVTouch) and (UnitIsPlayer(LYEnemyTarget) or LYMode ~= "PvP") then
					LYQueueSpell(PrDamn,LYEnemyTarget)
					LY_Print(PrDamn,"green",PrDamn)
					return true
				end
			end
		end
		local function Shield(isPvP)
			if GCDCheck(PrShield) and LYStyle ~= "Utilities only" and (LYHDPS or (isPvP and ((LYZoneType == "arena" and CalculateMP("player") > 20) or LYZoneType == "Outworld" or HaveBuff("player",PrFaeGuard)))) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 90 and FriendIsUnderAttack(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],PrShield,0,"player") and not HaveDebuff(LYTeamPlayers[i],PrWeakSoul) then
						LYQueueSpell(PrShield,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function ShadowCrash()
			if GCDCheck(PrShadowCrash) and LYUP < 80 then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and inRange(PrVTouch,LYEnemies[i]) and (LYMode ~= "PvE" or not IsMoving(LYEnemies[i])) then
						LYQueueSpell(PrShadowCrash,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function MCRootBeam()
			if GCDCheck(PrMC) and not IsMoving() and LYZoneType == "arena" and HaveDebuff(LYTeamHealers[1],DrSolar) and IsRooted(LYTeamHealers[1],2) and CheckUnitDR(LYTeamHealers[1],"control",2) then
				LYQueueSpell(PrMC,LYTeamHealers[1])
				return true
			end
		end
		local function DivineStarDPS()
			if GCDCheck(PrDivStar) and LYStyle ~= "Utilities only" then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and IsInDistance(LYEnemies[i],20) and IsLookingAt(LYEnemies[i]) then
						LYQueueSpell(PrDivStar,LYEnemies[i])
						return true
					end
				end
			end
		end
		if CommonKick(PrSilence,nil,"kick",true) or
		CommonKick(PrFear,nil,"alt",LYPrFearKick,8) or
		PrSWDCC() or
		PrGripCC() or
		PrShift() or
		Silence() or
		AntiReflect(PrSWP) or
		LYReflect(PrFade,IsPvPTalentInUse(5568)) or
		TripleCC(PrFear,LYPrFearTripple,8) or
		CommonKick(PrPsyHorror,nil,"alt",LYPrPsyHorKick) or
		FearCC(PrFear,nil,LYPrFearDR,LYPrFearHealer,LYPrFearHealerHP,LYPrFearTeamBurst,LYPrFearDPS,LYPrFearDPSHP,LYPrFearDPSBurst,LYPrFearCont,LYPrFearFocus,nil,7) or
		StunCC(PrPsyHorror,nil,LYPrPsyHorDR,LYPrPsyHorHealer,LYPrPsyHorHealerHP,LYPrPsyHorTeamBurst,LYPrPsyHorDPS,LYPrPsyHorDPSHP,LYPrPsyHorDPSBurst,LYPrPsyHorCont,LYPrPsyHorFocus) or
		MCRootBeam() or
		AntiStealth(PrPurge) or
		PauseRotation or
		PrMDImunes() or
		PrMDCC() or
		Form() or
		Shield() or
		ConditionalSpell(PrDespPrayer,GCDCheck(PrDespPrayer) and CalculateHP("player") < LYPrDespPrayer and FriendIsUnderAttack("player")) or
		CommonHeal(PrPWLife,true,35) or
		CommonHeal(PrFlash,not IsMoving() and LYHDPS,80) or
		CommonHeal(PrFlash,not IsMoving(),LYPrFlashSP) or
		DefensiveOnTeam(PrVampEmbrace,nil,LYPrVampEmbraceHP,LYPrVampEmbraceBurst,nil,InEnemySight() and EnemiesAroundUnitDoTed(nil,nil,{PrVTouch,PrSWP},true) == #LYEnemies) or
		PurgeForce(PrPurge) or
		TotemStomp(nil,rdpsTotem,40) or
		PurgeEssential(PrPurge) or
		LYDispelAlwaysF(PrPurify) or
		CommonAttack(PrSWD,nil,nil,PrSWP,HaveBuff("player",PrDeathsent) or PlayerHasTierBonus(4) or (GetTotemInfo(1) and IsTalentInUse(373427))) or
		CommonAttack(PrSWD,nil,nil,PrSWD,true,nil,nil,nil,20) or
		Burst() or
		CommonAttack(PrVTouch,nil,nil,PrVTouch,BuffTimeLeft("player",PrUnfurDark) < 2) or
		CommonAttack(PrVoidErup,nil,true,PrSWP,HaveBuff("player",PrVoidform)) or
		CommonAttack(PrMindBlast,nil,true,PrMindBlast,HaveBuff("player",PrShadIns)) or
		ShadowCrash() or
		CommonAttack(PrDevPlague,nil,nil,PrDevPlague,not DoNotUsePower,2,PrDevPlague) or
		PrThoughtstealCast() or
		CommonAttack(PrSWP,nil,nil,PrSWP,IsPvPTalentInUse(5486)) or
		CommonAttack(PrVTouch,nil,nil,PrVTouch,(not IsMoving() or HaveBuff("player",PrUnfurDark)) and (not IsTalentInUse(205385) or LYLastSpellName ~= PrShadowCrash),7,PrVTouch) or
		PrMindGames() or
		CommonAttackTarget(PrVoidTor,nil,nil,inRange(PrSWP,LYEnemyTarget) and LYUP < 40 and not IsMoving() and (HaveAllDebuffs(LYEnemyTarget,{PrSWP,PrVTouch,PrDevPlague}) or HaveBuff("player",PrVoidform) or UnitIsPlayer(LYEnemyTarget))) or
		CommonAttack(PrMindBlast,nil,true,PrMindBlast,not IsMoving()) or
		DivineStarDPS() or
		CommonAttack(PrDamn,nil,nil,PrSWP,true,0,{PrSWP,PrVTouch,PrDevPlague}) or
		PrShackleDK() or
		PrShackleAbom() or
		CommonAttack(PrSWP,nil,nil,PrSWP,true,7,PrSWP) or
		ControlCC(PrMC,nil,LYPrMCDR,LYPrMCHealer,LYPrMCHealerHP,LYPrMCTeamBurst,LYPrMCDPS,LYPrMCDPSHP,LYPrMCDPSBurst,nil,LYPrMCFocus) or
		CommonAttack(PrMindSpike,nil,true,PrMindBlast,not IsMoving() and BuffCount("player",PrMMelt) < 2) or
		CommonAttack(PrMFlay,nil,true,PrSWP,not IsMoving() and UnitChannelInfo("player") ~= PrMFlay) or
		AutoBuffParty(PrBuff) or
		Shield(true) or
		PrFeatherCast() or
		LYDispelAllF(PrPurify) or
		PrMindSootheCast() or
		PurgePassive(PrPurge) or
		UpdateDoTs(PrSWP) then
			return true
		end
	end
	function LYRogueAss()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",RgKick) then
				if GCDCheck(RgKingsbane) and LYCP < LYCPMax then
					LYQueueSpell(RgKingsbane,LYEnemyTarget)
					LY_Print(RgKingsbane,"green",RgKingsbane)
					return true
				end
				if GCDCheck(RgDeathmark) and ((IsTalentInUse(385627) and HaveAllDebuffs(LYEnemyTarget,{RgGarStrike,RgRupture,RgKingsbane},5)) or (not IsTalentInUse(385627) and HaveAllDebuffs(LYEnemyTarget,{RgGarStrike,RgRupture},5))) then
					LYQueueSpell(RgDeathmark,LYEnemyTarget)
					LY_Print(RgDeathmark,"green",RgDeathmark)
					return true
				end
				if GCDCheck(RgSD) and not HaveBuff("player",listRgStealth) then
					LYQueueSpell(RgSD)
					LY_Print(RgSD,"green",RgSD)
					return true
				end
				if GCDCheck(RgEchoingReprimand) and LYCP <= LYCPMax - 2 and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(RgEchoingReprimand,LYEnemyTarget)
					LY_Print(RgEchoingReprimand,"green")
					return true
				end
				if GCDCheck(RgSepsis) and LYCP <= LYCPMax - 1 and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(RgSepsis,LYEnemyTarget)
					LY_Print(RgSepsis,"green")
					return true
				end
				if GCDCheck(RgVanish) and LYRgVanishDPS and not HaveBuff("player",listRgStealth) and LYMode ~= "PvP" and LYCP >= LYCPMax - 1 then
					LYQueueSpell(RgVanish)
					LY_Print(RgVanish,"green",RgVanish)
					return true
				end
			end
		end
		if RgKickCast() or
		ConditionalSpell(RgThistleTea,LYUP < LYUPMax/2 and not HaveBuff("player",RgThistleTea) and inRange(RgKick,LYEnemyTarget) and UnitAffectingCombat("player")) or
		PauseRotation or
		DefensiveOnPlayer(RgVanish,nil,LYRgVanishHP,LYRgVanishBurst,LYRgVanishHealer,not HaveDebuff("player",listDoTs)) or
		RgSapNonCombat() or
		RgCoShCC() or
		DefensiveOnPlayer(RgEvasion,"MELEE",LYRgEvasionHP,LYRgEvasionBurst,LYRgEvasionHealer,true) or
		DefensiveOnPlayer(RgCloak,"WIZARD",LYRgCloakHP,LYRgCloakBurst,LYRgCloakHealer,true) or
		DefensiveOnPlayer(RgFeint,nil,LYRgFeintHP,LYRgFeintBurst,LYRgFeintHealer,IsTalentInUse(79008) and not HaveBuff("player",listRgStealth)) or
		ConditionalSpell(RgColdblood,GCDCheck(RgColdblood) and (GCDCheck(RgAmbush) or GCDCheck(RgEnven)) and UnitAffectingCombat("player") and UnitIsVisible(LYEnemyTarget) and inRange(RgKick,LYEnemyTarget) and CalculateHP(LYEnemyTarget) < LYRgColdblood) or
		RgSapBlind() or
		RgPoisons() or
		AntiStealth(RgPoisKnife) or
		TotemStomp({RgMuti,RgShiv},{RgPoisKnife},30) or
		Disarm(RgDisarm,LYRgDisarmHP,LYRgDisarmBurst,LYRgDisarmHealer,LYRgDisarmFocus) or
		RgGougeKick() or
		RgGougeCC() or
		FearCC(RgBlind,nil,LYRgBlindDR,LYRgBlindHealer,LYRgBlindHealerHP,LYRgBlindTeamBurst,LYRgBlindDPS,LYRgBlindDPSHP,LYRgBlindDPSBurst,LYRgBlindCont,LYRgBlindFocus) or
		ConditionalSpell(RgBomb,LYMode ~= "PvE" and GCDCheck(RgBomb) and UnitIsVisible(LYEnemyTarget) and inRange(RgKick,LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and ((LYRgBombBurst and IsBursting()) or CalculateHP(LYEnemyTarget) < LYRgBombHP) and (not LYRgBombStun or UnitIsStunned(LYEnemyTarget,3))) or
		DefensiveOnTeam(RgBomb,"WIZARD",LYRgBombDefHP,LYRgBombDef,8,LYMode ~= "PvE") or
		ConditionalSpell(RgStealth,LYRgStealth and GCDCheck(RgStealth) and GetTime() - LastStealth > 1 and not HaveDebuff("player",listDoTs)) or
		DefensiveOnPlayer(RgCrimson,nil,LYRgCrimsonHP,LYRgCrimsonBurst,LYRgCrimsonHealer,true) or
		Burst() or
		RgQueueStun() or
		RgKidneyCast() or
		RgEvisRupSlice() or
		RgCheapshotPlayers() or
		CommonAttack(RgAmbush,nil,true,RgKick,LYCP < LYCPMax - 2 or (not IsTalentInUse(381620) and LYCP < LYCPMax - 1)) or
		CommonAttack(RgGarStrike,nil,true,RgGarStrike,HaveBuff("player",RgImprGar) and (LYCP < LYCPMax or (UnitIsVisible(LYNextStun) and CDLeft(RgKidney) > 2)),5,RgGarStrike) or
		CommonAttack(RgEchoingReprimand,nil,true,RgKick,LYCP <= LYCPMax - 2,nil,nil,nil,35) or
		CommonAttack(RgSepsis,nil,true,RgKick,LYCP <= LYCPMax - 1,nil,nil,nil,35) or
		CommonAttack(RgSerratedBoneSpike,nil,true,RgSerratedBoneSpike,not DoNotUsePower and LYCP < LYCPMax,0,RgSerratedBoneSpike) or
		CommonAttack(RgGarStrike,nil,true,RgGarStrike,(LYCP < LYCPMax or (UnitIsVisible(LYNextStun) and CDLeft(RgKidney) > 2)),5,RgGarStrike) or
		ConditionalSpell(RgFan,LYZoneType ~= "arena" and not BreakCCAroundUnit("player",15) and (LYCP < LYCPMax or (UnitIsVisible(LYNextStun) and CDLeft(RgKidney) > 2)) and GCDCheck(RgFan) and EnemiesAroundUnit(10) > 2) or
		CommonAttack(RgShiv,nil,true,RgKick,IsPvPTalentInUse(830) and (LYCP == LYCPMax - 1 or (IsBursting() and LYCP < LYCPMax)),0,RgHemotox) or
		PurgeEnrage(RgShiv,LYCP < LYCPMax) or
		CommonAttack(RgShiv,nil,true,RgKick,(LYCPMax-LYCP)%2 == 1) or
		CommonAttack(RgMuti,nil,true,RgKick,LYCP < LYCPMax or (UnitIsVisible(LYNextStun) and CDLeft(RgKidney) > 2)) or
		ConnecTarget(RgShStep,LYRgShStepBurst,LYRgShStepHP) then
			return true
		end
	end
	function LYRogueOutlaw()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",RgKick) then
				if GCDCheck(RgAR) and (not IsTalentInUse(395422) or LYCP < 2) and not HaveBuff("player",RgAR) then
					LYQueueSpell(RgAR)
					LY_Print(RgAR,"green",RgAR)
					return true
				end
				if GCDCheck(RgGhostStrk) and LYCP < LYCPMax then
					LYQueueSpell(RgGhostStrk,LYEnemyTarget)
					LY_Print(RgGhostStrk,"green",RgSD)
					return true
				end
				if GCDCheck(RgKillSpree) and LYCP >= LYCPMax - 1 then
					if GCDCheck(RgColdblood) then
						CastSpellByName(RgColdblood)
					end
					LYQueueSpell(RgKillSpree,LYEnemyTarget)
					LY_Print(RgKillSpree,"green",RgKillSpree)
					return true
				end
				if GCDCheck(RgDreadblades) and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(RgDreadblades,LYEnemyTarget)
					LY_Print(RgDreadblades,"green",RgDreadblades)
					return true
				end
				if GCDCheck(RgSD) and not HaveBuff("player",listRgStealth) and (CDLeft(RgBtwEyes) < 3 or not IsTalentInUse(423703)) then
					LYQueueSpell(RgSD)
					LY_Print(RgSD,"green",RgSD)
					return true
				end
				if GCDCheck(RgEchoingReprimand) and LYCP <= LYCPMax - 2 and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(RgEchoingReprimand,LYEnemyTarget)
					LY_Print(RgEchoingReprimand,"green")
					return true
				end
				if GCDCheck(RgSepsis) and LYCP <= LYCPMax - 1 and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(RgSepsis,LYEnemyTarget)
					LY_Print(RgSepsis,"green")
					return true
				end
				if GCDCheck(RgVanish) and LYRgVanishDPS and not HaveBuff("player",listRgStealth) and LYMode ~= "PvP" and LYCP >= LYCPMax - 1 and (CDLeft(RgBtwEyes) < 3 or not IsTalentInUse(423703)) then
					LYQueueSpell(RgVanish)
					LY_Print(RgVanish,"green",RgVanish)
					return true
				end
			end
		end
		local function Tricks()
			if GCDCheck(RgTricks) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and IsPvPTalentInUse(1208) then
				local friendDPS = ReturnTeamMate(true)
				if UnitIsVisible(friendDPS) then
					CastSpellByName(RgTricks,friendDPS)
					return true
				end
			end
		end
		local function BladeFuryCancel()
			if HaveBuff("player",RgBladeFlurry) and BreakCCAroundUnit("player",12) then
				CancelBuffByName(RgBladeFlurry)
			end
		end
		if RgKickCast() or
		BladeFuryCancel() or
		ConditionalSpell(RgThistleTea,LYUP < LYUPMax/2 and not HaveBuff("player",RgThistleTea) and inRange(RgKick,LYEnemyTarget) and UnitAffectingCombat("player")) or
		PauseRotation or
		DefensiveOnPlayer(RgVanish,nil,LYRgVanishHP,LYRgVanishBurst,LYRgVanishHealer,not HaveDebuff("player",listDoTs)) or
		Tricks() or
		RgSapNonCombat() or
		RgCoShCC() or
		DefensiveOnPlayer(RgEvasion,"MELEE",LYRgEvasionHP,LYRgEvasionBurst,LYRgEvasionHealer,true) or
		DefensiveOnPlayer(RgCloak,"WIZARD",LYRgCloakHP,LYRgCloakBurst,LYRgCloakHealer,true) or
		DefensiveOnPlayer(RgFeint,nil,LYRgFeintHP,LYRgFeintBurst,LYRgFeintHealer,IsTalentInUse(79008) and not HaveBuff("player",listRgStealth)) or
		ConditionalSpell(RgColdblood,GCDCheck(RgColdblood) and GCDCheck(RgAmbush) and UnitAffectingCombat("player") and UnitIsVisible(LYEnemyTarget) and inRange(RgKick,LYEnemyTarget) and CalculateHP(LYEnemyTarget) < LYRgColdblood) or
		RgSapBlind() or
		RgPoisons() or
		AntiStealth(RgPistolShot) or
		TotemStomp({RgSaberSlash,RgShiv},{RgPistolShot},20) or
		Disarm(RgDisarm,LYRgDisarmHP,LYRgDisarmBurst,LYRgDisarmHealer,LYRgDisarmFocus) or
		RgGougeKick() or
		RgGougeCC() or
		FearCC(RgBlind,nil,LYRgBlindDR,LYRgBlindHealer,LYRgBlindHealerHP,LYRgBlindTeamBurst,LYRgBlindDPS,LYRgBlindDPSHP,LYRgBlindDPSBurst,LYRgBlindCont,LYRgBlindFocus) or
		ConditionalSpell(RgBomb,LYMode ~= "PvE" and GCDCheck(RgBomb) and UnitIsVisible(LYEnemyTarget) and inRange(RgKick,LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and ((LYRgBombBurst and IsBursting()) or CalculateHP(LYEnemyTarget) < LYRgBombHP) and (not LYRgBombStun or UnitIsStunned(LYEnemyTarget,3))) or
		DefensiveOnTeam(RgBomb,"WIZARD",LYRgBombDefHP,LYRgBombDef,8,LYMode ~= "PvE") or
		Peel(RgPistolShot,nil,LYPeelAny,LYPeelHealer) or
		ConditionalSpell(RgStealth,LYRgStealth and GCDCheck(RgStealth) and GetTime() - LastStealth > 1 and not HaveDebuff("player",listDoTs)) or
		DefensiveOnPlayer(RgCrimson,nil,LYRgCrimsonHP,LYRgCrimsonBurst,LYRgCrimsonHealer,true) or
		RgQueueStun() or
		Burst() or
		ConditionalSpell(RgRollBones,not DoNotUsePower and GCDCheck(RgRollBones) and not UnitIsVisible(LYNextStun) and inRange(RgKick,LYEnemyTarget) and NumberOfBuffs("player",listRgRoll) < 2) or
		ConditionalSpell(RgBladeFlurry,GCDCheck(RgBladeFlurry) and ((EnemiesAroundUnit(8) > 1 and not HaveBuff("player",RgBladeFlurry)) or EnemiesAroundUnit(8) > 4)) or
		RgKidneyCast() or
		ConditionalSpell(RgSliceDice,not DoNotUsePower and GCDCheck(RgSliceDice) and not UnitIsVisible(LYNextStun) and not AnyEnemyHealCCed(1) and LYCP >= LYCPMax - 1 and UnitIsVisible(LYEnemyTarget) and inRange(RgKick,LYEnemyTarget) and CalculateHP(LYEnemyTarget) > LYRgEvisHP and not HaveBuff("player",{RgSliceDice,RgEchoingReprimand},10)) or
		CommonAttack(RgBtwEyes,nil,true,RgBtwEyes,not DoNotUsePower and LYCP >= LYCPMax - 1 and not UnitIsVisible(LYNextStun) and (not IsTalentInUse(423703) or HaveBuff("player",listRgStealth))) or
		CommonAttack(RgDeathAbove,nil,true,RgDeathAbove,not DoNotUsePower and LYMode ~= "PvE" and LYCP >= LYCPMax - 1 and not UnitIsVisible(LYNextStun)) or
		CommonAttack(RgRunThr,nil,true,RgKick,not DoNotUsePower and LYCP >= LYCPMax - 1 and not UnitIsVisible(LYNextStun)) or
		RgCheapshotPlayers() or
		CommonAttack(RgAmbush,nil,true,RgKick,LYCP < LYCPMax - 2 or (not IsTalentInUse(381620) and LYCP < LYCPMax - 1) or HaveBuff("player",RgAudacity)) or
		CommonAttack(RgEchoingReprimand,nil,true,RgKick,LYCP <= LYCPMax - 2,nil,nil,nil,35) or
		CommonAttack(RgSepsis,nil,true,RgKick,LYCP <= LYCPMax - 1,nil,nil,nil,35) or
		PurgeEnrage(RgShiv,LYCP < LYCPMax) or
		CommonAttack(RgPistolShot,nil,true,RgPistolShot,(LYCP < LYCPMax or (UnitIsVisible(LYNextStun) and CDLeft(RgKidney) > 2)) and HaveBuff("player",RgOpportun)) or
		CommonAttack(RgSaberSlash,nil,true,RgKick,(LYCP < LYCPMax or (UnitIsVisible(LYNextStun) and CDLeft(RgKidney) > 2)) and not HaveBuff("player",RgAudacity)) or
		CommonAttack(RgShiv,nil,true,RgKick,LYCP == LYCPMax - 1 and LYMode ~= "PvE") or
		ConditionalSpell(RgBladeRush,GCDCheck(RgBladeRush) and UnitIsVisible(LYEnemyTarget) and inRange(RgBladeRush,LYEnemyTarget) and not BreakCCAroundUnit(LYEnemyTarget,8) and (EnemiesAroundUnit(8,LYEnemyTarget) < 1 or HaveBuff("player",RgBladeFlurry) or (LYMode ~= "PvP" and inRange(RgKick,LYEnemyTarget)))) or
		ConnecTarget(RgGrapHook,LYRgShStepBurst,LYRgShStepHP) then
			return true
		end
	end
	function LYRogueSub()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"phys",RgKick) then
				if GCDCheck(RgShBlade) then
					LYQueueSpell(RgShBlade)
					LY_Print(RgShBlade,"green")
					return true
				end
				if GCDCheck(RgSD) and not HaveBuff("player",listRgStealth) and not HaveDebuff("player",RgShadDuel) then
					LYQueueSpell(RgSD)
					LY_Print(RgSD,"green")
					return true
				end
				if GCDCheck(RgSecTech) and LYCP >= LYCPMax - 1 then
					LYQueueSpell(RgSecTech,LYEnemyTarget)
					LY_Print(RgSecTech,"green")
					return true
				end
				if GCDCheck(RgEchoingReprimand) and (LYCP <= LYCPMax - 2 or HaveBuff("player",RgShBlade)) and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(RgEchoingReprimand,LYEnemyTarget)
					LY_Print(RgEchoingReprimand,"green")
					return true
				end
				if GCDCheck(RgSepsis) and (LYCP <= LYCPMax - 1 or HaveBuff("player",RgShBlade)) and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(RgSepsis,LYEnemyTarget)
					LY_Print(RgSepsis,"green")
					return true
				end
				if GCDCheck(RgGoremBite) and (LYCP <= LYCPMax - 3 or HaveBuff("player",RgShBlade)) then
					LYQueueSpell(RgGoremBite,LYEnemyTarget)
					LY_Print(RgGoremBite,"green")
					return true
				end
				if GCDCheck(RgFlagel) then
					LYQueueSpell(RgFlagel,LYEnemyTarget)
					LY_Print(RgFlagel,"green")
					return true
				end
				if LYRgShadowDuelBurst and GCDCheck(RgShadDuel) and not HaveBuff("player",listRgStealth) and not HaveBuff("player",listFlags) and UnitIsPlayer(LYEnemyTarget) and not HaveBuff(LYEnemyTarget,listFlags) and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(RgShadDuel,LYEnemyTarget)
					LY_Print(RgShadDuel,"green")
					return true
				end
				if GCDCheck(RgVanish) and LYRgVanishDPS and not HaveBuff("player",listRgStealth) and LYMode ~= "PvP" and LYCP >= LYCPMax - 1 then
					LYQueueSpell(RgVanish)
					LY_Print(RgVanish,"green",RgVanish)
					return true
				end
			end
		end
		local function ShadDuelHealer()
			if GCDCheck(RgShadDuel) and EnemyHPBelow(LYRgShadowDuelHP) and not HaveBuff("player",listRgStealth) then
				for i=1,#LYEnemyHealers do
					if UnitIsVisible(LYEnemyHealers[i]) and not UnitIsCCed(LYEnemyHealers[i]) then
						if inRange(RgShadDuel,LYEnemyHealers[i]) then
							LYQueueSpell(RgShadDuel,LYEnemyHealers[i],"face")
							return true
						elseif GCDCheck(RgShStep) and inRange(RgShStep,LYEnemyHealers[i]) then
							LYQueueSpell(RgShStep,LYEnemyHealers[i])
							return true
						end
					end
				end
			end
		end
		local function CheapshotKick()
			if LYRgCheapKick and (GCDCheck(RgCheap) or (LYRgCheapSD and GCDCheck(RgSD))) then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
						local castName, _, _, castStartTime, castEndTime = UnitCastingInfo(LYEnemies[i])
						local channelName, _, _, channelStartTime, channelEndTime = UnitChannelInfo(LYEnemies[i])
						local modified = nil
						if channelName then
							castName = channelName
							castStartTime = channelStartTime
							castEndTime = channelEndTime
							modified = true
						end
						if castName and not tContains(LYListNotKick,castName) and ValidKick(LYEnemies[i],castName) and CheckUnitDR(LYEnemies[i],"stun",2) then
							local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
							local castTime = castEndTime - castStartTime
							local currentPercent = timeSinceStart / castTime * 100
							if (currentPercent > KickTime or (modified and timeSinceStart > KickDelayFixed)) and castTime > LYKickMin and currentPercent < 95 then
								if HaveBuff("player",listRgStealth) or HaveDebuff("player",RgShadDuel) then
									if GCDCheck(RgCheap) then
										if inRange(RgCheap,LYEnemies[i]) then
											LYSpellStopCasting()
											LYQueueSpell(RgCheap,LYEnemies[i],"face")
											LY_Print(RgCheap.." "..castName,"green",RgCheap)
											return true
										elseif LYRgShStepKick and GCDCheck(RgShStep) and inRange(RgShStep,LYEnemies[i]) then
											CastSpellByName(RgShStep,LYEnemies[i])
											return true
										end
									end
								elseif LYRgCheapSD and GCDCheck(RgSD) and LYUP > 35 and (inRange(RgCheap,LYEnemies[i]) or (LYRgShStepKick and GCDCheck(RgShStep) and inRange(RgShStep,LYEnemies[i]))) then
									CastSpellByName(RgSD)
									return true
								end
							end
						end
					end
				end
			end
		end
		if RgKickCast() or
		ConditionalSpell(RgSymbDeath,UnitAffectingCombat("player") and GCDCheck(RgSymbDeath) and not HaveBuff("player",RgSymbDeath) and inRange(RgKick,LYEnemyTarget) and (LYUP + 40) < LYUPMax) or
		ConditionalSpell(RgThistleTea,LYUP < LYUPMax/2 and not HaveBuff("player",RgThistleTea) and inRange(RgKick,LYEnemyTarget) and UnitAffectingCombat("player")) or
		PauseRotation or
		DefensiveOnPlayer(RgVanish,nil,LYRgVanishHP,LYRgVanishBurst,LYRgVanishHealer,not HaveDebuff("player",listDoTs)) or
		RgSapNonCombat() or
		RgCoShCC() or
		DefensiveOnPlayer(RgEvasion,"MELEE",LYRgEvasionHP,LYRgEvasionBurst,LYRgEvasionHealer,true) or
		DefensiveOnPlayer(RgCloak,"WIZARD",LYRgCloakHP,LYRgCloakBurst,LYRgCloakHealer,true) or
		DefensiveOnPlayer(RgFeint,nil,LYRgFeintHP,LYRgFeintBurst,LYRgFeintHealer,IsTalentInUse(79008) and not HaveBuff("player",listRgStealth) and not HaveDebuff("player",RgShadDuel)) or
		ConditionalSpell(RgColdblood,GCDCheck(RgColdblood) and GCDCheck(RgShadStrk) and UnitAffectingCombat("player") and UnitIsVisible(LYEnemyTarget) and inRange(RgKick,LYEnemyTarget) and CalculateHP(LYEnemyTarget) < LYRgColdblood) or
		RgSapBlind() or
		RgPoisons() or
		AntiStealth(RgToss) or
		RgGougeKick() or
		CheapshotKick() or
		TotemStomp({RgShadStrk,RgBackstab},{RgToss},30) or
		Disarm(RgDisarm,LYRgDisarmHP,LYRgDisarmBurst,LYRgDisarmHealer,LYRgDisarmFocus) or
		RgGougeCC() or
		FearCC(RgBlind,nil,LYRgBlindDR,LYRgBlindHealer,LYRgBlindHealerHP,LYRgBlindTeamBurst,LYRgBlindDPS,LYRgBlindDPSHP,LYRgBlindDPSBurst,LYRgBlindCont,LYRgBlindFocus) or
		ConditionalSpell(RgBomb,LYMode ~= "PvE" and GCDCheck(RgBomb) and UnitIsVisible(LYEnemyTarget) and inRange(RgKick,LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and ((LYRgBombBurst and IsBursting()) or CalculateHP(LYEnemyTarget) < LYRgBombHP) and (not LYRgBombStun or UnitIsStunned(LYEnemyTarget,3))) or
		DefensiveOnTeam(RgBomb,"WIZARD",LYRgBombDefHP,LYRgBombDef,8,LYMode ~= "PvE") or
		ConditionalSpell(RgStealth,LYRgStealth and GCDCheck(RgStealth) and GetTime() - LastStealth > 1 and not HaveDebuff("player",listDoTs)) or
		DefensiveOnPlayer(RgCrimson,nil,LYRgCrimsonHP,LYRgCrimsonBurst,LYRgCrimsonHealer,true) or
		Burst() or
		RgQueueStun() or
		RgKidneyCast() or
		RgCheapshotPlayers() or
		ShadDuelHealer() or
		RgEvisRupSlice() or
		CommonAttack(RgEchoingReprimand,nil,true,RgKick,LYCP <= LYCPMax - 2,nil,nil,nil,35) or
		CommonAttack(RgSepsis,nil,true,RgKick,LYCP <= LYCPMax - 1,nil,nil,nil,35) or
		CommonAttack(RgBlackPowder,nil,true,RgKick,not DoNotUsePower and LYCP >= LYCPMax - 1 and not UnitIsVisible(LYNextStun) and EnemiesAroundUnit(8) > 2) or
		ConditionalSpell(RgShurTornado,GCDCheck(RgShurTornado) and not HaveDebuff("player",RgShadDuel) and (LYCP < LYCPMax-1 or (UnitIsVisible(LYNextStun) and CDLeft(RgKidney) > 2)) and EnemiesAroundUnit(10) > 2 and not BreakCCAroundUnit()) or
		ConditionalSpell(RgShuriken,GCDCheck(RgShuriken) and not HaveDebuff("player",RgShadDuel) and LYZoneType ~= "arena" and (LYCP < LYCPMax-1 or (UnitIsVisible(LYNextStun) and CDLeft(RgKidney) > 2)) and EnemiesAroundUnit(10) > 2) or
		PurgeEnrage(RgShiv,LYCP < LYCPMax) or
		CommonAttack(RgShadStrk,nil,true,RgShStep,(LYCP < LYCPMax and (not HaveBuff("player",RgSD) or LYCP < LYCPMax - 1)) or (UnitIsVisible(LYNextStun) and CDLeft(RgKidney) > 2)) or
		CommonAttack(RgBackstab,nil,true,RgKick,(LYCP < LYCPMax or (UnitIsVisible(LYNextStun) and CDLeft(RgKidney) > 2)) and not HaveBuff("player",listRgStealth) and not HaveDebuff("player",RgShadDuel)) or
		CommonAttack(RgShiv,nil,true,RgKick,LYCP == LYCPMax - 1 and LYMode ~= "PvE") or
		CommonAttack(RgToss,nil,true,RgToss,LYCP < LYCPMax and LYUP == LYUPMax and UnitAffectingCombat("player") and HaveDebuff("player",listDoTs)) or
		ConnecTarget(RgShStep,LYRgShStepBurst,LYRgShStepHP) then
			return true
		end
	end
	function LYShamanElem()
		local function FrostShockRoot()
			if not LYShFrostRoot or not HaveBuff("player",ShSurgePow) or not GCDCheck(ShFrostShock) then
				return
			end
			if not LYShSurgeAlwaysRoot then
				for i=1,#LYTeamPlayers do
					local enemy = FriendIsUnderAttack(LYTeamPlayers[i],"MELEE",LYShFrostCCByHP,true)
					if UnitIsVisible(enemy) and not IsRooted(enemy) and CheckUnitDR(enemy,"root",LYShFrostDR) and not HaveBuff(enemy,listISlows) and LYFacingCheck(enemy) then
						LYQueueSpell(ShFrostShock,enemy)
						LY_Print(ShFrostShock.."Root @enemy DPS to Help Teammate","green",ShFrostShock)
						return true
					end
				end
			else
				for i=1,#LYTeamPlayers do
					local enemy = FriendIsUnderAttack(LYTeamPlayers[i],"MELEE")
					if UnitIsVisible(enemy) and not IsRooted(enemy) and CheckUnitDR(enemy,"root",LYShFrostDR) and not HaveBuff(enemy,listISlows) and LYFacingCheck(enemy) then
						LYQueueSpell(ShFrostShock,enemy)
						LY_Print(ShFrostShock.."Root @enemy DPS","green",ShFrostShock)
						return true
					end
				end
				for i=1,#LYEnemyHealers do
					if UnitIsPlayer(LYEnemyHealers[i]) and UnitIsVisible(LYEnemyHealers[i]) and not IsRooted(LYEnemyHealers[i]) and CheckUnitDR(LYEnemyHealers[i],"root",LYShFrostDR) and not HaveBuff(LYEnemyHealers[i],listISlows) and LYFacingCheck(LYEnemyHealers[i]) then
						LYQueueSpell(ShFrostShock,LYEnemyHealers[i])
						LY_Print(ShFrostShock.."Root @enemy Healer","green",ShFrostShock)
						return true
					end
				end
			end
		end
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,nil,ShFireShock) then
				if GCDCheck(ShFireEle) and (not IsTalentInUse(117013) or not UnitIsVisible("pet")) then
					LYQueueSpell(ShFireEle)
					LY_Print(ShFireEle,"green",ShFireEle)
					return true
				end
				if GCDCheck(ShEarthEle) and (not IsTalentInUse(117013) or not UnitIsVisible("pet")) then
					LYQueueSpell(ShEarthEle)
					LY_Print(ShEarthEle,"green",ShEarthEle)
					return true
				end
				if GCDCheck(ShStormKeeper) and not IsMoving() and not HaveBuff("player",ShStormKeeper) and (HaveBuff("player",ShSurgePow) or not IsTalentInUse(262303) or LYMode ~= "PvP") then
					LYQueueSpell(ShStormKeeper)
					LY_Print(ShStormKeeper,"green",ShStormKeeper)
					return true
				end
				if GCDCheck(ShAscend) then
					LYQueueSpell(ShAscend)
					LY_Print(ShAscend,"green",ShAscend)
					return true
				end
				if GCDCheck(ShWalker) and IsMoving() then
					LYQueueSpell(ShWalker)
					LY_Print(ShWalker,"green",ShWalker)
					return true
				end
				if GCDCheck(ShStaticTotem) and IsMoving(LYEnemyTarget) then
					LYQueueSpell(ShStaticTotem,LYEnemyTarget)
					LY_Print(ShStaticTotem,"green",ShStaticTotem)
					return true
				end
				if GCDCheck(ShStormEle) then
					LYQueueSpell(ShStormEle)
					LY_Print(ShStormEle,"green",ShStormEle)
					return true
				end
			end
		end
		local function SlowOrPeel()
			if HaveBuff("player",ShSurgePow) and LYShFrostRoot then
				return
			end
			if SlowTarget(ShFrostShock,"magic",nil,LYSlowAlways) or Peel(ShFrostShock,"magic",LYPeelAny,LYPeelHealer) then
				return true
			end
		end
		local listTStomp = {
			ShFrostShock,
			ShEarthShock
		}
		if HaveBuff("player",ShLavaSurge) then
			tinsert(listTStomp,1,ShLava)
		end
		if CommonKick(ShKick,nil,"kick",true) or
		CommonKick(ShThunder,nil,"move",LYShThunderKick,10) or
		ShGroundingCC() or
		ShWolfRep() or
		CommonKick(ShLightLasso,nil,"alt",LYMode ~= "PvE" and LYShLassoKick) or
		CommonKick(ShCap,nil,"alt",LYMode ~= "PvP" and LYShCapKick,35) or
		AntiReflect(ShFrostShock) or
		AntiStealth(ShFireShock) or
		ShTremorTotem() or
		PauseRotation or
		DefensiveOnPlayer(ShAstralShift,nil,LYShAShiftHP,LYShAShiftBurst,LYShAShiftHealer,true) or
		LYDispelAlwaysF(ShDispelDPS) or
		CommonHeal(ShHealSurge,LYHDPS and (not IsMoving() or HaveBuff("player",ShWalker)),90) or
		ShGroundHarm() or
		TotemStomp(nil,listTStomp,40) or
		PurgeForce(ShPurge) or
		PurgeEssential(ShPurge) or
		ShFreedomTotem() or
		AvoidGapCloser(ShThunder,true,10,"magic") or
		StunCC(ShPulver,nil,LYShPulverDR,LYShPulverHealer,LYShPulverHealerHP,LYShPulverHealerBurst,LYShPulverDPS,LYShPulverDPSHP,LYShPulverDPSBurst,LYShPulverCont) or
		StunCC(ShCap,nil,LYShCapDR,LYShCapHealer,LYShCapHealerHP,LYShCapHealerBurst,LYShCapDPS,LYShCapDPSHP,LYShCapDPSBurst,LYShCapCont,LYShCapFocus,40) or
		StunCC(ShLightLasso,nil,LYShLassoDR,LYShLassoHealer,LYShLassoHealerHP,LYShLassoTeamBurst,LYShLassoDPS,LYShLassoDPSHP,LYShLassoDPSBurst,nil,LYShLassoFocus) or
		FrostShockRoot() or
		DefensiveOnPlayer(ShEarthEle,nil,LYShEarthEleHP,nil,nil,true) or
		DefensiveOnPlayer(ShBurrow,nil,LYShBurrowHP,LYShBurrowBurst,LYShBurrowHealer,true) or
		ControlCC(ShHex,nil,LYShHexDR,LYShHexHealer,LYShHexHealerHP,LYShHexHealerBurst,LYShHexDPS,LYShHexDPSHP,LYShHexDPSBurst,LYShHexCont,LYShHexFocus) or
		DefensiveOnTeam(ShCSTotem,"MELEE",LYShCounterHP,LYShCounterBurst,nil,LYMode ~= "PvE") or
		DefensiveOnEnemy(ShLightLasso,nil,"magic",LYShLassoHP,LYShLassoBurst,nil,LYMode ~= "PvE" and LYLastSpellName ~= ShCap) or
		ConditionalSpell(ShAG,GCDCheck(ShAG) and UnitAffectingCombat("player") and (PartyHPBelow(LYShAGHP) or TeamMembersAroundUnit(nil,"player",LYShAGAOEHP) >= LYShAGAOE) or (LYShAGBurst and EnemyIsBursting())) or
		DefensiveOnTeam(ShThunder,"MELEE",LYShThunderHP,LYShThunderBurst,nil,IsPvPTalentInUse(730)) or
		DefensiveOnTeam(ShGround,"WIZARD",LYShGroundTeamHP,LYShGroundTeamBurst,30,LYMode ~= "PvE") or
		DefensiveOnTeam(ShSkyTotem,nil,LYShSkyTotemHP,LYShSkyTotemBurst,nil,LYMode ~= "PvE") or
		SlowOrPeel() or
		DefensiveOnTeam(ShTEarthBind,"MELEE",LYShEartTotHP,LYShEartTotBurst,nil,LYMode ~= "PvE") or
		ConditionalSpell(ShFlameTon,not GetWeaponEnchantInfo()) or
		Burst() or
		CommonAttack(ShPrimorWave,"magic",true,ShFireShock,not GCDCheck(ShFireShock),5,ShFireShock) or
		CommonAttackTarget(ShMeteorit,"magic",nil,GCDCheck(ShMeteorit) and inRange(ShFireShock,LYEnemyTarget) and UnitIsVisible("pet") and ObjectId("pet") == 61029) or
		AOEAttack(ShLMagma,8,ShFireShock,LYShLMagma,not ShTotemExists(ShLMagma)) or
		CommonAttack(ShFireShock,nil,true,ShFireShock,true,0,ShFireShock) or
		AOEAttack(ShChainL,8,ShChainL,3,HaveBuff("player",{ShStormKeeper,ShPowMaels})) or
		AOEAttack(ShQuake,8,ShFireShock,LYShQuake,not DoNotUsePower and (((not IsTalentInUse(16166) or HaveBuff("player",ShMasterElem)) and (not IsTalentInUse(381932) or BuffCount("player",ShMagmaChamber) > 14)) or LYUP > LYUPMax - 14 or not GCDCheck(ShLava))) or
		ConditionalSpell(ShSkyTotem,LYShSkyTotemKill and GCDCheck(ShSkyTotem) and TeamIsBursting()) or
		ShLavaCast(HaveBuff("player",ShLavaSurge) and LYUP < LYUPMax - 14) or
		CommonAttack(ShPrimorWave,"magic",true,ShFireShock,true) or
		CommonAttackTarget(ShLightning,nil,true,HaveBuff("player",ShStormKeeper) and LYUP < LYUPMax - 12) or
		CommonAttackTarget(ShEarthShock,"magic",true,(((not IsTalentInUse(16166) or HaveBuff("player",ShMasterElem)) and (not IsTalentInUse(381932) or BuffCount("player",ShMagmaChamber) > 14)) or LYUP > LYUPMax - 14 or not GCDCheck(ShLava)) and not DoNotUsePower and UnitIsVisible(LYEnemyTarget) and inRange(ShEarthShock,LYEnemyTarget)) or
		CommonAttack(ShFireShock,nil,true,ShFireShock,HaveBuff("player",ShSurgePow),5,ShFireShock,2) or
		CommonAttack(ShLightning,nil,true,ShLightning,HaveBuff("player",ShSurgePow) and (not IsMoving() or HaveBuff("player",ShWalker))) or
		CommonAttack(ShFireShock,nil,true,ShFireShock,true,5,ShFireShock) or
		ShLavaCast((not IsTalentInUse(333919) or SpellChargesCheck(ShLava) or HaveBuff("player",{ShPrimorWave,ShFluxMelt})) and (not IsMoving() or HaveBuff("player",ShWalker))) or
		CommonAttack(ShIcefury,nil,true,ShIcefury,GCDCheck(ShIcefury) and (not IsMoving() or HaveBuff("player",ShWalker)) and not HaveBuff("player",ShAscend)) or
		ShEarthShld() or
		DefensiveOnTeam(ShHealStream,nil,LYShHealStreamHP,LYShHealStreamBurst,nil,true) or
		CommonAttack(ShFrostShock,nil,true,ShFrostShock,HaveBuff("player",ShIcefury) or (IsTalentInUse(381776) and not HaveBuff("player",ShFluxMelt))) or
		CommonAttackTarget(ShLightLasso,"magic",true,GCDCheck(ShLightLasso) and inRange(ShLightLasso,LYEnemyTarget) and CalculateHP(LYEnemyTarget) < LYShLassoHP and not EnemyCanKick() and CheckUnitDR(LYEnemyTarget,"stun")) or
		CommonAttack(ShEleBlast,nil,true,ShEleBlast,GCDCheck(ShEleBlast) and (not IsMoving() or HaveBuff("player",ShWalker)) and not HaveBuff("player",ShAscend)) or
		CommonHeal(ShChainHeal,HaveBuff("player",336737),101) or
		AOEAttack(ShChainL,8,ShChainL,3,not IsMoving() or HaveBuff("player",{ShWalker,336736})) or
		ShLavaCast(not IsMoving() or HaveBuff("player",ShWalker)) or
		ConditionalSpell(ShTotRecall,ShTotemExists(ShLMagma)) or
		ConditionalSpell(ShLShield,not HaveBuff("player",ShLShield) and (not HaveBuff("player",ShEarthShield) or IsTalentInUse(383010))) or
		CommonHeal(ShHealSurge,((LYMode ~= "PvE" and LYZoneType ~= "pvp") or not UnitAffectingCombat("player")) and (not IsMoving() or HaveBuff("player",ShWalker)),LYShHealSurge) or
		CommonAttack(ShLightning,nil,true,ShLightning,(not IsMoving() or HaveBuff("player",ShWalker))) or
		CommonAttack(ShUnleashShield,"magic",true,ShUnleashShield,true) or
		LYDispelAllF(ShDispelDPS) or
		PurgePassive(ShPurge) or
		CommonAttack(ShFrostShock,nil,true,ShFrostShock,not HaveBuff("player",ShSurgePow)) then
			return true
		end
	end
	function LYShamanEnch()
		local rdpsTotem = {ShFrostShock,ShFireShock}
		if BuffCount("player",ShMaelstorm) > 4 then
			rdpsTotem = {ShFrostShock,ShLightning}
		end
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,"magic",ShPrimalStrike) then
				if GCDCheck(ShFeralSpirit) then
					LYQueueSpell(ShFeralSpirit)
					LY_Print(ShFeralSpirit,"green",ShFeralSpirit)
					return true
				end
				if GCDCheck(ShDoomWinds) then
					LYQueueSpell(ShDoomWinds)
					LY_Print(ShDoomWinds,"green",ShDoomWinds)
					return true
				end
				if GCDCheck(ShBL) and IsPvPTalentInUse(722) and not HaveBuff("player",Mercenary) then
					LYQueueSpell(ShBL,ReturnTeamMate(true))
					LY_Print(ShBL,"green",ShBL)
					return true
				end
				if GCDCheck(ShAscend) then
					LYQueueSpell(ShAscend)
					LY_Print(ShAscend,"green",ShAscend)
					return true
				end
				if GCDCheck(ShStaticTotem) and IsMoving(LYEnemyTarget) then
					LYQueueSpell(ShStaticTotem,LYEnemyTarget)
					LY_Print(ShStaticTotem,"green",ShStaticTotem)
					return true
				end
			end
		end
		local function WaitForWS()
			LYShStormStrike = LYShStormStrike or 0.2
			if HaveBuff("player",{ShAscend,ShDoomWinds}) and CDLeft(ShStormStrike) < LYShStormStrike then
				return true
			end
		end
		local function SunderAOE()
			if GCDCheck(ShSunder) and LYStyle ~= "Utilities only" and not BreakCCAroundUnit("player",10,true) and LYShSunderAOE ~= 0 then
				local count = 0
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and inRange(ShPrimalStrike,LYEnemies[i]) and not UnitIsCCed(LYEnemies[i]) and IsLookingAt(LYEnemies[i],"player",2) then
						count = count + 1
					end
				end
				if count >= LYShSunderAOE then
					LYQueueSpell(ShSunder)
					return true
				end
			end
		end
		local function LavaLash(func)
			if GCDCheck(ShLavaLash) and func and LYStyle ~= "Utilities only" then
				local unit
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and inRange(ShLavaLash,LYEnemies[i]) and HaveDebuff(LYEnemies[i],ShFireShock,0.5,"player") then
						if not IsTalentInUse(334046) or not HaveDebuff(LYEnemies[i],ShLashFlame) then
							if LYFacingCheck(LYEnemies[i]) then
								LYQueueSpell(ShLavaLash,LYEnemies[i])
								return true
							end
						elseif not unit then
							unit = LYEnemies[i]
						end
					end
				end
				if unit and LYFacingCheck(unit) then
					LYQueueSpell(ShLavaLash,unit)
					return true
				end
			end
		end
		if CommonKick(ShKick,"magic","kick",true) or
		CommonKick(ShThunder,"magic","move",LYShThunderKick,10) or
		ShGroundingCC() or
		ShWolfRep() or
		ShTremorTotem() or
		PauseRotation or
		DefensiveOnPlayer(ShAstralShift,nil,LYShAShiftHP,LYShAShiftBurst,LYShAShiftHealer,not IsPvPTalentInUse(1944)) or
		ConditionalSpell(ShSWalk,LYMode ~= "PvE" and GCDCheck(ShSWalk) and UnitIsVisible(LYEnemyTarget) and (IsRooted("player",LYShSWalkRoot) or (HaveDebuff("player",listSlows) and CalculateHP(LYEnemyTarget) < LYShSWalkSlow)) and (not UnitIsVisible(LYEnemyTarget) or not inRange(ShLavaLash,LYEnemyTarget))) or
		DefensiveOnPlayer(ShAstralShift,"MELEE",LYShAShiftHP,LYShAShiftBurst,LYShAShiftHealer,LYMode ~= "PvE" and IsPvPTalentInUse(1944)) or
		AntiStealth(ShFrostShock) or
		ConditionalSpell(ShSunder,LYShSunderCap and LYLastSpellName == ShCap and IsInDistance(LYCurrentSpellTarget,8) and IsLookingAt(LYCurrentSpellTarget,"player",2)) or
		LYDispelAlwaysF(ShDispelDPS) or
		CommonKick(ShSunder,"magic","alt",LYShSunderKick,8) or
		CommonKick(ShLightLasso,nil,"alt",LYMode ~= "PvE" and LYShLassoKick) or
		CommonKick(ShCap,nil,"alt",LYMode ~= "PvP" and LYShCapKick,35) or
		ShGroundHarm() or
		CommonHeal(ShHealSurge,LYHDPS and (not IsMoving() or BuffCount("player",ShMaelstorm) > 4),90) or
		TotemStomp({ShLavaLash,ShStormStrike},rdpsTotem,40) or
		BreakCCMG(ShHealSurge,BuffCount("player",ShMaelstorm) > 4) or
		CommonAttack(ShStormStrike,"phys",true,ShFireShock,HaveBuff("player",{ShAscend,ShDoomWinds})) or
		WaitForWS() or
		PurgeForce(ShPurge) or
		AvoidGapCloser(ShThunder,true,10,"magic") or
		ConditionalSpell(ShAG,GCDCheck(ShAG) and UnitAffectingCombat("player") and (PartyHPBelow(LYShAGHP) or TeamMembersAroundUnit(nil,"player",LYShAGAOEHP) >= LYShAGAOE) or (LYShAGBurst and EnemyIsBursting())) or
		CommonHeal(ShHealSurge,(LYMode ~= "PvE" or not UnitAffectingCombat("player")) and BuffCount("player",ShMaelstorm) > 4,LYShHealSurge) or
		CommonHeal(ShChainHeal,HaveBuff("player",336737),101) or
		DefensiveOnPlayer(ShEarthEle,nil,LYShEarthEleHP,nil,nil,true) or
		DefensiveOnPlayer(ShBurrow,nil,LYShBurrowHP,LYShBurrowBurst,LYShBurrowHealer,true) or
		DefensiveOnTeam(ShThunder,"MELEE",LYShThunderHP,LYShThunderBurst,nil,IsPvPTalentInUse(5527)) or
		PurgeEssential(ShPurge) or
		StunCC(ShLightLasso,nil,LYShLassoDR,LYShLassoHealer,LYShLassoHealerHP,LYShLassoTeamBurst,LYShLassoDPS,LYShLassoDPSHP,LYShLassoDPSBurst,nil,LYShLassoFocus) or
		DefensiveOnEnemy(ShLightLasso,nil,"magic",LYShLassoHP,LYShLassoBurst,nil,LYMode ~= "PvE" and LYLastSpellName ~= ShCap) or
		DefensiveOnTeam(ShHealStream,nil,LYShHealStreamHP,LYShHealStreamBurst,nil,true) or
		StunCC(ShCap,nil,LYShCapDR,LYShCapHealer,LYShCapHealerHP,LYShCapHealerBurst,LYShCapDPS,LYShCapDPSHP,LYShCapDPSBurst,LYShCapCont,LYShCapFocus,40) or
		ControlCC(ShHex,nil,LYShHexDR,LYShHexHealer,LYShHexHealerHP,LYShHexHealerBurst,LYShHexDPS,LYShHexDPSHP,LYShHexDPSBurst,LYShHexCont,LYShHexFocus) or
		DefensiveOnTeam(ShCSTotem,"MELEE",LYShCounterHP,LYShCounterBurst,nil,LYMode ~= "PvE") or
		DefensiveOnTeam(ShGround,"WIZARD",LYShGroundTeamHP,LYShGroundTeamBurst,30,LYMode ~= "PvE") or
		DefensiveOnTeam(ShSkyTotem,nil,LYShSkyTotemHP,LYShSkyTotemBurst,nil,LYMode ~= "PvE") or
		ShFreedomTotem() or
		SlowTarget(ShFrostShock,"magic",nil,LYSlowAlways) or
		Peel(ShFrostShock,"magic",LYPeelAny,LYPeelHealer) or
		ConditionalSpell(ShSkyTotem,LYShSkyTotemKill and GCDCheck(ShSkyTotem) and TeamIsBursting()) or
		CommonAttack(ShFireShock,"magic",true,ShFireShock,true,5,ShFireShock) or
		LavaLash(HaveBuff("player",ShHotHand) or BuffCount("player",ShAshenCata) > 7 or (IsTalentInUse(334033) and EnemiesAroundUnit(8,"player",ShFireShock) > 0)) or
		CommonAttack(ShPrimorWave,"magic",true,ShFireShock,(not IsTalentInUse(384405) or BuffCount("player",ShMaelstorm) < 5),5,ShFireShock) or
		CommonAttack(ShPrimorWave,"magic",true,ShFireShock,(not IsTalentInUse(384405) or BuffCount("player",ShMaelstorm) < 5)) or
		CommonAttack(ShLightning,"magic",true,ShLightning,BuffCount("player",ShMaelstorm) > 4 and HaveBuff("player",ShPrimorWave)) or
		SunderAOE() or
		CommonAttackTarget(ShSunder,"magic",nil,GCDCheck(ShSunder) and not BreakCCAroundUnit("player",10,true) and inRange(ShPrimalStrike,LYEnemyTarget) and not UnitIsCCed(LYEnemyTarget) and IsLookingAt(LYEnemyTarget) and ((LYShSunderBurst and IsBursting(LYEnemyTarget)) or (LYShSunderTeam and PartyHPBelow(LYShSunderTeam)) or CalculateHP(LYEnemyTarget) < LYShSunderHP)) or
		ConditionalSpell(ShCrashLight,GCDCheck(ShCrashLight) and EnemiesAroundUnit(8,"player",nil,true,true) > 2) or
		CommonAttack(ShChainL,"magic",true,ShLightning,BuffCount("player",ShMaelstorm) > 9 or (IsTalentInUse(384411) and BuffCount("player",ShMaelstorm) > 4),nil,nil,3) or
		CommonAttack(ShFeralSpirit,"magic",true,ShPrimalStrike,IsTalentInUse(375982) and CDLeft(ShPrimorWave) > 8) or
		CommonAttack(ShEleBlast,"magic",true,ShLightning,BuffCount("player",ShMaelstorm) > 4) or
		CommonAttack(ShIceStrk,"magic",true,ShIceStrk,true) or
		Burst() or
		CommonAttack(ShStormStrike,"phys",true,ShPrimalStrike,true) or
		ShLavaCast(IsTalentInUse(51505) and BuffCount("player",ShMaelstorm) > 9) or
		CommonAttack(ShFrostShock,"magic",true,ShFrostShock,BuffCount("player",ShHailstorm) > 8 or HaveBuff("player",ShIceStrk)) or
		CommonAttack(ShLightning,"magic",true,ShLightning,BuffCount("player",ShMaelstorm) > 9 or (BuffCount("player",ShMaelstorm) > 4 and LYMode ~= "PvP" and IsTalentInUse(384411))) or
		LavaLash(true) or
		ShEarthShld() or
		ConditionalSpell(ShFireNova,GCDCheck(ShFireNova) and AnyEnemyHasDebuff(ShFireShock)) or
		ConditionalSpell(ShWindTotem,InEnemySight() and not HaveBuff("player",{ShWindTotem,ShWolf}) and (UnitAffectingCombat("player") or LYZoneType == "arena")) or
		CommonAttack(ShUnleashShield,"magic",true,ShUnleashShield,true) or
		LYDispelAllF(ShDispelDPS) or
		PurgePassive(ShPurge) or
		DefensiveOnTeam(ShTEarthBind,"MELEE",LYShEartTotHP,LYShEartTotBurst,nil,LYMode ~= "PvE") or
		ConnecTarget(ShBlink,LYShBlinkBurst,LYShBlinkHP) or
		ConditionalSpell(ShLShield,not HaveBuff("player",ShLShield) and (not HaveBuff("player",ShEarthShield) or IsTalentInUse(383010))) or
		ConditionalSpell(ShFlameTon,not select(5,GetWeaponEnchantInfo()) or (not UnitAffectingCombat("player") and LYZoneType == "arena" and HaveBuff("player",ArenaPrepBuff) and LYLastSpellName ~= ShWindfury and LYLastSpellName ~= ShFlameTon)) or
		ConditionalSpell(ShWindfury,not GetWeaponEnchantInfo() or (not UnitAffectingCombat("player") and LYZoneType == "arena" and HaveBuff("player",ArenaPrepBuff) and LYLastSpellName ~= ShWindfury)) or
		ConditionalSpell(ShWolf,LYShWolf and GCDCheck(ShWolf) and UnitAffectingCombat("player") and not HaveBuff("player",ShWolf) and EnemiesAroundUnit(10) < 1) then
			return true
		end
	end
	function LYShamanRestor()
		local chainDist = 13
		if IsTalentInUse(236501) then
			chainDist = 25
		end
		local function TotemTimeLeft(name)
			local index = 0
			for i=1,4 do
				local totem = select(2,GetTotemInfo(i))
				if totem and totem == name then
					index = i
				end
			end
			return GetTotemTimeLeft(index) or 0
		end
		local function Riptide()
			local spell = ShRiptide
			if not GCDCheck(ShRiptide) and GCDCheck(ShPrimorWave) then
				spell = ShPrimorWave
			end
			if GCDCheck(spell) and LYStyle ~= "Utilities only" and (LYMode ~= "PvE" or BuffCount("player",ShTidalWave) < 2 or IsMoving() or EnemyCanKick() or SpellChargesCheck(ShRiptide)) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and (LYMode ~= "PvE" or not HaveBuff(LYTeamPlayers[i],ShRiptide,6,"player")) and (CalculateHP(LYTeamPlayers[i]) < 80 or (not HaveBuff(LYTeamPlayers[i],ShRiptide,6,"player") and (CalculateHP(LYTeamPlayers[i]) < 95 or FriendIsUnderAttack(LYTeamPlayers[i])))) then
						LYQueueSpell(spell,LYTeamPlayers[i])
						return true
					end
				end
			end
		end
		local function HealStream()
			if GCDCheck(ShHealStream) and LYStyle ~= "Utilities only" and not IsTalentInUse(157153) and not ShTotemExists(ShHealStream) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < LYShHealStreamHP then
						LYQueueSpell(ShHealStream)
						return true
					end
				end
			end
		end
		local function CloudBurst()
			if GCDCheck(ShHealStream) and LYStyle ~= "Utilities only" and IsTalentInUse(157153) then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 95 and (not ShTotemExists(ShCloudBurst) or (CalculateHP(LYTeamPlayers[i]) < 25 and TotemTimeLeft(ShCloudBurst) < 10)) then
						LYQueueSpell(ShHealStream)
						return true
					end
				end
			end
		end
		local function SpiritLink()
			if CDCheck(ShLink) and not IsPvPTalentInUse(718) and #LYTeamPlayers > 1 then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and UnitAffectingCombat(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < LYShSpiritLink then
						for j=1,#LYTeamPlayers do
							if UnitIsVisible(LYTeamPlayers[j]) and not UnitIsUnit(LYTeamPlayers[i],LYTeamPlayers[j]) and IsInDistance(LYTeamPlayers[i],10,LYTeamPlayers[j]) then
								LYQueueSpell(ShLink,LYTeamPlayers[i])
								LY_Print(ShLink,"green")
								return true
							end
						end
					end
				end
			end
		end
		if LYDispel(ShDispel) or
		CommonKick(ShKick,nil,"kick",true) or
		CommonKick(ShThunder,nil,"move",LYShThunderKick,10) or
		ShGroundingCC() or
		ShWolfRep() or
		AntiStealth(ShFireShock) or
		ShTremorTotem() or
		SpiritLink() or
		PauseRotation or
		DefensiveOnPlayer(ShAstralShift,nil,LYShAShiftHP,LYShAShiftBurst,LYShAShiftHealer,true) or
		CommonHeal(ShNS,not HaveBuff("player",ShWalker),LYShNS) or
		ResDeadFriend() or
		CommonKick(ShLightLasso,nil,"alt",LYMode ~= "PvE" and LYShLassoKick) or
		CommonKick(ShCap,nil,"alt",LYMode ~= "PvP" and LYShCapKick,35) or
		ShGroundHarm() or
		ConditionalSpell(ShLivWeapon,not GetWeaponEnchantInfo()) or
		ConditionalSpell(ShStormKeeper,LYHDPS and (not IsMoving() or HaveBuff("player",ShWalker))) or
		CommonAttack(ShFireShock,"magic",true,ShFireShock,LYHDPS,6,ShFireShock) or
		ShLavaCast((HaveBuff("player",ShLavaSurge) or not IsMoving() or HaveBuff("player",ShWalker)) and LYHDPS) or
		AOEAttack(ShChainL,8,ShChainL,2,(not IsMoving() or HaveBuff("player",ShWalker)) and LYHDPS and LYZoneType ~= "arena") or
		CommonAttack(ShLightning,"magic",true,ShLightning,LYHDPS and (not IsMoving() or HaveBuff("player",{ShWalker,ShStormKeeper}))) or
		CommonAttackTarget(ShLightLasso,"magic",true,LYHDPS and GCDCheck(ShLightLasso) and inRange(ShLightLasso,LYEnemyTarget) and not EnemyCanKick() and CheckUnitDR(LYEnemyTarget,"stun")) or
		PurgeForce(ShPurge) or
		AvoidHealer(ShThunder,true,10,"magic") or
		AvoidGapCloser(ShThunder,true,10,"magic") or
		CommonHeal(ShHealWave,HaveBuff("player",ShNS),80) or
		CommonHeal(ShAncTotem,true,10) or
		CommonHeal(ShHealUnleash,true,90) or
		CommonHeal(ShChainHeal,(not IsMoving() or HaveBuff("player",ShWalker)) and HaveAllBuffs("player",{ShHealUnleash,ShTidebring,ShFlashFlood}),5) or
		Riptide() or
		DefensiveOnPlayer(ShEarthEle,nil,LYShEarthEleHP,nil,nil,true) or
		DefensiveOnPlayer(ShBurrow,nil,LYShBurrowHP,LYShBurrowBurst,LYShBurrowHealer,true) or
		DefensiveOnTeam(ShThunder,"MELEE",LYShThunderHP,LYShThunderBurst,nil,IsPvPTalentInUse(5528)) or
		DefensiveOnTeam(ShShieldTotem,nil,LYShWallTotemHP,LYShWallTotemBurst,nil,not ShTotemExists(ShShieldTotem)) or
		ConditionalSpell(ShTotRecall,ShTotemExists(ShShieldTotem)) or
		PurgeEssential(ShPurge) or
		StunCC(ShCap,nil,LYShCapDR,LYShCapHealer,LYShCapHealerHP,LYShCapHealerBurst,LYShCapDPS,LYShCapDPSHP,LYShCapDPSBurst,LYShCapCont,LYShCapFocus,40) or
		StunCC(ShLightLasso,nil,LYShLassoDR,LYShLassoHealer,LYShLassoHealerHP,LYShLassoTeamBurst,LYShLassoDPS,LYShLassoDPSHP,LYShLassoDPSBurst,nil,LYShLassoFocus) or
		DefensiveOnEnemy(ShLightLasso,nil,"magic",LYShLassoHP,LYShLassoBurst,nil,LYMode ~= "PvE" and LYLastSpellName ~= ShCap) or
		ConditionalSpell(ShAG,GCDCheck(ShAG) and UnitAffectingCombat("player") and (PartyHPBelow(LYShAGHP) or TeamMembersAroundUnit(nil,"player",LYShAGAOEHP) >= LYShAGAOE) or (LYShAGBurst and EnemyIsBursting())) or
		DefensiveOnTeam(ShAscend,nil,LYShAscendHP,LYShAscendBurst,nil,true) or
		ConditionalSpell(ShAscend,GCDCheck(ShAscend) and TeamMembersAroundUnit(nil,"player",LYShAscendAOEHP) >= LYShAscendAOEUnits) or
		ConditionalSpell(ShHealTide,GCDCheck(ShHealTide) and TeamMembersAroundUnit(nil,"player",LYShHealTideAOEHP) > LYShHealTideAOEUnits) or
		ShEarthShld() or
		CloudBurst() or
		HealStream() or
		CommonHeal(ShHealTide,true,LYShHealTideHP) or
		AOEAttack(ShHealRain,10,ShLightning,3,LYMode ~= "PvP" and IsTalentInUse(378443) and (not IsMoving() or HaveBuff("player",ShWalker)) and not PartyHPBelow(50)) or
		AOEHeal(ShRArt,10,85,3,(not IsMoving() or HaveBuff("player",ShWalker))) or
		AOEHeal(ShWellspring,10,85,3,(not IsMoving() or HaveBuff("player",ShWalker)),true) or
		AOEHeal(ShHealRain,10,85,5,LYMode ~= "PvP" and (not IsMoving() or HaveBuff("player",ShWalker)) and not HaveBuff("player",ShAscend)) or
		AOEHeal(ShChainHeal,chainDist,LYShChainHealHP,LYShChainHealCount,(not LYShChainHealTide or HaveBuff("player",ShTidebring)) and (not IsMoving() or HaveBuff("player",ShWalker))) or
		CommonHeal(ShWalker,GCDCheck(ShWalker) and IsMoving() and (not IsPvPTalentInUse(3756) or EnemyCanKick()),LYShWalker) or
		CommonHeal(ShHealSurge,(not IsMoving() or HaveBuff("player",ShWalker)) and (LYMode ~= "PvP" or not HaveBuff("player",ShPrimorWave)),LYShHealSurge) or
		DefensiveOnTeam(ShCSTotem,"MELEE",LYShCounterHP,LYShCounterBurst,nil,LYMode ~= "PvE") or
		ConditionalSpell(ShSkyTotem,LYShSkyTotemKill and GCDCheck(ShSkyTotem) and TeamIsBursting()) or
		TotemStomp(nil,{ShFrostShock},40) or
		ControlCC(ShHex,nil,LYShHexDR,LYShHexHealer,LYShHexHealerHP,LYShHexHealerBurst,LYShHexDPS,LYShHexDPSHP,LYShHexDPSBurst,LYShHexCont,LYShHexFocus) or
		DefensiveOnTeam(ShGround,"WIZARD",LYShGroundTeamHP,LYShGroundTeamBurst,30,LYMode ~= "PvE") or
		DefensiveOnTeam(ShSkyTotem,nil,LYShSkyTotemHP,LYShSkyTotemBurst,nil,LYMode ~= "PvE") or
		ShLavaCast(HaveBuff("player",ShLavaSurge) and CalculateMP("player") > LYHealerDPS) or
		Peel(ShEarthGrab,nil,LYPeelAny,LYPeelHealer,35) or
		CommonHeal(ShHealWave,not IsMoving() or HaveBuff("player",ShWalker),LYShHealWaveHP) or
		CommonHeal(ShHealWave,(not IsMoving() or HaveBuff("player",ShWalker)) and HaveBuff("player",ShPrimorWave),100) or
		ConditionalSpell(ShStormKeeper,CalculateMP("player") > LYHealerDPS and (not IsMoving() or HaveBuff("player",ShWalker)) and InEnemySight()) or
		ConditionalSpell(ShWaterShield,not HaveBuff("player",ShWaterShield) and (not HaveBuff("player",ShEarthShield) or IsTalentInUse(383010))) or
		ConditionalSpell(ShManaTotem,CalculateMP("player") < LYShManaTotem and InEnemySight()) or
		DefensiveOnTeam(ShTEarthBind,"MELEE",LYShEartTotHP,LYShEartTotBurst,nil,LYMode ~= "PvE") or
		ShFreedomTotem() or
		Peel(ShFrostShock,"magic",LYPeelAny,LYPeelHealer) or
		CommonAttack(ShUnleashShield,"magic",true,ShUnleashShield,true) or
		AOEAttack(ShChainL,8,ShChainL,3,not IsMoving() or HaveBuff("player",{ShWalker,ShStormKeeper})) or
		CommonAttack(ShLightning,"magic",true,ShLightning,HaveBuff("player",ShStormKeeper) and not HaveBuff("player",ShAscend)) or
		CommonAttack(ShFireShock,"magic",true,ShFireShock,CalculateMP("player") > LYHealerDPS and not HaveBuff("player",ShAscend),5,ShFireShock) or
		ShLavaCast((not IsMoving() or HaveBuff("player",ShWalker)) and CalculateMP("player") > LYHealerDPS) or
		PurgePassive(ShPurge) or
		CommonAttack(ShLightning,"magic",true,ShLightning,CalculateMP("player") > LYHealerDPS and (not IsMoving() or HaveBuff("player",{ShWalker,ShStormKeeper})) and LYZoneType ~= "arena" and not HaveBuff("player",ShAscend)) or
		ConditionalSpell(ShWolf,LYMode ~= "PvE" and FriendIsUnderAttack("player","MELEE") and IsMoving() and HaveDebuff("player",listSlows)) then
			return true
		end
	end
	function LYWarlockAfli()
		local rdpsTotem = {WlShadowBolt}
		if LYMyLevel > 53 then
			rdpsTotem = {WlCorrupt}
		end
		local function Burst()
			if not IsMoving() and BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,nil,WlAgony) and (LYBurstMacro or HaveAllDebuffs(LYEnemyTarget,listWlDoTs,7)) then
				if GCDCheck(WlSoulRot) and not IsMoving() and not IsTalentInUse(334319) then
					LYQueueSpell(WlSoulRot,LYEnemyTarget)
					LY_Print(WlSoulRot,"green",WlSoulRot)
					return true
				end
				if GCDCheck(WlSumDarkglare) then
					LYQueueSpell(WlSumDarkglare,LYEnemyTarget)
					LY_Print(WlSumDarkglare,"green",WlSumDarkglare)
					return true
				end
				if GCDCheck(WlObservCall) and LYMode ~= "PvE" and IsInDistance(LYEnemyTarget,20) then
					LYQueueSpell(WlObservCall)
					LY_Print(WlObservCall,"green",WlObservCall)
					return true
				end
			end
		end
		local function DoTSpell(SpellName)
			if GCDCheck(SpellName) and LYStyle ~= "Utilities only" and not IsMoving() and ValidEnemyUnit(LYEnemyTarget) and inRange(WlShadowBolt,LYEnemyTarget) and HaveAllDebuffs(LYEnemyTarget,listWlDoTs,7) and LYFacingCheck(LYEnemyTarget) then
				LYQueueSpell(SpellName,LYEnemyTarget)
				return true
			end
		end
		local function Unstable(func)
			if GCDCheck(WlUnstable) and LYStyle ~= "Utilities only" and not IsMoving() and func then
				local pandemicUA = 6.3
				if IsTalentInUse(264000) then
					pandemicUA = 5.4
				end
				pandemicUA = pandemicUA + LYMyPing
				local count = EnemiesAroundUnitDoTed(nil,nil,WlUnstable,nil,pandemicUA)
				local dotUnit = nil
				if count == 0 or (IsPvPTalentInUse(5379) and count < 3) then
					for i=1,#LYEnemies do
						if ValidEnemyUnit(LYEnemies[i]) and inRange(WlShadowBolt,LYEnemies[i]) then
							if not HaveDebuff(LYEnemies[i],WlUnstable,0,"player") and count < 3 then
								if LYFacingCheck(LYEnemies[i]) then
									LYQueueSpell(WlUnstable,LYEnemies[i])
									return true
								end
							elseif DebuffTimeLeft(LYEnemies[i],WlUnstable) < pandemicUA and not dotUnit then
								dotUnit = LYEnemies[i]
							end
						end
					end
					if dotUnit and LYFacingCheck(dotUnit) then
						LYQueueSpell(WlUnstable,dotUnit)
						return true
					end
				end
			end
		end
		local function Agony(stacks)
			if GCDCheck(WlAgony) and LYStyle ~= "Utilities only" then
				local count = 0
				if LYDoTUnits ~= 0 then
					if #LYEnemyTotems > 0 then
						return
					end
					for i=1,#LYEnemies do
						if inRange(WlAgony,LYEnemies[i]) and HaveDebuff(LYEnemies[i],WlAgony,0,"player") then
							count = count + 1
						end
					end
					if count >= LYDoTUnits then
						return
					end
				end
				local dotUnit = nil
				local maxStack = 10
				if IsTalentInUse(196102) then
					maxStack = 18
				end
				local pandemicTiming = 5.4
				if IsTalentInUse(264000) then pandemicTiming = 4.5 end
				pandemicTiming = pandemicTiming + LYMyPing
				local dTime = math.max(count*LYGCDTime,pandemicTiming)
				if stacks then
					for i=1,#LYEnemies do
						if ValidEnemyUnit(LYEnemies[i]) and inRange(WlAgony,LYEnemies[i]) and DebuffCount(LYEnemies[i],WlAgony,dTime) == maxStack then
							LYQueueSpell(WlAgony,LYEnemies[i])
							return true
						end
					end
				elseif IsTalentInUse(334319) or maxStack == 18 then
					for i=1,#LYEnemies do
						if ValidEnemyUnit(LYEnemies[i]) and inRange(WlAgony,LYEnemies[i]) then
							if not HaveDebuff(LYEnemies[i],WlAgony,0,"player") then
								LYQueueSpell(WlAgony,LYEnemies[i])
								return true
							elseif not dotUnit and not HaveDebuff(LYEnemies[i],WlAgony,dTime,"player") then
								dotUnit = LYEnemies[i]
							end
						end
					end
					if dotUnit then
						LYQueueSpell(WlAgony,dotUnit)
						return true
					end
				end
			end
		end		
		local function DrainSoulRot()
			if GCDCheck(WlDrainLife) and LYStyle ~= "Utilities only" and UnitChannelInfo("player") ~= WlDrainLife and ValidEnemyUnit(LYEnemyTarget) and inRange(WlDrainLife,LYEnemyTarget) and BuffCount("player",WlInevDemise) > 49 and LYFacingCheck(LYEnemyTarget) then
				if GCDCheck(WlSoulRot) then
					LYQueueSpell(WlSoulRot,LYEnemyTarget)
					return true
				else
					if GCDCheck(WlSoulBurn) then
						CastSpellByName(WlSoulBurn)
					end
					LYQueueSpell(WlDrainLife,LYEnemyTarget)
					return true
				end
			end
		end
		local pandemicAgony = 5.4
		local pandemicCorruption = 4.2
		local pandemicSiphon = 4.5
		local function SetVar()
			if IsTalentInUse(264000) then
				pandemicAgony = 4.5
				pandemicCorruption = 3.5
				pandemicSiphon = 3.8
			end
			pandemicAgony = pandemicAgony + LYMyPing
			pandemicCorruption = pandemicCorruption + LYMyPing
		end
		if CommonKick(WlPetAbility,nil,"kick",HaveBuff("player",WlSac) and LYWlPetType == 1) or
		CommonKick(WlHowl,nil,"alt",LYWlHowlKick,9) or
		CommonKick(WlCoil,nil,"alt",LYWlCoilKick) or
		WlNethWard() or
		LYReflect(WlNetherWard,true) or
		CastKick(WlFear,LYWlFearKick,"fear") or
		CastKick(WlSF,LYWlSFKick,"stun") or
		AntiReflect(WlCurWeak) or
		AntiStealth(WlAgony) or
		TripleCC(WlHowl,LYWlHowlTripple,9) or
		PauseRotation or
		PetBehaviour() or
		BRDeadFriend() or
		TotemStomp(nil,rdpsTotem,40) or
		DefensiveOnPlayer(WlTP2,nil,LYWlTPHP,LYWlTPBurst,LYWlTPHealer,LYMode ~= "PvE" and TPX and GCDCheck(WlTP2) and (not InLineOfSightPointToUnit(TPX,TPY,TPZ) or GetDistancePointToUnit(TPX,TPY,TPZ) > 25) and GetDistancePointToUnit(TPX,TPY,TPZ) < 40) or
		DefensiveOnTeam(WlSoulRip,nil,nil,true,20,true) or
		ConditionalSpell(WlCastCircle,LYMode ~= "PvE" and GCDCheck(WlCastCircle) and EnemyCanKick()) or
		CommonAttack(WlCoil,nil,true,WlCoil,CalculateHP("player") < LYWlCoilPlayerHP) or
		FearCC(WlSeduction,nil,LYWlSedDR,LYWlSedHealer,LYWlSedHealerHP,LYWlSedHealerBurst,LYWlSedDPS,LYWlSedDPSHP,LYWlSedDPSBurst,LYWlSedCont,LYWlSedFocus,nil,25,LYWlFearWhileBurst) or
		FearCC(WlFear,nil,LYWlFearDR,LYWlFearHealer,LYWlFearHealerHP,LYWlFearHealerBurst,LYWlFearDPS,LYWlFearDPSHP,LYWlFearDPSBurst,LYWlFearCont,LYWlFearFocus,true,nil,LYWlFearWhileBurst) or
		StunCC(WlSF,nil,LYWlSFDR,LYWlSFHealer,LYWlSFHealerHP,LYWlSFHealerBurst,LYWlSFDPS,LYWlSFDPSHP,LYWlSFDPSBurst,nil,LYWlSFFocus,35) or
		ControlCC(WlCoil,nil,LYWlCoilDR,LYWlCoilHealer,LYWlCoilHealerHP,LYWlCoilHealerBurst,LYWlCoilDPS,LYWlCoilDPSHP,LYWlCoilDPSBurst,LYWlCoilCont,LYWlCoilFocus) or
		CommonAttack(WlDrainLife,nil,true,WlDrainLife,not IsMoving() and CalculateHP("player") < LYWlDrainHP and UnitChannelInfo("player") ~= WlDrainLife) or
		WlSummonPet() or
		ConditionalSpell(WlSac,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and not HaveBuff("player",ArenaPrepBuff)) or
		WlBanishTyrant() or
		Burst() or
		SetVar() or
		CommonAttackTarget(WlHaunt,nil,nil,GCDCheck(WlHaunt) and not IsMoving() and inRange(WlShadowBolt,LYEnemyTarget) and LYMode == "PvE" and UnitIsBoss(LYEnemyTarget)) or
		CommonAttack(WlVileTaint,nil,true,WlShadowBolt,not IsMoving(),0,WlVileTaint,LYWlVileTaint) or
		CommonAttack(WlSeed,nil,true,WlShadowBolt,not IsMoving() and LYZoneType ~= "arena" and not DoNotUsePower,0,WlSeed,LYWlSeedCount) or
		Agony(true) or
		CommonAttack(WlShadowBolt,nil,true,WlShadowBolt,HaveBuff("player",WlNighfall) and HaveAllDebuffs(LYEnemyTarget,listWlDoTs)) or
		DrainSoulRot() or
		ConditionalSpell(WlMalRapture,(EnemiesAroundUnitDoTed(nil,nil,listWlDoTs,true,2) > 0 and (LYUP > 3 or HaveBuff("player",WlTormCres)))) or
		Unstable(LYZoneType ~= "arena" or not EnemyCanKick() or HaveBuff("player",WlMA) or LYWlUAIgnoreKick) or
		CommonAttackTarget(WlHaunt,nil,nil,GCDCheck(WlHaunt) and not IsMoving() and inRange(WlShadowBolt,LYEnemyTarget) and HaveAllDebuffs(LYEnemyTarget,listWlDoTs,7)) or
		ConditionalSpell(WlObservCall,GCDCheck(WlObservCall) and EnemyIsBursting(25)) or
		WlCurses(IsPvPTalentInUse(5386)) or
		Agony() or
		WlCurses(true) or
		SlowTarget(WlCurExhaus,nil,nil,LYSlowAlways) or
		Peel(WlCurExhaus,nil,LYPeelAny,LYPeelHealer) or
		CommonAttack(WlCorrupt,nil,nil,WlCorrupt,true,pandemicCorruption,WlCorrupt) or
		CommonAttack(WlAgony,nil,nil,WlAgony,true,pandemicAgony,WlAgony) or
		CommonAttack(WlSiphon,nil,nil,WlSiphon,true,pandemicSiphon,WlSiphon) or
		Unstable(true) or
		CommonAttack(WlShadowBolt,nil,true,WlShadowBolt,HaveBuff("player",WlNighfall)) or
		ConditionalSpell(WlMalRapture,GCDCheck(WlMalRapture) and not IsMoving() and EnemiesAroundUnitDoTed(nil,nil,listWlDoTs,true,2) > 0) or
		CommonAttack(WlDrainLife,nil,true,WlDrainLife,not IsMoving() and (IsPvPTalentInUse(19) or CalculateHP("player") < 95) and not IsTalentInUse(334319) and UnitChannelInfo("player") ~= WlDrainLife) or
		CommonAttackTarget(WlPhantomSingul,nil,nil,GCDCheck(WlPhantomSingul) and not IsMoving() and inRange(WlShadowBolt,LYEnemyTarget) and (IsBursting() or CalculateHP("player") < 80 or CalculateHP(LYEnemyTarget) < 35 or LYMode ~= "PvP")) or
		CommonAttackTarget(WlCurFrag,nil,nil,GCDCheck(WlCurFrag) and inRange(WlShadowBolt,LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and CalculateHP(LYEnemyTarget) < LYWlCurFragHP and not HaveDebuff(LYEnemyTarget,WlCurFrag)) or
		CommonAttackTarget(WlVileTaint,nil,nil,GCDCheck(WlVileTaint) and CalculateHP(LYEnemyTarget) < LYWlVileTaintTar and not IsMoving() and inRange(WlShadowBolt,LYEnemyTarget) and HaveAllDebuffs(LYEnemyTarget,listWlDoTs,7)) or
		ConditionalSpell(WlHealthFunnel,GCDCheck(WlHealthFunnel) and not IsMoving() and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and IsInDistance("pet",45) and CalculateHP("pet") < 25 and not IsBursting() and CalculateHP("player") > 80) or
		CommonAttack(WlShadowBolt,nil,true,WlShadowBolt,not IsMoving() and not UnitChannelInfo("player")) or
		UpdateDoTs(WlAgony) or
		WlDemonArmor() or
		ConditionalSpell(WlSoulwell,LYMode ~= "PvE" and not UnitAffectingCombat("player") and HaveBuff("player",{ArenaPrepBuff,RgPrep}) and not IsMoving()) then
			return true
		end
	end
	function LYWarlockDemon()
		local rdpsTotem = {WlShadowBolt}
		if HaveBuff("player",WlDemCore) then
			rdpsTotem = {WlDemonbolt,WlShadowBolt}
		elseif LYWlPetsCount > 0 then
			rdpsTotem = {WlImplosion,WlShadowBolt}
		end
		local function Burst()
			if not IsMoving() and BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,nil,WlShadowBolt) then
				if GCDCheck(WlServFguard) and GetTotemInfo(1) then
					LYQueueSpell(WlServFguard,LYEnemyTarget)
					LY_Print(WlServFguard,"green",WlServFguard)
					return true
				end
				if GetTotemInfo(1) and GetTotemInfo(2) and GCDCheck(WlSumDemTyrant) and not IsMoving() then
					if LYWlURBurst and GCDCheck(WlMA) and EnemyCanKick() then
						CastSpellByName(WlMA)
						LY_Print(WlMA,"green",WlMA)
					end
					LYQueueSpell(WlSumDemTyrant)
					LY_Print(WlSumDemTyrant,"green",WlSumDemTyrant)
					return true
				end
				if GCDCheck(WlDemStrgth) and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and WlPetType == 5 and not UnitIsCCed("pet") and not HaveBuff("pet",WlFelstorm) then
					LYQueueSpell(WlDemStrgth,LYEnemyTarget)
					LY_Print(WlDemStrgth,"green",WlDemStrgth)
					return true
				end
				if GCDCheck(WlObservCall) and LYMode ~= "PvE" and IsInDistance(LYEnemyTarget,20) then
					LYQueueSpell(WlObservCall)
					LY_Print(WlObservCall,"green",WlObservCall)
					return true
				end
			end
		end
		local function WarlockPetsCount()
			local count = 0
			if LYWlPetsTime < GetTime() then
				for i=1,GetObjectCount() do
					local pointer = GetObjectWithIndex(i)
					if UnitIsVisible(pointer) and not UnitIsDeadOrGhost(pointer) and (UnitName(pointer) == WlWildImp or UnitName(pointer) == WlWildImpBoss) then
						local creator = UnitCreator(pointer)
						if UnitIsVisible(creator) and UnitIsUnit(creator,"player") then
							count = count + 1
						end
					end
				end
				LYWlPetsCount = count
				LYWlPetsTime = GetTime() + 1
			end
		end
		if CommonKick(WlPetAbility,nil,"kick",HaveBuff("player",WlSac) and LYWlPetType == 1) or
		CommonKick(WlKickTalent,nil,"kick",LYMode ~= "PvE") or
		CommonKick(WlHowl,nil,"alt",LYWlHowlKick,9) or
		CommonKick(WlCoil,nil,"alt",LYWlCoilKick) or
		CommonKick(WlAxes,"phys","alt",LYWlAxesKick,40) or
		WlNethWard() or
		LYReflect(WlNetherWard,true) or
		CastKick(WlFear,LYWlFearKick,"fear") or
		CastKick(WlSF,LYWlSFKick,"stun") or
		AntiReflect(WlCurWeak) or
		AntiStealth(WlCurWeak) or
		TripleCC(WlHowl,LYWlHowlTripple,9) or
		PauseRotation or
		PetBehaviour() or
		WarlockPetsCount() or
		BRDeadFriend() or
		TotemStomp(nil,rdpsTotem,40) or
		DefensiveOnPlayer(WlTP2,nil,LYWlTPHP,LYWlTPBurst,LYWlTPHealer,LYMode ~= "PvE" and TPX and GCDCheck(WlTP2) and (not InLineOfSightPointToUnit(TPX,TPY,TPZ) or GetDistancePointToUnit(TPX,TPY,TPZ) > 25) and GetDistancePointToUnit(TPX,TPY,TPZ) < 40) or
		DefensiveOnTeam(WlSoulRip,nil,nil,true,20,true) or
		StunCC(WlAxes,"phys",LYWlAxesDR,LYWlAxesHealer,LYWlAxesHealerHP,LYWlAxesHealerBurst,LYWlAxesDPS,LYWlAxesDPSHP,LYWlAxesDPSBurst,LYWlAxesCont,LYWlAxesFocus,30) or
		DefensiveOnTeam(WlFellLord,"MELEE",LYWlFellLordHP,LYWlFellLordBurst,40,LYMode ~= "PvE") or
		ConditionalSpell(WlCastCircle,LYMode ~= "PvE" and GCDCheck(WlCastCircle) and EnemyCanKick()) or
		CommonAttack(WlCoil,nil,true,WlCoil,CalculateHP("player") < LYWlCoilPlayerHP) or
		FearCC(WlSeduction,nil,LYWlSedDR,LYWlSedHealer,LYWlSedHealerHP,LYWlSedHealerBurst,LYWlSedDPS,LYWlSedDPSHP,LYWlSedDPSBurst,LYWlSedCont,LYWlSedFocus,nil,25,LYWlFearWhileBurst) or
		FearCC(WlFear,nil,LYWlFearDR,LYWlFearHealer,LYWlFearHealerHP,LYWlFearHealerBurst,LYWlFearDPS,LYWlFearDPSHP,LYWlFearDPSBurst,LYWlFearCont,LYWlFearFocus,true,nil,LYWlFearWhileBurst) or
		StunCC(WlSF,nil,LYWlSFDR,LYWlSFHealer,LYWlSFHealerHP,LYWlSFHealerBurst,LYWlSFDPS,LYWlSFDPSHP,LYWlSFDPSBurst,nil,LYWlSFFocus,35) or
		ControlCC(WlCoil,nil,LYWlCoilDR,LYWlCoilHealer,LYWlCoilHealerHP,LYWlCoilHealerBurst,LYWlCoilDPS,LYWlCoilDPSHP,LYWlCoilDPSBurst,LYWlCoilCont,LYWlCoilFocus) or
		CommonAttack(WlDrainLife,nil,true,WlDrainLife,not IsMoving() and CalculateHP("player") < LYWlDrainHP and UnitChannelInfo("player") ~= WlDrainLife) or
		WlSummonPet() or
		WlBanishTyrant() or
		WlCurses(true) or
		SlowTarget(WlCurExhaus,nil,nil,LYSlowAlways) or
		Peel(WlCurExhaus,nil,LYPeelAny,LYPeelHealer) or
		Burst() or
		AOEAttack(WlBilesBomber,8,WlShadowBolt,LYWlBilesBomber,true) or
		ConditionalSpell(WlPowerSiph,LYWlPetsCount > 1 and not HaveBuff("player",WlDemCore) and UnitAffectingCombat("player")) or
		CommonAttack(WlDreadstalker,nil,nil,WlDreadstalker,(not IsMoving() or HaveBuff("player",WlDemCall) or IsPvPTalentInUse(1213))) or
		CommonAttack(WlDoom,nil,nil,WlDoom,true,0,WlDoom) or
		CommonAttackTarget(WlCurFrag,nil,nil,GCDCheck(WlCurFrag) and inRange(WlShadowBolt,LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and CalculateHP(LYEnemyTarget) < LYWlCurFragHP and not HaveDebuff(LYEnemyTarget,WlCurFrag)) or
		CommonAttack(WlDemonbolt,nil,nil,WlGuldan,HaveBuff("player",WlDemCore) and LYUP < 4) or
		ConditionalSpell(WlObservCall,GCDCheck(WlObservCall) and EnemyIsBursting(25)) or
		CommonAttackTarget(WlGuillotine,nil,nil,GCDCheck(WlGuillotine) and inRange(WlShadowBolt,LYEnemyTarget) and LYWlPetType == 5 and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and not UnitIsCCed("pet") and not BreakCCAroundUnit(LYEnemyTarget,10) and CDLeft(WlFelstorm) > 6) or
		CommonAttackTarget(WlImplosion,nil,nil,GCDCheck(WlImplosion) and inRange(WlShadowBolt,LYEnemyTarget) and (LYMode ~= "PvP" or UnitIsPlayer(LYEnemyTarget)) and LYLastSpellName ~= WlImplosion and LYWlPetsCount > 1) or
		CommonAttack(WlGuldan,nil,nil,WlGuldan,not IsMoving() and LYUP > 2) or
		ConditionalSpell(WlSumVilef,GCDCheck(WlSumVilef) and not IsMoving() and UnitAffectingCombat("player") and #LYEnemies > 0) or
		ConditionalSpell(WlHealthFunnel,GCDCheck(WlHealthFunnel) and not IsMoving() and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and IsInDistance("pet",45) and CalculateHP("pet") < 25 and not IsBursting() and CalculateHP("player") > 80) or
		CommonAttackTarget(WlFelstorm,"phys",nil,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and not UnitIsCCed("pet") and IsInDistance("pet",5,LYEnemyTarget) and not BreakCCAroundUnit("pet",10)) or
		CommonAttack(WlShadowBolt,nil,true,WlShadowBolt,not IsMoving()) or
		ConditionalSpell(WlSoulwell,LYMode ~= "PvE" and not UnitAffectingCombat("player") and HaveBuff("player",{ArenaPrepBuff,RgPrep}) and not IsMoving())	then
			return true
		end
	end
	function LYWarlockDestr()
		local function Burst()
			if not IsMoving() and BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,nil,WlConflag) and GCDCheck(WlChaosBolt) then
				if GCDCheck(WlSumInf) then
					LYQueueSpell(WlSumInf,LYEnemyTarget)
					LY_Print(WlSumInf,"green",WlSumInf)
					return true
				end
				if GCDCheck(WlObservCall) and LYMode ~= "PvE" and IsInDistance(LYEnemyTarget,20) then
					LYQueueSpell(WlObservCall)
					LY_Print(WlObservCall,"green",WlObservCall)
					return true
				end
			end
		end
		local function Havoc()
			if CDCheck(WlChaos) and LYWlHavocDPS and LYStyle == "All units" and UnitIsVisible(LYCurrentSpellTarget) and ((LYCurrentSpellName == WlChaosBolt and not IsPvPTalentInUse(155)) or LYCurrentSpellName == WlCoil or (LYCurrentSpellName == WlConflag and IsPvPTalentInUse(155)) or (LYCurrentSpellName == WlEmber and IsPvPTalentInUse(155))) then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and inRange(WlConflag,LYEnemies[i]) and not UnitIsUnit(LYCurrentSpellTarget,LYEnemies[i]) then
						LYSpellStopCasting()
						LYQueueSpell(WlChaos,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function ChaosBoltCanCast()
			if not LYWlChaosBoltSet or LYUP > 3 or LYLastSpellName == WlChaosBolt then
				return true
			end
		end
		if CommonKick(WlPetAbility,nil,"kick",HaveBuff("player",WlSac) and LYWlPetType == 1) or
		CommonKick(WlHowl,nil,"alt",LYWlHowlKick,9) or
		CommonKick(WlCoil,nil,"alt",LYWlCoilKick) or
		WlNethWard() or
		LYReflect(WlNetherWard,true) or
		CastKick(WlFear,LYWlFearKick and castNameP ~= WlChaosBolt,"fear") or
		CastKick(WlSF,LYWlSFKick,"stun") or
		Havoc() or
		AntiReflect(WlCurWeak) or
		AntiStealth(WlConflag) or
		TripleCC(WlHowl,LYWlHowlTripple,9) or
		PauseRotation or
		PetBehaviour() or
		BRDeadFriend() or
		TotemStomp(nil,{WlConflag,WlEmber,WlIncin},40) or
		DefensiveOnPlayer(WlTP2,nil,LYWlTPHP,LYWlTPBurst,LYWlTPHealer,LYMode ~= "PvE" and TPX and GCDCheck(WlTP2) and (not InLineOfSightPointToUnit(TPX,TPY,TPZ) or GetDistancePointToUnit(TPX,TPY,TPZ) > 25) and GetDistancePointToUnit(TPX,TPY,TPZ) < 40) or
		DefensiveOnTeam(WlSoulRip,nil,nil,true,20,true) or
		ConditionalSpell(WlCastCircle,LYMode ~= "PvE" and GCDCheck(WlCastCircle) and EnemyCanKick()) or
		CommonAttack(WlDrainLife,nil,true,WlDrainLife,not IsMoving() and CalculateHP("player") < LYWlDrainHP and UnitChannelInfo("player") ~= WlDrainLife) or
		FearCC(WlFear,nil,LYWlFearDR,LYWlFearHealer,LYWlFearHealerHP,LYWlFearHealerBurst,LYWlFearDPS,LYWlFearDPSHP,LYWlFearDPSBurst,LYWlFearCont,LYWlFearFocus,true,nil,LYWlFearWhileBurst) or
		FearCC(WlSeduction,nil,LYWlSedDR,LYWlSedHealer,LYWlSedHealerHP,LYWlSedHealerBurst,LYWlSedDPS,LYWlSedDPSHP,LYWlSedDPSBurst,LYWlSedCont,LYWlSedFocus,nil,25,LYWlFearWhileBurst) or
		StunCC(WlSF,nil,LYWlSFDR,LYWlSFHealer,LYWlSFHealerHP,LYWlSFHealerBurst,LYWlSFDPS,LYWlSFDPSHP,LYWlSFDPSBurst,nil,LYWlSFFocus,35) or
		ControlCC(WlCoil,nil,LYWlCoilDR,LYWlCoilHealer,LYWlCoilHealerHP,LYWlCoilHealerBurst,LYWlCoilDPS,LYWlCoilDPSHP,LYWlCoilDPSBurst,LYWlCoilCont,LYWlCoilFocus) or
		CommonAttack(WlCoil,nil,true,WlCoil,CalculateHP("player") < LYWlCoilPlayerHP) or
		WlSummonPet() or
		ConditionalSpell(WlSac,UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and not HaveBuff("player",ArenaPrepBuff)) or
		WlBanishTyrant() or
		WlCurses(true) or
		SlowTarget(WlCurExhaus,nil,nil,LYSlowAlways) or
		Peel(WlCurExhaus,nil,LYPeelAny,LYPeelHealer) or
		Burst() or
		CommonAttackTarget(WlChaosBolt,nil,true,not DoNotUsePower and not IsMoving() and ChaosBoltCanCast() and (LYBurstMacro or HaveBuff("player",WlMA) or GetTotemInfo(1)) and inRange(WlConflag,LYEnemyTarget) and HaveBuff("player",WlBackdraft)) or
		AOEAttack(WlRainFire,8,WlConflag,LYWlRainFire,not DoNotUsePower and (LYZoneType ~= "arena" or (IsMoving() and LYUP > 4))) or
		AOEAttack(WlCata,8,WlConflag,LYWlCata,not IsMoving() and LYUP < 5) or
		CommonAttack(WlImmolate,nil,true,WlIncin,not IsMoving() and LYUP < 5 and LYLastSpellName ~= WlCata and (not HaveBuff("player",WlMA) or not GCDCheck(WlChaosBolt)),6,WlImmolate) or
		ConditionalSpell(WlDemFire,not IsMoving() and LYUP < 5) or
		CommonAttackTarget(WlSoulFire,nil,true,GCDCheck(WlSoulFire) and not IsMoving() and LYUP < 5 and inRange(WlSoulFire,LYEnemyTarget) and (UnitIsCCed(WlSoulFire,3) or IsRooted(WlSoulFire,3))) or
		CommonAttackTarget(WlCurFrag,nil,nil,GCDCheck(WlCurFrag) and inRange(WlShadowBolt,LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and CalculateHP(LYEnemyTarget) < LYWlCurFragHP and not HaveDebuff(LYEnemyTarget,WlCurFrag)) or
		CommonAttack(WlEmber,nil,true,WlEmber,true,nil,nil,nil,20) or
		ConditionalSpell(WlObservCall,GCDCheck(WlObservCall) and EnemyIsBursting(25)) or
		CommonAttackTarget(WlDimRift,nil,true,IsTalentInUse(387976) and C_Spell.GetSpellCharges(WlDimRift).currentCharges > 2) or
		CommonAttackTarget(WlChaosBolt,nil,true,not DoNotUsePower and not IsMoving() and ChaosBoltCanCast() and inRange(WlConflag,LYEnemyTarget) and HaveBuff("player",WlBackdraft)) or
		AOEAttack(WlRainFire,8,WlConflag,1,IsMoving() and GetTotemInfo(1) and LYUP > 4) or
		CommonAttack(WlConflag,nil,true,WlConflag,not HaveBuff("player",WlBackdraft)) or
		CommonAttack(WlEmber,nil,true,WlEmber,GCDCheck(WlEmber) and LYUP > 3 and SpellChargesCheck(WlEmber)) or
		ConditionalSpell(WlHealthFunnel,GCDCheck(WlHealthFunnel) and not IsMoving() and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and IsInDistance("pet",45) and CalculateHP("pet") < 25 and not IsBursting() and CalculateHP("player") > 80) or
		CommonAttack(WlIncin,nil,true,WlIncin,(not IsMoving() or HaveBuff("player",WlChaotic))) or
		CommonAttackTarget(WlDimRift,nil,true,true) or
		WlDemonArmor() or
		ConditionalSpell(WlSoulwell,LYMode ~= "PvE" and not UnitAffectingCombat("player") and HaveBuff("player",{ArenaPrepBuff,RgPrep}) and not IsMoving()) then
			return true
		end
	end
	function LYWarriorArms()
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,nil,WrMortal) then
				if ((not IsTalentInUse(262161) and GCDCheck(WrColos)) or (IsTalentInUse(262161) and GCDCheck(WrWarBreak))) and LYWrColosBurst and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(WrColos,LYEnemyTarget)
					LY_Print(WrColos,"green",WrColos)
					return true
				end
				if GCDCheck(WrAvatar) then
					LYQueueSpell(WrAvatar)
					LY_Print(WrAvatar,"green",WrAvatar)
					return true
				end
				if GCDCheck(WrSpearBast) then
					LYQueueSpell(WrSpearBast,LYEnemyTarget)
					LY_Print(WrSpearBast,"green",WrSpearBast)
					return true
				end
				if GCDCheck(WrBS) and not GCDCheck(WrColos) and not BreakCCAroundUnit("player",10) and LYWrBSBurst and (not IsTalentInUse(772) or HaveDebuff(LYEnemyTarget,WrDoT)) and not (IsTalentInUse(384318) and HaveAllDebuffs(LYEnemyTarget,{WrDoT,WrDW}) and GCDCheck(WrRoar)) then
					LYQueueSpell(WrBS)
					LY_Print(WrBS,"green",WrBS)
					return true
				end
			end
		end
		local function BannerCC()
			if GCDCheck(WrBanner) and LYMode ~= "PvE" and LYKickPause == 0 then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemyHealers[i]) then
						local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
						if castName and tContains(listRefl,castName) then
							local spellTar = GetSpellDestUnit(LYEnemies[i])
							if UnitIsVisible(spellTar) and not HaveBuff(spellTar,listIMagic) and (not GCDCheck(WrKick) or not inRange(WrKick,LYEnemies[i])) and (CheckRole(spellTar) == "HEALER" or (LYWrBannerDPS and ((LYWrBannerBurst and IsBursting(spellTar)) or EnemyHPBelow(LYWrBannerEnemyHP)))) and CheckUnitDRSpell(spellTar,castName) then
								local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
								local castTime = (castEndTime - castStartTime)
								local currentPercent = timeSinceStart / castTime * 100
								if currentPercent > 70 then
									CastSpellByName(WrBanner)
									LYKickPause = GetTime()
									LY_Print(WrBanner.." "..castName,"green",WrBanner)
									return true
								end
							end
						end
					end
				end
			end
		end
		local function Duel()
			if GCDCheck(WrDuel) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and not UnitIsUnit("player",LYTeamPlayers[i]) and UnitIsPlayer(LYTeamPlayers[i]) then
						local enemy = FriendIsUnderAttack(LYTeamPlayers[i],nil,LYWrDuelHP,LYWrDuelBurst)
						if UnitIsVisible(enemy) and inRange(WrDuel,enemy) and LYFacingCheck(enemy) then
							CastSpellByName(WrDuel,enemy)
							return
						end
					end
				end
			end
		end
		local function PrioMortal()
			if GCDCheck(WrMortal) and LYStyle ~= "Utilities only" then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and inRange(WrMortal,LYEnemies[i]) and (BuffCount("player",WrMartProw) > 1 or DebuffCount(LYEnemies[i],WrExePrecis) > 1) and LYFacingCheck(LYEnemies[i]) then
						LYQueueSpell(WrMortal,LYEnemies[i])
						return true
					end
				end
			end
		end
		if WrKickPlayers() or
		WrReflectIncCC() or
		BannerCC() or
		LYReflect(WrReflect,true) or
		TauntCC(WrTaunt) or
		WrInterveneIncCC() or
		WrStance() or
		WrCancelBSKick() or
		PauseRotation or
		DefensiveOnPlayer(WrDbS,nil,LYWrDbSHP,LYWrDbSBurst,LYWrDbSHealer,true) or
		DefensiveOnPlayer(WrReflect,"WIZARD",LYWrReflDefHP,LYWrReflDefBurst,LYWrReflHealer,LYMode ~= "PvE") or
		DefensiveOnPlayer(WrBitterImmune,nil,LYWrHealHP,LYWrHealBurst,LYWrHealHealer,true) or
		Duel() or
		WrInterveneCast() or
		ConditionalSpell(WrSharpBlade,GCDCheck(WrSharpBlade) and GCDCheck(WrMortal) and (CalculateHP(LYEnemyTarget) < LYWrShBladeHP or IsBursting() or AllEnemyHealCCed())) or
		DefensiveOnPlayer(WrIgnorePain,nil,LYWrIgnorePainHP,LYWrIgnorePainBurst,LYWrIgnorePainHealer,LYMode ~= "PvE") or
		WrStopBS() or
		WrShatThrowCast() or
		CommonKick(WrBolt,nil,"alt",LYWrBoltKick) or
		CommonKick(WrFear,nil,"kick",LYWrFearKick) or
		TripleCC(WrFear,LYWrFearTrpl,8) or
		AntiStealth(WrTaunt) or
		TotemStomp({WrOver,WrMortal,WrSlam},{WrThrow},30) or
		CommonAttack(WrVRush,nil,true,WrVRush,IsTalentInUse(202168) and CalculateHP("player") < 60 and (not TeamHealerCanInteract() or CalculateHP("player") < 40)) or
		StunCC(WrBolt,nil,LYWrBoltDR,LYWrBoltHealer,LYWrBoltHealerHP,LYWrBoltBurst,LYWrBoltDPS,LYWrBoltDPSHP,LYWrBoltDPSBurst,LYWrBoltCont,LYWrBoltFocus) or
		StunCC(WrSW,nil,LYWrSWDR,LYWrSWHealer,LYWrSWHealerHP,LYWrSWHealerBurst,LYWrSWDPS,LYWrSWDPSHP,LYWrSWDPSBurst,LYWrSWCont,nil,8) or
		FearCC(WrFear,nil,LYWrFearDR,LYWrFearHealer,LYWrFearHealerHP,LYWrFearBurst,LYWrFearDPS,LYWrFearDPSHP,LYWrFearDPSBurst,LYWrFearCont) or
		TripleCC(WrSW,LYWrSWTripple,8) or
		DefensiveOnTeam(WrRaly,nil,LYWrRally,nil,nil,true) or
		Disarm(WrDisarm,LYWrDisarmHP,LYWrDisarmBurst,LYWrDisarmHealer,LYWrDisarmFocus) or
		CommonAttack(WrVRush,nil,true,WrVRush,not IsTalentInUse(202168) and CalculateHP("player") < 90) or
		AutoBuffParty(WrAP) or
		SlowTarget(WrHarm,nil,nil,LYSlowAlways) or
		WrPiercHowlCast() or
		Peel(WrHarm,nil,LYPeelAny,LYPeelHealer) or
		WrDemolition() or
		Burst() or
		CommonAttack(WrColos,nil,nil,WrMortal,LYWrColosCount ~= 0 and IsTalentInUse(262161) and EnemiesAroundUnit(WrMortal) >= LYWrColosCount and not HaveDebuff("player",listDisarm)) or
		AOEAttack(WrSpearBast,8,WrThrow,3,true) or
		ConditionalSpell(WrRoar,((LYWrRoarCount ~= 0 and EnemiesAroundUnitDoTed(12,"player",{WrDoT,WrDW}) >= LYWrRoarCount) or (LYWrRoarBurst and IsBursting() and EnemiesAroundUnitDoTed(12,"player",{WrDoT,WrDW},true) > 0)) and not GCDCheck(WrColos)) or
		PrioMortal() or
		WrExecuteCast() or
		CommonAttack(WrDoT,nil,true,WrDoT,IsBursting(),4,WrDoT) or
		ConditionalSpell(WrBS,LYWrBSCount ~= 0 and not GCDCheck(WrColos) and EnemiesAroundUnit(WrMortal) >= LYWrBSCount) or
		ConditionalSpell(WrSwStrk,LYStyle == "All units" and not DoNotUsePower and EnemiesAroundUnit(WrMortal) > 1 and GCDCheck(WrMortal)) or
		CommonAttack(WrColos,nil,true,WrMortal,not HaveDebuff("player",listDisarm),nil,nil,nil,LYWrColosHP) or
		CommonAttack(WrOver,nil,true,WrOver,GCDCheck(WrOver) and IsTalentInUse(262150) and SpellChargesCheck(WrOver) and not BreakCCAroundUnit("player",10)) or
		CommonAttack(WrMortal,nil,true,WrMortal,not DoNotUsePower) or
		ConditionalSpell(WrThunder,GCDCheck(WrThunder) and UnitAffectingCombat("player") and not DoNotUsePower and (not LYHDPS or LYUP > LYUPMax-10) and not BreakCCAroundUnit("player",10) and (LYUP > 69 or (IsTalentInUse(384277) and EnemiesAroundUnit(8,"player",WrDoT) > 0))) or
		CommonAttack(WrDoT,nil,true,WrDoT,not DoNotUsePower,4,WrDoT) or
		CommonAttack(WrCleave,nil,true,WrMortal,not DoNotUsePower and EnemiesAroundUnit(WrMortal) > 2) or
		CommonAttack(WrSkul,nil,true,WrSkul,LYUP < LYUPMax - 30) or
		CommonAttack(WrStorm,nil,nil,WrMortal,not DoNotUsePower and EnemiesAroundUnit(WrMortal) > 1 and not HaveBuff("player",WrSwStrk) and LYUP > 49) or
		CommonAttack(WrOver,nil,true,WrOver,(not IsTalentInUse(262150) or not BreakCCAroundUnit("player",10))) or
		CommonAttack(WrSlam,nil,true,WrSlam,not DoNotUsePower and (not LYHDPS or LYUP > LYUPMax-10) and LYUP > 49) or
		WrThrowStealth() or
		ConnecTarget(WrCharge,LYWrChargeBurst,LYWrChargeHP) then
			return true
		end
	end
	function LYWarriorFury()
		local meleeTotem = {WrBloodThirst,WrRagBlow,WrSlam}
		if IsTalentInUse(383916) then
			meleeTotem = {WrBloodThirst,WrSlam}
		end
		local function Burst()
			if BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,nil,WrBloodThirst) then
				if GCDCheck(WrReck) and (not IsTalentInUse(202751) or LYUP < 50) then
					LYQueueSpell(WrReck)
					LY_Print(WrReck,"green",WrReck)
					return true
				end
				if GCDCheck(WrAvatar) then
					LYQueueSpell(WrAvatar)
					LY_Print(WrAvatar,"green",WrAvatar)
					return true
				end
				if GCDCheck(WrSpearBast) then
					LYQueueSpell(WrSpearBast,LYEnemyTarget)
					LY_Print(WrSpearBast,"green",WrSpearBast)
					return true
				end
				if GCDCheck(WrRavager) and LYFacingCheck(LYEnemyTarget) then
					LYQueueSpell(WrRavager,LYEnemyTarget)
					LY_Print(WrRavager,"green", WrRavager)
					return true
				end
			end
		end
		if WrKickPlayers() or
		WrReflectIncCC() or
		LYReflect(WrReflect,true) or
		TauntCC(WrTaunt) or
		WrInterveneIncCC() or
		WrStance() or
		PauseRotation or
		DefensiveOnPlayer(WrHeal,nil,LYWrHealHP,LYWrWrHealBurst,LYWrWrHealHealer,true) or
		DefensiveOnPlayer(WrReflect,"WIZARD",LYWrReflDefHP,LYWrReflDefBurst,LYWrReflHealer,LYMode ~= "PvE") or
		DefensiveOnPlayer(WrBitterImmune,nil,LYWrBitterImmuneHP,LYWrBitterImmuneBurst,LYWrBitterImmuneHealer,true) or
		WrInterveneCast() or
		WrShatThrowCast() or
		CommonKick(WrBolt,nil,"alt",LYWrBoltKick) or
		CommonKick(WrFear,nil,"kick",LYWrFearKick) or
		AntiStealth(WrTaunt) or
		TripleCC(WrFear,LYWrFearTrpl,8) or
		CommonAttack(WrRagBlow,nil,true,WrRagBlow,IsPvPTalentInUse(170) and LYLastSpellName == WrRagBlow and not HaveBuff("player",WrBattleTrance,15)) or
		TotemStomp(meleeTotem,{WrThrow},30) or
		CommonAttack(WrVRush,nil,true,WrVRush,IsTalentInUse(202168) and CalculateHP("player") < 60 and (not TeamHealerCanInteract() or CalculateHP("player") < 40)) or
		StunCC(WrBolt,nil,LYWrBoltDR,LYWrBoltHealer,LYWrBoltHealerHP,LYWrBoltBurst,LYWrBoltDPS,LYWrBoltDPSHP,LYWrBoltDPSBurst,LYWrBoltCont,LYWrBoltFocus) or
		StunCC(WrSW,nil,LYWrSWDR,LYWrSWHealer,LYWrSWHealerHP,LYWrSWHealerBurst,LYWrSWDPS,LYWrSWDPSHP,LYWrSWDPSBurst,LYWrSWCont,nil,8) or
		FearCC(WrFear,nil,LYWrFearDR,LYWrFearHealer,LYWrFearHealerHP,LYWrFearBurst,LYWrFearDPS,LYWrFearDPSHP,LYWrFearDPSBurst,LYWrFearCont) or
		TripleCC(WrSW,LYWrSWTripple,8) or
		DefensiveOnTeam(WrRaly,nil,LYWrRally,nil,nil,true) or
		Disarm(WrDisarm,LYWrDisarmHP,LYWrDisarmBurst,LYWrDisarmHealer,LYWrDisarmFocus) or
		CommonAttack(WrVRush,nil,true,WrVRush,not IsTalentInUse(202168) and CalculateHP("player") < 90) or
		AutoBuffParty(WrAP) or
		SlowTarget(WrHarm,nil,nil,LYSlowAlways) or
		WrPiercHowlCast() or
		Peel(WrHarm,nil,LYPeelAny,LYPeelHealer) or
		Burst() or
		CommonAttack(WrBloodThirst,nil,true,WrBloodThirst,(HaveBuff("player",WrHeal) and CalculateHP("player") < 90) or BuffCount("player",WrMerciAss) > 9) or
		ConditionalSpell(WrRoar,(LYWrRoarCount ~= 0 and EnemiesAroundUnit(7) >= LYWrRoarCount) or (LYWrRoarBurst and IsBursting() and EnemiesAroundUnit(7) > 0)) or
		ConditionalSpell(WrFArt,EnemiesAroundUnit(5) > 0 and not BreakCCAroundUnit("player",10)) or
		AOEAttack(WrSpearBast,8,WrThrow,3,true) or
		CommonAttack(WrDeathWish,nil,true,WrBloodThirst,LYMode ~= "PvE" and GCDCheck(WrDeathWish) and BuffCount("player",WrDeathWish,LYGCDTime*3) < 10 and CalculateHP("player") > LYWrDWishHP and (not LYWrDWishAttack or not FriendIsUnderAttack("player")) and (not LYWrDWishHealer or TeamHealerCanInteract())) or
		ConditionalSpell(WrStorm,EnemiesAroundUnit(7) > 1 and IsTalentInUse(12950) and not HaveBuff("player",WrStorm) and not BreakCCAroundUnit("player",10)) or
		CommonAttack(WrRampage,nil,true,WrRampage,not LYHDPS or LYUP == LYUPMax) or
		ConditionalSpell(WrRoar,LYWrRoarBurst and EnemiesAroundUnit(7) > 0 and HaveBuff("player",{WrReck,WrAvatar})) or
		WrExecuteCast() or
		CommonAttack(WrOnslaught,nil,true,WrBloodThirst,true) or
		CommonAttack(WrRagBlow,nil,true,WrRagBlow,GCDCheck(WrRagBlow) and SpellChargesCheck(WrRagBlow)) or
		CommonAttack(WrBloodThirst,nil,true,WrBloodThirst,true) or
		ConditionalSpell(WrStorm,EnemiesAroundUnit(7) > 0 and not BreakCCAroundUnit("player",10) and CDLeft(WrBloodThirst) > LYGCDTime and CDLeft(WrRagBlow) > LYGCDTime) or
		WrThrowStealth() or
		ConnecTarget(WrCharge,LYWrChargeBurst,LYWrChargeHP) then
			return true
		end
	end
	function LYWarriorProt()
		local function DragonKick()
			if GCDCheck(WrDrCharge) and LYMode ~= "PvE" and LYKickPause == 0 then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) then
						local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
						local channelName,_,_,channelStartTime,channelEndTime = UnitChannelInfo(LYEnemies[i])
						local modified = nil
						if channelName then
							castName = channelName
							castStartTime = channelStartTime
							castEndTime = channelEndTime
							modified = true
						end
						if castName and IsInDistance(LYEnemies[i],10) and not tContains(LYListNotKick,castName) and ValidKick(LYEnemies[i],castName) and not UnitCanCastOnMove(castName,LYEnemies[i]) then
							local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
							local castTime = castEndTime - castStartTime
							local currentPercent = timeSinceStart / castTime * 100
							if (currentPercent > KickTime or (modified and timeSinceStart > KickDelayFixed)) and castTime > LYKickMin and currentPercent < 95 and LYFacingCheck(LYEnemies[i]) then
								LYSpellStopCasting()
								LYQueueSpell(WrDrCharge,LYEnemies[i])
								LY_Print(WrDrCharge.." "..castName,"green",WrDrCharge)
								LYKickPause = GetTime()
								return true
							end
						end
					end
				end
			end
		end
		if WrKickPlayers() or
		WrReflectIncCC() or
		LYReflect(WrReflect,true) or
		LYReflect(WrSpellBlock,true) or
		TauntPvP(WrTaunt,845) or
		WrInterveneIncCC() or
		PauseRotation or
		DefensiveOnPlayer(WrBitterImmune,nil,LYWrHealHP,LYWrHealBurst,LYWrHealHealer,true) or
		DefensiveOnPlayer(WrShieldWall,nil,LYWrShWallHP,LYWrShWallBurst,LYWrShWallHealer,true) or
		DefensiveOnPlayer(WrLastStand,nil,LYWrLastStandHP,nil,LYWrLastStandHealer,true) or
		DefensiveOnPlayer(WrReflect,"WIZARD",LYWrReflDefHP,LYWrReflDefBurst,LYWrReflHealer,true) or
		DefensiveOnPlayer(WrIgnorePain,nil,LYWrIgnorePainHP,LYWrIgnorePainBurst,LYWrIgnorePainHealer,LYMode ~= "PvE") or
		WrInterveneCast() or
		WrStance() or
		WrShatThrowCast() or
		CommonKick(WrBolt,nil,"alt",LYWrBoltKick) or
		WrSWKick() or
		CommonKick(WrFear,nil,"kick",LYWrFearKick) or
		DragonKick() or
		CommonKick(WrLeap,nil,"alt",LYWrLeapKick and IsPvPTalentInUse(178)) or
		DefensiveOnTeam(WrRaly,nil,LYWrRally,nil,nil,true) or
		AntiStealth(WrTaunt) or
		Taunt(WrTaunt) or
		TotemStomp({WrShieldSlam,WrRevenge,WrDevastate},{WrThrow},30) or
		CommonAttack(WrVRush,nil,true,WrVRush,IsTalentInUse(202168) and CalculateHP("player") < 60 and (not TeamHealerCanInteract() or CalculateHP("player") < 40)) or
		StunCC(WrBolt,nil,LYWrBoltDR,LYWrBoltHealer,LYWrBoltHealerHP,LYWrBoltBurst,LYWrBoltDPS,LYWrBoltDPSHP,LYWrBoltDPSBurst,LYWrBoltCont,LYWrBoltFocus) or
		StunCC(WrSW,nil,LYWrSWDR,LYWrSWHealer,LYWrSWHealerHP,LYWrSWHealerBurst,LYWrSWDPS,LYWrSWDPSHP,LYWrSWDPSBurst,LYWrSWCont,nil,8) or
		FearCC(WrFear,nil,LYWrFearDR,LYWrFearHealer,LYWrFearHealerHP,LYWrFearBurst,LYWrFearDPS,LYWrFearDPSHP,LYWrFearDPSBurst,LYWrFearCont) or
		DefensiveOnTeam(WrBodyGuard,"MELEE",LYWrBdGuardHP,LYWrBdGuardBurst,10,LYMode ~= "PvE") or
		DefensiveOnTeam(WrDefShout,"MELEE",LYWrDefShoutHP,LYWrDefShoutBurst,10,LYMode ~= "PvE" and GCDCheck(WrDefShout) and IsPvPTalentInUse(171) and (not IsTalentInUse(202743) or LYUP + 40 < LYUPMax)) or
		CommonAttack(WrVRush,nil,true,WrVRush,not IsTalentInUse(202168) and CalculateHP("player") < 90) or
		TripleCC(WrSW,LYWrSWTripple,8) or
		DefensiveOnPlayer(WrDefShout,"MELEE",LYWrDefShoutHP,LYWrDefShoutBurst,LYWrDefShoutHealer,(not IsTalentInUse(202743) or LYUP + 40 < LYUPMax)) or
		Disarm(WrDisarm,LYWrDisarmHP,LYWrDisarmBurst,LYWrDisarmHealer,LYWrDisarmFocus) or
		AutoBuffParty(WrAP) or
		SlowTarget(WrHarm,nil,nil,LYSlowAlways) or
		Peel(WrHarm,nil,LYPeelAny,LYPeelHealer) or
		ConditionalSpell(WrIgnorePain,GCDCheck(WrIgnorePain) and not HaveBuff("player",WrIgnorePain,LYGCDTime) and FriendIsUnderAttack("player")) or
		ConditionalSpell(WrShieldBlock,GCDCheck(WrShieldBlock) and (not IsTalentInUse(280001) or not HaveBuff("player",WrLastStand)) and not HaveBuff("player",WrShieldBlock,LYGCDTime) and (FriendIsUnderAttack("player","MELEE") or (LYUP == LYUPMax and EnemiesAroundUnit(WrShieldSlam) > 0 and CDLeft(WrShieldSlam) < 6))) or
		ConditionalSpell(WrRoar,EnemiesAroundUnit(WrShieldSlam) >= LYWrRoarCount) or
		CommonAttack(WrRavager,nil,true,WrFear,true,nil,nil,3) or
		AOEAttack(WrSpearBast,8,WrThrow,3,true) or
		ConditionalSpell(WrThunder,GCDCheck(WrThunder) and ((not IsTalentInUse(203201) and EnemiesAroundUnit(8) >= 3) or (IsTalentInUse(203201) and EnemiesAroundUnit(12) >= 3))) or
		ConditionalSpell(WrAvatar,GCDCheck(WrAvatar) and BurstCondition(LYBurstHP,LYBurstHealCC,LYBurstTeam,LYBurstIgnoreDef,nil,WrShieldSlam)) or
		WrExecuteCast() or
		CommonAttack(WrShieldBash,nil,true,WrShieldSlam,LYMode ~= "PvE",1,WrShieldBash) or
		CommonAttack(WrShieldSlam,nil,true,WrShieldSlam,GCDCheck(WrShieldSlam) and (HaveBuff("player",WrShieldBlock) or not FriendIsUnderAttack("player","MELEE") or not GCDCheck(WrShieldBlock))) or
		CommonAttack(WrRevenge,nil,true,WrShieldSlam,(HaveBuff("player",WrFreeRev) or LYUP > 69)) or
		ConditionalSpell(WrThunder,UnitIsVisible(LYEnemyTarget) and inRange(WrShieldSlam,LYEnemyTarget)) or
		CommonAttackTarget(WrSpearBast,nil,true,inRange(WrBloodThirst,LYEnemyTarget) and (UnitIsBoss(LYEnemyTarget) or (UnitIsPlayer(LYEnemyTarget) and CalculateHP(LYEnemyTarget) < 35)) and UnitAffectingCombat(LYEnemyTarget)) or
		CommonAttack(WrDevastate,nil,true,WrDevastate,true) or
		WrThrowStealth() or
		ConnecTarget(WrCharge,LYWrChargeBurst,LYWrChargeHP) then
			return true
		end
	end
	function BuildTables()
		local function CanAttack(pointer)
			if LYMyClass == 1 or LYMyClass == 4 then
				if not HaveBuff(pointer,listIPhys) and ((not HaveBuff(pointer,{RgEvasion,WrDBS}) and UnitChannelInfo(pointer) ~= MnFists) or ObjectIsBehind("player",pointer)) then
					return true
				end
			elseif LYMyClass == 5 or (LYMyClass == 7 and LYMySpec == 1) or LYMyClass == 8 or LYMyClass == 9 then
				if not HaveBuff(pointer,listIMagic) then
					return true
				end
			else
				return true
			end
		end
		local function AddEnemy(pointer)
			if LYMode == "PvP" then
				tinsert(LYEnemiesAll,pointer)
				if CheckRole(pointer) == "HEALER" then
					LYEnemyHealer = pointer
				end
			end
			if pointer == "target" or not UnitIsVisible("target") or not UnitIsUnit("target",pointer) then
				if not UnitIsPlayer(pointer) then
					if UnitAffectingPvECombat(pointer) and not tContains(LYBLUnits,UnitName(pointer)) and not UnitIsDeadOrGhost(pointer) and not HaveDebuff(pointer,listIInteract) and InLineOfSight(pointer) then
						if HaveDebuff(pointer,LYListBreakableCC) or HaveBuff(pointer,LYListBreakableCC) then
							tinsert(LYEnemiesBCCed,pointer)
						elseif pointer == "target" then
							LYEnemyTarget = ObjectPointer("target")
							tinsert(LYEnemies,1,LYEnemyTarget)
						elseif LYMode ~= "PvP" or not LYIgnorePets then
							tinsert(LYEnemies,pointer)
						else
							tinsert(LYEnemyMinors,pointer)
						end
					end
				elseif CanAttack(pointer) and (not UnitIsCharmed(pointer) or LYMode == "PvE") and InteractInSmoke(pointer) and (not UnitIsDeadOrGhost(pointer) or HaveBuff(pointer,HnFD)) and not HaveBuff(pointer,listIDmgAll) and not HaveDebuff(pointer,listIInteract) and (InLineOfSight(pointer) or (LYMyClass == 3 and HaveDebuff(pointer,HnSentinel,0.5,"player"))) then
					local breakCC = HaveDebuff(pointer,LYListBreakableCC) or (HaveDebuff(pointer,listTremor) and (not UnitIsVisible("target") or not UnitIsUnit("target",pointer)))
					if breakCC and breakCC ~= 122470 then
						tinsert(LYEnemiesBCCed,pointer)
					elseif CheckRole(pointer) == "HEALER" then
						tinsert(LYEnemyHealers,pointer)
						if pointer == "target" then
							LYEnemyTarget = ObjectPointer("target")
							tinsert(LYEnemies,1,LYEnemyTarget)
						else
							tinsert(LYEnemies,pointer)
						end
						LYEnemyHealer = pointer
					elseif pointer == "target" then
						LYEnemyTarget = ObjectPointer("target")
						tinsert(LYEnemies,1,LYEnemyTarget)
					elseif LYMode ~= "Outworld" or (UnitAffectingCombat(pointer) and UnitIsTargetingUnit(pointer,"player")) then
						tinsert(LYEnemies,pointer)
					end
				end
			end
		end
		local function AddEnemyNPC(pointer)
			if not UnitIsDeadOrGhost(pointer) then
				if UnitAffectingPvECombat(pointer) and not tContains(LYBLUnits,UnitName(pointer)) and (pointer == "target" or not UnitIsVisible("target") or not UnitIsUnit("target",pointer)) and not HaveDebuff(pointer,listIInteract) and InLineOfSight(pointer) then
					if HaveDebuff(pointer,LYListBreakableCC) or HaveBuff(pointer,LYListBreakableCC) then
						tinsert(LYEnemiesBCCed,pointer)
					elseif pointer == "target" then
						LYEnemyTarget = pointer
						tinsert(LYEnemies,1,pointer)
					elseif LYMode ~= "PvP" or not LYIgnorePets then
						tinsert(LYEnemies,pointer)
					else
						tinsert(LYEnemyMinors,pointer)
					end
				end
			end
		end
		local function AddEnemyPlayer(pointer)
			if LYMode == "PvP" then
				tinsert(LYEnemiesAll,pointer)
				if CheckRole(pointer) == "HEALER" then
					LYEnemyHealer = pointer
				end
			end
			if CanAttack(pointer) and (not UnitIsCharmed(pointer) or LYMode == "PvE") and InteractInSmoke(pointer) and (not UnitIsDeadOrGhost(pointer) or HaveBuff(pointer,HnFD)) and (pointer == "target" or not UnitIsVisible("target") or not UnitIsUnit("target",pointer)) and not HaveBuff(pointer,listIDmgAll) and not HaveDebuff(pointer,listIInteract) and (InLineOfSight(pointer) or (LYMyClass == 3 and HaveDebuff(pointer,HnSentinel,0.5,"player"))) then
				local breakCC = HaveDebuff(pointer,LYListBreakableCC) or (HaveDebuff(pointer,listTremor) and (not UnitIsVisible("target") or not UnitIsUnit("target",pointer)))
				if breakCC and breakCC ~= 122470 then
					tinsert(LYEnemiesBCCed,pointer)
				elseif CheckRole(pointer) == "HEALER" then
					tinsert(LYEnemyHealers,pointer)
					if pointer == "target" then
						LYEnemyTarget = pointer
						tinsert(LYEnemies,1,pointer)
					else
						tinsert(LYEnemies,pointer)
					end
					LYEnemyHealer = pointer
				elseif pointer == "target" then
					LYEnemyTarget = pointer
					tinsert(LYEnemies,1,pointer)
				elseif LYMode ~= "Outworld" or (UnitAffectingCombat(pointer) and UnitIsTargetingUnit(pointer,"player")) then
					tinsert(LYEnemies,pointer)
				end
			end
		end
		local function AddFriendPlayer(pointer)
			if LYMode == "PvP" then
				tinsert(LYTeamPlayersAll,pointer)
				if CheckRole(pointer) == "HEALER" then
					tinsert(LYTeamHealersAll,pointer)
				end
			end
			if UnitIsVisible(pointer) and not tContains(LYBLUnits,UnitName(pointer)) and (UnitInRange(pointer) or UnitIsUnit(pointer,"player")) and not UnitIsCharmed(pointer) and not HaveDebuff(pointer,listIInteract) and InteractInSmoke(pointer) and UnitPhaseReason(pointer) == myPhase and not HaveBuff(pointer,LYListDoNotHeal) and not HaveDebuff(pointer,LYListDoNotHeal) and InLineOfSight(pointer) then
				if LYMode ~= "PvP" and UnitIsDeadOrGhost(pointer) and not HaveBuff(pointer,HnFD) then
					tinsert(LYTeamPlayersDead,pointer)
				end
				if not UnitIsDeadOrGhost(pointer) or HaveBuff(pointer,HnFD) then
					if CheckRole(pointer) == "HEALER" then
						tinsert(LYTeamHealers,pointer)
					end
					tinsert(LYTeamPlayers,pointer)
				end
			end
		end
		if (unlocker =="MB" and select(2,GetObjectCount())) or LastTimeLYUpdated + 0.1 < GetTime() then
			local myPhase = UnitPhaseReason("player")
			LastTimeLYUpdated = GetTime()
			LYEnemies = {}
			LYEnemiesAll = {}
			LYEnemiesBCCed = {}
			LYEnemiesDead = {}
			LYEnemyHealers = {}
			LYEnemyTotems = {}
			LYEnemyMinors = {}
			LYTeamPlayers = {"player"}
			LYTeamPlayersAll = {"player"}
			LYTeamPlayersDead = {}
			LYLootEnemies = {}
			if LYPlayerRole == "HEALER" then
				LYTeamHealers = {"player"}
				LYTeamHealersAll = {"player"}
			else
				LYTeamHealers = {}
				LYTeamHealersAll = {}
			end
			if UnitGroupRolesAssigned("player") == "TANK" then
				LYPlayerIsTank = true
			end
			LYEnemyTarget = nil
			local pointer = nil
			local id = select(8,GetInstanceInfo())
			if unlocker == "MB" then
				for i=1,(GetPlayerCount("player",80) or 0) do
					pointer = GetPlayerWithIndex(i)
					if UnitIsVisible(pointer) and UnitCanAttack("player",pointer) then
						AddEnemyPlayer(pointer)
					end
				end
				local BoPPoD = LYMode == "PvP" and LYMyClass == 2 and (GCDCheck(PlBoP) or GCDCheck(PlSac)) and UnitAffectingCombat("player")
				for i=1,(GetNpcCount("player",80) or 0) do
					pointer = GetNpcWithIndex(i)
					if UnitIsVisible(pointer) and UnitCanAttack("player",pointer) then
						if LYMode ~= "PvE" and UnitCreatureTypeId(pointer) ~= 1 and tContains(LYListTotems,UnitName(pointer)) then
							if InLineOfSight(pointer) then
								tinsert(LYEnemyTotems,pointer)
							end
						else
							AddEnemyNPC(pointer)
						end
					end
				end
				if LYZoneType == "pvp" and LYFlag and id and (id == 2106 or id == 726 or id == 566) and not IsStealthed() then
					for i=1,GetGameObjectCount("player",10) do
						pointer = GetGameObjectWithIndex(i)
						if UnitName(pointer) == HordeFlag or UnitName(pointer) == AlyFlag or UnitName(pointer) == "Eye of the Storm Flag" then
							ObjectInteract(pointer)
						end
					end
				end
			elseif unlocker == "NN" then
				local objects = ObjectManager("Unit" or 5)
				for _, pointer in ipairs(objects) do
					if UnitIsVisible(pointer) and UnitCanAttack("player",pointer) then
						if tContains(LYListTotems,UnitName(pointer)) then
							if LYMode ~= "PvE" and InLineOfSight(pointer) then
								tinsert(LYEnemyTotems,pointer)
							end
						else
							AddEnemy(pointer)
						end
					end
				end
				local objects = ObjectManager("Player"or 6)
				for _, pointer in ipairs(objects) do
					if UnitIsVisible(pointer) and UnitCanAttack("player",pointer) then
						AddEnemy(pointer)
					end
				end
				if LYZoneType == "pvp" and LYFlag and id and (id == 2106 or id == 726 or id == 566) and not IsStealthed() then
					local objects = ObjectManager("GameObject" or 8)
					for _, pointer in ipairs(objects) do
						if (ObjectName(pointer) == HordeFlag or ObjectName(pointer) == AlyFlag or ObjectName(pointer) == "Eye of the Storm Flag") and GetDistanceBetweenObjects(pointer,"player") < 5 then
							ObjectInteract(pointer)
						end
					end
				end
			elseif unlocker == "tinkr" then
				local objects = Objects()
				for _, pointer in ipairs(objects) do
					if UnitIsVisible(pointer) and ObjectIsUnit(pointer) and UnitCanAttack("player",pointer) then
						if tContains(LYListTotems,UnitName(pointer)) then
							if LYMode ~= "PvE" and InLineOfSight(pointer) then
								tinsert(LYEnemyTotems,pointer:unit())
							end
						else
							AddEnemy(pointer:unit())
						end
					end
					if LYZoneType == "pvp" and LYFlag and id and (id == 2106 or id == 726 or id == 566) and not IsStealthed() and ObjectIsGameObject(pointer) and (ObjectName(pointer) == HordeFlag or ObjectName(pointer) == AlyFlag or ObjectName(pointer) == "Eye of the Storm Flag") and GetDistanceBetweenObjects(pointer,"player") < 5 then
						ObjectInteract(pointer)
					end
				end
			elseif unlocker == "daemon" then
				for i=1,GetObjectCount() do
					pointer = GetObjectWithIndex(i)
					if UnitIsVisible(pointer) and ObjectIsUnit(pointer) and UnitCanAttack("player",pointer) then
						if tContains(LYListTotems,UnitName(pointer)) then
							if LYMode ~= "PvE" and InLineOfSight(pointer) then
								tinsert(LYEnemyTotems,pointer)
							end
						else
							AddEnemy(pointer)
						end
					end
					if LYZoneType == "pvp" and LYFlag and id and (id == 2106 or id == 726 or id == 566) and not IsStealthed() and ObjectIsGameObject(pointer) and (ObjectName(pointer) == HordeFlag or ObjectName(pointer) == AlyFlag or ObjectName(pointer) == "Eye of the Storm Flag") and GetDistanceBetweenObjects(pointer,"player") < 5 then
						ObjectInteract(pointer)
					end
				end
			end
			local isRaid = nil
			for i=1,39 do
				pointer = "raid"..i
				if UnitIsVisible(pointer) then
					isRaid = true
					AddFriendPlayer(pointer)
				else
					break
				end
			end
			if not isRaid then
				for i=1,4 do
					pointer = "party"..i
					if UnitIsVisible(pointer) then
						AddFriendPlayer(pointer)
					else
						break
					end
				end
			else
				tremove(LYTeamPlayers,1)
				tremove(LYTeamPlayersAll,1)
				if LYPlayerRole == "HEALER" then
					tremove(LYTeamHealers,1)
					tremove(LYTeamHealersAll,1)
				end
			end
			if #LYEnemies > 1 then
				table.sort(LYEnemies,function(x,y) return CalculateHP(x) < CalculateHP(y) end)
			end
			if UnitIsVisible("target") then
				if UnitCanAttack("player","target") then
					if UnitIsPlayer("target") then
						AddEnemyPlayer("target")
					else
						AddEnemyNPC("target")
					end
				elseif (not UnitIsPlayer("target") or (#LYTeamPlayers == 1 and not UnitIsUnit("player","target"))) and (UnitAffectingCombat("target") or LYMode ~= "PvP" or not UnitAffectingCombat("player")) and not UnitIsDeadOrGhost("target") and IsInDistance() and InLineOfSight() then
					tinsert(LYTeamPlayers,"target")
				end
			end
			if #LYTeamPlayers > 1 then
				table.sort(LYTeamPlayers,function(x,y) return CalculateHP(x) < CalculateHP(y) end)
			end
			NetStats3,NetStats4 = select(3,GetNetStats())
			LYMyPing = NetStats3 / 1000
		end
	end
	--Core
	function InteractInSmoke(pointer)
		local creator = nil
		if HaveDebuff(pointer,RgBomb) then
			creator = DebuffCreator(pointer,RgBomb)
			if HaveDebuff("player",RgBomb) or (UnitIsVisible(creator) and UnitIsFriend("player",creator)) then
				return true
			end
		elseif HaveDebuff("player",RgBomb) then
			creator = DebuffCreator("player",RgBomb)
			if UnitIsVisible(creator) and UnitIsFriend("player",creator) then
				return true
			end
		else
			return true
		end
	end
	function ValidEnemyUnit(pointer)
		if UnitIsVisible(pointer) and ((LYStyle ~= "Only target" and (not LYEnemyHealer or LYDoTEHeal or CheckRole(pointer) ~= "HEALER")) or (UnitIsVisible("target") and UnitIsUnit("target",pointer))) then
			return true
		end
	end
	function SpellAttackTypeCheck(pointer,typeDmg)
		if not UnitIsVisible(pointer) then
			return
		end
		if not typeDmg or LYMode ~= "PvP" or not UnitIsPlayer(pointer) or (typeDmg == "all" and not HaveBuff(pointer,listIMagic) and not HaveBuff(pointer,listIPhys) and (not HaveBuff(pointer,{RgEvasion,WrDBS}) or ObjectIsBehind("player",pointer))) or (typeDmg == "magic" and not HaveBuff(pointer,listIMagic)) or (typeDmg == "phys" and not HaveBuff(pointer,listIPhys) and (not HaveBuff(pointer,{RgEvasion,WrDBS}) or ObjectIsBehind("player",pointer))) then
			return true
		end
	end
	function ValidFriendUnit(pointer)
		if UnitIsVisible(pointer) and (LYStyle ~= "Only target" or (UnitIsVisible("target") and UnitIsUnit("target",pointer))) then
			return true
		end
	end
	function UnitAffectingPvECombat(pointer)
		if pointer == "target" then
			if UnitAffectingCombat(pointer) or LYMode ~= "PvE" or (IsInBossFight() and CalculateHP(pointer) < 100) then
				return true
			end
		elseif UnitAffectingCombat(pointer) then
			if LYMode ~= "PvP" then
				return true
			else
				local threat = UnitThreatSituation("player",pointer)
				if threat and threat > 0 then
					return true
				end
			end
		elseif LYMode == "Outworld" and UnitAffectingCombat("player") then
			local id = ObjectId(pointer)
			if tContains(listDummies,id) and ObjectIsFacing("player",pointer) then
				return true
			end
		end
	end
	function IsWizzard(pointer)
		if UnitIsVisible(pointer) then
			if UnitIsPlayer(pointer) then
				local class = select(2,UnitClass(pointer))
				if CheckRole(pointer) == "RDPS" and class ~= "HUNTER" then
					return true
				end
			elseif LYMode ~= "PvP" and UnitCastingInfo(pointer) then
				return true
			end
		end
	end
	function GetPlayerSpells()
		LYPlayerSpellsByName = {}
		LYPlayerSpellsByID = {}
		local max = 0
		for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
			local _, _, offset, numSpells, _, specId =  C_SpellBook.GetSpellBookSkillLineInfo(i)
			if specId == 0 then
				max = offset + numSpells
			end
		end
		local function SetSpellsForBook(book)
			local max = 0
			for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
				local _, _, offs, numspells, _, specId =  C_SpellBook.GetSpellBookSkillLineInfo(i)
				if specId == 0 then
					max = offs + numspells
				end
			end

			local spellsByName = LYPlayerSpellsByName
			local spellsByID = LYPlayerSpellsByID

			for spellBookID = 1, max do
				local type, baseSpellID = C_SpellBook.GetSpellBookItemInfo(spellBookID, book)
				if type == "SPELL" then
					local currentSpellName = C_SpellBook.GetSpellBookItemName(spellBookID, book)
					local spellLink = GetSpellLink(currentSpellName)
					local currentSpellID = tonumber(spellLink and spellLink:gsub("|", "||"):match("spell:(%d+)"))
					if currentSpellName and not LYPlayerSpellsByName[currentSpellName] then
						LYPlayerSpellsByName[currentSpellName] = spellBookID
					end
					if currentSpellID and not LYPlayerSpellsByID[currentSpellID] then
						LYPlayerSpellsByID[currentSpellID] = spellBookID
					end
					if type == "SPELL" then
						local baseSpellName = GetSpellInfo(baseSpellID)
						if baseSpellName and not LYPlayerSpellsByName[baseSpellName] then
							LYPlayerSpellsByName[baseSpellName] = spellBookID
						end
						if baseSpellID and not LYPlayerSpellsByID[baseSpellID] then
							LYPlayerSpellsByID[baseSpellID] = spellBookID
						end
					end
				end
			end
		end
		wipe(LYPlayerSpellsByName)
		wipe(LYPlayerSpellsByID)
		SetSpellsForBook("spell")
	end
	function CheckPlayerTalents()
		LYPlayerRole = GetSpecializationRole(GetSpecialization())
		PlayerTalents = {}
		PlayerTalentRanks = {}
		PlayerPvPTalents = {}
		if LYPlayerRole ~= "HEALER" then
			LYPlayerRole = CheckRole("player")
		end
		local configId = C_ClassTalents.GetActiveConfigID()
		if not configId then
			return
		end
		local configInfo = C_Traits.GetConfigInfo(configId)
		for _, treeId in pairs(configInfo.treeIDs) do
			local nodes = C_Traits.GetTreeNodes(treeId)
			for _, nodeId in pairs(nodes) do
				local node = C_Traits.GetNodeInfo(configId, nodeId)
				local activeid = (node.activeRank > 0 or node.ranksPurchased > 0) and (node.activeEntry and node.activeEntry.entryID or node.entryIDs[1])
				for _, entryID in pairs(node.entryIDs) do
					local entryInfo = C_Traits.GetEntryInfo(configId,entryID)
					if entryInfo and entryInfo.definitionID then
						local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
						if definitionInfo and definitionInfo.spellID then
							PlayerTalents[definitionInfo.spellID] = (entryID == activeid)
							if (entryID == activeid) then
								PlayerTalentRanks[definitionInfo.spellID] = node.activeRank
							end
						end
					end
				end
			end
		end
		if LYMyLevel > 10 then
			local talents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
			for k=1,#talents do
				PlayerPvPTalents[talents[k]] = true
			end
		end
		if LYMyClass == 11 then
			listRDruHoTs = {
			DrRejuv,
			DrLBloom
			}
			if IsTalentInUse(155675) then
				tinsert(listRDruHoTs,DrGerm)
			end
		end
		if LYMyClass == 9 then
			listWlDoTs = {
			WlAgony,
			WlCorrupt
			}
			if IsTalentInUse(316099) then
				tinsert(listWlDoTs,WlUnstable)
			end
			if IsTalentInUse(63106) then
				tinsert(listWlDoTs,WlSiphon)
			end
		end
		if LYMyClass == 7 then
			if IsTalentInUse(378773) then
				ShPurge = GetSpellInfo(378773)
			else
				ShPurge = GetSpellInfo(370)
			end
		end
		listDispelTypes = {}
		if LYPlayerRole == "HEALER" then
			tinsert(listDispelTypes,"Magic")
		end
		if LYMyClass == 13 then
			tinsert(listDispelTypes,"Poison")
		elseif LYMyClass == 11 then
			tinsert(listDispelTypes,"Curse")
			tinsert(listDispelTypes,"Poison")
		elseif LYMyClass == 10 then
			tinsert(listDispelTypes,"Disease")
			tinsert(listDispelTypes,"Poison")
		elseif LYMyClass == 2 then
			tinsert(listDispelTypes,"Disease")
			tinsert(listDispelTypes,"Poison")
		elseif LYMyClass == 5 then
			if IsTalentInUse(390632) then
				tinsert(listDispelTypes,"Disease")
			end
		elseif LYMyClass == 7 then
			tinsert(listDispelTypes,"Curse")
		end
	end
	function IsTalentInUse(spellID)
		return PlayerTalents[spellID]
	end
	function IsPvPTalentInUse(Spell)
		if PlayerPvPTalents[Spell] and (LYMode == "PvP" or C_PvP.IsWarModeActive() or ((GetRestState() == 1 or IsResting()) and C_PvP.IsWarModeDesired())) then
			return true
		end
	end
	function PredictLocation(x, y, z, pointer, time, SpellName, radius)
		local function IsRingPositionValid(x, y, z, radius)
			local pointsToCheck = 16
			local angleStep = 2 * math.pi / pointsToCheck
			local heightOffset = 2
			for i = 1, pointsToCheck do
				local angle = i * angleStep
				local edgeX = x + radius * math.cos(angle)
				local edgeY = y + radius * math.sin(angle)
				local edgeZ = z

				local startX, startY, startZ = TraceLine(x, y, z + heightOffset, edgeX, edgeY, edgeZ + heightOffset, 0x111)
				if startX then
					return false
				end
			end
			return true
		end
		local function GetMovingDirection(pointer)
			local R = ObjectFacing(pointer);
			local mod = 0;
			local flags = UnitMovementFlags(pointer)
			if not flags then
				return false
			else
				flags = bit.band(flags, 0xF)
			end
			if flags == 0x2 then
				mod = math.pi;
			elseif flags == 0x4 then
				mod = math.pi * 0.5;
			elseif flags == 0x8 then
				mod = math.pi * 1.5;
			elseif flags == bit.bor(0x1, 0x4) then
				mod = math.pi * (1 / 8) * 2;
			elseif flags == bit.bor(0x1, 0x8) then
				mod = math.pi * (7 / 8) * 2;
			elseif flags == bit.bor(0x2, 0x4) then
				mod = math.pi * (3 / 8) * 2;
			elseif flags == bit.bor(0x2, 0x8) then
				mod = math.pi * (5 / 8) * 2;
			end
			return (R + mod) % (math.pi * 2);
		end
		if not pointer then return x,y,z end
		if not x and not y and not z then
			x,y,z = ObjectPosition(pointer)
		end
		if not time then
			time = C_Spell.GetSpellInfo(SpellName).castTime / 1000
		end
		if x and y and z then
			local direction = GetMovingDirection(pointer)
			local distance = GetUnitSpeed(pointer) * (time + LYMyPing)
			if SpellName == MgRingFrost or SpellName == MgRingFire or (SpellName == MgFlameStrike and IsTalentInUse(203280)) then
				if SpellName == MgRingFrost then radius = 5 else radius = 6 end
				distance = distance - radius
			end
			if not radius then
				local pX = x + distance * math.cos(direction)
				local pY = y + distance * math.sin(direction)
				local pZ = z
				local tX, tY, tZ = TraceLine(x,y,z+2,pX,pY,pZ+2,0x100111)
				if not tX then
					return GroundZ(pX, pY, pZ)
				else
					return GroundZ(tX, tY, tZ)
				end
			else
				local maxAttempts = 16
				local angleOffset = 2 * math.pi / maxAttempts
				local pX, pY, pZ

				for attempt = 1, maxAttempts do
					local adjustedDirection = direction + (angleOffset * (attempt - 1))
					pX = x + distance * math.cos(adjustedDirection)
					pY = y + distance * math.sin(adjustedDirection)
					pZ = z
					if IsRingPositionValid(pX, pY, pZ, radius) then
						local tX, tY, tZ = TraceLine(x, y, z + 2, pX, pY, pZ + 2, 0x100111)
						if not tX then
							return GroundZ(pX, pY, pZ)
						else
							return GroundZ(tX, tY, tZ)
						end
					end
				end
			end
		end
	end
	function ClickAOESpell(pointer)
		local isMouseOn
		if pointer then
			if UnitIsVisible(pointer) then
				local x,y,z = ObjectPosition(pointer)
				local x0,y0,z0 = x,y,z
				if IsMouselooking() then
					MouselookStop()
					isMouseOn = true
				end
				if LYCurrentSpellName == MgRingFrost or LYCurrentSpellName == MgRingFire or LYCurrentSpellName == MgFlameStrike or LYCurrentSpellName == WlSF then
					x,y,z = PredictLocation(x, y, z, pointer, nil, LYCurrentSpellName)
				elseif (LYCurrentSpellName == HnTrap or LYCurrentSpellName == HnSteelTrap or LYCurrentSpellName == HnRootTrap) then
					x,y,z = PredictLocation(x, y, z, pointer, 0.5, LYCurrentSpellName)
				else
					x,y,z = TraceLine(x,y,z+2,x,y,z-2,0x110)
				end
				if x and z then
					ClickPosition(x,y,z)
				elseif x0 and z0 then
					ClickPosition(x0,y0,z0)
				else
					SpellStopTargeting()
				end
				PauseGCD = GetTime() + 0.1
			elseif pointer == "point" and LYCurrentSpellX then
				if IsMouselooking() then
					MouselookStop()
					isMouseOn = true
				end
				ClickPosition(LYCurrentSpellX,LYCurrentSpellY,LYCurrentSpellZ)
				PauseGCD = GetTime() + 0.1
			else
				SpellStopTargeting()
			end
		else
			if IsMouselooking() then
				MouselookStop()
				isMouseOn = true
			end
			CameraOrSelectOrMoveStart()
			CameraOrSelectOrMoveStop()
			PauseGCD = GetTime() + 0.1
		end
		if not SpellIsTargeting() then
			if GetKeyState(0x02) or isMouseOn then
				MouselookStart()
			end
			if GetKeyState(0x01) then
				CameraOrSelectOrMoveStart()
			end
		end
	end
	function CheckUnitDR(pointer,category,count)
		local count = count or 0
		if UnitIsVisible(pointer) then
			local tempGUID = UnitGUID(pointer)
			if not tempGUID then
				return
			end
			if not DR[tempGUID] then
				DR[tempGUID] ={}
			end
			if not DR[tempGUID][category] then
				DR[tempGUID][category] = {Time = 0,Count = 0}
			end
			if DR[tempGUID][category].Count <= count or (DR[tempGUID][category].Time ~= 0 and GetTime() - DR[tempGUID][category].Time > 18) then
				if category == "stun" and (HaveBuff(pointer,listIStun) or (UnitChannelInfo(pointer) == MnFists and ObjectIsFacing(pointer,"player"))) then
					return
				end
				if category == "fear" and HaveBuff(pointer,listIFear) then
					return
				end
				return true
			end
		end
	end
	function CheckUnitDRSpell(pointer,spell,count)
		local count = count or 0
		if UnitIsVisible(pointer) then
			local tempGUID = UnitGUID(pointer)
			local category = nil
			if not tempGUID then
				return
			end
			if tContains(listStuns,spell) then
				category = "stun"
			elseif tContains(listFear,spell) then
				category = "fear"
			elseif tContains(listIncap,spell) then
				category = "control"
			end
			if not category then
				return true
			end
			if not DR[tempGUID] then
				DR[tempGUID] ={}
			end
			if not DR[tempGUID][category] then
				DR[tempGUID][category] = {Time = 0,Count = 0}
			end
			if DR[tempGUID][category].Count <= count or GetTime() - DR[tempGUID][category].Time > 19 then
				return true
			end
		end
	end
	function GCDCheck(Spell,force)
		if Spell == PlCrusader and IsTalentInUse(404542) then 
			return 
		end
		if not Spell or type(Spell) ~= "string" then
			return false -- or handle the error as needed
		end
		if  C_Spell.IsSpellUsable(Spell) and 
		(force or not tContains(LYBLSpells,Spell)) and (not tContains(listThoughtsteal,Spell) or not HaveDebuff("player",PrThoughtsteal)) then
			local tSpell = C_Spell.GetSpellCooldown(Spell)
			if tSpell.startTime and tSpell.startTime+tSpell.duration-GetTime() < LYMyPing*2 then
				return true
			end
		elseif GetItemSpell(Spell) and GetInventoryItemCooldown("player",select(9,GetItemInfo(Spell))) == 0 then
			return true
		end
	end
	function CDCheck(Spell,force)
		if C_Spell.IsSpellUsable(Spell) and (force or not tContains(LYBLSpells,Spell)) then
			local tSpell = C_Spell.GetSpellCooldown(Spell)
			if not UnitCastingInfo("player") then
				if tSpell.startTime and tSpell.startTime+tSpell.duration-GetTime() < LYGCDTime+LYMyPing*2 then
					return true
				end
			elseif UnitCastingInfo("player") == Spell then
				return false
			elseif tSpell.startTime and (tSpell.startTime == 0 or (castStartP and math.abs(tSpell.startTime - castStartP/1000) < LYGCDTime+LYMyPing*2)) then
				return true
			end
		elseif GetItemSpell(Spell) and GetInventoryItemCooldown("player",select(9,GetItemInfo(Spell))) == 0 then
			return true
		end
	end
	function IsGCDReady()
		local tSpell = C_Spell.GetSpellCooldown(61304)
		if tSpell.startTime and tSpell.startTime+tSpell.duration-GetTime() < LYMyPing*2 then
			return true
		else
			LYGCDTime = tSpell.duration+LYMyPing
		end
	end
	function CDLeft(Spell,force)
		if GetSpellInfo(Spell) and (force or not tContains(LYBLSpells,Spell)) then
			local tSpell = C_Spell.GetSpellCooldown(Spell)
			if tSpell.startTime and tSpell.startTime == 0 then
				return 0
			else
				return tSpell.startTime+tSpell.duration-GetTime()
			end
		elseif GetItemSpell(Spell) then
			local start,duration = GetInventoryItemCooldown("player",select(9,GetItemInfo(Spell)))
			if start and start == 0 then
				return 0
			else
				return start+duration-GetTime()
			end
		else
			return 300
		end
	end
	function TeamHealerIsSpellTarget(pointer,dist)
		for i=1,#LYTeamHealers do
			if UnitIsVisible(LYTeamHealers[i]) and UnitIsUnit(LYTeamHealers[i],GetSpellDestUnit(pointer)) and (not dist or IsInDistance(LYTeamHealers[i],dist)) and not HaveBuff(LYTeamHealers[i],{ShGroundEffect,PrHolyWard}) then
				return true
			end
		end
	end
	function UnitIsBoss(pointer,isMain)
		if not UnitIsVisible(pointer) then
			return
		--else
			--return UnitIsBossMob(pointer)
		--end
		elseif LYMode == "PvE" then
			local boss
			local mainT = MainRaidTarget()
			for i=1,5 do
				boss = "boss"..i
				if UnitIsVisible(boss) and UnitIsUnit(pointer,boss) and (not isMain or (UnitIsVisible(mainT) and UnitIsUnit(mainT,pointer))) then
					return true
				end
			end
		end
	end
	function UnitIsTank(pointer,role)
		if not UnitIsVisible(pointer) then
			return
		end
		if LYMode ~= "PvP" then
			if UnitGroupRolesAssigned(pointer) == "TANK" then
				local isMain = GetPartyAssignment("MAINTANK",pointer)
				if not role or (role == "main" and (isMain or #LYTeamPlayers < 6)) or (role == "off" and not isMain) then
					return true
				end
			end
		elseif LYZoneType == "arena" and UnitCanAttack("player",pointer) then
			for i = 1,5 do
				local unit = "arena"..i
				local specID = GetArenaOpponentSpec(i)
				if specID and UnitIsVisible(unit) and UnitIsUnit(pointer,unit) then
					local id = GetSpecializationInfoByID(specID)
					if (class == "DRUID" and id == 104) or (class == "PALADIN" and id == 66) or (class == "MONK" and id == 268) or (class == "WARRIOR" and id == 73) or (class == "DEATHKNIGHT" and id == 250) or (class == "DEMONHUNTER" and id == 581) then
						return true
					end
				end
			end
		else
			local specRealID = GetSpecByDescriptor(pointer)
			if specRealID and specRealID < 300 then
				local id = GetSpecializationInfoByID(specRealID)
				if (class == "DRUID" and id == 104) or (class == "PALADIN" and id == 66) or (class == "MONK" and id == 268) or (class == "WARRIOR" and id == 73) or (class == "DEATHKNIGHT" and id == 250) or (class == "DEMONHUNTER" and id == 581) then
					return true
				end
			end
		end
	end
	function MainRaidTarget()
		for i=1,#LYTeamPlayers do
			if UnitIsVisible(LYTeamPlayers[i]) and UnitIsTank(LYTeamPlayers[i],"main") then
				local t = UnitTarget(LYTeamPlayers[i])
				if UnitIsVisible(t) then
					return t
				end
				return
			end
		end
	end
	function HaveBuff(pointer,Spell,TimeLeft,Source)
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetBuffDataByIndex(pointer,i)			
				if tBuff and tBuff.name then
					if type(Spell) ~= "table" then
						if ((type(Spell) == "string" and tBuff.name == Spell) or (type(Spell) == "number" and tBuff.spellId == Spell)) and (not TimeLeft or TimeLeft == 0 or tBuff.expirationTime == 0 or tBuff.expirationTime - GetTime() > TimeLeft) and (not Source or (tBuff.sourceUnit and UnitIsUnit(Source,tBuff.sourceUnit))) then
							return tBuff.spellId
						end
					else
						for j=1,#Spell do
							if ((type(Spell[j]) == "string" and tBuff.name == Spell[j]) or (type(Spell[j]) == "number" and tBuff.spellId == Spell[j])) and (not TimeLeft or TimeLeft == 0 or tBuff.expirationTime == 0 or tBuff.expirationTime - GetTime() > TimeLeft) and (not Source or (tBuff.sourceUnit and UnitIsUnit(Source,tBuff.sourceUnit))) then
								return tBuff.spellId
							end
						end
					end
				else
					return
				end
			end
		end
	end
	function BuffTimeLeft(pointer,Spell)
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetBuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if tBuff.expirationTime and tBuff.expirationTime ~= 0 and tBuff.name == Spell then
						return (tBuff.expirationTime - GetTime())
					end
				else
					return 100
				end
			end
		end
		return 100
	end
	function BuffCount(pointer,Spell,TimeLeft)
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetBuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if tBuff.applications == 0 then
						tBuff.applications = 1
					end
					if tBuff.name == Spell then
						if not TimeLeft or TimeLeft == 0 or tBuff.expirationTime == 0 or tBuff.expirationTime - GetTime() > TimeLeft then
							return tBuff.applications
						else
							return 0
						end
					end
				else
					return 0
				end
			end
		end
		return 0
	end
	function NumberOfPurgeBuffs(pointer)
		local count = 0
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tSpell = C_UnitAuras.GetBuffDataByIndex(pointer,i)
				if tSpell and tSpell.isStealable then
					count = count + 1
				end
			end
		end
		return count
	end
	function NumberOfBuffs(pointer,Spell)
		local count = 0
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetBuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					for j=1,#Spell do
						if tBuff.name == Spell[j] then
							count = count + 1
						end
					end
				else
					return count
				end
			end
		end
		return count
	end
	function HaveAllBuffs(pointer,Spell,TimeLeft)
		local TimeLeft = TimeLeft or 0
		local count = 0
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetBuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if tBuff.expirationTime == 0 or tBuff.expirationTime - GetTime() > TimeLeft then
						for j=1,#Spell do
							if tBuff.name == Spell[j] then
								count = count + 1
							end
						end
					end
				else
					break
				end
			end
		end
		if count == #Spell then
			return true
		end
	end
	function CancelBuffByName(Spell)
		for i=1,40 do
			local tBuff = C_UnitAuras.GetBuffDataByIndex("player",i)
			if tBuff and tBuff.name then
				if tBuff.name == Spell then
					CancelUnitBuff("player",i)
				end
			else
				return
			end
		end
	end
	function HaveDebuff(pointer,Spell,TimeLeft,Source)
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if type(Spell) ~= "table" then
						if Spell == "Magic" then
							if tBuff.dispelName and Spell == "Magic" and tBuff.dispelName == "Magic" and (tBuff.expirationTime == 0 or tBuff.expirationTime - GetTime() > TimeLeft) then
								return true
							end
						elseif ((type(Spell) == "string" and tBuff.name == Spell) or (type(Spell) == "number" and tBuff.spellId == Spell)) and (not TimeLeft or TimeLeft == 0 or tBuff.expirationTime == 0 or tBuff.expirationTime - GetTime() > TimeLeft) and (not Source or (tBuff.sourceUnit and UnitIsUnit(Source,tBuff.sourceUnit))) then
							return tBuff.spellId
						end
					else
						for j=1,#Spell do
							if ((type(Spell[j]) == "string" and tBuff.name == Spell[j]) or (type(Spell[j]) == "number" and tBuff.spellId == Spell[j])) and (not TimeLeft or TimeLeft == 0 or tBuff.expirationTime == 0 or tBuff.expirationTime - GetTime() > TimeLeft) and (not Source or (tBuff.sourceUnit and UnitIsUnit(Source,tBuff.sourceUnit))) then
								return tBuff.spellId
							end
						end
					end
				else
					return
				end
			end
		end
	end
	function DebuffTimeLeft(pointer,Spell)
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if tBuff.expirationTime ~= 0 and tBuff.name == Spell and UnitIsVisible(tBuff.sourceUnit) and UnitIsUnit("player",tBuff.sourceUnit) then
						return (tBuff.expirationTime - GetTime())
					end
				else
					return 100
				end
			end
		end
		return 100
	end
	function DebuffCount(pointer,Spell,TimeLeft)
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if tBuff.name == Spell and tBuff.applications and UnitIsVisible(tBuff.sourceUnit) and UnitIsUnit("player",tBuff.sourceUnit) then
						if not TimeLeft or TimeLeft == 0 or tBuff.expirationTime == 0 or tBuff.expirationTime - GetTime() < TimeLeft then
							return tBuff.applications
						else
							return 0
						end
					end
				else
					return 0
				end
			end
		end
		return 0
	end
	function HaveAllDebuffs(pointer,Spell,TimeLeft)
		local TimeLeft = TimeLeft or 0
		local count = 0
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if (tBuff.expirationTime == 0 or tBuff.expirationTime - GetTime() > TimeLeft) and UnitIsVisible(tBuff.sourceUnit) and UnitIsUnit("player",tBuff.sourceUnit) then
						for j=1,#Spell do
							if tBuff.name == Spell[j] then
								count = count + 1
							end
						end
					end
				else
					break
				end
			end
		end
		if count == #Spell then
			return true
		end
	end
	function DebuffCreator(pointer,Spell)
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if tBuff.name == Spell then
						return tBuff.sourceUnit
					end
				else
					return
				end
			end
		end
	end
	function UnitIsCCed(pointer,TimeLeft,left)
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if tContains(listCC,tBuff.name) or tContains(listStunsID,tBuff.spellId) or (pointer ~= "player" and tContains(listSilence,tBuff.name)) then
						local timer = tBuff.duration - GetTime()
						if not TimeLeft or (not left and timer > TimeLeft) or (left and timer < TimeLeft) then
							return tBuff.name
						end
					end
				else
					return
				end
			end
		end
	end
	function AnyEnemyDPSCCed()
		for i=1,#LYEnemiesAll do
			if UnitIsCCed(LYEnemiesAll[i]) and CheckRole(LYEnemiesAll[i]) ~= "HEALER" then
				return LYEnemiesAll[i]
			end
		end
	end
	function AnyEnemyHealCCed(timer)
		if #LYEnemyHealers < 1 and not timer then
			return true
		end
		for i=1,#LYEnemyHealers do
			if UnitIsCCed(LYEnemyHealers[i],timer) then
				return LYEnemyHealers[i]
			end
		end
	end
	function AllEnemyHealCCed()
		if #LYEnemyHealers < 1 then
			return
		end
		for i=1,#LYEnemyHealers do
			if not UnitIsCCed(LYEnemyHealers[i]) then
				return
			end
		end
		return true
	end
	function AnyEnemyHasDebuff(SpellName,timer)
		if #LYEnemiesAll == 0 then
			LYEnemiesAll = LYEnemies
		end
		for i=1,#LYEnemiesAll do
			if HaveDebuff(LYEnemiesAll[i],SpellName,timer,"player") then
				return LYEnemiesAll[i]
			end
		end
	end
	function AnyFriendHasBuff(Spell,timer)
		local timer = timer or 1
		if LYZoneType == "arena" then
			for i=1,#LYTeamPlayersAll do
				if HaveBuff(LYTeamPlayersAll[i],Spell,timer,"player") then
					return LYTeamPlayersAll[i]
				end
			end
		else
			for i=1,#LYTeamPlayers do
				if HaveBuff(LYTeamPlayers[i],Spell,timer,"player") then
					return LYTeamPlayers[i]
				end
			end
		end
	end
	function UnitIsStunned(pointer,timeLeft)
		if UnitIsVisible(pointer) then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if tContains(listStuns,tBuff.name) or tContains(listStunsID,tBuff.spellId) then
						local timer = tBuff.expirationTime - GetTime()
						if not timeLeft or timer > timeLeft then
							return true
						end
					end
				else
					return
				end
			end
		end
	end
	function CalculateHP(pointer)
		if UnitIsVisible(pointer) then
			local incHeal,absorb = 0,0
			if #LYTeamHealers > 0 and UnitIsFriend("player",pointer) then
				for i=1,#LYTeamHealers do
					if UnitIsVisible(LYTeamHealers[i]) then
						incHeal = incHeal + (UnitGetIncomingHeals(pointer,LYTeamHealers[i]) or 0)
					end
				end
			end
			if LYMode == "PvP" or UnitIsTank(pointer) then
				absorb = UnitGetTotalHealAbsorbs(pointer)
			end
			return (100 * (UnitHealth(pointer) - absorb + incHeal) / UnitHealthMax(pointer)) or 110
		else
			return 110
		end
	end
	function CalculateMP(pointer)
		if UnitIsVisible(pointer) then
			if UnitIsUnit(pointer,"player") and (HaveBuff("player",DrInner) or LYMyClass == 3) then
				return 100
			else
				return (100 * ( UnitPower(pointer,Enum.PowerType.Mana)) / UnitPowerMax(pointer,Enum.PowerType.Mana))
			end
		else
			return 110
		end
	end
	function inRange(spell,pointer)
		if spell == PlCrusader and IsTalentInUse(404542) then
			spell = PlKick
		end
		local pointer = pointer or "target"
		if UnitIsVisible(pointer) and C_Spell.IsSpellInRange(spell,pointer) then
			return true
		end
	end
	function PartyHPBelow(HP)
		for i=1,#LYTeamPlayers do
			if CalculateHP(LYTeamPlayers[i]) <= HP and UnitAffectingCombat(LYTeamPlayers[i]) then
				return LYTeamPlayers[i]
			end
		end
	end
	function PartyLowestHP(face)
		local lowestHP = 100
		for i=1,#LYTeamPlayers do
			if not face or UnitIsUnit("player",LYTeamPlayers[i]) or ObjectIsFacing("player",LYTeamPlayers[i]) then
				local hp = CalculateHP(LYTeamPlayers[i])
				if hp < lowestHP and UnitAffectingCombat(LYTeamPlayers[i]) then
					lowestHP = hp
				end
			end
		end
		return lowestHP
	end
	function EnemyHPBelow(HP,dist)
		for i=1,#LYEnemies do
			if CalculateHP(LYEnemies[i]) <= HP and (not dist or IsInDistance(LYEnemies[i],dist)) then
				return LYEnemies[i]
			end
		end
	end
	function InEnemySight()
		if #LYEnemies > 0 then
			return true
		end
	end
	function CanHoTSafe(pointer)
		if (CalculateHP(pointer) - CalculateHP(LYTeamPlayers[1])) < 30 or IsMoving() then
			return true
		end
	end
	function IsMoving(pointer)
		local pointer = pointer or "player"
		if UnitIsVisible(pointer) and GetUnitSpeed(pointer) > 0 then
			return true
		end
	end
	function TeamHealerCanInteract()
		for i=1,#LYTeamHealers do
			if UnitIsVisible(LYTeamHealers[i]) and not UnitIsCCed(LYTeamHealers[i],LYGCDTime) and CalculateMP(LYTeamHealers[i]) > 10 and not UnitIsKicked(LYTeamHealers[i]) then
				return LYTeamHealers[i]
			end
		end
	end
	function TeamHealerCCed(timer)
		for i=1,#LYTeamHealersAll do
			if UnitIsVisible(LYTeamHealersAll[i]) and UnitIsCCed(LYTeamHealersAll[i],timer) then
				return LYTeamHealersAll[i]
			end
		end
	end
	function TeamHealerCanDispel(spell)
		local healer = TeamHealerCanInteract()
		if UnitIsVisible(healer) and SpellIsReady(healer,GetClassSpell(healer,"dispel"),8) and (spell ~= ShHex or select(2,UnitClass(healer)) ~= "PALADIN") then
			return true
		end
	end
	function BreakCCAroundUnit(pointer,range,face)
		local pointer = pointer or "player"
		for i=1,#LYEnemiesBCCed do
			if UnitIsVisible(LYEnemiesBCCed[i]) and (not range or inRange(range,LYEnemiesBCCed[i]) or (type(range) == "number" and IsInDistance(pointer,range,LYEnemiesBCCed[i]))) and (not face or IsLookingAt(LYEnemiesBCCed[i])) then
				return true
			end
		end
	end
	function EnemiesAroundUnit(range,pointer,dot,face,minors)
		local count = -1
		local pointer = pointer or "player"
		if BreakCCAroundUnit(pointer,range) or not UnitAffectingCombat("player") then
			return -1
		end
		for i=1,#LYEnemies do
			if (inRange(range,LYEnemies[i]) or (type(range) == "number" and IsInDistance(LYEnemies[i],range,pointer))) and (not dot or not HaveDebuff(LYEnemies[i],dot,0,"player")) and (not face or ObjectIsFacing("player",LYEnemies[i])) and (LYMode ~= "PvE" or UnitAffectingCombat(LYEnemies[i])) then
				count = count + 1
			end
		end
		if minors then
			for i=1,#LYEnemyMinors do
				if (inRange(range,LYEnemyMinors[i]) or (type(range) == "number" and IsInDistance(LYEnemyMinors[i],range,pointer))) and (not dot or not HaveDebuff(LYEnemyMinors[i],dot,0,"player")) and (not face or ObjectIsFacing("player",LYEnemyMinors[i])) and (LYMode ~= "PvE" or UnitAffectingCombat(LYEnemyMinors[i])) then
					count = count + 1
				end
			end
		end
		if count ~= -1 then
			count = count + 1
		end
		return count
	end
	function EnemiesAroundUnitDoTed(range,pointer,dot,all,timeLeft,stacks)
		local count = 0
		local pointer = pointer or "player"
		local enemies = LYEnemiesAll
		for i=1,#LYEnemies do
			if UnitIsVisible(LYEnemies[i]) and (not range or inRange(range,LYEnemies[i]) or (type(range) == "number" and IsInDistance(LYEnemies[i],range,pointer))) and ((not all and HaveDebuff(LYEnemies[i],dot,timeLeft or 1,"player")) or (all and HaveAllDebuffs(LYEnemies[i],dot,0))) and (not stacks or DebuffCount(LYEnemies[i],dot) == stacks) then
				count = count + 1
			end
		end
		return count
	end
	function TeamMembersAroundUnit(range,pointer,HP,hot,face)
		local count = 0
		local pointer = pointer or "player"
		local HP = HP or 101
		for i=1,#LYTeamPlayers do
			if (not range or IsInDistance(LYTeamPlayers[i],range,pointer)) and CalculateHP(LYTeamPlayers[i]) < HP and (not hot or not HaveBuff(LYTeamPlayers[i],hot)) and (not face or UnitIsUnit("player",LYTeamPlayers[i]) or ObjectIsFacing("player",LYTeamPlayers[i])) then
				count = count + 1
			end
		end
		return count
	end
	function TeamMembersAroundUnitBuffed(hot,all,timeLeft,stacks)
		local count = 0
		for i=1,#LYTeamPlayers do
			if UnitIsVisible(LYTeamPlayers[i]) and ((not all and HaveBuff(LYTeamPlayers[i],hot,timeLeft or 1)) or (all and HaveAllBuffs(LYTeamPlayers[i],hot,0))) and (not stacks or BuffCount(LYTeamPlayers[i],hot) == stacks) then
				count = count + 1
			end
		end
		return count
	end
	function FriendIsUnderAttack(pointer,role,HP,burst,count)
		local hpcheck = nil
		local total = 0
		if HP and CalculateHP(pointer) < HP then
			hpcheck = true
		end
		if HaveBuff(pointer,listIDmgAll) then
			return
		end
		local pve = LYMode ~= "PvP" and UnitAffectingCombat(pointer) and (UnitIsTank(pointer) or HP)
		for i=1,#LYEnemies do
			if (UnitIsTargetingUnit(LYEnemies[i],pointer) or pve) and not UnitIsCCed(LYEnemies[i]) and not HaveDebuff(LYEnemies[i],listDisarm) and (LYMode ~= "PvP" or UnitIsPlayer(LYEnemies[i])) and ((not HP and not burst) or (HP and hpcheck) or (burst and IsBursting(LYEnemies[i]))) and (LYMode ~= "PvP" or (not role and IsInDistance(LYEnemies[i],50,pointer)) or (role and role == "MELEE" and CheckRole(LYEnemies[i]) == "MELEE" and IsInDistance(LYEnemies[i],7,pointer)) or (role and role == "RDPS" and CheckRole(LYEnemies[i]) == "RDPS" and IsInDistance(LYEnemies[i],45,pointer)) or (role and role == "WIZARD" and IsWizzard(LYEnemies[i]) and IsInDistance(LYEnemies[i],45,pointer))) then
				if not count then
					return LYEnemies[i]
				else
					total = total + 1
				end
			end
		end
		if count and total >= count then
			return true
		end
	end
	function EnemyIsUnderAttack(pointer)
		for i=1,#LYTeamPlayers do
			if UnitIsTargetingUnit(LYTeamPlayers[i],pointer) and UnitAffectingCombat(pointer) and CheckRole(LYTeamPlayers[i]) ~= "HEALER" then
				return true
			end
		end
	end
	function TeamIsBursting(dist)
		if LYBurstMacro then
			return true
		end
		for i=1,#LYTeamPlayers do
			if IsBursting(LYTeamPlayers[i]) and (not dist or IsInDistance(LYTeamPlayers[i],dist)) then
				return true
			end
		end
	end
	function EnemyIsBursting(dist)
		for i=1,#LYEnemies do
			if IsBursting(LYEnemies[i]) and (not dist or IsInDistance(dist)) then
				return LYEnemies[i]
			end
		end
	end
	function BurstCondition(HP,Healer,Burst,Def,typedmg,SpellName)
		local function CanPvEBurst()
			local hp = 0
			if LYBurstMacro or (UnitIsBoss(LYEnemyTarget) and LYBurstPvE) then
				return true
			end
			if LYBurstPvE then
				if UnitIsVisible(LYEnemyTarget) and LYZoneType == "Outworld" and UnitAffectingCombat("player") and tContains(listDummies,ObjectId(LYEnemyTarget)) and ObjectIsFacing("player",LYEnemyTarget) then
					return true
				end
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and UnitAffectingPvECombat(LYEnemies[i]) then
						hp = hp + UnitHealth(LYEnemies[i])
					end
				end
				if hp > UnitHealthMax("player") * 3 then
					return true
				end
			end
		end
		if ValidEnemyUnit(LYEnemyTarget) and inRange(SpellName,LYEnemyTarget) and not HaveDebuff("player",listDisarm) then
			if LYMode == "PvP" then
				if LYHDPS or not UnitIsPlayer(LYEnemyTarget) or (typedmg and not SpellAttackTypeCheck(LYEnemyTarget,typedmg)) or (not Def and HaveBuff(LYEnemyTarget,listDef)) then
					return
				end
				if (LYBurstPickup and IsBursting()) or LYBurstMacro then
					return true
				end
				if CalculateHP(LYEnemyTarget) < HP then
					return true
				end
				if Healer and #LYEnemyHealers > 0 then
					for i=1,#LYEnemyHealers do
						if UnitIsCCed(LYEnemyHealers[i],4) then
							return true
						end
					end
				end
				if Burst and #LYTeamPlayers > 1 then
					for i=1,#LYTeamPlayers do
						if IsBursting(LYTeamPlayers[i]) and not UnitIsUnit(LYTeamPlayers[i],"player") and CheckRole(LYTeamPlayers[i]) ~= "HEALER" then
							return true
						end
					end
				end
			elseif CanPvEBurst() then
				return true
			end
		end
	end
	function EnemyCanKick(Fake)
		if LYMode == "PvP" and not HaveBuff("player",listIKick) and ((not castInterruptableP and not PartyHPBelow(20)) or UnitChannelInfo("player") == MnSoothMist) then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and not UnitIsCCed(LYEnemies[i]) then
					local tempClass = select(2,UnitClass(LYEnemies[i]))
					if CheckRole(LYEnemies[i]) == "MELEE" or tempClass == "MAGE" or (tempClass == "SHAMAN" and CheckRole(LYEnemies[i]) ~= "HEALER") or tempClass == "HUNTER" or tempClass == "EVOKER" then
						local guid = UnitGUID(LYEnemies[i])
						if not KicksData[guid] then
							KicksData[guid] = {Time = 0,CD = 0,Percent = 35}
						end
						if (GetTime() - KicksData[guid].Time) > KicksData[guid].CD and ((tContains(list6yaKick,tempClass) and IsInDistance(LYEnemies[i],6)) or (tempClass == "EVOKER" and IsInDistance(LYEnemies[i],25)) or (tempClass == "DEMONHUNTER" and IsInDistance(LYEnemies[i],11)) or (tempClass == "SHAMAN" and IsInDistance(LYEnemies[i],26)) or ((tempClass == "MAGE" or (tempClass == "HUNTER" and CheckRole(LYEnemies[i]) == "RDPS")) and IsInDistance(LYEnemies[i],41)) or ((tempClass == "DRUID" or tempClass == "DEATHKNIGHT") and IsInDistance(LYEnemies[i],16))) then
							if not Fake then
								return true
							elseif UnitCastingInfo("player") and castTimeTotalP / 1000 > 0.6 and currentCastPercentP < 90 and ((currentCastPercentP > (KicksData[guid].Percent - 5) and FakeCount == 1) or (currentCastPercentP > (KicksData[guid].Percent + 10) and FakeCount == 2)) then
								LYFakeSpell = UnitCastingInfo("player")
								LYSpellStopCasting()
								LY_Print("Faking X"..FakeCount.." "..tempClass,"green")
								PauseGCD = GetTime()+0.5
								FakeCount = FakeCount + 1
							end
						end
					end
				end
			end
		end
	end
	function TotemsAroundPet(dist)
		for i=1,#LYEnemyTotems do
			if IsInDistance("pet",dist,LYEnemyTotems[i]) then
				return LYEnemyTotems[i]
			end
		end
	end
	function TimeToEnergy(value)
		local energyRegenRate = select(2,GetPowerRegen())
		if UnitPower("player") >= value then
			return 0
		else
			return (value - UnitPower("player"))/energyRegenRate
		end
	end
	function PlayerOutOfCC()
		if LYPlayerOutOfCC and LYPlayerOutOfCC + 2 > GetTime() then
			return true
		end
	end
	function OthersCanKick(pointer)
		if LYZoneType == "arena" then
			for i=1,#LYTeamPlayersAll do
				if UnitIsVisible(LYTeamPlayersAll[i]) and SpellIsReady(LYTeamPlayersAll[i],GetClassSpell(LYTeamPlayersAll[i],"kick")) and InLineOfSight(pointer,LYTeamPlayersAll[i]) and not UnitIsCCed(LYTeamPlayersAll[i]) and ((tContains(list6yaKick,tempClass) and IsInDistance(LYTeamPlayersAll[i],6,pointer)) or (tempClass == "SHAMAN" and IsInDistance(LYTeamPlayersAll[i],26,pointer)) or (tempClass == "MAGE" and IsInDistance(LYTeamPlayersAll[i],41,pointer)) or (((tempClass == "DRUID" and CheckRole(LYTeamPlayersAll[i]) == "MELEE") or tempClass == "DEATHKNIGHT") and IsInDistance(LYTeamPlayersAll[i],16,pointer)) or (tempClass == "HUNTER" and (IsInDistance(LYTeamPlayersAll[i],6,pointer) or (CheckRole(LYTeamPlayersAll[i]) == "RDPS" and IsInDistance(LYTeamPlayersAll[i],41,pointer))))) then
					return true
				end
			end
		else
			for i=1,#LYTeamPlayers do
				if UnitIsVisible(LYTeamPlayers[i]) and SpellIsReady(LYTeamPlayers[i],GetClassSpell(LYTeamPlayers[i],"kick")) and InLineOfSight(pointer,LYTeamPlayers[i]) and not UnitIsCCed(LYTeamPlayers[i]) and ((tContains(list6yaKick,tempClass) and IsInDistance(LYTeamPlayers[i],6,pointer)) or (tempClass == "SHAMAN" and IsInDistance(LYTeamPlayers[i],26,pointer)) or (tempClass == "MAGE" and IsInDistance(LYTeamPlayers[i],41,pointer)) or (((tempClass == "DRUID" and CheckRole(LYTeamPlayers[i]) == "MELEE") or tempClass == "DEATHKNIGHT") and IsInDistance(LYTeamPlayers[i],16,pointer)) or (tempClass == "HUNTER" and (IsInDistance(LYTeamPlayers[i],6,pointer) or (CheckRole(LYTeamPlayers[i]) == "RDPS" and IsInDistance(LYTeamPlayers[i],41,pointer))))) then
					return true
				end
			end
		end
	end
	function GetClassSpell(pointer,spellType)
		local class = select(2,UnitClass(pointer))
		if spellType == "kick" and CheckRole(pointer) == "HEALER" and class ~= 7 then
			return
		end
		if spellType == "dispel" and CheckRole(pointer) ~= "HEALER" then
			return
		end
		if class == 1 then
			return WrKick
		elseif class == 2 then
			if spellType == "kick" then
				return PlKick
			else
				return PlDispel
			end
		elseif class == 3 then
			return HnKick
		elseif class == 4 then
			return RgKick
		elseif class == 5 and spellType == "dispel" then
			return PrDispel
		elseif class == 6 then
			return DKKick
		elseif class == 7 then
			if spellType == "kick" then
				return ShKick
			else
				return ShDispel
			end
		elseif class == 8 then
			return MgKick
		elseif class == 10 then
			if spellType == "kick" then
				return MnKick
			else
				return MnDispel
			end
		elseif class == 11 and spellType == "dispel" then
			return DrDispel
		elseif class == 12 then
			return DHKick
		elseif class == 13 then
			return EvKick
		end
	end
	function SpellIsReady(pointer,SpellName,timer)
		if not UnitIsVisible(pointer) or not SpellName then
			return
		end
		local guid = UnitGUID(pointer)
		local timer = timer or 0
		if not LYUnitAbilityUsedTime[guid] then
			LYUnitAbilityUsedTime[guid] = {}
		end
		if not LYUnitAbilityUsedTime[guid][SpellName] then
			LYUnitAbilityUsedTime[guid][SpellName] = 0
		end
		if tContains(list15CDKick,SpellName) then
			if SpellName == ShKick then
				timer = 12
			else
				timer = 15
			end
		elseif tContains(list24CDKick,SpellName) then
			timer = 24
		end
		if GetTime() - LYUnitAbilityUsedTime[guid][SpellName] > timer then
			return true
		end
	end
	function FriendRoleExists(role)
		for i=1,#LYTeamPlayers do
			if CheckRole(LYTeamPlayers[i]) == role then
				return LYTeamPlayers[i]
			end
		end
	end
	function EnemyClassExists(class)
		if LYMode ~= "PvE" then
			if #LYEnemiesAll == 0 then
				LYEnemiesAll = LYEnemies
			end
			for i=1,#LYEnemiesAll do
				if UnitIsVisible(LYEnemiesAll[i]) and UnitIsPlayer(LYEnemiesAll[i]) then
					local tempClass = select(2,UnitClass(LYEnemiesAll[i]))
					if tempClass and tempClass == class then
						return LYEnemiesAll[i]
					end
				end
			end
		end
	end
	function UnitsCCedOnPathTo(pointer)
		for i=1,#LYEnemiesBCCed do
			if UnitIsVisible(LYEnemiesBCCed[i]) and ObjectIsFacing("player",LYEnemiesBCCed[i]) then
				return true
			end
		end
	end
	function UnitCanCastOnMove(SpellName,pointer)
		local pointer = pointer or "player"
		local tSpell = C_Spell.GetSpellInfo(SpellName)
		if (tSpell and tSpell.castTime == 0) or HaveBuff(pointer,{ShWalker,MgIceFloes}) or tContains(listCastOnMove,SpellName) or (UnitIsVisible(pointer) and UnitIsUnit("player",pointer) and not IsMoving()) then
			return true
		end
	end
	function LY_Print(text,color,SpellName)
		if LYLog and (not TimerPrint[text] or TimerPrint[text].t < GetTime()) then
			if color then
				if color == "green" then
					RaidNotice_AddMessage(RaidWarningFrame, text, {r=0,g=1,b=0},2)
				else
					RaidNotice_AddMessage(RaidWarningFrame, text, {r=1,g=0,b=0},2)
				end
			else
				RaidNotice_AddMessage(RaidWarningFrame, text, {r=1,g=0.3,b=0},2)
			end
			if LYSoundLog then
				PlaySound(8959)
			end
			TimerPrint[text] = {t = GetTime() + 1}
			if TimerPrintTime > GetTime() then
				TimerPrint = nil
				TimerPrintTime = GetTime() + 10
			end
			if GetSpellInfo(text) then
				SpellName = text
			end
			if SpellName and GetSpellInfo(SpellName) and LYStart and not LYHideIcons then
				LegacyFrame_SpellWarning:SetNormalTexture(C_Spell.GetSpellInfo(SpellName).iconID)
				LegacyFrame_SpellWarning:Show()
				C_Timer.After(1, function() LegacyFrame_SpellWarning:Hide() end)
			end
		end
	end
	function IsBursting(pointer)
		local pointer = pointer or "player"
		if not UnitIsVisible(pointer) then
			return
		elseif pointer == "player" and LYBurstMacro then
			return true
		end
		if (HaveBuff(pointer,listBursts,6.5) and not UnitIsTank(pointer)) or (HaveBuff(pointer,listBursts2,6.5) and CheckRole(pointer) ~= "HEALER") then
			return true
		end
	end
	function IsRooted(pointer,timer)
		local pointer = pointer or "player"
		local timer = timer or 0
		if HaveDebuff(pointer,listRoots,timer) or HaveDebuff(pointer,listRootsAd,timer) then
			return true
		end
	end
	function RecordMovement()
		for i=1,#LYEnemiesAll do
			if UnitIsVisible(LYEnemiesAll[i]) and RecordMove[UnitGUID(LYEnemiesAll[i])] then
				local X1,Y1,Z1 = ObjectPosition(LYEnemiesAll[i])
				RecordMove[UnitGUID(LYEnemiesAll[i])] = {X = X1,Y = Y1,Z = Z1}
			end
		end
	end
	function PlayerHasTierBonus(num)
		local bonus = 0
		for _,i in ipairs(listTierSets[LYMyClass]) do
			if IsEquippedItem(i) then
				bonus = bonus + 1
			end
		end
		if bonus >= num then
			return true
		end
	end
	function ReturnTeamMate(dps)
		for i=1,#LYTeamPlayers do
			if UnitIsVisible(LYTeamPlayers[i]) and not UnitIsUnit("player",LYTeamPlayers[i]) and (not dps or CheckRole(LYTeamPlayers[i]) ~= "HEALER") then
				return LYTeamPlayers[i]
			end
		end
		return "player"
	end
	function UnitIsKicked(pointer)
		if (LockTime[UnitGUID(pointer)] and GetTime() - LockTime[UnitGUID(pointer)] < 0.5) or HaveDebuff(pointer,listSilence) then
			return true
		end
	end
	function IsInBossFight()
		if LYMode ~= "PvP" and UnitAffectingCombat("player") then
			local boss
			for i=1,5 do
				boss = "boss"..i
				if UnitIsVisible(boss) then
					return true
				end
			end
			if LYInBossFight then
				return true
			end
		end
	end
	function StopMoving(full)
		MoveAndSteerStop()
		MoveForwardStop()
		MoveBackwardStop()
		PitchDownStop()
		PitchUpStop()
		StrafeLeftStop()
		StrafeRightStop()
		TurnLeftStop()
		TurnOrActionStop()
		TurnRightStop()
		if IsMoving() then
			MoveForwardStart()
			MoveForwardStop()
		end
		if not full then
			if GetKeyStatus(0x02) then
				TurnOrActionStart()
			elseif GetKeyStatus(0x01) then
				CameraOrSelectOrMoveStart()
			end
		end
	end
	function LYSpellStopCasting()
		LYCurrentSpellName = nil
		PauseRotation = true
		SpellStopCasting()
		SpellCancelQueuedSpell()
	end
	function SpellChargesCheck(SpellName)
		local tSpell = C_Spell.GetSpellCharges(SpellName)
		if tSpell.currentCharges == tSpell.maxCharges or (tSpell.currentCharges > 0 and tSpell.cooldownStartTime + tSpell.cooldownDuration - LYGCDTime < GetTime()) then
			return true
		end
	end
	function RecordHP()
		if not UnitAffectingCombat("player") and #LYRecordHP > 0 then
			LYRecordHP = {}
			return
		end
		for i=1,#LYEnemies do
			if UnitIsVisible(LYEnemies[i]) and UnitAffectingCombat(LYEnemies[i]) then
				local guid = UnitGUID(LYEnemies[i])
				if not LYRecordHP[guid] then
					LYRecordHP[guid] = {}
				end
				tinsert(LYRecordHP[guid],UnitHealth(LYEnemies[i]))
			end
		end
	end
	function CalcTimeToDie(pointer)
		if UnitIsVisible(pointer) then
			local guid = UnitGUID(pointer)
			if LYRecordHP[guid] and #LYRecordHP[guid] > 1 then
				local hp = 0
				for i=1,#LYRecordHP[guid]-1 do
					hp = hp + LYRecordHP[guid][i] - LYRecordHP[guid][i+1]
				end
				return UnitHealth(pointer)/hp/(#LYRecordHP[guid]-1)
			end
		end
		return 100
	end
	function LYQueueSpell(SpellName,pointer,face,Y,Z)
		if not LYCurrentSpellName then
			if unlocker == "MB" and pointer == "target" then
				local guid = UnitGUID("target")
				if guid then
					local obj = GetObjectWithGUID(guid)
					if obj then 
						pointer = obj 
					end
				end
			end
			LYCurrentSpellName = SpellName
			LYCurrentSpellTarget = pointer or "none"
			LYSpellTime = 0
			if pointer == "point" then
				LYCurrentSpellX = face
				LYCurrentSpellY = Y
				LYCurrentSpellZ = Z
			elseif face then
				LYCurrentSpellFace = face
			end
		end
	end
	function LYFacingCheck(pointer)
		LYCurrentSpellFace = nil
		if UnitIsVisible(pointer) then
			if ObjectIsFacing("player",pointer) then
				return true
			elseif LYFacing then
				LYCurrentSpellFace = "face"
				return true
			end
		end
	end
	function LYFireSpell()
		local function CheckCast(SpellName,pointer)
			if pointer then
				local timer = C_Spell.GetSpellInfo(SpellName).castTime/1000
				if SpellName == HnTrap or SpellName == WlCoil then
					timer = GetDistanceToUnit(pointer)/20
				end
				if tContains(listCC,SpellName) and HaveBuff(pointer,listICC,timer+LYMyPing*2) then
					LY_Print("Can not cast "..SpellName..". Target is immune","red",SpellName)
					LYSpellQueue = {}
					return
				end
				if tContains(listStuns,SpellName) and HaveBuff(pointer,listIStun,timer+LYMyPing*2) then
					LY_Print("Can not cast "..SpellName..". Target is immune","red",SpellName)
					LYSpellQueue = {}
					return
				end
				if tContains(listFear,SpellName) and HaveBuff(pointer,listIFear,timer+LYMyPing*2) then
					LY_Print("Can not cast "..SpellName..". Target is immune","red",SpellName)
					LYSpellQueue = {}
					return
				end
				if tContains(listKicks,SpellName) and ((not UnitCastingInfo(pointer) and not UnitChannelInfo(pointer)) or HaveBuff(pointer,listIKick) or select(8,UnitCastingInfo(pointer)) or select(7,UnitChannelInfo(pointer))) then
					LY_Print("Can not cast "..SpellName..". Target is immune","red",SpellName)
					LYSpellQueue = {}
					return
				end
				if tContains(listMagicCC,SpellName) and (HaveBuff(pointer,listIMagic,timer+LYMyPing*2) or (LYMode == "PvP" and not SpellAttackTypeCheck(pointer,"magic"))) then
					LY_Print("Can not cast "..SpellName..". Target is immune","red",SpellName)
					LYSpellQueue = {}
					return
				end
				if SpellName == DKGrip and IsRooted(pointer) then
					LYSpellQueue = {}
					return
				end
			end
			return true
		end
		local function Cast(SpellName,pointer)			
			local function FindSpellKeybinding(SpellName)
				for _, actionBar in ipairs(ActionBarButtonNames) do
					for i = 1, NUM_ACTIONBAR_BUTTONS do
						local btn = _G[actionBar .. i]
						local _, actionSpellID = GetActionInfo(btn.action)
						if actionSpellID and GetSpellInfo(actionSpellID) == SpellName then
							return MapActionBarToBinding[actionBar .. i]
						end
					end
				end				
				return "JUMP"
			end			
			if pointer == "point" then
				if GetItemSpell(SpellName) then
					UseItemByName(SpellName)
				else
					LYActiveSpellCast = SpellName
					CastSpellByName(SpellName)
				end
			elseif SpellName ~= MgFBlast or SpellName ~= DrStealth then
				if GetItemSpell(SpellName) then
					UseItemByName(SpellName,pointer)
				else
					LYActiveSpellCast = SpellName					
					IncrementAppleCount(FindSpellKeybinding(SpellName))
					CastSpellByName(SpellName,pointer)
					IncrementAppleCount(FindSpellKeybinding(SpellName))
				end
			end
			if LYOriginalPosition then
				FaceDirection(LYOriginalPosition,false)
				LYOriginalPosition = nil
			end
			LYCurrentSpellFace = nil
			if SpellIsTargeting() then
				ClickAOESpell(pointer)
				C_Timer.After(LYMyPing*2,function() if SpellIsTargeting() then ClickAOESpell(pointer) end end)
			end
			if SpellName == MgFBlast then
				LYLastSpellName = MgFBlast
			end
			if SpellName == DrStealth then
				LYLastSpellName = DrStealth
			end
			if SpellName == MgAlterTime then
				LastAlterTime = GetTime()
				LYLastSpellName = MgAlterTime
			end
		end
		if LYCurrentSpellName and (not LYCastTimerSpell or LYCastTimerSpell ~= LYCurrentSpellName) then
			LYCastTimerSpell = LYCurrentSpellName
		end
		if LYCastTimerSpell and CDLeft(LYCastTimerSpell) < 1 and C_Spell.GetSpellCooldown(LYCastTimerSpell).startTime ~= 0 then
			if CDLeft(LYCastTimerSpell) > 0.1 then
				if GetTime() > LYCastTimer then
					CastSpellByName(LYCastTimerSpell)
					local t = math.min(200,CDLeft(LYCastTimerSpell)*1000)
					if t < 50 then
						t = 75
					end
					LYCastTimer = GetTime() + math.random(50,t)/1000
				end
				return
			else
				LYCastTimerSpell = nil
			end
		end
		local spells = {}
		for i=1,#LYSpellQueue do
			if LYSpellQueue[i] and LYSpellQueue[i].timer + LYGCDTime*2 > GetTime() then
				tinsert(spells,LYSpellQueue[i])
			end
		end
		LYSpellQueue = spells
		if #LYSpellQueue > 0 and CDCheck(LYSpellQueue[1].spell,true) and LYSpellQueue[1].spell ~= LYCurrentSpellName and CheckCast(LYSpellQueue[1].spell,LYSpellQueue[1].unit) and (not UnitIsVisible(LYSpellQueue[1].unit) or InLineOfSight(LYSpellQueue[1].unit)) then
			LYCurrentSpellName = nil
			local spell = LYSpellQueue[1].spell
			LYQueueSpell(LYSpellQueue[1].spell,LYSpellQueue[1].unit,"face")
			if LYLastQueueSpell and LYSpellQueue[1].spell == LYLastQueueSpell then
				LYSpellQueue[1] = nil
			end
			LYLastQueueSpell = spell
			DoNotUsePower = nil
		end
		if LYCurrentSpellName and (C_Spell.GetSpellLossOfControlCooldown(LYCurrentSpellName) == 0 or GetItemSpell(LYCurrentSpellName)) and LYCurrentSpellName ~= LYActiveSpellCast and (LYLastSpellName ~= LYCurrentSpellName or not tContains(listDontCastTwice,LYCurrentSpellName)) then
			if UnitIsVisible(LYCurrentSpellTarget) then
				if C_Spell.GetSpellCooldown(LYCurrentSpellName).startTime == 0 and not InLineOfSight(LYCurrentSpellTarget) then
					LYCurrentSpellName = nil
					LYSpellQueue = {}
					return
				end
				if not LYCurrentSpellFace or UnitIsUnit(LYCurrentSpellTarget,"player") or (LYCurrentSpellFace and ObjectIsFacing("player",LYCurrentSpellTarget)) then
					if LYCurrentSpellFace == "force" then
						Face(LYCurrentSpellTarget)
					end
					Cast(LYCurrentSpellName,LYCurrentSpellTarget)
					return
				end				
				if LYCurrentSpellFace and C_Spell.GetSpellCooldown(LYCurrentSpellName).startTime == 0 then
					if LYCurrentSpellFace and GetSpellInfo(LYCurrentSpellName).startTime == 0 then
						LYOriginalPosition = ObjectFacing("player")
					end
					local pX,pY = ObjectPosition("player")
					local tX,tY = ObjectPosition(LYCurrentSpellTarget)
					FaceDirection(math.atan2(tY - pY,tX - pX) % (math.pi * 2),false)
				end
			elseif LYCurrentSpellTarget == "point" then
				Cast(LYCurrentSpellName,"point")
			elseif LYCurrentSpellTarget == "none" or LYCurrentSpellTarget == "cursor" then
				Cast(LYCurrentSpellName)
			else
				LYCurrentSpellName = nil
			end
		end
	end
	function IsInDistance(obj1,dist,obj2)
		local obj1 = obj1 or "target"
		local obj2 = obj2 or "player"
		local dist = dist or 40
		if LYMyClass == 11 and IsTalentInUse(197524) then
			dist = dist + 5
		end
		if UnitIsVisible(obj1) and UnitIsVisible(obj2) then
			local currentDist = 0
			local X1,Y1,Z1 = ObjectPosition(obj1)
			local X2,Y2,Z2 = ObjectPosition(obj2)
			local TargetCombatReach = UnitCombatReach(obj1) or 0
			local PlayerCombatReach = LYMyCombatReach
			if obj2 ~= "player" then
				PlayerCombatReach = UnitCombatReach(obj2) or 0
			end
			local MeleeCombatReachConstant = 4/3
			if IsMoving(obj1) and IsMoving(obj2) then
				IfSourceAndTargetAreRunning = 8/3
			else
				IfSourceAndTargetAreRunning = 0
			end
			if not X1 or not X2 then
				return
			end
			local dist1 = math.sqrt(((X2-X1)^2) + ((Y2-Y1)^2) + ((Z2-Z1)^2)) - (PlayerCombatReach + TargetCombatReach)
			local dist2 = dist1 + 0.03 * ((13 - dist1) / 0.13)
			local dist3 = dist1 + 0.05 * ((8 - dist1) / 0.15) + 1
			local dist4 = dist1 + (PlayerCombatReach + TargetCombatReach)
			local meleeRange = math.max(5,PlayerCombatReach + TargetCombatReach + MeleeCombatReachConstant + IfSourceAndTargetAreRunning)
			if dist1 > 13 then
				currentDist = dist1
			elseif dist2 > 8 and dist3 > 8 then
				currentDist = dist2
			elseif dist3 > 5 and dist4 > 5 then
				currentDist = dist3
			elseif dist4 > meleeRange then
				currentDist = dist4
			end
			if currentDist < dist then
				return true
			end
		end
	end
	function CheckRole(pointer)
		if UnitIsVisible(pointer) then
			if UnitIsPlayer(pointer) then
				local class = select(2,UnitClass(pointer))
				if pointer == "player" then
					if class == "WARLOCK" or class == "MAGE" or class == "PRIEST" or class == "EVOKER" then
						return "RDPS"
					elseif class == "WARRIOR" or class == "DEATHKNIGHT" or class == "ROGUE" or class == "PALADIN" or class == "MONK" or class == "DEMONHUNTER" then
						return "MELEE"
					elseif class == "DRUID" or class == "SHAMAN" then
						if LYMySpec == 1 then
							return "RDPS"
						else
							return "MELEE"
						end
					elseif class == "HUNTER" then
						if LYMySpec == 3 then
							return "MELEE"
						else
							return "RDPS"
						end
					end
				elseif class and UnitIsVisible(pointer) then
					if LYZoneType == "arena" and UnitCanAttack("player",pointer) then
						for i = 1,5 do
							local unit = "arena"..i
							local specID = GetArenaOpponentSpec(i)
							if specID and UnitIsVisible(unit) and UnitIsUnit(pointer,unit) then
								local id,_,_,_,role = GetSpecializationInfoByID(specID)
								if role == "HEALER" or ((class == "PALADIN" or class == "DRUID") and role == "TANK") then
									return "HEALER"
								elseif (class == "HUNTER" and id ~= 255) or class == "PRIEST" or class == "EVOKER" or class == "MAGE" or class == "WARLOCK" or (class == "SHAMAN" and id == 262) or (class == "DRUID" and id == 102) then
									return "RDPS"
								else
									return "MELEE"
								end
							end
						end
					else
						local specRealID = GetSpecByDescriptor(pointer)
						if specRealID and specRealID < 1500 then
							local id,_,_,_,role = GetSpecializationInfoByID(specRealID)
							if role == "HEALER" then
								return "HEALER"
							elseif (class == "HUNTER" and id ~= 255) or class == "EVOKER" or class == "PRIEST" or class == "MAGE" or class == "WARLOCK" or (class == "SHAMAN" and id == 262) or (class == "DRUID" and id == 102) then
								return "RDPS"
							else
								return "MELEE"
							end
						end
					end
				end
			elseif LYMode ~= "PvP" then
				if UnitCastingInfo(pointer) then
					return "RDPS"
				else
					return "MELEE"
				end
			end
		end
		return ""
	end
	function UnitIsTargetingUnit(obj1,obj2)
		if UnitIsVisible(obj1) and UnitIsVisible(obj2) then
			local unitT = UnitTarget(obj1)
			if UnitIsVisible(unitT) and UnitIsUnit(unitT,obj2) then
				return true
			end
		end
	end
	function EnemyIsTargetingUnit(obj1,obj2)
		if UnitIsVisible(obj1) then
			if obj2 then
				local theT = UnitTarget(obj2)
				if UnitIsVisible(theT) and UnitIsUnit(theT,obj1) then
					return true
				end
			else
				if #LYEnemiesAll == 0 then
					LYEnemiesAll = LYEnemies
				end
				for i=1,#LYEnemiesAll do
					if UnitIsVisible(LYEnemiesAll[i]) and CheckRole(LYEnemiesAll[i]) ~= "HEALER" then
						local unitT = UnitTarget(LYEnemiesAll[i])
						if UnitIsVisible(unitT) and UnitIsUnit(unitT,obj1) then
							return unitT
						end
					end
				end
			end
		end
	end
	function InLineOfSight(obj1,obj2)
		local obj1 = obj1 or "target"
		local obj2 = obj2 or "player"
		if obj1 == obj2 then
			return true
		end
		if UnitIsVisible(obj1) and UnitIsVisible(obj2) then
			if (LYMode ~= "PvP" and UnitIsBoss(obj1) and UnitAffectingPvECombat(obj1)) or UnitIsUnit(obj1,obj2) then
				return true
			end
			local X1,Y1,Z1 = ObjectPosition(obj1)
			local X2,Y2,Z2 = ObjectPosition(obj2)
			local obj1Height = ObjectHeight(obj1) or 2
			local obj2Height = ObjectHeight(obj2) or 2
			if not Z1 or not Z2 then
				if LYMode == "PvE" then
					return true
				else
					return
				end
			end
			return not TraceLine(X1,Y1,Z1 + obj1Height,X2,Y2,Z2 + obj2Height,0x100011)
		end
	end
	function InLineOfSightPointToUnit(X,Y,Z,pointer)
		local pointer = pointer or "player"
		if UnitIsVisible(pointer) and Z then
			local X1,Y1,Z1 = ObjectPosition(pointer)
			local objHeight = ObjectHeight(pointer) or 2
			return not TraceLine(X1,Y1,Z1 + objHeight,X,Y,Z,0x100011)
		end
	end
	function InLineOfSightPointToPoint(X,Y,Z,X1,Y1,Z1)
		return not TraceLine(X1,Y1,Z1,X,Y,Z,0x100011)
	end
	function GetDistanceToUnit(pointer)
		if UnitIsVisible(pointer) then
			local X1,Y1,Z1 = ObjectPosition(pointer)
			if not X1 or not Y1 or not Z1 then return 100 end
			local X2,Y2,Z2 = ObjectPosition("player")
			return math.sqrt(((X2 - X1) ^ 2) + ((Y2 - Y1) ^ 2) + ((Z2 - Z1) ^ 2))
		else
			return 100
		end
	end
	function GetDistancePointToUnit(X,Y,Z,pointer)
		local pointer = pointer or "player"
		if UnitIsVisible(pointer) then
			local X1,Y1,Z1 = ObjectPosition(pointer)
			return math.sqrt(((X - X1) ^ 2) + ((Y - Y1) ^ 2) + ((Z - Z1) ^ 2))
		else
			return 100
		end
	end
	function GetDistancePointToPoint(X,Y,Z,X1,Y1,Z1)
		return math.sqrt(((X - X1) ^ 2) + ((Y - Y1) ^ 2) + ((Z - Z1) ^ 2))
	end
	function IsRotatedAt(object, dir, mod)
		return math.abs(dir - ObjectFacing(object)) < 0.2 * mod
	end
	function GroundZ(X,Y,Z)
		local x,y,z = TraceLine(X,Y,Z+4,X,Y,-10000,0x100111)
		if not z then z = Z end
		return x,y,math.min(z,Z)
	end
	function GetAnglesBetweenPositions(X1, Y1, Z1, X2, Y2, Z2)
		return math.atan2(Y2 - Y1, X2 - X1) % (math.pi * 2), math.atan((Z1 - Z2) / math.sqrt(math.pow(X1 - X2, 2) + math.pow(Y1 - Y2, 2))) % math.pi
	end
	function IsLookingAt(obj1,obj2,mod)
		local obj1 = obj1 or "target"
		local obj2 = obj2 or "player"
		local mod = mod or 1
		local f = ObjectFacing(obj2)
		local dir = GetAnglesBetweenObjects(obj2, obj1)
		if not dir then return false end
		if IsRotatedAt(obj2, dir, mod) then
			return true
		end
	end
	function Face(pointer,update)
		local pointer = pointer or "target"
		local angle = GetAnglesBetweenObjects("player",pointer)
		if not angle then
			return
		end
		FaceDirection(angle,update or false)
	end
	function PlayerIsSpellTarget(pointer)
		local destPointer = nil
		if UnitIsVisible(pointer) then
			destPointer = UnitCastingTarget(pointer)
			if UnitIsVisible(destPointer) and UnitIsUnit(destPointer,"player") then
				return true
			end
		end
	end
	function GetSpellDestUnit(pointer)
		local destPointer = nil
		local pointer = pointer or "player"
		if UnitIsVisible(pointer) then
			destPointer = UnitCastingTarget(pointer)
			if UnitIsVisible(destPointer) then
				return destPointer
			end
		end
	end
	function KickSuccub()
		if LYIgnorePets and LYMode == "PvP" and UnitAffectingCombat("player") and EnemyClassExists("WARLOCK") then
			for i=1,#LYEnemyMinors do
				if UnitIsVisible(LYEnemyMinors[i]) and (not UnitIsVisible(LYEnemyTarget) or not UnitIsUnit(LYEnemyTarget,LYEnemyMinors[i])) and (UnitCastingInfo(LYEnemyMinors[i]) == WlSeduction or UnitChannelInfo(LYEnemyMinors[i]) == WlSeduction) then
					tinsert(LYEnemies,LYEnemyMinors[i])
					return
				end
			end
		end
	end
	function ValidKick(pointer,castName)
		local function CanDispel()
			for i=1,#LYTeamPlayers do
				if UnitIsVisible(LYTeamPlayers[i]) and UnitIsPlayer(LYTeamPlayers[i]) and not UnitIsUnit(LYTeamPlayers[i],"player") and not UnitIsCCed(LYTeamPlayers[i]) then
					local tempClass = select(2,UnitClass(LYTeamPlayers[i]))
					if tempClass == "DRUID" or tempClass == "SHAMAN" or tempClass == "MAGE" then
						return true
					end
				end
			end
		end
		if UnitIsVisible(pointer) and not tContains(LYListNotKick,castName) and not HaveBuff(pointer,listIKick) and (not tContains(listMagicKickClass,LYMyClass) or not HaveBuff(pointer,listIMagic)) then
			if NextKick then
				if (NextKick == "heal" and tContains(LYListHealInt,castName)) or (NextKick == "CC" and tContains(listCCInt,castName)) then
					return true
				end
			elseif not LYKickHold or not OthersCanKick(pointer) then
				if LYKickFocus and (not UnitIsVisible("focus") or not UnitIsUnit("focus",pointer)) then
					return
				end
				local spelltarget = GetSpellDestUnit(pointer)
				if (LYMode == "PvE" and tContains(LYListKickPvE,castName)) or (LYMode ~= "PvE" and tContains(LYListKickPvP,castName) and not HaveBuff(spelltarget,listIMagic,1.5)) then
					return true
				end
				if tContains(listKickChannel,castName) then
					if UnitChannelInfo(pointer) then
						if castName ~= PrMC then
							return true
						elseif LYMyClass ~= 2 and LYMyClass ~= 5 and LYMyClass ~= 7 then
							local teammate = nil
							for i=1,2 do
								teammate = "party"..i
								if UnitIsVisible(teammate) and UnitIsCharmed(teammate) and HaveDebuff(teammate,PrMC,2) then
									return true
								end
							end
						end
					elseif LYKickCCPlayer and UnitIsVisible(spelltarget) and UnitIsUnit(spelltarget,"player") and ((castName == PrMC and CheckUnitDR(spelltarget,"control",1)) or (castName == WlSeduction and CheckUnitDR(spelltarget,"fear",1) and not ShTotemExists(ShTremor,true) and not TeamHealerCanDispel(WlSeduction))) then
						return true
					end
				end
				if UnitIsVisible(spelltarget) then
					if tContains(LYListHealInt,castName) and CalculateHP(spelltarget) < LYKickHealHP and (not LYKickIgnoreDPS or CheckRole(pointer) == "HEALER") then
						return true
					end
					if not HaveBuff(spelltarget,listIMagic,1) and not HaveBuff(spelltarget,listIDmgAll,1) then
						if tContains(listDDInt,castName) and (CalculateHP(spelltarget) < LYKickDPSHP or (LYKickDPSBurst and IsBursting(pointer))) then
							return true
						end
						if tContains(listCCInt,castName) and not HaveBuff(spelltarget,listICC,1) and not HaveDebuff(spelltarget,PlUltSac) and ((LYKickCCPlayer and UnitIsUnit(spelltarget,"player") and (castName ~= ShHex or CanDispel()) and not TeamHealerCanDispel(castName)) or (CheckRole(spelltarget) == "HEALER" and (not LYKickChain or UnitIsCCed(spelltarget))) or (LYKickCCBurst and IsBursting(spelltarget))) then
							if (castName == EvSleepWalk or castName == MnSongChi or (tContains(listShiftCC,castName) and not HaveBuff(spelltarget,listForms))) and CheckUnitDR(spelltarget,"control",LYKickCCDR) then
								return true
							elseif castName == WlFear and CheckUnitDR(spelltarget,"fear",LYKickCCDR) and not HaveBuff(spelltarget,WrBers) and not ShTotemExists(ShTremor,true) then
								return true
							end
						end
					end
				end
			end
		end
	end
	--Common
	function CommonAttack(SpellName,typedmg,face,range,func,dottime,dotspell,aoe,HP)
		if aoe and (LYStyle ~= "All units" or aoe == 0) then
			return
		end
		if GCDCheck(SpellName) and LYStyle ~= "Utilities only" and func then
			if dottime and LYDoTUnits ~= 0 then
				if #LYEnemyTotems > 0 then
					return
				end
				local count = 0
				for i=1,#LYEnemies do
					if inRange(range,LYEnemies[i]) and HaveDebuff(LYEnemies[i],dotspell,dottime,"player") then
						count = count + 1
					end
				end
				if count >= LYDoTUnits then
					return
				end
			end
			local dotUnit = nil
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and (not typedmg or SpellAttackTypeCheck(LYEnemies[i],typedmg)) and inRange(range,LYEnemies[i]) and (not aoe or EnemiesAroundUnit(8,LYEnemies[i]) >= aoe) and (not HP or CalculateHP(LYEnemies[i]) < HP) and (not face or LYFacingCheck(LYEnemies[i])) then
					if not dottime then
						LYQueueSpell(SpellName,LYEnemies[i])
						return true
					elseif LYMode == "PvE" and (UnitClassification(LYEnemies[i]) == "normal" or CalcTimeToDie(LYEnemies[i]) < dottime/1.5) and C_Spell.GetSpellInfo(SpellName).castTime > 0 then
					elseif not HaveDebuff(LYEnemies[i],dotspell,0,"player") then
						LYQueueSpell(SpellName,LYEnemies[i])
						return true
					elseif not dotUnit and not HaveDebuff(LYEnemies[i],dotspell,dottime,"player") then
						dotUnit = LYEnemies[i]
					end
				end
			end
			if dotUnit then
				LYQueueSpell(SpellName,dotUnit)
				return true
			end
		end
	end
	function strme(obj)
		if obj == true then
			return "true"
		elseif obj == false then
			return "false"
		else
			return "nil"
		end
	end
	function CommonAttackTarget(SpellName,typedmg,face,func)
		if GCDCheck(SpellName) and LYStyle ~= "Utilities only" and ValidEnemyUnit(LYEnemyTarget) and (not typedmg or SpellAttackTypeCheck(LYEnemyTarget,typedmg)) and func and (not face or LYFacingCheck(LYEnemyTarget)) then
			LYQueueSpell(SpellName,LYEnemyTarget)
			return true
		end
	end
	function ConditionalSpell(SpellName,func)
		if GCDCheck(SpellName) and func and LYStyle ~= "Utilities only" then
			LYQueueSpell(SpellName)
			return true
		end
	end
	function CastBeforeSpell(SpellName,QueuedSpell,func)
		if CDCheck(SpellName) and LYStyle ~= "Utilities only" and LYCurrentSpellName == QueuedSpell and func then
			LYCurrentSpellName = nil
			SpellCancelQueuedSpell()
			LYQueueSpell(SpellName,LYEnemyTarget)
			return true
		end
	end
	function AOEAttack(SpellName,range,dist,count,func,face)
		if GCDCheck(SpellName) and LYStyle == "All units" and func and count ~= 0 then
			local UnitsAround = 0
			local BestAround = 0
			local BestUnit = nil
			if count == 1 then
				if ValidEnemyUnit(LYEnemyTarget) and inRange(dist,LYEnemyTarget) and not BreakCCAroundUnit(LYEnemyTarget,range) and (not IsMoving(LYEnemyTarget) or LYMode ~= "PvE") then
					BestUnit = LYEnemyTarget
				end
			else
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and inRange(dist,LYEnemies[i]) and (not IsMoving(LYEnemies[i]) or LYMode ~= "PvE") then
						UnitsAround = EnemiesAroundUnit(range,LYEnemies[i],nil,face)
						if UnitsAround ~= 0 and UnitsAround >= BestAround and UnitsAround >= count then
							BestUnit = LYEnemies[i]
							BestAround = UnitsAround
						end
					end
				end
			end
			if BestUnit then
				LYQueueSpell(SpellName,BestUnit)
				return true
			end
		end
	end
	function CommonHeal(SpellName,func,hp,hot)
		if GCDCheck(SpellName) and LYStyle ~= "Utilities only" and func and (LYPlayerRole == "HEALER" or not HaveDebuff("player",PrMindGame)) then
			if LYPlayerRole ~= "HEALER" and LYDPSSelfHeal then
				if CalculateHP("player") < hp and (not hot or not HaveBuff("player",SpellName,hot,"player")) then
					LYQueueSpell(SpellName,"player")
					return true
				end
				return
			end
			for i=1,#LYTeamPlayers do
				if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < hp and (not hot or (CanHoTSafe(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],SpellName,hot,"player"))) then
					LYQueueSpell(SpellName,LYTeamPlayers[i])
					return true
				end
			end
		end
	end
	function AOEHeal(SpellName,dist,HP,count,func,face)
		if GCDCheck(SpellName) and LYStyle == "All units" and UnitAffectingCombat("player") and count ~= 0 and func and ((LYMode == "PvP" and not PartyHPBelow(50)) or (LYMode ~= "PvP" and not PartyHPBelow(25)) or C_Spell.GetSpellInfo(SpellName).castTime == 0) then
			for i=1,#LYTeamPlayers do
				if ValidFriendUnit(LYTeamPlayers[i]) and (LYMode ~= "PvE" or UnitIsTank(LYTeamPlayers[i])) and TeamMembersAroundUnit(dist,LYTeamPlayers[i],HP,nil,face) >= count then
					LYQueueSpell(SpellName,LYTeamPlayers[i])
					return true
				end
			end
		end
	end
	function AutoBuffParty(SpellName)
		if LYAutoBuff and GCDCheck(SpellName) and not EnemyHPBelow(90) then
			local myfac = UnitFactionGroup("player")
			for i=1,#LYTeamPlayers do
				if ValidFriendUnit(LYTeamPlayers[i]) and UnitIsPlayer(LYTeamPlayers[i]) and (LYMode == "PvP" or myfac == UnitFactionGroup(LYTeamPlayers[i])) and (UnitInRaid(LYTeamPlayers[i]) or UnitInParty(LYTeamPlayers[i]) or UnitIsUnit("player",LYTeamPlayers[i])) and not HaveBuff(LYTeamPlayers[i],SpellName) then
					LYQueueSpell(SpellName,"player")
					return true
				end
			end
		end
	end
	function BreakCCMG(SpellName,func)
		if GCDCheck(SpellName) and func and LYStyle ~= "Utilities only" and HaveDebuff("player",PrMindGame) then
			for i=1,#LYTeamHealersAll do
				if UnitIsVisible(LYTeamHealersAll[i]) and HaveBuff(LYTeamHealersAll[i],LYListBreakableCC,3) and UnitInRange(LYTeamHealersAll[i]) and InLineOfSight(LYTeamHealersAll[i]) then
					LYQueueSpell(SpellName,LYTeamHealersAll[i])
					return true
				end
			end
		end
	end
	function TripleCC(SpellName,func,dist)
		if CDCheck(SpellName) and LYMode ~= "PvE" and func then
			local check = 0
			local unit
			for i=1,#LYEnemies do
				if IsInDistance(LYEnemies[i],dist)and UnitIsPlayer(LYEnemies[i]) and not UnitIsCCed(LYEnemies[i]) and not HaveDebuff(LYEnemies[i],WrSpearBast) then
					unit = LYEnemies[i]
					check = check + 1
				end
			end
			if check > 2 then
				LYSpellStopCasting()
				LYQueueSpell(SpellName,unit)
				return true
			end
		end
	end
	function AntiStealth(SpellName)
		if GCDCheck(SpellName) and LYMode ~= "PvE" then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and inRange(SpellName,LYEnemies[i]) and (HaveBuff(LYEnemies[i],listStealth) or (not UnitAffectingCombat(LYEnemies[i]) and (select(2,UnitClass(LYEnemies[i])) == "ROGUE"))) then
					LYQueueSpell(SpellName,LYEnemies[i],"face")
					LY_Print("Catch stealth unit","green")
					return true
				end
			end
			for i=1,#LYEnemyHealers do
				if ValidEnemyUnit(LYEnemyHealers[i]) and inRange(SpellName,LYEnemyHealers[i]) and HaveBuff(LYEnemyHealers[i],DrinkMana) then
					LYQueueSpell(SpellName,LYEnemyHealers[i])
					return true
				end
			end
		end
	end
	function TotemStomp(melee,rdps,range)
		local function KillTotem(totem)
			if melee and #melee > 0 and IsInDistance(totem,5) then
				for i=1,#melee do
					if GCDCheck(melee[i]) and UnitCanCastOnMove(melee[i]) then
						LYQueueSpell(melee[i],totem,"face")
						LY_Print("TotemStomp "..UnitName(totem),"green",melee[i])
						return true
					end
				end
			end
			if rdps and #rdps > 0 and IsInDistance(totem,range) then
				for i=1,#rdps do
					if GCDCheck(rdps[i]) and UnitCanCastOnMove(rdps[i]) and (rdps[i] ~= WrThrow or not IsInDistance(totem,8)) then
						LYQueueSpell(rdps[i],totem,"face")
						LY_Print("TotemStomp "..UnitName(totem),"green", rdps[i])
						return true
					end
				end
			end
		end
		if IsGCDReady() and LYMode ~= "PvE" and (LYReaction == 0 or GetTime() - LYTotemTime > LYReaction/1000) then
			for i=1,#LYEnemyTotems do
				if UnitIsVisible(LYEnemyTotems[i]) and not UnitIsDeadOrGhost(LYEnemyTotems[i]) and UnitHealth(LYEnemyTotems[i]) ~= 0 and UnitHealth(LYEnemyTotems[i]) ~= 1 and IsInDistance(LYEnemyTotems[i],40) and KillTotem(LYEnemyTotems[i]) then
					return true
				end
			end
		end
	end
	function ConnecTarget(SpellName,burst,hp)
		if GCDCheck(SpellName) and ValidEnemyUnit(LYEnemyTarget) and inRange(SpellName,LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and ((burst and IsBursting()) or CalculateHP(LYEnemyTarget) < hp) and not IsInDistance(LYEnemyTarget,10) and LYFacingCheck(LYEnemyTarget) then
			LYQueueSpell(SpellName,LYEnemyTarget)
			return true
		end
	end
	function PurgeForce(SpellName)
		if GCDCheck(SpellName) and ValidEnemyUnit(ForcePurge) and SpellAttackTypeCheck(ForcePurge,"magic") and inRange(SpellName,ForcePurge) and NumberOfPurgeBuffs(ForcePurge) ~= 0 then
			LYQueueSpell(SpellName,ForcePurge)
			return true
		end
	end
	function PurgeEssential(SpellName)
		local function PurgeCheck(pointer)
			local burst = IsBursting()
			for i=1,40 do
				local tBuff = C_UnitAuras.GetBuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if tContains(LYPurgeList,tBuff.name) and (not burst or tContains(listPurgeAlways,tBuff.name)) and (tBuff.expirationTime == 0 or (tBuff.expirationTime - GetTime() > 3 and (LYReaction == 0 or tBuff.expirationTime - GetTime() < tBuff.duration - LYReaction/1000))) then
						return tBuff.name
					end
				else
					return
				end
			end
		end
		if GCDCheck(SpellName) then
			if LYZoneType == "arena" and LYMyClass ~= 8 and LYMyClass ~= 12 then
				local pointer = nil
				for i=1,2 do
					pointer = "party"..i
					if UnitIsVisible(pointer) and UnitIsCharmed(pointer) and inRange(SpellName,pointer) and InLineOfSight(pointer) then
						LYQueueSpell(SpellName,pointer)
						LY_Print("Purge MC", "green", SpellName)
						return true
					end
				end
			end
			if LYMyClass ~= 2 and LYPlayerRole ~= "HEALER" or not PartyHPBelow(LYPurgeHP) or IsMoving() then
				for i=1,#LYEnemies do
					local purgeSpell = PurgeCheck(LYEnemies[i])
					if UnitIsVisible(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and inRange(SpellName,LYEnemies[i]) and purgeSpell then
						LYQueueSpell(SpellName,LYEnemies[i])
						LY_Print("Purging " .. purgeSpell,"green",SpellName)
						return true
					end
				end
			end
		end
	end
	function PurgePassive(SpellName)
		if GCDCheck(SpellName) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and (LYPlayerRole ~= "HEALER" or CalculateMP("player") > LYPurgeMana or LYHDPS or TeamIsBursting() or EnemyHPBelow(30)) then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and UnitIsPlayer(LYEnemies[i]) and inRange(SpellName,LYEnemies[i]) and NumberOfPurgeBuffs(LYEnemies[i]) ~= 0 then
					LYQueueSpell(SpellName,LYEnemies[i])
					return true
				end
			end
		end
	end
	function PurgeEnrage(SpellName,func)
		if GCDCheck(SpellName) and LYStyle ~= "Utilities only" and func then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and inRange(SpellName,LYEnemies[i]) and NumberOfPurgeBuffs(LYEnemies[i]) > 0 then
					LYQueueSpell(SpellName,LYEnemies[i])
					return true
				end
			end
		end
	end
	function AntiReflect(SpellName)
		if CDCheck(SpellName) and LYMode ~= "PvE" and HaveBuff(LYCurrentSpellTarget,23920) then
			LYSpellStopCasting()
			LY_Print("Anti-Reflect", "green", SpellName)
			LYQueueSpell(SpellName,LYCurrentSpellTarget)
			return true
		end
	end
	function DefensiveOnPlayer(SpellName,role,HP,Burst,Healer,func)
		if GCDCheck(SpellName) and UnitAffectingCombat("player") and not HaveBuff("player",SpellName) and (LYStackDef or not HaveBuff("player",listDef)) and func and (not Healer or not TeamHealerCanInteract()) and FriendIsUnderAttack("player",role,HP,Burst) then
			LYSpellStopCasting()
			LYQueueSpell(SpellName)
			LY_Print(SpellName.." @player","green",SpellName)
			return true
		end
	end
	function DefensiveOnTeam(SpellName,role,HP,Burst,dist,func)
		if GCDCheck(SpellName) and func then
			for i=1,#LYTeamPlayers do
				if UnitIsVisible(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],SpellName) and (not dist or IsInDistance(LYTeamPlayers[i],dist)) and (LYMode ~= "PvE" or UnitIsTank(LYTeamPlayers[i]) or CheckRole(LYTeamPlayers[i]) == "HEALER") and FriendIsUnderAttack(LYTeamPlayers[i],role,HP,Burst) and (LYStackDef or not HaveBuff(LYTeamPlayers[i],listDef)) then
					LYSpellStopCasting()
					LYQueueSpell(SpellName,LYTeamPlayers[i])
					LY_Print(SpellName.." @teammate","green",SpellName)
					return true
				end
			end
		end
	end
	function DefensiveOnEnemy(SpellName,role,typedmg,HP,Burst,dist,func)
		if GCDCheck(SpellName) and func then
			for i=1,#LYTeamPlayers do
				local enemy = FriendIsUnderAttack(LYTeamPlayers[i],role,HP,Burst)
				if UnitIsVisible(enemy) and SpellAttackTypeCheck(enemy,typedmg) and (inRange(SpellName,enemy) or (dist and IsInDistance(enemy,dist))) and (not tContains(listDisarm,SpellName) or (select(2,UnitClass(enemy)) ~= "DRUID" and not HaveBuff(enemy,WrBS))) and not HaveDebuff(enemy,SpellName) and LYFacingCheck(enemy) then
					LYSpellStopCasting()
					LYQueueSpell(SpellName,enemy)
					LY_Print(SpellName.." @enemy","green",SpellName)
					return true
				end
			end
		end
	end
	function PlayerDefensiveOnEnemy(SpellName,role,typedmg,HP,Burst,dist,func)
		if GCDCheck(SpellName) and func then
			local enemy = FriendIsUnderAttack("player",role,HP,Burst)
			if UnitIsVisible(enemy) and SpellAttackTypeCheck(enemy,typedmg) and (inRange(SpellName,enemy) or (dist and IsInDistance(enemy,dist))) and not HaveDebuff(enemy,SpellName) then
				LYSpellStopCasting()
				LYQueueSpell(SpellName,enemy,"face")
				LY_Print(SpellName.." @enemy","green",SpellName)
				return true
			end
		end
	end
	function Disarm(SpellName,HP,Burst,Healer,Focus,dist)
		if GCDCheck(SpellName) then
			local hp = PartyHPBelow(HP)
			local noheal = Healer and TeamHealerCCed(6)
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and (not Focus or (UnitIsVisible("focus") and UnitIsUnit("focus",LYEnemies[i]))) and SpellAttackTypeCheck(LYEnemies[i],"phys") and (inRange(SpellName,LYEnemies[i]) or (dist and IsInDistance(LYEnemies[i],dist))) and not HaveBuff(LYEnemies[i],{WrBS,WrDbS}) and ((Burst and IsBursting(LYEnemies[i])) or hp or noheal) and not UnitIsCCed(LYEnemies[i]) then
					local class = select(2,UnitClass(LYEnemies[i]))
					if (CheckRole(LYEnemies[i]) == "MELEE" or class == "HUNTER") and class ~= "PALADIN" and class ~= "SHAMAN" and class ~= "DRUID" and class ~= "DEMONHUNTER" and class ~= "MONK" and LYFacingCheck(LYEnemies[i]) then
						LYQueueSpell(SpellName,LYEnemies[i])
						LY_Print(SpellName,"green")
						return true
					end
				end
			end
		end
	end
	function FreedomCast(SpellName,heal,hp,sec,dps,func)
		if GCDCheck(SpellName) and func then
			if LYMode == "PvE" then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and HaveDebuff(LYTeamPlayers[i],listPvERoots,sec) and (SpellName ~= PlFreedom or not HaveBuff(LYTeamPlayers[i],{PlBoP,PlSac})) and (inRange(SpellName,LYTeamPlayers[i]) or (SpellName == HnFreedom and IsInDistance("pet",40,LYTeamPlayers[i]) and InLineOfSight("pet",LYTeamPlayers[i]))) then
						LYQueueSpell(SpellName,LYTeamPlayers[i])
						LY_Print(SpellName.." @teammate","green",SpellName)
						return true
					end
				end
			else
				local druid = EnemyClassExists("DRUID")
				if druid and GetSpecByDescriptor(druid) == 102 and SpellIsReady(druid,DrSolar,35) then
					druid = true
				else
					druid = nil
				end
				for i=1,#LYTeamHealers do
					if UnitIsVisible(LYTeamHealers[i]) and ((IsRooted(LYTeamHealers[i]) and HaveDebuff(LYTeamHealers[i],DrSolar)) or (not druid and CalculateHP(LYTeamHealers[i]) < heal and HaveDebuff(LYTeamHealers[i],listSlows) and FriendIsUnderAttack(LYTeamHealers[i]) and IsMoving(LYTeamHealers[i]) and not UnitIsCCed(LYTeamHealers[i]) and (SpellName ~= PlFreedom or not HaveBuff(LYTeamHealers[i],{PlBoP,PlSac})))) and (inRange(SpellName,LYTeamHealers[i]) or (SpellName == HnFreedom and not UnitIsCCed("pet") and IsInDistance("pet",40,LYTeamHealers[i]) and InLineOfSight("pet",LYTeamHealers[i]))) then
						LYQueueSpell(SpellName,LYTeamHealers[i])
						LY_Print(SpellName.." @team healer","green",SpellName)
						return true
					end
				end
				if dps and not druid then
					for i=1,#LYTeamPlayers do
						if CheckRole(LYTeamPlayers[i]) == "MELEE" and select(2,UnitClass(LYTeamPlayers[i])) ~= "DRUID" and (SpellName ~= PlFreedom or not HaveBuff(LYTeamPlayers[i],{PlBoP,PlSac})) and not UnitIsCCed(LYTeamPlayers[i]) and (inRange(SpellName,LYTeamPlayers[i]) or (SpellName == HnFreedom and not UnitIsCCed("pet") and IsInDistance("pet",40,LYTeamPlayers[i]) and InLineOfSight("pet",LYTeamPlayers[i]))) then
							local target = UnitTarget(LYTeamPlayers[i])
							if UnitIsVisible(target) and UnitCanAttack(LYTeamPlayers[i],target) and ((CalculateHP(target) < hp and HaveDebuff(LYTeamPlayers[i],listSlows)) or IsRooted(LYTeamPlayers[i],sec)) and not IsInDistance(LYTeamPlayers[i],5,target) then
								LYQueueSpell(SpellName,LYTeamPlayers[i])
								LY_Print(SpellName.." @DPS teammate","green",SpellName)
								return true
							end
						end
					end
				elseif not druid and UnitIsVisible(LYEnemyTarget) and (SpellName ~= PlFreedom or not HaveBuff("player",{PlBoP,PlSac})) and ((CalculateHP(LYEnemyTarget) < hp and HaveDebuff("player",listSlows)) or IsRooted("player",sec)) and not IsInDistance(LYEnemyTarget,5) and (SpellName ~= HnFreedom or (not UnitIsCCed("pet") and IsInDistance("pet",40,"player") and InLineOfSight("pet","player"))) then
					LYQueueSpell(SpellName,"player")
					LY_Print(SpellName.." @player","green",SpellName)
					return true
				end
			end
		end
	end
	function SlowTarget(SpellName,dmgtype,dist,always)
		local function ObjectIsChasing(Object1,Object2)
			local Object1X,Object1Y = ObjectPosition(Object1)
			local Object2X,Object2Y = ObjectPosition(Object2)
			local Object1Facing = ObjectFacing(Object1)
			local Object2Facing = ObjectFacing(Object2)
			if Object1X and Object2X then
				local facing1 = ((Object1X - Object2X) * math.cos(-Object1Facing)) - ((Object1Y - Object2Y) * math.sin(-Object1Facing))
				local facing2 = ((Object2X - Object1X) * math.cos(-Object2Facing)) - ((Object2Y - Object1Y) * math.sin(-Object2Facing))
				return facing1 < 0 and facing2 > 0
			end
		end
		if GCDCheck(SpellName) and LYMode ~= "PvE" and ValidEnemyUnit(LYEnemyTarget) and (LYMyClass ~= 9 or not HaveDebuff(LYEnemyTarget,listWlCurses,2,"player")) and UnitIsPlayer(LYEnemyTarget) and (inRange(SpellName,LYEnemyTarget) or (dist and IsInDistance(LYEnemyTarget,dist))) and (not dmgtype or SpellAttackTypeCheck(LYEnemyTarget,dmgtype)) and not HaveDebuff(LYEnemyTarget,listSlows,LYGCDTime) and not HaveBuff(LYEnemyTarget,listISlows) and not UnitIsCCed(LYEnemyTarget) and (always or (LYSlowTarget and (IsBursting(LYEnemyTarget) or ObjectIsChasing("player",LYEnemyTarget) or ObjectIsChasing(LYEnemyTarget,"player")))) and LYFacingCheck(LYEnemyTarget) then
			LY_Print("Slowing enemy","green",SpellName)
			LYQueueSpell(SpellName,LYEnemyTarget)
			return true
		end
	end
	function Peel(SpellName,dmgtype,team,healer,dist)
		if not hp then hp = 100 end
		if GCDCheck(SpellName) and LYMode == "PvP" and not LYHDPS and not IsBursting() then
			local checkTable = LYTeamPlayers
			if not team and healer then
				checkTable = LYTeamHealers
			elseif not team and not healer then
				return
			end
			for i=1,#checkTable do
				local enemy = FriendIsUnderAttack(checkTable[i],"MELEE")
				if UnitIsVisible(enemy) and (LYMyClass ~= 9 or not HaveDebuff(enemy,WlCurWeak,2,"player")) and (inRange(SpellName,enemy) or (dist and IsInDistance(enemy,dist))) and (not dmgtype or SpellAttackTypeCheck(enemy,dmgtype)) and not HaveBuff(enemy,listISlows) and not IsRooted(enemy) and not HaveDebuff(enemy,listSlows) and LYFacingCheck(enemy) then
					LY_Print("Peeling teammate/self","green",SpellName)
					LYQueueSpell(SpellName,enemy)
					return true
				end
			end
		end
	end
	function StunCC(SpellName,typedmg,DR,Healer,HealerHP,TeamBurst,DPS,DPSHP,DPSBurst,Cont,Focus,dist)
		local function UnitIsCCable(pointer,cont)
			if cont then
				DR = 0
			end
			if UnitIsVisible(pointer) and UnitIsPlayer(pointer) and (not typedmg or SpellAttackTypeCheck(pointer,typedmg)) and (inRange(SpellName,pointer) or (dist and IsInDistance(pointer,dist))) and not HaveBuff(pointer,listICC) and CheckUnitDR(pointer,"stun",DR) and not UnitIsKicked(pointer) and not UnitIsCCed(pointer,LYGCDTime) and (not cont or UnitIsCCed(pointer,LYGCDTime*2,true)) and not HaveDebuff(pointer,listDisarm) and LYFacingCheck(pointer) then
				if SpellName == HnIntimid then
					if not UnitIsVisible("pet") or UnitIsDeadOrGhost("pet") or UnitIsCCed("pet") then
						return
					end
					PetAttack(pointer)
					PetBehTimer = GetTime() + 3
				end
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) then
						local castCC = UnitCastingInfo(LYTeamPlayers[i])
						if castCC and tContains(listCCInt,castCC) then
							local ccUnit = GetSpellDestUnit(LYTeamPlayers[i])
							if UnitIsVisible(ccUnit) and UnitIsUnit(ccUnit,pointer) then
								return
							end
						end
					end
				end
				return true
			end
		end
		if CDCheck(SpellName) and LYMode ~= "PvE" and UnitCanCastOnMove(SpellName) then
			if Healer and (EnemyHPBelow(HealerHP) or (TeamBurst and TeamIsBursting())) then
				for i=1,#LYEnemyHealers do
					if UnitIsCCable(LYEnemyHealers[i]) then
						LYSpellStopCasting()
						LYQueueSpell(SpellName,LYEnemyHealers[i])
						LY_Print("Stun ".." @enemy healer","green",SpellName)
						return true
					end
				end
			end
			if DPS and not AnyEnemyDPSCCed() then
					for i=1,#LYTeamHealersAll do
					if UnitIsVisible(LYTeamHealersAll[i]) and UnitIsCCed(LYTeamHealersAll[i],4) then
						for j=1,#LYTeamPlayers do
							local enemy = FriendIsUnderAttack(LYTeamPlayers[j])
							if UnitIsVisible(enemy) and UnitIsCCable(enemy) then
								LYSpellStopCasting()
								LYQueueSpell(SpellName,enemy)
								LY_Print("Stun ".." @enemy DPS","green",SpellName)
								return true
							end
						end
					end
				end
				for i=1,#LYTeamPlayers do
					local enemy = FriendIsUnderAttack(LYTeamPlayers[i],nil,DPSHP,DPSBurst)
					if UnitIsVisible(enemy) and UnitIsCCable(enemy) then
						LYSpellStopCasting()
						LYQueueSpell(SpellName,enemy)
						LY_Print("Stun ".." @enemy DPS","green",SpellName)
						return true
					end
				end
			end
			if Cont then
				for i=1,#LYEnemyHealers do
					if UnitIsCCable(LYEnemyHealers[i],Cont) then
						LYSpellStopCasting()
						LYQueueSpell(SpellName,LYEnemyHealers[i])
						LY_Print("Chain CC","green",SpellName)
						return true
					end
				end
			end
			if Focus and UnitIsVisible("focus") and UnitIsCCable("focus") then
				LYSpellStopCasting()
				LYQueueSpell(SpellName,"focus")
				LY_Print("Stun".." @focus","green",SpellName)
				return true
			end
		end
	end
	function FearCC(SpellName,typedmg,DR,Healer,HealerHP,TeamBurst,DPS,DPSHP,DPSBurst,Cont,Focus,dot,dist,whileBurst)
		local timer = LYGCDTime
		if C_Spell.IsSpellUsable(SpellName) then
			timer = C_Spell.GetSpellInfo(SpellName).castTime/1000 + LYGCDTime
		end
		if AnyEnemyHasDebuff(SpellName,2) then
			return
		end
		local function UnitIsCCable(pointer,spell,cont)
			if cont then
				DR = 0
			end
			if UnitIsVisible(pointer) and UnitIsPlayer(pointer) and not EnemyIsUnderAttack(pointer) and (not UnitIsVisible(LYEnemyTarget) or not UnitIsUnit(LYEnemyTarget,pointer)) and (not typedmg or SpellAttackTypeCheck(pointer,typedmg)) and not HaveBuff(pointer,listICC) and (inRange(SpellName,pointer) or (dist and IsInDistance(pointer,dist))) and (SpellName ~= WlSeduction or not HaveBuff(pointer,listForms)) and CheckUnitDR(pointer,"fear",DR) and not UnitIsKicked(pointer) and not UnitIsCCed(pointer,timer) and (not cont or UnitIsCCed(pointer,timer*2,true)) and not HaveDebuff(pointer,listDisarm) and LYFacingCheck(pointer) then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) then
						local castCC = UnitCastingInfo(LYTeamPlayers[i])
						if castCC and tContains(listCCInt,castCC) then
							local ccUnit = GetSpellDestUnit(LYTeamPlayers[i])
							if UnitIsVisible(ccUnit) and UnitIsUnit(ccUnit,pointer) then
								return
							end
						end
					end
				end
				if not UnitCanCastOnMove(spell) then
					if LYAutoCCMoveStop then
						LY_Print("Force stopped moving to cast autoCC","red",spell)
						StopMoving(true)
					elseif LYAutoCCMoveWarn then
						LY_Print("Please stop moving to let it cast autoCC","red",spell)
						return
					end
				end
				return true
			end
		end
		if CDCheck(SpellName) and LYMode ~= "PvE" and (not IsBursting() or whileBurst) and (UnitCanCastOnMove(SpellName) or LYAutoCCMoveWarn or LYAutoCCMoveStop) and (not dot or not AnyEnemyHasDebuff(SpellName, timer)) then
			if Healer and (EnemyHPBelow(HealerHP) or (TeamBurst and TeamIsBursting())) then
				for i=1,#LYEnemyHealers do
					if UnitIsCCable(LYEnemyHealers[i],SpellName) then
						if SpellName == MgDB then
							if not MgBlinkDB(LYEnemyHealers[i]) then
								return
							end
						else
							LYSpellStopCasting()
							LYQueueSpell(SpellName,LYEnemyHealers[i])
						end
						LY_Print("FearCC ".." @enemy healer","green",SpellName)
						return true
					end
				end
			end
			if DPS and not AnyEnemyDPSCCed() then
				for i=1,#LYTeamHealersAll do
					if UnitIsVisible(LYTeamHealersAll[i]) and UnitIsCCed(LYTeamHealersAll[i],4) then
						for j=1,#LYTeamPlayers do
							local enemy = FriendIsUnderAttack(LYTeamPlayers[j])
							if UnitIsVisible(enemy) and UnitIsCCable(enemy,SpellName) then
								if SpellName == MgDB then
									if not MgBlinkDB(enemy) then
										return
									end
								else
									LYSpellStopCasting()
									LYQueueSpell(SpellName,enemy)
								end
								LY_Print("FearCC ".." @enemy DPS","green",SpellName)
								return true
							end
						end
					end
				end
				for i=1,#LYTeamPlayers do
					local enemy = FriendIsUnderAttack(LYTeamPlayers[i],nil,DPSHP,DPSBurst)
					if UnitIsVisible(enemy) and UnitIsCCable(enemy,SpellName) then
						if SpellName == MgDB then
							if not MgBlinkDB(enemy) then
								return
							end
						else
							LYSpellStopCasting()
							LYQueueSpell(SpellName,enemy)
						end
						LY_Print("FearCC ".." @enemy DPS","green",SpellName)
						return true
					end
				end
			end
			if Cont then
				for i=1,#LYEnemyHealers do
					if UnitIsCCable(LYEnemyHealers[i],SpellName,Cont) then
						if SpellName == MgDB then
							if not MgBlinkDB(LYEnemyHealers[i]) then
								return
							end
						else
							LYSpellStopCasting()
							LYQueueSpell(SpellName,LYEnemyHealers[i])
						end
						LY_Print("Chain CC","green",SpellName)
						return true
					end
				end
			end
			if Focus and UnitIsVisible("focus") and UnitIsCCable("focus",SpellName) then
				if SpellName == MgDB then
					if not MgBlinkDB("focus") then
						return
					end
				else
					LYSpellStopCasting()
					LYQueueSpell(SpellName,"focus")
				end
				LY_Print("FearCC".." @focus","green",SpellName)
				return true
			end
		end
	end
	function ControlCC(SpellName,typedmg,DR,Healer,HealerHP,TeamBurst,DPS,DPSHP,DPSBurst,Cont,Focus,dot,dist,whileBurst)
		local timer = LYGCDTime
		if C_Spell.IsSpellUsable(SpellName) then
			timer = C_Spell.GetSpellInfo(SpellName).castTime/1000 + LYGCDTime
		end
		if AnyEnemyHasDebuff(SpellName,2) then
			return
		end
		local function UnitIsCCable(pointer,spell,cont)
			if cont then
				DR = 0
			end
			if UnitIsVisible(pointer) and UnitIsPlayer(pointer) and not EnemyIsUnderAttack(pointer) and (not UnitIsVisible(LYEnemyTarget) or not UnitIsUnit(LYEnemyTarget,pointer)) and (not typedmg or SpellAttackTypeCheck(pointer,typedmg)) and (inRange(SpellName,pointer) or (dist and IsInDistance(pointer,dist))) and not HaveBuff(pointer,listICC) and not HaveDebuff(pointer, PlUltSac) and (not tContains(listShiftCC,SpellName) or not HaveBuff(pointer,listForms)) and CheckUnitDR(pointer,"control",DR) and (not UnitIsKicked(pointer) or tContains(listCastWhileKicked, SpellName)) and not UnitIsCCed(pointer,timer) and not HaveDebuff(pointer,listDisarm) and (not cont or UnitIsCCed(pointer,timer*2,true)) and (SpellName ~= HnTrap or not IsMoving(pointer)) and LYFacingCheck(pointer) then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) then
						local castCC = UnitCastingInfo(LYTeamPlayers[i])
						if castCC and tContains(listCCInt,castCC) then
							local ccUnit = GetSpellDestUnit(LYTeamPlayers[i])
							if UnitIsVisible(ccUnit) and UnitIsUnit(ccUnit,pointer) then
								return
							end
						end
					end
				end
				if not UnitCanCastOnMove(spell) then
					if LYAutoCCMoveStop then
						LY_Print("Force stopped moving to cast autoCC","red",spell)
						StopMoving(true)
					elseif LYAutoCCMoveWarn then
						LY_Print("Stop moving to cast autoCC","red",spell)
						return
					else
						return
					end
				end
				return true
			end
		end
		if GCDCheck(SpellName) and LYMode ~= "PvE" and (SpellName ~= PrMC or not PartyHPBelow(LYPrMCHP)) and (UnitCanCastOnMove(SpellName) or LYAutoCCMoveWarn or LYAutoCCMoveStop) and (not IsBursting() or whileBurst) and (not dot or not AnyEnemyHasDebuff(SpellName,timer)) then
			if Healer and (EnemyHPBelow(HealerHP) or (TeamBurst and TeamIsBursting())) then
				for i=1,#LYEnemyHealers do
					if UnitIsCCable(LYEnemyHealers[i],SpellName) then
						LYQueueSpell(SpellName,LYEnemyHealers[i])
						LY_Print("ContolCC ".." @enemy healer","green",SpellName)
						return true
					end
				end
			end
			if DPS and not AnyEnemyDPSCCed() then
				for i=1,#LYTeamHealersAll do
					if UnitIsVisible(LYTeamHealersAll[i]) and UnitIsCCed(LYTeamHealersAll[i],4) then
						for j=1,#LYTeamPlayers do
							local enemy = FriendIsUnderAttack(LYTeamPlayers[j])
							if UnitIsVisible(enemy) and UnitIsCCable(enemy,SpellName) then
								LYQueueSpell(SpellName,enemy)
								LY_Print("ControlCC ".." @enemy DPS","green",SpellName)
								return true
							end
						end
					end
				end
				for i=1,#LYTeamPlayers do
					local enemy = FriendIsUnderAttack(LYTeamPlayers[i],nil,DPSHP,DPSBurst)
					if UnitIsCCable(enemy,SpellName) then
						LYQueueSpell(SpellName,enemy)
						LY_Print("ControlCC ".." @enemy DPS","green",SpellName)
						return true
					end
				end
			end
			if Cont then
				for i=1,#LYEnemyHealers do
					if UnitIsCCable(LYEnemyHealers[i],SpellName,Cont) then
						LYQueueSpell(SpellName,LYEnemyHealers[i])
						LY_Print("Chain CC","green",SpellName)
						return true
					end
				end
			end
			if Focus and UnitIsCCable("focus",SpellName) then
				LYQueueSpell(SpellName,"focus")
				LY_Print("ControlCC ".." @focus","green",SpellName)
				return true
			end
		end
	end
	function PetBehaviour()
		if UnitIsVisible("pet") and LYZoneType == "arena" and not UnitIsDeadOrGhost("pet") and not UnitIsCCed("pet") and GetTime() > PetBehTimer + 0.5 and #LYSpellQueue == 0 then
			local NearbyTotem = TotemsAroundPet(20)
			local PetTar = UnitTarget("pet")
			PetBehTimer = GetTime()
			if NearbyTotem then
				if not UnitIsVisible(PetTar) or not UnitIsUnit(NearbyTotem,PetTar) then
					PetAttack(NearbyTotem)
					LY_Print("Send pet to kill "..UnitName(NearbyTotem),"green")
				end
				return
			end
			if CalculateHP("pet") < 35 and FriendIsUnderAttack("pet") and not IsInDistance("pet",10) then
				PetFollow()
				return
			end
			if UnitIsVisible(PetTar) and HaveDebuff(PetTar,LYListBreakableCC) then
				PetStopAttack()
				return
			end
			if LYZoneType == "arena" and UnitIsVisible(LYEnemyHealer) and UnitAffectingCombat("player") and not HaveBuff("player",HnCoordAttack) and LYPetOnHealer and (not UnitIsVisible(PetTar) or not UnitIsUnit(LYEnemyHealer,PetTar)) then
				PetAttack(LYEnemyHealer)
				return
			end
			if UnitIsVisible(LYEnemyTarget) and (not UnitIsVisible(PetTar) or not UnitIsUnit(PetTar,LYEnemyTarget)) and UnitAffectingCombat(LYEnemyTarget) and UnitAffectingCombat("player") then
				PetAttack(LYEnemyTarget)
				return
			end
			if UnitIsCCed("player") then
				local enemy = FriendIsUnderAttack("player")
				if ValidEnemyUnit(enemy) then
					PetAttack(enemy)
				end
			end
		end
	end
	function Taunt(SpellName)
		if GCDCheck(SpellName) and (LYZoneType == "party" or LYZoneType == "scenario") then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) then
					local threat = UnitThreatSituation("player",LYEnemies[i])
					if threat and threat < 2 then
						CastSpellByName(SpellName,LYEnemies[i])
						return true
					end
				end
			end
		end
	end
	function TauntCC(SpellName,trap)
		local function taunt(SpellName)
			local pointer
			for j=1,3 do
				pointer = "arenapet"..j
				if UnitIsVisible(pointer) and inRange(SpellName,pointer) and InLineOfSight(pointer) then
					SpellStopCasting()
					CastSpellByName(SpellName,pointer)
					LY_Print(SpellName.." CC","green",SpellName)
					return true
				end
			end
		end
		if GCDCheck(SpellName) and LYZoneType == "arena" then
			if trap then
				taunt(SpellName)
			else
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
						local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
						if castName and tContains(listSWDCC,castName) and PlayerIsSpellTarget(LYEnemies[i]) then
							taunt(SpellName)
						end
					end
				end
			end
		end
	end
	function TauntPvP(SpellName,TalentID)
		if GCDCheck(SpellName) and LYMode ~= "PvE" and IsPvPTalentInUse(TalentID) then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"phys") and inRange(SpellName,LYEnemies[i]) and EnemyIsUnderAttack(LYEnemies[i]) and not HaveDebuff(LYEnemies[i],SpellName) then
					CastSpellByName(SpellName,LYEnemies[i])
					return true
				end
			end
		end
	end
	function UpdateDoTs(SpellName)
		if GCDCheck(SpellName) and LYStyle ~= "Utilities only" and IsMoving() then
			local CurrentDoT = nil
			local CurrentTime = nil
			local PriorityTime = 0
			local PriorityDoT = nil
			local PriorityUnit = nil
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and inRange(SpellName,LYEnemies[i]) then
					local D1Time,D2Time,D3Time
					if LYMyClass == 9 then
						if DebuffCount(LYEnemies[i],WlAgony) < 10 or (IsTalentInUse(196102) and DebuffCount(LYEnemies[i],WlAgony) < 18) then
							LYQueueSpell(WlAgony,LYEnemies[i])
							return true
						end
						D1Time = DebuffTimeLeft(LYEnemies[i],WlAgony)
						D2Time = DebuffTimeLeft(LYEnemies[i],WlCorrupt)
						if D1Time ~= 100 and D2Time ~= 100 then
							if D1Time < D2Time then
								CurrentDoT = WlAgony
								CurrentTime = D1Time
							else
								CurrentDoT = WlCorrupt
								CurrentTime = D2Time
							end
						end
					end
					if LYMyClass == 11 then
						D1Time = DebuffTimeLeft(LYEnemies[i],DrMF)
						D2Time = DebuffTimeLeft(LYEnemies[i],DrSF)
						if D1Time ~= 100 and D2Time ~= 100 then
							if D1Time < D2Time then
								CurrentDoT = DrMF
								CurrentTime = D1Time
							elseif not BreakCCAroundUnit(LYEnemies[i],9) then
								CurrentDoT = DrSF
								CurrentTime = D2Time
							end
						end
					end
					if LYMyClass == 5 or LYMyClass == 7 then
						D1Time = DebuffTimeLeft(LYEnemies[i],SpellName)
						if D1Time ~= 100 then
							CurrentDoT = SpellName
							CurrentTime = D1Time
						end
					end
					if CurrentDoT and (not PriorityDoT or CurrentTime < PriorityTime) then
						PriorityDoT = CurrentDoT
						PriorityTime = CurrentTime
						PriorityUnit = LYEnemies[i]
					end
				end
			end
			if PriorityUnit and CalculateMP("player") > 30 then
				LYQueueSpell(PriorityDoT,PriorityUnit)
				return true
			end
		end
	end
	function ResDeadFriend()
		if GCDCheck(ResSpell) and not UnitAffectingCombat("player") and not IsMoving() and LYMode ~= "PvP" then
			for i=1,#LYTeamPlayersDead do
				if UnitIsVisible(LYTeamPlayersDead[i]) and InLineOfSight(LYTeamPlayersDead[i]) then
					LYQueueSpell(ResSpell,LYTeamPlayersDead[i])
					PauseGCD = GetTime() + 12
					return true
				end
			end
		end
	end
	function BRDeadFriend()
		if LYBattleRes and GCDCheck(BRSpell) and UnitAffectingCombat("player") and not IsMoving() and LYMode ~= "PvP" and LYLastSpellName ~= BRSpell then
			for i=1,#LYTeamPlayersDead do
				if UnitIsVisible(LYTeamPlayersDead[i]) and (UnitIsTank(LYTeamPlayersDead[i]) or CheckRole(LYTeamPlayersDead[i]) == "HEALER") then
					LYQueueSpell(BRSpell,LYTeamPlayersDead[i])
					return true
				end
			end
		end
	end
	function LYReflect(SpellName,setting)
		if GCDCheck(SpellName) and LYKickPause == 0 and setting then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
					local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(LYEnemies[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						castInterruptable = channelInterruptable
						modified = true
					end
					if castName and (tContains(LYReflectAlways,castName) or tContains(listRefl,castName)) and CheckUnitDRSpell("player",castName,1) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if (currentPercent > 90 and currentPercent < 97 and PlayerIsSpellTarget(LYEnemies[i])) or (modified and IsInDistance(LYEnemies[i],30)) then
							LYSpellStopCasting()
							LYQueueSpell(SpellName)
							LYKickPause = GetTime()
							LY_Print(SpellName.." "..castName,"green",SpellName)
							return true
						end
					end
				end
			end
		end
	end
	function CommonKick(SpellName,typedmg,typeKick,setting,dist)
		if CDCheck(SpellName) and not LYKickStop and LYKickPause == 0 and setting then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
					local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(LYEnemies[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						castInterruptable = channelInterruptable
						modified = true
					end
					if castName and ((typeKick == "kick" and not castInterruptable) or (typeKick == "move" and not UnitCanCastOnMove(castName,LYEnemies[i])) or (typeKick == "alt" and (LYMode == "PvE" or CheckUnitDRSpell(LYEnemies[i],SpellName)))) and (inRange(SpellName,LYEnemies[i]) or (dist and IsInDistance(LYEnemies[i],dist))) and (not typedmg or SpellAttackTypeCheck(LYEnemies[i],typedmg)) and ValidKick(LYEnemies[i],castName) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						local castTimeLeft = (castTime - timeSinceStart) / 1000
						if (currentPercent > KickTime - 5 or (modified and timeSinceStart > KickDelayFixed)) and castTime > LYKickMin and currentPercent < 95 then
							if castNameP then
								local timeFromStartP = (GetTime() * 1000 - castStartP) + (NetStats3 + NetStats4) / 2
								local castTimeLeftP = (castTimeTotalP - timeFromStartP) / 1000
								if castTimeLeftP + 0.3 < castTimeLeft then
									return
								end
							end
							if not tContains(listCharges,SpellName) then
								LYKickPause = GetTime()
							end
							LYSpellStopCasting()
							if SpellName == MgDB then
								if not MgBlinkDB(LYEnemies[i]) then
									return
								end
							else
								LYQueueSpell(SpellName,LYEnemies[i],"face")
							end
							LY_Print("Kick -> "..castName,"green",SpellName)
							return true
						end
					end
				end
			end
		end
	end
	function CastKick(SpellName,func,DR)
		if UnitCastingInfo("player") == SpellName and LYCastToKick then
			local continue = nil
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and castName == LYCastToKick then
						continue = true
						break
					end
				end
			end
			if not continue then
				LYSpellStopCasting()
			end
		end
		if func and CDCheck(SpellName) and not IsMoving() and LYKickPause == 0 and UnitCastingInfo("player") ~= SpellName then
			local timer = C_Spell.GetSpellInfo(SpellName).castTime
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and inRange(SpellName,LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and (tContains(listCCInt,castName) or (LYMode == "PvE" and tContains(LYListKickPvE,castName))) and CheckUnitDR(LYEnemies[i],DR,2) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local castTimeLeft = castTime - timeSinceStart
						if (castName ~= MgGrPyro or castTimeLeft < timer + 250) and timer < castTimeLeft + 50 then
							LYSpellStopCasting()
							LYQueueSpell(SpellName,LYEnemies[i])
							LY_Print(SpellName.." to kick -> "..castName,"green",SpellName)
							LYKickPause = GetTime()
							LYCastToKick = castName
							return true
						end
					end
				end
			end
		end
	end
	function LYDispelMyType(pointer,list,count)
		local c = 0
		for i=1,40 do
			local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
			if tBuff and tBuff.name then
				if (not list or tContains(list,tBuff.name)) and tBuff.dispelName and tContains(listDispelTypes,tBuff.dispelName) and (tBuff.expirationTime == 0 or tBuff.expirationTime - GetTime() > 2) then
					if count then
						c = c + 1
					else
						return true
					end
				end
			elseif count then
				return c
			else
				return
			end
		end
	end
	function LYDispelAlwaysF(SpellName)
		if GCDCheck(SpellName) then
			for i=1,#LYTeamPlayers do
				if UnitIsVisible(LYTeamPlayers[i]) and ((LYMode == "PvE" and LYDispelMyType(LYTeamPlayers[i],LYDispelPvE)) or (LYMode ~= "PvE" and LYDispelMyType(LYTeamPlayers[i],LYListDispelPvP))) and inRange(SpellName,LYTeamPlayers[i]) and (LYPlayerRole ~= "HEALER" or not HaveDebuff(LYTeamPlayers[i],LYListDoNotDispel)) then
					LYQueueSpell(SpellName,LYTeamPlayers[i])
					LY_Print(SpellName,"green",SpellName)
					return true
				end
			end
		end
	end
	function LYDispelAllF(SpellName)
		if GCDCheck(SpellName) and LYDispelDPSSet then
			for i=1,#LYTeamPlayers do
				if UnitIsVisible(LYTeamPlayers[i]) and inRange(SpellName,LYTeamPlayers[i]) and (not LYDPSSelfHeal or UnitIsUnit(LYTeamPlayers[i],"player")) and LYDispelMyType(LYTeamPlayers[i]) then
					LYQueueSpell(SpellName,LYTeamPlayers[i])
					return true
				end
			end
		end
	end
	function LYDispel(SpellName)
		local function DispelCCUnit(pointer)
			for i=1,40 do
				local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if (tContains(listDispelCC,tBuff.name) or tContains(listDispelIDs,tBuff.spellId) or (tContains(listDispelFear,tBuff.name) and not HaveDebuff(pointer,listDoTs)) or (tBuff.name == ShHex and (LYMyClass == 7 or LYMyClass == 11))) and tBuff.expirationTime - GetTime() > LYDispelCC and (LYReaction == 0 or tBuff.expirationTime - GetTime() < tBuff.duration - LYReaction/1000) then
						return true
					end
				else
					return
				end
			end
		end
		local function DispelStunUnit(pointer)
			for i=1,40 do
				local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
				if tBuff and tBuff.name then
					if (tContains(listDispelStun,tBuff.name) or tBuff.spellId == 117526 or tBuff.spellId == 287254) and tBuff.expirationTime - GetTime() > LYDispelCC and (LYReaction == 0 or tBuff.expirationTime - GetTime() < tBuff.duration - LYReaction/1000) then
						return true
					end
				else
					return
				end
			end
		end
		local function DispelRootUnit(pointer)
			if CheckRole(pointer) == "MELEE" and select(2,UnitClass(pointer)) ~= "DRUID" and not HaveDebuff(pointer,{WlUnstable,PrVTouch}) and not GCDCheck(PlFreedom) then
				for i=1,40 do
					local tBuff = C_UnitAuras.GetDebuffDataByIndex(pointer,i)
					if tBuff and tBuff.name then
						if tContains(listDispelRoots,tBuff.name) and tBuff.expirationTime - GetTime() > LYDispelRoot and (LYReaction == 0 or tBuff.expirationTime - GetTime() < tBuff.duration - LYReaction/1000) then
							return true
						end
					else
						return
					end
				end
			end
			if UnitIsUnit(pointer,"player") and HaveDebuff("player",listDispelRoots) then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
						local castName = UnitCastingInfo(LYEnemies[i])
						if castName and tContains(listSWDCC,castName) and PlayerIsSpellTarget(LYEnemies[i]) then
							return true
						end
					end
				end
			end
		end
		if LYDispelAlwaysF(SpellName) then
			return true
		end
		if CDCheck(SpellName) and LYMode == "PvP" and not PartyHPBelow(LYDispelHP) then
			local cced = {}
			for i=1,#LYTeamHealers do
				if UnitIsVisible(LYTeamHealers[i]) and inRange(SpellName,LYTeamHealers[i]) and not HaveDebuff(LYTeamHealers[i],LYListDoNotDispel) and (DispelStunUnit(LYTeamHealers[i]) or DispelCCUnit(LYTeamHealers[i])) then
					LYSpellStopCasting()
					LYQueueSpell(SpellName,LYTeamHealers[i])
					LY_Print(SpellName.." @team healer","green",SpellName)
					return true
				end
			end
			for i=1,#LYTeamPlayers do
				if UnitIsVisible(LYTeamPlayers[i]) and inRange(SpellName,LYTeamPlayers[i]) and not HaveDebuff(LYTeamPlayers[i],LYListDoNotDispel) then
					if DispelStunUnit(LYTeamPlayers[i]) then
						LYSpellStopCasting()
						LYQueueSpell(SpellName,LYTeamPlayers[i])
						LY_Print(SpellName.." @DPS teammate","green",SpellName)
						return true
					elseif DispelCCUnit(LYTeamPlayers[i]) then
						tinsert(cced,LYTeamPlayers[i])
					end
				end
			end
			if #cced == 0 then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and inRange(SpellName,LYTeamPlayers[i]) and not HaveDebuff(LYTeamPlayers[i],LYListDoNotDispel) and DispelRootUnit(LYTeamPlayers[i]) then
						tinsert(cced,LYTeamPlayers[i])
					end
				end
			end
			if #cced == 0 and LYDispelDotCount ~= 0 then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and inRange(SpellName,LYTeamPlayers[i]) and not HaveDebuff(LYTeamPlayers[i],LYListDoNotDispel) and LYDispelMyType(LYTeamPlayers[i],nil,true) >= LYDispelDotCount and CalculateHP(LYTeamPlayers[i]) < LYDispelDoTHP and not HaveDebuff(LYTeamPlayers[i],{WlUnstable,PrVTouch}) then
						tinsert(cced,LYTeamPlayers[i])
					end
				end
			end
			if #cced == 0 then
				return false
			elseif #cced == 1 then
				LYSpellStopCasting()
				LYQueueSpell(SpellName,cced[1])
				LY_Print(SpellName.." @DPS teammate","green",SpellName)
				return true
			else
				local ccedsort = {}
				for i=1,#cced do
					if not FriendIsUnderAttack(cced[i]) then
						LYSpellStopCasting()
						LYQueueSpell(SpellName,cced[i])
						LY_Print(SpellName.." @DPS teammate","green",SpellName)
						return true
					else
						tinsert(ccedsort,cced[i])
					end
				end
				table.sort(ccedsort,function(x,y) return CalculateHP(x) > CalculateHP(y) end)
				LYSpellStopCasting()
				LYQueueSpell(SpellName,ccedsort[1])
				LY_Print(SpellName.." @DPS teammate","green",SpellName)
				return true
			end
		end
	end
	function AvoidHealer(spell,func,range,dmgtype,face)
		local function HealerAroundUnit(range)
			if #LYEnemyHealers > 0 then
				for i=1,#LYEnemyHealers do
					if GetDistanceToUnit(LYEnemyHealers[i]) < range then
						return LYEnemyHealers[i]
					end
				end
			end
		end
		local healer = HealerAroundUnit(range)
		if not func or not GCDCheck(spell) or not healer or (dmgtype and not SpellAttackTypeCheck(healer,dmgtype)) then
			return
		end
		LY_Print("Avoid Healer with "..spell,"green",spell)
		LYQueueSpell(spell,healer,face)
	end
	function AvoidGapCloser(spell,func,range,dmgtype,face)
		if not func or not GapCloseTime or not UnitIsVisible(GapCloseUnit) or not GCDCheck(spell) or (dmgtype and not SpellAttackTypeCheck(GapCloseUnit,dmgtype)) or (range and GetDistanceToUnit(GapCloseUnit) > range) then
			return
		end
		if GetTime() - GapCloseTime > 1 then
			GapCloseTime = 0
			GapCloseUnit = nil
			GapCloseDistance = 0
			return
		end
		LY_Print("Avoid "..GapCloseSpell.." with "..spell,"green",spell)
		LYQueueSpell(spell,GapCloseUnit,face)
		GapCloseTime = 0
		GapCloseUnit = nil
		GapCloseDistance = 0
		return true
	end
	function AvoidStun(spell)
		if GCDCheck(ShadowMeld) and (spell ~= RgShStep or LYPlayerRole == "HEALER") then
			StopMoving(true)
			LYSpellStopCasting()
			CastSpellByName(ShadowMeld)
			LY_Print(ShadowMeld.." stun","green",ShadowMeld)
			return true
		end
		if LYMyClass == 1 and LYMySpec ~= 3 and GCDCheck(WrDStance) and not HaveBuff("player",WrDStance) and LYWrDStanceStun then
			CastSpellByName(WrDStance)
			LY_Print(WrDStance.." stun","green",WrDStance)
			return true
		end
		if LYMyClass == 4 and GCDCheck(RgFeint) and not HaveBuff("player",RgFeint) and IsTalentInUse(79008) then
			LYSpellStopCasting()
			LYQueueSpell(RgFeint)
			LY_Print(RgFeint.." stun","green",RgFeint)
			return true
		end
		if LYMyClass == 11 and GetShapeshiftForm() ~= 1 and not HaveBuff("player",DrIncTree) and LYMySpec == 4 and GCDCheck(DrBear) then
			LYSpellStopCasting()
			LYQueueSpell(DrBear)
			LY_Print(DrBear.." stun","green",DrBear)
			return true
		end
		if LYMyClass == 12 then
			if GCDCheck(DHBladeDance) then
				LYSpellStopCasting()
				LYQueueSpell(DHBladeDance)
				LY_Print(DHBladeDance.." stun","green",DHBladeDance)
				return true
			elseif spell ~= RgShStep and GCDCheck(DHRainAbove) and LYDHRainAboveStun then
				LYSpellStopCasting()
				LYQueueSpell(DHRainAbove)
				LY_Print(DHRainAbove.." stun","green",DHRainAbove)
				return true
			end
		end
	end
	--Tables
	function IDTables()
		Fishing = GetSpellInfo(131474)
		Mining = GetSpellInfo(2575)
		Herbing = GetSpellInfo(2366)
		TradeMount = GetSpellInfo(61425)
		ArenaPrepBuff = GetSpellInfo(32727)
		DeserterBG = GetSpellInfo(26013)
		DeserterArena = GetSpellInfo(158263)
		GhostUnit = GetSpellInfo(8326)
		PvPTrinket1 = GetSpellInfo(218423)
		PvPTrinket2 = GetSpellInfo(218716)
		HordeFlag = GetSpellInfo(156618)
		AlyFlag = GetSpellInfo(156621)
		OrbPower = GetSpellInfo(121164)
		DrinkMana = GetSpellInfo(172786)
		PetSummon = GetSpellInfo(159584)
		CastRaidMarker = GetSpellInfo(84996)
		MiningSkill = GetSpellInfo(32606)
		HerbSkill = GetSpellInfo(170691)
		SoulWell = GetSpellInfo(58275)
		FlagCapture = GetSpellInfo(70263)
		ShadowMeld = GetSpellInfo(58984)
		DwarfSkin = GetSpellInfo(20594)
		HumanTrinket = GetSpellInfo(59752)
		QuakingPalm = GetSpellInfo(107079)
		WarStomp = GetSpellInfo(20549)
		ArcaneTorrent = GetSpellInfo(50613)
		GiftNaaru = GetSpellInfo(28880)
		BloodFury = GetSpellInfo(33702)
		Berserking = GetSpellInfo(26297)
		AncCall = GetSpellInfo(274738)
		LightJudg = GetSpellInfo(255647)
		BullRush = GetSpellInfo(255654)
		RocketBar = GetSpellInfo(69041)
		EscapeArt = GetSpellInfo(20589)
		Darkflight = GetSpellInfo(68992)
		WillForsaken = GetSpellInfo(7744)
		PvEEyeAman = GetSpellInfo(206516)
		PvEStuffNightmare = GetSpellInfo(209915)
		FelExplosive = GetSpellInfo(243110)
		IgniteSoul = GetSpellInfo(228796)
		SpiritRealm = GetSpellInfo(235621)
		PvEDebuff = GetSpellInfo(257908)
		MaledictTrinket = GetSpellInfo(294127)
		SpiritHeal = GetSpellInfo(44535)
		PurifySoul = GetSpellInfo(323436)
		Fleshcraft = GetSpellInfo(324631)
		CyclotBlast = GetSpellInfo(293491)
		FocusEnergy = GetSpellInfo(299335)
		TwistAppend = GetSpellInfo(318483)
		CutDeath = GetSpellInfo(281712)
		SteadResolve = GetSpellInfo(318378)
		Haymaker = GetSpellInfo(287712)
		ThingFromBeyond = GetSpellInfo(313301)
		CovenantAbility = GetSpellInfo(313347)
		DoorShadows = GetSpellInfo(300728)
		AgentChaos = GetSpellInfo(331866)
		DeathTouch = GetSpellInfo(5)
		HonorlessTarget = GetSpellInfo(2479)
		Mercenary = GetSpellInfo(193475)
		SummonSteward = GetSpellInfo(324739)
		UltForm = GetSpellInfo(323524)
		ConquerorBanner = GetSpellInfo(324143)
		ForgeBourne = GetSpellInfo(326514)
		BagofTricks = GetSpellInfo(312411)
		--PvE
		--dispel
		RendingMaul = GetSpellInfo(255814)
		WrackingPain = GetSpellInfo(250096)
		UnstableHex = GetSpellInfo(252781)
		LingeringNausea = GetSpellInfo(250372)
		Wildfire = GetSpellInfo(253562)
		TerrifyingVisage = GetSpellInfo(255371)
		MoltenGold = GetSpellInfo(255582)
		VenomfangStrike = GetSpellInfo(252687)
		PileOfBones = GetSpellInfo(257483)
		BloodthirstyLeap = GetSpellInfo(225963)
		BrutalGlaive = GetSpellInfo(197546)
		SoulBlade = GetSpellInfo(200084)
		SoulEchoes = GetSpellInfo(194960)
		SoulVenom = GetSpellInfo(225909)
		GrievousTear = GetSpellInfo(196376)
		GrievousRip = GetSpellInfo(225484)
		CurseOfIsolation = GetSpellInfo(201839)
		DarksoulDrain = GetSpellInfo(201365)
		Despair = GetSpellInfo(200642)
		TormentingFear = GetSpellInfo(204246)
		FesteringRip = GetSpellInfo(200182)
		ScorchingShot = GetSpellInfo(201902)
		NightmareToxin = GetSpellInfo(200684)
		PoisonSpear = GetSpellInfo(198904)
		StranglingRoots = GetSpellInfo(199063)
		Stonebolt = GetSpellInfo(412285)
		Temposlice = GetSpellInfo(412044)
		Bloom = GetSpellInfo(413547)
		Chronoburst = GetSpellInfo(415554)
		ShearedLifespan = GetSpellInfo(416716)
		Chronomelt = GetSpellInfo(411994)
		SerratedArrows = GetSpellInfo(418009)
		SerratedAxe = GetSpellInfo(407120)
		Shrapnel = GetSpellInfo(407313)
		RendingCleave = GetSpellInfo(412505)
		SlobberingBite = GetSpellInfo(411700)
		TimelessCurse = GetSpellInfo(413618)
		SoggyBonk = GetSpellInfo(411644)
		OrbOfContemplation = GetSpellInfo(412131)
		CorrodingVolley = GetSpellInfo(413606)
		SparkOfTyr = GetSpellInfo(400681)
		TimeStasis = GetSpellInfo(401667)
		Fireball = GetSpellInfo(417030)
		ChronalBurn = GetSpellInfo(412027)
		Immolate = GetSpellInfo(407121)
		GlacialFusion = GetSpellInfo(428084)
		Frostbolt = GetSpellInfo(427863)
		ChokingVines = GetSpellInfo(164965)
		Pyroblast = GetSpellInfo(169839)
		ColdFusion = GetSpellInfo(426849)
		VenomBurst = GetSpellInfo(165123)
		PoisonousClaws = GetSpellInfo(169658)
		DreadpetalPollen = GetSpellInfo(164886)
		GnarledRoots = GetSpellInfo(426500)
		WaveOfCorruption = GetSpellInfo(76363)
		LightningSurge = GetSpellInfo(75992)
		FlameShock = GetSpellInfo(429048)
		RavagingLeap = GetSpellInfo(271178)
		JaggedNettles = GetSpellInfo(260741)
		TearingStrike = GetSpellInfo(264556)
		UnstableRunicMark = GetSpellInfo(260703)
		RunicMark = GetSpellInfo(264105)
		DreadMark = GetSpellInfo(265880)
		VirulentPathogen = GetSpellInfo(261440)
		InfectedThorn = GetSpellInfo(264050)
		DecayingTouch = GetSpellInfo(265881)
		FragmentSoul = GetSpellInfo(264378)
		SeveringSerpent = GetSpellInfo(264520)
		--kick
		MendingWord = GetSpellInfo(253517)
		BwomsamdisMantle = GetSpellInfo(253548)
		TerrifyingScreech = GetSpellInfo(6605)
		NoxiousStench = GetSpellInfo(250368)
		UnnervingScreech = GetSpellInfo(200631)
		TormentingEye = GetSpellInfo(204243)
		BloodMetamorphosis = GetSpellInfo(225562)
		DreadInferno = GetSpellInfo(201399)
		Spellbind = GetSpellInfo(264390)
		PallidGlare = GetSpellInfo(255978)
		SoulVolley = GetSpellInfo(263959)
		Retch = GetSpellInfo(360448)
		Infest = GetSpellInfo(278444)
		RuinousVolley = GetSpellInfo(265876)
		HorrificVisage = GetSpellInfo(138040)
		DarkenedLightning = GetSpellInfo(266225)
		InfiniteBoltVolley = GetSpellInfo(202019)
		Enervate = GetSpellInfo(415437)
		DisplaceChronosequence = GetSpellInfo(417481)
		InfiniteBurn = GetSpellInfo(418200)
		FishBoltVolley = GetSpellInfo(411300)
		DizzyingSands = GetSpellInfo(412378)
		RocketBoltVolley = GetSpellInfo(412233)
		Felfrenzy = GetSpellInfo(227913)
		EnragedGrowth = GetSpellInfo(165213)
		Revitalize = GetSpellInfo(168082)
		ToxicBloom = GetSpellInfo(427459)
		Aquablast = GetSpellInfo(429176)
		HealingWave = GetSpellInfo(76813)
		--stun kick
		BulwarkofJuju = GetSpellInfo(253721)
		DeathLens = GetSpellInfo(268202)
		ElectroJuicedGigablast = GetSpellInfo(412200)
		KnifeDance = GetSpellInfo(200291)
		ArrowBarrage = GetSpellInfo(200345)
		AncientPotion = GetSpellInfo(200784)
		PoisonedSpear = GetSpellInfo(76516)
		--root
		PileOfBones = GetSpellInfo(257483)
		StranglingRoots = GetSpellInfo(199063)
		DreadpetalPollen = GetSpellInfo(164886)
		GnarledRoots = GetSpellInfo(426500)

		-- Warrior
		WrBers = GetSpellInfo(18499)
		WrMasReflect = GetSpellInfo(213915)
		WrFear = GetSpellInfo(5246)
		WrCharge = GetSpellInfo(100)
		WrThrow = GetSpellInfo(57755)
		WrHarm = GetSpellInfo(1715)
		WrAvatar = GetSpellInfo(107574)
		WrReck = GetSpellInfo(1719)
		WrExecute = GetSpellInfo(163201)
		WrStorm = GetSpellInfo(1680)
		WrKick = GetSpellInfo(6552)
		WrSW = GetSpellInfo(46968)
		WrBolt = GetSpellInfo(107570)
		WrReflect = GetSpellInfo(23920)
		WrTaunt = GetSpellInfo(355)
		WrRaly = GetSpellInfo(97462)
		WrLeap = GetSpellInfo(6544)
		WrHeal = GetSpellInfo(184364)
		WrVRush = GetSpellInfo(34428)
		WrBS = GetSpellInfo(46924)
		WrWounds = GetSpellInfo(115768)
		WrVRushProc = GetSpellInfo(32216)
		WrThunder = GetSpellInfo(6343)
		WrChargeStun = GetSpellInfo(103828)
		WrDStance = GetSpellInfo(386208)
		WrBStance = GetSpellInfo(53792)
		WrDeathSent = GetSpellInfo(144442)
		WrRoar = GetSpellInfo(384318)
		WrLigil = GetSpellInfo(114030)
		WrAP = GetSpellInfo(6673)
		WrShatThrow = GetSpellInfo(64382)
		WrSpearBast = GetSpellInfo(307865)
		WrBitterImmune = GetSpellInfo(383762)
		WrWreckThrow = GetSpellInfo(384110)
		-- Arms
		WrDW = GetSpellInfo(262115)
		WrDbS = GetSpellInfo(118038)
		WrDoT = GetSpellInfo(772)
		WrColos = GetSpellInfo(167105)
		WrMortal = GetSpellInfo(12294)
		WrSlam = GetSpellInfo(1464)
		WrMortalWound = GetSpellInfo(115804)
		WrOver = GetSpellInfo(7384)
		WrFocusRage = GetSpellInfo(207982)
		WrAArt = GetSpellInfo(209577)
		WrSharpBlade = GetSpellInfo(198817)
		WrShatDef = GetSpellInfo(209574)
		WrCleave = GetSpellInfo(845)
		WrDisarm = GetSpellInfo(236077)
		WrDuel = GetSpellInfo(236273)
		WrBanner = GetSpellInfo(236320)
		WrExePrecis = GetSpellInfo(242188)
		WrSudDeath = GetSpellInfo(29725)
		WrSkul = GetSpellInfo(260643)
		WrSwStrk = GetSpellInfo(260708)
		WrCrusAs = GetSpellInfo(278824)
		WrWarBreak = GetSpellInfo(262161)
		WrExploit = GetSpellInfo(335452)
		WrMartProw = GetSpellInfo(316440)
		-- Fury
		WrBloodThirst = GetSpellInfo(23881)
		WrWildStrike = GetSpellInfo(100130)
		WrRagBlow = GetSpellInfo(85288)
		WrPiercHowl = GetSpellInfo(12323)
		WrMeatCleaver = GetSpellInfo(85739)
		WrEnrage = GetSpellInfo(184362)
		WrRampage = GetSpellInfo(184367)
		WrBall = GetSpellInfo(215570)
		WrMassacre = GetSpellInfo(206315)
		WrFrenzy = GetSpellInfo(202539)
		WrFrotBers = GetSpellInfo(215572)
		WrFArt = GetSpellInfo(205545)
		WrDeathWish = GetSpellInfo(199261)
		WrBarbar = GetSpellInfo(280745)
		WrThirstBattle = GetSpellInfo(199202)
		WrBattleTrance = GetSpellInfo(213858)
		WrOnslaught = GetSpellInfo(315720)
		WrReprisal = GetSpellInfo(335718)
		WrMerciAss =  GetSpellInfo(409983)
		-- Prot
		WrShieldSlam = GetSpellInfo(23922)
		WrRevenge = GetSpellInfo(6572)
		WrDevastate = GetSpellInfo(20243)
		WrLastStand = GetSpellInfo(12975)
		WrDefShout = GetSpellInfo(1160)
		WrIntervene = GetSpellInfo(3411)
		WrShieldBlock = GetSpellInfo(2565)
		WrVenFocRage = GetSpellInfo(202573)
		WrVenIgnPain = GetSpellInfo(202574)
		WrIgnorePain = GetSpellInfo(190456)
		WrShieldWall = GetSpellInfo(871)
		WrRavager = GetSpellInfo(228920)
		WrShieldBash = GetSpellInfo(198912)
		WrDrCharge = GetSpellInfo(206572)
		WrPArt = GetSpellInfo(203524)
		WrFreeRev = GetSpellInfo(5302)
		WrMorKiller = GetSpellInfo(199023)
		WrLeaveBeh = GetSpellInfo(199037)
		WrWarpath = GetSpellInfo(199086)
		WrOppres = GetSpellInfo(205800)
		WrBodyGuard = GetSpellInfo(213871)
		WrBurHatch = GetSpellInfo(280212)
		WrSpellBlock = GetSpellInfo(392966)
		-- Paladin
		PlRep = GetSpellInfo(20066)
		PlFlash = GetSpellInfo(19750)
		PlBlind = GetSpellInfo(115750)
		PlSearingGlare = GetSpellInfo(410126)
		PlHoJ = GetSpellInfo(853)
		PlFreedom = GetSpellInfo(1044)
		PlBubble = GetSpellInfo(642)
		PlBoP = GetSpellInfo(1022)
		PlSac = GetSpellInfo(6940)
		PlKick = GetSpellInfo(96231)
		PlWings = GetSpellInfo(31884)
		PlJudg = GetSpellInfo(20271)
		PlHolyPrizm = GetSpellInfo(114165)
		PlCrusader = GetSpellInfo(35395)
		PlDevProt = GetSpellInfo(498)
		PlTaunt = GetSpellInfo(62124)
		PlForbear = GetSpellInfo(25771)
		PlMA = GetSpellInfo(31821)
		PlSpeed = GetSpellInfo(85499)
		PlLoH = GetSpellInfo(633)
		PlAuraCrus = GetSpellInfo(32223)
		PlAuraDev = GetSpellInfo(465)
		PlAuraConc = GetSpellInfo(317920)
		PlAuraRetri = GetSpellInfo(183435)
		PlDivToll = GetSpellInfo(304971)
		PlBlessSpr = GetSpellInfo(328282)
		PlBlessSum = GetSpellInfo(328620)
		PlBlessAut = GetSpellInfo(328622)
		PlBlessWin = GetSpellInfo(328281)
		PlAshHallow = GetSpellInfo(316958)
		PlRoyalDec = GetSpellInfo(340147)
		-- Holy
		PlHolyLight = GetSpellInfo(82326)
		PlLightDawn = GetSpellInfo(85222)
		PlBeacon = GetSpellInfo(53563)
		PlBeacon2 = GetSpellInfo(156910)
		PlShock = GetSpellInfo(20473)
		PlSacShield = GetSpellInfo(223306)
		PlLightInf = GetSpellInfo(53576)
		PlLightJudg = GetSpellInfo(196941)
		PlMartyr = GetSpellInfo(183998)
		PlAvenger = GetSpellInfo(105809)
		PlDispel = GetSpellInfo(4987)
		PlAvenCrus = GetSpellInfo(216331)
		PlTyrDev = GetSpellInfo(200652)
		PlMaraad = GetSpellInfo(234848)
		PlFervent = GetSpellInfo(196923)
		PlShVirtue = GetSpellInfo(215652)
		PlDivFavor = GetSpellInfo(210294)
		PlLightSaves = GetSpellInfo(200421)
		PlBreakDawn = GetSpellInfo(279406)
		PlLightGrace = GetSpellInfo(216328)
		PlUltSac = GetSpellInfo(199450)
		PlGlimmer = GetSpellInfo(287268)
		PlDarkDawn = GetSpellInfo(210391)
		PlBarFaith = GetSpellInfo(148039)
		PlVeneration = GetSpellInfo(392938)
		PlHandDiv = GetSpellInfo(414273)
		-- Retri
		PlDivStorm = GetSpellInfo(53385)
		PlVerdict = GetSpellInfo(85256)
		PlDivPurp = GetSpellInfo(223819)
		PlSelflessHeal = GetSpellInfo(114250)
		PlFVerdict = GetSpellInfo(157048)
		PlBladeJust = GetSpellInfo(184575)
		PlJustVeng = GetSpellInfo(215661)
		PlHindrace = GetSpellInfo(183218)
		PlShieldVeng = GetSpellInfo(184662)
		PlExSent = GetSpellInfo(343527)
		PlJustFire = GetSpellInfo(209785)
		PlEye = GetSpellInfo(205191)
		PlGlory = GetSpellInfo(85673)
		PlDivSteed = GetSpellInfo(190784)
		PlRDispel = GetSpellInfo(213644)
		PlSanctuary = GetSpellInfo(210256)
		PlRArt = GetSpellInfo(205273)
		PlSerBless = GetSpellInfo(204927)
		PlScarlet = GetSpellInfo(248289)
		PlWrathHam = GetSpellInfo(24275)
		PlInquis = GetSpellInfo(84963)
		PlEmpyrean = GetSpellInfo(286390)
		PlHolywar = GetSpellInfo(231895)
		PlFinReckon = GetSpellInfo(343721)
		PlAuraReckon = GetSpellInfo(247675)
		PlFinVerdict = GetSpellInfo(337228)
		PlDivArb = GetSpellInfo(404306)
		-- Prot
		PlAvShield = GetSpellInfo(31935)
		PlConsec = GetSpellInfo(26573)
		PlShieldRight = GetSpellInfo(53600)
		PlDefender = GetSpellInfo(31850)
		PlRightFury = GetSpellInfo(25780)
		PlGrandCrus = GetSpellInfo(85416)
		PlGuardKings = GetSpellInfo(86659)
		PlPArt = GetSpellInfo(209202)
		PlJudgLight = GetSpellInfo(183778)
		PlHalGround = GetSpellInfo(216868)
		PlMomGlory = GetSpellInfo(327193)
		PlShinLight = GetSpellInfo(321136)
		PlEyeTyr = GetSpellInfo(387174)
		PlBastLight = GetSpellInfo(378974)
		PlRedoubt = GetSpellInfo(280373)
		PlSent = GetSpellInfo(389539)
		-- Hunter
		HnPetSac = GetSpellInfo(53480)
		HnTrap = GetSpellInfo(187650)
		HnFear = GetSpellInfo(24394)
		HnFreedom = GetSpellInfo(53271)
		HnDeter = GetSpellInfo(186265)
		HnPetSlow = GetSpellInfo(50433)
		HnPetSlow2 = GetSpellInfo(54644)
		HnFrAmmo = GetSpellInfo(162546)
		HnBlink = GetSpellInfo(781)
		HnSteady = GetSpellInfo(56641)
		HnHealPet = GetSpellInfo(136)
		HnFD = GetSpellInfo(5384)
		HnArcane = GetSpellInfo(185358)
		HnMulti = GetSpellInfo(2643)
		HnRevPet = GetSpellInfo(982)
		HnExpTrap = GetSpellInfo(191433)
		HnFlare = GetSpellInfo(1543)
		HnStealth = GetSpellInfo(199483)
		HnBarrage = GetSpellInfo(120360)
		HnCrows = GetSpellInfo(131894)
		HnBindShot = GetSpellInfo(109248)
		HnTaunt = GetSpellInfo(34477)
		HnHeal = GetSpellInfo(109304)
		HnHarpoon = GetSpellInfo(190925)
		HnEagleBurst = GetSpellInfo(186289)
		HnCobraBurst = GetSpellInfo(194407)
		HnToss = GetSpellInfo(193265)
		HnConcus = GetSpellInfo(5116)
		HnDiamondIce = GetSpellInfo(203340)
		HnPrimalRage = GetSpellInfo(272678)
		HnInterlope = GetSpellInfo(248518)
		HnCallPetName = GetSpellInfo(67777)
		HnCallPet = {
		GetSpellInfo(883),
		GetSpellInfo(83242),
		GetSpellInfo(83243),
		GetSpellInfo(83244),
		GetSpellInfo(83245)
		}
		HnPlayDead = GetSpellInfo(209997)
		HnWakeUp = GetSpellInfo(210000)
		HnKillShot = GetSpellInfo(53351)
		HnPurge = GetSpellInfo(19801)
		HnFlayMark = GetSpellInfo(324156)
		HnDeathChak = GetSpellInfo(325028)
		HnCombatMedit = GetSpellInfo(328266)
		HnWildKing = GetSpellInfo(356707)
		HnChimaeralSting = GetSpellInfo(356719)
		HnScareBeast = GetSpellInfo(1513)
		HnDeathblow = GetSpellInfo(378770)
		HnSurvFit = GetSpellInfo(264735)
		HnSentinel = GetSpellInfo(393480)
		HnFortBear = GetSpellInfo(388035)
		-- Surv
		HnRootTrap = GetSpellInfo(187698)
		HnSerpent = GetSpellInfo(87935)
		HnLacer = GetSpellInfo(185855)
		HnFlank = GetSpellInfo(269751)
		HnRaptor = GetSpellInfo(186270)
		HnAxes = GetSpellInfo(200163)
		HnDragon = GetSpellInfo(194855)
		HnMongFury = GetSpellInfo(190931)
		HnSnakeHunt = GetSpellInfo(201078)
		HnRangNet = GetSpellInfo(206755)
		HnStickBomb = GetSpellInfo(191241)
		HnKick = GetSpellInfo(187707)
		HnWingClip = GetSpellInfo(195645)
		HnFuryEagle = GetSpellInfo(203415)
		HnMendBand = GetSpellInfo(212640)
		HnTrackerNet = GetSpellInfo(212638)
		HnRangerNet = GetSpellInfo(200108)
		HnSteelTrap = GetSpellInfo(162480)
		HnTarTrap = GetSpellInfo(407028)
		HnSSTar = GetSpellInfo(201158)
		HnOnTrail = GetSpellInfo(204081)
		HnCoordAttack = GetSpellInfo(266779)
		HnChakrams = GetSpellInfo(259391)
		HnWildFireBomb = GetSpellInfo(259495)
		HnPredator = GetSpellInfo(260249)
		HnButherBone = GetSpellInfo(336908)
		HnMadBomb = GetSpellInfo(364490)
		HnButchery = GetSpellInfo(212436)
		HnCoordKill = GetSpellInfo(385739)
		-- BM
		HnKillCom = GetSpellInfo(34026)
		HnBullHead = GetSpellInfo(53490)
		HnFrenzy = GetSpellInfo(19623)
		HnBestWrath = GetSpellInfo(19574)
		HnSpiritMend = GetSpellInfo(90361)
		HnCobra = GetSpellInfo(193455)
		HnDireBeast = GetSpellInfo(120679)
		HnChimaera = GetSpellInfo(53209)
		HnKick2 = GetSpellInfo(147362)
		HnBestCun = GetSpellInfo(191397)
		HnIntimid = GetSpellInfo(19577)
		HnBArt = GetSpellInfo(207068)
		HnHawk = GetSpellInfo(208652)
		HnBasil = GetSpellInfo(205691)
		HnBarbShot = GetSpellInfo(217200)
		HnBeastCleave = GetSpellInfo(115939)
		HnBloodshed = GetSpellInfo(321530)
		HnThrill = GetSpellInfo(257946)
		HnHuntPrey = GetSpellInfo(378215)
		HnCallWild = GetSpellInfo(359844)
		-- MM
		HnAimed = GetSpellInfo(19434)
		HnBurstShot = GetSpellInfo(186387)
		HnSentinel = GetSpellInfo(206817)
		HnExplosive = GetSpellInfo(212431)
		HnExplosiveDeton = GetSpellInfo(212679)
		HnExplDeton = GetSpellInfo(212679)
		HnBlackArrow = GetSpellInfo(430703) -- og 194599
		HnPiercShout = GetSpellInfo(198670)
		HnLockAndLoad = GetSpellInfo(194594)
		HnStdFoc = GetSpellInfo(193533)
		HnVolley = GetSpellInfo(260243)
		HnTrueShot = GetSpellInfo(288613)
		HnBombard = GetSpellInfo(82921)
		HnMArt = GetSpellInfo(204147)
		HnScatter = GetSpellInfo(213691)
		HnSniperShot = GetSpellInfo(203155)
		HnFreezArrow = GetSpellInfo(209789)
		HnHiExpTrap = GetSpellInfo(236776)
		HnCritAim = GetSpellInfo(242243)
		HnSentSight = GetSpellInfo(208913)
		HnPrecShout = GetSpellInfo(260242)
		HnRapidFire = GetSpellInfo(257044)
		HnHuntMark = GetSpellInfo(257284)
		HnTrickShot = GetSpellInfo(257621)
		HnSalvo = GetSpellInfo(400456)
		-- Rogue
		RgEvasion = GetSpellInfo(5277)
		RgGouge = GetSpellInfo(1776)
		RgSap = GetSpellInfo(6770)
		RgBlind = GetSpellInfo(2094)
		RgCheap = GetSpellInfo(1833)
		RgKidney = GetSpellInfo(408)
		RgCloak = GetSpellInfo(31224)
		RgStealth = GetSpellInfo(1784)
		RgKick = GetSpellInfo(1766)
		RgGarrotte = GetSpellInfo(1330)
		RgPoison = GetSpellInfo(3409)
		RgSlowThrow = GetSpellInfo(26679)
		RgSW = GetSpellInfo(74001)
		RgBomb = GetSpellInfo(76577)
		RgBSpeed = GetSpellInfo(108212)
		RgSliceDice = GetSpellInfo(5171)
		RgSprint = GetSpellInfo(2983)
		RgFeint = GetSpellInfo(1966)
		RgVanish = GetSpellInfo(1856)
		RgAmbush = GetSpellInfo(8676)
		RgGarStrike = GetSpellInfo(703)
		RgShStep = GetSpellInfo(36554)
		RgDeathAbove = GetSpellInfo(152150)
		RgShReflect = GetSpellInfo(152151)
		RgDeadlyPoison = GetSpellInfo(2823)
		RgWoundPoison = GetSpellInfo(8679)
		RgCripPoison = GetSpellInfo(3408)
		RgNumbPoison = GetSpellInfo(5761)
		RgPrep = GetSpellInfo(44521)
		RgSinister = GetSpellInfo(1752)
		RgRupture = GetSpellInfo(1943)
		RgCrimson = GetSpellInfo(185311)
		RgCreeping = GetSpellInfo(198092)
		RgShiv = GetSpellInfo(5938)
		RgShrSuf = GetSpellInfo(278666)
		RgEchoingReprimand = GetSpellInfo(323547)
		RgSerratedBoneSpike = GetSpellInfo(328547)
		RgSepsis = GetSpellInfo(328305)
		RgThistleTea = GetSpellInfo(381623)
		RgHemotox = GetSpellInfo(354124)
		-- Sub
		RgSD = GetSpellInfo(185313)
		RgHemor = GetSpellInfo(16511)
		RgBackstab = GetSpellInfo(53)
		RgShBlade = GetSpellInfo(121471)
		RgNightBlade = GetSpellInfo(195452)
		RgShuriken = GetSpellInfo(197835)
		RgEvis = GetSpellInfo(196819)
		RgToss = GetSpellInfo(114014)
		RgShadStrk = GetSpellInfo(185438)
		RgSymbDeath = GetSpellInfo(212283)
		RgNightTer = GetSpellInfo(206760)
		RgSArt = GetSpellInfo(209782)
		RgStrShadow = GetSpellInfo(196958)
		RgColdblood = GetSpellInfo(213981)
		RgMasterAsInit = GetSpellInfo(235022)
		RgFirstOfDead = GetSpellInfo(248110)
		RgSecTech = GetSpellInfo(280719)
		RgShurTornado = GetSpellInfo(277925)
		RgBlackPowder = GetSpellInfo(319175)
		RgGoremBite = GetSpellInfo(426591)
		RgFlagel = GetSpellInfo(384631)
		-- Outlaw
		RgAR = GetSpellInfo(13750)
		RgKillSpree = GetSpellInfo(51690)
		RgOpportun = GetSpellInfo(195627)
		RgBtwEyes = GetSpellInfo(315341)
		RgPistolShot = GetSpellInfo(185763)
		RgRipost = GetSpellInfo(199754)
		RgGrapHook = GetSpellInfo(195457)
		RgSaberSlash = GetSpellInfo(193315)
		RgGhostStrk = GetSpellInfo(196937)
		RgBladeFlurry = GetSpellInfo(13877)
		RgRollBones = GetSpellInfo(315508)
		RgRunThr = GetSpellInfo(2098)
		RgDisarm = GetSpellInfo(207777)
		RgOArt = GetSpellInfo(202665)
		RgCheapTrick = GetSpellInfo(213995)
		RgTricks = GetSpellInfo(57934)
		RgShadDuel = GetSpellInfo(207736)
		RgBladeRush = GetSpellInfo(271877)
		RgDeadshot = GetSpellInfo(272935)
		RgBroadside = GetSpellInfo(193356)
		RgBuriedTreas = GetSpellInfo(199600)
		RgGrandMelee = GetSpellInfo(193358)
		RgRuthPrec = GetSpellInfo(193357)
		RgSkullCross = GetSpellInfo(199603)
		RgTrueBearing = GetSpellInfo(193359)
		RgLoadedDice = GetSpellInfo(256171)
		RgDreadblades = GetSpellInfo(343142)
		RgAudacity = GetSpellInfo(386270)
		-- Assasin
		RgMuti = GetSpellInfo(1329)
		RgBlindSide = GetSpellInfo(121153)
		RgPoisKnife = GetSpellInfo(185565)
		RgEnven = GetSpellInfo(32645)
		RgFan = GetSpellInfo(51723)
		RgAArt = GetSpellInfo(192759)
		RgSubterfuge = GetSpellInfo(108208)
		RgToxicBlade = GetSpellInfo(245388)
		RgIntBleed = GetSpellInfo(154904)
		RgHidBlade = GetSpellInfo(270070)
		RgCrimTemp = GetSpellInfo(121411)
		RgKingsbane = GetSpellInfo(385627)
		RgDeathmark = GetSpellInfo(360194)
		RgImprGar = GetSpellInfo(392403)
		-- Priest
		PrFlash = GetSpellInfo(2061)
		PrHeal = GetSpellInfo(2060)
		PrPrayerHealing = GetSpellInfo(596)
		PrPrayerMending = GetSpellInfo(33076)
		PrDivHymn = GetSpellInfo(64843)
		PrMD = GetSpellInfo(32375)
		PrFear = GetSpellInfo(8122)
		PrMC = GetSpellInfo(605)
		PrInfusion = GetSpellInfo(10060)
		PrSilence = GetSpellInfo(15487)
		PrClarity = GetSpellInfo(152118)
		PrSWP = GetSpellInfo(589)
		PrSWD = GetSpellInfo(32379)
		PrPurge = GetSpellInfo(528)
		PrGrip = GetSpellInfo(73325)
		PrFade = GetSpellInfo(586)
		PrPet = GetSpellInfo(34433)
		PrFeather = GetSpellInfo(121536)
		PrBuff = GetSpellInfo(211681)
		PrWeakSoul = GetSpellInfo(6788)
		PrShield = GetSpellInfo(17)
		PrDispel = GetSpellInfo(527)
		PrHolyFire = GetSpellInfo(14914)
		PrDivStar = GetSpellInfo(110744)
		PrDespPrayer = GetSpellInfo(19236)
		PrHalo = GetSpellInfo(120517)
		PrSmite = GetSpellInfo(585)
		PrSanctum = GetSpellInfo(274366)
		PrShackle = GetSpellInfo(9484)
		PrThoughtsteal = GetSpellInfo(323716)
		PrMindSoothe = GetSpellInfo(453)
		PrMindGame = GetSpellInfo(323673)
		PrPWLife = GetSpellInfo(373481)
		PrUltPenance = GetSpellInfo(421453)
		PrPhase = GetSpellInfo(408557)
		-- Holy
		PrWings = GetSpellInfo(47788)
		PrChas = GetSpellInfo(88625)
		PrPhatasm = GetSpellInfo(114239)
		PrSeren = GetSpellInfo(2050)
		PrCircle = GetSpellInfo(204883)
		PrHolyNova = GetSpellInfo(132157)
		PrApotheosis = GetSpellInfo(200183)
		PrHolyWard = GetSpellInfo(213610)
		PrRayHope = GetSpellInfo(197268)
		PrHArt = GetSpellInfo(208065)
		PrRenew = GetSpellInfo(139)
		PrSanctify = GetSpellInfo(34861)
		PrSymbolHope = GetSpellInfo(64901)
		PrRedemption = GetSpellInfo(20711)
		PrPWConcen = GetSpellInfo(289657)
		PrGreatHeal = GetSpellInfo(289666)
		PrDivAscen = GetSpellInfo(328530)
		PrCensure = GetSpellInfo(200199)
		PrDivWord = GetSpellInfo(372760)
		PrEmpBlaze = GetSpellInfo(372616)
		PrSpiritRedem = GetSpellInfo(215769)
		PrSalvation = GetSpellInfo(265202)
		PrRhapsody = GetSpellInfo(390622)
		PrLightweav = GetSpellInfo(390992)
		-- Shadow
		PrDispers = GetSpellInfo(47585)
		PrMFlay = GetSpellInfo(15407)
		PrMMelt = GetSpellInfo(391092)
		PrShadowForm = GetSpellInfo(232698)
		PrMindBlast = GetSpellInfo(8092)
		PrVTouch = GetSpellInfo(34914)
		PrSinPunish = GetSpellInfo(131556)
		PrVampEmbrace = GetSpellInfo(15286)
		PrVoidErup = GetSpellInfo(228260)
		PrPurify = GetSpellInfo(213634)
		PrShadIns = GetSpellInfo(375888)
		PrVoidform = GetSpellInfo(194249)
		PrShadowCrash = GetSpellInfo(205385)
		PrSArt = GetSpellInfo(205065)
		PrPsyfiend = GetSpellInfo(211522)
		PrVoidshift = GetSpellInfo(108968)
		PrLastWord = GetSpellInfo(215776)
		PrPsyHorror = GetSpellInfo(64044)
		PrVoidTor = GetSpellInfo(263165)
		PrThHarvest = GetSpellInfo(288343)
		PrDevPlague = GetSpellInfo(335467)
		PrUnfurDark = GetSpellInfo(341273)
		PrDamn = GetSpellInfo(341374)
		PrDarkThought = GetSpellInfo(341207)
		PrMindSpike = GetSpellInfo(73510)
		PrDarkAscension = GetSpellInfo(391109)
		PrDeathsent = GetSpellInfo(392511)
		PrCatharsis = GetSpellInfo(391314)
		-- DC
		PrPenance = GetSpellInfo(47540)
		PrSurgeLight = GetSpellInfo(114255)
		PrTeeth = GetSpellInfo(33206)
		PrPWB = GetSpellInfo(62618)
		PrPWRad = GetSpellInfo(194509)
		PrArchangel = GetSpellInfo(197862)
		PrDarkAngel = GetSpellInfo(197871)
		PrRapture = GetSpellInfo(47536)
		PrAton = GetSpellInfo(194384)
		PrDArt = GetSpellInfo(207946)
		PrPWicked = GetSpellInfo(204197)
		PrEvangel = GetSpellInfo(246287)
		PrWeal = GetSpellInfo(273310)
		PrInnerLight = GetSpellInfo(355897)
		PrInnerShadow = GetSpellInfo(355898)
		PrPenitent = GetSpellInfo(336009)
		PrRadProvid = GetSpellInfo(410638)
		PrShadCoven = GetSpellInfo(314867)
		-- DeathKnight
		DKIceBound = GetSpellInfo(48792)
		DKAsphyx = GetSpellInfo(108194)
		DKAMS = GetSpellInfo(48707)
		DKStrangulate = GetSpellInfo(47476)
		DKKick = GetSpellInfo(47528)
		DKReaper = GetSpellInfo(343294)
		DKChains = GetSpellInfo(45524)
		DKDesGround = GetSpellInfo(108201)
		DKSimul = GetSpellInfo(77606)
		DKOutbreak = GetSpellInfo(77575)
		DKConvers = GetSpellInfo(119975)
		DKEatPet = GetSpellInfo(48743)
		DKBloodTap = GetSpellInfo(221699)
		DKDecay = GetSpellInfo(43265)
		DKDeathStrike = GetSpellInfo(49998)
		DKBloodBoil = GetSpellInfo(50842)
		DKBloodPlague = GetSpellInfo(55078)
		DKFrostFever = GetSpellInfo(55095)
		DKCoil = GetSpellInfo(47541)
		DKGrip = GetSpellInfo(49576)
		DKSindra = GetSpellInfo(152279)
		DKAP = GetSpellInfo(57330)
		DKPlagueLeech = GetSpellInfo(123693)
		DKDarkSuccor = GetSpellInfo(101568)
		DKBStance = GetSpellInfo(48263)
		DKBloodRune = GetSpellInfo(72410)
		DKWrWalk = GetSpellInfo(212552)
		DKAMZ = GetSpellInfo(51052)
		DKDeathChil = GetSpellInfo(204085)
		DKUnhStr = GetSpellInfo(53365)
		DKRazorice = GetSpellInfo(51714)
		DKDeathAdvance = GetSpellInfo(48265)
		DKSacPact = GetSpellInfo(327574)
		DKAbomLimb = GetSpellInfo(315443)
		DKDeathDue = GetSpellInfo(324128)
		-- Unholy
		DKPetJump = GetSpellInfo(91809)
		DKGnaw = GetSpellInfo(91800)
		DKBlow = GetSpellInfo(91797)
		DKTransform = GetSpellInfo(63560)
		DKScourge = GetSpellInfo(55090)
		DKPet = GetSpellInfo(46584)
		DKSuddenDoom = GetSpellInfo(49530)
		DKFestStrike = GetSpellInfo(85948)
		DKSumGarg = GetSpellInfo(49206)
		DKVirPlague = GetSpellInfo(191587)
		DKFestWound = GetSpellInfo(38254)
		DKBlightWeapon = GetSpellInfo(194918)
		DKEpidemic = GetSpellInfo(207317)
		DKCorShield = GetSpellInfo(207319)
		DKDebInfest = GetSpellInfo(208278)
		DKHook = GetSpellInfo(212468)
		DKHuddle = GetSpellInfo(47484)
		DKProtBil = GetSpellInfo(212384)
		DKApocalypse = GetSpellInfo(220143)
		DKIgnSac = GetSpellInfo(212756)
		DKWanPlague = GetSpellInfo(199725)
		DKReanimat = GetSpellInfo(210128)
		DKNecrosis = GetSpellInfo(207346)
		DKDeadArmy = GetSpellInfo(42650)
		DKColdHeart = GetSpellInfo(248406)
		DKUnhFrenzy = GetSpellInfo(207289)
		DKUnhBlight = GetSpellInfo(115989)
		DKLichborn = GetSpellInfo(287081)
		DKCryptFever = GetSpellInfo(288849)
		DKAbomination = GetSpellInfo(288853)
		DKClawShad = GetSpellInfo(207311)
		DKVileContag = GetSpellInfo(390279)
		DKPlagueBring = GetSpellInfo(390175)
		-- Frost
		DKPillar = GetSpellInfo(51271)
		DKObliterate = GetSpellInfo(49020)
		DKObliteration = GetSpellInfo(207256)
		DKFStrike = GetSpellInfo(49143)
		DKFFog = GetSpellInfo(59052)
		DKHBlast = GetSpellInfo(49184)
		DKKillMashine = GetSpellInfo(51128)
		DKBlindSleet = GetSpellInfo(207167)
		DKScythe = GetSpellInfo(207230)
		DKWinter = GetSpellInfo(196770)
		DKGlac = GetSpellInfo(194913)
		DKFArt = GetSpellInfo(279302)
		DKChillStreak = GetSpellInfo(204160)
		-- Blood
		DKCrimson = GetSpellInfo(81141)
		DKBoneShiled = GetSpellInfo(195181)
		DKRuneTap = GetSpellInfo(194679)
		DKVamBlood = GetSpellInfo(55233)
		DKDanceWeapon = GetSpellInfo(49028)
		DKDeathCaress = GetSpellInfo(195292)
		DKHeartStrike = GetSpellInfo(206930)
		DKMarrowrend = GetSpellInfo(195182)
		DKMarkBlood = GetSpellInfo(206940)
		DKGorefiend = GetSpellInfo(108199)
		DKBonestorm = GetSpellInfo(194844)
		DKBloddrink = GetSpellInfo(206931)
		DKTombstone = GetSpellInfo(219809)
		DKTightGrasp = GetSpellInfo(143375)
		DKDeathChain = GetSpellInfo(203173)
		DKBArt = GetSpellInfo(205223)
		DKBloodMir = GetSpellInfo(206977)
		DKTaunt = GetSpellInfo(56222)
		DKTremble = GetSpellInfo(206960)
		DKConsumption = GetSpellInfo(274156)
		-- Shaman
		ShFreedom = GetSpellInfo(192077)
		ShGround = GetSpellInfo(204336)
		ShHex = GetSpellInfo(51514)
		ShFireShock = GetSpellInfo(188389)
		ShKick = GetSpellInfo(57994)
		ShPurge = GetSpellInfo(370)
		ShHealStream = GetSpellInfo(5394)
		ShHealSurge = GetSpellInfo(8004)
		ShTremor = GetSpellInfo(8143)
		ShCap = GetSpellInfo(192058)
		ShStun = GetSpellInfo(118905)
		ShWalker = GetSpellInfo(79206)
		ShAegis = GetSpellInfo(131558)
		ShGroundEffect = GetSpellInfo(8178)
		ShEarthBind = GetSpellInfo(3600)
		ShRoots = GetSpellInfo(64695)
		ShTEarthBind = GetSpellInfo(2484)
		ShFireEle = GetSpellInfo(198067)
		ShLightning = GetSpellInfo(188196)
		ShWolf = GetSpellInfo(2645)
		ShLava = GetSpellInfo(51505)
		ShEarthShock = GetSpellInfo(8042)
		ShEarthGrab = GetSpellInfo(51485)
		ShAscend = GetSpellInfo(114051)
		ShDispel = GetSpellInfo(77130)
		ShEleBlast = GetSpellInfo(117014)
		ShEarthEle = GetSpellInfo(198103)
		ShLMagma = GetSpellInfo(192222)
		ShVoodoo = GetSpellInfo(196932)
		ShSkyTotem = GetSpellInfo(204330)
		ShCSTotem = GetSpellInfo(204331)
		ShWindTotem = GetSpellInfo(204332)
		if LYMyFaction == "Alliance" then
			ShBL = GetSpellInfo(32182)
		else
			ShBL = GetSpellInfo(2825)
		end
		ShBLA = GetSpellInfo(32182)
		ShBLH = GetSpellInfo(2825)
		ShExhaus = GetSpellInfo(57723)
		ShPulver = GetSpellInfo(118345)
		ShDispelDPS = GetSpellInfo(51886)
		ShOvercharge = GetSpellInfo(273323)
		ShPrimorWave = GetSpellInfo(326059)
		ShStaticTotem = GetSpellInfo(355580)
		ShPrimalStrike = GetSpellInfo(73899)
		ShUnleashShield = GetSpellInfo(356736)
		ShTotRecall = GetSpellInfo(108285)
		ShEarthUnleash = GetSpellInfo(356738)
		ShBurrow = GetSpellInfo(409293)
		-- Restor
		ShLink = GetSpellInfo(98008)
		ShHealWave = GetSpellInfo(77472)
		ShRiptide = GetSpellInfo(61295)
		ShEarthShield = GetSpellInfo(204288)
		ShCloudBurst = GetSpellInfo(157153)
		ShHealUnleash = GetSpellInfo(73685)
		ShHealTide = GetSpellInfo(108280)
		ShHealRain = GetSpellInfo(73920)
		ShTidalWave = GetSpellInfo(51564)
		ShSpiritVigor = GetSpellInfo(171382)
		ShAncTotem = GetSpellInfo(207399)
		ShShieldTotem = GetSpellInfo(198838)
		ShCalmWater = GetSpellInfo(221677)
		ShChainHeal = GetSpellInfo(1064)
		ShRArt = GetSpellInfo(207778)
		ShWellspring = GetSpellInfo(197995)
		ShRDispel = GetSpellInfo(77130)
		ShAncProtect = GetSpellInfo(207498)
		ShGhostMist = GetSpellInfo(207351)
		ShTidebring = GetSpellInfo(236501)
		ShAncGift = GetSpellInfo(290641)
		ShFlashFlood = GetSpellInfo(280615)
		ShEarthWall = GetSpellInfo(201633)
		ShWaterShield = GetSpellInfo(79949)
		ShManaTotem = GetSpellInfo(16191)
		ShLivWeapon = GetSpellInfo(382021)
		ShNS = GetSpellInfo(378081)
		ShUndul = GetSpellInfo(200071)
		ShTidReserv = GetSpellInfo(424461)
		-- Ele
		ShQuake = GetSpellInfo(61882)
		ShThunder = GetSpellInfo(51490)
		ShLavaSurge = GetSpellInfo(77756)
		ShChainL = GetSpellInfo(188443)
		ShGaleForce = GetSpellInfo(157375)
		ShIcefury = GetSpellInfo(210714)
		ShFrostShock = GetSpellInfo(196840)
		ShTotMaster = GetSpellInfo(210643)
		ShTMaster1 = GetSpellInfo(202192)
		ShTMaster2 = GetSpellInfo(210652)
		ShTMaster3 = GetSpellInfo(210658)
		ShTMaster4 = GetSpellInfo(210659)
		ShLightLasso = GetSpellInfo(204437)
		ShEarthFury = GetSpellInfo(204399)
		ShMeteorit = GetSpellInfo(231396)
		ShLavaShock = GetSpellInfo(273453)
		ShSurgePow = GetSpellInfo(285514)
		ShStormKeeper = GetSpellInfo(191634)
		ShMagmaChamber = GetSpellInfo(381932)
		ShMasterElem = GetSpellInfo(16166)
		ShStormEle = GetSpellInfo(192249)
		ShPowMaels = GetSpellInfo(191861)
		ShFluxMelt = GetSpellInfo(381776)
		-- Ench
		ShLavaLash = GetSpellInfo(60103)
		ShStormStrike = GetSpellInfo(17364)
		ShFeralSpirit = GetSpellInfo(51533)
		ShAG = GetSpellInfo(108281)
		ShSWalk = GetSpellInfo(58875)
		ShLShield = GetSpellInfo(192106)
		ShCrashLight = GetSpellInfo(187874)
		ShFlameTon = GetSpellInfo(318038)
		ShAstralShift = GetSpellInfo(108271)
		ShBlink = GetSpellInfo(196884)
		ShSunder = GetSpellInfo(197214)
		ShWindRush = GetSpellInfo(192077)
		ShStormbring = GetSpellInfo(201846)
		ShHotHand = GetSpellInfo(215785)
		ShLandslide = GetSpellInfo(197992)
		ShEnArt = GetSpellInfo(204945)
		ShLashFlame = GetSpellInfo(238142)
		ShForceMount = GetSpellInfo(254308)
		ShWindfury = GetSpellInfo(33757)
		ShMaelstorm = GetSpellInfo(344179)
		ShIceStrk = GetSpellInfo(342240)
		ShFireNova = GetSpellInfo(333974)
		ShHailstorm = GetSpellInfo(334196)
		ShDoomWinds = GetSpellInfo(335902)
		ShAshenCata = GetSpellInfo(390370)
		-- Mage
		MgPoly = GetSpellInfo(118)
		MgRingFrost = GetSpellInfo(113724)
		MgRingFire = GetSpellInfo(353082)
		MgBlock = GetSpellInfo(45438)
		MgKick = GetSpellInfo(2139)
		MgBlink = GetSpellInfo(1953)
		MgTable = GetSpellInfo(42955)
		MgDrink = GetSpellInfo(167152)
		MgConeCold = GetSpellInfo(120)
		MgPurge = GetSpellInfo(30449)
		MgColdSnap = GetSpellInfo(235219)
		MgHypo = GetSpellInfo(41425)
		MgIceFloes = GetSpellInfo(108839)
		MgIceBarier = GetSpellInfo(11426)
		MgStealth = GetSpellInfo(66)
		MgFlurry = GetSpellInfo(44614)
		MgNova = GetSpellInfo(122)
		MgSlowFall = GetSpellInfo(130)
		MgTempShield = GetSpellInfo(198111)
		MgBurnDeterm = GetSpellInfo(198063)
		MgArcInt = GetSpellInfo(1459)
		MgDispel = GetSpellInfo(475)
		MgAlterTime = GetSpellInfo(108978)
		MgRadiantSpark = GetSpellInfo(307443)
		MgShiftingPower = GetSpellInfo(314791)
		MgMassBar = GetSpellInfo(414660)
		-- Frost
		MgBlizz = GetSpellInfo(190356)
		MgEle = GetSpellInfo(31687)
		MgVeins = GetSpellInfo(12472)
		MgFBolt = GetSpellInfo(116)
		MgPetFreeze = GetSpellInfo(33395)
		MgChill = GetSpellInfo(205708)
		MgPetBolt = GetSpellInfo(31707)
		MgFingers = GetSpellInfo(44544)
		MgLance = GetSpellInfo(30455)
		MgBrainFreeze = GetSpellInfo(190446)
		MgIceNova = GetSpellInfo(157997)
		MgComet = GetSpellInfo(153595)
		MgOrb = GetSpellInfo(198149)
		MgIncanter = GetSpellInfo(116267)
		MgRayFrost = GetSpellInfo(205021)
		MgIcicles = GetSpellInfo(205473)
		MgGlacSpike = GetSpellInfo(199786)
		MgFsArt = GetSpellInfo(214634)
		MgMirImage = GetSpellInfo(55342)
		MgFrozenTouch = GetSpellInfo(205030)
		MgFrostbite = GetSpellInfo(198121)
		MgGlacProc = GetSpellInfo(199844)
		MgBurstCold = GetSpellInfo(206431)
		MgIceForm = GetSpellInfo(198144)
		MgFeezRain = GetSpellInfo(240555)
		MgZannJorney = GetSpellInfo(206397)
		MgWintChill = GetSpellInfo(228358)
		MgFreezRain = GetSpellInfo(270232)
		MgFrostBomb = GetSpellInfo(390612)
		-- Fire
		MgDB = GetSpellInfo(31661)
		MgCombust = GetSpellInfo(190319)
		MgBlastWave = GetSpellInfo(157981)
		MgPyroblast = GetSpellInfo(11366)
		MgIgnition = GetSpellInfo(165979)
		MgHeatUp = GetSpellInfo(48107)
		MgPyroProc = GetSpellInfo(48108)
		MgFireBall = GetSpellInfo(133)
		MgFlameStrike = GetSpellInfo(2120)
		MgFBlast = GetSpellInfo(108853)
		MgScorch = GetSpellInfo(2948)
		MgMeteor = GetSpellInfo(153561)
		MgMeteorBurn = GetSpellInfo(155158)
		MgIgnite = GetSpellInfo(12654)
		MgLivBomb = GetSpellInfo(44457)
		MgFlameOn = GetSpellInfo(205029)
		MgCinder = GetSpellInfo(198929)
		MgFrArt = GetSpellInfo(257541)
		MgGrPyro = GetSpellInfo(203286)
		MgBlazBar = GetSpellInfo(235313)
		MgCauter = GetSpellInfo(86949)
		MgConflag = GetSpellInfo(205023)
		MgTinder = GetSpellInfo(203277)
		MgAlexFury = GetSpellInfo(235870)
		MgFurySunKing = GetSpellInfo(383883)
		-- Arcne
		MgMissile = GetSpellInfo(5143)
		MgSlow = GetSpellInfo(31589)
		MgArcOrb = GetSpellInfo(153626)
		MgBarrage = GetSpellInfo(44425)
		MgArcPower = GetSpellInfo(365350)
		MgPoM = GetSpellInfo(205025)
		MgArcCharge = GetSpellInfo(36032)
		MgArcExp = GetSpellInfo(1449)
		MgEvoc = GetSpellInfo(12051)
		MgAArt = GetSpellInfo(224968)
		MgGreatInv = GetSpellInfo(110959)
		MgMasStealth = GetSpellInfo(198158)
		MgArcBlast = GetSpellInfo(30451)
		MgSupernova = GetSpellInfo(157980)
		MgPrizBar = GetSpellInfo(235450)
		MgTempFlux = GetSpellInfo(236299)
		MgArcFam = GetSpellInfo(205022)
		MgDisplace = GetSpellInfo(195676)
		MgChronoShift = GetSpellInfo(235711)
		MgTouchMagi = GetSpellInfo(321507)
		MgArcHarmony = GetSpellInfo(332769)
		-- Warlock
		WlFear = GetSpellInfo(5782)
		WlCoil = GetSpellInfo(6789)
		WlDrainSoul = GetSpellInfo(198590)
		WlDrainLife = GetSpellInfo(234153)
		WlGates = GetSpellInfo(111771)
		WlHowl = GetSpellInfo(5484)
		WlSF = GetSpellInfo(30283)
		WlAxes = GetSpellInfo(89766)
		WlKickPetFH = GetSpellInfo(132409)
		WlPetAbility = GetSpellInfo(119898)
		WlDispelPet = GetSpellInfo(89808)
		WlDispelPet2 = GetSpellInfo(115276)
		WlTP1 = GetSpellInfo(48018)
		WlTP2 = GetSpellInfo(48020)
		WlHS = GetSpellInfo(5512)
		WlCorrupt = GetSpellInfo(172)
		WlSac = GetSpellInfo(108503)
		WlSacBuff = GetSpellInfo(196099)
		WlRegen = GetSpellInfo(108359)
		WlBurning = GetSpellInfo(111400)
		WlBanish = GetSpellInfo(710)
		WlSoulwell = GetSpellInfo(29893)
		WlTap = GetSpellInfo(1454)
		WlTapBuff = GetSpellInfo(235156)
		WlSummonKickPet = GetSpellInfo(691)
		WlSummonTankPet = GetSpellInfo(697)
		WlSummonDispelPet = GetSpellInfo(688)
		WlSummonFelImpPet = GetSpellInfo(111859)
		WlSummonObserverPet = GetSpellInfo(112869)
		WlSummonVoidPet = GetSpellInfo(112867)
		WlSummonSucPet = GetSpellInfo(366222)
		WlCauterize = GetSpellInfo(119899)
		WlSacShield = GetSpellInfo(108416)
		WlMA = GetSpellInfo(104773)
		WlTrinketPet = GetSpellInfo(89792)
		WlKickPet = GetSpellInfo(111897)
		WlNetherWard = GetSpellInfo(212295)
		WlCurTongue = GetSpellInfo(199890)
		WlCurWeak = GetSpellInfo(199892)
		WlCurFrag = GetSpellInfo(199954)
		WlSeduction = GetSpellInfo(6358)
		WlInfAwake = GetSpellInfo(22703)
		WlBreath = GetSpellInfo(5697)
		WlSumPet = GetSpellInfo(79597)
		WlDeadArmor = GetSpellInfo(285933)
		WlDevMagic = GetSpellInfo(19505)
		WlFelDomin = GetSpellInfo(333889)
		WlEyeKilrogg = GetSpellInfo(126)
		WlCurExhaus = GetSpellInfo(334275)
		WlAmpCurse = GetSpellInfo(328774)
		WlSoulRot = GetSpellInfo(325640)
		WlSoulRip = GetSpellInfo(410598)
		WlWhiplash = GetSpellInfo(6360)
		WlHealthFunnel = GetSpellInfo(755)
		WlPrecogn = GetSpellInfo(377360)
		WlSoulBurn = GetSpellInfo(385899)
		-- Destro
		WlChaosBolt = GetSpellInfo(116858)
		WlImmolate = GetSpellInfo(348)
		WlChaos = GetSpellInfo(80240)
		WlConflag = GetSpellInfo(17962)
		WlEmber = GetSpellInfo(17877)
		WlIncin = GetSpellInfo(29722)
		WlBackdraft = GetSpellInfo(117828)
		WlCata = GetSpellInfo(152108)
		WlDemFire = GetSpellInfo(196447)
		WlDimRift = GetSpellInfo(196586)
		WlFirestone = GetSpellInfo(212284)
		WlBaneHavoc = GetSpellInfo(200546)
		WlKickTalent = GetSpellInfo(212619)
		WlRainFire = GetSpellInfo(5740)
		WlChaotic = GetSpellInfo(278748)
		-- Afli
		WlHaunt = GetSpellInfo(48181)
		WlUnstable = GetSpellInfo(30108)
		WlAgony = GetSpellInfo(980)
		WlSSwap = GetSpellInfo(86121)
		WlSeed = GetSpellInfo(27243)
		WlPhantomSingul = GetSpellInfo(205179)
		WlMetStrike = GetSpellInfo(171017)
		WlShadLock = GetSpellInfo(171138)
		WlCripple = GetSpellInfo(170995)
		WlSumDoom = GetSpellInfo(157757)
		WlSumInf = GetSpellInfo(157898)
		WlAArt = GetSpellInfo(216698)
		WlTorSouls = GetSpellInfo(216695)
		WlDeadwind = GetSpellInfo(216708)
		WlCastCircle = GetSpellInfo(221703)
		WlCompHorror = GetSpellInfo(199282)
		WlEsDrain = GetSpellInfo(221711)
		WlGrimService = GetSpellInfo(108501)
		WlNighfall = GetSpellInfo(248813)
		WlVileTaint = GetSpellInfo(278350)
		WlInevDemise = GetSpellInfo(273521)
		WlMalRapture = GetSpellInfo(324536)
		WlMalefWrath = GetSpellInfo(337125)
		WlTormCres = GetSpellInfo(387079)
		WlMaelAffli = GetSpellInfo(389761)
		WlDreadTouch = GetSpellInfo(389868)
		WlSiphon = GetSpellInfo(63106)
		-- Demon
		WlGuldan = GetSpellInfo(105174)
		WlSummonDemoPet = GetSpellInfo(30146)
		WlShadowBolt = GetSpellInfo(686)
		WlSoulFire = GetSpellInfo(6353)
		WlHellfire = GetSpellInfo(1949)
		WlDoom = GetSpellInfo(603)
		WlDreadstalker = GetSpellInfo(104316)
		WlMortal = GetSpellInfo(115625)
		WlShadFlame = GetSpellInfo(205181)
		WlSumDarkglare = GetSpellInfo(205180)
		WlDemEmpower = GetSpellInfo(193396)
		WlDemwrath = GetSpellInfo(193440)
		WlImplosion = GetSpellInfo(196277)
		WlWildImp = GetSpellInfo(215818)
		WlWildImpBoss = GetSpellInfo(387445)
		WlShadInsp = GetSpellInfo(196606)
		WlDemCall = GetSpellInfo(205146)
		WlDmArt = GetSpellInfo(211714)
		WlFellLord = GetSpellInfo(212459)
		WlObservCall = GetSpellInfo(201996)
		WlDemSynergy = GetSpellInfo(171982)
		WlServFguard = GetSpellInfo(111898)
		WlSingeMagic = GetSpellInfo(212623)
		WlDemCore = GetSpellInfo(264173)
		WlBilesBomber = GetSpellInfo(267211)
		WlSumVilef = GetSpellInfo(264119)
		WlPowerSiph = GetSpellInfo(264130)
		WlSumDemTyrant = GetSpellInfo(265187)
		WlDemStrgth = GetSpellInfo(267171)
		WlFelstorm = GetSpellInfo(89751)
		WlDemonPower = GetSpellInfo(265273)
		WlGuillotine = GetSpellInfo(386833)
		WlDemonbolt = GetSpellInfo(264178)
		-- Monk
		MnLightning = GetSpellInfo(117952)
		MnSap = GetSpellInfo(115078)
		MnTP = GetSpellInfo(119996)
		MnTPPlace = GetSpellInfo(101643)
		MnKick = GetSpellInfo(116705)
		MnKillShot = GetSpellInfo(115080)
		MnTaunt = GetSpellInfo(115546)
		MnSpin = GetSpellInfo(101546)
		MnRoll = GetSpellInfo(109132)
		MnLegSwip = GetSpellInfo(119381)
		MnDzen = GetSpellInfo(124081)
		MnJab = GetSpellInfo(100780)
		MnExpelHarm = GetSpellInfo(322101)
		MnChiWave = GetSpellInfo(115098)
		MnJadeWind = GetSpellInfo(116847)
		MnChiBrew = GetSpellInfo(115399)
		MnFortBrew = GetSpellInfo(115203)
		MnChiBurst = GetSpellInfo(123986)
		MnRingPeace = GetSpellInfo(116844)
		MnDifMagic = GetSpellInfo(122783)
		MnChiTorp = GetSpellInfo(115008)
		MnFaelStomp = GetSpellInfo(388201)
		MnBoneBrew = GetSpellInfo(325216)
		MnWeaponOrder = GetSpellInfo(310454)
		MnWhiteTiger = GetSpellInfo(388686)
		MnVivaViv = GetSpellInfo(388812)
		-- MW
		MnEMist = GetSpellInfo(124682)
		MnUplift = GetSpellInfo(116670)
		MnSoothMist = GetSpellInfo(209525)
		MnRenewMist = GetSpellInfo(115151)
		MnDispel = GetSpellInfo(115450)
		MnThunderTea = GetSpellInfo(116680)
		MnXuen = GetSpellInfo(123904)
		MnRevival = GetSpellInfo(115310)
		MnCocoon = GetSpellInfo(116849)
		MnFreedom = GetSpellInfo(116841)
		MnStatue = GetSpellInfo(115313)
		MnMTea = GetSpellInfo(197908)
		MnRefWind = GetSpellInfo(196725)
		MnSongChi = GetSpellInfo(198898)
		MnInvokeChi = GetSpellInfo(325197)
		MnSphere = GetSpellInfo(205234)
		MnMArt = GetSpellInfo(205406)
		MnFortTurn = GetSpellInfo(216915)
		MnTeachMonaster = GetSpellInfo(202090)
		MnSurgOfMists = GetSpellInfo(246328)
		MnZenTea = GetSpellInfo(209584)
		MnLifeCyclEM = GetSpellInfo(197919)
		MnLifeCyclUL = GetSpellInfo(197916)
		MnChanllenged = GetSpellInfo(290512)
		MnInvokeYulon = GetSpellInfo(322118)
		MnAncTeach = GetSpellInfo(388026)
		MnLingerNumb = GetSpellInfo(336887)
		MnRestoral = GetSpellInfo(388615)
		MnZenSphere = GetSpellInfo(410777)
		MnSphereHope = GetSpellInfo(411036)
		MnSphereDespair = GetSpellInfo(411038)
		MnSheilun = GetSpellInfo(399491)
		MnAncConc = GetSpellInfo(388740)
		MnChiJiBuff = GetSpellInfo(343820)
		MnPeaceWeaver = GetSpellInfo(353313)
		-- WW
		MnFists = GetSpellInfo(113656)
		MnDisable = GetSpellInfo(116095)
		MnFlySerpent = GetSpellInfo(101545)
		MnWWking = GetSpellInfo(166646) -- old 166646
		MnKarma = GetSpellInfo(122470)
		MnSunKick = GetSpellInfo(107428)
		MnBlackout = GetSpellInfo(100784)
		MnZen = GetSpellInfo(115176)
		MnCopy = GetSpellInfo(137639)
		MnComboChi = GetSpellInfo(159407)
		MnComboBlackout = GetSpellInfo(116768)
		MnDetox = GetSpellInfo(218164)
		MnDragPunch = GetSpellInfo(152175)
		MnHitCombo = GetSpellInfo(196741)
		MnWArt = GetSpellInfo(205320)
		MnFortElix = GetSpellInfo(115) -- old 201318
		MnFireBlos = GetSpellInfo(202077)
		MnDisarm = GetSpellInfo(233759)
		MnContrMist = GetSpellInfo(233765)
		MnHidMaster = GetSpellInfo(213112)
		MnEmpCapac = GetSpellInfo(337291)
		MnTigerBrew = GetSpellInfo(247483)
		MnDanceChi = GetSpellInfo(286585)
		MnChiEnergy = GetSpellInfo(337571)
		MnAlphaTiger = GetSpellInfo(287504)
		MnPresPoint = GetSpellInfo(247255)
		MnStrkWindlord = GetSpellInfo(392983)
		MnBlackReinf = GetSpellInfo(424454)
		MnFaelExp = GetSpellInfo(395414)
		-- BM
		MnKegSmash = GetSpellInfo(121253)
		MnBreath = GetSpellInfo(115181)
		MnPureBrew = GetSpellInfo(119582)
		MnBlackoutStr = GetSpellInfo(205523)
		MnBlOxStatue = GetSpellInfo(115315)
		MnStagger1 = GetSpellInfo(124275)
		MnStagger2 = GetSpellInfo(124274)
		MnStagger3 = GetSpellInfo(124273)
		MnBArt = GetSpellInfo(214326)
		MnBlCombo = GetSpellInfo(196736)
		MnGuardian = GetSpellInfo(202162)
		MnNimbleBrew = GetSpellInfo(213658)
		MnDoubleBar = GetSpellInfo(202335)
		MnGuard = GetSpellInfo(115295)
		MnElusBraw = GetSpellInfo(195630)
		MnCelBrew = GetSpellInfo(322507)
		MnExplKeg = GetSpellInfo(325153)
		MnCelFlames = GetSpellInfo(325177)
		MnInvNiu = GetSpellInfo(132578)
		MnPressAdv = GetSpellInfo(418361)
		MnPureChi = GetSpellInfo(325092)
		-- Druid
		DrStealth = GetSpellInfo(5215)
		DrStamped = GetSpellInfo(106898)
		DrWildCharge = GetSpellInfo(102401)
		DrTyphoon = GetSpellInfo(132469)
		DrDispelCurst = GetSpellInfo(2782)
		DrRejuv = GetSpellInfo(774)
		DrCat = GetSpellInfo(768)
		DrBear = GetSpellInfo(5487)
		DrRegen = GetSpellInfo(22842)
		DrCenWard = GetSpellInfo(102351)
		DrNVigil = GetSpellInfo(124974)
		DrBash = GetSpellInfo(5211)
		DrMasRoot = GetSpellInfo(102359)
		DrWrath = GetSpellInfo(190984)
		DrClone = GetSpellInfo(33786)
		DrRoots = GetSpellInfo(339)
		DrBSkin = GetSpellInfo(22812)
		DrBlink = GetSpellInfo(102280)
		DrMush = GetSpellInfo(145205)
		DrVortex = GetSpellInfo(102793)
		DrClearCast = GetSpellInfo(16870)
		DrMF = GetSpellInfo(8921)
		DrThrash = GetSpellInfo(106830)
		DrMarkWild = GetSpellInfo(1126)
		DrTravel = GetSpellInfo(783)
		DrIncTreeForm = GetSpellInfo(117679)
		DrFlyForm = GetSpellInfo(165962)
		DrRegr = GetSpellInfo(8936)
		DrDash = GetSpellInfo(1850)
		DrInner = GetSpellInfo(29166)
		DrIronfur = GetSpellInfo(192081)
		DrSwipe = GetSpellInfo(213771)
		DrMangle = GetSpellInfo(33917)
		DrDemoRoar = GetSpellInfo(201664)
		DrOverrun = GetSpellInfo(202246)
		DrHibernate = GetSpellInfo(2637)
		DrImmob = GetSpellInfo(45334)
		DrSoothe = GetSpellInfo(2908)
		DrHeartWild = GetSpellInfo(319454)
		DrConvSpirit = GetSpellInfo(391528) -- old 323764 
		DrKeeperGrove = GetSpellInfo(353114)
		-- Feral
		DrTF = GetSpellInfo(5217)
		DrHerd = GetSpellInfo(213200)
		DrRake = GetSpellInfo(1822)
		DrShred = GetSpellInfo(5221)
		DrFBite = GetSpellInfo(22568)
		DrSavMoment = GetSpellInfo(205673)
		DrRip = GetSpellInfo(1079)
		DrMaim = GetSpellInfo(22570)
		DrKick = GetSpellInfo(106839)
		DrIncJungle = GetSpellInfo(102543)
		DrBers = GetSpellInfo(106951)
		DrDaze = GetSpellInfo(50259)
		DrSlowWounds = GetSpellInfo(48484)
		DrPredatory = GetSpellInfo(16974)
		DrSurvInst = GetSpellInfo(61336)
		DrEluneGuide = GetSpellInfo(202060)
		DrRenewal = GetSpellInfo(108238)
		DrFArt = GetSpellInfo(210722)
		DrPrimVital = GetSpellInfo(202812)
		DrRipTear = GetSpellInfo(203242)
		DrFurySwipe = GetSpellInfo(203199)
		DrEnrMaul = GetSpellInfo(236716)
		DrThorns = GetSpellInfo(305497)
		DrEnrMaim = GetSpellInfo(236026)
		DrAshamane = GetSpellInfo(210650)
		DrBloodTal = GetSpellInfo(319439)
		DrFerWound = GetSpellInfo(236020)
		DrFieryRedMaim = GetSpellInfo(212875)
		DrEarthGrasp = GetSpellInfo(236023)
		DrFeralFrenzy = GetSpellInfo(274837)
		DrIronJaws = GetSpellInfo(276021)
		DrBrSlash = GetSpellInfo(202028)
		DrRakeFer = GetSpellInfo(273339)
		DrPrimWrath = GetSpellInfo(285381)
		DrMasterInst = GetSpellInfo(273344)
		DrWildFlesh = GetSpellInfo(279527)
		DrApexPred = GetSpellInfo(339140)
		DrSudAmbush = GetSpellInfo(340698)
		DrAttunement = GetSpellInfo(410406)
		-- Moonkin
		DrSolar = GetSpellInfo(78675)
		DrSFire = GetSpellInfo(194153)
		DrSFall = GetSpellInfo(191034)
		DrSSurge = GetSpellInfo(78674)
		DrIncElune = GetSpellInfo(102560)
		DrCelAlig = GetSpellInfo(194223)
		DrEmpowered = GetSpellInfo(157228)
		DrLunarEmp = GetSpellInfo(211091)
		DrSolarEmp = GetSpellInfo(211089)
		DrSF = GetSpellInfo(164815)
		DrOwl = GetSpellInfo(24858)
		DrEluneWar = GetSpellInfo(202425)
		DrEluneWrath = GetSpellInfo(202770)
		DrStelFlare = GetSpellInfo(202347)
		DrAstralCom = GetSpellInfo(202359)
		DrBArt = GetSpellInfo(202767)
		DrFSwarm = GetSpellInfo(209749)
		DrOneth = GetSpellInfo(393942)
		DrOneth2 = GetSpellInfo(393944)
		DrBlessAnshe = GetSpellInfo(202739)
		DrBlessElune = GetSpellInfo(202737)
		DrBlessAncient = GetSpellInfo(202360)
		DrTreants = GetSpellInfo(205636)
		DrFullMoon = GetSpellInfo(202771)
		DrEmerald = GetSpellInfo(208190)
		DrIntuition = GetSpellInfo(209406)
		DrCelDwnpour = GetSpellInfo(200726)
		DrHighNoon = GetSpellInfo(279581)
		DrStrStar = GetSpellInfo(272871)
		DrLEclipse = GetSpellInfo(48518)
		DrSEclipse = GetSpellInfo(48517)
		DrWildMush = GetSpellInfo(88747)
		DrStarlord = GetSpellInfo(202345)
		-- Restor
		DrDispel = GetSpellInfo(88423)
		DrLBloom = GetSpellInfo(33763)
		DrSMend = GetSpellInfo(18562)
		DrWGrowth = GetSpellInfo(48438)
		DrIBark = GetSpellInfo(102342)
		DrTranq = GetSpellInfo(740)
		DrIncTree = GetSpellInfo(33891)
		DrGerm = GetSpellInfo(155777)
		DrSoulOfForest = GetSpellInfo(114108)
		DrOmen = GetSpellInfo(16870)
		DrOvergrowth = GetSpellInfo(203651)
		DrRArt = GetSpellInfo(208253)
		DrFlour = GetSpellInfo(197721)
		DrFocusGrowth = GetSpellInfo(203554)
		DrEarlySpring = GetSpellInfo(203624)
		DrDisentang = GetSpellInfo(233673)
		DrNourish = GetSpellInfo(289022)
		DrNS = GetSpellInfo(132158)
		DrInvigor = GetSpellInfo(392160)
		DrGroveGuard = GetSpellInfo(102693)
		-- Guard
		DrKenDream = GetSpellInfo(158501)
		DrMaul = GetSpellInfo(6807)
		DrPulver = GetSpellInfo(80313)
		DrIncUrsoc = GetSpellInfo(102558)
		DrBristFlur = GetSpellInfo(155835)
		DrDesor = GetSpellInfo(99)
		DrGArt = GetSpellInfo(200851)
		DrLunarBeam = GetSpellInfo(204066)
		DrTaunt = GetSpellInfo(6795)
		DrIntimid = GetSpellInfo(206891)
		DrEntClaws = GetSpellInfo(202226)
		DrRagFrenzy = GetSpellInfo(236153)
		DrAlphChalen = GetSpellInfo(207017)
		DrToothAndClaw = GetSpellInfo(135288)
		DrGalacticGuardian = GetSpellInfo(203964)
		DrInfectedWound = GetSpellInfo(345209)
		DrDreamCen = GetSpellInfo(372119)
		DrRaze = GetSpellInfo(400254)
		-- DH
		DHGlaive = GetSpellInfo(185123)
		DHBurst = GetSpellInfo(191427)
		DHKick = GetSpellInfo(183752)
		DHFelRush = GetSpellInfo(195072)
		DHSpectral = GetSpellInfo(188501)
		DHImprison = GetSpellInfo(217832)
		DHRevMagic = GetSpellInfo(205604)
		DHGlide = GetSpellInfo(131347)
		DHImmoAura = GetSpellInfo(258920)
		DHHunt = GetSpellInfo(323639)
		DHElysian = GetSpellInfo(306830)
		DHShiv = GetSpellInfo(219437)
		DHDemonPatrol = GetSpellInfo(339051)
		-- Havoc
		DHDemonBite = GetSpellInfo(162243)
		DHChaosStrk = GetSpellInfo(162794)
		DHEyeBeam = GetSpellInfo(198013)
		DHBladeDance = GetSpellInfo(188499)
		DHStun = GetSpellInfo(179057)
		DHBlur = GetSpellInfo(198589)
		DHDarkness = GetSpellInfo(196718)
		DHVengRetreat = GetSpellInfo(198793)
		DHFelblade = GetSpellInfo(232893)
		DHMasterGlaiv = GetSpellInfo(213405)
		DHFelBar = GetSpellInfo(211053)
		DHFelErupt = GetSpellInfo(211881)
		DHFelLance = GetSpellInfo(206966)
		DHRainAbove = GetSpellInfo(206803)
		DHHArt = GetSpellInfo(201467)
		DHBloodlet = GetSpellInfo(207690)
		DHNetherwalk = GetSpellInfo(196555)
		DHMomentum = GetSpellInfo(208628)
		DHPrepared = GetSpellInfo(203650)
		DHConsumeMagic = GetSpellInfo(278326)
		DHEssBreak = GetSpellInfo(258860)
		DHDeathSweep = GetSpellInfo(210155)
		DHGlTempest = GetSpellInfo(342817)
		DHBurnWound = GetSpellInfo(346279)
		DHUnboundChaos = GetSpellInfo(347462)
		DHGlimpse = GetSpellInfo(354489)
		DHSoulrend = GetSpellInfo(388106)
		-- Vengeance
		DHShear = GetSpellInfo(203782)
		DHSoulCleave = GetSpellInfo(228477)
		DHSigilFlame = GetSpellInfo(204596)
		DHSigilMisery = GetSpellInfo(207684)
		DHSigilSilence = GetSpellInfo(202137)
		DHDemonSpike = GetSpellInfo(203720)
		DHFieryBrand	= GetSpellInfo(204021)
		DHRazorSpike = GetSpellInfo(210003)
		DHFelDevas = GetSpellInfo(212084)
		DHSoulFrag = GetSpellInfo(203981)
		DHSpiritBomb = GetSpellInfo(247454)
		DLYrailty = GetSpellInfo(224509)
		DHBulkExtr = GetSpellInfo(320341)
		DHSoulCarve = GetSpellInfo(207407)
		DHSigilChains = GetSpellInfo(202138)
		DHDemTrample = GetSpellInfo(205629)
		DHIlGrasp = GetSpellInfo(205630)
		DHDemInf = GetSpellInfo(236189)
		DHTaunt = GetSpellInfo(185245)
		DHFrailty = GetSpellInfo(389958)
		DHInfStrike = GetSpellInfo(189110)
		--Evoker
		EvEternSurge = GetSpellInfo(382411)
		EvFireBreath = GetSpellInfo(382266)
		EvPyre = GetSpellInfo(357211)
		EvAzureStrk = GetSpellInfo(362969)
		EvDisintegr = GetSpellInfo(356995)
		EvLivFlame = GetSpellInfo(361469)
		EvVerdEmbrace = GetSpellInfo(360995)
		EvEmerBlos = GetSpellInfo(355913)
		EvDispel = GetSpellInfo(360823)
		EvDispelDPS = GetSpellInfo(365585)
		EvWingBuf = GetSpellInfo(357214)
		EvKick = GetSpellInfo(351338)
		EvTailSwipe = GetSpellInfo(368970)
		EvHover = GetSpellInfo(358267)
		EvRescue = GetSpellInfo(370665)
		EvSwoopUp = GetSpellInfo(370388)
		EvBlessBronze = GetSpellInfo(364342)
		EvTimeStop = GetSpellInfo(378441)
		EvObsidScales = GetSpellInfo(363916)
		EvRenewBlaze = GetSpellInfo(374348)
		EvLandslide = GetSpellInfo(358385)
		EvChronoLoop = GetSpellInfo(383005)
		EvTipScales = GetSpellInfo(370553)
		EvDragonrage = GetSpellInfo(375087)
		EvDeepBreath = GetSpellInfo(357210)
		EvNullShroud = GetSpellInfo(378464)
		EvSleepWalk = GetSpellInfo(360806)
		EvUnravel = GetSpellInfo(368432)
		EvFirestorm = GetSpellInfo(368847)
		EvShatStar = GetSpellInfo(370452)
		EvOppresRoar = GetSpellInfo(372048)
		EvCauterFlame = GetSpellInfo(374251)
		EvTimeSpiral = GetSpellInfo(374968)
		EvSourceMagic = GetSpellInfo(369459)
		EvZephyr = GetSpellInfo(374227)
		EvChargedBlast = GetSpellInfo(370454)
		EvFireBreathDot = GetSpellInfo(357209)
		EvLeapFlame = GetSpellInfo(369939)
		--Devas
		EvEssenceBurst = GetSpellInfo(359618)
		EvBurnout = GetSpellInfo(375802)
		--Preser
		EvDreamProject = GetSpellInfo(377509)
		EvDreamFlight = GetSpellInfo(359816)
		EvTempAnomaly = GetSpellInfo(373861)
		EvTimeDilation = GetSpellInfo(357170)
		EvDreamBreath = GetSpellInfo(355936)
		EvEcho = GetSpellInfo(364343)
		EvRevers = GetSpellInfo(366155)
		EvSpiritbloom = GetSpellInfo(367226)
		EvStasis = GetSpellInfo(370537)
		EvEmerCommun = GetSpellInfo(370960)
		EvRewind = GetSpellInfo(363534)
		--Aug
		EvBlistScale = GetSpellInfo(360827)
		EvBreathEon = GetSpellInfo(403631)
		EvEbonMight = GetSpellInfo(395152)
		EvErupt = GetSpellInfo(395160)
		EvPresc = GetSpellInfo(409311)
		EvUpheaval = GetSpellInfo(396286)
		EvTimeless = GetSpellInfo(412710)
		EvBestow = GetSpellInfo(408233)
		EvSpatPara = GetSpellInfo(406732)
		EvTimeSkip = GetSpellInfo(404977)
		EvBlackAttun = GetSpellInfo(403264)
		EvBronzeAttun = GetSpellInfo(403265)
		if LYMyClass == 2 then
			ResSpell = GetSpellInfo(212056)
			BRSpell = GetSpellInfo(391054)
		elseif LYMyClass == 5 then
			ResSpell = GetSpellInfo(212036)
		elseif LYMyClass == 6 then
			BRSpell = GetSpellInfo(61999)
		elseif LYMyClass == 7 then
			ResSpell = GetSpellInfo(212048)
		elseif LYMyClass == 9 then
			BRSpell = GetSpellInfo(20707)
		elseif LYMyClass == 10 then
			ResSpell = GetSpellInfo(212051)
		elseif LYMyClass == 11 then
			ResSpell = GetSpellInfo(212040)
			BRSpell = GetSpellInfo(20484)
		end
		listMagicCC = {
		QuakingPalm,
		WlFear,
		WlHowl,
		WlCoil,
		WlSF,
		PrChas,
		PrFear,
		PrMC,
		DrClone,
		HnTrap,
		MgPoly,
		MgRingFrost,
		MgDB,
		PlBlind,
		PlRep,
		PlHoJ,
		ShHex,
		ShStun,
		DKAsphyx,
		207167,
		DHStun,
		DHImprison,
		DHIlGrasp,
		DHFelErupt,
		MnSongChi,
		EvSleepWalk
		}
		listDHDispel = {
		HnTrap,
		PlHoJ,
		WlSF,
		WlFear,
		MgPoly,
		MgRingFrost,
		PlRep,
		WlHowl,
		PrFear,
		MnSongChi,
		EvSleepWalk,
		MgDB,
		DKStrangulate,
		DKBlindSleet,
		PrSilence
		}
		listDef = {
		WrDbS,
		WrShieldWall,
		DHBlur,
		DHRainAbove,
		DrBSkin,
		DrIBark,
		DrSurvInst,
		DrCenWard,
		HnPetSac,
		RgEvasion,
		RgSW,
		DKIceBound,
		PrTeeth,
		PrPWB,
		PrRapture,
		PrDispers,
		PrRayHope,
		PlSac,
		PlEye,
		PlDefender,
		PlGuardKings,
		WlMA,
		ShAstralShift,
		ShEarthWall,
		DKVamBlood,
		DKIceBound,
		DKAMZ,
		MnCocoon
		}
		listTrackSpells = {
		HnTrap,
		DKAsphyx,
		RgKidney,
		HnHarpoon,
		DrSolar,
		ShGround,
		WrReflect,
		WrIntervene
		}
		listNotFake = {
		WlFear,
		WlImmolate,
		WlIncin,
		MgGrPyro,
		MgScorch,
		MgFBolt
		}
		listHPalBurst = {
		PlBubble,
		PlWings,
		PlHolywar,
		PlAvenger,
		PlMA,
		PlTyrDev
		}
		listRgRoll = {
		RgBroadside,
		RgBuriedTreas,
		RgGrandMelee,
		RgRuthPrec,
		RgSkullCross,
		RgTrueBearing
		}
		listTaunt = {
		PlRep,
		MgPoly,
		ShHex,
		WlFear
		}
		listStopChannel = {
		MnSoothMist,
		WlDrainSoul,
		}
		listPvPTrinket = {
		HumanTrinket,
		PvPTrinket1,
		PvPTrinket2
		}
		listCharges = {
		DHFelRush,
		RgShStep,
		RgGrapHook
		}
		listCCInt = {
		PlRep,
		WlFear,
		DrClone,
		MgPoly,
		MgRingFrost,
		ShHex,
		WlSF,
		EvSleepWalk,
		MnSongChi
		}
		listShiftCC = {
		MgPoly,
		PlRep,
		ShHex
		}
		listSim = {
		PlRep,
		WlFear,
		DrClone,
		MgPoly,
		MgGrPyro,
		ShHex
		}
		listSWDCC = {
		MgPoly,
		PlRep,
		ShHex,
		WlFear,
		WlSeduction,
		EvSleepWalk
		}
		listRefl = {
		PlRep,
		WlFear,
		DrClone,
		HnScareBeast,
		MgPoly,
		ShHex,
		EvSleepWalk
		}
		listInstInt = {
		MnSoothMist,
		DrTranq,
		PrDivHymn
		}
		listDDInt = {
		WlChaosBolt,
		WlHaunt,
		WlUnstable,
		MgGlacSpike,
		MgGrPyro,
		ShLava,
		PrMindBlast,
		PrVoidErup,
		PrSArt,
		PrVTouch,
		PrMindGame,
		PrDamn,
		ShEleBlast,
		ShStormKeeper,
		MgArcBlast,
		MgMissile,
		MgScorch,
		MgCinder,
		MgFireBall,
		MgFsArt,
		MgFBolt,
		WlDrainSoul,
		WlShadowBolt,
		WlIncin,
		WlImmolate,
		DrWrath,
		DrSFire,
		DrBArt,
		MgAArt
		}
		listTremor = {
		WlFear,
		WlHowl,
		WrFear,
		PrFear,
		PrMindBomb,
		WlSeduction,
		MnSongChi,
		EvSleepWalk
		}
		listFear = {
		207167,
		DrClone,
		RgBlind,
		WlFear,
		WlHowl,
		WlSeduction,
		WrFear,
		MgDB,
		PrFear,
		DHSigilMisery,
		HnScatter,
		PlBlind,
		HnScareBeast,
		MnSongChi,
		EvSleepWalk
		}
		listWlCurses = {
		WlCurTongue,
		WlCurWeak,
		WlCurExhaus
		}
		listCC = {
		QuakingPalm,
		WarStomp,
		WlFear,
		WlHowl,
		WlCoil,
		WlSF,
		WlBanish,
		WlSeduction,
		WlAxes,
		WlInfAwake,
		WlMetStrike,
		PrChas,
		PrFear,
		PrMC,
		PrSinPunish,
		PrSilence,
		PrPsyHorror,
		WrBolt,
		WrFear,
		WrChargeStun,
		WrWarpath,
		WrSW,
		WrWarpath,
		DrDesor,
		DrBash,
		DrClone,
		DrSolar,
		HnTrap,
		HnIntimid,
		HnScatter,
		HnFreezArrow,
		MgPoly,
		MgRingFrost,
		MgDB,
		MnSap,
		MnLegSwip,
		PlBlind,
		PlRep,
		PlHoJ,
		RgSap,
		RgBlind,
		RgCheap,
		RgKidney,
		RgGouge,
		ShHex,
		ShStun,
		ShLightLasso,
		ShEarthFury,
		ShPulver,
		ShSunder,
		DKGnaw,
		DKBlow,
		207167,
		DKAsphyx,
		DHStun,
		DHImprison,
		DHIlGrasp,
		DHFelErupt,
		DHSigilMisery,
		PrShackle,
		EvSleepWalk,
		MnSongChi
		}
		listSacCC = {
		WlFear,
		WlHowl,
		WlInfAwake,
		PrFear,
		PlHoJ,
		ShStun,
		PrSilence,
		PrPsyHorror,
		DKAsphyx,
		DrMaim,
		DrBash,
		HnIntimid,
		MnLegSwip,
		PrMindBomb,
		RgCheap,
		RgKidney,
		WrSW,
		WrBolt,
		DHStun,
		DHIlGrasp,
		DHFelErupt,
		EvSleepWalk,
		MnSongChi
		}
		listSilence = {
		DKStrangulate,
		DrSolar,
		PrSilence,
		RgGarrotte,
		DHSigilSilence,
		PlAvShield
		}
		listIncap = {
		HnTrap,
		HnScatter,
		MgPoly,
		MgRingFrost,
		MnSap,
		PlRep,
		PrMC,
		PrChas,
		ShHex,
		WlCoil,
		QuakingPalm,
		DHImprison,
		RgGouge,
		RgSap,
		WlBanish,
		PrShackle,
		203126
		}
		listMagicKickClass = {
		2,
		5,
		6,
		7,
		8,
		9,
		12,
		13
		}
		listBers = {
		WlFear,
		WlHowl,
		PrFear,
		WrFear,
		RgGouge,
		MnSap,
		DrDesor,
		217832
		}
		listThoughtsteal = {
		DrRejuv,
		MgPoly,
		MnRenewMist,
		PlFreedom,
		PrVTouch,
		PrRenew,
		PrPenance,
		ShFrostShock,
		WlFear
		}
		listMercenary = {
		98219,
		114665,
		114662,
		98218,
		98148,
		114663,
		98171
		}
		listPlAuras = {
		PlAuraCrus,
		PlAuraDev,
		PlAuraConc,
		PlAuraRetri
		}
		listKnocks = {
		DrTyphoon,
		HnExpTrap,
		HnBurstShot,
		ShThunder
		}
		listBandage = {
		RgRupture,
		DrRip,
		DrRake,
		CutDeath,
		RgWoundPoison,
		RgCripPoison,
		}
		listISlows = {
		WrBS,
		HnFreedom,
		PlFreedom,
		PrDispers,
		PrPhatasm,
		DKDesGround,
		MnWayCrane,
		PlHalGround,
		WrThirstBattle,
		DKLichborn,
		ShWolf,
		EvHover
		}
		listIRoot = {
		WrBS,
		HnFreedom,
		PlFreedom,
		PrDispers,
		PrPhatasm,
		DKDesGround,
		MnWayCrane,
		PlHalGround
		}
		listIInteract = {
		33786,
		209753,
		203337,
		221527
		}
		listDispelIDs = {
		3355,--trap
		221527 --imprison
		}
		listCancelAOE = {
		PrFeather,
		MnSphere,
		PrShadowCrash
		}
		listIDmgAll = {
		MgBlock,
		PlBubble,
		HnDeter,
		PrDispers,
		PrPhase,
		DHNetherwalk,
		PrRedemption,
		WlBanish,
		ForgeBourne,
		DrKeeperGrove,
		ShBurrow
		}
		listICC = {
		PlUltSac,
		PrHolyWard,
		PrUltPenance,
		PrPhase,
		WrBanner,
		WrBS,
		PlSanctuary,
		DKLichborn,
		UltForm,
		DHGlimpse,
		DrKeeperGrove,
		EvNullShroud,
		WlPrecogn
		}
		listIMagic = {
		RgCloak,
		23920,
		ShGroundEffect,
		WlNetherWard,
		PrPhase,
		MnPeaceWeaver
		}
		listIPhys = {
		PlBoP,
		DHBladeDance,
		DHDeathSweep,
		PrPhase
		}
		listPurgeAlways = {
		PlBoP,
		WlNetherWard,
		MgTempShield,
		PrHolyWard,
		MgAlterTime,
		PlDivFavor,
		EvNullShroud
		}
		listIStun = {
		DKIceBound,
		DKDesGround,
		WrBS,
		PrHolyWard,
		PrUltPenance,
		DrKeeperGrove,
		UltForm,
		EvNullShroud,
		WlPrecogn
		}
		listIFear = {
		WrBers,
		ShTremor,
		WrBS,
		PrHolyWard,
		PrUltPenance,
		DrKeeperGrove,
		UltForm,
		EvNullShroud,
		WlPrecogn
		}
		listDispelCC = {
		MgDB,
		MgPoly,
		MgRingFrost,
		PlBlind,
		PlRep
		}
		listDispelFear = {
		WlHowl,
		WlFear,
		PrFear
		}
		listDispelStun = {
		DHStun,
		PlHoJ,
		PrMindBomb,
		WlCoil,
		WlSF,
		ShCap
		}
		listSlows = {
		DHRazorSpike,
		DHMasterGlaiv,
		DHDemonPatrol,
		DKChains,
		DKWinter,
		DKHeartStrike,
		DKTightGrasp,
		DKDebInfest,
		317898,
		DrDaze,
		DrSlowWounds,
		DrTyphoon,
		DrVortex,
		HnConcus,
		HnWingClip,
		HnBestCun,
		HnPetSlow,
		HnPetSlow2,
		HnFrAmmo,
		HnRootTrap,
		HnRangNet,
		MgConeCold,
		MgFBolt,
		MgFlurry,
		MgChill,
		MgBlastWave,
		MgTempFlux,
		MgSlow,
		MgChronoShift,
		MnDisable,
		MnFlySerpent,
		MnKegSmash,
		MnLingerNumb,
		PrMFlay,
		PlHindrace,
		PlRArt,
		RgPoison,
		RgSlowThrow,
		RgPistolShot,
		RgNightTer,
		RgShiv,
		ShEarthBind,
		ShQuake,
		ShThunder,
		ShFrostShock,
		WlGuldan,
		WlConflag,
		WlCurExhaus,
		WlWhiplash,
		WrHarm,
		WrPiercHowl,
		WrCharge,
		WrThunder
		}
		listFreedom = {
		ShEarthBind,
		ShQuake,
		DrSlowWounds,
		HnFrAmmo,
		PrMFlay,
		RgPoison,
		RgSlowThrow,
		ShEarthBind
		}
		listShiftSlow = {
		DKChains,
		DKHeartStrike,
		DrDaze,
		DrTyphoon,
		HnConcus,
		HnWingClip,
		HnBestCun,
		HnPetSlow,
		HnPetSlow2,
		HnFrAmmo,
		HnRangNet,
		MgConeCold,
		MgFBolt,
		MgFlurry,
		MgBlastWave,
		MgChill,
		MnDisable,
		MnFlySerpent,
		RgPoison,
		RgSlowThrow,
		PlHindrace,
		ShEarthBind,
		ShThunder,
		WlGuldan,
		WlConflag,
		WrHarm,
		WrPiercHowl,
		WrThunder
		}
		listRoots = {
		DKDeathChil,
		DrRoots,
		DrMasRoot,
		DrImmob,
		MgPetFreeze,
		MgNova,
		MgGlacSpike,
		MgFrostbite,
		HnTrackerNet,
		HnRangerNet,
		HnSSTar,
		HnHarpoon,
		HnSteelTrap,
		ShRoots,
		ShEarthUnleash,
		96294,
		116706,
		117526
		}
		listPvERoots = {
		PileOfBones,
		StranglingRoots,
		DreadpetalPollen,
		GnarledRoots
		}
		listCastOnMove = {
		PrPenance,
		ShLightLasso,
		DrConvSpirit
		}
		listDispelRoots = {
		DrRoots,
		DrMasRoot,
		MgPetFreeze,
		MgNova,
		ShRoots
		}
		listMgFrozen = {
		MgIceNova,
		MgPetFreeze,
		MgNova,
		MgGlacSpike,
		MgWintChill,
		MgFrostbite
		}
		listRgStealth = {
		RgSubterfuge,
		RgSD,
		RgVanish,
		RgShadDuel
		}
		listBursts = {
		DKPillar,
		DKUnhFrenzy,
		DrIncElune,
		DrIncJungle,
		DrBers,
		HnBestWrath,
		HnTrueShot,
		PrVoidform,
		MgVeins,
		MgCombust,
		RgAR,
		RgShBlade,
		RgKillSpree,
		RgSD,
		WrReck,
		WrAvatar,
		DHBurst,
		MnSerenity,
		ShDoomWinds,
		ConquerorBanner
		}
		listBursts2 = {
		PlWings,
		PlHolywar,
		ShAscend,
		ShBLA,
		ShBLH
		}
		listStuns = {
		DKAsphyx,
		DKGnaw,
		DKBlow,
		DrBash,
		DrMaim,
		HnIntimid,
		MnLegSwip,
		PlHoJ,
		PrPsyHorror,
		PrCensure,
		RgCheap,
		RgKidney,
		ShStun,
		ShLightLasso,
		ShPulver,
		WlSF,
		WlAxes,
		WlInfAwake,
		WlMetStrike,
		WrSW,
		WrBolt,
		WarStomp,
		WrWarpath,
		DHStun,
		DHIlGrasp,
		DHFelErupt,
		}
		listStunsID = {
		163505,
		226943,
		103828,
		200200,
		207171,
		232055,
		287254,
		203123
		}
		listMStuns = {
		DKAsphyx,
		DKGnaw,
		DKBlow,
		DrBash,
		HnIntimid,
		MnLegSwip,
		RgCheap,
		RgKidney,
		WlAxes,
		WlInfAwake,
		WrSW,
		WrBolt,
		WarStomp,
		DHStun,
		DHBurst,
		DHIlGrasp,
		DHFelErupt
		}
		listKickChannel = {
		PrMC,
		WlSeduction,
		CyclotBlast,
		FocusEnergy
		}
		listDisarm = {
		WrDisarm,
		RgDisarm,
		MnDisarm
		}
		listMD = {
		HnTrap,
		MgPoly,
		MgRingFrost,
		PlRep
		}
		listKicks = {
		DKKick,
		MgKick,
		WlPetAbility,
		WlKickPetFH,
		WlSummonKickPet,
		WlKickTalent,
		WlKickPet,
		WrKick,
		RgKick,
		HnKick,
		HnKick2,
		PlKick,
		MnKick,
		ShKick,
		DrKick,
		DHKick
		}
		listForms = {
		DrCat,
		DrOwl,
		DrBear,
		DrTravel,
		DrIncTree,
		PlSac
		}
		listShiftForm = {
		DrCat,
		DrOwl,
		DrBear,
		DrTravel,
		ShWolf
		}
		listDemons = {
		169421,
		169425,
		168932,
		169426,
		169429,
		169428,
		169430
		}
		listStealth = {
		DrStealth,
		RgStealth,
		HnStealth,
		MgMasStealth,
		MgStealth,
		ShadowMeld
		}
		listIKick = {
		PlBubble,
		WlMA,
		PrPWConcen,
		ShAncGift,
		DrKeeperGrove,
		WlPrecogn
		}
		listDispelAbilities = {
		PlDispel,
		PrDispel,
		ShRDispel,
		MnDispel,
		DrDispel
		}
		listBlink = {
		MgBlink,
		ShThunder,
		DrBlink,
		HnBlink,
		HnExpTrap
		}
		listBlinkChase = {
		WrCharge,
		RgShStep,
		DrBlink,
		DrWildCharge,
		MnRoll
		}
		listGapCloser = {
		WrCharge,
		WrLeap,
		RgShStep,
		DrBlink,
		DrWildCharge,
		MnRoll,
		DHHunt,
		}
		listDontCastTwice = {
		DrStealth,
		RgStealth,
		MgAlterTime,
		MgBlink,
		PrTeeth
		}
		listRetrySpell = {
		MgBlock,
		PlBubble,
		HnDeter,
		PrDispers,
		DHNetherwalk,
		}
		listCastWhileKicked = {
		ShHex,
		DrClone,
		MgPoly
		}
		listDemonID = {
		169421,
		169425,
		168932,
		169426,
		169429,
		169428,
		169430
		}
		listWlDoTs = {
		WlAgony,
		WlCorrupt
		}
		listRDruHoTs = {
		DrRejuv,
		DrLBloom
		}
		listDoTs = {
		DKBloodPlague,
		DKFrostFever,
		DKVirPlague,
		DHBloodlet,
		DHSoulCarve,
		DrMF,
		DrSF,
		DrStelFlare,
		DrRip,
		DrRake,
		DrThrash,
		HnSerpent,
		HnCrows,
		HnBlackArrow,
		HnLacer,
		HnSerpent,
		HnExpTrap,
		HnCaltrops,
		HnOnTrail,
		HnDragon,
		MnKarma,
		MgIgnite,
		MgLivBomb,
		MgConflag,
		MgMeteorBurn,
		MgFlameStrike,
		PlConsec,
		PrVTouch,
		PrSWP,
		RgHemor,
		RgDeadlyPoison,
		RgGarStrike,
		RgRupture,
		RgIntBleed,
		RgSepsis,
		RgCreeping,
		ShFireShock,
		WlAgony,
		WlCorrupt,
		WlUnstable,
		WlPhantomSingul,
		WlDoom,
		WlShadFlame,
		WlImmolate,
		WrWounds,
		WrDoT,
		OrbPower,
		AlyFlag,
		HordeFlag
		}
		listFlags = {
		HordeFlag,
		AlyFlag,
		OrbPower
		}
		listMDoTs = {
		WlAgony,
		WlCorrupt,
		WlUnstable,
		WlImmolate,
		DrMF,
		DrSF,
		PrVTouch,
		PrSWP,
		ShFireShock,
		MgPyroblast,
		MgIgnite,
		MgLivBomb
		}
		listPauseRotation = {
		DrinkMana,
		MgDrink,
		MgBlock,
		PrDispers,
		HnDeter,
		MgGreatInv,
		DHNetherwalk,
		HnFD,
		DrTravel
		}
		listWlSummon = {
		WlSummonKickPet,
		WlSummonTankPet,
		WlSummonDispelPet,
		WlSummonFelImpPet,
		WlSummonObserverPet,
		WlSummonVoidPet,
		WlSumDoom,
		WlSumInf,
		WlSummonDemoPet,
		WlSummonSucPet
		}
		listAreanRdy = {
		ArenaPrepBuff,
		RgPrep,
		SpiritHeal,
		HonorlessTarget
		}
		listPlSBlessings = {
		PlBlessAut,
		PlBlessSpr,
		PlBlessSum,
		PlBlessWin
		}
		list6yaKick = {
		"WARRIOR",
		"MONK",
		"ROGUE",
		"PALADIN",
		"HUNTER"
		}
		list15CDKick = {
		WrKick,
		PlKick,
		RgKick,
		MnKick,
		DrKick,
		DHKick,
		HnKick,
		DKKick,
		ShKick
		}
		list24CDKick = {
		MgKick,
		HnKick2,
		EvKick
		}
		list2SecKick = {
		ShKick
		}
		list4SecKick = {
		EvKick
		}
		list3SecKick = {
		HnKick,
		HnKick2,
		DHKick,
		WrKick,
		PlKick,
		RgKick,
		DKKick,
		MnKick,
		DrKick
		}
		list5SecKick = {
		MgKick,
		WlKickPetFH,
		WlKickPet,
		DrSolar
		}
		listBeamClasses = {
		"DEATHKNIGHT",
		"SHAMAN",
		"MAGE",
		"PRIEST",
		"DRUID",
		"PALADIN",
		"WARLOCK"
		}
		listBobbers = {
		"é±¼æ¼",
		"æµ®æ¨",
		"Fishing Bobber",
		"Schwimmer",
		"Flotteur",
		"ÐÐ¾Ð¿Ð»Ð°Ð²Ð¾Ðº",
		"Corcho de pesca",
		"Galleggiante",
		"ëìì°",
		"Flutuador de Pesca"
		}
		listPvEFinderTypes = {
		LE_LFG_CATEGORY_LFD,
		LE_LFG_CATEGORY_LFR,
		LE_LFG_CATEGORY_RF,
		LE_LFG_CATEGORY_SCENARIO,
		LE_LFG_CATEGORY_FLEXRAID
		}
		listStaggers = {
		MnStagger1,
		MnStagger2,
		MnStagger3
		}
		listPvPZones = {
		1825, --hook point
		1505, --nagrand
		617, --dalaran sewers
		566, --eye of storm
		727, --silvershard mines
		998, --temple fotmogu
		761, --gilneas
		2106, --warsong
		726, --twin peaks
		}
		listTierSets = {
		[3] = {
			188856,
			188861,
			188860,
			188859,
			188858
			},
		[4] = {
			207234,
			207235,
			207236,
			207237,
			207239
			},
		[5] = {
			207281,
			207279,
			207284,
			207282,
			207280
			},
		[6] = {
			188868,
			188867,
			188866,
			188864,
			188863
			},
		[7] = {
			207207,
			207208,
			207209,
			207210,
			207212
			}
		}
		listDummies = {
		79987,
		92169,
		96442,
		109595,
		113963,
		131985,
		131990,
		132976,
		17578,
		60197,
		64446,
		144077,
		44171,
		44389,
		44848,
		44548,
		44614,
		44703,
		44794,
		44820,
		44937,
		48304,
		32541,
		32545,
		32666,
		32542,
		32667,
		32543,
		31144,
		32546,
		46647,
		67127,
		79414,
		87317,
		87321,
		87760,
		88289,
		88316,
		88835,
		88906,
		88967,
		89078,
		92164,
		92165,
		92167,
		92168,
		100440,
		100441,
		102045,
		102048,
		102052,
		103402,
		103404,
		107483,
		107555,
		107557,
		108420,
		111824,
		113674,
		113676,
		113687,
		113858,
		113859,
		113862,
		113863,
		113871,
		113966,
		113967,
		114832,
		114840,
		87318,
		87322,
		87761,
		88288,
		88314,
		88836,
		93828,
		97668,
		98581,
		126781,
		131989,
		131994,
		144082,
		144085,
		144081,
		153285,
		153292,
		131997,
		131998,
		144074,
		131992,
		132036,
		144078,
		144075,
		24792,
		30527,
		31146,
		87320,
		87329,
		87762,
		88837,
		92166,
		101956,
		103397,
		107202,
		107484,
		107556,
		113636,
		113860,
		113864,
		70245,
		113964,
		131983,
		144086,
		198594,
		194646
		}
		ActionBarButtonNames = {
			"ActionButton",
			"MultiBarBottomLeftButton",
			"MultiBarBottomRightButton",
			"MultiBarLeftButton",
			"MultiBarRightButton",
			"MultiBar5Button",
			"MultiBar6Button",
			"MultiBar7Button"
		}
		MapActionBarToBinding = {
			ActionButton1 = "ACTIONBUTTON1",
			ActionButton2 = "ACTIONBUTTON2",
			ActionButton3 = "ACTIONBUTTON3",
			ActionButton4 = "ACTIONBUTTON4",
			ActionButton5 = "ACTIONBUTTON5",
			ActionButton6 = "ACTIONBUTTON6",
			ActionButton7 = "ACTIONBUTTON7",
			ActionButton8 = "ACTIONBUTTON8",
			ActionButton9 = "ACTIONBUTTON9",
			ActionButton10 = "ACTIONBUTTON10",
			ActionButton11 = "ACTIONBUTTON11",
			ActionButton12 = "ACTIONBUTTON12",
			MultiBarBottomLeftButton1 = "MULTIACTIONBAR1BUTTON1",
			MultiBarBottomLeftButton2 = "MULTIACTIONBAR1BUTTON2",
			MultiBarBottomLeftButton3 = "MULTIACTIONBAR1BUTTON3",
			MultiBarBottomLeftButton4 = "MULTIACTIONBAR1BUTTON4",
			MultiBarBottomLeftButton5 = "MULTIACTIONBAR1BUTTON5",
			MultiBarBottomLeftButton6 = "MULTIACTIONBAR1BUTTON6",
			MultiBarBottomLeftButton7 = "MULTIACTIONBAR1BUTTON7",
			MultiBarBottomLeftButton8 = "MULTIACTIONBAR1BUTTON8",
			MultiBarBottomLeftButton9 = "MULTIACTIONBAR1BUTTON9",
			MultiBarBottomLeftButton10 = "MULTIACTIONBAR1BUTTON10",
			MultiBarBottomLeftButton11 = "MULTIACTIONBAR1BUTTON11",
			MultiBarBottomLeftButton12 = "MULTIACTIONBAR1BUTTON12",
			MultiBarBottomRightButton1 = "MULTIACTIONBAR2BUTTON1",
			MultiBarBottomRightButton2 = "MULTIACTIONBAR2BUTTON2",
			MultiBarBottomRightButton3 = "MULTIACTIONBAR2BUTTON3",
			MultiBarBottomRightButton4 = "MULTIACTIONBAR2BUTTON4",
			MultiBarBottomRightButton5 = "MULTIACTIONBAR2BUTTON5",
			MultiBarBottomRightButton6 = "MULTIACTIONBAR2BUTTON6",
			MultiBarBottomRightButton7 = "MULTIACTIONBAR2BUTTON7",
			MultiBarBottomRightButton8 = "MULTIACTIONBAR2BUTTON8",
			MultiBarBottomRightButton9 = "MULTIACTIONBAR2BUTTON9",
			MultiBarBottomRightButton10 = "MULTIACTIONBAR2BUTTON10",
			MultiBarBottomRightButton11 = "MULTIACTIONBAR2BUTTON11",
			MultiBarBottomRightButton12 = "MULTIACTIONBAR2BUTTON12",
			MultiBarLeftButton1 = "MULTIACTIONBAR4BUTTON1",
			MultiBarLeftButton2 = "MULTIACTIONBAR4BUTTON2",
			MultiBarLeftButton3 = "MULTIACTIONBAR4BUTTON3",
			MultiBarLeftButton4 = "MULTIACTIONBAR4BUTTON4",
			MultiBarLeftButton5 = "MULTIACTIONBAR4BUTTON5",
			MultiBarLeftButton6 = "MULTIACTIONBAR4BUTTON6",
			MultiBarLeftButton7 = "MULTIACTIONBAR4BUTTON7",
			MultiBarLeftButton8 = "MULTIACTIONBAR4BUTTON8",
			MultiBarLeftButton9 = "MULTIACTIONBAR4BUTTON9",
			MultiBarLeftButton10 = "MULTIACTIONBAR4BUTTON10",
			MultiBarLeftButton11 = "MULTIACTIONBAR4BUTTON11",
			MultiBarLeftButton12 = "MULTIACTIONBAR4BUTTON12",
			MultiBarRightButton1 = "MULTIACTIONBAR3BUTTON1",
			MultiBarRightButton2 = "MULTIACTIONBAR3BUTTON2",
			MultiBarRightButton3 = "MULTIACTIONBAR3BUTTON3",
			MultiBarRightButton4 = "MULTIACTIONBAR3BUTTON4",
			MultiBarRightButton5 = "MULTIACTIONBAR3BUTTON5",
			MultiBarRightButton6 = "MULTIACTIONBAR3BUTTON6",
			MultiBarRightButton7 = "MULTIACTIONBAR3BUTTON7",
			MultiBarRightButton8 = "MULTIACTIONBAR3BUTTON8",
			MultiBarRightButton9 = "MULTIACTIONBAR3BUTTON9",
			MultiBarRightButton10 = "MULTIACTIONBAR3BUTTON10",
			MultiBarRightButton11 = "MULTIACTIONBAR3BUTTON11",
			MultiBarRightButton12 = "MULTIACTIONBAR3BUTTON12"
		}
		KeyBinds = {
		0x51,
		0x57,
		0x45,
		0x41,
		0x53,
		0x44,
		0x20,
		0x30,
		0x31,
		0x32,
		0x33,
		0x34,
		0x35,
		0x36,
		0x37,
		0x38,
		0x42,
		0x43,
		0x46,
		0x47,
		0x48,
		0x52,
		0x54,
		0x56,
		0x58,
		0x59,
		0x5A,
		0x70,
		0x71,
		0x72,
		0x73,
		0x74,
		}
		BLKeyBinds = {
		"Q",
		"W",
		"E",
		"A",
		"S",
		"D",
		"SPACE",
		"0",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"B",
		"C",
		"F",
		"G",
		"H",
		"R",
		"T",
		"V",
		"X",
		"Y",
		"Z",
		"F1",
		"F2",
		"F3",
		"F4",
		"F5"
		}
		for t=1,8 do
			local tempKey = select(3,GetBinding(t))
			for u=1,#BLKeyBinds do
				if BLKeyBinds[u] == tempKey then
					KeyBinds[u] = nil
				end
			end
		end
		setmetatable(LYL,{
			__index = function(t,k)
				rawset(t,k,k)
				return k
			end,
			__newindex = function(t,k,v)
				rawset(t,k,v)
			end
		})
	end
	function ResetLYTables()
		LYMyLevel = UnitLevel("player")
		LYLastSpellName = nil
		LYCurrentSpellName = nil
		if not LYKickDelay then
			LYKickDelay = 125
		end
		KickDelayFixed = math.random(LYKickDelay,LYKickDelay+300)
		LYPurifySoulCount = GetItemCount(177278)
		KicksData = {}
		LYUnitAbilityUsedTime = {}
		DR = {}
		LockTime = {}
		RecordMove = {}
		LYRecordHP = {}
		LYSpellQueue = {}
		LastTimeLYUpdated = 0
		LYTotemTime = 0
		FakeCount = 1
		LYCastTimer = 0
		LYFrameOptimal = GetTime()
		PauseGCD = 0
		KickTime = 0
		LYGCDTime = 1.5
		TimerPrint = {}
		TimerPrintTime = 0
		PetBehTimer = 0
		RecordTime = 0
		LYKickPause = 0
		LYSwingTimer = 0
		HSUsed = 0
		LYWlPetsTime = 0
		LYWlPetsCount = 0
		LYMyPing = 100
		NextKick = nil
		LYInBossFight = nil
		LYLoS = {}
		LYFace = {}
		MnGetStatue = {}
		LYOldGCD = nil
		LYStayForm = nil
		LYHDPS = nil
		LastAlterTime = 0
		LastStealth = 0
	end
	--Macros
	function LY_BlinkCC(action)
		local s = string.find(action,"@")
		local e = string.find(action,"]")
		local target = ""
		if s and e then
			target = string.sub(action,s+1,e-1)
		else
			target = "target"
		end
		if target == "ehealer" and LYEnemyHealers then
			for i=1,#LYEnemyHealers do
				if UnitIsVisible(LYEnemyHealers[i]) then
					target = LYEnemyHealers[i]
				end
			end
		end
		if UnitIsVisible(target) then
			MgBlinkDB(target)
		end
	end
	function LY_Next(action)
		if not action then
			return
		end
		if action == "kickcc" then
			if NextKick == "CC" then
				NextKick = nil
				LY_Print("Disable next kick","red")
			else
				NextKick = "CC"
				LY_Print("Kicking next CC","green")
			end
		elseif action == "kickheal" then
			if NextKick == "heal" then
				NextKick = nil
				LY_Print("Disable next kick","red")
			else
				NextKick = "heal"
				LY_Print("Kicking next heal","green")
			end
		elseif string.find(action,"stun") then
			if LYNextStun then
				LYNextStun = nil
				LY_Print("Stun canceled","red")
				return
			end
			local s = string.find(action,"@")
			local e = string.find(action,"]")
			if s and e then
				LYNextStun = string.sub(action,s+1,e-1)
			else
				LYNextStun = "target"
			end
			LY_Print("Queue stun","green")
		elseif action == "jump" then
			PauseGCD = GetTime() + 1
			if LYMyClass == 3 then
				if C_Spell.GetSpellCooldown(HnBlink).startTime == 0 and (not IsRooted() or IsTalentInUse(109215)) then
					StopMoving(true)
					FaceDirection(mod(ObjectFacing("player") + math.pi,math.pi * 2),true)
					LYSpellStopCasting()
					C_Timer.After(LYMyPing*2,function() CastSpellByName(HnBlink) FaceDirection(mod(ObjectFacing("player") + math.pi,math.pi * 2),true) end)
					return
				end
			elseif LYMyClass == 8 and C_Spell.GetSpellCooldown(MgBlink).startTime == 0 then
				if IsTalentInUse(212653) then
					CastSpellByName(MgBlink)
				else
					LYSpellStopCasting()
					LYQueueSpell(MgBlink)
				end
				return
			elseif LYMyClass == 10 and C_Spell.GetSpellCooldown(MnRoll).startTime == 0 then
				LYSpellStopCasting()
				CastSpellByName(MnRoll)
				return
			elseif LYMyClass == 12 and C_Spell.GetSpellCooldown(DHVengRetreat).startTime == 0 and not IsRooted() and not IsFalling() then
				StopMoving(true)
				FaceDirection(mod(ObjectFacing("player") + math.pi,math.pi * 2),true)
				LYSpellStopCasting()
				C_Timer.After(LYMyPing*2,function() CastSpellByName(DHVengRetreat) FaceDirection(mod(ObjectFacing("player") + math.pi,math.pi * 2),true) end)
				return
			end
		elseif action == "purge" then
			if ForcePurge then
				ForcePurge = nil
				LY_Print("Stop purging","red")
			elseif UnitIsVisible("target") and UnitCanAttack("player","target") then
				ForcePurge = "target"
				LY_Print("Start purging","green")
			end
			return
		elseif action == "door" and CDCheck(DoorShadows) and not IsRooted() and not IsMoving() then
			if UnitIsVisible("target") then
				if IsInDistance("target",33,"player") and InLineOfSight("target","player") then
					LYSpellStopCasting()
					LYQueueSpell(DoorShadows,"target")
				else
					local x,y,z = GetPositionBetweenObjects("player","target",33)
					if x then
						LYSpellStopCasting()
						LYQueueSpell(DoorShadows,"point",x,y,z)
					end
				end
			else
				LYSpellStopCasting()
				LYQueueSpell(DoorShadows,"cursor")
			end
			return
		end
	end
	function LY_StartStop()
		if LYStart then
			LYStart = false
			LYMinimapIcon:SetTexture("Interface/Icons/spell_arcane_portalorgrimmar")
			ResetLYTables()
		else
			LYStart = true
			LYMinimapIcon:SetTexture("Interface/Icons/spell_arcane_portalstonard")
		end
	end
	function LY_Burst(par)
		if LYPlayerRole ~= "HEALER" then
			if not LYBurstMacro then
				DoNotUsePower = nil
				LYBurstMacro = GetTime() + 30
				if LYMode ~= "PvP" and IsUsableItem(191383) and GetItemCooldown(191383) == 0 and UnitAffectingCombat("player") then
					local pot = GetItemInfo(191383)
					if not tContains(LYBLSpells,pot) then
						UseItemByName(191383)
					end
				end
				LY_Print("Burst is ACTIVATED","green")
				if par and LYStyle == "All units" then
					LYStyle = "Only target"
					C_Timer.After(30,function() LYStyle = "All units" end)
				end
				if not LYStart then
					LY_StartStop()
				end
			else
				LYBurstMacro = nil
				LY_Print("Burst is DEACTIVATED","red")
				if par and LYStyle == "Only target" then
					LYStyle = "All units"
				end
			end
		else
			LY_Print("There is no BURST mode for your spec","red")
		end
	end
	function LY_Style()
		if LYStyle == "All units" then
			LYStyle = "Only target"
			LY_Print("Only TARGET","red")
		elseif LYStyle == "Only target" then
			LYStyle = "All units"
			LY_Print("ALL units","green")
		end
	end
	function LY_AutoFace()
		if LYFacing then
			LYFacing = false
			LY_Print("AutoFacing is DISABLED","red")
		else
			LYFacing = true
			LY_Print("AutoFacing is ENABLED","green")
		end
	end
	function LY_Kick()
		if LYKickStop then
			LYKickStop = false
			LY_Print("AutoKick is ENABLED","green")
		else
			LYKickStop = true
			LY_Print("AutoKick is DISABLED","red")
		end
	end
	function LY_SmartFake()
		if LYFake then
			LYFake = false
			LY_Print("Smart fake is DISABLED","red")
		else
			LYFake = true
			LY_Print("Smart fake is ENABLED","green")
		end
	end
	function LY_DoTHealer()
		if LYDoTEHeal then
			LYDoTEHeal = false
			LY_Print("Do NOT DoT healer","red")
		else
			LYDoTEHeal = true
			LY_Print("Attack healer","green")
		end
	end
	function LY_Slow()
		if LYSlowAlways then
			LYSlowAlways = false
			LY_Print("Slow target is DISABLED","red")
		else
			LYSlowAlways = true
			LY_Print("Slow target is ENABLED","green")
		end
	end
	function LY_PetOnHealer()
		if LYPetOnHealer then
			LYPetOnHealer = false
			LY_Print("Pet Attack Healer is DISABLED","red")
		else
			LYPetOnHealer = true
			LY_Print("Pet Attack Healer is ENABLED","green")
		end
	end
	function LY_MiniMap()
		if LYMinimapIcon:IsVisible() then
			LYMinimapIcon:Hide()
			LY_Print("Hide minimap","red")
		else
			LYMinimapIcon:Show()
			LY_Print("Show minimap","green")
		end
	end
	function LY_Debug()
		if LYDebug then
			LYDebug = false
			LY_Print("DEBUG is DISABLED","red")
		else
			LYDebug = true
			LY_Print("DEBUG is ENABLED","green")
		end
	end
	function LY_DoNotUsePower(burst)
		if DoNotUsePower then
			DoNotUsePower = false
			LY_Print("Stop saving power/combo","green")
		else
			if LYMyClass == 4 or (LYMyClass == 11 and LYMySpec == 2) or LYMyClass == 10 then
				DoNotUsePower = LYCPMax
			else
				DoNotUsePower = LYUPMax
			end
			if burst then
				DoNotUsePowerBurst = true
				LY_Print("Saving power/combos and autoburst","red")
			else
				LY_Print("Saving power/combos","red")
			end
		end
	end
	function LY_Gate()
		local gates
		for i=1,GetObjectCount() do
			local pointer = GetObjectWithIndex(i)
			if ObjectId(pointer) == 59262 or ObjectId(pointer) == 59271 then
				local creator = UnitCreator(pointer)
				if UnitIsVisible(creator) and not UnitCanAttack("player",creator) then
					gates = true
					if IsInDistance(pointer,10) then
						ObjectInteract(pointer)
						ObjectInteract(pointer)
						return
					end
				end
			end
		end
		if not gates and GCDCheck(WlGates) then
			LYSpellStopCasting()
			LYQueueSpell(WlGates)
			return
		end
	end
	function LY_TrueTrinket()
		if LYMyClass == 6 then
			if GCDCheck(DKIceBound) and UnitIsStunned("player") and not HaveDebuff("player",listSilence) then
				CastSpellByName(DKIceBound)
				LY_Print(DKIceBound,"green")
				return
			end
			if GCDCheck(DKLichborn) and HaveDebuff("player",listBers) and not HaveDebuff("player",listSilence) then
				CastSpellByName(DKLichborn)
				LY_Print(DKLichborn,"green")
			end
			if GCDCheck(DKWrWalk) and IsRooted() then
				CastSpellByName(DKWrWalk)
				LY_Print(DKWrWalk,"green")
				return
			end
		end
		if LYMyClass == 11 and IsRooted() then
			if GetShapeshiftForm() == 0 then
				LYQueueSpell(DrBear)
			else
				CancelShapeshiftForm()
			end
			return
		end
		if GCDCheck(WillForsaken) and HaveDebuff("player",listBers) then
			CastSpellByName(WillForsaken)
			LY_Print(WillForsaken,"green")
			return
		end
		if GCDCheck(HumanTrinket) and UnitIsStunned("player") and not HaveDebuff("player",listSilence) then
			CastSpellByName(HumanTrinket)
			LY_Print(HumanTrinket,"green")
			return
		end
		if UnitIsCCed("player") or HaveDebuff("player",listSilence) or IsRooted() or HaveDebuff("player",listDisarm) or not HasFullControl() then
			local name1 = GetItemInfo(209764)
			local name2 = GetItemInfo(208683)
			UseItemByName(name1)
			UseItemByName(name2)
			LY_Print("Trinket CC","green")
		end
	end
	function LY_ForceCast(arg)
		if not arg or not LYTeamPlayers then
			return
		end
		local function IsHealer(pointer)
			if not pointer then
				return
			end
			if pointer == "ehealer" then
				for i=1,#LYEnemyHealers do
					if UnitIsVisible(LYEnemyHealers[i]) then
						return LYEnemyHealers[i]
					end
				end
			elseif pointer == "fhealer" then
				for i=1,#LYTeamHealers do
					if UnitIsVisible(LYTeamHealers[i]) then
						return LYTeamHealers[i]
					end
				end
			elseif pointer == "tank" then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and UnitIsTank(LYTeamPlayers[i]) then
						return LYTeamPlayers[i]
					end
				end
			elseif pointer == "off" then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and UnitIsVisible(LYEnemyTarget) and not UnitIsUnit(LYEnemyTarget,LYEnemies[i]) and CheckRole(LYEnemies[i]) ~= "HEALER" then
						return LYEnemies[i]
					end
				end
			end
		end
		local function CheckCast(SpellName,pointer)
			if CDLeft(SpellName,true) > LYGCDTime + LYMyPing*2 + #LYSpellQueue*LYGCDTime then
				return
			end
			if not pointer or string.find(pointer,"-") then
				return true
			end
			local pointer = IsHealer(pointer) or pointer
			if pointer ~= "cursor" and (not InLineOfSight(pointer) or not IsInDistance(pointer,50)) then
				return
			end
			if SpellName == PrShield and HaveDebuff(pointer,PrWeakSoul) then
				return
			end
			return true
		end
		local function oldSpell(SpellName)
			for i=1,#LYSpellQueue do
				if LYSpellQueue[i] and LYSpellQueue[i].spell and LYSpellQueue[i].spell == SpellName then
					return true
				end
			end
		end
		local function CastSequence(spells,pointer)
			local start = 0
			local newspell,SpellName
			for i=1,string.len(spells) do
				newspell = string.find(spells,",",start)
				if newspell then
					SpellName = string.sub(spells,start+1,newspell-1)
					start = newspell+1
					if not oldSpell(SpellName) and CheckCast(SpellName,pointer) then
						tinsert(LYSpellQueue,{spell = SpellName,unit = IsHealer(pointer) or pointer,timer = GetTime()+#LYSpellQueue*LYGCDTime})
						LY_Print("Add "..SpellName.." to queue","green",SpellName)
					end
				else
					SpellName = string.sub(spells,start+1)
					if not oldSpell(SpellName) and CheckCast(SpellName,pointer) then
						tinsert(LYSpellQueue,{spell = SpellName,unit = IsHealer(pointer) or pointer,timer = GetTime()+#LYSpellQueue*LYGCDTime})
						LYSpellStopCasting()
						LY_Print("Add "..SpellName.." to queue","green",SpellName)
					end
					break
				end
			end
		end
		if string.find(arg,"]") then
			local SpellName,pointer = SecureCmdOptionParse(arg)
			if pointer == "mouseover" then
				if UnitIsVisible("mouseover") then
					pointer = GetObjectWithGUID(UnitGUID("mouseover"))
				else
					LY_Print("no @mouseover unit found. use @cursor for area spells","red")
					return
				end
			end
			if SpellName then
				if not UnitIsVisible(pointer) then
					for i=1,#LYTeamPlayers do
						if UnitIsVisible(LYTeamPlayers[i]) and UnitName(LYTeamPlayers[i]) == pointer then
							pointer = LYTeamPlayers[i]
							break
						end
					end
				end
				if string.find(SpellName,",") then
					CastSequence(SpellName,pointer)
				elseif not oldSpell(SpellName) and CheckCast(SpellName,pointer) then
					if string.lower(UnitCastingInfo("player") or "") ~= string.lower(SpellName) then
						LYSpellStopCasting()
					end
					tinsert(LYSpellQueue,{spell = SpellName,unit = IsHealer(pointer) or pointer,timer = GetTime()+#LYSpellQueue*LYGCDTime})
					LY_Print("Cast "..SpellName,"green",SpellName)
				end
			end
		elseif string.find(arg,",") then
			if LYMyClass == 10 and (GetSpellInfo(arg) == MnCopy or GetSpellInfo(arg) == MnXuen or GetSpellInfo(arg) == MnInvokeChi) then
				tinsert(LYSpellQueue,{spell = arg,unit = nil,timer = GetTime()+#LYSpellQueue*LYGCDTime})
				LYSpellStopCasting()
			end
			CastSequence(arg)
		elseif GetSpellInfo(arg) and not oldSpell(arg) and CheckCast(arg) then
			if string.lower(UnitCastingInfo("player") or "") ~= string.lower(arg) then
				LYSpellStopCasting()
			end
			if LYMyClass == 8 and GetSpellInfo(arg) == MgBlink and C_Spell.GetSpellCooldown(MgBlink).startTime == 0 and IsTalentInUse(212653) then
				CastSpellByName(MgBlink)
			end
			if LYMyClass == 10 and GetSpellInfo(arg) == MnChiTorp and C_Spell.GetSpellCooldown(MnChiTorp).startTime == 0 then
				LYSpellStopCasting()
				CastSpellByName(MnChiTorp)
			end
			tinsert(LYSpellQueue,{spell = arg,unit = nil,timer = GetTime()+#LYSpellQueue*LYGCDTime})
			LY_Print("Cast "..arg,"green",arg)
		elseif GetItemInfo(arg) then
			LYSpellStopCasting()
			PauseGCD = GetTime() + 1
			local name = GetItemInfo(arg)
			local ID
			for i=1,18 do
				ID = GetInventoryItemID("player",i)
				if ID and GetItemInfo(ID) == name then
					break
				end
			end
			if not ID then
				LY_Print("Can't perform the macro spell","red")
				return
			end
			local start,duration = GetItemCooldown(ID)
			local CD = start+duration+LYMyPing-GetTime()
			if start == 0 then
				UseItemByName(arg)
			elseif CD < LYGCDTime*2 then
				C_Timer.After(CD,function() UseItemByName(arg) end)
			end
			LY_Print("Use "..name,"red")
		else
			LY_Print("Can't perform the macro spell","red")
		end
		Dismount()
	end
	function LY_ForceCastCheck(arg)
		if not arg or not LYTeamPlayers then
			return
		end
		local function oldSpell(SpellName)
			for i=1,#LYSpellQueue do
				if LYSpellQueue[i].spell and LYSpellQueue[i].spell == SpellName then
					return true
				end
			end
		end
		local arg, space1, space2, range, count, SpellName = strtrim(arg), string.find(arg," "), nil, nil, nil, nil
		if space1 then
			space2 = string.find(arg," ",space1+1)
			if space2 then
				range = tonumber(string.sub(arg,1,space1-1))
				count = tonumber(string.sub(arg,space1+1,space2-1))
				SpellName = string.sub(arg,space2+1)
			end
		end
		if range and count and GetSpellInfo(SpellName) and not oldSpell(SpellName) and CDLeft(SpellName,true) < LYGCDTime and EnemiesAroundUnit(range) >= count then
			if UnitCastingInfo("player") ~= SpellName then
				LYSpellStopCasting()
			end
			tinsert(LYSpellQueue,{spell = SpellName,unit = nil,timer = GetTime()+LYGCDTime})
			LY_Print("Cast "..SpellName,"green",SpellName)
		else
			LY_Print("Can't perform the macro spell","red")
		end
		Dismount()
	end
	function LY_Form(form)
		local function BackToForm()
			LYSpellStopCasting()
			if LYMySpec == 1 then
				LY_ForceCast(DrOwl)
			elseif LYMySpec == 2 then
				LY_ForceCast(DrCat)
			elseif LYMySpec == 3 then
				LY_ForceCast(DrBear)
			else
				CancelShapeshiftForm()
			end
		end
		if not form or UnitIsCCed("player") or not HasFullControl() then
			return
		end
		if LYMyClass == 11 then
			if form == "cat" and LYMySpec ~= 2 then
				if GetShapeshiftForm() ~= 2 then
					LY_ForceCast(DrCat)
					LY_Print("Cat ON","green",DrCat)
					LYStayForm = DrCat
				else
					BackToForm()
					LYStayForm = nil
					LY_Print("Cat OFF","red")
				end
			elseif form == "travel" then
				if GetShapeshiftForm() ~= 3 and not IsIndoors() then
					LY_ForceCast(DrTravel)
					LY_Print("Travel ON","green",DrTravel)
					LYStayForm = DrTravel
				else
					BackToForm()
					LYStayForm = nil
					LY_Print("Travel OFF","red")
				end
			elseif form == "bear" and LYMySpec ~= 3 then
				if GetShapeshiftForm() ~= 1 then
					LY_ForceCast(DrBear)
					LY_Print("Bear ON","green",DrBear)
					LYStayForm = DrBear
				else
					BackToForm()
					LYStayForm = nil
					LY_Print("Bear OFF","red")
				end
			elseif form == "balance" and LYMySpec ~= 1 then
				if not HaveBuff("player",DrOwl) then
					LY_ForceCast(DrOwl)
					LY_Print("Owl ON","green",DrOwl)
					LYStayForm = DrOwl
				else
					BackToForm()
					LYStayForm = nil
					LY_Print("Owl OFF","red")
				end
			end
		elseif LYMyClass == 9 then
			if form == "kick" then
				LYWlPetType = 1
			elseif form == "tank" then
				LYWlPetType = 2
			elseif form == "dispel" then
				LYWlPetType = 3
			elseif form == "succubus" then
				LYWlPetType = 4
			elseif form == "guard" then
				LYWlPetType = 5
			end
			PetDismiss()
			LY_Print("Call pet "..form,"green")
		elseif LYMyClass == 7 then
			if not HaveBuff("player",ShWolf) and CDLeft(ShWolf) < 2 then
				LY_ForceCast(ShWolf)
				LY_Print("Wolf ON","green",ShWolf)
				LYStayForm = ShWolf
			else
				CancelBuffByName(ShWolf)
				LYStayForm = nil
				LY_Print("Wolf OFF","red")
			end
		elseif LYMyClass == 1 and LYMySpec ~= 3 then
			if not LYStayForm then
				LYStayForm = WrDStance
				LY_Print(WrDStance,"red",WrDStance)
			else
				LYStayForm = nil
				LY_Print(WrBStance,"green",WrBStance)
			end
		elseif LYMyClass == 5 and LYMySpec == 1 then
			if not LYStayForm then
				LYStayForm = PrInnerLight
				LY_Print("Light Form", "green")
			else
				LYStayForm = nil
				LY_Print("Shadow Form", "green")
			end
		end
	end
	function LY_HDPS()
		if LYHDPS then
			LYHDPS = nil
			LY_Print("Normal mode","green")
		elseif LYMyClass ~= 3 and LYMyClass ~= 4 and LYMyClass ~= 8 and LYMyClass ~= 9 and LYMyClass ~= 12 then
			LYHDPS = true
			LY_Print("Heal/DPS mode","red")
		else
			LY_Print("Heal/DPS mode is not supported by your class","red")
		end
	end
	--Event handler
	local failed = 0
	local timeSinceFirstFailed = 0
	local LYLastFailedSpell = nil
	local excludedSpells = {
		DrBear, DrCat, DrOwl, DrStealth, ShadowMeld, RgStealth, RgVanish, PrDispers, MgBlock
	}
	function LYFrames_OnEvent(self,event,...)
		if event == "SPELLS_CHANGED" then
			CheckPlayerTalents()
			GetPlayerSpells()
		end
		if LYMode ~= "PvP" then
			if event == "ENCOUNTER_START" then
				LYInBossFight = true
			elseif event == "ENCOUNTER_END" then
				LYInBossFight = nil
			end
		end
		if event == "ACTIVE_TALENT_GROUP_CHANGED" or (LYMyClass and event == "PLAYER_ENTERING_WORLD") then
			TalentGroup = GetActiveSpecGroup()
			LYMySpec = GetSpecialization()
			IDTables()
			ResetLYTables()
			CheckPlayerTalents()
			GetPlayerSpells()
		end
		if event == "PLAYER_UNGHOST" then
			PauseGCD = GetTime() + 1
		end
		if event == "PLAYER_TARGET_CHANGED" then
			if not UnitGUID("target") and LYEnemiesAll then
				for i=1,#LYEnemiesAll do
					if UnitIsVisible(LYEnemiesAll[i]) and HaveBuff(LYEnemiesAll[i],HnFD) then
						TargetUnit(LYEnemiesAll[i])
					end
				end
			end
			LastTimeLYUpdated = 0
			LYCurrentSpellName = nil
			LYEnemyTarget = nil
		end
		if event == "UNIT_SPELLCAST_SUCCEEDED" then
			if UnitIsUnit("player", select(1, ...)) then
				failed = 0
				timeSinceFirstFailed = 0
				LYLastFailedSpell  = nil
				if LYCurrentSpellName == GetSpellInfo(select(3, ...)) then
					LYCurrentSpellName = nil
				end
				LYActiveSpellCast = nil
			end
		elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_STOP" then
			local unit, _, id = ...
			if unit and id and unit == "player" then
				local SpellName = GetSpellInfo(id)
				if event == "UNIT_SPELLCAST_FAILED" then
					if not UnitIsStunned("player") then
						-- this would be the latest spell failing (whatever LYFireSpell last fired)
						if LYActiveSpellCast == SpellName then
							if tContains(listRetrySpell,SpellName) and GCDCheck(SpellName) then
								CastSpellByName(SpellName)
							end
						end
						if ((SpellName == LYLastFailedSpell or not LYLastFailedSpell) and ((SpellName == LYLastSpellName and not LYCurrentSpellName) or SpellName == LYCurrentSpellName) and not tContains(excludedSpells,SpellName)) then
							failed = failed + 1
							if not LYLastFailedSpell then LYLastFailedSpell  = SpellName end
							if timeSinceFirstFailed == 0 then timeSinceFirstFailed = GetTime() end
							if failed >= 5 and PauseRotation and GetTime() - timeSinceFirstFailed > LYGCDTime then
								failed, timeSinceFirstFailed, LYLastFailedSpell, LYCurrentSpellName, LYSpellQueue = 0, 0, nil, nil, {}
							elseif LYFacing then -- set face again
								LYCurrentSpellFace = "face"
							end
						elseif LYLastFailedSpell and LYLastFailedSpell ~= SpellName then -- we're not stuck on a spell then, just failing a new one
							failed, timeSinceFirstFailed, LYLastFailedSpell = 0, 0, nil
						end
					else -- stunned, so we dont need to track fails
						failed, timeSinceFirstFailed, LYLastFailedSpell = 0, 0, nil
					end
				end
				-- active spellcast nil if stop or fail
				LYActiveSpellCast = nil
			end
		end
		if event == "PLAYER_FOCUS_CHANGED" then
			C_Timer.After(0.5,function() if UnitIsVisible("focus") then LYAutoFocusLastUnit = nil end end)
		end
		if event == "PLAYER_LEVEL_UP" then
			LYMyLevel = UnitLevel("player")
		end
		if event == "PLAYER_DEAD" then
			ResetLYTables()
		end
		if event == "PLAYER_REGEN_ENABLED" and  LYBurstMacro then
			LY_Burst()
		end
		local _,eType,_,sourceGUID,_,_,_,destGUID,_,_,_,spellId,SpellName,_,failType,_,school = CombatLogGetCurrentEventInfo()
		if event == "COMBAT_LOG_EVENT_UNFILTERED" and LYStart then
			if LYSimple and eType == "SPELL_CAST_FAILED" and sourceGUID == LYMyGUID and LYCurrentSpellTarget and destGUID then
				local fail = nil
				local newGUID = UnitGUID(LYCurrentSpellTarget)
				if failType == "Target not in line of sight" or failType == "Your vision of the target is obscured" or failType == "Invalid target" or failType == "Ð¦ÐµÐ»Ñ Ð²Ð½Ðµ Ð¿Ð¾Ð»Ñ Ð·ÑÐµÐ½Ð¸Ñ." then
					LYLoS[newGUID] = GetTime()
					fail = true
				elseif failType == "Target needs to be in front of you." or failType == "Ð¦ÐµÐ»Ñ Ð´Ð¾Ð»Ð¶Ð½Ð° Ð±ÑÑÑ Ð¿ÐµÑÐµÐ´ Ð²Ð°Ð¼Ð¸." then
					LYFace[newGUID] = GetTime()
					fail = true
				elseif failType == "Out of range." or failType == "ÐÐ½Ðµ Ð·Ð¾Ð½Ñ Ð´ÐµÐ¹ÑÑÐ²Ð¸Ñ." then
					fail = true
				end
				if fail then
					BlackListUnit(newGUID)
					LYSpellQueue = {}
					LastTimeLYUpdated = 0
				end
			end
			if eType == "UNIT_DIED" then
				LastTimeLYUpdated = 0
			end
			if eType == "SPELL_INTERRUPT" and LYMode ~= "PvE" then
				if destGUID == LYMyGUID then
					FakeCount = 1
					PauseGCD = GetTime() + 0.3
				end
				if destGUID then
					local kickunit = GetObjectWithGUID(destGUID)
					if UnitIsVisible(kickunit) and not HaveBuff(kickunit,listIKick) then
						if tContains(list2SecKick,SpellName) then
							LockTime[destGUID] = GetTime()+1
						elseif tContains(list3SecKick,SpellName) then
							LockTime[destGUID] = GetTime()+2
						elseif tContains(list4SecKick,SpellName) then
							LockTime[destGUID] = GetTime()+3
						elseif tContains(list5SecKick,SpellName) then
							LockTime[destGUID] = GetTime()+4
						end
					end
				end
				if sourceGUID == LYMyGUID then
					KickTime = 0
				end
			end
			if destGUID and LYMyGUID == destGUID then
				if eType == "SPELL_AURA_REMOVED" then
					if LYStayForm and SpellName == LYStayForm then
						LYStayForm = nil
					end
					if tContains(listCC,SpellName) then
						LYPlayerOutOfCC = GetTime()
					end
				end
				if eType == "SPELL_AURA_APPLIED" and tContains(listCC,SpellName) then
					LYCurrentSpellName = nil
					LYSpellQueue = {}
				end
			end
			if destGUID and destGUID ~= LYMyGUID and eType == "SPELL_AURA_APPLIED" and tContains(LYListBreakableCC,SpellName) then
				LastTimeLYUpdated = 0
			end
			if (eType == "SPELL_AURA_REMOVED" or eType == "SPELL_AURA_APPLIED" or eType == "SPELL_AURA_REFRESH") and destGUID then
				if tContains(listStuns,SpellName) or tContains(listStunsID,spellId) then
					if not DR[destGUID] then
						DR[destGUID] = {}
					end
					if not DR[destGUID]["stun"] then
						DR[destGUID]["stun"] = {Count = 1}
					end
					if eType ~= "SPELL_AURA_REMOVED" then
						if DR[destGUID]["stun"].Time and GetTime() - DR[destGUID]["stun"].Time < 18 then
							DR[destGUID]["stun"].Count = DR[destGUID]["stun"].Count + 1
						else
							DR[destGUID]["stun"].Count = 1
						end
					end
					DR[destGUID]["stun"].Time = GetTime()
				end
				if tContains(listRoots,SpellName) or spellId == 116706 or spellId == 96294 or spellId == 117526 then
					if not DR[destGUID] then
						DR[destGUID] = {}
					end
					if not DR[destGUID]["root"] then
						DR[destGUID]["root"] = {Count = 1}
					end
					if eType ~= "SPELL_AURA_REMOVED" then
						if DR[destGUID]["root"].Time and GetTime() - DR[destGUID]["root"].Time < 18 then
							DR[destGUID]["root"].Count = DR[destGUID]["root"].Count + 1
						else
							DR[destGUID]["root"].Count = 1
						end
					end
					DR[destGUID]["root"].Time = GetTime()
				end
				if tContains(listFear,SpellName) then
					if not DR[destGUID] then
						DR[destGUID] = {}
					end
					if not DR[destGUID]["fear"] then
						DR[destGUID]["fear"] = {Count = 1}
					end
					if eType ~= "SPELL_AURA_REMOVED" then
						if DR[destGUID]["fear"].Time and GetTime() - DR[destGUID]["fear"].Time < 18 then
							DR[destGUID]["fear"].Count = DR[destGUID]["fear"].Count + 1
						else
							DR[destGUID]["fear"].Count = 1
						end
					end
					DR[destGUID]["fear"].Time = GetTime()
				end
				if tContains(listIncap,SpellName) then
					if not DR[destGUID] then
						DR[destGUID] = {}
					end
					if not DR[destGUID]["control"] then
						DR[destGUID]["control"] = {Count = 1}
					end
					if eType ~= "SPELL_AURA_REMOVED" then
						if DR[destGUID]["control"].Time and GetTime() - DR[destGUID]["control"].Time < 18 then
							DR[destGUID]["control"].Count = DR[destGUID]["control"].Count + 1
						else
							DR[destGUID]["control"].Count = 1
						end
					end
					DR[destGUID]["control"].Time = GetTime()
				end
				if tContains(listSilence,SpellName) and SpellName ~= DrSolar then
					if not DR[destGUID] then
						DR[destGUID] = {}
					end
					if not DR[destGUID]["silence"] then
						DR[destGUID]["silence"] = {Count = 1}
					end
					if eType ~= "SPELL_AURA_REMOVED" then
						if DR[destGUID]["silence"].Time and GetTime() - DR[destGUID]["silence"].Time < 18 then
							DR[destGUID]["silence"].Count = DR[destGUID]["silence"].Count + 1
						else
							DR[destGUID]["silence"].Count = 1
						end
					end
					DR[destGUID]["silence"].Time = GetTime()
				end
			end
			if eType == "SPELL_CAST_SUCCESS" and LYTeamPlayers and sourceGUID then
				if LYMode ~= "PvE" then
					local sourceUnit = GetObjectWithGUID(sourceGUID)
					if not UnitIsVisible(sourceUnit) then
						return
					end
					if UnitIsUnit("player", sourceUnit) then
						if tContains(listStealth, SpellName) then
							LastStealth = GetTime()
						end
					elseif (((destGUID and destGUID == LYMyGUID) or (GetDistanceToUnit(sourceUnit) <= 10 and tContains(listGapCloser,SpellName))) and not UnitIsFriend(sourceUnit,"player")) then
						if tContains(listStuns,SpellName) or SpellName == RgShStep then
							AvoidStun(SpellName)
						end
						if (tContains(listKicks,SpellName) or tContains(listBlinkChase,SpellName)) and not castInterruptableP and LYPlayerRole == "HEALER" then
							SpellStopCasting()
							PauseGCD = GetTime() + 0.1
						end
						if SpellName == DeathTouch then
							LYStart = nil
						end
						if tContains(listGapCloser,SpellName) then
							GapCloseUnit = sourceUnit
							GapCloseTime = GetTime()
							GapCloseDistance = GetDistanceToUnit(sourceUnit)
							GapCloseSpell = SpellName
						end
					end
					if LYZoneType == "arena" then
						if UnitCanAttack("player",sourceUnit) then
							if tContains(list15CDKick,SpellName) then
								if not KicksData[sourceGUID] then
									KicksData[sourceGUID] = {Time = 0,CD = 0,Percent = 35}
								end
								if SpellName == ShKick then
									KicksData[sourceGUID].CD = 12
								else
									KicksData[sourceGUID].CD = 15
								end
								if castNameP and currentCastPercentP < 90 then
									KicksData[sourceGUID].Percent = currentCastPercentP
								else
									KicksData[sourceGUID].Percent = 35
								end
								KicksData[sourceGUID].Time = GetTime()
							end
							if tContains(list24CDKick,SpellName) then
								if not KicksData[sourceGUID] then
									KicksData[sourceGUID] = {Time = 0,CD = 0,Percent = 35}
								end
								KicksData[sourceGUID].CD = 24
								if castNameP and currentCastPercentP < 90 then
									KicksData[sourceGUID].Percent = currentCastPercentP
								else
									KicksData[sourceGUID].Percent = 35
								end
								KicksData[sourceGUID].Time = GetTime()
							end
							if tContains(listTrackSpells,SpellName) then
								if not LYUnitAbilityUsedTime[sourceGUID] then
									LYUnitAbilityUsedTime[sourceGUID] = {}
								end
								LYUnitAbilityUsedTime[sourceGUID][SpellName] = GetTime()
							end
						end
						if tContains(listDispelAbilities,SpellName) or tContains(listKicks,SpellName) then
							if not LYUnitAbilityUsedTime[sourceGUID] then
								LYUnitAbilityUsedTime[sourceGUID] = {}
							end
							LYUnitAbilityUsedTime[sourceGUID][SpellName] = GetTime()
						end
					end
					if not UnitIsCCed("player") and UnitCanAttack("player",sourceUnit) and UnitIsPlayer(sourceUnit) and not IsMounted() then
						if tContains(LYListTotems,SpellName) then
							LYTotemTime = GetTime()
						end
						if tContains(listPvPTrinket,SpellName) then
							if not LYUnitAbilityUsedTime[sourceGUID] then
								LYUnitAbilityUsedTime[sourceGUID] = {}
							end
							LYUnitAbilityUsedTime[sourceGUID]["trinket"] = GetTime()
							if CheckRole(sourceUnit) == "HEALER" then
								if CheckUnitDR(sourceUnit,"stun") then
									if LYPlHoJHealer and CDCheck(PlHoJ) and inRange(sourceUnit,PlHoJ) then
										LYSpellStopCasting()
										LYQueueSpell(PlHoJ,sourceUnit)
										LY_Print(PlHoJ.." @healer after "..SpellName,"green",PlHoJ)
									end
									if LYDKAsphyxHealer and GCDCheck(DKAsphyx) and inRange(sourceUnit,DKAsphyx) then
										LYCurrentSpellName = nil
										LYQueueSpell(DKAsphyx,sourceUnit)
										LY_Print(DKAsphyx.." @healer after "..SpellName,"green",DKAsphyx)
									end
								end
								if not UnitIsVisible(LYEnemyTarget) or not UnitIsUnit(LYEnemyTarget,sourceUnit) then
									if LYRgBlindHealer and CDCheck(RgBlind) and inRange(RgBlind,sourceUnit) and CheckUnitDR(sourceUnit,"fear") then
										LYCurrentSpellName = nil
										LYQueueSpell(RgBlind,sourceUnit)
										LY_Print(RgBlind.." @healer after "..SpellName,"green",RgBlind)
									end
									if LYHnTrapHealer and CDCheck(HnTrap) and CheckUnitDR(sourceUnit,"control") then
										LYSpellStopCasting()
										LYQueueSpell(HnTrap,sourceUnit)
										LY_Print(HnTrap.." @healer after "..SpellName,"green",HnTrap)
									end
									if LYMnSapHealer and CDCheck(MnSap) and inRange(MnSap,sourceUnit) and CheckUnitDR(sourceUnit,"control") then
										LYSpellStopCasting()
										LYQueueSpell(MnSap,sourceUnit)
										LY_Print(MnSap.." @healer after "..SpellName,"green",MnSap)
									end
									if LYWrFearHealer and CDCheck(WrFear) and inRange(WrFear,sourceUnit) and CheckUnitDR(sourceUnit,"fear") then
										LYCurrentSpellName = nil
										LYQueueSpell(WrFear,sourceUnit)
										LY_Print(WrFear.." @healer after "..SpellName,"green",WrFear)
									end
								end
								if CDCheck(PrSilence) and inRange(PrSWP,sourceUnit) then
									SpellStopCasting()
									CastSpellByName(PrSilence,sourceUnit)
									LY_Print(PrSilence.." @healer after "..SpellName,"green",PrSilence)
								end
							end
						end
						if destGUID and destGUID == LYMyGUID then
							if LYMyClass == 2 and #LYTeamPlayers > 1 and SpellName == RgBlind and CDCheck(PlSac) then
								for j=1,#LYTeamPlayers do
									if UnitIsVisible(LYTeamPlayers[j]) and not UnitIsUnit("player",LYTeamPlayers[j]) then
										LYSpellStopCasting()
										LYQueueSpell(PlSac,LYTeamPlayers[j])
										LY_Print(PlSac.." Blind","green",PlSac)
									end
								end
							end
							if SpellName == DKGrip then
								if TPX then
									if LYMyClass == 9 and (LYWlTPHP ~= 0 or LYWlTPBurst) and CDCheck(WlTP2) and (not InLineOfSightPointToUnit(TPX,TPY,TPZ) or GetDistancePointToUnit(TPX,TPY,TPZ) > 25) and GetDistancePointToUnit(TPX,TPY,TPZ) < 40 then
										LYSpellStopCasting()
										LYQueueSpell(WlTP2)
										LY_Print(WlTP2.." from "..DKGrip,"green",WlTP2)
									end
								end
								if LYMyClass == 7 and LYMySpec == 3 and CDCheck(ShGround) and CheckUnitDR("player","stun") and SpellIsReady(sourceUnit,DKAsphyx,45) then
									LYSpellStopCasting()
									LYQueueSpell(ShGround)
									LY_Print(ShGround.." on "..DKGrip,"green",ShGround)
								end
								if LYMyClass == 11 and LYMySpec == 4 and GetShapeshiftForm() == 0 and CDCheck(DrBear) then
									LYSpellStopCasting()
									LYQueueSpell(DrBear)
									LY_Print(DrBear.." on "..DKGrip,"green",DrBear)
								end
							end
							if SpellName == DKSimul and castNameP and tContains(listCCInt,castNameP) then
								SpellStopCasting()
								LYCurrentSpellName = nil
								LY_Print("Stopcast on "..DKSimul,"red")
							end
							if LYMyClass == 7 and CDCheck(ShGround) and tContains(LYReflectAlways,SpellName) and not HaveBuff("player",listIMagic) then
								LYSpellStopCasting()
								LYQueueSpell(ShGround)
								LY_Print(ShGround.." on "..SpellName,"green",ShGround)
							end
						end
						if tContains(listStealth,SpellName) and RecordMove[sourceGUID] then
							if LYMyClass == 3 then
								if CDCheck(HnFlare) and GetDistancePointToUnit(RecordMove[sourceGUID].X,RecordMove[sourceGUID].Y,RecordMove[sourceGUID].Z) < 40 and InLineOfSightPointToUnit(RecordMove[sourceGUID].X,RecordMove[sourceGUID].Y,RecordMove[sourceGUID].Z+2) then
									LYSpellStopCasting()
									LYQueueSpell(HnFlare,"point",RecordMove[sourceGUID].X,RecordMove[sourceGUID].Y,RecordMove[sourceGUID].Z)
									LY_Print(HnFlare.." on "..SpellName,"green",HnFlare)
								end
							elseif LYMyClass == 12 then
								if CDCheck(DHSpectral) then
									C_Timer.After(0.5,function() LYCurrentSpellName = nil LYQueueSpell(DHSpectral) end)
									LY_Print(DHSpectral.." on "..SpellName,"green",DHSpectral)
								end
							elseif LYMyClass == 6 then
								if CDCheck(DKDecay) and GetDistancePointToUnit(RecordMove[sourceGUID].X,RecordMove[sourceGUID].Y,RecordMove[sourceGUID].Z) < 30 and InLineOfSightPointToUnit(RecordMove[sourceGUID].X,RecordMove[sourceGUID].Y,RecordMove[sourceGUID].Z+2) then
									LYCurrentSpellName = nil
									LYQueueSpell(DKDecay,"point",RecordMove[sourceGUID].X,RecordMove[sourceGUID].Y,RecordMove[sourceGUID].Z)
									LY_Print(DKDecay.." on "..SpellName,"green",DKDecay)
								end
								if CDCheck(DKEpidemic) then
									LYCurrentSpellName = nil
									LYQueueSpell(DKEpidemic)
								end
							end
						end
						if LYMyClass == 6 and LYMySpec == 3 and SpellName == DrinkMana and CDCheck(DKEpidemic) then
							LYCurrentSpellName = nil
							LYQueueSpell(DKEpidemic)
						end
						if SpellName == WrColos or SpellName == WrWarBreak or SpellName == WrSpearBast then
							local disarm = nil
							if LYMyClass == 1 and LYWrDisarmColos then
								disarm = WrDisarm
							elseif LYMyClass == 4 and LYRgDisarmColos then
								disarm = RgDisarm
							elseif LYMyClass == 10 and LYMnDisarmColos then
								disarm = MnDisarm
							end
							if disarm and CDCheck(disarm) and inRange(disarm,sourceUnit) then
								LYCurrentSpellName = nil
								LYQueueSpell(disarm,sourceUnit)
							end
						end
						if SpellName == HnTrap or (SpellName == HnHarpoon and destGUID and CheckRole(GetObjectWithGUID(destGUID)) == "HEALER" and SpellIsReady(sourceUnit,HnTrap,23)) then
							if LYMyClass == 1 then
								if LYWrInterTrap and GCDCheck(WrIntervene) and InLineOfSight(sourceUnit,LYTeamHealers[1]) and IsInDistance(sourceUnit,45,LYTeamHealers[1]) and inRange(WrIntervene,LYTeamHealers[1]) then
									CastSpellByName(WrIntervene,LYTeamHealers[1])
									CastSpellByName(WrReflect)
									StopMoving()
									LY_Print(WrIntervene.." @team healer for "..SpellName,"green",WrIntervene)
									return
								end
								if LYMySpec == 1 and LYWrBannerTrap and GCDCheck(WrBanner) and IsInDistance(LYTeamHealers[1],30) and InLineOfSight(sourceUnit,LYTeamHealers[1]) and IsInDistance(sourceUnit,45,LYTeamHealers[1]) then
									CastSpellByName(WrBanner)
									LY_Print(WrBanner.." on "..SpellName,"green",WrBanner)
									return
								end
								if LYWrReflTrap and #LYTeamHealersAll == 0 and GCDCheck(WrReflect) and InLineOfSight(sourceUnit) and IsInDistance(sourceUnit,45) and UnitGUID(UnitTarget(sourceUnit)) ~= UnitGUID("player") then
									CastSpellByName(WrReflect)
									LY_Print(WrReflect.." @"..SpellName,"green",WrReflect)
									return
								end
								if LYWrReflect and LYMyClass == 1 and SpellName == HnTrap and GCDCheck(WrReflect) and CheckUnitDR("player","control") and not FriendIsUnderAttack("player") and not HaveBuff("player",ShGroundEffect) and InLineOfSight(sourceUnit) and IsInDistance(sourceUnit,45) then
									CastSpellByName(WrReflect)
									LY_Print(WrReflect.." on "..SpellName,"green",WrReflect)
									return
								end
							end
							if LYMyClass == 2 then
								TauntCC(PlTaunt,true)
								if CDCheck(PlSac) and LYPlSacCCHP ~= 0 and CheckUnitDR("player","control") and not FriendIsUnderAttack("player") and InLineOfSight(sourceUnit) and IsInDistance(sourceUnit,45) then
									for j=1,#LYTeamPlayers do
										if (FriendIsUnderAttack(LYTeamPlayers[j]) or HaveDebuff(LYTeamPlayers[j],listDoTs)) and not UnitIsUnit("player",LYTeamPlayers[j]) then
											LYSpellStopCasting()
											LYQueueSpell(PlSac,LYTeamPlayers[j])
											LY_Print(PlSac.." on "..SpellName,"green",PlSac)
											return true
										end
									end
								end
							end
							if LYMyClass == 4 and LYRgShStepTrap and CDCheck(RgShStep) and InLineOfSight(sourceUnit,LYTeamHealers[1]) and IsInDistance(sourceUnit,45,LYTeamHealers[1]) then
								CastSpellByName(RgShStep,LYTeamHealers[1])
								StopMoving()
								LY_Print(RgShStep.." @team healer for "..SpellName,"green",RgShStep)
								return
							end
							if LYMyClass == 7 then
								if CDCheck(ShGround) and IsInDistance(GetObjectWithGUID(destGUID),40) then
									LYSpellStopCasting()
									LYQueueSpell(ShGround)
									LY_Print(ShGround.." on "..SpellName,"green",ShGround)
									return
								end
								if CDCheck(ShEarthEle) and LYMySpec == 3 and IsInDistance(sourceUnit,40) then
									LYSpellStopCasting()
									LYQueueSpell(ShEarthEle)
									LY_Print(ShEarthEle.." on "..SpellName,"green",ShEarthEle)
									return
								end
							end
							if LYMyClass == 5 then
								if CDCheck(PrSWD) and InLineOfSight(sourceUnit) and IsInDistance(sourceUnit,45) then
									CancelBuffByName(PrShield)
									LYSpellStopCasting()
									LYQueueSpell(PrSWD,sourceUnit)
									LY_Print(PrSWD.." on "..SpellName,"green",PrSWD)
									return
								end
								if LYMySpec == 3 and CDCheck(PrGrip) and LYPrGripTrap and InLineOfSight(sourceUnit,LYTeamHealers[1]) and IsInDistance(sourceUnit,45,LYTeamHealers[1]) then
									LYSpellStopCasting()
									CastSpellByName(PrGrip,LYTeamHealers[1])
									LY_Print(PrGrip.." @team healer from "..SpellName,"green",PrGrip)
									return
								end
							end
							if LYMyClass == 10 and LYMySpec == 2 then
								TauntCC(MnTaunt,true)
								if CDCheck(MnTP) and TPX and LYMnTPTrap then
									LYSpellStopCasting()
									LYQueueSpell(MnTP)
									LY_Print(MnTP.." from "..HnTrap,"green",MnTP)
									return
								end
							end
							if LYMyClass == 11 and CDCheck(DrWildCharge) and LYDrChargeTrap then
								if LYMySpec == 4 then
									if CheckUnitDR("player","control") and not FriendIsUnderAttack("player") and InLineOfSight(sourceUnit) and IsInDistance(sourceUnit,40) then
										for j=1,#LYTeamPlayers do
											if IsInDistance(LYTeamPlayers[j],25) and not UnitIsUnit("player",LYTeamPlayers[j]) then
												LYSpellStopCasting()
												CancelShapeshiftForm()
												LYQueueSpell(DrWildCharge,LYTeamPlayers[j])
												StopMoving()
												LY_Print(DrWildCharge.." from "..SpellName,"green",DrWildCharge)
												return
											end
										end
									end
								else
									for j=1,#LYTeamHealers do
										if IsInDistance(LYTeamHealers[j],25) and CheckUnitDR(LYTeamHealers[j],"control") and not FriendIsUnderAttack(LYTeamHealers[j]) and InLineOfSight(sourceUnit,LYTeamHealers[j]) and IsInDistance(sourceUnit,40,LYTeamHealers[j]) then
											LYSpellStopCasting()
											CancelShapeshiftForm()
											LYQueueSpell(DrWildCharge,LYTeamHealers[j])
											StopMoving()
											LY_Print(DrWildCharge.." to catch "..SpellName,"green",DrWildCharge)
											return
										end
									end
								end
							end
						end
						if SpellName == RgBomb then
							local temtTarget = UnitTarget(sourceUnit)
							if LYMyClass == 2 and UnitIsVisible(temtTarget) and not UnitIsUnit("player",temtTarget) and not UnitCanAttack("player",temtTarget) and InLineOfSight(temtTarget) then
								if CDCheck(PlSac) and LYPlSacBomb then
									LYSpellStopCasting()
									CastSpellByName(PlSac,temtTarget)
									LY_Print(PlSac.." on "..RgBomb,"green",PlBoP)
									return
								end
								if CDCheck(PlBoP) and inRange(PlShock,temtTarget) and not HaveDebuff(temtTarget,{PlForbear,OrbPower}) and not HaveBuff(temtTarget,{HordeFlag,AlyFlag,PlSac,PlGuardKings}) then
									LYSpellStopCasting()
									LYQueueSpell(PlBoP,temtTarget)
									LY_Print(PlBoP.." on "..RgBomb,"green",PlBoP)
									return
								end
							end
							if LYMyClass == 3 and LYMySpec == 2 and CDCheck(HnHiExpTrap) and InLineOfSight(sourceUnit) and IsInDistance(sourceUnit,40) then
								LYSpellStopCasting()
								LYQueueSpell(HnHiExpTrap,sourceUnit)
								LY_Print(HnHiExpTrap.." on "..RgBomb,"green",HnHiExpTrap)
								return
							end
							if LYMyClass == 5 and UnitIsVisible(temtTarget) and not UnitIsUnit("player",temtTarget) and not UnitCanAttack("player",temtTarget) and inRange(PrGrip,temtTarget) and LYPrGripBomb and CDCheck(PrGrip) and InLineOfSight(sourceUnit) then
								LYSpellStopCasting()
								CastSpellByName(PrGrip,temtTarget)
								LY_Print(PrGrip.." on "..RgBomb,"green",PrGrip)
								return
							end
							if LYMyClass == 6 and CDCheck(DKGrip) and inRange(DKGrip,sourceUnit) and not IsRooted(sourceUnit) and UnitIsVisible(temtTarget) and not UnitIsUnit(temtTarget,"player") and InLineOfSight(sourceUnit) then
								LYCurrentSpellName = nil
								LYQueueSpell(DKGrip,sourceUnit,"face")
								LY_Print(DKGrip.." on "..RgBomb,"green",DKGrip)
								return
							end
							if LYMyClass == 10 and LYMnRingPeaceBomb and IsInDistance(sourceUnit,38) and CDCheck(MnRingPeace) and InLineOfSight(sourceUnit) then
								LYSpellStopCasting()
								LYQueueSpell(MnRingPeace,sourceUnit)
								LY_Print(MnRingPeace.." on "..RgBomb,"green",MnRingPeace)
								return
							end
							if LYMyClass == 12 and GCDCheck(DHBladeDance) and IsInDistance(sourceUnit,8) then
								LYSpellStopCasting()
								LYQueueSpell(DHBladeDance)
								LY_Print(DHBladeDance.." on "..RgBomb,"green",DHBladeDance)
								return
							end
						end
					end
					if UnitIsVisible("target") and UnitGUID("target") == sourceGUID and tContains(listBlink,SpellName) and not HaveDebuff("player",DrVortex) and LYFollowBlink and InLineOfSight() and IsInDistance("target",40) then
						if LYMyClass == 1 and not IsRooted() then
							if GCDCheck(WrCharge) then
								CastSpellByName(WrCharge,"target","face")
								LY_Print(WrCharge.." after "..SpellName,"green",WrCharge)
							elseif GCDCheck(WrLeap) then
								LYSpellStopCasting()
								LYQueueSpell(WrLeap,"target")
								LY_Print(WrLeap.." after "..SpellName,"green",WrLeap)
							end
						end
						if LYMyClass == 6 and inRange(DKGrip) and CDCheck(DKGrip) and not IsRooted("target") then
							LYCurrentSpellName = nil
							LYQueueSpell(DKGrip,"target","face")
							LY_Print(DKGrip.." after "..SpellName,"green",DKGrip)
						end
						if LYMyClass == 7 and LYMySpec == 2 and IsInDistance("target",25) and CDCheck(ShBlink) and not IsRooted() then
							LYSpellStopCasting()
							LYQueueSpell(ShBlink,"target","force")
							LY_Print(ShBlink.." after "..SpellName,"green",ShBlink)
						end
						if LYMyClass == 11 and LYMySpec == 2 and not IsRooted() and CDCheck(DrWildCharge) and GetShapeshiftForm() == 2 and inRange(DrWildCharge) then
							LYSpellStopCasting()
							LYQueueSpell(DrWildCharge,"target","face")
							LY_Print(DrWildCharge.." after "..SpellName,"green",DrWildCharge)
						end
						if LYMyClass == 12 and not IsRooted() and CDCheck(DHFelRush) then
							LYSpellStopCasting()
							DHFelRushTarget("target")
							LY_Print(DHFelRush.." after "..SpellName,"green",DHFelRush)
						end
					end
				end
				if LYMyGUID == sourceGUID then
					local spells = {}
					for i=1,#LYSpellQueue do
						if LYSpellQueue[i] and string.lower(LYSpellQueue[i].spell) ~= string.lower(SpellName) then
							tinsert(spells,LYSpellQueue[i])
						end
					end
					LYSpellQueue = spells
					if SpellName == LYFakeSpell then
						FakeCount = 1
					end
					if tContains(listCancelAOE,SpellName) then
						SpellStopTargeting()
					end
					if SpellName == ShadowMeld then
						if LYMyClass == 11 and GCDCheck(DrStealth) then
							CastSpellByName(DrStealth)
						end
						if LYMyClass == 4 and GCDCheck(RgStealth) then
							CastSpellByName(RgStealth)
						end
						PauseGCD = GetTime() + 1
					end
					if LYMyClass == 2 and LYMySpec == 3 and SpellName == PlJudg and IsPvPTalentInUse(755) then
						local judgU = GetObjectWithGUID(destGUID)
						if not UnitIsVisible(LYPlJudgUnit) or not UnitIsUnit(judgU,LYPlJudgUnit) then
							LYPlJudgUnit = judgU
						else
							LYPlJudgUnit = nil
						end
					end
					if LYMyClass == 4 then
						if SpellName == RgKidney then
							LYNextStun = nil
						end
					end
					if LYMyClass == 9 then
						if tContains(listWlSummon,SpellName) and not UnitAffectingCombat("player") then
							PauseGCD = GetTime() + 1
						end
						if SpellName == WlTP1 and not HaveBuff("player",WlTP1) then
							TPX,TPY,TPZ = ObjectPosition("player")
						end
						if SpellName == WlImplosion or SpellName == WlPowerSiph then
							LYWlPetsCount = 0
						end
					end
					if LYMyClass == 10 then
						if LYMySpec == 2 then
							if destGUID and SpellName == MnSoothMist then
								MnSMistUnit = GetObjectWithGUID(destGUID)
							end
							if LYFake and UnitChannelInfo("player") == MnSoothMist and (SpellName == MnEMist or SpellName == MnUplift) then
								EnemyCanKick(true)
							end
						end
						if LYMnStatues and (SpellName == MnStatue or SpellName == MnBlOxStatue) then
							MnGetStatue = {ObjectPosition("player")}
						end
						if SpellName == MnTP or SpellName == MnTPPlace then
							TPX,TPY,TPZ = ObjectPosition("player")
						end
						if SpellName == MnCopy then
							CastSpellByName(MnCopy)
						end
					end
					if LYMyClass == 11 then
						if SpellName == DrMaim then
							LYNextStun = nil
						end
					end
					if LYMyClass == 12 and LYMySpec == 1 then
						if SpellName == DHFelRush then
							MoveBackwardStop()
							AscendStop()
						end
					end
					if tContains(listKicks,SpellName) then
						LYKickPause = GetTime()
						NextKick = nil
					end
					LYLastSpellName2 = LYLastSpellName
					LYLastSpellName = SpellName
					LYLastQueueSpell = nil
					LYCurrentSpellName = nil
					LYCurrentSpellFace = nil
					LYCastToKick = nil
					LYOldGCD = nil
					PauseGCD = 0
				end
			end
		end
	end	
	--GUI
	function LY_RunGUI()
		function UpdateSettings()
			if not LYSettings then
				return
			end
			LYLog = LYSettings[0]["NON-COMBAT"][1].LUA
			LYFacing = LYSettings[0]["NON-COMBAT"][2].LUA
			LYPause = LYSettings[0]["NON-COMBAT"][3].LUA
			LYFlag = LYSettings[0]["NON-COMBAT"][4].LUA
			LYAutoBuff = LYSettings[0]["NON-COMBAT"][5].LUA
			LYFake = LYSettings[0]["NON-COMBAT"][6].LUA
			LYAutoTrink1 = LYSettings[0]["NON-COMBAT"][7].LUA
			LYAutoTrink2 = LYSettings[0]["NON-COMBAT"][8].LUA
			LYFrameDelay = LYSettings[0]["NON-COMBAT"][9].LUA
			LYReaction = LYSettings[0]["NON-COMBAT"][10].LUA
			LYAutoFocusHeal = LYSettings[0]["NON-COMBAT"][11].LUA
			LYAutoFocusLast = LYSettings[0]["NON-COMBAT"][12].LUA
			LYNamePlates = LYSettings[0]["NON-COMBAT"][13].LUA
			LYCameraDist = LYSettings[0]["NON-COMBAT"][14].LUA
			LYSoundLog = LYSettings[0]["NON-COMBAT"][15].LUA
			LYLooter = LYSettings[0]["NON-COMBAT"][16].LUA
			LYStyle = LYSettings[0]["COMMON"][1].LUA
			LYIgnorePets = LYSettings[0]["COMMON"][2].LUA
			LYHS = LYSettings[0]["COMMON"][3].LUA
			LYAutoCCMoveWarn = LYSettings[0]["COMMON"][4].LUA
			LYAutoCCMoveStop = LYSettings[0]["COMMON"][5].LUA
			LYBattleRes = LYSettings[0]["COMMON"][6].LUA
			LYStackDef = LYSettings[0]["COMMON"][7].LUA
			LYDoTEHeal = LYSettings[0]["COMMON"][8].LUA
			LYBurstHP = LYSettings[0]["DPS"][1].LUA
			LYBurstHealCC = LYSettings[0]["DPS"][2].LUA
			LYBurstTeam = LYSettings[0]["DPS"][3].LUA
			LYBurstIgnoreDef = LYSettings[0]["DPS"][4].LUA
			LYBurstPickup = LYSettings[0]["DPS"][5].LUA
			LYBurstPvE = LYSettings[0]["DPS"][6].LUA
			LYFollowBlink = LYSettings[0]["DPS"][7].LUA
			LYMarkHealer = LYSettings[0]["DPS"][8].LUA
			LYMarkFrTarget = LYSettings[0]["DPS"][9].LUA
			LYDispelDPSSet = LYSettings[0]["DPS"][10].LUA
			LYDoTUnits = LYSettings[0]["DPS"][11].LUA
			LYPurgeMana = LYSettings[0]["DPS"][12].LUA
			LYPetOnHealer = LYSettings[0]["DPS"][13].LUA
			LYDPSSelfHeal = LYSettings[0]["DPS"][14].LUA
			LYSlowTarget = LYSettings[0]["DPS"][15].LUA
			LYSlowAlways = LYSettings[0]["DPS"][16].LUA
			LYPeelHealer = LYSettings[0]["DPS"][17].LUA
			LYPeelAny = LYSettings[0]["DPS"][18].LUA
			LYDispelHP = LYSettings[0]["HEALING"][1].LUA
			LYDispelCC = LYSettings[0]["HEALING"][2].LUA
			LYDispelRoot = LYSettings[0]["HEALING"][3].LUA
			LYDispelDotCount = LYSettings[0]["HEALING"][4].LUA
			LYDispelDoTHP = LYSettings[0]["HEALING"][5].LUA
			LYDispelAll = LYSettings[0]["HEALING"][6].LUA
			LYHealerDPS = LYSettings[0]["HEALING"][7].LUA
			LYMarkKick = LYSettings[0]["HEALING"][8].LUA
			LYMarkFrDPS = LYSettings[0]["HEALING"][9].LUA
			LYPurgeHP = LYSettings[0]["HEALING"][10].LUA
			LYKickStart = LYSettings[0]["KICK"][1].LUA
			LYKickEnd = LYSettings[0]["KICK"][2].LUA
			LYKickDelay = LYSettings[0]["KICK"][3].LUA
			LYKickMin = LYSettings[0]["KICK"][4].LUA
			LYKickHold = LYSettings[0]["KICK"][5].LUA
			LYKickFocus = LYSettings[0]["KICK"][6].LUA
			LYKickHealHP = LYSettings[0]["KICK"][7].LUA
			LYKickIgnoreDPS = LYSettings[0]["KICK"][8].LUA
			LYKickDPSHP = LYSettings[0]["KICK"][9].LUA
			LYKickDPSBurst = LYSettings[0]["KICK"][10].LUA
			LYKickCCPlayer = LYSettings[0]["KICK"][11].LUA
			LYKickCCBurst = LYSettings[0]["KICK"][12].LUA
			LYKickCCDR = LYSettings[0]["KICK"][13].LUA
			LYKickChain = LYSettings[0]["KICK"][14].LUA
			LYMeldCCHP = LYSettings[0]["RACIAL"][1].LUA
			LYMeldCCBurst = LYSettings[0]["RACIAL"][2].LUA
			LYRacialsBurst = LYSettings[0]["RACIAL"][3].LUA
			LYRacialsKick = LYSettings[0]["RACIAL"][4].LUA
			LYRacialsHP = LYSettings[0]["RACIAL"][5].LUA
			LYRacialsDPS = LYSettings[0]["RACIAL"][6].LUA
			LYRacialsRootHP = LYSettings[0]["RACIAL"][7].LUA
			LYRacialsRootTime = LYSettings[0]["RACIAL"][8].LUA
			LYClassConfigs = LYSettings[0]["CONFIG"][1].LUA
			LYElvUISkinning = LYSettings[0]["CONFIG"][2].LUA
			LYMacroCommand = LYSettings[0]["CONFIG"][3].LUA
			LYDHBlurHP = LYSettings[12][DHBlur][1].LUA
			LYDHBlurBurst = LYSettings[12][DHBlur][2].LUA
			LYDHBlurHealer = LYSettings[12][DHBlur][3].LUA
			LYDHStunKick = LYSettings[12][DHStun][1].LUA
			LYDHStunAOE = LYSettings[12][DHStun][2].LUA
			LYDHStunBurst = LYSettings[12][DHStun][3].LUA
			LYDHStunHealer = LYSettings[12][DHStun][4].LUA
			LYDHStunHealerHP = LYSettings[12][DHStun][5].LUA
			LYDHStunTeamBurst = LYSettings[12][DHStun][6].LUA
			LYDHStunDPS = LYSettings[12][DHStun][7].LUA
			LYDHStunDPSHP = LYSettings[12][DHStun][8].LUA
			LYDHStunDPSBurst = LYSettings[12][DHStun][9].LUA
			LYDHStunDR = LYSettings[12][DHStun][10].LUA
			LYDHStunCont = LYSettings[12][DHStun][11].LUA
			LYDHStunFocus = LYSettings[12][DHStun][12].LUA
			LYDHDarknessHP = LYSettings[12][DHDarkness][1].LUA
			LYDHDarknessBurst = LYSettings[12][DHDarkness][2].LUA
			LYDHEyeBeamCast = LYSettings[12][DHEyeBeam][1].LUA
			LYDHEyeBeamMove = LYSettings[12][DHEyeBeam][2].LUA
			LYDHFelBar = LYSettings[12][DHFelBar][1].LUA
			LYDHFelEruptBurst = LYSettings[12][DHFelErupt][1].LUA
			LYDHFelEruptHealer = LYSettings[12][DHFelErupt][2].LUA
			LYDHFelEruptHealerHP = LYSettings[12][DHFelErupt][3].LUA
			LYDHFelEruptTeamBurst = LYSettings[12][DHFelErupt][4].LUA
			LYDHFelEruptDPS = LYSettings[12][DHFelErupt][5].LUA
			LYDHFelEruptDPSHP = LYSettings[12][DHFelErupt][6].LUA
			LYDHFelEruptDPSBurst = LYSettings[12][DHFelErupt][7].LUA
			LYDHFelEruptDR = LYSettings[12][DHFelErupt][8].LUA
			LYDHFelEruptCont = LYSettings[12][DHFelErupt][9].LUA
			LYDHFelEruptFocus = LYSettings[12][DHFelErupt][10].LUA
			LYDHFelEruptKick = LYSettings[12][DHFelErupt][11].LUA
			LYDHFelRushKick = LYSettings[12][DHFelRush][1].LUA
			LYDHFelRushDPS = LYSettings[12][DHFelRush][2].LUA
			LYDHFelRushAway = LYSettings[12][DHFelRush][3].LUA
			LYDHIlGraspHP = LYSettings[12][DHIlGrasp][1].LUA
			LYDHIlGraspBurst = LYSettings[12][DHIlGrasp][2].LUA
			LYDHImprisonKick = LYSettings[12][DHImprison][1].LUA
			LYDHImprHealer = LYSettings[12][DHImprison][2].LUA
			LYDHImprHealerHP = LYSettings[12][DHImprison][3].LUA
			LYDHImprTeamBurst = LYSettings[12][DHImprison][4].LUA
			LYDHImprDPS = LYSettings[12][DHImprison][5].LUA
			LYDHImprDPSHP = LYSettings[12][DHImprison][6].LUA
			LYDHImprDPSBurst = LYSettings[12][DHImprison][7].LUA
			LYDHImprDR = LYSettings[12][DHImprison][8].LUA
			LYDHImprCont = LYSettings[12][DHImprison][9].LUA
			LYDHImprFocus = LYSettings[12][DHImprison][10].LUA
			LYDHMetaTank = LYSettings[12][DHBurst][1].LUA
			LYDHNWalkHP = LYSettings[12][DHNetherwalk][1].LUA
			LYDHNWalkBurst = LYSettings[12][DHNetherwalk][2].LUA
			LYDHNWalkHealer = LYSettings[12][DHNetherwalk][3].LUA
			LYDHRainAboveHP = LYSettings[12][DHRainAbove][1].LUA
			LYDHRainAboveBurst = LYSettings[12][DHRainAbove][2].LUA
			LYDHRainAboveHealer = LYSettings[12][DHRainAbove][3].LUA
			LYDHRainAboveStun = LYSettings[12][DHRainAbove][4].LUA
			LYDHRevMagCC = LYSettings[12][DHRevMagic][1].LUA
			LYDHRevMagEnemy = LYSettings[12][DHRevMagic][2].LUA
			LYDHRevMagTeam = LYSettings[12][DHRevMagic][3].LUA
			LYDHRevMagHP = LYSettings[12][DHRevMagic][4].LUA
			LYDHRevMagDPS = LYSettings[12][DHRevMagic][5].LUA
			LYDHSigChainHP = LYSettings[12][DHSigilChains][1].LUA
			LYDHSigChainBurst = LYSettings[12][DHSigilChains][2].LUA
			LYDHSigMisHealer = LYSettings[12][DHSigilMisery][1].LUA
			LYDHSigMisHealerHP = LYSettings[12][DHSigilMisery][2].LUA
			LYDHSigMisTeamBurst = LYSettings[12][DHSigilMisery][3].LUA
			LYDHSigMisDPS = LYSettings[12][DHSigilMisery][4].LUA
			LYDHSigMisDPSHP = LYSettings[12][DHSigilMisery][5].LUA
			LYDHSigMisDPSBurst = LYSettings[12][DHSigilMisery][6].LUA
			LYDHSigMisDR = LYSettings[12][DHSigilMisery][7].LUA
			LYDHSigMisAlt = LYSettings[12][DHSigilMisery][8].LUA
			LYDHSigSilenHP = LYSettings[12][DHSigilSilence][1].LUA
			LYDHSigSilenBurst = LYSettings[12][DHSigilSilence][2].LUA
			LYDHVengRetreat = LYSettings[12][DHVengRetreat][1].LUA
			LYDHVengRetreatCCHP = LYSettings[12][DHVengRetreat][2].LUA
			LYDHVengRetreatCCBurst = LYSettings[12][DHVengRetreat][3].LUA
			LYDHFieryBrandHP = LYSettings[12][DHFieryBrand][1].LUA
			LYDHFieryBrandBurst = LYSettings[12][DHFieryBrand][2].LUA
			LYDHFelDevasHP = LYSettings[12][DHFelDevas][1].LUA
			LYDHFelDevasAOE = LYSettings[12][DHFelDevas][2].LUA
			LYDHFelbladeBurst = LYSettings[12][DHFelblade][1].LUA
			LYDHFelbladeHP = LYSettings[12][DHFelblade][2].LUA
			LYDHFelbladeMelee = LYSettings[12][DHFelblade][3].LUA
			LYDHFelbladeVR = LYSettings[12][DHFelblade][4].LUA
			LYDHElysianAOE = LYSettings[12][DHElysian][1].LUA
			LYDKAMSHP = LYSettings[6][DKAMS][1].LUA
			LYDKAMSBurst = LYSettings[6][DKAMS][2].LUA
			LYDKAMSHealer = LYSettings[6][DKAMS][3].LUA
			LYDKAMSCCHP = LYSettings[6][DKAMS][4].LUA
			LYDKAMSCCBurst = LYSettings[6][DKAMS][5].LUA
			LYDKAMSTeammate = LYSettings[6][DKAMS][6].LUA
			LYDKAMSCCAll = LYSettings[6][DKAMS][7].LUA
			LYDKAMZHP = LYSettings[6][DKAMZ][1].LUA
			LYDKAMZBurst = LYSettings[6][DKAMZ][2].LUA
			LYDKAsphyxHealer = LYSettings[6][DKAsphyx][1].LUA
			LYDKAsphyxHealerHP = LYSettings[6][DKAsphyx][2].LUA
			LYDKAsphyxTeamBurst = LYSettings[6][DKAsphyx][3].LUA
			LYDKAsphyxDPS = LYSettings[6][DKAsphyx][4].LUA
			LYDKAsphyxDPSHP = LYSettings[6][DKAsphyx][5].LUA
			LYDKAsphyxDPSBurst = LYSettings[6][DKAsphyx][6].LUA
			LYDKAsphyxDR = LYSettings[6][DKAsphyx][7].LUA
			LYDKAsphyxCont = LYSettings[6][DKAsphyx][8].LUA
			LYDKAsphyxFocus = LYSettings[6][DKAsphyx][9].LUA
			LYDKAsphyxKick = LYSettings[6][DKAsphyx][10].LUA
			LYDKDeadArmy = LYSettings[6][DKDeadArmy][1].LUA
			LYDKBlindSleetKick = LYSettings[6][DKBlindSleet][1].LUA
			LYDKBlindSleetHealer = LYSettings[6][DKBlindSleet][2].LUA
			LYDKBlindSleetHealerHP = LYSettings[6][DKBlindSleet][3].LUA
			LYDKBlindSleetTeamBurst = LYSettings[6][DKBlindSleet][4].LUA
			LYDKBlindSleetDPS = LYSettings[6][DKBlindSleet][5].LUA
			LYDKBlindSleetDPSHP = LYSettings[6][DKBlindSleet][6].LUA
			LYDKBlindSleetDPSBurst = LYSettings[6][DKBlindSleet][7].LUA
			LYDKBlindSleetDR = LYSettings[6][DKBlindSleet][8].LUA
			LYDKBlindSleetCont = LYSettings[6][DKBlindSleet][9].LUA
			LYDKBlindSleetFocus = LYSettings[6][DKBlindSleet][10].LUA
			LYDKSimulCC = LYSettings[6][DKSimul][1].LUA
			LYDKSimulHP = LYSettings[6][DKSimul][2].LUA
			LYDKSimulFire = LYSettings[6][DKSimul][3].LUA
			LYDKDeathAdvanceHP = LYSettings[6][DKDeathAdvance][1].LUA
			LYDKDecay = LYSettings[6][DKDecay][1].LUA
			LYDKGripKick = LYSettings[6][DKGrip][1].LUA
			LYDKFollowBlink = LYSettings[6][DKGrip][2].LUA
			LYDKGripBurst = LYSettings[6][DKGrip][3].LUA
			LYDKGripHP = LYSettings[6][DKGrip][4].LUA
			LYDKEatPetHP = LYSettings[6][DKEatPet][1].LUA
			LYDKPetStunKick = LYSettings[6][DKGnaw][1].LUA
			LYDKIceBoundHP = LYSettings[6][DKIceBound][1].LUA
			LYDKIceBoundBurst = LYSettings[6][DKIceBound][2].LUA
			LYDKIceBoundHealer = LYSettings[6][DKIceBound][3].LUA
			LYDKIBFStunTime = LYSettings[6][DKIceBound][4].LUA
			LYDKIBFStunBurst = LYSettings[6][DKIceBound][5].LUA
			LYDKIBFStunHP = LYSettings[6][DKIceBound][6].LUA
			LYDKWrWalkTime = LYSettings[6][DKWrWalk][1].LUA
			LYDKWrWalkHP = LYSettings[6][DKWrWalk][2].LUA
			LYDKRuneTapHP = LYSettings[6][DKRuneTap][1].LUA
			LYDKRuneTapBurst = LYSettings[6][DKRuneTap][2].LUA
			LYDKRuneTapHealer = LYSettings[6][DKRuneTap][3].LUA
			LYDKTombHP = LYSettings[6][DKTombstone][1].LUA
			LYDKTombBurst = LYSettings[6][DKTombstone][2].LUA
			LYDKTombHealer = LYSettings[6][DKTombstone][3].LUA
			LYDKVamBloodHP = LYSettings[6][DKVamBlood][1].LUA
			LYDKVamBloodBurst = LYSettings[6][DKVamBlood][2].LUA
			LYDKVamBloodHealer = LYSettings[6][DKVamBlood][3].LUA
			LYDKSacPact = LYSettings[6][DKSacPact][1].LUA
			LYDKDeathStrikeHP = LYSettings[6][DKDeathStrike][1].LUA
			LYDKDeathStrikeBurst = LYSettings[6][DKDeathStrike][2].LUA
			LYDKPet = LYSettings[6][DKPet][1].LUA
			LYDKLichbornHP = LYSettings[6][DKLichborn][1].LUA
			LYDKEpidemic = LYSettings[6][DKEpidemic][1].LUA
			LYDrBearHP = LYSettings[11][DrBear][1].LUA
			LYDrBearBurst = LYSettings[11][DrBear][2].LUA
			LYDrBearHealer = LYSettings[11][DrBear][3].LUA
			LYDrBSkinHP = LYSettings[11][DrBSkin][1].LUA
			LYDrBSkinBurst = LYSettings[11][DrBSkin][2].LUA
			LYDrBSkinHealer = LYSettings[11][DrBSkin][3].LUA
			LYDrBSkinStunTime = LYSettings[11][DrBSkin][4].LUA
			LYDrBSkinStunHP = LYSettings[11][DrBSkin][5].LUA
			LYDrCenWardHP = LYSettings[11][DrCenWard][1].LUA
			LYDrCenWardBurst = LYSettings[11][DrCenWard][2].LUA
			LYDrCloneHealer = LYSettings[11][DrClone][1].LUA
			LYDrCloneHealerHP = LYSettings[11][DrClone][2].LUA
			LYDrCloneTeamBurst = LYSettings[11][DrClone][3].LUA
			LYDrCloneDPS = LYSettings[11][DrClone][4].LUA
			LYDrCloneDPSHP = LYSettings[11][DrClone][5].LUA
			LYDrCloneDPSBurst = LYSettings[11][DrClone][6].LUA
			LYDrCloneDR = LYSettings[11][DrClone][7].LUA
			LYDrCloneCont = LYSettings[11][DrClone][8].LUA
			LYDrCloneFocus = LYSettings[11][DrClone][9].LUA
			LYDrEfflorCount = LYSettings[11][DrMush][1].LUA
			LYDrEfflorHP = LYSettings[11][DrMush][2].LUA
			LYDrEflorSlowHP = LYSettings[11][DrMush][3].LUA
			LYDrFWarmHP = LYSettings[11][DrFSwarm][1].LUA
			LYDrFWarmBurst = LYSettings[11][DrFSwarm][2].LUA
			LYDrFlourCCHP = LYSettings[11][DrFlour][1].LUA
			LYDrFlourHP = LYSettings[11][DrFlour][2].LUA
			LYDrDesorKick = LYSettings[11][DrDesor][1].LUA
			LYDrDesorHealer = LYSettings[11][DrDesor][2].LUA
			LYDrDesorHealerHP = LYSettings[11][DrDesor][3].LUA
			LYDrDesorTeamBurst = LYSettings[11][DrDesor][4].LUA
			LYDrDesorDPS = LYSettings[11][DrDesor][5].LUA
			LYDrDesorDPSHP = LYSettings[11][DrDesor][6].LUA
			LYDrDesorDPSBurst = LYSettings[11][DrDesor][7].LUA
			LYDrDesorDR = LYSettings[11][DrDesor][8].LUA
			LYDrDesorCont = LYSettings[11][DrDesor][9].LUA
			LYDrDesorFocus = LYSettings[11][DrDesor][10].LUA
			LYDrIncTreeHP = LYSettings[11][DrIncTree][1].LUA
			LYDrIncTreeAOEUnits = LYSettings[11][DrIncTree][2].LUA
			LYDrIncTreeAOEHP = LYSettings[11][DrIncTree][3].LUA
			LYDrIrBarkCCHP = LYSettings[11][DrIBark][1].LUA
			LYDrIrBarkHP = LYSettings[11][DrIBark][2].LUA
			LYDrIrBarkBurst = LYSettings[11][DrIBark][3].LUA
			LYDrLunBeamHP = LYSettings[11][DrLunarBeam][1].LUA
			LYDrLunBeamCount = LYSettings[11][DrLunarBeam][2].LUA
			LYDrMaimKick = LYSettings[11][DrMaim][1].LUA
			LYDrMaimHealer = LYSettings[11][DrMaim][2].LUA
			LYDrMaimHealerHP = LYSettings[11][DrMaim][3].LUA
			LYDrMaimTeamBurst = LYSettings[11][DrMaim][4].LUA
			LYDrMaimDPS = LYSettings[11][DrMaim][5].LUA
			LYDrMaimDPSHP = LYSettings[11][DrMaim][6].LUA
			LYDrMaimDPSBurst = LYSettings[11][DrMaim][7].LUA
			LYDrMaimDR = LYSettings[11][DrMaim][8].LUA
			LYDrBashKick = LYSettings[11][DrBash][1].LUA
			LYDrBashHealer = LYSettings[11][DrBash][2].LUA
			LYDrBashHealerHP = LYSettings[11][DrBash][3].LUA
			LYDrBashTeamBurst = LYSettings[11][DrBash][4].LUA
			LYDrBashDPS = LYSettings[11][DrBash][5].LUA
			LYDrBashDPSHP = LYSettings[11][DrBash][6].LUA
			LYDrBashDPSBurst = LYSettings[11][DrBash][7].LUA
			LYDrBashDR = LYSettings[11][DrBash][8].LUA
			LYDrBashChain = LYSettings[11][DrBash][9].LUA
			LYDrBashFocus = LYSettings[11][DrBash][10].LUA
			LYDrInner = LYSettings[11][DrInner][1].LUA
			LYDrOvergrHP = LYSettings[11][DrOvergrowth][1].LUA
			LYDrOverrunKick = LYSettings[11][DrOverrun][1].LUA
			LYDrStealth = LYSettings[11][DrStealth][1].LUA
			LYDrRegrHP = LYSettings[11][DrRegr][1].LUA
			LYDrRegrNSHP = LYSettings[11][DrRegr][2].LUA
			LYDrRejuvHP = LYSettings[11][DrRejuv][1].LUA
			LYDrRenew = LYSettings[11][DrRenewal][1].LUA
			LYDrSolarHP = LYSettings[11][DrSolar][1].LUA
			LYDrSolarBurst = LYSettings[11][DrSolar][2].LUA
			LYDrSolarCCHP = LYSettings[11][DrSolar][3].LUA
			LYDrSolarCCBurst = LYSettings[11][DrSolar][4].LUA
			LYDrFreedomRoot = LYSettings[11][DrStamped][1].LUA
			LYDrFreedomHealHP = LYSettings[11][DrStamped][2].LUA
			LYDrFreedomDPS = LYSettings[11][DrStamped][3].LUA
			LYDrFreedomTarHP = LYSettings[11][DrStamped][4].LUA
			LYDrSFallCount = LYSettings[11][DrSFall][1].LUA
			LYDrSMendHP = LYSettings[11][DrSMend][1].LUA
			LYDrSurvHP = LYSettings[11][DrSurvInst][1].LUA
			LYDrSurvBurst = LYSettings[11][DrSurvInst][2].LUA
			LYDrSurvHealer = LYSettings[11][DrSurvInst][3].LUA
			LYDrThornsHP = LYSettings[11][DrThorns][1].LUA
			LYDrThornsBurst = LYSettings[11][DrThorns][2].LUA
			LYDrTranqCount = LYSettings[11][DrTranq][1].LUA
			LYDrTranqHP = LYSettings[11][DrTranq][2].LUA
			LYDrTyphKick = LYSettings[11][DrTyphoon][1].LUA
			LYDrChargeKick = LYSettings[11][DrWildCharge][1].LUA
			LYDrChargeKickHeal = LYSettings[11][DrWildCharge][2].LUA
			LYDrChargeTrap = LYSettings[11][DrWildCharge][3].LUA
			LYDrVortexHP = LYSettings[11][DrVortex][1].LUA
			LYDrVortexBurst = LYSettings[11][DrVortex][2].LUA
			LYDrHeartWildDefHP = LYSettings[11][DrHeartWild][1].LUA
			LYDrHeartWildDefBurst = LYSettings[11][DrHeartWild][2].LUA
			LYDrHeartWildDefHealer = LYSettings[11][DrHeartWild][3].LUA
			LYDrHeartWildDPS = LYSettings[11][DrHeartWild][4].LUA
			LYDrHeartWildHealHP = LYSettings[11][DrHeartWild][5].LUA
			LYDrHeartWildHealBurst = LYSettings[11][DrHeartWild][6].LUA
			LYDrNS = LYSettings[11][DrNS][1].LUA
			LYDrFBite = LYSettings[11][DrFBite][1].LUA
			LYDrFBiteBurst = LYSettings[11][DrFBite][2].LUA
			LYDrWGrowthCount = LYSettings[11][DrWGrowth][1].LUA
			LYDrWGrowthHP = LYSettings[11][DrWGrowth][2].LUA
			LYDrTFAggressive = LYSettings[11][DrTF][1].LUA
			LYEvTimeStopCCHP = LYSettings[13][EvTimeStop][1].LUA
			LYEvTimeStopHP = LYSettings[13][EvTimeStop][2].LUA
			LYEvTipScalesHP = LYSettings[13][EvTipScales][1].LUA
			LYEvTipScalesBurst = LYSettings[13][EvTipScales][2].LUA
			LYEvWingBufKick = LYSettings[13][EvWingBuf][1].LUA
			LYEvTailSwipeKick = LYSettings[13][EvTailSwipe][1].LUA
			LYEvObsidScalesHP = LYSettings[13][EvObsidScales][1].LUA
			LYEvObsidScalesBurst = LYSettings[13][EvObsidScales][2].LUA
			LYEvObsidScalesHealer = LYSettings[13][EvObsidScales][3].LUA
			LYEvSleepWalkHealer = LYSettings[13][EvSleepWalk][1].LUA
			LYEvSleepWalkHealerHP = LYSettings[13][EvSleepWalk][2].LUA
			LYEvSleepWalkTeamBurst = LYSettings[13][EvSleepWalk][3].LUA
			LYEvSleepWalkDPS = LYSettings[13][EvSleepWalk][4].LUA
			LYEvSleepWalkDPSHP = LYSettings[13][EvSleepWalk][5].LUA
			LYEvSleepWalkDPSBurst = LYSettings[13][EvSleepWalk][6].LUA
			LYEvSleepWalkDR = LYSettings[13][EvSleepWalk][7].LUA
			LYEvSleepWalkCont = LYSettings[13][EvSleepWalk][8].LUA
			LYEvSleepWalkFocus = LYSettings[13][EvSleepWalk][9].LUA
			LYEvLivFlameHP = LYSettings[13][EvLivFlame][1].LUA
			LYEvEmerBlosHP = LYSettings[13][EvEmerBlos][1].LUA
			LYEvDreamFlightHP = LYSettings[13][EvDreamFlight][1].LUA
			LYEvDreamProjectHP = LYSettings[13][EvDreamProject][1].LUA
			LYEvRenewBlazeHP = LYSettings[13][EvRenewBlaze][1].LUA
			LYEvRenewBlazeBurst = LYSettings[13][EvRenewBlaze][2].LUA
			LYEvTimeDilationHP = LYSettings[13][EvTimeDilation][1].LUA
			LYEvTimeDilationBurst = LYSettings[13][EvTimeDilation][2].LUA
			LYEvEmerCommunHP = LYSettings[13][EvEmerCommun][1].LUA
			LYEvSpiritBloomHP = LYSettings[13][EvSpiritbloom][1].LUA
			LYEvDreamBreathHP = LYSettings[13][EvDreamBreath][1].LUA
			LYEvDreamBreathRank3 = LYSettings[13][EvDreamBreath][2].LUA
			LYEvDreamBreathR3HP = LYSettings[13][EvDreamBreath][3].LUA
			LYEvDreamBreathRank3Immune = LYSettings[13][EvDreamBreath][4].LUA
			LYEvRewindHP = LYSettings[13][EvRewind][1].LUA
			LYHnEagleBurstHP = LYSettings[3][HnEagleBurst][1].LUA
			LYHnDeterHP = LYSettings[3][HnDeter][1].LUA
			LYHnDeterBurst = LYSettings[3][HnDeter][2].LUA
			LYHnDeterHealer = LYSettings[3][HnDeter][3].LUA
			LYHnBind = LYSettings[3][HnBindShot][1].LUA
			LYHnBindShotHealer = LYSettings[3][HnBindShot][2].LUA
			LYHnBindShotHealerHP = LYSettings[3][HnBindShot][3].LUA
			LYHnBindShotTeamBurst = LYSettings[3][HnBindShot][4].LUA
			LYHnBindShotDPS = LYSettings[3][HnBindShot][5].LUA
			LYHnBindShotDPSHP = LYSettings[3][HnBindShot][6].LUA
			LYHnBindShotDPSBurst = LYSettings[3][HnBindShot][7].LUA
			LYHnBindShotDR = LYSettings[3][HnBindShot][8].LUA
			LYHnBindShotCont = LYSettings[3][HnBindShot][9].LUA
			LYHnBurstShotKick = LYSettings[3][HnBurstShot][1].LUA
			LYHnBurstShotHP = LYSettings[3][HnBurstShot][2].LUA
			LYHnBurstShotHPBurst = LYSettings[3][HnBurstShot][3].LUA
			LYSummonPet = LYSettings[3][HnCallPetName][1].LUA
			LYHnHarpoon = LYSettings[3][HnHarpoon][1].LUA
			LYHnExhil = LYSettings[3][HnHeal][1].LUA
			LYHnExhilHealer = LYSettings[3][HnHeal][2].LUA
			LYHnFDHP = LYSettings[3][HnFD][1].LUA
			LYHnFDCCHP = LYSettings[3][HnFD][2].LUA
			LYHnFDCCBurst = LYSettings[3][HnFD][3].LUA
			LYHnFDDPS = LYSettings[3][HnFD][4].LUA
			LYHnTrapHealer = LYSettings[3][HnTrap][1].LUA
			LYHnTrapHealerHP = LYSettings[3][HnTrap][2].LUA
			LYHnTrapTeamBurst = LYSettings[3][HnTrap][3].LUA
			LYHnTrapDPS = LYSettings[3][HnTrap][4].LUA
			LYHnTrapDPSHP = LYSettings[3][HnTrap][5].LUA
			LYHnTrapDPSBurst = LYSettings[3][HnTrap][6].LUA
			LYHnTrapDR = LYSettings[3][HnTrap][7].LUA
			LYHnTrapCont = LYSettings[3][HnTrap][8].LUA
			LYHnTrapFocus = LYSettings[3][HnTrap][9].LUA
			LYHnHiExpTrapKick = LYSettings[3][HnExpTrap][1].LUA
			LYHnHiExpTrapHP = LYSettings[3][HnExpTrap][2].LUA
			LYHnHiExpTrapBurst = LYSettings[3][HnExpTrap][3].LUA
			LYHnTauntHP = LYSettings[3][HnInterlope][1].LUA
			LYHnTauntBurst = LYSettings[3][HnInterlope][2].LUA
			LYHnIntimidHealer = LYSettings[3][HnIntimid][1].LUA
			LYHnIntimidHealerHP = LYSettings[3][HnIntimid][2].LUA
			LYHnIntimidTeamBurst = LYSettings[3][HnIntimid][3].LUA
			LYHnIntimidDPS = LYSettings[3][HnIntimid][4].LUA
			LYHnIntimidDPSHP = LYSettings[3][HnIntimid][5].LUA
			LYHnIntimidDPSBurst = LYSettings[3][HnIntimid][6].LUA
			LYHnIntimidDR = LYSettings[3][HnIntimid][7].LUA
			LYHnIntimidKick = LYSettings[3][HnIntimid][8].LUA
			LYHnFreedomRoot = LYSettings[3][HnFreedom][1].LUA
			LYHnFreedomHeal = LYSettings[3][HnFreedom][2].LUA
			LYHnFreedomDPS = LYSettings[3][HnFreedom][3].LUA
			LYHnFreedomHP = LYSettings[3][HnFreedom][4].LUA
			LYHnSacHP = LYSettings[3][HnPetSac][1].LUA
			LYHnSacBurst = LYSettings[3][HnPetSac][2].LUA
			LYHnScatKick = LYSettings[3][HnScatter][1].LUA
			LYHnScatHealer = LYSettings[3][HnScatter][2].LUA
			LYHnScatHealerHP = LYSettings[3][HnScatter][3].LUA
			LYHnScatTeamBurst = LYSettings[3][HnScatter][4].LUA
			LYHnScatDPS = LYSettings[3][HnScatter][5].LUA
			LYHnScatDPSHP = LYSettings[3][HnScatter][6].LUA
			LYHnScatDPSBurst = LYSettings[3][HnScatter][7].LUA
			LYHnScatDR = LYSettings[3][HnScatter][8].LUA
			LYHnScatCont = LYSettings[3][HnScatter][9].LUA
			LYHnScatFocus = LYSettings[3][HnScatter][10].LUA
			LYHnVolleyAOE = LYSettings[3][HnVolley][1].LUA
			LYHnRapidFire = LYSettings[3][HnRapidFire][1].LUA
			LYHnSurvFitHP = LYSettings[3][HnSurvFit][1].LUA
			LYHnSurvFitBurst = LYSettings[3][HnSurvFit][2].LUA
			LYHnSurvFitHealer = LYSettings[3][HnSurvFit][3].LUA
			LYHnFortBearHP = LYSettings[3][HnFortBear][1].LUA
			LYHnTarTrapHP = LYSettings[3][HnTarTrap][1].LUA
			LYHnTarTrapBurst = LYSettings[3][HnTarTrap][2].LUA
			LYMgBarrage = LYSettings[8][MgBarrage][1].LUA
			LYMgBlinkTime = LYSettings[8][MgBlink][1].LUA
			LYMgDisplace = LYSettings[8][MgDisplace][1].LUA
			LYMgDBKick = LYSettings[8][MgDB][1].LUA
			LYMgDBHealer = LYSettings[8][MgDB][2].LUA
			LYMgDBHealerHP = LYSettings[8][MgDB][3].LUA
			LYMgDBTeamBurst = LYSettings[8][MgDB][4].LUA
			LYMgDBDPS = LYSettings[8][MgDB][5].LUA
			LYMgDBDPSHP = LYSettings[8][MgDB][6].LUA
			LYMgDBDPSBurst = LYSettings[8][MgDB][7].LUA
			LYMgDBDR = LYSettings[8][MgDB][8].LUA
			LYMgDBCont = LYSettings[8][MgDB][9].LUA
			LYMgDBAlex = LYSettings[8][MgDB][10].LUA
			LYMgDBWhileBurst = LYSettings[8][MgDB][11].LUA
			LYMgDBBlink = LYSettings[8][MgDB][12].LUA
			LYMgGreatInvHP = LYSettings[8][MgGreatInv][1].LUA
			LYMgGreatInvBurst = LYSettings[8][MgGreatInv][2].LUA
			LYMgGreatInvHealer = LYSettings[8][MgGreatInv][3].LUA
			LYMgBlockHP = LYSettings[8][MgBlock][1].LUA
			LYMgBlockBurst = LYSettings[8][MgBlock][2].LUA
			LYMgBlockHealer = LYSettings[8][MgBlock][3].LUA
			LYMgBlockCC = LYSettings[8][MgBlock][4].LUA
			LYMgFlameStrike = LYSettings[8][MgFlameStrike][1].LUA
			LYMgPolyKick = LYSettings[8][MgPoly][1].LUA
			LYMgPolyHealer = LYSettings[8][MgPoly][2].LUA
			LYMgPolyHealerHP = LYSettings[8][MgPoly][3].LUA
			LYMgPolyTeamBurst = LYSettings[8][MgPoly][4].LUA
			LYMgPolyDPS = LYSettings[8][MgPoly][5].LUA
			LYMgPolyDPSHP = LYSettings[8][MgPoly][6].LUA
			LYMgPolyDPSBurst = LYSettings[8][MgPoly][7].LUA
			LYMgPolyDR = LYSettings[8][MgPoly][8].LUA
			LYMgPolyCont = LYSettings[8][MgPoly][9].LUA
			LYMgPolyFocus = LYSettings[8][MgPoly][10].LUA
			LYMgPolyWhileBurst = LYSettings[8][MgPoly][11].LUA
			LYMgRingFrostHealer = LYSettings[8][MgRingFrost][1].LUA
			LYMgRingFrostHealerHP = LYSettings[8][MgRingFrost][2].LUA
			LYMgRingFrostTeamBurst = LYSettings[8][MgRingFrost][3].LUA
			LYMgRingFrostDPS = LYSettings[8][MgRingFrost][4].LUA
			LYMgRingFrostDPSHP = LYSettings[8][MgRingFrost][5].LUA
			LYMgRingFrostDPSBurst = LYSettings[8][MgRingFrost][6].LUA
			LYMgRingFrostDR = LYSettings[8][MgRingFrost][7].LUA
			LYMgRingFrostCont = LYSettings[8][MgRingFrost][8].LUA
			LYMgRingFrostFocus = LYSettings[8][MgRingFrost][9].LUA
			LYMgTempShieldHP = LYSettings[8][MgTempShield][1].LUA
			LYMgTempShieldBurst = LYSettings[8][MgTempShield][2].LUA
			LYMgTempShieldHealer = LYSettings[8][MgTempShield][3].LUA
			LYMgMirImageHP = LYSettings[8][MgMirImage][1].LUA
			LYMgMirImageBurst = LYSettings[8][MgMirImage][2].LUA
			LYMgMirImageHealer = LYSettings[8][MgMirImage][3].LUA
			LYMgMirImageDPS = LYSettings[8][MgMirImage][4].LUA
			LYMgAlterTimeBurst = LYSettings[8][MgAlterTime][1].LUA
			LYMgAlterTimeHealer = LYSettings[8][MgAlterTime][2].LUA
			LYMgMassBarHP = LYSettings[8][MgMassBar][1].LUA
			LYMgMassBarBurst = LYSettings[8][MgMassBar][2].LUA
			LYMnGuardianHP = LYSettings[10][MnGuardian][1].LUA
			LYMnGuardianBurst = LYSettings[10][MnGuardian][2].LUA
			LYMnDifMagHP = LYSettings[10][MnDifMagic][1].LUA
			LYMnDifMagBurst = LYSettings[10][MnDifMagic][2].LUA
			LYMnDifMagHealer = LYSettings[10][MnDifMagic][3].LUA
			LYMnDifMagBuff = LYSettings[10][MnDifMagic][4].LUA
			LYMnDisableRoot = LYSettings[10][MnDisable][1].LUA
			LYMnDisarmHP = LYSettings[10][MnDisarm][1].LUA
			LYMnDisarmBurst = LYSettings[10][MnDisarm][2].LUA
			LYMnDisarmHealer = LYSettings[10][MnDisarm][3].LUA
			LYMnDisarmColos = LYSettings[10][MnDisarm][4].LUA
			LYMnDisarmFocus = LYSettings[10][MnDisarm][5].LUA
			LYMnFortElixHP = LYSettings[10][MnFortBrew][1].LUA
			LYMnFortElixBurst = LYSettings[10][MnFortBrew][2].LUA
			LYMnFortElixHealer = LYSettings[10][MnFortBrew][3].LUA
			LYMnInvokeYulonHP = LYSettings[10]["Invoke Yulon"][1].LUA
			LYMnInvokeYulonAOE = LYSettings[10]["Invoke Yulon"][2].LUA
			LYMnInvokeYulonAOEHP = LYSettings[10]["Invoke Yulon"][3].LUA
			LYMnInvokeYulonBurst = LYSettings[10]["Invoke Yulon"][4].LUA
			LYMnRestoralHP = LYSettings[10][MnRestoral][1].LUA
			LYMnRestoralAOE = LYSettings[10][MnRestoral][2].LUA
			LYMnRestoralAOEHP = LYSettings[10][MnRestoral][3].LUA
			LYMnLegSwipKick = LYSettings[10][MnLegSwip][1].LUA
			LYMnLegSwipHealer = LYSettings[10][MnLegSwip][2].LUA
			LYMnLegSwipHealerHP = LYSettings[10][MnLegSwip][3].LUA
			LYMnLegSwipTeamBurst = LYSettings[10][MnLegSwip][4].LUA
			LYMnLegSwipDPS = LYSettings[10][MnLegSwip][5].LUA
			LYMnLegSwipDPSHP = LYSettings[10][MnLegSwip][6].LUA
			LYMnLegSwipDPSBurst = LYSettings[10][MnLegSwip][7].LUA
			LYMnLegSwipDR = LYSettings[10][MnLegSwip][8].LUA
			LYMnLegSwipCont = LYSettings[10][MnLegSwip][9].LUA
			LYMnLegSwipFocus = LYSettings[10][MnLegSwip][10].LUA
			LYMnLegSwipTrpl = LYSettings[10][MnLegSwip][11].LUA
			LYMnCocoonHP = LYSettings[10][MnCocoon][1].LUA
			LYMnCocoonBurst = LYSettings[10][MnCocoon][2].LUA
			LYMnSapKick = LYSettings[10][MnSap][1].LUA
			LYMnSapHealer = LYSettings[10][MnSap][2].LUA
			LYMnSapHealerHP = LYSettings[10][MnSap][3].LUA
			LYMnSapTeamBurst = LYSettings[10][MnSap][4].LUA
			LYMnSapDPS = LYSettings[10][MnSap][5].LUA
			LYMnSapDPSHP = LYSettings[10][MnSap][6].LUA
			LYMnSapDPSBurst = LYSettings[10][MnSap][7].LUA
			LYMnSapDR = LYSettings[10][MnSap][8].LUA
			LYMnSapCont = LYSettings[10][MnSap][9].LUA
			LYMnSapFocus = LYSettings[10][MnSap][10].LUA
			LYMnPureBrew = LYSettings[10][MnPureBrew][1].LUA
			LYMnRevivalHP = LYSettings[10][MnRevival][1].LUA
			LYMnRevivalAOE = LYSettings[10][MnRevival][2].LUA
			LYMnRevivalAOEHP = LYSettings[10][MnRevival][3].LUA
			LYMnRingPeaceHP = LYSettings[10][MnRingPeace][1].LUA
			LYMnRingPeaceBurst = LYSettings[10][MnRingPeace][2].LUA
			LYMnRingPeaceBomb = LYSettings[10][MnRingPeace][3].LUA
			LYMnRingPeaceKick = LYSettings[10][MnRingPeace][4].LUA
			LYMnRingPeaceOut = LYSettings[10][MnRingPeace][5].LUA
			LYFistTeaHP = LYSettings[10][MnThunderTea][1].LUA
			LYMnStatues = LYSettings[10][MnStatue][1].LUA
			LYMnFreedomRoot = LYSettings[10][MnFreedom][1].LUA
			LYMnFreedomHeal = LYSettings[10][MnFreedom][2].LUA
			LYMnFreedomDPS = LYSettings[10][MnFreedom][3].LUA
			LYMnFreedomHP = LYSettings[10][MnFreedom][4].LUA
			LYMnKarmaHP = LYSettings[10][MnKarma][1].LUA
			LYMnKarmaBurst = LYSettings[10][MnKarma][2].LUA
			LYMnKarmaHealer = LYSettings[10][MnKarma][3].LUA
			LYMnTPHP = LYSettings[10][MnTP][1].LUA
			LYMnTPBurst = LYSettings[10][MnTP][2].LUA
			LYMnTPHealer = LYSettings[10][MnTP][3].LUA
			LYMnTPTrap = LYSettings[10][MnTP][4].LUA
			LYMnUplift = LYSettings[10][MnUplift][1].LUA
			LYMnZenTea = LYSettings[10][MnZenTea][1].LUA
			LYMnCelBrewHP = LYSettings[10][MnCelBrew][1].LUA
			LYMnCelBrewBurst = LYSettings[10][MnCelBrew][2].LUA
			LYMnCelBrewHealer = LYSettings[10][MnCelBrew][3].LUA
			LYMnExplKegHP = LYSettings[10][MnExplKeg][1].LUA
			LYMnExplKegBurst = LYSettings[10][MnExplKeg][2].LUA
			LYMnExplKegCount = LYSettings[10][MnExplKeg][3].LUA
			LYMnTigerBrewFoF = LYSettings[10][MnTigerBrew][1].LUA
			LYMnTigerBrewBurst = LYSettings[10][MnTigerBrew][2].LUA
			LYMnSpin = LYSettings[10][MnSpin][1].LUA
			LYPlDefenderHP = LYSettings[2][PlDefender][1].LUA
			LYPlDefenderBurst = LYSettings[2][PlDefender][2].LUA
			LYPlDefenderHealer = LYSettings[2][PlDefender][3].LUA
			LYPlWingsHP = LYSettings[2][PlWings][1].LUA
			LYPlWingsBurst = LYSettings[2][PlWings][2].LUA
			LYPlWingsAOEUnits = LYSettings[2][PlWings][3].LUA
			LYPlWingsAOEHP = LYSettings[2][PlWings][4].LUA
			LYPlMAHP = LYSettings[2][PlMA][1].LUA
			LYPlMABurst = LYSettings[2][PlMA][2].LUA
			LYPlMAAOEUnits = LYSettings[2][PlMA][3].LUA
			LYPlMAAOEHP = LYSettings[2][PlMA][4].LUA
			LYPlBeacon = LYSettings[2][PlBeacon][1].LUA
			LYPlBeaconSelf = LYSettings[2][PlBeacon][2].LUA
			LYPlFreedomRoot = LYSettings[2][PlFreedom][1].LUA
			LYPlFreedomHeal = LYSettings[2][PlFreedom][2].LUA
			LYPlFreedomDPS = LYSettings[2][PlFreedom][3].LUA
			LYPlFreedomHP = LYSettings[2][PlFreedom][4].LUA
			LYPlBoPHP = LYSettings[2][PlBoP][1].LUA
			LYPlBoPBurst = LYSettings[2][PlBoP][2].LUA
			LYPlBoPDPS = LYSettings[2][PlBoP][3].LUA
			LYPlBoPStunSec = LYSettings[2][PlBoP][4].LUA
			LYPlBoPStunTeamHP = LYSettings[2][PlBoP][5].LUA
			LYPlBoPStunEnemyHP = LYSettings[2][PlBoP][6].LUA
			LYPlBoPKarma = LYSettings[2][PlBoP][7].LUA
			LYPlBoPTank = LYSettings[2][PlBoP][8].LUA
			LYPlSacHP = LYSettings[2][PlSac][1].LUA
			LYPlSacCCHP = LYSettings[2][PlSac][2].LUA
			LYPlSacBomb = LYSettings[2][PlSac][3].LUA
			LYPlSancSec = LYSettings[2][PlSanctuary][1].LUA
			LYPlSancTeamHP = LYSettings[2][PlSanctuary][2].LUA
			LYPlSancDPS = LYSettings[2][PlSanctuary][3].LUA
			LYPlSancEnemyHP = LYSettings[2][PlSanctuary][4].LUA
			LYPlSancBurst = LYSettings[2][PlSanctuary][5].LUA
			LYPlBlindAOE = LYSettings[2][PlBlind][1].LUA
			LYPlBlindHealer = LYSettings[2][PlBlind][2].LUA
			LYPlBlindHealerHP = LYSettings[2][PlBlind][3].LUA
			LYPlBlindTeamBurst = LYSettings[2][PlBlind][4].LUA
			LYPlBlindDPS = LYSettings[2][PlBlind][5].LUA
			LYPlBlindDPSHP = LYSettings[2][PlBlind][6].LUA
			LYPlBlindDPSBurst = LYSettings[2][PlBlind][7].LUA
			LYPlBlindDR = LYSettings[2][PlBlind][8].LUA
			LYPlBlindKick = LYSettings[2][PlBlind][9].LUA
			LYPlSearGlareAOE = LYSettings[2][PlSearingGlare][1].LUA
			LYPlSearGlareHP = LYSettings[2][PlSearingGlare][2].LUA
			LYPlSearGlareDPSBurst = LYSettings[2][PlSearingGlare][3].LUA
			LYPlSearGlareDR = LYSettings[2][PlSearingGlare][4].LUA
			LYPlGloryHP = LYSettings[2][PlGlory][1].LUA
			LYPlGuardKingsHP = LYSettings[2][PlGuardKings][1].LUA
			LYPlGuardKingsBurst = LYSettings[2][PlGuardKings][2].LUA
			LYPlGuardKingsHealer = LYSettings[2][PlGuardKings][3].LUA
			LYPlDevProtHP = LYSettings[2][PlDevProt][1].LUA
			LYPlDevProtBurst = LYSettings[2][PlDevProt][2].LUA
			LYPlDevProtHealer = LYSettings[2][PlDevProt][3].LUA
			LYPlDevProtStunSec = LYSettings[2][PlDevProt][4].LUA
			LYPlDevProtStunHP = LYSettings[2][PlDevProt][5].LUA
			LYPlDivFavor = LYSettings[2][PlDivFavor][1].LUA
			LYPlBubbleHP = LYSettings[2][PlBubble][1].LUA
			LYPlBubbleBurst = LYSettings[2][PlBubble][2].LUA
			LYPlBubbleHealer = LYSettings[2][PlBubble][3].LUA
			LYPlEyeHP = LYSettings[2][PlEye][1].LUA
			LYPlEyeBurst = LYSettings[2][PlEye][2].LUA
			LYPlEyeHealer = LYSettings[2][PlEye][3].LUA
			LYPlFlash = LYSettings[2][PlFlash][1].LUA
			LYPlHoJHealer = LYSettings[2][PlHoJ][1].LUA
			LYPlHoJHealerHP = LYSettings[2][PlHoJ][2].LUA
			LYPlHoJTeamBurst = LYSettings[2][PlHoJ][3].LUA
			LYPlHoJDPS = LYSettings[2][PlHoJ][4].LUA
			LYPlHoJDPSHP = LYSettings[2][PlHoJ][5].LUA
			LYPlHoJDPSBurst = LYSettings[2][PlHoJ][6].LUA
			LYPlHoJDR = LYSettings[2][PlHoJ][7].LUA
			LYPlHoJCont = LYSettings[2][PlHoJ][8].LUA
			LYPlHoJFocus = LYSettings[2][PlHoJ][9].LUA
			LYPlHoJKick = LYSettings[2][PlHoJ][10].LUA
			LYPlMartyr = LYSettings[2][PlMartyr][1].LUA
			LYPlAvenHP = LYSettings[2][PlAvenger][1].LUA
			LYPlAvenBurst = LYSettings[2][PlAvenger][2].LUA
			LYPlAvenAOEUnits = LYSettings[2][PlAvenger][3].LUA
			LYPlAvengAOEHP = LYSettings[2][PlAvenger][4].LUA
			LYPlLoH = LYSettings[2][PlLoH][1].LUA
			LYPlRepHealer = LYSettings[2][PlRep][1].LUA
			LYPlRepHealerHP = LYSettings[2][PlRep][2].LUA
			LYPlRepTeamBurst = LYSettings[2][PlRep][3].LUA
			LYPlRepDPS = LYSettings[2][PlRep][4].LUA
			LYPlRepDPSHP = LYSettings[2][PlRep][5].LUA
			LYPlRepDPSBurst = LYSettings[2][PlRep][6].LUA
			LYPlRepDR = LYSettings[2][PlRep][7].LUA
			LYPlRepCont = LYSettings[2][PlRep][8].LUA
			LYPlRepFocus = LYSettings[2][PlRep][9].LUA
			LYPlRepKick = LYSettings[2][PlRep][10].LUA
			LYPlShVengHP = LYSettings[2][PlShieldVeng][1].LUA
			LYPlShVengBurst = LYSettings[2][PlShieldVeng][2].LUA
			LYPlShVengHealer = LYSettings[2][PlShieldVeng][3].LUA
			LYPlHolyLight = LYSettings[2][PlHolyLight][1].LUA
			LYPlTyrDevHP = LYSettings[2][PlTyrDev][1].LUA
			LYPlTyrDevBurst = LYSettings[2][PlTyrDev][2].LUA
			LYPlTyrDevAOEUnits = LYSettings[2][PlTyrDev][3].LUA
			LYPlHandDivHP = LYSettings[2][PlHandDiv][1].LUA
			LYPrApothHP = LYSettings[5][PrApotheosis][1].LUA
			LYPrApothBurst = LYSettings[5][PrApotheosis][2].LUA
			LYPrArcHP = LYSettings[5][PrArchangel][1].LUA
			LYPrArcBurst = LYSettings[5][PrArchangel][2].LUA
			LYPrDespPrayer = LYSettings[5][PrDespPrayer][1].LUA
			LYPrDispersHP = LYSettings[5][PrDispers][1].LUA
			LYPrDispersBurst = LYSettings[5][PrDispers][2].LUA
			LYPrDispersHealer = LYSettings[5][PrDispers][3].LUA
			LYPrInnerLightHP = LYSettings[5][PrInnerLight][1].LUA
			LYPrWingsHP = LYSettings[5][PrWings][1].LUA
			LYPrWingsBurst = LYSettings[5][PrWings][2].LUA
			LYPrHolyWard = LYSettings[5][PrHolyWard][1].LUA
			LYPrChasHealer = LYSettings[5][PrChas][1].LUA
			LYPrChasHealerHP = LYSettings[5][PrChas][2].LUA
			LYPrChasTeamBurst = LYSettings[5][PrChas][3].LUA
			LYPrChasDPS = LYSettings[5][PrChas][4].LUA
			LYPrChasDPSHP = LYSettings[5][PrChas][5].LUA
			LYPrChasDPSBurst = LYSettings[5][PrChas][6].LUA
			LYPrChasDR = LYSettings[5][PrChas][7].LUA
			LYPrChasCont = LYSettings[5][PrChas][8].LUA
			LYPrChasFocus = LYSettings[5][PrChas][9].LUA
			LYPrChasKick = LYSettings[5][PrChas][10].LUA
			LYPrDivHymnAOEUnits = LYSettings[5][PrDivHymn][1].LUA
			LYPrDivHymnAOEHP = LYSettings[5][PrDivHymn][2].LUA
			LYPrGripTrap = LYSettings[5][PrGrip][1].LUA
			LYPrGripBomb = LYSettings[5][PrGrip][2].LUA
			LYPrGripClone = LYSettings[5][PrGrip][3].LUA
			LYPrMDTeamHP = LYSettings[5][PrMD][1].LUA
			LYPrMDTeamBurst = LYSettings[5][PrMD][2].LUA
			LYPrMDHealerHP = LYSettings[5][PrMD][3].LUA
			LYPrMDHealerBurst = LYSettings[5][PrMD][4].LUA
			LYPrMCHealer = LYSettings[5][PrMC][1].LUA
			LYPrMCHealerHP = LYSettings[5][PrMC][2].LUA
			LYPrMCTeamBurst = LYSettings[5][PrMC][3].LUA
			LYPrMCDPS = LYSettings[5][PrMC][4].LUA
			LYPrMCDPSHP = LYSettings[5][PrMC][5].LUA
			LYPrMCDPSBurst = LYSettings[5][PrMC][6].LUA
			LYPrMCDR = LYSettings[5][PrMC][7].LUA
			LYPrMCFocus = LYSettings[5][PrMC][8].LUA
			LYPrMCHP = LYSettings[5][PrMC][9].LUA
			LYPrTeethHP = LYSettings[5][PrTeeth][1].LUA
			LYPrTeethBurst = LYSettings[5][PrTeeth][2].LUA
			LYPrTeethStun = LYSettings[5][PrTeeth][3].LUA
			LYPrTeethSmoke = LYSettings[5][PrTeeth][4].LUA
			LYPrPenance = LYSettings[5][PrPenance][1].LUA
			LYPrPWBHP = LYSettings[5][PrPWB][1].LUA
			LYPrPWBBurst = LYSettings[5][PrPWB][2].LUA
			LYPrPWRadHP = LYSettings[5][PrPWRad][1].LUA
			LYPrPWRadAOECount = LYSettings[5][PrPWRad][2].LUA
			LYPrPWRadAOEHP = LYSettings[5][PrPWRad][3].LUA
			LYPrPsyHorHealer = LYSettings[5][PrPsyHorror][1].LUA
			LYPrPsyHorHealerHP = LYSettings[5][PrPsyHorror][2].LUA
			LYPrPsyHorTeamBurst = LYSettings[5][PrPsyHorror][3].LUA
			LYPrPsyHorDPS = LYSettings[5][PrPsyHorror][4].LUA
			LYPrPsyHorDPSHP = LYSettings[5][PrPsyHorror][5].LUA
			LYPrPsyHorDPSBurst = LYSettings[5][PrPsyHorror][6].LUA
			LYPrPsyHorDR = LYSettings[5][PrPsyHorror][7].LUA
			LYPrPsyHorCont = LYSettings[5][PrPsyHorror][8].LUA
			LYPrPsyHorFocus = LYSettings[5][PrPsyHorror][9].LUA
			LYPrPsyHorKick = LYSettings[5][PrPsyHorror][10].LUA
			LYPrFearKick = LYSettings[5][PrFear][1].LUA
			LYPrFearTripple = LYSettings[5][PrFear][2].LUA
			LYPrFearHealer = LYSettings[5][PrFear][3].LUA
			LYPrFearHealerHP = LYSettings[5][PrFear][4].LUA
			LYPrFearTeamBurst = LYSettings[5][PrFear][5].LUA
			LYPrFearDPS = LYSettings[5][PrFear][6].LUA
			LYPrFearDPSHP = LYSettings[5][PrFear][7].LUA
			LYPrFearDPSBurst = LYSettings[5][PrFear][8].LUA
			LYPrFearDR = LYSettings[5][PrFear][9].LUA
			LYPrFearCont = LYSettings[5][PrFear][10].LUA
			LYPrFearFocus = LYSettings[5][PrFear][11].LUA
			LYPrRapturHP = LYSettings[5][PrRapture][1].LUA
			LYPrRapturBurst = LYSettings[5][PrRapture][2].LUA
			LYPrRayHopeHP = LYSettings[5][PrRayHope][1].LUA
			LYPrRayHopeBurst = LYSettings[5][PrRayHope][2].LUA
			LYPrShadowCrash = LYSettings[5][PrShadowCrash][1].LUA
			LYPrFlash = LYSettings[5][PrFlash][1].LUA
			LYPrFlashSP = LYSettings[5][PrFlash][2].LUA
			LYPrSilence = LYSettings[5][PrSilence][1].LUA
			LYPrVampEmbraceHP = LYSettings[5][PrVampEmbrace][1].LUA
			LYPrVampEmbraceBurst = LYSettings[5][PrVampEmbrace][2].LUA
			LYPrVampEmbraceSync = LYSettings[5][PrVampEmbrace][3].LUA
			LYPrVoidshift = LYSettings[5][PrVoidshift][1].LUA
			LYPrVoidshiftHeal = LYSettings[5][PrVoidshift][2].LUA
			LYPrInfusionDPS = LYSettings[5][PrInfusion][1].LUA
			LYPrInfusionFocus = LYSettings[5][PrInfusion][2].LUA
			LYPrInfusionHP = LYSettings[5][PrInfusion][3].LUA
			LYPrInfusionBurst = LYSettings[5][PrInfusion][4].LUA
			LYPrDivAscenHP = LYSettings[5][PrDivAscen][1].LUA
			LYPrDivAscenBurst = LYSettings[5][PrDivAscen][2].LUA
			LYPrMindSoothe = LYSettings[5][PrMindSoothe][1].LUA
			LYPrDarkAngelHP = LYSettings[5][PrDarkAngel][1].LUA
			LYPrDarkAngelBurst = LYSettings[5][PrDarkAngel][2].LUA
			LYPrSanctifyHP = LYSettings[5][PrSanctify][1].LUA
			LYPrSanctifyAOE = LYSettings[5][PrSanctify][2].LUA
			LYPrSanctifyHPS = LYSettings[5][PrSanctify][3].LUA
			LYPrDivWordHP = LYSettings[5][PrDivWord][1].LUA
			LYPrDivWordBurst = LYSettings[5][PrDivWord][2].LUA
			LYPrSpiritRedemHP = LYSettings[5][PrSpiritRedem][1].LUA
			LYPrSpiritRedemBurst = LYSettings[5][PrSpiritRedem][2].LUA
			LYPrSalvationHP = LYSettings[5][PrSalvation][1].LUA
			LYPrSalvationAOE = LYSettings[5][PrSalvation][2].LUA
			LYPrUltPenanceHP = LYSettings[5][PrUltPenance][1].LUA
			LYPrUltPenanceAOEHP = LYSettings[5][PrUltPenance][2].LUA
			LYPrUltPenanceAOECount = LYSettings[5][PrUltPenance][3].LUA
			LYRgBlindHealer = LYSettings[4][RgBlind][1].LUA
			LYRgBlindHealerHP = LYSettings[4][RgBlind][2].LUA
			LYRgBlindTeamBurst = LYSettings[4][RgBlind][3].LUA
			LYRgBlindDPS = LYSettings[4][RgBlind][4].LUA
			LYRgBlindDPSHP = LYSettings[4][RgBlind][5].LUA
			LYRgBlindDPSBurst = LYSettings[4][RgBlind][6].LUA
			LYRgBlindDR = LYSettings[4][RgBlind][7].LUA
			LYRgBlindCont = LYSettings[4][RgBlind][8].LUA
			LYRgBlindFocus = LYSettings[4][RgBlind][9].LUA
			LYRgBlindKick = LYSettings[4][RgBlind][10].LUA
			LYRgCheapStun = LYSettings[4][RgCheap][1].LUA
			LYRgCheapKick = LYSettings[4][RgCheap][2].LUA
			LYRgCheapDR = LYSettings[4][RgCheap][3].LUA
			LYRgCheapDRT = LYSettings[4][RgCheap][4].LUA
			LYRgCheapSD = LYSettings[4][RgCheap][5].LUA
			LYRgCheapTarget = LYSettings[4][RgCheap][6].LUA
			LYRgCloakHP = LYSettings[4][RgCloak][1].LUA
			LYRgCloakBurst = LYSettings[4][RgCloak][2].LUA
			LYRgCloakHealer = LYSettings[4][RgCloak][3].LUA
			LYRgCloakCCHP = LYSettings[4][RgCloak][4].LUA
			LYRgCloakCCBurst = LYSettings[4][RgCloak][5].LUA
			LYRgCrimsonHP = LYSettings[4][RgCrimson][1].LUA
			LYRgCrimsonBurst = LYSettings[4][RgCrimson][2].LUA
			LYRgCrimsonHealer = LYSettings[4][RgCrimson][3].LUA
			LYRgDisarmHP = LYSettings[4][RgDisarm][1].LUA
			LYRgDisarmBurst = LYSettings[4][RgDisarm][2].LUA
			LYRgDisarmHealer = LYSettings[4][RgDisarm][3].LUA
			LYRgDisarmColos = LYSettings[4][RgDisarm][4].LUA
			LYRgDisarmFocus = LYSettings[4][RgDisarm][5].LUA
			LYRgFeintHP = LYSettings[4][RgFeint][1].LUA
			LYRgFeintBurst = LYSettings[4][RgFeint][2].LUA
			LYRgFeintHealer = LYSettings[4][RgFeint][3].LUA
			LYRgEvisHP = LYSettings[4][RgEvis][1].LUA
			LYRgEvasionHP = LYSettings[4][RgEvasion][1].LUA
			LYRgEvasionBurst = LYSettings[4][RgEvasion][2].LUA
			LYRgEvasionHealer = LYSettings[4][RgEvasion][3].LUA
			LYRgGougeKick = LYSettings[4][RgGouge][1].LUA
			LYRgGougeHealer = LYSettings[4][RgGouge][2].LUA
			LYRgGougeHealerHP = LYSettings[4][RgGouge][3].LUA
			LYRgGougeTeamBurst = LYSettings[4][RgGouge][4].LUA
			LYRgGougeDPS = LYSettings[4][RgGouge][5].LUA
			LYRgGougeDPSHP = LYSettings[4][RgGouge][6].LUA
			LYRgGougeDPSBurst = LYSettings[4][RgGouge][7].LUA
			LYRgGougeDR = LYSettings[4][RgGouge][8].LUA
			LYRgGougeCont = LYSettings[4][RgGouge][9].LUA
			LYRgGougeFocus = LYSettings[4][RgGouge][10].LUA
			LYRgKidneyAll = LYSettings[4][RgKidney][1].LUA
			LYRgKidneyHeal = LYSettings[4][RgKidney][2].LUA
			LYRgKidneyKick = LYSettings[4][RgKidney][3].LUA
			LYRgShStepKick = LYSettings[4][RgShStep][1].LUA
			LYRgShStepTrap = LYSettings[4][RgShStep][2].LUA
			LYRgShStepBurst = LYSettings[4][RgShStep][3].LUA
			LYRgShStepHP = LYSettings[4][RgShStep][4].LUA
			LYRgShadowDuelBurst = LYSettings[4][RgShadDuel][1].LUA
			LYRgShadowDuelHP = LYSettings[4][RgShadDuel][2].LUA
			LYRgBombBurst = LYSettings[4][RgBomb][1].LUA
			LYRgBombHP = LYSettings[4][RgBomb][2].LUA
			LYRgBombStun = LYSettings[4][RgBomb][3].LUA
			LYRgBombDefHP = LYSettings[4][RgBomb][4].LUA
			LYRgBombDef = LYSettings[4][RgBomb][5].LUA
			LYRgStealth = LYSettings[4][RgStealth][1].LUA
			LYRgVanishHP = LYSettings[4][RgVanish][1].LUA
			LYRgVanishBurst = LYSettings[4][RgVanish][2].LUA
			LYRgVanishHealer = LYSettings[4][RgVanish][3].LUA
			LYRgVanishDPS = LYSettings[4][RgVanish][4].LUA
			LYRgColdblood = LYSettings[4][RgColdblood][1].LUA
			LYShAscendHP = LYSettings[7][ShAscend][1].LUA
			LYShAscendBurst = LYSettings[7][ShAscend][2].LUA
			LYShAscendAOEUnits = LYSettings[7][ShAscend][3].LUA
			LYShAscendAOEHP = LYSettings[7][ShAscend][4].LUA
			LYShAGHP = LYSettings[7][ShAG][1].LUA
			LYShAGBurst = LYSettings[7][ShAG][2].LUA
			LYShAGAOE = LYSettings[7][ShAG][3].LUA
			LYShAGAOEHP = LYSettings[7][ShAG][4].LUA
			LYShAShiftHP = LYSettings[7][ShAstralShift][1].LUA
			LYShAShiftBurst = LYSettings[7][ShAstralShift][2].LUA
			LYShAShiftHealer = LYSettings[7][ShAstralShift][3].LUA
			LYShCapHealer = LYSettings[7][ShCap][1].LUA
			LYShCapHealerHP = LYSettings[7][ShCap][2].LUA
			LYShCapHealerBurst = LYSettings[7][ShCap][3].LUA
			LYShCapDPS = LYSettings[7][ShCap][4].LUA
			LYShCapDPSHP = LYSettings[7][ShCap][5].LUA
			LYShCapDPSBurst = LYSettings[7][ShCap][6].LUA
			LYShCapDR = LYSettings[7][ShCap][7].LUA
			LYShCapCont = LYSettings[7][ShCap][8].LUA
			LYShCapFocus = LYSettings[7][ShCap][9].LUA
			LYShCapKick = LYSettings[7][ShCap][10].LUA
			LYShCounterHP = LYSettings[7][ShCSTotem][1].LUA
			LYShCounterBurst = LYSettings[7][ShCSTotem][2].LUA
			LYShGroundTeamHP = LYSettings[7][ShGround][1].LUA
			LYShGroundTeamBurst = LYSettings[7][ShGround][2].LUA
			LYShGroundHP = LYSettings[7][ShGround][3].LUA
			LYShGroundBurst = LYSettings[7][ShGround][4].LUA
			LYShGroundDPS = LYSettings[7][ShGround][5].LUA
			LYShGroundTrap = LYSettings[7][ShGround][6].LUA
			LYShWallTotemHP = LYSettings[7][ShShieldTotem][1].LUA
			LYShWallTotemBurst = LYSettings[7][ShShieldTotem][2].LUA
			LYShEartTotHP = LYSettings[7][ShTEarthBind][1].LUA
			LYShEartTotBurst = LYSettings[7][ShTEarthBind][2].LUA
			LYShEarthShock = LYSettings[7][ShEarthShock][1].LUA
			LYShFrostRoot = LYSettings[7][ShSurgePow][1].LUA
			LYShSurgeAlwaysRoot = LYSettings[7][ShSurgePow][2].LUA
			LYShFrostCCByHP = LYSettings[7][ShSurgePow][3].LUA
			LYShFrostDR = LYSettings[7][ShSurgePow][4].LUA
			LYShQuake = LYSettings[7][ShQuake][1].LUA
			LYShHealTideHP = LYSettings[7][ShHealTide][1].LUA
			LYShHealTideAOEUnits = LYSettings[7][ShHealTide][2].LUA
			LYShHealTideAOEHP = LYSettings[7][ShHealTide][3].LUA
			LYShHealSurge = LYSettings[7][ShHealSurge][1].LUA
			LYShHexHealer = LYSettings[7][ShHex][1].LUA
			LYShHexHealerHP = LYSettings[7][ShHex][2].LUA
			LYShHexHealerBurst = LYSettings[7][ShHex][3].LUA
			LYShHexDPS = LYSettings[7][ShHex][4].LUA
			LYShHexDPSHP = LYSettings[7][ShHex][5].LUA
			LYShHexDPSBurst = LYSettings[7][ShHex][6].LUA
			LYShHexDR = LYSettings[7][ShHex][7].LUA
			LYShHexCont = LYSettings[7][ShHex][8].LUA
			LYShHexFocus = LYSettings[7][ShHex][9].LUA
			LYShLassoKick = LYSettings[7][ShLightLasso][1].LUA
			LYShLassoHP = LYSettings[7][ShLightLasso][2].LUA
			LYShLassoBurst = LYSettings[7][ShLightLasso][3].LUA
			LYShLassoHealer = LYSettings[7][ShLightLasso][4].LUA
			LYShLassoHealerHP = LYSettings[7][ShLightLasso][5].LUA
			LYShLassoTeamBurst = LYSettings[7][ShLightLasso][6].LUA
			LYShLassoDPS = LYSettings[7][ShLightLasso][7].LUA
			LYShLassoDPSHP = LYSettings[7][ShLightLasso][8].LUA
			LYShLassoDPSBurst = LYSettings[7][ShLightLasso][9].LUA
			LYShLassoDR = LYSettings[7][ShLightLasso][10].LUA
			LYShLassoFocus = LYSettings[7][ShLightLasso][11].LUA
			LYShLassoHP = LYSettings[7][ShLightLasso][12].LUA
			LYShLMagma = LYSettings[7][ShLMagma][1].LUA
			LYShPulverHealer = LYSettings[7][ShPulver][1].LUA
			LYShPulverHealerHP = LYSettings[7][ShPulver][2].LUA
			LYShPulverHealerBurst = LYSettings[7][ShPulver][3].LUA
			LYShPulverDPS = LYSettings[7][ShPulver][4].LUA
			LYShPulverDPSHP = LYSettings[7][ShPulver][5].LUA
			LYShPulverDPSBurst = LYSettings[7][ShPulver][6].LUA
			LYShPulverDR = LYSettings[7][ShPulver][7].LUA
			LYShPulverCont = LYSettings[7][ShPulver][8].LUA
			LYShSkyTotemHP = LYSettings[7][ShSkyTotem][1].LUA
			LYShSkyTotemBurst = LYSettings[7][ShSkyTotem][2].LUA
			LYShSkyTotemKill = LYSettings[7][ShSkyTotem][3].LUA
			LYShSpiritLink = LYSettings[7][ShLink][1].LUA
			LYShSWalkRoot = LYSettings[7][ShSWalk][1].LUA
			LYShSWalkSlow = LYSettings[7][ShSWalk][2].LUA
			LYShSunderHP = LYSettings[7][ShSunder][1].LUA
			LYShSunderTeam = LYSettings[7][ShSunder][2].LUA
			LYShSunderBurst = LYSettings[7][ShSunder][3].LUA
			LYShSunderKick = LYSettings[7][ShSunder][4].LUA
			LYShSunderAOE = LYSettings[7][ShSunder][5].LUA
			LYShSunderCap = LYSettings[7][ShSunder][6].LUA
			LYShThunderHP = LYSettings[7][ShThunder][1].LUA
			LYShThunderBurst = LYSettings[7][ShThunder][2].LUA
			LYShThunderKick = LYSettings[7][ShThunder][3].LUA
			LYShTremorTime = LYSettings[7][ShTremor][1].LUA
			LYShTremorDPS = LYSettings[7][ShTremor][2].LUA
			LYShTremorEnemyHP = LYSettings[7][ShTremor][3].LUA
			LYShTremorTeamHP = LYSettings[7][ShTremor][4].LUA
			LYShTremorBurst = LYSettings[7][ShTremor][5].LUA
			LYShTremorInc = LYSettings[7][ShTremor][6].LUA
			LYShFreedomHealHP = LYSettings[7][ShFreedom][1].LUA
			LYShFreedomDPS = LYSettings[7][ShFreedom][2].LUA
			LYShFreedomTarHP = LYSettings[7][ShFreedom][3].LUA
			LYShWolf = LYSettings[7][ShWolf][1].LUA
			LYShManaTotem = LYSettings[7][ShManaTotem][1].LUA
			LYShHealStreamHP = LYSettings[7][ShHealStream][1].LUA
			LYShHealStreamBurst = LYSettings[7][ShHealStream][2].LUA
			LYShEarthShieldPlayer = LYSettings[7][ShEarthShield][1].LUA
			LYShEarthEleHP = LYSettings[7][ShEarthEle][1].LUA
			LYShWalker = LYSettings[7][ShWalker][1].LUA
			LYShChainHealHP = LYSettings[7][ShChainHeal][1].LUA
			LYShChainHealCount = LYSettings[7][ShChainHeal][2].LUA
			LYShChainHealTide = LYSettings[7][ShChainHeal][3].LUA
			LYShBlinkBurst = LYSettings[7][ShBlink][1].LUA
			LYShBlinkHP = LYSettings[7][ShBlink][2].LUA
			LYShNS = LYSettings[7][ShNS][1].LUA
			LYShBurrowHP = LYSettings[7][ShBurrow][1].LUA
			LYShBurrowBurst = LYSettings[7][ShBurrow][2].LUA
			LYShBurrowHealer = LYSettings[7][ShBurrow][3].LUA
			LYShHealWaveHP = LYSettings[7][ShHealWave][1].LUA
			LYWlAxesHealer = LYSettings[9][WlAxes][1].LUA
			LYWlAxesHealerHP = LYSettings[9][WlAxes][2].LUA
			LYWlAxesHealerBurst = LYSettings[9][WlAxes][3].LUA
			LYWlAxesDPS = LYSettings[9][WlAxes][4].LUA
			LYWlAxesDPSHP = LYSettings[9][WlAxes][5].LUA
			LYWlAxesDPSBurst = LYSettings[9][WlAxes][6].LUA
			LYWlAxesDR = LYSettings[9][WlAxes][7].LUA
			LYWlAxesCont = LYSettings[9][WlAxes][8].LUA
			LYWlAxesFocus = LYSettings[9][WlAxes][9].LUA
			LYWlAxesKick = LYSettings[9][WlAxes][9].LUA
			LYWlBane = LYSettings[9][WlBaneHavoc][1].LUA
			LYWlBilesBomber = LYSettings[9][WlBilesBomber][1].LUA
			LYWlBRush = LYSettings[9][WlBurning][1].LUA
			LYWlFellLordHP = LYSettings[9][WlFellLord][1].LUA
			LYWlFellLordBurst = LYSettings[9][WlFellLord][2].LUA
			LYWlCata = LYSettings[9][WlCata][1].LUA
			LYWlCurFragHP = LYSettings[9][WlCurFrag][1].LUA
			LYWlSacShieldHP = LYSettings[9][WlSacShield][1].LUA
			LYWlSacShieldBurst = LYSettings[9][WlSacShield][2].LUA
			LYWlSacShieldHealer = LYSettings[9][WlSacShield][3].LUA
			LYWlTPHP = LYSettings[9][WlTP2][1].LUA
			LYWlTPBurst = LYSettings[9][WlTP2][2].LUA
			LYWlTPHealer = LYSettings[9][WlTP2][3].LUA
			LYWlDrainHP = LYSettings[9][WlDrainLife][1].LUA
			LYWlDrainStack = LYSettings[9][WlDrainLife][2].LUA
			LYWlFearKick = LYSettings[9][WlFear][1].LUA
			LYWlFearHealer = LYSettings[9][WlFear][2].LUA
			LYWlFearHealerHP = LYSettings[9][WlFear][3].LUA
			LYWlFearHealerBurst = LYSettings[9][WlFear][4].LUA
			LYWlFearDPS = LYSettings[9][WlFear][5].LUA
			LYWlFearDPSHP = LYSettings[9][WlFear][6].LUA
			LYWlFearDPSBurst = LYSettings[9][WlFear][7].LUA
			LYWlFearDR = LYSettings[9][WlFear][8].LUA
			LYWlFearCont = LYSettings[9][WlFear][9].LUA
			LYWlFearFocus = LYSettings[9][WlFear][10].LUA
			LYWlFearWhileBurst = LYSettings[9][WlFear][11].LUA
			LYWlHavocDPS = LYSettings[9][WlChaos][1].LUA
			LYWlCoilKick = LYSettings[9][WlCoil][1].LUA
			LYWlCoilPlayerHP = LYSettings[9][WlCoil][2].LUA
			LYWlCoilHealer = LYSettings[9][WlCoil][3].LUA
			LYWlCoilHealerHP = LYSettings[9][WlCoil][4].LUA
			LYWlCoilHealerBurst = LYSettings[9][WlCoil][5].LUA
			LYWlCoilDPS = LYSettings[9][WlCoil][6].LUA
			LYWlCoilDPSHP = LYSettings[9][WlCoil][7].LUA
			LYWlCoilDPSBurst = LYSettings[9][WlCoil][8].LUA
			LYWlCoilDR = LYSettings[9][WlCoil][9].LUA
			LYWlCoilCont = LYSettings[9][WlCoil][10].LUA
			LYWlCoilFocus = LYSettings[9][WlCoil][11].LUA
			LYWlWardPlayerHP = LYSettings[9][WlNetherWard][1].LUA
			LYWlWardBurts = LYSettings[9][WlNetherWard][2].LUA
			LYWlWardEnemyHP = LYSettings[9][WlNetherWard][3].LUA
			LYWlRainFire = LYSettings[9][WlRainFire][1].LUA
			LYWlSedHealer = LYSettings[9][WlSeduction][1].LUA
			LYWlSedHealerHP = LYSettings[9][WlSeduction][2].LUA
			LYWlSedHealerBurst = LYSettings[9][WlSeduction][3].LUA
			LYWlSedDPS = LYSettings[9][WlSeduction][4].LUA
			LYWlSedDPSHP = LYSettings[9][WlSeduction][5].LUA
			LYWlSedDPSBurst = LYSettings[9][WlSeduction][6].LUA
			LYWlSedDR = LYSettings[9][WlSeduction][7].LUA
			LYWlSedCont = LYSettings[9][WlSeduction][8].LUA
			LYWlSedFocus = LYSettings[9][WlSeduction][9].LUA
			LYWlSeedCount = LYSettings[9][WlSeed][1].LUA
			LYWlDispelTime = LYSettings[9][WlDispelPet][1].LUA
			LYWlDispelTeamHP = LYSettings[9][WlDispelPet][2].LUA
			LYWlDispelHealer = LYSettings[9][WlDispelPet][3].LUA
			LYWlDispelEnemyHP = LYSettings[9][WlDispelPet][4].LUA
			LYWlDispelBurst = LYSettings[9][WlDispelPet][5].LUA
			LYWlSFHealer = LYSettings[9][WlSF][1].LUA
			LYWlSFHealerHP = LYSettings[9][WlSF][2].LUA
			LYWlSFHealerBurst = LYSettings[9][WlSF][3].LUA
			LYWlSFDPS = LYSettings[9][WlSF][4].LUA
			LYWlSFDPSHP = LYSettings[9][WlSF][5].LUA
			LYWlSFDPSBurst = LYSettings[9][WlSF][6].LUA
			LYWlSFDR = LYSettings[9][WlSF][7].LUA
			LYWlSFFocus = LYSettings[9][WlSF][8].LUA
			LYWlSFKick = LYSettings[9][WlSF][9].LUA
			LYWlPetType = LYSettings[9][WlSumPet][1].LUA
			LYWlMADefHP = LYSettings[9][WlMA][1].LUA
			LYWlMADefBurst = LYSettings[9][WlMA][2].LUA
			LYWlMADefHealer = LYSettings[9][WlMA][3].LUA
			LYWlURBurst = LYSettings[9][WlMA][4].LUA
			LYWlVileTaint = LYSettings[9][WlVileTaint][1].LUA
			LYWlVileTaintTar = LYSettings[9][WlVileTaint][2].LUA
			LYWlHowlTripple = LYSettings[9][WlHowl][1].LUA
			LYWlHowlKick = LYSettings[9][WlHowl][2].LUA
			LYWlUAIgnoreKick = LYSettings[9][WlUnstable][1].LUA
			LYWlChaosBoltSet = LYSettings[9][WlChaosBolt][1].LUA
			LYWrBSCount = LYSettings[1][WrBS][1].LUA
			LYWrBSBurst = LYSettings[1][WrBS][2].LUA
			LYWrBSKick = LYSettings[1][WrBS][3].LUA
			LYWrRoarCount = LYSettings[1][WrRoar][1].LUA
			LYWrRoarBurst = LYSettings[1][WrRoar][2].LUA
			LYWrBdGuardHP = LYSettings[1][WrBodyGuard][1].LUA
			LYWrBdGuardBurst = LYSettings[1][WrBodyGuard][2].LUA
			LYWrColosHP = LYSettings[1][WrColos][1].LUA
			LYWrColosBurst = LYSettings[1][WrColos][2].LUA
			LYWrColosCount = LYSettings[1][WrColos][3].LUA
			LYWrChargeKick = LYSettings[1][WrCharge][1].LUA
			LYWrChargeHealer = LYSettings[1][WrCharge][2].LUA
			LYWrChargeExecute = LYSettings[1][WrCharge][3].LUA
			LYWrChargeBurst = LYSettings[1][WrCharge][4].LUA
			LYWrChargeHP = LYSettings[1][WrCharge][5].LUA
			LYWrLeapKick = LYSettings[1][WrLeap][1].LUA
			LYWrLeapHealer = LYSettings[1][WrLeap][2].LUA
			LYWrLeapExecute = LYSettings[1][WrLeap][3].LUA
			LYWrDWishHP = LYSettings[1][WrDeathWish][1].LUA
			LYWrDWishAttack = LYSettings[1][WrDeathWish][2].LUA
			LYWrDWishHealer = LYSettings[1][WrDeathWish][3].LUA
			LYWrDStanceHP = LYSettings[1][WrDStance][1].LUA
			LYWrDStanceBurst = LYSettings[1][WrDStance][2].LUA
			LYWrDStance2 = LYSettings[1][WrDStance][3].LUA
			LYWrDStanceMyBurst = LYSettings[1][WrDStance][4].LUA
			LYWrDStanceStun = LYSettings[1][WrDStance][5].LUA
			LYWrDefShoutHP = LYSettings[1][WrDefShout][1].LUA
			LYWrDefShoutBurst = LYSettings[1][WrDefShout][2].LUA
			LYWrDefShoutHealer = LYSettings[1][WrDefShout][3].LUA
			LYWrDbSHP = LYSettings[1][WrDbS][1].LUA
			LYWrDbSBurst = LYSettings[1][WrDbS][2].LUA
			LYWrDbSHealer = LYSettings[1][WrDbS][3].LUA
			LYWrHealHP = LYSettings[1][WrHeal][1].LUA
			LYWrHealBurst = LYSettings[1][WrHeal][2].LUA
			LYWrHealHealer = LYSettings[1][WrHeal][3].LUA
			LYWrBitterImmuneHP = LYSettings[1][WrBitterImmune][1].LUA
			LYWrBitterImmuneBurst = LYSettings[1][WrBitterImmune][2].LUA
			LYWrBitterImmuneHealer = LYSettings[1][WrBitterImmune][3].LUA
			LYWrDisarmHP = LYSettings[1][WrDisarm][1].LUA
			LYWrDisarmBurst = LYSettings[1][WrDisarm][2].LUA
			LYWrDisarmHealer = LYSettings[1][WrDisarm][3].LUA
			LYWrDisarmColos = LYSettings[1][WrDisarm][4].LUA
			LYWrDisarmFocus = LYSettings[1][WrDisarm][5].LUA
			LYWrDuelHP = LYSettings[1][WrDuel][1].LUA
			LYWrDuelBurst = LYSettings[1][WrDuel][2].LUA
			LYWrFearHealer = LYSettings[1][WrFear][1].LUA
			LYWrFearHealerHP = LYSettings[1][WrFear][2].LUA
			LYWrFearBurst = LYSettings[1][WrFear][3].LUA
			LYWrFearDPS = LYSettings[1][WrFear][4].LUA
			LYWrFearDPSHP = LYSettings[1][WrFear][5].LUA
			LYWrFearDPSBurst = LYSettings[1][WrFear][6].LUA
			LYWrFearDR = LYSettings[1][WrFear][7].LUA
			LYWrFearCont = LYSettings[1][WrFear][8].LUA
			LYWrFearTrpl = LYSettings[1][WrFear][9].LUA
			LYWrFearKick = LYSettings[1][WrFear][10].LUA
			LYWrLastStandHP = LYSettings[1][WrLastStand][1].LUA
			LYWrLastStandHealer = LYSettings[1][WrLastStand][2].LUA
			LYWrRally = LYSettings[1][WrRaly][1].LUA
			LYWrInterHP = LYSettings[1][WrIntervene][1].LUA
			LYWrInterBurst = LYSettings[1][WrIntervene][2].LUA
			LYWrInterHeal = LYSettings[1][WrIntervene][3].LUA
			LYWrInterTrap = LYSettings[1][WrIntervene][4].LUA
			LYWrInterEx = LYSettings[1][WrIntervene][5].LUA
			LYWrInterCC = LYSettings[1][WrIntervene][6].LUA
			LYWrShBladeHP = LYSettings[1][WrSharpBlade][1].LUA
			LYWrShWallHP = LYSettings[1][WrShieldWall][1].LUA
			LYWrShWallBurst = LYSettings[1][WrShieldWall][2].LUA
			LYWrShWallHealer = LYSettings[1][WrShieldWall][3].LUA
			LYWrSWKick = LYSettings[1][WrSW][1].LUA
			LYWrSWTripple = LYSettings[1][WrSW][2].LUA
			LYWrSWHealer = LYSettings[1][WrSW][3].LUA
			LYWrSWHealerHP = LYSettings[1][WrSW][4].LUA
			LYWrSWHealerBurst = LYSettings[1][WrSW][5].LUA
			LYWrSWDPS = LYSettings[1][WrSW][6].LUA
			LYWrSWDPSHP = LYSettings[1][WrSW][7].LUA
			LYWrSWDPSBurst = LYSettings[1][WrSW][8].LUA
			LYWrSWDR = LYSettings[1][WrSW][9].LUA
			LYWrSWCont = LYSettings[1][WrSW][10].LUA
			LYWrReflDefHP = LYSettings[1][WrReflect][1].LUA
			LYWrReflDefBurst = LYSettings[1][WrReflect][2].LUA
			LYWrReflHealer = LYSettings[1][WrReflect][3].LUA
			LYWrReflCCHP = LYSettings[1][WrReflect][4].LUA
			LYWrReflCCBurst = LYSettings[1][WrReflect][5].LUA
			LYWrReflTrap = LYSettings[1][WrReflect][6].LUA
			LYWrBoltKick = LYSettings[1][WrBolt][1].LUA
			LYWrBoltHealer = LYSettings[1][WrBolt][2].LUA
			LYWrBoltHealerHP = LYSettings[1][WrBolt][3].LUA
			LYWrBoltBurst = LYSettings[1][WrBolt][4].LUA
			LYWrBoltDPS = LYSettings[1][WrBolt][5].LUA
			LYWrBoltDPSHP = LYSettings[1][WrBolt][6].LUA
			LYWrBoltDPSBurst = LYSettings[1][WrBolt][7].LUA
			LYWrBoltDR = LYSettings[1][WrBolt][8].LUA
			LYWrBoltCont = LYSettings[1][WrBolt][9].LUA
			LYWrBoltFocus = LYSettings[1][WrBolt][10].LUA
			LYWrBannerEnemyHP = LYSettings[1][WrBanner][1].LUA
			LYWrBannerBurst = LYSettings[1][WrBanner][2].LUA
			LYWrBannerDPS = LYSettings[1][WrBanner][3].LUA
			LYWrBannerTrap = LYSettings[1][WrBanner][4].LUA
			LYWrIgnorePainHP = LYSettings[1][WrIgnorePain][1].LUA
			LYWrIgnorePainBurst = LYSettings[1][WrIgnorePain][2].LUA
			LYWrIgnorePainHealer = LYSettings[1][WrIgnorePain][3].LUA
			LYWrPiercHowl = LYSettings[1][WrPiercHowl][1].LUA
			LYWrSwStrk = LYSettings[1][WrSwStrk][1].LUA
			LYWrDeathSentHP = LYSettings[1][WrDeathSent][1].LUA
			LYWrDeathSent = LYSettings[1][WrDeathSent][2].LUA
			if LYStyle == 1 then
				LYStyle = "All units"
			elseif LYStyle == 2 then
				LYStyle = "Only target"
			else
				LYStyle = "Utilities only"
			end
			if unlocker == "MB" and SetNameplateDistanceMax then
				if LYNamePlates == 0 then
					SetNameplateDistanceMax()
				else
					SetNameplateDistanceMax(LYNamePlates)
				end
				if LYCameraDist == 0 then
					SetCameraDistanceMax()
				else
					SetCameraDistanceMax(LYCameraDist)
					SetCVarEx("cameraDistanceMaxZoomFactor",100)
				end
			end
		end
		local function LYLoadDefaults()
			WriteFile(GetAppDirectory().."\\LegacyRT.txt","",false)
			ReloadUI()
		end
		local function LYSetNextLoad(filename)
			WriteFile(GetAppDirectory().."\\" .. "LYNextLoad" .. ".txt",filename,false)
			ReloadUI()
		end
		local function LYCheckNextLoad()
			if FileExists(GetAppDirectory().."\\" .. "LYNextLoad" .. ".txt") then
				local text = ReadFile(GetAppDirectory().."\\" .. "LYNextLoad" .. ".txt")
				if text and #text > 0 and FileExists(GetAppDirectory().."\\" .. text .. ".txt") then
					LYSettingsFile = text
					WriteFile(GetAppDirectory().."\\" .. "LYNextLoad" .. ".txt","",false)
					return true
				elseif text then
					print("CONFIG: " .. text .. " does not exist")
				end
			end
		end
		local function LYLoadSetting(filename)
			if not filename or filename == "" then filename = "LegacyRT" end
			LYSettingsFile = filename
			local function InitializeSpellTables()
				LYListHealInt = {
				DrRegr,
				DrWGrowth,
				DrTranq,
				DrNourish,
				PlFlash,
				PlHolyLight,
				PrFlash,
				PrHeal,
				PrPrayerHealing,
				PrPrayerMending,
				PrClarity,
				PrDivHymn,
				PrGreatHeal,
				PrPenance,
				PrUltPenance,
				MnSoothMist,
				MnEMist,
				MnUplift,
				ShChainHeal,
				ShHealWave,
				ShHealSurge,
				ShHealRain,
				WlDrainLife,
				EvDreamBreath,
				EvSpiritbloom,
				EvLivFlame
				}
				LYListKickPvE = {
				MendingWord,
				BwomsamdisMantle,
				UnstableHex,
				TerrifyingScreech,
				NoxiousStench,
				WrackingPain,
				UnnervingScreech,
				TormentingEye,
				BloodMetamorphosis,
				DreadInferno,
				Spellbind,
				PallidGlare,
				SoulVolley,
				Retch,
				Infest,
				RuinousVolley,
				HorrificVisage,
				DarkenedLightning,
				InfiniteBoltVolley,
				Enervate,
				DisplaceChronosequence,
				InfiniteBurn,
				FishBoltVolley,
				DizzyingSands,
				RocketBoltVolley,
				HealingWave,
				Felfrenzy,
				ChokingVines,
				EnragedGrowth,
				Pyroblast,
				Revitalize,
				ToxicBloom,
				Aquablast
				}
				LYListKickPvP = {
				DrClone,
				MgRingFrost,
				HnRevPet,
				PrMD,
				MgEle,
				MgGlacSpike,
				MgGrPyro,
				MgRayFrost,
				WlSF,
				ShLightLasso,
				CyclotBlast,
				FocusEnergy,
				Fleshcraft,
				DrConvSpirit,
				PrMindGame
				}
				LYListNotKick = {
				MgFBolt,
				MgPetBolt,
				ShLightning,
				ShChainL,
				WlTP1,
				MgScorch,
				MgFireBall,
				WlShadowBolt
				}
				LYDispelPvE = {
				RendingMaul,
				WrackingPain,
				UnstableHex,
				LingeringNausea,
				Wildfire,
				TerrifyingVisage,
				TerrifyingScreech,
				MoltenGold,
				VenomfangStrike,
				PileOfBones,
				BloodthirstyLeap,
				BrutalGlaive,
				SoulBlade,
				SoulEchoes,
				SoulVenom,
				GrievousTear,
				GrievousRip,
				CurseOfIsolation,
				DarksoulDrain,
				Despair,
				TormentingFear,
				FesteringRip,
				ScorchingShot,
				NightmareToxin,
				PoisonSpear,
				StranglingRoots,
				Stonebolt,
				Temposlice,
				Bloom,
				Chronoburst,
				ShearedLifespan,
				Chronomelt,
				SerratedArrows,
				SerratedAxe,
				Shrapnel,
				RendingCleave,
				SlobberingBite,
				TimelessCurse,
				SoggyBonk,
				OrbOfContemplation,
				CorrodingVolley,
				SparkOfTyr,
				InfiniteBurn,
				TimeStasis,
				Fireball,
				ChronalBurn,
				DizzyingSands,
				Immolate,
				GlacialFusion,
				Frostbolt,
				ChokingVines,
				Pyroblast,
				ColdFusion,
				VenomBurst,
				PoisonousClaws,
				ToxicBloom,
				DreadpetalPollen,
				GnarledRoots,
				WaveOfCorruption,
				LightningSurge,
				FlameShock,
				PoisonedSpear,
				RavagingLeap,
				JaggedNettles,
				TearingStrike,
				UnstableRunicMark,
				RunicMark,
				DreadMark,
				VirulentPathogen,
				InfectedThorn,
				DecayingTouch,
				FragmentSoul,
				Spellbind,
				HorrificVisage,
				SeveringSerpent
				}
				LYListTotems = {
				ShCap,
				ShTremor,
				ShTEarthBind,
				ShEarthGrab,
				ShLink,
				ShGround,
				ShSkyTotem,
				ShCSTotem,
				"Regenerating Wildseed"
				}
				LYPurgeList = {
				PlBoP,
				PrInfusion,
				ShWalker,
				WlNetherWard,
				ShBLA,
				ShBLH,
				MgTempShield,
				PrHolyWard,
				MgAlterTime,
				PlDivFavor,
				DrThorns,
				DrInner
				}
				LYListDoNotDispel = {
				WlUnstable,
				PrVTouch
				}
				LYBLSpells = {}
				LYBLUnits = {}
				LYReflectAlways = {
				WlChaosBolt,
				DrClone,
				PrMindGame,
				MgGrPyro
				}
				LYListDoNotHeal = {
				}
				LYListDispelPvP = {
				ShHex,
				PrMindGame,
				RgSepsis,
				}
				LYListBreakableCC = {
				AgentChaos,
				QuakingPalm,
				MnKarma,
				MnSap,
				MgPoly,
				MgRingFrost,
				PlRep,
				PlBlind,
				RgSap,
				RgGouge,
				RgBlind,
				ShHex,
				HnTrap,
				HnScatter,
				HnTrackerNet,
				DHImprison,
				DrHibernate,
				EvSleepWalk
				}
			end
			if filename == "" then
				InitializeSpellTables()
			end
			if #filename > 1 then
				if not FileExists(GetAppDirectory().."\\"..filename..".txt") then
					if filename == "LegacyRT" then
						WriteFile(GetAppDirectory().."\\"..filename..".txt","",false)
					else
						LY_Print("The file does not exist!","red")
						return
					end
				end
				local s = ""
				s = ReadFile(GetAppDirectory().."\\"..filename..".txt")
				if not s or s == "" or not string.find(s,"table14") then
					InitializeSpellTables()
				else
					LYListHealInt = {}
					LYListNotKick = {}
					LYListKickPvE = {}
					LYPurgeList = {}
					LYListTotems = {}
					LYDispelPvE = {}
					LYListKickPvP = {}
					LYBLSpells = {}
					LYBLUnits = {}
					LYReflectAlways = {}
					LYListDoNotDispel = {}
					LYListDoNotHeal = {}
					LYListDispelPvP = {}
					LYListBreakableCC = {}
				end
				if s and #s > 1 then
					--if not string.find(s,"table14") then
					--	LYLoadDefaults()
					--end
					local p1 = 0
					for i=1,string.len(s) do
						local equal = string.find(s,"=",p1)
						if equal then
							local coma = string.find(s,";",equal)
							local value = string.sub(s,equal+1,coma-1)
							local number = tonumber(value)
							local setting = string.sub(s,p1+1,equal-1)
							if not number then
								if value == "true" then
									value = true
								elseif value == "false" or value == "nil" then
									value = false
								end
							else
								value = number
							end
							if not string.find(setting,"table") or string.find(setting,"Unstable") then
								local iClass = string.find(setting,",")
								if iClass then
									local class = tonumber(string.sub(setting,1,iClass-1))
									local iV = string.find(setting,",",iClass+1)
									local v = string.sub(setting,iClass+1,iV-1)
									local x = tonumber(string.sub(setting,iV+1))
									if LYSettings[class][v] and LYSettings[class][v][x] and type(LYSettings[class][v][x].LUA) == type(value) then
										LYSettings[class][v][x].LUA = value
									end
								end
							else
								local p2 = 0
								for j=1,string.len(value) do
									local del = string.find(value,",",p2+1)
									if del then
										local spell = string.sub(value,p2,del-1)
										p2 = del+1
										if setting == "table1" then
											tinsert(LYListHealInt,spell)
										elseif setting == "table2" then
											tinsert(LYListNotKick,spell)
										elseif setting == "table3" then
											tinsert(LYListKickPvE,spell)
										elseif setting == "table4" then
											tinsert(LYListKickPvP,spell)
										elseif setting == "table5" then
											tinsert(LYPurgeList,spell)
										elseif setting == "table6" then
											tinsert(LYListTotems,spell)
										elseif setting == "table7" then
											tinsert(LYDispelPvE,spell)
										elseif setting == "table8" then
											tinsert(LYBLSpells,spell)
										elseif setting == "table9" then
											tinsert(LYBLUnits,spell)
										elseif setting == "table10" then
											tinsert(LYReflectAlways,spell)
										elseif setting == "table11" then
											tinsert(LYListDoNotDispel,spell)
										elseif setting == "table12" then
											tinsert(LYListDoNotHeal,spell)
										elseif setting == "table13" then
											tinsert(LYListDispelPvP,spell)
										elseif setting == "table14" then
											tinsert(LYListBreakableCC,spell)
										end
									else
										break
									end
								end
							end
							p1 = coma
						else
							break
						end
					end
				end
			end
			UpdateSettings()
		end
		if C_AddOns.IsAddOnLoaded("ElvUI") and FileExists(GetAppDirectory().."\\".."LegacySkinningELVUI"..".txt") and ReadFile(GetAppDirectory().."\\".."LegacySkinningELVUI"..".txt") == "true" then
			LYSkinELVUILoaded = true
		end
		local mainBD = {bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		tile = true, tileSize = 30, edgeSize = 30,
		insets = {left = 10, right = 10, top = 10, bottom = 10}}
		local blackBD = {bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
		edgeFile = "Interface/FriendsFrame/UI-Toast-Border",
		tile = true, tileSize = 10, edgeSize = 10,
		insets = {left = 5, right = 5, top = 5, bottom = 5}}
		local clearBD = {bgFile = nil,
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 0, right = 0, top = 0, bottom = 0}}
		local LegacyFrame = CreateFrame("Frame",nil,UIParent,BackdropTemplateMixin and "BackdropTemplate")
		LegacyFrame:SetFrameStrata("DIALOG")
		LegacyFrame:SetWidth(700)
		LegacyFrame:SetHeight(500)
		if not LYSkinELVUILoaded then
			LegacyFrame:SetBackdrop(mainBD)
			LegacyFrame:SetBackdropColor(0,0,0,1)
		end
		LegacyFrame:SetPoint("CENTER",0,0)
		LegacyFrame_SpellWarning = CreateFrame("Button","SpellWarning")
		LegacyFrame_SpellWarning:SetWidth(GetScreenHeight()*0.05)
		LegacyFrame_SpellWarning:SetHeight(GetScreenHeight()*0.05)
		LegacyFrame_SpellWarning:SetPoint("TOP",0,-GetScreenHeight()*0.07)
		local LegacyFrame_titleBG = LegacyFrame:CreateTexture(nil,"ARTWORK")
		LegacyFrame_titleBG:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
		LegacyFrame_titleBG:SetWidth(580)
		LegacyFrame_titleBG:SetHeight(65)
		LegacyFrame_titleBG:SetPoint("TOP",LegacyFrame,0,12)
		local LegacyFrame_titleText = LegacyFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		LegacyFrame_titleText:SetText("HandsFree Reborn")
		LegacyFrame_titleText:SetPoint("TOP",LegacyFrame,0,-3)
		LegacyFrame:EnableMouse(true)
		LegacyFrame:SetMovable(true)
		LegacyFrame:RegisterForDrag("LeftButton")
		LegacyFrame:SetScript("OnDragStart",LegacyFrame.StartMoving)
		LegacyFrame:SetScript("OnDragStop",LegacyFrame.StopMovingOrSizing)
		local LegacyFrameMap = CreateFrame("Button",UIParent,Minimap)
		LegacyFrameMap:SetFrameStrata("HIGH")
		LegacyFrameMap:SetWidth(31)
		LegacyFrameMap:SetHeight(31)
		LegacyFrameMap:RegisterForClicks("AnyUp")
		LegacyFrameMap:RegisterForDrag("RightButton")
		LegacyFrameMap:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")
		LegacyFrameMap:SetPoint("CENTER",55,75)
		local LYMinimapOverlay = LegacyFrameMap:CreateTexture(nil,"OVERLAY")
		LYMinimapOverlay:SetWidth(53)
		LYMinimapOverlay:SetHeight(53)
		LYMinimapOverlay:SetTexture("Interface/Minimap/MiniMap-TrackingBorder")
		LYMinimapOverlay:SetPoint("TOPLEFT")
		local LYMinimapBG = LegacyFrameMap:CreateTexture(nil,"BACKGROUND")
		LYMinimapBG:SetWidth(20)
		LYMinimapBG:SetHeight(20)
		LYMinimapBG:SetTexture("Interface/Minimap/UI-Minimap-Background")
		LYMinimapBG:SetPoint("TOPLEFT",7,-5)
		LYMinimapIcon = LegacyFrameMap:CreateTexture(nil,"ARTWORK")
		LYMinimapIcon:SetWidth(20)
		LYMinimapIcon:SetHeight(20)
		LYMinimapIcon:SetTexture("Interface/Icons/spell_arcane_portalorgrimmar")
		LYMinimapIcon:SetTexCoord(0.05,0.95,0.05,0.95)
		LYMinimapIcon:SetPoint("TOPLEFT",7,-5)
		local function HideUI()
			LegacyFrame:Hide()
		end
		local function LYSaveClose(filename)
			if not filename or filename == "" then
				filename = "LegacyRT"
			end
			LYSettingsFile = filename
			local s = ""
			for class in pairs(LYSettings) do
				if type(class) == "string" then
					s = s..class.."="..tostring(LYSettings[class].LUA)..";"
				else
					for i in pairs(LYSettings[class]) do
						for j=1,#LYSettings[class][i] do
							s = s..tostring(class)..","..tostring(i)..","..tostring(j).."="..tostring(LYSettings[class][i][j].LUA)..";"
						end
					end
				end
			end
			s = s.."table1="
			for i=1,#LYListHealInt do
				s = s..LYListHealInt[i]..","
			end
			s = s..";table2="
			for i=1,#LYListNotKick do
				s = s..LYListNotKick[i]..","
			end
			s = s..";table3="
			for i=1,#LYListKickPvE do
				s = s..LYListKickPvE[i]..","
			end
			s = s..";table4="
			for i=1,#LYListKickPvP do
				s = s..LYListKickPvP[i]..","
			end
			s = s..";table5="
			for i=1,#LYPurgeList do
				s = s..LYPurgeList[i]..","
			end
			s = s..";table6="
			for i=1,#LYListTotems do
				s = s..LYListTotems[i]..","
			end
			s = s..";table7="
			for i=1,#LYDispelPvE do
				s = s..LYDispelPvE[i]..","
			end
			s = s..";table8="
			for i=1,#LYBLSpells do
				s = s..LYBLSpells[i]..","
			end
			s = s..";table9="
			for i=1,#LYBLUnits do
				s = s..LYBLUnits[i]..","
			end
			s = s..";table10="
			for i=1,#LYReflectAlways do
				s = s..LYReflectAlways[i]..","
			end
			s = s..";table11="
			for i=1,#LYListDoNotDispel do
				s = s..LYListDoNotDispel[i]..","
			end
			s = s..";table12="
			for i=1,#LYListDoNotHeal do
				s = s..LYListDoNotHeal[i]..","
			end
			s = s..";table13="
			for i=1,#LYListDispelPvP do
				s = s..LYListDispelPvP[i]..","
			end
			s = s..";table14="
			for i=1,#LYListBreakableCC do
				s = s..LYListBreakableCC[i]..","
			end
			s = s..";"
			WriteFile(GetAppDirectory().."\\"..filename..".txt",s,false)
			UpdateSettings()
			local skinText = ""
			if LYElvUISkinning then skinText = "true" else skinText = "false" end
			WriteFile(GetAppDirectory().."\\".."LegacySkinningELVUI"..".txt",skinText,false)
			HideUI()
		end
		local MainList = CreateFrame("ScrollFrame",nil,LegacyFrame,BackdropTemplateMixin and "BackdropTemplate")
		MainList:SetHeight(185)
		MainList:SetWidth(157)
		MainList:SetPoint("CENTER",-233,120)
		if not LYSkinELVUILoaded then
			MainList:SetBackdrop(clearBD)
		end
		MainList.StartButton = CreateFrame("Button",nil,MainList,"GameMenuButtonTemplate")
		MainList.StartButton:SetPoint("CENTER",-40,-335)
		MainList.StartButton:SetText("START / STOP")
		MainList.StartButton:SetSize(120,30)
		MainList.StartButton:SetScript("OnClick",function() LY_StartStop() HideUI() end)
		MainList.SettingsButton = CreateFrame("Button",nil,MainList,"GameMenuButtonTemplate")
		MainList.SettingsButton:SetPoint("CENTER",100,-335)
		MainList.SettingsButton:SetText("Default Settings")
		MainList.SettingsButton:SetSize(120,30)
		MainList.SettingsButton:SetScript("OnClick",function() LYLoadDefaults() end)
		MainList.LoadSettingsButton = CreateFrame("Button",nil,MainList,"GameMenuButtonTemplate")
		MainList.LoadSettingsButton:SetPoint("CENTER", 240, -335)
		MainList.LoadSettingsButton:SetText("Load Settings")
		MainList.LoadSettingsButton:SetSize(120, 30)
		MainList.LoadSettingsButton:SetScript("OnClick", function()
			LYSetNextLoad(MainList.SettingsEditBox:GetText())
		end)
		MainList.CloseButton = CreateFrame("Button",nil,MainList,"GameMenuButtonTemplate")
		MainList.CloseButton:SetPoint("CENTER",380,-335)
		MainList.CloseButton:SetText("Save and Close")
		MainList.CloseButton:SetSize(120,30)
		MainList.CloseButton:SetScript("OnClick",function() LYSaveClose(MainList.SettingsEditBox:GetText()) end)
		MainList.SettingsEditBox = CreateFrame("EditBox", nil, MainList, "InputBoxTemplate")
		MainList.SettingsEditBox:SetPoint("CENTER", 510, -335)
		MainList.SettingsEditBox:SetSize(120, 30)
		MainList.SettingsEditBox:SetAutoFocus(false)
		MainList.SettingsEditBox:SetFontObject("GameFontHighlight")
		MainList.SettingsEditBox:SetTextInsets(8, 8, 0, 0)
		MainList.SettingsEditBox:SetMaxLetters(255)
		MainList.SettingsEditBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
		local MainListContent = CreateFrame("Frame",nil,MainList)
		MainListContent:SetSize(185,155)
		MainListContent.Items = {}
		local MainListTable = {
			"GENERAL",
			"CLASS",
			"TABLES"
		}
		MainList:SetScrollChild(MainListContent)
		local SecondList = CreateFrame("ScrollFrame",nil,LegacyFrame,"UIPanelScrollFrameTemplate")
		SecondList:SetHeight(180)
		SecondList:SetWidth(140)
		SecondList:SetPoint("CENTER",-241,-90)
		local SecondListContent = CreateFrame("Frame",nil,SecondList)
		SecondListContent:SetSize(180,140)
		SecondListContent.Items = {}
		SecondList:SetScrollChild(SecondListContent)
		local SecondListFrame = CreateFrame("Frame",nil,LegacyFrame,BackdropTemplateMixin and "BackdropTemplate")
		SecondListFrame:SetHeight(200)
		SecondListFrame:SetWidth(160)
		SecondListFrame:SetPoint("CENTER",-233,-90)
		if not LYSkinELVUILoaded then
			SecondListFrame:SetBackdrop(clearBD)
		end
		local ThirdList = CreateFrame("Frame",nil,LegacyFrame,BackdropTemplateMixin and "BackdropTemplate")
		ThirdList:SetHeight(403)
		ThirdList:SetWidth(450)
		ThirdList:SetPoint("CENTER",100,10)
		if not LYSkinELVUILoaded then
			ThirdList:SetBackdrop(clearBD)
		end
		local SpellTableMain = CreateFrame("Frame",nil,ThirdList,BackdropTemplateMixin and "BackdropTemplate")
		SpellTableMain:SetHeight(370)
		SpellTableMain:SetWidth(250)
		SpellTableMain:SetPoint("CENTER",0,0)
		if not LYSkinELVUILoaded then
			SpellTableMain:SetBackdrop(clearBD)
		end
		SpellTableMain:Hide()
		local SpellTableInput = CreateFrame("EditBox",nil,ThirdList,"InputBoxTemplate")
		SpellTableInput:SetWidth(153)
		SpellTableInput:SetHeight(20)
		SpellTableInput:SetPoint("CENTER",-27,160)
		SpellTableInput:SetAutoFocus(false)
		SpellTableInput:SetScript("OnEscapePressed",function (self) self:ClearFocus() self:SetText("") end)
		local SpellTableList = CreateFrame("ScrollFrame",nil,ThirdList,"UIPanelScrollFrameTemplate")
		SpellTableList:SetHeight(300)
		SpellTableList:SetWidth(200)
		SpellTableList:SetPoint("CENTER",-10,0)
		local SpellTableContent = CreateFrame("Frame",nil,SpellTableList)
		SpellTableContent:SetSize(200,600)
		SpellTableContent.Items = {}
		local SpellTableDeletButton = CreateFrame("Button",nil,ThirdList,"GameMenuButtonTemplate")
		SpellTableDeletButton:SetPoint("CENTER",-10,-165)
		SpellTableDeletButton:SetText("Delete")
		SpellTableDeletButton:SetSize(200,20)
		local SpellTableAddButton = CreateFrame("Button",nil,ThirdList,"GameMenuButtonTemplate")
		SpellTableAddButton:SetPoint("CENTER",70,160)
		SpellTableAddButton:SetText("Add")
		SpellTableAddButton:SetSize(40,20)
		SpellTableInput:Hide()
		SpellTableList:Hide()
		SpellTableContent:Hide()
		SpellTableDeletButton:Hide()
		SpellTableAddButton:Hide()
		if LYSkinELVUILoaded then
			local function ApplyElvUISkin()
				if not ElvUI then return end -- Make sure ElvUI is installed and active
				local E, L, V, P, G = unpack(ElvUI) -- Get ElvUI's API and configuration
				LYElvUIGlossTexture = E.media.glossTex
				LYElvUINormTexture = E.media.normTex
				LYElvUIValueColor = E.db.general.valuecolor
				local S = E:GetModule("Skins") -- Access ElvUI's Skinning module
				LYSkinELVUISkinModule = S
				LYSkinELVUISkinModule:HandleButton(SpellTableAddButton)
				LYSkinELVUISkinModule:HandleButton(SpellTableDeletButton)
				LYSkinELVUISkinModule:HandleButton(MainList.CloseButton)
				LYSkinELVUISkinModule:HandleButton(MainList.LoadSettingsButton)
				LYSkinELVUISkinModule:HandleButton(MainList.SettingsButton)
				LYSkinELVUISkinModule:HandleButton(MainList.StartButton)
				S:HandleScrollBar(SpellTableList.ScrollBar)
				S:HandleScrollBar(SecondList.ScrollBar)
				LYSkinELVUISkinModule:HandleEditBox(SpellTableInput)
				LYSkinELVUISkinModule:HandleEditBox(MainList.SettingsEditBox)
				LYSkinELVUISkinModule:HandleFrame(LegacyFrame)
				LYSkinELVUISkinModule:HandleFrame(MainList)
				LYSkinELVUISkinModule:HandleFrame(SpellTableList)
				LYSkinELVUISkinModule:HandleFrame(SecondList)
			end
			local E = unpack(ElvUI)
			ApplyElvUISkin()
		end
		local MainTabTable = {
			"NON-COMBAT",
			"COMMON",
			"HEALING",
			"DPS",
			"RACIAL",
			"KICK",
			"CONFIG"
		}
		local ClassTabTable = {}
		LYSettings = {
			[0] = {
				["NON-COMBAT"] = {
					[1] = {name = LYL["Notify bot actions"],Type = 2,LUA = true,Tooltip = LYL["Enable raid warnings visible to you only to indicate important bot's actions"]},
					[2] = {name = LYL["Always facing"],Type = 2,LUA = true,Tooltip = LYL["Attack any unit regardless if facing or not"]},
					[3] = {name = LYL["Smart pause"],Type = 2,LUA = false,Tooltip = LYL["Pause the bot when pressing a non-movement key on the keyboard"]},
					[4] = {name = LYL["Flag pick-up"],Type = 2,LUA = true,Tooltip = LYL["Auto pick up flags in BGs"]},
					[5] = {name = LYL["Auto buff"],Type = 2,LUA = true,Tooltip = LYL["Auto buff group"]},
					[6] = {name = LYL["Smart fake"],Type = 2,LUA = false,Tooltip = LYL["Attempt to fake kicks with a human behaviour"]},
					[7] = {name = LYL["Upper Trinket"],Type = 1,LUA = 8,Tooltip = LYL["1. Burst: when bursting\n2. CD: as soon as possible\n3.Boss: on bosses only\n4. LowPlayer: when player is < 20% HP\n5. LowTeam: when a team member is < 35% HP\n6. LowEnemy: when an enemy target is < 25% HP\n7. Stunned (Glad Medalion): when player is stunned for 5+sec and can die or has a chance to kill\n8.Disabled"]},
					[8] = {name = LYL["Lower Trinket"],Type = 1,LUA = 8,Tooltip = LYL["1. Burst: when bursting\n2. CD: as soon as possible\n3.Boss: on bosses only\n4. LowPlayer: when player is < 20% HP\n5. LowTeam: when a team member is < 35% HP\n6. LowEnemy: when an enemy target is < 25% HP\n7. Stunned (Glad Medalion): when player is stunned for 5+sec and can die or has a chance to kill\n8.Disabled"]},
					[9] = {name = LYL["Rotation delay, ms"],Type = 1,LUA = 0,Tooltip = LYL["Increase the value if you have FPS issues"]},
					[10] = {name = LYL["Reaction delay, ms"],Type = 1,LUA = 300,Tooltip = LYL["Humanize several actions (e.g. dispel) with reaction delay"]},
					[11] = {name = LYL["AutoFocus Healer"],Type = 2,LUA = false,Tooltip = LYL["Automatically focus an enemy healer in Arena"]},
					[12] = {name = LYL["AutoFocus Last Focus"],Type = 2,LUA = true,Tooltip = LYL["Automatically focus the unit you had previously in focus"]},
					[13] = {name = LYL["[HWT] Nameplates Distance"],Type = 1,LUA = 0,Tooltip = LYL["Sets the current nameplate visible distance maximum. 0 restores original setting"]},
					[14] = {name = LYL["[HWT] Camera Distance"],Type = 1,LUA = 0,Tooltip = LYL["Sets the current camera distance maximum. 0 restores original setting"]},
					[15] = {name = LYL["Play Notification Sound"],Type = 2,LUA = true,Tooltip = LYL["Enable sound for notifications."]},
					[16] = {name = LYL["[HWT] Auto Loot"],Type = 2,LUA = false,Tooltip = LYL["Enable Auto Loot Icon"]},
				},
				["COMMON"] = {
					[1] = {name = LYL["Combat Style"],Type = 1,LUA = 1,Tooltip = LYL["1. All units: hit/heal any enemy/friend if canât interact with target\n2. Only target: interract with the target only\n3. Utilities only: disable DPS/Healing and leave the utilities features (autokick,totem stomp etc.)"]},
					[2] = {name = LYL["[PvP] Ignore minor units"],Type = 2,LUA = true,Tooltip = LYL["Do not engage with minor units (e.g. pets and summoned creatures)"]},
					[3] = {name = LYL["HealthStone/CrimsonVial/PurifySoul"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[4] = {name = LYL["AutoCC stop movement alert"],Type = 2,LUA = true,Tooltip = LYL["Send an alert to stop movement to perform autoCC cast"]},
					[5] = {name = LYL["AutoCC force stop movement"],Type = 2,LUA = false,Tooltip = LYL["Force stop character movement to perform autoCC cast"]},
					[6] = {name = LYL["Battle Resurection"],Type = 2,LUA = true,Tooltip = LYL["Enable BR (CR) abilities auto use on tanks/team healers"]},
					[7] = {name = LYL["Stack defences"],Type = 2,LUA = false,Tooltip = LYL["Allow the bot use several defensive abilities at the same time"]},
					[8] = {name = LYL["Hit enemy healer"],Type = 2,LUA = true,Tooltip = LYL["Let the bot attack / DoT enemy healers"]},
				},
				["DPS"] = {
					[1] = {name = LYL["Burst by target HP"],Type = 1,LUA = 50,Tooltip = LYL["Burst when target is below set HP%"]},
					[2] = {name = LYL["Burst when Healer CCed"],Type = 2,LUA = true,Tooltip = LYL["Burts when enemy healer is CCed"]},
					[3] = {name = LYL["Burst when Team bursts"],Type = 2,LUA = true,Tooltip = LYL["Burts when a teammate is bursting"]},
					[4] = {name = LYL["Burst ignoring defs"],Type = 2,LUA = true,Tooltip = LYL["Burts regardless if the target has any defensive buffs"]},
					[5] = {name = LYL["Pick up Burst"],Type = 2,LUA = true,Tooltip = LYL["Detects burst buffs on player and enters Burst phase to use other burst spells"]},
					[6] = {name = LYL["[PvE] Auto Trash Burst"],Type = 2,LUA = true,Tooltip = LYL["Allow auto burst on trash in PvE"]},
					[7] = {name = LYL["[PvP] Gap closer"],Type = 2,LUA = true,Tooltip = LYL["Follow the target after blink-like abilities with Charge and similar available abilities"]},
					[8] = {name = LYL["[PvP] Mark Team healer"],Type = 2,LUA = true,Tooltip = LYL["Track team healer: green line - can interract,red line - not in LoS/range"]},
					[9] = {name = LYL["[PvP] Mark 2nd DPS Target"],Type = 2,LUA = true,Tooltip = LYL["Track your partner DPS' target: yellow circle under the unit"]},
					[10] = {name = LYL["Defensive Dispel"],Type = 2,LUA = true,Tooltip = LYL["Dispel any debuffs that your class can when you have a free GCD"]},
					[11] = {name = LYL["Max units to DoT"],Type = 1,LUA = 0,Tooltip = LYL["Set maximum number of enemies to DoT,where 0 - unlimited"]},
					[12] = {name = LYL["Passive purge MP"],Type = 1,LUA = 75,Tooltip = LYL["Allow passive purging enemies if above set MP%"]},
					[13] = {name = LYL["[PvP] Pet on healer"],Type = 2,LUA = true,Tooltip = LYL["Keep pet on enemy healer to prevent drinking etc."]},
					[14] = {name = LYL["Only heal @self"],Type = 2,LUA = false,Tooltip = LYL["Only use heal spells on self"]},
					[15] = {name = LYL["[PvP] Smart slow target"],Type = 2,LUA = true,Tooltip = LYL["Slow target only if whether the player chases the target or the other way around"]},
					[16] = {name = LYL["[PvP] Always slow target"],Type = 2,LUA = false,Tooltip = LYL["Always keep a slow on your target if it's not already slowed or immune"]},
					[17] = {name = LYL["[PvP] Peel team healer"],Type = 2,LUA = false,Tooltip = LYL["Slow enemy DPS attacking team healer when low HP or bursted"]},
					[18] = {name = LYL["[PvP] Peel any teammate"],Type = 2,LUA = false,Tooltip = LYL["Slow enemy DPS attacking any teammate when low HP or bursted"]},
				},
				["HEALING"] = {
					[1] = {name = LYL["Dispel HP"],Type = 1,LUA = 30,Tooltip = LYL["Enable AutoDispel only if all group members are above set HP%"]},
					[2] = {name = LYL["Dispel CC timer"],Type = 1,LUA = 3,Tooltip = LYL["Dispel CC with debuff time greater than the set number in seconds"]},
					[3] = {name = LYL["Dispel roots timer"],Type = 1,LUA = 4,Tooltip = LYL["Dispel roots from MELEE teammates with debuff time greater than the set number in seconds"]},
					[4] = {name = LYL["Dispel DoTs count"],Type = 1,LUA = 0,Tooltip = LYL["Minimum number of DoTs to be dispelled"]},
					[5] = {name = LYL["Dispel DoTs by HP"],Type = 1,LUA = 0,Tooltip = LYL["Dispel DoTs when a teammate is below set HP%"]},
					[6] = {name = LYL["Dispel any debuff in PvE"],Type = 2,LUA = false,Tooltip = LYL["Auto Dispel any debuff on teammates on dungeons and raids"]},
					[7] = {name = LYL["Enable DPS by MP"],Type = 1,LUA = 80,Tooltip = LYL["DPS enemies when there is noone to heal and MP above set value"]},
					[8] = {name = LYL["Track enemy kicks"],Type = 2,LUA = false,Tooltip = LYL["Track enemy interrupts: green line - free cast,red line - can be kicked"]},
					[9] = {name = LYL["Track teammates"],Type = 2,LUA = true,Tooltip = LYL["Track teammates in arena: green line - can interract,red line - not in LoS/range"]},
					[10] = {name = LYL["Purge HP"],Type = 1,LUA = 70,Tooltip = LYL["Enable AutoPurge only if all group members are above set HP%"]},
				},
				["RACIAL"] = {
					[1] = {name = LYL["Shadow Meld CC by Enemy HP"],Type = 1,LUA = 50,Tooltip = LYL["Meld incoming CC when an enemy is below set HP%"]},
					[2] = {name = LYL["Shadow Meld CC when bursting"],Type = 2,LUA = true,Tooltip = LYL["Meld incoming CC when player is bursting"]},
					[3] = {name = LYL["Racials during burst"],Type = 2,LUA = true,Tooltip = LYL["Use Berserking / BloodFury when bursting"]},
					[4] = {name = LYL["Racials to kick"],Type = 2,LUA = true,Tooltip = LYL["Use WarStomp / QuakingPalm / BullRush as an alternative kick ability"]},
					[5] = {name = LYL["Racials defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Use GiftNaaru / DwarfSkin when a teammate is below set HP%"]},
					[6] = {name = LYL["Racials as DPS"],Type = 2,LUA = true,Tooltip = LYL["Use RocketBarrage / LightJudgment / Bag of Tricks as part of DPS rotation"]},
					[7] = {name = LYL["Racials antisnare by HP"],Type = 1,LUA = 50,Tooltip = LYL["Use EscapeArtist / DarkFlight when a target is not in range and below set HP%"]},
					[8] = {name = LYL["Racials antisnare timer"],Type = 1,LUA = 4,Tooltip = LYL["Use EscapeArtist / DarkFlight when a target is not in range and you are snared with debuff time greater than the set number in seconds"]},
				},
				["KICK"] = {
					[1] = {name = LYL["Kick interval start"],Type = 1,LUA = 60,Tooltip = LYL["Random kick interval's cast time start value %"]},
					[2] = {name = LYL["Kick interval end"],Type = 1,LUA = 80,Tooltip = LYL["Random kick interval's cast time end value %"]},
					[3] = {name = LYL["Channeled kick delay"],Type = 1,LUA = 300,Tooltip = LYL["A delay before kicking a channeled cast in random interval in MS between set value + 300"]},
					[4] = {name = LYL["Cast min time to kick"],Type = 1,LUA = 600,Tooltip = LYL["Minimum cast time of a spell to be kicked in MS"]},
					[5] = {name = LYL["Don't kick if a mate can"],Type = 2,LUA = false,Tooltip = LYL["Hold your kick if a teammate can (CD,LoS,range checks)"]},
					[6] = {name = LYL["Kick only focus"],Type = 2,LUA = false,Tooltip = LYL["Kick only @focus if fits the rest of kick settings"]},
					[7] = {name = LYL["[PvP] Kick heals <HP"],Type = 1,LUA = 80,Tooltip = LYL["Kick heals if any enemy is below set HP%"]},
					[8] = {name = LYL["[PvP] Ignore DPS heals"],Type = 2,LUA = true,Tooltip = LYL["Ignore heals cast by DPS enemies"]},
					[9] = {name = LYL["[PvP] Kick DPS <HP"],Type = 1,LUA = 35,Tooltip = LYL["Kick DPS if any teammate is below set HP%"]},
					[10] = {name = LYL["[PvP] Kick DPS bursting"],Type = 2,LUA = true,Tooltip = LYL["Kick bursting enemy DPS"]},
					[11] = {name = LYL["[PvP] Kick CC @player"],Type = 2,LUA = true,Tooltip = LYL["Always kick CC cast on player"]},
					[12] = {name = LYL["[PvP] Kick CC if bursting"],Type = 2,LUA = true,Tooltip = LYL["Kick CC cast on player or teammates when bursting"]},
					[13] = {name = LYL["[PvP] Kick CC DR counter"],Type = 1,LUA = 0,Tooltip = LYL["0 = no DR,1 = 1/2 DR,2 = 1/4 DR"]},
					[14] = {name = LYL["[PvP] Kick chain CC"],Type = 2,LUA = false,Tooltip = LYL["Kick CC only if the unit is already CCed"]},
				},
				["CONFIG"] = {
					[1] = {name = LYL["Load Settings By Class Name"],Type = 2,LUA = false,Tooltip = LYL["Automatically loads settings based on clased name, i.e. druid.txt, mage.txt, etc."]},
					[2] = {name = LYL["Use ElvUI Skinning"],Type = 2,LUA = true,Tooltip = LYL["Uses ElvUI skinning for HF frames"]},
					[3] = {name = LYL["Macro Command"],Type = 3,LUA = "ly",Tooltip = LYL["Macro command prefix"]},
				}
			},
			[1] = {
				[WrBS] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
					[2] = {name = LYL["When bursting"],Type = 2,LUA = true,Tooltip = LYL["Cast the spell only when bursting"]},
					[3] = {name = LYL["Cancel to kick"],Type = 2,LUA = true,Tooltip = LYL["Cancel BS to kick a cast at the end, according to kick settings if in melee range"]},
				},
				[WrRoar] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
					[2] = {name = LYL["When bursting"],Type = 2,LUA = true,Tooltip = LYL["Cast the spell only when bursting"]},
				},
				[WrBodyGuard] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[WrCharge] = {
					[1] = {name = LYL["Gap closer to kick"],Type = 2,LUA = true,Tooltip = LYL["When not in range to perform kick"]},
					[2] = {name = LYL["Only @Healer"],Type = 2,LUA = false,Tooltip = LYL["Only cats at enemy healer to perform kick"]},
					[3] = {name = LYL["Gap closer to execute"],Type = 1,LUA = 35,Tooltip = LYL["When not in range to execute and player is above set HP"]},
					[4] = {name = LYL["Gap closer when bursting"],Type = 2,LUA = true,Tooltip = LYL["When bursting and target is not in range"]},
					[5] = {name = LYL["Gap closer by HP"],Type = 1,LUA = 25,Tooltip = LYL["When target is belowe set HP% and is not in range"]},
				},
				[WrLeap] = {
					[1] = {name = LYL["Gap closer to kick"],Type = 2,LUA = true,Tooltip = LYL["When not in range to perform kick"]},
					[2] = {name = LYL["Only @Healer"],Type = 2,LUA = false,Tooltip = LYL["Only cats at enemy healer to perform kick"]},
					[3] = {name = LYL["Gap closer to execute"],Type = 1,LUA = 35,Tooltip = LYL["When not in range to execute and player is above set HP"]},
				},
				[WrColos] = {
					[1] = {name = LYL["By target HP"],Type = 1,LUA = 35,Tooltip = LYL["When target is below set HP%"]},
					[2] = {name = LYL["When bursting"],Type = 2,LUA = true,Tooltip = LYL["Cast the spell only when bursting"]},
					[3] = {name = LYL["[WarBreaker] Enemies around"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[WrDeathWish] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 50,Tooltip = LYL["Only if layer is above set HP%"]},
					[2] = {name = LYL["Not under attack"],Type = 2,LUA = false,Tooltip = LYL["Only if player is not under attack"]},
					[3] = {name = LYL["Under heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can interact with player"]},
				},
				[WrDStance] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 70,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["When bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Enemies count"],Type = 1,LUA = 2,Tooltip = LYL["Player is under attack by the set amount of enemies"]},
					[4] = {name = LYL["Disable when bursting"],Type = 2,LUA = true,Tooltip = LYL["Go Battle Stance when bursting"]},
					[5] = {name = LYL["Catch stunns"],Type = 2,LUA = true,Tooltip = LYL["Try to cast before incoming stuns"]},
				},
				[WrDefShout] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Player or a teammate (if PvP talent selected) is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player or a teammate (if PvP talent selected) is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[WrDbS] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[WrBitterImmune] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[WrHeal] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[WrDisarm] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = true,Tooltip = LYL["If team healer can't interact with player"]},
					[4] = {name = LYL["Defensive under damage debuff"],Type = 2,LUA = true,Tooltip = LYL["A teammate is under a major damage debuff, e.g. Colossus Smash"]},
					[5] = {name = LYL["@focus only"],Type = 2,LUA = false,Tooltip = LYL["Use the spell @focus unit only"]},
				},
				[WrDuel] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[WrFear] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 60,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 25,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["Tripple"],Type = 2,LUA = true,Tooltip = LYL["Cast the spell if it can cover at least 3 enemies"]},
					[10] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[WrLastStand] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 20,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[WrRaly] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[WrIntervene] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["If team healer can't interact with player"]},
					[4] = {name = LYL["Catch Freezing Trap"],Type = 2,LUA = true,Tooltip = LYL["Catch Freezing Trap fired @Team Healer"]},
					[5] = {name = LYL["Gap closer to execute"],Type = 1,LUA = 35,Tooltip = LYL["When not in range to execute and player is above set HP"]},
					[6] = {name = LYL["AntiCC"],Type = 2,LUA = true,Tooltip = LYL["Intervene a teammate to redirect daamage and break CC of yourself after"]},
				},
				[WrSharpBlade] = {
					[1] = {name = LYL["By target HP"],Type = 1,LUA = 100,Tooltip = LYL["Use the spell as part of DPS rotation when enemy target is below set HP%"]},
				},
				[WrShieldWall] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[WrSW] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["Tripple"],Type = 2,LUA = true,Tooltip = LYL["Cast the spell if it can cover at least 3 enemies"]},
					[3] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[4] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[5] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[6] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[7] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[8] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[9] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[10] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
				},
				[WrReflect] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["AntiCC by HP"],Type = 1,LUA = 40,Tooltip = LYL["Avoid incoming CC when an enemy is below set HP%"]},
					[5] = {name = LYL["AntiCC when bursting"],Type = 2,LUA = true,Tooltip = LYL["Avoid incoming CC when bursting"]},
					[6] = {name = LYL["Catch Freezing Trap"],Type = 2,LUA = true,Tooltip = LYL["Catch Freezing Trap fired @self"]},
				},
				[WrBolt] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 70,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 30,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[WrBanner] = {
					[1] = {name = LYL["AntiCC by HP"],Type = 1,LUA = 50,Tooltip = LYL["Avoid incoming CC when an enemy is below set HP%"]},
					[2] = {name = LYL["AntiCC when bursting"],Type = 2,LUA = true,Tooltip = LYL["Avoid incoming CC when bursting"]},
					[3] = {name = LYL["Allow cast @DPS teammates"],Type = 2,LUA = false,Tooltip = LYL["Let the spell be cast @teammate DPS players or at player only"]},
					[4] = {name = LYL["Catch Freezing Trap"],Type = 2,LUA = true,Tooltip = LYL["Catch Freezing Trap fired @Team Healer"]},
				},
				[WrIgnorePain] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[WrPiercHowl] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[WrSwStrk] = {
					[1] = {name = LYL["Only for Unhinged"],Type = 2,LUA = false,Tooltip = LYL["Cast the spell only when bladestorming with Unhinged Runecarving Power, otherwise any time when 2 enemies are nearby"]},
				},
				[WrDeathSent] = {
					[1] = {name = LYL["Player HP"],Type = 1,LUA = 50,Tooltip = LYL["Death Sentence charge to execute for Sudden Death proc or Condemn only if player is above set HP%"]},
					[2] = {name = LYL["@target only"],Type = 2,LUA = false,Tooltip = LYL["Allow only on your target. Otherwise any unit"]},
				}
			},
			[2] = {
				[PlDefender] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 10,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[PlWings] = {
					[1] = {name = LYL["[Holy] Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["[Holy] Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["[Holy] Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[4] = {name = LYL["[Holy] Teammates HP"],Type = 1,LUA = 70,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[PlMA] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[4] = {name = LYL["Teammates HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[PlBeacon] = {
					[1] = {name = LYL["Auto use"],Type = 2,LUA = true,Tooltip = LYL["Enable automatic Beacons usage"]},
					[2] = {name = LYL["@player only"],Type = 2,LUA = false,Tooltip = LYL["Only cast a beacon on the player"]},
				},
				[PlFreedom] = {
					[1] = {name = LYL["AntiRoot timer"],Type = 1,LUA = 4,Tooltip = LYL["Roots time is greater than the set number in seconds"]},
					[2] = {name = LYL["AntiRoot team healer by HP"],Type = 1,LUA = 40,Tooltip = LYL["When team healer is rooted and below set HP%"]},
					[3] = {name = LYL["Allow cast @DPS teammates"],Type = 2,LUA = true,Tooltip = LYL["Let the spell be cast @teammate DPS players or @player only if disabled"]},
					[4] = {name = LYL["Antisnare by enemy HP"],Type = 1,LUA = 40,Tooltip = LYL["When DPS teammate is rooted and his target is below set HP%"]},
				},
				[PlBoP] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Allow cast @DPS teammates"],Type = 2,LUA = true,Tooltip = LYL["Let the spell be cast @teammate DPS players"]},
					[4] = {name = LYL["Stun timer"],Type = 1,LUA = 4,Tooltip = LYL["Stun time is greater than the set number in seconds"]},
					[5] = {name = LYL["Stun team HP"],Type = 1,LUA = 50,Tooltip = LYL["When a teammate is stunned and below set HP%"]},
					[6] = {name = LYL["Stun enemy HP"],Type = 1,LUA = 50,Tooltip = LYL["When a teammate is stunned and his target is below set HP%"]},
					[7] = {name = LYL["@Touch of Karma"],Type = 2,LUA = true,Tooltip = LYL["Allow using on enemy Monk's Karma"]},
					[8] = {name = LYL["[PvE] Allow on Tanks"],Type = 2,LUA = true,Tooltip = LYL["Allow using on tanks"]},
				},
				[PlSac] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP% when no MAGE / WARLOCK around"]},
					[2] = {name = LYL["AntiCC by HP"],Type = 1,LUA = 85,Tooltip = LYL["Catch incoming CC when a teammate is below set HP%"]},
					[3] = {name = LYL["Anti Smoke Bomb"],Type = 2,LUA = true,Tooltip = LYL["Sac teammate on enemy Rogue's Smoke Bomb"]},
				},
				[PlSanctuary] = {
					[1] = {name = LYL["Dispel CC timer"],Type = 1,LUA = 4,Tooltip = LYL["Dispel CC with debuff time greater than the set number in seconds"]},
					[2] = {name = LYL["Dispel CC @team healer by HP"],Type = 1,LUA = 70,Tooltip = LYL["Dispel team healer when a teammate is below set HP%"]},
					[3] = {name = LYL["Allow cast @DPS teammates"],Type = 2,LUA = true,Tooltip = LYL["Let the spell be cast @teammate DPS players"]},
					[4] = {name = LYL["Dispel CC by enemy HP"],Type = 1,LUA = 40,Tooltip = LYL["Dispel a DPS teammate when his target is below set HP%"]},
					[5] = {name = LYL["Dispel CC when bursting"],Type = 2,LUA = true,Tooltip = LYL["Dispel a DPS teammate when he is bursting"]},
				},
				[PlBlind] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 50,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 30,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Alternative kick"],Type = 2,LUA = false,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[PlSearingGlare] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 2,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 30,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[3] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[4] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
				},
				[PlGuardKings] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[PlDevProt] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["Stun timer"],Type = 1,LUA = 4,Tooltip = LYL["Stun time is greater than the set number in seconds"]},
					[5] = {name = LYL["Stun HP"],Type = 1,LUA = 80,Tooltip = LYL["When player is stunned and below set HP%"]},
				},
				[PlDivFavor] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 70,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[PlMartyr] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[PlBubble] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 15,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[PlEye] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[PlFlash] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is below set HP%"]},
				},
				[PlHolyLight] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 85,Tooltip = LYL["Teammate is below set HP%"]},
				},
				[PlHoJ] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[10] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[PlAvenger] = {
					[1] = {name = LYL["[Holy] Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["[Holy] Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["[Holy] Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[4] = {name = LYL["[Holy] Teammates HP"],Type = 1,LUA = 70,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[PlLoH] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 15,Tooltip = LYL["Teammate or player is under attack and below set HP%"]},
				},
				[PlRep] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 50,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[10] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[PlShieldVeng] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[PlGlory] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 85,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[PlTyrDev] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[4] = {name = LYL["Teammates HP"],Type = 1,LUA = 85,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[PlHandDiv] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
			},
			[3] = {
				[HnEagleBurst] = {
					[1] = {name = LYL["By target HP"],Type = 1,LUA = 70,Tooltip = LYL["Burst when target is below set HP%"]},
				},
				[HnDeter] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 15,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[HnBindShot] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 2,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
				},
				[HnBurstShot] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["Defensive by HP"],Type = 1,LUA = 60,Tooltip = LYL["Player is under attack and below set HP%"]},
					[3] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
				},
				[HnCallPetName] = {
					[1] = {name = LYL["Summon Pet"],Type = 1,LUA = 1,Tooltip = LYL["0 - Disabled,1 - pet1,2 - pet2,3 - pet3,4 - pet4,5 - pet5"]},
				},
				[HnHeal] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[HnFD] = {
					[1] = {name = LYL["By HP"],Type = 1,LUA = 10,Tooltip = LYL["Set player's HP% to use FD"]},
					[2] = {name = LYL["AntiCC by HP"],Type = 1,LUA = 40,Tooltip = LYL["Avoid incoming CC when an enemy is below set HP%"]},
					[3] = {name = LYL["AntiCC when bursting"],Type = 2,LUA = true,Tooltip = LYL["Avoid incoming CC when bursting"]},
					[4] = {name = LYL["AntiDPS by HP"],Type = 1,LUA = 40,Tooltip = LYL["Avoid incoming major DPS spell when player is below set HP%"]},
				},
				[HnTrap] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[HnTrackerNet] =  {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[HnExpTrap] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[3] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[HnInterlope] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[HnIntimid] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 30,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[HnFreedom] = {
					[1] = {name = LYL["AntiRoot timer"],Type = 1,LUA = 4,Tooltip = LYL["Roots time is greater than the set number in seconds"]},
					[2] = {name = LYL["AntiRoot team healer by HP"],Type = 1,LUA = 40,Tooltip = LYL["When team healer is rooted and below set HP%"]},
					[3] = {name = LYL["Allow cast @DPS teammates"],Type = 2,LUA = true,Tooltip = LYL["Let the spell be cast @teammate DPS players or @player only if disabled"]},
					[4] = {name = LYL["Antisnare by enemy HP"],Type = 1,LUA = 35,Tooltip = LYL["When DPS teammate is rooted and his target is below set HP%"]},
				},
				[HnHarpoon] = {
					[1] = {name = LYL["Auto use"],Type = 2,LUA = true,Tooltip = LYL["Enable to reach target with Terms of Engagement talent"]},
				},
				[HnPetSac] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[HnScatter] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 30,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[HnVolley] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[HnRapidFire] = {
					[1] = {name = LYL["in DPS rotation"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as part of DPS rotation or hold for Double Tap buff"]},
				},
				[HnSurvFit] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[HnFortBear] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
				},
				[HnTarTrap] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				}
			},
			[4] = {
				[RgBlind] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 50,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 25,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[10] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[RgCheap] = {
					[1] = {name = LYL["Stun any player"],Type = 2,LUA = true,Tooltip = LYL["Stun any enemy player with Cheap Shot when no DR"]},
					[2] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[3] = {name = LYL["DR check off-targets"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[4] = {name = LYL["DR check @target"],Type = 1,LUA = 1,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[5] = {name = LYL["Cast Shadow Dance to stun-kick"],Type = 2,LUA = true,Tooltip = LYL["Allow casting Shadow Dance to kick a cast with Cheap Shot"]},
					[6] = {name = LYL["Allow @target"],Type = 2,LUA = true,Tooltip = LYL["Allow casting Cheap Shot on your target. Otherwise on off-targets only"]},
				},
				[RgCloak] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["AntiCC by HP"],Type = 1,LUA = 35,Tooltip = LYL["Avoid incoming CC when an enemy is below set HP%"]},
					[5] = {name = LYL["AntiCC when bursting"],Type = 2,LUA = true,Tooltip = LYL["Avoid incoming CC when bursting"]},
				},
				[RgCrimson] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[RgDisarm] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive when healer CCed"],Type = 2,LUA = true,Tooltip = LYL["Team healer is CCed 6+ sec"]},
					[4] = {name = LYL["Defensive under damage debuff"],Type = 2,LUA = true,Tooltip = LYL["A teammate is under a major damage debuff, e.g. Colossus Smash"]},
					[5] = {name = LYL["@focus only"],Type = 2,LUA = false,Tooltip = LYL["Use the spell @focus unit only"]},
				},
				[RgFeint] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 65,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[RgEvis] = {
					[1] = {name = LYL["DfA / Evis / Enven priority by HP"],Type = 1,LUA = 35,Tooltip = LYL["Prioritize the one-hit spell over DoT finishers when an enemy is below set HP%"]},
				},
				[RgGouge] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 70,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[RgKidney] = {
					[1] = {name = LYL["Stun any player"],Type = 2,LUA = false,Tooltip = LYL["Stun any enemy player with Kidney Shot / Between the Eyes when no DR"]},
					[2] = {name = LYL["Stun any healer"],Type = 2,LUA = true,Tooltip = LYL["Stun any enemy healer with Kidney Shot / Between the Eyes when no DR"]},
					[3] = {name = LYL["[PvE] Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[RgEvasion] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[RgShStep] = {
					[1] = {name = LYL["Gap closer to kick"],Type = 2,LUA = true,Tooltip = LYL["When not in range to perform kick"]},
					[2] = {name = LYL["Catch Freezing Trap"],Type = 2,LUA = true,Tooltip = LYL["Catch Freezing Trap fired @Team Healer"]},
					[3] = {name = LYL["Gap closer when bursting"],Type = 2,LUA = true,Tooltip = LYL["When bursting and target is not in range"]},
					[4] = {name = LYL["Gap closer by HP"],Type = 1,LUA = 25,Tooltip = LYL["When target is belowe set HP% and is not in range"]},
				},
				[RgShadDuel] = {
					[1] = {name = LYL["Enable when bursting"],Type = 2,LUA = true,Tooltip = LYL["Enable when bursting"]},
					[2] = {name = LYL["Offensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Cast at enemy healer when an enemy DPS is below set HP%"]},
				},
				[RgBomb] = {
					[1] = {name = LYL["Offensive bursting"],Type = 2,LUA = true,Tooltip = LYL["Player is bursting"]},
					[2] = {name = LYL["Offensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Enemy target is below set HP%"]},
					[3] = {name = LYL["Offensive when stunned"],Type = 2,LUA = false,Tooltip = LYL["Only if target is stunned"]},
					[4] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[5] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[RgStealth] = {
					[1] = {name = LYL["Auto use"],Type = 2,LUA = true,Tooltip = LYL["Enable auto stealth"]},
				},
				[RgVanish] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 20,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["Offensive bursting"],Type = 2,LUA = true,Tooltip = LYL["Player is bursting"]},
				},
				[RgColdblood] = {
					[1] = {name = LYL["Offensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Enemy target is below set HP%"]},
				},
			},
			[5] = {
				[PrApotheosis] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[PrArchangel] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[PrDespPrayer] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
				},
				[PrDispers] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 15,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[PrInnerLight] = {
					[1] = {name = LYL["Teammates HP"],Type = 1,LUA = 45,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[PrDivHymn] = {
					[1] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[2] = {name = LYL["Teammates HP"],Type = 1,LUA = 65,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[PrWings] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[PrHolyWard] = {
					[1] = {name = LYL["AntiCC by HP"],Type = 1,LUA = 80,Tooltip = LYL["Catch incoming CC when a teammate is below set HP%"]},
				},
				[PrGrip] = {
					[1] = {name = LYL["Catch Freezing Trap"],Type = 2,LUA = true,Tooltip = LYL["Catch Freezing Trap fired @Team Healer"]},
					[2] = {name = LYL["Anti Smoke Bomb"],Type = 2,LUA = true,Tooltip = LYL["Grip a teammate from enemy Rogue's Smoke Bomb"]},
					[3] = {name = LYL["Anti Clone"],Type = 2,LUA = true,Tooltip = LYL["Grip a teammate away from enemy casting Cyclone"]},
				},
				[PrChas] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 75,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[10] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[PrMD] = {
					[1] = {name = LYL["Offensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Dispel Cyclone from teammate when an enemy is below set HP%"]},
					[2] = {name = LYL["Offensive when bursting"],Type = 2,LUA = true,Tooltip = LYL["Dispel Cyclone from teammate when he is bursting"]},
					[3] = {name = LYL["Defensive by HP"],Type = 1,LUA = 75,Tooltip = LYL["MD team healer when a teammate is below set HP%"]},
					[4] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["MD team healer when an enemy is bursting"]},
				},
				[PrMC] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 50,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = false,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 30,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when Bursting"],Type = 2,LUA = false,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[9] = {name = LYL["HP Check"],Type = 1,LUA = 60,Tooltip = LYL["Do not use the spell if a teammate below set HP%"]},
				},
				[PrTeeth] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Stun timer"],Type = 1,LUA = 4,Tooltip = LYL["Stun time is greater than the set number in seconds"]},
					[4] = {name = LYL["Anti Smoke Bomb"],Type = 2,LUA = true,Tooltip = LYL["PS a teammate from enemy Rogue's Smoke Bomb"]},
				},
				[PrPenance] = {
					[1] = {name = LYL["Offensive by HP"],Type = 1,LUA = 80,Tooltip = LYL["use offensively when no teammate is below set HP%"]},
				},
				[PrPWB] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[PrPWRad] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[3] = {name = LYL["Teammates HP"],Type = 1,LUA = 80,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[PrPsyHorror] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 75,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 30,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[10] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[PrFear] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["Tripple"],Type = 2,LUA = true,Tooltip = LYL["Cast the spell if it can cover at least 3 enemies"]},
					[3] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[4] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[5] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[6] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[7] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[8] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[9] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[10] = {name = LYL["Chain CC"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[11] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[PrRapture] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[PrRayHope] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[PrShadowCrash] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 1,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[PrFlash] = {
					[1] = {name = LYL["[Disc+Holy] by HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammate is under attack and below set HP% or DPS otherwise"]},
					[2] = {name = LYL["[Shadow] Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[PrSilence] = {
					[1] = {name = LYL["Enemy healer by enemy HP"],Type = 1,LUA = 35,Tooltip = LYL["Blanket enemy healer when an enemy player is below set HP%"]},
				},
				[PrVampEmbrace] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Sync with Shadow Covenant"],Type = 2,LUA = true,Tooltip = LYL["Use the spell during Shadow Covenant buff"]},
				},
				[PrVoidshift] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 15,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["@healer"],Type = 2,LUA = false,Tooltip = LYL["Allow Swap with a healer"]},
				},
				[PrInfusion] = {
					[1] = {name = LYL["Offensive when bursting"],Type = 2,LUA = true,Tooltip = LYL["Teammate is bursting"]},
					[2] = {name = LYL["Allow @focus only"],Type = 2,LUA = false,Tooltip = LYL["Allow @focus only when the unit is bursting"]},
					[3] = {name = LYL["Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[4] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[PrDivAscen] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
				},
				[PrMindSoothe] = {
					[1] = {name = LYL["by Mana"],Type = 1,LUA = 80,Tooltip = LYL["MP above set value"]},
				},
				[PrDarkAngel] = {
					[1] = {name = LYL["Offensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Enemy target is below set HP%"]},
					[2] = {name = LYL["Offensive when bursting"],Type = 2,LUA = true,Tooltip = LYL["Teammate is bursting"]},
				},
				[PrSanctify] = {
					[1] = {name = LYL["Teammates HP"],Type = 1,LUA = 80,Tooltip = LYL["Teammates are below set HP%"]},
					[2] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[3] = {name = LYL["Single Teammate HP"],Type = 1,LUA = 35,Tooltip = LYL["A Teammate below set HP%"]},
				},
				[PrDivWord] = {
					[1] = {name = LYL["Offensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Enemy target is below set HP%"]},
					[2] = {name = LYL["Offensive when bursting"],Type = 2,LUA = true,Tooltip = LYL["Teammate is bursting"]},
				},
				[PrSpiritRedem] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
				},
				[PrSalvation] = {
					[1] = {name = LYL["Teammates HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammates are below set HP%"]},
					[2] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
				},
				[PrUltPenance] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["A teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Teammates HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammates are below set HP%"]},
					[3] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
				}
			},
			[6] = {
				[DKAMS] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["AntiCC by HP"],Type = 1,LUA = 40,Tooltip = LYL["Avoid incoming CC when an enemy is below set HP%"]},
					[5] = {name = LYL["AntiCC when bursting"],Type = 2,LUA = true,Tooltip = LYL["Avoid incoming CC when bursting"]},
					[6] = {name = LYL["[PvP] Defensive on teammate"],Type = 2,LUA = false,Tooltip = LYL["Use AMS on teammates according to above settings."]},
					[7] = {name = LYL["[PvP] AntiCC on team healer only"],Type = 2,LUA = false,Tooltip = LYL["Use AMS on teammates according to above settings."]},
				},
				[DKAMZ] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
				},
				[DKAsphyx] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 70,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 30,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[10] = {name = LYL["Alternative kick"],Type = 2,LUA = false,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[DKDeadArmy] = {
					[1] = {name = LYL["Use in Burst"],Type = 2,LUA = true,Tooltip = LYL["Use the spell in burst mode"]},
				},
				[DKBlindSleet] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[DKSimul] = {
					[1] = {name = LYL["Steal CC spells"],Type = 2,LUA = true,Tooltip = LYL["Steal CC abilities"]},
					[2] = {name = LYL["Steal at low HP"],Type = 2,LUA = true,Tooltip = LYL["Cast at enemy below 20HP%"]},
					[3] = {name = LYL["Use stolen spell"],Type = 2,LUA = true,Tooltip = LYL["Auto use stolen spell"]},
				},
				[DKDeathAdvance] = {
					[1] = {name = LYL["Antisnare by target HP"],Type = 1,LUA = 40,Tooltip = LYL["When slowed and target is below set HP%"]},
				},
				[DKDecay] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 2,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[DKGrip] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["Target blinks"],Type = 2,LUA = true,Tooltip = LYL["After target blinks"]},
					[3] = {name = LYL["Gap closer when bursting"],Type = 2,LUA = true,Tooltip = LYL["When bursting and target is not in range"]},
					[4] = {name = LYL["Gap closer by HP"],Type = 1,LUA = 25,Tooltip = LYL["When target is belowe set HP% and is not in range"]},
				},
				[DKEatPet] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Player is under attack and below set HP%"]},
				},
				[DKGnaw] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[DKIceBound] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["AntiStun timer"],Type = 1,LUA = 4,Tooltip = LYL["Stun time is greater than the set number in seconds"]},
					[5] = {name = LYL["AntiStun when bursting"],Type = 2,LUA = false,Tooltip = LYL["Antistun when bursting"]},
					[6] = {name = LYL["AntiStun by enemy HP"],Type = 1,LUA = 50,Tooltip = LYL["Antistun when an enemy is below set HP%"]},
				},
				[DKWrWalk] = {
					[1] = {name = LYL["AntiRoot timer"],Type = 1,LUA = 4,Tooltip = LYL["Roots time is greater than the set number in seconds"]},
					[2] = {name = LYL["AntiRoot by HP"],Type = 1,LUA = 50,Tooltip = LYL["When snared and target is below set HP%"]},
				},
				[DKRuneTap] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 80,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[DKTombstone] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 70,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[DKVamBlood] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[DKSacPact] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Player is under attack and below set HP%"]},
				},
				[DKDeathStrike] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 85,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
				},
				[DKPet] = {
					[1] = {name = LYL["Auto use"],Type = 2,LUA = true,Tooltip = LYL["Use the spell always in comnbat or save it for manual / Sacrificial pact"]},
				},
				[DKLichborn] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
				},
				[DKEpidemic] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				}
			},
			[7] = {
				[ShAscend] = {
					[1] = {name = LYL["[Restor] Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["[Restor] Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["[Restor] Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[4] = {name = LYL["[Restor] Teammates HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[ShAG] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["A team member is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["A team member is under attack by a bursting enemy"]},
					[3] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[4] = {name = LYL["Teammates HP"],Type = 1,LUA = 70,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[ShAstralShift] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[ShCap] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[10] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability in PvE"]},
				},
				[ShCSTotem] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[ShGround] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["AntiCC by HP"],Type = 1,LUA = 35,Tooltip = LYL["Avoid incoming CC when an enemy is below set HP%"]},
					[4] = {name = LYL["AntiCC when bursting"],Type = 2,LUA = true,Tooltip = LYL["Avoid incoming CC when bursting"]},
					[5] = {name = LYL["Allow cast @DPS teammates"],Type = 2,LUA = true,Tooltip = LYL["Let the spell be cast @teammate DPS players or at player only"]},
					[6] = {name = LYL["Anti Freezing Trap"],Type = 2,LUA = true,Tooltip = LYL["Grounding when an enemy hunter can trap CCed team healer"]},
				},
				[ShShieldTotem] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[ShTEarthBind] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[ShSurgePow] = {
					[1] = {name = LYL["Use frost shock to root"],Type = 2,LUA = true,Tooltip = LYL["Use frost shock to root enemies, else use on chain lightning"]},
					[2] = {name = LYL["Only use Surge Power on Root"],Type = 2,LUA = true,Tooltip = LYL["Will only spend surge of power procs to root an enemy"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[4] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
				},
				[ShEarthShock] = {
					[1] = {name = LYL["in DPS rotation"],Type = 2,LUA = true,Tooltip = LYL["Always use the spell as part of DPS rotation or hold for 20 stacks of Lava Shock (if disabled)"]},
				},
				[ShQuake] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 2,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[ShHealTide] = {
					[1] = {name = LYL["by lowest HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[3] = {name = LYL["Teammates HP"],Type = 1,LUA = 70,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[ShHealSurge] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 60,Tooltip = LYL["A teammate is below set HP%"]},
				},
				[ShHex] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[ShLightLasso] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[3] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[4] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 50,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[6] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[7] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[8] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[9] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[10] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[11] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[12] = {name = LYL["by HP"],Type = 1,LUA = 30,Tooltip = LYL["Enemy is below set HP%"]},
				},
				[ShLMagma] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 2,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[ShPulver] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = false,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
				},
				[ShSkyTotem] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Offensive when bursting"],Type = 2,LUA = true,Tooltip = LYL["Teammate is bursting"]},
				},
				[ShLink] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[ShSWalk] = {
					[1] = {name = LYL["AntiRoot timer"],Type = 1,LUA = 4,Tooltip = LYL["Roots time is greater than the set number in seconds"]},
					[2] = {name = LYL["AntiRoot by HP"],Type = 1,LUA = 40,Tooltip = LYL["When snared and target is below set HP%"]},
				},
				[ShSunder] = {
					[1] = {name = LYL["Offensive by HP"],Type = 1,LUA = 100,Tooltip = LYL["Enemy is below set HP%"]},
					[2] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[3] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[4] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[5] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
					[6] = {name = LYL["Before Capacitor"],Type = 2,LUA = true,Tooltip = LYL["Use the spell to ensure Capacitor stun"]},
				},
				[ShThunder] = {
					[1] = {name = LYL["[PvP Talent] Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["[PvP Talent] Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[ShTremor] = {
					[1] = {name = LYL["Fear timer"],Type = 1,LUA = 2,Tooltip = LYL["Dispel CC with debuff time greater than the set number in seconds"]},
					[2] = {name = LYL["Allow cast @DPS teammates"],Type = 2,LUA = true,Tooltip = LYL["Let the spell be cast @teammate DPS players"]},
					[3] = {name = LYL["Dispel Fear by enemy HP"],Type = 1,LUA = 40,Tooltip = LYL["Dispel DPS teammate when his target is below set HP%"]},
					[4] = {name = LYL["Dispel Fear by party HP"],Type = 1,LUA = 80,Tooltip = LYL["Dispel team healer when a teammate is below set HP%"]},
					[5] = {name = LYL["Dispel Fear when bursting"],Type = 2,LUA = true,Tooltip = LYL["Dispel DPS teammate when he is bursting"]},
					[6] = {name = LYL["Pre-Tremor Fear"],Type = 2,LUA = true,Tooltip = LYL["Precast Tremor on incoming Fear"]}
				},
				[ShFreedom] = {
					[1] = {name = LYL["AntiRoot team healer by HP"],Type = 1,LUA = 40,Tooltip = LYL["When team healer is rooted and below set HP%"]},
					[2] = {name = LYL["Allow cast @DPS teammates"],Type = 2,LUA = true,Tooltip = LYL["Let the spell be cast @teammate DPS players or @player only if disabled"]},
					[3] = {name = LYL["Antisnare by enemy HP"],Type = 1,LUA = 40,Tooltip = LYL["When DPS teammate is rooted and his target is below set HP%"]},
				},
				[ShWolf] = {
					[1] = {name = LYL["Auto Ghost Wolf"],Type = 2,LUA = true,Tooltip = LYL["When no enemy in melee range"]},
				},
				[ShManaTotem] = {
					[1] = {name = LYL["by Mana"],Type = 1,LUA = 30,Tooltip = LYL["Use the spell when player's mana is below set MP%"]},
				},
				[ShHealStream] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 90,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[ShEarthShield] = {
					[1] = {name = LYL["on self only"],Type = 2,LUA = false,Tooltip = LYL["Use the spell only on self"]},
				},
				[ShEarthEle] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["[Vital Accretion Conduit] Player is under attack and below set HP%"]},
				},
				[ShWalker] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[ShChainHeal] = {
					[1] = {name = LYL["Teammates HP"],Type = 1,LUA = 80,Tooltip = LYL["Teammates are below set HP%"]},
					[2] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[3] = {name = LYL["Tidebringer only"],Type = 2,LUA = true,Tooltip = LYL["Only use under Tidebringer buff"]},
				},
				[ShBlink] = {
					[1] = {name = LYL["Gap closer when bursting"],Type = 2,LUA = true,Tooltip = LYL["When bursting and target is not in range"]},
					[2] = {name = LYL["Gap closer by HP"],Type = 1,LUA = 25,Tooltip = LYL["When target is belowe set HP% and is not in range"]},
				},
				[ShNS] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[ShBurrow] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[ShHealWave] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 80,Tooltip = LYL["A teammate is below set HP%"]},
				}
			},
			[8] = {
				[MgBarrage] = {
					[1] = {name = LYL["by Mana"],Type = 1,LUA = 100,Tooltip = LYL["Use Barrage when player's mana is below set MP%"]},
				},
				[MgBlink] = {
					[1] = {name = LYL["Stun timer"],Type = 1,LUA = 4,Tooltip = LYL["Stun time is greater than the set number in seconds"]},
				},
				[MgDisplace] = {
					[1] = {name = LYL["Auto use"],Type = 2,LUA = true,Tooltip = LYL["Use after Blink"]},
				},
				[MgDB] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 70,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["in DPS rotation"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as part of DPS rotation or during Burst phase only"]},
					[11] = {name = LYL["CC While Bursting"],Type = 2,LUA = true,Tooltip = LYL["CC according to above settings even while bursting"]},
					[12] = {name = LYL["Blink DB"], Type = 2, LUA = true, Tooltip = LYL["Enable Auto Blink DB"]}
				},
				[MgGreatInv] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[MgBlock] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 15,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["Cancel by HP"],Type = 1,LUA = 85,Tooltip = LYL["Cancel when player is above set HP%"]},
				},
				[MgFlameStrike] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 2,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[MgPoly] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 90,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 1,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[11] = {name = LYL["CC While Bursting"],Type = 2,LUA = false,Tooltip = LYL["CC according to above settings even while bursting"]},
				},
				[MgRingFrost] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[MgTempShield] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[MgMirImage] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["Use in Burst"],Type = 2,LUA = true,Tooltip = LYL["Use the spell in burst mode"]},
				},
				[MgAlterTime] = {
					[1] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[2] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[MgMassBar] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				}
			},
			[9] = {
				[WlAxes] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[10] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[WlBaneHavoc] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[WlBilesBomber] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 2,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[WlBurning] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 80,Tooltip = LYL["Player is above set HP%"]},
				},
				[WlFellLord] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[WlCata] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[WlCurFrag] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 30,Tooltip = LYL["Use the Curse when enemy is below set HP%"]},
				},
				[WlSacShield] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 60,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[WlTP2] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[WlDrainLife] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 15,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Inevitable Demise x20"],Type = 2,LUA = true,Tooltip = LYL["Only allow Drain Life when you have 20 stacks of Inevitable Demise"]},
				},
				[WlFear] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell to kick cast CC spells"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 85,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 1,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[11] = {name = LYL["CC While Bursting"],Type = 2,LUA = true,Tooltip = LYL["CC according to above settings even while bursting"]},
				},
				[WlChaos] = {
					[1] = {name = LYL["in DPS rotation"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as part of DPS rotation before Chaos Bolt / Conflag / Coil"]},
				},
				[WlCoil] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Player is under attack and below set HP%"]},
					[3] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[4] = {name = LYL["CC by HP"],Type = 1,LUA = 70,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[5] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[6] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[7] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[8] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[9] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[10] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[11] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[WlNetherWard] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Offensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Avoid incoming CC when an enemy is below set HP%"]},
				},
				[WlRainFire] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[WlUnstable] = {
					[1] = {name = LYL["Cast UA even if you can be kicked"],Type = 2,LUA = true,Tooltip = LYL["Cast UA even if you can be kicked"]},
				},
				[WlSeduction] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[WlSeed] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[WlDispelPet] = {
					[1] = {name = LYL["Dispel CC timer"],Type = 1,LUA = 4,Tooltip = LYL["Dispel CC with debuff time greater than the set number in seconds"]},
					[2] = {name = LYL["Dispel CC @team healer by HP"],Type = 1,LUA = 80,Tooltip = LYL["Dispel team healer when a teammate is below set HP%"]},
					[3] = {name = LYL["Allow cast @team healer only"],Type = 2,LUA = true,Tooltip = LYL["Let the spell be cast @team healer only"]},
					[4] = {name = LYL["Dispel CC by enemy HP"],Type = 1,LUA = 40,Tooltip = LYL["Dispel a DPS teammate when his target is below set HP%"]},
					[5] = {name = LYL["Dispel CC when bursting"],Type = 2,LUA = true,Tooltip = LYL["Dispel a DPS teammate when he is bursting"]},
				},
				[WlSF] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 70,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 30,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[9] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell to kick cast CC spells"]},
				},
				[WlSumPet] = {
					[1] = {name = LYL["Pet type"],Type = 1,LUA = 1,Tooltip = LYL["1 - Kick,2 - Tank,3 - Dispel,4 - CC,5 - Guard"]},
				},
				[WlMA] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["Offensive bursting"],Type = 2,LUA = true,Tooltip = LYL["Player is bursting and can be kicked"]},
				},
				[WlVileTaint] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
					[2] = {name = LYL["By target HP"],Type = 1,LUA = 100,Tooltip = LYL["Cast the spell by target HP when all dots applied"]},
				},
				[WlHowl] = {
					[1] = {name = LYL["Tripple"],Type = 2,LUA = true,Tooltip = LYL["Cast the spell if it can cover at least 3 enemies"]},
					[2] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[WlChaosBolt] = {
					[1] = {name = LYL["Save shards for x2 bolts"],Type = 2,LUA = false,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				}
			},
			[10] = {
				[MnGuardian] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[MnDifMagic] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["Defensive on Debuffs"],Type = 2,LUA = true,Tooltip = LYL["Use on Karma and Mindgames"]},
				},
				[MnDisable] = {
					[1] = {name = LYL["Root"],Type = 2,LUA = true,Tooltip = LYL["Root enemy target when he is or you are bursting"]},
				},
				[MnDisarm] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive when healer CCed"],Type = 2,LUA = true,Tooltip = LYL["Team healer is CCed 6+ sec"]},
					[4] = {name = LYL["Defensive under damage debuff"],Type = 2,LUA = true,Tooltip = LYL["A teammate is under a major damage debuff, e.g. Colossus Smash"]},
					[5] = {name = LYL["@focus only"],Type = 2,LUA = false,Tooltip = LYL["Use the spell @focus unit only"]},
				},
				[MnFortBrew] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				["Invoke Yulon"] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[3] = {name = LYL["Teammates HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammates are below set HP%"]},
					[4] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[MnRestoral] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[3] = {name = LYL["Teammates HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[MnLegSwip] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = false,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 40,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[11] = {name = LYL["Tripple"],Type = 2,LUA = true,Tooltip = LYL["Cast the spell if it can cover at least 3 enemies"]},
				},
				[MnCocoon] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[MnSap] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 1,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[MnPureBrew] = {
					[1] = {name = LYL["Stagger to HP, %"],Type = 1,LUA = 10,Tooltip = LYL["Stagger is above set HP% * 1.5"]},
				},
				[MnRevival] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[3] = {name = LYL["Teammates HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[MnRingPeace] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["Anti Smoke Bomb"],Type = 2,LUA = true,Tooltip = LYL["Grip a teammate from enemy Rogue's Smoke Bomb"]},
					[4] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[5] = {name = LYL["Knock from Defensives"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as to knock enemies from Power Word: Barrier,Earthen Wall Totem etc."]},
				},
				[MnThunderTea] = {
					[1] = {name = LYL["[FISTWEAVE] Use By HP"],Type = 1,LUA = 75,Tooltip = LYL["When to use TFT when fistweaving by HP."]},
				},
				[MnStatue] = {
					[1] = {name = LYL["Auto use"],Type = 2,LUA = true,Tooltip = LYL["Summon Jade Serpent (MW) or Black Ox (BM) statue"]},
				},
				[MnFreedom] = {
					[1] = {name = LYL["AntiRoot timer"],Type = 1,LUA = 4,Tooltip = LYL["Roots time is greater than the set number in seconds"]},
					[2] = {name = LYL["AntiRoot team healer by HP"],Type = 1,LUA = 35,Tooltip = LYL["When team healer is rooted and below set HP%"]},
					[3] = {name = LYL["Allow cast @DPS teammates"],Type = 2,LUA = true,Tooltip = LYL["Let the spell be cast @teammate DPS players or @player only if disabled"]},
					[4] = {name = LYL["Antisnare by enemy HP"],Type = 1,LUA = 40,Tooltip = LYL["When DPS teammate is rooted and his target is below set HP%"]},
				},
				[MnKarma] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 15,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[MnTP] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["Anti Freezing Trap"],Type = 2,LUA = true,Tooltip = LYL["Escape from Freezing Trap"]},
				},
				[MnUplift] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 50,Tooltip = LYL["[DPS] Player is below set HP%"]},
				},
				[MnZenTea] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 50,Tooltip = LYL["Teammate is below set HP% and enemy can kick cast"]},
				},
				[MnCelBrew] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 75,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[MnExplKeg] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 5,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[MnTigerBrew] = {
					[1] = {name = LYL["During Fists of Fury"],Type = 2,LUA = true,Tooltip = LYL["Enable on every Fists of Fury -> Rising Sub Kick use"]},
					[2] = {name = LYL["During burst"],Type = 2,LUA = true,Tooltip = LYL["Enable when bursting"]},
				},
				[MnSpin] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 5,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				}
			},
			[11] = {
				[DrBear] = {
					[1] = {name = LYL["[Feral/Balance] Defensive by HP"],Type = 1,LUA = 15,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["[Feral/Balance] Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["[Feral/Balance] Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[DrBSkin] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["Stun timer"],Type = 1,LUA = 4,Tooltip = LYL["Stun time is greater than the set number in seconds"]},
					[5] = {name = LYL["Stun HP"],Type = 1,LUA = 70,Tooltip = LYL["When player is stunned and below set HP%"]},
				},
				[DrHeartWild] = {
					[1] = {name = LYL["[Bear] Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["[Bear] Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["[Bear] Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["[Feral/Balance] Offensive"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a part of DPS rotation"]},
					[5] = {name = LYL["[Restor] Defensive by HP"],Type = 1,LUA = 50,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[6] = {name = LYL["[Restor] Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[DrCenWard] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 75,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[DrClone] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 65,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 1,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[DrMush] = {
					[1] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 2,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[2] = {name = LYL["Teammates HP"],Type = 1,LUA = 75,Tooltip = LYL["Teammates are below set HP%"]},
					[3] = {name = LYL["[PvP] Remove snare by enemy HP"],Type = 1,LUA = 50,Tooltip = LYL["When a teammate is snared and his enemy target is below set HP%"]},
				},
				[DrFSwarm] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 70,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[DrFlour] = {
					[1] = {name = LYL["Before CC on player by HP"],Type = 1,LUA = 65,Tooltip = LYL["Precast on lowest teammate (below set HP%) before incoming on player CC"]},
					[2] = {name = LYL["After CC by HP"],Type = 1,LUA = 50,Tooltip = LYL["Right after player is out of CC and teammate's below set HP%"]},
				},
				[DrDesor] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 50,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 25,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[DrIncTree] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[3] = {name = LYL["Teammates HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[DrInner] = {
					[1] = {name = LYL["Auto use"],Type = 2,LUA = true,Tooltip = LYL["Use Innervate at Team healer when enemy is bursting [PvP] or Team healer is bursting [PvE]"]},
				},
				[DrIBark] = {
					[1] = {name = LYL["Before CC on player by HP"],Type = 1,LUA = 70,Tooltip = LYL["Precast on lowest teammate (below set HP%) before incoming on player CC"]},
					[2] = {name = LYL["Defensive by HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[3] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[DrLunarBeam] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 70,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[DrMaim] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability with PvP talent taken"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 50,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 25,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
				},
				[DrBash] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 50,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 25,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[DrOvergrowth] = {
					[1] = {name = LYL["By HP"],Type = 1,LUA = 60,Tooltip = LYL["When a teammate is below set HP%"]},
				},
				[DrOverrun] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[DrStealth] = {
					[1] = {name = LYL["Auto use"],Type = 2,LUA = true,Tooltip = LYL["Use the spell"]},
				},
				[DrRegr] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Use with NS by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP% and NS is active"]},
				},
				[DrRejuv] = {
					[1] = {name = LYL["[Balance / Feral] by HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[DrRenewal] = {
					[1] = {name = LYL["By HP"],Type = 1,LUA = 30,Tooltip = LYL["When player is below set HP%"]},
				},
				[DrSolar] = {
					[1] = {name = LYL["Defensive by HP [+Mass Entanglement]"],Type = 1,LUA = 25,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted [+Mass Entanglement]"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
					[3] = {name = LYL["CC by HP [+Mass Entanglement]"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when Bursting [+Mass Entanglement]"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
				},
				[DrStamped] = {
					[1] = {name = LYL["AntiRoot timer"],Type = 1,LUA = 3,Tooltip = LYL["Roots time is greater than the set number in seconds"]},
					[2] = {name = LYL["AntiRoot team healer by HP"],Type = 1,LUA = 40,Tooltip = LYL["When team healer is rooted and below set HP%"]},
					[3] = {name = LYL["Allow cast @DPS teammates"],Type = 2,LUA = true,Tooltip = LYL["Let the spell be cast @teammate DPS players"]},
					[4] = {name = LYL["Antisnare by enemy HP"],Type = 1,LUA = 30,Tooltip = LYL["When DPS teammate is rooted and his target is below set HP%"]},
				},
				[DrSFall] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[DrSMend] = {
					[1] = {name = LYL["by HP"],Type = 1,LUA = 70,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[DrSurvInst] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[DrThorns] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[DrTranq] = {
					[1] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[2] = {name = LYL["Teammates HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[DrTyphoon] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[DrWildCharge] = {
					[1] = {name = LYL["Gap closer to kick any"],Type = 2,LUA = true,Tooltip = LYL["Leap to an enemy to kick if not in range"]},
					[2] = {name = LYL["Gap closer to kick healers"],Type = 2,LUA = true,Tooltip = LYL["Leap to an enemy healer to kick if not in range"]},
					[3] = {name = LYL["Anti Freezing Trap"],Type = 2,LUA = true,Tooltip = LYL["Catch / Escape from Freezing Trap with Wild Charge"]},
				},
				[DrVortex] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[DrNS] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[DrFBite] = {
					[1] = {name = LYL["Ferocious Bite priority by HP"],Type = 1,LUA = 30,Tooltip = LYL["Prioritize FB over Rip when an enemy is below set HP%"]},
					[2] = {name = LYL["During burst"],Type = 2,LUA = true,Tooltip = LYL["Prioritize FB over Rip when bursting"]},
				},
				[DrWGrowth] = {
					[1] = {name = LYL["Teammates in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of teammates in its area"]},
					[2] = {name = LYL["Teammates HP"],Type = 1,LUA = 85,Tooltip = LYL["Teammates are below set HP%"]},
				},
				[DrTF] = {
					[1] = {name = LYL["Use aggressively during burst"],Type = 2,LUA = true,
						   Tooltip = LYL["Uses TF during burst even if it can't restore energy as long as the enemy is doted and you have Adaptive Swarm + Save for TF setting or Adaptive Swarm isn't learned"]}
				}
			},
			[12] = {
				[DHBlur] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[DHStun] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 3,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
					[3] = {name = LYL["During burst"],Type = 2,LUA = true,Tooltip = LYL["Enable when bursting"]},
					[4] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[6] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[7] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[8] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[9] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[10] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[11] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[12] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[DHDarkness] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[DHEyeBeam] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 1,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
					[2] = {name = LYL["Force stop movement"],Type = 2,LUA = false,Tooltip = LYL["Force stop character movement,otherwise only cast when not moving"]},
				},
				[DHFelBar] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 2,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[DHFelErupt] = {
					[1] = {name = LYL["During burst"],Type = 2,LUA = true,Tooltip = LYL["Enable when bursting"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
					[11] = {name = LYL["Alternative kick"],Type = 2,LUA = false,Tooltip = LYL["Use the spell as a kick ability"]}
				},
				[DHFelRush] = {
					[1] = {name = LYL["Gap closer to kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["Part of DPS rotation"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a part of DPS rotation"]},
					[3] = {name = LYL["Evade incoming casts"],Type = 2,LUA = true,Tooltip = LYL["Charge behind a caster's back at the end of the cast to evade the spell"]},
				},
				[DHIlGrasp] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[DHImprison] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
					[2] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[3] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[4] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[5] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[6] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[7] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[8] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[9] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[10] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[DHBurst] = {
					[1] = {name = LYL["[Vengeance] by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
				},
				[DHNetherwalk] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 20,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = false,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[DHRainAbove] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
					[4] = {name = LYL["AntiStun"],Type = 2,LUA = true,Tooltip = LYL["Avoid incoming CC"]},
				},
				[DHRevMagic] = {
					[1] = {name = LYL["Dispel CC timer"],Type = 1,LUA = 4,Tooltip = LYL["Dispel CC with debuff time greater than the set number in seconds"]},
					[2] = {name = LYL["Dispel CC by enemy HP"],Type = 1,LUA = 50,Tooltip = LYL["Dispel CC from DPS teammates when an enemy is below set HP%"]},
					[3] = {name = LYL["Dispel CC by team HP"],Type = 1,LUA = 80,Tooltip = LYL["Dispel CC from team healer when a teammate is below set HP%"]},
					[4] = {name = LYL["Dispel DoTs by HP"],Type = 1,LUA = 35,Tooltip = LYL["Dispel magic DoTs when a teammate is below set HP%"]},
					[5] = {name = LYL["Allow cast @DPS teammates"],Type = 2,LUA = false,Tooltip = LYL["Let the spell be cast @teammate DPS players"]},
				},
				[DHSigilChains] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[DHSigilMisery] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 80,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 0,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[DHSigilSilence] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Teammate is under attack by a bursting enemy"]},
				},
				[DHVengRetreat] = {
					[1] = {name = LYL["Part of DPS rotation"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a part of DPS rotation"]},
					[2] = {name = LYL["AntiCC by HP"],Type = 1,LUA = 40,Tooltip = LYL["Avoid incoming CC when an enemy is below set HP%"]},
					[3] = {name = LYL["AntiCC when bursting"],Type = 2,LUA = true,Tooltip = LYL["Avoid incoming CC when bursting"]},
				},
				[DHFieryBrand] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
				},
				[DHFelDevas] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 80,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 1,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				},
				[DHFelblade] = {
					[1] = {name = LYL["Gap closer when bursting"],Type = 2,LUA = true,Tooltip = LYL["When player is bursting and the target is not in melee"]},
					[2] = {name = LYL["Gap closer by HP"],Type = 1,LUA = 100,Tooltip = LYL["When target is below set HP% and is not in melee"]},
					[3] = {name = LYL["Only in melee"],Type = 2,LUA = false,Tooltip = LYL["Always cast when in melee"]},
					[4] = {name = LYL["Reconnect after VR"],Type = 2,LUA = true,Tooltip = LYL["Charge back to the target after casting Vengeful Retreat"]},
				},
				[DHElysian] = {
					[1] = {name = LYL["Enemies in spell area"],Type = 1,LUA = 1,Tooltip = LYL["Cast the spell if it can cover at least the set amount of enemies in its area"]},
				}
			},
			[13] = {
				[EvSpiritbloom] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 70,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[EvDreamBreath] ={
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 60,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[2] = {name= LYL["Consider Rank 3"], Type = 2,LUA = true, Tooltip = LYL["Charge to rank 3 if teammates are below Rank 3 HP"]},
					[3] = {name = LYL["Rank 3 HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
					[4] = {name= LYL["Only if interrupt immune"], Type = 2,LUA = true, Tooltip = LYL["Consider rank 3 only if interrupt immune"]},
				},
				[EvTimeStop] = {
					[1] = {name = LYL["AntiCC by HP"],Type = 1,LUA = 40,Tooltip = LYL["On Healer: Avoid incoming CC when an party member is below set HP%"]},
					[2] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Player is under attack and below set HP%"]},
				},
				[EvTipScales] = {
					[1] = {name = LYL["Offensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["An enemy is below set HP%"]},
					[2] = {name = LYL["Offensive bursting"],Type = 2,LUA = true,Tooltip = LYL["Player is bursting"]},
				},
				[EvWingBuf] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[EvTailSwipe] = {
					[1] = {name = LYL["Alternative kick"],Type = 2,LUA = true,Tooltip = LYL["Use the spell as a kick ability"]},
				},
				[EvObsidScales] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
					[3] = {name = LYL["Defensive no heals"],Type = 2,LUA = false,Tooltip = LYL["Only if team healer can't interact with player"]},
				},
				[EvSleepWalk] = {
					[1] = {name = LYL["CC Enemy Healer"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy healer according to the settings"]},
					[2] = {name = LYL["CC by HP"],Type = 1,LUA = 65,Tooltip = LYL["CC enemy healer when an enemy is below set HP%"]},
					[3] = {name = LYL["CC when team bursting"],Type = 2,LUA = true,Tooltip = LYL["CC enemy healer when a teammate is bursting"]},
					[4] = {name = LYL["CC Defensive"],Type = 2,LUA = true,Tooltip = LYL["Enable AutoCC enemy DPS when team healer is CCed"]},
					[5] = {name = LYL["CC by HP"],Type = 1,LUA = 35,Tooltip = LYL["CC enemy DPS when a teammate is below set HP%"]},
					[6] = {name = LYL["CC when enemy bursting"],Type = 2,LUA = true,Tooltip = LYL["CC bursting enemy DPS"]},
					[7] = {name = LYL["DR check"],Type = 1,LUA = 1,Tooltip = LYL["DR check for CC (0 - full time CC,1 - 1/2 CC,2 - 1/4 CC)"]},
					[8] = {name = LYL["Chain CC"],Type = 2,LUA = false,Tooltip = LYL["CC enemy healer if he is already CCed to continue the chain"]},
					[9] = {name = LYL["CC Focus"],Type = 2,LUA = false,Tooltip = LYL["CC focused enemy every time the spell is available according to DR settings"]},
				},
				[EvLivFlame] = {
					[1] = {name = LYL["Defensive by HP"], Type= 1, LUA = 20, Tooltip = LYL["Teammate is under attack and below set HP%"]}
				},
				[EvEmerBlos] = {
					[1] = {name = LYL["Defensive by HP"], Type= 1, LUA = 75, Tooltip = LYL["Teammate is under attack and below set HP%"]}
				},
				[EvDreamFlight] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 40,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[EvDreamProject] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[EvEmerCommun] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				},
				[EvRenewBlaze] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 35,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
				},
				[EvTimeDilation] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 30,Tooltip = LYL["Player is under attack and below set HP%"]},
					[2] = {name = LYL["Defensive when bursted"],Type = 2,LUA = true,Tooltip = LYL["Player is under attack by a bursting enemy"]},
				},
				[EvRewind] = {
					[1] = {name = LYL["Defensive by HP"],Type = 1,LUA = 25,Tooltip = LYL["Teammate is under attack and below set HP%"]},
				}
			}
		}
		if not FileExists(GetAppDirectory().."\\".."LegacyRTBackup"..".txt") and FileExists(GetAppDirectory().."\\".."LegacyRT"..".txt") then
			print("[".."|cff20c000".."HandsFree Reborn".."|r".."]".."Creating backup")
			LYLoadSetting(LYSettingsFile)
			LYSaveClose("LegacyRTBackup")
			LYSettingsFile = nil
		end
		local loadingCustom = LYCheckNextLoad()
		LYLoadSetting(LYSettingsFile)
		if (not LYClassConfigs or LYForceConfigGreeting or loadingCustom) and not LYDidConfigLoadGreeting then
			print("[".."|cff20c000".."HandsFree Reborn".."|r".."]".."Loaded config: " .. tostring(LYSettingsFile or "LegacyRT"))
			LYDidConfigLoadGreeting = true
			LYForceConfigGreeting = false
		end
		if not loadingCustom then
			if not LYDidClassConfigs and LYClassConfigs then
				if not FileExists(GetAppDirectory().."\\"..LYMyClassName..".txt") then
					print("[".."|cff20c000".."HandsFree Reborn".."|r".."]".."Creating class config for " .. LYMyClassName)
					LYSettingsFile = LYMyClassName
					LYSaveClose(LYSettingsFile)
				else
					print("[".."|cff20c000".."HandsFree Reborn".."|r".."]".."Loaded class config: " .. LYMyClassName)
					LYSettingsFile = LYMyClassName
					LYLoadSetting(LYSettingsFile)
				end
				LYDidClassConfigs = true
			end
		end
		MainList.SettingsEditBox:SetText(LYSettingsFile)
		for i,k in pairs(LYSettings[LYMyClass]) do
			tinsert(ClassTabTable,1,i)
		end
		local TablesTabTable = {
			LYL["Kick: heals"],
			LYL["Kick: blacklist"],
			LYL["Kick always: PvE"],
			LYL["Kick always: PvP"],
			LYL["Purge buffs"],
			LYL["Totem stomp"],
			LYL["Dispel debuffs: PvE"],
			LYL["Dispel debuffs always: PvP"],
			LYL["Blacklist Spells by Name"],
			LYL["Blacklist Units by Name"],
			LYL["Reflect: always"],
			LYL["Do not Attack: debuffs"],
			LYL["Do not Dispel: debuffs"],
			LYL["Do not Heal: buffs / debuffs"],
		}
		local TablesDecoding = {
			[LYL["Kick: heals"]] = LYListHealInt,
			[LYL["Kick: blacklist"]] = LYListNotKick,
			[LYL["Kick always: PvE"]] = LYListKickPvE,
			[LYL["Kick always: PvP"]] = LYListKickPvP,
			[LYL["Purge buffs"]] = LYPurgeList,
			[LYL["Totem stomp"]] = LYListTotems,
			[LYL["Dispel debuffs: PvE"]] = LYDispelPvE,
			[LYL["Dispel debuffs always: PvP"]] = LYListDispelPvP,
			[LYL["Blacklist Spells by Name"]] = LYBLSpells,
			[LYL["Blacklist Units by Name"]] = LYBLUnits,
			[LYL["Reflect: always"]] = LYReflectAlways,
			[LYL["Do not Attack: debuffs"]] = LYListBreakableCC,
			[LYL["Do not Dispel: debuffs"]] = LYListDoNotDispel,
			[LYL["Do not Heal: buffs / debuffs"]] = LYListDoNotHeal
		}
		local SLTemp,LYNumInput,LYText,LYTextInput,LYBox,LYPrevTable = nil,{},{},{},{},{}
		local function AddButton(parent,position,x,y,height,width)
			local button = CreateFrame("Button",nil,parent)
			button:SetHeight(height)
			button:SetWidth(width)
			button:SetPoint(position,parent,position,x,y)
			button.Text = button:CreateFontString(nil,"BACKGROUND","GameFontWhiteSmall")
			button.Text:SetJustifyH("LEFT")
			button.Text:SetPoint("TOP",button,"TOP",0,10)
			return button
		end
		local function HideThirdList()
			SpellTableMain:Hide()
			SpellTableInput:Hide()
			SpellTableContent:Hide()
			SpellTableList:Hide()
			SpellTableDeletButton:Hide()
			SpellTableAddButton:Hide()
			if not LYNumInput[1] then
				return
			end
			for i=1,22 do
				LYNumInput[i]:Hide()
				LYText[i]:Hide()
				LYBox[i]:Hide()
				LYTextInput[i]:Hide()
			end
		end
		local function LoadThirdList(option,text)
			local function AddUIOptions(i)
				local iX = 35
				local iY = 12-34*i
				local bX = 25
				local bY = 10-22.7*i
				if i > 11 then
					iX = 240
					iY = 12-34*(i-11)
					bX = 160
					bY = 10-22.7*(i-11)
				end
				LYNumInput[i] = CreateFrame("EditBox",nil,ThirdList,"InputBoxTemplate")
				if LYSkinELVUILoaded then
					LYSkinELVUISkinModule:HandleEditBox(LYNumInput[i])
				end
				LYNumInput[i]:SetWidth(30)
				LYNumInput[i]:SetHeight(20)
				LYNumInput[i]:SetPoint("TOPLEFT",iX,iY)
				LYNumInput[i]:SetAutoFocus(false)
				LYText[i] = ThirdList:CreateFontString(nil,"OVERLAY","GameFontNormal")
				LYText[i]:SetAllPoints()
				LYBox[i] = CreateFrame("CheckButton",nil,ThirdList,"UIRadioButtonTemplate")
				if LYSkinELVUILoaded then
					LYSkinELVUISkinModule:HandleCheckBox(LYBox[i])
				end
				LYBox[i]:SetPoint("TOPLEFT",bX,bY)
				LYBox[i]:SetScale(1.5)
				LYBox[i]:SetScript("OnLeave",function(self)
					GameTooltip:Hide()
				end)
				LYTextInput[i] = CreateFrame("EditBox",nil,ThirdList,"InputBoxTemplate")
				if LYSkinELVUILoaded then
					LYSkinELVUISkinModule:HandleEditBox(LYTextInput[i])
				end
				LYTextInput[i]:SetWidth(100)
				LYTextInput[i]:SetHeight(20)
				LYTextInput[i]:SetPoint("TOPLEFT",iX,iY)
				LYTextInput[i]:SetAutoFocus(false)
				LYTextInput[i]:Hide()
				LYText[i]:Hide()
				LYNumInput[i]:Hide()
				LYBox[i]:Hide()
			end
			local function EnableOption(class,i,j)
				local tX = -300
				local tY = 405-68.5*j
				if j > 11 then
					tX = 100
					tY = 405-68.5*(j-11)
				end
				LYText[j]:Show()
				LYText[j]:SetText(LYSettings[class][i][j].name)
				LYText[j]:SetPoint("TOPLEFT",LYText[j]:GetStringWidth()+tX,tY)
				if LYSettings[class][i][j].Type == 1 then
					LYNumInput[j]:SetText(LYSettings[class][i][j].LUA)
					LYNumInput[j]:SetScript("OnEnterPressed",function(self)
						local value = LYNumInput[j]:GetText()
						value = tonumber(value)
						if value and value >=0 and (value <=100 or class == 0) then
							LYNumInput[j]:ClearFocus()
							LYNumInput[j]:SetText(value)
							LYSettings[class][i][j].LUA = value
						else
							LY_Print("Wrong input","red")
						end
					end)
					LYNumInput[j]:SetScript("OnEnter",function(self)
						GameTooltip:SetOwner(self,"ANCHOR_TOPRIGHT")
						GameTooltip:ClearLines()
						GameTooltip:AddLine(LYSettings[class][i][j].Tooltip,NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,true)
						GameTooltip:Show()
					end)
					LYNumInput[j]:SetScript("OnEscapePressed",function(self) self:ClearFocus() self:SetText(LYSettings[class][i][j].LUA) end)
					LYNumInput[j]:SetScript("OnLeave",function(self)
						local value = LYNumInput[j]:GetText()
						value = tonumber(value)
						if value and value >=0 and (value <=100 or class == 0) then
							LYNumInput[j]:ClearFocus()
							LYNumInput[j]:SetText(value)
							LYSettings[class][i][j].LUA = value
						end
						GameTooltip:Hide()
					end)
					LYNumInput[j]:Show()
				elseif LYSettings[class][i][j].Type == 2 then
					LYBox[j]:SetChecked(LYSettings[class][i][j].LUA)
					LYBox[j]:SetScript("OnEnter",function(self)
						GameTooltip:SetOwner(self,"ANCHOR_TOPRIGHT")
						GameTooltip:ClearLines()
						GameTooltip:AddLine(LYSettings[class][i][j].Tooltip,NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,true)
						GameTooltip:Show()
					end)
					LYBox[j]:SetScript("PostClick",function() if LYSettings[class][i][j].LUA then LYSettings[class][i][j].LUA = nil else LYSettings[class][i][j].LUA = true end end)
					LYBox[j]:Show()
				elseif LYSettings[class][i][j].Type == 3 then
					LYTextInput[j]:SetText(LYSettings[class][i][j].LUA)
					LYTextInput[j]:SetScript("OnEnterPressed",function(self)
						local value = LYTextInput[j]:GetText()
						if value and type(value) == "string" then
							LYTextInput[j]:ClearFocus()
							LYTextInput[j]:SetText(value)
							LYSettings[class][i][j].LUA = value
						else
							LY_Print("Wrong input","red")
						end
					end)
					LYTextInput[j]:SetScript("OnEnter",function(self)
						GameTooltip:SetOwner(self,"ANCHOR_TOPRIGHT")
						GameTooltip:ClearLines()
						GameTooltip:AddLine(LYSettings[class][i][j].Tooltip,NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,true)
						GameTooltip:Show()
					end)
					LYTextInput[j]:SetScript("OnEscapePressed",function(self) self:ClearFocus() self:SetText(LYSettings[class][i][j].LUA) end)
					LYTextInput[j]:SetScript("OnLeave",function(self)
						local value = LYTextInput[j]:GetText()
						if value and type(value) == "string" then
							LYTextInput[j]:ClearFocus()
							LYTextInput[j]:SetText(value)
							LYSettings[class][i][j].LUA = value
						end
						GameTooltip:Hide()
					end)
					LYTextInput[j]:Show()
					LYText[j]:SetPoint("TOPLEFT",LYText[j]:GetStringWidth()+tX+130,tY)
				end
			end
			local function FillSpellTable(Table)
				local function SetSpellTable(Table)
					local maxx = #Table
					if maxx == 0 then
						maxx = 2
					end
					for i=1,#Table do
						SpellTableContent.Items[i]:Enable()
						SpellTableContent.Items[i].Text:SetText(Table[i] or "")
					end
				end
				local function AddSpell(i)
					SpellTableContent.Items[i] = AddButton(SpellTableContent,"TOP",0,(-(i-1)*16)-5,12,180)
					SpellTableContent.Items[i].Number = i
					SpellTableContent.Items[i].Text:SetAllPoints(SpellTableContent.Items[i])
					SpellTableContent.Items[i].Texture = SpellTableContent.Items[i]:CreateTexture(nil,"BACKGROUND")
					SpellTableContent.Items[i].Texture:SetAllPoints(SpellTableContent.Items[i])
					if not LYSkinELVUILoaded then
						SpellTableContent.Items[i].Texture:SetColorTexture(255,0,0)
					else
						SpellTableContent.Items[i].Texture:SetTexture(LYElvUIGlossTexture)
						SpellTableContent.Items[i].Texture:SetVertexColor(LYElvUIValueColor.r,LYElvUIValueColor.g,LYElvUIValueColor.b,LYElvUIValueColor.a)
					end
					SpellTableContent.Items[i].Texture:SetAlpha(0)
					SpellTableContent.Items[i]:Disable()
					SpellTableContent.Items[i]:SetScript("OnEnter",function (self) if (SLTemp ~= self) then self.Texture:SetAlpha(0.3) end end)
					SpellTableContent.Items[i]:SetScript("OnLeave",function (self) if (SLTemp ~= self) then self.Texture:SetAlpha(0) end end)
					SpellTableContent.Items[i]:SetScript("OnClick",function (self)
					if SLTemp then
						SLTemp.Texture:SetAlpha(0)
					end
					SLTemp = self
					self.Texture:SetAlpha(0.6) end)
				end
				table.sort(Table)
				SpellTableInput:SetScript("OnEnterPressed",function (self)
					local input = SpellTableInput:GetText()
					if type(input) == "number" then
						input = GetSpellInfo(input)
					end
					tinsert(Table,input)
					AddSpell(#Table)
					SetSpellTable(Table)
					SpellTableInput:ClearFocus()
					SpellTableInput:SetText("")
				end)
				SpellTableAddButton:SetScript("OnClick",function ()
					local input = SpellTableInput:GetText()
					if type(input) == "number" then
						input = GetSpellInfo(input)
					end
					tinsert(Table,input)
					AddSpell(#Table)
					SetSpellTable(Table)
					SpellTableInput:ClearFocus()
					SpellTableInput:SetText("")
				end)
				for i=1,#LYPrevTable do
					if SpellTableContent.Items[i] then
						SpellTableContent.Items[i].Text:SetText("")
					end
				end
				LYPrevTable = Table
				for i=1,#Table do
					AddSpell(i)
				end
				SpellTableDeletButton:SetScript("OnClick",function ()
					if SLTemp then
						SpellTableContent.Items[#Table]:Hide()
						tremove(Table,SLTemp.Number)
						SLTemp = nil
						if #Table ~= 0 then
							SetSpellTable(Table)
						end
					end
				end)
				SetSpellTable(Table)
				SpellTableList:SetScrollChild(SpellTableContent)
			end
			if option == "GENERAL" then
				for i=1,35 do
					AddUIOptions(i)
				end
				for i=1,#LYSettings[0][text] do
					EnableOption(0,text,i)
				end
			elseif option == "CLASS" then
				for i=1,35 do
					AddUIOptions(i)
				end
				for i=1,#LYSettings[LYMyClass][text] do
					EnableOption(LYMyClass,text,i)
				end
			elseif option == "TABLES" then
				SpellTableMain:Show()
				SpellTableInput:Show()
				SpellTableContent:Show()
				SpellTableList:Show()
				SpellTableDeletButton:Show()
				SpellTableAddButton:Show()
				FillSpellTable(TablesDecoding[text])
			end
		end
		local function FillMainMenu(frame,content)
			local function SetTable(frame,content)
				for i=1,#content do
					if frame.Items[i] then
						frame.Items[i]:Enable()
						frame.Items[i].Text:SetText(content[i])
					end
				end
			end
			local GlowTemp, MLTemp = nil, nil
			local function AddItem(frame,i)
				frame.Items[i] = AddButton(frame,"TOP",0,(-(i-1)*16)-5,12,150)
				frame.Items[i].Number = i
				frame.Items[i].Text:SetAllPoints(frame.Items[i])
				frame.Items[i].Texture = frame.Items[i]:CreateTexture(nil,"BACKGROUND")
				frame.Items[i].Texture:SetAllPoints(frame.Items[i])
				if not LYSkinELVUILoaded then
					frame.Items[i].Texture:SetColorTexture(255,0,0)
				else
					frame.Items[i].Texture:SetTexture(LYElvUIGlossTexture)
					frame.Items[i].Texture:SetVertexColor(LYElvUIValueColor.r,LYElvUIValueColor.g,LYElvUIValueColor.b,LYElvUIValueColor.a)
				end
				frame.Items[i].Texture:SetAlpha(0)
				frame.Items[i]:Disable()
				frame.Items[i]:SetScript("OnEnter",function (self) if (GlowTemp ~= self) then self.Texture:SetAlpha(0.3) end end)
				frame.Items[i]:SetScript("OnLeave",function (self) if (GlowTemp ~= self) then self.Texture:SetAlpha(0) end end)
				frame.Items[i]:SetScript("OnClick",function (self)
					if GlowTemp then
						GlowTemp.Texture:SetAlpha(0)
					end
					if i ~= 1 then
						frame.Items[1].Texture:SetAlpha(0)
					end
					GlowTemp = self
					HideThirdList()
					if frame == MainListContent then
						MLTemp = MainListTable[i]
						for j=1,35 do
							if SecondListContent.Items[j] then
								SecondListContent.Items[j]:Disable()
								SecondListContent.Items[j].Text:SetText("")
							end
						end
						if MLTemp == "GENERAL" then
							SetTable(SecondListContent,MainTabTable)
						end
						if MLTemp == "CLASS" then
							table.sort(ClassTabTable)
							SetTable(SecondListContent,ClassTabTable)
						end
						if MLTemp == "TABLES" then
							SetTable(SecondListContent,TablesTabTable)
						end
					else
						local text = frame.Items[i].Text:GetText()
						LoadThirdList(MLTemp,text)
					end
					self.Texture:SetAlpha(0.6)
				end)
			end
			for i=1,#content do
				AddItem(MainListContent,i)
			end
			for i=1,#ClassTabTable do
				AddItem(SecondListContent,i)
			end
			SetTable(MainListContent,content)
		end
		function OpenSettings()
			LegacyFrame:Show()
		end
		LegacyFrameMap:SetScript("OnClick",function(self,clickType)
			if clickType == "LeftButton" then
				LY_StartStop()
			elseif clickType == "RightButton" then
				OpenSettings()
			end
		end)
		LegacyFrameMap:SetScript("OnDragStart",function(self,btn)
			self.dragging = true
			self:LockHighlight()
			LYMinimapIcon:SetTexCoord(0,1,0,1)
			self:SetScript("OnUpdate",function(self,btn)
				local mx,my = Minimap:GetCenter()
				local px,py = GetCursorPosition()
				local scale = Minimap:GetEffectiveScale()
				px,py = px / scale,py / scale
				local deg = math.deg(math.atan2(py - my,px - mx)) % 360
				local angle = math.rad(deg)
				local x,y,q = math.cos(angle),math.sin(angle),1
				if x < 0 then q = q + 1 end
				if y > 0 then q = q + 2 end
				local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
				local minimapShapes = {
					["ROUND"] = {true, true, true, true},
					["SQUARE"] = {false, false, false, false},
					["CORNER-TOPLEFT"] = {false, false, false, true},
					["CORNER-TOPRIGHT"] = {false, false, true, false},
					["CORNER-BOTTOMLEFT"] = {false, true, false, false},
					["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
					["SIDE-LEFT"] = {false, true, false, true},
					["SIDE-RIGHT"] = {true, false, true, false},
					["SIDE-TOP"] = {false, false, true, true},
					["SIDE-BOTTOM"] = {true, true, false, false},
					["TRICORNER-TOPLEFT"] = {false, true, true, true},
					["TRICORNER-TOPRIGHT"] = {true, false, true, true},
					["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
					["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
				}
				local quadTable = minimapShapes[minimapShape]
				if quadTable[q] then
					x,y = x*80,y*80
				else
					local diagRadius = 103.13708498985
					x = math.max(-80,math.min(x*diagRadius,80))
					y = math.max(-80,math.min(y*diagRadius,80))
				end
				self:SetPoint("CENTER",self:GetParent(),"CENTER",x,y)
				MiniMapX = x
				MiniMapY = y
			end)
		end)
		LegacyFrameMap:SetScript("OnEnter",function(self)
			GameTooltip:SetOwner(self,"ANCHOR_TOPRIGHT")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(LYL["Left-click to start/stop\nRight-click to open settings\nRight-click and hold to move the icon around the minimap"],NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,true)
			GameTooltip:Show()
		end)
		LegacyFrameMap:SetScript("OnLeave",function(self)
			GameTooltip:Hide()
		end)
		LegacyFrameMap:SetScript("OnDragStop",function(self,btn)
			self.dragging = nil
			self:SetScript("OnUpdate",nil)
			LYMinimapIcon:SetTexCoord(0.05,0.95,0.05,0.95)
			self:UnlockHighlight()
		end)
		if LYLog and not LYDidGreeting then
			print("[".."|cff20c000".."HandsFree Reborn".."|r".."]".."[Info] Welcome to HandsFree Reborn! Right-click the portal minimap icon to open the settings")
			LYDidGreeting = true
		end
		FillMainMenu(MainListContent,MainListTable)
		HideUI()
	end
	--Draw
	-- modules/arena
	function ArenaTeamAwareness()
		local function HealerLine(pointer)
			local X1,Y1,Z1 = ObjectPosition("player")
			local X2,Y2,Z2 = ObjectPosition(pointer)
			local class = select(2,UnitClass(pointer))
			local guid = UnitGUID(pointer)
			if class == "WARLOCK" or class == "PRIEST" then
				return
			end
			local dist = 0
			local role = CheckRole(pointer)
			if role == "RDPS" then
				dist = 41
			elseif class == "SHAMAN" then
				dist = 26
			elseif role == "MELEE" then
				if class == "DRUID" or class == "DEATHKNIGHT" then
					dist = 16
				elseif class == "DEMONHUNTER" then
					dist = 21
				else
					dist = 6
				end
			else
				return
			end
			if not KicksData[guid] then
				KicksData[guid] = {Time = 0,CD = 0,Percent = 45}
			end
			if IsInDistance(pointer,dist) and (GetTime() - KicksData[guid].Time) > KicksData[guid].CD and not UnitIsCCed(pointer) and InLineOfSight(pointer) then
				graphics.drawing:SetColorRaw(1,0,0,1)
			else
				graphics.drawing:SetColorRaw(0,1,0,1)
			end
			graphics.drawing:SetWidth(3)
			graphics.drawing:Line(X1,Y1,Z1,X2,Y2,Z2)
		end
		local isArena, isRegistered = IsActiveBattlefieldArena()
		if not isArena then
			return
		end
		if LYMyClass == 12 and HaveBuff("player",DHSpectral) then
			for i=1,3 do
				local unit = "arena" .. tostring(i)
				if UnitIsVisible(unit) and HaveBuff(unit,listStealth) then
					local X1,Y1,Z1 = ObjectPosition("player")
					local X2,Y2,Z2 = ObjectPosition(unit)
					graphics.drawing:SetColorRaw(1,0,0,1)
					graphics.drawing:SetWidth(3)
					graphics.drawing:Line(X1,Y1,Z1,X2,Y2,Z2)
				end
			end
		end
		if LYPlayerRole == "HEALER" then
			-- track kicks
			if LYMarkKick then
				for i=1,3 do
					local unit = "arena" .. tostring(i)
					if UnitIsVisible(unit) then
						HealerLine(unit)
					end
				end
			end
			-- track dps los
			if LYMarkFrDPS then
				for i=1,2 do
					local unit = "party" .. tostring(i)
					if UnitIsVisible(unit) then
						local X1,Y1,Z1 = ObjectPosition("player")
						local X2,Y2,Z2 = ObjectPosition(unit)
						if InLineOfSight(unit) and IsInDistance(unit) then
							graphics.drawing:SetColorRaw(0,1,0,1)
						else
							graphics.drawing:SetColorRaw(1,0,0,1)
						end
						graphics.drawing:SetWidth(3)
						graphics.drawing:Line(X1,Y1,Z1,X2,Y2,Z2)
					end
				end
			end
		end
		if not (LYMarkHealer or LYMarkFrTarget) then return end
		for i=1,GetNumGroupMembers() do
			local unit = "party" .. tostring(i)
			if UnitIsVisible(unit) then
				-- track healer
				if UnitGroupRolesAssigned(unit) == "HEALER" then
					if LYMarkHealer then
						local tX, tY, tZ = ObjectPosition(unit)
						local pX, pY, pZ = ObjectPosition("player")
						if not pX or not pY or not pZ or not tX or not tY or not tZ then
							return
						end
						if not TraceLine(pX, pY, pZ + 2, tX, tY, tZ + 2, 0x100011) then
							graphics.drawing:SetColorRaw(0,1,0,1)
						else
							graphics.drawing:SetColorRaw(1,0,0,1)
						end
						graphics.drawing:SetWidth(3)
						graphics.drawing:Line(pX,pY,pZ,tX,tY,tZ)
					end
				-- track teammate target
				elseif LYMarkFrTarget then
					local target = UnitTarget(unit)
					if UnitIsVisible(target) and not UnitIsUnit("player", target) then
						graphics.drawing:SetColor(244,208,63,100)
						graphics.drawing:SetWidth(2)
						local x, y, z = ObjectPosition(target)
						graphics.drawing:GroundCircle(x,y,z,2)
					end
				end
			end
		end
	end
	-- modules/arena end
	graphics:AddDrawingCallback("arena", ArenaTeamAwareness)
	--Class specific
	function DKSummonPet()
		if GCDCheck(DKPet) and LYLastSpellName ~= DKPet and ((LYMySpec == 3 and (not UnitIsVisible("pet") or UnitIsDeadOrGhost("pet"))) or (LYMySpec ~= 3 and LYDKPet and UnitAffectingCombat("player") and not GetTotemInfo(1))) then
			PetDismiss()
			LYQueueSpell(DKPet)
			LY_Print("Resummoned Pet","green")
			return true
		end
	end
	function DKCancelLichborn()
		if HaveBuff("player",DKLichborn) then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and castName == PrShackle then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 90 then
							CancelBuffByName(DKLichborn)
							return true
						end
					end
				end
			end
		end
	end
	function DKLichbornHeal()
		if GCDCheck(DKCoil) and HaveBuff("player",DKLichborn) and not HaveDebuff("player",PrMindGame) and CalculateHP("player") < 80 then
			LYQueueSpell(DKCoil,"player")
			return true
		end
	end
	function DKAntiDrink()
		if GCDCheck(DKEpidemic) and LYZoneType == "arena" then
			for i=1,#LYEnemiesAll do
				if ValidEnemyUnit(LYEnemiesAll[i]) and HaveBuff(LYEnemiesAll[i],DrinkMana) and HaveDebuff(LYEnemiesAll[i],DKVirPlague,0.5,"player") and IsInDistance(LYEnemiesAll[i],40) then
					LYQueueSpell(DKEpidemic)
					return true
				end
			end
		end
	end
	function DKRuneCount()
		local count = 0
		for i = 1,6 do
			local isRuneReady = select(3,GetRuneCooldown(i))
			if isRuneReady then
				count = count + 1
			end
		end
		return count
	end
	function DKSacPet()
		if GCDCheck(DKSacPact) and CalculateHP("player") < LYDKSacPact and FriendIsUnderAttack("player") and not HaveDebuff("player",PrMindGame) then
			if GCDCheck(DKPet) and LYLastSpellName ~= DKPet and ((LYMySpec == 3 and (not UnitIsVisible("pet") or UnitIsDeadOrGhost("pet"))) or (LYMySpec ~= 3 and UnitAffectingCombat("player") and not GetTotemInfo(1))) then
				PetDismiss()
				LYQueueSpell(DKPet)
				return true
			end
			if (LYMySpec == 3 and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet")) or (LYMySpec ~= 3 and GetTotemInfo(1)) then
				LYQueueSpell(DKSacPact)
				LY_Print(DKSacPact,"green")
				return true
			end
		end
	end
	function DKWalkPause()
		if HaveBuff("player",DKWrWalk) and UnitIsVisible(LYEnemyTarget) and not inRange(DKFStrike,LYEnemyTarget) then
			return true
		end
	end
	function DKReflectIncCC()
		if GCDCheck(DKAMS) and LYMode ~= "PvE" and LYKickPause == 0 then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and tContains(listRefl,castName) then
						local spellTarget = GetSpellDestUnit(LYEnemies[i])
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if UnitIsVisible(spellTarget) and ((UnitIsUnit("player",spellTarget) and ((LYDKAMSCCBurst and IsBursting()) or EnemyHPBelow(LYDKAMSCCHP))) or ((IsPvPTalentInUse(5590) or IsPvPTalentInUse(5591) or IsPvPTalentInUse(5592)) and (CheckRole(spellTarget) == "HEALER" or LYDKAMSCCAll))) and not HaveBuff(spellTarget,ShGroundEffect) and currentPercent > 90 and InLineOfSight(spellTarget) then
							CastSpellByName(DKAMS,spellTarget)
							LYKickPause = GetTime()
							LY_Print(DKAMS.." CC on "..UnitName(spellTarget),"green",DKAMS)
							return true
						end
					end
				end
			end
		end
	end
	function DKSimulFire()
		if LYDKSimulFire and LYMode ~= "PvE" and GCDCheck(DKSimul) and HaveBuff("player",DKSimul) then
			local DKSimSName,_,DKSimCTime = GetSpellInfo(DKSimul)
			if tContains(listCCInt,DKSimSName) then
				for i=1,#LYEnemyHealers do
					if inRange(DKSimul,LYEnemyHealers[i]) and SpellAttackTypeCheck(LYEnemyHealers[i],"magic") and not EnemyIsUnderAttack(LYEnemyHealers[i]) and not UnitIsCCed(LYEnemyHealers[i]) and LYFacingCheck(LYEnemyHealers[i]) then
						LYQueueSpell(DKSimul,LYEnemyHealers[i])
						LY_Print(DKSimSName.." @Enemy Healer","green",DKSimSName)
						return true
					end
				end
				for i=1,#LYEnemies do
					if inRange(DKSimul,LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and not EnemyIsUnderAttack(LYEnemies[i]) and not UnitIsCCed(LYEnemies[i]) and LYFacingCheck(LYEnemies[i]) then
						LYQueueSpell(DKSimul,LYEnemies[i])
						LY_Print(DKSimSName.." @Enemy DPS","green",DKSimSName)
						return true
					end
				end
			elseif not C_Spell.IsSpellHarmful(DKSimSName) then
				for i=1,#LYTeamPlayers do
					if CalculateHP(LYTeamPlayers[i]) < 85 and inRange(DKSimul,LYTeamPlayers[i]) then
						LYQueueSpell(DKSimul,LYTeamPlayers[i])
						LY_Print(DKSimSName.." @Friend","green",DKSimSName)
						return true
					end
				end
			elseif ValidEnemyUnit(LYEnemyTarget) and IsInDistance(LYEnemyTarget,40) and SpellAttackTypeCheck(LYEnemyTarget,"magic") and LYFacingCheck(LYEnemyTarget) then
				LYQueueSpell(DKSimul,LYEnemyTarget)
				LY_Print(DKSimSName.." @Enemy Target","green",DKSimSName)
				return true
			end
		end
	end
	function DKSimulStealCC()
		if GCDCheck(DKSimul) and LYMode ~= "PvE" and LYDKSimulCC and not HaveBuff("player",DKSimul) and LYKickPause == 0 then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and inRange(DKSimul,LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if tContains(listSim,castName) and SpellAttackTypeCheck(LYEnemies[i],"magic") and currentPercent > 85 then
							LYSpellStopCasting()
							LYQueueSpell(DKSimul,LYEnemies[i],"face")
							LY_Print(DKSimul.." "..castName,"green",DKSimul)
							return true
						end
					end
				end
			end
		end
	end
	function DHConsumeMagicCast()
		if GCDCheck(DHConsumeMagic) and LYStyle ~= "Utilities only" then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and inRange(DHConsumeMagic,LYEnemies[i]) and NumberOfPurgeBuffs(LYEnemies[i]) ~= 0 then
					LYQueueSpell(DHConsumeMagic,LYEnemies[i])
					return true
				end
			end
		end
	end
	function DHFelRushTarget(target)
		Face(target,false)
		CastSpellByName(DHFelRush)
	end
	function DHReverseMagic()
		if GCDCheck(DHRevMagic) and LYMode ~= "PvE" then
			if PartyHPBelow(LYDHRevMagTeam) then
				for i=1,#LYTeamHealersAll do
					if HaveDebuff(LYTeamHealersAll[i],listDHDispel,LYDHRevMagCC) and IsInDistance(LYTeamHealersAll[i],25) and not HaveDebuff(LYTeamHealersAll[i],listIInteract) and InLineOfSight(LYTeamHealersAll[i]) then
						if IsInDistance(LYTeamHealersAll[i],8) then
							LYQueueSpell(DHRevMagic)
							LY_Print(DHRevMagic.." team healer","green",DHRevMagic)
							return true
						elseif GCDCheck(DHFelRush) and not IsRooted() and InLineOfSight(LYTeamHealersAll[i]) then
							DHFelRushTarget(LYTeamHealersAll[i])
							return true
						end
					end
				end
			end
			if #LYTeamHealersAll == 0 and LYDHRevMagDPS then
				for i=1,#LYTeamPlayers do
					if ((CalculateHP(LYTeamPlayers[i]) < LYDHRevMagHP and HaveDebuff(LYTeamPlayers[i],listMDoTs,3) and FriendIsUnderAttack(LYTeamPlayers[i])) or (HaveDebuff(LYTeamPlayers[i],listDHDispel,LYDHRevMagCC) and EnemyHPBelow(LYDHRevMagEnemy))) and IsInDistance(LYTeamPlayers[i],8) then
						LYQueueSpell(DHRevMagic)
						LY_Print(DHRevMagic.." DPS teammate","green",DHRevMagic)
						return
					end
				end
			end
		end
	end
	function DHGlideKnocks()
		if IsFalling() and LYMode ~= "PvE" and HaveDebuff("player",listKnocks) and GCDCheck(DHGlide) then
			CastSpellByName(DHGlide)
		end
	end
	function DHFelRushEvade()
		if GCDCheck(DHFelRush) and not IsRooted() and LYDHFelRushAway then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if tContains(LYReflectAlways,castName) and PlayerIsSpellTarget(LYEnemies[i]) and currentPercent > 85 and IsInDistance(LYEnemies[i],9) then
							LYSpellStopCasting()
							DHFelRushTarget(LYEnemies[i])
							LY_Print(DHFelRush.." "..castName,"green",DHFelRush)
							return true
						end
					end
				end
			end
		end
	end
	function DHSigilMisKick()
		if GCDCheck(DHSigilMisery) and LYDHSigMisAlt and LYKickPause == 0 and (LYMode ~= "PvE" or not UnitChannelInfo("player")) then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
					local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(LYEnemies[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						castInterruptable = channelInterruptable
						modified = true
					end
					if castName and not castInterruptable and SpellAttackTypeCheck(LYEnemies[i],"magic") and ValidKick(LYEnemies[i],castName) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						local castTimeLeft = castTime - timeSinceStart
						if currentPercent > 10 and castTimeLeft > 2.1 then
							LYQueueSpell(DHSigilMisery,LYEnemies[i])
							LYKickPause = GetTime()
							LY_Print(DHSigilMisery.." "..castName,"green",DHSigilMisery)
							return true
						end
					end
				end
			end
		end
	end
	function DrKickPlayers()
		if GCDCheck(DrKick) and LYKickPause == 0 and not IsRooted() and not UnitChannelInfo("player") then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
					local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(LYEnemies[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						castInterruptable = channelInterruptable
						modified = true
					end
					if castName and not castInterruptable and SpellAttackTypeCheck(LYEnemies[i],"phys") and ValidKick(LYEnemies[i],castName) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						local castTimeLeft = castTime - timeSinceStart
						if castTime > LYKickMin and currentPercent < 95 then
							if inRange(DrKick,LYEnemies[i]) then
								if currentPercent > KickTime or (modified and timeSinceStart > KickDelayFixed) then
									LYSpellStopCasting()
									LYQueueSpell(DrKick,LYEnemies[i],"face")
									LYKickPause = GetTime()
									LY_Print(DrKick.." "..castName,"green",DrKick)
									return true
								end
							elseif inRange(DrWildCharge,LYEnemies[i]) and (LYDrChargeKick or (LYDrChargeKickHeal and CheckRole(LYEnemies[i]) == "HEALER")) and GCDCheck(DrWildCharge) and currentPercent > 10 and castTimeLeft < 500 then
								LYSpellStopCasting()
								LYQueueSpell(DrWildCharge,LYEnemies[i])
								LY_Print(DrWildCharge.." to kick","green",DrWildCharge)
								return true
							end
						end
					end
				end
			end
		end
	end
	function DrAutoBuffSelfWild()
		if not HaveBuff("player", DrMarkWild) and GCDCheck(DrMarkWild) then return LYQueueSpell(DrMarkWild, "player") end
	end
	function DrAntiHibr()
		if GetShapeshiftForm() ~= 0 and not HaveBuff("player",DrOwl) then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and (castName == DrHibernate or castName == HnScareBeast) and PlayerIsSpellTarget(LYEnemies[i]) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 50 then
							CancelShapeshiftForm()
							PauseGCD = GetTime() + 0.5
							return true
						end
					end
				end
			end
		end
	end
	function DrSwiftMend()
		local spell = DrSMend
		if LYMySpec == 4 and not GCDCheck(DrSMend) and GCDCheck(DrGroveGuard) then
			spell = DrGroveGuard
		end
		if GCDCheck(spell) and LYStyle ~= "Utilities only" and LYLastSpellName ~= DrSMend and LYLastSpellName ~= DrGroveGuard then
			for i=1,#LYTeamPlayers do
				if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < LYDrSMendHP and HaveBuff(LYTeamPlayers[i],{DrRejuv,DrRegr,DrWGrowth},0.5,"player") then
					LYQueueSpell(spell,LYTeamPlayers[i])
					return true
				end
			end
		end
	end
	function DrQueueStun()
		if GCDCheck(DrMaim) and UnitIsVisible(LYNextStun) and SpellAttackTypeCheck(LYNextStun,"phys") and inRange(DrMaim,LYNextStun) and LYCP == LYCPMax and not UnitIsCCed(LYNextStun) and not UnitIsKicked(LYNextStun) then
			LYCurrentSpellName = nil
			LYQueueSpell(DrMaim,LYNextStun)
			LY_Print(DrMaim,"green")
			return true
		end
	end
	function DrBearAction()
		if GetShapeshiftForm() == 1 then
			DrKickPlayers()
			ConditionalSpell(DrRegen,CalculateHP("player") < 85 and not HaveBuff("player",DrRegen))
			ConditionalSpell(DrIronfur,FriendIsUnderAttack("player") and not HaveBuff("player",DrIronfur))
			if DefensiveOnPlayer(DrHeartWild,nil,LYDrHeartWildDefHP,LYDrHeartWildDefBurst,LYDrHeartWildDefHealer,true) or
			CommonAttack(DrEnrMaul,"phys",true,DrEnrMaul,true) or
			CommonAttack(DrMangle,"phys",true,DrMangle,true) or
			CommonAttack(DrThrash,"phys",true,DrMangle,true) or
			CommonAttack(DrSwipe,"phys",true,DrMangle,LYMySpec == 2) or
			CommonAttack(DrMF,"magic",nil,DrSoothe,LYMySpec == 3,0,DrMF) or
			CommonAttack(DrMF,"magic",nil,DrSoothe,LYMySpec == 3) then
				return true
			end
		end
	end
	function DrOwlAction()
		if HaveBuff("player",DrOwl) or (LYMySpec == 4 and GetShapeshiftForm() == 0 and (CalculateMP("player") > LYHealerDPS or LYHDPS)) then
			if ConditionalSpell(DrHeartWild,LYDrHeartWildDPS and (LYMySpec ~= 4 or LYHDPS) and InEnemySight()) or
			CommonAttack(DrSSurge,"magic",true,DrSSurge,not IsMoving()) or
			CommonAttack(DrSF,"magic",nil,DrSF,true,5,DrSF) or
			CommonAttack(DrMF,"magic",nil,DrMF,true,5,DrMF) or
			CommonAttack(DrSFire,"magic",true,DrSFire,not IsMoving(),nil,nil,2) or
			CommonAttack(DrWrath,"magic",true,DrMF,not IsMoving() or HaveBuff("player",DrIncTreeForm)) then
				return true
			end
		end
	end
	function DrCatAction()
		if GetShapeshiftForm() == 2 then
			DrKickPlayers()
			if ConditionalSpell(DrHeartWild,LYDrHeartWildDPS and EnemiesAroundUnit(DrShred) > 0) or
			DrQueueStun() or
			CommonAttack(DrFBite,"phys",true,DrShred,LYCP > 4 and LYUP > 49) or
			CommonAttack(DrRake,"phys",true,DrShred,LYCP < 5,4,DrRake) or
			ConditionalSpell(DrSwipe,LYCP < 5 and EnemiesAroundUnit(DrShred) > 1) or
			CommonAttack(DrShred,"phys",true,DrShred,LYCP < 5) then
				return true
			end
		end
	end
	function DrHealMode()
		if not LYHDPS then
			return
		end
		if DefensiveOnTeam(DrHeartWild,nil,LYDrHeartWildHealHP,LYDrHeartWildHealBurst,nil,true) or
		DrSwiftMend() or
		CommonHeal(DrRejuv,true,90,4) or
		CommonHeal(DrRegr,not IsMoving(),90) then
			return true
		end
	end
	function EvReleaseEmpowered()
		local channelName, _, _, channelStartTime, channelEndTime = UnitChannelInfo("player")
		if channelName == EvEternSurge then
			local total = (channelEndTime - channelStartTime)/1000
			local count = EnemiesAroundUnit(12,LYEnemyTarget)
			local enemiesPerRank = 1
			local maxRanks = 3
			if IsTalentInUse(375757) then
				enemiesPerRank = 2
			end
			if IsTalentInUse(375783) then
				maxRanks = 4
			end
			local optimalRank = math.min(math.ceil(count/enemiesPerRank),maxRanks)
			local minimumTime = total * ((1/maxRanks * optimalRank) + LYMyPing)
			if (GetTime() - channelStartTime/1000) > minimumTime then
				CastSpellByName(EvEternSurge)
				return true
			end
		elseif channelName == EvFireBreath then
			local total = (channelEndTime - channelStartTime)/1000
			local count = EnemiesAroundUnit(12, LYEnemyTarget)
			local maxRanks = 3
			if IsTalentInUse(375783) then
				maxRanks = 4
			end
			-- simc variables
			local playerHaste = UnitSpellHaste("player")
			local spell_haste = 1/((playerHaste/100) + 1)
			local blastFurnaceRank = 0
			if IsTalentInUse(375510) and PlayerTalentRanks[375510] then
				blastFurnaceRank = PlayerTalentRanks[375510]
			end
			local everburningFlame = IsTalentInUse(370819)
			local fireBreathDamageRemains = BuffTimeLeft(LYEnemyTarget,EvFireBreathDot)
			if fireBreathDamageRemains == 100 then
				fireBreathDamageRemains = 0
			end
			local dragonBreathRemains = BuffTimeLeft("player",EvDragonrage)
			if dragonBreathRemains == 100 then
				dragonBreathRemains = 0
			end
			local optimalRank = 0
			if count >= 3 then
				-- aoe IV logic
				local fire_breath_cooldown_remains = CDLeft(EvFireBreath)
				local eternity_surge_cooldown_remains = CDLeft(EvEternSurge)
				local gcdMax =  1.5 / ((playerHaste/100) + 1)
				if fire_breath_cooldown_remains <= gcdMax and eternity_surge_cooldown_remains < 3 * gcdMax then
					optimalRank = 4
				end
				-- default logic
				if optimalRank == 0 then
					local cooldownDragonrageRemains = CDLeft(EvDragonrage)
					-- single target logic only with different condition below
					if dragonBreathRemains > 0 or not IsTalentInUse(375087) or (cooldownDragonrageRemains > 10) and everburningFlame then
						if count <= 2 or ((20 + 2 * blastFurnaceRank) + fireBreathDamageRemains < (20 + 2 * blastFurnaceRank) * 1.3) or (dragonBreathRemains < 1.75 * spell_haste and dragonBreathRemains >= 1 * spell_haste) then
							optimalRank = 1
						elseif ((14 + 2 * blastFurnaceRank) + fireBreathDamageRemains < (20 + 2 * blastFurnaceRank) * 1.3) or (dragonBreathRemains < 2.5 * spell_haste and dragonBreathRemains >= 1.75 * spell_haste) then
							optimalRank = 2
						elseif maxRanks == 3 or ((8 + 2 * blastFurnaceRank) + fireBreathDamageRemains < (20 + 2 * blastFurnaceRank) * 1.3) or (dragonBreathRemains < 3.25 * spell_haste and dragonBreathRemains >= 2.5 * spell_haste) then
							optimalRank = 3
						else
							optimalRank = 4
						end
					else
						-- aoe logic
						if (cooldownDragonrageRemains > 10 or not IsBursting()) and count >= 7 then
							optimalRank = 1
						elseif (cooldownDragonrageRemains > 10 or not IsBursting()) and count >= 6 then
							optimalRank = 2
						elseif (cooldownDragonrageRemains > 10 or not IsBursting()) and count >= 4 then
							optimalRank = 3
						elseif (cooldownDragonrageRemains > 10 or not IsBursting()) then
							optimalRank = 2
						end
					end
					if optimalRank == 0 then
						optimalRank = 1
					end
				end
			else
				-- single target logic
				if count <= 2 or ((20 + 2 * blastFurnaceRank) + fireBreathDamageRemains < (20 + 2 * blastFurnaceRank) * 1.3) or (dragonBreathRemains < 1.75 * spell_haste and dragonBreathRemains >= 1 * spell_haste) then
					optimalRank = 1
				elseif ((14 + 2 * blastFurnaceRank) + fireBreathDamageRemains < (20 + 2 * blastFurnaceRank) * 1.3) or (dragonBreathRemains < 2.5 * spell_haste and dragonBreathRemains >= 1.75 * spell_haste) then
					optimalRank = 2
				elseif maxRanks == 3 or ((8 + 2 * blastFurnaceRank) + fireBreathDamageRemains < (20 + 2 * blastFurnaceRank) * 1.3) or (dragonBreathRemains < 3.25 * spell_haste and dragonBreathRemains >= 2.5 * spell_haste) then
					optimalRank = 3
				else
					optimalRank = 4
				end
			end
			if LYZoneType == "pvp" then
				optimalRank = 4
			end
			local minimumTime = total * ((1/maxRanks * optimalRank) + LYMyPing)
			local maximumTime = total * ((1/maxRanks * maxRanks) + LYMyPing)
			local time = GetTime() - channelStartTime/1000
			if time >= minimumTime or time >= maximumTime then
				CastSpellByName(EvFireBreath)
				return true
			end
		elseif channelName == EvDreamProject and CalculateHP("player") < LYEvDreamProjectHP and not HaveDebuff("player",WlUnstable) then
			CastSpellByName(EvDreamProject)
			return true
		elseif channelName == EvSpiritbloom then
			local total = (channelEndTime - channelStartTime)/1000
			local teammatesLow = TeamMembersAroundUnit(30,"player",90)
			local maxRanks = 3
			local optimalRank = 0
			if teammatesLow <= 1 then
				optimalRank = 1
			elseif teammatesLow == 2 then
				optimalRank	 = 2
			else
				optimalRank = 3
			end
			local minimumTime = total * ((1/maxRanks * optimalRank) + LYMyPing)
			local maximumTime = total * ((1/maxRanks * maxRanks) + LYMyPing)
			local time = GetTime() - channelStartTime/1000
			if time >= minimumTime or time >= maximumTime then
				CastSpellByName(EvSpiritbloom)
				return true
			end
		elseif channelName == EvDreamBreath then
			local total = (channelEndTime - channelStartTime)/1000
			local haveBuff = HaveBuff("player",363916)
			local interruptImmune = IsPvPTalentInUse(5459) and haveBuff
			local maxRanks = 3
			local optimalRank = 0
			if (PartyHPBelow(LYEvDreamBreathR3HP) and LYEvDreamBreathRank3 and (not LYEvDreamBreathRank3Immune or interruptImmune or LYMode ~= "PvP")) then
				optimalRank = 3
			else
				optimalRank = 1
			end
			local minimumTime = total * ((1/maxRanks * optimalRank) + LYMyPing)
			local maximumTime = total * ((1/maxRanks * maxRanks) + LYMyPing)
			local time = GetTime() - channelStartTime/1000
			if time >= minimumTime or time >= maximumTime then
				CastSpellByName(EvDreamBreath)
				return true
			end
		elseif channelName == EvUpheaval then
			local total = (channelEndTime - channelStartTime)/1000
			local count = 1
			if EnemiesAroundUnit(6,LYEnemyTarget) > EnemiesAroundUnit(3,LYEnemyTarget) then
				count = 2
			end
			if EnemiesAroundUnit(10,LYEnemyTarget) > EnemiesAroundUnit(6,LYEnemyTarget) then
				count = 3
			end
			local maxRanks = 3
			if IsTalentInUse(408083) then
				maxRanks = 4
			end
			local optimalRank = math.min(math.ceil(count,maxRanks))
			local minimumTime = total * ((1/maxRanks * optimalRank) + LYMyPing)
			if (GetTime() - channelStartTime/1000) > minimumTime then
				CastSpellByName(EvUpheaval)
				return true
			end
		end
	end
	function EvTimeStopCC()
		if CDCheck(EvTimeStop) and LYMode ~= "PvE" and not HaveBuff("player",{PlSac,PlBubble}) and PartyHPBelow(LYEvTimeStopCCHP) then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and tContains(listSWDCC,castName) and CheckUnitDRSpell("player",castName) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 80 then
							for k=1,#LYTeamPlayers do
								if inRange(EvTimeStop,LYTeamPlayers[k]) and UnitIsUnit(LYTeamPlayers[k],GetSpellDestUnit(LYEnemies[i])) then
									LYSpellStopCasting()
									CastSpellByName(EvTimeStop,LYTeamPlayers[k])
									LY_Print(EvTimeStop.." "..castName,"green",EvTimeStop)
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	function EvSourceMagicCast()
		if GCDCheck(EvSourceMagic) and LYStyle ~= "Utilities only" and not AnyFriendHasBuff(EvSourceMagic) then
			for i=1,#LYTeamHealers do
				if ValidFriendUnit(LYTeamHealers[i]) and inRange(EvSourceMagic,LYTeamHealers[i]) and not UnitIsUnit(LYTeamHealers[i],"player") and not HaveBuff(LYTeamHealers[i],EvSourceMagic,0,"player") then
					LYQueueSpell(EvSourceMagic,LYTeamHealers[i])
					return true
				end
			end
		end
	end
	function EvNullShroudCast()
		if CDCheck(EvNullShroud) and LYMode ~= "PvE" and not IsMoving() and LYKickPause == 0 and UnitCastingInfo("player") ~= EvNullShroud then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and PlayerIsSpellTarget(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and tContains(listCCInt,castName) and CheckUnitDRSpell(LYEnemies[i],castName,1) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local castTimeLeft = castTime - timeSinceStart
						if C_Spell.GetSpellInfo(EvNullShroud).castTime < castTimeLeft + 50 then
							LYSpellStopCasting()
							LYQueueSpell(EvNullShroud)
							LY_Print(EvNullShroud.." "..castName,"green",EvNullShroud)
							LYKickPause = GetTime()
							return true
						end
					end
				end
			end
		end
	end
	function EvVerdEmbraceCast()
		if GCDCheck(EvVerdEmbrace) and LYStyle ~= "Utilities only" then
			for i=1,#LYTeamPlayers do
				if ValidFriendUnit(LYTeamPlayers[i]) and inRange(EvVerdEmbrace,LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 80 and (UnitIsUnit("player",LYTeamPlayers[i]) or (not LYDPSSelfHeal and (not EnemyHPBelow(40) or EnemiesAroundUnit(8) < 1))) then
					LYQueueSpell(EvVerdEmbrace,LYTeamPlayers[i])
					return true
				end
			end
		end
	end
	function HnMark()
		if GCDCheck(HnHuntMark) and LYStyle ~= "Utilities only" and not AnyEnemyHasDebuff(HnHuntMark) and UnitAffectingCombat("player") then
			if LYMode ~= "PvE" then
				local unit = EnemyClassExists("ROGUE")
				if UnitIsVisible(unit) and SpellAttackTypeCheck(unit,"magic") and inRange(HnHuntMark,unit) and LYFacingCheck(unit) then
					LYQueueSpell(HnHuntMark,unit)
					return true
				end
			elseif UnitIsVisible(LYEnemyTarget) and inRange(HnHuntMark,LYEnemyTarget) and UnitIsBoss(LYEnemyTarget) and CalculateHP(LYEnemyTarget) > 80 and LYFacingCheck(LYEnemyTarget) then
				LYQueueSpell(HnHuntMark,LYEnemyTarget)
				return true
			end
		end
	end
	function HnFDDef()
		if GCDCheck(HnFD) and CalculateHP("player") < LYHnFDHP and FriendIsUnderAttack("player") then
			StopMoving()
			LYSpellStopCasting()
			CastSpellByName(HnFD)
			PauseGCD = GetTime() + 3
			LY_Print(HnFD,"green")
			return true
		end
	end
	function HnFDCC()
		if CDCheck(HnFD) and LYMode ~= "PvE" and LYKickPause == 0 and ((LYHnFDCCBurst and HaveBuff("player",HnTrueShot)) or EnemyHPBelow(LYHnFDCCHP)) then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and tContains(listCCInt,castName) and not HaveBuff("player",ShGroundEffect) and PlayerIsSpellTarget(LYEnemies[i]) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 85 then
							StopMoving()
							LYSpellStopCasting()
							CastSpellByName(HnFD)
							LYKickPause = GetTime()
							C_Timer.After(0.5,function() CancelBuffByName(HnFD) end)
							LY_Print(HnFD.." "..castName,"green",HnFD)
							return true
						end
					end
				end
			end
		end
	end
	function HnCastSteelTrap()
		if GCDCheck(HnSteelTrap) then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and IsInDistance(LYEnemies[i],30) and SpellAttackTypeCheck(LYEnemies[i],"phys")
				and (LYMode == "PvE" or (CheckRole(LYEnemies[i]) == "MELEE" and (IsBursting(LYEnemies[i]) or (UnitIsVisible(LYEnemyTarget) and not UnitIsUnit(LYEnemyTarget,LYEnemies[i])))) or (CalculateHP(LYEnemyTarget) < 35 and not IsInDistance(LYEnemyTarget,10)))
				and not HaveBuff(LYEnemies[i],listIRoot) and CheckUnitDR(LYEnemies[i],"root",1) and not UnitIsCCed(LYEnemies[i],LYGCDTime) and not IsRooted(LYEnemies[i],LYGCDTime) then
					LYQueueSpell(HnSteelTrap,LYEnemies[i])
					return true
				end
			end
		end
	end
	function HnPlayDeadCC()
		local function CancelPlayDead()
			for i=1,40 do
				local tBuff = C_UnitAuras.GetBuffDataByIndex("pet",i)
				if tBuff and tBuff.name then
					if tBuff.name == HnPlayDead then
						CancelUnitBuff("pet",i)
					end
				else
					return
				end
			end
		end
		if GCDCheck(HnPlayDead) and LYZoneType == "arena" and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and tContains(listCCInt,castName) and not HaveBuff("pet",ShGroundEffect) then
						local spellTarget = GetSpellDestUnit(LYEnemies[i])
						if UnitIsVisible(spellTarget) and UnitIsUnit("pet",spellTarget) then
							local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
							local castTime = castEndTime - castStartTime
							local currentPercent = timeSinceStart / castTime * 100
							if currentPercent > 85 then
								CastSpellByName(HnPlayDead)
								C_Timer.After(0.5,function() CancelPlayDead() CastSpellByName(HnWakeUp) PetAttack(LYEnemyTarget) end)
								LY_Print(HnPlayDead.." "..castName,"green",HnPlayDead)
								return true
							end
						end
					end
				end
			end
		end
	end
	function HnFDDPS()
		if CDCheck(HnFD) and LYMode ~= "PvE" and LYKickPause == 0 and CalculateHP("player") < LYHnFDDPS then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and tContains(LYReflectAlways,castName) and not HaveBuff("player",ShGroundEffect) and PlayerIsSpellTarget(LYEnemies[i]) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 85 then
							StopMoving()
							LYSpellStopCasting()
							CastSpellByName(HnFD)
							LYKickPause = GetTime()
							C_Timer.After(0.5,function() CancelBuffByName(HnFD) end)
							LY_Print(HnFD.." "..castName,"green",HnFD)
							return true
						end
					end
				end
			end
		end
	end
	function HnFDKarma()
		if CDCheck(HnFD) and IsPvPTalentInUse(3607) and DebuffTimeLeft("player",MnKarma) < 1 then
			StopMoving()
			LYSpellStopCasting()
			CastSpellByName(HnFD)
			C_Timer.After(1.5,function() CancelBuffByName(HnFD) end)
			LY_Print(HnFD.." "..MnKarma,"green",HnFD)
			return true
		end
	end
	function HnBinding()
		if GCDCheck(HnBindShot) and LYMode ~= "PvE" and LYHnBind ~= 0 then
			for i=1,#LYEnemies do
				if IsInDistance(LYEnemies[i],30) and EnemiesAroundUnit(5,LYEnemies[i]) > LYHnBind-1 then
					LYHnBindUnit = LYEnemies[i]
					LYQueueSpell(HnBindShot,LYEnemies[i])
					LY_Print(HnBindShot.." "..LYHnBind.." enemies","green",HnBindShot)
				end
			end
		end
	end
	function HnExploseBinding()
		if UnitIsVisible(LYHnBindUnit) and GCDCheck(HnHiExpTrap) and LYLastSpellName == HnBindShot then
			LYCurrentSpellName = nil
			LYQueueSpell(HnHiExpTrap,LYHnBindUnit)
			LYHnBindUnit = nil
		end
	end
	function HnExploseKick()
		if GCDCheck(HnHiExpTrap) and LYKickPause == 0 and LYHnHiExpTrapKick and LYMode ~= "PvE" and not tContains(listKicks,LYCurrentSpellName) then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
					local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(LYEnemies[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						castInterruptable = channelInterruptable
						modified = true
					end
					if castName and IsInDistance(LYEnemies[i],40) and not UnitCanCastOnMove(castName,LYEnemies[i]) and ValidKick(LYEnemies[i],castName) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						local castTimeLeft = (castTime - timeSinceStart) / 1000
						if (currentPercent > 30 or (modified and timeSinceStart > KickDelayFixed)) and currentPercent < 70 then
							if castNameP then
								local timeFromStartP = (GetTime() * 1000 - castStartP) + (NetStats3 + NetStats4) / 2
								local castTimeLeftP = (castTimeTotalP - timeFromStartP) / 1000
								if castTimeLeftP + 0.3 < castTimeLeft then
									return
								end
							end
							LYKickPause = GetTime()
							LYSpellStopCasting()
							LYQueueSpell(HnHiExpTrap,LYEnemies[i])
							LY_Print(HnHiExpTrap.." "..castName,"green",HnHiExpTrap)
							return true
						end
					end
				end
			end
		end
	end
	function HnCallPetFunc()
		if IsGCDReady() and LYSummonPet ~= 0 and not UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and LYStyle ~= "Utilities only" then
			CastSpellByName(HnCallPet[LYSummonPet])
			return true
		end
	end
	function HnMendBandCast()
		if GCDCheck(HnMendBand) and HaveBuff("player",HnDeter) and CalculateHP("player") < 70 then
			StopMoving()
			CastSpellByName(HnMendBand)
			LY_Print("DON'T MOVE for "..HnMendBand,"red",HnMendBand)
		end
	end
	function HnTrapCC()
		local function UnitIsCCable(pointer)
			if UnitIsVisible(pointer) and UnitIsPlayer(pointer) and not EnemyIsUnderAttack(pointer) and (not UnitIsVisible(LYEnemyTarget) or not UnitIsUnit(LYEnemyTarget,pointer)) and SpellAttackTypeCheck(pointer,"magic") and IsInDistance(pointer,40) and not HaveBuff(pointer,listICC) and CheckUnitDR(pointer,"control",LYHnTrapDR) and not UnitIsKicked(pointer) and (UnitIsCCed(pointer,LYGCDTime*2,true) or IsRooted(pointer,LYGCDTime*2) or IsInDistance(pointer,8)) and LYFacingCheck(pointer) then
				return true
			end
		end
		if GCDCheck(HnTrap) and LYMode ~= "PvE" then
			if LYHnTrapHealer and (EnemyHPBelow(LYHnTrapHealerHP) or (LYHnTrapTeamBurst and TeamIsBursting())) then
				for i=1,#LYEnemyHealers do
					if UnitIsCCable(LYEnemyHealers[i]) then
						LYQueueSpell(HnTrap,LYEnemyHealers[i])
						LY_Print(HnTrap.." @enemy healer","green")
						return true
					end
				end
			end
			if LYHnTrapDPS and not AnyEnemyDPSCCed() then
				for i=1,#LYTeamPlayers do
					local enemy = FriendIsUnderAttack(LYTeamPlayers[i],nil,LYHnTrapDPSHP,LYHnTrapDPSBurst)
					if UnitIsCCable(enemy) then
						LYQueueSpell(HnTrap,enemy)
						LY_Print(HnTrap.." @enemy DPS","green")
						return true
					end
				end
			end
			if LYHnTrapCont then
				for i=1,#LYEnemies do
					if UnitIsCCable(LYEnemies[i]) then
						LYQueueSpell(HnTrap,LYEnemies[i])
						LY_Print(HnTrap.." to chain CC","green")
						return true
					end
				end
			end
			if LYHnTrapFocus and UnitIsCCable("focus") then
				LYQueueSpell(HnTrap,"focus")
				LY_Print(HnTrap.." @focus","green")
				return true
			end
		end
	end
	function HnKillCommand(func)
		if GCDCheck(HnKillCom) and LYStyle ~= "Utilities only" and func and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and not UnitIsCCed("pet") and not IsRooted("pet") and (LYMySpec == 1 or LYUP < 80 or not inRange(HnRaptor,LYEnemyTarget)) and ValidEnemyUnit(LYEnemyTarget) and SpellAttackTypeCheck(LYEnemyTarget,"phys") then
			LYQueueSpell(HnKillCom,LYEnemyTarget)
			return true
		end
	end
	function HnScareBeastBurst()
		if GCDCheck(HnScareBeast) and LYStyle ~= "Utilities only" and not IsMoving() then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and HaveBuff(LYEnemies[i],DrBers,2) and CheckUnitDR(LYEnemies[i],"fear",2) then
					LYQueueSpell(HnScareBeast,LYEnemies[i])
					return true
				end
			end
		end
	end
	function HnTauntPvE()
		if GCDCheck(HnTaunt) and LYMode ~= "PvP" and UnitAffectingCombat("player") and not UnitCastingInfo("player") then
			for i=1,#LYTeamPlayers do
				if UnitIsVisible(LYTeamPlayers[i]) and UnitIsTank(LYTeamPlayers[i]) then
					CastSpellByName(HnTaunt,LYTeamPlayers[i])
					return true
				end
			end
		end
	end
	function HnKillShotCast()
		if CDLeft(HnKillShot) < LYMyPing*2 and LYStyle ~= "Utilities only" then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"phys") and inRange(HnKillShot,LYEnemies[i]) and (CalculateHP(LYEnemies[i]) < 20 or HaveBuff("player",{HnDeathblow,HnFlayMark,HnHuntPrey,HnCoordKill})) and LYFacingCheck(LYEnemies[i]) then
					LYQueueSpell(HnKillShot,LYEnemies[i])
					return true
				end
			end
		end
	end
	function MgBlockCancel()
		if HaveBuff("player",MgBlock) and LYMode ~= "PvE" and CalculateHP("player") > LYMgBlockCC then
			CancelBuffByName(MgBlock)
			return true
		end
	end
	function MgBlinkStun()
		if GCDCheck(MgBlink) and LYMode ~= "PvE" and not IsTalentInUse(212653) and LYMgBlinkTime ~= 0 and UnitIsStunned("player",LYMgBlinkTime) then
			CastSpellByName(MgBlink)
			LY_Print(MgBlink.." stun","green",MgBlink)
			if LYMySpec == 1 and LYMgDisplace and GCDCheck(MgDisplace) then
				LYQueueSpell(MgDisplace)
			end
			return true
		end
	end
	function MgBlastWaveKnockback()
		local function WillKnockIntoRing(mageX,mageY,mageZ,enemyX,enemyY,enemyZ,ringX,ringY,ringZ,ringRadius,knockbackDistance)
			knockbackDistance = knockbackDistance or 15
			-- Calculate the predicted position of the enemy after the knockback effect
			local direction = math.atan2(enemyY - mageY, enemyX - mageX)
			local predictedEnemyX = enemyX + knockbackDistance * math.cos(direction)
			local predictedEnemyY = enemyY + knockbackDistance * math.sin(direction)
			local predictedEnemyZ = enemyZ -- Assuming no change in Z position
			-- Calculate the distance between the predicted position of the enemy and the center of the Ring of Fire
			local deltaX = predictedEnemyX - ringX
			local deltaY = predictedEnemyY - ringY
			local deltaZ = predictedEnemyZ - ringZ
			local distanceToRingCenter = math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
			-- Compare the calculated distance with the radius of the Ring
			return distanceToRingCenter <= ringRadius
		end
		local function GetClosestTargetWithinKnockback(knockbackDistance,playerType)
			local closestDistance = 99
			local closestPlayer = nil
			if playerType == "all" then
				for i=1, #LYEnemies do
					local distance = GetDistanceToUnit(LYEnemies[i])
					if distance < closestDistance and distance < knockbackDistance then
						closestDistance = distance
						closestPlayer = LYEnemies[i]
					end
				end
			else
				for i=1, #LYEnemyHealers do
					local distance = GetDistanceToUnit(LYEnemyHealers[i])
					if distance < closestDistance and distance < knockbackDistance then
						closestDistance = distance
						closestPlayer = LYEnemyHealers[i]
					end
				end
			end
			return closestPlayer
		end
		if not GCDCheck(MgBlastWave) then
			return
		end
		if unlocker == "MB" then
			local ringObj = nil
			local radius = 0
			local isRingFire = false
			for i = 1, (GetNpcCount("player", 80) or 0) do
				local npc = GetNpcWithIndex(i)
				if npc.Name == "Ring of Frost" and UnitIsUnit("player",UnitCreator(npc.Object)) then
					ringObj = npc
					radius = 8
				end
			end
			for i = 1, (GetAreaTriggerCount("player") or 0) do
				local trigger = GetAreaTriggerWithIndex(i)
				if trigger.Id == 27384 and UnitIsUnit("player",trigger.Creator) then
					ringObj = trigger
					radius = 8
					isRingFire = true
				end
			end
			if ringObj then
				local ringX, ringY, ringZ = ObjectPosition(ringObj.Object)
				local myX, myY, myZ = ObjectPosition("player")
				local closestPlayer = nil
				if isRingFire then
					local closest = GetClosestTargetWithinKnockback(12,"all")
					if closest and not UnitIsStunned(closest) and not UnitIsCCed(closest) and not HaveDebuff(closest,MgRingFire) then
						closestPlayer = closest
					end
				else
					local closest = GetClosestTargetWithinKnockback(12,"healers")
					if closest and not UnitIsStunned(closest) and not UnitIsCCed(closest) and not HaveDebuff(closest,MgRingFrost) then
						closestPlayer = closest
					end
				end
				if closestPlayer then
					local enemyX, enemyY, enemyZ = ObjectPosition(closestPlayer)
					if WillKnockIntoRing(myX,myY,myZ,enemyX,enemyY,enemyZ,ringX,ringY,ringZ,radius,12) then
						LY_Print("Blast Wave into Ring!", "green")
						SpellStopCasting()
						LYQueueSpell(MgBlastWave)
						return true
					end
				end
			end
		end
	end
	function MgBlinkDB(unit)
		local blink_ticker_done
		local function CastDB(unit)
			C_Timer.NewTicker(0, function()
				if GetDistanceToUnit(unit) < 8.5 or (player_blink and GetTime()-player_blink < 0.2) then
					TurnOrActionStop()
					local dir = GetAnglesBetweenObjects("player",unit)
					FaceDirection(dir, true)
					if IsRotatedAt("player", dir, 0.9) then
						CastSpellByName(MgDB)
						return true
					end
				end
			end, 10)
		end
		local function GetBlinkPoint(unit)
			if not UnitIsVisible(unit) then
				return
			end
			local x,y,z = ObjectPosition(unit)
			if not x and y and z then
				return
			end
			local px,py,pz = ObjectPosition("player")
			local maxdist = 8
			local points = {}
			local step = (math.pi*2) / 12
			local direction
			for i=0,math.pi*2,step do
				local bx, by, bz = GroundZ (px+20*math.cos(i),py+20*math.sin(i),pz)
				if bx and by and bz and not TraceLine(px,py,pz+1.2,bx,by,bz+1.2,0x100111) then
					local zdif = pz - bz
					if zdif < 1.5 and zdif > -1.5 then
						if zdif < 0 then zdif = -zdif end
						if not TraceLine(bx,by,bz+1.7,x,y,z+1.7,0x100111) then
							local dist = GetDistancePointToPoint(x,y,z,bx,by,bz)
							if dist < maxdist then
								table.insert(points,{x=bx,y=by,z=bz,dist=dist,zdif=math.floor(zdif)})
							end
						end
					end
				end
			end
			table.sort(points,function(x,y) return x.zdif < y.zdif or (x.zdif == y.zdif and x.dist < y.dist) end)
			if #points > 0 then
				if #points == 1 then
					local a,b,c = points[1].x,points[1].y,points[1].z
					return a,b,c,points[1].dist
				else
					local index = math.ceil(#points/4)
					local a,b,c = points[index].x,points[index].y,points[index].z
					return a,b,c,points[index].dist
				end
			end
		end
		local time = GetTime()
		if not GCDCheck(MgDB) then return false end
		if not UnitIsVisible(unit) or UnitIsFriend("player",unit) then
			return
		end
		local distance = GetDistanceToUnit(unit)
		local px,py,pz = ObjectPosition("player")
		local castingSpell = UnitCastingInfo("player")
		if distance > 12.5 and LYMgDBBlink then
			local x,y,z = GetBlinkPoint(unit)
			if x and y and z and GCDCheck(MgBlink) and (not player_blink or time - player_blink > LYMyPing + .5) and not IsMoving("player") then
				if not castingSpell or (castingSpell ~= MgGrPyro and castingSpell ~= MgGlacSpike) then
					if castingSpell then
						SpellStopCasting()
					end
					blink_ticker_done = false
					C_Timer.NewTicker(0, function()
						if (not player_blink or time - player_blink > LYMyPing + .5) and GCDCheck(MgBlink) and GCDCheck(MgDB) and not blink_ticker_done then
							TurnOrActionStop()
							local dir = GetAnglesBetweenPositions(px,py,pz,x,y,z)
							FaceDirection(dir, true)
							local c = ObjectFacing("player")
							if IsRotatedAt("player", dir, 1) then
								LY_Print("Blink -> DB", "green", MgDB)
								CastSpellByName(MgBlink)
								player_blink = time
								blink_ticker_done = true
								C_Timer.After(LYMyPing*2, function()
									CastDB(unit)
								end)
								return true
							end
						end
					end, 10)
				end
			end
		else -- if no blink is needed, just cast DB
			x,y,z = PredictLocation(nil, nil, nil, unit,.08)
			if GetDistancePointToPoint(x,y,z,px,py,pz) < 9.25 and not TraceLine(x,y,z+1.6,px,py,pz+1.6,0x100011) then
				if not castingSpell or (castingSpell ~= MgGrPyro and castingSpell ~= MgGlacSpike) then
					if castingSpell then
						SpellStopCasting()
					end
					return CastDB(unit)
				end
			end
		end
		return false
	end
	function MgRingPlace(x,y,z)
		local px,py,pz = ObjectPosition("player")
		if not TraceLine(px,py,pz+2,x+5,y,z+2,0x100011) then
			return x+5,y,z
		elseif not TraceLine(px,py,pz+2,x,y+5,z+2,0x100011) then
			return x,y+5,z
		elseif not TraceLine(px,py,pz+2,x-5,y,z+2,0x100011) then
			return x-5,y,z
		elseif not TraceLine(px,py,pz+2,x,y-5,z+2,0x100011) then
			return x,y-5,z
		end
	end
	function MnKillShotCast()
		if CDLeft(MnKillShot) < LYMyPing and LYStyle ~= "Utilities only" then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"phys") and inRange(MnKillShot,LYEnemies[i]) and ((UnitIsPlayer(LYEnemies[i]) and (CalculateHP(LYEnemies[i]) < 10 or (CalculateHP(LYEnemies[i]) < 15 and (IsTalentInUse(394923) or IsTalentInUse(322113)))) and not HaveBuff(LYEnemies[i],{WrIntervene,PrWings})) or (LYMode ~= "PvP" and not UnitIsPlayer(LYEnemies[i]) and UnitHealth(LYEnemies[i]) < UnitHealth("player") and not UnitCastingInfo(LYEnemies[i]))) and LYFacingCheck(LYEnemies[i]) then
					if UnitCastingInfo("player") or UnitChannelInfo("player") then
						LYSpellStopCasting()
					end
					TargetUnit(LYEnemies[i])
					LYQueueSpell(MnKillShot,LYEnemies[i])
					return true
				end
			end
		end
	end
	function MnDifMagicBuffs()
		if LYMnDifMagBuff and GCDCheck(MnDifMagic) and HaveDebuff("player",{MnKarma,PrMindGame}) then
			LYQueueSpell(MnDifMagic)
			return true
		end
	end
	function MnCastStatue(spell,func)
		if GCDCheck(spell) and LYMnStatues and func and (UnitAffectingCombat("player") or #LYEnemiesAll > 0) then
			if #MnGetStatue == 3 then
				local X1,Y1,Z1 = MnGetStatue[1],MnGetStatue[2],MnGetStatue[3]
				local X2,Y2,Z2 = ObjectPosition("player")
				if X1 and math.sqrt(((X2 - X1) ^ 2) + ((Y2 - Y1) ^ 2) + ((Z2 - Z1) ^ 2)) > 40 then
					LYQueueSpell(spell,"player")
					return true
				end
			else
				LYQueueSpell(spell,"player")
				return true
			end
		end
	end
	function MnRingPeaceOut()
		if GCDCheck(MnRingPeace) and LYStyle ~= "Utilities only" then
			if LYMnRingPeaceOut then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and HaveBuff(LYEnemies[i],{PrPWB,ShEarthWall,DKAMZ,DHDarkness}) and not HaveBuff(LYEnemies[i],WrBS) then
						LYQueueSpell(MnRingPeace,LYEnemies[i])
						return true
					end
				end
			end
			for i=1,#LYTeamPlayers do
				local enemy = FriendIsUnderAttack(LYTeamPlayers[i],"MELEE",LYMnRingPeaceHP,LYMnRingPeaceBurst)
				if UnitIsVisible(enemy) and not HaveBuff(enemy,WrBS) then
					LYQueueSpell(MnRingPeace,LYTeamPlayers[i])
					LY_Print(MnRingPeace.." @teammate","green",MnRingPeace)
					return true
				end
			end
		end
	end
	function MnSoothingViv()
		if GCDCheck(MnSoothMist) then
			if GCDCheck(MnUplift) and LYStyle ~= "Utilities only" and not IsMoving() then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and (CalculateHP(LYTeamPlayers[i]) < LYMnUplift or ((LYHDPS or HaveBuff("player",MnVivaViv)) and CalculateHP(LYTeamPlayers[i]) < 90)) then
						if HaveBuff(LYTeamPlayers[i],MnSoothMist,0,"player") or HaveBuff("player",MnVivaViv) then
							LYQueueSpell(MnUplift,LYTeamPlayers[i])
							return true
						else
							LYSpellStopCasting()
							LYQueueSpell(MnSoothMist,LYTeamPlayers[i])
							return true
						end
					end
				end
			end
		elseif GCDCheck(MnUplift) and LYStyle ~= "Utilities only" and not IsMoving() then
			for i=1,#LYTeamPlayers do
				if ValidFriendUnit(LYTeamPlayers[i]) and (CalculateHP(LYTeamPlayers[i]) < LYMnUplift or ((LYHDPS or HaveBuff("player",MnVivaViv)) and CalculateHP(LYTeamPlayers[i]) < 90)) then
					LYQueueSpell(MnUplift,LYTeamPlayers[i])
					return true
				end
			end
		end
	end
	function PlAuras()
		if GCDCheck(PlAuraDev) and LYAutoBuff and not HaveBuff("player",listPlAuras,0,"player") and not tContains(listPlAuras,LYLastSpellName) then
			if #LYTeamHealersAll > 0 and not HaveBuff("player",PlAuraConc) and GCDCheck(PlAuraConc) then
				LYQueueSpell(PlAuraConc)
				return true
			elseif not HaveBuff("player",PlAuraDev) then
				LYQueueSpell(PlAuraDev)
				return true
			elseif not HaveBuff("player",PlAuraRetri) then
				LYQueueSpell(PlAuraRetri)
				return true
			end
		end
	end
	function PlBoPCast()
		if GCDCheck(PlBoP) and (not HaveBuff("player",PlDivFavor) or IsMoving()) then
			for i=1,#LYTeamPlayers do
				if UnitIsVisible(LYTeamPlayers[i]) and (not GCDCheck(PlBubble) or not UnitIsUnit(LYTeamPlayers[i],"player")) and not HaveDebuff(LYTeamPlayers[i],{PlForbear,OrbPower}) and not HaveBuff(LYTeamPlayers[i],{HordeFlag,AlyFlag,PlSac,PlGuardKings}) and (CheckRole(LYTeamPlayers[i]) == "HEALER" or LYPlBoPDPS) and (UnitIsUnit("player",LYTeamPlayers[i]) or select(2,UnitClass(LYTeamPlayers[i])) ~= "PALADIN") then
					if (HaveDebuff(LYTeamPlayers[i],listMStuns,LYPlBoPStunSec) and EnemyHPBelow(LYPlBoPStunEnemyHP)) or (LYPlBoPKarma and HaveDebuff(LYTeamPlayers[i],MnKarma,3.5)) or HaveDebuff(LYTeamPlayers[i],RgBlind,6) then
						LYSpellStopCasting()
						LYQueueSpell(PlBoP,LYTeamPlayers[i])
						LY_Print(PlBoP.." @DPS teammate for CC","green",PlBoP)
						return true
					end
					if FriendIsUnderAttack(LYTeamPlayers[i],"MELEE",LYPlBoPHP,LYPlBoPBurst) and (LYPlBoPTank or LYMode ~= "PvE" or not UnitIsTank(LYTeamPlayers[i])) then
						LYSpellStopCasting()
						LYQueueSpell(PlBoP,LYTeamPlayers[i])
						LY_Print(PlBoP.." @DPS teammate for HP","green",PlBoP)
						return true
					end
					if (IsTalentInUse(204018) or IsPvPTalentInUse(5573)) and FriendIsUnderAttack(LYTeamPlayers[i],"WIZARD",LYPlBoPHP,LYPlBoPBurst) and (LYPlBoPTank or LYMode ~= "PvE" or not UnitIsTank(LYTeamPlayers[i])) then
						LYSpellStopCasting()
						LYQueueSpell(PlBoP,LYTeamPlayers[i])
						LY_Print(PlBoP.." @DPS teammate for HP","green",PlBoP)
						return true
					end
				end
			end
		end
	end
	function PlLoHCast()
		if CDCheck(PlLoH) and not HaveDebuff("player",PrMindGame) then
			for i=1,#LYTeamPlayers do
				if UnitIsVisible(LYTeamPlayers[i]) and UnitIsPlayer(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < LYPlLoH and not HaveDebuff(LYTeamPlayers[i],PlForbear) then
					LYSpellStopCasting()
					LYQueueSpell(PlLoH,LYTeamPlayers[i])
					LY_Print(PlLoH,"green")
					return true
				end
			end
		end
	end
	function PlSacHP()
		if GCDCheck(PlSac) and LYStyle ~= "Utilities only" then
			for i=1,#LYTeamPlayers do
				if UnitIsVisible(LYTeamPlayers[i]) and not UnitIsUnit(LYTeamPlayers[i],"player") and (LYMode ~= "PvE" or UnitIsTank(LYTeamPlayers[i]) or LYMySpec == 2) and CalculateHP(LYTeamPlayers[i]) < LYPlSacHP and FriendIsUnderAttack(LYTeamPlayers[i]) then
					CastSpellByName(PlSac,LYTeamPlayers[i])
					return
				end
			end
		end
	end
	function PlSacCC()
		if CDCheck(PlSac) and LYMode ~= "PvE" and not HaveBuff("player",{PlSac,PlBubble}) and PartyHPBelow(LYPlSacCCHP) then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and tContains(listSWDCC,castName) and CheckUnitDRSpell("player",castName) and PlayerIsSpellTarget(LYEnemies[i]) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 80 then
							for k=1,#LYTeamPlayers do
								if (FriendIsUnderAttack(LYTeamPlayers[k]) or HaveDebuff(LYTeamPlayers[k],listDoTs)) and not UnitIsUnit("player",LYTeamPlayers[k]) then
									LYSpellStopCasting()
									CastSpellByName(PlSac,LYTeamPlayers[k])
									LY_Print(PlSac.." "..castName,"green",PlSac)
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	function PlCastSearingGlare()
		if GCDCheck(PlSearingGlare) and LYStyle ~= "Utilities only" and not BreakCCAroundUnit() and not IsMoving() then
			local enemies = {}
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and GetDistanceToUnit(LYEnemies[i]) < 25 and IsLookingAt(LYEnemies[i],nil,2) then
					tinsert(enemies,LYEnemies[i])
				end
			end
			local count = #enemies
			if count < LYPlSearGlareAOE then return end
			for i=1,count do
				if (IsBursting(enemies[i]) or PartyHPBelow(LYPlSearGlareHP) or count == 3) and CheckUnitDR(enemies[i],"fear",LYPlSearGlareDR) then
					LYQueueSpell(PlSearingGlare)
					return true
				end
			end
		end
	end
	function PlWrathHamCast()
		if CDLeft(PlWrathHam) < LYMyPing and LYStyle ~= "Utilities only" then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"phys") and inRange(PlWrathHam,LYEnemies[i]) and (CalculateHP(LYEnemies[i]) < 20 or HaveBuff("player",{PlWings,PlHolywar,PlFinVerdict,PlSent})) and LYFacingCheck(LYEnemies[i]) then
					LYQueueSpell(PlWrathHam,LYEnemies[i])
					return true
				end
			end
		end
	end
	function PrMindGames()
		if GCDCheck(PrMindGame) and not IsMoving() then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and inRange(PrSWP,LYEnemies[i]) and (IsBursting(LYEnemies[i]) or CalculateHP(LYEnemies[i]) < 40 or IsBursting() or LYMode == "PvE") and LYFacingCheck(LYEnemies[i]) then
					LYQueueSpell(PrMindGame,LYEnemies[i])
					return true
				end
			end
		end
	end
	function PrMDImunes()
		if GCDCheck(PrMD) and not IsMoving() and not SpellIsTargeting() and LYLastQueueSpell ~= PrMD then
			for i=1,#LYEnemiesAll do
				if IsInDistance(LYEnemiesAll[i],30) and HaveBuff(LYEnemiesAll[i],{MgBlock,PlBubble},3.5) and InLineOfSight(LYEnemiesAll[i]) then
					LYSpellStopCasting()
					LYQueueSpell(PrMD,LYEnemiesAll[i])
					return true
				end
			end
		end
	end
	function PrMDCC()
		if GCDCheck(PrMD) and not IsMoving() and not SpellIsTargeting() then
			if LYMySpec == 3 then
				for i=1,#LYTeamHealersAll do
					if (HaveDebuff(LYTeamHealersAll[i],listDHDispel,3.5) or HaveDebuff(LYTeamHealersAll[i],DrClone,3.5) or (HaveDebuff(LYTeamHealersAll[i],DrSolar) and IsRooted(LYTeamHealersAll[i],3.5))) and InLineOfSight(LYTeamHealersAll[i]) and (PartyHPBelow(LYPrMDHealerHP) or (LYPrMDHealerBurst and EnemyIsBursting())) then
						LYSpellStopCasting()
						LYQueueSpell(PrMD,LYTeamHealersAll[i])
						return true
					end
				end
			else
				for i=1,#LYTeamPlayersAll do
					if HaveDebuff(LYTeamPlayersAll[i],DrClone,3.5) and InLineOfSight(LYTeamPlayersAll[i]) and (EnemyHPBelow(LYPrMDTeamHP) or (LYPrMDTeamBurst and IsBursting(LYTeamPlayersAll[i]))) then
						LYSpellStopCasting()
						LYQueueSpell(PrMD,LYTeamPlayersAll[i])
						return true
					end
				end
			end
		end
	end
	function PrFeatherCast()
		if GCDCheck(PrFeather) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and LYZoneType == "arena" and UnitAffectingCombat("player") and LYLastSpellName ~= PrFeather then
			for i=1,#LYTeamPlayers do
				if CheckRole(LYTeamPlayers[i]) == "MELEE" and not HaveBuff(LYTeamPlayers[i],PrFeather) and not IsRooted(LYTeamPlayers[i]) and IsMoving(LYTeamPlayers[i]) then
					local tempTarget = UnitTarget(LYTeamPlayers[i])
					if UnitIsVisible(tempTarget) and GetUnitSpeed(LYTeamPlayers[i]) < GetUnitSpeed(tempTarget) then
						LYQueueSpell(PrFeather,LYTeamPlayers[i])
						return
					end
				end
			end
		end
	end
	function PrDivineStar()
		if GCDCheck(PrDivStar) and LYStyle ~= "Utilities only" then
			for i=1,#LYTeamPlayers do
				if IsInDistance(LYTeamPlayers[i],20) and CalculateHP(LYTeamPlayers[i]) < 85 and (UnitIsUnit("player",LYTeamPlayers[i]) or not UnitsCCedOnPathTo(LYTeamPlayers[i])) and IsLookingAt(LYTeamPlayers[i]) then
					LYQueueSpell(PrDivStar,LYTeamPlayers[i])
					return true
				end
			end
		end
	end
	function PrSWDCC()
		if CDCheck(PrSWD) and LYMode ~= "PvE" and LYLastSpellName ~= PrSWD and LYKickPause == 0 and not HaveBuff("player",PrHolyWard) then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and inRange(PrSWD,LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and tContains(listSWDCC,castName) and PlayerIsSpellTarget(LYEnemies[i]) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 40 then
							LYSpellStopCasting()
							PauseGCD = GetTime() + 0.1
							if currentPercent > 70 then
								CancelBuffByName(PrShield)
								CancelBuffByName(PrClarity)
								LYQueueSpell(PrSWD,LYEnemies[i])
								LYKickPause = GetTime()
								LY_Print(PrSWD.." "..castName,"green",PrSWD)
							end
							return true
						end
					end
				end
			end
		end
	end
	function PrGripCC()
		if CDCheck(PrGrip) and LYMode ~= "PvE" and LYKickPause == 0 and not HaveBuff("player",PrHolyWard) and LYPrGripClone then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and castName == DrClone then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 80 then
							local spellTarget = GetSpellDestUnit(LYEnemies[i])
							for j=1,#LYTeamPlayers do
								if UnitIsVisible(LYTeamPlayers[j]) and UnitIsPlayer(LYTeamPlayers[j]) and UnitIsUnit(spellTarget,LYTeamPlayers[j]) and not UnitIsUnit(LYTeamPlayers[j],"player") and CheckUnitDR(LYTeamPlayers[j],"control") and (not IsInDistance(LYEnemies[i],21) or not InLineOfSight(LYEnemies[i])) then
									LYSpellStopCasting()
									CastSpellByName(PrGrip,LYTeamPlayers[j])
									LYKickPause = GetTime()
									LY_Print(PrGrip.." "..castName,"green",PrSWD)
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	function PrMindSootheCast()
		if GCDCheck(PrMindSoothe) and LYStyle ~= "Utilities only" and CalculateMP("player") > LYPrMindSoothe then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and IsInDistance(LYEnemies[i],40) and IsWizzard(LYEnemies[i]) and not HaveDebuff(LYEnemies[i],PrMindSoothe) then
					LYQueueSpell(PrMindSoothe,LYEnemies[i])
					return true
				end
			end
		end
	end
	function PrInfusionCast()
		if GCDCheck(PrInfusion) and LYStyle ~= "Utilities only" then
			for i=1,#LYTeamPlayers do
				if ValidFriendUnit(LYTeamPlayers[i]) then
					if LYPrInfusionDPS and IsBursting(LYTeamPlayers[i]) and CheckRole(LYTeamPlayers[i]) ~= "HEALER" and (not LYPrInfusionFocus or UnitIsUnit("focus",LYTeamPlayers[i])) then
						CastSpellByName(PrInfusion,LYTeamPlayers[i])
						return true
					end
					if FriendIsUnderAttack(LYTeamPlayers[i],nil,LYPrInfusionHP,LYPrInfusionBurst) then
						if IsTalentInUse(373466) then
							CastSpellByName(PrInfusion,ReturnTeamMate(true))
							return true
						else
							CastSpellByName(PrInfusion,"player")
							return true
						end
					end
				end
			end
		end
	end
	function PrThoughtstealCast()
		if GCDCheck(PrThoughtsteal) then
			if not HaveBuff("player",PrThoughtsteal) then
				local stealUnit = EnemyClassExists("MAGE") or EnemyClassExists("WARLOCK")
				if stealUnit then
					if ValidEnemyUnit(stealUnit) and inRange(PrThoughtsteal,stealUnit) and not HaveDebuff(stealUnit,PrThoughtsteal) then
						LYQueueSpell(PrThoughtsteal,stealUnit)
						return true
					end
				elseif #LYEnemyHealers > 0 then
					for i=1,#LYEnemyHealers do
						if ValidEnemyUnit(LYEnemyHealers[i]) and inRange(PrThoughtsteal,LYEnemyHealers[i]) and not HaveDebuff(LYEnemyHealers[i],PrThoughtsteal) then
							local class = select(2,UnitClass(LYEnemyHealers[i]))
							if class ~= "PALADIN" and class ~= "SHAMAN" then
								LYQueueSpell(PrThoughtsteal,LYEnemyHealers[i])
								return true
							end
						end
					end
				end
			elseif not IsMoving() then
				local stolenSpell = GetSpellInfo(PrThoughtsteal)
				if (stolenSpell == MgPoly or stolenSpell == WlFear) and not AnyEnemyHasDebuff(stolenSpell) then
					for i=1,#LYEnemyHealers do
						if ValidEnemyUnit(LYEnemyHealers[i]) and inRange(PrSWP,LYEnemyHealers[i]) and SpellAttackTypeCheck(LYEnemyHealers[i],"magic") and not EnemyIsUnderAttack(LYEnemyHealers[i]) and not UnitIsCCed(LYEnemyHealers[i]) and ((stolenSpell == MgPoly and CheckUnitDR(LYEnemyHealers[i],"control",1)) or (stolenSpell == WlFear and CheckUnitDR(LYEnemyHealers[i],"fear",1))) then
							LYQueueSpell(PrThoughtsteal,LYEnemyHealers[i])
							LY_Print(stolenSpell.." @Enemy Healer","green",stolenSpell)
							return true
						end
					end
					for i=1,#LYEnemies do
						if ValidEnemyUnit(LYEnemies[i]) and inRange(PrSWP,LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and not EnemyIsUnderAttack(LYEnemies[i]) and not UnitIsCCed(LYEnemies[i]) and ((stolenSpell == MgPoly and CheckUnitDR(LYEnemies[i],"control",1)) or (stolenSpell == WlFear and CheckUnitDR(LYEnemies[i],"fear",1))) then
							LYQueueSpell(PrThoughtsteal,LYEnemies[i])
							LY_Print(stolenSpell.." @Enemy DPS","green",stolenSpell)
							return true
						end
					end
				end
			end
		end
	end
	function PrShackleAbom()
		if GCDCheck(PrShackle) and not IsMoving() and LYZoneType == "arena" and EnemyClassExists("DEATHKNIGHT") then
			for i=1,GetObjectCount() do
				local pointer = GetObjectWithIndex(i)
				if UnitIsVisible(pointer) and not UnitIsPlayer(pointer) and UnitCanAttack("player",pointer) and ObjectId(pointer) == 149555 and not HaveDebuff(pointer,PrShackle) and inRange(PrShackle,pointer) and CheckUnitDR(pointer,"control") and InLineOfSight(pointer) then
					LYQueueSpell(PrShackle,pointer)
					return true
				end
			end
		end
	end
	function PrShackleDK()
		if GCDCheck(PrShackle) and not IsMoving() and LYZoneType == "arena" then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and inRange(PrShackle,LYEnemies[i]) and HaveBuff(LYEnemies[i],DKLichborn) and not HaveDebuff(LYEnemies[i],PrShackle) and CheckUnitDR(pointer,"control") then
					LYQueueSpell(PrShackle,LYEnemies[i])
					return true
				end
			end
		end
	end
	function PrRenewCast(buff)
		if GCDCheck(PrRenew) and LYStyle ~= "Utilities only" and TeamMembersAroundUnitBuffed(PrRenew) < 5 then
			for i=1,#LYTeamPlayers do
				if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < 95 and CanHoTSafe(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],buff,0,"player") then
					LYQueueSpell(PrRenew,LYTeamPlayers[i])
					return true
				end
			end
		end
	end
	function PrShift()
		if CDCheck(PrVoidshift) and LYMode ~= "PvE" and not HaveBuff("player",{PrDispers,PrRayHope}) then
			if CalculateHP("player") < LYPrVoidshift then
				table.sort(LYTeamPlayers,function(x,y) return CalculateHP(x) > CalculateHP(y) end)
				if LYPrVoidshiftHeal and LYPlayerRole ~= "HEALER" then
					for i=1,#LYTeamHealers do
						if UnitIsVisible(LYTeamHealers[i]) then
							LYSpellStopCasting()
							LYQueueSpell(PrVoidshift,LYTeamHealers[i])
							return true
						end
					end
				end
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and not UnitIsUnit(LYTeamPlayers[i],"player") and CheckRole(LYTeamPlayers[i]) ~= "HEALER" then
						LYSpellStopCasting()
						LYQueueSpell(PrVoidshift,LYTeamPlayers[i])
						return true
					end
				end
			end
			for i=1,#LYTeamPlayers do
				if UnitIsVisible(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < LYPrVoidshift and not HaveBuff(LYTeamPlayers[i],PrRayHope) and not UnitIsUnit(LYTeamPlayers[i],"player") and FriendIsUnderAttack(LYTeamPlayers[i]) then
					LYSpellStopCasting()
					LYQueueSpell(PrVoidshift,LYTeamPlayers[i])
					return true
				end
			end
		end
	end
	function PrFadeIncFear()
		if CDCheck(PrFade) and LYMode ~= "PvE" and (IsPvPTalentInUse(5570) or IsPvPTalentInUse(5569)) then
			local enemyPrst = EnemyClassExists("PRIEST")
			if UnitIsVisible(enemyPrst) and IsMoving(enemyPrst) and CheckUnitDR("player","fear") and SpellIsReady(enemyPrst,PrFear,30) and IsInDistance(enemyPrst,10) and HaveBuff(enemyPrst,PrPhase) and ObjectFacing(enemyPrst,"player") then
				LYSpellStopCasting()
				LYQueueSpell(PrFade)
				LY_Print(PrFade.." @inc Priest Fear","green",PrFade)
				return true
			end
		end
	end
	function RgKickCast()
		if LYKickPause == 0 then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
					local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(LYEnemies[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						castInterruptable = channelInterruptable
						modified = true
					end
					if castName and ValidKick(LYEnemies[i],castName) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						local castTimeLeft = (castTime - timeSinceStart) / 1000
						if (currentPercent > KickTime or (modified and timeSinceStart > KickDelayFixed)) and castTime > LYKickMin and currentPercent < 95 then
							if not castInterruptable and GCDCheck(RgKick) then
								if inRange(RgKick,LYEnemies[i]) then
									Face(LYEnemies[i])
									CastSpellByName(RgKick,LYEnemies[i])
									LYKickPause = GetTime()
									LY_Print(RgKick.." "..castName,"green",RgKick)
									return true
								elseif GCDCheck(RgShStep) and inRange(RgShStep,LYEnemies[i]) and LYRgShStepKick then
									LYSpellStopCasting()
									CastSpellByName(RgShStep,LYEnemies[i])
									return true
								elseif GCDCheck(RgGrapHook) and IsInDistance(LYEnemies[i],40) and LYRgShStepKick then
									LYSpellStopCasting()
									LYQueueSpell(RgGrapHook,LYEnemies[i])
									return true
								end
							elseif LYMode == "PvE" then
								if LYRgKidneyKick and GCDCheck(RgKidney) and inRange(RgKick,LYEnemies[i]) and CheckUnitDR(LYEnemies[i],"stun",2) then
									LYQueueSpell(RgKidney,LYEnemies[i],"face")
									LY_Print(RgKidney.." "..castName,"green",RgKidney)
									return true
								elseif LYRgCheapKick and GCDCheck(RgCheap) and inRange(RgKick,LYEnemies[i]) and CheckUnitDR(LYEnemies[i],"stun",2) then
									LYQueueSpell(RgCheap,LYEnemies[i],"face")
									LY_Print(RgCheap.." "..castName,"green",RgCheap)
									return true
								elseif LYRgBlindKick and GCDCheck(RgBlind) and inRange(RgBlind,LYEnemies[i]) then
									LYQueueSpell(RgBlind,LYEnemies[i])
									LY_Print(RgBlind.." "..castName,"green",RgBlind)
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	function RgEvisRupSlice()
		if GCDCheck(RgRupture) and LYStyle ~= "Utilities only" and not DoNotUsePower and not UnitIsVisible(LYNextStun) and UnitAffectingCombat("player") and (CDLeft(RgSecTech) > 2 or not IsBursting()) then
			local spell, dotUnit, finUnit, crimson = RgEvis, nil, nil, 0
			if LYMySpec == 1 then
				spell = RgEnven
			end
			if GCDCheck(RgDeathAbove) then
				spell = RgDeathAbove
			end
			if LYCP >= LYCPMax - 1 then
				local slicedice = UnitIsVisible(LYEnemyTarget) and inRange(RgKick,LYEnemyTarget) and not HaveBuff("player",{RgSliceDice,RgEchoingReprimand},10)
				if CDLeft(RgCrimTemp) < 1 then
					for i=1,#LYEnemies do
						if ValidEnemyUnit(LYEnemies[i]) and IsInDistance(LYEnemies[i],9) and not HaveDebuff(LYEnemies[i],RgCrimTemp,4,"player") then
							crimson = crimson + 1
						end
					end
				end
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and inRange(RgKick,LYEnemies[i]) then
						if CalculateHP(LYEnemies[i]) < LYRgEvisHP or (IsBursting() and HaveDebuff(LYEnemies[i],RgRupture,5,"player")) then
							if GCDCheck(spell) then
								LYQueueSpell(spell,LYEnemies[i])
							end
							return true
						elseif crimson > 1 then
							if GCDCheck(RgCrimTemp) then
								LYQueueSpell(RgCrimTemp)
							end
							return true
						else
							if slicedice and GCDCheck(RgSliceDice) then
								LYQueueSpell(RgSliceDice)
								return true
							end
							if not HaveDebuff(LYEnemies[i],RgRupture,0,"player") then
								LYQueueSpell(RgRupture,LYEnemies[i])
								return true
							elseif not dotUnit and not HaveDebuff(LYEnemies[i],RgRupture,9,"player") then
								dotUnit = LYEnemies[i]
							end
						end
						if not finUnit then
							finUnit = LYEnemies[i]
						end
					end
				end
			end
			if dotUnit then
				LYQueueSpell(RgRupture,dotUnit)
				return true
			elseif finUnit and GCDCheck(spell) then
				LYQueueSpell(spell,dotUnit)
				return true
			end
		end
	end
	function RgGetTrueMaxCP()
		local maxcp = 5
		if IsTalentInUse(394321) or IsTalentInUse(394320) then
			maxcp = maxcp + 1
		end
		if IsTalentInUse(193531) then
			maxcp = maxcp + 1
		end
		if not HaveBuff("player",RgEchoingReprimand) or UnitIsVisible(LYNextStun) then
			return maxcp
		end
		local echocp = BuffCount("player",RgEchoingReprimand)
		if LYCP <= echocp then
			return echocp
		end
		return maxcp
	end
	function RgSapNonCombat()
		if GCDCheck(RgSap) and LYMode == "PvP" and EnemiesAroundUnitDoTed(nil,nil,RgSap) < 1 and EnemyHPBelow(95) then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and not UnitAffectingCombat(LYEnemies[i]) and not UnitIsCCed(LYEnemies[i],LYGCDTime) and not HaveDebuff(LYEnemies[i],listDoTs) then
					if inRange(RgSap,LYEnemies[i]) then
						LYQueueSpell(RgSap,LYEnemies[i])
						return true
					elseif GCDCheck(RgShStep) and LYZoneType == "arena" and inRange(RgShStep,LYEnemies[i]) then
						CastSpellByName(RgShStep,LYEnemies[i])
					elseif GCDCheck(RgGrapHook) and LYZoneType == "arena" and IsInDistance(LYEnemies[i]) then
						LYQueueSpell(RgGrapHook,LYEnemies[i])
						return true
					end
				end
			end
		end
	end
	function RgCoShCC()
		if GCDCheck(RgCloak) and LYMode ~= "PvE" and ((LYRgCloakCCBurst and HaveBuff("player",{RgAR,RgSD})) or EnemyHPBelow(LYRgCloakCCHP)) and not HaveBuff("player",{ShGroundEffect,WrBanner}) and LYKickPause == 0 then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and tContains(listRefl,castName) and CheckUnitDRSpell("player",castName) and PlayerIsSpellTarget(LYEnemies[i]) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 90 then
							CastSpellByName(RgCloak)
							LYKickPause = GetTime()
							LY_Print(RgCloak.." "..castName,"green",RgCloak)
							return true
						end
					end
				end
			end
		end
	end
	function RgSapBlind()
		if not GCDCheck(RgBlind) and LYMode ~= "PvE" then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and not UnitAffectingCombat(LYEnemies[i]) and (inRange(RgSap,LYEnemies[i]) or (GCDCheck(RgShStep) and inRange(RgShStep,LYEnemies[i])) or (GCDCheck(RgGrapHook) and IsInDistance(LYEnemies[i]))) and DebuffTimeLeft(LYEnemies[i],RgBlind) < LYGCDTime*2 and LYUP > 19 and not HaveDebuff(LYEnemies[i],RgSap) then
					if not HaveBuff("player",listRgStealth) then
						if GCDCheck(RgSD) then
							LYQueueSpell(RgSD)
							return true
						elseif GCDCheck(RgVanish) then
							CastSpellByName(RgVanish)
							return true
						end
					else
						if inRange(RgSap,LYEnemies[i]) then
							LYQueueSpell(RgSap,LYEnemies[i])
							return true
						elseif GCDCheck(RgShStep) and inRange(RgShStep,LYEnemies[i]) then
							LYQueueSpell(RgGrapHook,LYEnemies[i])
							return true
						elseif GCDCheck(RgGrapHook) then
							LYQueueSpell(RgGrapHook,LYEnemies[i])
							return true
						end
					end
				end
			end
		end
	end
	function RgKidneyCast()
		if GCDCheck(RgKidney) and LYStyle ~= "Utilities only" and not DoNotUsePower and LYCP >= LYCPMax - 1 and LYMode ~= "PvE" then
			if LYRgKidneyHeal then
				for i=1,#LYEnemyHealers do
					if ValidEnemyUnit(LYEnemyHealers[i]) and inRange(RgKick,LYEnemyHealers[i]) and CheckUnitDR(LYEnemyHealers[i],"stun") and HaveBuff(LYEnemyHealers[i],listDef) and not UnitIsKicked(LYEnemyHealers[i]) and not UnitIsCCed(LYEnemyHealers[i],LYGCDTime) and not HaveBuff(LYEnemyHealers[i],listIStun) and LYFacingCheck(LYEnemyHealers[i]) then
						LYQueueSpell(RgKidney,LYEnemyHealers[i])
						return true
					end
				end
			end
			if LYRgKidneyAll and UnitIsVisible(LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and inRange(RgKick,LYEnemyTarget) and not HaveBuff(LYEnemyTarget,listDef) and CheckUnitDR(LYEnemyTarget,"stun") and not UnitIsKicked(LYEnemyTarget) and not UnitIsCCed(LYEnemyTarget,LYGCDTime) and not HaveBuff(LYEnemyTarget,listIStun) and LYFacingCheck(LYEnemyTarget) then
				LYQueueSpell(RgKidney,LYEnemyTarget)
				return true
			end
		end
	end
	function RgQueueStun()
		if LYCP and UnitIsVisible(LYNextStun) and GCDCheck(RgKidney) and SpellAttackTypeCheck(LYNextStun,"phys") and LYCP >= 5 and not UnitIsCCed(LYNextStun) and not UnitIsKicked(LYNextStun) and not HaveBuff(LYNextStun,listIStun) and UnitIsPlayer(LYNextStun) then
			LYCurrentSpellName = nil
			if UnitIsVisible(LYNextStun) and GCDCheck(RgShStep) and not inRange(RgKidney,LYNextStun) and inRange(RgShStep,LYNextStun) then
				CastSpellByName(RgShStep,LYNextStun)
			end
			if inRange(RgKidney,LYNextStun) then
				LYQueueSpell(RgKidney,LYNextStun)
				LY_Print(RgKidney,"green")
				PauseGCD = GetTime() + 0.1
				return true
			end
		end
	end
	function RgCheapshotPlayers()
		if GCDCheck(RgCheap) and LYRgCheapStun and LYCP < LYCPMax and not UnitIsVisible(LYNextStun) and UnitIsVisible(LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and inRange(RgKick,LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and ((LYRgCheapTarget and UnitIsUnit(LYEnemyTarget,LYEnemies[i]) and CheckUnitDR(LYEnemyTarget,"stun",LYRgCheapDRT)) or (not UnitIsUnit(LYEnemyTarget,LYEnemies[i]) and CheckUnitDR(LYEnemies[i],"stun",LYRgCheapDR))) and not UnitIsCCed(LYEnemies[i],LYGCDTime) and not HaveBuff(LYEnemies[i],listIStun) and not UnitIsKicked(LYEnemies[i]) and LYFacingCheck(LYEnemies[i]) then
					LYQueueSpell(RgCheap,LYEnemies[i])
					return true
				end
			end
		end
	end
	function RgPoisons()
		if LYAutoBuff and not UnitAffectingCombat("player") and not IsMoving() then
			if GCDCheck(RgCripPoison) and not HaveBuff("player",RgCripPoison) then
				LYQueueSpell(RgCripPoison)
				return true
			end
			if GCDCheck(RgWoundPoison) and not HaveBuff("player",{RgDeadlyPoison,RgWoundPoison}) then
				LYQueueSpell(RgWoundPoison)
				return true
			end
			if GCDCheck(RgNumbPoison) and not HaveBuff("player", RgNumbPoison) and IsTalentInUse(381801) then
				LYQueueSpell(RgNumbPoison)
				return true
			end
		end
	end
	function RgGougeKick()
		if GCDCheck(RgGouge) and LYKickPause == 0 and LYRgGougeKick then
			for i=1,#LYEnemies do
				if inRange(RgGouge,LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"phys") then
					local castName, _, _, castStartTime, castEndTime = UnitCastingInfo(LYEnemies[i])
					local channelName, _, _, channelStartTime, channelEndTime = UnitChannelInfo(LYEnemies[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						modified = true
					end
					if castName and ValidKick(LYEnemies[i],castName) and not ObjectIsBehind("player",LYEnemies[i]) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if (currentPercent > KickTime or (modified and timeSinceStart > KickDelayFixed)) and castTime > LYKickMin and currentPercent < 95 and LYFacingCheck(LYEnemies[i]) then
							LYSpellStopCasting()
							LYQueueSpell(RgGouge,LYEnemies[i])
							LYKickPause = GetTime()
							LY_Print(RgGouge.." "..castName,"green",RgGouge)
							return true
						end
					end
				end
			end
		end
	end
	function RgGougeCC()
		local function UnitIsCCable(pointer,Cont)
			if UnitIsVisible(pointer) and UnitIsPlayer(pointer) and not ObjectIsBehind("player",pointer) and (not UnitIsVisible(LYEnemyTarget) or not UnitIsUnit(LYEnemyTarget,pointer)) and SpellAttackTypeCheck(pointer,"phys") and inRange(RgGouge,pointer) and not HaveBuff(pointer,{WrBS,PrHolyWard,PlSac}) and CheckUnitDR(pointer,"control",LYRgGougeDR) and not UnitIsKicked(pointer) and not UnitIsCCed(pointer,LYGCDTime) and (not Cont or UnitIsCCed(pointer)) and LYFacingCheck(pointer) then
				return true
			end
		end
		if GCDCheck(RgGouge) and LYMode ~= "PvE" then
			if LYRgGougeHealer and (EnemyHPBelow(LYRgGougeHealerHP) or (LYRgGougeTeamBurst and TeamIsBursting())) then
				for i=1,#LYEnemyHealers do
					if UnitIsCCable(LYEnemyHealers[i]) and not EnemyIsUnderAttack(LYEnemyHealers[i]) then
						LYQueueSpell(RgGouge,LYEnemyHealers[i])
						LY_Print(RgGouge.." @enemy healer","green",RgGouge)
						return true
					end
				end
			end
			if LYRgGougeDPS and not AnyEnemyDPSCCed() then
				for i=1,#LYTeamPlayers do
					local enemy = FriendIsUnderAttack(LYTeamPlayers[i],nil,LYRgGougeDPSHP,LYRgGougeDPSBurst)
					if UnitIsVisible(enemy) and UnitIsCCable(enemy) and not EnemyIsUnderAttack(enemy) then
						LYQueueSpell(RgGouge,enemy)
						LY_Print(RgGouge.." @enemy DPS","green",RgGouge)
						return true
					end
				end
			end
			if LYRgGougeCont then
				for i=1,#LYEnemies do
					if UnitIsCCable(LYEnemies[i],LYRgGougeCont) and not EnemyIsUnderAttack(LYEnemies[i]) then
						LYQueueSpell(RgGouge,LYEnemies[i])
						LY_Print(RgGouge.." to chain CC","green",RgGouge)
						return true
					end
				end
			end
			if LYRgGougeFocus and UnitIsVisible("focus") and UnitIsCCable("focus") and not EnemyIsUnderAttack("focus") then
				LYQueueSpell(RgGouge,"focus")
				LY_Print(RgGouge.." @focus","green",RgGouge)
				return true
			end
		end
	end
	function ShTotemExists(name,enemy)
		if not enemy then
			for i=1,4 do
				local totem = select(2,GetTotemInfo(i))
				if totem and totem == name then
					return true
				end
			end
		elseif EnemyClassExists("SHAMAN") then
			for i=1,GetObjectCount() do
				local pointer = GetObjectWithIndex(i)
				if UnitIsVisible(pointer) and UnitCanAttack("player",pointer) and UnitName(pointer) == name then
					return pointer
				end
			end
		end
	end
	function ShEarthShld()
		local function AnyFriendHasES()
			if LYZoneType == "arena" then
				for i=1,#LYTeamPlayersAll do
					if HaveBuff(LYTeamPlayersAll[i],ShEarthShield,1,"player") and (not IsTalentInUse(383010) or not UnitIsUnit("player",LYTeamPlayersAll[i])) then
						return LYTeamPlayersAll[i]
					end
				end
			else
				for i=1,#LYTeamPlayers do
					if HaveBuff(LYTeamPlayers[i],ShEarthShield,1,"player") and (not IsTalentInUse(383010) or not UnitIsUnit("player",LYTeamPlayers[i])) then
						return LYTeamPlayers[i]
					end
				end
			end
		end
		if GCDCheck(ShEarthShield) and LYStyle ~= "Utilities only" and (LYMySpec == 3 or ((LYMode ~= "PvE" or not UnitAffectingCombat("player")) and C_Spell.IsSpellUsable(ShHealSurge))) and not IsBursting() then
			if IsTalentInUse(383010) and not HaveBuff("player",ShEarthShield) then
				LYQueueSpell(ShEarthShield,"player")
				return true
			end
			if LYShEarthShieldPlayer then
				if InEnemySight() and not HaveBuff("player",ShEarthShield) then
					LYQueueSpell(ShEarthShield,"player")
					return true
				end
			else
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and not HaveBuff(LYTeamPlayers[i],ShEarthShield) and (UnitIsTank(LYTeamPlayers[i]) or (LYMode ~= "PvE" and FriendIsUnderAttack(LYTeamPlayers[i]))) then
						local LBUnit = AnyFriendHasES()
						if not UnitIsVisible(LBUnit) or (CalculateHP(LYTeamPlayers[i]) + 10 < CalculateHP(LBUnit)) then
							LYQueueSpell(ShEarthShield,LYTeamPlayers[i])
							return true
						end
					end
				end
			end
		end
	end
	function ShTremorTotem()
		if CDCheck(ShTremor) and LYMode ~= "PvE" then
			if LYMySpec == 3 and LYShTremorInc then
				local enemyPrst = EnemyClassExists("PRIEST")
				if UnitIsVisible(enemyPrst) and not UnitIsCCed(enemyPrst) and IsMoving(enemyPrst) and CheckUnitDR("player","fear") and SpellIsReady(enemyPrst,PrFear,30) and IsInDistance(enemyPrst,10) and ObjectFacing(enemyPrst,"player") then
					LYSpellStopCasting()
					LYQueueSpell(ShTremor)
					LYKickPause = GetTime()
					LY_Print(ShTremor.." @inc Priest Fear","green",ShTremor)
					return true
				end
			end
			if LYKickPause == 0  then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
						local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
						if castName and (castName == WlFear or castName == PrMindBomb) and PlayerIsSpellTarget(LYEnemies[i]) and CheckUnitDR("player","fear") then
							local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
							local castTime = (castEndTime - castStartTime)
							local currentPercent = timeSinceStart / castTime * 100
							if currentPercent > 40 then
								LYSpellStopCasting()
								PauseGCD = GetTime() + 0.1
								if currentPercent > 70 then
									LYSpellStopCasting()
									LYQueueSpell(ShTremor)
									LYKickPause = GetTime()
									LY_Print(ShTremor.." "..castName,"green",ShTremor)
									return true
								end
								return true
							end
						end
					end
				end
			end
			if PartyHPBelow(LYShTremorTeamHP) and LYZoneType == "arena" then
				for i=1,#LYTeamHealersAll do
					if UnitIsVisible(LYTeamHealersAll[i]) and HaveDebuff(LYTeamHealersAll[i],listTremor,LYShTremorTime) and IsInDistance(LYTeamHealersAll[i],30) then
						LYSpellStopCasting()
						LYQueueSpell(ShTremor)
						LY_Print(ShTremor.." @team healer","green",ShTremor)
						return true
					end
				end
			end
			if LYShTremorDPS or LYZoneType ~= "arena" then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and HaveDebuff(LYTeamPlayers[i],listTremor,LYShTremorTime) and IsInDistance(LYTeamPlayers[i],30) and (CheckRole(LYTeamPlayers[i]) == "HEALER" or (LYShTremorDPS and ((LYShTremorBurst and IsBursting(LYTeamPlayers[i])) or EnemyHPBelow(LYShTremorEnemyHP)))) then
						LYSpellStopCasting()
						LYQueueSpell(ShTremor)
						LY_Print(ShTremor.." @DPS teammate","green",ShTremor)
						return true
					end
				end
			end
		end
	end
	function ShFreedomTotem()
		if GCDCheck(ShFreedom) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" then
			for i=1,#LYTeamHealers do
				if HaveDebuff(LYTeamHealers[i],listSlows) and CalculateHP(LYTeamHealers[i]) < LYShFreedomHealHP and FriendIsUnderAttack(LYTeamHealers[i],"MELEE") then
					LYQueueSpell(ShFreedom,LYTeamHealers[i])
					LY_Print(ShFreedom.." @team healer","green",ShFreedom)
					return true
				end
			end
			if LYShFreedomDPS then
				for i=1,#LYTeamPlayers do
					if UnitIsVisible(LYTeamPlayers[i]) and CheckRole(LYTeamPlayers[i]) == "MELEE" and select(2,UnitClass(LYTeamPlayers[i])) ~= "DRUID" then
						local target = UnitTarget(LYTeamPlayers[i])
						if UnitIsVisible(target) and UnitCanAttack(LYTeamPlayers[i],target) and CalculateHP(target) < LYShFreedomTarHP and HaveDebuff(LYTeamPlayers[i],listSlows) and not IsInDistance(LYTeamPlayers[i],7,target) then
							LYQueueSpell(ShFreedom,LYTeamPlayers[i])
							LY_Print(ShFreedom.." @DPS teammate","green",ShFreedom)
							return true
						end
					end
				end
			elseif CalculateHP(LYEnemyTarget) < LYShFreedomTarHP and HaveDebuff("player",listSlows) and not IsInDistance(LYEnemyTarget,7) then
				LYQueueSpell(ShFreedom,"player")
				LY_Print(ShFreedom.." @player","green",ShFreedom)
				return true
			end
		end
	end
	function ShGroundingCC()
		if CDCheck(ShGround) and LYMode ~= "PvE" then
			if LYShGroundTrap and LYZoneType == "arena" and LYMySpec ~= 3 then
				local hunter = EnemyClassExists("HUNTER")
				if UnitIsVisible(hunter) and SpellIsReady(hunter,HnTrap,27) then
					for i=1,#LYTeamHealersAll do
						if CheckUnitDR(LYTeamHealersAll[i],"control") and UnitIsCCed(LYTeamHealersAll[i],3,true) and not IsMoving(LYTeamHealersAll[i]) and InLineOfSight(hunter,LYTeamHealersAll[i]) and IsInDistance(hunter,40,LYTeamHealersAll[i]) and IsInDistance(LYTeamHealersAll[i],30) then
							LYSpellStopCasting()
							LYQueueSpell(ShGround)
							LY_Print(ShGround.." inc "..HnTrap,"green",ShGround)
							return true
						end
					end
				end
			end
			if LYKickPause == 0 then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
						local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
						if castName and tContains(listRefl,castName) then
							local spellTar = GetSpellDestUnit(LYEnemies[i])
							if UnitIsVisible(spellTar) and (castName ~= PlRep or select(2,UnitClass(spellTar)) ~= "SHAMAN") and (CheckRole(spellTar) == "HEALER" or (LYShGroundDPS and ((LYShGroundBurst and IsBursting(spellTar)) or EnemyHPBelow(LYShGroundHP)))) and CheckUnitDRSpell(spellTar,castName,1) and IsInDistance(spellTar,30) and (not GCDCheck(ShKick) or not inRange(ShKick,LYEnemies[i])) then
								local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
								local castTime = (castEndTime - castStartTime)
								local currentPercent = timeSinceStart / castTime * 100
								if currentPercent > 30 then
									PauseGCD = GetTime() + 0.1
									if currentPercent > 70 and currentPercent < 90 then
										LYSpellStopCasting()
										LYQueueSpell(ShGround)
										LYKickPause = GetTime()
										LY_Print(ShGround.." "..castName,"green",ShGround)
									end
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	function ShLavaCast(func)
		if GCDCheck(ShLava) and func and LYStyle ~= "Utilities only" then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and inRange(ShLightning,LYEnemies[i]) and HaveDebuff(LYEnemies[i],ShFireShock,0.5,"player") and LYFacingCheck(LYEnemies[i]) then
					LYQueueSpell(ShLava,LYEnemies[i])
					return true
				end
			end
		end
	end
	function ShGroundHarm()
		if GCDCheck(ShGround) and LYKickPause == 0 and #LYReflectAlways > 0 then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
					local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(LYEnemies[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						castInterruptable = channelInterruptable
						modified = true
					end
					if castName and tContains(LYReflectAlways,castName) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if (currentPercent > 40 and currentPercent < 90 and IsInDistance("player",30,GetSpellDestUnit(LYEnemies[i]))) or (modified and IsInDistance(LYEnemies[i],30)) then
							LYQueueSpell(ShGround)
							LYKickPause = GetTime()
							LY_Print(ShGround.." "..castName,"green",ShGround)
							return true
						end
					end
				end
			end
		end
	end
	function ShWolfRep()
		if CDCheck(ShWolf) and LYKickPause == 0 and not HaveBuff("player",ShWolf) then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
					if castName then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 75 and castName == PlRep and PlayerIsSpellTarget(LYEnemies[i]) then
							LYSpellStopCasting()
							LYQueueSpell(ShWolf)
							PauseGCD = GetTime() + 0.5
							LYKickPause = GetTime()
							LY_Print(ShWolf.." "..castName,"green",ShWolf)
							return true
						end
					end
				end
			end
		end
	end
	function WlDemonArmor()
		if GCDCheck(WlDeadArmor) and LYStyle ~= "Utilities only" and not HaveBuff("player",WlDeadArmor) then
			CastSpellByName(WlDeadArmor)
			return true
		end
	end
	function WlBurnRush()
		if GCDCheck(WlBurning) and LYWlBRush ~= 0 then
			if not HaveBuff("player",WlBurning) and not UnitAffectingCombat("player") and IsMoving() and CalculateHP("player") > LYWlBRush then
				LYQueueSpell(WlBurning)
			else
				CancelBuffByName(WlBurning)
			end
		end
	end
	function WlCurses(func)
		local function EnemyIsAround(pointer)
			for i=1,#LYTeamPlayers do
				if IsInDistance(pointer,8,LYTeamPlayers[i]) then
					return true
				end
			end
		end
		if GCDCheck(WlCurTongue) and func and LYStyle ~= "Utilities only" and LYMode ~= "PvE" then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and inRange(WlCurTongue,LYEnemies[i]) and not HaveDebuff(LYEnemies[i],listWlCurses,3) and (IsWizzard(LYEnemies[i]) or CheckRole(LYEnemies[i]) == "HEALER") then
					if GCDCheck(WlAmpCurse) and ((IsWizzard(LYEnemies[i]) and IsBursting(LYEnemies[i])) or (CheckRole(LYEnemies[i]) == "HEALER" and EnemyHPBelow(50))) then
						CastSpellByName(WlAmpCurse)
					end
					LYQueueSpell(WlCurTongue,LYEnemies[i])
					return true
				end
			end
		end
		if GCDCheck(WlCurWeak) and func and LYStyle ~= "Utilities only" then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and (UnitIsPlayer(LYEnemies[i]) or UnitIsBoss(LYEnemies[i])) and inRange(WlCurWeak,LYEnemies[i]) and not HaveDebuff(LYEnemies[i],listWlCurses,3) and ((IsPvPTalentInUse(5386) and not HaveAllDebuffs(LYEnemies[i],{WlCorrupt,WlAgony},4,"player")) or (CheckRole(LYEnemies[i]) == "MELEE" and EnemyIsAround(LYEnemies[i])) or LYMode == "PvE") then
					if GCDCheck(WlAmpCurse) and (IsBursting(LYEnemies[i]) or LYMode == "PvE") then
						CastSpellByName(WlAmpCurse)
					end
					LYQueueSpell(WlCurWeak,LYEnemies[i])
					return true
				end
			end
		end
	end
	function WlNethWard()
		if CDCheck(WlNetherWard) and LYMode ~= "PvE" then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = (castEndTime - castStartTime)
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 80 and ((tContains(LYReflectAlways,castName) and (CalculateHP("player") < LYWlWardPlayerHP or (LYWlWardBurts and IsBursting(LYEnemies[i])))) or (tContains(listRefl,castName) and EnemyHPBelow(LYWlWardEnemyHP) and CheckUnitDRSpell("player",castName))) and PlayerIsSpellTarget(LYEnemies[i]) then
							LYSpellStopCasting()
							CastSpellByName(WlNetherWard)
							LY_Print(WlNetherWard.." "..castName,"green",WlNetherWard)
							return true
						end
					end
				end
			end
		end
	end
	function WlSummonPet()
		if (not UnitIsVisible("pet") or UnitIsDeadOrGhost("pet")) and not HaveBuff("player",WlSacBuff) and GCDCheck(WlSummonKickPet) and not IsMoving() and not IsBursting() and (not UnitAffectingCombat("player") or not InEnemySight() or not EnemyHPBelow(30)) and not tContains(listWlSummon,LYLastSpellName) then
			if GCDCheck(WlFelDomin) and (UnitAffectingCombat("player") or LYMode ~= "PvP") then
				LYQueueSpell(WlFelDomin)
				return true
			end
			if LYWlPetType == 1 and LYLastSpellName ~= WlSummonKickPet then
				LYQueueSpell(WlSummonKickPet)
				return true
			elseif LYWlPetType == 2 and LYLastSpellName ~= WlSummonTankPet then
				LYQueueSpell(WlSummonTankPet)
				return true
			elseif LYWlPetType == 3 and LYLastSpellName ~= WlSummonDispelPet then
				LYQueueSpell(WlSummonDispelPet)
				return true
			elseif LYWlPetType == 4 and LYLastSpellName ~= WlSummonSucPet then
				LYQueueSpell(WlSummonSucPet)
				return true
			elseif LYWlPetType == 5 and LYMySpec == 2 and LYLastSpellName ~= WlSummonDemoPet then
				LYQueueSpell(WlSummonDemoPet)
				return true
			end
		end
	end
	function WlSetPetType()
		if IsSpellKnown(54049,true) then
			WlPetType = 1
		elseif IsSpellKnown(112042,true) then
			WlPetType = 2
		elseif IsSpellKnown(3110,true) then
			WlPetType = 3
		elseif IsSpellKnown(6360,true) then
			WlPetType = 4
		elseif IsSpellKnown(134477,true) then
			WlPetType = 5
		end
	end
	function WlDispel()
		local function Dispel(pointer)
			if GCDCheck(WlTrinketPet) and HaveDebuff("pet",listStuns) then
				CastSpellByName(WlTrinketPet)
			end
			if not UnitIsCCed("pet") and IsInDistance("pet",30,pointer) and InLineOfSight(pointer,"pet") then
				if GCDCheck(WlDispelPet) then
					CastSpellByName(WlDispelPet,pointer)
					LY_Print(WlDispelPet,"green")
					return true
				elseif GCDCheck(WlSingeMagic) then
					CastSpellByName(WlSingeMagic,pointer)
					LY_Print(WlSingeMagic,"green")
					return true
				end
			end
		end
		if UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and LYMode == "PvP" then
			if WlPetType == 3 then
				if GCDCheck(WlDispelPet) or GCDCheck(WlSingeMagic) then
					for i=1,#LYTeamHealersAll do
						if HaveDebuff(LYTeamHealersAll[i],listSacCC,LYWlDispelTime) and PartyHPBelow(LYWlDispelTeamHP) then
							return Dispel(LYTeamHealersAll[i])
						end
					end
					if not LYWlDispelHealer then
						for i=1,#LYTeamPlayersAll do
							if HaveDebuff(LYTeamPlayersAll[i],listSacCC,LYWlDispelTime) and (EnemyHPBelow(LYWlDispelEnemyHP) or (LYWlDispelBurst and IsBursting(LYTeamPlayersAll[i]))) then
								return Dispel(LYTeamPlayersAll[i])
							end
						end
					end
				end
			elseif WlPetType == 1 and GCDCheck(WlDevMagic) then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and NumberOfPurgeBuffs(LYEnemies[i]) > 0 and IsInDistance("pet",30,LYEnemies[i]) and InLineOfSight(LYEnemies[i],"pet") then
						CastSpellByName(WlDevMagic,LYEnemies[i])
						return true
					end
				end
			end
		end
	end
	function WlKick()
		if GCDCheck(WlPetAbility) and LYKickPause == 0 and WlPetType == 1 and not HaveBuff("player",WlSac) and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") then
			local list = LYEnemies
			if LYZoneType == "arena" then
				list = LYEnemiesAll
			end
			for i=1,#list do
				if UnitIsVisible(list[i]) then
					local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(list[i])
					local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(list[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						castInterruptable = channelInterruptable
						modified = true
					end
					if castName and not castInterruptable and IsInDistance(list[i],30,"pet") and InLineOfSight("pet",list[i]) and ValidKick(list[i],castName) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if (currentPercent > KickTime-10 or (modified and timeSinceStart > KickDelayFixed)) and castTime > LYKickMin and currentPercent < 95 then
							LYKickPause = GetTime()
							CastSpellByName(WlPetAbility,list[i])
							LY_Print(WlPetAbility.." "..castName,"green",WlPetAbility)
							return true
						end
					end
				end
			end
		end
	end
	function WlBanishTyrant()
		if GCDCheck(WlBanish) and not IsMoving() and LYZoneType == "arena" and EnemyClassExists("WARLOCK") then
			for i=1,GetObjectCount() do
				local pointer = GetObjectWithIndex(i)
				if UnitIsVisible(pointer) and UnitCanAttack("player",pointer) and ObjectId(pointer) == 135002 and not HaveDebuff(pointer,WlBanish) and inRange(WlBanish,pointer) and CheckUnitDR(pointer,"control") and InLineOfSight(pointer) then
					LYQueueSpell(WlBanish,pointer)
					return true
				end
			end
		end
	end
	function WrInterveneCast()
		if GCDCheck(WrIntervene) and LYMode ~= "PvE" then
			local lowhp = EnemyHPBelow(30)
			local healer = TeamHealerCCed(4)
			for i=1,#LYTeamPlayers do
				if inRange(WrIntervene,LYTeamPlayers[i]) and not UnitIsUnit(LYTeamPlayers[i],"player") and not HaveBuff(LYTeamPlayers[i],WrIntervene) and (not lowhp or IsInDistance(LYTeamPlayers[i],8)) and (FriendIsUnderAttack(LYTeamPlayers[i],"MELEE",LYWrInterHP,LYWrInterBurst) or (LYWrInterHeal and healer and not UnitIsUnit(healer,LYTeamPlayers[i]) and not FriendIsUnderAttack(healer))) and (LYStackDef or not HaveBuff(LYTeamPlayers[i],listDef)) then
					CastSpellByName(WrIntervene,LYTeamPlayers[i])
					LY_Print(WrIntervene.." @teammate","green",WrIntervene)
					return true
				end
			end
		end
	end
	function WrShatThrowCast()
		if GCDCheck(WrShatThrow) and LYMode == "PvP" then
			for i=1,#LYEnemiesAll do
				if inRange(WrShatThrow,LYEnemiesAll[i]) and HaveBuff(LYEnemiesAll[i],{MgBlock,PlBubble,PlBoP}) and InLineOfSight(LYEnemiesAll[i]) then
					if IsMoving() then
						if LYAutoCCMoveStop then
							LY_Print("Force stopped moving to cast "..WrShatThrow,"red",WrShatThrow)
							StopMoving(true)
							return
						elseif LYAutoCCMoveWarn then
							LY_Print("Please stop moving to let it cast "..WrShatThrow,"red",WrShatThrow)
							return
						else
							return
						end
					else
						LYQueueSpell(WrShatThrow,LYEnemiesAll[i],"face")
						return true
					end
				end
			end
		end
	end
	function WrDemolition()
		local spell
		if GCDCheck(WrShatThrow) and not IsMoving() and IsPvPTalentInUse(5372) then
			spell = WrShatThrow
		elseif GCDCheck(WrWreckThrow) then
			spell = WrWreckThrow
		end
		if spell and LYStyle ~= "Utilities only" and not DoNotUsePower then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and inRange(spell,LYEnemies[i]) and HaveBuff(LYEnemies[i],{MnCocoon,WlSacShield},2) and LYFacingCheck(LYEnemies[i]) then
					LYQueueSpell(spell,LYEnemies[i])
					return true
				end
			end
		end
	end
	function WrSWKick()
		if LYWrSWKick and GCDCheck(WrSW) and LYKickPause == 0 then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and IsLookingAt(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					local channelName,_,_,channelStartTime,channelEndTime = UnitChannelInfo(LYEnemies[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						modified = true
					end
					if castName and (IsInDistance(LYEnemies[i],9) or (IsTalentInUse(275339) and IsInDistance(LYEnemies[i],15))) and not tContains(LYListNotKick,castName) and ValidKick(LYEnemies[i],castName) and CheckUnitDR(LYEnemies[i],"stun",2) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if (currentPercent > KickTime or (modified and timeSinceStart > KickDelayFixed)) and castTime > LYKickMin and currentPercent < 95 then
							LYSpellStopCasting()
							LYQueueSpell(WrSW,LYEnemies[i],"face")
							LY_Print(WrSW.." "..castName,"green",WrSW)
							LYKickPause = GetTime()
							return true
						end
					end
				end
			end
		end
	end
	function WrKickPlayers()
		if GCDCheck(WrKick) and LYKickPause == 0 then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and not HaveBuff(LYEnemies[i],WrIntervene) then
					local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
					local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(LYEnemies[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						castInterruptable = channelInterruptable
						modified = true
					end
					if castName and not castInterruptable and ValidKick(LYEnemies[i],castName) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						local castTimeLeft = (castTime - timeSinceStart) / 1000
						if currentPercent < 95 then
							if inRange(WrKick,LYEnemies[i]) then
								if (currentPercent > KickTime or (modified and timeSinceStart > KickDelayFixed)) and castTime > LYKickMin then
									LYSpellStopCasting()
									Face(LYEnemies[i])
									CastSpellByName(WrKick,LYEnemies[i])
									LYKickPause = GetTime()
									LY_Print(WrKick.." "..castName,"green",WrKick)
									return true
								end
							elseif GetUnitSpeed("player") < 20 and LYMode == "PvP" and not HaveDebuff("player",DrVortex) and ((GCDCheck(WrLeap) and GCDCheck(WrCharge)) or SpellChargesCheck(WrCharge) or SpellChargesCheck(WrLeap) or (LYMySpec == 2 and IsPvPTalentInUse(166)) or (UnitIsVisible(LYEnemyTarget) and UnitIsUnit(LYEnemyTarget,LYEnemies[i]))) then
								local travelTime = GetDistanceBetweenObjects("player",LYEnemies[i]) / 50
								local dTime = castTimeLeft - travelTime
								if travelTime < .75 and dTime < .6 and dTime > 0.05 then
									if LYWrChargeKick and GCDCheck(WrCharge) and inRange(WrCharge,LYEnemies[i]) then
										CastSpellByName(WrCharge,LYEnemies[i],"face")
										LY_Print(WrCharge.." to kick","green",WrCharge)
										if UnitIsVisible(LYEnemyTarget) and not UnitIsUnit("target",LYEnemies[i]) then
											if GCDCheck(WrLeap) or (LYMySpec == 2 and IsPvPTalentInUse(166)) then
												C_Timer.After(LYGCDTime,function() LYCurrentSpellName = nil LYQueueSpell(WrLeap,LYEnemyTarget) end)
											elseif GCDCheck(WrCharge) then
												C_Timer.After(LYGCDTime,function() LYCurrentSpellName = nil LYQueueSpell(WrCharge,LYEnemyTarget,"face") end)
											end
										end
										return true
									elseif LYWrLeapKick and GCDCheck(WrLeap) and IsInDistance(LYEnemies[i],40) and (not LYWrLeapHealer or CheckRole(LYEnemies[i]) == "HEALER") then
										LYSpellStopCasting()
										LYQueueSpell(WrLeap,LYEnemies[i])
										LY_Print(WrLeap.." to kick","green",WrLeap)
										if UnitIsVisible(LYEnemyTarget) and not UnitIsUnit(LYEnemyTarget,LYEnemies[i]) then
											if SpellChargesCheck(WrLeap) or (LYMySpec == 2 and IsPvPTalentInUse(166)) then
												C_Timer.After(LYGCDTime,function() LYCurrentSpellName = nil LYQueueSpell(WrLeap,LYEnemyTarget) end)
											elseif GCDCheck(WrCharge) then
												C_Timer.After(LYGCDTime,function() LYCurrentSpellName = nil LYQueueSpell(WrCharge,LYEnemyTarget,"face") end)
											end
										end
										return true
									end
								end
							end
						end
					end
				end
			end
		end
	end
	function WrReflectIncCC()
		if GCDCheck(WrReflect) and LYMode ~= "PvE" and LYKickPause == 0 then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName then
						local spellDest = GetSpellDestUnit(LYEnemies[i])
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if tContains(listRefl,castName) and CheckUnitDRSpell(spellDest,castName) and currentPercent > 50 and UnitIsUnit("player",spellDest) and currentPercent > 90 and ((LYWrReflCCBurst and HaveBuff("player",{WrReck,WrAvatar})) or EnemyHPBelow(LYWrReflCCHP)) and not HaveBuff("player",{ShGroundEffect,WrBanner}) and (castName ~= WlFear or not GCDCheck(WrBers)) then
							CastSpellByName(WrReflect)
							LYKickPause = GetTime()
							LY_Print(WrReflect.." "..castName,"green",WrReflect)
							return true
						end
					end
				end
			end
		end
	end
	function WrInterveneIncCC()
		if GCDCheck(WrIntervene) and LYWrInterCC and LYMode ~= "PvE" and LYKickPause == 0 and #LYTeamPlayers > 1 then
			for i=1,#LYEnemies do
				if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
					if castName and tContains(listRefl,castName) and PlayerIsSpellTarget(LYEnemies[i]) and CheckUnitDRSpell("player",castName) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = castEndTime - castStartTime
						local currentPercent = timeSinceStart / castTime * 100
						if currentPercent > 85 then
							for j=1,#LYTeamPlayers do
								if inRange(WrIntervene,LYTeamPlayers[j]) and not UnitIsUnit(LYTeamPlayers[j],"player") and FriendIsUnderAttack(LYTeamPlayers[j]) then
									CastSpellByName(WrIntervene,LYTeamPlayers[j])
									LYKickPause = GetTime()
									LY_Print(WrIntervene.." to break "..castName,"green",WrIntervene)
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	function WrCancelBSKick()
		if LYWrBSKick and CDLeft(WrKick) == 0 and LYMode ~= "PvE" and HaveBuff("player",WrBS) then
			for i=1,#LYEnemies do
				if inRange(WrKick,LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
					local castName,_,_,castStartTime,castEndTime,_,_,castInterruptable = UnitCastingInfo(LYEnemies[i])
					local channelName,_,_,channelStartTime,channelEndTime,_,channelInterruptable = UnitChannelInfo(LYEnemies[i])
					local modified = nil
					if channelName then
						castName = channelName
						castStartTime = channelStartTime
						castEndTime = channelEndTime
						castInterruptable = channelInterruptable
						modified = true
					end
					if castName and not castInterruptable and ValidKick(LYEnemies[i],castName) then
						local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
						local castTime = (castEndTime - castStartTime)
						local currentPercent = timeSinceStart / castTime * 100
						if (not modified or timeSinceStart > KickDelayFixed) and (tContains(listInstInt,castName) or currentPercent > 80) and currentPercent < 95 then
							CancelBuffByName(WrBS)
							LY_Print("Cancel "..WrBS.." to kick "..castName,"green")
							return true
						end
					end
				end
			end
		end
	end
	function WrStance()
		if GCDCheck(WrDStance) and LYStyle ~= "Utilities only" then
			local stance = nil
			if (LYMode ~= "PvE" and FriendIsUnderAttack("player",nil,LYWrDStanceHP,LYWrDStanceBurst)) or (not UnitAffectingCombat("player") and LYMode == "PvP") or (LYWrDStance2 ~= 0 and FriendIsUnderAttack("player",nil,nil,nil,LYWrDStance2)) then
				stance = true
			end
			if LYWrDStanceMyBurst and IsBursting() then
				stance = nil
			end
			if GetShapeshiftForm() ~= 1 and (LYStayForm or stance) then
				CastShapeshiftForm(1)
			elseif GetShapeshiftForm() ~= 2 and not stance and not LYStayForm then
				CastShapeshiftForm(2)
			end
		end
	end
	function WrExecuteCast()
		if CDLeft(WrExecute) < LYMyPing and LYStyle ~= "Utilities only" and (HaveBuff("player",WrSudDeath) or LYUP > 20 or IsTalentInUse(316402)) then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and (CalculateHP(LYEnemies[i]) < 20 or HaveBuff("player",WrSudDeath) or (IsTalentInUse(281001) and CalculateHP(LYEnemies[i]) < 35)) then
					if inRange(WrExecute,LYEnemies[i]) or inRange(WrKick,LYEnemies[i]) then
						if ((not IsPvPTalentInUse(3522) and not IsPvPTalentInUse(25)) or inRange(WrKick,LYEnemies[i]) or (LYWrDeathSent and UnitIsVisible(LYEnemyTarget) and UnitIsUnit(LYEnemies[i],LYEnemyTarget)) or CalculateHP("player") > LYWrDeathSentHP) and LYFacingCheck(LYEnemies[i]) then
							LYQueueSpell(WrExecute,LYEnemies[i])
							return true
						end
					elseif not HaveBuff("player",WrSudDeath) and UnitIsPlayer(LYEnemies[i]) and LYLastSpellName ~= WrLeap and LYLastSpellName ~= WrCharge and GetUnitSpeed("player") < 10 then
						if GCDCheck(WrCharge) and CalculateHP("player") > LYWrChargeExecute and inRange(WrCharge,LYEnemies[i]) and LYFacingCheck(LYEnemies[i]) then
							CastSpellByName(WrCharge,LYEnemies[i])
							return true
						elseif GCDCheck(WrLeap) and CalculateHP("player") > LYWrLeapExecute and IsInDistance(LYEnemies[i],40) then
							LYQueueSpell(WrLeap,LYEnemies[i])
							return true
						elseif GCDCheck(WrIntervene) and CalculateHP("player") > LYWrInterEx then
							for j=1,#LYTeamPlayers do
								if UnitIsVisible(LYTeamPlayers[j]) and not UnitIsUnit(LYTeamPlayers[j],"player") and inRange(WrIntervene,LYTeamPlayers[j]) and GetDistanceBetweenObjects(LYTeamPlayers[j],LYEnemies[i]) < GetDistanceBetweenObjects("player",LYEnemies[i]) and InLineOfSight(LYTeamPlayers[j],LYEnemies[i]) then
									CastSpellByName(WrIntervene,LYTeamPlayers[j])
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	function WrBersAntiFear()
		if GCDCheck(WrBers) and LYMode ~= "PvE" and not IsRooted() and not UnitIsStunned("player") then
			for i=1,40 do
				local tBuff = C_UnitAuras.GetDebuffDataByIndex("player",i)
				if tBuff and tBuff.name then
					for j=1,#listBers do
						if tBuff.name == listBers[j] and (LYReaction == 0 or tBuff.expirationTime - GetTime() < tBuff.duration - LYReaction/1000) then
							CastSpellByName(WrBers)
							LY_Print(WrBers.." "..tBuff.name,"green",WrBers)
							return true
						end
					end
				else
					return
				end
			end
		end
	end
	function WrPiercHowlCast()
		if GCDCheck(WrPiercHowl) and LYMode == "PvP" and IsMoving() then
			if LYSlowTarget and ValidEnemyUnit(LYEnemyTarget) and UnitIsPlayer(LYEnemyTarget) and not inRange(WrKick,LYEnemyTarget) and IsInDistance(LYEnemyTarget,11) and HaveDebuff("player",listSlows) and not HaveDebuff(LYEnemyTarget,listSlows,LYGCDTime) and not HaveBuff(LYEnemyTarget,listISlows) and not UnitIsCCed(LYEnemyTarget) and GetUnitSpeed(LYEnemyTarget) > GetUnitSpeed("player") then
				LYQueueSpell(WrPiercHowl)
				return true
			end
			local count = 0
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and not HaveDebuff(LYEnemies[i],listSlows,LYGCDTime) and not HaveBuff(LYEnemies[i],listISlows) and IsInDistance(LYEnemies[i],11) then
					count = count + 1
				end
			end
			if count >= LYWrPiercHowl then
				LYQueueSpell(WrPiercHowl)
				return true
			end
		end
	end
	function WrThrowStealth()
		if GCDCheck(WrThrow) and LYZoneType == "arena" then
			for i=1,#LYEnemies do
				if ValidEnemyUnit(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and inRange(WrThrow,LYEnemies[i]) then
					local class = select(2,UnitClass(LYEnemies[i]))
					if class == "ROGUE" or class == "DRUID" then
						LYQueueSpell(WrThrow,LYEnemies[i])
						return true
					end
				end
			end
		end
	end
	function WrStopBS()
		if HaveBuff("player",WrBS) then
			return true
		end
	end
	--Rotation starter
	function MainRotation()
		local function SetVars()
			castNameP,_,_,castStartP,castEndP,_,_,castInterruptableP = UnitCastingInfo("player")
			local channelName = UnitChannelInfo("player")
			if castNameP or (channelName and not tContains(listStopChannel,channelName) and (channelName ~= PrMFlay or IsPvPTalentInUse(113)) and (channelName ~= WlDrainLife or HaveBuff("player",WlInevDemise))) then
				PauseGCD = GetTime() + 0.1
				LYCurrentSpellName = nil
			end
			if not IsGCDReady() or PauseGCD + LYMyPing > GetTime() or LYCurrentSpellName then
				PauseRotation = true
			elseif not LYCurrentSpellName then
				PauseRotation = nil
			end
			if KickTime == 0 then
				if LYKickStart <= LYKickEnd then
					KickTime = math.random(LYKickStart,LYKickEnd)
				else
					KickTime = math.random(LYKickEnd,LYKickStart)
				end
			end
			if LYKickPause ~= 0 and LYKickPause + 0.5 < GetTime() then
				LYKickPause = 0
			end
			LYUP = UnitPower("player")
			LYUPMax = UnitPowerMax("player")
			LYZoneType = select(2,IsInInstance()) or "none"
			if LYZoneType == "party" or LYZoneType == "raid" or LYZoneType == "scenario" then
				LYMode = "PvE"
			elseif LYZoneType == "arena" or LYZoneType == "pvp" then
				LYMode = "PvP"
			else
				LYMode = "Outworld"
			end
			if IsGCDReady() and not LYOldGCD then
				LastTimeLYUpdated = 0
				LYOldGCD = true
				LegacyFrame_SpellWarning:Hide()
				if DoNotUsePower then
					if LYMyClass == 4 or (LYMyClass == 11 and LYMySpec == 2) or LYMyClass == 10 then
						if LYCP == LYCPMax then
							DoNotUsePower = nil
							if DoNotUsePowerBurst then
								LYBurstMacro = GetTime() + 30
							else
								LY_Print("Stop saving power/combo","green")
							end
						end
					elseif LYUP and LYUP >= DoNotUsePower then
						DoNotUsePower = nil
						if DoNotUsePowerBurst then
							LYBurstMacro = GetTime() + 30
						else
							LY_Print("Stop saving power/combo","green")
						end
					end
				end
			end
			if LYBurstMacro and not IsInBossFight() and LYBurstMacro < GetTime() and LYPlayerRole ~= "HEALER" then
				LYBurstMacro = nil
				LY_Print("Burst is DEACTIVATED","red")
			end
			if C_Spell.GetSpellCooldown(61304).startTime == 0 and LYCurrentSpellName then
				if LYSpellTime == 0 then
					LYSpellTime = GetTime()
				elseif GetTime() > LYSpellTime + LYMyPing + 0.1 + LYFrameDelay / 1000 then
					LYCurrentSpellName = nil
					LYSpellTime = 0
				end
			end
			if GetTime() - RecordTime > 1 then
				if LYZoneType == "arena" then
					RecordMovement()
				end
				if LYMode ~= "PvP" then
					RecordHP()
				end
				RecordTime = GetTime()
			end
		end
		local function CastSpells()
			if castNameP then
				local SpellDestP = GetSpellDestUnit("player")
				local timeFromStartP = (GetTime() * 1000 - castStartP) + (NetStats3 + NetStats4) / 2
				castTimeTotalP = (castEndP - castStartP)
				currentCastPercentP = timeFromStartP / castTimeTotalP * 100
				local castTimeLeftP = (castTimeTotalP - timeFromStartP) / 1000
				if UnitIsVisible(SpellDestP) then
					if (castNameP == ShHex and HaveBuff(SpellDestP,listForms)) or (tContains(listRefl,castNameP) and HaveBuff(SpellDestP,listIMagic,castTimeLeftP + 0.1)) or (HaveDebuff(SpellDestP,LYListBreakableCC,castTimeLeftP + 0.1) and UnitCanAttack("player",SpellDestP) and GetSpellInfo(LYLastQueueSpell) ~= castNameP and C_Spell.IsSpellHarmful(castNameP) and castTimeTotalP < 2500) then
						LYSpellStopCasting()
						PauseGCD = GetTime() + 0.1
						LY_Print("Stop cast protection","red")
					end
					if LYFacing and LYCurrentSpellFace and not IsMoving() and C_Spell.IsSpellHarmful(castNameP) and not ObjectIsFacing("player",SpellDestP,0.5) then
						Face(SpellDestP)
					end
					if HaveDebuff(SpellDestP,castNameP,15,"player") then
						LYSpellStopCasting()
					end
				end
			end
		end
		local function PauseKeys()
			if LYPause then
				for i=1,#KeyBinds do
					if KeyBinds[i] and GetKeyStatus(KeyBinds[i]) then
						PauseGCD = GetTime() + 1
						break
					end
				end
			end
		end
		local function AvoidIncomingMissiles()
			if unlocker == "MB" or unlocker == "daemon" then
				local count = GetMissileCount()
				if count > 0 then
					for i=1,count do
						local spellId,spellVisualId,x,y,z,sourceObject,sourceX,sourceY,sourceZ,targetObject,targetX,targetY,targetZ = GetMissileWithIndex(count)
						local SpellName = GetSpellInfo(spellId)
						if not spellId or not SpellName or not targetObject then
							return
						end
						if tContains(listStuns,SpellName) and UnitIsUnit("player",targetObject) then
							return AvoidStun(SpellName)
						end
					end
				end
			end
		end
		local function Meld()
			if GCDCheck(ShadowMeld) and LYMode ~= "PvE" and ((LYMeldCCBurst and HaveBuff("player",listBurst)) or EnemyHPBelow(LYMeldCCHP)) and not HaveBuff("player",listIMagic) and LYKickPause == 0 then
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
						local castName,_,_,castStartTime,castEndTime = UnitCastingInfo(LYEnemies[i])
						if castName and tContains(listRefl,castName) and (LYMyClass ~= 11 or castName ~= MgPoly) and PlayerIsSpellTarget(LYEnemies[i]) then
							local timeSinceStart = (GetTime() * 1000 - castStartTime) + (NetStats3 + NetStats4) / 2
							local castTime = (castEndTime - castStartTime)
							local currentPercent = timeSinceStart / castTime * 100
							if currentPercent > 90 then
								StopMoving(true)
								LYSpellStopCasting()
								CastSpellByName(ShadowMeld)
								LYCurrentSpellName = nil
								LYQueueSpell(ShadowMeld)
								LYKickPause = GetTime()
								LY_Print(ShadowMeld .. " on " .. castName,"red",ShadowMeld)
							end
						end
					end
				end
			end
		end
		local function Trinkets()
			local function Click()
				if SpellIsTargeting() then
					ClickPosition(ObjectPosition("player"))
				end
			end
			if UnitCastingInfo("player") or UnitChannelInfo("player") then
				return
			end
			if UnitAffectingCombat("player") and LYAutoTrink1 ~= 8 and ((LYAutoTrink1 == 4 and CalculateHP("player") < 25) or (LYAutoTrink1 == 5 and PartyHPBelow(35)) or
			(ValidEnemyUnit(LYEnemyTarget) and (UnitIsPlayer(LYEnemyTarget) or LYMode ~= "PvP") and IsInDistance(LYEnemyTarget,40) and ((LYAutoTrink1 == 1 and IsBursting()) or LYAutoTrink1 == 2 or (LYAutoTrink1 == 6 and CalculateHP(LYEnemyTarget) < 25) or (LYAutoTrink1 == 3 and UnitIsBoss(LYEnemyTarget))))) and
			IsUsableItem(GetInventoryItemID("player",13)) and GetInventoryItemCooldown("player",13) == 0 then
				local id = GetInventoryItemID("player",13)
				UseItemByName(id)
				Click()
			end
			if UnitAffectingCombat("player") and LYAutoTrink2 ~= 8 and ((LYAutoTrink2 == 4 and CalculateHP("player") < 25) or (LYAutoTrink2 == 5 and PartyHPBelow(35)) or
			(ValidEnemyUnit(LYEnemyTarget) and (UnitIsPlayer(LYEnemyTarget) or LYMode ~= "PvP") and IsInDistance(LYEnemyTarget,40) and ((LYAutoTrink2 == 1 and IsBursting()) or LYAutoTrink2 == 2 or (LYAutoTrink2 == 6 and CalculateHP(LYEnemyTarget) < 25) or (LYAutoTrink2 == 3 and UnitIsBoss(LYEnemyTarget))))) and
			IsUsableItem(GetInventoryItemID("player",14)) and GetInventoryItemCooldown("player",14) == 0 then
				local id = GetInventoryItemID("player",14)
				UseItemByName(id)
				Click()
			end
			if UnitAffectingCombat("player") and CalculateHP(LYEnemyTarget) < 35 and IsInDistance(LYEnemyTarget,40) and GetInventoryItemID("player",16) == 208321 and IsUsableItem(GetInventoryItemID("player",16)) and GetInventoryItemCooldown("player",16) == 0 then
				local id = GetItemInfo(208321)
				UseItemByName(id,LYEnemyTarget)
			end
		end
		local function AutoFocus()
			if IsGCDReady() and LYZoneType == "arena" then
				if LYAutoFocusHeal and not UnitIsVisible("focus") then
					for i=1,#LYEnemyHealers do
						if UnitIsVisible(LYEnemyHealers[i]) then
							FocusUnit(LYEnemyHealers[i])
							return true
						end
					end
				end
				if LYAutoFocusLast then
					if not LYAutoFocusLastUnit and UnitIsVisible("focus") then
						LYAutoFocusLastUnit = UnitGUID("focus")
					end
					if LYAutoFocusLastUnit and not UnitIsVisible("focus") then
						local focus = GetObjectWithGUID(LYAutoFocusLastUnit)
						if UnitIsVisible(focus) then
							FocusUnit(focus)
						end
					end
				end
				for i=1,#LYEnemies do
					if UnitIsVisible(LYEnemies[i]) and HaveBuff(LYEnemies[i],HnFD) and (not UnitIsVisible(LYEnemyTarget) or not UnitIsUnit(LYEnemyTarget,LYEnemies[i])) then
						TargetUnit(LYEnemies[i])
						return true
					end
				end
			end
		end
		local function BurstRacials()
			if LYRacialsBurst and IsBursting() and UnitIsVisible(LYEnemyTarget) and UnitAffectingCombat("player") then
				if GCDCheck(BloodFury) then
					CastSpellByName(BloodFury)
				end
				if GCDCheck(Berserking) then
					CastSpellByID(26297)
				end
				if GCDCheck(AncCall) then
					CastSpellByName(AncCall)
				end
			end
		end
		local function ArcTor()
			if GCDCheck(ArcaneTorrent) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and HaveBuff(LYEnemies[i],LYPurgeList,3) and IsInDistance(LYEnemies[i],8) then
						LYQueueSpell(ArcaneTorrent)
						return true
					end
				end
			end
		end
		local function Naaru()
			if GCDCheck(GiftNaaru) and LYStyle ~= "Utilities only" then
				for i=1,#LYTeamPlayers do
					if ValidFriendUnit(LYTeamPlayers[i]) and CalculateHP(LYTeamPlayers[i]) < LYRacialsHP then
						CastSpellByName(GiftNaaru,LYTeamPlayers[i])
						LY_Print(GiftNaaru,"green")
					end
				end
			end
		end
		local function DwarfSkinDoT()
			if GCDCheck(DwarfSkin) and LYStyle ~= "Utilities only" and CalculateHP("player") < LYRacialsHP and FriendIsUnderAttack("player") and HaveDebuff("player",listDoTs,3) then
				CastSpellByName(DwarfSkin)
				LY_Print(DwarfSkin,"green")
			end
		end
		local function LightJudgment()
			if LYRacialsDPS and GCDCheck(LightJudg) and LYStyle ~= "Utilities only" then
				for i=1,#LYEnemies do
					if ValidEnemyUnit(LYEnemies[i]) and SpellAttackTypeCheck(LYEnemies[i],"magic") and (UnitIsStunned(LYEnemies[i],2) or IsRooted(LYEnemies[i],2)) then
						LYQueueSpell(LightJudg,LYEnemies[i])
						return true
					end
				end
			end
		end
		local function EscapeArtist()
			if GCDCheck(EscapeArt) and LYMode ~= "PvE" and IsRooted("player",LYRacialsRootTime) and CalculateHP(LYEnemyTarget) < LYRacialsRootHP and not IsInDistance(LYEnemyTarget,5) then
				CastSpellByName(EscapeArt)
				LY_Print(EscapeArt,"green")
			end
		end
		local function DarkFlight()
			if GCDCheck(Darkflight) and LYStyle ~= "Utilities only" and LYMode ~= "PvE" and CalculateHP(LYEnemyTarget) < LYRacialsRootHP and HaveDebuff("player",listSlows,LYRacialsRootTime) and not IsInDistance(LYEnemyTarget,5) then
				CastSpellByName(Darkflight)
				LY_Print(Darkflight,"green")
			end
		end
		local function Attack()
			local dist = 5
			if LYMyClass == 3 and LYMySpec ~= 3 then
				dist = 40
			end
			if GetTime() > LYSwingTimer and LYStyle ~= "Utilities only" and UnitIsVisible(LYEnemyTarget) and (LYPlayerRole == "MELEE" or (LYMyClass == 3 and not HaveBuff("player",HnFD)) or (LYPlayerRole == "HEALER" and LYHDPS)) and (UnitAffectingCombat("player") or UnitAffectingCombat(LYEnemyTarget)) and IsInDistance(LYEnemyTarget,dist) and ObjectIsFacing("player",LYEnemyTarget) then
				StartAttack(LYEnemyTarget)
				LYSwingTimer = GetTime() + 2
				return
			end
		end
		local function CancelBoP()
			if LYMode == "PvP" and LYPlayerRole == "MELEE" and HaveBuff("player",PlBoP) and UnitIsVisible(LYEnemyTarget) and select(2,UnitClass(LYEnemyTarget)) == "MAGE" then
				CancelBuffByName(PlBoP)
			end
		end
		local function TargetFlag()
			if LYPlayerRole ~= "HEALER" and LYZoneType == "pvp" then
				local id = select(8,GetInstanceInfo())
				if id and (id == 2107 or id == 761) then
					for i=1,#LYEnemies do
						if UnitIsVisible(LYEnemies[i]) and UnitIsPlayer(LYEnemies[i]) then
							local castFlag = UnitCastingInfo(LYEnemies[i])
							if castFlag and castFlag == FlagCapture and (not UnitIsVisible("target") or not UnitIsUnit("target",LYEnemies[i])) then
								TargetUnit(LYEnemies[i])
								break
							end
						end
					end
				end
			end
		end
		local function Fake()
			if LYFake and castNameP and LYZoneType == "arena" and not HaveBuff("player",{PlBoP,PlBubble,PlMA}) then
				local spellT = GetSpellDestUnit("player")
				if UnitIsVisible(spellT) and ((LYPlayerRole == "HEALER" and CalculateHP(spellT) < 80 and not C_Spell.IsSpellHarmful(castNameP)) or (LYPlayerRole == "RDPS" and LYMyClass ~= 3 and C_Spell.IsSpellHarmful(castNameP) and CalculateHP(spellT) > 35 and not tContains(listNotFake,castNameP))) then
					EnemyCanKick(true)
					return
				end
			end
		end
		local function UseHealthStone()
			if CalculateHP("player") < LYHS and FriendIsUnderAttack("player") and not HaveDebuff("player",PrMindGame) and HSUsed + 10 < GetTime() then
				if IsUsableItem(5512) and GetItemCooldown(5512) == 0 then
					if GCDCheck(WlSoulBurn) then
						CastSpellByName(WlSoulBurn)
					end
					UseItemByName(5512)
					LY_Print(WlHS,"green")
					HSUsed = GetTime()
					return
				end
				if IsUsableItem(191380) and GetItemCooldown(191380) == 0 then
					UseItemByName(191380)
					LY_Print(WlHS,"green")
					HSUsed = GetTime()
					return
				end
				if IsUsableItem(137222) and GetItemCooldown(137222) == 0 then
					UseItemByName(137222)
					LY_Print(RgCrimson,"green")
					HSUsed = GetTime()
					return
				end
				if IsUsableItem(177278) and GetItemCooldown(177278) == 0 and LYPurifySoulCount ~= 0 then
					LYPurifySoulCount = 0
					UseItemByName(177278)
					LY_Print(PurifySoul,"green")
					HSUsed = GetTime()
					return
				end
				if IsUsableItem(207023) and GetItemCooldown(207023) == 0 then
					UseItemByName(207023)
					HSUsed = GetTime()
					LY_Print("Dreamwalker Potion","green")
				end
			end
		end
		local function CancelThorns()
			if HaveBuff("player",DrThorns) and HaveDebuff("player",MnKarma) and FriendIsUnderAttack("player") then
				CancelBuffByName(DrThorns)
			end
		end
		local function FirstPrio()
			if LYMyClass == 1 then
				if WrBersAntiFear() then
					return true
				end
			end
			if LYMyClass == 2 then
				if ConditionalSpell(PlDevProt,LYPlDevProtStunSec ~= 0 and UnitIsStunned("player",LYPlDevProtStunSec) and FriendIsUnderAttack("player") and CalculateHP("player") < LYPlDevProtStunHP) or
				DefensiveOnPlayer(PlDevProt,nil,LYPlDevProtHP,LYPlDevProtBurst,LYPlDevProtHealer,true) or
				PlBoPCast() or
				DefensiveOnPlayer(PlBubble,nil,LYPlBubbleHP,LYPlBubbleBurst,LYPlBubbleHealer,not HaveDebuff("player",PlForbear)) then
					return true
				end
			end
			if LYMyClass == 3 then
				if DefensiveOnTeam(HnPetSac,nil,LYHnSacHP,LYHnSacBurst,nil,not IsStealthed() and UnitIsVisible("pet") and not UnitIsDeadOrGhost("pet") and not UnitIsCCed("pet")) then
					return true
				end
			end
			if LYMyClass == 4 then
				if AntiStealth(RgSap) then
					return true
				end
			end
			if LYMyClass == 5 and UnitChannelInfo("player") ~= PrUltPenance then
				if DefensiveOnTeam(PrTeeth,nil,LYPrTeethHP,LYPrTeethBurst,nil,(not UnitIsStunned("player") or (LYPrTeethStun ~= 0 and UnitIsStunned("player",LYPrTeethStun))) and LYLastSpellName ~= PrTeeth and LYLastSpellName ~= PrPWB and LYLastSpellName ~= PrVoidshift) or
				DefensiveOnTeam(PrWings,nil,LYPrWingsHP,LYPrWingsBurst,nil,(not UnitIsStunned("player") or (LYPrWingsStun ~= 0 and UnitIsStunned("player",LYPrWingsStun)))) or
				DefensiveOnPlayer(PrDispers,nil,LYPrDispersHP,LYPrDispersBurst,LYPrDispersHealer,true) then
					return true
				end
			end
			if LYMyClass == 6 then
				if ConditionalSpell(DKIceBound,LYDKIBFStunTime ~= 0 and UnitIsStunned("player",LYDKIBFStunTime) and (not LYDKIBFStunBurst or HaveBuff("player",{DKUnhFrenzy,DKPillar,DKSindra}) or EnemyHPBelow(LYDKIBFStunHP))) or
				DefensiveOnPlayer(DKIceBound,nil,LYDKIceBoundHP,LYDKIceBoundBurst,LYDKIceBoundHealer,true) then
					return true
				end
			end
			if LYMyClass == 8 then
				if MgBlockCancel() or
				MgBlinkStun() or
				DefensiveOnPlayer(MgBlock,nil,LYMgBlockHP,LYMgBlockBurst,LYMgBlockHealer,not HaveDebuff("player",MgHypo) and not HaveBuff("player", MgAlterTime)) then
					return true
				end
			end
			if LYMyClass == 9 then
				if WlDispel() or
				WlKick() or
				DefensiveOnPlayer(WlMA,nil,LYWlMADefHP,LYWlMADefBurst,LYWlMADefHealer,not HaveBuff("player",PlBoP)) or
				DefensiveOnPlayer(WlSacShield,nil,LYWlSacShieldHP,LYWlSacShieldBurst,LYWlSacShieldHealer,(not LYWlSacShieldStun or UnitIsStunned("player"))) then
					return true
				end
			end
			if LYMyClass == 10 then
				if ConditionalSpell(MnTigerBrew,LYMnTigerBrewFoF and UnitChannelInfo("player") == MnFists and not HaveBuff("player",247483)) then
					return true
				end
			end
			if LYMyClass == 11 then
				if AntiStealth(DrRake) or
				ConditionalSpell(DrBSkin,LYDrBSkinStunTime ~= 0 and UnitIsStunned("player",LYDrBSkinStunTime) and FriendIsUnderAttack("player") and CalculateHP("player") < LYDrBSkinStunHP) or
				DefensiveOnPlayer(DrBSkin,nil,LYDrBSkinHP,LYDrBSkinBurst,LYDrBSkinHealer,true) or
				ConditionalSpell(DrBear,HaveDebuff("player",DrSolar) and IsRooted()) then
					return true
				end
			end
			if LYMyClass == 12 and HaveBuff("player",DHSpectral) then
				if AntiStealth(DHGlaive) then
					return true
				end
			end
			if LYMyClass == 13 and LYMySpec == 2 and UnitIsCCed("player") then
				if CommonHeal(EvEmerCommun,true,LYEvEmerCommunHP) then
					return true
				end
			end
		end
		local function CanNotCast()
			if UnitIsCCed("player") or HaveBuff("player",listStealth) or (HaveBuff("player",RgVanish) and LYMode ~= "PvE") or (LYMode == "PvP" and GetBattlefieldInstanceExpiration() ~= 0) or (LYMode == "PvE" and not HasFullControl()) or ((IsMounted() or UnitInVehicle("player")) and not HaveBuff("player",PlDivSteed)) then
				return true
			end
		end
		local function Common()
			if not PauseRotation then
				if AvoidIncomingMissiles() or
				BurstRacials() or
				CommonKick(WarStomp,"phys","alt",LYRacialsKick and not IsMoving(),5) or
				CommonKick(Haymaker,"phys","alt",LYRacialsKick and not IsMoving(),5) or
				CommonKick(QuakingPalm,"magic","alt",LYRacialsKick) or
				CommonKick(BullRush,"phys","alt",LYRacialsKick,5) or
				Naaru() or
				DwarfSkinDoT() or
				LightJudgment() or
				CommonAttack(BagofTricks,"phys",nil,BagofTricks,true) or
				EscapeArtist() or
				DarkFlight() or
				ArcTor() then
					return true
				end
			end
		end
		local function Class()
			if LYMyClass == 1 then -- Warrior
				if LYMySpec == 1 or LYMySpec == 5 then
					if not StartMSG then
						LY_Print("Arms Warrior enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYWarriorArms()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Fury Warrior enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYWarriorFury()
				elseif LYMySpec == 3 then
					if not StartMSG then
						LY_Print("Protection Warrior enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYWarriorProt()
				end
			elseif LYMyClass == 2 then -- Paladin
				LYUP = UnitPower("player",9)
				if LYMySpec == 1 then
					if not StartMSG then
						LY_Print("Holy Paladin enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYPaladinHoly()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Protection Paladin enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYPaladinProt()
				elseif LYMySpec == 3 or LYMySpec == 5 then
					if not StartMSG then
						LY_Print("Retribution Paladin enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYPaladinRet()
				end
			elseif LYMyClass == 3 then -- Hunter
				LYUP = UnitPower("player",2)
				if LYMySpec == 1 or LYMySpec == 5 then
					if not StartMSG then
						LY_Print("BM Hunter enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYHunterBM()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("MM Hunter enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYHunterMM()
				elseif LYMySpec == 3 then
					if not StartMSG then
						LY_Print("Surv Hunter enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYHunterSurv()
				end
			elseif LYMyClass == 4 then -- Rogue
				if UnitIsVisible("target") then
					LYCP = GetComboPoints("player","target")
				elseif not LYCP then
					LYCP = 0
				end
				LYCPMax = RgGetTrueMaxCP()
				if LYMySpec == 1 or LYMySpec == 5 then
					if not StartMSG then
						LY_Print("Assasination Rogue enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYRogueAss()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Outlaw Rogue enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYRogueOutlaw()
				elseif LYMySpec == 3 then
					if not StartMSG then
						LY_Print("Subtlety Rogue enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYRogueSub()
				end
			elseif LYMyClass == 5 then -- Priest
				if (UnitChannelInfo("player") == PrMC and not PartyHPBelow(LYPrMCHP)) or UnitChannelInfo("player") == PrUltPenance then
					return
				end
				if LYMySpec == 1 then
					if not StartMSG then
						LY_Print("Discipline Priest enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYPriestDisc()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Holy Priest enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYPriestHoly()
				elseif LYMySpec == 3 or LYMySpec == 5 then
					LYUP = UnitPower("player",13)
					if not StartMSG then
						LY_Print("Shadow Priest enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYPriestShadow()
				end
			elseif LYMyClass == 6 then -- DeathKnight
				LYUP = UnitPower("player",6)
				if LYMySpec == 1 then
					if not StartMSG then
						LY_Print("Blood DK enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYDeathKnightBlood()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Frost DK enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYDeathKnightFrost()
				elseif LYMySpec == 3 or LYMySpec == 5 then
					if not StartMSG then
						LY_Print("Unholy DK enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYDeathKnightUnh()
				end
			elseif LYMyClass == 7 then -- Shaman
				LYUP = UnitPower("player",11)
				if LYStayForm then
					return true
				end
				if LYMySpec == 1 or LYMySpec == 5 then
					if UnitChannelInfo("player") == ShLightLasso then
						return
					end
					if not StartMSG then
						LY_Print("Elemental Shaman enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYShamanElem()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Enhancement Shaman enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYShamanEnch()
				elseif LYMySpec == 3 then
					if not StartMSG then
						LY_Print("Restoration Shaman enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYShamanRestor()
				end
			elseif LYMyClass == 8 then -- Mage
				if LYMySpec == 1 then
					LYUP = UnitPower("player",16)
					if not StartMSG then
						LY_Print("Arcane Mage enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYMageArc()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Fire Mage enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYMageFire()
				elseif LYMySpec == 3 or LYMySpec == 5 then
					if not StartMSG then
						LY_Print("Frost Mage enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYMageFrost()
				end
			elseif LYMyClass == 9 then -- Warlock
				LYUP = UnitPower("player",7)
				WlSetPetType()
				if LYMySpec == 1 or LYMySpec == 5 then
					if not StartMSG then
						LY_Print("Affliction Warlock enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYWarlockAfli()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Demonology Warlock enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYWarlockDemon()
				elseif LYMySpec == 3 then
					if not StartMSG then
						LY_Print("Destruction Warlock enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYWarlockDestr()
				end
			elseif LYMyClass == 10 then -- Monk
				LYCP = UnitPower("player",12)
				if LYMySpec == 1 then
					if not StartMSG then
						LY_Print("Brewmaster Monk enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYMonkBrew()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Mistweaver Monk enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYMonkMist()
				elseif LYMySpec == 3 then
					LYCPMax = 5
					if IsTalentInUse(115396) then
						LYCPMax = 6
					end
					if not StartMSG then
						LY_Print("Windwalker Monk enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYMonkWind()
				end
			elseif LYMyClass == 11 then -- Druid
				if UnitIsVisible("target") then
					LYCP = GetComboPoints("player","target")
				elseif not LYCP then
					LYCP = 0
				end
				LYCPMax = 5
				if LYStayForm then
					if GetShapeshiftForm() == 3 then
						return true
					elseif DrBearAction() or
						DrCatAction() or
						DrOwlAction() then
						return true
					end
					return true
				end
				if LYMySpec ~= 2 and HaveBuff("player",DrDash) and GetShapeshiftForm() == 2 then
					return true
				end
				if LYMySpec == 1 or LYMySpec == 5 then
					if not StartMSG then
						LY_Print("Balance Druid enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYDruidBalance()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Feral Druid enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYDruidFeral()
				elseif LYMySpec == 3 then
					if not StartMSG then
						LY_Print("Guardian Druid enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYDruidGuard()
				elseif LYMySpec == 4 then
					if not StartMSG then
						LY_Print("Restor Druid enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYDruidRestor()
				end
			elseif LYMyClass == 12 then -- DH
				if LYMySpec == 1 then
					if not StartMSG then
						LY_Print("Demon Hunter Havoc enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYDemonHunterHavoc()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Demon Hunter Vengeance enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYDemonHunterVeng()
				end
			elseif LYMyClass == 13 then -- Evoker
				if LYMySpec == 1 then
					if not StartMSG then
						LY_Print("Evoker Devastation enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYEvokerDevas()
				elseif LYMySpec == 2 then
					if not StartMSG then
						LY_Print("Evoker Preservation enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYEvokerPreserv()
				elseif LYMySpec == 3 then
					if not StartMSG then
						LY_Print("Evoker Augmentatiuon enabled","green")
						StartMSG = true
						LYValidRotation = true
					end
					return LYEvokerAug()
				end
			end
		end
		if LYDebug and not (UnitChannelInfo("player") or UnitCastingInfo("player")) and IsGCDReady() then
			print("Time: "..GetTime()..". Enemies: "..tostring(#LYEnemies)..". PauseGCD: " .. tostring(PauseGCD or "0" ) .. ". Rotation pause: " .. tostring(PauseRotation or "OFF") .. ". Current spell: " .. tostring(LYCurrentSpellName or "NONE"))
		end
		SetVars()
		LYFireSpell()
		if not HaveBuff("player",listPauseRotation) and (not HaveBuff("player",DHSpectral) or IsTalentInUse(389849)) then
			CastSpells()
			PauseKeys()
			Fake()
			Meld()
			CancelThorns()
			Attack()
			AutoFocus()
			CancelBoP()
			TargetFlag()
			UseHealthStone()
			Trinkets()
			if FirstPrio() or
			CanNotCast() or
			Common() or
			Class() then
				return true
			end
		end
	end
	--Main
	function LY_OnLoad()
		LYFrames = CreateFrame("Frame")
		LYFrames:SetScript("OnUpdate",LYFrames_OnUpdate)
		LYFrames:SetScript("OnEvent",LYFrames_OnEvent)
		LYFrames:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		LYFrames:RegisterEvent("PLAYER_LEVEL_UP")
		LYFrames:RegisterEvent("PLAYER_DEAD")
		LYFrames:RegisterEvent("PLAYER_TALENT_UPDATE")
		LYFrames:RegisterEvent("PLAYER_PVP_TALENT_UPDATE")
		LYFrames:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		LYFrames:RegisterEvent("SPELLS_CHANGED")
		LYFrames:RegisterEvent("PLAYER_ENTERING_WORLD")
		LYFrames:RegisterEvent("PLAYER_TARGET_CHANGED")
		LYFrames:RegisterEvent("PLAYER_UNGHOST")
		LYFrames:RegisterEvent("PLAYER_REGEN_ENABLED")
		LYFrames:RegisterEvent("UNIT_SPELLCAST_SENT")
		LYFrames:RegisterEvent("ENCOUNTER_END")
		LYFrames:RegisterEvent("ENCOUNTER_START")
		LYFrames:RegisterEvent("UI_ERROR_MESSAGE")
		LYFrames:RegisterEvent("RESURRECT_REQUEST")
		LYFrames:RegisterEvent("PLAYER_FOCUS_CHANGED")
		LYFrames:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		LYFrames:RegisterEvent("UNIT_SPELLCAST_FAILED")
		LYFrames:RegisterEvent("UNIT_SPELLCAST_STOP")
	end
	function LYFrames_OnUpdate(self,elapsed)
		if IsPlayerInWorld() then
			if not LYMyClass then                		
				LYMyClassName,LYMyClass = select(2,UnitClass("player"))
				LYMySpec = GetSpecialization()
				LYMyLevel = UnitLevel("player")
				LYMyGUID = UnitGUID("player")
				if LYMyLevel < 10 then
					print("[".."|cffff6060".."HandsFree Reborn".."|r".."]".."[ATTENTION] HF might not run properly at low levels")
				end
				LYMyFaction = UnitFactionGroup("player")
				TalentGroup = GetActiveSpecGroup()
				IDTables()
				CheckPlayerTalents()
				GetPlayerSpells()
				LY_RunGUI()
				_G.SLASH_EVENT1 = "/"..string.upper(LYMacroCommand)
				_G.SlashCmdList["EVENT"] = LEGCMD
				SetCVar("synchronizeMacros",0)
				SetCVar("scriptErrors",1)
				SetCVar("spellQueueWindow",100)
				LYMyCombatReach = UnitCombatReach("player")
				ResetLYTables()
			end
			if LYStart then
				-- if not tContains(HFSubs,LYMyClass) then
				-- 	LY_Print("You don't have the class sub. Game will close in 5 sec","red")
				-- 	C_Timer.After(5,function() ForceQuit() end)
				-- 	return
				-- end
				-- RunSecurityCheck()
				if GetTime() > LYFrameOptimal + LYFrameDelay/1000 + math.random(5,25)/1000 then
					LYFrameOptimal = GetTime()
					if not UnitIsDeadOrGhost("player") then
						BuildTables()
						MainRotation()
					end
					if not LYMessage and LYValidRotation then
						LYMessage = true
					end
				end
			elseif LYMessage then
				if LYValidRotation then
					LYCP,LYUP = 0,0
					LY_Print("Disabled","red")
					LYMessage = false
				end
				StartMSG = false
			end
		end
	end
	function LEGCMD(msg)
		local msg = strtrim(msg)
		local space1, space2, command, par = string.find(msg," "), nil, nil, nil
		if space1 then
			space2 = string.find(msg," ",space1)
			if space2 then
				command = string.sub(msg,1,space1-1)
				par = string.sub(msg,space2+1)
			end
		end
		if command then
			if command == "burst" then
				LY_Burst(par)
			elseif command == "shift" then
				LY_Form(par)
			elseif command == "next" then
				LY_Next(par)
			elseif command == "cast" or command == "castsequence" then
				LY_ForceCast(par)
			elseif command == "blinkcc" then
				LY_BlinkCC(par)
			elseif command == "savepower" then
				LY_DoNotUsePower(par)
			elseif command == "castcheck" then
				LY_ForceCastCheck(par)
			elseif command == "run" then
				PauseGCD = GetTime() + par
				LY_Print("Pausing rotation for "..par.." sec","red")
			end
		elseif msg == "" then
			OpenSettings()
		elseif msg == "aoe" then
			LY_Style()
		elseif msg == "run" then
			LY_StartStop()
		elseif msg == "savepower" then
			LY_DoNotUsePower()
		elseif msg == "fake" then
			LY_SmartFake()
		elseif msg == "dothealer" then
			LY_DoTHealer()
		elseif msg == "trinket" then
			LY_TrueTrinket()
		elseif msg == "burst" then
			LY_Burst()
		elseif msg == "hdps" then
			LY_HDPS()
		elseif msg == "slow" then
			LY_Slow()
		elseif msg == "gate" then
			LY_Gate()
		elseif msg == "help" then
			LY_Print("Open readme.txt for macros and help","green")
		elseif msg == "petattack" then
			LY_PetOnHealer()
		elseif msg == "kick" then
			LY_Kick()
		elseif msg == "minimap" then
			LY_MiniMap()
		elseif msg == "debug" then
			LY_Debug()
		else
			LY_Print("Wrong macro","red")
		end
	end
	LY_OnLoad()
end
local function TryLoading()
	C_Timer.After(1,function()
		if setfenv then
			setmetatable(LYEnv,{
				__index = function(t,k)
					local result
					if MainEnv[k] then
						result = MainEnv[k]
					elseif unlocker == "tinkr" and TinkrAPI[k] then
						result = TinkrAPI[k]
					elseif extraAPI[k] then
						result = extraAPI[k]
					elseif _G[k] then
						result = _G[k]
					end
					rawset(t,k,result)
					return result
				end
			})
			setfenv(Load,LYEnv)
			Load()
		else
			TryLoading()
		end
	end)
end
TryLoading()