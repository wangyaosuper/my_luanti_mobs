--
-- Helper Functions For Block Comparisons
--

local function contains(array, value)
	for i = 1, #array do
		if array[i] == value then
			return true
		end
	end
	return false
end

local function array_to_set(array)
	local set = {}
	for i = 1, #array do
		set[array[i]] = true
	end
	return set
end

local function set_contains(set, value)
	return set[value] ~= nil
end

local function intersects(array1, array2)
	if #array1 > 8 and #array2 > 8 then
		local set2 = array_to_set(array2)
		for i = 1, #array1 do
			if set2[array1[i]] then
				return true
			end
		end
		return false
	end
	for i = 1, #array1 do
		local v1 = array1[i]
		for j = 1, #array2 do
			if v1 == array2[j] then
				return true
			end
		end
	end
	return false
end

local function bool_to_number(value)
	if value == true then
		return 1
	else
		return 0
	end
end

local function number_to_bool(value)
	if value == 1 then
		return true
	else
		return false
	end
end

local function is_even(a)
	return a - (math.floor(a / 2) * 2) == 0
end

local function randomize_list(list)
	local list_new = {}
	while #list > 0 do
		table.insert(list_new, table.remove(list, math.random(1, #list)))
	end
	return list_new
end

local stone_ground_blocks = {
	"default:desert_sandstone", "default:desert_sandstone_block", "default:desert_sandstone_brick",
	"default:desert_cobble", "default:desert_stone", "default:desert_stone_block", "default:desert_stonebrick",
	"default:cobble", "default:stone", "default:stone_block", "default:stonebrick",
	"default:sandstone", "default:sandstone_block",  "default:sandstonebrick",
	"default:silver_sandstone", "default:silver_sandstone_block", "default:silver_sandstone_brick"
}
local stone_ground_blocks_set = array_to_set(stone_ground_blocks)

local cold_blocks_set = {
	["default:snowblock"] = true,
	["default:snow"] = true,
	["default:dirt_with_snow"] = true,
	["default:ice"] = true,
	["default:cave_ice"] = true,
}

local frozen_biome_cache = {}
local cached_cold_deco_biomes = nil

local function build_cold_deco_biomes_set()
	if cached_cold_deco_biomes ~= nil then
		return cached_cold_deco_biomes
	end
	local set = {}
	if minetest.registered_decorations then
		for _, deco_def in ipairs(minetest.registered_decorations) do
			if cold_blocks_set[deco_def.decoration] and deco_def.biomes then
				for _, bname in ipairs(deco_def.biomes) do
					set[bname] = true
				end
			end
		end
	end
	cached_cold_deco_biomes = set
	return set
end

local function get_solid_air_block_replacement(pos, cobbelify)
	local biome_data = minetest.get_biome_data(pos)
	if biome_data == nil then
		return "default:stone"
	end
	local biome_name = minetest.get_biome_name(biome_data.biome)
	local stone_type = minetest.registered_biomes[biome_name].node_stone or "default:stone"
	if stone_type == "default:stone" and cobbelify then
		return "default:cobble"
	elseif stone_type == "default:desert_stone" then
		return "default:desert_cobble"
	elseif stone_ground_blocks_set[stone_type] then
		return stone_type
	else
		return "default:stone"
	end
end

local function is_in_frozen_biome(pos)
	if minetest.get_mapgen_setting("mg_name") == "v6" then
		return contains({"Taiga", "Tundra"}, biomeinfo.get_v6_biome(pos))
	end
	local biome_data = minetest.get_biome_data(pos)
	if biome_data == nil then
		return nil
	end
	local biome_name = minetest.get_biome_name(biome_data.biome)
	local cached = frozen_biome_cache[biome_name]
	if cached ~= nil then
		return cached
	end
	local biome_definition = minetest.registered_biomes[biome_name]
	local result = false
	if biome_definition.heat_point <= 25 then
		result = true
	else
		local biome_blocks = {
			biome_definition.node_dust,
			biome_definition.node_top,
			biome_definition.node_filler,
			biome_definition.node_stone,
			biome_definition.node_water_top,
			biome_definition.node_river_water,
			biome_definition.node_riverbed,
		}
		for i = 1, #biome_blocks do
			if cold_blocks_set[biome_blocks[i]] then
				result = true
				break
			end
		end
		if not result then
			local cold_deco_set = build_cold_deco_biomes_set()
			if cold_deco_set[biome_name] then
				result = true
			end
		end
	end
	frozen_biome_cache[biome_name] = result
	return result
end

local helper_functions = {
    contains = contains,
    intersects = intersects,
    bool_to_number = bool_to_number,
	number_to_bool = number_to_bool,
	is_even = is_even,
	randomize_list = randomize_list,
	get_solid_air_block_replacement = get_solid_air_block_replacement,
	is_in_frozen_biome = is_in_frozen_biome,
	array_to_set = array_to_set,
	set_contains = set_contains,
	cold_blocks_set = cold_blocks_set,
}
randungeon.helper_functions = helper_functions
return helper_functions
