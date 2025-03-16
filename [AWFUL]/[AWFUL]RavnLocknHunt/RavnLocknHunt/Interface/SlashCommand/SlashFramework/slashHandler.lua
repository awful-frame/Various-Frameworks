local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.SlashHandler = __TS__Class()
local SlashHandler = ____exports.SlashHandler
SlashHandler.name = "SlashHandler"
function SlashHandler.prototype.____constructor(self)
end
SlashHandler.classEvents = {}
SlashHandler.generalEvents = {}
SlashHandler.specEvents = {}
awful.Populate(
    {
        ["Interface.SlashCommand.SlashFramework.slashHandler"] = ____exports,
    },
    ravn,
    getfenv(1)
)
