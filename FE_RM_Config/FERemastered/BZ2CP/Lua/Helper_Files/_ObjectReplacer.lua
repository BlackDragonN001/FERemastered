--[[ Object Replacer 
Script by General BlackDragon
Version 1.0 - 1-1-2020

For use with command lines to replace objects on a .BZN. Instructions:
-- To specify the specific ODF to replace, use /svar 29 blah.odf
-- To specify the ODF to replace it with, use /svar 28 blah.odf

The objects are replaced, as is, preserving as much information about 
the original object as possible. --]]

print("Loading _ObjectReplacer.lua");

local _ObjectReplacer = {}

function _ObjectReplacer.InitialSetup()

	-- For EDF04 mission portals.
	--[[
	for i = 2, 6 do
		local h = GetHandle(string.format("Portal%d", i));
		print("Getting Handle: " .. GetLabel(h) .. " CFG: " .. GetCfg(h));
		if GetCfg(h) == "hbportTerr" then
			ReplaceObject(h, "hbport");
			print("Replacing Portal: " .. string.format("Portal%d", i));
		end
	end
	--]]
	
	local s_odffind = GetVarItemStr("network.session.svar29");
	local s_odfreplace = GetVarItemStr("network.session.svar28");
	
	local ObjectList = GetAllGameObjectHandles();
	
	for n = 1, #ObjectList do

		local Label = GetLabel(ObjectList[n]);	
		if GetCfg(ObjectList[n]) == s_odffind then
			ReplaceObject(ObjectList[n], s_odfreplace);
			
			if(Label) then
				print("Replacing: " .. s_odffind .. " Label: " .. Label .. " with: " .. s_odfreplace);
			else
				print("Replacing: " .. s_odffind .. " with: " .. s_odfreplace);
			end
		end
	
	end

end

print("Finished _ObjectReplacer.lua");

return _ObjectReplacer;