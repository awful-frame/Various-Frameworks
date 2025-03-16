local Unlocker, awful, ravn = ...
local ____exports = {}
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
---
-- @noSelf
function ____exports.ravnPrint(...)
    local color = "|cFFeb6e85"
    local before = (color .. "[Ravn]") .. Color.WHITE
    print(before, ...)
end
function ____exports.ravnInfo(...)
    if not awful.DevMode then
        return
    end
    local color = Color.LIME
    local before = (color .. "[INFO]") .. Color.WHITE
    print(before, ...)
end
awful.Populate(
    {
        ["Utilities.ravnPrint"] = ____exports,
    },
    ravn,
    getfenv(1)
)
