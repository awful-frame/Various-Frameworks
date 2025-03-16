local Unlocker, awful, project = ...

project.util.scan.enemies = function(type)
    project.util.enemy.existing_classes = {}
    project.util.enemy.combat_viable_ids = {}

    project.util.enemy.danger = false

    project.util.enemy.best_target.unit = nil
    project.util.enemy.best_target.attackers.total = 0
    project.util.enemy.best_target.attackers.melee = 0
    project.util.enemy.best_target.attackers.ranged = 0
    project.util.enemy.best_target.attackers.cds = 0
    project.util.enemy.best_target.attackers.cdp = 0
    project.util.enemy.best_target.attackers.cds_big = 0
    project.util.enemy.best_target.attackers.cds_small = 0
    project.util.enemy.best_target.defensives.def = 0
    project.util.enemy.best_target.defensives.def_dr = 0
    project.util.enemy.best_target.defensives.def_best = 0

    project.util.enemy.target.stealth = nil

    project.util.enemy.total = 0
    project.util.enemy.totalPlayers = 0
    project.util.enemy.totalViable = 0
    project.util.enemy.totalCombat = 0
    project.util.enemy.withPurge = 0
    project.util.enemy.aggro = 0

    project.util.enemy.max_level_combat = awful.player.level

    project.util.friend.total_cds = 0

    awful.enemies.loop(function(enemy)
        project.util.enemy.total = project.util.enemy.total + 1

        if enemy.player then
            project.util.enemy.totalPlayers = project.util.enemy.totalPlayers + 1
            if awful.arena then
                project.util.enemy.existing_classes[enemy.class3] = true
            end
        end

        if not project.util.check.target.viable(enemy) then
            return
        end

        if not awful.arena then
            project.util.enemy.existing_classes[enemy.class3] = true
        end

        project.util.enemy.totalViable = project.util.enemy.totalViable + 1

        if enemy.inCombat then
            project.util.enemy.totalCombat = project.util.enemy.totalCombat + 1
            project.util.enemy.combat_viable_ids[enemy.id] = true

            if project.util.enemy.max_level_combat ~= -1 then
                if enemy.level > project.util.enemy.max_level_combat or enemy.level == -1 then
                    project.util.enemy.max_level_combat = enemy.level
                end
            end
        end

        if enemy.debuffRemains(project.util.id.spell.PURGE_THE_WICKED_DEBUFF) > project.util.thresholds.buff() + 1 then
            project.util.enemy.withPurge = project.util.enemy.withPurge + 1
        end

        if enemy.aggro then
            project.util.enemy.aggro = project.util.enemy.aggro + 1
        end

        if type == "pvp" then
            if enemy.stealth then
                project.util.enemy.target.stealth = enemy
            end
        end

        project.util.friend.total_cds = project.util.friend.total_cds + project.util.check.target.attackers(enemy).cdp
        if not project.util.enemy.danger then
            project.util.enemy.danger = project.util.check.target.danger(enemy)
        end
    end)

    if project.util.enemy.totalViable == 0 then
        return
    end

    if project.util.friend.total == 1 then
        if awful.target.enemy then
            project.util.enemy.best_target.unit = awful.target
        end
    else
        project.util.enemy.best_target.unit = project.util.best_target.enemy(type)
    end

    if not project.util.enemy.best_target.unit then
        return
    end

    local attackers = project.util.check.target.attackers(project.util.enemy.best_target.unit)
    local defensives = project.util.check.target.defensives(project.util.enemy.best_target.unit)

    project.util.enemy.best_target.attackers.total = attackers.total
    project.util.enemy.best_target.attackers.melee = attackers.melee
    project.util.enemy.best_target.attackers.ranged = attackers.ranged
    project.util.enemy.best_target.attackers.cds = attackers.cds
    project.util.enemy.best_target.attackers.cdp = attackers.cdp
    project.util.enemy.best_target.attackers.cds_big = attackers.cds_big
    project.util.enemy.best_target.attackers.cds_small = attackers.cds_small

    project.util.enemy.best_target.defensives.def = defensives.def
    project.util.enemy.best_target.defensives.def_dr = defensives.def_dr
    project.util.enemy.best_target.defensives.def_best = defensives.def_best

    project.settings.enemy_target = awful.colors.red .. tostring(project.util.enemy.best_target.unit.name)
    project.settings.enemy_combat_danger = "DANGER: " .. awful.colors.red .. tostring(project.util.enemy.danger)
    project.settings.enemy_combat_tot_all = "TOT_ALL: " .. awful.colors.red .. project.util.friend.total_cds

    project.settings.enemy_combat_total = "TOT: " .. awful.colors.red .. attackers.total
    project.settings.enemy_combat_melee = "MEL: " .. awful.colors.red .. attackers.melee
    project.settings.enemy_combat_ranged = "RAN: " .. awful.colors.red .. attackers.ranged
    project.settings.enemy_combat_cd_total = "CDS: " .. awful.colors.red .. attackers.cds
    project.settings.enemy_combat_cd_players = "CDP: " .. awful.colors.red .. attackers.cdp
    project.settings.enemy_combat_cd_big = "BIG: " .. awful.colors.red .. attackers.cds_big
    project.settings.enemy_combat_cd_sm = "SML: " .. awful.colors.red .. attackers.cds_small

    project.settings.enemy_combat_def = "DEF: " .. awful.colors.red .. defensives.def
    project.settings.enemy_combat_def_dr = "DDR: " .. awful.colors.red .. defensives.def_dr
    project.settings.enemy_combat_def_best = "BES: " .. awful.colors.red .. defensives.def_best
end
