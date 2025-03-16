local Unlocker, awful, project = ...

project.util.cc.check_fear = function(target, mc, hold_gcd)
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

    local hold_gcd_extra = 0
    if hold_gcd then
        hold_gcd_extra = 1
    end

    local danger
    if target.friend then
        danger = project.util.friend.danger
    else
        danger = project.util.enemy.danger
    end

    if danger
            and target.disorientDR < 0.25
            and target.ddrRemains > 0 + hold_gcd_extra then
        return
    end

    if not danger
            and target.disorientDR < 0.5
            and target.ddrRemains > 0 + hold_gcd_extra then
        return
    end

    if not target.cc
            and target.disorientDR ~= 1
            and target.disorientDRRemains < 8 then
        return
    end

    if target.ccRemains > 0.5 + awful.buffer + hold_gcd_extra then
        return
    end

    if target.silenceRemains > 0.5 + awful.buffer + hold_gcd_extra then
        return
    end

    if target.debuffRemains(project.util.id.spell.SOLAR_BEAM) > awful.gcd + awful.buffer + hold_gcd_extra then
        return
    end

    if target.ccImmunityRemains > 0 + hold_gcd_extra then
        return
    end

    if target.magicEffectImmunityRemains > 0 + hold_gcd_extra then
        return
    end

    if not mc and target.class3 == project.util.id.class.WARRIOR then
        if target.cooldown(project.util.id.spell.BERSERKER_SHOUT) < 1 then
            return
        end
    end

    if target.class3 == project.util.id.class.PRIEST then
        if target.used(project.util.id.spell.SHADOW_WORD_DEATH, 1) then
            return
        end

        if target.buffRemains(project.util.id.spell.PHASE_SHIFT) > 0 + hold_gcd_extra then
            return
        end
    end

    if target.class3 == project.util.id.class.MAGE then
        if target.used(project.util.id.spell.BLINK, 1) then
            return
        end

        if target.used(project.util.id.spell.SHIMMER, 1) then
            return
        end
    end

    if target.class3 == project.util.id.class.ROGUE then
        if target.used(project.util.id.spell.SHADOWSTEP, 1) then
            return
        end
    end

    if target.buffRemains(project.util.id.spell.NULLIFYING_SHROUD) > 0 + hold_gcd_extra then
        return
    end

    if target.buffRemains(project.util.id.spell.BLESSING_OF_SANCTUARY) > 0 + hold_gcd_extra then
        return
    end

    local incoming_cc, incoming_cast, _ = project.util.check.target.incoming(target)
    if incoming_cc or incoming_cast then
        return
    end

    return true
end
