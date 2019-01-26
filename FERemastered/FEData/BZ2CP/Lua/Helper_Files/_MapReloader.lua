--[[ Map Reloader Lua
Written by General BlackDragon
Version 1.0 - 1-24-2019

For use with command lines to load/replace objects on a .BZN. Instructions:
-- To Save objects, load the game with /ivar 120 1
-- To specify a specific ODF to save/load, use /svar 31 blah.odf
-- To Save objects and delete the objects after saving, use /ivar 120 3
-- To Load objects, load the game with /ivar 120 2

The object lists are saved to a .txt file matching the BZN file name in Documents\My Games\Battlezone Combat Commander\logs\
Loading deletes all instances of the specified svar 31 from the map. To skip deleting on load, put some dummy value in svar 31.
Note: the .odf extention is required on the svar 31 parameter. --]]

print("Loading _MapReloader.lua");

local _MapReloader = {}

function bool_to_number(value)
  return value and 1 or 0
end

local ObjectList = { }

local tank = nil
local player = nil
local mapClear = false
local ObjectCount = 0

function _MapReloader.InitialSetup()

	--print("MAPRELOADER_INITSETUP");


	ObjectList = GetAllGameObjectHandles();
	
	local b_saveload = GetVarItemInt("network.session.ivar120");
	local s_odfname = GetVarItemStr("network.session.svar31");
	
	local filename = GetMissionFilename(); --"testload.txt";
	filename = string.sub(filename, 0, string.len(filename)-3);
	filename = filename .. "txt";

	player = GetPlayerHandle();

	-- Save the entire map.
	if b_saveload == 1 or b_saveload == 3 then
		
		print("Created Object List: " .. filename);
	
		WriteToFile(filename, "//Preload ODF List" , false);
		WriteToFile(filename, "[ObjectList]");
		
		for n = 1, #ObjectList do
			if not IsPlayer(ObjectList[n]) and (s_odfname == "" or GetOdf(ObjectList[n]) == s_odfname) then
				ObjectCount = ObjectCount + 1;
			end
		end
		
		WriteToFile(filename, "ObjectCount = " .. ObjectCount); --#ObjectList);
		
		local iterCount = 0;
		
		for n = 1, #ObjectList do
		
			-- If this is an object we care about, save it's info.
			if not IsPlayer(ObjectList[n]) and (s_odfname == "" or GetOdf(ObjectList[n]) == s_odfname) then
			
				iterCount = iterCount + 1;
				WriteToFile(filename, "[ObjectList" .. iterCount  .."]");
				
				local Odf = GetOdf(ObjectList[n]);
				Odf = string.sub(Odf, 0, string.len(Odf)-4);				
				local mystring = "ObjectODF = \"" .. Odf .. "\""; --GetCfg(ObjectList[n])
				WriteToFile(filename, mystring);
				
				local mystring = "ObjectTeam = " .. GetTeamNum(ObjectList[n]);
				WriteToFile(filename, mystring);
				
				local mystring = "ObjectPTeam = " .. GetPerceivedTeam(ObjectList[n]);
				WriteToFile(filename, mystring);
				
				-- Find the default label.
				local deflabel = GetOdf(ObjectList[n]);
				deflabel = string.sub(deflabel, 0, string.len(deflabel)-4);
				deflabel = "unnamed_" .. deflabel;	
			print(deflabel);
				
				local label = GetLabel(ObjectList[n]);
				if label == nil or label == deflabel then
					label = ""
				end
				local mystring = "ObjectLabel = \"" .. label .. "\"";
				WriteToFile(filename, mystring);
				
				local name = GetObjectiveName(ObjectList[n]);
				if name == nil then
					name = ""
				end
				local mystring = "ObjectName = \"" .. name .. "\"";
				WriteToFile(filename, mystring);
				
				local pilot = GetPilotClass(ObjectList[b]);
				if pilot == nil then
					pilot = ""
				end
				local mystring = "ObjectPilot = \"" .. pilot .. "\"";
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

				local Velocity = GetVelocity(ObjectList[n]);
				mystring = "Velocity = \"" .. Velocity.x .. " " .. Velocity.y .. " " .. Velocity.z .. "\"";
				WriteToFile(filename, mystring);
				
				local Omega = GetOmega(ObjectList[n]);
				mystring = "Omega = \"" .. Omega.x .. " " .. Omega.y .. " " .. Omega.z .. "\"";
				WriteToFile(filename, mystring);
				
				local Deployed = IsDeployed(ObjectList[n]);
				mystring = "IsDeployed = " .. tostring(Deployed);
				WriteToFile(filename, mystring);
				
				mystring = "MaxHealth = " .. tostring(GetMaxHealth(ObjectList[n]));
				WriteToFile(filename, mystring);
				
				mystring = "CurHealth = " .. tostring(GetCurHealth(ObjectList[n]));
				WriteToFile(filename, mystring);
				
				mystring = "MaxAmmo = " .. tostring(GetMaxAmmo(ObjectList[n]));
				WriteToFile(filename, mystring);
				
				mystring = "CurAmmo = " .. tostring(GetCurAmmo(ObjectList[n]));
				WriteToFile(filename, mystring);
				
				local MaxScrap = GetScavengerMaxScrap(ObjectList[n])
				if MaxScrap == nil then
					MaxScrap = -1
				end
				mystring = "MaxScrap = " .. tostring(MaxScrap);
				WriteToFile(filename, mystring);
				
				local CurScrap = GetScavengerCurScrap(ObjectList[n])
				if CurScrap == nil then
					CurScrap = -1
				end
				mystring = "CurScrap = " .. tostring(CurScrap);
				WriteToFile(filename, mystring);
				
				local Skill = GetSkill(ObjectList[n])
				if Skill == nil then
					Skill = -1
				end
				mystring = "Skill = " .. tostring(Skill);
				WriteToFile(filename, mystring);
				
				local Independence = GetIndependence(ObjectList[n])
				if Independence == nil then
					Independence = -1
				end
				mystring = "Independence = " .. tostring(Independence);
				WriteToFile(filename, mystring);
				
				local Group = GetGroup(ObjectList[n])
				if Group == nil then
					Group = -1
				end
				mystring = "Group = " .. tostring(Group);
				WriteToFile(filename, mystring);
			print("Group is: " .. tostring(Group));
			
				local lifespan = GetRemainingLifespan(ObjectList[n])
				if lifespan == nil then
					lifespan = -1
				end
				mystring = "Lifespan = " .. tostring(lifespan);
				WriteToFile(filename, mystring);
				
				mystring = "CanSnipe = " .. tostring(GetCanSnipe(ObjectList[n]));
				WriteToFile(filename, mystring);
				
				local CurTarget = GetTarget(ObjectList[n]);
				if CurTarget ~= nil then
					local targetlabel = GetLabel(CurTarget);
					if targetlabel == nil then
						targetlabel = ""
					end
					local mystring = "CurTargetLabel = \"" .. targetlabel .. "\"";
					WriteToFile(filename, mystring);
					
					SetLabel(CurWho, "Object" .. n .. "_Target");
				end				
			
				mystring = "CurCommand = " .. tostring(GetCurrentCommand(ObjectList[n]));
				WriteToFile(filename, mystring);
				
				local CurWho = GetCurrentWho(ObjectList[n]);
				if CurWho ~= nil then
					local wholabel = GetLabel(CurWho);
					if wholabel == nil then
						wholabel = ""
					end
					local mystring = "CurWhoLabel = \"" .. wholabel .. "\"";
					WriteToFile(filename, mystring);
					
					SetLabel(CurWho, "Object" .. n .. "_Who");
				end
				local CurWhere = GetCurrentCommandWhere(ObjectList[n]);
				mystring = "CurWhere = \"" .. CurWhere.x .. " " .. CurWhere.y .. " " .. CurWhere.z .. "\"";
				WriteToFile(filename, mystring);
				
			
				-- WeaponMask? CurrCommand?
				
				
				-- If we want to delete this object immediately, do it.
				if b_saveload == 3 then
					RemoveObject(ObjectList[n]);
					print("Removing Object " .. label);
				end

			end
		end
	elseif b_saveload == 2 then -- Load the entire map.
	
		print("Loaded Object List: " .. filename);
	
		-- Erase entire map.
		for n = 1, #ObjectList do
			if not IsPlayer(ObjectList[n]) and (s_odfname == "" or GetOdf(ObjectList[n]) == s_odfname) then
				RemoveObject(ObjectList[n]);
			end
		end
		
		-- Load the objects.
		local count = GetODFInt(filename, "ObjectList", "ObjectCount");
		
		print("Object count " .. count);
		
		for n = 1, count do
			
			-- Read the data.
			local mystring = "ObjectList" .. n;
		
			local odf = GetODFString(filename, mystring, "ObjectODF");
			local team = GetODFInt(filename, mystring, "ObjectTeam");
			local pteam = GetODFInt(filename, mystring, "ObjectPTeam");
			local label = GetODFString(filename, mystring, "ObjectLabel");
			local name = GetODFString(filename, mystring, "ObjectName");
			local pilot = GetODFString(filename, mystring, "ObjectPilot");
			
			local mat = IdentityMatrix
			
			mat.front = GetODFVector(filename, mystring, "Front");
			mat.right = GetODFVector(filename, mystring, "Right");
			mat.up = GetODFVector(filename, mystring, "Up");
			mat.posit = GetODFVector(filename, mystring, "Posit");
			local velocity = GetODFVector(filename, mystring, "Velocity");
			local omega = GetODFVector(filename, mystring, "Omega");
			
			local deployed = GetODFBool(filename, mystring, "IsDeployed");
			
			local maxh = GetODFLong(filename, mystring, "MaxHealth");
			local curh = GetODFLong(filename, mystring, "CurHealth");
			local maxa = GetODFLong(filename, mystring, "MaxAmmo");
			local cura = GetODFLong(filename, mystring, "CurAmmo");
			local maxs = GetODFLong(filename, mystring, "MaxScrap");
			local curs = GetODFLong(filename, mystring, "CurScrap");
			
			local skill = GetODFInt(filename, mystring, "Skill");
			local independence = GetODFInt(filename, mystring, "Independence");
			local group = GetODFInt(filename, mystring, "Group");
			
			local lifespan = GetODFFloat(filename, mystring, "Lifespan");
			local cansnipe = bool_to_number(GetODFBool(filename, mystring, "CanSnipe"));
			
			local targetlabel = GetODFString(filename, mystring, "CurTargetLabel");
			
			local curcmd = GetODFInt(filename, mystring, "CurCommand");
			local wholabel = GetODFString(filename, mystring, "CurWhoLabel");
			local curwhere = GetODFVector(filename, mystring, "CurWhere");
			
			-- Build the object, and set it's variables.
			local h = BuildObject(odf, team, mat);
			SetVelocity(h, velocity);
			SetOmega(h, omega);
			if(deployed) then
				Deploy(h);
			end
			
			if label ~= "" then
				SetLabel(h, label);
			end
			
			if name ~= "" then
				SetObjectiveName(h, name);
			end
			
			if pilot ~= "" then
				SetPilotClass(h, pilot);
			end
			
			SetPerceivedTeam(h, pteam);
			SetMaxHealth(h, maxh);
			SetCurHealth(h, curh);
			SetMaxAmmo(h, maxa);
			SetCurAmmo(h, cura);
			
			if maxs ~= -1 then
				SetScavengerMaxScrap(h, maxs);
			end
			
			if curs ~= -1 then
				SetScavengerCurScrap(h, curs);
			end
			
			if skill ~= -1 then
				SetSkill(h, skill);
			end
			
			if independence ~= -1 then
				SetIndependence(h, independence);
			end
			
			if group ~= -1 then
				SetGroup(h, group);
			end
			
			if lifespan ~= -1 then
				SetLifespan(h, lifespan);
			end
			
			SetCanSnipe(h, cansnipe);
			
			local NewTarget = GetHandle("Object" .. n .. "_Target");
			if NewTarget ~= nil then
				SetLabel(NewTarget, targetlabel);
				SetTarget(h, NewTarget);
			end
			
			local priority = bool_to_number(group == -1);
			
			local NewWho = GetHandle("Object" .. n .. "_Who");
			if NewWho ~= nil then
				SetLabel(NewWho, wholabel);
				
				if not IsNullVector(curwhere) then
					SetCommand(h, curcmd, priority, NewWho, curwhere);
				else
					SetCommand(h, curcmd, priority, NewWho);
				end
			else
				if not IsNullVector(curwhere) then
					SetCommand(h, curcmd, priority, 0, curwhere);
				else
					SetCommand(h, curcmd, priority);
				end
			end
			
			
		
		end	
	end

end

print("Finished _MapReloader.lua");

return _MapReloader;