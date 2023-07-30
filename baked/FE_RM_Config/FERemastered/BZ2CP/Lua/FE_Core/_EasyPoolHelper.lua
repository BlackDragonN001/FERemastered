--[[ FE:Remastered Easy Pool Helper
Written by General BlackDragon
Version 1.0 7-29-2023 --]]

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');

local _EasyPools = {}

function _EasyPools.SetupEasyPools()

	local TempEasyPoolODF = GetVarItemStr("network.session.svar21");
	if(TempEasyPoolODF ~= nil and TempEasyPoolODF ~= "") then
		BuildObject(EasyPoolODF, 0, "EasyPool1");
		BuildObject(EasyPoolODF, 0, "EasyPool2");
	else
		BuildObject("cpstpool01", 0, "EasyPool1");
		BuildObject("cpstpool01", 0, "EasyPool2");
	end

end

return _EasyPools;