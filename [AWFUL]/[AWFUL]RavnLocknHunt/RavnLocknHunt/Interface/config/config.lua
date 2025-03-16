local Unlocker, awful, ravn = ...
local ____exports = {}
local config = awful.NewConfig("Ravn_CLASSIC_Config")
ravn.config = config
function ____exports.saveConfig()
end
awful.Populate(
    {
        ["Interface.config.config"] = ____exports,
    },
    ravn,
    getfenv(1)
)
