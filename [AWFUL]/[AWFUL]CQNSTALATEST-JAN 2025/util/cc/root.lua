local Unlocker, awful, project = ...

project.util.cc.check_root = function(target)
    if not target then
        return
    end

    if not target.player then
        if target.level > awful.player.level or target.level == -1 then
            return
        end

        if project.util.check.scenario.type() == "pvp" then
            return
        end
    end

    if target.speed > 15 then
        return
    end

    if target.dead then
        return
    end

    if not target.inCombat then
        return
    end

    if not target.los then
        return
    end

    if target.ccRemains > 0.5 + awful.buffer then
        return
    end

    if target.silenceRemains > 0.5 + awful.buffer then
        return
    end

    if target.debuffRemains(project.util.id.spell.SOLAR_BEAM) > 0.5 + awful.buffer then
        return
    end

    if target.ccImmunityRemains > 0 then
        return
    end

    if target.magicEffectImmunityRemains > 0 then
        return
    end

    if target.buffRemains(project.util.id.spell.PHASE_SHIFT) > 0 then
        return
    end

    local incoming_cc, _, _ = project.util.check.target.incoming(target)
    if incoming_cc then
        return
    end

    if target.buffRemains(project.util.id.spell.BLESSING_OF_FREEDOM) > 0 then
        return
    end

    if target.buffRemains(project.util.id.spell.MASTERS_CALL_BUFF) > 0 then
        return
    end

    if target.rooted then
        return
    end

    return true
end
