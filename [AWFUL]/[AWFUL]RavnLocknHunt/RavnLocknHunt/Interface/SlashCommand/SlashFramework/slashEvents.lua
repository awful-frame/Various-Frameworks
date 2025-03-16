local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____global = ravn["Global.global"]
local Global = ____global.Global
____exports.SlashEvent = __TS__Class()
local SlashEvent = ____exports.SlashEvent
SlashEvent.name = "SlashEvent"
function SlashEvent.prototype.____constructor(self, title, macroText, icon, ____type, main, cb, tooltip, extra)
    self.title = title
    self.type = ____type
    self.macroText = (("/" .. Global.baseCmd) .. " ") .. macroText
    self.tooltip = tooltip
    self.mainArg = main
    self.callback = cb or (function()
    end)
    self.icon = icon or 134400
    self.extra = extra
end
awful.Populate(
    {
        ["Interface.SlashCommand.SlashFramework.slashEvents"] = ____exports,
    },
    ravn,
    getfenv(1)
)
