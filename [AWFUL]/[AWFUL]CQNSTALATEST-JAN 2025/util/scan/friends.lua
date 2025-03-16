local Unlocker, awful, project = ...

project.util.scan.friends = function()
    project.util.friend.existing_classes = {}

    project.util.friend.danger = false

    project.util.friend.best_target.unit = awful.player
    project.util.friend.best_target.attackers.total = 0
    project.util.friend.best_target.attackers.melee = 0
    project.util.friend.best_target.attackers.ranged = 0
    project.util.friend.best_target.attackers.cds = 0
    project.util.friend.best_target.attackers.cdp = 0
    project.util.friend.best_target.attackers.cds_big = 0
    project.util.friend.best_target.attackers.cds_small = 0
    project.util.friend.best_target.defensives.def = 0
    project.util.friend.best_target.defensives.def_dr = 0
    project.util.friend.best_target.defensives.def_best = 0

    project.util.friend.tank = awful.player

    project.util.friend.total = 0
    project.util.friend.totalViable = 0
    project.util.friend.inCombat = 0

    project.util.friend.under90Hp = 0
    project.util.friend.under90Hp30Yards = 0

    project.util.friend.under70Hp = 0
    project.util.friend.under70Hp30Yards = 0
    project.util.friend.under70HpAton = 0

    project.util.friend.under50Hp = 0
    project.util.friend.under50HpAton = 0

    project.util.friend.under30Hp = 0
    project.util.friend.within30Yards = 0
    project.util.friend.tanks = 0
    project.util.friend.healers = 0
    project.util.friend.melees = 0
    project.util.friend.rangers = 0

    project.util.enemy.total_cds = 0

    --disci specific
    project.util.friend.withAtonement = 0
    project.util.friend.withBigAtonement = 0
    project.util.friend.withAtonement30Yards = 0
    project.util.friend.withoutAtonement30Yards = 0
    project.util.friend.withPWS = 0
    project.util.friend.withBigPWS = 0

    awful.fgroup.loop(function(friend)
        project.util.friend.total = project.util.friend.total + 1

        if friend.guid ~= awful.player.guid then
            project.util.friend.existing_classes[friend.class3] = true
        end

        if friend.role == "tank" then
            project.util.friend.tanks = project.util.friend.tanks + 1

            if not friend.dead then
                if not project.util.friend.tank
                        or not project.util.friend.tank.dead
                        or project.util.friend.tank.hp > friend.hp then
                    project.util.friend.tank = friend
                end
            end
        end

        if friend.role == "healer" then
            project.util.friend.healers = project.util.friend.healers + 1
        end

        if friend.melee then
            project.util.friend.melees = project.util.friend.melees + 1
        end

        if friend.ranged then
            project.util.friend.rangers = project.util.friend.rangers + 1
        end

        if not project.util.check.target.viable(friend) then
            return
        end

        project.util.friend.totalViable = project.util.friend.totalViable + 1

        if friend.combat then
            project.util.friend.inCombat = project.util.friend.inCombat + 1
        end

        if friend.los then
            if friend.hp < 90 then
                project.util.friend.under90Hp = project.util.friend.under90Hp + 1

                if friend.dist < 30 - 1 then
                    project.util.friend.under90Hp30Yards = project.util.friend.under90Hp30Yards + 1
                end
            end

            if friend.hp < 70 then
                project.util.friend.under70Hp = project.util.friend.under70Hp + 1

                if friend.dist < 30 - 1 then
                    project.util.friend.under70Hp30Yards = project.util.friend.under70Hp30Yards + 1
                end

                if friend.buffRemains(project.util.id.spell.ATONEMENT) > project.util.thresholds.buff() + 2 then
                    project.util.friend.under70HpAton = project.util.friend.under70HpAton + 1
                end
            end

            if friend.hp < 50 then
                project.util.friend.under50Hp = project.util.friend.under50Hp + 1
                if friend.buffRemains(project.util.id.spell.ATONEMENT) > project.util.thresholds.buff() then
                    project.util.friend.under50HpAton = project.util.friend.under50HpAton + 1
                end
            end

            if friend.dist < 30 - 1 then
                project.util.friend.within30Yards = project.util.friend.within30Yards + 1
            end

            if friend.buffRemains(project.util.id.spell.ATONEMENT) > project.util.thresholds.buff() then
                project.util.friend.withAtonement = project.util.friend.withAtonement + 1
                if friend.dist < 30 - 1 then
                    project.util.friend.withAtonement30Yards = project.util.friend.withAtonement30Yards + 1
                end
            end

            if friend.buffRemains(project.util.id.spell.ATONEMENT) <= project.util.thresholds.buff()
                    and friend.dist < 30 - 1 then
                project.util.friend.withoutAtonement30Yards = project.util.friend.withoutAtonement30Yards + 1
            end

            if friend.buffRemains(project.util.id.spell.ATONEMENT) > 5 + project.util.thresholds.buff() then
                project.util.friend.withBigAtonement = project.util.friend.withBigAtonement + 1
            end

            if friend.buff(project.util.id.spell.POWER_WORD_SHIELD) then
                project.util.friend.withPWS = project.util.friend.withPWS + 1
                if friend.hpa - friend.hp > 15 then
                    project.util.friend.withBigPWS = project.util.friend.withBigPWS + 1
                end
            end
        end

        project.util.enemy.total_cds = project.util.enemy.total_cds + project.util.check.target.attackers(friend).cdp
        if not project.util.friend.danger then
            project.util.friend.danger = project.util.check.target.danger(friend)
        end
    end)

    project.util.friend.best_target.unit = project.util.best_target.friend()
    local attackers = project.util.check.target.attackers(project.util.friend.best_target.unit)
    local defensives = project.util.check.target.defensives(project.util.friend.best_target.unit)

    project.util.friend.best_target.attackers.total = attackers.total
    project.util.friend.best_target.attackers.melee = attackers.melee
    project.util.friend.best_target.attackers.ranged = attackers.ranged
    project.util.friend.best_target.attackers.cds = attackers.cds
    project.util.friend.best_target.attackers.cdp = attackers.cdp
    project.util.friend.best_target.attackers.cds_big = attackers.cds_big
    project.util.friend.best_target.attackers.cds_small = attackers.cds_small

    project.util.friend.best_target.defensives.def = defensives.def
    project.util.friend.best_target.defensives.def_dr = defensives.def_dr
    project.util.friend.best_target.defensives.def_best = defensives.def_best

    project.settings.friend_target = awful.colors.green .. tostring(project.util.friend.best_target.unit.name)
    project.settings.friend_combat_danger = "DANGER: " .. awful.colors.green .. tostring(project.util.friend.danger)
    project.settings.friend_combat_tot_all = "TOT_ALL: " .. awful.colors.green .. project.util.enemy.total_cds

    project.settings.friend_combat_total = "TOT: " .. awful.colors.green .. attackers.total
    project.settings.friend_combat_melee = "MEL: " .. awful.colors.green .. attackers.melee
    project.settings.friend_combat_ranged = "RAN: " .. awful.colors.green .. attackers.ranged
    project.settings.friend_combat_cd_total = "CDS: " .. awful.colors.green .. attackers.cds
    project.settings.friend_combat_cd_players = "CDP: " .. awful.colors.green .. attackers.cdp
    project.settings.friend_combat_cd_big = "BIG: " .. awful.colors.green .. attackers.cds_big
    project.settings.friend_combat_cd_sm = "SML: " .. awful.colors.green .. attackers.cds_small

    project.settings.friend_combat_def = "DEF: " .. awful.colors.green .. defensives.def
    project.settings.friend_combat_def_dr = "DDR: " .. awful.colors.green .. defensives.def_dr
    project.settings.friend_combat_def_best = "BES: " .. awful.colors.green .. defensives.def_best
end
