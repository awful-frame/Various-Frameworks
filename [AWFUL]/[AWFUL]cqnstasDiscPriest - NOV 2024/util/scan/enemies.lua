local Unlocker, awful, project = ...

project.util.scan.enemies = function(type)
    project.util.enemy.attackers.reset()

    project.util.enemy.existingClasses = {}

    project.util.enemy.danger = false

    project.util.enemy.bestTarget = nil
    project.util.enemy.target.stealth = nil
    project.util.enemy.target.interrupt = nil

    project.util.enemy.total = 0
    project.util.enemy.totalPlayers = 0
    project.util.enemy.totalViable = 0
    project.util.enemy.totalCombat = 0
    project.util.enemy.withPurge = 0
    project.util.enemy.aggro = 0

    project.util.enemy.max_level_combat = awful.player.level

    project.util.friend.withOffensiveCds = 0

    awful.enemies.loop(function(enemy)
        project.util.enemy.total = project.util.enemy.total + 1

        if enemy.player then
            project.util.enemy.totalPlayers = project.util.enemy.totalPlayers + 1
            project.util.enemy.existingClasses[enemy.class] = true
        end

        if not project.util.check.target.viable(enemy) then
            return
        end

        project.util.enemy.totalViable = project.util.enemy.totalViable + 1

        if enemy.inCombat then
            project.util.enemy.totalCombat = project.util.enemy.totalCombat + 1

            if project.util.enemy.max_level_combat ~= -1 then
                if enemy.level > project.util.enemy.max_level_combat or enemy.level == -1 then
                    project.util.enemy.max_level_combat = enemy.level
                end
            end
        end

        if enemy.debuffRemains("Purge the Wicked") > project.util.thresholds.buff() + 1 then
            project.util.enemy.withPurge = project.util.enemy.withPurge + 1
        end

        if enemy.aggro then
            project.util.enemy.aggro = project.util.enemy.aggro + 1
        end

        if enemy.stealth then
            project.util.enemy.target.stealth = enemy
        end

        if enemy.casting == "Capturing"
                or enemy.casting == "Resurrection"
                or enemy.casting == "Redemption"
                or enemy.casting == "Resuscitate"
                or enemy.casting == "Return"
                or enemy.casting == "Revive"
                or enemy.casting == "Ancestral Spirit"
                or enemy.casting == "Mass Resurrection" then
            project.util.enemy.target.interrupt = enemy
        end

        local t, m, r, cd, cdp, cdb, cds, def, def_dr, def_best = project.util.check.target.combat(enemy)
        project.util.friend.withOffensiveCds = project.util.friend.withOffensiveCds + cdp
        project.util.enemy.attackers.add(enemy, t, m, r, cd, cdp, cdb, cds, def, def_dr, def_best)
        if not project.util.enemy.danger then
            project.util.enemy.danger = project.util.check.target.danger(enemy)
        end
    end)

    if project.util.enemy.totalViable == 0 then
        return
    end

    if project.util.friend.total == 1 then
        if awful.target.enemy then
            project.util.enemy.bestTarget = awful.target
        end
    else
        project.util.enemy.bestTarget = project.util.best_target.enemy(type)
    end

    if not project.util.enemy.bestTarget then
        return
    end

    local attackers = project.util.enemy.attackers.get(project.util.enemy.bestTarget.guid)
    project.util.enemy.attackers.update(attackers)

    project.settings.enemy_target = awful.colors.red .. tostring(project.util.enemy.bestTarget.name)
    project.settings.enemy_combat_danger = "DANGER: " .. awful.colors.red .. tostring(project.util.enemy.danger)
    project.settings.enemy_combat_tot_all = "TOT_ALL: " .. awful.colors.red .. project.util.friend.withOffensiveCds
    project.settings.enemy_combat_total = "TOT: " .. awful.colors.red .. attackers.t
    project.settings.enemy_combat_melee = "MEL: " .. awful.colors.red .. attackers.m
    project.settings.enemy_combat_ranged = "RAN: " .. awful.colors.red .. attackers.r
    project.settings.enemy_combat_cd_total = "CDS: " .. awful.colors.red .. attackers.cd
    project.settings.enemy_combat_cd_players = "CDP: " .. awful.colors.red .. attackers.cdp
    project.settings.enemy_combat_cd_big = "BIG: " .. awful.colors.red .. attackers.cdb
    project.settings.enemy_combat_cd_sm = "SML: " .. awful.colors.red .. attackers.cds
    project.settings.enemy_combat_def = "DEF: " .. awful.colors.red .. attackers.def
    project.settings.enemy_combat_def_dr = "DDR: " .. awful.colors.red .. attackers.def_dr
    project.settings.enemy_combat_def_best = "BES: " .. awful.colors.red .. tostring(attackers.def_best)
end
