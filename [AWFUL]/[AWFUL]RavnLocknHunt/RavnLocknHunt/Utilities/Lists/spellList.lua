local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local SpellSchool = ____spellBook.SpellSchool
local WowClass = ____spellBook.WowClass
____exports.SpellList = __TS__Class()
local SpellList = ____exports.SpellList
SpellList.name = "SpellList"
function SpellList.prototype.____constructor(self)
end
SpellList.interrupts = {
    {id = 6552, spellType = "physical"},
    {id = 1766, spellType = "physical"},
    {id = 2139, spellType = "magic"},
    {id = 57994, spellType = "magic"},
    {id = 34490, spellType = "physical"},
    {id = SpellBook.PET_SPELL_LOCK, spellType = "magic"},
    {id = SpellBook.REBUKE, spellType = "physical"},
    {id = SpellBook.SKULL_BASH_CAT, spellType = "physical"},
    {id = SpellBook.SKULL_BASH_BEAR, spellType = "physical"}
}
SpellList.importantSchoolsDPS = {{specid = 64, school = SpellSchool.FROST}, {specid = 258, school = SpellSchool.SHADOW}, {specid = 70, school = SpellSchool.HOLY}, {specid = 65, school = SpellSchool.HOLY}}
SpellList.kickPve = {
    79710,
    77896,
    80734,
    78939,
    82752,
    91303,
    83070
}
SpellList.csCC = {
    118,
    228,
    28272,
    28271,
    61305,
    61025,
    61721,
    61780,
    51514,
    SpellBook.FEAR,
    SpellBook.BANISH,
    SpellBook.CYCLONE
}
SpellList.csDamage = {
    50796,
    SpellBook.UNSTABLE_AFFLICTION,
    SpellBook.EXORCISM,
    SpellBook.SCORCH,
    SpellBook.FROSTBOLT
}
SpellList.csHeal = {
    2050,
    331,
    34861,
    2060,
    5185,
    8004,
    596,
    32546,
    70772,
    70809,
    50464,
    8936,
    19750,
    635
}
SpellList.hexes = {
    51514,
    211015,
    210873,
    211010,
    211004,
    277784,
    277778,
    309328,
    269352
}
SpellList.ccSWD = {
    51514,
    211015,
    210873,
    211010,
    211004,
    277784,
    277778,
    309328,
    269352,
    118,
    28272,
    28271,
    391622,
    61305,
    61025,
    61721,
    61780,
    277787,
    5782,
    118699,
    20066
}
SpellList.csAlways = {
    SpellBook.REVIVE_PET,
    SpellBook.MASS_DISPEL,
    SpellBook.SUMMON_FELGUARD,
    SpellBook.SUMMON_FELHUNTER,
    SpellBook.MANA_BURN,
    688
}
SpellList.csChannel = {SpellBook.PENANCE, SpellBook.DRAIN_SOUL}
SpellList.hunterPetSpells = {SpellBook.PET_BAD_MANNER, SpellBook.PET_COWER, SpellBook.PET_GROWL, SpellBook.PET_PROWL}
SpellList.hunterPetInvokeSpells = {
    SpellBook.SUMMON_PET_1,
    SpellBook.SUMMON_PET_2,
    SpellBook.SUMMON_PET_3,
    SpellBook.SUMMON_PET_4,
    SpellBook.SUMMON_PET_5
}
SpellList.gapCloseIDs = {SpellBook.SHADOWSTEP, SpellBook.CHARGE}
SpellList.trinketIds = {}
SpellList.stealthIDs = {
    27617,
    26888,
    1857,
    1856,
    26889,
    5215,
    6783,
    9913,
    1784,
    58984
}
SpellList.importantDispelsEx = {
    {id = SpellBook.HAND_OF_PROTECTION, class = WowClass.PALADIN},
    {id = 79460, spec = {265}},
    {id = 79462, spec = {266}},
    {id = SpellBook.COMBUSTION, spec = {63}},
    {id = SpellBook.POWER_INFUSION, class = WowClass.PRIEST},
    {id = SpellBook.SPIRITWALKERS_GRACE, class = WowClass.SHAMAN},
    {id = 16166, spec = {262}},
    {id = 69369, spec = {103}}
}
SpellList.importantDispels = {
    1022,
    79460,
    79462,
    SpellBook.FEAR_WARD,
    SpellBook.COMBUSTION,
    10060,
    79206,
    16166,
    108839,
    2825,
    32182,
    196098,
    196098,
    212295,
    236696,
    198111,
    213610,
    108978,
    110909,
    378464,
    374227,
    342242,
    342246,
    328774,
    89485,
    69369
}
SpellList.mortalStrikDebuffs = {SpellBook.WIDOW_VENOM}
SpellList.weightDefensiveBuff = {{id = 100, weight = 50, wowclass = WowClass.HUNTER}}
SpellList.weightOffensiveBuff = {}
SpellList.burstIDs = {}
awful.Populate(
    {
        ["Utilities.Lists.spellList"] = ____exports,
    },
    ravn,
    getfenv(1)
)
