local modname = pixelart.mod.name
local registered_palettes = pixelart.palettes.registered
local fast_digging = pixelart.settings.fast_digging
local noise_opacity = pixelart.settings.noise_opacity
local max_pixels_setting = pixelart.settings.max_pixels
local privileges = pixelart.settings.privileges
local hide_nodes = pixelart.settings.hide_nodes
local show_error = pixelart.show_error
local S = pixelart.mod.translator


-- Register pixel nodes
--
-- The nodes have the needed definition to only be usable with the configured
-- privileges. Without the privileges, all of the nodes are non-interactive.
-- Players cannot dig them or place them.
--
-- By default the `interact` privilege is used which makes this feature
-- redundant without any further configuration, but other mods or games could
-- add additional privileges, so the player can interact normally, but don’t
-- have access to the pixel nodes.
--
-- @param color        Hexadecimal RGB color value (`#rrggbb`)
-- @param name         String that is used as name for the pixel node
-- @param palette_id   Palette origin ID of this color
-- @param palette_name Palette origin name of this color
local node_registration = function (PixelSpec, palette_id, palette_name)
    local color = PixelSpec.color
    local name = PixelSpec.name
    local node_id = modname..':'..palette_id..'_'..color:gsub('#', '')
    local tile_base = '(+b^[colorize:+c)^((+n^[multiply:+c)^[opacity:+o)'
    local node_name = name..'\n'..S('Palette: @1', palette_name)

    core.register_node(node_id:lower(), {
        description = node_name,
        use_texture_alpha = 'blend',
        drop = '',
        stack_max = 1,
        groups = {
            oddly_breakable_by_hand = 1,
            dig_immediate = fast_digging == true and 3 or 2,
            not_in_creative_inventory = hide_nodes == true and 1 or 0,
            pixelart_pixel_node = 1,
            ['pixelart_palette_'..palette_id] = 1
        },
        tiles = {
            (tile_base:gsub('%+%w', {
                ['+b'] = 'pixelart_base.png',
                ['+n'] = 'pixelart_noise.png',
                ['+c'] = color,
                ['+o'] = noise_opacity
            }))
        },
        sounds = {
            place = { name = 'pixelart_plopp' },
            dig = { name = 'pixelart_plopp', pitch = 3 },
            dug = { name = 'pixelart_plopp', pitch = 0.7 },
            footstep = { name = 'pixelart_plopp', pitch=0.2 },
        },
        -- Do not remove node when placing
        after_place_node = function () return true end,
        -- Prevent placing without sufficient privileges
        on_place = function (itemstack, placer, pointed_thing)
            if not placer:is_player() then return end
            local allowed,p = core.check_player_privs(placer, privileges)
            if not allowed then
                show_error(placer:get_player_name(), 'privs', p)
                return
            end
            core.item_place(itemstack, placer, pointed_thing)
        end,
        -- Prevent digging without sufficient privileges
        on_dig = function(pos, node, digger)
            if not digger:is_player() then return end
            local allowed,p = core.check_player_privs(digger, privileges)
            if not allowed then
                show_error(digger:get_player_name(), 'privs', p)
                return false
            end
            core.node_dig(pos, node, digger)
        end
    })
end


-- Register pixel nodes from palettes
--
-- This iteration uses the registered palettes to create the nodes. The nodes
-- always have the same syntax for the ID: `pixelart:palette_color` where
-- `palette` is the palette’s ID, and `color` being the lowercase HEX code
-- for the color without the `#`.
--
-- If a palette results in registering more as – by default – 128 nodes, a
-- warning message is logged and the current palette is not loaded any furhter
-- to limit the possibility of an overflow of the internal Luanti node IDs.
--
-- @see https://github.com/luanti-org/luanti/issues/6101
-- @see node_registration()
for palette_id,palette in pairs(registered_palettes) do
    local amount = 0
    local builtin = palette.builtin
    local max_pixels = builtin == true and 128 or max_pixels_setting

    for _,PixelSpec in pairs(palette.pixels) do
        -- Register node if color is `#rrggbb`, this excludes registration
        -- attempts for newlines and spaces in the palette.
        if string.sub(PixelSpec.color, 1, 1) == '#' then
            amount = amount + 1
            node_registration(PixelSpec, palette_id, palette.name)
        end

        if amount > max_pixels then
            core.log('warning', table.concat({
                '[pixelart]',
                'Registering more than', max_pixels, 'pixels is unsupported!',
                '(Offending palette ID: '..palette_id..')',
                'Please', builtin == true
                    and 'contact the mod author about this!'
                    or 'check your world-specific configuration and/or palette!'
            }, ' '))
            amount = 0
            break
        end
    end
end
