local Unlocker, awful, project = ...

local interrupts = {
    ['Druid'] = {
        ['Feral'] = { name = "Skull Bash", range = 13 },
        ['Balance'] = nil,
        ['Guardian'] = { name = "Skull Bash", range = 13 },
        ['Restoration'] = nil,
    },
    ['Evoker'] = {
        ['Devastation'] = { name = "Quell", range = 25 },
        ['Preservation'] = { name = "Quell", range = 25 },
        ['Augmentation'] = { name = "Quell", range = 25 },
    },
    ['Mage'] = {
        ['Arcane'] = { name = "Counterspell", range = 40 },
        ['Fire'] = { name = "Counterspell", range = 40 },
        ['Frost'] = { name = "Counterspell", range = 40 },
    },
    ['Paladin'] = {
        ['Retribution'] = { name = "Rebuke", range = 5 },
        ['Protection'] = { name = "Rebuke", range = 5 },
        ['Holy'] = { name = "Rebuke", range = 5 },
    },
    ['Rogue'] = {
        ['Assassination'] = { name = "Kick", range = 5 },
        ['Outlaw'] = { name = "Kick", range = 5 },
        ['Subtlety'] = { name = "Kick", range = 5 },
    },
    ['Shaman'] = {
        ['Elemental'] = { name = "Wind Shear", range = 30 },
        ['Enhancement'] = { name = "Wind Shear", range = 30 },
        ['Restoration'] = { name = "Wind Shear", range = 30 },
    },
    ['Hunter'] = {
        ['Beast Mastery'] = { name = "Counter Shot", range = 40 },
        ['Marksmanship'] = { name = "Counter Shot", range = 40 },
        ['Survival'] = { name = "Muzzle", range = 5 },
    },
    ['Monk'] = {
        ['Windwalker'] = { name = "Spear Hand Strike", range = 5 },
        ['Brewmaster'] = { name = "Spear Hand Strike", range = 5 },
        ['Mistweaver'] = { name = "Spear Hand Strike", range = 5 },
    },
    ['Warlock'] = {
        ['Affliction'] = { name = "Spell Lock", range = 40 },
        ['Demonology'] = { name = "Spell Lock", range = 40 },
        ['Destruction'] = { name = "Spell Lock", range = 40 },
    },
    ['Warrior'] = {
        ['Arms'] = { name = "Pummel", range = 5 },
        ['Fury'] = { name = "Pummel", range = 5 },
        ['Protection'] = { name = "Pummel", range = 5 },
    },
    ['Death Knight'] = {
        ['Unholy'] = { name = "Mind Freeze", range = 5 },
        ['Frost'] = { name = "Mind Freeze", range = 5 },
        ['Blood'] = { name = "Mind Freeze", range = 5 },
    },
    ['Demon Hunter'] = {
        ['Havoc'] = { name = "Disrupt", range = 5 },
        ['Vengeance'] = { name = "Disrupt", range = 5 },
    },
}

project.util.check.enemy.interrupt = function()
    if awful.player.buff(377362) then
        return
    end

    return awful.enemies.find(function(enemy)
        if not enemy
                or enemy.dead
                or not enemy.player
                or enemy.cc
                or not enemy.los then
            return
        end

        local interrupt = interrupts[enemy.class] and interrupts[enemy.class][enemy.spec]
        if not interrupt then
            return
        end

        if project.util.friend.danger then
            if enemy.class == 'Rogue' and enemy.cooldown("Shadowstep") <= awful.gcd * 2 then
                interrupt.range = 40
            end
        end

        if enemy.dist > interrupt.range then
            return
        end

        if enemy.cooldown(interrupt.name) > awful.gcd then
            return
        end

        return true
    end)
end
