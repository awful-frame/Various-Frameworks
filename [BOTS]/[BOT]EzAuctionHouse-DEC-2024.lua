local un = ...

--==========================================================================
--========================== Unlocker Detection ============================
--==========================================================================
--
local Unlocker = "NA"

local function SetUnlocker()
	local cacheUnlocker = "NA"
	-- Check if the ObjectLootableRaw and ObjectLootable functions are available (Only works in combination since ObjectLootable itself is available in Tinkr too)
	if (type(ObjectLootableRaw) == "function") and type(ObjectLootable) == "function" then
		return "noname"
	elseif un.Util.Evaluator ~= nil then
		un.Util.Evaluator:EmplaceGlobals('app')
		return "tinkr"
	end

	return cacheUnlocker
end
Unlocker = SetUnlocker()
if Unlocker == "NA" then
	print("|cff00FF00[|r |cffFF0000E|r |cffFF7F00A|r |cffFFFF00Z|r |cff00FF00Y|r |cff00FF00-|r |cff00FF00A|r |cff00FF00H|r |cff00FF00]|r |cffFF0000[ERROR]|r " .. "No Unlocker Detected")
	return
end

--==========================================================================
--======================== Bot Variables ===================================
--==========================================================================
local EZ_Running = false;
local EZ_Path = nil;
local TickerRate = 0.05
local TSM_Loaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded("TradeSkillMaster")
local Auctionator_Loaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded("Auctionator")
local PointBlankSniper_Loaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded("PointBlankSniper")
local AutoLoad = true
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

local mainFolder = "ezah"
local settingsFoler = "Settings"
local logFolder = "Logs"

Launcher = CreateFrame("Frame", "EZ_Launcher", UIParent, "BackdropTemplate")
_G.EZA = {}
local EZL = {}
EZL.Helper = {
	JSON = {},
	Base64 = {},
}
EZL.FileSystem = {}
EZL.UI = {}
EZL.Common = {
	Hitflags = {
		DoodadCollision = 0x00000001,
		DoodadRender = 0x00000002,
		WmoCollision = 0x00000010,
		WmoRender = 0x00000020,
		WmoNoCamCollision = 0x00000040,
		Terrain = 0x00000100,
		WmoIgnoreDoodad = 0x00002000,
		LiquidWaterWalkable = 0x00010000,
		LiquidAll = 0x00020000,
		Cull = 0x00080000,
		EntityCollision = 0x00100000,
		EntityRender = 0x00200000,
		Collision = 0x00100111,
		LineOfSight = 0x00100010,
	}
}
--==========================================================================
--================================ Settings ================================
--==========================================================================

local closeAfterXHours = 0;
local snipeForXMinutes = 10;
local waitXMinutes = 5;
local reloadXMinutes = 5;

local SelectedMode = "NA"
local PostScanStarted = false
local CancelScanStarted = false
local WaitingPrint = false
local mailTaskBlockedUntil = 0 -- Time until the mail task is blocked
local reloadTimer = nil
local sniperScanTime = 0 -- Time how long the sniper scan should run
local LastPrintTime = 0

local auctionStateRoutine
local lastYieldTime = GetTime()
local delay = 0.3  -- Delay for 0.3 seconds
local auctionDelay = 0.3  -- Delay for 0.3 seconds
local cancelDelay = 0.3  -- Delay for 0.3 seconds
local mailDelay = 0.3  -- Delay for 0.3 seconds
local mailProcessRoutine
local cancelStateRoutine
local snipeRoutine
local isBuyingSnipe = false

local BotModes = {
	Sliders = { name = "Auto-Sell" },
	autoCancel = { name = "Auto-Cancel" },
	autoSnipe = { name = "Auto-Snipe" },
	fullAuto = { name = "Full-Auto" },
}

--==========================================================================
--=========================== Object Information ===========================
--==========================================================================

local mailboxInfo = {
	x = 0,
	y = 0,
	z = 0,
	id = 0,
}
local auctioneerInfo = {
	x = 0,
	y = 0,
	z = 0,
	id = 0,
}

--==========================================================================
--=========================== Addon Detection ==============================
--==========================================================================

if not TSM_Loaded then 
	local message = "TradeSkillMaster does not seem to be loaded. Make sure it's properly installed."
	print("|cff00FF00[|r |cffFF0000E|r |cffFF7F00A|r |cffFFFF00Z|r |cff00FF00Y|r |cff00FF00-|r |cff00FF00A|r |cff00FF00H|r |cff00FF00]|r |cffFF0000[ERROR]|r " .. message)
	return
elseif isRetail then
	if not Auctionator_Loaded then
		local message = " Auctionator does not seem to be loaded. Make sure it's properly installed."
		print("|cff00FF00[|r |cffFF0000E|r |cffFF7F00A|r |cffFFFF00Z|r |cff00FF00Y|r |cff00FF00-|r |cff00FF00A|r |cff00FF00H|r |cff00FF00]|r |cffFF0000[ERROR]|r " .. message)
		return
	elseif not PointBlankSniper_Loaded then
		local message = " PointBlankSniper does not seem to be loaded. Make sure it's properly installed."
		print("|cff00FF00[|r |cffFF0000E|r |cffFF7F00A|r |cffFFFF00Z|r |cff00FF00Y|r |cff00FF00-|r |cff00FF00A|r |cff00FF00H|r |cff00FF00]|r |cffFF0000[ERROR]|r " .. message)
		return
	end
end

--==========================================================================
--============================= Core Functions =============================
--==========================================================================

	--======================================================================
	--==================== Unlocker Functions ==============================
	--======================================================================
	local UnlockerFuncs = {
		noname = {
			Unlock = function(functionname,...) return Unlock(functionname,...)	end,
			Draw = function() return Utils.Draw:New() end,
			ObjectManager = function(typ) return ObjectManager(typ) end,
			JSONDecode = function(string) return Utils.JSON.decode(string) end,
			JSONEncode = function(string) return Utils.JSON.encode(string) end,
			BASE64Encode = function(string) return un.Base64Encode(string) end,
			BASE64Decode = function(string) return un.Base64Decode(string) end,
			ReadFile = function(path) return ReadFile(path) end,
			WriteFile = function(path,data,append) return WriteFile(path,data,append) end,
			DirectoryExists = function(dir) return DirectoryExists(dir) end,
			CreateDirectory = function(dir) return CreateDirectory(dir) end,
			FileExists = function(file) return FileExists(file) end,
			ReloadUI = function() return Unlock("ReloadUI","") end,
			AntiAFK = function() return LastHardwareAction(GetTime() * 1000) end,
			ObjectPosition = function(object) return ObjectPosition(object) end,
			ObjectId = function(object) return ObjectId(object) end,
			ObjectName = function(object) return ObjectName(object) end,
			Object = function(object) return Object(object) end,
			GameObjectType = function(object) return GameObjectType(object) end,
			ObjectInteract = function(object) return ObjectInteract(object) end,
			SetFacing = function(angle) return SetPlayerFacing(angle) end,
			TraceLine = function(x1,y1,z1,x2,y2,z2,flags) return TraceLine(x1,y1,z1,x2,y2,z2,flags) end,
			ScreenToWorld = function(x,y) return ScreenToWorld(x,y) end,
			GetCursorPosition = function() return GetCursorPosition() end,
			ObjectHeight = function(object) return ObjectHeight(object) end,
			ObjectBoundingRadius = function(object) return ObjectBoundingRadius(object) end,
			ObjectCombatReach = function(object) return GetUnitCombatReach(object) end,
		},
		tinkr = {
			Unlock = function(functionname, ...)
				if select("#", ...) == 0 then
					return Eval(functionname .. "()", "")
				else
					local args = table.concat({...}, "','")
					return Eval(functionname .. "('" .. args .. "')", "")
				end
			end,
			Draw = function() return un.Util.Draw:New() end,
			ObjectManager = function(typ) return un.Util.ObjectManager:Filter(typ) end,
			JSONDecode = function(string) return un.Util.JSON:Decode(string) end,
			JSONEncode = function(string) return un.Util.JSON:Encode(string) end,
			BASE64Encode = function(string) return un.Util.Crypto.Base64:Encode(string) end,
			BASE64Decode = function(string) return un.Util.Crypto.Base64:Decode(string) end,
			ReadFile = function(path) return ReadFile(path) end,
			WriteFile = function(path,data,append) return WriteFile(path,data,append) end,
			DirectoryExists = function(dir) return DirectoryExists(dir) end,
			CreateDirectory = function(dir) return CreateDirectory(dir) end,
			FileExists = function(file) return FileExists(file) end,
			ReloadUI = function() return Eval("ReloadUI()", "") end,
			AntiAFK = function() return SetLastHardwareActionTime(GetGameTick()) end,
			ObjectPosition = function(object) return ObjectPosition(object) end,
			ObjectId = function(object) return ObjectID(object) end,
			ObjectName = function(object) return ObjectName(object) end,
			Object = function(object) return Object(object) end,
			GameObjectType = function(object) return GameObjectType(object) end,
			ObjectInteract = function(object) return ObjectInteract(object) end,
			SetFacing = function(angle) return SetHeading(angle) end,
			TraceLine = function(x1,y1,z1,x2,y2,z2,flags) return TraceLine(x1,y1,z1,x2,y2,z2,flags) end,
			ScreenToWorld = function(x,y) return un.Common.ScreenToWorld(x,y) end,
			GetCursorPosition = function() return GetCursorPosition() end,
			ObjectHeight = function(object) return ObjectHeight(object) end,
			ObjectBoundingRadius = function(object) return ObjectBoundingRadius(object) end,
			ObjectCombatReach = function(object) return ObjectCombatReach(object) end,
		}
	}
	
	--======================================================================
	--======================= Prints =======================================
	--======================================================================
	EZL.Print = {}
	print("test4")
	local PrintTable = {
		__index = function(table, key)
			if key == "Info" then
				return function(string)
					-- Print [EAZY-AH] (Rainbow color)
					print("|cff00FF00[|r |cffFF0000E|r |cffFF7F00A|r |cffFFFF00Z|r |cff00FF00Y|r |cff00FF00-|r |cff00FF00A|r |cff00FF00H|r |cff00FF00]|r " .. string)
				end
			elseif key == "Error" then
				return function(string)
					-- Print [EAZY-AH][ERROR] (error in red)
					print("|cff00FF00[|r |cffFF0000E|r |cffFF7F00A|r |cffFFFF00Z|r |cff00FF00Y|r |cff00FF00-|r |cff00FF00A|r |cff00FF00H|r |cff00FF00]|r |cffFF0000[ERROR]|r " .. string)
				end
			elseif key == "Debug" then
				return function(string)
					-- Print [EAZY-AH][DEBUG] (debug in yellow)
					print("|cff00FF00[|r |cffFF0000E|r |cffFF7F00A|r |cffFFFF00Z|r |cff00FF00Y|r |cff00FF00-|r |cff00FF00A|r |cff00FF00H|r |cff00FF00]|r |cffFFFF00[DEBUG]|r " .. string)
				end
			elseif key == "Warning" then
				return function(string)
					-- Print [EAZY-AH][WARNING] (warning in orange)
					print("|cff00FF00[|r |cffFF0000E|r |cffFF7F00A|r |cffFFFF00Z|r |cff00FF00Y|r |cff00FF00-|r |cff00FF00A|r |cff00FF00H|r |cff00FF00]|r |cffFF7F00[WARNING]|r " .. string)
				end
			elseif key == "System" then
				return function(string)
					-- Print [EAZY-AH][SYSTEM] (system in white)
					print("|cff00FF00[|r |cffFF0000E|r |cffFF7F00A|r |cffFFFF00Z|r |cff00FF00Y|r |cff00FF00-|r |cff00FF00A|r |cff00FF00H|r |cff00FF00]|r |cffFFFFFF[SYSTEM]|r " .. string)
				end
			end
		end
	}

	setmetatable(EZL.Print, PrintTable)

--==========================================================================
--============================= Utils ======================================
--==========================================================================

local ObjectManager = UnlockerFuncs[Unlocker].ObjectManager()

--==========================================================================
--============================ Helper Functions ============================
--==========================================================================

function EZL.Helper.JSON.Decode(string)
	return UnlockerFuncs[Unlocker].JSONDecode(string)
end

function EZL.Helper.JSON.Encode(string)
	return UnlockerFuncs[Unlocker].JSONEncode(string)
end

function EZL.Helper.Base64.Encode(string)
	return UnlockerFuncs[Unlocker].BASE64Encode(string)
end

function EZL.Helper.Base64.Decode(string)
	return UnlockerFuncs[Unlocker].BASE64Decode(string)
end

function EZL.Helper.HexToRGBA(hex_color,alpha)
    -- Remove the hash (#) if it exists
    hex_color = hex_color:gsub("#","")

    -- Convert hex color to decimal and normalize to 0-1 range
    local r = tonumber("0x"..hex_color:sub(1,2)) / 255
    local g = tonumber("0x"..hex_color:sub(3,4)) / 255
    local b = tonumber("0x"..hex_color:sub(5,6)) / 255
    local a = alpha or 1

    return r, g, b, a
end

function EZL.Helper.TableCount(table)
	local count = 0
	for _ in pairs(table) do count = count + 1 end
	return count
end

--==========================================================================
--============================ File System =================================
--==========================================================================

function EZL.FileSystem.ReadFile(path)
	return UnlockerFuncs[Unlocker].ReadFile(path)
end

function EZL.FileSystem.WriteFile(path,data,append)
	return UnlockerFuncs[Unlocker].WriteFile(path,data,append)
end

function EZL.FileSystem.DirectoryExists(dir) -- Root Directory --> Scripts
	return UnlockerFuncs[Unlocker].DirectoryExists(dir)
end

function EZL.FileSystem.CreateDirectory(dir) --e.g '/scripts/onezero/test'
	return UnlockerFuncs[Unlocker].CreateDirectory(dir)
end

function EZL.FileSystem.FileExists(path)
	return UnlockerFuncs[Unlocker].FileExists(path)
end

function EZA.RunString(string)
	if Unlocker == "noname" then
		loadstring(string)()
		--C_Timer.Nn.RunScript(string)
	elseif Unlocker == "tinkr" then
		Eval(string, "")
	end
end

--==========================================================================
--============================ UI / GUI ============================
--==========================================================================

local changingSize = false
local changingAlpha = false

local LauncherWidth_Start = 130
local LauncherWidth_Final = 180

local ContentHeight_Start = 0
local ContentHeight_Final = 80

local StateDisplayWidth_Start = 130
local StateDisplayWidth_Final = 180
local StateDisplayHeight = 55

local HeaderHeight = 30

-- Normal Green: |cff00FF00
-- Dark Green: |cff00CC00
local Color_White = "FDFDFD"
local Color_LightGray = "DDE3EB"
local Color_DarkGray = "474F5A"
local Color_BlueGray = "263141"
local Color_Green = "054E00"
local Color_LightGreen = "407b31"
local Color_Red = "ff3232"
local Color_LightRed = "ff6666"

local PaneBackdrop  = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	edgeSize = 4,
	insets = {left = 1, right = 1, top = 1, bottom = 1},
}

--------------------------
-- GUI
--------------------------

-- Launcher
function EZL.UI.ChangeSize(frame, x, y, duration, delay)
	changingSize = true
    local originalX = frame:GetWidth()
    local originalY = frame:GetHeight()

	frame:Show()

    local xStep = 0.2
    local yStep = 0.2

	local xDiff = x - originalX
	local yDiff = y - originalY

	if xDiff < 0 then xStep = xStep * -1 end
	if yDiff < 0 then yStep = yStep * -1 end

	local xSteps = xDiff / duration
	local ySteps = yDiff / duration

	local tickRate = duration / GetFramerate()
    local startTime;
    
    local function changeSize()
		if not startTime then startTime = GetTime() end
        local currentTime = GetTime() - startTime
        
        local newWidth = originalX + xSteps * currentTime
		local newHeight = originalY + ySteps * currentTime

		-- Round to the nearest integer
		newWidth = math.floor(newWidth + 0.5)
		newHeight = math.floor(newHeight + 0.5)
        
        frame:SetSize(newWidth, newHeight)
        
        if currentTime < duration then
            C_Timer.After(tickRate, changeSize)
        else
			changingSize = false
            frame:SetSize(x, y)
			if x == 0 and y == 0 then
				frame:Hide()
			end
        end
    end
    C_Timer.After(delay or 0, changeSize)
end

function EZL.UI.ChangeAlpha(frame, alpha, duration, delay,prints)
	changingAlpha = true
    if not frame then
        EZL.Print.Debug(debugstack("Error: frame is nil in EZL.UI.ChangeAlpha"))
        return
    end
	local originalAlpha = frame:GetAlpha()

	local aStep = 0.1

	local diffAlpha = alpha - originalAlpha

	if diffAlpha < 0 then aStep = aStep * -1 end
	
	local alphaStep = diffAlpha / duration

	local tickRate = duration / GetFramerate()
	local startTime;

	local function changeAlpha()
		if not startTime then startTime = GetTime() end
		local currentTime = GetTime() - startTime

		local newAlpha = originalAlpha + alphaStep * currentTime
		
		if newAlpha < 0 then
			newAlpha = 0
		elseif newAlpha > 1 then
			newAlpha = 1
		end
		if prints then
			EZL.Print.Debug(newAlpha)
		end
		frame:SetAlpha(newAlpha)

		if currentTime < duration then
			changingAlpha = true
			C_Timer.After(tickRate, changeAlpha)
		else
			changingAlpha = false
			frame:SetAlpha(alpha)
		end
	end
	
	C_Timer.After(delay or 0, changeAlpha)
end

function EZL.SaveSettings()
	local saveTable = {
		["closeAfterXHours"] = closeAfterXHours,
		["snipeForXMinutes"] = snipeForXMinutes,
		["waitXMinutes"] = waitXMinutes,
		["reloadXMinutes"] = reloadXMinutes,
		["auctioneerInfo"] = auctioneerInfo,
		["mailboxInfo"] = mailboxInfo,
		["selectedMode"] = EZL.StateMachine.selectedMode,
		["AutoLoad"] = AutoLoad,
	}
	
	if not EZL.FileSystem.DirectoryExists("/scripts/" .. mainFolder) then        
        EZL.FileSystem.CreateDirectory("/scripts/" .. mainFolder)
    end

	if not EZL.FileSystem.DirectoryExists("/scripts/" .. mainFolder ..  "/" .. settingsFoler) then        
        EZL.FileSystem.CreateDirectory("/scripts/" .. mainFolder ..  "/" .. settingsFoler)
	else
		local json = EZL.Helper.JSON.Encode(saveTable)
		EZL.FileSystem.WriteFile("/scripts/" .. mainFolder ..  "/" .. settingsFoler .. "/" .. UnitGUID("player")..UnitName("player")..".json",json,false)
    end
end

function EZL.LoadSettings()
	local settings = EZL.FileSystem.ReadFile("/scripts/" .. mainFolder ..  "/" .. settingsFoler .. "/" .. UnitGUID("player")..UnitName("player")..".json")
	if settings then
		local decoded = EZL.Helper.JSON.Decode(settings)
		if decoded then
			closeAfterXHours = decoded.closeAfterXHours or closeAfterXHours
			snipeForXMinutes = decoded.snipeForXMinutes or snipeForXMinutes
			waitXMinutes = decoded.waitXMinutes or waitXMinutes
			reloadXMinutes = decoded.reloadXMinutes or reloadXMinutes
			auctioneerInfo = decoded.auctioneerInfo or auctioneerInfo
			mailboxInfo = decoded.mailboxInfo or mailboxInfo
			SelectedMode = decoded.selectedMode or SelectedMode
			AutoLoad = decoded.AutoLoad or AutoLoad
		end
	end
end

function EZL.SetMailbox()
	local tableobjects = EZL.ObjectManager("GameObject")
	local collectedMailboxes = {}
	for _, v in pairs(tableobjects) do
		if EZL.ObjectIsMailbox(v) or (EZL.GetObjectName(v) == "Mailbox") then -- Added Mailbox Name as a fallback during ongoing fix from NN
			local distance = EZL.GetDistanceBetweenObjects("player", v)
			table.insert(collectedMailboxes,
				{
					object = v,
					distance = distance
				})
		end
	end

	local bestMailbox = nil
	local bestdistance = 100000000
	if collectedMailboxes and #collectedMailboxes > 0 then
		for _, mailbox in pairs(collectedMailboxes) do
			if mailbox.distance and mailbox.distance < bestdistance then
				bestdistance = mailbox.distance
				bestMailbox = mailbox.object
			end
		end
	end

	if bestMailbox then
		local xT, yT, zT, idT, object = EZL.GetObjectInfo(bestMailbox)
		mailboxInfo.x = xT
		mailboxInfo.y = yT
		mailboxInfo.z = zT
		mailboxInfo.id = idT
		if idT then
			EZL.SaveSettings()
			EZL.Print.System("Mailbox Successfully Set")
		end
	end
end

function EZL.SetAuctioneer()
	
	if UnitExists("target") then
		local xT,yT,zT,idT,object = EZL.GetObjectInfo("target")
		auctioneerInfo.x = xT
		auctioneerInfo.y = yT
		auctioneerInfo.z = zT
		auctioneerInfo.id = idT
		EZL.SaveSettings()
		EZL.Print.Info("Auctioneer Successfully Set")
	else
		EZL.Print.Error("No Target")
	end
end

function EZL.SetPlayerPosAsAHPos()
	local x,y,z = EZL.GetObjectPosition("player")
	auctioneerInfo.x = x
	auctioneerInfo.y = y
	auctioneerInfo.z = z
	EZL.SaveSettings()
	EZL.Print.Info("PlayerPos as AuctioneerPos Successfully Set")
end

function EZL.IsMailboxSet()
	local x,y,z = mailboxInfo.x,mailboxInfo.y,mailboxInfo.z
	local id = mailboxInfo.id

	if x == 0.0 and y == 0.0 and z == 0.0 and id == 0.0 then
		return false
	else
		return true
	end	
end

function EZL.IsAuctioneerSet()
	local x,y,z = auctioneerInfo.x,auctioneerInfo.y,auctioneerInfo.z
	local id = auctioneerInfo.id

	if x == 0.0 and y == 0.0 and z == 0.0 and id == 0.0 then
		return false
	else
		return true
	end
end

function EZL.MoveToMailbox()
	if not EZ_Path then
		EZ_Path = EZL.PathToMailbox()
	end
	EZL.UpdatePosition()
end

function EZL.MoveToAuctioneer()
	if not EZ_Path then
		EZ_Path = EZL.PathToAuctioneer()
	end
	EZL.UpdatePosition()
end

function EZL.IsNearMailbox()
    local mailbox = EZL.GetObjectWithId(mailboxInfo.id,"GameObject")
    if mailbox then
        local distance = EZL.GetDistanceBetweenObjects("player",mailbox)
        
        if distance and distance < 5 then
            return true
        end
    end
    return false
end

function EZL.IsNearAuctioneer()
	local auctioneer = EZL.GetObjectWithId(auctioneerInfo.id)
	if auctioneer then
		local distance = EZL.GetDistanceBetweenObjects("player",auctioneer)
		if distance and distance < 5 then
			return true
		end
	end
	return false
end

function EZL.IsAuctionHouseFrameVisible()
	if isRetail then
		return AuctionHouseFrame and AuctionHouseFrame:IsVisible()
	else
		return (AuctionFrame and AuctionFrame:IsVisible()) or TSM_API.IsUIVisible("AUCTION")
	end
end

function EZL.ResetScans()
	PostScanStarted = false
	CancelScanStarted = false
	SniperScanStarted = false
end

function EZL.Unlock(...)
	return UnlockerFuncs[Unlocker].Unlock(...)
end

function EZL.StopMovement()
	EZ_Path = nil
	EZL.Unlock("MoveForwardStop","")
	EZL.Unlock('MoveBackwardStop','')
	EZL.Unlock('TurnLeftStart','')
	EZL.Unlock('TurnLeftStop','')
end

function EZL.HasMailsToOpen()
	CheckInbox() -- Query Server for Mails
	if HasNewMail() or (GetInboxNumItems() > 0) then
		return true
	end
	return false
end

function EZL.HasEmptyMails()
	for i = 1, GetInboxNumItems() do
		local _, _, _, _, _, _, _, hasItem = GetInboxHeaderInfo(i)
		if not hasItem then
			return true
		end
	end
	return false
end

function EZL.RemoveEmptyMail()
	for i = 1, GetInboxNumItems() do
		local _, _, _, _, _, _, _, hasItem = GetInboxHeaderInfo(i)
		if not hasItem then
			DeleteInboxItem(i)
		end
	end
end

function EZL.HasItemsToPickUp()
	local numItems, totalnum = GetInboxNumItems()
	if numItems then
		for messageIndex = 1, numItems do
			for attachmentIndex = 1, ATTACHMENTS_MAX_SEND do
				local hasItem = HasInboxItem(messageIndex, attachmentIndex)
				if hasItem then
					return true
				end
			end
		end
	end
	return false
end

function EZA.GetMode()
	return EZL.StateMachine.selectedMode or false
end

function EZL.SelectFirstItemFromEachQuery()
	if Auctionator_Loaded and PointBlankSniper_Loaded and TSM_Loaded then
		PointBlankSniperTabFrame.ResultsListing.ScrollArea.ScrollBox.ScrollTarget:GetChildren():OnClick()
	end
end

function EZL.RestartPBSScan()
	if Auctionator_Loaded and PointBlankSniper_Loaded and TSM_Loaded then
		if PointBlankSniperTabFrame and PointBlankSniperTabFrame:IsVisible() then
			--EZL.Print.Debug("Check stopped")
			if EZL.PointBlankSniperStopped() then
				--EZL.Print.Debug("Stopped")
				PointBlankSniperTabFrame.StartButton:Click()
			end
		end
	end
end

function EZL.CloseAuctionHouse()
	if isRetail then
		return C_AuctionHouse.CloseAuctionHouse()
	else
		return CloseAuctionHouse() 
	end
end

function EZL.GetSelection()
	return _G.fsmContext.scanFrame:GetElement("auctions"):GetSelection(self)
end

function EZL.SnipeItemFound()
	if Auctionator_Loaded and PointBlankSniper_Loaded and TSM_Loaded then
		if PointBlankSniperTabFrame.ResultsListing.dataProvider.results and #PointBlankSniperTabFrame.ResultsListing.dataProvider.results > 0 then
			return true
		end
	end
	return false
end

function EZL.HandleIdleState()
	EZL.StopMovement()
end

function EZL.PointBlankSniperStopped()
	if PointBlankSniperTabFrame and PointBlankSniperTabFrame:IsVisible() and PointBlankSniperTabFrame.Status then
		local statusText = PointBlankSniperTabFrame.Status:GetText()
		-- Check if statusText contains "Scan stopped"
		if string.find(statusText,"Scan stopped") or statusText == nil then
			return true
		end
	end
	return false
end

local function SimulateClick(button)
	--UpdateLastHardwareAction(GetTime()*1000) -- why is that needed?
	_G[button]:Click()
	--EZL.Print.Info("Pressed: " .. button)
end


function EZL.InitializeAuctionStateCoroutine()
    auctionStateRoutine = coroutine.create(function()
        while true do
			EZL.StopMovement()
			if EZL.IsAuctionHouseFrameVisible() then
				if EZL.inTSMFrame("AUCTION") then
					if _G.InAuctTab() then
						if EZL.IsProgressBarState("Scanning (%d Items)") then
							if not PostScanStarted then
								PostScanStarted = true
							end
						elseif EZL.IsProgressBarState("Posting %d / %d") then
							if not EZL.IsProgressBarState("Confirm") then
								if TSMAuctioningBtn:IsEnabled() then
									--TSMAuctioningBtn:Click()
									SimulateClick("TSMAuctioningBtn")
								end
							else
								-- Add any other functionality here, if required
							end
						elseif EZL.IsProgressBarState("Confirming %d / %d") then
							-- Waiting for confirmation
						elseif not PostScanStarted then
							if TSMPostScanBtn:IsVisible() then
								SimulateClick("TSMPostScanBtn")
								--TSMPostScanBtn:Click("LeftButton")
							end
						end
					else
						_G.OpenAuctTab()
					end
				else
					-- Switch to TSM Tab
					_G.SwitchToTSMTab()
				end
			else
				if EZL.IsNearAuctioneer() then
					EZL.ObjectInteract(EZL.GetObjectWithId(auctioneerInfo.id))
				end
			end
			coroutine.yield()  -- Yielding here
        end
    end)
end

function EZL.InitializeMailProcessCoroutine()
    mailProcessRoutine = coroutine.create(function()
        while true do
			EZL.StopMovement()  

			if MailFrame:IsVisible() or EZL.inTSMFrame("MAILING") then
				if EZL.HasMailsToOpen() then
					if MailFrame:IsVisible() then
						if EZL.HasEmptyMails() then
							EZL.RemoveEmptyMail()
						end

						TSM_OnClickSwitchBtn()
					elseif EZL.inTSMFrame("MAILING") then
						_G.TSMOpenAllMailsBtn:Click()
					end
				end
			else
				if EZL.IsNearMailbox() then
					local mailobject = EZL.GetObjectWithId(mailboxInfo.id,"GameObject")
					if mailobject then
						--EZL.Print.Debug("Interact with Mailbox")
						EZL.ObjectInteract(mailobject)
					end
				end
			end
			coroutine.yield()  -- Yielding here
        end
    end)
end


function EZL.InitializeCancelStateCoroutine()
    cancelStateRoutine = coroutine.create(function()
        while true do
			EZL.StopMovement()
			if EZL.IsAuctionHouseFrameVisible() then
				if EZL.inTSMFrame("AUCTION") then
					if _G.InAuctTab() then
						if EZL.IsProgressBarState("Scanning") then
							if not CancelScanStarted then
								CancelScanStarted = true
							end
						elseif EZL.IsProgressBarState("Canceling %d / %d") then
							if not EZL.CacheVariables.maxCancels then
								EZL.CacheVariables.maxCancels = EZL.DetectMaxCancels() +3
								EZL.CacheVariables.cancels = 0
								EZL.Print.Info("Setting max cancels to: " .. EZL.CacheVariables.maxCancels)
								
							end
							if not EZL.IsProgressBarState("Confirm") then
								EZL.CacheVariables.cancels = EZL.CacheVariables.cancels + 1
								if EZL.CacheVariables.maxCancels and EZL.CacheVariables.cancels >= EZL.CacheVariables.maxCancels then
									EZL.Print.Info("Max cancels reached, stopping cancel scan")
									EZL.StateMachine.hasItemsToCancel = false
								end
								TSMAuctioningBtn:Click()
							else
								-- Add any other functionality here, if required
							end
						elseif not CancelScanStarted then
							TSMCancelScanBtn:Click()
						end
					else
						_G.OpenAuctTab()
					end
				else
					-- Switch to TSM Tab
					_G.SwitchToTSMTab()
				end
			else
				if EZL.IsNearAuctioneer() then
					EZL.ObjectInteract(EZL.GetObjectWithId(auctioneerInfo.id))
				end
			end
			coroutine.yield()  -- Yielding here
        end
    end)
end

local localLanguage = GetLocale()

local LanguageTable = _G.POINT_BLANK_SNIPER_LOCALES and _G.POINT_BLANK_SNIPER_LOCALES[localLanguage]()


local function reactToSnipeButton()
	local buttonText = PointBlankSniperTabFrame.Buy.BuyButton:GetText()
	if buttonText == LanguageTable["BUY_NOW"] then
		PointBlankSniperTabFrame.Buy:BuyNow()		
		lastYieldTime = GetTime() + 1	 -- Hier war 0.3						
	elseif buttonText == LanguageTable["WAITING"] then
		lastYieldTime = GetTime() + 1
		C_Timer.After(0.6, reactToSnipeButton)
	else
		EZL.RestartPBSScan()
	end
	isBuyingSnipe = false
end

function EZL.InitializeSnipeCoroutine()
    snipeRoutine = coroutine.create(function()
        while true do
			if EZL.IsAuctionHouseFrameVisible() then
				if Auctionator_Loaded and PointBlankSniper_Loaded and TSM_Loaded then
					if EZL.inTSMFrame("AUCTION") then
						_G.TSM_SwitchMainFrame()
						coroutine.yield()
					else
						if PointBlankSniperTabFrame and PointBlankSniperTabFrame:IsVisible() then
							if not EZL.PointBlankSniperStopped() then
								if EZL.SnipeItemFound() and not isBuyingSnipe then
									
									isBuyingSnipe = true
									EZL.SelectFirstItemFromEachQuery()
									coroutine.yield() -- Wait for the next frame
									C_Timer.After(0.3, reactToSnipeButton)
								end
							elseif EZL.PointBlankSniperStopped() and not isBuyingSnipe then
								PointBlankSniperTabFrame:StartButtonClicked()
							end
							coroutine.yield() -- Wait for the next frame
						elseif not PointBlankSniperTabFrame or not PointBlankSniperTabFrame:IsVisible() then
							local PBS_TabButton = _G["AuctionatorTabs_Point-Blank Sniper"]
							PBS_TabButton:Click()
						end
					end
				elseif not Auctionator_Loaded then
					EZL.Print.Error("Auctionator is not loaded")
				elseif not PointBlankSniper_Loaded then
					EZL.Print.Error("PointBlankSniper is not loaded")
				elseif not TSM_Loaded then
					EZL.Print.Error("TradeSkillMaster is not loaded")
				end
			else
				if EZL.IsNearAuctioneer() then
					EZL.ObjectInteract(EZL.GetObjectWithId(auctioneerInfo.id))
				end
			end
			lastYieldTime = GetTime()  -- Store the time when the coroutine yields
            coroutine.yield() -- Yielding here
        end
    end)
end

function EZL.UpdateMailProcessCoroutine()
	if lastYieldTime and GetTime() - lastYieldTime >= mailDelay then
        if mailProcessRoutine and coroutine.status(mailProcessRoutine) == "dead" then
            -- Restart the coroutine if it has died.
            EZL.InitializeMailProcessCoroutine()
        end

		if mailProcessRoutine then
			-- Resume the coroutine.
			coroutine.resume(mailProcessRoutine)
		end

		-- Reset the yield time.
		lastYieldTime = GetTime()
	end
end



function EZL.UpdateCancelStateCoroutine()
	if lastYieldTime and GetTime() - lastYieldTime >= cancelDelay then
        if cancelStateRoutine and coroutine.status(cancelStateRoutine) == "dead" then
            -- Restart the coroutine if it has died.
            EZL.InitializeCancelStateCoroutine()
        end

		if cancelStateRoutine then
			-- Resume the coroutine.
			coroutine.resume(cancelStateRoutine)
		end

		-- Reset the yield time.
		lastYieldTime = GetTime()
	end
end

function EZL.UpdateAuctionStateCoroutine()
	if lastYieldTime and GetTime() - lastYieldTime >= auctionDelay then
        if auctionStateRoutine and coroutine.status(auctionStateRoutine) == "dead" then
            -- Restart the coroutine if it has died.
            EZL.InitializeAuctionStateCoroutine()
        end

		if auctionStateRoutine then
			-- Resume the coroutine.
			coroutine.resume(auctionStateRoutine)
		end

		-- Reset the yield time.
		lastYieldTime = GetTime()
	end
end

function EZL.UpdateSnipeCoroutine()
	EZL.StopMovement()
	if lastYieldTime and GetTime() - lastYieldTime >= delay then
        if snipeRoutine and coroutine.status(snipeRoutine) == "dead" then
            -- If the coroutine has died, you might want to restart it.
            EZL.InitializeSnipeCoroutine()
        end

		if snipeRoutine then
			-- This will resume the coroutine from its last `coroutine.yield()` call.
			coroutine.resume(snipeRoutine)
		end

		-- Reset the last yield time
		lastYieldTime = GetTime()
	end
end

function EZL.HandleWaitState()
	EZL.StopMovement()
	local currentTime = GetTime()
	if currentTime < mailTaskBlockedUntil then
		if not WaitingPrint then
			-- Print immediately and set WaitingPrint to true
			local timeLeft = mailTaskBlockedUntil - currentTime
			local minutes = math.ceil(timeLeft / 60)
			
			EZL.Print.System(string.format("Waiting for %d minutes to start again.", minutes))
			
			WaitingPrint = true
			LastPrintTime = GetTime()
			return
		end

		if GetTime() - LastPrintTime >= 60 then
			-- It's been at least 1 minute since the last print
			local timeLeft = mailTaskBlockedUntil -currentTime
			local minutes = math.ceil(timeLeft / 60)	
			EZL.Print.System(string.format("Waiting for %d minutes to start again.", minutes))
			LastPrintTime = GetTime()
		end
	end
end

function EZL.CanRunMailState()
    local currentTime = GetTime()
    if currentTime < mailTaskBlockedUntil then
        return false
    else
        return true
    end
end

function EZL.RepeatLogic()

end

function EZL.ReloadUI()
	UnlockerFuncs[Unlocker].ReloadUI()
end

local function WriteLogFile(...)
	if not EZL.FileSystem.DirectoryExists("/scripts/" .. mainFolder) then        
        EZL.FileSystem.CreateDirectory("/scripts/" .. mainFolder)
    end

	if not EZL.FileSystem.DirectoryExists("/scripts/" .. mainFolder ..  "/" .. logFolder) then        
        EZL.FileSystem.CreateDirectory("/scripts/" .. mainFolder ..  "/" .. logFolder)
	else
		local json = EZL.Helper.JSON.Encode(saveTable)
		EZL.FileSystem.WriteFile("/scripts/" .. mainFolder ..  "/" .. logFolder .. "/" .. UnitGUID("player")..GetTime()..".lua",...,false)
    end
end

function EZL.ErrorEventHandler(self, event, ...)
    if not isRetail then
        return
    end
	local state = EZL.StateMachine.selectedMode
    if event == "AUCTION_HOUSE_SHOW_ERROR" then
        local errorType = select(1, ...)
		local errorMsg = select(2, ...)
        if errorType == Enum.AuctionHouseError.DatabaseError then
			WriteLogFile(errorType,errorMsg)
			EZL.Print.Error("We encounter some Auction House Database Errors. We will reload the UI in 3 seconds to fix the issue.")
            C_Timer.After(3,EZL.ReloadUI)
        end
    elseif event == "AUCTION_HOUSE_POST_ERROR" then
		EZL.Print.Error("We encounter some General Auction House Post Errors. We will reload the UI in 3 seconds to fix the issue.")
		C_Timer.After(3,EZL.ReloadUI)
    end

end

function EZL.InitErrorListener()
	if isRetail then
		local errorListener = CreateFrame("Frame")
		errorListener:RegisterEvent("AUCTION_HOUSE_SHOW_ERROR")
		errorListener:RegisterEvent("AUCTION_HOUSE_POST_ERROR")
		errorListener:SetScript("OnEvent", EZL.ErrorEventHandler)
	end
end

function EZL.AntiAFK()
	UnlockerFuncs[Unlocker].AntiAFK()
end

function EZL.Reset()
	EZL.StateMachine.hasItemsToPost = true
	EZL.StateMachine.hasItemsToCancel = true
	EZL.ResetScans()
	mailTaskBlockedUntil = 0
end

EZL.CacheVariables = {}
function EZL.OnInitStateMachine(startState)
    startState = startState or (EZL.HasMailsToOpen() and "moveToMailbox") or "idle"
	EZL.StateMachine = {
		selectedMode = SelectedMode, 
		state = startState,
		hasItemsToPost = true,
		hasItemsToCancel = true,
		states = {
			idle = {
				enter = function(self)
					EZL.ResetScans()
					EZL.UI.SetState("Idle")
				end,
				execute = EZL.HandleIdleState,
				transitions = {
					{name = "moveToMailbox", func = function() return EZL.CanRunMailState() and EZL.HasMailsToOpen() and (EZL.GetNumFreeBagSpace() > 0) end},
					{name = "moveToAuctioneer", func = function(self)
						return (BotModes.Sliders.name == self.selectedMode and self.hasItemsToPost) or
						(BotModes.autoCancel.name == self.selectedMode and self.hasItemsToCancel) or
						(BotModes.autoSnipe.name == self.selectedMode and not EZL.HasMailsToOpen()) or
						(BotModes.fullAuto.name == self.selectedMode and not EZL.HasMailsToOpen())
					end },
					{name = "wait", func = function(self) return (not self.hasItemsToPost or not self.hasItemsToCancel) and not EZL.HasMailsToOpen() and EZL.CanRunMailState() end },
				},
			},
			wait = {
				enter = function(self)
					WaitingPrint = false
					mailTaskBlockedUntil = GetTime() + (waitXMinutes * 60)
					EZL.UI.SetState("Waiting")
				end,
				execute = function(self) EZL.HandleWaitState() end,
				transitions = {
					{name = "idle", func = function(self) return EZL.CanRunMailState() end},
				},
				generalPreTransitionAction = function() WaitingPrint = false end,
			},
			moveToMailbox = {
				enter = function(self)
					EZL.UI.SetState("[MT]Mailbox")
				end,
				execute = function(self)
					EZL.MoveToMailbox()
				end,
				transitions = {
					{name = "mail", func = function(self) return EZL.IsNearMailbox() and EZL.HasMailsToOpen() and EZL.CanRunMailState() and (EZL.GetNumFreeBagSpace() > 0) end},
					{name = "moveToAuctioneer", func = function(self) return (not EZL.HasMailsToOpen()) or (EZL.GetNumFreeBagSpace() == 0) end},
				}
			},
			mail = {
				enter = function(self)
					EZL.StopMovement()
					EZL.ResetScans()
					EZL.UI.SetState("Mailing")
					self.hasItemsToPost = true
				end,
				execute = EZL.UpdateMailProcessCoroutine,
				transitions = {
					{name = "moveToMailbox", func = function() return not EZL.IsNearMailbox() end}, -- Fallback if we move away from Mailbox
					{name = "moveToAuctioneer", func = function(self) return (not EZL.HasMailsToOpen() and not EZL.HasItemsToPickUp()) or (EZL.GetNumFreeBagSpace() == 0) end},
				},
				generalPreTransitionAction = function()
					CloseMail()
				end,
			},
			moveToAuctioneer = {
				enter = function(self)
					EZL.UI.SetState("[MT]Auctioneer")
				end,
				execute = function(self)
					EZL.MoveToAuctioneer()
				end,
				transitions = {
					{name = "auction", func = function(self)
						if self.selectedMode == BotModes.Sliders.name or self.selectedMode == BotModes.fullAuto.name then
							return EZL.IsNearAuctioneer() and self.hasItemsToPost
						end
						return false
					end},
					{name = "cancel", func = function(self)
						if self.selectedMode == BotModes.autoCancel.name or self.selectedMode == BotModes.fullAuto.name then
							return (EZL.IsNearAuctioneer() and self.hasItemsToCancel) or (not isRetail and not self.hasItemsToPost)
						end
						return false
					end },
					{name = "snipe", func = function(self)
						if self.selectedMode == BotModes.autoSnipe.name or self.selectedMode == BotModes.fullAuto.name and isRetail then
							return EZL.IsNearAuctioneer()
						end
						return false
					end},
					{name = "wait", func = function(self) 
						if not self.selectedMode == BotModes.fullAuto.name then
							return (not (self.hasItemsToPost or self.hasItemsToCancel)) and EZL.IsNearAuctioneer()
						end
					end},
				},
			},
			auction = {
				enter = function(self)
					EZL.StopMovement()
					EZL.ResetScans()
					EZL.UI.SetState("Auctioning")
				end,
				execute = EZL.UpdateAuctionStateCoroutine,
				transitions = {
					{name = "moveToAuctioneer", func = function(self) return not EZL.IsNearAuctioneer() end},
					{name = "cancel", func = function(self)
						if (self.selectedMode == BotModes.fullAuto.name) then
							return (EZL.IsAuctionHouseFrameVisible() and EZL.IsProgressBarState("Done Posting"))
						end
						return false
					end},
					{name = "wait", func = function(self) 
						if not (self.selectedMode == BotModes.fullAuto.name) then
							return (EZL.IsAuctionHouseFrameVisible() and EZL.IsProgressBarState("Done Posting"))
						end
					end},

				},
				generalPreTransitionAction = function(self) 			
					EZL.CloseAuctionHouse()
					self.hasItemsToPost= false
				end
			},
			cancel = {
				enter = function(self)
					EZL.CacheVariables.cancels = nil
					EZL.CacheVariables.maxCancels = nil
					EZL.UI.SetState("Cancel")
					self.hasItemsToPost = true
				end,
				execute = EZL.UpdateCancelStateCoroutine,
				transitions = {
					{name = "moveToAuctioneer", func = function(self) 
						return not EZL.IsNearAuctioneer()
					end},
					{name = "snipe", func = function(self)
						if self.selectedMode == BotModes.fullAuto.name and Auctionator_Loaded and PointBlankSniper_Loaded and isRetail then
							return EZL.IsAuctionHouseFrameVisible() and not EZL.IsProgressBarState("Done Canceling") and not self.hasItemsToPost or (not self.hasItemsToCancel) 
						end
						return false
					end},
					{name = "wait", func = function(self) return (EZL.IsAuctionHouseFrameVisible() and EZL.IsProgressBarState("Done Canceling")) end},
				},
				generalPreTransitionAction = function(self) 
					EZL.CloseAuctionHouse()
					self.hasItemsToCancel= false
				end
			},
			snipe = {
				enter = function(self)
					EZL.UI.SetState("Snipe")
					self.hasItemsToCancel = true
					if isRetail then
						sniperScanTime = GetTime() + (snipeForXMinutes * 60)
						EZL.Print.System("Sniping for "..snipeForXMinutes.." minutes")
					end					
				end,
				execute = EZL.UpdateSnipeCoroutine,
				transitions = {
					{name = "wait", func = function(self) return not isRetail end},
					{name = "moveToAuctioneer", func = function(self) return not EZL.IsNearAuctioneer() end},
					{name = "wait", func = function(self) return sniperScanTime < GetTime() end},
					{name = "moveToMailbox", func = function(self) return EZL.HasMailsToOpen() and EZL:CanRunMailState() and sniperScanTime < GetTime() and (EZL.GetNumFreeBagSpace() > 0) end},
					{name = "cancel", func = function(self)
						if (self.selectedMode == BotModes.fullAuto.name) then
							return (EZL.IsAuctionHouseFrameVisible() and EZL.IsProgressBarState("Done Posting")) and not EZL.HasMailsToOpen()
						end
						return false
					end},
				},
				generalPreTransitionAction = function() 
					EZL.CloseAuctionHouse()
				end
			},
		},
		update = function(self)
			-- Get the current state object based on the state name
			local currentState = self.states[self.state]
			--EZL.Print.Debug("Current State: "..self.state)
			-- Execute the behavior associated with the current state
			if currentState.execute then
				currentState.execute(self)
			end

			---------------------------------
			-- Prepare the automatic Reload
			---------------------------------
			if not reloadTimer then
				reloadTimer = GetTime() + (reloadXMinutes * 60)
				EZL.Print.System("Reloading UI in "..reloadXMinutes.." minutes")
				if not AutoLoad then
					EZL.Print.System("Auto Load is disabled. Bot will not automatically restart after reload.")
				end
			else
				if reloadTimer < GetTime() then
					EZL.Print.System("Reloading UI")
					C_Timer.After(3,function()
						EZL.ReloadUI()
					end)
				end
			end

			if currentState.transitions then
				-- Check for possible transitions from the current state
				for _, transition in ipairs(currentState.transitions) do
					-- If a transition condition is met
					if transition.func(self) then
						EZ_Path = nil
						-- If an 'exit' behavior is defined for the current state, execute it
						if currentState.exit then
							currentState.exit(self)
						end

						-- Execute general pre-transition action for the current state
						if currentState.generalPreTransitionAction then
							currentState.generalPreTransitionAction(self)
						end

						-- Execute specific pre-transition action if it exists
						if currentState.preTransitionActions and currentState.preTransitionActions[transition.name] then
							currentState.preTransitionActions[transition.name](self)
						end

						-- Update to the new state
						self.state = transition.name

						-- If an 'enter' behavior is defined for the new state, execute it
						if self.states[self.state].enter then
							self.states[self.state].enter(self)
						end

						
						-- Break out of the loop after the first valid transition is taken
						break
					end
				end
			end
		end
	}
end

function EZL.UpdateMode()
	if SelectedMode ~= "NA" then
		
		Launcher.StateDisplay.ModeDropdown.Label:SetText("|cffffffff" .. SelectedMode .. "|r")
	end
	EZL.StateMachine.selectedMode = SelectedMode
end

function EZL.OnUpdate()
    if not EZ_Running or not TSM_Loaded then return end
	if TSM_Loaded then
		EZL.StateMachine:update()
		C_Timer.After(TickerRate,function()
			EZL.OnUpdate()
		end)
	else
		EZL.Print.Warning("Install TradeSkillMaster to use this Bot")
	end
end

function EZL.UI.Init()
	Launcher:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	Launcher:EnableMouse(true)
	Launcher:SetMovable(true)
	Launcher:SetFrameStrata("FULLSCREEN_DIALOG")
	Launcher:SetFrameLevel(350)
	Launcher:SetWidth(LauncherWidth_Start)
	Launcher:SetHeight(HeaderHeight)
	Launcher:SetBackdrop(PaneBackdrop)
	Launcher:SetBackdropColor(0, 0, 0, 0)
	Launcher:SetScript("OnMouseDown", function(self) Launcher:StartMoving() end)
	Launcher:SetScript("OnMouseUp", function(self) Launcher:StopMovingOrSizing() end)

	Launcher.StateDisplay = CreateFrame("Frame", nil, Launcher, "BackdropTemplate")
	Launcher.StateDisplay:SetHeight(StateDisplayHeight)
	Launcher.StateDisplay:SetWidth(StateDisplayWidth_Start)
	Launcher.StateDisplay:SetPoint("BOTTOMLEFT", Launcher, "TOPLEFT", 0, -5)
	Launcher.StateDisplay:SetBackdrop(PaneBackdrop)
	Launcher.StateDisplay:SetBackdropColor(EZL.Helper.HexToRGBA(Color_DarkGray, 0.9))
	Launcher.StateDisplay:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray))

	Launcher.Content = CreateFrame("Frame", nil, Launcher, "BackdropTemplate")
	Launcher.Content:SetFrameLevel(350)
	Launcher.Content:SetWidth(200)
	Launcher.Content:SetHeight(ContentHeight_Start)
	Launcher.Content:SetPoint("TOPLEFT", Launcher, "BOTTOMLEFT", 0, 0)
	Launcher.Content:SetPoint("TOPRIGHT", Launcher, "BOTTOMRIGHT", 0, 0)
	Launcher.Content:SetBackdrop(PaneBackdrop)
	Launcher.Content:SetBackdropColor(EZL.Helper.HexToRGBA(Color_White, 1))
	Launcher.Content:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray))

	Launcher.Header = CreateFrame("Frame", nil, Launcher, "BackdropTemplate")
	Launcher.Header:SetFrameLevel(Launcher.StateDisplay:GetFrameLevel() + 1)
	Launcher.Header:SetHeight(30)
	Launcher.Header:SetWidth(LauncherWidth_Start)
	Launcher.Header:SetPoint("CENTER", Launcher, 0, 0)
	Launcher.Header:SetBackdrop(PaneBackdrop)
	Launcher.Header:SetBackdropColor(EZL.Helper.HexToRGBA(Color_White, 1))
	Launcher.Header:SetScript("OnMouseDown", function(self) Launcher:StartMoving() end)
	Launcher.Header:SetScript("OnMouseUp", function(self) Launcher:StopMovingOrSizing() end)
	Launcher.Header:SetAlpha(1)

	Launcher.Header.Label = Launcher.Header:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
	Launcher.Header.Label:SetPoint("CENTER", 0, 1)
	Launcher.Header.Label:SetFont("Fonts\\2002B.ttf", 13)
	Launcher.Header.Label:SetTextColor(EZL.Helper.HexToRGBA(Color_DarkGray))
	Launcher.Header.Label:SetText("EAZY-AH")

	Launcher.CloseButton = CreateFrame("Button", nil, Launcher, "BackdropTemplate")
	Launcher.CloseButton:SetFrameLevel(Launcher.Header:GetFrameLevel() + 1)
	Launcher.CloseButton:SetWidth(20)
	Launcher.CloseButton:SetHeight(20)
	Launcher.CloseButton:SetPoint("TOPRIGHT", Launcher, "TOPRIGHT", -5, -5)
	Launcher.CloseButton:SetBackdrop(PaneBackdrop)
	Launcher.CloseButton:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightRed))
	Launcher.CloseButton:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_DarkGray))
	Launcher.CloseButton:SetScript("OnEnter", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Red)) end)
	Launcher.CloseButton:SetScript("OnLeave", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightRed)) end)
	Launcher.CloseButton:SetScript("OnClick", function(self)
		if changingAlpha or changingSize then
			return
		end
		PlaySound(822)
		Launcher.Sliders.Frame:Hide()
		Launcher.Gen.Frame:Hide()
		EZL.UI.ChangeAlpha(Launcher.Content.StartButton, 0, 0.05)
		EZL.UI.ChangeAlpha(Launcher.Content.StopButton, 0, 0.05)
		EZL.UI.ChangeAlpha(Launcher.Content.Gen, 0, 0.05)
		EZL.UI.ChangeAlpha(Launcher.Content.SlideButton, 0, 0.05)

		EZL.UI.ChangeSize(Launcher.Content, 0, 0, 0.2, 0)
		EZL.UI.ChangeSize(Launcher.Header, LauncherWidth_Start, HeaderHeight, 0.1, 0.1)
		EZL.UI.ChangeSize(Launcher, LauncherWidth_Start, HeaderHeight, 0.1, 0.1)
		EZL.UI.ChangeSize(Launcher.StateDisplay, StateDisplayWidth_Start, StateDisplayHeight, 0.1, 0.1)
		EZL.UI.ChangeSize(Launcher.StateDisplay.ModeDropdown, StateDisplayWidth_Start - 10 , 20, 0.1, 0.1)
	end)

	Launcher.CloseButton.Label = Launcher.CloseButton:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
	Launcher.CloseButton.Label:SetPoint("CENTER", 0.85, 1)
	Launcher.CloseButton.Label:SetFont("Fonts\\2002B.ttf", 13)
	Launcher.CloseButton.Label:SetText("|cffffffffx")

	Launcher.OpenButton = CreateFrame("Button", nil, Launcher, "BackdropTemplate")
	Launcher.OpenButton:SetFrameLevel(Launcher.Header:GetFrameLevel() + 1)
	Launcher.OpenButton:SetWidth(20)
	Launcher.OpenButton:SetHeight(20)
	Launcher.OpenButton:SetPoint("TOPLEFT", Launcher, "TOPLEFT", 5, -5)
	Launcher.OpenButton:SetBackdrop(PaneBackdrop)
	Launcher.OpenButton:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.OpenButton:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.OpenButton:SetScript("OnEnter", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGreen)) end)
	Launcher.OpenButton:SetScript("OnLeave", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green)) end)
	Launcher.OpenButton:SetScript("OnClick", function(self)
		if changingAlpha or changingSize then
			return
		end
		PlaySound(821)
		EZL.UI.ChangeSize(Launcher, LauncherWidth_Final, HeaderHeight, 0.1, 0)
		EZL.UI.ChangeSize(Launcher.Header, LauncherWidth_Final, HeaderHeight, 0.1, 0)
		EZL.UI.ChangeSize(Launcher.StateDisplay, StateDisplayWidth_Final, StateDisplayHeight, 0.1, 0)
		EZL.UI.ChangeSize(Launcher.StateDisplay.ModeDropdown, StateDisplayWidth_Final - 10 , 20, 0.1, 0)
		EZL.UI.ChangeSize(Launcher.Content, LauncherWidth_Final, ContentHeight_Final, 0.2, 0)

		EZL.UI.ChangeAlpha(Launcher.Content.StartButton, 1, 0.3, 0)
		EZL.UI.ChangeAlpha(Launcher.Content.StopButton, 1, 0.3, 0)
		EZL.UI.ChangeAlpha(Launcher.Content.Gen, 1, 0.3, 0)
		EZL.UI.ChangeAlpha(Launcher.Content.SlideButton, 1, 0.3, 0)
		
	end)


	Launcher.OpenButton.Label = Launcher.OpenButton:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
	Launcher.OpenButton.Label:SetPoint("CENTER", 0, 1)
	Launcher.OpenButton.Label:SetFont("Fonts\\2002B.ttf", 13)
	Launcher.OpenButton.Label:SetText("|cffffffffo")

	-- State Display
	Launcher.StateDisplay.StateLabel = Launcher.StateDisplay:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
	Launcher.StateDisplay.StateLabel:SetPoint("TOPLEFT", 5, -5)
	Launcher.StateDisplay.StateLabel:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.StateDisplay.StateLabel:SetText("|cffffffffState: " .. "|cffff0000Stopped")

	Launcher.StateDisplay.ModeDropdown = CreateFrame("Button", "EZL_ModeDropdown", Launcher.StateDisplay, "BackdropTemplate")
	Launcher.StateDisplay.ModeDropdown:SetPoint("BOTTOMLEFT", Launcher.StateDisplay, "BOTTOMLEFT", 5, 12)
	Launcher.StateDisplay.ModeDropdown:SetWidth(Launcher.StateDisplay:GetWidth() - 10)
	Launcher.StateDisplay.ModeDropdown:SetHeight(22) 
	Launcher.StateDisplay.ModeDropdown:SetBackdrop(PaneBackdrop)
	Launcher.StateDisplay.ModeDropdown:SetBackdropColor(EZL.Helper.HexToRGBA(Color_White,0.2))
	Launcher.StateDisplay.ModeDropdown:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray))

	Launcher.StateDisplay.ModeDropdown.Label = Launcher.StateDisplay.ModeDropdown:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
	Launcher.StateDisplay.ModeDropdown.Label:SetPoint("CENTER", 0, 1)
	Launcher.StateDisplay.ModeDropdown.Label:SetFont("Fonts\\2002B.ttf", 13)
	Launcher.StateDisplay.ModeDropdown.Label:SetText("|cffffffffSelect Mode")

	Launcher.StateDisplay.ModeDropdown.Menu = CreateFrame("Frame", "EZL_ModeDropdownMenu", Launcher.StateDisplay, "BackdropTemplate")
	Launcher.StateDisplay.ModeDropdown.Menu:SetPoint("BOTTOMRIGHT", Launcher.StateDisplay.ModeDropdown, "BOTTOMLEFT", -5, 0)
	Launcher.StateDisplay.ModeDropdown.Menu:SetWidth(115)
	Launcher.StateDisplay.ModeDropdown.Menu:SetHeight(EZL.Helper.TableCount(BotModes)*22-22)
	Launcher.StateDisplay.ModeDropdown.Menu:SetBackdrop(PaneBackdrop)
	Launcher.StateDisplay.ModeDropdown.Menu:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.StateDisplay.ModeDropdown.Menu:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.StateDisplay.ModeDropdown.Menu:Hide()

	local modesCounter = 0
	for mode, table in pairs(BotModes) do
		if mode == "autoSnipe" and not isRetail then
			
		else
			modesCounter = modesCounter + 1
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter] = CreateFrame("Button", nil, Launcher.StateDisplay.ModeDropdown.Menu, "BackdropTemplate")
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter]:SetFrameLevel(Launcher.StateDisplay:GetFrameLevel()+500)
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter]:SetWidth(115)
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter]:SetHeight(22)
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter]:SetPoint("BOTTOMLEFT", Launcher.StateDisplay.ModeDropdown.Menu[modesCounter - 1] or Launcher.StateDisplay.ModeDropdown.Menu, "TOPLEFT", 0,0)
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter]:SetBackdrop(PaneBackdrop)
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter]:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray,1))
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter]:SetBackdropColor(EZL.Helper.HexToRGBA(Color_White,1))
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter]:SetScript("OnEnter", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray,1)) end)
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter]:SetScript("OnLeave", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_White,1)) end)
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter]:SetScript("OnClick", function(self) 
				PlaySound(798)
				EZL.StateMachine.selectedMode = table.name
				EZL.StateMachine.state = "idle"
				Launcher.StateDisplay.ModeDropdown.Label:SetText("|cffffffff" .. table.name .. "|r")
				Launcher.StateDisplay.ModeDropdown.Menu:Hide()
				EZL.Reset()
				EZL.SaveSettings()
			end)

			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter].Label = Launcher.StateDisplay.ModeDropdown.Menu[modesCounter]:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter].Label:SetPoint("CENTER", 0, 1)
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter].Label:SetFont("Fonts\\2002B.ttf", 12)
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter].Label:SetText(table.name)
			Launcher.StateDisplay.ModeDropdown.Menu[modesCounter].Label:SetTextColor(EZL.Helper.HexToRGBA(Color_DarkGray))
		end
	end

	Launcher.StateDisplay.ModeDropdown:SetScript("OnClick", function(self)
		if Launcher.StateDisplay.ModeDropdown.Menu:IsVisible() then
			Launcher.StateDisplay.ModeDropdown.Menu:Hide()
			Launcher.StateDisplay.ModeDropdown.Label:SetText("|cffffffff".. SelectedMode)
		else
			Launcher.StateDisplay.ModeDropdown.Menu:Show()
			Launcher.StateDisplay.ModeDropdown.Label:SetText("|cffffffffClose")
		end
	end)
	Launcher.StateDisplay.ModeDropdown:SetScript("OnEnter",function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_White,0.5)) end)
	Launcher.StateDisplay.ModeDropdown:SetScript("OnLeave",function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_White,0.2)) end)

	-- Start Button
	Launcher.Content.StartButton = CreateFrame("Button", nil, Launcher.Content, "BackdropTemplate")
	Launcher.Content.StartButton:SetFrameLevel(Launcher.Content:GetFrameLevel() + 1)
	Launcher.Content.StartButton:SetWidth(80)
	Launcher.Content.StartButton:SetHeight(30)
	Launcher.Content.StartButton:SetPoint("TOPLEFT", Launcher.Content, "TOPLEFT", 5, -5)
	Launcher.Content.StartButton:SetBackdrop(PaneBackdrop)
	Launcher.Content.StartButton:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Content.StartButton:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Content.StartButton:SetAlpha(0)
	Launcher.Content.StartButton:SetScript("OnEnter", function(self)
		if EZL.IsMailboxSet() and EZL.IsAuctioneerSet() and not EZ_Running then
			self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGreen))
		else
			self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
		end
	end)
	Launcher.Content.StartButton:SetScript("OnLeave", function(self)
		if EZ_Running then
			self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
		elseif EZL.IsMailboxSet() and EZL.IsAuctioneerSet() then
			self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green))
		else
			self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
		end
	end)
	
	Launcher.Content.StartButton:SetScript("OnClick", function(self)
		PlaySound(798)
		EZL.UI.OnStart()
	end)

	Launcher.Content.StartButton.Label = Launcher.Content.StartButton:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Content.StartButton.Label:SetPoint("CENTER", 0, 1)
	Launcher.Content.StartButton.Label:SetFont("Fonts\\2002B.ttf", 13)
	Launcher.Content.StartButton.Label:SetText("|cffffffffSTART")

	-- Stop Button
	Launcher.Content.StopButton = CreateFrame("Button", nil, Launcher.Content, "BackdropTemplate")
	Launcher.Content.StopButton:SetFrameLevel(Launcher.Content:GetFrameLevel() + 1)
	Launcher.Content.StopButton:SetWidth(80)
	Launcher.Content.StopButton:SetHeight(30)
	Launcher.Content.StopButton:SetPoint("TOPRIGHT", Launcher.Content, "TOPRIGHT", -5, -5)
	Launcher.Content.StopButton:SetBackdrop(PaneBackdrop)
	Launcher.Content.StopButton:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Content.StopButton:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Content.StopButton:SetAlpha(0)
	Launcher.Content.StopButton:SetScript("OnEnter", function(self)
		if EZ_Running then
			self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightRed))
		else
			self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
		end
	end)
	Launcher.Content.StopButton:SetScript("OnLeave", function(self)
		if EZ_Running then
			self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Red))
		else
			self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
		end
	end)
	Launcher.Content.StopButton:SetScript("OnClick", function(self)
		PlaySound(798)
		EZL.UI.OnStop()
	end)

	Launcher.Content.StopButton.Label = Launcher.Content.StopButton:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Content.StopButton.Label:SetPoint("CENTER", 0, 1)
	Launcher.Content.StopButton.Label:SetFont("Fonts\\2002B.ttf", 13)
	Launcher.Content.StopButton.Label:SetText("|cffffffffSTOP")

	Launcher.Content.Gen = CreateFrame("Button", nil, Launcher.Content, "BackdropTemplate")
	Launcher.Content.Gen:SetFrameLevel(Launcher.Content:GetFrameLevel()+1)
	Launcher.Content.Gen:SetWidth(80)
	Launcher.Content.Gen:SetHeight(30)
	Launcher.Content.Gen:SetPoint("TOPLEFT", Launcher.Content, "TOPLEFT", 5, -40)
	Launcher.Content.Gen:SetBackdrop(PaneBackdrop)
	Launcher.Content.Gen:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Content.Gen:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Content.Gen:SetAlpha(0)
	Launcher.Content.Gen:SetScript("OnEnter", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGreen)) end)
	Launcher.Content.Gen:SetScript("OnLeave", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green)) end)
	Launcher.Content.Gen:SetScript("OnClick", function(self) 
		PlaySound(798)
		if Launcher.Gen.Frame:IsVisible() then
			Launcher.Gen.Frame:Hide()
		else
			Launcher.Gen.Frame:Show()
		end
		if Launcher.Sliders.Frame:IsVisible() then
			Launcher.Sliders.Frame:Hide()
		end
	end)

	Launcher.Content.Gen.Label = Launcher.Content.Gen:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
	Launcher.Content.Gen.Label:SetPoint("CENTER", 0, 1)
	Launcher.Content.Gen.Label:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.Content.Gen.Label:SetText("|cffffffffGeneral")

	Launcher.Content.SlideButton = CreateFrame("Button", nil, Launcher.Content, "BackdropTemplate")
	Launcher.Content.SlideButton:SetFrameLevel(Launcher.Content:GetFrameLevel() + 1)
	Launcher.Content.SlideButton:SetWidth(80)
	Launcher.Content.SlideButton:SetHeight(30)
	Launcher.Content.SlideButton:SetPoint("TOPRIGHT", Launcher.Content, "TOPRIGHT", -5, -40)
	Launcher.Content.SlideButton:SetBackdrop(PaneBackdrop)
	Launcher.Content.SlideButton:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Content.SlideButton:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Content.SlideButton:SetAlpha(0)
	Launcher.Content.SlideButton:SetScript("OnEnter", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGreen)) end)
	Launcher.Content.SlideButton:SetScript("OnLeave", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green)) end)
	Launcher.Content.SlideButton:SetScript("OnClick", function(self) 
		PlaySound(798)
		if Launcher.Sliders.Frame:IsVisible() then
			Launcher.Sliders.Frame:Hide()
		else
			Launcher.Sliders.Frame:Show()
		end
		if Launcher.Gen.Frame:IsVisible() then
			Launcher.Gen.Frame:Hide()
		end
	end)

	Launcher.Content.SlideButton.Label = Launcher.Content.SlideButton:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Content.SlideButton.Label:SetPoint("CENTER", 0, 1)
	Launcher.Content.SlideButton.Label:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.Content.SlideButton.Label:SetText("|cffffffffSlider")
	------------------
	-- Options
	------------------
	Launcher.Gen = {}

	local AH_Group_Height = 80
	local AH_Group_Width = 170

	local Mail_Group_Height = 50
	local Mail_Group_Width = 170

	local Setting_Group_Height = 50
	local Setting_Group_Width = 170

	local Gen_Height = 5 + AH_Group_Height + 5 + Mail_Group_Height + 5 + Setting_Group_Height + 5

	Launcher.Gen.Frame = CreateFrame("Frame", nil, Launcher.Content, "BackdropTemplate")
	Launcher.Gen.Frame:SetPoint("TOPLEFT", Launcher.Content, "BOTTOMLEFT", 0, 0)
	Launcher.Gen.Frame:SetFrameLevel(Launcher.Content:GetFrameLevel() + 1)
	Launcher.Gen.Frame:SetWidth(LauncherWidth_Final)
	Launcher.Gen.Frame:SetHeight(Gen_Height)
	Launcher.Gen.Frame:SetBackdrop(PaneBackdrop)
	Launcher.Gen.Frame:SetBackdropColor(EZL.Helper.HexToRGBA(Color_White))
	Launcher.Gen.Frame:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_White))
	Launcher.Gen.Frame:Hide()

	Launcher.Gen.AH_Group = CreateFrame("Frame", nil, Launcher.Gen.Frame, "BackdropTemplate")
	Launcher.Gen.AH_Group:SetPoint("TOPLEFT", Launcher.Gen.Frame, "TOPLEFT", 5, -5)
	Launcher.Gen.AH_Group:SetFrameLevel(Launcher.Gen.Frame:GetFrameLevel() + 1)
	Launcher.Gen.AH_Group:SetWidth(AH_Group_Width)
	Launcher.Gen.AH_Group:SetHeight(AH_Group_Height)
	Launcher.Gen.AH_Group:SetBackdrop(PaneBackdrop)
	Launcher.Gen.AH_Group:SetBackdropColor(EZL.Helper.HexToRGBA(Color_DarkGray, 0.3))
	Launcher.Gen.AH_Group:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_Green))

	Launcher.Gen.AH_Group.Label = Launcher.Gen.AH_Group:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
	Launcher.Gen.AH_Group.Label:SetPoint("TOPLEFT", 5, -5)
	Launcher.Gen.AH_Group.Label:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.Gen.AH_Group.Label:SetText("Auction House Settings")

	Launcher.Gen.AH_Group.SetNPC = CreateFrame("Button", nil, Launcher.Gen.AH_Group, "BackdropTemplate")
	Launcher.Gen.AH_Group.SetNPC:SetFrameLevel(Launcher.Gen.AH_Group:GetFrameLevel() + 1)
	Launcher.Gen.AH_Group.SetNPC:SetWidth(LauncherWidth_Final - 75)
	Launcher.Gen.AH_Group.SetNPC:SetHeight(25)
	Launcher.Gen.AH_Group.SetNPC:SetPoint("TOPLEFT", Launcher.Gen.AH_Group, "TOPLEFT", 5, -20)
	Launcher.Gen.AH_Group.SetNPC:SetBackdrop(PaneBackdrop)
	Launcher.Gen.AH_Group.SetNPC:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Gen.AH_Group.SetNPC:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Gen.AH_Group.SetNPC:SetScript("OnEnter", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGreen)) end)
	Launcher.Gen.AH_Group.SetNPC:SetScript("OnLeave", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green)) end)
	Launcher.Gen.AH_Group.SetNPC:SetScript("OnClick", function()
		PlaySound(798)
		EZL.SetAuctioneer()
		EZL.UI.UpdateSates()
	end)

	Launcher.Gen.AH_Group.SetNPC.Label = Launcher.Gen.AH_Group.SetNPC:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Gen.AH_Group.SetNPC.Label:SetPoint("CENTER", 0, 1)
	Launcher.Gen.AH_Group.SetNPC.Label:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.Gen.AH_Group.SetNPC.Label:SetText("|cffffffffSet AH NPCs")

	Launcher.Gen.AH_Group.IsAHNPCSet = Launcher.Gen.AH_Group:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
	Launcher.Gen.AH_Group.IsAHNPCSet:SetPoint("TOPLEFT", Launcher.Gen.AH_Group.SetNPC, "TOPRIGHT", 5, -8)
	Launcher.Gen.AH_Group.IsAHNPCSet:SetFont("Fonts\\Arial.ttf", 13)
	Launcher.Gen.AH_Group.IsAHNPCSet:SetText("|cffFF0000Not Set")

	Launcher.Gen.AH_Group.SetNPCPosition = CreateFrame("Button", nil, Launcher.Gen.AH_Group, "BackdropTemplate")
	Launcher.Gen.AH_Group.SetNPCPosition:SetFrameLevel(Launcher.Gen.AH_Group:GetFrameLevel() + 1)
	Launcher.Gen.AH_Group.SetNPCPosition:SetWidth(LauncherWidth_Final - 20)
	Launcher.Gen.AH_Group.SetNPCPosition:SetHeight(25)
	Launcher.Gen.AH_Group.SetNPCPosition:SetPoint("TOPLEFT", Launcher.Gen.AH_Group.SetNPC, "BOTTOMLEFT", 0, -5)
	Launcher.Gen.AH_Group.SetNPCPosition:SetBackdrop(PaneBackdrop)
	Launcher.Gen.AH_Group.SetNPCPosition:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Gen.AH_Group.SetNPCPosition:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Gen.AH_Group.SetNPCPosition:SetScript("OnEnter", function(self) 
		self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGreen)) 
		Launcher.Gen.AH_Group.SetNPCPosition.Tooltip:Show()
	end)
	Launcher.Gen.AH_Group.SetNPCPosition:SetScript("OnLeave", function(self) 
		self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green)) 
		Launcher.Gen.AH_Group.SetNPCPosition.Tooltip:Hide()
	end)
	Launcher.Gen.AH_Group.SetNPCPosition:SetScript("OnClick", function()
		PlaySound(798)
		EZL.SetPlayerPosAsAHPos()
		EZL.UI.UpdateSates()
	end)

	Launcher.Gen.AH_Group.SetNPCPosition.Label = Launcher.Gen.AH_Group.SetNPCPosition:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Gen.AH_Group.SetNPCPosition.Label:SetPoint("CENTER", 0, 1)
	Launcher.Gen.AH_Group.SetNPCPosition.Label:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.Gen.AH_Group.SetNPCPosition.Label:SetText("|cffffffffSet new AH Position")

	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip = CreateFrame("Frame", nil, Launcher.Gen.AH_Group.SetNPCPosition, "BackdropTemplate")
	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip:SetFrameLevel(Launcher.Gen.AH_Group:GetFrameLevel() + 5)
	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip:SetWidth(350)
	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip:SetHeight(35)
	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip:SetPoint("TOPLEFT", Launcher.Gen.AH_Group.SetNPCPosition, "BOTTOMLEFT", 0, -5)
	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip:SetBackdrop(PaneBackdrop)
	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip:SetBackdropColor(EZL.Helper.HexToRGBA(Color_DarkGray))
	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_White))
	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip:Hide()

	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip.Label = Launcher.Gen.AH_Group.SetNPCPosition.Tooltip:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip.Label:SetPoint("CENTER", 0, 1)
	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip.Label:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.Gen.AH_Group.SetNPCPosition.Tooltip.Label:SetText("|cffffffffSet the PlayerPosition as the AH Position. \nCan be useful if the Unlocker Path seems to be buggy.")

	Launcher.Gen.Mail_Group = CreateFrame("Frame", nil, Launcher.Gen.Frame, "BackdropTemplate")
	Launcher.Gen.Mail_Group:SetPoint("TOPLEFT", Launcher.Gen.AH_Group, "BOTTOMLEFT", 0, -5)
	Launcher.Gen.Mail_Group:SetFrameLevel(Launcher.Gen.Frame:GetFrameLevel() + 1)
	Launcher.Gen.Mail_Group:SetWidth(Mail_Group_Width)
	Launcher.Gen.Mail_Group:SetHeight(Mail_Group_Height)
	Launcher.Gen.Mail_Group:SetBackdrop(PaneBackdrop)
	Launcher.Gen.Mail_Group:SetBackdropColor(EZL.Helper.HexToRGBA(Color_DarkGray, 0.3))
	Launcher.Gen.Mail_Group:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_Green))

	Launcher.Gen.Mail_Group.Label = Launcher.Gen.Mail_Group:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
	Launcher.Gen.Mail_Group.Label:SetPoint("TOPLEFT", 5, -5)
	Launcher.Gen.Mail_Group.Label:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.Gen.Mail_Group.Label:SetText("Mailbox Settings")

	Launcher.Gen.Mail_Group.SetMailbox = CreateFrame("Button", nil, Launcher.Gen.Mail_Group, "BackdropTemplate")
	Launcher.Gen.Mail_Group.SetMailbox:SetFrameLevel(Launcher.Gen.Mail_Group:GetFrameLevel() + 1)
	Launcher.Gen.Mail_Group.SetMailbox:SetWidth(LauncherWidth_Final - 75)
	Launcher.Gen.Mail_Group.SetMailbox:SetHeight(25)
	Launcher.Gen.Mail_Group.SetMailbox:SetPoint("TOPLEFT", Launcher.Gen.Mail_Group, "TOPLEFT", 5, -20)
	Launcher.Gen.Mail_Group.SetMailbox:SetBackdrop(PaneBackdrop)
	Launcher.Gen.Mail_Group.SetMailbox:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Gen.Mail_Group.SetMailbox:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_Green))
	Launcher.Gen.Mail_Group.SetMailbox:SetScript("OnEnter",function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGreen)) end)
	Launcher.Gen.Mail_Group.SetMailbox:SetScript("OnLeave",function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green)) end)
	Launcher.Gen.Mail_Group.SetMailbox:SetScript("OnClick", function()
		PlaySound(798)
		EZL.SetMailbox()
		EZL.UI.UpdateSates()
	end)

	Launcher.Gen.Mail_Group.SetMailbox.Label = Launcher.Gen.Mail_Group.SetMailbox:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Gen.Mail_Group.SetMailbox.Label:SetPoint("CENTER", 0, 1)
	Launcher.Gen.Mail_Group.SetMailbox.Label:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.Gen.Mail_Group.SetMailbox.Label:SetText("|cffffffffSet Mailbox")

	Launcher.Gen.Mail_Group.IsMailboxSet = Launcher.Gen.Mail_Group:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Gen.Mail_Group.IsMailboxSet:SetPoint("TOPLEFT", Launcher.Gen.Mail_Group.SetMailbox, "TOPRIGHT", 5, -8)
	Launcher.Gen.Mail_Group.IsMailboxSet:SetFont("Fonts\\Arial.ttf", 13)
	Launcher.Gen.Mail_Group.IsMailboxSet:SetText("|cffFF0000Not Set")

	Launcher.Gen.Setting_Group = CreateFrame("Frame", nil, Launcher.Gen.Frame, "BackdropTemplate")
	Launcher.Gen.Setting_Group:SetPoint("TOPLEFT", Launcher.Gen.Mail_Group, "BOTTOMLEFT", 0, -5)
	Launcher.Gen.Setting_Group:SetFrameLevel(Launcher.Gen.Frame:GetFrameLevel() + 1)
	Launcher.Gen.Setting_Group:SetWidth(Setting_Group_Width)
	Launcher.Gen.Setting_Group:SetHeight(Setting_Group_Height)
	Launcher.Gen.Setting_Group:SetBackdrop(PaneBackdrop)
	Launcher.Gen.Setting_Group:SetBackdropColor(EZL.Helper.HexToRGBA(Color_DarkGray, 0.3))
	Launcher.Gen.Setting_Group:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_Green))

	Launcher.Gen.Setting_Group.Label = Launcher.Gen.Setting_Group:CreateFontString(nil, "OVERLAY", "QuestFontNormalSmall")
	Launcher.Gen.Setting_Group.Label:SetPoint("TOPLEFT", 5, -5)
	Launcher.Gen.Setting_Group.Label:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.Gen.Setting_Group.Label:SetText("Settings")

	Launcher.Gen.Setting_Group.AutoLoad_Checkbox = CreateFrame("CheckButton", nil, Launcher.Gen.Setting_Group, "BackdropTemplate")
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetFrameLevel(Launcher.Gen.Setting_Group:GetFrameLevel() + 1)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetWidth(20)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetHeight(20)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetPoint("TOPLEFT", Launcher.Gen.Setting_Group, "TOPLEFT", 5, -20)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetBackdrop(PaneBackdrop)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetScript("OnClick", function(self)
		PlaySound(798)
		if AutoLoad then
			AutoLoad = false
			self:SetChecked(false)
			EZL.Print.Info("Auto Load |cffFF0000Disabled")
		else
			AutoLoad = true
			self:SetChecked(true)
			EZL.Print.Info("Auto Load |cff00FF00Enabled")
		end
		EZL.SaveSettings()
	end)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetScript("OnEnter", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray)) end)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetScript("OnLeave", function(self) self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray)) end)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetScript("OnEnter", function(self)
		self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_DarkGray))
		Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip:Show()
	end)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetScript("OnLeave", function(self)
		self:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
		Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip:Hide()
	end)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetChecked(AutoLoad)

	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.CheckTexture = Launcher.Gen.Setting_Group.AutoLoad_Checkbox:CreateTexture(nil, "OVERLAY")
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.CheckTexture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.CheckTexture:SetSize(20, 20)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.CheckTexture:SetPoint("CENTER", 0, 0)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.CheckTexture:SetAlpha(1)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox:SetCheckedTexture(Launcher.Gen.Setting_Group.AutoLoad_Checkbox.CheckTexture)

	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Label = Launcher.Gen.Setting_Group.AutoLoad_Checkbox:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Label:SetPoint("LEFT", Launcher.Gen.Setting_Group.AutoLoad_Checkbox, "RIGHT", 5, 0)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Label:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Label:SetText("Auto Load")

	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip = CreateFrame("Frame", nil, Launcher.Gen.Setting_Group.AutoLoad_Checkbox, "BackdropTemplate")
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip:SetFrameLevel(Launcher.Gen.Setting_Group.AutoLoad_Checkbox:GetFrameLevel() + 1)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip:SetWidth(300)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip:SetHeight(35)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip:SetPoint("TOPLEFT", Launcher.Gen.Setting_Group.AutoLoad_Checkbox, "TOPRIGHT", 5, 0)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip:SetBackdrop(PaneBackdrop)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip:Hide()

	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip.Label = Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip.Label:SetPoint("TOPLEFT", 5, -5)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip.Label:SetFont("Fonts\\2002B.ttf", 12)
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip.Label:SetText("Automatically loads the addon when you start the \ngame or reload your UI.")
	Launcher.Gen.Setting_Group.AutoLoad_Checkbox.Tooltip.Label:SetJustifyH("LEFT")

	Launcher.Sliders = {}

	Launcher.Sliders.Frame = CreateFrame("Frame", nil, Launcher.Content, "BackdropTemplate")
	Launcher.Sliders.Frame:SetPoint("TOPLEFT", Launcher.Content, "BOTTOMLEFT", 0, 0)
	Launcher.Sliders.Frame:SetFrameLevel(Launcher.Content:GetFrameLevel() + 1)
	Launcher.Sliders.Frame:SetWidth(LauncherWidth_Final)
	Launcher.Sliders.Frame:SetHeight(135)
	Launcher.Sliders.Frame:SetBackdrop(PaneBackdrop)
	Launcher.Sliders.Frame:SetBackdropColor(EZL.Helper.HexToRGBA(Color_White))
	Launcher.Sliders.Frame:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Sliders.Frame:Hide()

	Launcher.Sliders.CheckSnipeSlider = CreateFrame("Slider", nil, Launcher.Sliders.Frame, "BackdropTemplate")

	Launcher.Sliders.CheckSnipeSlider.Label = Launcher.Sliders.CheckSnipeSlider:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Sliders.CheckSnipeSlider.Label:SetPoint("TOPLEFT", Launcher.Sliders.Frame, "TOPLEFT", 5, -10)
	Launcher.Sliders.CheckSnipeSlider.Label:SetFont("Fonts\\2002B.ttf", 11)
	Launcher.Sliders.CheckSnipeSlider.Label:SetTextColor(EZL.Helper.HexToRGBA(Color_DarkGray))
	Launcher.Sliders.CheckSnipeSlider.Label:SetJustifyH("LEFT")
	Launcher.Sliders.CheckSnipeSlider.Label:SetText("Stay Sniping for " .. snipeForXMinutes)

	Launcher.Sliders.CheckSnipeSlider:SetFrameLevel(Launcher.Sliders.Frame:GetFrameLevel() + 1)
	Launcher.Sliders.CheckSnipeSlider:SetWidth(LauncherWidth_Final-15)
	Launcher.Sliders.CheckSnipeSlider:SetHeight(20)
	Launcher.Sliders.CheckSnipeSlider:SetPoint("TOPLEFT", Launcher.Sliders.CheckSnipeSlider.Label, "BOTTOMLEFT", 5, -10)
	Launcher.Sliders.CheckSnipeSlider:SetBackdrop(PaneBackdrop)
	Launcher.Sliders.CheckSnipeSlider:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Sliders.CheckSnipeSlider:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Sliders.CheckSnipeSlider:SetOrientation("HORIZONTAL")
	Launcher.Sliders.CheckSnipeSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	Launcher.Sliders.CheckSnipeSlider:SetMinMaxValues(0, 120)
	Launcher.Sliders.CheckSnipeSlider:SetValueStep(1)
	Launcher.Sliders.CheckSnipeSlider:SetValue(snipeForXMinutes)
	Launcher.Sliders.CheckSnipeSlider:SetScript("OnValueChanged", function(self, value)
		snipeForXMinutes = math.floor(value)
		Launcher.Sliders.CheckSnipeSlider.Label:SetText("Stay Sniping for " .. snipeForXMinutes)
		sniperScanTime = snipeForXMinutes * 60
		EZL.SaveSettings()
	end)

	Launcher.Sliders.WaitSlider = CreateFrame("Slider", nil, Launcher.Sliders.Frame, "BackdropTemplate")

	Launcher.Sliders.WaitSlider.Label = Launcher.Sliders.WaitSlider:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Sliders.WaitSlider.Label:SetPoint("TOPLEFT", Launcher.Sliders.Frame, "TOPLEFT", 5, -60)
	Launcher.Sliders.WaitSlider.Label:SetFont("Fonts\\2002B.ttf", 11)
	Launcher.Sliders.WaitSlider.Label:SetTextColor(EZL.Helper.HexToRGBA(Color_DarkGray))
	Launcher.Sliders.WaitSlider.Label:SetJustifyH("LEFT")
	Launcher.Sliders.WaitSlider.Label:SetText("Wait " .. waitXMinutes .. " Minutes.")

	Launcher.Sliders.WaitSlider:SetFrameLevel(Launcher.Sliders.Frame:GetFrameLevel() + 1)
	Launcher.Sliders.WaitSlider:SetWidth(LauncherWidth_Final-15)
	Launcher.Sliders.WaitSlider:SetHeight(20)
	Launcher.Sliders.WaitSlider:SetPoint("TOPLEFT", Launcher.Sliders.WaitSlider.Label, "BOTTOMLEFT", 5, -10)
	Launcher.Sliders.WaitSlider:SetBackdrop(PaneBackdrop)
	Launcher.Sliders.WaitSlider:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Sliders.WaitSlider:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Sliders.WaitSlider:SetOrientation("HORIZONTAL")
	Launcher.Sliders.WaitSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	Launcher.Sliders.WaitSlider:SetMinMaxValues(0, 120)
	Launcher.Sliders.WaitSlider:SetValueStep(1)
	Launcher.Sliders.WaitSlider:SetValue(waitXMinutes)
	Launcher.Sliders.WaitSlider:SetScript("OnValueChanged", function(self, value)
		waitXMinutes = math.floor(value)
		Launcher.Sliders.WaitSlider.Label:SetText("Wait " .. waitXMinutes .. " Minutes.")

		-- Lower the block counter if the new time is lower than the current one
		-- Required to prevent the bot from doing the Mailstate but isn't allowed to switch from MoveTo to Handle
		local newblocktime = GetTime() + (waitXMinutes * 60)
		if newblocktime < mailTaskBlockedUntil then
			mailTaskBlockedUntil = GetTime() + (waitXMinutes * 60)
		end
		EZL.SaveSettings()
	end)

	Launcher.Sliders.ReloadSlider = CreateFrame("Slider", nil, Launcher.Sliders.Frame, "BackdropTemplate")

	Launcher.Sliders.ReloadSlider.Label = Launcher.Sliders.ReloadSlider:CreateFontString(nil, "OVERLAY","QuestFontNormalSmall")
	Launcher.Sliders.ReloadSlider.Label:SetPoint("TOPLEFT", Launcher.Sliders.Frame, "TOPLEFT", 5, -110)
	Launcher.Sliders.ReloadSlider.Label:SetFont("Fonts\\2002B.ttf", 11)
	Launcher.Sliders.ReloadSlider.Label:SetTextColor(EZL.Helper.HexToRGBA(Color_DarkGray))
	Launcher.Sliders.ReloadSlider.Label:SetJustifyH("LEFT")
	Launcher.Sliders.ReloadSlider.Label:SetText("Reload Game after " .. reloadXMinutes .. " Minutes.")

	Launcher.Sliders.ReloadSlider:SetFrameLevel(Launcher.Sliders.Frame:GetFrameLevel() + 1)
	Launcher.Sliders.ReloadSlider:SetWidth(LauncherWidth_Final-15)
	Launcher.Sliders.ReloadSlider:SetHeight(20)
	Launcher.Sliders.ReloadSlider:SetPoint("TOPLEFT", Launcher.Sliders.ReloadSlider.Label, "BOTTOMLEFT", 5, -10)
	Launcher.Sliders.ReloadSlider:SetBackdrop(PaneBackdrop)
	Launcher.Sliders.ReloadSlider:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Sliders.ReloadSlider:SetBackdropBorderColor(EZL.Helper.HexToRGBA(Color_LightGray))
	Launcher.Sliders.ReloadSlider:SetOrientation("HORIZONTAL")
	Launcher.Sliders.ReloadSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	Launcher.Sliders.ReloadSlider:SetMinMaxValues(1, 120)
	Launcher.Sliders.ReloadSlider:SetValueStep(1)
	Launcher.Sliders.ReloadSlider:SetValue(reloadXMinutes)
	Launcher.Sliders.ReloadSlider:SetScript("OnValueChanged", function(self, value)
		-- Set the Bot variable to the new value
		reloadXMinutes = math.floor(value)

		-- Set the Timer to the new value
		EZL.Print.System("Reloading UI in "..reloadXMinutes.." minutes. ")
		reloadTimer = GetTime() + (reloadXMinutes * 60)
		if not AutoLoad then
			EZL.Print.System("Auto Load is disabled. Bot will not automatically restart after reload.")
		end

		-- Update the Label
		Launcher.Sliders.ReloadSlider.Label:SetText("Reload Game after " .. reloadXMinutes .. " Minutes.")

		-- Save the new value
		EZL.SaveSettings()
	end)


	local requiredheigh = 70 + Launcher.Sliders.CheckSnipeSlider.Label:GetHeight() + Launcher.Sliders.CheckSnipeSlider:GetHeight() + Launcher.Sliders.WaitSlider.Label:GetHeight() + Launcher.Sliders.WaitSlider:GetHeight() + Launcher.Sliders.ReloadSlider.Label:GetHeight() + Launcher.Sliders.ReloadSlider:GetHeight()
	Launcher.Sliders.Frame:SetHeight(requiredheigh)

	-----------------
	-- Minimap Button
	-----------------
	local MinimapButton = CreateFrame("Button", nil, Minimap)
	MinimapButton:SetFrameLevel(8)
	if WOW_PROJECT_ID == 11 then
		MinimapButton:SetSize(35, 35)
	else
		MinimapButton:SetSize(40, 40)
	end
	MinimapButton:SetMovable(true)

	MinimapButton.Texture = MinimapButton:CreateTexture("IconDefault", "OVERLAY")
	MinimapButton.Texture:SetAtlas("MagePortalAlliance")
	MinimapButton.Texture:SetAllPoints(MinimapButton)

	MinimapButton.TextureActive = MinimapButton:CreateTexture("IconActive", "HIGHLIGHT")
	MinimapButton.TextureActive:SetAllPoints(MinimapButton)
	MinimapButton.TextureActive:SetAtlas("MagePortalHorde")

	local myIconPos = 20
	local startPos = 100
	local radius = (Minimap:GetWidth() / 2)

	-- Control movement
	function EZL.UpdateMapBtn()
		local Xpoa, Ypoa = GetCursorPosition()
		local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()

		Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + radius
		Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - radius
		myIconPos = math.deg(math.atan2(Ypoa, Xpoa))
		MinimapButton:ClearAllPoints()
		MinimapButton:SetPoint("CENTER", Minimap, "CENTER", (-(radius + 10) * cos(myIconPos)),
			((radius + 10) * sin(myIconPos)))
	end

	MinimapButton:RegisterForDrag("LeftButton")
	MinimapButton:SetScript("OnDragStart", function()
		MinimapButton:StartMoving()
		MinimapButton:SetScript("OnUpdate", function() EZL.UpdateMapBtn() end)
	end)

	MinimapButton:SetScript("OnDragStop", function()
		MinimapButton:StopMovingOrSizing();
		MinimapButton:SetScript("OnUpdate", nil)
		EZL.UpdateMapBtn();
	end)

	-- Set position
	MinimapButton:ClearAllPoints();
	MinimapButton:SetPoint("CENTER", Minimap, "CENTER", (-(radius + 10) * cos(startPos)), ((radius + 10) * sin(startPos)))

	-- Control clicks
	MinimapButton:SetScript("OnClick", function()
		if Launcher and Launcher:IsVisible() then
			Launcher:Hide()
		else
			Launcher:Show()
		end
	end)
end

function EZL.UI.OnStart()
	local auctionerReady = EZL.IsAuctioneerSet();
	local mailboxReady = EZL.IsMailboxSet();
	if not TSM_Loaded then
		EZL.Print.Error("TradeSkillMaster is not installed. Please install it to use this bot.")
		return
	end
	if EZL.StateMachine.selectedMode == "NA" then 
		EZL.Print.Warning("Please Choose a Mode before starting the bot")
		return
	end
	if EZ_Running == false then
		EZ_Running = true
		if mailboxReady == true and auctionerReady == true then
			EZ_Running = true
			-- Label to Running
			Launcher.StateDisplay.StateLabel:SetText("|cffffffffState: |cff00FF00Running|r")
			-- Startbutton to lightgray
			Launcher.Content.StartButton:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
			-- Stopbutton to red
			Launcher.Content.StopButton:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Red))
			EZL.OnUpdate()
		else
			-- Label to Stopped
			Launcher.StateDisplay.StateLabel:SetText("|cffffffffState: |cffFF0000Stopped|r")
			-- Startbutton to green
			Launcher.Content.StartButton:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green))
			EZ_Running = false
			if mailboxReady == false then
				-- Mailbox not set
				Launcher.Gen.Mail_Group.IsMailboxSet:SetText("|cffFF0000Not Set")
			end
			if auctionerReady == false then
				-- Auctioneer not set
				Launcher.Gen.AH_Group.IsAHNPCSet:SetText("|cffFF0000Not Set")
			end
			EZL.Print.Error("|cffffffffPlease set the mailbox and auctioneer before starting the bot.")
		end		
	else
		EZL.Print.System("|cffffffffBot is already running.")
	end
end

function EZL.UI.OnStop()
	if EZ_Running == true then
		EZ_Running = false
		Launcher.StateDisplay.StateLabel:SetText("|cffffffffState: |cffFF0000Stopped")
		Launcher.Content.StartButton:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green))
		Launcher.Content.StopButton:SetBackdropColor(EZL.Helper.HexToRGBA(Color_LightGray))
		EZL.StopMovement()
		EZL.ResetScans()
	end
end

function EZL.UI.UpdateSates()

	if EZL.IsAuctioneerSet() then
		Launcher.Gen.AH_Group.IsAHNPCSet:SetText("|cff00CC00Set")
	end

	if EZL.IsMailboxSet() then
		Launcher.Gen.Mail_Group.IsMailboxSet:SetText("|cff00CC00Set")
		
	end

	if EZL.IsMailboxSet() and EZL.IsAuctioneerSet() then
		Launcher.Content.StartButton:SetBackdropColor(EZL.Helper.HexToRGBA(Color_Green))
	end
end

function EZL.UI.SetState(stateString)
	Launcher.StateDisplay.StateLabel:SetText("|cffffffffState: |cff00FF00" .. stateString .."|r")
end

function EZL.UI.AutoStart()
	if AutoLoad then
		EZL.Print.System("Auto-Load enabled. Starting bot.")
		EZL.UI.OnStart()
	end
end

--==========================================================================
--================================ Objects =================================
--==========================================================================

local possibletypes = {
	["Object"] = true,
	["Item"] = true,
	["Container"] = true,
	["Unit"] = true,
	["Player"] = true,
	["ActivePlayer"] = true,
	["GameObject"] = true,
	["DynamicObject"] = true,
	["Corpse"] = true,
	["AreaTrigger"] = true,
	["SceneObject"] = true,
	["ConversationData"] = true
}

function EZL.ObjectManager(typ)
	-- Early return if type is not valid
	if not possibletypes[typ] then
		EZL.Print.Error("Invalid object type in OM: " .. tostring(typ))
		return
	end

	-- Call the appropriate Unlocker function
	return UnlockerFuncs[Unlocker].ObjectManager(typ)
end

function EZL.GetObjectPosition(object)
	return UnlockerFuncs[Unlocker].ObjectPosition(object)
end

function EZL.GetObjectID(object)
	return UnlockerFuncs[Unlocker].ObjectId(object)
end

function EZL.GetObjectName(object)
	return UnlockerFuncs[Unlocker].ObjectName(object)
end

function EZL.GetObject(object)
	if object then
		return UnlockerFuncs[Unlocker].Object(object)
	end
end

function EZL.GetObjectWithId(id,type)
	local bestobject = nil
	local bestdistance = math.huge
	local objects = EZL.ObjectManager(type or "Unit")
	if objects == nil then return end
    for _, object in pairs(objects) do
        local objectId = EZL.GetObjectID(object)
        if objectId == id then
			local distance = EZL.GetDistanceBetweenObjects("player",object)
			if distance ~= nil and distance < bestdistance then
				bestdistance = distance
				bestobject = object
			end
        end
    end
	return bestobject
end

function EZL.GetObjectInfo(object)
	
	local x,y,z = EZL.GetObjectPosition(object)
	local id = EZL.GetObjectID(object)
	return x,y,z,id,object
end

function EZL.GetGameObjectType(object)
	return UnlockerFuncs[Unlocker].GameObjectType(object)
end

function EZL.GetDistance(X, Y, Z, XX, YY, ZZ)
    local dist;
    if X and XX and Y and YY and Z and ZZ then
        dist = math.sqrt((XX-X)^2 + (YY-Y)^2 + (ZZ-Z)^2)
        if dist == nil then
            dist = 0
        end
        if (dist < 0 and dist > 0) then
            return 0
        end
        return dist
    end
end

function EZL.GetDistanceBetweenObjects(objectA,objectB)
    if objectA and objectB then
        local x1,y1,z1 = EZL.GetObjectInfo(objectA)
        local x2,y2,z2 = EZL.GetObjectInfo(objectB)
        if x2 and x1 then
            local distance = EZL.GetDistance(x1,y1,z1,x2,y2,z2)
            return distance
        end
    end
end

function EZL.ObjectInteract(object)
	UnlockerFuncs[Unlocker].ObjectInteract(object)
end

function EZL.ObjectIsMailbox(object)
	return EZL.GetGameObjectType(object) == 0x13
end

--- This function will not work since Unit is not a GameObject need to rework the Unitflags
local testcache = true
function EZL.ObjectIsAuctioneer(object)
	if EZL.GetGameObjectType(object) == 0x14 or testcache then
		return true
	else
		return false
	end
end

function EZL.SetFacing(angle)
	UnlockerFuncs[Unlocker].SetFacing(angle)
end

function EZL.GetFacingValue(x,y,z)
	if x and y and z then
		local xPla, yPla, zPla = EZL.GetObjectPosition("player")
        if xPla then
            local a = y - yPla
            local b = x - xPla

            if a < 0 and b > 0 then
                local value = ((270 + math.atan(b/-a)*180/math.pi)/360)*(2*math.pi)
                return value
            elseif a < 0 and b < 0 then
                local value = ((270 - math.atan(b/a)*180/math.pi)/360)*(2*math.pi)
                return value
            elseif a > 0 and b < 0 then
                local value = ((90 + math.atan(-b/a)*180/math.pi)/360)*(2*math.pi)
                return value
            elseif a > 0 and b > 0 then
                local value = ((90 - math.atan(b/a)*180/math.pi)/360)*(2*math.pi)
                return value
            end
        end
	end
end

function EZL.TraceLine(x1, y1, z1, x2, y2, z2, hitFlags)
	local hitFlags = bit.bor(unpack(hitFlags))
	return UnlockerFuncs[Unlocker].TraceLine(x1, y1, z1, x2, y2, z2, hitFlags)
end


--==========================================================================
--================================ Pathing =================================
--==========================================================================

function EZL.GeneratePath(x,y,z)
	local path = nil
	local mapid = select(8, GetInstanceInfo())
	local px,py,pz = EZL.GetObjectPosition("player")
	local ex,ey,ez = x,y,z
	if Unlocker == "noname" then
		local callback = function(status, response)
			if status == 200 then
				path = response
			end
		end
		local x2, y2, z2 = x,y,z
		path = GenerateLocalPath(mapid,px,py,pz,ex,ey,ez,callback,true)
	elseif Unlocker == "tinkr" then
		local PathTypes = {
			PATHFIND_BLANK = 0x00, -- path not built yet
			PATHFIND_NORMAL = 0x01, -- normal path
			PATHFIND_SHORTCUT = 0x02, -- travel through obstacles, terrain, air, etc (old behavior)
			PATHFIND_INCOMPLETE = 0x04, -- we have partial path to follow - getting closer to target
			PATHFIND_NOPATH = 0x08, -- no valid path at all or error in generating one
			PATHFIND_NOT_USING_PATH = 0x10, -- used when we are either flying/swiming or on map w/o mmaps
			PATHFIND_SHORT = 0x20, -- path is longer or equal to its limited path length
		}
		local pathType = nil
		local cachepath = nil
		local generationParams = {
			excludeFlags = 0,
			terrainCost = 1.0,
			waterCost = 0.9,
			deadlyCost = 1.5,
			wmoCost = 1.0,
			doodadCost = 1.0
		}
		cachepath, pathType = GeneratePath(px,py,pz,ex,ey,ez,mapid,generationParams)
		print(cachepath, pathType)
		--EZL.Print.Debug(pathType)
		if pathType == PathTypes.PATHFIND_NORMAL or pathType == PathTypes.PATHFIND_INCOMPLETE or -1  then
			--EZL.Print.Debug("normal")
			path = cachepath
		elseif pathType == PathTypes.PATHFIND_NOPATH then
			--EZL.Print.Debug("nopath")
			local radius = 4
			local step = 1 -- you can adjust this value for more granularity
			local closestPoint = nil
			local closestDistance = math.huge
			local closestPath = nil
		
			for angle = 0, 360, step do
				local radian = math.rad(angle)
				local dx = radius * math.cos(radian)
				local dy = radius * math.sin(radian)
				local nx, ny = ex + dx, ey + dy
				local _, _, nz = EZL.TraceLine(nx, ny, ez, nx, ny, ez - 10, {EZL.Common.Hitflags.Collision, EZL.Common.Hitflags.WmoCollision, EZL.Common.Hitflags.Terrain, EZL.Common.Hitflags.LiquidWaterWalkable}) -- get the z value using TraceLine
				local newPath, newPathType = GeneratePath(px,py,pz, nx, ny, nz, mapid, generationParams)
				if newPathType == PathTypes.PATHFIND_NORMAL or -1 then
					local dist = EZL.GetDistance(px,py,pz, nx, ny, nz)
					if dist < closestDistance then
						closestDistance = dist
						closestPoint = {x = nx, y = ny, z = nz}
						closestPath = newPath
					end
				end
			end
		
			if closestPoint and closestPath then
				path = closestPath
			else
				EZL.Print.Debug("No valid path found in the radius")
			end
		end
	end

	return path
end

function EZL.ResetPath()
	EZ_Path = nil
end

function EZL.PathToMailbox()
	local MailboxX,MailboxY,MailboxZ = mailboxInfo.x,mailboxInfo.y,mailboxInfo.z
	local path = EZL.GeneratePath(MailboxX,MailboxY,MailboxZ)
	C_Timer.After(5,EZL.ResetPath)
	return path
end

function EZL.PathToAuctioneer()
	local AuctioneerX,AuctioneerY,AuctioneerZ = auctioneerInfo.x,auctioneerInfo.y,auctioneerInfo.z
	local path = EZL.GeneratePath(AuctioneerX,AuctioneerY,AuctioneerZ)
	C_Timer.After(5,EZL.ResetPath)
	return path
end

local AngleTimer = GetTime()
local AngleDelay = 0.2

function EZL.UpdatePosition()
	if EZ_Path ~= nil  and EZ_Running then
		local currentX, currentY, currentZ = EZL.GetObjectPosition("player")
		local destX = tonumber(EZ_Path[1]["x"])
		local destY = tonumber(EZ_Path[1]["y"])
		local destZ = tonumber(EZ_Path[1]["z"])

		local dist = EZL.GetDistance(currentX, currentY, 1, destX, destY, 1)

		if dist and (dist < 0.5) then
			table.remove(EZ_Path, 1)
			if #EZ_Path == 0 then
				EZ_Path = nil
				EZL.StopMovement()
			end
		else
			if AngleTimer < GetTime() then
				local angle = EZL.GetFacingValue(destX,destY,destZ)
				EZL.SetFacing(angle)
				EZL.Unlock('TurnLeftStart','')
				EZL.Unlock('TurnLeftStop','')
				EZL.Unlock("MoveForwardStart","")
				AngleTimer = GetTime() + AngleDelay
			end
		end
	end
end

--==========================================================================
--================================== TSM ===================================
--==========================================================================


function EZL.GetNumFreeBagSpace()
    local freeSlots = 0

    for bag = 0, 4 do
		freeSlots = freeSlots + C_Container.GetContainerNumFreeSlots(bag)
    end

    return freeSlots
end


function EZL.inTSMFrame(name)
	local possibleFrames = {"AUCTION","CRAFTING","VENDORING","MAILING"}
	if TSM_API and TSM_API.IsUIVisible then
		if name then
			if TSM_API.IsUIVisible(name) then
				return true
			end
		else
			for i=1,#possibleFrames do
				if TSM_API.IsUIVisible(possibleFrames[i]) then
					return true
				end
			end
		end
	end
end

function EZL.IsProgressBarState(state)
	local newstate = _G.TSMLibrary[state]
	local newstate2 = newstate:gsub("%%d", "%%d*")

	local table = _G.ReturnAllTSMFrames()

	for k,v in pairs(table) do
		if type(v) == "table" then
			for k2,v2 in pairs(v) do
				local stringcheck = tostring(v2)
				if string.find(stringcheck, "ProgressBar:bottom.progressBar") then
					local stringcheck2 = tostring(v2:GetText())
					if stringcheck2:match("^" .. newstate2 .. "$") then
						return true
					end
				end
			end
		end
	end
end

function EZL.DetectMaxCancels()
	local table = _G.ReturnAllTSMFrames()
	local locCancel = _G.TSMLibrary["Canceling %d / %d"]
	local newstate2 = locCancel:gsub("%%d", "%%d*")
	-- Detect the %d / %d in the string and return the bigger number
	for k,v in pairs(table) do
		if type(v) == "table" then
			for k2,v2 in pairs(v) do
				local stringcheck = tostring(v2)
				if string.find(stringcheck, "ProgressBar:bottom.progressBar") then
					local stringcheck2 = tostring(v2:GetText())
					if stringcheck2:match("^" .. newstate2 .. "$") then
						local _,cancels,maxcancels = string.match(stringcheck2, "(%d+) / (%d+)") -- returns 2 values
						return cancels	
					end
				end
			end
		end
	end
end

function EZL.GetProgressBarState()
	local table = _G.ReturnAllTSMFrames()

	for k,v in pairs(table) do
		if type(v) == "table" then
			for k2,v2 in pairs(v) do
				local stringcheck = tostring(v2)
				if string.find(stringcheck, "ProgressBar:bottom.progressBar") then
					local text = v2:GetText()
					if text then
						return text
					end
				end
			end
		end
	end
end

--==========================================================================
--========================= TSM File Management ============================ 
--==========================================================================

--function EZA.OnAPICallTSM(self,...)
--	if EZA and EZA.RunString  then  --and self._name ~= "QueryAuctionItems"
--		--EZL.Print.Debug("Debug: Calling APIWrapper._CallAPI with args and name:" .. self._name)
--		--EZL.Print.Debug("Total number of arguments:", select("#", ...))
--		
--		EZA.RunStringArgsTable = {} -- create a table that should be accessible within eval
--
--		local argsStr = ""
--
--		for i = 1, select("#", ...) do
--			local arg = select(i, ...)
--			--EZL.Print.Debug(string.format("Debug: Arg %d, Type: %s, Value: %s", i, type(arg), tostring(arg)))
--			EZA.RunStringArgsTable[i] = arg -- assign the arg value to the table we created above
--			argsStr = argsStr .. "EZA.RunStringArgsTable[".. i .. "]," -- Format an args string pointing to the table we created above
--		end
--
--		argsStr = string.sub(argsStr, 1, string.len(argsStr) - 1) -- trim the trailing ","
--		--EZL.Print.Debug(string.format("Debug: ArgStr: %s", argsStr))  
--		print(argsStr)
--		local args = argsStr
--		
--		local func = (_G.Environment.HasFeature(_G.Environment.FEATURES.C_AUCTION_HOUSE) and '_G["C_AuctionHouse"]' or '_G')..'["'..self._name..'"]('.. args ..')'
--		--EZL.Print.Debug("Debug: Generated function call:", func)
--		local function runStringTempWrapper() -- needed for NN Safety. Client needs to be wrapped in local functions to be 100% sure. -- Trust Source Principal
--			local function runStringTemp()
--				EZA.RunString(func) 
--			end
--			if Unlocker == "noname" then
--				IsMacClient(46)
--			end
--			runStringTemp()
--		end
--		
--		return runStringTempWrapper()
--	end
--end

function EZA.OnAPICallTSM(self,...)
    if EZA and EZA.RunString  then  --and self._name ~= "QueryAuctionItems"
        --EZL.Print.Debug("Debug: Calling APIWrapper._CallAPI with args and name:" .. self._name)
        --EZL.Print.Debug("Total number of arguments:", select("#", ...))

        if Unlocker == "noname" then
            -- C_Timer.Nn.forcesecure()
            return Unlock(C_AuctionHouse and C_AuctionHouse[self._name] or _G[self._name],...)
        else
            EZA.RunStringArgsTable = {} -- create a table that should be accessible within eval

            local argsStr = ""

            for i = 1, select("#", ...) do
                local arg = select(i, ...)
                --EZL.Print.Debug(string.format("Debug: Arg %d, Type: %s, Value: %s", i, type(arg), tostring(arg)))
                EZA.RunStringArgsTable[i] = arg -- assign the arg value to the table we created above
                argsStr = argsStr .. "EZA.RunStringArgsTable[".. i .. "]," -- Format an args string pointing to the table we created above
            end

            argsStr = string.sub(argsStr, 1, string.len(argsStr) - 1) -- trim the trailing ","
            --EZL.Print.Debug(string.format("Debug: ArgStr: %s", argsStr))
            local args = argsStr

            local func = (_G.ClientInfo.HasFeature(_G.ClientInfo.FEATURES.C_AUCTION_HOUSE) and '_G["C_AuctionHouse"]' or '_G')..'["'..self._name..'"]('.. args ..')'
            --EZL.Print.Debug("Debug: Generated function call:", func)
            local function runStringTempWrapper() -- needed for NN Safety. Client needs to be wrapped in local functions to be 100% sure. -- Trust Source Principal
                local function runStringTemp()
                    EZA.RunString(func) 
                end
                runStringTemp()
            end

            return runStringTempWrapper()
        end

    end
end


function EZA.SnipeBuyNow(self)
	if EZA and EZA.RunString then
		if not self then EZL.Print.Debug("No Self") return end
		-- Create an argument table similar to EZA.RunStringArgsTable to hold arguments
		EZA.RunStringPBArgsTable = {}
		EZA.RunStringPBArgsTable["itemID"] = self.expectedItemKey.itemID
		EZA.RunStringPBArgsTable["auctionID"] = self.resultInfo and self.resultInfo.auctionID
		EZA.RunStringPBArgsTable["buyoutAmount"] = self.resultInfo and self.resultInfo.buyoutAmount
		EZA.RunStringPBArgsTable["quantity"] = self.ghostCount or (self.resultInfo and self.resultInfo.quantity)

		-- Generate the function call string
		local func
		if self.info.isCommodity then
			--EZL.Print.Debug("Is Commodity")
			self.buyCommodity = true
			--EZL.Print.Debug("set commodity")
			func = '_G["C_AuctionHouse"]["StartCommoditiesPurchase"](EZA.RunStringPBArgsTable["itemID"], EZA.RunStringPBArgsTable["quantity"])'
		else
			func = '_G["C_AuctionHouse"]["PlaceBid](EZA.RunStringPBArgsTable["auctionID"], EZA.RunStringPBArgsTable["buyoutAmount"])'
		end
		--EZL.Print.Debug(func)
		EZA.RunString(func)
	end
end

local function PatchTSM()
	local tsm_base = "Interface/AddOns/TradeSkillMaster"
    local tsm_path = tsm_base .. "/Core/UI"
    local tsm_path_core = tsm_path .. "/AuctionUI/Core.lua"
    local tsm_path_Auctioning = tsm_path .. "/AuctionUI/Auctioning.lua"
    local tsm_path_UIElements = tsm_base .. "/LibTSM/UI/UIElements.lua"
	local tsm_path_Mailing = tsm_path.. "/MailingUI/Core.lua"
	local tsm_path_Inbox = tsm_path .. "/MailingUI/Inbox.lua"
	local tsm_path_AuctionHouseWrapper = tsm_base .. "/LibTSM/Service/AuctionHouseWrapper.lua"
	local tsm_path_Sniper = tsm_path .. "/AuctionUI/Sniper.lua"

	local pointBlank_base = "Interface/AddOns/PointBlankSniper"
	local pointBlank_main = pointBlank_base .. "/Source/Buy/Main.lua"
	
	local reloadrequired = false

	local function appendIfNotExists(data, searchString, appendStr)
		if not string.find(data, searchString) then
			data = data .. "\n\n" .. appendStr
			reloadrequired = true
		end
		return data
	end

	local function replaceInString(data, searchString, replaceString)
		-- Escape any special characters in searchString
		local escapedSearchString = searchString:gsub("[%(%)%.%+%-%*%?%[%]%^%$]", "%%%1")
	
		-- Split the data into individual lines
		local lines = {}
		for line in data:gmatch("[^\r\n]+") do
			table.insert(lines, line)
		end
	
		-- Join the lines back together with newline characters
		data = table.concat(lines, "\n")
	
		-- Perform the replacement
		local newData, numReplacements = string.gsub(data, escapedSearchString, replaceString)
		
		return newData, numReplacements
	end

    local coredata = EZL.FileSystem.ReadFile(tsm_path_core)
    if coredata then

        coredata = appendIfNotExists(coredata, "_G.OpenAuctTab()", "function _G.OpenAuctTab()\n\treturn AuctionUI.SetOpenPage(L['Auctioning'])\nend")
        coredata = appendIfNotExists(coredata, "_G.InAuctTab()", "function _G.InAuctTab()\n\treturn AuctionUI.IsPageOpen(L['Auctioning'])\nend")
        coredata = appendIfNotExists(coredata, "_G.GetAHTab()", "function _G.GetAHTab()\n\treturn private.frame:GetSelectedNavButton()\nend")
        coredata = appendIfNotExists(coredata, "_G.TSMIsScanning = AuctionUI.IsScanning", "_G.TSMIsScanning = AuctionUI.IsScanning")
        coredata = appendIfNotExists(coredata, "_G.OpenSniperTab()", "function _G.OpenSniperTab() return AuctionUI.SetOpenPage(L['Sniper']) end")
        coredata = appendIfNotExists(coredata, " _G.InSniperTab()", " function _G.InSniperTab() return AuctionUI.IsPageOpen(L['Sniper']) end")
        coredata = appendIfNotExists(coredata, "_G.TSM_SwitchMainFrame  = private.SwitchBtnOnClick", "_G.TSM_SwitchMainFrame  = private.SwitchBtnOnClick")
        coredata = appendIfNotExists(coredata, "_G.SwitchToTSMTab()", "function _G.SwitchToTSMTab() return private.TSMTabOnClick() end")
		
        EZL.FileSystem.WriteFile(tsm_path_core, coredata, false)
    end

    local auctioningdata = EZL.FileSystem.ReadFile(tsm_path_Auctioning)
    if auctioningdata then
        auctioningdata = appendIfNotExists(auctioningdata, "_G.BuySnipeBtnOnClick = private.ActionButtonOnClick", "_G.BuySnipeBtnOnClick = private.ActionButtonOnClick")
        auctioningdata = appendIfNotExists(auctioningdata, "_G.TSMLibrary = L", "_G.TSMLibrary = L")

		auctioningdata = replaceInString(auctioningdata, ":AddChild(UIElements.New(\"ActionButton\", \"postScanBtn\")", ":AddChild(UIElements.NewNamed(\"ActionButton\", \"postScanBtn\", \"TSMPostScanBtn\")")
		auctioningdata = replaceInString(auctioningdata, ":AddChild(UIElements.New(\"ActionButton\", \"cancelScanBtn\")", ":AddChild(UIElements.NewNamed(\"ActionButton\", \"cancelScanBtn\", \"TSMCancelScanBtn\")")

        
        EZL.FileSystem.WriteFile(tsm_path_Auctioning, auctioningdata, false)
    end

    local uielementsdata = EZL.FileSystem.ReadFile(tsm_path_UIElements)
    if uielementsdata then
        uielementsdata = appendIfNotExists(uielementsdata, "ReturnAllTSMFrames", "function _G.ReturnAllTSMFrames()\n\treturn private\nend")
			EZL.FileSystem.WriteFile(tsm_path_UIElements, uielementsdata, false)
	end
		
	local uielementsdata = EZL.FileSystem.ReadFile(tsm_path_Inbox)
	if uielementsdata then
		uielementsdata = replaceInString(uielementsdata, ":AddChild(UIElements.New(\"ActionButton\", \"openAllMail\")", ":AddChild(UIElements.NewNamed(\"ActionButton\", \"openAllMail\", \"TSMOpenAllMailsBtn\")")
		EZL.FileSystem.WriteFile(tsm_path_Inbox, uielementsdata, false)
	end
		
	local uielementsdata = EZL.FileSystem.ReadFile(tsm_path_Mailing)
    if uielementsdata then
        uielementsdata = appendIfNotExists(uielementsdata, "_G.TSM_OnClickSwitchBtn = private.SwitchBtnOnClick", "_G.TSM_OnClickSwitchBtn = private.SwitchBtnOnClick")
        EZL.FileSystem.WriteFile(tsm_path_Mailing, uielementsdata, false)
    end
	

	local uielementsdata = EZL.FileSystem.ReadFile(tsm_path_AuctionHouseWrapper)
    if uielementsdata then
		-- Replace the function
local searchFunc = [[function APIWrapper:_CallAPI(self, ...)
	return (ClientInfo.HasFeature(ClientInfo.FEATURES.C_AUCTION_HOUSE) and C_AuctionHouse or _G)[self._name](...)
end]]
	
local replaceFunc = [[function APIWrapper:_CallAPI( ...)
	if _G.EZA and _G.EZA.OnAPICallTSM then
		_G.EZA.OnAPICallTSM(self,...)
	else
		return (ClientInfo.HasFeature(ClientInfo.FEATURES.C_AUCTION_HOUSE) and C_AuctionHouse or _G)[self._name](...)
	end
end]]
        uielementsdata = appendIfNotExists(uielementsdata, "_G.ClientInfo = ClientInfo", "_G.ClientInfo = ClientInfo")
        uielementsdata = replaceInString(uielementsdata, searchFunc, replaceFunc)
		EZL.FileSystem.WriteFile(tsm_path_AuctionHouseWrapper, uielementsdata, false)
    end

	local uielementsdata = EZL.FileSystem.ReadFile(tsm_path_Sniper)
    if uielementsdata then
		uielementsdata = replaceInString(uielementsdata, "local fsmContext = {", "_G.fsmContext = {")
		uielementsdata = replaceInString(uielementsdata, ":AddChild(UIElements.New(\"ActionButton\", \"pauseResumeBtn\")", ":AddChild(UIElements.NewNamed(\"ActionButton\", \"pauseResumeBtn\", \"TSMPauseResumeBtn\")")
		uielementsdata = replaceInString(uielementsdata, ":AddChild(UIElements.New(\"ActionButton\", \"buyoutScanBtn\")", ":AddChild(UIElements.NewNamed(\"ActionButton\", \"buyoutScanBtn\", \"TSMStartSniperScanBtn\")")
        EZL.FileSystem.WriteFile(tsm_path_Sniper, uielementsdata, false)
    end

	local uielementsdata = EZL.FileSystem.ReadFile(pointBlank_main)
	if uielementsdata then
local searchFunc = [[function PointBlankSniperBuyFrameMixin:BuyNow()
	assert(self.BuyButton:IsEnabled())
	if self.info.isCommodity then
	  self.buyCommodity = true
	  C_AuctionHouse.StartCommoditiesPurchase(self.expectedItemKey.itemID, self.ghostCount or self.resultInfo.quantity)
	else
	  C_AuctionHouse.PlaceBid(self.resultInfo.auctionID, self.resultInfo.buyoutAmount)
	end
	self.BuyButton:Disable()
	self.BuyButton:SetText(POINT_BLANK_SNIPER_L_BUYING)
end]]
	
local replaceFunc = [[function PointBlankSniperBuyFrameMixin:BuyNow() 
	if EZA and EZA.SnipeBuyNow then 
		EZA.SnipeBuyNow(self) 
	else 
		assert(self.BuyButton:IsEnabled()) 
		if self.info.isCommodity then 
			self.buyCommodity = true 
			C_AuctionHouse.StartCommoditiesPurchase(self.expectedItemKey.itemID, self.ghostCount or self.resultInfo.quantity) 
		else 
			C_AuctionHouse.PlaceBid(self.resultInfo.auctionID, self.resultInfo.buyoutAmount) 
		end 
	end 
	self.BuyButton:Disable() 
	self.BuyButton:SetText(POINT_BLANK_SNIPER_L_BUYING) 
end]]

	uielementsdata = replaceInString(uielementsdata, searchFunc, replaceFunc)
end





	return reloadrequired
end
--==========================================================================
--========================= Drawing ========================================
--==========================================================================
local Draw = UnlockerFuncs[Unlocker].Draw()

Draw:Sync(function(draw)
	if EZ_Path and #EZ_Path > 2 then
		for i = 1, #EZ_Path - 1 do
	
			local currentPoint = EZ_Path[i]
			local nextPoint = EZ_Path[i + 1]
	
			draw:SetColor(draw.colors.blue)
			-- draw:Circle(currentPoint.x, currentPoint.y, currentPoint.z, 0.2)
			if nextPoint and currentPoint.x and currentPoint.y and currentPoint.z and nextPoint.x and nextPoint.y and nextPoint.z then
				draw:Line(currentPoint.x, currentPoint.y, currentPoint.z, nextPoint.x, nextPoint.y, nextPoint.z)
			end
		end
	end
end)

if TSM_Loaded then
	EZL.Print.Info("[Initialization] Checking the System.")

	if Unlocker == "noname" and PatchTSM() then
			EZL.Print.Info("[Initialization] Successfully Patched your TSM Files. Reload is required. Will automatically reload in 2 seconds")
			C_Timer.After(2, function() EZL.ReloadUI() end)
	else
		EZL.InitializeAuctionStateCoroutine()
		EZL.InitializeMailProcessCoroutine()
		EZL.InitializeCancelStateCoroutine()
		EZL.InitializeSnipeCoroutine()
		EZL.OnInitStateMachine()
		EZL.InitErrorListener()
		EZL.LoadSettings()
		EZL.UI.Init()
		EZL.UI.UpdateSates()
		EZL.UpdateMode()
		Draw:Enable()
		C_Timer.NewTicker(3, EZL.AntiAFK)
		EZL.Print.Info("[Initialization] System Ready! Thanks for using Eazy AH")
		EZL.UI.AutoStart()
	end
end


------------------------
--CHANGES TO TSM FILE
------------------------

-- function APIWrapper._CallAPI(self, ...)
-- 	if _G.EZA and _G.EZA.OnAPICallTSM then  
-- 		_G.EZA.OnAPICallTSM(self,...)
-- 	else
-- 	    return (Environment.HasFeature(Environment.FEATURES.C_AUCTION_HOUSE) and C_AuctionHouse or _G)[self._name](...)
-- 	end
-- end
--:AddChild(UIElements.New("ActionButton", "openAllMail")  to :AddChild(UIElements.NewNamed("ActionButton", "openAllMail", TSMOpenAllMailBtn)
--_G.Environment = Environment

--_G.TSM_OnClickSwitchBtn = private.SwitchBtnOnClick // /Applications/World of Warcraft/_retail_/Interface/AddOns/TradeSkillMaster/Core/UI/MailingUI/Core.lua
-- 
--_G.RunCancelBtnnOnClick() = private.RunCancelButtonOnclick // /Users/justingfrerer/Downloads/TradeSkillMaster 2/Core/UI/AuctionUI/Auctioning.lua
--_G.RunPostBtnnOnClick() = private.RunPostButtonOnclick/	// Users/justingfrerer/Downloads/TradeSkillMaster 2/Core/UI/AuctionUI/Auctioning.lua
--	function _G.OpenSniperTab() return AuctionUI.SetOpenPage(L['Sniper']) end/Applications/World of Warcraft/_retail_/Interface/AddOns/TradeSkillMaster/Core/UI/AuctionUI/Core.lua
-- function _G.InSniperTab() return AuctionUI.IsPageOpen(L['Sniper']) end /Applications/World of Warcraft/_retail_/Interface/AddOns/TradeSkillMaster/Core/UI/AuctionUI/Core.lua
--TSMStartSniperScanBtn


-- function PointBlankSniperBuyFrameMixin:BuyNow()
-- 	assert(self.BuyButton:IsEnabled())
-- 	if self.info.isCommodity then
-- 		self.buyCommodity = true
-- 		C_AuctionHouse.StartCommoditiesPurchase(self.expectedItemKey.itemID, self.ghostCount or 1)
-- 	else
-- 		C_AuctionHouse.PlaceBid(self.resultInfo.auctionID, self.resultInfo.buyoutAmount)
-- 	end
-- 	self.BuyButton:Disable()
-- 	self.BuyButton:SetText(POINT_BLANK_SNIPER_L_BUYING)
-- end