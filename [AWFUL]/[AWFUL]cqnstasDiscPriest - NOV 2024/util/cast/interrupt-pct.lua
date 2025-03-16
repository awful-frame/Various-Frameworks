local Unlocker, awful, project = ...

local last_casts_pct_list = {}
local last_cast_pct
local interrupt_cooldown = 0

project.util.cast.interrupt_pct_avg = 50

project.util.cast.interrupt_pct = function()
    if interrupt_cooldown > awful.time then
        return
    end

    if awful.player.casting then
        last_cast_pct = awful.player.castPct
    end

    if awful.player.lockouts.holy or awful.player.lockouts.shadow then
        if last_cast_pct and last_cast_pct < 95 and last_cast_pct > 20 then
            table.insert(last_casts_pct_list, last_cast_pct)
            last_cast_pct = nil
            interrupt_cooldown = awful.time + 5
        end
    end

    if #last_casts_pct_list > 0 then
        local total = 0
        for _, pct in ipairs(last_casts_pct_list) do
            total = total + pct
        end
        project.util.cast.interrupt_pct_avg = total / #last_casts_pct_list
    else
        project.util.cast.interrupt_pct_avg = 50
    end
end

project.util.cast.interrupt_pct_reset = function()
    last_casts_pct_list = {}
    last_cast_pct = nil
    project.util.cast.interrupt_pct_avg = 50
    interrupt_cooldown = 0
end

project.util.cast.print_last_casts_pct = function()
    if #last_casts_pct_list == 0 then
        return
    end

    print("Last Cast Percentages:")
    for index, pct in ipairs(last_casts_pct_list) do
        print(string.format("Cast %d: %.2f%%", index, pct))
    end
    print(string.format("Average Interrupt Percentage: %.2f%%", project.util.cast.interrupt_pct_avg))
end

awful.onEvent(project.util.cast.interrupt_pct_reset, "ARENA_PREP_OPPONENT_SPECIALIZATIONS")
awful.onEvent(project.util.cast.interrupt_pct_reset, "PLAYER_ENTERING_WORLD")
awful.onEvent(project.util.cast.interrupt_pct_reset, "PLAYER_LEAVING_WORLD")
