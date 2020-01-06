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

--snaps the pos to the terrain height at that location
function TerrainFloor(pos)
	return SetVector(pos.x, TerrainFindFloor(pos), pos.z);
end

-- New method for building and labelling units. - AI_Unit.
function BuildObjectAndLabel(handle, team, pos, label) 
    local h = BuildObject(handle, team, pos);

    if (label ~= nil) then
        SetLabel(h, label);
    end

    return h;
end

-- Teleports Handle h to Handle dest, with optional offset.
function Teleport(h, dest, offset)
	if not IsAround(h) then 
		return; 
	end
	
	BuildObject("teleportout", 0, GetPosition(h));
	local dir = Normalize(offset);
	local pos = GetPosition(dest) + offset;
	BuildObject("teleportin", 0, pos);
	SetPosition(h, pos);
	SetVelocity(h, Length(GetVelocity(h))*dir);
	if h == GetPlayerHandle() then
		StartSoundEffect("teleport.wav", nil);	--sound effects seem to get cut off when player is teleporting
	end
end

-- Teleports In (spawns) an ODF at a Portal Handle dest.
function TeleportIn(odf, team, dest, offset)
	if IsAround(dest) then
		local pos = GetPosition(dest) + offset; -- Need to localize to object coordinates, not world coordinates. -GBD
		BuildObject("teleportin", 0, pos);
		return BuildObject(odf, team, pos);
	else
		return nil;
	end
end

--removes the object with a teleportout effect
function TeleportOut(h)
	BuildObject("teleportout", 0, GetPosition(h));
	RemoveObject(h);
end

return _DLLUtils;