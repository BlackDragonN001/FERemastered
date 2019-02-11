--[[ BZCC Deathmatch Mission Script 
Written by General BlackDragon
Version 1.0 2-10-2019 --]]


local MAX_FLOAT    =   3.4028e+38;


local VEHICLE_SPACING_DISTANCE = 20.0;

-- How many seconds sniped AI craft will stick around before
-- going boom.
local SNIPED_AI_LIFESPAN = 300.0; 

-- How far away a new craft will be from the old one
local RespawnMinRadiusAway = 10.0;
local RespawnMaxRadiusAway = 20.0;

-- How high up to respawn a pilot
local RespawnPilotHeight = 200.0;

-- How far allies will be from the commander's position
local AllyMinRadiusAway = 10.0;
local AllyMaxRadiusAway = 30.0;

local BotMinRadiusAway = 30.0;
local BotMaxRadiusAway = 100.0;

-- Tuning distances for GetSpawnpointForTeam()

-- Friendly spawnpoint: Max distance away for ally
local FRIENDLY_SPAWNPOINT_MAX_ALLY = 100.;
-- Friendly spawnpoint: Min distance away for enemy
local FRIENDLY_SPAWNPOINT_MIN_ENEMY = 300.;

-- Random spawnpoint: min distance away for enemy
local RANDOM_SPAWNPOINT_MIN_ENEMY = 150.;

local FIRST_AI_TEAM = 11;
local LAST_AI_TEAM = 15;

-- ---------- Scoring Values-- these are delta scores, added to current score --------
local ScoreForKillingCraft = 5;
local ScoreForKillingPerson = 5;
local ScoreForDyingAsCraft = -1;
local ScoreForDyingAsPerson = -1;

-- Unlike Strat/MPI, these are always on.
local PointsForAIKill = true;
local KillForAIKill = true;

-- -----------------------------------------------



local TempMsgString = nil;
local StaticTempMsgStr  = nil;

-- Temporary name for blasting ODF names into while building
-- them. *not* saved, do *not* count on its contents being valid
-- next time the dll is called.
local TempODFName = nil;
local RaceSetObjective = false; -- Done separately from regularly loaded varbs, done per-machine


function AddObject(h)

	-- Changed NM 11/22/01 - all AI is at skill 3 now by default.
	if(not IsPlayer(h)) 
	then
		-- Always get a random # to keep things in sync
		local UseSkill = (int)GetRandomFloat(4);
		if(UseSkill == 4)
			UseSkill = 3;

		if(m_AIUnitSkill<4)
			UseSkill = m_AIUnitSkill;

		SetSkill(h, UseSkill);
	end

end

-- Returns true if players can eject (or bail out) of their vehicles
-- depending on the game type, false if they should be killed when
-- they try and do so.
function GetCanEject(h)

	if(m_ShipOnlyMode)
		return false;

	-- Can't eject if the rabbit
	if((m_RabbitMode) && (h == m_RabbitTargetHandle))
		return false;

	switch (m_MissionType)
	then
	case DMSubtype_Normal:
	case DMSubtype_KOH:
	case DMSubtype_Loot:
		return true;

	default:
		return false;
	end
end

-- Returns true if players shouldn't be respawned as a pilot, but in
-- a piloted vehicle instead, i.e. during race mode
function Deathmatch01::GetRespawnInVehicle()

	if(m_ShipOnlyMode)
		return true;

	switch (m_MissionType)
	then
	case DMSubtype_Race2:
	case DMSubtype_Normal2:
		return true;

	default:
		return false;
	end
end


-- Given a race identifier, get the flag odf back
function GetInitialFlagODF(Race)

	strcpy_s(TempODFName, "ioflag01");
	TempODFName[0] = Race;
	return TempODFName;
end

-- Given a race identifier, get the stand odf back
function GetInitialFlagStandODF(Race)

	strcpy_s(TempODFName, "iostand01");
	TempODFName[0] = Race;
	return TempODFName;
end


-- Given a race identifier, get the pilot odf back
function GetInitialPlayerPilotODF(Race)

	strcpy_s(TempODFName, "ispilo");
	TempODFName[0] = Race;
	return TempODFName;
end


-- Gets the next vehicle ODF for the player on a given team.
function GetNextVehicleODF(TeamNum, Randomize)

	RandomizeType RType = Randomize_None; -- Default
	if(Randomize)
	then
		if(m_RespawnType == 1)
			RType = Randomize_ByRace;
		else if(m_RespawnType == 2)
			RType = Randomize_Any;
	end

	return GetPlayerODF(TeamNum, RType);
end

function GetNextRandomVehicleODF(Team)
	return GetPlayerODF(Team);
end


-- Helper function for SetupTeam(), returns an appropriate spawnpoint.
local Deathmatch01::GetSpawnpointForTeam(local Team)
then
	local spawnpointPosition;
	spawnpointPosition.x = spawnpointPosition.y = spawnpointPosition.z = 0.;

	-- Pick a random, ideally safe spawnpoint.
	SpawnpointInfo* pSpawnPointInfo;
	size_t i,count = GetAllSpawnpoints(pSpawnPointInfo, Team);

	-- Designer didn't seem to put any spawnpoints on the map :(
	if(count == 0)
	then
		return spawnpointPosition;
	end

	-- First pass: see if a spawnpolocal exists with this team #
	--
	-- Note: using a temporary array allocated on stack to keep track
	-- of indices.
	size_t* pIndices = reinterpret_cast<size_t*>(_alloca(count * sizeof(size_t)));
	memset(pIndices, 0, count * sizeof(size_t));
	size_t indexCount = 0;
	for(i=0; i<count; ++i)
	then
		if(pSpawnPointInfo[i].m_Team == Team)
		then
			pIndices[indexCount++] = i;
		end
	end

	-- Did we find any spawnpoints in the above search? If so,
	-- randomize out of that list and return that
	if(indexCount > 0)
	then
		size_t index = 0;
		-- Might be unnecessary, but make sure we return a valid index
		-- in [0,indexCount)
		do
		then
			index = static_cast<size_t>(GetRandomFloat(static_cast<float>(indexCount)));
		end while(index >= indexCount);
		return pSpawnPointInfo[pIndices[index]].m_Position;
	end

	-- Second pass: build up a list of spawnpoints that appear to have
	-- allies close, randomly pick one of those.
	indexCount = 0;
	for(i=0; i<count; ++i)
	then
		if(((pSpawnPointInfo[i].m_DistanceToClosestSameTeam < FRIENDLY_SPAWNPOINT_MAX_ALLY) ||
			(pSpawnPointInfo[i].m_DistanceToClosestAlly < FRIENDLY_SPAWNPOINT_MAX_ALLY)) &&
		   (pSpawnPointInfo[i].m_DistanceToClosestEnemy >= FRIENDLY_SPAWNPOINT_MIN_ENEMY))
		then
			pIndices[indexCount++] = i;
		end
	end

	-- Did we find any spawnpoints in the above search? If so,
	-- randomize out of that list and return that
	if(indexCount > 0)
	then
		size_t index = 0;
		-- Might be unnecessary, but make sure we return a valid index
		-- in [0,indexCount)
		do
		then
			index = static_cast<size_t>(GetRandomFloat(static_cast<float>(indexCount)));
		end while(index >= indexCount);
		return pSpawnPointInfo[pIndices[index]].m_Position;
	end

	-- Third pass: Make up a list of spawnpoints that appear to have
	-- no enemies close.
	indexCount = 0;
	for(i=0; i<count; ++i)
	then
		if(pSpawnPointInfo[i].m_DistanceToClosestEnemy >= RANDOM_SPAWNPOINT_MIN_ENEMY)
		then
			pIndices[indexCount++] = i;
		end
	end

	-- Did we find any spawnpoints in the above search? If so,
	-- randomize out of that list and return that
	if(indexCount > 0)
	then
		size_t index = 0;
		-- Might be unnecessary, but make sure we return a valid index
		-- in [0,indexCount)
		do
		then
			index = static_cast<size_t>(GetRandomFloat(static_cast<float>(indexCount)));
		end while(index >= indexCount);
		return pSpawnPointInfo[pIndices[index]].m_Position;
	end

	-- If here, all spawnpoints have an enemy within
	-- RANDOM_SPAWNPOINT_MIN_ENEMY.  Fallback to old code.
	return GetRandomSpawnpoint(Team);
end


-- Sets up the side's commander's extra vehicles, such a recycler or
-- more. Does *not* create the player vehicle for them, 
-- however. [That's to be done in SetupPlayer.] Safe to be called
-- multiple times for each player on that team. 
--
-- If Teamplay is off, this function is called once per player.
--
-- If Teamplay is on, this function is called only on the
-- _defensive_ team number for an alliance. 

void Deathmatch01::SetupTeam(local Team)
then
	-- Sanity checks: don't do anything that looks invalid
	if((Team < 0) || (Team >= MAX_TEAMS))
		return;

	-- Also, if we've already set up this team group, don't do anything
	if((IsTeamplayOn()) && (m_TeamIsSetUp[Team]))
		return;

	local TeamRace = GetRaceOfTeam(Team);

	if(IsTeamplayOn())
	then
		SetMPTeamRace(WhichTeamGroup(Team), TeamRace); -- Lock this down to prevent changes.
	end

	local Where;

	if(DMIsRaceSubtype[m_MissionType])
	then
		-- Race-- everyone starts off at spawnpolocal 0's position
		Where = GetSpawnpoint(0);
	end
	else if(m_MissionType == DMSubtype_CTF) 
	then
		-- CTF-- find spawnpolocal by team # 
		Where = GetSpawnpointForTeam(Team);
		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	end
	else
	then
		Where = GetSpawnpointForTeam(Team);

		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	end

	-- Store position we created them at for later
	m_TeamPos[3*Team+0] = Where.x;
	m_TeamPos[3*Team+1] = Where.y;
	m_TeamPos[3*Team+2] = Where.z;

	-- Find location to place flag at
	if (m_MissionType == DMSubtype_CTF)
	then
		-- CTF
		-- Find place to drop flag from AIPaths list
		local DesiredName[64];
		sprintf_s(DesiredName, "base%d", Team);

		local DesiredName2[64];
		sprintf_s(DesiredName2, "m_base%d", Team);

		local i, pathCount;
		local **pathNames;
		GetAiPaths(pathCount, pathNames);
		for (i = 0; i<pathCount; ++i)
		then
			local *label = pathNames[i];
			if(strcmp(label, DesiredName) == 0)
			then
				Handle FlagH = 0;
				Handle BaseH = GetHandle(DesiredName2); -- First look for an existing base. -GBD
				if(not BaseH)
					BaseH = BuildObject(GetInitialFlagStandODF(TeamRace), Team, label); -- Build race specific base. -GBD
				SetAnimation(BaseH, "loop", 0);

				if(BaseH)
					FlagH = BuildObject(GetInitialFlagODF(TeamRace), Team, BaseH); -- Place directly ontop of flag stand. -GBD
				else
					FlagH = BuildObject(GetInitialFlagODF(TeamRace), Team, label);
				SetAnimation(FlagH, "loop", 0);

				if (Team == 1)
				then
					m_Base1 = BaseH;
					m_Flag1 = FlagH;
				end
				else if (Team == 6)
				then
					m_Base2 = BaseH;
					m_Flag2 = FlagH;
				end
			end
		end

	end -- CTF Flag setup

	else if ((DMIsRaceSubtype[m_MissionType]) && (not m_RaceIsSetup)) 
	then
		local intCheckpointCount = 0;
		Handle hdlCheckpolocal = 0;
		do then
			intCheckpointCount++;
			sprintf_s(TempODFName, "checkpoint%d", intCheckpointCount);
			hdlCheckpolocal = GetHandle(TempODFName);
		end while(hdlCheckpoint);
		m_TotalCheckpoints = intCheckpointCount-1;

		m_RaceIsSetup = true;
	end

	if(IsTeamplayOn()) 
	then
		for(local i = GetFirstAlliedTeam(Team);i<= GetLastAlliedTeam(Team);i++) 
		then
			if(i~= Team)
			then
				-- Get a new position near the team's central position
				local NewPosition = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);

				-- In teamplay, store where offense players were created for respawns later
				m_TeamPos[3*i+0] = NewPosition.x;
				m_TeamPos[3*i+1] = NewPosition.y;
				m_TeamPos[3*i+2] = NewPosition.z;
			end -- Loop over allies not the commander
		end
	end

	m_TeamIsSetUp[Team] = true;

end

-- Tries to return a good target for the AI unit, orders them to go
-- after it.
void Deathmatch01::FindGoodAITarget(local index)
then

	-- Sanity check - if this AI craft went MIA, clear handle
	if(not IsAliveAndPilot2(m_AICraftHandles[index]))
	then
		m_AICraftHandles[index] = 0;
		return;
	end

	-- Rabbit mode? Hammer the "it" player, nothing else to do
	if((m_RabbitMode) && (m_AICraftHandles[index] ~= m_RabbitTargetHandle))
	then
		Handle TargetH = m_RabbitTargetHandle;
		if(IsAlive(TargetH))
			Attack(m_AICraftHandles[index], m_RabbitTargetHandle);
		return;
	end

	Handle nearestEnemy = GetNearestEnemy(m_AICraftHandles[index]);
	local i;
	for(i = 1;i<MAX_TEAMS;i++)
	then
		Handle PlayerH = GetPlayerHandle(i);
		-- Ignore any close-by pilots.
		if((nearestEnemy == PlayerH) && (IsAliveAndPilot(PlayerH)))
			nearestEnemy = 0;
	end

	-- Was our last action an attack? Consider powerups now.
	if(nearestEnemy && (not m_AILastWentForPowerup[index]))
	then
		Handle nearestPerson = GetNearestPerson(m_AICraftHandles[index], true, 100.0);

		float distToEnemy = GetDistance(m_AICraftHandles[index], nearestEnemy);

		if(nearestPerson)
		then
			float distToPerson = GetDistance(m_AICraftHandles[index], nearestPerson);

			-- Consider objects a bit farther away than closest enemy
			if(distToPerson < (distToEnemy * 1.2))
			then
				Goto(m_AICraftHandles[index], nearestPerson);
				m_AILastWentForPowerup[index] = true;
				m_PowerupGotoTime[index] = 0;
				m_AITargetHandles[index] = nearestPerson;
				return; -- exit...
			end -- Powerup is close
		end -- nearestPerson exists

		Handle nearestPowerup = GetNearestPowerup(m_AICraftHandles[index], true, 100.0);
		if(nearestPowerup)
		then
			float distToPowerup = GetDistance(m_AICraftHandles[index], nearestPowerup);

			-- Consider objects a bit farther away than closest enemy
			if(distToPowerup < (distToEnemy * 1.2))
			then
				Goto(m_AICraftHandles[index], nearestPowerup);
				m_AILastWentForPowerup[index] = true;
				m_PowerupGotoTime[index] = 0;
				m_AITargetHandles[index] = nearestPowerup;
				return; -- exit...
			end -- Powerup is close
		end -- nearestPerson exists
	end

	if(nearestEnemy)
	then
		-- Nothing to do here-- Got the target
	end
	else
	then
		-- Nearest enemy scan failed (found pilot, too far, 
		-- something). Try harder.
		float BestDist = 1e10;
		Handle BestHandle = 0;
		if(not m_HumansVsBots)
		then
			-- Scan botlist..
			--local i;
			for(i = 0;i<m_NumAIUnits;i++)
			then
				-- Can't attack self.
				if(i == index)
					continue;
				-- If don't have a craft for self, skip.
				if(not m_AICraftHandles[index])
					continue;

				Handle ThisBotH = m_AICraftHandles[i];
				-- If bot died, skip them.
				if(not IsAlive(ThisBotH))
					continue;
				-- Skip friendly AIs
				if(IsAlly(m_AICraftHandles[index], m_AICraftHandles[i]))
					continue;
				ThisBotH = m_AICraftHandles[i];
				Handle MyH = m_AICraftHandles[index];
				float ThisDist = GetDistance(MyH, ThisBotH);
				if((ThisDist > 0.01) && (ThisDist < BestDist))
				then
					-- Winner (of sorts). Store them.
					BestDist = ThisDist;
					BestHandle = m_AICraftHandles[i];
				end
			end -- Loop over all AI units.
		end -- Isn't humans vs bots, so need to consider bots.

		--local i;
		for(i = 1;i<MAX_TEAMS;i++)
		then
			Handle PlayerH = GetPlayerHandle(i);
			if(not PlayerH)
				continue;
			Handle PlayerH2 = PlayerH;

			-- Skip human pilots in this phase (GetWhoShotMe will pick up other attacks)
			if(IsAliveAndPilot(PlayerH2))
				continue;

			Handle MyH = m_AICraftHandles[index];
			float ThisDist = GetDistance(MyH, PlayerH);
			if((ThisDist > 0.01) && (ThisDist < BestDist))
			then
				-- Winner (of sorts). Store them.
				BestDist = ThisDist;
				BestHandle = PlayerH;
			end
		end-- loop over all teams.

		if(BestHandle)
		then
			nearestEnemy = BestHandle;
		end
	end -- Fallback for things.

	m_AITargetHandles[index] = nearestEnemy;
	-- Chargenot 
	if(nearestEnemy)
	then
		Attack(m_AICraftHandles[index], m_AITargetHandles[index]);
	end
	m_AILastWentForPowerup[index] = false; -- In combat modenot 
end

-- Sets up the specified AI unit, first time or later.
void Deathmatch01::BuildBotCraft(local index)
then
	_ASSERTE(m_AICraftHandles[index] == 0);
	local i;

	local theirTeam;

	if(m_RabbitMode)
		theirTeam = 14; -- until they become 'it', and on team 15
	else if(m_HumansVsBots)
		theirTeam = 15;
	else
	then
		-- Put them on a consistent team # based on their slot, so they'll
		-- respawn with the same team # later, etc.
		local NUM_AI_TEAMS = LAST_AI_TEAM - FIRST_AI_TEAM + 1;
		theirTeam = FIRST_AI_TEAM + (index % NUM_AI_TEAMS);
	end

	-- Find a valid human user, and use them to read the vehicles list.
	local APlayerTeam = 1; -- Absolute fallback, if you must
	for(i = 0;i<MAX_TEAMS;i++)
	then
		if((m_TeamIsSetUp[i]) && (GetPlayerHandle(i)))
			APlayerTeam = i;
	end

	local Where = GetRandomSpawnpoint(theirTeam); -- Try to spawn bots at a spawnpolocal that is "safe" for them. Jira 529. -GBD
	-- Somewhere near the spawnpoint..
	Where = GetPositionNear(Where, BotMinRadiusAway, BotMaxRadiusAway);
	-- Bounce them up a little.
	Where.y += 2+GetRandomFloat(4);
	local *NewCraftsODF = GetPlayerODF(APlayerTeam, Randomize_Any);

	m_AICraftHandles[index] = BuildObject(NewCraftsODF, theirTeam, Where);
	SetRandomHeadingAngle(m_AICraftHandles[index]);
	SetNoScrapFlagByHandle(m_AICraftHandles[index]);
	AddPilotByHandle(m_AICraftHandles[index]);

	-- Ok, find a 'victim' for this AI unit. :)
	FindGoodAITarget(index);
end -- BuildBotCraft()

-- Sets up the specified Animal unit, first time or later.
void Deathmatch01::SetupAnimal(local index)
then
	local AnimalTeam = 8 + (int)GetRandomFloat(6);

	-- Don't make animals allied w/ humans, go to another team
	if(m_HumansVsBots || m_RabbitMode)
		AnimalTeam = 13;

	local Where = GetRandomSpawnpoint();
	-- Somewhere near the spawnpoint..
	Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	-- Bounce them up in the air a little.
	Where.y += 2+GetRandomFloat(4);
	local *AnimalODF = (char*)(&m_AnimalConfig[0]);

	m_AnimalHandles[index] = BuildObject(AnimalODF, AnimalTeam, Where);
	SetRandomHeadingAngle(m_AnimalHandles[index]);
	SetNoScrapFlagByHandle(m_AnimalHandles[index]);
	--	AddPilotByHandle(m_AICraftHandles[index]);
end -- SetupAnimal()


-- For CTF, objectifies the other team's flag
void Deathmatch01::ObjectifyFlag(void)
then
	const Handle PlayerH = GetPlayerHandle();
	if(PlayerH == 0)
	then
		-- Shouldn't happen, but be safe in case it does
		return;
	end

	local team = GetTeamNum(PlayerH);
	local TeamBlock = WhichTeamGroup(team);
	if((IsTeamplayOn()) && (TeamBlock >= 0))
	then
		const Handle myFlag = (TeamBlock == 0) ? m_Flag1 : m_Flag2;
		const Handle opponentFlag = (TeamBlock == 0) ? m_Flag2 : m_Flag1;

		SetObjectiveOff(myFlag);
		SetObjectiveOn(myFlag);
		SetObjectiveName(myFlag, GetBZCCLocalizedString("cfg", "Defend Flagnot "));

		SetObjectiveOff(opponentFlag);
		SetObjectiveOn(opponentFlag);
		SetObjectiveName(opponentFlag, GetBZCCLocalizedString("cfg", "Capture Flagnot "));
	end
end



void Deathmatch01::ObjectifyRabbit(void)
then
	Handle PlayerH = GetPlayerHandle();
	if(PlayerH == m_RabbitTargetHandle)
	then
		ClearObjectives();
	end
	else
	then
		-- Force-reset this.
		SetObjectiveOff(m_RabbitTargetHandle);
		SetObjectiveOn(m_RabbitTargetHandle);
		SetObjectiveName(m_RabbitTargetHandle, GetBZCCLocalizedString("cfg", "Wabbitnot "));
		--			SetUserTarget(m_RabbitTargetHandle);
	end
end


-- This handle is the new rabbit. Target themnot 
void Deathmatch01::SetNewRabbit(const Handle h)
then
#ifndef EDITOR
	--		BZTrace(("SetNewRabbit(%08X)\n", h));
	local ODFName[64];
	GetObjInfo(h, Get_CFG, ODFName);
	BZTrace(("SetNewRabbit(%08X...), odf %s\n", h, ODFName));

	-- Ignore invalid handle.
	if(not h)
		return;

	Handle h2 = h;
	if(not IsAround(h2))
	then
		BZTrace(("ERROR: don't set the rabbit to something that doesn't existnot \n"));
		return;
	end


	m_RabbitMissingTurns = 0; -- always clear this

	-- Remove old objectification
	SetObjectiveOff(m_RabbitTargetHandle);

	m_RabbitTargetHandle = h;
	m_RabbitShooterHandle = 0;
	--		m_RabbitShooterWasHuman = false;
	--		m_RabbitShooterTeam = 0;

	if(not IsPlayer(h))
	then
		m_RabbitWasHuman = false;
		m_RabbitTeam = 0;
		SetTeamNum(h, 15); -- Force a different team #, so AI will target them.
	end
	else
	then
		m_RabbitWasHuman = true;
		m_RabbitTeam = GetTeamNum(h);
	end

	local i;

	local FoundIt = false;
	for(i = 1;i<MAX_TEAMS;i++)
	then
		Handle PlayerH = GetPlayerHandle(i);
		if(PlayerH == m_RabbitTargetHandle)
		then
			BZTrace(("New Rabbit is human, team %d\n", i));
			FoundIt = true;
		end
	end

	if(not FoundIt)
	then
		BZTrace(("New Rabbit isn't human, handle %08X\n", m_RabbitTargetHandle));
	end

	-- Reset targets for all bots
	for(i = 0;i<m_NumAIUnits;i++)
	then
		if(m_AICraftHandles[i] == h)
			continue; -- do nothing...
		FindGoodAITarget(i);
	end

	-- Also, reset objectives the local player.
	Handle PlayerH = GetPlayerHandle();
	if(PlayerH == m_RabbitTargetHandle)
	then
		-- We're the victim. Let them know.
		AddToMessagesBox(GetBZCCLocalizedString("mission", "It's wabbit hunting season. Do you feel lucky?"));
	end
	else
	then
		ObjectifyRabbit();
	end
#endif -- #ifndef EDITOR
end -- end of SetNewRabbit.


Handle Deathmatch01::SetupPlayer(local Team)
then
#ifndef EDITOR
	Handle PlayerH = 0;
	local Where;
	memset(&Where, 0, sizeof(Where));

	if((Team < 0) || (Team >= MAX_TEAMS))
		return 0; -- Sanity check... do NOT proceed

	m_SpawnedAtTime[Team] = m_ElapsedGameTime; -- Note when they spawned in.

	local TeamBlock = WhichTeamGroup(Team);

	if((not IsTeamplayOn()) || (TeamBlock<0))
	then

		if(DMIsRaceSubtype[m_MissionType])
			Where = GetSpawnpoint(0); -- Start at spawnpolocal 0
		else
			Where = GetRandomSpawnpoint();

		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
		Where.y += 1.0;

		-- This player is their own commander; set up their equipment.
		SetupTeam(Team);
	end
	else
	then
		-- Teamplay. Gotta put them near their commander. Also, always
		-- ensure the recycler/etc has been set up for this team if we
		-- know who they are
		SetupTeam(GetCommanderTeam(Team));

		-- SetupTeam will fill in the m_TeamPos[] array of positions
		-- for both the commander and offense players, so read out the
		-- results
		Where.x = m_TeamPos[3*Team+0];
		Where.z = m_TeamPos[3*Team+2];
		Where.y = TerrainFindFloor(Where.x, Where.z) + 1.0;
	end -- Teamplay setup

	if(DMIsRaceSubtype[m_MissionType]) 
	then
		-- Race. Start off near spawnpolocal 0
		Where = GetSpawnpoint(0);
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
		Where.y += 1.0;
		m_NextRaceCheckpoint[Team] = 1; -- Heading towards sp 1
		m_TotalCheckpointsCompleted[Team] = 0; -- None so far
		m_LapNumber[Team] = 0; -- None so far
		m_RaceWinerCount = 0; -- None so far
		RaceSetObjective = false;
	end

	PlayerH = BuildObject(GetPlayerODF(Team), Team, Where);
	if(not DMIsRaceSubtype[m_MissionType]) 
		SetRandomHeadingAngle(PlayerH);
	SetNoScrapFlagByHandle(PlayerH);

	-- If on team 0 (dedicated server team), make this object gone from the world
	if(not Team)
		MakeInert(PlayerH);

	if((IsTeamplayOn()) && (TeamBlock >= 0))
	then
		-- Also set up the other side too now, in case it wasn't done earlier.
		-- This puts both CTF flags on the map when the first player joins.
		SetupTeam(7 - GetCommanderTeam(Team));
	end

	return PlayerH;
#else
	return 0;
#endif -- #ifndef EDITOR
end

void Deathmatch01::InitialSetup(void)
then
	m_DidOneTimeInit = false;
	m_FirstTime = true;
	m_DMSetup = false;
end

-- Collapses the tracked vehicle list so there are no holes (values
-- of 0) in it, puts the updated count in m_NumVehiclesTracked
void Deathmatch01::CrunchEmptyVehicleList(void)
then
#ifndef EDITOR
	local i, j = 0;
	for(i = 0;i<MAX_VEHICLES_TRACKED;i++)
	then
		if(m_EmptyVehicles[i])
		then
			m_EmptyVehicles[j] = m_EmptyVehicles[i];
			j++;
		end
	end

	m_NumVehiclesTracked = j; -- idx of the first empty slot

	-- Zero out the rest of the array
	for(j = m_NumVehiclesTracked;j<MAX_VEHICLES_TRACKED;j++)
	then
		m_EmptyVehicles[j] = 0;
	end

#ifdef _DEBUG
	-- Sanity check on arraynot 
	for(j = 0;j<m_NumVehiclesTracked;j++)
	then
		_ASSERTE(m_EmptyVehicles[j]);
	end
#endif
#endif -- #ifndef EDITOR
end

-- Designed to be called from Execute(), updates list of empty
-- vehicles, killing some if there are too many, and forgetting
-- about any if they've been entered.
void Deathmatch01::UpdateEmptyVehicles(void)
then
	-- Early-exit if no vehicles tracked.
	if(not m_NumVehiclesTracked)
		return;

	local i;
	local anyChanges = false;
	for(i = 0;i<MAX_VEHICLES_TRACKED;i++)
	then
		if(m_EmptyVehicles[i])
		then
			-- Side effect to note: IsAliveAndPilot zeroes the handle if
			-- pilot missing; that'd be bad for us here if we want to
			-- manually remove it. Thus, we have a sacrificial varb
			Handle TempH = m_EmptyVehicles[i];
			if(not IsAround(m_EmptyVehicles[i]))
			then
				m_EmptyVehicles[i] = 0; -- craft died. Forget about it.
				anyChanges = true;
			end
			else if(IsPlayer(m_EmptyVehicles[i]))
			then
				m_EmptyVehicles[i] = 0; -- Human entered this. No longer empty
				anyChanges = true;
			end
			else if(IsAliveAndPilot(TempH))
			then
				m_EmptyVehicles[i] = 0; -- AI pilot entered this. No longer empty
				anyChanges = true;
			end
		end
	end -- i loop over MAX_VEHICLES_TRACKED

	-- Tweak the list if needed.
	if(anyChanges)
	then
		CrunchEmptyVehicleList();
		anyChanges = false;
	end

	-- If there's too many craft floating around, then kill the oldest.
	-- Above code ensures that m_EmptyVehicles[0] is valid.
	local CurNumPlayers = CountPlayers();
	local MaxEmpties = CurNumPlayers + (CurNumPlayers>>1) + 1; -- 150% of # of players on map
	if(m_NumVehiclesTracked > MaxEmpties)
	then
		SelfDamage(m_EmptyVehicles[0], 1e+20);
		m_EmptyVehicles[0] = 0; -- forget about this craft, as it better not exist anymore
		anyChanges = true;
	end

	-- Tweak the list if needed.
	if(anyChanges)
	then
		CrunchEmptyVehicleList();
		anyChanges = false;
	end
end

-- Adds a vehicle to the tracking list, and kills the oldest unpiloted
-- one if list full
void Deathmatch01::AddEmptyVehicle(Handle NewCraft)
then
#ifndef EDITOR
	_ASSERTE(NewCraft~= 0);
	if(NewCraft == 0)
		return;

	-- Don't overflow buffernot 
	if(m_NumVehiclesTracked >= MAX_VEHICLES_TRACKED)
	then
		UpdateEmptyVehicles();

		-- Kill oldest one, NOW.
		if(m_EmptyVehicles[0])
		then
			SelfDamage(m_EmptyVehicles[0], 1e+20);
			m_EmptyVehicles[0] = 0; -- forget about this craft, as it better not exist anymore
			CrunchEmptyVehicleList();
		end
	end

	-- This better succeed after the above.
	_ASSERTE(m_NumVehiclesTracked < MAX_VEHICLES_TRACKED);
	if(m_NumVehiclesTracked < MAX_VEHICLES_TRACKED)
	then
		m_EmptyVehicles[m_NumVehiclesTracked++] = NewCraft;
	end

#endif -- #ifndef EDITOR
end -- AddEmptyVehicle()


void Deathmatch01::Init(void)
then
	if(i_array)
		memset(i_array, 0, i_count*sizeof(int));
	if(f_array)
		memset(f_array, 0, f_count*sizeof(float));
	if(h_array)
		memset(h_array, 0, h_count*sizeof(Handle));
	if(b_array)
		memset(b_array, 0, b_count*sizeof(bool));

	RaceSetObjective = false;

	-- Read from the map's .trn file whether we respawn at altitude or
	-- not.
	then
		local mapTrnFile[128];
		strcpy_s(mapTrnFile, GetMapTRNFilename());
		OpenODF(mapTrnFile);
		GetODFBool(mapTrnFile, "DLL", "RespawnAtLowAltitude", &m_RespawnAtLowAltitude, false);
		GetODFFloat(mapTrnFile, "DLL", "CheckpointRadius", &m_RaceCheckpointRadius, 35.0);
		CloseODF(mapTrnFile);
	end
	TRNAllies::SetupTRNAllies(GetMapTRNFilename());

#ifdef EDITOR
	-- In EDITOR build, fill in some defaults
	m_Gravity = 25;
	m_LastTeamInLead = -1;
	m_MaxSpawnKillTime = 150;
	m_RespawnType = 1;
	m_AIUnitSkill = 3;
#else

	--	_ASSERTE(IsNetworkOn());
	m_LastTeamInLead = DPID_UNKNOWN;

	m_KillLimit = GetVarItemInt("network.session.ivar0");
	m_TotalGameTime = GetVarItemInt("network.session.ivar1");
	-- Skip ivar2-- player limit. Assume the netmgr takes care of that.
	local MissionTypePrefs = GetVarItemInt("network.session.ivar7");
	m_TotalRaceLaps = GetVarItemInt("network.session.ivar9"); -- Just in case we're using this
	m_Gravity = GetVarItemInt("network.session.ivar31");
	m_ScoreLimit = GetVarItemInt("network.session.ivar35");
	-- Set this for the server now. Clients get this set from Load().
	SetGravity(static_cast<float>(m_Gravity) * 0.5);

	m_bIsFriendlyFireOn = (GetVarItemInt("network.session.ivar32") ~= 0);

	m_MaxSpawnKillTime = m_GameTPS * GetVarItemInt("network.session.ivar13"); -- convert seconds to 1/10 ticks
	if(m_MaxSpawnKillTime < 0)
		m_MaxSpawnKillTime = 0; -- sanity check

	m_MissionType = bit32.band(MissionTypePrefs, 0xFF);
	m_RespawnType = bit32.band((MissionTypePrefs >> 8), 0xFF);

	m_NumAIUnits = 0;
	m_MaxAIUnits = 0;
	if(not DMIsRaceSubtype[m_MissionType])
	then
		m_MaxAIUnits = GetVarItemInt("network.session.ivar9");
		if(m_MaxAIUnits >= MAX_AI_UNITS)
			m_MaxAIUnits = MAX_AI_UNITS; 

#if 0--def _DEBUG
		if(m_MaxAIUnits > 0)
			m_MaxAIUnits = 8;
#endif

#if 1
		-- If the network is not on, this map was probably started from the
		-- commandline, and therefore, ivars are not at the defaults expected.
		-- Switch to some sane defaults.
		if(not IsNetworkOn())
		then
			m_MaxAIUnits = 0;
			m_Gravity = 25; -- default
			SetGravity(static_cast<float>(m_Gravity) * 0.5);
		end
#endif
	end

	m_AIUnitSkill = GetVarItemInt("network.session.ivar22");
	if((m_AIUnitSkill < 0) || (m_AIUnitSkill >4))
		m_AIUnitSkill = 3;

	if(not IsNetworkOn())
		m_AIUnitSkill = 3;

	m_HumansVsBots = (bool)GetVarItemInt("network.session.ivar16");

	-- If it's vs bots, make all humans allied (but not with animals
	-- (team 13))
	if(m_HumansVsBots)
	then
		local i, j;
		for(i = 1;i<12;i++)
		then
			for(j = 1;j<12;j++)
			then
				if(i ~= j)
				then
					Ally(i, j);
				end
			end
		end
	end

	m_RabbitMode = (bool)GetVarItemInt("network.session.ivar23");

	m_WeenieMode = (bool)GetVarItemInt("network.session.ivar19");
	m_ShipOnlyMode = (bool)GetVarItemInt("network.session.ivar25");

	m_NumAnimals = 0;
	m_MaxAnimals = GetVarItemInt("network.session.ivar27");
	if(m_MaxAnimals >= MAX_ANIMALS)
		m_MaxAnimals = MAX_ANIMALS; 

	if(m_MaxAnimals > 0)
	then
		const char* pAnimalConfig = DLLUtils::GetCheckedNetworkSvar(12, NETLIST_Animals);
		if((pAnimalConfig == NULL) || (strlen(pAnimalConfig) < 2))
			pAnimalConfig = "mcjak01";

		local *pStoreConfig = (char*)&m_AnimalConfig[0];
		size_t len = sizeof(m_AnimalConfig);
		strcpy_s(pStoreConfig, len, pAnimalConfig);
	end

	Handle PlayerH = 0;
	Handle playerEntryH = 0;
	local LocalTeamNum = GetLocalPlayerTeamNumber(); -- Query this from game

	-- As the .bzn has a vehicle which may not be appropriate, we
	-- must zap that player object and recreate them the way we want
	-- them when the game starts up.
	playerEntryH = GetPlayerHandle();
	if(playerEntryH) 
		RemoveObject(playerEntryH);

	-- Do One-time server side init of varbs for everyone
	if((ImServer()) || (not IsNetworkOn()))
	then
		if(not m_RemainingGameTime)
			m_RemainingGameTime = m_TotalGameTime* 60 * m_GameTPS; -- convert minutes to 1/10 seconds

		-- And build local player
		PlayerH = SetupPlayer(LocalTeamNum);
		SetAsUser(PlayerH, LocalTeamNum);
		AddPilotByHandle(PlayerH);

#if 0--def _DEBUG
		GiveWeapon(PlayerH, "gstatic");
#endif

		-- First player becomes the rabbit target
		if((m_RabbitMode) && (m_RabbitTargetHandle == 0))
		then
			SetNewRabbit(PlayerH);
		end

	end -- Server or no network

	-- Throw up Objectives.
	CreateObjectives();

	PUPMgr::Init();
	m_FirstTime = false;
#endif -- #ifndef EDITOR
	m_DidOneTimeInit = true;
end


-- Flags the appropriately 'next' spawnpolocal as the objective
void Deathmatch01::ObjectifyRacePoint(void)
then
#ifndef EDITOR
	static local LastObjectified = -1;
	-- First, clear all previous objectives
	for(local i = 0;i<m_TotalCheckpoints;i++)
	then
		sprintf_s(TempODFName, "checkpoint%d", i+1);
		SetObjectiveOff(GetHandle(TempODFName)); -- Ensure these are all cleared off.
	end
	local Idx = GetLocalPlayerTeamNumber();
	if(Idx >= 0)
	then
#ifdef _DEBUG
		if(LastObjectified~= m_NextRaceCheckpoint[Idx])
		then
			LastObjectified = m_NextRaceCheckpoint[Idx];
			sprintf_s(StaticTempMsgStr, "Objectifying %d", LastObjectified);
			AddToMessagesBox(StaticTempMsgStr);
		end
#endif
		if(not m_TotalRaceLaps || (m_LapNumber[Idx] < m_TotalRaceLaps))
		then
			sprintf_s(TempODFName, "checkpoint%d", m_NextRaceCheckpoint[Idx]);
			Handle NextCheckpolocal = GetHandle(TempODFName);
			if(NextCheckpoint)
				SetObjectiveOn(NextCheckpoint);
		end
	end
#endif -- #ifndef EDITOR
end


-- Rabbit-specific execute stuff. Kill da wabbitnot  Kill da wabbitnot 
void Deathmatch01::ExecuteRabbit(void)
then
#ifndef EDITOR
	-- Rebuild the rabbit if they're missing for more than a half
	-- second...
	Handle RabbitH = m_RabbitTargetHandle;
	if(IsAround(RabbitH))
	then

		m_RabbitMissingTurns = 0;
		-- Account for human hopping out of craft (which would keep the
		-- rabbit designation, while the pilot is the true rabbit)
		if((m_RabbitWasHuman) && (RabbitH ~= GetPlayerHandle(m_RabbitTeam)))
		then
			-- Unobjectify the old craft.
			--				SetObjectiveOff(RabbitH);
			SetNewRabbit(GetPlayerHandle(m_RabbitTeam));
		end
	end
	else
	then
		BZTrace(("Rabbit (%08X) has gone missing :(\n", RabbitH));
		m_RabbitMissingTurns++;
	end

	-- Track the rabbit shooter in case they died/switched vehicles, etc
	if((m_RabbitShooterWasHuman) && (m_RabbitShooterHandle ~= GetPlayerHandle(m_RabbitShooterTeam)))
	then
		m_RabbitShooterHandle = GetPlayerHandle(m_RabbitShooterTeam);
		BZTrace(("Resetting shooter to be handle %08X on team %d\n", m_RabbitShooterHandle, m_RabbitShooterTeam));
	end

	if(m_RabbitMissingTurns > 1)
	then
		-- Do the in-depth search for a new target
		RabbitH = m_RabbitTargetHandle;
		if(not IsAround(RabbitH))
		then
			-- Uhoh. Lost the target. :(
			if((m_RabbitWasHuman) && (m_RabbitTeam ~= m_ForbidRabbitTeam))
			then
				-- Move to current vehicle on that team.
				SetNewRabbit(GetPlayerHandle(m_RabbitTeam));
			end
		end

		RabbitH = m_RabbitTargetHandle;
		if(not IsAround(RabbitH))
		then
			-- Still gone? Gotta rebuild target.
			RabbitH = m_RabbitShooterHandle; -- last person to shoot them...
			if(IsAround(RabbitH))
			then
				SetNewRabbit(m_RabbitShooterHandle);
			end
			else
			then
				-- Gone, no known shooter. Pick a semi-random human to take
				-- over. The timestep at which this occurrs should be fairly
				-- random
				local i;
				local foundNewRabbit = false;
				for(i = 0;i<MAX_TEAMS;i++)
				then
					local T2 = (m_ElapsedGameTime+i) % MAX_TEAMS;
					Handle PlayerH = GetPlayerHandle(T2);
					if((T2 && PlayerH) && (T2 ~= m_ForbidRabbitTeam))
					then
						SetNewRabbit(PlayerH);
						foundNewRabbit = true;
						m_ForbidRabbitTeam = 0;
						break; -- out of this for loop
					end
				end

				-- If we didn't find a human, pick a random AI
				if(not foundNewRabbit)
				then
					for(i = 0;i<MAX_AI_UNITS;i++) 
					then
						local index2 = (m_ElapsedGameTime+i) % MAX_AI_UNITS;
						if(m_AICraftHandles[index2])
						then
							SetNewRabbit(m_AICraftHandles[index2]);
							foundNewRabbit = true;
							m_ForbidRabbitTeam = 0;
							break; -- out of this for loop
						end
					end -- i loop over MAX_AI_UNITS
				end -- Still hadn't found a human player to be the rabbit


				AddToMessagesBox(GetBZCCLocalizedString("mission", "Reset the rabbit... it's hunting seasonnot "));
				BZTrace(("Reset the rabbit... it's hunting seasonnot "));
			end
		end
	end

	-- If the rabbit's MIA, skip this.
	RabbitH = m_RabbitTargetHandle;
	if(not IsAround(RabbitH))
		return; -- Can't do a thing here.

	-- Update the last *other* person to hit me, only overriding if
	-- valid data
	Handle LastShooter = GetWhoShotMe(m_RabbitTargetHandle);
	--	BZTrace(("LastShooter = %08X\n", LastShooter));
	local i;
	if((LastShooter) && (LastShooter ~= m_RabbitTargetHandle) && (LastShooter ~= m_RabbitShooterHandle))
	then

		-- Workaround- if player (craft) was rabbit shooter, but they
		-- died as a pilot, LastShooter will the craft that did the
		-- shooting. So, reassign to player if they're still around.
		local LastShooterTeam = GetTeamNum(LastShooter);
		if((LastShooterTeam == m_RabbitShooterTeam) || (m_RabbitShooterTeam == 0))
		then
			Handle temph = GetPlayerHandle(m_RabbitShooterTeam);
			if(temph)
				LastShooter = temph;
		end

		m_RabbitShooterHandle = LastShooter;

		-- Preclear this...
		m_RabbitShooterWasHuman = false;
		m_RabbitShooterTeam = 0;

		local FoundIt = false;
		for(i = 1;i<MAX_TEAMS;i++)
		then
			Handle PlayerH = GetPlayerHandle(i);
			if(PlayerH == m_RabbitShooterHandle)
			then
				m_RabbitShooterWasHuman = true;
				m_RabbitShooterTeam = i;
				FoundIt = true;

#ifdef _DEBUG
				if(i ~= 1)
				then
					BZTrace(("What the heck?\n"));
				end
#endif

				BZTrace(("Rabbit shooter is human, team %d\n", i));
			end
		end

		if(not FoundIt)
		then
			--			BZTrace(("Rabbit shooter isn't human, Rabbit %08X, shooter %08X. LastShooterTeam = %d, m_RabbitShooterTeam = %d\n", m_RabbitTargetHandle, m_RabbitShooterHandle, LastShooterTeam, m_RabbitShooterTeam));
		end
	end

	-- Have a known rabbit. Update scores for them, 1 polocal every 5 seconds
	if(((m_ElapsedGameTime % (5 * m_GameTPS)) == 0) && ((CountPlayers() > 1) || (m_NumAIUnits > 0)))
	then
		AddScore(m_RabbitTargetHandle, 1); -- Staying alive....
	end

	if(not (m_ElapsedGameTime % m_GameTPS))
	then
		ObjectifyRabbit();
	end

#endif -- #ifndef EDITOR
end -- ExecuteRabbit

-- Race-specific execute stuff.
void Deathmatch01::ExecuteRace(void)
then
#ifndef EDITOR
	if((not RaceSetObjective) || (not (m_ElapsedGameTime % m_GameTPS))) 
	then
		-- Race. Gotta set objectives properly
		RaceSetObjective = true;
		ObjectifyRacePoint();
	end -- Periodic re-objectifying

	-- Also, check if everyone's near their next checkpoint
	local Advanced[MAX_TEAMS];
	local AnyAdvanced = false;
	local i, j;

	for(i = 0;i<MAX_TEAMS;i++)
	then
		Advanced[i] = false;
		Handle PlayerH = GetPlayerHandle(i);
		if(not PlayerH)
			continue; -- Do nothing for them.

		sprintf_s(TempODFName, "checkpoint%d", m_NextRaceCheckpoint[i]);
		Handle NextCheckpolocal = GetHandle(TempODFName);
		if(NextCheckpoint)
		then
			--Player is close enough AND (0 laps OR not finished already)
			if((GetDistance(PlayerH, NextCheckpoint) < (m_RaceCheckpointRadius)) && ((not m_TotalRaceLaps) || (m_LapNumber[i] < m_TotalRaceLaps)))
			then
				m_NextRaceCheckpoint[i] = m_NextRaceCheckpoint[i]++;
				if(m_NextRaceCheckpoint[i] > m_TotalCheckpoints)
				then
					m_NextRaceCheckpoint[i] = 1;
					m_LapNumber[i]++;
				end
				ObjectifyRacePoint();
				Advanced[i] = true;
				AnyAdvanced = AnyAdvanced || Advanced[i];
				m_TotalCheckpointsCompleted[i]++;

				-- Prlocal out a message for local player upon lap completion
				if((m_NextRaceCheckpoint[i]==1) && (i == GetLocalPlayerTeamNumber()))
				then
					if(m_TotalRaceLaps) 
						sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "Lap %d/%d Completed"), m_LapNumber[i], m_TotalRaceLaps);
					else
						sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "Lap %d Completed"), m_LapNumber[i]);

					AddToMessagesBox(StaticTempMsgStr);
				end
			end
		end -- NextCheckpolocal exists
	end -- Loop over all players

	-- Give a polocal to someone if they made it to a checkpolocal before anyone else did.
	if(AnyAdvanced)
	then
		for(i = 0;i<MAX_TEAMS;i++) 
			if(Advanced[i])
			then
				Handle PlayerH = GetPlayerHandle(i);

				local LeadingPlayer = true;
				for(j = 0;j<MAX_TEAMS;j++)
					if((i~= j) && (m_TotalCheckpointsCompleted[i]<= m_TotalCheckpointsCompleted[j]))
						LeadingPlayer = false;
				if(LeadingPlayer)
				then
					if(i ~= m_LastTeamInLead)
					then
						sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "%s takes the lead"), GetPlayerName(PlayerH));
						AddToMessagesBox(StaticTempMsgStr);
						m_LastTeamInLead = i;
					end
				end

				-- Also check if leader completed a full lap
				LeadingPlayer = true;
				for(j = 0;j<MAX_TEAMS;j++)
					if((i~= j) && (m_TotalCheckpointsCompleted[i]<m_TotalCheckpointsCompleted[j]))
						LeadingPlayer = false;
				if((LeadingPlayer) && (m_NextRaceCheckpoint[i] == 1))
				then
					AddScore(PlayerH, 1); -- Add score to show lap completion. -GBD

					if(m_TotalRaceLaps)
					then
						if(not m_RaceWinerCount)
							sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "Lap %d/%d completed by %s"), m_LapNumber[i], m_TotalRaceLaps, GetPlayerName(PlayerH));
					end
					else
					then
						if(not m_RaceWinerCount)
							sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "Lap %d completed by %s"), m_LapNumber[i], GetPlayerName(PlayerH));
					end

					AddToMessagesBox(StaticTempMsgStr);
					if(m_LapNumber[i] == m_TotalRaceLaps)
					then
						m_RaceWinerCount++;
						switch ( m_RaceWinerCount )
						then
						case 1:
							sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "%s finished in 1st place"), GetPlayerName(PlayerH));
							AddScore(PlayerH, 100);
							break;
						case 2:
							sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "%s finished in 2nd place"), GetPlayerName(PlayerH));
							AddScore(PlayerH, 75);
							break;
						case 3:
							sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "%s finished in 3rd place"), GetPlayerName(PlayerH));
							AddScore(PlayerH, 50);
							break;
						default:
							sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "%s finished in %dth place"), GetPlayerName(PlayerH), m_RaceWinerCount);
							AddScore(PlayerH, 25);
						end
						if(m_RaceWinerCount <= 1)
						then
							NoteGameoverWithCustomMessage(StaticTempMsgStr);
							strcpy_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "10 seconds left..."));
						end
						else
						then
							AddToMessagesBox(StaticTempMsgStr);
						end
						DoGameover(10.0);
					end

				end
			end
	end
#endif -- #ifndef EDITOR
end -- ExecuteRace()

void Deathmatch01::ExecuteWeenie(void)
then
#ifndef EDITOR
	local i;
	-- Go over all humans first
	for(i = 1;i<MAX_TEAMS;i++)
	then
		Handle p = GetPlayerHandle(i);
		if(p)
		then
			-- self-fire doesn't count (and possibly friendly fire doesn't either)
			Handle h = GetWhoShotMe(p);
			if (h && (h ~= p) && ((GetLastEnemyShot(p) >= 0.0) || m_bIsFriendlyFireOn))
				DamageF(p, MAX_FLOAT);
		end
	end

	for(i = 0;i<m_NumAIUnits;i++)
	then
		Handle p = m_AICraftHandles[i];
		if(p)
		then
			-- self-fire doesn't count (and possibly friendly fire doesn't either)
			Handle h = GetWhoShotMe(p);
			if (h && (h ~= p) && ((GetLastEnemyShot(p) >= 0.0) || m_bIsFriendlyFireOn))
				DamageF(p, MAX_FLOAT);
		end
	end

	for(i = 0;i<m_NumAnimals;i++)
	then
		Handle p = m_AnimalHandles[i];
		if(p)
		then
			-- self-fire doesn't count (and possibly friendly fire doesn't either)
			Handle h = GetWhoShotMe(p);
			if (h && (h ~= p) && ((GetLastEnemyShot(p) >= 0.0) || m_bIsFriendlyFireOn))
				DamageF(p, MAX_FLOAT);
		end
	end

	for(i = 0;i<m_NumVehiclesTracked;i++)
	then
		Handle p = m_EmptyVehicles[i];
		if(p)
		then
			-- self-fire doesn't count (and possibly friendly fire doesn't either)
			Handle h = GetWhoShotMe(p);
			if (h && (h ~= p) && ((GetLastEnemyShot(p) >= 0.0) || m_bIsFriendlyFireOn))
				DamageF(p, MAX_FLOAT);
		end
	end
#endif -- #ifndef EDITOR
end

-- Notices what ships all the human players are currently in. If they
-- hop out, then their old craft is pushed onto the empties list. If
-- this is 'ship only' mode, then other penalties are applied.
void Deathmatch01::ExecuteTrackPlayers(void)
then
#ifndef EDITOR
	local i;
	-- Go over all humans first
	for(i = 1;i<MAX_TEAMS;i++)
	then
		Handle p = GetPlayerHandle(i);
		if(p)
		then
			SetLifespan(p, -1.0); -- Ensure there's no lifespan killing this craft

			if(IsAliveAndPilot(p))
			then
				-- Make sure the 'spawn kill' doesn't get triggered.
				if(m_ShipOnlyMode)
				then
					m_SpawnedAtTime[i] = -4096;

					--					AddKills(p, -1); -- Ouch. Don't do thatnot 
					if (m_MissionType == DMSubtype_Normal || m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
						AddScore(p, -ScoreForKillingCraft); -- Ouch. Don't do thatnot 
					SelfDamage(p, 1e+20);
				end

				-- Did they just hop out, leaving that craft w/o a pilot? Nuke that craft too.
				Handle lastp = m_LastPlayerCraftHandle[i];
				if(IsAround(lastp))
				then
					lastp = m_LastPlayerCraftHandle[i];
					if(not IsAliveAndPilot(lastp))
					then
						if(m_ShipOnlyMode)
						then
							SelfDamage(m_LastPlayerCraftHandle[i], 1e+20);
						end
						else
						then
							-- Not ship-only mode. Add this to empties list
							if(m_NumVehiclesTracked < MAX_VEHICLES_TRACKED)
								m_EmptyVehicles[m_NumVehiclesTracked++] = m_LastPlayerCraftHandle[i];
						end
						m_LastPlayerCraftHandle[i] = 0; -- 'forget' about this.
					end -- last craft is now an empty
				end -- lastp is still around
			end -- p is currently a pilot.
			else
			then
				-- Must be in a craft. Store it.
				m_LastPlayerCraftHandle[i] = p;
			end
		end -- p valid (i.e. human is playing on that team)
	end -- i loop over MAX_TEAMS
#endif -- #ifndef EDITOR
end -- ExecuteTrackPlayers


-- Called via execute, m_GameTPS of a second has elapsed. Update everything.
void Deathmatch01::UpdateGameTime(void)
then
#ifndef EDITOR
	m_ElapsedGameTime++;

	-- Are we in a time limited game?
	if(m_RemainingGameTime>0)
	then
		m_RemainingGameTime--;
		if(not (m_RemainingGameTime % m_GameTPS))
		then
			-- Convert tenth-of-second ticks to hour/minutes/seconds format.
			local Seconds = m_RemainingGameTime / m_GameTPS;
			local Minutes = Seconds / 60;
			local Hours = Minutes / 60;
			-- Lop seconds and minutes down to 0..59 once we've grabbed
			-- non-remainder out.
			Seconds %= 60;
			Minutes %= 60;

			if(Hours)
				sprintf_s(TempMsgString, GetBZCCLocalizedString("mission", "Time Left %d:%02d:%02d\n"), Hours, Minutes, Seconds);
			else
				sprintf_s(TempMsgString, GetBZCCLocalizedString("mission", "Time Left %d:%02d\n"), Minutes, Seconds);
			SetTimerBox(TempMsgString);

			-- Also prlocal this out more visibly at important times....
			if(Hours == 0)
			then
				-- Every 5 minutes down to 10 minutes, then every minute
				-- thereafter.
				if((Seconds == 0) && ((Minutes <= 10) || (not (Minutes % 5))))
					AddToMessagesBox(TempMsgString);
				else
				then
					-- Every 5 seconds when under a minute is remaining.
					if((Minutes == 0) && (not (Seconds % 5)))
						AddToMessagesBox(TempMsgString);
				end
			end
		end

		-- Game over due to timeout?
		if(not m_RemainingGameTime)
		then
			NoteGameoverByTimelimit();
			DoGameover(10.0);
		end

	end
	else
	then
		-- Infinite time game. Periodically update ingame clock.
		if(not (m_ElapsedGameTime % m_GameTPS))
		then
			-- Convert tenth-of-second ticks to hour/minutes/seconds format.
			local Seconds = m_ElapsedGameTime / m_GameTPS;
			local Minutes = Seconds / 60;
			local Hours = Minutes / 60;
			-- Lop seconds and minutes down to 0..59 once we've grabbed
			-- non-remainder out.
			Seconds %= 60;
			Minutes %= 60;

			if(Hours)
				sprintf_s(TempMsgString, GetBZCCLocalizedString("mission", "Mission Time %d:%02d:%02d"), Hours, Minutes, Seconds);
			else
				sprintf_s(TempMsgString, GetBZCCLocalizedString("mission", "Mission Time %d:%02d"), Minutes, Seconds);
			SetTimerBox(TempMsgString);
		end
	end
#endif -- #ifndef EDITOR
end

void Deathmatch01::UpdateAIUnits()
then
#ifndef EDITOR
	local i;

	-- Need to spawn in a new craft at the start of the game
	-- (staggered every second)
#ifdef _DEBUG
	local InitialSpawnInFrequency = 1; -- 10 ticks per second
#else
	local InitialSpawnInFrequency = 5; -- 10 ticks per second
#endif

	if(not (m_ElapsedGameTime % InitialSpawnInFrequency))
	then

#ifdef _DEBUG
		-- Spam in all units asap to make logs line up better
		while(m_NumAIUnits < m_MaxAIUnits)
		then
			BuildBotCraft(m_NumAIUnits);
			m_NumAIUnits++;
		end
#endif

		if(m_NumAIUnits < m_MaxAIUnits)
		then
			BuildBotCraft(m_NumAIUnits);
			m_NumAIUnits++;
		end
		else
		then
			for(i = 0;i<m_NumAIUnits;i++) 
			then
				-- Fix for mantis #400 - if a bot craft is sniped,
				-- 'forget' about it and build another in its slot.
				if(not IsNotDeadAndPilot2(m_AICraftHandles[i]))
				then
					_ASSERTE(0);
					SetLifespan(m_AICraftHandles[i], SNIPED_AI_LIFESPAN);
					m_AICraftHandles[i] = 0;
				end

				if(m_AICraftHandles[i] == 0) 
				then
					BuildBotCraft(i);
					break;
				end
			end
		end
	end

	-- Periodically, update all the AI tasks. This is set to 3.2
	-- seconds by default. It rotates thru all bots, one per tick.
	--
--	local GameTime = ((float)m_ElapsedGameTime) / m_GameTPS;

	for(i = 0;i<m_NumAIUnits;i++)
	then
		if(((m_ElapsedGameTime + i) & 0x1F) == 0)
		then

			if(m_AILastWentForPowerup[i])
			then
				Handle Target = m_AITargetHandles[i];
				m_PowerupGotoTime[i]++;
				-- Max of 15 seconds to pick up a powerup, then we go again
				if((not IsAlive(Target)) || (m_PowerupGotoTime[i] > 150) ||
					(GetDistance(m_AICraftHandles[i], m_AITargetHandles[i]) < 2.0))
				then
					-- Need to retarget.
					FindGoodAITarget(i);
				end
			end
			else 
			then
				-- Code disabled NM 7/28/07 - this is not multiworld friendly.
				-- Units will pop nastily if they constantly get orders like this
				-- in the lockstep world, but they're not propagated into the
				-- visual worlds.
#if 0
				-- combat mode, not going for powerups.

				local Retarget = false;
				local TargetIsAlive = IsAlive(m_AITargetHandles[i]);
				Handle WhoLastShotMe = GetWhoShotMe(m_AICraftHandles[i]);

				-- AI check: if we're getting shot by someone, and our primary
				-- target is not getting hit by us (or they don't exist), nail
				-- them instead.
				if((WhoLastShotMe ~= 0) && ((not TargetIsAlive) ||
					(GetWhoShotMe(m_AITargetHandles[i]) ~= m_AICraftHandles[i])))
				then
					-- Ignore anything close to friendly fire.
					if(not IsAlly(m_AICraftHandles[i], WhoLastShotMe))
					then
						-- Short circuit: hit them instead.
						m_AITargetHandles[i] = WhoLastShotMe;
						Attack(m_AICraftHandles[i], m_AITargetHandles[i]);
						break; -- Skip all the rest of the targets
					end
				end

				-- AI check: if our target has gone missing, need a retargetnot 
				if(not TargetIsAlive)
				then
					Retarget = true;
				end

				-- Next AI check: if it's been a while since we got hit, find something else.
				if((not Retarget) && (GetLastEnemyShot(m_AICraftHandles[i]) > (GameTime + 5.0)))
				then
					Retarget = true;
				end

				-- Need to retarget? Do so.
				if(Retarget)
					FindGoodAITarget(i);
				else
					Attack(m_AICraftHandles[i], m_AITargetHandles[i]);
#endif
			end -- combat mode
		end -- Time to recalculate this.
	end -- loop over AI units
#endif -- #ifndef EDITOR
end -- UpdateAIUnits();

void Deathmatch01::UpdateAnimals()
then
#ifndef EDITOR
	local i;

	-- Have to manually check on animals; they won't trigger a call to
	-- DeadObject(). If any died, note that.
	for(i = 0;i<m_NumAnimals;i++)
	then
		if(m_AnimalHandles[i] ~= 0)
		then
			Handle h = m_AnimalHandles[i];
			if(not IsAlive(h))
				m_AnimalHandles[i] = 0;
		end
	end -- loop over all objects

	-- Spawn in animals at the start of the game (staggered every 4
	-- seconds)
	local InitialSpawnInFrequency = 4 * m_GameTPS; -- m_GameTPS ticks per second

	if(not (m_ElapsedGameTime % InitialSpawnInFrequency))
	then
		if(m_NumAnimals < m_MaxAnimals)
		then
			SetupAnimal(m_NumAnimals);
			m_NumAnimals++;
		end
		else
		then
			-- 'Full' set of animals. Do respawns as needed.
			for(i = 0;i<m_NumAnimals;i++)
			then
				if(m_AnimalHandles[i] == 0)
				then
					SetupAnimal(i);
					break;
				end
			end
		end
	end -- periodic check

#if 0--def _DEBUG
	-- Slowly kill off animals so that they respawn
	for(i = 0;i<m_NumAnimals;i++)
	then
		if(m_AnimalHandles[i] ~= 0)
		then
			Damage(m_AnimalHandles[i], 1);
		end
	end -- loop over all objects
#endif
#endif -- #ifndef EDITOR
end -- UpdateAnimals()

void Deathmatch01::Execute(void)
then
	local i;

	-- Always ensure we did this
	if (not m_DidOneTimeInit)
		Init();
#ifndef EDITOR

#if 0--def _DEBUG
	-- AI testing...
	for(i = 1;i<4;i++)
	then
		Handle h = GetPlayerHandle(i);
		if(not h)
			continue;

		-- Kill players every little bit to check respawns
		float maxHealth = GetMaxHealth(h);
		SelfDamage(h, (float)(maxHealth / 200.0));
	end
#endif

	-- Always see if any empties are filled or need to be killed
	UpdateEmptyVehicles();

	if(DMIsRaceSubtype[m_MissionType]) 
		ExecuteRace();

	if((m_RabbitMode) && (m_MissionType == DMSubtype_Normal || m_MissionType == DMSubtype_Normal2)) -- Only in Normal DM. -GBD
		ExecuteRabbit();

	if(m_WeenieMode)
		ExecuteWeenie();

	-- CTF - periodically re-objectify the opponent's flag
	if(m_MissionType == DMSubtype_CTF)
	then
		if(not (m_ElapsedGameTime % m_GameTPS))
		then
			ObjectifyFlag();
		end
	end

	ExecuteTrackPlayers();

	-- Do this as well...
	UpdateGameTime();

	if(m_MaxAIUnits)
		UpdateAIUnits();

	if(m_MaxAnimals)
		UpdateAnimals();

	-- Keep powerups going, etc
	PUPMgr::Execute();

	-- Check to see if someone was flagged as flying, and if they've
	-- landed, build a new craft for them
	for(i = 0;i<MAX_TEAMS;i++)
	then
		if(m_Flying[i])
		then
			Handle PlayerH = GetPlayerHandle(i);
			if((PlayerH ~= 0) && (not IsFlying(PlayerH)))
			then
				m_Flying[i] = false; -- clear flag so we don't check until they're dead
				if(PlayerH)
				then
					local *ODF = GetNextVehicleODF(i, true);
					Handle h = BuildEmptyCraftNear(PlayerH, ODF, i, RespawnMinRadiusAway, RespawnMaxRadiusAway);
					if(h)
					then
						SetTeamNum(h, 0); -- flag as neutral so AI won't immediately hit it

						AddEmptyVehicle(h); -- Clean things up if there are too many around
					end
				end
			end
		end
	end

	-- Mission scoring for KOH/CTF now done in main game, so we
	-- don't need to do anything here. Except gameover

	if((m_ScoreLimit > 0) && (not m_bDidGameOverByScore))
	then
		local Teamplay = IsTeamplayOn();
		local Teamscore[MAX_MULTIPLAYER_TEAMS] = then 0 end;
		Handle TeamplayHandles[MAX_MULTIPLAYER_TEAMS] = then 0 end;
		for(i=0;i<MAX_TEAMS;i++)
		then
			const Handle playerH = GetPlayerHandle(i);
			if (playerH == 0)
			then
				continue;
			end

			if (Teamplay)
			then
				local whichteamgroupami = WhichTeamGroup(i);
				if ((WhichTeamGroup >= 0) && (whichteamgroupami < MAX_MULTIPLAYER_TEAMS))
				then
					Teamscore[whichteamgroupami] += GetScore(playerH);

					if (not TeamplayHandles[whichteamgroupami])
						TeamplayHandles[whichteamgroupami] = playerH;
				end
			end
			else
			then
				if (GetScore(playerH) >= m_ScoreLimit)
				then
					NoteGameoverByScore(playerH);
					DoGameover(5.0);
					m_bDidGameOverByScore = true;
					break;
				end
			end
		end
		if (Teamplay)
		then
			for (i = 0; i < MAX_MULTIPLAYER_TEAMS; i++)
			then
				if (Teamscore[i] >= m_ScoreLimit)
				then
					NoteGameoverByScore(TeamplayHandles[i]);
					DoGameover(5.0);
					m_bDidGameOverByScore = true;
					break;
				end
			end
		end
	end
#endif -- #ifndef EDITOR
end

local Deathmatch01::AddPlayer(DPID id, local Team, local IsNewPlayer)
then
	if (not m_DidOneTimeInit)
		Init();

#ifndef EDITOR
	-- Server does all building; client doesn't need to do anything
	if (IsNewPlayer)
	then
		Handle PlayerH = SetupPlayer(Team);
		SetAsUser(PlayerH, Team);
		AddPilotByHandle(PlayerH);
		SetNoScrapFlagByHandle(PlayerH);
	end
#endif -- #ifndef EDITOR

	return 1; -- BOGUS: always assume successful
end

void Deathmatch01::DeletePlayer(DPID id)
then
end

-- Rebuilds pilot
EjectKillRetCodes Deathmatch01::RespawnPilot(Handle DeadObjectHandle, local Team)
then
#ifdef EDITOR
	return DLLHandled;
#else

	local Where; -- Where they
	local RespawnInVehicle = (GetRespawnInVehicle()) || (m_RabbitMode && (DeadObjectHandle == m_RabbitTargetHandle));

	if(m_RabbitMode && (DeadObjectHandle == m_RabbitTargetHandle))
	then
		m_ForbidRabbitTeam = m_RabbitTeam;
		m_RabbitTargetHandle = 0;
	end

	if(DMIsRaceSubtype[m_MissionType]) 
	then
		-- Race-- spawn back at last spawnpolocal they were at.
		local LastSpawnAt = m_NextRaceCheckpoint[Team]-1;
		if(LastSpawnAt > 0)
		then
			sprintf_s(TempODFName, "checkpoint%d", LastSpawnAt);
			GetPosition(GetHandle(TempODFName), Where);
		end
		else
		then
			Where = GetSpawnpoint(0);
		end
	end
	else if((not IsTeamplayOn()) || (Team<1))
	then
		Where = GetRandomSpawnpoint();
		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	end
	else
	then
		-- Place them back where originally created
		Where.x = m_TeamPos[3*Team+0];
		Where.y = m_TeamPos[3*Team+1];
		Where.z = m_TeamPos[3*Team+2];
		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	end

	if((Team>0) && (Team<MAX_TEAMS))
		m_SpawnedAtTime[Team] = m_ElapsedGameTime; -- Note when they spawned in.

	-- Randomize starting position somewhat
	Where = GetPositionNear(Where, RespawnMinRadiusAway, RespawnMaxRadiusAway);

	if((not RespawnInVehicle) && (not m_RespawnAtLowAltitude))
		Where.y += RespawnPilotHeight; -- Bounce them in the air to prevent multi-kills

	Handle NewPerson;
	if(RespawnInVehicle) 
		NewPerson = BuildObject(GetNextVehicleODF(Team, true), Team, Where);
	else
	then
		local Race = GetRaceOfTeam(Team);
		NewPerson = BuildObject(GetInitialPlayerPilotODF(Race), Team, Where);
	end

	SetAsUser(NewPerson, Team);
	SetNoScrapFlagByHandle(NewPerson);

	AddPilotByHandle(NewPerson);
	SetRandomHeadingAngle(NewPerson);
	if(not RespawnInVehicle) 
		m_Flying[Team] = true; -- build a craft when they land.

	-- If on team 0 (dedicated server team), make this object gone from the world
	if(not Team)
		MakeInert(NewPerson);

	return DLLHandled; -- Dead pilots get handled by DLL
#endif -- #ifndef EDITOR
end

EjectKillRetCodes Deathmatch01::DeadObject(local DeadObjectHandle, local KillersHandle, local WasDeadPerson, local WasDeadAI)
then
#ifdef EDITOR
	return DLLHandled;
#else
	local ODFName[64];
	GetObjInfo(DeadObjectHandle, Get_CFG, ODFName);
	--			BZTrace(("DeadObject(%08X...), odf %s\n", DeadObjectHandle, ODFName));

	-- Rabbit mode, for non-rabbit players, special scoring. Normal
	-- scoring for the rabbit below, as in other modes.
	local KilledRabbit = false;
	local UseRabbitScoring = false;
	local Wasm_RabbitShooterHandle = (DeadObjectHandle == m_RabbitShooterHandle);
	if((m_RabbitMode) && (KillersHandle ~= m_RabbitTargetHandle))
	then
		UseRabbitScoring = true;
		KilledRabbit = (DeadObjectHandle == m_RabbitTargetHandle);
		if(KilledRabbit)
		then
			-- Clear the objective set on them...
			SetObjectiveOff(m_RabbitTargetHandle);

			-- See if the rabbit's last shooter is still alive. If so, 
			-- make them the new target asap. Else, the next
			-- ExecuteRabbit ought to pick it up.
			Handle RabbitH = KillersHandle;
			if(IsAlive(RabbitH)) 
				SetNewRabbit(RabbitH); -- Update for everyone
			else
			then
				RabbitH = m_RabbitShooterHandle;
				if(IsAlive(RabbitH)) 
					SetNewRabbit(RabbitH); -- Update for everyone
			end
		end
		else
		then
			BZTrace(("Killed Object wasn't rabbit(%08X)\n", m_RabbitTargetHandle));
		end
	end -- Rabbit mode tweaks

	-- Get team number of who got waxed.
	local DeadTeam = GetTeamNum(DeadObjectHandle);
	local IsSpawnKill = false;
	-- Flip scoring if this is a spawn kill.
	local SpawnKillMultiplier = 1;
	local KillerIsAI = not IsPlayer(KillersHandle);

	-- Give positive or negative points to killer, depending on
	-- whether they killed enemy or ally

	-- Spawnkill is a non-suicide, on a human by another human.
	if((DeadObjectHandle ~= KillersHandle) && 
		(DeadTeam > 0) && (DeadTeam < MAX_TEAMS) && (m_SpawnedAtTime[DeadTeam] > 0))
	then
		IsSpawnKill = (m_ElapsedGameTime - m_SpawnedAtTime[DeadTeam]) < m_MaxSpawnKillTime;
	end

	if((UseRabbitScoring) && (not KilledRabbit))
	then
		SpawnKillMultiplier = -1; -- Force the score downnot 
		sprintf_s(TempMsgString, GetBZCCLocalizedString("mission", "%s killed the wrong target, %s\n"),
			GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle));
		AddToMessagesBox(TempMsgString);
	end
	else if((UseRabbitScoring) && (KilledRabbit))
	then
		SpawnKillMultiplier = -1; -- Force the score downnot 
		sprintf_s(TempMsgString, GetBZCCLocalizedString("mission", "Rabbit kill by %s on %s\n"),
			GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle));
		AddToMessagesBox(TempMsgString);
	end
	else if(IsSpawnKill)
	then
		SpawnKillMultiplier = -1;
		sprintf_s(TempMsgString, GetBZCCLocalizedString("mission", "Spawn kill by %s on %s\n"),
			GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle));
		AddToMessagesBox(TempMsgString);
	end

	-- Jira 2445: Don't count kills/deaths/score for Team 0 (props). -GBD
	if (DeadTeam ~= 0)
	then
		if ((DeadObjectHandle ~= KillersHandle) && (not IsAlly(DeadObjectHandle, KillersHandle)))
		then
			-- Killed enemy...
			if ((not WasDeadAI) || (KillForAIKill))
				AddKills(KillersHandle, 1 * SpawnKillMultiplier); -- Give them a kill

			if (m_MissionType == DMSubtype_Normal || m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
			then
				if ((not WasDeadAI) || (PointsForAIKill))
				then
					if (WasDeadPerson)
						AddScore(KillersHandle, ScoreForKillingPerson*SpawnKillMultiplier);
					else
						AddScore(KillersHandle, ScoreForKillingCraft*SpawnKillMultiplier);
				end
			end
		end
		else
		then
			if ((not WasDeadAI) || (KillForAIKill))
				AddKills(KillersHandle, -1 * SpawnKillMultiplier); -- Suicide or teamkill counts as -1 kill

			if ((UseRabbitScoring) && (not KilledRabbit))
				SpawnKillMultiplier = 0; -- no deaths count here...

			if (m_MissionType == DMSubtype_Normal || m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
			then
				if ((not WasDeadAI) || (PointsForAIKill))
				then
					if (WasDeadPerson)
						AddScore(KillersHandle, -ScoreForKillingPerson * SpawnKillMultiplier);
					else
						AddScore(KillersHandle, -ScoreForKillingCraft * SpawnKillMultiplier);
				end
			end
		end

		if (not WasDeadAI)
		then
			if ((UseRabbitScoring) && (not KilledRabbit))
				SpawnKillMultiplier = 0; -- no deaths count here...

			-- Give points to killee-- this always increases
			AddDeaths(DeadObjectHandle, 1 * SpawnKillMultiplier);

			if (m_MissionType == DMSubtype_Normal || m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
			then
				if (WasDeadPerson)
					AddScore(DeadObjectHandle, ScoreForDyingAsPerson*SpawnKillMultiplier);
				else
					AddScore(DeadObjectHandle, ScoreForDyingAsCraft*SpawnKillMultiplier);
			end

			-- Neener neenernot 
			if ((KillerIsAI) && (m_NumAIUnits > 0))
				DoTaunt(TAUNTS_HumanShipDestroyed);
		end

		-- Check to see if we have a m_KillLimit winner
		if ((m_KillLimit) && (GetKills(KillersHandle) >= m_KillLimit))
		then
			NoteGameoverByKillLimit(KillersHandle);
			DoGameover(10.0);
		end
	end
	-- Get team number of who got waxed.
	else
	then
		return DoEjectPilot; -- Someone on neutral team always gets default behavior
	end

	if(WasDeadAI)
	then
		local i;
		local bFoundAI = false;

		for(i = 0;i<m_NumAIUnits;i++)
		then
			if(DeadObjectHandle == m_AICraftHandles[i])
			then
				m_AICraftHandles[i] = 0;
				BuildBotCraft(i); -- Respawn them asap.
				bFoundAI = true;
				if(Wasm_RabbitShooterHandle)
				then
					m_RabbitShooterHandle = m_AICraftHandles[i];
				end
				break; -- out of i loop
			end
		end

		for(i = 0;i<m_NumAnimals;i++)
		then
			if(DeadObjectHandle == m_AnimalHandles[i])
			then
				SetupAnimal(i); -- Respawn them asap.
				bFoundAI = true;
				break; -- out of i loop
			end
		end

		if(bFoundAI)
		then
			return DLLHandled;
		end
		else
		then
#ifdef _DEBUG
			AddToMessagesBox("AI Unit not found... ?");
			BZTrace(("AI Unit not found... ???\n"));
#endif
			return DLLHandled;
			--			return DoEjectPilot;
		end

	end
	else 
	then
		-- Not DeadAI, i.e. a humannot 

		-- For a player-piloted craft, always respawn a new craft;
		-- respawn pilot if needed as well.
		if((WasDeadPerson) || (m_RabbitMode && KilledRabbit))
		then
			return RespawnPilot(DeadObjectHandle, DeadTeam);
		end
		else
		then
			-- Don't build anything for them until they land.
			m_Flying[DeadTeam] = true;
			return DoEjectPilot;
		end
	end
#endif -- #ifndef EDITOR
end

EjectKillRetCodes Deathmatch01::PlayerEjected(Handle DeadObjectHandle)
then
#ifdef EDITOR
	return DLLHandled;
#else
	local WasDeadAI = not IsPlayer(DeadObjectHandle);

	local DeadTeam = GetTeamNum(DeadObjectHandle);
	if(DeadTeam == 0)
		return DLLHandled; -- Invalid team. Do nothing

	-- Update Deaths, Kills, Score for this player
	AddDeaths(DeadObjectHandle, 1);
	AddKills(DeadObjectHandle, -1);

	if (m_MissionType == DMSubtype_Normal || m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
		AddScore(DeadObjectHandle, ScoreForDyingAsCraft-ScoreForKillingCraft);

	if(GetCanEject(DeadObjectHandle)) 
	then
		-- Flags saying if they can eject or not
#ifdef _DEBUG
		AddToMessagesBox("L1841 - can eject");
#endif

		m_Flying[DeadTeam] = true; -- They're flying; create craft when they land
		return DoEjectPilot; 
	end
	else
	then
#ifdef _DEBUG
		AddToMessagesBox("L1849 - can't eject");
#endif
		-- Can't eject, so put back at base by forcing a insta-kill as pilot
		return DeadObject(DeadObjectHandle, DeadObjectHandle, true, WasDeadAI);
	end
#endif -- #ifndef EDITOR
end

EjectKillRetCodes Deathmatch01::ObjectKilled(local DeadObjectHandle, local KillersHandle)
then
#ifdef EDITOR
	return DLLHandled;
#else
	local WasDeadAI = not IsPlayer(DeadObjectHandle);

	-- We don't care about dead craft, only dead pilots, and also only
	-- care about things in the lockstep world
	if(GetCurWorld() ~= 0)
	then
		return DoEjectPilot;
	end

	local WasDeadPerson = IsPerson(DeadObjectHandle);
	if(GetRespawnInVehicle()) -- CTF-- force a "kill" back to base
		WasDeadPerson = true;

	return DeadObject(DeadObjectHandle, KillersHandle, WasDeadPerson, WasDeadAI);
#endif -- #ifndef EDITOR
end

EjectKillRetCodes Deathmatch01::ObjectSniped(local DeadObjectHandle, local KillersHandle)
then
#ifdef EDITOR
	return DLLHandled;
#else
	local WasDeadAI = not IsPlayer(DeadObjectHandle);

	-- We don't care about dead craft, only dead pilots, and also only
	-- care about things in the lockstep world
	if(GetCurWorld() ~= 0)
	then
		return DoRespawnSafest;
	end

	-- Dead person means we must always respawn a new person
	return DeadObject(DeadObjectHandle, KillersHandle, true, WasDeadAI);
#endif -- #ifndef EDITOR
end

void Deathmatch01::CreateObjectives()
then
	-- Do this for everyone as well.
	ClearObjectives();
	switch (m_MissionType)
	then
	case DMSubtype_Normal:
	case DMSubtype_Normal2:
		AddObjective("mpobjective_dm.otf", WHITE, -1.0); -- negative time means don't change display to show it
		break;
	case DMSubtype_CTF:
		AddObjective("mpobjective_dmctf.otf", WHITE, -1.0); -- negative time means don't change display to show it
		break;
	case DMSubtype_KOH:
		AddObjective("mpobjective_dmkoth.otf", WHITE, -1.0); -- negative time means don't change display to show it
		break;
	case DMSubtype_Loot:
		AddObjective("mpobjective_dmloot.otf", WHITE, -1.0); -- negative time means don't change display to show it
		break;
	case DMSubtype_Race1:
	case DMSubtype_Race2:
		AddObjective("mpobjective_dmrace.otf", WHITE, -1.0); -- negative time means don't change display to show it
		break;
	default:
		AddObjective("mpobjective_dm.otf", WHITE, -1.0); -- negative time means don't change display to show it
		break;
	end
end

local Deathmatch01::Load(local missionSave)
then
	SetAutoGroupUnits(false);
	EnableHighTPS(m_GameTPS);

	-- Always do this to hook up clients with the taunt engine as well.
	InitTaunts(&m_ElapsedGameTime, &m_LastTauntPrintedAt, &m_GameTPS, "Bots");

	-- We're a 1.3 DLL.
	WantBotKillMessages();

	if (missionSave)
	then
		local i;

		-- init bools
		if((b_array) && (b_count))
			for (i = 0; i < b_count; i++)
				b_array[i] = false;

		-- init floats
		if((f_array) && (f_count))
			for (i = 0; i < f_count; i++)
				f_array[i] = 0.0;

		-- init handles
		if((h_array) && (h_count))
			for (i = 0; i < h_count; i++)
				h_array[i] = 0;

		-- init ints
		if((i_array) && (i_count))
			for (i = 0; i < i_count; i++)
				i_array[i] = 0;

		CreateObjectives();

		return true;
	end

	local ret = true;

	-- bools
	if (b_array ~= NULL)
		ret = ret && Read(b_array, b_count);

	-- floats
	if (f_array ~= NULL)
		ret = ret && Read(f_array, f_count);

	-- Handles
	if (h_array ~= NULL)
		ret = ret && Read(h_array, h_count);

	-- ints
	if (i_array ~= NULL)
		ret = ret && Read(i_array, i_count);

	-- Set this right after reading -- we might be on a client.  Safe
	-- to call this multiple times on the server.
	SetGravity(static_cast<float>(m_Gravity) * 0.5);

	PUPMgr::Load(missionSave);
	return ret;
end


local Deathmatch01::PostLoad(local missionSave)
then
	if (missionSave)
		return true;

	local ret = true;

	ConvertHandles(h_array, h_count);

	ret = ret && PUPMgr::PostLoad(missionSave);
#if 0
	if (DMIsRaceSubtype[m_MissionType])
	then
		for(local i = 0;i<MAX_TEAMS;i++)
		then
			m_SpawnPointHandles[i] = GetSpawnpointHandle(i);
			_ASSERTE(m_SpawnPointHandles[i]);
			local V = GetSpawnpoint(i);
			m_SpawnPointPos[3*i+0] = V.x;
			m_SpawnPointPos[3*i+1] = V.y;
			m_SpawnPointPos[3*i+2] = V.z;
		end
	end
#endif
	if(m_RabbitMode)
	then
		-- Clear, 
		Handle OrigRabbit = m_RabbitTargetHandle;
		SetNewRabbit(0); -- Clear.
		SetNewRabbit(OrigRabbit); -- re-aim everyone
	end

	-- ret = ret && PUPMgr::PostLoad(missionSave);
	return ret;
end


local Deathmatch01::Save(local missionSave)
then
	if (missionSave)
		return true;

	local ret = true;

	-- bools
	if (b_array ~= NULL)
		ret = ret && Write(b_array, b_count);

	-- floats
	if (f_array ~= NULL)
		ret = ret && Write(f_array, f_count);

	-- Handles
	if (h_array ~= NULL)
		ret = ret && Write(h_array, h_count);

	-- ints
	if (i_array ~= NULL)
		ret = ret && Write(i_array, i_count);

	ret = ret && PUPMgr::Save(missionSave);

	return ret;
end


-- Passed the current world, shooters handle, victim handle, and
-- the ODF string of the ordnance involved in the snipe. Returns a
-- code detailing what to do.
--
-- not not  Note : If DLLs want to do any actions to the world based on this
-- PreSnipe callback, they should (1) Ensure curWorld == 0 (lockstep)
-- -- do NOTHING if curWorld is ~= 0, and (2) probably queue up an
-- action to do in the next Execute() call.
PreSnipeReturnCodes Deathmatch01::PreSnipe(local curWorld, Handle shooterHandle, Handle victimHandle, local ordnanceTeam, const char* pOrdnanceODF)
then
	-- If Friendly Fire is off, then see if we should disallow the snipe
	if(not m_bIsFriendlyFireOn)
	then
		const TEAMRELATIONSHIP relationship = GetTeamRelationship(shooterHandle, victimHandle);
		if((relationship == TEAMRELATIONSHIP_SAMETEAM) || 
		   (relationship == TEAMRELATIONSHIP_ALLIEDTEAM))
		then
			-- Allow snipes of items on team 0/perceived team 0, as long
			-- as they're not a local/remote player
			if(IsPlayer(victimHandle) || (GetTeamNum(victimHandle) ~= 0))
			then
				return PRESNIPE_ONLYBULLETHIT;
			end
		end
		-- Friendly fire is off, and we're about to kill the pilot of the hit object.
		-- Set its team to 0
		SetPerceivedTeam(victimHandle, 0);
	end

	-- If we got here, allow the pilot to be killed
	return PRESNIPE_KILLPILOT;
end


DLLBase *BuildMission(void)
then
	return new Deathmatch01;
end

