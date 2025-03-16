local Unlocker, awful, project = ...

local function should_smite()
    if project.util.enemy.existing_classes[project.util.id.class.HUNTER]
            and awful.player.debuff(project.util.id.spell.SCORPID_VENOM)
            and awful.player.debuffRemains(project.util.id.spell.SCORPID_VENOM) < project.priest.spells.smite.castTime then
        return
    end

    if not awful.player.buff(project.util.id.spell.VOIDHEART) then
        if project.util.friend.danger then
            return
        end

        if awful.player.manaPct < 5 then
            return
        end
    end

    if project.util.evade.block_cast then
        return
    end

    return true
end

project.priest.spells.smite:Callback("spam", function(spell, target)
    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Smite! spam", project.priest.spells.smite.id)
end)

project.priest.spells.smite:Callback("totem_stomp", function(spell, totem)
    return project.util.cast.stop_moving(spell, totem, true)
            and project.util.debug.alert.attack("Smite! totem_stomp " .. totem.name, project.priest.spells.smite.id)
end)

project.priest.spells.smite:Callback("pve", function(spell, target)
    if project.util.cast.block.spell == project.util.id.spell.SMITE then
        return
    end

    if project.util.cast.block.spell == project.util.id.spell.VOID_BLAST then
        return
    end

    return project.priest.spells.smite("spam", target)
end)

project.priest.spells.smite:Callback("pvp", function(spell, target)
    if project.util.cast.block.spell == project.util.id.spell.SMITE then
        return
    end

    if project.util.cast.block.spell == project.util.id.spell.VOID_BLAST then
        return
    end

    if not should_smite() then
        return
    end

    if project.util.friend.danger then
        if awful.player.buff(project.util.id.spell.RAPTURE)
                and not awful.player.buff(project.util.id.spell.PREMONITION_OF_INSIGHT)
                and not awful.player.buff(project.util.id.spell.VOIDHEART) then
            return
        end
    end

    return project.priest.spells.smite("spam", target)
end)