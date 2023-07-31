--[[ BZCC DLL Utils Helper
Written by General BlackDragon
Version 1.0 2-10-2019 --]]

local _DLLUtils = {}

-- Returns true if h is a recycler or recycler vehicle, false
-- if h is invalid, or not a recycler
function IsRecycler(h)

	local ObjClass = GetClassLabel(h);
	if(ObjClass == nil) then
		return false;
	end

	return (ObjClass == "CLASS_RECYCLERVEHICLE") or (ObjClass == "CLASS_RECYCLER") or (ObjClass == "CLASS_RECYCLERVEHICLEH");
end


-- Given a team #, counts the number of allied human players currently
-- playing. (i.e. not the number of possible allies, but the number of
-- actual allies) Note: should return at least 1, because each team is
-- an ally of itself. Does not count the neutral team (0), which is an
-- ally of all teams by default.
function CountAlliedPlayers(team)

	local count = 0;
	
	for i = 1, MAX_TEAMS
	do
		if(IsTeamAllied(i, team))
		then
			local h = GetPlayerHandle(i);
			if(h ~= nil)
			then
				count = count + 1;
			end
		end -- team is allied
	end

	return count;
end

-- Sanity wrapper for GetVarItemStr. Reads the specified svar, and
-- verifies it's present in the specified list. If not found in
-- there, returns NULL.
function GetCheckedNetworkSvar(svar, listType)

	local svarStr = "network.session.svar" .. svar;

	local pContents = GetVarItemStr(svarStr);
	-- Error finding? Bail, asap
	if(pContents == nil or pContents == "")
	then
		return nil;
	end

	local count = GetNetworkListCount(listType);
	for i = 0, count
	do
		local pItem = GetNetworkListItem(listType, i);
		if(pItem ~= nil) then

			if(pContents == pItem)
			then
				-- Got a good match. Return it
				return pContents;
			end
		end
	end

	-- No match found. Report error
	return nil;
end

-- Helper function for SetupTeam(), returns an appropriate spawnpoint.
function GetSpawnpointForTeam(Team, FRIENDLY_SPAWNPOINT_MAX_ALLY, FRIENDLY_SPAWNPOINT_MIN_ENEMY, RANDOM_SPAWNPOINT_MIN_ENEMY);
	
	local spawnpointPosition = SetVector(0, 0, 0);
	
	-- Pick a random, ideally safe spawnpoint.
	local pSpawnPointInfo = GetAllSpawnpoints(Team);
	local count = #pSpawnPointInfo;
	
	-- Designer didn't seem to put any spawnpoints on the map :(
	if(count == 0)
	then
		return spawnpointPosition;
	end

	-- First pass: see if a spawnpoint exists with this team #
	--
	-- Note: using a temporary array allocated on stack to keep track
	-- of indices.
	local pIndices = { };
	
	local indexCount = 0;
	for i = 1, count
	do
		if(pSpawnPointInfo[i].Team == Team)
		then
			pIndices[indexCount] = i;
			indexCount = indexCount + 1;
		end
	end

	-- Did we find any spawnpoints in the above search? If so,
	-- randomize out of that list and return that
	if(indexCount > 0)
	then
		local index = 0;
		-- Might be unnecessary, but make sure we return a valid index
		-- in [0,indexCount)
		local index = math.min(math.floor(GetRandomFloat(indexCount)),indexCount-1);
		return pSpawnPointInfo[pIndices[index]].Position;
	end
	
	if(not IsTeamplayOn())
	then
		-- 1.5 pass: build up a list of spawnpoints that appear to have
		-- nobody close, randomly pick one of those.
		indexCount = 0;
		for i = 1, count
		do
			if((pSpawnPointInfo[i].DistanceToClosestSameTeam >= FRIENDLY_SPAWNPOINT_MAX_ALLY) and
				(pSpawnPointInfo[i].DistanceToClosestAlly >= FRIENDLY_SPAWNPOINT_MAX_ALLY) and
			   (pSpawnPointInfo[i].DistanceToClosestEnemy >= FRIENDLY_SPAWNPOINT_MIN_ENEMY))
			then
				pIndices[indexCount] = i;
				indexCount = indexCount + 1;
			end
		end

		-- Did we find any spawnpoints in the above search? If so,
		-- randomize out of that list and return that
		if(indexCount > 0)
		then
			local index = 0;
			-- Might be unnecessary, but make sure we return a valid index
			-- in [0,indexCount)
			local index = math.min(math.floor(GetRandomFloat(indexCount)),indexCount-1);
			return pSpawnPointInfo[pIndices[index]].Position;
		end
	end

	-- Second pass: build up a list of spawnpoints that appear to have
	-- allies close, randomly pick one of those.
	indexCount = 0;
	for i = 1, count
	do
		if(((pSpawnPointInfo[i].DistanceToClosestSameTeam < FRIENDLY_SPAWNPOINT_MAX_ALLY) or
			(pSpawnPointInfo[i].DistanceToClosestAlly < FRIENDLY_SPAWNPOINT_MAX_ALLY)) and
		   (pSpawnPointInfo[i].DistanceToClosestEnemy >= FRIENDLY_SPAWNPOINT_MIN_ENEMY))
		then
			pIndices[indexCount] = i;
			indexCount = indexCount + 1;
		end
	end

	-- Did we find any spawnpoints in the above search? If so,
	-- randomize out of that list and return that
	if(indexCount > 0)
	then
		local index = 0;
		-- Might be unnecessary, but make sure we return a valid index
		-- in [0,indexCount)
		local index = math.min(math.floor(GetRandomFloat(indexCount)),indexCount-1);
		return pSpawnPointInfo[pIndices[index]].Position;
	end

	-- Third pass: Make up a list of spawnpoints that appear to have
	-- no enemies close.
	indexCount = 0;
	for i = 1, count
	do
		if(pSpawnPointInfo[i].DistanceToClosestEnemy >= RANDOM_SPAWNPOINT_MIN_ENEMY)
		then
			pIndices[indexCount] = i;
			indexCount = indexCount + 1;
		end
	end

	-- Did we find any spawnpoints in the above search? If so,
	-- randomize out of that list and return that
	if(indexCount > 0)
	then
		local index = 0;
		-- Might be unnecessary, but make sure we return a valid index
		-- in [0,indexCount)
		local index = math.min(math.floor(GetRandomFloat(indexCount)),indexCount-1);
		return pSpawnPointInfo[pIndices[index]].Position;
	end

	-- If here, all spawnpoints have an enemy within
	-- RANDOM_SPAWNPOINT_MIN_ENEMY.  Fallback to old code.
	return GetRandomSpawnpoint(Team);
	
end


--[[-- FE Utils --]]--

function DoEjectRatio(h)
	if (GetRandomFloat(1.0) > GetEjectRatio(h))
		return EJECTKILLRETCODES_DLLHANDLED;
	else
		return EJECTKILLRETCODES_DOEJECTPILOT;
	end
end

--gets an object handle by label. If it doesn't exist, throws an error.
function GetHandleOrDie(name)
	return GetHandle(name) or error("Error: object '"..name.."' not found!");
end

--snaps the pos to the terrain height at that location
function TerrainFloor(pos)
	return SetVector(pos.x, TerrainFindFloor(pos), pos.z);
end

-- New method for building and labelling units. - AI_Unit.
function BuildObjectAndLabel(handle, team, pos, label) 

	local h = GetHandle(label);

	if(h == nil) then
		if type(pos) == "string" then
			h = BuildObject(handle, team, GetPositionNear(GetPosition(pos), 5.0, 10.0));
		else
			h = BuildObject(handle, team, pos);
		end

		if (label ~= nil) then
			SetLabel(h, label);
		end
    end

    return h;
end

-- Get the Difficulty setting from Player Options.
function GetDifficulty()

	if IsNetworkOn() then
		-- return ???? MP difficulty setting, possibly from ivar?
	else
		return GetVarItemInt("options.play.difficulty");
	end
end

-- Phase out in place of internal DLL teleportation code, using PreTeleport and PostTeleport callbacks? (DLL driven VFX for Portals) -GBD
-- Teleports Handle h to Handle dest, with optional offset.
function Teleport(h, dest, offset)
	if not IsAround(h) then 
		return false;
	end

	--[[ -- Original BS-er Code converted. -GBD
	local PortalPos = GetPosition(dest);
	local Front = GetFront(h);
	local StartPos = GetPosition(h);
	
	PortalPos.x = PortalPos.x + Front.x * offset;
	PortalPos.z = PortalPos.z + Front.z * offset;
	
	Front.x = Front.x * 8.0;
	Front.z = Front.z * 8.0;
	
	if h == GetPlayerHandle() then
		SetColorFade(1.0, 1.0, 32767);
		StartSoundEffect("teleport.wav", nil);	--sound effects seem to get cut off when player is teleporting
		AddHealth(h, -15);
	else
		BuildObject("TeleportOut", 0, PortalPos);
		BuildObject("TeleportIn", 0, StartPos);
		Stop(h, 0);
	end
	
	SetPosition(h, PortalPos);
	SetVelocity(h, Front);
	--]]
	
	
	
	--[[-- Transport code from BZC DLL. Offset based on matricies. Bit complex? Requires entrance portal position. -GBD
	local StartPortal = GetTransform(startportal);
	local EndPortal = GetTransform(dest);
	local ShipPosition = GetTransform(h);
	
	local NewMatrix = EndPortal;
	local Teleport = Identity_Matrix;
	
	local Velocity = SetVector(0, 0, 0);
	local ShipVelocity = GetVelocity(h);
	
	NewMatrix.right = Neg_Vector(NewMatrix.right); -- Flip the ship around to come out the opposite direction compared to portal front.
	NewMatrix.front = Neg_Vector(NewMatrix.front); -- ^ ditto.
	local InvStartPortal = Matrix_Inverse(StartPortal); -- Inverse Matrix.
	Teleport = InvStartPortal * EndPortal; --Matrix_Multiply(InvStartPortal, EndPortal); -- Apply inverse angle to Destination Matrix.
	NewMatrix = ShipPosition * Teleport; --Matrix_Multiply(ShipPosition, Teleport); // Apply Position offset to that.
	Velocity = Vector_Rotate(Teleport, ShipVelocity); // Apply Velocity Rotation.

	-- Off set Position.
	local ShipOffset = Vector_TransformInv(ShipPosition, StartPortal.posit); -- Calculate position offset.
	NewMatrix.posit = Vector_Transform(NewMatrix, ShipOffset); -- Apply position offset.
	--Velocity = Vector_Rotate(Teleport, ShipVelocity); -- Apply velocity rotation.
	
	-- Appy code offset.
	NewMatrix.posit = NewMatrix.posit + (EndPortal.front * offset);
	Velocity = EndPortal.front * math.max(ShipVelocity.x, ShipVelocity.z);
	
	BuildObject("teleportin", 0, ShipPosition);
	
	-- Teleport them.
	SetTransform(h, NewMatrix);
	SetVelocity(h, Velocity);
	
	BuildObject("teleportout", 0, NewMatrix);
	--]]



	--[[ Old code from Kevin? Position is in world coordinates, not local coordinates. -GBD
	BuildObject("teleportin", 0, GetPosition(h));
	
	local dir = Normalize(offset);
	local pos = GetPosition(dest) + offset;
	
	BuildObject("teleportout", 0, pos);
	
	SetPosition(h, pos);
	SetVelocity(h, Length(GetVelocity(h)) * dir);
	--]]
	
	
	-- Simpler, Transform based code. -GBD
	BuildObject("teleportin", 0, GetPosition(h));
	
	local pos = nil;
	if type(dest) == "string" then
		-- If we are a path point then make a new matrix with no directional data
		pos = BuildDirectionalMatrix(GetPosition(dest), nil);
	elseif IsAround(dest) then
		pos = GetTransform(dest);
	else
		return nil;
	end

	pos.posit = pos.posit + pos.front * offset;
	pos.posit.y = pos.posit.y + 5;
	
	BuildObject("teleportout", 0, pos);
	
	SetTransform(h, pos);
	SetVelocity(h, Length(GetVelocity(h)) * pos.front);
	
	if h == GetPlayerHandle() then
		SetColorFade(1.0, 1.0, 32767);
		StartSoundEffect("teleport.wav", nil);	--sound effects seem to get cut off when player is teleporting
		--AddHealth(h, -15);
	end
	
	return true;
end

-- Teleports In (spawns) an ODF at a Portal Handle dest.
function TeleportIn(odf, team, dest, offset, label)

	local pos = nil;
	local buildFx = true;
	
	if type(dest) == "string" then
	
		pos = GetPosition(dest);
	
	elseif IsAround(dest) then
	
	--	local pos = GetPosition(dest) + offset; -- Need to localize to object coordinates, not world coordinates. -GBD
	--	pos = BuildDirectionalMatrix(pos);
	
		pos = GetTransform(dest);
		pos.posit = pos.posit + pos.front * offset;
		pos.posit.y = pos.posit.y + 5;
		
	--	if GetPortalDest(dest) ~= nil then -- If this portal has a destination set, it's FX are on, use them.
			SetPortalEffectEnd(dest, 7, 0, false); -- HACK! assume we are using "hbport" out effect. I don't feel like opening and reading ODFs for this... -GBD
			buildFx = false;
	--	end
	else
		return nil;
	end
	
	if buildFx then
		BuildObject("teleportin", 0, pos);
	end
	
	-- FX has been placed in center of portal. Now add some spread so multiple units don't get clumped up together... -GBD
	pos = GetPositionNear(pos, 3.0, 5.0);
	local h = BuildObject(odf, team, pos);
	
	if (label ~= nil) then
		SetLabel(h, label);
	end
	
	return h;
end

--removes the object with a teleportout effect
function TeleportOut(h)
	BuildObject("teleportout", 0, BuildDirectionalMatrix(GetPosition(h)));
	RemoveObject(h);
end

-- Spawns an object around a central position.
function SpawnObjectAround(odf, team, where, minRadius, maxRadius)

	local origin = SetVector(0, 0, 0);
	
	if type(where) == "string" then
		origin = GetPosition("where", 0);
	elseif IsAround(where) then
		origin = GetPosition(handle);
	else
		origin = where;
	end
	
	local pos = GetPositionNear(origin, minRadius, maxRadius);
	pos.y = TerrainFindFloor(pos.x, pos.z);
	
	return BuildObject(odf, team, pos);
end

return _DLLUtils;