--[[ BZCC Deathmatch Mission Script 
Written by General BlackDragon
Version 1.0 2-10-2019 --]]

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

local MAX_FLOAT    =  3.4028e+38;

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




local m_GameTPS = 20;

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
	m_SpawnedAtTime = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },

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
	m_AnimalConfig = nil, -- HACK - storing a string in here.

	--		AITeams[MAX_AI_UNITS], -- Which team # was last assigned to the specified AI unit
	m_PowerupGotoTime = { }, -- How much time has elapsed on their quest for a powerup
	m_RabbitTeam = 0,
	m_ForbidRabbitTeam = 0,
	m_RabbitShooterTeam = 0,
	m_RabbitMissingTurns = 0, -- how many turns they're MIA

	m_Gravity = 0, -- from ivar30
	m_ScoreLimit = 0, -- from ivar35, 0=unlimited
		
--bools
	m_GameWon = false, 
	m_Flying = { }, -- Flag saying we need to keep track of a specific player to build a craft when they land
	m_TeamIsSetUp = { },
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
	m_EmptyVehicles = { }, -- Index is 0 based.
	--m_SpawnPointHandles[MAX_TEAMS] = nil, -- Used during race
	m_AICraftHandles = { }, -- Index is 0 based.
	m_AITargetHandles = { }, -- Whom each of those is aiming at.
	m_LastPlayerCraftHandle = { }, -- for ShipOnly mode
	m_AnimalHandles = { }, -- Index is 0 based.
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

	if Mission.m_MissionType == DMSubtype_Normal or
		Mission.m_MissionType == DMSubtype_KOH or
		Mission.m_MissionType == DMSubtype_Loot
	then
		return true;
	else
		return false;
	end
end

-- Returns true if players shouldn't be respawned as a pilot, but in
-- a piloted vehicle instead, i.e. during race mode
function GetRespawnInVehicle()

	if(Mission.m_ShipOnlyMode) then
		return true;
	end

	if Mission.m_MissionType == DMSubtype_Race2 or
		Mission.m_MissionType == DMSubtype_Normal2
	then
		return true;
	else
		return false;
	end
end

-- Given a race identifier, get the flag odf back
function GetInitialFlagODF(Race)

	local TempODFName = Race .. "oflag01";
	return TempODFName;
end

-- Given a race identifier, get the stand odf back
function GetInitialFlagStandODF(Race)

	local TempODFName = Race .. "ostand01";
	return TempODFName;
end

-- Given a race identifier, get the pilot odf back
function GetInitialPlayerPilotODF(Race)

	local TempODFName = Race .. "spilo"; -- With sniper.
	return TempODFName;
end


-- Gets the next vehicle ODF for the player on a given team.
function GetNextVehicleODF(TeamNum, Randomize)

	local RType = Randomize_None; -- Default
	if(Randomize)
	then
		if(Mission.m_RespawnType == 1) then
			RType = Randomize_ByRace;
		elseif(Mission.m_RespawnType == 2) then
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

function SetupTeam(Team)
 
	-- Sanity checks: don't do anything that looks invalid
	if((Team < 0) or (Team >= MAX_TEAMS)) then
		return;
	end

	-- Also, if we've already set up this team group, don't do anything
	if((IsTeamplayOn()) and (Mission.m_TeamIsSetUp[Team])) then
		return;
	end

	local TeamRace = GetRaceOfTeam(Team);

	if(IsTeamplayOn())
	then
		SetMPTeamRace(WhichTeamGroup(Team), TeamRace); -- Lock this down to prevent changes.
	end

	local Where = SetVector(0, 0, 0);

	if(DMIsRaceSubtype[Mission.m_MissionType])
	then
		-- Race-- everyone starts off at spawnpolocal 0's position
		Where = GetSpawnpoint(0);
	elseif(Mission.m_MissionType == DMSubtype_CTF) then
		-- CTF-- find spawnpolocal by team # 
		Where = GetSpawnpointForTeam(Team, FRIENDLY_SPAWNPOINT_MAX_ALLY, FRIENDLY_SPAWNPOINT_MIN_ENEMY, RANDOM_SPAWNPOINT_MIN_ENEMY);
		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	else
		Where = GetSpawnpointForTeam(Team, FRIENDLY_SPAWNPOINT_MAX_ALLY, FRIENDLY_SPAWNPOINT_MIN_ENEMY, RANDOM_SPAWNPOINT_MIN_ENEMY);

		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	end

	-- Store position we created them at for later
	Mission.m_TeamPos[Team] = Where;

	-- Find location to place flag at
	if (Mission.m_MissionType == DMSubtype_CTF)
	then
		-- CTF
		-- Find place to drop flag from AIPaths list
		local DesiredName = "base" .. Team;
		local DesiredName2 = "m_base" .. Team;

		local pathNames = GetAiPaths();
		for i = 1, #pathNames
		do
			local label = pathNames[i];
			if(label == DesiredName)
			then
				local FlagH = nil;
				local BaseH = GetHandle(DesiredName2); -- First look for an existing base. -GBD
				if(BaseH == nil) then
					BaseH = BuildObject(GetInitialFlagStandODF(TeamRace), Team, label); -- Build race specific base. -GBD
				end
				SetAnimation(BaseH, "loop", 0);

				if(BaseH ~= nil) then
					FlagH = BuildObject(GetInitialFlagODF(TeamRace), Team, BaseH); -- Place directly ontop of flag stand. -GBD
				else
					FlagH = BuildObject(GetInitialFlagODF(TeamRace), Team, label);
				end
				SetAnimation(FlagH, "loop", 0);

				if (Team == 1)
				then
					Mission.m_Base1 = BaseH;
					Mission.m_Flag1 = FlagH;
				elseif (Team == 6) then
					Mission.m_Base2 = BaseH;
					Mission.m_Flag2 = FlagH;
				end
			end
		end

	-- CTF Flag setup
	elseif ((DMIsRaceSubtype[Mission.m_MissionType]) and (not Mission.m_RaceIsSetup)) 
	then
		local intCheckpointCount = 0;
		local hdlCheckpoint = 0;
		repeat
			intCheckpointCount = intCheckpointCount + 1;
			TempODFName = "checkpoint" .. intCheckpointCount;
			hdlCheckpoint = GetHandle(TempODFName);
		until (hdlCheckpoint == nil);
		Mission.m_TotalCheckpoints = intCheckpointCount - 1;

		Mission.m_RaceIsSetup = true;
	end

	if(IsTeamplayOn()) 
	then
		for i = GetFirstAlliedTeam(Team), GetLastAlliedTeam(Team)
		do
			if(i ~= Team)
			then
				-- Get a new position near the team's central position
				local NewPosition = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);

				-- In teamplay, store where offense players were created for respawns later
				Mission.m_TeamPos[i] = NewPosition;
			end -- Loop over allies not the commander
		end
	end

	Mission.m_TeamIsSetUp[Team] = true;

end

-- Tries to return a good target for the AI unit, orders them to go
-- after it.
function FindGoodAITarget(index)

	-- Sanity check - if this AI craft went MIA, clear handle
	if(not IsAliveAndPilot(Mission.m_AICraftHandles[index]))
	then
		Mission.m_AICraftHandles[index] = nil;
		return;
	end

	-- Rabbit mode? Hammer the "it" player, nothing else to do
	if((Mission.m_RabbitMode) and (Mission.m_AICraftHandles[index] ~= Mission.m_RabbitTargetHandle))
	then
		local TargetH = Mission.m_RabbitTargetHandle;
		if(IsAlive(TargetH))
		then
			Attack(Mission.m_AICraftHandles[index], Mission.m_RabbitTargetHandle);
		end
		return;
	end

	local nearestEnemy = GetNearestEnemy(Mission.m_AICraftHandles[index]);
	for i = 1, MAX_TEAMS-1
	do
		local PlayerH = GetPlayerHandle(i);
		-- Ignore any close-by pilots.
		if((nearestEnemy == PlayerH) and (IsAliveAndPilot(PlayerH))) then
			nearestEnemy = nil;
		end
	end

	-- Was our last action an attack? Consider powerups now.
	if((nearestEnemy ~= nil) and (not Mission.m_AILastWentForPowerup[index]))
	then
		local nearestPerson = GetNearestPerson(Mission.m_AICraftHandles[index], true, 100.0);

		local distToEnemy = GetDistance(Mission.m_AICraftHandles[index], nearestEnemy);

		if(nearestPerson ~= nil)
		then
			local distToPerson = GetDistance(Mission.m_AICraftHandles[index], nearestPerson);

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

		local nearestPowerup = GetNearestPowerup(Mission.m_AICraftHandles[index], true, 100.0);
		if(nearestPowerup ~= nil)
		then
			local distToPowerup = GetDistance(Mission.m_AICraftHandles[index], nearestPowerup);

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

	if(nearestEnemy ~= nil)
	then
		-- Nearest enemy scan failed (found pilot, too far, 
		-- something). Try harder.
		local BestDist = MAX_FLOAT;
		local BestHandle = nil;
		if(not Mission.m_HumansVsBots)
		then
			-- Scan botlist..
			for i = 0, Mission.m_NumAIUnits-1
			do
				local Skip = false;
				-- Can't attack self.
				if(i == index) then
					Skip = true;
				end
				-- If don't have a craft for self, skip.
				if(not Mission.m_AICraftHandles[index]) then
					Skip = true;
				end

				local ThisBotH = Mission.m_AICraftHandles[i];
				-- If bot died, skip them.
				if(not IsAlive(ThisBotH)) then
					Skip = true;
				end
				-- Skip friendly AIs
				if(IsAlly(Mission.m_AICraftHandles[index], Mission.m_AICraftHandles[i])) then
					Skip = true;
				end
				
				if not Skip then
					ThisBotH = Mission.m_AICraftHandles[i];
					local MyH = Mission.m_AICraftHandles[index];
					local ThisDist = GetDistance(MyH, ThisBotH);
					if((ThisDist > 0.01) and (ThisDist < BestDist))
					then
						-- Winner (of sorts). Store them.
						BestDist = ThisDist;
						BestHandle = Mission.m_AICraftHandles[i];
					end
				end
			end -- Loop over all AI units.
		end -- Isn't humans vs bots, so need to consider bots.

		--local i;
		for i = 1, MAX_TEAMS-1
		do
			local Skip = false;
			
			local PlayerH = GetPlayerHandle(i);
			if(PlayerH == nil) then
				Skip = true;
			end
			local PlayerH2 = PlayerH;

			-- Skip human pilots in this phase (GetWhoShotMe will pick up other attacks)
			if(IsAliveAndPilot(PlayerH2)) then
				Skip = true;
			end

			if not Skip then
				local MyH = Mission.m_AICraftHandles[index];
				local ThisDist = GetDistance(MyH, PlayerH);
				if((ThisDist > 0.01) and (ThisDist < BestDist))
				then
					-- Winner (of sorts). Store them.
					BestDist = ThisDist;
					BestHandle = PlayerH;
				end
			end
		end-- loop over all teams.

		if(BestHandle ~= nil)
		then
			nearestEnemy = BestHandle;
		end
	end -- Fallback for things.

	Mission.m_AITargetHandles[index] = nearestEnemy;
	-- Chargenot 
	if(nearestEnemy ~= nil)
	then
		Attack(Mission.m_AICraftHandles[index], Mission.m_AITargetHandles[index]);
	end
	Mission.m_AILastWentForPowerup[index] = false; -- In combat mode! 
end

-- Sets up the specified AI unit, first time or later.
function BuildBotCraft(index)

	local theirTeam = 0;

	if(Mission.m_RabbitMode) then
		theirTeam = 14; -- until they become 'it', and on team 15
	elseif(Mission.m_HumansVsBots) then
		theirTeam = 15;
	else
		-- Put them on a consistent team # based on their slot, so they'll
		-- respawn with the same team # later, etc.
		local NUM_AI_TEAMS = LAST_AI_TEAM - FIRST_AI_TEAM + 1;
		theirTeam = FIRST_AI_TEAM + (index % NUM_AI_TEAMS);
	end

	-- Find a valid human user, and use them to read the vehicles list.
	local APlayerTeam = 1; -- Absolute fallback, if you must
	for i = 1, MAX_TEAMS-1
	do
		if((Mission.m_TeamIsSetUp[i]) and (GetPlayerHandle(i) ~= nil)) then
			APlayerTeam = i;
		end
	end

	local Where = GetRandomSpawnpoint(theirTeam); -- Try to spawn bots at a spawnpolocal that is "safe" for them. Jira 529. -GBD
	-- Somewhere near the spawnpoint..
	Where = GetPositionNear(Where, BotMinRadiusAway, BotMaxRadiusAway);
	-- Bounce them up a little.
	Where.y = Where.y + 2.0 + GetRandomFloat(4);
	local NewCraftsODF = GetPlayerODF(APlayerTeam, Randomize_Any);

	Mission.m_AICraftHandles[index] = BuildObject(NewCraftsODF, theirTeam, Where);
	SetRandomHeadingAngle(Mission.m_AICraftHandles[index]);
	SetNoScrapFlagByHandle(Mission.m_AICraftHandles[index]);
	AddPilotByHandle(Mission.m_AICraftHandles[index]);

	-- Ok, find a 'victim' for this AI unit. :)
	FindGoodAITarget(index);
end -- BuildBotCraft()

-- Sets up the specified Animal unit, first time or later.
function SetupAnimal(index)

	local AnimalTeam = 8 + math.floor(GetRandomFloat(6));

	-- Don't make animals allied w/ humans, go to another team
	if(Mission.m_HumansVsBots or Mission.m_RabbitMode) then
		AnimalTeam = 13;
	end

	local Where = GetRandomSpawnpoint();
	-- Somewhere near the spawnpoint..
	Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	-- Bounce them up in the air a little.
	Where.y = Where.y + 2 + GetRandomFloat(4);
	local AnimalODF = Mission.m_AnimalConfig;

	Mission.m_AnimalHandles[index] = BuildObject(AnimalODF, AnimalTeam, Where);
	SetRandomHeadingAngle(Mission.m_AnimalHandles[index]);
	SetNoScrapFlagByHandle(Mission.m_AnimalHandles[index]);
	--	AddPilotByHandle(Mission.m_AICraftHandles[index]);
end -- SetupAnimal()


-- For CTF, objectifies the other team's flag
function ObjectifyFlag()

	local PlayerH = GetPlayerHandle();
	if(PlayerH == nil)
	then
		-- Shouldn't happen, but be safe in case it does
		return;
	end

	local team = GetTeamNum(PlayerH);
	local TeamBlock = WhichTeamGroup(team);
	if((IsTeamplayOn()) and (TeamBlock >= 0))
	then
	
		local myFlag = (TeamBlock == 0) and Mission.m_Flag1 or Mission.m_Flag2;
		local opponentFlag = (TeamBlock == 0) and Mission.m_Flag2 or Mission.m_Flag1;

		SetObjectiveOff(myFlag);
		SetObjectiveOn(myFlag);
		SetObjectiveName(myFlag, TranslateString("cfg", "Defend Flag!"));

		SetObjectiveOff(opponentFlag);
		SetObjectiveOn(opponentFlag);
		SetObjectiveName(opponentFlag, TranslateString("cfg", "Capture Flag!"));
	end
end



function ObjectifyRabbit()

	local PlayerH = GetPlayerHandle();
	if(PlayerH == Mission.m_RabbitTargetHandle)
	then
		ClearObjectives();
	else
		-- Force-reset this.
		SetObjectiveOff(Mission.m_RabbitTargetHandle);
		SetObjectiveOn(Mission.m_RabbitTargetHandle);
		SetObjectiveName(Mission.m_RabbitTargetHandle, TranslateString("cfg", "Wabbit!"));
		--			SetUserTarget(Mission.m_RabbitTargetHandle);
	end
end


-- This handle is the new rabbit. Target themnot 
function SetNewRabbit(h)

	-- Ignore invalid handle.
	if(h == nil) or (not IsAround(h)) then
		return;
	end

	Mission.m_RabbitMissingTurns = 0; -- always clear this

	-- Remove old objectification
	SetObjectiveOff(Mission.m_RabbitTargetHandle);

	Mission.m_RabbitTargetHandle = h;
	Mission.m_RabbitShooterHandle = nil;
	--		Mission.m_RabbitShooterWasHuman = false;
	--		Mission.m_RabbitShooterTeam = 0;

	if(not IsPlayer(h))
	then
		Mission.m_RabbitWasHuman = false;
		Mission.m_RabbitTeam = 0;
		SetTeamNum(h, 15); -- Force a different team #, so AI will target them.
	else
		Mission.m_RabbitWasHuman = true;
		Mission.m_RabbitTeam = GetTeamNum(h);
	end

	local FoundIt = false;
	for i = 1, MAX_TEAMS-1
	do
		local PlayerH = GetPlayerHandle(i);
		if(PlayerH == Mission.m_RabbitTargetHandle)
		then
			FoundIt = true;
		end
	end

	-- Reset targets for all bots
	for i = 0, Mission.m_NumAIUnits-1
	do
		if(Mission.m_AICraftHandles[i] ~= h) then
			FindGoodAITarget(i);
		end
	end

	-- Also, reset objectives the local player.
	local PlayerH = GetPlayerHandle();
	if(PlayerH == Mission.m_RabbitTargetHandle)
	then
		-- We're the victim. Let them know.
		AddToMessagesBox(TranslateString("mission", "It's wabbit hunting season. Do you feel lucky?"));
	else
		ObjectifyRabbit();
	end
end -- end of SetNewRabbit.


function SetupPlayer(Team)

	local PlayerH =  nil;
	local Where = SetVector(0, 0, 0);

	if((Team < 0) or (Team >= MAX_TEAMS)) then
		return nil; -- Sanity check... do NOT proceed
	end

	Mission.m_SpawnedAtTime[Team] = Mission.m_ElapsedGameTime; -- Note when they spawned in.

	local TeamBlock = WhichTeamGroup(Team);

	if((not IsTeamplayOn()) or (TeamBlock < 0))
	then

		if(DMIsRaceSubtype[Mission.m_MissionType]) then
			Where = GetSpawnpoint(0); -- Start at spawnpolocal 0
		else
			Where = GetRandomSpawnpoint();
		end

		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
		Where.y = Where.y + 1.0;

		-- This player is their own commander; set up their equipment.
		SetupTeam(Team);
	else
		-- Teamplay. Gotta put them near their commander. Also, always
		-- ensure the recycler/etc has been set up for this team if we
		-- know who they are
		SetupTeam(GetCommanderTeam(Team));

		-- SetupTeam will fill in the Mission.m_TeamPos[] array of positions
		-- for both the commander and offense players, so read out the
		-- results
		Where = Mission.m_TeamPos;
		Where.y = TerrainFindFloor(Where.x, Where.z) + 1.0;
	end -- Teamplay setup

	if(DMIsRaceSubtype[Mission.m_MissionType]) 
	then
		-- Race. Start off near spawnpolocal 0
		Where = GetSpawnpoint(0);
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
		Where.y = Where.y + 1.0;
		Mission.m_NextRaceCheckpoint[Team] = 1; -- Heading towards sp 1
		Mission.m_TotalCheckpointsCompleted[Team] = 0; -- None so far
		Mission.m_LapNumber[Team] = 0; -- None so far
		Mission.m_RaceWinerCount = 0; -- None so far
		RaceSetObjective = false;
	end

	PlayerH = BuildObject(GetPlayerODF(Team), Team, Where);
	if(not DMIsRaceSubtype[Mission.m_MissionType]) then
		SetRandomHeadingAngle(PlayerH);
	end
	SetNoScrapFlagByHandle(PlayerH);

	-- If on team 0 (dedicated server team), make this object gone from the world
	if(Team == 0) then
		MakeInert(PlayerH);
	end

	if((IsTeamplayOn()) and (TeamBlock >= 0))
	then
		-- Also set up the other side too now, in case it wasn't done earlier.
		-- This puts both CTF flags on the map when the first player joins.
		SetupTeam(7 - GetCommanderTeam(Team));
	end

	return PlayerH;
end

function InitialSetup()

	m_GameTPS = EnableHighTPS();
	SetAutoGroupUnits(false);

	-- Make sure we always call this
	_FECore.InitialSetup();
	
		-- Always do this to hook up clients with the taunt engine as well.
	SetTauntCPUTeamName("Bots");

	-- We're a 1.3 DLL.
	WantBotKillMessages();

	CreateObjectives();

end

-- Collapses the tracked vehicle list so there are no holes (values
-- of 0) in it, puts the updated count in Mission.m_NumVehiclesTracked
function CrunchEmptyVehicleList()

	local j = 0;
	for i = 0, MAX_VEHICLES_TRACKED-1
	do
		if(Mission.m_EmptyVehicles[i] ~= nil)
		then
			Mission.m_EmptyVehicles[j] = Mission.m_EmptyVehicles[i];
			j = j + 1;
		end
	end

	Mission.m_NumVehiclesTracked = j; -- idx of the first empty slot

	-- Zero out the rest of the array
	for j = Mission.m_NumVehiclesTracked, MAX_VEHICLES_TRACKED-1
	do
		Mission.m_EmptyVehicles[j] = nil;
	end
end

-- Designed to be called from Execute(), updates list of empty
-- vehicles, killing some if there are too many, and forgetting
-- about any if they've been entered.
function UpdateEmptyVehicles()

	-- Early-exit if no vehicles tracked.
	if(Mission.m_NumVehiclesTracked == 0) then
		return;
	end

	local anyChanges = false;
	for i = 0, MAX_VEHICLES_TRACKED-1
	do
		if(Mission.m_EmptyVehicles[i] ~= nil)
		then
			local TempH = Mission.m_EmptyVehicles[i];
			if(not IsAround(Mission.m_EmptyVehicles[i]))
			then
				Mission.m_EmptyVehicles[i] = nil; -- craft died. Forget about it.
				anyChanges = true;
			elseif(IsPlayer(Mission.m_EmptyVehicles[i]))
			then
				Mission.m_EmptyVehicles[i] = nil; -- Human entered this. No longer empty
				anyChanges = true;
			elseif(IsAliveAndPilot(TempH))
			then
				Mission.m_EmptyVehicles[i] = nil; -- AI pilot entered this. No longer empty
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
	local MaxEmpties = CurNumPlayers + bit32.rshift(CurNumPlayers, 1) + 1; -- 150% of # of players on map
	if(Mission.m_NumVehiclesTracked > MaxEmpties)
	then
		SelfDamage(Mission.m_EmptyVehicles[0], 1e+20);
		Mission.m_EmptyVehicles[0] = nil; -- forget about this craft, as it better not exist anymore
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
function AddEmptyVehicle(NewCraft)

	if(NewCraft == nil) then
		return;
	end

	-- Don't overflow buffernot 
	if(Mission.m_NumVehiclesTracked >= MAX_VEHICLES_TRACKED)
	then
		UpdateEmptyVehicles();

		-- Kill oldest one, NOW.
		if(Mission.m_EmptyVehicles[0])
		then
			SelfDamage(Mission.m_EmptyVehicles[0], 1e+20);
			Mission.m_EmptyVehicles[0] = nil; -- forget about this craft, as it better not exist anymore
			CrunchEmptyVehicleList();
		end
	end

	-- This better succeed after the above.
	if(Mission.m_NumVehiclesTracked < MAX_VEHICLES_TRACKED)
	then
		Mission.m_EmptyVehicles[Mission.m_NumVehiclesTracked] = NewCraft;
		Mission.m_NumVehiclesTracked = Mission.m_NumVehiclesTracked + 1
	end
end -- AddEmptyVehicle()


function Start()

	RaceSetObjective = false;

	-- Read from the map's .trn file whether we respawn at altitude or
	-- not.
	local mapTrnFile = GetMapTRNFilename();
	Mission.m_RespawnAtLowAltitude = GetODFBool(mapTrnFile, "DLL", "RespawnAtLowAltitude", false);
	Mission.m_RaceCheckpointRadius = GetODFFloat(mapTrnFile, "DLL", "CheckpointRadius", 35.0);

	Mission.m_LastTeamInLead = DPID_UNKNOWN;

	Mission.m_KillLimit = GetVarItemInt("network.session.ivar0");
	Mission.m_TotalGameTime = GetVarItemInt("network.session.ivar1");
	-- Skip ivar2-- player limit. Assume the netmgr takes care of that.
	local MissionTypePrefs = GetVarItemInt("network.session.ivar7");
	Mission.m_TotalRaceLaps = GetVarItemInt("network.session.ivar9"); -- Just in case we're using this
	Mission.m_Gravity = GetVarItemInt("network.session.ivar31");
	Mission.m_ScoreLimit = GetVarItemInt("network.session.ivar35");
	-- Set this for the server now. Clients get this set from Load().
	SetGravity(Mission.m_Gravity * 0.5);

	Mission.m_bIsFriendlyFireOn = (GetVarItemInt("network.session.ivar32") ~= 0);

	Mission.m_MaxSpawnKillTime = m_GameTPS * GetVarItemInt("network.session.ivar13"); -- convert seconds to 1/10 ticks
	if(Mission.m_MaxSpawnKillTime < 0) then
		Mission.m_MaxSpawnKillTime = 0; -- sanity check
	end

	Mission.m_MissionType = bit32.band(MissionTypePrefs, 0xFF);
	Mission.m_RespawnType = bit32.band(bit32.rshift(MissionTypePrefs, 8), 0xFF);

	Mission.m_NumAIUnits = 0;
	Mission.m_MaxAIUnits = 0;
	if(not DMIsRaceSubtype[Mission.m_MissionType])
	then
		Mission.m_MaxAIUnits = GetVarItemInt("network.session.ivar9");
		if(Mission.m_MaxAIUnits >= MAX_AI_UNITS) then
			Mission.m_MaxAIUnits = MAX_AI_UNITS;
		end

		-- If the network is not on, this map was probably started from the
		-- commandline, and therefore, ivars are not at the defaults expected.
		-- Switch to some sane defaults.
		if(not IsNetworkOn())
		then
			Mission.m_MaxAIUnits = 0;
			Mission.m_Gravity = 25; -- default
			SetGravity(Mission.m_Gravity * 0.5);
		end
	end

	Mission.m_AIUnitSkill = GetVarItemInt("network.session.ivar22");
	if((Mission.m_AIUnitSkill < 0) or (Mission.m_AIUnitSkill > 4)) then
		Mission.m_AIUnitSkill = 3
	end

	if(not IsNetworkOn()) then
		Mission.m_AIUnitSkill = 3;
	end

	Mission.m_HumansVsBots = (GetVarItemInt("network.session.ivar16") ~= 0);

	-- If it's vs bots, make all humans allied (but not with animals
	-- (team 13))
	if(Mission.m_HumansVsBots)
	then
		for i = 1, 11
		do
			for j = 1, 11
			do
				if(i ~= j)
				then
					Ally(i, j);
				end
			end
		end
	end

	Mission.m_RabbitMode = (GetVarItemInt("network.session.ivar23") ~= 0);

	Mission.m_WeenieMode = (GetVarItemInt("network.session.ivar19") ~= 0);
	Mission.m_ShipOnlyMode = (GetVarItemInt("network.session.ivar25") ~= 0);

	Mission.m_NumAnimals = 0;
	Mission.m_MaxAnimals = GetVarItemInt("network.session.ivar27");
	if(Mission.m_MaxAnimals >= MAX_ANIMALS) then
		Mission.m_MaxAnimals = MAX_ANIMALS; 
	end

	if(Mission.m_MaxAnimals > 0)
	then
		Mission.m_AnimalConfig = GetCheckedNetworkSvar(12, NETLIST_Animals);
		if((Mission.m_AnimalConfig == nil) or string.len(Mission.m_AnimalConfig) < 2) then
			Mission.m_AnimalConfig = "mcjak01";
		end
	end

	local PlayerH = nil;
	local playerEntryH = nil;
	local LocalTeamNum = GetLocalPlayerTeamNumber(); -- Query this from game

	-- As the .bzn has a vehicle which may not be appropriate, we
	-- must zap that player object and recreate them the way we want
	-- them when the game starts up.
	playerEntryH = GetPlayerHandle();
	if(playerEntryH ~= nil) then
		RemoveObject(playerEntryH);
	end

	-- Do One-time server side init of varbs for everyone
	if((ImServer()) or (not IsNetworkOn()))
	then
		if(not Mission.m_RemainingGameTime) then
			Mission.m_RemainingGameTime = Mission.m_TotalGameTime* 60 * m_GameTPS; -- convert minutes to 1/10 seconds
		end

		-- And build local player
		PlayerH = SetupPlayer(LocalTeamNum);
		SetAsUser(PlayerH, LocalTeamNum);
		AddPilotByHandle(PlayerH);

		-- First player becomes the rabbit target
		if((Mission.m_RabbitMode) and (Mission.m_RabbitTargetHandle == nil))
		then
			SetNewRabbit(PlayerH);
		end

	end -- Server or no network

--------------------------------------------------------------------------------
	--PUPMgr::Init(); -- !!! TODO: WRITE ME! -GBD
--------------------------------------------------------------------------------
end


-- Flags the appropriately 'next' spawnpolocal as the objective
function ObjectifyRacePoint()

	local LastObjectified = -1;
	-- First, clear all previous objectives
	for i = 0, Mission.m_TotalCheckpoints
	do
		TempODFName = "checkpoint" .. i+1;
		SetObjectiveOff(GetHandle(TempODFName)); -- Ensure these are all cleared off.
	end
	local Idx = GetLocalPlayerTeamNumber();
	if(Idx >= 0)
	then
		if(not Mission.m_TotalRaceLaps or (Mission.m_LapNumber[Idx] < Mission.m_TotalRaceLaps))
		then
			TempODFName = "checkpoint" .. Mission.m_NextRaceCheckpoint[Idx];
			local NextCheckpoint = GetHandle(TempODFName);
			if(NextCheckpoint ~= nil) then
				SetObjectiveOn(NextCheckpoint);
			end
		end
	end
end


-- Rabbit-specific execute stuff. Kill da wabbitnot  Kill da wabbitnot 
function ExecuteRabbit()

	-- Rebuild the rabbit if they're missing for more than a half
	-- second...
	local RabbitH = Mission.m_RabbitTargetHandle;
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
			
			print("Set Rabbit to Player on Rabbit Team, Rabbit Changed Teams");
		end
	else
		Mission.m_RabbitMissingTurns = Mission.m_RabbitMissingTurns + 1;
	end

	-- Track the rabbit shooter in case they died/switched vehicles, etc
	if((Mission.m_RabbitShooterWasHuman) and (Mission.m_RabbitShooterHandle ~= GetPlayerHandle(Mission.m_RabbitShooterTeam)))
	then
		Mission.m_RabbitShooterHandle = GetPlayerHandle(Mission.m_RabbitShooterTeam);
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
				
				print("Set Rabbit to Player on Rabbit Team, no rabbit was around");
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
				
				print("Set Rabbit to Last Rabbit Shooter");
			else
				-- Gone, no known shooter. Pick a semi-random human to take
				-- over. The timestep at which this occurrs should be fairly
				-- random
				local foundNewRabbit = false;
				for i = 1, MAX_TEAMS-1
				do
					local T2 = (Mission.m_ElapsedGameTime + i) % MAX_TEAMS;
					local PlayerH = GetPlayerHandle(T2);
					if((T2 ~= 0 and PlayerH ~= nil) and (T2 ~= Mission.m_ForbidRabbitTeam))
					then
						SetNewRabbit(PlayerH);
						foundNewRabbit = true;
						Mission.m_ForbidRabbitTeam = 0;
						
						print("Set Rabbit to Random Player");
						break; -- out of this for loop
					end
				end

				-- If we didn't find a human, pick a random AI
				if(not foundNewRabbit)
				then
					for i = 1, MAX_AI_UNITS-1
					do
						local index2 = (Mission.m_ElapsedGameTime + i) % MAX_AI_UNITS;
						if(Mission.m_AICraftHandles[index2] ~= nil)
						then
							SetNewRabbit(Mission.m_AICraftHandles[index2]);
							foundNewRabbit = true;
							Mission.m_ForbidRabbitTeam = 0;
							
							print("Set Rabbit to Random AI");
							break; -- out of this for loop
						end
					end -- i loop over MAX_AI_UNITS
				end -- Still hadn't found a human player to be the rabbit

				AddToMessagesBox(TranslateString("mission", "Reset the rabbit... it's hunting season!"));
			end
		end
	end

	-- If the rabbit's MIA, skip this.
	RabbitH = Mission.m_RabbitTargetHandle;
	if(not IsAround(RabbitH)) then
		return; -- Can't do a thing here.
	end

	-- Update the last *other* person to hit me, only overriding if
	-- valid data
	local LastShooter = GetWhoShotMe(Mission.m_RabbitTargetHandle);

	if((LastShooter ~= nil) and (LastShooter ~= Mission.m_RabbitTargetHandle) and (LastShooter ~= Mission.m_RabbitShooterHandle))
	then

		-- Workaround- if player (craft) was rabbit shooter, but they
		-- died as a pilot, LastShooter will the craft that did the
		-- shooting. So, reassign to player if they're still around.
		local LastShooterTeam = GetTeamNum(LastShooter);
		if((LastShooterTeam == Mission.m_RabbitShooterTeam) or (Mission.m_RabbitShooterTeam == 0))
		then
			local temph = GetPlayerHandle(Mission.m_RabbitShooterTeam);
			if(temph ~= nil) then
				LastShooter = temph;
			end
		end

		Mission.m_RabbitShooterHandle = LastShooter;

		-- Preclear this...
		Mission.m_RabbitShooterWasHuman = false;
		Mission.m_RabbitShooterTeam = 0;

		local FoundIt = false;
		for i = 1, MAX_TEAMS-1
		do
			local PlayerH = GetPlayerHandle(i);
			if(PlayerH == Mission.m_RabbitShooterHandle)
			then
				Mission.m_RabbitShooterWasHuman = true;
				Mission.m_RabbitShooterTeam = i;
				FoundIt = true;
			end
		end
	end

	-- Have a known rabbit. Update scores for them, 1 polocal every 5 seconds
	if(((Mission.m_ElapsedGameTime % (5 * m_GameTPS)) == 0) and ((CountPlayers() > 1) or (Mission.m_NumAIUnits > 0)))
	then
		AddScore(Mission.m_RabbitTargetHandle, 1); -- Staying alive....
	end

	if(not (Mission.m_ElapsedGameTime % m_GameTPS))
	then
		ObjectifyRabbit();
	end
end -- ExecuteRabbit

-- Race-specific execute stuff.
function ExecuteRace()

	if((not RaceSetObjective) or (not (Mission.m_ElapsedGameTime % m_GameTPS))) 
	then
		-- Race. Gotta set objectives properly
		RaceSetObjective = true;
		ObjectifyRacePoint();
	end -- Periodic re-objectifying

	-- Also, check if everyone's near their next checkpoint
	local Advanced = { };
	local AnyAdvanced = false;

	for i = 1, MAX_TEAMS-1
	do
		Advanced[i] = false;
		local PlayerH = GetPlayerHandle(i);
		if(PlayerH ~= nil) then
		
			TempODFName = "checkpoint" .. Mission.m_NextRaceCheckpoint[i];
			local NextCheckpoint = GetHandle(TempODFName);
			if(NextCheckpoint ~= nil)
			then
				--Player is close enough AND (0 laps OR not finished already)
				if((GetDistance(PlayerH, NextCheckpoint) < (Mission.m_RaceCheckpointRadius)) and ((not Mission.m_TotalRaceLaps) or (Mission.m_LapNumber[i] < Mission.m_TotalRaceLaps)))
				then
					Mission.m_NextRaceCheckpoint[i] = Mission.m_NextRaceCheckpoint[i] + 1;
					if(Mission.m_NextRaceCheckpoint[i] > Mission.m_TotalCheckpoints)
					then
						Mission.m_NextRaceCheckpoint[i] = 1;
						Mission.m_LapNumber[i] = Mission.m_LapNumber[i] + 1;
					end
					ObjectifyRacePoint();
					Advanced[i] = true;
					AnyAdvanced = AnyAdvanced or Advanced[i];
					Mission.m_TotalCheckpointsCompleted[i] = Mission.m_TotalCheckpointsCompleted[i] + 1;

					-- Prlocal out a message for local player upon lap completion
					if((Mission.m_NextRaceCheckpoint[i] == 1) and (i == GetLocalPlayerTeamNumber()))
					then
						if(Mission.m_TotalRaceLaps ~= 0) then
							StaticTempMsgStr = TranslateString("mission", ("Lap %d/%d Completed"):format(Mission.m_LapNumber[i], Mission.m_TotalRaceLaps));
						else
							StaticTempMsgStr = TranslateString("mission", ("Lap %d Completed"):format(Mission.m_LapNumber[i]));
						end

						AddToMessagesBox(StaticTempMsgStr);
					end
				end
			end -- NextCheckpoint exists
		end
	end -- Loop over all players

	-- Give a polocal to someone if they made it to a Checkpoint before anyone else did.
	if(AnyAdvanced)
	then
		for i = 1, MAX_TEAMS-1
		do
			if(Advanced[i])
			then
				local PlayerH = GetPlayerHandle(i);

				local LeadingPlayer = true;
				for j = 1, MAX_TEAMS-1
				do
					if((i~= j) and (Mission.m_TotalCheckpointsCompleted[i] <= Mission.m_TotalCheckpointsCompleted[j])) then
						LeadingPlayer = false;
					end
				end
				if(LeadingPlayer)
				then
					if(i ~= Mission.m_LastTeamInLead)
					then
						StaticTempMsgStr = TranslateString("mission", ("%s takes the lead"):format(GetPlayerName(PlayerH)));
						AddToMessagesBox(StaticTempMsgStr);
						Mission.m_LastTeamInLead = i;
					end
				end

				-- Also check if leader completed a full lap
				LeadingPlayer = true;
				for j = 1, MAX_TEAMS-1
				do
					if((i~= j) and (Mission.m_TotalCheckpointsCompleted[i] < Mission.m_TotalCheckpointsCompleted[j])) then
						LeadingPlayer = false;
					end
				end
				if((LeadingPlayer) and (Mission.m_NextRaceCheckpoint[i] == 1))
				then
					AddScore(PlayerH, 1); -- Add score to show lap completion. -GBD

					if(Mission.m_TotalRaceLaps ~= 0)
					then
						if(not Mission.m_RaceWinerCount) then
							StaticTempMsgStr = TranslateString("mission", ("Lap %d/%d completed by %s"):format(Mission.m_LapNumber[i], Mission.m_TotalRaceLaps, GetPlayerName(PlayerH)));
						end
					else
						if(not Mission.m_RaceWinerCount) then
							StaticTempMsgStr = TranslateString("mission", ("Lap %d completed by %s"):format(Mission.m_LapNumber[i], GetPlayerName(PlayerH)));
						end
					end

					AddToMessagesBox(StaticTempMsgStr);
					if(Mission.m_LapNumber[i] == Mission.m_TotalRaceLaps)
					then
						Mission.m_RaceWinerCount = Mission.m_RaceWinerCount + 1;
						
						if(Mission.m_RaceWinerCount == 1) then
							StaticTempMsgStr = TranslateString("mission", ("%s finished in 1st place"):format(GetPlayerName(PlayerH)));
							AddScore(PlayerH, 100);
						elseif(Mission.m_RaceWinerCount == 2) then
							StaticTempMsgStr = TranslateString("mission", ("%s finished in 2nd place"):format(GetPlayerName(PlayerH)));
							AddScore(PlayerH, 75);
						elseif(Mission.m_RaceWinerCount == 3) then
							StaticTempMsgStr = TranslateString("mission", ("%s finished in 3rd place"):format(GetPlayerName(PlayerH)));
							AddScore(PlayerH, 50);
						else
							StaticTempMsgStr = TranslateString("mission", ("%s finished in %dth place"):format(GetPlayerName(PlayerH), Mission.m_RaceWinerCount));
							AddScore(PlayerH, 25);
						end
						if(Mission.m_RaceWinerCount <= 1)
						then
							NoteGameoverWithCustomMessage(StaticTempMsgStr);
							StaticTempMsgStr =  TranslateString("mission", "10 seconds left...");
						else
							AddToMessagesBox(StaticTempMsgStr);
						end
						DoGameover(10.0);
					end
				end
			end
		end
	end
end -- ExecuteRace()

function ExecuteWeenie()

	-- Go over all humans first
	for i = 1, MAX_TEAMS-1
	do
		local p = GetPlayerHandle(i);
		if(p ~= nil)
		then
			-- self-fire doesn't count (and possibly friendly fire doesn't either)
			local h = GetWhoShotMe(p);
			if (h ~= nil and (h ~= p) and ((GetLastEnemyShot(p) >= 0.0) or Mission.m_bIsFriendlyFireOn)) then
				Damage(p, MAX_FLOAT);
			end
		end
	end

	for i = 0, Mission.m_NumAIUnits-1
	do
		local p = Mission.m_AICraftHandles[i];
		if(p ~= nil)
		then
			-- self-fire doesn't count (and possibly friendly fire doesn't either)
			local h = GetWhoShotMe(p);
			if (h ~= nil and (h ~= p) and ((GetLastEnemyShot(p) >= 0.0) or Mission.m_bIsFriendlyFireOn)) then
				Damage(p, MAX_FLOAT);
			end
		end
	end

	for i = 0, Mission.m_NumAnimals-1
	do
		local p = Mission.m_AnimalHandles[i];
		if(p ~= nil)
		then
			-- self-fire doesn't count (and possibly friendly fire doesn't either)
			local h = GetWhoShotMe(p);
			if (h ~= nil and (h ~= p) and ((GetLastEnemyShot(p) >= 0.0) or Mission.m_bIsFriendlyFireOn)) then
				Damage(p, MAX_FLOAT);
			end
		end
	end

	for i = 0, Mission.m_NumVehiclesTracked-1
	do
		local p = Mission.m_EmptyVehicles[i];
		if(p ~= nil)
		then
			-- self-fire doesn't count (and possibly friendly fire doesn't either)
			local h = GetWhoShotMe(p);
			if (h ~= nil and (h ~= p) and ((GetLastEnemyShot(p) >= 0.0) or Mission.m_bIsFriendlyFireOn)) then
				Damage(p, MAX_FLOAT);
			end
		end
	end
end

-- Notices what ships all the human players are currently in. If they
-- hop out, then their old craft is pushed onto the empties list. If
-- this is 'ship only' mode, then other penalties are applied.
function ExecuteTrackPlayers()

	-- Go over all humans first
	for i = 1, MAX_TEAMS-1
	do
		local p = GetPlayerHandle(i);
		if(p ~= nil)
		then
			SetLifespan(p, -1.0); -- Ensure there's no lifespan killing this craft

			if(IsAliveAndPilot(p))
			then
				-- Make sure the 'spawn kill' doesn't get triggered.
				if(Mission.m_ShipOnlyMode)
				then
					Mission.m_SpawnedAtTime[i] = -4096;

					--					AddKills(p, -1); -- Ouch. Don't do that!
					if (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2) then -- Only in Normal DM. -GBD
						AddScore(p, -ScoreForKillingCraft); -- Ouch. Don't do that!
					end
					SelfDamage(p, 1e+20);
				end

				-- Did they just hop out, leaving that craft w/o a pilot? Nuke that craft too.
				local lastp = Mission.m_LastPlayerCraftHandle[i];
				if(IsAround(lastp))
				then
					lastp = Mission.m_LastPlayerCraftHandle[i];
					if(not IsAliveAndPilot(lastp))
					then
						if(Mission.m_ShipOnlyMode)
						then
							SelfDamage(Mission.m_LastPlayerCraftHandle[i], 1e+20);
						else
							-- Not ship-only mode. Add this to empties list
							if(Mission.m_NumVehiclesTracked < MAX_VEHICLES_TRACKED) then
								Mission.m_EmptyVehicles[Mission.m_NumVehiclesTracked] = Mission.m_LastPlayerCraftHandle[i];
								Mission.m_NumVehiclesTracked = Mission.m_NumVehiclesTracked + 1;
							end
						end
						Mission.m_LastPlayerCraftHandle[i] = nil; -- 'forget' about this.
					end -- last craft is now an empty
				end -- lastp is still around
			else -- p is currently a pilot.
				-- Must be in a craft. Store it.
				Mission.m_LastPlayerCraftHandle[i] = p;
			end
		end -- p valid (i.e. human is playing on that team)
	end -- i loop over MAX_TEAMS
end -- ExecuteTrackPlayers


-- Called via execute, m_GameTPS of a second has elapsed. Update everything.
function UpdateGameTime()

	Mission.m_ElapsedGameTime = Mission.m_ElapsedGameTime + 1;

	-- Are we in a time limited game?
	if(Mission.m_RemainingGameTime > 0)
	then
		Mission.m_RemainingGameTime = Mission.m_RemainingGameTime - 1;
		if((Mission.m_RemainingGameTime % m_GameTPS) == 0)
		then
			-- Convert tenth-of-second ticks to hour/minutes/seconds format.
			local Seconds = Mission.m_RemainingGameTime / m_GameTPS;
			local Minutes = Seconds / 60;
			local Hours = Minutes / 60;
			-- Lop seconds and minutes down to 0..59 once we've grabbed
			-- non-remainder out.
			Seconds = Seconds % 60;
			Minutes = Minutes % 60;

			if(Hours ~= 0) then
				TempMsgString = TranslateString("mission", ("Time Left %d:%02d:%02d\n"):format(Hours, Minutes, Seconds));
			else
				TempMsgString = TranslateString("mission", ("Time Left %d:%02d\n"):format(Minutes, Seconds));
			end
			SetTimerBox(TempMsgString);

			-- Also prlocal this out more visibly at important times....
			if(Hours == 0)
			then
				-- Every 5 minutes down to 10 minutes, then every minute
				-- thereafter.
				if((Seconds == 0) and ((Minutes <= 10) or ((Minutes % 5) == 0))) then
					AddToMessagesBox(TempMsgString);
				else
					-- Every 5 seconds when under a minute is remaining.
					if((Minutes == 0) and ((Seconds % 5) == 0)) then
						AddToMessagesBox(TempMsgString);
					end
				end
			end
		end

		-- Game over due to timeout?
		if(Mission.m_RemainingGameTime == 0)
		then
			NoteGameoverByTimelimit();
			DoGameover(10.0);
		end
	else
		-- Infinite time game. Periodically update ingame clock.
		if((Mission.m_ElapsedGameTime % m_GameTPS) == 0)
		then
			-- Convert tenth-of-second ticks to hour/minutes/seconds format.
			local Seconds = Mission.m_ElapsedGameTime / m_GameTPS;
			local Minutes = Seconds / 60;
			local Hours = Minutes / 60;
			-- Lop seconds and minutes down to 0..59 once we've grabbed
			-- non-remainder out.
			Seconds = Seconds % 60;
			Minutes = Minutes % 60;

			if(Hours ~= 0) then
				TempMsgString = TranslateString("mission", ("Mission Time %d:%02d:%02d"):format(Hours, Minutes, Seconds));
			else
				TempMsgString = TranslateString("mission", ("Mission Time %d:%02d"):format(Minutes, Seconds));
			end
			SetTimerBox(TempMsgString);
		end
	end
end

function UpdateAIUnits()


	-- Need to spawn in a new craft at the start of the game
	-- (staggered every second)

	local InitialSpawnInFrequency = 5; -- 10 ticks per second

	if((Mission.m_ElapsedGameTime % InitialSpawnInFrequency) == 0)
	then

		if(Mission.m_NumAIUnits < Mission.m_MaxAIUnits)
		then
			BuildBotCraft(Mission.m_NumAIUnits);
			Mission.m_NumAIUnits = Mission.m_NumAIUnits + 1;
		else
			for i = 0, Mission.m_NumAIUnits-1
			do
				-- Fix for mantis #400 - if a bot craft is sniped,
				-- 'forget' about it and build another in its slot.
				if(not IsNotDeadAndPilot(Mission.m_AICraftHandles[i]))
				then
					SetLifespan(Mission.m_AICraftHandles[i], SNIPED_AI_LIFESPAN);
					Mission.m_AICraftHandles[i] = nil;
				end

				if(Mission.m_AICraftHandles[i] == nil) 
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
--	local GameTime = ((float)Mission.m_ElapsedGameTime) / m_GameTPS;

	for i = 0, Mission.m_NumAIUnits-1
	do
		if(bit32.band((Mission.m_ElapsedGameTime + i), 0x1F) == 0)
		then

			if(Mission.m_AILastWentForPowerup[i])
			then
				local Target = Mission.m_AITargetHandles[i];
				Mission.m_PowerupGotoTime[i] = Mission.m_PowerupGotoTime[i] + 1;
				-- Max of 15 seconds to pick up a powerup, then we go again
				if((not IsAlive(Target)) or (Mission.m_PowerupGotoTime[i] > 150) or 
					(GetDistance(Mission.m_AICraftHandles[i], Mission.m_AITargetHandles[i]) < 2.0))
				then
					-- Need to retarget.
					FindGoodAITarget(i);
				end
			else 
				-- Code disabled NM 7/28/07 - this is not multiworld friendly.
				-- Units will pop nastily if they constantly get orders like this
				-- in the lockstep world, but they're not propagated into the
				-- visual worlds.
--[[
				-- combat mode, not going for powerups.

				local Retarget = false;
				local TargetIsAlive = IsAlive(Mission.m_AITargetHandles[i]);
				local WhoLastShotMe = GetWhoShotMe(Mission.m_AICraftHandles[i]);

				-- AI check: if we're getting shot by someone, and our primary
				-- target is not getting hit by us (or they don't exist), nail
				-- them instead.
				if((WhoLastShotMe ~= nil) and ((not TargetIsAlive) ||
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
				if(Retarget) then
					FindGoodAITarget(i);
				else
					Attack(Mission.m_AICraftHandles[i], Mission.m_AITargetHandles[i]);
				end
--]]
			end -- combat mode
		end -- Time to recalculate this.
	end -- loop over AI units
end -- UpdateAIUnits();

function UpdateAnimals()

	-- Have to manually check on animals; they won't trigger a call to
	-- DeadObject(). If any died, note that.
	for i = 0, Mission.m_NumAnimals-1
	do
		if(Mission.m_AnimalHandles[i] ~= nil)
		then
			local h = Mission.m_AnimalHandles[i];
			if(not IsAlive(h)) then
				Mission.m_AnimalHandles[i] = nil;
			end
		end
	end -- loop over all objects

	-- Spawn in animals at the start of the game (staggered every 4
	-- seconds)
	local InitialSpawnInFrequency = 4 * m_GameTPS; -- m_GameTPS ticks per second

	if((Mission.m_ElapsedGameTime % InitialSpawnInFrequency) == 0)
	then
		if(Mission.m_NumAnimals < Mission.m_MaxAnimals)
		then
			SetupAnimal(Mission.m_NumAnimals);
			Mission.m_NumAnimals = Mission.m_NumAnimals + 1;
		else
			-- 'Full' set of animals. Do respawns as needed.
			for i = 0, Mission.m_NumAnimals-1
			do
				if(Mission.m_AnimalHandles[i] == nil)
				then
					SetupAnimal(i);
					break;
				end
			end
		end
	end -- periodic check

end -- UpdateAnimals()

function Update()

	-- Always see if any empties are filled or need to be killed
	UpdateEmptyVehicles();

	if(DMIsRaceSubtype[Mission.m_MissionType]) then
		ExecuteRace();
	end

	if((Mission.m_RabbitMode) and (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2)) then -- Only in Normal DM. -GBD
		ExecuteRabbit();
	end

	if(Mission.m_WeenieMode) then
		ExecuteWeenie();
	end

	-- CTF - periodically re-objectify the opponent's flag
	if(Mission.m_MissionType == DMSubtype_CTF)
	then
		if(not (Mission.m_ElapsedGameTime % m_GameTPS))
		then
			ObjectifyFlag();
		end
	end

	ExecuteTrackPlayers();

	-- Do this as well...
	UpdateGameTime();

	if(Mission.m_MaxAIUnits > 0) then
		UpdateAIUnits();
	end

	if(Mission.m_MaxAnimals > 0) then
		UpdateAnimals();
	end

	-- Keep powerups going, etc
	--PUPMgr::Execute(); -- WRITE ME! -GBD

	-- Check to see if someone was flagged as flying, and if they've
	-- landed, build a new craft for them
	for i = 1, MAX_TEAMS-1
	do
		if(Mission.m_Flying[i])
		then
			local PlayerH = GetPlayerHandle(i);
			if((PlayerH ~= nil) and (not IsFlying(PlayerH)))
			then
				Mission.m_Flying[i] = false; -- clear flag so we don't check until they're dead
				if(PlayerH ~= nil)
				then
					local ODF = GetNextVehicleODF(i, true);
					local h = BuildEmptyCraftNear(PlayerH, ODF, i, RespawnMinRadiusAway, RespawnMaxRadiusAway);
					if(h ~= nil)
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
		local Teamscore = { };
		local TeamplayHandles = { };
		
		for i = 1, MAX_TEAMS-1
		do
			local playerH = GetPlayerHandle(i);
			if (playerH ~= nil)
			then
				
				if (Teamplay)
				then
					local whichteamgroupami = WhichTeamGroup(i);
					if ((WhichTeamGroup >= 0) and (whichteamgroupami < MAX_MULTIPLAYER_TEAMS))
					then
						Teamscore[whichteamgroupami] = Teamscore[whichteamgroupami] + GetScore(playerH);

						if (TeamplayHandles[whichteamgroupami] == nil) then
							TeamplayHandles[whichteamgroupami] = playerH;
						end
					end
				else
					if (GetScore(playerH) >= Mission.m_ScoreLimit)
					then
						NoteGameoverByScore(playerH);
						DoGameover(5.0);
						Mission.m_bDidGameOverByScore = true;
						break;
					end
				end
			end
		end
		if (Teamplay)
		then
			for i = 1, MAX_MULTIPLAYER_TEAMS-1
			do
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
end

function AddPlayer(id, Team, IsNewPlayer)

	-- Server does all building; client doesn't need to do anything
	if (IsNewPlayer)
	then
		local PlayerH = SetupPlayer(Team);
		SetAsUser(PlayerH, Team);
		AddPilotByHandle(PlayerH);
		SetNoScrapFlagByHandle(PlayerH);
	end

	return 1; -- BOGUS: always assume successful
end

-- Rebuilds pilot
function RespawnPilot(DeadObjectHandle, Team)

	local Where; -- Where they
	local RespawnInVehicle = (GetRespawnInVehicle()) or (Mission.m_RabbitMode and (DeadObjectHandle == Mission.m_RabbitTargetHandle));

	if(Mission.m_RabbitMode and (DeadObjectHandle == Mission.m_RabbitTargetHandle))
	then
		Mission.m_ForbidRabbitTeam = Mission.m_RabbitTeam;
		Mission.m_RabbitTargetHandle = nil;
	end

	if(DMIsRaceSubtype[Mission.m_MissionType]) 
	then
		-- Race-- spawn back at last spawnpolocal they were at.
		local LastSpawnAt = Mission.m_NextRaceCheckpoint[Team] - 1;
		if(LastSpawnAt > 0)
		then
			TempODFName = "checkpoint" .. LastSpawnAt;
			GetPosition(GetHandle(TempODFName), Where);
		else
			Where = GetSpawnpoint(0);
		end
	elseif((not IsTeamplayOn()) or (Team < 1))
	then
		Where = GetRandomSpawnpoint();
		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	else
		-- Place them back where originally created
		Where = Mission.m_TeamPos;
		-- And randomize around the spawnpolocal slightly so we'll
		-- hopefully never spawn in two pilots in the same place
		Where = GetPositionNear(Where, AllyMinRadiusAway, AllyMaxRadiusAway);
	end

	if((Team > 0) and (Team < MAX_TEAMS)) then
		Mission.m_SpawnedAtTime[Team] = Mission.m_ElapsedGameTime; -- Note when they spawned in.
	end

	-- Randomize starting position somewhat
	Where = GetPositionNear(Where, RespawnMinRadiusAway, RespawnMaxRadiusAway);

	if((not RespawnInVehicle) and (not Mission.m_RespawnAtLowAltitude)) then
		Where.y = Where.y + RespawnPilotHeight; -- Bounce them in the air to prevent multi-kills
	end

	local NewPerson = nil;
	if(RespawnInVehicle) then
		NewPerson = BuildObject(GetNextVehicleODF(Team, true), Team, Where);
	else
		local Race = GetRaceOfTeam(Team);
		NewPerson = BuildObject(GetInitialPlayerPilotODF(Race), Team, Where);
	end

	SetAsUser(NewPerson, Team);
	SetNoScrapFlagByHandle(NewPerson);

	AddPilotByHandle(NewPerson);
	SetRandomHeadingAngle(NewPerson);
	if(not RespawnInVehicle) then
		Mission.m_Flying[Team] = true; -- build a craft when they land.
	end

	-- If on team 0 (dedicated server team), make this object gone from the world
	if(Team == 0) then
		MakeInert(NewPerson);
	end

	return DLLHandled; -- Dead pilots get handled by DLL
end

function DeadObject(DeadObjectHandle, KillersHandle, WasDeadPerson, WasDeadAI)

	-- Rabbit mode, for non-rabbit players, special scoring. Normal
	-- scoring for the rabbit below, as in other modes.
	local KilledRabbit = false;
	local UseRabbitScoring = false;
	local Wasm_RabbitShooterHandle = (DeadObjectHandle == Mission.m_RabbitShooterHandle);
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
			local RabbitH = KillersHandle;
			if(IsAlive(RabbitH)) then
				SetNewRabbit(RabbitH); -- Update for everyone
				
				print("DeadObject: Set Rabbit to RabbitH, Rabbit Was Killer.");
			else
				RabbitH = Mission.m_RabbitShooterHandle;
				if(IsAlive(RabbitH)) then
					SetNewRabbit(RabbitH); -- Update for everyone
					
					print("DeadObject: Set Rabbit to RabbitH, Rabbit Was Shooter.");
				end
			end
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
		TempMsgString = TranslateString("mission", ("%s killed the wrong target, %s\n"):format(
			GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle)));
		AddToMessagesBox(TempMsgString);
	elseif((UseRabbitScoring) and (KilledRabbit))
	then
		SpawnKillMultiplier = -1; -- Force the score downnot 
		TempMsgString = TranslateString("mission", ("Rabbit kill by %s on %s\n"):format(
			GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle)));
		AddToMessagesBox(TempMsgString);
	elseif(IsSpawnKill)
	then
		SpawnKillMultiplier = -1;
		TempMsgString = TranslateString("mission", ("Spawn kill by %s on %s\n"):format(
			GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle)));
		AddToMessagesBox(TempMsgString);
	end

	-- Jira 2445: Don't count kills/deaths/score for Team 0 (props). -GBD
	if (DeadTeam ~= 0)
	then
		if ((DeadObjectHandle ~= KillersHandle) and (not IsAlly(DeadObjectHandle, KillersHandle)))
		then
			-- Killed enemy...
			if ((not WasDeadAI) or (KillForAIKill)) then
				AddKills(KillersHandle, 1 * SpawnKillMultiplier); -- Give them a kill
			end

			if (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
			then
				if ((not WasDeadAI) or (PointsForAIKill))
				then
					if (WasDeadPerson) then
						AddScore(KillersHandle, ScoreForKillingPerson*SpawnKillMultiplier);
					else
						AddScore(KillersHandle, ScoreForKillingCraft*SpawnKillMultiplier);
					end
				end
			end
		else
			if ((not WasDeadAI) or (KillForAIKill)) then
				AddKills(KillersHandle, -1 * SpawnKillMultiplier); -- Suicide or teamkill counts as -1 kill
			end

			if ((UseRabbitScoring) and (not KilledRabbit)) then
				SpawnKillMultiplier = 0; -- no deaths count here...
			end

			if (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
			then
				if ((not WasDeadAI) or (PointsForAIKill))
				then
					if (WasDeadPerson) then
						AddScore(KillersHandle, -ScoreForKillingPerson * SpawnKillMultiplier);
					else
						AddScore(KillersHandle, -ScoreForKillingCraft * SpawnKillMultiplier);
					end
				end
			end
		end

		if (not WasDeadAI)
		then
			if ((UseRabbitScoring) and (not KilledRabbit)) then
				SpawnKillMultiplier = 0; -- no deaths count here...
			end

			-- Give points to killee-- this always increases
			AddDeaths(DeadObjectHandle, 1 * SpawnKillMultiplier);

			if (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2) -- Only in Normal DM. -GBD
			then
				if (WasDeadPerson) then
					AddScore(DeadObjectHandle, ScoreForDyingAsPerson*SpawnKillMultiplier);
				else
					AddScore(DeadObjectHandle, ScoreForDyingAsCraft*SpawnKillMultiplier);
				end
			end

			-- Neener neenernot 
			if ((KillerIsAI) and (Mission.m_NumAIUnits > 0)) then
				DoTaunt(TAUNTS_HumanShipDestroyed);
			end
		end

		-- Check to see if we have a Mission.m_KillLimit winner
		if ((Mission.m_KillLimit > 0) and (GetKills(KillersHandle) >= Mission.m_KillLimit))
		then
			NoteGameoverByKillLimit(KillersHandle);
			DoGameover(10.0);
		end
	-- Get team number of who got waxed.
	else
		return DoEjectPilot; -- Someone on neutral team always gets default behavior
	end

	if(WasDeadAI)
	then
		local bFoundAI = false;

		for i = 0, Mission.m_NumAIUnits-1
		do
			if(DeadObjectHandle == Mission.m_AICraftHandles[i])
			then
				Mission.m_AICraftHandles[i] = nil;
				BuildBotCraft(i); -- Respawn them asap.
				bFoundAI = true;
				if(Wasm_RabbitShooterHandle)
				then
					Mission.m_RabbitShooterHandle = Mission.m_AICraftHandles[i];
				end
				break; -- out of i loop
			end
		end

		for i = 0, Mission.m_NumAnimals-1
		do
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
		else
			return DLLHandled;
			--			return DoEjectPilot;
		end
	else 
		-- Not DeadAI, i.e. a humannot 

		-- For a player-piloted craft, always respawn a new craft;
		-- respawn pilot if needed as well.
		if((WasDeadPerson) or (Mission.m_RabbitMode and KilledRabbit))
		then
			return RespawnPilot(DeadObjectHandle, DeadTeam);
		else
			-- Don't build anything for them until they land.
			Mission.m_Flying[DeadTeam] = true;
			return DoEjectPilot;
		end
	end
end

function PlayerEjected(DeadObjectHandle)

	local WasDeadAI = not IsPlayer(DeadObjectHandle);

	local DeadTeam = GetTeamNum(DeadObjectHandle);
	if(DeadTeam == 0) then
		return DLLHandled; -- Invalid team. Do nothing
	end

	-- Update Deaths, Kills, Score for this player
	AddDeaths(DeadObjectHandle, 1);
	AddKills(DeadObjectHandle, -1);

	if (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2) then -- Only in Normal DM. -GBD
		AddScore(DeadObjectHandle, ScoreForDyingAsCraft-ScoreForKillingCraft);
	end

	if(GetCanEject(DeadObjectHandle)) 
	then
		-- Flags saying if they can eject or not
		Mission.m_Flying[DeadTeam] = true; -- They're flying; create craft when they land
		return DoEjectPilot; 
	else
		-- Can't eject, so put back at base by forcing a insta-kill as pilot
		return DeadObject(DeadObjectHandle, DeadObjectHandle, true, WasDeadAI);
	end
end

function ObjectKilled(DeadObjectHandle, KillersHandle)

	local WasDeadAI = not IsPlayer(DeadObjectHandle);

	-- We don't care about dead craft, only dead pilots, and also only
	-- care about things in the lockstep world
	if(GetCurWorld() ~= 0)
	then
		return DoEjectPilot;
	end

	local WasDeadPerson = IsPerson(DeadObjectHandle);
	if(GetRespawnInVehicle()) then -- CTF-- force a "kill" back to base
		WasDeadPerson = true;
	end

	return DeadObject(DeadObjectHandle, KillersHandle, WasDeadPerson, WasDeadAI);
end

function ObjectSniped(DeadObjectHandle, KillersHandle)

	local WasDeadAI = not IsPlayer(DeadObjectHandle);

	-- We don't care about dead craft, only dead pilots, and also only
	-- care about things in the lockstep world
	if(GetCurWorld() ~= 0)
	then
		return DoRespawnSafest;
	end

	-- Dead person means we must always respawn a new person
	return DeadObject(DeadObjectHandle, KillersHandle, true, WasDeadAI);
end

function CreateObjectives()

	-- Do this for everyone as well.
	ClearObjectives();
	
	if (Mission.m_MissionType == DMSubtype_Normal or Mission.m_MissionType == DMSubtype_Normal2) then 
		AddObjective("mpobjective_dm.otf", "WHITE", -1.0); -- negative time means don't change display to show it
	elseif (Mission.m_MissionType == DMSubtype_CTF) then
		AddObjective("mpobjective_dmctf.otf", "WHITE", -1.0); -- negative time means don't change display to show it
	elseif (Mission.m_MissionType == DMSubtype_KOH) then
		AddObjective("mpobjective_dmkoth.otf", "WHITE", -1.0); -- negative time means don't change display to show it
	elseif (Mission.m_MissionType == DMSubtype_Loot) then
		AddObjective("mpobjective_dmloot.otf", "WHITE", -1.0); -- negative time means don't change display to show it
	elseif (Mission.m_MissionType == DMSubtype_Race1 or Mission.m_MissionType ==DMSubtype_Race2) then
		AddObjective("mpobjective_dmrace.otf", "WHITE", -1.0); -- negative time means don't change display to show it
	else
		AddObjective("mpobjective_dm.otf", "WHITE", -1.0); -- negative time means don't change display to show it
	end
end


function Save()
    return 
		_FECore.Save(), 
		Mission;
end

function Load(FECoreData, MissionData)	

	m_GameTPS = EnableHighTPS();
	SetAutoGroupUnits(false);

		-- Always do this to hook up clients with the taunt engine as well.
	SetTauntCPUTeamName("Bots");

	-- We're a 1.3 DLL.
	WantBotKillMessages();

	-- Make sure we always call this
	_FECore.Load(FECoreData);
	Mission = MissionData;

	CreateObjectives();
	SetGravity(Mission.m_Gravity * 0.5);
	
	-- Originally done in PostLoad, may not work? -GBD
	if(Mission.m_RabbitMode)
	then
		-- Clear, 
		local OrigRabbit = Mission.m_RabbitTargetHandle;
		SetNewRabbit(nil); -- Clear.
		print("LOAD Clearing Rabbit");
		SetNewRabbit(OrigRabbit); -- re-aim everyone
		print("LOAD Rabbit reset to saved handle.");
	end	
end


-- Passed the current world, shooters handle, victim handle, and
-- the ODF string of the ordnance involved in the snipe. Returns a
-- code detailing what to do.
--
-- not not  Note : If DLLs want to do any actions to the world based on this
-- PreSnipe callback, they should (1) Ensure curWorld == 0 (lockstep)
-- -- do NOTHING if curWorld is ~= 0, and (2) probably queue up an
-- action to do in the next Execute() call.
function PreSnipe(curWorld, shooterHandle, victimHandle, ordnanceTeam, pOrdnanceODF)

	-- If Friendly Fire is off, then see if we should disallow the snipe
	if(not Mission.m_bIsFriendlyFireOn)
	then
		local relationship = GetTeamRelationship(shooterHandle, victimHandle);
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

