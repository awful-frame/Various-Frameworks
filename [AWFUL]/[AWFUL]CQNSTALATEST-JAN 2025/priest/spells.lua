local Unlocker, awful, project = ...

awful.Populate({
    --dps
    mindBlast = awful.Spell(project.util.id.spell.MIND_BLAST, { damage = "magic", ignoreMoving = true }),
    purgeTheWicked = awful.Spell(project.util.id.spell.PURGE_THE_WICKED, { damage = "magic", ignoreFacing = true }),
    smite = awful.Spell(project.util.id.spell.SMITE, { damage = "magic", ignoreMoving = true }),
    voidBlast = awful.Spell(project.util.id.spell.VOID_BLAST, { damage = "magic" }),
    death = awful.Spell(project.util.id.spell.SHADOW_WORD_DEATH, { damage = "magic", ignoreFacing = true, ignoreCasting = true, ignoreChanneling = true }),

    --dps cds
    powerInfusion = awful.Spell(project.util.id.spell.POWER_INFUSION, { beneficial = true }),
    shadowfiend = awful.Spell(project.util.id.spell.SHADOWFIEND, { damage = "magic", ignoreFacing = true }),
    voidwraith = awful.Spell(project.util.id.spell.VOIDWRAITH, { damage = "magic", ignoreFacing = true }),
    voidTendrils = awful.Spell(project.util.id.spell.VOID_TENDRILS, { effect = "magic", targeted = false }),
    mindgames = awful.Spell(project.util.id.spell.MINDGAMES, { damage = "magic" }),

    --heal
    penance = awful.Spell(project.util.id.spell.PENANCE, { heal = true, damage = "magic", castableWhileMoving = true, ignoreMoving = true, ignoreFacing = true }),
    radiance = awful.Spell(project.util.id.spell.RADIANCE, { heal = true, targeted = "false" }),
    halo = awful.Spell(project.util.id.spell.HALO, { heal = true, targeted = "false" }),
    shield = awful.Spell(project.util.id.spell.POWER_WORD_SHIELD, { heal = true }),
    renew = awful.Spell(project.util.id.spell.RENEW, { heal = true }),
    flashHeal = awful.Spell(project.util.id.spell.FLASH_HEAL, { heal = true, ignoreMoving = true }), -- stopMoving
    life = awful.Spell(project.util.id.spell.POWER_WORD_LIFE, { heal = true }),

    --heal cds
    premonition = awful.Spell(project.util.id.spell.PREMONITION, { targeted = false }),
    premonitionOfClairvoyance = awful.Spell(project.util.id.spell.PREMONITION_OF_CLAIRVOYANCE, { targeted = false }),
    premonitionOfInsight = awful.Spell(project.util.id.spell.PREMONITION_OF_INSIGHT, { targeted = false }),
    premonitionOfPiety = awful.Spell(project.util.id.spell.PREMONITION_OF_PIETY, { targeted = false }),
    premonitionOfSolace = awful.Spell(project.util.id.spell.PREMONITION_OF_SOLACE, { targeted = false }),
    painSuppression = awful.Spell(project.util.id.spell.PAIN_SUPPRESSION, { beneficial = true, ignoreStuns = true }),
    ultimatePenitence = awful.Spell(project.util.id.spell.ULTIMATE_PENITENCE, { damage = "magic", ignoreMoving = true }), -- stopMoving
    rapture = awful.Spell(project.util.id.spell.RAPTURE, { beneficial = true }),
    powerWordBarrier = awful.Spell(project.util.id.spell.POWER_WORD_BARRIER, { targeted = false, beneficial = true, radius = 8 }),
    voidShift = awful.Spell(project.util.id.spell.VOID_SHIFT, { beneficial = true, ignoreCasting = true, ignoreChanneling = true, ignoreControl = true }),

    --defensives
    desperatePrayer = awful.Spell(project.util.id.spell.DESPERATE_PRAYER, { heal = true }),

    --utility
    fade = awful.Spell(project.util.id.spell.FADE, { targeted = false, ignoreCasting = true, ignoreChanneling = true }),
    purify = awful.Spell(project.util.id.spell.PURIFY, { beneficial = true }),
    dispelMagic = awful.Spell(project.util.id.spell.DISPEL_MAGIC, { effect = "magic" }),
    leapOfFaith = awful.Spell(project.util.id.spell.LEAP_OF_FAITH, { beneficial = true }),
    massDispel = awful.Spell(project.util.id.spell.MASS_DISPEL, { radius = 15, ignoreMoving = true }), -- stopMoving
    angelicFeather = awful.Spell(project.util.id.spell.ANGELIC_FEATHER, { beneficial = true, radius = 2 }),
    inner_light_and_shadow = awful.Spell(project.util.id.spell.INNER_LIGHT_AND_SHADOW, { targeted = false, beneficial = true }),

    --cc
    psychicScream = awful.Spell(project.util.id.spell.PSYCHIC_SCREAM, { cc = "fear" }),
    mindControl = awful.Spell(project.util.id.spell.MIND_CONTROL, { cc = "fear" }),

    --pvp
    darkArchangel = awful.Spell(project.util.id.spell.DARK_ARCHANGEL, { targeted = false, beneficial = true }),
    archangel = awful.Spell(project.util.id.spell.ARCHANGEL, { targeted = false, beneficial = true }),

    --buffs
    powerWordFortitude = awful.Spell(project.util.id.spell.POWER_WORD_FORTITUDE, { targeted = false, beneficial = true }),
}, project.priest.spells, getfenv(1))
