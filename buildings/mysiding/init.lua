mysiding = {}

local myores = core.settings:get_bool("mysiding.myores", true)
local mywhiteblock = core.settings:get_bool("mysiding.mywhiteblock", true)

dofile(core.get_modpath("mysiding").."/siding.lua")
dofile(core.get_modpath("mysiding").."/machine.lua")
dofile(core.get_modpath("mysiding").."/register.lua")

if myores then
	if core.get_modpath("myores") then
		dofile(core.get_modpath("mysiding").."/myores.lua")
	end
end
if mywhiteblock then
	if core.get_modpath("mywhiteblock") then
		dofile(core.get_modpath("mysiding").."/mywhiteblock.lua")
	end
end
