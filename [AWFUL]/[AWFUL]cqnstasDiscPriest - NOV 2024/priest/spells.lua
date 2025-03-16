local Unlocker, awful, project = ...

local Spell = awful.Spell
awful.Populate({
    --dps
    mindBlast = Spell(8092, { damage = "magic", ignoreMoving = true }),
    purgeTheWicked = Spell(204197, { damage = "magic", ignoreFacing = true }),
    smite = Spell(585, { damage = "magic", ignoreMoving = true }),
    voidBlast = Spell(450215, { damage = "magic" }),
    death = Spell(32379, { damage = "magic", ignoreFacing = true, ignoreCasting = true, ignoreChanneling = true }),

    --dps cds
    powerInfusion = Spell(10060, { beneficial = true }),
    shadowfiend = Spell(34433, { damage = "magic", ignoreFacing = true }),
    voidwraith = Spell(451235, { damage = "magic", ignoreFacing = true }),
    voidTendrils = Spell(108920, { effect = "magic", targeted = false }),
    mindgames = Spell(375901, { damage = "magic" }),

    --heal
    penance = Spell(47540, { heal = true, damage = "magic", ignoreMoving = true }),
    darkReprimand = Spell(400169, { heal = true, damage = "magic", ignoreMoving = true }),
    radiance = Spell(194509, { heal = true, targeted = "false" }),
    shield = Spell(17, { heal = true }),
    renew = Spell(139, { heal = true }),
    flashHeal = Spell(2061, { heal = true, ignoreMoving = true }), -- stopMoving
    life = Spell(373481, { heal = true }),

    --heal cds
    premonition = Spell(428942, { targeted = false }),
    premonitionOfClairvoyance = Spell(440725, { targeted = false }),
    premonitionOfInsight = Spell(428933, { targeted = false }),
    premonitionOfPiety = Spell(428930, { targeted = false }),
    premonitionOfSolace = Spell(428934, { targeted = false }),
    painSuppression = Spell(33206, { beneficial = true, ignoreStuns = true }),
    ultimatePenitence = Spell(421453, { damage = "magic", ignoreMoving = true }), -- stopMoving
    rapture = Spell(47536, { beneficial = true }),
    powerWordBarrier = Spell(62618, { targeted = false, beneficial = true, radius = 8 }),
    voidShift = Spell(108968, { beneficial = true, ignoreCasting = true, ignoreChanneling = true }),

    --defensives
    desperatePrayer = Spell(19236, { heal = true }),

    --utility
    fade = Spell(586, { targeted = false, ignoreCasting = true, ignoreChanneling = true }),
    purify = Spell(527, { beneficial = true }),
    dispelMagic = Spell(528, { effect = "magic" }),
    leapOfFaith = Spell(73325, { beneficial = true }),
    massDispel = Spell(32375, { radius = 15, ignoreMoving = true }), --stopMoving
    angelicFeather = Spell(121536, { beneficial = true, radius = 2 }),
    inner_light_and_shadow = Spell(355897, { targeted = false, beneficial = true }),

    --cc
    psychicScream = Spell(8122, { cc = "fear" }),
    mindControl = Spell(605, { cc = "fear" }),

    --pvp
    darkArchangel = Spell(197871, { targeted = false, beneficial = true }),
    archangel = Spell(197862, { targeted = false, beneficial = true }),

    --buffs
    powerWordFortitude = Spell(21562, { targeted = false, beneficial = true }),
}, project.priest.spells, getfenv(1))



