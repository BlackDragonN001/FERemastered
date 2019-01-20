

local ObjectList = { }

local tank = nil
local player = nil
local mapClear = false


function Start()

	ObjectList = GetAllGameObjectHandles();
	
	local bsaveload = GetVarItemInt("network.session.ivar120");
	
	local filename = "testload.txt";

	player = GetPlayerHandle();

	-- Save the entire map.
	if bsaveload == 1 then
		WriteToFile(filename, "//Preload ODF List" , false);
		WriteToFile(filename, "[ObjectList]");
		WriteToFile(filename, "ObjectCount = " .. #ObjectList);
		
		for n = 1, #ObjectList do
		
			if not IsPlayer(ObjectList[n]) then
			
				WriteToFile(filename, "[ObjectList" .. n  .."]");
				
				local mystring = "ObjectODF = " .. GetCfg(ObjectList[n]);
				WriteToFile(filename, mystring);
				
				local mystring = "ObjectTeam = " .. GetTeamNum(ObjectList[n]);
				WriteToFile(filename, mystring);
				
				local label = "";
				if not GetLabel(ObjectList[n]) == nil then
					label = GetLabel(ObjectList[n]);
				end
				
				local mystring = "ObjectLabel = \"" .. label .. "\"";
				WriteToFile(filename, mystring);
				
				local Position = GetTransform(ObjectList[n]);
				mystring = "Front = \"" .. Position.front.x .. " " .. Position.front.y .. " " .. Position.front.z .. "\"";
				WriteToFile(filename, mystring);
				mystring = "Right = \"" .. Position.right.x .. " " .. Position.right.y .. " " .. Position.right.z .. "\"";
				WriteToFile(filename, mystring);
				mystring = "Up = \"" .. Position.up.x .. " " .. Position.up.y .. " " .. Position.up.z .. "\"";
				WriteToFile(filename, mystring);
				mystring = "Posit = \"" .. Position.posit.x .. " " .. Position.posit.y .. " " .. Position.posit.z .. "\"";
				WriteToFile(filename, mystring);
				
				mystring = "MaxHealth = " .. tostring(GetMaxHealth(ObjectList[n]));
				WriteToFile(filename, mystring);
				
				mystring = "CurHealth = " .. tostring(GetCurHealth(ObjectList[n]));
				WriteToFile(filename, mystring);

			end
		end
	elseif bsaveload == 2 then -- Load the entire map.
	
		-- Erase entire map.
		for n = 1, #ObjectList do
			if not IsPlayer(ObjectList[n]) then
				RemoveObject(ObjectList[n]);
			end
		end
		
		-- Load the objects.
		local count = GetODFInt(filename, "ObjectList", "ObjectCount");
		
		print("Object count " .. count);
		
		for n = 1, count do
		
			local mystring = "ObjectList" .. n;
		
			local odf = GetODFString(filename, mystring, "ObjectODF");
			local team = GetODFInt(filename, mystring, "ObjectTeam");
			local label = GetODFString(filename, mystring, "ObjectLabel");
			
			local mat = IdentityMatrix
			
			mat.front = GetODFVector(filename, mystring, "Front");
			mat.right = GetODFVector(filename, mystring, "Right");
			mat.up = GetODFVector(filename, mystring, "Up");
			mat.posit = GetODFVector(filename, mystring, "Posit");
			
			local maxh = GetODFLong(filename, mystring, "MaxHealth");
			local curh = GetODFLong(filename, mystring, "CurHealth");
			
			local h = BuildObject(odf, team, mat);
			SetLabel(h, label);
			SetMaxHealth(h, maxh);
			SetCurHealth(h, curh);
		
		end	
	end

end
