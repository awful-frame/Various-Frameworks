local Unlocker, awful, project = ...

local innerLightShadowCooldown = false
local cooldownDuration = 3

local function setCooldown()
    innerLightShadowCooldown = true
    C_Timer.After(cooldownDuration, function()
        innerLightShadowCooldown = false
    end)
end

project.priest.spells.inner_light_and_shadow:Callback(function(spell)
    if not awful.player.hasTalent("Inner Light and Shadow") then
        return
    end

    if project.util.enemy.withOffensiveCds > 0 then
        return
    end

    if project.util.friend.bestTarget.hp < 50 then
        return
    end

    if not awful.player.buff("Inner Light") and not awful.player.buff("Inner Shadow") then
        setCooldown()
        return spell:Cast()
                and project.util.debug.alert.beneficial("Inner Light and Shadow!", project.priest.spells.inner_light_and_shadow.id)
    end

    if innerLightShadowCooldown then
        return
    end

    if awful.player.manaPct < project.settings.priest_cds_inner_light_and_shadow_mana_threshold
            and not awful.player.buff("Inner Light")
            and awful.arena then
        setCooldown()
        return spell:Cast()
                and project.util.debug.alert.beneficial("Inner Light!", project.priest.spells.inner_light_and_shadow.id)
    end

    if awful.player.manaPct >= project.settings.priest_cds_inner_light_and_shadow_mana_threshold
            and not awful.player.buff("Inner Shadow") then
        setCooldown()
        return spell:Cast()
                and project.util.debug.alert.beneficial("Inner Shadow!", project.priest.spells.inner_light_and_shadow.id)
    end
end)
