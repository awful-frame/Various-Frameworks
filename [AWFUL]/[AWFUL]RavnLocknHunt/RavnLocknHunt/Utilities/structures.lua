local Unlocker, awful, ravn = ...
local ____exports = {}
____exports.MACRO_TYPE = MACRO_TYPE or ({})
____exports.MACRO_TYPE.ALL = 0
____exports.MACRO_TYPE[____exports.MACRO_TYPE.ALL] = "ALL"
____exports.MACRO_TYPE.ENEMIES = 1
____exports.MACRO_TYPE[____exports.MACRO_TYPE.ENEMIES] = "ENEMIES"
____exports.MACRO_TYPE.FRIENDS = 2
____exports.MACRO_TYPE[____exports.MACRO_TYPE.FRIENDS] = "FRIENDS"
____exports.MACRO_TYPE.SPECIAL = 3
____exports.MACRO_TYPE[____exports.MACRO_TYPE.SPECIAL] = "SPECIAL"
____exports.MACRO_TYPE.NONE = 4
____exports.MACRO_TYPE[____exports.MACRO_TYPE.NONE] = "NONE"
____exports.IInteruptState = IInteruptState or ({})
____exports.IInteruptState.NoKick = 0
____exports.IInteruptState[____exports.IInteruptState.NoKick] = "NoKick"
____exports.IInteruptState.Kick = 1
____exports.IInteruptState[____exports.IInteruptState.Kick] = "Kick"
____exports.IInteruptState.StopIfPossible = 2
____exports.IInteruptState[____exports.IInteruptState.StopIfPossible] = "StopIfPossible"
____exports.IInteruptState.Important = 3
____exports.IInteruptState[____exports.IInteruptState.Important] = "Important"
____exports.CREATURE_ID = CREATURE_ID or ({})
____exports.CREATURE_ID.VENOMOUS_SNAKE = 19833
____exports.CREATURE_ID[____exports.CREATURE_ID.VENOMOUS_SNAKE] = "VENOMOUS_SNAKE"
____exports.CREATURE_ID.VIPER = 19921
____exports.CREATURE_ID[____exports.CREATURE_ID.VIPER] = "VIPER"
____exports.CREATURE_ID.TREMOR = 1513
____exports.CREATURE_ID[____exports.CREATURE_ID.TREMOR] = "TREMOR"
____exports.INTERNAL_CD = INTERNAL_CD or ({})
____exports.INTERNAL_CD.VOLCANO = "VOLCANO"
____exports.INTERNAL_CD.SYNAPSE_SPRINGS = "SYNAPSE_SPRINGS"
____exports.INTERNAL_CD.ON_USE_S9_HONOR = "ON_USE_S9_HONOR"
____exports.INTERNAL_CD.LIGHTWEAVE = "LIGHTWEAVE"
____exports.INTERNAL_CD.THERALION_MIRROR_NM = "THERALION_MIRROR_NM"
____exports.INTERNAL_CD.POWER_TORRENT = "POWER_TORRENT"
____exports.INTERNAL_CD.BELL_OF_ENRAGING_RESONANCE = "BELL_OF_ENRAGING_RESONANCE"
ravn.hunter = {}
ravn.warlock = {}
awful.Populate(
    {
        ["Utilities.structures"] = ____exports,
    },
    ravn,
    getfenv(1)
)
