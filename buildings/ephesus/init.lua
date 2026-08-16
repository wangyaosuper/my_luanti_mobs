-- Check for mod existence
local i3_mod = minetest.get_modpath("i3")

local stairsplus_mod = minetest.get_modpath("moreblocks") and minetest.global_exists("stairsplus")
local stairsplus_compat = minetest.settings:get_bool("stairsplus_clay_compatibility") ~= false



-- Shapes
local shapes = {
        { "micro", "" },
    	{ "micro", "_1" },
    	{ "micro", "_2" },
    	{ "micro", "_4" },
    	{ "micro", "_12" },
    	{ "micro", "_14" },
    	{ "micro", "_15" },
    	{ "panel", "" },
    	{ "panel", "_1" },
    	{ "panel", "_2" },
    	{ "panel", "_4" },
    	{ "panel", "_12" },
    	{ "panel", "_14" },
    	{ "panel", "_15" },
    	{ "slab",  "" },
    	{ "slab",  "_quarter" },
    	{ "slab",  "_three_quarter" },
    	{ "slab",  "_1" },
    	{ "slab",  "_2" },
    	{ "slab",  "_14" },
    	{ "slab",  "_15" },
    	{ "slab",  "_two_sides" },
    	{ "slab",  "_three_sides" },
    	{ "slab",  "_three_sides_u" },
    	{ "slope", "" },
    	{ "slope", "_half" },
    	{ "slope", "_half_raised" },
    	{ "slope", "_inner" },
    	{ "slope", "_inner_half" },
    	{ "slope", "_inner_half_raised" },
    	{ "slope", "_inner_cut" },
    	{ "slope", "_inner_cut_half" },
    	{ "slope", "_inner_cut_half_raised" },
    	{ "slope", "_outer" },
    	{ "slope", "_outer_half" },
    	{ "slope", "_outer_half_raised" },
    	{ "slope", "_outer_cut" },
    	{ "slope", "_outer_cut_half" },
    	{ "slope", "_outer_cut_half_raised" },
    	{ "slope", "_cut" },
    	{ "stair", "" },
    	{ "stair", "_half" },
    	{ "stair", "_right_half" },
    	{ "stair", "_inner" },
    	{ "stair", "_outer" },
    	{ "stair", "_alt" },
    	{ "stair", "_alt_1" },
    	{ "stair", "_alt_2" },
    	{ "stair", "_alt_4" },
    }


--- Node Registration

-- Full Blocks
local full_blocks = {
    {"marble", "Marble"},
    {"polished_marble", "Polished Marble"},
    {"grey_marble", "Grey Marble"},
    {"tiles", "Tiles"},
    {"blue_mosaic", "Blue Mosaic"},
    {"red_mosaic", "Red Mosaic"},
    {"cypress_planks", "Cypress Planks"},
    {"apricot_trunk_block", "Block of Cypres Trunk"},
    {"cypress_trunk_block", "Block of Apricot Trunk"},
    {"olive_trunk_block", "Block of Apricot Trunk"}
}

-- Leaves Blocks
local leave_blocks = {
    {"cypres1", "Cypress Leaves 1"},
    {"cypres2", "Cypress Leaves 2"},
    {"cypres3", "Cypress Leaves 3"},
    {"apricot_leaves", "Apricot Leaves"},
    {"olive_leaves", "Olive Leaves"},
    {"fig_leaves", "Fig Leaves"}
}

-- Brickslabs
local brick_slab = {
    {"marble","marble", "Marble"},
    {"polished_marble","polished_marble", "Polished Marble"},
    {"grey_marble","grey_marble", "Grey Marble"},
    {"default_clay","clay","Clay"},
    {"default_tin_block","tin","Tin"}
}

-- Brickslabs Corner
local brick_slab_corner = {
    {"marble","marble", "Marble"},
    {"polished_marble","polished_marble", "Polished Marble"},
    {"grey_marble","grey_marble", "Grey Marble"},
    {"default_clay","clay","Clay"},
    {"default_tin_block","tin","Tin"}
}

-- Special Slab Blocks
local full_blocks_special_slab = {
    {"marble", "Marble"},
    {"polished_marble", "Polished Marble"},
    {"grey_marble", "Grey Marble"}
}

-- Trunk Blocks
local trunk_blocks = {
    {"cypress_trunk", "Cypress Trunk", "cypress_trunk_top.png", "cypress_trunk_top.png", "cypress_trunk.png"},
    {"apricot_trunk", "Apricot Trunk", "apricot_trunk_top.png", "apricot_trunk_top.png", "apricot_trunk.png"},
    {"olive_trunk", "Olive Trunk", "olive_trunk_top.png", "olive_trunk_top.png", "olive_trunk.png"},
}



---Register 

-- Register Full Blocks
for _, full_block in pairs(full_blocks) do
    minetest.register_node("ephesus:" .. full_block[1], {
        description = full_block[2],
        tiles = {full_block[1] .. ".png"},
        groups = {cracky = 3, ephesus = 1},
        sounds = default.node_sound_stone_defaults()
    })

    if stairsplus_mod then
        stairsplus:register_all("ephesus", full_block[1], "ephesus:" .. full_block[1], {
            description = full_block[2],
            tiles = {full_block[1] .. ".png"},
            groups = {cracky = 3, ephesus = 1},
            sounds = default.node_sound_stone_defaults()
        })




        -- Compression pour les blocs pleins
        if i3_mod then
            for _, shape in pairs(shapes) do
                i3.compress("ephesus:" .. full_block[1], {
                    replace = full_block[1],
                    by = {shape[1] .. "_" .. full_block[1] .. shape[2]}
                })
            end
        end
    end
end



-- ...

-- Register Trunk Blocks
for _, trunk_block in pairs(trunk_blocks) do
    minetest.register_node("ephesus:" .. trunk_block[1], {
        description = trunk_block[2],
        tiles = {
            trunk_block[3], -- Texture pour la face supérieure
            trunk_block[4], -- Texture pour la face inférieure 
            trunk_block[5], -- Texture pour les côtés
            trunk_block[5], -- Texture pour les côtés
            trunk_block[5], -- Texture pour les côtés
            trunk_block[5], -- Texture pour les côtés
        },
        paramtype2 = "facedir",
        groups = {cracky = 3, ephesus = 1},
    })

    if stairsplus_mod then
        stairsplus:register_all("ephesus", trunk_block[1], "ephesus:" .. trunk_block[1], {
            description = trunk_block[2],
            tiles = {
                trunk_block[3], -- Texture pour la face supérieure
                trunk_block[4], -- Texture pour la face inférieure
                trunk_block[5], -- Texture pour les côtés
                trunk_block[5], -- Texture pour les côtés
                trunk_block[5], -- Texture pour les côtés
                trunk_block[5], -- Texture pour les côtés
            },
            paramtype2 = "facedir",
            groups = {cracky = 3, ephesus = 1},
        })
    end

    -- Compression pour les blocs de tronc
    if i3_mod then
        for _, shape in pairs(shapes) do
            i3.compress("ephesus:" .. trunk_block[1], {
                replace = trunk_block[1],
                by = {shape[1] .. "_" .. trunk_block[1] .. shape[2]}
            })
        end
    end
end



-- Register Leave Blocks

for _, leave_block in pairs(leave_blocks) do
    minetest.register_node("ephesus:" .. leave_block[1], {
        description = leave_block[2],
        drawtype = "allfaces_optional",
        paramtype = "light",
        waving = 1,
        tiles = {leave_block[1] .. ".png"},
        sunlight_propagates = true,
        is_ground_content = true,
        groups = {snappy = 2, leafdecay = 3, flammable = 2},
    })
end


-- Register Special Slabs and Special Slab Corners

for _, special_slab in pairs(full_blocks_special_slab) do

    minetest.register_node("ephesus:" .. special_slab[1] .. "_special_slab", {
        description = special_slab[2] .. " 15/16 Slab",
        tiles = {special_slab[1] .. ".png"},
        paramtype = "light",
        drawtype = "nodebox",
        paramtype2 = "facedir",
        node_box = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5}}},
        selection_box = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5}}},
        groups = {cracky = 2, oddly_breakable_by_hand = 1},
    })

    minetest.register_node("ephesus:" .. special_slab[1] .. "_special_slab_corner", {
        description = special_slab[2] .. " 15/16 Slab Corner",
        tiles = {special_slab[1] .. ".png"},
        paramtype = "light",
        drawtype = "nodebox",
        paramtype2 = "facedir",
        node_box = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.4375}}},
        selection_box = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.4375}}},
        groups = {cracky = 2, oddly_breakable_by_hand = 1},
    })
end


-- Register Bricks and Bricks Corners

if minetest.get_modpath("default") then
    for _, brick_slab in pairs(brick_slab) do
        minetest.register_node("ephesus:" .. brick_slab[2] .. "_brick_slab", {
        description = "Brick Slab ".. brick_slab[3],
        tiles = {brick_slab[1] .. ".png"},
        drawtype = "nodebox",
        paramtype = "light",
        paramtype2 = "facedir",
        groups = {cracky = 2, ephesus_blocks = 6},
        node_box = {type = "fixed", fixed = {-0.5, -0.5, 0.4375, 0.5, 0.4375, 0.5}},
        selection_box = {type = "fixed", fixed = {-0.5, -0.5, 0.4375, 0.5, 0.4375, 0.5}},
        collision_box = {type = "fixed", fixed = {-0.5, -0.5, 0.4375, 0.5, 0.4375, 0.5}},
    })    

    minetest.register_node("ephesus:" .. brick_slab[2] .. "_brick_slab_corner", {
        description = "Brick Slab Corner ".. brick_slab[3],
        tiles = {brick_slab[1] .. ".png"},
        drawtype = "nodebox",
        paramtype = "light",
        paramtype2 = "facedir",
        groups = {cracky = 2, ephesus_blocks = 6},
        node_box = {type = "fixed", fixed = {-0.4375, -0.5, 0.4375, 0.5, 0.4375, 0.5}},
        selection_box = {type = "fixed", fixed = {-0.4375, -0.5, 0.4375, 0.5, 0.4375, 0.5}},
        collision_box = {type = "fixed", fixed = {-0.4375, -0.5, 0.4375, 0.5, 0.4375, 0.5}},
    })    
    end
end




-- Registration of other node types

-- Column
minetest.register_node("ephesus:marble_column", {
    description = "Marble Column",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "large_column.obj",
    groups = {cracky = 2, ephesus_blocks = 6},
})

-- Column Top
minetest.register_node("ephesus:hat_column", {
    description = "Marble Column Top",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "hat_column.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
})

-- Medium Column
minetest.register_node("ephesus:hat_medium", {
    description = "Medium Column",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "medium_column.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
    selection_box = {type = "fixed", fixed = {{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}}},
    collision_box = {type = "fixed", fixed = {{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}}},
})

-- Medium-Column Top
minetest.register_node("ephesus:medium_column_top", {
    description = "Medium Column Top",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "medium_hat_column.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
    selection_box = {type = "fixed", fixed = {{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}}},
    collision_box = {type = "fixed", fixed = {{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}}},
})

-- Upper Corner
minetest.register_node("ephesus:hat_angle", {
    description = "Upper Corner",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "haut_angle.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
})

-- Top
minetest.register_node("ephesus:hat", {
    description = "Top",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "haut.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
})

-- Pedestal
minetest.register_node("ephesus:pedestal", {
    description = "Pedestal",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "socle.obj",
    groups = {cracky = 2, ephesus_blocks = 6},
})

-- Braces
minetest.register_node("ephesus:braces", {
    description = "Braces",
    tiles = {"braces.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
    node_box = {type = "fixed", fixed = {-0.5, -0.5, -0.25, 0.5, 0.5, 0.25}},
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.25, 0.5, 0.5, 0.25}},
    collision_box = {type = "fixed", fixed = {-0.5, -0.5, -0.125, 0.5, 0.5, 0.125}},
})



--- Compressions lists

-- Compress Leaves for i3 mod

if i3_mod then
    i3.compress("ephesus:cypres1", {
        replace = "cypres1",
        by = {"cypres2", "cypres3", "apricot_leaves", "olive_leaves", "fig_leaves"}
    })
end


-- Compress Bricks for i3 mod
if i3_mod then
    i3.compress("ephesus:clay_brick_slab", {
        replace = "clay_brick_slab",
        by = {  "marble_brick_slab","polished_marble_brick_slab","grey_marble_brick_slab", "tin_brick_slab", 
                "marble_brick_slab_corner","polished_marble_brick_slab_corner","grey_marble_brick_slab_corner", "clay_brick_slab_corner", "tin_brick_slab_corner" }
    })
end



-- Compress Others Types of Blocks for i3 mod

if i3_mod then
    i3.compress("ephesus:marble_column", {
        replace = "marble_column",
        by = {"hat_column", "hat_medium", "medium_column_top", "hat_angle", "hat", "pedestal", "braces"}
    })
end


-- Compress Special Slab for i3 mod

if i3_mod then
    for _, special_slab in pairs(full_blocks_special_slab) do
        i3.compress("ephesus:" .. special_slab[1], {
            replace = special_slab[1],
            by = {special_slab[1] .. "_special_slab", special_slab[1] .. "_special_slab_corner"}
        })
    end
end







