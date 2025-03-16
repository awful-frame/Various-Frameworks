local Unlocker, awful, ravn = ...
local ____exports = {}
local ____InternalCooldowns = ravn["Utilities.InternalCooldowns.InternalCooldowns"]
local InternalCooldowns = ____InternalCooldowns.InternalCooldowns
local ____library = ravn["rotation.library"]
local Library = ____library.Library
local function onPlayerEquipmentChanged()
    wipe(Library.gearCache)
    InternalCooldowns:populate()
end
awful.addEventCallback(onPlayerEquipmentChanged, "PLAYER_EQUIPMENT_CHANGED")
awful.Populate(
    {
        ["Events.onPlayerEquipmentChanged"] = ____exports,
    },
    ravn,
    getfenv(1)
)
