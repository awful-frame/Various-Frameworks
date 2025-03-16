local Unlocker, awful, ravn = ...
local ____exports = {}
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local NewSpell = awful.NewSpell
____exports.autoShoot = NewSpell(SpellBook.AUTO_SHOT)
____exports.aspectOfTheHawk = NewSpell(SpellBook.ASPECT_OF_THE_HAWK, {ignoreGCD = true})
____exports.aspectOfTheWild = NewSpell(SpellBook.ASPECT_OF_THE_WILD, {ignoreGCD = true})
____exports.aspectOfTheFox = NewSpell(SpellBook.ASPECT_OF_THE_FOX, {ignoreGCD = true})
____exports.chimeraShot = NewSpell(SpellBook.CHIMERA_SHOT, {targeted = true, damage = "physical", ranged = true})
____exports.dismissPet = NewSpell(SpellBook.DISMISS_PET)
____exports.arcaneShot = NewSpell(SpellBook.ARCANE_SHOT, {targeted = true, damage = "magic", ranged = true})
____exports.multiShot = NewSpell(SpellBook.MULTISHOT, {targeted = true, damage = "physical", ranged = true})
____exports.steadyShot = NewSpell(SpellBook.STEADY_SHOT, {targeted = true, damage = "physical", ranged = true, ignoreMoving = true})
____exports.cobraShot = NewSpell(SpellBook.COBRA_SHOT, {targeted = true, damage = "physical", ranged = true, ignoreMoving = true})
____exports.mendPet = NewSpell(SpellBook.MEND_PET, {targeted = false})
____exports.revivePet = NewSpell(SpellBook.REVIVE_PET, {targeted = false})
____exports.scareBeast = NewSpell(SpellBook.SCARE_BEAST, {targeted = true, cc = "charm"})
____exports.scatterShot = NewSpell(SpellBook.SCATTER_SHOT, {
    targeted = true,
    ranged = true,
    effect = "physical",
    ignoreCasting = true,
    ignoreChanneling = true,
    cc = "polymorph"
})
____exports.concussiveShot = NewSpell(SpellBook.CONCUSSIVE_SHOT, {targeted = true, slow = true, ranged = true})
____exports.wingClip = NewSpell(SpellBook.WING_CLIP, {targeted = true, slow = true})
____exports.huntersMark = NewSpell(SpellBook.HUNTERS_MARK, {targeted = true, ranged = true, effect = "magic"})
____exports.explosiveShot = NewSpell(SpellBook.EXPLOSIVE_SHOT, {targeted = true, damage = "both", ranged = true})
____exports.blackArrow = NewSpell(SpellBook.BLACK_ARROW, {targeted = true, damage = "both", ranged = true})
____exports.misdirection = NewSpell(SpellBook.MISDIRECTION, {targeted = true, beneficial = true})
____exports.serpentSting = NewSpell(SpellBook.SERPENT_STING, {targeted = true, damage = "both", ranged = true})
____exports.disengage = NewSpell(781, {targeted = false, ignoreGCD = true})
____exports.camouflage = NewSpell(SpellBook.CAMOUFLAGE, {targeted = false, ignoreGCD = true})
____exports.raptorStrike = NewSpell(SpellBook.RAPTOR_STRIKE, {targeted = true, damage = "physical"})
____exports.howl = NewSpell(SpellBook.PET_GROWL, {targeted = true, pet = true})
____exports.killShot = NewSpell(SpellBook.KILL_SHOT, {targeted = true, damage = "physical", ranged = true})
____exports.callPet1 = NewSpell(SpellBook.SUMMON_PET_1, {targeted = false, castByID = true})
____exports.callPet2 = NewSpell(SpellBook.SUMMON_PET_2, {targeted = false, castByID = true})
____exports.callPet3 = NewSpell(SpellBook.SUMMON_PET_3, {targeted = false, castByID = true})
____exports.callPet4 = NewSpell(SpellBook.SUMMON_PET_4, {targeted = false, castByID = true})
____exports.callPet5 = NewSpell(SpellBook.SUMMON_PET_5, {targeted = false, castByID = true})
____exports.trapLauncher = NewSpell(SpellBook.TRAP_LAUNCHER, {targeted = false, ignoreGCD = true})
____exports.explosiveTrapNormal = NewSpell(SpellBook.EXPLOSIVE_TRAP)
____exports.explosiveTrapLaunched = NewSpell(SpellBook.EXPLOSIVE_TRAP_LAUNCHED, {radius = 3, damage = "magic", maxHit = 1})
____exports.aimedShot = NewSpell(SpellBook.AIMED_SHOT, {targeted = true, damage = "physical", ranged = true})
____exports.widowVenom = NewSpell(SpellBook.WIDOW_VENOM, {targeted = true, damage = "both", ranged = true})
____exports.badManner = NewSpell(SpellBook.PET_BAD_MANNER, {targeted = true, pet = true, ignoreMoving = true})
____exports.bullHeaded = NewSpell(SpellBook.PET_TRINKET, {targeted = false, pet = true, ignoreMoving = true, ignoreControl = true})
____exports.dash = NewSpell(SpellBook.PET_DASH, {targeted = false, pet = true})
____exports.callOfTheWild = NewSpell(SpellBook.PET_CALL_OF_THE_WILD, {targeted = false, ignoreGCD = true, pet = true})
____exports.roarOfCourage = NewSpell(SpellBook.PET_ROAR_OF_COURAGE, {targeted = false, ignoreGCD = true, pet = true})
____exports.freezingTrap = NewSpell(SpellBook.FREEZING_TRAP, {targeted = false, maxHit = 1, radius = 2, effect = "magic"})
awful.Populate(
    {
        ["rotation.hunter.hunterspells"] = ____exports,
    },
    ravn,
    getfenv(1)
)
