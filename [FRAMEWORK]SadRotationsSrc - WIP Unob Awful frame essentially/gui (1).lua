local Unlocker, blink, sr = ...
local hunter, bm, sv = sr.hunter, sr.hunter.bm, sr.hunter.sv
local player = blink.player
local colors = blink.colors
local onEvent, onUpdate = blink.addEventCallback, blink.addUpdateCallback

if player.class2 ~= "HUNTER" 
and player.class2 ~= "DRUID" 
and player.class2 ~= "PRIEST" 
and player.class2 ~= "ROGUE" 
and player.class2 ~= "WARRIOR" 
and player.class2 ~= "SHAMAN" 
and player.class2 ~= "PALADIN" then
  sr.cmd, sr.ui, sr.saved = {}, {}, {}
  return
end

local currentSpec = GetSpecialization()

local blue = {0,232,255}
local white = {255, 255, 255, 1}
local black = {6, 4, 4, 0.8}
local ui, saved, cmd = blink.UI:New("sr", {
  title = {'Sad', 'Rotations'},
  tabs_w = 140,
  show = false,
  width = 500,
  height = 400,
  --sidebar = false,
  scale = 1,
  colors = {
    title = {blue, white},
    primary = white,
    accent = blue,
    background = black,
  },
})

local CopyToClipboard = blink.unlock("CopyToClipboard")

--if saved.NoMoreAutoShow then
	--ui.frame:Hide()
	if not saved.streamingMode then
		blink.alert({msg="SadRotations |cFFf7f25cLoaded!", duration=5})
		blink.alert({msg="Type |cff00ccff/sr|r to open the GUI.", duration=5})
	end
--end

sr.cmd, sr.ui, sr.saved = cmd, ui, saved

local existing_alert
cmd:New(function(msg)
  if msg == "toggle" 
  or msg == "on"
  or msg == "off"
  or msg == "start" then
    blink.enabled = not blink.enabled
    print(blink.enabled and "|cFFf7f25c[SadRotations]:|cFF22f248 Enabled" or "|cFFf7f25c[SadRotations]:|cFFf74a4a Disabled")
    local txt = "|cFFf7f25c[SadRotations]: " .. (blink.enabled and "|cFF22f248Enabled" or "|cFFf74a4aDisabled")
		if not existing_alert or existing_alert == true or existing_alert:GetAlpha() <= 0 then
			existing_alert = blink.alert(txt)
		else
			existing_alert.alpha = 1
			existing_alert:SetAlpha(1)
			existing_alert.fontString:SetText(txt)
			existing_alert.endTime = GetTime() + 0.7
		end
    return true
  end
end)

-- sr.saved = saved 

-- sr.cmd = cmd
-- local toggleAlert
-- cmd:New(function(msg)
--   if msg == "toggle" then
--     blink.enabled = not blink.enabled
--     local text = "|cFFf7f25c[SadRotations]: " .. (blink.enabled and "|cFF22f248Enabled" or "|cFFf74a4aDisabled")
--     if not toggleAlert or toggleAlert:GetAlpha() <= 0 then
--       toggleAlert = blink.alert(text), print(text)
--     else
--       -- set alpha back to 1
--       toggleAlert.alpha = 1
--       toggleAlert:SetAlpha(1)
--       -- change the text
--       toggleAlert.fontString:SetText(text)
--       -- extend end time of the fade out animation
--       toggleAlert.endTime = GetTime() + 0.7
--     end
--     return true
--   end
-- end)
-- local KeyBinds = ui:Tab("KeyBinds")
-- KeyBinds:Text({text ="KeyBinds Settings:", header = true})



local General = ui:Tab("General")
General:Text({text ="General Settings:", header = true, paddingBottom = 10,})
General:Dropdown({
  var = "rotationMode",
  default = "dmgAndUtil",
  paddingTop = 20,
  paddingBottom = 10,
  tooltip = "Choose Rotation Mode",
  options = {
    { label = "Rotation and utilities", value = "dmgAndUtil", tooltip = "Routine will do rotation and utilities." },
    { label = blink.colors.orange .. "(Beta) PVE Rotation Mode", value = "pveMode", tooltip = blink.colors.orange .. "(Beta) Routine will do PVE rotation." },
    { label = blink.colors.pink .. "(Beta) PVE Hekili Mode", value = "hekiliMode", tooltip = blink.colors.pink .. "(Beta) Routine will do PVE Hekili rotation. you must download and load Hekili Addon.\n\nYou can do your Hekili settings" },
    { label = "Utilities only", value = "utilOnly", tooltip = "Routine will do utilities only like Interrupts,Stomp Totems,Defensives etc." },
  },
  placeholder = "Select Mode",
  header = "Choose Rotation Mode:",
  size = 20,
})
General:Slider({
  text = "Routine Reaction Delay",
  var = "reactionDelay",
  step = 0.1,
  min = 0.1,
  max = 1,
  default = 0.5,
  valueType = "s",
  tooltip = "Routine Reaction Delay:\n\nLower number = Routine will react faster.\n\nHigher number = Routine will react slower.",
})

General:Checkbox({
  text = "Auto Accept Queues                   ",
  paddingTop = 10,
  paddingBottom = 10,
  var = "AutoAcceptQue",
  default = false,
  tooltip = "Enabling this will auto accept queues.\n\nIt will NOT Accept the Queue if you are flagged as AFK or routine is Disabled.",
})
General:Checkbox({
  text = "Alert When Queue Popup               ",
  paddingTop = 10,
  paddingBottom = 10,
  var = "AlertPopupQueue",
  default = true,
  tooltip = "Enabling this will alert when Queues popup.",
})


General:Dropdown({
  var = "autofousunit",
  default = "smartfocus",
  paddingTop = 20,
  paddingBottom = 10,
  tooltip = "Set Auto Focus unit",
  options = {
    { label = "Smart", value = "smartfocus", tooltip = "Routine will Auto Focus your off target or enemy healer automaticlly." },
    { label = "Healer", value = "enemyHealerfocus", tooltip = "Routine will only Auto Focus Enemy Healer." },
    { label = "Offtarget", value = "offtargetfocus", tooltip = "Routine will only Auto Focus off target DPS." },
    { label = "OFF", value = "turnautofocusoff", tooltip = "Turn OFF Auto Focus." },
  },
  placeholder = "Select Unit",
  header = "Set Auto Focus unit:",
  size = 20,
})
General:Text({text ="Drawing Settings:", header = true})
General:Checkbox({
  text = "PvP Drawings         ",
  size = 14,
  var = "DrawTriggers", 
  default = true,
  tooltip = "Draw enemy/friendly important spells",
})
General:Checkbox({
  text = "Auto Attack Range Drawing",
  size = 14,
  var = "aaDraw",
  default = false,
  tooltip = "Draw an arc indicating effective auto attack range.\n\nThis is useful for maximizing uptime, and will only appear when you have an enemy target.",
})
General:Checkbox({
  text = "Draw a line to Friendly Healer          ",
  size = 14,
  var = "DrawLineToFHealer", 
  default = true,
  tooltip = "Draw a line to your Friendly Healer        ",
})
General:Checkbox({
  text = "Enable Streaming Mode        ",
  size = 14,
  var = "streamingMode",
  default = false,
  tooltip = "Enable or Disable Streaming Mode.\n\nEnabling this will hide all routine Drawings/Alerts.",
})
General:Checkbox({
  text = "Disable All Alerts         ",
  size = 14,
  var = "DisableAllAlert",
  default = false,
  tooltip = "Enable or Disable All Alerts.\n\nEnabling this will hide all SadRotatons alerts including (/cast macros).",
})
General:Checkbox({
  text = "Disable Cast Alerts Only         ",
  size = 14,
  var = "DisableCastAlert",
  default = false,
  tooltip = "Enable or Disable Cast Alerts only.\n\nEnabling this will hide only SadRotatons Cast Alerts (/cast macros).",
})
-- General:Checkbox({
--   text = "Draw enemy names",
--   size = 14,
--   var = "EnemyNameDraw", 
--   default = false,
--   tooltip = "Draw enemy names (might drop fps)",
-- })
General:Text({text ="Miscs:", header = true})
General:Checkbox({
  text = "Enable Auto Eat Enemy Hunter Traps             ",
  var = "eatHunterTraps",
  default = true,
  tooltip = "To enable or disable the routine from auto moving to eat enemy hunter traps if near you.",
})
General:Checkbox({
  text = "Enable Anti AFK             ",
  var = "AntiAFK",
  default = false,
})
General:Checkbox({
  text = "Enable Auto Flag Pickup            ",
  var = "pickUpFlag",
  default = true,
  tooltip = "Enable/Disable Auto Flag Pickup in Battle Grounds.",
})
General:Checkbox({
  text = "Enable Auto Target            ",
  var = "autoTargeting",
  default = false,
  tooltip = "This is Beta more testing feedbacks is needed.",
})
General:Checkbox({
  text = "Enable Debug Mode            ",
  var = "DebugMode",
  default = false,
  tooltip = "Don't enable this its made for debug purpose.",
})
if currentSpec == 1 and player.class2 == "HUNTER" then
  General:Checkbox({
    text = "Disable Cobra Shot            ",
    var = "DisableCobra",
    default = false,
    tooltip = "Don't enable this its made for debug purpose.",
  })
end
-- General:Checkbox({
--   text = "Enable Auto Focus",
--   size = 14,
--   paddingBottom = 10,
--   var = "AutoFocus", -- checked bool = saved.test
--   default = true,
--   tooltip = "When enabled Routine will Auto Focus your off target or enemy healer automaticlly.",
-- })


--! KICKING MULTI-DROPDOWN !--

local Kicking = ui:Tab("Kick Settings")
Kicking:Text({text ="Kick Settings:", paddingBottom = 10, header = true})
Kicking:Checkbox({
  text = "Enable Auto Kicks              ",
  --size = 14,
  paddingBottom = 10,
  var = "smartkick",
  default = true,
  tooltip = "To enable or disable the routine from using auto kicks     ",
})
-- Kicking:Checkbox({
--   text = "Auto Face Enemy To Kick               ",
--   --size = 14,
--   paddingBottom = 10,
--   var = "autoFaceToKick",
--   default = false,
--   tooltip = "To enable or disable the routine from auto face unit to kick.     ",
-- })
Kicking:Checkbox({
  text = "Kick Fast Mass Dispel              ",
  var = "KickFastMD",
  paddingBottom = 10,
  default = false,
  tooltip = "Kick Fast Mass Dispel (Improved Mass Dispel) - (ppl will report you alot using this)    ",
})
Kicking:Checkbox({
  text = "Kick Warlock Tyrant           ",
  var = "KickTyrant",
  paddingBottom = 10,
  default = true,
  tooltip = "Kick Demo Warlock Tyrant pet     ",
})
Kicking:Checkbox({
  text = "Enable PVE Kicks         ",
  paddingBottom = 10,
  --paddingRight = 10,
  var = "KickPVE",
  default = true,
  tooltip = "Kick enemies in PVE     ",
})
Kicking:Checkbox({
  text = "Don't Kick CC if Team Healer (Priest) can (SWD)       ",
  paddingBottom = 10,
  var = "DontKickAvoidableCC",
  default = false,
  tooltip = "Don't Kick enemy if your Team Healer Priest can SWD it     ",
})
Kicking:Checkbox({
  text = "Don't Kick Triple DR CC          ",
  --size = 14,
  paddingBottom = 10,
  var = "TripleDR",
  default = true,
  tooltip = "Enable this if you don't want to Interrupt Triple DR CC's    ",
})

-- Kicking:Checkbox({
--   text = "Don't Kick CC if Team Healer (Priest) can (Fade)",
--   var = "DontKickAvoidableCCFade",
--   default = false,
--   tooltip = "Don't Kick enemy if your Team Healer Priest can Fade it",
-- })
Kicking:Checkbox({
  text = "Enable Hybrids Healing Kicks       ",
  --size = 14,
  paddingBottom = 20,
  var = "HybridsKick", -- checked bool = saved.test
  default = false,
  tooltip = "To enable or disable the routine from Kicking Hybrids Class Healings, Like : Ret/feral/SP heals etc",
})
Kicking:Slider({
  text = "Kick Heals under Health percentage",
  size = 14,
  paddingBottom = 10,
  var = "kickhealsunder",
  min = 0,
  max = 100,
  default = 80,
  valueType = "%",
  tooltip = "Set the Enemy Health percentage to Kick Heals."
})
-- we have a problem here to check what spec is the target and what school we should kick to make the kick more effective 
Kicking:Slider({
  text = "Kick DPS under Health percentage",
  size = 14,
  paddingBottom = 10,
  var = "kickdpsunder",
  min = 0,
  max = 100,
  default = 20,
  valueType = "%",
  tooltip = "Set the Enemy DPS Health percentage to Kick DPS."
})
-- Kicking:Slider({
--   --paddingTop = 55,
--   text = "Kick Delay",
--   var = "CastKickDelay",
--   -- min = 0.100,
--   -- max = 0.990,
--   -- step = 0.05,
--   -- default = 0.7,
--   min = 0.5,
--   max = 2,
--   step = 0.1,
--   default = 0.7,
--   valueType = "s",
--   tooltip = "Delay interrupts from the routine (in milliseconds)\n\nAverage human reaction time is ~0.5ms."
-- })
-- Kicking:Slider({
--   --paddingTop = 55,
--   text = "Channel Kick Delay",
--   var = "ChannelKickDelay",
--   min = 0.5,
--   max = 2,
--   step = 0.1,
--   default = 0.7,
--   valueType = "s",
--   tooltip = "Delay Channel interrupts from the routine (in seconds)\n\nAverage human reaction time is ~0.5ms."
-- })
-- Kicking:Slider({
--   --paddingTop = 55,
--   text = "Channel Kick Delay",
--   var = "channelkickingDelay",
--   min = 0.1,
--   max = 0.9,
--   step = 0.1,
--   default = 0.3,
--   valueType = "ms",
--   tooltip = "Delay interrupts from the routine (in milliseconds)\n\nAverage human reaction time is ~0.3ms."
-- })

Kicking:Text({text ="Interrupt Configurations:", header = true})
Kicking:Text({text = blink.colors.cyan .."*Interrupts delay auto randomized"})
Kicking:Dropdown({
  var = "kickHealinglist",
  multi = true,
  tooltip = "Choose Healing spells you want to kick.",
  options = {
    { label = blink.textureEscape(421453, 16, "0:0") .. " Ultimate Penitence", value = "Ultimate Penitence", tvalue = {421453} },
    { label = blink.textureEscape(2061, 16, "0:0") .. " Flash Heal", value = "Flash Heal", tvalue = {2061} },
    { label = blink.textureEscape(2060, 16, "0:0") .. " Heal", value = "Heal", tvalue = {2060} },
    { label = blink.textureEscape(32546, 16, "0:0") .. " Binding Heal", value = "Binding Heal", tvalue = {32546} },
    { label = blink.textureEscape(64843, 16, "0:0") .. " Divine Hymn", value = "Divine Hymn", tvalue = {64843} },
    { label = blink.textureEscape(64901, 16, "0:0") .. " Symbol of Hope", value = "Symbol of Hope", tvalue = {64901} },
    { label = blink.textureEscape(596, 16, "0:0") .. " Prayer of Healing", value = "Prayer of Healing", tvalue = {596} },
    { label = blink.textureEscape(120517, 16, "0:0") .. " Halo", value = "Halo", tvalue = {120517} },
    { label = blink.textureEscape(289666, 16, "0:0") .. " Greater Heal", value = "Greater Heal", tvalue = {289666} },
    { label = blink.textureEscape(47540, 16, "0:0") .. " Penance", value = "Penance", tvalue = {47757,47540,47758} },
    { label = blink.textureEscape(194509, 16, "0:0") .. " Power Word: Radiance", value = "Power Word: Radiance", tvalue = {194509} },
    { label = blink.textureEscape(32375, 16, "0:0") .. " Mass Dispel", value = "Mass Dispel", tvalue = {32375} },
    { label = blink.textureEscape(32375, 16, "0:0") .. " Improved Mass Dispel", value = "Improved Mass Dispel", tvalue = {341167} },
    { label = blink.textureEscape(82326, 16, "0:0") .. " Holy Light", value = "Holy Light", tvalue = {82326} },
    { label = blink.textureEscape(19750, 16, "0:0") .. " Flash of Light", value = "Flash of Light", tvalue = {19750} },
    { label = blink.textureEscape(200652, 16, "0:0") .. " Tyr's Deliverance", value = "Tyr's Deliverance", tvalue = {200652, 200654} },
    { label = blink.textureEscape(8936, 16, "0:0") .. " Regrowth", value = "Regrowth", tvalue = {8936,48438} },
    { label = blink.textureEscape(48438, 16, "0:0") .. " Wild Growth", value = "Wild Growth", tvalue = {48438} },
    { label = blink.textureEscape(289022, 16, "0:0") .. " Nourish", value = "Nourish", tvalue = {50464} },
    { label = blink.textureEscape(8004, 16, "0:0") .. " Healing Surge", value = "Healing Surge", tvalue = {8004} },
    { label = blink.textureEscape(77472, 16, "0:0") .. " Healing Wave", value = "Healing Wave", tvalue = {77472} },
    { label = blink.textureEscape(1064, 16, "0:0") .. " Chain Heal", value = "Chain Heal", tvalue = {1064} },
    { label = blink.textureEscape(115175, 16, "0:0") .. " Soothing Mist", value = "Soothing Mist", tvalue = {115175,209525} },
    { label = blink.textureEscape(116670, 16, "0:0") .. " Vivify", value = "Vivify", tvalue = {116670} },
    { label = blink.textureEscape(399491, 16, "0:0") .. " Sheilun's Gift", value = "Sheilun's Gift", tvalue = {399491} },
    { label = blink.textureEscape(191837, 16, "0:0") .. " Essence Font", value = "Essence Font", tvalue = {191837} },
    { label = blink.textureEscape(355936, 16, "0:0") .. " Dream Breath", value = "Dream Breath", tvalue = {355936} }, --EVOKER
    { label = blink.textureEscape(367226, 16, "0:0") .. " Spiritbloom", value = "Spiritbloom", tvalue = {367226} }, --EVOKER
    { label = blink.textureEscape(382266, 16, "0:0") .. " Fire Breath", value = "Fire Breath", tvalue = {382266} }, --EVOKER
    { label = blink.textureEscape(361469, 16, "0:0") .. " Living Flame", value = "Living Flame", tvalue = {361469} }, --EVOKER    
  },
  placeholder = "Select spells",
  header = "Select Healing spells you want to kick.",
  --default = {"Flash Heal", "Heal", 289666, 47540, "Divine Hymn", "Holy Light", "Mass Dispel", "Improved Mass Dispel", "Flash of Light", 77472, 124682, 115175, 355936, 367226, 382266, 194509} -- optional default selections
  default = {
    "Ultimate Penitence",
    "Penance", 
    "Improved Mass Dispel",
    "Mass Dispel",
    "Regrowth", 
    "Flash Heal", 
    "Greater Heal", 
    "Holy Light", 
    "Tyr's Deliverance",
    "Flash of Light", 
    "Healing Surge", 
    "Healing Wave", 
    "Soothing Mist", 
    "Vivify", 
    "Enveloping Mist", 
    "Heal",
    "Dream Breath",
    "Spiritbloom",
    "Fire Breath",
    "Living Flame",
    "Sheilun's Gift"
    }
})
Kicking:Dropdown({
  var = "kickCClist",
  multi = true,
  tooltip = "Choose Crowd Control spells you want to kick.",
  options = {
    { label = blink.textureEscape(118, 16, "0:0") .. " Polymorph", value = "Polymorph", tvalue = {118,161355,161354,161353,126819,61780,161372,61721,61305,28272,28271,277792,277787} },
    { label = blink.textureEscape(113724, 16, "0:0") .. " Ring of Frost", value = "Ring of Frost", tvalue = {113724,82691} },
    { label = blink.textureEscape(5782, 16, "0:0") .. " Fear", value = "Fear", tvalue = {5782} },
    { label = blink.textureEscape(710, 16, "0:0") .. " Banish", value = "Banish", tvalue = {710} },
    { label = blink.textureEscape(33786, 16, "0:0") .. " Cyclone", value = "Cyclone", tvalue = {33786, 88010} },
    { label = blink.textureEscape(2637, 16, "0:0") .. " Hibernate", value = "Hibernate", tvalue = {2637} },
    { label = blink.textureEscape(339, 16, "0:0") .. " Entangling Roots", value = "Entangling Roots", tvalue = {339} },
    { label = blink.textureEscape(20066, 16, "0:0") .. " Repentance", value = "Repentance", tvalue = {20066,29511,32779,82168,173315,82320,263672,82012} },
    { label = blink.textureEscape(51514, 16, "0:0") .. " Hex", value = "Hex", tvalue = {277784,309328,269352,211004,51514,332605,210873,211015,219215,277778,17172,66054,11641,271930,270492,18503,289419} },
    { label = blink.textureEscape(605, 16, "0:0") .. " Mind Control", value = "Mind Control", tvalue = {605} },
    { label = blink.textureEscape(198898, 16, "0:0") .. " Song of Chi-Ji", value = "Song of Chi-Ji", tvalue = {198898,198909} },
    { label = blink.textureEscape(360806, 16, "0:0") .. " Sleep Walk", value = "Sleep Walk", tvalue = {360806} },
    { label = blink.textureEscape(30283, 16, "0:0") .. " Shadowfury", value = "Shadowfury", tvalue = {30283,81441} },
    { label = blink.textureEscape(6358, 16, "0:0") .. " Seduction", value = "Seduction", tvalue = {6358} },
    { label = blink.textureEscape(1513, 16, "0:0") .. " Scare Beast", value = "Scare Beast", tvalue = {1513} },
    { label = blink.textureEscape(10326, 16, "0:0") .. " Turn Evil", value = "Turn Evil", tvalue = {10326} },
  
  },
  placeholder = "Select spells",
  header = "Select Crowd Control spells you want to kick.",
  default = {"Polymorph", "Sleep Walk", "Ring of Frost", "Hex", "Cyclone", "Seduction", "Fear", "Repentance", "Song of Chi-Ji"}
})
Kicking:Dropdown({
  var = "kickDangerouslist",
  multi = true,
  tooltip = "Choose Dangerous Damage spells you want to kick.",
  options = {
    { label = blink.textureEscape(265187, 16, "0:0") .. " Summon Demonic Tyrant", value = "Summon Demonic Tyrant", tvalue = {265187} },
    { label = blink.textureEscape(234153, 16, "0:0") .. " Drain Life", value = "Drain Life", tvalue = {234153} },
    { label = blink.textureEscape(198590, 16, "0:0") .. " Drain Soul", value = "Drain Soul", tvalue = {198590,1120} },
    { label = blink.textureEscape(116858, 16, "0:0") .. " Chaos Bolt", value = "Chaos Bolt", tvalue = {116858} },
    { label = blink.textureEscape(30108, 16, "0:0") .. " Unstable Affliction", value = "Unstable Affliction", tvalue = {30108,316099} },
    { label = blink.textureEscape(104316, 16, "0:0") .. " Call Dreadstalkers", value = "Call Dreadstalkers", tvalue = {104316, 193332} },
    { label = blink.textureEscape(325289, 16, "0:0") .. " Decimating Bolt", value = "Decimating Bolt", tvalue = {325289} },
    { label = blink.textureEscape(365350, 16, "0:0") .. " Arcane Surge", value = "Arcane Surge", tvalue = {365350,365362} },
    { label = blink.textureEscape(199786, 16, "0:0") .. " Glacial Spike", value = "Glacial Spike", tvalue = {199786} },
    { label = blink.textureEscape(390612, 16, "0:0") .. " Frost Bomb", value = "Frost Bomb", tvalue = {390612} },
    { label = blink.textureEscape(34914, 16, "0:0") .. " Vampiric Touch", value = "Vampiric Touch", tvalue = {34914,250037} },
    { label = blink.textureEscape(375901, 16, "0:0") .. " Mindgames", value = "Mindgames", tvalue = {375901} },
    { label = blink.textureEscape(263165, 16, "0:0") .. " Void Torrent", value = "Void Torrent", tvalue = {263165} },
    { label = blink.textureEscape(391109, 16, "0:0") .. " Dark Ascension", value = "Dark Ascension", tvalue = {391109} },
    { label = blink.textureEscape(15407, 16, "0:0") .. " Mind Flay", value = "Mind Flay", tvalue = {15407,23953} },
    { label = blink.textureEscape(228260, 16, "0:0") .. " Void Eruption", value = "Void Eruption", tvalue = {228260} },
    { label = blink.textureEscape(73510, 16, "0:0") .. " Mind Spike", value = "Mind Spike", tvalue = {73510} },
    { label = blink.textureEscape(214621, 16, "0:0") .. " Schism", value = "Schism", tvalue = {214621,20271} },
    { label = blink.textureEscape(8092, 16, "0:0") .. " Mind Blast", value = "Mind Blast", tvalue = {8092} },
    { label = blink.textureEscape(450405, 16, "0:0") .. " Void Blast", value = "Void Blast", tvalue = {450405} },
    { label = blink.textureEscape(257537, 16, "0:0") .. " Ebonbolt", value = "Ebonbolt", tvalue = {257537,214634} },
    { label = blink.textureEscape(205021, 16, "0:0") .. " Ray of Frost", value = "Ray of Frost", tvalue = {205021} },
    { label = blink.textureEscape(352278, 16, "0:0") .. " Ice Wall", value = "Ice Wall", tvalue = {352278}  },
    { label = blink.textureEscape(320137, 16, "0:0") .. " Stormkeeper", value = "Stormkeeper", tvalue = {191634,320137} },
    { label = blink.textureEscape(210714, 16, "0:0") .. " Icefury", value = "Icefury", tvalue = {210714,219271} },
    { label = blink.textureEscape(204437, 16, "0:0") .. " Lightning Lasso", value = "Lightning Lasso", tvalue = {305483,204437,305485} },
    { label = blink.textureEscape(325640, 16, "0:0") .. " Soul Rot", value = "Soul Rot", tvalue = {386997} },
    { label = blink.textureEscape(48181, 16, "0:0") .. " Haunt", value = "Haunt", tvalue = {48181,171788} },
    { label = blink.textureEscape(32375, 16, "0:0") .. " Mass Dispel (SP)", value = "Mass Dispel", tvalue = {32375} }, 
    { label = blink.textureEscape(32375, 16, "0:0") .. " Improved Mass Dispel (SP)", value = "Improved Mass Dispel", tvalue = {341167} },
    { label = blink.textureEscape(378464, 16, "0:0") .. " Nullifying Shroud", value = "Nullifying Shroud", tvalue = {378464,383618} },
    { label = blink.textureEscape(361469, 16, "0:0") .. " Living Flame", value = "Living Flame", tvalue = {361469} }, --EVOKER
    { label = blink.textureEscape(356995, 16, "0:0") .. " Disintegrate", value = "Disintegrate", tvalue = {356995} }, --EVOKER
    { label = blink.textureEscape(395160, 16, "0:0") .. " Eruption", value = "Eruption", tvalue = {395160} }, --EVOKER
    { label = blink.textureEscape(396286, 16, "0:0") .. " Upheaval", value = "Upheaval", tvalue = {396286, 410297} }, --EVOKER
    { label = blink.textureEscape(323764, 16, "0:0") .. " Convoke the Spirits", value = "Convoke the Spirits", tvalue = {393414,323764,337433} },
    { label = blink.textureEscape(410126, 16, "0:0") .. " Searing Glare", value = "Searing Glare", tvalue = {410126} },
    { label = blink.textureEscape(2812, 16, "0:0") .. " Denounce", value = "Denounce", tvalue = {2812} },
  
  },
  placeholder = "Select spells",
  header = "Select Dangerous Damage spells you want to kick.",
  default = {"Haunt","Ray of Frost","Summon Demonic Tyrant", "Arcane Surge", "Glacial Spike", "Decimating Bolt", "Chaos Bolt", "Drain Life", "Mindgames", "Stormkeeper", "Lightning Lasso", "Soul Rot", "Convoke the Spirits", "Mass Dispel", "Improved Mass Dispel", "Nullifying Shroud"}
})
-- stomping MULTI-DROPDOWN !--
local Stomp = ui:Tab("Totem Stomp")
Stomp:Text({text ="Totem Stomp Settings:", header = true})
Stomp:Checkbox({
  text = "Enable Auto Totem Stomp",
  --size = 14,
  paddingBottom = 10,
  var = "autoStomp",
  default = true,
  tooltip = "To enable or disable the routine from auto totem stomp     ",
})
Stomp:Text({text = blink.colors.cyan .."*Stomp delay auto randomized"})
-- Stomp:Slider({
--   --paddingTop = 55,
--   text = "Stomp Delay",
--   var = "stompDelay",
--   min = 0.1,
--   max = 0.9,
--   step = 0.1,
--   default = 0.3,
--   valueType = "ms",
--   tooltip = "Delay totems stomping (in milliseconds)\n\nAverage human reaction time is ~0.3ms."
-- })
Stomp:Dropdown({
  var = "totems",
  multi = true,
  tooltip = "Choose the totems you want to stomp.",
  options = {
  { label = blink.textureEscape(204336, 16, "0:0") .. " Grounding Totem", value = 5925 },
  { label = blink.textureEscape(98008, 16, "0:0") .. " Spirit Link Totem", value = 53006 },
  { label = blink.textureEscape(108280, 16, "0:0") .. " Healing Tide Totem", value = 59764 },
  { label = blink.textureEscape(204331, 16, "0:0") .. " Counterstrike Totem", value = 105451 },
  { label = blink.textureEscape(355580, 16, "0:0") .. " Static Field Totem", value = 179867 },
  { label = blink.textureEscape(5394, 16, "0:0") .. " Healing Stream Totem", value = 3527 },
  { label = blink.textureEscape(51485, 16, "0:0") .. " Earthgrab Totem", value = 60561 },
  { label = blink.textureEscape(2484, 16, "0:0") .. " Earthbind Totem", value = 2630 },
  { label = blink.textureEscape(204330, 16, "0:0") .. " Skyfury Totem", value = 105427 },
  { label = blink.textureEscape(8512, 16, "0:0") .. " Windfury Totem", value = 6112 },
  { label = blink.textureEscape(324386, 16, "0:0") .. " Vesper Totem", value = 324386 },
  { label = blink.textureEscape(192058, 16, "0:0") .. " Capacitor Totem", value = 61245 },
  { label = blink.textureEscape(8143, 16, "0:0") .. " Tremor Totem", value = 5913 },
  { label = blink.textureEscape(16191, 16, "0:0") .. " Mana Tide Totem", value = 10467 },
  { label = blink.textureEscape(383017, 16, "0:0") .. " Stoneskin Totem", value = 194117 },
  { label = blink.textureEscape(211522, 16, "0:0") .. " Psyfiend", value = 101398 },
  { label = blink.textureEscape(236320, 16, "0:0") .. " War Banner", value = 119052 },
  { label = blink.textureEscape(353601, 16, "0:0") .. " Fel Obelisk", value = 179193 },
  { label = blink.textureEscape(201996, 16, "0:0") .. " Observer", value = 107100 },
  
  },
  placeholder = "Select totems",
  header = "Select the Totems to stomp:",
default = {179193, 53006, 101398, 324386, 5925, 59764, 105427, 6112, 324386, 61245, 5913, 119052, 105451, 179867, 60561, 194117} -- optional default selections
})

--local Miscs = ui:Tab("Misc")

------------------------------------------------------------------
-- HUNTER SECTION
------------------------------------------------------------------
if sr.hunter.ready then

	local hunterColor = {170, 211, 114, 1}
	local hunterGroup = ui:Group({
		name = blink.textureEscape(626000, 15) .. " Hunter",
		title = {blink.textureEscape(626000, 14) .. " Sad", "Hunter"},

		colors = {
			title = {blinkCream, hunterColor},
			accent = hunterColor,
		}
	})
  local offensive = hunterGroup:Tab(blink.textureEscape(19574, 15) .. " Offensive ")
  offensive:Text({text = colors.hunter .. "Hunter Offensive Settings:", header = true})
  offensive:Dropdown({
    var = "mode",
    default = "ON",
    paddingBottom = 10,
    tooltip = "Turn ON/OFF Auto Burst",
    options = {
      { label = "ON", value = "ON", tooltip = "Turn on Auto Burst" },
      { label = "OFF", value = "OFF", tooltip = "Turn off Auto Burst" },
    },
    placeholder = "Select your mode",
    header = "Auto Burst:",
    size = 20,
  })
  offensive:Checkbox({
    text = blink.textureEscape(19574, 16, "0:8") .. " Burst only when enemyHealer in CC.",
    size = 14,
    paddingBottom = 10,
    paddingTop = 10,
    var = "NoAutoBurst", 
    default = false,
    tooltip = "Routine will burst only when enemyHealer in CC or YOU force it by using /sr burst.",
  })
	--! CONTROL TAB !--
	local control = hunterGroup:Tab(blink.textureEscape(187650, 15) .. " Control ")
	control:Text({text = colors.hunter .. "Hunter Crowd Control Settings:", header = true})
  control:Text({text = blink.textureEscape(187650, 16) .. " Auto Trap Settings:", header = true})
  control:Checkbox({
    text = "Enable Auto Trap     ",
    size = 16,
    paddingBottom = 10,
    var = "autotrap", -- checked bool = saved.test
    default = true,
    tooltip = "To enable or disable the routine from using the trap automaticlly",
  })
  control:Checkbox({name = "Trap to Followup CC      ", default = true, var = "autoFollowup", tooltip = "Automatically followup with trap off of other CC effects.\n\nOnly traps when it is full DR, or half out of other incapacitate effects."})
	-- control:Checkbox({name = "Bait With Tar", default = true, var = "tarBait", tooltip = "Use Tar Trap to bait trap immunities\n\n(Death, Grounding, Mass Reflect, Port, Etc.)\n\nOnly attempts baits while telegraphing a trap."})
	-- control:Checkbox({name = "Trap Fear Pathing", default = true, var = "trapFears", tooltip = "Attempt to trap off of fear pathing by linear prediction immediately after a directional change.\n\nThese can occasionally miss from far distances, as fear pathing can change multiple times unpredictably."})
	-- control:Checkbox({name = "Trap On Cast", default = true, var = "trapCasts", tooltip = "Throw trap to interrupt casts while within unprotected trap distance threshold.\n\nThese can occasionally be counterplayed, as starting a spell cast does not incur the global cooldown."})
	control:Checkbox({name = "Cheetah To Trap         ", default = false, var = "cheetahToTrap", tooltip = "Use cheetah to close gap when running towards trap target and out of range, as long as a slow is not applied to you and they are nearly off incap DR."})
	control:Checkbox({name = "Disengage To Trap       ", default = true, var = "disengageToTrap", tooltip = "Use disengage to close gap when running towards trap target and out of range, as long as they are nearly off incap DR."})
  -- control:Checkbox({name = "Don't Trap Units Under Attack", default = false, var = "DontTrapAttackedUnit", tooltip = "Don't trap units that under attack by your teammates."})
  if currentSpec == 3 then
    control:Checkbox({
      text = "Harpoon to trap       ",
      size = 14,
      paddingBottom = 10,
      var = "autoharpoon", 
      default = false,
      tooltip = "Use harpoon to close gap when running towards trap target and out of range, as long as they are nearly off incap DR automaticlly.",
    })
  end  
  control:Dropdown({
		var = "trapUnit",
		options = {
      { label = "Smart", value = "smart", tooltip = "Routine will trap your focus or your enemy healer if exists." },
			{ label = "Healer", value = "enemyHealer", tooltip = "Routine will only trap your enemy healer." },
			{ label = "Focus", value = "focus", tooltip = "Routine will only trap your focus." },
		},
		placeholder = "Choose Unit",
		tooltip = "Choose the unit the routine should use trap on.",
		default = "smart",
		header = "Trap Unit:",
	})

  --Intimidation Stun Settings
  control:Text({text = blink.textureEscape(19577, 16) .. " Intimidation Stun Settings:", header = true})

  control:Dropdown({
		var = "autoStunTarget",
		options = {
      { label = "Stun Trap Unit", value = "stunTrapUnit", tooltip = "Automatically use intimidation to secure trap on the trap target.\n\nRoutine will wait for incap DR on trap target and defensives on the kill target before stunning." },
			{ label = "Stun Kill Target", value = "stunKillTarget", tooltip = "Automatically use intimidation for cross-cc on kill target.\n\nRoutine will wait for trap or other cc on the trap target that guarantees a trap, as well as defensives on the kill target before stunning." },
      { label = "Disabled", value = "none", tooltip = "Disable Auto Intimidation." },
		},
		placeholder = "Choose Unit",
		tooltip = "Choose the unit the routine should use Intimidation Stun on.",
		default = "none",
		header = "Intimidation Unit:",
	})
	-- control:Checkbox({name = "Stun Trap Target                        ", default = false, var = "autoStun", tooltip = "Automatically use intimidation to secure trap on the trap target.\n\nRoutine will wait for incap DR on trap target and defensives on the kill target before stunning."})
	-- control:Checkbox({name = "Stun Kill Target                        ", default = false, var = "stunKillTarget", tooltip = "Automatically use intimidation for cross-cc on kill target.\n\nRoutine will wait for trap or other cc on the trap target that guarantees a trap, as well as defensives on the kill target before stunning."})

  
  control:Text({text = blink.textureEscape(213691, 16) .. " Scatter Shot Settings:", header = true})
  control:Checkbox({
    text = "Auto Scatter Shot     ",
    size = 14,
    paddingBottom = 10,
    var = "autoScatter", 
    default = true,
    tooltip = "To Enable or Disable the routine from using the Scatter Shot.",
  })
  control:Checkbox({
    text = "Don't Scatter Shot dotted/bleeded enemies ",
    size = 14,
    paddingBottom = 10,
    var = "dontScatterDots", 
    default = true,
    tooltip = "Avoid Scatter Shot enemies that are dotted or bleeded from teammates unless necessary.",
  })
  control:Checkbox({
    text = "Scatter Shot Enemy CD's  ",
    size = 14,
    paddingBottom = 10,
    var = "autoscatterCDs", 
    default = true,
    tooltip = "To Enable or Disable the routine from using the Scatter Shot on Enemy CD's when you are not targeting them.",
  })
  control:Checkbox({
    text = "Scatter Shot Cross CC  ",
    size = 14,
    paddingBottom = 10,
    var = "autoscatterCrossCC", 
    default = false,
    tooltip = "To Enable or Disable the routine from using the Scatter Shot on off target when you are not targeting them.",
  })
  control:Checkbox({
    text = "Scatter Shot Gapclosers  ",
    size = 14,
    paddingBottom = 10,
    var = "autoscatterGapCloser", 
    default = false,
    tooltip = "To Enable or Disable the routine from using the Scatter Shot on Gapclosers when you are not targeting them.",
  })
  control:Checkbox({
    text = "Scatter Shot to cover our Trap  ",
    size = 14,
    paddingBottom = 10,
    var = "autoscattercover", 
    default = true,
    tooltip = "To Enable or Disable the routine from using Scatter Shot to cover our Trap when you are not targeting them.",
  })
  control:Checkbox({
    text = "Scatter Shot to peel  ",
    size = 14,
    paddingBottom = 10,
    var = "autoscatterpeel", 
    default = true,
    tooltip = "To Enable or Disable the routine from using the Scatter Shot to peel when you are not targeting them.",
  })
  control:Text({text = blink.textureEscape(109248, 16, "0:2") .. " BindingShot:", header = true})
  control:Checkbox({
    text = "Auto BindingShot to cover traps",
    size = 14,
    paddingBottom = 10,
    var = "autocoverdh", 
    default = true,
    tooltip = "To Enable or Disable the routine from using BindingShot on Enemy Demon Hunter to cover traps",
  })
  -- control:Checkbox({
  --   text = "Auto BindingShot WW Monk Clones",
  --   size = 14,
  --   paddingBottom = 10,
  --   var = "autobindingClones", 
  --   default = true,
  --   tooltip = "To Enable or Disable the routine from using BindingShot on Enemy WW Monk Clones",
  -- })

  control:Text({text = blink.textureEscape(5116, 16, "0:2") .. " Slow:", header = true})
  control:Checkbox({
    text = "Keep enemy Healer slowed",
    size = 14,
    paddingBottom = 10,
    var = "autoslow", 
    default = true,
    tooltip = "To Enable or Disable the routine from Keeping enemy Healer slowed automaticlly",
  })
  control:Checkbox({
    text = "Slow enemy DPS Bursting",
    size = 14,
    paddingBottom = 10,
    var = "slowbigdam", 
    default = true,
    tooltip = "To Enable or Disable the routine from using Slow on enemy DPS Bursting automaticlly",
  })
  control:Checkbox({
    text = "Slow enemy melee DPS tunnel you",
    size = 13,
    paddingBottom = 10,
    var = "slowtunnel", 
    default = false,
    tooltip = "To Enable or Disable the routine from using Slow on enemy Melee DPS Tunnel you automaticlly",
  })
  control:Checkbox({
    text = "Auto Steel Trap",
    size = 14,
    --paddingTop = 10,
    var = "autosteeltrap", 
    default = true,
    tooltip = "To Enable or Disable the routine from using Steel Trap on enemy DPS Bursting automaticlly",
  })
  control:Text({text = blink.textureEscape(356719, 16, "0:2") .. " Chimaeral Sting:", header = true, paddingTop = 15})
  control:Checkbox({
    text = "Use Chimaeral Sting to Followup CC",
    size = 14,
    --paddingTop = 10,
    var = "ChimaeralSting", 
    default = true,
    tooltip = "Routine will use Chimaeral Sting on enemy Healer when he is stunned and you don't have trap to followup Silence",
  })
  control:Checkbox({
    text = "Use Chimaeral Sting After Successful Kick",
    size = 14,
    --paddingTop = 10,
    var = "csHealer", 
    default = true,
    tooltip = "Routine will use Chimaeral Sting on enemy Healer After Successful Kick to followup Silence",
  })

	--! UTILITY TAB !--
	local utility = hunterGroup:Tab(blink.textureEscape(5384, 15) .. " Utility ")
  utility:Text({text = colors.hunter .. "Hunter Utilitys Settings:", header = true})
  utility:Checkbox({
    text = blink.textureEscape(58984, 16, "0:8") .. " Enable Auto Shadowmeld events",
    size = 14,
    paddingBottom = 10,
    var = "AutoMeld",
    default = true,
    tooltip = "To Enable or Disable the routine from using Shadowmeld to counter enemies.\n\n\will meld stormbolts/coil/the hunt etc.",
    
  })
  utility:Checkbox({
    text = blink.textureEscape(1543, 16, "0:8") .. " Enable Auto Flare enemy restealths",
    size = 14,
    paddingBottom = 10,
    var = "AutoFlare",
    default = true,
    tooltip = "To Enable or Disable the routine from using Flare on enemy restealths",
    
  })
  utility:Checkbox({
    text = blink.textureEscape(19801, 16, "0:8") .. " Enable Auto Tranq",
    size = 14,
    paddingBottom = 10,
    var = "AutoTranq",
    default = true,
    tooltip = "To Enable or Disable the routine from using Tranq",
    
  })
  utility:Checkbox({
    text = blink.textureEscape(257284, 16, "0:8") .. " Enable Auto Hunter's Mark",
    size = 14,
    paddingBottom = 10,
    var = "autoHunterMark",
    default = true,
    tooltip = "To Enable or Disable the routine from using Hunter's Mark.",
    
  })
  utility:Dropdown({
    var = "tranqList",
    multi = true,
    tooltip = "Select the buffs you want to Tranq.",
    options = {
      { label = blink.textureEscape(79206, 16, "0:0") .. " Spiritwalker's Grace", value = "Spiritwalker's Grace", tvalue = {79206} },
      { label = blink.textureEscape(10060, 16, "0:0") .. " Power Infusion", value = "Power Infusion", tvalue = {10060} },
      { label = blink.textureEscape(378464, 16, "0:0") .. " Nullifying Shroud", value = "Nullifying Shroud", tvalue = {378464} },
      { label = blink.textureEscape(305395, 16, "0:0") .. " Blessing of Freedom", value = "Blessing of Freedom", tvalue = {305395,1044} },
      { label = blink.textureEscape(1022, 16, "0:0") .. " Blessing of Protection", value = "Blessing of Protection", tvalue = {1022} },
      { label = blink.textureEscape(210294, 16, "0:0") .. " Divine Favor", value = "Divine Favor", tvalue = {210294} },
      { label = blink.textureEscape(80240, 16, "0:0") .. " Havoc", value = "Havoc", tvalue = {80240} },
      { label = blink.textureEscape(132158, 16, "0:0") .. " Druid Nature's Swiftness", value = "Druid Nature's Swiftness", tvalue = {132158} },
      { label = blink.textureEscape(305497, 16, "0:0") .. " Thorns", value = "Thorns", tvalue = {305497} },
      { label = blink.textureEscape(378081, 16, "0:0") .. " Shaman Nature's Swiftness", value = "Shaman Nature's Swiftness", tvalue = {378081} },
      { label = blink.textureEscape(342246, 16, "0:0") .. " Alter time", value = "Alter time", tvalue = {342246,198111} },
      { label = blink.textureEscape(342242, 16, "0:0") .. " Time Warp", value = "Time Warp", tvalue = {342242,198111} },
      { label = blink.textureEscape(213610, 16, "0:0") .. " Holy Word", value = "Holy Word", tvalue = {213610} },
      { label = blink.textureEscape(11426, 16, "0:0") .. " Ice Barrier", value = "Ice Barrier", tvalue = {11426,198094,414661} },
      { label = blink.textureEscape(235313, 16, "0:0") .. " Blazing Barrier", value = "Blazing Barrier", tvalue = {235313} },
      { label = blink.textureEscape(17, 16, "0:0") .. " Power Word: Shield", value = "Power Word: Shield", tvalue = {135940,17} },
      { label = blink.textureEscape(360827, 16, "0:0") .. " Blistering Scales", value = "Blistering Scales", tvalue = {360827} },
    },
    placeholder = "Select spells",
    header = "Select the buffs you want to Tranq.",
    default = {
      "Spiritwalker's Grace",
      "Blessing of Freedom", 
      "Blessing of Protection", 
      "Power Infusion", 
      "Nullifying Shroud", 
      "Alter time", 
      "Holy Word",
      "Ice Barrier",
      "Blazing Barrier",
      "Druid Nature's Swiftness",
      "Shaman Nature's Swiftness",
      "Havoc",
      "Time Warp",
      "Blistering Scales",
      "Thorns",
    }
  })
  -- if currentSpec == 3 then
  --   utility:Checkbox({
  --     text = blink.textureEscape(360966, 16, "0:8") .. " Spearhead Gapclose Target",
  --     var = "autoSpearhead",
  --     default = false,
  --     tooltip = "Will automatically Spearhead to target when out of range and moving towards them.",
  --   })
  --   utility:Slider({
  --     text = blink.textureEscape(360966, 16) .. " Spearhead Gapclose Pressure Modifier",
  --     var = "SpearheadGapcloseMod",
  --     min = 0.75,
  --     max = 1.5,
  --     step = 0.01,
  --     default = 1.2,
  --     valueType = "x",
  --     tooltip = "Modifies sensitivity to our pressure for using leap to gapclose.\n\n\Lower = only use Spearhead to gapclose our target when we have a lot of pressure.\n\nHigher = use leap to gapclose our target even when we have very little pressure."
  --   })
  -- end
  utility:Dropdown({
		var = "freedomUnit",
		options = {
      { label = "Freedom self only", value = "selfish", tooltip = "Routine will use pet Freedom for you only." },
			{ label = "Freedom only my healer", value = "friendlyHealer", tooltip = "Routine will use pet Freedom when your healer need it only." },
			{ label = "Freedom all team mates", value = "allTeam", tooltip = "Routine will use pet Freedom when any team mate need it." },
			{ label = "Disable auto Freedom", value = "none", tooltip = "Disable auto pet Freedom." },
		},
		tooltip = "Choose the unit to use pet Freedom for.",
		default = "selfish",
		header = blink.textureEscape(53271, 16, "0:1") .. " Use pet Freedom on Unit:",
	})
  utility:Checkbox({
    text = blink.textureEscape(5384, 16, "0:8") .. " Enable Auto Feign Death",
    size = 14,
    paddingBottom = 10,
    var = "autofeign", -- checked bool = saved.test
    default = true,
    tooltip = "To Enable or Disable the routine from using the Smart Feign Death logic",
    
  })
  -- utility:Checkbox({
  --   text = blink.textureEscape(53271, 16, "0:8") .. " Enable Auto Freedom",
  --   size = 14,
  --   paddingBottom = 10,
  --   var = "autofreedom",
  --   default = true,
  --   tooltip = "To Enable or Disable the routine from using Auto Freedom",
    
  -- })
  utility:Checkbox({
    text = blink.textureEscape(883, 16, "0:8") .. " Enable Auto Call Pet",
    size = 14,
    paddingBottom = 10,
    var = "autocallpet",
    default = true,
    tooltip = "To Enable or Disable the routine from using Auto Calling Pet",
    
  })
  utility:Dropdown({
    var = "CallPetMode",
    default = "pet1",
    tooltip = "Select which pet routine should call.\n\nCalling Pets is sorted by your stable index.",
    options = {
        { label = blink.textureEscape(883, 16) .. " Call pet 1", value = "pet1", tooltip = "" },
        { label = blink.textureEscape(83242, 16) .. " Call pet 2", value = "pet2", tooltip = "" },
        { label = blink.textureEscape(83243, 16) .. " Call pet 3", value = "pet3", tooltip = "" },
        { label = blink.textureEscape(83244, 16) .. " Call pet 4", value = "pet4", tooltip = "" },
        { label = blink.textureEscape(83245, 16) .. " Call pet 5", value = "pet5", tooltip = "" },
    },
    placeholder = "Select which pet routine should call",
    header = blink.textureEscape(883, 16) .. " Call Pet by stable index:",
    size = 20,
  })
  
  -- utility:Checkbox({
  --   text = blink.textureEscape(187650, 16, "0:8") .. " Enable Auto move pet to eat enemy traps",
  --   size = 14,
  --   paddingBottom = 10,
  --   var = "peteattrap",
  --   default = true,
  --   tooltip = "To Enable or Disable the routine from using pet move to eat enemy traps on your (Friendly healer)",
    
  -- })
  if currentSpec == 3 then
    utility:Checkbox({
      text = blink.textureEscape(186289, 16, "0:8") .. " Enable Auto Aspect of the Eagle",
      size = 14,
      paddingBottom = 10,
      var = "autoEagle", -- checked bool = saved.test
      default = true,
      tooltip = "To Enable or Disable the routine from using Aspect of the Eagle if your target is away from you and you have CD's up",
      
    })
  end
  -- utility:Text({text = blink.textureEscape(212640, 16, "0:2") .. " Mending Bandage:",
  -- paddingTop = 10,
  -- })
  if currentSpec == 3 then
    utility:Checkbox({
      text = blink.textureEscape(212640, 16, "0:8") .. " Enable Auto Mending Bandage",
      size = 14,
      paddingTop = 10,
      var = "automending", -- checked bool = saved.test
      default = true,
      tooltip = "To Enable or Disable the routine from using the Auto Mending Bandage logic",
    })
  end   

  -- local pve = hunterGroup:Tab(blink.textureEscape(359844, 15, "0:1") .. " PVE Settings")
  -- pve:Text({text = blink.colors.orange .."Hunter PVE|r Settings:", header = true})
  -- -- pve:Checkbox({
  -- --   text = blink.textureEscape(359844, 16, "0:8") .. " Load Pve Profile.",
  -- --   size = 14,
  -- --   paddingBottom = 10,
  -- --   paddingTop = 10,
  -- --   var = "loadPve", 
  -- --   default = false,
  -- --   tooltip = "Load Pve Profile.",
  -- --   OnClick = function(self, event)
  -- --     blink.alert("Loading Pve")
  -- --   end
  -- -- })
  -- pve:Dropdown({
  --   var = "pveMode",
  --   default = "BOSS",
  --   paddingBottom = 10,
  --   tooltip = "Select your burst mode",
  --   options = {
  --     { label = "Burst Bosses Only", value = "BOSS", tooltip = "Will use burst cd's on bosses only" },
  --     { label = "Always Burst", value = "ALWAYS", tooltip = "Will always use burst cd's" },
  --   },
  --   placeholder = "Select your burst mode",
  --   header = "Burst Mode:",
  --   size = 20,
  -- })
  -- pve:Text({text = blink.colors.orange .. "PVE Interrupt|r Configurations:", header = true})
  -- pve:Text({text = blink.colors.cyan .."*Interrupts delay auto randomized"})
  -- -- pve:Dropdown({
  -- --   var = "kickMode",
  -- --   default = "kickAll",
  -- --   paddingTop = 20,
  -- --   paddingBottom = 10,
  -- --   tooltip = "Choose Unit to kick.",
  -- --   options = {
  -- --     { label = "Kick All", value = "kickAll", tooltip = "Routine will do rotation and utilities." },
  -- --     { label = "Kick Focus only", value = "kickFocus", tooltip = "Routine will do PVE rotation." },
  -- --     { label = "Kick Skull only", value = "kickSkull", tooltip = "Routine will do PVE rotation." },
  -- --     { label = "Kick Triange only", value = "kickTriange", tooltip = "Routine will do PVE rotation." },
  -- --     { label = "Kick Star only", value = "kickStar", tooltip = "Routine will do PVE rotation." },

  -- --   },
  -- --   placeholder = "Select Mode",
  -- --   header = "Choose Unit to kick:",
  -- --   size = 20,
  -- -- })

  -- pve:Dropdown({
  -- var = "everBloomList",
  -- multi = true,
  -- tooltip = blink.colors.orange .."The Everbloom|r Kick list.",
  -- options = {
  --   { label = blink.textureEscape(118, 16, "0:0") .. " test", value = "test", tvalue = {118} },
  --   { label = blink.textureEscape(168082, 16, "0:0") .. " Revitalize", value = "Revitalize", tvalue = {168082} },
  --   { label = blink.textureEscape(169839, 16, "0:0") .. " Pyroblast", value = "Pyroblast", tvalue = {169839} },
  --   { label = blink.textureEscape(169841, 16, "0:0") .. " Arcane Blast", value = "Arcane Blast", tvalue = {169841} },
  --   { label = blink.textureEscape(173563, 16, "0:0") .. " Lasher Venom", value = "Lasher Venom", tvalue = {173563} },
  --   { label = blink.textureEscape(168092, 16, "0:0") .. " Water Bolt", value = "Water Bolt", tvalue = {168092} },
  --   { label = blink.textureEscape(166465, 16, "0:0") .. " Frostbolt", value = "Frostbolt", tvalue = {166465} },
  --   { label = blink.textureEscape(164965, 16, "0:0") .. " Choking Vines", value = "Choking Vines", tvalue = {164965} },
  --   { label = blink.textureEscape(164887, 16, "0:0") .. " Healing Waters", value = "Healing Waters", tvalue = {164887} },
  --   { label = blink.textureEscape(165213, 16, "0:0") .. " Enraged Growth", value = "Enraged Growth", tvalue = {165213} },
  --   { label = blink.textureEscape(164973, 16, "0:0") .. " Dancing Thorns", value = "Dancing Thorns", tvalue = {164973} },
  --   { label = blink.textureEscape(168040, 16, "0:0") .. " Nature's Wrath", value = "Nature's Wrath", tvalue = {168040} },
  -- },
  -- placeholder = "Select spells",
  -- header = blink.colors.orange .."The Everbloom|r Kick list.",
  -- default = {
  --   "Revitalize",
  --   "Arcane Blast",
  --   "Choking Vines",
  --   "Healing Waters",
  --   "Enraged Growth",
  --   }
  -- })

  -- pve:Dropdown({
  -- var = "wayCrestList",
  -- multi = true,
  -- tooltip = blink.colors.orange .."Waycrest Manor|r Kick list.",
  -- options = {
  --   --should be finshed
  --   { label = blink.textureEscape(264520, 16, "0:0") .. " Severing Serpent", value = "Severing Serpent", tvalue = {264520} },
  --   { label = blink.textureEscape(278444, 16, "0:0") .. " Infest", value = "Infest", tvalue = {278444} },
  --   { label = blink.textureEscape(265368, 16, "0:0") .. " Spirited Defense", value = "Spirited Defense", tvalue = {265368} },
  --   { label = blink.textureEscape(260699, 16, "0:0") .. " Soul Bolt", value = "Soul Bolt", tvalue = {260699} },
  --   { label = blink.textureEscape(271174, 16, "0:0") .. " Retch", value = "Retch", tvalue = {271174} },
  --   { label = blink.textureEscape(268278, 16, "0:0") .. " Wracking Chord", value = "Wracking Chord", tvalue = {268278} },
  --   { label = blink.textureEscape(264050, 16, "0:0") .. " Infected Thorn", value = "Infected Thorn", tvalue = {264050} },
  --   { label = blink.textureEscape(266225, 16, "0:0") .. " Darkened Lightning", value = "Darkened Lightning", tvalue = {266225} },
  --   { label = blink.textureEscape(260701, 16, "0:0") .. " Bramble Bolt", value = "Bramble Bolt", tvalue = {260701} },
  --   { label = blink.textureEscape(164973, 16, "0:0") .. " Death Lens", value = "Death Lens", tvalue = {164973} },
  --   { label = blink.textureEscape(263959, 16, "0:0") .. " Soul Volley", value = "Soul Volley", tvalue = {263959} },
  --   { label = blink.textureEscape(267824, 16, "0:0") .. " Scar Soul", value = "Scar Soul", tvalue = {267824} },
  --   { label = blink.textureEscape(264390, 16, "0:0") .. " Spellblind", value = "Spellblind", tvalue = {264390} },
  -- },
  -- placeholder = "Select spells",
  -- header = blink.colors.orange .."Waycrest Manor|r Kick list.",
  -- default = {
  --   "Spellblind",
  --   "Infected Thorn",
  --   "Soul Volley",
  --   "Wracking Chord",
  --   "Retch",
  --   }
  -- })

  -- pve:Dropdown({
  -- var = "AtalList",
  -- multi = true,
  -- tooltip = blink.colors.orange .."Atal'Dazar|r Kick list.",
  -- options = {
  --   --should be finshed
  --   { label = blink.textureEscape(253239, 16, "0:0") .. " Merciless Assault", value = "Merciless Assault", tvalue = {253239} },
  --   { label = blink.textureEscape(260668, 16, "0:0") .. " Transfusion", value = "Transfusion", tvalue = {260668} },
  --   { label = blink.textureEscape(256138, 16, "0:0") .. " Fervent Strike", value = "Fervent Strike", tvalue = {256138} },
  --   { label = blink.textureEscape(250096, 16, "0:0") .. " Wracking Pain", value = "Wracking Pain", tvalue = {250096} },
  --   { label = blink.textureEscape(253562, 16, "0:0") .. " Wildfire", value = "Wildfire", tvalue = {253562} },
  --   { label = blink.textureEscape(255041, 16, "0:0") .. " Terrifying Screech", value = "Terrifying Screech", tvalue = {255041} },
  --   { label = blink.textureEscape(256959, 16, "0:0") .. " Rotting Decay", value = "Rotting Decay", tvalue = {256959} },
  --   { label = blink.textureEscape(253583, 16, "0:0") .. " Fiery Enchant", value = "Fiery Enchant", tvalue = {253583} },
  --   { label = blink.textureEscape(252687, 16, "0:0") .. " Venomfang Strike", value = "Venomfang Strike", tvalue = {252687} },
  --   { label = blink.textureEscape(250368, 16, "0:0") .. " Noxious Stench", value = "Noxious Stench", tvalue = {250368} },
  --   { label = blink.textureEscape(253548, 16, "0:0") .. " Bwonsamdi's Mantle", value = "Bwonsamdi's Mantle", tvalue = {253548} },
  --   { label = blink.textureEscape(252781, 16, "0:0") .. " Unstable Hex", value = "Unstable Hex", tvalue = {252781} },
  --   { label = blink.textureEscape(255824, 16, "0:0") .. " Fanatic's Rage", value = "Fanatic's Rage", tvalue = {255824} },
  --   { label = blink.textureEscape(252923, 16, "0:0") .. " Venom Blast", value = "Venom Blast", tvalue = {252923} },
  --   { label = blink.textureEscape(253517, 16, "0:0") .. " Mending Word", value = "Mending Word", tvalue = {253517} },
  -- },
  -- placeholder = "Select spells",
  -- header = blink.colors.orange .."Atal'Dazar|r Kick list.",
  -- default = {
  --   "Terrifying Screech",
  --   "Fanatic's Rage",
  --   -- "Choking Vines",
  --   -- "Healing Waters",
  --   -- "Enraged Growth",
  --   }
  -- })

  -- pve:Dropdown({
  -- var = "brhList",
  -- multi = true,
  -- tooltip = blink.colors.orange .."Black Rook Hold|r Kick list.",
  -- options = {
  --   --should be finshed
  --   { label = blink.textureEscape(200248, 16, "0:0") .. " Arcane Blitz", value = "Arcane Blitz", tvalue = {200248} },
  --   { label = blink.textureEscape(200784, 16, "0:0") .. " (Drink) Ancient Potion", value = "Ancient Potion", tvalue = {200784} },
  --   { label = blink.textureEscape(200261, 16, "0:0") .. " Bonebreaking Strike", value = "Bonebreaking Strike", tvalue = {200261} },
  --   { label = blink.textureEscape(214003, 16, "0:0") .. " Coup de Grace", value = "Coup de Grace", tvalue = {214003} },
  --   { label = blink.textureEscape(199663, 16, "0:0") .. " Soul Blast", value = "Soul Blast", tvalue = {199663} },
  --   { label = blink.textureEscape(197974, 16, "0:0") .. " Bonecrushing Strike", value = "Bonecrushing Strike", tvalue = {197974} },
  --   { label = blink.textureEscape(200256, 16, "0:0") .. " Phased Explosion", value = "Phased Explosion", tvalue = {200256} },
  --   { label = blink.textureEscape(200913, 16, "0:0") .. " Indigestion", value = "Indigestion", tvalue = {200913} },
  --   { label = blink.textureEscape(200291, 16, "0:0") .. " Knife Dance", value = "Knife Dance", tvalue = {200291} },
  --   { label = blink.textureEscape(201139, 16, "0:0") .. " Brutal Assault", value = "Brutal Assault", tvalue = {201139} },
  --   { label = blink.textureEscape(200084, 16, "0:0") .. " Soul Blade", value = "Soul Blade", tvalue = {200084} },
  --   { label = blink.textureEscape(156854, 16, "0:0") .. " Drain Life", value = "Drain Life", tvalue = {156854} },
  --   { label = blink.textureEscape(227913, 16, "0:0") .. " Felfrenzy", value = "Felfrenzy", tvalue = {227913} },
  --   { label = blink.textureEscape(214001, 16, "0:0") .. " Raven's Dive", value = "Raven's Dive", tvalue = {214001} },
  --   { label = blink.textureEscape(193633, 16, "0:0") .. " Shoot", value = "Shoot", tvalue = {193633} },
  -- },
  -- placeholder = "Select spells",
  -- header = blink.colors.orange .."Black Rook Hold|r Kick list.",
  -- default = {
  --   -- "Revitalize",
  --   -- "Arcane Blast",
  --   -- "Choking Vines",
  --   -- "Healing Waters",
  --   -- "Enraged Growth",
  --   }
  -- })

  -- pve:Dropdown({
  -- var = "darkHeartList",
  -- multi = true,
  -- tooltip = blink.colors.orange .."Darkheart Thicket|r Kick list.",
  -- options = {
  --   --should be finshed
  --   { label = blink.textureEscape(225562, 16, "0:0") .. " Blood Metamorphosis", value = "Blood Metamorphosis", tvalue = {225562} },
  --   { label = blink.textureEscape(201400, 16, "0:0") .. " Dread Inferno", value = "Dread Inferno", tvalue = {201400} },
  --   { label = blink.textureEscape(201298, 16, "0:0") .. " Bloodbolt", value = "Bloodbolt", tvalue = {201298} },
  --   { label = blink.textureEscape(200642, 16, "0:0") .. " Despair", value = "Despair", tvalue = {200642} },
  --   { label = blink.textureEscape(201411, 16, "0:0") .. " Firebolt", value = "Firebolt", tvalue = {201411} },
  --   { label = blink.textureEscape(201837, 16, "0:0") .. " Shadow Bolt", value = "Shadow Bolt", tvalue = {201837} },
  --   { label = blink.textureEscape(201842, 16, "0:0") .. " Curse of Isolation", value = "Curse of Isolation", tvalue = {201842} },
  --   { label = blink.textureEscape(198723, 16, "0:0") .. " Throw Spear", value = "Throw Spear", tvalue = {198723} },
  --   { label = blink.textureEscape(200658, 16, "0:0") .. " Star Shower", value = "Star Shower", tvalue = {200658} },
  --   { label = blink.textureEscape(200631, 16, "0:0") .. " Unnerving Screech", value = "Unnerving Screech", tvalue = {200631} },
  --   { label = blink.textureEscape(204243, 16, "0:0") .. " Tormenting Eye", value = "Tormenting Eye", tvalue = {204243} },
  -- },
  -- placeholder = "Select spells",
  -- header = blink.colors.orange .."Darkheart Thicket|r Kick list.",
  -- default = {
  --   -- "Revitalize",
  --   -- "Arcane Blast",
  --   -- "Choking Vines",
  --   -- "Healing Waters",
  --   -- "Enraged Growth",
  --   }
  -- })

  -- pve:Dropdown({
  -- var = "dawnInfiniteList",
  -- multi = true,
  -- tooltip = blink.colors.orange .."Dawn of the Infinite|r Kick list.",
  -- options = {
  --   --should be finshed
  --   { label = blink.textureEscape(411958, 16, "0:0") .. " Stonebolt", value = "Stonebolt", tvalue = {411958} },
  --   { label = blink.textureEscape(415770, 16, "0:0") .. " Infinite Bolt Volley", value = "Infinite Bolt Volley", tvalue = {415770} },
  --   { label = blink.textureEscape(415436, 16, "0:0") .. " Tainted Sands", value = "Tainted Sands", tvalue = {415436} },
  --   { label = blink.textureEscape(411994, 16, "0:0") .. " Chronometl", value = "Chronometl", tvalue = {411994} },
  --   { label = blink.textureEscape(413473, 16, "0:0") .. " Double Strike", value = "Double Strike", tvalue = {413473} },
  --   { label = blink.textureEscape(415435, 16, "0:0") .. " Infinite Bolt", value = "Infinite Bolt", tvalue = {415435} },
  --   { label = blink.textureEscape(415437, 16, "0:0") .. " Enervate", value = "Enervate", tvalue = {415437} },
  -- },
  -- placeholder = "Select spells",
  -- header = blink.colors.orange .."Dawn of the Infinite|r Kick list.",
  -- default = {
  --   -- "Revitalize",
  --   -- "Arcane Blast",
  --   -- "Choking Vines",
  --   -- "Healing Waters",
  --   -- "Enraged Growth",
  --   }
  -- })

  -- pve:Dropdown({
  -- var = "TOTList",
  -- multi = true,
  -- tooltip = blink.colors.orange .."Throne of the Tides|r Kick list.",
  -- options = {
  --   --should be finshed
  --   { label = blink.textureEscape(429176, 16, "0:0") .. " Aquablast", value = "Aquablast", tvalue = {429176} },
  --   { label = blink.textureEscape(115062, 16, "0:0") .. " Throw Spear", value = "Throw Spear", tvalue = {115062} },
  -- },
  -- placeholder = "Select spells",
  -- header = blink.colors.orange .."Throne of the Tides|r Kick list.",
  -- default = {
  --   "Aquablast",
  --   "Throw Spear",
  --   -- "Choking Vines",
  --   -- "Healing Waters",
  --   -- "Enraged Growth",
  --   }
  -- })


	--! Defensives TAB !--
	local Defensives = hunterGroup:Tab(blink.textureEscape(186265, 15) .. " Defensives ")
  Defensives:Text({
    text = colors.hunter .. "Hunter Defensives Settings:", header = true,
    --paddingBottom = 5,
  })

  Defensives:Checkbox({
    text = blink.textureEscape(53480, 16, "0:8") .. " Enable Auto Roar of Sacrifice",
    size = 20,
    paddingBottom = 5,
    var = "autoros", 
    default = true,
    tooltip = "To Enable or Disable the routine from using the Smart Pet Roar of Sacrfice automatically",
  })
  Defensives:Checkbox({
    text = blink.textureEscape(186265, 16, "0:8") .. " Don't Turtle with [Guardian Spirit/Life Cocoon] up",
    size = 20,
    paddingBottom = 5,
    var = "dontturtleGuardian", 
    default = true,
    tooltip = "To Enable or Disable the routine from using Turtle if you have [Guardian Spirit/Life Cocoon] buff up",
  })
  Defensives:Checkbox({
    text = blink.textureEscape(264735, 16, "0:8") .. " Enable Auto Survival of the Fittest",
    size = 20,
    paddingBottom = 5,
    var = "AutoSOTF", 
    default = true,
    tooltip = "To Enable or Disable the routine from using the Smart Survival of the Fittest automatically",
  })
  Defensives:Checkbox({
    text = blink.textureEscape(388035, 16, "0:8") .. " Enable Auto Fortitude of the Bear",
    size = 20,
    paddingBottom = 5,
    var = "AutoFortitude",
    default = true,
    tooltip = "To Enable or Disable the routine from using the Smart Fortitude of the Bear automatically",
  })
	Defensives:Slider({
		text = "Fortitude Sensitivity",
		size = 14,
		var = "FortitudeSensitivity",
		min = 0.5,
		max = 1.5,
		step = 0.01,
		default = 1,
		valueType = "x",
		tooltip = "Modifies sensitivity to danger threshold for using Fortitude of the Bear.\n\nSetting this higher will cause it to use Fortitude of the Bear more preemptively.\n\nSetting this lower will cause it to hold it unless we are in a lot of trouble."
	})

  Defensives:Slider({
    text = blink.textureEscape(461117, 16, "0:2") .. " Use Exhilaration by player health",
    --text = "Use Exhilaration By Health",
    paddingTop = 10,
    var = "exhilaration", 
    min = 0,
    max = 100,
    default = 30,
    valueType = "%",
    tooltip = "Set the percentage to use Exhilaration"
  })
  Defensives:Slider({
    text = blink.textureEscape(461117, 16) .. " Use Exhilaration by pet health",
    paddingTop = 10,
    var = "Petexhilaration", 
    min = 0,
    max = 100,
    default = 20,
    valueType = "%",
    tooltip = "Set the pet percentage to use Exhilaration"
  })
  Defensives:Slider({
    text = blink.textureEscape(90361, 16, "0:2") .. " Use Spirit Mend by player health",
    paddingTop = 10,
    var = "spiritMendSlider", 
    min = 0,
    max = 100,
    default = 65,
    valueType = "%",
    tooltip = "Set the percentage to use Spirit Mend (Spirit pet heal)"
  })
  Defensives:Checkbox({
    text = blink.textureEscape(186265, 16, "0:8") .. " Greedy Turtle ",
    size = 20,
    paddingBottom = 5,
    var = "GreedyTurtle", 
    default = false,
    tooltip = "To Enable or Disable the routine to be really greedy on using turtle.\n\ndon't rely on that still working hard to make it read alot of stuff before using it",
  })
  Defensives:Slider({
    text = blink.textureEscape(186265, 16, "0:2") .. " Use Turtle By Health",
    --text = "Use Turtle By Health",
    var = "turtle", 
    min = 0,
    max = 100,
    default = 20,
    valueType = "%",
    tooltip = "Set the percentage to use Turtle"
  })

  -- Defensives:Slider({
  --   text = blink.textureEscape(538745, 16, "0:2") .. " Healthstone By Health",
  --   --text = "Healthstone By Health",5512
  --   var = "healthstoneHP",
  --   min = 0,
  --   max = 100,
  --   step = 1,
  --   default = 30,
  --   valueType = "%",
  --   tooltip = "Set the percentage to use Healthstone"
  -- })

  Defensives:Slider({
    text = blink.textureEscape(345231, 16, "0:2") .. " Use Emblem Trinket By Health",
    var = "emblemtrinket",
    min = 0,
    max = 100,
    step = 1,
    default = 35,
    valueType = "%",
    tooltip = "Set the percentage to use Emblem Trinket"
  })

  --! MACROS TAB !--
  local Macros = hunterGroup:Tab(blink.textureEscape(1500870, 15, "0:1") .. " Macros")
  -- lil combustion icon, fires an alert when clicked!
  Macros:Text({
    text = colors.hunter .. "Commands and Macros",
    size = 14,
    paddingBottom = 10,
  })
  
  Macros:Text({
    text = "Using the macros below will Queue the spell on next GCD:",
    size = 10,
    paddingBottom = 10,
  })
  Macros:Text({
    text = "|cFFf7f25cClick on the command to copy it",
    size = 9,
    paddingBottom = 10,
  })

  Macros:Text({
    text = colors.hunter .."General Macros",
    size = 12,
  })
  Macros:Text({
    text = "|cFF43caf7/sr",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr")
    end
  })
  Macros:Text({
    text = "- To Show or Hide the GUI ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7toggle",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr toggle")
    end
  })
  Macros:Text({
    text = "- Turn ON/OFF the routine ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7burst ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr burst")
    end
  })
  Macros:Text({
    text = "- Bursting with your Biggest Cooldowns ",
    paddingBottom = 10,
  })
  -- Macros:Text({
  --   text = "/sr |cFF43caf7resonator target ",
  --   size = 10,
  -- })
  -- Macros:Text({
  --   text = "- Will throw Resonator Trinket to your target ",
  --   paddingBottom = 10,
  -- })
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@unit] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@unit] spell")
    end
  })
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@enemyhealer] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@enemyhealer] spell")
    end
  })  
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@fdps] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@fdps] spell")
    end
  }) 
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "units including: |cFFf7f25ctarget, focus, healer, enemyhealer, party123, arena123, cursor ",
    paddingBottom = 10,
  }) 
  Macros:Text({
    text = "/sr |cFF43caf7pause 1",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr pause 1")
    end
  })
  Macros:Text({
    text = "- Will pause the routine for the giving time (Pause timing: from 1 to 5 Seconds) ",
    paddingBottom = 10,
  }) 
  Macros:Text({
    text = colors.hunter .."Hunter Specific Macros:",
    size = 12,
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7trap focus ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr trap focus")
    end
  })
  Macros:Text({
    text = "- Will Queue Freezing Trap to focus ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7trap arena1,arena2,arena3,enemyhealer ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr trap arena1")
    end
  })
  Macros:Text({
    text = "- Will Queue Freezing Trap to arena1,arena2, arena3 or enemyHealer ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7trap safe ",
    size = 10,
    paddingBottom = 30,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr trap safe")
    end
  })
  Macros:Text({
    text = "|cFFf7f25c\n\n\1-It will check how many times you press the macro.\n\n\1- Pressing it once will let the Routine knows you want to trap the trap unit.\n\n\2- Pressing it twice will bypass all of the checks and throw the trap immediately.\n\n\Trap units can be set from the settings/GUI.",
    --text = "ng it twice wil",   ---Routine will trap your focus or your enemy healer if exists.
    paddingBottom = 50,
  })
  Macros:Text({
    text = "/sr |cFF43caf7scatter toggle ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr scatter toggle")
    end
  })
  Macros:Text({
    text = "- Will Toggle Auto Scatter Shot ON/OFF ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7scatter unit ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr scatter focus")
    end
  })
  Macros:Text({
    text = "- Will Queue Scatter Shot to unit ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7stun target ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr stun target")
    end
  })
  Macros:Text({
    text = "- Will Queue Pet Stun to target ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7stun focus ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr stun focus")
    end
  })
  Macros:Text({
    text = "- Will Queue Pet Stun to focus ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7stun arena1,arena2,arena3,enemyhealer ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr stun arena1")
    end
  })
  Macros:Text({
    text = "- Will Queue Pet Stun to arena1,arena2,arena3 or enemyhealer ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7ros healer ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr ros healer")
    end
  })
  Macros:Text({
    text = "- Will Queue Pet Roar of Sacrifice on your Friendly Healer ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7ros dps ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr ros dps")
    end
  })
  Macros:Text({
    text = "- Will Queue Pet Roar of Sacrifice on your Friendly DPS ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7free toggle ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr free toggle")
    end
  })
  Macros:Text({
    text = "- Will Toggle Auto Masters Call “Freedom” ON/OFF ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7free healer ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr free healer")
    end
  })
  Macros:Text({
    text = "- Will Queue Pet Masters Call “Freedom” on your Friendly Healer ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7free dps ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr free dps")
    end
  })
  Macros:Text({
    text = "- Will Queue Pet Masters Call “Freedom” on your Friendly DPS ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7binding unit ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr binding target")
    end
  })
  Macros:Text({
    text = "- Will Queue Binding Shot to unit ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7pet back ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr pet back")
    end
  })
  Macros:Text({
    text = "- Will move your pets back to you  ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7reset ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr reset")
    end
  })
  Macros:Text({
    text = "- Will [Feign Death] then [Camoflage] ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7disengage forward ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr disengage forward")
    end
  })
  Macros:Text({
    text = "- will disengage forward ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7disengage trap ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr disengage trap")
    end
  })
  Macros:Text({
    text = "- will disengage trap your focus target ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7disengage target ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr disengage target")
    end
  })
  Macros:Text({
    text = "- will disengage to your target ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7disengage focus ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr disengage focus")
    end
  })
  Macros:Text({
    text = "- Will disengage to your focus unit ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7disengage healer ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr disengage healer")
    end
  })
  Macros:Text({
    text = "- Will disengage to your friendly healer ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7disengage enemyhealer ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr disengage enemyhealer")
    end
  })
  Macros:Text({
    text = "- Will disengage to your enemy Healer ",
    paddingBottom = 10,
  })

  -- local Builds = hunterGroup:Tab(blink.textureEscape(1499566, 15, "0:1") .. " Builds")
  -- Builds:Text({
  --   text = colors.hunter .. "Suggested Hunter Builds",
  --   size = 14,
  --   paddingBottom = 10,
  -- })
  -- Builds:Text({
  --   text = blink.textureEscape(19574, 15, "0:1") .. " Beast Mastery with direbeast [|cFFf7f25cClick to copy it|r]",
  --   size = 10,
  --   OnClick = function(self, event)
  --     blink.alert("Copied to clipboard")
  --     blink.call("CopyToClipboard", "B0PAI6Hz82/AvTZSB0bPjW+5YJgWSAoRAAAAAAAAAAAoJJHoIohkEiQEpIkWikQiQiGJkA")
  --   end
  -- })
  -- Builds:Text({
  --   text = blink.textureEscape(19574, 15, "0:1") .. " Beast Mastery without direbeast [|cFFf7f25cClick to copy it|r]",
  --   size = 10,
  --   OnClick = function(self, event)
  --     blink.alert("Copied to clipboard")
  --     blink.call("CopyToClipboard", "B0PAI6Hz82/AvTZSB0bPjW+5YJCaJBgGBAAAAAAAAAAgmkcgigGSSICRkiQaJSCJChGJkA")
  --   end
  -- })
  -- Builds:Text({
  --   text = blink.textureEscape(257044, 15, "0:1") .. " Marksmanship with pet [|cFFf7f25cClick to copy it|r]",
  --   size = 10,
  --   OnClick = function(self, event)
  --     blink.alert("Copied to clipboard")
  --     blink.call("CopyToClipboard", "B4PAI6Hz82/AvTZSB0bPjW+5Y5ABaBgkGCAAAAAIJEJJJSISk0IpRSkCpohkEhEEKAAAAAC")
  --   end
  -- })
  -- Builds:Text({
  --   text = blink.textureEscape(257044, 15, "0:1") .. " Marksmanship without pet [|cFFf7f25cClick to copy it|r]",
  --   size = 10,
  --   OnClick = function(self, event)
  --     blink.alert("Copied to clipboard")
  --     blink.call("CopyToClipboard", "B4PAIlFMjeNhnEouGfV8Ij2uSJBaBABCAAAAAkkQkkkICSk0ikGSSakiGSSESQoAAAAAI")
  --   end
  -- })
  -- Builds:Text({
  --   text = blink.textureEscape(461113, 15, "0:1") .. " Survival [|cFFf7f25cClick to copy it|r]",
  --   size = 10,
  --   OnClick = function(self, event)
  --     blink.alert("Copied to clipboard")
  --     blink.call("CopyToClipboard", "B8PAI6Hz82/AvTZSB0bPjW+5YJgWI5AABBJkEJRiERSkEAAAAAAJJpUEaIJBSQkCAAAAgA")
  --   end
  -- })
end

------------------------------------------------------------------
-- Druid SECTION                                                 -
------------------------------------------------------------------
if sr.druid.ready then

	local druidColor = {255, 124, 10, 1}
	local druidGroup = ui:Group({
    name = blink.textureEscape(625999, 15) .. " Druid",
		title = {blink.textureEscape(625999, 14) .. " Sad", "Druid"},

		colors = {
			title = {blinkCream, druidColor},
			accent = druidColor,
		}
	})
  	--! OPENER TAB !--
  -- local opener = druidGroup:Tab(blink.textureEscape(1822, 12) .. " Opener Mode ")
  -- opener:Dropdown({
  --   var = "openermode",
  --   default = "doublestun",
  --   tooltip = "Select your Opener Mode",
  --   options = {
  --       { label = "Double Stun", value = "doublestun", tooltip = "Rake > FF > MF > Maim" },
  --       { label = "Rake Stun only", value = "rakeonly", tooltip = "Rake > FF > MF > RIP" },
  --   },
  --   placeholder = "Select your Opener Mode",
  --   header = "Opener Mode:",
  --   size = 20,
  -- })
  local offensive = druidGroup:Tab(blink.textureEscape(22568, 15) .. " Offensive ")
  offensive:Text({text = colors.druid .. "Druid Offensive Settings:", header = true})
  offensive:Dropdown({
    var = "mode",
    default = "ON",
    paddingBottom = 10,
    tooltip = "Turn ON/OFF Auto Burst",
    options = {
      { label = "ON", value = "ON", tooltip = "Turn on Auto Burst" },
      { label = "OFF", value = "OFF", tooltip = "Turn off Auto Burst" },
    },
    placeholder = "Select your mode",
    header = "Auto Burst:",
    size = 20,
  })
  offensive:Checkbox({
    text = blink.textureEscape(22568, 16, "0:8") .. " Use Bite to Execute",
    size = 20,
    var = "BiteExecute",
    default = true,
    tooltip = "To enable or disable the routine from using Bite to Execute instead of bleeding.\n\nDisable = Routine will not use Bite to excute your target.",
  })
  --! CONTROL TAB !--
	local control = druidGroup:Tab(blink.textureEscape(33786, 15) .. " Control ")
	control:Text({text = "Druid Crowd control Settings:", header = true})
  control:Checkbox({
    text = blink.textureEscape(22570, 16, "0:8") .. " Auto Maim",
    size = 20,
    --paddingBottom = 5,
    var = "AutoMaim",
    default = true,
    tooltip = "To enable or disable the routine from using Maim upon setups , (enemyhealer in CC) automatically",
  })
  control:Checkbox({
    text = blink.textureEscape(339, 16, "0:8") .. " Enable Auto Root",
    size = 20,
    --paddingBottom = 5,
    var = "AutoRoot",
    default = true,
    tooltip = "To enable or disable the routine from using Entangling Roots on Enemy CD's/kitting/help automatically",
  })
  control:Checkbox({
		text = blink.textureEscape(5211, 16, "0:8") .. " Auto Bash Enemy Healer",
		var = "bashHealer",
		default = true,
		tooltip = "Will full stun enemy healer if you are not attacking them.",
	})
  -- control:Checkbox({
  --   text = blink.textureEscape(58984, 16, "0:8") .. " Auto Shadowmeld to Restun",
  --   size = 20,
  --   --paddingBottom = 5,
  --   var = "automeldrestun",
  --   default = true,
  --   tooltip = "To enable or disable the routine from using Shadowmeld to Restun on opener",
  -- })
  
	--! Defensives TAB !
	local Defensives = druidGroup:Tab(blink.textureEscape(61336, 15) .. " Defensives ")
  Defensives:Text({
    text = "Druid Defensives Settings:", header = true,
    --paddingBottom = 5,
  })

  Defensives:Checkbox({
    text = blink.textureEscape(305497, 16, "0:8") .. " Auto Thorns",
    size = 20,
    --paddingBottom = 5,
    var = "AutoThorns", -- checked bool = saved.test
    default = true,
    tooltip = "To enable or disable the routine from using Thorns if You or Team mate under attack from Melees automatically",
  })
  Defensives:Checkbox({
    text = blink.textureEscape(22812, 16, "0:8") .. " Auto Barkskin",
    size = 20,
    paddingBottom = 5,
    var = "AutoBarkskin", -- checked bool = saved.test
    default = true,
    tooltip = "To enable or disable the routine from using Auto Barkskin if you are stunned and enemys have cds up",
  })
  -- Barkskin sensitivity slider
	Defensives:Slider({
		text = "Barkskin Sensitivity",
		size = 14,
		var = "BarkskinSensitivity",
		min = 0.5,
		max = 1.5,
		step = 0.01,
		default = 1,
		valueType = "x",
		tooltip = "Modifies sensitivity to danger threshold for using Barkskin.\n\nSetting this higher will cause it to use Barkskin more preemptively.\n\nSetting this lower will cause it to hold Barkskin unless you are in a lot of trouble."
	})
  -- auto renewal
  Defensives:Checkbox({
		text = blink.textureEscape(108238, 16, "0:8") .. " Auto Renewal",
		var = "autoRenewal",
		default = true,
		tooltip = "Will automatically use Renewal when in danger.\n\nUses variables like enemy burst, not having a healer or our healer being in cc, us being in a stun etc. to calculate best HP to use it at.",
	})
	-- Renewal sensitivity slider
	Defensives:Slider({
		text = "Renewal Sensitivity",
		size = 14,
		var = "RenewalSensitivity",
		min = 0.5,
		max = 1.5,
		step = 0.01,
		default = 1.2,
		valueType = "x",
		tooltip = "Modifies sensitivity to danger threshold for using Renewal.\n\nSetting this higher will cause it to use Renewal more preemptively.\n\nSetting this lower will cause it to hold Renewal unless you are in a lot of trouble."
	})
  -- auto Instincts
  Defensives:Checkbox({
		text = blink.textureEscape(61336, 16, "0:8") .. " Auto Survival Instincts",
		var = "autoInstincts",
		default = true,
		tooltip = "Will automatically use Instincts when in danger.\n\nUses variables like enemy burst, not having a healer or our healer being in cc, us being in a stun etc. to calculate best HP to use it at.",
	})
	-- Instincts sensitivity slider
	Defensives:Slider({
		text = "Survival Instincts Sensitivity",
		size = 14,
		var = "InstinctsSensitivity",
		min = 0.5,
		max = 1.5,
		step = 0.01,
		default = 0.7,
		valueType = "x",
		tooltip = "Modifies sensitivity to danger threshold for using Survival Instincts.\n\nSetting this higher will cause it to use Survival Instincts more preemptively.\n\nSetting this lower will cause it to hold Survival Instincts unless you are in a lot of trouble."
	})
  -- Defensives:Text({
  --   text = "Defensives Settings:", header = true,
  --   --paddingBottom = 5,
  -- })

  -- Defensives:Slider({
  --   text = blink.textureEscape(61336, 16, "0:2") .. " Use Survival Instincts By Health",
  --   paddingTop = 10,
  --   var = "SurvivalInstincts", 
  --   min = 0,
  --   max = 100,
  --   default = 48,
  --   valueType = "%",
  --   tooltip = "Set the percentage to use Survival Instincts"
  -- })

  -- Defensives:Slider({
  --   text = blink.textureEscape(22812, 16, "0:2") .. " Use Barkskin By Health",
  --   --text = "Use Turtle By Health",
  --   var = "Barkskin", 
  --   min = 0,
  --   max = 100,
  --   default = 50,
  --   valueType = "%",
  --   tooltip = "Set the percentage to use Barkskin"
  -- })

  -- Defensives:Slider({
  -- text = blink.textureEscape(22842, 16, "0:2") .. " Use Frenzied Regeneration By Health",
  -- var = "FrenziedRegeneration", 
  -- min = 0,
  -- max = 100,
  -- default = 45,
  -- valueType = "%",
  -- tooltip = "Set the percentage to use Frenzied Regeneration"
  -- })

  -- Defensives:Slider({
  -- text = blink.textureEscape(538745, 16, "0:2") .. " Healthstone By Health",
  -- var = "healthstoneHP",
  -- min = 0,
  -- max = 100,
  -- step = 1,
  -- default = 30,
  -- valueType = "%",
  -- tooltip = "Set the percentage to use Healthstone"
  -- })
  -- auto Instincts
  Defensives:Checkbox({
		text = blink.textureEscape(22842, 16, "0:8") .. " Auto Frenzied Regeneration",
		var = "FrenziedRegeneration",
		default = true,
		tooltip = "Will automatically use Instincts when in danger.\n\nUses variables like enemy burst, not having a healer or our healer being in cc, us being in a stun etc. to calculate best HP to use it at.",
	})
	-- Instincts sensitivity slider
	Defensives:Slider({
		text = "Frenzied Regeneration Sensitivity",
		size = 14,
		var = "FrenziedRegenerationSensitivity",
		min = 0.5,
		max = 1.5,
		step = 0.01,
		default = 1.0,
		valueType = "x",
		tooltip = "Modifies sensitivity to danger threshold for using Frenzied Regeneration.\n\nSetting this higher will cause it to use Frenzied Regeneration more preemptively.\n\nSetting this lower will cause it to hold Frenzied Regeneration unless you are in a lot of trouble."
	})

  Defensives:Slider({
  text = blink.textureEscape(345231, 16, "0:2") .. " Use Emblem Trinket By Health",
  --text = "Use Emblem Trinket By Health",186868 345231  132344
  var = "emblemtrinket",
  min = 0,
  max = 100,
  step = 1,
  default = 35,
  valueType = "%",
  tooltip = "Set the percentage to use Emblem Trinket"
  })

	--! UTILITY TAB !--
	local utility = druidGroup:Tab(blink.textureEscape(1850, 15) .. " Utility ")
  utility:Text({text = "Druid Utilitys Settings:", header = true})

  utility:Checkbox({
    text = blink.textureEscape(1850, 16, "0:8") .. " Auto Dash",
    size = 20,
    --paddingBottom = 5,
    var = "AutoDash",
    default = true,
    tooltip = "To enable or disable the routine from using Dash to help Gap Gapclose to your target automatically",
  })

  utility:Checkbox({
    text = blink.textureEscape(768, 16, "0:8") .. " Auto Shapeshift",
    size = 20,
    --paddingBottom = 5,
    var = "AutoShift",
    default = true,
    tooltip = "To enable or disable the routine from Shapeshift automatically",
  })

  utility:Checkbox({
    text = blink.textureEscape(106898, 16, "0:8") .. " Auto Stampeding Roar",
    size = 20,
    --paddingBottom = 5,
    var = "AutoStampedingRoar",
    default = true,
    tooltip = "To enable or disable the routine from using Stampeding Roar to help Gap Gapclose to your target automatically",
  })

  utility:Checkbox({
		text = blink.textureEscape(49376, 16, "0:8") .. " Wild Charge Target",
		var = "autoCharge",
		default = true,
		tooltip = "Will automatically WildCharge to target when out of range and moving towards them.",
	})
	utility:Slider({
		text = "Charge Gapclose Pressure Modifier",
		var = "chargeGapcloseMod",
		min = 0.75,
		max = 1.5,
		step = 0.01,
		default = 0.75,
		valueType = "x",
		tooltip = "Modifies sensitivity to our pressure for using WildCharge to gapclose.\n\n\Setting this low will only use WildCharge to gapclose to your target when you have a lot of pressure.\n\nSetting it Higher means it will use WildCharge to gapclose to your target even if you have little pressure"
	})

  --! MACROS TAB !--
  local Macros = druidGroup:Tab(blink.textureEscape(1500870, 15, "0:1") .. " Macros")

  Macros:Text({
    text = colors.druid .. "Commands and Macros",
    size = 14,
    paddingBottom = 10,
  })

  Macros:Text({
    text = "Using the macros below will Queue the spell on next GCD:",
    size = 10,
    paddingBottom = 10,
  })
  Macros:Text({
    text = "|cFFf7f25cClick on the command to copy it",
    size = 9,
    paddingBottom = 10,
  })
  Macros:Text({
    text = colors.druid .."General Macros ",
    size = 12,
  })
  Macros:Text({
    text = "|cFF43caf7/sr",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr")
    end
  })
  Macros:Text({
    text = "- To Show or Hide the GUI ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7toggle",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr toggle")
    end
  })
  Macros:Text({
    text = "- Turn ON/OFF the routine ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7burst ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr burst")
    end
  })
  Macros:Text({
    text = "- Bursting with your Biggest Cooldowns ",
    paddingBottom = 10,
  })
  -- Macros:Text({
  --   text = "/sr |cFF43caf7resonator target ",
  --   size = 10,
  -- })
  -- Macros:Text({
  --   text = "- Will throw Resonator Trinket to your target ",
  --   paddingBottom = 10,
  -- })
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@unit] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@unit] spell")
    end
  })
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@enemyhealer] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@enemyhealer] spell")
    end
  })  
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@fdps] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@fdps] spell")
    end
  }) 
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "units including: |cFFf7f25ctarget, focus, healer, enemyhealer, party123, arena123, cursor ",
    paddingBottom = 10,
  }) 
  Macros:Text({
    text = "/sr |cFF43caf7pause 1",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr pause 1")
    end
  })
  Macros:Text({
    text = "- Will pause the routine for the giving time (Pause timing: from 1 to 5 Seconds) ",
    paddingBottom = 10,
  }) 
  Macros:Text({
    text = colors.druid .."Druid Specific Macros:",
    size = 12,
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7maim target ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr maim target")
    end
  })
  Macros:Text({
    text = "- Will Queue maim on your target",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7maim focus ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr maim focus")
    end
  })
  Macros:Text({
    text = "- Will Queue maim on your focus",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7maim arena1,arena2,arena3 ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr maim arena1")
    end
  })
  Macros:Text({
    text = "- Will Queue maim on your arena1 or 2 or 3",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7bash target ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr bash target")
    end
  })
  Macros:Text({
    text = "- Will Queue bash on your target",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7bash focus ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr bash focus")
    end
  })
  Macros:Text({
    text = "- Will Queue bash on your focus",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7bash arena1,arena2,arena3 ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr bash arena1")
    end
  })
  Macros:Text({
    text = "- Will Queue bash on your arena1 or 2 or 3",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7clone target ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr clone target")
    end
  })
  Macros:Text({
    text = "- Will Queue Cyclone on your target",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7clone focus ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr clone focus")
    end
  })
  Macros:Text({
    text = "- Will Queue Cyclone on your focus",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7clone arena1,arena2,arena3 ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr clone arena1")
    end
  })
  Macros:Text({
    text = "- Will Queue Cyclone on your arena1,2 or 3",
    paddingBottom = 10,
  })

  -- local Builds = druidGroup:Tab(blink.textureEscape(1499566, 15, "0:1") .. " Builds")
  -- Builds:Text({
  --   text = colors.druid .. "Suggested Feral Builds",
  --   size = 14,
  --   paddingBottom = 10,
  -- })
  -- -- Builds:Text({
  -- --   text = blink.textureEscape(22568, 15, "0:1") .. " Single Target Build [|cFFf7f25cClick to copy it|r]",
  -- --   size = 10,
  -- --   OnClick = function(self, event)
  -- --     blink.alert("Copied to clipboard")
  -- --     blink.call("CopyToClipboard", "BcGAYhlYdy9RJ6ROrphOEi69vCAAAAAAQIlUkIRSkUSjokkEHIJAAAAAAoIAIASSikkESi0SAOAAAAAAAIBA")
  -- --   end
  -- -- })
  -- Builds:Text({
  --   text = blink.textureEscape(3578197, 15, "0:1") .. " Feral Build [|cFFf7f25cClick to copy it|r]",
  --   size = 10,
  --   OnClick = function(self, event)
  --     blink.alert("Copied to clipboard")
  --     blink.call("CopyToClipboard", "BcGAjgO5l4zUDkYE8W5/Dtff2BAAAAAAg0QSakkkUSLiSSScgkAAAAAAIFAkESQSikECJhWCwBAAAAAAgEAgA")
  --   end
  -- })
end

------------------------------------------------------------------
-- Paladin SECTION                                               -
------------------------------------------------------------------
if sr.paladin.ready then

  local paladinColor = {244, 140, 186, 1}
	local paladinGroup = ui:Group({
    name = blink.textureEscape(626003, 15) .. " Paladin",
		title = {blink.textureEscape(626003, 14) .. " Sad", "Paladin"},

		colors = {
			title = {blinkCream, paladinColor},
			accent = paladinColor,
		}
	})

  local offensive = paladinGroup:Tab(blink.textureEscape(31884, 15) .. " Offensive ")
  offensive:Text({text = colors.paladin .. "Paladin Offensive Settings:", header = true})
  offensive:Dropdown({
    var = "mode",
    default = "ON",
    paddingBottom = 10,
    tooltip = "Turn ON/OFF Auto Burst",
    options = {
      { label = "ON", value = "ON", tooltip = "Turn on Auto Burst" },
      { label = "OFF", value = "OFF", tooltip = "Turn off Auto Burst" },
    },
    placeholder = "Select your mode",
    header = "Auto Burst:",
    size = 20,
  })
  offensive:Checkbox({
    text = blink.textureEscape(255937, 15, "0:8") .. " Auto Use Wake of Ashes",
    size = 14,
    paddingBottom = 10,
    var = "autoAshes",
    default = true,
    tooltip = "Auto Use Wake of Ashes.",

  })

  local control = paladinGroup:Tab(blink.textureEscape(853, 15) .. " Control ")
	control:Text({text = "Paladin Crowd control Settings:", header = true})

  control:Checkbox({
    text = blink.textureEscape(853, 15, "0:8") .. " Auto Use Hammer of Justice on Enemy Healer",
    size = 14,
    paddingBottom = 10,
    var = "hojHealer",
    default = false,
    tooltip = "Auto Use Hammer of Justice on Enemy Healer if enemies health less than 70%",

  })

  control:Checkbox({
    text = blink.textureEscape(853, 15, "0:8") .. " Auto Use Hammer of Justice on target",
    size = 14,
    paddingBottom = 10,
    var = "hojTarget",
    default = true,
    tooltip = "Auto Use Hammer of Justice on target if enemy healer CCed",
    
  })

  local utility = paladinGroup:Tab(blink.textureEscape(1044, 15) .. " Utility")
	utility:Text({text = "Paladin utility Settings:", header = true})

  utility:Checkbox({
    text = blink.textureEscape(1044, 15, "0:8") .. " Auto Use Blessing of freedom",
    size = 14,
    paddingBottom = 10,
    var = "AutoFreedom",
    default = true,
    tooltip = "Auto Use Blessing of freedom",
    
  })

  -- utility:Slider({
	-- 	text = "Blessing of freedom Gapclose Pressure Modifier",
	-- 	var = "freedomSensitivity",
	-- 	min = 0.75,
	-- 	max = 1.5,
	-- 	step = 0.01,
	-- 	default = 1,
	-- 	valueType = "x",
	-- 	tooltip = "Modifies sensitivity to our pressure for using Blessing of freedom to gapclose.\n\n\Lower = only use Blessing of freedom to gapclose our target when we have a lot of pressure.\n\nHigher = use Blessing of freedom to gapclose our target even when we have very little pressure."
	-- })


  utility:Checkbox({
    text = blink.textureEscape(190784, 15, "0:8") .. " Auto Use Divine Steed",
    size = 14,
    paddingBottom = 10,
    var = "AutoSteed",
    default = true,
    tooltip = "Auto Use Divine Steed",
    
  })

  utility:Slider({
		text = "Divine Steed Gapclose Pressure Modifier",
		var = "steedSensitivity",
		min = 0.75,
		max = 1.5,
		step = 0.01,
		default = 1,
		valueType = "x",
		tooltip = "Modifies sensitivity to our pressure for using Divine Steed to gapclose.\n\n\Lower = only use Divine Steed to gapclose our target when we have a lot of pressure.\n\nHigher = use Divine Steed to gapclose our target even when we have very little pressure."
	})


	--! Defensives TAB !--
	local Defensives = paladinGroup:Tab(blink.textureEscape(1022, 15) .. " Defensives ")
  Defensives:Text({
    text = "Paladin Defensives Settings:", header = true,
    --paddingBottom = 5,
  })
  Defensives:Checkbox({
    text = blink.textureEscape(19750, 15, "0:8") .. " Use healings spells on player only in BGs",
    size = 14,
    paddingBottom = 10,
    var = "selfishHeal",
    default = true,
    tooltip = "Use healings spells on player only in BGs.",
  })
  Defensives:Checkbox({
    text = blink.textureEscape(6940, 15, "0:8") .. " Auto Blessing of Sacrifice incoming CC",
    size = 14,
    paddingBottom = 10,
    var = "AutoSacCC",
    default = true,
    tooltip = "Auto Blessing of Sacrifice incoming CC on player.",
  })
  Defensives:Checkbox({
    text = blink.textureEscape(6940, 15, "0:8") .. " Auto Blessing of Sacrifice Friends",
    size = 14,
    paddingBottom = 10,
    var = "AutoSacFriendly",
    default = true,
    tooltip = "Auto Blessing of Sacrifice Friends.",
  })
  Defensives:Checkbox({
    text = blink.textureEscape(210256, 15, "0:8") .. " Use Blessing of Sanctuary on Friendly Healer only",
    size = 14,
    paddingBottom = 10,
    var = "SancHealeronly",
    default = false,
    tooltip = "force the routine to Use Blessing of Sanctuary on Friendly Healer only",
  })
  -- Defensives:Slider({
  -- --paddingTop = 55,
  -- text = "Sanc Delay",
  -- var = "SancDelay",
  -- min = 0.1,
  -- max = 1,
  -- step = 0.1,
  -- default = 0.3,
  -- valueType = "s",
  -- tooltip = "Delay Blessing of Sanctuary usage (in seconds)\n\nAverage human reaction time is ~0.3ms."
  -- })

  Defensives:Checkbox({
    text = blink.textureEscape(1022, 15, "0:8") .. " Blessing of Protection (Karma)",
    size = 14,
    paddingBottom = 10,
    var = "BopKarma",
    default = true,
    tooltip = "force the routine to Use Blessing of Protection on Friendly effected by enemy Monk (Touch of Karma)",
  })

  Defensives:Checkbox({
    text = blink.textureEscape(1022, 15, "0:8") .. " Use Blessing of Protection on Friendly Healer if (Blinded)",
    size = 14,
    paddingBottom = 10,
    var = "BopHealerBlind",
    default = true,
    tooltip = "force the routine to Use Blessing of Protection on Friendly Healer if he is (Blinded)",
  })

  Defensives:Slider({
    text = blink.textureEscape(1022, 16, "0:2") .. " Use Blessing of Protection By Health",
    var = "BOPSensitivity",
    min = 0,
    max = 100,
    default = 25,
    valueType = "%",
    tooltip = "Set the percentage to use Blessing of Protection"
  })

  Defensives:Slider({
    text = blink.textureEscape(633, 16, "0:2") .. " Use Lay on Hands By Health",
    var = "LayonhandSensitivity",
    min = 0,
    max = 100,
    default = 13,
    valueType = "%",
    tooltip = "Set the percentage to use Lay on Hands"
  
  })

  Defensives:Slider({
    text = blink.textureEscape(204018, 16, "0:2") .. " Use Blessing of Spellwarding by Health",
    var = "WardingSensitivity",
    min = 0,
    max = 100,
    default = 25,
    valueType = "%",
    tooltip = "Set the percentage to use Blessing of Spellwarding"
  
  })

  Defensives:Slider({
    text = blink.textureEscape(642, 16, "0:2") .. " Use Bubble By Health",
    --text = "Use Bubble By Health",
    var = "BubbleSensitivity",
    min = 0,
    max = 100,
    default = 28,
    valueType = "%",
    tooltip = "Set the percentage to use Bubble"
  
  })
  
  Defensives:Checkbox({
    text = blink.textureEscape(19750, 15, "0:8") .. " Auto Flash of Heal",
    size = 14,
    paddingBottom = 10,
    var = "AutoFlash",
    default = true,
    tooltip = "Enable the routine to use Flash of Heal",
  })

	Defensives:Slider({
		text = "Flash of Heal Sensitivity",
		var = "FlashSensitivity",
		min = 0,
		max = 100,
		step = 0.1,
		default = 80,
		valueType = "%",
		tooltip = "Set the percentage to use."
	})

  Defensives:Checkbox({
    text = blink.textureEscape(85673, 15, "0:8") .. " Auto Word of Glory",
    size = 14,
    paddingBottom = 10,
    var = "AutoWOG",
    default = true,
    tooltip = "Enable the routine to use Word of Glory",
  })

	Defensives:Slider({
		text = "Word of Glory Sensitivity",
		var = "WOGSensitivity",
		min = 0,
		max = 100,
		step = 0.1,
		default = 35,
		valueType = "%",
		tooltip = "Set the percentage to use."
	})

  Defensives:Checkbox({
    text = blink.textureEscape(184662, 15, "0:8") .. " Auto Shield of Vengeance",
    size = 14,
    paddingBottom = 10,
    var = "AutoSOV",
    default = true,
    tooltip = "Enable the routine to use Shield of Vengeance",
  })

	Defensives:Slider({
		text = "Shield of Vengeance Sensitivity",
		var = "SOVSensitivity",
		min = 0,
		max = 100,
		step = 0.1,
		default = 80,
		valueType = "%",
		tooltip = "Set the percentage to use."
	})

  Defensives:Checkbox({
    text = blink.textureEscape(498, 15, "0:8") .. " Auto Divine Protection",
    size = 14,
    paddingBottom = 10,
    var = "AutoDP",
    default = true,
    tooltip = "Enable the routine to use Divine Protection",
  })
  Defensives:Slider({
		text = "Divine Protection Sensitivity",
		var = "dPSensitivity",
		min = 0,
		max = 100,
		step = 0.1,
		default = 70,
		valueType = "%",
		tooltip = "Set the percentage to use."
	})

  Defensives:Slider({
    text = blink.textureEscape(345231, 16, "0:2") .. " Use Emblem Trinket By Health",
    var = "emblemtrinket",
    min = 0,
    max = 100,
    step = 1,
    default = 35,
    valueType = "%",
    tooltip = "Set the percentage to use Emblem Trinket"
  })

  local Macros = paladinGroup:Tab(blink.textureEscape(1500870, 15, "0:1") .. " Macros")

  Macros:Text({
    text = colors.paladin .. "Commands and Macros",
    size = 14,
    paddingBottom = 10,
  })

  Macros:Text({
    text = "Using the macros below will Queue the spell on next GCD:",
    size = 10,
    paddingBottom = 10,
  })
  Macros:Text({
    text = "|cFFf7f25cClick on the command to copy it",
    size = 9,
    paddingBottom = 10,
  })
  Macros:Text({
    text = colors.paladin .."General Macros ",
    size = 12,
  })
  Macros:Text({
    text = "|cFF43caf7/sr",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr")
    end
  })
  Macros:Text({
    text = "- To Show or Hide the GUI ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7toggle",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr toggle")
    end
  })
  Macros:Text({
    text = "- Turn ON/OFF the routine ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7burst ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr burst")
    end
  })
  Macros:Text({
    text = "- Bursting with your Biggest Cooldowns ",
    paddingBottom = 10,
  })
  -- Macros:Text({
  --   text = "/sr |cFF43caf7resonator target ",
  --   size = 10,
  -- })
  -- Macros:Text({
  --   text = "- Will throw Resonator Trinket to your target ",
  --   paddingBottom = 10,
  -- })
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@unit] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@unit] spell")
    end
  })
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@enemyhealer] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@enemyhealer] spell")
    end
  })  
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@fdps] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@fdps] spell")
    end
  }) 
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "units including: |cFFf7f25ctarget, focus, healer, enemyhealer, party123, arena123, cursor ",
    paddingBottom = 10,
  }) 
  Macros:Text({
    text = "/sr |cFF43caf7pause 1",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr pause 1")
    end
  })
  Macros:Text({
    text = "- Will pause the routine for the giving time (Pause timing: from 1 to 5 Seconds) ",
    paddingBottom = 10,
  }) 
  Macros:Text({
    text = colors.paladin .."Paladin Specific Macros:",
    size = 12,
    paddingBottom = 10,
  })

  Macros:Text({
    text = "/sr |cFF43caf7hoj unit ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr hoj focus")
    end
  })
  Macros:Text({
    text = "- Will Queue Hammer of Justice on your target,focus,arena123",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7blind unit",
    size = 10,
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr hoj focus")
    end
  })
  Macros:Text({
    text = "- Will Queue Blinding Light on your target,focus,arena123.",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7free unit",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr free player")
    end
  })
  Macros:Text({
    text = "- Will Queue Blessing of Freedom on units: |cFFf7f25cplayer,fdps,healer",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7steed",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr steed")
    end
  })
  Macros:Text({
    text = "- Will Queue Divine Steed once and will not use it again until the buff is gone",
    paddingBottom = 10,
  })

end

if sr.priest.ready then

  local priestColor = {255, 255, 255}
	local priestGroup = ui:Group({
    name = blink.textureEscape(626004, 15) .. " Priest",
		title = {blink.textureEscape(626004, 14) .. " Sad", "Priest"},

		colors = {
			title = {blinkCream, priestColor},
			accent = priestColor,
		}
	})

  local utility = priestGroup:Tab(blink.textureEscape(58984, 15) .. " Utility ")
  utility:Text({text = colors.priest .. "Priest Utilitys Settings:", header = true})
  -- utility:Slider({
	-- 	text = blink.textureEscape(32379, 16) .. " Max GCD Hold Duration To Death",
	-- 	var = "maxGCDHold",
	-- 	min = 0,
	-- 	max = 7.5,
	-- 	step = 0.1,
	-- 	default = 3,
	-- 	valueType = "sec.",
	-- 	tooltip = "Set max duration (in seconds) to hold GCDs when conditions indicate."
	-- })
  utility:Checkbox({
    text = blink.textureEscape(58984, 16, "0:8") .. " Enable Auto Shadowmeld events",
    size = 14,
    paddingBottom = 10,
    var = "AutoMeld",
    default = true,
    tooltip = "To enable or disable the routine from using Shadowmeld to counter enemies.\n\n\will meld stormbolts/coil/the hunt etc.",
    
  })
  local healing = priestGroup:Tab(blink.textureEscape(17, 15) .. " Healing ")
  if currentSpec == 1 then 
    healing:Text({text = "Priest Healing Settings:", header = true})
    healing:Slider({
      text = blink.textureEscape(2061, 16, "0:2") .. " Flash Heal",
      var = "FlashHeal",
      min = 0,
      max = 100,
      step = 1,
      default = 80,
      valueType = "%",
      tooltip = "Set the percentage to cast Flash Heal"
    })
    healing:Slider({
      text = blink.textureEscape(47540, 16, "0:2") .. " Penance",
      var = "PenanceHeal",
      min = 0,
      max = 100,
      step = 1,
      default = 75,
      valueType = "%",
      tooltip = "Set the percentage to cast Penance"
    })
    healing:Slider({
      text = blink.textureEscape(194509, 16, "0:2") .. " Radiance",
      var = "RadianceHeal",
      min = 0,
      max = 100,
      step = 1,
      default = 40,
      valueType = "%",
      tooltip = "Set the percentage to cast Radiance"
    })
    healing:Slider({
      text = blink.textureEscape(47536, 16, "0:2") .. " Rapture",
      var = "RaptureHeal",
      min = 0,
      max = 100,
      step = 1,
      default = 75,
      valueType = "%",
      tooltip = "Set the percentage to cast Rapture"
    })
    healing:Checkbox({
      text = blink.textureEscape(62618, 16, "0:8") .. " Use Barrier on enemy CD's",
      var = "AutoSmartBarrier",
      paddingBottom = 6,
      default = true,
      tooltip = "will trade Barrier on enemy cds.",
    })
    healing:Slider({
      text = blink.textureEscape(62618, 16, "0:2") .. " Power Word: Barrier",
      var = "BarrierHeal",
      min = 0,
      max = 100,
      step = 1,
      default = 65,
      valueType = "%",
      tooltip = "Set the percentage to cast Power Word: Barrier"
    })
    healing:Checkbox({
      text = blink.textureEscape(33206, 16, "0:8") .. " Use Pain Suppression on enemy CD's",
      var = "AutoSmartPS",
      paddingBottom = 6,
      default = true,
      tooltip = "will trade Pain Suppression on enemy cds..",
    })
    healing:Slider({
      text = blink.textureEscape(33206, 16, "0:2") .. " Pain Suppression",
      var = "PSHeal",
      min = 0,
      max = 100,
      step = 1,
      default = 30,
      valueType = "%",
      tooltip = "Set the percentage to cast Pain Suppression"
    })
    healing:Slider({
      text = blink.textureEscape(108968, 16, "0:2") .. " Void Shift",
      var = "VoidShift",
      min = 0,
      max = 100,
      step = 1,
      default = 20,
      valueType = "%",
      tooltip = "Set the percentage to cast Void Shift"
    })
  --Holy  
  elseif currentSpec == 2 then
    healing:Slider({
      text = blink.textureEscape(2061, 16, "0:2") .. " Flash Heal",
      var = "FlashHeal",
      min = 0,
      max = 100,
      step = 1,
      default = 70,
      valueType = "%",
      tooltip = "Set the percentage to cast Flash Heal"
    })
    healing:Slider({
      text = blink.textureEscape(2060, 16, "0:2") .. " Heal",
      var = "heal",
      min = 0,
      max = 100,
      step = 1,
      default = 90,
      valueType = "%",
      tooltip = "Set the percentage to cast Heal"
    })
    healing:Slider({
      text = blink.textureEscape(2050, 16, "0:2") .. " Serenity",
      var = "serenityHeal",
      min = 0,
      max = 100,
      step = 1,
      default = 60,
      valueType = "%",
      tooltip = "Set the percentage to cast Serenity"
    })
    healing:Slider({
      text = blink.textureEscape(47788, 16, "0:2") .. " Guardian Spirit",
      var = "guardianSpirit",
      min = 0,
      max = 100,
      step = 1,
      default = 30,
      valueType = "%",
      tooltip = "Set the percentage to cast Guardian Spirit"
    })
    healing:Slider({
      text = blink.textureEscape(108968, 16, "0:2") .. " Void Shift",
      var = "VoidShift",
      min = 0,
      max = 100,
      step = 1,
      default = 22,
      valueType = "%",
      tooltip = "Set the percentage to cast Void Shift"
    })
  end
    
end

if sr.rogue.ready then

  local rogueColor = {255, 244, 104}
	local rogueGroup = ui:Group({
		name = "Rogue",
		title = {"Sad", "Rogue"},

		colors = {
			title = {blinkCream, rogueColor},
			accent = rogueColor,
		}
	})

  local control = rogueGroup:Tab(blink.textureEscape(853, 15) .. " Control ")
	control:Text({text = "Rogue Crowd control Settings:", header = true})

end


if sr.warrior.ready then

  local warriorColor = {198, 155, 109}
	local warriorGroup = ui:Group({
		name = blink.textureEscape(626008, 15) .. " Warrior",
		title = {blink.textureEscape(626008, 14) .. " Sad ", "Warrior"},

		colors = {
			title = {blinkCream, warriorColor},
			accent = warriorColor,
		}
	})

  local offensive = warriorGroup:Tab(blink.textureEscape(107574, 15) .. " Offensive ")
	offensive:Text({
    text = colors.warrior .. "Warrior Offensive Settings:", 
    header = true,
    paddingBottom = 12
  })
  offensive:Dropdown({
    var = "mode",
    default = "ON",
    paddingBottom = 10,
    tooltip = "Turn ON/OFF Auto Burst",
    options = {
      { label = "ON", value = "ON", tooltip = "Turn on Auto Burst" },
      { label = "OFF", value = "OFF", tooltip = "Turn off Auto Burst" },
    },
    placeholder = "Select your mode",
    header = "Auto Burst:",
    size = 20,
  })
  offensive:Text({text = blink.textureEscape(46924, 16) .. " Auto Bladestorm Settings:", header = true})
  offensive:Checkbox({
		text = "Bladestorm Unhinged",
		var = "bladestormUnhinged",
    paddingBottom = 6,
		default = true,
		tooltip = "Use bladestorm when Sharpen up (Unhinged).",
	})
  offensive:Checkbox({
		text = "Bladestorm Enemy Roots         ",
		var = "bladestormRoots",
    paddingBottom = 6,
		default = false,
		tooltip = "Use bladestorm to get out of roots.",
	})
	-- offensive:Checkbox({
	-- 	text = "Auto Burst",
	-- 	var = "autoBurst",
	-- 	default = false,
	-- 	tooltip = "Automatically use burst.\n\nWill try to only do it during good conditions, but it's recommended to use burst manually.",
	-- })
	-- auto spear on burst key
	-- offensive:Checkbox({
	-- 	text = "Spear on Burst",
	-- 	var = "autoSpear",
	-- 	default = true,
	-- 	tooltip = "Routine Will auto use spear on burst.",
	-- })
	-- cleave slider # of nearby players to prio whirlwind
	-- offensive:Slider({
	-- 	text = "Cleave Threshold",
	-- 	var = "cleaveCount",
	-- 	min = 2,
	-- 	max = 5,
	-- 	default = 3,
	-- 	valueType = " players",
	-- 	tooltip = "Number of players that must be around for the routine to prioritize getting whirlwind stacks to maximize cleave damage."
	-- })
	-- offensive:Slider({
	-- 	text = "Auto Spear # Players",
	-- 	var = "autoSpearCount",
	-- 	min = 2,
	-- 	max = 5,
	-- 	default = 3,
	-- 	valueType = " players",
	-- 	tooltip = "Routine will auto spear when it can hit this many players at once."
	-- })
	-- offensive:Slider({
	-- 	text = blink.colors.dk.."DK|r Offensive Disarm Modifier",
	-- 	size = 14,
	-- 	var = "dkOffensiveDisarmSens",
	-- 	min = 0.75,
	-- 	max = 1.25,
	-- 	step = 0.01,
	-- 	default = 1,
	-- 	valueType = "x",
	-- 	tooltip = "Modifies sensitivity to offensive disarm vs DK.\n\nIt is already set to only use disarm on DK when they are in extreme danger.\n\nSetting this higher will cause it to use disarm offensively against DK at higher HP.\n\nSetting this lower will cause it to disarm DK at much lower HP."
	-- })
	-- auto charge gapclose
	-- auto leap gapclose
	-- bladestorm on burst key
	-- offensive:Checkbox({
	-- 	text = "Signet Bladestorm",
	-- 	var = "bsOnBurst",
	-- 	default = true,
	-- 	tooltip = "Will prio Bladestorm over reck on burst with Signet of Tormented Kings leggo if we are below 65 rage and have at least 2.5s of enrage.",
	-- })
	-- offensive:Checkbox({
	-- 	text = "Signet Storm on Reck Proc",
	-- 	var = "ssReckProc",
	-- 	default = false,
	-- 	tooltip = "Will auto Bladestorm on reck proc with Signet of Tormented Kings leggo and Reckless Abandon talented.\n\nThis will guarantee we get the empowered crushing blow / bloodthirst for signet recklessness.",
	-- })
	-- offensive:Checkbox({
	-- 	text = "Maximize Reck",
	-- 	var = "raRefund",
	-- 	default = false,
	-- 	tooltip = "Will wait for <65 energy when playing reckless abandon, or at least 2.5s of Enrage up before using Recklesness on burst key.",
	-- })
	-- -- -- auto stormbolt
	-- -- offensive:Checkbox({
	-- -- 	text = "Auto Storm Bolt",
	-- -- 	var = "autoStormBolt",
	-- -- 	default = true,
	-- -- 	tooltip = "Will automatically use storm bolt before burst, or in relatively good conditions where target is off stun dr and we have some cc on the healer.",
	-- -- })
	-- offensive:Checkbox({
	-- 	text = "Bloodrage on CD",
	-- 	var = "bloodrageOnCD",
	-- 	default = false,
	-- 	tooltip = "Will spam bloodrage on cd when not capping out on rage, instead of saving it for cds/roots/slows.",
	-- })
	-- offensive:Checkbox({
	-- 	text = "Never Whirlwind",
	-- 	var = "neverWhirlwind",
	-- 	default = true,
	-- 	tooltip = "Will only use fallthrough whirlwind when you have no raging blows to use.",
	-- })
	-- offensive:Slider({
	-- 	text = "Death Wish | "..blink.colors.pink.."Pussy Slider",
	-- 	var = "pussyPct",
	-- 	min = 0,
	-- 	max = 100,
	-- 	default = 69,
	-- 	valueType = "% pussy",
	-- 	tooltip = "Percentage of a pussy you are when it comes to death wish.\n\nLower pussy percentage will result in more death wish usage, prioritizing brutally murdering your enemies over living.\n\nHigher pussy percentage will result in less death wish usage, resulting in a longer life but significantly less bitches/fame/money/power/KDA."
	-- })

  local defensive = warriorGroup:Tab(blink.textureEscape(386208, 15) .. " Defensive ")
	defensive:Text({
    text = colors.warrior .. "Warrior Defensive Settings:", 
    header = true,
    --paddingBottom = 12,
  })
	-- -- auto enraged
	-- defensive:Checkbox({
	-- 	text = "Auto Regen",
	-- 	var = "autoRegen",
	-- 	default = true,
	-- 	tooltip = "Will automatically use regen when in danger.\n\nUses variables like enemy burst, not having a healer or our healer being in cc, us being in a stun etc. to calculate best HP to use it at.",
	-- })
	-- -- auto aegis
	-- defensive:Checkbox({
	-- 	text = "Auto Aegis",
	-- 	var = "autoAegis",
	-- 	default = true,
	-- 	tooltip = "Will automatically use aegis trinket when in danger.\n\nUses variables like enemy burst, not having a healer or our healer being in cc, us being in a stun etc. to calculate best HP to use it at.\n\nVs. DK will use it on abom limb.",
	-- })
	-- defensive:Checkbox({
	-- 	text = "Auto Fleshcraft",
	-- 	var = "autoFlesh",
	-- 	default = true,
	-- 	tooltip = "Will automatically use fleshcraft.",
	-- })
	-- -- regen / aegis sensitivity slider thing
	-- defensive:Slider({
	-- 	text = "Enraged Regen Sensitivity",
	-- 	size = 14,
	-- 	var = "regenSensitivity",
	-- 	min = 0.5,
	-- 	max = 1.5,
	-- 	step = 0.01,
	-- 	default = 1,
	-- 	valueType = "x",
	-- 	tooltip = "Modifies sensitivity to danger threshold for using enraged regen.\n\nSetting this higher will cause it to use enraged regen more preemptively.\n\nSetting this lower will cause it to hold regen unless we are in a lot of trouble."
	-- })
	-- rally sensitivity slider
	-- disarm cds
	-- defensive disarm slider
	-- defensive fear slider
	-- ignore pain hp% slider
  --defensive:Text({text = blink.textureEscape(3411, 16) .. " Auto Intervene Settings:", header = true})
	-- pre-intervene cc
	defensive:Checkbox({
		text = blink.textureEscape(3411, 16, "0:8") .. " Auto Intervene",
    paddingBottom = 50,
		var = "autoIntervene",
		default = true,
		tooltip = "Routine Will Auto Intervenes.",
	})
  defensive:Slider({
		text = blink.textureEscape(386208, 15) .. " Defensive Stance Sensitivity",
		var = "DSensitivity",
    paddingTop = 10,
		min = 10,
		max = 100,
		step = 1,
		default = 70,
		valueType = "%",
		tooltip = "Set Defensive Stance HP."
	})
  defensive:Slider({
		text = blink.textureEscape(118038, 15) .. " Die by the Sword Sensitivity",
		var = "DBTSSensitivity",
		min = 10,
		max = 100,
		step = 1,
		default = 35,
		valueType = "%",
		tooltip = "Set Die by the Sword HP."
	})
	defensive:Checkbox({
		text = blink.textureEscape(97462, 15, "0:8") ..  " Auto Rally",
		var = "autoRally",
		default = true,
		tooltip = "Routine Will automatically use rally when you or a teammate are in danger.",
	})
	defensive:Slider({
		text = "Auto Rally HP",
		var = "rallyHP",
		min = 10,
		max = 80,
		step = 1,
		default = 25,
		valueType = "%",
		tooltip = "Set Auto Rally HP"
	})
  defensive:Checkbox({
		text = blink.textureEscape(383762, 15, "0:8") .. " Auto Bitter Immunity",
		var = "bitter",
		default = true,
		tooltip = "Use Auto Bitter Immunity."
  })
	defensive:Slider({
		text = "Auto Bitter Immunity Sensitivity",
		var = "bitterHP",
		min = 10,
		max = 100,
		step = 1,
		default = 35,
		valueType = "%",
		tooltip = "Set the HP threshold for Bitter Immunity."
	})
  defensive:Slider({
		text = blink.textureEscape(190456, 15) .. " Ignore Pain Sensitivity",
		var = "IgnorePainSensitivity",
		min = 10,
		max = 100,
		step = 1,
		default = 80,
		valueType = "%",
		tooltip = "Set the HP threshold for Bitter Ignore Pain."
	})
	-- defensive:Slider({
	-- 	text = blink.colors.dk.."DK|r Defensive Disarm Modifier",
	-- 	size = 14,
	-- 	var = "dkDisarmSens",
	-- 	min = 0.75,
	-- 	max = 1.25,
	-- 	step = 0.01,
	-- 	default = 1,
	-- 	valueType = "x",
	-- 	tooltip = "Modifies sensitivity to defensive disarm vs DK.\n\nIt is already set to only use disarm on DK in extreme danger.\n\nSetting this higher will cause it to use disarm defensively against DK more frequently.\n\nSetting this lower will cause it to only disarm a DK offensively, or if we are in a LOT of trouble."
	-- })
  local utility = warriorGroup:Tab(blink.textureEscape(100, 15) .. " Utility ")
	utility:Text({
    text = colors.warrior .. "Warrior Utility Settings:", 
    header = true,
    --paddingBottom = 12,
  })

	-- utility:Checkbox({
	-- 	text = "Healer Line",
	-- 	var = "healerLine",
	-- 	default = true,
	-- 	tooltip = "Draws a line to your healer to help you stay aware of their positioning and whether or not you're out of range / LoS.",
	-- })
  utility:Checkbox({
		text = blink.textureEscape(64382, 15, "0:8") .. " Lock Movment to Shattering Throw",
		var = "moveLockForShatter",
    paddingTop = 10,
		default = false,
		tooltip = "Routine Will lock your movment to Shattering Throw enemy bubble/block/etc.",
	})
  utility:Checkbox({
		text = blink.textureEscape(236320, 15, "0:8") .. " Auto War Banner incoming CC",
		var = "autoWarBanner",
    paddingTop = 10,
		default = true,
		tooltip = "Routine Will Auto War Banner incoming CC to you or your healer.",
	})
	-- utility:Checkbox({
	-- 	text = "Meme Storm",
	-- 	var = "bladestormBM",
	-- 	default = false,
	-- 	tooltip = "Rub salt in the wounds by sending a /laugh at your enemies when you pre-bladestorm their instant cc",
	-- })
	-- utility:Slider({
	-- 	text = "Max GCD Hold Duration",
	-- 	var = "maxGCDHold",
	-- 	min = 0,
	-- 	max = 7.5,
	-- 	step = 0.1,
	-- 	default = 3,
	-- 	valueType = "sec.",
	-- 	tooltip = "Set max duration (in seconds) to hold GCDs when conditions indicate pre-bladestorming instant CC is possible. This counter resets between stun DR on yourself, or every 20sec.\n\nSet to 0 to never hold GCD, basically disabling pre-cc bladestorms, since there is probably <1% chance you will be off GCD when you get stunned / blinded / etc."
	-- })
  utility:Text({text = blink.textureEscape(100, 16) .. " Auto Charge Settings:", header = true})
  -- control:Checkbox({
  --   text = " Enable Auto Trap",
  --   size = 16,
  --   paddingBottom = 10,
  --   var = "autotrap", -- checked bool = saved.test
  --   default = true,
  --   tooltip = "To enable or disable the routine from using the trap automaticlly",
  -- })
	-- utility:Text({
	-- 	text = blink.textureEscape(100, 15, "0:1") .. " Charge Settings",
	-- 	size = 12,
	-- 	paddingTop = 4,
	-- 	paddingBottom = 8,
	-- })
	utility:Checkbox({
		text = " Use Charge to Gapclose Target",
		var = "autoCharge",
		default = true,
		tooltip = "To enable or disable the routine from using charge to target when out of range and moving towards them.",
	})
  utility:Checkbox({
		text = "Use Charge to Fear Healer",
		var = "chargeToFearHealer",
		default = false,
		tooltip = "Will automatically charge to fear enemy healer.",
	})
	utility:Slider({
		text = "Charge Gapclose Pressure Modifier",
		var = "chargeGapcloseMod",
		min = 0.75,
		max = 1.5,
		step = 0.01,
		default = 1,
		valueType = "x",
		tooltip = "Modifies sensitivity to our pressure for using Charge to gapclose.\n\n\Setting this low will only use Charge to gapclose to your target when you have a lot of pressure.\n\nSetting it Higher means it will use Charge to gapclose to your target even if you have little pressure"
	})
	-- utility:Dropdown({
	-- 	var = "chargeIntTarget",
	-- 	options = {
	-- 		{ label = "Healer", value = "enemyHealer", tooltip = "Charge the healer to interrupt." },
	-- 		{ label = "Focus", value = "focus", tooltip = "Charge your focus target to interrupt." },
	-- 		{ label = "Target", value = "target", tooltip = "Charge your target to interrupt." },
	-- 		{ label = "All of the above", value = "everyone", tooltip = "Charge the healer, your focus target, or your target to interrupt." },
	-- 		{ label = "Disabled", value = "none", tooltip = "Disable charge interrupts." },
	-- 	},
	-- 	tooltip = "Select which unit(s) the routine should charge to interrupt.",
	-- 	default = "none",
	-- 	header = "Charge Interrupt:",
	-- })
  utility:Text({text = blink.textureEscape(6544, 16) .. " Auto Leap Settings:", header = true})
	utility:Checkbox({
		text = "Use Heroic Leap to Gapclose Target",
		var = "autoLeap",
		default = true,
		tooltip = "Will automatically leap to target when out of range and moving towards them.",
	})
  utility:Checkbox({
		text = "Use Heroic Leap to Fear Healer",
		var = "leapToFearHealer",
		default = false,
		tooltip = "Will automatically leap to fear enemy healer.",
	})
	utility:Slider({
		text = "Leap Gapclose Pressure Modifier",
		var = "leapGapcloseMod",
		min = 0.75,
		max = 1.5,
		step = 0.01,
		default = 1.5,
		valueType = "x",
		tooltip = "Modifies sensitivity to our pressure for using Heroic Leap to gapclose.\n\n\Setting this low will only use Heroic Leap to gapclose to your target when you have a lot of pressure.\n\nSetting it Higher means it will use Heroic Leap to gapclose to your target even if you have little pressure"
	})
	-- utility:Dropdown({
	-- 	var = "leapIntTarget",
	-- 	options = {
	-- 		{ label = "Healer", value = "enemyHealer", tooltip = "Leap to healer to interrupt." },
	-- 		{ label = "Focus", value = "focus", tooltip = "Leap to focus target to interrupt." },
	-- 		{ label = "Target", value = "target", tooltip = "Leap to target to interrupt." },
	-- 		{ label = "All of the above", value = "everyone", tooltip = "Leap to healer, your focus target, or your target to interrupt." },
	-- 		{ label = "Disabled", value = "none", tooltip = "Disable leap interrupts." },
	-- 	},
	-- 	tooltip = "Select which unit(s) the routine should leap to to interrupt.",
	-- 	default = "none",
	-- 	header = "Leap Interrupt:",
	-- })

  local control = warriorGroup:Tab(blink.textureEscape(5246, 15) .. " Control ")
	control:Text({
    text = colors.warrior .. "Warrior Crowd Control Settings:", 
    header = true,
    paddingBottom = 12,
  })

  control:Text({
		text = blink.textureEscape(107570, 15, "0:1") .. "  Storm Bolt Settings:",
		size = 12,
		paddingBottom = 6,
		paddingTop = 16
	})

	control:Dropdown({
		var = "boltTarget",
		options = {
			{ label = "Healer", value = "enemyHealer", tooltip = "Storm bolt the healer." },
			{ label = "Focus", value = "focus", tooltip = "Storm bolt focus." },
			{ label = "Target", value = "target", tooltip = "Storm bolt target." },
			{ label = "Disabled", value = "none", tooltip = "Disable auto storm bolt." },
		},
		tooltip = "Choose the target of your storm bolt.",
		default = "target",
		header = "Use Storm Bolt on Unit:",
	})
	control:Checkbox({
		text = "Use Storm Bolt on burst",
		var = "sbBigPressure",
		default = true,
		tooltip = "Use storm bolt when you are bursting and/or target is low HP.",
	})
	control:Checkbox({
		text = "Use Storm Bolt to Cross CC",
		var = "sbCrossCC",
		default = true,
		tooltip = "Use full DR storm bolt on your storm bolt target when your team cc's other enemy players.",
	})

	control:Checkbox({
		text = "Use Storm Bolt off DR  ",
		var = "sbOffDR",
		default = false,
		tooltip = "Use storm bolt on the storm bolt unit you set off dr.",
	})

  control:Text({
		text = blink.textureEscape(46968, 15, "0:1") .. "  Shockwave Settings:",
		size = 12,
		paddingBottom = 6,
		paddingTop = 16
	})
  control:Checkbox({
		text = "Use Shockwave on burst",
		var = "swBigPressure",
		default = true,
		tooltip = "Use Shockwave when you are bursting and/or target is low HP.",
	})
	-- control:Checkbox({
	-- 	text = "Interrupts",
	-- 	var = "sbInterrupt",
	-- 	default = false,
	-- 	tooltip = "Use storm bolt to interrupt some casts when your interrupt is on CD.",
	-- })

	control:Text({
		text = blink.textureEscape(5246, 15, "0:1") .. "  Intimidating Shout Settings:",
		size = 12,
		paddingBottom = 6,
		paddingTop = 16
	})

	-- control:Slider({
	-- 	text = "Multi-Player Fear Threshold",
	-- 	var = "fearBombCount",
	-- 	min = 2,
	-- 	max = 5,
	-- 	step = 1,
	-- 	default = 3,
	-- 	valueType = " players",
	-- 	tooltip = "Routine will automatically fear if this many players will be hit with full fear and no major cc overlap, regardless of other conditions.\n\nSetting this to 5 will disable it.\n\nOnly works in arenas for performance reasons."
	-- })

	control:Checkbox({
		text = "Use Intimidating Shout on enemyHealer",
		var = "fearHealer",
		default = true,
		tooltip = "Routine Will full fear enemy healer off DR as long as you are not attacking them.",
	})
  control:Checkbox({
		text = "Use Intimidating Shout on Tyrant",
		var = "FearTyrant",
		default = true,
		tooltip = "Routine Will full fear Enemy Warlock Tyrant.",
	})

	control:Checkbox({
		text = "Use Intimidating Shout to peel",
		var = "fearDefensive",
		default = true,
		tooltip = "Routine Will fear enemy dps when they have cooldowns up.",
	})

	-- control:Slider({
	-- 	text = "Gapclose Fear Sensitivity",
	-- 	var = "gcFearSens",
	-- 	min = 0.75,
	-- 	max = 1.25,
	-- 	step = 0.1,
	-- 	default = 1,
	-- 	valueType = "x",
	-- 	tooltip = "Adjust sensitivity to our pressure (enemy hp, teammate cds, etc.) for using charge / leap to get to healer for a full fear.\n\nLower = will only leap/charge to healer for fear if we have a lot of pressure.\n\nHigher = will use leap/charge for full hear on healer more often, even if we don't have a lot of pressure."
	-- })

  local Macros = warriorGroup:Tab(blink.textureEscape(1500870, 15, "0:1") .. " Macros")
  -- lil combustion icon, fires an alert when clicked!
  Macros:Text({
    text = colors.warrior .. "Commands and Macros",
    size = 14,
    paddingBottom = 10,
  })
  
  Macros:Text({
    text = "Using the macros below will Queue the spell on next GCD:",
    size = 10,
    paddingBottom = 10,
  })
  Macros:Text({
    text = "|cFFf7f25cClick on the command to copy it",
    size = 9,
    paddingBottom = 10,
  })

  Macros:Text({
    text = colors.warrior .."General Macros",
    size = 12,
  })
  Macros:Text({
    text = "|cFF43caf7/sr",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr")
    end
  })
  Macros:Text({
    text = "- To Show or Hide the GUI ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7toggle",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr toggle")
    end
  })
  Macros:Text({
    text = "- Turn ON/OFF the routine ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7burst ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr burst")
    end
  })
  Macros:Text({
    text = "- Bursting with your Biggest Cooldowns ",
    paddingBottom = 10,
  })
  -- Macros:Text({
  --   text = "/sr |cFF43caf7resonator target ",
  --   size = 10,
  -- })
  -- Macros:Text({
  --   text = "- Will throw Resonator Trinket to your target ",
  --   paddingBottom = 10,
  -- })
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@unit] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@unit] spell")
    end
  })
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@enemyhealer] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@enemyhealer] spell")
    end
  })  
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@fdps] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@fdps] spell")
    end
  }) 
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "units including: |cFFf7f25ctarget, focus, healer, enemyhealer, party123, arena123, cursor ",
    paddingBottom = 10,
  }) 
  Macros:Text({
    text = "/sr |cFF43caf7pause 1",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr pause 1")
    end
  })
  Macros:Text({
    text = "- Will pause the routine for the giving time (Pause timing: from 1 to 5 Seconds) ",
    paddingBottom = 10,
  }) 
  Macros:Text({
    text = colors.warrior .."Warrior Specific Macros:",
    size = 12,
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7bolt unit ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr bolt target")
    end
  })
  Macros:Text({
    text = "- Will Queue Storm Bolt to unit ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7fear unit ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr fear target")
    end
  })
  Macros:Text({
    text = "- Will Queue Intimidating Shout to unit ",
    paddingBottom = 10,
  })

  -- local Builds = warriorGroup:Tab(blink.textureEscape(1499566, 15, "0:1") .. " Builds")
  -- Builds:Text({
  --   text = colors.warrior .. "Suggested Warrior Builds",
  --   size = 14,
  --   paddingBottom = 10,
  -- })
  -- Builds:Text({
  --   text = blink.textureEscape(2065633, 15, "0:1") .. " Arms Warbreaker Build [|cFFf7f25cClick to copy it|r]",
  --   size = 10,
  --   OnClick = function(self, event)
  --     blink.alert("Copied to clipboard")
  --     blink.call("CopyToClipboard", "BcEAoonA2h02U1PVo4204nicFAgWikEJkkkWpkEAAAAQQkIQCQENkkkkEaSESA4ARCAAAAAAAAJKJIAQDB")
  --   end
  -- })
  -- Builds:Text({
  --   text = blink.textureEscape(464973, 15, "0:1") .. " Arms Colossus Smash Build [|cFFf7f25cClick to copy it|r]",
  --   size = 10,
  --   OnClick = function(self, event)
  --     blink.alert("Copied to clipboard")
  --     blink.call("CopyToClipboard", "BcEAoonA2h02U1PVo4204nicFAgWikEJkkkSpkEAAAAQQkIQCQENkkkkEaSESA4ARCAAAAAAAAJKJIAQDB")
  --   end
  -- })
  -- Builds:Text({
  --   text = blink.textureEscape(2065621, 15, "0:1") .. " Arms Skullsplitter Build [|cFFf7f25cClick to copy it|r]",
  --   size = 10,
  --   OnClick = function(self, event)
  --     blink.alert("Copied to clipboard")
  --     blink.call("CopyToClipboard", "BcEAoonA2h02U1PVo4204nicFAgWCJRSSSiWpkEAAAAQQkIgAFEFKJSSSoJRIBgDEJAAAAAAAAkokgAQUQA")
  --   end
  -- })

end

--shaman
if sr.shaman.ready then

  local shamanColor = {0, 112, 221}
  local shamanGroup = ui:Group({
    name = blink.textureEscape(626006, 15) .. " Shaman",
    title = {blink.textureEscape(626006, 14) .. " Sad", "Shaman"},

    colors = {
      title = {blinkCream, shamanColor},
      accent = shamanColor,
    }
  })

  local offensive = shamanGroup:Tab(blink.textureEscape(114050, 15) .. " Offensives")
  offensive:Text({text = colors.shaman .. "Shaman Offensives Settings:", header = true})
  offensive:Checkbox({
		text = blink.textureEscape(114050, 15, "0:8") .. " Auto Ascendance                      ",
		var = "autoAscendance",
		default = true,
		tooltip = "Enable or Disable Routine from using Auto Ascendance.\n\nWill still use it if you do /sr burst manually.",
	})
  offensive:Checkbox({
		text = blink.textureEscape(204361, 15, "0:8") .. " Auto Bloodlust/Heroism                      ",
		var = "autoLust",
		default = true,
		tooltip = "Enable or Disable Routine from using Auto Bloodlust/Heroism.\n\nWill still use it if you do /sr burst manually.",
	})
  offensive:Checkbox({
		text = blink.textureEscape(375982, 15, "0:8") .. " Auto Primordial Wave                      ",
		var = "autoPWave",
		default = true,
		tooltip = "Enable or Disable Routine from using Auto Primordial Wave.\n\nWill still use it if you do /sr burst manually.",
	})

  local utility = shamanGroup:Tab(blink.textureEscape(8143, 15) .. " Utility ")
  utility:Text({text = colors.shaman .. "Shaman Utilitys Settings:", header = true})
  utility:Text({
		text = blink.textureEscape(8143, 15, "0:1") .. "  Tremor Totem Settings:",
		size = 12,
		paddingBottom = 6,
		paddingTop = 16
	})

	utility:Dropdown({
		var = "tremorUnit",
		options = {
			{ label = "Tremor only my healer", value = "friendlyHealer", tooltip = "Routine will use Tremor Totem when your healer need it only." },
			{ label = "Tremor all team mates", value = "allTeam", tooltip = "Routine will use Tremor Totem when any team mate need it." },
			{ label = "Disable auto tremor", value = "none", tooltip = "Disable auto Tremor." },
		},
		tooltip = "Choose the unit to use Tremor Totem for.",
		default = "friendlyHealer",
		header = "Use Tremor Totem on Unit:",
	})
  
	utility:Checkbox({
		text = "Auto Pre tremor enemy fears on you                      ",
		var = "preTremor",
		default = true,
		tooltip = "Routine will Auto pre tremor enemy fear on you.",
	})
  utility:Text({
		text = blink.textureEscape(136075, 15, "0:1") .. "  Purge Settings:",
		size = 12,
		paddingBottom = 6,
		paddingTop = 16
	})
  utility:Checkbox({
    text = "Enable Auto Purge",
    size = 14,
    paddingBottom = 10,
    var = "autoPurge",
    default = true,
    tooltip = "To Enable or Disable the routine from using Purge",
    
  })
  utility:Dropdown({
    var = "purgeList",
    multi = true,
    tooltip = "Select the buffs you want to Purge.",
    options = {
      { label = blink.textureEscape(79206, 16, "0:0") .. " Spiritwalker's Grace", value = "Spiritwalker's Grace", tvalue = {79206} },
      { label = blink.textureEscape(10060, 16, "0:0") .. " Power Infusion", value = "Power Infusion", tvalue = {10060} },
      { label = blink.textureEscape(378464, 16, "0:0") .. " Nullifying Shroud", value = "Nullifying Shroud", tvalue = {378464} },
      { label = blink.textureEscape(305395, 16, "0:0") .. " Blessing of Freedom", value = "Blessing of Freedom", tvalue = {305395,1044} },
      { label = blink.textureEscape(1022, 16, "0:0") .. " Blessing of Protection", value = "Blessing of Protection", tvalue = {1022} },
      { label = blink.textureEscape(210294, 16, "0:0") .. " Divine Favor", value = "Divine Favor", tvalue = {210294} },
      { label = blink.textureEscape(80240, 16, "0:0") .. " Havoc", value = "Havoc", tvalue = {80240} },
      { label = blink.textureEscape(132158, 16, "0:0") .. " Druid Nature's Swiftness", value = "Druid Nature's Swiftness", tvalue = {132158} },
      { label = blink.textureEscape(305497, 16, "0:0") .. " Thorns", value = "Thorns", tvalue = {305497} },
      { label = blink.textureEscape(378081, 16, "0:0") .. " Shaman Nature's Swiftness", value = "Shaman Nature's Swiftness", tvalue = {378081} },
      { label = blink.textureEscape(342246, 16, "0:0") .. " Alter time", value = "Alter time", tvalue = {342246,198111} },
      { label = blink.textureEscape(342242, 16, "0:0") .. " Time Warp", value = "Time Warp", tvalue = {342242,198111} },
      { label = blink.textureEscape(213610, 16, "0:0") .. " Holy Word", value = "Holy Word", tvalue = {213610} },
      { label = blink.textureEscape(11426, 16, "0:0") .. " Ice Barrier", value = "Ice Barrier", tvalue = {11426,198094,414661} },
      { label = blink.textureEscape(235313, 16, "0:0") .. " Blazing Barrier", value = "Blazing Barrier", tvalue = {235313} },
      { label = blink.textureEscape(17, 16, "0:0") .. " Power Word: Shield", value = "Power Word: Shield", tvalue = {135940,17} },
      { label = blink.textureEscape(360827, 16, "0:0") .. " Blistering Scales", value = "Blistering Scales", tvalue = {360827} },
    },
    placeholder = "Select spells",
    header = "Select the buffs you want to Purge.",
    default = {
      "Spiritwalker's Grace",
      "Blessing of Freedom", 
      "Blessing of Protection", 
      "Power Infusion", 
      "Nullifying Shroud", 
      "Alter time", 
      "Holy Word",
      "Ice Barrier",
      "Blazing Barrier",
      "Druid Nature's Swiftness",
      "Shaman Nature's Swiftness",
      "Havoc",
      "Time Warp",
      "Blistering Scales",
      "Thorns",
    }
  })

  utility:Text({
		text = blink.textureEscape(204336, 15, "0:1") .. "  Grounding Totem Settings:",
		size = 12,
		paddingBottom = 6,
		paddingTop = 16
	})
  utility:Checkbox({
		text = "Enable Auto Grounding           ",
		var = "autoGrounding",
		default = true,
		tooltip = "Routine will Auto Grounding Totem.",
	})
  utility:Checkbox({
		text = "Auto Grounding Enemy " ..colors.hunter .."Hunter" .. " [Freezing Trap]",
		var = "groundTraps",
		default = true,
		tooltip = "Routine Auto Grounding Enemy Hunter traps.",
	})

  utility:Text({
		text = blink.textureEscape(51490, 15, "0:1") .. "  Thunderstorm Settings:",
		size = 12,
		paddingBottom = 6,
		paddingTop = 16
	})
  utility:Checkbox({
		text = "Enable Auto Thunderstorm           ",
		var = "autoThunderstorm",
		default = true,
		tooltip = "Routine will Auto Thunderstorm.",
	})
  
  local control = shamanGroup:Tab(blink.textureEscape(51514, 15) .. " Control ")
  control:Text({text = colors.shaman .. "Shaman Crowd Control Settings:", header = true})

  control:Text({
		text = blink.textureEscape(51514, 15, "0:1") .. "  Hex Settings:",
		size = 12,
		paddingBottom = 6,
		paddingTop = 16
	})

	control:Dropdown({
		var = "hexTarget",
		options = {
			{ label = "Healer", value = "enemyHealer", tooltip = "Hex the healer." },
			{ label = "Focus", value = "focus", tooltip = "Hex focus." },
			{ label = "Target", value = "target", tooltip = "Hex target." },
			{ label = "Disabled", value = "none", tooltip = "Disable auto Hex." },
		},
		tooltip = "Choose the target of your Hex.",
		default = "enemyHealer",
		header = "Use Hex on Unit:",
	})
	control:Checkbox({
		text = "Use Hex on burst                      ",
		var = "hexBigPressure",
		default = true,
		tooltip = "Use Hex when you are bursting and/or target is low HP.            ",
	})
	control:Checkbox({
		text = "Use Hex to Cross CC",
		var = "hexCrossCC",
		default = true,
		tooltip = "Use full DR Hex on your Hex target when your team cc's other enemy players.          ",
	})

	control:Checkbox({
		text = "Use Hex off DR                 ",
		var = "hexOffDR",
		default = true,
		tooltip = "Use Hex on the Hex unit you set off dr.",
	})

  control:Text({
		text = blink.textureEscape(305483, 15, "0:1") .. "  Lightning Lasso Settings:",
		size = 12,
		paddingBottom = 6,
		paddingTop = 16
	})

  control:Checkbox({
    text = "Lightning Lasso Enemy CD's  ",
    size = 14,
    paddingBottom = 10,
    var = "autoLassoCDs", 
    default = true,
    tooltip = "To Enable or Disable the routine from using Lightning Lasso on Enemy CD's if you are targeting the enemy.",
  })
  -- control:Checkbox({
  --   text = "Lightning Lasso to peel  ",
  --   size = 14,
  --   paddingBottom = 10,
  --   var = "autoLassoPeel", 
  --   default = true,
  --   tooltip = "To Enable or Disable the routine from using Lightning Lasso to peel you or team mates if you are targeting the enemy.",
  -- })
  control:Checkbox({
    text = "Lightning Lasso Gapclosers  ",
    size = 14,
    paddingBottom = 10,
    var = "autoLassoGapCloser", 
    default = false,
    tooltip = "To Enable or Disable the routine from using Lightning Lasso on Gapclosers if you are targeting the enemy.",
  })
  control:Checkbox({
    text = "Lightning Lasso Enemy Healer  ",
    size = 14,
    paddingBottom = 10,
    var = "autoLassoHealer", 
    default = true,
    tooltip = "To Enable or Disable the routine from using Lightning Lasso on Enemy Healer if you are target is low.",
  })

  control:Text({
		text = blink.textureEscape(51485, 15, "0:1") .. "  Earthgrab Totem Settings:",
		size = 12,
		paddingBottom = 6,
		paddingTop = 16
	})

  control:Checkbox({
		text = "Use Earthgrab Totem on Enemy CD's                 ",
		var = "rootCDs",
		default = true,
		tooltip = "Use Earthgrab Totem on Enemy CD's.",
	})

  control:Checkbox({
		text = "Use Earthgrab Totem on Enemy Tunnel                 ",
		var = "rootTunnel",
		default = false,
		tooltip = "Use Earthgrab Totem on Enemy Tunnel you.",
	})

  control:Text({
		text = blink.textureEscape(192058, 15, "0:1") .. "  Capacitor Totem Settings:",
		size = 12,
		paddingBottom = 6,
		paddingTop = 16
	})
  control:Checkbox({
		text = "Use Capacitor Totem on Enemy Healer                 ",
		var = "capHealer",
		default = true,
		tooltip = "Use Capacitor Totem on Enemy Healer.",
	})

  -- control:Text({
	-- 	text = blink.textureEscape(1020304, 15, "0:1") .. "  Static Field Totem Settings:",
	-- 	size = 12,
	-- 	paddingBottom = 6,
	-- 	paddingTop = 16
	-- })
  -- control:Checkbox({
	-- 	text = "Auto Static Field + Projection Totem Enemy                      ",
	-- 	var = "autoStaticField",
	-- 	default = true,
	-- 	tooltip = "Routine will Auto Static Field + Projection Totem enemies.",
	-- })


  local defensives = shamanGroup:Tab(blink.textureEscape(108271, 15) .. " Defensives ")
  defensives:Text({text = colors.shaman .. "Shaman Defensives Settings:", header = true})
  defensives:Checkbox({
    text = "Don't Overlap Defensives",
    size = 20,
    paddingBottom = 5,
    var = "dontDefOvelap", 
    default = true,
    tooltip = "To Enable or Disable the routine from using Astral Shift/Burrow if you have [Guardian Spirit/Life Cocoon/Ultimate Sac] buffs up",
  })
  defensives:Checkbox({
    text = blink.textureEscape(974, 16, "0:8") .. " Auto Earth Shield      ",
    size = 20,
    paddingBottom = 5,
    var = "autoEarthShield", 
    default = true,
    tooltip = "To Enable or Disable the routine use Earth Shield on Group memebers",
  })
  defensives:Checkbox({
    text = blink.textureEscape(108281, 16, "0:8") .. " Auto Ancestral Guidance      ",
    size = 20,
    paddingBottom = 5,
    var = "autoGuidance", 
    default = true,
    tooltip = "To Enable or Disable the routine use Ancestral Guidance",
  })
  defensives:Checkbox({
    text = blink.textureEscape(108271, 16, "0:8") .. " Greedy Astral Shift ",
    size = 20,
    paddingBottom = 5,
    var = "greedyAstral", 
    default = false,
    tooltip = "To Enable or Disable the routine to be really greedy on using Astral Shift.\n\ndon't rely on that still working hard to make it read alot of stuff before using it",
  })
  defensives:Slider({
    text = blink.textureEscape(108271, 16, "0:2") .. " Use Astral Shift By Health",
    --text = "Use Astral Shift By Health",
    var = "astralSlider", 
    min = 0,
    max = 100,
    default = 45,
    valueType = "%",
    tooltip = "Set the percentage to use Astral Shift"
  })
  defensives:Slider({
    text = blink.textureEscape(108270, 16, "0:2") .. " Auto Stone Bulwark Totem",
    var = "bulwarkSlider", 
    min = 0,
    max = 100,
    default = 70,
    valueType = "%",
    tooltip = "Set the percentage to use Stone Bulwark Totem"
  })
  defensives:Checkbox({
    text = blink.textureEscape(8004, 15, "0:8") .. " Auto Healing Surge",
    size = 14,
    paddingBottom = 10,
    var = "autoSurge",
    default = true,
    tooltip = "Enable the routine to use Healing Surge",
  })
	defensives:Slider({
		text = blink.textureEscape(8004, 16, "0:2") .. "Healing Surge Sensitivity",
		var = "surgeSlider",
		min = 0,
		max = 100,
		step = 0.1,
		default = 65,
		valueType = "%",
		tooltip = "Set the percentage to use."
	})
  defensives:Slider({
    text = blink.textureEscape(409293, 16, "0:2") .. " Use Burrow By Health",
    --text = "Use Burrow By Health",
    var = "burrowSlider", 
    min = 0,
    max = 100,
    default = 20,
    valueType = "%",
    tooltip = "Set the percentage to use Burrow"
  })
  defensives:Slider({
    text = blink.textureEscape(345231, 16, "0:2") .. " Use Emblem Trinket By Health",
    var = "emblemtrinket",
    min = 0,
    max = 100,
    step = 1,
    default = 35,
    valueType = "%",
    tooltip = "Set the percentage to use Emblem Trinket"
  })

  --! MACROS TAB !--
  local Macros = shamanGroup:Tab(blink.textureEscape(1500870, 15, "0:1") .. " Macros")
  -- lil combustion icon, fires an alert when clicked!
  Macros:Text({
    text = colors.shaman .. "Commands and Macros",
    size = 14,
    paddingBottom = 10,
  })
  
  Macros:Text({
    text = "Using the macros below will Queue the spell on next GCD:",
    size = 10,
    paddingBottom = 10,
  })
  Macros:Text({
    text = "|cFFf7f25cClick on the command to copy it",
    size = 9,
    paddingBottom = 10,
  })

  Macros:Text({
    text = colors.shaman .."General Macros",
    size = 12,
  })
  Macros:Text({
    text = "|cFF43caf7/sr",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr")
    end
  })
  Macros:Text({
    text = "- To Show or Hide the GUI ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7toggle",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr toggle")
    end
  })
  Macros:Text({
    text = "- Turn ON/OFF the routine ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7burst ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr burst")
    end
  })
  Macros:Text({
    text = "- Bursting with your Biggest Cooldowns ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@unit] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@unit] spell")
    end
  })
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@enemyhealer] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@enemyhealer] spell")
    end
  })  
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "- /sr |cFF43caf7cast [@fdps] spell ",
    paddingBottom = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr cast [@fdps] spell")
    end
  }) 
  Macros:Text({
    text = "- Using the macros will Queue the spell on the unit ",----
    paddingBottom = 10,
  })  
  Macros:Text({
    text = "units including: |cFFf7f25ctarget, focus, healer, enemyhealer, party123, arena123, cursor ",
    paddingBottom = 10,
  }) 
  Macros:Text({
    text = "/sr |cFF43caf7pause 1",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr pause 1")
    end
  })
  Macros:Text({
    text = "- Will pause the routine for the giving time (Pause timing: from 1 to 5 Seconds) ",
    paddingBottom = 10,
  }) 
  Macros:Text({
    text = colors.shaman .."Shaman Specific Macros:",
    size = 12,
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7wolf toggle ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr wolf toggle")
    end
  })
  Macros:Text({
    text = "- Will Toggle Ghost Wolf ON/OFF ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7lasso target ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr lasso target")
    end
  })
  Macros:Text({
    text = "- Will Queue Lightning Lasso to target ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7lasso focus ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr lasso focus")
    end
  })
  Macros:Text({
    text = "- Will Queue Lightning Lasso to focus ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7lasso arena1,arena2,arena3,enemyhealer ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr lasso arena1")
    end
  })
  Macros:Text({
    text = "- Will Queue Lightning Lasso to arena1,arena2,arena3 or enemyhealer ",
    paddingBottom = 10,
  })

  Macros:Text({
    text = "/sr |cFF43caf7hex target ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr hex target")
    end
  })
  Macros:Text({
    text = "- Will Queue Hex to target ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7hex focus ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr hex focus")
    end
  })
  Macros:Text({
    text = "- Will Queue Hex to focus ",
    paddingBottom = 10,
  })
  Macros:Text({
    text = "/sr |cFF43caf7hex arena1,arena2,arena3,enemyhealer ",
    size = 10,
    OnClick = function(self, event)
      blink.alert("Command copied to clipboard")
      blink.call("CopyToClipboard", "/sr hex arena1")
    end
  })
  Macros:Text({
    text = "- Will Queue Hex to arena1,arena2,arena3 or enemyhealer ",
    paddingBottom = 10,
  })


end


-- Minimap Button
local button = CreateFrame("Button", "SadButton", Minimap, "SecureActionButtonTemplate")
button:SetWidth(28)
button:SetHeight(28)
button:SetFrameStrata("MEDIUM")
button:SetPoint("CENTER", Minimap, "CENTER", -50, -85)
button:SetMovable(true)
button:EnableMouse(true)
button:RegisterForDrag("LeftButton")
button:SetScript("OnDragStart", button.StartMoving)
button:SetScript("OnDragStop", button.StopMovingOrSizing)

-- Button normal texture
local texture = button:CreateTexture(nil, "BACKGROUND")
texture:SetWidth(28)
texture:SetHeight(28)
texture:SetPoint("CENTER", button, "CENTER")
texture:SetTexture("Interface\\Icons\\Achievement_leader_sylvanas")

-- Button hover texture
local hoverTexture = button:CreateTexture()
hoverTexture:SetWidth(28)
hoverTexture:SetHeight(28)
hoverTexture:SetPoint("CENTER")
hoverTexture:SetTexture("Interface\\Icons\\Achievement_leader_sylvanas")
hoverTexture:SetAlpha(0) -- Initially hidden

button:SetScript("OnEnter", function(self)
  texture:SetAlpha(0) -- Hide normal texture
  hoverTexture:SetAlpha(1) -- Show hover texture
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:AddLine("Sad Rotations")
  GameTooltip:Show()
end)

button:SetScript("OnLeave", function(self)
  texture:SetAlpha(1) -- Show normal texture
  hoverTexture:SetAlpha(0) -- Hide hover texture
  GameTooltip:Hide()
end)

button:SetHitRectInsets(-10, -10, -10, -10)
texture:SetMask("Interface\\Minimap\\UI-Minimap-Background")

-- Declare existing_alert outside of the function to ensure it persists between clicks
local existing_alert

-- Handling clicks
button:SetScript("OnClick", function(self, buttonPressed)
  if buttonPressed == "RightButton" then
    -- Toggle the feature and display an alert
    blink.enabled = not blink.enabled
    local txt = "|cFFf7f25c[SadRotations]: " .. (blink.enabled and "|cFF22f248Enabled" or "|cFFf74a4aDisabled")
    if not existing_alert or existing_alert == true or existing_alert:GetAlpha() <= 0 then
      existing_alert = blink.alert(txt)
    else
      existing_alert.alpha = 1
      existing_alert:SetAlpha(1)
      existing_alert.fontString:SetText(txt)
      existing_alert.endTime = GetTime() + 0.7
    end
  else
    -- Left click action or other default action
    blink.call('C_Macro.RunMacroText', '/sr', "")
  end
end)




-- function Module:OnEnable()
--   local Install = CreateFrame("Frame", UIParent)
--   Install:SetWidth(GetScreenWidth())
--   Install:SetHeight(GetScreenHeight())
--   Install:SetPoint("CENTER", 0, 0)
--   Install:EnableMouse(true)
--   Install:SetFrameStrata("HIGH")
--   Install.text = Install:CreateFontString(nil, "ARTWORK", "QuestMapRewardsFont")
--   Install.text:SetScale(4)
--   Install.text:SetPoint("CENTER", 0, 30)
--   Install.text:SetText("|cFFFFFFFFWelcome to |cFF43caf7SAD|r|cFFFFFFFFRotations|r")

--   local Texture = Install:CreateTexture(nil, "BACKGROUND")
--   Texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
--   Texture:SetAllPoints(Install)
--   Install.texture = Texture

--   local Subtittle = CreateFrame("Frame", "Subtittle", Install)
--   Subtittle:SetSize(250, 50)
--   Subtittle:SetPoint("CENTER", Install, 0, 90)
--   Subtittle.text = Subtittle:CreateFontString(Subtittle, "ARTWORK", "QuestMapRewardsFont")
--   Subtittle.text:SetPoint("CENTER", 0, 0)
--   Subtittle.text:SetText("|cFF43caf7The Most Advanced PVP Routines")
--   Subtittle.text:SetScale(1.4)

--   local Discord = CreateFrame("Frame", "Discord", Install)
--   Discord:SetSize(250, 50)
--   Discord:SetPoint("CENTER", Subtittle, 0, -30)
--   Discord.text = Discord:CreateFontString(Discord, "ARTWORK", "QuestMapRewardsFont")
--   Discord.text:SetPoint("CENTER", 0, 0)
--   Discord.text:SetText("|cFFFFFFFFDiscord: |cFF43caf7https://discord.gg/sadrotations")
--   Discord.text:SetScale(0.9)

--   local Author = CreateFrame("Frame", "Author", Install)
--   Author:SetSize(250, 50)
--   Author:SetPoint("CENTER", Subtittle, 0, -15)
--   Author.text = Author:CreateFontString(Author, "ARTWORK", "QuestMapRewardsFont")
--   Author.text:SetPoint("CENTER", 0, 0)
--   Author.text:SetText("|cFFFFFFFFtype |cFF43caf7/sr |cFFFFFFFF(to show the GUI settings)")
--   Author.text:SetScale(0.9)

--   local Button = CreateFrame("Button", "Start", Install, "UIPanelButtonTemplate")
--   Button:SetPoint("CENTER", 0, 25)
--   Button:SetSize(100, 25)
--   Button:SetText("Start")
--   Button:SetNormalTexture("Interface\\Common\\bluemenu-main")
--   Button:GetNormalTexture():SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813)
--   Button:GetNormalTexture():SetVertexColor(0.265, 0.320, 0.410, 1)
--   Button:SetHighlightTexture("Interface\\Common\\bluemenu-main")
--   Button:GetHighlightTexture():SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813)
--   Button:GetHighlightTexture():SetVertexColor(0.265, 0.320, 0.410, 1)
--   Button:SetScript("OnClick",function()
--     local fadeInfo = {};
--     fadeInfo.mode = "OUT";
--     fadeInfo.timeToFade = 0.4;
--     fadeInfo.finishedFunc = function()
--       Install:Hide()
--       blink.protected.RunMacroText('/sr')
--     end
--     UIFrameFade(Install, fadeInfo);
--   end)
-- end
-- Module:OnEnable()

function sr.actionDelay(callback)
  if not callback then return false end

  local reactionTime = saved.reactionDelay or 0.5

  C_Timer.After(reactionTime, function()
    callback()
  end)

  return true
end

sr.nextReactionTimes = sr.nextReactionTimes or {}

-- Updated reactionDelay function that accepts an action identifier.
function sr.reactionDelay(actionId, delayOverride)
  local currentTime = GetTime()
  local delay = saved.reactionDelay or 0.5

  -- Initialize the next reaction time for this action if it hasn't been set.
  sr.nextReactionTimes[actionId] = sr.nextReactionTimes[actionId] or 0

  if currentTime >= sr.nextReactionTimes[actionId] then
    -- Update the next reaction time for this action.
    sr.nextReactionTimes[actionId] = currentTime + delay
    return true
  else
    return false
  end
end

-- local lastTimeSoundPlayed = 0
-- onUpdate(function()
--   --need to make for all Queues kinds

--   --Alert Queues
--   if saved.AlertPopupQueue then
--     local battlefieldStatus = GetBattlefieldStatus(1)
--     if battlefieldStatus == "confirm" then
--       local currentTime = GetTime()
--       if currentTime > (lastTimeSoundPlayed + 3) then
--         if currentTime < (lastTimeSoundPlayed + 3) then return end
--         PlaySound(5775)
--         lastTimeSoundPlayed = GetTime()
--       end
--     end
--   end

--   --Auto Accept Queues
--   if saved.AutoAcceptQue 
--   and blink.enabled
--   and not UnitIsAFK("player") then
--     local battlefieldStatus = GetBattlefieldStatus(1)
--     if battlefieldStatus == "confirm" then
--       if GetBattlefieldPortExpiration(1) > 5 then return end
--       --print("Auto Accept Queue!")
--       blink.call("AcceptBattlefieldPort", 1, true)
--     end
--   end

--   --antiAFK
--   if saved.AntiAFK then
--     if ResetAfk then
--       ResetAfk()
--       antiafk = blink.time
--     elseif SetLastHardwareActionTime then
--       SetLastHardwareActionTime(blink.time*1000)
--       antiafk = blink.time
--     end
--   end

--   if saved.streamingMode then
--     C_Timer.After(0.2, function()
--       if blink.saved.disableAlerts == true then return end
--       blink.saved.disableAlerts = true
--       print("|cFFf7f25c[Steaming Mode]: |cFF22f248Enabled")
--     end)
--   elseif not saved.streamingMode then
--     C_Timer.After(0.2, function()
--       if blink.saved.disableAlerts == false then return end
--       blink.saved.disableAlerts = false
--       print("|cFFf7f25c[Steaming Mode]: |cFFf74a4aDisabled")
--     end)
--   end

--   if not saved.DisableCastAlert then
--     C_Timer.After(0.2, function()
--       if blink.saved.disableCastAlerts == false then return end
--       blink.saved.disableCastAlerts = false
--       print("|cFFf7f25c[Cast Alerts]: |cFF22f248Enabled")
--     end)
--   elseif saved.DisableCastAlert then
--     C_Timer.After(0.2, function()
--       if blink.saved.disableCastAlerts == true then return end
--       blink.saved.disableCastAlerts = true
--       print("|cFFf7f25c[Cast Alerts]: |cFFf74a4aDisabled")
--     end)
--   end
  
--   -- if saved.autoStunSet == "stunTrapUnit" then 
--   --   print("stunTrapUnit") 
--   -- elseif saved.autoStunSet == "stunKillTarget" then 
--   --   print("stunKillTarget") 
--   -- end

-- end)

local lastTimeSoundPlayed = 0
--alert sounds
local function handleQueueAlert()
  if saved.AlertPopupQueue then
    for i = 1, GetMaxBattlefieldID() do
      local battlefieldStatus = GetBattlefieldStatus(i)
      if battlefieldStatus == "confirm" then
        local currentTime = GetTime()
        if currentTime > (lastTimeSoundPlayed + 3) then
          PlaySound(5775) -- Sound ID for queue pop
          lastTimeSoundPlayed = currentTime
        end
      end
    end
  end
end

--auto-accept queues
local function handleAutoAcceptQueue()
  if saved.AutoAcceptQue and blink.enabled and not UnitIsAFK("player") then
    for i = 1, GetMaxBattlefieldID() do
      local battlefieldStatus = GetBattlefieldStatus(i)
      if battlefieldStatus == "confirm" then
        if GetBattlefieldPortExpiration(i) > 5 then return end
        blink.call("AcceptBattlefieldPort", i, true)
      end
    end
  end
end

-- Function to prevent AFK status
local function handleAntiAFK()
  if saved.AntiAFK then
    if ResetAfk then
      ResetAfk()
    elseif SetLastHardwareActionTime then
      SetLastHardwareActionTime(blink.time * 1000)
    end
  end
end


local function handleStreamingMode()
  if not saved.streamingMode then return end
  if saved.streamingMode then
    if not blink.saved.disableAlerts then
      blink.saved.disableAlerts = true
      print("|cFFf7f25c[Streaming Mode]: |cFF22f248Enabled")
    end
  else
    if blink.saved.disableAlerts then
      blink.saved.disableAlerts = false
      print("|cFFf7f25c[Streaming Mode]: |cFFf74a4aDisabled")
    end
  end
end

local function handleCastAlerts()
  if saved.streamingMode then return end
  if saved.DisableCastAlert then
    if not blink.saved.disableCastAlerts then
      blink.saved.disableCastAlerts = true
      print("|cFFf7f25c[Cast Alerts]: |cFFf74a4aDisabled")
    end
  else
    if blink.saved.disableCastAlerts then
      blink.saved.disableCastAlerts = false
      print("|cFFf7f25c[Cast Alerts]: |cFF22f248Enabled")
    end
  end
end


local function handleAllAlerts()
  if saved.streamingMode then return end
  if saved.DisableAllAlert then
    if not blink.saved.disableAlerts then
      blink.saved.disableAlerts = true
      print("|cFFf7f25c[All Alerts]: |cFF22f248Enabled")
    end
  else
    if blink.saved.disableAlerts then
      blink.saved.disableAlerts = false
      print("|cFFf7f25c[All Alerts]: |cFFf74a4aDisabled")
    end
  end
end


blink.onUpdate(function()
  handleQueueAlert()
  handleAutoAcceptQueue()
  handleAntiAFK()
  handleStreamingMode()
  handleCastAlerts()
  handleAllAlerts()
end)

--debugging
-- if saved.DebugMode then

--   C_Timer.After(0.5, function()
--     RunMacroText("/blink debug")
--     print("|cFFf7f25c[SadRotations]: |cFF22f248Debug Mode Enabled")
--   end)

-- end

-- if not blinkToggle then
--   blinkToggle = CreateFrame("Button", "BlinkToggle", UIParent, "SecureHandlerClickTemplate")
-- end

-- local ToggleFrame = CreateFrame("Frame", nil, blinkToggle)

-- local p, x, y = "CENTER", 0, 0

-- blinkToggle:SetSize(40, 40)

-- blinkToggle:SetPoint(p, x, y)

-- blinkToggle:EnableMouse(true)
-- blinkToggle:SetMovable(true)
-- blinkToggle:SetClampedToScreen(true)
-- blinkToggle:RegisterForDrag("LeftButton")

-- -- This is what your button texture looks like
-- blinkToggle:SetNormalTexture([[Interface\ICONS\Spell_Magic_PolymorphChicken]])

-- blinkToggle:SetScript("OnDragStart", blinkToggle.StartMoving)
-- blinkToggle:SetScript("OnDragStop", blinkToggle.StopMovingOrSizing)

-- blinkToggle:SetScript("OnClick", function()
--   -- put your toggle stuff here if you have more than just enabling Blink
--   if not blink.enabled then
--       blink.enabled = true
--       -- This is the highlight effect of your button while enabled
--       ToggleFrame.texture:SetTexture([[Interface/BUTTONS/CheckButtonHilight-Blue]])
--   else
--       blink.enabled = false
--       -- This is shamelessly stolen as the blank texture from BR
--       ToggleFrame.texture:SetTexture([[Interface\GLUES\CREDITS\Arakkoa1]])
--   end
-- end)

-- ToggleFrame:SetWidth(60 * 1.67)
-- ToggleFrame:SetHeight(60 * 1.67)
-- ToggleFrame:SetPoint("CENTER")
-- ToggleFrame.texture = ToggleFrame:CreateTexture(nil, "OVERLAY")
-- ToggleFrame.texture:SetAllPoints()
-- ToggleFrame.texture:SetWidth(60 * 1.67)
-- ToggleFrame.texture:SetHeight(60 * 1.67)
-- ToggleFrame.texture:SetAlpha(1)

--toggles
cmd:New(function(msg)

  if msg == "scatter toggle" then
    saved.autoScatter = not saved.autoScatter
    print(saved.autoScatter == true and blink.textureEscape(213691, 16, "0:2") .. "|cFF22f248 Auto Scatter Enabled" or blink.textureEscape(213691, 16, "0:2") .. "|cFFf74a4a Auto Scatter Disabled")
    local txt = (saved.autoScatter == true and blink.textureEscape(213691, 16, "0:2") .."|cFF22f248 Auto Scatter Enabled" or blink.textureEscape(213691, 16, "0:2") .."|cFFf74a4a Auto Scatter Disabled")
		if not existing_alert or existing_alert == true or existing_alert:GetAlpha() <= 0 then
			existing_alert = blink.alert(txt)
		else
			existing_alert.alpha = 1
			existing_alert:SetAlpha(1)
			existing_alert.fontString:SetText(txt)
			existing_alert.endTime = GetTime() + 0.7
		end
    return true
  end

  -- if msg == "freedom toggle" or msg == "free toggle" then
  --   saved.autofreedom = not saved.autofreedom
  --   print(saved.autofreedom == true and blink.textureEscape(53271, 16, "0:2") .. "|cFF22f248 Auto Master's Call Enabled" or blink.textureEscape(53271, 16, "0:2") .. "|cFFf74a4a Auto Master's Call Disabled")
  --   local txt = (saved.autofreedom == true and blink.textureEscape(53271, 16, "0:2") .."|cFF22f248 Auto Master's Call Enabled" or blink.textureEscape(53271, 16, "0:2") .."|cFFf74a4a Auto Master's Call Disabled")
	-- 	if not existing_alert or existing_alert == true or existing_alert:GetAlpha() <= 0 then
	-- 		existing_alert = blink.alert(txt)
	-- 	else
	-- 		existing_alert.alpha = 1
	-- 		existing_alert:SetAlpha(1)
	-- 		existing_alert.fontString:SetText(txt)
	-- 		existing_alert.endTime = GetTime() + 0.7
	-- 	end
  --   return true
  -- end

  local function handleModeToggle(settingKey, modes, iconID)
    local currentMode = saved[settingKey] or modes[1].value
    local currentIndex = 1

    for i, mode in ipairs(modes) do
      if mode.value == currentMode then
        currentIndex = i
        break
      end
    end

    local nextIndex = (currentIndex % #modes) + 1
    local nextMode = modes[nextIndex]

    saved[settingKey] = nextMode.value

    print(blink.textureEscape(iconID, 16, "0:2") 
    .. "|cFF22f248 " .. nextMode.label)

    if not existing_alert or existing_alert:GetAlpha() <= 0 then
      existing_alert = blink.alert("|cFF22f248 " .. nextMode.label, iconID)
    else
      existing_alert.alpha = 1
      existing_alert:SetAlpha(1)
      existing_alert.fontString:SetText(nextMode.label)
      existing_alert.endTime = GetTime() + 0.7
    end
  end

  if msg == "freedom toggle" 
  or msg == "free toggle" then
    handleModeToggle(
      "freedomUnit",
      {
        { value = "none", label = "Auto Master's Call Disabled" },
        { value = "selfish", label = "Freedom Self Only" },
        { value = "friendlyHealer", label = "Freedom Only My Healer" },
        { value = "allTeam", label = "Freedom All Teammates" }
      },
      53271
    )
    return true
  end
end)