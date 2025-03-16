local Unlocker, awful, ravn = ...
local ____exports = {}
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local NewSpell = awful.NewSpell
____exports.felArmor = NewSpell(SpellBook.FEL_ARMOR)
____exports.demonArmor = NewSpell(SpellBook.DEMON_ARMOR)
____exports.incinerate = NewSpell(SpellBook.INCINERATE, {targeted = true, damage = "magic"})
____exports.summonFelguard = NewSpell(SpellBook.SUMMON_FELGUARD)
____exports.summonFelhunter = NewSpell(SpellBook.SUMMON_FELHUNTER)
____exports.felStorm = NewSpell(SpellBook.PET_FELSTORM, {pet = true})
____exports.axeToss = NewSpell(SpellBook.PET_AXE_TOSS, {pet = true, targeted = true, damage = "physical", cc = "stun"})
____exports.metamorphosis = NewSpell(SpellBook.METAMORPHOSIS)
____exports.summonDoomguard = NewSpell(SpellBook.SUMMON_DOOMGUARD)
____exports.summonInfernal = NewSpell(SpellBook.SUMMON_INFERNAL)
____exports.shadowBolt = NewSpell(SpellBook.SHADOW_BOLT, {targeted = true, damage = "magic", ranged = true})
____exports.lifeTap = NewSpell(SpellBook.LIFE_TAP, {targeted = false})
____exports.handOfGuldan = NewSpell(SpellBook.HAND_OF_GULDAN, {targeted = true, damage = "magic"})
____exports.soulFire = NewSpell(SpellBook.SOULFIRE, {targeted = true, damage = "magic"})
____exports.soulHarvest = NewSpell(SpellBook.SOUL_HARVEST, {targeted = false})
____exports.curseOfTheElements = NewSpell(SpellBook.CURSE_OF_THE_ELEMENTS, {targeted = true, effect = "magic"})
____exports.baneOfDoom = NewSpell(SpellBook.BANE_OF_DOOM, {targeted = true, damage = "magic"})
____exports.curseOfWeakness = NewSpell(SpellBook.CURSE_OF_WEAKNESS, {targeted = true, effect = "magic"})
____exports.curseOfTongues = NewSpell(SpellBook.CURSE_OF_TONGUES, {targeted = true, effect = "magic"})
____exports.darkIntent = NewSpell(SpellBook.DARK_INTENT, {targeted = true, effect = "magic", beneficial = true})
____exports.shadowflame = NewSpell(SpellBook.SHADOWFLAME, {damage = "magic"})
____exports.felFlame = NewSpell(SpellBook.FEL_FLAME, {damage = "magic", targeted = true})
____exports.shadowWard = NewSpell(SpellBook.SHADOW_WARD, {targeted = false})
____exports.soulBurn = NewSpell(SpellBook.SOULBURN, {targeted = false, ignoreGCD = true})
____exports.immolate = NewSpell(SpellBook.IMMOLATE, {targeted = true, damage = "magic"})
____exports.corruption = NewSpell(SpellBook.CORRUPTION, {targeted = true, damage = "magic", ignoreFacing = true})
____exports.hellfire = NewSpell(SpellBook.HELLFIRE, {targeted = false, damage = "magic", ignoreMoving = true, stupidChannel = true})
____exports.soulLink = NewSpell(SpellBook.SOUL_LINK, {targeted = false})
____exports.hellFire = NewSpell(SpellBook.HELLFIRE, {targeted = false, damage = "magic"})
____exports.demonSoul = NewSpell(SpellBook.DEMON_SOUL, {targeted = false, ignoreGCD = true})
____exports.demonLeap = NewSpell(SpellBook.DEMON_LEAP, {targeted = true})
____exports.immolationAura = NewSpell(SpellBook.IMMOLATION_AURA, {targeted = false})
____exports.soulshatter = NewSpell(SpellBook.SOULSHATTER, {targeted = false})
____exports.baneOfAgony = NewSpell(SpellBook.BANE_OF_AGONY, {targeted = true, damage = "magic", ignoreFacing = true})
____exports.drainSoul = NewSpell(SpellBook.DRAIN_SOUL, {targeted = true, damage = "magic"})
____exports.drainSoulWeak = NewSpell(SpellBook.DRAIN_SOUL, {targeted = true, damage = "magic", stupidChannel = true})
____exports.drainLifeWeak = NewSpell(SpellBook.DRAIN_LIFE, {targeted = true, damage = "magic", stupidChannel = true})
____exports.sprintPet = NewSpell(SpellBook.PET_PURSUIT, {targeted = true, pet = true})
____exports.unstableAffliction = NewSpell(SpellBook.UNSTABLE_AFFLICTION, {targeted = true, damage = "magic"})
____exports.fear = NewSpell(SpellBook.FEAR, {
    targeted = true,
    ranged = true,
    cc = "charm",
    effect = "magic",
    ignoreFacing = true
})
____exports.demonicCircleTeleport = NewSpell(SpellBook.DEMONIC_CIRCLE_TELEPORT, {targeted = false, ignoreCasting = true, castByID = true})
____exports.demonicCircleSummon = NewSpell(SpellBook.DEMONIC_CIRCLE_SUMMON, {targeted = false})
____exports.deathlCoil = NewSpell(SpellBook.DEATH_COIL, {targeted = true, ranged = true, effect = "magic", cc = "horror"})
____exports.howlOfTerror = NewSpell(SpellBook.HOWL_OF_TERROR, {targeted = false, cc = "charm", effect = "magic"})
____exports.shadowBite = NewSpell(SpellBook.PET_SHADOW_BITE, {targeted = true, pet = true, damage = "magic"})
____exports.spellLock = NewSpell(SpellBook.PET_SPELL_LOCK, {targeted = true, pet = true, interrupt = true, ignoreGCD = true})
____exports.curseofExhaustion = NewSpell(SpellBook.CURSE_OF_EXHAUSTION, {targeted = true, effect = "magic"})
____exports.soulSwap = NewSpell(SpellBook.SOUL_SWAP, {targeted = true, ignoreGCD = true, castByID = true, damage = "magic"})
____exports.haunt = NewSpell(SpellBook.HAUNT, {targeted = true, damage = "magic"})
____exports.healthFunnel = NewSpell(SpellBook.HEALTH_FUNNEL, {beneficial = true, targeted = true})
____exports.devourMagic = NewSpell(SpellBook.PET_DEVOUR_MAGIC, {targeted = true, pet = true})
____exports.createHS = NewSpell(SpellBook.CREATE_HEALTHSTONE, {})
____exports.ritualOfSouls = NewSpell(SpellBook.RITUAL_OF_SOULS, {targeted = false})
____exports.drainLife = NewSpell(SpellBook.DRAIN_LIFE, {targeted = true, damage = "magic"})
____exports.banish = NewSpell(SpellBook.BANISH, {targeted = true, effect = "magic"})
____exports.singeMagic = NewSpell(SpellBook.PET_SINGE_MAGIC, {
    targeted = true,
    effect = "magic",
    beneficial = true,
    pet = true,
    ignoreControl = true
})
____exports.fleeImp = NewSpell(SpellBook.PET_FLEE, {pet = true})
____exports.whiplash = NewSpell(SpellBook.PET_WHIPLASH, {radius = 5, pet = true, damage = "physical"})
awful.Populate(
    {
        ["rotation.lock.lockspells"] = ____exports,
    },
    ravn,
    getfenv(1)
)
