local Unlocker, awful, project = ...
if awful.player.class ~= "Evoker" then return end
if awful.player.spec ~= "Preservation" then return end
awful.AntiAFK.enabled = true

awful.enabled = true
local preservation = project.evoker.preservation
local Spell = awful.Spell
local settings = project.settings
local player = awful.player
local delay = awful.delay(0.350, 0.550)
local party1, party2, party3, party4 = awful.party1, awful.party2, awful.party3, awful.party4
local fireBreathChanneling = false
local spiritBloomChanneling = false
local delay = awful.delay(0.350, 0.550)
awful.unlock("SpellStopCasting")
project.stasisState = 0
project.stasisInitialSequence = false


awful.Populate({
    -----------DEFINITIONS--------------
    target = awful.target,
    focus = awful.focus,
    player = awful.player,
    healer = awful.healer,
    pet = awful.pet,
    enemyHealer = awful.enemyHealer,

    --## DMG ##--
    fireBreath = Spell(357208, { damage = "magic", targeted = false }),
    fireBreathRank4 = Spell(382266, { damage = "magic", targeted = false, ignoreMoving = true }),
    disintegrate = Spell(356995, { damage = "magic", targeted = true, ignoreMoving = true }),
    azureStrike = Spell(362969, { damage = "magic", targeted = true, ignoreMoving = true }),
    livingFlame = Spell(361469, { damage = "magic", targeted = true, ignoreMoving = true }),
    unravel = Spell(368432, { damage = "magic", targeted = true, ignoreMoving = true }),
    chronoLoop = Spell(383005, { damage = "magic", targeted = true, ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true }),

    --## HEAL ##--
    echo = Spell(364343, { heal = true, targeted = true, ignoreMoving = true }),
    reversion = Spell(366155, { heal = true, targeted = true, ignoreMoving = true }),
    reversion2 = Spell(367364, { heal = true, targeted = true, ignoreMoving = true }),
    dreamBreath = Spell(382614, { heal = true, targeted = false }),
    dreamBreathChannel = Spell(355936, { heal = true, targeted = false }),
    spiritBloom = Spell(382731, { heal = true, targeted = false }),
    spiritBloomChannel = Spell(367226, { heal = true, targeted = false }),
    rewind = Spell(363534, { beneficial = true, targeted = false, ignoreMoving = true }),
    emeraldCommunion = Spell(370960, { beneficial = true, heal = true, ignoreFacing = true, ignoreControl = true, ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true }),
    verdantEmbrace = Spell(360995, { heal = true, ignoreFacing = true, ignoreMoving = true, targeted = true }),
    obsidianScales = Spell(363916, { beneficial = true, ignoreFacing = true, ignoreMoving = true, ignoreGCD = true }),
    renewingBlaze = Spell(374348, { beneficial = true, ignoreFacing = true, ignoreMoving = true, ignoreGCD = true }),
    emeraldBlossom = Spell(355913, { beneficial = true, ignoreFacing = true, ignoreMoving = true }),
    stasis = Spell(370537, { beneficial = true, ignoreFacing = true, ignoreGCD = true, ignoreMoving = true }),
    stasisRelease = Spell(370564, { beneficial = true, ignoreFacing = true, ignoreGCD = true, ignoreMoving = true }),
    timeDilation = Spell(357170, { beneficial = true, ignoreFacing = true, ignoreMoving = true, ignoreGCD = true }),
    dreamProjection = Spell(377509, { beneficial = true, targeted = false }),
    dreamCancel = Spell(381414, { beneficial = true, targeted = false, ignoreControl = true, ignoreMoving = true, ignoreChanneling = true, ignoreCasting = true }),

    --## RACIALS ##--
    quakingPalm = Spell(107079, { effect = "physical", cc = "incapacitate", targeted = true, ignoreMoving = true }),
    bloodFury = Spell(33702, { beneficial = true }),
    warStomp = Spell(1234, { effect = "physical", cc = "stun", ignoreFacing = true }),
    berserking = Spell(26297, { beneficial = true }),
    rocketBarrage = Spell(69041, { damage = "magic", targeted = true, ignoreMoving = true }),
    rocketJump = Spell(69070, { beneficial = true }),
    bullRush = Spell(255654, { effect = "physical", cc = "stun", targeted = true, ignoreMoving = true }),
    ancestralCall = Spell(274738, { beneficial = true }),
    bagofTricksDirectDmg = Spell(312411, { damage = "magic", targeted = true, ignoreMoving = true }),
    stoneform = Spell(20594, { beneficial = true }),
    haymaker = Spell(287712, { damage = "physical", effect = "physical", cc = "stun", targeted = true, ignoreMoving = true }),
    bagofTricksDirectHeal = Spell(312411, { heal = true, ignoreFacing = true, ignoreMoving = true, targeted = true }),
    giftoftheNaaru = Spell(59547, { heal = true, ignoreMoving = true }),
    regeneratin = Spell(291944, { heal = true }),
    willToSurvive = Spell(59752, { beneficial = true, ignoreControl = true }),
    glide = Spell(358733, { beneficial = true, ignoreMoving = true, ignoreGCD = true, targeted = false, ignoreCasting = true, ignoreChanneling = true }),

    --## INTERRUPTS ##--
    quell = Spell(351338, { effect = "magic", targeted = true, ignoreGCD = true, ignoreFacing = false, ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true }),

    --## DISPELLS ##--   
    naturalize = Spell(360823, { targeted = true, ignoreMoving = true, ignoreGCD = false, ignoreCasting = true, ignoreChanneling = true }),
    cauterizingFlame = Spell(374251, { targeted = true, ignoreMoving = true, ignoreGCD = false, ignoreCasting = true, ignoreChanneling = true }),
    
    --## CC ##--
    sleepWalk = Spell(360806, { effect = "magic", cc = "disorient", targeted = true, ignoreMoving = true }),
    oppressingRoar = Spell(372048, { effect = "magic", targeted = false }),
    landSlide = Spell(358385, { effect = 'magic', cc = "root", diameter = 8, ignoreMoving = true }),
    deepBreath = Spell(357210, { effect = 'magic', cc = "stun", diameter = 8, ignoreFacing = true, ignoreMoving = true }),

    --## BUFFS ##--
    leapingFlames = Spell(370901, { beneficial = true }),
    ancientFlame = Spell(375583, { beneficial = true }),
    dreamBreathBuff = Spell(355914, { beneficial = true }),
    ouroboros = Spell(387350, { beneficial = true }),
    callOfYsera = Spell(373835, { beneficial = true }),
    temporalCompression = Spell(362877, { beneficial = true }),
    essenceBurst = Spell(369299, { beneficial = true }),
    fontOfMagic = Spell(375783, { beneficial = true }),
    empath = Spell(376138, { beneficial = true }),
    lifeGiversFlame = Spell(371426, { beneficial = true }),
    terrorOfTheSkies = Spell(371032, { beneficial = true }),
    energyLoop = Spell(372233, { beneficial = true }),  
    arenaPrep = Spell(32727),   
    bgPrep = Spell(44521),  
    stasisBuff = Spell(370562),
    groundingTotem = Spell(8178),
    preCog = Spell(377362),
    lifeSpark = Spell(443176, { beneficial = true }),
    permiatingChill = Spell(370898),
    shadowyDuelDebuff = Spell(207736),
    

    --## DEFENSIVE/UTILITY ##--
    tipTheScales = Spell(370553, { beneficial = true, targeted = false, ignoreFacing = true, ignoreGCD = true, ignoreCasting = true, ignoreChanneling = true }), 
    blessingOfTheBronze = Spell(364342, { beneficial = true, targeted = false, ignoreFacing = true }),
    hover = Spell(358267, { beneficial = true, ignoreFacing = true, ignoreGCD = true }),
    rescue = Spell(370665, { beneficial = true, targeted = true, ignoreFacing = true, ignoreGCD = false }),
    wingBuffet = Spell(357214, { ignoreFacing = false }),
    tailSwipe = Spell(368970, { beneficial = true, ignoreFacing = false }),
    timeSpiral = Spell(374968, { beneficial = true, ignoreFacing = false }),
    nullifyingShroud = Spell(378464, { beneficial = true, ignoreMoving = true }),
    timeStop = Spell(378441, { targeted = true, ignoreMoving = true, ignoreGCD = true, ignoreCasting = true, ignoreChanneling = true } ),
    timeStopCancel = Spell(383332, { ignoreMoving = true, ignoreGCD = true, ignoreCasting = true, ignoreChanneling = true, targeted = false }),
    spatialParadox = Spell(406732, { beneficial = true, ignoreMoving = true, ignoreGCD = true, ignoreCasting = true, ignoreChanneling = true }),
    furyOfTheAspects = Spell(390386, { beneficial = true, ignoreMoving = true, ignoreGCD = true, ignoreCasting = true, ignoreChanneling = true, targeted = false }),

    --## MISC ##--
    UA = Spell(342938),
    iceWall = Spell(352278)

}, preservation, getfenv(1))

local enemyReflect = {
    23920, --spell reflect
}

local BurstCDS = {
    -- Death Knight
    [383269] = true, -- Abomination Limb
    [207289] = true, -- Unholy Assault

    -- Demon Hunter
    [255647] = true, -- The Hunt
    [191427] = true, -- MetaMorphisis

    -- Druid
    [274837] = true, -- Feral Frenzy
    [102543] = true, -- Incarnation: Avatar of Ashamane
    [102560] = true, -- Incarnation: Chosen of Elune
    [390414] = true, -- Incarnation: Guardian of Ursoc
    [194223] = true, -- Celestial Alignment
    [391528] = true, -- Convoke the Spirits

    -- Evoker
    [375087] = true, -- Dragonrage
    [406227] = true, -- Deep Breath
    [403631] = true, -- Breath of Eons

    -- Hunter
    [360952] = true, -- Coordinated Assault
    [359844] = true, -- Call of the Wild
    [19574] = true,  -- Bestial Wrath
    [288613] = true, -- Trueshot

    -- Mage
    [190319] = true, -- Combustion
    [12472]  = true, -- Icy Veins
    [365350] = true, -- Arcane Surge

    -- Monk
    [137639] = true, -- Storm, Earth, and Fire
    [123904] = true, -- Invoke Xuen

    -- Paladin
    [31884]  = true, -- Avenging Wrath: Might

    -- Priest
    [194249] = true, -- Voidform
    [280711] = true, -- Dark Ascension
    [228260] = true, -- Void Eruption

    -- Rogue
    [121471] = true, -- Shadow Blades
    [185313] = true, -- Shadow Dance
    [360194] = true, -- Deathmark
    [13750] = true, -- Adrenaline Rush

    -- Shaman
    [384352] = true, -- Doom Winds
    [204361] = true, -- Bloodlust
    [114051] = true, -- Ascendance
    [114050] = true, -- Ascendance

    -- Warlock
    [1122]   = true, -- Infernal
    [205179] = true, -- Phantom Singularity
    [265187] = true, -- Summon Demonic Tyrant
    [386997] = true, -- SoulRot
    [205180] = true, -- Dark Glare

    -- Warrior
    [376079] = true, -- Spear of Bastion
    [107574] = true, -- Avatar
    [262161] = true, -- Warbreaker
    [1719]   = true, -- Recklessness
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

local cauterizeTable = {
    [80240] = { uptime = 0.2, min = 2 },  -- Havoc
    [335467] = { uptime = 0.2, min = 2 }, -- Devouring Plague
    [1943] = { uptime = 0.2, min = 2 },   -- Rupture
    [703] = { uptime = 0.2, min = 2 },    -- Garrote
    [1079] = { uptime = 0.2, min = 2 },   -- Rip
    [360194] = { uptime = 0.2, min = 2 }  -- Deathmark
}

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
    [191587] = { uptime = 0.2, min = 2, debuffStacks = 6 }, -- Necrotic Wound
    [2812] = { uptime = 0.2, min = 2 },   -- Denounce
    [410201] = { uptime = 0.2, min = 2}, -- Searing Glare
    [30283] = { uptime = 0.2, min = 2 },  -- Shadow Fury
    [179057] = { uptime = 0.2, min = 2 }, -- Chaos Nova
    [356738] = { uptime = 0.2, min = 2 }, -- Earth Unleashed
    [285515] = { uptime = 0.2, min = 2 }, -- Surge of Power
    [127797] = { uptime = 0.2, min = 2 }, -- Freeze
    [228600] = { uptime = 0.2, min = 2 }, -- Ice Nova
    [47476] = { uptime = 0.2, min = 2 },  -- Strangulate
    [410065] = { uptime = 0.2, min = 2 }, -- Reactive Resin
    [209749] = { uptime = 0.2, min = 2 }, -- Faerie Swarm
    [197214] = { uptime = 0.2, min = 2 }, -- Hibernate
    [710] = { uptime = 0.2, min = 2 },    -- Banish
    [31661] = { uptime = 0.2, min = 2 },  -- Dragon's Breath
    [1513] = { uptime = 0.2, min = 2 },   -- Scare Beast
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
    [48707] = true, -- Anti Magic Shell
    [51052] = true, -- Anti Magic Zone
    [198589] = true, -- Blur
    [196718] = true, -- Darkness
    [196555] = true, -- NetherWalk
    [22812] = true, -- Barkskin
    [186265] = true, -- Turtle
    [45438] = true, -- Ice Block
    [235219] = true, -- Cold Snap
    [122470] = true, -- Touch of Karma
    [642] = true, -- Divine Shield
    [498] = true, -- Divine Protection
    [47585] = true, -- Dispersion
    [19236] = true, -- Desperate Prayer
    [33206] = true, -- Pain Suppression
    [62618] = true, -- Power Word Barrier
    [5277] = true, -- Evasion
    [31224] = true, -- Cloak of Shadows
    [108271] = true, -- Astral Shift
    [409293] = true, -- Burrow
    [104773] = true, -- Unending Resolve
    [108416] = true, -- Dark Pact
    [118038] = true, -- Die by the Sword
    [97462] = true, -- Rallying Cry
    [6940] = true, -- Sacrifice
    [184364] = true, -- Enraged Regeneration
    [363916] = true -- Obsidian Scales
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

local groundingTable = {
    [357210] = true, -- Deep Breath
    [49576] = true, -- Death Grip
    [190925] = true, -- Harpoon
    [375901] = true, -- MindGames
    [19577] = true, -- Intimidation
    [3355] = true,    -- Freezing Trap
    [190319] = true, -- Combustion
    [102560] = true, -- Incarnation: Chosen of Elune
    [370965] = true, -- The Hunt
    [116858] = true, -- Chaos Bolt
    [199786] = true, -- Glacial Spike
    [359073] = true, -- Eternity Surge
    [387839] = true, -- Eternity Surge?
    [382411] = true, -- Eternity Surge?
    [428332] = true, -- Primordial Wave
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
    [359073] = true, -- Eternity Surge
    [387839] = true, -- Eternity Surge?
    [382411] = true, -- Eternity Surge?
    [428332] = true, -- Primordial Wave
}

local SAFE_ZONES = {
    "Stormwind City",
    "Ironforge",
    "Darnassus",
    "Exodar",
    "Shrine of Seven Stars",
    "Stormshield",
    "Dalaran",
    "Boralus",
    "Orgrimmar",
    "Thunder Bluff",
    "Undercity",
    "Silvermoon City",
    "Shrine of Two Moons",
    "Warspear",
    "Valdrakken",
    "Dazar'alor",
    "Dornogal"
  
  }

  function project.cd(spellObject)
    local gcd = 0
    if spellObject.gcd > 0 then
        gcd = awful.gcdRemains
    end
    return spellObject.cooldown - gcd
end
  
  function isPlayerInSafeZone()
    local zoneText = GetZoneText()
    for _, safeZone in ipairs(SAFE_ZONES) do
        if zoneText == safeZone then
            return true
        end
    end
    return false
  end
  
  local function combatCheck()
    local combatFound = false
    awful.fgroup.loop(function(friend)
        if friend.isInCombat then
            combatFound = true
            return true
        else 
            combatFound = false
        return false
        end
    end)
    return combatFound
end
  
  function project.isInValidInstance()
    local instanceType = select(2, IsInInstance())
    return instanceType == "arena" or instanceType == "pvp"
        or (instanceType == "raid" and combatCheck()) or instanceType == "scenario" and combatCheck() or (instanceType == "party" and combatCheck()) or 
        (instanceType == "none" and (combatCheck() and not isPlayerInSafeZone() or target.dummy))
  end
  
  awful.onEvent(function(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
      instanceType = select(2, IsInInstance())
    end
  end)

local function isLocked(unit)
    if unit.lockouts.nature then return true end
    if unit.lockouts.holy then return true end
    if unit.lockouts.fire then return true end
    if unit.lockouts.frost then return true end
    if unit.lockouts.arcane then return true end
    if unit.lockouts.shadow then return true end
    return false
end


awful.addEventCallback(function(eventinfo, event, source, dest)
    if not project.isInValidInstance() then return end
    if source ~= awful.player then return end

    local spellName, spellID = eventinfo[13], eventinfo[12]

    if event == "SPELL_CAST_SUCCESS" then
        if spellID == stasis.id and project.stasisState == 0 then
            project.stasisState = 1
            project.stasisInitialSequence = true
        elseif spellID == verdantEmbrace.id and project.stasisState == 1 then
            project.stasisState = 2
        elseif spellID == echo.id and project.stasisState == 2 then
            project.stasisState = 3
        elseif event == "SPELL_EMPOWER_END" and spellID == dreamBreath.id then -- Dream Breath end
            if project.stasisState == 3 then
                project.stasisState = 4
                project.stasisInitialSequence = false
            end
        end
    elseif spellID == stasisRelease.id and project.stasisState == 4 then
        project.stasisState = 0
    end
end)

local HIT_FLAGS = {
    M2Collision = 0x1,
    M2Render = 0x2,
    WMOCollision = 0x10,
    WMORender = 0x20,
    Terrain = 0x100,
    WaterWalkableLiquid = 0x10000,
    Liquid = 0x20000,
    EntityCollision = 0x100000,
    Unknown = 0x200000
}

local function distanceToLine(x1, y1, x2, y2, px, py)
    local A = px - x1
    local B = py - y1
    local C = x2 - x1
    local D = y2 - y1

    local dot = A * C + B * D
    local len_sq = C * C + D * D
    local param = dot / len_sq

    local xx, yy
    if param < 0 then
        xx, yy = x1, y1
    elseif param > 1 then
        xx, yy = x2, y2
    else
        xx = x1 + param * C
        yy = y1 + param * D
    end

    local dx = px - xx
    local dy = py - yy
    return math.sqrt(dx * dx + dy * dy)
end

local DEEP_BREATH_FLAGS = bit.bor(
    HIT_FLAGS.M2Collision,
    HIT_FLAGS.WMOCollision,
    HIT_FLAGS.Terrain  -- Re-added for wall and mountainside detection
)

local function isPathClearForDeepBreath(startX, startY, startZ, endX, endY, endZ)
    local characterHeight = 2  -- Approximate character height
    local breathHeight = 5     -- Estimated height of Deep Breath above the character
    local checkHeights = {0, characterHeight, breathHeight, breathHeight + characterHeight}
    
    for _, heightOffset in ipairs(checkHeights) do
        -- Check the direct path
        local hitX, hitY, hitZ = TraceLine(
            startX, startY, startZ + heightOffset, 
            endX, endY, endZ + heightOffset, 
            DEEP_BREATH_FLAGS
        )
        if hitX ~= nil then
            -- Found an obstacle at this height
            return false
        end
        
        -- Check for walls or steep inclines
        local stepDistance = 5 -- Check every 5 yards
        local steps = math.floor(math.sqrt((endX-startX)^2 + (endY-startY)^2) / stepDistance)
        for i = 1, steps do
            local stepX = startX + (endX - startX) * (i / steps)
            local stepY = startY + (endY - startY) * (i / steps)
            
            -- Check for a wall or steep incline
            local _, _, groundZ = TraceLine(stepX, stepY, startZ + 100, stepX, stepY, startZ - 100, DEEP_BREATH_FLAGS)
            if groundZ and (groundZ > startZ + breathHeight) then
                -- Found a wall or steep incline that's too high
                return false
            end
        end
    end
    
    -- No obstacles found
    return true
end

local function willDeepBreathHit(startX, startY, startZ, endX, endY, endZ, targetX, targetY, targetZ)
    local distance = distanceToLine(startX, startY, endX, endY, targetX, targetY)
    if distance > 7.5 then return false end -- Half of the 15-yard width

    -- Check if there's a clear path for the breath
    return isPathClearForDeepBreath(startX, startY, startZ, targetX, targetY, targetZ)
end

local KNOCK_FLAGS = bit.bor(0x100, 0x10, 0x1)  -- Terrain, WMOCollision, M2Collision

local function canKnockOffMap(unit, knockbackDistance, minDropDistance)
    if not unit or not unit.position then return false end
    local tx, ty, tz = unit.position()
    if not tx or not ty or not tz then return false end

    local px, py, pz = player.position()
    local dx, dy = tx - px, ty - py
    local length = math.sqrt(dx*dx + dy*dy)
    if length == 0 then return false end
    dx, dy = dx/length, dy/length

    local landX, landY = tx + dx * knockbackDistance, ty + dy * knockbackDistance
    
    -- Check the ground level at the landing spot
    local hitX, hitY, hitZ = TraceLine(landX, landY, tz + 5, landX, landY, tz - 100, KNOCK_FLAGS)
    
    -- If hitZ is nil, it means there's no ground within 100 yards below, definitely a drop
    if not hitZ then return true end
    
    -- Check if the drop is significant enough
    return (tz - hitZ) >= minDropDistance
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
                    Interact(flag.pointer)
                else
                    ObjectInteract(flag.pointer)
                end
            end
        end
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
        local maxDistance = 30
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

local function friendCheck(unit)
    return 
    not unit.immuneHealing and
        not unit.dead and
        not unit.pet and
        unit.los and
        unit.friend and not
        unit.buff(timeStop.id) and
        project.hasLosBehindIceWall(player, unit)
        and not unit.debuff(207736)
end

local function enemyCheck(unit)
    return not unit.cc and
        not unit.bcc and
        not unit.dead and
        not unit.pet and
        unit.los and
        unit.enemy and 
        project.hasLosBehindIceWall(player, unit)
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

function project.useMedallion()
    if not project.medallion.equipped or project.medallion2.equipped then return end
    if project.medallion:Usable() and player.hp < project.settings.md and project.medallion.cd < 1 then
        project.medallion:Use()
    end

    if project.medallion2:Usable() and player.hp < project.settings.md and project.medallion.cd < 1 then
        project.medallion2:Use()
    end
end

function project.collectHealthstone()
    local soulwelled = awful.objects.within(5).find(function(obj) return obj.id == 303148 and obj.creator.friend end)
    if not awful.prep then return end
    if soulwelled and project.healthStones.count < 1 then
        if Unlocker.type == "daemonic" then
            if Interact(soulwelled.pointer) then return end
        else
            if ObjectInteract(soulwelled.pointer) then return end
        end
        return
    end
end

function project.healthStone()
    if project.healthStones:Usable() and player.hp < project.settings.hst and project.healthStones.count >= 1 and project.healthStones.cd < 1 then
        project.healthStones:Use()
    end
end

function project.stompTotems()
    local function homies(unit)
        if unit.dead then return false end
        if unit.pet then return false end
        if unit.immuneHealing then return false end
        return true
    end

    local lowestf = awful.fgroup.within(40).filter(homies).lowest

    if not lowestf.friend then return end
    if lowestf.hp < 50 then return end

    awful.totems.stomp(function(totem, uptime)
        if project.settings.stompsHigh[totem.id] then
            if uptime < 0.3 then return end
            if not totem.los then return end
            if totem.hp <= azureStrike.damage * 2 then
                if totem.dist > 25 then return end
                if azureStrike:Castable(totem) then azureStrike:Cast(totem) end
            end
            if totem.hp > azureStrike.damage * 2 then
                if totem.dist > 30 then return end
                if livingFlame:Castable(totem) and (player.buff(ancientFlame.id) or player.buff(lifeSpark.id) or player.buff(hover.id)) then livingFlame:Cast(totem) end
            end
        end


        if project.settings.stomps[totem.id] then
            if uptime < 0.3 then return end
            if not totem.los then return end
            if totem.hp <= azureStrike.damage * 2 then
                if totem.dist > 25 then return end
                if azureStrike:Castable(totem) then azureStrike:Cast(totem) end
            end
            if totem.hp > azureStrike.damage * 2 then
                if totem.dist > 30 then return end
                if livingFlame:Castable(totem) and (player.buff(ancientFlame.id) or player.buff(lifeSpark.id) or player.buff(hover.id)) then livingFlame:Cast(totem) end
            end
            return
        end
    end)
end


local function aimbots()
    local function nerds(unit)
        return enemyCheck(unit)
    end

    local function homies(unit)
        return friendCheck(unit)
    end

    -- New function to get the current spell range
    local function getCurrentSpellRange()
        if (player.channelID == fireBreathRank4.id or player.channelID == fireBreath.id) then
            return 25
        elseif (player.channelID == spiritBloomChannel.id or player.channelID == spiritBloom.id) then
            return 30
        elseif (player.channelID == dreamBreathChannel.id or player.channelID == dreamBreath.id) then
            return 30
        elseif player.casting and player.castID == livingFlame.id then
            return 30
        else
            return 30
        end
    end

    local currentRange = getCurrentSpellRange()
    local loweste = awful.enemies.within(currentRange).filter(nerds).lowest
    local lowestf = awful.fgroup.within(currentRange).filter(homies).lowest

    if not lowestf.friend then return end
    if not loweste.enemy then return end
    -- PlayerCastingBarFrame.CurrSpellStage >= 1
    --fireBreath
    if fireBreathChanneling and not player.moving then
        if (player.channelID == fireBreathRank4.id or player.channelID == fireBreath.id) and player.channelTimeComplete >= 0.1 and not loweste.playerFacing45 then
            player.face(loweste, 45)
        end
    end

    --dreamBreath
    if player.channelID == 382614 and player.channelTimeComplete >= 0.1 and not player.moving and not lowestf.playerFacing45 and (player.channelID == 355936 or player.channelID == dreamBreath.id) then
        player.face(lowestf, 45)
    end

    --livingFlame
    if lowestf.hp > 80 and player.buff(leapingFlames.id) and player.casting and player.castID == livingFlame.id and player.castTarget.isUnit(loweste) and player.castTimeComplete >= 0.1 and not loweste.playerFacing45 then
        player.face(loweste, 45)
    end

    if player.buff(leapingFlames.id) and player.casting and player.castID == livingFlame.id and player.castTarget.isUnit(lowestf) and player.castTimeComplete >= 0.1 and not lowestf.playerFacing45 then
        player.face(lowestf, 45)
    end

    -- dream projection
    if player.buff(dreamProjection.id) and not lowestf.playerFacing45 then
        player.face(lowestf, 45)
    end
end

local function releases()

    if player.dead then
        project.stasisState = 0
    end

    if (player.channelID == fireBreathRank4.id or player.channelID == fireBreath.id) then
        fireBreathChanneling = true
    end

    if (player.channelID == spiritBloomChannel.id or player.channelID == spiritBloom.id) then
        spiritBloomChanneling = true
    end

    if (player.channelID == dreamBreathChannel.id or player.channelID == dreamBreath.id) then
        if PlayerCastingBarFrame.CurrSpellStage == 1 then
        dreamBreath:Release()
        end
    end

    if spiritBloomChanneling then
        if PlayerCastingBarFrame.CurrSpellStage == 2 then
            spiritBloom:Release()
            spiritBloomChanneling = false
        end
    end

    if fireBreathChanneling and not player.moving then
    if (PlayerCastingBarFrame.CurrSpellStage == 4 and player.hasTalent(fontOfMagic.id) or PlayerCastingBarFrame.CurrSpellStage >= 3 and not player.hasTalent(fontOfMagic.id)) then
        fireBreath:Release()
        fireBreathChanneling = false
    end
end

    if player.buff(dreamProjection.id) then
        local function homies(unit)
            return not unit.debuff(UA.id) and
                friendCheck(unit)
        end

        local homie = awful.fgroup.within(12).filter(homies).lowest
        if not homie.friend then return end
        return dreamCancel:Cast({ castByID = true })
    end

    local tremor = awful.totems.find(function(t) return t.id == 5913 and t.creator.enemy end)

    if player.casting and player.castID == (sleepWalk.id) and tremor and tremor.distanceTo(enemyHealer) <= 30 then
    awful.call("SpellStopCasting")
    end

    if player.casting and player.castID == sleepWalk.id and player.castTarget.isUnit(enemyHealer) and 
    (enemyHealer.cc or enemyHealer.bcc) and 
    (enemyHealer.ccRemains > sleepWalk.castTime + awful.buffer or enemyHealer.bccRemains > sleepWalk.castTime + awful.buffer) then
    awful.call("SpellStopCasting")
    end

end

awful.addUpdateCallback(aimbots)
awful.addUpdateCallback(releases)

furyOfTheAspects:Callback(function(spell)
    if select(2, IsInInstance()) == "arena" then return end
    local nerd = 0
    local function homies(unit)
        return unit.cds and
            unit.friend and not
            unit.pet and not
            unit.dead
    end

    awful.fgroup.within(40).filter(homies).loop(function()
        nerd = nerd + 1
    end)

    if nerd < 1 then return end

    return spell:Cast(player)
end)

dreamCancel:Callback(function(spell)
    if not player.buff(dreamProjection.id) then return end

    local function homies(unit)
        return not unit.debuff(UA.id) and
            friendCheck(unit) and
            unit.distanceTo(player) <= 12 and not
            unit.isUnit(player)
    end

    local homie = awful.fgroup.within(12).filter(homies)
    if #homie < 1 then return end

    return spell:Cast({ castByID = true })
end)


azureStrike:Callback("combat", function(spell)
    if player.combat then return end
    if not select(2, IsInInstance()) == "arena" then return end

    local function nerds(unit)
        return enemyCheck(unit)
    end

    local nub = awful.enemies.within(spell.range).filter(nerds).lowest
    if not nub.enemy then return end

    return spell:Cast(nub)
end)

azureStrike:Callback("slow", function(spell)
    if not player.combat then return end
    if not select(2, IsInInstance()) == "arena" then return end

    local function nerds(unit)
        return enemyCheck(unit) and not 
        unit.debuff(permiatingChill.id) and 
        unit.enemiesattacking
    end

    local function homies(unit)
        return friendCheck(unit) end

    local lowestf = awful.fgroup.within(spell.range).filter(homies).lowest
    local nub = awful.enemies.within(spell.range).filter(nerds).lowest

    if not nub.enemy then return end
    if lowestf.friend and lowestf.hp <= project.settings.echo then return end

    return spell:Cast(nub)
end)

local function shouldPreEcho(unit)
    -- Don't echo if we can't cast it
    if echo.cd > awful.gcd then return false end
    -- Need resource check
    if not (player.essence >= 2 or player.buff(essenceBurst.id)) then return false end
    -- Don't double echo
    if unit.buff(echo.id, player) then return false end
    -- Unit validity check
    if not friendCheck(unit) then return false end
    
    -- Pre-echo conditions:
    -- 1. Unit is low and we can reversion
    if unit.hp <= project.settings.reversion and reversion.cd < awful.gcd then return true end
    -- 2. We're about to dreambreath and they're low
    if unit.hp <= project.settings.db and dreamBreath.cd < awful.gcd then return true end
    -- 3. We're about to spiritbloom and they're low 
    if unit.hp <= project.settings.sb and spiritBloom.cd < awful.gcd then return true end
    -- 4. Emergency VE condition
    if unit.hp <= project.settings.ve and verdantEmbrace.cd < awful.gcd then return true end
    
    return false
end

function project.shouldWaitForEcho(unit, hpThreshold)
    -- Don't wait if Echo is on a long CD
    if echo.cd > awful.gcd * 2 then return false end
    
    -- Don't wait if we don't have/won't have resources for Echo
    if player.essence < 1 and not player.buff(essenceBurst.id) then return false end
    
    -- Don't wait if target already has Echo
    if unit.buff(echo.id, player) then return false end

    -- Critical case - don't wait if target might die
    if unit.hp < 25 then return false end

    -- Wait if we're about to be able to Echo
    return echo.cd <= awful.gcd and (player.essence >= 2 or player.buff(essenceBurst.id))
end


echo:Callback(function(spell)
    local total, _, _, cds = project.LowestUnit.v2attackers()
    if project.cd(spell) > 0 then return end
    if player.hasTalent(energyLoop.id) and player.manaPct < 10 then return end
    if not friendCheck(project.LowestUnit) then return end

    if shouldPreEcho(project.LowestUnit) then
        return spell:Cast(project.LowestUnit) 
    end

    if project.LowestUnit.buff(echo.id, player) then return end
    if project.LowestUnit.hp > project.settings.echo then return end
    if player.essence >= 2 or player.buff(essenceBurst.id) then
    return spell:Cast(project.LowestUnit)
    end
end)


rewind:Callback(function(spell)
    local nerd = false
    if project.cd(spell) > 0 then return end
    if tipTheScales.cd < awful.gcd and (dreamBreath.cd < awful.gcd or spiritBloom.cd < awful.gcd) then return end
    if project.cd(emeraldCommunion) <= 0 then return end
    if player.buff(emeraldCommunion.id) then return end
    if player.debuffFrom({ 33786, 221527 }) then return end
    if timeStop.prevgcd then return end

    awful.fgroup.within(spell.range).loop(function(unit)
        if not friendCheck(unit) then return end
        if unit.hp > 38 then return end
        nerd = true
    end)
    if not nerd then return end
    return spell:Cast()
end)

reversion:Callback(function(spell)
    if project.cd(spell) > 0 then return end
    if not project.LowestUnit.buff(echo.id, player) and echo:Castable(project.LowestUnit) then return end
    if (project.LowestUnit.buff(reversion.id, player) or project.LowestUnit.buff(reversion2.id, player)) then return end
    if not reversion:Castable(project.LowestUnit) then return end
    if project.LowestUnit.hp > project.settings.reversion then return end

    return spell:Cast(project.LowestUnit)
end)

verdantEmbrace:Callback(function(spell)
    if (stasis.cd < awful.gcd and verdantEmbrace.cd < awful.gcd and dreamBreath.cd < awful.gcd) then return end
    

    if project.cd(spell) > 0 then return end
    if player.rooted then return end

    local function homies(unit)
        local total, _, _, cooldowns = unit.v2attackers()
        return friendCheck(unit) and total >= 1 and
            unit.buff(echo.id, player) and
            unit.hp <= project.settings.ve
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end
    if project.shouldWaitForEcho(lowest, project.settings.ve) then return end

    if not verdantEmbrace:Castable(lowest) then return end
    return spell:Cast(lowest)
end)

dreamProjection:Callback(function(spell)
    local instanceType = select(2, IsInInstance())
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and combatCheck())) then return end

    if project.cd(spell) > 0 then return end

    local function homies(unit)
        return not unit.debuff(UA.id) and
            unit.buff(echo.id, player) and
            friendCheck(unit) and
            unit.hp <= project.settings.dp
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest

    if not lowest.friend then return end
    if player.moving and not player.buff(spatialParadox.id) then return end

    return spell:Cast(lowest, { face = true })
end)

dreamBreath:Callback(function(spell)
if (stasis.cd < awful.gcd and verdantEmbrace.cd < awful.gcd) then return end

    if project.cd(spell) > 0 then return end

    local function homies(unit)
        return
            friendCheck(unit) and
            unit.hp <= project.settings.db and
            unit.enemiesattacking 
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end
    if project.shouldWaitForEcho(lowest, project.settings.db) then return end

    return spell:Cast({ stopMoving = true })
end)

dreamBreath:Callback("buff", function(spell)
    if (stasis.cd < awful.gcd and verdantEmbrace.cd < awful.gcd) then return end

    if project.cd(spell) > 0 then return end

    local function homies(unit)
        return
            friendCheck(unit)
            
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    if player.buff(callOfYsera.id) then
    return spell:Cast({ stopMoving = true })
    end
end)

spiritBloom:Callback(function(spell)
    if project.cd(spell) > 0 then return end
    if player.moving then return end

    local function homies(unit)
        return
            friendCheck(unit) and
            unit.hp <= project.settings.sb
            
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end
    if project.shouldWaitForEcho(lowest, project.settings.sb) then return end

    return spell:Cast()
end)

spiritBloom:Callback("low", function(spell)
    if not project.settings.tts then return end
    if project.settings.otts then return end
    if project.cd(spell) > 0 then return end

    local function homies(unit)
        return friendCheck(unit) and
            unit.buff(echo.id, player) and
            unit.hp <= 45
            
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest

    if not lowest.friend then return end
    tipTheScales:Cast()
    spell:Cast()
    return true
end)

rescue:Callback(function(spell)
    local x,y,z = GetBestPositionAwayFromEnemies({range = 29, losPrio = false})
    if project.cd(spell) > 0 then return end
    if player.rooted then return end


    local function lowhp(unit)
        return friendCheck(unit) and not
            unit.rooted
    end

    local lowest = awful.fgroup.within(30).filter(lowhp).lowest

    if not lowest.friend then return end
    local total, melee, ranged, cooldowns = lowest.v2attackers()

    if lowest.hp <= 50 and total >= 1 then
        lowest.setTarget()
        return spell:AoECast(x,y,z)
    end

    if lowest.hp <= 80 and total >= 2 and cooldowns >= 2 then
        lowest.setTarget()
        return spell:AoECast(x,y,z)
    end
end)

rescue:Callback("kill", function(spell)
    if project.cd(spell) > 0 then return end
    if player.rooted then return end

    local function lowhp(unit)
        return enemyCheck(unit) and not unit.rooted
        
    end

    local function lowhpf(unit)
        return enemyCheck(unit) and not unit.rooted
    end

    local lowestf = awful.fgroup.within(spell.range).filter(lowhpf).lowest
    local loweste = awful.enemies.within(spell.range).filter(lowhp).lowest
    if not loweste.enemy then return end
    if not lowestf.friend then return end

    local total, melee, ranged, cooldowns = loweste.v2attackers()
    local x, y, z = loweste.position()

    if loweste.hp <= 80 and total < 2 and cooldowns < 2 then return end
    if loweste.hp <= 50 and total < 1 then return end

    local meleeHomie = nil
    awful.fgroup.within(spell.range).loop(function(friend)
        if friend.melee and friend.target and friend.target.isUnit(loweste) then
            meleeHomie = friend
            return true
        end
    end)

    if meleeHomie then
        local meleeRange = 12
        if meleeHomie.distanceTo(loweste) > meleeRange then
            meleeHomie.setTarget()
            return spell:AoECast(x, y, z)
        end
    end
end)

dreamBreath:Callback("low", function(spell)
    if project.settings.otts then return end
    if not project.settings.tts then return end
    if (tipTheScales.cd < awful.gcd and spiritBloom.cd < awful.gcd) then return end
    if (stasis.cd < awful.gcd and verdantEmbrace.cd < awful.gcd and dreamBreath.cd < awful.gcd) then return end

    if project.cd(tipTheScales) > 0 then return end
    if project.cd(spell) > 0 then return end

    local function homies(unit)
        return friendCheck(unit) and
            unit.hp <= 45
            
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest

    if not lowest.friend then return end

    tipTheScales:Cast()
    if not lowest.playerFacing45 then player.face(lowest) end
    return spell:Cast()
end)

local function shouldHover()
    local total, melee, ranged, cooldowns = player.v2attackers()
    local function homies(unit)
        return friendCheck(unit)
    end

    local lowestf = awful.fgroup.within(40).filter(homies).lowest
    if not lowestf.friend then return end

    if lowestf.dist > 25 then return true end
    if melee >= 1 then return true end
    if total >= 1 and player.slowed and player.hasTalent(378437) then return true end
    if not lowestf.los and player.movingToward(lowestf, { angle = 180, duration = 0.5}) then return true end
    if enemyHealer.movingToward(player, { angle = 180, duration = 0.5}) and player.movingAwayFrom(enemyHealer, { angle = 320, duration = 0.5}) then return true end

    return false
end

hover:Callback(function(spell)
    if player.buff(hover.id) then return end
    if not player.moving then return end
    if spell.charges < 1 then return end
    if not shouldHover() then return end
    return spell:Cast()
end)

livingFlame:Callback("friend", function(spell)
    if player.buff(ancientFlame.id) then return end
    if player.buff(leapingFlames.id) then return end
    if player.buff(essenceBurst.id) and echo.cd ~= 0 then return end
    if player.moving and not (player.buff(hover.id) or player.buff(spatialParadox.id)) then return end
    if project.cd(dreamBreath) <= 0 then return end
    if project.cd(dreamProjection) <= 0 then return end
    if player.buff(stasis.id) then return end


    local function homies(unit)
        return friendCheck(unit) and
            unit.hp <= 80
            
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    if echo.cd < awful.gcd and (player.essence >= 2 or player.buff(essenceBurst.id)) then return end
    if reversion.cd < awful.gcd and not (lowest.buff(reversion.id, player) and lowest.buff(reversion2.id, player)) then return end

    return spell:Cast(lowest)
end)

spatialParadox:Callback(function(spell)
    local function homies(unit)
        return friendCheck(unit) and
            unit.dist > 30 and
            unit.hpa <= 50
    end
    local homie = awful.fgroup.within(spell.range).filter(homies).lowest
    if not homie.friend then return end

    return spell:Cast()
end)

livingFlame:Callback("enemy", function(spell)
    if player.buff(ancientFlame.id) then return end
    if player.buff(leapingFlames.id) then return end
    if player.buff(stasis.id) then return end
    if player.moving and not (player.buff(hover.id) or player.buff(spatialParadox.id)) then return end
    if player.buff(essenceBurst.id) and disintegrate.cd < awful.gcd or (echo.cd < awful.gcd and player.essence >= 2 or player.buff(essenceBurst.id)) then return end

    local function nerds(unit)
        return
            enemyCheck(unit) and
            spell:Castable(unit)
            
    end

    local function homies(unit)
        return friendCheck(unit)
    end

    local loweste = awful.enemies.within(spell.range).filter(nerds).lowest
    local lowestf = awful.fgroup.within(spell.range).filter(homies).lowest

    if not loweste.enemy then return end
    if not lowestf.friend then return end
    if lowestf.hp <= 80 then return end
    if not spell:Castable(loweste) then return end
    return spell:Cast(loweste)
end)

livingFlame:Callback("proc", function(spell)
    if not ((player.buff(leapingFlames.id) and player.buff(ancientFlame.id)) or player.buff(lifeSpark.id)) then return end
    if wasCasting[sleepWalk.id] then return end
    if player.buff(stasis.id) then return end

    local function nerds(unit)
        return
            enemyCheck(unit) and
            spell:Castable(unit)
            
    end

    local function homies(unit)
        return friendCheck(unit)
        
    end

    local loweste = awful.enemies.within(spell.range).filter(nerds).lowest
    local lowestf = awful.fgroup.within(spell.range).filter(homies).lowest

    if not loweste.enemy then return end
    if not lowestf.friend then return end

    if lowestf.hp <= 80 then
        return spell:Cast(lowestf)
    else
        return spell:Cast(loweste)
    end
end)

emeraldCommunion:Callback(function(spell)
    local nerd = false
    if player.debuffFrom({ 33786, 221527 }) then return end
    if project.cd(spell) > 0 then return end

    awful.fgroup.within(40).loop(function(unit)
        if not friendCheck(unit) then return end
        if unit.hp > 30 then return end
        nerd = true
    end)
    if not nerd then return end
    return spell:Cast()
end)

timeDilation:Callback(function(spell)
    if spell.cd > 0 then return end
    local function homies(unit)
        return friendCheck(unit)
        
    end

    local lowestf = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowestf.friend then return end

    local total, melee, ranged, cooldowns = lowestf.v2attackers()

    if (total >= 1 and cooldowns >= 1 or total >= 1 and lowestf.hp <= 50) then
        if not spell:Castable(lowestf) then return end
        return spell:Cast(lowestf)
    end
end)


fireBreath:Callback(function(spell)
    if project.cd(fireBreathRank4) > 0 then return end
    if player.buff(tipTheScales.id) then return end
    --if player.buff(temporalCompression.id) and player.buffStacks(temporalCompression.id) < 3 then return end
    --if player.buff(temporalCompression.id) and player.buffRemains(temporalCompression.id) < 2 then return end
    if player.moving then return end

    local function nerds(unit)
        return
            enemyCheck(unit)
    end

    local function homies(unit)
        return friendCheck(unit)
    end

    local loweste = awful.enemies.within(25).filter(nerds).lowest
    local lowestf = awful.fgroup.within(40).filter(homies).lowest


    if not loweste.enemy then return end
    if not lowestf.friend then return end
    if lowestf.hp <= 40 then return end

    return fireBreathRank4:Cast({ stopMoving = true })
end)

fireBreath:Callback("offensive", function(spell)
if tipTheScales.cd > awful.gcd then return end
if project.cd(fireBreathRank4) > 0 then return end
if project.settings.tts then return end
if not project.settings.otts then return end

local function nerds(unit)
    return enemyCheck(unit)
end

local loweste = awful.enemies.within(25).filter(nerds).lowest
if not loweste.enemy then return end

if not loweste.playerFacing45 then player.face(loweste, 45) end
tipTheScales:Cast()
return fireBreathRank4:Cast({ face = true })
end)

fireBreath:Callback("kill", function(spell)
    if project.cd(fireBreathRank4) > 0 then return end

    local function nerds(unit)
        return enemyCheck(unit)
    end

    local loweste = awful.enemies.within(25).filter(nerds).lowest
    if not loweste.enemy then return end

    if loweste.hpa <= 20 and tipTheScales.cd > awful.gcd and not
        player.buff(tipTheScales.id) and fireBreathRank4.cd < awful.gcd then
        --if player.casting or player.channeling then awful.call("SpellStopCasting") end
        if not loweste.playerFacing45 then player.face(loweste, 45) end
        return spell:Cast({ stopMoving = true, face = true})
    end

    if loweste.hpa <= 35 and tipTheScales.cd < awful.gcd and fireBreathRank4.cd < awful.gcd then
        --if player.casting or player.channeling then awful.call("SpellStopCasting") end
        if not loweste.playerFacing45 then player.face(loweste, 45) end
        tipTheScales:Cast()
        return fireBreathRank4:Cast({ face = true })
    end
end)

landSlide:Callback("healer", function(spell)
    if project.cd(spell) > 0 then return end
    if enemyHealer.rdr < 0.5 then return end
    if enemyHealer.dist > 50 then return end
    if enemyHealer.dist < 15 then return end
    if not enemyHealer.los then return end
    local x, y, z = enemyHealer.predictPosition(0.5)
    return spell:AoECast(x, y, z)
end)

landSlide:Callback("peel", function(spell)
    if project.cd(spell) > 0 then return end
    local function nerds(unit)
        return unit.rdr >= 0.5 and
            unit.dist < 50 and
            unit.dist >= 15 and not
            unit.immuneMagic and not
            unit.rooted and not
            unit.cc and not
            unit.bcc and
            unit.melee and
            unit.cds
    end

    local lowest = awful.enemies.within(spell.range).filter(nerds).lowest

    local x, y, z = lowest.predictPosition(0.5)
    return spell:AoECast(x, y, z)
end)


disintegrate:Callback("kill", function(spell)
    if project.cd(spell) > 0 then return end
    if player.essence < 3 then return end
    if tipTheScales.cd < awful.gcd and fireBreathRank4.cd < awful.gcd then return end
    if player.moving and not player.buff(hover.id) then return end

    local function nerds(unit)
        return
            enemyCheck(unit)
            
    end


    local loweste = awful.enemies.within(spell.range).filter(nerds).lowest

    if not loweste.enemy then return end
    if not disintegrate:Castable(loweste) then return end
    if loweste.hpa > 20 then return end


    loweste.setTarget()
    return spell:Cast(loweste)
end)

disintegrate:Callback("slow", function(spell)
    if project.cd(spell) > 0 then return end
    if player.moving and not player.buff(hover.id) then return end

    local function nerds(unit)
        return
            enemyCheck(unit)
            
    end


    local function homies(unit)
        return friendCheck(unit)
    end


    local loweste = awful.enemies.within(spell.range).filter(nerds).lowest
    local lowestf = awful.fgroup.within(spell.range).filter(homies).lowest



    if not loweste.enemy then return end
    if not lowestf.friend then return end

    local total, melee, ranged, cooldowns = loweste.v2attackers()
    if not disintegrate:Castable(loweste) then return end
    if loweste.hpa > 40 then return end
    if lowestf.hp < 50 then return end
    if melee < 1 then return end

    if player.essence >= 3 or player.buff(essenceBurst.id) then
        loweste.setTarget()
        return spell:Cast(loweste)
    end
end)

disintegrate:Callback("dam", function(spell)
    if project.cd(spell) > 0 then return end
    if player.moving and not player.buff(hover.id) then return end

    local function nerds(unit)
        return
            enemyCheck(unit)
    end


    local function homies(unit)
        return friendCheck(unit)
    end


    local loweste = awful.enemies.within(spell.range).filter(nerds).lowest
    local lowestf = awful.fgroup.within(spell.range).filter(homies).lowest

    if not loweste.enemy then return end
    if not lowestf.friend then return end

    local total, melee, ranged, cooldowns = loweste.v2attackers()
    if not disintegrate:Castable(loweste) then return end
    if lowestf.hp < project.settings.echo and echo.cd < awful.gcd then return end

    if player.essence >= 3 or player.buff(essenceBurst.id) then
        loweste.setTarget()
        return spell:Cast(loweste)
    end
end)

disintegrate:Callback("mana", function(spell)
    if project.cd(spell) > 0 then return end
    if player.moving and not player.buff(hover.id) then return end
    if not player.hasTalent(energyLoop.id) then return end

    local function nerds(unit)
        return
            enemyCheck(unit)
            
    end


    local loweste = awful.enemies.within(spell.range).filter(nerds).lowest

    if (player.manaPct <= 10 or lowestf.hp >= 80 and player.manaPct <= 90) then
        if not loweste.playerFacing45 then player.face(loweste) end
        loweste.setTarget()
        return spell:Cast(loweste)
    end
end)

unravel:Callback(function(spell)
    if project.cd(spell) > 0 then return end
    if not player.hasTalent(unravel.id) then return end
    if player.hasTalent(unravel.id) and unravel.cd > awful.gcd then return end

    local function nerds(unit)
        return
            enemyCheck(unit) and unit.absorbs >= 50000
    end

    local loweste = awful.enemies.within(spell.range).filter(nerds).lowest

    if not loweste.enemy then return end
    if not spell:Castable(loweste) then return end

    loweste.setTarget()
    return spell:Cast(loweste)
end)

renewingBlaze:Callback(function(spell)
    if spell.cd > 0 then return end
    local total, melee, ranged, cooldowns = player.v2attackers()

    if (cooldowns >= 2 and total >= 1 or player.hpa <= 40 and total >= 1) then
        return spell:Cast()
    end
end)

obsidianScales:Callback(function(spell)
    if spell.cd > 0 then return end
    local total, melee, ranged, cooldowns = player.v2attackers()
    if player.buff(obsidianScales.id) then return end

    if (cooldowns >= 1 and total >= 1 or player.hpa <= 60 and total >= 1) then
        return spell:Cast()
    end
end)

wingBuffet:Callback("knock", function(spell)
    if project.cd(spell) > 0 then return end
    if player.moving then return end

    local minDropDistance = 10   -- Minimum 10 yards drop
    local knockbackDistance = 15 -- Wing Buffet knockback distance

    local function canKnock(unit)
        return enemyCheck(unit) and
            unit.distance <= 15 and
            not unit.rooted and
            canKnockOffMap(unit, knockbackDistance, minDropDistance)
    end

    local knockableEnemies = awful.enemies.within(15).filter(canKnock)
    local count = #knockableEnemies

    if count < 1 then return end

    -- Find the nearest knockable enemy
    local nearestEnemy = knockableEnemies[1]
    for i = 2, count do
        if knockableEnemies[i].distance < nearestEnemy.distance then
            nearestEnemy = knockableEnemies[i]
        end
    end

    -- Cast on the nearest knockable enemy
    if nearestEnemy then
        if spell:Cast(nearestEnemy, { face = true }) then
            awful.print("Debug: Knocking Enemy")
        end
    end
end)

wingBuffet:Callback(function(spell)
    local nerds = nil
    if project.cd(spell) > 0 then return end
    local count, total, enemies = awful.enemies.around(player, 6)

    if project.cd(wingBuffet) > 0 then return end

    for i = 1, count do
        local nerd = enemies[i]
        if not wingBuffet:Castable(nerd) then return end
        if not enemyCheck(nerd) then return end
        if not nerd.melee then return end
        if nerd.rooted then return end
        if nerd.immuneCC then return end
        if player.channel8 then return end
        --if not nerd.playerFacing45 then player.face(nerd) end
        return spell:Cast(nerd, { face = true })
    end
end)

wingBuffet:Callback("kick", function(spell)
    local holdGCD = false

    local function enemyCasting(unit)
        return
            (unit.casting or unit.channeling) and (unit.castID or unit.channelID) and
            (project.flatCC[unit.castID] or project.flatCC[unit.channelID]) and not player.buff(groundingTotem.id) and
            unit.castRemains <= 0.5 or
            (project.flatDam[unit.castID] or project.flatDam[unit.channelID]) and not player.buff(groundingTotem.id) and
            unit.castRemains <= 0.5 or
            (project.flatHeals[unit.castID] or project.flatHeals[unit.channelID]) and unit.castRemains <= 0.5
    end

    awful.enemies.within(14).filter(enemyCasting).loop(function(nerd)
        if not quell:Castable(nerd) or (nerd.casting8 or nerd.channel7) then
            if wingBuffet:Castable() and not nerd.immunePhysical and not nerd.rooted then
                --if not nerd.playerFacing45 then player.face(nerd) end
                if spell:Cast(nerd, { face = true }) then
                    return true
                end
            end
        end

        if quell.cd > awful.gcd or (nerd.casting8 or nerd.channel7) and awful.gcdRemains > 0.5 then
            holdGCD = true
            return true
        end
    end)

    return holdGCD
end)

tailSwipe:Callback(function(spell)
    if project.cd(spell) > 0 then return end
    local count, total, enemies = awful.enemies.around(player, 8)
    if project.cd(tailSwipe) > 0 then return end

    for i = 1, count do
        local nerd = enemies[i]
        if not enemyCheck(nerd) then return end
        if not spell:Castable(nerd) then return end
        if not nerd.melee then return end
        if nerd.rooted then return end
        if nerd.immuneCC then return end
        if player.channel8 then return end
        return spell:Cast()
    end
end)

tailSwipe:Callback("kick", function(spell)
    if project.cd(wingBuffet) <= 0 then return end
    local holdGCD = false

    local function enemyCasting(unit)
        return
            (unit.casting or unit.channeling) and (unit.castID or unit.channelID) and
            (project.flatCC[unit.castID] or project.flatCC[unit.channelID]) and not player.buff(groundingTotem.id) and
            unit.castRemains <= 0.5 or
            (project.flatDam[unit.castID] or project.flatDam[unit.channelID]) and not player.buff(groundingTotem.id) and
            unit.castRemains <= 0.5 or
            (project.flatHeals[unit.castID] or project.flatHeals[unit.channelID]) and unit.castRemains <= 0.5
    end

    awful.enemies.within(8).filter(enemyCasting).loop(function(nerd)
        if quell.cd > awful.gcd or (nerd.casting8 or nerd.channel7) then
            if wingBuffet:Castable() and not nerd.immunePhysical and not nerd.rooted then
                if spell:Cast(nerd, { face = true }) then
                    return true
                end
            end
        end

        if quell.cd > awful.gcd and awful.gcdRemains > 0.5 then
            holdGCD = true
            return true
        end
    end)

    return holdGCD
end)

chronoLoop:Callback(function(spell)
    if not spell:Castable() then return end
    local instanceType = select(2, IsInInstance())
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and combatCheck())) then return end
    if project.cd(spell) > 0 then return end

    local function nerds(unit)
        return
            enemyCheck(unit) and not
            unit.immuneMagic and
            unit.hpa <= 35
    end

    local loweste = awful.enemies.within(spell.range).filter(nerds).lowest

    if not loweste.enemy then return end
    if not spell:Castable(loweste) then return end
    return spell:Cast(loweste)
end)

nullifyingShroud:Callback(function(spell)
    if not combatCheck() then return end
    if not spell:Castable(player) then return end
    local instanceType = select(2, IsInInstance())
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and combatCheck())) then return end

    if project.cd(spell) > 0 then return end
    if player.moving and not (player.buff(hover.id) or player.buff(spatialParadox.id)) then return end

    local function homies(unit)
        return friendCheck(unit) and
            unit.hp > 40
    end

    local lowest = awful.fgroup.within(40).filter(homies).lowest
    if not lowest.friend then return end
    return spell:Cast()
end)

blessingOfTheBronze:Callback(function(spell)
    if project.cd(spell) > 0 then return end
    local function homies(unit)
        return friendCheck(unit) and not unit.buff("Blessing of the Bronze")
    end

    local homie = awful.fgroup.within(spell.range).filter(homies)

    if #homie > 0 then
        return spell:Cast()
    end
end)

quell:Callback("CC", function(spell)
    if spell.cd > 0 then return end
    local aids = false
    local nerd = nil
    awful.enemies.within(spell.range).loop(function(enemy)
        if enemy and not enemy.player then return end
        if enemy and isLocked(enemy) then return end
        if enemy and not (enemy.casting or enemy.channeling) then return end
        if enemy and (enemy.casting8 or enemy.channel7) then return end
        if enemy and not enemy.los then return end
        if enemy and not (project.flatCC[enemy.castID] or project.flatCC[enemy.channelID]) then return end
        if enemy and not (enemy.castTarget.isUnit(player)) then return end
        if enemy and (enemy.castTimeComplete < delay.now or enemy.channelTimeComplete < delay.now) then return end
        if player.buff(groundingTotem.id) and player.buffRemains(groundingTotem.id) >= (enemy.castRemains or enemy.channelRemains) then return end
        if player.buff(nullifyingShroud.id) and player.buffRemains(nullifyingShroud.id) >= (enemy.castRemains or enemy.channelRemains) then return end
        if enemy.buff(preCog.id) and enemy.buffRemains(preCog.id) > awful.gcdRemains then return end
        if not spell:Castable(enemy) then return end
        aids = true
        nerd = enemy
    end)
    if not aids then return end
    return spell:Cast(nerd) and alert("Quell | " .. colors.red .. "CC", spell.id, true)
end)

quell:Callback("Heal", function(spell)
    if spell.cd > 0 then return end
    local lowestE = awful.enemies.within(spell.range).lowest
    local aids = false
    local nerd = nil
    awful.enemies.within(spell.range).loop(function(enemy)
        if enemy and not enemy.player then return end
        if enemy and isLocked(enemy) then return end
        if enemy and not (enemy.casting or enemy.channeling) then return end
        if enemy and (enemy.casting8 or enemy.channel7) then return end
        if enemy and not enemy.los then return end
        if enemy and not (project.flatHeals[enemy.castID] or project.flatHeals[enemy.channelID]) then return end
        if enemy and (enemy.castTimeComplete < delay.now or enemy.channelTimeComplete < delay.now) then return end
        if lowestE.hp > project.settings.khp then return end
        if enemy.buff(preCog.id) and enemy.buffRemains(preCog.id) > awful.gcdRemains then return end
        if not spell:Castable(enemy) then return end
        aids = true
        nerd = enemy
    end)
    if not aids then return end
    return spell:Cast(nerd) and alert("Quell | " .. colors.green .. "Heal", spell.id, true)
end)

quell:Callback("Dam", function(spell)
    local aids = false
    local nerd = nil
    if spell.cd > 0 then return end
    local function homies(unit)
        return unit.los and
            not unit.pet and
            not unit.dead and
            not unit.immuneMagic
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest

    awful.enemies.within(spell.range).loop(function(enemy)
        if enemy and not enemy.player then return end
        if enemy and isLocked(enemy) then return end
        if enemy and not (enemy.casting or enemy.channeling) then return end
        if enemy and (enemy.casting8 or enemy.channel7) then return end
        if enemy and not enemy.los then return end
        if enemy and not (project.flatDam[enemy.castID] or project.flatDam[enemy.channelID]) then return end
        if enemy and (project.flatCC[enemy.castID] or project.flatCC[enemy.channelID]) and enemy.castTarget.isUnit(player) and lowest.hp > 40 then return end
        if enemy and (enemy.castTimeComplete < delay.now or enemy.channelTimeComplete < delay.now) then return end
        if enemy and enemy.buff(preCog.id) then return end
        if player.buff(groundingTotem.id) and player.buffRemains(groundingTotem.id) >= (enemy.castRemains or enemy.channelRemains) then return end
        if not spell:Castable(enemy) then return end
        aids = true
        nerd = enemy
    end)
    if not aids then return end
    return spell:Cast(nerd) and alert("Quell | " .. colors.red .. "Damage", spell.id, true)
end)

naturalize:Callback(function(spell)
    local aids = false
    local homie = nil
    if spell.cd > 0 then return end
    local function homies(unit)
        return unit.friend and
            unit.los and
            not unit.pet and
            not unit.dead and
            unit.hp > 40
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest

    awful.fgroup.within(spell.range).loop(function(friend)
        if not friendCheck(friend) then return end
        if friend.debuff(UA.id) then return end                     -- Unstable Affliction
        if friend.debuff(34914) and lowest.hp <= 65 then return end -- Vampiric Touch
        if not friend.debuffFrom(cleanseTable) then return end
        homie = friend
        aids = true
    end)
    if not aids then return end
    return spell:Cast(homie)
end)

cauterizingFlame:Callback(function(spell)
    local aids = false
    local homie = nil
    if spell.cd > 0 then return end

    local function homies(unit)
        return unit.friend and
            unit.los and
            not unit.pet and
            not unit.dead and
            unit.hp > 40
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest

    awful.fgroup.within(spell.range).loop(function(friend)
        if not friendCheck(friend) then return end
        if friend.debuff(342938) then return end                    -- Unstable Affliction
        if friend.debuff(34914) and lowest.hp <= 65 then return end -- Vampiric Touch
        if not friend.debuffFrom(cauterizeTable) then return end
        aids = true
        homie = friend
    end)
    if not aids then return end
    return spell:Cast(homie)
end)


deepBreath:Callback("multi", function(spell)
    if project.cd(spell) > 0 then return end
    if not player.combat then return end
    if player.rooted then return end
    if not player.hasTalent(terrorOfTheSkies.id) then return end

    local px, py, pz = player.position()
    local bestDirection = nil
    local maxHits = 0

    for angle = 0, 2 * math.pi, math.pi / 4 do
        local endX = px + 50 * math.cos(angle)
        local endY = py + 50 * math.sin(angle)
        local hits = 0

        if isPathClearForDeepBreath(px, py, pz, endX, endY, pz) then
            awful.enemies.within(50).loop(function(enemy)
                local ex, ey, ez = enemy.position()
                if ex and ey and ez and willDeepBreathHit(px, py, pz, endX, endY, pz, ex, ey, ez) then
                    hits = hits + 1
                end
            end)
        end

        if hits > maxHits then
            maxHits = hits
            bestDirection = angle
        end
    end

    if maxHits >= 3 and bestDirection then
        local castX = px + 50 * math.cos(bestDirection)
        local castY = py + 50 * math.sin(bestDirection)
        return spell:AoECast(castX, castY, pz) and awful.print("Debug: Deep Breath - Multi")
    end
end)

deepBreath:Callback("healer", function(spell)
    if project.cd(spell) > 0 then return end
    if enemyHealer.sdr < 0.5 then return end
    if enemyHealer.speed > 10 then return end
    if enemyHealer.distance < 15 then return end
    if enemyHealer.dead then return end
    if not enemyHealer.los then return end
    if not player.combat then return end
    if enemyHealer.immuneMagic then return end
    if player.buff(renewingBlaze.id, player) then return end
    if player.rooted then return end
    if not player.hasTalent(terrorOfTheSkies.id) then return end
    if enemyHealer.cc and enemyHealer.ccRemains > 0.4 then return end
    if enemyHealer.bcc and enemyHealer.bccRemains > 0.4 then return end

    local function homies(unit)
        return friendCheck(unit) and
            unit.hpa > 40
    end

    local lowest = awful.fgroup.within(48).filter(homies).lowest
    if not lowest.friend then return end

    local x, y, z = enemyHealer.predictPosition(0.8)
    return spell:AoECast(x, y, z)
end)

sleepWalk:Callback("chainHealer", function(spell)
    local holdGCD = false
    if not spell:Castable(enemyHealer) then return end
    if wasCasting[sleepWalk.id] then return end
    if not enemyHealer.exists then return end
    if isLocked(enemyHealer) then return end
    if not enemyHealer.los then return end
    if enemyHealer.immuneMagic and enemyHealer.magicEffectImmunityRemains > spell.castTime then return end
    if enemyHealer.immuneCC and enemyHealer.ccImmunityRemains > spell.castTime then return end
    if enemyHealer.buffFrom(cantCC) then return end
    if enemyHealer.ddr < 0.5 then return end

    local function filter(unit)
        return unit.los
            and not unit.dead
            and not unit.pet
            and unit.dist <= 30
    end
    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if lowest.hp <= 50 then return end

    if (enemyHealer.cc and enemyHealer.ccRemains <= spell.castTime + awful.buffer) then
        return spell:Cast(enemyHealer)
    end

    if (enemyHealer.bcc and enemyHealer.bccRemains <= spell.castTime + awful.buffer) then
        return spell:Cast(enemyHealer)
    end


    if (enemyHealer.cc or enemyHealer.bcc) and (enemyHealer.ccRemains <= spell.castTime + awful.buffer or enemyHealer.bccRemains <= spell.castTime + awful.buffer) then
        holdGCD = true
    end

    return holdGCD
end)


sleepWalk:Callback("enemyHealer", function(spell)
    if not enemyHealer then return end
    if not spell:Castable(enemyHealer) then return end
    if wasCasting[sleepWalk.id] then return end

    local function filter(unit)
        return unit.los
            and not unit.pet
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if lowest.hp < 55 then return end

    local total, _, _, cooldowns = enemyHealer.v2attackers()

    if isLocked(enemyHealer) then return end
    if not enemyHealer.los then return end
    if enemyHealer.immuneMagic and enemyHealer.magicEffectImmunityRemains > spell.castTime then return end
    if enemyHealer.immuneCC and enemyHealer.ccImmunityRemains > spell.castTime then return end
    if enemyHealer.buffFrom(cantCC) then return end
    if enemyHealer.ddr < 0.5 then return end
    if total >= 1 then return end

    if not enemyHealer.cc or enemyHealer.bcc then
        return spell:Cast(enemyHealer)
    end
end)

sleepWalk:Callback("dps", function(spell)
    local canCast = false
    local nerd = nil
    if wasCasting[sleepWalk.id] then return end

    local function filter(unit)
        return not unit.pet
            and not unit.dead
    end

    local lowest = awful.fgroup.within(spell.range).filter(filter).lowest
    if lowest.hp then return end

    awful.enemies.within(spell.range).loop(function(enemy)
        local total, _, _, cooldowns = enemy.v2attackers()
        if not enemy then return end
        if not spell:Castable(enemy) then return end
        if enemy.pet then return end
        if enemy and isLocked(enemy) then return end
        if not enemy.los then return end
        if enemy.immuneMagic and enemy.magicEffectImmunityRemains > spell.castTime then return end
        if enemy.immuneCC and enemy.ccImmunityRemains > spell.castTime then return end
        if enemy.buffFrom(cantCC) then return end
        if total >= 1 then return end
        if enemy.isUnit(enemyHealer) then return end
        if (enemy.cc and enemy.ccRemains > spell.castTime + awful.buffer) then return end
        if (enemy.bcc and enemy.bccRemains > spell.castTime + awful.buffer) then return end
        nerd = enemy
        canCast = true
    end)

    if not canCast then return end
    return spell:Cast(nerd)
end)

timeStop:Callback(function(spell)
    local instanceType = select(2, IsInInstance())
    if not (instanceType == "pvp" or instanceType == "arena" or (instanceType == "none" and combatCheck())) then return end
    if player.buff(tipTheScales.id) then return end
    local function homies(unit)
        return friendCheck(unit) and not
            unit.buff(rewind.id) and
            unit.hpa <= 30
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    return spell:Cast(lowest)
end)

timeStopCancel:Callback(function(spell)
    local function homies(unit)
        return friendCheck(unit) and unit.buff(timeStop.id)
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end
    if lowest.enemiesattacking then return end


    return spell:Cast()
end)


-- Stasis Sequence
stasis:Callback("cast", function(spell)
    if project.stasisState ~= 0 then return end
    if (verdantEmbrace.cd > awful.gcd and dreamBreath.cd > awful.gcd) then return end
    if not player.combat then return end

    local function hasEchoBuff(unit)
        return friendCheck(unit) and unit.hp <= 85
    end

    local lowestWithEcho = awful.fgroup.within(40).filter(hasEchoBuff).lowest
    if not lowestWithEcho.friend then return end

    if player.essence >= 2 or player.buff(essenceBurst.id) then
        return spell:Cast()
    end
end)

verdantEmbrace:Callback("stasis", function(spell)
    if project.stasisState ~= 1 then return end
    if project.cd(spell) > 0 then return end

    local function homies(unit)
        return friendCheck(unit) and unit.enemiesattacking
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    if spell:Cast(lowest) then
        return
    end
end)

echo:Callback("stasis", function(spell)
    if project.stasisState ~= 2 then return end
    if project.cd(spell) > 0 then return end

    local function homies(unit)
        return friendCheck(unit) and not
            unit.buff(echo.id, player) and
            unit.enemiesattacking
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end
    if lowest.buff(echo.id, player) then return end

    if (player.essence >= 2 or player.buff(essenceBurst.id)) then
        if spell:Cast(lowest) then
            return
        end
    end
end)

dreamBreath:Callback("stasis", function(spell)
    if project.stasisState ~= 3 then return end
    if project.cd(spell) > 0 then return end

    local function homies(unit)
        return friendCheck(unit)
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    if spell:Cast({ stopMoving = true }) then
        return
    end
end)

stasisRelease:Callback(function(spell)
    if project.stasisState ~= 4 then return end
    if spell.cd > 0 then return end

    local function homies(unit)
        return friendCheck(unit)
    end

    local lowest = awful.fgroup.within(spell.range).filter(homies).lowest
    if not lowest.friend then return end

    if (not lowest.buff(dreamBreathBuff.id) or player.buffRemains(stasisBuff.id) <= 5) then
        if not lowest.playerFacing45 then player.face(lowest) end
        if spell:Cast(lowest, { face = true }) then
            return
        end
    end
end)

