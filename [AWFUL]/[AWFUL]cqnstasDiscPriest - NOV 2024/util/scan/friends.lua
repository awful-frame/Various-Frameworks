local Unlocker, awful, project = ...

project.util.scan.friends = function()
    project.util.friend.attackers.reset()

    project.util.friend.existingClasses = {}

    project.util.friend.danger = false

    project.util.friend.bestTarget = awful.player
    project.util.friend.tank = awful.player

    project.util.friend.total = 0
    project.util.friend.totalViable = 0
    project.util.friend.inCombat = 0

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

    project.util.enemy.withOffensiveCds = 0

    --disci specific
    project.util.friend.withAtonement = 0
    project.util.friend.withBigAtonement = 0
    project.util.friend.withAtonement30Yards = 0
    project.util.friend.withoutAtonement30Yards = 0
    project.util.friend.withPWS = 0

    awful.fgroup.loop(function(friend)
        project.util.friend.total = project.util.friend.total + 1
        project.util.friend.existingClasses[friend.class] = true

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
            if friend.hp < 70 then
                project.util.friend.under70Hp = project.util.friend.under70Hp + 1

                if friend.dist < 30 - 1 then
                    project.util.friend.under70Hp30Yards = project.util.friend.under70Hp30Yards + 1
                end

                if friend.buffRemains("Atonement") > project.util.thresholds.buff() + 2 then
                    project.util.friend.under70HpAton = project.util.friend.under70HpAton + 1
                end
            end

            if friend.hp < 50 then
                project.util.friend.under50Hp = project.util.friend.under50Hp + 1
                if friend.buffRemains("Atonement") > project.util.thresholds.buff() + 2 then
                    project.util.friend.under50HpAton = project.util.friend.under50HpAton + 1
                end
            end

            if friend.dist < 30 - 1 then
                project.util.friend.within30Yards = project.util.friend.within30Yards + 1
            end

            if friend.buffRemains("Atonement") > project.util.thresholds.buff() + 2 then
                project.util.friend.withAtonement = project.util.friend.withAtonement + 1
                if friend.dist < 30 - 1 then
                    project.util.friend.withAtonement30Yards = project.util.friend.withAtonement30Yards + 1
                end
            end

            if friend.buffRemains("Atonement") <= project.util.thresholds.buff() + 2
                    and friend.dist < 30 - 1 then
                project.util.friend.withoutAtonement30Yards = project.util.friend.withoutAtonement30Yards + 1
            end

            if friend.buffRemains("Atonement") > 5 + project.util.thresholds.buff() then
                project.util.friend.withBigAtonement = project.util.friend.withBigAtonement + 1
            end

            if friend.buff("Power Word: Shield") then
                project.util.friend.withPWS = project.util.friend.withPWS + 1
            end
        end

        local t, m, r, cd, cdp, cdb, cds, def, def_dr, def_best = project.util.check.target.combat(friend)
        project.util.enemy.withOffensiveCds = project.util.enemy.withOffensiveCds + cdp
        project.util.friend.attackers.add(friend, t, m, r, cd, cdp, cdb, cds, def, def_dr, def_best)
        if not project.util.friend.danger then
            project.util.friend.danger = project.util.check.target.danger(friend)
        end
    end)

    project.util.friend.bestTarget = project.util.best_target.friend()

    local attackers = project.util.friend.attackers.get(project.util.friend.bestTarget.guid)
    project.util.friend.attackers.update(attackers)

    project.settings.friend_target = awful.colors.green .. tostring(project.util.friend.bestTarget.name)
    project.settings.friend_combat_danger = "DANGER: " .. awful.colors.green .. tostring(project.util.friend.danger)
    project.settings.friend_combat_tot_all = "TOT_ALL: " .. awful.colors.green .. project.util.enemy.withOffensiveCds
    project.settings.friend_combat_total = "TOT: " .. awful.colors.green .. attackers.t
    project.settings.friend_combat_melee = "MEL: " .. awful.colors.green .. attackers.m
    project.settings.friend_combat_ranged = "RAN: " .. awful.colors.green .. attackers.r
    project.settings.friend_combat_cd_total = "CDS: " .. awful.colors.green .. attackers.cd
    project.settings.friend_combat_cd_players = "CDP: " .. awful.colors.green .. attackers.cdp
    project.settings.friend_combat_cd_big = "BIG: " .. awful.colors.green .. attackers.cdb
    project.settings.friend_combat_cd_sm = "SML: " .. awful.colors.green .. attackers.cds
    project.settings.friend_combat_def = "DEF: " .. awful.colors.green .. attackers.def
    project.settings.friend_combat_def_dr = "DDR: " .. awful.colors.green .. attackers.def_dr
    project.settings.friend_combat_def_best = "BES: " .. awful.colors.green .. tostring(attackers.def_best)
end
