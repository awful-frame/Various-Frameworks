local Unlocker, awful, project = ...

local spells = {}

project.util.cast.overlap.reset = function()
    spells = {}
end

project.util.cast.overlap.should = function(spell, target)
    if not spell then
        return false
    end

    if target then
        local overlap_spell = spells[target.guid]
        if not overlap_spell then
            return true
        end

        return spell.id == overlap_spell.id
    else
        local overlap_spell = spells["no_target"]
        if not overlap_spell then
            return true
        end

        return spell.id == overlap_spell.id
    end
end

project.util.cast.overlap.set = function(spell, target)
    if target and target.guid then
        spells[target.guid] = spell
    else
        spells["no_target"] = spell
    end
end

project.util.cast.overlap.cast = function(spell, target)
    if not spell then
        return false
    end

    if not project.util.cast.overlap.should(spell, target) then
        return false
    end

    if target then
        if spell:Cast(target) then
            project.util.cast.overlap.set(spell, target)
            return true
        end
    else
        if spell:Cast() then
            project.util.cast.overlap.set(spell)
            return true
        end
    end

    return false
end

project.util.cast.overlap.cast_sm = function(spell, target)
    if not spell then
        return false
    end

    if not project.util.cast.overlap.should(spell, target) then
        return false
    end

    if target then
        if spell:Cast(target, { stopMoving = true }) then
            project.util.cast.overlap.set(spell, target)
            return true
        end
    else
        if spell:Cast({ stopMoving = true }) then
            project.util.cast.overlap.set(spell)
            return true
        end
    end

    return false
end

project.util.cast.overlap.smart_aoe = function(spell, target)
    if not spell then
        return false
    end

    if not project.util.cast.overlap.should(spell, target) then
        return false
    end

    if target and spell:SmartAoE(target) then
        project.util.cast.overlap.set(spell, target)
        return true
    end

    return false
end
