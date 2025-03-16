local Unlocker, awful, project = ...

local function should_smite()
    if awful.player.debuff("Scorpid Venom")
            and awful.player.debuffRemains("Scorpid Venom") < project.priest.spells.smite.castTime then
        return
    end

    if not awful.player.buff("Voidheart") then
        if project.util.friend.bestTarget.hp < 20 then
            return
        end

        if awful.player.buffStacks("Weal and Woe") < 6 then
            if project.priest.spells.penance.cd < awful.gcd then
                return
            end

            if project.priest.spells.mindBlast.cd < awful.gcd then
                return
            end
        end
    end

    if awful.player.manaPct < 5 then
        return
    end

    return true
end

project.priest.spells.smite:Callback("spam", function(spell, target)
    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Smite! spam", project.priest.spells.smite.id)
end)

project.priest.spells.smite:Callback("totem_stomp", function(spell, totem)
    return project.util.cast.stop_moving(spell, totem, true, true)
            and project.util.debug.alert.attack("Smite! totem_stomp " .. totem.name , project.priest.spells.smite.id)
end)

project.priest.spells.smite:Callback("pve", function(spell, target)
    if project.util.cast.block.spell_name == "Smite" then
        return
    end

    if project.util.cast.block.spell_name == "Void Blast" then
        return
    end

    return project.priest.spells.smite("spam", target)
end)

project.priest.spells.smite:Callback("pvp", function(spell, target)
    if project.util.cast.block.spell_name == "Smite" then
        return
    end

    if project.util.cast.block.spell_name == "Void Blast" then
        return
    end

    if not should_smite() then
        return
    end

    if project.util.friend.danger then
        if awful.player.buff("Rapture")
                and not awful.player.buff("Premonition of Insight")
                and not awful.player.buff("Voidheart") then
            return
        end
    end

    return project.priest.spells.smite("spam", target)
end)