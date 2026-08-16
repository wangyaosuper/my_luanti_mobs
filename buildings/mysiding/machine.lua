local material = {}
local shape = {}
local make_ok = {}
local anzahl = {}

core.register_node("mysiding:machine2", {
--	description = "Siding Machine 2",
	tiles = {
		"mysiding_right_top.png",
		"mysiding_right_bottom.png",
		"mysiding_right_side.png",
		"mysiding_left_side.png",
		"mysiding_right_back.png",
		"mysiding_right_front.png"
		},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2},
	drop = "mysiding:machine",
	node_box = {
		type = "fixed",
		fixed = {
			{0.3125, -0.5, 0.3125, 0.5, 0.125, 0.5},
			{0.3125, -0.5, -0.5, 0.5, 0.125, -0.3125}, 
			{-0.5, -0.25, -0.5, 0.5, 0.25, 0.5}, 
			{-0.5, 0.25, 0.1875, 0.5, 0.5, 0.3125}, 
			{-0.5, 0.25, -0.25, -0.4375, 0.3125, 0.1875}, 
		}
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{0, 0, 0, 0.0625, 0.0625, 0.0625},
		}
	},

after_destruct = function(pos)
	if core.get_node({x=pos.x + 1, y=pos.y, z=pos.z}).name == "mysiding:machine" then
      core.set_node({x=pos.x + 1, y=pos.y, z=pos.z}, {name="air"})
	end
	if core.get_node({x=pos.x - 1, y=pos.y, z=pos.z}).name == "mysiding:machine" then
      core.set_node({x=pos.x - 1, y=pos.y, z=pos.z}, {name="air"})
	end
	if core.get_node({x=pos.x, y=pos.y, z=pos.z + 1}).name == "mysiding:machine" then
      core.set_node({x=pos.x, y=pos.y, z=pos.z + 1}, {name="air"})
	end
	if core.get_node({x=pos.x, y=pos.y, z=pos.z - 1}).name == "mysiding:machine" then
      core.set_node({x=pos.x, y=pos.y, z=pos.z - 1}, {name="air"})
	end
end,
})

core.register_node("mysiding:machine", {
	description = "Siding Machine",
	tiles = {
		"mysiding_left_top.png",
		"mysiding_left_bottom.png",
		"mysiding_right_side.png",
		"mysiding_left_side.png",
		"mysiding_left_back.png",
		"mysiding_left_front.png"
		},
	drawtype = "nodebox",
	inventory_image = "mysiding_mach_inv.png",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.3125, -0.3125, 0.125, 0.5}, 
			{-0.5, -0.5, -0.5, -0.3125, 0.125, -0.3125}, 
			{-0.5, -0.25, -0.5, 0.5, 0.25, 0.5}, 
			{-0.5, 0.25, 0.1875, 0.5, 0.5, 0.3125}, 
			{0.4375, 0.25, -0.25, 0.5, 0.3125, 0.1875}, 
		}
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,-0.5,1.5,0.25,0.5}

		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,-0.5,1.5,0.25,0.5}

		}
	},


after_place_node = function(pos, placer)
      local dir = placer:get_look_dir()
      local right_pos = vector.new(pos)
      if math.abs(dir.x) < math.abs(dir.z) then
         right_pos.x = right_pos.x+dir.z/math.abs(dir.z)
      else
         right_pos.z = right_pos.z-dir.x/math.abs(dir.x)
      end
      local right_node = core.get_node(right_pos)
	if right_node.name == "air" then
      core.set_node(right_pos, {name="mysiding:machine2",param2 = core.dir_to_facedir(placer:get_look_dir())})
	end

local meta = core.get_meta(pos);
	meta:set_string("owner",  (placer:get_player_name() or ""));
	meta:set_string("infotext",  "Siding Machine (owned by " .. (placer:get_player_name() or "") .. ")");
	
	local inv = meta:get_inventory()
	if not inv:is_empty("ingot") then
		return false
	elseif not inv:is_empty("res") then
		return false
	end
	return true
end,

can_dig = function(pos,player)
	local meta = core.get_meta(pos);
	local inv = meta:get_inventory()
	if player:get_player_name() == meta:get_string("owner") and
	inv:is_empty("ingot") and
	inv:is_empty("res") then
		return true
	else
	return false
	end
end,

on_construct = function(pos)
		
	local meta = core.get_meta(pos)
	meta:set_string("formspec", "invsize[10,11;]"..
		"background[-0.15,-0.25;10.40,11.75;mysiding_background.png]"..
		"list[current_name;ingot;7,2;1,1;]"..
		"list[current_name;res;7,4;1,1;]"..
		"label[7,1.5;Input:]"..
		"label[7,3.5;Output:]"..
		
		"label[0,0;Choose Siding Stye:]"..
		
		"label[1,0.5;  Wide Siding]"..
		"image_button[1.5,1;1,1;mysiding_mach1.png;wide; ]"..
		
		"label[3.5,0.5; Narrow Siding]"..
		"image_button[4,1;1,1;mysiding_mach2.png;narrow; ]"..
		
		"label[1,2;Wide Corner Siding]"..
		"image_button[1.5,2.5;1,1;mysiding_mach3.png;widecorner; ]"..
		
		"label[3.5,2;Narrow Corner Siding]"..
		"image_button[4,2.5;1,1;mysiding_mach4.png;narrowcorner; ]"..
		--------------------------------------------
		
		"label[1,3.5;  Wide Siding]"..
		"image_button[1.5,4;1,1;mysiding_mach5.png;widelight; ]"..
		
		"label[3.5,3.5; Narrow Siding]"..
		"image_button[4,4;1,1;mysiding_mach6.png;narrowlight; ]"..
		
		"label[1,5;Wide Corner Siding]"..
		"image_button[1.5,5.5;1,1;mysiding_mach7.png;widecornerlight; ]"..
		
		"label[3.5,5;Narrow Corner Siding]"..
		"image_button[4,5.5;1,1;mysiding_mach8.png;narrowcornerlight; ]"..
		
		"list[current_player;main;1,7;8,4;]")
	meta:set_string("infotext", "Siding Machine")
	local inv = meta:get_inventory()
	inv:set_size("ingot", 1)
	inv:set_size("res", 1)
end,

on_receive_fields = function(pos, formname, fields, sender)
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()

if fields["wide"] 
or fields["narrow"]
or fields["widecorner"]
or fields["narrowcorner"]
or fields["widelight"] 
or fields["narrowlight"]
or fields["widecornerlight"]
or fields["narrowcornerlight"]
then

	if fields["wide"] then
		make_ok = "0"
		anzahl = "1"
		shape = "mysiding:wide_"
		if inv:is_empty("ingot") then
			return
		end
	end

	if fields["narrow"] then
		make_ok = "0"
		anzahl = "1"
		shape = "mysiding:narrow_"
		if inv:is_empty("ingot") then
			return
		end
	end

	if fields["widecorner"] then
		make_ok = "0"
		anzahl = "1"
		shape = "mysiding:wide_corner_"
		if inv:is_empty("ingot") then
			return
		end
	end

	if fields["narrowcorner"] then
		make_ok = "0"
		anzahl = "1"
		shape = "mysiding:narrow_corner_"
		if inv:is_empty("ingot") then
			return
		end
	end
----------------------------------------------------------------------------------
	if fields["widelight"] then
		make_ok = "0"
		anzahl = "1"
		shape = "mysiding:light_wide_"
		if inv:is_empty("ingot") then
			return
		end
	end

	if fields["narrowlight"] then
		make_ok = "0"
		anzahl = "1"
		shape = "mysiding:light_narrow_"
		if inv:is_empty("ingot") then
			return
		end
	end

	if fields["widecornerlight"] then
		make_ok = "0"
		anzahl = "1"
		shape = "mysiding:light_wide_corner_"
		if inv:is_empty("ingot") then
			return
		end
	end

	if fields["narrowcornerlight"] then
		make_ok = "0"
		anzahl = "1"
		shape = "mysiding:light_narrow_corner_"
		if inv:is_empty("ingot") then
			return
		end
	end
	
----------------------------------------------------------------------------------
		local ingotstack = inv:get_stack("ingot", 1)
		local resstack = inv:get_stack("res", 1)
----------------------------------------------------------------------------------
--register nodes here
----------------------------------------------------------------------------------
		local mat_table = {
						{"default:sandstone",		"default_sandstone"},
						{"default:clay",			"default_clay"},
						{"default:desert_stone",	"default_desert_stone"},
						{"default:desert_sandstone","default_desert_sandstone"},
						{"default:silver_sandstone","default_silver_sandstone"},
						{"default:cobble",			"default_cobble"},
						{"default:stone",			"default_stone"},
						{"default:wood",			"default_wood"},
						{"default:pine_wood",		"default_pine_wood"},
						{"default:aspen_wood",		"default_aspen_wood"},
						{"default:acacia_wood",		"default_acacia_wood"},
						{"default:dirt",			"default_dirt"},
						{"default:desert_cobble",	"default_desert_cobble"},
						{"default:gravel",			"default_gravel"},
						{"default:junglewood",		"default_junglewood"},
						{"default:mossycobble",		"default_mossycobble"},
						{"farming:straw",			"farming_straw"},
						--Wool
						{"wool:white",				"wool_white"},
						{"wool:black",				"wool_black"},
						{"wool:blue",				"wool_blue"},
						{"wool:brown",				"wool_brown"},
						{"wool:cyan",				"wool_cyan"},
						{"wool:dark_green",			"wool_cyan"},
						{"wool:dark_grey",			"wool_dark_grey"},
						{"wool:green",				"wool_green"},
						{"wool:grey",				"wool_grey"},
						{"wool:magenta",			"wool_magenta"},
						{"wool:orange",				"wool_orange"},
						{"wool:pink",				"wool_pink"},
						{"wool:red",				"wool_red"},
						{"wool:violet",				"wool_violet"},
						{"wool:yellow",				"wool_yellow"},
						--myores
						{"myores:slate",			"slate"},
						{"myores:shale",			"shale"},
						{"myores:schist",			"schist"},
						{"myores:gneiss",			"gneiss"},
						{"myores:basalt",			"basalt"},
						{"myores:granite",			"granite"},
						{"myores:marble",			"marble"},
						{"myores:chromium",			"chromium"},
						{"myores:manganese",		"manganese"},
						{"myores:quartz",			"quartz"},
						{"myores:chalcopyrite",		"chalcopyrite"},
						{"myores:cobalt",			"cobalt"},
						{"myores:uvarovite",		"uvarovite"},
						{"myores:selenite",			"selenite"},
						{"myores:miserite",			"miserite"},
						{"myores:limonite",			"limonite"},
						{"myores:sulfur",			"sulfur"},
						{"myores:lapis_lazuli",		"lapis_lazuli"},
						{"myores:emerald",			"emerald"},
						{"myores:amethyst",			"amethyst"},
						
						{"mywhiteblock:block_black",    "block_black"},
						{"mywhiteblock:block_blue",     "block_blue"},
						{"mywhiteblock:block_brown",    "block_brown"},
						{"mywhiteblock:block_cyan",     "block_cyan"},
						{"mywhiteblock:block_darkgreen","block_darkgreen"},
						{"mywhiteblock:block_darkgrey", "block_darkgrey"},
						{"mywhiteblock:block_green",    "block_green"},
						{"mywhiteblock:block_grey",     "block_grey"},
						{"mywhiteblock:block_magenta",  "block_magenta"},
						{"mywhiteblock:block_orange",   "block_orange"},
						{"mywhiteblock:block_pink",     "block_pink"},
						{"mywhiteblock:block_red",      "block_red"},
						{"mywhiteblock:block_violet",   "block_violet"},
						{"mywhiteblock:block_white",    "block_white"},
						{"mywhiteblock:block_yellow",   "block_yellow"},
						{"mywhiteblock:block",			"block"},
						}

		for i in ipairs(mat_table) do
			local items = mat_table[i][1]
			local mater = mat_table[i][2]
			
			if ingotstack:get_name()== items then
				material = mater
				make_ok = "1"
			end
		end
----------------------------------------------------------------------
		if make_ok == "1" then
			local give = {}
			for i = 0, anzahl-1 do
				give[i+1]=inv:add_item("res",shape..material)
			end
			ingotstack:take_item()
			inv:set_stack("ingot",1,ingotstack)
		end            

end	
end,

after_destruct = function(pos)
	if core.get_node({x=pos.x + 1, y=pos.y, z=pos.z}).name == "mysiding:machine2" then
      core.set_node({x=pos.x + 1, y=pos.y, z=pos.z}, {name="air"})
	end
	if core.get_node({x=pos.x - 1, y=pos.y, z=pos.z}).name == "mysiding:machine2" then
      core.set_node({x=pos.x - 1, y=pos.y, z=pos.z}, {name="air"})
	end
	if core.get_node({x=pos.x, y=pos.y, z=pos.z+ 1}).name == "mysiding:machine2" then
      core.set_node({x=pos.x, y=pos.y, z=pos.z + 1}, {name="air"})
	end
	if core.get_node({x=pos.x, y=pos.y, z=pos.z - 1}).name == "mysiding:machine2" then
      core.set_node({x=pos.x, y=pos.y, z=pos.z - 1}, {name="air"})
	end
end,
})

--Craft

core.register_craft({
		output = 'mysiding:machine',
		recipe = {
			{'default:copperblock', 'default:copperblock', 'default:copperblock'},
			{'default:copperblock', 'default:steel_ingot', 'default:copperblock'},
			{'default:copperblock', "default:copperblock", 'default:copperblock'},		
		},
})













