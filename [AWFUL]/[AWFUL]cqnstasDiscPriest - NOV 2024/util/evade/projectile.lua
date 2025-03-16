local Unlocker, awful, project = ...

local projectilesToEvade = {
    -- fade/meld
    ["Convoke the Spirits"] = 1,
    ["Ray of Frost"] = 1,
    ["Void Torrent"] = 1,
    ["Killing Spree"] = 1,

    -- only fade
    ["Death Grip"] = 2,

    --only meld
    ["Mortal Coil"] = 3,
    ["The Hunt"] = 3,
    ["Storm Bolt"] = 3,
}

project.util.evade.projectile_cc_time = math.huge
project.util.evade.projectile_prio = 0
project.util.evade.holdGCD = false

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_SUCCESS" or event == "SPELL_CAST_START" then
        if not project.util.evade.should_evade() then
            return
        end

        if not source.enemy then
            return
        end

        local spellID, spellName = select(12, unpack(info))
        if dest.guid == awful.player.guid or (source.target and source.target.guid == awful.player.guid) then
            local prio = projectilesToEvade[spellName]

            if prio then
                if prio == 3
                        and not project.settings.general_evade_projectiles
                        and spellName ~= "The Hunt" then
                    return
                end

                if prio == 3
                        and project.util.spells.racials.shadowmeld.cd > awful.gcd then
                    return
                end

                if prio == 2
                        and project.priest.spells.fade.cd > awful.gcd then
                    return
                end

                if prio == 1
                        and project.priest.spells.fade.cd > awful.gcd
                        and project.util.spells.racials.shadowmeld.cd > awful.gcd then
                    return
                end

                if spellName == "Storm Bolt" then
                    if awful.player.stunDR <= 0.25 then
                        return
                    end
                end

                if spellName == "Death Grip" then
                    C_Timer.After(0.5, function()
                        project.util.evade.projectile_cc_time = awful.time
                        project.util.evade.projectile_prio = prio
                        project.util.evade.holdGCD = true
                    end)
                else
                    local threshold = (0.3 + (math.random() * 0.6))
                    project.util.evade.projectile_cc_time = awful.time + threshold
                    project.util.evade.projectile_prio = prio
                    project.util.evade.holdGCD = true
                end

                awful.call("SpellCancelQueuedSpell")
                awful.call("SpellStopCasting")

                C_Timer.After(1, function()
                    project.util.evade.projectile_cc_time = math.huge
                    project.util.evade.projectile_prio = 0
                    project.util.evade.holdGCD = false
                end)

                project.util.debug.alert.evade("Detected evade projectile: " .. spellName)
            end
        end
    end
end)

