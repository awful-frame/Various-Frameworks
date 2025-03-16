local Unlocker, awful, project = ...

project.util.check.target.viable = function(target, ignore_facing, ignore_los)
    if not target then
        return
    end

    if target.dead then
        return
    end

    if not awful.arena then
        if not target.los then
            return
        end

        if target.dist > project.util.check.player.range() then
            return
        end
    end

    if project.util.check.scenario.type() == "pvp" then
        if target.buff(project.util.id.spell.TIME_STOP) then
            return
        end
    end

    if target.friend then
        if target.immuneHealing then
            return
        end
    end

    if target.enemy then
        if not ignore_los
                and not target.los then
            return
        end

        if target.dist > project.util.check.player.range() then
            return
        end

        if target.immuneMagicDamage then
            return
        end

        if target.buff(project.util.id.spell.GROUNDING_TOTEM_BUFF) then
            return
        end

        if target.class3 == project.util.id.class.WARRIOR
                and target.buff(project.util.id.spell.SPELL_REFLECTION) then
            return
        end

        if target.class3 == project.util.id.class.WARLOCK
                and target.buff(project.util.id.spell.NETHER_WARD) then
            return
        end

        if target.specID == project.util.id.spec.HOLY_PRIEST
                and target.buffFrom({ project.util.id.spell.SPIRIT_OF_REDEMPTION_1, project.util.id.spell.SPIRIT_OF_REDEMPTION_2 }) then
            return
        end

        if not ignore_facing
                and not awful.mapID == project.util.id.map.DAWNBREAKER
                and not target.playerFacing then
            return
        end

        if awful.mapID == project.util.id.map.DAWNBREAKER then
            if target.distanceTo(project.util.friend.tank) > 15 then
                return
            end

            if target.id == project.util.id.npc.SPEAKER_SHADOWCROWN then
                if target.castID == project.util.id.spell.DARKNESS_COMES then
                    return
                end

                if target.buffFrom({ project.util.id.spell.DARKNESS_COMES_BUFF_1,
                                     project.util.id.spell.DARKNESS_COMES_BUFF_2,
                                     project.util.id.spell.DARKNESS_COMES_BUFF_3 }) then
                    return
                end
            end
        end

        if project.util.check.scenario.type() == "pvp" then
            if target.bcc then
                return
            end

            local _, _, incoming_remaining = project.util.check.target.incoming(target)
            if incoming_remaining < awful.gcd then
                return
            end
        end
    end

    return true
end