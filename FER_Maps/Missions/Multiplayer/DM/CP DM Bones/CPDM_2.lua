
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _DM = require('Deathmatch');


function AddObject(h)

	if(GetClassLabel(h) == "CLASS_NAVBEACON") then
		RemoveObject(h);
	end

end