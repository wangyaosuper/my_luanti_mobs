
function mysiding.register_all(mat, desc, image, groups, craft)

core.register_node("mysiding:wide_"..mat, {
	description = desc.." Wide Siding",
	drawtype = "normal",
	tiles = {
		image,
		image,
		image,
		image,
		image,
		image.."^mysiding_pattern1.png",
		},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	groups = {cracky = 2,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

core.register_node("mysiding:narrow_"..mat, {
	description = desc.." Narrow Siding",
	drawtype = "normal",
	tiles = {
		image,
		image,
		image,
		image,
		image,
		image.."^mysiding_pattern2.png",
		},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	groups = {cracky = 2,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

core.register_node("mysiding:wide_corner_"..mat, {
	description = desc.." Corner Wide Siding",
	drawtype = "normal",
	tiles = {
		image,
		image,
		image.."^mysiding_pattern1.png",
		image,
		image,
		image.."^mysiding_pattern1.png",
		},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	groups = {cracky = 2,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

core.register_node("mysiding:narrow_corner_"..mat, {
	description = desc.." Corner Narrow Siding",
	drawtype = "normal",
	tiles = {
		image,
		image,
		image.."^mysiding_pattern2.png",
		image,
		image,
		image.."^mysiding_pattern2.png",
		},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	groups = {cracky = 2,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

--------------------------------------------------------------------------
core.register_node("mysiding:light_wide_"..mat, {
	description = desc.." Wide Siding",
	drawtype = "normal",
	tiles = {
		image,
		image,
		image,
		image,
		image,
		image.."^mysiding_pattern1_light.png",
		},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	groups = {cracky = 2,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

core.register_node("mysiding:light_narrow_"..mat, {
	description = desc.." Narrow Siding",
	drawtype = "normal",
	tiles = {
		image,
		image,
		image,
		image,
		image,
		image.."^mysiding_pattern2_light.png",
		},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	groups = {cracky = 2,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

core.register_node("mysiding:light_wide_corner_"..mat, {
	description = desc.." Corner Wide Siding",
	drawtype = "normal",
	tiles = {
		image,
		image,
		image.."^mysiding_pattern1_light.png",
		image,
		image,
		image.."^mysiding_pattern1_light.png",
		},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	groups = {cracky = 2,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

core.register_node("mysiding:light_narrow_corner_"..mat, {
	description = desc.." Corner Narrow Siding",
	drawtype = "normal",
	tiles = {
		image,
		image,
		image.."^mysiding_pattern2_light.png",
		image,
		image,
		image.."^mysiding_pattern2_light.png",
		},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	groups = {cracky = 2,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})
end
