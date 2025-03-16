local Unlocker, awful, project = ...
if awful.player.class2 ~= "SHAMAN" then return end
if GetSpecialization() ~= 3 then return end
local restoration = project.shaman.restoration
local Spell = awful.Spell
local settings = project.settings
local player = awful.player
local bin = awful.bin
awful.enabled = true
local castDelay = awful.delay(0.200, 0.270)
local channelDelay = awful.delay(0.300, 0.350)
local hookCallbacks, hookSpells = awful.hookSpellCallbacks, awful.hookSpellCasts


awful.AntiAFK.enabled = true

awful.Populate({
    -----------DEFINITIONS--------------
    target = awful.target,
    focus = awful.focus,
    player = awful.player,
    healer = awful.healer,
    pet = awful.pet,
    enemyHealer = awful.enemyHealer,

    --------------HEALS-----------------
    preHot = Spell(974, { heal = true, ignoreMoving = true }),
    preHot2 = Spell(61295, { heal = true, ignoreMoving = true, targeted = true, ignoreChanneling = false, ignoreCasting = false, ignoreFacing = false, ignoreGCD = false }),
    earthShield = Spell(974, { heal = true, ignoreMoving = true, targeted = true, ignoreFacing = false, ignoreChanneling = false, ignoreCasting = false, ignoreGCD = false }),
    healingRain = Spell(73920, { heal = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = false }),
    healingWave = Spell(77472, { heal = true, targeted = true, ignoreFacing = false, ignoreGCD = false }),
    healingWaveNS = Spell(77472, { heal = true, targeted = true, ignoreFacing = false, ignoreMoving = true, ignoreGCD = false }),
    healingSurge = Spell(8004, { heal = true, targeted = true, ignoreFacing = false, ignoreGCD = false }),
    chainHeal = Spell(1064, { heal = true, ignoreFacing = false, ignoreGCD = false }),
    ripTide = Spell(61295, { heal = true, ignoreMoving = true, targeted = true, ignoreChanneling = false, ignoreCasting = false, ignoreFacing = false, ignoreGCD = false }),
    unleashLife = Spell(73685, { heal = true, targeted = true, ignoreFacing = false, ignoreChanneling = false, ignoreCasting = false, ignoreMoving = true, ignoreGCD = false }),
    primordialWave = Spell(428332, { heal = true, ignoreMoving = true, targeted = true, ignoreChanneling = false, ignoreCasting = false, ignoreGCD = false }),
    ascendance = Spell(114052, { beneficial = true, ignoreMoving = true, ignoreGCD = false }),
    naturesSwiftness = Spell(378081, { beneficial = true, ignoreGCD = true, ignoreMoving = true, ignoreFacing = true, ignorecasting = true, ignoreChanneling = true }),
    ancestralGuidance = Spell(108281, { beneficial = true, ignoreMoving = true, ignoreGCD = true, ignoreFacing = true, ignoreCasting = true }),

    --------------DEFENSIVES--------------
    astralShift = Spell(108271, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreCasting = true, ignoreChanneling = true, ignoreGCD = false }),
    burrow = Spell(409293, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreCasting = true, ignoreChanneling = true, ignoreGCD = false }),
    bloodLust = Spell(2825, { beneficial = true, ignoreMoving = true }),
    earthElemental = Spell(198103, { beneficial = true, targeted = false, ignoreFacing = true, ignoreGCD = false }),

    --------------CC-----------------------
    lightningLasso = Spell(305483, { damage = "magic", effect = "physical", cc = "stun", targeted = true, ignoreMoving = true, ignoreGCD = false }),
    thunderStorm = Spell(51490, { ignoreControl = true, ignoreMoving = true, ignoreFacing = true, ignoreCasting = true, ignoreGCD = false }),
    unleashShield = Spell(356736, { effect = "magic", targeted = true, ignoreMoving = true, ignoreGCD = false }),
    windShear = Spell(57994, { targeted = true, ignoreMoving = true, ignoreCasting = true, ignoreGCD = true, ignoreFacing = false }),
    hex = Spell(51514, { effect = "magic", cc = "incapacitate", targeted = true, ignoreFacing = true, ignoreGCD = false }),

    --------------MISC-----------------
    ghostWolf = Spell(2645, { beneficial = true, ignoreMoving = true }),
    purge = Spell(370, { ignoreMoving = true, targeted = true, ignoreFacing = true, ignoreGCD = false }),
    greaterPurge = Spell(378773, { targeted = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = false }),
    purifySpirit = Spell(77130, { ignoreMoving = true, effect = "magic", ignoreGCD = false }),
    flameShock = Spell(188389, { targeted = true, damage = "magic", ignoreChanneling = false, ignoreCasting = false, ignoreFacing = false, ignoreMoving = true, ignoreGCD = false }),
    frostShock = Spell(196740, { targeted = true, damage = "magic", cc = "root", ignoreChanneling = false, ignoreCasting = false, ignoreFacing = false, ignoreMoving = true, ignoreGCD = false }),
    chainLightning = Spell(188443, { targeted = true, damage = "magic", ignoreGCD = false }),
    lavaBurst = Spell(51505, { targeted = true, damage = "magic", ignoreChanneling = false, ignoreCasting = false, ignoreFacing = false, ignoreGCD = false }),
    spiritWalkersGrace = Spell(79206, { beneficial = true, ignoreCasting = true, ignoreMoving = true, ignoreChanneling = true, ignoreGCD = true }),
    rainDance = Spell(290250, { beneficial = true }),
    bloodFury = Spell(33697, { beneficial = true, ignoreMoving = true, ignoreCasting = true, ignoreChanneling = false, ignoreGCD = true }),
    sigilOfMiseryDebuff = Spell(207685),
    sigilOfMisery = Spell(207684),
    preCog = Spell(377362),
    gustOfWind = Spell(192063, { beneficial = true, ignoreMoving = true }),
    spiritWalk = Spell(58875, { beneficial = true, ignoreMoving = true }),
    travelingStorms = Spell(204403),

    -----------------BUFFS----------------------------
    earthLiving = Spell(382021, { beneficial = true }),
    tideCallersGuard = Spell(457481, { beneficial = true }),
    waterShield = Spell(52127, { beneficial = true, ignoreMoving = true, ignoreGCD = false }),
    whirlingElements = Spell(445024),
    whirlingEarth = Spell(453406, { beneficial = true }),
    whirlingAir = Spell(453409, { beneficial = true}),
    whirlingWater = Spell(453407, { beneficial = true}),
    primordialWaveBuff = Spell(375986),
    earthWallBuff = Spell(201633),
    tidalWaves = Spell(53390),
    treeOfLifeBuff = Spell(117679),
    totemicFocus = Spell(382201),
    skyFury = Spell(462854, { targeted = true }),
    healingRainBuff = Spell(456366, { beneficial = true }),
    coalescingWaters = Spell(470077, { beneficial = true }),

    ------------------TOTEMS--------------------------
    totemicRecall = Spell(108285, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = false }),
    healingStream = Spell(5394, { beneficial = true, ignoreMoving = true, ignoreGCD = false }),
    cloudBurst = Spell(157153, { beneficial = true, ignoreMoving = true, ignoreGCD = false }),
    stoneSkin = Spell(108270, { beneficial = true, ignoreMoving = true, ignoreGCD = false }),
    manaTide = Spell(16191, { beneficial = true, ignoreMoving = true, ignoreGCD = false }),
    poisonTotem = Spell(383013, { beneficial = true, ignoreMoving = true, ignoreGCD = false }),
    earthBind = Spell(2484, { effect = "magic", slow = true, targeted = false, ignoreFacing = true, radius = 8, ignoreFriends = true, ignoreGCD = false }),
    earthWall = Spell(198838, { ignoreFacing = true, ignoreMoving = true, radius = 10, ignoreGCD = false }),
    totemicProjection = Spell(108287, { ignoreMoving = true, ignoreGCD = true, ignoreFacing = true, radius = 3, ignoreLoS = false, CircleSteps = 12, DistanceSteps = 6 }),
    totemicProjectionEW = Spell(108287, { ignoreMoving = true, ignoreGCD = true, ignoreFacing = true, radius = 10, ignoreLoS = false, CircleSteps = 12, DistanceSteps = 6 }),
    totemicProjectionHT = Spell(108287, { ignoreMoving = true, ignoreGCD = true, ignoreFacing = true, radius = 4, ignoreLoS = false, CircleSteps = 12, DistanceSteps = 6 }),
    totemicProjectionSL = Spell(108287, { ignoreMoving = true, ignoreGCD = true, ignoreFacing = true, radius = 10, ignoreLoS = false, CircleSteps = 12, DistanceSteps = 6 }),
    totemicProjectionSFT = Spell(108287, { ignoreMoving = true, ignoreGCD = true, ignoreFacing = true, radius = 8, ignoreLoS = false, CircleSteps = 16, DistanceSteps = 9 }),
    earthGrab = Spell(51485, { ignoreMoving = true, effect = "magic", cc = "root", ignoreFacing = false, radius = 8, ignoreGCD = false }),
    capacitorTotem = Spell(192058, { targeted = false, ignoreMoving = true, cc = "stun", effect = "magic", ignoreFacing = true, ignoreFriends = true, diameter = 16, offsetMin = 0, offsetMax = 7, castById = true, ignoreGCD = false }),
    staticFieldTotem = Spell(355580, { effect = "magic", ignoreMoving = true, ignoreLoS = false, ignoreFriends = true, ignoreFacing = true, diameter = 16, CircleSteps = 12, DistanceSteps = 6, ignoreGCD = false }),
    counterStrikeTotem = Spell(204331, { beneficial = true, ignoreMoving = true, ignoreGCD = false } ),
    spiritLink = Spell(98008, { ignoreMoving = true, radius = 10, ignoreFacing = true, ignoreCasting = true, ignoreChanneling = true, ignoreGCD = false }),
    healingTide = Spell(108280, { beneficial = true, ignoreMoving = true, ignoreGCD = false, ignoreFacing = true, targeted = false }),
    surgingTotem = Spell(444995, { beneficial = true, ignoreMoving = true, radius = 10 }),
    tremorTotem = Spell(8143, { beneficial = true, ignoreMoving = true, ignoreCasting = true, ignoreFacing = true, ignoreChanneling = true, ignoreGCD = false }),
    wrathTotem = Spell(460697, { beneficial = true, ignoreMoving = true, ignoreGCD = false }),
    groundingTotem = Spell(204336, { beneficial = true, ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true, ignoreGCD = false })
}, restoration, getfenv(1))

local BurstCDS1 = {
    -- Death Knight
    [383269] = { uptime = 0.2, min = 2 }, -- Abomination Limb
    [51271]  = { uptime = 0.2, min = 2 }, -- Pillar of Frost
    [207289] = { uptime = 0.2, min = 2 }, -- Unholy Frenzy

    -- Demon Hunter
    [162264] = { uptime = 0.2, min = 2 }, -- Metamorphosis

    -- Druid
    [194223] = { uptime = 0.2, min = 2 }, -- Celestial Alignment
    [106951] = { uptime = 0.2, min = 2 }, -- Berserk
    [391528] = { uptime = 0.2, min = 2 }, -- Convoke the Spirits

    -- Evoker
    [375087] = { uptime = 0.2, min = 2 }, -- Dragonrage

    -- Hunter
    [266779] = { uptime = 0.2, min = 2 }, -- Coordinated Assault
    [288613] = { uptime = 0.2, min = 2 }, -- Trueshot
    [19574]  = { uptime = 0.2, min = 2 }, -- Bestial Wrath
    [359844] = { uptime = 0.2, min = 2 }, -- Call of the Wild

    -- Mage
    [365362] = { uptime = 0.2, min = 2 }, -- Arcane Surge
    [190319] = { uptime = 0.2, min = 2 }, -- Combustion
    [12472]  = { uptime = 0.2, min = 2 }, -- Icy Veins

    -- Monk
    [137639] = { uptime = 0.2, min = 2 }, -- Storm, Earth, and Fire
    [443028] = { uptime = 0.2, min = 2 }, -- Celestial Conduit

    -- Paladin
    [31884]  = { uptime = 0.2, min = 2 }, -- Avenging Wrath

    -- Priest
    [10060]  = { uptime = 0.2, min = 2 }, -- Power Infusion
    [194249] = { uptime = 0.2, min = 2 }, -- Voidform

    -- Rogue
    [13750]  = { uptime = 0.2, min = 2 }, -- Adrenaline Rush
    [121471] = { uptime = 0.2, min = 2 }, -- Shadow Blades
    [394758] = { uptime = 0.2, min = 2 }, -- Flagellation

    -- Shaman
    [114050] = { uptime = 0.2, min = 2 }, -- Ascendance
    [333957] = { uptime = 0.2, min = 2 }, -- Feral Spirit
    [191634] = { uptime = 0.2, min = 2 }, -- Stormkeeper
    [384352] = { uptime = 0.2, min = 2 }, -- Doom Winds

    -- Warlock
    [265273] = { uptime = 0.2, min = 2 }, -- Demonic Power
    [344566] = { uptime = 0.2, min = 2 }, -- Rapid Contagion
    [442726] = { uptime = 0.2, min = 2 }, -- Malevolence

    -- Warrior
    [107574] = { uptime = 0.2, min = 2 }, -- Avatar
    [1719]   = { uptime = 0.2, min = 2 }  -- Battle Cry
}

local BurstCDS2 = {
    -- Death Knight
    383269, -- Abomination Limb
    51271,  -- Pillar of Frost
    207289, -- Unholy Frenzy

    -- Demon Hunter
    162264, -- Metamorphosis

    -- Druid
    194223, -- Celestial Alignment
    106951, -- Berserk
    391528, -- Convoke the Spirits

    -- Evoker
    375087, -- Dragonrage

    -- Hunter
    266779, -- Coordinated Assault
    288613, -- Trueshot
    19574,  -- Bestial Wrath
    359844, -- Call of the Wild

    -- Mage
    365362, -- Arcane Surge
    190319, -- Combustion
    12472,  -- Icy Veins

    -- Monk
    137639, -- Storm, Earth, and Fire
    443028, -- Celestial Conduit

    -- Paladin
    31884,  -- Avenging Wrath

    -- Priest
    10060,  -- Power Infusion
    194249, -- Voidform

    -- Rogue
    13750,  -- Adrenaline Rush
    121471, -- Shadow Blades
    394758, -- Flagellation

    -- Shaman
    114050, -- Ascendance
    333957, -- Feral Spirit
    191634, -- Stormkeeper
    384352, -- Doom Winds

    -- Warlock
    265273, -- Summon Demonic Tyrant
    344566, -- Rapid Contagion
    442726, -- Malevolence

    -- Warrior
    107574, -- Avatar
    1719    -- Battle Cry
}

local enemyReflect = {
    23920, --spell reflect
}

local leaps = {
    [6544] = true,   -- Heroic Leap
    [36554] = true,  -- Shadowstep
    [1953] = true,   -- Blink
    [212653] = true, -- Shimmer
    [100] = true,    -- Charge
    [1850] = true,   -- Dash  
    [781] = true,    -- Disengage  
    [109132] = true, -- Roll   
    [2983] = true,   -- Sprint  
    [108273] = true, -- Wind Walk
    [196884] = true, -- Feral Lunge
    [190784] = true, -- Divine Steed
    [102401] = true, -- Wild Charge
}

local cantHex = {
    [768] = true,   -- Cat Form
    [5487] = true,  -- Bear Form
    [197625] = true, -- Moonkin Form
    [24858] = true, -- Moonkin Form (Balance specialization)
    [33891] = true -- Tree Form
}

local cleanseTable = {
    -- Major Crowd Control
    -- Polymorphs (Mage)
    [118] = { uptime = 0.2, min = 2 },      -- Polymorph (Sheep)
    [28271] = { uptime = 0.2, min = 2 },    -- Polymorph (Turtle)
    [28272] = { uptime = 0.2, min = 2 },    -- Polymorph (Pig)
    [61305] = { uptime = 0.2, min = 2 },    -- Polymorph (Black Cat)
    [61721] = { uptime = 0.2, min = 2 },    -- Polymorph (Rabbit)
    [61780] = { uptime = 0.2, min = 2 },    -- Polymorph (Turkey)
    [126819] = { uptime = 0.2, min = 2 },   -- Polymorph (Porcupine)
    [161353] = { uptime = 0.2, min = 2 },   -- Polymorph (Polar Bear)
    [161354] = { uptime = 0.2, min = 2 },   -- Polymorph (Monkey)
    [161355] = { uptime = 0.2, min = 2 },   -- Polymorph (Penguin)
    [161372] = { uptime = 0.2, min = 2 },   -- Polymorph (Peacock)
    [277787] = { uptime = 0.2, min = 2 },   -- Polymorph (Direhorn)
    [277792] = { uptime = 0.2, min = 2 },   -- Polymorph (Bumblebee)
    [321395] = { uptime = 0.2, min = 2 },   -- Polymorph (Mawrat)
    [391622] = { uptime = 0.2, min = 2 },   -- Polymorph (Duck)

    -- Hexes (Shaman)
    [51514] = { uptime = 0.2, min = 2 },    -- Hex (Frog)
    [210873] = { uptime = 0.2, min = 2 },   -- Hex (Compy)
    [211004] = { uptime = 0.2, min = 2 },   -- Hex (Spider)
    [211010] = { uptime = 0.2, min = 2 },   -- Hex (Snake)
    [211015] = { uptime = 0.2, min = 2 },   -- Hex (Cockroach)
    [269352] = { uptime = 0.2, min = 2 },   -- Hex (Skeletal Hatchling)
    [277778] = { uptime = 0.2, min = 2 },   -- Hex (Zandalari Tendonripper)
    [277784] = { uptime = 0.2, min = 2 },   -- Hex (Wicker Mongrel)
    [309328] = { uptime = 0.2, min = 2 },   -- Hex (Living Honey)

    -- Fears and Disorients
    [8122] = { uptime = 0.2, min = 2 },     -- Psychic Scream (Priest)
    [5484] = { uptime = 0.2, min = 2 },     -- Howl of Terror (Warlock)
    [118699] = { uptime = 0.2, min = 2 },   -- Fear (Warlock)
    [5782] = { uptime = 0.2, min = 2 },     -- Fear (Warlock)
    [6789] = { uptime = 0.2, min = 2 },     -- Mortal Coil (Warlock)
    [6358] = { uptime = 0.2, min = 2 },     -- Seduction (Warlock Pet)
    [31661] = { uptime = 0.2, min = 2 },    -- Dragon's Breath (Mage)
    [105421] = { uptime = 0.2, min = 2 },   -- Blinding Light (Paladin)
    [10326] = { uptime = 0.2, min = 2 },    -- Turn Evil (Paladin)
    [360806] = { uptime = 0.2, min = 2 },   -- Sleep Walk (Evoker)
    [1513] = { uptime = 0.2, min = 2 },     -- Scare Beast (Hunter)

    -- Incapacitates
    [20066] = { uptime = 0.2, min = 2 },    -- Repentance (Paladin)
    [217832] = { uptime = 0.2, min = 2 },   -- Imprison (Demon Hunter)
    [710] = { uptime = 0.2, min = 2 },      -- Banish (Warlock)
    [198909] = { uptime = 0.2, min = 2 },   -- Song of Chi-ji (Monk)

    -- Roots and Snares
    [122] = { uptime = 0.2, min = 2 },      -- Frost Nova (Mage)
    [82691] = { uptime = 0.2, min = 2 },    -- Ring of Frost (Mage)
    [228600] = { uptime = 0.2, min = 2 },   -- Ice Nova (Mage)
    [339] = { uptime = 0.2, min = 2 },      -- Entangling Roots (Druid)
    [102359] = { uptime = 0.2, min = 2 },   -- Mass Entanglement (Druid)
    [64695] = { uptime = 0.2, min = 2 },    -- Earthgrab (Shaman)
    [393456] = { uptime = 0.2, min = 2 },   -- Entrapment (Hunter)
    [212638] = { uptime = 0.2, min = 2 },   -- Tracker's Net (Hunter)
    [356738] = { uptime = 0.2, min = 2 },   -- Earth Unleashed (Shaman)
    [285515] = { uptime = 0.2, min = 2 },   -- Surge of Power (Shaman)

    -- Silences and Interrupts
    [15487] = { uptime = 0.2, min = 2 },    -- Silence (Priest)
    [47476] = { uptime = 0.2, min = 2 },    -- Strangulate (Death Knight)
    [204490] = { uptime = 0.2, min = 2 },   -- Sigil of Silence (Demon Hunter)

    -- Offensive Debuffs
    [375901] = { uptime = 0.2, min = 2 },   -- Mind Games (Priest)
    [386997] = { uptime = 0.2, min = 2 },   -- Soul Rot (Warlock)
    [383005] = { uptime = 0.2, min = 2 },   -- Chrono Loop (Evoker)
    [411038] = { uptime = 0.2, min = 2 },   -- Sphere of Despair (Monk)
    [385408] = { uptime = 0.2, min = 2 },   -- Sepsis (Rogue)
    [390612] = { uptime = 0.2, min = 2 },   -- Frost Bomb (Mage)

    -- Curses
    [702] = { uptime = 0.2, min = 2 },      -- Curse of Weakness (Warlock)
    [1714] = { uptime = 0.2, min = 2 },     -- Curse of Tongues (Warlock)

    -- Utility/Control
    [372048] = { uptime = 0.2, min = 2 },   -- Oppressing Roar (Evoker - Increases CC duration)
    [356824] = { uptime = 0.2, min = 2 },   -- Water Unleashed (Shaman - Reduces damage/healing)
    [209749] = { uptime = 0.2, min = 2 },   -- Faerie Swarm (Druid)
    [410065] = { uptime = 0.2, min = 2 },   -- Reactive Resin (Druid)
    [2812] = { uptime = 0.2, min = 2 },     -- Denounce (Paladin)
    [410201] = { uptime = 0.2, min = 2 },   -- Searing Glare (Paladin)
}

local purgeTable = {
    [342246] = { uptime = 0.2, min = 2 }, -- Alter Time
    [31821] = { uptime = 0.2, min = 2 }, -- Aura Mastery
    [305497] = { uptime = 0.2, min = 2 }, -- Thorns
    [114108] = { uptime = 0.2, min = 2 }, -- Soul of the Forest
    [132158] = { uptime = 0.2, min = 2 }, -- Nature's Swiftness
    [378464] = { uptime = 0.2, min = 2 }, -- Nullifying Shroud
    [29166] = { uptime = 0.2, min = 2 }, -- Innervate
    [269279] = { uptime = 0.2, min = 2 }, -- Tip the Scales
    [10060] = { uptime = 0.2, min = 2 }, -- Power Infusion
    [2825] = { uptime = 0.2, min = 2 }, -- Bloodlust
    [204018] = { uptime = 0.2, min = 2 }, -- Blessing of SpellWarding
    [1022] = { uptime = 0.2, min = 2 }, -- Blessing of Protection
    [213610] = { uptime = 0.2, min = 2 },  -- Holy Ward  
    [387801] = { uptime = 0.2, min = 2 } -- Echoing Blessings
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
    33786,  -- Cyclone
    45438,  -- Ice Block
    642,    -- Divine Shield
    186265, -- Aspect of the Turtle
    221527, -- Imprison
    710,    -- Banish
    203340, -- Diamond Ice
    362486, -- Tranquility PVP Talent
    31224,  -- Cloak of shadows
    79811,  -- Dispersion
    47585,  -- Dispersion
    196555, -- Netherwalk
    212295, -- Nether ward
    215769, -- Spirit of Redemption
    421453, -- Ultimate Penitence
    228049, -- Guardian of the Forgotten Queen
    409293, -- Burrow
    378441,  -- Time Stop
    328530  -- Divine Ascension (Up)
}

local cantCC = {
    79811,  -- Dispersion
    47585,  -- Dispersion
    215769, -- Spirit Of Redemption
    421453,  -- Ultimate Penitence
    6940,   -- Blessing of Sacrifice
    196555, -- NetherWalk
    45438,  -- Ice Block
    409293, -- Burrow
    362486, -- Tranquility PVP Talent
    210256, -- Sanc
    408558, -- Phase Shift
    48707,  -- Anti-Magic Shell (Death Knight - immunity to magic CC)
    31224,  -- Cloak of Shadows (Rogue - immunity to magic CC)
    47585,  -- Dispersion (Priest - immunity to CC)
    378464, -- Nullifying Shroud (Evoker - immunity to CC)
    377362, -- Precognition (Evoker - immunity to CC)
    213610, -- Holy Ward (Priest - immunity to CC)
    227847, -- Bladestorm (Warrior - immunity to CC)
    8178,   -- Grounding Totem (Shaman - redirects spells, effectively CC immunity)
    1022,   -- Blessing of Protection (Paladin - immunity to physical CC)
    204018, -- Blessing of Spellwarding (Paladin - immunity to magic CC)
    23920,  -- Spell Reflection (Warrior - reflects spells, effectively CC immunity)
    248519, -- Interlope (Hunter - immunity to magic CC)
    202248, -- Guided Meditation (Monk - immunity to magic CC)
    353319, -- Peaceweaver (Monk - immunity to magic CC, except Mindgames)
    212295, -- Nether Ward (Warlock - immunity to magic CC)
    354610, -- Glimpse (Demon Hunter - immunity to CC)
    357210, -- Deep Breath (Evoker - immunity to CC, with Maneuverability talent)
    359816, -- Dream Flight (Evoker - immunity to CC)
    213664, -- Nimble Brew (Monk - immunity to CC)
    269513, -- Death from Above (Rogue - immunity to CC)
    209584, -- Zen Focus Tea (Monk - immunity to silences and interrupts)
    377362  -- Precognition (Evoker - immunity to CC)
}

local groundingTable = {
    [357210] = true, -- Deep Breath
    [49576] = true, -- Death Grip
    [190925] = true, -- Harpoon
    [19577] = true, -- Intimidation
    [3355] = true,    -- Freezing Trap
    [190319] = true, -- Combustion
    [102560] = true, -- Incarnation: Chosen of Elune
    [370965] = true, -- The Hunt
    [116858] = true, -- Chaos Bolt
    [199786] = true, -- Glacial Spike
    [359073] = true, -- Eternity Surge (Rank 1)
    [359074] = true, -- Eternity Surge (Rank 2)
    [359075] = true, -- Eternity Surge (Rank 3)
    [203340] = true, -- Diamond Ice Trap
    [428332] = true, -- Primordial Wave
    [114051] = true, -- Ascendance
    [114050] = true, -- Ascendance
}

local groundingTable2 = {
    [357210] = true, -- Deep Breath
    [49576] = true, -- Death Grip
    [190925] = true, -- Harpoon
    [19577] = true, -- Intimidation
    [3355] = true,    -- Freezing Trap
    [190319] = true, -- Combustion
    [102560] = true, -- Incarnation: Chosen of Elune
    [370965] = true, -- The Hunt
    [116858] = true, -- Chaos Bolt
    [199786] = true, -- Glacial Spike
    [359073] = true, -- Eternity Surge (Rank 1)
    [359074] = true, -- Eternity Surge (Rank 2)
    [359075] = true, -- Eternity Surge (Rank 3)
    [203340] = true, -- Diamond Ice Trap
    [428332] = true, -- Primordial Wave
    [114051] = true, -- Ascendance
    [114050] = true, -- Ascendance
}

function project.resetFlags()
    INTEnemy = nil
    MoveInterrupt = math.huge
    MoveTide = math.huge
    MoveHealer = math.huge
    MoveLowHP = math.huge
    MovePeel = math.huge
    MoveHealer = math.huge
    MoveInterrupt = math.huge
    CastedGrounding = math.huge
end

local function maxStaticMove()
    local modifier = 1
    if IsPlayerSpell(382201) then
        modifier = modifier + 0.15
    end
    if IsPlayerSpell(445026) then
        modifier = modifier + 0.15
    end

    local actualRadius = 7 * modifier
    local maxMoveDistance = actualRadius * 2

    return actualRadius, maxMoveDistance
end

local function maxEwMove()
    local modifier = 1
    if IsPlayerSpell(382201) then
        modifier = modifier + 0.15
    end
    if IsPlayerSpell(445026) then
        modifier = modifier + 0.15
    end

    local actualRadius = 10 * modifier
    local maxMoveDistance = actualRadius * 2

    return actualRadius, maxMoveDistance
end

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

function QueueAlertAndAccept()
    if project.settings.autoaccept then
        local battlefieldStatus = GetBattlefieldStatus(1)
        if battlefieldStatus == "confirm" then
            awful.call("AcceptBattlefieldPort", 1, true)
        end
    end
end

if project.settings.autoaccept then
    awful.addUpdateCallback(QueueAlertAndAccept)
end

function grabFlag()
    if not project.settingsgrabFlag then return end
    local flag = awful.objects.find(function(obj) return obj.id == 227741 or obj.id == 227740 or obj.id == 227745 end)
    if select(2, IsInInstance()) == "pvp" then
        if flag then
            local distance = flag.distance
            if distance <= 10 then
                if Unlocker.type == "daemonic" then
                    return Interact(flag.pointer)
                else
                    return ObjectInteract(flag.pointer)
                end
            end
        end
    end
end

function project.cd(spellObject)
    local gcd = 0
    if spellObject and spellObject.gcd > 0 then
        gcd = awful.gcdRemains
    end
    return spellObject.cooldown - gcd
end

awful.onEvent(function(info, event, source, dest)
    -- Extract spellID from the info table
    local spellID = select(12, unpack(info))

    -- Early returns for invalid conditions
    if not project.isInValidInstance() then return end
    if not player.hasTalent(groundingTotem.id) then return end
    if groundingTotem.cd > awful.gcd then return end
    if event ~= "UNIT_SPELLCAST_START" then return end
    if not source.enemy or not dest.isUnit(player) then return end

    -- Ensure spellID is a valid number before comparing
    if not spellID or type(spellID) ~= "number" then return end

    -- Check if the spellID is in groundingTable2 and Grounding Totem is off cooldown
    if groundingTable2[spellID] and groundingTotem.cd < awful.gcd then
        return groundingTotem:Cast() and alert("Grounding Totem | " .. colors.red .. "Emergency", groundingTotem.id, true)
    end
end)

awful.addEventCallback(function(eventinfo, event, source, dest)
    local spellID = select(12, unpack(eventinfo))
    if not project.isInValidInstance() then return end
    if not player.hasTalent(groundingTotem.id) then return end
    if project.cd(groundingTotem) > 0 then return end
    if event ~= "UNIT_SPELLCAST_START" or event ~= "SPELL_CAST_SUCCESS" then return end
    if source == nil then return end
    if not source.enemy then return end
    if spellID == 187650 or spellID == 203340 then
        return groundingTotem:Cast() and alert("Grounding Totem | " .. colors.red .. "Trap", spell.id, true)
    end
end)

local MissileCCs = {
    [187650] = true, -- Freezing Trap
    [6789] = true,   -- Mortal Coil
}

local MissileCCs2 = {
    [203340] = true, -- Diamond Ice Trap
}

awful.addActualUpdateCallback(function()
        -- Pre-HoJ detection
        awful.enemies.loop(function(enemy)
            if project.cd(groundingTotem) > 0 then return end
            if enemy.class2 == "PALADIN" 
            and enemy.cooldown(853) <= 1
            and enemy.gcdRemains <= 0.8 
            and enemy.facing(player)
            and player.sdr >= 0.5
            and (enemy.predictDistance(0.8, player) <= 12 or enemy.distanceTo(player) <= 12) then
                if groundingTotem.current then return end
                SpellCancelQueuedSpell()
                awful.alert("Cancelling Queued Spell for Pre-HoJ Ground")
                return
            end
        end)

        -- Pre-Fear detection
        awful.enemies.loop(function(enemy)
            if project.cd(tremorTotem) > 0 then return end
            if enemy.class2 == "PRIEST" 
            and enemy.cooldown(8122) <= 1
            and enemy.gcdRemains <= 0.8 
            and enemy.facing(player)
            and player.ddr >= 0.5
            and (enemy.predictDistance(0.8, player) <= 10 or enemy.distanceTo(player) <= 10) then
                if tremorTotem.current then return end
                SpellCancelQueuedSpell()
                awful.alert("Cancelling Queued Spell for Pre-Fear Tremor") 
                return
            end
        end)
end)

function project.Lowest()
    project.LowestHealth = 100
    project.LowestUnit = player
    project.LowestPetHealth = 100
    project.LowestPetUnit = player
    project.SecondLowestHealth = 100
    project.SecondLowestUnit = player
    project.LowestActualHealth = 200000
    project.LowestActualUnit = nil
    local badDebuff = { 33786, 207736, 203337, 221527 } -- cyclone, duel, ?, ?
    local badBuff = { 342245, 215769 }                  -- alter time, spirit of redemption
    awful.fullGroup.loop(function(unit, i, uptime)
        if not unit.dead then
            if not unit.charmed and not unit.debuffFrom(badDebuff) and not unit.buffFrom(badBuff) then
                if unit.distance <= 40 then
                    if unit.los then
                        if unit.hp < project.LowestHealth then
                            project.SecondLowestHealth = project.LowestHealth
                            project.SecondLowestUnit = project.LowestUnit
                            project.LowestHealth = unit.hp
                            project.LowestUnit = unit
                        end
                        if unit.hp > project.LowestHealth and unit.hp < project.SecondLowestHealth then
                            project.SecondLowestHealth = unit.hp
                            project.SecondLowestUnit = unit
                        end
                        if not unit.isUnit(player) and unit.health < project.LowestActualHealth then
                            project.LowestActualHealth = unit.health
                            project.LowestActualUnit = unit
                        end
                    end
                end
            end
        end
    end)
end

burstTracker = {
    enemyBurst = false,
    burstTarget = nil,
    burstEnemy = nil,
    friendBurst = false,
    burstFriend = nil
}

hookCallbacks(function(spell)
    if not project.isInValidInstance() then return end
    burstTracker.enemyBurst = false 
    burstTracker.burstTarget = nil
    burstTracker.burstEnemy = nil
    burstTracker.friendBurst = false
    burstTracker.burstFriend = nil

    project.Lowest()

    -- Single enemy loop to detect burst
    awful.enemies.within(40).loop(function(enemy)
        if not enemy then return end
        if enemy.enemy and not enemy.dead and not enemy.pet then
            if enemy.used(BurstCDS1, 2) or enemy.buffFrom(BurstCDS2) or enemy.cds then
                if enemy.cc or enemy.bcc then return end
                burstTracker.enemyBurst = true
                burstTracker.burstEnemy = enemy
                if enemy.target and enemy.target.friend then
                    burstTracker.burstTarget = enemy.target
                end
            end
        end
    end)

    awful.fgroup.within(40).loop(function(friend)
        if not friend then return end
        if friend.friend and not friend.dead and not friend.pet then
            if friend.used(BurstCDS1, 2) or friend.buffFrom(BurstCDS2) or friend.cds then
                if friend.cc or friend.bcc then return end
                burstTracker.friendBurst = true
                burstTracker.burstFriend = friend
            end
        end
    end)
end)

awful.addUpdateCallback(function()
    if not project.isInValidInstance() then return end
    if not player.hasTalent(groundingTotem.id) then return end
    if project.cd(groundingTotem) > 0 then return end
    awful.missiles.track(function(missile)
        local aoe = MissileCCs[id]
        local aoe2 = MissileCCs2[id]
        local id = missile.spellId
        local missilecreator = awful.GetObjectWithGUID(missile.source)
        local hx, hy, hz = missile.hx, missile.hy, missile.hz
        if missile.source == nil then return end
        if missilecreator.friend then return end
        if missile.source.friendly then return end
        if missile.source.friend then return end

        if not id then return end
        if not aoe or aoe2 then return end

        return groundingTotem:Cast() and alert("Grounding Totem | " .. colors.red .. "Trap", spell.id, true)
    end)
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

function totemActive(spell)
    if not spell then return false, 0 end
    local up = false
    local duration = 0
    for i = 1, MAX_TOTEMS do
        local _, totemName, remains, uptime = GetTotemInfo(i)
        if totemName and totemName ~= "" and string.match(totemName, spell.name) then
            up = true
            duration = awful.time - remains - uptime
        end
    end
    return up, math.abs(duration)
end

function project.useMedallion()
    if not project.medallion.equipped or project.medallion2.equipped then return end
    if project.medallion:Usable() and player.hp < project.settings.md and project.medallion.cd < 1 then
        project.medallion:Use()
    end

    if project.medallion2:Usable() and player.hp < project.settings.md and project.medallion.cd < 1 then
        project.medallion2:Use()
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

function project.collectHealthstone()
    project.hasAttemptedCollection = false
    if project.healthStones.count >= 1 or project.hasAttemptedCollection then return end

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

function project.healthStone()
    if project.healthStones:Usable() and player.hp < project.settings.hst and project.healthStones.count >= 1 and project.healthStones.cd < 1 then
        project.healthStones:Use()
    end
end

function project.stompTotems()
    local function homies(unit)
        return not unit.dead and not unit.pet
    end

    local lowest = awful.fgroup.within(40).filter(homies).lowest
    if not lowest.friend then return end
    if lowest.hp < 50 then return end

    awful.totems.stomp(function(totem, uptime)
        if project.settings.stompsHigh[totem.id] then
            if uptime < 0.3 then return end
            if not totem.los then return end
            if totem.dead then return end
            if not player.facing(totem) then return end
            if totem.dist > 40 then return end
            if flameShock:Castable(totem) and project.cd(flameShock) <= 0 then flameShock:Cast(totem) end
            if lavaBurst:Castable(totem) and project.cd(lavaBurst) <= 0 then lavaBurst:Cast(totem) end
            return
        end


        if project.settings.stomps[totem.id] then
            if uptime < 0.3 then return end
            if not totem.los then return end
            if totem.dead then return end
            if totem.dist > 40 then return end
            if not player.facing(totem) then return end
            if flameShock:Castable(totem) and project.cd(flameShock) <= 0 then flameShock:Cast(totem) end
            if lavaBurst:Castable(totem) and project.cd(lavaBurst) <= 0 then lavaBurst:Cast(totem) end
            return
        end
    end)
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
    if not unit1.exists or unit1 == nil then
        return false
    end

    if not unit2.exists or unit2 == nil then
        return false
    end

    return project.getLosTraceLine(unit1, unit2)
end

function project.frostStomp()
    if not frostShock.known then return end
    local function homies(unit)
        return not unit.dead and not
            unit.pet
    end

    local lowest = awful.fgroup.within(40).filter(homies).lowest
    if not lowest.friend then return end
    if lowest.hp < 50 then return end

    awful.totems.stomp(function(totem, uptime)
        if project.settings.stompsHigh[totem.id] then
            if uptime < 0.3 then return end
            if not totem.los then return end
            if totem.dead then return end
            if totem.dist > frostShock.range then return end
            if not frostShock:Castable(totem) then return end
            if project.cd(frostShock) > 0 then return end
            return frostShock:Cast(totem)
        end

        if project.settings.stomps[totem.id] then
            if uptime < 0.3 then return end
            if not totem.los then return end
            if totem.dead then return end
            if totem.dist > frostShock.range then return end
            if not frostShock:Castable(totem) then return end
            if project.cd(frostShock) > 0 then return end
            return frostShock:Cast(totem)
        end
    end)
end

function project.hexCancel()
    if player.casting and player.castID == hex.id and (player.castTarget.buffFrom(cantCC) or player.castTarget.buffFrom(cantHex) or player.castTarget.isbeast) then
        return awful.call("SpellStopCasting")
    end
end

skyFury:Callback(function(spell)
    if player.channel and player.channelid == lightningLasso.id then return end
    local function fury(unit)
        return
            not unit.buff(skyFury.id)
            and unit.friend
            and not unit.pet
            and not unit.dead
    end

    local noFury = awful.fgroup.within(spell.range).filter(fury)
    if #noFury < 1 then return end

    spell:Cast()
end)

surgingTotem:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if not IsPlayerSpell(445029) then return end -- Surging Totem Check (Not the spell ID of surging totem)
    local function homies(unit)
        return not unit.dead and
            not unit.pet
            and not unit.immuneHealing
            and unit.los
            and not unit.buff(healingRainBuff.id)
            and unit.hp <= project.settings.hr
            and not unit.moving
            and project.hasLosBehindIceWall(player, unit)
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    local x, y, z = lowest.predictPosition(0.5)
    return spell:AoECast(x, y, z)
end)

wrathTotem:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    local instanceType = select(2, IsInInstance())
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and project.combatCheck())) then return end
    if not player.hasTalent(wrathTotem.id) then return end

    local wtRange = 40 + bin(player.hasTalent(totemicFocus.id)) * 0.15

    if not (burstTracker.enemyBurst or burstTracker.friendBurst) then return end
    if burstTracker.enemyBurst and burstTracker.burstEnemy.dist > wtRange then return end
    if burstTracker.friendBurst and burstTracker.burstFriend.dist > wtRange then return end
    return spell:Cast()
end)

astralShift:Callback(function(spell)
    if player.channel and player.channelid == lightningLasso.id then return end
    if player.hp <= project.settings.astral then
        return spell:Cast()
    end
end)

earthElemental:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if not spell.known then return end
    if player.hp <= project.settings.ele then
        return spell:Cast()
    end
end)

earthLiving:Callback(function(spell)
    if not player.mainHandEnchant then
        return spell:Cast()
    end
end)

tideCallersGuard:Callback(function(spell)
    if not IsPlayerSpell(457481) then return end
    if not player.offHandEnchant then
        return spell:Cast()
    end
end)

preHot2:Callback(function()
    if not project.isInValidInstance() then return end

    local function isValidPreHotTarget(friend)
        return friend.player
            and friend.los
            and friend.hp == 100
            and not friend.combat
            and not friend.buff(ripTide.id, player)
    end

    local targetToBuff = nil
    awful.fgroup.within(40).loop(function(friend)
        if isValidPreHotTarget(friend) then
            targetToBuff = friend
            return true -- Exit the loop early once we find a valid target
        end
    end)

    if targetToBuff then
        return ripTide:Cast(targetToBuff)
    end
end)

preHot:Callback(function(spell)
    if spell.cd > awful.gcd then return end
    if not player.buff(383648) then
        return earthShield:Cast(player)
    end

    if not player.buff(52127) then
        return waterShield:Cast(player)
    end

    local foundRanged = false
    awful.group.within(spell.range).loop(function(friend)
        if not friend then return end
        if not friend.los then return end
        if friend.buff(974, player) then
            return true
        end

        if not friend.buff(974, player) and friend.role == "ranged" then
            earthShield:Cast(friend)
            foundRanged = true
            return true
        end

        if not foundRanged and not friend.buff(974, player) then
            earthShield:Cast(friend)
            return true
        end
    end)
end)

waterShield:Callback(function(spell)
    if project.LowestHealth <= 40 then return end
    if player.buffStacks(waterShield.id) > 2 then return end
    spell:Cast(player)
end)

thunderStorm:Callback("CC", function(spell)
    local holdGCD = false
    local aids = false
    if player.channel and player.channelID == lightningLasso.id then return end
    awful.enemies.within(30).loop(function(enemy)
        if (enemy.predictDistanceLiteral(0.8, player) <= 10 or enemy.distanceToLiteral(player) <= 10) and (enemy.los or enemy.predictLoS(0.6, player)) and player.ddr >= 0.5 then
            if totemActive(tremorTotem) then return end
            if project.cd(tremorTotem) > 0 and enemy.facing(player) then
                if enemy.class2 == "PRIEST" and enemy.cooldown(8122) <= 1 and enemy.gcdRemains <= 0.8 and not enemy.immuneMagic and not enemy.rooted then
                    aids = true
                    holdGCD = true
                end
            end
        end
        if (enemy.predictDistanceLiteral(0.8, player) <= 10 or enemy.distanceToLiteral(player) <= 10) and (enemy.los or enemy.predictLoS(0.6, player)) and player.sdr >= 0.5 then
            if project.cd(groundingTotem) > 0 and enemy.facing(player) then
                if enemy.class2 == "PALADIN" and enemy.cooldown(853) <= 1 and enemy.gcdRemains <= 0.8 and not enemy.immuneMagic and not enemy.rooted then
                    aids = true
                    holdGCD = true
                end
            end

            if (enemy.predictDistanceLiteral(0.8, player) <= 10 or enemy.distanceToLiteral(player) <= 10) and (enemy.los or enemy.predictLoS(0.6, player)) and player.ddr >= 0.5 then
                if project.cd(tremorTotem) > 0 and enemy.facing(player) then
                    if totemActive(tremorTotem) then return end
                    if enemy.class2 == "WARRIOR" and enemy.cooldown(5246) <= 1 and enemy.gcdRemains <= 0.8 and not enemy.immuneMagic and not enemy.rooted then
                        aids = true
                        holdGCD = true
                    end
                end
            end
        end
    end)

    if aids then
        spell:Cast()
    end

    return holdGCD
end)


thunderStorm:Callback(function(spell)
    -- Early returns
    if player.channel and player.channelID == lightningLasso.id then return end

    local function isCastingDangerous(enemy)
        if not (enemy.castID or enemy.channelID) then return false end

        local enemyCasting = (enemy.casting or enemy.channel) and (enemy.castID or enemy.channelID) and
            ((project.flatCC[enemy.castID] or project.flatCC[enemy.channelID]) and not player.immuneCC and enemy.castRemains <= 0.5 or
                (project.flatDam[enemy.castID] or project.flatDam[enemy.channelID]) and not player.buff(groundingTotem.id) and enemy.castRemains <= 0.5 or
                (project.flatHeals[enemy.castID] or project.flatHeals[enemy.channelID]) and enemy.castRemains <= 0.5)

        return enemyCasting
    end

    local function checkDangerousEnemies(unit, distance)
        local count = enemies.around(unit, distance, function(enemy)
            return enemy.distanceToLiteral(unit) <= 10
                and enemy.los
                and not enemy.immuneMagic
                and not enemy.rooted
                and not enemy.pet
                and not enemy.dead
                and isCastingDangerous(enemy)
        end)
        return count > 0
    end

    local function getMeleePressure(unit)
        local count = enemies.around(unit, 10, function(obj)
            return obj.los
                and obj.melee
                and obj.enemy
                and not obj.cc
                and not obj.bcc
                and not obj.immuneMagic
                and not obj.pet
                and not obj.rooted
        end)
        return count
    end

    -- Check for player thunderstorm
    local holdGCD = false
    local shouldCastOnSelf = false
    local shouldCastOnHomie = false

    awful.enemies.within(15).loop(function(enemy)
        if enemy.distanceToLiteral(player) <= 10 and enemy.los and not enemy.immuneMagic and not enemy.rooted then
            if player.stunned and enemy.class2 == "PRIEST" then
                shouldCastOnSelf = true
            end

            if isCastingDangerous(enemy) and player.stunned then
                shouldCastOnSelf = true
            end

            if isCastingDangerous(enemy) and windShear.cd > awful.gcd then
                if player.used(windShear.id, 0.3) then return end
                holdGCD = true
                shouldCastOnSelf = true
            end
        end
    end)

    -- Check melee pressure on player
    if player.stunned and getMeleePressure(player) >= 1 then
        shouldCastOnSelf = true
    end

    if shouldCastOnSelf then
        spell:Cast()
    end

    -- Check for ally thunderstorm if we have the talent
    if player.hasTalent(travelingStorms.id) then
        awful.friends.within(40).loop(function(friend)
            if friend.dead or friend.pet then return end

            if friend.stunned then
                -- Check for dangerous casts around friend
                if checkDangerousEnemies(friend, 15) then
                    holdGCD = true
                    shouldCastOnHomie = true
                end

                -- Check melee pressure on friend
                if getMeleePressure(friend) >= 1 then
                    holdGCD = true
                    shouldCastOnHomie = true
                end
            end

            -- Check for interrupt opportunity when Wind Shear is on CD
            if (windShear.cd > awful.gcd or groundingTotem.cd > awful.gcd or tremorTotem.cd > awful.gcd or player.cc) and checkDangerousEnemies(friend, 10) then
                holdGCD = true
                shouldCastOnHomie = true
            end

            if shouldCastOnHomie then
                spell:Cast()
            end
        end)
    end

    return holdGCD
end)

groundingTotem:Callback("preHoj", function(spell)
    local holdGCD = false
    local shouldCast = false
    local instanceType = select(2, IsInInstance())
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and project.combatCheck())) then return end
    local gRange = 30 + bin(player.hasTalent(totemicFocus.id)) * 0.15
    if spell.cd > awful.gcd then return end

    awful.enemies.within(gRange).loop(function(enemy)
        if enemy.class2 ~= "PALADIN" then return end
        if enemy.cooldown(853) > 1 then return end
        if player.sdr < 0.5 then return end
        if not enemy.facing(player) then return end
        if not (enemy.predictLoS(0.8, player) or enemy.los) then return end
        if enemy.gcdRemains > 0.8 then return end

        if (enemy.predictDistance(0.8, player) <= 10 or enemy.distanceTo(player) <= 10) then
            holdGCD = true
            shouldCast = true
        end

        if (enemy.predictDistance(0.8, player) <= 12 or enemy.distanceTo(player) <= 12) then
            holdGCD = true
        end
    end)

    if shouldCast then
        spell:Cast(player)
    end

    return holdGCD
end)

groundingTotem:Callback("CC", function(spell)
    local holdGCD = false

    -- Original logic: Calculate range and check instance type
    local gRange = 30 + bin(player.hasTalent(totemicFocus.id)) * 0.15
    local instanceType = select(2, IsInInstance())
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and project.combatCheck())) then return end
    if spell.cd > awful.gcd then return end

    awful.enemies.within(gRange).loop(function(enemy)
        -- Original logic: Check Wind Shear cooldown and enemy buffs
        if windShear.cd < awful.gcd and not (enemy.buff(preCog.id) or enemy.buff(378444) or enemy.casting8) then return end
        if enemy.debuff(windShear.id) then return end
        if player.lastCast == windShear.id then return end

        -- Check if the enemy is casting or channeling
        if not (enemy.casting or enemy.channeling) then return end

        -- Get the spell ID being cast or channeled
        local spellID = (enemy.casting and enemy.castID) or (enemy.channeling and enemy.channelID)
        if not spellID then return end

        -- Check if the spell is in the flatCC table
        local spellData = project.flatCC[spellID]
        if not spellData then return end

        -- NEW: Skip if the spell is AoE (using the new aoe flag)
        if spellData.aoe then return end

        -- Call the check function to determine if the spell should be grounded
        local shouldGround = spellData.check(enemy)
        if not shouldGround then return end

        -- Original logic: Check cast remains or channel time complete
        if (enemy.casting and enemy.castRemains <= castDelay.now) or (enemy.channeling and enemy.channelTimeComplete >= channelDelay.now) then
            if not groundingTotem:Castable() then return end
            if spell:Cast() then
                alert("Grounding Totem | " .. colors.red .. "CC", spell.id, true)
            end
        end

        -- Original logic: Hold GCD if the spell is still being cast or channeled
        if (enemy.casting and enemy.castTimeComplete >= 0.1) or (enemy.channeling and enemy.channelTimeComplete >= 0.1) then
            holdGCD = true
        end
    end)

    return holdGCD
end)

groundingTotem:Callback("Dam", function(spell)
    local holdGCD = false
    local gRange = 30 + bin(player.hasTalent(totemicFocus.id)) * 0.15
    local instanceType = select(2, IsInInstance())
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and project.combatCheck())) then return end
    if spell.cd > awful.gcd then return end

    awful.enemies.within(gRange).loop(function(enemy)
        if windShear.cd < awful.gcd and not (enemy.buff(preCog.id) or enemy.buff(378444) or enemy.casting8) then return end
        if enemy.debuff(windShear.id) then return end
        if player.lastCast == windShear.id then return end
        if not enemy.casting then return end
        if not (groundingTable[enemy.castID] or groundingTable[enemy.buff]) then return end

        if enemy.castTimeComplete >= 0.1 then
            holdGCD = true
        end

        if enemy.castRemains <= castDelay.now then
            if not groundingTotem:Castable() then return end
            if spell:Cast() then
                alert("Grounding Totem | " .. colors.red .. "Damage", spell.id, true)
            end
        end
    end)
    return holdGCD
end)

CastedGrounding = math.huge

groundingTotem:Callback("interrupt", function(spell)
    local gRange = 30 + bin(player.hasTalent(totemicFocus.id)) * 0.15
    local instanceType = select(2, IsInInstance())
    if spell.cd > awful.gcd then return end
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and project.combatCheck())) then return end

    local function homies(unit)
        if unit.dead then return false end
        if unit.pet then return false end
        return true
    end

    local lowest = awful.fgroup.within(gRange).filter(homies).lowest
    if not lowest.friend then return end

    if not project.settings.akg then return end

    if not player.canBeInterrupted(healingSurge.castTime) then return end
    if player.buff(spiritWalkersGrace.id) then return end
    if player.buff(naturesSwiftness.id) then return end
    if not player.buff(tidalWaves.id) then return end
    if player.buff(tidalWaves.id) and player.buffStacks(tidalWaves.id) < 2 + bin(player.hasTalent(443448)) then return end
    if lowest.hp > project.settings.hs then return end

    if spell:Cast() then
        CastedGrounding = awful.time + 1
    end
    CastedGrounding = math.huge
end)

counterStrikeTotem:Callback(function(spell)
    local instanceType = select(2, IsInInstance())
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and project.combatCheck())) then return end
    if player.channel and player.channelid == lightningLasso.id then return end
    if not player.hasTalent(counterStrikeTotem.id) then return end
    local csRange = 20 + bin(player.hasTalent(totemicFocus.id)) * 0.15

    if burstTracker.enemyBurst then
    if player.distanceTo(burstTracker.burstEnemy) > spell.range then return end
    return spell:Cast() and alert("Counter Strike Totem | " .. colors.red .. "Burst", spell.id, true)
    end
end)

tremorTotem:Callback("pets", function(spell)
    local holdGCD = false
    awful.enemyPets.loop(function(pet)
        if not pet.enemy then return end
        if not pet.los then return end
        if not pet.casting then return end
        if not pet.castID == 119909 then return end
        if not pet.castTarget.isUnit(player) then return end
        if windShear.cd > awful.gcd then return end
        if pet.debuff(windShear.id) then return end
        if pet and pet.casttimecomplete >= 0.1 then
            holdGCD = true
        end

        if pet.castRemains <= 0.5 then
            spell:Cast()
        end
    end)
    return holdGCD
end)

windShear:Callback("pets", function(spell)
    local aids = false
    local nerd = nil
    if totemActive(tremorTotem) then return end
    awful.pets.loop(function(pet)
        if not windShear:Castable(pet) then return end
        if not pet.enemy then return end
        if not pet.los then return end
        if not pet.casting then return end
        if not pet.castID == 119909 then return end
        if not pet.castTarget.isUnit(player) then return end
        if pet.castRemains > 0.5 then return end
        if player.ddr < 0.5 then return end
        aids = true
        nerd = pet
    end)
    if not aids then return end
    return spell:Cast(nerd)
end)

-- Table of fear effects from cleanseTable
local fearDebuffs = {
    [8122] = true,     -- Psychic Scream (Priest)
    [5484] = true,     -- Howl of Terror (Warlock)
    [118699] = true,   -- Fear (Warlock)
    [5782] = true,     -- Fear (Warlock)
    [6789] = true,     -- Mortal Coil (Warlock)
    [6358] = true,     -- Seduction (Warlock Pet)
    [10326] = true,    -- Turn Evil (Paladin)
    [1513] = true,     -- Scare Beast (Hunter)
    [5246] = true      -- Intimidating Shoud (Warrior)
}

tremorTotem:Callback("friends", function(spell)
    local shouldCast = false
    local fearedCount = 0
    local ttRange = 30 + bin(player.hasTalent(totemicFocus.id)) * 0.15
    if spell.cd > awful.gcd then return end

    awful.fgroup.within(ttRange).loop(function(friend)
        if not friend then return end
        if friend.dead then return end
        
        -- Check for any fear debuffs
        for debuffID, _ in pairs(fearDebuffs) do
            if friend.debuff(debuffID) and friend.debuffRemains(debuffID) > 2 then
                fearedCount = fearedCount + 1
                
                -- Immediate cast if healer is feared
                if purifySpirit:Castable(friend) and fearedCount < 2 then
                    shouldCast = false
                    return true
                end
                
                -- Cast if multiple friends are feared
                if fearedCount >= 2 then
                    shouldCast = true
                    return true
                end
            end
        end
    end)

    if not shouldCast then return end
    return spell:Cast()
end)


tremorTotem:Callback("preTremor", function(spell)
    local holdGCD = false
    local shouldCast = false
    local ttRange = 30 + bin(player.hasTalent(totemicFocus.id)) * 0.15
    if spell.cd > awful.gcd then return end

    awful.enemies.within(30).loop(function(enemy)
        if enemy.class2 == "PRIEST" and player.ddr >= 0.5 and enemy.cooldown(8122) <= 1 and enemy.gcdRemains <= 0.8 and enemy.facing(player) then
            if (enemy.predictDistance(0.8, player) <= 8 or enemy.distanceTo(player) <= 8) and (enemy.predictLoS(0.5, player) or enemy.los) then
                holdGCD = true
                shouldCast = true
            end

            if (enemy.predictDistance(0.8, player) <= 10 or enemy.distanceTo(player) <= 10) and (enemy.predictLoS(0.5, player) or enemy.los) then
                holdGCD = true
            end
        elseif enemy.class2 == "WARRIOR" and player.ddr >= 0.5 and enemy.cooldown(5246) <= 1 and enemy.gcdRemains <= 0.8 and enemy.facing(player) then
            if (enemy.predictDistance(0.8, player) <= 10 or enemy.distanceTo(player) <= 10) and (enemy.predictLoS(0.5, player) or enemy.los) then
                holdGCD = true
                shouldCast = true
            end

            if (enemy.predictDistance(0.8, player) <= 12 or enemy.distanceTo(player) <= 12) and (enemy.predictLoS(0.5, player) or enemy.los) then
                holdGCD = true
            end
        end
    end)

    if shouldCast then
        spell:Cast()
    end

    return holdGCD
end)

local tremorIDs = {
    [5782] = true,  -- fear
    [360806] = true -- sleep walk
}

tremorTotem:Callback("casts", function(spell)
    local holdGCD = false
    local ttRange = 30 + bin(player.hasTalent(totemicFocus.id)) * 0.15
    if spell.cd > awful.gcd then return end
    awful.enemies.within(40).loop(function(enemy)
        if enemy.debuff(windShear.id) then return end
        if player.buff(groundingTotem.id) then return end
        if not enemy.los then return end
        if player.ddr < 0.5 then return end
        if enemy.casting and enemy.castRemains <= 0.5 and enemy.castTarget.isUnit(player) and tremorIDs[enemy.castID] then
            if windShear.cd < awful.gcd and not enemy.castint and enemy.dist <= windShear.range then return end
            if project.cd(groundingTotem) <= 0 and enemy.castRemains <= castDelay.now then return end
            holdGCD = true
            spell:Cast()
        end

        if enemy.casting and tremorIDs[enemy.castID] and enemy.castTarget.isUnit(player) and enemy.casttimecomplete >= 0.1 then
            if windShear.cd < awful.gcd and not enemy.castint and enemy.dist <= windShear.range then return end
            holdGCD = true
        end
    end)

    return holdGCD
end)

tremorTotem:Callback("sigil", function(spell)
    local aids = false
    local dh = awful.enemies.find(function(e) return e.class2 == "DEMON HUNTER" end)
    if spell.cd > awful.gcd then return end

    awful.areaTriggers.loop(function(trigger, uptime)
        if not dh then return end
        if trigger.id ~= 207684 then return end
        if uptime < 0.2 then return end
        local x, y, z = trigger.position()
        if player.distanceTo(x, y, z) > 8 then return end
        aids = true
    end)
    if not aids then return end
    return spell:Cast()
end)

earthGrab:Callback("peel", function(spell)
    local aids = false
    local nerd = nil
    local total, melee, _, cds = player.v2attackers()
    if spell.cd > awful.gcd then return end
    if player.channel and player.channelid == lightningLasso.id then return end

    awful.enemies.within(35).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        local total2, _, _, _ = enemy.v2attackers()
        if melee < 1 then return end
        if total2 >= 1 then return end
        if enemy.rdr < 0.5 then return end
        if not (enemy.predictLoS(0.5, player) or enemy.los) then return end
        if enemy.immuneMagic and enemy.magicEffectImmunityRemains > awful.gcdRemains then return end
        if enemy.immuneCC and enemy.ccImmunityRemains > awful.gcdRemains then return end
        if enemy.rooted and enemy.rootRemains > awful.gcdRemains then return end
        aids = true
        nerd = enemy
    end)
    if not aids then return end
    return spell:SmartAoE(nerd)
end)

earthGrab:Callback("losManagement", function(spell)
    local nerd = nil
    local aids = false
    local staticActive = totemActive(staticFieldTotem)
    if spell.cd > awful.gcd then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if staticActive then return end

    awful.enemies.within(35).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if not enemy.los then return end
        if enemy.losOf(enemyHealer) then return end
        if enemy.predictDistance(0.5) > spell.range then return end
        if enemy.rdr < 0.5 then return end
        if (enemy.cc and enemy.ccRemains > awful.gcdRemains) or (enemy.bcc and enemy.bccRemains > awful.gcdRemains) then return end
        aids = true
        nerd = enemy
    end)

    if aids then
        return spell:SmartAoE(nerd)
    end

    if enemyHealer and enemyHealer.exists then
        if not earthGrab:Castable(enemyHealer) then return end
        if not enemyHealer.los then return end
        if enemyHealer.predictDistance(0.5) > spell.range then return end
        if enemyHealer.rdr < 0.5 then return end
        if (enemyHealer.cc and enemyHealer.ccRemains > awful.gcdRemains) or (enemyHealer.bcc and enemyHealer.bccRemains > awful.gcdRemains) then return end

        local healerInLOS = false
        awful.enemies.within(35).loop(function(enemy)
            if enemyHealer.losOf(enemy) then
                healerInLOS = true
            end
        end)

        if not healerInLOS then
            if not project.hasLosBehindIceWall(player, enemyHealer) then return end
            return spell:SmartAoE(enemyHealer)
        end
    end
end)


earthGrab:Callback("burstMelee", function(spell)
    local staticActive = totemActive(staticFieldTotem)
    local nerd = nil

    if spell.cd > awful.gcd then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if staticActive then return end

    if burstTracker.enemyBurst then
    if not project.hasLosBehindIceWall(player, burstTracker.burstEnemy) then return end
    local total, _, _, _ = burstTracker.burstEnemy.v2attackers()
    if total >= 1 then return end
    if burstTracker.burstEnemy.role ~= "melee" then return end
    if burstTracker.burstEnemy.predictDistance(0.5) > spell.range then return end
    if burstTracker.burstEnemy.rdr < 0.5 then return end
    if not (burstTracker.burstEnemy.predictLoS(0.5, player) or burstTracker.burstEnemy.los) then return end
    if (burstTracker.burstEnemy.cc and burstTracker.burstEnemy.ccRemains > awful.gcdRemains) or (burstTracker.burstEnemy.bcc and burstTracker.burstEnemy.bccRemains > awful.gcdRemains) then return end
    return spell:SmartAoE(burstTracker.burstEnemy)
    end
end)

earthGrab:Callback("enemyHealer", function(spell)
    local aids = false
    local staticActive = totemActive(staticFieldTotem)
    if player.channel and player.channelID == lightningLasso.id then return end
    if staticActive then return end
    if not enemyHealer.exists then return end
    awful.enemies.within(35).loop(function(enemyHealer)
        if not project.hasLosBehindIceWall(player, enemyHealer) then return end
        if not earthGrab:Castable(enemyHealer) then return end
        if not enemyHealer.los then return end
        if enemyHealer.rdr < 0.5 then return end
        if enemyHealer.distance > spell.range then return end
        if (enemyHealer.cc and enemyHealer.ccRemains > awful.gcdRemains) then return end
        if (enemyHealer.bcc and enemyHealer.bccRemains > awful.gcdRemains) then return end
        if enemyHealer.exists and enemyHealer.playerFacing and enemyHealer.movingToward(player, { angle = 180, duration = 0.5 }) and enemyHealer.distanceTo(player) <= 12 then
            aids = true
        end
    end)
    if not aids then return end
    return spell:SmartAoE(enemyHealer)
end)

earthGrab:Callback("leaps", function(spell)
    if player.channel and player.channelid == lightningLasso.id then return end
    awful.enemies.within(35).loop(function(enemy)
        for spellID, _ in pairs(leaps) do
            if not project.hasLosBehindIceWall(player, enemy) then return end
            if not enemy.used(spellID, 1) then return end
            if not (enemy.predictLoS(0.5, player) or enemy.los) then return end
            if enemy.predictDistance(0.5) > spell.range then return end
            if enemy.rooted and enemy.rootRemains > awful.gcdRemains then return end
            return spell:SmartAoE(enemy)
        end
    end)
end)

earthGrab:Callback("pets", function(spell)
    if spell.cd > awful.gcd then return end

    -- Track active bursts
    local bmBurst = false
    local dkBurst = false

    awful.enemies.within(40).loop(function(enemy)
        if enemy.class2 == "HUNTER" then
            if enemy.buff(19574) or enemy.buff(359844) then -- Bestial Wrath or Call of the Wild
                bmBurst = true
            end
        elseif enemy.class2 == "DEATHKNIGHT" then
            if enemy.buff(42650) then -- Army of the Dead
                dkBurst = true
            end
        end
    end)

    -- Now check pets if we found burst windows
    if bmBurst then
        awful.enemyPets.within(spell.range).loop(function(enemy)
            if not project.hasLosBehindIceWall(player, enemy) then return end
            if enemy.bcc or enemy.cc then return end
            if enemy.rdr < 0.5 then return end

            return spell:SmartAoE(enemy, {
                filter = function(obj, estDist)
                    if obj.pet and obj.enemy and not obj.bcc and not obj.cc and obj.rdr >= 0.5 then
                        return estDist <= 8
                    end
                end,
                offsetMin = 0,
                offsetMax = 8
            })
        end)
    end

    if dkBurst then
        awful.enemyPets.within(spell.range).loop(function(enemy)
            if not project.hasLosBehindIceWall(player, enemy) then return end
            if enemy.bcc or enemy.cc then return end
            if pet.rdr < 0.5 then return end

            return spell:SmartAoE(enemy, {
                filter = function(obj, estDist)
                    if obj.pet and obj.enemy and not obj.bcc and not obj.cc and obj.rdr >= 0.5 then
                        return estDist <= 8
                    end
                end,
                offsetMin = 0,
                offsetMax = 8
            })
        end)
    end

    -- Demo Lock Tyrant - Direct cast
    awful.tyrants.loop(function(tyrant)
        if not project.hasLosBehindIceWall(player, tyrant) then return end
        if tyrant.bcc or tyrant.cc then return end
        if tyrant.rdr < 0.5 then return end
        return spell:Cast(tyrant)
    end)
end)


burrow:Callback(function(spell)
    local instanceType = select(2, IsInInstance())
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and project.combatCheck())) then return end
    if not player.hasTalent(burrow.id) then return end
    if player.hp < project.settings.burrow then
        return spell:Cast()
    end
end)

MovePeel = math.huge

staticFieldTotem:Callback("peel", function(spell)
    local aids = false
    local nerd = nil
    local instanceType = select(2, IsInInstance())
    local baseRadius = 7 + bin(IsPlayerSpell(382201)) * .15 + bin(IsPlayerSpell(445026)) * .15
    if spell.cd > awful.gcd then return end
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and project.combatCheck())) then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if player.hasTalent(totemicProjection.id) and not totemicProjection:Castable() then return end
    if totemActive(earthWall) then return end
    if totemActive(spiritLink) then return end

    local function homies(unit)
        return
            not unit.dead
            and not unit.pet
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end

        if burstTracker.enemyBurst and burstTracker.burstEnemy.melee then
            aids = true
            nerd = enemy
        end

        if (lowest.debuff(212182) or lowest.debuff(359053)) then -- smoke bomb
            aids = true
            nerd = enemy
        end

        if enemy.buff(196718) or enemy.buff(62618) or enemy.buff(116844) then -- darkness, --pw barrier, --ring of peace
            aids = true
            nerd = enemy
        end
    end)

    if not aids then return end
    if spell:SmartAoE(nerd, { offsetMin = 0, offsetMax = baseRadius }) then
        MovePeel = awful.time + 1
        return
    end
end)

MoveInterrupt = math.huge
INTEnemy = nil

staticFieldTotem:Callback("interrupt", function(spell)
    if spell.cd > awful.gcd then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if totemicProjection.cd > awful.gcd then return end
    local instanceType = select(2, IsInInstance())
    local baseRadius = 7 + bin(IsPlayerSpell(382201)) * .15 + bin(IsPlayerSpell(445026)) * .15
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and project.combatCheck())) then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if windShear.cd < awful.gcd and not (isLocked(enemy) or enemy.buff(preCog.id) or enemy.channel7 or enemy.castint) then return end
        if enemy and not (enemy.casting or enemy.channeling) then return end
        if enemy and not enemy.los then return end
        if enemy and not (project.flatCC[enemy.castID] or project.flatCC[enemy.channelID] and project.flatCC[enemy.channelID]) then return end
        if enemy and not (enemy.castTarget.isUnit(player)) then return end
        if (enemy.casttimecomplete < 0.1 or enemy.channelTimeComplete < 0.1) then return end
        if project.cd(groundingTotem) <= 0 and awful.gcdRemains <= enemy.castRemains then return end
        if groundingTotem.queued then return end
        if player.buff(groundingTotem.id) and player.buffRemains(groundingTotem.id) > enemy.castRemains + awful.buffer then return end
        if spell:SmartAoE(enemy, { offsetMin = 0, offsetMax = baseRadius }) then
            INTEnemy = enemy
            MoveInterrupt = awful.time + 1
            return
        end
    end)
end)

MoveHealer = math.huge

staticFieldTotem:Callback("enemyHealer", function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    local instanceType = select(2, IsInInstance())
    local baseRadius = 7 + bin(IsPlayerSpell(382201)) * .15 + bin(IsPlayerSpell(445026)) * .15
    local maxOffset = baseRadius * 2
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and project.combatCheck())) then return end
    if project.cd(staticFieldTotem) > 0 then return end
    if totemicProjection.cd > awful.gcd then return end
    if totemActive(earthWall) then return end
    if not enemyHealer.exists then return end
    if not project.hasLosBehindIceWall(player, enemyHealer) then return end

    local function filter(unit)
        return not unit.pet
            and not unit.dead
    end

    local lowest = awful.enemies.within(40).filter(filter).lowest
    if lowest.hp > 70 then return end

    if enemyHealer.rooted and enemyHealer.rootRemains > awful.gcdRemains + awful.buffer then return end
    if enemyHealer.bcc and enemyHealer.bccRemains > awful.gcdRemains + awful.buffer then return end
    if enemyHealer.cc and enemyHealer.ccRemains > awful.gcdRemains + awful.buffer then return end
    if enemyHealer.silenced and enemyHealer.silenceRemains > awful.gcdRemains + awful.buffer then return end

    if spell:SmartAoE(enemyHealer, { offsetMin = 0, offsetMax = maxOffset }) then
        MoveHealer = awful.time + 1
        return
    end
end)

totemicProjectionSFT:Callback("enemyHealer", function(spell)
    local staticActive, tuptime = totemActive(staticFieldTotem)
    local baseRadius = 7 + bin(IsPlayerSpell(382201)) * .15 + bin(IsPlayerSpell(445026)) * .15
    local minOffset = baseRadius * 1.5
    local maxOffset = baseRadius * 2
    local x, y, z = awful.GetBestPositionAwayFromEnemies({ range = maxRange, losPrio = true })
    if totemicProjection.cd > awful.gcd then return end
    if MoveHealer < awful.time then return end
    if player.recentlyCast(staticFieldTotem.id, castDelay.now) then return end
    if not staticActive then return end
    if tuptime < 0.3 then return end
    if not enemyHealer.exists then return end

    if spell:SmartAoE(x, y, z, { offsetMin = minOffset, offsetMax = maxOffset }) then
        alert("Static Field Totem | " .. colors.red .. "Relocate Enemy Healer", spell.id, true)
        MoveHealer = math.huge
        return
    end
end)


totemicProjectionSFT:Callback("interrupt", function(spell)
    local staticActive = totemActive(staticFieldTotem)
    local baseRadius = 7 + bin(IsPlayerSpell(382201)) * .15 + bin(IsPlayerSpell(445026)) * .15
    local minOffset = baseRadius * 1.8
    local maxOffset = baseRadius * 2
    if totemicProjection.cd > awful.gcd then return end
    if MoveInterrupt < awful.time then return end
    if not staticActive then return end
    if INTEnemy == nil then return end
    if spell:SmartAoE(INTEnemy, { offsetMin = minOffset, offsetMax = maxOffset }) then
        MoveInterrupt = math.huge
        INTEnemy = nil
    end
end)


totemicProjectionSFT:Callback("peel", function(spell)
    local staticActive = totemActive(staticFieldTotem)
    local baseRadius = 7 + bin(IsPlayerSpell(382201)) * .15 + bin(IsPlayerSpell(445026)) * .15
    local minOffset = baseRadius * 1.8
    local maxOffset = baseRadius * 2

    if player.channel and player.channelid == lightningLasso.id then return end
    if player.recentlyCast(staticFieldTotem.id, castDelay.now) then return end
    local function homies(unit)
        return not unit.dead and not
            unit.pet
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    if totemicProjection.cd > awful.gcd then return end
    if MovePeel < awful.time then return end
    if not staticActive then return end

    if player.losOfLiteral(enemyHealer) and enemyHealer.distanceTo(lowest) <= 16 then
        spell:SmartAoE(enemyHealer, { offsetMin = 0, offsetMax = maxOffset })
        MovePeel = math.huge
    else
        spell:SmartAoE(lowest, { offsetMin = minOffset, offsetMax = maxOffset })
        MovePeel = math.huge
        return
    end
end)

totemicProjectionHT:Callback("tide", function(spell)
    local tideActive = totemActive(healingTide)
    local earthenActive = totemActive(earthWall)
    local spiritActive = totemActive(spiritLink)

    if player.channel and player.channelID == lightningLasso.id then return end
    if MoveTide < awful.time then return end
    if totemicProjection.cd > awful.gcd then return end
    if not tideActive then return end
    if earthenActive then return end
    if spiritActive then return end

    local function homies(unit)
        return not unit.dead and not
            unit.pet and not
            unit.immuneHealing
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    local x, y, z = awful.GetBestPositionAwayFromEnemies({
        range = 15,
        losPrio = true,
        filter = function(px, py, pz)
            return lowest.distanceToLiteral(px, py, pz) <= 15
        end
    })

    if not (x and y and z) then return end

    if spell:AoECast(x, y, z) then
        MoveTide = math.huge
        return true
    end
end)


totemicProjectionEW:Callback("earthen", function(spell)
    local earthActive, tuptime = totemActive(earthWall)
    local maxMove = maxEwMove()

    local function homies(unit)
        return not unit.dead and not
            unit.pet and not
            unit.buff(earthWallBuff.id) and
            unit.enemiesattacking and
            unit.losLiteral and not
            unit.moving
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest

    if not lowest.friend then return end

    local total, _, _, _ = lowest.v2attackers()

    if totemicProjection.cd > awful.gcd then return end
    if not earthActive then return end
    if total < 1 then return end

    return spell:SmartAoE(lowest, { offsetMin = 2, offsetMax = maxMove })
end)


earthShield:Callback(function(spell)
    local shieldedFriend
    local shieldedFriendHp = 100

    if player.buff(unleashLife.id) then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if spell.cd > awful.gcd then return end

    local function homies(unit)
        return (not unit.buff(earthShield.id, player) or unit.buffStacks(earthShield.id) <= 3)
            and not
            unit.isUnit(player) and not
            unit.dead and not
            unit.pet and not unit.immuneHealing
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    awful.fgroup.within(spell.range).loop(function(friend)
        if not project.hasLosBehindIceWall(player, friend) then return end
        if not friend then return end
        if not friend.los then return end
        if friend.pet then return end
        if friend.dead then return end

        if friend.buff(974, player) and friend.buffStacks(974, player) > 2 then
            shieldedFriend = friend
            shieldedFriendHp = friend.hp
        end
    end)

    local healthThreshold = 15
    local friendToShield = lowest
    local lowestHp = lowest.hp or 100

    if friendToShield and friendToShield ~= shieldedFriend and (shieldedFriendHp - lowestHp) >= healthThreshold and friendToShield ~= awful.player and friendToShield.distance <= spell.range then
        return spell:Cast(friendToShield)
    end

    if player.hasTalent(383010) and (not player.buff(383648, player) or player.buffStacks(383648) <= 3) then
        return spell:Cast(player)
    end
end)

frostShock:Callback("melee", function(spell)
    if not spell.known then return end
    if spell.cd > awful.gcd then return end

    local function homies(unit)
        return not unit.dead and not unit.pet
    end

    local lowest = awful.fgroup.within(40).filter(homies).lowest
    if not lowest.friend then return end


    if player.channel and player.channelID == lightningLasso.id then return end
    if lowest.hp <= project.settings.dps then return end
    if player.lastCast == hex.id then return end

    awful.enemies.within(40).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if not enemy.cds and enemy.role == "melee" then return end
        if enemy.bcc then return end
        if enemy.rooted then return end
        if not enemy.los then return end
        if enemy.dist > 40 then return end
        if not enemy.playerFacing then return end
        return spell:Cast(enemy)
    end)
end)

frostShock:Callback("root", function(spell)
    if not spell.known then return end
    if player.channel and player.channelID == lightningLasso.id then return end

    local function homies(unit)
        return not unit.dead and not unit.pet
    end

    local lowest = awful.fgroup.within(40).filter(homies).lowest
    if not lowest.friend then return end


    if lowest.hp <= project.settings.dps then return end
    if player.lastCast == hex.id then return end

    awful.enemies.within(40).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if enemy.bcc and enemy.bccRemains > awful.gcdRemains then return end
        if enemy.rooted and enemy.rootRemains > awful.gcdRemains then return end
        if not enemy.los then return end
        if enemy.dist > 40 then return end
        if not enemy.playerFacing then return end
        return spell:Cast(enemy)
    end)
end)

frostShock:Callback("lowHP", function(spell)
    if not spell.known then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if spell.cd > awful.gcd then return end
    local function homies(unit)
        return not unit.pet and not
            unit.dead and not
            unit.bcc
    end

    local lowest = awful.fgroup.within(40).filter(homies).lowest
    if not lowest.friend then return end
    if lowest.hp < 50 then return end

    if lowest.hp <= project.settings.dps then return end
    if player.lastCast == hex.id then return end

    awful.enemies.within(40).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if enemy.hp > 40 then return end
        if enemy.bcc and enemy.bccRemains > awful.gcdRemains then return end
        if enemy.rooted and enemy.rootRemains > awful.gcdRemains then return end
        if not enemy.los then return end
        if enemy.dist > 40 then return end
        if not enemy.playerFacing then return end
        return spell:Cast(enemy)
    end)
end)

flameShock:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if spell.cd > awful.gcd then return end
    local aids = false
    local nerd = nil

    local function homies(unit)
        return not unit.pet and not
            unit.dead and
            unit.hp <= project.settings.dps
    end

    local lowest = awful.fgroup.within(40).filter(homies).lowest
    if lowest.friend then return end

    if player.lastCast == hex.id then return end
    awful.enemies.within(40).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if enemy.pet then return end
        if not enemy.los then return end
        if enemy.bcc then return end
        if enemy.rooted then return end
        if enemy.debuff(188389) then return end
        if enemy.predictDistance(0.5) > spell.range then return end
        if not enemy.playerFacing then return end
        aids = true
        nerd = enemy
    end)
    if not aids then return end
    return spell:Cast(nerd)
end)

lavaBurst:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if wasCasting[lavaBurst.id] then return end
    if player.moving then return end
    if spell.cd > awful.gcd then return end

    local friendBelowThreshold = false
    awful.fgroup.within(40).loop(function(friend)
        if not friend.pet and not friend.dead and friend.los and friend.hp <= project.settings.dps then
            friendBelowThreshold = true
            return true
        end
    end)

    if friendBelowThreshold then return end

    local function enemyFilter(unit)
        return not unit.pet
            and not unit.dead
            and lavaBurst:Castable(unit)
            and unit.los
            and not unit.bcc
            and not unit.cc
            and unit.playerFacing
            and project.hasLosBehindIceWall(player, unit)
    end

    local nerd = awful.enemies.within(40).filter(enemyFilter).lowest
    if not nerd.enemy then return end
    return spell:Cast(nerd)
end)

totemicRecall:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if spell.cd > awful.gcd then return end
    if (earthWall.prevgcd or player.used(earthWall.id, 2)) then
        return spell:Cast()
    end
end)

healingStream:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    local hsActive = totemActive(healingStream)
    local htActive = totemActive(healingTide)
    local hsRange = 40 + bin(player.hasTalent(totemicFocus.id)) * 0.15 -- totemic focus
    if spell.cd > awful.gcd then return end
    if spell.charges < 1 then return end

    local function homies(unit)
        return unit.los and not unit.pet and not unit.dead
    end

    local lowest = awful.fgroup.within(hsRange).filter(homies).lowest
    if not lowest.friend then return end

    if lowest.combat and healingStream.charges > 1 then
        return spell:Cast()
    end

    if hsActive and lowest.hp <= 40 and healingStream.charges >= 1 and (project.cd(naturesSwiftness) > 0 and not player.buff(naturesSwiftness.id)) then
        return spell:Cast()
    end

    if not htActive and project.cd(healingTide) > 0 and (burstTracker.enemyBurst or project.LowestHealth <= 40) and healingStream.charges >= 1 then
        return spell:Cast()
    end
end)


healingSurge:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if wasCasting[healingSurge.id] then return end
    if player.buff(naturesSwiftness.id) then return end
    if not (player.buff(tidalWaves.id) or player.buff(unleashLife.id) or player.buff(whirlingAir.id)) then return end
    if (player.buff(tidalWaves.id) and player.buffStacks(tidalWaves.id) < 2) then return end
    if spell.cd > awful.gcd then return end

    local function filter(unit)
        return
            unit.hp <= project.settings.hs
            and not unit.pet
            and not unit.dead
            and unit.los
            and project.hasLosBehindIceWall(player, unit)
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if lowest.hp <= project.settings.ns and project.cd(naturesSwiftness) <= 0 then return end

    if not lowest.friend then return end
    return spell:Cast(lowest)
end)

healingSurge:Callback("ground", function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if wasCasting[healingSurge.id] then return end
    if spell.cd > awful.gcd then return end
    if player.buff(naturesSwiftness.id) then return end
    if not (player.buff(tidalWaves.id) or player.buff(unleashLife.id) or player.buff(whirlingAir.id)) then return end
    if (player.buff(tidalWaves.id) and player.buffStacks(tidalWaves.id) < 2) then return end
    if CastedGrounding < awful.time then return end

    local function filter(unit)
        return not unit.pet
            and not unit.immuneHealing
            and unit.los
            and unit.hp <= project.settings.hs
            and project.hasLosBehindIceWall(player, unit)
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if not lowest.friend then return end
    return spell:Cast(lowest)
end)

naturesSwiftness:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end

    if not player.buff(unleashLife.id) then return end

    local function filter(unit)
        return unit.hp <= project.settings.ns and
            not unit.pet and
            not unit.dead and
            unit.los
            and project.hasLosBehindIceWall(player, unit)
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest

    if lowest.friend then
        return spell:Cast()
    end
end)


healingWave:Callback("cast", function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if wasCasting[healingWave.id] then return end
    if player.buff(naturesSwiftness.id) then return end
    if spell.cd > awful.gcd then return end

    local function filter(unit)
        return not unit.immuneHealing
            and not unit.dead
            and not unit.pet
            and unit.hp > project.settings.hs
            and unit.hp <= project.settings.hw
            and project.hasLosBehindIceWall(player, unit)
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if lowest.friend then
        return spell:Cast(lowest)
    end
end)

healingWaveNS:Callback("ns", function(spell)
    local holdGCD = false
    if player.channel and player.channelID == lightningLasso.id then return end
    if not player.buff(primordialWaveBuff.id) then return end
    if not player.buff(unleashLife.id) then return end
    if spell.cd > awful.gcd then return end


    local function filter(unit)
        return spell:Castable(unit)
            and not unit.immuneHealing
            and not unit.pet
            and unit.los
            and not unit.dead
            and project.hasLosBehindIceWall(player, unit)
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest

    if not lowest.friend then return end
    if project.badge and project.badge.equipped and project.project.cd(badge) <= 0 then
        project.badge:Use()
        naturesSwiftness:Cast(player)
        spell:Cast(lowest)
        return holdGCD
    elseif project.badge2 and project.badge2.equipped and project.project.cd(badge2) <= 0 then
        project.badge2:Use()
        naturesSwiftness:Cast(player)
        spell:Cast(lowest)
        return holdGCD
    else
        naturesSwiftness:Cast(player)
        spell:Cast(lowest)
        return holdGCD
    end
end)

ripTide:Callback(function(spell)
    if player.buff(primordialWaveBuff.id) then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if player.buff(naturesSwiftness.id) and player.buffRemains(naturesSwiftness.id) > awful.gcdRemains then return end
    if (project.cd(unleashLife) <= 0 and ripTide.charges <= 1) then return end

    local function filter(unit)
        return not unit.immuneHealing
            and unit.hp <= project.settings.rt
            and spell:Castable(unit)
            --and not unit.buff(ripTide.id, player)
            and unit.los
            and not unit.pet
            and project.hasLosBehindIceWall(player, unit)
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if lowest.friend then
        return spell:Cast(lowest)
    end
end)

ripTide:Callback("unleash", function(spell)
    if player.channel and player.channelid == lightningLasso.id then return end
    if ripTide.charges < 1 then return end
    if not ripTide:Castable(project.LowestUnit) then return end
    if not project.hasLosBehindIceWall(player, project.LowestUnit) then return end
    if project.LowestHealth < project.settings.ns and project.cd(naturesSwiftness) <= 0 then return end
    if project.LowestHealth > project.settings.rt then return end
    if project.LowestHealth <= project.settings.hs then return end
    if not player.buff(unleashLife.id) then return end
    return spell:Cast(project.LowestUnit)
end)

unleashLife:Callback(function(spell)
    if spell.cd > awful.gcd then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if not unleashLife:Castable(project.LowestUnit) then return end
    if not project.LowestUnit then return end
    if not project.hasLosBehindIceWall(player, project.LowestUnit) then return end
    if not project.LowestUnit.buff(ripTide.id) then return end
    if project.LowestHealth > (project.settings.rt or project.settings.hs) then return end
    if (ripTide.charges < 1 and ripTide.nextChargeCD > awful.gcdRemains) then return end
    if project.LowestHealth < project.settings.ns and project.cd(naturesSwiftness) <= 0 and player.hasTalent(primordialWave.id) and project.cd(primordialWave) <= 0 then return end
    return spell:Cast(project.LowestUnit)
end)


unleashLife:Callback("ns", function(spell)
    if player.channel and player.channelid == lightningLasso.id then return end
    if spell.cd > awful.gcd then return end
    --if not player.buff(primordialWaveBuff.id) then return end
    if not unleashLife:Castable(project.LowestUnit) then return end
    if not project.hasLosBehindIceWall(player, project.LowestUnit) then return end
    if player.hasTalent(primordialWave.id) and not (primordialWave.prevgcd or player.buff(primordialWaveBuff.id)) then return end
    if project.cd(naturesSwiftness) > 0 then return end
    if not project.LowestUnit then return end
    ancestralGuidance:Cast()
    return spell:Cast(project.LowestUnit)
end)

unleashLife:Callback("cast", function(spell)
    if spell.cd > awful.gcd then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if ripTide.charges >= 1 and not project.LowestUnit.buff(ripTide.id, player) then return end
    if primordialWave.cd <= 15 then return end

    local function filter(unit)
        return not unit.pet
            and unit.los
            and not unit.immuneHealing
            and unit.hp <= project.settings.hs
            and not (unit.hp <= project.settings.ns and project.cd(naturesSwiftness) <= 0)
            and project.hasLosBehindIceWall(player, unit)
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if lowest.friend then
        return spell:Cast(lowest)
    end
end)

earthWall:Callback("totemic", function(spell)
    if spell.cd > awful.gcd then return end
    if player.channel and player.channelID == lightningLasso.id then return end


    local function homies(unit)
        return not unit.pet and
            not unit.dead and
            unit.losLiteral and
            not (unit.hp <= project.settings.ns) and
            (project.cd(naturesSwiftness) <= 0)
    end


    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    if (totemicRecall.current or totemicRecall.prevgcd or player.used(totemicRecall.id, awful.gcd)) then
        return spell:SmartAoE(lowest, { offsetMin = 0, offsetMax = 10 })
    end
end)

earthWall:Callback("burst", function(spell)
    if spell.cd > awful.gcd then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if not project.LowestUnit.losLiteral then return end
    if project.cd(healingTide) <= 0 and not totemActive(healingTide) then return end
    if project.LowestUnit.distance > spell.range then return end
    if project.LowestHealth <= project.settings.ns and project.cd(naturesSwiftness) <= 0 then return end

    if burstTracker.enemyBurst then
        -- Use burst target if available, otherwise lowest
        local target = burstTracker.burstTarget or project.LowestUnit
        return spell:SmartAoE(target, { offsetMin = 0, offsetMax = 10 })
    end
end)

earthWall:Callback("lowHP", function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if project.LowestHealth > 50 then return end
    if not project.LowestUnit.losLiteral then return end
    if project.cd(healingTide) <= 0 and not totemActive(healingTide) then return end
    if project.LowestUnit.distance > spell.range then return end
    return spell:SmartAoE(project.LowestUnit, { offsetMin = 0, offsetMax = 10 })
end)

local rogueCDS = { 212182, 359053 } -- Smoke Bomb IDs

earthWall:Callback("bomb", function(spell)
    if (player.channel and player.channelID == lightningLasso.id) then return end

    local function homies(unit)
        return not unit.pet
            and not unit.dead
            and unit.debuffFrom(rogueCDS)
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    return spell:SmartAoE(lowest, { offsetMin = 0, offsetMax = 15 })
end)

primordialWave:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if project.cd(naturesSwiftness) > 0 then return end
    if project.cd(unleashLife) > 0 then return end
    if spell.cd > awful.gcd then return end

    local function WithoutRiptide(unit)
        return
            unit.los and
            not unit.pet and
            not unit.immuneHealing and
            not (unit.buff(ripTide.id, player)) and
            unit.hp <= project.settings.ns
            and project.hasLosBehindIceWall(player, unit)
    end

    -- First try to find lowest HP unit without Riptide
    local NoRiptide = awful.fgroup.within(spell.range).filter(WithoutRiptide).lowest

    -- If we found a valid target without Riptide, use them
    if NoRiptide.friend then
        if bloodFury.known and project.cd(bloodFury) <= 0 then
            bloodFury:Cast()
            return spell:Cast(NoRiptide)
        else
            return spell:Cast(NoRiptide)
        end
    end

    -- Fallback filter that accepts units with Riptide
    local function WithRiptide(unit)
        return
            unit.los and
            not unit.pet and
            not unit.immuneHealing and
            unit.hp <= project.settings.ns
            and project.hasLosBehindIceWall(player, unit)
    end

    -- If no target without Riptide, find lowest HP unit including those with Riptide
    local lowestAny = awful.fgroup.within(spell.range).filter(WithRiptide).lowest

    if lowestAny.friend then
        if bloodFury.known and project.cd(bloodFury) <= 0 then
            bloodFury:Cast()
            return spell:Cast(lowestAny)
        else
            return spell:Cast(lowestAny)
        end
    end
end)

poisonTotem:Callback(function(spell)
    local holdGCD = false
    local shouldCast = false
    if spell.cd > awful.gcd then return end
    if not player.hasTalent(poisonTotem.id) then return end
    if player.channel and player.channelid == lightningLasso.id then return end

    -- Get hunter target with Chimaeral Sting
    if player.debuff(356723) then
        holdGCD = true
        shouldCast = true
    end

    -- Check for Assassination Rogue burst
    awful.enemies.within(40).loop(function(enemy)
        if enemy.class2 == "ROGUE" and enemy.used(360194, 3) then -- Deathmark
            holdGCD = true
            shouldCast = true
        end
    end)

    awful.fgroup.within(40).loop(function(friend)
        if friend.pet then return end
        if friend.dead then return end
        if not friend.debuff(360194) then return end
        holdGCD = true
        shouldCast = true
    end)

    if shouldCast then
        spell:Cast()
    end

    return holdGCD
end)

ascendance:Callback(function(spell)
    if not project.settings.asd then return end

    if player.channel and player.channelID == lightningLasso.id then return end

    local function filter(unit)
        local total, _, _, cds = unit.v2attackers()
        local dynamicThreshold = 30
        dynamicThreshold = dynamicThreshold + bin(project.cd(healingTide) > 0) * 10
        dynamicThreshold = dynamicThreshold + bin(not totemActive(healingTide)) * 10
        dynamicThreshold = dynamicThreshold - bin(totemActive(healingTide) or project.cd(healingTide) <= 0) * 10
        dynamicThreshold = dynamicThreshold + cds * 15
        dynamicThreshold = dynamicThreshold + total * 7
        dynamicThreshold = dynamicThreshold + bin(isLocked(player)) * 10

        return unit.hp <= dynamicThreshold
            and not unit.pet
            and not unit.dead
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest

    if not lowest.friend then return end
    return spell:Cast(player)
end)


ancestralGuidance:Callback("multi", function(spell)
    if project.cd(naturesSwiftness) <= 0 then return end
    if player.channel and player.channelid == lightningLasso.id then return end

    local function filter(unit)
        return
            not unit.pet and
            unit.los and
            unit.hp <= 50
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest

    if lowest.friend and #lowest >= 2 then
        return spell:Cast(player)
    end
end)

spiritLink:Callback(function(spell)
    if player.buff(primordialWaveBuff.id) or player.buff(naturesSwiftness.id) then return end
    if project.LowestUnit.buffFrom(immuneTable) then return end
    if not project.LowestUnit.losOfLiteral(player) then return end
    if project.LowestHealth > project.settings.sl then return end

    return spell:SmartAoE(project.LowestUnit, {
        radius = 10,
        ignoreEnemies = true,
        filter = function(obj, estDist)
            -- Only count friendly players that aren't the lowest unit
            if obj.friend and not obj.dead and not obj.pet
                and not obj.buffFrom(immuneTable)
                and not obj.isUnit(project.LowestUnit) then
                if estDist <= 10 then return true end
            end
        end,
        minHit = 1
    })
end)

totemicProjectionSL:Callback("spiritLink", function(spell)
    local slActive, tuptime = totemActive(spiritLink)
    if not slActive then return end
    if tuptime < 0.3 then return end
    if not player.losOfLiteral(project.LowestUnit) then return end

    -- Count players in current link
    local playersInLink = awful.fgroup.filter(function(unit)
        return unit.friend and not unit.dead and not unit.pet and unit.buff(325174)
    end)

    -- If we have 2+ players and lowest is one of them, don't move
    if #playersInLink >= 2 and project.LowestUnit.buff(325174) then return end

    -- Try to find valid second player
    local validSecondPlayer = awful.fgroup.find(function(unit)
        return unit.friend and not unit.dead and not unit.pet
            and not unit.buffFrom(immuneTable)
            and not unit.isUnit(project.LowestUnit)
            and unit.distanceTo(project.LowestUnit) <= 10
    end)

    local x, y, z = project.LowestUnit.x, project.LowestUnit.y, project.LowestUnit.z

    if not validSecondPlayer then return end

    return spell:SmartAoE({ x, y, z }, {
        radius = 10,
        ignoreEnemies = true,
        offsetMin = 13,
        offsetMax = 25,
        filter = function(obj, estDist)
            if obj.friend and not obj.dead and not obj.pet
                and not obj.buffFrom(immuneTable)
                and not obj.isUnit(project.LowestUnit) then
                if estDist <= 10 then return true end
            end
        end,
        minHit = 1
    })
end)

purge:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end

    local function homies(unit)
        return not unit.dead and
            unit.los and
            not unit.pet
            and unit.hp <= settings.prg
    end

    local lowest = awful.fgroup.within(40).filter(homies).lowest
    if lowest.friend then return end

    if player.manaPct <= 40 then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if not enemy.los then return end
        if enemy.buffFrom(purgeTable) then
            return spell:Cast(enemy)
        end
    end)

    awful.fgroup.within(spell.range).loop(function(friend)
        if not project.hasLosBehindIceWall(player, friend) then return end
        if not friend.los then return end
        if friend.charmed then -- Mind Control
            return spell:Cast(friend)
        end
    end)
end)

purge:Callback("lowHP", function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if not project.settings.odispel then return end

    local function homies(unit)
        return unit.los and
            not unit.pet and
            not unit.dead and
            not unit.immuneHealing and
            unit.hp <= project.settings.prg
    end

    local lowest = awful.fgroup.within(40).filter(homies).lowest
    if lowest.friend then return end

    if player.manaPct <= 40 then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if enemy.purgeCount < 1 then return end
        if not enemy.los then return end
        if enemy.hp > 40 then return end

        return spell:Cast(enemy)
    end)
end)

greaterPurge:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if spell.cd > awful.gcd then return end

    local function homies(unit)
        return unit.los and
            not unit.pet and
            not unit.dead and
            not unit.immuneHealing and
            unit.hp <= project.settings.prg
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if lowest.friend then return end

    if lowest.hp <= project.settings.prg then return end
    if player.manaPct <= 40 then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if not enemy.player then return end
        if not enemy.los then return end
        if enemy.buffFrom(purgeTable) then
            return spell:Cast(enemy)
        end
    end)

    awful.fgroup.within(spell.range).loop(function(friend)
        if not project.hasLosBehindIceWall(player, friend) then return end
        if not friend.los then return end
        if friend.charmed then -- Mind Control
            return spell:Cast(friend)
        end
    end)
end)

greaterPurge:Callback("lowHP", function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if not project.settings.odispel then return end
    if spell.cd > awful.gcd then return end

    local function homies(unit)
        return unit.los and
            not unit.pet and
            not unit.dead and
            not unit.immuneHealing and
            unit.hp <= project.settings.prg
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if lowest.friend then return end


    if player.manaPct <= 40 then return end
    awful.enemies.within(spell.range).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if not enemy.player then return end
        if enemy.purgeCount < 1 then return end
        if not enemy.los then return end
        if enemy.hp > 40 then return end

        return spell:Cast(enemy)
    end)
end)

purifySpirit:Callback(function(spell)
    local aids = false
    local nerd = nil
    if player.channel and player.channelID == lightningLasso.id then return end
    if spell.cd > awful.gcd then return end
    local function homies(unit)
        return unit.los and
            not unit.pet and
            not unit.dead and
            not unit.immuneHealing
            and unit.hp <= 40
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest

    awful.fgroup.within(spell.range).loop(function(friend)
        if not project.hasLosBehindIceWall(player, friend) then return end
        if not friend.los then return end
        if friend.pet then return end
        if friend.debuff(342938) then return end                    -- Unstable Affliction
        if friend.debuff(34914) and lowest.hp <= 65 then return end -- Vampiric Touch
        if not friend.debuffFrom(cleanseTable) then return end
        aids = true
        nerd = friend
    end)

    if lowest.friend and not lowest.isUnit(nerd) then return end
    if not aids then return end
    return spell:Cast(nerd)
end)


windShear:Callback("CC", function(spell)
    awful.enemies.within(30).loop(function(enemy)
        if not project..hasLosBehindIceWall(player, enemy) then return end
        if enemy and not enemy.player then return end
        if enemy and isLocked(enemy) then return end
        if enemy and not (enemy.casting or enemy.channeling) then return end
        if enemy and (enemy.casting8 or enemy.channel7) then return end
        if enemy and not enemy.los then return end
        if enemy and not ((enemy.casting and project.flatCC[enemy.castID]) or (enemy.channel and project.flatCC[enemy.channelID])) then return end
        if enemy and not (enemy.castTarget.isUnit(player)) then return end
        if enemy and ((enemy.casting and enemy.castRemains > castDelay.now) or (enemy.channel and enemy.channelTimeComplete < channelDelay.now)) then return end
        if player.lastCast == groundingTotem.id then return end
        if player.recentlyCast(groundingTotem.id, 0.5) then return end
        if player.buff(groundingTotem.id) and player.buffRemains(groundingTotem.id) >= (enemy.castRemains or enemy.channeltimecomplete) then return end
        if enemy.buff(preCog.id) and enemy.buffRemains(preCog.id) > awful.buffer then return end
        return spell:Cast(enemy) and alert("Wind Shear | " .. colors.red .. "CC", spell.id, true)
    end)
end)

windShear:Callback("Heal", function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end

    local lowestE = awful.enemies.within(40).lowest

    awful.enemies.within(30).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if enemy and not enemy.player then return end
        if enemy and isLocked(enemy) then return end
        if enemy and not (enemy.casting or enemy.channel) then return end
        if enemy and (enemy.casting8 or enemy.channel7) then return end
        if enemy and not enemy.los then return end
        if enemy and not ((enemy.casting and project.flatHeals[enemy.castID]) or (enemy.channel and project.flatHeals[enemy.channelID])) then return end
        if enemy and ((enemy.casting and enemy.castRemains > castDelay.now) or (enemy.channel and enemy.channelTimeComplete < channelDelay.now)) then return end
        if lowestE.hp > project.settings.khp then return end
        if enemy.buff(preCog.id) and enemy.buffRemains(preCog.id) > awful.gcdRemains then return end
        return spell:Cast(enemy) and alert("Wind Shear | " .. colors.green .. "Heal", spell.id, true)
    end)
end)

windShear:Callback("Dam", function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end

    local function homies(unit)
        return unit.los and
            not unit.pet and
            not unit.dead and
            not unit.immuneMagic
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest

    awful.enemies.within(spell.range).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if enemy and not enemy.player then return end
        if enemy and isLocked(enemy) then return end
        if enemy and not (enemy.casting or enemy.channeling) then return end
        if enemy and (enemy.casting8 or enemy.channel7) then return end
        if enemy and not enemy.los then return end
        if enemy and not ((enemy.casting and project.flatDam[enemy.castID]) or (enemy.channel and project.flatDam[enemy.channelID])) then return end
        if enemy and (project.flatCC[enemy.castID] or project.flatCC[enemy.channelID]) and enemy.castTarget.isUnit(player) and lowest.hp > 40 then return end
        if enemy and ((enemy.casting and enemy.castRemains > castDelay.now) or (enemy.channel and enemy.channelTimeComplete < channelDelay.now)) then return end
        if enemy and enemy.buff(preCog.id) then return end
        if player.lastCast == groundingTotem.id then return end
        if player.buff(groundingTotem.id) and player.buffRemains(groundingTotem.id) >= (enemy.castRemains or enemy.channelRemains) then return end
        return spell:Cast(enemy) and alert("Wind Shear | " .. colors.red .. "Damage", spell.id, true)
    end)
end)

MoveTide = math.huge


healingTide:Callback("burst", function(spell)
    if spell.cd > awful.gcd then return end
    if project.LowestUnit.dist > 40 then return end

    if burstTracker.enemyBurst then
        if spell:Cast(player) then
            MoveTide = awful.time + 1
            return true
        end
    end
end)


healingTide:Callback(function(spell)
    if project.LowestHealth > 55 then return end
    if player.buff(ascendance.id) then return end
    if project.LowestUnit.distance > 40 then return end
    if spell:Cast(player) then
        MoveTide = awful.time + 1
        return
    end
end)


bloodLust:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if not burstTracker.friendBurst then return end
    if burstTracker.burstFriend.distance > spell.range then return end
    if not spell.known then return end
    return spell:Cast()
end)

hex:Callback("tyrant", function(spell)
    local nerd = nil
    local aids = false
    if wasCasting[hex.id] then return end
    if player.channel and player.channelid == lightningLasso.id then return end
    awful.tyrants.loop(function(tyrant)
        if tyrant.cc then return end
        if tyrant.bcc then return end
        if not tyrant.enemy then return end
        aids = true
        nerd = tyrant
    end)
    if not aids then return end
    return spell:Cast(nerd)
end)

hex:Callback("chainHealer", function(spell)
    local holdGCD = false
    local capActive = totemActive(capacitorTotem)
    if not project.settings.hex then return end
    if capActive then return end
    if not hex:Castable(enemyHealer) then return end
    if wasCasting[hex.id] then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if not enemyHealer.exists then return end
    if enemyHealer.buff(treeOfLifeBuff.id) then return end
    if isLocked(enemyHealer) then return end
    if enemyHealer.beast then return end
    if not enemyHealer.los then return end
    if enemyHealer.immuneMagic and enemyHealer.magicEffectImmunityRemains > hex.castTime then return end
    if enemyHealer.immuneCC and enemyHealer.ccImmunityRemains > hex.castTime then return end
    if enemyHealer.buffFrom(cantCC) then return end
    if enemyHealer.idr < 0.5 then return end
    --if enemyHealer.enemiesattacking then return end

    local function filter(unit)
        return unit.los
            and not unit.dead
            and not unit.pet
    end
    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if lowest.hp <= 50 then return end

    if (enemyHealer.cc and enemyHealer.ccRemains <= hex.castTime + awful.buffer) then
        spell:Cast(enemyHealer)
    end

    if (enemyHealer.bcc and enemyHealer.bccRemains <= hex.castTime + awful.buffer) then
        spell:Cast(enemyHealer)
    end


    if (enemyHealer.cc or enemyHealer.bcc) and (enemyHealer.ccRemains <= hex.castTime + awful.buffer or enemyHealer.bccRemains <= hex.castTime + awful.buffer) then
        holdGCD = true
    end

    return holdGCD
end)


hex:Callback("enemyHealer", function(spell)
    if not project.settings.hex then return end
    if not enemyHealer.exists then return end
    if not hex:Castable(enemyHealer) then return end
    if wasCasting[hex.id] then return end
    if spell.cd > awful.gcd then return end
    if player.channel and player.channelID == lightningLasso.id then return end

    local function filter(unit)
        return unit.los
            and not unit.pet
            and not unit.dead
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if lowest.hp <= 50 then return end

    local total, _, _, cooldowns = enemyHealer.v2attackers()

    if enemyHealer.buff(treeOfLifeBuff.id) then return end
    if isLocked(enemyHealer) then return end
    if enemyHealer.beast then return end
    if not enemyHealer.los then return end
    if not project.hasLosBehindIceWall(player, enemyHealer) then return end
    if enemyHealer.immuneMagic and enemyHealer.magicEffectImmunityRemains > hex.castTime then return end
    if enemyHealer.immuneCC and enemyHealer.ccImmunityRemains > hex.castTime then return end
    if enemyHealer.buffFrom(cantCC) then return end
    if enemyHealer.idr < 0.5 then return end
    --if total >= 1 then return end
    if enemyHealer.cc or enemyHealer.bcc then return end
    return spell:Cast(enemyHealer)
end)

hex:Callback("dps", function(spell)
    if not project.settings.hex then return end
    if wasCasting[hex.id] then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if spell.cd > awful.gcd then return end

    local function filter(unit)
        return not unit.pet
            and not unit.dead
            and unit.hp <= 55
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if lowest.friend then return end

    awful.enemies.within(30).loop(function(enemy)
        local total, _, _, cooldowns = enemy.v2attackers()
        if not enemy then return end
        if not project.hasLosBehindIceWall(player, enemy) then return end

        if not enemy.player then return end
        if enemy and isLocked(enemy) then return end
        if not enemy.los then return end
        if enemy.immuneMagic and enemy.magicEffectImmunityRemains > hex.castTime + awful.buffer then return end
        if enemy.immuneCC and enemy.ccImmunityRemains > hex.castTime + awful.buffer then return end
        if enemy.buffFrom(cantCC) then return end
        if enemy.beast then return end
        if total >= 1 then return end
        if enemy.isUnit(enemyHealer) then return end
        if (enemy.cc and enemy.ccRemains > hex.castTime + awful.buffer) then return end
        if (enemy.bcc and enemy.bccRemains > hex.castTime + awful.buffer) then return end

        local canCast = true
        awful.fgroup.loop(function(friend)
            if not friend.isPlayer then return end
            if friend.target and friend.target.guid == enemy.guid then
                canCast = false
                return
            end
        end)

        if not canCast then return end
        return spell:Cast(enemy)
    end)
end)

spiritWalkersGrace:Callback(function(spell)
    if not project.settings.swg then return end

    if player.stunned then return end
    if player.channel and player.channelID == lightningLasso.id then return end
    if not player.canBeInterrupted(healingSurge.castTime) then return end
    if player.buff(groundingTotem.id) and player.buffRemains(groundingTotem.id) > healingSurge.castTime then return end

    local function filter(unit)
        return not unit.pet and
            not unit.dead and
            unit.hp <= project.settings.hs
    end

    local lowest = awful.fgroup.within(40).filter(filter).lowest
    if not lowest.friend then return end

    if player.casting and player.castID == healingSurge.id and player.castPct >= 50 then
        return spell:Cast(player) and alert("Spirit Walker's Grace | " .. colors.red .. "Anti-Kick", spell.id, true)
    end
end)

stoneSkin:Callback(function(spell)
    local total, melee, ranged, cds = player.v2attackers()
    if player.channel and player.channelID == lightningLasso.id then return end
    if not player.hasTalent(stoneSkin.id) then return end
    if spell.cd > awful.gcd then return end

    if player.hpa <= 40 then
        return spell:Cast()
    end

    if earthWall.cd > awful.gcd and not player.buff(earthWallBuff.id) and cds >= 1 and total >= 1 and astralShift.cd > awful.gcd and not player.buff(astralShift.id) then
        return spell:Cast()
    end
end)

lightningLasso:Callback("healer", function(spell)
    local staticActive = totemActive(staticFieldTotem)
    local capActive = totemActive(capacitorTotem)
    if not player.hasTalent(305483) then return end
    if not project.settings.lasso then return end
    if not lightningLasso:Castable(enemyHealer) then return end
    if spell.cd > awful.gcd then return end
    if capActive then return end
    if staticActive then return end
    if enemyHealer.dist > 20 then return end
    if enemyHealer.rooted and enemyHealer.rootRemains > awful.buffer then return end
    if enemyHealer.immuneCC and enemyHealer.ccImmunityRemains > awful.buffer then return end
    if enemyHealer.immunePhysical and enemyHealer.physicalEffectImmunityRemains > awful.buffer then return end
    if enemyHealer.buffFrom(cantCC) then return end
    if not enemyHealer.los then return end
    if not player.facing(enemyHealer) then return end
    if enemyHealer.sdr < 0.5 then return end
    if not project.hasLosBehindIceWall(player, enemyHealer) then return end


    local lowHealthTeammate = false
    awful.fgroup.within(40).loop(function(friend)
        if not friend.dead and not friend.pet and friend.hp <= 40 then
            lowHealthTeammate = true
            return true
        end
    end)

    if lowHealthTeammate then return end

    if (enemyHealer.cc and enemyHealer.ccRemains <= awful.buffer) or
        (enemyHealer.bcc and enemyHealer.bccRemains <= awful.buffer) or
        not (enemyHealer.cc or enemyHealer.bcc) then
        return spell:Cast(enemyHealer)
    end
end)


lightningLasso:Callback("dps", function(spell)
    local aids = false
    local nerd = nil
    local staticActive = totemActive(staticFieldTotem)
    local capActive = totemActive(capacitorTotem)
    if not player.hasTalent(305483) then return end
    if not project.settings.lasso then return end
    if spell.cd > awful.gcd then return end
    if staticActive then return end
    if capActive then return end

    local function filter(unit)
        return not unit.pet
            and not unit.dead
            and unit.los
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if lowest.hp <= 50 then return end

    awful.enemies.within(20).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if enemy.rooted and enemy.rootRemains > awful.buffer then return end
        if enemy.immuneCC and enemy.ccImmunityRemains > awful.buffer then return end
        if enemy.immunePhysical and enemy.physicalEffectImmunityRemains > awful.buffer then return end
        if enemy.buffFrom(cantCC) then return end
        if not enemy.los then return end
        if not player.facing(enemy) then return end
        if enemy.isUnit(enemyHealer) then return end
        if enemy.sdr < 0.5 then return end

        if (enemy.cc and enemy.ccRemains <= awful.buffer) then
            aids = true
            nerd = enemy
        end

        if (enemy.bcc and enemy.bccRemains <= awful.buffer) then
            aids = true
            nerd = enemy
        end

        if not (enemy.cc or enemy.bcc) then
            aids = true
            nerd = enemy
        end
    end)

    if not aids then return end
    return spell:Cast(nerd)
end)


manaTide:Callback(function(spell)
    if spell.cd > awful.gcd then return end
    if player.channel and player.channelid == lightningLasso.id then return end
    if not player.hasTalent(manaTide.id) then return end
    if player.manaPct <= 70 then
        return spell:Cast()
    end
end)


capacitorTotem:Callback(function(spell)
    local aids = false
    local nerd = nil
    local staticActive = totemActive(staticFieldTotem)
    local htActive = totemActive(healingTide)
    if spell.cd > awful.gcd then return end
    if not player.hasTalent(capacitorTotem.id) then return end
    if player.channel and player.channelid == lightningLasso.id then return end

    if htActive then return end
    if staticActive then return end

    awful.enemies.within(40).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if enemy.sdr < 0.5 then return end
        if enemy.rooted and enemy.rootRemains <= 2 + awful.gcdRemains + awful.buffer + awful.latency then
            aids = true
            nerd = enemy
        end
        if enemy.bcc and enemy.bccRemains <= 2 + awful.gcdRemains + awful.buffer + awful.latency then
            aids = true
            nerd = enemy
        end
        if enemy.cc and enemy.ccRemains <= 2 + awful.gcdRemains + awful.buffer + awful.latency then
            aids = true
            nerd = enemy
        end
    end)

    if not aids then return end
    return spell:SmartAoE(nerd, { offsetMin = 0, offsetMax = 7 })
end)

unleashShield:Callback(function(spell)
    local holdGCD = false
    local aids = false
    local nerd = nil
    if player.channel and player.channelID == lightningLasso.id then return end
    local instanceType = select(2, IsInInstance())
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and project.combatCheck())) then return end
    if not player.hasTalent(unleashShield.id) then return end
    if spell.cd > awful.gcd then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if not project.hasLosBehindIceWall(player, enemy) then return end
        if enemy and not enemy.dead then
            if enemy.player and not enemy.cc or enemy.bcc then
                if enemy and enemy.speed > 25 then
                    if enemy and not enemy.buffFrom(enemyReflect) and not enemy.immuneMagic then
                        holdGCD = true
                        aids = true
                        nerd = enemy
                    end
                else
                    for _, id in pairs(leaps) do
                        if enemy.castID == id then
                            if enemy and not enemy.buffFrom(enemyReflect) and not enemy.immuneMagic then
                                holdGCD = true
                                aids = true
                                nerd = enemy
                            end
                        end
                    end
                end
            end
        end

        if enemy and enemy.hp <= 60 and spell:Castable(enemy) and not enemyHealer.buffFrom(enemyReflect) then
            holdGCD = true
            aids = true
            nerd = enemy
        end
        if enemy.cds and not enemy.buffFrom(enemyReflect) and not enemy.immuneMagic then
            holdGCD = true
            aids = true
            nerd = enemy
        end
    end)

    if aids then
        spell:Cast(nerd)
    end

    return holdGCD
end)


healingRain:Callback(function(spell)
    if player.channel and player.channelID == lightningLasso.id then return end
    if spell.cd > awful.gcd then return end
    if player.hasTalent(rainDance.id) then
        local function homies(unit)
            return not unit.dead and
                not unit.pet
                and not unit.immuneHealing
                and unit.hp <= project.settings.hr
                and not unit.moving
                and project.hasLosBehindIceWall(player, unit)
        end

        local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
        if not lowest.friend then return end

        local x, y, z = lowest.predictPosition(0.5)
        return spell:AoECast(x, y, z)
    end
end)

ghostWolf:Callback("rep", function(spell)
    local CastingRep = false
    if player.channel and player.channelID == lightningLasso.id then return end
    awful.enemies.within(40).loop(function(enemy)
        if enemy.casting and enemy.castID == 2066 and enemy.castTarget.isUnit(player) and enemy.castRemains <= 0.5 then
            if player.buff(ghostWolf.id) then return end
            if windShear.cd < awful.gcd and enemy.dist <= 30 then return end
            if project.cd(groundingTotem) <= 0 and awful.gcdRemains <= enemy.castRemains then return end
            CastingRep = true
        end
    end)

    if not CastingRep then return end
    return spell:Cast()
end)

ghostWolf:Callback("move", function(spell)
    local castThatShit = false
    if player.channel and player.channelID == lightningLasso.id then return end
    local total, melee, _, cooldowns = player.v2attackers()
    if not project.settings.gw then return end
    if spell.cd > awful.gcd then return end

    local function homies(unit)
        return unit.exists and (unit.dist > 40 or not unit.los) and
            not unit.dead and
            not unit.pet or
            unit.isUnit(player) and melee >= 1 or
            unit.isUnit(player) and player.hasTalent(378075) and unit.slowed -- remove snare
    end

    local lowest = awful.fgroup.within(60).filter(homies).lowest
    if not lowest.friend then return end
    if not player.moving then return end
    if lowest.hp <= 40 and lowest.los and lowest.dist <= 40 then return end
    if player.buff(ghostWolf.id) then return end

    return spell:Cast()
end)

ghostWolf:Callback("cancel", function(spell)
    local total, melee, _, cooldowns = player.v2attackers()
    if not project.settings.gw then return end
    if spell.cd > awful.gcd then return end

    local function homies(unit)
        if unit.dist <= 40 and unit.los then return false end
        if unit.dead then return false end
        if unit.pet then return false end
        return true
    end

    local lowest = awful.fgroup.within(60).filter(homies).lowest

    if player.buff(ghostWolf.id) and melee < 1 and (lowest.los) then
        awful.call("CancelShapeshiftForm")
    end
    if player.buff(ghostWolf.id) and (player.distanceTo(lowest) < 39) and melee < 1 then
        awful.call("CancelShapeshiftForm")
    end
end)

spiritWalk:Callback(function(spell)
    if not player.hasTalent(spiritWalk.id) then return end
    local total, melee, _, cooldowns = player.v2attackers()
    local balance = awful.enemies.within(60).find(function(enemy) return enemy.class2 == "DRUID" and
        enemy.spec == "Balance" and enemy.cd(78675) < awful.gcd end)                                                                                          -- solar beam
    local shouldUse = false

    if (player.rooted and player.silenced) then
        shouldUse = true
    end

    if melee >= 1 and player.slowed then
        shouldUse = true
    end

    if player.slowed and (project.LowestUnit.los or project.LowestUnit.dist > 40) and project.LowestUnit.hp <= 60 then
        shouldUse = true
    end

    if player.hp <= 40 and melee >= 1 then
        shouldUse = true
    end

    if player.rooted and player.rootRemains >= 2 and purifySpirit.cd > awful.gcd and not balance then
        shouldUse = true
    end


    if not shouldUse then return end
    return spell:Cast()
end)
