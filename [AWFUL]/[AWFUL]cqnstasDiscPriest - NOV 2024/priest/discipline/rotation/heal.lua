local Unlocker, awful, project = ...

local function findBestAtonementTargetPVE()
    local bestAtonementTarget

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        if friend.buffRemains("Atonement") < project.util.thresholds.buff() then
            if bestAtonementTarget and bestAtonementTarget.role == "tank" then
                return
            end

            if friend.role == "tank" then
                bestAtonementTarget = friend
            end

            if bestAtonementTarget
                    and bestAtonementTarget.hp > friend.hp then
                bestAtonementTarget = friend
                return
            end

            if not bestAtonementTarget then
                bestAtonementTarget = friend
                return
            end
        end
    end)

    if not bestAtonementTarget then
        return
    end

    if not bestAtonementTarget.inCombat then
        return
    end

    if bestAtonementTarget.hp > 90 then
        return
    end

    return bestAtonementTarget
end

local function findBestAtonementTargetPVP()
    local bestAtonementTarget
    local maxAttackers = 0
    local maxCooldowns = 0

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        local attackers = project.util.friend.attackers.get(friend.guid)

        if friend.buffRemains("Atonement") < project.util.thresholds.buff() then
            if bestAtonementTarget and maxCooldowns < attackers.cdp then
                bestAtonementTarget = friend
                maxAttackers = attackers.t
                maxCooldowns = attackers.cdp
                return
            end

            if bestAtonementTarget and maxAttackers < attackers.t then
                bestAtonementTarget = friend
                maxAttackers = attackers.t
                return
            end

            if bestAtonementTarget
                    and maxAttackers == attackers.t
                    and maxCooldowns == attackers.cdp
                    and bestAtonementTarget.hp > friend.hp then
                bestAtonementTarget = friend
                return
            end

            if not bestAtonementTarget then
                bestAtonementTarget = friend
                maxAttackers = attackers.t
                maxCooldowns = attackers.cdp
                return
            end
        end
    end)

    if project.util.friend.withAtonement > 0 then
        if project.util.friend.total > 3
                and (maxAttackers == 0 or bestAtonementTarget.hp > 90) then
            return
        end
    end

    return bestAtonementTarget
end

local function findBestAtonementTarget(type)
    if type == "pvp" then
        return findBestAtonementTargetPVP()
    end
    return findBestAtonementTargetPVE()
end

local function should_heal()
    if awful.player.buff("Arena Preparation") then
        return
    end

    if awful.player.buff("Preparation") then
        return
    end

    if project.util.cast.block.spell_name == "Power Word: Radiance" then
        return
    end

    if project.util.cast.block.spell_name == "Flash Heal" then
        return
    end

    if project.util.cast.block.spell_name == "Mind Blast" then
        return
    end

    return true
end

project.priest.discipline.rotation.heal = function(type)
    if not should_heal() then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        project.priest.spells.radiance(type)
        project.priest.spells.penance("from_heal")
    end

    project.priest.spells.shield(type)

    if type == "pvp"
            or project.util.friend.total <= 5
            or project.util.friend.bestTarget.hp < 20 then
        project.priest.spells.flashHeal(type)
    end

    if IsPlayerSpell(373481) then
        project.priest.spells.life("default")
    end

    project.priest.spells.radiance(type)
    project.priest.spells.penance("from_heal")

    if project.util.friend.danger then
        return
    end

    local bestAtonementTarget = findBestAtonementTarget(type)
    if not bestAtonementTarget then
        return
    end

    return project.priest.spells.flashHeal("best_atonement", bestAtonementTarget, type)
            or project.priest.spells.shield("best_atonement", bestAtonementTarget, type)
            or project.priest.spells.renew("best_atonement", bestAtonementTarget)
end
