local Unlocker, awful, ravn = ...
local ____exports = {}
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local NewSpell = awful.NewSpell
____exports.kick = NewSpell(SpellBook.KICK, {
    targeted = true,
    ignoreGCD = true,
    interrupt = true,
    ignoreCasting = true,
    effect = "physical"
})
____exports.pummel = NewSpell(SpellBook.PUMMEL, {
    targeted = true,
    ignoreGCD = true,
    ignoreCasting = true,
    interrupt = true,
    effect = "physical"
})
____exports.silencingShot = NewSpell(SpellBook.SILENCING_SHOT, {
    targeted = true,
    ignoreGCD = true,
    interrupt = true,
    ignoreCasting = true,
    effect = "physical"
})
____exports.survey = NewSpell(80451, {targeted = false})
____exports.aspecOfTheCheetah = NewSpell(SpellBook.ASPECT_OF_THE_CHEETAH, {targeted = false, ignoreGCD = true})
____exports.awfulSpellInterrupts = {____exports.kick, ____exports.pummel, ____exports.silencingShot}
____exports.volcanicPot = awful.NewItem(58091)
____exports.healthStone = awful.NewItem(5512)
____exports.soulCasket = awful.NewItem(58183)
____exports.freeYourMind = awful.NewSpell(79323)
____exports.stolenPower = awful.NewSpell(80627)
awful.Populate(
    {
        ["Utilities.Lists.awfulSpells"] = ____exports,
    },
    ravn,
    getfenv(1)
)
