local Unlocker, awful, project = ...

project.util.friend.attackers.data = {}

project.util.friend.attackers.add = function(friend, t, m, r, cd, cdp, cdb, cds, def, def_dr, def_best)
    if not friend then
        return
    end

    project.util.friend.attackers.data[friend.guid] = {
        t = t,
        m = m,
        r = r,
        cd = cd,
        cdp = cdp,
        cdb = cdb,
        cds = cds,
        def = def,
        def_dr = def_dr,
        def_best = def_best,
    }
end

project.util.friend.attackers.get = function(guid)
    local attackers = project.util.friend.attackers.data[guid]

    if not attackers then
        return {
            t = 0,
            m = 0,
            r = 0,
            cd = 0,
            cdp = 0,
            cdb = 0,
            cds = 0,
            def = 0,
            def_dr = 0,
            def_best = 0,
        }
    end

    return attackers
end

project.util.friend.attackers.reset = function()
    project.util.friend.attackers.data = {}

    project.util.friend.attackers.total = 0
    project.util.friend.attackers.melee = 0
    project.util.friend.attackers.ranged = 0
    project.util.friend.attackers.cd.total = 0
    project.util.friend.attackers.cd.players = 0
    project.util.friend.attackers.cd.big = 0
    project.util.friend.attackers.cd.sm = 0
    project.util.friend.attackers.def = 0
    project.util.friend.attackers.def_dr = 0
    project.util.friend.attackers.def_best = 0
    project.util.friend.attackers.data = {}
end

project.util.friend.attackers.update = function(attackers)
    project.util.friend.attackers.total = attackers.t
    project.util.friend.attackers.melee = attackers.m
    project.util.friend.attackers.ranged = attackers.r
    project.util.friend.attackers.cd.total = attackers.cd
    project.util.friend.attackers.cd.players = attackers.cdp
    project.util.friend.attackers.cd.big = attackers.cdb
    project.util.friend.attackers.cd.sm = attackers.cds
    project.util.friend.attackers.def = attackers.def
    project.util.friend.attackers.def_dr = attackers.def_dr
    project.util.friend.attackers.def_best = attackers.def_best
end

project.util.enemy.attackers.data = {}

project.util.enemy.attackers.add = function(enemy, t, m, r, cd, cdp, cdb, cds, def, def_dr, def_best)
    if not enemy then
        return
    end

    project.util.enemy.attackers.data[enemy.guid] = {
        t = t,
        m = m,
        r = r,
        cd = cd,
        cdp = cdp,
        cdb = cdb,
        cds = cds,
        def = def,
        def_dr = def_dr,
        def_best = def_best,
    }
end

project.util.enemy.attackers.get = function(guid)
    local attackers = project.util.enemy.attackers.data[guid]

    if not attackers then
        return {
            t = 0,
            m = 0,
            r = 0,
            cd = 0,
            cdp = 0,
            cdb = 0,
            cds = 0,
            def = 0,
            def_dr = 0,
            def_best = 0,
        }
    end

    return attackers
end

project.util.enemy.attackers.reset = function()
    project.util.enemy.attackers.data = {}

    project.util.enemy.attackers.total = 0
    project.util.enemy.attackers.melee = 0
    project.util.enemy.attackers.ranged = 0
    project.util.enemy.attackers.cd.total = 0
    project.util.enemy.attackers.cd.players = 0
    project.util.enemy.attackers.cd.big = 0
    project.util.enemy.attackers.cd.sm = 0
    project.util.enemy.attackers.def = 0
    project.util.enemy.attackers.def_dr = 0
    project.util.enemy.attackers.def_best = 0
    project.util.enemy.attackers.data = {}
end

project.util.enemy.attackers.update = function(attackers)
    project.util.enemy.attackers.total = attackers.t
    project.util.enemy.attackers.melee = attackers.m
    project.util.enemy.attackers.ranged = attackers.r
    project.util.enemy.attackers.cd.total = attackers.cd
    project.util.enemy.attackers.cd.players = attackers.cdp
    project.util.enemy.attackers.cd.big = attackers.cdb
    project.util.enemy.attackers.cd.sm = attackers.cds
    project.util.enemy.attackers.def = attackers.def
    project.util.enemy.attackers.def_dr = attackers.def_dr
    project.util.enemy.attackers.def_best = attackers.def_best
end
