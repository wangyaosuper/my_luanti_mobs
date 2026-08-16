local S = pixelart.mod.translator
local privileges = pixelart.settings.privileges
local show_selector = pixelart.show_selector
local access_node = pixelart.settings.access_node
local access_node_id = pixelart.ids.access_node
local show_error = pixelart.show_error
local chat_command = pixelart.settings.chat_command


-- Optionally register a chat command
--
-- Players can directly open the selector formspec with this. It is validated
-- via Luanti API that the sufficient privileges are set for the player.
--
-- Using `/pixelart` opens the selector dialog. No further parameters are
-- needed. If the permissions are sufficient, this works in all games that do
-- not intercept chat commands or opening formspecs.
if chat_command == true then
    core.register_chatcommand('pixelart', {
        description = S('Open the pixelart selector'),
        privs = privileges,
        func = function (name, param)
            show_selector(name)
        end
    })
end


-- Optionally register an access node
--
-- Players can craft a node with the node with the `mapgen_stone` alias. This
-- node is most likely available in abundance to all players and most likely
-- is also craftable by all players.
--
-- The node can be crafted and uncrafted if players have access to the Luanti
-- default crafting inventory and its output.
--
--   x  _  x
--   x  _  _
--   _  x  _
--
-- `x` is the `mapgen_stone` node and `_` is an empty slot. And after placing
-- the node in the world, it can be rightclicked to open the selector formspec.
--
-- Being able to place and dig the node depends on the privileges set for
-- the player and what’s configured for the mod to use. With insufficient
-- privileges, the player gets an error message when trying to place or
-- dig the node.
if access_node == true then
    local fast_digging = pixelart.settings.fast_digging
    local noise_opacity = pixelart.settings.noise_opacity

    core.register_node(access_node_id, {
        description = S('Pixelart selector access'),
        use_texture_alpha = 'blend',
        drop = '',
        stack_max = 1,
        groups = {
            oddly_breakable_by_hand = 1,
            dig_immediate = fast_digging == true and 3 or 2
        },
        tiles = {
            (('((+b)^((+b)^[opacity:+o^[overlay:(+n)))'):gsub('%+%w+', {
                ['+b'] = 'pixelart_access_node.png',
                ['+o'] = noise_opacity,
                ['+n'] = 'pixelart_noise.png',
            }))
        },
        sounds = {
            place = { name = 'pixelart_plopp' },
            dig = { name = 'pixelart_plopp', pitch = 3 },
            dug = { name = 'pixelart_plopp', pitch = 0.8 },
            footstep = { name = 'pixelart_plopp', pitch=0.2, gain=0.4 },
        },
        -- Show selector on rightclick
        on_rightclick = function(pos, node, clicker)
            if not clicker:is_player() then return end
            show_selector(clicker:get_player_name())
        end,
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

    core.register_craft({
        output = access_node_id,
        recipe = {
            { 'mapgen_stone', '',             'mapgen_stone' },
            { 'mapgen_stone', '',             ''             },
            { '',             'mapgen_stone', ''             },
        },
    })

    core.register_craft({
        output = 'mapgen_stone 4',
        type = 'shapeless',
        recipe = { access_node_id },
    })
end
