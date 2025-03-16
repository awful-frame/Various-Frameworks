local Unlocker, awful, gifted = ...
local UnlockerType = Unlocker.type
awful.Devmode = true
awful.AntiAFK.enabled = true 

gifted.hunter = {}
gifted.hunter.bm = awful.Actor:New({ spec = 1, class = "hunter" })

if awful.player.class2 ~= "HUNTER" then return end


local SpecCheck = function()
    return GetSpecialization()
end

gifted.bm = false

if SpecCheck() == 1 then
    gifted.bm = true
end

if not gifted.bm then return end


local hunter, bm = gifted.hunter, gifted.hunter.bm
local player, target, focus, healer, enemyHealer, arena1, arena2, arena3 = awful.player, awful.target, awful.focus, awful.healer, awful.enemyHealer, awful.arena1, awful.arena2, awful.arena3
local bin, angles, min, max, cos, sin, inverse, sort = awful.bin, awful.AnglesBetween, min, max, math.cos, math.sin, awful.inverseAngle, table.sort
local enemy = awful.enemy
local enemies = awful.enemies
local gcd, buffer, latency, tickRate, gcdRemains = awful.gcd, awful.buffer, awful.latency, awful.tickRate, awful.gcdRemains
local pet = awful.pet
local anglesNew, acb, gdist, between = awful.AnglesBetween, awful.AddSlashAwfulCallback, awful.Distance, awful.PositionBetween
local events, colors, colored, escape = awful.events, awful.colors, awful.colored, awful.textureEscape
local succs = {127797, 307871, 355591, 355619 , 23284, 376080}
local CopyToClipboard = awful.unlock("CopyToClipboard")
local onUpdate, onEvent, hookCallbacks, hookCasts, Spell, Item = awful.addUpdateCallback, awful.addEventCallback, awful.hookSpellCallbacks, awful.hookSpellCasts, awful.NewSpell, awful.NewItem
local delay = awful.delay(0.3, 0.5)
local quickdelay = awful.delay(0.2, 0.4)
local randomd = math.random(0.4, 1)
local randomValue = math.random(-3, 3)
local dispelDelay = awful.delay(0.3, 0.6)
local NS = awful.NewSpell
local unitIDs = {  [179867] = {r = 69, g = 126, b = 151, a = 75, radius = 8}, -- static field totem
}
local party1, party2, party3 = awful.party1, awful.party2, awful.party3
local SpellStopCasting = awful.unlock("SpellStopCasting")
local settings, state = gifted.settings, gifted.arenaState
gifted.delay = awful.delay(0.4, 0.6)
gifted.quickdelay = awful.delay(0.2, 0.4)
gifted.interruptDelay = awful.delay(0.2, 0.80)


function gifted.print(...)
    print(awful.textureEscape(626000) .. awful.colors.white .. " - giftedHunter |r")
    print("        " .. awful.textureEscape(217200) .. awful.colors.green .. " |cFFAAD372- Time to WIN!")
end

gifted.print()


local title = {
    ["HUNTER"] = {awful.colors.white .. '   Gifted    \n' .. awful.colors.green .. "      |cFFAAD372BM       "},
}

local titleColor = {
    ["HUNTER"] = { 244, 140, 186 },
}

local primaryColor = {
    ["HUNTER"] = { 244, 140, 186 },
}


local ui, settings, cmd = awful.UI:New("gifted", {
    title = title[awful.player.class2][1],
    colors = {
        title = titleColor[awful.player.class2],
        primary = { 175, 175, 175, 0.8 },
        accent = { 147, 197, 114 },
        background = { 12, 12, 12, 0.6 },
        tertiary = { 161, 161, 161, 0.5 }
    },
    sidebar = true,
    width = 400,
    height = 320,
    scale = 1,
    show = true,
    defaultTab = ("   " .. awful.textureEscape(626000, 20, "0:-1") .. awful.colors.green .. " |cFFAAD372-  Info"),
    cmd = { "gifted", "bm", "gift", "gifts", "hunter", "hunt" }
})

gifted.cmd = cmd

local function RunSlashCmd(cmd) 
    local slash, rest = cmd:match("^(%S+)%s*(.-)$") 
    for name in pairs(SlashCmdList) do 
       local i = 1 
       local slashCmd 
       repeat 
          slashCmd = _G["SLASH_"..name..i] 
          if slashCmd == slash then 
             SlashCmdList[name](rest) 
             return true 
          end 
          i = i + 1 
       until not slashCmd 
    end 
end


local spacer0 = ui:Tab(awful.colors.white .. "          -         ")

local Information = ui:Tab("   " .. awful.textureEscape(626000, 20, "0:-1") .. awful.colors.green .. " |cFFAAD372-  Info")

Information:Text({
    text = awful.textureEscape(626000, 22, "0:0") .. awful.colors.white .. "   Hunter | |cFFAAD372BM   " .. awful.textureEscape(217200, 22, "0:0"),
    size = 15,
    paddingLeft = 35,
    paddingBottom = 15
})

Information:Text({
    text = awful.textureEscape(272651, 22, "0:0") .. awful.colors.white .. " - To open the UI, type: |cFFAAD372/bm |r",
    size = 11,
    paddingBottom = 10,
})


Information:Text({
    text = awful.colors.white .. "    Builds:",
    size = 14,
    paddingLeft = 80,
})

Information:Text({
    text = awful.textureEscape(430703, 22, "0:0") .. awful.colors.white .. " - Dark Ranger [100%] : |cFFAAD372 [Click]",
    size = 11,
    OnClick = function()
        CopyToClipboard("C0PAjWdaYGhrXhCioy+K0kCnAastMwAmgZhtQGLAAAAAAYAAAAAAAmx2wsMzMjZmxMjZYGzMYYmMDMDzYMzwYmZmZmhZZmhtBWA")
        awful.alert({msg= "Talents copied to clipboard!", texture=430703})

    end
})

Information:Text({
    text = awful.colors.white .. "   PvP Talents:",
    size = 12,
    paddingLeft = 80,
    paddingTop = 5,
})

Information:Text({
    text = awful.textureEscape(202746, 22, "0:0") .. awful.colors.white .. " - Survival Tactics |cFFAAD372(Mandatory 100%)",
    size = 10,
    paddingTop = 5,
})

Information:Text({
    text = awful.textureEscape(203340, 22, "0:0") .. awful.colors.white .. " - Diamond Ice |cFFAAD372(Mandatory 100%)",
    size = 10,
    paddingTop = 5,
})

Information:Text({
    text = awful.textureEscape(356719, 22, "0:0") .. awful.colors.white .. " - Chimaeral Sting |cFFAAD372(Recommended - Flex Casters)",
    size = 9,
    paddingTop = 5,
})

Information:Text({
    text = awful.textureEscape(356962, 22, "0:0") .. awful.colors.white .. " - Kindred Spirits |cFFAAD372(Recommended - Flex Melee)",
    size = 10,
    paddingTop = 5,
})

Information:Text({
  text = awful.textureEscape(356976, 22, "0:0") .. awful.colors.white .. " - The Beast Within |cFFAAD372(Recommended - Flex Fear Classes)",
  size = 8.5,
  paddingTop = 5,
})


local spacer0 = ui:Tab(awful.colors.white .. "          -                 ")

local Control = ui:Tab("   " .. awful.textureEscape(187650, 20, "0:-1") .. awful.colors.white .. " |cFFAAD372-  CC")
local icon_size = 13


Control:Text({
    text = awful.textureEscape(626000, 22, "0:0") .. awful.colors.white .. "   BM | |cFFAAD372Control   " .. awful.textureEscape(187650, 22, "0:0"),
    size = 15,
    paddingLeft = 35,
    paddingBottom = 15
})

Control:Text({text = awful.textureEscape(187650, icon_size) .. " |cFFAAD372Freezing Trap", header = true})

	Control:Dropdown({
		var = "trapThreshold",
		options = {
			{ label = "|cFFAAD372Ultra Safe", value = 0, tooltip = "Only throw unprotected traps that are almost guaranteed to land.\n\nGreatly increases the delay before committing to an auto trap, as it will wait for the perfect opportunity to catch them in a position they cannot counterplay.\n\n A good option, but not recommended for most players, it will often take a long time to throw a trap, which can be more harm than it is good.", default = false },
			{ label = "|cFFAAD372Safe", value = 1, tooltip = "Commit to unprotected traps that are highly likely to land.\n\nAdds a slight delay before committing to a trap when they have any abilities that can counterplay it. It will occasionally go for slightly more risky traps in good conditions.\n\n RECOMMENDED OPTION, great for most players, and a great chance at landing every single trap.", default = true },
			{ label = "|cFFAAD372Fair", value = 2, tooltip = "Throws unprotected traps that reasonably likely to land.\n\nReduces the delay before committing to a trap, but opens it up to the possibility of being counterplayed versus good players in some conditions.\n\n Not recommended for most players", default = false },
			{ label = "|cFFAAD372Risky", value = 3, tooltip = "Throw that trap bruh.\n\n Not recommended.", default = false },
		},
		placeholder = "Choose Threshold",
		tooltip = "Choose your risk acceptance rate for throwing unprotected traps.\n\nSafer risk thresholds will cause more delays and damage pausing as it attempts to bait potential trap counterplay.\n\nDelays are due to the routine patiently waiting to outplay the enemies by catching them on GCD and/or edging the trap perfectly as they stop moving to avoid trap eating.",
		default = 1,
		header = "|cFFAAD372Unprotected Trap Threshold:",
	})

	Control:Dropdown({
		var = "trapUnit",
		options = {
			{ label = "|cFFAAD372Healer", value = "healer", tooltip = "Routine will only pursue trap on the healer.\n\n This can work if you know for sure you will ONLY ever want to trap the Enemy Healer.\n\n Not recommended, as Focus option can achieve the same result by pairing it with Auto Focus." },
			{ label = "|cFFAAD372Focus", value = "focus", tooltip = "Routine will only pursue trap on your focus target.\n\n I personally recommend you to use this option paired with Auto Focus enabled.\n\n This way, if you want to change your trap target mid game, you are able to do so freely just by changing your focus target." },
		},
		placeholder = "Choose Unit",
		tooltip = "Choose the unit the routine should pursue trap on.\n\nDefault is Focus, since Auto Focus will prioritize setting the healer to your focus anyway, it simply gives you more control over trap pursuit.",
		default = "focus",
		header = "|cFFAAD372Trap Unit:",
	})

	Control:Checkbox({name = "|cFFAAD372Followup CC", default = true, var = "autoFollowup", tooltip = "Automatically followup with trap off of other CC effects.\n\nOnly traps when it is full DR, or half out of other incapacitate effects.\n\n Leave this enabled at all times."})
	Control:Checkbox({name = "|cFFAAD372Bait With Tar", default = true, var = "tarBait", tooltip = "Use Tar Trap to bait trap immunities\n\n(Death, Grounding, Mass Reflect, Port, Etc.)\n\nOnly attempts baits while telegraphing a trap.\n\n Leave this enabled at all times."})
	Control:Checkbox({name = "|cFFAAD372Trap Fear Pathing", default = true, var = "trapFears", tooltip = "Attempt to trap off of fear pathing by linear prediction immediately after a directional change.\n\nThese can occasionally miss from far distances, as fear pathing can change multiple times unpredictably.\n\n Leave this enabled at all times."})
	Control:Checkbox({name = "|cFFAAD372Trap On Cast", default = true, var = "trapCasts", tooltip = "Throw trap to interrupt casts while within unprotected trap distance threshold.\n\nThese can occasionally be counterplayed, as starting a spell cast does not incur the global cooldown.\n\n Leave this enabled at all times."})
	
	Control:Text({text = awful.textureEscape(19577, icon_size) .. " |cFFAAD372Intimidation Stun (Pick One)", header = true})

	Control:Checkbox({name = "|cFFAAD372Intim Trap-Target (Leave Enabled)", default = true, var = "autoStun", tooltip = "Automatically use intimidation to secure trap on the trap-target.\n\n Leave this enabled at all times."})
	Control:Checkbox({name = "|cFFAAD372Intim Kill Target", default = false, var = "stunKillTarget", tooltip = "Automatically use intimidation for cross-cc on kill target.\n\nRoutine will wait for trap or other cc on the trap target that guarantees a trap, as well as defensives on the kill target before stunning."})

  Control:Text({text = awful.textureEscape(109248, icon_size) .. " |cFFAAD372Binding Shot Stun", header = true})

	Control:Checkbox({name = "|cFFAAD372Binding Trap-Target (Leave Enabled)", default = true, var = "autoBindingShot", tooltip = "Automatically use Binding Shot to secure trap on the trap-target.\n\n Leave this enabled at all times."})
	Control:Checkbox({name = "|cFFAAD372Binding To Cover/Other Uses", default = true, var = "stunOthers", tooltip = "Automatically use Binding Shot to cover/other uses.\n\n Leave this enabled at all times."})
	Control:Checkbox({name = "|cFFAAD372MW TOGGLE", default = false, var = "MWTOGGLE", tooltip = "Automatically use Binding Shot to ensure best use cases VS Mistweavers\n\n YOU MUST ENABLE THIS VERSUS MISTWEAVERS!\n\n OTHERWISE, IF THERE ARE NO MISTWEAVERS, THEN DISABLE\n\n YOU MAY USE THE BUTTON TO TOGGLE THIS ON AND OFF INSTEAD OF IN THE GUI."})

  Control:Text({text = awful.textureEscape(213691, icon_size) .. " |cFFAAD372Scatter Shot", header = true})
	Control:Checkbox({name = "|cFFAAD372Scatter Trap-Target (Leave Enabled)", default = true, var = "autoScatterShot", tooltip = "Automatically use Scatter Shot to secure trap on the trap-target\n\n Leave this enabled at all times."})
	Control:Checkbox({name = "|cFFAAD372Scatter To Cover/Other Uses", default = true, var = "scatterOthers", tooltip = "Automatically use Scatter Shot to cover/other uses\n\n Leave this enabled unless you are playing with a DoT Class, in which case you should disable it."})

  Control:Text({text = awful.textureEscape(236776, icon_size) .. " |cFFAAD372High Explosive Trap (BETA)", header = true})
	Control:Checkbox({name = "|cFFAAD372Trap-Target (Binding) (Leave Enabled)", default = true, var = "autoExplosiveTrap", tooltip = "Automatically use Explosive Trap on the Trap-Target if they are in a Binding Shot.\n\n This is in BETA, the logic for it is being tested and improved daily. I will be adding more conditions for High Explosive Trap over time."})
	Control:Checkbox({name = "|cFFAAD372Knock Target (Defensives) (Leave Enabled)", default = true, var = "autoKnockBuffs", tooltip = "Automatically use Explosive Trap on your Target if they are in a AoE Defensive.\n\n This is in BETA, the logic for it is being tested and improved daily. I will be adding more conditions for High Explosive Trap over time."})

  Control:Text({text = awful.textureEscape(186387, icon_size) .. " |cFFAAD372Bursting Shot (BETA)", header = true})
	Control:Checkbox({name = "|cFFAAD372Trap-Target (Binding) (Leave Enabled)", default = true, var = "autoBurstingShot", tooltip = "Automatically use Bursting Shot on the Trap-Target if they are in a Binding Shot. This will take priority over Explosive Trap (you must be in melee range of the Trap Target to use it, as it has a very short range.\n\n This is in BETA, the logic for it is being tested and improved daily. I will be adding more conditions for Bursting Shot over time."})
	Control:Checkbox({name = "|cFFAAD372Knock Target (Defensives) (Leave Enabled)", default = true, var = "autoKnockBuffsBS", tooltip = "Automatically use Bursting Shot on your Target if they are in a AoE Defensive. This will take priority over Explosive Trap (you must be in melee range of the Trap Target to use it, as it has a very short range.\n\n This is in BETA, the logic for it is being tested and improved daily. I will be adding more conditions for Bursting Shot over time."})

  Control:Text({text = awful.textureEscape(147362, icon_size) .. " |cFFAAD372Counter Shot", header = true})
	Control:Checkbox({name = "|cFFAAD372Only Kick CC", default = false, var = "onlyKickCC", tooltip = "Only use kicks on CC, not damage or healing kicks.\n\nRecommended for CC Heavy Comps (Jungle/RMP/etc).", paddingLeft = 5})


  Control:Text({text = awful.textureEscape(186257, icon_size) .. " |cFFAAD372Utility For Traps", header = true})
	Control:Checkbox({name = "|cFFAAD372Cheetah for Traps", default = true, var = "autoCheetah", tooltip = "Automatically use cheetah to secure trap on the trap-target.\n\n Leave this enabled, but it will be rare to trigger the use case for it. I recommended you also bind Cheetah yourself."})

  Control:Text({text = awful.textureEscape(781, icon_size) .. " |cFFAAD372Disengage Tech", header = true})
  Control:Checkbox({name = "|cFFAAD372Disengage Tech (DISABLE /USERNAME YOLO)", default = false, var = "disengageTech", tooltip = "Automatically use Disengage to secure trap on the trap-target and for other various uses\n\n YOU MUST DISABLE AWFUL SAFETY FEATURES TO USE THIS BY DOING:\n\n (/USERNAME YOLO)."})

  local spacer0 = ui:Tab(awful.colors.white .. "           -                     ")

  local Config = ui:Tab("   " .. awful.textureEscape(321297, 18, "0:-1") .. awful.colors.white .. " |cFFAAD372-  Config")

  Config:Text({
    text = awful.textureEscape(626000, 22, "0:0") .. awful.colors.white .. "   BM | |cFFAAD372Config   " .. awful.textureEscape(321297, 22, "0:0"),
    size = 15,
    paddingLeft = 35,
    paddingBottom = 15
})

Config:Text({text = awful.textureEscape(186265, icon_size) .. " |cFFAAD372Turtle Sensitivity Slider", header = true})
  
  Config:Slider({
    text = awful.textureEscape(186265, 22, "0:0") .. awful.colors.priest .. "  -  Turtle Sensitivity %",
    var = "turtlesens", -- checked bool = settings.autoburst
    min = 0.4,
    max = 0.8,
    default = 0.6,
    step = 0.01,
    valueType = "x",
    tooltip = "Lower = Riskier.",
  })

  Config:Slider({
    text = awful.textureEscape(109304, 22, "0:0") .. awful.colors.priest .. "  -  Auto Exhilarate %",
    var = "autoexhilarate", -- checked bool = settings.autoburst
    min = 0,
    max = 100,
    default = 45,
    step = 1,
    tooltip = "Lower = Riskier.",
  })

  Config:Text({text = awful.textureEscape(883, icon_size) .. " |cFFAAD372Summon Pet Selection", header = true})

  Config:Dropdown({
    var = "CallPetMode",
    default = "pet1",
    tooltip = "Select which pet routine should call.\n\nCalling Pets is sorted by your stable index.",
    options = {
        { label = awful.textureEscape(883, 16) .. " |cFFAAD372Call Pet 1", value = "pet1", tooltip = "Call Pet 1 from your stable." },
        { label = awful.textureEscape(83242, 16) .. " |cFFAAD372Call Pet 2", value = "pet2", tooltip = "Call Pet 2 from your stable." },
        { label = awful.textureEscape(83243, 16) .. " |cFFAAD372Call Pet 3", value = "pet3", tooltip = "Call Pet 3 from your stable." },
        { label = awful.textureEscape(83244, 16) .. " |cFFAAD372Call Pet 4", value = "pet4", tooltip = "Call Pet 4 from your stable." },
        { label = awful.textureEscape(83245, 16) .. " |cFFAAD372Call Pet 5", value = "pet5", tooltip = "Call Pet 5 from your stable." },
    },
    placeholder = "|cFFAAD372Select which pet routine should call",
    header = awful.textureEscape(883, 16) .. " |cFFAAD372Call Pet by stable index:",
    size = 20,
  })

  Config:Checkbox({
    text = awful.textureEscape(186265, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Auto Defensives",
    var = "autodef", -- boolean = settings.esp
    default = true,
    tooltip = "Enable or Disable Auto Defensives.\n\n Recommended to leave this enabled."
  })

  Config:Checkbox({
    text = awful.textureEscape(883, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Auto Summon Pet",
    var = "autosummonpet", -- boolean = settings.esp
    default = true,
    tooltip = "Enable or Disable Auto Summon Pet.\n\n Disable if you'd want to summon your pet manually."
  })

  Config:Checkbox({
    text = awful.textureEscape(6197, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Auto Focus",
    var = "autofocus", -- boolean = settings.esp
    default = true,
    tooltip = "Enable or Disable Auto Focus.\n\n LEAVE THIS ENABLED IF USING: FOCUS AS TRAP-TARGET MODE."
  })


  Config:Checkbox({
    text = awful.textureEscape(187650, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Auto Eat Traps (rare)",
    var = "peteattrap", -- boolean = settings.esp
    default = true,
    tooltip = "Enable or Disable Auto Eat Traps.\n\n Rarely triggers, but when it does, it's a game changer, leave it enabled."
  })
  
  Config:Checkbox({
    text = awful.textureEscape(19574, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Auto Burst",
    var = "autoburst", -- boolean = settings.esp
    default = true,
    tooltip = "Enable or Disable Auto Burst.\n\nLEAVE THIS ENABLED AT ALL TIMES."
  })

  Config:Checkbox({
    text = awful.textureEscape(8178, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Auto Totem Stomp",
    var = "autostomp", -- boolean = settings.esp
    default = true,
    tooltip = "Enable or Disable Auto Totem Stomp.\n\nLEAVE THIS ENABLED AT ALL TIMES."
  })

  Config:Checkbox({
    text = awful.textureEscape(321297, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Auto Targeting",
    var = "autotarget", -- boolean = settings.esp
    default = false,
    tooltip = "Enable or Disable Auto Targeting.\n\nPersonal Preference, I would recommend that you target enemies yourself."
  })

local spacer0 = ui:Tab(awful.colors.white .. "           -                      ")

local Draws = ui:Tab("   " .. awful.textureEscape(6197, 20, "0:-1") .. awful.colors.white .. " |cFFAAD372-  Draws")

Draws:Text({
  text = awful.textureEscape(626000, 22, "0:0") .. awful.colors.white .. "   BM | |cFFAAD372Draws   " .. awful.textureEscape(6197, 22, "0:0"),
  size = 15,
  paddingLeft = 35,
  paddingBottom = 15
})


Draws:Checkbox({
  text = awful.textureEscape(83950, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Enable Drawings (recommended)",
  var = "drawings", -- boolean = settings.esp
  default = true,
  tooltip = "Enable or Disable Drawings.\n\nLEAVE THIS ENABLED AT ALL TIMES."
})

Draws:Checkbox({
  text = awful.textureEscape(187650, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Draw Trap ESP (recommended)",
  var = "trapesp", -- boolean = settings.esp
  default = true,
  tooltip = "Enable or Disable Trap ESP.\n\nLEAVE THIS ENABLED AT ALL TIMES."
})

Draws:Checkbox({
  text = awful.textureEscape(19577, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Draw Trap-Target (recommended)",
  var = "drawtraptarget", -- boolean = settings.esp
  default = true,
  tooltip = "Enable or Disable Draw Trap-Target.\n\nThis draw will show you the distance you need to maintain to your trap-target to ensure the Combo's can be used correctly.\n\nLEAVE THIS ENABLED AT ALL TIMES."
})

Draws:Checkbox({
  text = awful.textureEscape(267316, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Draw Suggestive Alerts(recommended)",
  var = "drawalerts", -- boolean = settings.esp
  default = true,
  tooltip = "Enable or Disable Suggestion Alerts.\n\nLEAVE THIS ENABLED AT ALL TIMES."
})

Draws:Checkbox({
  text = awful.textureEscape(230027, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Draw healer line (recommended)",
  var = "drawhealer", -- boolean = settings.esp
  default = true,
  tooltip = "Enable or Disable line to friendly healer.\n\nRecommended to leave this enabled."
})

Draws:Checkbox({
  text = awful.textureEscape(302582, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Draw enemy players(not recommended)",
  var = "drawenemy", -- boolean = settings.esp
  default = false,
  tooltip = "Enable or Disable Enemy ESP.\n\nRecommended to leave this DISABLED unless you want to use it for BGs."
})

Draws:Checkbox({
  text = awful.textureEscape(302582, 22, "0:12") .. awful.colors.priest .. " - |cFFAAD372Draw Totem ESP (recommended)",
  var = "totemesp", -- boolean = settings.esp
  default = true,
  tooltip = "Enable or Disable Totem ESP.\n\nRecommended to leave this enabled."
})

local spacer0 = ui:Tab(awful.colors.white .. "           -                 ")

local Macros = ui:Tab("   " .. awful.textureEscape(781, 20, "0:-1") .. awful.colors.white .. " |cFFAAD372-  Macros")

Macros:Text({
  text = awful.textureEscape(626000, 22, "0:0") .. awful.colors.white .. "   BM | |cFFAAD372Macros   " .. awful.textureEscape(781, 22, "0:0"),
  size = 15,
  paddingLeft = 35,
  paddingBottom = 15
})

Macros:Text({
  text = awful.textureEscape(187650, 22, "0:0") .. awful.colors.white .. " - /username trap (recommended)",
  size = 10,
  paddingBottom = 15,
  tooltip = "This macro will speed up your trap in situations where you do not have pre-cc OR in situations where you'd be following up on other CC with a trap.",
})

Macros:Text({
  text = "|cFFAAD372YOU MUST DISABLE AWFUL SAFETY FEATURES TO USE DISENGAGE MACROS:\n\n            (/USERNAME YOLO)",
  size = 12,
  paddingLeft = 10,
  paddingTop = 10,
  paddingBottom = 10
})


Macros:Text({
  text = awful.textureEscape(781, 22, "0:0") .. awful.colors.white .. " - /username disengage forward",
  size = 10,
  paddingTop = 15,
})

Macros:Text({
  text = awful.textureEscape(781, 22, "0:0") .. awful.colors.white .. " - /username disengage enemyhealer",
  size = 10,
  paddingTop = 8,
})

Macros:Text({
  text = awful.textureEscape(781, 22, "0:0") .. awful.colors.white .. " - /username disengage focus",
  size = 10,
  paddingTop = 8,
})

Macros:Text({
  text = awful.textureEscape(781, 22, "0:0") .. awful.colors.white .. " - /username disengage flow",
  size = 10,
  paddingTop = 8,
})


Macros:Text({
  text = "|cFFAAD372IT IS NOT REQUIRED TO USE DISENGAGE MACROS, IT IS JUST A BONUS IF YOU WANT TO USE THEM.\n\n\nBe sure to enable the GUI toggle to use disengage macros, as well as disable Awful's Safety Feature by doing:\n\n/username yolo",
  size = 9,
  paddingLeft = 10,
  paddingTop = 35,
  paddingBottom = 10
})


awful.Draw(function(draw)

  if settings.drawings and settings.totemesp then
      awful.units.loop(function(unit)
          for uid, data in pairs(unitIDs) do
              if uid == unit.id then
                  local ux, uy, uz = unit.position()
                  if ux and uy and uz then
                      if unit.friend then
                          draw:SetColor(50, 205, 50)
                      end
                      if unit.enemy then
                          draw:SetColor(220, 20, 60)
                      end
                      draw:Outline(ux, uy, uz, data.radius)
                      draw:SetColor(data.r, data.g, data.b)
                      if uid == 179867 and not unit.friend then
                          draw:FilledCircle(ux, uy, uz, data.radius * (1 - (unit.uptime / 6)))
                      else
                          draw:FilledCircle(ux, uy, uz, data.radius * (unit.castpct / 100))
                      end
                  end
              end
          end
      end)
  end
end)

awful.Draw(function(draw)
  if settings.drawings and settings.totemesp then
      awful.units.loop(function(unit)
          for uid, data in pairs(unitIDs) do
              if uid == unit.id then
                  local ux, uy, uz = unit.position()
                  if ux and uy and uz then
                      if unit.friend then
                          draw:SetColor(50, 205, 50)
                      end
                      if unit.enemy then
                          draw:SetColor(220, 20, 60)
                      end
                      draw:Outline(ux, uy, uz, data.radius)
                      draw:SetColor(data.r, data.g, data.b)
                      if uid == 179867 and not unit.friend then
                          draw:FilledCircle(ux, uy, uz, data.radius * (1 - (unit.uptime / 6)))
                      else
                          draw:FilledCircle(ux, uy, uz, data.radius * (unit.castpct / 100))
                      end
                  end
              end
          end
      end)
  end

  if settings.drawings and settings.drawhealer then
      if not healer.exists then return end
      if healer.visible then
          local lining = not healer.los
          local ranging = healer.dist > 38.5
          draw:SetWidth(4 + bin(lining or ranging) + bin(lining) + bin(ranging))
          local colorValue = 0
  
          if not (lining or ranging) then
              -- Set color to green (0, 255, 0)
              draw:SetColor(0, 255, 0, 255)
          else
              -- Set color to shades of purple based on lining/ranging
              colorValue = bin(lining or ranging) * 155
              draw:SetColor(100 + colorValue, 100, 255 - colorValue, 255)
          end
  
          local px, py, pz = player.position()
          local hx, hy, hz = healer.position()
          draw:Line(px, py, pz, hx, hy, hz)
      end
  end

  for _, enemy in ipairs(awful.enemies) do 
      
 
      if settings.drawings and settings.drawenemy and enemy.player then                        
      local icon = awful.textureEscape(626006, 16, "0:2")
      if enemy.class2 == "SHAMAN" then draw:SetColor(0, 112, 221, 225) icon = awful.textureEscape(626006, 16, "0:2")  end
      if enemy.class2 == "ROGUE" then draw:SetColor(255, 244, 104, 225)  icon = awful.textureEscape(626005, 16, "0:2") end
      if enemy.class2 == "WARRIOR" then draw:SetColor(198, 155, 109, 225) icon = awful.textureEscape(626008, 16, "0:2") end
      if enemy.class2 == "WARLOCK" then draw:SetColor(135, 136, 238, 225) icon = awful.textureEscape(626007, 16, "0:2")  end
      if enemy.class2 == "DRUID" then draw:SetColor(255, 124, 10, 225) icon = awful.textureEscape(625999, 16, "0:2")  end
      if enemy.class2 == "PRIEST" then draw:SetColor(255, 255, 255, 225) icon = awful.textureEscape(626004, 16, "0:2")  end
      if enemy.class2 == "PALADIN" then draw:SetColor(244, 140, 104, 225) icon = awful.textureEscape(626003, 16, "0:2")  end
      if enemy.class2 == "MAGE" then draw:SetColor(63, 199, 235, 225) icon = awful.textureEscape(626001, 16, "0:2")  end
      if enemy.class2 == "DEATHKNIGHT" then draw:SetColor(196, 30, 58, 225) icon = awful.textureEscape(135771, 16, "0:2") end
      if enemy.class2 == "HUNTER" then draw:SetColor(170, 211, 114, 225) icon = awful.textureEscape(626000, 16, "0:2") end
      if enemy.class2 == "DEMONHUNTER" then draw:SetColor(163, 48, 201, 225) icon = awful.textureEscape(1260827, 16, "0:2") end
      if enemy.class2 == "MONK" then draw:SetColor(0, 255, 152, 225) icon = awful.textureEscape(626002, 16, "0:2") end
    
          local ex, ey, ez = enemy.position()
          if (ey == nil ) then  return end
          local level = enemy.level
          local name = enemy.name
          local text = (name .." [" .. tostring(level) .. "] ")
         
          draw:Text(text .. icon ,"GameFontHighlight", ex, ey+1, ez+4)
       
       end
   end
end)


awful.Draw(function(draw)
  if not settings.totemesp then return end
  awful.triggers.loop(function(trigger)
      if trigger.id ~= 198839 then return end --friendly earthen--
      if trigger.distance > 60 then return end 
      if trigger.creator.friend then
      local x,y,z = trigger.position()
      draw:SetColor(100, 255, 100, 200)
      draw:Outline(x,y,z,10.5)
      end
  end)
end)

local Buttons = ui:StatusFrame({
    colors = {
        background = { 0, 0, 0, 0 },
        enabled = { 30, 240, 255, 1 },
    },
    maxWidth = 500,
    padding = 7,
})


Buttons:Button({
    spellID = 217200,
    var = "enable",
    default = false,
    size = 30,
    text = function()
        if settings.enable then
            return awful.colors.green .. "On"
        else
            return awful.colors.red .. "Off"
        end
    end,
})

Buttons:Button({
  spellID = 211236,
  var = "MWTOGGLE",
  default = false,
  size = 30,
  paddingLeft = 10,
  text = function()
    if settings["MWTOGGLE"] then
      return awful.colors.green .. "On"
    else
      return awful.colors.red .. "Off"
    end
  end,
})

Buttons:Button({
  spellID = 213691,
  var = "scatterOthers",
  default = false,
  size = 30,
  paddingLeft = 5,
  text = function()
    if settings["scatterOthers"] then
      return awful.colors.green .. "On"
    else
      return awful.colors.red .. "Off"
    end
  end,
})

awful.Populate({

-- damage spells --
killCommand = NS(34026, {damage = "physical", targeted = true}),
killShot = NS(53351, { damage = "physical", ranged = true, targeted = true }),
cobraShot = NS(193455, { damage = "physical", ranged = true, targeted = true }),
barbedShot = NS(217200, { damage = "physical", ranged = true, targeted = true }),
blackArrow = NS(466930, { damage = "magical", ranged = true, targeted = true }),
steadyShot = NS(56641, { damage = "physical", ranged = true, targeted = true}),
explosiveShot = NS(212431, { damage = "physical", ranged = true, targeted = true }),
-- end damage spells --

-- burst cds spells --
direBeast = NS(120679, { damage = "physical", targeted = true }),
beastialWrath = NS(19574, { beneficial = true, targeted = false, ignoreGCD = true}),
bloodshed = NS(321530, {damage = "physical", targeted = true, bleed = true }),
callOfTheWild = NS(359844, {beneficial = true, targeted = false }),
-- end burst cds spells --

-- cc spells --
tar = NS(187698, {effect = "magic", targeted = false, slow = true  }),
trap = hunter.trap,
counterShot = NS(147362, { effect = "physical", kick = true, ranged = true }),
scatterShot = NS(213691, { effect = "physical", ranged = true, cc = "incapacitate", targeted = true }),
burstingShot = NS(186387, { effect = "physical", ranged = true, targeted = false }),
binding = NS(109248, { effect = "magic", cc = "stun", ranged = true, targeted = false, ignoreFacing = true, radius = 5 }),
chimaeralSting = NS(356719, { effect = "magic", cc = "silence", ranged = true, targeted = true }),
intimidation = NS(19577, { effect = "magic", cc = "stun", ranged = true, targeted = true, ignoreFacing = true }),
-- end cc spells --

-- utility spells --
flare = NS(1543, { radius = 10 }),
disengage = hunter.disengage,
conc = NS(5116, { effect = "physical", ranged = true, targeted = true }),
tranquilizingShot = NS(19801, { effect = "magic", ranged = true, targeted = true }),
camo = hunter.camo,
cheetah = NS(186257, { beneficial = true, ignoreGCD = true }),
mastersCall = NS(272682, { beneficial = true, ignoreFacing = true, ignoreLoS = true, ignoreControl = true}),
highExplosiveTrap = NS(236776, { effect = "magic", ignoreFacing = true}),
-- end utility spells --

-- defensive spells --
survivalOfTheFittest = NS(264735, { beneficial = true, ignoreGCD = true }),
exhilaration = NS(109304, { beneficial = true, heal = true, ignoreGCD = true}),
aspectOfTheTurtle = NS(186265, { beneficial = true }),
feign = NS(5384, {ignoreCasting = true, ignoreChanneling = true, ignoreGCD = true, mustBeGrounded = true }),
roarOfSacrifice = NS(53480, { beneficial = true, ignoreGCD = true, ignoreControl = true, ignoreFacing = true, ignoreMoving = true}),



fortitude = NS({388035}, { heal = true, beneficial = true, ignoreGCD = true }),

commandPetLust = NS({272651, 272678}, { beneficial = true, ignoreGCD = true, ignoreFacing = true, ignoreMoving = true, targeted = false }),

-- end defensive spells --

-- misc spells --
huntersMark = NS(257284),
mend = NS(136, { heal = true, targeted = false }),
dismissPet = NS(2641, {targeted = false}),
res = NS(982, {beneficial = true, targeted = false }),
callPetOne = NS(883, {beneficial = true, targeted = false}),
callPetTwo = NS(83242, {beneficial = true, targeted = false}),
callPetThree = NS(83243, {beneficial = true, targeted = false}),
callPetFour = NS(83244, {beneficial = true, targeted = false}),
-- end misc spells --

-- racials --
WillToSurvive = NS(59752, { beneficial = true, ignoreControl = true }),
escapeArtist = NS(20589, { beneficial = true, ignoreControl = true }),
BloodFury = NS(20572, { beneficial = true, ignoreGCD = true }),
Berserking = NS(26297, { beneficial = true }),
AncestralCall = NS(274738, { beneficial = true }),
shadowmeld = NS(58984, { ignoreCasting = true, ignoreChanneling = true, ignoreGCD = true }),
-- end racials --
}, bm, getfenv(1))

gifted.SCATTER_SHOT_TALENT = 213691

local spiritMend = NS({90361, 237586}, { ignoreFacing = true, ignoreGCD = true, heal = true, pet = true })
local dash = NS(61684, { ignoreFacing = true, ignoreGCD = true, pet = true })
hunter.conc = conc


-- start functions and lists --

local GetSpellInfo = GetSpellInfo or function(spellID)
    if not spellID then
      return nil;
    end
  
    local spellInfo = C_Spell.GetSpellInfo(spellID);
    if spellInfo then
      return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID;
    end
  end

local debounceCache = {}

gifted.debounce = function(key, min, reset, func, verify)
    local matching = debounceCache[key]
    local now = GetTime() * 1000

    if not matching then
        debounceCache[key] = now
        return
    end

    if matching + reset < now then
        debounceCache[key] = now
        return
    end

    if matching + min > now then return end

    if verify then
        if func() then
            debounceCache[key] = nil
        end
        return
    end

    debounceCache[key] = nil
    func()
end

gifted.debounceSpell = function(key, min, reset, spell, unit)
    local matching = debounceCache[key]
    local now = GetTime() * 1000

    if not matching then
        debounceCache[key] = now
        return
    end

    if matching + reset < now then
        debounceCache[key] = now
        return
    end

    if matching + min > now then return end

    local result

    if unit then
        result = spell:Cast(unit)
    else
        result = spell:Cast()
    end

    if result then
        debounceCache[key] = nil
    end

    return result
end


function MinDelayTime()
    local _delay = awful.delay(0.25, 0.5)
    return _delay.now
end

local cantRoot = {
    227847, --bladestorm
    48707, --AMS
    31224, --cloak
    1044, -- freedom
}


awful.onUpdate(function()
    if settings.enable then
        awful.enabled = true
    else
        awful.enabled = false
    end
end)

gifted.WasCasting = { }

gifted.WasCastingCheck = function()
    local time = awful.time
    if player.casting then
        gifted.WasCasting[player.castingid] = time
    end
    for spell, when in pairs(gifted.WasCasting) do
        if time - when > 0.100+awful.latency then
            gifted.WasCasting[spell] = nil
        end
    end
end

local badges = awful.Item({
    218421, 218713,
})

function Badge()
    if not badges.equipped then return end
    if not player.cds then return end
    if badges.usable and badges.cd <= 0 then
        if badges:Use() then
            awful.alert({
                message = awful.colors.purple .. " - Using Badge",
                texture = 102747,
                big = true,
                highlight = true,
                outline = "OUTLINE"
            })
        end
    end
end

local BMTrinket = awful.Item({
    219933, 218424, 218715, 
})

function BMTrink()
    if not BMTrinket.equipped then return end
    if BMTrinket.usable and BMTrinket.cd <= 0 then
        if player.hp < 30 then
            if BMTrinket:Use() then
                awful.alert({
                    message = awful.colors.purple .. " - Using Battlemasters!",
                    texture = 205781,
                    big = true,
                    highlight = true,
                    outline = "OUTLINE"
                })
            end
        end
    end
end

local DontDefensive = {
    -- druid
    [362486] = true, -- tranq/presuring nature
    [22812] = true, -- barkskin
    [61336] = true, -- survival instinct
    -- paladin
    [204018] = true, -- blessing of spellwarding
    [1022] = true, -- blessing of protection
    [642] = true, -- divine shield
    --hunter
    [186265] = true, -- turtle
    [264735] = true, -- survival of the fittest
    --mage
    [198111] = true, -- temporal shield
    [342246] = true, -- alter time
    [45438] = true, -- ice block
    [113862] = true, -- mass invisibility
    --priest
    [232708] = true, -- ray of hope
    [47585] = true, -- dispersion
    [33206] = true, -- pain suppression
    [47788] = true, -- guardian spirit
    [443526] = true, -- premonition of solace shield
    --evoker
    [378441] = true, -- time stop
    [363916] = true, -- obsidian scales
    [374348] = true, -- renewing blaze
    [370960] = true, -- emerald communion
    [363534] = true, -- rewind
    --warlock
    [104773] = true, -- unending resolve
    --monk
    [125174] = true, --karma
    [120954] = true, -- fort brew
    [122783] = true, -- diffuse magic
    [116849] = true, -- cocoon
    [353319] = true, -- peaceweaver/revival
    --warrior
    [118038] = true, -- die by the sword
    [184364] = true, -- enraged regen
    --rogue
    [5277] = true, -- evasion
    [31224] = true, -- cloak of shadows
    --shaman
    [114893] = true, -- stone bulwark
    [108271] = true, -- astral shift
    [409293] = true, -- burrow
    --demon hunter
    [209426] = true, -- darkness
    [212800] = true, -- blur
    [196555] = true, -- netherwalk
    --dk
    [410358] = true, -- ams friend
    [48792] = true, -- icebound fortitude
    [48707] = true, -- anti magic shell
    [145629] = true, -- anti-magic zone
}

local DontDefensivePlayer = {

    --hunter
    [202748] = true, -- survival tactcs
    [186265] = true, -- turtle
    [264735] = true, -- survival of the fittest
    [388035] = true, -- fortitude of the bear
    [53480] = true, -- roar of sacrifice
}

local DefensiveKnockBuffs = {

  [81782] = true, -- power word: barrier
  [145629] = true, -- anti-magic zone
  [209426] = true, -- darkness
  [201633] = true, -- earthen wall totem (maybe only if right on top of the unit, as its a large radius)

}

--Slow By buff name table
local BigDamageBuffs =
{
  --Incarnation
  [102543] = function(source)
    return source.role == "melee" or source.role == "ranged"
  end,
  --wings
  [31884] = function(source)
    return source.role == "melee"
  end,
  --wings
  [231895] = function(source)
    return source.role == "melee"
  end,
  --doomwinds
  [384352] = function(source)
    return source.class2 == "SHAMAN" and source.role == "melee"
  end,
  --Serenity
  [152173] = function(source)
    return source.role == "melee"
  end,
  --boondust
  [386276] = function(source)
    return source.role == "melee"
  end,
  --trueshot
  [288613] = function(source)
    return true
  end,
  --Coordinated Assault
  [266779] = function(source)
    return true
  end,
  --Coordinated Assault2
  [360952] = function(source)
    return true
  end,
  --Shadow Dance
  [185422] = function(source)
    return true
  end,
  --Shadow Blades
  [121471] = function(source)
    return true
  end,  
  --Adrenaline Rush
  [13750] = function(source)
    return true
  end,  
  --Combustion
  [190319] = function(source)
    return true
  end,  
  --Pillar of Frost
  [51271] = function(source)
    return true
  end,
  --Unholy Assault
  [207289] = function(source)
    return true
  end,
  --Metamorphosis
  [162264] = function(source)
    return true
  end,
  --Recklessness
  [1719] = function(source)
    return true
  end,
  --Avatar
  [107574] = function(source)
    return true
  end,
  --warbreaker
  [167105] = function(source)
    return true
  end,

} 

local FDBigDam = {
  --Incarnation Ashame - Feral
  [102543] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player)
  end,
  --Incarnation Chosen - Boomkin
  [102560] = function(source)
    return source.role == "ranged" and source.target.isUnit(player) and player.hp <= 85 and source.losOf(player)
  end,
  --wings
  [31884] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --wings
  [231895] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --doomwinds
  [384352] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Serenity
  [152173] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --boondust
  [386276] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --trueshot
  [288613] = function(source)
    return source.target.isUnit(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Coordinated Assault
  [266779] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Coordinated Assault2
  [360952] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Shadow Dance
  [185422] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Shadow Blades
  [121471] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,  
  --Adrenaline Rush
  [13750] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,  
  --Combustion
  [190319] = function(source)
    return source.target.isUnit(player) and player.hp <= 85 and source.losOf(player)
  end, 
  --Arcane Surge
  [365362] = function(source)
    return source.target.isUnit(player) and player.hp <= 85 and source.losOf(player)
  end,  
  --ele Primordial Wave
  [375986] = function(source)
    return source.target.isUnit(player) and player.hp <= 85 and source.losOf(player)
  end,  
  --Boomie
  [202425] = function(source)
    return source.target.isUnit(player) and player.hp <= 85 and source.losOf(player)
  end,  
  --Pillar of Frost
  [51271] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Unholy Assault
  [207289] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Metamorphosis
  [162264] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player)
  end,
  --Recklessness
  [1719] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Avatar
  [107574] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --warbreaker
  [167105] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  -- eternity surge
  [382411] = function(source)
    return source.target.isUnit(player) and source.losOf(player) and source.distance <= 25
  end,
  [263165] = function(source)
    return source.target.isUnit(player) and source.losOf(player) and player.hp <= 85 and source.distance <= 40
  end,
}

gifted.lowest = function(list)
  if list and list.lowest then
    return list.lowest.hp or 100
  else
    return 100
  end
end

gifted.fullImmunityBuffs = {
  [196555] = true, -- Netherwalk
  [202748] = true, -- Survival tactics
  [198111] = true, -- Temporal Shield
  [110909] = true, -- Alter Time (F/B,Arcane)
  [125174] = true, -- Touch of Karma (player buff) target debuff(122470)
  [116849] = true, -- Life Cocoon
  [228050] = true, -- Guardian of the Forgotten Queen (P,T)
  [232708] = true, -- Ray of Hope (delay dmg - blue,delay heal - yellow)
  [186265] = true, -- Aspect of the Turtle
  [47585] = true, -- Dispersion
  [1022] = true, -- Blessing of Protection
  [53480] = true, -- Roar of Sacrifice
  [264735] = true, -- Survival of the Fittest
}

function setFocus()
    if settings.autofocus then
        awful.AutoFocus()
    end
end

function BurstAlert()

  if not settings.drawalerts then return end

  if player.buff(19574) or player.buff(20572) or player.buff(359844) then
    awful.alert({
      message = awful.colors.green .. " - BURST CDS ACTIVE",
      big = false,
      highlight = true,
      outline = "OUTLINE"
    })
  end
end

function Soulwell()

    if GetItemCount(5512) > 0 and IsUsableItem(5512) then return end
  
    if not player.combat then
        awful.objects.loop(function(obj)
            if player.distanceTo(obj) <= 3 and obj.name == "Soulwell" then
                gifted.debounce("interact_soulwell", 4500, 6500, function()
                    obj:interact()
                    return true
                end, true)
            end
        end)
    end
end

local healerLocked = false

local healerLockouts = {
    ["DRUID"] = "nature",
    ["PRIEST"] = "holy",
    ["PALADIN"] = "holy",
    ["SHAMAN"] = "nature",
    ["MONK"] = "nature",
    ["EVOKER"] = "nature"
}

function gifted.CheckHealerLocked()
    if not player.combat then return end
    if not awful.arena then return end
    if not enemyHealer.exists then return end

    if healerLockouts[enemyHealer.class2] then
        local lockoutSchool = healerLockouts[enemyHealer.class2]

        if enemyHealer.lockouts[lockoutSchool] then
            healerLocked = true
        else
            healerLocked = false
        end
    else
        healerLocked = false
    end
end


local healthstone = awful.Item(5512)
local healthstoneUsed = 0

function Healthstone()

    if not awful.hasControl then return end

    if not player.combat then return end

    if healthstone.count == 0 then return end

    if healthstone.cd > 0 then  return end

    if not healthstone.usable then return end

    if player.hp < settings.healthstonehp then
        if healthstone:Use() then
            healthstoneUsed = awful.time
            awful.alert({
                message = awful.colors.purple .. " - Using Healthstone",
                big = true,
            })
        end
    end
end

local friendBursting = false

function CheckfriendBursting()
    if not player.combat or not settings.teamburst or not awful.arena then
        friendBursting = false
        return
    end

    local anyFriendBursting = false

    awful.group.loop(function(friend)
        if friend.healer then return end
        if friend.cds then
            anyFriendBursting = true
        end
    end)

    friendBursting = anyFriendBursting
end

local MWPort = { [54569] = true }

function TrackMWPort()

  if not awful.fighting(270, true) then return end

  local portUnit = awful.units.find(function(unit)
    return unit.id == 54569
  end)

  if portUnit and enemyHealer.exists then

    local portX, portY, portZ = portUnit.position()
    local healerX, healerY, healerZ = enemyHealer.position()
    local distanceToHealer = awful.Distance(portX, portY, portZ, healerX, healerY, healerZ)

    if distanceToHealer <= 40 then
       return true

    else

      return false
    end
  end
end

awful.Draw(function(draw)

  if not awful.fighting(270, true) then return end

    local portUnit = awful.units.find(function(unit)
        return unit.id == 54569
    end)

    if portUnit and enemyHealer.exists then
        local portX, portY, portZ = portUnit.position()
        local healerX, healerY, healerZ = enemyHealer.position()
        local distanceToHealer = awful.Distance(portX, portY, portZ, healerX, healerY, healerZ)

        if distanceToHealer <= 40 then
            draw:SetColor(0, 255, 0) -- Green color
        else
            draw:SetColor(255, 0, 0) -- Red color
        end

        draw:SetWidth(3) -- Set the width to make the circle thicker
        draw:FilledCircle(portX, portY, portZ, 3) -- Draw a filled circle around the port
    end
end)

local flags = {"Alliance Flag", "Horde Flag"}
local flagDropTime = 0

onEvent(function(info, event, source, dest)
  local time = GetTime()
  if event ~= "SPELL_AURA_REMOVED" then return end
  local spellID, spellName, _, auraType = select(12, unpack(info))
  if auraType ~= "DEBUFF" then return end
  if source.isUnit(awful.player) and tContains(flags, spellName) then
    flagDropTime = time
  end
end)

function gifted.FlagPick()
  if awful.instanceType2 == "pvp" then
    if GetTime() - flagDropTime > 3 then
      awful.objects.loop(function(obj)

        if obj.distance > 5 then return end
        C_Timer.After(0.5, function()  
          if obj.name == "Alliance Flag" then
            obj:interact()
            return awful.alert(awful.colors.blue .. "Pickup Alliance Flag", 23335)
          elseif obj.name == "Horde Flag" then 
            obj:interact()
            return awful.alert(awful.colors.red .."Pickup Horde Flag", 23333)
          end  
        end) 
      end)
    end
  end
end

gifted.FindOffTarget = function()
  local bestOffTarget = nil
  local bestOffTargetCount = 0
  local bestOffTargetHp = 0
  awful.enemies.loop(function(enemy)
      if enemy.isUnit(enemyHealer) then return end
      local count = enemy.v2attackers()
      if bestOffTarget == nil then
      bestOffTarget = enemy
      bestOffTargetCount = count
      bestOffTargetHp = enemy.hp 
      elseif count < bestOffTargetCount then
      bestOffTarget = enemy
      bestOffTargetCount = count
      bestOffTargetHp = enemy.hp 
      elseif count == bestOffTargetCount and enemy.hp > bestOffTargetHp then
      bestOffTarget = enemy
      bestOffTargetCount = count
      bestOffTargetHp = enemy.hp 
      end
  end)
  return bestOffTarget
end

gifted.FindKillTarget = function()
  local killTarget = nil
  local killTargetCount = 0
  local killTargetHp = 0
  awful.enemies.loop(function(enemy)
      if enemy.isUnit(enemyHealer) then return end
      local count = enemy.v2attackers()
      if killTarget == nil then
      killTarget = enemy
      killTargetCount = count
      killTargetHp = enemy.hp 
      elseif count > killTargetCount then
      killTarget = enemy
      killTargetCount = count
      killTargetHp = enemy.hp 
      elseif count == killTargetCount and enemy.hp < killTargetHp then
      killTarget = enemy
      killTargetCount = count
      killTargetHp = enemy.hp 
      end
  end)
  return killTarget
end

local _antiCC = math.huge

awful.addUpdateCallback(function()
    if _antiCC < (awful.time - 1) then
        _antiCC = math.huge
    end
end)

local priestUsed = 0

onEvent(function(info, event, source, dest)
    if not player.combat then return end
    if event ~= "SPELL_CAST_SUCCESS" then return end
    if not source.enemy then return end
    if not source.isUnit(enemyHealer) then return end

    local spellID, spellName = select(12, unpack(info))
    if (spellID == 32379 or spellName == "Shadow Word: Death") or (spellID == 586 or spellName == "Fade") then
        priestUsed = awful.time
        return
    end
end)


local dodgeCC ={

    -- Repentance
    [20066] = function()
        return player.incapDR >= 0.5
    end,
    [118] = function()
        return player.incapDR >= 0.5
    end,

    -- Fear
    [5782] = function()
        return player.disorientDR >= 0.5
    end,
    [65809] = function()
        return player.disorientDR >= 0.5
    end,
    [342914] = function()
        return player.disorientDR >= 0.5
    end,
    [251419] = function()
        return player.disorientDR >= 0.5
    end,
    [118699] = function()
        return player.disorientDR >= 0.5
    end,
    [30530] = function()
        return player.disorientDR >= 0.5
    end,
    [221424] = function()
        return player.disorientDR >= 0.5
    end,
    [41150] = function()
        return player.disorientDR >= 0.5
    end,

    -- Hex
    [51514] = function()
        return player.incapDR >= 0.5
    end,
    [211015] = function()
        return player.incapDR >= 0.5
    end,
    [211010] = function()
        return player.incapDR >= 0.5
    end,
    [211004] = function()
        return player.incapDR >= 0.5
    end,
    [210873] = function()
        return player.incapDR >= 0.5
    end,
    [269352] = function()
        return player.incapDR >= 0.5
    end,
    [277778] = function()
        return player.incapDR >= 0.5
    end,
    [277784] = function()
        return player.incapDR >= 0.5
    end,
    [309328] = function()
        return player.incapDR >= 0.5
    end,
    [161355] = function()
        return player.incapDR >= 0.5
    end,
    [161354] = function()
        return player.incapDR >= 0.5
    end,
    [161353] = function()
        return player.incapDR >= 0.5
    end,
    [126819] = function()
        return player.incapDR >= 0.5
    end,
    [61780] = function()
        return player.incapDR >= 0.5
    end,
    [161372] = function()
        return player.incapDR >= 0.5
    end,
    [61721] = function()
        return player.incapDR >= 0.5
    end,
    [61305] = function()
        return player.incapDR >= 0.5
    end,
    [28272] = function()
        return player.incapDR >= 0.5
    end,
    [28271] = function()
        return player.incapDR >= 0.5
    end,
    [277792] = function()
        return player.incapDR >= 0.5
    end,
    [277787] = function()
        return player.incapDR >= 0.5
    end,
    [391622] = function()
        return player.incapDR >= 0.5
    end,

    -- Sleep Walk
    [360806] = function()
        return player.disorientDR >= 0.5
    end,

    -- Cyclone
    [33786] = function()
        return player.incapDR >= 0.5
    end,
}

local bigDam = {
    [116858] = true, 
    [257044] = true,
    [199786] = true,
    [202771] = true,
    [19434] = true,
    [395160] = true,
    [375901] = true,
    [205021] = true,
    [382411] = true,
    [228260] = true,
    [390612] = true,
    [386997] = true,
    [459806] = true,
    [263165] = true,
    [48181] = true,
}

local prioPurge = {
    [110909] = { uptime = MinDelayTime(), min = 2 }, -- alter time (mage)
    [1022] = { uptime = MinDelayTime(), min = 2 }, -- blessing of protection (paladin)
    [10060] = { uptime = MinDelayTime(), min = 2 }, -- power infusion (priest)
    [378464] = { uptime = MinDelayTime(), min = 2 }, -- nullifying shroud (evoker)
    [213610] = { uptime = MinDelayTime(), min = 2 }, -- holy ward (priest)
    [210256] = { uptime = MinDelayTime(), min = 2 }, -- sanc (ret)
    [132158] = { uptime = MinDelayTime(), min = 2 }, -- ns (druid)
}


local stealthClass = {
    ["ROGUE"] = true,
    ["DRUID"] = true,
    ["MAGE"] = true,
    ["HUNTER"] = true
}

local stealthSpells = {
    [115191] = 115191,  -- subterfuge stealth
    [1784] = 1784,      -- non-subterfuge stealth
    [1856] = 11327,     -- vanish
    [5215] = 5215,      -- prowl
    [66] = 32612,       -- invis
    [58984] = 58984,    -- meld
    [199483] = 199483,  -- camo
}

local ssArray = {}
for k, v in pairs(stealthSpells) do
    ssArray[#ssArray+1] = v
end

local attack = NS(6603)

function attack:stop()
  return self.current and StopAttack()
end

local lastTimeCalled = 0

local function autoShot()
  if awful.MacrosQueued['reset'] then return end
  if attack:stop() then return end -- Check if attack:stop() is called
  if player.buff(199483) then return end -- camo
  if lastTimeCalled > awful.time - 3 then return end
  if C_Spell.IsAutoRepeatSpell("Auto Shot") then return end
  if C_Spell.IsAutoRepeatSpell(6603) then return end -- normal autoshot
  if C_Spell.IsAutoRepeatSpell(467718) then return end -- this is the new hero talent
  if C_Spell.IsAutoRepeatSpell(75) then return end -- this is the spellID of autohit
  if not target.exists then return end
  if not target.enemy then return end
  if target.immune or target.bcc then -- Check if target is immune or in bcc
    awful.call("StopAttack")
    lastTimeCalled = awful.time
  else
    awful.call("AttackTarget")
    lastTimeCalled = awful.time
  end
end

-- end random lists and functions --
-- start event callbacks --
local stealthTracker = {}
gifted.StealthTracker = stealthTracker
awful.StealthTracker = stealthTracker

awful.addUpdateCallback(function()
    local shadowSight = player.debuff(34709)
    awful.enemies.loop(function(enemy, index, uptime)
        if uptime > 2.5 and not shadowSight then return end
        if stealthClass[enemy.class2] and enemy.stealthed and enemy.buffFrom(ssArray) then
            awful.alert("|cFFa1eeffTracking " .. enemy.classString .. " |cFFffeea8(" .. GetSpellInfo(enemy.stealthed) .. ")", 118)
            local x, y, z = enemy.position()
            local dir = enemy.movingDirection
            local velocity = enemy.speed
            stealthTracker[enemy] = {
                time = GetTime(),
                pointer = enemy.pointer,
                obj = enemy,
                class = enemy.classString,
                pos = { x, y, z },
                dir = dir,
                velocity = velocity,
                maxVelocity = enemy.speed2,
                spellID = enemy.stealthed,
                immuneMagic = max(enemy.magicDamageImmunityRemains, enemy.magicEffectImmunityRemains),
                immunePhysical = max(enemy.physicalDamageImmunityRemains, enemy.physicalEffectImmunityRemains)
            }
        end
    end)
end)


local preDefensive = {
    [107570] = true,    -- storm bolt
    [132169] = true,    -- storm bolt
    [6789] = true,        -- mortal coil
    [89766] = true,        -- axe toss
    [119914] = true,       -- axe toss
    [370965] = true,    -- the hunt
    [323639] = true,    -- the hunt
}

awful.addEventCallback(function(info, event, source, dest)
    if not settings.automeld then return end
    local ets,subEvent,_,sourceGUID,sourceName,sourceFlags,sourceRaidFlags,destGUID,destName,destFlags,destRaidFlags,spellID,spellName = unpack(info)
    if subEvent == "SPELL_CAST_SUCCESS" then
        if source.isUnit(player) then
            if spellID == shadowmeld.id or spellID == feign.id then
                _antiCC = math.huge
            end
        end
        if dest.isUnit(player) and source.distanceTo(player) < 30 then
            return
        end
        if dest.isUnit(player) and source.distanceTo(player) >= 30 then
            if preDefensive[spellID] then
                _antiCC = (awful.time + quickdelay.now)  
            end
        end
    end
end)

-- only tracking direct meaningful damage, 
-- it's an indicator they're committed to attking the unit
local fireMageSpell = {
  [108853] = true,  -- fire blast
  [11366] = true,   -- pyroblast
  [257541] = true,  -- phoenix flames (maybe remove this)
}

local fireMageVictims = {}
local function recentlyAttackedByFireMage(unit)
  for i=#fireMageVictims,1,-1 do
    local victim = fireMageVictims[i]
    if awful.time - victim.time > 2 then
      tremove(fireMageVictims, i)
    end
  end

  for i=1,#fireMageVictims do
    local victim = fireMageVictims[i]
    if victim.object.isUnit(unit) then
      return true
    end
  end
end

local function insideEnemyMeteor(unit)
  -- 6211
  for _, trigger in ipairs(awful.areaTriggers) do
    if trigger.id == 6211 and trigger.distanceTo(unit) < 5.5 then
      return true
    end
  end
end

feign:CastCallback(function(spell)
  hunter.spearAlert = false
end)

function feign:CastWhenPossible(callback)
  -- never when carrying flag
  if player.hasFlag then return end

  local attempts = 0
  if self.cd <= 0.5 then
    C_Timer.NewTicker(0.05, function(self)
      if feign:Cast({stopMoving = true}) then
        self:Cancel()
        return callback and callback()
      elseif attempts >= 15 then
        self:Cancel()
      else
        attempts = attempts + 1
      end
    end)
  end
end

local recentDoubleTapAimed = 0
local recentDoubleTap = 0

-- on-damage events!
local trap = NS(187650, { effect = "magic", targeted = true, ignoreFacing = true })

onEvent(function(info, event, source, dest)
  local time = GetTime()
  if event ~= "SPELL_CAST_SUCCESS" then return end
  if not source.enemy then return end

  local spellID, spellName = select(12, unpack(info))
  local events = awful.events
  local happened = event.time

  --some checks tho 
  if not awful.enabled then return end
  if player.buff(186265) then return end
  if player.mounted then return end

  --Rogues .....
  if spellID == 36554
  and dest.isUnit(player)
  or source.buffFrom({121471,185422})
  and source.target.isUnit(player)
  and source.dist <= 10 then 
    feign:CastWhenPossible(function()
      awful.alert("Feign Death (" .. colored("Incoming Damage!", colors.rogue) .. ")", feign.id)
    end)
  end

  -- Meld the hunt
  if spellID == 370965
  and dest.isUnit(player)
  and source.speed > 45 
  and player.race == "Night Elf"
  and feign.cd > 0 then 
    if shadowmeld:Cast({stopMoving = true}) then
      return awful.alert("Shadow Meld (" .. colored("The Hunt", colors.dh) .. ")", shadowmeld.id)
    end
  end

  -- FD the hunt
  if spellID == 370965
  and dest.isUnit(player)
  and source.speed > 45 then 
    feign:CastWhenPossible(function()
      awful.alert("Feign Death (" .. colored("The Hunt", colors.dh) .. ")", feign.id)
    end)
  end

  -- don't mind me, just tracking fire mage victims
  if spellID and fireMageSpell[spellID] then
    tinsert(fireMageVictims, {
      time = time,
      object = dest
    })
  end

  -- double tapped aimed shot? feign it.
  if spellID == 19434 and time - recentDoubleTapAimed <= 0.15 and dest.isUnit(player) then 
    feign:CastWhenPossible(function()
      awful.alert("Feign Death (" .. colored("Double Tap Aimed Shot", colors.hunter) .. ")", feign.id)
    end)
  end

  -- deathbolt? feign it.
  if spellID == 264106 and dest.isUnit(player) then
    if feign.cd <= 0.25 then
      feign:CastWhenPossible(function()
        awful.alert("Feign Death (" .. colored("Deathbolt", colors.warlock) .. ")", feign.id)
      end)
    end
  end

  -- Drain life feign it.
  if spellID == 234153 and dest.isUnit(player) then
    if feign.cd <= 0.25 and counterShot.cd > 0 then
      feign:CastWhenPossible(function()
        awful.alert("Feign Death (" .. colored("Drain Life", colors.warlock) .. ")", feign.id)
      end)
    end
  end

  -- dark soul bolt
  if spellID == 116858 and source.buff(113858) and dest.isUnit(player) then
    if feign.cd <= 0.25 then
      feign:CastWhenPossible(function()
        awful.alert("Feign Death (" .. colored("Dark Soul Chaos Bolt", colors.warlock) .. ")", feign.id)
      end)
    end
  end

  -- ShadowMeld/flesh/scatter Stormbolt
  if spellID == 107570 
  and settings.scatterOthers 
  and dest.isUnit(player) 
  and source.disorientDR == 1
  and source.dist > awful.latency / (5 - bin(player.moving) * 1) then
    if awful.fighting(270, true) and settings.autoScatter then
      return
    end
    if settings.scatterOthers and scatterShot.cd <= 0.25 and settings.scatterOthers and not source.immunePhysicalEffects then
      if player.casting or player.channeling then
        awful.call("SpellStopCasting")
      end
      if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
        return awful.alert("Scatter Shot (" .. colored("Stormbolt", colors.warrior) .. ")", scatterShot.id)
      end
    elseif settings.scatterOthers and scatterShot.cd > 0.25 and player.race == "Night Elf" then
      if shadowmeld:Cast({stopMoving = true}) then
        return awful.alert("Shadow Meld (" .. colored("Stormbolt", colors.warrior) .. ")", shadowmeld.id)
      end
    end
  end

  -- ShadowMeld/flesh Coil
  if spellID == 6789 and dest.isUnit(player) 
  and source.dist > awful.latency / (5 - bin(player.moving) * 1) then
    if player.race == "Night Elf" then
      if shadowmeld:Cast({stopMoving = true}) then
        return awful.alert("Shadow Meld (" .. colored("Coil", colors.warlock) .. ")", shadowmeld.id)
      end
    end
  end

  -- Scatter things on events 
  if player.hasTalent(213691) then

    if source.debuff(360194) then return end

    --camo
    if player.buff(199483) then return end  
    if source.disorientDR ~= 1 then return end
    if source.buffFrom({198589, 212800}) then return end

    -- Scatter the hunt on player
    if spellID == 370965
    and dest.isUnit(player)
    and settings.scatterOthers
    and feign.cd > 0 then 
      if settings.scatterOthers and scatterShot.cd <= 0.25 and not source.immuneCC and trap.cd > 3 then
        if awful.fighting(270, true) and settings.autoScatter then
          return
        end
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("The Hunt", colors.dh) .. ")", feign.id)
        end
      end
    end

    --scatter the hunt 
    if spellID == 370965
    and source.enemy 
    and settings.scatterOthers
    and source.dist > awful.latency / (5 - bin(player.moving) * 1) then
      if settings.scatterOthers and scatterShot.cd <= 0.25 and not source.immuneCC and trap.cd > 3 then
        if awful.fighting(270, true) and settings.autoScatter then
          return
        end
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("The Hunt", colors.dh) .. ")", scatterShot.id)
        end
      end
    end

    -- Scatter Mark for death 
    if spellID == 137619 
    and dest.isUnit(player) 
    and source.enemy 
    and settings.scatterOthers
    and source.dist > awful.latency / (5 - bin(player.moving) * 1) then
      if settings.scatterOthers and scatterShot.cd <= 0.25 and not source.immuneCC and trap.cd > 3 then
        if awful.fighting(270, true) and settings.autoScatter then
          return
        end
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Mark for Death", colors.rogue) .. ")", scatterShot.id)
        end
      end
    end

    -- Metamorphosis on player
    if source.buff(162264) 
    and source.target.isUnit(player) 
    and settings.scatterOthers
    and not player.target.isUnit(source) then
      if settings.scatterOthers and scatterShot.cd - awful.gcdRemains == 0 
      and not source.immuneCC and trap.cd > 3 then
        if awful.fighting(270, true) and settings.autoScatter then
          return
        end
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Metamorphosis", colors.dh) .. ")", scatterShot.id)
        end
      end
    end            

    -- Flagellation Rush on player
    if spellID == 323654 
    and settings.scatterOthers
    and dest.isUnit(player) then
      if settings.scatterOthers and scatterShot.cd <= 0.25 and not source.immuneCC and trap.cd > 3 then
        if awful.fighting(270, true) and settings.autoScatter then
          return
        end
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Flagellation", colors.rogue) .. ")", scatterShot.id)
        end
      end
    end 

    -- Vendetta/deathmark on player
    if (spellID == 360194 or spellID == 79140) and settings.scatterOthers then
      if settings.scatterOthers and scatterShot.cd <= 0.25 and not source.immuneCC and trap.cd > 3 then
        if awful.fighting(270, true) and settings.autoScatter then
          return
        end
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Deathmark", colors.rogue) .. ")", scatterShot.id)
        end
      end
    end         

    -- Shadow Blades on player
    if source.buff(121471) then
      if settings.scatterOthers and scatterShot.cd <= 0.25 and not source.immuneCC and trap.cd > 3 then
        if awful.fighting(270, true) and settings.autoScatter then
          return
        end
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Shadow Blades", colors.rogue) .. ")", scatterShot.id)
        end
      end
    end   
    -- Adrenaline Rush on player
    if source.buff(13750)
    and settings.scatterOthers
    and source.dist > awful.latency / (5 - bin(player.moving) * 1) 
    and player.hp < 90 
    and healer.cc then
      if settings.scatterOthers and scatterShot.cd <= 0.25 and not source.immuneCC and trap.cd > 3 then
        if awful.fighting(270, true) and settings.autoScatter then
          return
        end
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Adrenaline Rush", colors.rogue) .. ")", scatterShot.id)
        end
      end
    end    
    

    -----------Scatter Gap Closers-----------------

    -- Warrior Charge Scatter it.
    if spellID == 100 
    and settings.scatterOthers
    and not player.target.isUnit(source) then
      if awful.fighting(270, true) and settings.autoScatter then
        return
      end
      if settings.scatterOthers and scatterShot.cd - awful.gcdRemains == 0 
      and not source.immuneCC and trap.cd > 3 then
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Charge", colors.warrior) .. ")", scatterShot.id)
        end
      end
    end
    --warrior leap Scatter it
    if spellID == 6544 
    and source.enemy 
    and settings.scatterOthers
    and not player.target.isUnit(source)
    and not source.isHealer
    and source.dist > awful.latency / (5 - bin(player.moving) * 1) then
      if awful.fighting(270, true) and settings.autoScatter then
        return
      end
      if settings.scatterOthers and scatterShot.cd - awful.gcdRemains == 0 
      and not source.immuneCC and trap.cd > 3 then
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Heroic Leap", colors.warrior) .. ")", scatterShot.id)
        end
      end
    end
    -- DH Fel rush Scatter it.
    if spellID == 195072 
    and settings.scatterOthers
    and not player.target.isUnit(source) then
      if awful.fighting(270, true) and settings.autoScatter then
        return
      end
      if settings.scatterOthers and scatterShot.cd - awful.gcdRemains == 0 
      and not source.immuneCC and trap.cd > 3 then
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Fel Rush", colors.dh) .. ")", scatterShot.id)
        end
      end
    end
    --rogue Shadowstep Scatter it
    if spellID == 36554 
    and source.enemy 
    and settings.scatterOthers
    and not player.target.isUnit(source)
    and source.dist > awful.latency / (5 - bin(player.moving) * 1) then
      if awful.fighting(270, true) and settings.autoScatter then
        return
      end
      if settings.scatterOthers and scatterShot.cd - awful.gcdRemains == 0 
      and not source.immuneCC and trap.cd > 3 then
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Shadow Step", colors.rogue) .. ")", scatterShot.id)
        end
      end
    end
    --feral charge Scatter it
    if spellID == 49376 
    and source.enemy 
    and settings.scatterOthers
    and not player.target.isUnit(source)
    and not source.isHealer
    and source.dist > awful.latency / (5 - bin(player.moving) * 1) then
      if awful.fighting(270, true) and settings.autoScatter then
        return
      end
      if settings.scatterOthers and scatterShot.cd - awful.gcdRemains == 0 
      and not source.immuneCC and trap.cd > 3 then
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Wild Charge", colors.druid) .. ")", scatterShot.id)
        end
      end
    end
    --monk roll Scatter it
    if spellID == 49376 
    and source.enemy 
    and settings.scatterOthers
    and not player.target.isUnit(source)
    and not source.isHealer
    and source.dist > awful.latency / (5 - bin(player.moving) * 1) then
      if awful.fighting(270, true) and settings.autoScatter then
        return
      end
      if settings.scatterOthers and scatterShot.cd - awful.gcdRemains == 0 
      and not source.immuneCC and trap.cd > 3 then
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Roll", colors.monk) .. ")", scatterShot.id)
        end
      end
    end

    ----------------------End of scatter Gap Closers-----


    -- double tapped aimed shot? Scatter it.
    if spellID == 19434 
    and time - recentDoubleTapAimed <= 0.15 
    and settings.scatterOthers then
      if settings.scatterOthers and scatterShot.cd <= 0.25 and not source.immuneCC and trap.cd > 3 then
        if awful.fighting(270, true) and settings.autoScatter then
          return
        end
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Double Tap Aimed Shot", colors.hunter) .. ")", scatterShot.id)
        end
      end 
    end

    -- double tapped rapidfire? feign/Meld it.
    if spellID == 257044 and source.buff(260402) and dest.isUnit(player) then 
      if feign.cd <= 0.25 then
        feign:CastWhenPossible(function()
          awful.alert("Feign Death (" .. colored("Double Tap Rapid Fire", colors.hunter) .. ")", feign.id)
        end)
      elseif feign.cd > 0.5 and player.race == "Night Elf" then
        if shadowmeld:Cast({stopMoving = true}) then
          return awful.alert("Shadow Meld (" .. colored("Double Tap Rapid Fire", colors.hunter) .. ")", shadowmeld.id)
        end
      end
    end

    -- Glacial Spike feign/Meld it.
    if spellID == 199786 and dest.isUnit(player) then 
      if feign.cd <= 0.25 then
        feign:CastWhenPossible(function()
          awful.alert("Feign Death (" .. colored("Glacial Spike", colors.mage) .. ")", feign.id)
        end)
      elseif feign.cd > 0.5 and player.race == "Night Elf" then
        if shadowmeld:Cast({stopMoving = true}) then
          return awful.alert("Shadow Meld (" .. colored("Glacial Spike", colors.mage) .. ")", shadowmeld.id)
        end
      end
    end

    -- Arcane Surge feign/Meld it.
    if spellID == 365350 or spellID == 365362 and dest.isUnit(player) then 
      if feign.cd <= 0.25 then
        feign:CastWhenPossible(function()
          awful.alert("Feign Death (" .. colored("Arcane Surge", colors.mage) .. ")", feign.id)
        end)
      elseif feign.cd > 0.5 and player.race == "Night Elf" then
        if shadowmeld:Cast({stopMoving = true}) then
          return awful.alert("Shadow Meld (" .. colored("Arcane Surge", colors.mage) .. ")", shadowmeld.id)
        end
      end
    end

    -- chaos bolt? Scatter it.
    if spellID == 116858 and dest.isUnit(player) and settings.scatterOthers then
      if awful.fighting(270, true) and settings.autoScatter then
        return
      end
      if settings.scatterOthers and scatterShot.cd <= 0.5 and feign.cd > 0 and trap.cd > 3 then
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if settings.scatterOthers and scatterShot:Cast(source, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Chaos Bolt", colors.warlock) .. ")", scatterShot.id)
        end
      end
    end 

  end

  -- big surge
  if spellID == 78674 and dest.isUnit(player) then
    if source.channelID == 323764 then
      if feign.cd <= 0.2 then
        feign:CastWhenPossible(function()
          awful.alert("Feign Death (" .. colored("Big Starsurge", colors.druid) .. ")", feign.id)
        end)
      end
    elseif source.buffFrom({194223, 102560}) then
      if feign.cd <= 0.2 then
        feign:CastWhenPossible(function()
          awful.alert("Feign Death (" .. colored("Big Starsurge", colors.druid) .. ")", feign.id)
        end)
      end
    end
  end

  -- chaos bolt? feign it.
  if spellID == 116858 and dest.isUnit(player) then
    if feign.cd <= 0.5 then
      feign:CastWhenPossible(function()
        awful.alert("Feign Death (" .. colored("Chaos Bolt", colors.warlock) .. ")", feign.id)
      end)
    end 
  end

end)

shadowmeld:Callback("instants",function(spell)
    if player.stealth then return end
    if player.race ~= "Night Elf" then return end
    if shadowmeld.cd > 0 then return end
    if awful.time > _antiCC then
        awful.controlMovement(0.3)
        SpellStopCasting()
        SpellStopCasting()
        C_Timer.After(0.06, function()  if spell:Cast({ stopMoving = true }) then awful.alert("Shadowmeld | Incoming Instant CC", spell.id) return end end)
    end
end)

feign:Callback("instants", function(spell)
    if player.stealth then return end
    if feign.cd > 0 then return end
    if shadowmeld.cd < 0.5 + awful.buffer then return end
    if awful.time > _antiCC then
        awful.controlMovement(0.3)
        SpellStopCasting()
        SpellStopCasting()
        if spell:Cast({ stopMoving = true }) then
            awful.alert({
                message = awful.colors.green .. " - Feign Death | Incoming Instant CC",
                texture = 5384,
                imgScale = 1,
                highlight = true,
                outline = "OUTLINE",
            })
            return
        end
    end
end)
-- end event callbacks --

-- start totem stomp stuff --


local stompID = {
  5925, -- Grounding
  53006, -- Spirit link
  101398, -- Psyfiend
  107100, -- observer
  105451, -- Counterstrike
  179867, -- Static Field
  119052, -- War Banner
  179193, -- fel obelisk
  5913, -- tremor totem
  51485, -- earthgrab totem
  61245, -- capacitor totem  --192058
  105427, -- skyfury totem
  59764, -- healing tide totem
}

local stompDelay = awful.delay(0.5, 0.65)

function HardCodeStomp()
    if not settings.autostomp or not player.combat then 
        return 
    end

    awful.units.loop(function(unit, uptime)
        if unit.distance > 30 or not unit.los or unit.uptime < stompDelay.now or unit.friend or not unit.enemy or not unit.exists and not unit.los then 
            return 
        end

        for _, id in ipairs(stompID) do
            if unit.id == id and player.focus >= 30 and pet.distanceTo(unit) <= 15 and pet.losOf(unit) and player.losOf(unit) then
                if killCommand:Castable(unit) and killCommand:Cast(unit) then
                    awful.alert("KC(Totem Stomp) on " .. unit.classString, killCommand.id)
                    return
                end
            end
        end

        for _, id in ipairs(stompID) do
            if unit.id == id and player.focus >= 35 and killCommand.charges < 1 and unit.losOf(player) and cobraShot:Castable(unit) and cobraShot:Cast(unit) and player.losOf(unit) then
                awful.alert("Cobra Shot(Totem Stomp) on " .. unit.classString, cobraShot.id)
                  return
            end
        end
    end)
end
      
   
-- end totem stomp stuff --

-- start bloodfury --

BloodFury:Callback("pvp", function(spell)
  if not player.combat then return end
  if not (player.buff(19574) or player.buff(359844)) then return end
  if not spell:Castable() then return end

  spell:Cast()
end)

-- commandPetLust:Callback("pvp", function(spell)
--   if not player.combat then return end
--   if not (player.buff(19574) or player.buff(359844)) then return end
--   if not spell.known then return end
--   if not spell:Castable() then return end
--   if not pet.exists then return end
--   if pet.dead then return end

--   spell:Cast()
-- end)


-- end bloodfury --

-- start feign/shadowmeld stuff --

feign:Callback("pvp-bigdam", function(spell)
    

    awful.enemies.loop(function(enemy)
        if not enemy.exists then return end
        local castName = enemy.casting
        if not castName then return end
        if not enemy.castTarget.isUnit(player) then return end
        if not bigDam[castName] then return end
        if enemy.castRemains <= awful.buffer then
            awful.controlMovement(0.3)
            SpellStopCasting()
            SpellStopCasting()
            if spell:Cast({ stopMoving = true }) then
                awful.alert({
                    message = awful.colors.purple .. " - Feign Death | Big Damage",
                    texture = 5384,
                    imgScale = 1,
                    highlight = true,
                    outline = "OUTLINE",
                })
                return
            end
        end
    end)
end)

feign:Callback("cds", function(spell)

  if spell.cd - awful.gcdRemains > 0 then return end
  -- never when carrying flag
  if player.hasFlag then return end

  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if not enemy.los then return end
    if not enemy.target.isUnit(player) then return end
    if enemy.ccr and enemy.ccr > 1 then return end
    if not enemy.isPlayer then return end  

    local has = enemy.buffFrom(FDBigDam)

    if not has then return end
    local str = ""
    for i, id in ipairs(has) do
      if i == #has then
        str = str .. C_Spell.GetSpellInfo(id).name
      else
        str = str .. C_Spell.GetSpellInfo(id).name .. ","
      end
    end

    if has then
      return spell:Cast({stopMoving = true}) and awful.alert("Feign Death (" .. colors.red .. (str) .. "|r)", spell.id)
    end
    
  end)
end)


-- on-damage feigns
feign:Callback("damage", function(spell)
  -- never when carrying flag
  if player.hasFlag then return end
  if spell.cd - awful.gcdRemains > 0 then return end
  if not player.hasTalent(202746) then return end --survival tactics

  local time = awful.time

  -- pause for deadly casts
  awful.enemies.loop(function(enemy)
    local class = enemy.class2

    --Disc Ultimate Penitance
    if awful.fighting(256)
    and enemy.channelID == 421434
    and enemy.castTarget.isUnit(player) then
      if spell:Cast({stopMoving = true}) then
        awful.alert("Feign Death (" .. colored("Ultimate Penitance", colors.priest) .. ")", spell.id)
      end
    end

    if class == "HUNTER" then
      local hasDoubleTap = enemy.buff(260402)
      
      -- aimed shot
      if enemy.castID == 19434 
      and enemy.buff(260402) 
      and enemy.castTarget.isUnit(player) 
      and enemy.los and enemy.castRemains <= (awful.gcd + awful.buffer) * 2 then
        recentDoubleTapAimed = time
        hunter.temporaryAlert = { msg = "Ready to Feign " .. colored("Double Tap Aimed Shot", colors.hunter), texture = spell.id }
      end

      -- rapid fire
      if enemy.channelID == 257044 
      and enemy.buff(260402) 
      and enemy.castTarget.isUnit(player) 
      and enemy.channelRemains >= 0.3 then
        if spell:Cast({stopMoving = true}) then
          awful.alert("Feign Death (" .. colored("Double Tap Rapid Fire", colors.hunter) .. ")", spell.id)
        end
      end

      --Sniper Shot
      if enemy.castID == 203155 
      and enemy.castTarget.isUnit(player) 
      and enemy.los and enemy.castRemains <= (awful.gcd + awful.buffer) * 2 then
        if spell:Cast({stopMoving = true}) then
          awful.alert("Feign Death (" .. colored("Sniper Shot", colors.hunter) .. ")", spell.id)
        end
      end
    end

    -- Calculate the threshold for using Feign Death
    local threshold = 25

    -- Adjust threshold based on player's health percentage
    threshold = threshold - (player.hp * 0.5)

    -- Adjust threshold based on enemy's dangerous cooldowns
    threshold = threshold + (bin(enemy.cds) * 20)

    -- Adjust threshold based on healer's condition
    threshold = threshold + bin(not healer.exists or not healer.los or healer.cc) * 25

    if player.hp > threshold then return end

    if player.class == "EVOKER" 
    and enemy.role == "ranged"
    and enemy.castTarget.isUnit(player) then
      -- Handle Evoker Eruption
      if enemy.castID == 395160
      and enemy.los
      and enemy.castRemains <= (awful.gcd + awful.buffer) * 2 then

        if spell:Cast({stopMoving = true}) then
          awful.alert("Feign Death (" .. colored("Eruption", colors.evoker) .. ")", spell.id)
        end

      elseif enemy.channelID == 356995 and enemy.castRemains <= (awful.gcd + awful.buffer) * 2 then

        if spell:Cast({stopMoving = true}) then
          awful.alert("Feign Death (" .. colored("Disintegrate", colors.evoker) .. ")", spell.id)
        end

      end
    end

    --Evoker shit
    if class == "EVOKER" 
    and enemy.role == "ranged" then

      local threshold = 25
      threshold = threshold - bin(player.immuneMagicDamage) * 10
      threshold = threshold - bin(player.hp) * 10
      threshold = threshold + bin(not healer.exists or not healer.los or healer.cc) * 25

      if player.hp > threshold then return end
        
      --Evoker eruption
      if enemy.castID == 395160 
      and enemy.castTarget.isUnit(player) 
      and enemy.los and enemy.castRemains <= (awful.gcd + awful.buffer) * 2 then
        if spell:Cast({stopMoving = true}) then
          awful.alert("Feign Death (" .. colored("Eruption", colors.evoker) .. ")", spell.id)
        end
      end

      --Disintegrate
      if enemy.channelID == 356995 
      and enemy.castTarget.isUnit(player) 
      and enemy.castRemains <= (awful.gcd + awful.buffer) * 2 then
        if spell:Cast({stopMoving = true}) then
          awful.alert("Feign Death (" .. colored("Disintegrate", colors.evoker) .. ")", spell.id)
        end
      end
    end

  end)

end)

shadowmeld:Callback("pvp-bigdam",function(spell)
    if player.stealth then return end
    if player.race ~= "Night Elf" then return end
    if shadowmeld.cd > player.gcdRemains then return end
    if not player.hasTalent(408557) then return end
    if feign.cd == 0 then return end 

    awful.enemies.loop(function(enemy)
        if not enemy.exists then return end
        local castName = enemy.casting
        if not castName then return end
        if not enemy.castTarget.isUnit(player) then return end
        if not bigDam[castName] then return end
        if counterShot.cd <= enemy.castRemains - awful.buffer then return end
        if enemy.castRemains <= awful.buffer then
            awful.controlMovement(0.3)
            SpellStopCasting()
            SpellStopCasting()
            if spell:Cast({ stopMoving = true }) then
                awful.alert({
                    message = awful.colors.purple .. " - Shadowmeld | Big Damage",
                    texture = 58984,
                    imgScale = 1,
                    highlight = true,
                    outline = "OUTLINE",
                })
                return
            end
        end
    end)
end)

feign:Callback("dodgeCC", function(spell)

  awful.enemies.loop(function(enemy)
  
    if not enemy.exists then return end
        if enemy.dist > 45 then return end
        local cast = enemy.castID
        if not cast then return end
        if not enemy.castTarget.isUnit(player) then return end
        if not dodgeCC[cast] then return end
        if counterShot.cd <= enemy.castRemains - awful.buffer then return end
        if enemy.castRemains <= delay.now + awful.buffer then
          awful.controlMovement(0.4)
            SpellStopCasting()
            SpellStopCasting()
            awful.call("SpellCancelQueuedSpell")
            awful.SpellQueued = nil
            if spell:Cast({ stopMoving = true }) then
                awful.alert({
                    message = awful.colors.white .. " - Feign Death used to dodge CC!",
                    texture = spell.id,
                    highlight = true,
                    outline = "OUTLINE"
                })   
            end
            return
        end
    end)
end)

shadowmeld:Callback("dodgeCC", function(spell)
  if player.stealth then return end
  if player.race ~= "Night Elf" then return end
  if shadowmeld.cd > player.gcdRemains then return end
  if feign.cd == 0 then return end 

  awful.enemies.loop(function(enemy)

    if not enemy.exists then return end
        if enemy.dist > 45 then return end
        local cast = enemy.castID
        if not cast then return end
        if not enemy.castTarget.isUnit(player) then return end
        if not dodgeCC[cast] then return end
        if counterShot.cd <= enemy.castRemains - awful.buffer then return end
        if enemy.castRemains <= delay.now + awful.buffer then
          awful.controlMovement(0.4)
            SpellStopCasting()
            SpellStopCasting()
            awful.call("SpellCancelQueuedSpell")
            awful.SpellQueued = nil
            if spell:Cast({ stopMoving = true }) then
                awful.alert({
                    message = awful.colors.white .. " - Shadowmeld used to dodge CC!",
                    texture = spell.id,
                    highlight = true,
                    outline = "OUTLINE"
                })   
            end
            return
        end
    end)
end)

feign:Callback("hp", function(spell) -- may need fix
  if not player.hasTalent(202746) then return end
  if player.buff(199483) then return end
  if player.hp <= 65 then
    awful.controlMovement(0.3)
        SpellStopCasting()
        SpellStopCasting()
        awful.call("SpellCancelQueuedSpell")
        awful.SpellQueued = nil
    if spell:Cast({ stopMoving = true }) then
    end
  end
end)


-- end feign/shadowmeld stuff --

-- start move pet to unit stuff --

hunter.movePetToUnit = function(unit)

  --if Unlocker.type == "daemonic" then return end
  if SpellIsTargeting() then return end
  -- player must be within 60y to move pet to position?
  if player.distanceToLiteral(unit) > 60 then
    -- alert("Unable to move pet, too far")
    return false
  end

  local x,y,z = unit.position()

  PetMoveTo()
  Click(x,y,z)

  return unit.classString and awful.alert("Moving pet to " .. unit.classString) or awful.alert("Moving Pet")
end

hunter.movePetToPosition = function(x,y,z)

  --if Unlocker.type == "daemonic" then return end
  if SpellIsTargeting() then return end
  -- player must be within 60y to move pet to position?
  if player.distanceToLiteral(x,y,z) > 60 then
    -- alert("Unable to move pet, too far")
    return false
  end

  PetMoveTo()
  Click(x,y,z)

  return true
  
end

-- end move pet to unit stuff --

local stealthTracker = {}
gifted.StealthTracker = stealthTracker
awful.StealthTracker = stealthTracker


-- flare stuff --
flare:Callback("restealth", function(spell)
    awful.enemies.loop(function(enemy)
    local time = awful.time
    for key, tracker in pairs(gifted.StealthTracker) do
      local x, y, z = unpack(tracker.pos)
      if x and y and z then
        local elapsed = (tracker.init and time - tracker.init or buffer) + buffer
        local dist = elapsed * tracker.velocity
        local fx, fy, fz = x + dist * cos(tracker.dir), y + dist * sin(tracker.dir), z
        local extraElapsed = (player.distanceToLiteral(fx, fy, fz) / 24)
        local extraDist = extraElapsed * tracker.velocity
        fx, fy, fz = x + extraDist * cos(tracker.dir), y + extraDist * sin(tracker.dir), z
        if player.losCoordsLiteral(fx, fy, fz) and spell:AoECast(fx, fy, fz) then
          gifted.flareDraw = { pos = {fx, fy, fz}, tracker = tracker, time = time }
            return awful.alert("Flare " .. tracker.class .. "(" .. GetSpellInfo(tracker.spellID) .. ")", spell.id)
            end
        end
      end
    end)
end)

  flare:Callback("stealth", function(spell)
    return awful.enemies.loop(function(enemy, uptime)
      -- if uptime < 2 then
        if enemy.stealth then
          local x,y,z = enemy.predictPosition(0.35)
          return spell:AoECast(x,y,z) and awful.alert("Flare " .. (enemy.class or "") .. "(Stealth)", spell.id)
        end
      -- end
    end)
  end)

  flare:Callback("binding", function(spell)
    if not player.recentlyUsed(109248, 2) then return end
    awful.enemies.loop(function(enemy)
      if not enemy.stealth then return end
      if not enemy.exists then return end
      if not enemy.class2 == "DRUID" and enemy.spec == "Feral" or enemy.class2 == "ROGUE" then return end
      if player.used(109248, awful.time + 1) then
        local x,y,z = enemy.predictPosition(0.35)
        return spell:AoECast(x,y,z) and awful.alert("Flare (" .. colored("Flare Feral Opener", colors.cyan) .. ")", spell.id)
      end
    end)
  end)
  
  flare:Callback("friendly", function(spell)
    if awful.prep then return end
    if not awful.arena then return end
    if not healer.debuff(2094) then return end
  
    if awful.arena 
    and healer.exists
    and healer.los
    and player.distanceTo(healer) < 36 
    and healer.debuff(2094) then
  
      local x,y,z = healer.position()
  
      if spell:AoECast(x,y,z) then 
          awful.alert("Flare " .. (healer.name or "") .. "|cFFf74a4a[Prevent Sap]", spell.id)
        end  
    end
end)
      
  -- end flare stuff --

  -- conc stuff --
  local trapTarget = hunter.trapTarget
  bm.trapTarget = trapTarget

  hookCallbacks(function(spell)
    trapTarget = hunter.trapTarget
  end)

  local trappedTarget = {}
  local function findTrappedTarget()
    trappedTarget = {}
    for _, enemy in ipairs(awful.enemies) do
      if enemy.debuff(3355, "player") then
        trappedTarget = enemy
        break
      end
    end
  end

  local function dontConc(unit, overlap)
    awful.enemies.loop(function(unit)
    overlap = overlap or 0
    return player.buff(199483)
    or not unit.enemy
    or unit.immuneSlow
    or unit.slow and unit.slowRemains >= 2
    -- unit already in cc
    or unit.ccr > overlap
    -- -- standing still in tar trap
    or unit.debuff(135299) and not unit.moving
    or unit.debuff(117405) and unit.moving
    or unit.debuff(117526) or unit.debuff(24394)
    or unit.debuff(393456) or unit.debuff(213691)
    end)
  end

  conc:Callback("yolo trap", function(spell, unit)
    if not trapTarget.exists then return end
    if not trapTarget.enemy then return end
    if dontConc(unit) then return end
    if player.debuff(gifted.SEARING_SHOT_DEBUFF_ID) then return end
    if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end
    return spell:Cast(unit) and awful.alert("Conc " .. unit.classString .. " For Trap", spell.id)
  end)

  conc:Callback("trap target", function(spell)
    if not trapTarget.exists then return end
    if not trapTarget.enemy then return end
    if dontConc(trapTarget) then return end
    if player.debuff(gifted.SEARING_SHOT_DEBUFF_ID) then return end
    if trap.cd > 4 then return end
    if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end
    if player.movingToward(trapTarget, { angle = 55, flags = {1, 5, 9, 4, 8, 2057, 2053, 2049, 2056, 2052}, duration = 0 + bin(hunter.trap.cd > 8) * (hunter.trap.cd / 23) }) then
      return spell:Cast(trapTarget) and awful.alert("Conc " .. trapTarget.classString .. " For Trap", spell.id)
    end
  end)
  
  conc:Callback("bad position", function(spell, unit)
    if not trapTarget.exists then return end
    if not trapTarget.enemy then return end
    if dontConc(unit, buffer) then return end
    if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end
    if player.debuff(gifted.SEARING_SHOT_DEBUFF_ID) then return end
    local bpUnit = unit.isUnit(target) and enemyHealer or unit.isUnit(enemyHealer) and target or {}
    local badPosition = bpUnit.exists and (not unit.losOf(bpUnit) or unit.distanceTo(bpUnit) > 40)
  
    if not badPosition or unit.isUnit(bpUnit) then return end
  
    return spell:Cast(unit) and awful.alert("Conc " .. unit.classString .. " LoS", spell.id)
  end)

  conc:Callback("slowbigdam", function(spell, unit)
    if target.exists and target.hp <= 20 then return end
    if spell.cd - awful.gcdRemains > 0 then return end
    if player.buff(199483) then return end
    
    if not enemyHealer.exists or enemyHealer.ccRemains > 3 or enemyHealer.slowed or trap.cd > 3 then
      awful.enemies.loop(function(enemy)
  
        if enemy.distance > 30 then return end
        if not enemy.los then return end
        if not enemy.isPlayer then return end
        if enemy.role ~= "melee" then return end
        if enemy.class2 == "DRUID" then return end
  
        if enemy.immuneSlow 
        or enemy.buff(227847) 
        or enemy.slowed
        or enemy.rooted
        or enemy.immunePhysicalDamage 
        or enemy.IsInCC then
         return 
        end
  
        if enemy.buffsFrom(BigDamageBuffs) > 0
        and player.combat 
        and enemy.debuffRemains(5116) < 1 then
          if spell:Cast(enemy, {face = true}) then
            awful.alert("|cFFf7f25cSlow " .. (enemy.classString or "") .. "", spell.id)
          end
        end   
      end) 
    end
  
  end)
  
  conc:Callback("tunnel", function(spell, unit)
    if target.exists and target.hp <= 20 then return end
    if spell.cd - awful.gcdRemains > 0 then return end
    if player.buff(199483) then return end
  
    if not enemyHealer.exists or enemyHealer.ccRemains > 3 or enemyHealer.slowed or trap.cd > 3 then
      awful.enemies.loop(function(enemy)
  
        if enemy.distance > 30 then return end
        if not enemy.los then return end
        if not enemy.isPlayer then return end
        if enemy.role ~= "melee" then return end
        if enemy.class2 == "DRUID" then return end
  
        if enemy.immuneSlow 
        or enemy.buff(227847) 
        or enemy.slowed
        or enemy.rooted
        or enemy.immunePhysicalDamage 
        or enemy.IsInCC then
          return 
        end
  
        if enemy.target.isUnit(player)
        and enemy.cds or player.hp < 85
        and player.combat 
        and enemy.debuffRemains(5116) < 1
        and not player.target.isUnit(enemy) then
          if spell:Cast(enemy, {face = true}) then
            awful.alert("|cFFf7f25cSlow " .. (enemy.classString or "") .. "", spell.id)
          end
        end   
      end) 
    end
  
  end)
  
  conc:Callback("slow target", function(spell)
    if target.hp <= 30 then return end
    if not target.enemy then return end
    if not target.los then return end
    if target.immunePhysicalEffects then return end
    if target.immuneSlow then return end
    if target.cc then return end
    if player.buff(199483) then return end
    if target.slowRemains >= 1 then return end 
    if not target.moving then return end
    if dontConc(target) then return end
  
    if enemyHealer.exists 
    and enemyHealer.ccRemains > 3 
    or enemyHealer.slowed 
    or trap.cd > 3
    or enemyHealer.exists 
    and enemyHealer.idrRemains >= 4 then 
      return spell:Cast(target) and awful.alert("|cFFf7f25cSlow " .. (target.classString or ""), spell.id)
      
    elseif target.slowRemains < 1 
    and not enemyHealer.exists then
      return spell:Cast(target) and awful.alert("|cFFf7f25cSlow " .. (target.classString or ""), spell.id)
    end
  
  end)

  -- end conc stuff --

  -- disengage stuff --

local disengage = NS(781)

  local alert = awful.alert
local shortalert = function(msg, txid)
  return alert({msg = msg, texture = txid, duration = 0.1, fadeOut = 0.1})
end 

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

local lastJump = 0
hooksecurefunc("JumpOrAscendStart", function()
  if not IsFalling() then
    lastJump = GetTime()
  end
end)

local function jumpApex(min, max)
  if player.rooted then return true end
  if not IsFalling() then
    JumpOrAscendStart()
    AscendStop()
  elseif GetTime() - lastJump >= math.max(0, (awful.min or 0.35 - awful.buffer)) then
    return true
  end
end

  function disengage:Maneuver(angle, message, min, max)
    if self:Castable() and self.cd == 0 then
      local alreadyQueued 
      awful.pauseFacing = true
      awful.controlFacing(0.65)  
      if not SpellIsTargeting() and not IsMouseButtonDown("LeftButton") and not IsMouseButtonDown("RightButton") then
        CameraOrSelectOrMoveStart()
      end
      if min == -1 or jumpApex(min, max) then
        if not self.performingManeuver then
           --print(angle, inverse(player.movingDir))
          self.performingManeuver = true
          local rotation = tonumber(player.rotation)
  
          local postFaceCast = 0
          local postCastTurn = 0
  
          local totalDuration = postFaceCast + postCastTurn
  
          awful.controlFacing(totalDuration + 0.65) 
          if not SpellIsTargeting() and not IsMouseButtonDown("LeftButton") and not IsMouseButtonDown("RightButton") then
            CameraOrSelectOrMoveStart()
            C_Timer.After(totalDuration + 0.35, function() 
              if not IsMouseButtonDown("LeftButton") then
                CameraOrSelectOrMoveStop()
              end
            end)
          end
  
          if message then
            awful.alert(message, self.id)
          end
  
          local setFacing = awful.FaceDirection
  
          setFacing(angle)
  
          C_Timer.After(postFaceCast, function()
            awful.pauseFacing = true
            if not alreadyQueued and self:Cast() then
              alreadyQueued = true
              C_Timer.After(awful.buffer, function()
                setFacing(rotation)
              end)
              C_Timer.After(0.75, function() 
                self.performingManeuver = nil
                if not IsMouseButtonDown("LeftButton") then
                  CameraOrSelectOrMoveStop()
                end
              end)
            else
              C_Timer.After(0.75, function() 
                self.performingManeuver = nil
                if not IsMouseButtonDown("LeftButton") then
                  CameraOrSelectOrMoveStop()
                end
              end)
            end
          end)
        end
      end
    end
  end
  
  function disengage:forward(min, max, manual)
    if manual and self.cd > 0.5 and self.cd < 15 then return awful.alert({msg = "Waiting for cooldown", duration = 0.3, texture = self.id}) end
    local angle = inverse(player.rotation)
    return disengage:Maneuver(angle, "Disengage |cFF8be9f7Forward", min, max)
  end
  
  function disengage:movingDirection(backward, min, max, manual)
    if manual and self.cd > 0.5 and self.cd < 15 then return awful.alert({msg = "Waiting for cooldown", duration = 0.3, texture = self.id}) end
    local angle = player.moving and inverse(player.movingDir) or backward and player.rotation or inverse(player.rotation)
    return disengage:Maneuver(angle, "Disengage |cFF8be9f7Flow", min, max)
  end
  
  function disengage:toUnit(unit, min, max, manual)
    if manual and self.cd > 0.5 and self.cd < 15 then return awful.alert({msg = "Waiting for cooldown", duration = 0.3, texture = self.id}) end
    if not unit.visible then return not awful.alert("Invalid disengage unit...", self.id) end
    local x,y,z = unit.position()
    if not x or not y or not z then return end
    local px,py,pz = player.position()
    local angle = angles(x,y,z,px,py,pz)
    return disengage:Maneuver(angle, "Disengage to " .. unit.classString, min, max)
  end
  
  function disengage:handler()
    if not settings.disengageTech then return end
    local queued = awful.MacrosQueued
    if queued["disengage forward"] then 
      disengage:forward(nil, nil, true)
    elseif queued["disengage flow"] then
      disengage:movingDirection(nil, nil, nil, true)
    elseif queued["disengage flow2"] then
      disengage:movingDirection(true, nil, nil, true)
    elseif queued["disengage trap"] then
      disengage:toUnit(hunter.trapTarget, nil, nil, true)
    elseif queued["disengage target"] then
      disengage:toUnit(target, nil, nil, true)
    elseif queued["disengage focus"] then
      disengage:toUnit(focus, nil, nil, true)
    elseif queued["disengage healer"] then
      disengage:toUnit(healer, nil, nil, true)
    elseif queued["disengage enemyhealer"] or queued["disengage enemyHealer"] then
      disengage:toUnit(enemyHealer, nil, nil, true)
    end
  end
  
  hunter.disengage = disengage

  disengage:Callback("backwardsnormal", function(spell)
    if spell:Castable() then
      if spell:Cast() then
        awful.alert("Disengage (Backwards)", spell.id)
      end
    end
  end)


  local triggerFrame = CreateFrame("Frame") 
  triggerFrame.lastTrigger = GetTime()
  triggerFrame.rng = math.random(80, 90) / 100

  triggerFrame:SetScript("OnUpdate", function(self, elapsed)
    if GetTime() - self.lastTrigger > self.rng and self.spell then
   --   print(GetTime() - self.lastTrigger, self.rng)
      if self.spell:Cast() then
        self.spell = nil
        self.enemy = nil
        self.lastTrigger = GetTime()
      end
    end
  end)

  disengage:Callback("backwardsnormaldk", function(spell)
  
    awful.enemies.loop(function(enemy)
      if not enemy.class2 == "DEATHKNIGHT" then return end
      if enemy.used(49576, 2) and enemy.target.isUnit(player) then
        if spell:Castable() then
          awful.alert("Disengage on DK GRIP From " .. enemy.classString, spell.id)
          if GetTime() - triggerFrame.lastTrigger > 3 then
            if enemy.distanceTo(player) < 10 then return end
            triggerFrame.rng = math.random(enemy.distanceTo(player), enemy.distanceTo(player) + 10) / 100
            triggerFrame.lastTrigger = GetTime()
            triggerFrame.spell = spell
            triggerFrame.enemy = enemy
          end
        end
      end
    end)
  end)

  -- start trap stuff --

local colors = awful.colors
local state = { 
    deaths = {}, 
    specs = {},
    startTime = 0,
    elapsed = 0,
    elapsedCombat = 0,
}

gifted.arenaState = state

  cheetah:Callback("pursue trap", function(spell)
    if not player.slowed or not player.snared then return end
    return spell:Cast() and alert("Cheetah (Trap Pursuit)", spell.id)
  end)


-- telegraph delay (time after telegraphing movement toward the healer to delay bait attempt)
local tDelay = {
  min = 1300,
  max = 2500
}

-- commit delay (time after attempting bait to commit to the trap regardless of risk)
local cDelay = {
  min = 1800,
  max = 2800
}


local function couldKnowSpell(obj, id, reasonableTime)
    -- reasonable amount of time after first combat that they may not have used the ability for
    reasonableTime = reasonableTime or 30
    local elapsed = state.elapsedCombat
  
    -- we know they've used it..
    if obj.used(id, elapsed + 69) then return true end
    -- they haven't used it within reasonable time, assume they don't 
    if elapsed > reasonableTime then return false end
    -- otherwise, always assume they have it.
    return true
  
  end 
  
  -- ttu: trapping this unit
  local canCuckTrap = function(obj, travel, ttu, actualObj)
    -- return id if off cd
    local has = function(id) return obj.cooldown(id) <= travel and id end
    local knows = function(id, t) return couldKnowSpell(obj, id, t) end
  
    local class = obj.class2
  
    if class == "SHAMAN" then 
      -- grounding
      if (ttu or obj.distanceTo(actualObj) < 32) and knows(204336) and has(204336) then
        return 204336
      end
      -- spiritwalk
      if (ttu or obj.distanceTo(actualObj) < 15) and knows(58875, 5) and has(58875) then
        return 58875
      end
    end
    if class == "PRIEST" then 
      if ttu then
        -- death
        return has(32379)
        -- holy/shadow club only
        or (obj.spec == "Holy" or obj.spec == "Shadow")
        -- gfade       
        and knows(408557, 50) and has(586)
        -- holy only boly coly bars
        or obj.spec == "Holy"
        -- holy ward
        and knows(213610, 20) and has(213610)
      end
    end
  
    if class == "MONK" then
      if ttu then
        -- port
        return has(119996)
        -- roll
        or knows(109132, 5) and has(109132)
        -- chi torp
        or knows(115008, 0) and has(115008)
        -- 
      end
    end
  end

-- acceptable overlap (adjust this based on other conditions bruh!)
local acceptable_overlap = 0.5
local necessary_overlap = 1
--! TRAPS !--

-- tar 
local tar = NS(187698, { effect = "magic", slow = true })
tar.velocity = 20.5
tar.radius = 1.5

tar:Callback("ghostwolf", function(spell, obj, elapsed, msg)
    awful.enemies.loop(function(obj)
    local x, y, z = obj.predictPosition(elapsed)
    if not obj.buff(2645) then return end 
    if spell:AoECast(x,y,z) then
        return msg and awful.alert("Tar " .. obj.classString .. " (" .. msg .. ")", spell.id) or awful.alert("Tar " .. obj.classString, spell.id)
      end
    end)
  end)
  

-- freezing
trap.velocity = 20.5
trap.radius = 1.5


local gapOpeners = {
  109132, -- roll
  119996, -- port
  310143, -- soulshape
  324701, -- flicker
  115008, -- chi torpedo
  1953,   -- blink
  100,    -- charge
  781,    -- disengage
  48020,  -- demonic circle: teleport
  190784, -- divine steed
  358267, -- hover
  212653, -- shimmer
  6544,   -- heroic leap
  102401, -- wild charge(human)
  49376,  -- wild charge(cat)
  16979,  -- wild charge(bear)

}

hunter.trapKeyPresses = 0
hunter.lastTrapKey = 0
acb(function(msg)
  if msg == "trap" then
    hunter.lastTrapKey = awful.time
    if hunter.listen then
      hunter.trapKeyPresses = hunter.trapKeyPresses + 1
    end
    return true
  end
end)

local margins = {
  safe = 50,
  fair = 125,
  unsafe = 195
}

local predDivisor = 3.2

function trap:travelInfo(unit)

  local buffer, latency = awful.buffer, awful.latency

  -- science
  local dist = unit.distanceLiteral
  local velocity = self.velocity -- in yd/s
  local radius = self.radius -- 1.5yd trigger radius
  local speed, maxSpeed = unit.speed, unit.speed2
  local travel = buffer + latency + dist / velocity
  local maxReach = maxSpeed * travel
  local riskFactor = max(maxReach - self.radius, 0)

  local info = {
    dist = dist,
    radius = radius,
    velocity = velocity,
    travel = travel,
    unit = {
      maxReach = maxReach,
      speed = speed,
      maxSpeed = maxSpeed
    } 
  }

  return info

end

function trap:maxDist(unit, errorMargin)
  
  local speed, maxSpeed = unit.speed, unit.speed2
  local buffer, tickRate, latency = awful.buffer, awful.tickRate, awful.latency
  local radius, velocity = self.radius, self.velocity

  local acceptableRadius = radius + (radius * (errorMargin / 100))

  -- 0.65 surplus..
  -- 43% error margin...

  for simDist = 30, 0, -0.5 do
    local simTravelTime = buffer - tickRate + latency + simDist / velocity, 2
    if maxSpeed * simTravelTime <= acceptableRadius then
      return simDist
    end
  end

  return 0

end

local gz = awful.GroundZ
trap:Callback("normal", function(spell, obj, msg)
  -- don't auto trap in camo
  if awful.time - hunter.lastTrapKey > 1.75 and player.buff(199483) then awful.alert("Press trap key to trap " .. obj.classString, spell.id) return end
  local x, y, z = gz(obj.position())
  if not x then return end
  if spell:AoECast(x,y,z) then
    return msg and awful.alert("Trap " .. obj.classString .. " (" .. msg .. ")", spell.id) or awful.alert("Trap " .. obj.classString, spell.id)
  end
end)

trap:Callback("predict", function(spell, obj, elapsed, msg)
  -- don't auto trap in camo
  if awful.time - hunter.lastTrapKey > 1.75 and player.buff(199483) then awful.alert("Press trap key to trap " .. obj.classString, spell.id) return end
  local x, y, z = gz(obj.predictPosition(elapsed))
  if not x then return end
  if spell:AoECast(x,y,z) then
    return msg and awful.alert("Trap " .. obj.classString .. " (" .. msg .. ")", spell.id) or awful.alert("Trap " .. obj.classString, spell.id)
  end
end)

function trap:immunityRemains(unit)
  local immunities = {}

  -- Magic Immunity
  if unit.magicEffectImmunityRemains > 0 then
    table.insert(immunities, {
      name = "Magic Immunity",
      remains = unit.magicEffectImmunityRemains
    })
  end

  -- CC Immunity
  if unit.ccImmunityRemains > 0 then
    table.insert(immunities, {
      name = "CC Immunity",
      remains = unit.ccImmunityRemains
    })
  end

  -- Searing Glare
    if player.debuff(410201) then
     table.insert(immunities, {
         name = "Searing Glare",
            remains = player.debuffRemains(410201)
            })
        end

  -- AMS Spellwarden
  if unit.buff(410358) then
    table.insert(immunities, {
      name = "AMS Spellwarden",
      remains = unit.buffRemains(410358)
    })
  end

  if unit.buff(48707) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Anti-Magic Shell]",
      remains = 5
    }
  end
  
  -- fleshy c
  if unit.channelID == 324631 then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Fleshcraft]",
      remains = 6
    }
  end

  -- Ultimate Fleshcraft
  if unit.buff(323524) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Ultimate Form]",
      remains = 3
    }
  end

  -- grounding
  if unit.buff(8178) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Grounding]",
      remains = 69
    }
  end

  --Evoker Nullifying Shit
  if unit.buff(378464) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Nullifying Shroud]",
      remains = 30
    }
  end

  --Warrior Reflect
  if unit.buff(23920) then
    immunities[#immunities+1] = {
      name = "Spell Reflect",
      remains = 7
    }
  end

  --Warrior Reflect Legendary
  if unit.buff("Spell Reflection") then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Spell Reflection]",
      remains = 7
    }
  end
  
  --Warrior Reflect Legendary Misshapen Mirror
  if unit.buff("Misshapen Mirror") then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Spell Reflect]",
      remains = 7
    }
  end

  --PROT PALA Immune Spell Warding
  if unit.buff(204018) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Spell Warding]",
      remains = 10
    }
  end

  --PROT PALA Immune Forgotten Queen
  if unit.buff(228050) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Forgotten Queen]",
      remains = 10
    }
  end

  --if not undispellable
  if not player.hasTalent(203340) then 
    --more Sac to make sure we not throw traps into sacs please?
    if unit.buff(6940) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Blessing of Sacrifice]",
        remains = 12
      }
    end

    --Sac more !!
    if unit.buff(199448) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Blessing of Sacrifice]",
        remains = 12
      }
    end

    --Ultimate Sac another one #justin
    if unit.buff(199452) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Blessing of Sacrifice]",
        remains = 6
      }
    end

    --NEW DF Ultimate Sac
    if unit.buff(199448) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Ultimate Sacrifice]",
        remains = 6
      }
    end

    --NEW DF Ultimate Sac2
    if unit.buff(199450) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Ultimate Sacrifice]",
        remains = 6
      }
    end

    --Ultimate Sac another one with name 
    if unit.buff("Ultimate Sacrifice") then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Ultimate Sacrifice]",
        remains = 6
      }
    end

  --NEW Paladin Searing Glare
  if player.debuff(410201) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Searing Glare]",
      remains = 4
    }
  end

  --meteor
  if unit.debuff(155158) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Meteor]",
      remains = 4
    }
  end

  --orb
  if unit.debuff(289308) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Frozen Orb]",
      remains = 4
    }
  end

  --blizzard
  if unit.debuff(12486) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Blizzard]",
      remains = 4
    }
  end

  --deathmark
  if unit.debuff(360194) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Deathmark]",
      remains = 16
    }
  end

  --Feral Frenzy
  if unit.debuff(274837) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Feral Frenzy]",
      remains = 4
    }
  end
  
  --Feral Frenzy
  if unit.debuff(274838) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Feral Frenzy]",
      remains = 4
    }
  end  

  --war banner
  if unit.buff(236321) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[War Banner]",
      remains = 5
    }
  end

  --Monk immune Restoal
  if unit.buff(353319) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Peaceweaver]",
      remains = 2
    }
  end

  --immune Precognition
  if unit.buff(377360) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Precognition]",
      remains = 5
    }
  end
  
  --immune Precognition
  if unit.buff(377362) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Precognition]",
      remains = 5
    }
  end

  --priest Phase Shift
  if unit.buff(408558) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Phase Shift]",
      remains = 1
    }
  end

  --priest Ultimate Penitence
  if unit.buff(421453) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Ultimate Penitence]",
      remains = 5
    }
  end
  
  
  --ensure all remains values are numbers
  for i, immunity in ipairs(immunities) do
    if immunity.remains == nil then
      immunities[i].remains = 0 -- Default nil remains to 0
    end
  end

  sort(immunities, function(x,y) return x.remains > y.remains end)

  return immunities[1]

end

-- Blessing of Sacrifice
  if unit.class2 == "PALADIN" and not player.hasTalent(203340) then -- diamond ice talent
    for _, enemy in ipairs(awful.enemies) do
      local buff, _, _, _, _, _, source = enemy.buff(6940)
      if not buff then
        buff, _, _, _, _, _, source = enemy.buff(199448)
      end
      if buff and unit.isUnit(source) then
        table.insert(immunities, {
          name = "Sac",
          remains = enemy.buffRemains(buff)
        })
      end
    end
  end

  table.sort(immunities, function(x, y) return x.remains > y.remains end)

  return immunities[1] or { name = "None", remains = 0 }
end

function trap:reset()
  hunter.listen = false
  hunter.trapKeyPresses = 0
  self.telegraphDelay = nil
  self.commitDelay = nil
  self.startTime = nil
  self.elapsed = nil
  self.currentTarget = nil
end

local ignorePred = {
331866,   -- Door of Shadows
105421,   -- Blinding Light
118,		  -- Sheep
28272,		-- Pig
277792,		-- Bee
161354,		-- Monkey
277787,		-- Direhorn
161355,		-- Penguin
161353,		-- Polar Bear
120140,		-- Porcupine
61305,		-- Cat
61721,		-- Rabbit
61780,		-- Turkey
28271,		-- Turtle
2094,     -- Blind
196942,   -- Hex?
51514, -- Hex
211015, -- Hex (Cockroach)
210873, -- Hex (Compy)
211010,	-- Hex (Snake)
211004,	-- Hex (Spider)
277784,	-- Hex (Wicker Mongrel)
277778,	-- Hex (Zandalari Tendonripper)
309328,	-- Hex (Living Honey)
269352,	-- Hex (Skeletal Raptor)
207167, -- Blinding Sleet
99,     -- Incap Roar
213691, -- scatter shot
}

local predictionCC = {
1513,     -- scare beast
5246,     -- intim shout
5782,     -- Fear
118699,   -- Actual fear?
10326,    -- Turn evil
8122,     -- Psychic Scream
6789,     -- Coil
360806,   -- Sleep Walk
}


local msg = {
  cd = "|cFF8be9f7Trap|r ready soon...",
  dr = "Waiting for |cFFba8bf7DR",
  cc = "Waiting to follow up",
  immune = "Waiting for immunity",
  range = "Move into range for |cFF8be9f7trap",
  outplay = "Waiting for |cFF8be9f7outplay|r opportunity",
  cdt = "Waiting for CD, then delaying"
}

-- start trap:pursue(obj) -- works for no pre-cc traps
function trap:pursue(obj)

  -- reset always
  trap.cuckable = false

  -- start normal stuff --
  if not obj or not obj.enemy or not obj.exists then 
    self:reset() 
    return 
  end
  if self.cd > 6 then 
    self:reset() 
    return msg.cd 
  end

  if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691) or hunter.trapTarget.stunned) then 
    return 
  end

  -- cc checks for combo on trap:followup(obj) -- WITHOUT MISTWEAVER
  if not settings.MWTOGGLE and settings.autoStun and settings.autoBindingShot then
    if hunter.trapTarget and hunter.trapTarget.exists then
      if hunter.trapTarget.stunDR == 1 or hunter.trapTarget.stundrr <= 3 then
        if (intimidation.cd and intimidation.cd <= 3) or (binding.cd and binding.cd <= 3) then 
          return 
        end
      end
    end
  end
  
  -- cc checks for combo on trap:followup(obj) -- FOR MISTWEAVER
  if settings.MWTOGGLE and settings.autoScatterShot then
    awful.enemies.loop(function(enemy)
      if hunter.trapTarget.class2 == "MONK" and hunter.trapTarget.spec == "Mistweaver" then
        if enemy.cooldown(119996) <= 1.5 and TrackMWPort() then
          if hunter.trapTarget and hunter.trapTarget.exists then
            if hunter.trapTarget.incapDR == 1 or hunter.trapTarget.incapdrr <= 3 then
              if (scatterShot.cd and scatterShot.cd <= 3) then
                return
              end
            end
          end
        end
      end
    end)
  end

  if settings.MWTOGGLE and settings.autoStun and settings.autoBindingShot then
    awful.enemies.loop(function(enemy)
      if hunter.trapTarget.class2 == "MONK" and hunter.trapTarget.spec == "Mistweaver" then
        if enemy.cooldown(119996) >= 5 or not TrackMWPort() then
          if hunter.trapTarget and hunter.trapTarget.exists then
            if hunter.trapTarget.stunDR == 1 or hunter.trapTarget.stundrr <= 3 then
              if (intimidation.cd and intimidation.cd <= 3) or (binding.cd and binding.cd <= 3) then
                return
              end
            end
          end
        end
      end
    end)
  end

  local buffer, tickRate, latency, gcd, gcdRemains = awful.buffer, awful.tickRate, awful.latency, awful.gcd, awful.gcdRemains
  local info = obj.exists and obj.enemy and trap:travelInfo(obj)
  local travel, maxReach = info.travel, info.unit.maxReach

  local Fleshcrafting = obj.channelID == (324631) and obj.channelTimeComplete > 0.3
  local inCamo = player.buff(199483)
  local time = awful.time

  -- Mced unit
  if obj.charmed then return "Waiting for Mind Control" end

  local immunity = trap:immunityRemains(obj)
  local mir = immunity.remains

  if mir > travel - 0.125 then return "Waiting for " .. immunity.name end

  local dr, drr = obj.incapdr, obj.incapdrr
  
  if (dr < 0.5 and not obj.incapped) and drr > travel - 0.125 then return msg.dr end

  local ccr = obj.ccr

  if obj.isUnit(target) then
    hunter.listen = true
    if hunter.trapKeyPresses == 0 then return false end
  end

  local manuallyQueued = awful.time - hunter.lastTrapKey < 1.25
  local followupReady = awful.time - hunter.lastTrapKey < 2.5 or settings.autoFollowup

  local distanceFactor = obj.distance / 100 -- Normalize distance to a factor
  local dynamicOverlap = acceptable_overlap * (1 + distanceFactor) -- Adjust overlap based on distance

  local dist = obj.distanceLiteral 
  local safe = self:maxDist(obj, margins.safe) 
  local unsafe = self:maxDist(obj, margins.unsafe) 
  local fair = self:maxDist(obj, margins.fair)

  local setThreshold = settings.trapThreshold

  -- ultra safe
  if setThreshold <= 0 then
    -- idk do stuff with this
  -- safe
  elseif setThreshold <= 1 then
    -- do nothing, safe is safe by default
  -- fair
  elseif setThreshold <= 2 then
    safe = safe * 1.25
    fair = safe * 1.05
  -- risky
  elseif setThreshold <= 3 then
    safe = fair
    fair = unsafe
    unsafe = unsafe * 1.15
  end

  if dist > unsafe then
    self:reset() 
    if player.combat then
      if settings.disengageTech then
        if dist >= unsafe * 1.015 and dist <= 32.5 and not player.slowed and not player.mounted and not player.buff(199483) and player.movingToward(obj, { angle = 55 + bin(manuallyQueued) * 20, duration = 1.5 - bin(manuallyQueued) * 1 }) then
          cheetah("pursue trap")
        end
      end
    end
    if settings.disengageTech then
      if dist <= 32.5 and dist >= unsafe * 1.1 and not player.mounted and player.movingToward(obj, { angle = 35 + bin(manuallyQueued) * 65, duration = 1.2 - bin(manuallyQueued) * 1 }) then
        disengage:toUnit(obj, 0.1, 0.85)
      end
    end
    if dist <= unsafe * (1.25 + bin(obj.slowRemains < travel + buffer + 0.1) * 1) and dist > safe then
      if hunter.conc then
        if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end
        hunter.conc("yolo trap", obj)
      end
    end
    return time - hunter.lastTrapKey < 2 and msg.range or nil
  end

  -- listen for consecutive trap macro presses, 
  -- loosen restrictions for each press made while in range
  hunter.listen = true

  -- wait for cd before starting delays
  if trap.cd - awful.gcdRemains > 0 then return msg.cdt end

  local elapsed = 0

  self.telegraphDelay = self.telegraphDelay or math.random(tDelay.min, tDelay.max) / 1000
  self.commitDelay = self.commitDelay or math.random(cDelay.min, cDelay.max) / 1000
  if dist <= fair then
    self.startTime = self.startTime or awful.time
    elapsed = awful.time - self.startTime
  else
    self.startTime = awful.time
    elapsed = 0
  end
  self.elapsed = elapsed

  -- reapply conc to keep unit slowed
  if obj.slowRemains <= travel + 0.025 and (not obj.debuff(135299) or obj.moving) and dist > safe * 1.1 then 
    if hunter.conc then
      if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end
      hunter.conc("yolo trap", obj)
    end
  end

  -- pause unimportant dmg gcds for potential gotcha
  if self.cd <= awful.gcdRemains then
    if dist <= safe then
      hunter.importantPause = { msg = "GCD HOLD", texture = self.id }
    elseif dist <= self:maxDist(obj, margins.fair) then
      hunter.unimportantPause = true
    end
  end

  local onGCD = obj.gcdRemains >= travel - 0.025 and not obj.immuneCC

  if obj.used(gapOpeners, 0.75) then return "Waiting - |cFFff4f42Recent Gap-opener" end
  if obj.used(32379, 1.5 - travel) then return "Waiting - |cFFff4f42SW: Death" end

  local cuckable = canCuckTrap(obj, travel, true)
  trap.cuckable = cuckable
  if cuckable and elapsed >= self.telegraphDelay and self.commitDelay - elapsed >= gcd then
    local cuckName = C_Spell.GetSpellInfo(cuckable).name
    tar("predict", obj, travel / predDivisor, cuckName and "Bait |cFFff4f42" .. cuckName)
  end

  local class = obj.class2

  if class == "PALADIN" and obj.slowed and dist > unsafe / 1.65 then
    cuckable = 1044
  end

  local trapCasts = settings.trapCasts

  if obj.used(2645, 1) and not obj.debuff(393456) then return end

  if dist <= (setThreshold >= 3 and fair or safe)
  or onGCD
  or (dist <= (class == "DRUID" and fair or unsafe)) and not cuckable -- was checking for fair dist before, but tbh doesn't matter
  or hunter.trapKeyPresses >= 1 then
    if cuckable then
      if elapsed >= self.commitDelay
      or onGCD
      or (trapCasts and obj.castRemains > travel)
      or hunter.trapKeyPresses >= 2 then
        if elapsed >= self.telegraphDelay then
          hunter.importantPause = { msg = "GCD HOLD", texture = self.id }
          return trap("predict", obj, travel / predDivisor, onGCD and "|cFF6bffc4Gotcha|r ~ GCD" or obj.casting and "|cFF6bffc4On Cast")
        end
      end
      local cuckName = GetSpellInfo(cuckable)
      if cuckName then
        return "Provoking |cFFff4f42" .. cuckName
      end
    else
      if elapsed >= self.telegraphDelay then
        hunter.importantPause = { msg = "GCD HOLD", texture = self.id }
        return trap("predict", obj, travel / predDivisor, onGCD and "|cFF6bffc4Gotcha|r ~ GCD" or obj.casting and "|cFF6bffc4On Cast")
      end
    end
  else
    return msg.outplay
  end
end



  -- start trap:followup(obj) -- works off of other CC
  function trap:followup(obj)
    -- reset always
    trap.cuckable = false
  
    if hunter.trapTarget and hunter.trapTarget.exists and hunter.trapTarget.debuff(117405) then return end
  
    if settings.autoExplosiveTrap then
      if player.recentlyCast(236776, 1) then return end
    end
  
    if not obj then self:reset() return end
    if not obj.enemy or not obj.exists then self:reset() return end
    if self.cd > 6 then self:reset() return msg.cd end
  
    local buffer, tickRate, latency, gcd, gcdRemains = awful.buffer, awful.tickRate, awful.latency, awful.gcd, awful.gcdRemains
    local info = obj.exists and obj.enemy and trap:travelInfo(obj)
    local travel, maxReach = info.travel, info.unit.maxReach
    
    local Fleshcrafting = obj.channelID == (324631) and obj.channelTimeComplete > 0.3
    local inCamo = player.buff(199483)
    local time = awful.time
  
    -- Mced unit
    if obj.charmed then return "Waiting for Mind Control" end
  
    local immunity = trap:immunityRemains(obj)
    local mir = immunity.remains
      
    if mir > travel - 0.125 then return "Waiting for " .. immunity.name end
    
    local dr, drr = obj.incapdr, obj.incapdrr
    if dr < 0.5 and drr > travel - 0.125 then return msg.dr end
      
    local ccr = obj.ccr
    
    if obj.isUnit(target) then
      hunter.listen = true
      if hunter.trapKeyPresses == 0 then return false end
    end
    
    local manuallyQueued = awful.time - hunter.lastTrapKey < 1.25
    local followupReady = awful.time - hunter.lastTrapKey < 2.5 or settings.autoFollowup
    
    local distanceFactor = obj.distance / 100 -- Normalize distance to a factor
    local dynamicOverlap = acceptable_overlap * (1 + distanceFactor) -- Adjust overlap based on distance
    
    if ccr > travel + buffer - bin(manuallyQueued) * (buffer + 0.085) then
      hunter.drawFollowupTrap = {
        obj = obj,
        cc = obj.cc,
        remains = ccr,
        after = ccr - travel + dynamicOverlap + buffer,
        travel = travel,
      }
      -- handle followup trap prediction logic here
      if obj.moving and not obj.stunned then
        if obj.speed < 7.5 then
          local fullPred = obj.debuffFrom(predictionCC)
          local partialPred = obj.debuffFrom(ignorePred)
  
          if fullPred or obj.stunned then
            local dChange = obj.timeSinceDirectionChange
  
            hunter.drawFollowupTrap.predict = true
            hunter.drawFollowupTrap.dirChange = dChange
  
            local goodChange = dChange < 0.95 and dChange > 0.09 or obj.speed < 4.65
            if obj.los then
              if ccr > travel + bin(goodChange) * dynamicOverlap + (buffer + gcd) * 2 then -- Reduced delay
                if hunter.conc then
                  hunter.conc("yolo trap", obj)
                end
              elseif followupReady and ccr < 0.75 + travel + buffer and obj.distanceLiteral <= travel + buffer then -- Adjusted check
                if ccr <= travel + buffer + gcd then -- Only hold GCD for 1 GCD before the trap throw
                  hunter.importantPause = { msg = "GCD HOLD", texture = self.id }
                  return trap("predict", obj, travel + buffer + tickRate, "|cFF8be9f7Predict Pathing")
                end
              elseif ccr <= travel + dynamicOverlap + buffer + bin(manuallyQueued) * 4 then -- New condition for fullPred
                if followupReady then
                  if ccr <= travel + buffer + gcd then -- Only hold GCD for 1 GCD before the trap throw
                    hunter.importantPause = { msg = "GCD HOLD", texture = self.id }
                    return trap("normal", obj, manuallyQueued and "|cFFf7f25c[Manual - Early]")
                  end
                end
              elseif ccr > travel + buffer then
                return msg.cc
              end
            end
          elseif partialPred then
            if ccr <= travel + dynamicOverlap + bin(awful.time - hunter.lastTrapKey < 1.25) * 2 + buffer + 0.025 and (cc ~= 1513 or obj.rooted) then
              if followupReady then
                if ccr <= travel + buffer + gcd then -- Only hold GCD for 1 GCD before the trap throw
                  hunter.importantPause = { msg = "GCD HOLD", texture = self.id }
                  return trap("predict", obj, (travel + buffer + tickRate) / 3, "|cFF8be9f7Slight Prediction") -- Reduced delay
                end
              end
            end
          elseif obj.classString then
            alert("|cFFff5e5eCan't Trap " .. obj.classString .. " [Moving]", self.id)
          end
        end
      else
        if ccr <= travel + dynamicOverlap + (buffer + gcd) * 2 + bin(manuallyQueued) * 4 then -- Reduced delay
          if obj.class2 == "MONK" and obj.isHealer and obj.cooldown(119996) <= travel and not (obj.stunned or obj.rooted) then 
            tar("predict", obj, travel / predDivisor, "Bait |cFFff4f42Transcendence")
          end
        end

        if ccr <= travel + dynamicOverlap + buffer + bin(manuallyQueued) * 4 and (cc ~= 1513 or obj.rooted) then
          if followupReady then
            if player.casting or player.channeling then 
              if player.castID == 982 then return end
              awful.call("SpellStopCasting") 
              awful.call("SpellStopCasting")
            end
            if ccr <= travel + buffer + gcd then -- Only hold GCD for 1 GCD before the trap throw
              hunter.importantPause = { msg = "GCD HOLD", texture = self.id }
              return trap("normal", obj, manuallyQueued and "|cFFf7f25c[Manual - Early]")
            end
          end
        end
      end
    end
  end
hunter.trap = trap
    
hunter.controllingPet = 0
    
hunter.trapTarget = {}
onUpdate(function()
  local time, tickRate = awful.time, awful.tickRate
  
  if settings.trapUnit == "healer" then
    hunter.trapTarget = (enemyHealer.exists and not enemyHealer.isUnit(target) and enemyHealer or {})
  end
  if settings.trapUnit == "focus" then
    hunter.trapTarget = (focus.exists and not focus.isUnit(target) and focus or {})
  end

  hunter.bm.trapTarget = hunter.trapTarget
  -- pet control
  if time - hunter.controllingPet > tickRate * 7 then
    hunter.petControlImportance = 0
  end 
end)
-- end trap stuff --
-- draw trap stuff --

local AwfulFontLarge = awful.createFont(16)
local AwfulFontNormal = awful.createFont


local function normalize(a)
  return min(255, max(0, a))
end
local ddraw = 0
awful.Draw(function(draw)
  if not settings.trapesp then return end
  if not settings.drawings then return end

  -- if true then return end
  if UnlockerType == "daemonic" then
    draw:SetWidth(4)
  end

  local tt = hunter.trapTarget

  if tt.enemy and trap.cd < 1 then

    local followup = hunter.drawFollowupTrap
    if followup then
      local cc, remains, travel = followup.cc, followup.remains, followup.travel
      if cc then
        local x,y,z = tt.position()
        draw:SetColor(255,255,255,255)
        if followup.predict then
          local px, py, pz = tt.predictPosition(travel + awful.buffer)
          local angle = angles(x,y,z,px,py,pz)
          local diam = trap.radius * 2
          draw:FilledCircle(px, py, pz, diam)
          draw:Line(x, y, z, px + diam * cos(angle), py + diam * sin(angle), pz)
        end
        if awful.textureEscape(cc) then
          local str = awful.textureEscape(cc) .. " >> " .. awful.textureEscape(trap.id)
          draw:Text(str, AwfulFontNormal, x, y, z - 0.5)
          if followup.after then
            draw:Text(round(math.floor(remains - travel),1), AwfulFontLarge, x, y, z - 2.5)
          end
        end
      end
    else

      local d1 = trap:maxDist(tt, margins.safe)
      local d2 = trap:maxDist(tt, margins.fair)
      local d3 = trap:maxDist(tt, margins.unsafe)
      local x, y, z = awful.GroundZ(tt.position())
      if not x then return end

      -- Check for conditions that should stop drawing
      if (intimidation.cd < 5 and settings.autoStun) or (binding.cd < 5 and settings.autoBindingShot) or (scatterShot.cd < 5 and settings.MWTOGGLE) then return end

      local trMod = max(0, (trap.cd - awful.gcdRemains) * 20)
      local d = tt.distanceLiteral
      local tengage = hunter.trapKeyPresses >= 1

      if UnlockerType == "daemonic" then
        if settings.trapThreshold == 0 then
          draw:SetColor(0, 255, 0, (d < d1 * 0.7 and 255 or 100) - trMod) -- Brighter green for ultrasafe
          if d < d1 * 0.7 then
            draw:FilledCircle(x, y, z, d1 * 0.7) -- Make d1 even smaller for ultrasafe
          else
            draw:Outline(x, y, z, d1 * 0.7)
          end
        elseif settings.trapThreshold == 1 then
          draw:SetColor(173, 255, 173, (d < d1 and 255 or 100) - trMod) -- Brighter light green for safe
          if d < d1 then
            draw:FilledCircle(x, y, z, d1)
          else
            draw:Outline(x, y, z, d1)
          end
        elseif settings.trapThreshold == 2 then
          draw:SetColor(244 - bin(tengage) * 85, 195 + bin(tengage) * 60, 45, normalize((d < d1 and 25 or d < d2 and d > d1 and 235 or 125) - trMod))
          if d < d3 then
            draw:FilledCircle(x, y, z, d2)
          else
            draw:Outline(x, y, z, d2)
          end
        elseif settings.trapThreshold == 3 then
          draw:SetColor(235 - bin(tengage) * 80, 90 + bin(tengage) * 90, 35, normalize((d < d3 and d > d2 and 185 or 125) - trMod))
          if d < d3 and d > d2 then
            draw:FilledCircle(x, y, z, d3)
          elseif d > d2 then
            draw:Outline(x, y, z, d3)
          end
        end
      else
        if settings.trapThreshold == 0 then
          draw:SetColor(0, 255, 0, normalize((d < d1 * 0.7 and 150 or 100) - trMod)) -- Brighter green for ultrasafe
          if d < d1 * 0.7 then
            draw:FilledCircle(x, y, z, d1 * 0.7) -- Make d1 even smaller for ultrasafe
          else
            draw:Outline(x, y, z, d1 * 0.7)
          end
        elseif settings.trapThreshold == 1 then
          draw:SetColor(173, 255, 173, normalize((d < d1 and 135 or 110) - trMod)) -- Brighter light green for safe
          if d < d1 then
            draw:FilledCircle(x, y, z, d1)
          else
            draw:Outline(x, y, z, d1)
          end
        elseif settings.trapThreshold == 2 then
          draw:SetColor(244 - bin(tengage) * 85, 195 + bin(tengage) * 60, 45, normalize((d < d1 and 20 or d < d2 and d > d1 and 65 or 55) - trMod))
          if d < d3 then
            draw:FilledCircle(x, y, z, d2)
          else
            draw:Outline(x, y, z, d2)
          end
        elseif settings.trapThreshold == 3 then
          draw:SetColor(235 - bin(tengage) * 80, 90 + bin(tengage) * 90, 35, normalize((d < d3 and d > d2 and 25 or 15) - trMod))
          if d < d3 and d > d2 then
            draw:FilledCircle(x, y, z, d3)
          elseif d > d2 then
            draw:Outline(x, y, z, d3)
          end
        end
      end

      if tt.moving then
        local info = trap:travelInfo(tt)
        local travel, maxReach = info.travel, info.unit.maxReach
        local px, py, pz = tt.predictPosition(travel / predDivisor)
        draw:SetColor(155, 165, 255, 255)
        -- draw:Line(x, y, z, px, py, pz)
        draw:Circle(px, py, pz, 0.5)
      end
      if trap.elapsed and trap.cuckable then
        draw:SetColor(235 - bin(trap.elapsed > trap.commitDelay) * 130, 214, 255 - bin(trap.elapsed > trap.commitDelay) * 160, 255)
        local txt = trap.elapsed > trap.commitDelay and "Ready to commit" or round(trap.elapsed, 1) .. "/" .. round(trap.commitDelay - awful.buffer, 1)
        draw:Text(txt, AwfulFontLarge, x, y, z + 0.5)
        end
      end
    end
  end)

-- end draw trap stuff --

-- start purge stuff --

tranquilizingShot:Callback("pvp-prio", function(spell)
    if not player.combat then return end
    if not awful.arena then return end
    if gifted.WasCasting[spell.id] then return end
    if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end 
    if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end


    local enemiesCurrent = awful.enemies.filter(function(obj)
        return obj.distance <= 40
    end)

    enemiesCurrent.loop(function(enemy)
      if not enemy.player then return end
        if not spell:Castable(enemy) then return end
        if enemy.purgeCount < 1 then return end
        if enemy.buffFrom(prioPurge) then
            return spell:Cast(enemy)
        end
    end)
end)

tranquilizingShot:Callback("target-prio", function(spell)
    if not player.combat then return end
    if not awful.arena then return end
    if gifted.WasCasting[spell.id] then return end
    if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
    if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end
    if not target.exists then return end
    if not target.enemy then return end
    if not target.player then return end
    if target.purgeCount == 0 then return end
    if spell:Castable(target) then
        return spell:Cast(target)
    end
end)

-- end purge stuff --

-- start binding stuff --  -- add checks 

binding:Callback("feral opener", function(spell)
  if not settings.stunOthers then return end
  if not settings.MWTOGGLE then return end
  if not settings.disengageTech then return end
  if not player.hasTalent(109248) then return end

  if player.debuff(50259) and player.stunDR == 1 then
    local dir = inverse(player.rotation)
    local px, py, pz = player.position()
    local ex, ey, ez = px + 9.7 * cos(dir), py + 9.7 * sin(dir), pz
    local x, y, z = player.predictPosition(0.35)
    if spell:AoECast(x, y, z) then
      disengage:movingDirection(false, -1)
      C_Timer.After(0, function() disengage:movingDirection(false, -1) end)
      awful.alert("Binding Shot (" .. colored("Binding Feral Opener", colors.cyan) .. ")", spell.id)
    end
  end
end)

binding:Callback("warrior charge", function(spell)
  if not settings.stunOthers then return end
  if not settings.MWTOGGLE then return end
  if not settings.disengageTech then return end
  if not player.hasTalent(109248) then return end

  if player.debuff(105771) and player.stunDR == 1 then
    local px, py, pz = player.position()
    local x, y, z = player.predictPosition(0.35)
    if spell:AoECast(x, y, z) then
      disengage("backwardsnormal")
      awful.alert("Binding Shot (" .. colored("Binding Warrior Charge", colors.cyan) .. ")", spell.id)
    end
  end
end)

binding:Callback("rogue step", function(spell)
  if not settings.stunOthers then return end
  if not settings.MWTOGGLE then return end
  if not settings.disengageTech then return end
  if not player.hasTalent(109248) then return end

  awful.enemies.loop(function(enemy)
    if not enemy.class2 == "ROGUE" then return end
    if enemy.used(36554, 1) and player.stunDR == 1 then
      if enemy.distanceTo(player) <= 6 then
      local dir = inverse(player.rotation)
      local px, py, pz = player.position()
      local ex, ey, ez = px + 9.7 * cos(dir), py + 9.7 * sin(dir), pz
      local x, y, z = player.predictPosition(0.35)
      if spell:AoECast(x, y, z) then
        disengage:movingDirection(false, -1)
        C_Timer.After(0, function() disengage:movingDirection(false, -1) end)
        awful.alert("Binding Shot (" .. colored("Binding Rogue Step", colors.cyan) .. ")", spell.id)
        end
      end
    end
  end)
end)

function binding:handler()
  return self("feral opener") or self("warrior charge") or self("rogue step")
end

hunter.binding = binding


binding:Callback("stacked", function(spell)
  if not settings.stunOthers then return end
  if not settings.MWTOGGLE then return end
  if not settings.disengageTech then return end
  if not player.combat then return end
  if not player.hasTalent(gifted.BINDING_SHOT_TALENT) then return end
  if not player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end


  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if not enemy.isUnit(hunter.trapTarget) then
      if awful.enemies.around(enemy, 8) >= 2 then
        if enemy.stunDR == 1 then
          local x, y, z = enemy.position()
          if spell:AoECast(x, y, z) then
            awful.alert("Binding Shot on " .. enemy.classString, "STACKED", spell.id)
          end
        end
      end
    end
  end)
end)


binding:Callback("beastial wrath pets", function(spell)
  if not settings.stunOthers then return end
  if not settings.MWTOGGLE then return end
  if awful.prep then return end
  if target.exists and target.hp <= 30 then return end
  if spell.cd - awful.gcdRemains > 0 then return end

  awful.pets.loop(function(pet)
    if not pet.enemy then return end
    if pet.distance > spell.range then return end
    if not pet.los then return end
    if pet.debuff(gifted.TAR_TRAP_DEBUFF_ID) then return end

    local dontUseIt = pet.immuneSlow or pet.slowed or pet.rooted or pet.ccRemains > 1.5 or pet.distanceLiteral > 10
    if dontUseIt then return end

    local gz = awful.GroundZ
    local x, y, z = gz(pet.predictPosition(0.35))
    if not x then return end

    if pet.buff("Beastial Wrath") and pet.buffRemains("Beastial Wrath") > 4 and player.combat then
      if spell:AoECast(x, y, z) then
        awful.alert("Binding Shot on " .. pet.classString .. " - Beastial Wrath Pets Stacked", spell.id)
      end
    end
  end)
end)

binding:Callback("cover stuff", function(spell)
  if not settings.stunOthers then return end
  if not settings.MWTOGGLE then return end
  if not player.hasTalent(spell.id) then return end
  if player.hasTalent(203340) then return end --Diamond Ice

  if player.hasTalent(109248) then
    local DH = awful.enemies.find(function(obj) return obj.class2 == "DEMONHUNTER" and obj.enemy end)
    if not DH then return end
      
    if DH and (enemyHealer.debuff(3355)
    and enemyHealer.debuffRemains(3355) >= 2
    or enemyHealer.stunned and enemyHealer.disorientDR == 1 and trap.cd - awful.gcdRemains <= 1)
    and DH.enemy
    and player.distanceTo(DH) <= 30
    and DH.cooldown(205604) <= 3 
    and not (DH.immuneSlow or DH.immuneMagicEffects) then
      if spell:SmartAoE(DH) then
        awful.alert("|cFFf7f25c[Cover Trap]: |cFFFFFFFFBinding Shot[" .. DH.classString .. "]", spell.id)
      end
    end
  end

  --Monk Clones
  -- local MonkClones = awful.units.find(function(obj) return obj.id == 69791 and obj.enemy end) or awful.units.find(function(obj) return obj.id == 69792 and obj.enemy end)
  -- local DH = awful.enemies.find(function(obj) return obj.class2 == "DEMONHUNTER" end)
  -- if MonkClones then 
  --   if DH and DH.enemy then return end
  --   if MonkClones and MonkClones.enemy then
  --     if spell:SmartAoE(MonkClones, { diameter = 15, range = 30, movePredTime = awful.buffer}) then
  --       alert("Binding Shot [" .. MonkClones.classString .. "]", spell.id)
  --     end
  --   end
  -- end

end)

-- end binding stuff --

-- start intimidation stuff --

intimidation:Callback("traptarget", function(spell)
  if not settings.autoStun then return end
  if settings.MWTOGGLE then return end
  if not player.combat then return end

  if not player.hasTalent(19577) then return end

  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if pet.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if player.recentlyCast(109248, 3) then return end
  if player.lastCast == 109248 then return end
  
  if trap.cd > 1.5 then return end

  if not pet.exists then return end
  if pet.dead then return end
  if not pet.losOf(hunter.trapTarget) then return end

  awful.enemies.loop(function(enemy)

    if not hunter.trapTarget.exists then return end
    if not hunter.trapTarget.enemy then return end
    if not enemy.isUnit(hunter.trapTarget) then return end
    if hunter.trapTarget.buff(410358) then return end -- spellwarding
    if hunter.trapTarget.debuff(gifted.SOLAR_BEAM_DEBUFF_ID) then return end
    if hunter.trapTarget.distance > 28 then return end
    if hunter.trapTarget.incapacitateDR < 0.5 then return end
    if hunter.trapTarget.stunDR < 1 then return end
    if hunter.trapTarget.ccr > 0.5 or hunter.trapTarget.bccr > 0.5 then return end
    if hunter.trapTarget.immune then return end
    if hunter.trapTarget.immuneMagic then return end
    if hunter.trapTarget.debuff(117405) then return end -- binding before stun 

    if spell:Castable(hunter.trapTarget) then
      if spell:Cast(hunter.trapTarget) then
        awful.alert("Intim Stun (TRAP)" .. hunter.trapTarget.classString, spell.id)
      end
    end
  end)
end)

intimidation:Callback("Kill Target", function(spell)
  if not player.hasTalent(19577) then return end
  if not settings.stunKillTarget then return end
  if settings.autoStun then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if pet.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if not player.combat then return end
  if trap.cd > 2 then return end


  if not pet.exists then return end
  if pet.dead then return end
  if not pet.losOf(target) then return end

  awful.enemies.loop(function(enemy)
    if not target.exists and not target.enemy then return end
    if target.stunDR < 1 then return end
    if target.ccr > 0.8 then return end
    if target.bccr > 0.8 then return end
    if target.distance > 28 then return end

    if pet.distanceTo(target) > 40 then return end
    if target.buff(410358) then return end -- spellwarding

    if not enemyHealer.exists then return end
    if enemyHealer.ccr < 3 then return end

    if spell:Castable(target) then
      if spell:Cast(target) then
        awful.alert("Intim Stun (Kill Target)" .. target.classString, spell.id)
      end
    end
  end)
end)

-- end intimidation stuff --

-- start binding trap stuff --

binding:Callback("traptarget", function(spell)
  if not settings.autoBindingShot then return end
  if settings.MWTOGGLE then return end

  if not player.combat then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if not player.hasTalent(109248) then return end

  if trap.cd > 1.5 then return end
  if intimidation.cd < 1.5 then return end

  if player.recentlyCast(19577, 3) then return end
  if player.lastCast == 19577 then return end

  awful.enemies.loop(function(enemy)

    if not hunter.trapTarget.exists then return end
    if not hunter.trapTarget.enemy then return end
    if not enemy.isUnit(hunter.trapTarget) then return end
    if hunter.trapTarget.buff(410358) then return end -- spellwarding
    if hunter.trapTarget.debuff(gifted.SOLAR_BEAM_DEBUFF_ID) then return end
    if hunter.trapTarget.debuff(24394) then return end
    if hunter.trapTarget.debuff("Frost Nova") then return end
    if hunter.trapTarget.distance > 28 then return end
    if hunter.trapTarget.incapacitateDR < 0.5 then return end
    if hunter.trapTarget.stunDR < 1 then return end
    if hunter.trapTarget.ccr > 0.5 or hunter.trapTarget.bccr > 0.5 then return end
    if hunter.trapTarget.immune then return end
    if hunter.trapTarget.immuneMagic then return end

    if not spell:Castable(hunter.trapTarget) then return end


    local x, y, z = enemy.predictPosition(0.5)
      if spell:AoECast(x, y, z) then
        awful.alert("Binding Shot on " .. enemy.classString, spell.id)
    end
  end)
end)

-- end binding trap stuff --

-- start explosive trap stuff --

highExplosiveTrap:Callback("traptarget", function(spell)
  if not settings.autoExplosiveTrap then return end
  if not player.combat then return end

  if not player.hasTalent(236776) then return end -- explosive trap talent

  if player.recentlyCast(186387, 3) then return end
  if player.lastCast == 186387 then return end

  awful.enemies.loop(function(enemy)

    if not hunter.trapTarget.exists then return end
    if not hunter.trapTarget.enemy then return end
    if not enemy.isUnit(hunter.trapTarget) then return end
    
    if burstingShot:Castable() and settings.autoBurstingShot and (player.movingToward(hunter.trapTarget) or hunter.trapTarget.distance <= 6) and hunter.trapTarget.distance <= 15 then return end


    if hunter.trapTarget.distance > 15 then return end
    if not hunter.trapTarget.debuff(117405) then return end -- binding before stun
    if hunter.trapTarget.stunDR < 1 then return end

    if hunter.trapTarget.buff(410358) then return end -- spellwarding
    if hunter.trapTarget.debuff(24394) then return end -- intim
    if hunter.trapTarget.debuff("Frost Nova") then return end
    if hunter.trapTarget.incapacitateDR < 0.5 then return end
    if hunter.trapTarget.immune then return end
    if hunter.trapTarget.immuneMagic then return end
    if hunter.trapTarget.stunned then return end
    if hunter.trapTarget.moving then return end

      local x, y, z = enemy.predictPosition(0.25)
      if spell:AoECast(x, y, z) then
        awful.alert("High Explosive Trap on " .. hunter.trapTarget.classString, spell.id)
    end
  end)
end)

highExplosiveTrap:Callback("traptarget-intimidation", function(spell)
  if not settings.autoExplosiveTrap then return end
  if not player.combat then return end

  if not player.hasTalent(236776) then return end -- explosive trap talent

  if player.recentlyCast(186387, 3) then return end
  if player.lastCast == 186387 then return end

  awful.enemies.loop(function(enemy)

    if not hunter.trapTarget.exists then return end
    if not hunter.trapTarget.enemy then return end
    if not enemy.isUnit(hunter.trapTarget) then return end

    if hunter.trapTarget.class2 ~= "DRUID" then return end
    
    if burstingShot:Castable() and settings.autoBurstingShot and (player.movingToward(hunter.trapTarget) or hunter.trapTarget.distance <= 6) and hunter.trapTarget.distance <= 11 then return end


    if hunter.trapTarget.distance > 11 then return end
    if not hunter.trapTarget.debuff(24394) then return end -- intimidation
    if hunter.trapTarget.debuff("Frost Nova") then return end

    if hunter.trapTarget.buff(410358) then return end -- spellwarding
    if hunter.trapTarget.incapacitateDR < 0.5 then return end
    if hunter.trapTarget.immune then return end
    if hunter.trapTarget.immuneMagic then return end

      local x, y, z = enemy.position()
      if spell:AoECast(x, y, z) then
        awful.alert("High Explosive Trap on " .. hunter.trapTarget.classString, spell.id)
    end
  end)
end)

highExplosiveTrap:Callback("traptarget-druid-binding", function(spell)
  if not player.combat then return end
  if not settings.autoExplosiveTrap then return end

  if binding.cd == 0 then return end
  if not player.recentlyCast(109248, 3) then return end

  awful.enemies.loop(function(enemy)

  if not hunter.trapTarget.exists then return end
  if not hunter.trapTarget.enemy then return end
  if not enemy.isUnit(hunter.trapTarget) then return end

  if hunter.trapTarget.class2 ~= "DRUID" then return end

  if hunter.trapTarget.buff(410358) then return end -- spellwarding

  if hunter.trapTarget.debuff(24394) then return end -- intim
  if hunter.trapTarget.debuff(117526) then return end -- binding stun
  if not hunter.trapTarget.debuff(117405) then return end -- binding before stun
  if hunter.trapTarget.debuff("Frost Nova") then return end
  if hunter.trapTarget.distance > 24 then return end
  if hunter.trapTarget.incapacitateDR < 0.5 then return end
  if hunter.trapTarget.stunDR < 1 then return end
  if hunter.trapTarget.ccr > 0.5 or hunter.trapTarget.bccr > 0.5 then return end
  if hunter.trapTarget.immune then return end
  if hunter.trapTarget.immuneMagic then return end
  if hunter.trapTarget.moving then return end -- alternatively, test for timeStandingStill at some point to see if this works for more than just player.

  local x, y, z = enemy.predictPosition(0.25)
  -- Calculate a position slightly further away from the enemy to push them towards us
  local dir = inverse(enemy.rotation)
  local offsetX, offsetY = 3 * cos(dir), 3 * sin(dir) -- Adjust the offset as needed
  local targetX, targetY, targetZ = x + offsetX, y + offsetY, z

  if spell:AoECast(targetX, targetY, targetZ) then
    awful.alert("Binding Shot on " .. enemy.classString, spell.id)
  end
end)
end)



highExplosiveTrap:Callback("knock-defensives", function(spell)
  if not settings.autoKnockBuffs or not player.combat or not player.hasTalent(236776) then return end
  if player.recentlyCast(186387, 3) or player.lastCast == 186387 then return end

  if not spell:Castable() or not target.exists or not target.enemy or target.immune or target.immuneMagic or target.rooted then return end
  if target.debuff("Frost Nova") then return end
  if not target.buffFrom(DefensiveKnockBuffs) then return end

    if burstingShot:Castable() and settings.autoKnockBuffsBS and (player.movingToward(target) or target.distance <= 6) and target.distance <= 6 then return end

  if ((target.slowed or target.snared or target.stunned) and target.distance <= 18) or target.distance <= 12 then
    local x, y, z = target.predictPosition(0.25)
    if spell:AoECast(x, y, z) then
      awful.alert("High Explosive Trap on " .. target.classString .. " - Knock Defensives", spell.id)
    end
  end
end)

-- end explosive trap stuff --


-- start bursting shot stuff --

burstingShot:Callback("traptarget", function(spell)
  if not settings.autoBurstingShot then return end
  if not player.combat then return end
  if not player.hasTalent(186387) then return end
  if not spell:Castable() then return end


  if player.recentlyCast(236776, 3) then return end
  if player.lastCast == 236776 then return end

  if not hunter.trapTarget.exists then return end
  if not hunter.trapTarget.enemy then return end

  if not hunter.trapTarget.debuff(117405) then return end -- binding before stun

  if hunter.trapTarget.buff(410358) then return end -- spellwarding
  if hunter.trapTarget.debuff(24394) then return end -- intim
  if hunter.trapTarget.debuff("Frost Nova") then return end
  if hunter.trapTarget.immune then return end
  if hunter.trapTarget.immuneMagic then return end
  if hunter.trapTarget.stunned then return end


  if hunter.trapTarget.distance > 6 then return end

  if spell:Castable() then

    if not player.facing(hunter.trapTarget, 5) then
      awful.protected.TurnOrActionStop()
      player.face(hunter.trapTarget)
      if spell:Cast() then
        awful.alert("Knock " .. hunter.trapTarget.classString .. " Trap Combo", spell.id)
      end
    end
  end
end)

burstingShot:Callback("traptarget-intimidation", function(spell)
  if not settings.autoBurstingShot then return end
  if not player.combat then return end

  if not player.hasTalent(186387) then return end -- bursting shot talent

  if player.recentlyCast(236776, 3) then return end
  if player.lastCast == 236776 then return end

  awful.enemies.loop(function(enemy)

    if not hunter.trapTarget.exists then return end
    if not hunter.trapTarget.enemy then return end

    if hunter.trapTarget.class2 ~= "DRUID" then return end

    if not hunter.trapTarget.exists then return end
    if not hunter.trapTarget.enemy then return end
  
    if not hunter.trapTarget.debuff(24394) then return end -- intimidation
    if hunter.trapTarget.debuff("Frost Nova") then return end
    if hunter.trapTarget.buff(410358) then return end -- spellwarding
    if hunter.trapTarget.immune then return end
    if hunter.trapTarget.immuneMagic then return end  
  
    if hunter.trapTarget.distance > 6 then return end
  
    if spell:Castable() then
  
      if not player.facing(hunter.trapTarget, 5) then
        awful.protected.TurnOrActionStop()
        player.face(hunter.trapTarget)
        if spell:Cast() then
          awful.alert("Knock " .. hunter.trapTarget.classString .. " Trap Combo", spell.id)
        end
      end
    end
  end)
end)



burstingShot:Callback("knock-defensives", function(spell)
  if not settings.autoKnockBuffsBS then return end
  if not player.combat then return end
  if not player.hasTalent(186387) then return end
  if not spell:Castable() then return end

  if player.recentlyCast(236776, 3) or player.lastCast == 236776 then return end

  if not target.exists then return end
  if not target.enemy then return end
  if target.immune or target.immuneMagic or target.rooted then return end
  if target.debuff("Frost Nova") then return end
  if not target.buffFrom(DefensiveKnockBuffs) then return end

  if target.distance > 6 then return end

  if not player.facing(target) then
    awful.protected.TurnOrActionStop()
    player.face(target)
  end

  if spell:Cast() then
    awful.alert("Knock " .. target.classString .. " Trap Combo", spell.id)
  end
end)




-- end bursting shot stuff --

-- start scatter trap stuff MW --


scatterShot:Callback("MW", function(spell)
  if not settings.autoScatterShot then return end
  if not settings.MWTOGGLE then return end
  if not player.combat then return end
  if not player.hasTalent(gifted.SCATTER_SHOT_TALENT) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if trap.cd > 1.5 then return end

  if player.recentlyCast(19577, 3) then return end
  if player.lastCast == 19577 then return end

  if player.recentlyCast(109248, 3) then return end
  if player.lastCast == 109248 then return end

  awful.enemies.loop(function(enemy)

    if not hunter.trapTarget.exists then return end
    if not hunter.trapTarget.enemy then return end
    if not enemy.isUnit(hunter.trapTarget) then return end
    if hunter.trapTarget.buff(410358) then return end -- spellwarding

    if hunter.trapTarget.debuff(gifted.SOLAR_BEAM_DEBUFF_ID) then return end
    if hunter.trapTarget.distance > 20 then return end
    if hunter.trapTarget.incapacitateDR < 1 then return end

    if hunter.trapTarget.cc or hunter.trapTarget.bcc then return end

    if hunter.trapTarget.debuff(24394) then return end
    if hunter.trapTarget.debuff(117526) then return end

    if hunter.trapTarget.class2 == "MONK" and hunter.trapTarget.spec == "Mistweaver" then
      if enemy.cooldown(119996) <= 1.5 and TrackMWPort() then 

    if spell:Castable(hunter.trapTarget) then
      if spell:Cast(hunter.trapTarget, { face = true }) then
        awful.alert("Scatter Shot (MW)", spell.id)
          end
        end
      end
    end
  end)
end)

intimidation:Callback("MW", function(spell)
  if not settings.autoStun then return end
  if not settings.MWTOGGLE then return end
  if not player.combat then return end

  if not player.hasTalent(19577) then return end

  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if pet.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if player.recentlyCast(109248, 3) then return end
  if player.lastCast == 109248 then return end

  if trap.cd > 1.5 then return end

  awful.enemies.loop(function(enemy)

    if not hunter.trapTarget.exists then return end
    if not hunter.trapTarget.enemy then return end
    if not enemy.isUnit(hunter.trapTarget) then return end
    if hunter.trapTarget.buff(410358) then return end -- spellwarding
    if hunter.trapTarget.debuff(gifted.SOLAR_BEAM_DEBUFF_ID) then return end


    if hunter.trapTarget.distance > 30 then return end
    if hunter.trapTarget.incapacitateDR < 0.5 then return end
    if hunter.trapTarget.stunDR < 1 then return end
    if hunter.trapTarget.ccr > 0.5 or hunter.trapTarget.bccr > 0.5 then return end
    if hunter.trapTarget.immune then return end
    if hunter.trapTarget.immuneMagic then return end
    if pet.distanceTo(hunter.trapTarget) > 40 then return end
    if hunter.trapTarget.debuff(117405) then return end -- binding before stun 
    if spell:Castable(hunter.trapTarget) then

      if hunter.trapTarget.class2 == "MONK" and hunter.trapTarget.spec == "Mistweaver" then
        if enemy.cooldown(119996) >= 5 or not TrackMWPort() then 
          if enemy.buff("Escape From Reality") then return end

      if spell:Cast(hunter.trapTarget) then
        awful.alert("Intim Stun (TRAP)" .. hunter.trapTarget.classString, spell.id)
          end
        end
      end
    end
  end)
end)

binding:Callback("MW", function(spell)
  if not settings.autoBindingShot then return end
  if not settings.MWTOGGLE then return end
  if not player.combat then return end
  if not player.hasTalent(109248) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if player.recentlyCast(19577, 3) then return end
  if player.lastCast == 19577 then return end


  if intimidation.cd < 1.5 then return end
  if trap.cd > 1.5 then return end
  local has = function(id) return enemy.cooldown(id) <= 1.5 and id end


  awful.enemies.loop(function(enemy)

    if not hunter.trapTarget.exists then return end
    if not hunter.trapTarget.enemy then return end
    if not enemy.isUnit(hunter.trapTarget) then return end
    if hunter.trapTarget.buff(410358) then return end -- spellwarding
    if hunter.trapTarget.debuff(gifted.SOLAR_BEAM_DEBUFF_ID) then return end


    if hunter.trapTarget.debuff(24394) then return end
    if hunter.trapTarget.distance > 25 then return end
    if hunter.trapTarget.incapacitateDR < 0.5 then return end
    if hunter.trapTarget.stunDR < 1 then return end
    if hunter.trapTarget.ccr > 0.5 or hunter.trapTarget.bccr > 0.5 then return end
    if hunter.trapTarget.immune then return end
    if hunter.trapTarget.immuneMagic then return end
  
    if hunter.trapTarget.class2 == "MONK" and hunter.trapTarget.spec == "Mistweaver" then
      if enemy.cooldown(119996) >= 5 or not TrackMWPort() then 
        if enemy.buff("Escape From Reality") then return end

    local x, y, z = enemy.predictPosition(0.3)

      if spell:AoECast(x, y, z) then
        awful.alert("Binding Shot on " .. enemy.classString, spell.id)
        end
      end
    end
  end)
end)
-- tar trap stuff --

tar:Callback("stacked", function(spell) -- needs testing
  if not player.combat then return end
  if not player.hasTalent(gifted.TAR_TRAP_TALENT) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end




  awful.friends.loop(function(friend)
    if not friend.exists then return end

    local total, melee, ranged, cooldowns = friend.v2attackers()
    if melee >= 2 and friend.hp <= 85 then
      if awful.enemies.around(friend, 8) >= 2 then
        -- Logic for when conditions are met
      end
    end
  end)

  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if enemy.bcc or enemy.cc then return end
    if not hunter.trapTarget.exists then return end
    if hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691) then return end
    if enemy.isUnit(hunter.trapTarget) then return end
    if enemy.class2 == "DRUID" and enemy.spec == "Feral" then return end
    if enemy.role ~= "Melee" then return end
    if player.distanceTo(enemy) <= 10 then
      local x, y, z = enemy.predictPosition(0.5)
      if spell:AoECast(x, y, z) then
        awful.alert("Tar Trap " .. enemy.classString .. " - STACKED MELEES", spell.id)
      end
    end
  end)
end)

tar:Callback("bigdmg",function(spell)
  if awful.prep then return end
  if target.exists and target.hp <= 20 then return end
  if spell.cd - awful.gcdRemains > 0 then return end

  if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end


  local lowest = gifted.lowest(awful.fgroup)



  awful.enemies.loop(function(enemy)

    if hunter.trapTarget.exists and hunter.trapTarget.enemy and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end
    if enemy.isUnit(hunter.trapTarget) then return end

    if not enemy.exists 
    or not enemy.los 
    or not enemy.isPlayer then 
      return 
    end
      
    if enemy.immuneSlows 
    or enemy.distanceLiteral > 12
    or enemy.ccRemains > 1.5 
    or enemy.rootRemains > 1
    or enemy.role ~= "Melee"
    or enemy.class2 == "DRUID" then 
      return 
    end

    if lowest <= 80 + bin(enemy.buffsFrom(BigDamageBuffs)) * 57 + bin(not healer.exists or not healer.los or healer.cc) * 30 then
      local gz = awful.GroundZ
      local x, y, z = gz(enemy.predictPosition(0.35))
      if not x then return end
      if spell:AoECast(x,y,z) then
        return awful.alert("|cFFf7f25c[Peel]: |rTar Trap! |r [" .. enemy.classString .. "]", spell.id)
      end
    end

  end)	

end)	

tar:Callback("badpostion", function(spell)
  if awful.prep then return end
  if spell.cd - awful.gcdRemains > 0 then return end
  if enemyHealer.class2 == "DRUID" then return end
  if not enemyHealer.los then return end
  if enemyHealer.rootRemains > 1 then return end

  if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end


  awful.enemies.loop(function(enemy)
    if not hunter.trapTarget.exists then return end
    if hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691) then return end
  end)

  if target.enemy 
  and enemyHealer.exists 
  and not enemyHealer.isUnit(target)
  and (not enemyHealer.losOf(target) or enemyHealer.distanceTo(target) > 40)
  and not enemyHealer.cc then
    if enemyHealer.bcc then return end

    local gz = awful.GroundZ
    local x, y, z = gz(enemyHealer.predictPosition(0.5))
    if not x then return end
    if spell:AoECast(x,y,z) then
      awful.alert("|cFFf7f25c Tar Trap " .. (enemyHealer.classString or "") .. " [Bad Position] ", spell.id)
    end

  end
end)

tar:Callback("tyrant", function(spell)
  if awful.prep then return end
  if target.exists and target.hp <= 20 then return end
  if spell.cd - awful.gcdRemains > 0 then return end

  -- local TotalPets = awful.enemyPets.around(player, 25)
  -- if TotalPets > 3 then print(">3") end

  awful.enemies.loop(function(enemy)
    if not hunter.trapTarget.exists then return end
    if hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691) then return end
    if enemy.isUnit(hunter.trapTarget) then return end
  end)


  awful.tyrants.loop(function(tyrant)

    if tyrant.ccRemains > 1.5
    or tyrant.distanceLiteral > 12 then 
      return 
    end

    local gz = awful.GroundZ
    local x, y, z = gz(tyrant.predictPosition(0.35))
    if not x then return end
    if spell:AoECast(x,y,z) then
      return awful.alert("Tar Trap |cFFf7f25c[Tyrant]", spell.id)
    end

  end)

end)


tar:Callback("BM Pets", function(spell, unit)
  if awful.prep then return end
  if target.exists and target.hp <= 30 then return end
  if spell.cd - awful.gcdRemains > 0 then return end

  if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end


  awful.enemies.loop(function(enemy)
    if not hunter.trapTarget.exists then return end
    if hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691) then return end
    if enemy.isUnit(hunter.trapTarget) then return end
  end)


  awful.pets.loop(function(pet)
    if not pet.enemy then return end
    if pet.distance > spell.range then return end
    if not pet.los then return end

    local dontUseIt = pet.immuneSlow or pet.slowed or pet.rooted or pet.ccRemains > 1.5 or pet.distanceLiteral > 10
    if dontUseIt then return end

    local gz = awful.GroundZ
    local x, y, z = gz(pet.predictPosition(0.35))
    if not x then return end

    if pet.buff(186254)
    and pet.buffRemains(186254) > 4
    and player.combat then
      if spell:AoECast(x,y,z) then 
        alert("|cFFf7f25cTar Trap " ..  colors.pink ..(pet.name or "") .. "", spell.id)
      end
    end   
  end) 

end)




-- end tar trap stuff --

-- master's call stuff --

mastersCall:Callback("rootbeam", function(spell)
  if not player.combat then return end
  if not spell.known then return end
  if not pet.exists then return end
  if not spell:Castable() then return end

  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if not enemy.player then return end
    if not (enemy.class2 == "DRUID" and enemy.spec == "Balance") then return end
    if not awful.fighting(102, true) then return end
  end)

  if not healer.exists then return end
  if not (healer.debuffUptime(gifted.SOLAR_BEAM_DEBUFF_ID) > 0.6 + awful.buffer) then return end
  if not (healer.debuffUptime(gifted.MASS_ENTANGLEMENT_DEBUFF_ID) > 0.6 + awful.buffer) then return end

  if spell:Castable(healer) then
    if spell:Cast(healer) then
      alert("Master's Call on " .. healer.classString .. " - ROOT + BEAM", spell.id)
    end
  end
end)


mastersCall:Callback("player", function(spell)
  if not player.combat then return end
  if not spell.known then return end
  if not pet.exists then return end
  if not spell:Castable() then return end
  if healer.exists then return end

  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if not enemy.player then return end
    if (enemy.class2 == "DRUID" and enemy.spec == "Balance" and healer.exists) then return end
    if awful.fighting(102, true) then return end
    if (enemy.class2 == "HUNTER" and healer.exists) then return end
  end)
  local total, melee, ranged, cooldowns = player.v2attackers()

  if total >= 1 and cooldowns >= 1 then
    if player.rooted then
      if spell:Cast(player) then
        alert("Master's Call on " .. player.classString .. " - ROOTED", spell.id)
      end
    end
  end

  if melee >= 1 and player.slowed and player.hp <= 70 then
    local meleeInRange = false
    awful.enemies.loop(function(enemy)
      if enemy.exists and enemy.meleeRangeOf(player) then
        meleeInRange = true
      end
    end)
    if meleeInRange then
      if spell:Cast(player) then
        alert("Master's Call on " .. player.classString .. " - SLOWED", spell.id)
      end
    end
  end
end)

mastersCall:Callback("harpoon", function(spell)
  if not player.combat then return end
  if not spell.known then return end
  if not pet.exists then return end
  if not healer.exists then return end
  if not spell:Castable() then return end

  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if not enemy.player then return end
    if not awful.fighting(255, true) then return end
    if enemy.cooldown(187650) > 3 then return end
  end)

  if (healer.debuffUptime(gifted.HARPOON_DEBUFF_ID) >= 0.5 + awful.buffer) then
    if spell:Castable(healer) then
      if spell:Cast(healer) then
        alert("Master's Call on " .. healer.classString .. " - HARPOON", spell.id)
      end
    end
  end
end)
-- master's call stuff --


-- start kick stuff --

-- Callback for damage kicks
counterShot:Callback("damage", function(spell)
  if player.buff(gifted.GROUNDING_TOTEM_ID) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if settings.onlyKickCC then return end

  gifted.sortedEnemies.loop(function(enemy)
    if gifted.KickCheckCasting(enemy, spell) then
      if not gifted.damageKickList[enemy.castID] then return end
      return spell:Cast(enemy)
    end

    if gifted.KickCheckChanneling(enemy, spell) then
      if not gifted.damageKickList[enemy.channelID] then return end
      return spell:Cast(enemy)
    end
  end)
end)

-- Callback for cc kicks
counterShot:Callback("cc", function(spell)
  if player.buff(gifted.GROUNDING_TOTEM_ID) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  gifted.sortedEnemies.loop(function(enemy)
    if gifted.KickCheckCasting(enemy, spell) then
      if not gifted.ccKickList[enemy.castID] then return end
      return spell:Cast(enemy)
    end

    if gifted.KickCheckChanneling(enemy, spell) then
      if not gifted.ccKickList[enemy.channelID] then return end
      return spell:Cast(enemy)
    end
  end)
end)

counterShot:Callback("healer", function(spell)
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if settings.onlyKickCC then return end

  if gifted.CheckHealerLocked() then return end -- if enemy is healer and locked, dont lock
  if gifted.sortedEnemies[1] and gifted.sortedEnemies[1].hp > 50 then return end -- if no one below 50% dont kick heal


  if gifted.KickCheckCasting(enemyHealer, spell) then
      if not gifted.healKickList[enemyHealer.castID] then return end
      return spell:Cast(enemyHealer)
  end

  if gifted.KickCheckChanneling(enemyHealer, spell) then
      if not gifted.healKickList[enemyHealer.channelID] then return end
      return spell:Cast(enemyHealer)
  end
end)
-- end kick stuff --

-- start turtle stuff --

aspectOfTheTurtle:Callback("default", function(spell)
  if not player.combat then return end
  if not settings.autodef then return end
  if player.buff(264735) and player.hp >= 40 then return end
  if player.recentlyCast(109304, 2) and player.hp >= 40 then return end

  if exhilaration.cd < 1 then return end

  if survivalOfTheFittest.charges >= 1 then return end

  local threshold = 28 -- Initial value of the threshold

  local count, _, _, cds = player.v2attackers()  -- Extracts certain values from the player's attack information
  
  threshold = threshold + count * 1.5  -- Adds 1.6 times the 'count' value to the threshold
  threshold = threshold + cds * 1.5   -- Adds 1.6 times the 'cds' value to the threshold
  
  -- Modifies the threshold further based on additional conditions using a binary function 'bin()'
  threshold = threshold * (1 + bin(not healer.exists or healer.cc and healer.ccr > 2.5) * 0.8)
  
  threshold = threshold * settings.turtlesens  -- Multiplies the threshold by setting

  if player.used(survivalOfTheFittest.id, 3) and healer.exists and not healer.cc then return end
  if player.hpa <= threshold then
      if spell:Cast() then
        print("Turtle Threshold: " .. threshold)
          awful.alert("|cFFf7f25cAspect of the Turtle|r", spell.id)
          return
      end
  end
end)

-- end turtle stuff --

-- start roar of sacrifice stuff --
hunter.currentDangerousCasts = {}
hunter.holdingRoSAlert = false

local dangerDebuffs = {
  [167105]  = { min = 4, weight = 13 },      -- warbreaker
  [208086]  = { min = 4, weight = 13 },      -- smash
  [386276]  = { min = 6.5, weight = 15 },    -- bonedust brew
  [274838]  = { min = 4, weight = 7 },       -- frenzy 
  [274837]  = { min = 4, weight = 7 },       -- frenzy
  [363830]  = { min = 7.5, weight = 14 },    -- sickle
  [323673]  = { min = 3, weight = 7 },       -- games
  [375901]  = { min = 3, weight = 7 },       -- games
  [385408]  = { min = 7, weight = 8 },       -- sepsis
  [375939]  = { min = 7, weight = 8 },       -- sepsis2
  [79140]   = { min = 7, weight = 18 },      -- vendetta FIXME: ID FOR DF 360194
  [360194]   = { min = 7, weight = 16 },      -- Deathmark
  [206491]  = { min = 30, weight = 10 },     -- nemesis..?
  [376079]  = { weight = 11 },               -- spear of bastion 
}

local dangerousCasts = {
  -- mindgames
  [323673] = { weight = 17 }, 
  [375901] = { weight = 17 }, 
  -- Glacial Spike
  [199786] = { 
    weight = 12, 
    mod = function(obj, dest) 
      return 1 + bin(obj.castPct > 75) * 3 
    end 
  },
  -- chaos bolt / dark soul bolt (crits through ros sadge)
  -- [116858] = { 
  --   weight = 12, 
  --   mod = function(obj, dest) 
  --     return 1 + bin(obj.buff(113858)) * 3 
  --   end 
  -- },
  -- convoke (feral and boomert)
  [323764] = {
    weight = 16,
    mod = function(obj)
      return 1 + obj.channelRemains * 0.33
    end,
    dest = function(obj)
      if obj.melee then
        if obj.target.exists and obj.target.distanceTo(obj) < 7 then 
          return obj.target 
        else
          local _, _, around = awful.fullGroup.around(obj, 7.5)
          for _, friend in ipairs(around) do
            if obj.facing(friend) then
              return friend
            end
          end
        end
      else
        return obj.target
      end
    end
  },
  -- deathbolt
  [264106] = {
    weight = 12,
    mod = function(obj)
      -- rapid contagion 33% increase, but they're probably tryna do big dam
      -- dark soul is just haste increase but they probably used phantom/darkglare/all dots for this deathbolt..
      return 1 + bin(obj.buff(344566)) * 0.66 + bin(obj.buff(113860)) * 0.88
    end
  },
  -- rapid fire
  [257044] = {
    weight = 8,
    mod = function(obj)
      -- double tap rapid fire full channel biggg scary
      return (1 + bin(obj.buff(260402)) * 2) / max(0.1, 2 - obj.channelRemains)
    end
  },
  -- aimed shot
  [19434] = {
    weight = 9,
    mod = function(obj)
      -- double tap aimed shot essentially 2x dmg.. buuut trading cds and crits are scary etc etc
      return 1 + bin(obj.buff(260402)) * 2
    end
  },
  -- Evoker Disintegrate
  [356995] = {
    weight = 9,
    mod = function(obj)
      return 1 + obj.channelRemains * 0.33
    end
  },
}

local function dangerousCastsScan()
  hunter.currentDangerousCasts = {}
  for i=1,#awful.enemies do
    local enemy = awful.enemies[i]
    local cast = (enemy.castID or enemy.channelID)
    --if enemy.distance > 90 then return end
    if cast then
      local info = dangerousCasts[cast]
      if info then
        local type = enemy.castID and "cast" or "channel"
        if type ~= "cast" or enemy.castRemains <= awful.buffer then
          local mod = info.mod and info.mod(enemy) or 1
          local dest = info.dest and info.dest(enemy)
          local weight = info.weight * mod
          tinsert(hunter.currentDangerousCasts, {
            source = enemy,
            dest = dest or enemy.castTarget,
            weight = weight
          })
        end
      end
    end
  end
end

local ros = NS(53480, { 
  ignoreFacing = true,
  ignoreGCD = true,
  heal = true,
  pet = true
})

roarOfSacrifice:CastCallback(function(spell)
  hunter.holdingRoSAlert = false
end)

function roarOfSacrifice:combustTarget(unit)

  if not hunter.holdingRoSAlert then 
    alert({msg = "Holding |cFFfcd86aROS|r for |cFFff8336Combustion", texture = self.id, duration = 5})
    hunter.holdingRoSAlert = true
  end

  -- highly weighted by whether or not the unit is the one combust is being committed on
  local weight = 18
  if state.fireMage.buff(190319) then
    weight = weight + bin(recentlyAttackedByFireMage(unit)) * 32
    weight = weight + bin(insideEnemyMeteor(unit)) * 26
    weight = weight + bin(state.fireMage.target.isUnit(unit)) * 32
    weight = weight + bin(unit.stunned) * 18
  elseif state.fireMage.cooldown(190319) > 95 then
    return self:threshold(unit, true)
  end

  return weight

end

function roarOfSacrifice:threshold(unit, bypass)
  
  -- fire mage exists? only ros on combust.
  if not bypass and state.fireMage then return roarOfSacrifice:combustTarget(unit) end

  -- modifiers by units on the unit
  local total, _, _, cds = unit.v2attackers()

  -- the hunt flying
  local theHuntWeight = 0
  local huntEvent = events.huntCast
  if huntEvent then
    local event = huntEvent
    local source, dest, happened = event.source, event.dest, event.time
    local time = awful.time
    if time - happened <= 2.25
    and source.exists 
    and source.enemy
    and source.speed > 45
    and dest.isUnit(unit)
    and source.distanceTo(dest) > 8 then
      theHuntWeight = theHuntWeight + 50
    end
  end

  -- debuffs that mean big dam' be comin'
  local debuffWeights = 0
  local hasDebuffs = unit.debuffFrom(dangerDebuffs)
  if hasDebuffs then 
    for _, id in ipairs(hasDebuffs) do 
      debuffWeights = debuffWeights + dangerDebuffs[id].weight 
    end 
  end

  -- dangerous casts or channels currently happening
  local dangerousCastsWeight = 0
  for _, cast in ipairs(hunter.currentDangerousCasts) do 
    if cast.dest.isUnit(unit) then
      dangerousCastsWeight = dangerousCastsWeight + cast.weight
    end
  end

  -- bit 'o weight for them committing a stun to their target
  local stunWeight = unit.stunned and 10 or 0

  local threshold = 28 + debuffWeights / 2 + dangerousCastsWeight

  threshold = threshold + total * (10 + debuffWeights / 2.5 + stunWeight / 2 + dangerousCastsWeight / 2.5)
  threshold = threshold + cds * (17 + debuffWeights + stunWeight + dangerousCastsWeight / 2)

  -- slight multiplicative mod for no heals, mitigation more important
  threshold = threshold * 1 + bin(not healer.exists or not healer.los or healer.ccr > 2) * 0.1

  return threshold

end

roarOfSacrifice:Callback("threshold", function(spell, info)

  if not player.hasTalent(spell.id) then return end

  if player.lastCast == 388035 then return end
  if player.recentlyCast(388035, 1) then return end
  
  -- Lone wolf check
  if player.buff(164273) then return end

  -- Scan for any dangerous casts
  dangerousCastsScan()

  local petDead = pet.dead
  local petInCC = pet.cc
  local petRooted = pet.rooted
  local petSlowed = pet.slowed

  -- RoS any member who meets complex weighted HP threshold
  awful.fullGroup.sort(function(x, y) return x.hp < y.hp end)
  awful.fgroup.loop(function(member)
    if not member.dead and member.dist < 50 and member.hp <= roarOfSacrifice:threshold(member) then
      -- Check if RoS is usable
      if not spell:Castable(member) then
        local petOutOfRange = (petRooted and not pet.meleeRangeOf(member)) or pet.distanceTo(member) > 30
        -- Get pet to unit
        if petInCC then
          if petInCC or (petRooted and player.spec == "Beast Mastery" and beastialWrath.cd - awful.gcdRemains == 0) then
            if not beastialWrath.known then return end
            if beastialWrath:Cast({ignoreControl = true}) then 
              alert("Bestial Wrath to |cFFfcd86aROS|r, |cFFfa9f28( Pet in CC )", beastialWrath.id) 
            end
          else
            shortalert("Can't |cFFfcd86aROS|r, |cFFfa9f28( Pet is in CC )", spell.id)
          end
        elseif petOutOfRange then
          if petSlowed then
            dash:Cast()
          elseif petRooted then
            if mastersCall.cd == 0 then 
              local isFightingBoomkin = awful.fighting(102, true)
              if player.buff(264656) and not isFightingBoomkin then 
                mastersCall:Cast(member)
              end
            else
              shortalert("|cFFfcd86aROS|r Alert: |cFFfa9f28( Pet Stuck Out of Range )", spell.id)
            end
          end
          if hunter.movePetToUnit(member) then
            hunter.controllingPet = awful.time
            hunter.petControlImportance = 5
          end
        end
      end

      -- Get player to unit.. out of LoS or > 40y cannot RoS
      if not member.los then
        shortalert("Can't |cFFfcd86aROS|r, |cFFfa9f28Out of LoS", spell.id)
      elseif member.distance > 40 then
        shortalert("Can't |cFFfcd86aROS|r " .. member.classString .. " |cFFfa9f28( Out of Range )", spell.id)
      end

      -- Turtle
      if member.buff(186265) then return end  
      -- Bear wall
      if member.buff(388035) and member.hpa > 30 then return end
      -- Pet wall fittest
      if member.buff(264735) then return end
      
      if member.hp > roarOfSacrifice:threshold(member) then return end  

      if member.hp <= roarOfSacrifice:threshold(member) then
        return spell:Cast(member) and alert("RoS " .. member.classString, spell.id)
      end

    end
  end)
end)

roarOfSacrifice:Callback("party", function(spell)
  if not player.combat then return end
  if not settings.autodef then return end
  if not pet.exists then return end
  if pet.dead then return end
  if not player.hasTalent(53480) then return end

  if player.lastCast == 388035 then return end
  if player.recentlyCast(388035, 1) then return end

  -- Lone wolf check
  if player.buff(164273) then return end

  local petDead = pet.dead
  local petInCC = pet.cc
  local petRooted = pet.rooted
  local petSlowed = pet.slowed

  awful.fgroup.loop(function(friend)

    -- Turtle
    if friend.buff(186265) then return end  
    -- Bear wall
    if friend.buff(388035) and friend.hpa > 30 then return end
    -- Pet wall fittest
    if friend.buff(264735) then return end
    -- Dont Defensive List 
    
    if petDead then return end
      if not friend.exists or not spell:Castable(friend) then return end
      if not pet.losOf(friend) then return end

      local petOutOfRange = (petRooted and not pet.meleeRangeOf(friend)) or pet.distanceTo(friend) > 30

      -- Check if we need to Roar of Sacrifice
      local total, melee, ranged, cooldowns = friend.v2attackers()
      local needRoS = (total >= 2 and cooldowns >= 1 and healer.exists and healer.cc and healer.ccr >= 2 and friend.hp <= 90) or
                      (total >= 1 and cooldowns >= 1 and friend.hp <= 70) or
                      (total >= 1 and friend.hp <= 65)

      if needRoS then
        -- Get pet to unit if needed
        if petInCC then
          if petInCC or (petRooted and player.spec == "Beast Mastery" and beastialWrath.cd - awful.gcdRemains == 0) then
            if not beastialWrath.known then return end
            if beastialWrath:Cast({ignoreControl = true}) then 
              alert("Bestial Wrath to |cFFfcd86aROS|r, |cFFfa9f28( Pet in CC )", beastialWrath.id) 
            end
          else
            shortalert("Can't |cFFfcd86aROS|r, |cFFfa9f28( Pet is in CC )", spell.id)
          end
        elseif petOutOfRange then
          if petSlowed then
            dash:Cast()
          elseif petRooted then
            if mastersCall.cd == 0 then 
              local isFightingBoomkin = awful.fighting(102, true)
              if player.buff(264656) and not isFightingBoomkin then 
                mastersCall:Cast(friend)
              end
            else
              shortalert("|cFFfcd86aROS|r Alert: |cFFfa9f28( Pet Stuck Out of Range )", spell.id)
            end
          end
          if hunter.movePetToUnit(friend) then
            hunter.controllingPet = awful.time
            hunter.petControlImportance = 5
          end
        end

        -- Attempt to cast Roar of Sacrifice
        if spell:Cast(friend) then
          awful.alert("RoS " .. friend.name, spell.id)
        end
      end

      -- Get player to unit.. out of LoS or > 40y cannot RoS
      if not friend.los then
        shortalert("Can't |cFFfcd86aROS|r, |cFFfa9f28Out of LoS", spell.id)
      elseif friend.distance > 40 then
        shortalert("Can't |cFFfcd86aROS|r " .. friend.classString .. " |cFFfa9f28( Out of Range )", spell.id)
      end
  end)
end)

-- end roar of sacrifice stuff --

-- start fortitude of the bear stuff --

fortitude:Callback("default", function(spell)
  if not player.combat then return end
  if not settings.autodef then return end
  if not pet.exists then return end
  if pet.dead then return end
  if not spell:Castable() then return end
  if not spell.known then return end

  if roarOfSacrifice.cd < 1 then return end

  if player.lastCast == 53480 then return end
  if player.recentlyCast(53480, 1) then return end

  local total, melee, ranged, cooldowns = player.v2attackers()


  if total >= 1 and player.hp <= 55 then
    spell:Cast()
  elseif total >= 1 and cooldowns >= 1 and player.hp <= 65 then
    spell:Cast()
  elseif total >= 2 and cooldowns >= 1 and healer.exists and healer.cc and healer.ccr >= 2 and player.hp <= 85 then
    spell:Cast()
  end
end)

-- end fortitude of the bear stuff --

-- start survival of the fittest stuff --


survivalOfTheFittest:Callback("default", function(spell)
  if not player.combat then return end
  if not settings.autodef then return end
  if player.buff(264735) then return end

  if roarOfSacrifice.cd < 1 then return end

  if player.lastCast == 264735 then return end
  if player.recentlyCast(264735, 3) then return end

  if player.lastCast == 53480 then return end
  if player.recentlyCast(53480, 3) then return end

  if player.lastCast == 388035 then return end
  if player.recentlyCast(388035, 1) then return end

  if player.buffFrom(DontDefensive) then return end

  local total, melee, ranged, cooldowns = player.v2attackers()

  if total >= 1 and player.hp <= 50 then
    if spell:Castable() then
      if spell:Cast() then
        awful.alert("Survival of the Fittest", spell.id)
      end
    end
  elseif total >= 1 and cooldowns >= 1 and healer.exists and healer.cc and healer.ccr >= 2 and player.hp <= 65 then
    if spell:Castable() then
      if spell:Cast() then
        awful.alert("Survival of the Fittest ", spell.id)
      end
    end
  end
end)

-- end survival of the fittest stuff --


-- start exhilaration stuff --

exhilaration:Callback("default", function(spell)
  if not player.combat then return end
  if not settings.autodef then return end
  if player.buff(388035) and player.buff(53480) and player.buff(264735) then return end
  if player.buff(186265) then return end

  local total, melee, ranged, cooldowns = player.v2attackers()


  if player.hp < settings.autoexhilarate and total > 0 then
    if spell:Castable() then
      if spell:Cast() then
        awful.alert("Exhilaration")
      end
    end
  end
end)


-- end exhilaration stuff --




-- pet stuff --

local callpet = {

  NS(883), -- call pet by stable index
  NS(83242), 
  NS(83243),
  NS(83244),
  NS(83245),
}

local modes = {
  PET_MODE_PASSIVE = "passive",
  PET_MODE_ASSIST = "assist",
  PET_MODE_DEFENSIVEASSIST = "defensive"
}
local function updatePetModes()
  local passiveIndex, growlIndex, dashIndex, spiritMendIndex
  local growlActive, dashActive, spiritMendActive
  local mode
  for i=1,10 do
    local name, id, _, token, _, active  = GetPetActionInfo(i)
    if id == 132270 then  -- Growl ID
      growlIndex = i
      growlActive = active
    elseif id == 132120 then  -- Dash ID
      dashIndex = i
      dashActive = active
    elseif id == 237586 then  -- Spirit Mend ID
      spiritMendIndex = i
      spiritMendActive = active
    else
      local alias = modes[name]
      if alias then
        if alias == "passive" then
          passiveIndex = i
        end
        if token then
          mode = alias
        end
      end
    end
  end

  if passiveIndex and mode ~= "passive" then
    -- Switch to Passive Mode
    PetPassiveMode()
    alert("Swapping pet to Passive mode", PET_PASSIVE_TEXTURE)
  end
 
  if growlIndex and growlActive then
    -- Toggle Growl Autocast
    TogglePetAutocast(growlIndex)
    alert("Disabled Auto Growl", 2649)
  end

  -- Disable Dash Autocast if it's currently active
  if dashIndex and dashActive then
    TogglePetAutocast(dashIndex)
    alert("Disabled Auto Dash", 61684)
  end

  if spiritMendIndex and spiritMendActive then
    TogglePetAutocast(spiritMendIndex)
    alert("Disabled Auto Spirit Mend", 90361)
  end
end

C_Timer.After(2, updatePetModes)

  -- start reset stuff --
  local res, mend = NS(982), NS(136, { heal = true, ignoreFacing = true })

  hunter.reset = function()
    local feignReset = NS(5384, { mustBeGrounded = true })
    local CamouflageReset = NS(199483)
    if CamouflageReset.cd > 0 or feignReset.cd > 0 then return end

    if awful.MacrosQueued['reset'] then
      attack:stop()
      attack:stop()

      if pet.exists then
        hunter:PetFollow()
        hunter:PetFollow()
        PetPassiveMode()
        PetPassiveMode()
      end

      if feignReset:Cast({stopMoving = true}) then
        alert("Reset ..", feignReset.id)
      end

      if not player.combat then 
        CamouflageReset:Cast()
      end

      if player.buff(CamouflageReset.id) and pet.dead then
        if res() then
          awful.alert(colors.hunter .. "Stop moving trying to ress pet..", res.id, true)
        end
      end
    end
  end

  -- end reset stuff --


hunter.petState = {
  mode = "passive",
}


local mendMePls = {
  [198909] = { uptime = 0.25, min = 2 },         -- monk khobaar
  [8122] = { uptime = 0.25, min = 2 },         -- Psychic Scream
  [112] = { uptime = 0.25, min = 2 }, -- Frost Nova
  [187650] = { uptime = 0.25, min = 2 }, -- Freezing Trap
  [3355] = { uptime = 0.25, min = 2 }, -- Freezing Trap
  [853] = { uptime = 0.25, min = 2 }, -- Hammer of Justice
  [179057] = { uptime = 0.25, min = 2 }, -- dh choas nova
  [20066] = { uptime = 0.15, min = 2 }, -- Repentance
  [77787] = { uptime = 0.15, min = 2 }, -- Hammer of Justice
  ------------- Sheeeps
  [118] = { uptime = 0.25, min = 2 },
  [161355] = { uptime = 0.25, min = 2 },
  [161354] = { uptime = 0.25, min = 2 },
  [161353] = { uptime = 0.25, min = 2 },
  [126819] = { uptime = 0.25, min = 2 },
  [61780] = { uptime = 0.25, min = 2 },
  [161372] = { uptime = 0.25, min = 2 },
  [61721] = { uptime = 0.25, min = 2 },
  [61305] = { uptime = 0.25, min = 2 },
  [28272] = { uptime = 0.25, min = 2 },
  [28271] = { uptime = 0.25, min = 2 },
  [277792] = { uptime = 0.25, min = 2 },
  [277787] = { uptime = 0.25, min = 2 },
  [391622] = { uptime = 0.25, min = 2 },
  ---------------------
  [360806] = { uptime = 0.25, min = 2 }, --- sleep walk
  ------------Fears 
  [5782] = { uptime = 0.25, min = 2 },
  [65809] = { uptime = 0.25, min = 2 },
  [342914] = { uptime = 0.25, min = 2 },
  [251419] = { uptime = 0.25, min = 2 },
  [118699] = { uptime = 0.25, min = 2 },
  [30530] = { uptime = 0.25, min = 2 },
  [221424] = { uptime = 0.25, min = 2 },
  [41150] = { uptime = 0.25, min = 2 },
  ------------------------
  [82691] = { uptime = 0.25, min = 2 },        --- ring of frost
  [64044] = { uptime = 0.25, min = 2 },         -- Psychic Horror (Stun)
  [105421] = { uptime = 0.25, min = 2 },         -- Blinding Light
  [6358] = { uptime = 0.25, min = 2 },         -- Seduction (Succubus)
  --------------- rooots 
  [339] = { uptime = 0.25, min = 2 },         ----entangling roots
  [235963] = { uptime = 0.25, min = 2 }, -- Entangling Roots
  [102359] = { uptime = 0.25, min = 2 }, -- Mass Entanglement
  [117526] = { uptime = 0.25, min = 2 }, -- Binding Shot
  [122] = { uptime = 0.25, min = 2 }, -- Frost Nova 
  [33395] = { uptime = 0.25, min = 2 }, -- Freeze
  [64695] = { uptime = 0.25, min = 2 }, -- Earthgrab
}

res:Callback(function(spell)
  if not pet.dead then return end
  if not pet.exists then return end
  return spell:Cast() and alert("Revive Pet", spell.id)
end)

mend:Callback(function(spell)
  if pet.buff(spell.id) then return end
  if player.hasTalent(343242) and pet.debuffFrom({30108, 316099}) then return end
  if not pet.los then return end
  if not pet.exists then return end

  if hunter.trapTarget and hunter.trapTarget.exists and hunter.trapTarget.enemy and (hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(213691)) then return end

  if not hunter.importantPause 
  and pet.hp <= 85 - bin(hunter.unimportantPause) * 25 - bin(healer.exists and not healer.cc) * 25 then

    if spell:Cast(pet) then
      return
    end

  else

    if player.hasTalent(343242) 
    and pet.debuffFrom(mendMePls) then
      if spell:Cast(pet) then
        return
      end
    end

  end
end)


function hunter:PetFollow()
  if not self.followCommand then self.followCommand = awful.time end
  if awful.time - self.followCommand < 0.1 then return end

  awful.call("PetFollow")
  self.followCommand = awful.time
end

function hunter:PetAttack()
  if not target.enemy then return end
  if awful.MacrosQueued['stun focus'] then return end
  if player.buff(199483) then return end
  if not self.attackCommand then self.attackCommand = awful.time end
  if awful.time - self.attackCommand < 0.1 then return end
    
  if Unlocker.type == "daemonic" then 
    awful.call("PetAttack")
  else
    if target.bcc then
      awful.call("PetStopAttack") --PetStopAttack()
    end
  end
  self.attackCommand = awful.time
end

function hunter:PetControl()
  if player.used(2641, 5) then return end
  local petIndex = tonumber(settings.CallPetMode:match("%d+"))
  -- call / res pet
  if settings.autosummonpet and not pet.exists and not pet.dead then
    if not hunter.call_pet_attempted then
      if petIndex
      and player.castID ~= res.id 
      and callpet[petIndex]:Cast() then
        alert("Calling pet ", callpet[petIndex].id)
        hunter.call_pet_attempted = true
      end
    elseif player.castID ~= res.id then
      hunter.res_pet_attempted = true
      -- try to res pet
      res()
    end
  else
    hunter.call_pet_attempted = false
    if not hunter.res_pet_attempted and pet.dead then
      hunter.res_pet_attempted = true
      res()
    else 
      -- mend pet
      mend()
    end

    if not hunter.petState.externalControl 
    or awful.time - hunter.petState.externalControl > awful.tickRate * 3 then
      --! PROTECC !--
      --if target.exists then
        -- camo
        if player.buff(199483)
        -- bcc
        or target.bcc
        --pet back macro 
        or awful.MacrosQueued['pet back'] 
        or awful.MacrosQueued['reset']
        or pet.distance > 25 and spiritMend:Castable(player) and spiritMend.current
        -- thorns
        or target.exists and target.buffRemains(305497) > 2 and pet.hp < 50 then
          hunter:PetFollow()
          alert("Moving Pets back ..", callpet[petIndex].id) 
        else
          --! ATTACC !--
            hunter:PetAttack()
          end
        end
      --end
    end
  end

function hunter:PetEatTrap()
  if not settings.peteattrap then return end
  
  if not healer.exists then return end  

  local enemyhunter = awful.enemies.find(function(obj) return obj.class2 == "HUNTER" end)

  if awful.arena 
  and enemyhunter 
  and enemyhunter.cooldown(187650) < 5 then

    local WillFollowTrap = healer.stunned or healer.debuff(213691)
    if not WillFollowTrap then return end

    local x,y,z = healer.position()
    local petDistance = pet.distanceToLiteral(x,y,z)

    if pet.distanceToLiteral(x,y,z) > 10 then

    if dash:Cast() then awful.alert(colors.cyan .. "Dash (Eat Trap) [" .. healer.classString .. "]", dash.id) end

    if hunter.movePetToPosition(x,y,z) then
      return awful.alert(colors.cyan .. "Move Pet (Eat Trap) [" .. healer.classString .. "]")
      end
    end
  end
end

function hunter:AntiPetTaunt()
  local tx,ty,tz = target.position()
  local px,py,pz = player.position()

  --Taunts
  if player.hasTalent(203340) then return end
  if not pet.debuffFrom({62124, 116189, 6795}) then return end
  if trap.cd - awful.gcdRemains > 1 then return end

  if target.exists 
  and target.enemy
  and target.los
  and pet.distanceToLiteral(tx,ty,tz) < 53 then 
    return hunter.movePetToPosition(tx,ty,tz) and awful.alert(colors.orange .. "Moving pets out [Taunted]")
  else
    return hunter.movePetToPosition(px,py,pz) and awful.alert(colors.orange .. "Moving pets out [Taunted]")
  end
end

dash:Callback("rooted", function(spell)
  if player.buff(199483) then return end
  if not target.exists then return end
  if not target.enemy then return end
  if target.dead then return end
  if pet.distanceToLiteral(target) < 39 then return end

  return spell:Cast()

end)
-- end pet stuff --


-- chimaeral sting stuff --

chimaeralSting:Callback("healer", function(spell)
  if not player.combat then return end
  if not player.hasTalent(gifted.CHIMAERAL_STING_TALENT) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if trap.cd <= 6 then return end

  if not player.buff(19574) or not player.buff(20572) or not player.buff(359844) then return end

  if not enemyHealer.exists then return end
  if (enemyHealer.bccr >= 0.5 + awful.buffer) or (enemyHealer.ccr >= 2.5 + awful.buffer) then return end
  if enemyHealer.silenceDR ~= 1 then return end
  if enemyHealer.debuff(gifted.FREEZING_TRAP_DEBUFF_ID) then return end
  if enemyHealer.debuff(gifted.DIAMOND_ICE_TRAP_DEBUFF_ID) then return end
  if enemyHealer.debuff(gifted.CHIMAERAL_STING_SCORPID_DEBUFF_ID) then return end
  if enemyHealer.debuff(gifted.CHIMAERAL_STING_SPIDER_DEBUFF_ID) then return end
  if enemyHealer.debuff(gifted.CHIMAERAL_STING_VIPER_DEBUFF_ID) then return end
  if enemyHealer.immune then return end
  if enemyHealer.immuneMagic then return end

  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if enemy.hp > 80 then return end
    if spell:Castable(enemyHealer) then
      if spell:Cast(enemyHealer, { face = true }) then
        alert("Chimaeral Sting on " .. enemyHealer.classString .. " - HEALER", spell.id)
      end
    end
  end)
end)


chimaeralSting:Callback("healerlowhp", function(spell)
  if not player.combat then return end
  if not player.hasTalent(gifted.CHIMAERAL_STING_TALENT) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  
  if trap.cd <= 6 then return end

  if not enemyHealer.exists then return end
  if (enemyHealer.bccr >= 0.5 + awful.buffer) or (enemyHealer.ccr >= 2.5 + awful.buffer) then return end
  if enemyHealer.silenceDR < 0.5 then return end
  if enemyHealer.debuff(gifted.FREEZING_TRAP_DEBUFF_ID) then return end
  if enemyHealer.debuff(gifted.DIAMOND_ICE_TRAP_DEBUFF_ID) then return end
  if enemyHealer.debuff(gifted.CHIMAERAL_STING_SCORPID_DEBUFF_ID) then return end
  if enemyHealer.debuff(gifted.CHIMAERAL_STING_SPIDER_DEBUFF_ID) then return end
  if enemyHealer.debuff(gifted.CHIMAERAL_STING_VIPER_DEBUFF_ID) then return end
  if enemyHealer.immune then return end
  if enemyHealer.immuneMagic then return end

  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if enemy.hp > 30 then return end
    if spell:Castable(enemyHealer) then
      if spell:Cast(enemyHealer, { face = true }) then
        alert("Chimaeral Sting on " .. enemyHealer.classString .. " - HEALER", spell.id)
      end
    end
  end)
end)

chimaeralSting:Callback("castersbursting", function(spell)
  if not player.combat then return end
  if not player.hasTalent(gifted.CHIMAERAL_STING_TALENT) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end


  awful.group.loop(function(friend)
    if not friend.exists then return end
    if friend.hp > 80 then return end
  end)

  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if not enemy.player then return end
    if not enemy.ranged then return end
    if enemy.debuff(gifted.CHIMAERAL_STING_SCORPID_DEBUFF_ID) then return end
    if enemy.debuff(gifted.CHIMAERAL_STING_SPIDER_DEBUFF_ID) then return end
    if enemy.debuff(gifted.CHIMAERAL_STING_VIPER_DEBUFF_ID) then return end
    if enemy.class2 == "HUNTER" then return end
    if enemy.immune then return end
    if enemy.immuneMagic then return end
      if enemy.cds then
        if spell:Castable(enemy) then
          if spell:Cast(enemy, { face = true }) then
            alert("Chimaeral Sting on " .. enemy.classString .. " - BURSTING", spell.id)
          end
        end
      end
  end)
end)
    

chimaeralSting:Callback("badpostion", function(spell)
  if spell.cd - awful.gcdRemains > 0 then return end
  if not player.hasTalent(gifted.CHIMAERAL_STING_TALENT) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if not enemyHealer.los then return end
  if enemyHealer.castID == 421453 or enemyHealer.channelID == 421453 then return end

  if trap.cd <= 6 then return end

  if hunter.trapTarget.exists then
    if settings.autoStun and (hunter.trapTarget.stunDR > 0.5 or hunter.trapTarget.stunDRRemains < 5) then return end
    if settings.autoBindingShot and (hunter.trapTarget.stunDR > 0.5 or hunter.trapTarget.stunDRRemains < 5) then return end
    if settings.MWTOGGLE and (hunter.trapTarget.incapacitateDR > 0.5 or hunter.trapTarget.incapacitateDRRemains < 5) then return end
    if hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691) then return end
  end

  if target.enemy 
  and enemyHealer.exists 
  and (not enemyHealer.losOf(target) or enemyHealer.distanceTo(target) > spell.range)
  and not enemyHealer.cc then
    if enemyHealer.bcc then return end
    if spell:Cast(enemyHealer, { face = true }) then
      alert("|cFFf7f25c Chimaeral Sting " .. (enemyHealer.classString or "") .. " [Bad Position] ", spell.id)
      return true
    end
  end
end)

chimaeralSting:Callback("lockout",function(spell)
  if spell.cd - awful.gcdRemains > 0 then return end
  if not player.hasTalent(gifted.CHIMAERAL_STING_TALENT) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if trap.cd <= 6 then return end

  local KickedHoly = enemyHealer.lockouts.holy and enemyHealer.lockouts.holy.remains >= 1
  local KickedNature = enemyHealer.lockouts.nature and enemyHealer.lockouts.nature.remains >= 1

  if enemyHealer.exists then 
    if enemyHealer.bcc then return end
    if not enemyHealer.los then return end
    if enemyHealer.dist > spell.range then return end
    if enemyHealer.castID == 421453 or enemyHealer.channelID == 421453 then return end

    if KickedHoly or KickedNature then
      if spell:Cast(enemyHealer, { face = true }) then
        alert("|cFFf7f25c Chimaeral Sting " .. (enemyHealer.classString or "") .. " ", spell.id)
      end
    end
  end
end)
--
-- end chimaeral sting stuff --

-- start scatter shot stuff --

scatterShot:Callback("big dam", function(spell)
  if not settings.scatterOthers then return end
  if settings.MWTOGGLE then return end
  if not player.hasTalent(gifted.SCATTER_SHOT_TALENT) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if not player.hasTalent(213691) then return end
  if spell.cd - awful.gcdRemains > 0 then return end

  if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end


  local lowest = gifted.lowest(awful.fgroup)
  local estimatedOffTarget = gifted.FindOffTarget()
  local estimatedKillTarget = gifted.FindKillTarget()


  awful.enemies.loop(function(enemy)
    if hunter.trapTarget.exists and enemy.isUnit(hunter.trapTarget) then return end
    if not enemy.exists then return end
    if not enemy.los then return end
    if enemy.dist > spell.range then return end
    if enemy.immunePhysicalEffects or enemy.immuneCC or enemy.immuneMagic or enemy.immune then return end
    if player.target.isUnit(enemy) then return end
    if enemy.ccr and enemy.ccr > 1 then return end
    if enemy.isUnit(estimatedKillTarget) then return end
    if enemy.v2attackers() > 0 then return end
    -- not into bladestorm
    if enemy.class2 == "WARRIOR" and enemy.buffFrom({46924, 227847}) then return end
    if player.casting or player.channeling then return end
    if not enemy.isPlayer then return end  
    if player.buff(186265) then return end
    if enemy.immuneCC then return end
    if enemy.disorientDR ~= 1 then return end
    if player.buff(199483) then return end
    if enemy.buffFrom({198589, 212800}) then return end
    if enemy.disarmed then return end

    if trap.cd <= 2 then return end
    
    -- dance 
    if enemy.class2 == "ROGUE"
    and enemy.buffRemains(185422) > 2.75 - bin(lowest < 85) * 1.5
    and spell:Cast(enemy, {face = true}) then
      alert("Scatter " .. colors.rogue .. "[Shadow Dance]", spell.id)
    end

    -- Combustion 
    if enemy.class2 == "MAGE"
    and enemy.buffRemains(190319) > 2.75 - bin(lowest < 85) * 1.5
    and spell:Cast(enemy, {face = true}) then
      alert("Scatter " .. colors.mage .. "[Combustion]", spell.id)
    end

    -- Glacial spike 
    if enemy.class2 == "MAGE"
    and enemy.castID == 199786
    and counterShot.cd - awful.gcdRemains > 0
    and enemy.castPct > 70
    and spell:Cast(enemy, {face = true}) then
      alert("Scatter " .. colors.mage .. "[Glacial Spike]", spell.id)
    end

    -- wings
    if enemy.class2 == "PALADIN"
    and enemy.role == "melee"
    and enemy.buff(31884)
    and spell:Cast(enemy, {face = true}) then
      alert("Scatter " .. colors.paladin .. "[Wings]", spell.id)
    end

    -- hunter shit
    if enemy.class2 == "HUNTER"
    and (not healer.exists or healer.cc)
    and (lowest < 75 
      + bin(not healer.exists or healer.cc) * 20
      + bin(enemy.cds) * 25)
    and spell:Cast(enemy, {face = true}) then
      return alert("Scatter " .. enemy.classString, spell.id)         
    end

    -- warrior shit
    if enemy.class2 == "WARRIOR"
    and (not healer.exists or healer.cc)
    and (lowest < 75 
      + bin(not healer.exists or healer.cc) * 20
      + bin(enemy.cds) * 25)
    and spell:Cast(enemy, {face = true}) then
      return alert("Scatter " .. enemy.classString, spell.id)         
    end

    --DK Pillar of Frost
    if enemy.buff(51271) 
    and enemy.dist > awful.latency / (5 - bin(player.moving) * 1)
    and not player.target.isUnit(enemy) then
      if spell.cd <= 0.25 then
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if spell:Cast(enemy, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Pillar of Frost", colors.dk) .. ")", spell.id)
        end
      end
    end   

    -- DK Unholy Assult
    if enemy.buff(207289) 
    and player.target.isUnit(enemy) then
      if spell.cd <= 0.25 then
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if spell:Cast(enemy, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Unholy Assault", colors.dk) .. ")", spell.id)
        end
      end
    end       

    -- Mage Combustion on player
    if enemy.buff(190319) then
      if spell.cd <= 0.25 then
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if spell:Cast(enemy, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Combustion", colors.mage) .. ")", spell.id)
        end
      end
    end
  
    -- Recklessness on player
    if enemy.buff(1719) 
    and not player.target.isUnit(enemy) then
      if spell.cd <= 0.25 then
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if spell:Cast(enemy, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Recklessness", colors.warrior) .. ")", spell.id)
        end
      end
    end              

    -- Avatar on player
    if enemy.buff(107574) 
    and not player.target.isUnit(enemy) then
      if spell.cd <= 0.25 then
        awful.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          awful.call("SpellStopCasting")
        end
        if spell:Cast(enemy, {face = true}) then
          return awful.alert("Scatter Shot (" .. colored("Avatar", colors.warrior) .. ")", spell.id)
        end
      end
    end 

    -- we just need a peel
    if enemy.isPlayer 
    and not enemy.immuneCC
    and not enemy.isHealer then
      if lowest < 60 + bin(enemy.cds) * 57 + bin(not healer.exists or healer.cc) * 30 then
        return spell:Cast(enemy, {face = true}) and alert("Scatter " .. enemy.classString, spell.id)
      end
    end
  end)
end)

scatterShot:Callback("covertraps", function(spell)
  if not settings.scatterOthers then return end
  if settings.MWTOGGLE then return end
  if not player.hasTalent(gifted.SCATTER_SHOT_TALENT) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if not player.hasTalent(213691) then return end
  if spell.cd - awful.gcdRemains > 0 then return end

  local estimatedOffTarget = gifted.FindOffTarget()
  local estimatedKillTarget = gifted.FindKillTarget()


  awful.enemies.loop(function(enemy)
    if hunter.trapTarget.exists and enemy.isUnit(hunter.trapTarget) then return end
    if not enemy.exists then return end
    if not enemy.los then return end
    if enemy.dist > spell.range then return end
    if enemy.immunePhysicalEffects or enemy.immuneCC or enemy.immuneMagic or enemy.immune then return end
    if player.target.isUnit(enemy) then return end
    if enemy.ccr and enemy.ccr > 2 then return end
    if not enemy.isPlayer then return end  
    if enemy.incapacitateDR < 0.5 then return end
    if enemy.isUnit(estimatedKillTarget) then return end

    -- Cover our trap from grounding
    if enemy.class2 == "SHAMAN"
    and enemyHealer.ccr > 1
    and enemy.cooldown(204336) <= 4
    and trap.cd <= 1
    and spell:Cast(enemy, {face = true}) then
      alert("Scatter " .. colors.shaman .. "[Grounding]", spell.id) 
    end

    -- Cover our trap from DH
    if enemy.class2 == "DEMONHUNTER"
    and enemyHealer.ccr > 1
    and trap.cd <= 1
    and spell:Cast(enemy, {face = true}) then
      alert("Scatter " .. colors.dh .. "[Reverse Magic]", spell.id) 
    end

    -- Cover our trap from MD
    if enemy.class2 == "PRIEST"
    and (enemy.castID == 341167 or enemy.castID == 32375)
    and enemy.debuff(3355, "player")
    and counterShot.cd > 0.8
    and spell:Cast(enemy, {face = true}) then
      alert("Scatter " .. colors.cyan .. "[Mass Dispel]", spell.id) 
    end

    -- Cover our trap from DK
    if enemy.class2 == "DEATHKNIGHT"
    and enemyHealer.ccr > 1
    and enemy.cooldown(48707) <= 4
    and trap.cd <= 1
    and spell:Cast(enemy, {face = true}) then
      alert("Scatter " .. colors.dk .. "[Spell Warden]", spell.id) 
    end
  
    
    -- Cross CC
    if (enemyHealer.debuff(3355, "player") or enemyHealer.debuff(203337, "player"))
    and not player.target.isUnit(enemy)
    and not enemy.isHealer
    and spell:Cast(enemy, {face = true}) then
      alert("Scatter " .. colors.cyan .. "[Cross CC]", spell.id) 
    end
  end)
end)

scatterShot:Callback("seduction", function(spell)
  if not player.hasTalent(gifted.SCATTER_SHOT_TALENT) then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if not settings.scatterOthers then return end
  if settings.MWTOGGLE then return end
  if not player.hasTalent(213691) then return end
  if spell.cd - awful.gcdRemains > 0 then return end

  if trap.cd <= 3 then return end

  --Seduction
  if awful.fighting(265, 266, 267, true) then 

    awful.enemyPets.loop(function(EnemyPet)

      if not EnemyPet.channelID == 6358 then return end
      if not EnemyPet.exists then return end
      if not EnemyPet.los then return end
      if EnemyPet.dist > 21 then return end
      if EnemyPet.immunePhysicalEffects or EnemyPet.immuneCC or EnemyPet.immuneMagic or EnemyPet.immune then return end
      if player.target.isUnit(EnemyPet) then return end
      if EnemyPet.ccr and EnemyPet.ccr > 1 then return end
      if player.casting or player.channeling then return end
      if player.buff(186265) then return end
      if EnemyPet.immuneCC then return end
      if EnemyPet.disorientDR < 0.5 then return end
      if player.buff(199483) then return end

      if EnemyPet.channelID == 6358
      and counterShot.cd - awful.gcdRemains > 0 then
        if spell:Cast(EnemyPet, {face = true}) then
          alert("Scatter " .. colors.cyan .. "[Seduction]", spell.id) 
        end
      end
    end)
  end
end)

-- end scatter shot stuff --


-- Start Damage Rotation --

local checks = 0
hunter.fixKillCommandBug = function()
  -- fix kc stuck queued bug
  if checks > 20 then
    awful.debug.print("cancelling bugged kill command", "debug")
    awful.call("SpellCancelQueuedSpell")
    checks = 0
  else
    if C_Spell.IsCurrentSpell(34026) then
      checks = checks + 1
    else 
      checks = 0 
    end
  end
end 

blackArrow:Callback("target", function(spell)
  if not player.combat then return end
  if player.focus < 10 then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if player.buff(378770) then return end


  if not target.exists then return end
  --if not target.player then return end
  if not target.enemy then return end
  if target.immune then return end
  if target.immuneMagic then return end

  if spell:Castable(target) then
      return spell:Cast(target)
  end
end)

blackArrow:Callback("proc", function(spell)
  if not player.combat then return end
  if player.focus < 10 then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if not player.buff(378770) then return end


  if not target.exists then return end
  --if not target.player then return end
  if not target.enemy then return end
  if target.immune then return end
  if target.immuneMagic then return end

  if spell:Castable(target) then
      return spell:Cast(target)
  end
end)

blackArrow:Callback("enemies", function(spell)
  if not player.combat then return end
  if player.focus < 10 then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if player.buff(378770) then return end


  if not target.exists then return end
  if not target.enemy then return end

  if spell:Castable(target) then return end

  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if enemy.bcc then return end
    if enemy.immune then return end
    if enemy.immuneMagic then return end
    if not enemy.player then return end
    if spell:Castable(enemy) then
      return spell:Cast(enemy)
    end
  end)
end)

barbedShot:Callback("maintain", function(spell) -- target
  if player.recentlyUsed(217200, 1) then return end
  if not player.combat then return end

  if not target.exists then return end
  --if not target.player then return end
  if not target.enemy then return end
  if target.immune then return end
  if target.immuneMagic then return end

  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if target.debuff(217200) and target.debuffRemains(217200) >= 9 then return end

  if pet.exists and pet.buff(gifted.FRENZY_PET_BUFF) and pet.buffRemains(gifted.FRENZY_PET_BUFF) <= (3 + awful.buffer) then

    if spell:Castable(target) then
      return spell:Cast(target)
    end
  end
end)

barbedShot:Callback("normal", function(spell) -- target
  if player.recentlyUsed(217200, 1) then return end
  if not player.combat then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if not target.exists then return end
 -- if not target.player then return end
  if not target.enemy then return end
  if target.immune then return end
  if target.immuneMagic then return end
  if target.hp <= 50 then return end

  if player.recentlyCast(217200, 1) then return end

  if spell:Castable(target) then
      return spell:Cast(target)
    end
end)

barbedShot:Callback("enemies", function(spell)
  if player.recentlyUsed(217200, 1) then return end
  if not player.combat then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if not target.debuff(217200) then return end
  if target.exists and target.enemy and target.debuff(217200) and target.debuffRemains(217200) >= 6 and target.hp <= 70 then return end

  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if enemy.bcc then return end
    if not enemy.player then return end
    if enemy.immune then return end
    if enemy.immuneMagic then return end
    if enemy.debuff(217200) and enemy.debuffRemains(217200) >= 6 then return end

    if spell:Castable(enemy) then
      return spell:Cast(enemy)
    end
  end)
end)

barbedShot:Callback("fallback", function(spell) -- enemy
  if player.recentlyUsed(217200, 1) then return end
  if not player.combat then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if not target.debuff(217200) then return end

  if target.exists and target.enemy and target.debuff(217200) and target.debuffRemains(217200) >= 6 and target.hp <= 70 then return end

  awful.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if enemy.bcc then return end
    if not enemy.player then return end
    if enemy.immune then return end
    if enemy.immuneMagic then return end
    if enemy.debuff(217200) then return end

    if spell:Castable(enemy) then
      return spell:Cast(enemy)
    end
  end)
end)

barbedShot:Callback("enemies-maintain", function(spell) -- enemy
  if player.recentlyUsed(217200, 1) then return end
  if not player.combat then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if not target.debuff(217200) then return end
  if target.exists and target.enemy and target.debuff(217200) and target.debuffRemains(217200) >= 6 and target.hp <= 70 then return end


  awful.enemies.loop(function(enemy)
  if not enemy.exists then return end
  if not enemy.player then return end
  if not enemy.enemy then return end
  if enemy.immune then return end
  if enemy.immuneMagic then return end

  if enemy.debuff(217200) and enemy.debuffRemains(217200) >= 6 then return end

  if pet.exists and pet.buff(gifted.FRENZY_PET_BUFF) and pet.buffRemains(gifted.FRENZY_PET_BUFF) <= (3 + awful.buffer) then

    if spell:Castable(enemy) then
      return spell:Cast(enemy)
    end
  end
end)
end)


killCommand:Callback("normal", function(spell)
  if not player.combat then return end
  if player.focus < 30 then return end
  if barbedShot:Castable() or blackArrow:Castable() or direBeast:Castable() then
    if gifted.WasCasting[spell.id] then return end
    if player.lastCast == 34026 then return end
    if player.recentlyCast(34026, awful.gcd) then return end
  end
  if not target.exists then return end
 -- if not target.player then return end
  if not target.enemy then return end
  if target.immune then return end
  if target.immunePhysical then return end

  if not pet.exists or pet.dead or pet.cc or pet.rooted then return end
  if not pet.losOf(target) then return end

  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if pet.buff(gifted.FRENZY_PET_BUFF) then

    if spell:Castable(target) then
      return spell:Cast(target)
    end
  end
end)

killCommand:Callback("gapclose", function(spell)
  if not player.combat then return end
  if player.focus < 30 then return end
  if barbedShot:Castable() or blackArrow:Castable() or direBeast:Castable() then
    if gifted.WasCasting[spell.id] then return end
    if player.lastCast == 34026 then return end
    if player.recentlyCast(34026, awful.gcd) then return end
  end
  if not target.exists then return end
  -- if not target.player then return end
  if not target.enemy then return end
  if target.immune then return end
  if target.immunePhysical then return end

  if hunter.petControlImportance > 0 then return end
  if not pet.exists or pet.dead or pet.cc or pet.rooted then return end

  if not pet.losOf(target) then return end
  if pet.distanceTo(target) > 8 and pet.distanceTo(target) < 40 then
    return spell:Cast(target) and alert("Kill Command (Gapclose)", spell.id)
  end
end)


cobraShot:Callback("filler", function(spell)
  if not player.combat then return end
  if player.focus < 45 then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if killCommand.charges >= 1 or barbedShot.charges >= 1 then return end

  if killCommand.cd < (0.5 + awful.buffer) or barbedShot.cd < (0.5 + awful.buffer) then return end

  if not target.exists then return end
 -- if not target.player then return end
  if not target.enemy then return end
  if not target.los then return end
  if target.immune then return end
  if target.immunePhysical then return end

  if spell:Castable(target) then
      return spell:Cast(target)
    end
end)

direBeast:Callback("normal", function(spell)
  if not player.combat then return end

  if not target.exists then return end
 -- if not target.player then return end
  if not target.enemy then return end
  if not target.los then return end
  if target.immune then return end
  if target.immunePhysical then return end

  if spell:Castable(target) then
    return spell:Cast(target)
  end
end)

direBeast:Callback("burst", function(spell)
  if not player.combat then return end

  if not target.exists then return end
 -- if not target.player then return end
  if not target.enemy then return end
  if not target.los then return end
  if target.immune then return end
  if target.immunePhysical then return end

  if not player.buff(19574) then return end

  if spell:Castable(target) then
    return spell:Cast(target)
  end
end)



-- End Damage Rotation --




-- Burst Rotation --

beastialWrath:Callback("burst", function(spell)
  if not player.combat then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if pet.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if not target.exists then return end
  if not target.enemy then return end
  if not target.los then return end
  if target.immune then return end
  if target.immunePhysical then return end
  if target.immuneMagic then return end
  if target.distance >= 38 then return end

  -- if pet.exists and pet.buff(gifted.FRENZY_PET_BUFF) then 

    if spell:Castable(target) then
      return spell:Cast(target)
    -- end
  end
end)

callOfTheWild:Callback("burst", function(spell)
  if not player.combat then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if pet.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end

  if not target.exists then return end
  if not target.enemy then return end
  if not target.los then return end
  if target.immune then return end
  if target.immunePhysical then return end
  if target.immuneMagic then return end
  if target.distance >= 38 then return end

  -- if pet.exists and pet.buff(gifted.FRENZY_PET_BUFF) then 

    if spell:Castable(target) then
      return spell:Cast(target)
    -- end
  end
end)

bloodshed:Callback("burst", function(spell)
  if not player.combat then return end
  if player.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if pet.debuff(gifted.SEARING_GLARE_DEBUFF_ID) then return end
  if not player.hasTalent(gifted.BLOODSHED_TALENT) then return end

  if not target.exists then return end
  if not target.enemy then return end
  if not target.los then return end
  if target.immune then return end
  if target.immunePhysical then return end
  if target.immuneMagic then return end
  if target.distance >= 38 then return end

  if pet.exists and pet.buff(gifted.FRENZY_PET_BUFF) then 

    if spell:Castable(target) then
      return spell:Cast(target)
    end
  end
end)

-- End Burst Rotation --

-- hunters mark --

huntersMark:Callback("target", function(spell)
  if not target.exists then return end
  if not target.enemy then return end
  if not target.los then return end
  if target.immune then return end
  if target.immuneMagic then return end
  if target.debuff(257284) then return end
  if target.hp < 78 then return end
  if player.debuff(gifted.SEARING_SHOT_DEBUFF_ID) then return end


  if spell:Castable(target) then
    return spell:Cast(target)
  end
end)


-- draw trap target --

awful.Draw(function(draw)
  if not settings.drawtraptarget then return end
  if settings.MWTOGGLE then return end

  if not hunter.trapTarget.exists then return end
  if not hunter.trapTarget.enemy then return end

  if trap.cd > 5 then return end
  if (settings.autoStun and intimidation.cd > 5) and (settings.autoBindingShot and binding.cd > 5) then return end

  local px, py, pz = player.position()
  local tx, ty, tz = hunter.trapTarget.position()
  local distance = math.sqrt((px - tx)^2 + (py - ty)^2 + (pz - tz)^2)
  draw:SetWidth(0.8)

  if distance <= 28 then
    draw:SetColor(0, 0, 0) -- Black color
    draw:Text("Trap Target In Range", AwfulFontLarge, tx, ty, tz)
  else
    draw:SetColor(255, 255, 255) -- White color
    draw:Text("Trap Target Out Of Range", AwfulFontLarge, tx, ty, tz)
  end

  draw:Circle(tx, ty, tz, 28) -- Added thickness parameter to make the circle thinner
end)

awful.Draw(function(draw)
  if not settings.drawtraptarget then return end
  if not settings.MWTOGGLE then return end

  if not hunter.trapTarget.exists then return end
  if not hunter.trapTarget.enemy then return end

  if trap.cd > 5 then return end
  if (settings.autoStun and intimidation.cd > 5) and (settings.autoBindingShot and binding.cd > 5) and (settings.MWTOGGLE and scatterShot.cd > 5) then return end
  


  local px, py, pz = player.position()
  local tx, ty, tz = hunter.trapTarget.position()
  local distance = math.sqrt((px - tx)^2 + (py - ty)^2 + (pz - tz)^2)

  draw:SetWidth(0.8)

  if distance <= 20 then
    draw:SetColor(0, 0, 0) -- Black color
    draw:Text("Trap Target In Range", AwfulFontLarge, tx, ty, tz)
  else
    draw:SetColor(255, 255, 255) -- White color
    draw:Text("Trap Target Out Of Range", AwfulFontLarge, tx, ty, tz)
  end

  draw:Circle(tx, ty, tz, 20) -- Added thickness parameter to make the circle thinner
end)

-- end draw trap target --

-- end hunters mark --

-- start auto target --

function gifted.autoTarget()

  local bestScore = -9999
  local bestTarget = nil

  local specRole = {
    Arms = "melee", Fury = "melee", Protection = "melee",
    HolyPaladin = "healer", ProtectionPaladin = "melee", Retribution = "melee",
    BeastMastery = "ranged", Marksmanship = "ranged", Survival = "melee",
    Assassination = "melee", Outlaw = "melee", Subtlety = "melee",
    Discipline = "healer", HolyPriest = "healer", Shadow = "ranged",
    Blood = "melee", FrostDK = "melee", Unholy = "melee",
    Elemental = "ranged", Enhancement = "melee", RestorationShaman = "healer",
    Arcane = "ranged", Fire = "ranged", FrostMage = "ranged",
    Affliction = "ranged", Demonology = "ranged", Destruction = "ranged",
    Brewmaster = "melee", Mistweaver = "healer", Windwalker = "melee",
    Balance = "ranged", Feral = "melee", Guardian = "melee", RestorationDruid = "healer",
    Havoc = "melee", Vengeance = "melee",
    Devastation = "ranged", Preservation = "healer", Augmentation = "ranged",
  }

  local roleDamageType = {
    melee = "physical",
    ranged = "physical",
    caster = "magic",
    healer = "magic",
    tank = "physical",
  }

  local playerSpec = player.spec
  local playerRole = specRole[playerSpec]
  local playerDamageType = roleDamageType[playerRole]

  --chill
  if not awful.instanceType2 == "pvp" then return end
  if not settings.autotarget then return end
  if not player.combat then return end

  awful.enemies.loop(function(enemy)
    if enemy.los 
    and not enemy.isPet 
    and not enemy.isUnit(hunter.trapTarget) then
      local score = 0

      -- Calculate score based on Health / Absorbs
      score = score - enemy.hp 

      -- Check for Immune Magic
      if playerDamageType == "magic" 
      and enemy.immuneMagicDamage then
        return
      end

      -- Check for Immune physical
      if playerDamageType == "physical" 
      and enemy.immunePhysicalDamage then
        return
      end

      --player not facing the shit
      if not player.facing(enemy, 130) then
        return
      end

      -- Check distance for melee players
      if playerRole == "melee" 
      and enemy.distance > 5 then
        return
      end

      -- Check distance for ranged players
      if playerRole == "ranged" 
      and enemy.distance > 40 then 
        return
      end

      --MM Hunters? more range fuck it
      if player.class2 == "HUNTER" 
      and player.spec == "Marksmanship"
      and enemy.distance > 45 then
        return
      end
      
      -- Update best target
      if score > bestScore then
        bestScore = score
        bestTarget = enemy
      end
    end
  end)
  
  if bestTarget then 
    bestTarget.setTarget()
  end
end

-- end auto target --

  bm:Init(function()
    
    gifted.filteredEnemies = awful.enemies.filter(function(enemy) return enemy.isPlayer and not enemy.dead end)
    gifted.sortedEnemies = gifted.filteredEnemies.sort(function(a, b) return a.hp < b.hp end)

    gifted.filteredFriendlies = awful.fgroup.filter(function(friend) return friend.isPlayer and not friend.dead end)
    gifted.sortedFriendlies = gifted.filteredFriendlies.sort(function(a, b) return a.hp < b.hp end)

    -- initialize macros --
    awful.RegisterMacro("disengage forward", 1.25)
    awful.RegisterMacro("disengage target", 1)
    awful.RegisterMacro("disengage healer", 1)
    awful.RegisterMacro("disengage focus", 1)
    awful.RegisterMacro("disengage flow", 1)
    awful.RegisterMacro("disengage flow2", 1)
    awful.RegisterMacro("disengage trap", 1)
    awful.RegisterMacro("disengage enemyhealer", 1)
    awful.RegisterMacro("trap", 10)
    awful.RegisterMacro('reset', 5)

    -- end initialize macros --

    -- initialize pause vars --
    local turtled = player.buff(186265)
    local inCamo = player.buff(199483)
    hunter.criticalPause = false
    hunter.temporaryAlert = false
    hunter.importantPause = false
    hunter.unimportantPause = false
    hunter.drawFollowupTrap = false
    -- end initialize pause vars --

    -- functions --
    hunter.disengage:handler()
    gifted.CheckHealerLocked()
    setFocus()
    hunter:AntiPetTaunt()
    gifted.FlagPick()
    hunter.fixKillCommandBug()
    BurstAlert()
    gifted.autoTarget()
    -- end functions --

    -- start pet eat trap --
    if awful.arena 
    and settings.peteattrap 
    and healer.exists 
    and healer.stunned 
    or healer.exists and healer.debuff(213691) then
      hunter:PetEatTrap()
    end

    -- end pet eat trap --

    -- soulwell stuff --
    if awful.prep then
        Soulwell()
    end
    -- end soulwell stuff --

    -- flares above pauses only during camo --
    if inCamo then
      flare("restealth")
      flare("stealth")
      flare("binding")
      flare("friendly")
      hunter.mark("stealthunits")
    end
    -- end flares above pauses only during camo --

    -- return if in camo or mounted or feigned --
    if inCamo or player.mounted or player.buff(feign.id) then 
        return 
    end
    -- end return if in camo or mounted or feigned --

    -- dash stuff --
    dash("rooted")
    -- end dash stuff --

    -- pursue trap --
    local status = hunter.trap:pursue(trapTarget)
    if status and hunter.trap.cd < 4 and type(status) == "string" then
        awful.alert(status, hunter.trap.id)
    end
    -- end pursue trap --

    -- followup trap --
    local status = hunter.trap:followup(trapTarget)
    if status and hunter.trap.cd < 4 and type(status) == "string" then
        awful.alert(status, hunter.trap.id)
    end
    -- end followup trap --

    -- defensives --
    roarOfSacrifice("party")
    roarOfSacrifice("threshold")
    fortitude("default")
    survivalOfTheFittest("default")
    exhilaration("default")
    aspectOfTheTurtle("default")
    feign("hp")
    feign("pvp-bigdam")
    feign("cds")
    feign("damage")
    -- end defensives --

    -- meld/feign stuff --
    feign("dodgeCC")
    shadowmeld("dodgeCC")
    shadowmeld("instants")
    shadowmeld("pvp-bigdam")
    feign("instants")
    -- end meld/feign stuff --

      -- critical pause --
      -- if hunter.criticalPause then 
      --   return awful.alert(hunter.criticalPause.msg, hunter.criticalPause.texture)
      -- end
    -- end critical pause --

    -- master's call stuff --
    mastersCall("rootbeam")
    mastersCall("harpoon")
    mastersCall("player")
    -- end master's call stuff --

    -- cc stuff --
    highExplosiveTrap("traptarget-intimidation")
    highExplosiveTrap("traptarget-druid-binding")
    burstingShot("traptarget-intimidation")
    highExplosiveTrap("traptarget")
    burstingShot("traptarget")
    scatterShot("MW")
    intimidation("MW")
    binding("MW")
    intimidation("traptarget")
    binding("traptarget")
    intimidation("Kill Target")
    -- end cc stuff --

    -- countershot(kick) stuff --
    if not turtled then
      counterShot("cc")
      counterShot("damage")
      counterShot("healer")
    end
    -- end countershot(kick) stuff --

    -- cover traps --
    scatterShot("covertraps")
    -- end cover traps --

    -- knock defensives --
    burstingShot("knock-defensives")
    highExplosiveTrap("knock-defensives")
    -- end knock defensives --

    -- start pause for traps --
    if hunter.importantPause then 
      return awful.alert(hunter.importantPause.msg, hunter.importantPause.texture) 
  end
  -- end pause for traps --

  if hunter.trapTarget.exists and (hunter.trapTarget.debuff(24394) or hunter.trapTarget.debuff(117405) or hunter.trapTarget.debuff(117526) or hunter.trapTarget.debuff(213691)) then return end

    -- -- chimaeral sting stuff --
    chimaeralSting("badposition")
    chimaeralSting("lockout")
    chimaeralSting("healerlowhp")
    chimaeralSting("healer")
    chimaeralSting("castersbursting")
    -- end chimaeral sting stuff --

    -- totem stomp stuff --
    HardCodeStomp()
    -- end totem stomp stuff --

    -- scatter shot stuff --
    scatterShot("big dam")
    scatterShot("seduction")
    -- end scatter shot stuff --

    -- tar trap stuff --
    tar("BM Pets")
    tar("badposition")
    tar("bigdmg")
    tar("stacked")
    tar("tyrant")
    -- end tar trap stuff --

    -- flare/mark stuff --
    huntersMark("target")
    flare("restealth")
    flare("stealth")
    flare("binding")
    flare("friendly")
    -- end flare/mark stuff --
     
    -- binding shot handler --
    binding:handler()
    disengage("backwardsnormaldk")
    binding("cover stuff")
    binding("stacked")
    binding("beastial wrath pets")
    -- end binding shot handler --

    -- hunters mark --
    if inCamo then
      huntersMark("target")
    end
    -- end hunters mark --

    -- auto attack stuff --
    autoShot()
    hunter:PetControl()
    -- end auto attack stuff --

    -- black arrow stuff --
    blackArrow("proc")
    blackArrow("target")
    blackArrow("enemies")
    -- end black arrow stuff --

    -- KC Gap Close --
    killCommand("gapclose")
    -- end KC Gap Close --

    if awful.burst or settings.autoburst then
      direBeast("burst")
      callOfTheWild("burst")
      bloodshed("burst")
      beastialWrath("burst")
      -- commandPetLust("pvp")
      BloodFury("pvp")
      Badge()
    end

    -- barbed maintain --
    barbedShot("maintain")
    barbedShot("enemies-maintain")
    -- end barbed maintain --

    -- purge stuff --
    tranquilizingShot("pvp-prio")
    tranquilizingShot("target-prio")
    -- end purge stuff --

    -- conc stuff --
    conc("slowbigdam")
    conc("tunnel")
    -- end conc stuff --

    -- high prio dps rotation goes here --

    direBeast("normal")
    killCommand("normal")
    barbedShot("enemies")
    barbedShot("normal")
    barbedShot("fallback")


    -- conc trap target when moving towards them
    if conc("trap target") then return end
    conc("slow target")


    -- lower prio dps rotation goes here --
    cobraShot("filler")


  end, 0.06)
