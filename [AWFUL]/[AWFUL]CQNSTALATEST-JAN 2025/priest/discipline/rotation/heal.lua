local Unlocker, awful, project = ...

local function find_best_aton_target_pve()
    local best_aton_target

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        if friend.buffRemains(project.util.id.spell.ATONEMENT) < project.util.thresholds.buff() then
            if best_aton_target and best_aton_target.role == "tank" then
                return
            end

            if friend.role == "tank" then
                best_aton_target = friend
            end

            if best_aton_target
                    and best_aton_target.hp > friend.hp then
                best_aton_target = friend
                return
            end

            if not best_aton_target then
                best_aton_target = friend
                return
            end
        end
    end)

    if not best_aton_target then
        return
    end

    if not best_aton_target.inCombat then
        return
    end

    if best_aton_target.hp > 90 then
        return
    end

    return best_aton_target
end

local function find_best_aton_target_pvp()
    local best_aton_target
    local max_attackers = 0
    local max_cds = 0

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        local attackers = project.util.check.target.attackers(friend)

        if friend.buffRemains(project.util.id.spell.ATONEMENT) < project.util.thresholds.buff() then
            if best_aton_target and max_cds < attackers.cdp then
                best_aton_target = friend
                max_attackers = attackers.total
                max_cds = attackers.cdp
                return
            end

            if best_aton_target and max_attackers < attackers.total then
                best_aton_target = friend
                max_attackers = attackers.total
                return
            end

            if best_aton_target
                    and max_attackers == attackers.total
                    and max_cds == attackers.cdp
                    and best_aton_target.hp > friend.hp then
                best_aton_target = friend
                return
            end

            if not best_aton_target then
                best_aton_target = friend
                max_attackers = attackers.total
                max_cds = attackers.cdp
                return
            end
        end
    end)

    if project.util.friend.withAtonement > 0
            and project.util.friend.total > 3
            and best_aton_target
            and best_aton_target.hp > 90 then
        return
    end

    return best_aton_target
end

local function find_best_aton_target(type)
    if type == "pvp" then
        return find_best_aton_target_pvp()
    end
    return find_best_aton_target_pve()
end

local function should_heal()
    if awful.player.buff(project.util.id.spell.ARENA_PREPARATION) then
        return
    end

    if awful.player.buff(project.util.id.spell.PREPARATION) then
        return
    end

    if project.util.cast.block.spell == project.util.id.spell.RADIANCE then
        return
    end

    if project.util.cast.block.spell == project.util.id.spell.FLASH_HEAL then
        if awful.player.castTarget.immuneHealing then
            awful.call("SpellStopCasting")
        end

        return
    end

    if project.util.cast.block.spell == project.util.id.spell.MIND_BLAST then
        return
    end

    return true
end

project.priest.discipline.rotation.heal = function(type)
    if not should_heal() then
        return
    end
    project.priest.spells.shield(type)

    if IsPlayerSpell(project.util.id.spell.POWER_WORD_LIFE) then
        project.priest.spells.life("default")
    end

    local best_penance_target = project.priest.discipline.rotation.util.find_best_target_to_ptw_penance_spread(type)
    if not project.util.check.enemy.interrupt()
            and type == "pvp"
            and project.priest.discipline.rotation.util.is_premonition() then
        project.priest.spells.radiance(type)
        project.priest.spells.penance("from_heal")
        project.priest.spells.penance("from_attack", best_penance_target)
        project.priest.spells.flashHeal(type)
    else
        if type == "pvp"
                or project.util.friend.total <= 5
                or project.util.friend.best_target.unit.hp < 20 then
            project.priest.spells.flashHeal(type)
        end
        project.priest.spells.radiance(type)
        project.priest.spells.penance("from_heal")
        if type == "pvp"
                and project.priest.discipline.rotation.util.is_premonition() then
            project.priest.spells.penance("from_attack", best_penance_target)
        end

    end

    if IsPlayerSpell(project.util.id.spell.HALO) then
        project.priest.spells.halo(type)
    end

    local best_aton_target = find_best_aton_target(type)
    if not best_aton_target then
        return
    end

    return project.priest.spells.flashHeal("best_atonement", best_aton_target, type)
            or project.priest.spells.shield("best_atonement", best_aton_target, type)
            or project.priest.spells.renew("best_atonement", best_aton_target)
end
