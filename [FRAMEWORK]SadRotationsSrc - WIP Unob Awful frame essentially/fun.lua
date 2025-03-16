local Unlocker, blink = ...
local player = blink.player

local blinkFont = blink.createFont(16)
blinkFont:SetFont(blinkFont:GetFont(), 16, "THICKOUTLINE")
-- blinkFont:SetShadowColor(0.5,0.5,0.5,1)
-- blinkFont:SetShadowOffset(3,-3)

local tinsert, tonumber = tinsert, tonumber
local find, gmatch, strsub = string.find, string.gmatch, string.sub
local format, rep, tonumber, tostring = string.format, string.rep, tonumber, tostring
local type = type
local pairs, ipairs = pairs, ipairs

local serializable = {
  table = true,
  number = true,
  string = true,
  boolean = true
}
-- limitations:
-- won't properly serialize tables that are both associative and normal arrays
-- if there are normal table additions (from tinsert or t[#t + 1] = v), only those additions will be serialized.
function blink.srlz(val, name, skipnewlines, depth)
  skipnewlines = skipnewlines or true
  depth = depth or 0

  local vtype = type(val)
  if not serializable[vtype] then
    return ""
  end

  local tmp = rep(" ", depth)

  local n2n = tonumber(name)

  if n2n then
    tmp = tmp .. "[" .. name .. "]="
  elseif name then
    -- bracketed string not nessary if valid variable
    -- (alphanumeric and first character is not number)
    if not tonumber(name:sub(1, 1)) and not name:match("%W") then
      tmp = tmp .. name .. "="
    else
      tmp = tmp .. '["' .. name .. '"]='
    end
  end

  if vtype == "table" then
    tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")
    -- if #val > 0 then
    --   -- normal array
    --   for k, v in ipairs(val) do
    --     local subserialize = serialize(v, nil, skipnewlines, depth)
    --     if subserialize ~= "" then
    --       tmp = tmp .. subserialize .. "," .. (not skipnewlines and "\n" or "")
    --     end
    --   end
    -- else
      -- associative array
      for k, v in pairs(val) do
        local subserialize = blink.srlz(v, k, skipnewlines, depth)
        if subserialize ~= "" then
          tmp = tmp .. subserialize .. "," .. (not skipnewlines and "\n" or "")
        end
      end
    -- end
    tmp = tmp .. rep(" ", depth) .. "}"
  elseif vtype == "number" then
    tmp = tmp .. tostring(val)
  elseif vtype == "string" then
    tmp = tmp .. format("%q", val)
  elseif vtype == "boolean" then
    tmp = tmp .. (val and "true" or "false")
  end

  return tmp
end

local loader = {}

-- thx stack overflow!
local function magiclines(s)
  if s:sub(-1)~="\n" then s=s.."\n" end
  return s:gmatch("(.-)\n")
end

local function string_split(s, d)
	local t = {}
	local i = 0
	local f
	local match = '(.-)' .. d .. '()'
	
	if find(s, d) == nil then
		return {s}
	end
	
	for sub, j in gmatch(s, match) do
		i = i + 1
		t[i] = sub
		f = j
	end
	
	if i ~= 0 then
		t[i+1] = strsub(s, f)
	end
	
	return t
end

function loader:Load(file, mtl)

  local materials = mtl and loader:LoadMTL(mtl) or {}

  file = ReadFile(file)
  if not file then return print("Wavefront: File not found") end

	local lines = {}

	for line in magiclines(file) do
		tinsert(lines, line)
	end

	return loader:Parse(lines, materials)
end

function loader:Parse(object, mtl)

	local obj = {
		v	= {}, -- List of vertices - x, y, z, [w]=1.0
		vt	= {}, -- Texture coordinates - u, v, [w]=0
		vn	= {}, -- Normals - x, y, z
		vp	= {}, -- Parameter space vertices - u, [v], [w]
		f	= {}, -- Faces
    materials = mtl
	}

  local current_material = nil

	for _, line in ipairs(object) do
		local l = string_split(line, " ")
		
		if l[1] == "v" then
			local v = {
				x = tonumber(l[2]),
				y = tonumber(l[3]),
				z = tonumber(l[4]),
				w = tonumber(l[5]) or 1.0
			}
			tinsert(obj.v, v)
		elseif l[1] == "vt" then
			local vt = {
				u = tonumber(l[2]),
				v = tonumber(l[3]),
				w = tonumber(l[4]) or 0
			}
			tinsert(obj.vt, vt)
		elseif l[1] == "vn" then
			local vn = {
				x = tonumber(l[2]),
				y = tonumber(l[3]),
				z = tonumber(l[4]),
			}
			tinsert(obj.vn, vn)
		elseif l[1] == "vp" then
			local vp = {
				u = tonumber(l[2]),
				v = tonumber(l[3]),
				w = tonumber(l[4]),
			}
			tinsert(obj.vp, vp)
		elseif l[1] == "f" then
			local f = {
        material = current_material
      }
			for i=2, #l do
				local split = string_split(l[i], "/")
				local v = {}

				v.v = tonumber(split[1])
				if split[2] ~= "" then v.vt = tonumber(split[2]) end
				v.vn = tonumber(split[3])

				tinsert(f, v)
			end
			tinsert(obj.f, f)
    elseif l[1] == "usemtl" then
      current_material = l[2]
		end
	end

	return obj
end

function loader:LoadMTL(file)
  local file_content = ReadFile(file)
  if not file_content then return print("MTL: File not found") end

  local materials = {}
  local current_material = nil

  for line in magiclines(file_content) do
      local l = string_split(line, " ")

      if l[1] == "newmtl" then
          if current_material then
              materials[current_material.name] = current_material
          end
          current_material = {name = l[2]}
      elseif l[1] == "Kd" then
          current_material.Kd = {
              r = tonumber(l[2]),
              g = tonumber(l[3]),
              b = tonumber(l[4])
          }
      end
  end

  if current_material then
      materials[current_material.name] = current_material
  end

  return materials
end

blink.Wavefront = loader

local function penguMessage(penguName, msg)
  print("\124cffff80ff\124Tinterface\\ChatFrame\\UI-ChatIcon-WoW:12:20:0:0:32:16:4:28:0:16\124t ["..penguName.."] whispers: " .. msg)
  PlaySound(3081)
end

-- check if player types "/lay" in chat
local lastPlayerLay = 0
local function LayCommandFilter(self, event, msg, ...)
  local msgLower = msg:lower()
  if msgLower == "you lie down." or msgLower == "you fall asleep.  zzzzzzz." then
      lastPlayerLay = GetTime()
  end
  return false, msg, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", LayCommandFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", LayCommandFilter)

local distance = blink.Distance
local started, finished, index = {}, {}, {}
local rotated, lastMessageIndex = {}, {}
local tostring = tostring

local pengu = {vp={},materials={Black={name="Black",Kd={b=0.003588,g=0.002195,r=0.001782,},},Orange={name="Orange",Kd={b=0.091654,g=0.181283,r=0.8,},},White={name="White",Kd={b=0.8,g=0.8,r=0.8,},},},f={[1]={[1]={vt=10,vn=18,v=8,},[2]={vt=180,vn=18,v=131,},[3]={vt=179,vn=18,v=130,},material="White",},[2]={[1]={vt=33,vn=23,v=26,},[2]={vt=45,vn=23,v=37,},[3]={vt=36,vn=23,v=29,},material="White",},[3]={[1]={vt=37,vn=25,v=29,},[2]={vt=181,vn=25,v=132,},[3]={vt=180,vn=25,v=131,},material="White",},[4]={[1]={vt=11,vn=27,v=8,},[2]={vt=33,vn=27,v=26,},[3]={vt=36,vn=27,v=29,},material="White",},[5]={[1]={vt=61,vn=31,v=50,},[2]={vt=51,vn=31,v=42,},[3]={vt=58,vn=31,v=47,},material="White",},[6]={[1]={vt=52,vn=34,v=42,},[2]={vt=184,vn=34,v=135,},[3]={vt=182,vn=34,v=133,},material="White",},[7]={[1]={vt=57,vn=38,v=47,},[2]={vt=182,vn=38,v=133,},[3]={vt=183,vn=38,v=134,},material="White",},[8]={[1]={vt=46,vn=41,v=37,},[2]={vt=183,vn=41,v=134,},[3]={vt=181,vn=41,v=132,},material="White",},[9]={[1]={vt=43,vn=42,v=35,},[2]={vt=58,vn=42,v=47,},[3]={vt=45,vn=42,v=37,},material="White",},[10]={[1]={vt=65,vn=47,v=54,},[2]={vt=80,vn=47,v=65,},[3]={vt=68,vn=47,v=56,},material="White",},[11]={[1]={vt=67,vn=49,v=56,},[2]={vt=185,vn=49,v=136,},[3]={vt=184,vn=49,v=135,},material="White",},[12]={[1]={vt=40,vn=51,v=32,},[2]={vt=68,vn=51,v=56,},[3]={vt=51,vn=51,v=42,},material="White",},[13]={[1]={vt=139,vn=53,v=98,},[2]={vt=187,vn=53,v=138,},[3]={vt=199,vn=53,v=150,},material="White",},[14]={[1]={vt=186,vn=61,v=137,},[2]={vt=101,vn=61,v=79,},[3]={vt=188,vn=61,v=139,},material="White",},[15]={[1]={vt=143,vn=62,v=100,},[2]={vt=96,vn=62,v=77,},[3]={vt=138,vn=62,v=98,},material="White",},[16]={[1]={vt=145,vn=63,v=101,},[2]={vt=94,vn=63,v=76,},[3]={vt=93,vn=63,v=75,},material="White",},[17]={[1]={vt=198,vn=64,v=149,},[2]={vt=92,vn=64,v=75,},[3]={vt=186,vn=64,v=137,},material="White",},[18]={[1]={vt=96,vn=66,v=77,},[2]={vt=98,vn=66,v=78,},[3]={vt=105,vn=66,v=81,},material="White",},[19]={[1]={vt=93,vn=67,v=75,},[2]={vt=102,vn=67,v=80,},[3]={vt=100,vn=67,v=79,},material="White",},[20]={[1]={vt=187,vn=68,v=138,},[2]={vt=104,vn=68,v=81,},[3]={vt=189,vn=68,v=140,},material="White",},[21]={[1]={vt=74,vn=84,v=62,},[2]={vt=198,vn=84,v=149,},[3]={vt=142,vn=84,v=100,},material="White",},[22]={[1]={vt=77,vn=85,v=63,},[2]={vt=140,vn=85,v=99,},[3]={vt=145,vn=85,v=101,},material="White",},[23]={[1]={vt=75,vn=86,v=62,},[2]={vt=138,vn=86,v=98,},[3]={vt=80,vn=86,v=65,},material="White",},[24]={[1]={vt=81,vn=87,v=65,},[2]={vt=199,vn=87,v=150,},[3]={vt=185,vn=87,v=136,},material="White",},[25]={[1]={vt=185,vn=114,v=136,},[2]={vt=141,vn=114,v=99,},[3]={vt=79,vn=114,v=64,},material="White",},[26]={[1]={vt=187,vn=122,v=138,},[2]={vt=103,vn=122,v=80,},[3]={vt=95,vn=122,v=76,},material="White",},[27]={[1]={vt=198,vn=123,v=149,},[2]={vt=91,vn=123,v=74,},[3]={vt=142,vn=123,v=100,},material="White",},[28]={[1]={vt=186,vn=124,v=137,},[2]={vt=99,vn=124,v=78,},[3]={vt=91,vn=124,v=74,},material="White",},[29]={[1]={vt=199,vn=125,v=150,},[2]={vt=95,vn=125,v=76,},[3]={vt=141,vn=125,v=99,},material="White",},[30]={[1]={vt=184,vn=126,v=135,},[2]={vt=79,vn=126,v=64,},[3]={vt=66,vn=126,v=55,},material="White",},[31]={[1]={vt=181,vn=127,v=132,},[2]={vt=62,vn=127,v=51,},[3]={vt=44,vn=127,v=36,},material="White",},[32]={[1]={vt=183,vn=128,v=134,},[2]={vt=50,vn=128,v=41,},[3]={vt=62,vn=128,v=51,},material="White",},[33]={[1]={vt=182,vn=129,v=133,},[2]={vt=66,vn=129,v=55,},[3]={vt=50,vn=129,v=41,},material="White",},[34]={[1]={vt=180,vn=130,v=131,},[2]={vt=44,vn=130,v=36,},[3]={vt=35,vn=130,v=28,},material="White",},[35]={[1]={vt=12,vn=131,v=9,},[2]={vt=180,vn=131,v=131,},[3]={vt=35,vn=131,v=28,},material="White",},[36]={[1]={vt=10,vn=149,v=8,},[2]={vt=37,vn=149,v=29,},[3]={vt=180,vn=149,v=131,},material="White",},[37]={[1]={vt=33,vn=153,v=26,},[2]={vt=43,vn=153,v=35,},[3]={vt=45,vn=153,v=37,},material="White",},[38]={[1]={vt=37,vn=155,v=29,},[2]={vt=46,vn=155,v=37,},[3]={vt=181,vn=155,v=132,},material="White",},[39]={[1]={vt=11,vn=157,v=8,},[2]={vt=5,vn=157,v=4,},[3]={vt=33,vn=157,v=26,},material="White",},[40]={[1]={vt=61,vn=161,v=50,},[2]={vt=40,vn=161,v=32,},[3]={vt=51,vn=161,v=42,},material="White",},[41]={[1]={vt=52,vn=164,v=42,},[2]={vt=67,vn=164,v=56,},[3]={vt=184,vn=164,v=135,},material="White",},[42]={[1]={vt=57,vn=168,v=47,},[2]={vt=52,vn=168,v=42,},[3]={vt=182,vn=168,v=133,},material="White",},[43]={[1]={vt=46,vn=171,v=37,},[2]={vt=57,vn=171,v=47,},[3]={vt=183,vn=171,v=134,},material="White",},[44]={[1]={vt=43,vn=172,v=35,},[2]={vt=61,vn=172,v=50,},[3]={vt=58,vn=172,v=47,},material="White",},[45]={[1]={vt=65,vn=177,v=54,},[2]={vt=75,vn=177,v=62,},[3]={vt=80,vn=177,v=65,},material="White",},[46]={[1]={vt=67,vn=179,v=56,},[2]={vt=81,vn=179,v=65,},[3]={vt=185,vn=179,v=136,},material="White",},[47]={[1]={vt=40,vn=181,v=32,},[2]={vt=65,vn=181,v=54,},[3]={vt=68,vn=181,v=56,},material="White",},[48]={[1]={vt=139,vn=184,v=98,},[2]={vt=97,vn=184,v=77,},[3]={vt=187,vn=184,v=138,},material="White",},[49]={[1]={vt=186,vn=192,v=137,},[2]={vt=92,vn=192,v=75,},[3]={vt=101,vn=192,v=79,},material="White",},[50]={[1]={vt=143,vn=193,v=100,},[2]={vt=90,vn=193,v=74,},[3]={vt=96,vn=193,v=77,},material="White",},[51]={[1]={vt=145,vn=194,v=101,},[2]={vt=140,vn=194,v=99,},[3]={vt=94,vn=194,v=76,},material="White",},[52]={[1]={vt=198,vn=195,v=149,},[2]={vt=146,vn=195,v=101,},[3]={vt=92,vn=195,v=75,},material="White",},[53]={[1]={vt=96,vn=197,v=77,},[2]={vt=90,vn=197,v=74,},[3]={vt=98,vn=197,v=78,},material="White",},[54]={[1]={vt=93,vn=198,v=75,},[2]={vt=94,vn=198,v=76,},[3]={vt=102,vn=198,v=80,},material="White",},[55]={[1]={vt=187,vn=199,v=138,},[2]={vt=97,vn=199,v=77,},[3]={vt=104,vn=199,v=81,},material="White",},[56]={[1]={vt=74,vn=84,v=62,},[2]={vt=146,vn=84,v=101,},[3]={vt=198,vn=84,v=149,},material="White",},[57]={[1]={vt=77,vn=214,v=63,},[2]={vt=78,vn=214,v=64,},[3]={vt=140,vn=214,v=99,},material="White",},[58]={[1]={vt=75,vn=215,v=62,},[2]={vt=143,vn=215,v=100,},[3]={vt=138,vn=215,v=98,},material="White",},[59]={[1]={vt=81,vn=216,v=65,},[2]={vt=139,vn=216,v=98,},[3]={vt=199,vn=216,v=150,},material="White",},[60]={[1]={vt=185,vn=242,v=136,},[2]={vt=199,vn=242,v=150,},[3]={vt=141,vn=242,v=99,},material="White",},[61]={[1]={vt=187,vn=68,v=138,},[2]={vt=189,vn=68,v=140,},[3]={vt=103,vn=68,v=80,},material="White",},[62]={[1]={vt=198,vn=64,v=149,},[2]={vt=186,vn=64,v=137,},[3]={vt=91,vn=64,v=74,},material="White",},[63]={[1]={vt=186,vn=61,v=137,},[2]={vt=188,vn=61,v=139,},[3]={vt=99,vn=61,v=78,},material="White",},[64]={[1]={vt=199,vn=245,v=150,},[2]={vt=187,vn=245,v=138,},[3]={vt=95,vn=245,v=76,},material="White",},[65]={[1]={vt=184,vn=246,v=135,},[2]={vt=185,vn=246,v=136,},[3]={vt=79,vn=246,v=64,},material="White",},[66]={[1]={vt=181,vn=247,v=132,},[2]={vt=183,vn=247,v=134,},[3]={vt=62,vn=247,v=51,},material="White",},[67]={[1]={vt=183,vn=248,v=134,},[2]={vt=182,vn=248,v=133,},[3]={vt=50,vn=248,v=41,},material="White",},[68]={[1]={vt=182,vn=249,v=133,},[2]={vt=184,vn=249,v=135,},[3]={vt=66,vn=249,v=55,},material="White",},[69]={[1]={vt=180,vn=250,v=131,},[2]={vt=181,vn=250,v=132,},[3]={vt=44,vn=250,v=36,},material="White",},[70]={[1]={vt=12,vn=251,v=9,},[2]={vt=179,vn=251,v=130,},[3]={vt=180,vn=251,v=131,},material="White",},[71]={[1]={vt=210,vn=271,v=159,},[2]={vt=351,vn=271,v=257,},[3]={vt=352,vn=271,v=258,},material="White",},[72]={[1]={vt=224,vn=276,v=170,},[2]={vt=226,vn=276,v=172,},[3]={vt=233,vn=276,v=178,},material="White",},[73]={[1]={vt=227,vn=278,v=172,},[2]={vt=352,vn=278,v=258,},[3]={vt=353,vn=278,v=259,},material="White",},[74]={[1]={vt=211,vn=280,v=159,},[2]={vt=226,vn=280,v=172,},[3]={vt=224,vn=280,v=170,},material="White",},[75]={[1]={vt=245,vn=284,v=187,},[2]={vt=243,vn=284,v=185,},[3]={vt=237,vn=284,v=181,},material="White",},[76]={[1]={vt=238,vn=287,v=181,},[2]={vt=354,vn=287,v=260,},[3]={vt=356,vn=287,v=262,},material="White",},[77]={[1]={vt=242,vn=291,v=185,},[2]={vt=355,vn=291,v=261,},[3]={vt=354,vn=291,v=260,},material="White",},[78]={[1]={vt=234,vn=294,v=178,},[2]={vt=353,vn=294,v=259,},[3]={vt=355,vn=294,v=261,},material="White",},[79]={[1]={vt=232,vn=295,v=177,},[2]={vt=233,vn=295,v=178,},[3]={vt=243,vn=295,v=185,},material="White",},[80]={[1]={vt=248,vn=300,v=190,},[2]={vt=250,vn=300,v=191,},[3]={vt=256,vn=300,v=196,},material="White",},[81]={[1]={vt=249,vn=302,v=191,},[2]={vt=356,vn=302,v=262,},[3]={vt=357,vn=302,v=263,},material="White",},[82]={[1]={vt=230,vn=304,v=175,},[2]={vt=237,vn=304,v=181,},[3]={vt=250,vn=304,v=191,},material="White",},[83]={[1]={vt=311,vn=306,v=225,},[2]={vt=371,vn=306,v=277,},[3]={vt=359,vn=306,v=265,},material="White",},[84]={[1]={vt=358,vn=314,v=264,},[2]={vt=360,vn=314,v=266,},[3]={vt=273,vn=314,v=206,},material="White",},[85]={[1]={vt=315,vn=315,v=227,},[2]={vt=310,vn=315,v=225,},[3]={vt=268,vn=315,v=204,},material="White",},[86]={[1]={vt=317,vn=316,v=228,},[2]={vt=265,vn=316,v=202,},[3]={vt=266,vn=316,v=203,},material="White",},[87]={[1]={vt=370,vn=317,v=276,},[2]={vt=358,vn=317,v=264,},[3]={vt=264,vn=317,v=202,},material="White",},[88]={[1]={vt=268,vn=319,v=204,},[2]={vt=277,vn=319,v=208,},[3]={vt=270,vn=319,v=205,},material="White",},[89]={[1]={vt=265,vn=320,v=202,},[2]={vt=272,vn=320,v=206,},[3]={vt=274,vn=320,v=207,},material="White",},[90]={[1]={vt=359,vn=321,v=265,},[2]={vt=361,vn=321,v=267,},[3]={vt=276,vn=321,v=208,},material="White",},[91]={[1]={vt=254,vn=336,v=195,},[2]={vt=314,vn=336,v=227,},[3]={vt=370,vn=336,v=276,},material="White",},[92]={[1]={vt=77,vn=337,v=63,},[2]={vt=317,vn=337,v=228,},[3]={vt=312,vn=337,v=226,},material="White",},[93]={[1]={vt=255,vn=338,v=195,},[2]={vt=256,vn=338,v=196,},[3]={vt=310,vn=338,v=225,},material="White",},[94]={[1]={vt=257,vn=339,v=196,},[2]={vt=357,vn=339,v=263,},[3]={vt=371,vn=339,v=277,},material="White",},[95]={[1]={vt=357,vn=366,v=263,},[2]={vt=79,vn=366,v=64,},[3]={vt=313,vn=366,v=226,},material="White",},[96]={[1]={vt=359,vn=374,v=265,},[2]={vt=267,vn=374,v=203,},[3]={vt=275,vn=374,v=207,},material="White",},[97]={[1]={vt=370,vn=375,v=276,},[2]={vt=314,vn=375,v=227,},[3]={vt=263,vn=375,v=201,},material="White",},[98]={[1]={vt=358,vn=376,v=264,},[2]={vt=263,vn=376,v=201,},[3]={vt=271,vn=376,v=205,},material="White",},[99]={[1]={vt=371,vn=377,v=277,},[2]={vt=313,vn=377,v=226,},[3]={vt=267,vn=377,v=203,},material="White",},[100]={[1]={vt=356,vn=378,v=262,},[2]={vt=66,vn=378,v=55,},[3]={vt=79,vn=378,v=64,},material="White",},[101]={[1]={vt=353,vn=379,v=259,},[2]={vt=44,vn=379,v=36,},[3]={vt=62,vn=379,v=51,},material="White",},[102]={[1]={vt=355,vn=380,v=261,},[2]={vt=62,vn=380,v=51,},[3]={vt=50,vn=380,v=41,},material="White",},[103]={[1]={vt=354,vn=381,v=260,},[2]={vt=50,vn=381,v=41,},[3]={vt=66,vn=381,v=55,},material="White",},[104]={[1]={vt=352,vn=382,v=258,},[2]={vt=35,vn=382,v=28,},[3]={vt=44,vn=382,v=36,},material="White",},[105]={[1]={vt=12,vn=383,v=9,},[2]={vt=35,vn=383,v=28,},[3]={vt=352,vn=383,v=258,},material="White",},[106]={[1]={vt=210,vn=401,v=159,},[2]={vt=352,vn=401,v=258,},[3]={vt=227,vn=401,v=172,},material="White",},[107]={[1]={vt=224,vn=405,v=170,},[2]={vt=233,vn=405,v=178,},[3]={vt=232,vn=405,v=177,},material="White",},[108]={[1]={vt=227,vn=407,v=172,},[2]={vt=353,vn=407,v=259,},[3]={vt=234,vn=407,v=178,},material="White",},[109]={[1]={vt=211,vn=409,v=159,},[2]={vt=224,vn=409,v=170,},[3]={vt=207,vn=409,v=157,},material="White",},[110]={[1]={vt=245,vn=413,v=187,},[2]={vt=237,vn=413,v=181,},[3]={vt=230,vn=413,v=175,},material="White",},[111]={[1]={vt=238,vn=416,v=181,},[2]={vt=356,vn=416,v=262,},[3]={vt=249,vn=416,v=191,},material="White",},[112]={[1]={vt=242,vn=420,v=185,},[2]={vt=354,vn=420,v=260,},[3]={vt=238,vn=420,v=181,},material="White",},[113]={[1]={vt=234,vn=423,v=178,},[2]={vt=355,vn=423,v=261,},[3]={vt=242,vn=423,v=185,},material="White",},[114]={[1]={vt=232,vn=424,v=177,},[2]={vt=243,vn=424,v=185,},[3]={vt=245,vn=424,v=187,},material="White",},[115]={[1]={vt=248,vn=429,v=190,},[2]={vt=256,vn=429,v=196,},[3]={vt=255,vn=429,v=195,},material="White",},[116]={[1]={vt=249,vn=431,v=191,},[2]={vt=357,vn=431,v=263,},[3]={vt=257,vn=431,v=196,},material="White",},[117]={[1]={vt=230,vn=433,v=175,},[2]={vt=250,vn=433,v=191,},[3]={vt=248,vn=433,v=190,},material="White",},[118]={[1]={vt=311,vn=436,v=225,},[2]={vt=359,vn=436,v=265,},[3]={vt=269,vn=436,v=204,},material="White",},[119]={[1]={vt=358,vn=444,v=264,},[2]={vt=273,vn=444,v=206,},[3]={vt=264,vn=444,v=202,},material="White",},[120]={[1]={vt=315,vn=445,v=227,},[2]={vt=268,vn=445,v=204,},[3]={vt=262,vn=445,v=201,},material="White",},[121]={[1]={vt=317,vn=446,v=228,},[2]={vt=266,vn=446,v=203,},[3]={vt=312,vn=446,v=226,},material="White",},[122]={[1]={vt=370,vn=447,v=276,},[2]={vt=264,vn=447,v=202,},[3]={vt=318,vn=447,v=228,},material="White",},[123]={[1]={vt=268,vn=449,v=204,},[2]={vt=270,vn=449,v=205,},[3]={vt=262,vn=449,v=201,},material="White",},[124]={[1]={vt=265,vn=450,v=202,},[2]={vt=274,vn=450,v=207,},[3]={vt=266,vn=450,v=203,},material="White",},[125]={[1]={vt=359,vn=451,v=265,},[2]={vt=276,vn=451,v=208,},[3]={vt=269,vn=451,v=204,},material="White",},[126]={[1]={vt=254,vn=336,v=195,},[2]={vt=370,vn=336,v=276,},[3]={vt=318,vn=336,v=228,},material="White",},[127]={[1]={vt=77,vn=466,v=63,},[2]={vt=312,vn=466,v=226,},[3]={vt=78,vn=466,v=64,},material="White",},[128]={[1]={vt=255,vn=467,v=195,},[2]={vt=310,vn=467,v=225,},[3]={vt=315,vn=467,v=227,},material="White",},[129]={[1]={vt=257,vn=468,v=196,},[2]={vt=371,vn=468,v=277,},[3]={vt=311,vn=468,v=225,},material="White",},[130]={[1]={vt=357,vn=494,v=263,},[2]={vt=313,vn=494,v=226,},[3]={vt=371,vn=494,v=277,},material="White",},[131]={[1]={vt=359,vn=321,v=265,},[2]={vt=275,vn=321,v=207,},[3]={vt=361,vn=321,v=267,},material="White",},[132]={[1]={vt=370,vn=317,v=276,},[2]={vt=263,vn=317,v=201,},[3]={vt=358,vn=317,v=264,},material="White",},[133]={[1]={vt=358,vn=314,v=264,},[2]={vt=271,vn=314,v=205,},[3]={vt=360,vn=314,v=266,},material="White",},[134]={[1]={vt=371,vn=497,v=277,},[2]={vt=267,vn=497,v=203,},[3]={vt=359,vn=497,v=265,},material="White",},[135]={[1]={vt=356,vn=498,v=262,},[2]={vt=79,vn=498,v=64,},[3]={vt=357,vn=498,v=263,},material="White",},[136]={[1]={vt=353,vn=499,v=259,},[2]={vt=62,vn=499,v=51,},[3]={vt=355,vn=499,v=261,},material="White",},[137]={[1]={vt=355,vn=500,v=261,},[2]={vt=50,vn=500,v=41,},[3]={vt=354,vn=500,v=260,},material="White",},[138]={[1]={vt=354,vn=501,v=260,},[2]={vt=66,vn=501,v=55,},[3]={vt=356,vn=501,v=262,},material="White",},[139]={[1]={vt=352,vn=502,v=258,},[2]={vt=44,vn=502,v=36,},[3]={vt=353,vn=502,v=259,},material="White",},[140]={[1]={vt=12,vn=503,v=9,},[2]={vt=352,vn=503,v=258,},[3]={vt=351,vn=503,v=257,},material="White",},[141]={[1]={vt=27,vn=1,v=20,},[2]={vt=11,vn=1,v=8,},[3]={vt=28,vn=1,v=21,},material="Black",},[142]={[1]={vt=27,vn=2,v=20,},[2]={vt=1,vn=2,v=1,},[3]={vt=26,vn=2,v=19,},material="Black",},[143]={[1]={vt=1,vn=3,v=1,},[2]={vt=16,vn=3,v=13,},[3]={vt=14,vn=3,v=11,},material="Black",},[144]={[1]={vt=2,vn=4,v=2,},[2]={vt=39,vn=4,v=31,},[3]={vt=32,vn=4,v=25,},material="Black",},[145]={[1]={vt=4,vn=5,v=3,},[2]={vt=6,vn=5,v=5,},[3]={vt=1,vn=5,v=1,},material="Black",},[146]={[1]={vt=13,vn=6,v=10,},[2]={vt=17,vn=6,v=14,},[3]={vt=22,vn=6,v=17,},material="Black",},[147]={[1]={vt=4,vn=7,v=3,},[2]={vt=13,vn=7,v=10,},[3]={vt=7,vn=7,v=6,},material="Black",},[148]={[1]={vt=5,vn=8,v=4,},[2]={vt=32,vn=8,v=25,},[3]={vt=33,vn=8,v=26,},material="Black",},[149]={[1]={vt=14,vn=9,v=11,},[2]={vt=30,vn=9,v=23,},[3]={vt=29,vn=9,v=22,},material="Black",},[150]={[1]={vt=29,vn=10,v=22,},[2]={vt=41,vn=10,v=33,},[3]={vt=38,vn=10,v=30,},material="Black",},[151]={[1]={vt=26,vn=11,v=19,},[2]={vt=14,vn=11,v=11,},[3]={vt=29,vn=11,v=22,},material="Black",},[152]={[1]={vt=179,vn=12,v=130,},[2]={vt=20,vn=12,v=15,},[3]={vt=10,vn=12,v=8,},material="Black",},[153]={[1]={vt=11,vn=13,v=8,},[2]={vt=31,vn=13,v=24,},[3]={vt=28,vn=13,v=21,},material="Black",},[154]={[1]={vt=18,vn=14,v=14,},[2]={vt=202,vn=14,v=153,},[3]={vt=24,vn=14,v=18,},material="Black",},[155]={[1]={vt=22,vn=15,v=17,},[2]={vt=17,vn=15,v=14,},[3]={vt=23,vn=15,v=18,},material="Black",},[156]={[1]={vt=28,vn=16,v=21,},[2]={vt=31,vn=16,v=24,},[3]={vt=202,vn=16,v=153,},material="Black",},[157]={[1]={vt=26,vn=17,v=19,},[2]={vt=15,vn=17,v=12,},[3]={vt=2,vn=17,v=2,},material="Black",},[158]={[1]={vt=5,vn=19,v=4,},[2]={vt=26,vn=19,v=19,},[3]={vt=2,vn=19,v=2,},material="Black",},[159]={[1]={vt=27,vn=20,v=20,},[2]={vt=9,vn=20,v=7,},[3]={vt=3,vn=20,v=3,},material="Black",},[160]={[1]={vt=24,vn=21,v=18,},[2]={vt=31,vn=21,v=24,},[3]={vt=19,vn=21,v=15,},material="Black",},[161]={[1]={vt=43,vn=22,v=35,},[2]={vt=156,vn=22,v=107,},[3]={vt=159,vn=22,v=110,},material="Black",},[162]={[1]={vt=38,vn=24,v=30,},[2]={vt=49,vn=24,v=40,},[3]={vt=47,vn=24,v=38,},material="Black",},[163]={[1]={vt=15,vn=26,v=12,},[2]={vt=38,vn=26,v=30,},[3]={vt=39,vn=26,v=31,},material="Black",},[164]={[1]={vt=59,vn=28,v=48,},[2]={vt=53,vn=28,v=43,},[3]={vt=54,vn=28,v=44,},material="Black",},[165]={[1]={vt=56,vn=29,v=46,},[2]={vt=40,vn=29,v=32,},[3]={vt=61,vn=29,v=50,},material="Black",},[166]={[1]={vt=56,vn=30,v=46,},[2]={vt=54,vn=30,v=44,},[3]={vt=34,vn=30,v=27,},material="Black",},[167]={[1]={vt=32,vn=32,v=25,},[2]={vt=156,vn=32,v=107,},[3]={vt=33,vn=32,v=26,},material="Black",},[168]={[1]={vt=39,vn=33,v=31,},[2]={vt=47,vn=33,v=38,},[3]={vt=48,vn=33,v=39,},material="Black",},[169]={[1]={vt=54,vn=35,v=44,},[2]={vt=69,vn=35,v=57,},[3]={vt=70,vn=35,v=58,},material="Black",},[170]={[1]={vt=34,vn=36,v=27,},[2]={vt=65,vn=36,v=54,},[3]={vt=40,vn=36,v=32,},material="Black",},[171]={[1]={vt=34,vn=37,v=27,},[2]={vt=70,vn=37,v=58,},[3]={vt=64,vn=37,v=53,},material="Black",},[172]={[1]={vt=63,vn=39,v=52,},[2]={vt=55,vn=39,v=45,},[3]={vt=53,vn=39,v=43,},material="Black",},[173]={[1]={vt=49,vn=40,v=40,},[2]={vt=63,vn=40,v=52,},[3]={vt=47,vn=40,v=38,},material="Black",},[174]={[1]={vt=48,vn=43,v=39,},[2]={vt=56,vn=43,v=46,},[3]={vt=42,vn=43,v=34,},material="Black",},[175]={[1]={vt=42,vn=44,v=34,},[2]={vt=61,vn=44,v=50,},[3]={vt=43,vn=44,v=35,},material="Black",},[176]={[1]={vt=47,vn=45,v=38,},[2]={vt=59,vn=45,v=48,},[3]={vt=48,vn=45,v=39,},material="Black",},[177]={[1]={vt=64,vn=46,v=53,},[2]={vt=83,vn=46,v=67,},[3]={vt=72,vn=46,v=60,},material="Black",},[178]={[1]={vt=71,vn=48,v=59,},[2]={vt=82,vn=48,v=66,},[3]={vt=69,vn=48,v=57,},material="Black",},[179]={[1]={vt=53,vn=50,v=43,},[2]={vt=71,vn=50,v=59,},[3]={vt=69,vn=50,v=57,},material="Black",},[180]={[1]={vt=72,vn=52,v=60,},[2]={vt=73,vn=52,v=61,},[3]={vt=144,vn=52,v=101,},material="Black",},[181]={[1]={vt=73,vn=54,v=61,},[2]={vt=83,vn=54,v=67,},[3]={vt=84,vn=54,v=68,},material="Black",},[182]={[1]={vt=84,vn=55,v=68,},[2]={vt=87,vn=55,v=71,},[3]={vt=88,vn=55,v=72,},material="Black",},[183]={[1]={vt=70,vn=56,v=58,},[2]={vt=82,vn=56,v=66,},[3]={vt=83,vn=56,v=67,},material="Black",},[184]={[1]={vt=64,vn=57,v=53,},[2]={vt=75,vn=57,v=62,},[3]={vt=65,vn=57,v=54,},material="Black",},[185]={[1]={vt=87,vn=58,v=71,},[2]={vt=89,vn=58,v=73,},[3]={vt=88,vn=58,v=72,},material="Black",},[186]={[1]={vt=82,vn=59,v=66,},[2]={vt=87,vn=59,v=71,},[3]={vt=83,vn=59,v=67,},material="Black",},[187]={[1]={vt=85,vn=60,v=69,},[2]={vt=86,vn=60,v=70,},[3]={vt=82,vn=60,v=66,},material="Black",},[188]={[1]={vt=122,vn=65,v=90,},[2]={vt=113,vn=65,v=85,},[3]={vt=124,vn=65,v=91,},material="Black",},[189]={[1]={vt=112,vn=69,v=85,},[2]={vt=193,vn=69,v=144,},[3]={vt=191,vn=69,v=142,},material="Black",},[190]={[1]={vt=129,vn=70,v=93,},[2]={vt=110,vn=70,v=84,},[3]={vt=108,vn=70,v=83,},material="Black",},[191]={[1]={vt=125,vn=71,v=91,},[2]={vt=191,vn=71,v=142,},[3]={vt=195,vn=71,v=146,},material="Black",},[192]={[1]={vt=194,vn=72,v=145,},[2]={vt=109,vn=72,v=83,},[3]={vt=190,vn=72,v=141,},material="Black",},[193]={[1]={vt=120,vn=73,v=89,},[2]={vt=130,vn=73,v=94,},[3]={vt=137,vn=73,v=97,},material="Black",},[194]={[1]={vt=109,vn=74,v=83,},[2]={vt=192,vn=74,v=143,},[3]={vt=190,vn=74,v=141,},material="Black",},[195]={[1]={vt=113,vn=75,v=85,},[2]={vt=115,vn=75,v=86,},[3]={vt=120,vn=75,v=89,},material="Black",},[196]={[1]={vt=110,vn=76,v=84,},[2]={vt=116,vn=76,v=87,},[3]={vt=108,vn=76,v=83,},material="Black",},[197]={[1]={vt=188,vn=77,v=139,},[2]={vt=128,vn=77,v=93,},[3]={vt=194,vn=77,v=145,},material="Black",},[198]={[1]={vt=189,vn=78,v=140,},[2]={vt=125,vn=78,v=91,},[3]={vt=195,vn=78,v=146,},material="Black",},[199]={[1]={vt=102,vn=79,v=80,},[2]={vt=129,vn=79,v=93,},[3]={vt=100,vn=79,v=79,},material="Black",},[200]={[1]={vt=105,vn=80,v=81,},[2]={vt=122,vn=80,v=90,},[3]={vt=124,vn=80,v=91,},material="Black",},[201]={[1]={vt=197,vn=81,v=148,},[2]={vt=154,vn=81,v=105,},[3]={vt=201,vn=81,v=152,},material="Black",},[202]={[1]={vt=119,vn=82,v=88,},[2]={vt=132,vn=82,v=95,},[3]={vt=116,vn=82,v=87,},material="Black",},[203]={[1]={vt=193,vn=83,v=144,},[2]={vt=136,vn=83,v=97,},[3]={vt=197,vn=83,v=148,},material="Black",},[204]={[1]={vt=192,vn=74,v=143,},[2]={vt=133,vn=74,v=95,},[3]={vt=196,vn=74,v=147,},material="Black",},[205]={[1]={vt=200,vn=74,v=151,},[2]={vt=152,vn=74,v=104,},[3]={vt=201,vn=74,v=152,},material="Black",},[206]={[1]={vt=196,vn=74,v=147,},[2]={vt=149,vn=74,v=103,},[3]={vt=200,vn=74,v=151,},material="Black",},[207]={[1]={vt=137,vn=88,v=97,},[2]={vt=147,vn=88,v=102,},[3]={vt=153,vn=88,v=105,},material="Black",},[208]={[1]={vt=134,vn=89,v=96,},[2]={vt=150,vn=89,v=103,},[3]={vt=132,vn=89,v=95,},material="Black",},[209]={[1]={vt=155,vn=90,v=106,},[2]={vt=160,vn=90,v=111,},[3]={vt=158,vn=90,v=109,},material="Black",},[210]={[1]={vt=155,vn=91,v=106,},[2]={vt=159,vn=91,v=110,},[3]={vt=156,vn=91,v=107,},material="Black",},[211]={[1]={vt=158,vn=92,v=109,},[2]={vt=165,vn=92,v=116,},[3]={vt=159,vn=92,v=110,},material="Black",},[212]={[1]={vt=159,vn=93,v=110,},[2]={vt=162,vn=93,v=113,},[3]={vt=43,vn=93,v=35,},material="Black",},[213]={[1]={vt=48,vn=94,v=39,},[2]={vt=157,vn=94,v=108,},[3]={vt=39,vn=94,v=31,},material="Black",},[214]={[1]={vt=32,vn=95,v=25,},[2]={vt=157,vn=95,v=108,},[3]={vt=155,vn=95,v=106,},material="Black",},[215]={[1]={vt=164,vn=96,v=115,},[2]={vt=171,vn=96,v=122,},[3]={vt=165,vn=96,v=116,},material="Black",},[216]={[1]={vt=165,vn=97,v=116,},[2]={vt=168,vn=97,v=119,},[3]={vt=162,vn=97,v=113,},material="Black",},[217]={[1]={vt=42,vn=98,v=34,},[2]={vt=162,vn=98,v=113,},[3]={vt=161,vn=98,v=112,},material="Black",},[218]={[1]={vt=48,vn=99,v=39,},[2]={vt=161,vn=99,v=112,},[3]={vt=163,vn=99,v=114,},material="Black",},[219]={[1]={vt=160,vn=100,v=111,},[2]={vt=164,vn=100,v=115,},[3]={vt=158,vn=100,v=109,},material="Black",},[220]={[1]={vt=160,vn=101,v=111,},[2]={vt=163,vn=101,v=114,},[3]={vt=166,vn=101,v=117,},material="Black",},[221]={[1]={vt=167,vn=102,v=118,},[2]={vt=175,vn=102,v=126,},[3]={vt=169,vn=102,v=120,},material="Black",},[222]={[1]={vt=170,vn=103,v=121,},[2]={vt=178,vn=103,v=129,},[3]={vt=176,vn=103,v=127,},material="Black",},[223]={[1]={vt=161,vn=104,v=112,},[2]={vt=168,vn=104,v=119,},[3]={vt=167,vn=104,v=118,},material="Black",},[224]={[1]={vt=164,vn=105,v=115,},[2]={vt=172,vn=105,v=123,},[3]={vt=170,vn=105,v=121,},material="Black",},[225]={[1]={vt=161,vn=106,v=112,},[2]={vt=169,vn=106,v=120,},[3]={vt=163,vn=106,v=114,},material="Black",},[226]={[1]={vt=166,vn=107,v=117,},[2]={vt=169,vn=107,v=120,},[3]={vt=172,vn=107,v=123,},material="Black",},[227]={[1]={vt=173,vn=108,v=124,},[2]={vt=177,vn=108,v=128,},[3]={vt=176,vn=108,v=127,},material="Black",},[228]={[1]={vt=175,vn=109,v=126,},[2]={vt=176,vn=109,v=127,},[3]={vt=178,vn=109,v=129,},material="Black",},[229]={[1]={vt=172,vn=110,v=123,},[2]={vt=175,vn=110,v=126,},[3]={vt=178,vn=110,v=129,},material="Black",},[230]={[1]={vt=171,vn=111,v=122,},[2]={vt=174,vn=111,v=125,},[3]={vt=168,vn=111,v=119,},material="Black",},[231]={[1]={vt=171,vn=112,v=122,},[2]={vt=176,vn=112,v=127,},[3]={vt=177,vn=112,v=128,},material="Black",},[232]={[1]={vt=167,vn=113,v=118,},[2]={vt=174,vn=113,v=125,},[3]={vt=173,vn=113,v=124,},material="Black",},[233]={[1]={vt=196,vn=74,v=147,},[2]={vt=148,vn=74,v=102,},[3]={vt=131,vn=74,v=94,},material="Black",},[234]={[1]={vt=200,vn=74,v=151,},[2]={vt=154,vn=74,v=105,},[3]={vt=148,vn=74,v=102,},material="Black",},[235]={[1]={vt=192,vn=74,v=143,},[2]={vt=131,vn=74,v=94,},[3]={vt=114,vn=74,v=86,},material="Black",},[236]={[1]={vt=193,vn=115,v=144,},[2]={vt=135,vn=115,v=96,},[3]={vt=118,vn=115,v=88,},material="Black",},[237]={[1]={vt=197,vn=116,v=148,},[2]={vt=152,vn=116,v=104,},[3]={vt=135,vn=116,v=96,},material="Black",},[238]={[1]={vt=103,vn=117,v=80,},[2]={vt=195,vn=117,v=146,},[3]={vt=127,vn=117,v=92,},material="Black",},[239]={[1]={vt=188,vn=118,v=139,},[2]={vt=123,vn=118,v=90,},[3]={vt=99,vn=118,v=78,},material="Black",},[240]={[1]={vt=107,vn=74,v=82,},[2]={vt=192,vn=74,v=143,},[3]={vt=114,vn=74,v=86,},material="Black",},[241]={[1]={vt=123,vn=119,v=90,},[2]={vt=190,vn=119,v=141,},[3]={vt=107,vn=119,v=82,},material="Black",},[242]={[1]={vt=127,vn=120,v=92,},[2]={vt=191,vn=120,v=142,},[3]={vt=111,vn=120,v=84,},material="Black",},[243]={[1]={vt=111,vn=121,v=84,},[2]={vt=193,vn=121,v=144,},[3]={vt=118,vn=121,v=88,},material="Black",},[244]={[1]={vt=179,vn=132,v=130,},[2]={vt=12,vn=132,v=9,},[3]={vt=21,vn=132,v=16,},material="Black",},[245]={[1]={vt=27,vn=134,v=20,},[2]={vt=5,vn=134,v=4,},[3]={vt=11,vn=134,v=8,},material="Black",},[246]={[1]={vt=27,vn=135,v=20,},[2]={vt=3,vn=135,v=3,},[3]={vt=1,vn=135,v=1,},material="Black",},[247]={[1]={vt=1,vn=136,v=1,},[2]={vt=6,vn=136,v=5,},[3]={vt=16,vn=136,v=13,},material="Black",},[248]={[1]={vt=2,vn=137,v=2,},[2]={vt=15,vn=137,v=12,},[3]={vt=39,vn=137,v=31,},material="Black",},[249]={[1]={vt=4,vn=138,v=3,},[2]={vt=7,vn=138,v=6,},[3]={vt=6,vn=138,v=5,},material="Black",},[250]={[1]={vt=13,vn=139,v=10,},[2]={vt=8,vn=139,v=7,},[3]={vt=17,vn=139,v=14,},material="Black",},[251]={[1]={vt=4,vn=140,v=3,},[2]={vt=8,vn=140,v=7,},[3]={vt=13,vn=140,v=10,},material="Black",},[252]={[1]={vt=5,vn=141,v=4,},[2]={vt=2,vn=141,v=2,},[3]={vt=32,vn=141,v=25,},material="Black",},[253]={[1]={vt=14,vn=142,v=11,},[2]={vt=16,vn=142,v=13,},[3]={vt=30,vn=142,v=23,},material="Black",},[254]={[1]={vt=29,vn=143,v=22,},[2]={vt=30,vn=143,v=23,},[3]={vt=41,vn=143,v=33,},material="Black",},[255]={[1]={vt=26,vn=144,v=19,},[2]={vt=1,vn=144,v=1,},[3]={vt=14,vn=144,v=11,},material="Black",},[256]={[1]={vt=11,vn=145,v=8,},[2]={vt=19,vn=145,v=15,},[3]={vt=31,vn=145,v=24,},material="Black",},[257]={[1]={vt=18,vn=146,v=14,},[2]={vt=9,vn=146,v=7,},[3]={vt=202,vn=146,v=153,},material="Black",},[258]={[1]={vt=9,vn=147,v=7,},[2]={vt=28,vn=147,v=21,},[3]={vt=202,vn=147,v=153,},material="Black",},[259]={[1]={vt=26,vn=148,v=19,},[2]={vt=29,vn=148,v=22,},[3]={vt=15,vn=148,v=12,},material="Black",},[260]={[1]={vt=5,vn=150,v=4,},[2]={vt=27,vn=150,v=20,},[3]={vt=26,vn=150,v=19,},material="Black",},[261]={[1]={vt=27,vn=151,v=20,},[2]={vt=28,vn=151,v=21,},[3]={vt=9,vn=151,v=7,},material="Black",},[262]={[1]={vt=43,vn=152,v=35,},[2]={vt=33,vn=152,v=26,},[3]={vt=156,vn=152,v=107,},material="Black",},[263]={[1]={vt=38,vn=154,v=30,},[2]={vt=41,vn=154,v=33,},[3]={vt=49,vn=154,v=40,},material="Black",},[264]={[1]={vt=15,vn=156,v=12,},[2]={vt=29,vn=156,v=22,},[3]={vt=38,vn=156,v=30,},material="Black",},[265]={[1]={vt=59,vn=158,v=48,},[2]={vt=63,vn=158,v=52,},[3]={vt=53,vn=158,v=43,},material="Black",},[266]={[1]={vt=56,vn=159,v=46,},[2]={vt=34,vn=159,v=27,},[3]={vt=40,vn=159,v=32,},material="Black",},[267]={[1]={vt=56,vn=160,v=46,},[2]={vt=59,vn=160,v=48,},[3]={vt=54,vn=160,v=44,},material="Black",},[268]={[1]={vt=32,vn=162,v=25,},[2]={vt=155,vn=162,v=106,},[3]={vt=156,vn=162,v=107,},material="Black",},[269]={[1]={vt=39,vn=163,v=31,},[2]={vt=38,vn=163,v=30,},[3]={vt=47,vn=163,v=38,},material="Black",},[270]={[1]={vt=54,vn=165,v=44,},[2]={vt=53,vn=165,v=43,},[3]={vt=69,vn=165,v=57,},material="Black",},[271]={[1]={vt=34,vn=166,v=27,},[2]={vt=64,vn=166,v=53,},[3]={vt=65,vn=166,v=54,},material="Black",},[272]={[1]={vt=34,vn=167,v=27,},[2]={vt=54,vn=167,v=44,},[3]={vt=70,vn=167,v=58,},material="Black",},[273]={[1]={vt=63,vn=169,v=52,},[2]={vt=60,vn=169,v=49,},[3]={vt=55,vn=169,v=45,},material="Black",},[274]={[1]={vt=49,vn=170,v=40,},[2]={vt=60,vn=170,v=49,},[3]={vt=63,vn=170,v=52,},material="Black",},[275]={[1]={vt=48,vn=173,v=39,},[2]={vt=59,vn=173,v=48,},[3]={vt=56,vn=173,v=46,},material="Black",},[276]={[1]={vt=42,vn=174,v=34,},[2]={vt=56,vn=174,v=46,},[3]={vt=61,vn=174,v=50,},material="Black",},[277]={[1]={vt=47,vn=175,v=38,},[2]={vt=63,vn=175,v=52,},[3]={vt=59,vn=175,v=48,},material="Black",},[278]={[1]={vt=64,vn=176,v=53,},[2]={vt=70,vn=176,v=58,},[3]={vt=83,vn=176,v=67,},material="Black",},[279]={[1]={vt=71,vn=178,v=59,},[2]={vt=85,vn=178,v=69,},[3]={vt=82,vn=178,v=66,},material="Black",},[280]={[1]={vt=53,vn=180,v=43,},[2]={vt=55,vn=180,v=45,},[3]={vt=71,vn=180,v=59,},material="Black",},[281]={[1]={vt=144,vn=182,v=101,},[2]={vt=74,vn=182,v=62,},[3]={vt=72,vn=182,v=60,},material="Black",},[282]={[1]={vt=73,vn=183,v=61,},[2]={vt=76,vn=183,v=63,},[3]={vt=144,vn=183,v=101,},material="Black",},[283]={[1]={vt=73,vn=185,v=61,},[2]={vt=72,vn=185,v=60,},[3]={vt=83,vn=185,v=67,},material="Black",},[284]={[1]={vt=84,vn=186,v=68,},[2]={vt=83,vn=186,v=67,},[3]={vt=87,vn=186,v=71,},material="Black",},[285]={[1]={vt=70,vn=187,v=58,},[2]={vt=69,vn=187,v=57,},[3]={vt=82,vn=187,v=66,},material="Black",},[286]={[1]={vt=64,vn=188,v=53,},[2]={vt=72,vn=188,v=60,},[3]={vt=75,vn=188,v=62,},material="Black",},[287]={[1]={vt=87,vn=189,v=71,},[2]={vt=86,vn=189,v=70,},[3]={vt=89,vn=189,v=73,},material="Black",},[288]={[1]={vt=82,vn=190,v=66,},[2]={vt=86,vn=190,v=70,},[3]={vt=87,vn=190,v=71,},material="Black",},[289]={[1]={vt=85,vn=191,v=69,},[2]={vt=89,vn=191,v=73,},[3]={vt=86,vn=191,v=70,},material="Black",},[290]={[1]={vt=122,vn=196,v=90,},[2]={vt=106,vn=196,v=82,},[3]={vt=113,vn=196,v=85,},material="Black",},[291]={[1]={vt=112,vn=200,v=85,},[2]={vt=121,vn=200,v=89,},[3]={vt=193,vn=200,v=144,},material="Black",},[292]={[1]={vt=129,vn=201,v=93,},[2]={vt=126,vn=201,v=92,},[3]={vt=110,vn=201,v=84,},material="Black",},[293]={[1]={vt=125,vn=202,v=91,},[2]={vt=112,vn=202,v=85,},[3]={vt=191,vn=202,v=142,},material="Black",},[294]={[1]={vt=194,vn=203,v=145,},[2]={vt=128,vn=203,v=93,},[3]={vt=109,vn=203,v=83,},material="Black",},[295]={[1]={vt=120,vn=204,v=89,},[2]={vt=115,vn=204,v=86,},[3]={vt=130,vn=204,v=94,},material="Black",},[296]={[1]={vt=109,vn=74,v=83,},[2]={vt=117,vn=74,v=87,},[3]={vt=192,vn=74,v=143,},material="Black",},[297]={[1]={vt=113,vn=205,v=85,},[2]={vt=106,vn=205,v=82,},[3]={vt=115,vn=205,v=86,},material="Black",},[298]={[1]={vt=110,vn=206,v=84,},[2]={vt=119,vn=206,v=88,},[3]={vt=116,vn=206,v=87,},material="Black",},[299]={[1]={vt=188,vn=207,v=139,},[2]={vt=101,vn=207,v=79,},[3]={vt=128,vn=207,v=93,},material="Black",},[300]={[1]={vt=189,vn=208,v=140,},[2]={vt=104,vn=208,v=81,},[3]={vt=125,vn=208,v=91,},material="Black",},[301]={[1]={vt=102,vn=209,v=80,},[2]={vt=126,vn=209,v=92,},[3]={vt=129,vn=209,v=93,},material="Black",},[302]={[1]={vt=105,vn=210,v=81,},[2]={vt=98,vn=210,v=78,},[3]={vt=122,vn=210,v=90,},material="Black",},[303]={[1]={vt=197,vn=211,v=148,},[2]={vt=136,vn=211,v=97,},[3]={vt=154,vn=211,v=105,},material="Black",},[304]={[1]={vt=119,vn=212,v=88,},[2]={vt=134,vn=212,v=96,},[3]={vt=132,vn=212,v=95,},material="Black",},[305]={[1]={vt=193,vn=213,v=144,},[2]={vt=121,vn=213,v=89,},[3]={vt=136,vn=213,v=97,},material="Black",},[306]={[1]={vt=192,vn=74,v=143,},[2]={vt=117,vn=74,v=87,},[3]={vt=133,vn=74,v=95,},material="Black",},[307]={[1]={vt=200,vn=74,v=151,},[2]={vt=149,vn=74,v=103,},[3]={vt=152,vn=74,v=104,},material="Black",},[308]={[1]={vt=196,vn=74,v=147,},[2]={vt=133,vn=74,v=95,},[3]={vt=149,vn=74,v=103,},material="Black",},[309]={[1]={vt=137,vn=217,v=97,},[2]={vt=130,vn=217,v=94,},[3]={vt=147,vn=217,v=102,},material="Black",},[310]={[1]={vt=134,vn=218,v=96,},[2]={vt=151,vn=218,v=104,},[3]={vt=150,vn=218,v=103,},material="Black",},[311]={[1]={vt=155,vn=219,v=106,},[2]={vt=157,vn=219,v=108,},[3]={vt=160,vn=219,v=111,},material="Black",},[312]={[1]={vt=155,vn=220,v=106,},[2]={vt=158,vn=220,v=109,},[3]={vt=159,vn=220,v=110,},material="Black",},[313]={[1]={vt=158,vn=221,v=109,},[2]={vt=164,vn=221,v=115,},[3]={vt=165,vn=221,v=116,},material="Black",},[314]={[1]={vt=159,vn=222,v=110,},[2]={vt=165,vn=222,v=116,},[3]={vt=162,vn=222,v=113,},material="Black",},[315]={[1]={vt=48,vn=223,v=39,},[2]={vt=160,vn=223,v=111,},[3]={vt=157,vn=223,v=108,},material="Black",},[316]={[1]={vt=32,vn=224,v=25,},[2]={vt=39,vn=224,v=31,},[3]={vt=157,vn=224,v=108,},material="Black",},[317]={[1]={vt=164,vn=225,v=115,},[2]={vt=170,vn=225,v=121,},[3]={vt=171,vn=225,v=122,},material="Black",},[318]={[1]={vt=165,vn=226,v=116,},[2]={vt=171,vn=226,v=122,},[3]={vt=168,vn=226,v=119,},material="Black",},[319]={[1]={vt=42,vn=227,v=34,},[2]={vt=43,vn=227,v=35,},[3]={vt=162,vn=227,v=113,},material="Black",},[320]={[1]={vt=48,vn=228,v=39,},[2]={vt=42,vn=228,v=34,},[3]={vt=161,vn=228,v=112,},material="Black",},[321]={[1]={vt=160,vn=229,v=111,},[2]={vt=166,vn=229,v=117,},[3]={vt=164,vn=229,v=115,},material="Black",},[322]={[1]={vt=160,vn=230,v=111,},[2]={vt=48,vn=230,v=39,},[3]={vt=163,vn=230,v=114,},material="Black",},[323]={[1]={vt=167,vn=231,v=118,},[2]={vt=173,vn=231,v=124,},[3]={vt=175,vn=231,v=126,},material="Black",},[324]={[1]={vt=170,vn=232,v=121,},[2]={vt=172,vn=232,v=123,},[3]={vt=178,vn=232,v=129,},material="Black",},[325]={[1]={vt=161,vn=233,v=112,},[2]={vt=162,vn=233,v=113,},[3]={vt=168,vn=233,v=119,},material="Black",},[326]={[1]={vt=164,vn=234,v=115,},[2]={vt=166,vn=234,v=117,},[3]={vt=172,vn=234,v=123,},material="Black",},[327]={[1]={vt=161,vn=235,v=112,},[2]={vt=167,vn=235,v=118,},[3]={vt=169,vn=235,v=120,},material="Black",},[328]={[1]={vt=166,vn=236,v=117,},[2]={vt=163,vn=236,v=114,},[3]={vt=169,vn=236,v=120,},material="Black",},[329]={[1]={vt=173,vn=237,v=124,},[2]={vt=174,vn=237,v=125,},[3]={vt=177,vn=237,v=128,},material="Black",},[330]={[1]={vt=175,vn=238,v=126,},[2]={vt=173,vn=238,v=124,},[3]={vt=176,vn=238,v=127,},material="Black",},[331]={[1]={vt=172,vn=239,v=123,},[2]={vt=169,vn=239,v=120,},[3]={vt=175,vn=239,v=126,},material="Black",},[332]={[1]={vt=171,vn=111,v=122,},[2]={vt=177,vn=111,v=128,},[3]={vt=174,vn=111,v=125,},material="Black",},[333]={[1]={vt=171,vn=240,v=122,},[2]={vt=170,vn=240,v=121,},[3]={vt=176,vn=240,v=127,},material="Black",},[334]={[1]={vt=167,vn=241,v=118,},[2]={vt=168,vn=241,v=119,},[3]={vt=174,vn=241,v=125,},material="Black",},[335]={[1]={vt=196,vn=74,v=147,},[2]={vt=200,vn=74,v=151,},[3]={vt=148,vn=74,v=102,},material="Black",},[336]={[1]={vt=200,vn=74,v=151,},[2]={vt=201,vn=74,v=152,},[3]={vt=154,vn=74,v=105,},material="Black",},[337]={[1]={vt=192,vn=74,v=143,},[2]={vt=196,vn=74,v=147,},[3]={vt=131,vn=74,v=94,},material="Black",},[338]={[1]={vt=193,vn=83,v=144,},[2]={vt=197,vn=83,v=148,},[3]={vt=135,vn=83,v=96,},material="Black",},[339]={[1]={vt=197,vn=81,v=148,},[2]={vt=201,vn=81,v=152,},[3]={vt=152,vn=81,v=104,},material="Black",},[340]={[1]={vt=103,vn=243,v=80,},[2]={vt=189,vn=243,v=140,},[3]={vt=195,vn=243,v=146,},material="Black",},[341]={[1]={vt=188,vn=77,v=139,},[2]={vt=194,vn=77,v=145,},[3]={vt=123,vn=77,v=90,},material="Black",},[342]={[1]={vt=107,vn=74,v=82,},[2]={vt=190,vn=74,v=141,},[3]={vt=192,vn=74,v=143,},material="Black",},[343]={[1]={vt=123,vn=244,v=90,},[2]={vt=194,vn=244,v=145,},[3]={vt=190,vn=244,v=141,},material="Black",},[344]={[1]={vt=127,vn=71,v=92,},[2]={vt=195,vn=71,v=146,},[3]={vt=191,vn=71,v=142,},material="Black",},[345]={[1]={vt=111,vn=69,v=84,},[2]={vt=191,vn=69,v=142,},[3]={vt=193,vn=69,v=144,},material="Black",},[346]={[1]={vt=25,vn=252,v=18,},[2]={vt=20,vn=252,v=15,},[3]={vt=21,vn=252,v=16,},material="Black",},[347]={[1]={vt=20,vn=253,v=15,},[2]={vt=179,vn=253,v=130,},[3]={vt=21,vn=253,v=16,},material="Black",},[348]={[1]={vt=219,vn=254,v=165,},[2]={vt=220,vn=254,v=166,},[3]={vt=211,vn=254,v=159,},material="Black",},[349]={[1]={vt=219,vn=255,v=165,},[2]={vt=218,vn=255,v=164,},[3]={vt=203,vn=255,v=154,},material="Black",},[350]={[1]={vt=203,vn=256,v=154,},[2]={vt=212,vn=256,v=160,},[3]={vt=16,vn=256,v=13,},material="Black",},[351]={[1]={vt=204,vn=257,v=155,},[2]={vt=223,vn=257,v=169,},[3]={vt=229,vn=257,v=174,},material="Black",},[352]={[1]={vt=206,vn=258,v=156,},[2]={vt=203,vn=258,v=154,},[3]={vt=6,vn=258,v=5,},material="Black",},[353]={[1]={vt=13,vn=259,v=10,},[2]={vt=22,vn=259,v=17,},[3]={vt=214,vn=259,v=162,},material="Black",},[354]={[1]={vt=206,vn=260,v=156,},[2]={vt=7,vn=260,v=6,},[3]={vt=13,vn=260,v=10,},material="Black",},[355]={[1]={vt=207,vn=261,v=157,},[2]={vt=224,vn=261,v=170,},[3]={vt=223,vn=261,v=169,},material="Black",},[356]={[1]={vt=212,vn=262,v=160,},[2]={vt=221,vn=262,v=167,},[3]={vt=30,vn=262,v=23,},material="Black",},[357]={[1]={vt=221,vn=263,v=167,},[2]={vt=228,vn=263,v=173,},[3]={vt=41,vn=263,v=33,},material="Black",},[358]={[1]={vt=218,vn=264,v=164,},[2]={vt=221,vn=264,v=167,},[3]={vt=212,vn=264,v=160,},material="Black",},[359]={[1]={vt=351,vn=265,v=257,},[2]={vt=210,vn=265,v=159,},[3]={vt=217,vn=265,v=163,},material="Black",},[360]={[1]={vt=211,vn=266,v=159,},[2]={vt=220,vn=266,v=166,},[3]={vt=222,vn=266,v=168,},material="Black",},[361]={[1]={vt=215,vn=267,v=162,},[2]={vt=24,vn=267,v=18,},[3]={vt=374,vn=267,v=280,},material="Black",},[362]={[1]={vt=22,vn=268,v=17,},[2]={vt=23,vn=268,v=18,},[3]={vt=214,vn=268,v=162,},material="Black",},[363]={[1]={vt=220,vn=269,v=166,},[2]={vt=374,vn=269,v=280,},[3]={vt=222,vn=269,v=168,},material="Black",},[364]={[1]={vt=218,vn=270,v=164,},[2]={vt=204,vn=270,v=155,},[3]={vt=213,vn=270,v=161,},material="Black",},[365]={[1]={vt=207,vn=272,v=157,},[2]={vt=204,vn=272,v=155,},[3]={vt=218,vn=272,v=164,},material="Black",},[366]={[1]={vt=219,vn=273,v=165,},[2]={vt=205,vn=273,v=156,},[3]={vt=209,vn=273,v=158,},material="Black",},[367]={[1]={vt=24,vn=274,v=18,},[2]={vt=216,vn=274,v=163,},[3]={vt=222,vn=274,v=168,},material="Black",},[368]={[1]={vt=232,vn=275,v=177,},[2]={vt=331,vn=275,v=237,},[3]={vt=328,vn=275,v=234,},material="Black",},[369]={[1]={vt=228,vn=277,v=173,},[2]={vt=235,vn=277,v=179,},[3]={vt=49,vn=277,v=40,},material="Black",},[370]={[1]={vt=213,vn=279,v=161,},[2]={vt=229,vn=279,v=174,},[3]={vt=228,vn=279,v=173,},material="Black",},[371]={[1]={vt=244,vn=281,v=186,},[2]={vt=240,vn=281,v=183,},[3]={vt=239,vn=281,v=182,},material="Black",},[372]={[1]={vt=241,vn=282,v=184,},[2]={vt=245,vn=282,v=187,},[3]={vt=230,vn=282,v=175,},material="Black",},[373]={[1]={vt=241,vn=283,v=184,},[2]={vt=225,vn=283,v=171,},[3]={vt=240,vn=283,v=183,},material="Black",},[374]={[1]={vt=223,vn=285,v=169,},[2]={vt=224,vn=285,v=170,},[3]={vt=328,vn=285,v=234,},material="Black",},[375]={[1]={vt=229,vn=286,v=174,},[2]={vt=236,vn=286,v=180,},[3]={vt=235,vn=286,v=179,},material="Black",},[376]={[1]={vt=240,vn=288,v=183,},[2]={vt=252,vn=288,v=193,},[3]={vt=251,vn=288,v=192,},material="Black",},[377]={[1]={vt=225,vn=289,v=171,},[2]={vt=230,vn=289,v=175,},[3]={vt=248,vn=289,v=190,},material="Black",},[378]={[1]={vt=225,vn=290,v=171,},[2]={vt=247,vn=290,v=189,},[3]={vt=252,vn=290,v=193,},material="Black",},[379]={[1]={vt=246,vn=292,v=188,},[2]={vt=239,vn=292,v=182,},[3]={vt=55,vn=292,v=45,},material="Black",},[380]={[1]={vt=49,vn=293,v=40,},[2]={vt=235,vn=293,v=179,},[3]={vt=246,vn=293,v=188,},material="Black",},[381]={[1]={vt=236,vn=296,v=180,},[2]={vt=231,vn=296,v=176,},[3]={vt=241,vn=296,v=184,},material="Black",},[382]={[1]={vt=231,vn=297,v=176,},[2]={vt=232,vn=297,v=177,},[3]={vt=245,vn=297,v=187,},material="Black",},[383]={[1]={vt=235,vn=298,v=179,},[2]={vt=236,vn=298,v=180,},[3]={vt=244,vn=298,v=186,},material="Black",},[384]={[1]={vt=247,vn=299,v=189,},[2]={vt=253,vn=299,v=194,},[3]={vt=259,vn=299,v=198,},material="Black",},[385]={[1]={vt=71,vn=301,v=59,},[2]={vt=251,vn=301,v=192,},[3]={vt=258,vn=301,v=197,},material="Black",},[386]={[1]={vt=239,vn=303,v=182,},[2]={vt=251,vn=303,v=192,},[3]={vt=71,vn=303,v=59,},material="Black",},[387]={[1]={vt=253,vn=305,v=194,},[2]={vt=316,vn=305,v=228,},[3]={vt=73,vn=305,v=61,},material="Black",},[388]={[1]={vt=73,vn=307,v=61,},[2]={vt=84,vn=307,v=68,},[3]={vt=259,vn=307,v=198,},material="Black",},[389]={[1]={vt=84,vn=308,v=68,},[2]={vt=88,vn=308,v=72,},[3]={vt=261,vn=308,v=200,},material="Black",},[390]={[1]={vt=252,vn=309,v=193,},[2]={vt=259,vn=309,v=198,},[3]={vt=258,vn=309,v=197,},material="Black",},[391]={[1]={vt=247,vn=310,v=189,},[2]={vt=248,vn=310,v=190,},[3]={vt=255,vn=310,v=195,},material="Black",},[392]={[1]={vt=261,vn=311,v=200,},[2]={vt=88,vn=311,v=72,},[3]={vt=89,vn=311,v=73,},material="Black",},[393]={[1]={vt=258,vn=312,v=197,},[2]={vt=259,vn=312,v=198,},[3]={vt=261,vn=312,v=200,},material="Black",},[394]={[1]={vt=85,vn=313,v=69,},[2]={vt=258,vn=313,v=197,},[3]={vt=260,vn=313,v=199,},material="Black",},[395]={[1]={vt=294,vn=318,v=217,},[2]={vt=296,vn=318,v=218,},[3]={vt=285,vn=318,v=212,},material="Black",},[396]={[1]={vt=284,vn=322,v=212,},[2]={vt=363,vn=322,v=269,},[3]={vt=365,vn=322,v=271,},material="Black",},[397]={[1]={vt=301,vn=323,v=220,},[2]={vt=280,vn=323,v=210,},[3]={vt=282,vn=323,v=211,},material="Black",},[398]={[1]={vt=297,vn=324,v=218,},[2]={vt=367,vn=324,v=273,},[3]={vt=363,vn=324,v=269,},material="Black",},[399]={[1]={vt=366,vn=325,v=272,},[2]={vt=362,vn=325,v=268,},[3]={vt=281,vn=325,v=210,},material="Black",},[400]={[1]={vt=292,vn=326,v=216,},[2]={vt=309,vn=326,v=224,},[3]={vt=302,vn=326,v=221,},material="Black",},[401]={[1]={vt=281,vn=74,v=210,},[2]={vt=362,vn=74,v=268,},[3]={vt=364,vn=74,v=270,},material="Black",},[402]={[1]={vt=285,vn=327,v=212,},[2]={vt=292,vn=327,v=216,},[3]={vt=287,vn=327,v=213,},material="Black",},[403]={[1]={vt=282,vn=328,v=211,},[2]={vt=280,vn=328,v=210,},[3]={vt=288,vn=328,v=214,},material="Black",},[404]={[1]={vt=360,vn=329,v=266,},[2]={vt=366,vn=329,v=272,},[3]={vt=300,vn=329,v=220,},material="Black",},[405]={[1]={vt=361,vn=330,v=267,},[2]={vt=367,vn=330,v=273,},[3]={vt=297,vn=330,v=218,},material="Black",},[406]={[1]={vt=274,vn=331,v=207,},[2]={vt=272,vn=331,v=206,},[3]={vt=301,vn=331,v=220,},material="Black",},[407]={[1]={vt=277,vn=332,v=208,},[2]={vt=296,vn=332,v=218,},[3]={vt=294,vn=332,v=217,},material="Black",},[408]={[1]={vt=369,vn=333,v=275,},[2]={vt=373,vn=333,v=279,},[3]={vt=326,vn=333,v=232,},material="Black",},[409]={[1]={vt=291,vn=334,v=215,},[2]={vt=288,vn=334,v=214,},[3]={vt=304,vn=334,v=222,},material="Black",},[410]={[1]={vt=365,vn=335,v=271,},[2]={vt=369,vn=335,v=275,},[3]={vt=308,vn=335,v=224,},material="Black",},[411]={[1]={vt=364,vn=74,v=270,},[2]={vt=368,vn=74,v=274,},[3]={vt=305,vn=74,v=222,},material="Black",},[412]={[1]={vt=372,vn=74,v=278,},[2]={vt=373,vn=74,v=279,},[3]={vt=324,vn=74,v=231,},material="Black",},[413]={[1]={vt=368,vn=74,v=274,},[2]={vt=372,vn=74,v=278,},[3]={vt=321,vn=74,v=230,},material="Black",},[414]={[1]={vt=309,vn=340,v=224,},[2]={vt=325,vn=340,v=232,},[3]={vt=319,vn=340,v=229,},material="Black",},[415]={[1]={vt=306,vn=341,v=223,},[2]={vt=304,vn=341,v=222,},[3]={vt=322,vn=341,v=230,},material="Black",},[416]={[1]={vt=327,vn=342,v=233,},[2]={vt=330,vn=342,v=236,},[3]={vt=332,vn=342,v=238,},material="Black",},[417]={[1]={vt=327,vn=343,v=233,},[2]={vt=328,vn=343,v=234,},[3]={vt=331,vn=343,v=237,},material="Black",},[418]={[1]={vt=330,vn=344,v=236,},[2]={vt=331,vn=344,v=237,},[3]={vt=337,vn=344,v=243,},material="Black",},[419]={[1]={vt=331,vn=345,v=237,},[2]={vt=232,vn=345,v=177,},[3]={vt=334,vn=345,v=240,},material="Black",},[420]={[1]={vt=236,vn=346,v=180,},[2]={vt=229,vn=346,v=174,},[3]={vt=329,vn=346,v=235,},material="Black",},[421]={[1]={vt=223,vn=347,v=169,},[2]={vt=327,vn=347,v=233,},[3]={vt=329,vn=347,v=235,},material="Black",},[422]={[1]={vt=336,vn=348,v=242,},[2]={vt=337,vn=348,v=243,},[3]={vt=343,vn=348,v=249,},material="Black",},[423]={[1]={vt=337,vn=349,v=243,},[2]={vt=334,vn=349,v=240,},[3]={vt=340,vn=349,v=246,},material="Black",},[424]={[1]={vt=231,vn=350,v=176,},[2]={vt=333,vn=350,v=239,},[3]={vt=334,vn=350,v=240,},material="Black",},[425]={[1]={vt=236,vn=351,v=180,},[2]={vt=335,vn=351,v=241,},[3]={vt=333,vn=351,v=239,},material="Black",},[426]={[1]={vt=332,vn=352,v=238,},[2]={vt=330,vn=352,v=236,},[3]={vt=336,vn=352,v=242,},material="Black",},[427]={[1]={vt=332,vn=353,v=238,},[2]={vt=338,vn=353,v=244,},[3]={vt=335,vn=353,v=241,},material="Black",},[428]={[1]={vt=339,vn=354,v=245,},[2]={vt=341,vn=354,v=247,},[3]={vt=347,vn=354,v=253,},material="Black",},[429]={[1]={vt=342,vn=355,v=248,},[2]={vt=348,vn=355,v=254,},[3]={vt=350,vn=355,v=256,},material="Black",},[430]={[1]={vt=333,vn=356,v=239,},[2]={vt=339,vn=356,v=245,},[3]={vt=340,vn=356,v=246,},material="Black",},[431]={[1]={vt=336,vn=357,v=242,},[2]={vt=342,vn=357,v=248,},[3]={vt=344,vn=357,v=250,},material="Black",},[432]={[1]={vt=333,vn=358,v=239,},[2]={vt=335,vn=358,v=241,},[3]={vt=341,vn=358,v=247,},material="Black",},[433]={[1]={vt=338,vn=359,v=244,},[2]={vt=344,vn=359,v=250,},[3]={vt=341,vn=359,v=247,},material="Black",},[434]={[1]={vt=345,vn=360,v=251,},[2]={vt=348,vn=360,v=254,},[3]={vt=349,vn=360,v=255,},material="Black",},[435]={[1]={vt=347,vn=361,v=253,},[2]={vt=350,vn=361,v=256,},[3]={vt=348,vn=361,v=254,},material="Black",},[436]={[1]={vt=344,vn=362,v=250,},[2]={vt=350,vn=362,v=256,},[3]={vt=347,vn=362,v=253,},material="Black",},[437]={[1]={vt=343,vn=363,v=249,},[2]={vt=340,vn=363,v=246,},[3]={vt=346,vn=363,v=252,},material="Black",},[438]={[1]={vt=343,vn=364,v=249,},[2]={vt=349,vn=364,v=255,},[3]={vt=348,vn=364,v=254,},material="Black",},[439]={[1]={vt=339,vn=365,v=245,},[2]={vt=345,vn=365,v=251,},[3]={vt=346,vn=365,v=252,},material="Black",},[440]={[1]={vt=368,vn=74,v=274,},[2]={vt=303,vn=74,v=221,},[3]={vt=320,vn=74,v=229,},material="Black",},[441]={[1]={vt=372,vn=74,v=278,},[2]={vt=320,vn=74,v=229,},[3]={vt=326,vn=74,v=232,},material="Black",},[442]={[1]={vt=364,vn=74,v=270,},[2]={vt=286,vn=74,v=213,},[3]={vt=303,vn=74,v=221,},material="Black",},[443]={[1]={vt=365,vn=367,v=271,},[2]={vt=290,vn=367,v=215,},[3]={vt=307,vn=367,v=223,},material="Black",},[444]={[1]={vt=369,vn=368,v=275,},[2]={vt=307,vn=368,v=223,},[3]={vt=324,vn=368,v=231,},material="Black",},[445]={[1]={vt=275,vn=369,v=207,},[2]={vt=299,vn=369,v=219,},[3]={vt=367,vn=369,v=273,},material="Black",},[446]={[1]={vt=360,vn=370,v=266,},[2]={vt=271,vn=370,v=205,},[3]={vt=295,vn=370,v=217,},material="Black",},[447]={[1]={vt=279,vn=74,v=209,},[2]={vt=286,vn=74,v=213,},[3]={vt=364,vn=74,v=270,},material="Black",},[448]={[1]={vt=295,vn=371,v=217,},[2]={vt=279,vn=371,v=209,},[3]={vt=362,vn=371,v=268,},material="Black",},[449]={[1]={vt=299,vn=372,v=219,},[2]={vt=283,vn=372,v=211,},[3]={vt=363,vn=372,v=269,},material="Black",},[450]={[1]={vt=283,vn=373,v=211,},[2]={vt=290,vn=373,v=215,},[3]={vt=365,vn=373,v=271,},material="Black",},[451]={[1]={vt=351,vn=384,v=257,},[2]={vt=21,vn=384,v=16,},[3]={vt=12,vn=384,v=9,},material="Black",},[452]={[1]={vt=219,vn=386,v=165,},[2]={vt=211,vn=386,v=159,},[3]={vt=207,vn=386,v=157,},material="Black",},[453]={[1]={vt=219,vn=387,v=165,},[2]={vt=203,vn=387,v=154,},[3]={vt=205,vn=387,v=156,},material="Black",},[454]={[1]={vt=203,vn=388,v=154,},[2]={vt=16,vn=388,v=13,},[3]={vt=6,vn=388,v=5,},material="Black",},[455]={[1]={vt=204,vn=389,v=155,},[2]={vt=229,vn=389,v=174,},[3]={vt=213,vn=389,v=161,},material="Black",},[456]={[1]={vt=206,vn=390,v=156,},[2]={vt=6,vn=390,v=5,},[3]={vt=7,vn=390,v=6,},material="Black",},[457]={[1]={vt=13,vn=391,v=10,},[2]={vt=214,vn=391,v=162,},[3]={vt=208,vn=391,v=158,},material="Black",},[458]={[1]={vt=206,vn=392,v=156,},[2]={vt=13,vn=392,v=10,},[3]={vt=208,vn=392,v=158,},material="Black",},[459]={[1]={vt=207,vn=393,v=157,},[2]={vt=223,vn=393,v=169,},[3]={vt=204,vn=393,v=155,},material="Black",},[460]={[1]={vt=212,vn=394,v=160,},[2]={vt=30,vn=394,v=23,},[3]={vt=16,vn=394,v=13,},material="Black",},[461]={[1]={vt=221,vn=395,v=167,},[2]={vt=41,vn=395,v=33,},[3]={vt=30,vn=395,v=23,},material="Black",},[462]={[1]={vt=218,vn=396,v=164,},[2]={vt=212,vn=396,v=160,},[3]={vt=203,vn=396,v=154,},material="Black",},[463]={[1]={vt=211,vn=397,v=159,},[2]={vt=222,vn=397,v=168,},[3]={vt=216,vn=397,v=163,},material="Black",},[464]={[1]={vt=215,vn=398,v=162,},[2]={vt=374,vn=398,v=280,},[3]={vt=209,vn=398,v=158,},material="Black",},[465]={[1]={vt=209,vn=399,v=158,},[2]={vt=374,vn=399,v=280,},[3]={vt=220,vn=399,v=166,},material="Black",},[466]={[1]={vt=218,vn=400,v=164,},[2]={vt=213,vn=400,v=161,},[3]={vt=221,vn=400,v=167,},material="Black",},[467]={[1]={vt=207,vn=402,v=157,},[2]={vt=218,vn=402,v=164,},[3]={vt=219,vn=402,v=165,},material="Black",},[468]={[1]={vt=219,vn=403,v=165,},[2]={vt=209,vn=403,v=158,},[3]={vt=220,vn=403,v=166,},material="Black",},[469]={[1]={vt=232,vn=404,v=177,},[2]={vt=328,vn=404,v=234,},[3]={vt=224,vn=404,v=170,},material="Black",},[470]={[1]={vt=228,vn=406,v=173,},[2]={vt=49,vn=406,v=40,},[3]={vt=41,vn=406,v=33,},material="Black",},[471]={[1]={vt=213,vn=408,v=161,},[2]={vt=228,vn=408,v=173,},[3]={vt=221,vn=408,v=167,},material="Black",},[472]={[1]={vt=244,vn=410,v=186,},[2]={vt=239,vn=410,v=182,},[3]={vt=246,vn=410,v=188,},material="Black",},[473]={[1]={vt=241,vn=411,v=184,},[2]={vt=230,vn=411,v=175,},[3]={vt=225,vn=411,v=171,},material="Black",},[474]={[1]={vt=241,vn=412,v=184,},[2]={vt=240,vn=412,v=183,},[3]={vt=244,vn=412,v=186,},material="Black",},[475]={[1]={vt=223,vn=414,v=169,},[2]={vt=328,vn=414,v=234,},[3]={vt=327,vn=414,v=233,},material="Black",},[476]={[1]={vt=229,vn=415,v=174,},[2]={vt=235,vn=415,v=179,},[3]={vt=228,vn=415,v=173,},material="Black",},[477]={[1]={vt=240,vn=417,v=183,},[2]={vt=251,vn=417,v=192,},[3]={vt=239,vn=417,v=182,},material="Black",},[478]={[1]={vt=225,vn=418,v=171,},[2]={vt=248,vn=418,v=190,},[3]={vt=247,vn=418,v=189,},material="Black",},[479]={[1]={vt=225,vn=419,v=171,},[2]={vt=252,vn=419,v=193,},[3]={vt=240,vn=419,v=183,},material="Black",},[480]={[1]={vt=246,vn=421,v=188,},[2]={vt=55,vn=421,v=45,},[3]={vt=60,vn=421,v=49,},material="Black",},[481]={[1]={vt=49,vn=422,v=40,},[2]={vt=246,vn=422,v=188,},[3]={vt=60,vn=422,v=49,},material="Black",},[482]={[1]={vt=236,vn=425,v=180,},[2]={vt=241,vn=425,v=184,},[3]={vt=244,vn=425,v=186,},material="Black",},[483]={[1]={vt=231,vn=426,v=176,},[2]={vt=245,vn=426,v=187,},[3]={vt=241,vn=426,v=184,},material="Black",},[484]={[1]={vt=235,vn=427,v=179,},[2]={vt=244,vn=427,v=186,},[3]={vt=246,vn=427,v=188,},material="Black",},[485]={[1]={vt=247,vn=428,v=189,},[2]={vt=259,vn=428,v=198,},[3]={vt=252,vn=428,v=193,},material="Black",},[486]={[1]={vt=71,vn=430,v=59,},[2]={vt=258,vn=430,v=197,},[3]={vt=85,vn=430,v=69,},material="Black",},[487]={[1]={vt=239,vn=432,v=182,},[2]={vt=71,vn=432,v=59,},[3]={vt=55,vn=432,v=45,},material="Black",},[488]={[1]={vt=316,vn=434,v=228,},[2]={vt=253,vn=434,v=194,},[3]={vt=254,vn=434,v=195,},material="Black",},[489]={[1]={vt=73,vn=435,v=61,},[2]={vt=316,vn=435,v=228,},[3]={vt=76,vn=435,v=63,},material="Black",},[490]={[1]={vt=73,vn=437,v=61,},[2]={vt=259,vn=437,v=198,},[3]={vt=253,vn=437,v=194,},material="Black",},[491]={[1]={vt=84,vn=438,v=68,},[2]={vt=261,vn=438,v=200,},[3]={vt=259,vn=438,v=198,},material="Black",},[492]={[1]={vt=252,vn=439,v=193,},[2]={vt=258,vn=439,v=197,},[3]={vt=251,vn=439,v=192,},material="Black",},[493]={[1]={vt=247,vn=440,v=189,},[2]={vt=255,vn=440,v=195,},[3]={vt=253,vn=440,v=194,},material="Black",},[494]={[1]={vt=261,vn=441,v=200,},[2]={vt=89,vn=441,v=73,},[3]={vt=260,vn=441,v=199,},material="Black",},[495]={[1]={vt=258,vn=442,v=197,},[2]={vt=261,vn=442,v=200,},[3]={vt=260,vn=442,v=199,},material="Black",},[496]={[1]={vt=85,vn=443,v=69,},[2]={vt=260,vn=443,v=199,},[3]={vt=89,vn=443,v=73,},material="Black",},[497]={[1]={vt=294,vn=448,v=217,},[2]={vt=285,vn=448,v=212,},[3]={vt=278,vn=448,v=209,},material="Black",},[498]={[1]={vt=284,vn=452,v=212,},[2]={vt=365,vn=452,v=271,},[3]={vt=293,vn=452,v=216,},material="Black",},[499]={[1]={vt=301,vn=453,v=220,},[2]={vt=282,vn=453,v=211,},[3]={vt=298,vn=453,v=219,},material="Black",},[500]={[1]={vt=297,vn=454,v=218,},[2]={vt=363,vn=454,v=269,},[3]={vt=284,vn=454,v=212,},material="Black",},[501]={[1]={vt=366,vn=455,v=272,},[2]={vt=281,vn=455,v=210,},[3]={vt=300,vn=455,v=220,},material="Black",},[502]={[1]={vt=292,vn=456,v=216,},[2]={vt=302,vn=456,v=221,},[3]={vt=287,vn=456,v=213,},material="Black",},[503]={[1]={vt=281,vn=74,v=210,},[2]={vt=364,vn=74,v=270,},[3]={vt=289,vn=74,v=214,},material="Black",},[504]={[1]={vt=285,vn=457,v=212,},[2]={vt=287,vn=457,v=213,},[3]={vt=278,vn=457,v=209,},material="Black",},[505]={[1]={vt=282,vn=458,v=211,},[2]={vt=288,vn=458,v=214,},[3]={vt=291,vn=458,v=215,},material="Black",},[506]={[1]={vt=360,vn=459,v=266,},[2]={vt=300,vn=459,v=220,},[3]={vt=273,vn=459,v=206,},material="Black",},[507]={[1]={vt=361,vn=460,v=267,},[2]={vt=297,vn=460,v=218,},[3]={vt=276,vn=460,v=208,},material="Black",},[508]={[1]={vt=274,vn=461,v=207,},[2]={vt=301,vn=461,v=220,},[3]={vt=298,vn=461,v=219,},material="Black",},[509]={[1]={vt=277,vn=462,v=208,},[2]={vt=294,vn=462,v=217,},[3]={vt=270,vn=462,v=205,},material="Black",},[510]={[1]={vt=369,vn=463,v=275,},[2]={vt=326,vn=463,v=232,},[3]={vt=308,vn=463,v=224,},material="Black",},[511]={[1]={vt=291,vn=464,v=215,},[2]={vt=304,vn=464,v=222,},[3]={vt=306,vn=464,v=223,},material="Black",},[512]={[1]={vt=365,vn=465,v=271,},[2]={vt=308,vn=465,v=224,},[3]={vt=293,vn=465,v=216,},material="Black",},[513]={[1]={vt=364,vn=74,v=270,},[2]={vt=305,vn=74,v=222,},[3]={vt=289,vn=74,v=214,},material="Black",},[514]={[1]={vt=372,vn=74,v=278,},[2]={vt=324,vn=74,v=231,},[3]={vt=321,vn=74,v=230,},material="Black",},[515]={[1]={vt=368,vn=74,v=274,},[2]={vt=321,vn=74,v=230,},[3]={vt=305,vn=74,v=222,},material="Black",},[516]={[1]={vt=309,vn=469,v=224,},[2]={vt=319,vn=469,v=229,},[3]={vt=302,vn=469,v=221,},material="Black",},[517]={[1]={vt=306,vn=470,v=223,},[2]={vt=322,vn=470,v=230,},[3]={vt=323,vn=470,v=231,},material="Black",},[518]={[1]={vt=327,vn=471,v=233,},[2]={vt=332,vn=471,v=238,},[3]={vt=329,vn=471,v=235,},material="Black",},[519]={[1]={vt=327,vn=472,v=233,},[2]={vt=331,vn=472,v=237,},[3]={vt=330,vn=472,v=236,},material="Black",},[520]={[1]={vt=330,vn=473,v=236,},[2]={vt=337,vn=473,v=243,},[3]={vt=336,vn=473,v=242,},material="Black",},[521]={[1]={vt=331,vn=474,v=237,},[2]={vt=334,vn=474,v=240,},[3]={vt=337,vn=474,v=243,},material="Black",},[522]={[1]={vt=236,vn=475,v=180,},[2]={vt=329,vn=475,v=235,},[3]={vt=332,vn=475,v=238,},material="Black",},[523]={[1]={vt=223,vn=476,v=169,},[2]={vt=329,vn=476,v=235,},[3]={vt=229,vn=476,v=174,},material="Black",},[524]={[1]={vt=336,vn=477,v=242,},[2]={vt=343,vn=477,v=249,},[3]={vt=342,vn=477,v=248,},material="Black",},[525]={[1]={vt=337,vn=478,v=243,},[2]={vt=340,vn=478,v=246,},[3]={vt=343,vn=478,v=249,},material="Black",},[526]={[1]={vt=231,vn=479,v=176,},[2]={vt=334,vn=479,v=240,},[3]={vt=232,vn=479,v=177,},material="Black",},[527]={[1]={vt=236,vn=480,v=180,},[2]={vt=333,vn=480,v=239,},[3]={vt=231,vn=480,v=176,},material="Black",},[528]={[1]={vt=332,vn=481,v=238,},[2]={vt=336,vn=481,v=242,},[3]={vt=338,vn=481,v=244,},material="Black",},[529]={[1]={vt=332,vn=482,v=238,},[2]={vt=335,vn=482,v=241,},[3]={vt=236,vn=482,v=180,},material="Black",},[530]={[1]={vt=339,vn=483,v=245,},[2]={vt=347,vn=483,v=253,},[3]={vt=345,vn=483,v=251,},material="Black",},[531]={[1]={vt=342,vn=484,v=248,},[2]={vt=350,vn=484,v=256,},[3]={vt=344,vn=484,v=250,},material="Black",},[532]={[1]={vt=333,vn=485,v=239,},[2]={vt=340,vn=485,v=246,},[3]={vt=334,vn=485,v=240,},material="Black",},[533]={[1]={vt=336,vn=486,v=242,},[2]={vt=344,vn=486,v=250,},[3]={vt=338,vn=486,v=244,},material="Black",},[534]={[1]={vt=333,vn=487,v=239,},[2]={vt=341,vn=487,v=247,},[3]={vt=339,vn=487,v=245,},material="Black",},[535]={[1]={vt=338,vn=488,v=244,},[2]={vt=341,vn=488,v=247,},[3]={vt=335,vn=488,v=241,},material="Black",},[536]={[1]={vt=345,vn=489,v=251,},[2]={vt=349,vn=489,v=255,},[3]={vt=346,vn=489,v=252,},material="Black",},[537]={[1]={vt=347,vn=490,v=253,},[2]={vt=348,vn=490,v=254,},[3]={vt=345,vn=490,v=251,},material="Black",},[538]={[1]={vt=344,vn=491,v=250,},[2]={vt=347,vn=491,v=253,},[3]={vt=341,vn=491,v=247,},material="Black",},[539]={[1]={vt=343,vn=363,v=249,},[2]={vt=346,vn=363,v=252,},[3]={vt=349,vn=363,v=255,},material="Black",},[540]={[1]={vt=343,vn=492,v=249,},[2]={vt=348,vn=492,v=254,},[3]={vt=342,vn=492,v=248,},material="Black",},[541]={[1]={vt=339,vn=493,v=245,},[2]={vt=346,vn=493,v=252,},[3]={vt=340,vn=493,v=246,},material="Black",},[542]={[1]={vt=368,vn=74,v=274,},[2]={vt=320,vn=74,v=229,},[3]={vt=372,vn=74,v=278,},material="Black",},[543]={[1]={vt=372,vn=74,v=278,},[2]={vt=326,vn=74,v=232,},[3]={vt=373,vn=74,v=279,},material="Black",},[544]={[1]={vt=364,vn=74,v=270,},[2]={vt=303,vn=74,v=221,},[3]={vt=368,vn=74,v=274,},material="Black",},[545]={[1]={vt=365,vn=335,v=271,},[2]={vt=307,vn=335,v=223,},[3]={vt=369,vn=335,v=275,},material="Black",},[546]={[1]={vt=369,vn=333,v=275,},[2]={vt=324,vn=333,v=231,},[3]={vt=373,vn=333,v=279,},material="Black",},[547]={[1]={vt=275,vn=495,v=207,},[2]={vt=367,vn=495,v=273,},[3]={vt=361,vn=495,v=267,},material="Black",},[548]={[1]={vt=360,vn=329,v=266,},[2]={vt=295,vn=329,v=217,},[3]={vt=366,vn=329,v=272,},material="Black",},[549]={[1]={vt=279,vn=74,v=209,},[2]={vt=364,vn=74,v=270,},[3]={vt=362,vn=74,v=268,},material="Black",},[550]={[1]={vt=295,vn=496,v=217,},[2]={vt=362,vn=496,v=268,},[3]={vt=366,vn=496,v=272,},material="Black",},[551]={[1]={vt=299,vn=324,v=219,},[2]={vt=363,vn=324,v=269,},[3]={vt=367,vn=324,v=273,},material="Black",},[552]={[1]={vt=283,vn=322,v=211,},[2]={vt=365,vn=322,v=271,},[3]={vt=363,vn=322,v=269,},material="Black",},[553]={[1]={vt=25,vn=504,v=18,},[2]={vt=21,vn=504,v=16,},[3]={vt=217,vn=504,v=163,},material="Black",},[554]={[1]={vt=217,vn=505,v=163,},[2]={vt=21,vn=505,v=16,},[3]={vt=351,vn=505,v=257,},material="Black",},[555]={[1]={vt=24,vn=133,v=18,},[2]={vt=202,vn=133,v=153,},[3]={vt=31,vn=133,v=24,},material="Orange",},[556]={[1]={vt=24,vn=385,v=18,},[2]={vt=222,vn=385,v=168,},[3]={vt=374,vn=385,v=280,},material="Orange",},},vt={[1]={u=0.625,w=0,v=0.5,},[2]={u=0.375,w=0,v=0.5,},[3]={u=0.625,w=0,v=0.25,},[4]={u=0.875,w=0,v=0.5,},[5]={u=0.375,w=0,v=0.25,},[6]={u=0.625,w=0,v=0.625,},[7]={u=0.875,w=0,v=0.625,},[8]={u=0.875,w=0,v=0.5,},[9]={u=0.625,w=0,v=0.25,},[10]={u=0.125,w=0,v=0.5,},[11]={u=0.375,w=0,v=0.25,},[12]={u=0.125,w=0,v=0.625,},[13]={u=0.875,w=0,v=0.625,},[14]={u=0.625,w=0,v=0.5,},[15]={u=0.375,w=0,v=0.5,},[16]={u=0.625,w=0,v=0.625,},[17]={u=0.875,w=0,v=0.5,},[18]={u=0.625,w=0,v=0.25,},[19]={u=0.375,w=0,v=0.25,},[20]={u=0.125,w=0,v=0.5,},[21]={u=0.125,w=0,v=0.625,},[22]={u=0.875,w=0,v=0.625,},[23]={u=0.875,w=0,v=0.625,},[24]={u=0.625,w=0,v=0.25,},[25]={u=0.125,w=0,v=0.5,},[26]={u=0.5,w=0,v=0.5,},[27]={u=0.5,w=0,v=0.25,},[28]={u=0.5,w=0,v=0.25,},[29]={u=0.5,w=0,v=0.5,},[30]={u=0.5,w=0,v=0.625,},[31]={u=0.5,w=0,v=0.25,},[32]={u=0.375,w=0,v=0.5,},[33]={u=0.375,w=0,v=0.25,},[34]={u=0.375,w=0,v=0.5,},[35]={u=0.125,w=0,v=0.625,},[36]={u=0.375,w=0,v=0.25,},[37]={u=0.125,w=0,v=0.5,},[38]={u=0.5,w=0,v=0.5,},[39]={u=0.375,w=0,v=0.5,},[40]={u=0.375,w=0,v=0.25,},[41]={u=0.5,w=0,v=0.625,},[42]={u=0.375,w=0,v=0.5,},[43]={u=0.375,w=0,v=0.25,},[44]={u=0.125,w=0,v=0.625,},[45]={u=0.375,w=0,v=0.25,},[46]={u=0.125,w=0,v=0.5,},[47]={u=0.5,w=0,v=0.5,},[48]={u=0.375,w=0,v=0.5,},[49]={u=0.5,w=0,v=0.625,},[50]={u=0.125,w=0,v=0.625,},[51]={u=0.375,w=0,v=0.25,},[52]={u=0.125,w=0,v=0.5,},[53]={u=0.5,w=0,v=0.5,},[54]={u=0.375,w=0,v=0.5,},[55]={u=0.5,w=0,v=0.625,},[56]={u=0.375,w=0,v=0.5,},[57]={u=0.125,w=0,v=0.5,},[58]={u=0.375,w=0,v=0.25,},[59]={u=0.375,w=0,v=0.5,},[60]={u=0.5,w=0,v=0.625,},[61]={u=0.375,w=0,v=0.25,},[62]={u=0.125,w=0,v=0.625,},[63]={u=0.5,w=0,v=0.5,},[64]={u=0.375,w=0,v=0.5,},[65]={u=0.375,w=0,v=0.25,},[66]={u=0.125,w=0,v=0.625,},[67]={u=0.125,w=0,v=0.5,},[68]={u=0.375,w=0,v=0.25,},[69]={u=0.5,w=0,v=0.5,},[70]={u=0.375,w=0,v=0.5,},[71]={u=0.5,w=0,v=0.625,},[72]={u=0.375,w=0,v=0.5,},[73]={u=0.375,w=0,v=0.625,},[74]={u=0.125,w=0,v=0.5,},[75]={u=0.375,w=0,v=0.25,},[76]={u=0.125,w=0,v=0.625,},[77]={u=0,w=0,v=0,},[78]={u=0,w=0,v=0,},[79]={u=0.125,w=0,v=0.625,},[80]={u=0.375,w=0,v=0.25,},[81]={u=0.125,w=0,v=0.5,},[82]={u=0.5,w=0,v=0.5,},[83]={u=0.375,w=0,v=0.5,},[84]={u=0.375,w=0,v=0.625,},[85]={u=0.5,w=0,v=0.625,},[86]={u=0.5,w=0,v=0.5,},[87]={u=0.375,w=0,v=0.5,},[88]={u=0.375,w=0,v=0.625,},[89]={u=0.5,w=0,v=0.625,},[90]={u=0.375,w=0,v=0.25,},[91]={u=0.125,w=0,v=0.5,},[92]={u=0.125,w=0,v=0.625,},[93]={u=0,w=0,v=0,},[94]={u=0,w=0,v=0,},[95]={u=0.125,w=0,v=0.625,},[96]={u=0.375,w=0,v=0.25,},[97]={u=0.125,w=0,v=0.5,},[98]={u=0.375,w=0,v=0.25,},[99]={u=0.125,w=0,v=0.5,},[100]={u=0,w=0,v=0,},[101]={u=0.125,w=0,v=0.625,},[102]={u=0,w=0,v=0,},[103]={u=0.125,w=0,v=0.625,},[104]={u=0.125,w=0,v=0.5,},[105]={u=0.375,w=0,v=0.25,},[106]={u=0.375,w=0,v=0.25,},[107]={u=0.125,w=0,v=0.5,},[108]={u=0,w=0,v=0,},[109]={u=0.125,w=0,v=0.625,},[110]={u=0,w=0,v=0,},[111]={u=0.125,w=0,v=0.625,},[112]={u=0.125,w=0,v=0.5,},[113]={u=0.375,w=0,v=0.25,},[114]={u=0.125,w=0,v=0.5,},[115]={u=0.375,w=0,v=0.25,},[116]={u=0,w=0,v=0,},[117]={u=0.125,w=0,v=0.625,},[118]={u=0.125,w=0,v=0.625,},[119]={u=0,w=0,v=0,},[120]={u=0.375,w=0,v=0.25,},[121]={u=0.125,w=0,v=0.5,},[122]={u=0.375,w=0,v=0.25,},[123]={u=0.125,w=0,v=0.5,},[124]={u=0.375,w=0,v=0.25,},[125]={u=0.125,w=0,v=0.5,},[126]={u=0,w=0,v=0,},[127]={u=0.125,w=0,v=0.625,},[128]={u=0.125,w=0,v=0.625,},[129]={u=0,w=0,v=0,},[130]={u=0.375,w=0,v=0.25,},[131]={u=0.125,w=0,v=0.5,},[132]={u=0,w=0,v=0,},[133]={u=0.125,w=0,v=0.625,},[134]={u=0,w=0,v=0,},[135]={u=0.125,w=0,v=0.625,},[136]={u=0.125,w=0,v=0.5,},[137]={u=0.375,w=0,v=0.25,},[138]={u=0.375,w=0,v=0.25,},[139]={u=0.125,w=0,v=0.5,},[140]={u=0,w=0,v=0,},[141]={u=0.125,w=0,v=0.625,},[142]={u=0.125,w=0,v=0.5,},[143]={u=0.375,w=0,v=0.25,},[144]={u=0.125,w=0,v=0.597128,},[145]={u=0,w=0,v=0,},[146]={u=0.125,w=0,v=0.625,},[147]={u=0.375,w=0,v=0.25,},[148]={u=0.125,w=0,v=0.5,},[149]={u=0.125,w=0,v=0.625,},[150]={u=0,w=0,v=0,},[151]={u=0,w=0,v=0,},[152]={u=0.125,w=0,v=0.625,},[153]={u=0.375,w=0,v=0.25,},[154]={u=0.125,w=0,v=0.5,},[155]={u=0.375,w=0,v=0.5,},[156]={u=0.375,w=0,v=0.25,},[157]={u=0.375,w=0,v=0.5,},[158]={u=0.375,w=0,v=0.5,},[159]={u=0.375,w=0,v=0.25,},[160]={u=0.375,w=0,v=0.5,},[161]={u=0.375,w=0,v=0.5,},[162]={u=0.375,w=0,v=0.25,},[163]={u=0.375,w=0,v=0.5,},[164]={u=0.375,w=0,v=0.5,},[165]={u=0.375,w=0,v=0.25,},[166]={u=0.375,w=0,v=0.5,},[167]={u=0.375,w=0,v=0.5,},[168]={u=0.375,w=0,v=0.25,},[169]={u=0.375,w=0,v=0.5,},[170]={u=0.375,w=0,v=0.5,},[171]={u=0.375,w=0,v=0.25,},[172]={u=0.375,w=0,v=0.5,},[173]={u=0.375,w=0,v=0.5,},[174]={u=0.375,w=0,v=0.25,},[175]={u=0.375,w=0,v=0.5,},[176]={u=0.375,w=0,v=0.5,},[177]={u=0.375,w=0,v=0.25,},[178]={u=0.375,w=0,v=0.5,},[179]={u=0.125,w=0,v=0.5625,},[180]={u=0.125,w=0,v=0.5625,},[181]={u=0.125,w=0,v=0.5625,},[182]={u=0.125,w=0,v=0.5625,},[183]={u=0.125,w=0,v=0.5625,},[184]={u=0.125,w=0,v=0.5625,},[185]={u=0.125,w=0,v=0.5625,},[186]={u=0.125,w=0,v=0.5625,},[187]={u=0.125,w=0,v=0.5625,},[188]={u=0.125,w=0,v=0.5625,},[189]={u=0.125,w=0,v=0.5625,},[190]={u=0.125,w=0,v=0.5625,},[191]={u=0.125,w=0,v=0.5625,},[192]={u=0.125,w=0,v=0.5625,},[193]={u=0.125,w=0,v=0.5625,},[194]={u=0.125,w=0,v=0.5625,},[195]={u=0.125,w=0,v=0.5625,},[196]={u=0.125,w=0,v=0.5625,},[197]={u=0.125,w=0,v=0.5625,},[198]={u=0.125,w=0,v=0.5625,},[199]={u=0.125,w=0,v=0.5625,},[200]={u=0.125,w=0,v=0.5625,},[201]={u=0.125,w=0,v=0.5625,},[202]={u=0.556045,w=0,v=0.25,},[203]={u=0.625,w=0,v=0.5,},[204]={u=0.375,w=0,v=0.5,},[205]={u=0.625,w=0,v=0.25,},[206]={u=0.875,w=0,v=0.5,},[207]={u=0.375,w=0,v=0.25,},[208]={u=0.875,w=0,v=0.5,},[209]={u=0.625,w=0,v=0.25,},[210]={u=0.125,w=0,v=0.5,},[211]={u=0.375,w=0,v=0.25,},[212]={u=0.625,w=0,v=0.5,},[213]={u=0.375,w=0,v=0.5,},[214]={u=0.875,w=0,v=0.5,},[215]={u=0.625,w=0,v=0.25,},[216]={u=0.375,w=0,v=0.25,},[217]={u=0.125,w=0,v=0.5,},[218]={u=0.5,w=0,v=0.5,},[219]={u=0.5,w=0,v=0.25,},[220]={u=0.5,w=0,v=0.25,},[221]={u=0.5,w=0,v=0.5,},[222]={u=0.5,w=0,v=0.25,},[223]={u=0.375,w=0,v=0.5,},[224]={u=0.375,w=0,v=0.25,},[225]={u=0.375,w=0,v=0.5,},[226]={u=0.375,w=0,v=0.25,},[227]={u=0.125,w=0,v=0.5,},[228]={u=0.5,w=0,v=0.5,},[229]={u=0.375,w=0,v=0.5,},[230]={u=0.375,w=0,v=0.25,},[231]={u=0.375,w=0,v=0.5,},[232]={u=0.375,w=0,v=0.25,},[233]={u=0.375,w=0,v=0.25,},[234]={u=0.125,w=0,v=0.5,},[235]={u=0.5,w=0,v=0.5,},[236]={u=0.375,w=0,v=0.5,},[237]={u=0.375,w=0,v=0.25,},[238]={u=0.125,w=0,v=0.5,},[239]={u=0.5,w=0,v=0.5,},[240]={u=0.375,w=0,v=0.5,},[241]={u=0.375,w=0,v=0.5,},[242]={u=0.125,w=0,v=0.5,},[243]={u=0.375,w=0,v=0.25,},[244]={u=0.375,w=0,v=0.5,},[245]={u=0.375,w=0,v=0.25,},[246]={u=0.5,w=0,v=0.5,},[247]={u=0.375,w=0,v=0.5,},[248]={u=0.375,w=0,v=0.25,},[249]={u=0.125,w=0,v=0.5,},[250]={u=0.375,w=0,v=0.25,},[251]={u=0.5,w=0,v=0.5,},[252]={u=0.375,w=0,v=0.5,},[253]={u=0.375,w=0,v=0.5,},[254]={u=0.125,w=0,v=0.5,},[255]={u=0.375,w=0,v=0.25,},[256]={u=0.375,w=0,v=0.25,},[257]={u=0.125,w=0,v=0.5,},[258]={u=0.5,w=0,v=0.5,},[259]={u=0.375,w=0,v=0.5,},[260]={u=0.5,w=0,v=0.5,},[261]={u=0.375,w=0,v=0.5,},[262]={u=0.375,w=0,v=0.25,},[263]={u=0.125,w=0,v=0.5,},[264]={u=0.125,w=0,v=0.625,},[265]={u=0,w=0,v=0,},[266]={u=0,w=0,v=0,},[267]={u=0.125,w=0,v=0.625,},[268]={u=0.375,w=0,v=0.25,},[269]={u=0.125,w=0,v=0.5,},[270]={u=0.375,w=0,v=0.25,},[271]={u=0.125,w=0,v=0.5,},[272]={u=0,w=0,v=0,},[273]={u=0.125,w=0,v=0.625,},[274]={u=0,w=0,v=0,},[275]={u=0.125,w=0,v=0.625,},[276]={u=0.125,w=0,v=0.5,},[277]={u=0.375,w=0,v=0.25,},[278]={u=0.375,w=0,v=0.25,},[279]={u=0.125,w=0,v=0.5,},[280]={u=0,w=0,v=0,},[281]={u=0.125,w=0,v=0.625,},[282]={u=0,w=0,v=0,},[283]={u=0.125,w=0,v=0.625,},[284]={u=0.125,w=0,v=0.5,},[285]={u=0.375,w=0,v=0.25,},[286]={u=0.125,w=0,v=0.5,},[287]={u=0.375,w=0,v=0.25,},[288]={u=0,w=0,v=0,},[289]={u=0.125,w=0,v=0.625,},[290]={u=0.125,w=0,v=0.625,},[291]={u=0,w=0,v=0,},[292]={u=0.375,w=0,v=0.25,},[293]={u=0.125,w=0,v=0.5,},[294]={u=0.375,w=0,v=0.25,},[295]={u=0.125,w=0,v=0.5,},[296]={u=0.375,w=0,v=0.25,},[297]={u=0.125,w=0,v=0.5,},[298]={u=0,w=0,v=0,},[299]={u=0.125,w=0,v=0.625,},[300]={u=0.125,w=0,v=0.625,},[301]={u=0,w=0,v=0,},[302]={u=0.375,w=0,v=0.25,},[303]={u=0.125,w=0,v=0.5,},[304]={u=0,w=0,v=0,},[305]={u=0.125,w=0,v=0.625,},[306]={u=0,w=0,v=0,},[307]={u=0.125,w=0,v=0.625,},[308]={u=0.125,w=0,v=0.5,},[309]={u=0.375,w=0,v=0.25,},[310]={u=0.375,w=0,v=0.25,},[311]={u=0.125,w=0,v=0.5,},[312]={u=0,w=0,v=0,},[313]={u=0.125,w=0,v=0.625,},[314]={u=0.125,w=0,v=0.5,},[315]={u=0.375,w=0,v=0.25,},[316]={u=0.125,w=0,v=0.597128,},[317]={u=0,w=0,v=0,},[318]={u=0.125,w=0,v=0.625,},[319]={u=0.375,w=0,v=0.25,},[320]={u=0.125,w=0,v=0.5,},[321]={u=0.125,w=0,v=0.625,},[322]={u=0,w=0,v=0,},[323]={u=0,w=0,v=0,},[324]={u=0.125,w=0,v=0.625,},[325]={u=0.375,w=0,v=0.25,},[326]={u=0.125,w=0,v=0.5,},[327]={u=0.375,w=0,v=0.5,},[328]={u=0.375,w=0,v=0.25,},[329]={u=0.375,w=0,v=0.5,},[330]={u=0.375,w=0,v=0.5,},[331]={u=0.375,w=0,v=0.25,},[332]={u=0.375,w=0,v=0.5,},[333]={u=0.375,w=0,v=0.5,},[334]={u=0.375,w=0,v=0.25,},[335]={u=0.375,w=0,v=0.5,},[336]={u=0.375,w=0,v=0.5,},[337]={u=0.375,w=0,v=0.25,},[338]={u=0.375,w=0,v=0.5,},[339]={u=0.375,w=0,v=0.5,},[340]={u=0.375,w=0,v=0.25,},[341]={u=0.375,w=0,v=0.5,},[342]={u=0.375,w=0,v=0.5,},[343]={u=0.375,w=0,v=0.25,},[344]={u=0.375,w=0,v=0.5,},[345]={u=0.375,w=0,v=0.5,},[346]={u=0.375,w=0,v=0.25,},[347]={u=0.375,w=0,v=0.5,},[348]={u=0.375,w=0,v=0.5,},[349]={u=0.375,w=0,v=0.25,},[350]={u=0.375,w=0,v=0.5,},[351]={u=0.125,w=0,v=0.5625,},[352]={u=0.125,w=0,v=0.5625,},[353]={u=0.125,w=0,v=0.5625,},[354]={u=0.125,w=0,v=0.5625,},[355]={u=0.125,w=0,v=0.5625,},[356]={u=0.125,w=0,v=0.5625,},[357]={u=0.125,w=0,v=0.5625,},[358]={u=0.125,w=0,v=0.5625,},[359]={u=0.125,w=0,v=0.5625,},[360]={u=0.125,w=0,v=0.5625,},[361]={u=0.125,w=0,v=0.5625,},[362]={u=0.125,w=0,v=0.5625,},[363]={u=0.125,w=0,v=0.5625,},[364]={u=0.125,w=0,v=0.5625,},[365]={u=0.125,w=0,v=0.5625,},[366]={u=0.125,w=0,v=0.5625,},[367]={u=0.125,w=0,v=0.5625,},[368]={u=0.125,w=0,v=0.5625,},[369]={u=0.125,w=0,v=0.5625,},[370]={u=0.125,w=0,v=0.5625,},[371]={u=0.125,w=0,v=0.5625,},[372]={u=0.125,w=0,v=0.5625,},[373]={u=0.125,w=0,v=0.5625,},[374]={u=0.556045,w=0,v=0.25,},},vn={[1]={y=0.0589,x=0.9779,z=-0.2005,},[2]={y=-0.2174,x=0.9333,z=0.2856,},[3]={y=-0.7398,x=0.3066,z=0.599,},[4]={y=-0.5432,x=0.8215,z=-0.1733,},[5]={y=-0.4687,x=0.2857,z=0.8359,},[6]={y=0.9898,x=-0.1167,z=0.0822,},[7]={y=0.5762,x=0.1467,z=0.8041,},[8]={y=-0.096,x=0.9739,z=0.2057,},[9]={y=-0.9186,x=0.3325,z=0.2138,},[10]={y=-0.8545,x=0.4111,z=-0.3175,},[11]={y=-0.7445,x=0.648,z=0.1607,},[12]={y=0.6856,x=0.1545,z=-0.7114,},[13]={y=0.7954,x=0.2603,z=-0.5474,},[14]={y=0.2978,x=0.8918,z=0.3405,},[15]={y=0.3657,x=0.3382,z=0.8671,},[16]={y=0.7265,x=0.2762,z=-0.6292,},[17]={y=-0.4123,x=0.9064,z=-0.0917,},[18]={y=0.7121,x=-0.0799,z=0.6975,},[19]={y=-0.0424,x=0.9954,z=0.0854,},[20]={y=0.2982,x=0.9423,z=0.1524,},[21]={y=0.1605,x=0.8673,z=-0.4711,},[22]={y=0.4492,x=0.8507,z=0.2728,},[23]={y=0.2181,x=0.949,z=0.2276,},[24]={y=-0.8996,x=0.4359,z=0.0284,},[25]={y=0.8512,x=0.3305,z=0.4077,},[26]={y=-0.658,x=0.688,z=-0.3061,},[27]={y=0.166,x=0.9365,z=0.3087,},[28]={y=-0.6483,x=0.7438,z=0.1629,},[29]={y=-0.3246,x=0.938,z=0.1215,},[30]={y=-0.3413,x=0.9322,z=0.1206,},[31]={y=0.6249,x=0.762,z=-0.1696,},[32]={y=-0.2284,x=0.844,z=0.4852,},[33]={y=-0.8235,x=0.5568,z=0.1089,},[34]={y=0.7219,x=0.458,z=-0.5187,},[35]={y=-0.6226,x=0.7087,z=0.3317,},[36]={y=-0.3267,x=0.9305,z=0.1656,},[37]={y=-0.3264,x=0.9072,z=0.2655,},[38]={y=0.9404,x=0.2506,z=-0.2301,},[39]={y=-0.8899,x=0.3443,z=0.299,},[40]={y=-0.8571,x=0.4266,z=0.2889,},[41]={y=0.929,x=0.2141,z=0.302,},[42]={y=0.4917,x=0.8707,z=0.0068,},[43]={y=-0.2804,x=0.9588,z=0.0446,},[44]={y=-0.2217,x=0.9582,z=0.1808,},[45]={y=-0.8164,x=0.5547,z=0.1605,},[46]={y=-0.4598,x=0.8879,z=-0.0147,},[47]={y=0.3425,x=0.8978,z=-0.2768,},[48]={y=-0.8842,x=0.2467,z=0.3966,},[49]={y=0.8336,x=0.1433,z=-0.5334,},[50]={y=-0.8953,x=0.2465,z=0.3709,},[51]={y=0.5035,x=0.8304,z=-0.2386,},[52]={y=-0.1511,x=0.1798,z=-0.972,},[53]={y=0.6855,x=-0.0505,z=-0.7263,},[54]={y=-0.5035,x=0.0153,z=-0.8639,},[55]={y=0.7033,x=-0.063,z=-0.7081,},[56]={y=-0.6418,x=0.7648,z=0.0566,},[57]={y=-0.1986,x=0.9471,z=0.2522,},[58]={y=-0.8948,x=0.4388,z=0.0825,},[59]={y=-0.6044,x=0.7863,z=0.1283,},[60]={y=-0.8735,x=0.2102,z=0.4391,},[61]={y=-0.7536,x=0.0102,z=-0.6572,},[62]={y=0.0179,x=0.5397,z=-0.8417,},[63]={y=-0.0539,x=-0.7887,z=-0.6124,},[64]={y=-0.9711,x=-0.0044,z=0.2385,},[65]={y=-0.276,x=0.8438,z=0.4603,},[66]={y=-0.0716,x=0.0866,z=-0.9937,},[67]={y=0.1348,x=-0.7256,z=-0.6748,},[68]={y=-0.0052,x=-0.0198,z=-0.9998,},[69]={y=-0.3347,x=-0.064,z=0.9401,},[70]={y=-0.1796,x=-0.978,z=-0.1066,},[71]={y=0.8176,x=0.1286,z=0.5612,},[72]={y=-0.9478,x=-0.1647,z=-0.273,},[73]={y=0.0819,x=0.9253,z=0.3702,},[74]={y=-0,x=-0,z=-1,},[75]={y=-0.4771,x=0.7793,z=0.4062,},[76]={y=-0.3583,x=-0.9274,z=0.1076,},[77]={y=-0.8496,x=0.0815,z=-0.5211,},[78]={y=0.6075,x=0.1123,z=0.7864,},[79]={y=0.2309,x=-0.9708,z=-0.0651,},[80]={y=0.1707,x=0.9207,z=-0.351,},[81]={y=0.5734,x=0.1459,z=0.8062,},[82]={y=0.4966,x=-0.8532,z=0.1596,},[83]={y=0.3424,x=0.0465,z=0.9384,},[84]={y=-0.9844,x=-0.0255,z=0.174,},[85]={y=-0.1328,x=0.0443,z=-0.9902,},[86]={y=0.3965,x=0.896,z=-0.1999,},[87]={y=0.5776,x=0.0384,z=-0.8154,},[88]={y=0.5816,x=0.5826,z=0.5677,},[89]={y=0.6356,x=-0.7283,z=0.2561,},[90]={y=-0.5924,x=0.7549,z=0.2813,},[91]={y=-0.0776,x=0.9725,z=0.2197,},[92]={y=0.1072,x=0.9941,z=0.0136,},[93]={y=0.7771,x=0.3815,z=-0.5006,},[94]={y=-0.923,x=0.3791,z=0.0654,},[95]={y=-0.4871,x=0.7486,z=0.4499,},[96]={y=0.1234,x=0.9885,z=-0.0877,},[97]={y=0.7574,x=0.6503,z=-0.0588,},[98]={y=0.192,x=-0.948,z=-0.2538,},[99]={y=0.2544,x=-0.9284,z=-0.2707,},[100]={y=-0.5755,x=0.736,z=0.3566,},[101]={y=-0.8294,x=0.4987,z=0.2517,},[102]={y=0.4957,x=-0.846,z=0.1964,},[103]={y=-0.6801,x=0.5398,z=-0.496,},[104]={y=0.186,x=-0.9711,z=-0.1495,},[105]={y=-0.7543,x=0.6124,z=-0.2369,},[106]={y=0.267,x=-0.9592,z=-0.0932,},[107]={y=-0.9495,x=0.1984,z=-0.243,},[108]={y=0.3353,x=0.8665,z=-0.3698,},[109]={y=-0.6705,x=0.3164,z=-0.6711,},[110]={y=-0.7906,x=0.2187,z=-0.5719,},[111]={y=0.4908,x=0.8702,z=-0.0438,},[112]={y=0.2647,x=0.9554,z=-0.1307,},[113]={y=0.1056,x=-0.9917,z=0.0738,},[114]={y=0.4503,x=0.0078,z=-0.8928,},[115]={y=0.3392,x=0.1247,z=0.9324,},[116]={y=0.5814,x=0.0715,z=0.8104,},[117]={y=0.7084,x=0.1209,z=0.6954,},[118]={y=-0.8333,x=0.0113,z=-0.5527,},[119]={y=-0.9689,x=-0.1684,z=-0.1811,},[120]={y=0.7792,x=0.2101,z=0.5905,},[121]={y=-0.3221,x=-0.0782,z=0.9435,},[122]={y=-0.0275,x=0.0003,z=-0.9996,},[123]={y=-0.981,x=-0.0225,z=0.1927,},[124]={y=-0.7631,x=0.0219,z=-0.6459,},[125]={y=0.868,x=0.0013,z=-0.4966,},[126]={y=0.8261,x=0.1376,z=-0.5464,},[127]={y=0.9054,x=0.1614,z=0.3927,},[128]={y=0.9605,x=0.19,z=-0.2034,},[129]={y=0.81,x=0.0886,z=-0.5797,},[130]={y=0.8944,x=0.1108,z=0.4334,},[131]={y=0.6946,x=0.1497,z=0.7036,},[132]={y=0.9154,x=0.3969,z=0.067,},[133]={y=0.2537,x=0.9663,z=0.0444,},[134]={y=0.2995,x=0.9522,z=-0.0607,},[135]={y=-0.219,x=0.9357,z=0.2766,},[136]={y=-0.7007,x=0.2236,z=0.6775,},[137]={y=-0.4282,x=0.8843,z=-0.186,},[138]={y=-0.4717,x=0.2941,z=0.8312,},[139]={y=0.9665,x=0.1076,z=0.2332,},[140]={y=0.6389,x=0.2424,z=0.7301,},[141]={y=-0.0597,x=0.978,z=0.2001,},[142]={y=-0.9282,x=0.1672,z=0.3325,},[143]={y=-0.8712,x=0.3774,z=-0.3139,},[144]={y=-0.7003,x=0.6051,z=0.3788,},[145]={y=0.7944,x=0.2512,z=-0.5531,},[146]={y=0.8767,x=0.4636,z=-0.1279,},[147]={y=0.9221,x=0.3752,z=-0.0945,},[148]={y=-0.7555,x=0.624,z=0.1998,},[149]={y=0.7569,x=0.3388,z=0.5589,},[150]={y=-0.1079,x=0.9912,z=-0.0771,},[151]={y=0.2268,x=0.9116,z=0.3428,},[152]={y=0.4693,x=0.8285,z=0.3055,},[153]={y=0.2388,x=0.9382,z=0.2505,},[154]={y=-0.877,x=0.4803,z=0.0158,},[155]={y=0.8588,x=0.2458,z=0.4495,},[156]={y=-0.8294,x=0.467,z=-0.3065,},[157]={y=0.0799,x=0.9503,z=0.3009,},[158]={y=-0.6834,x=0.6905,z=0.2372,},[159]={y=-0.3321,x=0.9361,z=0.1163,},[160]={y=-0.3377,x=0.9348,z=0.11,},[161]={y=0.4989,x=0.8424,z=-0.2038,},[162]={y=-0.2409,x=0.8464,z=0.4748,},[163]={y=-0.6656,x=0.7433,z=0.0666,},[164]={y=0.8738,x=0.1766,z=-0.4532,},[165]={y=-0.5802,x=0.7637,z=0.2831,},[166]={y=-0.2165,x=0.9585,z=0.1854,},[167]={y=-0.2822,x=0.9381,z=0.2007,},[168]={y=0.7924,x=0.5488,z=-0.2663,},[169]={y=-0.8905,x=0.2907,z=0.3501,},[170]={y=-0.9302,x=0.2988,z=0.213,},[171]={y=0.9058,x=0.3909,z=0.1638,},[172]={y=0.5158,x=0.8546,z=0.0591,},[173]={y=-0.3824,x=0.9239,z=-0.0168,},[174]={y=-0.3029,x=0.9517,z=0.0509,},[175]={y=-0.6899,x=0.6895,z=0.2207,},[176]={y=-0.4772,x=0.8788,z=0.0071,},[177]={y=0.3882,x=0.8864,z=-0.252,},[178]={y=-0.898,x=0.2165,z=0.3831,},[179]={y=0.848,x=0.115,z=-0.5174,},[180]={y=-0.8781,x=0.3504,z=0.3259,},[181]={y=0.3394,x=0.9069,z=-0.2498,},[182]={y=-0.2795,x=0.0373,z=-0.9594,},[183]={y=-0.1018,x=0.091,z=-0.9906,},[184]={y=0.3482,x=0.1105,z=-0.9309,},[185]={y=-0.2591,x=0.1676,z=-0.9512,},[186]={y=0.6223,x=-0.3177,z=-0.7154,},[187]={y=-0.691,x=0.6865,z=0.2264,},[188]={y=-0.5187,x=0.8549,z=0.0082,},[189]={y=-0.8485,x=0.4941,z=0.1894,},[190]={y=-0.5637,x=0.82,z=0.0996,},[191]={y=-0.7611,x=0.4497,z=0.4675,},[192]={y=-0.74,x=0.0226,z=-0.6723,},[193]={y=-0.2458,x=0.2094,z=-0.9464,},[194]={y=-0.1544,x=-0.6904,z=-0.7068,},[195]={y=-0.9664,x=-0.0122,z=0.2566,},[196]={y=-0.4554,x=0.8902,z=-0.0135,},[197]={y=-0.1392,x=0.5395,z=-0.8304,},[198]={y=-0.1735,x=-0.2203,z=-0.9599,},[199]={y=0.0197,x=0.0142,z=-0.9997,},[200]={y=-0.3392,x=-0.0836,z=0.937,},[201]={y=-0.0693,x=-0.9005,z=0.4292,},[202]={y=0.8256,x=0.2203,z=0.5195,},[203]={y=-0.9313,x=0.0855,z=-0.3542,},[204]={y=0.0117,x=0.9649,z=0.2624,},[205]={y=-0.6407,x=0.7359,z=0.2189,},[206]={y=-0.0233,x=-0.909,z=0.4162,},[207]={y=-0.8821,x=0.012,z=-0.4708,},[208]={y=0.548,x=0.1445,z=0.8239,},[209]={y=0.0896,x=-0.9864,z=0.1379,},[210]={y=0.2152,x=0.8966,z=-0.387,},[211]={y=0.5944,x=0.0728,z=0.8008,},[212]={y=0.5423,x=-0.8005,z=0.2551,},[213]={y=0.3083,x=0.1155,z=0.9442,},[214]={y=0.3992,x=-0.0603,z=-0.9149,},[215]={y=0.0871,x=0.7384,z=-0.6688,},[216]={y=0.6911,x=-0.0492,z=-0.7211,},[217]={y=0.3849,x=0.8618,z=0.3304,},[218]={y=0.7328,x=-0.4333,z=0.5246,},[219]={y=-0.5693,x=0.7813,z=0.2559,},[220]={y=0.0081,x=0.9488,z=0.3158,},[221]={y=0.0906,x=0.9958,z=0.0135,},[222]={y=0.7856,x=0.3657,z=-0.4991,},[223]={y=-0.9746,x=-0.0222,z=0.2227,},[224]={y=-0.4644,x=0.7712,z=0.4355,},[225]={y=0.0535,x=0.9915,z=-0.1188,},[226]={y=0.5201,x=0.8463,z=-0.1147,},[227]={y=0.252,x=-0.9363,z=-0.2447,},[228]={y=0.2233,x=-0.9352,z=-0.275,},[229]={y=-0.8002,x=0.5445,z=0.2515,},[230]={y=-0.9272,x=0.1161,z=0.3561,},[231]={y=0.0824,x=-0.9946,z=0.0631,},[232]={y=-0.7145,x=0.4902,z=-0.4991,},[233]={y=0.1697,x=-0.9729,z=-0.1573,},[234]={y=-0.8751,x=0.4409,z=-0.1994,},[235]={y=0.4728,x=-0.8753,z=-0.1014,},[236]={y=-0.9215,x=0.3065,z=-0.2386,},[237]={y=0.5909,x=0.7344,z=-0.334,},[238]={y=-0.6677,x=0.3155,z=-0.6743,},[239]={y=-0.8179,x=-0.0107,z=-0.5753,},[240]={y=0.0666,x=0.986,z=-0.1531,},[241]={y=0.1181,x=-0.9894,z=0.0849,},[242]={y=0.5208,x=-0.0843,z=-0.8495,},[243]={y=0.6124,x=0.1588,z=0.7745,},[244]={y=-0.961,x=0.0864,z=-0.2625,},[245]={y=0.7239,x=0.2189,z=-0.6543,},[246]={y=0.8376,x=0.1116,z=-0.5348,},[247]={y=0.8986,x=0.3333,z=0.2855,},[248]={y=0.9303,x=0.2894,z=-0.2254,},[249]={y=0.8003,x=0.1187,z=-0.5878,},[250]={y=0.8966,x=0.1658,z=0.4107,},[251]={y=0.6873,x=0.1655,z=0.7072,},[252]={y=0.0706,x=0.2972,z=-0.9522,},[253]={y=0.6904,x=0.1297,z=-0.7117,},[254]={y=0.0589,x=-0.9779,z=-0.2005,},[255]={y=-0.2174,x=-0.9333,z=0.2856,},[256]={y=-0.7398,x=-0.3066,z=0.599,},[257]={y=-0.5432,x=-0.8215,z=-0.1733,},[258]={y=-0.4687,x=-0.2857,z=0.8359,},[259]={y=0.9898,x=0.1167,z=0.0822,},[260]={y=0.5762,x=-0.1467,z=0.8041,},[261]={y=-0.096,x=-0.9739,z=0.2057,},[262]={y=-0.9186,x=-0.3325,z=0.2138,},[263]={y=-0.8545,x=-0.4111,z=-0.3175,},[264]={y=-0.7445,x=-0.648,z=0.1607,},[265]={y=0.6856,x=-0.1545,z=-0.7114,},[266]={y=0.7954,x=-0.2603,z=-0.5474,},[267]={y=0.2978,x=-0.8918,z=0.3405,},[268]={y=0.3657,x=-0.3382,z=0.8671,},[269]={y=0.7265,x=-0.2762,z=-0.6292,},[270]={y=-0.4123,x=-0.9064,z=-0.0917,},[271]={y=0.7121,x=0.0799,z=0.6975,},[272]={y=-0.0424,x=-0.9954,z=0.0854,},[273]={y=0.2982,x=-0.9423,z=0.1524,},[274]={y=0.1605,x=-0.8673,z=-0.4711,},[275]={y=0.4492,x=-0.8507,z=0.2728,},[276]={y=0.2181,x=-0.949,z=0.2276,},[277]={y=-0.8996,x=-0.4359,z=0.0284,},[278]={y=0.8512,x=-0.3305,z=0.4077,},[279]={y=-0.658,x=-0.688,z=-0.3061,},[280]={y=0.166,x=-0.9365,z=0.3087,},[281]={y=-0.6483,x=-0.7438,z=0.1629,},[282]={y=-0.3246,x=-0.938,z=0.1215,},[283]={y=-0.3413,x=-0.9322,z=0.1206,},[284]={y=0.6249,x=-0.762,z=-0.1696,},[285]={y=-0.2284,x=-0.844,z=0.4852,},[286]={y=-0.8235,x=-0.5568,z=0.1089,},[287]={y=0.7219,x=-0.458,z=-0.5187,},[288]={y=-0.6226,x=-0.7087,z=0.3317,},[289]={y=-0.3267,x=-0.9305,z=0.1656,},[290]={y=-0.3264,x=-0.9072,z=0.2655,},[291]={y=0.9404,x=-0.2506,z=-0.2301,},[292]={y=-0.8899,x=-0.3443,z=0.299,},[293]={y=-0.8571,x=-0.4266,z=0.2889,},[294]={y=0.929,x=-0.2141,z=0.302,},[295]={y=0.4917,x=-0.8707,z=0.0068,},[296]={y=-0.2804,x=-0.9588,z=0.0446,},[297]={y=-0.2217,x=-0.9582,z=0.1808,},[298]={y=-0.8164,x=-0.5547,z=0.1605,},[299]={y=-0.4598,x=-0.8879,z=-0.0147,},[300]={y=0.3425,x=-0.8978,z=-0.2768,},[301]={y=-0.8842,x=-0.2467,z=0.3966,},[302]={y=0.8336,x=-0.1433,z=-0.5334,},[303]={y=-0.8953,x=-0.2465,z=0.3709,},[304]={y=0.5035,x=-0.8304,z=-0.2386,},[305]={y=-0.1511,x=-0.1798,z=-0.972,},[306]={y=0.6855,x=0.0505,z=-0.7263,},[307]={y=-0.5035,x=-0.0153,z=-0.8639,},[308]={y=0.7033,x=0.063,z=-0.7081,},[309]={y=-0.6418,x=-0.7648,z=0.0566,},[310]={y=-0.1986,x=-0.9471,z=0.2522,},[311]={y=-0.8948,x=-0.4388,z=0.0825,},[312]={y=-0.6044,x=-0.7863,z=0.1283,},[313]={y=-0.8735,x=-0.2102,z=0.4391,},[314]={y=-0.7536,x=-0.0102,z=-0.6572,},[315]={y=0.0179,x=-0.5397,z=-0.8417,},[316]={y=-0.0539,x=0.7887,z=-0.6124,},[317]={y=-0.9711,x=0.0044,z=0.2385,},[318]={y=-0.276,x=-0.8438,z=0.4603,},[319]={y=-0.0716,x=-0.0866,z=-0.9937,},[320]={y=0.1348,x=0.7256,z=-0.6748,},[321]={y=-0.0052,x=0.0198,z=-0.9998,},[322]={y=-0.3347,x=0.064,z=0.9401,},[323]={y=-0.1796,x=0.978,z=-0.1066,},[324]={y=0.8176,x=-0.1286,z=0.5612,},[325]={y=-0.9478,x=0.1647,z=-0.273,},[326]={y=0.0819,x=-0.9253,z=0.3702,},[327]={y=-0.4771,x=-0.7793,z=0.4062,},[328]={y=-0.3583,x=0.9274,z=0.1076,},[329]={y=-0.8496,x=-0.0815,z=-0.5211,},[330]={y=0.6075,x=-0.1123,z=0.7864,},[331]={y=0.2309,x=0.9708,z=-0.0651,},[332]={y=0.1707,x=-0.9207,z=-0.351,},[333]={y=0.5734,x=-0.1459,z=0.8062,},[334]={y=0.4966,x=0.8532,z=0.1596,},[335]={y=0.3424,x=-0.0465,z=0.9384,},[336]={y=-0.9844,x=0.0255,z=0.174,},[337]={y=-0.1328,x=-0.0443,z=-0.9902,},[338]={y=0.3965,x=-0.896,z=-0.1999,},[339]={y=0.5776,x=-0.0384,z=-0.8154,},[340]={y=0.5816,x=-0.5826,z=0.5677,},[341]={y=0.6356,x=0.7283,z=0.2561,},[342]={y=-0.5924,x=-0.7549,z=0.2813,},[343]={y=-0.0776,x=-0.9725,z=0.2197,},[344]={y=0.1072,x=-0.9942,z=0.0136,},[345]={y=0.7771,x=-0.3815,z=-0.5006,},[346]={y=-0.923,x=-0.3791,z=0.0654,},[347]={y=-0.4871,x=-0.7486,z=0.4499,},[348]={y=0.1234,x=-0.9885,z=-0.0877,},[349]={y=0.7574,x=-0.6503,z=-0.0588,},[350]={y=0.192,x=0.948,z=-0.2538,},[351]={y=0.2544,x=0.9284,z=-0.2707,},[352]={y=-0.5755,x=-0.736,z=0.3566,},[353]={y=-0.8294,x=-0.4987,z=0.2517,},[354]={y=0.4957,x=0.846,z=0.1964,},[355]={y=-0.6801,x=-0.5398,z=-0.496,},[356]={y=0.186,x=0.9711,z=-0.1495,},[357]={y=-0.7543,x=-0.6124,z=-0.2369,},[358]={y=0.267,x=0.9592,z=-0.0932,},[359]={y=-0.9495,x=-0.1984,z=-0.243,},[360]={y=0.3353,x=-0.8665,z=-0.3698,},[361]={y=-0.6705,x=-0.3164,z=-0.6711,},[362]={y=-0.7906,x=-0.2187,z=-0.5719,},[363]={y=0.4908,x=-0.8702,z=-0.0438,},[364]={y=0.2647,x=-0.9554,z=-0.1307,},[365]={y=0.1056,x=0.9917,z=0.0738,},[366]={y=0.4503,x=-0.0078,z=-0.8928,},[367]={y=0.3392,x=-0.1247,z=0.9324,},[368]={y=0.5814,x=-0.0715,z=0.8104,},[369]={y=0.7084,x=-0.1209,z=0.6954,},[370]={y=-0.8333,x=-0.0113,z=-0.5527,},[371]={y=-0.9689,x=0.1684,z=-0.1811,},[372]={y=0.7792,x=-0.2101,z=0.5905,},[373]={y=-0.3221,x=0.0782,z=0.9435,},[374]={y=-0.0275,x=-0.0003,z=-0.9996,},[375]={y=-0.981,x=0.0225,z=0.1927,},[376]={y=-0.7631,x=-0.0219,z=-0.6459,},[377]={y=0.868,x=-0.0013,z=-0.4966,},[378]={y=0.8261,x=-0.1376,z=-0.5464,},[379]={y=0.9054,x=-0.1614,z=0.3927,},[380]={y=0.9605,x=-0.19,z=-0.2034,},[381]={y=0.81,x=-0.0886,z=-0.5797,},[382]={y=0.8944,x=-0.1108,z=0.4334,},[383]={y=0.6946,x=-0.1497,z=0.7036,},[384]={y=0.9154,x=-0.3969,z=0.067,},[385]={y=0.2537,x=-0.9663,z=0.0444,},[386]={y=0.2995,x=-0.9522,z=-0.0607,},[387]={y=-0.219,x=-0.9357,z=0.2766,},[388]={y=-0.7007,x=-0.2236,z=0.6775,},[389]={y=-0.4282,x=-0.8843,z=-0.186,},[390]={y=-0.4717,x=-0.2941,z=0.8312,},[391]={y=0.9665,x=-0.1076,z=0.2332,},[392]={y=0.6389,x=-0.2424,z=0.7301,},[393]={y=-0.0597,x=-0.978,z=0.2001,},[394]={y=-0.9282,x=-0.1672,z=0.3325,},[395]={y=-0.8712,x=-0.3774,z=-0.3139,},[396]={y=-0.7003,x=-0.6051,z=0.3788,},[397]={y=0.7944,x=-0.2512,z=-0.5531,},[398]={y=0.8767,x=-0.4636,z=-0.1279,},[399]={y=0.9221,x=-0.3752,z=-0.0945,},[400]={y=-0.7555,x=-0.624,z=0.1998,},[401]={y=0.7569,x=-0.3388,z=0.5589,},[402]={y=-0.1079,x=-0.9912,z=-0.0771,},[403]={y=0.2268,x=-0.9116,z=0.3428,},[404]={y=0.4693,x=-0.8285,z=0.3055,},[405]={y=0.2388,x=-0.9382,z=0.2505,},[406]={y=-0.877,x=-0.4803,z=0.0158,},[407]={y=0.8588,x=-0.2458,z=0.4495,},[408]={y=-0.8294,x=-0.467,z=-0.3065,},[409]={y=0.0799,x=-0.9503,z=0.3009,},[410]={y=-0.6834,x=-0.6905,z=0.2372,},[411]={y=-0.3321,x=-0.9361,z=0.1163,},[412]={y=-0.3377,x=-0.9348,z=0.11,},[413]={y=0.4989,x=-0.8424,z=-0.2038,},[414]={y=-0.2409,x=-0.8464,z=0.4748,},[415]={y=-0.6656,x=-0.7433,z=0.0666,},[416]={y=0.8738,x=-0.1766,z=-0.4532,},[417]={y=-0.5802,x=-0.7637,z=0.2831,},[418]={y=-0.2165,x=-0.9585,z=0.1854,},[419]={y=-0.2822,x=-0.9381,z=0.2007,},[420]={y=0.7924,x=-0.5488,z=-0.2663,},[421]={y=-0.8905,x=-0.2907,z=0.3501,},[422]={y=-0.9302,x=-0.2988,z=0.213,},[423]={y=0.9058,x=-0.3909,z=0.1638,},[424]={y=0.5158,x=-0.8546,z=0.0591,},[425]={y=-0.3824,x=-0.9239,z=-0.0168,},[426]={y=-0.3029,x=-0.9517,z=0.0509,},[427]={y=-0.6899,x=-0.6895,z=0.2207,},[428]={y=-0.4772,x=-0.8788,z=0.0071,},[429]={y=0.3882,x=-0.8864,z=-0.252,},[430]={y=-0.898,x=-0.2165,z=0.3831,},[431]={y=0.848,x=-0.115,z=-0.5174,},[432]={y=-0.8781,x=-0.3504,z=0.3259,},[433]={y=0.3394,x=-0.9069,z=-0.2498,},[434]={y=-0.2795,x=-0.0373,z=-0.9594,},[435]={y=-0.1018,x=-0.091,z=-0.9906,},[436]={y=0.3482,x=-0.1105,z=-0.9309,},[437]={y=-0.2591,x=-0.1676,z=-0.9512,},[438]={y=0.6223,x=0.3177,z=-0.7154,},[439]={y=-0.691,x=-0.6865,z=0.2264,},[440]={y=-0.5187,x=-0.8549,z=0.0082,},[441]={y=-0.8485,x=-0.4941,z=0.1894,},[442]={y=-0.5637,x=-0.82,z=0.0996,},[443]={y=-0.7611,x=-0.4497,z=0.4675,},[444]={y=-0.74,x=-0.0226,z=-0.6723,},[445]={y=-0.2458,x=-0.2094,z=-0.9464,},[446]={y=-0.1544,x=0.6904,z=-0.7068,},[447]={y=-0.9664,x=0.0122,z=0.2566,},[448]={y=-0.4554,x=-0.8902,z=-0.0135,},[449]={y=-0.1392,x=-0.5395,z=-0.8304,},[450]={y=-0.1735,x=0.2203,z=-0.9599,},[451]={y=0.0197,x=-0.0142,z=-0.9997,},[452]={y=-0.3392,x=0.0836,z=0.937,},[453]={y=-0.0693,x=0.9005,z=0.4292,},[454]={y=0.8256,x=-0.2203,z=0.5195,},[455]={y=-0.9313,x=-0.0855,z=-0.3542,},[456]={y=0.0117,x=-0.9649,z=0.2624,},[457]={y=-0.6407,x=-0.7359,z=0.2189,},[458]={y=-0.0233,x=0.909,z=0.4162,},[459]={y=-0.8821,x=-0.012,z=-0.4708,},[460]={y=0.548,x=-0.1445,z=0.8239,},[461]={y=0.0896,x=0.9864,z=0.1379,},[462]={y=0.2152,x=-0.8966,z=-0.387,},[463]={y=0.5944,x=-0.0728,z=0.8008,},[464]={y=0.5423,x=0.8005,z=0.2551,},[465]={y=0.3083,x=-0.1155,z=0.9442,},[466]={y=0.3992,x=0.0603,z=-0.9149,},[467]={y=0.0871,x=-0.7384,z=-0.6688,},[468]={y=0.6911,x=0.0492,z=-0.7211,},[469]={y=0.3849,x=-0.8618,z=0.3304,},[470]={y=0.7328,x=0.4333,z=0.5246,},[471]={y=-0.5693,x=-0.7813,z=0.2559,},[472]={y=0.0081,x=-0.9488,z=0.3158,},[473]={y=0.0906,x=-0.9958,z=0.0135,},[474]={y=0.7856,x=-0.3657,z=-0.4991,},[475]={y=-0.9746,x=0.0222,z=0.2227,},[476]={y=-0.4644,x=-0.7712,z=0.4355,},[477]={y=0.0535,x=-0.9915,z=-0.1188,},[478]={y=0.5201,x=-0.8463,z=-0.1147,},[479]={y=0.252,x=0.9363,z=-0.2447,},[480]={y=0.2233,x=0.9352,z=-0.275,},[481]={y=-0.8002,x=-0.5445,z=0.2515,},[482]={y=-0.9272,x=-0.1161,z=0.3561,},[483]={y=0.0824,x=0.9946,z=0.0631,},[484]={y=-0.7145,x=-0.4902,z=-0.4991,},[485]={y=0.1697,x=0.9729,z=-0.1573,},[486]={y=-0.8751,x=-0.4409,z=-0.1994,},[487]={y=0.4728,x=0.8753,z=-0.1014,},[488]={y=-0.9215,x=-0.3065,z=-0.2386,},[489]={y=0.5909,x=-0.7344,z=-0.334,},[490]={y=-0.6677,x=-0.3155,z=-0.6743,},[491]={y=-0.8179,x=0.0107,z=-0.5753,},[492]={y=0.0666,x=-0.986,z=-0.1531,},[493]={y=0.1181,x=0.9894,z=0.0849,},[494]={y=0.5208,x=0.0843,z=-0.8495,},[495]={y=0.6124,x=-0.1588,z=0.7745,},[496]={y=-0.961,x=-0.0864,z=-0.2625,},[497]={y=0.7239,x=-0.2189,z=-0.6543,},[498]={y=0.8376,x=-0.1116,z=-0.5348,},[499]={y=0.8986,x=-0.3333,z=0.2855,},[500]={y=0.9303,x=-0.2894,z=-0.2254,},[501]={y=0.8003,x=-0.1187,z=-0.5878,},[502]={y=0.8966,x=-0.1658,z=0.4107,},[503]={y=0.6873,x=-0.1655,z=0.7072,},[504]={y=0.0706,x=-0.2972,z=-0.9522,},[505]={y=0.6904,x=-0.1297,z=-0.7117,},},v={[1]={y=-0.170428,x=0.332585,w=1,z=4.128081,},[2]={y=-0.101824,x=0.434429,w=1,z=3.481075,},[3]={y=0.519246,x=0.384951,w=1,z=4.496902,},[4]={y=0.431525,x=0.450057,w=1,z=3.563918,},[5]={y=-0.162163,x=0,w=1,z=4.246409,},[6]={y=0.467873,x=0,w=1,z=4.603964,},[7]={y=0.869973,x=0.320116,w=1,z=4.211536,},[8]={y=0.628482,x=0.395715,w=1,z=3.683214,},[9]={y=0.714209,x=0,w=1,z=3.61135,},[10]={y=0.882636,x=0,w=1,z=4.306754,},[11]={y=-0.472452,x=0.161851,w=1,z=3.842455,},[12]={y=-0.42347,x=0.296861,w=1,z=3.567534,},[13]={y=-0.471514,x=0,w=1,z=3.92646,},[14]={y=0.924159,x=0.174236,w=1,z=4.054237,},[15]={y=0.735512,x=0.182394,w=1,z=3.740044,},[16]={y=0.709102,x=0,w=1,z=3.681169,},[17]={y=0.897019,x=0,w=1,z=4.133649,},[18]={y=1.781489,x=0,w=1,z=3.760623,},[19]={y=-0.26774,x=0.395971,w=1,z=3.846896,},[20]={y=0.414825,x=0.48742,w=1,z=4.067656,},[21]={y=0.794104,x=0.439344,w=1,z=3.944617,},[22]={y=-0.52532,x=0.154675,w=1,z=3.626498,},[23]={y=-0.585628,x=0,w=1,z=3.607921,},[24]={y=0.817647,x=0.247283,w=1,z=3.887489,},[25]={y=0.311347,x=0.581727,w=1,z=2.884418,},[26]={y=0.713711,x=0.581201,w=1,z=3.07475,},[27]={y=0.03941,x=0.614372,w=1,z=0.982636,},[28]={y=1.022809,x=0,w=1,z=3.306687,},[29]={y=0.935659,x=0.499087,w=1,z=3.204509,},[30]={y=-0.260067,x=0.171249,w=1,z=2.934016,},[31]={y=-0.099542,x=0.316645,w=1,z=2.915715,},[32]={y=0.581641,x=0.811329,w=1,z=0.945628,},[33]={y=-0.353317,x=0,w=1,z=2.963255,},[34]={y=0.403228,x=0.64869,w=1,z=2.0073,},[35]={y=0.966378,x=0.723785,w=1,z=2.299771,},[36]={y=1.28348,x=0,w=1,z=2.768779,},[37]={y=1.225257,x=0.575175,w=1,z=2.609642,},[38]={y=-0.243192,x=0.258854,w=1,z=2.124786,},[39]={y=-0.080171,x=0.502455,w=1,z=2.112097,},[40]={y=-0.368259,x=0,w=1,z=2.135978,},[41]={y=1.303311,x=0,w=1,z=1.234328,},[42]={y=0.935721,x=0.628315,w=1,z=1.055963,},[43]={y=-0.495309,x=0.251712,w=1,z=1.388331,},[44]={y=-0.295125,x=0.458466,w=1,z=1.240908,},[45]={y=-0.563438,x=0,w=1,z=1.47543,},[46]={y=0.259674,x=0.631531,w=1,z=1.473488,},[47]={y=1.355755,x=0.505812,w=1,z=2.053487,},[48]={y=-0.212643,x=0.439356,w=1,z=1.656475,},[49]={y=-0.4582,x=0,w=1,z=1.743127,},[50]={y=0.880613,x=0.816988,w=1,z=1.700808,},[51]={y=1.515153,x=0,w=1,z=2.234601,},[52]={y=-0.381112,x=0.245558,w=1,z=1.735278,},[53]={y=-0.427575,x=0.630764,w=1,z=0.352582,},[54]={y=0.132995,x=0.781524,w=1,z=0.227805,},[55]={y=0.765103,x=0,w=1,z=0.482221,},[56]={y=0.549418,x=0.651092,w=1,z=0.320021,},[57]={y=-0.793024,x=0.305045,w=1,z=0.634259,},[58]={y=-0.628885,x=0.520392,w=1,z=0.482236,},[59]={y=-0.863744,x=0,w=1,z=0.666313,},[60]={y=-0.527998,x=0.573108,w=1,z=0.011094,},[61]={y=-0.48512,x=0,w=1,z=-0.10158,},[62]={y=-0.139636,x=0.809748,w=1,z=-0.092823,},[63]={y=0.174393,x=0,w=1,z=-0.169362,},[64]={y=0.39895,x=0,w=1,z=-0.071381,},[65]={y=0.283011,x=0.615657,w=1,z=-0.124512,},[66]={y=-0.983351,x=0.240118,w=1,z=0.250332,},[67]={y=-0.725804,x=0.471269,w=1,z=0.047027,},[68]={y=-0.875579,x=0,w=1,z=0.125999,},[69]={y=-1.041753,x=0,w=1,z=0.24911,},[70]={y=-1.215797,x=0.130102,w=1,z=-0.159398,},[71]={y=-1.237455,x=0.12556,w=1,z=-0.244567,},[72]={y=-1.304097,x=0,w=1,z=-0.299584,},[73]={y=-1.290914,x=0,w=1,z=-0.156544,},[74]={y=-0.157506,x=0.619143,w=1,z=-0.217812,},[75]={y=-0.158482,x=0.287867,w=1,z=-0.227887,},[76]={y=0.138477,x=0.313907,w=1,z=-0.287548,},[77]={y=0.062425,x=0.571883,w=1,z=-0.285383,},[78]={y=-0.1109,x=0.54243,w=1,z=-0.275468,},[79]={y=-0.113647,x=0.340443,w=1,z=-0.275468,},[80]={y=0.042183,x=0.378142,w=1,z=-0.284881,},[81]={y=0.011584,x=0.507923,w=1,z=-0.287294,},[82]={y=-0.024765,x=0.505684,w=1,z=-0.536551,},[83]={y=-0.000154,x=0.364078,w=1,z=-0.536551,},[84]={y=0.14938,x=0.321942,w=1,z=-0.401863,},[85]={y=0.087834,x=0.565246,w=1,z=-0.407207,},[86]={y=0.199805,x=0.701219,w=1,z=-0.536551,},[87]={y=0.27701,x=0.257001,w=1,z=-0.536551,},[88]={y=0.371985,x=0.352166,w=1,z=-0.323364,},[89]={y=0.282332,x=0.643974,w=1,z=-0.32978,},[90]={y=-0.055494,x=0.492633,w=1,z=-0.360027,},[91]={y=0.042687,x=0.495127,w=1,z=-0.305737,},[92]={y=0.057559,x=0.377367,w=1,z=-0.300408,},[93]={y=-0.066984,x=0.357378,w=1,z=-0.36246,},[94]={y=0.629189,x=0.696003,w=1,z=-0.536551,},[95]={y=0.666123,x=0.483492,w=1,z=-0.536551,},[96]={y=0.650631,x=0.502231,w=1,z=-0.444808,},[97]={y=0.633373,x=0.659531,w=1,z=-0.446306,},[98]={y=0.166214,x=0.641971,w=1,z=-0.238244,},[99]={y=0.208172,x=0.173985,w=1,z=-0.166099,},[100]={y=-0.155582,x=0.717721,w=1,z=-0.196506,},[101]={y=-0.128662,x=0.20181,w=1,z=-0.119679,},[102]={y=0.730043,x=0.650957,w=1,z=-0.536551,},[103]={y=0.746898,x=0.553978,w=1,z=-0.536551,},[104]={y=0.767797,x=0.589328,w=1,z=-0.536551,},[105]={y=0.759628,x=0.621421,w=1,z=-0.536551,},[106]={y=0.257281,x=0.844044,w=1,z=2.389389,},[107]={y=0.595892,x=0.824304,w=1,z=2.596382,},[108]={y=-0.00277,x=0.630296,w=1,z=2.463479,},[109]={y=0.232577,x=1.007871,w=1,z=1.897777,},[110]={y=0.683017,x=0.957406,w=1,z=2.03788,},[111]={y=-0.132041,x=0.718464,w=1,z=1.906619,},[112]={y=-0.029404,x=0.720204,w=1,z=1.412913,},[113]={y=0.447566,x=0.782932,w=1,z=1.539372,},[114]={y=-0.329388,x=0.636055,w=1,z=1.419585,},[115]={y=-0.110871,x=1.047746,w=1,z=1.261194,},[116]={y=0.235961,x=1.014639,w=1,z=1.376054,},[117]={y=-0.25647,x=0.795863,w=1,z=1.343274,},[118]={y=0.055368,x=0.856056,w=1,z=0.635745,},[119]={y=0.290806,x=0.890243,w=1,z=0.706607,},[120]={y=-0.083616,x=0.778875,w=1,z=0.654029,},[121]={y=0.030475,x=0.95857,w=1,z=0.580571,},[122]={y=0.164973,x=0.957439,w=1,z=0.631754,},[123]={y=-0.054446,x=0.865722,w=1,z=0.610952,},[124]={y=0.251738,x=0.845425,w=1,z=0.211648,},[125]={y=0.309318,x=0.861813,w=1,z=0.349522,},[126]={y=0.171109,x=0.843762,w=1,z=0.290707,},[127]={y=0.194659,x=0.903168,w=1,z=0.295181,},[128]={y=0.258993,x=0.888686,w=1,z=0.319587,},[129]={y=0.161904,x=0.883427,w=1,z=0.318605,},[130]={y=0.640423,x=0.164577,w=1,z=3.64454,},[131]={y=1.014155,x=0.217326,w=1,z=3.268993,},[132]={y=1.266835,x=0.276306,w=1,z=2.693604,},[133]={y=1.177977,x=0.302522,w=1,z=1.105412,},[134]={y=1.44894,x=0.247967,w=1,z=2.153522,},[135]={y=0.65726,x=0.325546,w=1,z=0.401121,},[136]={y=0.34098,x=0.307829,w=1,z=-0.097946,},[137]={y=-0.157994,x=0.453505,w=1,z=-0.22285,},[138]={y=0.100451,x=0.442895,w=1,z=-0.286465,},[139]={y=-0.112274,x=0.441436,w=1,z=-0.275468,},[140]={y=0.026884,x=0.443033,w=1,z=-0.286088,},[141]={y=-0.012459,x=0.434881,w=1,z=-0.536551,},[142]={y=0.118607,x=0.443594,w=1,z=-0.404535,},[143]={y=0.238408,x=0.47911,w=1,z=-0.536551,},[144]={y=0.327159,x=0.49807,w=1,z=-0.326572,},[145]={y=-0.061239,x=0.425006,w=1,z=-0.361243,},[146]={y=0.050123,x=0.436247,w=1,z=-0.303072,},[147]={y=0.647656,x=0.589747,w=1,z=-0.536551,},[148]={y=0.642002,x=0.580881,w=1,z=-0.445557,},[149]={y=-0.142122,x=0.459765,w=1,z=-0.158093,},[150]={y=0.187193,x=0.407978,w=1,z=-0.202172,},[151]={y=0.73847,x=0.602468,w=1,z=-0.536551,},[152]={y=0.763713,x=0.605374,w=1,z=-0.536551,},[153]={y=0.880973,x=0.22769,w=1,z=3.951998,},[154]={y=-0.170428,x=-0.332585,w=1,z=4.128081,},[155]={y=-0.101824,x=-0.434429,w=1,z=3.481075,},[156]={y=0.519246,x=-0.384951,w=1,z=4.496902,},[157]={y=0.431525,x=-0.450057,w=1,z=3.563918,},[158]={y=0.869973,x=-0.320116,w=1,z=4.211536,},[159]={y=0.628482,x=-0.395715,w=1,z=3.683214,},[160]={y=-0.472452,x=-0.161851,w=1,z=3.842455,},[161]={y=-0.42347,x=-0.296861,w=1,z=3.567534,},[162]={y=0.924159,x=-0.174236,w=1,z=4.054237,},[163]={y=0.735512,x=-0.182394,w=1,z=3.740044,},[164]={y=-0.26774,x=-0.395971,w=1,z=3.846896,},[165]={y=0.414825,x=-0.48742,w=1,z=4.067656,},[166]={y=0.794104,x=-0.439344,w=1,z=3.944617,},[167]={y=-0.52532,x=-0.154675,w=1,z=3.626498,},[168]={y=0.817647,x=-0.247283,w=1,z=3.887489,},[169]={y=0.311347,x=-0.581727,w=1,z=2.884418,},[170]={y=0.713711,x=-0.581201,w=1,z=3.07475,},[171]={y=0.03941,x=-0.614372,w=1,z=0.982636,},[172]={y=0.935659,x=-0.499087,w=1,z=3.204509,},[173]={y=-0.260067,x=-0.171249,w=1,z=2.934016,},[174]={y=-0.099542,x=-0.316645,w=1,z=2.915715,},[175]={y=0.581641,x=-0.811329,w=1,z=0.945628,},[176]={y=0.403228,x=-0.64869,w=1,z=2.0073,},[177]={y=0.966378,x=-0.723785,w=1,z=2.299771,},[178]={y=1.225257,x=-0.575175,w=1,z=2.609642,},[179]={y=-0.243192,x=-0.258854,w=1,z=2.124786,},[180]={y=-0.080171,x=-0.502455,w=1,z=2.112097,},[181]={y=0.935721,x=-0.628315,w=1,z=1.055963,},[182]={y=-0.495309,x=-0.251712,w=1,z=1.388331,},[183]={y=-0.295125,x=-0.458466,w=1,z=1.240908,},[184]={y=0.259674,x=-0.631531,w=1,z=1.473488,},[185]={y=1.355755,x=-0.505812,w=1,z=2.053487,},[186]={y=-0.212643,x=-0.439356,w=1,z=1.656475,},[187]={y=0.880613,x=-0.816988,w=1,z=1.700808,},[188]={y=-0.381112,x=-0.245558,w=1,z=1.735278,},[189]={y=-0.427575,x=-0.630764,w=1,z=0.352582,},[190]={y=0.132995,x=-0.781524,w=1,z=0.227805,},[191]={y=0.549418,x=-0.651092,w=1,z=0.320021,},[192]={y=-0.793024,x=-0.305045,w=1,z=0.634259,},[193]={y=-0.628885,x=-0.520392,w=1,z=0.482236,},[194]={y=-0.527998,x=-0.573108,w=1,z=0.011094,},[195]={y=-0.139636,x=-0.809748,w=1,z=-0.092823,},[196]={y=0.283011,x=-0.615657,w=1,z=-0.124512,},[197]={y=-0.983351,x=-0.240118,w=1,z=0.250332,},[198]={y=-0.725804,x=-0.471269,w=1,z=0.047027,},[199]={y=-1.215797,x=-0.130102,w=1,z=-0.159398,},[200]={y=-1.237455,x=-0.12556,w=1,z=-0.244567,},[201]={y=-0.157506,x=-0.619143,w=1,z=-0.217812,},[202]={y=-0.158482,x=-0.287867,w=1,z=-0.227887,},[203]={y=0.138477,x=-0.313907,w=1,z=-0.287548,},[204]={y=0.062425,x=-0.571883,w=1,z=-0.285383,},[205]={y=-0.1109,x=-0.54243,w=1,z=-0.275468,},[206]={y=-0.113647,x=-0.340443,w=1,z=-0.275468,},[207]={y=0.042183,x=-0.378142,w=1,z=-0.284881,},[208]={y=0.011584,x=-0.507923,w=1,z=-0.287294,},[209]={y=-0.024765,x=-0.505684,w=1,z=-0.536551,},[210]={y=-0.000154,x=-0.364078,w=1,z=-0.536551,},[211]={y=0.14938,x=-0.321942,w=1,z=-0.401863,},[212]={y=0.087834,x=-0.565246,w=1,z=-0.407207,},[213]={y=0.199805,x=-0.701219,w=1,z=-0.536551,},[214]={y=0.27701,x=-0.257001,w=1,z=-0.536551,},[215]={y=0.371985,x=-0.352166,w=1,z=-0.323364,},[216]={y=0.282332,x=-0.643974,w=1,z=-0.32978,},[217]={y=-0.055494,x=-0.492633,w=1,z=-0.360027,},[218]={y=0.042687,x=-0.495127,w=1,z=-0.305737,},[219]={y=0.057559,x=-0.377367,w=1,z=-0.300408,},[220]={y=-0.066984,x=-0.357378,w=1,z=-0.36246,},[221]={y=0.629189,x=-0.696003,w=1,z=-0.536551,},[222]={y=0.666123,x=-0.483492,w=1,z=-0.536551,},[223]={y=0.650631,x=-0.502231,w=1,z=-0.444808,},[224]={y=0.633373,x=-0.659531,w=1,z=-0.446306,},[225]={y=0.166214,x=-0.641971,w=1,z=-0.238244,},[226]={y=0.208172,x=-0.173985,w=1,z=-0.166099,},[227]={y=-0.155582,x=-0.717721,w=1,z=-0.196506,},[228]={y=-0.128662,x=-0.20181,w=1,z=-0.119679,},[229]={y=0.730043,x=-0.650957,w=1,z=-0.536551,},[230]={y=0.746898,x=-0.553978,w=1,z=-0.536551,},[231]={y=0.767797,x=-0.589328,w=1,z=-0.536551,},[232]={y=0.759628,x=-0.621421,w=1,z=-0.536551,},[233]={y=0.257281,x=-0.844044,w=1,z=2.389389,},[234]={y=0.595892,x=-0.824304,w=1,z=2.596382,},[235]={y=-0.00277,x=-0.630296,w=1,z=2.463479,},[236]={y=0.232577,x=-1.007871,w=1,z=1.897777,},[237]={y=0.683017,x=-0.957406,w=1,z=2.03788,},[238]={y=-0.132041,x=-0.718464,w=1,z=1.906619,},[239]={y=-0.029404,x=-0.720204,w=1,z=1.412913,},[240]={y=0.447566,x=-0.782932,w=1,z=1.539372,},[241]={y=-0.329388,x=-0.636055,w=1,z=1.419585,},[242]={y=-0.110871,x=-1.047746,w=1,z=1.261194,},[243]={y=0.235961,x=-1.014639,w=1,z=1.376054,},[244]={y=-0.25647,x=-0.795863,w=1,z=1.343274,},[245]={y=0.055368,x=-0.856056,w=1,z=0.635745,},[246]={y=0.290806,x=-0.890243,w=1,z=0.706607,},[247]={y=-0.083616,x=-0.778875,w=1,z=0.654029,},[248]={y=0.030475,x=-0.95857,w=1,z=0.580571,},[249]={y=0.164973,x=-0.957439,w=1,z=0.631754,},[250]={y=-0.054446,x=-0.865722,w=1,z=0.610952,},[251]={y=0.251738,x=-0.845425,w=1,z=0.211648,},[252]={y=0.309318,x=-0.861813,w=1,z=0.349522,},[253]={y=0.171109,x=-0.843762,w=1,z=0.290707,},[254]={y=0.194659,x=-0.903168,w=1,z=0.295181,},[255]={y=0.258993,x=-0.888686,w=1,z=0.319587,},[256]={y=0.161904,x=-0.883427,w=1,z=0.318605,},[257]={y=0.640423,x=-0.164577,w=1,z=3.64454,},[258]={y=1.014155,x=-0.217326,w=1,z=3.268993,},[259]={y=1.266835,x=-0.276306,w=1,z=2.693604,},[260]={y=1.177977,x=-0.302522,w=1,z=1.105412,},[261]={y=1.44894,x=-0.247967,w=1,z=2.153522,},[262]={y=0.65726,x=-0.325546,w=1,z=0.401121,},[263]={y=0.34098,x=-0.307829,w=1,z=-0.097946,},[264]={y=-0.157994,x=-0.453505,w=1,z=-0.22285,},[265]={y=0.100451,x=-0.442895,w=1,z=-0.286465,},[266]={y=-0.112274,x=-0.441436,w=1,z=-0.275468,},[267]={y=0.026884,x=-0.443033,w=1,z=-0.286088,},[268]={y=-0.012459,x=-0.434881,w=1,z=-0.536551,},[269]={y=0.118607,x=-0.443594,w=1,z=-0.404535,},[270]={y=0.238408,x=-0.47911,w=1,z=-0.536551,},[271]={y=0.327159,x=-0.49807,w=1,z=-0.326572,},[272]={y=-0.061239,x=-0.425006,w=1,z=-0.361243,},[273]={y=0.050123,x=-0.436247,w=1,z=-0.303072,},[274]={y=0.647656,x=-0.589747,w=1,z=-0.536551,},[275]={y=0.642002,x=-0.580881,w=1,z=-0.445557,},[276]={y=-0.142122,x=-0.459765,w=1,z=-0.158093,},[277]={y=0.187193,x=-0.407978,w=1,z=-0.202172,},[278]={y=0.73847,x=-0.602468,w=1,z=-0.536551,},[279]={y=0.763713,x=-0.605374,w=1,z=-0.536551,},[280]={y=0.880973,x=-0.22769,w=1,z=3.951998,},},}

local function funDraw(draw, x, y, z, scale, name, dialog, rotation, color)
  local px, py, pz = player.position()

  if not pz then return end
  
  local zdiff = pz - z
  if zdiff > 5 or zdiff < -5 then return end

  local key = name .. (tostring(dialog))

  local dist = distance(x, y, z, px, py, pz)
  if dist > 12 then
    started[key] = false
    finished[key] = false
    index[key] = 1
    lastPlayerLay = 0
    return 
  end

  if not index[key] then
    index[key] = 1
  end
  if not rotated[name] then
    if not rotation then
      rotation = {0, 0, 0}
    else
      rotated[name] = true
    end
    draw:RotateObject(pengu, rotation[1], rotation[2], rotation[3])
  end

   -- scale the alpha from 0-1 as we get closer
   local a = 1 - ((dist - 3) / 10)
   if a > 1 then a = 1 end
   if a < 0 then a = 0 end

   local r, g, b
   if color then
    r, g, b = unpack(color)
   else
    r, g, b = 255, 180, 180
   end

   draw:SetColor(r, g, b, a * 235)
   -- draw:LaplacianSmoothing(pengu, 1)
   draw:Object(pengu, x, y, z, scale or 0.6, true)
   draw:SetColor(r, g, b, a * 255)

   if dist < 6 then
    if not started[key] then 
      started[key] = GetTime()
    elseif index[key] ~= 1 or GetTime() - started[key] > 1 then
      local elapsed = GetTime() - started[key]
      if dialog[index[key] + 1] and elapsed > dialog[index[key]].duration then
        index[key] = index[key] + 1
        started[key] = GetTime()
      elseif not dialog[index[key] + 1] then
        if elapsed > dialog[index[key]].duration then
          finished[key] = true
        end
      end
      if not finished[key] then
        draw:Text(dialog[index[key]].text, blinkFont, x, y, z + 3.5)
        if lastMessageIndex ~= index[key] then
          penguMessage(name, dialog[index[key]].text)
          lastMessageIndex = index[key]
        end
      end
    end
  end

end

-- penguin (step1)
do

  local dialog = {
    {
      text = "If you truly want this sublime feathery behind,",
      duration = 4
    },
    {
      text = "The least you can do is find my lost brother. C'mon, be kind.",
      duration = 5
    },
    {
      text = "Last time I saw him, his lore was untold.",
      duration = 3
    },
    {
      text = "About a race of creatures, I think the Furbolg?",
      duration = 5
    },
    {
      text = "Somewhere cold, somewhere green, somewhere old, somewhere unseen.",
      duration = 4
    },
    {
      text = "He's in a house, but not with a bed.",
      duration = 3
    },
    {
      text = "Not in the open, but in something dead.",
      duration = 3
    },
    {
      text = "Round and round, in a hole that is deep.",
      duration = 3
    },
    {
      text = "It's not a castle, a building, or even a keep.",
      duration = 3
    },
    {
      text = "It's something ancient, but long ago fell.",
      duration = 3
    },
    {
      text = "Good luck, cute stuff. Go out, give them hell.",
      duration = 3
    },
    {
      text = "A bear mound, above a shouting ravine.",
      duration = 3
    },
    {
      text = "Find my lost brother, and balls deep you'll be.",
      duration = 3
    }
  }

  local initialDialog = {
    {
      text = "Oh hey cutie, come lay down and play!",
      duration = 4
    },
    {
      text = "You could stroke my beak, c'mon please stay.",
      duration = 5
    },
  }

  local whisperedIndex = false

  local started = false
  local finished = false
  
  local index = 1
  local lastMessageIndex = false
  blink.Draw(function(draw)
    if blink.mapID ~= 0 then return end
    if blink.zone ~= "Lion's Pride Inn" then return end

    local tx, ty, tz = -9460.46949, -4.92618, 65.02042

    if GetTime() - lastPlayerLay > 200 then
      funDraw(draw, tx, ty, tz, 0.6, "Bradley", initialDialog)
    else
      funDraw(draw, tx, ty, tz, 0.6, "Bradley", dialog, {1.5, 0.2, 0})
    end
  
  end)
end

-- penguin2:
do

  local initialDialog = {
    {
      text = "Yo ..hic!",
      duration = 4
    },
    {
      text = "I'm not really one for this sober small talk..",
      duration = 6
    },
    {
      text = "..Hic! Grab me something to roll this blunt with homie.",
      duration = 5
    },
    {
      text = "My neighbors probably have something.",
      duration = 5
    }
  }

  local dialog = {
    {
        text = "...Hic! Thanks homie, Grizzly OG is some strong ass shit.",
        duration = 4
    },
    {
        text = "Lemme get my two puffs then you take a hit.",
        duration = 5
    },
    {
        text = "Anyway, you found me ..hic! Well done, my friend.",
        duration = 5
    },
    {
        text = "But alas! The adventure is not at its end...",
        duration = 5
    },
    {
        text = "Our cousin is missing. He's at death's door.",
        duration = 5
    },
    {
        text = "He's been in a warzone, blood, sweat, tears and more.",
        duration = 4
    },
    {
        text = "You gotta find him ..hic! He's hiding in fear.",
        duration = 4
    },
    {
        text = "But I must warn you, adventurer. He is not ..hic! near...",
        duration = 5
    },
    {
        text = "There is a battle, of purple and red.",
        duration = 4
    },
    {
        text = "Just when the sun is setting, but before it is dead.",
        duration = 5
    },
    {
        text = "A valuable gem, a gleaming tint of flame.",
        duration = 4
    },
    {
        text = "Two worlds collide, neither to blame.",
        duration = 4
    },
    {
        text = "There lies a tree, shielding new life's gifts.",
        duration = 4
    },
    {
        text = "Guarded by 4 mountains of brutal strength and wing lift.",
        duration = 5
    },
    {
        text = "A fellow who can help travel across the land.",
        duration = 4
    },
    {
        text = "There will be our cousin, hiding in high stand.",
        duration = 4
    },
  }

  blink.Draw(function(draw)
    if blink.mapID ~= 571 then return end
    if blink.zone ~= "Grizzlemaw" then return end

    local x, y, z = player.position()
    -- local tx, ty, tz = -9464.993, -30.4027, 58.18952
    local tx, ty, tz = 4005.8566, -3709.05388, 178.716242

    -- 33470, 43852
    if GetItemCount(33470) + GetItemCount(43852) > 0 then
      funDraw(draw, tx, ty, tz, 0.5, "Snooger", dialog, {0, 0, 2.5}, {24, 200, 24})
    else
      funDraw(draw, tx, ty, tz, 0.5, "Snooger", initialDialog, {0, 0, 2.5}, {24, 200, 24})
    end
    
  end)
end

-- penguin3
do
  local dialog = {
    {
      text = "Oh, hello there. I'm so glad you found me!",
      duration = 4
    },
    {
      text = "I've been hiding here, way up in this tree.",
      duration = 4
    },
    {
      text = "I've been so scared, not knowing what to do.",
      duration = 5
    },
    {
      text = "Oh, I'm sorry, I haven't introduced myself to you.",
      duration = 5
    },
    {
      text = "I'm Goobert the Grape, third of the penguin clan.",
      duration = 5
    },
    {
      text = "I'm so glad you found me, I'm your biggest fan.",
      duration = 3
    },
    {
      text = "Since you've come to help, I'll tell you what I know.",
      duration = 5
    },
    {
      text = "Legend has it, a selfie with me is worth a lot of blink dough!",
      duration = 5
    }
  }

  blink.Draw(function(draw)
    if blink.mapID ~= 0 then return end
    if blink.zone ~= "Vermillion Redoubt" then return end

    local x, y, z = player.position()
    -- local tx, ty, tz = -9464.993, -30.4027, 58.18952
    local tx, ty, tz = -3012.0962, -3953.43652, 354.09

    -- 33470, 43852
    funDraw(draw, tx, ty, tz, 0.3, "Goobert", dialog, {0, 0, 0.5}, {144, 100, 200})
    
  end)
end

-- do
--   local x,y,z = -3036.2702, -3915.1826, 281.831085

--   local farts = loader:Load('mccree.obj', 'mccree.mtl')
--   local smoothed
--   blink.Draw(function(draw)
--     -- if not smoothed then
--     --   draw:LaplacianSmoothing(farts, 1)
--     --   smoothed = true
--     -- end
--     -- draw:WavefrontObject(farts, x, y, z, 2.5)
--   end)
-- end