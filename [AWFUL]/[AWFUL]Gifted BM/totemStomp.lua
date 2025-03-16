local Unlocker, awful, gifted = ...

local player = awful.player
local SpellStopCasting = awful.unlock("SpellStopCasting")

local totemList = {
    5925, -- Grounding
    53006, -- Spirit link
    105451, -- Counterstrike
    179867, -- Static Field
    119052, -- War Banner
    5913, -- tremor totem
    60561, -- earthgrab totem
    105427, -- skyfury totem
    101398, -- Psyfiend
    107100, -- observer
    179193, -- fel obelisk
    61245, -- capacitor totem  --192058
    59764, -- healing tide totem
}
gifted.totemStomp = function(bigSpell, smallSpell)
    if not player.combat then return end
    awful.units.loop(function(unit, uptime)
        if unit.friendly then return end
        if unit.uptime < gifted.quickdelay.now then return end
        if not unit.los then return end

        -- Totems (No HP Check)--
        for key, value in ipairs(totemList) do
            if unit.id == value then
                if smallSpell:Castable(unit) and not gifted.WasCasting[smallSpell.id] then
                    if awful.pet.losOf(unit) and awful.pet.distanceTo(unit) <= 15 then
                        if gifted.killCommand.charges >= 1 then
                            if awful.player.focus >= 30 then
                                gifted.spellAlert(smallSpell.name, " - Stomping Totem!")
                                return smallSpell:Cast(unit)
                            end
                        end
                    else
                        if bigSpell:Castable(unit) and not gifted.WasCasting[bigSpell.id] then
                            if gifted.killCommand.charges < 1 then
                                if awful.player.focus >= 35 then
                                    SpellStopCasting()
                                    SpellStopCasting()
                                    gifted.spellAlert(bigSpell, " - Stomping Totem!")
                                    return bigSpell:Cast(unit)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end