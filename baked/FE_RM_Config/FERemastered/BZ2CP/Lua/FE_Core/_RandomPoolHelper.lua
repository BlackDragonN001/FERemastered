--[[ FE:Remastered Random Pool Helper
Written by General BlackDragon
Version 1.0 7-29-2023 --]]

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');

local _RandomPools = {}

function _RandomPools.SetupRandomPools(pathNames)
	local pathCount = #pathNames;
	local length;
	
	local RandomPools = {};

	for i = 1, pathCount do
		local Label = pathNames[i];

		if (string.sub(Label, 1, 10) == "RandomPool") then

			length = string.len(Label);
			
			print(Label);

			-- If we're missing any format, bail.
			local Underscore = string.find(Label, "_");
			if (Underscore == nil) then
				return;
			end

			local Underscore2 = string.find(Label, "_", Underscore + 1);
			if (Underscore2 == nil) then
				return;
			end
			
			local Underscore3 = string.find(Label, "_", Underscore2 + 1);
			if (Underscore3 == nil) then
				return
			end

			-- store the values.
			local X = string.sub(Label, Underscore + 1, Underscore2 - 1);
			local Y = string.sub(Label,  Underscore2 + 1, Underscore3 - 1);
			local ODF = string.sub(Label, Underscore3 + 1, length);
			
			
			--[[
			-- do this inside the loop
			local EntriesAtY = RandomPools[Y] or {}
			EntriesAtY[X] = { Label: Label, ODF : ODF }
			--]]

		end
	end
	
	-- now iterate over each X group, and randomly pick a Y point to spawn a pool.
	
	local RowEntries = RandomPools[Y];
	if RowEntries ~= nil then
		local Entry = RowEntries[X];
		if Entry ~= nil then
			local Label = Entry.Label
			local ODF = Entry.ODF
			-- do stuff with Label and ODF
		end
	end
	
end

return _RandomPools;