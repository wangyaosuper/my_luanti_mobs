local storage = minetest.get_mod_storage()

local S = minetest.get_translator(minetest.get_current_modname())
ww1_planes_lib = {}
ww1_planes_lib.licence_name = "WW1_flight_licence"

local load_bypass_protection = storage:get_int("bypass_protection")
ww1_planes_lib.bypass_protection = false
-- 1 == true ---- 2 == false
if load_bypass_protection == 1 then ww1_planes_lib.bypass_protection = true end

local load_no_fixed_owner = storage:get_int("no_fixed_owner")
ww1_planes_lib.no_fixed_owner = false
-- 1 == true ---- 2 == false
if load_no_fixed_owner == 1 then ww1_planes_lib.no_fixed_owner = true end

dofile(minetest.get_modpath("ww1_planes_lib") .. DIR_DELIM .. "bullets.lua")
dofile(minetest.get_modpath("ww1_planes_lib") .. DIR_DELIM .. "bombs.lua")
dofile(minetest.get_modpath("ww1_planes_lib") .. DIR_DELIM .. "forms.lua") --custom form for the planes

--
-- helpers and co.
--

minetest.register_entity('ww1_planes_lib:cabin',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "ww1_planes_lib_cabin.b3d",
	textures = {"airutils_white.png", "airutils_metal.png", "airutils_black.png", "airutils_red.png", },
	},
	
    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,
	
})

--returns 0 for old, 1 for new
function ww1_planes_lib._custom_punch_when_attached(self, player)
    local ctrl = player:get_player_control()
    if ctrl.aux1 then
        local armament = "ww1_planes_lib:bomb1"
        local inv = airutils.get_inventory(self)
        if not inv then return end

        local total_taken = 0
        local stack = ItemStack(armament.." 1")
        local taken = inv:remove_item("main", stack)
        local total_taken = taken:get_count()

        if total_taken > 0 then
            airutils.save_inventory(self)
            ww1_planes_lib.spawn_bomb(self, player:get_player_name(), armament, 1)
        end
    else
        local armament = "ww1_planes_lib:bullet1"
        if self._vehicle_custom_data._ww1_loaded_bullets then
            if self._vehicle_custom_data._ww1_loaded_bullets > 0 then
                local speed = 300
                local total_bullets = self._vehicle_custom_data._ww1_loaded_bullets
                ww1_planes_lib.spawn_bullet(self, player:get_player_name(), armament, speed)
                self._vehicle_custom_data._ww1_loaded_bullets = total_bullets - 1

                minetest.after(0.1, function()
                    if player then
                        ww1_planes_lib.spawn_bullet(self, player:get_player_name(), armament, speed)
                        self._vehicle_custom_data._ww1_loaded_bullets = total_bullets - 2
                    end
                end)
            end
        end
    end
end

ww1_planes_lib.register_bullet("ww1_planes_lib:bullet1", "ww1_planes_bullet_ico.png", "ww1_planes_box_texture.png", "Plane bullet", 8, 300)

--ww1_planes_lib.register_bomb(radius, ent_name, inv_image, bomb_texture, description, bomb_max_stack) 
ww1_planes_lib.register_bomb(3, "ww1_planes_lib:bomb1", "ww1_planes_lib_bomb.png", "ww1_planes_lib_bomb.png", "A bomb to drop over the enemy field", 5) 

minetest.register_craft({
	output = "ww1_planes_lib:bullet1 50",
	recipe = {
		{"default:bronze_ingot", "default:bronze_ingot", "default:bronze_ingot"},
		{"default:bronze_ingot", "tnt:gunpowder", "default:bronze_ingot"},
		{"default:bronze_ingot", "tnt:gunpowder", "default:bronze_ingot"},
	}
})

minetest.register_privilege("WW1_flight_licence", {
    description = "Gives a flight licence to the player",
    give_to_singleplayer = true
})

minetest.register_chatcommand("damage_bypass_protection", {
	params = "<true/false>",
	description = "Set enable/disable damage to non protected nodes.",
	privs = {server = true},
    func = function(name, param)
        local command = param

        if command == "false" then
            ww1_planes_lib.bypass_protection = false
            minetest.chat_send_player(name, ">>> Environment damage is disabled")
        else
            ww1_planes_lib.bypass_protection = true
            minetest.chat_send_player(name, ">>> Environment damage is enabled")
        end
        local save = 2
        if ww1_planes_lib.bypass_protection == true then save = 1 end
        storage:set_int("bypass_protection", save)
    end,
})

--agora ninguém é de ninguém mané!!!!
minetest.register_chatcommand("no_fixed_owner", {
	params = "<true/false>",
	description = "Enable/disable the ownership revocation for the fighters. Anyone can get any plane when activated.",
	privs = {server = true},
    func = function(name, param)
        local command = param

        if command == "false" then
            ww1_planes_lib.no_fixed_owner = false
            minetest.chat_send_player(name, ">>> No Owner mode is disabled")
        else
            ww1_planes_lib.no_fixed_owner = true
            minetest.chat_send_player(name, ">>> No Owner mode is enabled")
        end
        local save = 2
        if ww1_planes_lib.no_fixed_owner == true then save = 1 end
        storage:set_int("no_fixed_owner", save)
    end,
})

--[[minetest.register_chatcommand("ww1_plane_manual", {
	params = "",
	description = "Planes operation manual",
	privs = {interact = true},
	func = function(name, param)
        lib_planes.manual_formspec(name)
	end
})]]--

local function give_starter_kit(player)
    local inv = player:get_inventory()
    if not inv then return end

    local player_name = player:get_player_name()

    local privs = minetest.get_player_privs(player_name)
    privs["WW1_flight_licence"] = true
    minetest.set_player_privs(player_name, privs)

    local storage_key = "starter_given_" .. player_name
    if storage:get_int(storage_key) == 1 then
        return
    end

    local items_to_give = {
        {"sopwith_f1_camel:sopwith_f1_camel", 5},
        {"albatros_d5:albatros_d5", 5},
        {"ww1_planes_lib:bullet1", 600},
        {"ww1_planes_lib:bomb1", 100},
    }

    if minetest.registered_items["biofuel:biofuel"] then
        table.insert(items_to_give, {"biofuel:biofuel", 100})
    end

    for _, item_def in ipairs(items_to_give) do
        local item_name, count = item_def[1], item_def[2]
        if minetest.registered_items[item_name] then
            local stack = ItemStack(item_name .. " " .. tostring(count))
            if inv:room_for_item("main", stack) then
                inv:add_item("main", stack)
            else
                local remaining = count
                while remaining > 0 do
                    local def = minetest.registered_items[item_name]
                    local stack_max = def and def.stack_max or 99
                    local give_count = math.min(remaining, stack_max)
                    local partial = ItemStack(item_name .. " " .. tostring(give_count))
                    if inv:room_for_item("main", partial) then
                        inv:add_item("main", partial)
                    else
                        local pos = player:get_pos()
                        minetest.add_item(pos, partial)
                    end
                    remaining = remaining - give_count
                end
            end
        end
    end

    storage:set_int(storage_key, 1)
    minetest.chat_send_player(player_name, ">>> WW1 Planes Starter Kit: You got all planes, bullets, bombs and fuel!")
end

minetest.register_on_newplayer(function(player)
    give_starter_kit(player)
end)

minetest.register_on_joinplayer(function(player)
    give_starter_kit(player)
end)


