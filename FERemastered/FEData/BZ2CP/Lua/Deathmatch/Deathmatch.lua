--[[ BZCC Deathmatch Mission Script 
Written by General BlackDragon
Version 1.0 2-10-2019 --]]

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');
local _DLLUtils = require('_DLLUtils');

local MAX_FLOAT    =   3.4028e+38;

local MAX_AI_UNITS = 256;
local MAX_ANIMALS = 8;
local MAX_VEHICLES_TRACKED = 32;

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




local Mission.m_GameTPS = 20;

local Mission = 
{ 
--ints
	m_TotalGameTime = 0,
	m_ElapsedGameTime = 0,
	m_RemainingGameTime = 0,
	m_KillLimit = 0, -- As specified from the shell
	m_MissionType = 0,
	m_RespawnType = 0,
	m_NumVehiclesTracked = 0, 
	m_SpawnedAtTime = { },

	-- How long a "spawn" kill lasts, in tenth of second ticks. If the
	-- time since they were spawned to current is less than this, it's a
	-- spawn kill, and not counted. From ivar13
	m_MaxSpawnKillTime = 0, -- long time, so we can debug this

	m_LastTauntPrintedAt = 0,
		
	-- Variables used during racing
	m_NextRaceCheckpoint = { },
	m_TotalCheckpointsCompleted = { },
	m_TotalCheckpoints = 0,
	m_LapNumber = { },
	m_LastTeamInLead = 0,
	m_TotalRaceLaps = 0,
	m_RaceWinerCount = 0,
	-- End of race varbs

	m_AIUnitSkill = 0, -- from ivar22, 0..3 or 4==random
	m_NumAIUnits = 0, -- Current count of AIs spawned in
	m_MaxAIUnits = 0, -- Limit of AIs
	m_NumAnimals = 0, -- Current count of AIs spawned in
	m_MaxAnimals = 0, -- Limit of AIs
	m_AnimalConfig[16] = 0, -- HACK - storing a string in here.

	--		AITeams[MAX_AI_UNITS], -- Which team # was last assigned to the specified AI unit
	m_PowerupGotoTime = { }, -- How much time has elapsed on their quest for a powerup
	m_RabbitTeam = 0,
	m_ForbidRabbitTeam = 0,
	m_RabbitShooterTeam = 0,
	m_RabbitMissingTurns = 0, -- how many turns they're MIA

	m_Gravity = 0, -- from ivar30
	m_ScoreLimit = 0, -- from ivar35, 0=unlimited
		
--bools
	m_DidOneTimeInit = false,
	m_FirstTime = false,
	m_GameWon = false, 
	m_Flying = { }, -- Flag saying we need to keep track of a specific player to build a craft when they land
	m_TeamIsSetUp = { },
	m_DMSetup = false,
	m_RaceIsSetup = false,
	m_HumansVsBots = false,
	m_RabbitMode = false,
	m_RabbitWasHuman = false,
	m_RabbitShooterWasHuman = false,
	m_AILastWentForPowerup = { }, -- flag saying they last went for 
	m_WeenieMode = false,
	m_ShipOnlyMode = false,
	m_RespawnAtLowAltitude = false,
	m_bIsFriendlyFireOn = false,
	m_bDidGameOverByScore = false, -- Goes true when we have noted a winner by score
-- floats
	m_RaceCheckpointRadius = 0.0,
-- Vector For Spawn positions.
	m_TeamPos = { },
-- Handles
	m_Flag1 = nil,
	m_Flag2 = nil,
	m_Carrier1 = nil,
	m_Carrier2 = nil,
	m_Base1 = nil,
	m_Base2 = nil,
	m_EmptyVehicles = { },
	--m_SpawnPointHandles[MAX_TEAMS] = nil, -- Used during race
	m_AICraftHandles = { },
	m_AITargetHandles = { }, -- Whom each of those is aiming at.
	m_LastPlayerCraftHandle = { }, -- for ShipOnly mode
	m_AnimalHandles = { },
	m_RabbitTargetHandle = nil,
	m_RabbitShooterHandle = nil,
}


function AddObject(h)

	-- Changed NM 11/22/01 - all AI is at skill 3 now by default.
	if(not IsPlayer(h)) 
	then
		-- Always get a random # to keep things in sync
		local UseSkill = math.floor(GetRandomFloat(4));
		if(UseSkill == 4) then
			UseSkill = 3;
		end

		if(Mission.m_AIUnitSkill < 4) then
			UseSkill = Mission.m_AIUnitSkill;
		end

		SetSkill(h, UseSkill);
	end

end

-- Returns true if players can eject (or bail out) of their vehicles
-- depending on the game type, false if they should be killed when
-- they try and do so.
function GetCanEject(h)

	if(Mission.m_ShipOnlyMode) then
		return false;
	end

	-- Can't eject if the rabbit
	if((Mission.m_RabbitMode) and (h == Mission.m_RabbitTargetHandle)) then
		return false;
	end

	switch (Mission.m_MissionType)
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

	if(Mission.m_ShipOnlyMode) then
		return true;
	end

	switch (Mission.m_MissionType)
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
		if(Mission.m_RespawnType == 1) then
			RType = Randomize_ByRace;
		elseif(Mission.m_RespawnType == 2)
			RType = Randomize_Any;
		end
	end

	return GetPlayerODF(TeamNum, RType);
end

function GetNextRandomVehicleODF(Team)
	return GetPlayerODF(Team);
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
	if((Team < 0) or (Team >= MAX_TEAMS))
		return;

	-- Also, if we've already set up this team group, don't do anything
	if((IsTeamplayOn()) and (Mission.m_TeamIsSetUp[Team]))
		return;

	local TeamRace = GetRaceOfTeam(Team);

	if(IsTeamplayOn())
	then
		SetMPTeamRace(WhichTeamGroup(Team), TeamRace); -- Lock this down to prevent changes.
	end

	local Where;

	if(DMIsRaceSubtype[Mission.m_MissionType])
	then
		-- Race-- everyone starts off at spawnpolocal 0's position
		Where = GetSpawnpoint(0);
	elseif(Mission.m_MissionType == DMSubtype_CTF) 
		-- CTF-- find spawnpolocal by team # 
		Where = _DLLUtils.GetSpawnpointForTeam(Team, FRIENDLY_SPAWNPOINT_MAX_ALLY, FRIENDLY_SPAWNPOINT_MIN_ENEMY, RANDOM_SPAWNPOINT_MIN_ENEMY);
		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	else
		Where = _DLLUtils.GetSpawnpointForTeam(Team, FRIENDLY_SPAWNPOINT_MAX_ALLY, FRIENDLY_SPAWNPOINT_MIN_ENEMY, RANDOM_SPAWNPOINT_MIN_ENEMY);

		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	end

	-- Store position we created them at for later
	Mission.m_TeamPos[3*Team+0] = Where.x;
	Mission.m_TeamPos[3*Team+1] = Where.y;
	Mission.m_TeamPos[3*Team+2] = Where.z;

	-- Find location to place flag at
	if (Mission.m_MissionType == DMSubtype_CTF)
	then
		-- CTF
		-- Find place to drop flag from AIPaths list
		local DesiredName[64];
		sprintf_s(DesiredName, "base%d", Team);

		local DesiredName2[64];
		sprintf_s(DesiredName2, "Mission.m_base%d", Team);

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
					Mission.m_Base1 = BaseH;
					Mission.m_Flag1 = FlagH;
				end
				elseif (Team == 6)
				then
					Mission.m_Base2 = BaseH;
					Mission.m_Flag2 = FlagH;
				end
			end
		end

	end -- CTF Flag setup

	elseif ((DMIsRaceSubtype[Mission.m_MissionType]) and (not Mission.m_RaceIsSetup)) 
	then
		local intCheckpointCount = 0;
		Handle hdlCheckpolocal = 0;
		do then
			intCheckpointCount++;
			sprintf_s(TempODFName, "checkpoint%d", intCheckpointCount);
			hdlCheckpolocal = GetHandle(TempODFName);
		end while(hdlCheckpoint);
		Mission.m_TotalCheckpoints = intCheckpointCount-1;

		Mission.m_RaceIsSetup = true;
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
				Mission.m_TeamPos[3*i+0] = NewPosition.x;
				Mission.m_TeamPos[3*i+1] = NewPosition.y;
				Mission.m_TeamPos[3*i+2] = NewPosition.z;
			end -- Loop over allies not the commander
		end
	end

	Mission.m_TeamIsSetUp[Team] = true;

end

-- Tries to return a good target for the AI unit, orders them to go
-- after it.
void Deathmatch01::FindGoodAITarget(local index)
then

	-- Sanity check - if this AI craft went MIA, clear handle
	if(not IsAliveAndPilot2(Mission.m_AICraftHandles[index]))
	then
		Mission.m_AICraftHandles[index] = 0;
		return;
	end

	-- Rabbit mode? Hammer the "it" player, nothing else to do
	if((Mission.m_RabbitMode) and (Mission.m_AICraftHandles[index] ~= Mission.m_RabbitTargetHandle))
	then
		Handle TargetH = Mission.m_RabbitTargetHandle;
		if(IsAlive(TargetH))
			Attack(Mission.m_AICraftHandles[index], Mission.m_RabbitTargetHandle);
		return;
	end

	Handle nearestEnemy = GetNearestEnemy(Mission.m_AICraftHandles[index]);
	local i;
	for(i = 1;i<MAX_TEAMS;i++)
	then
		Handle PlayerH = GetPlayerHandle(i);
		-- Ignore any close-by pilots.
		if((nearestEnemy == PlayerH) and (IsAliveAndPilot(PlayerH)))
			nearestEnemy = 0;
	end

	-- Was our last action an attack? Consider powerups now.
	if(nearestEnemy and (not Mission.m_AILastWentForPowerup[index]))
	then
		Handle nearestPerson = GetNearestPerson(Mission.m_AICraftHandles[index], true, 100.0);

		float distToEnemy = GetDistance(Mission.m_AICraftHandles[index], nearestEnemy);

		if(nearestPerson)
		then
			float distToPerson = GetDistance(Mission.m_AICraftHandles[index], nearestPerson);

			-- Consider objects a bit farther away than closest enemy
			if(distToPerson < (distToEnemy * 1.2))
			then
				Goto(Mission.m_AICraftHandles[index], nearestPerson);
				Mission.m_AILastWentForPowerup[index] = true;
				Mission.m_PowerupGotoTime[index] = 0;
				Mission.m_AITargetHandles[index] = nearestPerson;
				return; -- exit...
			end -- Powerup is close
		end -- nearestPerson exists

		Handle nearestPowerup = GetNearestPowerup(Mission.m_AICraftHandles[index], true, 100.0);
		if(nearestPowerup)
		then
			float distToPowerup = GetDistance(Mission.m_AICraftHandles[index], nearestPowerup);

			-- Consider objects a bit farther away than closest enemy
			if(distToPowerup < (distToEnemy * 1.2))
			then
				Goto(Mission.m_AICraftHandles[index], nearestPowerup);
				Mission.m_AILastWentForPowerup[index] = true;
				Mission.m_PowerupGotoTime[index] = 0;
				Mission.m_AITargetHandles[index] = nearestPowerup;
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
		if(not Mission.m_HumansVsBots)
		then
			-- Scan botlist..
			--local i;
			for(i = 0;i<Mission.m_NumAIUnits;i++)
			then
				-- Can't attack self.
				if(i == index)
					continue;
				-- If don't have a craft for self, skip.
				if(not Mission.m_AICraftHandles[index])
					continue;

				Handle ThisBotH = Mission.m_AICraftHandles[i];
				-- If bot died, skip them.
				if(not IsAlive(ThisBotH))
					continue;
				-- Skip friendly AIs
				if(IsAlly(Mission.m_AICraftHandles[index], Mission.m_AICraftHandles[i]))
					continue;
				ThisBotH = Mission.m_AICraftHandles[i];
				Handle MyH = Mission.m_AICraftHandles[index];
				float ThisDist = GetDistance(MyH, ThisBotH);
				if((ThisDist > 0.01) and (ThisDist < BestDist))
				then
					-- Winner (of sorts). Store them.
					BestDist = ThisDist;
					BestHandle = Mission.m_AICraftHandles[i];
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

			Handle MyH = Mission.m_AICraftHandles[index];
			float ThisDist = GetDistance(MyH, PlayerH);
			if((ThisDist > 0.01) and (ThisDist < BestDist))
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

	Mission.m_AITargetHandles[index] = nearestEnemy;
	-- Chargenot 
	if(nearestEnemy)
	then
		Attack(Mission.m_AICraftHandles[index], Mission.m_AITargetHandles[index]);
	end
	Mission.m_AILastWentForPowerup[index] = false; -- In combat modenot 
end

-- Sets up the specified AI unit, first time or later.
void Deathmatch01::BuildBotCraft(local index)
then
	_ASSERTE(Mission.m_AICraftHandles[index] == 0);
	local i;

	local theirTeam;

	if(Mission.m_RabbitMode)
		theirTeam = 14; -- until they become 'it', and on team 15
	elseif(Mission.m_HumansVsBots)
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
		if((Mission.m_TeamIsSetUp[i]) and (GetPlayerHandle(i)))
			APlayerTeam = i;
	end

	local Where = GetRandomSpawnpoint(theirTeam); -- Try to spawn bots at a spawnpolocal that is "safe" for them. Jira 529. -GBD
	-- Somewhere near the spawnpoint..
	Where = GetPositionNear(Where, BotMinRadiusAway, BotMaxRadiusAway);
	-- Bounce them up a little.
	Where.y += 2+GetRandomFloat(4);
	local *NewCraftsODF = GetPlayerODF(APlayerTeam, Randomize_Any);

	Mission.m_AICraftHandles[index] = BuildObject(NewCraftsODF, theirTeam, Where);
	SetRandomHeadingAngle(Mission.m_AICraftHandles[index]);
	SetNoScrapFlagByHandle(Mission.m_AICraftHandles[index]);
	AddPilotByHandle(Mission.m_AICraftHandles[index]);

	-- Ok, find a 'victim' for this AI unit. :)
	FindGoodAITarget(index);
end -- BuildBotCraft()

-- Sets up the specified Animal unit, first time or later.
void Deathmatch01::SetupAnimal(local index)
then
	local AnimalTeam = 8 + (int)GetRandomFloat(6);

	-- Don't make animals allied w/ humans, go to another team
	if(Mission.m_HumansVsBots or Mission.m_RabbitMode)
		AnimalTeam = 13;

	local Where = GetRandomSpawnpoint();
	-- Somewhere near the spawnpoint..
	Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	-- Bounce them up in the air a little.
	Where.y += 2+GetRandomFloat(4);
	local *AnimalODF = (char*)(&Mission.m_AnimalConfig[0]);

	Mission.m_AnimalHandles[index] = BuildObject(AnimalODF, AnimalTeam, Where);
	SetRandomHeadingAngle(Mission.m_AnimalHandles[index]);
	SetNoScrapFlagByHandle(Mission.m_AnimalHandles[index]);
	--	AddPilotByHandle(Mission.m_AICraftHandles[index]);
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
	if((IsTeamplayOn()) and (TeamBlock >= 0))
	then
		const Handle myFlag = (TeamBlock == 0) ? Mission.m_Flag1 : Mission.m_Flag2;
		const Handle opponentFlag = (TeamBlock == 0) ? Mission.m_Flag2 : Mission.m_Flag1;

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
	if(PlayerH == Mission.m_RabbitTargetHandle)
	then
		ClearObjectives();
	end
	else
	then
		-- Force-reset this.
		SetObjectiveOff(Mission.m_RabbitTargetHandle);
		SetObjectiveOn(Mission.m_RabbitTargetHandle);
		SetObjectiveName(Mission.m_RabbitTargetHandle, GetBZCCLocalizedString("cfg", "Wabbitnot "));
		--			SetUserTarget(Mission.m_RabbitTargetHandle);
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


	Mission.m_RabbitMissingTurns = 0; -- always clear this

	-- Remove old objectification
	SetObjectiveOff(Mission.m_RabbitTargetHandle);

	Mission.m_RabbitTargetHandle = h;
	Mission.m_RabbitShooterHandle = 0;
	--		Mission.m_RabbitShooterWasHuman = false;
	--		Mission.m_RabbitShooterTeam = 0;

	if(not IsPlayer(h))
	then
		Mission.m_RabbitWasHuman = false;
		Mission.m_RabbitTeam = 0;
		SetTeamNum(h, 15); -- Force a different team #, so AI will target them.
	end
	else
	then
		Mission.m_RabbitWasHuman = true;
		Mission.m_RabbitTeam = GetTeamNum(h);
	end

	local i;

	local FoundIt = false;
	for(i = 1;i<MAX_TEAMS;i++)
	then
		Handle PlayerH = GetPlayerHandle(i);
		if(PlayerH == Mission.m_RabbitTargetHandle)
		then
			BZTrace(("New Rabbit is human, team %d\n", i));
			FoundIt = true;
		end
	end

	if(not FoundIt)
	then
		BZTrace(("New Rabbit isn't human, handle %08X\n", Mission.m_RabbitTargetHandle));
	end

	-- Reset targets for all bots
	for(i = 0;i<Mission.m_NumAIUnits;i++)
	then
		if(Mission.m_AICraftHandles[i] == h)
			continue; -- do nothing...
		FindGoodAITarget(i);
	end

	-- Also, reset objectives the local player.
	Handle PlayerH = GetPlayerHandle();
	if(PlayerH == Mission.m_RabbitTargetHandle)
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

	if((Team < 0) or (Team >= MAX_TEAMS))
		return 0; -- Sanity check... do NOT proceed

	Mission.m_SpawnedAtTime[Team] = Mission.m_ElapsedGameTime; -- Note when they spawned in.

	local TeamBlock = WhichTeamGroup(Team);

	if((not IsTeamplayOn()) or (TeamBlock<0))
	then

		if(DMIsRaceSubtype[Mission.m_MissionType])
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

		-- SetupTeam will fill in the Mission.m_TeamPos[] array of positions
		-- for both the commander and offense players, so read out the
		-- results
		Where.x = Mission.m_TeamPos[3*Team+0];
		Where.z = Mission.m_TeamPos[3*Team+2];
		Where.y = TerrainFindFloor(Where.x, Where.z) + 1.0;
	end -- Teamplay setup

	if(DMIsRaceSubtype[Mission.m_MissionType]) 
	then
		-- Race. Start off near spawnpolocal 0
		Where = GetSpawnpoint(0);
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
		Where.y += 1.0;
		Mission.m_NextRaceCheckpoint[Team] = 1; -- Heading towards sp 1
		Mission.m_TotalCheckpointsCompleted[Team] = 0; -- None so far
		Mission.m_LapNumber[Team] = 0; -- None so far
		Mission.m_RaceWinerCount = 0; -- None so far
		RaceSetObjective = false;
	end

	PlayerH = BuildObject(GetPlayerODF(Team), Team, Where);
	if(not DMIsRaceSubtype[Mission.m_MissionType]) 
		SetRandomHeadingAngle(PlayerH);
	SetNoScrapFlagByHandle(PlayerH);

	-- If on team 0 (dedicated server team), make this object gone from the world
	if(not Team)
		MakeInert(PlayerH);

	if((IsTeamplayOn()) and (TeamBlock >= 0))
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
	Mission.m_DidOneTimeInit = false;
	Mission.m_FirstTime = true;
	Mission.m_DMSetup = false;
end

-- Collapses the tracked vehicle list so there are no holes (values
-- of 0) in it, puts the updated count in Mission.m_NumVehiclesTracked
void Deathmatch01::CrunchEmptyVehicleList(void)
then
#ifndef EDITOR
	local i, j = 0;
	for(i = 0;i<MAX_VEHICLES_TRACKED;i++)
	then
		if(Mission.m_EmptyVehicles[i])
		then
			Mission.m_EmptyVehicles[j] = Mission.m_EmptyVehicles[i];
			j++;
		end
	end

	Mission.m_NumVehiclesTracked = j; -- idx of the first empty slot

	-- Zero out the rest of the array
	for(j = Mission.m_NumVehiclesTracked;j<MAX_VEHICLES_TRACKED;j++)
	then
		Mission.m_EmptyVehicles[j] = 0;
	end

#ifdef _DEBUG
	-- Sanity check on arraynot 
	for(j = 0;j<Mission.m_NumVehiclesTracked;j++)
	then
		_ASSERTE(Mission.m_EmptyVehicles[j]);
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
	if(not Mission.m_NumVehiclesTracked)
		return;

	local i;
	local anyChanges = false;
	for(i = 0;i<MAX_VEHICLES_TRACKED;i++)
	then
		if(Mission.m_EmptyVehicles[i])
		then
			-- Side effect to note: IsAliveAndPilot zeroes the handle if
			-- pilot missing; that'd be bad for us here if we want to
			-- manually remove it. Thus, we have a sacrificial varb
			Handle TempH = Mission.m_EmptyVehicles[i];
			if(not IsAround(Mission.m_EmptyVehicles[i]))
			then
				Mission.m_EmptyVehicles[i] = 0; -- craft died. Forget about it.
				anyChanges = true;
			end
			elseif(IsPlayer(Mission.m_EmptyVehicles[i]))
			then
				Mission.m_EmptyVehicles[i] = 0; -- Human entered this. No longer empty
				anyChanges = true;
			end
			elseif(IsAliveAndPilot(TempH))
			then
				Mission.m_EmptyVehicles[i] = 0; -- AI pilot entered this. No longer empty
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
	-- Above code ensures that Mission.m_EmptyVehicles[0] is valid.
	local CurNumPlayers = CountPlayers();
	local MaxEmpties = CurNumPlayers + (CurNumPlayers>>1) + 1; -- 150% of # of players on map
	if(Mission.m_NumVehiclesTracked > MaxEmpties)
	then
		SelfDamage(Mission.m_EmptyVehicles[0], 1e+20);
		Mission.m_EmptyVehicles[0] = 0; -- forget about this craft, as it better not exist anymore
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
	if(Mission.m_NumVehiclesTracked >= MAX_VEHICLES_TRACKED)
	then
		UpdateEmptyVehicles();

		-- Kill oldest one, NOW.
		if(Mission.m_EmptyVehicles[0])
		then
			SelfDamage(Mission.m_EmptyVehicles[0], 1e+20);
			Mission.m_EmptyVehicles[0] = 0; -- forget about this craft, as it better not exist anymore
			CrunchEmptyVehicleList();
		end
	end

	-- This better succeed after the above.
	_ASSERTE(Mission.m_NumVehiclesTracked < MAX_VEHICLES_TRACKED);
	if(Mission.m_NumVehiclesTracked < MAX_VEHICLES_TRACKED)
	then
		Mission.m_EmptyVehicles[Mission.m_NumVehiclesTracked++] = NewCraft;
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
		GetODFBool(mapTrnFile, "DLL", "RespawnAtLowAltitude", &Mission.m_RespawnAtLowAltitude, false);
		GetODFFloat(mapTrnFile, "DLL", "CheckpointRadius", &Mission.m_RaceCheckpointRadius, 35.0);
		CloseODF(mapTrnFile);
	end
	TRNAllies::SetupTRNAllies(GetMapTRNFilename());

#ifdef EDITOR
	-- In EDITOR build, fill in some defaults
	Mission.m_Gravity = 25;
	Mission.m_LastTeamInLead = -1;
	Mission.m_MaxSpawnKillTime = 150;
	Mission.m_RespawnType = 1;
	Mission.m_AIUnitSkill = 3;
#else

	--	_ASSERTE(IsNetworkOn());
	Mission.m_LastTeamInLead = DPID_UNKNOWN;

	Mission.m_KillLimit = GetVarItemInt("network.session.ivar0");
	Mission.m_TotalGameTime = GetVarItemInt("network.session.ivar1");
	-- Skip ivar2-- player limit. Assume the netmgr takes care of that.
	local MissionTypePrefs = GetVarItemInt("network.session.ivar7");
	Mission.m_TotalRaceLaps = GetVarItemInt("network.session.ivar9"); -- Just in case we're using this
	Mission.m_Gravity = GetVarItemInt("network.session.ivar31");
	Mission.m_ScoreLimit = GetVarItemInt("network.session.ivar35");
	-- Set this for the server now. Clients get this set from Load().
	SetGravity(static_cast<float>(Mission.m_Gravity) * 0.5);

	Mission.m_bIsFriendlyFireOn = (GetVarItemInt("network.session.ivar32") ~= 0);

	Mission.m_MaxSpawnKillTime = Mission.m_GameTPS * GetVarItemInt("network.session.ivar13"); -- convert seconds to 1/10 ticks
	if(Mission.m_MaxSpawnKillTime < 0)
		Mission.m_MaxSpawnKillTime = 0; -- sanity check

	Mission.m_MissionType = bit32.band(MissionTypePrefs, 0xFF);
	Mission.m_RespawnType = bit32.band((MissionTypePrefs >> 8), 0xFF);

	Mission.m_NumAIUnits = 0;
	Mission.m_MaxAIUnits = 0;
	if(not DMIsRaceSubtype[Mission.m_MissionType])
	then
		Mission.m_MaxAIUnits = GetVarItemInt("network.session.ivar9");
		if(Mission.m_MaxAIUnits >= MAX_AI_UNITS)
			Mission.m_MaxAIUnits = MAX_AI_UNITS; 

#if 0--def _DEBUG
		if(Mission.m_MaxAIUnits > 0)
			Mission.m_MaxAIUnits = 8;
#endif

#if 1
		-- If the network is not on, this map was probably started from the
		-- commandline, and therefore, ivars are not at the defaults expected.
		-- Switch to some sane defaults.
		if(not IsNetworkOn())
		then
			Mission.m_MaxAIUnits = 0;
			Mission.m_Gravity = 25; -- default
			SetGravity(static_cast<float>(Mission.m_Gravity) * 0.5);
		end
#endif
	end

	Mission.m_AIUnitSkill = GetVarItemInt("network.session.ivar22");
	if((Mission.m_AIUnitSkill < 0) or (Mission.m_AIUnitSkill >4))
		Mission.m_AIUnitSkill = 3;

	if(not IsNetworkOn())
		Mission.m_AIUnitSkill = 3;

	Mission.m_HumansVsBots = (bool)GetVarItemInt("network.session.ivar16");

	-- If it's vs bots, make all humans allied (but not with animals
	-- (team 13))
	if(Mission.m_HumansVsBots)
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

	Mission.m_RabbitMode = (bool)GetVarItemInt("network.session.ivar23");

	Mission.m_WeenieMode = (bool)GetVarItemInt("network.session.ivar19");
	Mission.m_ShipOnlyMode = (bool)GetVarItemInt("network.session.ivar25");

	Mission.m_NumAnimals = 0;
	Mission.m_MaxAnimals = GetVarItemInt("network.session.ivar27");
	if(Mission.m_MaxAnimals >= MAX_ANIMALS)
		Mission.m_MaxAnimals = MAX_ANIMALS; 

	if(Mission.m_MaxAnimals > 0)
	then
		const char* pAnimalConfig = DLLUtils::GetCheckedNetworkSvar(12, NETLIST_Animals);
		if((pAnimalConfig == NULL) or (strlen(pAnimalConfig) < 2))
			pAnimalConfig = "mcjak01";

		local *pStoreConfig = (char*)&Mission.m_AnimalConfig[0];
		size_t len = sizeof(Mission.m_AnimalConfig);
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
	if((ImServer()) or (not IsNetworkOn()))
	then
		if(not Mission.m_RemainingGameTime)
			Mission.m_RemainingGameTime = Mission.m_TotalGameTime* 60 * Mission.m_GameTPS; -- convert minutes to 1/10 seconds

		-- And build local player
		PlayerH = SetupPlayer(LocalTeamNum);
		SetAsUser(PlayerH, LocalTeamNum);
		AddPilotByHandle(PlayerH);

#if 0--def _DEBUG
		GiveWeapon(PlayerH, "gstatic");
#endif

		-- First player becomes the rabbit target
		if((Mission.m_RabbitMode) and (Mission.m_RabbitTargetHandle == 0))
		then
			SetNewRabbit(PlayerH);
		end

	end -- Server or no network

	-- Throw up Objectives.
	CreateObjectives();

	PUPMgr::Init();
	Mission.m_FirstTime = false;
#endif -- #ifndef EDITOR
	Mission.m_DidOneTimeInit = true;
end


-- Flags the appropriately 'next' spawnpolocal as the objective
void Deathmatch01::ObjectifyRacePoint(void)
then
#ifndef EDITOR
	static local LastObjectified = -1;
	-- First, clear all previous objectives
	for(local i = 0;i<Mission.m_TotalCheckpoints;i++)
	then
		sprintf_s(TempODFName, "checkpoint%d", i+1);
		SetObjectiveOff(GetHandle(TempODFName)); -- Ensure these are all cleared off.
	end
	local Idx = GetLocalPlayerTeamNumber();
	if(Idx >= 0)
	then
#ifdef _DEBUG
		if(LastObjectified~= Mission.m_NextRaceCheckpoint[Idx])
		then
			LastObjectified = Mission.m_NextRaceCheckpoint[Idx];
			sprintf_s(StaticTempMsgStr, "Objectifying %d", LastObjectified);
			AddToMessagesBox(StaticTempMsgStr);
		end
#endif
		if(not Mission.m_TotalRaceLaps or (Mission.m_LapNumber[Idx] < Mission.m_TotalRaceLaps))
		then
			sprintf_s(TempODFName, "checkpoint%d", Mission.m_NextRaceCheckpoint[Idx]);
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
	Handle RabbitH = Mission.m_RabbitTargetHandle;
	if(IsAround(RabbitH))
	then

		Mission.m_RabbitMissingTurns = 0;
		-- Account for human hopping out of craft (which would keep the
		-- rabbit designation, while the pilot is the true rabbit)
		if((Mission.m_RabbitWasHuman) and (RabbitH ~= GetPlayerHandle(Mission.m_RabbitTeam)))
		then
			-- Unobjectify the old craft.
			--				SetObjectiveOff(RabbitH);
			SetNewRabbit(GetPlayerHandle(Mission.m_RabbitTeam));
		end
	end
	else
	then
		BZTrace(("Rabbit (%08X) has gone missing :(\n", RabbitH));
		Mission.m_RabbitMissingTurns++;
	end

	-- Track the rabbit shooter in case they died/switched vehicles, etc
	if((Mission.m_RabbitShooterWasHuman) and (Mission.m_RabbitShooterHandle ~= GetPlayerHandle(Mission.m_RabbitShooterTeam)))
	then
		Mission.m_RabbitShooterHandle = GetPlayerHandle(Mission.m_RabbitShooterTeam);
		BZTrace(("Resetting shooter to be handle %08X on team %d\n", Mission.m_RabbitShooterHandle, Mission.m_RabbitShooterTeam));
	end

	if(Mission.m_RabbitMissingTurns > 1)
	then
		-- Do the in-depth search for a new target
		RabbitH = Mission.m_RabbitTargetHandle;
		if(not IsAround(RabbitH))
		then
			-- Uhoh. Lost the target. :(
			if((Mission.m_RabbitWasHuman) and (Mission.m_RabbitTeam ~= Mission.m_ForbidRabbitTeam))
			then
				-- Move to current vehicle on that team.
				SetNewRabbit(GetPlayerHandle(Mission.m_RabbitTeam));
			end
		end

		RabbitH = Mission.m_RabbitTargetHandle;
		if(not IsAround(RabbitH))
		then
			-- Still gone? Gotta rebuild target.
			RabbitH = Mission.m_RabbitShooterHandle; -- last person to shoot them...
			if(IsAround(RabbitH))
			then
				SetNewRabbit(Mission.m_RabbitShooterHandle);
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
					local T2 = (Mission.m_ElapsedGameTime+i) % MAX_TEAMS;
					Handle PlayerH = GetPlayerHandle(T2);
					if((T2 and PlayerH) and (T2 ~= Mission.m_ForbidRabbitTeam))
					then
						SetNewRabbit(PlayerH);
						foundNewRabbit = true;
						Mission.m_ForbidRabbitTeam = 0;
						break; -- out of this for loop
					end
				end

				-- If we didn't find a human, pick a random AI
				if(not foundNewRabbit)
				then
					for(i = 0;i<MAX_AI_UNITS;i++) 
					then
						local index2 = (Mission.m_ElapsedGameTime+i) % MAX_AI_UNITS;
						if(Mission.m_AICraftHandles[index2])
						then
							SetNewRabbit(Mission.m_AICraftHandles[index2]);
							foundNewRabbit = true;
							Mission.m_ForbidRabbitTeam = 0;
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
	RabbitH = Mission.m_RabbitTargetHandle;
	if(not IsAround(RabbitH))
		return; -- Can't do a thing here.

	-- Update the last *other* person to hit me, only overriding if
	-- valid data
	Handle LastShooter = GetWhoShotMe(Mission.m_RabbitTargetHandle);
	--	BZTrace(("LastShooter = %08X\n", LastShooter));
	local i;
	if((LastShooter) and (LastShooter ~= Mission.m_RabbitTargetHandle) and (LastShooter ~= Mission.m_RabbitShooterHandle))
	then

		-- Workaround- if player (craft) was rabbit shooter, but they
		-- died as a pilot, LastShooter will the craft that did the
		-- shooting. So, reassign to player if they're still around.
		local LastShooterTeam = GetTeamNum(LastShooter);
		if((LastShooterTeam == Mission.m_RabbitShooterTeam) or (Mission.m_RabbitShooterTeam == 0))
		then
			Handle temph = GetPlayerHandle(Mission.m_RabbitShooterTeam);
			if(temph)
				LastShooter = temph;
		end

		Mission.m_RabbitShooterHandle = LastShooter;

		-- Preclear this...
		Mission.m_RabbitShooterWasHuman = false;
		Mission.m_RabbitShooterTeam = 0;

		local FoundIt = false;
		for(i = 1;i<MAX_TEAMS;i++)
		then
			Handle PlayerH = GetPlayerHandle(i);
			if(PlayerH == Mission.m_RabbitShooterHandle)
			then
				Mission.m_RabbitShooterWasHuman = true;
				Mission.m_RabbitShooterTeam = i;
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
			--			BZTrace(("Rabbit shooter isn't human, Rabbit %08X, shooter %08X. LastShooterTeam = %d, Mission.m_RabbitShooterTeam = %d\n", Mission.m_RabbitTargetHandle, Mission.m_RabbitShooterHandle, LastShooterTeam, Mission.m_RabbitShooterTeam));
		end
	end

	-- Have a known rabbit. Update scores for them, 1 polocal every 5 seconds
	if(((Mission.m_ElapsedGameTime % (5 * Mission.m_GameTPS)) == 0) and ((CountPlayers() > 1) or (Mission.m_NumAIUnits > 0)))
	then
		AddScore(Mission.m_RabbitTargetHandle, 1); -- Staying alive....
	end

	if(not (Mission.m_ElapsedGameTime % Mission.m_GameTPS))
	then
		ObjectifyRabbit();
	end

#endif -- #ifndef EDITOR
end -- ExecuteRabbit

-- Race-specific execute stuff.
void Deathmatch01::ExecuteRace(void)
then
#ifndef EDITOR
	if((not RaceSetObjective) or (not (Mission.m_ElapsedGameTime % Mission.m_GameTPS))) 
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

		sprintf_s(TempODFName, "checkpoint%d", Mission.m_NextRaceCheckpoint[i]);
		Handle NextCheckpolocal = GetHandle(TempODFName);
		if(NextCheckpoint)
		then
			--Player is close enough AND (0 laps OR not finished already)
			if((GetDistance(PlayerH, NextCheckpoint) < (Mission.m_RaceCheckpointRadius)) and ((not Mission.m_TotalRaceLaps) or (Mission.m_LapNumber[i] < Mission.m_TotalRaceLaps)))
			then
				Mission.m_NextRaceCheckpoint[i] = Mission.m_NextRaceCheckpoint[i]++;
				if(Mission.m_NextRaceCheckpoint[i] > Mission.m_TotalCheckpoints)
				then
					Mission.m_NextRaceCheckpoint[i] = 1;
					Mission.m_LapNumber[i]++;
				end
				ObjectifyRacePoint();
				Advanced[i] = true;
				AnyAdvanced = AnyAdvanced or Advanced[i];
				Mission.m_TotalCheckpointsCompleted[i]++;

				-- Prlocal out a message for local player upon lap completion
				if((Mission.m_NextRaceCheckpoint[i]==1) and (i == GetLocalPlayerTeamNumber()))
				then
					if(Mission.m_TotalRaceLaps) 
						sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "Lap %d/%d Completed"), Mission.m_LapNumber[i], Mission.m_TotalRaceLaps);
					else
						sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "Lap %d Completed"), Mission.m_LapNumber[i]);

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
					if((i~= j) and (Mission.m_TotalCheckpointsCompleted[i]<= Mission.m_TotalCheckpointsCompleted[j]))
						LeadingPlayer = false;
				if(LeadingPlayer)
				then
					if(i ~= Mission.m_LastTeamInLead)
					then
						sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "%s takes the lead"), GetPlayerName(PlayerH));
						AddToMessagesBox(StaticTempMsgStr);
						Mission.m_LastTeamInLead = i;
					end
				end

				-- Also check if leader completed a full lap
				LeadingPlayer = true;
				for(j = 0;j<MAX_TEAMS;j++)
					if((i~= j) and (Mission.m_TotalCheckpointsCompleted[i]<Mission.m_TotalCheckpointsCompleted[j]))
						LeadingPlayer = false;
				if((LeadingPlayer) and (Mission.m_NextRaceCheckpoint[i] == 1))
				then
					AddScore(PlayerH, 1); -- Add score to show lap completion. -GBD

					if(Mission.m_TotalRaceLaps)
					then
						if(not Mission.m_RaceWinerCount)
							sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "Lap %d/%d completed by %s"), Mission.m_LapNumber[i], Mission.m_TotalRaceLaps, GetPlayerName(PlayerH));
					end
					else
					then
						if(not Mission.m_RaceWinerCount)
							sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "Lap %d completed by %s"), Mission.m_LapNumber[i], GetPlayerName(PlayerH));
					end

					AddToMessagesBox(StaticTempMsgStr);
					if(Mission.m_LapNumber[i] == Mission.m_TotalRaceLaps)
					then
						Mission.m_RaceWinerCount++;
						switch ( Mission.m_RaceWinerCount )
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
							sprintf_s(StaticTempMsgStr, GetBZCCLocalizedString("mission", "%s finished in %dth place"), GetPlayerName(PlayerH), Mission.m_RaceWinerCount);
							AddScore(PlayerH, 25);
						end
						if(Mission.m_RaceWinerCount <= 1)
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
			if (h and (h ~= p) and ((GetLastEnemyShot(p) >= 0.0) or Mission.m_bIsFriendlyFireOn))
				DamageF(p, MAX_FLOAT);
		end
	end

	for(i = 0;i<Mission.m_NumAIUnits;i++)
	then
		Handle p = Mission.m_AICraftHandles[i];
		if(p)
		then
			-- self-fire doesn't count (and possibly friendly fire doesn't either)
			Handle h = GetWhoShotMe(p);
			if (h and (h ~= p) and ((GetLastEnemyShot(p) >= 0.0) or Mission.m_bIsFriendlyFireOn))
				DamageF(p, MAX_FLOAT);
		end
	end

	for(i = 0;i<Mission.m_NumAnimals;i++)
	then
		Handle p = Mission.m_AnimalHandles[i];
		if(p)
		then
			-- self-fire doesn't count (and possibly friendly fire doesn't either)
			Handle h = GetWhoShotMe(p);
			if (h and (h ~= p) and ((GetLastEnemyShot(p) >= 0.0) or Mission.m_bIsFriendlyFireOn))
				DamageF(p, MAX_FLOAT);
		end
	end

	for(i = 0;i<Mission.m_NumVehiclesTracked;i++)
	then
		Handle p = Mission.m_EmptyVehicles[i];
		if(p)
		then
			-- self-fire doesn't count (and possibly friendly fire doesn't either)
			Handle h = GetWhoShotMe(p);
			if (h and (h ~= p) and ((GetLastEnemyShot(p) >= 0.0) or Mission.m_bIsFriendlyFireOn))
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
				if(Mission.m_ShipOnlyMode)
				then
					Mission.m_SpawnedAtTime[i] = -4096;

					--					AddKills(p, -1); -- Ouch. Don't do thatnot 
					if (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
						AddScore(p, -ScoreForKillingCraft); -- Ouch. Don't do thatnot 
					SelfDamage(p, 1e+20);
				end

				-- Did they just hop out, leaving that craft w/o a pilot? Nuke that craft too.
				Handle lastp = Mission.m_LastPlayerCraftHandle[i];
				if(IsAround(lastp))
				then
					lastp = Mission.m_LastPlayerCraftHandle[i];
					if(not IsAliveAndPilot(lastp))
					then
						if(Mission.m_ShipOnlyMode)
						then
							SelfDamage(Mission.m_LastPlayerCraftHandle[i], 1e+20);
						end
						else
						then
							-- Not ship-only mode. Add this to empties list
							if(Mission.m_NumVehiclesTracked < MAX_VEHICLES_TRACKED)
								Mission.m_EmptyVehicles[Mission.m_NumVehiclesTracked++] = Mission.m_LastPlayerCraftHandle[i];
						end
						Mission.m_LastPlayerCraftHandle[i] = 0; -- 'forget' about this.
					end -- last craft is now an empty
				end -- lastp is still around
			end -- p is currently a pilot.
			else
			then
				-- Must be in a craft. Store it.
				Mission.m_LastPlayerCraftHandle[i] = p;
			end
		end -- p valid (i.e. human is playing on that team)
	end -- i loop over MAX_TEAMS
#endif -- #ifndef EDITOR
end -- ExecuteTrackPlayers


-- Called via execute, Mission.m_GameTPS of a second has elapsed. Update everything.
void Deathmatch01::UpdateGameTime(void)
then
#ifndef EDITOR
	Mission.m_ElapsedGameTime++;

	-- Are we in a time limited game?
	if(Mission.m_RemainingGameTime>0)
	then
		Mission.m_RemainingGameTime--;
		if(not (Mission.m_RemainingGameTime % Mission.m_GameTPS))
		then
			-- Convert tenth-of-second ticks to hour/minutes/seconds format.
			local Seconds = Mission.m_RemainingGameTime / Mission.m_GameTPS;
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
				if((Seconds == 0) and ((Minutes <= 10) or (not (Minutes % 5))))
					AddToMessagesBox(TempMsgString);
				else
				then
					-- Every 5 seconds when under a minute is remaining.
					if((Minutes == 0) and (not (Seconds % 5)))
						AddToMessagesBox(TempMsgString);
				end
			end
		end

		-- Game over due to timeout?
		if(not Mission.m_RemainingGameTime)
		then
			NoteGameoverByTimelimit();
			DoGameover(10.0);
		end

	end
	else
	then
		-- Infinite time game. Periodically update ingame clock.
		if(not (Mission.m_ElapsedGameTime % Mission.m_GameTPS))
		then
			-- Convert tenth-of-second ticks to hour/minutes/seconds format.
			local Seconds = Mission.m_ElapsedGameTime / Mission.m_GameTPS;
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

	if(not (Mission.m_ElapsedGameTime % InitialSpawnInFrequency))
	then

#ifdef _DEBUG
		-- Spam in all units asap to make logs line up better
		while(Mission.m_NumAIUnits < Mission.m_MaxAIUnits)
		then
			BuildBotCraft(Mission.m_NumAIUnits);
			Mission.m_NumAIUnits++;
		end
#endif

		if(Mission.m_NumAIUnits < Mission.m_MaxAIUnits)
		then
			BuildBotCraft(Mission.m_NumAIUnits);
			Mission.m_NumAIUnits++;
		end
		else
		then
			for(i = 0;i<Mission.m_NumAIUnits;i++) 
			then
				-- Fix for mantis #400 - if a bot craft is sniped,
				-- 'forget' about it and build another in its slot.
				if(not IsNotDeadAndPilot2(Mission.m_AICraftHandles[i]))
				then
					_ASSERTE(0);
					SetLifespan(Mission.m_AICraftHandles[i], SNIPED_AI_LIFESPAN);
					Mission.m_AICraftHandles[i] = 0;
				end

				if(Mission.m_AICraftHandles[i] == 0) 
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
--	local GameTime = ((float)Mission.m_ElapsedGameTime) / Mission.m_GameTPS;

	for(i = 0;i<Mission.m_NumAIUnits;i++)
	then
		if(((Mission.m_ElapsedGameTime + i) & 0x1F) == 0)
		then

			if(Mission.m_AILastWentForPowerup[i])
			then
				Handle Target = Mission.m_AITargetHandles[i];
				Mission.m_PowerupGotoTime[i]++;
				-- Max of 15 seconds to pick up a powerup, then we go again
				if((not IsAlive(Target)) or (Mission.m_PowerupGotoTime[i] > 150) ||
					(GetDistance(Mission.m_AICraftHandles[i], Mission.m_AITargetHandles[i]) < 2.0))
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
				local TargetIsAlive = IsAlive(Mission.m_AITargetHandles[i]);
				Handle WhoLastShotMe = GetWhoShotMe(Mission.m_AICraftHandles[i]);

				-- AI check: if we're getting shot by someone, and our primary
				-- target is not getting hit by us (or they don't exist), nail
				-- them instead.
				if((WhoLastShotMe ~= 0) and ((not TargetIsAlive) ||
					(GetWhoShotMe(Mission.m_AITargetHandles[i]) ~= Mission.m_AICraftHandles[i])))
				then
					-- Ignore anything close to friendly fire.
					if(not IsAlly(Mission.m_AICraftHandles[i], WhoLastShotMe))
					then
						-- Short circuit: hit them instead.
						Mission.m_AITargetHandles[i] = WhoLastShotMe;
						Attack(Mission.m_AICraftHandles[i], Mission.m_AITargetHandles[i]);
						break; -- Skip all the rest of the targets
					end
				end

				-- AI check: if our target has gone missing, need a retargetnot 
				if(not TargetIsAlive)
				then
					Retarget = true;
				end

				-- Next AI check: if it's been a while since we got hit, find something else.
				if((not Retarget) and (GetLastEnemyShot(Mission.m_AICraftHandles[i]) > (GameTime + 5.0)))
				then
					Retarget = true;
				end

				-- Need to retarget? Do so.
				if(Retarget)
					FindGoodAITarget(i);
				else
					Attack(Mission.m_AICraftHandles[i], Mission.m_AITargetHandles[i]);
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
	for(i = 0;i<Mission.m_NumAnimals;i++)
	then
		if(Mission.m_AnimalHandles[i] ~= 0)
		then
			Handle h = Mission.m_AnimalHandles[i];
			if(not IsAlive(h))
				Mission.m_AnimalHandles[i] = 0;
		end
	end -- loop over all objects

	-- Spawn in animals at the start of the game (staggered every 4
	-- seconds)
	local InitialSpawnInFrequency = 4 * Mission.m_GameTPS; -- Mission.m_GameTPS ticks per second

	if(not (Mission.m_ElapsedGameTime % InitialSpawnInFrequency))
	then
		if(Mission.m_NumAnimals < Mission.m_MaxAnimals)
		then
			SetupAnimal(Mission.m_NumAnimals);
			Mission.m_NumAnimals++;
		end
		else
		then
			-- 'Full' set of animals. Do respawns as needed.
			for(i = 0;i<Mission.m_NumAnimals;i++)
			then
				if(Mission.m_AnimalHandles[i] == 0)
				then
					SetupAnimal(i);
					break;
				end
			end
		end
	end -- periodic check

#if 0--def _DEBUG
	-- Slowly kill off animals so that they respawn
	for(i = 0;i<Mission.m_NumAnimals;i++)
	then
		if(Mission.m_AnimalHandles[i] ~= 0)
		then
			Damage(Mission.m_AnimalHandles[i], 1);
		end
	end -- loop over all objects
#endif
#endif -- #ifndef EDITOR
end -- UpdateAnimals()

void Deathmatch01::Execute(void)
then
	local i;

	-- Always ensure we did this
	if (not Mission.m_DidOneTimeInit)
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

	if(DMIsRaceSubtype[Mission.m_MissionType]) 
		ExecuteRace();

	if((Mission.m_RabbitMode) and (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2)) -- Only in Normal DM. -GBD
		ExecuteRabbit();

	if(Mission.m_WeenieMode)
		ExecuteWeenie();

	-- CTF - periodically re-objectify the opponent's flag
	if(Mission.m_MissionType == DMSubtype_CTF)
	then
		if(not (Mission.m_ElapsedGameTime % Mission.m_GameTPS))
		then
			ObjectifyFlag();
		end
	end

	ExecuteTrackPlayers();

	-- Do this as well...
	UpdateGameTime();

	if(Mission.m_MaxAIUnits)
		UpdateAIUnits();

	if(Mission.m_MaxAnimals)
		UpdateAnimals();

	-- Keep powerups going, etc
	PUPMgr::Execute();

	-- Check to see if someone was flagged as flying, and if they've
	-- landed, build a new craft for them
	for(i = 0;i<MAX_TEAMS;i++)
	then
		if(Mission.m_Flying[i])
		then
			Handle PlayerH = GetPlayerHandle(i);
			if((PlayerH ~= 0) and (not IsFlying(PlayerH)))
			then
				Mission.m_Flying[i] = false; -- clear flag so we don't check until they're dead
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

	if((Mission.m_ScoreLimit > 0) and (not Mission.m_bDidGameOverByScore))
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
				if ((WhichTeamGroup >= 0) and (whichteamgroupami < MAX_MULTIPLAYER_TEAMS))
				then
					Teamscore[whichteamgroupami] += GetScore(playerH);

					if (not TeamplayHandles[whichteamgroupami])
						TeamplayHandles[whichteamgroupami] = playerH;
				end
			end
			else
			then
				if (GetScore(playerH) >= Mission.m_ScoreLimit)
				then
					NoteGameoverByScore(playerH);
					DoGameover(5.0);
					Mission.m_bDidGameOverByScore = true;
					break;
				end
			end
		end
		if (Teamplay)
		then
			for (i = 0; i < MAX_MULTIPLAYER_TEAMS; i++)
			then
				if (Teamscore[i] >= Mission.m_ScoreLimit)
				then
					NoteGameoverByScore(TeamplayHandles[i]);
					DoGameover(5.0);
					Mission.m_bDidGameOverByScore = true;
					break;
				end
			end
		end
	end
#endif -- #ifndef EDITOR
end

local Deathmatch01::AddPlayer(DPID id, local Team, local IsNewPlayer)
then
	if (not Mission.m_DidOneTimeInit)
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
	local RespawnInVehicle = (GetRespawnInVehicle()) or (Mission.m_RabbitMode and (DeadObjectHandle == Mission.m_RabbitTargetHandle));

	if(Mission.m_RabbitMode and (DeadObjectHandle == Mission.m_RabbitTargetHandle))
	then
		Mission.m_ForbidRabbitTeam = Mission.m_RabbitTeam;
		Mission.m_RabbitTargetHandle = 0;
	end

	if(DMIsRaceSubtype[Mission.m_MissionType]) 
	then
		-- Race-- spawn back at last spawnpolocal they were at.
		local LastSpawnAt = Mission.m_NextRaceCheckpoint[Team]-1;
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
	elseif((not IsTeamplayOn()) or (Team<1))
	then
		Where = GetRandomSpawnpoint();
		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	end
	else
	then
		-- Place them back where originally created
		Where.x = Mission.m_TeamPos[3*Team+0];
		Where.y = Mission.m_TeamPos[3*Team+1];
		Where.z = Mission.m_TeamPos[3*Team+2];
		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	end

	if((Team>0) and (Team<MAX_TEAMS))
		Mission.m_SpawnedAtTime[Team] = Mission.m_ElapsedGameTime; -- Note when they spawned in.

	-- Randomize starting position somewhat
	Where = GetPositionNear(Where, RespawnMinRadiusAway, RespawnMaxRadiusAway);

	if((not RespawnInVehicle) and (not Mission.m_RespawnAtLowAltitude))
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
		Mission.m_Flying[Team] = true; -- build a craft when they land.

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
	local WasMission.m_RabbitShooterHandle = (DeadObjectHandle == Mission.m_RabbitShooterHandle);
	if((Mission.m_RabbitMode) and (KillersHandle ~= Mission.m_RabbitTargetHandle))
	then
		UseRabbitScoring = true;
		KilledRabbit = (DeadObjectHandle == Mission.m_RabbitTargetHandle);
		if(KilledRabbit)
		then
			-- Clear the objective set on them...
			SetObjectiveOff(Mission.m_RabbitTargetHandle);

			-- See if the rabbit's last shooter is still alive. If so, 
			-- make them the new target asap. Else, the next
			-- ExecuteRabbit ought to pick it up.
			Handle RabbitH = KillersHandle;
			if(IsAlive(RabbitH)) 
				SetNewRabbit(RabbitH); -- Update for everyone
			else
			then
				RabbitH = Mission.m_RabbitShooterHandle;
				if(IsAlive(RabbitH)) 
					SetNewRabbit(RabbitH); -- Update for everyone
			end
		end
		else
		then
			BZTrace(("Killed Object wasn't rabbit(%08X)\n", Mission.m_RabbitTargetHandle));
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
	if((DeadObjectHandle ~= KillersHandle) and 
		(DeadTeam > 0) and (DeadTeam < MAX_TEAMS) and (Mission.m_SpawnedAtTime[DeadTeam] > 0))
	then
		IsSpawnKill = (Mission.m_ElapsedGameTime - Mission.m_SpawnedAtTime[DeadTeam]) < Mission.m_MaxSpawnKillTime;
	end

	if((UseRabbitScoring) and (not KilledRabbit))
	then
		SpawnKillMultiplier = -1; -- Force the score downnot 
		sprintf_s(TempMsgString, GetBZCCLocalizedString("mission", "%s killed the wrong target, %s\n"),
			GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle));
		AddToMessagesBox(TempMsgString);
	end
	elseif((UseRabbitScoring) and (KilledRabbit))
	then
		SpawnKillMultiplier = -1; -- Force the score downnot 
		sprintf_s(TempMsgString, GetBZCCLocalizedString("mission", "Rabbit kill by %s on %s\n"),
			GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle));
		AddToMessagesBox(TempMsgString);
	end
	elseif(IsSpawnKill)
	then
		SpawnKillMultiplier = -1;
		sprintf_s(TempMsgString, GetBZCCLocalizedString("mission", "Spawn kill by %s on %s\n"),
			GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle));
		AddToMessagesBox(TempMsgString);
	end

	-- Jira 2445: Don't count kills/deaths/score for Team 0 (props). -GBD
	if (DeadTeam ~= 0)
	then
		if ((DeadObjectHandle ~= KillersHandle) and (not IsAlly(DeadObjectHandle, KillersHandle)))
		then
			-- Killed enemy...
			if ((not WasDeadAI) or (KillForAIKill))
				AddKills(KillersHandle, 1 * SpawnKillMultiplier); -- Give them a kill

			if (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
			then
				if ((not WasDeadAI) or (PointsForAIKill))
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
			if ((not WasDeadAI) or (KillForAIKill))
				AddKills(KillersHandle, -1 * SpawnKillMultiplier); -- Suicide or teamkill counts as -1 kill

			if ((UseRabbitScoring) and (not KilledRabbit))
				SpawnKillMultiplier = 0; -- no deaths count here...

			if (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
			then
				if ((not WasDeadAI) or (PointsForAIKill))
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
			if ((UseRabbitScoring) and (not KilledRabbit))
				SpawnKillMultiplier = 0; -- no deaths count here...

			-- Give points to killee-- this always increases
			AddDeaths(DeadObjectHandle, 1 * SpawnKillMultiplier);

			if (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
			then
				if (WasDeadPerson)
					AddScore(DeadObjectHandle, ScoreForDyingAsPerson*SpawnKillMultiplier);
				else
					AddScore(DeadObjectHandle, ScoreForDyingAsCraft*SpawnKillMultiplier);
			end

			-- Neener neenernot 
			if ((KillerIsAI) and (Mission.m_NumAIUnits > 0))
				DoTaunt(TAUNTS_HumanShipDestroyed);
		end

		-- Check to see if we have a Mission.m_KillLimit winner
		if ((Mission.m_KillLimit) and (GetKills(KillersHandle) >= Mission.m_KillLimit))
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

		for(i = 0;i<Mission.m_NumAIUnits;i++)
		then
			if(DeadObjectHandle == Mission.m_AICraftHandles[i])
			then
				Mission.m_AICraftHandles[i] = 0;
				BuildBotCraft(i); -- Respawn them asap.
				bFoundAI = true;
				if(WasMission.m_RabbitShooterHandle)
				then
					Mission.m_RabbitShooterHandle = Mission.m_AICraftHandles[i];
				end
				break; -- out of i loop
			end
		end

		for(i = 0;i<Mission.m_NumAnimals;i++)
		then
			if(DeadObjectHandle == Mission.m_AnimalHandles[i])
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
		if((WasDeadPerson) or (Mission.m_RabbitMode and KilledRabbit))
		then
			return RespawnPilot(DeadObjectHandle, DeadTeam);
		end
		else
		then
			-- Don't build anything for them until they land.
			Mission.m_Flying[DeadTeam] = true;
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

	if (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
		AddScore(DeadObjectHandle, ScoreForDyingAsCraft-ScoreForKillingCraft);

	if(GetCanEject(DeadObjectHandle)) 
	then
		-- Flags saying if they can eject or not
#ifdef _DEBUG
		AddToMessagesBox("L1841 - can eject");
#endif

		Mission.m_Flying[DeadTeam] = true; -- They're flying; create craft when they land
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
	switch (Mission.m_MissionType)
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
	EnableHighTPS(Mission.m_GameTPS);

	-- Always do this to hook up clients with the taunt engine as well.
	InitTaunts(&Mission.m_ElapsedGameTime, &Mission.m_LastTauntPrintedAt, &Mission.m_GameTPS, "Bots");

	-- We're a 1.3 DLL.
	WantBotKillMessages();

	if (missionSave)
	then
		local i;

		-- init bools
		if((b_array) and (b_count))
			for (i = 0; i < b_count; i++)
				b_array[i] = false;

		-- init floats
		if((f_array) and (f_count))
			for (i = 0; i < f_count; i++)
				f_array[i] = 0.0;

		-- init handles
		if((h_array) and (h_count))
			for (i = 0; i < h_count; i++)
				h_array[i] = 0;

		-- init ints
		if((i_array) and (i_count))
			for (i = 0; i < i_count; i++)
				i_array[i] = 0;

		CreateObjectives();

		return true;
	end

	local ret = true;

	-- bools
	if (b_array ~= NULL)
		ret = ret and Read(b_array, b_count);

	-- floats
	if (f_array ~= NULL)
		ret = ret and Read(f_array, f_count);

	-- Handles
	if (h_array ~= NULL)
		ret = ret and Read(h_array, h_count);

	-- ints
	if (i_array ~= NULL)
		ret = ret and Read(i_array, i_count);

	-- Set this right after reading -- we might be on a client.  Safe
	-- to call this multiple times on the server.
	SetGravity(static_cast<float>(Mission.m_Gravity) * 0.5);

	PUPMgr::Load(missionSave);
	return ret;
end


local Deathmatch01::PostLoad(local missionSave)
then
	if (missionSave)
		return true;

	local ret = true;

	ConvertHandles(h_array, h_count);

	ret = ret and PUPMgr::PostLoad(missionSave);
#if 0
	if (DMIsRaceSubtype[Mission.m_MissionType])
	then
		for(local i = 0;i<MAX_TEAMS;i++)
		then
			Mission.m_SpawnPointHandles[i] = GetSpawnpointHandle(i);
			_ASSERTE(Mission.m_SpawnPointHandles[i]);
			local V = GetSpawnpoint(i);
			Mission.m_SpawnPointPos[3*i+0] = V.x;
			Mission.m_SpawnPointPos[3*i+1] = V.y;
			Mission.m_SpawnPointPos[3*i+2] = V.z;
		end
	end
#endif
	if(Mission.m_RabbitMode)
	then
		-- Clear, 
		Handle OrigRabbit = Mission.m_RabbitTargetHandle;
		SetNewRabbit(0); -- Clear.
		SetNewRabbit(OrigRabbit); -- re-aim everyone
	end

	-- ret = ret and PUPMgr::PostLoad(missionSave);
	return ret;
end


local Deathmatch01::Save(local missionSave)
then
	if (missionSave)
		return true;

	local ret = true;

	-- bools
	if (b_array ~= NULL)
		ret = ret and Write(b_array, b_count);

	-- floats
	if (f_array ~= NULL)
		ret = ret and Write(f_array, f_count);

	-- Handles
	if (h_array ~= NULL)
		ret = ret and Write(h_array, h_count);

	-- ints
	if (i_array ~= NULL)
		ret = ret and Write(i_array, i_count);

	ret = ret and PUPMgr::Save(missionSave);

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
	if(not Mission.m_bIsFriendlyFireOn)
	then
		const TEAMRELATIONSHIP relationship = GetTeamRelationship(shooterHandle, victimHandle);
		if((relationship == TEAMRELATIONSHIP_SAMETEAM) or 
		   (relationship == TEAMRELATIONSHIP_ALLIEDTEAM))
		then
			-- Allow snipes of items on team 0/perceived team 0, as long
			-- as they're not a local/remote player
			if(IsPlayer(victimHandle) or (GetTeamNum(victimHandle) ~= 0))
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

