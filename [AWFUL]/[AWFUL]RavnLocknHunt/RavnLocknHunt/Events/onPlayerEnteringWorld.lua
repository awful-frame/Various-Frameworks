local Unlocker, awful, ravn = ...
local ____exports = {}
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____cache = ravn["Utilities.Cache.cache"]
local Cache = ____cache.Cache
local ____hunterLib = ravn["rotation.hunter.hunterLib"]
local HunterLib = ____hunterLib.HunterLib
local ____library = ravn["rotation.library"]
local Library = ____library.Library
local function onPlayerEnteringWorld()
    Global.queuedAOE = nil
    Global.queuedSpell = nil
    Global.pauseTimer = 0
    Cache:cleanAllCaches()
    HunterLib:detectPetTypes()
    wipe(Library.gearCache)
    ravn.fakeTracker:onPlayerEnteringWorld()
end
awful.addEventCallback(onPlayerEnteringWorld, "PLAYER_ENTERING_WORLD")
awful.Populate(
    {
        ["Events.onPlayerEnteringWorld"] = ____exports,
    },
    ravn,
    getfenv(1)
)
