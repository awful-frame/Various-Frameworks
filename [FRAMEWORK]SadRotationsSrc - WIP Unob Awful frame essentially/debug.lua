local unlocker, blink = ...
local debugprofilestart, debugprofilestop = debugprofilestart, debugprofilestop
local unpack = unpack

local _env = getfenv(1)

blink.debug = {}
blink.debug["all"] = false
blink.debug["enemies"] = false
blink.debug["friends"] = false
blink.debug["drs"] = false
blink.debug["combat"] = false
blink.debug["drawings"] = false
blink.debug["casts"] = false

local Profiler = {
	current = {},
	hooked = {},
	overhead = {
		objectAttributes = {
			prefix = blink.colors.cyan .. "obj."
		},
		objectFunctions = {
			prefix = blink.colors.yellow .. "obj."
		},
		blinkFunctions = {
			prefix = blink.colors.orange .. "blink."
		},
		blinkMetatable = {
			prefix = blink.colors.orange .. "blink(mt)."
		},
		envFunctions = {
			prefix = blink.colors.blue .. "_env."
		}
	}
}

blink.dump = function(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. blink.dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
end

blink.toggleDebug = function(debugType, override)
	if debugType ~= "all" then
		if override then
			blink.debug[debugType] = override
		elseif not blink.debug[debugType] then
			blink.debug[debugType] = GetTime()
		else
			blink.debug[debugType] = false
		end
		if blink.debug[debugType] then
			blink.print("|cFF5cffd9debugger:|r " .. debugType .. " enabled")
		else
			blink.print("|cFF5cffd9debugger:|r " .. debugType .. " disabled", true)
		end
	else
		blink.print("all debugging modes enabled")
	end
end

local function Split(s, delimiter)
	result = {};
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
			table.insert(result, match);
	end
	return result;
end

blink.AddSlashBlinkCallback(function(msg)
	if not blink.DevMode == true then return false end
	if msg == "log" then
		blink.debuglogging = not blink.debuglogging
	elseif msg == "debug" then
		blink.toggleDebug("debug")
		return true
	elseif msg:match("debug") then
		local types = Split(msg, " ")
		for _, type in ipairs(types) do
			if type == "help" then
				blink.print("|cFFff7b1cblink debug|r is an experimental feature designed to help you debug your routines.")
				blink.print("|cFFFFFFFFvalid debug types:")
				blink.print("/blink |cFFff9d57debug: |cFFfc6868potentially critical issues, unexpected events where the framework defaulted to fail gracefully")
				blink.print("/blink debug |cFFff9d57all: |cFFFFFFFFenables all debug prints simultaneously, except 'harmless'")
				blink.print("/blink debug |cFFff9d57perf: |cFFFFFFFFpotential performance improvement opportunities")
				-- blink.print("/blink debug |cFFff9d57cast: |cFFFFFFFFspecific reason spells aren't being cast (unreliable/outdated)")
				blink.print("/blink debug |cFFff9d57harmless: |cFFFFFFFFunexpected events, likely harmless, that may shed light on unseen problems.")
			elseif type ~= "debug" then
				blink.toggleDebug(type)
			end
		end
		return true
	elseif msg:match("profile") then
		if msg:match("all") then
			-- functions 
			for key, value in pairs(_env) do
				if not Profiler.hooked["_env."..key] and type(value) == "function" then
					Profiler.hooked["_env."..key] = true
					_env[key] = function(...)
						debugprofilestart()
						local result = {value(...)}
						local time = debugprofilestop()
						self.overhead.envFunctions[key] = (self.overhead.envFunctions[key] or 0) + time
						return unpack(result)
					end
				end
			end
		end
		Profiler:Toggle()
		return true
	end
end)

blink.debug.print = function(str, debugType, noStack)
	if debugType then
		if blink.debug[debugType] or blink.debug.all then
			blink.print("|cFFFFFFFF(" .. debugType .. ")|r " .. str)
			if not noStack then
				blink.print(debugstack(3), true)
			end
		end
	end
end

local function debuglog(line)
	line = line .. "\n"
	WriteFile("scripts/SadRotations/debug.txt", line, true)
end
blink.debuglog = debuglog

local function round(num, numDecimalPlaces)
  local mult = 10 ^ (numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Profiler:StartProfiling(category, key)
	debugprofilestart()
	self.current[1] = category
	self.current[2] = key
end

function Profiler:StopProfiling(category, key)
	local currentCat, currentKey = self.current[1], self.current[2]
	if currentCat ~= category or currentKey ~= key then
		blink.print("Profiler:StopProfiling() called with mismatched category/key: " .. category .. "/" .. key .. " vs " .. currentCat .. "/" .. currentKey, true)
		return
	end
	local time = debugprofilestop()
	local totalTime = self.overhead[category][key] or 0
	self.overhead[category][key] = totalTime + time
end

function Profiler:ColorByOverhead(time, totalTime, isTotal)
	totalTime = totalTime * 1000
	if time > totalTime * (0.08 + (isTotal and 0.2 or 0)) then
		return blink.colors.red .. "*!*" .. time
	elseif time > totalTime * (0.03 + (isTotal and 0.1 or 0)) then
		return blink.colors.red .. time
	elseif time > totalTime * (0.01 + (isTotal and 0.05 or 0))  then
		return blink.colors.yellow .. time
	else
		return blink.colors.cyan .. time
	end
end

function Profiler:Tick()

	-- reset profiler when disabled
	if not self.started then
    for profileType, entries in pairs(self.overhead) do
			for key, time in pairs(entries) do
				if key ~= "prefix" then
					entries[key] = nil
				end
			end
		end
		return
  end

	-- hook all object functions to track overhead
	for guid, object in pairs(blink.objectsByGUID) do
		-- don't hook them twice!
		if not object.hooked_by_profiler then
			object.hooked_by_profiler = true

			-- functions 
			for key, value in pairs(object) do
				if key ~= "cacheReturn" and type(value) == "function" then
					object[key] = function(...)
						debugprofilestart()
						local result = {value(...)}
						local time = debugprofilestop()
						self.overhead.objectFunctions[key] = (self.overhead.objectFunctions[key] or 0) + time
						return unpack(result)
					end
				end
			end

			-- attributes (replace __index) with hooked version
			local mt = getmetatable(object)
			if mt then
				local original_index = mt.__index
				mt.__index = function(t, key)
					debugprofilestart()
					local result = original_index(t, key)
					local time = debugprofilestop()
					self.overhead.objectAttributes[key] = (self.overhead.objectAttributes[key] or 0) + time
					return result
				end
			end

		end
	end

	-- hook all blink functions to track overhead
	for key, value in pairs(blink) do
		if not self.hooked['blink'..key] then
			self.hooked['blink'..key] = true
			if type(value) == "function" then
				blink[key] = function(...)
					if key == 'objectCacheReturnTemplate' then
						print('objectCacheReturnTemplate')
					end
					debugprofilestart()
					local result = {value(...)}
					local time = debugprofilestop()
					self.overhead.blinkFunctions[key] = (self.overhead.blinkFunctions[key] or 0) + time
					return unpack(result)
				end
			end
		end
	end

	-- and blink's mt to track any functional mt fallback calls
	if not self.hooked['blink_mt'] then
		self.hooked['blink_mt'] = true
		local mt = getmetatable(blink)
		local original_index = mt.__index
		mt.__index = function(t, key)
			debugprofilestart()
			local result = original_index(t, key)
			local time = debugprofilestop()
			self.overhead.blinkMetatable[key] = (self.overhead.blinkMetatable[key] or 0) + time
			return result
		end
	end

	-- store overhead in iterative array
	local sorted = {}
	local blinkOverhead = 0
	for profileType, entries in pairs(self.overhead) do
		for key, time in pairs(entries) do
			if key ~= "prefix" then
				blinkOverhead = blinkOverhead + time
				tinsert(sorted, { key, time, entries.prefix })
			end
		end
	end

	-- sort array by shortest overhead (longest = last print out)
	table.sort(sorted, function(a, b)
		return a[2] < b[2]
	end)

	local totalTime = round(GetTime() - self.started, 4)
	
	for i=1,#sorted do
		local key, time, prefix = unpack(sorted[i])
		print(self:ColorByOverhead(round(time, 4), totalTime) .. "ms", "-", (prefix or "") .. key)
	end

	print("---------------------")
	print(blink.colors.orange .. "Blink Overhead: " .. blink.colors.green .. self:ColorByOverhead(round(blinkOverhead / 10 / totalTime, 2), 0.065, true) .. "%")
  print(blink.colors.cyan .. "Profiler Runtime: " .. blink.colors.green .. totalTime .. "s")

end

function Profiler:Toggle()
	if not self.started then
		self.started = GetTime()
		blink.print("|cFF5cffd9profiler:|r enabled")
	else
		self.started = false
		blink.print("|cFF5cffd9profiler:|r disabled", true)
	end
end

C_Timer.NewTicker(1, function()
	Profiler:Tick()
end)

blink.Profiler = Profiler