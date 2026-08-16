local S = pixelart.mod.translator
local privileges = pixelart.mod.privileges
local selector_id = pixelart.ids.selector
local palette_meta = pixelart.ids.palette_meta
local show_selector = pixelart.show_selector
local msg = core.chat_send_player


core.register_on_player_receive_fields(function(player, formname, fields)
    if not player:is_player() then return end
    if formname ~= selector_id then return end

    local playername = player:get_player_name()
    local allowed, missing_privs = core.check_player_privs(player, privileges)

    -- If the player has insufficient permissions, send them a chat message
    -- informing them about this, except when the player exits the formspec.
    --
    -- Ideally this should never trigger, because the formspec itself already
    -- checks the permissions. If the player somehow manages to send fields
    -- under the mod’s formspec ID, this should prevent anything unwanted
    -- from happening.
    if not allowed and not fields.quit then
        msg(playername, table.concat({
            S('You do not have the sufficient privileges for this!'),
            S('Missing Privileges: @1', table.concat(missing_privs, ', '))
        }, ' '))
        return
    end

    -- Set palette or return pixel when a player interacts with the selector
    -- formspec. At this point the player is validated (is a player and has
    -- the needed privileges).
    --
    -- Switching the palette just writes the palette ID as meta data and then
    -- re-shows the selector formspec. The selector formspec loading code
    -- automatically validates and sets the palette to display.
    --
    -- Getting pixel nodes first checks if there is room for that node in the
    -- player’s inventory (`main` inventory list) and then adds the node to
    -- that inventory. If there is no space left, an error message is written
    -- to the plauer in the chat.
    for field,_ in pairs(fields) do
        if string.sub(field,1,18) == 'switch_to_palette_' then
            local palette = field:gsub('switch_to_palette_', '')
            local meta = player:get_meta()
            meta:set_string(palette_meta, palette)
            show_selector(playername)
        elseif string.sub(field,1,10) == 'get_pixel_' then
            local meta = player:get_meta()
            local inv = player:get_inventory()
            local node_id = field:gsub('get_pixel_', '')
            if inv:room_for_item('main', node_id) then
                inv:add_item('main', node_id)
            else
                msg(playername, S('Not enough room for this pixel!'))
            end
        end
    end
end)
