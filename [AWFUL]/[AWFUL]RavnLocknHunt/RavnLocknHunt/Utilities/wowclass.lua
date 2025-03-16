local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
____exports.WowClass = __TS__Class()
local WowClass = ____exports.WowClass
WowClass.name = "WowClass"
function WowClass.prototype.____constructor(self)
end
WowClass.DEATHKNIGHT = "DEATHKNIGHT"
WowClass.DRUID = "DRUID"
WowClass.HUNTER = "HUNTER"
WowClass.MAGE = "MAGE"
WowClass.PALADIN = "PALADIN"
WowClass.PRIEST = "PRIEST"
WowClass.ROGUE = "ROGUE"
WowClass.SHAMAN = "SHAMAN"
WowClass.WARLOCK = "WARLOCK"
WowClass.WARRIOR = "WARRIOR"
WowClass.COLOR_CODE = {
    {wowClass = ____exports.WowClass.DEATHKNIGHT, color = Color.DEATH_KNIGHT},
    {wowClass = ____exports.WowClass.DRUID, color = Color.DRUID},
    {wowClass = ____exports.WowClass.HUNTER, color = Color.HUNTER},
    {wowClass = ____exports.WowClass.MAGE, color = Color.MAGE},
    {wowClass = ____exports.WowClass.PALADIN, color = Color.PALADIN},
    {wowClass = ____exports.WowClass.PRIEST, color = Color.PRIEST},
    {wowClass = ____exports.WowClass.ROGUE, color = Color.ROGUE},
    {wowClass = ____exports.WowClass.SHAMAN, color = Color.SHAMAN},
    {wowClass = ____exports.WowClass.WARLOCK, color = Color.WARLOCK},
    {wowClass = ____exports.WowClass.WARRIOR, color = Color.WARRIOR}
}
WowClass.MeleeClasses = {
    ____exports.WowClass.DEATHKNIGHT,
    ____exports.WowClass.DRUID,
    ____exports.WowClass.PALADIN,
    ____exports.WowClass.ROGUE,
    ____exports.WowClass.WARRIOR,
    ____exports.WowClass.SHAMAN
}
WowClass.RangeClasses = {
    ____exports.WowClass.DRUID,
    ____exports.WowClass.MAGE,
    ____exports.WowClass.PRIEST,
    ____exports.WowClass.WARLOCK,
    ____exports.WowClass.SHAMAN,
    ____exports.WowClass.HUNTER
}
awful.Populate(
    {
        ["Utilities.wowclass"] = ____exports,
    },
    ravn,
    getfenv(1)
)
