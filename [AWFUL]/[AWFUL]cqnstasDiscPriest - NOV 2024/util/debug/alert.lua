local Unlocker, awful, project = ...

local function debug_print(msg)
    if not msg then
        return
    end

    if type(msg) == "boolean" then
        return
    end

    print(awful.colors.red .. "[CQNSTA'S ROTATIONS] " .. msg)
end

local last_info_msg = ""
project.util.debug.alert.info = function(msg)
    if not awful.DevMode then
        return true
    end

    if project.settings.debug_alerts_enabled and project.settings.debug_alerts["INFO"] then
        awful.alert(awful.colors.white .. msg)
        if project.settings.debug_alerts_print and last_info_msg ~= msg then
            print(awful.colors.white .. msg)
            last_info_msg = msg
        end
    end

    return true
end

local last_alert_msg = ""
project.util.debug.alert.attack = function(msg, txt)
    if not awful.DevMode then
        return true
    end

    if project.settings.debug_alerts_enabled and project.settings.debug_alerts["ATTACK"] then
        awful.alert(awful.colors.red .. msg, txt)
        if project.settings.debug_alerts_print and last_alert_msg ~= msg then
            debug_print(awful.colors.red .. msg)
            last_alert_msg = msg
        end
    end

    return true
end

local last_heal_msg = ""
project.util.debug.alert.heal = function(msg, txt)
    if not awful.DevMode then
        return true
    end

    if project.settings.debug_alerts_enabled and project.settings.debug_alerts["HEAL"] then
        awful.alert(awful.colors.green .. msg, txt)
        if project.settings.debug_alerts_print and last_heal_msg ~= msg then
            debug_print(awful.colors.green .. msg)
            last_heal_msg = msg
        end
    end

    return true
end

local last_beneficial_msg = ""
project.util.debug.alert.beneficial = function(msg, txt)
    if not awful.DevMode then
        return true
    end


    if project.settings.debug_alerts_enabled and project.settings.debug_alerts["BENEFICIAL"] then
        awful.alert(awful.colors.yellow .. msg, txt)
        if project.settings.debug_alerts_print and last_beneficial_msg ~= msg then
            debug_print(awful.colors.yellow .. msg)
            last_beneficial_msg = msg
        end
    end

    return true
end

local last_defensive_msg = ""
project.util.debug.alert.defensive = function(msg, txt)
    if not awful.DevMode then
        return true
    end

    if project.settings.debug_alerts_enabled and project.settings.debug_alerts["DEFENSIVE"] then
        awful.alert(awful.colors.evoker .. msg, txt)
        if project.settings.debug_alerts_print and last_defensive_msg ~= msg then
            debug_print(awful.colors.evoker .. msg)
            last_defensive_msg = msg
        end
    end

    return true
end

local last_offensive_msg = ""
project.util.debug.alert.offensive = function(msg, txt)
    if not awful.DevMode then
        return true
    end

    if project.settings.debug_alerts_enabled and project.settings.debug_alerts["OFFENSIVE"] then
        awful.alert(awful.colors.druid .. msg, txt)
        if project.settings.debug_alerts_print and last_offensive_msg ~= msg then
            debug_print(awful.colors.druid .. msg)
            last_offensive_msg = msg
        end
    end

    return true
end

local last_evade_msg = ""
project.util.debug.alert.evade = function(msg, txt)
    if not awful.DevMode then
        return true
    end


    if project.settings.debug_alerts_enabled and project.settings.debug_alerts["EVADE"] then
        awful.alert(awful.colors.dh .. msg, txt)
        if project.settings.debug_alerts_print and last_evade_msg ~= msg then
            debug_print(awful.colors.dh .. msg)
            last_evade_msg = msg
        end
    end

    return true
end

local last_dispel_msg = ""
project.util.debug.alert.dispel = function(msg, txt)
    if not awful.DevMode then
        return true
    end

    if project.settings.debug_alerts_enabled and project.settings.debug_alerts["DISPEL"] then
        awful.alert(awful.colors.blue .. msg, txt)
        if project.settings.debug_alerts_print and last_dispel_msg ~= msg then
            debug_print(awful.colors.blue .. msg)
            last_dispel_msg = msg
        end
    end

    return true
end

local last_cc_msg = ""
project.util.debug.alert.cc = function(msg, txt)
    if not awful.DevMode then
        return true
    end

    if project.settings.debug_alerts_enabled and project.settings.debug_alerts["CC"] then
        awful.alert(awful.colors.pink .. msg, txt)
        if project.settings.debug_alerts_print and last_cc_msg ~= msg then
            debug_print(awful.colors.pink .. msg)
            last_cc_msg = msg
        end
    end

    return true
end

project.util.debug.alert.cd = function(msg, txt)
    if not awful.DevMode then
        return true
    end

    if project.settings.debug_alerts_enabled and project.settings.debug_alerts["CD"] then
        awful.alert(awful.colors.monk .. msg, txt)
    end

    return true
end
