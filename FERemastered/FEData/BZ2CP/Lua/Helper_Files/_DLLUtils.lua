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

return _DLLUtils;