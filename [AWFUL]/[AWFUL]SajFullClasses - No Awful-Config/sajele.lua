local Unlocker, awful, sajele = ...
local player, target, focus, healer, enemyHealer, arena1, arena2, arena3, party1, party2 = awful.player, awful.target, awful.focus, awful.healer, awful.enemyHealer, awful.arena1, awful.arena2, awful.arena3, awful.party1, awful.party2



sajele.shaman = {}
sajele.shaman.elemental = awful.Actor:New({ spec = 1, class = "shaman" })

local elemental = sajele.shaman.elemental

if player.spec ~= "Elemental" then return end

if player.class == "Shaman" and player.spec == "Elemental" then
    awful.print("[|cffDA2020 Welcome to |r]") 
    awful.print("[|cff4550FC Sajs Elemental |r]") 
    awful.print("[|cffDA2020 Enjoy |r]")
end

local cmd = awful.Command("saj", true)
sajele.cmd = cmd

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


--------------- --------------- --------------- --------------- UI--------------- --------------- --------------- ---------------

local settings = sajele.settings

local yellow = {245, 235, 55, 1}
local white = {255, 255, 255, 1}
local dark = {21, 21, 21, 0.45}
local orange = {255, 140, 0, 255}
local red = {255, 0, 0, 1}
local reddark = {210, 58, 58, 1}
local brown = {139, 71, 38, 255}
local green = {0, 255, 0, 255}
local black = {55, 55, 55, 1}
local yellowcool = {255, 255, 153, 1}
local redcool = {139, 90, 43, 0.45}
local greencool = {152, 251, 152, 200}
local browncool = {255, 165, 79, 200}
local newgreencool = {0, 255, 0, 0.1}
local shamancolor = {0, 112,221, 1}
local colortest = {215, 117, 61, 1}

local gui, settings = awful.UI:New("sajUI", {
 title = "      SAJ     ",
 show = true, -- show not on load by default
 colors = {
     --color of our ui title in the top left
     title = reddark,
     --primary is the primary text color
     primary = reddark,
     --accent controls colors of elements and some element text in the UI. it should contrast nicely with the background.
     accent = colortest,
     background = dark,
 }
})

local sajUI = gui:Tab("Mode")

sajUI:Text({
    text = awful.textureEscape(1032476, 25, "0:0") .. awful.colors.red .. " Sajs Elemental",
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
	tooltip = "Choose if you play PVE or PVP, very important",
	options = {
		{ label = awful.textureEscape(400924, 22, "0:01") .. "  PVP", value = "pvpmode", tooltip = "Choose if you play PVP", default = true },
		{ label = awful.textureEscape(101108, 22, "0:01") .. "  PVE", value = "pvemode", tooltip = "Choose if you play PVE" },
	},
	placeholder = "PRESS HERE TO SELECT MODE",
	header = "Mode:",
})

sajUI:Checkbox({
    text = awful.textureEscape(3684828, 22, "0:13") .. "  Drawings",
    var = "drawings", -- checked bool = settings.drawings   
    default = true,
    tooltip = "Drawings like Trap, Lines to ur Mates and stuff" 
})

sajUI:Checkbox({
    text = awful.textureEscape(132284, 22, "0:13") .. "  Icons for Classes",
    var = "classdrawings", -- checked bool =  
    default = true,
    tooltip = "Enemy class icons will be shown above to the characters, it may cause some LUA errors, disable it if u like" 
})

sajUI:Checkbox({
    text = awful.textureEscape(538575, 22, "0:13") .. "  Icons above Totems",
    var = "totemdrawings", -- checked bool =  
    default = true,
    tooltip = "Drawings icons above totems (visual)" 
})

sajUI:Checkbox({
    text = awful.textureEscape(1320372, 22, "0:13") .. "  Icons above Bursting Enemies",
    var = "burstdrawings", -- checked bool =  
    default = false,
    tooltip = "Drawing Icons above Players who are bursting (BETA)" 
})

sajUI:Checkbox({
    text = awful.textureEscape(895885, 22, "0:13") .. "  Alerts enabled",
    var = "alertsmode", -- checked bool = settings.alertsmode
    default = true,
    tooltip = "Alerts in the middle of ur screen, recommended when playing with my Macros" 
})

sajUI:Checkbox({
    text = awful.textureEscape(37529, 22, "0:13") .. "  Start Rotation only in Combat",
    var = "nofightstarter", -- checked bool = settings.nofightstarter
    default = false,
    tooltip = "This is made for questing/leveling to prevent attacking people in town, it will only start the rotation when u are in fight. So you have to press a button to get in combat. You don't need this option in Dungeons/Raids, it's auto checking there if mobs are in fight." 
})


sajUI:Dropdown({
	var = "hexmode",
	tooltip = "only important in pvp",
	options = {
		{ label = awful.textureEscape(51514, 22, "0:01") .. "  Show Hex Icon Healer", value = "hexiconhealer", tooltip = "Will show the hex icon above the enemy Healer, when he is ready for full hex", default = true },
		{ label = awful.textureEscape(51514, 22, "0:01") .. "  Show Hex Icon on all", value = "hexiconall", tooltip = "Will show the hex icon above everyone who is able to get a full hex" },
        { label = awful.textureEscape(51514, 22, "0:01") .. "  No Hex Icons", value = "nohexicons", tooltip = "Will disable Icons above players who are ready for full hex" },
	},
	placeholder = "PRESS HERE TO SELECT VISUAL HEX ICON",
	header = "Hex Icon:",
})


-- sajUI:Checkbox({
--     text = awful.textureEscape(5852173, 22, "0:13") .. "  Legit Mode (soon)",
--     var = "legitmode", -- checked bool = settings.alertsmode
--     default = false,
--     tooltip = "<IN PROGRESS> Legitmode for PVP to make it not look obvious we are botting. It will include a lot of logic and randomness <IN PROGRESS>" 
-- })

local sajUI = gui:Tab("General")

sajUI:Text({
    text = awful.textureEscape(1032476, 25, "0:0") .. awful.colors.red .. " Sajs Elemental",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})


sajUI:Checkbox({
    text = awful.textureEscape(198067, 22, "0:13") .. "  Auto Burst   ",
    var = "autoburst", -- checked bool = if not settings.autoburst then return end
    default = true,
    tooltip = "Auto Burst with Primo & Ele, if u turn this off you need to use /saj bursti to toggle burst on/off" 
})

sajUI:Checkbox({
    text = awful.textureEscape(8143, 22, "0:13") .. "  Auto Totems ",
    var = "autototem", -- checked bool = settings.autototem
    default = true,
    tooltip = "Using ur Totems automatically (for example Healing Stream, Tremor and stuff in PVP and in PVE it means Liquid Totem and all that" 
})

sajUI:Checkbox({
    text = awful.textureEscape(57994, 22, "0:13") .. "  Auto Kick   ",
    var = "autokick", -- checked bool = if not settings.autokick then return end
    default = true,
    tooltip = "Auto Kick in PVE & PVP" 
})

sajUI:Checkbox({
    text = awful.textureEscape(79206, 22, "0:13") .. "  Auto Spiritwalker",
    var = "autospiritwalker", -- checked bool = settings.autospiritwalker
    default = true,
    tooltip = "Using Auto Spiritwalker" 
})


sajUI:Checkbox({
    text = awful.textureEscape(192058, 22, "0:13") .. "  Auto Capacitor Totem ",
    var = "autostuntotem", -- checked bool = settings.autowindrus
    default = true,
    tooltip = "Using Capacitor Totem (Stun Totem) automatically in PVP and PVE" 
})

local sajUI = gui:Tab("PVP")

sajUI:Text({
    text = awful.textureEscape(1032476, 25, "0:0") .. awful.colors.red .. " Sajs Elemental",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Checkbox({
    text = awful.textureEscape(254416, 22, "0:13") .. "  Totem Stomp ",
    var = "totemstomp", -- checked bool = settings.totemstomps    
    default = true,
    tooltip = "Stomping important Totems" 
})


sajUI:Checkbox({
    text = awful.textureEscape(8004, 22, "0:13") .. "  Auto Heal    ",
    var = "autoheal", -- checked bool = if not settings.autoheal then return end
    default = true,
    tooltip = "Auto Heal, using Heals" 
})

sajUI:Checkbox({
    text = awful.textureEscape(51514, 22, "0:13") .. "  Auto Hex (Arena)",
    var = "autohex", -- checked bool =  
    default = true,
    tooltip = "Auto Hex in PVP Arena" 
})

sajUI:Checkbox({
    text = awful.textureEscape(51485, 22, "0:13") .. "  Auto Root ",
    var = "autoroot", -- checked bool = settings.autoroot   
    default = true,
    tooltip = "Using Auto Root Totem (PVP)" 
})

sajUI:Checkbox({
    text = awful.textureEscape(51485, 22, "0:13") .. "  Auto Root Hunter Pets",
    var = "autorootPets", -- checked bool = settings.autorootPets   
    default = true,
    tooltip = "Using Auto Root Totem (PVP) vs Hunter Pets on Burst" 
})

sajUI:Checkbox({
    text = awful.textureEscape(305483, 22, "0:13") .. "  Auto Lasso ",
    var = "autolasso", -- checked bool = settings.autoroot   
    default = true,
    tooltip = "Using Auto Lasso (PVP), still beta version" 
})

sajUI:Checkbox({
    text = awful.textureEscape(8143, 22, "0:13") .. "  Auto Pre-Tremor",
    var = "autopretremor", -- checked bool = settings.autopretremor
    default = true,
    tooltip = "<beta> We will pre-tremor goes, we won't do that when we have a healer because we hold it for him" 
})

sajUI:Checkbox({
    text = awful.textureEscape(356736, 22, "0:13") .. "  Auto Unleash Shield ",
    var = "autounleashshield", -- checked bool = settings.autounleashshield
    default = true,
    tooltip = "Auto Using Unleash Shield" 
})

sajUI:Checkbox({
    text = awful.textureEscape(378773, 22, "0:13") .. "  Auto Purge ",
    var = "autopurge", -- checked bool = settings.autopurge    
    default = true,
    tooltip = "Purging important spells only" 
})

sajUI:Checkbox({
    text = awful.textureEscape(378773, 22, "0:13") .. "  Auto Purge (offensive)",
    var = "autopurgeoffensive", -- checked bool = settings.autopurgeoffensive   
    default = true,
    tooltip = "Purging very offensive, especially against rdruid/discs" 
})


sajUI:Checkbox({
    text = awful.textureEscape(88492, 22, "0:13") .. "  Auto Focus in PVP",
    var = "autofocus", -- checked bool =  
    default = true,
    tooltip = "Auto Focus Target in PVP" 
})

sajUI:Checkbox({
    text = awful.textureEscape(51490, 22, "0:13") .. "  Auto Thunderstorm ",
    var = "autothunderstorm", -- checked bool = settings.autothunderstorm
    default = true,
    tooltip = "Using Thunderstorm vs melees" 
})

sajUI:Checkbox({
    text = awful.textureEscape(402482, 22, "0:13") .. "  (BGs) Auto Pickup Flags",
    var = "autopickupflags", -- checked bool =   if not settings.autopickupflags then return end 
    default = true,
    tooltip = "Will Auto Pickup Flags in BGs" 
})


local sajUI = gui:Tab("PVE")

sajUI:Text({
    text = awful.textureEscape(1032476, 25, "0:0") .. awful.colors.red .. " Sajs Elemental",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})


sajUI:Checkbox({
    text = awful.textureEscape(8004, 22, "0:13") .. "  Auto Heal out of Combat",
    var = "autohealPVE", -- checked bool = if not settings.autoheal then return end
    default = false,
    tooltip = "Auto Heal out of combat in PVE" 
})

sajUI:Checkbox({
    text = awful.textureEscape(192077, 22, "0:13") .. "  Auto Windrush Totem ",
    var = "autowindrush", -- checked bool = settings.autowindrus
    default = true,
    tooltip = "Using Windrush Totem automatically in PVE" 
})

sajUI:Checkbox({
    text = awful.textureEscape(196927, 22, "0:13") .. "  Dawnbreaker Instance READ",
    var = "dawnbringershit", -- checked bool = settings.dawnbringershit
    default = false,
    tooltip = "Enable this when u are on dawnbringer instance and you are on the ship right now, disable it when u are not on the ship anymore. There are currently problems with the ships." 
})


local sajUI = gui:Tab("Defensives")

sajUI:Text({
    text = awful.textureEscape(1032476, 25, "0:0") .. awful.colors.red .. " Sajs Elemental",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Checkbox({
    text = awful.textureEscape(108271, 22, "0:13") .. "  Auto Defensives",
    var = "autodefensives", -- checked bool =  
    default = true,
    tooltip = "Auto Using Astral Shift, Ancestral Guidance, Burrow, Earth Ele" 
})

sajUI:Checkbox({
    text = awful.textureEscape(974, 22, "0:13") .. "  Auto Earth Shield",
    var = "autoearthshield", -- checked bool = settings.autospiritwalker
    default = true,
    tooltip = "Using Auto Earth Shield" 
})

sajUI:Checkbox({
    text = awful.textureEscape(877482, 22, "0:13") .. "  My Healer is a monkey ",
    var = "healermonkey", -- checked bool = settings.weplaywithmonkeys
    default = false,
    tooltip = "Enable this only on low rating or when you play with a newbie healer. The rotation will act differently with defensives." 
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
--done--
sajUI:Slider({
    text = awful.textureEscape(202296, 22, "0:3") .. "HP Trinket",
    var = "bmtrinket",
    min = 0,
    max = 100,
    step = 1,
    default = 35,
    valueType = "%",
    tooltip = "The routine will use hp trinket at"
})


-- sajUI:Checkbox({
-- text = awful.textureEscape(208683, 22, "0:13") .. "  Auto Trinket ",
-- var = "autotrinketsmart", -- checked bool = settings.autotrinketsmart
-- default = false,
-- tooltip = "<For Beginners or SS Bot Users> Using Trinket auto in specific situations, not recomennded" 
-- })

local sajUI = gui:Tab("Macros")

sajUI:Text({
    text = awful.textureEscape(1032476, 25, "0:0") .. awful.colors.red .. " Sajs Elemental",
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
    paddingBottom = 1,
})

sajUI:Text({
    text = "|cfff2b0ffIf you not playing with Auto Burst",
    size = 8,
})

sajUI:Text({
    text = "|cfffff394/saj heal",
    size = 10,
    paddingBottom = 5,
})

sajUI:Text({
    text = "|cfff2b0ffRotation will only heal, so you have to turn it of by yourself. It will automatically turn off when we are kicked.",
    size = 8,
})

sajUI:Text({
    text = "|cfffff394/saj lasso",
    size = 10,
    paddingBottom = 5,
})

sajUI:Text({
    text = "|cfff2b0ffwill lasso the target but checking for stunDRs, if target is immune it won't lasso",
    size = 8,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

--------------- --------------- --------------- --------------- VISUALS --------------- --------------- --------------- ---------------

---- ICONS ----

--- disabled because of LUA error --
-- awful.Draw(function(draw)
--     if not settings.classdrawings then return end
--     local icon = nil
--     awful.enemies.loop(function(enemy)
--         local ax, ay, az = enemy.position()
--             if enemy.class2 == "SHAMAN" then 
--                 icon = awful.textureEscape(626006, 20, "0:2")  
--             elseif enemy.class2 == "ROGUE" then 
--                 icon = awful.textureEscape(626005, 20, "0:2") 
--             elseif enemy.class2 == "WARRIOR" then 
--                 icon = awful.textureEscape(626008, 20, "0:2") 
--             elseif enemy.class2 == "WARLOCK" then 
--                 icon = awful.textureEscape(626007, 20, "0:2")  
--             elseif enemy.class2 == "DRUID" then 
--                 icon = awful.textureEscape(625999, 20, "0:2")  
--             elseif enemy.class2 == "PRIEST" then 
--                 icon = awful.textureEscape(626004, 20, "0:2")  
--             elseif enemy.class2 == "PALADIN" then 
--                 icon = awful.textureEscape(626003, 20, "0:2")  
--             elseif enemy.class2 == "MAGE" then 
--                 icon = awful.textureEscape(626001, 20, "0:2")  
--             elseif enemy.class2 == "DEATHKNIGHT" then 
--                 icon = awful.textureEscape(187893, 20, "0:2") 
--             elseif enemy.class2 == "HUNTER" then 
--                 icon = awful.textureEscape(626000, 20, "0:2") 
--             elseif enemy.class2 == "DEMONHUNTER" then 
--                 icon = awful.textureEscape(1260827, 20, "0:2") 
--             elseif enemy.class2 == "MONK" then 
--                 icon = awful.textureEscape(626002, 20, "0:2") 
--             end
--         draw:Text(icon, "GameFontHighlight", ax, ay, az+4)
--     end)
-- end) 


local icon = nil

---SHAMAN---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local ax, ay, az = enemy.position()
        if enemy.class2 == "SHAMAN" then 
            icon = awful.textureEscape(626006, 20, "0:2")  
            draw:Text(icon, "GameFontHighlight", ax, ay, az+4)
        end
    end)
end)

---ROGUE---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local bx, by, bz = enemy.position()
        if enemy.class2 == "ROGUE" then 
            icon = awful.textureEscape(626005, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", bx, by, bz+4)
        end
    end)
end)

---WARRIOR--
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local cx, cy, cz = enemy.position()
        if enemy.class2 == "WARRIOR" then 
            icon = awful.textureEscape(626008, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", cx, cy, cz+4)
        end
    end)
end)

---WARLOCK---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local dx, dy, dz = enemy.position()
        if enemy.class2 == "WARLOCK" then 
            icon = awful.textureEscape(626007, 20, "0:2")  
            draw:Text(icon, "GameFontHighlight", dx, dy, dz+4)
        end
    end)
end)

---DRUID---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local ex, ey, ez = enemy.position()
        if enemy.class2 == "DRUID" then 
            icon = awful.textureEscape(625999, 20, "0:2")  
            draw:Text(icon, "GameFontHighlight", ex, ey, ez+4)
        end
    end)
end)

---PRIEST
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local gx, gy, gz = enemy.position()
        if enemy.class2 == "PRIEST" then 
            icon = awful.textureEscape(626004, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", gx, gy, gz+4)
        end
    end)
end)

---PALADIN---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local hx, hy, hz = enemy.position()
        if enemy.class2 == "PALADIN" then 
            icon = awful.textureEscape(626003, 20, "0:2")
            draw:Text(icon, "GameFontHighlight", hx, hy, hz+4)
        end
    end)
end)

---MAGE---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local jx, jy, jz = enemy.position()
        if enemy.class2 == "MAGE" then 
            icon = awful.textureEscape(626001, 20, "0:2")  
            draw:Text(icon, "GameFontHighlight", jx, jy, jz+4)
        end
    end)
end)

---DK---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local kx, ky, kz = enemy.position()
        if enemy.class2 == "DEATHKNIGHT" then 
            icon = awful.textureEscape(187893, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", kx, ky, kz+4)
        end
    end)
end)

---HUNTER---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local mx, my, mz = enemy.position()
        if enemy.class2 == "HUNTER" then 
            icon = awful.textureEscape(626000, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", mx, my, mz+4)
        end
    end)
end)

---DH---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local nx, ny, nz = enemy.position()
        if enemy.class2 == "DEMONHUNTER" then 
            icon = awful.textureEscape(1260827, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", nx, ny, nz+4)
        end
    end)
end)

---MONK---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local ox, oy, oz = enemy.position()
        if enemy.class2 == "MONK" then 
            icon = awful.textureEscape(626002, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", ox, oy, oz+4)
        end
    end)
end)

local enemyburstingicon = awful.textureEscape(1320372, 40, "0:16")

awful.Draw(function(draw)
    if not settings.burstdrawings then return end
    awful.enemies.loop(function(enemy)
        if enemy.player and not enemy.healer then 
            if enemy.cds then 
            --if player.cds then
                if enemy.distanceTo(player) < 40 then 
                local px, py, pz = enemy.position()
                --local px, py, pz = player.position()
                draw:Text(enemyburstingicon, "GameFontHighlight", px, py, pz+6)
                end 
            end 
        end 
    end)
end)

local hexicon = awful.textureEscape(51514, 45, "0:16")

--possible hexes on enemies--
awful.Draw(function(draw)
    if settings.hexmode == "nohexicons" then return end 
    if settings.hexmode == "hexiconall" then 
        if select(2,GetInstanceInfo()) == "pvp" then return end --in bg--
        if not settings.drawings then return end
        awful.enemies.loop(function(enemy) 
            if enemy.idr == 1 then 
                if enemy.exists then
                local px, py, pz = enemy.position()
                draw:Text(hexicon, "GameFontHighlight", px, py, pz+7)
                end
            end 
        end)
    end 
end)

---possible hexes only on enemyhealer---

--possible hexes on enemyHealer--
awful.Draw(function(draw)
    if settings.hexmode == "nohexicons" then return end 
    if settings.hexmode == "hexiconhealer" then 
        if select(2,GetInstanceInfo()) == "pvp" then return end --in bg--
        if not settings.drawings then return end
        if enemyHealer.idr == 1 then 
            if enemyHealer.exists then
            local px, py, pz = enemyHealer.position()
            draw:Text(hexicon, "GameFontHighlight", px, py, pz+7)
            end
        end 
    end 
end)

---- REST ----

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

------ EARTHEN ------
local earthenicon = awful.textureEscape(198838, 35, "0:16")

awful.Draw(function(draw)
    if not settings.totemdrawings then return end
    awful.triggers.loop(function(trigger) 
        if trigger.id ~= 198839 then return end --friendly earthen--
        if trigger.distance > 60 then return end 
        if trigger.creator.friend then
            local px, py, pz = trigger.position()
            draw:Text(earthenicon, "GameFontHighlight", px, py, pz+3)
        end 
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

----BULKWARD---

--ground stormkeeper

local stonebulkwardicon = awful.textureEscape(108270, 40, "0:16")

awful.Draw(function(draw)
    if not settings.totemdrawings then return end
    awful.friendlyTotems.loop(function(trigger)
        if trigger.id ~= 59712 then return end --stonebulkward totem--
        if trigger.distance < 60 then 
        --if trigger.creator.friend then
            local px, py, pz = trigger.position()
            draw:Text(stonebulkwardicon, "GameFontHighlight", px, py, pz+3)
        end 
    end)
end)

-- awful.Draw(function(draw)
--     if not settings.drawings then return end
--     awful.friendlyTotems.loop(function(trigger)
--         if trigger.id ~= 59712 then return end --stonebulkward totem--
--         if trigger.distance < 60 then
--         local x,y,z = trigger.position()
--         draw:SetColor(100, 255, 100, 200)
--         draw:Outline(x,y,z,40)
--         end
--     end)
-- end)

---- grounding ---
local groundingdicon = awful.textureEscape(204336, 40, "0:16")

awful.Draw(function(draw)
    if not settings.totemdrawings then return end
    awful.friendlyTotems.loop(function(trigger)
        if trigger.id ~= 5925 then return end --grounding
        if trigger.distance < 40 then 
        --if trigger.creator.friend then
            local px, py, pz = trigger.position()
            draw:Text(groundingdicon, "GameFontHighlight", px, py, pz+3)
        end 
    end)
end)

---rooot---

local rooticon = awful.textureEscape(51485, 40, "0:16")

awful.Draw(function(draw)
    if not settings.totemdrawings then return end
    awful.friendlyTotems.loop(function(trigger)
        if trigger.id ~= 60561 then return end --root totem
        if trigger.distance < 40 then 
        --if trigger.creator.friend then
            local px, py, pz = trigger.position()
            draw:Text(rooticon, "GameFontHighlight", px, py, pz+3)
        end 
    end)
end)

---healingstream--- 

local healingstreamicon = awful.textureEscape(5394, 40, "0:16")

awful.Draw(function(draw)
    if not settings.totemdrawings then return end
    awful.friendlyTotems.loop(function(trigger)
        if trigger.id ~= 3527 then return end --healingstream
        if trigger.distance < 40 then 
        --if trigger.creator.friend then
            local px, py, pz = trigger.position()
            draw:Text(healingstreamicon, "GameFontHighlight", px, py, pz+3)
        end 
    end)
end)

--- tremor ----

local tremoricon = awful.textureEscape(8143, 40, "0:16")

awful.Draw(function(draw)
    if not settings.totemdrawings then return end
    awful.friendlyTotems.loop(function(trigger)
        if trigger.id ~= 5913 then return end --tremor
        if trigger.distance < 40 then 
        --if trigger.creator.friend then
            local px, py, pz = trigger.position()
            draw:Text(tremoricon, "GameFontHighlight", px, py, pz+3)
        end 
    end)
end)

---liquid-----

local liquidicon = awful.textureEscape(192222, 40, "0:16")

awful.Draw(function(draw)
    if not settings.totemdrawings then return end
    awful.friendlyTotems.loop(function(trigger)
        if trigger.id ~= 97369 then return end --liquid
        if trigger.distance < 40 then 
        --if trigger.creator.friend then
            local px, py, pz = trigger.position()
            draw:Text(liquidicon, "GameFontHighlight", px, py, pz+3)
        end 
    end)
end)

---capacitor-----

local capacitoricon = awful.textureEscape(192058, 40, "0:16")

awful.Draw(function(draw)
    if not settings.totemdrawings then return end
    awful.friendlyTotems.loop(function(trigger)
        if trigger.id ~= 61245 then return end --liquid
        if trigger.distance < 40 then 
        --if trigger.creator.friend then
            local px, py, pz = trigger.position()
            draw:Text(capacitoricon, "GameFontHighlight", px, py, pz+3)
        end 
    end)
end)

---wrath/skyfury-----

local wrathicon = awful.textureEscape(460697, 40, "0:16")

awful.Draw(function(draw)
    if not settings.totemdrawings then return end
    awful.friendlyTotems.loop(function(trigger)
        if trigger.id ~= 105247 then return end --skyfury
        if trigger.distance < 40 then 
        --if trigger.creator.friend then
            local px, py, pz = trigger.position()
            draw:Text(wrathicon, "GameFontHighlight", px, py, pz+3)
        end 
    end)
end)


----- enemies----

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

--------------- --------------- --------------- --------------- TABLES --------------- --------------- --------------- ---------------

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

 local someDefensives = { 
    108271, --astral shift
    642, --bubble
    1022, --BoP
    186265, --turtle--
    53480, --hunter sac--
    47585, --dispersion--
    104773, --warlock wall unsolving res--
    31224, --cloak--
    5277, --evasion--
    125174, --karma--
    48707, --Anti Magic shell--
    311975, --anti magic shell#2--
    48792, --icebound fortitude--
    292152, --iebound forti#2--
    45438, --iceblock--
    240133, --iceblock#2--
    118038, --die by the sword--
    196718, --darkness--
    209426, --darkness#2--
    363916, --obsidian scales--
    61336, --survival instincts--
    409293, --burrow
    116849, --cocoon
    114893, --bulwark totem--
 }

 local immuneBuffs = { 
    212295, --netherward
    --48707, --ams
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
    408558, --priest immunity fade
}

--------------- --------------- --------------- --------------- SPELLS --------------- --------------- --------------- ---------------

-- Dmg spells --
awful.Populate({
    --flameshock = awful.Spell(188389, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }), --
    lightbolt = awful.Spell(188196, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }), --
    chainlight = awful.Spell(188443, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }),
    lavaburst = awful.Spell(51505, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false, ignoreCasting = true }), --
    earthshock = awful.Spell(8042, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }), --
    earthquakeTarget = awful.Spell(462620, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }), --
    frostshock = awful.Spell(196840, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }), --
    lasso = awful.Spell(305483, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false, ignoreCasting = true }),
    fireele = awful.Spell(198067),
    fireeleAOE = awful.Spell(117588, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    stormele = awful.Spell(192249),
    earthele = awful.Spell(198103),
    eartheleSTUN = awful.Spell(118345, { damage = "physical", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
    astralshift = awful.Spell(108271), 
    totemicrecall = awful.Spell(108285),
    natureSwiftness = awful.Spell(378081),
    ancestralSwiftness = awful.Spell(443454),
    spiritwalker = awful.Spell(79206),
}, elemental, getfenv(1))

-- totems ---
awful.Populate({
    totemtremor = awful.Spell(8143, { ignoreChanneling = false, ignoreFacing = true, ignoreCasting = true }), --
    totemhealingstream = awful.Spell(5394, { ignoreChanneling = false, ignoreFacing = true }), --
    --totemgrounding = awful.Spell(204336, { ignoreChanneling = false, ignoreFacing = true }), --
    totemskyfury = awful.Spell(204330, { ignoreChanneling = false, ignoreFacing = true }),
    totemcounterstrike = awful.Spell(204331, { ignoreChanneling = false, ignoreFacing = true }),
}, elemental, getfenv(1))

local totemstun = NewSpell(192058, { diameter = 7, offsetMin = 0, offsetMax = 2 })
local totemstunPVE = NewSpell(192058, { diameter = 8, offsetMin = 0.7, offsetMax = 1.5 })
--local totemroot = NewSpell(51485, { diameter = 9, offsetMin = 2, offsetMax = 7 })
local totemroot = NewSpell(51485, { 
    effect = "magic", 
    targeted = false,
    circleSteps = 24,
    distChecks = 12,
    radius = 9, 
    minDist = 6, 
    maxDist = 8,
    maxHit = 999, -- should hit NO ONE in bcc
    ignoreFriends = true, -- ignore friends in filter func for performance reasons
    -- filter = function(obj, predDist, position)

    --   -- otherwise hit as many ppl as possible 
    --   if predDist < 6.5 and predDist > 5.5 then
    --     return true
    --   end

    -- end,
    -- sort = function(a, b)
    --   return a.hit > b.hit
    -- end
  })

--local totemslow = NewSpell(355580, { diameter = 10, offsetMin = 0, offsetMax = 2, })
local totemgrounding = NewSpell(204336, { ignoreChanneling = true, ignoreFacing = true, ignoreCasting = true })
local burrow = NewSpell(409293, { ignoreCasting = true, ignoreChanneling = true })
local windshear = NewSpell(57994, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false, ignoreCasting = true })
local totempoisoncleanse = NewSpell(383013, { ignoreChanneling = false, ignoreFacing = true })
local totemwindrush = NewSpell(192077, { diameter = 10, offsetMin = 0, offsetMax = 1 })
local windshearPVE = NewSpell(57994, { ignoreCasting = true })

local flameshock = NewSpell(188389, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }) 
local primowave = NewSpell(375982, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false })

local totemliquidmagma = NewSpell(192222, { diameter = 8, offsetMin = 0, offsetMax = 0 })

-- def/heal --
awful.Populate({
    earthshield = awful.Spell(974, { heal = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    flametongue = awful.Spell(318038, { ignoreChanneling = false, ignoreFacing = true }),
    lightningshield = awful.Spell(192106, { ignoreChanneling = false, ignoreFacing = true }),
    healingsurge = awful.Spell(8004, { heal = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }), --
    dispelcurse = awful.Spell(51886, { heal = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }), --
    ancestralguidance = awful.Spell(108281, { heal = true, ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }), 
    thunderstrikeWard = awful.Spell(462757, { ignoreChanneling = false, ignoreFacing = true }),
}, elemental, getfenv(1))

-- misc --
awful.Populate({
   -- windshear = awful.Spell(57994, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }),
    hex = awful.Spell(51514, { effect = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    unleashshield = awful.Spell(356736, { effect = "magic", ignoreLoS = false, ignoreChanneling = false }),
    purge = awful.Spell(370, { effect = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    greaterpurge = awful.Spell(378773, { effect = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    stormkeeper = awful.Spell(191634, { effect = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    trollracial = awful.Spell(26297, { effect = "magic", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
    orcracial = awful.Spell(33697, { effect = "magic", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
}, elemental, getfenv(1))

-------------------------------------- NEW STUFF FROM TWW --------------------------------------

--local icefury = NewSpell(210714, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false })
local lightningbolt = NewSpell(188196, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false })
local ascendance = NewSpell(114050, { ignoreChanneling = false, ignoreFacing = true })
local bloodlust = NewSpell(204362, { ignoreChanneling = false, ignoreFacing = true })
local bloodlustHorde = NewSpell(204361, { ignoreChanneling = false, ignoreFacing = true })
local totemStoneBulwark = NewSpell(108270, { ignoreChanneling = false, ignoreFacing = true })
local skyfuryBuff = NewSpell(462854, { ignoreChanneling = false, ignoreFacing = true })
local thunderstorm = NewSpell(51490, { effect = "magic", ignoreControl = true  })

--------------- --------------- --------------- --------------- CMDs --------------- --------------- --------------- ---------------
local bursti = false
local heal = false 

cmd:New(function(msg)
    if msg == "burst" then
        burst = not burst
        and awful.alert({ message = awful.colors.red.. "Please use /saj bursti macro and not /saj burst", texture = 135727, duration = awful.tickRate * 2, duration = 9 })
    end
end)

--------------- --------------- --------------- --------------- BURST --------------- --------------- --------------- ---------------
cmd:New(function(msg)
    if msg == "bursti" then
        bursti = not bursti
    end
end)

cmd:New(function(msg)
    if msg == "heal" then
        heal = not heal
    end
end)

orcracial:Callback("burst", function(spell)
    if player.cds or bursti then 
        if target.friendly then return end
        if player.combat then
            if target.distance < 41 then 
                if orcracial.known then
                return spell:Cast(player) and awful.alert({ message = awful.colors.yellow.. "Racial", texture = spell.id, duration = 1 })
                end
            end
        end
    end
end)

trollracial:Callback("burst", function(spell)
    if player.cds or bursti then 
        if target.friendly then return end
        if player.combat then
            if target.distance < 41 then 
                if trollracial.known then
                return spell:Cast(player) and awful.alert({ message = awful.colors.yellow.. "Racial", texture = spell.id, duration = 1 })
                end
            end
        end
    end
end)

--------------- --------------- --------------- --------------- TOTEM STOMP --------------- --------------- --------------- ---------------

local stompTotems = { 5925, 105427, 5913 } --grounding, skyfury, tremor --
local bigTotems = { 59764, 101398, 107100, 53006 } --healing tide, psyfiend, observer, link--
local bigPets = { 101398, 107100 }  --psyfiend, observer--

frostshock:Callback("smalltotems", function(spell)
    if not settings.totemstomp then return end
    --if awful.instanceType2 == "pvp" then return end --we dont need it in bgs--
    awful.totems.stomp(function(totem, uptime)
    if uptime < 0.5 then return end
    if not totem.los then return end
    if player.castID == 305483 then return end --lasso--
        if tContains(stompTotems, totem.id) then
            if spell:Cast(totem) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "stomp", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)

earthshock:Callback("bigtotems", function(spell)
    if not settings.totemstomp then return end
    if awful.instanceType2 == "pvp" then return end --we dont need it in bgs--
    if player.buff(77762) and not player.lockouts.fire then return end 
    if player.used(51505, 1) then return end --we used to kill pets before and traveltime--
    awful.totems.stomp(function(totem, uptime)
    if uptime < 0.5 then return end
    if not totem.los then return end
    if player.maelstrom < 50 then return end 
    if player.castID == 305483 then return end --lasso--
        if tContains(bigTotems, totem.id) then
            if spell:Cast(totem) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "stomp", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)

earthshock:Callback("bigpets", function(spell)
    if not settings.totemstomp then return end
    if player.buff(77762) and not player.lockouts.fire then return end 
    if player.used(51505, 1) then return end --we used to kill pets before and traveltime--
    if awful.instanceType2 == "pvp" then return end --we dont need it in bgs--
    awful.enemyPets.loop(function(pet, uptime) 
    if uptime < 0.5 then return end
    if not pet.los then return end
    if player.maelstrom < 50 then return end 
    if player.castID == 305483 then return end --lasso--
        if tContains(bigPets, pet.id) then
            if spell:Cast(pet) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "stomp", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)

lavaburst:Callback("bigtotems", function(spell)
    if not settings.totemstomp then return end
    if awful.instanceType2 == "pvp" then return end --we dont need it in bgs--
    awful.totems.stomp(function(totem, uptime)
    if uptime < 0.5 then return end
    if not totem.los then return end
    if player.maelstrom < 50 then return end 
    if player.castID == 305483 then return end --lasso--
        if player.buff(77762) then
            if tContains(bigTotems, totem.id) then
                if spell:Cast(totem) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "stomp", texture = spell.id, duration = 1 }) end
                end 
            end
        end 
    end)
end)

lavaburst:Callback("bigpets", function(spell)
    if not settings.totemstomp then return end
    if awful.instanceType2 == "pvp" then return end --we dont need it in bgs--
    awful.enemyPets.loop(function(pet, uptime) 
    if uptime < 0.5 then return end
    if not pet.los then return end
    if player.maelstrom < 50 then return end 
    if player.castID == 305483 then return end --lasso--
        if player.buff(77762) then
            if tContains(bigPets, pet.id) then
                if spell:Cast(pet) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "stomp", texture = spell.id, duration = 1 }) end
                end 
            end
        end 
    end)
end)

--------------- --------------- --------------- --------------- DEFENSIVE --------------- --------------- --------------- --------------

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
    125174, --Karma
    108271, -- astral shift
    114893, --bulwark
}

astralshift:Callback("nohealer", function(spell)
    if not settings.autodefensives then return end 
    if healer.exists then return end 
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.hp > 99 then return end 
    local total, melee, ranged, cooldowns = player.v2attackers()
        if cooldowns > 0 then
            awful.enemies.loop(function(enemy) 
                if not enemy.isHealer and enemy.los and enemy.target.isUnit(player) and enemy.distanceTo(player) < 40 then
                    if spell:Cast() then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end
            end)
        end
end)

astralshift:Callback("nobigdefs", function(spell)
    if settings.healermonkey then return end 
    if not settings.autodefensives then return end 
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if healer.cc and healer.castID == 370984 then return end  --evoker is in cc but communion on--
    if healer.cc and healer.channelID == 370984 then return end  --evoker is in cc but communion on--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if cooldowns > 1 then
        if healer.cc and healer.ccRemains > 1 then
            awful.enemies.loop(function(enemy) 
                if not enemy.isHealer and enemy.los and enemy.target.isUnit(player) and enemy.distanceTo(player) < 40 then
                    if spell:Cast() then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                    end 
                end
            end)
        end
    end
end)

astralshift:Callback("danger", function(spell)
    if settings.healermonkey then return end 
    if not settings.autodefensives then return end 
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if healer.cc and healer.castID == 370984 then return end  --evoker is in cc but communion on--
    if healer.cc and healer.channelID == 370984 then return end  --evoker is in cc but communion on--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if cooldowns > 1 then
        if player.hp < 65 then
            awful.enemies.loop(function(enemy) 
                if not enemy.isHealer and enemy.los and enemy.target.isUnit(player) and enemy.distanceTo(player) < 40 then
                    if spell:Cast() then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                    end 
                end
            end)
        end
    end
end)


--wir haben hier healer.cc entfernt--
astralshift:Callback("nobigdefs-MonkeyHealer", function(spell)
    if settings.healermonkey then
        if not settings.autodefensives then return end 
        if player.buffFrom(BigDef) then return end --we already have big def up--
        if player.buffFrom(noPanic) then return end --we already have big def up--
        if healer.cc and healer.castID == 370984 then return end  --evoker is in cc but communion on--
        if healer.cc and healer.channelID == 370984 then return end  --evoker is in cc but communion on--
        local total, melee, ranged, cooldowns = player.v2attackers()
        if cooldowns > 1 and total > 1 then
            --if healer.cc and healer.ccRemains > 1 then
                awful.enemies.loop(function(enemy) 
                    if not enemy.isHealer and enemy.los and enemy.target.isUnit(player) and enemy.distanceTo(player) < 40 then
                        if spell:Cast() then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                        end 
                    end
                end)
           -- end
        end
    end 
end)

astralshift:Callback("inBGs", function(spell)
    if not settings.autodefensives then return end 
    if awful.instanceType2 ~= "pvp" then return end 
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if cooldowns > 1 and total > 1 then
       -- if healer.cc and healer.ccRemains > 1 then
            if player.hp < 90 then 
                awful.enemies.loop(function(enemy) 
                    if not enemy.isHealer and enemy.los and enemy.target.isUnit(player) and enemy.distanceTo(player) < 40 then
                        if spell:Cast() then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                        end 
                    end
                end)
            end 
        --end
    end
end)

astralshift:Callback("inBGsLow", function(spell)
    if settings.mode == "pvemode" then return end 
    if not settings.autodefensives then return end 
    if awful.instanceType2 ~= "pvp" then return end 
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.hp < 50 then 
        awful.enemies.loop(function(enemy) 
            if not enemy.isHealer and enemy.los and enemy.target.isUnit(player) and enemy.distanceTo(player) < 40 then
                if spell:Cast() then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end 
end)

burrow:Callback("BGslow", function(spell)
    if settings.mode == "pvemode" then return end 
    if not settings.autodefensives then return end 
    if awful.instanceType2 ~= "pvp" then return end 
    if player.buffFrom(noPanic) then return end --we already have big def up--
    awful.enemies.loop(function(unit)
        if player.hp < 30 then
            if unit.los then
                if unit.target.isUnit(player) then --and unit.buff(185422) then --or unit.cooldown(408) < 1 then ---enemy has offensive CDs and shadowdance or kidney rdy targeting me---
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                    end 
                end
            end 
        end 
    end)
end)


burrow:Callback(function(spell)

    if settings.mode == "pvemode" then return end 
    if not settings.autodefensives then return end 

    local link = awful.totems.find(function(obj) return obj.id == 53006 and obj.distance < 10 end)
    if link then return end 

    if healer.cc and healer.castID == 370984 then return end  --evoker is in cc but communion on--
    if healer.cc and healer.channelID == 370984 then return end  --evoker is in cc but communion on--

    --local healingtide = awful.totems.find(function(obj) return obj.id == 59764 and obj.distance < 35 end)
    --if healingtide then return end 

    --if healer.buff(642) then return end --our healer has bubble enabled---
    if player.buff(108271) then return end ---astral shift
    if player.buffFrom(noPanic) then return end --bop--
    if not spell:Castable(player) then return end
    if healer.exists and healer.cc then 
        if player.hp < 25 then
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
            end 
        end
    end 
end)

--- healercc hier entfernt --
burrow:Callback("MonkeyHealer", function(spell)
    if settings.healermonkey then
        if settings.mode == "pvemode" then return end 
        if not settings.autodefensives then return end 

        local link = awful.totems.find(function(obj) return obj.id == 53006 and obj.distance < 10 end)
        if link then return end 

        if healer.cc and healer.castID == 370984 then return end  --evoker is in cc but communion on--
        if healer.cc and healer.channelID == 370984 then return end  --evoker is in cc but communion on--

        --local healingtide = awful.totems.find(function(obj) return obj.id == 59764 and obj.distance < 35 end)
        --if healingtide then return end 

        --if healer.buff(642) then return end --our healer has bubble enabled---
        if player.buff(108271) then return end ---astral shift
        if player.buffFrom(noPanic) then return end --bop--
        if not spell:Castable(player) then return end
        --if healer.exists and healer.cc then 
            if player.hp < 30 then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        --end 
    end 
end)

burrow:Callback("nohealer", function(spell)

    if settings.mode == "pvemode" then return end 
    if not settings.autodefensives then return end 

    if healer.exists then return end 

    awful.enemies.loop(function(enemy) 
        if enemy.los then
            if player.buffFrom(noPanic) then return end --bop--
            if not spell:Castable(player) then return end
            if player.hp < 25 then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end 
    end)
end)

burrow:Callback("low", function(spell)
    if settings.mode == "pvemode" then return end 
    if not settings.autodefensives then return end 
    if player.buffFrom(noPanic) then return end --we already have big def up--
    awful.enemies.loop(function(unit)
        if player.hp < 15 then
            if unit.los then
                if unit.target.isUnit(player) then --and unit.buff(185422) then --or unit.cooldown(408) < 1 then ---enemy has offensive CDs and shadowdance or kidney rdy targeting me---
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                    end 
                end
            end 
        end 
    end)
end)

--------------- --------------- --------------- --------------- DAMAGE --------------- --------------- --------------- ---------------

flameshock:Callback("target", function(spell)
    if player.cooldown(375982) < 1 then return end --we can primo our main target--
    if target.buff(212295) then return end --netherward--
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.dist > flameshock.range then return end
    if target.friendly then return end
    if target.los then
        if target.debuffRemains(flameshock.id, player) < 3 then 
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)

---on manual burst we want to flameshock the target first ofc--
flameshock:Callback("targetManualBurst", function(spell)
    if settings.autoburst then return end --we can primo our main target--
    if target.buff(212295) then return end --netherward--
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.dist > flameshock.range then return end
    if target.friendly then return end
    if target.los then
        if target.debuffRemains(flameshock.id, player) < 3 then 
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)

--spread enemies--
flameshock:Callback("spread", function(spell)
    if player.hasTalent(468625) then return end --storm build--

    if player.used(primowave.id, 1) then return end --better stuff to do--

    awful.enemies.loop(function(enemy)
        if not enemy.isPlayer then return end 
        if enemy.buff(212295) then return end  --netherward--
        if enemy.immuneMagicDamage then return end 
        if enemy.buffFrom(immuneBuffs) then return end 
        if not spell:Castable(enemy) then return end
        if enemy.dead then return end
        if enemy.bcc then return end
        --if enemy.cc then return end
        if enemy.dist > flameshock.range then return end
        if enemy.debuff(flameshock.id, player) then return end 
        if enemy.los then
            if enemy.debuffRemains(flameshock.id, player) < 4 then
                if not player.target.isUnit(enemy) then --we do it on off target mostly--
                    if spell:Cast(enemy) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end 
            end
        end
    end)
end)

--spread enemies--
flameshock:Callback("spreadStormkeeper", function(spell)
    if not player.hasTalent(468625) then return end --storm build--

    if player.used(primowave.id, 1) then return end --better stuff to do--

    awful.enemies.loop(function(enemy)
        if not enemy.isPlayer then return end 
        if enemy.buff(212295) then return end  --netherward--
        if enemy.immuneMagicDamage then return end 
        if enemy.buffFrom(immuneBuffs) then return end 
        if not spell:Castable(enemy) then return end
        if enemy.dead then return end
        if enemy.bcc then return end
        --if enemy.cc then return end
        if enemy.dist > flameshock.range then return end
        if enemy.debuff(flameshock.id, player) then return end 
        if enemy.los then
            if enemy.debuffRemains(flameshock.id, player) < 4 then
                if not player.target.isUnit(enemy) then --we do it on off target mostly--
                    if spell:Cast(enemy) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
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
    [55659] = true, -- Wild Imp
}

local dotBlacklistTotems = { 
    [355580] = true, --root totem
    [204336] = true, -- grouding
    [8143] = true, -- tremor
}

---hier eventuell noch enemyPets zu einfach enemy loop ändern und bei dotblacklist einfach enemy.id machen 
--spreadpets--
flameshock:Callback("spreadpets", function(spell)
    if player.hasTalent(468625) then return end --storm build--
    --if select(2,GetInstanceInfo()) == "pvp" then return end --in bg or arena--

    local fscount = 0

    awful.enemyPets.loop(function(pet)
    if dotBlacklist[pet.id] then return end
    if pet.name == "Limestone Falcon" then return end  --open world shit in dornogal
    if pet.name == "Ashwhite Kestrel" then return end --open world shit in dornogal
    if dotBlacklistTotems[pet.id] then return end
    if pet.dist > flameshock.range then return end
    if pet.debuff(flameshock.id, player) then return end 

    if pet.debuff(flameshock.id, player) then fscount = fscount + 1 end 
    if fscount >= 8 then return true end 

        if pet.los then
            if spell:Cast(pet) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)

-- --old-- spread low prio
flameshock:Callback("spreadLowPrio", function(spell)

    if player.buff(77762) then return end --lava surge--
    if player.maelstrom >= 55 then return end --we earthshock--
    if player.used(primowave.id, 2) then return end --better stuff to do--

    awful.enemies.loop(function(enemy)
        if enemy.buff(212295) then return end  --netherward--
        if enemy.immuneMagicDamage then return end 
        if enemy.buffFrom(immuneBuffs) then return end 
        if not spell:Castable(enemy) then return end
        if enemy.dead then return end
        if enemy.bcc then return end
        if enemy.cc then return end
        if enemy.dist > flameshock.range then return end
        if enemy.debuff(flameshock.id, player) then return end 
        if enemy.los then
            if enemy.debuffRemains(flameshock.id, player) < 3 then
                if spell:Cast(enemy) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end)
end)

primowave:Callback("burst", function(spell)
    if not settings.autoburst then return end
    
    --if player.buff(77762) then return end --lava surge--

    local fscount = 0
    awful.enemies.loop(function(enemy)
        
        -- if awful.instanceType2 == "arena" and enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
        -- if awful.instanceType2 == "arena" and fscount <= 1 then return end 

            if target.buff(212295) then return end --netherward--
            if target.buff(8178) then return end --grounding--
            if target.immuneMagicDamage then return end 
            if target.buffFrom(immuneBuffs) then return end 
            if not spell:Castable(target) then return end
            if target.dead then return end
            if target.bcc then return end
            if target.dist > primowave.range then return end
            if target.friendly then return end
            --if target.debuff(flameshock.id, player) then return end 
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end

    end)
end)

local onusePvpTrinket = awful.Item{218421, 218713}
onusePvpTrinket:Update(function(item)
    if not onusePvpTrinket.equipped then return end
    if not item:Usable(player) then return end
    if player.used(375982, 2) then
      return item:Use() --and awful.alert({ message = awful.colors.red.. "Battlemaster", texture = 5512, duration = 1 })
    end
end)


primowave:Callback("macrobursti", function(spell)
    if settings.autoburst then return end
    
    if bursti then 

        local fscount = 0
        --awful.enemies.loop(function(enemy)

            --if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
            --if fscount >= 1 then 

                if target.buff(8178) then return end --grounding--
                if target.buff(212295) then return end --netherward--
                if target.immuneMagicDamage then return end 
                if target.buffFrom(immuneBuffs) then return end 
                if not spell:Castable(target) then return end
                if target.dead then return end
                if target.bcc then return end
                if target.dist > primowave.range then return end
                if target.friendly then return end
                --if target.debuff(flameshock.id, player) then return end 
                if target.los then
                    if spell:Cast(target) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end

           -- end 
       -- end)
    end 
end)

ancestralSwiftness:Callback("PVP", function(spell)
    if player.buff(77762) then return end --lavaprocc--
   -- if player.buff(462725) and player.buffStacks(462725) > 1 then return end --stormfrenzy procc from talent--
    if not player.combat then return end 
    if player.buff(191634) then return end --stormkeeper available, so instants rdy--
    --if player.casting or player.channeling then return end
    --if player.moving and not player.buff(79206) then 
    if player.used(375982, 1) then --primo wave--
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

lavaburst:Callback("targetProcc", function(spell)
    if target.buff(212295) then return end --netherward--
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if not target.debuff(188389) and awful.instanceType2 ~= "arena" then return end --flame shock for crit--
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > lavaburst.range then return end
    --if player.lastCast == 51505 and player.maelstrom > 50 then return end 
    --if player.maelstrom > 50 then return end 
    if target.los then
        if player.buff(77762) or player.buff(375986) then --lava surge or primo buff--
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
    end
end)

lavaburst:Callback("targetCasting", function(spell)
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if not target.debuff(188389) and awful.instanceType2 == "arena" then return end --flame shock for crit--
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > lavaburst.range then return end
    --if player.lastCast == 51505 and player.maelstrom > 50 then return end 
    --if player.maelstrom > 50 then return end 
    if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

earthshock:Callback("target", function(spell)
    if target.buff(212295) then return end --netherward--
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > earthshock.range then return end
    if player.buff(77762) then return end 
    --if player.lastCast == 8042 then return end --earthshock--
    if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    end
end)

earthele:Callback(function(spell)
    awful.group.loop(function(group)
    if not settings.autodefensives then return end 
        --if select(2,GetInstanceInfo()) == "arena" then
            if group.buffFrom(noPanic) then return end 
            if group.buffFrom(someDefensives) then return end 
            --if healer.cc and group.hp < 30 or group.hp < 50 then  => will so nicht, also nur player atm
            if healer.cc and player.hp < 30 then 
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end 
        --end 
    end)
end)

eartheleSTUN:Callback(function(spell)
    if select(2,GetInstanceInfo()) == "arena" then
        awful.enemies.loop(function(enemy)
            if enemy.immunePhysicalDamage then return end 
            if enemy.buffFrom(immuneBuffs) then return end 
            if not spell:Castable(enemy) then return end
            if enemy.dist > 40 then return end
            if enemy.cc then return end 
            if enemy.isHealer then return end
            --if not enemy.isPlayer then return end 
            if enemy.sdr == 1 then 
                if spell:Cast(enemy) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end 
        end)
    end 
end)

stormele:Callback("burst", function(spell)
    if not settings.autoburst then return end
    if not player.hasTalent(192249) then return end --fire ele talent--
    --if bursti then
    --awful.friendlyPets.loop(function(unit) 
   -- if unit.exists and unit.name == "Primal Earth Elemental" then return end --earth ele already out--
    if player.used(198103, 70) then return end --earth ele used--
    if player.used(192249, 24) then return end --storm ele used--
        
        awful.enemies.loop(function(enemy)

            -- if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
            -- if fscount >= 1 then 

                if target.buff(212295) then return end --netherward--
                if target.immuneMagicDamage then return end
                if target.buffFrom(immuneBuffs) then return end 
                if not spell:Castable(target) then return end
                if target.dead then return end
                if target.bcc then return end
                if target.dist > 40 then return end
                if target.friendly then return end
                --if target.debuff(flameshock.id, player) then return end 
                if target.los then
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end
            --end
        end)
   -- end) 
end)


stormele:Callback("macrobursti", function(spell)
    if not player.hasTalent(192249) then return end --fire ele talent--
    if player.used(192249, 24) then return end --storm ele used--
    if settings.autoburst then return end
    if bursti then
        if target.buff(212295) then return end --netherward--
        if target.immuneMagicDamage then return end 
        if target.buffFrom(immuneBuffs) then return end 
        if not spell:Castable(target) then return end
        if target.dead then return end
        if target.bcc then return end
        if target.dist > 40 then return end
        if target.friendly then return end
        --if target.debuff(flameshock.id, player) then return end 
        if target.los then
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)

fireele:Callback("burst", function(spell)
    if not settings.autoburst then return end
    if not player.hasTalent(198067) then return end --fire ele talent--
    --if bursti then
    --awful.friendlyPets.loop(function(unit) 
   -- if unit.exists and unit.name == "Primal Earth Elemental" then return end --earth ele already out--
    if player.used(198103, 70) then return end --earth ele used--
    if player.used(198067, 36) then return end --fire ele used--
        local fscount = 0
        awful.enemies.loop(function(enemy)

            if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
            if fscount >= 1 then 

                if target.buff(212295) then return end --netherward--
                if target.immuneMagicDamage then return end
                if target.buffFrom(immuneBuffs) then return end 
                if not spell:Castable(target) then return end
                if target.dead then return end
                if target.bcc then return end
                if target.dist > 40 then return end
                if target.friendly then return end
                --if target.debuff(flameshock.id, player) then return end 
                if target.los then
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end
            end
        end)
   -- end) 
end)

fireele:Callback("macrobursti", function(spell)
    if not player.hasTalent(198067) then return end --fire ele talent--
    if player.used(198067, 36) then return end --fire ele used--
    if settings.autoburst then return end
    if bursti then
        if target.buff(212295) then return end --netherward--
        if target.immuneMagicDamage then return end 
        if target.buffFrom(immuneBuffs) then return end 
        if not spell:Castable(target) then return end
        if target.dead then return end
        if target.bcc then return end
        if target.dist > 40 then return end
        if target.friendly then return end
        --if target.debuff(flameshock.id, player) then return end 
        if target.los then
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end
end)

local elepets = { 61029 }  --firele--

fireeleAOE:Callback("burst", function(spell)
    if not player.hasTalent(117013) then return end 
    --if bursti then
        if not fireele.used(25) then return end 
        if fireeleAOE.cd > 1 then return end 
        if target.buff(212295) then return end --netherward--
        if target.immuneMagicDamage then return end 
        if target.buffFrom(immuneBuffs) then return end 
        if not spell:Castable(target) then return end
        if target.dead then return end
        if target.bcc then return end
        if target.dist > 40 then return end
        if target.friendly then return end
        if target.los then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
    --end
end)

-- root procc vs melees --  noch surge of power procc ID adden 
-- frostshock:Callback("procc", function(spell)
--     awful.enemies.loop(function(enemy)
--         if enemy.role ~= "melee" then return end 
--         if enemy.buff(212295) then return end --netherward--
--         if not spell:Castable(enemy) then return end
--         if target.buffFrom(immuneBuffs) then return end 
--         if enemy.dead then return end
--         if enemy.bcc then return end
--         if enemy.dist > frostshock.range then return end
--         if enemy.rooted then return end 
--         if enemy.rootDR < 1 then return end --only full DR--
--         if enemy.los then
--             if enemy.cds and healer.cc then 
--                 if player.buff(285514) then 
--                     if spell:Cast(enemy) then
--                         if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
--                     end 
--                 end
--             end 
--         end
--     end)
-- end)


-- icefury:Callback("targetProcc", function(spell)
--     if not player.hasTalent(462816) then return end  ---icefury talent---
--     if wasCasting[spell.id] then return end
--     if target.immuneMagicDamage then return end 
--     if target.buffFrom(immuneBuffs) then return end 
--     if not spell:Castable(target) then return end
--     if target.dead then return end
--     if target.bcc then return end
--     if target.friendly then return end
--     if target.dist > 40 then return end
--     if target.los then
--         if spell:Cast(target) then
--             if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
--         end 
--     end
-- end)

frostshock:Callback("targetProcc", function(spell)
    if wasCasting[spell.id] then return end
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if target.los then
        if player.buff(210714) then --frostshock procc
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
    end
end)

frostshock:Callback("icefury", function(spell)
    if wasCasting[spell.id] then return end
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if target.los then
        if player.buff(462818) then --icefury procc
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
    end
end)

frostshock:Callback("icefuryExecute", function(spell)
    if not target.player then return end 
    if wasCasting[spell.id] then return end
    if target.immuneMagicDamage then return end 
    if target.buffFrom(BigDef) then return end --we already have big def up--
    if target.buffFrom(noPanic) then return end --we already have big def up--
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if target.los then
        if player.buff(462818) then --icefury procc
            if target.hp < 30 then 
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end 
        end 
    end
end)

frostshock:Callback("targetProccExecute", function(spell)
    if not target.player then return end 
    if wasCasting[spell.id] then return end
    if target.immuneMagicDamage then return end 
    if target.buffFrom(BigDef) then return end --we already have big def up--
    if target.buffFrom(noPanic) then return end --we already have big def up--
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if target.los then
        if player.buff(210714) then --frostshock procc
            if target.hp < 10 then 
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end 
        end 
    end
end)


stormkeeper:Callback("PVE", function(spell)
    if not settings.autoburst then return end 
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if spell:Cast(player) then
        ---hiar noch adden, wenn enemy healer im cc--
        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
    end 
end)

stormkeeper:Callback("PVEmacro", function(spell)
    if settings.autoburst then return end 
    if bursti then 
        if target.immuneMagicDamage then return end 
        if target.buffFrom(immuneBuffs) then return end 
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > 40 then return end
        if spell:Cast(player) then
            ---hiar noch adden, wenn enemy healer im cc--
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    end 
end)

lightningbolt:Callback("targetProcc", function(spell)
    --if not settings.autolb then return end
    if wasCasting[spell.id] then return end
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if target.los then
        if player.buff(191634) then ---stormkeeper buff--
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
    end
end)

lightningbolt:Callback("targetTempestAOE", function(spell)
    --if not settings.autolb then return end
    if wasCasting[spell.id] then return end
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if target.los then
        local abc, abcCount = enemies.around(target, 12, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
        if abc and abcCount >= 2 then  --we chainlight--
            if player.buff(454015) then ---tempest buff--
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end 
        end 
    end
end)

lightningbolt:Callback("targetTempestST", function(spell)
    if wasCasting[spell.id] then return end
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if target.los then
        local abc, abcCount = enemies.around(target, 12, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
        if abc and abcCount >= 2 then return end --we only awnt it on ST prio higher than earthshock--
        if player.buff(454015) then ---tempest buff--
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
    end
end)

local lbstack = NewSpell(51505)

--- nur wenn wir kein mana haben, auf fire locked sind und dadurch nicth healen können--
lightningbolt:Callback("targetCasting", function(spell)
    --if not settings.autolb then return end
    --if awful.instanceType2 == "arena" then return end 
    if awful.instanceType2 == "arena" then return end 
    --if not player.lockouts.fire and player.cooldown(51505) < 0.5 then return end 
    if not player.lockouts.fire and lbstack.charges >= 1 then return end 
    if player.mana >= 30000 and player.hp < 70 and settings.autoheal then return end --we can heal instead and have this option enabled--
    awful.fullGroup.loop(function(group)
    if player.mana >= 35000 and group.hp < 70 and settings.autoheal and group.distanceTo(player) < 40 and group.los then return end --we can heal in arena and we hold some mana for totems--  and awful.instanceType2 == "arena" 
        --if wasCasting[spell.id] then return end
        if target.immuneMagicDamage then return end 
        if target.buffFrom(immuneBuffs) then return end 
        if not spell:Castable(target) then return end
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > 40 then return end
        if target.los then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)

---stormfrenzy talent, if talented---
lightningbolt:Callback("targetStormFrenzyProcc", function(spell)
   -- if not settings.autolb then return end
    --if not player.hasTalent(462695) then return end 
   --if wasCasting[spell.id] then return end
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if target.los then
        if player.buff(462725) and player.buffStacks(462725) > 1  then --stormfrenzy procc from talent--
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
    end
end)

ascendance:Callback("burst", function(spell)
if not settings.autoburst then return end
if player.buff(114050) then return end --already ascendance procc--
    local fscount = 0
    awful.enemies.loop(function(enemy)

        if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
        if fscount >= 2 then 

            if target.immuneMagicDamage then return end
            if target.buffFrom(immuneBuffs) then return end 
            --if not spell:Castable(target) then return end
            if target.dead then return end
            if target.bcc then return end
            if target.dist > 40 then return end
            if target.friendly then return end
            if target.los then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end) 
end)

---we use insta burst in 2s--
ascendance:Callback("burst2S", function(spell)
if not settings.autoburst then return end
if healer.exists then return end ---healer exists so its not 2s--
if awful.instanceType2 ~= "arena" then return end --only in arena--
if player.buff(114050) then return end --already ascendance procc--
    local fscount = 0
    awful.enemies.loop(function(enemy)

        if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
        if fscount >= 1 then 

            if target.immuneMagicDamage then return end
            if target.buffFrom(immuneBuffs) then return end 
            --if not spell:Castable(target) then return end
            if target.dead then return end
            if target.bcc then return end
            if target.dist > 40 then return end
            if target.friendly then return end
            if target.los then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end) 
end)

ascendance:Callback("Manualburst", function(spell)
    if settings.autoburst then return end
    if player.buff(114050) then return end --already ascendance procc--
    local fscount = 0
       awful.enemies.loop(function(enemy)
    
            if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
            if fscount >= 2 then 
    
                if target.immuneMagicDamage then return end
                if target.buffFrom(immuneBuffs) then return end 
                --if not spell:Castable(target) then return end
                if target.dead then return end
                if target.bcc then return end
                if target.dist > 40 then return end
                if target.friendly then return end
                if target.los then
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end
            end
        end) 
    end)


ascendance:Callback("Stormkeeperburst", function(spell)
if not settings.autoburst then return end
if not player.hasTalent(468625) then return end 
if player.buff(114050) then return end --already ascendance procc--

    awful.enemies.loop(function(enemy)

        if player.buff(191634) then  --stormkeeper--

            if target.immuneMagicDamage then return end
            if target.buffFrom(immuneBuffs) then return end 
            --if not spell:Castable(target) then return end
            if target.dead then return end
            if target.bcc then return end
            if target.dist > 40 then return end
            if target.friendly then return end
            if target.los then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end) 
end)

ascendance:Callback("StormkeeperManualburst", function(spell)
if settings.autoburst then return end
if player.buff(114050) then return end --already ascendance procc--

    awful.enemies.loop(function(enemy)

        if bursti and player.buff(191634) then 
            if target.immuneMagicDamage then return end
            if target.buffFrom(immuneBuffs) then return end 
            --if not spell:Castable(target) then return end
            if target.dead then return end
            if target.bcc then return end
            if target.dist > 40 then return end
            if target.friendly then return end
            if target.los then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
        end
    end) 
end)

ascendance:Callback("PVEburst", function(spell)
    if not settings.autoburst then return end
    if player.buff(114050) then return end --already ascendance procc--
        local fscount = 0
        awful.enemies.loop(function(enemy)
    
            if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
            if fscount >= 2 or player.buff(191634) then 
    
                if target.immuneMagicDamage then return end
                if target.buffFrom(immuneBuffs) then return end 
                --if not spell:Castable(target) then return end
                if target.dead then return end
                if target.bcc then return end
                if target.dist > 40 then return end
                if target.friendly then return end
                if target.los then
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end
            end
        end) 
    end)

bloodlust:Callback("burst", function(spell)
if awful.instanceType2 == "party" then return end --dungeon--
if awful.instanceType2 == "raid" then return end --raid--
--if not settings.autoburst then return end
if not player.hasTalent(193876) then return end --pvp talent heroism--
    local fscount = 0
    awful.enemies.loop(function(enemy)

        if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
        if fscount >= 2 or bursti then 
            
            if target.immuneMagicDamage then return end
            if target.buffFrom(immuneBuffs) then return end 
            if target.dead then return end
            if target.bcc then return end
            if target.dist > 40 then return end
            if target.los then
                awful.group.loop(function(group)
                    if group.isHealer then return end -- we don't want to use it on healer --
                    if group.los then
                        if spell:Cast(group) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                        end 
                    end 
                end)
            end
        end
    end) 
end)

bloodlustHorde:Callback("burst", function(spell)
    if awful.instanceType2 == "party" then return end --dungeon--
    if awful.instanceType2 == "raid" then return end --raid--
    --if not settings.autoburst then return end
    if not player.hasTalent(193876) then return end --pvp talent heroism--
        local fscount = 0
        awful.enemies.loop(function(enemy)
    
            if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
            if fscount >= 2 or bursti then 
                
                if target.immuneMagicDamage then return end
                if target.buffFrom(immuneBuffs) then return end 
                if target.dead then return end
                if target.bcc then return end
                if target.dist > 40 then return end
                if target.los then
                    awful.group.loop(function(group)
                        if group.isHealer then return end -- we don't want to use it on healer --
                        if group.los then
                            if spell:Cast(group) then
                                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                            end 
                        end 
                    end)
                end
            end
        end) 
    end)

totemStoneBulwark:Callback(function(spell)
    if not settings.autototem then return end 
    if awful.instanceType2 ~= "arena" then return end 
    if not player.combat then return end 
    if player.buffFrom(noPanic) then return end 
    if player.buffFrom(someDefensives) and player.hp > 40 then return end 
    if player.mana < 5000 then return end -- costs of that totem---
    if player.hp < 70 then
        if healer.cc or healer.bcc then --our healer is in cc--
            awful.enemies.loop(function(enemy)
                if enemy.distanceTo(player) < 40 and enemy.target.isUnit(player) then 
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                    end 
                end
            end)
        end
    end
end)

totemStoneBulwark:Callback("emergency", function(spell)
    if not settings.autototem then return end 
    if player.buffFrom(noPanic) then return end  ---we are fine---
    if player.buffFrom(someDefensives) and player.hp > 40 then return end 
    if not player.combat then return end 
    --if player.buffFrom(someDefensives) then return end  ---we are fine---
    if player.mana < 5000 then return end -- costs of that totem---
    if player.hp < 50 then
        awful.enemies.loop(function(enemy)
            if enemy.distanceTo(player) < 40 then 
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end
end)

skyfuryBuff:Callback(function(spell)
    if player.combat then return end 
    awful.fullGroup.loop(function(group)
        if not group.los then return end
        if group.distanceTo(player) > 40 then return end 
        if not group.buff(462854) then
            if spell:Cast(group) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
            end 
        end
    end)
end)

local stunList = {
    [5211] = { uptime = 0.8, min = 0.5 }, --bash--
    [203123] = { uptime = 0.8, min = 0.5 }, --maim--
    [163505] = { uptime = 0.8, min = 0.5 }, --rake--
    [853] = { uptime = 0.8, min = 0.5 },  --hoj--
    [119381] = { uptime = 0.8, min = 0.5 }, --legwsweep?--
    [1833] = { uptime = 0.8, min = 0.5 },  --cheashot--
    [408] = { uptime = 0.8, min = 0.5 },  --kidney--
    [132169] = { uptime = 0.8, min = 0.5 }, --stormbolt--
    [132168] = { uptime = 0.8, min = 0.5 }, --shockwave--
    [287250] = { uptime = 0.8, min = 0.5 },  --DK dead of winter--
    [179057] = { uptime = 0.8, min = 0.5 }, --chaos nova--
    [211881] = { uptime = 0.8, min = 0.5 }, --fel eruption--
    [30283] = { uptime = 0.8, min = 0.5 }, --shadowfury--
    [221562] = { uptime = 0.8, min = 0.5 }, --DK asphyxiate stun
    [377047] = { uptime = 0.8, min = 0.5 }, --DK absolute zero 
}

thunderstorm:Callback(function(spell)
    if not settings.autothunderstorm then return end
    awful.enemies.loop(function(enemy, i, uptime) 
        --if uptime < 0.7 then return end 
        if not enemy.player then return end 
        if enemy.role ~= "melee" then return end -- if not meele then dont --
        if enemy.buff(227847) then return end --bladestorm--
        if enemy.distanceTo(player) > 10 then return end
        if enemy.immuneMagicDamage then return end 
        if enemy.buff(642) then return end --bubble--
        if enemy.buff(48707) then return end --AMS--
        if enemy.buff(345228) then return end --lolstorm--
        if enemy.buff(23920) then return end --spell reflect--
        if not enemy.los then return end --enemy is not in sight for casting--
       -- if not spell:Castable(enemy) then return end --is castable like when he has immunities--
       -- if enemy.rootDR <= 0.25 then return end --only rooting him when he is on half or full dr--
        if enemy.distanceTo(player) < 10 then
            if player.debuffFrom(stunList) then --or player.debuff(372245) then ---enemy stunned me--- +dk stun
            return spell:Cast(player) and awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 })
            end
        end
    end)
end)

--------------- --------------- --------------- --------------- KICKS --------------- --------------- --------------- ---------------
--- Kick ---
local kickList = { 5782, 33786, 116858, 2637, 375901, 211015, 210873, 277784, 277778, 269352, 211004, 51514, 28272, 118, 277792, 161354, 277787, 
161355, 161353, 120140, 61305, 61721, 61780, 28271, 82691, 391622, 20066, 605, 113724, 198898, 186723, 32375, 982, 320137, 254418, 8936, 82326, 
209525, 289666, 2061, 283006, 19750, 77472, 199786, 204437, 227344, 30283, 115175, 191837, 124682, 360806, 382614, 382731, 382266, 8004, 355936, 367226, 2060, 64843, 263165, 228260, 
205021, 404977, 421453, 342938, 316099, 200652, 51505, 1064, 48181, 120644, 410126 } --neu geadded: lavaburst, chainheal, haunt, halo--

---channels die von der castbar "weniger" werden, anders wie bei penance wo die castbar auch channeld ist aber der balken "voll" wird--
--soothing mist, penance, essence font, Lasso, Convoke, Dream Breath, Spiritbloom, Sleep Walk, Gotteshymne, Void Torrent, Desintegrate, ray of frost, time skip--
local kickChannels = { 115175, 47540, 191837, 305483, 391528, 355936, 367226, 360806, 64843, 263165, 205021, 404977 } 

---eben andersherum aber muss noch IDs finden---
local kickDisintigrate = { 356995 } --disintegrate
local kickFireBreath = { 357208 } --fire breath when playing with rdruid

local kickClone = { 33786 }

local noKickthings = { 
    377362, --precog
    209584, --zen tea
    378078, --shaman spirit walker immunity
    363916, --prevoker immunity--
    104773, --unending resolve
    317929, --hpal aura mastery immunity
    215769, --angel
}

-- local KickDelay = awful.delay(0.3, 0.45)
-- local KickDelayCasts = awful.delay(0.2, 0.35)

local KickDelay = awful.delay(0.4, 0.6)
local KickDelayCasts = awful.delay(0.4, 0.6)

windshear:Callback("casts", function(spell)  
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autokick then return end
    awful.enemies.loop(function(enemy) 
        if enemy.class == "Druid" and enemy.spec == "Balance" and awful.instanceType2 == "arena" then return end -- we have our own function for it --
        if enemy.class == "Druid" and enemy.spec == "Feral" and awful.instanceType2 == "arena" then return end -- we have our own function for it --

        if awful.fighting("Balance") and awful.instanceType2 == "arena" then return end 
        if awful.fighting("Feral") and awful.instanceType2 == "arena" then return end 

        if awful.fighting(102) and awful.instanceType2 == "arena" then return end --balance--
        if awful.fighting(103) and awful.instanceType2 == "arena" then return end --feral--

        if not spell:Castable(enemy) then return end
        if not enemy.casting then return end 
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.los then return end 
        if not tContains(kickList, enemy.castID) then return end
        if enemy.casting then
            --if enemy.castTimeComplete > KickDelay.now then --and enemy.castRemains > awful.buffer then 
            if enemy.castRemains < awful.buffer + KickDelayCasts.now then 
                if spell:Cast(enemy) then -- 
                    --awful.alert({ message = awful.colors.red.. "Kick", texture = spell.id, duration = 2 })
                    awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id) 
                    return true -- we return true to stop the loop.
                end
            end
        end
    end)
end)

windshear:Callback("vsBoomkins", function(spell) 
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autokick then return end
    if player.buff(8178) then return end --grounding enabled--
    awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if not enemy.casting then return end 
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.los then return end 
        if not tContains(kickClone, enemy.castID) then return end
        if enemy.casting then
            if enemy.castRemains < awful.buffer + KickDelayCasts.now then 
                if spell:Cast(enemy) then -- 
                    awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
                    return true -- we return true to stop the loop.
                end
            end
        end
    end)
end)

windshear:Callback("channel", function(spell) 
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autokick then return end
    awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.los then return end 
        if not enemy.channeling then return end 
        if not tContains(kickList, enemy.channelID) then return end
        if enemy.channeling and enemy.channelTimeComplete > KickDelay.now then
        return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
        end
    end)
end)

windshear:Callback("channelotherkicks", function(spell) 
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autokick then return end
    --if not settings.autokick then return end 
    awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.channeling then return end 
        if not enemy.los then return end 
        if not tContains(kickChannels, enemy.channelID) then return end
        if enemy.channeling and enemy.channelTimeComplete > KickDelay.now then
        return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
        end
    end)
end)

windshear:Callback("otherchannels", function(spell) 
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autokick then return end
        awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.los then return end 
            if enemy.channel == "Penance" or enemy.channel == "Lightning Lasso" or enemy.channel == "Convoke the Spirits" or enemy.channel == "Disintigrate" then
                if enemy.channelTimeComplete > KickDelay.now then  
                return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
                end
            end
        end)
end)

---because it's not taking the fcking ID, so I had to do a function only for some single castIDs which are ignored in my kicklist somehow--
windshear:Callback("nottakingthefckID", function(spell) 
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autokick then return end
        awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if not enemy.casting then return end
        if not enemy.los then return end 
   
        if enemy.class == "Druid" and enemy.spec == "Balance" and awful.instanceType2 == "arena" then return end -- we have our own function for it --
        if enemy.class == "Druid" and enemy.spec == "Feral" and awful.instanceType2 == "arena" then return end -- we have our own function for it --

        if awful.fighting("Balance") and awful.instanceType2 == "arena" then return end 
        if awful.fighting("Feral") and awful.instanceType2 == "arena" then return end 

        if awful.fighting(102) and awful.instanceType2 == "arena" then return end --balance--
        if awful.fighting(103) and awful.instanceType2 == "arena" then return end --feral--

        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
            if enemy.castID == 360806 or enemy.castID == 228260 or enemy.castID == 77472 or enemy.castID == 8004 then --sleep walk, void erruption, healing wave--
                if enemy.castRemains < awful.buffer + KickDelayCasts.now then 
                return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
                end
            end
        end)
end)

windshear:Callback("disintigrate", function(spell) 
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autokick then return end
    awful.enemies.loop(function(enemy) 
      
        if enemy.class == "Druid" and enemy.spec == "Balance" and awful.instanceType2 == "arena" then return end -- we have our own function for it --
        if enemy.class == "Druid" and enemy.spec == "Feral" and awful.instanceType2 == "arena" then return end -- we have our own function for it --

        if awful.fighting("Balance") and awful.instanceType2 == "arena" then return end 
        if awful.fighting("Feral") and awful.instanceType2 == "arena" then return end 

        if awful.fighting(102) and awful.instanceType2 == "arena" then return end --balance--
        if awful.fighting(103) and awful.instanceType2 == "arena" then return end --feral--

        if not spell:Castable(enemy) then return end
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.los then return end 
        if not enemy.channeling then return end 
        if enemy.healer then return end --we don't kick Disintigrate on Healer--
        if not tContains(kickDisintigrate, enemy.channelID) then return end
        if enemy.channeling and enemy.channelTimeComplete > KickDelay.now then
        return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
        end
    end)
end)

windshear:Callback("firebreath", function(spell)  
    if not settings.autokick then return end
    awful.fullGroup.loop(function(group)
        if group.class == "Druid" and group.spec == "Restoration" then 
            awful.enemies.loop(function(enemy) 
                if not spell:Castable(enemy) then return end
                if not enemy.casting then return end 
                if enemy.buffFrom(noKickthings) then return end 
                if enemy.debuff(410216) then return end --searing glare on him--
                if not enemy.los then return end 
                if not tContains(kickFireBreath, enemy.castID) then return end
                if enemy.casting then
                    --if enemy.castTimeComplete > KickDelay.now then --and enemy.castRemains > awful.buffer then 
                    if enemy.castRemains < awful.buffer + KickDelayCasts.now then 
                        if spell:Cast(enemy) then -- 
                            --awful.alert({ message = awful.colors.red.. "Kick", texture = spell.id, duration = 2 })
                            awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id) 
                            return true -- we return true to stop the loop.
                        end
                    end
                end
            end)
        end 
    end)
end)

windshear:Callback("firebreathChannel", function(spell) 
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autokick then return end
    awful.fullGroup.loop(function(group)
        if group.class == "Druid" and group.spec == "Restoration" then 
            awful.enemies.loop(function(enemy) 
                if not spell:Castable(enemy) then return end
                if enemy.buffFrom(noKickthings) then return end 
                if enemy.debuff(410216) then return end --searing glare on him--
                if not enemy.los then return end 
                if not enemy.channeling then return end 
                if not tContains(kickFireBreath, enemy.channelID) then return end
                if enemy.channeling and enemy.channelTimeComplete > KickDelay.now then
                return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
                end
            end)
        end 
    end) 
end)

--------------- --------------- --------------- --------------- MISC --------------- --------------- --------------- ---------------

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

dispelcurse:Callback("healer", function(spell)
    if not player.hasTalent(51886) then return end 
    if healer.dead then return end
    if not spell:Castable(healer) then return end
    if not healer.debuffFrom(natureCureDebuffs) then return end
    if spell:Cast(healer) then
        awful.alert({ message = awful.colors.orange.."Decurse Healer", texture = spell.id, duration = 1 }) return true
    end
end)


dispelcurse:Callback("other", function(spell)
    awful.fullGroup.loop(function(friend)
        if not player.hasTalent(51886) then return end 
        if not spell:Castable(friend) then return end
        if not friend.debuffFrom(natureCureDebuffs) then return end
        if healer.cc or healer.bcc then
            if spell:Cast(friend) then
                awful.alert({ message = awful.colors.orange.."Decurse", texture = spell.id, duration = 1 }) return true
            end
        end
    end)
end)

dispelcurse:Callback("agony", function(spell)

    awful.enemies.loop(function(unit)
    if unit.class2 == "SHAMAN" then return end -- we dont dispel agony vs shams --
    if unit.class2 == "WARLOCK" and unit.spec == "Destruction" then return end -- we dont dispel agony when there is havoc gamers--
    end)

    awful.fullGroup.loop(function(unit)
        if not player.hasTalent(251886) then return end 
        if not spell:Castable(unit) then return end
        if unit.debuffStacks(285135) > 16 then --stacks sind über 16
            return spell:Cast(unit) and awful.alert({ message = awful.colors.orange.."Dispel Agony", texture = spell.id, duration = 1 }) 
        end
    end)
end)

local DispelMagicDelay = awful.delay(0.3, 0.5)

local purgeList = {
    [1022] = { uptime = DispelMagicDelay.now, min = 2 },    --"Blessing of Protection",
    [342246] = { uptime = DispelMagicDelay.now, min = 0 },  --"Alter Time",
    [10060] = { uptime = DispelMagicDelay.now, min = 2 },  --"Power Infusion",
    [213610] = { uptime = DispelMagicDelay.now, min = 2 }, --"Holy Ward",
    [132158] = { uptime = DispelMagicDelay.now, min = 0 }, --"Nature's Swiftness Druid",
    [378081] = { uptime = DispelMagicDelay.now, min = 0 }, --"Nature's Swiftness Shaman",
    [443454] = { uptime = DispelMagicDelay.now, min = 0 }, --"Nature's Swiftness Shaman, ancestral shift--
    [378464] = { uptime = DispelMagicDelay.now, min = 2 },    ---"Nullifying shroud"---
    [415244] = { uptime = DispelMagicDelay.now, min = 1 },    ---Hpal Divine Plea---
    [415246] = { uptime = DispelMagicDelay.now, min = 1 },    ---Hpal Divine Plea2---
    [460422] = { uptime = DispelMagicDelay.now, min = 1 },    ---Divine Favor
    [114893] = { uptime = DispelMagicDelay.now, min = 1 },    ---New Bulwark Totem--
    [212295] = { uptime = DispelMagicDelay.now, min = 1 },    ---Warlock Reflect netherward
}

local purgeListOffensive = {
    11426, --"Ice Barrier"
    235313, --fire barrier
    188550, --lifebloom
    102351, --cenarion ward
    1044, --freedom
    17, --power shield 
    41635, --mending holy priest
    974, --earth shield
    124682, --monk envolving mist 40% heal
    378464, --nully shroud
}

greaterpurge:Callback("mindcontrol", function(spell)
    if not settings.autopurge then return end
    if player.mana < 45000 then return end -- purge costs 44960 mana --
    if awful.fighting("PRIEST") then
        awful.group.loop(function(unit, i, uptime)
            if unit.dead then return end
            if not spell:Castable(unit) then return end
            if unit.cc ~= 605 then return end
            if spell:Cast(unit) then
                awful.alert({ message = awful.colors.red.."", texture = spell.id, duration = 1 }) return true
            end
        end)
    end
end)

greaterpurge:Callback("purge", function(spell)
    if not settings.autopurge then return end
    if player.mana < 52500 then return end -- purge costs 52500 mana --
    if player.debuffStacks(410063) == 2 then return end --silence stacks of rdruid--
    awful.enemies.loop(function(unit, i, uptime)
        --if uptime < 0.3 then return end
        if unit.dead then return end
        if not spell:Castable(unit) then return end
        if not unit.buffFrom(purgeList) then return end
        --if unit.purgeCount > 15 then return end --too many buffs on him--
        if spell:Cast(unit) then
            awful.alert({ message = awful.colors.red.."", texture = spell.id, duration = 1 }) return true
        end
    end)
end)

greaterpurge:Callback("offensivepurge", function(spell)
    if not settings.autopurgeoffensive then return end
    if player.mana < 52500 then return end -- purge costs 52500 mana --
    if player.debuffStacks(410063) == 2 then return end --silence stacks of rdruid--
    awful.enemies.loop(function(unit, i, uptime)
        --if uptime < 0.3 then return end
        if unit.dead then return end
        if not spell:Castable(unit) then return end
        if not unit.buffFrom(purgeListOffensive) then return end
        --if unit.purgeCount > 15 then return end --too many buffs on him--
        if spell:Cast(unit) then
            awful.alert({ message = awful.colors.red.."", texture = spell.id, duration = 1 }) return true
        end
    end)
end)

--- TOTEMS ---
-- alte logic führte zu LUA errors--
-- local stuffToTremor = {
--     [360806] = { uptime = 0.5, min = 3 }, --sleepwalk
--     [198898] = { uptime = 0.5, min = 3 }, -- Songofchi
--     [207685] = { uptime = 0.5, min = 3 },  ---sigil fear---
--     [8122] = { uptime = 0.5, min = 3 },  -- Psychic Scream
--     [5484] = { uptime = 0.5, min = 3 }, -- Howl of Terror
--     [5782] = { uptime = 0.5, min = 3 }, -- Fear
--     [6358] = { uptime = 0.5, min = 3 }, -- Seduction
--     [5246] = { uptime = 0.5, min = 3 }, -- Int shout warri
-- }

-- local stuffToTremor = {
--     [360806] = { min = 3 }, --sleepwalk
--     [198898] = { min = 3 }, -- Songofchi
--     [207685] = { min = 3 },  ---sigil fear---
--     [8122] = { min = 3 },  -- Psychic Scream
--     [5484] = { min = 3 }, -- Howl of Terror
--     [5782] = { min = 3 }, -- Fear
--     [6358] = { min = 3 }, -- Seduction
--     [5246] = { min = 3 }, -- Int shout warri
-- }

-- local stuffToTremor = {
--     360806, --sleepwalk
--     198898, -- Songofchi
--     207685,  ---sigil fear---
--     8122,  -- Psychic Scream
--     5484, -- Howl of Terror
--     5782, -- Fear
--     6358, -- Seduction
--     5246, -- Int shout warri
-- }

local stuffToTremor = {
    [360806] = true, --sleepwalk
    [198898] = true, -- Songofchi
    [207685] = true, ---sigil fear---
    [8122] = true, -- Psychic Scream
    [5484] = true, -- Howl of Terror
    [5782] = true, -- Fear
    [6358] = true, -- Seduction
    [5246] = true, -- Int shout warri
}

totemtremor:Callback("healer", function(spell)
    if not settings.autototem then return end 
    --if not player.hasTalent(8143) then return end 
    if healer.dead then return end
    --if healer.debuffFrom(stuffToTremor) and healer.debuffUptime(stuffToTremor) < 3 then return end  
    if healer.debuffFrom(stuffToTremor) then
        if healer.distanceTo(player) < 30 or player.hasTalent(382201) and healer.distanceTo(player) < 34 then 
        --elseif player.hasTalent(382201) and healer.distanceTo(player) < 34 then 
            if spell:Cast() then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Healer", texture = spell.id, duration = 1 }) end
            end 
        end
    end 
end)

totemtremor:Callback("nohealer", function(spell)
    if not settings.autototem then return end 
    if healer.exists then return end 
    if not player.hasTalent(8143) then return end 
    awful.group.loop(function(group)
        if group.debuffFrom(stuffToTremor) then
            if group.distanceTo(player) < 30 then --tremor 30 y range -- 
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
        end 
    end) 
end)

---pre tremor---

local stuffToPreTremor = { 
    360806, --sleep walk
    5782, --fear
}

totemtremor:Callback("preTremorCasts", function(spell)
    if not settings.autopretremor then return end 
    if not settings.autototem then return end 
    if player.cooldown(204336) < 0.1 then return end --grounding rdy--
    if healer.exists then return end 
    if not player.hasTalent(8143) then return end 
        awful.enemies.loop(function(enemy)
        if not enemy.casting then return end
        --if player.cooldown(57994) < 0.1 and not player.silenced then return end  --windshear--
        if enemy.distanceTo(player) > 40 then return end 
        if player.cooldown(57994) < 0.1 and enemy.losOf(player) and not enemy.buffFrom(immunityStuff) then return end --windshear--
        if not tContains(stuffToPreTremor, enemy.castID) then return end
        if tContains(stuffToPreTremor, enemy.castID) and enemy.castRemains < awful.buffer + 0.7 and player.casting then SpellStopCasting() end
            --if tContains(ccStufftoGround, enemy.castID) and enemy.distanceTo(player) < 34 and enemy.castRemains < awful.buffer + 0.4 then
            if tContains(stuffToPreTremor, enemy.castID) and enemy.distanceTo(player) < 34 and enemy.castTimeLeft < awful.buffer + 0.6 then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Pre Tremor", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
end)

totemtremor:Callback("priestfear", function(spell)
    if not settings.autopretremor then return end 
    if not settings.autototem then return end 
    if healer.exists then return end 
    --if healer.exists then return end 
    if not player.hasTalent(8143) then return end 
    if player.ddr < 0.5 then return end  --only half or full ddr drs--
    awful.enemies.loop(function(enemy)
    if enemy.class2 ~= "PRIEST" then return end  
    if enemy.cc or enemy.bcc then return end 
    if not enemy.los then return end 
    --if player.speed > enemy.speed then return end 
    if enemy.cooldown(8122) > 0.5 then return end  --priest fear not rdy--  
        if enemy.distanceTo(player) < 10 then
            return spell:Cast() and awful.alert({ message = awful.colors.red.. "Pre Tremor", texture = spell.id, duration = 1 })
        end
    end)
end)

totemtremor:Callback("warriorfear", function(spell)
    if not settings.autopretremor then return end 
    if not settings.autototem then return end 
    if healer.exists then return end 
    --if healer.exists then return end 
    if not player.hasTalent(8143) then return end 
    if player.ddr < 0.5 then return end  --only half or full ddr drs--
    awful.enemies.loop(function(enemy)
    if not enemy.isPlayer then return end 
    if enemy.class2 ~= "WARRIOR" then return end  
    if enemy.cc or enemy.bcc then return end 
    if not enemy.los then return end 
    --if player.speed > enemy.speed then return end 
    if enemy.cooldown(5246) > 0.5 then return end  --war fear not rdy--  
        if enemy.distanceTo(player) < 10 and not enemy.target.isUnit(player) then --he is not targeting us, so probably will try to fear us--
            return spell:Cast() and awful.alert({ message = awful.colors.red.. "Pre Tremor War", texture = spell.id, duration = 1 })
        end
    end)
end)

-- totemstatic:Callback("charge", function(spell)
--     awful.enemies.loop(function(enemy) 
--         if enemy.class ~= "Warrior" then return end -- if not meele then dont --
--         if not enemy.los then return end
--         if enemy.distance > 10 then --makes only sense when war is not already next to me--
--             if enemy.target.isUnit(player) and enemy.cds then --war is targeting me w cds--
--             return spell:SmartAoE(enemy) and awful.alert({ message = awful.colors.red.. "Static War", texture = spell.id, duration = 2 })
--             end
--         end
--     end)
-- end)

totemroot:Callback("stopdrink", function(spell)
    if awful.instanceType2 ~= "arena" then return end
    if not enemyHealer.combat and enemyHealer.buff("Drink") then
    --return spell:SmartAoE(enemyHealer) and awful.alert({ message = awful.colors.red.. "Root Enemy Healer to stop Drink", texture = spell.id, duration = 2 })
        if spell:SmartAoE(enemyHealer) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "stop drink", texture = spell.id, duration = 1 }) end
        end 
    end 
end)

local ccStufftoGround = { 
    51514, --Hex
    211015, --Hex
    210873, --Hex
    277784, --Hex
    277778, --Hex
    309328, --Hex
    269352, --Hex
    211004, --Hex
    211010, --Hex
    20066, --rep pala
    118, --sheep
    161355, --sheep
    161354, --sheep
    161353, --sheep
    126819, --sheep
    61780, --sheep
    161372, --sheep
    61721, --sheep
    61305, --sheep
    28272, --sheep
    28271, --sheep
    277792, --sheep
    277787, --sheep
    460392, --Newsheep
    360806, --sleep walk
    5782, --fear
    605, --MC
    33786, --cyclone
}

local damageStufftoGround = { 
    116858, -- chaos bolt
    199786, --glacial spike
    228260, --void erruption
    323764, --convoke
    365350, --arcane surge
    386997, --soulrot
}

local immunityStuff = { 377362, 378078, 363916, 104773, 317929}  --precog, spiritwalker, prevokerim, unendinge resolve, auramastery--

local holdnow = false 

awful.onTick(function()

    awful.enemies.loop(function(enemy)
    if not settings.autototem then return end 
    if enemy.distanceTo(player) > 34 then return end 
    if player.buff(8178) then return end --there is already a grounding--
   -- if player.cooldown(57994) < 0.1 and not player.silenced then return end  --windshear--
    if player.cooldown(57994) < 0.1 and enemy.losOf(player) and not enemy.buffFrom(immunityStuff) then return end --windshear--
    if not player.hasTalent(204336) then return end --we dont have grounding talented--

        if player.cooldown(204336) < 0.1 then --grounding--
            
        local totalBuffer = awful.gcd + awful.player.gcdRemains + 0.7

            --if tContains(ccStufftoGround, enemy.castID) and enemy.castRemains < totalBuffer then 
            if tContains(ccStufftoGround, enemy.castID) and enemy.castRemains < totalBuffer then 
                holdnow = true
                --SpellCancelQueuedSpell()
                awful.alert({ message = awful.colors.red.. "HOLD", texture = 204336, duration = 0.5 })
                --if player.casting then SpellStopCasting() end
            end 
        end
    end) 
end)

---second holding to gett holdnow to false again back or it will hold swd forever because it is staying true--
awful.onTick(function()
    awful.enemies.loop(function(enemy)
    if not settings.autototem then return end 
    --if enemy.distanceTo(player) > 30 then return end 
    if holdnow == false then return end 
        if not tContains(ccStufftoGround, enemy.castID) then 
            holdnow = false 
            --and awful.alert({ message = awful.colors.yellow.. "HOLD OFF", duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0 })
        end
    end)
end)

totemgrounding:Callback(function(spell)
    if not settings.autototem then return end 
    if not player.hasTalent(204336) then return end --grounding talent--
    --if holdnow == true then 
        awful.enemies.loop(function(enemy)
        if not enemy.casting then return end
        --if player.cooldown(57994) < 0.1 and not player.silenced then return end  --windshear--
        if enemy.distanceTo(player) > 40 then return end 
        if player.cooldown(57994) < 0.1 and enemy.losOf(player) and not enemy.buffFrom(immunityStuff) then return end --windshear--
        if not tContains(ccStufftoGround, enemy.castID) then return end
        if tContains(ccStufftoGround, enemy.castID) and enemy.castRemains < awful.buffer + 0.7 and player.casting then SpellStopCasting() end
            --if tContains(ccStufftoGround, enemy.castID) and enemy.distanceTo(player) < 34 and enemy.castRemains < awful.buffer + 0.4 then
            if tContains(ccStufftoGround, enemy.castID) and enemy.distanceTo(player) < 34 and enemy.castTimeLeft < awful.buffer + 0.3 then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "CC", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    --end 
end)

totemgrounding:Callback("damagespells", function(spell)
    if not settings.autototem then return end 
    awful.enemies.loop(function(enemy)
   -- if player.cooldown(57994) < 0.1 and not player.silenced then return end  --windshear--
    if player.cooldown(57994) < 0.1 and enemy.losOf(player) and not enemy.buffFrom(immunityStuff) then return end --windshear--
    if not player.hasTalent(204336) then return end --grounding talent--
    if not enemy.casting then return end
    if not tContains(damageStufftoGround, enemy.castID) then return end
    if tContains(damageStufftoGround, enemy.castID) and enemy.castRemains < awful.buffer + 0.8 and player.casting then SpellStopCasting() end
        --if tContains(damageStufftoGround, enemy.castID) and enemy.distanceTo(player) < 30 and enemy.castRemains < awful.buffer + 0.3 then
        if tContains(ccStufftoGround, enemy.castID) and enemy.distanceTo(player) < 34 and enemy.castTimeLeft < awful.buffer + 0.3 then
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "DMG", texture = spell.id, duration = 1 }) end 
            end 
        end
    end)
end)

totemgrounding:Callback("CDs", function(spell)
    if not settings.autototem then return end 
    if not player.hasTalent(204336) then return end --grounding talent--
    awful.enemies.loop(function(enemy)
        if enemy.distanceTo(player) > 34 then return end 
        if enemy.used(190319, 2) or enemy.used(375982, 2) or enemy.used(421453, 2) or enemy.used(191634, 1) then --combust, primo, ultimative penance, stormkeeper--
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "CDs", texture = spell.id, duration = 1 }) end 
            end 
        end 
    end)
end)

local onUpdate = awful.addUpdateCallback

awful.onUpdate(function()
    totemgrounding:Callback("trap", function(spell)
        if not settings.autototem then return end 
        if awful.instanceType2 == "pvp" then return end -- we don't need that in BGs--
        awful.missiles.track(function(missile)
            local id = missile.spellId
            if not id then return end
            local missilecreator = awful.GetObjectWithGUID(missile.source)
            if missilecreator.friend then return end
            if id ~= 187650 then return end
            if player.casting then 
                SpellStopCasting()
                SpellStopCasting()
            end 
            local hx, hy, hz = missile.hx,missile.hy,missile.hz
            if player.distanceTo(hx, hy, hz) < 30 then
                return totemgrounding:Cast() and awful.alert({ message = awful.colors.red.. "Trap", texture = spell.id, duration = 1 })
            end
        end)
    end)
end)

---reflect---
frostshock:Callback("reflecttarget", function(spell)
    if player.buff(285514) then return end --we don't reflect surge of power procc--
    if player.buff(462818) then return end --icefury hurts--
    if target.class ~= "Warrior" then return end -- if not enemy isn't a Warrior
    if player.hp < 20 then return end --so we dont kill us--
    if player.castID == 305483 then return end --lasso--
    if player.castID == 8004 then return end --we are currently healing--
    if target.buff(212295) then return end --netherward--
    if target.dead then return end
    if target.bcc then return end
    if target.cc then return end
    if target.dist > frostshock.range then return end
    if target.friendly then return end
    if target.los then
        if target.buff(23920) then --spell reflect--
        return spell:Cast(target) and awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 })
        end
    end
end)

--- Defensives ---
local battleMaster = awful.Item{205781, 205710}

battleMaster:Update(function(item)
    if not battleMaster.equipped then return end
    if not item:Usable(player) then return end
    if player.hp <= settings.bmtrinket then
      return item:Use() and awful.alert({ message = awful.colors.orange.. "BM", texture = 5512, duration = 1 })
    end
end)

local medalTrinket = awful.Item{216282}

medalTrinket:Update(function(item)
    if player.cc then
    return item:Use() and awful.alert({ message = awful.colors.purple.. "Trinket", texture = 205779, duration = 1 })
    end
end)

local healthStone = awful.Item(5512)
healthStone:Update(function(item)
    if not item:Usable(player) then return end
    if player.hp <= settings.healthstoneHP then
      return item:Use() and awful.alert({ message = awful.colors.orange.. "Healthstone", texture = 5512, duration = 1 })
    end
end)

local healthstone = awful.NewItem(5512)

local checked_for_hs = 0
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

healingsurge:Callback("ourgroup", function(spell)
    if not settings.autoheal then return end
    if player.buff(108281) then return end  --- ancestral guidance activated --- HIAR NOCH BUFFID ÜBERPRÜFEN ---
    awful.fullGroup.loop(function(friend)
        if friend.buff(342246) then return end --alter time--
        if wasCasting[spell.id] then return end
        if player.manaPct < 10 then return end -- do nothing under 10% mana
        if friend.dist > healingsurge.range then return end
        if target.hp < 20 and not target.buffFrom(noPanic) then return end --we kill--
        if not friend.los then return end --not in sight--
        if friend.hp < 40 then
            if healer.cc or healer.bcc then --our healer is in cc--
                awful.enemies.loop(function(enemy)
                    if enemy.target.isUnit(friend) then
                        if spell:Cast(friend) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                        end 
                    end
                end)
            end
        end
    end)
end)

healingsurge:Callback("lockedOnFire", function(spell)
    if not settings.autoheal then return end
    if player.lockouts.fire and player.lockouts.fire.remains > 0.5 then
        awful.fullGroup.loop(function(friend)
            if wasCasting[spell.id] then return end
            if player.manaPct < 15 then return end -- do nothing under 10% mana
            if friend.dist > healingsurge.range then return end
            --if target.hp < 20 and not target.buffFrom(noPanic) then return end --we kill--
            if not friend.los then return end --not in sight--
            local lowest = awful.fullGroup.lowest
            if lowest.hp < 90 then
                if spell:Cast(lowest) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "locked", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end 
end)

healingsurge:Callback("searingglare", function(spell)
    if not settings.autoheal then return end
    if player.debuff(410216) then --searing glare--
        awful.fullGroup.loop(function(friend)
            if wasCasting[spell.id] then return end
            if player.manaPct < 10 then return end -- do nothing under 10% mana
            if friend.dist > healingsurge.range then return end
            --if target.hp < 20 and not target.buffFrom(noPanic) then return end --we kill--
            if not friend.los then return end --not in sight--
            local lowest = awful.fullGroup.lowest
            if lowest.hp < 95 then
                if spell:Cast(lowest) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end 
end)


--we can't use earthshock, no flameshock, have enough mana, no lava burst rdy
healingsurge:Callback("insteadOfLB", function(spell)
    if not settings.autoheal then return end
    if player.buff(77762) then return end --lava surge procc--
    if player.maelstrom < 55 and player.cooldown(188389) > 0.4 and player.mana > 30000 and player.cooldown(51505) > 0.4 then 
        awful.fullGroup.loop(function(friend)
            if wasCasting[spell.id] then return end
            if player.manaPct < 15 then return end -- do nothing under 10% mana
            if friend.dist > healingsurge.range then return end
            --if target.hp < 20 and not target.buffFrom(noPanic) then return end --we kill--
            if not friend.los then return end --not in sight--
            local lowest = awful.fullGroup.lowest
            if lowest.hp < 95 then
                if spell:Cast(lowest) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end 
end)

healingsurge:Callback("outofcombat", function(spell)
    if not settings.autoheal then return end
    if awful.prep then return end 
    if not player.combat then 
        awful.fullGroup.loop(function(friend)
            if wasCasting[spell.id] then return end
            if player.manaPct < 15 then return end -- do nothing under 10% mana
            if friend.dist > healingsurge.range then return end
            --if target.hp < 20 and not target.buffFrom(noPanic) then return end --we kill--
            if not friend.los then return end --not in sight--
            local lowest = awful.fullGroup.lowest
            if lowest.hp < 95 then
                if spell:Cast(lowest) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end 
end)

healingsurge:Callback("macroLowest", function(spell)
    if wasCasting[spell.id] then return end
    if player.manaPct < 11 then return end -- do nothing under 10% mana
    if heal then
        --local lowest = awful.fullGroup.within(40).filter(unit).lowest
        --local lowest = awful.fgroup.within(40).filter(filter).lowest 
        local lowest = awful.fullGroup.lowest
        --local lowest = awful.fullGroup.lowest.filter(function(unit) { return unit.los})
        if lowest.distance > 40 then return end
        if not lowest.los then return end --not in sight--
        if lowest.exists and lowest.hp < 99 then
            if spell:Cast(lowest) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
            end 
        end
    end 
end)

healingsurge:Callback("macro", function(spell)
    if wasCasting[spell.id] then return end
    if player.manaPct < 10 then return end -- do nothing under 10% mana
    if heal then
        awful.fullGroup.loop(function(friend)
            if friend.dist > healingsurge.range then return end
            if not friend.los then return end --not in sight--
            if friend.hp < 99 then
                if spell:Cast(friend) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end 
end)

function healautooff()
    if player.lockouts.nature and player.lockouts.nature.remains > 0.5 then
    heal = false 
    end 
end 

ancestralguidance:Callback(function(spell)
    if not settings.autodefensives then return end
    awful.fullGroup.loop(function(friend)
        if wasCasting[spell.id] then return end
        if friend.distanceTo(player) > 40 then return end 
        if not friend.los then return end --not in sight--
        if friend.hp < 50 then
            if healer.cc or healer.bcc then --our healer is in cc--
                awful.enemies.loop(function(enemy)
                    --if enemy.target.isUnit(friend) then
                        if spell:Cast(player) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                        end 
                   --end
                end)
            end
        end
    end)
end)

ancestralguidance:Callback("nohealer", function(spell)
    if not settings.autodefensives then return end
    awful.fullGroup.loop(function(friend)
        if healer.exists and healer.distanceTo(friend) < 40 and not healer.cc then return end --our healer can heal--
        if wasCasting[spell.id] then return end
        if friend.distanceTo(player) > 40 then return end 
        if not friend.los then return end --not in sight--
        if friend.hp < 60 and not friend.buffFrom(noPanic) then
            awful.enemies.loop(function(enemy)
                --if enemy.target.isUnit(friend) then
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                    end 
                --end
            end)
        end 
    end)
end)

totemhealingstream:Callback(function(spell)
    if not settings.autototem then return end 
    awful.fullGroup.loop(function(friend)
        if friend.buff(342246) then return end --alter time--
        if wasCasting[spell.id] then return end
        if player.mana < 12500 then return end -- costs of that totem---
        if friend.hp < 90 and friend.distanceTo(player) < 40 then
            if healer.cc or healer.bcc then --our healer is in cc--
                awful.enemies.loop(function(enemy)
                    if enemy.distanceTo(player) < 40 then 
                        --if enemy.cds then
                        if spell:Cast(player) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                        end 
                       -- end
                    end
                end)
            end
        end
    end)
end)

totemhealingstream:Callback("nohealer", function(spell)
    if not settings.autototem then return end 
    awful.fullGroup.loop(function(friend)
        --if friend.buff(342246) then return end --alter time--
        if wasCasting[spell.id] then return end
        if player.mana < 12500 then return end -- costs of that totem---
        if friend.hp < 90 and friend.distanceTo(player) < 40 then
            if not healer.exists then --no healer
                awful.enemies.loop(function(enemy)
                    if enemy.distanceTo(player) < 40 then 
                        if spell:Cast(player) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                        end 
                    end
                end)
            end
        end
    end)
end)

earthshield:Callback("onme", function(spell)
    if not settings.autoearthshield then return end 
    if not target.friendly and target.hp < 30 and not target.buffFrom(noPanic) then return end
    if not target.friendly and target.hp < 30 and not target.buffFrom(someDefensives) then return end 
    if player.buff(383648) then return end --earthshield--
    if not player.buff(383648) then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

earthshield:Callback("onOffDps", function(spell)
    if not settings.autoearthshield then return end 
    if select(2,GetInstanceInfo()) ~= "arena" then return end  --we only use it in arena--
    if player.mana < 12500 then return end 
    if not target.friendly and target.hp < 30 and not target.buffFrom(noPanic) then return end
    if not target.friendly and target.hp < 30 and not target.buffFrom(someDefensives) then return end 
    if healer.buff(974, player) then return end --we set our earthshield on healer--
    --if healer.buff(974) then return end --we used it on our healer so we don't want to use it on off dps-- < makes no sense when our healer is a shaman 
    awful.group.loop(function(friend)
        if friend.buff(974) then return end --earthshield--
        if not friend.healer and not friend.buff(974) then
            if spell:Cast(friend) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "DPS", texture = spell.id, duration = 1 }) end 
            end 
        end
    end)
end)

earthshield:Callback("onHealer2S", function(spell)
    if not settings.autoearthshield then return end 
    if select(2,GetInstanceInfo()) ~= "arena" then return end  --we only use it in arena--
    if not target.friendly and target.hp < 30 and not target.buffFrom(noPanic) then return end
    if not target.friendly and target.hp < 30 and not target.buffFrom(someDefensives) then return end 
    if party1.exists and party2.exists then return end 
    if healer.buff(974, player) then return end --earthshield--
    if not healer.buff(974, player) then
        if spell:Cast(healer) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Healer", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

flametongue:Callback(function(spell)
    --if not player.hasTalent(382027) then return end 
    --if player.buff(382028) then return end --flametounge--
    --if not player.buff(382028) then
    if player.mainhandEnchantRemains == 0 or player.mainhandEnchantRemains > 0 and player.mainhandEnchantRemains < 120 then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

thunderstrikeWard:Callback(function(spell)
    if not player.hasTalent(462757) then return end 
    if player.used(462757, 8) then return end --thunderstrikeward--
    if player.mainhandEnchantRemains == 0 or player.mainhandEnchantRemains > 0 and player.mainhandEnchantRemains < 120 or player.used(318038, 1) then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

lightningshield:Callback(function(spell)
    if player.buff(192106) then return end --LS--
    if not player.buff(192106) then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

local stuffToCleanseHunter = {
    356723, --silence shot hunter
    356727, --silence shot hunter
}

totempoisoncleanse:Callback("hunter", function(spell)
    awful.fullGroup.loop(function(group)
    if not player.hasTalent(383013) then return end 
    if not group.debuffFrom(stuffToCleanseHunter) then return end
        if group.distanceTo(player) < 30 then --cleanse 30 y range -- 
        return spell:Cast(player) and awful.alert({ message = awful.colors.blue.. "Silence Shot", texture = spell.id, duration = 1 }) 
        end
    end)
end)

local stuffToCleanseAssa = {
    360194, -- deathmark
    319504, -- shiv
}

totempoisoncleanse:Callback("assa", function(spell)
    awful.fullGroup.loop(function(group)
    if not player.hasTalent(383013) then return end 
    if not group.debuffFrom(stuffToCleanseAssa) then return end
        if group.distanceTo(player) < 30 then --cleanse 30 y range -- 
        return spell:Cast(player) and awful.alert({ message = awful.colors.blue.. "Assa Go", texture = spell.id, duration = 1 }) 
        end
    end)
end)

--ist jetzt ne passive "totem wrath"
-- totemskyfury:Callback("burst", function(spell)
--     if not settings.autoburst then return end
--     if player.used(460697, 15) then return end --we used it already, so we dont overuse it in world when doing pve meanwhile--
--     if primowave.cd > 0.1 and primowave.cd < 42 then return end --we only use with primo, but in case we can't use skyfury immediatly, we use it even after primo--
--     if player.cooldown(375982) > 0.1 and player.cooldown(375982) < 42 then return end  --we only use with primo, but in case we can't use skyfury immediatly, we use it even after primo--

--     local fscount = 0
--     awful.enemies.loop(function(enemy)

--         if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
--         if fscount >= 1 then 
           
--             if target.buff(212295) then return end --netherward--
--             if target.immuneMagicDamage then return end 
--             if target.buffFrom(immuneBuffs) then return end 
--             if not spell:Castable(target) then return end
--             if target.dead then return end
--             if target.bcc then return end
--             if target.dist > 45 then return end
--             if target.friendly then return end
--             if target.los then
--                 if spell:Cast(player) then
--                     if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
--                 end 
--             end
--         end 
--     end)
-- end)

unleashshield:Callback("charge", function(spell)
    if not settings.autounleashshield then return end
    awful.enemies.loop(function(enemy) 
        if enemy.dist > unleashshield.range then return end
        if enemy.class ~= "Warrior" then return end -- if not meele then dont --
        if not enemy.los then return end
        if enemy.used(100) then --charge--
            if enemy.target.isUnit(player) then --war is targeting me--
                if spell:Cast(enemy) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Charge", texture = spell.id, duration = 1 }) end
                end 
            end
        end
     end)
end)

--verkackt hier muss ich komplett neu machen wenn ich das machen will, aber zu sus--
-- unleashshield:Callback("leap", function(spell)
--     if not settings.autounleashshield then return end
--     awful.enemies.loop(function(enemy) 
--         if enemy.dist > unleashshield.range then return end
--         if enemy.class2 ~= "WARRIOR" then return end -- if not meele then dont --
--         if not enemy.los then return end
--         if enemy.used(178368) or enemy.used(6544) then --leap ids--
--             --if enemy.target.isUnit(player) then --war is targeting me-- 
--                 if spell:Cast(enemy) then
--                     if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Leap", texture = spell.id, duration = 1 }) end
--                 end 
--            -- end
--         end
--      end)
-- end)

unleashshield:Callback("FWs", function(spell)
    if not settings.autounleashshield then return end
    --awful.enemies.loop(function(enemy) 
        if enemyHealer.dist > unleashshield.range then return end
        if enemyHealer.class ~= "Monk" then return end --only FWs--
        if not enemyHealer.los then return end
        if enemyHealer.rooted then return end 
        if enemyHealer.rootDR == 1 then 
            if enemyHealer.distanceTo(player) < 5 then 
                if enemyHealer.target.isUnit(player) then 
                    if spell:Cast(enemyHealer) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "FW", texture = spell.id, duration = 1 }) end
                    end 
                end
            end
        end 
    --end)
end)



unleashshield:Callback("Melees", function(spell)
    if not settings.autounleashshield then return end
    awful.enemies.loop(function(enemy, i, uptime) 
        if uptime < 0.8 then return end 
        if enemy.distanceTo(player) > 10 then return end 
        if not enemy.target.isUnit(player) then return end 
        if enemy.dist > unleashshield.range then return end
        if enemy.role ~= "melee" then return end -- if not meele then dont --
        if enemy.class == "Druid" then return end -- if not meele then dont --
        if not enemy.los then return end
        if not spell:Castable(enemy) then return end 
        if enemy.immuneMagicDamage then return end 
        if enemy.buff(186289) then return end --falken buff von SV--
        --if enemy.sdr < 0.5 then return end 
        if enemy.used(100, 2) then return end --not sus unleashing him-- CHARGE
        if enemy.used(6544, 2) then return end --not sus unleashing him-- LEAP
        if enemy.buff(1044) then return end --freedom--
        if enemy.buff(345228) then return end --lolstorm--
        if enemy.buff(23920) then return end --spell reflect--
        if enemy.cc or enemy.bcc then return end 
        if enemy.rooted then return end 
        if enemy.distanceTo(player) < 8 then --distance--
            if enemy.target.isUnit(player) and enemy.cds then --melee is targeting me--
                if spell:Cast(enemy) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
        end
     end)
end)

---ToDo maybe DreamBreath von Prevoker für unleash --

spiritwalker:Callback("PVP", function(spell)
    if not settings.autospiritwalker then return end 
    if not player.combat then return end 
    if player.cooldown(375982) < 0.1 then return end --primo wave--
    if player.maelstrom > 50 then return end --we can earthshock--
    if player.buff(191634) then return end --stormkeeper available, so instants rdy-- 
    if player.buff(378081) then return end --nature swiftness available, so instants rdy--
    if player.buff(77762) then return end --lava surge on me, so instants rdy-
    if player.cooldown(51505) > 0.1 or player.lockouts.fire then return end --we dont do it without lavaburst--
    if target.immuneMagicDamage then return end 
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if player.moving and not player.buff(79206) then 
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

------------------------------AUTO HEX------------------------------------

local nohexthings = { 
    377362, --precog
    8178, --grounding
    23920, --reflect
    212295, --netherward--
    353319, --monk revival
    409293, --burrow
    215769, --angel
}

local reflectStuff = { 212295, 23920 }
local immuneBuffHex = { 
    212295, --netherward
    48707, --ams
    47585, --dispersion
    23920, --reflect
    409293, --burrow
    642, --bubble
    204018, --spellwarding
    45438, --iceblock--
    186265, --turtle--
    33786, --cyclone
    353319, --monk revival 
    408558, --priest immunity fade
    8178, --grounding
    421453, --ult penance--
}

function StopCastingInImmunities()
    if not player.casting then return end 
    awful.enemies.loop(function(enemy)
    if player.castID == hex.id and player.castTarget.isUnit(enemy) and enemy.immuneMagicDamage and enemy.distanceTo(player) < 40 then SpellStopCasting() end 
    if player.castID == 51514 and player.castTarget.isUnit(enemy) and enemy.immuneMagicDamage and enemy.distanceTo(player) < 40 then SpellStopCasting() end 

    if player.castID == hex.id and player.castTarget.isUnit(enemy) and enemy.buffFrom(reflectStuff) and enemy.distanceTo(player) < 40  then SpellStopCasting() end 
    if player.castID == 51514 and player.castTarget.isUnit(enemy) and enemy.buffFrom(reflectStuff) and enemy.distanceTo(player) < 40  then SpellStopCasting() end 

    if player.castID == hex.id and player.castTarget.isUnit(enemy) and enemy.buffFrom(immuneBuffHex) and enemy.distanceTo(player) < 40 then SpellStopCasting() end 
    if player.castID == 51514 and player.castTarget.isUnit(enemy) and enemy.buffFrom(immuneBuffHex) and enemy.distanceTo(player) < 40 then SpellStopCasting() end 

    if player.castID == hex.id and enemy.buff(8178) and enemy.distanceTo(player) < 40 then SpellStopCasting() end  ---grounding---
    if player.castID == 51514 and enemy.buff(8178) and enemy.distanceTo(player) < 40 then SpellStopCasting()  end  ---grounding---
    end)
end

---healer--
hex:Callback("Healer", function(spell)
    if not settings.autohex then return end
    if enemyHealer.buffFrom(reflectStuff) then return end 
    if enemyHealer.buffFrom(immuneBuffHex) then return end 
    if enemyHealer.immuneMagicDamage then return end 
    if target.hp < 20 and not target.buffFrom(noPanic) then return end 
    if awful.instanceType2 == "arena" then
        if wasCasting[spell.id] then return end
        if enemyHealer.class2 == "DRUID" then return end --he will shapeshift--
        if enemyHealer.dist > hex.range then return end
        if enemyHealer.debuff(81261) then return end --he is root-beamed-
        if not spell:Castable(enemyHealer) then return end
        if enemyHealer.buffFrom(nohexthings) then return end 
        if not enemyHealer.los then return end --enemy is not in sight for casting--
        if enemyHealer.idr <= 0.5 then return end 
        if enemyHealer.ccRemains > 2 then return end  --to prevent not ccing already cc'd target--
        if player.target.isUnit(enemyHealer) then return end -- we go on healer ---
        if (enemyHealer.ccRemains - buffer) < hex.castTimeRaw then 
            --if settings.autolockmovement and spell.current or player.channelID == spell.id then awful.controlMovement(0.3) end
            if spell:Cast(enemyHealer, { stopMoving = true }) then 
                if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Healer", texture = 51514, duration = 1 }) end
                return true
            end
        end 
    end 
end)

---off target peel when our healer is in cc--
hex:Callback("healerisinCC", function(spell)
    if not settings.autohex then return end
    if target.hp < 30 and not target.buffFrom(noPanic) then return end --we kill--
    if awful.instanceType2 == "arena" then
        awful.enemies.loop(function(enemy)
        if enemy.buffFrom(reflectStuff) then return end 
        if enemy.buffFrom(immuneBuffHex) then return end 
        if enemy.immuneMagicDamage then return end 
        if not enemy.isPlayer then return end 
        if enemy.class2 == "DRUID" then return end 
        if enemy.ccRemains > 2 then return end  --to prevent not ccing already cc'd target--
        --if enemy.cc then return end 
        if enemy.role == "healer" then return end --we don't want to clone heal--
        if wasCasting[spell.id] then return end
        if not spell:Castable(enemy) then return end
        if enemy.dist > hex.range then return end
        if enemy.buffFrom(nohexthings) then return end 
        if enemy.idr < 0.5 then return end 
        if not enemy.los then return end --enemy is not in sight for casting--
            if (enemy.ccRemains - buffer) < hex.castTimeRaw then
                if not player.target.isUnit(enemy) then  --so it's off target--
                    --if not enemy.target.isUnit(player) then --we are not the target--
                        awful.group.loop(function(group)
                            if healer.cc then
                                --if settings.autolockmovement and spell.current or player.channelID == spell.id then awful.controlMovement(0.3) end
                                if spell:Cast(enemy, { stopMoving = true }) then 
                                    if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Peel", texture = 51514, duration = 1 }) end
                                    return true
                                end
                            end
                        end)
                    --end 
                end
            end
        end)
    end 
end)

---- clone logic when we have precog on us on enemy healer ---
hex:Callback("precog-Healer", function(spell)
    if not settings.autohex then return end
    if enemyHealer.buffFrom(reflectStuff) then return end 
    if enemyHealer.buffFrom(immuneBuffHex) then return end 
    if enemyHealer.immuneMagicDamage then return end 
    if enemyHealer.class2 == "DRUID" then return end 
    if awful.instanceType2 == "arena" then
        if player.buff(377362) and player.buffRemains(377362) > 1.4 then --precog--
            if wasCasting[spell.id] then return end
            if enemyHealer.dist > hex.range then return end
            if enemyHealer.debuff(81261) then return end --he is root-beamed-
            if not spell:Castable(enemyHealer) then return end
            --if enemyHealer.cc then return end
            if enemyHealer.buffFrom(nohexthings) then return end 
            if not enemyHealer.los then return end --enemy is not in sight for casting--
            if enemyHealer.idr <= 0.5 then return end 
            if enemyHealer.ccRemains > 2 then return end  --to prevent not ccing already cc'd target--
            if player.target.isUnit(enemyHealer) then return end -- we go on healer ---
            if (enemyHealer.ccRemains - buffer) < hex.castTimeRaw then 
                --if settings.autolockmovement and spell.current or player.channelID == spell.id then awful.controlMovement(0.3) end
                if spell:Cast(enemyHealer, { stopMoving = true }) then 
                    if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Healer", texture = 51514, duration = 1 }) end
                    return true
                end
            end 
        end
    end 
end)

hex:Callback("precog-Off", function(spell)
    if not settings.autohex then return end
    if awful.instanceType2 == "arena" then
        if player.buff(377362) and player.buffRemains(377362) > 1.4 then --precog--
            awful.enemies.loop(function(enemy)
                if enemy.buffFrom(reflectStuff) then return end 
                if enemy.buffFrom(immuneBuffHex) then return end 
                if enemy.immuneMagicDamage then return end 
                if enemy.class2 == "DRUID" then return end 
                if not enemy.isPlayer then return end 
                if wasCasting[spell.id] then return end
                if enemy.dist > hex.range then return end
                if enemy.debuff(81261) then return end --he is root-beamed-
                if not spell:Castable(enemy) then return end
                --if enemyHealer.cc then return end
                if enemy.buffFrom(nohexthings) then return end 
                if not enemy.los then return end --enemy is not in sight for casting--
                if enemy.idr <= 0.5 then return end 
                if enemy.ccRemains > 2 then return end  --to prevent not ccing already cc'd target--
                if not player.target.isUnit(enemy) then  --so it's off target--
                    if (enemy.ccRemains - buffer) < hex.castTimeRaw then 
                        --if settings.autolockmovement and spell.current or player.channelID == spell.id then awful.controlMovement(0.3) end
                        if spell:Cast(enemy, { stopMoving = true }) then 
                            if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Peel", texture = 51514, duration = 1 }) end
                            return true
                        end
                    end 
                end 
            end)
        end 
    end 
end)

---HIAR---

totemroot:Callback("pvp", function(spell)
    if not settings.autoroot then return end
    if player.used(355580, 2) then return end --static totem used--
    awful.enemies.loop(function(enemy) 
        if enemy.buff(227847) then return end --bladestorm--
        if player.target.isUnit(enemy) then return end --we go on this target--
        if not enemy.los then return end 
        if enemy.dist > 40 then return end
        if enemy.role ~= "melee" then return end -- if not meele then dont --
        if enemy.buff(1044) then return end --freedom --
        if enemy.buff(81782) then return end --dome buff--
        --if not enemy.los then return end --enemy is not in sight for casting--
        --if not spell:Castable(enemy) then return end --is castable like when he has immunities--
        if enemy.rootDR < 1 then return end --only rooting him when he is on half or full dr--
        --if enemy.target.isUnit(player) then ---enemy has offensive CDs and targeting me---
            if spell:SmartAoE(enemy) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 2 }) end
            end 
        --end
    end)
end)

totemroot:Callback("pvpOnEnemyHealer", function(spell)
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autoroot then return end
    awful.enemies.loop(function(enemy) 
        if enemyHealer.dist > 40 then return end
        if not enemyHealer.los then return end 
        if enemyHealer.buff(1044) then return end --freedom --
        if player.target.isUnit(enemyHealer) then return end --we go on healer--
        --if not enemy.los then return end --enemy is not in sight for casting--
        --if not spell:Castable(enemy) then return end --is castable like when he has immunities--
        if enemyHealer.rootDR <= 0.5 then return end --only rooting him when he is on half or full dr--
        if enemy.losOf(enemyHealer) then ---enemy has offensive CDs and targeting me---
            if spell:SmartAoE(enemyHealer) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "root Healer LoS", texture = spell.id, duration = 2 }) end
            end 
        end
    end)
end)

totemroot:Callback("pvpPets", function(spell)
    if not settings.autorootPets then return end
    awful.enemies.loop(function(enemy) 
        if enemy.class2 ~= "HUNTER" then return end -- if not meele then dont --
        awful.pets.loop(function(pet)
            if pet.rootDR < 0.5 then return end --only rooting him when he is on half or full dr--
            if not pet.los then return end 
            if enemy.used(19574, 5) then ---bestial wrath--
                if spell:SmartAoE(pet) then 
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "root BM pets", texture = spell.id, duration = 1 }) end
                end 
            end
        end)
    end)
end)

totemliquidmagma:Callback("PVP", function(spell)
    --if not settings.autototem then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    --if allEnemies.around(target, 8) >= 2 then
    local abc, abcCount = enemies.around(target, 9, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
    if abc and abcCount >= 2 then
        if spell:AoECast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    end
end)

totemliquidmagma:Callback("PVPoneEnemyOnly", function(spell)
    --if not settings.autototem then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    --if allEnemies.around(target, 8) >= 2 then
    local abc, abcCount = enemies.around(target, 9, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
    if abc and abcCount >= 1 then
        if spell:AoECast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    end
end)

--erstmal testen bevor release--
totemstun:Callback("PVParena", function(spell)
    if not settings.autostuntotem then return end 
    if awful.instanceType2 ~= "arena" then return end 
   --awful.enemies.loop(function(enemy) 
        if enemyHealer.sdr >= 0.5 and (enemyHealer.ccRemains - buffer) < 2 then
            if not player.target.isUnit(enemyHealer) then  --we go on him--
                if spell:AoECast(enemyHealer) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "extend cc", texture = spell.id, duration = 1 }) end
                end
            end
        end
    --end)
end)

--performance heavy? testen--
totemstun:Callback("PVPBgs", function(spell)
    if not settings.autostuntotem then return end 
    if awful.instanceType2 ~= "pvp" then return end 
    if target.distance > 40 then return end 
    if not target.exists then return end
    if target.friendly then return end 
    local abc, abcCount = enemies.around(target, 8, function(obj) return obj.sdr == 1 and not obj.dead and not obj.friendly end)
        if abcCount >= 3 then 
            if spell:AoECast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end
        end 
end)

--hiar-- 

awful.RegisterMacro("lasso", 1)

lasso:Callback("macro", function(spell)
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if target.stunDR < 0.25 then return end 
    if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

--------------------------------------------------------------------------- PVE ---------------------------------------------------------------------------

fireele:Callback("PVEburst", function(spell)
    --if settings.mode == "pvemode" then
    if not settings.autoburst then return end
    if not player.hasTalent(198067) then return end --fire ele talent--
    if player.used(198067, 36) then return end --fire ele used--
        local fscount = 0
        awful.enemies.loop(function(enemy)

            if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
            if fscount >= 1 then 

                if target.buff(212295) then return end --netherward--
                if target.immuneMagicDamage then return end
                if target.buffFrom(immuneBuffs) then return end 
                --if not spell:Castable(target) then return end
                if target.dead then return end
                if target.bcc then return end
                if target.dist > 40 then return end
                if target.friendly then return end
                --if target.debuff(flameshock.id, player) then return end 
                --if target.los then
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                --end
            end
        end)
    --end 
end)

fireele:Callback("PVEmacrobursti", function(spell)
    if player.used(198067, 36) then return end --fire ele used--
    if settings.autoburst then return end
    if not player.hasTalent(198067) then return end --fire ele talent--
    if bursti then
        if target.buff(212295) then return end --netherward--
        if target.immuneMagicDamage then return end 
        if target.buffFrom(immuneBuffs) then return end 
        --if not spell:Castable(target) then return end
        if target.dead then return end
        if target.bcc then return end
        if target.dist > 40 then return end
        if target.friendly then return end
        --if target.los then
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
       -- end
    end
end)

fireeleAOE:Callback("PVEburst", function(spell)
    if not fireele.used(25) then return end 
    if fireeleAOE.cd > 1 then return end 
    if target.buff(212295) then return end --netherward--
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    --if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.dist > 40 then return end
    if target.friendly then return end
    --if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    --end 
end)

stormele:Callback("PVEburst", function(spell)
if not settings.autoburst then return end
if not player.hasTalent(192249) then return end --storm ele talent--
if player.used(192249, 36) then return end --storm ele used--
    if target.buff(212295) then return end --netherward--
    if target.immuneMagicDamage then return end
    if target.buffFrom(immuneBuffs) then return end 
    --if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.dist > 40 then return end
    if target.friendly then return end
    --if target.debuff(flameshock.id, player) then return end 
   -- if target.los then
        --if allEnemies.around(target, 12) >= 2 then
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
       -- end 
   -- end
end)

stormele:Callback("PVEmacrobursti", function(spell)
    if player.used(192249, 36) then return end --storm ele used--
    if settings.autoburst then return end
    if not player.hasTalent(192249) then return end --storm ele talent--
    if bursti then
        if target.buff(212295) then return end --netherward--
        if target.immuneMagicDamage then return end 
        if target.buffFrom(immuneBuffs) then return end 
       -- if not spell:Castable(target) then return end
        if target.dead then return end
        if target.bcc then return end
        if target.dist > 40 then return end
        if target.friendly then return end
       -- if target.los then
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
       -- end
    end
end)

primowave:Callback("PVEburst", function(spell)
    if not settings.autoburst then return end
    
    --if player.buff(77762) then return end --lava surge--

    local fscount = 0
    awful.enemies.loop(function(enemy)

        if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
        if fscount >= 1 then 

            if target.buff(212295) then return end --netherward--
            if target.immuneMagicDamage then return end 
            if target.buffFrom(immuneBuffs) then return end 
            --if not spell:Castable(target) then return end
            if target.dead then return end
            if target.bcc then return end
            if target.dist > primowave.range then return end
            if target.friendly then return end
            --if target.debuff(flameshock.id, player) then return end 
           -- if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
          -- end

        end

    end)
end)


primowave:Callback("PVEmacrobursti", function(spell)
    if settings.autoburst then return end
    
    if bursti then 

        local fscount = 0
        awful.enemies.loop(function(enemy)

            if enemy.debuff(flameshock.id, player) then fscount = fscount + 1 end 
            if fscount >= 1 then 

                if target.buff(212295) then return end --netherward--
                if target.immuneMagicDamage then return end 
                if target.buffFrom(immuneBuffs) then return end 
               -- if not spell:Castable(target) then return end
                if target.dead then return end
                if target.bcc then return end
                if target.dist > primowave.range then return end
                if target.friendly then return end
                --if target.debuff(flameshock.id, player) then return end 
               -- if target.los then
                    if spell:Cast(target) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
              --  end

            end 
        end)
    end 
end)

flameshock:Callback("PVEtarget", function(spell)
    if player.cooldown(375982) < 2 or player.used(375982, 2) then return end --we can primo our main target or we used it on our main target 2 sec before--
    if player.used(375982, 2) then return end 
    if target.buff(212295) then return end --netherward--
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    --if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.dist > flameshock.range then return end
    if target.friendly then return end
    --if target.los then
        if target.debuffRemains(flameshock.id, player) < 3 then 
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
   -- end
end)

---on manual burst we want to flameshock the target first ofc--
flameshock:Callback("PVEtargetManualBurst", function(spell)
    if settings.autoburst then return end 
    if player.cooldown(375982) < 2 and bursti then return end --we can primo our main target with burst on--
    if player.used(375982, 2) then return end 
    if target.buff(212295) then return end --netherward--
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    --if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.dist > flameshock.range then return end
    if target.friendly then return end
   -- if target.los then
        if target.debuffRemains(flameshock.id, player) < 3 then 
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    --end
end)


lavaburst:Callback("PVEtargetProcc", function(spell)

     --noch adden, dass es nicht außerhalb des fights passiert--
    local abc, abcCount = enemies.around(target, 14, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
    if abc and abcCount >= 3 then return end 
    if wasCasting[spell.id] then return end

    if target.buff(212295) then return end --netherward--
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
   -- if not spell:Castable(target) then return end
    if not target.debuff(188389) then return end --flame shock for crit--
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > lavaburst.range then return end
    --if player.lastCast == 51505 and player.maelstrom > 50 then return end 
    --if player.maelstrom > 50 then return end 
   -- if target.los then
        if player.buff(77762) then --or player.buff(375986) then --lava surge or primo buff--
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
  --  end
end)

lavaburst:Callback("PVEtargetProccPRIMO", function(spell)

    --noch adden, dass es nicht außerhalb des fights passiert--
    if wasCasting[spell.id] then return end

   if target.buff(212295) then return end --netherward--
   if target.immuneMagicDamage then return end 
   if target.buffFrom(immuneBuffs) then return end 
   --if not spell:Castable(target) then return end
   if not target.debuff(188389) then return end --flame shock for crit--
   if target.dead then return end
   if target.bcc then return end
   if target.friendly then return end
   if target.dist > lavaburst.range then return end
   --if player.lastCast == 51505 and player.maelstrom > 50 then return end 
   --if player.maelstrom > 50 then return end 
  -- if target.los then
       if player.buff(375986) and player.buff(77762) then --primo buff + lava surge procc--
           if spell:Cast(target) then
               if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
           end 
       end 
   --end
end)

lavaburst:Callback("PVEtargetProccMoving", function(spell)

    --noch adden, dass es nicht außerhalb des fights passiert--
   --local abc, abcCount = enemies.around(target, 14, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
   --if abc and abcCount >= 3 then return end 
   if wasCasting[spell.id] then return end

   if target.buff(212295) then return end --netherward--
   if target.immuneMagicDamage then return end 
   if target.buffFrom(immuneBuffs) then return end 
   --if not spell:Castable(target) then return end
   if not target.debuff(188389) then return end --flame shock for crit--
   if target.dead then return end
   if target.bcc then return end
   if target.friendly then return end
   if target.dist > lavaburst.range then return end
   --if player.lastCast == 51505 and player.maelstrom > 50 then return end 
   --if player.maelstrom > 50 then return end 
    --if target.los then
       if player.buff(77762) then --or player.buff(375986) then --lava surge or primo buff--
            if player.moving and not player.buff(79206) then --we are moving and not having spiritwalker on us--
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
       end 
   -- end
end)


earthshock:Callback("PVEtarget", function(spell)
    if target.buff(212295) then return end --netherward--
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    --if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > earthshock.range then return end
    if player.buff(77762) then return end 
    --if player.lastCast == 8042 then return end --earthshock--
    --if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
   -- end
end)

lightningbolt:Callback("PVEtargetProcc", function(spell)
    if target.immuneMagicDamage then return end 
    local abc, abcCount = enemies.around(target, 14, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
    if abc and abcCount >= 2 then return end 
    if target.buffFrom(immuneBuffs) then return end 
   -- if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
   -- if target.los then
        if player.buff(191634) or player.buff(378081) then ---stormkeeper buff, NS buff--
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
   -- end
end)

lightningbolt:Callback("PVEtargetStormFrenzyProcc", function(spell)
    if not player.hasTalent(462695) then return end 
    local abc, abcCount = enemies.around(target, 14, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
    if abc and abcCount >= 2 then return end 
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
   -- if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    --if target.los then
        if player.buff(462725) and player.buffStacks(462725) > 1  then --stormfrenzy procc from talent--
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
    --end
end)

flameshock:Callback("PVE", function(spell)
    --if select(2,GetInstanceInfo()) == "pvp" then return end --in bg or arena--

    local fscount = 0

    awful.enemies.loop(function(pet)

    if pet.dist > flameshock.range then return end
    if pet.debuff(flameshock.id, player) then return end 

    if pet.debuff(flameshock.id, player) then fscount = fscount + 1 end 
    if fscount >= 6 then return true end 

        if pet.los then
            if spell:Cast(pet) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)

flameshock:Callback("PVEplayerMoving", function(spell)
    --if select(2,GetInstanceInfo()) == "pvp" then return end --in bg or arena--

    local fscount = 0

    awful.enemies.loop(function(pet)

    if pet.dist > flameshock.range then return end
    if pet.debuff(flameshock.id, player) then return end 
    if not pet.combat then return end 

    if pet.debuff(flameshock.id, player) then fscount = fscount + 1 end 
    if fscount >= 6 then return true end 
        if player.moving and not player.buff(79206) then
            --if pet.los then
                if spell:Cast(pet) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            --end
        end 
    end)
end)

stormkeeper:Callback("PVP", function(spell)
    if not settings.autoburst then return end 
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if spell:Cast(player) then
        ---hiar noch adden, wenn enemy healer im cc--
        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
    end 
end)

stormkeeper:Callback("PVPmacro", function(spell)
    if settings.autoburst then return end 
    if bursti then 
        if target.immuneMagicDamage then return end 
        if target.buffFrom(immuneBuffs) then return end 
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > 40 then return end
        if spell:Cast(player) then
            ---hiar noch adden, wenn enemy healer im cc--
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    end 
end)

lavaburst:Callback("PVEtargetCasting", function(spell)
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    --if not spell:Castable(target) then return end
    if not target.debuff(188389) then return end --flame shock for crit--
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > lavaburst.range then return end
    local abc, abcCount = enemies.around(target, 12, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
    if abcCount >= 2 then return end --we chainlight--
    --if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    --end
end)

lightningbolt:Callback("PVEtargetCasting", function(spell)
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
   -- if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    --if allEnemies.around(target, 8) >= 2 then return end 
    local abc, abcCount = enemies.around(target, 12, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
    if abcCount >= 2 then return end --we chainlight--
   -- if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    --end
end)

chainlight:Callback("PVE", function(spell)
    if target.immuneMagicDamage then return end 
    --if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    --if allEnemies.around(target, 12) >= 2 then
    local abc, abcCount = enemies.around(target, 17, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
    if abc and abcCount >= 2 then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    end
end)

chainlight:Callback("PVEtargetProcc", function(spell)
    --if not target.combat then return end 
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    --if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
   -- if target.los then
        --if allEnemies.around(target, 12) >= 2 then
        local abc, abcCount = enemies.around(target, 17, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
        if abc and abcCount >= 2 then
            if player.buff(191634) or player.buff(378081) then ---stormkeeper buff, swiftness--
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end 
        end 
    --end
end)

chainlight:Callback("PVEtargetProccTempest", function(spell)
    --if not target.combat then return end 
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    --if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
   -- if target.los then
        --if allEnemies.around(target, 12) >= 2 then
        if player.buff(455097) then ---tempest procc AOE Hero talent--
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
    --end
end)


earthquakeTarget:Callback("PVE", function(spell)
    --if not target.combat then return end 
    if target.immuneMagicDamage then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    --if allEnemies.around(target, 8) >= 2 then
    local abc, abcCount = enemies.around(target, 8.1, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
    if abc and abcCount >= 2 then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    end
end)

totemliquidmagma:Callback("PVE", function(spell)
    if settings.dawnbringershit then return end --we are on the ship--
    if not settings.autototem then return end
    if not settings.autoburst then return end 
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    --if allEnemies.around(target, 8) >= 2 then
    local abc, abcCount = enemies.around(target, 9, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
    if abc and abcCount >= 2 then
        if spell:AoECast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    end
end)

totemliquidmagma:Callback("PVEmacro", function(spell)
    if settings.dawnbringershit then return end --we are on the ship--
    if not settings.autototem then return end
    if settings.autoburst then return end 
    if bursti then 
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > 40 then return end
        --if allEnemies.around(target, 8) >= 2 then
        local abc, abcCount = enemies.around(target, 9, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
        if abc and abcCount >= 2 then
            if spell:AoECast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end 
end)

totemicrecall:Callback("PVE", function(spell)
    --if player.casting or player.channeling then return end
    if player.lastCast == 192058 then return end --Capacitor Totem--
    if player.used(192058, 4) and not player.used(192222, 3) then return end  --we used static totem but not liquid--
    if player.used(192222, 11) then 
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

natureSwiftness:Callback("PVE", function(spell)
    if player.buff(462725) and player.buffStacks(462725) > 1 then return end --stormfrenzy procc from talent--
    if not player.combat then return end 
    if player.buff(191634) then return end --stormkeeper available, so instants rdy--
    --if player.casting or player.channeling then return end
    --if player.moving and not player.buff(79206) then 
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    --end
end)

ancestralSwiftness:Callback("PVE", function(spell)
    if player.buff(77762) then return end --lavaprocc--
    if player.buff(462725) and player.buffStacks(462725) > 1 then return end --stormfrenzy procc from talent--
    if not player.combat then return end 
    if player.buff(191634) then return end --stormkeeper available, so instants rdy--
    --if player.casting or player.channeling then return end
    --if player.moving and not player.buff(79206) then 
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    --end
end)

spiritwalker:Callback("PVE", function(spell)
    if not settings.autospiritwalker then return end 
    if not player.combat then return end 
    if player.buff(191634) then return end --stormkeeper available, so instants rdy--
    if player.buff(378081) then return end --nature swiftness available, so instants rdy--
    if player.buff(77762) then return end --lava surge on me, so instants rdy-
    if target.immuneMagicDamage then return end 
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if player.moving and not player.buff(79206) then 
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

totemStoneBulwark:Callback("PVE", function(spell)
    if not settings.autototem then return end 
    if not player.combat then return end 
    if player.buffFrom(noPanic) then return end 
    if player.mana < 5000 then return end -- costs of that totem---
    if player.hp >= 60 then return end 
    if player.hp < 60 then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

astralshift:Callback("PVE", function(spell)
    if not settings.autodefensives then return end 
    if not player.combat then return end 
    if player.buff(114893) then return end --bulwark totem--
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.hp < 60 then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

ancestralguidance:Callback("PVE", function(spell)
    if not settings.autodefensives then return end
    if not player.combat then return end 
    awful.fullGroup.loop(function(friend)
        if friend.hp > 50 then return end 
        if player.manaPct < 10 then return end -- do nothing under 10% mana
        if friend.distanceTo(player) > 40 then return end 
        if friend.hp < 50 then
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
            end 
        end
    end)
end)

totemstunPVE:Callback("PVE", function(spell)
    if settings.dawnbringershit then return end --we are on the ship--
    if not settings.autostuntotem then return end 
    --if not target.combat then return end 
    if not player.combat then return end 
    if target.moving then return end 
    local abc, abcCount = enemies.around(target, 8, function(obj) return obj.sdr == 1 and not obj.dead and not obj.friendly end)
        if abcCount >= 3 then 
            if spell:AoECast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end
        end
end)

earthshield:Callback("PVEonTank", function(spell)
    if awful.instanceType2 ~= "party" then return end --only in dungeons or we will spam when there are more tanks--
    if player.mana < 12500 then return end 
    if player.combat then return end --we have better stuff to do--
    awful.group.loop(function(friend)
        if friend.buff(974) then return end --earthshield--
        if friend.role == "tank" and not friend.buff(974) then
            if spell:Cast(friend) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Tank", texture = spell.id, duration = 1 }) end 
            end 
        end 
    end)
end)

earthshield:Callback("PVEonme", function(spell)
    if player.combat then return end --we have better stuff to do--
    if player.buff(383648) then return end --earthshield--
    if not player.buff(383648) then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

totemwindrush:Callback("PVE", function(spell)
    if settings.dawnbringershit then return end --we are on the ship--
    --if awful.instanceType2 == "party" and not target.combat then return end
    --if awful.instanceType2 == "raid" and not target.combat then return end
    if not settings.autototem then return end 
    if not settings.autowindrush then return end 
    if player.mounted then return end 
    if player.combat then return end 
    if player.moving then
        awful.fullGroup.loop(function(friend)
            --if not friend.los then return end 
            if friend.mounted then return end 
            local abc, abcCount = friends.around(player, 10, function(obj) return not obj.combat and obj.friendly end)
            if abc and abcCount >= 2 then
                if spell:AoECast(friend) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
        end)
    end 
end)

---kicklist from https://keyandheal.com/dungeons/SpellBank/
local kickListPVE = { 
    426283,
    275826,
    324776,
    272571,
    322450,
    431309,
    328667,
    338353,
    451871,
    452162,
    430097,
    324914,
    445207,
    324293,
    434793,
    429109,
    448248,
    443430,
    323057,
    340544,
    326046,
    431333,
    433841,
    256957,
    450756,
    449734,
    429110,
    426283,
    275826,
    335143,
    257063,
    324776,
    429545,
    272571,
    452099,
    322450,
    334748,
    451261,
    322274,
    431309,
    320336,
    333602,
    328667,
    338353,
    327396,
    442536,
    322938,
    434802,
    449455,
    451871,
    452162,
    430097,
    320171,
    320462,
    431303,
    324914,
    321828,
    445207,
    436322,
    324293,
    434793,
    429109,
    448248,
    76711,
    428086,
    447966,
    76369,
    443430,
    323057,
    322767,
    340544,
    326046,
    454440,
    429422,
    431333,
    443433,
    432520,
    433841,
    434122,
    446086,
    272581,
    256957,
    451113,
    443427,
    434786,
 }

local KickDelayCasts = awful.delay(0.3, 0.7)

-- windshear:Callback("PVE", function(spell)  
--     if not settings.autokick then return end 
--     awful.enemies.loop(function(enemy) 
--         --if not spell:Castable(enemy) then return end
--         if not enemy.casting then return end 
--        -- if enemy.buffFrom(noKickthings) then return end 
--        -- if not enemy.los then return end 
--         if not tContains(kickListPVE, enemy.castID) then return end
--         if enemy.casting then
--             --if enemy.castTimeComplete > KickDelay.now then --and enemy.castRemains > awful.buffer then 
--             if enemy.castRemains < awful.buffer + KickDelayCasts.now then 
--                 if spell:Cast(enemy) then -- 
--                     --awful.alert({ message = awful.colors.red.. "Kick", texture = spell.id, duration = 2 })
--                     awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id) 
--                     return true -- we return true to stop the loop.
--                 end
--             end
--         end
--     end)
-- end)

windshearPVE:Callback("PVE", function(spell)  
    if settings.mode == "pvpmode" then return end 
    if not settings.autokick then return end 
    if player.cooldown(57994) > 0.1 then return end 
    awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if not enemy.casting then return end 
        if not enemy.los then return end 
        if not tContains(kickListPVE, enemy.castID) then return end
        if enemy.casting then
            if enemy.castRemains < 2 then 
                if spell:Cast(enemy) then -- 
                    --awful.alert({ message = awful.colors.red.. "Kick", texture = spell.id, duration = 2 })
                    awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id) 
                    return true -- we return true to stop the loop.
                end
            end
        end
    end)
end)

-- function checkModeArena()
--     if settings.mode == "pvemode" and select(2,GetInstanceInfo()) == "arena" then
--     elseif settings.mode == "pvemode" and awful.instanceType2 == "pvp" then 
--         awful.alert({ message = awful.colors.red.. "CHECK MODE, YOU ARE IN PVE MODE BUT IN PVP SCENARIO", texture = 186668, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) 
--     end 
-- end

healingsurge:Callback("PVEoutofcombat", function(spell)
    if not settings.autohealPVE then return end
    if awful.prep then return end 
    if not player.combat then 
        awful.fullGroup.loop(function(friend)
            if wasCasting[spell.id] then return end
            if player.manaPct < 20 then return end -- do nothing under 10% mana
            if friend.dist > healingsurge.range then return end
            --if target.hp < 20 and not target.buffFrom(noPanic) then return end --we kill--
            if not friend.los then return end --not in sight--
            local lowest = awful.fullGroup.lowest
            if lowest.hp < 95 then
                if spell:Cast(lowest) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end 
end)

local stuffToCleansePVE = {
   -- 461487, nicht sonst killt das eigene leute
    326092,
    340283,
    448248,
    275836,
    340288,
    443401,
    433841,
    438618,
    461630,
    444985,
    --461487,
}

totempoisoncleanse:Callback("PVE", function(spell)
    if not settings.autototem then return end 
    if not player.hasTalent(383013) then return end 
    awful.fullGroup.loop(function(group)
    if not group.debuffFrom(stuffToCleansePVE) then return end
        if group.distanceTo(player) < 30 then --cleanse 30 y range -- 
        return spell:Cast(player) and awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) 
        end
    end)
end)

local natureCureDelayPVE = awful.delay(0.6, 1)

local curseDebuffsPVE = {
    [450095] = { uptime = natureCureDelayPVE.now, min = 2 },
    [257168] = { uptime = natureCureDelayPVE.now, min = 2 },
    [322968] = { uptime = natureCureDelayPVE.now, min = 2 },
    [431309] = { uptime = natureCureDelayPVE.now, min = 2 },
    [451224] = { uptime = natureCureDelayPVE.now, min = 2 },
    [426308] = { uptime = natureCureDelayPVE.now, min = 2 },
    [440622] = { uptime = natureCureDelayPVE.now, min = 2 },
}

dispelcurse:Callback("PVE", function(spell)
    awful.fullGroup.loop(function(friend)
        if not player.hasTalent(51886) then return end 
        if not spell:Castable(friend) then return end
        if not friend.debuffFrom(curseDebuffsPVE) then return end
        if spell:Cast(friend) then
            awful.alert({ message = awful.colors.red.. "Decurse", texture = spell.id, duration = 1 }) return true
        end
    end)
end)

-- function autoTargeting()
--     if target.exists then
--         target.setTarget()
--     end 
-- end 

-- local flags = {
--     ["Alliance Flag"] = true,  --156621
--     ["Horde Flag"] = true, ---156618
-- }
-- local flagDropTime = 0
-- local function flagActions()
-- if not settings.autopickupflags then return end 
--   if awful.instanceType2 ~= "pvp" then return end
--     --if fullGroup.find(function(e) return (e.role == "tank" and e.dist < 20) end) then return end
--   if awful.time > flagDropTime then
--         awful.objects.loop(function(obj)
--             if not flags[obj.name] then return end
--             if obj.dist > 5 then return end
--             obj:interact()
--         end)
--   end
-- end

lasso:Callback("precog", function(spell)
    if player.hp < 60 then return end 
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autolasso then return end
    if player.used(51514, 2) then return end --we hexed--
    if player.buff(377362) and player.buffRemains(377362) > 2 then --precog--
        awful.group.loop(function(group)
        if group.class2 == "ROGUE" and group.target.isUnit(enemy) then return end --rogue goes on him--
            awful.enemies.loop(function(enemy)
                if enemy.immuneMagicDamage then return end 
                if enemy.buffFrom(immuneBuffs) then return end 
                if not enemy.isPlayer then return end 
                if enemy.dist > lasso.range then return end
                if enemy.debuff(81261) then return end --he is root-beamed-
                if not spell:Castable(enemy) then return end
                if enemy.cc or enemy.bcc then return end 
                if enemy.sdr <= 0.5 then return end --dont cast cyclone double DR--
                if enemy.ccRemains > 2 then return end  --to prevent not ccing already cc'd target--
                if enemy.los then 
                    if spell:Cast(enemy) then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "precog", texture = spell.id, duration = 2 }) end
                        return true
                    end
                end 
            end)
        end) 
    end
end)

lasso:Callback("enemyHealer", function(spell)
    --local eta, interrupt = awful.interruptETA(enemy, player)
    if player.hp < 60 then return end 
    if player.used(51514, 2) then return end --we hexed--
    --local eta, interrupt = awful.interruptETA(enemy, player)
   -- if eta and interrupt and eta <= 4 then -- 3 seconds for instance
    if not player.canBeInterrupted(5) then --no kicker--
        if awful.instanceType2 ~= "arena" then return end
        if not settings.autolasso then return end
        awful.group.loop(function(group)
            if group.cds and not group.target.isUnit(enemyHealer) then
                if enemyHealer.immuneMagicDamage then return end 
                if enemyHealer.buffFrom(immuneBuffs) then return end 
                if enemyHealer.dist > lasso.range then return end
                if enemyHealer.debuff(81261) then return end --he is root-beamed-
                if not spell:Castable(enemyHealer) then return end
                if enemyHealer.cc or enemyHealer.bcc then return end 
                if enemyHealer.sdr <= 0.5 then return end --dont cast cyclone double DR--
                if enemyHealer.ccRemains > 2 then return end  --to prevent not ccing already cc'd target--
                if enemyHealer.los then 
                    if spell:Cast(enemyHealer) then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "on eHealer", texture = spell.id, duration = 2 }) end
                        return true
                    end
                end 
            end 
        end) 
    end 
end)

lasso:Callback("HealerinCC", function(spell)
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autolasso then return end
    if player.used(51514, 2) then return end --we hexed--
    if healer.cc and healer.ccRemains > 2 then 
        --local eta, interrupt = awful.interruptETA(enemy, player)
        --if eta and interrupt and eta <= 4 then -- 3 seconds for instance
        if not player.canBeInterrupted(5) then --no kicker--
            awful.group.loop(function(group)
            if group.class2 == "ROGUE" and group.target.isUnit(enemy) then return end --rogue goes on him--
                awful.enemies.loop(function(enemy)
                    if enemy.healer then return end 
                    if enemy.immuneMagicDamage then return end 
                    if enemy.buffFrom(immuneBuffs) then return end 
                    if not enemy.isPlayer then return end 
                    if enemy.dist > lasso.range then return end
                    if enemy.debuff(81261) then return end --he is root-beamed-
                    if not spell:Castable(enemy) then return end
                    if enemy.cc or enemy.bcc then return end 
                    if enemy.sdr <= 0.5 then return end --dont cast cyclone double DR--
                    if enemy.ccRemains > 2 then return end  --to prevent not ccing already cc'd target--
                    if enemy.los and not enemy.healer then 
                        if spell:Cast(enemy) then 
                            if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "peel our healer", texture = spell.id, duration = 2 }) end
                            return true
                        end
                    end 
                end)
            end) 
        end 
    end
end)


bloodlust:Callback("newburst", function(spell)
if awful.instanceType2 == "party" then return end --dungeon--
if awful.instanceType2 == "raid" then return end --raid--
--if not settings.autoburst then return end
if not player.hasTalent(193876) then return end --pvp talent heroism--
    awful.enemies.loop(function(enemy)

        if player.buff(191634) or player.buff(114050) or player.buff(375986) then  --stormkeeper, ascendance or primo wave
            
            if target.immuneMagicDamage then return end
            if target.buffFrom(immuneBuffs) then return end 
            if target.dead then return end
            if target.bcc then return end
            if target.dist > 40 then return end
            if target.los then
                awful.group.loop(function(group)
                    if group.isHealer then return end -- we don't want to use it on healer --
                    if group.los then
                        if spell:Cast(group) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                        end 
                    end 
                end)
            end
        end
    end) 
end)

bloodlust:Callback("newburstNoHeal", function(spell)
if healer.exists then return end 
if awful.instanceType2 == "party" then return end --dungeon--
if awful.instanceType2 == "raid" then return end --raid--
--if not settings.autoburst then return end
if not player.hasTalent(193876) then return end --pvp talent heroism--
    awful.enemies.loop(function(enemy)

        if player.buff(191634) or player.buff(114050) or player.buff(375986) then  --stormkeeper, ascendance or primo wave
            
            if target.immuneMagicDamage then return end
            if target.buffFrom(immuneBuffs) then return end 
            if target.dead then return end
            if target.bcc then return end
            if target.dist > 40 then return end
            if target.los then
                awful.group.loop(function(group)
                    if group.los then
                        if spell:Cast(group) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                        end 
                    end 
                end)
            end
        end
    end) 
end)


bloodlustHorde:Callback("newburst", function(spell)
if awful.instanceType2 == "party" then return end --dungeon--
if awful.instanceType2 == "raid" then return end --raid--
--if not settings.autoburst then return end
if not player.hasTalent(193876) then return end --pvp talent heroism--
    awful.enemies.loop(function(enemy)

        if player.buff(191634) or player.buff(114050) or player.buff(375986) then  --stormkeeper, ascendance or primo wave
            
            if target.immuneMagicDamage then return end
            if target.buffFrom(immuneBuffs) then return end 
            if target.dead then return end
            if target.bcc then return end
            if target.dist > 40 then return end
            if target.los then
                awful.group.loop(function(group)
                    if group.isHealer then return end -- we don't want to use it on healer --
                    if group.los then
                        if spell:Cast(group) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                        end 
                    end 
                end)
            end
        end
    end) 
end)
    
bloodlustHorde:Callback("newburstNoHeal", function(spell)
if healer.exists then return end 
if awful.instanceType2 == "party" then return end --dungeon--
if awful.instanceType2 == "raid" then return end --raid--
--if not settings.autoburst then return end
if not player.hasTalent(193876) then return end --pvp talent heroism--
    awful.enemies.loop(function(enemy)

        if player.buff(191634) or player.buff(114050) or player.buff(375986) then  --stormkeeper, ascendance or primo wave
            
            if target.immuneMagicDamage then return end
            if target.buffFrom(immuneBuffs) then return end 
            if target.dead then return end
            if target.bcc then return end
            if target.dist > 40 then return end
            if target.los then
                awful.group.loop(function(group)
                    if group.los then
                        if spell:Cast(group) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                        end 
                    end 
                end)
            end
        end
    end) 
end)
------------------------------------------------------------------------------------------------actor---------------------------------------------------------------------------------------------
elemental:Init(function()

    if bursti == true then awful.alert({ message = awful.colors.cyan.. "Burst", texture = 242878, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) end
    if heal == true then awful.alert({ message = awful.colors.pink.. "Heal", texture = 8004, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) end
    --checkModeArena()

    --if awful.instanceType2 == "none" and not player.combat then return end 

    if awful.MacrosQueued["lasso"] then 
        lasso("macro")
    end

    healthStone()
    battleMaster()

    if awful.MacrosQueued["trinket"] then 
        medalTrinket()
    end

    if awful.player.mounted then return end

    if settings.nofightstarter and not awful.player.combat then return end 

    totemgrounding("trap")
    totemgrounding()
    totemgrounding("damagespells")
    totemgrounding("CDs")
    dispelcurse("healer")
    totemtremor("healer")
    totemtremor("nohealer")
    totemtremor("preTremorCasts")
    totemtremor("priestfear")
    totemtremor("warriorfear")

    astralshift("nohealer")
    astralshift("nobigdefs")
    astralshift("danger")
    astralshift("nobigdefs-MonkeyHealer")
    astralshift("inBGs")
    astralshift("inBGsLow")
    burrow("BGslow")
    burrow()
    burrow("MonkeyHealer")
    burrow("nohealer")
    lasso("precog")
    lasso("enemyHealer")
    lasso("HealerinCC")

    if awful.player.castID == 305483 then return end --lasso--

    healingsurge("macroLowest")
    healingsurge("macro")
    healautooff()

    if heal == true then return end 

    ancestralguidance()
    ancestralguidance("nohealer")

    if holdnow == true then awful.alert({ message = awful.colors.red.. "HOLDING GROUNDING", texture = 204336, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0 }) end
    if holdnow == true then return end 

    WasCastingCheck()

    if settings.autofocus then
    awful.AutoFocus() 
    end 

    --healthstone:grab()

    thunderstrikeWard()
    flametongue()
    lightningshield()
    skyfuryBuff()

    bloodlust("burst")
    bloodlust("newburst")
    bloodlust("newburstNoHeal")
    bloodlustHorde("burst")
    bloodlustHorde("newburst")
    bloodlustHorde("newburstNoHeal")
    onusePvpTrinket()
    --------------------------------------------PVP--------------------------------------------

    if settings.mode == "pvpmode" then

   -- if player.hasTalent(210689) then awful.alert({ message = awful.colors.red.. "Wrong Spec for PVP detected", texture = 159512, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0 }) end

    healingsurge("searingglare")

    if awful.player.debuff(410216) then return end --searing glare--

    windshear("casts")
    windshear("vsBoomkins")
    windshear("channel")
    windshear("channelotherkicks")
    windshear("otherchannels")
    windshear("nottakingthefckID")
    windshear("firebreath")
    windshear("firebreathChannel")
    windshear("disintigrate")

    if awful.player.buff(2645) then return end --ghost wolf--

    StopCastingInImmunities()
    hex("healerisinCC")
    hex("precog-Healer")
    hex("precog-Off")
    hex("Healer")

    --unleashshield("charge")
    --unleashshield("leap")
    unleashshield("FWs")
    unleashshield("Melees")
 
    totemroot("stopdrink")
    greaterpurge("mindcontrol")

    if awful.player.castID == 8004 then return end --healing surge--

    orcracial("burst")
    trollracial("burst")

    frostshock("smalltotems")
    lavaburst("bigpets")
    lavaburst("bigtotems")
    earthshock("bigtotems")
    earthshock("bigpets")

    frostshock("reflecttarget")
    --frostshock("procc") --for peeling--

    totempoisoncleanse("hunter")
    totempoisoncleanse("assa")
    healingsurge("ourgroup")
    healingsurge("lockedOnFire")
    earthshield("onme")
    earthshield("onOffDps")
    earthshield("onHealer2S")
    totemhealingstream()
    totemhealingstream("nohealer")
    totemStoneBulwark()
    totemStoneBulwark("emergency")
    thunderstorm()

    greaterpurge("purge")
    greaterpurge("offensivepurge")
    totemroot("pvp")
    totemroot("pvpOnEnemyHealer")
    totemroot("pvpPets")

    earthele()
    eartheleSTUN()
    stormele("burst")
    stormele("macrobursti")
    fireele("burst")
    fireele("macrobursti")
    fireeleAOE("burst")
    --totemskyfury("burst")
    ancestralSwiftness("PVP")
    primowave("burst")
    primowave("macrobursti")
    ascendance("burst")
    ascendance("burst2S")
    ascendance("Manualburst")
    ascendance("Stormkeeperburst")
    ascendance("StormkeeperManualburst")

    lightningbolt("targetProcc")
    flameshock("target")
    flameshock("targetManualBurst")
    
    totemliquidmagma("PVP")
    earthshock("target")
    lavaburst("targetProcc")
    frostshock("icefuryExecute")
    frostshock("targetProccExecute")
    flameshock("spread")
    lightningbolt("targetStormFrenzyProcc")
    flameshock("spreadpets")
    dispelcurse("agony")
    spiritwalker("PVP")
    stormkeeper("PVP")
    stormkeeper("PVPmacro")
    --totemstun("PVPBgs")
    frostshock("icefury")
    flameshock("spreadStormkeeper")
    lavaburst("targetCasting")
    totemliquidmagma("PVPoneEnemyOnly")
    lightningbolt("targetCasting")
    healingsurge("insteadOfLB")
    frostshock("targetProcc")
    healingsurge("outofcombat")

    flameshock("spreadLowPrio")
    --frostshock("target")

    --------------------------------------------PVE--------------------------------------------

    elseif settings.mode == "pvemode" then


    if settings.mode == "pvpmode" then return end 
    earthshield("PVEonTank")  
    earthshield("PVEonme")

    if awful.player.buff(2645) then return end --ghost wolf--
    if awful.instanceType2 == "party" and not target.combat then return end
    if awful.instanceType2 == "raid" and not target.combat then return end

    totemStoneBulwark("PVE")
    ancestralguidance("PVE")
    windshearPVE("PVE")
    totemwindrush("PVE")

    fireele("PVEburst")
    fireele("PVEmacrobursti")
    fireeleAOE("PVEburst")
    
    primowave("PVEburst")
    primowave("PVEmacrobursti")
    flameshock("PVEtarget")
    flameshock("PVEtargetManualBurst")

    stormele("PVEburst")
    stormele("PVEmacrobursti")
    totemicrecall("PVE")
    totemliquidmagma("PVE")
    totemliquidmagma("PVEmacro")
    ascendance("PVEburst")

    earthquakeTarget("PVE")
    
    lightningbolt("targetTempestST")
    earthshock("PVEtarget")
    totempoisoncleanse("PVE")
    dispelcurse("PVE")

    spiritwalker("PVE")

    stormkeeper("PVE")
    stormkeeper("PVEmacro")

    --lavaburst("PVEtargetProcc")
    lavaburst("PVEtargetProccPRIMO")
    lightningbolt("targetTempestAOE")
    chainlight("PVEtargetProcc")
    chainlight("PVEtargetProccTempest")
    natureSwiftness("PVE")
    ancestralSwiftness("PVE")
    lavaburst("PVEtargetProccMoving")
    flameshock("PVEplayerMoving")
    totemstunPVE("PVE")
    chainlight("PVE")
    lightningbolt("PVEtargetProcc")
    lightningbolt("PVEtargetStormFrenzyProcc")
    lightningbolt("PVEtargetCasting")

    flameshock("PVE")

    --lavaburst("PVEtargetCasting")
    healingsurge("PVEoutofcombat")

    end 

end)

-- Grounding im Duell testen
-- schauen ob andere spell school castet, wenn locked auf z. B. fire => wenn nicht dann bei spells adden "if blabla OR spell school locked then"
-- speziell "spread" bei pets überprüfen und anpassen => eventuell umändern in .enemy und einfach trotzdem blacklisten > scheint ok 