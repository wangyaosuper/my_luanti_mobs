local esc = core.formspec_escape
local S,NS = core.get_translator(pixelart.mod.name)
local palettes = pixelart.palettes.registered
local ordered_ids = pixelart.palettes.ordered_ids
local privileges = pixelart.settings.privileges
local selector_id = pixelart.ids.selector
local show_error = pixelart.show_error
local palette_meta = pixelart.ids.palette_meta
local modname = pixelart.mod.name


-- Return palette meta data as formspec string
--
-- The palette data is taken from the provided palette table. All user-provided
-- data and translations are formspec-escaped.
--
-- @param palette Palette table
--
-- @return string Formatted metadata as usable formspec string
local get_palette_meta = function (palette)
    if type(palette) ~= 'table' then return end

    local count = 0
    local description = palette.description
    local curator = palette.curator

    for _,PixelSpec in pairs(palette.pixels) do
        if string.sub(PixelSpec.color, 1, 1) == '#' then
            count = count + 1
        end
    end

    local meta = (table.concat({
        palette.builtin
            and S('This built-in palette')
            or S('This world-specific palette'),
        curator  and S('was curated by @1 and', curator) or '',
        NS('provides @1 pixel.', 'provides @1 pixels.', count, count)
    }, ' ')):gsub('  ', ' ')


    local result = {
        'style_type[label;font=bold]',
        'label[0.25,0.40;'..esc(S('Current palette: @1', description))..']',
        'style_type[label;font=italic;font_size=*0.8]',
        'label[0.25,0.70;'..esc(meta)..']',
    }

    return table.concat(result, ' ')
end


-- Return buttons for all palettes
--
-- The ordered IDs of all registered valid palettes are used to create the
-- palette buttons. All names and descriptions are formspec-escaped.
--
-- @return string Generated palette buttons as usable formspec string
local get_palette_buttons = function (current_palette)
    local result = {}
    local buttonCount = 0

    for _,id in pairs(ordered_ids) do
        local button = ('button[0,+pos;4.5,0.5;+id;+name]'):gsub('%+%w+', {
            ['+pos'] = buttonCount * 0.75,
            ['+id'] = 'switch_to_palette_'..id,
            ['+name'] = esc(palettes[id].name),
        })

        local tooltip = ('tooltip[+id;+text]'):gsub('%+%w+', {
            ['+id'] = 'switch_to_palette_'..id,
            ['+text'] = esc(palettes[id].description)
        })

        if id == current_palette then
            button = 'style[switch_to_palette_'..id..';font=bold]'..button
        end

        buttonCount = buttonCount + 1
        table.insert(result, tooltip..' '..button)
    end

    return table.concat(result, ' ')
end


-- Create a palette’s pixel nodes buttons
--
-- The provided palette’s pixels are used to generate the set of pixel node
-- buttons for that palette. The Pixel nodes are shown as item buttons in
-- the formspec and are properly aligned, sized, and spaced to fit into the
-- designated scroll container in the formspec.
--
-- @param palette The palette to use
-- @return string The palette’s pixel node buttons as usable formspec string
local get_pixel_nodes = function (palette)
    local result = {}
    local palette_id = (palette or {}).id or ''
    local button_template = 'item_image_button[+x,+y;+s,+s;+id;+fid;]'

    local size = 0.8
    local space = 0.16

    local maxX = 14
    local posX = 0
    local posY = 0

    for _,PixelSpec in pairs((palette or {}).pixels or {}) do
        local color = PixelSpec.color:gsub('#', ''):lower()
        local node_id = modname..':'..palette_id..'_'..color
        local entry = string.sub(PixelSpec.color, 1, 1)
        local button = ''

        if entry == '#' then
            -- It’s a regular pixel, define the button and advance the
            -- horizontal position by 1
            button = button_template:gsub('%+%w+',{
                ['+s'] = size,
                ['+x'] = (posX * size) + (posX * space),
                ['+y'] = (posY * size) + (posY * space),
                ['+id'] = node_id,
                ['+fid'] = 'get_pixel_'..node_id,
            })
            posX = posX + 1
        elseif entry == 's' then
            -- It’s a space! Advance horizontal position by one.
            posX = posX + 1
        elseif entry == 'n' then
            -- It’s a newline! Advance vertical position by one and reset the
            -- horizontal position back to the beginning of the line.
            posX = 0
            posY = posY + 1
        end

        -- Automatically wrap to a new line if the horizontal
        -- position reached its maximum.
        if posX == maxX then
            posX = 0
            posY = posY + 1
        end

        table.insert(result, button)
    end

    return table.concat(result, ' ')
end


-- Show the selector formspec to the given player
--
-- The function validates if the player has the sufficient privileges and if
-- the palette contains any pixels. If both is the case, the dialog opens.
--
-- When the privileges are not sufficient, an error message is shown. In case
-- the requested palette does not exist (anymore/yet), the first registered
-- palette is used instead. If there are no palettes registered, an error
-- message is shown instead.
--
-- @pparam playername Name of the player to show the selector formspec to.
pixelart.show_selector = function (playername)
    local player = core.get_player_by_name(playername)
    if not player then return end

    local allowed, missing_privs = core.check_player_privs(player, privileges)
    local player_palette = palettes[player:get_meta():get(palette_meta)]
    local current_palette = player_palette or palettes[ordered_ids[1]]

    -- Check for sufficient privileges
    if not allowed then
        show_error(playername, 'privs', missing_privs)
        return
    end

    -- Fetch and validate the current palette
    if current_palette == nil then
        show_error(playername, S('No palettes available!'),
            S('The mod was loaded but due to configuration or errors there '..
                'are no palettes available.')..'\n\n'..
            S('If you’re in singleplayer mode, you need to validate your '..
                'configuration. If you’re on a server, please refer to the '..
                'server’s rules and contact an administrator or a moderator '..
                'for further information.')
        )
        return
    end

    local selector = (table.concat({
        'formspec_version[10]',
        'size[20,11]',
        'bgcolor[#2e3436;false;]',

        -- Palettes
        'container[0.25,0.25]',
        '  box[0,0;5,9.25;+color]',
        '  scrollbar[5,0;0.25,9.25;vertical;palettes;]',
        '  scroll_container[0.25,0.25;4.5,8.75;palettes;vertical;;0.25]',
        '    +paletteButtons',
        '  scroll_container_end[]',
        'container_end[]',

        -- Current palette’s information
        'container[5.75,0.25]',
        '  box[0,0;14,1;+color]',
        '  +paletteMeta',
        'container_end[]',

        -- Current palette’s pixels
        'container[5.75,1.5]',
        '  box[0,0;13.75,8;+color]',
        '  scrollbar[13.75,0;0.25,8;vertical;current;]',
        '  scroll_container[0.25,0.25;13.26,7.5;current;vertical;;0]',
        '    +pixelNodes',
        '  scroll_container_end[]',
        'container_end[]',

        -- Navigation
        'container[0.25,9.75]',
        '  box[0,0;19.5,1;+color]',
        '  button_exit[0.25,0.25;2.5,0.5;close;+close]',
        '  hypertext[2.75,0.375;16.5,0.5;meta;<right>+registeredData</right>]',
        'container_end[]'

    }, ' ')):gsub('%+%w+', {
        ['+color'] = '#888a8550',
        ['+close'] = esc(S('Close')),
        ['+paletteButtons'] = get_palette_buttons(current_palette.id),
        ['+pixelNodes'] = get_pixel_nodes(current_palette),
        ['+paletteMeta'] = get_palette_meta(current_palette),
        ['+registeredData'] = NS(
            'There is @1 palette available.',
            'In total there are @1 palettes available.',
            #ordered_ids, #ordered_ids
        )
    })

    core.show_formspec(playername, selector_id, selector)
end
