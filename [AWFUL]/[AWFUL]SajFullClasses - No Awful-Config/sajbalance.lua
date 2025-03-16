local Unlocker, awful, sajbalance = ...
local player, target, focus, healer, enemyHealer, arena1, arena2, arena3, party1, party2 = awful.player, awful.target, awful.focus, awful.healer, awful.enemyHealer, awful.arena1, awful.arena2, awful.arena3, awful.party1, awful.party2



sajbalance.druid = {}
sajbalance.druid.balance = awful.Actor:New({ spec = 1, class = "druid" })

local balance = sajbalance.druid.balance

if player.spec ~= "Balance" then return end
if player.class2 ~= "DRUID" then return end

if player.class2 == "DRUID" and player.spec == "Balance" then
    awful.print("|cff2c71a5 Welcome|r ")
    awful.print("|cff20c000 Sajs Balance loaded|r"  .. awful.textureEscape(78674, 20, "0:01"))
    awful.print("|cff2c71a5 Enjoy|r ")
end

local cmd = awful.Command("saj", true)
sajbalance.cmd = cmd

--awful.enabled = true

local min, max, bin, cos, sin = min, max, awful.bin, math.cos, math.sin

local NewSpell = awful.NewSpell

local wasCasting = {}
function WasCastingCheck()
    local time = awful.time
    if player.casting then
        wasCasting[player.castingid] = time
    end
    for spell, when in pairs(wasCasting) do
        if time - when > 0.100 + awful.buffer then
            wasCasting[spell] = nil
        end
    end
end

---UI----

local settings = sajbalance.settings

local yellow = {245, 235, 55, 1}
local white = {255, 255, 255, 1}
local dark = {21, 21, 21, 0.45}
local orange = {255, 140, 0, 255}
local red = {255, 0, 0, 255}
local brown = {139, 71, 38, 255}
local green = {0, 255, 0, 255}
local black = {0, 0, 0, 0}
local yellowcool = {255, 255, 153, 1}
local redcool = {139, 90, 43, 0.45}
local greencool = {152, 251, 152, 1}
local browncool = {255, 165, 79, 1}
local newgreencool = {0, 255, 0, 1}
local bluecool = {84, 89, 235, 1}
local bluecool2 = {112, 121, 208, 1}
local bluecool3 = {164, 169, 213, 1}

local gui, settings = awful.UI:New("sajUI", {
 title = "S A J",
 show = true, -- show not on load by default
 colors = {
     --color of our ui title in the top left
     title = bluecool2,
     --primary is the primary text color
     primary = bluecool2,
     --accent controls colors of elements and some element text in the UI. it should contrast nicely with the background.
     accent = bluecool3,
     background = dark,
 }
})

local sajUI = gui:Tab("Mode")

sajUI:Text({
    text = awful.textureEscape(4913233, 25, "0:0") .. awful.colors.druid .. " Sajs Boomkin",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Dropdown({
	var = "mode",
	tooltip = "Using different logics in different modes, very important to choose!",
	options = {
		{ label = awful.textureEscape(400924, 22, "0:01") .. "  PVP", value = "pvpmode", tooltip = "Choose if you play PVP", default = true },
        { label = awful.textureEscape(264314, 22, "0:01") .. "  PVP RBG/BG", value = "bgmode", tooltip = "Choose if you play RBGs or BGs" },
       -- { label = awful.textureEscape(3610506, 22, "0:01") .. "  Solo Shuffle Bot", value = "ssbotmode", tooltip = "Choose if you bought the Solo Shuffle Bot and want to play with my routine." },
	},
	placeholder = "PRESS HERE TO SELECT MODE",
	header = "Arena Mode:",
})

-- sajUI:Checkbox({
--     text = awful.textureEscape(446087, 22, "0:13") .. "  Cast while we move       ",
--     var = "castwhilemoving", -- checked bool = if not settings.castwhilemoving then return end
--     default = true,
--     tooltip = "We cast/spread/refresh dots while we are moving" 
-- })

sajUI:Checkbox({
    text = awful.textureEscape(3684828, 22, "0:13") .. "  Drawings",
    var = "drawings", -- checked bool = settings.drawings   
    default = true,
    tooltip = "Drawings like Trap, Lines to ur Mates and stuff" 
    })

sajUI:Checkbox({
    text = awful.textureEscape(33786, 22, "0:13") .. "  Drawings for cc macros",
    var = "drawingscctime", -- checked bool = settings.drawings   
    default = true,
    tooltip = "When enabled, it shows a circle around you with a cyclone range" 
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Checkbox({
    text = awful.textureEscape(187116, 22, "0:13") .. "  Debug Mode, don't enable!!!",
    var = "alertsmode", -- checked bool = settings.alertsmode
    default = false,
    tooltip = "Don't touch. It's made for DEV debugging, if it's enabled just disable it." 
})

-- sajUI:Checkbox({
--     text = awful.textureEscape(3610512, 22, "0:13") .. "  Playing with /saj macros",
--     var = "autobearin", -- checked bool = if not settings.autobearin then return end 
--     default = true,
--     tooltip = "Turn on this option when you play with my macros like /saj beartime or /saj traveltime. Recommended, it is made for smoother Boomkin switches."
-- })

-- sajUI:Checkbox({
--     text = awful.textureEscape(4548873, 22, "0:13") .. "  Statusframe Icons",
--     var = "statusframeye", -- checked bool = settings.statusframeye  
--     default = false,
--     tooltip = "If you enable it, you need to RELOAD the game to get the Statusframe Icons, if you don't want them disable and reload again" 
-- })

-- sajUI:Checkbox({
--     text = awful.textureEscape(4549153, 22, "0:13") .. "  Disable Macro Alerts",
--     var = "macroalertsdisable", -- checked bool = settings.macroalertsdisable
--     default = false,
--     tooltip = "If you don't like the static macro alerts, you can turn it off here" 
-- })

local sajUI = gui:Tab("Options")

sajUI:Text({
    text = awful.textureEscape(4913233, 25, "0:0") .. awful.colors.druid .. " Sajs Boomkin",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Checkbox({
    text = awful.textureEscape(33786, 22, "0:13") .. "  Auto Clone   ",
    var = "autoclone", -- checked bool = if not settings.autoclonehighrating then return end
    default = true,
    tooltip = "Auto Clone with a lot of scenarios. Auto Clone only happen on FULL DR and works only in ARENA! Please still use my cc macros for urself" 
})

sajUI:Checkbox({
    text = awful.textureEscape(446087, 22, "0:13") .. "  Auto Clone Movement Lock",
    var = "autolockmovement", -- checked bool = if not settings.autolockmovement then return end
    default = true,
    tooltip = "Auto Locking Movement on Auto Clone" 
})

sajUI:Checkbox({
    text = awful.textureEscape(254416, 22, "0:13") .. "  Totem Stomp ",
    var = "totemstomps", -- checked bool = settings.smalltotemstomps    
    default = true,
    tooltip = "Stomping totems/observers" 
})

sajUI:Checkbox({
    text = awful.textureEscape(187650, 22, "0:13") .. "  Wildcharge Traps ",
     var = "autowildcharge", -- checked bool = settings.autowildcharge
     default = true,
     tooltip = "Using Wildcharge to eat traps" 
})

sajUI:Checkbox({
    text = awful.textureEscape(78675, 22, "0:13") .. "  Auto Root/Beam      ",
    var = "autobeam", -- checked bool = if not settings.autobeam then return end
    default = true,
    tooltip = "Auto Root/Beam Enemy Healer in specific scenarios" 
})

sajUI:Checkbox({
    text = awful.textureEscape(78675, 22, "0:13") .. "  Auto Root-Beam on ccheal",
    var = "autorootbeam", -- checked bool = settings.autorootbeam
    default = true,
    tooltip = "Using root-beam on ccheal macro" 
    })
    
    sajUI:Checkbox({
    text = awful.textureEscape(78675, 22, "0:13") .. "  Auto Root-Beam on burst",
    var = "autorootbeamburst", -- checked bool = settings.autorootbeam
    default = true,
    tooltip = "Using root-beam on burst macro" 
    })
    
    -- sajUI:Checkbox({
    --     text = awful.textureEscape(78675, 22, "0:13") .. " Beam as Kick on low hp",
    --     var = "lowbeamkick", -- checked bool = settings.autorootbeam
    --     default = false,
    --     tooltip = "Using beam on enemy heal when target is dropping very low and has no immunities/big absorbs" 
    -- })
    
    -- sajUI:Checkbox({
    -- text = awful.textureEscape(102359, 22, "0:13") .. "  Auto Massroot ",
    -- var = "automassroot", -- checked bool = settings.automassroot
    -- default = true,
    -- tooltip = "Using root in specific moments" 
    -- })
    
    sajUI:Checkbox({
        text = awful.textureEscape(102793, 22, "0:11") .. "  Auto Vortex ",
        var = "autovortex", -- checked bool = settings.test
        default = true,
        tooltip = "Using auto vortex" 
    })
    
    sajUI:Checkbox({
        text = awful.textureEscape(132469, 22, "0:11") .. "  Auto Typhoon",
        var = "autotyphoon", -- checked bool = settings.autotyphoon
        default = true,
        tooltip = "Using auto Typhoon" 
    })
    
    sajUI:Checkbox({
    text = awful.textureEscape(319454, 22, "0:13") .. "  Auto Heart of the Wild",
    var = "autohotw", -- checked bool = if not settings.feralhotw then return end
    default = true,
    tooltip = "Using HotW when getting slapped" 
    })

-- local sajUI = gui:Tab("Defensives")

-- sajUI:Text({
--     text = awful.textureEscape(4913233, 25, "0:0") .. awful.colors.druid .. " Sajs Boomkin",
--     header = true,
--     size = 12,
--     paddingBottom = 7,
-- })
-- --damit abstand ist--
-- sajUI:Text({
--     text = "  "
-- })

-- sajUI:Dropdown({
-- 	var = "clonemode",
-- 	tooltip = "<BETA> Using different clone logics in different mode, very important to choose!",
-- 	options = {
-- 		{ label = awful.textureEscape(33786, 22, "0:01") .. "  Auto Clone", value = "autoclone", tooltip = "Choose to enable Auto Clone", default = true },
-- 		{ label = awful.textureEscape(33786, 22, "0:01") .. "  Auto Clone SS Bot", value = "autoclonebot", tooltip = "Choose if you enabled Solo Shuffle Bot" },
--         { label = awful.textureEscape(999951, 22, "0:01") .. "  Disable Auto Clone", value = "autoclonedisabled", tooltip = "Choose if you don't want Auto Clone" },
-- 	},
-- 	placeholder = "PRESS HERE TO SELECT CLONE MODE",
-- 	header = "Auto Clone Mode:",
-- })

-- sajUI:Checkbox({
--     text = awful.textureEscape(33786, 22, "0:13") .. "  High Rating Auto Clone   ",
--     var = "autoclonehighrating", -- checked bool = if not settings.autoclonehighrating then return end
--     default = false,
--     tooltip = "<BETA> Auto Clone on big defensives like cocoon and stuff, you will probably get flamed on low rating for these plays" 
-- })

-- sajUI:Checkbox({
--     text = awful.textureEscape(33786, 22, "0:13") .. "  Auto Clone Tyrant",
--     var = "autoclonetyrant", -- checked bool = if not settings.autoclonehighrating then return end
--     default = true,
--     tooltip = "Auto Clone on Enemy Tyrants in Arena (not made for BGs)" 
-- })

-- sajUI:Checkbox({
--     text = awful.textureEscape(209740, 22, "0:13") .. "  Auto Burst      ",
--     var = "autoburst", -- checked bool = if not settings.autoburst then return end
--     default = false,
--     tooltip = "<BETA> Auto Burst" 
-- })

local sajUI = gui:Tab("Defensives")

sajUI:Text({
    text = awful.textureEscape(4913233, 25, "0:0") .. awful.colors.druid .. " Sajs Boomkin",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

--done--
sajUI:Slider({
 text = awful.textureEscape(538745, 22, "0:3") .. "Healthstone",
 var = "healthstoneHP",
 min = 0,
 max = 100,
 step = 1,
 default = 30,
 valueType = "%",
 tooltip = "The routine will use healthstone at"
})

sajUI:Checkbox({
text = awful.textureEscape(5487, 22, "0:13") .. "  Auto Bear   ",
var = "autobear", -- checked bool = if not settings.autobear then return end
default = true,
tooltip = "Will auto enable bear. It will also try to pre-bear kidneys and stuff." 
})

sajUI:Checkbox({
text = awful.textureEscape(8936, 22, "0:13") .. "  Auto Heal    ",
var = "autoregrowth", -- checked bool = settings.test
default = false,
tooltip = "Casting heals in specific situation <Arena>" 
})

--done--
sajUI:Checkbox({
 text = awful.textureEscape(22812, 22, "0:13") .. "  Auto Barkskin ",   
 var = "autobarkskin", -- checked bool = settings.autobarkskin
 default = true,
 tooltip = "Using Barkskin auto in specific situations" 
})

sajUI:Checkbox({
text = awful.textureEscape(108238, 22, "0:13") .. "  Auto Renewal ",
 var = "autorenewal", -- checked bool = settings.autorenewal
 default = true,
 tooltip = "Using Renewal auto in specific situations" 
})

sajUI:Checkbox({
text = awful.textureEscape(58984, 22, "0:13") .. "  Auto Shadowmeld ",
 var = "automeld", -- checked bool = settings.automeld
 default = true,
 tooltip = "Using Shadowmeld for Bolts, Coils and stuff" 
})

sajUI:Checkbox({
    text = awful.textureEscape(305497, 22, "0:13") .. "  Auto Thorns ",
    var = "autothorns", -- checked bool = settings.autothorns
    default = true,
    tooltip = "Using auto thorns" 
    })

-- sajUI:Checkbox({
-- text = awful.textureEscape(208683, 22, "0:13") .. "  Auto Trinket ",
-- var = "autotrinketsmart", -- checked bool = settings.autotrinketsmart
-- default = false,
-- tooltip = "<For Beginners> Using Trinket auto in specific situations, not recomennded" 
-- })


local sajUI = gui:Tab("Cooldowns")

sajUI:Text({
    text = awful.textureEscape(4913233, 25, "0:0") .. awful.colors.druid .. " Sajs Boomkin",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Checkbox({
    text = awful.textureEscape(390414, 22, "0:13") .. "  Auto Burst ",
    var = "autoburst", -- checked bool = settings.autoburst
    default = true,
    tooltip = "Will Auto burst, if you want to use it manual check macro section." 
})

-- sajUI:Checkbox({
--     text = awful.textureEscape(274283, 22, "0:13") .. "  Full Moon only with Macro",
--     var = "autofullmoon", -- checked bool = if settings.autofullmoon then return end 
--     default = false,
--     tooltip = "Enable it to use Full Moon only with /saj bursti Macro and not by default. New Moon and Half Moon will still be used by default." 
-- })

-- sajUI:Checkbox({
--     text = awful.textureEscape(274283, 22, "0:13") .. "  Auto Full Moon on Precog",
--     var = "autofullmoonprecog", -- checked bool = if not settings.autofullmoonprecog then return end 
--     default = false,
--     tooltip = "Enable it to use Full Moon with Precognition Buff" 
-- })


local sajUI = gui:Tab("Macros")

sajUI:Text({
    text = awful.textureEscape(4913233, 25, "0:0") .. awful.colors.druid .. " Sajs Boomkin",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Text({
    text = "|cfffff394/username cast [@<unit>] <spell>",
    size = 10,
    paddingBottom = 5,
})

sajUI:Text({
    text = "|cfffff394/username toggle",
    size = 10,
    paddingBottom = 5,
})

sajUI:Text({
    text = "|cfffff394/sajui",
    size = 10,
    paddingBottom = 5,
})

sajUI:Text({
    text = "|cfffff394/saj bursti",
    size = 10,
    paddingBottom = 5,
})

sajUI:Text({
    text = "|cfff2b0ffWill burst on your current target with all cds rdy",
    size = 8,
    paddingBottom = 8,
})

sajUI:Text({
    text = "|cfffff394/saj ccheal",
    size = 10,
    paddingBottom = 5,
})
sajUI:Text({
    text = "|cfff2b0ffEvery CC is going on Enemy Heal, Rotation will focus on CCing and stops doing anything other",
    size = 8,
})

sajUI:Text({
    text = "|cfffff394/saj cchealtwo",
    size = 10,
    paddingBottom = 5,
})
sajUI:Text({
    text = "|cfff2b0ffEvery CC is going on Enemy Heal, Rotation will still focusing on doing dmg/other stuff meanwhile, so cc-chains won't be to clean",
    size = 8,
})

sajUI:Text({
    text = "|cfffff394/saj ccoff",
    size = 10,
    paddingBottom = 1,
})
sajUI:Text({
    text = "|cfff2b0ffEvery CC is going on the off target (second DPS)",
    size = 8,
})

sajUI:Text({
    text = "|cfffff394/saj beartime",
    size = 10,
    paddingBottom = 6,
})
sajUI:Text({
    text = "|cfff2b0ffWhen you press it, auto switch into bear form + using everything needed in bear form. When you disable it, it will go back to moonkin",
    size = 8,
    paddingBottom = 8,
})

sajUI:Text({
    text = "|cfffff394/saj traveltime",
    size = 10,
    paddingBottom = 5,
})
sajUI:Text({
    text = "|cfff2b0ffit will force travelform and stay in there, so be careful turning it on/off, just for kiting but will stop most other stuff",
    size = 8,
})

-- local sajUI = gui:Tab("Team Comp")

-- sajUI:Text({
--     text = awful.textureEscape(393760, 25, "0:0") .. awful.colors.druid .. " Sajs Boomkin",
--     header = true,
--     size = 12,
--     paddingBottom = 7,
-- })

-- --damit abstand ist--
-- sajUI:Text({
--     text = "  "
-- })

-- sajUI:Dropdown({
-- 	var = "partner1",
-- 	tooltip = "What is ur first Party Member?",
-- 	options = {
-- 		{ label = awful.textureEscape(626008, 22, "0:01") .. "  Warrior", value = "war", tooltip = "One Member is a warrior", default = true },
--         { label = awful.textureEscape(1260827, 22, "0:01") .. "  Demon Hunter", value = "dh", tooltip = "One group Member is a DH" },
--         { label = awful.textureEscape(626000, 22, "0:01") .. "  Hunter", value = "hunter", tooltip = "One group Member is a Hunter" },
--         { label = awful.textureEscape(626005, 22, "0:01") .. "  Rogue", value = "rogue", tooltip = "One group Member is a Rogue" },
--         { label = awful.textureEscape(626003, 22, "0:01") .. "  Ret", value = "ret", tooltip = "One group Member is a Ret" },
--         { label = awful.textureEscape(4574311, 22, "0:01") .. "  Devoker", value = "devoker", tooltip = "One group Member is a Devoker" },
--         { label = awful.textureEscape(626001, 22, "0:01") .. "  Mage", value = "mage", tooltip = "One group Member is a Mage" },
--         { label = awful.textureEscape(625999, 22, "0:01") .. "  Druid", value = "druid", tooltip = "One group Member is a Druid (Balance/Feral)" },
--         { label = awful.textureEscape(626006, 22, "0:01") .. "  Shaman", value = "shaman", tooltip = "One group Member is a Shaman (Ele/Enh)" },
--         { label = awful.textureEscape(626007, 22, "0:01") .. "  Warlock", value = "warlock", tooltip = "One group Member is a Warlock" },
--         { label = awful.textureEscape(626004, 22, "0:01") .. "  Shadow", value = "shadow", tooltip = "One group Member is a Shadow" },
--         { label = awful.textureEscape(626002, 22, "0:01") .. "  Windwalker", value = "ww", tooltip = "One group Member is a Winwalker" },
--         { label = awful.textureEscape(356321, 22, "0:01") .. "  Death Knight", value = "dk", tooltip = "One group Member is a Unholy/Frost" },
--         { label = awful.textureEscape(264314, 22, "0:01") .. "  RBG / BG", value = "bgmode", tooltip = "I am playing BGs/RBG" },
-- 	},
-- 	placeholder = "PRESS HERE TO SELECT UR TEAMMATE",
-- 	header = "Arena Partner 1:",
-- })

-- sajUI:Dropdown({
-- 	var = "partner2",
-- 	tooltip = "Which Healer are u playing with?",
-- 	options = {
-- 		{ label = awful.textureEscape(17, 22, "0:01") .. "  Disc Priest", value = "disc", tooltip = "One Member is a warrior", default = true },
--         { label = awful.textureEscape(1260827, 22, "0:01") .. "  Demon Hunter", value = "dh", tooltip = "One group Member is a DH" },
--         { label = awful.textureEscape(626000, 22, "0:01") .. "  Hunter", value = "hunter", tooltip = "One group Member is a Hunter" },
--         { label = awful.textureEscape(626005, 22, "0:01") .. "  Rogue", value = "rogue", tooltip = "One group Member is a Rogue" },
--         { label = awful.textureEscape(626003, 22, "0:01") .. "  Ret", value = "ret", tooltip = "One group Member is a Ret" },
--         { label = awful.textureEscape(4574311, 22, "0:01") .. "  Devoker", value = "devoker", tooltip = "One group Member is a Devoker" },
--         { label = awful.textureEscape(626001, 22, "0:01") .. "  Mage", value = "mage", tooltip = "One group Member is a Mage" },
--         { label = awful.textureEscape(625999, 22, "0:01") .. "  Druid", value = "druid", tooltip = "One group Member is a Druid (Balance/Feral)" },
--         { label = awful.textureEscape(626006, 22, "0:01") .. "  Shaman", value = "shaman", tooltip = "One group Member is a Shaman (Ele/Enh)" },
--         { label = awful.textureEscape(626007, 22, "0:01") .. "  Warlock", value = "warlock", tooltip = "One group Member is a Warlock" },
--         { label = awful.textureEscape(626004, 22, "0:01") .. "  Shadow", value = "shadow", tooltip = "One group Member is a Shadow" },
--         { label = awful.textureEscape(626002, 22, "0:01") .. "  Windwalker", value = "ww", tooltip = "One group Member is a Winwalker" },
--         { label = awful.textureEscape(356321, 22, "0:01") .. "  Death Knight", value = "dk", tooltip = "One group Member is a Unholy/Frost" },
--         { label = awful.textureEscape(264314, 22, "0:01") .. "  RBG / BG", value = "bgmode", tooltip = "I am playing BGs/RBG" },
--         { label = awful.textureEscape(2022761, 22, "0:01") .. "  Rated 2vs2", value = "ratedmode2s", tooltip = "I am playing 2s, so no third partner" },
-- 	},
-- 	placeholder = "PRESS HERE TO SELECT UR TEAMMATE",
-- 	header = "Arena Partner 2:",
-- })

--- Visuals ---

awful.Draw(function(draw)
    if not settings.drawings then return end
    awful.triggers.loop(function(trigger)
        if trigger.id ~= 187651 then return end --freezing trap--
        if trigger.distance > 60 then return end 
        if trigger.creator.friend then return end
        local x,y,z = trigger.position()
        draw:SetColor(255, 1, 1, 169)
        draw:Outline(x,y,z,2.5)
    end)
end)

awful.Draw(function(draw)
    if not settings.drawings then return end
    awful.triggers.loop(function(trigger)
        if trigger.id ~= 132950 then return end --flair--
        if trigger.distance > 60 then return end 
        if trigger.creator.friend then return end
        local x,y,z = trigger.position()
        draw:SetColor(255, 1, 1, 169)
        draw:Outline(x,y,z,10)
    end)
end)

awful.Draw(function(draw)
    if not settings.drawings then return end
    awful.triggers.loop(function(trigger)
        if trigger.id ~= 389813 then return end --DH FEAR--
        if trigger.distance > 60 then return end 
        if trigger.creator.friend then return end
        local x,y,z = trigger.position()
        draw:SetColor(255, 1, 1, 169)
        draw:Outline(x,y,z,8)
    end)
end)

awful.Draw(function(draw)
    if not settings.drawings then return end
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

awful.Draw(function(draw)
    if not settings.drawings then return end
    awful.group.loop(function(unit)
        if select(2,GetInstanceInfo()) == "arena" then
        if unit.distance > 50 then return end
        local x, y, z = unit.position()
        if unit.class == "Druid" then draw:SetColor(255, 140, 0, 255) end
        if unit.class == "Rogue" then draw:SetColor(255, 215, 0, 255) end
        if unit.class == "Hunter" then draw:SetColor(0, 100, 0, 255) end
        if unit.class == "Warrior" then draw:SetColor(139, 71, 38, 255) end
        if unit.class == "Paladin" then draw:SetColor(255, 20, 147, 255) end
        if unit.class == "Monk" then draw:SetColor(0, 255, 127, 255) end
        if unit.class == "Priest" then draw:SetColor(140, 140, 140, 255) end
        if unit.class == "Mage" then draw:SetColor(99, 184, 255, 255) end
        if unit.class == "Shaman" then draw:SetColor(0, 0, 255, 255) end
        if unit.class == "Warlock" then draw:SetColor(106, 90, 205, 255) end
        if unit.class == "Death Knight" then draw:SetColor(255, 0, 0, 255) end
        if unit.class == "Demon Hunter" then draw:SetColor(76, 0, 153, 255) end
        if unit.class == "Evoker" then draw:SetColor(8, 87, 75, 255) end
        draw:Outline(x, y, z, 2)
        end
    end)
end)

--drawings to heal--
awful.Draw(function(draw)
    if not settings.drawings then return end
    if select(2,GetInstanceInfo()) == "arena" then
    local px, py, pz = player.position()
    if healer.dead then return end
    if healer.exists then
      local hx, hy, hz = healer.position()
      if (not healer.los) or healer.distanceLiteral > 40 then
          draw:SetColor(draw.colors.red)
          draw:Line(px, py, pz, hx, hy, hz, 3)
      end
     end
    end
  end)

  awful.Draw(function(draw)
    if not settings.drawings then return end
    if select(2,GetInstanceInfo()) == "arena" then
    local px, py, pz = player.position()
    if healer.dead then return end
    if healer.exists then
      local hx, hy, hz = healer.position()
      if (not healer.los) or healer.distanceLiteral < 40 then
          draw:SetColor(draw.colors.green)
          draw:Line(px, py, pz, hx, hy, hz, 3)
      end
     end
    end
  end)


---Spell List---

--forms--

awful.Populate({
    moonkin = awful.Spell(24858, { ignoreChanneling = true, ignoreFacing = true, ignoreCasting = false }),
    bear = awful.Spell(5487, { ignoreChanneling = true, ignoreFacing = true }),
    cat = awful.Spell(768, { ignoreChanneling = true, ignoreFacing = true }),
    travel = awful.Spell(783, { ignoreChanneling = true, ignoreFacing = true }),
    travelRoots = awful.Spell(24858, { ignoreChanneling = true, ignoreFacing = true }),
}, balance, getfenv(1))

--DMG--

awful.Populate({
    moonfire = awful.Spell(8921, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    sunfire = awful.Spell(93402, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    starsurge = awful.Spell(78674, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }),
    wrath = awful.Spell(190984, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }),
    starfire = awful.Spell(194153, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }),
    stellarflare = awful.Spell(202347, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    starfall = awful.Spell(191034, { damage = "magic", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
    mushroom = awful.Spell(88747, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    furyofelune = awful.Spell(202770, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    incarn = awful.Spell(390414, { diameter = 2, offsetMin = 0, offsetMax = 0, }),
    forcofnature = awful.Spell(205636, { diameter = 5, offsetMin = 1, offsetMax = 3, }),
    newmoon = awful.Spell(274281, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false, ignoreMoving = false }),
    halfmoon = awful.Spell(274282, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false, ignoreMoving = false }),
    fullmoon = awful.Spell(274283, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false, ignoreMoving = false }),
}, balance, getfenv(1))

--CDS--

awful.Populate({
    astralcommu = awful.Spell(202359, { effect = "magic", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
    warriorelune = awful.Spell(202425, { effect = "magic", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
    stamproar = awful.Spell(106898, { ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
    trollracial = awful.Spell(26297, { effect = "magic", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
}, balance, getfenv(1))

--HEAL + DEFS + Buffs--

awful.Populate({
    regrowth = awful.Spell(8936, { heal = true, ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    barkskin = awful.Spell(22812, { ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    frenzireg = awful.Spell(22842, { ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    renewal = awful.Spell(108238, { ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    wildcharge = awful.Spell(102383, { ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }), --disengange--
    wildchargetrap = awful.Spell(102401, { ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }), --disengange--
    prowl = awful.Spell(5215, { ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    markofthewild = awful.Spell(1126, { ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    dash = awful.Spell(1850, { ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    thorns = awful.Spell(305497, { effect = "magic", ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    faeriedisarm = awful.Spell(209749, { damage = "magic", ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    hotw = awful.Spell(319454, { effect = "magic", ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    natureVigil= awful.Spell(124974, { effect = "magic" }),
    shadowmeld = awful.Spell(58984, { ignoreChanneling = false, ignoreCasting = true }), 
    removeCorruption = awful.Spell(2782, { ignoreFacing = true, ignoreMoving = true, ignoreChanneling = false }),
}, balance, getfenv(1))

awful.Populate({
    mangle = awful.Spell(33917, { damage = "physical", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
    swipe = awful.Spell(213771, { damage = "physical", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
    ironfur = awful.Spell(33917, { ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
}, balance, getfenv(1))

--CCs--

awful.Populate({
    cyclone = awful.Spell(33786, { damage = "magic", cc = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true, ignoreMoving = true }),
    cycloneHealer = awful.Spell(33786, { damage = "magic", cc = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true, ignoreMoving = true }),
    cycloneauto = awful.Spell(33786, { damage = "magic", cc = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true, ignoreMoving = true }),
    bashHealer = awful.Spell(5211, { damage = "physical", cc = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }),
    bash = awful.Spell(5211, { damage = "physical", cc = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }),
    moonFireGrounding = awful.Spell(8921, { ignoreLoS = false, ignoreMoving = true, ignoreFacing = true, ignoreChanneling = false }),
    incapRoar = awful.Spell(99, { damage = "magic", cc = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    incapRoarHealer = awful.Spell(99, { damage = "magic", cc = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    solarbeam = awful.Spell(78675, { effect = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    entanglingRoot = awful.Spell(339, { damage = "magic", cc = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    massroot = awful.Spell(102359, { damage = "magic", cc = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    typhoon = awful.Spell(132469, { damage = "magic", cc = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }), --23y in front of me--
}, balance, getfenv(1))

--- shadowmeld stuff ---

local ccShadowmeld = { 360806, 5782, 20066, 33786, 605, } --sleep walk, fear, repentance, cyclone, mindcontrol--

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
    self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
end)

function f:COMBAT_LOG_EVENT_UNFILTERED(...)
    local ets, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, _, spellID, spName, _, ext1, ext2, ext3 = ...
    local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHandfHand
    if subEvent == "SPELL_CAST_SUCCESS" then
        if not settings.automeld then return end
        if spellID == 6789 or spellID == 107570 or spellID == 116858 or spellID == 199786 then  --coil, bolt, chaosbolt, glacial spike--
            local sourceUnit = awful.GetObjectWithGUID(sourceGUID)
            if sourceUnit.dist < 10 then return end
            if destGUID == player.guid then
                shadowmeld:Cast({ stopMoving = true })
            end
        end
    end
end

-- awful.addEventCallback(function(info, event, source, dest)
--     local ets,subEvent,_,sourceGUID,sourceName,sourceFlags,sourceRaidFlags,destGUID,destName,destFlags,destRaidFlags,spellID,spellName = unpack(info)
--     if subEvent == "SPELL_CAST_SUCCESS" then
--         if not settings.automeld then return end
--         if dest.isUnit(player) then
--             if spellID == 6789 or spellID == 107570 or spellID == 116858 or spellID == 199786 then --coil, bolt, chaosbolt, glacial spike,--
--             if source.dist < 8 then return end
--                 shadowmeld:Cast({ stopMoving = true })
--             end
--         end
--     end
-- end)

shadowmeld:Callback("incomingcc", function(spell)
    if not settings.automeld then return end
    awful.enemies.loop(function(enemy)
    if enemy.class == "Warrior" then return end --if enemy is a warrior, hold meld for bolt--
    if not enemy.casting then return end
    if not enemy.castTarget.isUnit(player) then return end
    if not enemy.los then return end
        if player.ddr == 1 then
            if tContains(ccShadowmeld, enemy.castID) and enemy.castRemains > 1 then return end
            if tContains(ccShadowmeld, enemy.castID) and enemy.castRemains < awful.buffer + 0.3 then
            return shadowmeld:Cast({ stopMoving = true }) and awful.alert({ message = awful.colors.red.. "inc CC", texture = 58984, duration = 2 })
            end
        end
    end)
end)

shadowmeld:Callback("verylowhp", function(spell)
    if not settings.automeld then return end
    if player.buff(232707) then return end  --ray--
    awful.enemies.loop(function(enemy)
    if enemy.class == "Warrior" then return end --if enemy is a warrior, hold meld for bolt--
        if player.hp < 15 then
        return shadowmeld:Cast({ stopMoving = true }) and awful.alert({ message = awful.colors.red.. "low hp", texture = 58984, duration = 2 })
        end
    end)
end)

---cmds---

local moonkinOutofBear = NewSpell(24858)

moonkinOutofBear:Callback(function(spell)
    if player.buff(24858) then return end --moonkin--
    return spell:Cast(player)
end)

local bursti = false
local beartime = false
local ccheal = false
local cchealtwo = false
local ccoff = false

local cancelform = false 
local moonkinform = false

-- switching out of form when cancelform = true--
cmd:New(function(msg)
    if cancelform == true then
    cancelform = not cancelform 
    if GetShapeshiftForm() ~= 0 then CancelShapeshiftForm() end
    end
end)

-- switching into moonkin when moonkinform = true--
cmd:New(function(msg)
    if moonkinform == true then
    moonkinform = not moonkinform
    if GetShapeshiftForm() ~= 0 then moonkinOutofBear() end
    end
end)

--disabling normal burst macro ---

cmd:New(function(msg)
    if msg == "burst" then
        burst = not burst
        and awful.alert({ message = awful.colors.red.. "Please use /saj bursti macro and not /saj burst", texture = 135727, duration = awful.tickRate * 2, duration = 9 })
    end
end)

-----burst----

cmd:New(function(msg)
    if msg == "bursti" then
        bursti = not bursti
        beartime = false
        --ccoff = false
        ccheal = false
    end
end)

------ beartime-----

cmd:New(function(msg)
    if msg == "beartime" then
        beartime = not beartime
        bursti = false
        ccoff = false
        ccheal = false
        cchealtwo = false
        traveltime = false 
        moonkinform = true
    end
end)

---cc enemy healer----

cmd:New(function(msg)
    if msg == "ccheal" then
        ccheal = not ccheal
        bursti = false
        ccoff = false
        beartime = false
        cchealtwo = false
    end
end)

---cc enemy healer and doing other stuff meanwihle---
cmd:New(function(msg)
    if msg == "cchealtwo" then
        cchealtwo = not cchealtwo
        ccoff = false
        beartime = false
        ccheal = false
    end
end)

----cc off dps-----

cmd:New(function(msg)
    if msg == "ccoff" then
        ccoff = not ccoff
        ccheal = false
        beartime = false
        cchealtwo = false
    end
end)

--travelform stick--
cmd:New(function(msg)
    if msg == "traveltime" then
        traveltime = not traveltime
        beartime = false
    end
end)

--- TABLES ---

local BigDef = { 
    33206, --Pain Suppression
    81782, --Dome
    102342, --Ironbark
    47788, --Guardian Spirit
    232707, --Ray of Hope
    116849, --cocoon
    1022, --BOP
    6940, --SAC
    325174, --link totem buff
    363534, --rewind prevoker--
    357170, --time dilation--
    196718, --darkness--
    209426, --darkness#2--
    61336, --survival instincts
}

local noPanic = { 
    642, --bubble
    186265, --turtle--
    47585, --dispersion--
    125174, --karma--
    45438, --iceblock--
    232707, --ray
    342246, --alter time
    47788, --guardian spirit
    204018, --spellwarding
    116849, --cocoon
    409293, --burrow
    240133, --iceblock#2--
    11327, --vannish--
    114893, --bulwark totem--
 }



--- totem stomps --

local stompTotems = { 5925, 105427, 5913, 53006, 179867 } --grounding, skyfury, tremor, link, static, capatotem --
local bigTotems = { 59764, 101398, 119052, 107110, 179867, 61245 } --healing tide, psyfiend, warbanner, observer NEW, static totem--
local bigPets = { 101398, 119052, 107110 }  --psyfiend, warbanner, observer--

moonfire:Callback("smalltotems", function(spell)
    if not settings.totemstomps then return end
    awful.totems.stomp(function(totem, uptime)
    if uptime < 0.3 then return end
    if not totem.los then return end
    if player.buff(5215) then return end --prowl---
    if player.buff(5487) then return end --bear---
        if tContains(stompTotems, totem.id) then
            --return spell:Cast(totem) and awful.alert({ message = awful.colors.yellow.. "Totemstomp", texture = spell.id, duration = 1 })
            if spell:Cast(totem) then 
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Totemstomp", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)

starsurge:Callback("bigtotems", function(spell)
    if not settings.totemstomps then return end
    awful.totems.stomp(function(totem, uptime)
    if uptime < 0.3 then return end
    if not totem.los then return end
    if player.buff(5215) then return end --prowl---
    if player.buff(5487) then return end --bear---
    if target.hp < 20 then return end 
        if tContains(bigTotems, totem.id) then
        --return spell:Cast(totem) and awful.alert({ message = awful.colors.yellow.. "Starsurge Big Totem", texture = spell.id, duration = 1 })
            if spell:Cast(totem) then 
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Totemstomp", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)

starsurge:Callback("bigpets", function(spell)
    if not settings.totemstomps then return end
    awful.enemyPets.loop(function(pet, uptime) 
    if uptime < 0.3 then return end
    if not pet.los then return end
    if player.buff(5215) then return end --prowl---
    if player.buff(5487) then return end --bear---
    if target.hp < 20 then return end 
        if tContains(bigPets, pet.id) then
        --return spell:Cast(pet) and awful.alert({ message = awful.colors.yellow.. "Starsurge Stomp", texture = spell.id, duration = 1 })
            if spell:Cast(pet) then 
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Totemstomp", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)

starfire:Callback("bigpets", function(spell)
    if not settings.totemstomps then return end
    awful.enemyPets.loop(function(pet, uptime) 
    if uptime < 0.3 then return end
    if not pet.los then return end
    if player.buff(5215) then return end --prowl---
    if player.buff(5487) then return end --bear---
    if target.hp < 20 then return end 
        if tContains(bigPets, pet.id) then
        --return spell:Cast(pet) and awful.alert({ message = awful.colors.yellow.. "Starfire Stomp", texture = spell.id, duration = 1 })
            if spell:Cast(totem) then 
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Totemstomp", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)


--- stances ---

moonkin:Callback(function(spell)
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if player.buff(24858) then return end --moonkin--
    if player.buff(768) then return end --cat--
    return spell:Cast(player)
end)

---reflect---

moonfire:Callback("reflecttarget", function(spell)
    if target.class ~= "Warrior" then return end -- if not enemy isn't a Warrior
    if player.hp < 30 then return end --so we dont kill us--
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if target.buff(212295) then return end --netherward--
    if target.dead then return end
    if target.bcc then return end
    if target.cc then return end
    if target.dist > moonfire.range then return end
    if target.friendly then return end
    if target.los then
        if target.buff(23920) then --spell reflect--
            if player.casting then 
                SpellStopCasting()
                SpellStopCasting()
            end 
        --return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Moonfire reflect", texture = spell.id, duration = 1 })
            if spell:Cast() then 
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Reflect", texture = spell.id, duration = 0.5 }) end
            end 
        end
    end
end)

moonfire:Callback("reflectccoff", function(spell)
    if ccoff then
        awful.enemies.loop(function(enemy)
            if enemy.class ~= "Warrior" then return end -- if not enemy is a Warrior
            if player.hp < 30 then return end --so we dont kill us--
            if player.buff(5487) then return end --bear---
            if player.buff(5215) then return end --prowl---
            if enemy.buff(212295) then return end --netherward--
            if not player.castTarget.isUnit(enemy) then return end --only if we are really cloning the off target in this case warrior--
            if enemy.bcc then return end
            if enemy.cc then return end
            if enemy.dist > moonfire.range then return end
            if enemy.los then
                if enemy.buff(23920) then --spell reflect--
                    if player.casting then 
                        SpellStopCasting()
                        SpellStopCasting()
                    end 
                --return spell:Cast(enemy) and awful.alert({ message = awful.colors.yellow.. "Moonfire reflect", texture = spell.id, duration = 1 })
                    if spell:Cast(enemy) then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Moonfire reflect", texture = spell.id, duration = 1 }) end
                    end 
                end
            end
        end)
    end
end)

---DMG----

local immuneBuffs = { 
    212295, --netherward
    --48707, --ams
    47585, --dispersion
    --23920, --reflect
    125174, --karma
    409293, --burrow
    642, --bubble
    204018, --spellwarding
    45438, --iceblock--
    186265, --turtle--
    33786, --cyclone
    353319, --monk revival 
    290049, --iceblock
    283627, --2. bubblle?
}

moonfire:Callback("target", function(spell)
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if target.buff(212295) then return end --netherward--
    if target.dead then return end
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    if target.bcc then return end
    if target.dist > moonfire.range then return end
    if target.friendly then return end
    if target.los then
        if target.debuffRemains(164812, player) < 2 then --moonfire debuff--
            if spell:Cast(target) then 
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Moonfire target", texture = spell.id, duration = 1 }) end 
            end 
        end
    end
end)

moonfire:Callback("movingtarget", function(spell)
    --if not settings.castwhilemoving then return end
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if target.buff(212295) then return end --netherward--
    if target.dead then return end
    if target.bcc then return end
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    if target.dist > moonfire.range then return end
    if target.friendly then return end
    if player.moving then
        if target.los then
            if target.debuffRemains(164812, player) < 10 then --moonfire debuff--
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Moonfire target", texture = spell.id, duration = 1 }) end 
                end 
            end
        end
    end
end)

moonfire:Callback("spread", function(spell)
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    awful.enemies.loop(function(enemy)
        if not enemy.isPlayer then return end
        if enemy.buff(212295) then return end  --netherward--
        if enemy.dead then return end
        if enemy.immuneMagicDamage then return end 
        if enemy.bcc then return end
        if enemy.cc then return end
        if enemy.dist > moonfire.range then return end
        if enemy.debuff(164812, player) then return end --moonfire debuff--
        if enemy.los then
            if enemy.debuffRemains(164812, player) < 2 then
                if spell:Cast(enemy) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Moonfire spread", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end)
end)

moonfire:Callback("movingspread", function(spell)
    --if not settings.castwhilemoving then return end
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    awful.enemies.loop(function(enemy)
        if not enemy.isPlayer then return end
        if enemy.buff(212295) then return end  --netherward--
        if enemy.dead then return end
        if enemy.bcc then return end
        if enemy.cc then return end
        if enemy.immuneMagicDamage then return end 
        if enemy.dist > moonfire.range then return end
        if enemy.debuff(164812, player) then return end --moonfire debuff--
        if player.moving then
            if enemy.los then
                if enemy.debuffRemains(164812, player) < 8 then
                    if spell:Cast(enemy) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Moonfire spread (we moving)", texture = spell.id, duration = 1 }) end
                    end 
                end
            end
        end
    end)
end)

local dotBlacklist = { 
    [60849] = true, -- jade serpent status
    [135816] = true, -- Vilefiend
    [98035] = true, -- Dreadstalkers
    [55659] = true, -- Wild Imps
}

moonfire:Callback("spreadpets", function(spell)
    if select(2,GetInstanceInfo()) == "pvp" or select(2,GetInstanceInfo()) == "arena" then --in bg or arena--
        awful.enemyPets.loop(function(pet)
        if dotBlacklist[pet.id] then return end
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if pet.dist > moonfire.range then return end
        if pet.debuff(164812, player) then return end --moonfire debuff--
            if pet.los then
                if spell:Cast(pet) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Spread Dots Pets", texture = spell.id, duration = 1 }) end
                end 
            end
        end)
    end
end)


sunfire:Callback("target", function(spell)
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if target.buff(212295) then return end --netherward--
    if target.dead then return end
    if target.bcc then return end
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    if target.dist > sunfire.range then return end
    if target.friendly then return end
    if target.los then
        if target.debuffRemains(164815, player) < 2 then --sunfire debuff--
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Sunfire target", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)

sunfire:Callback("movingtarget", function(spell)
    --if not settings.castwhilemoving then return end
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if target.buff(212295) then return end --netherward--
    if target.dead then return end
    if target.bcc then return end
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    if target.dist > sunfire.range then return end
    if target.friendly then return end
    if target.los then
        if player.moving then
            if target.debuffRemains(164815, player) < 10 then --sunfire debuff--
                if spell:Cast(target) then 
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Sunfire target (we moving)", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end
end)

sunfire:Callback("spread", function(spell)
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    awful.enemies.loop(function(enemy)
        if not enemy.isPlayer then return end
        if enemy.buff(212295) then return end  --netherward--
        if enemy.dead then return end
        if enemy.bcc then return end
        if enemy.cc then return end
        if enemy.immuneMagicDamage then return end 
        if enemy.dist > sunfire.range then return end
        if enemy.debuff(164815, player) then return end --sunfire debuff--
        if enemy.los then
            if enemy.debuffRemains(164815, player) < 2 then --sunfire debuff--
                if spell:Cast(enemy) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Sunfire spread", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end)
end)

sunfire:Callback("movingspread", function(spell)
   -- if not settings.castwhilemoving then return end
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    awful.enemies.loop(function(enemy)
        if not enemy.isPlayer then return end
        if enemy.buff(212295) then return end  --netherward--
        if enemy.dead then return end
        if enemy.bcc then return end
        if enemy.cc then return end
        if enemy.immuneMagicDamage then return end 
        if enemy.dist > sunfire.range then return end
        if enemy.debuff(164815, player) then return end --sunfire debuff--
        if player.moving then
            if enemy.los then
                if enemy.debuffRemains(164815, player) < 8 then --sunfire debuff--
                    if spell:Cast(enemy) then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Sunfire spread (we movin)", texture = spell.id, duration = 1 }) end
                    end 
                end
            end
        end
    end)
end)

sunfire:Callback("spreadpets", function(spell)
    if select(2,GetInstanceInfo()) == "pvp" or select(2,GetInstanceInfo()) == "arena" then --in bg or arena--
        awful.enemyPets.loop(function(pet)
        if dotBlacklist[pet.id] then return end
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if pet.dist > sunfire.range then return end
        if pet.debuff(164815, player) then return end --sunfire debuff--
            if pet.los then
                if spell:Cast(pet) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Spread Dots Pets", texture = spell.id, duration = 1 }) end
                end 
            end
        end)
    end
end)

mushroom:Callback("target", function(spell)
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if target.buff(212295) then return end --netherward--
    if target.dead then return end
    if target.bcc then return end
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    if target.friendly then return end
    if target.dist > mushroom.range then return end
    if wasCasting[spell.id] then return end
    if target.debuff(81281) then return end --already mushroom on him--
    if player.used(spell.id, 3) then return end --debuff needs 2 secs to apply--
    if not target.debuff(164815, player) then return end --sunfire debuff--
    if not target.debuff(164812, player) then return end --moonfire debuff--
    if mushroom.charges > 2 then
        if target.los then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Shroom", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)

starsurge:Callback("target", function(spell)
    --if settings.mode == "bgmode" then return end --not using it in bgs--
    if player.hasTalent(191034) then return end --we skilled starfall--
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if target.buff(212295) then return end --netherward--
    if target.dead then return end
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > starsurge.range then return end
    --if player.astralPower > 40 then
        if target.los then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Starsurge", texture = spell.id, duration = 1 }) end
            end 
        end
   -- end
end)

starsurge:Callback("targetLowCost", function(spell)
    --if settings.mode == "bgmode" then return end --not using it in bgs--
    if player.hasTalent(191034) then return end --we skilled starfall--
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if target.buff(212295) then return end --netherward--
    if target.dead then return end
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > starsurge.range then return end
    if player.buffStacks(393955) == 2 then
        if target.los then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Starsurge", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)

starsurge:Callback("targetLowHpAOEspec", function(spell)
    --if settings.mode == "bgmode" then return end --not using it in bgs--
    if not player.hasTalent(191034) then return end --we haven't skilled starfall so we dont need it--
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if target.buff(212295) then return end --netherward--
    if target.dead then return end
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > starsurge.range then return end
    if target.hp < 50 and not target.buffFrom(BigDef) then
        if target.los then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Starsurge", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)

starsurge:Callback("procc", function(spell)
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.friendly then return end
        if target.dist > starsurge.range then return end
        if player.buff(394414) then --free starsurge procc-- 
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Big Starsurge", texture = spell.id, duration = 1 }) end
                end 
            end
        end
end)

wrath:Callback("eclipse", function(spell)
    if wasCasting[spell.id] then return end
    if not player.buff(48518) then --not in eclipse--
        if player.cooldown(390414) < 6 then return end --we use incarn soon--
        if player.used(274282, 1) then return end --because we have astral power after--
        if player.used(274283, 1) then return end --because we have astral power after--
        --if newmoon.cd < 1 then return end 
        --if halfmoon.cd < 1 then return end 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        --if wasCasting[spell.id] then return end
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > wrath.range then return end
        --if player.astralPower < 40 then --we have better stuff to do--
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Wrath", texture = spell.id, duration = 1 }) end
                end 
            end
        --end
    end 
end)

starfire:Callback(function(spell)
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if not player.buff(48518) then return end --not in eclipse--
    --if not player.buff(393763) then return end --50% more dmg--
    if not spell:Castable(target) then return end
    if target.buff(212295) then return end --netherward--
    if wasCasting[spell.id] then return end
    if target.dead then return end
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    if target.bcc then return end
    --if target.friendly then return end
    if target.dist > starfire.range then return end
    if player.astralPower < 80 then --we have better stuff to do--
        if target.los then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Starfire", texture = spell.id, duration = 1 })
                end
            end 
        end
    end
end)

wrath:Callback("kicked", function(spell)
    if not player.lockouts.arcane then return end
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if target.buff(212295) then return end --netherward--
    if wasCasting[spell.id] then return end
    if target.dead then return end
    if target.bcc then return end
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    if target.friendly then return end
    if target.dist > wrath.range then return end
    --if player.astralPower < 90 then 
        if player.lockouts.arcane.remains > 0.6 then
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Wrath (we got kicked)", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    --end
end)



starfire:Callback("instantbuff", function(spell)
    if player.buff(157228) then --instant starfire--
        --if player.used(274282, 1) then return end --because we have astral power after--
        --if player.used(274283, 1) then return end --because we have astral power after--
        --if newmoon.cd < 1 then return end 
        --if halfmoon.cd < 1 then return end 
        --if fullmoon.cd < 1 then return end 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        --if not player.buff(48518) then return end --not in eclipse--
        --if not player.buff(393763) then return end --50% more dmg--
        if not spell:Castable(target) then return end
        if target.buff(212295) then return end --netherward--
        if wasCasting[spell.id] then return end
        if target.dead then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.bcc then return end
        --if target.friendly then return end
        if target.dist > starfire.range then return end
        if player.astralPower < 80 then --we have better stuff to do--
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Starfire", texture = spell.id, duration = 1 })
                    end
                end 
            end
        end
    end 
end)

starfire:Callback("kicked", function(spell)
    if player.lockouts.nature and player.lockouts.nature.remains > 0.7 then
        --if player.used(274282, 1) then return end --because we have astral power after--
        --if player.used(274283, 1) then return end --because we have astral power after--
        --if newmoon.cd < 1 then return end 
        --if halfmoon.cd < 1 then return end 
        --if fullmoon.cd < 1 then return end 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        --if not player.buff(48518) then return end --not in eclipse--
        --if not player.buff(393763) then return end --50% more dmg--
        if not spell:Castable(target) then return end
        if target.buff(212295) then return end --netherward--
        if wasCasting[spell.id] then return end
        if target.dead then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.bcc then return end
        --if target.friendly then return end
        if target.dist > starfire.range then return end
        if player.astralPower < 80 then --we have better stuff to do--
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Starfire", texture = spell.id, duration = 1 })
                    end
                end 
            end
        end
    end 
end)


newmoon:Callback(function(spell)
    
        --  local getspellname = GetSpellInfo()
        --  if getspellname == "Full Moon" then return end 

        -- if spell.name == "Full Moon" then return end 

        function getSpellIcon(spellId)
            local _, _1, icon = GetSpellInfo(spellId)
            return icon
        end
        if getSpellIcon(274281) == 1392545 then

            if player.buff(5487) then return end --bear---
            if player.buff(5215) then return end --prowl---
            if not spell:Castable(target) then return end
            --if not player.buff(48518) then return end --not in eclipse--
            --if not player.buff(393763) then return end --50% more dmg--
            if target.buff(212295) then return end --netherward--
            if wasCasting[spell.id] then return end
            if target.dead then return end
            if target.bcc then return end
            if target.buffFrom(immuneBuffs) then return end 
            if target.immuneMagicDamage then return end 
            if target.friendly then return end
            if target.dist > newmoon.range then return end
            if player.astralPower < 80 then --we don't overcap astral power--
                if target.los then
                    if spell:Cast(target) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "New Moon", texture = spell.id, duration = 1 }) end
                    end 
                end
            end

        end
end)

halfmoon:Callback(function(spell)

    function getSpellIcon(spellId)
        local _, _1, icon = GetSpellInfo(spellId)
        return icon
    end
    if getSpellIcon(274282) == 1392543 then

        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if not spell:Castable(target) then return end
        --if not player.buff(48518) then return end --not in eclipse--
        --if not player.buff(393763) then return end --50% more dmg--
        if target.buff(212295) then return end --netherward--
        if wasCasting[spell.id] then return end
        if target.dead then return end
        if target.bcc then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.friendly then return end
        if target.dist > halfmoon.range then return end
        if player.astralPower < 60 then --we don't overcap astral power--
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Half Moon", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end
end)

fullmoon:Callback(function(spell)
    if settings.autofullmoon then return end 

    function getSpellIcon(spellId)
        local _, _1, icon = GetSpellInfo(spellId)
        return icon
    end
    if getSpellIcon(274283) == 1392542 then

        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if not spell:Castable(target) then return end
        --if not player.buff(48518) then return end --not in eclipse--
        --if not player.buff(393763) then return end --50% more dmg--
        if target.buff(212295) then return end --netherward--
        if wasCasting[spell.id] then return end
        if target.dead then return end
        if target.bcc then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.friendly then return end
        if target.hp < 15 then return end --we will starsurge his ass--
        if target.dist > fullmoon.range then return end
        if player.astralPower < 60 then --we don't overcap astral power--
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Full Moon", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end
end)

fullmoon:Callback("precog", function(spell)
   --if not settings.autofullmoonprecog then return end 
    if not player.buff(377362) then return end 

    function getSpellIcon(spellId)
        local _, _1, icon = GetSpellInfo(spellId)
        return icon
    end
    if getSpellIcon(274283) == 1392542 then

        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if not spell:Castable(target) then return end
        --if not player.buff(48518) then return end --not in eclipse--
        --if not player.buff(393763) then return end --50% more dmg--
        if target.buff(212295) then return end --netherward--
        if wasCasting[spell.id] then return end
        if target.dead then return end
        if target.bcc then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.friendly then return end
        if target.hp < 15 then return end --we will starsurge his ass--
        if target.dist > fullmoon.range then return end
        --if player.astralPower < 60 then --we don't overcap astral power--
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Full Moon", texture = spell.id, duration = 1 }) end
                end 
            end
        --end
    end
end)

fullmoon:Callback("burst", function(spell)
    if bursti then

        function getSpellIcon(spellId)
            local _, _1, icon = GetSpellInfo(spellId)
            return icon
        end
        if getSpellIcon(274283) == 1392542 then
    
            if player.buff(5487) then return end --bear---
            if player.buff(5215) then return end --prowl---
            if not spell:Castable(target) then return end
            --if not player.buff(48518) then return end --not in eclipse--
            --if not player.buff(393763) then return end --50% more dmg--
            if target.buff(212295) then return end --netherward--
            if wasCasting[spell.id] then return end
            if target.dead then return end
            if target.bcc then return end
            if target.buffFrom(immuneBuffs) then return end 
            if target.immuneMagicDamage then return end 
            if target.friendly then return end
            if target.dist > fullmoon.range then return end
            if target.hp < 20 then return end --we will starsurge his ass--
            if player.astralPower < 60 then --we don't overcap astral power--
                if target.los then
                    if spell:Cast(target) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Full Moon", texture = spell.id, duration = 1 }) end
                    end 
                end
            end
        end
    end
end)


stellarflare:Callback(function(spell)
    if player.buff(5487) then return end --bear---
    if player.buff(5215) then return end --prowl---
    if not player.buff(48518) then return end --not in eclipse--
    --if target.debuff(202347, player) then return end --already stellar on him--
    if target.buff(212295) then return end --netherward--
    if wasCasting[spell.id] then return end
    if target.dead then return end
    if target.bcc then return end
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    if target.friendly then return end
    if target.dist > stellarflare.range then return end
    --if player.astralPower < 40 then --we have better stuff to do--
        if target.los then
            if target.debuffRemains(202347, player) < 2 then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Stellar Flare", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    --end
end)

starfall:Callback(function(spell)
    --if settings.mode == "bgmode" then --not using it in bgs--
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        --if not player.buff(48518) then return end --not in eclipse--
        if not player.combat then return end
        if allEnemies.around(player, 45) >= 1 then
            if spell:Cast() then
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Starfall", texture = spell.id, duration = 1 }) end
            end 
        end
     --end
end)

starsurge:Callback("bgmode", function(spell)
    if settings.mode == "bgmode" then --not using it in bgs--
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.friendly then return end
        if target.dist > starsurge.range then return end
        if player.astralPower > 60 then
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Starsurge", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end
end)

---talent 393944 chance to make starsurge and starfall free

starsurge:Callback("bgfreeprocc", function(spell)
    --if settings.mode == "bgmode" then --not using it in bgs--
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.friendly then return end
        if target.dist > starsurge.range then return end
        if player.buff(393944) then --free starsurge--
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Starsurge Procc", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    --end
end)

---talent 393944 chance to make starfall free 

starfall:Callback("bgfreeprocc", function(spell)
    --if settings.mode == "bgmode" then --not using it in bgs--
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if not player.combat then return end
        if player.buff(393942) then
        if not target.debuff() then return end 
            if allEnemies.around(player, 45) >= 1 then
                if spell:Cast() then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Starfall Procc", texture = spell.id, duration = 1 }) end
                end 
            end
        end
     --end
end)

--- Burst ---

moonkin:Callback("bursti", function(spell)
    if bursti then
        if player.buff(24858) then return end --moonkin--
        return spell:Cast(player)
    end
end)

solarbeam:Callback("burst", function(spell)
    if not settings.autorootbeamburst then return end
    if bursti then
        if enemyHealer.dist > 35 then return end --massroot range has only 35--
        --if enemyHealer.class == "Druid" then return end --if not druid--
        if enemyHealer.casting8 then return end --testen, kickt nicht in immunities--
        if enemyHealer.stun and enemyHealer.stunRemains > 1 then return end 
        if not spell:Castable(enemyHealer) then return end --is castable like when he has immunities--
        --if enemyHealer.cc then return end 
        --if enemyHealer.rootDR <= 0.50 then return end --only rooting him when he is on full dr--s
        if enemyHealer.rooted and enemyHealer.los then
            return spell:Cast(enemyHealer) and awful.alert({ message = awful.colors.red.. "Enemy Healer", texture = spell.id, duration = 1 })
        end
    end
end)

massroot:Callback("burst", function(spell)
    if not settings.autorootbeamburst then return end
    if bursti then
        if enemyHealer.dist > massroot.range then return end
        --if enemyHealer.rooted then return end 
        --if enemyHealer.class == "Druid" then return end --if not druid--
        if enemyHealer.casting8 then return end --testen, kickt nicht in immunities--
        if not spell:Castable(enemyHealer) then return end --is castable like when he has immunities--
        if enemyHealer.rootDR <= 0.50 then return end --only rooting him when he is on full dr--
        if solarbeam.cd > 1 then return end --solarbeam not rdy--
        if enemyHealer.los then
            return spell:Cast(enemyHealer) and awful.alert({ message = awful.colors.red.. "Enemy Healer", texture = spell.id, duration = 1 })
        end
    end
end)

typhoon:Callback(function(spell)
    if not settings.autotyphoon then return end 
    awful.enemies.loop(function(enemy)
        if enemy.role ~= "melee" then return end 
        if not spell:Castable(enemy) then return end --is castable like when he has immunities--
        if enemy.rooted then return end 
        if enemy.cds then 
            if enemy.distanceTo(player) <= 14 then 
                if enemy.los then
                    if spell:Cast(enemy, {face = true}) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Typhoon", texture = spell.id, duration = 2 }) end
                    end 
                end
            end
        end
    end)
end)

typhoon:Callback("askick", function(spell)
    if not settings.autotyphoon then return end 
    awful.enemies.loop(function(enemy)
        if not spell:Castable(enemyHealer) then return end --is castable like when he has immunities--
        if enemyHealer.casting8 then return end --testen, kickt nicht in immunities--
        if enemyHealer.debuff(81261) then return end --solar beam on him--
        if enemyHealer.rooted then return end 
        if enemy.hp < 60 then
            if enemyHealer.distanceTo(player) <= 20 then 
                if enemyHealer.los and enemyHealer.casting then
                    if spell:Cast(enemyHealer, {face = true}) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Typhoon as kick", texture = spell.id, duration = 2 }) end
                    end 
                end
            end
        end
    end)
end)

moonfire:Callback("burst", function(spell)
    if bursti then
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        --if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.dist > moonfire.range then return end
        if target.friendly then return end
        if target.los then
            if target.debuffRemains(164812, player) < 4 then --moonfire debuff--
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Moonfire", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end
end)

sunfire:Callback("burst", function(spell)
    if bursti then
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        --if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.dist > moonfire.range then return end
        if target.friendly then return end
        if target.los then
            if target.debuffRemains(164815, player) < 4 then --moonfire debuff--
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Sunfire", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end
end)

mushroom:Callback("burst", function(spell)
    if bursti then
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.debuff(393957) then return end  --waning twilight--
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        --if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.dist > mushroom.range then return end
        if wasCasting[spell.id] then return end
        if player.used(spell.id, 3) then return end --debuff needs 2 secs to apply--
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        if target.debuffRemains(81281) < 2.5 then --mushroom debuff--
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Shroom", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end
end)

starsurge:Callback("burst", function(spell)
    if bursti then
        --if settings.mode == "bgmode" then return end --not using it in bgs--
        if player.hasTalent(191034) then return end --we skilled starfall--
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.friendly then return end
        if target.dist > starsurge.range then return end
        --if target.debuff(393957) then  --waning twilight--
            if target.los then
                if spell:Cast(target) then 
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Starsurge", texture = spell.id, duration = 1 }) end
                end 
            end
        --end
    end
end)

furyofelune:Callback("burst", function(spell)
    if bursti then
        if player.cooldown(390414) > 1 and player.cooldown(390414) < 11 then return end  
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.dead then return end
        if target.bcc then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.friendly then return end
        if target.dist > furyofelune.range then return end
        --if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        if target.los then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Fury of Elune", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)

forcofnature:Callback("burst", function(spell)
    if bursti then
        if player.cooldown(390414) > 1 and player.cooldown(390414) < 11 then return end  
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.dead then return end
        --if target.bcc then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.friendly then return end
        if target.dist > 40 then return end
        --if not target.debuff(164815, player) then return end --sunfire debuff--
        --if not target.debuff(164812, player) then return end --moonfire debuff--
        if target.los then
            if spell:AoECast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Fury of Elune", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)


incarn:Callback("burst", function(spell)
    if bursti then
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.dead then return end
        --if target.bcc then return end
        --if target.friendly then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.dist > 40 then return end
        if target.friendly then return end 
        --if not target.debuff(164815, player) then return end --sunfire debuff--
        --if not target.debuff(164812, player) then return end --moonfire debuff--
        if target.los then
            --if spell:Cast(player) then
            if spell:AoECast(target) then 
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Incarn", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)

warriorelune:Callback(function(spell)
    if bursti then
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if player.buff(394414) then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.distance > 40 then return end --incarn hat 40m--
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        --if not target.debuff(393957, player) then return end --dmg increase debuff--
        if player.combat then 
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Warrior of Elune", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)

astralcommu:Callback(function(spell)
    if bursti then
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if player.buff(394414) then return end
        if not player.hasTalent(400636) then return end --astral commu talent--
        if target.distance > 40 then return end --incarn hat 40m--
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        --if not target.debuff(393957, player) then return end --dmg increase debuff--
        if player.astralPower < 35 then
            if player.combat then 
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Astral Communion", texture = spell.id, duration = 1 }) end
                end
            end 
        end
    end
end)

starfire:Callback("warriorbuff", function(spell)
    if bursti then
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.friendly then return end
        if target.dist > starfire.range then return end
        if player.buff(202425) then --free starfire procc--
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Instant Starfire", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end
end)

trollracial:Callback("burst", function(spell)
    if bursti then
        if target.friendly then return end
        if player.combat then
            if target.distance < 45 then 
                if trollracial.known then
                return spell:Cast(player) --and awful.alert({ message = awful.colors.yellow.. "Troll Racial", texture = spell.id, duration = 1 })
                end
            end
        end
    end
end)

frenzireg:Callback(function(spell)
    if player.buff(61336) then return end --survival instincts up on us--
    awful.enemies.loop(function(enemy)
        if player.buff(22842) then return end --already frenzi activated--
        if not player.buff(5487) then return end --bear---
        --if not player.debuff(382912) then return end -- only if talented: well-honed instics (autofrenzy) not used yet--
        if wasCasting[spell.id] then return end
        if player.hp < 70 then --if under 60% hp and 10 or more rage--
            if enemy.target.isUnit(player) then --enemy targeting me - enemy.cds and removed has offensive CDs--
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Frenzi", texture = spell.id, duration = 2 }) end
                end 
            end
        end
    end)
end)

frenzireg:Callback("reallow", function(spell)
    awful.enemies.loop(function(enemy)
        --if renewal.cd < 1 then return end --renewal is rdy--
        if player.buff(22842) then return end --already frenzi activated--
        if not player.buff(5487) then return end --bear---
        --if not player.debuff(382912) then return end -- only if talented: well-honed instics (autofrenzy) not used yet--
        if wasCasting[spell.id] then return end
        if player.hp < 40 then --if under 60% hp and 10 or more rage--
            if enemy.target.isUnit(player) then --enemy targeting me - enemy.cds and removed has offensive CDs--
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Frenzi", texture = spell.id, duration = 2 }) end
                end 
            end
        end
    end)
end)

barkskin:Callback("twocds", function(spell)
    if not settings.autobarkskin then return end
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buff(61336) then return end --survival instincts up on us--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if cooldowns > 1 then
        --if healer.cc then
            awful.enemies.loop(function(enemy) 
                if enemy.los and enemy.target.isUnit(player) then
                    if spell:Cast() then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Barkskin", texture = spell.id, duration = 1 }) end
                    end 
                end
            end)
        --end
    end
end)

barkskin:Callback("nobigdefs", function(spell)
    if not settings.autobarkskin then return end
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buff(61336) then return end --survival instincts up on us--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if cooldowns > 0 then
        if healer.cc then
            awful.enemies.loop(function(enemy) 
                if enemy.los and enemy.target.isUnit(player) then
                    if spell:Cast() then 
                        if settings.alertsmodet then awful.alert({ message = awful.colors.red.. "Barkskin", texture = spell.id, duration = 1 }) end
                    end 
                end
            end)
        end
    end
end)

barkskin:Callback("lowhp", function(spell)
    if not settings.autobarkskin then return end
    if player.buff(61336) then return end --survival instincts up on us--
    awful.enemies.loop(function(unit)
        if not player.combat then return end
        if player.buff(396920) then return end --player is drinking--
            if player.hp < 30 then --i am low hp--
                if unit.target.isUnit(player) then ---enemy targeting me---
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Barkskin", texture = 22812, duration = 2 }) end
                    end 
                end
            end
     end)
end)

barkskin:Callback("nohealer", function(spell)
    if not settings.autobarkskin then return end
    if healer.exists then return end 
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buff(61336) then return end --survival instincts up on us--
    local total, melee, ranged, cooldowns = player.v2attackers()
        if cooldowns > 0 or player.stunned then
            awful.enemies.loop(function(enemy) 
                if enemy.los and enemy.target.isUnit(player) then
                    if spell:Cast() then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Barkskin 2s", texture = spell.id, duration = 1 }) end 
                    end 
                end
            end)
        end
end)

hotw:Callback("nohealer", function(spell)
    if healer.exists then return end 
    if not settings.autohotw then return end
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buff(61336) then return end --survival instincts up on us--
    if player.buff(5487) then --bearform--
        local total, melee, ranged, cooldowns = player.v2attackers()
        if cooldowns > 0 or player.hp < 70 then
            --if healer.cc then
                awful.enemies.loop(function(enemy) 
                    if enemy.los and enemy.target.isUnit(player) then
                        if spell:Cast() then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "HOTW", texture = spell.id, duration = 1 }) end
                        end 
                    end
                end)
            --end
        end
    end 
end)

hotw:Callback(function(spell)
    if not settings.autohotw then return end
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buff(61336) then return end --survival instincts up on us--
    if player.buff(5487) then --bearform--
        local total, melee, ranged, cooldowns = player.v2attackers()
        if cooldowns > 0 then
            if healer.cc then
                awful.enemies.loop(function(enemy) 
                    if enemy.los and enemy.target.isUnit(player) then
                        if spell:Cast() then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "HOTW", texture = spell.id, duration = 1 }) end
                        end 
                    end
                end)
            end
        end
    end 
end)

thorns:Callback(function(spell)
    if not settings.autothorns then return end
    awful.enemies.loop(function(unit)
        if not unit.isPlayer then return end 
        if player.castID == 740 then return end --Tranquility cast--
        if player.buff(5215) then return end --prowl---
        if unit.role ~= "melee" then return end --if not unit.role == "meele" then return end  same
        awful.fullGroup.loop(function(friend)
            if not spell:Castable(friend) then return end
            if unit.distanceTo(friend) > 10 then return end --unit is over 10 m away
            if unit.cds and unit.target.isUnit(friend) then ---enemy has offensive CDs and targeting anyone in my group---
                if spell:Cast(friend) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.orange.. "Thorns", texture = spell.id, duration = 2 }) end
                end 
            end
        end)
     end)
end)

faeriedisarm:Callback(function(spell)
    awful.enemies.loop(function(unit)
        if not unit.isPlayer then return end 
        if player.buff(5215) then return end --prowl---
        if unit.role ~= "melee" then return end --if not unit.role == "meele" then return end  same
        if not spell:Castable(unit) then return end
        if unit.buff(227847) then return end --lolstorm, bladestorm--
        awful.fullGroup.loop(function(friend)
            if unit.distanceTo(friend) > 7 then return end --unit is over 10 m away
            if unit.cds and unit.target.isUnit(friend) then ---enemy has offensive CDs and targeting anyone in my group---
                if spell:Cast(unit) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Disarming", texture = spell.id, duration = 2 }) end
                end 
            end
        end)
     end)
end)

renewal:Callback(function(spell)
    if not settings.autorenewal then return end
    if player.castID == 740 then return end --Tranquility cast--
    if player.buff(5215) then return end --prowl---
    if player.debuff(382912) then --well-honed instics (autofrenzy) not used yet--
        if player.hp < 30 then
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.orange.. "Renewal", texture = spell.id, duration = 2 }) end
            end 
        end
    end
end)

local battleMaster = awful.Item(205781)
battleMaster:Update(function(item)
    if not settings.bmtrinket then return end
    if not battleMaster.equipped then return end
    if not item:Usable(player) then return end
    if player.hp <= settings.bmtrinket then
      return item:Use() and awful.alert({ message = awful.colors.orange.. "BM", texture = 5512, duration = 1 })
    end
end)

local medalTrinket = awful.Item{209764, 209346}

medalTrinket:Update(function(item)
    if player.cc then
    return item:Use() and awful.alert({ message = awful.colors.purple.. "Trinket", texture = 205779, duration = 1 })
    end
end)

local healthStone = awful.Item(5512)
healthStone:Update(function(item)
    if not item:Usable(player) then return end
    if player.hp <= settings.healthstoneHP then
      return item:Use() and awful.alert({ message = awful.colors.orange.. "HS", texture = 5512, duration = 1 })
    end
end)

local healthstone = awful.NewItem(5512)

-- local checked_for_hs = 0
-- function healthstone:grab()
--     if awful.time - checked_for_hs < 1 + bin(not awful.prep) * 6 then return end
--     if self.charges == 3 then return end
--     if player.casting or player.channeling then return end
--     if awful.GetNumFreeBagSlots() ~= nil then 
--       if awful.GetNumFreeBagSlots() == 0 then
--         checked_for_hs = awful.time
--         return
--       end
--     end
--     local soulWell = {
--         [303148] = true, -- soulwell
--     }
--     awful.objects.loop(function(obj)
--         if not soulWell[obj.id] then return end
--         if obj.creator.enemy then return end
--         if obj.dist > 5 then
--             awful.alert("Healthstone available")
--         end
--         if obj.dist > 5 then return end
--         obj:interact()
--     end)
--     checked_for_hs = awful.time
-- end

local medalTrinketauto = awful.Item{209764, 209346}
medalTrinketauto:Update(function(item)
    if not settings.autotrinketsmart then return end 
    if not item:Usable(player) then return end
        if healer.cc and healer.ccRemains > 2 then
            if player.stunned and player.stunRemains > 2 then
            --if player.cc and player.ccRemains > 2 then 
            return item:Use() and awful.alert({ message = awful.colors.purple.. "Auto Trinket", texture = 205779, duration = 1 })
            end
        end
end)

massroot:Callback("manualbeam", function(spell)
    awful.enemies.loop(function(enemy)
        if enemy.dist > massroot.range then return end
        if enemy.class == "Druid" then return end --if not druid--
        if not spell:Castable(enemy) then return end --is castable like when he has immunities--
        if enemy.rootDR < 0.5 then return end --only rooting him when he is on full dr--
        if enemy.los then
            if enemy.debuff(81261) then --beam--
            return spell:Cast(enemy) and awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 2 })
            end
        end
    end)
end)

--- Beam Kick ---
local kickList = { 5782, 33786, 116858, 2637, 375901, 211015, 210873, 277784, 277778, 269352, 211004, 51514, 28272, 118, 277792, 161354, 277787, 
161355, 161353, 120140, 61305, 61721, 61780, 28271, 82691, 391622, 20066, 605, 113724, 198898, 186723, 32375, 982, 320137, 254418, 8936, 82326, 
209525, 289666, 2061, 283006, 19750, 77472, 199786, 361469, 204437, 227344, 30283, 115175, 191837, 124682, 360806, 357208, 382614, 382731, 382266, 361469, 8004, 355936, 367226, 2060, 64843, 263165, 228260, 
356995, 205021, 404977, 421453, 342938, 316099 }

---channels die von der castbar "weniger" werden, anders wie bei penance wo die castbar auch channeld ist aber der balken "voll" wird--
--soothing mist, penance, essence font, Lasso, Convoke, Dream Breath, Spiritbloom, Sleep Walk, Gotteshymne, Void Torrent, Desintegrate, ray of frost, time skip--
local kickChannels = { 115175, 47540, 191837, 305483, 391528, 355936, 367226, 360806, 64843, 263165, 356995, 205021, 404977 } 

---eben andersherum aber muss noch IDs finden---
local kickChannelsOther = { }

local kickClone = { 33786 }

local noKickthings = { 
    377362, --precog
    209584, --zen tea
    378078, --shaman spirit walker immunity
    363916, --prevoker immunity--
    104773, --unending resolve
    317929, --hpal aura mastery immunity
}

local immuneBuffs = { 
    212295, --netherward
    47585, --dispersion
    23920, --reflect
    125174, --karma
    409293, --burrow
    642, --bubble
    204018, --spellwarding
    45438, --iceblock--
    186265, --turtle--
    33786, --cyclone
    353319, --monk revival 
    116849, --cocoon
    125174, ---karma
    33206, --Pain Suppression
    232707, --Ray of Hope
    6940, --SAC
    363534, --rewind prevoker--
    357170, --time dilation--
    61336, --survival instincts
}


local KickDelay = awful.delay(0.25, 0.35)
local KickDelayCasts = awful.delay(0.15, 0.2)

---low hp kicks-- es geht hier darum wirklich nur in kill windows solar beam zu usen

solarbeam:Callback("casts", function(spell) 
    if not settings.lowbeamkick then return end 
    awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemyHealer) then return end
        if not enemyHealer.casting then return end 
        if enemyHealer.stun and enemyHealer.stunRemains > 1 then return end 
        if enemyHealer.buffFrom(noKickthings) then return end 
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if not tContains(kickList, enemyHealer.castID) then return end
        if enemyHealer.casting then
            if enemyHealer.castRemains < awful.buffer + KickDelayCasts.now then 
                if target.hp < 30 then 
                    if spell:Cast(enemyHealer) then -- 
                        awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id) 
                        return true 
                    end
                end 
            end
        end
    end)
end)

solarbeam:Callback("channels", function(spell) 
    if not settings.lowbeamkick then return end 
    awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemyHealer) then return end
        if enemyHealer.stun and enemyHealer.stunRemains > 1 then return end 
        if not enemyHealer.channeling then return end 
        if enemyHealer.buffFrom(noKickthings) then return end 
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if not tContains(kickList, enemyHealer.channelID) then return end
        if enemyHealer.channeling then
            if enemyHealer.channelTimeComplete > KickDelay.now then 
                if target.hp < 30 then 
                    if spell:Cast(enemyHealer) then -- 
                        awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id) 
                        return true 
                    end
                end 
            end
        end
    end)
end)

---- Auto Shift ---

bear:Callback("kidney", function(spell)
    if not settings.autobear then return end
    if player.sdr < 0.5 then return end --only on full stun--
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buff(5487) then return end --bear---
    awful.enemies.loop(function(unit)
        if unit.class ~= "Rogue" then return end --if not rogue--
        if target.hp < 30 and not target.buffFrom(noPanic) then return end -- our target is low to kill--
        if healer.cc and healer.ccRemains > 1 then--only shift when our healer is in brekable cc--
            if unit.cds and unit.target.isUnit(player) then --and unit.buff(185422) then --or unit.cooldown(408) < 1 then ---enemy has offensive CDs and shadowdance or kidney rdy targeting me---
                awful.alert({ message = awful.colors.red.. "Rogue Go", texture = spell.id, duration = 2 })
                beartime = true 
            end
        end
    end)
end)

bear:Callback("lowhp", function(spell)
    if not settings.autobear then return end
    if not healer.exists then return end 
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buff(5487) then return end --bear---
    awful.enemies.loop(function(unit)
        if target.hp < 30 and not target.buffFrom(noPanic) then return end -- our target is low to kill--
        if healer.cc and healer.ccRemains > 1 then--only shift when our healer is in brekable cc--
            if player.hp <= 50 then --and unit.buff(185422) then --or unit.cooldown(408) < 1 then ---enemy has offensive CDs and shadowdance or kidney rdy targeting me---
                awful.alert({ message = awful.colors.red.. "low hp", texture = spell.id, duration = 2 })
                beartime = true 
            end
        end
    end)
end)

bear:Callback(function(spell)
    if beartime then
        if player.buff(5487) then return end --bear---
        return spell:Cast(player) --and awful.alert({ message = awful.colors.yellow.. "Bear time", texture = spell.id, duration = 1 })
    end
end)

moonkin:Callback("bearOFF", function(spell)
    if not settings.autobear then return end 
    if player.buff(24858) or player.used(24858, 1) then return end --moonkin-
    if beartime == true then return end 
    if player.hp >= 50 then 
        if healer.exists and not healer.cc or not healer.silenced then 
        return spell:Cast(player) and awful.alert({ message = awful.colors.yellow.. "fine", texture = 24858, duration = 1 })
        end 
    end 
end) 

mangle:Callback(function(spell)
    if beartime then
        awful.enemies.loop(function(enemy)
            if enemy.dead then return end
            if enemy.bcc then return end
            --if enemy.cc then return end
            if enemy.friendly then return end
            if enemy.los then
                if enemy.distanceTo(player) <= 10 then
                    if spell:Cast(enemy) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Mangle", texture = spell.id, duration = 1 }) end
                    end 
                end
            end
        end)
    end
end)

--nimmt aktuell zu viel GCDs--
swipe:Callback(function(spell)
    if beartime then
        awful.enemies.loop(function(enemy)
            if wasCasting[spell.id] then return end
            if enemy.dead then return end
            if enemy.bcc then return end
            --if enemy.cc then return end
            if enemy.friendly then return end
            if enemy.los then
                if enemy.distanceTo(player) <= 13 then
                    if spell:Cast(enemy) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.yellow.. "Swipe", texture = spell.id, duration = 1 }) end
                    end 
                end
            end
        end)
    end
end)


ironfur:Callback(function(spell)
    if beartime then
        awful.enemies.loop(function(enemy)
            if not enemy.isPlayer then return end 
            if enemy.class ~= "Meele" then return end -- if not enemy class is a meele
            if not player.buff(5487) then return end --bear---
            if player.buff(192081) then return end --already ironfur up--
            if player.rage >= 60 then -- if over 60 rage, to hold 10 rage for frenzy --
                if enemy.target.isUnit(player) then ---enemy targeting me---
                    if spell:Cast(player) then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.orange.. "Ironfur", texture = 192081, duration = 2 }) end
                    end 
                end
            end
        end)
    end
end)

--- cc heal ---

local groundingTotems = { 204336, 5925, 254416 } --groundings ids--

local noCCThings = { 378464, 642, 186265, 31224, 48707, 45438, 6940, 199448, 213610, 353319, 362486, 236321, 8178, 210256 } 

solarbeam:Callback(function(spell)
    if not settings.autorootbeam then return end
    if ccheal or cchealtwo then
        if enemyHealer.stun and enemyHealer.stunRemains > 1 then return end 
        if enemyHealer.dist > 35 then return end --massroot range has only 35--
        if enemyHealer.buffFrom(noCCThings) then return end 
        --if enemyHealer.class == "Druid" then return end --if not druid--
        if enemyHealer.casting8 then return end --testen, kickt nicht in immunities--
        --if enemyHealer.cc then return end 
        if not spell:Castable(enemyHealer) then return end --is castable like when he has immunities--
        --if enemyHealer.rootDR <= 0.50 then return end --only rooting him when he is on full dr--s
        if enemyHealer.rooted and enemyHealer.los then
            return spell:Cast(enemyHealer) and awful.alert({ message = awful.colors.red.. "Enemy Healer", texture = spell.id, duration = 2 })
        end
    end
end)

massroot:Callback(function(spell)
    if not settings.autorootbeam then return end
    if ccheal or cchealtwo then
        if enemyHealer.dist > massroot.range then return end
        --if enemyHealer.class == "Druid" then return end --if not druid--
        if enemyHealer.casting8 then return end --testen, kickt nicht in immunities--
        if not spell:Castable(enemyHealer) then return end --is castable like when he has immunities--
        if enemyHealer.rootDR < 0.5 then return end --only rooting him when he is on full or half dr--
        --if enemyHealer.cc then return end 
        if solarbeam.cd > 1 then return end --solarbeam not rdy--
        if enemyHealer.los then
            return spell:Cast(enemyHealer) and awful.alert({ message = awful.colors.red.. "Enemy Healer", texture = spell.id, duration = 2 })
        end
    end
end)

incapRoarHealer:Callback(function(spell)
    if ccheal or cchealtwo then
        --awful.enemies.loop(function(enemy)
        if not player.hasTalent(99) then return end --not incapRoar skilled--
        if enemyHealer.cc or enemyHealer.bcc then return end --already in cc--
        if player.used(33786, 1) then return end --cyclone--
        if player.used(1822, 1) then return end --rake stun--
        if player.castID == 740 then return end --Tranquility cast--
        if player.buff(396920) then return end --player is drinking--
        if not enemyHealer.los then return end --enemy is not in sight for casting--
        if enemyHealer.dotted then return end
            if enemyHealer.distanceTo(player) <= 10 then
                if enemyHealer.incapDR == 1 then --only incaproar when FULL idr--
                    if spell:Cast(enemyHealer) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Roar Enemy Healer", texture = 99, duration = 1 }) end
                    end 
                end
            end
        --end)
    end
end)

cycloneHealer:Callback(function(spell)
    if ccheal or cchealtwo then
        --awful.enemies.loop(function(enemy)
        if wasCasting[spell.id] then return end
        --if enemy.role ~= "healer" then return end
        if enemyHealer.dist > cyclone.range then return end
        if enemyHealer.debuff(81261) then return end --he is root-beamed-
        if not enemyHealer.los then return end --enemy is not in sight for casting--
        if enemyHealer.ddr < 0.1 then return end --dont cast cyclone when target is immune or dr--
        if enemyHealer.ddr < 0.5 and enemyHealer.ddrRemains < 10 then return end --dont cast cyclone when target is immune or dr--
        if enemyHealer.ccRemains > 2 or enemyHealer.bccRemains > 2 then return end  --to prevent not ccing already cc'd target--
        if (enemyHealer.ccRemains - buffer) < cyclone.castTimeRaw then
            awful.group.loop(function(group)
                if enemyHealer.debuff(80240) and group.cd(6789) < 1 then return end --havoc debuff on enemy and coil is rdy--
                if spell:Cast(enemyHealer) then 
                    if awful.alert({ message = awful.colors.red.. "Enemy Healer", texture = 33786, duration = 1 }) then
                    return true end
                end
            end) 
        end
    end
end)

bashHealer:Callback(function(spell)
    if ccheal or cchealtwo then
        awful.enemies.loop(function(enemy)
        if not player.hasTalent(5211) then return end --not bash skilled--
        if enemy.cc or enemy.bcc then return end --already in cc--
        if player.used(33786, 1) then return end --cyclone--
        if player.used(1822, 1) then return end --rake stun--
        if enemyHealer.debuff(81261) then return end --he is root-beamed-
        if not enemy.los then return end --enemy is not in sight for casting--
            awful.group.loop(function(group)
            if enemyHealer.debuff(80240) and group.cd(6789) < 1 then return end --havoc debuff on enemy and coil is rdy--
                if enemy.stunDR >= 0.5 and enemy.distance <= 5 then --only stun when half or FULL stun--
                return spell:Cast(enemyHealer) and awful.alert({ message = awful.colors.red.. "Enemy Healer", texture = 5211, duration = 2 })
                end
            end)
        end)
    end
end)

moonkin:Callback("ccheal", function(spell)
    if ccheal or cchealtwo then
        if player.buff(24858) then return end --moonkin--
        return spell:Cast(player)
    end
end)

----- ccoff ----

moonFireGrounding:Callback(function(spell)
    if ccheal or ccoff or cchealtwo then
        awful.totems.stomp(function(totem, uptime)
        --if uptime < 0.3 then return end
        if not totem.los then return end
        if player.castID == 740 then return end --Tranquility cast--
        if player.buff(396920) then return end --player is drinking--
        --if player.buff(5215) then return end --prowl---
        if player.buff(5487) then return end --bear---
        --if player.manaPct < 15 then return end --no totemstomp below 15--
            if tContains(groundingTotems, totem.id) then
                if moonFireGrounding:Cast(totem) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Kill Grounding for CC", texture = 204336, duration = 1 }) end
                end 
            end
        end)
    end
end)

incapRoar:Callback(function(spell)
    if ccoff then
        --awful.enemies.loop(function(enemy)
        if not player.hasTalent(99) then return end --not incapRoar skilled--
        if target.friendly then return end
        if target.cc or target.bcc then return end --already in cc--
        if target.dotted then return end --roar makes no sense, its dotted--
        if player.used(33786, 1) then return end --cyclone--
        if player.used(1822, 1) then return end --rake stun--
        if target.debuff(33786) then return end --don't bash randomly anyone when enemyheal is in cyclone for follow up cc--
        if target.stunned then return end
        if player.castID == 740 then return end --Tranquility cast--
        if player.buff(396920) then return end --player is drinking--
        if not target.los then return end --enemy is not in sight for casting--
            if target.distanceTo(player) <= 10 then
                if target.incapDR == 1 then --only incaproar when FULL idr--
                    if spell:Cast(target) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Roar Enemy Target", texture = 99, duration = 1 }) end
                    end 
                end
            end
        --end)
    end
end)

cyclone:Callback(function(spell)
    if ccoff then
        awful.enemies.loop(function(enemy)
        if enemy.role == "healer" then return end --we don't want to clone heal--
        if wasCasting[spell.id] then return end
        if player.buff(5215) then return end --prowl---
        if player.castID == 740 then return end --Tranquility cast--
        if player.buff(396920) then return end --player is drinking--
        --if enemy.dist > cyclone.range then return end
        if enemy.buff(212295) then return end  --netherward--
        if enemy.buff(227847) then return end  --lolstorm--
        if enemy.ddr < 0.1 then return end --dont cast cyclone when target is immune or dr--
        if enemy.ccRemains > 2 or enemy.bccRemains > 2 then return end --to prevent not ccing already cc'd target--
        if not enemy.los then return end --enemy is not in sight for casting--
            awful.group.loop(function(group)
                if enemy.debuff(80240) and group.cd(6789) < 1 then return end --havoc debuff on enemy and coil is rdy--
                if (enemy.ccRemains - buffer) < cyclone.castTimeRaw then
                    if not player.target.isUnit(enemy) then 
                        if spell:Cast(enemy) then 
                            if awful.alert({ message = awful.colors.red.. "OFF Dps", texture = 33786, duration = 2 }) then
                            return true end
                        end
                    end
                end
            end)
        end)
    end
end)

bash:Callback(function(spell)
    if ccoff then
        awful.enemies.loop(function(enemy)
        if enemy.role == "healer" then return end --we don't want to clone heal--
        if not player.hasTalent(5211) then return end --not bash skilled--
        if enemy.cc or enemy.bcc then return end --already in cc--
        if enemy.buff(227847) then return end  --lolstorm--
        if player.used(33786, 1) then return end --cyclone--
        if player.used(1822, 1) then return end --rake stun--
        if enemy.debuff(33786) then return end --don't bash randomly anyone when enemyheal is in cyclone for follow up cc--
        if enemy.stunned then return end
        if not enemy.los then return end --enemy is not in sight for casting--
            awful.group.loop(function(group)
            if enemy.debuff(80240) and group.cd(6789) < 1 then return end --havoc debuff on enemy and coil is rdy--
                if enemy.meleeRange then
                    if enemy.sdr >= 0.5 and enemy.distance <= 5 then --only stun when half or FULL stun--
                        if not player.target.isUnit(enemy) then 
                        return spell:Cast(enemy) and awful.alert({ message = awful.colors.red.. "Bash OFF Dps", texture = 5211, duration = 2 })
                        end
                    end
                end
            end)
        end)
    end
end)

moonkin:Callback("ccoff", function(spell)
    if ccoff then
        if player.buff(24858) then return end --moonkin--
        return spell:Cast(player)
    end
end)

awful.Draw(function(draw)
    if not settings.drawingscctime then return end
    if ccheal or cchealtwo then
        local x,y,z = player.position()
        draw:SetColor(255, 140, 1, 255)
        draw:Circle(x,y,z,30)
    end
end)

awful.Draw(function(draw)
    if not settings.drawingscctime then return end
    if ccoff then
        local x,y,z = player.position()
        draw:SetColor(255, 140, 1, 255)
        draw:Circle(x,y,z,30)
    end
end)

-- massroot:Callback("pitlord", function(spell)
--     if not settings.automassroot then return end
--     awful.enemyPets.loop(function(pet) 
--         if player.castID == 740 then return end --Tranquility cast--
--         if player.buff(396920) then return end --player is drinking--
--         --if player.buff("Prowl") then return end
--         if pet.name ~= "Pit Lord" then return end
--         if pet.rooted then return end --already rooted--
--         if pet.rootDR <= 0.25 then return end --only rooting him when he is on half or full dr--
--             if pet.los then 
--                 return spell:Cast(pet) and awful.alert({ message = awful.colors.red.. "Rooting Pitlord", texture = 102359, duration = 2 })
--             end
--     end)
-- end)

local vortex = NewSpell(102793, { diameter = 13, offsetMin = 0, offsetMax = 2, })

vortex:Callback("charge", function(spell)
    awful.enemies.loop(function(enemy) 
        if not settings.autovortex then return end
        if player.castID == 740 then return end --Tranquility cast--
        if player.buff(396920) then return end --player is drinking--
        if enemy.dist > vortex.range then return end
        if player.buff(5215) then return end --prowl---
        if player.buff(5487) then return end --bear---
        if enemy.class ~= "Warrior" then return end -- if not meele then dont --
        if not enemy.los then return end
        if enemy.distance > 10 then --makes only sense when war is not already next to me--
            if enemy.target.isUnit(player) and enemy.cds then --war is targeting me w cds--
                if spell:SmartAoE(enemy) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Vortex Warrior", texture = 102793, duration = 2 }) end
                end 
            end
        end
     end)
end)

--our dk bursts--
vortex:Callback("ourDKburst", function(spell)
    awful.group.loop(function(group)
        if not settings.autovortex then return end
        if player.castID == 740 then return end --Tranquility cast--
        if player.buff(396920) then return end --player is drinking--
        if group.dist > vortex.range then return end
        if player.buff(5215) then return end --prowl---
        if player.buff(5487) then return end --bear---
        if group.class2 ~= "DEATHKNIGHT" then return end --only on our dk--
        if not group.los then return end
        if group.used(383269, 4) then --our dk used abo for burst--
            if spell:SmartAoE(group) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Vortex", texture = 102793, duration = 2 }) end
            end 
        end
     end)
end)

-- Vortex on pressure target --
vortex:Callback("lowhp", function(spell)
    awful.enemies.loop(function(enemy)
        if not settings.autovortex then return end
        if player.castID == 740 then return end --Tranquility cast--
        if player.buff(396920) then return end --player is drinking--
        if enemy.dist > vortex.range then return end
        if player.buff(5215) then return end --prowl---
        if player.buff(5487) then return end --bear---
        if not enemy.los then return end
        if not enemy.player then return end
        if enemy.hp < 40 then
            if spell:SmartAoE(enemy) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Vortex", texture = 102793, duration = 2 }) end
            end 
        end
     end)
end)

-- vortex on our smokebomb--
vortex:Callback("ourRogBomb", function(spell)
    awful.group.loop(function(group)
        if not settings.autovortex then return end
        if player.castID == 740 then return end --Tranquility cast--
        if player.buff(396920) then return end --player is drinking--
        if group.dist > vortex.range then return end
        if player.buff(5215) then return end --prowl---
        if player.buff(5487) then return end --bear---
        if group.class2 ~= "ROGUE" then return end --only on our rogue--
        if not group.los then return end
        if group.used(76577, 2) then --our rogue used smoke bomb in the last 1 sec--
            if spell:SmartAoE(group) then 
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Vortex", texture = 102793, duration = 2 }) end
            end 
        end
     end)
end)

vortex:Callback("manualbeam", function(spell)
    if not settings.autovortex then return end
    awful.enemies.loop(function(enemy)
        if enemy.dist > vortex.range then return end
        if not spell:Castable(enemy) then return end --is castable like when he has immunities--
        if enemy.los then
            if enemy.debuff(81261) then --beam--
                if spell:Cast(enemy) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Vortex Beam", texture = spell.id, duration = 2 }) end
                end 
            end
        end
    end)
end)

travelRoots:Callback("noform", function(spell)
    awful.enemies.loop(function(unit)
        if unit.class ~= "Druid" and unit.spec == "Balance" then return end --if vs balance druids--
        if not player.rooted then return end
        if player.debuff(78675) then  --solar beam--
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.orange.. "Shapeshifting Solar Beam", texture = 78675, duration = 2 }) end
            end 
        end
        if player.used(783, 1) then CancelShapeshiftForm() end  --cancel after roots--
    end)
end)

travelRoots:Callback("noformChainsOfIce", function(spell)
    awful.enemies.loop(function(unit)
        --if unit.class2 ~= "DEATHKNIGHT" then return end
        --if not player.slowed then return end
        if player.debuff(45524) then  --chains of ice--
        if wasCasting[spell.id] then return end --to not go into travel accidently, bug--
            awful.fullGroup.loop(function(group)
                --if group.losOf(player) and group.distance < 40 then return end --we don't shift when team is in distance and los--
                if not group.losOf(player) or group.distance < 40 then --not in los or not in range--
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.orange.. "Shapeshifting Chains of Ice", texture = 45524, duration = 2 }) end
                    end 
                end
            end)
        end
    end)
end)

travelRoots:Callback("informChainsOfIce", function(spell)
    awful.enemies.loop(function(unit)
       --if unit.class2 ~= "DEATHKNIGHT" then return end
        --if not player.slowed then return end
        if wasCasting[spell.id] then return end --to not go into travel accidently, bug--
        if not unit.target.isUnit(player) then return end -- we are not target ---
        if player.debuff(45524) then  --chains of ice--
            --awful.fullGroup.loop(function(group)
                --if group.hp > 80 then
                    if player.buff(5487) or player.buff(33891) or player.buff(768) or player.buff(783) then
                    CancelShapeshiftForm() end
                    return awful.alert({ message = awful.colors.orange.. "", texture = 45524, duration = 2 })
                --end
            --end)
        end
    end)
end)

travelRoots:Callback("noformHunterNet", function(spell)
    awful.enemies.loop(function(unit)
        if wasCasting[spell.id] then return end --to not go into travel accidently, bug--
        if player.debuff(212638) then  --hunters net trackers net--
            awful.fullGroup.loop(function(group)
                if group.losOf(player) and group.hp < 60 then return end --we dont swift around when group is getting low--
                return spell:Cast(player) and awful.alert({ message = awful.colors.orange.. "Shapeshifting Net", texture = 212638, duration = 2 })
            end)
        end
    end)
end)

travelRoots:Callback("informHunterNet", function(spell)
    awful.enemies.loop(function(unit)
        if wasCasting[spell.id] then return end --to not go into travel accidently, bug--
        if not unit.target.isUnit(player) then return end -- we are not target ---
        if player.debuff(212638) then --hunters net trackers net--
            if player.buff(5487) or player.buff(24858) or player.buff(768) or player.buff(783) then
            CancelShapeshiftForm() end
            return awful.alert({ message = awful.colors.orange.. "Shapeshifting Net", texture = 212638, duration = 2 })
        end
    end)
end)

-- bear, Moonkin, cat, traven - cancelshape--
travelRoots:Callback("inform", function(spell)
    awful.enemies.loop(function(unit)
        if unit.class ~= "Druid" then return end --if vs balance druids--
        if unit.spec ~= "Balance" then return end
        if not player.rooted then return end
        if player.debuff(78675) then  --solar beam--
            if player.buff(5487) or player.buff(24858) or player.buff(768) or player.buff(783) then
            CancelShapeshiftForm() end
            return awful.alert({ message = awful.colors.orange.. "", texture = 78675, duration = 1 })
        end
    end)
end)

travelRoots:Callback("noformfulldr", function(spell)
    if not player.rooted then return end
    if player.rooted and player.rootRemains > 2 then
        return spell:Cast(player) and awful.alert({ message = awful.colors.orange.. "Shapeshifting Roots", texture = spell.id, duration = 1 })
    end
    if player.used(783, 1) then CancelShapeshiftForm() end  --cancel after roots--
end)

-- bear, moonkin, cat, traven - cancelshape--
travelRoots:Callback("informfulldr", function(spell)
    awful.enemies.loop(function(enemy)
        if not enemy.target.isUnit(player) and enemy.distance < 40 then return end 
        if not player.rooted then return end
        if player.rooted and player.rootRemains > 3 then
            if player.buff(5487) or player.buff(24858) or player.buff(768) or player.buff(783) then
            CancelShapeshiftForm() end
            return awful.alert({ message = awful.colors.orange.. "Shapeshifting Roots", texture = 783, duration = 1 })
        end
    end)
end)

travel:Callback("macro", function(spell)
    if traveltime then
        if player.buff(783) then return end --travel--
        return spell:Cast(player)
    end
end)


stamproar:Callback(function(spell)
   -- if not player.combat then return end
    if not player.rooted then return end
    if player.buff(768) then return end --if for example rooted out of prowl--
    if player.rooted and player.rootRemains > 2 then
        awful.enemies.loop(function(enemy)
            if enemy.distance > 10 then return end -- don't roar randomly --
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.orange.. "Stampeding Roar", texture = 106989, duration = 2 }) end
            end 
        end)
    end
    if player.used(5487, 1) then CancelShapeshiftForm() end  --cancel bear after roots--
end)

local catOpener = NewSpell(1822, { effect = "physical", ignoreLoS = false, ignoreMoving = true, ignoreChanneling = false, ignoreFacing = false })
catOpener:Callback(function(spell)
    awful.enemies.loop(function(enemy) 
        if not player.buff(5215) then return end --prowl---
        if not player.hasTalent(1822) then return end
        --if enemy.role ~= "healer" then return end -- if not the enemy healer--
        if enemy.sdr <= 0.5 then return end --stun only when full stun duration--
        if not enemy.los then return end --enemy is not in sight for opener--
        if enemy.distance <= 5 then 
            if spell:Cast(target) then
                CancelShapeshiftForm()
                --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Rake Opener", texture = 1822, duration = 2 }) and CancelShapeshiftForm() end
            end 
        end
     end)
end)

local innervate = NewSpell(29166, { heal = true, ignoreLoS = false, ignoreMoving = true, ignoreFacing = true, ignoreChanneling = false })

innervate:Callback(function(spell)
    --if not settings.autoinnervate then return end
    if not player.hasTalent(29166) then return end
    if player.buff(5487) then return end --bear--
    if player.buff(768) then return end --cat--
    if healer.cc then return end --our healer is in cc--
    if healer.bcc then return end --our healer is in cc--
    awful.enemies.loop(function(enemy)
        if enemy.target.isUnit(healer) then return end --they go on our heal--
        if enemy.distance > 50 then return end 
        if enemy.cds then
            if spell:Cast(healer) then
                if settings.alertsmode then awful.alert({ message = awful.colors.orange.. "Innervate to Healer", texture = 29166, duration = 1 }) end
            end 
        end
    end)
end)


natureVigil:Callback(function(spell)
    if player.buff(5215) then return end --prowl---
    if player.buff(5487) then return end --bear---
    awful.enemies.loop(function(enemy)
        if enemy.distance > 50 then return end
        if enemy.target.isUnit(player) then return end --not using it when they go on me--
        awful.group.loop(function(group)
            if enemy.target.isUnit(group) then
                if enemy.cds then
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.orange.. "Natures Vigil", texture = 124974, duration = 1 }) end
                    end 
                end
            end
        end)
    end)
end)

-- markofthewild:Callback(function(spell)
--     awful.group.loop(function(group)
--     if player.used(1126, 25) then return end
--     if player.buff(5215) then return end --prowl---
--         if awful.prep then
--         return spell:Cast(group) and awful.alert({ message = awful.colors.orange.. "Buffing Prep", texture = 1126, duration = 5 })
--         end
--     end)
-- end)

markofthewild:Callback(function(spell)
    awful.group.loop(function(group)
    --if player.used(1126, 25) then return end
    if group.buff(1126) then return end --markofwild--
        if awful.prep and awful.prepRemains < 15 then
            if spell:Cast(group) then
                if settings.alertsmode then awful.alert({ message = awful.colors.purple.. "Buffing Prep", texture = 1126, duration = 2 }) end
            end 
        end
    end)
end)

regrowth:Callback("ourgroup", function(spell)
    if settings.mode == "bgmode" then return end --not using it in bgs--
    awful.group.loop(function(friend)
        if not settings.autoregrowth then return end --if UI settings turned off, don't use it--
        if player.buff(5215) then return end --prowl---
        if player.buff(5487) then return end --bear---
        if friend.buff(342246) then return end --alter time--
        if wasCasting[spell.id] then return end
        if player.manaPct < 10 then return end -- do nothing under 10% mana
        if friend.dist > regrowth.range then return end
        if not friend.los then return end --not in sight--
        if friend.hp < 40 then
            if healer.cc or healer.bcc then --our healer is in cc--
                awful.enemies.loop(function(enemy)
                    if enemy.target.isUnit(friend) then
                        if spell:Cast(friend) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.orange.. "Regrowth", texture = 8936, duration = 1 }) end
                        end 
                    end
                end)
            end
        end
    end)
end)

regrowth:Callback("onmeNotLoS", function(spell)
    if settings.mode == "bgmode" then return end --not using it in bgs--
        if not settings.autoregrowth then return end --if UI settings turned off, don't use it--
        if player.buff(5215) then return end --prowl---
        if player.buff(5487) then return end --bear---
        if wasCasting[spell.id] then return end
        if player.manaPct < 10 then return end -- do nothing under 10% mana
        if player.hp < 60 then
            --if healer.cc or healer.bcc then --our healer is in cc--
            awful.enemies.loop(function(enemy)
                if not enemy.isPlayer then return end
                if not enemy.los then
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.orange.. "Regrowth", texture = 8936, duration = 1 }) end
                    end 
                end
            end)
       end
end)

regrowth:Callback("procc", function(spell)
    if not settings.autoregrowth then return end 
        awful.fullGroup.loop(function(friend)
            if player.buff(5487) then return end --bear---
            if player.buff(783) then return end --travel
            if player.buff(768) then return end --cat---
            if friend.buff(342246) then return end --alter time--
            if wasCasting[spell.id] then return end
            if friend.dist > regrowth.range then return end
            local lowest = awful.fullGroup.lowest
            if not spell:Castable(lowest) then return end
            if player.buff(429438) then --procc--
                if lowest.hp < 92 then
                    if spell:Cast(lowest) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Regrowth Procc", texture = spell.id, duration = 1 }) end 
                    end 
                end
            end
        end)
    end)


-- regrowth:Callback("kicked", function(spell)
--     if settings.mode == "bgmode" then return end --not using it in bgs--
--     if not settings.autoregrowth then return end --if UI settings turned off, don't use it--
--     if not player.lockouts.arcane then return end
--     awful.fullGroup.loop(function(friend)
--         if player.buff(5215) then return end --prowl---
--         if player.buff(5487) then return end --bear---
--         if wasCasting[spell.id] then return end
--         if player.manaPct < 10 then return end -- do nothing under 10% mana
--         --if healer.cc or healer.bcc then --our healer is in cc--
--             if player.lockouts.arcane.remains > 1 then
--                 if friend.hp < 80 then
--                 return spell:Cast(friend) and awful.alert({ message = awful.colors.orange.. "Regrowth (we got kicked)", texture = 8936, duration = 1 })
--                 end
--             end
--         --end
--     end)
-- end)

--decurse--
local natureCureDelay = awful.delay(0.3, 0.5)

local natureCureDebuffs = {
    [51514] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Frog
    [211015] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Kakerlake
    [210873] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Raptor
    [277784] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Köter
    [277778] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Zandalari
    [269352] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Skelett
    [211004] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Spider
    [80240] = { uptime = natureCureDelay.now, min = 1 },   -- Havoc
}

removeCorruption:Callback("healer", function(spell)
    if not player.hasTalent(2782) then return end 
    if healer.dead then return end
    if not spell:Castable(healer) then return end
    if not healer.debuffFrom(natureCureDebuffs) then return end
    if spell:Cast(healer) then
        awful.alert({ message = awful.colors.orange.."Healer", texture = spell.id, duration = 1 }) return true
    end
end)

removeCorruption:Callback("other", function(spell)
    awful.fullGroup.loop(function(friend)
        if not player.hasTalent(2782) then return end 
        if player.buff(5487) then return end --bear form--
        if not spell:Castable(friend) then return end
        if not friend.debuffFrom(natureCureDebuffs) then return end
        if healer.cc or healer.bcc then
            if spell:Cast(friend) then
                awful.alert({ message = awful.colors.orange.."", texture = spell.id, duration = 1 }) return true
            end
        end
    end)
end)

removeCorruption:Callback("agony", function(spell)

    awful.enemies.loop(function(unit)
    if unit.class2 == "SHAMAN" then return end -- we dont dispel agony vs shams --
    end)

    awful.fullGroup.loop(function(unit)
        if not player.hasTalent(2782) then return end 
        if player.buff(5215) then return end --prowl---
        if player.buff(5487) then return end --bear---
        if not spell:Castable(unit) then return end
        if unit.debuffStacks(980) > 16 then --stacks sind über 16
            return spell:Cast(unit) and awful.alert({ message = awful.colors.orange.."Agony", texture = spell.id, duration = 1 }) 
        end
    end)
end)

------------------------------AUTO CLONE ------------------------------------

--hiarr--

local noCyclonethings = { 
    377362, --precog
    8178, --grounding
    23920, --reflect
    212295, --netherward--
}

---off target peel when our healer is in cc--
cyclone:Callback("healerisinCC", function(spell)
    if select(2,GetInstanceInfo()) == "arena" then
    if not settings.autoclone then return end
    if player.buff(5487) then return end --we are in bear--
    if player.buff(5215) or player.buff(102547) or player.stealth then return end --already prowl or incarn prowl--
        awful.enemies.loop(function(enemy)
        if not enemy.isPlayer then return end 
        if enemy.role == "healer" then return end --we don't want to clone heal--
        if wasCasting[spell.id] then return end
        if not spell:Castable(enemy) then return end
        if enemy.dist > cyclone.range then return end
        if enemy.buffFrom(noCyclonethings) then return end 
        if enemy.ddr <= 0.5 then return end -- we only clone on full dr --
        if enemy.ccRemains > 2 then return end --to prevent not ccing already cc'd target--
        if not enemy.los then return end --enemy is not in sight for casting--
            if (enemy.ccRemains - buffer) < cyclone.castTimeRaw then
                if not player.target.isUnit(enemy) then  --so it's off target--
                    if not enemy.target.isUnit(player) then --we are not the target--
                        awful.group.loop(function(group)
                            if healer.cc then
                                if settings.autolockmovement and spell.current or player.channelID == spell.id then awful.controlMovement(0.3) end
                                if spell:Cast(enemy, { stopMoving = true }) then 
                                    if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Cyclone OFF Dps for PEEL", texture = 33786, duration = 2 }) end
                                    return true
                                end
                            end
                        end)
                    end 
                end
            end
        end)
    end 
end)

---- clone logic when we have precog on us on enemy healer ---

cyclone:Callback("precog-Healer", function(spell)
    if select(2,GetInstanceInfo()) == "arena" then
        if not settings.autoclone then return end
        if player.buff(5487) then return end --we are in bear--
        if player.buff(5215) then return end --we are in stealth--
        if player.buff(377362) and player.buffRemains(377362) > 1.4 then --precog--
            if wasCasting[spell.id] then return end
            if enemyHealer.dist > cyclone.range then return end
            if enemyHealer.debuff(81261) then return end --he is root-beamed-
            if not spell:Castable(enemyHealer) then return end
            --if enemyHealer.cc then return end
            if enemyHealer.buffFrom(noCyclonethings) then return end 
            if not enemyHealer.los then return end --enemy is not in sight for casting--
            if enemyHealer.ddr <= 0.5 then return end --dont cast cyclone double DR--
            if enemyHealer.ccRemains > 2 then return end  --to prevent not ccing already cc'd target--
            if player.target.isUnit(enemyHealer) then return end -- we go on healer ---
            if (enemyHealer.ccRemains - buffer) < cyclone.castTimeRaw then 
                if settings.autolockmovement and spell.current or player.channelID == spell.id then awful.controlMovement(0.3) end
                if spell:Cast(enemyHealer, { stopMoving = true }) then 
                    if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Cyclone Healer on Precog", texture = 33786, duration = 2 }) end
                    return true
                end
            end 
        end
    end 
end)

cyclone:Callback("precog-Off", function(spell)
    if select(2,GetInstanceInfo()) == "arena" then
        if not settings.autoclone then return end
        if player.buff(5487) then return end --we are in bear--
        if player.buff(5215) then return end --we are in stealth--
        if enemyHealer.debuff(33786) then return end --we cloned him--
        if player.buff(377362) and player.buffRemains(377362) > 1.4 then --precog--
            awful.enemies.loop(function(enemy)
                if not enemy.isPlayer then return end 
                if wasCasting[spell.id] then return end
                if enemy.dist > cyclone.range then return end
                if enemy.debuff(81261) then return end --he is root-beamed-
                if not spell:Castable(enemy) then return end
                --if enemyHealer.cc then return end
                if enemy.buffFrom(noCyclonethings) then return end 
                if not enemy.los then return end --enemy is not in sight for casting--
                if enemy.ddr <= 0.5 then return end --dont cast cyclone double DR--
                if enemy.ccRemains > 2 then return end  --to prevent not ccing already cc'd target--
                if player.target.isUnit(enemy) then return end -- we go on healer ---
                if (enemy.ccRemains - buffer) < cyclone.castTimeRaw then 
                    if settings.autolockmovement and spell.current or player.channelID == spell.id then awful.controlMovement(0.3) end
                    if spell:Cast(enemy, { stopMoving = true }) then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Cyclone OFF on Precog", texture = 33786, duration = 2 }) end
                        return true
                    end
                end 
            end)
        end 
    end 
end)

--- we clone target which has big defensive up ---
local EnemyBigDef = { 
    [33206] = { min = 4 },	-- Pain Suppression
    [102342] = { min = 4 },	-- Ironbark
    [47788] = { min = 4 },	-- Guardian Spirit
    [232707] = { min = 4 },	-- Ray of Hope
    [116849] = { min = 3 },	-- cocoon
    [357170] = { min = 4 },	-- time dilation
    [196555] = { min = 3 },	-- netherwalk
    [61336] = { min = 4 },	-- survival instincts 
    [108271] = { min = 4 },	-- astral shift
    [104773] = { min = 4 },	-- unending resolve
    [1022] = { min = 4 },	-- bop
    [125174] = { min = 4 },	-- Karma
    [47585] = { min = 4 },	-- Dispersion
    [118038] = { min = 4 },	-- Die by the sword 
    [48792] = { min = 4 },	-- Icebound
 }

 local EnemeyBigDefAlwaysClone = { 
    [116849] = { min = 3 },	-- cocoon
    [196555] = { min = 3 },	-- netherwalk
    [1022] = { min = 3 },	-- bop
    [125174] = { min = 4 },	-- Karma
    [47585] = { min = 4 },	-- Dispersion
 }

cyclone:Callback("autocloneBigDefs", function(spell)
    if select(2,GetInstanceInfo()) == "arena" then
        if not settings.autoclone then return end
        if player.buff(5487) then return end --we are in bear--
        if player.buff(5215) then return end --we are in stealth--
    -- if not player.hasTalent(410354) then return end --we don't have wild attunment talent
        awful.enemies.loop(function(enemy)
            if wasCasting[spell.id] then return end
            if not spell:Castable(enemy) then return end
            if enemy.dist > cyclone.range then return end
            if enemy.buffFrom(noCyclonethings) then return end 
            if enemy.ddr <= 0.5 then return end --dont cast cyclone half DR--
            if enemy.ccRemains > 1 then return end --to prevent not ccing already cc'd target--
            if not enemy.los then return end --enemy is not in sight for casting--
            if enemy.buffFrom(EnemyBigDef) and enemy.hp > 35 or enemy.buffFrom(EnemeyBigDefAlwaysClone) then
                if (enemy.ccRemains - buffer) < cyclone.castTimeRaw then
                if settings.autolockmovement and spell.current or player.channelID == spell.id then awful.controlMovement(0.3) end
                    if spell:Cast(enemy, { stopMoving = true }) then 
                    if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Cyclone Big Defensives", texture = 33786, duration = 2 }) end
                    return true
                    end
                end
            end
        end)
    end 
end)


---auto burst---

incarn:Callback("autoburst", function(spell)
    if not settings.autoburst then return end
        --if player.buff(5487) then return end --bear---
        --if player.buff(5215) then return end --prowl---
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.enemyHealer then return end
        if target.dist > incarn.range then return end
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        if target.los and enemyHealer.cc then
            return spell:AoECast(target) and awful.alert({ message = awful.colors.yellow.. "Incarn", texture = spell.id, duration = 1 })
        end
end)

moonfire:Callback("autoburst", function(spell)
    if not settings.autoburst then return end
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.dist > moonfire.range then return end
        if target.friendly then return end
        if target.los then
            if target.debuffRemains(164812, player) < 5 then --moonfire debuff--
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Moonfire", texture = spell.id, duration = 1 })
            end
        end
end)

sunfire:Callback("autoburst", function(spell)
    if not settings.autoburst then return end
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.dist > moonfire.range then return end
        if target.friendly then return end
        if target.los then
            if target.debuffRemains(164815, player) < 5 then --moonfire debuff--
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Sunfire", texture = spell.id, duration = 1 })
            end
        end
end)

mushroom:Callback("autoburst", function(spell)
    if not settings.autoburst then return end
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.debuff(393957) then return end  --waning twilight--
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > mushroom.range then return end
        if wasCasting[spell.id] then return end
        if player.used(spell.id, 3) then return end --debuff needs 2 secs to apply--
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        if target.debuffRemains(81281) < 2.5 then --mushroom debuff--
            if target.los then
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Shroom", texture = spell.id, duration = 1 })
            end
        end
end)

starsurge:Callback("autoburst", function(spell)
    if not settings.autoburst then return end
        if player.hasTalent(191034) then return end --we skilled starfall--
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > starsurge.range then return end
        --if target.debuff(393957) then  --waning twilight--
            if target.los and enemyHealer.cc then
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Starsurge", texture = spell.id, duration = 1 })
            end
        --end
end)

furyofelune:Callback("autoburst", function(spell)
    if not settings.autoburst then return end 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > furyofelune.range then return end
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        if target.los and enemyHealer.cc then
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Fury of Elune", texture = spell.id, duration = 1 })
        end
end)

warriorelune:Callback("autoburst", function(spell)
    if not settings.autoburst then return end 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if player.buff(394414) then return end
        if target.distance > 40 then return end --incarn hat 40m--
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        --if not target.debuff(393957, player) then return end --dmg increase debuff--
        if enemyHealer.cc then 
        return spell:Cast(player) and awful.alert({ message = awful.colors.yellow.. "Warrior of Elune", texture = spell.id, duration = 1 })
        end
end)

astralcommu:Callback("autoburst", function(spell)
    if not settings.autoburst then return end 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if player.buff(394414) then return end
        if not player.hasTalent(400636) then return end --astral commu talent--
        if target.distance > 40 then return end --incarn hat 40m--
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        --if not target.debuff(393957, player) then return end --dmg increase debuff--
        if player.astralPower < 35 then
            if enemyHealer.cc then 
            return spell:Cast(player) and awful.alert({ message = awful.colors.yellow.. "Astral Communion", texture = spell.id, duration = 1 })
            end
        end
end)

starfire:Callback("autoburst", function(spell)
    if not settings.autoburst then return end 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > starfire.range then return end
        if player.buff(202425) then --free starfire procc--
            if target.los then
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Instant Starfire", texture = spell.id, duration = 1 })
            end
        end
end)

---wenn auto shapeshift dann muss das hier noch angepasst werden---
moonkin:Callback("autoburst", function(spell)
    if not settings.autoburst then return end 
        if player.buff(24858) then return end --moonkin--
        return spell:Cast(player)
end)

solarbeam:Callback("autobeam", function(spell)
    if not settings.autobeam then return end
    awful.fullGroup.loop(function(group)
        if enemyHealer.stun and enemyHealer.stunRemains > 1 then return end 
        if not group.cds or not target.stunned then return end
        if enemyHealer.dist > 35 then return end --massroot range has only 35--
        if enemyHealer.buff(8178) then return end --grounding--
        if enemyHealer.buff(353319) then return end --immunity after revival--
        --if enemyHealer.class == "Druid" then return end --if not druid--
        --if enemyHealer.casting8 then return end --testen, kickt nicht in immunities--
        if not spell:Castable(enemyHealer) then return end --is castable like when he has immunities--
        if enemyHealer.cc then return end 
        --if enemyHealer.rootDR <= 0.50 then return end --only rooting him when he is on full dr--s
        if enemyHealer.rooted and enemyHealer.rootRemains > 3 and enemyHealer.los then
            return spell:Cast(enemyHealer) and awful.alert({ message = awful.colors.red.. "Root Beam", texture = spell.id, duration = 2 })
        end
    end)
end)

massroot:Callback("autobeam", function(spell)
    if not settings.autobeam then return end
        if not group.cds or not target.stunned then return end
        if enemyHealer.dist > 35 then return end
        if enemyHealer.buff(8178) then return end --grounding--
        if enemyHealer.buff(353319) then return end --immunity after revival--
        --if enemyHealer.cc then return end
        --if enemyHealer.rooted then return end 
        --if enemyHealer.class == "Druid" then return end --if not druid--
        --if enemyHealer.casting8 then return end --testen, kickt nicht in immunities--
        if not spell:Castable(enemyHealer) then return end --is castable like when he has immunities--
        if enemyHealer.rootDR <= 0.50 then return end --only rooting him when he is on full dr--
        if solarbeam.cd > 1 then return end --solarbeam not rdy--
        if enemyHealer.los then
            return spell:Cast(enemyHealer) and awful.alert({ message = awful.colors.red.. "Root Beam", texture = spell.id, duration = 2 })
        end
end)

local trapstunstuff = { 24394, 190925 } --intim bm stun, harpoon rooted--

wildchargetrap:Callback(function(spell)
    if not settings.autowildcharge then return end
    if player.rooted then return end
    if player.buff(5215) then return end --prowl---
    if not healer.debuff(trapstunstuff) then return end
    awful.enemies.loop(function(enemy)
        if enemy.class ~= "Hunter" then return end -- if not enemy isn't a hunter
        if enemy.cooldown(187650) > 1 then return end  
        if enemy.used(116844, 5) then return end --ring of peace was used--
            if healer.distance > 30 then return end
            if healer.distance < 5 then return end
            if not healer.los then return end
            --if player.buff(5487) then CancelShapeshiftForm() end --bear form--
            if player.buff(768) then CancelShapeshiftForm() end --cat form--
            if player.buff(783) then CancelShapeshiftForm() end --travel form--
            if player.buff(24858) then CancelShapeshiftForm() end --moonkin form--
            if healer.debuff(trapstunstuff) then --he is stunned for trap--
            return spell:Cast(healer) and awful.alert({ message = awful.colors.red.. "Wildcharge - Trap eating", texture = 187650, duration = 1 })
            end
    end)
end)

---- SHUFFLE BOT SECTION ---

local botting = awful.ShuffleBot and awful.ShuffleBot.enabled

incarn:Callback("botting", function(spell)
    if settings.mode == "ssbotmode" then 
        --if player.buff(5487) then return end --bear---
        --if player.buff(5215) then return end --prowl---
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.enemyHealer then return end
        if target.dist > incarn.range then return end
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        if target.los and enemyHealer.cc then
            return spell:AoECast(target) and awful.alert({ message = awful.colors.yellow.. "Incarn", texture = spell.id, duration = 1 })
        end
    end
end)

trollracial:Callback("botting", function(spell)
    if settings.mode == "ssbotmode" then 
        if trollracial.known then
            if player.cds then 
            return spell:Cast(player) and awful.alert({ message = awful.colors.yellow.. "Troll Racial", texture = spell.id, duration = 1 })
            end
        end
    end
end)

moonfire:Callback("botting", function(spell)
    if settings.mode == "ssbotmode" then 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.dist > moonfire.range then return end
        if target.friendly then return end
        if target.los then
            if target.debuffRemains(164812, player) < 5 then --moonfire debuff--
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Moonfire", texture = spell.id, duration = 1 })
            end
        end
    end
end)

sunfire:Callback("botting", function(spell)
    if settings.mode == "ssbotmode" then 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.dist > moonfire.range then return end
        if target.friendly then return end
        if target.los then
            if target.debuffRemains(164815, player) < 5 then --moonfire debuff--
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Sunfire", texture = spell.id, duration = 1 })
            end
        end
    end
end)

mushroom:Callback("botting", function(spell)
    if settings.mode == "ssbotmode" then 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.debuff(393957) then return end  --waning twilight--
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > mushroom.range then return end
        if wasCasting[spell.id] then return end
        if player.used(spell.id, 3) then return end --debuff needs 2 secs to apply--
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        if target.debuffRemains(81281) < 2.5 then --mushroom debuff--
            if target.los then
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Shroom", texture = spell.id, duration = 1 })
            end
        end
    end
end)

starsurge:Callback("botting", function(spell)
    if settings.mode == "ssbotmode" then 
        if player.hasTalent(191034) then return end --we skilled starfall--
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > starsurge.range then return end
        --if target.debuff(393957) then  --waning twilight--
            if target.los and enemyHealer.cc then
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Starsurge", texture = spell.id, duration = 1 })
            end
        --end
    end
end)

furyofelune:Callback("botting", function(spell)
    if settings.mode == "ssbotmode" then 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > furyofelune.range then return end
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        if target.los and enemyHealer.cc then
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Fury of Elune", texture = spell.id, duration = 1 })
        end
    end
end)

warriorelune:Callback("botting", function(spell)
    if settings.mode == "ssbotmode" then 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if player.buff(394414) then return end
        if target.distance > 40 then return end --incarn hat 40m--
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        --if not target.debuff(393957, player) then return end --dmg increase debuff--
        if enemyHealer.cc then 
        return spell:Cast(player) and awful.alert({ message = awful.colors.yellow.. "Warrior of Elune", texture = spell.id, duration = 1 })
        end
    end
end)

astralcommu:Callback("botting", function(spell)
    if settings.mode == "ssbotmode" then 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if player.buff(394414) then return end
        if not player.hasTalent(400636) then return end --astral commu talent--
        if target.distance > 40 then return end --incarn hat 40m--
        if not target.debuff(164815, player) then return end --sunfire debuff--
        if not target.debuff(164812, player) then return end --moonfire debuff--
        --if not target.debuff(393957, player) then return end --dmg increase debuff--
        if player.astralPower < 35 then
            if enemyHealer.cc then 
            return spell:Cast(player) and awful.alert({ message = awful.colors.yellow.. "Astral Communion", texture = spell.id, duration = 1 })
            end
        end
    end
end)

starfire:Callback("botting", function(spell)
    if settings.mode == "ssbotmode" then 
        if player.buff(5487) then return end --bear---
        if player.buff(5215) then return end --prowl---
        if target.buff(212295) then return end --netherward--
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > starfire.range then return end
        if player.buff(202425) then --free starfire procc--
            if target.los then
            return spell:Cast(target) and awful.alert({ message = awful.colors.yellow.. "Instant Starfire", texture = spell.id, duration = 1 })
            end
        end
    end
end)

---wenn auto shapeshift dann muss das hier noch angepasst werden---
-- moonkin:Callback("botting", function(spell)
--     if settings.mode == "ssbotmode" then 
--         if player.buff(24858) then return end --moonkin--
--         return spell:Cast(player)
--     end
-- end)

-- solarbeam:Callback("botting", function(spell)
--     if settings.mode == "ssbotmode" then 
--         if enemyHealer.dist > 35 then return end --massroot range has only 35--
--         --if enemyhealer.cc then return end
--         --if enemyHealer.class == "Druid" then return end --if not druid--
--         --if enemyHealer.casting8 then return end --testen, kickt nicht in immunities--
--         if not spell:Castable(enemyHealer) then return end --is castable like when he has immunities--
--         if enemyHealer.cc then return end 
--         --if enemyHealer.rootDR <= 0.50 then return end --only rooting him when he is on full dr--s
--         if enemyHealer.rooted and enemyHealer.rootRemains > 3 and enemyHealer.los then
--             return spell:Cast(enemyHealer) and awful.alert({ message = awful.colors.red.. "Root Beam", texture = spell.id, duration = 2 })
--         end
--     end
-- end)

-- massroot:Callback("botting", function(spell)
--     if settings.mode == "ssbotmode" then 
--         if enemyHealer.dist > 35 then return end
--         --if enemyHealer.cc then return end
--         --if enemyHealer.rooted then return end 
--         --if enemyHealer.class == "Druid" then return end --if not druid--
--         --if enemyHealer.casting8 then return end --testen, kickt nicht in immunities--
--         if not spell:Castable(enemyHealer) then return end --is castable like when he has immunities--
--         if enemyHealer.rootDR <= 0.50 then return end --only rooting him when he is on full dr--
--         if solarbeam.cd > 1 then return end --solarbeam not rdy--
--         if enemyHealer.los then
--             return spell:Cast(enemyHealer) and awful.alert({ message = awful.colors.red.. "Root Beam", texture = spell.id, duration = 2 })
--         end
--     end
-- end)

-- cyclone:Callback("bottingoff", function(spell)
--     if settings.mode == "ssbotmode" then 
--         awful.enemies.loop(function(enemy)
--         if enemy.role == "healer" then return end --we don't want to clone heal--
--         if wasCasting[spell.id] then return end
--         if not spell:Castable(enemy) then return end
--         if enemy.dist > cyclone.range then return end
--         if enemy.buff(212295) then return end  --netherward--
--         if enemy.ddr < 0.5 then return end --dont cast cyclone tripple DR--
--         if enemy.ccRemains > 2 or enemy.bccRemains > 2 then return end --to prevent not ccing already cc'd target--
--         if not enemy.los then return end --enemy is not in sight for casting--
--             if (enemy.ccRemains - buffer) < cyclone.castTimeRaw then
--                 if not player.target.isUnit(enemy) then 
--                     awful.group.loop(function(group)
--                         if healer.cc and group.hp < 40 then
--                             if spell:Cast(enemy) then 
--                                 if awful.alert({ message = awful.colors.red.. "Cyclone OFF Dps for PEELING", texture = 33786, duration = 2 }) then
--                                 return true end
--                             end
--                         end
--                     end)
--                 end
--             end
--         end)
--     end
-- end)

-- cyclone:Callback("bottinghealer", function(spell)
--     if settings.mode == "ssbotmode" then 
--         if wasCasting[spell.id] then return end
--         --if enemy.role ~= "healer" then return end
--         if enemyHealer.dist > cyclone.range then return end
--         if enemyHealer.debuff(81261) then return end --he is root-beamed-
--         if not spell:Castable(enemyHealer) then return end
--         --if enemyHealer.cc then return end
--         if not enemyHealer.los then return end --enemy is not in sight for casting--
--         if enemyHealer.ddr < 0.5 then return end --dont cast cyclone tripple DR--
--         if enemyHealer.ccRemains > 2 or enemyHealer.bccRemains > 2 then return end  --to prevent not ccing already cc'd target--
--         if (enemyHealer.ccRemains - buffer) < cyclone.castTimeRaw then
--             if spell:Cast(enemyHealer) then 
--                 if awful.alert({ message = awful.colors.red.. "Cyclone Enemy Healer", texture = 33786, duration = 2 }) then
--                 return true end
--                 end
--             end
--     end
-- end)

-- cyclone:Callback("bottingBigDefs", function(spell)
--     if settings.mode == "ssbotmode" then 
--     if not settings.autoclonehighrating then return end
--     if player.buff(5487) then return end --we are in bear--
--         awful.enemies.loop(function(enemy)
--         if not enemy.buffFrom(BigDef) then return end
--         if wasCasting[spell.id] then return end
--         if not spell:Castable(enemy) then return end
--         if enemy.dist > cyclone.range then return end
--         if enemy.buff(212295) then return end  --netherward--
--         if enemy.ddr < 0.5 then return end --dont cast cyclone tripple DR--
--         if enemy.ccRemains > 2 then return end --to prevent not ccing already cc'd target--
--         if not enemy.los then return end --enemy is not in sight for casting--
--             --if (enemy.ccRemains - buffer) < cyclone.castTimeRaw then
--                 if spell:Cast(enemy) then 
--                     if awful.alert({ message = awful.colors.red.. "Cyclone Enemy with Big Defensive", texture = 33786, duration = 2 }) then
--                     return true end
--                 end
--             --end
--         end)
--     end
-- end)

------ rbg flags -----

-- local flags = {
--     ["Alliance Flag"] = true,
--     ["Horde Flag"] = true,
-- }
-- local flagDropTime = 0
-- local function flagActions()
--   if awful.instanceType2 ~= "pvp" then return end
--   if awful.time > flagDropTime then
--         awful.objects.loop(function(obj)
--             if not flags[obj.name] then return end
--             if obj.dist > 5 then return end
--             obj:interact()
--         end)
--   end
-- end

moonkinOutofBear:Callback(function(spell)
   -- if not settings.autobearin then return end 
    if player.buff(24858) then return end --moonkin--
    if beartime == true then return end 
    if traveltime == true then return end
    if player.buff(768) then return end --cat--
    if beartime == false or traveltime == false or not player.buff(768) then
    return spell:Cast(player) 
    end
end)

local BigDef = { 
    33206, --Pain Suppression
    81782, --Dome
    102342, --Ironbark
    47788, --Guardian Spirit
    232707, --Ray of Hope
    116849, --cocoon
    1022, --BOP
    6940, --SAC
    325174, --link totem buff
    363534, --rewind prevoker--
    357170, --time dilation--
    196718, --darkness--
    209426, --darkness#2--
    61336, --survival instincts
}

bear:Callback("kidney", function(spell)
    if not settings.autobear then return end
    if player.sdr < 0.5 then return end --only on full stun--
    --if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buff(5487) then return end --bear---
    --if player.buff(102543) then return end -- we are bursting --
    awful.enemies.loop(function(unit)
        if unit.class ~= "Rogue" then return end --if not rogue--
        if target.hp < 30 then return end -- our target is low to kill--
        if healer.cc and healer.ccRemains > 2 then--only shift when our healer is in brekable cc--
            if unit.cds and unit.target.isUnit(player) then --and unit.buff(185422) then --or unit.cooldown(408) < 1 then ---enemy has offensive CDs and shadowdance or kidney rdy targeting me---
                awful.alert({ message = awful.colors.red.. "Kidney", texture = spell.id, duration = 2 })
                beartime = true 
            end
        end
    end)
end)

function ccoffOFF()
    if ccoff then 
        awful.enemies.loop(function(enemy)
            if enemy.role == "healer" then return end --we don't want to clone heal--
            --if player.castTarget.isUnit(unit) and unit.distanceTo(player) > 23 or player.castTarget.isUnit(unit) and not unit.los then
            if not player.target.isUnit(enemy) and enemy.ddr <= 0.25 or select(2,GetInstanceInfo()) == "arena" and not player.target.isUnit(enemy) and not enemy.los then  ---off target is immune, or offtarget is not los but only in arena or it makes trouble openworld----
            ccoff = false
            awful.alert({ message = awful.colors.pink.. "Can't Clone Off-target now (on DR)", texture = 33786, duration = 2 })
            end 
        end)
    end 
end 

function cchealOFF()
    if ccheal or cchealtwo then 
        if enemyHealer.ddr <= 0.25 or not enemyHealer.los then 
        ccheal = false
        cchealtwo = false  
        awful.alert({ message = awful.colors.pink.. "Can't Clone Healer now (on DR or not existend)", texture = 33786, duration = 2 })
        end 
    end 
end 

function burstTrigger1()
    if not settings.autoburst then return end 
    if not player.combat then return end 
    if awful.prep then return end 
    --if incarn.cd > 1 then return end 
    if bursti == true then return end --already enabled--
    if target.friendly then return end 
    if target.buffFrom(noPanic) or target.buffFrom(immuneBuffs) then return end 
    if not enemyHealer.exists and target.exists and target.los then 
        bursti = true
     end
end 

function burstTrigger2()
    if select(2,GetInstanceInfo()) ~= "arena" then return end  --only arena--
    if not settings.autoburst then return end 
    if not player.combat then return end 
    if awful.prep then return end 
    --if incarn.cd > 1 then return end 
    if bursti == true then return end --already enabled--
    if target.friendly then return end 
    if target.buffFrom(noPanic) or target.buffFrom(immuneBuffs) then return end 
    if enemyHealer.exists and enemyHealer.cc and enemyHealer.ccRemains > 2 and target.exists and target.los then 
        bursti = true
     end
end 

function burstOFF()
    if not settings.autoburst then return end 
    if bursti then 
        if not player.combat or awful.prep or beartime or traveltime or player.buff(5487) then 
       -- if not player.buff(231895) then 
        bursti = false
        end 
    end 
end 


--ein burst trigger noch wenn wir root beam rdy haben, und eines wenn wir es nicht rdy haben und enemy healer im cc ist--

---actor---
balance:Init(function()

    --if not settings.macroalertsdisable then 
    if bursti == true then awful.alert({ message = awful.colors.cyan.. "Burst ON", texture = 393760, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) end
    if ccheal == true then awful.alert({ message = awful.colors.cyan.. "CC Heal ON", texture = 33786, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) end
    if cchealtwo == true then awful.alert({ message = awful.colors.cyan.. "CC heal ON", texture = 33786, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) end
    if ccoff == true then awful.alert({ message = awful.colors.cyan.. "CC OFF DPS ON", texture = 33786, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) end
    if beartime == true then awful.alert({ message = awful.colors.cyan.. "Bear Time ON", texture = 5487, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) end
    if traveltime == true then awful.alert({ message = awful.colors.cyan.. "Travel Time ON", texture = 783, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) end
    --end

    markofthewild()
    if awful.player.mounted then return end

    if awful.MacrosQueued["trinket"] then 
        medalTrinket()
    end

    WasCastingCheck()
    awful.AutoFocus()
    shadowmeld("incomingCC")
    shadowmeld("verylowhp")
    
    burstOFF()
    --healthstone:grab()

    travel("macro")
    wildchargetrap()

    medalTrinketauto()

    if traveltime == true then return end 

    bear("kidney")
    moonkin("ccheal")
    moonkin("ccoff")
    moonkin("bursti")
    moonkin("botting")
    moonkin()
    moonkinOutofBear()

    ccoffOFF()
    cchealOFF()

    bear()
    --bear("lowhp")
    --moonkin("bearOFF")

    frenzireg()
    frenzireg("reallow")

    barkskin("twocds")
    barkskin("nobigdefs")
    barkskin("lowhp")
    barkskin("nohealer")
    hotw()
    hotw("nohealer")
    renewal()
    battleMaster()
    healthStone()

    removeCorruption("healer")
    removeCorruption("other")

    vortex("charge")
    vortex("ourDKburst")
    vortex("lowhp")
    vortex("ourRogBomb")
    stamproar()
    --massroot("pitlord")
    thorns()
    faeriedisarm()
    massroot("manualbeam")
    vortex("manualbeam")
    typhoon("askick")
    typhoon()

    regrowth("onmeNotLoS")

    ironfur()
    mangle()
    --swipe()

    if beartime == true then return end 

    burstTrigger1()
    burstTrigger2()

    moonfire("smalltotems")
    starsurge("bigtotems")
    starsurge("bigpets")
    starfire("bigpets")
    innervate()
    natureVigil()

    catOpener()
    solarbeam()
    solarbeam("casts")
    solarbeam("channels")
    massroot()
    solarbeam("autobeam")
    massroot("autobeam")

    moonFireGrounding()
    bashHealer()
    cycloneHealer()
    cyclone()
    cyclone("autocloneBigDefs")
    cyclone("healerisinCC")
    cyclone("precog-Healer")
    cyclone("precog-Off")
    --incapRoar()
    --incapRoarHealer()

    if ccheal == true then return end 

    moonfire("reflecttarget")
    moonfire("reflectccoff")

    bash()

    solarbeam("burst")
    massroot("burst")
    forcofnature("burst")
    starsurge("procc")
    trollracial("burst")
    furyofelune("burst")
    incarn("burst")

    -- solarbeam("botting")
    -- massroot("botting")
    -- trollracial("botting")
    -- furyofelune("botting")
    -- incarn("botting")
    -- starsurge("botting")

    starsurge("targetLowHpAOEspec")
    moonfire("burst")
    sunfire("burst")
    wrath("eclipse")
    starfall()
    starfall("bgfreeprocc")
    starsurge("bgfreeprocc")
    starsurge("bgmode")
    regrowth("procc")

    starsurge("burst")
    fullmoon("precog")
    fullmoon("burst")
    starfire("burst")
    mushroom("burst")
    warriorelune()
    starfire("warriorbuff")
    astralcommu()

    cyclone("bottinghealer")
    cyclone("autoclonehealer")

    -- moonfire("botting")
    -- sunfire("botting")
    -- mushroom("botting")
    -- warriorelune("botting")
    -- starfire("botting")
    -- astralcommu("botting")

    --if bursti == true then return end

    regrowth("ourgroup")
    travelRoots("noform")
    travelRoots("inform")
    --travelRoots("noformfulldr")
    --travelRoots("informfulldr")
    travelRoots("informChainsOfIce")
    travelRoots("noformChainsOfIce")
    --travelRoots("noformHunterNet")
    --travelRoots("informHunterNet")

    removeCorruption("agony")

    --starsurge("targetLowCost")
    starsurge("target")
    mushroom("target")
    moonfire("target")
    sunfire("target")
    moonfire("spread")
    sunfire("spread")
    newmoon()
    halfmoon()
    fullmoon()
    stellarflare()
    starfire("instantbuff")
    starfire()
    starfire("kicked")
    --regrowth("kicked")
    wrath("kicked")
    moonfire("movingtarget")
    sunfire("movingtarget")
    moonfire("movingspread")
    sunfire("movingspread")
    moonfire("spreadpets")
    sunfire("spreadpets")

end)

