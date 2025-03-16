local Unlocker, awful, project = ...

project.priest.discipline.rotation.dispel = function(type)
    if awful.player.ccRemains > 1 then
        return
    end

    local friend, debuff, friend_prio, has_touch_or_aff = project.util.dispel.magic.friend(type)
    local enemy, buff, enemy_prio = project.util.dispel.magic.enemy(type)

    if friend_prio == -9 then
        project.priest.spells.dispelMagic("-9PRIO_FRIEND", friend, debuff, friend_prio)
    end

    project.priest.spells.purify(type, friend, debuff, friend_prio, has_touch_or_aff)
    project.priest.spells.dispelMagic(type, enemy, buff, enemy_prio)

    if type == "pvp" then
        if awful.player.castID == project.util.id.spell.MASS_DISPEL
                and not enemy
                and not friend
                and not project.priest.discipline.rotation.util.ice_wall_detected
        then
            awful.call("SpellStopCasting")
        end
    end

    if type == "pvp" then
        return project.priest.spells.massDispel("enemy_pvp", enemy, buff, enemy_prio)
                or project.priest.spells.massDispel("friend_pvp", friend, debuff, friend_prio)
    end

    return project.priest.spells.massDispel("friend_pve", friend, debuff, friend_prio)
            or project.priest.spells.massDispel("enemy_pve", enemy, buff, enemy_prio)
end
