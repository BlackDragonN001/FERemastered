--[[ BZCC DLL Utils Helper
Written by General BlackDragon
Version 1.0 2-10-2019 --]]

local _DLLUtils = {}

-- Returns true if h is a recycler or recycler vehicle, false
-- if h is invalid, or not a recycler
function _DLLUtils.IsRecycler(h)

	local ObjClass = GetObjInfo_GOClass(h);
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
function _DLLUtils.CountAlliedPlayers(team)

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
function _DLLUtils.GetCheckedNetworkSvar(svar, listType)

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
function _DLLUtils.GetSpawnpointForTeam(Team, FRIENDLY_SPAWNPOINT_MAX_ALLY, FRIENDLY_SPAWNPOINT_MIN_ENEMY, RANDOM_SPAWNPOINT_MIN_ENEMY);
	
	local spawnpointPosition = SetVector(0, 0, 0);
	
	-- Pick a random, ideally safe spawnpoint.
	--SpawnPointInfo* pSpawnPointInfo;
	--size_t i,count = GetAllSpawnpoints(pSpawnPointInfo, Team);
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
	--size_t *pIndices = reinterpret_cast<size_t*>(_alloca(count * sizeof(size_t)));
	--memset(pIndices, 0, count * sizeof(size_t));
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
		repeat
			index = math.floor(GetRandomFloat(indexCount)) + 1;
		until not(index >= indexCount);
		return pSpawnPointInfo[pIndices[index]].Position;
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
		repeat
			index = math.floor(GetRandomFloat(indexCount)) + 1;
		until not(index >= indexCount);
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
		repeat
			index = math.floor(GetRandomFloat(indexCount)) + 1;
		until not(index >= indexCount);
		return pSpawnPointInfo[pIndices[index]].Position;
	end

	-- If here, all spawnpoints have an enemy within
	-- RANDOM_SPAWNPOINT_MIN_ENEMY.  Fallback to old code.
	return GetRandomSpawnpoint(Team);
	
end


return _DLLUtils;