--[[ Prop Height Fixer Lua
Written by General BlackDragon
Version 1.0 - 2-2-2019 --]]

print("Loading _PropHeightFix.lua");

local _PropHeightFix = {}

local MissionStart = false

function _PropHeightFix.Start()

	MissionStart = true;
	
end

function _PropHeightFix.AddObject(h)

	local b_FixHeight = GetVarItemInt("network.session.ivar121");
	
	if b_FixHeight == 1 and not MissionStart then

		local Team = GetTeamNum(h);
		local ObjClass = GetClassLabel(h);
		
		if (Team == 0 or Team == 5) and (ObjClass == "CLASS_BUILDING" or ObjClass == "CLASS_SIGN" or ObjClass == "CLASS_PLANT") then
			
			local Pos = GetPosition(h);
			local Terrain = TerrainFindFloor(Pos);
			
			if Pos.y < Terrain then
				
				print("Logging Neutral Object Underground: " .. GetOdf(h) .. " Pos: X:" .. Pos.x .. " Y: " .. Pos.y .. " Z:" .. Pos.z .. " Height Below Ground: " .. Terrain - Pos.y);
			
				Pos.y = Terrain;
				SetPosition(h, Pos);
			end
		end
	end
end

print("Finished _PropHeightFix.lua");

return _PropHeightFix;