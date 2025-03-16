local Unlocker, awful, ravn = ...
local ____exports = {}
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
____exports.IStomps = {}
local IStomps = ____exports.IStomps
do
    IStomps.HEALING_STREAM = {spellId = SpellBook.HEALING_STREAM_TOTEM, objectId = 3527, important = true, fragile = true}
    IStomps.SLT = {spellId = SpellBook.SPIRIT_LINK_TOTEM, objectId = 53006, important = true, fragile = true}
    IStomps.MANA_TIDE = {spellId = 16190, objectId = 10467, important = true, fragile = false}
    IStomps.TREMOR = {spellId = SpellBook.TREMOR_TOTEM, objectId = 5913, important = false, fragile = true}
    IStomps.STRENGTH_OF_EARTH_TOTEM = {spellId = 8075, objectId = 5874, important = true, fragile = true}
    IStomps.FLAMETONGUE = {spellId = 8227, objectId = 15485, important = true, fragile = true}
    IStomps.WRATH_OF_AIR = {spellId = 3738, objectId = 15447, important = false, fragile = true}
    IStomps.WINDFURY = {spellId = 8512, objectId = 6112, important = false, fragile = true}
    IStomps.SEARING = {spellId = 3599, objectId = 15480, important = true, fragile = true}
    IStomps.GROUND = {spellId = 8177, objectId = 5925, important = false, fragile = true}
    IStomps.EARTHBIND = {spellId = 2484, objectId = 2630, important = true, fragile = true}
    IStomps.totemList = {
        IStomps.HEALING_STREAM,
        IStomps.SLT,
        IStomps.MANA_TIDE,
        IStomps.TREMOR,
        IStomps.STRENGTH_OF_EARTH_TOTEM,
        IStomps.FLAMETONGUE,
        IStomps.WRATH_OF_AIR,
        IStomps.GROUND,
        IStomps.WINDFURY,
        IStomps.EARTHBIND,
        IStomps.SEARING
    }
end
awful.Populate(
    {
        ["Utilities.Stomp.stompList"] = ____exports,
    },
    ravn,
    getfenv(1)
)
