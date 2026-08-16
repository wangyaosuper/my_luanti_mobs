local block_table = {
	{"black",      "Black",      "#000000"},
	{"blue",       "Blue",       "#2000c9"},
	{"brown",      "Brown",      "#954c05"},
	{"cyan",       "Cyan",       "#01ffd8"},
	{"darkgreen", "Dark Green",  "#005b07"},
	{"darkgrey",  "Dark Grey",   "#303030"},
	{"green",      "Green",      "#61ff01"},
	{"grey",       "Grey",       "#5b5b5b"},
	{"magenta",    "Magenta",    "#ff05bb"},
	{"orange",     "Orange",     "#ff8401"},
	{"pink",       "Pink",       "#ff65b5"},
	{"red",        "Red",        "#ff0000"},
	{"violet",     "Violet",     "#ab23b0"},
	{"white",      "White",      "#ffffff"},
	{"yellow",     "Yellow",     "#e3ff00"},
}
if core.get_modpath("mydye") then
	block_table = {
	{"black",      	"Black",      		"#000000"},
	{"blue",       	"Blue",       		"#2000c9"},
	{"brown",     	"Brown",      		"#954c05"},
	{"cyan",      	"Cyan",       		"#01ffd8"},
	{"darkgreen", 	"Dark Green",  		"#005b07"},
	{"darkgrey",  	"Dark Grey",   		"#303030"},
	{"green",     	"Green",      		"#61ff01"},
	{"grey",       	"Grey",       		"#5b5b5b"},
	{"magenta",    	"Magenta",    		"#ff05bb"},
	{"orange",     	"Orange",     		"#ff8401"},
	{"pink",      	"Pink",       		"#ff65b5"},
	{"red",        	"Red",        		"#ff0000"},
	{"violet",     	"Violet",     		"#ab23b0"},
	{"white",      	"White",      		"#ffffff"},
	{"yellow",     	"Yellow",     		"#e3ff00"},
	{"peachpuff",	"Peachpuff", 		"#FFDAB9"},
	{"navy",		"Navy", 			"#000080"},
	{"coral",		"Coral", 			"#FF7F50"},
	{"khaki",		"Khaki", 			"#F0E68C"},
	{"lime",		"Lime", 			"#00FF00"},
	{"light_pink",	"Light Pink", 		"#FFB6C1"},
	{"light_grey",	"Light Grey", 		"#D3D3D3"},
	{"purple",		"Purple", 			"#800080"},
	{"maroon",		"Maroon", 			"#800000"},
	{"aquamarine",	"Aqua Marine", 		"#7FFFD4"},
	{"chocolate",	"Chocolate", 		"#D2691E"},
	{"crimson",		"Crimson", 			"#DC143C"},
	{"olive",		"Olive", 			"#808000"},
	{"white_smoke",	"White Smoke", 		"#F5F5F5"},
	{"mistyrose",	"Misty Rose", 		"#FFE4E1"},
	{"orchid",		"Orchid", 			"#DA70D6"},
	}
end

local paintables = {
	"mysiding:narrow_block","mysiding:wide_block","mysiding:light_narrow_block","mysiding:light_wide_block","mysiding:narrow_corner_block","mysiding:wide_corner_block","mysiding:light_narrow_corner_block","mysiding:light_wide_corner_block"
}

for i in ipairs(block_table) do
	local mat = block_table[i][1]
	local des = block_table[i][2]
	local col = block_table[i][3]



--mat, desc, image, mygroups, craft, drawtype

mysiding.register_all(
	"block_"..mat, 
	des.." Block", 
	"mywhiteblock_white.png^[colorize:"..col,
	{cracky = 1, oddly_breakable_by_hand = 1, not_in_creative_inventory=1},
	"mywhiteblock:block_"..mat,
	"normal"
	)
end
mysiding.register_all(
	"block", 
	"Block", 
	"mywhiteblock_white.png",
	{cracky = 1, oddly_breakable_by_hand = 1, not_in_creative_inventory=1},
	"mywhiteblock:block",
	"normal"
	)
if core.get_modpath("mypaint") then
local colors = {}
for _, entry in ipairs(block_table) do
	table.insert(colors, entry[1])
end
	mypaint.register(paintables, colors)
end
