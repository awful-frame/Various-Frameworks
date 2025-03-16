local Unlocker, awful, project = ...
if awful.player.class2 ~= "PRIEST" then return end
if GetSpecialization() ~= 1 then return end
local discipline = project.priest.discipline
local Spell = awful.Spell
awful.AntiAFK.enabled = true
awful.enabled = true
awful.unlock("SpellStopCasting")
awful.unlock("CancelSpellByName")
local target = awful.target
local player = awful.player
local healer = awful.healer
local focus = awful.focus
local pet = awful.pet
local enemyHealer = awful.enemyHealer
local delay = awful.delay(0.3, 0.4)
local bin = awful.bin
local hookCallbacks, hookSpells = awful.hookSpellCallbacks, awful.hookSpellCasts

project.insightCast = false
project.pietyCast = false
project.solaceCast = false
project.clairvoyanceCast = false
project.shieldingSequence = false
project.holdGCD = false

awful.Populate({
prayerOfMending = Spell(33076, { targeted = true, heal = true, ignoreMoving = true, ignoreLoS = false, effect = "magic" }),
archAngel = Spell(197862, { targeted = false, ignoreMoving = true }),
shadowCovenant = Spell(314867),
voidTendrils = Spell(108920, { ignoreMoving = true, cc = "root", ignoreFacing = true }),
smite = Spell(585, { damage = "magic", targeted = true, effect = "magic", ignoreLoS = false, ignoreFacing = false }),
mindBlast = Spell(8092, { damage = "magic", targeted = true, ignoreLoS = false, ignoreFacing = false }),
purgeTheWicked = Spell(204197, { damage = "magic", ignoreLoS = false, ignoreMoving = true, targeted = true, ignoreFacing = false  }),
preHot = Spell(139, { targeted = true, heal = true, ignoreMoving = true, ignoreLoS = false }),
renew = Spell(139, { targeted = true, heal = true, ignoreMoving = true, ignoreLoS = false, ignoreFacing = false }),
PwShield = Spell(17, { targeted = true, ignoreMoving = true, ignoreLoS = false, heal = true }),
penance = Spell(47540, { heal = true, targeted = true, ignoreMoving = true, ignoreLoS = false, ignoreFacing = false, damage = "magic" }),
flashHeal = Spell(2061, { heal = true, targeted = true, ignoreLoS = false }),
SoL = Spell(2061, { heal = true, ignoreMoving = true, ignoreLoS = false }),
PwLife = Spell(373481, { heal = true, targeted = true, ignoreMoving = true, ignoreLoS = false, ignoreUsable = true }),
swd = Spell(32379, { damage = "magic", targeted = true, ignoreMoving = true, range = 40, ignoreFacing = false, mustBeGrounded = true, ignoreCasting = true, ignoreChanneling = true }),
fade = Spell(586, { ignoreMoving = true, ignoreLoS = true, ignoreFacing = true, ignoreGCD = true, beneficial = true, ignoreCasting = true, ignoreChanneling = true }),
PwBarrier = Spell(62618, { targeted = false, ignoreLoS = true, diameter = 16, offsetMin = 0, offsetMax = 10, ignoreFacing = true, ignoreEnemies = true, circleSteps = 24, distChecks = 12  }),
PwRadiance = Spell(194509, { targeted = false, heal = true, range = 30, ignoreFacing = true, ignoreLoS = true, ignoreMoving = true }),
dispelMagic = Spell(528, { targeted = true, ignoreLoS = false, ignoreMoving = true }),
mindGames = Spell(375901, { targeted = true, damage = "magic", effect = "magic", ignoreLoS = false }),
powerInfusion = Spell(10060, { targeted = true, ignoreMoving = true, ignoreLoS = false, ignoreGCD = true }),
darkArchangel = Spell(197871, { beneficial = true, targeted = false, ignoreMoving = true, ignoreFacing = true, ignoreLoS = true }),
purify = Spell(527, { targeted = true, ignoreMoving = true, ignoreLoS = false, ignoreFacing = false }),
massDispel = Spell(32375, { targeted = false, ignoreLoS = false, diameter = 16, offsetMin = 0, offsetMax = 2, circleSteps = 24, distChecks = 12, movePredTime = 0.5 }),
painSuppression = Spell(33206, { targeted = true, ignoreControl = true, ignoreLoS = false, ignoreGCD = true, ignoreFacing = false, heal = true }),
psychicScream = Spell(8122, { targeted = false, ignoreMoving = true, ignoreLoS = false, effect = "magic", ignoreFacing = true, cc = "disorient" }),
leapOfFaith = Spell(73325, { targeted = true, ignoreMoving = true, range = 40, ignoreLoS = false, ignoreGCD = true }),
angelicFeather = Spell(121536, { targeted = false, effect = "magic", ignoreMoving = true, ignoreLoS = false, diameter = 4, offsetMin = 0, offsetMax = 2, circleSteps = 24, distChecks = 12, ignoreEnemies = true }),
angelicFeatherBuff = Spell(121557),
PwFortitude = Spell(21562, { beneficial = true }),
desperatePrayer = Spell(19236, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
rapture = Spell(47536, { ignoreMoving = true, heal = true, targeted = true }),
innerLight = Spell(355897, { beneficial = true }),
phaseShift = Spell(408557, { beneficial = true }),
phaseShiftBuff = Spell(408558, { beneficial = true }),
ultimatePenitence = Spell(421453, { targeted = false, heal = true }),
shadowMeld = Spell(58984, { ignoreMoving = true, ignoreGCD = true, beneficial = true, targeted = false }),
voidShift = Spell(108968, { targeted = true, ignoreMoving = true, heal = true, ignoreGCD = true }),
swPain = Spell(589, { ignoreMoving = true, damage = "magic", targeted = true }),
shadowFiend = Spell(34433, { ignoreMoving = true }),
purgeTheWickedDebuff = Spell(204213),
SoLBuff = Spell(114255),
schismBuff = Spell(424509, { beneficial = true }),
ultimateChannel = Spell(421434),
sigilOfMisery = Spell(207685),
mindBender = Spell(123040, { ignoreMoving = true }),
lightBuff = Spell(355897, { beneficial = true }),
shadowBuff = Spell(355898, { beneficial = true }),
darkSideBuff = Spell(198069, { beneficial = true }),
PwBarrierBuff = Spell(81782, { beneficial = true }),
shadowyDuelDebuff = Spell(207736),
atonement = Spell(194384, { beneficial = true }),
miraculousRecovery = Spell(440674),
premonition = Spell(428924, { beneficial = true, ignoreGCD = true}),
entropicRift = Spell(447444),
insight = Spell(428933, { beneficial = true, ignoreGCD = true, ignoreMoving = true, targeted = false }),
piety = Spell(428930, { beneficial = true, ignoreGCD = true, ignoreMoving = true, targeted = false }),
solace = Spell(428934, { beneficial = true, ignoreGCD = true, ignoreMoving = true, targeted = false }),
clairvoyance = Spell(440725, { beneficial = true, ignoreGCD = true, ignoreMoving = true, targeted = false }),
phantomReach = Spell(459559, { beneficial = true }),
catharsis = Spell(391297),
surgeOfLight = Spell(109186),
wealAndWoe = Spell(3970787),
mindControl = Spell(605)
}, discipline, getfenv(1))

local commonChecks = {
    castingOrChanneling = function()
        return (player.channel and player.channelID == ultimateChannel.id)
            or (player.casting and player.castID == ultimatePenitence.id)
            or player.used(ultimatePenitence.id, 0.5)
    end,
}


local BurstCDS = {
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

local rogueCDS = {
    [212183] = { uptime = 0.3, min = 2 }, -- smoke bomb
    [359054] = { uptime = 0.3, min = 2 }, -- smoke bomb
    [207736] = { uptime = 0.3, min = 2 }, -- duel
}

-- First, create a table that holds all our spell definitions with comments
local deathTableDefinitions = {
    [51514] = true,     -- Hex
    [210873] = true,    -- Hex (Compy)
    [211004] = true,    -- Hex (Spider)
    [211010] = true,    -- Hex (Snake)
    [211015] = true,    -- Hex (Cockroach)
    [269352] = true,    -- Hex (Skeletal Hatchling)
    [277778] = true,    -- Hex (Zandalari Tendonripper)
    [277784] = true,    -- Hex (Wicker Mongrel)
    [309328] = true,    -- Hex (Living Honey)
    [118] = true,       -- Polymorph
    [61780] = true,     -- Polymorph (Turkey)
    [126819] = true,    -- Polymorph (Pig)
    [161353] = true,    -- Polymorph (Bear Cub)
    [161354] = true,    -- Polymorph (Monkey)
    [161355] = true,    -- Polymorph (Penguin)
    [28271] = true,     -- Polymorph (Turtle)
    [28272] = true,     -- Polymorph (Pig)
    [61305] = true,     -- Polymorph (Black Cat)
    [61721] = true,     -- Polymorph (Rabbit)
    [161372] = true,    -- Polymorph (Peacock)
    [277787] = true,    -- Polymorph (Baby Direhorn)
    [277792] = true,    -- Polymorph (Bumblebee)
    [321395] = true,    -- Polymorph (Mawrat)
    [391622] = true,    -- Polymorph (Duck)
    [5782] = true,      -- Fear
    [20066] = true,     -- Repentance
    [360806] = true,    -- Sleep Walk
    [356727] = true     -- Silence Venom
}

-- Create the metatable that will define lookup behavior
local deathTableMeta = {
    __index = function(_, spellID)
        -- If this spell isn't in our definitions, return nil
        if not deathTableDefinitions[spellID] then
            return nil
        end

        -- For Incapacitate DR spells (Polymorph, Hex variants, Repentance)
        if spellID == 118 or        -- Polymorph
           spellID == 61780 or      -- Polymorph (Turkey)
           spellID == 126819 or     -- Polymorph (Pig)
           spellID == 161353 or     -- Polymorph (Bear Cub)
           spellID == 161354 or     -- Polymorph (Monkey)
           spellID == 161355 or     -- Polymorph (Penguin)
           spellID == 28271 or      -- Polymorph (Turtle)
           spellID == 28272 or      -- Polymorph (Pig)
           spellID == 61305 or      -- Polymorph (Black Cat)
           spellID == 61721 or      -- Polymorph (Rabbit)
           spellID == 161372 or     -- Polymorph (Peacock)
           spellID == 277787 or     -- Polymorph (Baby Direhorn)
           spellID == 277792 or     -- Polymorph (Bumblebee)
           spellID == 321395 or     -- Polymorph (Mawrat)
           spellID == 391622 or     -- Polymorph (Duck)
           spellID == 51514 or      -- Hex
           spellID == 210873 or     -- Hex (Compy)
           spellID == 211004 or     -- Hex (Spider)
           spellID == 211010 or     -- Hex (Snake)
           spellID == 211015 or     -- Hex (Cockroach)
           spellID == 269352 or     -- Hex (Skeletal Hatchling)
           spellID == 277778 or     -- Hex (Zandalari Tendonripper)
           spellID == 277784 or     -- Hex (Wicker Mongrel)
           spellID == 309328 or     -- Hex (Living Honey)
           spellID == 20066 then    -- Repentance
            return player.idr >= 0.5
        end

        -- For Disorient DR spells
        if spellID == 5782 or       -- Fear
           spellID == 360806 then   -- Sleep Walk
            return player.ddr >= 0.5
        end

        -- Special case for Silence Venom
        if spellID == 356727 then   -- Silence Venom
            return player.debuff(356727) and player.debuffRemains(356727) <= 0.5
        end
    end
}

-- Create our main table and set its metatable
local deathTable = {}
setmetatable(deathTable, deathTableMeta)


-- First, create a table that holds all our spell definitions with comments
local fadeTableDefinitions = {
    [49576] = true,      -- Death Grip
    [3355] = true,       -- Freezing Trap
    [190925] = true,     -- Harpoon
    [102359] = true,     -- Mass Entanglement
    [19577] = true,      -- Intimidation
    [605] = true,        -- Mind Control
    [375901] = true      -- Mind Games
}

local fadeTableMeta = {
    __index = function(_, spellID)
        -- If this spell isn't in our definitions, return a function that returns false
        if not fadeTableDefinitions[spellID] then
            return function() return false end
        end

        -- Return appropriate function based on spell ID
        return function(unit)
            -- Handle simple "always true" cases
            if spellID == 49576 or     -- Death Grip
               spellID == 19577 then   -- Intimidation
                return true
            end

            -- Handle DR check cases
            if spellID == 3355 then    -- Freezing Trap
                return player.idr >= 0.5
            end

            if spellID == 102359 then  -- Mass Entanglement
                return player.rdr >= 0.5
            end

            -- Handle special cases that need unit info
            if spellID == 190925 then  -- Harpoon
                return unit and awful.gcdRemains <= 0.5 and unit.distanceTo(player) <= 2
            end

            if spellID == 605 then     -- Mind Control
                return unit and player.ddr >= 0.5 and unit.castRemains <= 0.5
            end

            if spellID == 375901 then  -- Mind Games
                return unit and unit.castRemains <= 0.5
            end

            return false
        end
    end
}

-- Create our main table and set its metatable
local fadeTable = {}
setmetatable(fadeTable, fadeTableMeta)

local enemyReflect = {
    23920 --spell reflect
}

local casterSpecs = {
    ["Balance"] = true,
    ["Affliction"] = true,
    ["Destruction"] = true,
    ["Demonology"] = true,
    ["Frost"] = true,
    ["Fire"] = true,
    ["Arcane"] = true,
    ["Elemental"] = true,
    ["Shadow"] = true,
    ["Augmentation"] = true,
    ["Devastation"] = true
}

-- Define the enemy comps and their characteristics
local MetaComps = {
    BURST_COMPS = {
        ["RMP"] = {
            classes = {"ROGUE", "MAGE"},
            specs = {"Subtlety", "Frost"}
        },
        ["FMP"] = {
            classes = {"DRUID", "MAGE"},
            specs = {"Feral", "Frost"}
        },
        ["Dancing with Stars"] = {
            classes = {"ROGUE", "DRUID"},
            specs = {"Outlaw", "Balance"}
        },
        ["RPD"] = {
            classes = {"ROGUE", "PRIEST"},
            specs = {"Subtlety", "Shadow"}
        },
        ["God Comp"] = {
            classes = {"MAGE", "PRIEST"},
            specs = {"Frost", "Shadow"}
        },
        ["FPX"] = {
            classes = {"DRUID", "PRIEST"},
            specs = {"Feral", "Shadow"}
        }
    },

    CLEAVE_COMPS = {
        ["DH DK"] = {
            classes = {"DEMONHUNTER", "DEATHKNIGHT"},
            specs = {"Havoc", "Unholy"}
        },
        ["TWD"] = {
            classes = {"DEATHKNIGHT", "MONK"},
            specs = {"Unholy", "Windwalker"}
        },
        ["Thunder Cleave"] = {
            classes = {"WARRIOR", "SHAMAN"},
            specs = {"Arms", "Elemental"}
        },
        ["PHDK"] = {
            classes = {"HUNTER", "DEATHKNIGHT"},
            specs = {"BeastMastery", "Unholy"}
        },
        ["DK Ele"] = {
            classes = {"DEATHKNIGHT", "SHAMAN"},
            specs = {"Unholy", "Elemental"}
        },
        ["DK Assa"] = {
            classes = {"DEATHKNIGHT", "ROGUE"},
            specs = {"Unholy", "Assassination"}
        },
        ["WW Ele"] = {
            classes = {"MONK", "SHAMAN"},
            specs = {"Windwalker", "Elemental"}
        },
        ["Ele Feral"] = {
            classes = {"SHAMAN", "DRUID"},
            specs = {"Elemental", "Feral"}
        }
    },

    CASTER_COMPS = {
        ["Shadowplay"] = {
            classes = {"PRIEST", "WARLOCK"},
            specs = {"Shadow", "Affliction"}
        },
        ["Shadow Cleave"] = {
            classes = {"DEATHKNIGHT", "WARLOCK"},
            specs = {"Unholy", "Affliction"}
        },
        ["LSPala"] = {
            classes = {"SHAMAN", "WARLOCK"},
            specs = {"Elemental", "Demonology"}
        },
        ["Demo Boomy"] = {
            classes = {"WARLOCK", "DRUID"},
            specs = {"Demonology", "Balance"}
        },
        ["Demo Shadowplay"] = {
            classes = {"WARLOCK", "PRIEST"},
            specs = {"Demonology", "Shadow"}
        },
        ["MLPala"] = {
            classes = {"MAGE", "WARLOCK"},
            specs = {"Frost", "Demonology"}
        },
        ["DH SP"] = {
            classes = {"DEMONHUNTER", "PRIEST"},
            specs = {"Havoc", "Shadow"}
        },
        ["DH Boomy"] = {
            classes = {"DEMONHUNTER", "DRUID"},
            specs = {"Havoc", "Balance"}
        }
    },

    JUNGLE_COMPS = {
        ["Jungle"] = {
            classes = {"DRUID", "HUNTER"},
            specs = {"Feral", "BeastMastery"}
        },
        ["BM/Ele"] = {
            classes = {"HUNTER", "SHAMAN"},
            specs = {"BeastMastery", "Elemental"}
        },
        ["Outlaw Thug"] = {
            classes = {"ROGUE", "HUNTER"},
            specs = {"Outlaw", "BeastMastery"}
        },
        ["Sub Thug"] = {
            classes = {"ROGUE", "HUNTER"},
            specs = {"Subtlety", "BeastMastery"}
        },
        ["BM SP"] = {
            classes = {"HUNTER", "PRIEST"},
            specs = {"BeastMastery", "Shadow"}
        }
    }
}

local KillSetupAbilities = {
    -- Rogue
    [408] = { drType = "sdr", class = "ROGUE", isKillSetup = true, type = "instant" },    -- Kidney Shot
    [2094] = { drType = "ddr", class = "ROGUE", isKillSetup = true, type = "instant" },   -- Blind
    --[359053] = { drType = nil, class = "ROGUE", isKillSetup = true, type = "instant" },    -- Smoke Bomb
    --[212182] = { drType = nil, class = "ROGUE", isKillSetup = true, type = "instant" },    -- Smoke Bomb
    --[207736] = { drType = nil, class = "ROGUE", isKillSetup = true, type = "instant" },    -- Duel
   
    --Monk
    [119381] = { drType = "sdr", class = "MONK", isKillSetup = true, type = "instant" },     -- Leg Sweep
    [115078] = { drType = "idr", class = "MONK", isKillSetup = true, type = "instant" },     -- Paralysis

    -- Mage
    [118] = { drType = "idr", class = "MAGE", isKillSetup = true, type = "instant" },     -- Polymorph
    [203286] = { drType = nil, class = "MAGE", isKillSetup = true, type = "cast" },       -- Greater Pyroblast
    [82691] = { drType = "idr", class = "MAGE", isKillSetup = true, type = "instant" },   -- Ring of Frost
    [31661] = { drType = "ddr", class = "MAGE", isKillSetup = true, type = "instant" },   -- Dragon's Breath

    -- Priest
    [8122] = { drType = "ddr", class = "PRIEST", isKillSetup = true, type = "instant" },  -- Psychic Scream
    [205369] = { drType = "sdr", class = "PRIEST", isKillSetup = true, type = "instant" }, -- Mind Bomb
    [605] = { drType = "ddr", class = "PRIEST", isKillSetup = true, type = "cast" },      -- Mind Control
    [247777] = { drType = "sdr", class = "PRIEST", isKillSetup = true, type = "instant" }, -- Chain CC Mind Bomb

    -- DH
    [207685] = { drType = "ddr", class = "DEMONHUNTER", isKillSetup = true, type = "instant" }, -- Sigil of Misery
    [179057] = { drType = "sdr", class = "DEMONHUNTER", isKillSetup = true, type = "instant" }, -- Chaos Nova
    [217832] = { drType = "idr", class = "DEMONHUNTER", isKillSetup = true, type = "instant" }, -- Imprison
    [211881] = { drType = "sdr", class = "DEMONHUNTER", isKillSetup = true, type = "instant" }, -- Fel Eruption

    -- Warlock
    [6789] = { drType = "ddr", class = "WARLOCK", isKillSetup = true, type = "instant" },  -- Mortal Coil
    [30283] = { drType = "sdr", class = "WARLOCK", isKillSetup = true, type = "instant" }, -- Shadowfury

    -- Hunter
    [3355] = { drType = "idr", class = "HUNTER", isKillSetup = true, type = "instant" },   -- Freezing Trap
    [19577] = { drType = "sdr", class = "HUNTER", isKillSetup = true, type = "instant" },  -- Intimidation
    [356727] = { drType = "idr", class = "HUNTER", isKillSetup = true, type = "instant" },     -- Spider Venom
    [213691] = { drType = "ddr", class = "HUNTER", isKillSetup = true, type = "instant" }, -- Scatter Shot

    -- Druid
    [33786] = { drType = "idr", class = "DRUID", isKillSetup = true, type = "cast" },     -- Cyclone
    [81261] = { drType = "silencedr", class = "DRUID", isKillSetup = true, type = "instant" }, -- Solar Beam
    [339] = { drType = "rdr", class = "DRUID", isKillSetup = true, type = "cast" },       -- Entangling Roots
    [5211] = { drType = "sdr", class = "DRUID", isKillSetup = true, type = "instant" },   -- Mighty Bash
    [22570] = { drType = "sdr", class = "DRUID", isKillSetup = true, type = "instant" },  -- Maim

    -- Warrior
    [132168] = { drType = "sdr", class = "WARRIOR", isKillSetup = true, type = "instant" }, -- Shockwave
    [5246] = { drType = "ddr", class = "WARRIOR", isKillSetup = true, type = "instant" },  -- Intimidating Shout
    [107570] = { drType = "sdr", class = "WARRIOR", isKillSetup = true, type = "instant" }, -- Storm Bolt

    -- Paladin
    [853] = { drType = "sdr", class = "PALADIN", isKillSetup = true, type = "instant" },   -- Hammer of Justice
    [20066] = { drType = "idr", class = "PALADIN", isKillSetup = true, type = "cast" },    -- Repentance

    -- Shaman
    [51514] = { drType = "idr", class = "SHAMAN", isKillSetup = true, type = "cast" },     -- Hex
    [197214] = { drType = "sdr", class = "SHAMAN", isKillSetup = true, type = "instant" },      -- Sundering
    [118905] = { drType = "sdr", class = "SHAMAN", isKillSetup = true, type = "instant" }, -- Static Charge

    -- DK
    [47476] = { drType = "silencedr", class = "DEATHKNIGHT", isKillSetup = true, type = "instant" }, -- Strangulate
    [221562] = { drType = "sdr", class = "DEATHKNIGHT", isKillSetup = true, type = "instant" }, -- Asphyxiate
    [207167] = { drType = "ddr", class = "DEATHKNIGHT", isKillSetup = true, type = "instant" }, -- Blinding Sleet
}

local setupInfo = {
    target = nil,
    pressure = 0,
    burstClass = nil,
    comp = nil,
    compType = nil,
    crossCC = false,
    stunSetup = false,
    goBuff = false,
    setupStyle = nil,
    enemyCCReady = false,
    enemyCCSpellID = nil,
    enemyCCSource = nil,
    enemyCCDrType = nil,
    isKillSetup = false,
    ccTarget = nil,
    killTarget = nil,
}

local function resetSetupInfo()
    setupInfo.target = nil
    setupInfo.pressure = 0
    setupInfo.burstClass = nil
    setupInfo.comp = nil
    setupInfo.compType = nil
    setupInfo.crossCC = false
    setupInfo.stunSetup = false
    setupInfo.goBuff = false
    setupInfo.setupStyle = nil
    setupInfo.enemyCCReady = false
    setupInfo.enemyCCSpellID = nil
    setupInfo.enemyCCSource = nil
    setupInfo.enemyCCDrType = nil
    setupInfo.isKillSetup = false
    setupInfo.ccTarget = nil
    setupInfo.killTarget = nil
end

local function getSetupTarget()
    resetSetupInfo()

    -- In your getSetupTarget() function, update the values with color coding:
    -- local function updateStatusFrame()
    --     if project.settings then
    --         -- Pressure (Red if high, blue if low)
    --         local pressureValue = setupInfo.pressure
    --         project.settings.pressure = pressureValue >= 30
    --             and "|cFFFF0000" .. pressureValue .. "|r" -- Red if high
    --             or "|cFF1EFFFF" .. pressureValue .. "|r" -- Blue if low

    --         -- Enemy Comp (Blue if known, white if unknown)
    --         project.settings.enemyComp = setupInfo.comp
    --             and "|cFF1EFFFF" .. setupInfo.comp .. "|r"
    --             or "|cFFFFFFFF" .. "Unknown" .. "|r"

    --         -- Cross CC (Orange if incoming, green if none)
    --         project.settings.crossCC = setupInfo.crossCC
    --             and "|cFFFF6400Incoming!|r"
    --             or "|cFF00FF00None|r"

    --         -- Burst (Red if active, green if none)
    --         project.settings.burst = setupInfo.goBuff
    --             and "|cFFFF0000Active!|r"
    --             or "|cFF00FF00None|r"

    --         -- Kill Target (Yellow if exists, white if none)
    --         project.settings.killTarget = (setupInfo.killTarget and setupInfo.killTarget.name)
    --             and "|cFFFFFF00" .. setupInfo.killTarget.name .. "|r"
    --             or "|cFFFFFFFFNone|r"
    --     end
    -- end

    if not awful.enemies then return setupInfo end

    local function validEnemy(unit)
        return unit.enemy and not unit.dead and not unit.pet and unit.los
    end

    -- Check for an enemy with an active burst buff from BurstCDS
    local function hasBurstBuff()
        local burstEnemies = awful.enemies.within(40).filter(function(unit)
            return unit.exists and unit.los and (
                unit.used(BurstCDS, 2) or unit.buffFrom(BurstCDS)
            )
        end)

        if #burstEnemies > 0 then
            local burstEnemy = burstEnemies[1]
            setupInfo.goBuff = true
            setupInfo.burstEnemy = burstEnemy
            setupInfo.burstSpellID = burstEnemy.used(BurstCDS, 2) or burstEnemy.buffFrom(BurstCDS)
            return true
        end
        return false
    end


    -- Check for enemies with ready CC abilities from KillSetupAbilities
    local function hasCCReady(unit)
        for spellID, ability in pairs(KillSetupAbilities) do
            if unit.class2 == ability.class and
                unit.cd(spellID) < awful.gcd and
                unit.facing(player) and
                unit.distance <= (unit.ranged and 30 or 10) then
                setupInfo.enemyCCReady = true
                setupInfo.enemyCCSpellID = spellID
                setupInfo.enemyCCSource = unit
                setupInfo.enemyCCDrType = ability.drType
                if ability.drType == "sdr" then
                    setupInfo.stunSetup = true
                elseif ability.drType == "ddr" then
                    setupInfo.disorientSetup = true
                elseif ability.drType == "idr" then
                    setupInfo.incapSetup = true
                end
                return true
            end
        end
        return false
    end

    -- Check for stealth setup indicators
    local function hasStealthSetup(unit)
        if unit.stealth then
            local partnerInRange = awful.enemies.find(function(partner)
                return partner.guid ~= unit.guid and
                    partner.distance <= (partner.ranged and 30 or 10) and
                    partner.facing(player) and
                    KillSetupAbilities[partner.lastCast]
            end)
            if partnerInRange then
                setupInfo.crossCC = true
                return true
            end
        end
        return false
    end

    -- Check for casting CC on targets
    local function hasCastingSetup(unit)
        if unit.casting then
            local ability = KillSetupAbilities[unit.castID]
            if ability and unit.casttarget then
                -- Handle player-targeted CC with DR check
                if unit.casttarget.isUnit(player) then
                    local canDeath = deathTable[unit.castID] and project.cd(swd) > 0
                    local canFade = fadeTable[unit.castID] and fade.cd < awful.gcd
                    local canMeld = IsPlayerSpell(58984) and shadowMeld.cd < awful.gcd
                    if (deathTable[unit.castID] and awful.gcdRemains > unit.castTimeRemains and not (canFade or canMeld)) or
                        not (canDeath or canFade or canMeld) then
                        -- Add DR pressure scoring
                        local drPressure = 0
                        if ability.drType then
                            if player[ability.drType] >= 1 then
                                drPressure = 25 -- Fresh DR
                            elseif player[ability.drType] >= 0.5 then
                                drPressure = 15 -- Half DR
                            end
                        end
                        setupInfo.pressure = setupInfo.pressure + drPressure + (unit.castpct >= 60 and 25 or 15)
                        return true
                    end
                    -- Handle teammate-targeted CC
                elseif unit.casttarget.friend then
                    local friendDR = ability.drType and unit.casttarget[ability.drType] or 0
                    if friendDR >= 1 then
                        setupInfo.pressure = setupInfo.pressure + 20
                        setupInfo.crossCC = true
                        return true
                    end
                end
            end
        end
        return false
    end

    -- Process base enemy information
    local enemies = awful.enemies.filter(validEnemy)
    if #enemies == 0 then return setupInfo end

    -- Get enemies with active burst/CC
    local burstEnemies = enemies.filter(hasBurstBuff)
    local ccEnemies = enemies.filter(hasCCReady)
    local stealthSetups = enemies.filter(hasStealthSetup)
    local castingSetups = enemies.filter(hasCastingSetup)

    -- Adjust pressure based on active threats
    setupInfo.pressure = setupInfo.pressure + (#burstEnemies * 15)
    setupInfo.pressure = setupInfo.pressure + (#ccEnemies * 10)
    setupInfo.pressure = setupInfo.pressure + (#stealthSetups * 25)
    setupInfo.pressure = setupInfo.pressure + (#castingSetups * 20)

    -- Process comp identification
    for compType, compList in pairs(MetaComps) do
        for compName, compData in pairs(compList) do
            local compMatches = enemies.filter(function(enemy)
                for i, requiredClass in ipairs(compData.classes) do
                    if enemy.class2 == requiredClass and compData.specs[i] == enemy.spec then
                        if enemy.target and enemy.target.friend then
                            setupInfo.target = enemy.target
                        end
                        return true
                    end
                end
                return false
            end)
            if #compMatches == #compData.classes then
                setupInfo.comp = compName
                setupInfo.compType = compType
                if compType == "BURST_COMPS" then
                    setupInfo.pressure = setupInfo.pressure + 35
                    setupInfo.setupStyle = "aggressive"
                elseif compType == "CLEAVE_COMPS" then
                    setupInfo.pressure = setupInfo.pressure + 30
                    setupInfo.setupStyle = "pressure"
                elseif compType == "JUNGLE_COMPS" then
                    setupInfo.pressure = setupInfo.pressure + 25
                    setupInfo.setupStyle = "mixed"
                elseif compType == "CASTER_COMPS" then
                    setupInfo.pressure = setupInfo.pressure + 20
                    setupInfo.setupStyle = "rot"
                else
                    setupInfo.pressure = setupInfo.pressure + 20
                    setupInfo.setupStyle = "consistent"
                end
                break
            end
        end
        if setupInfo.comp then break end
    end


    -- Identify kill target
    local function isKillTarget(unit)
        if not unit.friend then return false end
        local total, melee, ranged, cooldowns = unit.v2attackers()
        if cooldowns >= 1 or (total and total >= 2) then
            -- Add DR-based pressure
            local freshDR = false
            for _, ability in pairs(KillSetupAbilities) do
                if ability.drType and unit[ability.drType] >= 1 then
                    freshDR = true
                    break
                end
            end
            if freshDR then
                -- Check for off-target full DR (potential cross CC)
                local offTargetFullDR = awful.friends.find(function(friend)
                    return not friend.isUnit(unit) and (
                        friend.sdr >= 1 or
                        friend.idr >= 1 or
                        friend.ddr >= 1
                    )
                end)
                if offTargetFullDR then
                    setupInfo.pressure = setupInfo.pressure + 30
                    setupInfo.crossCC = true
                end
            end
            return true
        end
        if unit.cc or unit.bcc then
            local hasFollowup = awful.enemies.find(function(enemy)
                local ability = enemy.lastCast and KillSetupAbilities[enemy.lastCast]
                return enemy.distance <= (enemy.ranged and 30 or 10) and
                    enemy.facing(unit) and
                    ability and ability.drType and
                    unit[ability.drType] >= 1    -- Fresh DR for follow-up CC
            end)
            if hasFollowup then return true end
        end
        return false
    end

    local killTargets = awful.fgroup.filter(isKillTarget)
    if #killTargets > 0 then
        setupInfo.killTarget = killTargets.lowest
    elseif project.LowestUnit then
        setupInfo.killTarget = project.LowestUnit
    end
    --updateStatusFrame()
    return setupInfo
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

-- List of spammable CC spells
local spammableCC = {
    -- Incapacitate DR (idr)
    -- Polymorph variants
    [118] = true,       -- Polymorph
    [28272] = true,     -- Polymorph (Pig)
    [61305] = true,     -- Polymorph (Black Cat)
    [61721] = true,     -- Polymorph (Rabbit)
    [28271] = true,     -- Polymorph (Turtle)
    [161372] = true,    -- Polymorph (Peacock)
    [126819] = true,    -- Polymorph (Pig)
    [161355] = true,    -- Polymorph (Penguin)
    [161354] = true,    -- Polymorph (Monkey)
    [161353] = true,    -- Polymorph (Bear Cub)
    [277792] = true,    -- Polymorph (Bumblebee)
    [277787] = true,    -- Polymorph (Direhorn)
    [391622] = true,    -- Polymorph (Duck)
    
    -- Hex variants
    [51514] = true,     -- Hex
    [210873] = true,    -- Hex (Compy)
    [211004] = true,    -- Hex (Spider)
    [211010] = true,    -- Hex (Snake)
    [211015] = true,    -- Hex (Cockroach)
    [269352] = true,    -- Hex (Skeletal Hatchling)
    [277778] = true,    -- Hex (Zandalari Tendonripper)
    [277784] = true,    -- Hex (Wicker Mongrel)
    [309328] = true,    -- Hex (Living Honey)
    
    [20066] = true,     -- Repentance
    
    -- Disorient DR (ddr)
    [33786] = true,     -- Cyclone
    [5782] = true,      -- Fear
    [118699] = true,    -- Fear (Warlock)
    [360806] = true,    -- Sleep Walk

}

hookCallbacks(function(spell)
    burstTracker = {
        enemyBurst = false,
        burstTarget = nil,
        burstEnemy = nil,
        friendBurst = false,
        burstFriend = nil
    }

    local burstEnemy = awful.enemies.within(40).find(function(enemy)
        return enemy.enemy and not enemy.dead and not enemy.pet and
               not (enemy.cc or enemy.bcc) and
               (enemy.used(BurstCDS, 2) or enemy.buffFrom(BurstCDS) or enemy.cds)
    end)

    if burstEnemy then
        burstTracker.enemyBurst = true
        burstTracker.burstEnemy = burstEnemy
        if burstEnemy.target and burstEnemy.target.friend then
            burstTracker.burstTarget = burstEnemy.target
        end
    end


    local burstFriend = awful.fgroup.within(40).find(function(friend)
        return friend.friend and not friend.dead and not friend.pet and
               not (friend.cc or friend.bcc) and
               (friend.used(BurstCDS, 2) or friend.buffFrom(BurstCDS) or friend.cds)
    end)

    if burstFriend then
        burstTracker.friendBurst = true
        burstTracker.burstFriend = burstFriend
    end
end)

-- start of each tick
project.overlappingSpells = {}
project.overlappingDefensives = {}

function project.canCastOverlappingSpell(spell, unit)
    local overlappingSpell = project.overlappingSpells[unit.guid]

    if not overlappingSpell then
        return true
    end

    if spell.id == overlappingSpell.id then
        return true
    end

    return false
end

function project.setOverlappingSpell(spell, unit)
    project.overlappingSpells[unit.guid] = spell
end


project.setDefensive = function(spell, castID)
    if not spell or not castID then return end
    if project.overlappingDefensives == nil then
        project.overlappingDefensives = {}
    end
    project.overlappingDefensives[castID] = spell
end

project.canUseDefensive = function(spell, castID)
    -- Safety checks first
    if not spell or not castID then return true end
    if project.overlappingDefensives == nil then
        project.overlappingDefensives = {}
    end
    
    -- Check if this spell is already registered
    local overlappingSpell = project.overlappingDefensives[castID]
    if overlappingSpell then
        -- Allow if it's the same spell
        if spell.id == overlappingSpell.id then
            return true
        end
        -- Block if different spell
        return false
    end
    
    -- Allow if nothing is registered for this castID
    return true
end

awful.addEventCallback(function(info, event, source, dest)
    if event ~= "SPELL_CAST_SUCCESS" then return end
    local spellID = select(12, unpack(info))
    
    if spammableCC[spellID] then
        project.overlappingDefensives[spellID] = nil
    end
end)

local function shouldApplyPTW()
    -- Dont apply during Rapture with no shields up
    if player.buff(rapture.id) and not project.LowestUnit.buff(PwShield.id) then return false end
    -- Don't apply if we need urgent healing
    if project.LowestHealth <= 40 then return false end

    -- Don't apply during heavy incoming damage
    local total, _, _, cds = project.LowestUnit.v2attackers()
    if cds > 0 and project.LowestUnit.hpa < 75 then return false end

    -- Check if we have enough DoTs up already
    local ptwCount = 0
    awful.enemies.within(40).loop(function(enemy)
        if enemy.debuff(purgeTheWickedDebuff.id, player) then
            ptwCount = ptwCount + 1
        end
    end)

    return ptwCount < project.settings.ptw
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

local function allUnitsInCombat(units)
    local allUnitsAreInCombat = false
    local unitsCount = 0
    local unitsInCombatCount = 0

    units.loop(function(unit)
        unitsCount = unitsCount + 1

        if unit.isInCombat then
            unitsInCombatCount = unitsInCombatCount + 1
        end
    end)

    if unitsInCombatCount == unitsCount then
        allUnitsAreInCombat = true
    end

    return allUnitsAreInCombat
end

function project.setCombatStarted()
    if project.combatStarted then
        return
    end

    local allEnemiesAreInCombat = allUnitsInCombat(awful.enemies)
    local allFriendsAreInCombat = allUnitsInCombat(awful.fgroup)

    if allEnemiesAreInCombat and allFriendsAreInCombat then
        project.combatStarted = true
    end
end

project.delay = awful.delay(0.2, 0.8)
function project.random(number, multiply)
    -- Ensure 'number' is a number; if not, set a default
    if type(number) ~= "number" then
        number = 0 -- or any other default value
    end

    -- Ensure 'multiply' is set to a default value if it's nil
    if not multiply then multiply = 4 end

    return (number + (project.delay.now * multiply))
end

function project.QueueAlertAndAccept()
    if project.settings.autoaccept then
        local battlefieldStatus = GetBattlefieldStatus(1)
        if not battlefieldStatus then return end
        if battlefieldStatus == "confirm" then
            awful.call("AcceptBattlefieldPort", 1, true)
        end
    end
end

function project.grabFlag()
    if not project.settings.grabflag then return end
    if select(2, IsInInstance()) ~= "pvp" then return end

    local flag = awful.objects.within(10)
        .find(function(obj) 
            return obj.id == 227741 or 
                   obj.id == 227740 or 
                   obj.id == 227745 
        end)

    if not flag then return end
    if flag.distanceLiteral > 10 then return end

    if Unlocker.type == "daemonic" then
        Interact(flag.pointer)
    else
        LeftClickObject(flag.pointer)
    end
end

function project.cd(spellObject)
    local gcd = 0
    if spellObject.gcd > 0 then
        gcd = awful.gcdRemains
    end
    return spellObject.cooldown - gcd
end

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

if project.settings.autoShadowMeld and player.hasTalent(shadowMeld.id) then
    awful.onEvent(function(info, event, source, dest)
        local spellID = select(12, unpack(info))
        if not player.hasTalent(shadowMeld.id) then return end
        if event ~= "SPELL_CAST_SUCCESS" then return end
        if not source.enemy then return end
        if source == nil then return end

        if shadowMeld.cd > awful.gcd then return end
        if spellID == 107570 and dest.isUnit(player) then
            if source.distanceLiteral <= 8 then return end
            return shadowMeld:Cast(player, { stopMoving = true }) and
                awful.alert("Meld Bolt", 107570)
        end

        if shadowMeld.cd > awful.gcd then return end
        if spellID == 6789 and dest.isUnit(player) then
            if source.distanceLiteral <= 8 then return end
            return shadowMeld:Cast(player, { stopMoving = true }) and
                awful.alert("Meld Coil", 6789)
        end

        if fade.cd < awful.gcd then
            if spellID == 323639 and dest.isUnit(player) then
                return fade:Cast() and
                    awful.alert("The Hunt", 323639)
            end
        elseif shadowMeld.cd < awful.gcd then
            if spellID == 323639 and dest.isUnit(player) then
                return shadowMeld:Cast(player, { stopMoving = true }) and
                    awful.alert("The Hunt", 323639)
            end
        end
    end)
end

function project.autoFocus()
    if project.settings.afocus then awful.AutoFocus() end
end

local triggerEffects = {
    [109248] = { -- Binding Shot
        name = "Binding Shot",
        radius = 5,
        stun = true,
        checkMoving = true,
    },
    [207684] = { -- Sigil of Misery
        name = "Sigil of Misery",
        radius = 8,
        disorient = true,
        impact = 1.5, -- Time before effect
    }
}

awful.addUpdateCallback(function()
    if commonChecks.castingOrChanneling() then return end
    awful.triggers.track(function(trigger, uptime)
        local id = trigger.id
        if not id then return end
        local effect = triggerEffects[id]
        if not effect then return end
        if fade.cd > awful.gcd then return end

        local x, y, z = trigger.position()
        local currentDist = player.distanceToLiteral(x, y, z)

        -- Handle DR checks
        if effect.stun and player.sdr < 0.5 then return end
        if effect.disorient and player.ddr < 0.5 then return end

        -- Check impact timing
        if effect.impact and uptime < effect.impact then return end

        if id == 109248 then                     -- Binding Shot specific handling
            if not player.moving then return end -- Only react when moving
            if currentDist > effect.radius then return end

            local px, py, pz = player.position()
            local movingDir = player.movingDirection
            local nextX = px + (math.cos(movingDir) * player.speed * 0.5)
            local nextY = py + (math.sin(movingDir) * player.speed * 0.5)

            local futureDistance = player.distanceToLiteral(nextX, nextY, pz, x, y, z)
            if futureDistance > currentDist then
            return fade:Cast() and awful.alert("Fade " .. effect.name)
            end
        -- else
        --     -- Non-Binding Shot triggers
        --     if currentDist <= effect.radius then
        --         return fade:Cast() and awful.alert("Fade " .. effect.name)
        --     end
        end
    end)

    awful.totems.track(function(totem, uptime)
        local sham = awful.enemies.find(function(unit) return unit.class2 == "SHAMAN" and not unit.dead end)
        if not sham then return end
        if totem.id == 61245 then -- Cap Totem
            if player.distanceTo(totem) <= 8 and player.sdr >= 0.5 and uptime >= 1.5 then
                fade:Cast()
            end
        end
    end)

    local function dragon(unit)
        return unit.buff(433874) and not unit.dead and unit.enemy and not unit.pet and unit.los and
            unit.predictDistance(0.3, player) <= 10
    end
    local nerd = awful.enemies.within(15).filter(dragon)
    if nerd and #nerd < 1 then return end
    fade:Cast()
end)


awful.addUpdateCallback(function()
    local nerd = nil
    local aids = false
    if not project.isInValidInstance() then return end
    if commonChecks.castingOrChanneling() then return end
    if not player.casting and player.castID == mindGames.id then return end
    if not player.hasTalent(mindGames.id) then return end
    if project.holdGCD then return end

    awful.enemies.within(purgeTheWicked.range).loop(function(enemy)
        if project.cd(purgeTheWicked) > 0 then return end
        if not enemy.los and project.hasLosBehindIceWall(player, enemy) then return end
        if enemy.bcc then return end
        if not player.facing(enemy) then return end
        if enemy.buffFrom(enemyReflect) then
            aids = true
            nerd = enemy
        end
    end)
    if not aids then return end
    return purgeTheWicked:Cast(nerd)
end)

awful.addUpdateCallback(function()
    if not project.isInValidInstance() then return end
    if not player.hasTalent(surgeOfLight.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.holdGCD then return end

    if not player.buff(SoLBuff.id) then return end
    if not SoL:Castable(project.LowestUnit) then return end
    if project.LowestUnit and project.LowestUnit.immuneHealing then return end
    if project.LowestHealth > (project.settings.sol) then return end
    if project.cd(SoL) > 0 then return end
    if awful.gcdRemains > 0 then return end
    if SoL:Cast(project.LowestUnit) then
        return awful.alert({
            message = "Casting Surge of Light Heal on " .. project.LowestUnit.name,
            texture = 2061,
        })
    end
end)

awful.addEventCallback(function(info, event, source, dest)
    local spellID = select(12, unpack(info))
    if not player.hasTalent(phaseShift.id) then return end
    if not project.isInValidInstance() then return end
    if commonChecks.castingOrChanneling() then return end
    if event ~= "SPELL_CAST_SUCCESS" then return end
    if source == nil then return end
    if source.friend then return end
    if not source.enemy then return end
    if not dest.isUnit(player) then return end
    if fade.cd > awful.gcd then return end

    local fadeCondition = fadeTable[spellID]
    if fadeCondition then
        local result = fadeCondition(source)
        if result then
            
            return fade:Cast()
        end
    end
end)

awful.onEvent(function(_, event, isReloadingUi)
    if not IsPlayerSpell(428924) then return end
    if event == "PLAYER_ENTERING_WORLD" and not isReloadingUi then
        project.overlappingDefensives = {}
        project.insightCast = false
        project.pietyCast = false
        project.solaceCast = false
        project.clairvoyanceCast = false
        project.shieldingSequence = false
        project.hasAttemptedCollection = false
    end
end)

awful.addEventCallback(function(eventinfo, event, source)
    if not IsPlayerSpell(428924) then return end
    local spellID = select(12, unpack(eventinfo))
    if event ~= "SPELL_CAST_SUCCESS" then return end
    if source == nil then return end
    if not source.player then return end

    if spellID == insight.id then
        project.insightCast = true
        project.pietyCast = false
        project.solaceCast = false
        project.clairvoyanceCast = false
    end

    if spellID == piety.id then
        project.pietyCast = true
    end

    if spellID == solace.id then
        project.solaceCast = true
    end

    if spellID == clairvoyance.id then
        project.clairvoyanceCast = true
        -- Reset all flags after sequence complete
        project.insightCast = false
        project.pietyCast = false
        project.solaceCast = false
        project.clairvoyanceCast = false
    end
end)

awful.addEventCallback(function(eventinfo, event, source, dest)
    if event ~= "SPELL_CAST_SUCCESS" then return end
    if source == nil then return end
    if not source.enemy then return end
    local spellID = select(12, unpack(eventinfo))
    if not awful.enemies.within(50).find(function(enemy) return enemy.class2 == "HUNTER" end) then return end
    if commonChecks.castingOrChanneling() then return end

    -- Diamond Ice Trap - Fade only
    if spellID == 203340 then
        if not project.canUseDefensive(fade, spellID) then return end
        if fade.cd > awful.gcd then return end
        if fade:Cast() then
        project.setDefensive(fade, spellID)
        return true
        end
    end
    
    if spellID == 187650 then
        if fade.cd < awful.gcd then
            if not project.canUseDefensive(fade, spellID) then return end
            if fade:Cast() then
            project.setDefensive(fade, spellID)
            return true
            end
        end

        if project.cd(fade) > 0 and project.cd(swd) <= 0 and not player.used(fade.id, 0.5) and source.los then
            if not project.canUseDefensive(swd, spellID) then return end
            if swd:Cast(source) then
                project.setDefensive(swd, spellID)
                return true
            end
        end
    end
end)

local MissileCCs = {
    [187650] = { speed = 20.5, radius = 1.5 }, -- Freezing Trap
}

local MissileCCs2 = {
    [203340] = { speed = 20.5, radius = 1.5 }, -- Diamond Ice Trap (same as freeze trap)
}

awful.addUpdateCallback(function()
    local aids = false
    if not project.isInValidInstance() then return end
    if commonChecks.castingOrChanneling() then return end
    
    if fade.cd > awful.gcd then return end
    if swd.prevgcd then return end
    if player.used(swd.id, 0.5) then return end

    awful.missiles.track(function(missile)
        local id = missile.spellId
        local missileInfo = MissileCCs[id] or MissileCCs2[id]
        if not id or not missileInfo then return end
        if missile.source == nil then return end

        local missilecreator = awful.GetObjectWithGUID(missile.source)
        if missilecreator.friend then return end
        if missile.source.friendly then return end
        if missile.source.friend then return end

        local px, py, pz = player.position()
        local distanceToMissile = player.distanceToLiteral(missile.x, missile.y, missile.z, px, py, pz)
        local timeToImpact = distanceToMissile / missileInfo.speed

        -- Fade slightly before impact
        if timeToImpact <= 0.5 and distanceToMissile <= missileInfo.radius + 2 then
            if not project.canUseDefensive(fade, id) then return end
            aids = true
        end
    end)

    if not aids then return end
    if fade:Cast() then
    project.setDefensive(fade, id)
    return true end
end)

local Missiles = {
    [6789] = { speed = 30 }, -- Mortal Coil
}

awful.addUpdateCallback(function()
    if fade.cd > awful.gcd then return end
    if commonChecks.castingOrChanneling() then return end
    
    awful.missiles.track(function(missile)
        local id = missile.spellId
        local missileInfo = Missiles[id]
        if not id or not missileInfo then return end
        if missile.source == nil then return end

        local missilecreator = awful.GetObjectWithGUID(missile.source)
        if not missilecreator or missilecreator.friend then return end
        
        -- Check if we're the target
        local targetGUID = missile.dest
        local targetUnit = awful.GetObjectWithGUID(targetGUID)
        if not targetUnit or not targetUnit.isUnit(player) then return end
        
        -- Calculate time to impact
        local px, py, pz = player.position()
        local distanceToMissile = awful.distanceToLiteral(px, py, pz, missile.x, missile.y, missile.z)
        local timeToImpact = distanceToMissile / missileInfo.speed

        if timeToImpact <= 0.5 then
            if not project.canUseDefensive(fade, id) then return end
            if fade:Cast() then
                project.setDefensive(fade, id)
                awful.alert("Fade - Mortal Coil ")
                return true
            end
        end
    end)
end)

local MissileCCs = {
    [187650] = { speed = 20.5, radius = 1.5 }, -- Freezing Trap
}

awful.addUpdateCallback(function()
    local aids = false
    if not project.isInValidInstance() then return end
    if commonChecks.castingOrChanneling() then return end
    
    if fade.prevgcd then return end
    if player.used(fade.id, 0.5) then return end
    if project.cd(swd) > 0 then return end

    awful.missiles.track(function(missile)
        local id = missile.spellId
        local missileInfo = MissileCCs[id]

        if not id or not missileInfo then return end
        if missile.source == nil then return end
        local missilecreator = awful.GetObjectWithGUID(missile.source)
        if missilecreator.friend then return end

        -- Calculate time to impact
        local px, py, pz = player.position()
        local distanceToMissile = player.distanceTo(missile.x, missile.y, missile.z, px, py, pz)
        local timeToImpact = distanceToMissile / missileInfo.speed

        -- Death slightly before impact
        if timeToImpact <= 0.5 and distanceToMissile <= missileInfo.radius + 2 then
            aids = true
            source = missilecreator
        end
    end)

    if not aids then return end
    if not project.canUseDefensive(swd, id) then return end
    if swd:Cast(source) then
    project.setDefensive(swd, id)
    return true
    end
end)

local function friendCastingCC(unit)
    return unit.friend
        and not unit.dead
        and not unit.pet
        and unit.casting
        and (deathTable[unit.castID] or unit.castID == 33786)
        and unit.castTarget.isUnit(enemyHealer)
end


local function handleEnemy(enemy, class, spellId, range, facing)
    if commonChecks.castingOrChanneling() then return end
    if enemy.class2 ~= class then return end
    if enemy.gcdRemains > 0.8 then return end
    if enemy.cd(spellId) > 1 then return end
    if facing and not enemy.facing(player) then return end
    if enemy.cc or enemy.bcc then return end

    -- Enhanced Rogue detection for Kidney
    if spellId == 408 then
        if player.sdr < 0.5 then return end
        
        local partnerBursting = false
        awful.enemies.within(40).loop(function(partner)
            if partner.guid ~= enemy.guid and (partner.buffFrom(BurstCDS) or partner.cds) then
                partnerBursting = true
                return true
            end
        end)
        
        if partnerBursting and fade.cd < awful.gcd and enemy.distanceTo(player) <= 6 then
            if (player.casting or player.channel) then
                awful.call("SpellStopCasting")
            end
            return fade:Cast()
        end
    else
        if spellId == 853 and player.sdr < 0.5 then return end    -- HoJ
        if spellId == 8122 and player.ddr < 0.5 then return end   -- Psychic Scream
        if spellId == 119381 and player.sdr < 0.5 then return end -- Leg Sweep
        if spellId == 5211 and player.sdr < 0.5 then return end   -- Bash
    end

    local currentDist = enemy.distanceTo(player)
    local predictedDist = enemy.predictDistanceLiteral(0.3, player)
    local predictedLoS = enemy.predictLoS(0.3, player)

    if (predictedDist <= range or currentDist <= range) and predictedLoS then
        if spellId == 853 then
            if fade.cd < awful.gcd then
                if (player.casting or player.channel) then
                    awful.call("SpellStopCasting")
                end
                return fade:Cast()
            end
            if shadowMeld.cd < awful.gcd and fade.cd < awful.gcd and 
               not player.buff(phaseShiftBuff.id) and player.lastCast ~= fade.id then
                if (player.casting or player.channel) then
                    awful.call("SpellStopCasting")
                end
                return shadowMeld:Cast({ stopMoving = true })
            end
        else
            if fade.cd < awful.gcd then
                if (player.casting or player.channel) then
                    awful.call("SpellStopCasting")
                end
                return fade:Cast()
            end
        end
    end

    return false
end

    function Faded()
    if commonChecks.castingOrChanneling() then return end
    if not project.isInValidInstance() then return end

    if player.hasTalent(408557) then
        awful.enemies.within(40).loop(function(enemy)
            if handleEnemy(enemy, "PALADIN", 853, 11, true) then
                awful.alert({
                    message = "Casting Fade to avoid potential Hammer of Justice",
                    texture = 586,
                })
                return
            elseif handleEnemy(enemy, "PRIEST", 8122, 8, true) then
                awful.alert({
                    message = "Casting Fade to avoid potential Psychic Scream",
                    texture = 586,
                })
                return
            elseif handleEnemy(enemy, "ROGUE", 408, 5, true) then
                awful.alert({
                    message = "Casting Fade to avoid potential Kidney Shot",
                    texture = 586,
                })
                return
            elseif handleEnemy(enemy, "MONK", 119381, 5, true) then
                awful.alert({
                    message = "Casting Fade to avoid potential Leg Sweep",
                    texture = 586,
                })
                return
            elseif handleEnemy(enemy, "DRUID", 5211, 10, true) then
                awful.alert({
                    message = "Casting Fade to avoid potential Mighty Bash",
                    texture = 586,
                })
                return
            end
        end)
    end
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
        local maxDistance = 40 + awful.bin(player.hasTalent(phantomReach.id)) * 0.15
        if unit.distance > maxDistance then return end

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

        if unit.hpa < project.LowestHealth then
            project.SecondLowestHealth = project.LowestHealth
            project.SecondLowestUnit = project.LowestUnit
            project.LowestHealth = unit.hpa
            project.LowestUnit = unit
        elseif unit.hpa < project.SecondLowestHealth then
            project.SecondLowestHealth = unit.hpa
            project.SecondLowestUnit = unit
        end

        if not unit.isUnit(player) and unit.health < project.LowestActualHealth then
            project.LowestActualHealth = unit.health
            project.LowestActualUnit = unit
        end
    end)
end

awful.addActualUpdateCallback(function()
    project.Lowest()
    Faded()
end)

function project.usemedallion()
    if project.medallion:Usable() and player.hp < project.settings.md and project.cd(project.medallion) <= 0 then
        project.medallion:Use()
    end
    if project.medallion2:Usable() and player.hp < project.settings.md and project.cd(project.medallion2) <= 0 then
        project.medallion2:Use()
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
    if project.healthStone:Usable() and player.hp < project.settings.hst and project.healthStone.count >= 1 and project.healthStone.cd <= 0 then
        project.healthStone:Use()
    end
end

PwBarrier:Callback(function(spell)
    if not project.settings.pwb then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if player.moving then
        awful.controlMovement(awful.buffer + awful.tickRate * 2)
    end

    local setupInfo = getSetupTarget()

    -- Check for smoked targets first - highest priority
    local smokedTarget = awful.fgroup.find(function(friend)
        return friend.debuffFrom(rogueCDS)
    end)

    if smokedTarget then
        local x, y, z = smokedTarget.position()
        return spell:AoECast(x, y, z) and awful.alert("Barrier - Smoke Bomb")
    end

    -- Comp-specific logic based on setupInfo
    if setupInfo.pressure >= 30 and setupInfo.killTarget then
        -- BURST_COMPS (RMP, FMP, Dancing with Stars, RPD, God Comp, FPX)
        if setupInfo.setupStyle == "aggressive" and
            (setupInfo.crossCC or setupInfo.goBuff or
                (setupInfo.stunSetup and project.LowestUnit.sdr >= 1)) then
            return spell:SmartAoE(setupInfo.killTarget) and awful.alert("Barrier - Burst Setup")
        end

        -- CLEAVE_COMPS (DH DK, TWD, Thunder Cleave, PHDK, DK Ele, etc)
        if setupInfo.setupStyle == "pressure" then
            if setupInfo.killTarget.hp <= 80 then
                return spell:SmartAoE(setupInfo.killTarget) and awful.alert("Barrier - Heavy Cleave")
            end
        end

        -- JUNGLE_COMPS & Mixed Damage
        if setupInfo.setupStyle == "mixed" and setupInfo.killTarget.hpa <= 85 then
            return spell:SmartAoE(setupInfo.killTarget) and awful.alert("Barrier - Mixed Damage")
        end

        -- CASTER_COMPS (Shadowplay, Shadow Cleave, LSPala, Demo Boomy, etc)
        if setupInfo.setupStyle == "rot" and setupInfo.killTarget.hpa <= 85 then
            if setupInfo.crossCC or setupInfo.pressure >= 35 then
                return spell:SmartAoE(setupInfo.killTarget) and awful.alert("Barrier - Heavy Rot")
            end
        end

        -- Default case for unknown comps
        if setupInfo.setupStyle == "consistent" and setupInfo.killTarget.hpa <= 80 then
            if setupInfo.crossCC or setupInfo.pressure >= 35 then
                return spell:SmartAoE(setupInfo.killTarget) and awful.alert("Barrier - High Pressure")
            end
        end
    end

    -- Fallback logic for unrecognized comps or general burst conditions
    local burstTarget = awful.enemies.within(40).find(function(enemy)
        if not enemy.exists or not enemy.los then return false end
        return enemy.cds or enemy.buffFrom(BurstCDS) or enemy.used(BurstCDS, 2)
    end)

    if burstTarget then
        local targetFriend = awful.fgroup.within(40).find(function(friend)
            if friend.buff(painSuppression.id) then return false end
            local total, melee, ranged, cooldowns = friend.v2attackers()
            if cooldowns < 1 then return false end
            if friend.hpa > 85 then return false end
            return true
        end)

        if targetFriend then
            return spell:SmartAoE(targetFriend) and awful.alert("Barrier - Enemy Burst")
        end
    end
end)

ultimatePenitence:Callback("cancel", function(spell)
    if player.channel and player.channelID == ultimateChannel.id then
        if project.LowestHealth <= project.settings.vs and project.cd(voidShift) <= 0 then
            awful.call("CancelSpellByName", "Ultimate Penitence")
        elseif
        player.casting and player.castID == ultimatePenitence.id and project.LowestHealth <= project.settings.vs and project.cd(voidShift) <= 0 then
            awful.call("SpellStopCasting")
        end
    end
end)

ultimatePenitence:Callback("tyrant", function(spell)
    local aids = false
    if not player.hasTalent(ultimatePenitence.id) then return end
    if wasCasting[ultimatePenitence.id] then return end
    if player.buff(rapture.id) then return end
    if project.cd(spell) > 0 then return end
    awful.tyrants.loop(function(tyrant)
        if project.LowestHealth <= 25 and project.cd(voidShift) <= 0 then return end
        if not project.LowestUnit.losOf(player) then return end
        if project.LowestHealth > math.random(75, 80) then return end
        if tyrant.id == 135002 and tyrant.enemy then
            aids = true
        end
    end)
    if not aids then return end
    return spell:Cast(project.LowestUnit)
end)

ultimatePenitence:Callback("lowHP", function(spell)
    if not player.hasTalent(ultimatePenitence.id) then return end
    if wasCasting[ultimatePenitence.id] then return end
    if project.cd(spell) > 0 then return end
    if player.buff(rapture.id) then return end
    if project.LowestUnit.predictDistance(0.5, player) > spell.range then return end
    if project.LowestHealth <= 25 and project.cd(voidShift) <= 0 and not project.LowestUnit.isUnit(player) then return end
    if project.LowestHealth > project.random(55) then return end
    if not project.LowestUnit.predictLoS(0.5, player) then return end
    return spell:Cast(project.LowestUnit)
end)

ultimatePenitence:Callback("lowMana", function(spell)
    if not player.hasTalent(ultimatePenitence.id) then return end
    if wasCasting[ultimatePenitence.id] then return end
    if project.cd(spell) > 0 then return end
    if player.buff(rapture.id) then return end
    if project.LowestUnit.predictDistance(0.5, player) > spell.range then return end
    if project.LowestHealth <= 25 and project.cd(voidShift) <= 0 then return end
    if project.LowestHealth > project.random(40) then return end
    if not project.LowestUnit.predictLoS(0.5, player) then return end
    if player.manaPct > project.random(30) then return end
    return spell:Cast(project.LowestUnit)
end)

shadowMeld:Callback(function(spell)
    local aids = false
    local cast = nil
    if not IsPlayerSpell(58984) then return end
    if commonChecks.castingOrChanneling() then return end
    if spell.cd and project.cd(spell) > 0 then return end
    if fade.cd < awful.gcd then return end
    if project.cd(swd) <= 0 then return end
    if player.used(swd.id, 0.5) then return end
    if player.used(fade.id, 0.5) then return end


    awful.enemies.within(40).loop(function(enemy)
        if enemy.casting and
            deathTable[enemy.castID] and
            enemy.castTarget and
            enemy.castTarget.isUnit(player) and
            enemy.castRemains and enemy.castRemains <= 0.5 and
            enemy.los then
            if not project.canUseDefensive(shadowMeld, enemy.castID) then return end
            aids = true
            cast = enemy.castID
        end
    end)

    if not aids then return end
    if spell:Cast(player, { stopMoving = true }) then
        project.setDefensive(shadowMeld, cast)
        return true
    end
end)

shadowMeld:Callback("clone", function(spell)
    local aids = false
    if not IsPlayerSpell(58984) then return end
    if commonChecks.castingOrChanneling() then return end
    if spell.cd and project.cd(spell) > 0 then return end
    if fade.cd and fade.cd < awful.gcd then return end
    if player.ddr and player.ddr < 0.5 then return end
    if player.used(fade.id, 0.5) then return end

    awful.enemies.within(40).loop(function(enemy)
        if enemy.casting and enemy.castID == 33786
            and enemy.castTarget
            and enemy.castTarget.isUnit(player)
            and enemy.castRemains and enemy.castRemains <= 0.5
            and enemy.los then
            aids = true
        end
    end)

    if not aids then return end
    return shadowMeld:Cast(player, { stopMoving = true })
end)


swd:Callback("cc", function(spell)
    local delay = awful.delay(0.250, 0.300)
    project.holdGCD = false
    if not project.settings.swd then return end
    if commonChecks.castingOrChanneling() then return end
    
    if project.cd(spell) > 0 then return end
    if player.buff(8178) then return end
    if player.buff(phaseShiftBuff.id) then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if not enemy then return end
        if not enemy.casting then return end
        if not deathTable[enemy.castID] then return end
        if not enemy.castTarget or not enemy.castTarget.isUnit(player) then return end
        if player.lastCast == fade.id then return end

        -- If cast is about to finish, try to death it
        if enemy.castTimeLeft <= 0.5 then
            if (player.casting or player.channel) then
                awful.call("SpellStopCasting")
            else
                if not project.canUseDefensive(swd, enemy.castID) then return end
                spell:Cast(enemy, { face = true })
                project.setDefensive(swd, enemy.castID)
                return project.holdGCD
            end
        end

        -- Otherwise, if cast is coming up soon hold GCD and stop casting
        if enemy.castTimeLeft <= awful.gcd + awful.buffer then
            if player.casting and player.castRemains > 0.1 then
                awful.call("SpellStopCasting")
            end
            if player.channeling and player.channelRemains > 0.1 then
                awful.call("SpellStopCasting")
            end
            project.holdGCD = true
            return project.holdGCD
        end
    end)

    return project.holdGCD
end)


swd:Callback("preSWD", function(spell)
    project.holdGCD = false
    local offset = 0.8
    if project.cd(spell) > 0 then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if enemy.class2 == "PRIEST" and player.ddr >= 0.5 and enemy.cd(8122) <= 1 and enemy.facing(player) and enemy.gcdRemains <= offset then
            if (enemy.predictDistance(offset, player) <= 11 or enemy.distanceTo(player) <= 11) then
                if player.recentlyCast(fade.id, 0.5) then return end
                if fade.cd < awful.gcd then return end
                project.holdGCD = true
            end

            if (enemy.predictDistance(offset, player) <= 8 or enemy.distanceTo(player) <= 8) then
                if player.recentlyCast(fade.id, 0.5) then return end
                if fade.cd < awful.gcd then return end
                spell:Cast(enemy)
                return true
            end
        elseif enemy.class2 == "WARRIOR" and player.ddr >= 0.5 and enemy.cd(5246) <= 1 and enemy.facing(player) and enemy.gcdRemains <= offset then
            if (enemy.predictDistance(offset, player) <= 12 or enemy.distanceTo(player) <= 12) then
                project.holdGCD = true
            end

            if (enemy.predictDistance(offset, player) <= 10 or enemy.distanceTo(player) <= 10) and enemy.gcdRemains <= offset then
             spell:Cast(enemy)
             return true
            end
        elseif enemy.class2 == "PALADIN" and player.ddr >= 0.5 and enemy.hasTalent(115750) and enemy.cd(115750) <= 1 and enemy.cd(853) > awful.gcd and enemy.facing(player) and enemy.gcdRemains <= offset then
            if (enemy.predictDistance(offset, player) <= 11 or enemy.distanceTo(player) <= 11) then
                project.holdGCD = true
            end

            if (enemy.predictDistance(offset, player) <= 10 or enemy.distanceTo(player) <= 10) and enemy.gcdRemains <= offset then
                spell:Cast(enemy)
            end
        end
        
    end)
    return project.holdGCD
end)


swd:Callback("pets", function(spell)
    project.holdGCD = false
    if not project.settings.swd then return end
    if commonChecks.castingOrChanneling() then return end
    if player.used(fade.id, 0.5) then return end

    local targetPet = awful.enemyPets.within(spell.range)
        .find(function(pet)
            if not pet.casting then return false end
            if not pet.enemy then return false end
            if not pet.los then return false end
            if pet.castID ~= 6358 then return false end
            if pet.castRemains > 0.5 then return false end
            if not pet.castTarget.isUnit(player) then return false end
            if awful.gcdRemains > pet.castRemains then return false end
            if player.ddr < 0.5 then return false end
            return true
        end)

    if not targetPet then return end

    if project.cd(spell) <= 0 then
        spell:Cast(targetPet, { ignoreCasting = true, ignoreChanneling = true })
    elseif fade.cd < awful.gcd then
        fade:Cast()
        project.holdGCD = true
    end

    return project.holdGCD
end)

swd:Callback("lowHP", function(spell)
    if commonChecks.castingOrChanneling() then return end
    local nerd = nil
    local aids = false
    if project.cd(spell) > 0 then return end
    awful.enemies.within(spell.range).loop(function(enemy)
        if enemy.pet then return end
        if not player.facing(enemy) then return end
        if enemy.buff(5384) then return end
        if enemy.hpa <= 19 and enemy.predictLos(0.5, player) and not enemy.immuneMagic then
            aids = true
            nerd = enemy
        end
    end)
    if not aids then return end
    return spell:Cast(nerd, { ignoreChanneling = true, ignoreCasting = true })
end)

psychicScream:Callback("enemyHealer", function(spell)
    project.holdGCD = false
    if commonChecks.castingOrChanneling() then return end
    if not spell:Castable(enemyHealer) then return end
    if project.cd(spell) > 0 then return end
    if player.debuff(410126) and player.debuffRemains(410126) > awful.buffer then return end
    
    -- Check for friendly CC casts
    local friendCasting = awful.fgroup.find(friendCastingCC)
    if friendCasting then return end

    local tremorTotem = awful.totems.within(30)
        .find(function(obj) 
            return obj.id == 5913 and 
                   obj.creator.enemy and 
                   obj.distanceTo(enemyHealer) < 30 
        end)

    if tremorTotem and tremorTotem.los and tremorTotem.dist <= 40 and tremorTotem.hp <= purgeTheWicked.damage * 2 then
    purgeTheWicked:Cast(tremorTotem)
    end

    if tremorTotem then return end
    
    if not enemyHealer.los then return end
    if enemyHealer.ddr < 0.5 then return end
    if enemyHealer.immuneMagic and enemyHealer.magicEffectImmunityRemains > awful.buffer then return end
    if enemyHealer.immuneCC and enemyHealer.ccImmunityRemains > awful.buffer then return end
    if enemyHealer.used(swd.id, 0.2) then return end

    -- Check if healer is in/approaching fear range
    if enemyHealer.distanceLiteral > 9 then return end

    -- If conditions are good for immediate fear
    if not (enemyHealer.cc or enemyHealer.bcc) then
        if (player.casting or player.channel) then
            awful.call("SpellStopCasting")
        end
        project.holdGCD = true
        spell:Cast()
        return project.holdGCD
    end

    -- Check CC about to drop
    if (enemyHealer.cc and enemyHealer.ccRemains > 1 or 
            enemyHealer.bcc and enemyHealer.bccRemains > 1 or 
            enemyHealer.silence and enemyHealer.silenceRemains > 1) then
        return
    end

    -- Cast when CC is about to drop
    if enemyHealer.ccRemains <= awful.buffer or 
       enemyHealer.bccRemains <= awful.buffer or 
       enemyHealer.silenceRemains <= awful.buffer then
        if (player.casting or player.channel) then
            awful.call("SpellStopCasting")
        end
        project.holdGCD = true
        spell:Cast()
        return project.holdGCD
    end

    return project.holdGCD
end)

psychicScream:Callback("burst", function(spell)
    project.holdGCD = false
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    local tremorTotem = awful.totems.within(30)
        .find(function(obj) 
            return obj.id == 5913 and obj.creator.enemy 
        end)

    local nerd = awful.enemies.within(spell.range)
        .find(function(enemy)
            local total, _, _, _ = enemy.v2attackers()
            if total >= 1 then return false end
            if tremorTotem and tremorTotem.distanceTo(enemy) < 30 then return false end
            if not enemy.los then return false end
            if enemy.ddr < 0.5 then return false end
            if enemy.class2 == "WARRIOR" and enemy.cd(18499) - enemy.gcdRemains > 0 then return false end
            if enemy.immuneMagic and enemy.magicEffectImmunityRemains > awful.gcdRemains then return false end
            if enemy.immuneCC and enemy.ccImmunityRemains > awful.gcdRemains then return false end
            if not (enemy.cds or enemy.buffFrom(BurstCDS) or enemy.used(BurstCDS, 2)) then return false end
            if enemyHealer.exists and enemyHealer.losOf(enemy) and not (enemyHealer.cc or enemyHealer.bcc) then return false end
            if enemy.distanceLiteral > 8 then return false end
            return true
        end)

    if not nerd then return end
    project.holdGCD = true

    if (player.casting or player.channel) then
        awful.call("SpellStopCasting")
        spell:Cast()
    else
    spell:Cast()
    end

    return project.holdGCD
end)

psychicScream:Callback("pets", function(spell)
    local tremorTotem = awful.totems.within(30).find(function(obj) return obj.id == 5913 and obj.creator.enemy end)
    local hunter = awful.enemies.within(40).find(function(unit) return unit.class2 == "HUNTER" or unit.class2 == "WARLOCK" and
        unit.buffFrom(BurstCDS) end)
    local stupidPets = awful.enemyPets.within(spell.range).filter(function(pet) return not pet.bcc and not pet.cc and
        pet.ddr >= 0.5 end)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(voidTendrils) <= 0 then return end
    if project.cd(spell) > 0 then return end

    if not hunter then return end
    if #stupidPets < 2 then return end
    if tremorTotem then return end
    return spell:Cast()
end)


archAngel:Callback("rapture", function(spell)
    if not player.hasTalent(archAngel.id) then return end
    if commonChecks.castingOrChanneling() then return end

    if project.cd(spell) > 0 then return end
    if (rapture.prevgcd or player.used(rapture.id, awful.gcd) or player.buff(rapture.id)) then
        return spell:Cast() and
            awful.alert({
                message = "Archangel",
                texture = 197862, -- Archangel texture
            })
    end
end)

archAngel:Callback("noRapture", function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if project.cd(rapture) <= 0 then return end
    if (project.LowestHealth > project.random(project.settings.pwr) and project.cd(PwRadiance) > 0 or
            project.LowestHealth > project.random(project.settings.penance) and project.cd(penance) > 0) then
        return
    end
    return spell:Cast() and
        awful.alert({
            message = "Archangel",
            texture = 197862, -- Archangel texture
        })
end)

leapOfFaith:Callback(function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(rapture) <= 0 then return end
    if voidShift.cd < awful.gcd then return end
    if voidShift.prevgcd then return end
    if project.cd(spell) > 0 then return end

    -- Look for threatened friendly targets
    local target = awful.fgroup.within(spell.range)
        .find(function(friend)
            local total, melee, ranged, cooldowns = friend.v2attackers()
            if friend.distanceTo(player) < 15 then return false end
            if friend.hp >= project.random(project.settings.autogrip) then return false end
            if friend.buff(PwBarrierBuff.id) then return false end
            if friend.rooted then return false end
            if not friend.predictLoS(0.5, player) then return false end
            if total < 1 and cooldowns < 1 then return false end
            return true
        end)

    if target then
        return spell:Cast(target)
    end

    -- Check for rogue smoke bomb scenario
    local rogue = awful.enemies.within(spell.range)
        .find(function(enemy)
            if enemy.class2 ~= "ROGUE" then return false end
            if project.LowestUnit.distanceTo(player) < 10 then return false end
            if enemy.hasTalent(212182) and enemy.cd(212182) > 1 then return false end
            if enemy.hasTalent(359043) and enemy.cd(359053) > 1 then return false end
            if enemy.gcdRemains > 0.8 then return false end
            return project.LowestUnit and 
                   project.LowestUnit.debuff(408) and 
                   project.LowestUnit.debuffRemains(408) > 2
        end)

    if not rogue then return end
    return spell:Cast(project.LowestUnit)
end)

PwFortitude:Callback(function(spell)
    if project.cd(spell) > 0 then return end

    awful.fgroup.within(40).loop(function(friend)
        if awful.prep and not friend.buff(PwFortitude.id) then
            if spell:Castable() then
                return spell:Cast(player) and
                    awful.alert({
                        message = "Casting Power Word: Fortitude",
                        texture = 21562,
                    })
            end
        end
    end)
end)

rapture:Callback(function(spell)
    if not player.hasTalent(rapture.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    local setupInfo = getSetupTarget()

    -- Ensure we have a valid kill target
    if not setupInfo.killTarget then return end

    -- Comp-specific logic based on setupInfo
    if setupInfo.pressure >= 30 then
        if setupInfo.setupStyle == "aggressive" then
            if setupInfo.goBuff or setupInfo.crossCC or
                (setupInfo.stunSetup and project.LowestUnit.sdr >= 1) then
                return spell:Cast(setupInfo.killTarget)
            end
        end

        -- Pressure comp response
        if setupInfo.setupStyle == "pressure" then
            if setupInfo.goBuff and setupInfo.killTarget.hp <= 85 then
                if spell:Cast(setupInfo.killTarget) then
                    awful.alert({
                        message = "Rapture - Sustained Pressure on " .. setupInfo.killTarget.name,
                        texture = rapture.id,
                    })
                    return true
                end
            end
        end

        -- Mixed/rot comp response
        if setupInfo.setupStyle == "mixed" or setupInfo.setupStyle == "rot" then
            if setupInfo.killTarget.hp <= 85 or (setupInfo.crossCC and setupInfo.killTarget.hp <= 90) then
                if spell:Cast(setupInfo.killTarget) then
                    awful.alert({
                        message = "Rapture - Mixed Pressure on " .. setupInfo.killTarget.name,
                        texture = rapture.id,
                    })
                    return true
                end
            end
        end
    end

    -- General usage if kill target's HP is low
    if setupInfo.goBuff or setupInfo.killTarget.hp <= 50 then
        if spell:Cast(setupInfo.killTarget) then
            awful.alert({
                message = "Rapture - Low HP on " .. setupInfo.killTarget.name,
                texture = rapture.id,
            })
            return true
        end
    end
end)

rapture:Callback("lowHP", function(spell)
    if not player.hasTalent(rapture.id) then return end
    if project.cd(spell) > 0 then return end
    if insight.prevgcd then return end
    if solace.prevgcd then return end
    if project.LowestUnit.hpa > 40 then return end
    if spell:Cast(project.LowestUnit) then
        awful.alert({
            message = "Casting Rapture on " .. project.LowestUnit.name,
            texture = rapture.id,
        })
        return
    end
end)

PwBarrier:Callback(function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if not project.settings.pwb then return end

    local setupInfo = getSetupTarget()

    -- Check for smoked targets first
    local smokedTarget = awful.fgroup
        .find(function(friend)
            return friend.debuffFrom(rogueCDS)
        end)

    if smokedTarget then
        local x, y, z = smokedTarget.position()
        return spell:AoECast(x, y, z)
    end

    if setupInfo.pressure < 30 or not setupInfo.target then return end

    -- Aggressive burst comp response
    if setupInfo.setupStyle == "aggressive" and 
       (setupInfo.crossCC or setupInfo.goBuff) then
        return spell:SmartAoE(setupInfo.target) and 
               awful.alert("Barrier - Burst Setup")
    end

    -- Cleave comp response
    if setupInfo.setupStyle == "pressure" and 
       setupInfo.target.hp <= 80 then
        return spell:SmartAoE(setupInfo.target) and 
               awful.alert("Barrier - Heavy Pressure")
    end

    -- Mixed damage comp response
    if setupInfo.setupStyle == "mixed" and 
       setupInfo.target.hp <= 85 then
        return spell:SmartAoE(setupInfo.target) and 
               awful.alert("Barrier - Mixed Pressure")
    end
end)

PwBarrier:Callback(function(spell)
    local aids = false
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    if not project.settings.pwb then return end
    if player.buff(rapture.id) and player.buffRemains(rapture.id) > awful.gcdRemains then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if enemy.ranged and not enemy.losOf(project.AoELowestUnit) then return end
        if not enemy.cds or enemy.used(BurstCDS, 2) or enemy.buffFrom(BurstCDS) then return end
        if enemy.predictDistance(0.5, player) > 40 then return end
        if project.AoELowestUnit.moving then return end
        if not enemy.meleeRangeOf(project.AoELowestUnit) then return end
        if not project.AoELowestUnit.enemiesattacking then return end
        aids = true
    end)
    if not aids then return end
    return spell:SmartAoE(project.AoELowestUnit)
end)

PwBarrier:Callback("bomb", function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if not project.settings.pwb then return end
    local rogue = awful.enemies.within(50).find(function(unit) return unit.enemy and unit.class2 == "ROGUE" end)
    if not rogue then return end

    -- Check if any friendly is in smoke bomb
    local smokedTarget = nil
    awful.fgroup.loop(function(friend)
        if friend.debuffFrom(rogueCDS) then
            smokedTarget = friend
            return true
        end
    end)

    if not smokedTarget then return end
    local x, y, z = smokedTarget.position()
     spell:AoECast(x, y, z)
     return true
end)

function project.stompTotems()
    if commonChecks.castingOrChanneling() then return end
    if project.LowestHealth and project.LowestHealth <= 60 then return end

    awful.totems.stomp(function(totem, uptime)
        -- Skip early conditions
        if uptime < 0.2 then return end
        if totem.distance > 40 then return end
        if not totem.los then return end
        if not totem.playerFacing45 then return end
        
        -- Check if totem can be killed
        if totem.hp > (purgeTheWicked.damage + purgeTheWicked.effect) * 2 then return end

        -- Check priority based on settings
        if project.settings.stompsHigh[totem.id] or 
           project.settings.stomps[totem.id] then
        return purgeTheWicked:Cast(totem)
        end
    end)
end

renew:Callback(function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if player.buff(rapture.id) and not project.LowestUnit.buff(PwShield.id) then return end
    if project.cd(PwShield) <= 0 and project.LowestUnit.buff(atonement.id) then return end

    local function homies(unit)
        return not unit.pet
            and not unit.dead
            and unit.los
            and not unit.buff(atonement.id) and
            spell:Castable(unit) and
            project.hasLosBehindIceWall(player, unit)
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest

    if not lowest.friend then return end

    return spell:Cast(lowest)
end)

prayerOfMending:Callback(function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    if project.LowestHealth > project.random(project.settings.pom) then return end
    if not project.LowestUnit.combat then return end
    if project.LowestUnit.buff(prayerOfMending.id) then return end
    if not prayerOfMending:Castable(project.LowestUnit) then return end
    if project.LowestUnit.immuneHealing then return end
    return spell:Cast(project.LowestUnit) and
        awful.alert({
            message = "Prayer Of Mending on " .. project.LowestUnit.name,
            texture = prayerOfMending.id,
            duration = 1,
        })
end)

local function calculateShieldAmount()
    local baseShieldAmount = PwShield.effect
    local mastery = GetMasteryEffect()
    local masteryBonus = 1 + (mastery / 100)
    local totalShield = baseShieldAmount * masteryBonus

    if player.buff(rapture.id) then
        totalShield = totalShield * 1.4
    end

    return totalShield
end

PwShield:Callback(function(spell)
    if select(2, IsInInstance()) == "arena" and not project.combatStarted then return end
    if commonChecks.castingOrChanneling() then return end
    if not project.LowestUnit.enemiesattacking then return end
    if player.buff(rapture.id) then
        if project.LowestUnit.buff(PwShield.id, player) and project.LowestUnit.absorbs >= PwShield.effect * 0.6 then
            return
        end
    else
        -- Normal non-Rapture logic
        if project.cd(spell) > 0 then return end
        if project.LowestUnit.buff(PwShield.id, player) and project.LowestUnit.absorbs >= PwShield.effect / 2 then return end
    end

    if spell:Cast(project.LowestUnit) then
        awful.alert({
            message = "Power Word: Shield on " .. project.LowestUnit.name,
            texture = PwShield.id,
        })
    end
end)

purgeTheWicked:Callback("catharsis", function(spell)
    local stacks = select(16, player.buff(391314))
    local capDamage = math.floor(player.healthMax * 0.15) - 1
    local cast = false
    local diddy = nil
    if not player.hasTalent(purgeTheWicked.id) then return end
    if not player.hasTalent(catharsis.id) then return end
    if project.cd(spell) > 0 then return end
    if commonChecks.castingOrChanneling() then return end
    --if project.cd(PwShield) <= 0 then return end

    awful.enemies.within(spell.range).loop(function(unit)
        if not unit.los then return end
        if unit.dead then return end
        if unit.pet then return end
        if unit.bcc then return end
        if not project.hasLosBehindIceWall(player, unit) then return end
        diddy = unit
        cast = true
    end)

    if (stacks and (stacks >= capDamage) and cast) then
        return spell:Cast(diddy)
    end
end)

local ptwDebuff = function(obj)
    return obj.debuff(purgeTheWickedDebuff.id, player) and obj.enemy and obj.los and
        not obj.dead and not obj.isPet and project.hasLosBehindIceWall(player, obj)
end
local noDebuff = function(obj)
    return not obj.debuff(purgeTheWickedDebuff.id, player) and obj.enemy and not obj.isPet and
        not obj.immuneMagic and obj.los and not obj.bcc and not obj.isUnit(enemyHealer) and player.facing(obj) and
        project.hasLosBehindIceWall(player, obj)
end

purgeTheWicked:Callback(function(spell)
    if not player.hasTalent(purgeTheWicked.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if not shouldApplyPTW() then return end

    local hasDebuff = awful.enemies.within(40).filter(ptwDebuff)
    if #hasDebuff >= project.settings.ptw then return end

    local target = awful.enemies.within(spell.range).find(noDebuff)
    if not target then return end

    return spell:Cast(target)
end)

local ptwDebuffs = function(obj)
    return obj.debuff(purgeTheWickedDebuff.id, player) and obj.enemy and obj.los and
        not obj.dead and obj.isPet and project.hasLosBehindIceWall(player, obj)
end
local noPtw = function(obj)
    return not obj.debuff(purgeTheWickedDebuff.id, player) and not obj.immuneMagic and
        not obj.bcc and obj.isPet and obj.playerFacing45 and obj.los and obj.enemy and
        project.hasLosBehindIceWall(player, obj)
end

purgeTheWicked:Callback("pets", function(spell)
    local nerd = nil
    local aids = false
    if not player.hasTalent(purgeTheWicked.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if not shouldApplyPTW() then return end

    local petsWithDebuff = awful.enemyPets.within(spell.range).filter(ptwDebuffs)

    if #petsWithDebuff < project.settings.ptwp and project.settings.ptwp > 0 then
        awful.enemyPets.within(spell.range).filter(noPtw).loop(function(pet)
            aids = true
            nerd = pet
        end)
    end
    if not aids then return end
    return spell:Cast(nerd)
end)


penance:Callback(function(spell)
    if select(2, IsInInstance()) == "arena" and not project.combatStarted then return end
    if commonChecks.castingOrChanneling() then return end
    if player.buff(rapture.id) and not project.LowestUnit.buff(PwShield.id) then return end
    if player.buff(solace.id) then return end
    if project.cd(spell) > 0 then return end

    -- Handle Insight proc
    if player.buff(insight.id) then
        if project.LowestHealth > project.random(project.settings.penance) then
            local damageTarget = awful.enemies.within(spell.range)
                .find(function(enemy)
                    return not enemy.pet and
                           not enemy.dead and
                           enemy.los and
                           not enemy.bcc and
                           player.facing(enemy) and
                           enemy.debuff(purgeTheWickedDebuff.id, player) and
                           project.hasLosBehindIceWall(player, enemy)
                end)

            if damageTarget then
                return spell:Cast(damageTarget)
            end
        end

        if project.LowestHealth <= project.random(project.settings.penance) then
            return spell:Cast(project.LowestUnit)
        end
        return
    end

    -- Regular usage
    if project.LowestHealth <= project.random(project.settings.penance) then
        return spell:Cast(project.LowestUnit) and
            awful.alert({
                message = "Casting Penance on " .. project.LowestUnit.name,
                texture = penance.id,
            })
    end

    if player.buff(rapture.id) and not player.buff(darkSideBuff.id) then return end

    local damageTarget = awful.enemies.within(spell.range)
        .find(function(enemy)
            return not enemy.bcc and
                   not enemy.pet and
                   enemy.los and
                   enemy.debuff(purgeTheWickedDebuff.id, player) and
                   spell:Castable(enemy) and
                   player.facing(enemy) and
                   project.hasLosBehindIceWall(player, enemy)
        end)

    if not damageTarget then return end
    return spell:Cast(damageTarget)
end)


mindBlast:Callback(function(spell)
    if wasCasting[mindBlast.id] then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if player.buff(rapture.id) and not project.LowestUnit.buff(PwShield.id) then return end

    --if project.cd(PwShield) <= 0 and not project.LowestUnit.buff(PwShield.id) then return end
    --if project.cd(renew) <= 0 and not project.LowestUnit.buff(atonement.id, player) then return end

    local function nerds(unit)
        return unit.los and
            not unit.dead
            and not unit.pet
            and not unit.bcc
            and unit.debuff(purgeTheWickedDebuff.id, player)
            and spell:Castable(unit)
            and project.hasLosBehindIceWall(player, unit)
    end

    local lowest = awful.enemies.within(spell.range).filter(nerds).lowest

    if not lowest.enemy then return end

    return spell:Cast(lowest, { stopMoving = true }) and
        awful.alert({
            message = "Casting Mind Blast on " .. lowest.name,
            texture = mindBlast.id,
        })
end)

insight:Callback(function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.insightCast then return end
    if project.cd(insight) > 0 then return end
    if project.cd(penance) > 0 then return end
    if not IsPlayerSpell(428924) then return end
    if IsPlayerSpell(447444) then return end
    if not project.LowestUnit.combat then return end
    if not project.LowestUnit.los then return end
    return spell:Cast()
end)

piety:Callback(function(spell)
    if commonChecks.castingOrChanneling() then return end
    if not project.insightCast then return end
    if project.pietyCast then return end
    if not IsPlayerSpell(428924) then return end
    if IsPlayerSpell(447444) then return end
    if player.buff(insight.id) then return end
    if player.buff(rapture.id) or project.cd(rapture) <= 0 then return end
    if project.cd(piety) > 0 then return end
    local total, _, _, cds = project.LowestUnit.v2attackers()
    if cds < 1 and project.LowestUnit.hpa > 80 then return end
    return spell:Cast()
end)


solace:Callback(function(spell)
    project.shieldingSequence = false
    if commonChecks.castingOrChanneling() then return end
    if not project.canCastOverlappingSpell(solace, project.LowestUnit) then return end
    if painSuppression.charges >= 1 then return end
    if not project.pietyCast then return end
    if project.solaceCast then return end
    if player.buff(piety.id) then return end
    if project.cd(solace) > 0 then return end
    if not IsPlayerSpell(428924) then return end
    if IsPlayerSpell(447444) then return end
    if project.cd(PwShield) > 0 then return end
    if project.cd(PwShield) <= 0 and awful.gcdRemains > 0 then return end
    if player.buff(rapture.id) then return end
    if project.cd(rapture) <= 0 then return end
    if not project.LowestUnit.enemiesattacking then return end
    if project.LowestUnit.hpa > 50 then return end
    if project.LowestUnit.isUnit(player) and not player.enemiesattacking then return end
    project.shieldingSequence = true
    spell:Cast()
    PwShield:Cast(project.LowestUnit)
    project.setOverlappingSpell(solace, project.LowestUnit)
    project.shieldingSequence = false
    return true
end)

clairvoyance:Callback(function(spell)
    project.shieldingSequence = false
    if commonChecks.castingOrChanneling() then return end
    if not project.canCastOverlappingSpell(clairvoyance, project.LowestUnit) then return end
    if not project.solaceCast then return end
    if painSuppression.charges >= 1 then return end
    if project.clairvoyanceCast then return end
    if project.cd(clairvoyance) > 0 then return end
    if not IsPlayerSpell(428924) then return end
    if IsPlayerSpell(447444) then return end
    if project.cd(PwShield) > 0 then return end
    if project.cd(PwShield) <= 0 and awful.gcdRemains > 0 then return end
    if project.LowestUnit.hpa > 50 then return end
    if project.LowestUnit.immunePhysical then return end
    if project.LowestUnit.isUnit(player) and not player.enemiesattacking then return end
    project.shieldingSequence = true
    spell:Cast()
    PwShield:Cast(project.LowestUnit)
    project.setOverlappingSpell(clairvoyance, project.LowestUnit)
    project.shieldingSequence = false
    return true
end)

painSuppression:Callback(function(spell)
    -- Basic checks
    if not player.hasTalent(painSuppression.id) then return end
    if not project.settings.ps then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if player.buff(rapture.id) then return end
    if project.LowestUnit.buff(painSuppression.id) then return end

    -- Get attackers and setup info
    local total, melee, ranged, cooldowns = project.LowestUnit.v2attackers()
    local setupInfo = getSetupTarget()

    -- Basic checks
    if total == nil then return end
    if player.lastcast == voidShift.id then return end
    if player.used(voidShift.id, 1) then return end
    if project.cd(rapture) <= 0 then return end

    -- Check for enemy burst cooldowns regardless of comp detection
    local hasEnemyBurst = awful.enemies.within(40).find(function(enemy)
        return enemy.buffFrom(BurstCDS) or enemy.used(BurstCDS, 2)
    end)

    -- Check for incoming CC on yourself
    local incomingCC = awful.enemies.within(40).find(function(enemy)
        return enemy.casting and enemy.castTarget
            and enemy.castTarget.isUnit(player)
            and KillSetupAbilities[enemy.castID]
    end)

    -- Defensive overlap checks - more nuanced for high pressure
    if project.LowestUnit.bufffrom(defensiveTable) then
        -- Still PS through other defensives if pressure is extreme
        if not (hasEnemyBurst and cooldowns >= 1 and project.LowestUnit.hpa <= 45) then
            -- Only ignore defensives if you're about to be CC'd and damage is incoming
            if not (incomingCC and (hasEnemyBurst or cooldowns >= 1)) then
                return
            end
        end
    end

    -- Emergency cases - Higher thresholds for proactive use
    if project.LowestUnit.hpa <= 50 and project.cd(voidShift) <= 0 then
        return spell:Cast(project.LowestUnit) and awful.alert({
            message = "|cFFFF0000Pain Suppression - VS Prevention|r",
            texture = painSuppression.id
        })
    end

    -- Pre-emptive PS before CC
    if incomingCC and (hasEnemyBurst or cooldowns >= 1) then
        if project.LowestUnit.hpa <= 80 then
            return spell:Cast(project.LowestUnit) and awful.alert({
                message = "|cFFFF6B00Pain Suppression - Pre CC|r",
                texture = painSuppression.id
            })
        end
    end

    -- Known comp responses
    if setupInfo.pressure >= 30 and setupInfo.killTarget and setupInfo.killTarget.isUnit(project.LowestUnit) then
        -- Burst comp response (RMP, etc)
        if setupInfo.setupStyle == "aggressive" then
            if setupInfo.goBuff or setupInfo.crossCC or
                (setupInfo.stunSetup and project.LowestUnit.sdr >= 1) then
                return spell:Cast(project.LowestUnit) and awful.alert({
                    message = "|cFFFF6B00Pain Suppression - Burst Setup|r",
                    texture = painSuppression.id
                })
            end
        end

        -- Cleave comp response
        if setupInfo.setupStyle == "pressure" then
            if cooldowns >= 1 or setupInfo.pressure >= 40 then
                return spell:Cast(project.LowestUnit) and awful.alert({
                    message = "|cFFFFD700Pain Suppression - Heavy Pressure|r",
                    texture = painSuppression.id
                })
            end
        end

        -- Jungle comp response
        if setupInfo.compType == "JUNGLE_COMPS" then
            if setupInfo.goBuff and project.LowestUnit.hpa <= 70 then
                return spell:Cast(project.LowestUnit) and awful.alert({
                    message = "|cFF00FF00Pain Suppression - Hunter Setup|r",
                    texture = painSuppression.id
                })
            end
        end

        -- Wizard/caster response
        if setupInfo.setupStyle == "rot" then
            if project.LowestUnit.hpa <= 65 and cooldowns >= 1 then
                return spell:Cast(project.LowestUnit) and awful.alert({
                    message = "|cFF8A2BE2Pain Suppression - Heavy Rot|r",
                    texture = painSuppression.id
                })
            end
        end

        -- Mixed comp response
        if setupInfo.setupStyle == "mixed" then
            if project.LowestUnit.hpa <= 65 and (cooldowns >= 1 or setupInfo.crossCC) then
                return spell:Cast(project.LowestUnit) and awful.alert({
                    message = "|cFF1E90FFPain Suppression - Mixed Pressure|r",
                    texture = painSuppression.id
                })
            end
        end
    end

    -- Fallback for unrecognized situations
    if not setupInfo.comp then
        -- Enemy using burst CDs
        if hasEnemyBurst and project.LowestUnit.hpa <= 75 then
            return spell:Cast(project.LowestUnit) and awful.alert({
                message = "|cFFDC143CPain Suppression - Enemy Burst|r",
                texture = painSuppression.id
            })
        end

        -- Multiple melee pressure
        if melee >= 2 and project.LowestUnit.hpa <= 70 then
            return spell:Cast(project.LowestUnit) and awful.alert({
                message = "|cFFFF69B4Pain Suppression - Multiple Melee|r",
                texture = painSuppression.id
            })
        end
    end

    -- Handle stun scenarios on yourself
    if player.stunned and player.stunremains > 2 and project.LowestUnit.hpa <= 75 then
        return spell:Cast(project.LowestUnit) and awful.alert({
            message = "|cFF4169E1Pain Suppression - Self CC|r",
            texture = painSuppression.id
        })
    end

    -- Regular usage based on health and pressure
    if project.LowestUnit.hpa <= 55 and (total >= 2 or cooldowns >= 1) then
        return spell:Cast(project.LowestUnit) and awful.alert({
            message = "|cFFA0522DPain Suppression - Low HP|r",
            texture = painSuppression.id
        })
    end
end)


PwLife:Callback(function(spell)
    if not player.hasTalent(PwLife.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    if project.LowestUnit.immuneHealing then return end
    if not IsPlayerSpell(440674) and project.LowestUnit.hpa > project.settings.pwl then return end
    if IsPlayerSpell(440674) and project.LowestUnit.hpa > 49 then return end
    return spell:Cast(project.LowestUnit)
end)

flashHeal:Callback(function(spell)
    if wasCasting[flashHeal.id] then return end
    if player.buff(rapture.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    if not IsPlayerSpell(440674) and project.LowestHealth <= project.settings.pwl and project.cd(PwLife) <= 0 then return end
    if project.LowestHealth <= project.random(project.settings.pwr) and project.cd(PwRadiance) <= 0 then return end
    if project.LowestHealth <= 25 and project.cd(voidShift) <= 0 then return end
    if project.cd(PwShield) <= 0 and not project.LowestUnit.buff(PwShield.id) then return end
    if project.LowestHealth >= project.random(project.settings.fh) then return end
    if project.LowestUnit.immuneHealing then return end
    return spell:Cast(project.LowestUnit) and
        awful.alert({
            message = "Casting Flash Heal on " .. project.LowestUnit.name,
            texture = flashHeal.id,
        })
end)

PwRadiance:Callback(function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if player.buff(rapture.id) and not project.LowestUnit.buff(PwShield.id) then return end
    if not player.hasTalent(236499) then return end

    if project.AoELowestHealth <= project.random(project.settings.pwr) then
        if project.AoELowestUnit.predictDistance(0.5, player) > spell.range then return end
        
        return spell:Cast(player) and awful.alert({
            message = "Casting Power Word: Radiance on " .. project.AoELowestUnit.name,
            texture = PwRadiance.id,
        })
    end
end)

PwRadiance:Callback("rogue", function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    
    -- Check for rogue
    local rogue = awful.enemies.within(50)
        .find(function(unit) 
            return unit.enemy and unit.class2 == "ROGUE" 
        end)
    
    if not rogue then return end

    -- Check for smoke bomb debuff
    local smokedFriend = awful.fgroup
        .find(function(friend)
            return friend.debuffFrom(rogueCDS)
        end)

    if not smokedFriend then return end
    return spell:Cast(player)
end)

voidShift:Callback(function(spell)
    if not player.hasTalent(voidShift.id) then return end
    if not project.settings.vs then return end
    if not project.canCastOverlappingSpell(voidShift, project.LowestUnit) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if player.buff(rapture.id) and not project.LowestUnit.buff(PwShield.id, player) then return end
    if project.cd(rapture) <= 0 then return end
    if (project.LowestUnit.immuneMagic or project.LowestUnit.immunePhysical) then return end
    if project.LowestUnit.buff(painSuppression.id) and (player.hasTalent(PwLife.id) and project.cd(PwLife) <= 0 or player.hasTalent(PwRadiance.id) and project.cd(PwRadiance) <= 0) then return end
    if project.LowestUnit.hpa > 25 then return end
    if project.LowestUnit.class2 == "PRIEST" and project.LowestUnit.used(voidShift.id, awful.gcd) then return end
    project.setOverlappingSpell(voidShift, project.LowestUnit)
    return spell:Cast(project.LowestUnit) and
        awful.alert({
            message = "Casting Void Shift on " .. project.LowestUnit.name,
            texture = 108968,
        })
end)

voidShift:Callback("self", function(spell)
    -- Early exit checks
    if not player.hasTalent(voidShift.id) then return end
    if not project.settings.vs then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if player.hpa > 27 then return end
    if project.cd(PwLife) <= 0 then return end

    -- Check if another priest used void shift recently
    local priestVoidShift = awful.fgroup.within(spell.range)
        .find(function(friend)
            return friend.class2 == "PRIEST" and friend.used(voidShift.id, 1)
        end)
    if priestVoidShift then return end

    -- Find friend with highest HP
    local highestHPFriend = nil
    local highestHP = 0

    awful.fgroup.within(spell.range).loop(function(friend)
        -- Skip self and invalid targets
        if friend.isUnit(player) then return end
        if friend.dead then return end
        if not friend.los then return end
        if friend.immuneHealing then return end

        -- Track highest HP
        if friend.hpa > highestHP then
            highestHPFriend = friend
            highestHP = friend.hpa
        end
    end)

    -- Exit if no valid target found or HP difference isn't worth it
    if not highestHPFriend then return end
    if highestHP < 50 then return end -- Don't swap if friend also low
    if (highestHP - player.hp) < 25 then return end -- Ensure meaningful difference

    -- Cast and alert
    return spell:Cast(highestHPFriend) and awful.alert({
        message = "Void Shift with " .. highestHPFriend.name,
        texture = spell.id
    })
end)

purify:Callback(function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if not IsPlayerSpell(440674) and 
       project.LowestHealth <= project.settings.pwl and 
       project.cd(PwLife) <= 0 then return end

    local cleanseTarget = awful.fgroup.within(spell.range)
        .find(function(friend)
            if not friend.debuffFrom(cleanseTable) then return false end
            if friend.debuff("Vampiric Touch") and project.LowestHealth < 60 then return false end
            if friend.debuff("Unstable Affliction") then return false end
            return true
        end)

    if not cleanseTarget then return end

    return spell:Cast(cleanseTarget) and
        awful.alert({
            message = "Purify on " .. cleanseTarget.name,
            texture = purify.id,
        })
end)

powerInfusion:Callback(function(spell)
    if not player.hasTalent(powerInfusion.id) then return end
    if not project.settings.pi then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    local function hasActiveBurst(unit)
        return unit.used(BurstCDS, 1.5) or unit.bufffrom(BurstCDS) or unit.cds
    end

    local function isValidTarget(unit)
        return not unit.buff(powerInfusion.id) and unit.los
    end

    -- Find caster target
    local piTarget = awful.fgroup.within(spell.range)
        .find(function(friend)
            return isValidTarget(friend) and
                   ((casterSpecs[friend.spec] and hasActiveBurst(friend)) or
                    hasActiveBurst(friend))
        end)

    if piTarget then
        return spell:Cast(piTarget) and awful.alert({
            message = "Casting Power Infusion on " .. piTarget.name,
            texture = powerInfusion.id,
        })
    end

    -- Check defensive usage conditions
    local setupInfo = getSetupTarget()
    if setupInfo.pressure < 30 then return end

    if setupInfo.setupStyle == "aggressive" and 
       setupInfo.goBuff and 
       project.LowestUnit.hp <= 70 then
        return spell:Cast(project.LowestUnit) and awful.alert({
            message = "PI Self - Burst Healing",
            texture = powerInfusion.id,
        })
    end

    if project.LowestUnit.hp > 60 then return end
    if setupInfo.setupStyle ~= "pressure" and setupInfo.setupStyle ~= "mixed" then return end

    return spell:Cast(project.LowestUnit) and awful.alert({
        message = "PI Self - Heavy Pressure",
        texture = powerInfusion.id,
    })
end)

darkArchangel:Callback(function(spell)
    if not player.hasTalent(darkArchangel.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    local burstTarget = awful.fgroup.within(40)
        .find(function(friend)
            if not (friend.cds or friend.used(BurstCDS, 2)) then return false end
            if friend.distance > 40 then return false end
            return true
        end)

    if not burstTarget then return end

    return spell:Cast() and awful.alert({
        message = "Dark Archangel",
        texture = 197871,
    })
end)

smite:Callback(function(spell)
    if wasCasting[smite.id] then return end
    if player.buff(rapture.id) then return end
    if project.cd(PwShield) <= 0 and not project.LowestUnit.buff(PwShield.id) then return end
    if project.LowestHealth <= project.random(project.settings.penance) and project.cd(penance) <= 0 then return end
    if project.cd(mindBlast) <= 0 then return end
    if project.cd(spell) > 0 then return end

    -- Find valid smite target
    local target = awful.enemies.within(spell.range)
        .find(function(enemy)
            return not enemy.pet and
                   enemy.los and
                   enemy.debuff(purgeTheWickedDebuff.id, player) and
                   not enemy.immuneMagic and
                   not enemy.bcc and
                   player.facing(enemy) and
                   project.hasLosBehindIceWall(player, enemy)
        end)

    if not target then return end
    
    return spell:Cast(target) and awful.alert({
        message = "Smite " .. target.name,
        texture = 585,
    })
end)

local MD = {
    [642] = true,
    [45438] = true
}

massDispel:Callback(function(spell)
    if project.LowestHealth <= 40 then return end
    if wasCasting[massDispel.id] then return end
    if project.cd(spell) > 0 then return end
    if not player.hasTalent(massDispel.id) then return end

    -- Check enemies with important buffs
    local buffedEnemy = awful.enemies.within(40)
        .find(function(enemy)
            return enemy.buffFrom(MD) and
                   enemy.los and
                   enemy.distance <= 40
        end)

    if buffedEnemy then
        if player.moving then 
            awful.controlMovement(awful.buffer + awful.tickRate * 2)
        end
        return spell:SmartAoE(buffedEnemy)
    end

    -- Check cycloned friends
    local cyclonedFriend = awful.fgroup.within(40)
        .find(function(friend)
            if not friend.debuff(33786) then return false end
            if friend.ccRemains <= 2 then return false end
            if player.manaPct < 50 then return false end
            if not friend.los then return false end
            if friend.distance > 40 then return false end
            return true
        end)

    if not cyclonedFriend then return end
    
    if player.moving then 
        awful.controlMovement(awful.buffer + awful.tickRate * 2)
    end
    return spell:SmartAoE(cyclonedFriend)
end)


fade:Callback("melee", function(spell)
    local total, melee, ranged, cooldowns = player.v2attackers()
    if not project.settings.fade then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if not player.hasTalent(108942) then return end
    if melee < 1 then return end
    if not player.slowed then return end
    return spell:Cast()
end)


fade:Callback(function(spell)
    if not project.settings.fade then return end
    if project.cd(spell) > 0 then return end
    if commonChecks.castingOrChanneling() then return end

    local setupInfo = getSetupTarget()

    -- Track if we're the target
    local weAreTarget = false
    if setupInfo.target and setupInfo.target.isUnit(player) then
        weAreTarget = true
    end

    -- Fade during burst setups when targeted
    if weAreTarget and setupInfo.pressure >= 30 then
        if setupInfo.compType == "BURST_COMPS" then
            if setupInfo.goBuff then
                return spell:Cast() and awful.alert("Fade - " .. setupInfo.comp .. " Burst")
            end
        end
    end

    if player.hasTalent(408557) then
        awful.enemies.within(40).loop(function(enemy)
            if enemy.casting and enemy.castID == 33786 and enemy.castTarget ~= nil and enemy.castTarget.isUnit(player) and enemy.castRemains <= 0.5 and enemy.los and player.ddr >= 0.5 then
                if player.buff(8178) then return end -- ground
                if (player.casting or player.channel) then
                    awful.call("SpellStopCasting")
                else
                    return spell:Cast() and
                        awful.alert({
                            message = "Casting Fade due to enemy CC",
                            texture = 586,
                        })
                end
            end

            if enemy.los and enemy.casting and (deathTable[enemy.castID] and enemy.castTarget ~= nil and enemy.castTarget.isUnit(player) and enemy.castRemains <= 0.5) then
                
                if awful.gcdRemains <= enemy.castRemains and project.cd(swd) <= 0 then return end
                if project.cd(swd) <= 0 and not player.lockouts.shadow and awful.gcdRemains <= enemy.castRemains then return end
                --if player.used(swd.id, awful.gcd) then return end
                if swd.prevgcd then return end
                if player.lastCast == swd.id then return end
                if player.buff(8178) and player.buffRemains(8178) >= enemy.castRemains + awful.buffer then return end -- ground
                if (player.casting or player.channel) then
                    awful.call("SpellStopCasting")
                else
                    if not project.canUseDefensive(fade, enemy.castID) then return end
                    if spell:Cast() then
                        awful.alert({
                            message = "Casting Fade due to enemy CC",
                            texture = 586,
                        })
                        project.setDefensive(fade, enemy.castID)
                        return true
                    end
                end
            end
        end)
    end
end)

preHot:Callback(function(spell)
    if select(2, IsInInstance()) ~= "arena" then return end
    if project.cd(renew) > 0 then return end

    local target = awful.fgroup.within(40)
        .find(function(friend)
            if friend.hp ~= 100 then return false end
            if friend.combat then return false end
            if friend.buff(renew.id) then return false end
            if not renew:Castable(friend) then return false end
            if not friend.los then return false end
            return true
        end)

    if not target then return end
    return renew:Cast(target)
end)

desperatePrayer:Callback(function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    local setupInfo = getSetupTarget()

    -- Track if we're the target
    local weAreTarget = false
    if setupInfo.target and setupInfo.target.isUnit(player) then
        weAreTarget = true
    end

    -- More aggressive usage if we're being trained
    if weAreTarget then
        if setupInfo.compType == "BURST_COMPS" and player.hpa <= 80 then
            return spell:Cast() and awful.alert("Desperate Prayer - Burst Target")
        end
        if player.hpa <= 70 then
            return spell:Cast() and awful.alert("Desperate Prayer - Targeted")
        end
    end

    -- Normal usage
    if player.hpa <= project.random(project.settings.dp) then
        return spell:Cast() and awful.alert("Desperate Prayer - Low HP")
    end
end)

-- Create a callback for Inner Light
innerLight:Callback(function(spell)
    if awful.prep then
        if not player.buff(lightBuff.id) then
            return spell:Cast() and
                awful.alert({
                    message = "Casting Inner Shadow",
                    texture = 355897,
                })
        end
    end
end)

innerLight:Callback("switch", function(spell)
    if project.settings.ilsmode ~= "ilsdynamic" then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    if project.LowestHealth and project.LowestHealth <= 40 then return end

    local lowFriendCount = 0
    awful.fgroup.within(40).loop(function(friend)
        if friend and friend.hpa <= 65 then
            lowFriendCount = lowFriendCount + 1
        end
    end)

    if lowFriendCount and lowFriendCount >= 2 and (player.buff(lightBuff.id) or not player.buff(shadowBuff.id)) then
        innerLight:Cast()
    elseif (player.buff(shadowBuff.id) or not player.buff(lightBuff.id)) then
        innerLight:Cast()
    end
end)


innerLight:Callback("atone", function(spell)
    if project.settings.ilsmode ~= "ilsatone" then return end
    if player.buff(shadowBuff.id) then return end
    if project.cd(spell) > 0 then return end

    innerLight:Cast()
end)

innerLight:Callback("mana", function(spell)
    if project.settings.ilsmode ~= "ilsmana" then return end
    if player.buff(lightBuff.id) then return end
    if project.cd(spell) > 0 then return end

    innerLight:Cast()
end)

voidTendrils:Callback("multi", function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if not player.hasTalent(voidTendrils.id) then return end

    -- Check for multiple valid targets
    local targets = awful.enemies.within(spell.range)
        .filter(function(enemy)
            return not enemy.pet and 
                   enemy.distanceLiteral <= 8 and 
                   enemy.rootDR >= 0.5 and 
                   enemy.los and 
                   not enemy.immuneMagic
        end)

    if #targets >= 2 then
        return spell:Cast() and awful.alert({
            message = "Casting Void Tendrils to peel.",
            texture = 108920,
        })
    end
end)

local nerdMelee = function(obj)
    return not obj.isPet and obj.distanceLiteral <= 8 and obj.rootDR >= 0.5 and
        obj.melee and not obj.rooted and not obj.immuneSlows and obj.los and not obj.immuneMagic
end

voidTendrils:Callback("melee", function(spell)
    if not player.hasTalent(voidTendrils.id) then return end
    if project.cd(spell) > 0 then return end

    local nerds = awful.enemies.within(spell.range).filter(nerdMelee)

    if #nerds < 1 then return end
    return spell:Cast() and
        awful.alert({
            message = "Casting Void Tendrils.",
            texture = 108920,
        })
end)

local burstyNerds = function(obj)
    return obj.enemy and (obj.cds or obj.buffFrom(BurstCDS) or obj.used(BurstCDS, 2)) and
        obj.distanceLiteral <= 8 and obj.rootDR >= 0.5 and obj.melee and not obj.rooted and
        obj.los and not obj.immuneMagic
end

voidTendrils:Callback("enemyBurst", function(spell)
    if not player.hasTalent(voidTendrils.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    local nerds = awful.enemies.within(spell.range).filter(burstyNerds)

    if #nerds < 1 then return end

    return spell:Cast() and
        awful.alert({
            message = "Casting Void Tendrils to peel.",
            texture = 108920,
        })
end)

local nerdHealer = function(obj)
    return obj.healer and not obj.pet and obj.distanceLiteral <= 8 and obj.rootDR >= 0.5 and
        not obj.rooted and obj.los and not obj.immuneMagic
end

voidTendrils:Callback("enemyHealer", function(spell)
    if not player.hasTalent(voidTendrils.id) then return end
    if project.cd(spell) > 0 then return end
    if commonChecks.castingOrChanneling() then return end

    local nerds = awful.enemies.within(spell.range).filter(nerdHealer)
    if #nerds < 1 then return end

    return spell:Cast() and
        awful.alert({
            message = "Casting Void Tendrils on Enemy Healer",
            texture = 108920,
        })
end)

voidTendrils:Callback("chain", function(spell)
    local aids = false
    if not player.hasTalent(voidTendrils.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if enemy.rdr < 0.5 then return end
        if not enemy.los then return end
        if enemy.distanceLiteral > 8 then return end
        if not (enemy.cc or enemy.bcc) then return end
        if enemy.immuneSlows then return end
        if enemy.immuneMagic then return end
        if (enemy.cc and enemy.ccRemains > awful.gcdRemains + awful.buffer or enemy.bcc and enemy.bccRemains > awful.gcdRemains + awful.buffer) then return end
        aids = true
    end)
    if not aids then return end
    return spell:Cast()
end)

voidTendrils:Callback("los", function(spell)
    local tendies = false
    if not player.hasTalent(voidTendrils.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        if enemy.rdr < 0.5 then return end
        if not enemy.los then return end
        if enemy.immuneSlows then return end
        if enemy.distanceLiteral > 8 then return end
        if enemy.losOf(enemyHealer) then return end
        if enemy.immuneMagic then return end
        tendies = true
    end)
    if not tendies then return end
    return spell:Cast()
end)

local nerdPets = function(obj)
    return not obj.dead and 
           obj.enemy and 
           obj.distanceLiteral <= 8 and 
           obj.rootDR >= 0.5 and 
           not obj.cc and 
           not obj.bcc
end

voidTendrils:Callback("pets", function(spell)
    if not player.hasTalent(voidTendrils.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end

    -- Fixed the hunter/warlock check - the 'and' was in wrong place
    local hunter = awful.enemies.within(40).find(function(unit) 
        return (unit.class2 == "HUNTER" or unit.class2 == "WARLOCK") and
               unit.buffFrom(BurstCDS)
    end)

    -- Ensure pets function is available
    local nerdPetz = awful.enemyPets.within(8).filter(nerdPets)
    if not hunter then return end
    if #nerdPetz < 2 then return end

    return spell:Cast() and
        awful.alert({
            message = "Casting Void Tendrils on Pets.",
            texture = 108920,
        })
end)


shadowFiend:Callback(function(spell)
    if commonChecks.castingOrChanneling() then return end 
    if project.cd(spell) > 0 then return end

    -- Check for cooldowns more efficiently
    local hasCooldowns = awful.fgroup.within(spell.range)
        .find(function(friend)
            local _, _, _, cooldowns = friend.v2attackers()
            return not friend.pet and 
                   not friend.dead and 
                   friend.los and 
                   cooldowns >= 1
        end)

    if not hasCooldowns then return end

    -- Find most attacked enemy
    local mostAttackedEnemy = nil
    local highestAttackerCount = 0

    awful.enemies.within(spell.range)
        .find(function(enemy)
            if enemy.pet or 
               enemy.dead or 
               not enemy.los or 
               not project.hasLosBehindIceWall(player, enemy) then
                return false
            end
            
            local total = select(1, enemy.v2attackers())
            if total > highestAttackerCount then
                highestAttackerCount = total
                mostAttackedEnemy = enemy
            end
            return false
        end)

    if not mostAttackedEnemy then return end
    if not spell:Castable(mostAttackedEnemy) then return end

    if spell:Cast(mostAttackedEnemy) then
        return awful.alert({
            message = "Shadowfiend on " .. mostAttackedEnemy.name,
            texture = 34433,
        })
    end

    -- Low mana case
    if player.manaPct >= 40 then return end
    
    return spell:Cast(mostAttackedEnemy) and
        awful.alert({
            message = "Shadowfiend on " .. mostAttackedEnemy.name,
            texture = 34433,
        })
end)

dispelMagic:Callback(function(spell)
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if player.manaPct <= 35 then return end
    if project.LowestHealth < project.random(project.settings.dispel) then return end

    local target = awful.enemies.within(spell.range)
        .find(function(enemy)
            if not enemy.buffFrom(purgeTable) then return false end
            if not enemy.los then return false end
            if enemy.pet then return false end
            if enemy.dead then return false end
            if not project.hasLosBehindIceWall(player, enemy) then return false end
            return true
        end)

    if not target then return end

    return spell:Cast(target) and
        awful.alert({
            message = "Casting Dispel Magic",
            texture = 528,
        })
end)

dispelMagic:Callback("lowHP", function(spell)
    if not project.settings.odispel then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if player.manaPct <= 40 then return end
    if project.LowestHealth < project.random(project.settings.dispel) then return end
    if project.cd(PwShield) <= 0 and not project.LowestUnit.buff(PwShield.id) then return end

    local target = awful.enemies.within(spell.range)
        .find(function(enemy)
            if enemy.purgeCount < 1 then return false end
            if enemy.hp > 40 then return false end
            if enemy.dist > spell.range then return false end
            if not enemy.los then return false end
            if not project.hasLosBehindIceWall(player, enemy) then return false end
            return true
        end)

    if not target then return end

    return spell:Cast(target) and
        awful.alert({
            message = "Casting Dispel Magic",
            texture = 528,
        })
end)

angelicFeather:Callback("enemyHealer", function(spell)
    if not player.hasTalent(angelicFeather.id) then return end
    if not project.settings.af then return end
    if commonChecks.castingOrChanneling() then return end
    if player.buff(rapture.id) and not project.LowestUnit.buff(PwShield.id) then return end
    if project.cd(spell) > 0 then return end
    if project.LowestHealth < 40 then return end
    if player.buff(angelicFeatherBuff.id) then return end
    if enemyHealer.distanceTo(player) > 20 then return end
    if not enemyHealer.los then return end

    -- Moving toward healer
    if enemyHealer.exists and 
       player.movingToward(enemyHealer, { angle = 90, duration = 0.3 }) and 
       spell:Castable(player) then
        return spell:SmartAoE(player) and
            awful.alert({
                message = "Angelic Feather to run toward Enemy Healer",
                texture = 121536,
            })
    end

    -- Moving away from healer
    if not enemyHealer.exists then return end
    if not player.movingAwayFrom(enemyHealer, { angle = 120, duration = 0.3 }) then return end
    if not spell:Castable(player) then return end

    return spell:SmartAoE(player) and
        awful.alert({
            message = "Angelic Feather to run from Enemy Healer.",
            texture = 121536,
        })
end)

angelicFeather:Callback("enemyBurst", function(spell)
    if not player.hasTalent(angelicFeather.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if player.buff(rapture.id) and not project.LowestUnit.buff(PwShield.id) then return end
    if project.cd(spell) > 0 then return end
    if project.LowestHealth < 40 then return end
    if not project.LowestUnit.moving then return end
    if project.LowestUnit.buff(angelicFeatherBuff.id) then return end

    local total, _, _, cds = project.LowestUnit.v2attackers()
    if total < 1 and cds < 1 then return end
    if not spell:Castable() then return end

    return spell:SmartAoE(project.LowestUnit)
end)

angelicFeather:Callback("melee", function(spell)
    if not player.hasTalent(angelicFeather.id) then return end
    local total, melee, _, cds = project.LowestUnit.v2attackers()

    if commonChecks.castingOrChanneling() then return end
    if project.LowestHealth < 40 then return end
    if not project.LowestUnit.moving then return end
    if project.LowestUnit.buff(angelicFeatherBuff.id) then return end
    if player.buff(rapture.id) and not project.LowestUnit.buff(PwShield.id) then return end
    if total < 1 and melee < 1 then return end
    if not spell:Castable() then return end
    return spell:SmartAoE(project.LowestUnit)
end)

mindGames:Callback(function(spell)
    if not player.hasTalent(mindGames.id) then return end
    if commonChecks.castingOrChanneling() then return end
    if project.cd(spell) > 0 then return end
    if project.LowestHealth < 40 then return end
    if wasCasting[mindGames.id] then return end
    if not project.settings.mg then return end

    -- Helper function for target validation
    local function isValidTarget(enemy)
        if not spell:Castable(enemy) then return false end
        if enemy.immuneMagic and enemy.magicEffectImmunityRemains > spell.castTime then return false end
        if not project.hasLosBehindIceWall(player, enemy) then return false end
        return true
    end

    -- Check for burst target first
    local burstTarget = awful.enemies.within(spell.range)
        .find(function(enemy)
            if not isValidTarget(enemy) then return false end
            if not (enemy.cds or enemy.buffFrom(BurstCDS)) then return false end
            return true
        end)

    if burstTarget then
        return spell:Cast(burstTarget, {stopMoving = true})
    end

    -- Check healer conditions
    if enemyHealer.cc and enemyHealer.ccRemains > spell.castTime then return end
    if enemyHealer.bcc and enemyHealer.bccRemains > spell.castTime then return end
    if enemyHealer.immuneMagic and enemyHealer.magicEffectImmunityRemains > spell.castTime then return end

    -- Try to find any valid target
    local nerd = awful.enemies.within(spell.range)
        .find(isValidTarget)

    if target then
        return spell:Cast(nerd, {stopMoving = true})
    end

    -- Try healer as last resort
    if not spell:Castable(enemyHealer) then return end
    if not isValidTarget(enemyHealer) then return end

    return spell:Cast(enemyHealer, {stopMoving = true})
end)
