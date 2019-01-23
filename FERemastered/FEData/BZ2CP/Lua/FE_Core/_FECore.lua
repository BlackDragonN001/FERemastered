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
	
	Start = FEC_Start,
	
	Load = FEC_Load,
	
	Save = FEC_Save,
	
	AddObject = FEC_AddObject,
	
	DeleteObject = FEC_DeleteObject,
	
	Update = FEC_Update,
}

-- Core game functions.
function FEC_InitialSetup()

-- Call helper functions.

_MRH.InitialSetup();

end

function FEC_Start()

-- Call helper functions.

end

function FEC_Load()

-- Call helper functions.

end

function FEC_Save()

-- Call helper functions.

end

function FEC_AddObject(h)

-- Call helper functions.

end

function FEC_DeleteObject(h)

-- Call helper functions.

end

function FEC_Update()

-- Call helper functions.

end



print("Finished _FECore.lua");