local Unlocker, awful, project = ...
if awful.player.class2 ~= "PALADIN" then return end
if awful.player.spec ~= "Holy" then return end

awful.enabled = true
awful.AntiAFK.enabled = true
local holy = project.paladin.holy
local target = awful.target
local focus = awful.focus
local player = awful.player
local healer = awful.healer
local pet = awful.pet
local enemyHealer = awful.enemyHealer
local Spell = awful.Spell
local settings = project.settings
local SpellStopCasting = awful.call("SpellStopCasting")
local delay = awful.delay(0.3, 0.5)
local events, colors, colored, escape, bin = awful.events, awful.colors, awful.colored, awful.textureEscape, awful.bin
local alert = awful.alert
awful.unlock("SpellStopCasting")


awful.Populate({
    --buffs--
    beaconOfFaith = Spell(156910, { ignoreMoving = true, ignoreLoS = false, targeted = true }),
    beaconOfLight = Spell(53563, { ignoreMoving = true, ignoreLoS = false, targeted = true }),
    devotionAura = Spell(465, { ignoreMoving = true, targeted = false }),
    concentrationAura = Spell(317920, { ignoreMoving = true, targeted = false }),
    infusionOfLight = Spell(54149),
    glimmerOfLight = Spell(287280),
    blessingOfDawn = Spell(385127),
    blessingOfDusk = Spell(385126),
    divineResonance = Spell(386730),
    spellWarding = Spell(204018),
    risingSunlight = Spell(414204),
    divinePurpose = Spell(223819),
    shadowyDuelDebuff = Spell(207736),
    riteOfAdjuration = Spell(433583),
    riteOfSanctification = Spell(433568),
    sacredWeaponBuff = Spell(432502),
    holyBulwarkBuff = Spell(432496),

    --dam--
    judgement = Spell(275773, { ignoreMoving = true, damage = "magic" }),
    crusaderStrike = Spell(35395, { ignoreMoving = true, damage = "physical"  }),
    hammerOfWrath = Spell(24275, { ignoreMoving = true, damage = "magic", ignoreUsable = false }),
    shieldOfRighteous = Spell(415091, { ignoreMoving = true, damage = "magic" }),

    ---misc---
    handOfReckoning = Spell(62124, { ignoreMoving = true, ignoreGCD = true, ignoreCasting = true }),
    rebuke = Spell(96231, { ignoreMoving = true, effect = "physical", ignoreGCD = true }),
    denounce = Spell(2812, { damage = "magic", castableWhileMoving = false }),
    searingGlare = Spell(410126, { castableWhileMoving = false, targeted = false }),
    blessingOfFreedom = Spell(1044, { ignoreMoving = true }),
    cleanse = Spell(4987, { ignoreMoving = true }),
    improvedCleanse = Spell(393024),
    sigilOfMiseryDebuff = Spell(207685),
    sigilOfMisery = Spell(207684),
    preCog = Spell(377362),
    forbearance = Spell(25771),
    barrierBuff = Spell(395180),
    trinket = Spell(336126),

    ---healing---
    holyShock = Spell(20473, { ignoreMoving = true, damage = "magic", heal = true }),
    flashOfLight = Spell(19750, { heal = true, castableWhileMoving = false }),
    holyLight = Spell(82326, { heal = true }),
    wordOfGlory = Spell(85673, { heal = true, ignoreMoving = true }),
    barrierOfFaith = Spell(148039, { ignoreMoving = true }),
    lightOfDawn = Spell(85222, { ignoreMoving = true, heal = true, targeted = false }),
    divineFavor = Spell(210294, { ignorecasting = true, ignoreGCD = true }),
    holyBulwark = Spell(432459, { ignoreMoving = true }),
    sacredWeapon = Spell({432472, 432459}, { ignoreMoving = true }),


    ----cds----
    tyrsDeliverance = Spell(200652, { beneficial = true, targeted = false }),
    avengingWrath = Spell(31884, { ignoreMoving = true, ignoreGCD = true, targeted = false }),
    handOfDivinity = Spell(414273, { ignoreMoving = false }),
    divineToll = Spell(375576, { ignoreMoving = true, targeted = false }),
    layOnHands = Spell(633, { ignoreMoving = true, heal = true, ignoreGCD = true, ignoreCasting = true }),
    blessingOfSpring = Spell(388013, { ignoreMoving = true, targeted = true, castByID = true, ignoreGCD = true }),
    blessingOfSummer = Spell(388007, { ignoreMoving = true, targeted = true, castByID = true, ignoreGCD = true }),
    blessingOfAutumn = Spell(388010, { ignoreMoving = true, targeted = true, castByID = true, ignoreGCD = true }),
    blessingOfWinter = Spell(388011, { ignoreMoving = true, targeted = false, castByID = true, ignoreGCD = true }),

    ---def cds---
    divineShield = Spell(642, { ignoreMoving = true, ignoreCasting = true, ignoreControl = true }),
    blessingOfSacrifice = Spell(6940, { ignoreMoving = true, ignoreGCD = true, ignoreCasting = true }),
    blessingOfProtection = Spell(1022, { ignoreMoving = true, ignoreStuns = true, ignoreCasting = true }),
    auraMastery = Spell(31821, { ignoreMoving = true, targeted = false }),
    divineProtection = Spell(498, { ignoreMoving = true, ignoreGCD = true, ignoreControl = true, targeted = false }),

    ---cc---
    repentance = Spell(20066, { cc = "incapacitate", castableWhileMoving = false }),
    hammerOfJustice = Spell(853, { ignoreMoving = true, cc = "stun", effect = "magic", ignoreCasting = true }),
    blindingLight = Spell(115750, {ignoreMoving = true, cc = "disorient", effect = "magic", ignoreCasting = true })


}, holy, getfenv(1))

awful.powerTypes = {
	["mana"] = 0,
	["rage"] = 1,
	["focus"] = 2,
	["energy"] = 3,
	["combopoints"] = 4,
	["cp"] = 4,
	["runes"] = 5,
	["runicpower"] = 6,
	["soulshards"] = 7,
	["shards"] = 7,
	["astralpower"] = 8,
	["ap"] = 8,
	["lunarpower"] = 8,
	["holypower"] = 9,
	["alternatepower"] = 10,
	["maelstrom"] = 11,
	["chi"] = 12,
	["insanity"] = 13,
	["arcanecharges"] = 16,
	["fury"] = 17,
	["pain"] = 18,
    ["essence"] = 19
}

local BurstCDS = {
    -- Death Knight
    [383269] = { uptime = 0.2, min = 2 }, -- Abomination Limb
    [207289] = { uptime = 0.2, min = 2 }, -- Unholy Assault
 
    -- Demon Hunter
    [255647] = { uptime = 0.2, min = 2 }, -- The Hunt
    [191427] = { uptime = 0.2, min = 2 }, -- MetaMorphisis
 
    -- Druid
    [274837] = { uptime = 0.2, min = 2 }, -- Feral Frenzy 
    [102543] = { uptime = 0.2, min = 2 }, -- Incarnation: Avatar of Ashamane
    [102560] = { uptime = 0.2, min = 2 }, -- Incarnation: Chosen of Elune
    [390414] = { uptime = 0.2, min = 2 }, -- Incarnation: Guardian of Ursoc
    [194223] = { uptime = 0.2, min = 2 }, -- Celestial Alignment
    [391528] = { uptime = 0.2, min = 2 }, -- Convoke the Spirits
 
    -- Evoker
    [375087] = { uptime = 0.2, min = 2 }, -- Dragonrage
    [406227] = { uptime = 0.2, min = 2 }, -- Deep Breath
    [403631] = { uptime = 0.2, min = 2 }, -- Breath of Eons
 
    -- Hunter
    [360952] = { uptime = 0.2, min = 2 }, -- Coordinated Assault
    [359844] = { uptime = 0.2, min = 2 }, -- Call of the Wild
    [19574] = { uptime = 0.2, min = 2 },  -- Bestial Wrath
    [288613] = { uptime = 0.2, min = 2 }, -- Trueshot
 
    -- Mage
    [190319] = { uptime = 0.2, min = 2 }, -- Combustion
    [12472] = { uptime = 0.2, min = 2 },  -- Icy Veins
    [365350] = { uptime = 0.2, min = 2 }, -- Arcane Surge
 
    -- Monk
    [137639] = { uptime = 0.2, min = 2 }, -- Storm, Earth, and Fire
    [123904] = { uptime = 0.2, min = 2 }, -- Invoke Xuen
 
    -- Paladin
    [31884] = { uptime = 0.2, min = 2 },  -- Avenging Wrath: Might
 
    -- Priest
    [194249] = { uptime = 0.2, min = 2 }, -- Voidform
    [280711] = { uptime = 0.2, min = 2 }, -- Dark Ascension
    [228260] = { uptime = 0.2, min = 2 }, -- Void Eruption
 
    -- Rogue
    [121471] = { uptime = 0.2, min = 2 }, -- Shadow Blades
    [185313] = { uptime = 0.2, min = 2 }, -- Shadow Dance
    [360194] = { uptime = 0.2, min = 2 }, -- Deathmark
    [13750] = { uptime = 0.2, min = 2 }, -- Adrenaline Rush
 
    -- Shaman
    [384352] = { uptime = 0.2, min = 2 }, -- Doom Winds
    [204361] = { uptime = 0.2, min = 2 }, -- Bloodlust
    [114051] = { uptime = 0.2, min = 2 }, -- Ascendance
    [114050] = { uptime = 0.2, min = 2 }, -- Ascendance
 
    -- Warlock
    [1122] = { uptime = 0.2, min = 2 },   -- Infernal
    [205179] = { uptime = 0.2, min = 2 }, -- Phantom Singularity
    [265187] = { uptime = 0.2, min = 2 }, -- Summon Demonic Tyrant
    [386997] = { uptime = 0.2, min = 2 }, -- SoulRot
    [205180] = { uptime = 0.2, min = 2 }, -- Dark Glare
 
    -- Warrior
    [376079] = { uptime = 0.2, min = 2 }, -- Spear of Bastion
    [107574] = { uptime = 0.2, min = 2 }, -- Avatar
    [262161] = { uptime = 0.2, min = 2 }, -- Warbreaker
    [1719] = { uptime = 0.2, min = 2 },   -- Recklessness
 }

 local BurstCDS2 = {
    -- Death Knight
    383269, -- Abomination Limb
    207289, -- Unholy Assault

    -- Demon Hunter
    255647, -- The Hunt
    191427, -- MetaMorphisis

    -- Druid
    274837, -- Feral Frenzy
    102543, -- Incarnation: Avatar of Ashamane
    102560, -- Incarnation: Chosen of Elune
    390414, -- Incarnation: Guardian of Ursoc
    194223, -- Celestial Alignment
    391528, -- Convoke the Spirits

    -- Evoker
    375087, -- Dragonrage
    406227, -- Deep Breath
    403631, -- Breath of Eons

    -- Hunter
    360952, -- Coordinated Assault
    359844, -- Call of the Wild
    19574,  -- Bestial Wrath
    288613, -- Trueshot

    -- Mage
    190319, -- Combustion
    12472,  -- Icy Veins
    365350, -- Arcane Surge

    -- Monk
    137639, -- Storm, Earth, and Fire
    123904, -- Invoke Xuen

    -- Paladin
    31884,  -- Avenging Wrath: Might

    -- Priest
    194249, -- Voidform
    280711, -- Dark Ascension
    228260, -- Void Eruption

    -- Rogue
    121471, -- Shadow Blades
    185313, -- Shadow Dance
    360194, -- Deathmark
    13750,  -- Adrenaline Rush

    -- Shaman
    384352, -- Doom Winds
    204361, -- Bloodlust
    114051, -- Ascendance
    114050, -- Ascendance

    -- Warlock
    1122,   -- Infernal
    205179, -- Phantom Singularity
    265187, -- Summon Demonic Tyrant
    386997, -- SoulRot
    205180, -- Dark Glare

    -- Warrior
    376079, -- Spear of Bastion
    107574, -- Avatar
    262161, -- Warbreaker
    1719,   -- Recklessness
}


local bopCDS = {
    [360194] = true, -- Deathmark
    [274837] = true, -- Feral Frenzy
    [122470] = true, -- karma
    [408] = true, -- kidney shot
}

local sacTable = {
    [51514] = function() return player.idr >= 0.5 end,   -- Hex
    [210873] = function() return player.idr >= 0.5 end, -- Hex
    [211004] = function() return player.idr >= 0.5 end, -- Hex
    [211010] = function() return player.idr >= 0.5 end, -- Hex
    [211015] = function() return player.idr >= 0.5 end, -- Hex
    [269352] = function() return player.idr >= 0.5 end, -- Hex
    [277778] = function() return player.idr >= 0.5 end, -- Hex
    [277784] = function() return player.idr >= 0.5 end, -- Hex
    [309328] = function() return player.idr >= 0.5 end, -- Hex
    [118] = function() return player.idr >= 0.5 end,    -- Polymorph
    [61780] = function() return player.idr >= 0.5 end, -- Polymorph
    [126819] = function() return player.idr >= 0.5 end, -- Polymorph
    [161353] = function() return player.idr >= 0.5 end, -- Polymorph
    [161354] = function() return player.idr >= 0.5 end, -- Polymorph
    [161355] = function() return player.idr >= 0.5 end, -- Polymorph
    [28271] = function() return player.idr >= 0.5 end, -- Polymorph
    [28272] = function() return player.idr >= 0.5 end, -- Polymorph
    [61305] = function() return player.idr >= 0.5 end, -- Polymorph
    [61721] = function() return player.idr >= 0.5 end, -- Polymorph
    [161372] = function() return player.idr >= 0.5 end, -- Polymorph
    [277787] = function() return player.idr >= 0.5 end, -- Polymorph
    [277792] = function() return player.idr >= 0.5 end, -- Polymorph
    [321395] = function() return player.idr >= 0.5 end, -- Polymorph
    [391622] = function() return player.idr >= 0.5 end, -- Polymorph
    [198909] = function() return player.ddr >= 0.5 end, -- Song of Chi-ji
    [118699] = function() return player.ddr >= 0.5 end, -- Fear
    [5782] = function() return player.ddr >= 0.5 end,   -- Fear
    [360806] = function() return player.ddr >= 0.5 end, -- Sleep Walk
    [20066] = function() return player.idr >= 0.5 end,  -- Repentance
}

setmetatable(sacTable, {
    __index = function(tbl, spellID)
        local func = rawget(tbl, spellID)
        if func and type(func) == "function" then
            return func()
        else
            return false
        end
    end
})

local cleanseTable = {
    [51514] = { uptime = 0.2, min = 2 },   -- Hex
    [210873] = { uptime = 0.2, min = 2 }, -- Hex
    [211004] = { uptime = 0.2, min = 2 }, -- Hex
    [211010] = { uptime = 0.2, min = 2 }, -- Hex
    [211015] = { uptime = 0.2, min = 2 }, -- Hex
    [269352] = { uptime = 0.2, min = 2 }, -- Hex
    [277778] = { uptime = 0.2, min = 2 }, -- Hex
    [277784] = { uptime = 0.2, min = 2 }, -- Hex
    [309328] = { uptime = 0.2, min = 2 }, -- Hex
    [118] = { uptime = 0.2, min = 2 },    -- Polymorph
    [61780] = { uptime = 0.2, min = 2 }, -- Polymorph
    [126819] = { uptime = 0.2, min = 2 }, -- Polymorph
    [161353] = { uptime = 0.2, min = 2 }, -- Polymorph
    [161354] = { uptime = 0.2, min = 2 }, -- Polymorph
    [161355] = { uptime = 0.2, min = 2 }, -- Polymorph
    [28271] = { uptime = 0.2, min = 2 }, -- Polymorph
    [28272] = { uptime = 0.2, min = 2 }, -- Polymorph
    [61305] = { uptime = 0.2, min = 2 }, -- Polymorph
    [61721] = { uptime = 0.2, min = 2 }, -- Polymorph
    [161372] = { uptime = 0.2, min = 2 }, -- Polymorph
    [277787] = { uptime = 0.2, min = 2 }, -- Polymorph
    [277792] = { uptime = 0.2, min = 2 }, -- Polymorph
    [321395] = { uptime = 0.2, min = 2 }, -- Polymorph
    [391622] = { uptime = 0.2, min = 2 }, -- Polymorph
    [390612] = { uptime = 0.2, min = 2 }, -- Frost Bomb
    [198909] = { uptime = 0.2, min = 2 }, -- Song of Chi-ji
    [64695] = { uptime = 0.2, min = 2 },  -- EarthGrab
    [102359] = { uptime = 0.2, min = 2 }, -- Mass Entanglement
    [339] = { uptime = 0.2, min = 2 },   -- Entangling Roots
    [393456] = { uptime = 0.2, min = 2 }, -- Entrapment
    [385408] = { uptime = 0.2, min = 2 }, -- Sepsis
    [375901] = { uptime = 0.2, min = 2 }, -- Mind Games
    [217832] = { uptime = 0.2, min = 2 }, -- Imprison
    [355689] = { uptime = 0.2, min = 2 }, -- Landslide
    [118699] = { uptime = 0.2, min = 2 }, -- Fear
    [5782] = { uptime = 0.2, min = 2 },   -- Fear
    [386997] = { uptime = 0.2, min = 2 }, -- Soul Rot
    [383005] = { uptime = 0.2, min = 2 }, -- Chrono Loop
    [411038] = { uptime = 0.2, min = 2 }, -- Sphere of Despair
    [8122] = { uptime = 0.2, min = 2 },   -- Psychic Scream
    [853] = { uptime = 0.2, min = 2 },    -- Hammer of Justice
    [6789] = { uptime = 0.2, min = 2 },   -- Mortal Coil
    [3355] = { uptime = 0.2, min = 2 },   -- Freezing Trap
    [10326] = { uptime = 0.2, min = 2 },  -- Turn Evil
    [105421] = { uptime = 0.2, min = 2 }, -- Blinding Light
    [6358] = { uptime = 0.2, min = 2 },   -- Seduction
    [64044] = { uptime = 0.2, min = 2 },  -- Psychic Horror
    [360806] = { uptime = 0.2, min = 2 }, -- Sleep Walk
    [212638] = { uptime = 0.2, min = 2 }, -- Tracker's Net
    [82691] = { uptime = 0.2, min = 2 },  -- Ring of Frost
    [5484] = { uptime = 0.2, min = 2 },   -- Howl of Terror
    [20066] = { uptime = 0.2, min = 2 },  -- Repentance
    [226943] = { uptime = 0.2, min = 2 }, -- Mind Bomb
    [205369] = { uptime = 0.2, min = 2 }, -- Mind Bomb
    [122] = { uptime = 0.2, min = 2 },    -- Frost Nova
    --[356528] = { uptime = 0.2, min = 2, debuffStacks = 6 }, -- Necrotic Wound
    [2812] = { uptime = 0.2, min = 2 },   -- Denounce
    [30283] = { uptime = 0.2, min = 2 },  -- Shadow Fury
    [179057] = { uptime = 0.2, min = 2 }, -- Chaos Nova
    [356738] = { uptime = 0.2, min = 2 }, -- Earth Unleashed
    [285515] = { uptime = 0.2, min = 2 }, -- Surge of Power
    [127797] = { uptime = 0.2, min = 2 }, -- Freeze
    [228600] = { uptime = 0.2, min = 2 }, -- Ice Nova
    [47476] = { uptime = 0.2, min = 2 },  -- Strangulate
    --[410065] = { uptime = 0.2, min = 2 }, -- Reactive Resin
    [197214] = { uptime = 0.2, min = 2 }, -- Hibernate
    [710] = { uptime = 0.2, min = 2 },    -- Banish
    [31661] = { uptime = 0.2, min = 2 },  -- Dragon's Breath
    [1513] = { uptime = 0.2, min = 2 },   -- Scare Beast
}

local curseTable = {
    [51514] = { uptime = 0.3, min = 2 },   -- Hex
    [210873] = { uptime = 0.3, min = 2 }, -- Hex
    [211004] = { uptime = 0.3, min = 2 }, -- Hex
    [211010] = { uptime = 0.3, min = 2 }, -- Hex
    [211015] = { uptime = 0.3, min = 2 }, -- Hex
    [269352] = { uptime = 0.3, min = 2 }, -- Hex
    [277778] = { uptime = 0.3, min = 2 }, -- Hex
    [277784] = { uptime = 0.3, min = 2 }, -- Hex
    [309328] = { uptime = 0.3, min = 2 }, -- Hex
    [385408] = { uptime = 0.3, min = 2 }, -- Sepsis
    --[334275] = { uptime = 0.3, min = 2 }, -- Curse of Exhaustion
    --[1714] = { uptime = 0.3, min = 2 }, -- Curse of Tongues
    --[702] = { uptime = 0.3, min = 2 }, -- Curse of Weakness
    [199954] = { uptime = 0.3, min = 2 }, -- Bane of Fragility
    [234877] = { uptime = 0.3, min = 2 }, -- Bane of Shadows
    [8679] = { uptime = 0.3, min = 2 }, -- Wound Poison
}

local purgeTable = {
    [342246] = { uptime = 0.3, min = 2 }, -- Alter Time
    [31821] = { uptime = 0.3, min = 2 }, -- Aura Mastery
    [305497] = { uptime = 0.3, min = 2 }, -- Thorns
    [114108] = { uptime = 0.3, min = 2 }, -- Soul of the Forest
    [132158] = { uptime = 0.3, min = 2 }, -- Nature's Swiftness
    [378464] = { uptime = 0.3, min = 2 }, -- Nullifying Shroud
    [605] = { uptime = 0.3, min = 2 }, -- Mind Control
    [29166] = { uptime = 0.3, min = 2 }, -- Innervate
    [269279] = { uptime = 0.3, min = 2 }, -- Tip the Scales
    [10060] = { uptime = 0.3, min = 2 }, -- Power Infusion
    [2825] = { uptime = 0.3, min = 2 }, -- Bloodlust
    [204018] = { uptime = 0.3, min = 2 }, -- Blessing of SpellWarding
    [1022] = { uptime = 0.3, min = 2 }, -- Blessing of Protection
    [213610] = { uptime = 0.3, min = 2 }  -- Holy Ward  
}

local defensiveTable = {
    -- Death Knight
    [48707] = { uptime = 0.2, min = 2 },  -- Anti Magic Shell
    [51052] = { uptime = 0.2, min = 2 },  -- Anti Magic Zone
    [48792] = { uptime = 0.2, min = 2 }, -- Icebound Fortitude
    -- Demon Hunter
    [212800] = { uptime = 0.2, min = 2 }, -- Blur
    [196718] = { uptime = 0.2, min = 2 }, -- Darkness
    [196555] = { uptime = 0.2, min = 2 }, -- NetherWalk
    -- Druid
    [22812] = { uptime = 0.2, min = 2 },  -- Barkskin
    -- Hunter
    [186265] = { uptime = 0.2, min = 2 }, -- Turtle
    -- Mage
    [45438] = { uptime = 0.2, min = 2 },  -- Ice Block
    [414660] = { uptime = 0.2, min = 2 }, -- Mass Barrier
    [342245] = { uptime = 0.2, min = 2 }, -- Alter Time
    [11426] = { uptime = 0.2, min = 2 }, -- Ice Barrier
    -- Monk
    [122470] = { uptime = 0.2, min = 2 }, -- Touch of Karma
    [115203] = { uptime = 0.2, min = 2 }, -- Fortified Brew
    [122278] = { uptime = 0.2, min = 2 }, -- Dampen Harm
    [122783] = { uptime = 0.2, min = 2 }, -- Diffuse Magic
    -- Paladin
    [642] = { uptime = 0.2, min = 2 },    -- Divine Shield
    [31821] = { uptime = 0.2, min = 2 }, -- Aura Mastery
    [6940] = { uptime = 0.2, min = 2 }, -- Blessing of Sacrifice
    [184662] = { uptime = 0.2, min = 2 }, -- Shield of Vengeance
    [403876] = { uptime = 0.2, min = 2 }, -- Diviine Protection
    [498] = { uptime = 0.2, min = 2 }, -- Divine Protection
    -- Priest
    [47585] = { uptime = 0.2, min = 2 },  -- Dispersion
    [19236] = { uptime = 0.2, min = 2 },  -- Desperate Prayer
    [33206] = { uptime = 0.2, min = 2 },  -- Pain Suppression
    [62618] = { uptime = 0.2, min = 2 },  -- Power Word Barrier
    -- Rogue
    [5277] = { uptime = 0.2, min = 2 },   -- Evasion
    [31224] = { uptime = 0.2, min = 2 },  -- Cloak of Shadows
    -- Shaman
    [108271] = { uptime = 0.2, min = 2 }, -- Astral Shift
    [409293] = { uptime = 0.2, min = 2 }, -- Burrow
    -- Warlock
    [104773] = { uptime = 0.2, min = 2 }, -- Unending Resolve
    [108416] = { uptime = 0.2, min = 2 }, -- Dark Pact
    -- Warrior
    [118038] = { uptime = 0.2, min = 2 }, -- Die by the Sword
    [97462] = { uptime = 0.2, min = 2 },  -- Rallying Cry
    [184364] = { uptime = 0.2, min = 2 }, -- Enraged Regeneration
    -- Evoker
    [363916] = { uptime = 0.2, min = 2 }  -- Obsidian Scales
 }

local immuneTable = {
    [196555] = true,  -- NetherWalk
    [45438] = true,   -- Ice Block
    [409293] = true, -- Burrow
    [642] = true,     -- Divine Shield
    [186265] = true,  -- Turtle
    [362486] = true, -- Tranquility PVP Talent
    [31224] = true, -- Cloak of shadows
    [47585] = true   -- Dispersion
}

local cantCC = {
    [48707] = true, -- Anti Magic Shell
    [6940] = true, -- Blessing of Sacrifice
    [196555] = true,  -- NetherWalk
    [45438] = true,   -- Ice Block
    [409293] = true, -- Burrow
    [210256] = true, -- Sanc
    [642] = true,     -- Divine Shield
    [186265] = true,  -- Turtle
    [362486] = true, -- Tranquility PVP Talent
    [31224] = true, -- Cloak of shadows
    [47585] = true,   -- Dispersion
    [408558] = true, -- Phase Shift
    [23920] = true, --spell reflect
    [1022] = true, -- Blessing of Protection
    [378464] = true, -- Nullifying Shroud
    [227847] = true, -- Bladestorm
    [8178] = true, -- Grounding Totem
    [213610] = true,  -- Holy Ward
    [377362] = true, -- Precognition
    [215769] = true, -- Spirit Of Redemption
    [421453] = true -- Ultimate Penitence
}

local function isLocked(unit)
    if unit.lockouts.nature then return true end
    if unit.lockouts.holy then return true end
    if unit.lockouts.fire then return true end
    if unit.lockouts.frost then return true end
    if unit.lockouts.arcane then return true end
    if unit.lockouts.shadow then return true end
    return false
end

local function autoFocus()
    if project.settingsafocus then awful.AutoFocus() end
end

if project.settingsafocus then
    awful.addUpdateCallback(autoFocus)
end

function project.QueueAlertAndAccept()
    if project.settings.autoaccept then
        local battlefieldStatus = GetBattlefieldStatus(1)
        if battlefieldStatus == "confirm" then
            awful.call("AcceptBattlefieldPort", 1, true)
        end
    end
end

if project.settings.autoaccept then
    awful.addUpdateCallback(project.QueueAlertAndAccept)
end

function project.grabFlag()
    if not project.settings.grabFlag then return end
    local flag = awful.objects.find(function(obj) return obj.id == 227741 or obj.id == 227740 or obj.id == 227745 end)
    if select(2, IsInInstance()) == "pvp" then
        if flag then
            local distance = flag.distance
            if distance <= 10 then
                if Unlocker.type == "daemonic" then
                    return Interact(flag.pointer)
                else
                    return RightClickObject(flag.pointer)
                end
            end
        end
    end
end

awful.addEventCallback(function(eventinfo, event, source, dest)
    local spellID = select(12, unpack(eventinfo))
    if not player.hasTalent(blessingOfSacrifice.id) then return end
    if blessingOfSacrifice.cd > 0 then return end
    if not project.isInValidInstance() then return end
    if (event ~= "UNIT_SPELLCAST_START" or event ~= "SPELL_CAST_SUCCESS") then return end
    if source == nil then return end
    if not source.enemy then return end
    if spellID == 187650 or spellID == 203340 then
        if project.cd(blessingOfSacrifice) > 0 then return end
        if not player.facing(project.LowestUnit) then return end
        return blessingOfSacrifice:Cast(project.LowestUnit) and
            alert("Blessing of Sacrifice | " .. colors.red .. "Trap", blessingOfSacrifice.id, true)
    end
end)

awful.addEventCallback(function(eventinfo, event, source, dest)
    local spellID = select(12, unpack(eventinfo))
    if not player.hasTalent(blessingOfProtection.id) then return end
    if not project.isInValidInstance() then return end
    if event ~= "SPELL_CAST_SUCCESS" then return end
    if source == nil then return end
    if not source.enemy then return end
    if spellID == 370965 then
        if project.cd(blessingOfProtection) > 0 then return end
        if not player.facing(project.LowestUnit) then return end
        if project.LowestUnit.debuff(forbearance.id) then return end
        --if project.LowestUnit.class2 == "PALADIN" and project.LowestUnit.cd(divineShield.id) < 2 then return end
        if not source.target.los then return end
        return blessingOfProtection:Cast(source.target) and
            alert("Blessing of Protection | " .. colors.red .. "The Hunt", blessingOfProtection.id, true)
    end
end)

local MissileCCs = {
    [187650] = true, -- Freezing Trap
}

local MissileCCs2 = {
    [203340] = true, -- Diamond Ice Trap
}

awful.addUpdateCallback(function()
    local aids = false
    if not project.isInValidInstance() then return end
    if not player.hasTalent(blessingOfSacrifice.id) then return end
    awful.missiles.track(function(missile)
        local id = missile.spellId
        local aoe = MissileCCs[id]
        local aoe2 = MissileCCs2[id]
        local missilecreator = awful.GetObjectWithGUID(missile.source)
        if missile.source == nil then return end
        if missilecreator.friend then return end
        if missile.source.friendly then return end
        if missile.source.friend then return end

        if not id then return end
        if not aoe or aoe2 then return end
        if project.cd(blessingOfSacrifice) > 0 then return end
        if not project.LowestUnit.los then return end
        if project.LowestUnit.distance > 40 then return end
        if not player.facing(project.LowestUnit) then return end
        aids = true
    end)
    if not aids then return end
    return blessingOfSacrifice:Cast(project.LowestUnit) and
    alert("Blessing of Sacrifice | " .. colors.red .. "Trap", blessingOfSacrifice.id, true)
end)

local wasCasting = {}
function project.WasCastingCheck()
    local time = awful.time
    if player.casting then
        wasCasting[player.castID] = time
    end
    for spell, when in pairs(wasCasting) do
        if time - when > 0.100 + awful.buffer then
            wasCasting[spell] = nil
        end
    end
end

local function Dampening()
    local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, damp = player.debuff(110310)
    if damp then
        return damp
    else
        return 0
    end
end

local function hasCleanse()
    -- Druid: Nature's Cure
    if enemyHealer.exists and enemyHealer.class2 == "DRUID" and enemyHealer.cd(88423) < awful.gcd then
        return true
        -- Paladin: Cleanse
    elseif enemyHealer.exists and enemyHealer.class2 == "PALADIN" and enemyHealer.cooldown(4987) < awful.gcd then
        return true
        -- Priest: Purify
    elseif enemyHealer.exists and enemyHealer.class2 == "PRIEST" and enemyHealer.cooldown(527) < awful.gcd then
        return true
        -- Monk: Detox
    elseif enemyHealer.exists and enemyHealer.class2 == "MONK" and enemyHealer.cooldown(115450) < awful.gcd then
        return true
        -- Shaman: Cleanse Spirit
    elseif enemyHealer.exists and enemyHealer.class2 == "SHAMAN" and enemyHealer.cooldown(51886) < awful.gcd then
        return true
        -- Evoker: Not sure of the spell name, assuming ID is correct
    elseif enemyHealer.exists and enemyHealer.class2 == "EVOKER" and enemyHealer.cooldown(360823) < awful.gcd then
        return true
    end

    return false
end

function project.cd(spellObject)
    local gcd = 0
    if spellObject.gcd > 0 then
        gcd = awful.gcdRemains
    end
    return spellObject.cooldown - gcd
end

function project.getLosTraceLine(unit1, unit2)
    if not unit1.exists then
        return false
    end

    if not unit2.exists then
        return false
    end

    local x, y, z = unit1.position()
    local tx, ty, tz = unit2.position()

    return awful.TraceLine(x, y, z + 1.5, tx, ty, tz + 1.5, 0x100111) == 0
end

function project.hasLosBehindIceWall(unit1, unit2)
    if not unit1.exists then
        return false
    end

    if not unit2.exists then
        return false
    end

    return project.getLosTraceLine(unit1, unit2)
end

function project.Lowest()
    local playerInDuel = player.debuff(shadowyDuelDebuff.id)
    project.LowestHealth = 100
    project.LowestUnit = player
    project.LowestPetHealth = 100
    project.LowestPetUnit = player
    project.SecondLowestHealth = 100
    project.SecondLowestUnit = player
    project.LowestActualHealth = 9000000
    project.LowestActualUnit = nil
    local badDebuff = { 33786, 207736, 203337, 221527, 207736 }
    local badBuff = { 342245, 215769 }

    project.AoELowestHealth = 100
    project.AoELowestUnit = player

    awful.fullGroup.loop(function(unit, i, uptime)
        if unit.dead or unit.charmed or unit.immuneHealing then return end

        if not unit.los or not project.hasLosBehindIceWall(player, unit) then
            return
        end

        -- Check distance
    
        if unit.distance > 40 then return end

        -- Update AoE lowest health information
        if unit.hp < project.AoELowestHealth then
            project.AoELowestHealth = unit.hpa
            project.AoELowestUnit = unit
        end

        if playerInDuel then
            if not unit.isUnit(player) then return end
        else
            if unit.debuff(shadowyDuelDebuff.id) then return end
        end

        if unit.hp < project.LowestHealth then
            project.SecondLowestHealth = project.LowestHealth
            project.SecondLowestUnit = project.LowestUnit
            project.LowestHealth = unit.hpa
            project.LowestUnit = unit
        elseif unit.hp < project.SecondLowestHealth then
            project.SecondLowestHealth = unit.hpa
            project.SecondLowestUnit = unit
        end

        if not unit.isUnit(player) and unit.health < project.LowestActualHealth then
            project.LowestActualHealth = unit.health
            project.LowestActualUnit = unit
        end
    end)
end

function project.LowestEnemy()
    project.LowestHealthEnemy = 100
    project.LowestEnemyUnit = nil
    project.LowestEnemyPetHealth = 100
    project.LowestEnemyPetUnit = nil
    project.SecondLowestHealthEnemy = 100
    project.SecondLowestEnemyUnit = nil
    project.LowestActualHealthEnemy = 9000000
    project.LowestActualEnemyUnit = nil
    project.BurstingEnemy = nil
    project.enemyBursting = false
    awful.enemies.loop(function(unit, i, uptime)
        if not unit.dead then
            if unit.distance <= 40 then
                if unit.los and unit.enemy and not unit.pet then
                    if unit.hp < project.LowestHealthEnemy then
                        project.SecondLowestHealthEnemy = project.LowestHealthEnemy
                        project.SecondLowestEnemyUnit = project.LowestEnemyUnit
                        project.LowestHealthEnemy = unit.hp
                        project.LowestEnemyUnit = unit
                    end
                    if unit.hp > project.LowestHealthEnemy and unit.hp < project.SecondLowestHealthEnemy then
                        project.SecondLowestHealthEnemy = unit.hp
                        project.SecondLowestEnemyUnit = unit
                    end
                    if unit.health < project.LowestActualHealthEnemy then
                        project.LowestActualHealthEnemy = unit.health
                        project.LowestActualEnemyUnit = unit
                    end
                    if unit.cds or unit.used(BurstCDS, 3) or unit.buffFrom(BurstCDS2) then
                        project.BurstingEnemy = unit
                        project.enemyBursting = true
                    end
                end
            end
        end
    end)
end

awful.addActualUpdateCallback(function()
project.Lowest()
project.LowestEnemy()
end)

function project.usemedallion()
    if project.medallion:Usable() and player.hp < project.settings.md and project.medallion.cd < 1 then
        if project.medallion.equipped then
            project.medallion:Use()
        end
    end
    if project.medallion2:Usable() and player.hp < project.settings.md and project.medallion2.cd < 1 then
        if project.medallion2.equipped then
            project.medallion2:Use()
        end
    end
end

project.hasAttemptedCollection = false

function project.collectHealthstone()
    if project.healthStone.count >= 1 or project.hasAttemptedCollection then return end

    local soulwell = awful.objects.within(5)
        .find(function(obj) 
            return obj.id == 303148 and obj.creator.friend 
        end)

    if not soulwell then return end

    project.hasAttemptedCollection = true

    if Unlocker.type == "daemonic" then
        Interact(soulwell.pointer)
    else
        ObjectInteract(soulwell.pointer)
    end
end

function project.usehealthStone()
    if project.healthStone:Usable() and player.hp < project.settings.hst and project.healthStone.count >= 1 and project.healthStone.cd < 1 then
        project.healthStone:Use()
    end
end

function project.stompTotems()
    if project.LowestHealth <= 60 then return end
    awful.totems.stomp(function(totem, uptime)
        if project.settings.stompsHigh[totem.id] then
            if uptime < 0.3 then return end
            if not totem.los then return end
            if totem.dist >= 30 then return end
            if not player.facing(totem) then return end
            judgement:Cast(totem)
            if totem.dist <= 8 and project.cd(crusaderStrike) <= 0 then crusaderStrike:Cast(totem) end
        end


        if project.settings.stomps[totem.id] then
            if uptime < 0.3 then return end
            if not totem.los then return end
            if totem.dist >= 30 then return end
            if not player.facing(totem) then return end
            judgement:Cast(totem)
            if totem.dist <= 8 and project.cd(crusaderStrike) <= 0 then crusaderStrike:Cast(totem) end
        end
    end)
end

local rangedClasses = {
    ["MAGE"] = true,
    ["WARLOCK"] = true,
    ["PRIEST"] = true,
    ["EVOKER"] = true,
    ["SHAMAN"] = true,
    ["DRUID"] = true,
}

riteOfSanctification:Callback(function(spell)
    if player.combat then return end
    if not IsPlayerSpell(432459) then return end
    if IsPlayerSpell(433583) then return end
    if not player.buff(433550) or player.buff(433550) and player.buffRemains(433550) < 600 then
        if spell:Cast() then
            UseInventoryItem(16)
            return awful.alert("Applying Rite of Sanctification", spell.id)
        end
    end
end)

riteOfAdjuration:Callback(function(spell)
    if player.combat then return end
    if not IsPlayerSpell(432459) then return end
    if IsPlayerSpell(433568) then return end
    if not player.buff(433550) or player.buff(433550) and player.buffRemains(433550) < 600 then
        if spell:Cast() then
            UseInventoryItem(16)
            return awful.alert("Applying Rite of Adjuration", spell.id)
        end
    end
end)

sacredWeapon:Callback(function(spell)
    if not IsPlayerSpell(432459) then return end
    if project.cd(holyBulwark) > 0 then return end
    if holyBulwark.charges < 1 then return end
    if player.buff(sacredWeaponBuff.id) then return end
    if player.buff(holyBulwarkBuff.id) then return end
    if not player.combat then return end
    if project.LowestHealth > 40 then return end
    if project.LowestUnit.dist > 40 then return end
    return spell:Cast(project.LowestUnit)
end)

beaconOfLight:Callback(function(spell)
    local foundRanged = false
    if project.cd(spell) > 0 then return end
    awful.fgroup.within(60).loop(function(friend)
        if not friend then return end

        if not friend.buff(beaconOfLight.id, player) and not friend.healer then
            if rangedClasses[friend.class2] then
                if not friend.los then return end
                spell:Cast(friend)
                foundRanged = true
                return true
            end
        end

        if not foundRanged and not friend.buff(beaconOfLight.id, player) and not friend.healer then
            if not friend.los then return end
            spell:Cast(friend)
            return true
        end

        if friend.buff(beaconOfLight.id, player) then
            return true
        end
    end)
end)


beaconOfFaith:Callback(function(spell)
    if project.cd(spell) > 0 then return end
    awful.fgroup.within(60).loop(function(friend)
        if not friend then return end

        if not friend.buff(beaconOfFaith.id) and not friend.buff(beaconOfLight.id) and not friend.healer then
            if not friend.los then return end
            spell:Cast(friend)
            return true
        end

        if not friend.buff(beaconOfFaith.id) and not friend.buff(beaconOfLight.id) and friend.healer then
            if not friend.los then return end
            spell:Cast(friend)
            return true
        end

        if friend.buff(beaconOfFaith.id) then
            return true
        end
    end)
end)

function project.beacon()
    -- Track who has beacons currently
    local lightTarget, faithTarget = nil, nil
    awful.fgroup.loop(function(friend)
        if friend.buff(beaconOfLight.id) then
            lightTarget = friend
        elseif friend.buff(beaconOfFaith.id) then
            faithTarget = friend
        end
    end)

    -- Initial beacon placement if none exist
    if not lightTarget or not faithTarget then
        awful.fgroup.loop(function(friend)
            if not friend.isUnit(player) and not friend.healer then
                if not lightTarget and friend.los then
                    beaconOfLight:Cast(friend)
                elseif not faithTarget and not friend.buff(beaconOfLight.id) and friend.los then
                    beaconOfFaith:Cast(friend)
                end
            end
        end)
        return
    end

    -- Check if we're being trained hard
    local _, melee, _, cds = player.v2attackers()
    if melee >= 1 and cds >= 1 and player.hp <= 70 then
        -- Swap Beacon of Faith to ourselves if we're the target
        if not player.buff(beaconOfFaith.id) and not player.buff(beaconOfLight.id) then
            beaconOfFaith:Cast(player)
        end
    else
        -- Return Beacon of Faith to teammate if we're no longer being trained
        if player.buff(beaconOfFaith.id) then
            awful.fgroup.loop(function(friend)
                if not friend.isUnit(player) and not friend.healer and 
                   not friend.buff(beaconOfLight.id) and not friend.buff(beaconOfFaith.id) and friend.los then
                    beaconOfFaith:Cast(friend)
                end
            end)
        end
    end
end

function project.beaconOG()
    local currentBeaconLightTarget, currentBeaconFaithTarget = nil, nil
    local highestUrgencyTarget, secondHighestUrgencyTarget = nil, nil
    local highestUrgency = -1
    local secondHighestUrgency = -1
    local swapThreshold = 25 -- Defines the minimum urgency difference to justify a swap

    awful.fgroup.within(60).loop(function(friend)
        if project.LowestHealth <= 40 then return end

        local total, _, _, cds = friend.v2attackers()
        local beingAttackedBonus = bin(total) * 10
        local cdsBonus = cds * 12
        local attackersBonus = total * 10
        local healthUrgency = (100 - friend.hp) * 0.2

        local urgencyScore = beingAttackedBonus + cdsBonus + attackersBonus + healthUrgency
        if friend.buff(beaconOfLight.id) then
            currentBeaconLightTarget = friend
        elseif friend.buff(beaconOfFaith.id) then
            currentBeaconFaithTarget = friend
        end

        if urgencyScore > highestUrgency then
            secondHighestUrgency, secondHighestUrgencyTarget = highestUrgency, highestUrgencyTarget
            highestUrgency, highestUrgencyTarget = urgencyScore, friend
        elseif urgencyScore > secondHighestUrgency then
            secondHighestUrgency, secondHighestUrgencyTarget = urgencyScore, friend
        end
    end)

    local needLightSwap = currentBeaconLightTarget ~= highestUrgencyTarget and
        (not currentBeaconLightTarget or highestUrgency - (currentBeaconLightTarget.urgency or -1) > swapThreshold)
    local needFaithSwap = currentBeaconFaithTarget ~= secondHighestUrgencyTarget and
        secondHighestUrgencyTarget ~= highestUrgencyTarget and
        (not currentBeaconFaithTarget or secondHighestUrgency - (currentBeaconFaithTarget.urgency or -1) > swapThreshold)

    if needLightSwap then
        if not highestUrgencyTarget.buff(beaconOfFaith.id) then
            if not highestUrgencyTarget.los then return end
            beaconOfLight:Cast(highestUrgencyTarget)
        end
    end

    if needFaithSwap then
        if not secondHighestUrgencyTarget.buff(beaconOfLight.id) then
            if not secondHighestUrgencyTarget.los then return end
            beaconOfFaith:Cast(secondHighestUrgencyTarget)
        end
    end
end

local function shouldUseConcentrationAura()
    -- Count team compositions
    local rangedCount = 0
    local totalCount = 0
    local enemyMeleeCount = 0
    local enemyRangedCount = 0

    -- Analyze our team
    awful.fgroup.loop(function(friend)
        totalCount = totalCount + 1
        if rangedClasses[friend.class2] and not friend.healer and not friend.melee then
            rangedCount = rangedCount + 1
        end
    end)

    -- Count enemy composition
    awful.enemies.loop(function(enemy)
        if rangedClasses[enemy.class2] and not enemy.healer and not enemy.melee then
            enemyRangedCount = enemyRangedCount + 1
        else
            enemyMeleeCount = enemyMeleeCount + 1
        end
    end)

    -- Use Concentration Aura if:
    -- 1. Majority ranged team comp on our side
    -- 2. Against double caster comps
    -- 3. Against RMP (Rogue/Mage/Priest) specifically
    if (rangedCount > totalCount/2) or 
       (enemyRangedCount >= 2) or
       (awful.enemies.find(function(enemy) return enemy.class2 == "ROGUE" end) and 
        awful.enemies.find(function(enemy) return enemy.class2 == "MAGE" end) and
        awful.enemies.find(function(enemy) return enemy.class2 == "PRIEST" end)) then
        return true
    end

    -- Default to Devotion Aura for melee cleave matchups
    return false
end

local function updateAura(spell, auraType)
    -- Only update during arena prep
    if not awful.prep then return end
    
    local useConcentration = shouldUseConcentrationAura()
    local hasConcentration = player.buff(concentrationAura.id)
    local hasDevotion = player.buff(devotionAura.id)

    if auraType == "concentration" then
        if hasConcentration then return end
        if useConcentration then
            spell:Cast()
            return true
        end
    elseif auraType == "devotion" then
        if hasDevotion then return end
        if not useConcentration then
            spell:Cast()
            return true
        end
    end
end

-- Callback for Concentration Aura
concentrationAura:Callback(function(spell)
    updateAura(spell, "concentration")
end)

-- Callback for Devotion Aura
devotionAura:Callback(function(spell)
    updateAura(spell, "devotion")
end)

holyShock:Callback(function(spell)
    if project.cd(holyShock) > 0 then return end
    if player.holypower > 4 then return end
    if (player.buff(risingSunlight.id) and player.holypower > 2) then return end
    if project.LowestHealth > project.settings.hs then return end
    if not project.LowestUnit.los then return end
    if project.LowestUnit.predictDistance(0.5) > spell.range then return end
    if not player.facing(project.LowestUnit) then return end

    return spell:Cast(project.LowestUnit)
end)

holyShock:Callback("enemies", function(spell)
    if project.cd(holyShock) > 0 then return end
    if player.holypower > 4 then return end
    if project.enemyBursting then return end
    if project.LowestHealth < project.settings.hs then return end
    if holyShock.charges < 2 and holyShock.nextChargeCD > awful.gcd then return end
    if not project.LowestEnemyUnit then return end
    if (player.buff(risingSunlight.id) and player.holyPower > 2) then return end
    if not project.LowestEnemyUnit.los then return end
    if project.LowestEnemyUnit.predictDistance(0.5) > spell.range then return end
    if project.LowestEnemyUnit.immuneMagic then return end
    if not player.facing(project.LowestEnemyUnit) then return end
    return spell:Cast(project.LowestEnemyUnit)
end)

flashOfLight:Callback("infusion", function(spell)
    local holdGCD = false
    if project.cd(flashOfLight) > 0 then return end
    if player.holypower > 4 then return end
    if (holyShock.charges >= 1 or holyShock.nextChargeCD <= awful.gcdRemains) and player.holypower <= 4 then return end
    if project.LowestHealth and project.LowestHealth > project.settings.fol then return end
    if not player.buff(infusionOfLight.id) then return end
    if (project.LowestHealth < project.settings.wog and player.holypower >= 3) then return end
    if not project.LowestUnit.predictLoS(0.5, player) then return end
    if project.LowestUnit.predictDistance(0.5) > spell.range then return end
    if not player.facing(project.LowestUnit) then return end
    if awful.gcdRemains and awful.gcdRemains < awful.gcd then holdGCD = true end
    if spell:Cast(project.LowestUnit) and player.canBeInterrupted(spell.castTime) then
        alert(colors.pink ..
            "Gladdy | " .. colors.white .. " Enemy Interrupts Available, Juke these kids!")
    end
    return holdGCD
end)

flashOfLight:Callback(function(spell)
    if project.cd(flashOfLight) > 0 then return end
    if player.holypower > 4 then return end
    if (holyShock.charges >= 1 or holyShock.nextChargeCD <= awful.gcdRemains) and player.holypower <= 4 then return end
    if project.LowestHealth and project.LowestHealth > project.settings.fol then return end
    if project.LowestHealth < project.settings.wog and player.holypower >= 3 then return end
    if not project.LowestUnit.predictLoS(0.5, player) then return end
    if project.LowestUnit.predictDistance(0.5) > spell.range then return end
    if not player.facing(project.LowestUnit) then return end
    if spell:Cast(project.LowestUnit) and player.canBeInterrupted(spell.castTime) then
        alert(colors.pink ..
            "Gladdy | " .. colors.white .. " Enemy Interrupts Available, Juke these kids!")
    end
end)

wordOfGlory:Callback(function(spell)
    if project.cd(wordOfGlory) > 0 then return end
    --if (holyShock.charges >= 1 and player.holypower <= 4) then return end
    if project.LowestHealth > project.settings.wog then return end
    if (player.holypower < 3 and not player.buff(divinePurpose.id)) then return end
    if not project.LowestUnit.los then return end
    if project.LowestUnit.dist > spell.range then return end
    if not player.facing(project.LowestUnit) then return end
    return spell:Cast(project.LowestUnit)
end)

crusaderStrike:Callback(function(spell)
    local nerd = nil
    if project.cd(crusaderStrike) > 0 then return end
    if player.holypower > 4 then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if enemy.bcc then return end
        if not spell:Castable(enemy) then return end
        if not enemy.los then return end
        if not player.facing(enemy) then return end
        nerd = enemy
        return true
    end)
    if not nerd then return end
    return spell:Cast(nerd)
end)

judgement:Callback(function(spell)
    local nerd = nil
    if project.cd(judgement) > 0 then return end
    if player.holypower > 4 then return end
    if (holyShock.charges >= 1 or holyShock.nextChargeCD <= awful.gcdRemains) and player.holypower <= 4 and not player.buff(216331) then return end -- Avenging Crusader
    --if project.LowestHealth <= project.settings.fol then return end
    if project.LowestHealth <= project.settings.wog and player.holypower >= 3 then return end
    awful.enemies.within(spell.range).loop(function(enemy)
        if enemy.bcc then return end
        if enemy.pet then return end
        if enemy.dist > spell.range then return end
        if not enemy.los then return end
        if not player.facing(enemy) then return end

        if enemy.target.isUnit(project.LowestUnit) and not enemy.healer then
            nerd = enemy
            return true
        end
    end)

    if nerd then
        return spell:Cast(nerd)
    end
end)

judgement:Callback("infusion", function(spell)
    local nerd = nil
    if project.cd(judgement) > 0 then return end
    if not player.buff(infusionOfLight.id) then return end
    if player.holypower > 4 then return end
    if (holyShock.charges >= 1 or holyShock.nextChargeCD <= awful.gcdRemains) and player.holypower <= 4 and not player.buff(216331) then return end -- Avenging Crusader
    --if project.LowestHealth <= project.settings.fol then return end
    if project.LowestHealth <= project.settings.wog and player.holypower >= 3 then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if enemy.bcc then return end
        if enemy.pet then return end
        if enemy.dist > spell.range then return end
        if not enemy.los then return end
        if not player.facing(enemy) then return end

        if enemy.target.isUnit(project.LowestUnit) and not enemy.healer then
            nerd = enemy
            return true
        end
    end)

    if nerd then
        return spell:Cast(nerd)
    end
end)

hammerOfWrath:Callback(function(spell)
    if project.cd(hammerOfWrath) > 0 then return end
    if player.holypower > 4 then return end
    if not spell:Castable(project.LowestEnemyUnit) then return end
    if not project.LowestEnemyUnit then return end
    if project.LowestEnemyUnit.dist > spell.range then return end
    if not project.LowestEnemyUnit.los then return end
    if project.LowestEnemyUnit.bcc then return end
    if not (player.buff(avengingWrath.id) and project.LowestEnemyUnit.hp > 20) then return end
    if not player.facing(project.LowestEnemyUnit) then return end
    return spell:Cast(project.LowestEnemyUnit)
end)

denounce:Callback(function(spell)
    if project.cd(denounce) > 0 then return end
    if not player.hasTalent(denounce.id) then return end
    if not project.LowestEnemyUnit then return end
    if project.LowestEnemyUnit.debuff(denounce.id) and project.LowestEnemyUnit.debuffRemains(denounce.id) > spell.castTime then return end
    if player.holypower >= 5 and project.LowestHealth <= project.settings.wog then return end
    if player.holypower < 5 then return end
    if not project.LowestEnemyUnit then return end
    if project.LowestEnemyUnit.predictDistance(0.5) > spell.range then return end
    if not project.LowestEnemyUnit.predictLoS(0.5, player) then return end
    if project.LowestEnemyUnit.bcc then return end
    if not player.facing(project.LowestEnemyUnit) then return end
    return spell:Cast(project.LowestEnemyUnit)
end)

tyrsDeliverance:Callback(function(spell)
    if awful.prep then return end
    if player.moving then return end
    if project.cd(spell) > 0 then return end
    if project.LowestUnit.hpa <= 40 then return end
    if (player.canBeInterrupted(spell.castTime) and not player.castint) then return end
    return spell:Cast(player)
end)

tyrsDeliverance:Callback("auraMastery", function(spell)
    if player.moving then return end
    if project.cd(spell) > 0 then return end
    if not player.buff(concentrationAura.id) then return end
    if not (auraMastery.prevgcd or player.buff(auraMastery.id)) then return end
    return spell:Cast(player)
end)

avengingWrath:Callback("burst", function(spell)
    local total, _, _, cds = project.LowestUnit.v2attackers()
    local shouldCast = false

    if project.cd(spell) > 0 then return end
    awful.enemies.within(spell.range).loop(function(enemy)
        if (enemy.used(BurstCDS, 3) or enemy.buffFrom(BurstCDS2)) then
            shouldCast = true
            return true
        end
    end)

    if project.LowestHealth <= 40 then
        shouldCast = true
    end

    if shouldCast then
        return spell:Cast(player)
    end
end)

layOnHands:Callback(function(spell)
    local homie = project.LowestUnit
    local total, melee, ranged, cds = player.v2attackers()
    if project.cd(spell) > 0 then return end
    if project.LowestHealth > project.settings.loh then return end
    if not project.LowestUnit.los then return end
    if project.LowestUnit.dist > spell.range then return end
    if homie.debuff(forbearance.id) and homie.debuffRemains(forbearance.id) > awful.gcdRemains then return end
    if player.buff(tyrsDeliverance.id) and project.LowestHealth > 25 then return end
    if player.buff(avengingWrath.id) and player.buffRemains(avengingWrath.id) > awful.gcdRemains then return end
    if project.cd(avengingWrath) <= 0 and project.LowestHealth > 25 then return end
    if not player.facing(homie) then return end
    --if homie.class2 == "PALADIN" and homie.cooldown(divineShield.id) < awful.gcd then return end
    if homie.class2 == "PALADIN" and homie.hasTalent(spellWarding.id) and homie.cooldown(spellWarding.id) < awful.gcd then return end
    if homie.isUnit(player) and project.cd(divineShield) <= 0 then return end
    if homie.isUnit(player) and project.cd(blessingOfProtection) <= 0 and melee >= 1 and player.hp <= 40 then return end
    return spell:Cast(homie)
end)

blessingOfSacrifice:Callback("cc", function(spell)
    local aids = false
    if not project.settings.boscc then return end
    if not player.hasTalent(blessingOfSacrifice.id) then return end
    if project.cd(spell) > 0 then return end
    awful.enemies.within(spell.range).loop(function(enemy)
        if not enemy.los then return end
        if not player.facing(project.LowestUnit) then return end
        if not project.LowestUnit.los then return end
        if project.LowestUnit.immunePhysical then return end
        if project.LowestUnit.dist > spell.range then return end
        if project.LowestUnit.buff(blessingOfProtection.id) then return end
        if enemy.casting and sacTable[enemy.castID] and enemy.castTarget.isUnit(player) and enemy.castRemains <= 0.5 then
            aids = true
        end
    end)
    if not aids then return end
    return spell:Cast(project.LowestUnit)
end)

blessingOfSacrifice:Callback("lowHP", function(spell)
    if not project.settings.bos then return end
    if not player.hasTalent(blessingOfSacrifice.id) then return end
    if project.cd(spell) > 0 then return end
    if Dampening() < 40 and project.cd(layOnHands) <= 0 and not project.LowestUnit.debuff(forbearance.id) then return end
    if (player.hasTalent(avengingWrath.id) and project.cd(avengingWrath) <= 0) then return end
    if (layOnHands.current or layOnHands.prevgcd or player.used(layOnHands.id, 2)) then return end
    if project.LowestHealth > 40 then return end
    if not player.facing(project.LowestUnit) then return end
    if not project.LowestUnit.los then return end
    if project.LowestUnit.immunePhysical then return end
    if project.LowestUnit.dist > spell.range then return end
    if project.LowestUnit.buff(blessingOfProtection.id) then return end
    return spell:Cast(project.LowestUnit)
end)

local sacClasses = {
    ["WARLOCK"] = true,
    ["EVOKER"] = true,
    ["MAGE"] = true,
}

local function shouldSacBurst()
    local shouldSac = true
    local foundExcludedClass = false

    awful.enemies.within(40).loop(function(enemy)
        if sacClasses[enemy.class2] then
            foundExcludedClass = true
            return false
        end
    end)

    if foundExcludedClass then
        shouldSac = false
    end

    return shouldSac
end

blessingOfSacrifice:Callback("burst", function(spell)
    local aids = false
    local total, melee, _, cds = project.LowestUnit.v2attackers()
    if not player.hasTalent(blessingOfSacrifice.id) then return end
    if project.cd(spell) > 0 then return end
    if player.hp <= 40 then return end
    if project.LowestUnit.buff(blessingOfProtection.id) then return end
    if project.cd(avengingWrath) <= 0 then return end
    if project.LowestUnit.immunePhysical and project.LowestUnit.physicalEffectImmunityRemains > awful.gcdRemains then return end
    if player.buff(avengingWrath.id) and player.buffRemains(avengingWrath.id) > awful.gcdRemains then return end
    if Dampening() <= 40 and project.cd(layOnHands) <= 0 and not project.LowestUnit.debuff(forbearance.id) then return end
    awful.enemies.within(spell.range).loop(function()
        if cds < 1 then return end
        if not project.LowestUnit.los then return end
        if project.LowestUnit.isUnit(player) then return end
        aids = true
    end)
    if not aids then return end
    return spell:Cast(project.LowestUnit)
end)

blessingOfProtection:Callback("low", function(spell)
    local shouldCastBoP = false
    local total, _, _, cds = project.LowestUnit.v2attackers()
    if not player.hasTalent(blessingOfProtection.id) then return end
    if project.cd(spell) > 0 then return end

    local function meleeNerds(unit) return (unit.melee or unit.class2 == "HUNTER" or unit.spec == "Demonology") and not unit.pet and not unit.dead and unit.enemy end
    local physicalCount = awful.enemies.within(spell.range).filter(meleeNerds)
    local function burstingNerd(unit) return (unit.cds or unit.used(BurstCDS, 3) or unit.buffFrom(BurstCDS2)) and
        not unit.dead and unit.enemy and not unit.pet and unit.los end
    local nerd = awful.enemies.within(spell.range).filter(burstingNerd)
    local function bop(unit) return unit.buff(blessingOfProtection.id, player) and not unit.pet and not unit.dead end
    local bopCount = awful.fgroup.within(spell.range).filter(bop)
    --(#physicalCount >= 1 and #nerd >= 1) or


    if (#physicalCount >= 1 and project.LowestHealth <= 40) then
        shouldCastBoP = true
    end

    if shouldCastBoP then
        if project.cd(blessingOfSacrifice) <= 0 then return end
        if project.LowestUnit.immunePhysical then return end
        if project.LowestUnit.debuff(forbearance.id) then return end
        if project.LowestUnit.buff(blessingOfSacrifice.id) and project.LowestUnit.hpa > 35 then return end
        --if project.LowestUnit.class2 == "PALADIN" and not project.LowestUnit.isUnit(player) and project.LowestUnit.cooldown(divineShield.id) < awful.gcd then return end
        if total < 1 then return end
        if #bopCount > 0 and project.LowestUnit.hpa > 30 then return end
        if not project.LowestUnit.los then return end
        return spell:Cast(project.LowestUnit)
    end
end)

auraMastery:Callback("burst", function(spell)
    local aids = false
    local total, _, _, cds = project.LowestUnit.v2attackers()
    if not project.settings.am then return end
    if project.cd(spell) > 0 then return end
    if not player.buff(devotionAura.id) then return end
    if cds < 3 and (player.buff(avengingWrath.id) and player.buffRemains(avengingWrath.id) > awful.gcdRemains) then return end
    if cds < 4 and (player.buff(divineResonance.id) and player.buffRemains(divineResonance.id) > awful.gcdRemains) then return end
    if project.LowestUnit.distance > devotionAura.range then return end
    awful.enemies.within(devotionAura.range).loop(function(enemy)
        if not enemy.used(BurstCDS, 3) or enemy.buffFrom(BurstCDS2) or enemy.cds then return end
        aids = true
        return true
    end)
    if not aids then return end
    return spell:Cast(player)
end)

auraMastery:Callback("lowHP", function(spell)
    if not project.settings.am then return end
    if project.cd(spell) > 0 then return end
    if not player.buff(devotionAura.id) then return end
    if project.LowestHealth > 40 then return end
    if project.LowestUnit.immunePhysical then return end
    if project.LowestUnit.isUnit(player) and player.buff(divineShield.id) then return end
    return spell:Cast(player)
end)

auraMastery:Callback("cc", function(spell)
    local aids = false
    if not project.settings.am then return end
    if project.cd(spell) > 0 then return end
    if not player.buff(devotionAura.id) then return end
    if project.cd(blessingOfSacrifice) <= 0 then return end
    if project.LowestUnit.distance > 40 then return end
    awful.enemies.within(spell.range).loop(function(enemy)
        if not enemy.los then return end
        if not enemy.casting then return end
        if not enemy.castTarget.isUnit(player) then return end
        if not sacTable[enemy.castID] then return end
        if enemy.castremains > 0.5 then return end
        aids = true
        return true
    end)
    if not aids then return end
    return spell:Cast(player)
end)

auraMastery:Callback("tyrs", function(spell)
    if not player.buff(concentrationAura.id) then return end
    if not project.enemyBursting then return end
    if project.cd(spell) > 0 then return end
    if not (player.canBeInterrupted(tyrsDeliverance.castTime)) then return end
    if project.cd(tyrsDeliverance) > 0 then return end
    return spell:Cast(player)
end)

auraMastery:Callback("fburst", function(spell)
    local aids = false
    if not player.buff(concentrationAura.id) then return end
    if project.cd(spell) > 0 then return end
    awful.fgroup.within(spell.range).loop(function(friend)
        if not (friend.cds and friend.casting and friend.canBeInterrupted) or (friend.cds and friend.casting and friend.canBeInterrupted and friend.castTarget.isUnit(enemyHealer)) then return end
        if friend.distance > concentrationAura.range then return end
        aids = true
        return true
    end)
    if not aids then return end
    return spell:Cast(player)
end)

repentance:Callback("auraMastery", function(spell)
    local total, _, _, _ = enemyHealer.v2attackers()
    if not player.hasTalent(repentance.id) then return end
    if not player.buff(concentrationAura.id) then return end
    if not player.buff(auraMastery.id) then return end
    if enemyHealer.idr < 0.5 then return end
    if not enemyHealer.predictLoS(0.5, player) then return end
    if enemyHealer.predictDistance(0.5) > spell.range then return end
    if enemyHealer.beast then return end
    if enemyHealer.immuneCC and enemyHealer.ccImmunityRemains > repentance.castTime + awful.buffer then return end
    if total >= 1 then return end

    if enemyHealer.cc and enemyHealer.ccRemains <= repentance.castTime + awful.buffer or enemyHealer.bcc and enemyHealer.bccRemains <= repentance.castTime + awful.buffer then
        return spell:Cast(enemyHealer)
    end

    if not (enemyHealer.cc or enemyHealer.bcc) then
        return spell:Cast(enemyHealer)
    end
end)

divineToll:Callback(function(spell)
    if not player.hasTalent(divineToll.id) then return end
    if project.cd(spell) > 0 then return end
    if holyShock.charges > 0 then return end
    if (player.holypower > 3 and project.cd(wordOfGlory) > 0) then return end
    if project.LowestHealth > project.settings.wog then return end
    if project.LowestUnit.dist > spell.range then return end
    spell:Cast(player)
end)

divineToll:Callback("old", function(spell)
    local total, _, _, cds = project.LowestUnit.v2attackers()
    local nerd = 0
    local nerds = function(obj) return obj.enemy and obj.distanceTo(player) <= spell.range and not obj.pet and obj.los end
    if not player.hasTalent(divineToll.id) then return end
    if project.cd(spell) > 0 then return end
    if not (avengingWrath.prevgcd or player.used(avengingWrath.id, 2) or player.buff(avengingWrath.id)) or tyrsDeliverance.prevgcd or player.used(tyrsDeliverance.id, 2) or player.buff(tyrsDeliverance.id) then return end
    if player.holypower >= 3 then return end
    if project.LowestHealth > project.settings.wog then return end
    awful.enemies.filter(nerds).loop(function()
        nerd = nerd + 1
    end)
    if nerd < 2 then return end
    return spell:Cast(player)
end)

divineToll:Callback("glimmer", function(spell)
    if not player.combat then return end
    local nerd = 0
    local nerds = function(obj) return obj.enemy and obj.distanceTo(player) <= spell.range and not obj.pet and obj.los end
    if not player.hasTalent(divineToll.id) then return end
    if project.cd(spell) > 0 then return end
    if project.cd(avengingWrath) <= 0 then return end
    if avengingWrath.cd <= divineToll.cd then return end
    if player.holypower >= 3 then return end
    if project.LowestHealth > project.settings.wog then return end
    awful.enemies.filter(nerds).loop(function()
        nerd = nerd + 1
    end)
    if nerd < 2 then return end
    return spell:Cast(player)
end)

divineFavor:Callback(function(spell)
    if not player.hasTalent(spell.id) then return end
    if project.cd(spell) > 0 then return end
    if divineFavor.cd <= awful.gcdRemains then
        return spell:Cast()
    end
end)

handOfDivinity:Callback(function(spell)
    local total, _, _, cds = project.LowestUnit.v2attackers()
    if not player.hasTalent(spell.id) then return end
    if project.cd(spell) > 0 then return end
    if holyShock.charges > 0 and project.LowestHealth <= project.settings.hs then return end
    if player.holypower >= 3 and project.LowestHealth <= project.settings.wog then return end
    if project.cd(tyrsDeliverance) <= 0 then return end
    if cds <= 1 and (auraMastery.current or auraMastery.prevgcd or player.buff(auraMastery.id)) then return end
    if not project.enemyBursting then return end
    return spell:Cast(player)
end)

holyLight:Callback("divinity", function(spell)
    if not player.buff(handOfDivinity.id) then return end
    local healthThreshold = 80
    local buffDurationThreshold = 3
    local buffRemains = player.buffRemains(handOfDivinity.id)
    if project.cd(spell) > 0 then return end
    if project.LowestHealth <= (healthThreshold or buffRemains <= buffDurationThreshold) then
        if project.LowestUnit.dist > spell.range then return end
        if not project.LowestUnit.los then return end
        if not player.facing(project.LowestUnit) then return end
        return spell:Cast(project.LowestUnit)
    end
end)


divineShield:Callback("noTrinket", function(spell)
    if project.cd(spell) > 0 then return end
    if not (project.greenTrinket.equipped or project.epicTrinket.equipped) then return end
    
    local inDangerousCC = (player.cc and player.ccRemains >= 2) or (player.bcc and player.bccRemains >= 2) or (player.silence and player.silenceRemains >= 2)
    
    if inDangerousCC and project.LowestHealth <= 30 then
        if project.greenTrinket.equipped and trinket.cd > 0 then
            return spell:Cast(player) and awful.alert("Divine Shield (Trinket on CD)", spell.id)
        end
        
        if project.epicTrinket.equipped and trinket.cd > awful.gcd then
            return spell:Cast(player) and awful.alert("Divine Shield (Trinket on CD)", spell.id)
        end
    end
end)

divineShield:Callback(function(spell)
    if project.cd(spell) > 0 then return end
    --if player.debuff(forbearance.id) then return end
    if player.buff(blessingOfProtection.id) then return end
    if player.buff(divineProtection.id) and player.hp > 20 then return end
    if player.buff(auraMastery.id) and player.buff(devotionAura.id) and player.hp > 20 then return end
    if player.hp > project.settings.bub then return end
    return spell:Cast(player)
end)

local findPet = function(obj) return obj.pet and obj.enemy and obj.distance <= 30 and not obj.dead end

handOfReckoning:Callback(function(spell)
    local targetEnemy = nil
    local foundPet = nil
    if project.cd(spell) > 0 then return end
    awful.enemies.within(spell.range).loop(function(enemy)
        if not enemy.los then return end
        if not enemy.casting then return end
        if not sacTable[enemy.castID] then return end
        if enemy.castTarget == nil then return end
        if not enemy.castTarget.isUnit(player) then return end
        if enemy.castRemains > 0.5 then return end
        targetEnemy = enemy
        return true
    end)

    if not targetEnemy then return end

    awful.pets.filter(findPet).loop(function(pet)
        if pet.distance > 30 then return end
        if not pet.los then return end
        if not player.facing(pet) then return end
        foundPet = pet
        return true
    end)

    if not foundPet then return end

    return spell:Cast(foundPet)
end)


local blessingClasses = {
    ["MAGE"] = true,
    ["MONK"] = true,
    ["PRIEST"] = true,
    ["ROGUE"] = true,
    ["PALADIN"] = true,
}

awful.addEventCallback(function(_, event, _, isReload)
    if isReload then return end
    if event == "PLAYER_ENTERING_WORLD" then
        project.hasAttemptedCollection = false
        project.summerCast = false
        project.autumnCast = false
        project.winterCast = false
        project.springCast = false
    end
end)

    -- Reset all flags
    local resetFlags = function()
        project.summerCast = false
        project.autumnCast = false
        project.winterCast = false
        project.springCast = false
    end

awful.addEventCallback(function(eventinfo, event, source)
    local spellID = select(12, unpack(eventinfo))
    if event ~= "SPELL_CAST_SUCCESS" then return end
    if source == nil or not source.player then return end
       
    -- Handle blessing sequence
    if spellID == blessingOfSummer.id then
        project.summerCast = true
    elseif spellID == blessingOfAutumn.id then
        project.summerCast = true
        project.autumnCast = true
    elseif spellID == blessingOfWinter.id then
        project.summerCast = true
        project.autumnCast = true
        project.winterCast = true
    elseif spellID == blessingOfSpring.id then
        resetFlags()
    end
end)

-- Blessing of Summer callback
blessingOfSummer:Callback(function(spell)
    if project.summerCast then return end
    if project.cd(spell) > 0 then return end
    if not player.combat then return end
    return spell:Cast(player)
end)

-- Blessing of Autumn callback
blessingOfAutumn:Callback(function(spell)
    if not project.summerCast then return end
    if project.autumnCast then return end
    if project.cd(spell) > 0 then return end
    if not player.combat then return end
    return spell:Cast(player)
end)

-- Blessing of Winter callback
blessingOfWinter:Callback(function(spell)
    if not project.autumnCast then return end
    if project.winterCast then return end
    if project.cd(spell) > 0 then return end
    if not player.casting and not player.channeling then
        return spell:Cast(player)
    end
end)

-- Blessing of Spring callback
blessingOfSpring:Callback(function(spell)
    if not project.winterCast then return end
    if project.springCast then return end
    local highestUrgencyScore = -1
    local bestTarget = nil
    if project.cd(spell) > 0 then return end

    awful.fgroup.within(spell.range).loop(function(friend)
        local total, _, _, cds = friend.v2attackers()
        local beingAttackedBonus = bin(friend.enemiesattacking) * 10
        local cdsBonus = cds * 12
        local attackersBonus = total * 15
        local healthUrgency = (100 - friend.hp) * 0.5

        local urgencyScore = beingAttackedBonus + cdsBonus + attackersBonus + healthUrgency

        if urgencyScore > highestUrgencyScore then
            highestUrgencyScore = urgencyScore
            bestTarget = friend
        end
    end)
    if bestTarget and bestTarget.los and player.facing(bestTarget) and bestTarget.combat then
        return spell:Cast(bestTarget)
    end
end)

repentance:Callback(function(spell)
    if not player.hasTalent(repentance.id) then return end
    if project.cd(spell) > 0 then return end
    if not project.settings.rep then return end
    local total, _, _, _ = enemyHealer.v2attackers()
    if project.LowestHealth <= 50 then return end
    if not player.facing(enemyHealer) then return end
    if not enemyHealer.predictLoS(0.5, player) then return end
    if enemyHealer.predictDistance(0.5) > spell.range then return end
    if enemyHealer.idr < 0.5 then return end
    if enemyHealer.immuneCC and enemyHealer.ccImmunityRemains > repentance.castTime + awful.buffer then return end
    if enemyHealer.beast then return end
    if total >= 1 then return end

    if enemyHealer.cc and enemyHealer.ccRemains <= spell.castTime + awful.buffer or enemyHealer.bcc and enemyHealer.bccRemains <= spell.castTime + awful.buffer then
        return spell:Cast(enemyHealer)
    end

    if not (enemyHealer.cc or enemyHealer.bcc) then
        return spell:Cast(enemyHealer)
    end
end)

hammerOfJustice:Callback("healer", function(spell)
    local holdGCD = false
    if not project.settings.hoj then return end
    if project.cd(spell) > 0 then return end
    if repentance.prevgcd then return end
    if not enemyHealer.exists then return end
    if not player.facing(enemyHealer) then return end
    if not enemyHealer.predictLoS(0.5, player) then return end
    if enemyHealer.sdr < 0.5 then return end
    if enemyHealer.buff(8178) and enemyHealer.buffRemains(8178) > awful.gcdRemains then return end -- grounding
    if enemyHealer.immuneMagic and enemyHealer.magicEffectImmunityRemains > awful.gcdRemains then return end

    if enemyHealer.exists and player.movingToward(enemyHealer, { angle = 180, duration = 0.5 }) and player.predictDistance(0.5, enemyHealer) <= spell.range + 2 then
        holdGCD = true
        alert(colors.pink .. "Gladdy | " .. colors.red .. "Holding GCD for HOJ")
    end

    if enemyHealer.los and enemyHealer.cc and enemyHealer.ccRemains <= awful.gcdRemains or enemyHealer.bcc and enemyHealer.bccRemains <= awful.gcdRemains and enemyHealer.dist <= spell.range then
        return spell:Cast(enemyHealer)
    end

    if not (enemyHealer.cc or enemyHealer.bcc) and enemyHealer.los and enemyHealer.dist <= spell.range then
        return spell:Cast(enemyHealer)
    end

    return holdGCD
end)

hammerOfJustice:Callback("dps", function(spell)
    local aids = false
    local nerd = nil
    if not project.settings.hoj then return end
    if project.cd(spell) > 0 then return end
    awful.enemies.within(spell.range).loop(function(enemy)
        local total, _, _, cds = enemy.v2attackers()
        if enemy.buff(8178) and enemy.buffRemains(8178) > awful.gcd then return end
        if enemyHealer.buff(215769) then return end -- spirit of redemption
        if (hasCleanse() and not enemyHealer.cc and enemy.predictLoS(0.5, enemyHealer)) then return end
        if enemyHealer.cc and enemyHealer.ccRemains <= 2 then return end
        if enemy.healer then return end
        if enemy.isPet then return end
        if not enemy.los then return end
        if enemy.dead then return end
        if enemy.predictDistance(0.5) > spell.range then return end
        if not player.facing(enemy) then return end
        if enemy.sdr < 0.5 then return end
        if enemy.immuneMagic and enemy.magicEffectImmunityRemains > awful.gcdRemains then return end

        if enemy.los and enemy.cc and enemy.ccRemains <= awful.gcdRemains or enemy.bcc and enemy.bccRemains <= awful.gcdRemains then
            aids = true
            nerd = enemy
        end

        if enemy.los and (enemy.cds or enemy.used(BurstCDS, 3) or enemy.buffFrom(BurstCDS2)) or project.LowestHealth <= 40 then
            aids = true
            nerd = enemy
        end

        if not (enemy.cc or enemy.bcc) and total >= 1 and enemy.los then
            aids = true
            nerd = enemy
        end
    end)
    if not aids then return end
    return spell:Cast(nerd)
end)

blindingLight:Callback(function(spell)
    local holdGCD = false
    local aids = false
    if not player.hasTalent(blindingLight.id) then return end
    if project.cd(spell) > 0 then return end
    if not project.settings.bl then return end
    if not enemyHealer.exists then return end
    if not enemyHealer.predictLoS(0.5, player) then return end
    if enemyHealer.distanceLiteral > 10 then return end
    if enemyHealer.ddr < 0.5 then return end
    if (project.cd(hammerOfJustice) <= 0 and enemyHealer.sdr >= 0.5) then return end

    if enemyHealer.exists and player.movingToward(enemyHealer, { angle = 180, duration = 0.5 }) and player.predictDistance(0.5, enemyHealer) <= spell.range + 2 then
        holdGCD = true
        alert(colors.pink .. "Gladdy | " .. colors.red .. "Holding GCD for Blind")
    end

    if enemyHealer.los and enemyHealer.cc and enemyHealer.ccRemains <= awful.gcdRemains or enemyHealer.bcc and enemyHealer.bccRemains <= awful.gcdRemains and enemyHealer.dist <= spell.range then
        return spell:Cast()
    end

    if not (enemyHealer.cc or enemyHealer.bcc) and enemyHealer.los and enemyHealer.dist <= spell.range then
        return spell:Cast()
    end


    return holdGCD
end)

local rogueCDS = {
    [359053] = true, -- smokebomb
    [212182] = true, -- smokebomb
    [207736] = true, -- duel
}

blindingLight:Callback("rogues", function(spell)
    local shouldCast = false
    if not player.hasTalent(blindingLight.id) then return end
    if project.cd(spell) > 0 then return end
    if not project.settings.bl then return end

    local function rogueDanger(unit) return unit.debuffFrom(rogueCDS) and unit.friend and not unit.pet and not unit.dead end
    local danger = awful.fgroup.within(10).filter(rogueDanger)

    if #danger < 1 then return end
    awful.enemies.within(10).loop(function(enemy)
        if enemy.class2 ~= "ROGUE" then return end
        if enemy.ddr < 0.5 then return end
        if enemy.cc and enemy.ccRemains > awful.gcdRemains then return end
        if enemy.bcc and enemy.bccRemains > awful.gcdRemains then return end
        if enemy.immuneMagic and enemy.magicEffectImmunityRemains > awful.gcdRemains then return end
        shouldCast = true
    end)
    if not shouldCast then return end
    return spell:Cast()
end)

blessingOfProtection:Callback("dangerous", function(spell)
    local aids = false
    local nerd = nil
    if not player.hasTalent(spell.id) then return end
    if project.cd(spell) > 0 then return end
    if not project.settings.bop then return end
    awful.fgroup.within(spell.range).loop(function(friend)
        if friend.buff(blessingOfProtection.id) then return end
        if friend.debuff(forbearance.id) and friend.debuffRemains(forbearance.id) > awful.gcdRemains then return end
        if friend.class2 == "PALADIN" and not friend.hasTalent(146956) and not friend.isUnit(player) and friend.cooldown(divineShield.id) < awful.gcd then return end -- lights revocation (forbearance forgiveness)
        if friend.dist > spell.range then return end
        if not friend.los then return end
        if not friend.debuffFrom(bopCDS) then return end
        if friend.immunePhysical then return end
        if not player.facing(friend) then return end
        aids = true
        nerd = friend
    end)
    if not aids then return end
    return spell:Cast(nerd)
end)

blessingOfFreedom:Callback(function(spell)
    local aids = false
    local nerd = nil
    if not player.hasTalent(spell.id) then return end
    if project.cd(spell) > 0 then return end
    awful.fgroup.within(spell.range).loop(function(friend)
        if not player.facing(friend) then return end
        if not friend.los then return end
        if friend.dist > spell.range then return end
        if friend.rooted and not friend.debuff(162488) and project.cd(cleanse) <= 0 then return end
        if friend.buff(blessingOfFreedom.id) then return end
        if not (friend.rooted or friend.slowed or friend.debuff(45524)) then return end                                                                                -- chains
        if friend.slowed and not friend.moving then return end
        if player.enemiesattacking and blessingOfFreedom.charges < 2 and (player.slowed or player.rooted or player.debuff(45524)) and friend ~= player then return end -- chains
        if (friend.rooted and friend.rootRemains < 2 or friend.slowed and friend.slowRemains < 2) then return end
        aids = true
        nerd = friend
    end)
    if not aids then return end
    return spell:Cast(nerd)
end)

barrierOfFaith:Callback(function(spell)
    if not player.hasTalent(spell.id) then return end
    if project.LowestUnit.buff(barrierBuff.id) then return end
    if project.cd(spell) > 0 then return end
    if project.LowestHealth > 90 then return end
    if not project.LowestUnit.enemiesattacking then return end
    if project.LowestUnit.dist > spell.range then return end
    if not project.LowestUnit.los then return end
    if not player.facing(project.LowestUnit) then return end
    return spell:Cast(project.LowestUnit)
end)

divineProtection:Callback(function(spell)
    if project.cd(spell) > 0 then return end
    if not project.settings.dp then return end
    local total, melee, ranged, cds = player.v2attackers()
    if player.buff(divineShield.id) then return end
    if player.buff(blessingOfProtection.id) then return end
    if player.buff(devotionAura.id) and player.buff(auraMastery.id) then return end
    if (melee >= 1 and cds >= 1 or total >= 2 or player.hp <= 40 and player.enemiesattacking or cds >= 1 and total >= 1 or melee >= 2) then
        if player.casting then awful.call("SpellStopCasting") end
        return spell:Cast(player)
    end
end)

rebuke:Callback("CC", function(spell)
    local aids = false
    local nerd = nil
    if project.cd(spell) > 0 then return end
    awful.enemies.within(spell.range).loop(function(enemy)
        if not (enemy.casting or enemy.channeling) then return end
        if (enemy.casting8 or enemy.channel7) then return end
        if not enemy.los then return end
        if not player.facing(enemy) then return end
        if not (project.flatCC[enemy.castID] or project.flatCC[enemy.channelID]) then return end
        if enemy.castTarget == nil and not enemy.castTarget.isUnit(player) then return end
        if (enemy.castTimeComplete < delay.now or enemy.channelTimeComplete < delay.now) then return end
        aids = true
        nerd = enemy
    end)
    if not aids then return end
    return spell:Cast(nerd)
end)

rebuke:Callback("Heal", function(spell)
    local aids = false
    local nerd = nil
    if project.cd(spell) > 0 then return end
    awful.enemies.within(spell.range).loop(function(enemy)
        if not (enemy.casting or enemy.channeling) then return end
        if (enemy.casting8 or enemy.channel7) then return end
        if not enemy.los then return end
        if not player.facing(enemy) then return end
        if not (project.flatHeals[enemy.castID] or project.flatHeals[enemy.channelID]) then return end
        if (enemy.castTimeComplete or enemy.channelTimeComplete) < delay.now then return end
        if not project.LowestenemyUnit then return end
        if project.LowestEnemyUnit.hp > settings.khp then return end
        aids = true
        nerd = enemy
    end)
    if not aids then return end
    return spell:Cast(nerd)
end)

rebuke:Callback("Dam", function(spell)
    local aids = false
    local nerd = nil
    if project.cd(spell) > 0 then return end
    awful.enemies.within(spell.range).loop(function(enemy)
        if not (enemy.casting or enemy.channeling) then return end
        if (enemy.casting8 or enemy.channel7) then return end
        if not enemy.los then return end
        if not player.facing(enemy) then return end
        if not (project.flatDam[enemy.castID] or project.flatDam[enemy.channelID]) then return end
        if (enemy.castTimeComplete or enemy.channelTimeComplete) < delay.now then return end
        aids = true
        nerd = enemy
    end)
    if not aids then return end
    return spell:Cast(nerd)
end)

cleanse:Callback(function(spell)
    local aids = false
    local nerd = nil
    if project.cd(spell) > 0 then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    awful.fullGroup.within(spell.range).loop(function(friend)
        if not friend then return end
        if not friend.los then return end
        if friend.dist > spell.range then return end
        if not player.facing(friend) then return end
        if friend.debuff("Unstable Affliction") then return end
        if friend.debuff("Vampiric Touch") and project.LowestHealth <= 65 then return end
        if not friend.debuffFrom(cleanseTable) then return end
        aids = true
        nerd = friend
    end)
    if not aids then return end
    return spell:Cast(nerd)
end)

cleanse:Callback("improved", function(spell)
    local aids = false
    local nerd = nil
    if project.cd(spell) > 0 then return end
    if not player.hasTalent(improvedCleanse.id) then return end
    awful.fgroup.within(spell.range).loop(function(friend)
        if friend.debuffFrom(curseTable) then
            if friend.debuff("Unstable Affliction") then return end
            aids = true
            nerd = friend
            return true
        end
    end)
    if not aids then return end
    return spell:Cast(nerd)
end)


awful.addUpdateCallback(function()
    local function nerds(unit) return
        unit.los and
        unit.enemy and not
        unit.dead and not
        unit.pet and not
        unit.cc and not
        unit.bcc and
        (unit.cds or unit.used(BurstCDS, 3) or unit.buffFrom(BurstCDS2)) or ((unit.melee or unit.ranged and unit.class2 == "HUNTER" or unit.dummy))
    end
    local nerd = awful.enemies.within(25).filter(nerds)

    nerd.loop(function(nerd)
        if player.casting and player.castID == searingGlare.id and player.castRemains >= 0.1 and not player.facing(nerd, 45) then
            player.face(nerd, 45)
        end
    end)

    awful.enemies.within(40).loop(function(enemy)

        if player.casting and player.castID == searingGlare.id and player.castPct >= 20 and #nerd < 1 then
            awful.call("SpellStopCasting")
        end

        if player.casting and player.castID == repentance.id and player.castPct >= 20 and (enemyHealer.cc or enemyHealer.bcc) and (enemyHealer.ccRemains or enemyHealer.bccRemains) > repentance.castTime then
            awful.call("SpellStopCasting")
        end
        if player.casting and player.castID == repentance.id and player.castPct >= 20 and (enemyHealer.idr < 0.5 or enemyHealer.immuneMagic or enemyHealer.immuneCC) then
            awful.call("SpellStopCasting")
        end
        if player.casting and player.castID == denounce.id and player.castPct >= 20 and player.castTarget.isUnit(enemy) and enemy.bcc then
            awful.call("SpellStopCasting")
        end
        if player.casting and player.castID == repentance.id and player.castPct >= 85 and enemyHealer.used(32379, 1) then -- swd
            awful.call("SpellStopCasting")
        end
    end)
end)

searingGlare:Callback(function(spell)
    if not player.hasTalent(searingGlare.id) then return end
    if wasCasting[searingGlare.id] then return end
    --if player.canBeInterrupted(spell.castTime) then return end
    if project.cd(spell) > 0 then return end

    local function nerds(unit)
        return
            unit.los and
            unit.enemy and not
            unit.dead and not
            unit.pet and not
            unit.cc and not
            unit.bcc and
            (unit.cds or unit.used(BurstCDS, 3) or unit.buffFrom(BurstCDS2)) or ((unit.melee or unit.ranged and unit.class2 == "HUNTER" or unit.dummy))
    end
    local nerd = awful.enemies.within(25).filter(nerds)
    if #nerd < 1 then return end
    return spell:Cast()
end)
