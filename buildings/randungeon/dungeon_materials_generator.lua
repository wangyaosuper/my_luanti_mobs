--
-- Helper Functions
--

local mod_path = minetest.get_modpath("randungeon")
local helper_functions = dofile(mod_path.."/helpers.lua")
local contains = helper_functions.contains
local intersects = helper_functions.intersects
local bool_to_number = helper_functions.bool_to_number

--
-- Dungeon Material Generation Functions
--

local function make_random_dungeon_material_scheme()
	-- all available materials
	local available_materials = {
		--"default:brick",
		"randungeon:bookshelf",
		"default:desert_sandstone", "default:desert_sandstone_block", "default:desert_sandstone_brick",
		"default:desert_cobble", "default:desert_stone", "default:desert_stone_block", "default:desert_stonebrick",
		"default:cobble", "default:stone", "default:stone_block", "default:stonebrick",
		"default:sandstone", "default:sandstone_block",  "default:sandstonebrick", 
		"default:silver_sandstone", "default:silver_sandstone_block", "default:silver_sandstone_brick",
		"air", "default:meselamp"
	}
	-- only 2/3 of all generated material schemes contain wood
	if math.random() < 0.66 then
		table.insert(available_materials, "default:aspen_wood")
		table.insert(available_materials, "default:acacia_wood")
		table.insert(available_materials, "default:pine_wood")
		table.insert(available_materials, "default:wood")
	end
	-- choose random materials
	local materials = {
		roof_type = available_materials[math.random(1, #available_materials)],
		wall_type_2 = available_materials[math.random(1, #available_materials)],
		wall_type_1 = available_materials[math.random(1, #available_materials)],
		floor_type = available_materials[math.random(1, #available_materials)],
		pillar_type = available_materials[math.random(1, #available_materials)],
		bridge_type = math.random(0, 3),
	}
	return materials
end

local function compare_dungeon_material_schemes(scheme1, scheme2)
	local similarity = 0
	for _, attr in ipairs({"roof_type", "wall_type_2", "wall_type_1", "floor_type", "pillar_type"}) do
		if scheme1[attr] == scheme2[attr] then
			similarity = similarity + 0.2
			-- if attr == "pillar_type" then
			-- 	similarity = similarity + 0.3
			-- end
		end
	end
	similarity = similarity - 0.2 * math.abs(scheme1.bridge_type - scheme2.bridge_type)
	return similarity
end

local function make_similar_dungeon_scheme(scheme1)
	local best_scheme = nil
	local best_similarity = -1
	local iterations = 60
	for i = 1, iterations do
		local new_scheme = make_random_dungeon_material_scheme()
		local new_similarity = compare_dungeon_material_schemes(scheme1, new_scheme)
		if new_similarity > best_similarity then
			best_scheme = new_scheme
			best_similarity = new_similarity
			if best_similarity >= 0.8 then
				break
			end
		end
	end
	return best_scheme
end

local function a_to_set(a)
	local s = {}
	for i = 1, #a do s[a[i]] = true end
	return s
end

local group_desert_sandstone_set = a_to_set({"default:desert_sandstone", "default:desert_sandstone_block", "default:desert_sandstone_brick"})
local group_desert_stone_set = a_to_set({"default:desert_cobble", "default:desert_stone", "default:desert_stone_block", "default:desert_stonebrick"})
local group_normal_stone_set = a_to_set({"default:cobble", "default:stone", "default:stone_block", "default:stonebrick"})
local group_sandstone_set = a_to_set({"default:sandstone", "default:sandstone_block", "default:sandstonebrick"})
local group_silver_sandstone_set = a_to_set({"default:silver_sandstone", "default:silver_sandstone_block", "default:silver_sandstone_brick"})
local group_wood_shelf_set = a_to_set({"default:aspen_wood", "default:acacia_wood", "default:pine_wood", "default:wood", "randungeon:bookshelf"})
local group_wood4_set = a_to_set({"default:aspen_wood", "default:acacia_wood", "default:pine_wood", "default:wood"})
local group_wood_aspen_acacia_set = a_to_set({"default:aspen_wood", "default:acacia_wood"})
local group_cobble_pillar_set = a_to_set({"default:cobble", "default:desert_cobble"})
local group_normal_stone3_set = a_to_set({"default:cobble", "default:stone_block", "default:stonebrick"})
local group_tiles_blocks_set = a_to_set({"default:stone_block", "default:desert_stone_block", "default:sandstone_block", "default:desert_sandstone_block", "default:silver_sandstone_block"})

local material_group_sets = {
	group_desert_sandstone_set,
	group_desert_stone_set,
	group_normal_stone_set,
	group_sandstone_set,
	group_silver_sandstone_set,
	group_wood_shelf_set,
	{["default:stone"] = true},
	{["default:meselamp"] = true},
	{["air"] = true}
}

local desert_stone_type_sets = {
	group_desert_sandstone_set,
	group_desert_stone_set,
	group_sandstone_set,
	group_silver_sandstone_set
}

local function rate_dungeon_materials(materials)
	local score = 10
	if materials.floor_type == "air" or materials.pillar_type == "air" then
		return -100
	end
	local all_materials_list = {materials.floor_type, materials.pillar_type, materials.wall_type_1, materials.wall_type_2, materials.pillar_type}
	local all_set = a_to_set(all_materials_list)
	for gi = 1, #material_group_sets do
		local gset = material_group_sets[gi]
		local occurances = 0
		for _, m in pairs(materials) do
			if gset[m] then
				occurances = occurances + 1
			end
		end
		if occurances > 1 then
			score = score + 1.7^occurances
		end
	end
	local has_sandstone = intersects({"default:sandstone", "default:sandstone_block", "default:sandstonebrick"}, all_materials_list)
	local has_silver_sandstone = intersects({"default:silver_sandstone", "default:silver_sandstone_block", "default:silver_sandstone_brick"}, all_materials_list)
	local has_desert_sandstone = intersects({"default:desert_sandstone", "default:desert_sandstone_block", "default:desert_sandstone_brick"}, all_materials_list)
	local has_desert_stone = intersects({"default:desert_cobble", "default:desert_stone", "default:desert_stone_block", "default:desert_stonebrick"}, all_materials_list)
	local has_normal_stone = intersects({"default:cobble", "default:stone", "default:stone_block", "default:stonebrick"}, all_materials_list)
	if (has_sandstone or has_silver_sandstone) then
		if all_set["default:aspen_wood"] or all_set["default:acacia_wood"] then
			score = score + 1
		end
	elseif has_desert_sandstone and all_set["default:pine_wood"] then
		score = score + 1
	elseif has_desert_stone and all_set["default:acacia_wood"] then
		score = score + 1
	elseif has_normal_stone and all_set["default:wood"] then
		score = score + 1
	end
	local wood_types_list = {"default:aspen_wood", "default:acacia_wood", "default:pine_wood", "default:wood"}
	for wi = 1, #wood_types_list do
		if not all_set[wood_types_list[wi]] then
			score = score + 1.5
		end
	end
	if materials.wall_type_1 == "air" and materials.wall_type_2 ~= "air" then
		score = score - 4
	end
	if materials.wall_type_2 == "air" and materials.roof_type == "air" then
		score = score + 1
		if materials.wall_type_1 == "air" then
			score = score + 1
		end
	end
	local normal_stone_types_count = 0
	local desert_stone_types_count = 0
	for di = 1, #desert_stone_type_sets do
		local dset = desert_stone_type_sets[di]
		local found = false
		for ai = 1, #all_materials_list do
			if dset[all_materials_list[ai]] then found = true break end
		end
		if found then desert_stone_types_count = desert_stone_types_count + 1 end
	end
	for ai = 1, #all_materials_list do
		if group_normal_stone3_set[all_materials_list[ai]] then
			normal_stone_types_count = 1
			break
		end
	end
	if normal_stone_types_count > 0 and desert_stone_types_count > 0 then
		score = score - 2.5
	elseif desert_stone_types_count > 1 then
		score = score - 1
	end
	if materials.floor_type == "default:cobble" then
		score = score - 1.5
	else
		local fr_set = {[materials.floor_type] = true, [materials.wall_type_1] = true, [materials.wall_type_2] = true, [materials.roof_type] = true}
		if fr_set["default:cobble"] then score = score - 1 end
		if fr_set["default:desert_cobble"] then score = score - 0.5 end
	end
	if materials.wall_type_1 == "randungeon:bookshelf" and materials.wall_type_2 == "air" then
		score = score - 2
	elseif materials.wall_type_1 == "randungeon:bookshelf" and materials.wall_type_2 ~= "randungeon:bookshelf" then
		score = score - 3
	end
	local fr2_set = {[materials.floor_type] = true, [materials.roof_type] = true}
	if fr2_set["randungeon:bookshelf"] then
		score = score - 10
	end
	local w1w2_set = {[materials.wall_type_1] = true, [materials.wall_type_2] = true}
	for wi = 1, #wood_types_list do
		if w1w2_set[wood_types_list[wi]] then
			score = score - 0.5
		end
	end
	local pillar_wood_set = {["default:aspen_wood"] = true, ["default:acacia_wood"] = true, ["default:pine_wood"] = true, ["default:wood"] = true}
	if pillar_wood_set[materials.pillar_type] then
		score = score - 3
	elseif materials.pillar_type == "randungeon:bookshelf" then
		score = score - 5
	end
	if materials.wall_type_1 == materials.wall_type_2 then
		score = score + 2
	end
	local distinct_woods = 0
	for wi = 1, #wood_types_list do
		if all_set[wood_types_list[wi]] then distinct_woods = distinct_woods + 1 end
	end
	if distinct_woods > 1 then
		score = score - 2
	end
	if all_set["randungeon:bookshelf"] then
		score = score + 2
	end
	if group_cobble_pillar_set[materials.pillar_type] then
		score = score + 2
	end
	if group_wood4_set[materials.floor_type] then
		score = score + 2
	end
	if group_tiles_blocks_set[materials.floor_type] then
		score = score + 1.5
	end
	local tiles_as_wall_or_roof = false
	local rw_list = {materials.roof_type, materials.wall_type_1, materials.wall_type_2}
	for ri = 1, #rw_list do
		if group_tiles_blocks_set[rw_list[ri]] then tiles_as_wall_or_roof = true end
	end
	if tiles_as_wall_or_roof then
		score = score - 1
	end
	if group_tiles_blocks_set[materials.wall_type_2] and materials.wall_type_1 == "air" then
		score = score - 0.5
	elseif group_tiles_blocks_set[materials.wall_type_2] and not group_tiles_blocks_set[materials.wall_type_1] then
		score = score - 1.5
	end
	if materials.bridge_type == 3 and group_wood4_set[materials.floor_type] then
		score = score + 2
	end
	if (materials.bridge_type == 1 or materials.bridge_type == 2) and materials.wall_type_1 == "default:stone" then
		score = score - 2
	end
	if materials.bridge_type == 0 then
		score = score - 3
	end
	if materials.wall_type_2 == "default:mese_lamp" then
		score = score + 2
	end
	return score
end

local function get_good_material_set(old_material_set)
	local best_material_set = make_similar_dungeon_scheme(old_material_set)
	local best_score = rate_dungeon_materials(best_material_set)
	local max_iter = 80
	for i = 1, max_iter do
		local new_material_set = make_similar_dungeon_scheme(old_material_set)
		local new_material_set_score = rate_dungeon_materials(new_material_set)
		if new_material_set_score > best_score then
			best_material_set = new_material_set
			best_score = new_material_set_score
			if best_score >= 18 then
				break
			end
		end
	end
	return best_material_set
end

return {
    make_random_dungeon_material_scheme = make_random_dungeon_material_scheme,
    compare_dungeon_material_schemes = compare_dungeon_material_schemes,
    make_similar_dungeon_scheme = make_similar_dungeon_scheme,
    rate_dungeon_materials = rate_dungeon_materials,
    get_good_material_set = get_good_material_set
}