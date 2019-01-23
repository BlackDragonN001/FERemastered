print("Loading _FECore.lua");
--===================================================
-- Forgotten Enemies Core Helper Lua.
-- Written by General BlackDragon.
-- Links all the individual Lua Moduels together.
--===================================================

-- Key Asset/Require Loader. -- Already in root ODFs.
--assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

-- Helper Luas.
require('_GlobalHandler');
require('_MapReloader');

-- FE Moduels.
--require('_PortalHelper');
--require('_DispatchHelper');



-- Function Overload system
_FECore = {
	InitialSetup = FEC_InitialSetup,
}

function FEC_InitialSetup()

-- Call helper functions.

_MRH.InitialSetup();

end



print("Finished _FECore.lua");