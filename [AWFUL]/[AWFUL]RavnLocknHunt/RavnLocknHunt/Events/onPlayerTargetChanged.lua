local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local ____exports = {}
local ____localPlayer = ravn["LocalPlayer.localPlayer"]
local LP = ____localPlayer.LP
local ____arena = ravn["arena.arena"]
local arena = ____arena.arena
local function getUnitId(u)
    local guid = u.guid
    if guid == awful.call("UnitGUID", "arena1") then
        return "arena1"
    end
    if guid == awful.call("UnitGUID", "arena2") then
        return "arena2"
    end
    if guid == awful.call("UnitGUID", "arena3") then
        return "arena3"
    end
    if guid == awful.call("UnitGUID", "arena4") then
        return "arena4"
    end
    if guid == awful.call("UnitGUID", "arena5") then
        return "arena5"
    end
    return nil
end
function ____exports.autoFocus()
    if not awful.arena then
        return
    end
    if arena:inPrep() then
        return
    end
    if not ravn.modernConfig:getMiscAutoFocus() then
        return
    end
    local bracket = GetNumArenaOpponents()
    if bracket == 2 then
        if awful.call("UnitIsUnit", "arena2", "target") and not awful.call("UnitIsUnit", "arena1", "focus") and UnitIsVisible("arena1") then
            awful.call("FocusUnit", "arena1")
        end
        if awful.call("UnitIsUnit", "arena1", "target") and not awful.call("UnitIsUnit", "arena2", "focus") and UnitIsVisible("arena2") then
            awful.call("FocusUnit", "arena2")
        end
    elseif bracket == 3 then
        local focusFrameVisible = awful.focus.exists
        local TH = awful.enemyHealer
        if not TH or not TH.exists then
            return
        end
        local unitId = getUnitId(TH)
        if not unitId then
            return
        end
        if not focusFrameVisible and TH and TH.visible then
            awful.call("FocusUnit", unitId)
        elseif TH and awful.call("UnitIsUnit", unitId, "target") then
            if not focusFrameVisible then
                local bursty = __TS__ArrayFind(
                    awful.enemies,
                    function(____, o) return o.visible end
                )
                if not bursty then
                    __TS__ArrayFind(
                        awful.enemies,
                        function(____, o) return o.isPlayer and not o.dead end
                    )
                end
                if bursty then
                    local bID = getUnitId(bursty)
                    if bID then
                        awful.call("FocusUnit", bID)
                    end
                end
            end
        end
    elseif bracket == 5 then
        if awful.target.exists then
            if awful.target.isHealer then
                local other = __TS__ArrayFind(
                    awful.enemies,
                    function(____, o) return o.isPlayer and not o.isUnit(awful.target) and o.isHealer end
                )
                if other and other.exists then
                    awful.call(
                        "FocusUnit",
                        getUnitId(other)
                    )
                end
            else
                local other = __TS__ArrayFind(
                    awful.enemies,
                    function(____, o) return o.isPlayer and not o.isUnit(awful.target) and not o.isHealer end
                )
                if other and other.exists then
                    awful.call(
                        "FocusUnit",
                        getUnitId(other)
                    )
                end
            end
        end
    end
end
local function onPlayerTargetChanged()
    if awful.target.exists then
        if not LP.previousTargetGuid then
            LP.previousTargetGuid = awful.target.guid
        else
            LP.previousTargetGuid = LP.currentTargetGuid
        end
        LP.currentTargetGuid = awful.target.guid
    end
    if LP.isTargettingTotem == true then
        local previous = awful.GetObjectWithGUID(LP.previousTargetTotemGuid)
        if previous and previous.exists and previous.visible then
            previous.setTarget()
            LP.previousTargetTotemGuid = nil
        end
        LP.isTargettingTotem = false
    end
    ____exports.autoFocus()
end
awful.addEventCallback(onPlayerTargetChanged, "PLAYER_TARGET_CHANGED")
awful.Populate(
    {
        ["Events.onPlayerTargetChanged"] = ____exports,
    },
    ravn,
    getfenv(1)
)
