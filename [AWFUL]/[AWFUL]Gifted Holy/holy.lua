local Unlocker, awful, gifted = ...
awful.Devmode = true
awful.AntiAFK.enabled = true 

if WOW_PROJECT_ID == 2 then return end

gifted.paladin = {}
gifted.paladin.holy = awful.Actor:New({ spec = 1, class = "paladin" })


local paladin, holy = gifted.paladin, gifted.paladin.holy
local player, target, focus, healer, enemyHealer, arena1, arena2, arena3 = awful.player, awful.target, awful.focus, awful.healer, awful.enemyHealer, awful.arena1, awful.arena2, awful.arena3
local enemy = awful.enemy
local enemies = awful.enemies
local gcd, buffer, latency, tickRate, gcdRemains = awful.gcd, awful.buffer, awful.latency, awful.tickRate, awful.gcdRemains
local pet = awful.pet
local min, max, bin, cos, sin = min, max, awful.bin, math.cos, math.sin
local angles, acb, gdist, between = awful.AnglesBetween, awful.AddSlashAwfulCallback, awful.Distance, awful.PositionBetween
local events, colors, colored, escape = awful.events, awful.colors, awful.colored, awful.textureEscape
local succs = {127797, 307871, 355591, 355619 , 23284, 376080}
local CopyToClipboard = awful.unlock("CopyToClipboard")
local onUpdate, onEvent, hookCallbacks, hookCasts, Spell, Item = awful.addUpdateCallback, awful.addEventCallback, awful.hookSpellCallbacks, awful.hookSpellCasts, awful.NewSpell, awful.NewItem
gifted.delay = awful.delay(0.4, 0.6)
gifted.quickdelay = awful.delay(0.2, 0.4)
gifted.interruptDelay = awful.delay(0.2, 0.80)
local quickdelay = awful.delay(0.2, 0.4)
local randomd = math.random(0.4, 1)
local randomValue = math.random(-3, 3)
local dispelDelay = awful.delay(0.3, 0.6)
local NS = awful.NewSpell
local unitIDs = {  [179867] = {r = 69, g = 126, b = 151, a = 75, radius = 8}, -- static field totem
}
local party1, party2, party3 = awful.party1, awful.party2, awful.party3
local SpellStopCasting = awful.unlock("SpellStopCasting")
local NewItem = awful.NewItem
local Drinking = false
local CreateMacro = awful.unlock("CreateMacro")


if player.class2 ~= "PALADIN" then return end

local SpecCheck = function()
    return GetSpecialization()
end

gifted.holy = false

if SpecCheck() == 1 then
    gifted.holy = true
end

if not gifted.holy then return end

function gifted.print(...)
    print(awful.textureEscape(198034) .. awful.colors.white .. " - giftedPaladin |r")
    print("        " .. awful.textureEscape(384376) .. awful.colors.pink .. " |cFFF48CBA- Time to WIN!")
end

gifted.print()

local title = {
    ["PALADIN"] = {awful.colors.white .. '   Gifted    \n' .. awful.colors.pink .. "      |cFFF48CBAHoly       "},
}

local titleColor = {
    ["PALADIN"] = { 244, 140, 186 },
}

local primaryColor = {
    ["PALADIN"] = { 244, 140, 186 },
}

local ui, settings, cmd = awful.UI:New("gifted", {
    title = title[awful.player.class2][1],
    colors = {
        title = titleColor[awful.player.class2],
        primary = { 175, 175, 175, 0.8 },
        accent = {244, 140, 186, 1},
        background = { 12, 12, 12, 0.6 },
        tertiary = { 161, 161, 161, 0.5 }
    },
    sidebar = true,
    width = 400,
    height = 320,
    scale = 1,
    show = true,
    defaultTab = ("   " .. awful.textureEscape(198034, 20, "0:-1") .. awful.colors.pink .. " |cFFF48CBA-  Info"),
    cmd = { "gifted", "paladin", "gift", "gifts", "gr", "hpal" }
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

local spacer0 = ui:Tab(awful.colors.white .. "            -         ")

local Information = ui:Tab("   " .. awful.textureEscape(198034, 20, "0:-1") .. awful.colors.pink .. " |cFFF48CBA-  Info")



Information:Text({
    text = awful.textureEscape(198034, 22, "0:0") .. awful.colors.white .. "   Paladin | |cFFF48CBAHoly   " .. awful.textureEscape(384376, 22, "0:0"),
    size = 15,
    paddingLeft = 35,
    paddingBottom = 15
})

Information:Text({
    text = awful.textureEscape(317920, 22, "0:0") .. awful.colors.white .. " - To open the UI, type: |cFFF48CBA/hpal |r",
    size = 11,
    paddingBottom = 10,
})

Information:Text({
    text = awful.textureEscape(190784, 22, "0:0") .. awful.colors.white .. " - /hpal combo " .. awful.colors.paladin .. "(Freedom + Steed COMBO)",
    size = 10,
    paddingBottom = 5,
    paddingTop = 10,
})

Information:Text({
    text = awful.colors.white .. "   |cFFF48CBABuilds:",
    size = 14,
    paddingLeft = 80,
})

Information:Text({
    text = awful.textureEscape(431377, 22, "0:0") .. awful.colors.white .. " - Herald : |cFFF48CBA [Click]",
    size = 11,
    OnClick = function()
        CopyToClipboard("CEEA5ba6OK14IUITjS1kSUVJcBAAAYAAzAAAAYZMzMmZZmZxMmNzwyMzgtNTLNGLGmZGDYLDAYAwGwGzMDzsMLzMzSDAYmZZbplZGWAAbmhZmNzA")
        awful.alert({msg= "Talents copied to clipboard!", texture=431377})

    end
})

Information:Text({
    text = awful.textureEscape(432459, 22, "0:0") .. awful.colors.white .. " - Lightsmith (Recommended) : |cFFF48CBA [Click]",
    size = 11,
    OnClick = function()
        CopyToClipboard("CEEA5ba6OK14IUITjS1kSUVJcBAAAYAAzAAAAYZMzMmZZmZzMmNzw2AmttZapxMLGmZGDYLDAYAwGwGzMzYmlZZmZWaAAzMLbLtNzwGAGMzYMmB")
        awful.alert({msg= "Talents copied to clipboard!", texture=432459})

    end
})

Information:Text({
    text = awful.colors.white .. "  |cFFF48CBAPvP Talents:",
    size = 14,
    paddingLeft = 80,
    paddingTop = 5,
})

Information:Text({
    text = awful.textureEscape(199454, 22, "0:0") .. awful.colors.white .. "  |cFFF48CBA-  Blessed Hands |cFFF48CBA(Mandatory)",
    size = 10,
    paddingTop = 5,
})

Information:Text({
    text = awful.textureEscape(410126, 22, "0:0") .. awful.colors.white .. " |cFFF48CBA- Searing Glare |cFFF48CBA(Highly Recommended)",
    size = 10,
    paddingTop = 5,
})

Information:Text({
    text = awful.textureEscape(199324, 22, "0:0") .. awful.colors.white .. " |cFFF48CBA- Divine Vision |cFFF48CBA(Highly Recommended)",
    size = 10,
    paddingTop = 5,
})

Information:Text({
    text = awful.textureEscape(355858, 22, "0:0") .. awful.colors.white .. " |cFFF48CBA- Judgment of the Pure |cFFF48CBA(Flex)",
    size = 10,
    paddingTop = 5,
})

Information:Text({
    text = awful.textureEscape(199330, 22, "0:0") .. awful.colors.white .. " |cFFF48CBA- Cleanse the Weak |cFFF48CBA(Flex)",
    size = 10,
    paddingTop = 5,
})


local spacer0 = ui:Tab(awful.colors.white .. "            -                      ")

local General = ui:Tab("   " .. awful.textureEscape(31821, 20, "0:-1") .. awful.colors.white .. " |cFFF48CBA- General")

General:Text({
    text = awful.textureEscape(198034, 22, "0:0") .. awful.colors.priest .. "   Holy | |cFFF48CBAGeneral   " .. awful.textureEscape(384376, 22, "0:0"),
    size = 15,
    paddingLeft = 35,
    paddingBottom = 15
})

General:Checkbox({
    text = awful.textureEscape(200652, 22, "0:12") .. awful.colors.priest .. "  |cFFF48CBA-  Stop movement for priority casts",
    var = "controlmove", -- checked bool = settings.autoburst
    default = true,
    tooltip = "|cFFF48CBAAutomatically stop moving for priority casts.",
})

General:Checkbox({
    text = awful.textureEscape(8143, 22, "0:12") .. awful.colors.priest .. "  |cFFF48CBA-  Auto Stomp Priority Totems",
    var = "autostomp", -- checked bool = settings.autostomp
    default = true,
    tooltip = "|cFFF48CBAAutomatically stomp totems.",
})

General:Checkbox({
    text = awful.textureEscape(2096, 22, "0:12") .. awful.colors.priest .. "  |cFFF48CBA-  Auto Focus",
    var = "autofocus", -- checked bool = settings.autostomp
    default = true,
    tooltip = "|cFFF48CBAAutomatically set  your focus target.",
})

General:Dropdown({
    var = "auraselect",
    tooltip = "|cFFF48CBAChoose what Aura you want.",
    options = {
        { label = awful.textureEscape(317920, 22, "0:0") .. " |cFFF48CBA- Concentration Aura", value = "conc", tooltip = "|cFFF48CBAConcentration Aura" },
        { label = awful.textureEscape(465, 22, "0:0") .. " |cFFF48CBA- Devotion Aura", value = "devo", tooltip = "|cFFF48CBADevotion Aura" },
    },
    placeholder = awful.colors.purple .. "|cFFF48CBASelect Aura",
    header = awful.textureEscape(317920, 22, "0:0") .. awful.colors.priest .. "  |cFFF48CBA-  Select your Aura:",
    default = "devo",
})



local spacer0 = ui:Tab(awful.colors.white .. "            -                              ")

local Control = ui:Tab("   " .. awful.textureEscape(853, 20, "0:-1") .. awful.colors.white .. " |cFFF48CBA- Control")

Control:Text({
    text = awful.textureEscape(198034, 22, "0:0") .. awful.colors.priest .. "   Holy | |cFFF48CBAControl   " .. awful.textureEscape(384376, 22, "0:0"),
    size = 15,
    paddingLeft = 22,
    paddingBottom = 15
})

Control:Checkbox({
    text = awful.textureEscape(853, 22, "0:12") .. awful.colors.white .. "  |cFFF48CBA-  Auto Stun",
    var = "autostun", -- checked bool = settings.autoburst
    default = true,
    tooltip = "|cFFF48CBAAutomatically use Hammer Of Justice.",
})


Control:Checkbox({
    text = awful.textureEscape(96231, 22, "0:12") .. awful.colors.white .. "  |cFFF48CBA-  Auto Kick",
    var = "autokick", -- checked bool = settings.autoburst
    default = true,
    tooltip = "|cFFF48CBAAutomatically use Rebuke.",
})

local spacer0 = ui:Tab(awful.colors.white .. "            -                                           ")

local Defensive = ui:Tab("   " .. awful.textureEscape(642, 20, "0:-1") .. awful.colors.white .. " |cFFF48CBA- Def CDs")

Defensive:Text({
    text = awful.textureEscape(198034, 22, "0:0") .. awful.colors.priest .. "   Holy | |cFFF48CBADefensives   " .. awful.textureEscape(384376, 22, "0:0"),
    size = 15,
    paddingLeft = 25,
    paddingBottom = 15
})

Defensive:Checkbox({
    text = awful.textureEscape(1022, 22, "0:12") .. awful.colors.white .. "  |cFFF48CBA-  Special BoP",
    var = "specialbop", -- checked bool = settings.autoburst
    default = true,
    tooltip = "|cFFF48CBAAutomatically use BoP on specific CC/Debuffs" .. "\n" .. "It will only BoP if there is a value to it, otherwise it will hold it.",
})

Defensive:Slider({
    text = awful.textureEscape(642, 22, "0:0") .. awful.colors.priest .. "  |cFFF48CBA-  Divine Shield HP %",
    var = "divineshieldhp", -- checked bool = settings.autoburst
    default = 25,
    min = 0,
    max = 100,
    step = 1,
    tooltip = "|cFFF48CBADivine Shield HP % to use.",
})


Defensive:Slider({
    text = awful.textureEscape(6262, 22, "0:0") .. awful.colors.priest .. "  |cFFF48CBA-  Healthstone HP %",
    var = "healthstonehp", -- checked bool = settings.autoburst
    default = 35,
    min = 0,
    max = 100,
    step = 1,
    tooltip = "|cFFF48CBAHealth % to use Healthstone.",
})


Defensive:Slider({
    text = awful.textureEscape(345231, 22, "0:0") .. awful.colors.priest .. "  |cFFF48CBA-  BM Trinket HP %",
    var = "bmtrinkethp", -- checked bool = settings.autoburst
    default = 45,
    min = 0,
    max = 100,
    step = 1,
    tooltip = "|cFFF48CBAHealth % to use BM Trinket.",
})

local spacer0 = ui:Tab(awful.colors.white .. "            -                                            ")

local Draws = ui:Tab("   " .. awful.textureEscape(5502, 20, "0:-1") .. awful.colors.white .. " |cFFF48CBA-  Draws")

Draws:Text({
    text = awful.textureEscape(198034, 22, "0:0") .. awful.colors.priest .. "   Holy | |cFFF48CBADraws   " .. awful.textureEscape(384376, 22, "0:0"),
    size = 15,
    paddingLeft = 25,
    paddingBottom = 15
})

Draws:Checkbox({
    text = awful.textureEscape(83950, 22, "0:12") .. awful.colors.priest .. "  |cFFF48CBA-  Enable Drawings",
    var = "drawings", -- boolean = settings.esp
    default = true,
    tooltip = "|cFFF48CBAEnable or Disable drawings."
})

Draws:Checkbox({
    text = awful.textureEscape(267316, 22, "0:12") .. awful.colors.priest .. "  |cFFF48CBA-  Draw Suggestive Alerts",
    var = "drawalerts", -- boolean = settings.esp
    default = true,
    tooltip = "|cFFF48CBAEnable or Disable Suggestion Alerts."
})

Draws:Checkbox({
    text = awful.textureEscape(302582, 22, "0:12") .. awful.colors.priest .. "  |cFFF48CBA-  Draw Enemy Players",
    var = "drawenemy", -- boolean = settings.esp
    default = true,
    tooltip = "|cFFF48CBAEnable or Disable Enemy ESP."
})

Draws:Checkbox({
    text = awful.textureEscape(462905, 22, "0:12") .. awful.colors.priest .. "  |cFFF48CBA-  Draw Party Members",
    var = "drawteammates", -- boolean = settings.esp
    default = true,
    tooltip = "|cFFF48CBAEnable or Disable Teammate Lines."
})

Draws:Checkbox({
    text = awful.textureEscape(198838, 22, "0:12") .. awful.colors.priest .. "  |cFFF48CBA-  Draw Totem ESP",
    var = "totemesp", -- boolean = settings.esp
    default = true,
    tooltip = "|cFFF48CBAEnable or Disable Totem ESP."
})

local Buttons = ui:StatusFrame({
    colors = {
        background = { 0, 0, 0, 0 },
        enabled = { 30, 240, 255, 1 },
    },
    maxWidth = 500,
    padding = 7,
})

Buttons:Button({
    spellID = 156322,
    var = "enable",
    default = false,
    size = 30,
    text = function()
        if settings.enable then
            return awful.colors.purple .. "|cFFF48CBAOn"
        else
            return awful.colors.red .. "Off"
        end
    end,
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
                            draw:Circle(ux, uy, uz, data.radius * (1 - (unit.uptime / 6)))
                        else
                            draw:Circle(ux, uy, uz, data.radius * (unit.castpct / 100))
                        end
                    end
                end
            end
        end)
    end

    for _, enemy in ipairs(awful.enemies) do 
        
        if settings.drawings and settings.drawenemy and enemy.player then                        
            local icon = awful.textureEscape(626006, 16, "0:2")
            local classColors = {
                SHAMAN = {0, 112, 221},
                ROGUE = {255, 244, 104},
                WARRIOR = {198, 155, 109},
                WARLOCK = {135, 136, 238},
                DRUID = {255, 124, 10},
                PRIEST = {255, 255, 255},
                PALADIN = {244, 140, 104},
                MAGE = {63, 199, 235},
                DEATHKNIGHT = {196, 30, 58},
                HUNTER = {170, 211, 114},
                DEMONHUNTER = {163, 48, 201},
                MONK = {0, 255, 152},
                EVOKER = {14, 128, 22},
            }
            local classIcons = {
                SHAMAN = 626006,
                ROGUE = 626005,
                WARRIOR = 626008,
                WARLOCK = 626007,
                DRUID = 625999,
                PRIEST = 626004,
                PALADIN = 626003,
                MAGE = 626001,
                DEATHKNIGHT = 135771,
                HUNTER = 626000,
                DEMONHUNTER = 1260827,
                MONK = 626002,
                EVOKER = 4574311,
            }
            local color = classColors[enemy.class2]
            if color then
                draw:SetColor(color[1], color[2], color[3], 225)
                icon = awful.textureEscape(classIcons[enemy.class2], 16, "0:2")
            end

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

awful.Draw(function(draw)
    if settings.drawings and settings.drawteammates then
        awful.group.loop(function(member)
            if not member.exists then return end
            if member.visible then
                local lining = not member.los
                local ranging = member.dist > 38.5

                local classColors = {
                    SHAMAN = {0, 112, 221},
                    ROGUE = {255, 244, 104},
                    WARRIOR = {198, 155, 109},
                    WARLOCK = {135, 136, 238},
                    DRUID = {255, 124, 10},
                    PRIEST = {255, 255, 255},
                    PALADIN = {244, 140, 104},
                    MAGE = {63, 199, 235},
                    DEATHKNIGHT = {196, 30, 58},
                    HUNTER = {170, 211, 114},
                    DEMONHUNTER = {163, 48, 201},
                    MONK = {0, 255, 152},
                    EVOKER = {14, 128, 22},
                }
                
                draw:SetWidth(4 + bin(lining or ranging) + bin(lining) + bin(ranging))
                local colorValue = 0
        
                if not (lining or ranging) then
                    -- Set color to class color
                    local color = classColors[member.class2]
                    if color then
                        draw:SetColor(color[1], color[2], color[3], 255)
                    end
                else
                    -- Set color to shades of purple based on lining/ranging
                    colorValue = bin(lining or ranging) * 155
                    draw:SetColor(100 + colorValue, 100, 255 - colorValue, 255)
                end
        
                local px, py, pz = player.position()
                local hx, hy, hz = member.position()
                draw:Line(px, py, pz, hx, hy, hz)
            end
        end)
    end
end)

-- awful.Draw(function(draw)
--     if settings.drawings then

--         awful.group.loop(function(member)
--             if not member.exists then return end
--             if member.class ~= "WARLOCK" then return end
--             if not member.friendly then return end
--         end)
        
--         awful.objects.loop(function(object)
--             if object.source and object.source.enemy then return end
--             if object.exists and object.id == 191083 then
--                 local px, py, pz = player.position()
--                 local x, y, z = object.position()
--                 if x and y and z and px and py and pz then
--                     if object.losOf(player) and object.distanceTo(player) <= 40 then
--                         draw:SetColor(0, 255, 0, 255) -- Green color for good
--                         draw:SetWidth(5) -- Make it thick
--                         draw:FilledCircle(x, y, z, 1.5)
--                     else
--                     if not object.losOf(player) and object.distanceTo(player) > 40 then
--                         draw:SetColor(255, 0, 0, 255) -- Red color for bad
--                         draw:SetWidth(5) -- Make it thick
--                         draw:FilledCircle(x, y, z, 1.5)
--                         end
--                     end
--                 end
--             end
--         end)
--     end
-- end)


awful.Populate({

-- HEALS --
BarrierOfFaith = NS(148039, { beneficial = true, ignoreMoving = true, ignoreFacing = true, targeted = true }),
HolyShock = NS(20473, { heal = true, beneficial = true, ignoreMoving = true, ignoreFacing = true, targeted = true }),
FlashOfLight = NS(19750, { heal = true, beneficial = true, ignoreMoving = false, ignoreFacing = true, targeted = true }),
HolyLight = NS(82326, { heal = true, beneficial = true, ignoreMoving = false, ignoreFacing = true, targeted = true }),
WordOfGlory = NS(85673, { heal = true, beneficial = true, ignoreMoving = true, ignoreFacing = true, targeted = true }),
TyrsDeliverance = NS(200652, { heal = true, beneficial = true, ignoreMoving = false, ignoreFacing = true, targeted = true }),
HolyPrism = NS(114165, { heal = true, beneficial = true, ignoreMoving = true, targeted = true}),
EternalFlame = NS(156322, { heal = true, beneficial = true, ignoreMoving = true, targeted = true, ignoreFacing = true }),
HolyBulwark = NS(432459, { heal = true, beneficial = true, ignoreMoving = true, targeted = true, ignoreFacing = true }),
SacredWeapon = NS(432472, { heal = true, beneficial = true, ignoreMoving = true, targeted = true, ignoreFacing = true }),
-- END HEALS --

-- START COOLDOWNS --
AvengingWrath = NS(31884, { beneficial = true, ignoreGCD = true, targeted = false, ignoreFacing = true, ignoreMoving = true }),
AvengingCrusader = NS(216331, { beneficial = true, ignoreGCD = true, targeted = false, ignoreFacing = true, ignoreMoving = true }),
DivineToll = NS(375576, { beneficial = true, ignoreMoving = true, ignoreFacing = true, targeted = false }),
DayBreak = NS(414170, { beneficial = true, ignoreMoving = true, targeted = false, ignoreFacing = true }),
AuraMastery = NS(31821, { beneficial = true, ignoreMoving = true, targeted = false, ignoreFacing = true }),
DivineFavor = NS(210294, { beneficial = true, ignoreGCD = true, ignoreMoving = true, targeted = false, ignoreFacing = true }),
HandOfDivinity = NS(414273, { beneficial = true, targeted = false, ignoreFacing = true }),
BlessingOfAutumn = NS(388010, { beneficial = true, ignoreMoving = true, targeted = true, ignoreFacing = true }),
BlessingOfWinter = NS(388011, { beneficial = true, ignoreMoving = true, targeted = true, ignoreFacing = true }),
BlessingOfSpring = NS(388013, { beneficial = true, ignoreMoving = true, targeted = true, ignoreFacing = true }),
BlessingOfSummer = NS(388007, { beneficial = true, ignoreMoving = true, targeted = true, ignoreFacing = true }),
-- END COOLDOWNS --

-- START DEFENSIVES --
 DivineShield = NS(642, { beneficial = true, ignoreCasting = true, ignoreChanneling = true, ignoreFacing = true, targeted = false, castableInCC = true }),
 DivineProtection = NS(498, { beneficial = true, ignoreGCD = true, ignoreFacing = true, targeted = false, ignoreMoving = true, castableInCC = true }),
 LayOnHands = NS(633, { beneficial = true, ignoreGCD = true, ignoreFacing = true, targeted = true, ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true }),
 LayOnHandsTalent = NS(471195, { beneficial = true, ignoreGCD = true, ignoreFacing = true, targeted = true, ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true }),
 BlessingOfProtection = NS(1022, { beneficial = true, ignoreCasting = true, ignoreChanneling = true, targeted = true, ignoreMoving = true, castableInCC = true}),
 BlessingOfSacrifice = NS(6940, { beneficial = true, targeted = true, ignoreMoving = true, castableInCC = true}),
-- END DEFENSIVES --

-- START UTILITY --
DivineSteed = NS(190784, { beneficial = true, ignoreMoving = true, ignoreFacing = true, targeted = false, ignoreGCD = true, ignoreCasting = true, ignoreChanneling = true}),
HandOfReckoning = NS(62124, { ignoreMoving = true, ignoreGCD = true, targeted = true, ignoreCasting = true, ignoreChanneling = true }),
BeaconOfLight = NS(53563, { beneficial = true, ignoreMoving = true, targeted = true, ignoreFacing = true }),
BeaconOfFaith = NS(156910, { beneficial = true, ignoreMoving = true, targeted = true, ignoreFacing = true }),
Cleanse = NS(4987, { ignoreMoving = true, targeted = true, ignoreCasting = true, ignoreChanneling = true, ignoreFacing = true }),
BlessingOfFreedom = NS(1044, { beneficial = true, ignoreGCD = true, ignoreMoving = true, targeted = true, ignoreFacing = true, ignoreCasting = true, ignoreChanneling = true }),
RiteOfSanctification = NS(433568, { beneficial = true }),
-- END UTILITY --

-- START CC --
BlindingLight = NS(115750, { cc = "disorient" }),
Repentance = NS(20066, { cc = "incapacitate", effect = "magic" }),
HammerOfJustice = NS(853, { cc = "stun", effect = "magic", ignoreFacing = true }),
Rebuke = NS(96231, { interrupt = true, effect = "physical" }),
SearingGlare = NS(410126),
TurnEvil = NS(10326, { effect = "magic", cc = "fear", ignoreFacing = true, targeted = true }),
-- END CC --

-- START DAMAGE
Consecration = NS(26573, { damage = "magic", ignoreMoving = true, ignoreFacing = true, targeted = false }),
CrusaderStrike = NS(35395, { damage = "physical", ignoreMoving = true, targeted = true }),
Judgment = NS(275773, { damage = "magic", ignoreMoving = true, targeted = true }),
HammerOfWrath = NS(24275, {damage = "magic", ignoreMoving = true, targeted = true }),
Denounce = NS(2812, {damage = "magic", targeted = true }),
HolyShockDamage = NS(20473, { damage = "magic", ignoreMoving = true, targeted = true }),
-- END DAMAGE --

-- START AURAS --
DevotionAura = NS(465, { beneficial = true, targeted = false }),
ConcentrationAura = NS(317920, { beneficial = true, targeted = false }),
-- END AURAS --



-- START FOOD --
LavaCola = NewItem(227317),
-- END FOOD --


}, holy, getfenv(1))

-- instance check -- 

function gifted.inarena()
    local _, type = IsInInstance()
    return type == 'pvp' or type == 'arena'
end
-- end instance check --

-- START LOWEST FUNCTIONALITY --

gifted.ID = {
    buff = {
        Preparation       = 44521,
        ArenaPreparation  = 32727,
        SpellReflection   = 23920,
        GroundingTotem    = 8178,
        IceBlock          = 45438,
        DivineShield      = 642,
        AlterTime         = 108978,
        SpiritOfRedemption = 108968,
      },
      debuff = {
        Cyclone           = 33786,
        ShadowyDuel       = 207736,
        ShadowyDuelDebuff = 210558,
        FreezingTrap      = 203337,
        Imprison         = 221527,
      },
      buffGroup = {
        fullImmunity = {
          [108968]  = "Spirit of Redemption",
        },
      },
      debuffGroup = {
        ignoreFears = {
          [5782]    = "Fear",
          [5484]    = "Howl of Terror",
          [8122]    = "Psychic Scream",
          [10888]   = "Psychic Scream",
          [5246]   = "Intimidating Shout",
        },
        fullImmunity = {
          [33786]   = "Cyclone",
          [203337]  = "Freezing Trap",
          [221527]  = "Imprison",
          [207736]  = "Shadowy Duel",
          [210558]  = "Shadowy Duel Debuff",
          [378441]  = "Time Stop",
        },
      },
    }

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
        [378441] = true, -- Time Stop
    }

    
holy.LowestHealth = 100
holy.LowestUnit = player
holy.SecondLowestHealth = 100
holy.SecondLowestUnit = player
holy.ThirdLowestHealth = 100 
holy.ThirdLowestUnit = player 
holy.LowestActualHealth = 99999999
holy.LowestActualUnit = nil
holy.BeaconLightUp = false
holy.BeaconFaithUp = false
holy.AllLowHealth = 100
holy.AllLowUnit = player


function Lowest()
    holy.LowestHealth = 100
    holy.LowestUnit = player
    holy.SecondLowestHealth = 100
    holy.SecondLowestUnit = player
    holy.ThirdLowestHealth = 100  
    holy.ThirdLowestUnit = player 
    holy.LowestActualHealth = 99999999
    holy.LowestActualUnit = nil
    holy.BeaconLightUp = false
    holy.BeaconFaithUp = false
    holy.AllLowHealth = 100
    holy.AllLowUnit = player

    awful.fullGroup.loop(function(unit, i, uptime)
        if not unit.dead then
            -- Check for AllLowHealth without any restrictions
            if unit.hp < holy.AllLowHealth then
                holy.AllLowHealth = unit.hp
                holy.AllLowUnit = unit
            end

            if not unit.charmed and
               not unit.debuffFrom(gifted.ID.debuffGroup.fullImmunity) and
               not unit.buffFrom(gifted.ID.buffGroup.fullImmunity) then
                if unit.distance <= 40 then
                    if unit.los then
                        if unit.hp < holy.LowestHealth then
                            holy.ThirdLowestHealth = holy.SecondLowestHealth 
                            holy.ThirdLowestUnit = holy.SecondLowestUnit 
                            holy.SecondLowestHealth = holy.LowestHealth
                            holy.SecondLowestUnit = holy.LowestUnit
                            holy.LowestHealth = unit.hp
                            holy.LowestUnit = unit
                        elseif unit.hp < holy.SecondLowestHealth then
                            holy.ThirdLowestHealth = holy.SecondLowestHealth 
                            holy.ThirdLowestUnit = holy.SecondLowestUnit 
                            holy.SecondLowestHealth = unit.hp
                            holy.SecondLowestUnit = unit
                        elseif unit.hp < holy.ThirdLowestHealth then 
                            holy.ThirdLowestHealth = unit.hp  
                            holy.ThirdLowestUnit = unit  
                        end
                        if not unit.isUnit(player) and unit.health < holy.LowestActualHealth then
                            holy.LowestActualHealth = unit.health
                            holy.LowestActualUnit = unit
                        end
                    end
                end
            end
            if player.hastalent("Beacon of Faith") and unit.buff("Beacon of Faith", "player") then
                holy.BeaconFaithUp = true
            end
            if unit.buff("Beacon of Light", "player") then
                holy.BeaconLightUp = true
            end
        end
    end)
end
-- END LOWEST FUNCTIONALITY --

-- START TARGET FUNCTIONS --



gifted.FindOffTarget = function()
    local offTarget = nil
    local offTargetCount = 0
    local offTargetHp = 0
    awful.enemies.loop(function(enemy)
        if enemy.isUnit(enemyHealer) then return end
        local count = enemy.v2attackers()
        if offTarget == nil then
        bestOffTarget = enemy
        offTargetCount = count
        offTargetHp = enemy.hp 
        elseif count < offTargetCount then
        bestOffTarget = enemy
        offTargetCount = count
        offTargetHp = enemy.hp 
        elseif count == offTargetCount and enemy.hp > offTargetHp then
        bestOffTarget = enemy
        offTargetCount = count
        offTargetHp = enemy.hp 
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

local purgeClasses = 0

gifted.FindPurgeClasses = function()

    purgeClasses = 0


    awful.enemies.loop(function(enemy)
        if enemy.class == "MAGE" or enemy.class == "PRIEST" or enemy.class == "SHAMAN" or enemy.class == "EVOKER" or enemy.class == "HUNTER" then
            purgeClasses = purgeClasses + 1
        end
    end)
    return purgeClasses
end

-- END TARGET FUNCTIONS --

-- START FUNCTIONS FOR ROTATION -- 
awful.onUpdate(function()
    if settings.enable then
        awful.enabled = true
    else
        awful.enabled = false
    end
end)

function MinDelayTime()
    local _delay = awful.delay(0.25, 0.5)
    return _delay.now
end

local dontStop = {
    [TyrsDeliverance.id] = true,
    [SearingGlare.id] = true,
    [Repentance.id] = true,
    [FlashOfLight.id] = true,
    [HandOfDivinity.id] = true,
}

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


function setFocus()
    if not player.combat then return end
    if settings.autofocus then
        awful.AutoFocus()
    end
end



local cantBeKicked = {
    377360, --Precognition
    377362, --Precognition
    317929, --Aura Mastery 
}

function FreeCast()
    if not gifted.inarena() then return end
    if not player.combat then return end
    if player.buffFrom(cantBeKicked) then
        awful.alert({
            message = awful.colors.paladin .. " - Free Cast Now!",
            texture = 317929,
            big = true,
            highlight = true,
            outline = "OUTLINE",
        })
    end
end

function PreBuffGates()
if player.combat then return end
if not awful.prep then return end
if not player.buff(433550) then
awful.alert({
    message = awful.colors.paladin .. " - Apply Rite Of Sanctification!",
    texture = 433550,
    big = true,
    highlight = true,
    outline = "OUTLINE",
})
    end
end

gifted.healerLocked = false

local healerLockouts = {
    ["DRUID"] = "nature",
    ["PRIEST"] = "holy",
    ["PALADIN"] = "holy",
    ["SHAMAN"] = "nature",
    ["MONK"] = "nature",
    ["EVOKER"] = "nature"
}

gifted.CheckHealerLocked = function()
    if not player.combat then return end
    if not awful.arena then return end
    if not enemyHealer.exists then return end

    if healerLockouts[enemyHealer.class2] then
        local lockoutSchool = healerLockouts[enemyHealer.class2]

        if enemyHealer.lockouts[lockoutSchool] then
            gifted.healerLocked = true
        else
            gifted.healerLocked = false
        end
    else
        gifted.healerLocked = false
    end
end

function Soulwell()
    if not awful.prep then return end
    if player.mounted then return end
    if player.combat then return end
    if GetItemCount(5512) ~= 0 then return end

    if not player.combat then
        awful.objects.loop(function(obj)
            if obj.name == "Soulwell" and player.distanceTo(obj) < 3 then
            return obj:interact() and awful.alert("Grabbed Healthstone!", 5512)
            end
        end)
    end
end

local healthstone = awful.Item(5512)
local healthstoneUsed = 0

function Healthstone()

    if not awful.hasControl then return end

    if not player.combat then return end

    if healthstone.count == 0 then return end

    if healthstone.cd > 0 then return end

    if not healthstone.usable then return end

    if player.hp < settings.healthstonehp then
        if healthstone:Use() then
            healthstoneUsed = awful.time
            awful.alert({
                message = awful.colors.paladin .. " - Using Healthstone",
                big = true,
            })
        end
    end
end

local badges = awful.Item({
    218421, 218713,
})

function Badge()
    if not player.combat then return end
    if not badges.equipped then return end
    if badges.usable and badges.cd <= 0 then
        if badges:Use() then
            awful.alert({
                message = awful.colors.paladin .. " - Using Badge",
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
        if player.hp < settings.bmtrinkethp then
            if BMTrinket:Use() then
                awful.alert({
                    message = awful.colors.paladin .. " - Using Battlemasters!",
                    texture = 205781,
                    big = true,
                    highlight = true,
                    outline = "OUTLINE"
                })
            end
        end
    end
end

local totemUp = false

function TremorCheck()
    if not player.combat then return end
    awful.totems.loop(function(totem)
        if totem.friend then return end
        if totem.id == 5913 or totem.id == 5925 then
            totemUp = true
        else
            totemUp = false
        end
    end)
end

function TyrAlert()
if not player.hasTalent(200652) then return end -- tyrs
if awful.prep then return end
if not gifted.inarena() then return end
if not settings.drawalerts then return end
if TyrsDeliverance.cd > 2 then return end

    awful.alert({
        message = awful.colors.paladin .. " - LOS + DON'T MOVE TO CAST TYRS!",
        texture = 200652,
        big = true,
        highlight = true,
        outline = "OUTLINE"
    })
end

function HoJAlert()
    if not player.combat then return end
    if not gifted.inarena() then return end
    if awful.prep then return end
    if not settings.drawalerts then return end
    if not settings.autostun then return end
    if not HammerOfJustice:Castable() then return end
    if not enemyHealer.exists then return end
    if enemyHealer.immune then return end
    if enemyHealer.immuneMagic then return end
    if enemyHealer.immuneCC then return end
    if enemyHealer.buff("Nullifying Shroud") then return end
    if enemyHealer.distance < 10 then return end 
    if enemyHealer.stunDR < 1 then return end

    awful.alert({
        message = awful.colors.paladin .. " - GO HOJ HEALER!",
        texture = 853,
        big = true,
        highlight = true,
        outline = "OUTLINE"
    })
end
-- END FUNCTIONS FOR ROTATION -- 

-- START SPECIAL BOP STUFF --

local specialBoPs = {
    [2094] = { uptime = .6, min = 1.2}, -- blind
    [5246] = { uptime = .6, min = 1.2}, -- intim shout
    [408] = { uptime = .6, min = 1.2}, -- kidney shot
    [203123] = { uptime = .6, min = 1.2}, -- maim
    [385627] = { uptime = .6, min = 1.2}, -- kingsbane



}


local specialDisarmBoPs = {
    [233759] = { uptime = .6, min = 1.2}, -- Grapple Weapon
    [207777] = { uptime = .6, min = 1.2}, -- Dismantle
    [236077] = { uptime = .6, min = 1.2}, -- Disarm (A, P -- removed?)

}

local specialBurstBuffBoPs = {
    [102543] = { uptime = .6, min = 1.2}, -- Incarnation: Avatar of Ashemane (feral)

}

local specialBurstDebuffBoPs = {
    [274838] = { uptime = .6, min = 1.2}, -- Feral Frenzy (feral)

}


-- END SPECIAL BOP STUFF --

-- START DISPEL STUFF --

local dispelMagicList = {
    [217832]  = "true", -- Imprison
    [410201]  = "true", -- Searing Glare
    [211881]  = "true", -- Fel Eruption
    [3355]    = "true", -- Freezing Trap
    [118]     = "true", -- Polymorph
    [28271]   = "true", -- Polymorph (Turtle)
    [28272]   = "true", -- Polymorph (Pig)
    [61025]   = "true", -- Polymorph (Snake)
    [61305]   = "true", -- Polymorph (Black Cat)
    [61780]   = "true", -- Polymorph (Turkey)
    [61721]   = "true", -- Polymorph (Rabbit)
    [126819]  = "true", -- Polymorph (Porcupine)
    [161353]  = "true", -- Polymorph (Polar Bear Cub)
    [161354]  = "true", -- Polymorph (Monkey)
    [161355]  = "true", -- Polymorph (Penguin)
    [161372]  = "true", -- Polymorph (Peacock)
    [277787]  = "true", -- Polymorph (Baby Direhorn)
    [277792]  = "true", -- Polymorph (Bumblebee)
    [321395]  = "true", -- Polymorph (Mawrat)
    [391622]  = "true", -- Polymorph (Duck)
    [122]     = "true", -- Frost Nova
    [82691]   = "true", -- Ring of Frost
    [853]     = "true", -- Hammer of Justice
    [105421]  = "true", -- Blinding Light
    [10326]   = "true", -- Turn Evil
    [20066]   = "true", -- Repentance
    [198909]  = "true", -- Song of Chi-ji
    [34914]   = "true", -- Vampiric Touch
    [15487]   = "true", -- Silence
    [375901]  = "true", -- Mindgames
    [8122]    = "true", -- Psychic Scream
    [64044]   = "true", -- Psychic Horror
    [118699]  = "true", -- Fear
    [130616]  = "true", -- Fear (Horrify)
    [5484]    = "true", -- Howl of Terror
    [261589]  = "true", -- Seduction (Grimoire of Sacrifice)
    [6358]    = "true", -- Seduction (Succubus)
    [386997]  = "true", -- Soul Rot
    [6789]    = "true", -- Mortal Coil
    [108194]  = "true", -- Asphyxiate (Unholy)
    [221562]  = "true", -- Asphyxiate (Blood)
    [355689]  = "true", -- Landslide
    [360806]  = "true", -- Sleep Walk
    [383005]  = "true", -- Chrono Loop
    [2637]    = "true", -- Hibernate
    [390612]  = "true", -- Frost Bomb
    [287254]  = "true", -- Dead of Winter
    [339]     = "true", -- Entangling Roots
    [102359]  = "true", -- Mass Entanglement
    [64695]   = "true", -- Earthgrab
    [389831]  = "true", -- Snowdrift

}

gifted.dispelMagic = function(spell, unit)
    if not spell:Castable(unit) then return end

    for debuffId, _ in pairs(dispelMagicList) do
        if unit.debuffUptime(debuffId) > gifted.delay.now then
            return true
        end
    end
end

local dispelCurseList = {
    [51514]   = "true", -- Hex
    [196942]  = "true", -- Hex (Voodoo Totem)
    [210873]  = "true", -- Hex (Raptor)
    [211004]  = "true", -- Hex (Spider)
    [211010]  = "true", -- Hex (Snake)
    [211015]  = "true", -- Hex (Cockroach)
    [269352]  = "true", -- Hex (Skeletal Hatchling)
    [309328]  = "true", -- Hex (Living Honey)
    [277778]  = "true", -- Hex (Zandalari Tendonripper)
    [277784]  = "true", -- Hex (Wicker Mongrel)
    [80240]   = "true", -- Havoc
    [334275] = "true", -- Curse of Exhaustion
    [1714]   = "true", -- Curse of Tongues
    [702]    = "true", -- Curse of Weakness
}

gifted.dispelCurse = function(spell, unit)
    if not spell:Castable(unit) then return end

    for debuffId, _ in pairs(dispelCurseList) do
        if unit.debuffUptime(debuffId) > gifted.delay.now then
            return true
        end
    end
end

local dispelPoisonList = {

}

gifted.dispelPoison = function(spell, unit)
    if not spell:Castable(unit) then return end

    for debuffId, _ in pairs(dispelPoisonList) do
        if unit.debuffUptime(debuffId) > gifted.delay.now then
            return true
        end
    end
end

-- END DISPEL STUFF --

-- START DEBOUNCE DELAY FUNC --

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


-- END DEBOUNCE DELAY FUNC --

-- start GETSPELLINFO --

local GetSpellInfo = GetSpellInfo or function(spellID)
    if not spellID then
      return nil;
    end
  
    local spellInfo = C_Spell.GetSpellInfo(spellID);
    if spellInfo then
      return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID;
    end
  end

-- end GETSPELLINFO --


-- START EVENTS(?) --

local tauntID = {
    [187650] = function(spellID)
        return awful.missiles.find(function(obj) 
            return obj.source and obj.source.enemy and obj.spellId and obj.spellId == spellID
        end)
    end, 
   
}

awful.onEvent(function(info, event, source, dest)
    if event ~= "SPELL_CAST_SUCCESS" then return end
    local spellID = select(12, unpack(info))
    local aoe = tauntID[spellID]
    if not aoe then return end
    local missile = aoe(spellID)
    if not missile then return end
    local hx, hy, hz = missile.hx, missile.hy, missile.hz
    if player.distanceTo(hx, hy, hz) <= 10 then
        if player.magicEffectImmunityRemains > 1 + awful.buffer then return end
        awful.enemyPets.loop(function(pet)
            if pet.exists and not pet.dead and not pet.cc and 
               HandOfReckoning:Castable(pet) and pet.creatureType ~= "Totem" then
                if HandOfReckoning:Cast(pet) then
                    awful.alert({
                        message = "Taunt On " .. pet.name .. " (TRAP) ",
                        texture = spellID,
                        duration = 3,
                        color = {r = 244/255, g = 140/255, b = 186/255, a = 0.9} -- Paladin class color
                    })
                    return true
                end
            end
        end)
    end
end)


gifted.LOADING = 0
local function PauseVariable()
  gifted.LOADING = awful.time
end
awful.addEventCallback(PauseVariable, "PLAYER_ENTERING_WORLD")
awful.addEventCallback(PauseVariable, "PLAYER_LEAVING_WORLD")

-- END EVENTS -- 

-- START TOTEM STOMP --

local totemList = {
    5925, -- Grounding
    53006, -- Spirit link
    105451, -- Counterstrike
    179867, -- Static Field
    119052, -- War Banner
    5913, -- tremor totem
    60561, -- earthgrab totem
    105427, -- skyfury totem
    101398, -- Psyfiend
    107100, -- observer
    179193, -- fel obelisk
    61245, -- capacitor totem  --192058
    59764, -- healing tide totem
}
function TotemStomp(bigSpell, smallSpell, procSpell)
    if not settings.autostomp then return end
    if not player.combat then return end
    awful.units.loop(function(unit, uptime)
        if unit.friendly then return end
        if unit.uptime < (gifted.delay.now + awful.buffer) then return end
        if not unit.los then return end

        for key, value in ipairs(totemList) do
            if unit.id == value then
                if smallSpell:Castable(unit) and not gifted.WasCasting[smallSpell.id] then
                    if unit.hp <= 8000 then
                        awful.alert({
                            message = smallSpell.name .. " - Stomping Totem " .. unit.name,
                            color = {r = 244/255, g = 140/255, b = 186/255, a = 0.9} -- Paladin class color
                        })
                        return smallSpell:Cast(unit)
                    end
                end
                if bigSpell:Castable(unit) and not gifted.WasCasting[bigSpell.id] then
                    SpellStopCasting()
                    SpellStopCasting()
                    awful.alert({
                        message = bigSpell.name .. " - Stomping Totem " .. unit.name,
                        color = {r = 244/255, g = 140/255, b = 186/255, a = 0.9} -- Paladin class color
                    })
                    return bigSpell:Cast(unit)
                end
                if procSpell and procSpell:Castable(unit) and not gifted.WasCasting[procSpell.id] then
                    awful.alert({
                        message = procSpell.name .. " - Stomping Totem " .. unit.name,
                        color = {r = 244/255, g = 140/255, b = 186/255, a = 0.9} -- Paladin class color
                    })
                    return procSpell:Cast(unit)
                end
            end
        end
    end)
end

-- END TOTEM STOMP --

-- START AUTO ATTACK --
local attack = awful.NewSpell(6603)

function attack:start() return not self.current and attack:Cast() end

function attack:stop() return self.current and awful.call("StopAttack") end

function Attack()
  -- handle auto attacking
  if target.exists and target.enemy then
    if target.bcc then
      attack:stop()
    else
      attack:start()
    end
  end
end




-- END AUTO ATTACK --


-- START KICKS --


Rebuke:Callback("normal", function(spell)
    if not settings.autokick then return end
    if player.buff(gifted.GROUNDING_TOTEM_ID) then return end
    
    gifted.sortedEnemies.loop(function(enemy)

        if gifted.KickCheckCasting(enemy, spell) then
            if not gifted.ccKickList[enemy.castID] and not gifted.damageKickList[enemy.castID] then return end
            return spell:Cast(enemy)
        end
      
        if gifted.KickCheckChanneling(enemy, spell) then
            if not gifted.ccKickList[enemy.channelID] and not gifted.damageKickList[enemy.channelID] then return end
            return spell:Cast(enemy)
        end
    end)
end)

Rebuke:Callback("healer", function(spell)
    if not settings.autokick then return end
    if gifted.CheckHealerLocked() then return end -- if enemy is healer and locked, dont lock
    if gifted.sortedEnemies[1] and gifted.sortedEnemies[1].hp > 65 then return end -- if no one below 65% dont kick heal


    if gifted.KickCheckCasting(enemyHealer, spell) then
        if not gifted.healKickList[enemyHealer.castID] then return end
        return spell:Cast(enemyHealer)
    end

    if gifted.KickCheckChanneling(enemyHealer, spell) then
        if not gifted.healKickList[enemyHealer.channelID] then return end
        return spell:Cast(enemyHealer)
    end
end)


-- END KICKS --

-- START AURA STUFF --

ConcentrationAura:Callback(function(spell)
    if player.buff(317920) then return end
    if settings.auraselect == "conc" then
        gifted.debounceSpell("CONCENTRATIONAURA_PLAYER", 3500, 5000, spell, player)
    end
end)

DevotionAura:Callback(function(spell)
    if player.buff(465) then return end
    if settings.auraselect == "devo" then
        gifted.debounceSpell("DEVOTIONAURA_PLAYER", 3500, 5000, spell, player)
    end
end)

-- END AURA STUFF --

-- START BEACON STUFF --

BeaconOfLight:Callback("pvp", function(spell)
    if awful.prep then
        local party2 = awful.party2
        local targetUnit = party2.exists and party2 or player
        if not targetUnit.buff("Beacon of Light") and not targetUnit.buff("Beacon of Faith") and spell:Castable(targetUnit) then
             gifted.debounceSpell("BEACONOFLIGHT_TARGETUNIT", 3500, 5000, spell, targetUnit)
        end
    else
        if not player.hastalent("Beacon of Faith") then
            if not player.buff("Beacon of Light") and spell:Castable(player) then
                 gifted.debounceSpell("BEACONOFLIGHT_PLAYER", 3500, 5000, spell, player)
            end
        else
            if holy.LowestUnit and not holy.LowestUnit.buff("Beacon of Light") and not holy.LowestUnit.buff("Beacon of Faith") then
                if holy.LowestHealth < 70 and holy.LowestUnit.v2attackers() > 0 or not holy.BeaconLightUp then
                    if spell:Castable(holy.LowestUnit) then
                        return spell:Cast(holy.LowestUnit)
                    end
                end
            end
        end
    end
end)

BeaconOfFaith:Callback("pvp", function(spell)
    if awful.prep then
        local party1 = awful.party1
        if party1.exists and not party1.buff("Beacon of Faith") and spell:Castable(party1) then
            return gifted.debounceSpell("BEACONOFFAITH_PLAYER", 3500, 5000, spell, party1)
        end
    else
        if player.hastalent("Beacon of Faith") then
            if holy.LowestUnit and not holy.LowestUnit.buff("Beacon of Faith") and not holy.LowestUnit.buff("Beacon of Light") then
                if holy.LowestHealth < 70 and holy.LowestUnit.v2attackers() > 0 or not holy.BeaconFaithUp then
                    if spell:Castable(holy.LowestUnit) then
                        return spell:Cast(holy.LowestUnit)
                    end
                end
            end
        end
    end
end)

-- END BEACON STUFF --

-- START HAND OF RECKONING CASTED BCC --

local TauntCC = {
    -- Polymorph (Mage)
    118, 28271, 28272, 61305, 61721, 61025, 61780, 161372, 161355, 161353, 161354, 126819, 277787, 277792, 391631, 391622, 383121,
    -- Hex (Shaman)
    51514, 210873, 211004, 211015, 211010, 269352, 277778, 277784, 309328,
    -- Others
    5782, 118699, 20066, 605, 360806
}

HandOfReckoning:Callback("cc", function(spell)
    if not player.combat then return end
    

    awful.enemies.loop(function(enemy)
        if enemy.casting then
            for _, spellID in ipairs(TauntCC) do
                if enemy.castingid == spellID and enemy.castTarget.isUnit(player) and enemy.castRemains <= gifted.delay.now then
                    awful.enemyPets.loop(function(pet)
                        if pet.exists and not pet.dead and not pet.cc and 
                           HandOfReckoning:Castable(pet) and pet.creatureType ~= "Totem" then
                            if HandOfReckoning:Cast(pet) then
                                awful.alert({
                                    message = "Taunt On " .. pet.name .. " (CASTED BCC) ",
                                    texture = spell.id,
                                    duration = 3,
                                    color = {r = 244/255, g = 140/255, b = 186/255, a = 0.9} -- Paladin class color
                                })
                                return true
                            end
                        end
                    end)
                end
            end
        end
    end)
end)

-- END HAND OF RECKONING CASTED BCC --

-- START SACRIFICE CASTED BCC --

local SacCC = {
    -- Polymorph (Mage)
    118, 28271, 28272, 61305, 61721, 61025, 61780, 161372, 161355, 161353, 161354, 126819, 277787, 277792, 391631, 391622, 383121,
    -- Hex (Shaman)
    51514, 210873, 211004, 211015, 211010, 269352, 277778, 277784, 309328,
    -- Others
    5782, 118699, 20066, 605, 360806
}

BlessingOfSacrifice:Callback("cc",function(spell)
    if not spell:Castable(holy.LowestActualUnit) then return end
    if not player.combat then return end
    if holy.LowestHealth > 55 then return end
    if holy.LowestUnit.buffFrom(gifted.fullImmunityBuffs) then return end
    if player.lastCast == 62124 then return end
    if HolyBulwark:Castable(holy.LowestUnit) then return end

    local handOfReckoningCondition = false
    awful.enemies.loop(function(enemy)
        if enemy.casting then
            for _, spellID in ipairs(TauntCC) do
                if enemy.castingid == spellID and enemy.castTarget.isUnit(player) and enemy.castRemains <= gifted.delay.now then
                    awful.enemyPets.loop(function(pet)
                        if pet.exists and not pet.dead and not pet.cc and 
                           HandOfReckoning:Castable(pet) and pet.creatureType ~= "Totem" then
                            handOfReckoningCondition = true
                            return true
                        end
                    end)
                end
            end
        end
    end)

    if handOfReckoningCondition then return end

    awful.enemies.loop(function(enemy)
        if enemy.casting then
            for _, spellID in ipairs(SacCC) do
                if enemy.castingid == spellID then
                    if enemy.castTarget.isUnit(player) then
                        if enemy.castRemains <= gifted.delay.now then
                        if holy.LowestActualUnit and spell:Cast(holy.LowestActualUnit) then
                            awful.alert({
                                msg = "Sac on " .. holy.LowestUnit.name .. " - Pre-Sac CC",
                                texture = spell.id,
                                bgColor = {245/255, 60/255, 60/255, 0.9}
                              })
                            return true
                             end
                        end
                    end
                end
            end
        end
    end)
end)
-- END SACRIFICE CASTED BCC --

-- START BLESSING CALLBACKS --

local function getCurrentBlessing()
    for i = 1, 120 do
        local actionType, id = GetActionInfo(i)
        if actionType == "spell" then
            local spellInfo = C_Spell.GetSpellInfo(id)
            if spellInfo and spellInfo.name and spellInfo.name:match("Blessing of") then
                return spellInfo.name, id
            end
        end
    end
    return nil, nil
end


BlessingOfSpring:Callback("pvp", function(spell)
    if awful.prep then return end
    if holy.LowestHealth <= 70 then return end
    if not player.combat then return end

    local currentBlessing, currentId = getCurrentBlessing()

    if not currentBlessing or not currentBlessing:match("Spring") then
        return
    end

    if not spell:Castable() then return end
    if spell:Cast(player) then return end
end)


BlessingOfSummer:Callback("pvp", function(spell)
    if awful.prep then return end
    if holy.LowestHealth <= 70 then return end
    if not player.combat then return end
    if not holy.LowestUnit.exists then return end
    local currentBlessing, currentId = getCurrentBlessing()

    if not currentBlessing or not currentBlessing:match("Summer") then
        return
    end
    
    if not spell:Castable(holy.LowestUnit) then return end
    if spell:Cast(holy.LowestUnit) then return end
end)

BlessingOfAutumn:Callback("pvp", function(spell)
    if awful.prep then return end
    if not BlessingOfSummer:Castable() then return end
    if not player.combat then return end

    local currentBlessing, currentId = getCurrentBlessing()

    if not currentBlessing or not currentBlessing:match("Autumn") then
        return
    end

    if not spell:Castable() then return end
    if spell:Cast(player) then return end
end)


BlessingOfWinter:Callback("pvp", function(spell)
    if awful.prep then return end
    if holy.LowestHealth <= 70 then return end
    if not player.combat then return end

    local currentBlessing, currentId = getCurrentBlessing()

    if not currentBlessing or not currentBlessing:match("Winter") then
        return
    end
    
    if not spell:Castable() then return end
    if spell:Cast(player) then return end
end)

-- END BLESSING CALLBACKS --

-- JUDGMENT OF THE PURE CALLBACK --
local debuffList = {47476, 97547, 78675, 356727, 356719, 15487 } -- silences

Judgment:Callback("pure", function(spell)
    if not player.hasTalent(355858) then return end  -- Check for the specific talent

    
    awful.enemies.loop(function(enemy)
        for _, debuffID in ipairs(debuffList) do
            local debuff = player.debuff(debuffID, enemy)
            if debuff then
                if spell:Castable(enemy) then
                if spell:Cast(enemy) then
                    awful.alert({
                        msg = "Judgment on" .. enemy.name .. "for Debuff " .. GetSpellInfo(debuffID) .. ")",
                        texture = spell.id,
                        bgColor = {135/255, 136/255, 238/255, 0.95}
                      })
                    return true
                    end
                end
            end
        end
    end)
end)

-- END JUDGMENT OF THE PURE CALLBACK --

-- START DISPEL CALLBACKS --
Cleanse:Callback("magical", function(spell)
    if not player.combat then return end
    if not gifted.sortedFriendlies[1] then return end
    if gifted.sortedFriendlies[1].hp <= 30 then return end
    
    gifted.sortedFriendlies.loop(function(friendly)
        if friendly.debuff("Unstable Affliction") and not player.buff("Divine Shield") then return end
        if friendly.debuff("Vampiric Touch") and not player.buff("Divine Shield") then return end

        if gifted.dispelMagic(spell, friendly) then
            if spell:Cast(friendly) then
                awful.alert({
                    msg = "Dispelled " .. friendly.name,
                    texture = spell.id,
                    bgColor = {135/255, 136/255, 238/255, 0.95}
                })
                return true
            end
        end
    end)
end)

-- END DISPEL CALLBACKS --

-- START SEARING GLARE CALLBACKS --

local searingGlareTarget = nil

function SearingGlareFace()
    if not player.casting or player.castingid ~= SearingGlare.id then 
        searingGlareTarget = nil
        return 
    end

    -- If we've already calculated an angle for this cast, use it
    if searingGlareTarget then
        if not player.facing(searingGlareTarget, 5) then
            if player.castremains > awful.latency + awful.buffer then
                awful.protected.TurnOrActionStop()
                player.face(searingGlareTarget)
            end
        end
        return
    end
    local function findBestArc(priorityTarget)
        local bestAngle = 0
        local maxEnemiesHit = 0
        local bestTarget = nil

        for angle = 0, 359, 1 do
            local enemiesHit = 0
            local priorityHit = false
            awful.enemies.loop(function(enemy)
                if enemy.immune then return end
                if enemy.immuneMagic then return end
                if enemy.distance <= 18 and enemy.los and player.facing(enemy, 5, angle) then
                    enemiesHit = enemiesHit + 1
                    if enemy == priorityTarget then
                        priorityHit = true
                    end
                end
            end)
            if (priorityTarget and priorityHit and enemiesHit > maxEnemiesHit) or
               (not priorityTarget and enemiesHit > maxEnemiesHit) then
                maxEnemiesHit = enemiesHit
                bestAngle = angle
                bestTarget = priorityTarget or awful.enemies.find(function(enemy)
                    return enemy.distance <= 18 and enemy.los and player.facing(enemy, 5, angle)
                end)
            end
        end
        return bestTarget, maxEnemiesHit, bestAngle
    end

    -- Priority 1: Enemy with cooldowns
    local enemyWithCDs = awful.enemies.find(function(enemy)
        return enemy.distance <= 18 and enemy.los and enemy.cds
    end)

    -- Priority 2: 2 enemies possible to be hit
    local enemiesHit = 0
        awful.enemies.loop(function(e)
    local twoEnemiesHit = awful.enemies.find(function(e)
            if e.distance <= 18 and e.los then
                enemiesHit = enemiesHit + 1
            end
        end)
        return enemiesHit >= 2
    end)

    -- Priority 3: Enemy healer
    local enemyHealer = awful.enemies.find(function(enemy)
        return enemy.distance <= 18 and enemy.los and enemy.isHealer
    end)

    local bestTarget, enemiesHit, bestAngle, twoEnemiesHit

    if enemyWithCDs then
        bestTarget, enemiesHit, bestAngle = findBestArc(enemyWithCDs)
    elseif twoEnemiesHit then
        bestTarget, enemiesHit, bestAngle = findBestArc(twoEnemiesHit)
    elseif enemyHealer then
        bestTarget, enemiesHit, bestAngle = findBestArc(enemyHealer)
    else
        bestTarget, enemiesHit, bestAngle = findBestArc()
    end

    if bestTarget then
        searingGlareTarget = bestTarget
        if not player.facing(bestTarget, 5) then
            if player.castremains > awful.latency + awful.buffer then
                awful.protected.TurnOrActionStop()
                player.face(bestTarget)
            end
        end
    else
        -- Find the nearest enemy
        local nearestEnemy = awful.enemies.find(function(enemy)
            return enemy.distance <= 18 and enemy.los
        end)

        if nearestEnemy then
            searingGlareTarget = nearestEnemy
            if not player.facing(nearestEnemy, 5) then
                if player.castremains > 0 and player.castremains - awful.latency < awful.buffer then
                    awful.protected.TurnOrActionStop()
                    player.face(nearestEnemy)
                end
            end
        end
    end
end


SearingGlare:Callback("damage", function(spell)
    if player.debuff(410201) then return end
    if not player.combat then return end
    if player.buff(216331) then return end -- crusader
    if holy.LowestHealth <= 50 then return end
    if player.hp <= 50 then return end
    local total, melee, ranged, cooldowns = player.v2attackers()
    if total > 0 and player.canBeInterrupted(spell.castTime) then return end

    -- Find the lowest health enemy
    local lowestHealthEnemy = awful.enemies.find(function(enemy)
        return enemy.health <= 40
    end)

    -- Find enemy healer
    local enemyHealer = awful.enemies.find(function(enemy)
        return enemy.distance <= 18 and enemy.los and enemy.isHealer
    end)

    -- Find enemy with cooldowns
    local enemyWithCooldowns = awful.enemies.find(function(enemy)
        return enemy.distance <= 18 and enemy.los and enemy.cds
    end)

    local twoEnemiesHit = awful.enemies.find(function(enemy)
        local enemiesHit = 0
        awful.enemies.loop(function(e)
            if e.distance <= 18 and e.los then
                enemiesHit = enemiesHit + 1
            end
        end)
        return enemiesHit >= 2
    end)

    -- Cast if conditions are met
    if (lowestHealthEnemy and enemyHealer) or enemyWithCooldowns or twoEnemiesHit then
        if settings.controlmove then
            awful.controlMovement(0.3)
            if spell:Cast() then
                local reason = lowestHealthEnemy and enemyHealer and twoEnemiesHit "low hp" or "burst cds" or "2+ enemies"
                awful.alert({
                    msg = "Searing Glare: " .. reason,
                    texture = holy.SearingGlare.id,
                    bgColor = {135/255, 136/255, 238/255, 0.95}
                })
            end
        else
            if spell:Cast() then
                local reason = lowestHealthEnemy and enemyHealer and twoEnemiesHit "low hp" or "burst cds" or "2+ enemies"
                awful.alert({
                    msg = "Searing Glare: " .. reason,
                    texture = holy.SearingGlare.id,
                    bgColor = {135/255, 136/255, 238/255, 0.95}
                })
            end
        end
    end
end)


-- END SEARING GLARE CALLBACKS --

-- START HAMMER OF JUSTICE CALLBACKS --

HammerOfJustice:Callback("healer", function(spell)
    if not settings.autostun then return end
    if not player.combat then return end
    if player.debuff(410201) then return end
    if holy.LowestHealth <= 30 then return end
    if not enemyHealer.exists then return end
    if enemyHealer.buff(8178) then return end -- grounding totem
    if gifted.CheckHealerLocked() then return end 
    if spell:Castable(enemyHealer) and enemyHealer.stunDR == 1 and enemyHealer.ccRemains <= gifted.delay.now then
        SpellStopCasting()
        if spell:Cast(enemyHealer) then
            awful.alert({   
                msg = "Hammer of Justice on " .. enemyHealer.name,
                texture = spell.id,
                bgColor = {135/255, 136/255, 238/255, 0.95}
            })
            return true
        end
    end
end)

HammerOfJustice:Callback("healer-lowhp", function(spell)
    if not settings.autostun then return end
    if not player.combat then return end
    if holy.LowestHealth <= 30 then return end
    if not enemyHealer.exists then return end
    if enemyHealer.buff(8178) then return end -- grounding totem
    if gifted.CheckHealerLocked() then return end 
    awful.enemies.loop(function(enemy)
        if enemy.hp <= 30 then
    if spell:Castable(enemyHealer) and enemyHealer.stunDR >= 0.5 and enemyHealer.ccRemains <= gifted.delay.now then
        SpellStopCasting()
        if spell:Cast(enemyHealer) then
            awful.alert({   
                msg = "Hammer of Justice on " .. enemyHealer.name,
                texture = spell.id,
                bgColor = {135/255, 136/255, 238/255, 0.95}
            })
            return true
                end
            end
        end
    end)
end)

HammerOfJustice:Callback("killtarget", function(spell)
    if not settings.autostun then return end
    if not player.combat then return end
    if player.debuff(410201) then return end
    if holy.LowestHealth <= 30 then return end
    if player.hp <= 30 then return end

    if not enemyHealer.exists then return end
    if enemyHealer.ccRemains < 3 then return end

    local estimatedKillTarget = gifted.FindKillTarget()
    local estimatedOffTarget = gifted.FindOffTarget()

    if not estimatedKillTarget or not estimatedKillTarget.exists then return end
    if estimatedKillTarget.stunDR ~= 1 then return end
    if estimatedKillTarget.buff(8178) then return end -- grounding totem

    if spell:Castable(estimatedKillTarget) then
        if spell:Cast(estimatedKillTarget) then
            awful.alert({
                msg = "Hammer of Justice on " .. estimatedKillTarget.name,
                texture = spell.id,
                bgColor = {135/255, 136/255, 238/255, 0.95}
            })
        end
    end
end)

HammerOfJustice("offdps", function(spell)
    if not settings.autostun then return end
    if not player.combat then return end
    if player.debuff(410201) then return end
    if holy.LowestHealth <= 30 then return end
    if player.hp <= 30 then return end

    if not enemyHealer.exists then return end
    if (enemyHealer.cc and enemyHealer.ccRemains < 3) or (enemyHealer.bcc and enemyHealer.bccRemains < 3) then return end

    local estimatedKillTarget = gifted.FindKillTarget()
    local estimatedOffTarget = gifted.FindOffTarget()

    if not estimatedKillTarget then return end
    if estimatedKillTarget.stunDR == 1 then return end

    if not estimatedOffTarget.exists then return end
    if estimatedOffTarget.stunDR < 1 then return end
    if estimatedOffTarget.buff(8178) then return end -- grounding totem
    if (estimatedOffTarget.cc and estimatedOffTarget.ccr <= (0.3 + awful.buffer)) or (estimatedOffTarget.bcc and estimatedOffTarget.bccr <= (0.3 + awful.buffer)) then 

    if spell:Castable(estimatedOffTarget) then
        if spell:Cast(estimatedOffTarget) then
            awful.alert({
                msg = "HoJ on: " .. estimatedOffTarget.name .. "(CROSS oDPS)",
                texture = spell.id,
                bgColor = {135/255, 136/255, 238/255, 0.95}
            })
           end
        end
    end
end)





-- END HAMMER OF JUSTICE CALLBACKS --

-- START REPENTANCE/BLINDING LIGHT CALLBACKS --

Repentance:Callback("healer", function(spell)
    if not player.hasTalent("Repentance") then return end
    if gifted.WasCasting[spell.id] then return end
    if player.debuff(410201) then return end
    if player.buff(216331) then return end -- crusader
    if gifted.CheckHealerLocked() then return end 
    local total, melee, ranged, cooldowns = player.v2attackers()
    if melee > 0 or player.canBeInterrupted(spell.castTime) then return end
    if holy.LowestHealth <= 50 then return end
    if not enemyHealer.exists then return end
    if enemyHealer.immune then return end
    if enemyHealer.immuneMagic then return end
    if enemyHealer.immuneCC then return end
    if enemyHealer.buff(8178) then return end -- grounding totem
    local total, melee, ranged, cooldowns = enemyHealer.v2attackers()
    if total > 0 and enemyHealer.hp < 60 then return end
    if enemyHealer.debuff("unstable affliction") or enemyHealer.debuff("vampiric touch") or enemyHealer.debuff("rip") or enemyHealer.debuff("soul rot") then return end
    if spell:Castable(enemyHealer) and enemyHealer.incapacitateDR >= 0.5 and enemyHealer.ccRemains <= spell.castTime then
        if settings.controlmove then
            awful.controlMovement(0.3)
            if spell:Cast(enemyHealer) then
                return
            end
        else
            if spell:Cast(enemyHealer) then
                return
            end
        end
    end
end)

BlindingLight:Callback("healer", function(spell)
    if not player.hasTalent("Blinding Light") then return end
    if player.debuff(410201) then return end
    if holy.LowestHealth < 30 then return end
    if not enemyHealer.exists then return end
    if gifted.CheckHealerLocked() then return end 
    local total, melee, ranged, cooldowns = enemyHealer.v2attackers()
    if total > 0 then return end
    if enemyHealer.hp < 60 then return end
    if enemyHealer.debuff("unstable affliction") or enemyHealer.debuff("vampiric touch") or enemyHealer.debuff("rip") or enemyHealer.debuff("soul rot") then return end
    if enemyHealer.distance > 10 then return end
    if awful.enemies.around(enemyHealer, 10) > 0 then return end
    if spell:Castable(enemyHealer) and enemyHealer.disorientDR == 1 and enemyHealer.ccRemains <= spell.castTime then
        if spell:Cast(enemyHealer) then return end
    end
end)

BlindingLight:Callback("healer-lowhp", function(spell)
    if not player.hasTalent("Blinding Light") then return end
    if player.debuff(410201) then return end
    if holy.LowestHealth < 30 then return end
    if not enemyHealer.exists then return end
    if gifted.CheckHealerLocked() then return end 
    local total, melee, ranged, cooldowns = enemyHealer.v2attackers()
    if total > 0 then return end
    if enemyHealer.hp < 60 then return end
    if enemyHealer.debuff("unstable affliction") or enemyHealer.debuff("vampiric touch") or enemyHealer.debuff("rip") or enemyHealer.debuff("soul rot") then return end
    if enemyHealer.distance > 10 then return end
    if awful.enemies.around(enemyHealer, 10) > 0 then return end
    awful.enemies.loop(function(enemy)
        if enemy.hp <= 30 and not enemy.isUnit(enemyHealer) then
    if spell:Castable(enemyHealer) and enemyHealer.disorientDR >= 0.5 and enemyHealer.ccRemains <= spell.castTime then
        if spell:Cast(enemyHealer) then return end
            end
        end
    end)    
end)

-- END REPENTENCE/BLINDING LIGHT CALLBACKS --

-- START MACRO/DIVINE STEED + FREEDOM CALLBACKS --
awful.RegisterMacro("combo", 4)


local lastCastTime = 0 -- Tracks the last cast time to handle debounce
local debounceTime = 0.1 -- Approximate Global Cooldown (GCD) duration in seconds

-- Function to cast Divine Steed with necessary checks
local function castDivineSteed()
    if not player.combat then return end
    if player.mounted then return end

    -- Check if Divine Steed is on cooldown
    if DivineSteed.cd > 0 then
        return
    end
    -- Check the number of available charges for Divine Steed
    if DivineSteed.charges and DivineSteed.charges <= 0 then
        return
    end
    -- Attempt to cast Divine Steed on self
    if player.recentlyCast(190784, 4) then return end
    if DivineSteed:Cast(player) then
        lastCastTime = GetTime() -- Update the last cast time after successful cast
        awful.alert("!", DivineSteed.id) -- Alert with Divine Steed's icon
    end
end

function gifted.blessDivineSteed()
    if not player.combat then return end
    if player.mounted then return end
    local currentTime = GetTime()

    -- Prevent the function from executing if it was called too soon
    if currentTime - lastCastTime < debounceTime then
        return -- Exit early to avoid overlapping casts
    end

    -- Check if Blessing of Freedom is already active
    if player.buffRemains(1044) <= 5 and not player.recentlyCast(1044, 4) then -- Replace 1044 with the actual buff ID if different
        -- Attempt to cast Blessing of Freedom on self
        if BlessingOfFreedom:Cast(player) then
            lastCastTime = currentTime -- Update the last cast time after casting BoF
            if player.buff(1044) then
                castDivineSteed() -- Directly cast Divine Steed without scheduling
            end
        end
    else
        -- Proceed to cast Divine Steed immediately since BoF is active
        castDivineSteed()
    end
end
-- END MACRO/DIVINE STEED + FREEDOM CALLBACKS --


-- HEAL CALLBACKS --

HolyShock:Callback("fish", function(spell) 
    if not player.combat then return end
    if gifted.WasCasting[spell.id] then return end
    if player.buff(54149) then return end -- infusion
    if player.holypower >= 5 then return end
    if player.buff(414204) then return end -- rising sunlight(divine toll)

    local total, melee, ranged, cooldowns = holy.LowestUnit.v2attackers()

    if holy.LowestUnit then
        if holy.LowestHealth <= 88 and total >= 1 then
            if spell:Castable(holy.LowestUnit) then
                if spell:Cast(holy.LowestUnit) then
                    return
                end
            end
        end
    end
end)

HolyShock:Callback("refresh", function(spell) 
    if not player.combat then return end
    if gifted.WasCasting[spell.id] then return end
    if not player.buff(54149) then return end -- infusion
    if player.holypower >= 5 then return end
    if player.buff(414204) then return end -- rising sunlight(divine toll)

    local total, melee, ranged, cooldowns = holy.LowestUnit.v2attackers()

    if player.buffStacks(54149) < 2 and player.buffRemains(54149) <= 2 then -- infusion stacks < 2 and infusion refresh
        if holy.LowestUnit then
            if holy.LowestHealth <= 88 and total >= 1 then
                if spell:Castable(holy.LowestUnit) then
                    if spell:Cast(holy.LowestUnit) then
                        return
                    end
                end
            end
        end
    end
end)

HolyShock:Callback("ooc-fish", function(spell) -- herald talents only
    if player.combat then return end
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if awful.prep then return end
    if not gifted.inarena() then return end
    if gifted.WasCasting[spell.id] then return end
    if not player.buff(200652) then return end -- tyr's
    if player.buff(414204) then return end -- rising sunlight(wings/toll)

    local friendsCurrent = awful.fgroup.filter(function(obj)
        return obj.distance <= 40 and obj.los
    end)

    friendsCurrent.loop(function(friend)
        if friend.combat then return end
        if spell:Castable(friend) then
            if spell:Cast(friend) then
                return
            end
        end
    end)
end)

HolyShock:Callback("filler", function(spell) 
    if not player.combat then return end
    if gifted.WasCasting[spell.id] then return end
    if player.holyPower > 3 then return end
    if not holy.LowestUnit.exists and holy.LowestHealth >= 60 then return end 

    awful.enemies.loop(function(enemy)
        if not enemy.exists then return end
        if Judgment:Castable(enemy) then return end
        if CrusaderStrike:Castable(enemy) then return end
        if HammerOfWrath:Castable(enemy) then return end
    end)

    if holy.LowestHealth >= 65 then return end
    if spell:Castable(holy.LowestUnit) then
        if player.holypower < 3 then 
            if spell:Cast(holy.LowestUnit) then 
                awful.alert({
                    msg = "SHOCK FILLER ON : " .. holy.LowestUnit.name,
                    texture = spell.id,
                    duration = 2
                })
                return 
            end
        end
    end
end)

HolyShock:Callback("get-combat", function(spell) -- both talents

if player.combat then return end
if awful.prep then return end
if not gifted.inarena() then return end
if gifted.WasCasting[spell.id] then return end


awful.friends.loop(function(friend)
    if not friend.exists then return end
    if not friend.combat then return end
    if spell:Castable(friend) then
        if spell:Cast(friend) then return end
        end
    end)
end)

HolyShock:Callback("rising-sunlight", function(spell) -- both talents
    if not player.combat then return end
    if not player.hasTalent(461250) then return end
    if player.holypower >= 3 then return end
    if holy.LowestUnit.exists then
        if spell:Castable(holy.LowestUnit) and player.buff(414204) then
            if spell:Cast(holy.LowestUnit) then return end
        end
    end
end)

HolyShock:Callback("inf-lightsmith", function(spell) -- lightsmith talents only
    if not player.combat then return end

    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if not player.buff(54149) then return end -- infusion


    if holy.LowestHealth > 85 then return end

    if spell:Castable(holy.LowestUnit) then
        if spell:Cast(holy.LowestUnit) then return end
    end
end)


WordOfGlory:Callback("lowest", function(spell)
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent

    if not spell:Castable(holy.LowestUnit) then return end
    if holy.LowestHealth > 94 then return end
    if spell:Cast(holy.LowestUnit) then return end
end)

WordOfGlory:Callback("divine-purpose", function(spell)
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent

    if not player.buff(223819) then return end -- divine purpose

    if holy.LowestHealth > 94 then return end
    if spell:Castable(holy.LowestUnit) then
    if spell:Cast(holy.LowestUnit) then return end
      
    end
end)


EternalFlame:Callback("lowest", function(spell)
    if not IsPlayerSpell(156322) then return end
    if IsPlayerSpell(432459) then return end
    if not spell:Castable(holy.LowestUnit) then return end
    if holy.LowestHealth >= 90 then return end
    if spell:Cast(holy.LowestUnit) then return end
end)

EternalFlame:Callback("filler", function(spell)
    if awful.prep then return end
    if not IsPlayerSpell(156322) then return end
    if IsPlayerSpell(432459) then return end
    if not spell:Castable(holy.LowestUnit) then return end
    if player.holyPower < 3 then return end
    if holy.LowestHealth <= 96 then return end
    if holy.LowestUnit.buffRemains(156322) >= 10 then return end
    if spell:Cast(holy.LowestUnit) then
        awful.alert({
            msg = "EF FILLER ON : " .. holy.LowestUnit.name,
            texture = spell.id,
            bgColor = {244/255, 140/255, 186/255, 0.96}
        })
        return
    end
end)

EternalFlame:Callback("divine-purpose", function(spell)
    if not IsPlayerSpell(156322) then return end
    if IsPlayerSpell(432459) then return end
    if not player.buff(223819) then return end -- divine purpose
    if holy.LowestHealth >= 90 then return end
    if spell:Castable(holy.LowestUnit) then
    if spell:Cast(holy.LowestUnit) then return end
      
    end
end)


EternalFlame:Callback("spread-dawnlight", function(spell)
    if not player.buff(431522) then return end
    if not IsPlayerSpell(156322) then return end
    if IsPlayerSpell(432459) then return end
    if holy.LowestHealth <= 60 then return end

    if holy.LowestUnit.buff(431381) then
        if not holy.SecondLowestUnit.buff(431381) then
            if spell:Castable(holy.SecondLowestUnit) then
                if spell:Cast(holy.SecondLowestUnit) then
                    return
                end
            end
        end
    elseif not holy.ThirdLowestUnit.buff(431381) then
        if spell:Castable(holy.ThirdLowestUnit) then
            if spell:Cast(holy.ThirdLowestUnit) then
                return
            end
        end
    end
end)

BarrierOfFaith:Callback("cds", function(spell)
    if not player.combat then return end
    if player.buff(223819) then return end -- divine purpose
    if (player.buff(414204) or player.buff(414273) or player.buff(210294)) then return end -- rising sunlight or hand of divinity or divine favor
    if player.holypower >= 3 then return end
    if not holy.LowestUnit.exists then return end

    if holy.LowestUnit.hp >= 88 then return end

    if spell:Castable(holy.LowestUnit) then
        spell:Cast(holy.LowestUnit)
    end
end)

BarrierOfFaith:Callback("lowest", function(spell)
    if not player.combat then return end
    if player.buff(223819) then return end -- divine purpose
    if (player.buff(414204) or player.buff(414273) or player.buff(210294)) then return end -- rising sunlight or hand of divinity or divine favor
    if player.holypower >= 3 then return end
    if not holy.LowestUnit.exists then return end

    if holy.LowestUnit.hp >= 80 then return end

    if spell:Castable(holy.LowestUnit) then
        spell:Cast(holy.LowestUnit)
    end
end)



local function getCurrentBulwark()
    for i = 1, 120 do
        local actionType, id = GetActionInfo(i)
        if actionType == "spell" then
            local spellInfo = C_Spell.GetSpellInfo(id)
            if spellInfo and spellInfo.name and spellInfo.name:match("Holy Bulwark") then
                return spellInfo.name, id
            end
        end
    end
    return nil, nil
end


local function getCurrentWeapon()
    for i = 1, 120 do
        local actionType, id = GetActionInfo(i)
        if actionType == "spell" then
            local spellInfo = C_Spell.GetSpellInfo(id)
            if spellInfo and spellInfo.name and spellInfo.name:match("Sacred Weapon") then
                return spellInfo.name, id
            end
        end
    end
    return nil, nil
end


HolyBulwark:Callback("pre-combat", function(spell)
if player.combat then return end
if awful.prep then return end
if gifted.WasCasting[spell.id] then return end
if not gifted.inarena() then return end
if IsPlayerSpell(156322) then return end -- herald talent
if not IsPlayerSpell(432459) then return end -- lightsmith talent
if not holy.LowestUnit.exists then return end

if player.lastCast == 432459 then return end
if player.recentlyCast(432459, 2) then return end

local currentBulwark, currentId = getCurrentBulwark()

if not currentBulwark or not currentBulwark:match("Holy Bulwark") then
    return
end


awful.group.loop(function(friend)
    if friend.exists and friend.combat then
        if spell:Castable(friend) then
            if spell:Cast(friend) then return end
        end
    end
end)
end)


local BulwarkCC ={
    -- Repentance
    20066,
    118,
    -- Fear
    5782,
    65809,
    342914,
    251419,
    118699,
    30530,
    221424,
    41150,
    51514,
    211015,
    211010,
    211004,
    210873,
    269352,
    277778,
    277784,
    309328,
    161355,
    161354,
    161353,
    126819,
    61780,
    161372,
    61721,
    61305,
    28272,
    28271,
    277792,
    277787,
    391622,
    -- Sleep Walk
    360806,
    -- Polymorph (Mage)
    118, 28271, 28272, 61305, 61721, 61025, 61780, 161372, 161355, 161353, 161354, 126819, 277787, 277792, 391631, 391622, 383121,
    -- Hex (Shaman)
    51514, 210873, 211004, 211015, 211010, 269352, 277778, 277784, 309328,
    -- Others
    5782, 118699, 20066, 605, 360806,

}

HolyBulwark:Callback("pre-cc", function(spell)
    if not player.combat then return end
    if awful.prep then return end
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent

    if holy.LowestUnit.exists and holy.LowestUnit.buffFrom(gifted.fullImmunityBuffs) then return end

    local currentBulwark, currentId = getCurrentBulwark()

    if not currentBulwark or not currentBulwark:match("Holy Bulwark") then
        return
    end


    awful.enemies.loop(function(enemy)
        if enemy.casting then
            for _, spellID in ipairs(BulwarkCC) do
                if enemy.castingid == spellID then
                    if enemy.castTarget.isUnit(player) then
                        if enemy.castRemains <= gifted.delay.now then
                            local total, melee, ranged, cooldowns = holy.LowestUnit.v2attackers()
                            if total >= 1 and cooldowns >= 1 and holy.LowestHealth <= 88 then
                                if holy.LowestUnit and spell:Cast(holy.LowestUnit) then
                                    awful.alert({
                                        msg = "Bulwark on " .. holy.LowestUnit.name .. " - Pre-CC",
                                        texture = spell.id,
                                        bgColor = {245/255, 60/255, 60/255, 0.9}
                                    })
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end)


HolyBulwark:Callback("cds", function(spell)

if not player.combat then return end
if awful.prep then return end
if IsPlayerSpell(156322) then return end -- herald talent
if not IsPlayerSpell(432459) then return end -- lightsmith talent

local currentBulwark, currentId = getCurrentBulwark()

if not currentBulwark or not currentBulwark:match("Holy Bulwark") then
    return
end

awful.fgroup.loop(function(friend)
    if not friend.exists then return end
    if friend.buffFrom(gifted.fullImmunityBuffs) then return end
    if friend.buff(395180) then return end
    if friend.buff(432607) then return end


local total, melee, ranged, cooldowns = holy.LowestUnit.v2attackers()

if player.recentlyCast(432472, 2) then return end
if player.lastCast == 432472 then return end


if total >= 1 and cooldowns >= 1 and holy.LowestHealth <= 80 then
    if spell:Castable(holy.LowestUnit) then
        if spell:Cast(holy.LowestUnit) then return end
        end
    end
end)
end)

HolyBulwark:Callback("lowest", function(spell)

if IsPlayerSpell(156322) then return end -- herald talent
if not IsPlayerSpell(432459) then return end -- lightsmith talent

if not player.combat then return end
if awful.prep then return end

local currentBulwark, currentId = getCurrentBulwark()

if not currentBulwark or not currentBulwark:match("Holy Bulwark") then
    return
end

awful.fgroup.loop(function(friend)
    if not friend.exists then return end
    if friend.buffFrom(gifted.fullImmunityBuffs) then return end
    if friend.buff(395180) then return end
    if friend.buff(432607) then return end

local total, melee, ranged, cooldowns = holy.LowestUnit.v2attackers()

if player.recentlyCast(432472, 2) then return end
if player.lastCast == 432472 then return end

if total >= 1 and holy.LowestHealth <= 70 then
    if spell:Castable(holy.LowestUnit) then
        if spell:Cast(holy.LowestUnit) then return end
        end
    end
end)
end)

SacredWeapon:Callback("lowest", function(spell)
if IsPlayerSpell(156322) then return end -- herald talent
if not IsPlayerSpell(432459) then return end -- lightsmith talent
if not player.combat then return end
if awful.prep then return end

if player.recentlyCast(432459, 2) then return end

local currentWeapon, currentId = getCurrentWeapon()

if not currentWeapon or not currentWeapon:match("Sacred Weapon") then
    return
end


awful.fgroup.loop(function(friend)
    if not friend.exists then return end
    if friend.buffFrom(gifted.fullImmunityBuffs) then return end
    if friend.buff(395180) then return end
    if friend.buff(432607) then return end
    if friend.buff(432502) then return end -- sacred weapon
    if friend.hp <= 40 then return end -- do not use on ally at or below 40% hp

    local total, melee, ranged, cooldowns = friend.v2attackers()

    if holy.LowestUnit and holy.LowestHealth <= 88 and spell:Castable(friend) and total >= 1 then 
        if spell:Cast(friend) then return end
        end
    end)
end)


SacredWeapon:Callback("cds", function(spell)
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if not player.combat then return end
    if awful.prep then return end

    if player.recentlyCast(432459, 2) then return end

    local currentWeapon, currentId = getCurrentWeapon()

    if not currentWeapon or not currentWeapon:match("Sacred Weapon") then
        return
    end

    awful.enemies.loop(function(enemy)
        if not enemy.exists then return end
        if not enemy.cds then return end

        awful.fgroup.loop(function(friend)
            if not friend.exists then return end
            if friend.buffFrom(gifted.fullImmunityBuffs) then return end
            if friend.buff(395180) then return end
            if friend.buff(432607) then return end
            if friend.buff(432502) then return end -- sacred weapon
            if friend.hp <= 40 then return end -- do not use on ally at or below 40% hp


            local total, melee, ranged, cooldowns = friend.v2attackers()
            if total >= 1 and cooldowns >= 1 and holy.LowestUnit and holy.LowestHealth <= 92 and spell:Castable(friend) then 
                if spell:Cast(friend) then return end
            end
        end)
    end)
end)

TyrsDeliverance:Callback("precombat", function(spell)
    if player.combat then return end
    if awful.prep then return end
    if not gifted.inarena() then return end
    if not player.hasTalent(200652) then return end
    if gifted.WasCasting[spell.id] then return end
    if spell:Castable(player) then
        if settings.controlmove then
            awful.controlMovement(0.3)
        end
        if spell:Cast( {stopMoving = true} ) then
            return
        end
    else
        if spell:Cast(player) then
            return
        end
    end
end)

TyrsDeliverance:Callback("freecast-combat", function(spell)
    if not player.combat then return end
    if awful.prep then return end
    if not gifted.inarena() then return end
    if not player.hasTalent(200652) then return end
    if gifted.WasCasting[spell.id] then return end
    if player.holyPower >= 3 then return end
    if (player.buffFrom(cantBeKicked) and player.buffRemains(cantBeKicked) >= spell.castTime) or not player.canBeInterrupted(spell.castTime) then 
        if spell:Castable(player) then
            if settings.controlmove then
                awful.controlMovement(0.3)
            end
            if spell:Cast( {stopMoving = true} ) then
                awful.alert({
                    message = "Tyr's (FREECAST)",
                    texture = spell.id,
                    duration = 1.5,
                })
                return
            else
                if spell:Cast(player) then
                    awful.alert({
                        message = "Tyr's (FREECAST)",
                        texture = spell.id,
                        duration = 1.5,
                    })
                    return
                end
            end
        end
    end
end)

TyrsDeliverance:Callback("los-combat", function(spell)
    if not player.combat then return end
    if awful.prep then return end
    if not gifted.inarena() then return end
    if not player.hasTalent(200652) then return end
    if gifted.WasCasting[spell.id] then return end
    if player.holyPower >= 3 then return end
    if not player.losOf(holy.LowestUnit) then 
        if spell:Castable(player) then
            if settings.controlmove then
                awful.controlMovement(0.3)
            end
            if spell:Cast( {stopMoving = true} ) then
                awful.alert({
                    message = "Tyr's (LOS)",
                    texture = spell.id,
                    duration = 1.5,
                })
                return
            else
                if spell:Cast(player) then
                    awful.alert({
                        message = "Tyr's (LOS)",
                        texture = spell.id,
                        duration = 1.5,
                    })
                    return
                end
            end
        end
    end
end)

HandOfDivinity:Callback("tyrs", function(spell)
    if not player.combat then return end
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if not player.hasTalent(414273) then return end -- hand of divinity talent
    if player.holypower >= 5 then return end
    if awful.prep then return end
    if gifted.WasCasting[spell.id] then return end
    if not player.buff(200652) then return end -- tyr's 
    if not player.buff(54149) then return end -- infusion
    if spell:Castable() then
        if spell:Cast() then 
            awful.alert({
                message = "HoD (Tyr's)",
                texture = spell.id,
                duration = 2,
            })
            return
        end
    end
end)

HandOfDivinity:Callback("heals-notyrs", function(spell)
    if not player.combat then return end
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if not player.hasTalent(414273) then return end -- hand of divinity talent
    if player.holypower >= 5 then return end
    if awful.prep then return end
    if gifted.WasCasting[spell.id] then return end
    if player.buff(200652) then return end -- tyr's 
    if player.buffStacks(54149) < 2 then return end -- infusion
    if holy.LowestHealth >= 88 then return end
    if spell:Castable() then
        if spell:Cast() then 
            awful.alert({
                message = "HoD (No Tyr's)",
                texture = spell.id,
                duration = 2,
            })
            return
        end
    end
end)

HandOfDivinity:Callback("normal-lightsmith", function(spell) -- lightsmith talents only
    if not player.combat then return end
    if awful.prep then return end
    if gifted.WasCasting[spell.id] then return end
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if IsPlayerSpell(156322) then return end -- herald talent
    if not player.buff(54149) then return end -- infusion
    if player.buff(216331) then return end -- crusader buff
    if not holy.LowestUnit.exists then return end
    if holy.LowestHealth > 80 then return end

    awful.fgroup.loop(function(friend)
        if not friend.exists then return end
        if friend.buffFrom(gifted.fullImmunityBuffs) then return end
        if friend.buff(31821) then return end -- aura mastery
        if friend.buff(1022) then return end -- BoP
        if friend.buff(642) then return end -- divine shield
        if player.buff(414204) then return end -- rising sunlight

        if spell:Castable() then
            if settings.controlmove then
                awful.controlMovement(0.3)
                if spell:Cast() then return end
            else
                if spell:Cast() then return end
            end
        end
    end)
end)


HandOfDivinity:Callback("normal-lightsmith-ooc", function(spell) -- lightsmith talents only
    if player.combat then return end
    if awful.prep then return end
    if gifted.WasCasting[spell.id] then return end
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if IsPlayerSpell(156322) then return end -- herald talent
    if not holy.LowestUnit.exists then return end

    awful.fgroup.loop(function(friend)
        if not friend.exists then return end
        if not friend.combat then return end
        if friend.buffFrom(gifted.fullImmunityBuffs) then return end
        if friend.buff(31821) then return end -- aura mastery
        if friend.buff(1022) then return end -- BoP
        if friend.buff(642) then return end -- divine shield
        if player.buff(414204) then return end -- rising sunlight

        if spell:Castable() then
            if settings.controlmove then
                awful.controlMovement(0.3)
                if spell:Cast() then return end
            else
                if spell:Cast() then return end
            end
        end
    end)
end)

HolyLight:Callback("normal-lightsmith", function(spell) -- lightsmith talents only
    if not player.combat then return end
    if awful.prep then return end
    if gifted.WasCasting[spell.id] then return end
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if IsPlayerSpell(156322) then return end -- herald talent
    if not player.buff(54149) then return end -- infusion
    if player.buff(216331) then return end -- crusader buff
    if not player.buff(414273) then return end -- hand of divinity
    if not holy.LowestUnit.exists then return end
    if holy.LowestHealth > 85 then return end

    if spell:Castable(holy.LowestUnit) then
        if spell:Cast(holy.LowestUnit) then return end
    end
end)

HolyLight:Callback("HoD-Lightsmith-Remains", function(spell) -- lightsmith talents only
    if not player.combat then return end
    if awful.prep then return end
    if gifted.WasCasting[spell.id] then return end
    if not holy.LowestUnit.exists then return end
    if not player.hasTalent(414273) then return end -- hand of divinity talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if IsPlayerSpell(156322) then return end -- herald talent
    if not player.buff(414273) then return end -- hand of divinity
    if player.buffRemains(414273) > 3 then return end
    if holy.LowestHealth > 95 then return end
    if spell:Castable(holy.LowestUnit) then
        if spell:Cast(holy.LowestUnit) then 
            awful.alert({
                message = "HL on " .. holy.LowestUnit.name .. " (HoD Remains)",
                texture = spell.id,
                duration = 0.5,
            })
            return
        end
    end
    end)

DivineToll:Callback("holypower", function(spell)
    if not player.combat then return end
    if player.buff(414204) then return end -- rising sunlight(divine toll)
    if player.holypower > 1 then return end
    if player.buffStacks(54149) == 2 then return end
    if holy.LowestHealth > 75 then return end
    if spell:Castable(holy.LowestUnit) then
        if spell:Cast(holy.LowestUnit) then return end
    end
end)

DivineToll:Callback("health", function(spell)
    if not player.combat then return end
    if player.buff(414204) then return end -- rising sunlight(divine toll)
    if player.holypower >= 4 then return end
    if holy.LowestHealth > 60 then return end
    if spell:Castable(holy.LowestUnit) then
        if spell:Cast(holy.LowestUnit) then return end
    end
end)

-- START OF HAND OF DIVINITY HEAL STUFF --

HolyLight:Callback("HoD-tyrs", function(spell) -- herald talents only
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if not IsPlayerSpell(414273) then return end
    if not player.combat then return end
    if player.holypower >= 5 then return end
    if awful.prep then return end
    if gifted.WasCasting[spell.id] then return end
    if not player.hasTalent(414273) then return end -- hand of divinity talent
    if not player.buff(200652) then return end -- tyr's 
    if not player.buff(414273) then return end -- hand of divinity
    if holy.LowestHealth >= 95 then return end
    if spell:Castable(holy.LowestUnit) then
        if spell:Cast(holy.LowestUnit) then 
            awful.alert({
                message = "(HoD/Tyr's) HL on " .. holy.LowestUnit.name,
                texture = spell.id,
                duration = 2,
            })
            return
        end
    end
end)

HolyLight:Callback("HoD-notyrs", function(spell) -- herald talents only
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if not IsPlayerSpell(414273) then return end
    if not player.combat then return end
    if player.holypower >= 5 then return end
    if awful.prep then return end
    if gifted.WasCasting[spell.id] then return end
    if player.buff(200652) then return end -- tyr's 
    if not player.hasTalent(414273) then return end -- hand of divinity talent
    if not player.buff(414273) then return end -- hand of divinity
    if holy.LowestHealth >= 90 then return end
    if spell:Castable(holy.LowestUnit) then
        if spell:Cast(holy.LowestUnit) then 
            awful.alert({
                message = "(HoD) HL on " .. holy.LowestUnit.name,
                texture = spell.id,
                duration = 2,
            })
            return
        end
    end
end)


HolyLight:Callback("HoD-notyrs-remains", function(spell) -- herald talents only
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if not IsPlayerSpell(414273) then return end
    if not player.combat then return end
    if player.holypower >= 5 then return end
    if awful.prep then return end
    if gifted.WasCasting[spell.id] then return end
    if player.buff(200652) then return end -- tyr's 
    if not player.hasTalent(414273) then return end -- hand of divinity talent
    if not player.buff(414273) then return end -- hand of divinity
    if player.buffRemains(414273) > 3 then return end
    if holy.LowestHealth >= 90 then return end
    if spell:Castable(holy.LowestUnit) then
        if spell:Cast(holy.LowestUnit) then 
            awful.alert({
                message = "(HoD) HL on " .. holy.LowestUnit.name,
                texture = spell.id,
                duration = 2,
            })
            return
        end
    end
end)

-- END OF HAND OF DIVINITY HEAL STUFF --

-- START OF DIVINE FAVOR HEAL STUFF --

FlashOfLight:Callback("buffed", function(spell) -- need infusion + divine favor buffs 
    if not player.combat then return end
    if gifted.WasCasting[spell.id] then return end
    if not player.hasTalent(460422) then return end -- divine favor talent
    if player.buff(210294) and player.buff(54149) then -- divine favor or infusion
    if (holy.LowestHealth < 90 and holy.LowestHealth > 70) then 
        if spell:Castable(holy.LowestUnit) then
            if spell:Cast(holy.LowestUnit) then 
                awful.alert({
                    message = "(Divine Favor) HL on " .. holy.LowestUnit.name,
                    texture = spell.id,
                    duration = 2,
                })
                return
                 end
            end 
        end
    end
end)

FlashOfLight:Callback("buffednofillers", function(spell) -- need infusion + divine favor buffs 
    if not player.combat then return end
    if gifted.WasCasting[spell.id] then return end
    if not player.hasTalent(460422) then return end -- divine favor talent
    if player.buff(210294) then -- divine favor or infusion
    if Judgment:Castable() or HolyShock:Castable(holy.LowestUnit) or CrusaderStrike:Castable() then return end
    if (holy.LowestHealth < 90 and holy.LowestHealth > 70) then 
        if spell:Castable(holy.LowestUnit) then
            if spell:Cast(holy.LowestUnit) then 
                awful.alert({
                    message = "(Divine Favor) HL on " .. holy.LowestUnit.name,
                    texture = spell.id,
                    duration = 2,
                })
                return
                 end
            end 
        end
    end
end)


HolyLight:Callback("buffed", function(spell) -- need infusion + divine favor buffs
    if not player.combat then return end
    if gifted.WasCasting[spell.id] then return end
    if not player.hasTalent(460422) then return end -- divine favor talent
    if player.buff(210294) and player.buff(54149) then -- divine favor or infusion
    if (holy.LowestHealth <= 70 and holy.LowestHealth > 0) then
        if spell:Castable(holy.LowestUnit) then
            if spell:Cast(holy.LowestUnit) then 
                awful.alert({
                    message = "(Divine Favor) HL on " .. holy.LowestUnit.name,
                    texture = spell.id,
                    duration = 2,
                })
                return
                end
            end
        end
    end
end)


HolyLight:Callback("infusion", function(spell)
    if not player.combat then return end
    if player.buffRemains(54149) < spell.castTime then return end -- infusion
    if player.buff(210294) then return end -- divine favor
    if gifted.WasCasting[spell.id] then return end
    if not holy.LowestUnit.exists then return end
    if holy.LowestHealth <= 65 then
        if spell:Castable(holy.LowestUnit) then
            if spell:Cast(holy.LowestUnit) then return end
        end
    end 
end)

FlashOfLight:Callback("infusion", function(spell)
    if not player.combat then return end
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.buffRemains(54149) < spell.castTime then return end -- infusion
    if player.buff(210294) then return end -- divine favor
    if gifted.WasCasting[spell.id] then return end
    if not holy.LowestUnit.exists then return end
    if holy.LowestHealth >= 70 and holy.LowestHealth <= 90 then
        if spell:Castable(holy.LowestUnit) then
            if spell:Cast(holy.LowestUnit) then return end
        end
    end
end)

FlashOfLight:Callback("emergency-noprocs", function(spell)
    if not player.combat then return end
    if player.buff(54149) then return end -- infusion
    if player.buff(210294) then return end -- divine favor
    if DivineToll.cd < 2 then return end
    if AvengingWrath.cd < 2 then return end

    if gifted.WasCasting[spell.id] then return end
    if holy.LowestHealth <= 35 then
        if spell:Castable(holy.LowestUnit) then
            if spell:Cast(holy.LowestUnit) then return end
        end
    end
end)
-- END OF DIVINE FAVOR HEAL STUFF --



-- END HEALING CALLBACKS --

-- START DAMAGE CALLBACKS --

Judgment:Callback("cds-greater", function(spell) -- herald talents only
    if not player.buff(54149) then return end -- infusion
    if player.debuff(410201) then return end
    if holy.LowestHealth <= 30 then return end

    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent

    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
        if enemy.bcc and enemy.bccr > .5 then return end
        if enemy.isHealer then return end
        if not enemy.cds then return end
    
        if spell:Cast(enemy) then 
            awful.alert({msg = "Judgment on: " .. enemy.name .. " CDS", texture = 20271, duration = 2})
            return 
        end
    end)
end)

Judgment:Callback("cds-greater-lightsmith", function(spell) -- lightsmith talents only
    if not player.buff(54149) then return end -- infusion
    if player.debuff(410201) then return end
    if player.debuffFrom(debuffList) then return end

    if player.buff(216331) then return end -- crusader buff

    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent

    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
        if enemy.bcc and enemy.bccr > .5 then return end
        if enemy.isHealer then return end
        if not enemy.cds then return end
    
        if spell:Cast(enemy) then 
            awful.alert({msg = "Judgment on: " .. enemy.name .. " CDS", texture = 20271, duration = 2})
            return 
        end
    end)
end)

Judgment:Callback("awakeningpvp", function(spell) -- both talents
    if not target.enemy then return end
    if player.debuffFrom(debuffList) then return end
    if target.bcc and target.bccr > .5 then return end
    if not player.buff(414193) then return end
    if not spell:Castable(target) then return end
    if holy.LowestHealth <= 65 or holy.SecondLowestHealth <= 75 or holy.ThirdLowestHealth <= 85 then
        if spell:Cast(target) then return end
    end
end)


Judgment:Callback("filler", function(spell) 
    if not IsPlayerSpell(156322) then return end -- herald talent
    -- if IsPlayerSpell(432459) then return end -- lightsmith talent
    -- if player.buff(54149) then return end -- infusion
    if not player.combat then return end
    if player.holyPower > 4 then return end
    if player.debuffFrom(debuffList) then return end


    awful.enemies.loop(function(enemy)
        if not enemy.exists or not enemy.los then return end
        if enemy.bcc and enemy.bccr > .5 then return end

        if spell:Castable(enemy) then
            if player.holypower < 4 then 
                if spell:Cast(enemy) then 
                    awful.alert({
                        msg = "JUDG FILLER ON : " .. enemy.name,
                        texture = spell.id,
                        duration = 1
                    })
                    return 
                end
            end
        end
    end)
end)

Judgment:Callback("filler-infusion", function(spell) 
    if not player.combat then return end
    -- if not IsPlayerSpell(156322) then return end -- herald talent
    -- if IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.buff(54149) then return end -- infusion
    if player.holyPower > 4 then return end
    if player.debuffFrom(debuffList) then return end


    awful.enemies.loop(function(enemy)
        if not enemy.exists or not enemy.los then return end
        if enemy.bcc and enemy.bccr > .5 then return end
        if enemy.isUnit(enemyHealer) then return end

        if spell:Castable(enemy) then
            if player.holypower < 4 then 
                if spell:Cast(enemy) then 
                    awful.alert({
                        msg = "(INF) JUDG FILLER ON : " .. enemy.name,
                        texture = spell.id,
                        duration = 1
                    })
                    return 
                end
            end
        end
    end)
end)

Judgment:Callback("builder-infusion", function(spell) -- herald talents only
    if not player.combat then return end
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuffFrom(debuffList) then return end
    if player.debuff(410201) then return end
    if not player.buff(54149) then return end -- infusion

    if target.exists and target.enemy and not target.isUnit(enemyHealer) and spell:Castable(target) then return end

    if (player.hasTalent(31884) and player.buff(31884) and holy.LowestHealth <= 30) then return end -- herald check
    if (player.hasTalent(156322) and holy.LowestHealth <= 60) then return end -- herald check

    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
    end)



    local function castOnValidTarget(enemy)
        if enemy.isUnit(enemyHealer) then return end
        if enemy.exists and not enemy.dead and enemy.enemy and enemy.player and spell:Castable(enemy) then
            if enemy.bccr <= .5 then
                return spell:Cast(enemy, {alwaysFace = true})
            end
        end
        return false
    end

    if awful.arena then
        if awful.enemies.loop(castOnValidTarget) then return end
    end
end)

Judgment:Callback("builder-target", function(spell) -- herald talents only
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if player.debuffFrom(debuffList) then return end
    if not target.exists then return end
    if not target.enemy then return end
    if not player.buff(54149) then return end -- infusion
    if holy.LowestHealth <= 60 then return end
    if not spell:Castable(target) then return end
    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
    end)
    if (player.buff(31884) and holy.LowestHealth <= 35) then return end
    if target.bccr <= .5 then   
        if spell:Cast(target) then return end
    end
end)


Judgment:Callback("builder-lightsmith-infusion-enemy", function(spell) -- lightsmith talents only
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuffFrom(debuffList) then return end
    if player.debuff(410201) then return end
    if not player.buff(54149) then return end -- infusion
    if player.buff(216331) then return end -- crusader buff

    if target.exists and target.enemy and not target.isUnit(enemyHealer) and spell:Castable(target) then return end
    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
    end)



    local function castOnValidTarget(enemy)
        if enemy.exists and not enemy.dead and enemy.enemy and enemy.player and spell:Castable(enemy) then
            if enemy.bccr <= .5 then
                return spell:Cast(enemy, {alwaysFace = true})
            end
        end
        return false
    end

    if awful.arena then
        if awful.enemies.loop(castOnValidTarget) then return end
    end
end)


Judgment:Callback("builder-lightsmith-building-enemy", function(spell) -- lightsmith talents only
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuffFrom(debuffList) then return end
    if player.debuff(410201) then return end
    if player.buff(54149) then return end -- infusion
    if player.buff(216331) then return end -- crusader buff

    if player.holypower >= 3 then return end

    if target.exists and target.enemy and not target.isUnit(enemyHealer) and spell:Castable(target) then return end
    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
    end)



    local function castOnValidTarget(enemy)
        if enemy.exists and not enemy.dead and enemy.enemy and enemy.player and spell:Castable(enemy) then
            if enemy.bccr <= .5 then
                return spell:Cast(enemy, {alwaysFace = true})
            end
        end
        return false
    end

    if awful.arena then
        if awful.enemies.loop(castOnValidTarget) then return end
    end
end)

Judgment:Callback("builder-lightsmith-building-target", function(spell) -- lightsmith talents only
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if player.debuffFrom(debuffList) then return end
    if not target.exists then return end
    if not target.enemy then return end
    if player.buff(54149) then return end -- infusion
    if player.buff(216331) then return end -- crusader buff

    if player.holypower >= 3 then return end

    if not spell:Castable(target) then return end
    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
    end)
    if (player.buff(31884) and holy.LowestHealth <= 35) then return end
    if target.bccr <= .5 then   
        if spell:Cast(target) then return end
    end
end)


Judgment:Callback("builder-lightsmith-infusion-target", function(spell) -- lightsmith talents only
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if player.debuffFrom(debuffList) then return end
    if not target.exists then return end
    if not target.enemy then return end
    if not player.buff(54149) then return end -- infusion
    if player.buff(216331) then return end -- crusader buff

    if not spell:Castable(target) then return end
    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
    end)
    if (player.buff(31884) and holy.LowestHealth <= 35) then return end
    if target.bccr <= .5 then   
        if spell:Cast(target) then return end
    end
end)

Judgment:Callback("builder-lightsmith-crusader-enemy", function(spell) -- lightsmith talents only
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuffFrom(debuffList) then return end
    if player.debuff(410201) then return end
    if not player.buff(216331) then return end -- crusader buff

    if target.exists and target.enemy and not target.isUnit(enemyHealer) and spell:Castable(target) then return end
    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
    end)



    local function castOnValidTarget(enemy)
        if enemy.exists and not enemy.dead and enemy.enemy and enemy.player and spell:Castable(enemy) then
            if enemy.bccr <= .5 then
                return spell:Cast(enemy, {alwaysFace = true})
            end
        end
        return false
    end

    if awful.arena then
        if awful.enemies.loop(castOnValidTarget) then return end
    end
end)

Judgment:Callback("builder-lightsmith-crusader-target", function(spell) -- lightsmith talents only
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if not target.exists then return end
    if not target.enemy then return end
    if not player.buff(216331) then return end -- crusader buff

    if not spell:Castable(target) then return end
    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
    end)
    if (player.buff(31884) and holy.LowestHealth <= 35) then return end
    if target.bccr <= .5 then   
        if spell:Cast(target) then return end
    end
end)


Judgment:Callback("getcombat-lightsmith", function(spell) -- lightsmith talents only
    if player.combat then return end
    -- if IsPlayerSpell(156322) then return end -- herald talent
    -- if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuffFrom(debuffList) then return end
    if player.debuff(410201) then return end
    if target.exists and target.enemy and not target.isUnit(enemyHealer) and spell:Castable(target) then return end
    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
    end)



    local function castOnValidTarget(enemy)
        if enemy.exists and not enemy.dead and enemy.enemy and enemy.player and spell:Castable(enemy) then
            if enemy.bccr <= .5 then
                return spell:Cast(enemy, {alwaysFace = true})
            end
        end
        return false
    end

    if awful.arena then
        if awful.enemies.loop(castOnValidTarget) then return end
        if awful.enemyPets.loop(castOnValidTarget) then return end
    end
end)


CrusaderStrike:Callback("builder", function(spell) -- herald talents only
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if target.exists and target.enemy and spell:Castable(target) then return end
    if (player.buff(31884) and holy.LowestHealth <= 35) then return end



    local function castOnValidTarget(enemy)
        if enemy.exists and not enemy.dead and enemy.enemy and spell:Castable(enemy) then
            if enemy.bccr <= .5 then
                return spell:Cast(enemy, {alwaysFace = true})
            end
        end
        return false
    end

    if awful.arena then
        if awful.enemies.loop(castOnValidTarget) then return end
        if awful.enemyPets.loop(castOnValidTarget) then return end
    end
end)


CrusaderStrike:Callback("builder-lightsmith-enemy", function(spell) -- lightsmith talents only
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if player.buff(216331) then return end -- crusader buff
    if player.holypower >= 5 then return end
    if target.exists and target.enemy and spell:Castable(target) then return end



    local function castOnValidTarget(enemy)
        if enemy.exists and not enemy.dead and enemy.enemy and spell:Castable(enemy) then
            if enemy.bccr <= .5 then
                return spell:Cast(enemy, {alwaysFace = true})
            end
        end
        return false
    end

    if awful.arena then
        if awful.enemies.loop(castOnValidTarget) then return end
        if awful.enemyPets.loop(castOnValidTarget) then return end
    end
end)

CrusaderStrike:Callback("builder-lightsmith-crusader-enemy", function(spell) -- lightsmith talents only
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if not player.buff(216331) then return end -- crusader buff
    if target.exists and target.enemy and spell:Castable(target) then return end



    local function castOnValidTarget(enemy)
        if enemy.exists and not enemy.dead and enemy.enemy and spell:Castable(enemy) then
            if enemy.bccr <= .5 then
                return spell:Cast(enemy, {alwaysFace = true})
            end
        end
        return false
    end

    if awful.arena then
        if awful.enemies.loop(castOnValidTarget) then return end
        if awful.enemyPets.loop(castOnValidTarget) then return end
    end
end)


CrusaderStrike:Callback("builder-target", function(spell) -- herald talents only
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if not target.exists then return end
    if not target.enemy then return end
    if not spell:Castable(target) then return end
    if (player.buff(31884) and holy.LowestHealth <= 35) then return end
    if target.bccr <= .5 then   
        if spell:Cast(target) then return end
    end
end)

CrusaderStrike:Callback("builder-lightsmith-target", function(spell) -- lightsmith talents only
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if player.buff(216331) then return end -- crusader buff
    if not target.exists then return end
    if not target.enemy then return end
    if not spell:Castable(target) then return end
    if player.holypower >= 5 then return end
    if target.bccr <= .5 then   
        if spell:Cast(target) then return end
    end
end)

CrusaderStrike:Callback("builder-lightsmith-crusader-target", function(spell) -- lightsmith talents only
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if not player.buff(216331) then return end -- crusader buff
    if not target.exists then return end
    if not target.enemy then return end
    if not spell:Castable(target) then return end
    if player.holypower >= 5 then return end
    if target.bccr <= .5 then   
        if spell:Cast(target) then return end
    end
end)

HammerOfWrath:Callback("builder-target", function(spell) -- herald talents only
    if not IsPlayerSpell(156322) then return end -- herald talent
    if IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if not target.exists then return end
    if not target.enemy then return end
    if not spell:Castable(target) then return end
    if (player.buff(31884) and holy.LowestHealth <= 30) then return end
    if target.bccr <= .5 then   
        if spell:Cast(target) then return end
    end
end)

HammerOfWrath:Callback("builder-lightsmith-target", function(spell) -- lightsmith talents only
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if player.buff(216331) then return end -- crusader buff
    if not target.exists then return end
    if not target.enemy then return end
    if not spell:Castable(target) then return end
    if target.bccr <= .5 then   
        if spell:Cast(target) then return end
    end
end)

HammerOfWrath:Callback("builder-lightsmith-enemy", function(spell) -- lightsmith talents only
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if player.buff(216331) then return end -- crusader buff
    if target.exists and target.enemy and spell:Castable(target) then return end

    local function castOnValidTarget(enemy)
        if enemy.exists and not enemy.dead and enemy.enemy and spell:Castable(enemy) then
            if enemy.bccr <= .5 then
                return spell:Cast(enemy, {alwaysFace = true})
            end
        end
        return false
    end

    if awful.arena then
        if awful.enemies.loop(castOnValidTarget) then return end
        if awful.enemyPets.loop(castOnValidTarget) then return end
    end
end)

HammerOfWrath:Callback("builder-lightsmith-crusader-target", function(spell) -- lightsmith talents only
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if not player.buff(216331) then return end -- crusader buff
    if not target.exists then return end
    if not target.enemy then return end
    if not spell:Castable(target) then return end
    if target.bccr <= .5 then   
        if spell:Cast(target) then return end
    end
end)

HammerOfWrath:Callback("builder-lightsmith-crusader-enemy", function(spell) -- lightsmith talents only
    if IsPlayerSpell(156322) then return end -- herald talent
    if not IsPlayerSpell(432459) then return end -- lightsmith talent
    if player.debuff(410201) then return end
    if not player.buff(216331) then return end -- crusader buff
    if target.exists and target.enemy and spell:Castable(target) then return end

    local function castOnValidTarget(enemy)
        if enemy.exists and not enemy.dead and enemy.enemy and spell:Castable(enemy) then
            if enemy.bccr <= .5 then
                return spell:Cast(enemy, {alwaysFace = true})
            end
        end
        return false
    end

    if awful.arena then
        if awful.enemies.loop(castOnValidTarget) then return end
        if awful.enemyPets.loop(castOnValidTarget) then return end
    end
end)



Denounce:Callback("cds", function(spell)
    if not player.combat then return end
    if not player.hasTalent(2812) then return end
    if player.holyPower < 3 then return end
    if player.debuff(410201) then return end
    if holy.LowestHealth <= 60 then return end

    awful.enemies.loop(function(enemy)
        if not enemy.exists then return end
        if enemy.bccr > .5 then return end
        if enemy.isHealer then return end
        if not enemy.cds then return end
    
        if spell:Castable(enemy) then
            if spell:Cast(enemy) then 
                awful.alert({msg = "Denounce on: " .. enemy.name .. " CDS", texture = 2812, duration = 1})
                return 
            end
        end
    end)
end)


Denounce:Callback("spender", function(spell)
    if not player.combat then return end
    if not player.hasTalent(2812) then return end
    if player.holyPower < 3 then return end
    if player.debuff(410201) then return end
    if holy.LowestHealth <= 60 then return end

    local estimatedKillTarget = gifted.FindKillTarget()

    

    if estimatedKillTarget and estimatedKillTarget.exists and spell:Castable(estimatedKillTarget) then
        if estimatedKillTarget.bcc and estimatedKillTarget.bccr > .5 then return end
        if spell:Cast(estimatedKillTarget) then
            awful.alert({msg = "Denounce on: " .. estimatedKillTarget.name, texture = 2812, duration = 1})
            return
        end
    end
end)

Judgment:Callback("kill", function(spell)
    if holy.LowestHealth <= 40 then return end
    if player.debuffFrom(debuffList) then return end
    if (player.buff(31884) and holy.LowestHealth <= 35) then return end
    awful.enemies.loop(function(enemy)
        if player.hasTalent(355858) and (enemy.class == "DEATHKNIGHT" or enemy.class == "DRUID" and enemy.spec == "Balance") and (enemy.cooldown(47476) < 10 or enemy.cooldown(78675) < 10) then return end
    end)
    local function castOnLowHealthTarget(unit)
        return unit.hp < 20 and not unit.bcc and spell:Castable(unit) and spell:Cast(unit)
    end

    if target and castOnLowHealthTarget(target) then return end
    if awful.enemies.loop(castOnLowHealthTarget) then return end
end)

HammerOfWrath:Callback("kill", function(spell)
    if holy.LowestHealth <= 40 then return end
    if (player.buff(31884) and holy.LowestHealth <= 35) then return end
    local function castOnLowHealthTarget(unit)
        return unit.hp < 20 and not unit.bcc and spell:Castable(unit) and spell:Cast(unit)
    end

    if target and castOnLowHealthTarget(target) then return end
    if awful.enemies.loop(castOnLowHealthTarget) then return end
end)

HolyPrism:Callback("kill", function(spell)
    if holy.LowestHealth <= 40 then return end
    if (player.buff(31884) and holy.LowestHealth <= 35) then return end
    local function castOnLowHealthTarget(unit)
        return unit.hp < 20 and not unit.bcc and spell:Castable(unit) and spell:Cast(unit)
    end
    if awful.enemies.loop(castOnLowHealthTarget) then return end
end)

HolyShock:Callback("kill", function(spell)
    if holy.LowestHealth <= 40 then return end
    if player.manaPct <= 50 then return end
    if (player.buff(31884) and holy.LowestHealth <= 50) then return end
    if player.buff(414204) then return end -- rising sunlight
    local function castOnLowHealthTarget(unit)
        return unit.hp < 20 and not unit.bcc and spell:Castable(unit) and spell:Cast(unit)
    end

    if target and castOnLowHealthTarget(target) then return end
    if awful.enemies.loop(castOnLowHealthTarget) then return end
end)

CrusaderStrike:Callback("kill", function(spell)
    if holy.LowestHealth <= 40 then return end
    if (player.buff(31884) and holy.LowestHealth <= 35) then return end
    local function castOnLowHealthTarget(unit)
        return unit.hp < 20 and not unit.bcc and spell:Castable(unit) and spell:Cast(unit)
    end

    if target and castOnLowHealthTarget(target) then return end
    if awful.enemies.loop(castOnLowHealthTarget) then return end
end)

Denounce:Callback("kill", function(spell)
    if not player.hasTalent(2812) then return end
    if holy.LowestHealth <= 40 then return end
    if (player.buff(31884) and holy.LowestHealth <= 35) then return end
    if player.holyPower < 3 then return end

    local function castOnLowHealthTarget(unit)
    return unit.hp < 20 and not unit.bcc and spell:Castable(unit) and spell:Cast(unit)
    end

    if target and castOnLowHealthTarget(target) then return end
    if awful.enemies.loop(castOnLowHealthTarget) then return end
end)

Consecration:Callback("buff", function(spell)
    if not player.hasTalent(379008) then return end -- strength of conviction talent
    if holy.LowestHealth <= 40 then return end
    if spell:Castable() then
        if spell:Cast() then
            awful.alert({
                message = "STAND IN THE CONSECRATION! (BUFF)",
                texture = spell.id,
                duration = 2,
            })
            return
        end
    end
end)

-- END DAMAGE CALLBACKS --



-- START COOLDOWN CALLBACKS --

DivineProtection:Callback("cds", function(spell)
    if not spell:Castable() then return end
    if not player.combat then return end
    local total, melee, ranged, cooldowns = player.v2attackers()
    if total > 1 and cooldowns > 1 and player.hp < 75 then
        if spell:Cast() then
            awful.alert({
                msg = "Wall!",
                texture = spell.id,
                bgColor = {244/255, 140/255, 186/255, 0.96}
            })
            return
        end
    end
end)

DivineProtection:Callback("health", function(spell)
    if not spell:Castable() then return end
    if not player.combat then return end
    if player.hp < 70 and player.v2attackers() > 0 then
        if spell:Cast() then
            awful.alert({
                msg = "Wall (HP)!",
                texture = spell.id,
                bgColor = {244/255, 140/255, 186/255, 0.96}
            })
            return
        end
    end
end)

DivineProtection:Callback("stun", function(spell)
    if not spell:Castable() then return end
    if not player.combat then return end
    if player.stunned and player.stunRemains >= 3.5 then
        if player.hp <= 88 and player.v2attackers() > 0 then
            if spell:Cast() then
                awful.alert({
                    msg = "Wall (Stun)!",
                    texture = spell.id,
                    bgColor = {244/255, 140/255, 186/255, 0.96}
                })
                return
            end
        end
    end
end)

BlessingOfProtection:Callback("defensive", function(spell)
    if not spell:Castable() then return end
    if not player.combat then return end
    if holy.LowestUnit.exists and LayOnHandsTalent:Castable(holy.LowestUnit) then return end
    if gifted.WasCasting[spell.id] then return end
    if player.buff(31884) then return end
    if player.lastCast == 6940 then return end
    if player.recentlyCast(6940, 2) then return end
    if player.recentlyCast(31884, 2) then return end
    if player.lastCast == 31884 then return end

    awful.fullGroup.loop(function(member)

        awful.enemies.loop(function(enemy)

        if member.dead or member.debuff("Forbearance") or member.buff("aspect of the turtle") then return end
        if member.combat then
            local total, melee = member.v2attackers()
            local enemyHunters = 0
            awful.enemies.loop(function(unit)
                if unit.class == "HUNTER" and unit.target.isUnit(member) then
                    enemyHunters = enemyHunters + 1
                end
            end)
            
            if (melee > 0 or enemyHunters > 0) and enemy.distanceTo(member) <= 10 and
               not member.buffFrom(gifted.ID.buffGroup.fullImmunity) or member.debuffFrom(gifted.ID.debuffGroup.fullImmunity) or member.buff("aspect of the turtle") then
                if (member.hp > 55 and not member.buff("Blessing of Sacrifice")) or (member.hp > 25 and member.buff("Blessing of Sacrifice")) then return end
                if member.isUnit(player) and not player.hasTalent(146956) and DivineShield.cd < 0.5 then return end
                if spell:Cast(member) then
                    awful.alert({
                        msg = "BoP: " .. member.classString,
                        texture = spell.id,
                        bgColor = {244/255, 140/255, 186/255, 0.96}
                      })
                    return true
                  end
                end
            end
        end)
    end)
end)

BlessingOfProtection:Callback("feralburst", function(spell)
    if not settings.specialbop then return end
    if not player.combat then return end
    if player.debuff("Forbearance") then return end
    if gifted.WasCasting[spell.id] then return end
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if holy.LowestUnit.buff(1022) then return end
    if holy.LowestUnit.buff(6940) then return end
    if holy.LowestUnit.buff(31821) then return end

    awful.enemies.loop(function(enemy)
        if enemy.class ~= "DRUID" or enemy.spec ~= "Feral" then return end
        if not enemy.exists then return end
        if enemy.dead then return end
        if enemy.buffFrom(specialBurstBuffBoPs) then

            awful.group.loop(function(member)
                if member.dead or member.debuff("Forbearance") or member.buff("aspect of the turtle") then return end
                if member.debuffFrom(specialBurstBuffBoPs) then
                    local total, melee, ranged, cooldowns = member.v2attackers()
                    if total > 0 and cooldowns > 0 and member.hp <= 70 then
                        if spell:Cast(member) then
                            awful.alert({
                                msg = "Incarn + Frenzy BoP On : " .. member.name,
                                texture = spell.id,
                                bgColor = {244/255, 140/255, 186/255, 0.96}
                            })
                        end
                    end
                end
            end)
        end
    end)
end)

BlessingOfProtection:Callback("specialplayer", function(spell)
    if not settings.specialbop then return end
    if not player.combat then return end
    if player.debuff("Forbearance") then return end
    if gifted.WasCasting[spell.id] then return end
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if holy.LowestHealth >= 50 then return end

    if not player.debuffFrom(specialBoPs) then return end

    if spell:Castable(player) then
        if spell:Cast(player) then
            awful.alert({
                msg = "Special BoP On : " .. player.name,
                texture = spell.id,
                bgColor = {244/255, 140/255, 186/255, 0.96}
            })
        end
    end
end)


BlessingOfProtection:Callback("specialgroupdefensive", function(spell)
    if not settings.specialbop then return end
    if not player.combat then return end
    if gifted.WasCasting[spell.id] then return end
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if holy.LowestHealth >= 40 then return end

    awful.enemies.loop(function(enemy)
        if not enemy.exists then return end
        if enemy.dead then return end
        if not enemy.cds then return end
    end)

    awful.group.loop(function(member)
        local total, melee, ranged, cooldowns = member.v2attackers()
        if member.dead or member.debuff("Forbearance") or member.buff("aspect of the turtle") then return end
        if melee < 1 then return end
        if cooldowns < 1 and ranged < 1 then return end
        if member.debuffFrom(specialBoPs) then
            if spell:Castable(member) then
                if spell:Cast(member) then
                    awful.alert({
                        msg = "Defensive Special BoP On : " .. member.name,
                        texture = spell.id,
                        bgColor = {244/255, 140/255, 186/255, 0.96}
                    })
                end
            end
        end
    end)
end)

BlessingOfProtection:Callback("specialgroupdisarm", function(spell)
    if not settings.specialbop then return end
    if not player.combat then return end
    if gifted.WasCasting[spell.id] then return end
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if holy.LowestHealth < 55 then return end

    awful.enemies.loop(function(enemy)
        if not enemy.exists then return end
        if enemy.dead then return end
        if enemy.hp >= 50 then return end
    end)

    awful.group.loop(function(member)
        if member.dead or member.debuff("Forbearance") or member.buff("aspect of the turtle") then return end
        if member.debuffFrom(specialDisarmBoPs) and member.debuffRemains(specialDisarmBoPs) >= 3.5 then
            if spell:Castable(member) then
                if spell:Cast(member) then
                    awful.alert({
                        msg = "Disarm Special BoP On : " .. member.name,
                        texture = spell.id,
                        bgColor = {244/255, 140/255, 186/255, 0.96}
                    })
                end
            end
        end
    end)
end)

LayOnHands:Callback("defensive-no-melee", function(spell)
    if not player.combat then return end
    if gifted.WasCasting[spell.id] then return end
    if not LayOnHandsTalent:Castable() then return end

    awful.fullGroup.loop(function(member)
        if member.buff("Aspect of the Turtle") then return end
        if member.dead or member.debuff("Forbearance") then return end
        if member.buff(1022) then return end
        if member.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end

        local total, melee, ranged, cooldowns = member.v2attackers()
        local enemyHunters = 0

        awful.enemies.loop(function(unit)
            if unit.class == "HUNTER" and unit.target.isUnit(member) then
                enemyHunters = enemyHunters + 1
            end
        end)

        if (melee <= 0 and enemyHunters <= 0 and ranged > 0) and member.hp <= 30 then
            if spell:Cast(member) then
                awful.alert({
                    msg = "Lay on Hands: " .. member.classString .. " No Melee/Hunter",
                    texture = spell.id,
                    bgColor = {244/255, 140/255, 186/255, 0.96}
                })
                return true
                end
            end
    end)
end)


LayOnHands:Callback("defensive", function(spell)
    if not player.combat then return end
    if gifted.WasCasting[spell.id] then return end
    if not LayOnHandsTalent:Castable() then return end

    awful.fullGroup.loop(function(member)
        if member.buff("Aspect of the Turtle") then return end
        if member.dead or member.debuff("Forbearance") then return end
        if member.buff(1022) then return end
        if member.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end

        local total, melee = member.v2attackers()
        local enemyHunters = 0

        awful.enemies.loop(function(unit)
            if unit.class == "HUNTER" and unit.target.isUnit(member) then
                enemyHunters = enemyHunters + 1
            end
        end)

        if (total > 0 or enemyHunters > 0) and member.hp <= 30 then
            if spell:Cast(member) then
                awful.alert({
                    msg = "Lay on Hands: " .. member.classString .. " Attackers/HP",
                    texture = spell.id,
                    bgColor = {244/255, 140/255, 186/255, 0.96}
                })
                return true
                end
            end
    end)
end)


BlessingOfSacrifice:Callback("cooldowns", function(spell)
    if AuraMastery.cd < 2 then return end
    if not player.combat then return end
    if player.lastCast == 1022 then return end
    if player.recentlyCast(1022, 2) then return end
    if player.lastCast == 31821 then return end
    if player.recentlyCast(31821, 2) then return end
    if gifted.WasCasting[spell.id] then return end
    if not player.combat then return end
    if holy.LowestUnit.isUnit(player) then return end
    if holy.LowestUnit.buff(1022) then return end
    if holy.LowestUnit.buff(31821) or (holy.LowestUnit.buff(31821) and holy.LowestHealth > 20) then return end -- sac
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if holy.LowestUnit.buff("Aspect of the Turtle") then return end
    if holy.LowestUnit.buff(432459) then return end

    local total, melee, ranged, cooldowns = holy.LowestUnit.v2attackers()
    if total >= 1 and cooldowns >= 1 then 
        if holy.LowestHealth <= 55 then
            if spell:Castable(holy.LowestUnit) then
                if spell:Cast(holy.LowestUnit) then
                    awful.alert({
                        msg = "Sac: " .. holy.LowestUnit.name .. " On Enemy CD's",
                        texture = spell.id,
                        bgColor = {244/255, 140/255, 186/255, 0.96}
                    })
                    return
                end
            end
        end
    end
end)

BlessingOfSacrifice:Callback("health", function(spell)
    if AuraMastery.cd < 2 then return end
    if not player.combat then return end
    if player.lastCast == 1022 then return end
    if player.recentlyCast(1022, 1) then return end
    if gifted.WasCasting[spell.id] then return end
    if holy.LowestUnit.isUnit(player) then return end
    if holy.LowestUnit.buff(1022) then return end
    if player.lastCast == 31821 then return end
    if player.recentlyCast(31821, 2) then return end
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if holy.LowestUnit.buff("Aspect of the Turtle") then return end
    if holy.LowestUnit.buff(31821) or (holy.LowestUnit.buff(31821) and holy.LowestHealth > 20) then return end -- sac
    if holy.LowestUnit.buff(432459) then return end
    if holy.LowestHealth >= 40 then return end

    local total, melee, ranged, cooldowns = holy.LowestUnit.v2attackers()
    if total >= 1 then 
            if spell:Castable(holy.LowestUnit) then
                if spell:Cast(holy.LowestUnit) then
                    awful.alert({
                        msg = "Sac: " .. holy.LowestUnit.name .. " Low HP",
                        texture = spell.id,
                        bgColor = {244/255, 140/255, 186/255, 0.96}
                    })
                return
            end
        end
    end
end)

BlessingOfSacrifice:Callback("attackers", function(spell)
    if AuraMastery.cd < 2 then return end
    if not player.combat then return end
    if player.lastCast == 1022 then return end
    if player.recentlyCast(1022, 1) then return end
    if gifted.WasCasting[spell.id] then return end
    if not player.combat then return end
    if holy.LowestUnit.isUnit(player) then return end
    if holy.LowestUnit.buff(1022) then return end
    if player.lastCast == 31821 then return end
    if player.recentlyCast(31821, 2) then return end
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if holy.LowestUnit.buff("Aspect of the Turtle") then return end
    if holy.LowestUnit.buff(31821) or (holy.LowestUnit.buff(31821) and holy.LowestHealth > 30) then return end -- wall
    if holy.LowestUnit.buff(432459) then return end

    if holy.LowestHealth >= 70 then return end

    local total, melee, ranged, cooldowns = holy.LowestUnit.v2attackers()
    if total >= 2 then 
            if spell:Castable(holy.LowestUnit) then
                if spell:Cast(holy.LowestUnit) then
                    awful.alert({
                        msg = "Sac: " .. holy.LowestUnit.name .. " Lots of Attackers",
                        texture = spell.id,
                        bgColor = {244/255, 140/255, 186/255, 0.96}
                    })
                return
            end
        end
    end
end)

AuraMastery:Callback("spread-wall", function(spell)
    if not player.combat then return end
    if not spell:Castable() then return end
    if not player.buff(465) then return end -- devo aura
    if player.lastCast == 6940 then return end
    if player.recentlyCast(6940, 1) then return end
    if player.lastCast == 471195 then return end
    if player.recentlyCast(471195, 1) then return end
    

    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if holy.LowestUnit.buff(1022) then return end
    if holy.LowestUnit.buff(6940) or (holy.LowestUnit.buff(6940) and holy.LowestHealth > 40) then return end -- sac

    if holy.LowestUnit.buff("Aspect of the Turtle") then return end
    if (holy.LowestHealth < 60) or (holy.SecondLowestHealth < 70) or (holy.ThirdLowestHealth < 80) then
        if spell:Cast() then
            awful.alert({
                msg = "Aura Mastery (WALL)",
                texture = spell.id,
                bgColor = {244/255, 140/255, 186/255, 0.96}
            })
            return true
        end
    end
end)

AuraMastery:Callback("ST-wall", function(spell)
    if not player.combat then return end
    if not spell:Castable() then return end
    if not player.buff(465) then return end -- devo aura
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if holy.LowestUnit.buff(1022) then return end
    if holy.LowestUnit.buff("Aspect of the Turtle") then return end
    if player.lastCast == 6940 then return end
    if player.recentlyCast(6940, 1) then return end
    if player.lastCast == 471195 then return end
    if player.recentlyCast(471195, 1) then return end

    local total, melee, ranged, cooldowns = holy.LowestUnit.v2attackers()
    if total >= 1 and cooldowns >= 1 and holy.LowestHealth <= 80 then
    if holy.LowestUnit.buff(6940) or (holy.LowestUnit.buff(6940) and holy.LowestHealth > 35) then return end

        if spell:Cast() then
            awful.alert({
                msg = "Aura Mastery (ST WALL)",
                texture = spell.id,
                bgColor = {244/255, 140/255, 186/255, 0.96}
            })
            return true
        end
    end
end)

DivineShield:Callback("lowHP", function(spell)
    if not player.combat then return end
    if not spell:Castable() then return end
    if LayOnHandsTalent:Castable() then return end

    if player.hp <= settings.divineshieldhp and player.v2attackers() > 0 then
        if spell:Cast() then
            awful.alert({
                msg = "Divine Shield (Low HP)",
                texture = spell.id,
                bgColor = {244/255, 140/255, 186/255, 0.96}
            })
            return true
        end
    end
end)

AvengingWrath:Callback("lowHP", function(spell)
    if not player.combat then return end
    if not spell:Castable() then return end
    if not player.hasTalent(31884) then return end
    if player.hasTalent(216331) then return end
    if AuraMastery.cd < 2 then return end
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if player.lastCast == 1022 then return end
    if player.recentlyCast(1022, 2) then return end
    if holy.LowestUnit.buff(1022) then return end
    if player.lastCast == 31821 then return end
    if player.recentlyCast(31821, 1) then return end
    if player.lastCast == 6940 then return end
    if player.recentlyCast(6940, 1) then return end
    if holy.LowestUnit.buff(6940) or (holy.LowestUnit.buff(6940) and holy.LowestHealth > 45) then return end -- sac
    if holy.LowestUnit.buff(1022) or (holy.LowestUnit.buff(1022) and holy.LowestHealth > 25) then return end -- bop
    if holy.LowestUnit.buff(31821) or (holy.LowestUnit.buff(31821) and holy.LowestHealth > 35) then return end -- wall

    if holy.LowestHealth <= 40 then
        if spell:Cast() then
            awful.alert({
                msg = "Avenging Wrath (Low HP)",
                texture = spell.id,
                bgColor = {244/255, 140/255, 186/255, 0.96}
            })
            return true
        end
    end
end)

AvengingWrath:Callback("spread", function(spell)
    if not player.combat then return end
    if AuraMastery.cd < 2 then return end
    if not player.hasTalent(31884) then return end
    if player.hasTalent(216331) then return end
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if player.lastCast == 1022 then return end
    if player.recentlyCast(1022, 2) then return end
    if holy.LowestUnit.buff(1022) then return end
    if player.lastCast == 31821 then return end
    if player.recentlyCast(31821, 1) then return end
    if player.lastCast == 6940 then return end
    if player.recentlyCast(6940, 1) then return end
    if holy.LowestUnit.buff(6940) or (holy.LowestUnit.buff(6940) and holy.LowestHealth > 45) then return end -- sac
    if holy.LowestUnit.buff(1022) or (holy.LowestUnit.buff(1022) and holy.LowestHealth > 25) then return end -- bop
    if holy.LowestUnit.buff(31821) or (holy.LowestUnit.buff(31821) and holy.LowestHealth > 35) then return end -- wall
    if (holy.LowestHealth < 55) or (holy.SecondLowestHealth < 65) or (holy.ThirdLowestHealth < 75) then
        if spell:Cast() then
            awful.alert({
                msg = "Avenging Wrath (Team Low HP)",
                texture = spell.id,
                bgColor = {244/255, 140/255, 186/255, 0.96}
            })
            return true
        end
    end
end)


AvengingCrusader:Callback("lowHP", function(spell)
    if not player.combat then return end
    if not spell:Castable() then return end
    if not player.hasTalent(216331) then return end
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if player.lastCast == 1022 then return end
    if player.recentlyCast(1022, 2) then return end
    if holy.LowestUnit.buff(1022) then return end
    if player.lastCast == 31821 then return end
    if player.recentlyCast(31821, 1) then return end
    if player.lastCast == 6940 then return end
    if player.recentlyCast(6940, 1) then return end

    if player.recentlyCast(216331, 58) then return end

    if holy.LowestHealth <= 55 then
        if spell:Cast() then
            awful.alert({
                msg = "Avenging Crusader (Low HP)",
                texture = spell.id,
                bgColor = {244/255, 140/255, 186/255, 0.96}
            })
            return true
        end
    end
end)

AvengingCrusader:Callback("spread", function(spell)
    if not player.combat then return end
    if not player.hasTalent(216331) then return end
    if not spell:Castable() then return end
    if holy.LowestUnit.buffFrom(gifted.ID.buffGroup.fullImmunity) then return end
    if player.lastCast == 1022 then return end
    if player.recentlyCast(1022, 2) then return end
    if holy.LowestUnit.buff(1022) then return end
    if player.lastCast == 31821 then return end
    if player.recentlyCast(31821, 1) then return end
    if player.lastCast == 6940 then return end
    if player.recentlyCast(6940, 1) then return end

    if player.recentlyCast(216331, 58) then return end

    if (holy.LowestHealth < 55) or (holy.SecondLowestHealth < 65) or (holy.ThirdLowestHealth < 75) then
        if spell:Cast() then
            awful.alert({
                msg = "Avenging Crusader (Team Low HP)",
                texture = spell.id,
                bgColor = {244/255, 140/255, 186/255, 0.96}
            })
            return true
        end
    end
end)















-- END COOLDOWN CALLBACKS --


-- START FREEDOM CALLBACKS --

BlessingOfFreedom:Callback("player", function(spell)
    if not player.combat then return end
    if not spell:Castable() then return end
    if player.lastCast == 1044 then return end
    if player.recentlyCast(1044, 1) then return end
    if player.buff(1044) then return end
    if holy.LowestHealth <= 50 then return end

    local groupMembers = awful.group
    local rootDebuff = player.rooted and player.debuffRemains(player.rooted) > awful.gcd and player.debuffUptime(player.rooted) > gifted.delay.now
    local slowDebuff = player.slowed and player.debuffRemains(player.slowed) > awful.gcd and player.debuffUptime(player.slowed) > gifted.delay.now

    -- Check if player is out of LOS or too far from friends
    local outOfLosOrTooFar = true
    for _, member in ipairs(groupMembers) do
        if member.guid ~= player.guid and member.los or member.distance <= 40 then
            outOfLosOrTooFar = false
            break
        end
    end

    -- Check if player is rooted or slowed
    local isRootedOrSlowed = rootDebuff or slowDebuff

    -- Check if player has the specific buff (22883) and is slowed or rooted
    local hasSpecificBuff = player.buff(22883)

    -- Check if a Death Knight is casting Death Grip on the player
    local isDeathGripTarget = false
    awful.enemies.loop(function(enemy)
        if enemy.class == "DEATHKNIGHT" and enemy.lastCast  == 49576 and enemy.casttarget == player.guid then
                isDeathGripTarget = true
                return true -- Break the loop
        end
    end)

    if (outOfLosOrTooFar and isRootedOrSlowed) or (hasSpecificBuff and isRootedOrSlowed) or isDeathGripTarget then
        if spell:Cast(player) then
            awful.alert({
                msg = "Freedom: " .. player.name,
                texture = spell.id,
                bgColor = {225/255, 195/255, 30/255, 0.9}
              })
            return true
        end
    end
end)

BlessingOfFreedom:Callback("player-targeted", function(spell)
    if not player.combat then return end
    if not spell:Castable() then return end
    if player.lastCast == 1044 then return end
    if player.recentlyCast(1044, 1) then return end
    if player.buff(1044) then return end
    if holy.LowestHealth <= 50 then return end

    
    local total, melee, ranged, cooldowns = player.v2attackers()
    local rootDebuff = player.rooted and player.debuffRemains(player.rooted) > awful.gcd and player.debuffUptime(player.rooted) > gifted.delay.now
    local slowDebuff = player.slowed and player.debuffRemains(player.slowed) > awful.gcd and player.debuffUptime(player.slowed) > gifted.delay.now

    if melee >= 1 and (rootDebuff or slowDebuff) and player.hp <= 60 then
        if spell:Cast(player) then
            awful.alert({
                msg = "Freedom: " .. player.name .. " HP/Attackers",
                texture = spell.id,
                bgColor = {225/255, 195/255, 30/255, 0.9}
              })
        end
    end
end)


BlessingOfFreedom:Callback("player-targeted-burst", function(spell)
    if not player.combat then return end
    if not spell:Castable() then return end
    if player.lastCast == 1044 then return end
    if player.recentlyCast(1044, 1) then return end
    if holy.LowestHealth <= 50 then return end


    local total, melee, ranged, cooldowns = player.v2attackers()
    local rootDebuff = player.rooted and player.debuffRemains(player.rooted) > awful.gcd and player.debuffUptime(player.rooted) > gifted.delay.now
    local slowDebuff = player.slowed and player.debuffRemains(player.slowed) > awful.gcd and player.debuffUptime(player.slowed) > gifted.delay.now

    if total >= 1 and cooldowns >= 1 and (rootDebuff or slowDebuff) and player.hp <= 80 then
        if spell:Cast(player) then
            awful.alert({
                msg = "Freedom: " .. player.name .. " Burst/Attackers",
                texture = spell.id,
                bgColor = {225/255, 195/255, 30/255, 0.9}
              })
        end
    end
end)

BlessingOfFreedom:Callback("friend-root", function(spell)
    if not player.combat then return end
    if not spell:Castable() then return end
    if player.lastCast == 1044 then return end
    if player.recentlyCast(1044, 1) then return end
    if holy.LowestHealth <= 50 then return end


    awful.group.loop(function(friend)
    if not friend.exists then return end
    if not friend.melee then return end
    if not friend.rooted and not friend.slowed then return end
    if friend.cc then return end
    if friend.buff(1044) then return end

    local rootDebuff = friend.rooted and friend.debuffRemains(friend.rooted) > awful.gcd and friend.debuffUptime(friend.rooted) > gifted.delay.now
    local slowDebuff = friend.slowed and friend.debuffRemains(friend.slowed) > awful.gcd and friend.debuffUptime(friend.slowed) > gifted.delay.now

    local estimatedKillTarget = gifted.FindKillTarget()

    if not estimatedKillTarget then return end

    if friend.melee and friend.distanceTo(estimatedKillTarget) <= 8 then return end

    if rootDebuff or slowDebuff then
        if spell:Cast(friend) then
            return true
            end
        end
    end)
end)

BlessingOfFreedom:Callback("friend-health", function(spell)
    if not player.combat then return end
    if not spell:Castable() then return end
    if player.lastCast == 1044 then return end
    if player.recentlyCast(1044, 1) then return end
    if holy.LowestHealth <= 50 then return end


    awful.group.loop(function(friend)
        if not friend.exists then return end
        if friend.cc then return end
        if friend.buff(1044) then return end

        local rootDebuff = friend.rooted and friend.debuffRemains(friend.rooted) > awful.gcd and friend.debuffUptime(friend.rooted) > gifted.delay.now
        local slowDebuff = friend.slowed and friend.debuffRemains(friend.slowed) > awful.gcd and friend.debuffUptime(friend.slowed) > gifted.delay.now
        local snareDebuff = friend.snared and friend.debuffRemains(friend.snared) > awful.gcd and friend.debuffUptime(friend.snared) > gifted.delay.now 
        
        local total, melee, ranged, cooldowns = friend.v2attackers()
        if not rootDebuff and not slowDebuff and not snareDebuff then return end
        if friend.ranged and melee >= 1 and friend.hp <= 60 then
            if spell:Castable(friend) then
                if spell:Cast(friend) then
                    return true
                end
            end
        end
    end)
end)

-- END FREEDOM CALLBACKS --



holy:Init(function()
-- ignore --
gifted.filteredEnemies = awful.enemies.filter(function(enemy) return enemy.isPlayer and not enemy.dead end)
gifted.sortedEnemies = gifted.filteredEnemies.sort(function(a, b) return a.hp < b.hp end)

gifted.filteredFriendlies = awful.fgroup.filter(function(friend) return friend.isPlayer and not friend.dead end)
gifted.sortedFriendlies = gifted.filteredFriendlies.sort(function(a, b) return a.hp < b.hp end)
-- ignore --

-- funcs here --
TyrAlert()
PreBuffGates()
HoJAlert()
setFocus()
Lowest()
FreeCast()
gifted.WasCastingCheck()
gifted.CheckHealerLocked()
SearingGlareFace()
-- end funcs here --

if player.mounted then return end

if awful.MacrosQueued["combo"] then
    awful.alert({msg = "Combo Macro Queued", texture = 190784, duration = 1})
    gifted.blessDivineSteed()
end



-- start auras/beacons --
ConcentrationAura()
DevotionAura()
BeaconOfLight("pvp")
BeaconOfFaith("pvp")
-- end auras/beacons --

-- start pre-react bcc/pure --
HandOfReckoning("cc")
HolyBulwark("pre-cc")
BlessingOfSacrifice("cc")
Judgment("pure")
-- end pre-react bcc/pure --

-- start defensives --
AuraMastery("ST-wall")
AuraMastery("spread-wall")

BlessingOfSacrifice("defensive")
BlessingOfSacrifice("health")
BlessingOfSacrifice("attackers")

BlessingOfProtection("feralburst")
BlessingOfProtection("defensive")
BlessingOfProtection("specialplayer")
BlessingOfProtection("specialgroupdefensive")
-- BlessingOfProtection("specialgroupdisarm")

LayOnHands("defensive")
LayOnHands("defensive-no-melee")

AvengingWrath("lowHP")
AvengingWrath("spread")

AvengingCrusader("lowHP")
AvengingCrusader("spread")


-- end defensives --

-- start utilities --
BlessingOfFreedom("friend-root")
BlessingOfFreedom("friend-health")
BlessingOfFreedom("player")
BlessingOfFreedom("player-targeted")
BlessingOfFreedom("player-targeted-burst")
-- end utilities --

-- start personal defensives --
Healthstone()
BMTrink()
DivineShield("lowHP")

DivineProtection("cds")
DivineProtection("health")
DivineProtection("stun")
-- end personal defensives --

-- start kicks --
Rebuke("normal")
Rebuke("healer")
-- end kicks --

-- start awakening --
Judgment("awakeningpvp") -- both talents
-- end awakening --

-- kill --
HammerOfWrath("kill")
-- end kill --

-- get combat judgment --
Judgment("getcombat-lightsmith")
-- end get combat judgment --

-- start tyrs combat --
TyrsDeliverance("freecast-combat")
TyrsDeliverance("los-combat")
-- end tyrs combat --

-- start hammer of justice --
HammerOfJustice("healer-lowhp")
HammerOfJustice("healer")
HammerOfJustice("killtarget")
HammerOfJustice("offdps")
-- end hammer of justice --

-- start searing glare --
SearingGlare("damage")
-- end searing glare --

-- start repentance/blinding light --
Repentance("healer")
BlindingLight("healer-lowhp")
BlindingLight("healer")
-- end repentance/blinding light --

-- start cleanse --
Cleanse("magical")
-- end cleanse

-- start auto attack --
Attack()
-- end auto attack --

-- start healing stuff --

TyrsDeliverance("precombat")
HolyBulwark("pre-combat") -- lightsmith talents only
HandOfDivinity("normal-lightsmith-ooc") -- lightsmith talents only

HolyShock("rising-sunlight") -- both talents
HolyLight("normal-lightsmith") -- lightsmith talents only
HolyLight("HoD-Lightsmith-Remains") -- lightsmith talents only

HolyBulwark("cds")
HolyBulwark("lowest")

SacredWeapon("cds")
SacredWeapon("lowest")

WordOfGlory("divine-purpose") -- lightsmith talents only

HolyShock("get-combat") -- both talents
HolyShock("ooc-fish") 

HandOfDivinity("tyrs") -- herald talents only
HandOfDivinity("heals-notyrs") -- herald talents only
HandOfDivinity("normal-lightsmith") -- lightsmith talents only

WordOfGlory("lowest") -- lightsmith talents only

EternalFlame("divine-purpose")
EternalFlame("spread-dawnlight")
EternalFlame("lowest")
EternalFlame("filler")

BarrierOfFaith("cds")
BarrierOfFaith("lowest")

DivineToll("holypower")
DivineToll("health")

-- start damage crusader buff --
HammerOfWrath("builder-lightsmith-crusader-enemy")
HammerOfWrath("builder-lightsmith-crusader-target")

CrusaderStrike("builder-lightsmith-crusader-enemy")
CrusaderStrike("builder-lightsmith-crusader-target")

Judgment("builder-lightsmith-crusader-enemy")
Judgment("builder-lightsmith-crusader-target")

-- end damage crusader buff --

BlessingOfSpring("pvp")
BlessingOfSummer("pvp")
BlessingOfAutumn("pvp")
BlessingOfWinter("pvp")

Judgment("cds-greater-lightsmith") -- lightsmith talents only
Judgment("cds-greater") -- herald talents only
Consecration("buff")

HolyLight("infusion")
FlashOfLight("infusion")

HolyLight("HoD-tyrs") -- herald talents only
HolyLight("HoD-notyrs-remains") -- herald talents only
HolyLight("HoD-notyrs") -- herald talents only

HolyLight("buffed")
FlashOfLight("buffed")

HolyShock("inf-lightsmith") -- lightsmith talents only
HolyShock("refresh") 
HolyShock("fish") 
HolyShock("filler") 

FlashOfLight("emergency-noprocs")
FlashOfLight("buffednofillers")

CrusaderStrike("filler") -- herald talents only
-- end healing stuff --

-- start stomps --
if gifted.sortedEnemies and gifted.sortedEnemies[1] and gifted.sortedEnemies[1].hp > 50 then
    TotemStomp(CrusaderStrike, Judgment, HammerOfWrath)
end
-- end stomps --


-- start damage stuff --
Denounce("cds")
Denounce("spender")

HammerOfWrath("builder-target") -- herald talents only
HammerOfWrath("builder-lightsmith-enemy") -- lightsmith talents only
HammerOfWrath("builder-lightsmith-target") -- lightsmith talents only

CrusaderStrike("builder-lightsmith-enemy") -- lightsmith talents only
CrusaderStrike("builder-lightsmith-target") -- lightsmith talents only
CrusaderStrike("builder-target") -- herald talents only

Judgment("builder-lightsmith-infusion-enemy") -- lightsmith talents only
Judgment("builder-lightsmith-infusion-target") -- lightsmith talents only

Judgment("builder-lightsmith-building-enemy") -- lightsmith talents only
Judgment("builder-lightsmith-building-target") -- lightsmith talents only


Judgment("builder-infusion") -- herald talents only
Judgment("builder-target") -- herald talents only


CrusaderStrike("builder") -- herald talents only
HammerOfWrath("builder") -- herald talents only

Judgment("filler-infusion") -- both talents
Judgment("filler") -- both talents
-- end damage stuff --

-- start kill stuff --
Denounce("kill")
Judgment("kill")
CrusaderStrike("kill")
--HolyShock("kill")
HolyPrism("kill")
-- end kill stuff --

end, 0.10)
