local Unlocker, awful, project = ...

project.priest.discipline.rotation.ramp_time = 0

local ramp_on_cd = false
local ramp_cd = 15

local function set_cd()
    ramp_on_cd = true
    C_Timer.After(ramp_cd, function()
        ramp_on_cd = false
    end)
end

local function find_best_aton_target()
    local best_aton_target
    local lowest_aton_remaining = 20

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        if friend.buffRemains(project.util.id.spell.ATONEMENT) < lowest_aton_remaining then
            best_aton_target = friend
            lowest_aton_remaining = friend.buffRemains(project.util.id.spell.ATONEMENT)
        end

        if friend.buffRemains(project.util.id.spell.ATONEMENT) == lowest_aton_remaining
                and friend.hp < best_aton_target.hp then
            best_aton_target = friend
        end
    end)

    if not best_aton_target then
        return
    end

    return best_aton_target
end

local function disable_ramp()
    project.settings.priest_rampture = false
    project.settings.priest_ramp = false

    awful.alert(awful.colors.red .. "RAMP MODE DISABLED", project.priest.spells.voidwraith.id)
end

local function ramp_time()
    project.priest.discipline.rotation.ramp_time = 7 * awful.gcd -- 5 * atonement + purge + voidwraith

    if project.settings.priest_ramp then
        return
    end

    if not project.settings.priest_ramp_time then
        return
    end

    awful.alert(awful.colors.red
            .. "ESTIMATED TIME TO RAMP UP: "
            .. string.format("%.1f", project.priest.discipline.rotation.ramp_time),
            project.priest.spells.rapture.id)
end

local function auto_ramp()
    if awful.instanceType2 ~= project.util.id.instance.PARTY
            and awful.instanceType2 ~= project.util.id.instance.RAID then
        return
    end

    if not project.settings.priest_auto_ramp then
        return
    end

    if project.settings.priest_ramp
            or project.settings.priest_rampture then
        return
    end

    if project.settings.priest_auto_ramp_only_rapture then
        if project.priest.spells.rapture.cd > 2 then
            return
        end
    end

    if ramp_on_cd then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition()
            and awful.player.buff(project.util.id.spell.VOIDHEART) then

        if awful.player.buffRemains(project.util.id.spell.VOIDHEART) > 3 then
            return
        end

        if project.util.friend.best_target.unit.hpa < 95 then
            return
        end
    end

    if awful.player.buff(project.util.id.spell.RAPTURE) then
        if project.util.friend.withBigPWS == project.util.friend.totalViable then
            return
        end
    else
        if project.util.friend.withBigAtonement == project.util.friend.totalViable then
            return
        end
    end

    if not project.util.enemy.best_target.unit then
        return
    end

    if project.util.enemy.best_target.unit
            and project.util.enemy.best_target.unit.ttd < project.priest.discipline.rotation.ramp_time then
        return
    end

    for bar_id, bar_data in pairs(project.util.dbm_bars.active) do
        if bar_data.prio ~= 0 then
            return
        end

        local timer = bar_data.timer - awful.time

        if timer < project.priest.discipline.rotation.ramp_time / 2 then
            return
        end

        if timer - project.priest.discipline.rotation.ramp_time < 0 then
            awful.alert("AUTO RAMP FOR " .. bar_data.spell_name, project.priest.spells.rapture.id)
            project.util.debug.alert.pve("AUTO RAMP FOR: " .. bar_data.spell_name, project.priest.spells.rapture.id)

            C_Timer.After(timer, function()
                disable_ramp()
            end)

            set_cd()

            if awful.player.castID == project.util.id.spell.RADIANCE
                    and awful.player.castPct < 50 then
                awful.call("SpellStopCasting")
            end

            if project.priest.spells.rapture.cd > awful.gcd then
                project.settings.priest_ramp = true
                return
            end

            project.settings.priest_ramp = true
            project.settings.priest_rampture = true
        end
    end
end

project.priest.discipline.rotation.ramp = function(type)
    ramp_time()
    auto_ramp()

    if not project.settings.priest_ramp
            and not project.settings.priest_rampture then
        return
    end

    if project.settings.priest_rampture then
        awful.alert(awful.colors.green .. "RAMPTURE MODE ENABLED", project.priest.spells.rapture.id)
    else
        awful.alert(awful.colors.green .. "RAMP MODE ENABLED", project.priest.spells.renew.id)
    end

    if awful.player.buff(project.util.id.spell.RAPTURE) or project.priest.spells.rapture.queued then
        if project.util.friend.withBigPWS == project.util.friend.totalViable then
            disable_ramp()
            return
        end
    else
        if project.util.friend.withBigAtonement == project.util.friend.totalViable then
            disable_ramp()
            return
        end
    end

    local best_aton_target = find_best_aton_target()

    if project.settings.priest_rampture and not awful.player.buff(project.util.id.spell.RAPTURE) then
        return project.priest.spells.rapture("rampture", best_aton_target)
    end

    if awful.player.buff(project.util.id.spell.RAPTURE) then
        return project.priest.spells.shield("ramp", best_aton_target)
    end

    return project.priest.spells.flashHeal("ramp", best_aton_target)
            or project.priest.spells.shield("ramp", best_aton_target)
            or project.priest.spells.renew("ramp", best_aton_target)
end


