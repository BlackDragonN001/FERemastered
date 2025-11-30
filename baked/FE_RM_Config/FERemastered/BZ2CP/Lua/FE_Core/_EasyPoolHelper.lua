--[[ FE:Remastered Easy Pool Helper
Written by General BlackDragon
Version 1.0 7-29-2023 --]]

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');

local _EasyPools = {}

function _EasyPools.SetupEasyPools()

	local TempEasyPoolODF = nil;
	
	if IsNetworkOn() then
		TempEasyPoolODF = GetVarItemStr("network.session.svar21");
	else
		TempEasyPoolODF = IFace_GetString("options.instant.string7");
	end
	
	if(TempEasyPoolODF ~= nil and TempEasyPoolODF ~= "") then
		BuildObject(TempEasyPoolODF, 0, "EasyPool1");
		BuildObject(TempEasyPoolODF, 0, "EasyPool2");
	else
		BuildObject("cpstpool01", 0, "EasyPool1");
		BuildObject("cpstpool01", 0, "EasyPool2");
	end

end

return _EasyPools;