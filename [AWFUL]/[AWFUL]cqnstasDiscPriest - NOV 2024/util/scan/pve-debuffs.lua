local Unlocker, awful, project = ...

project.util.pve_debuffs.target = nil
project.util.pve_debuffs.debuff = nil
project.util.pve_debuffs.prio = nil

local pve_debuffs = {
    -- Raid
    -- Ky'veza
    ["Queensbane"] = 0,

    -- Ara'Kara
    ["Revolting Volley"] = 1,
    ["Venom Volley"] = 1,

    -- City of Threads
    ["Shadows of Doubt"] = 0,
    ["Venomous Spray"] = 1,

    --The Dawnbreaker
    ["Stygian Seed"] = 0,
    ["Ensnaring Shadows"] = 1,
    ["Bursting Cocoon"] = 1,
    ["Dark Scars"] = 1,
    ["Tormenting Ray"] = 1,

    -- The Stonevault
    ["Void Infection"] = 0,

    -- Necrotic Wake
    ["Goresplatter"] = 1,
    ["Frozen Binds"] = 1,
    ["Heaving Retch"] = 1,

    -- Siege of Boralus
    ["Rotting Wounds"] = 1,
    ["Azerite Charge"] = 1,

    -- Grim Batol
    ["Enveloping Shadowflame"] = 1,
}

project.util.scan.pve_debuffs = function(type)
    if type == "pvp" then
        return
    end

    local threshold = (0.2 + (math.random() * 0.4))

    local friend_with_debuff
    local pve_debuff
    local highest_prio = 100

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        for debuff, priority in pairs(pve_debuffs) do
            local valid = true

            if not friend.debuff(debuff) then
                valid = false
            end

            if friend.debuffUptime(debuff) < threshold then
                valid = false
            end

            if friend.debuffRemains(debuff) < project.util.thresholds.buff() + 3 then
                valid = false
            end

            if priority > highest_prio then
                valid = false
            end

            if friend_with_debuff then
                if priority == highest_prio then
                    if friend.hp > friend_with_debuff.hp then
                        valid = false
                    end
                end
            end

            if valid then
                friend_with_debuff = friend
                pve_debuff = debuff
                highest_prio = priority
            end
        end
    end)

    if not friend_with_debuff then
        project.util.pve_debuffs.target = nil
        project.util.pve_debuffs.debuff = nil
        project.util.pve_debuffs.prio = nil
    end

    project.util.pve_debuffs.target = friend_with_debuff
    project.util.pve_debuffs.debuff = pve_debuff
    project.util.pve_debuffs.prio = highest_prio
end
