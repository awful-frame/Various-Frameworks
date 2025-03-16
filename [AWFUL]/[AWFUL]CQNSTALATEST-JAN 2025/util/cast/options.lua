local Unlocker, awful, project = ...

project.util.cast.options = function(extra_options)
    local cast_options = {}

    if awful.mapID == project.util.id.map.DAWNBREAKER then
        cast_options.ignoreFacing = true
    end

    if extra_options then
        for key, value in pairs(extra_options) do
            cast_options[key] = value
        end
    end

    return cast_options
end
