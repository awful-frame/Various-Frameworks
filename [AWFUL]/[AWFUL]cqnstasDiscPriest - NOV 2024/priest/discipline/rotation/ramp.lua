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

        if friend.buffRemains("Atonement") < lowest_aton_remaining then
            best_aton_target = friend
            lowest_aton_remaining = friend.buffRemains("Atonement")
        end

        if friend.buffRemains("Atonement") == lowest_aton_remaining
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
    if type == "pvp" then
        return
    end

    if awful.instanceType2 ~= 'party' and awful.instanceType2 ~= 'raid' then
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

    if awful.player.buff("Voidheart") then
        return
    end

    if awful.player.buff("Rapture") then
        if project.util.friend.withPWS == project.util.friend.totalViable then
            return
        end
    else
        if project.util.friend.withBigAtonement == project.util.friend.totalViable then
            return
        end
    end

    if not project.util.enemy.bestTarget then
        return
    end

    if project.util.enemy.bestTarget
            and project.util.enemy.bestTarget.ttd < project.priest.discipline.rotation.ramp_time then
        return
    end

    for spell_name, bar_data in pairs(project.util.dbm_bars.active) do
        if bar_data.prio ~= 0 then
            return
        end

        local timer = bar_data.timer - awful.time

        if timer < project.priest.discipline.rotation.ramp_time / 2 then
            return
        end

        if timer - project.priest.discipline.rotation.ramp_time < 0 then
            awful.alert("AUTO RAMP FOR " .. spell_name, project.priest.spells.rapture.id)

            C_Timer.After(timer, function()
                disable_ramp()
            end)

            set_cd()
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

    if project.util.friend.withBigAtonement == project.util.friend.totalViable then
        disable_ramp()
        return
    end

    local best_aton_target = find_best_aton_target()

    if project.settings.priest_rampture and not awful.player.buff("Rapture") then
        return project.priest.spells.rapture("rampture", best_aton_target)
    end

    if awful.player.buff("Rapture") then
        return project.priest.spells.shield("ramp", best_aton_target)
    end

    return project.priest.spells.flashHeal("ramp", best_aton_target)
            or project.priest.spells.shield("ramp", best_aton_target)
            or project.priest.spells.renew("ramp", best_aton_target)
end


