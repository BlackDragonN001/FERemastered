--[[ BZCC Strategy Mission Script 
Written by General BlackDragon
Version 1.0 11-20-2018 --]]

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _SaveLoad = require("_SaveLoad");
local _FECore = require('_FECore');
local _StartingVehicles = require('_StartingVehicles');
local _MPI = require('_MPI');

-- Static Variables:
local ScoreDecrementForSpawnKill = 500;
local ScoreForWinning = 100;

local VEHICLE_SPACING_DISTANCE = 20.0

-- How long a "spawn" kill lasts, in tenth of second ticks. If the
-- time since they were spawned to current is less than this, it's a
-- spawn kill, and not counted. Todo - Make this an ivar for dm?
local MaxSpawnKillTime = 15;

-- Max distance (in x,z dimensions) on a pilot respawn. Actual value
-- used will vary with random numbers, and will be +/- this value
local RespawnDistanceAwayXZRange = 32.0;
-- Max distance (in y dimensions) on a pilot respawn. Actual value
-- used will vary with random numbers, and will be [0..this value)
local RespawnDistanceAwayYRange = 8.0;

local RespawnPilotHeight = 200.0;

-- How far allies will be from the commander's position
local AllyMinRadiusAway = 30.0;
local AllyMaxRadiusAway = 60.0;

-- How long (in seconds) from noticing gameover, to the actual kicking
-- out back to the shell.
local endDelta = 10.0;

-- Friendly spawnpoint: Max distance away for ally
local FRIENDLY_SPAWNPOINT_MAX_ALLY = 100.0;
-- Friendly spawnpoint: Min distance away for enemy
local FRIENDLY_SPAWNPOINT_MIN_ENEMY = 400.0;

-- Random spawnpoint: min distance away for enemy
local RANDOM_SPAWNPOINT_MIN_ENEMY = 450.0;

local m_GameTPS = 20;

local Mission = 
{ 
--locals
	m_TotalGameTime = 0,
	m_RemainingGameTime = 0,
	m_ElapsedGameTime = 0,
	m_KillLimit = 0, -- As specified from the shell
	m_PointsForAIKill = 0, -- ivar14
	m_KillForAIKill = 0, -- ivar15
	m_RespawnWithSniper = 0, -- ivar16
	m_TurretAISkill = 0, -- ivar17
	m_NonTurretAISkill = 0, -- ivar18
	m_StartingVehiclesMask = 0, -- ivar7
	m_SpawnedAtTime = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	m_RecyInvulnerabilityTime = 0, -- ivar25, if >0, this is currently active
	m_AllyTeams = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, -- New alliance var setting. Yay! -GBD
	m_IsMPI = 0, -- ivar12
		
--locals
	m_DidInit = false,
	m_HadMultipleFunctioningTeams = false,
	m_TeamIsSetUp = { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
	m_NotedRecyclerLocation = { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false }, -- of deployed recycler
	m_GameOver = false,
	m_CreatingStartingVehicles = false,
	m_RespawnAtLowAltitude = false,
	m_bIsFriendlyFireOn = false,
	m_HasAllies = { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false },
-- Vector For Spawn positions.
	m_TeamPos = { },
-- Handles
	m_RecyclerHandles = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
	-- 
	m_TESTBOOL
}

function InitialSetup()

	_FECore.InitialSetup();
	m_GameTPS = EnableHighTPS();
	SetAutoGroupUnits(false);
	
	WantBotKillMessages();
	
	-- Do this for everyone as well.
	CreateObjectives();
	
	Mission.m_IsMPI = (GetVarItemInt("network.session.ivar12") ~= 0);
	if (Mission.m_IsMPI) then
		_MPI.InitialSetup();
	end

end

function Save()
    return _FECore.Save(), _StartingVehicles.Save(), _SaveLoad.Save(), Mission;
end

function Load(FECoreData, StartingVehicleData, ModuleData, MissionData)

	m_GameTPS = EnableHighTPS();
	SetAutoGroupUnits(false);

	-- We're a 1.3 DLL.
	WantBotKillMessages();
	
	-- Load sub moduels.
	_FECore.Load(FECoreData);
	_StartingVehicles.Load(StartingVehicleData);
	
	if ModuleData then
		_SaveLoad.Load(ModuleData)
	else
		print("WARNING: No ModuleData provided to _SaveLoad.Load()")
	end
	
	-- Load mission data.
	if MissionData then
		for k,v in pairs(MissionData) do
			Mission[k] = v
		end
	else
		print("WARNING: No MissionData provided")
	end
	
	-- Do this for everyone as well.
	CreateObjectives();
end

function CreateObjectives()

	-- Do this for everyone as well.
	ClearObjectives();
	AddObjective("mpobjective_st.otf", "WHITE", -1.0); -- negative time means don't change display to show it

end

function AddObject(h)

	_FECore.AddObject(h);

	local ODFName = GetCfg(h);
	local ObjClass = GetClassLabel(h);

	-- See if this is a turret, 
	if (ObjClass == "CLASS_TURRETTANK")
	then
		SetSkill(h, Mission.m_TurretAISkill);
		if (not Mission.m_IsMPI) then
			return;
		end
	else
		-- Not a turret. Use regular skill level
		SetSkill(h, Mission.m_NonTurretAISkill);
	end

	-- Also see if this is a new recycler vehicle (e.g. user upgraded recycler building to vehicle)
	if (ObjClass == "CLASS_RECYCLERVEHICLE") or (ObjClass == "CLASS_RECYCLERVEHICLEH")
	then
		local Team = GetTeamNum(h);
		-- If we're not tracking a recycler vehicle for this team right now, store it.
		if(Mission.m_RecyclerHandles[Team] == nil) then
			Mission.m_RecyclerHandles[Team] = h;
		end
		
		if (not Mission.m_IsMPI) then
			return;
		end
	end
	
	if (ObjClass == "CLASS_BOMBERBAY") and not IsTeamAllied(GetTeamNum(h), GetLocalPlayerTeamNumber()) then
		AddToMessagesBox2(GetBZCCLocalizedString("mission", "Intel report: Bomber Bay!"));
	end
	
	-- Add MPI Support - AI_Unit
	if (Mission.m_IsMPI) then
		_MPI.AddObject(h, Mission.m_CreatingStartingVehicles, Mission.m_ElapsedGameTime, ODFName, ObjClass);
	end

end

function DeleteObject(h)

	if (Mission.m_IsMPI) then
		_MPI.DeleteObject(h);
	end
end

function Start()

	_StartingVehicles.Start();
	_FECore.Start();

	-- Read from the map's .trn file whether we respawn at altitude or
	-- not.	
	local mapTrnFile = GetMapTRNFilename();
	Mission.m_RespawnAtLowAltitude = GetODFBool(mapTrnFile, "DLL", "RespawnAtLowAltitude", false);

	-- Set up some variables based on how things appear in the world
	Mission.m_DidInit = true;
	Mission.m_KillLimit = GetVarItemInt("network.session.ivar0");
	Mission.m_TotalGameTime = GetVarItemInt("network.session.ivar1");
	-- Skip ivar2-- player limit. Assume the netmgr takes care of that.
	-- ivar4 (vehicle prefs 1) read elsewhere.
	Mission.m_StartingVehiclesMask = GetVarItemInt("network.session.ivar7");
	
	Mission.m_IsMPI = (GetVarItemInt("network.session.ivar12") ~= 0);

	Mission.m_bIsFriendlyFireOn = (GetVarItemInt("network.session.ivar32") ~= 0);

	-- Override the bitfields set in the shell, so that you start with 2 turrets, or nothing.
	if((not Mission.m_IsMPI) and (Mission.m_StartingVehiclesMask ~= 0)) then
		Mission.m_StartingVehiclesMask = 3;
	end

	Mission.m_PointsForAIKill = (GetVarItemInt("network.session.ivar14") ~= 0);
	Mission.m_KillForAIKill = (GetVarItemInt("network.session.ivar15") ~= 0);
	Mission.m_RespawnWithSniper = (GetVarItemInt("network.session.ivar16") ~= 0);

	Mission.m_TurretAISkill = GetVarItemInt("network.session.ivar17");
	if(Mission.m_TurretAISkill < 0) then
		Mission.m_TurretAISkill = 0;
	elseif(Mission.m_TurretAISkill > 3) then
		Mission.m_TurretAISkill = 3;
	end
	
	Mission.m_NonTurretAISkill = GetVarItemInt("network.session.ivar18");
	if(Mission.m_NonTurretAISkill < 0) then
		Mission.m_NonTurretAISkill = 0;
	elseif(Mission.m_NonTurretAISkill>3) then
		Mission.m_NonTurretAISkill = 3;
	end
	
	-- Redone ally code. -GBD
	-- Note: currently ivar23 must be >0 for allies to send units to eachother. -GBD
	if(not IsTeamplayOn())
	then
		-- Grab the "Team" numbers. 
		for i = 1, MAX_TEAMS-1 do
			Mission.m_AllyTeams[i] = GetVarItemInt("network.session.ivar" .. tostring(34+i));
		end
		--[[
		Mission.m_AllyTeams[1] = GetVarItemInt("network.session.ivar35");
		Mission.m_AllyTeams[2] = GetVarItemInt("network.session.ivar36");
		Mission.m_AllyTeams[3] = GetVarItemInt("network.session.ivar37");
		Mission.m_AllyTeams[4] = GetVarItemInt("network.session.ivar38");
		Mission.m_AllyTeams[5] = GetVarItemInt("network.session.ivar39");
		Mission.m_AllyTeams[6] = GetVarItemInt("network.session.ivar40");
		Mission.m_AllyTeams[7] = GetVarItemInt("network.session.ivar41");
		Mission.m_AllyTeams[8] = GetVarItemInt("network.session.ivar42");
		Mission.m_AllyTeams[9] = GetVarItemInt("network.session.ivar43");
		Mission.m_AllyTeams[10] = GetVarItemInt("network.session.ivar44");
		Mission.m_AllyTeams[11] = GetVarItemInt("network.session.ivar45");
		Mission.m_AllyTeams[12] = GetVarItemInt("network.session.ivar46");
		Mission.m_AllyTeams[13] = GetVarItemInt("network.session.ivar47");
		Mission.m_AllyTeams[14] = GetVarItemInt("network.session.ivar48");
		Mission.m_AllyTeams[15] = GetVarItemInt("network.session.ivar49");
		--]]

		-- Loop over all teams, and ally them if they're set to be allies. 
		for x = 1, MAX_TEAMS-1
		do
			for y = 1, MAX_TEAMS-1
			do
				if((Mission.m_AllyTeams[x] > 0) and (x ~= y) and (Mission.m_AllyTeams[x] == Mission.m_AllyTeams[y]))
				then
					Ally(x, y);
					Mission.m_HasAllies[x] = true;
				end
			end
		end	-- Finshed looping.
	else -- Teamplay, gotta fill it with something.
		for i = 1, MAX_TEAMS-1 do
			Mission.m_AllyTeams[i] = GetVarItemInt("network.session.ivar" .. tostring(34+i));
		end
	end

	Mission.m_RecyInvulnerabilityTime = GetVarItemInt("network.session.ivar25");
	Mission.m_RecyInvulnerabilityTime = Mission.m_RecyInvulnerabilityTime * (60 * m_GameTPS); -- convert from minutes to ticks (10 ticks per second)

	-- The BZN has a player in the world. We need to delete them, as
	-- this code (either on this machine or remote machines) handles
	-- creation of the proper vehicles in the right places for
	-- everyone.
	local PlayerEntryH = GetPlayerHandle();
	if(PlayerEntryH ~= nil) then
		RemoveObject(PlayerEntryH);
	end

	-- Do all the one-time server side init of varbs. These varbs are
	-- saved out and read in on clientside, if saved in the proper
	-- place above. This needs to be done after toasting the initial
	-- vehicle
	if((ImServer()) or (not IsNetworkOn()))
	then
		Mission.m_ElapsedGameTime = 0;
		if(Mission.m_RemainingGameTime == 0) then
			Mission.m_RemainingGameTime = Mission.m_TotalGameTime * 60 * m_GameTPS; -- convert minutes to TPS seconds
		end
	end

	-- And build the local player for the server
	local LocalTeamNum = GetLocalPlayerTeamNumber(); -- Query this from game
	local PlayerH = SetupPlayer(LocalTeamNum);
	SetAsUser(PlayerH, LocalTeamNum);
	AddPilotByHandle(PlayerH);

	-- MPI mode.
	if (Mission.m_IsMPI) then
		_MPI.Start();
		
		Mission.m_CreatingStartingVehicles = true;
		
		for i = CPU_START_TEAM, MAX_TEAMS-1 do
			Mission.m_RecyclerHandles[i] = _MPI.SetupAITeam(i);
			if (Mission.m_RecyclerHandles[i]) ~= nil then
				Mission.m_TeamIsSetUp[i] = true;
			end
		end
		
		Mission.m_CreatingStartingVehicles = false;
	end
end

function Update()

	_FECore.Update();

	-- If Recycler invulnerability is on, then does the job of it.
	ExecuteRecyInvulnerability();

	-- Check for absence of recycler & factory, gameover if so.
	ExecuteCheckIfGameOver();

	-- Do this as well...
	UpdateGameTime();
	
	local H = GetUserTarget();
	if not Mission.m_TESTBOOL and H ~= nil then
		--SetTauntCPUTeamName("Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies Baddies ");
		--DoTaunt(6);
		--BuildExplosion("xstabcar_c", H);
		SetEjectRatio(H, 0.7);
		Mission.m_TESTBOOL = true;
	elseif H == nil then
		Mission.m_TESTBOOL = false;
	end
	
	-- MPI mode
	if (Mission.m_IsMPI) then
		_MPI.Update(Mission.m_ElapsedGameTime);
	end

end

function AddPlayer(id, Team, IsNewPlayer)

	if(IsNewPlayer)
	then
		local PlayerH = SetupPlayer(Team);
		SetAsUser(PlayerH, Team);
		AddPilotByHandle(PlayerH);
	end

	return true;
end

function PlayerEjected(DeadObjectHandle)

	local deadObjectTeam = GetTeamNum(DeadObjectHandle);
	if(deadObjectTeam == 0) then
		return EJECTKILLRETCODES_DLLHANDLED; -- Invalid team. Do nothing
	end
	
	local isDeadAI = not IsPlayer(DeadObjectHandle);

	return _FECore.PlayerEjected(DeadObjectHandle) or DeadObject(DeadObjectHandle, DeadObjectHandle, false, isDeadAI); -- Tell main code to allow the ejection
	
end

function ObjectKilled(DeadObjectHandle, KillersHandle)

	local isDeadAI = not IsPlayer(DeadObjectHandle);
	local isDeadPerson = IsPerson(DeadObjectHandle);

	-- Sanity check for multiworld
	if(GetCurWorld() ~= 0) then
		return EJECTKILLRETCODES_DOEJECTPILOT;
	end

	local deadObjectTeam = GetTeamNum(DeadObjectHandle);
	if(deadObjectTeam == 0) then
		return EJECTKILLRETCODES_DOEJECTPILOT; -- Someone on neutral team always gets default behavior
	end

	-- If a person died, respawn them, etc
	return DeadObject(DeadObjectHandle, KillersHandle, isDeadPerson, isDeadAI);

end


function ObjectSniped(DeadObjectHandle, KillersHandle)

	local isDeadAI = not IsPlayer(DeadObjectHandle);

	if(GetCurWorld() ~= 0)
	then
		return EJECTKILLRETCODES_DLLHANDLED;
	end

	-- Dead person means we must always respawn a new person
	return DeadObject(DeadObjectHandle, KillersHandle, true, isDeadAI);
	
end

function PreSnipe(curWorld, shooterHandle, victimHandle, ordnanceTeam, pOrdnanceODF)

	-- If Friendly Fire is off, then see if we should disallow the snipe
	if(not Mission.m_bIsFriendlyFireOn)
	then
		local relationship = GetTeamRelationship(shooterHandle, victimHandle);
		if(--(relationship == TEAMRELATIONSHIP_SAMETEAM) or 
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

function PreGetIn(curWorld, pilotHandle, emptyCraftHandle)

	-- Is this an AI pilot getting localo an allied craft? If so, change
	-- the pilot's team to be the same as the craft, so that the craft
	-- remains with its owning team. If a local or remotely-controlled
	-- player tries to get in, behave as before.
	local relationship = GetTeamRelationship(pilotHandle, emptyCraftHandle);
	if((relationship == TEAMRELATIONSHIP_ALLIEDTEAM) and
	   ( not IsPlayer(pilotHandle)))
	then
		SetTeamNum(pilotHandle, GetTeamNum(emptyCraftHandle));
	end

	-- Always allow the entry
	return PREGETIN_ALLOW;
	
end

-- Given a race identifier, get the pilot back (used during a respawn)
function GetInitialPlayerPilotODF(Race);

	local TempODFName = nil;
	if(Mission.m_RespawnWithSniper) then
		TempODFName = Race .. "spilo"; -- With sniper.
	else
		TempODFName = Race .. "suser_m";  -- Note-- this is the sniper-less variant for a respawn
	end
	return TempODFName;
	
end

-- Given a race identifier, get the recycler ODF back
function GetInitialRecyclerODF(Race);

	local TempODFName = nil;
	local pContents = GetCheckedNetworkSvar(5, NETLIST_Recyclers);
	if((pContents ~= nil) and (pContents ~= ""))
	then
		TempODFName = Race .. string.sub(pContents, 2);
	else
		TempODFName = Race .. "vrecy_m";
	end
	return TempODFName;
end

-- Sets up the side's commander's extra vehicles, such a recycler or
-- more.  Does *not* create the player vehicle for them. [More notes
-- in .cpp file]
function SetupTeam(Team);

	if((Team < 1) or (Team >= MAX_TEAMS)) then
		return;
	end
	if(Mission.m_TeamIsSetUp[Team]) then
		return;
	end

	local TeamRace = GetRaceOfTeam(Team);
	if(IsTeamplayOn()) then
		SetMPTeamRace(WhichTeamGroup(Team), TeamRace); -- Lock this down to prevent changes.
	end

	local spawnpointPosition = GetSpawnpointForTeam(Team, FRIENDLY_SPAWNPOINT_MAX_ALLY, FRIENDLY_SPAWNPOINT_MIN_ENEMY, RANDOM_SPAWNPOINT_MIN_ENEMY);

	-- Store position we created them at for later
	Mission.m_TeamPos[Team] = spawnpointPosition;

	-- Build recycler some distance away, if it's not preplaced on the map.
	if(GetObjectByTeamSlot(Team, DLL_TEAM_SLOT_RECYCLER) == nil)
	then
		spawnpointPosition = GetPositionNear(spawnpointPosition, VEHICLE_SPACING_DISTANCE, 2 * VEHICLE_SPACING_DISTANCE);
		local VehicleH = BuildObject(GetInitialRecyclerODF(TeamRace), Team, spawnpointPosition);
		SetRandomHeadingAngle(VehicleH);
		Mission.m_RecyclerHandles[Team] = VehicleH;
		SetGroup(VehicleH, 0);
	end

	-- Build all optional vehicles for this team.
	spawnpointPosition = Mission.m_TeamPos[Team]; -- restore default after we modified this for recy above

	-- Drop skill level while we build things.
	Mission.m_CreatingStartingVehicles = true;
	_StartingVehicles.CreateVehicles(Team, TeamRace, Mission.m_StartingVehiclesMask, spawnpointPosition);
	Mission.m_CreatingStartingVehicles = false;

	SetScrap(Team, 40);

	if(IsTeamplayOn()) 
	then
		for i = GetFirstAlliedTeam(Team), GetLastAlliedTeam(Team)
		do
			if(i ~= Team)
			then
				-- Get a new position near the team's central position
				local pos = GetPositionNear(spawnpointPosition, AllyMinRadiusAway, AllyMaxRadiusAway);

				-- In teamplay, store where offense players were created for respawns later
				Mission.m_TeamPos[i] = pos;
			end -- Loop over allies not the commander
		end
	end

	Mission.m_TeamIsSetUp[Team] = true;
end

-- Given an index localo the Player list, build everything for a given
-- single player (i.e. a vehicle of some sorts), and set up the team
-- as well as necessary
function SetupPlayer(Team);

	local PlayerH = nil;
	local spawnpointPosition = SetVector(0, 0, 0);

	if((Team < 0) or (Team >= MAX_TEAMS)) then
		return nil; -- Sanity check... do NOT proceed
	end

	Mission.m_SpawnedAtTime[Team] = Mission.m_ElapsedGameTime; -- Note when they spawned in.

	local TeamBlock = WhichTeamGroup(Team);

	if((not IsTeamplayOn()) or (TeamBlock < 0))
	then
		-- This player is their own commander; set up their equipment.
		SetupTeam(Team);

		-- Now put player near his recycler
		spawnpointPosition = Mission.m_TeamPos[Team];
		spawnpointPosition.y = TerrainFindFloor(spawnpointPosition.x, spawnpointPosition.z) + 2.5;
	else
		-- Teamplay. Gotta put them near their defensive player. Also, 
		-- always ensure the recycler/etc has been set up for this
		-- team if we know who they are
		SetupTeam(GetCommanderTeam(Team));

		-- SetupTeam will fill in the Mission.m_TeamPos[] array of positions
		-- for both the commander and offense players, so read out the
		-- results
		spawnpointPosition = Mission.m_TeamPos[Team];
		spawnpointPosition.y = TerrainFindFloor(spawnpointPosition.x, spawnpointPosition.z) + 2.5;
	end -- Teamplay setup

	PlayerH = BuildObject(GetPlayerODF(Team), Team, spawnpointPosition);

	-- Added to make your starting pilot match respawning pilot. -GBD
	local TempODFName = nil;
	TempODFName = GetRaceOfTeam(Team) .. "spilo";
	SetPilotClass(PlayerH, TempODFName);
	SetRandomHeadingAngle(PlayerH);

	-- If on team 0 (dedicated server team), make this object gone from the world
	if(Team == 0) then
		MakeInert(PlayerH);
	end

	return PlayerH;
end
	
-- Called from Execute, 1/10 of a second has elapsed. Update everything.
function UpdateGameTime();

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
				if((Seconds == 0) and ((Minutes <= 10) or ((Minutes % 5) == 0)))
				then
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

-- Check for absence of recycler & factory, gameover if so.
function ExecuteCheckIfGameOver();

	-- No need to do anything more...
	if((Mission.m_GameOver) or (Mission.m_ElapsedGameTime < m_GameTPS)) then
		return;
	end

	-- Check for a gameover by no recycler & factory
	local NumFunctioningTeams = 0;
	local TeamIsFunctioning = { };
	local AlliesFunctioning = { }; -- Ally Functioning Flag. -GBD

	for i = 1, MAX_TEAMS-1
	do
		if(Mission.m_TeamIsSetUp[i])
		then
			local Functioning = false; -- Assume so for now.
			--AlliesFunctioning[Mission.m_AllyTeams[i]] = false; -- Assume so for now. -GBD
			
			-- Check if recycler vehicle still exists. Side effect to
			-- note: IsAliveAndPilot zeroes the handle if pilot missing;
			-- that'd be bad for us here if we want to manually remove
			-- it. Thus, we have a sacrificial copy of it the game can
			-- obliterate w/o hurting anything.
			local TempH = Mission.m_RecyclerHandles[i];

			-- Added to allow recycler upgrading? -GBD
			if(not IsAround(TempH)) then
				TempH = GetObjectByTeamSlot(i, DLL_TEAM_SLOT_RECYCLER);
			end

			-- Use the side effect of IsAlive as well, hence the TempH == 0 -GBD
            if((TempH == nil) or (not IsAlive(TempH))) then
				Mission.m_RecyclerHandles[i] = nil; -- Clear this out for later
			else
				Functioning = true;
			end

			-- Set this here. -GBD
			local RecyH = nil;

			-- Check vehicle if it is around, else, check the buuilding -GBD
			if(IsAround(TempH)) then -- This could let you drive it. :) -GBD
			--if((IsAlive(TempH)) or (TempH ~= 0)) then
				RecyH = TempH;
			else
				RecyH = GetObjectByTeamSlot(i, DLL_TEAM_SLOT_RECYCLER);
				--Mission.m_RecyclerHandles[i]=0; -- Clear this out for later
			end

			if(not IsAround(RecyH)) then -- Uh oh, no Recycler? Look for Factory. -GBD
				RecyH = GetObjectByTeamSlot(i, DLL_TEAM_SLOT_FACTORY);
			end

			if(RecyH ~= nil) then
				Functioning = true;
			--else
			--	AlliesFunctioning[Mission.m_AllyTeams[i]] = false; -- If Allied team is dead, flag as so -GBD
			end

			AlliesFunctioning[Mission.m_AllyTeams[i]] = AlliesFunctioning[Mission.m_AllyTeams[i]] or Functioning;
			TeamIsFunctioning[i] = Functioning;

			-- Moved Respawn check here to look for allies too. -GBD
			-- Note deployed location first time it deploys, also every 25.6 seconds
			if((not Mission.m_NotedRecyclerLocation[i]) or (not bit32.band(Mission.m_ElapsedGameTime, 0xFF)))
			then
				-- Grab out allie's Recy for respawn placement if ours is dead.
				if(RecyH == nil) -- Uh oh, your recy+factory are dead. Look for ones on allied teams.
				then
					for x = 1, MAX_TEAMS-1 -- Loop through all teams. 
					do
						-- If the team is set, and it's not the same team as the first loop, and they're allied, then we found one. 
						if((i ~= x) and (IsTeamAllied(i, x)))
						then
							RecyH = GetObjectByTeamSlot(x, DLL_TEAM_SLOT_RECYCLER);
							if(RecyH == nil) then-- Uh oh, no Recycler? Look for Factory.
								RecyH = GetObjectByTeamSlot(x, DLL_TEAM_SLOT_FACTORY);
							end

							if(RecyH ~= nil) then
								break; -- We found one, and they're alive. Abort X loop early. 
							end
						end
					end
				end
				
				if(RecyH ~= nil) -- The above loop found something, update respawn positions.-GBD
				then
					Mission.m_NotedRecyclerLocation[i] = true;
					local RecyPos = GetPosition(RecyH);
					Mission.m_TeamPos[i] = RecyPos;
					-- Apply this to thugs also.
					if(IsTeamplayOn())
					then
						for jj = GetFirstAlliedTeam(i), GetLastAlliedTeam(i)
						do
							-- In teamplay, store where offense players were created for respawns later
							Mission.m_TeamPos[jj] = RecyPos;
						end -- Loop over allies not the commander
					end
				end -- Note deployed location
			end
		end -- Team is set up
	end -- loop over functioning teams

	for i = 1, MAX_TEAMS-1
	do
		if (IsTeamplayOn())
		then
			if (TeamIsFunctioning[i]) then
				NumFunctioningTeams = NumFunctioningTeams + 1;
			end
		else
			if (AlliesFunctioning[i]) then
				NumFunctioningTeams = NumFunctioningTeams + 1;
			end
		end
	end

	-- Keep track if we ever had several teams playing. Don't need
	-- to check for gameover if so-- 
	if(NumFunctioningTeams > 1)
	then
		Mission.m_HadMultipleFunctioningTeams = true;
		return; -- Exit function early
	end

	-- Easy Gameover case: nobody's got a functioning base. End everything now.
	if((NumFunctioningTeams == 0) and (Mission.m_ElapsedGameTime > (5 * m_GameTPS)))
	then
		NoteGameoverByNoBases();
		DoGameover(endDelta);
		Mission.m_GameOver = true;
	else
		if((Mission.m_HadMultipleFunctioningTeams) and (NumFunctioningTeams == 1))
		then
			-- Ok, at one point we had >1 teams playing, now we've got
			-- 1. They're the winner.

			-- In teamplay, report the team as the winner
			if(IsTeamplayOn())
			then
				local WinningTeamgroup = -1;
				for i = 1, MAX_TEAMS-1
				do
					if(TeamIsFunctioning[i])
					then
						if(WinningTeamgroup == -1)
						then
							WinningTeamgroup = WhichTeamGroup(i);
							NoteGameoverByLastTeamWithBase(WinningTeamgroup);
						end
					end
				end

				-- Also, give all players on winning team points...
				for i = 1, MAX_TEAMS-1
				do
					if(WhichTeamGroup(i) == WinningTeamgroup) then
						AddScore(GetPlayerHandle(i), ScoreForWinning);
					end
				end
				DoGameover(endDelta);
				Mission.m_GameOver = true;
			-- Teamplay is on
			else -- Non-teamplay, report individual winner
				-- With alliances, we may not have a winner unless the team
				-- remaining isn't allied (or we would have caught it above)
	
				for i = 1, MAX_TEAMS-1 -- Start at 0. Also give a more proper message if allies are on. -GBD
				do
					if(AlliesFunctioning[Mission.m_AllyTeams[i]]) --if(TeamIsFunctioning[i])
					then
						if(Mission.m_HasAllies[i])
						then
							local TeamName = TranslateString("cfg", "Team") .. " " .. Mission.m_AllyTeams[i]; -- Tell who won. -GBD
							TempMsgString = TranslateString("Network", "HitLastWithBaseStr"):format(TeamName);
							NoteGameoverWithCustomMessage(TempMsgString); -- Custom message ftw. -GBD

							for j = 1, j < MAX_TEAMS-1 -- Give score to allies. -GBD
							do
								if((i ~= j) and (IsTeamAllied(i, j))) then
									AddScore(GetPlayerHandle(j), ScoreForWinning);
								end
							end
						else
							NoteGameoverByLastWithBase(GetPlayerHandle(i));
						end

						AddScore(GetPlayerHandle(i), ScoreForWinning);
						DoGameover(endDelta);
						Mission.m_GameOver=true;
					end -- Found winner team
				end
			end -- Non-teamplay.

		end -- Winner
	end
end

-- Called from Execute(). If Recycler invulnerability is on, then
-- does the job of it.
function ExecuteRecyInvulnerability();
	-- No need to do anything more...
	if((Mission.m_GameOver) or (Mission.m_RecyInvulnerabilityTime == 0)) then
		return;
	end

	local recyHandle = nil; -- for this team, either vehicle or building
	for i = 1, MAX_TEAMS-1
	do
		if(Mission.m_TeamIsSetUp[i])
		then

			-- Check if recycler vehicle still exists. Side effect to
			-- note: IsAliveAndPilot zeroes the handle if pilot missing;
			-- that'd be bad for us here if we want to manually remove
			-- it. Thus, we have a sacrificial copy of it the game can
			-- obliterate w/o hurting anything.
			local TempH = Mission.m_RecyclerHandles[i];
			if((not IsAlive(TempH)) or (TempH == nil)) then
				recyHandle = GetObjectByTeamSlot(i, DLL_TEAM_SLOT_RECYCLER);
			else
				recyHandle = Mission.m_RecyclerHandles[i];
			end

			if((recyHandle ~= nil) and (IsRecycler(recyHandle)))
			then
				SetCurHealth(recyHandle, GetMaxHealth(recyHandle));
			end

		end -- Mission.m_TeamIsSetUp[i]
	end -- i loop over all teams

	-- Prlocal periodic message about recycler invulnerability time left
	if((Mission.m_RecyInvulnerabilityTime == 1) or
		((Mission.m_RecyInvulnerabilityTime % (60 * m_GameTPS)) == 0) or
		((Mission.m_RecyInvulnerabilityTime < (60 * m_GameTPS)) and ((Mission.m_RecyInvulnerabilityTime % (15 * m_GameTPS)) == 0)))
	then

		if (Mission.m_RecyInvulnerabilityTime == 1)
		then
			TempMsgString = TranslateString("strat", "recyclersVulnerable");
		elseif (Mission.m_RecyInvulnerabilityTime >(60 * m_GameTPS))
		then
			TempMsgString = TranslateString("strat", "invulnerableExpiresMin"):format(Mission.m_RecyInvulnerabilityTime / (60 * m_GameTPS));
		else
			TempMsgString = TranslateString("strat", "invulnerableExpiresSec"):format(Mission.m_RecyInvulnerabilityTime / m_GameTPS);
		end

		AddToMessagesBox(TempMsgString, Make_RGB(255, 0, 255)); -- bright purple (ARGB)
	end

	-- Reduce timer
	Mission.m_RecyInvulnerabilityTime = Mission.m_RecyInvulnerabilityTime - 1;
end

-- Rebuilds pilot
function RespawnPilot(DeadObjectHandle, Team);

	local spawnpointPosition = SetVector(0, 0, 0);

	-- Only use safest place if invalid team #
	if((Team < 1) or (Team >= MAX_TEAMS))
	then
		spawnpointPosition = GetSafestspawnpoint();
	else
		-- Use last noted position for the team
		spawnpointPosition = Mission.m_TeamPos[Team];
		Mission.m_SpawnedAtTime[Team] = Mission.m_ElapsedGameTime; -- Note when they spawned in.
	end

	-- As this object was just killed, gotta use the slower search for its
	-- position.
	local OldPos = GetPosition2(DeadObjectHandle);

	-- Find out how far we are away from starting location... use
	-- default if couldn't get position of DeadObjectHandle
	local respawnHeight = RespawnPilotHeight;
	if((math.abs(OldPos.x) > 0.01) and (math.abs(OldPos.z) > 0.01))
	then
		-- Position valid. Use it.
		local dx = OldPos.x - spawnpointPosition.x;
		local dz = OldPos.z - spawnpointPosition.z;
		-- How far this person died from where we'll respawn them
		local distanceAway = math.sqrt((dx * dx) + (dz * dz));
		if(distanceAway < 100.0)
		then
			respawnHeight = 35.0; -- 1.2 used 25.f here
		else
			-- Min of 40, max varies by # of allies. More penalty for
			-- dying far away from your team
			local numAllies = CountAlliedPlayers(Team);
			respawnHeight = 30.0 + (math.sqrt(distanceAway) * 1.25);
			local minRespawnHeight = 40.0;
			local maxRespawnHeight = 72.0 + (15.0 * numAllies);

			if(respawnHeight < minRespawnHeight) then
				respawnHeight = minRespawnHeight;
			elseif(respawnHeight > maxRespawnHeight) then
				respawnHeight = maxRespawnHeight;
			end
		end
   	end
	if(Mission.m_RespawnAtLowAltitude)
	then
		respawnHeight = 2.0;
	end

	-- Randomize starting position somewhat. This gives a range of +/-
	-- RespawnDistanceAwayXZRange
	spawnpointPosition.x = spawnpointPosition.x + (GetRandomFloat(1.0) - 0.5) * (2.0 * RespawnDistanceAwayXZRange);
	spawnpointPosition.z = spawnpointPosition.z + (GetRandomFloat(1.0) - 0.5) * (2.0 * RespawnDistanceAwayXZRange);

	-- Don't allow a spawn underground - just in case there's a cliff
	-- near the starting spawnpointPosition position, we need to keep y above the
	-- ground.
	local curFloor = TerrainFindFloor(spawnpointPosition.x, spawnpointPosition.z) + 2.5;
	if(spawnpointPosition.y < curFloor)
	then
		spawnpointPosition.y = curFloor;
	end
	spawnpointPosition.y = spawnpointPosition.y + respawnHeight; -- Bounce them in the air to prevent multi-kills
	spawnpointPosition.y = spawnpointPosition.y + GetRandomFloat(1.0) * RespawnDistanceAwayYRange;

	local NewPerson = BuildObject(GetInitialPlayerPilotODF(GetRaceOfTeam(Team)), Team, spawnpointPosition);
	SetAsUser(NewPerson, Team);
	AddPilotByHandle(NewPerson);
	SetRandomHeadingAngle(NewPerson);

	-- If on team 0 (dedicated server team), make this object gone from the world
	if(Team == 0)
	then
		MakeInert(NewPerson);
	end

	return EJECTKILLRETCODES_DLLHANDLED;
end

-- Helper function for ObjectKilled/Sniped
function DeadObject(DeadObjectHandle, KillersHandle, isDeadPerson, isDeadAI)

	-- Get team number of the dead object
	local deadObjectTeam = GetTeamNum(DeadObjectHandle);

	-- An object is a player if it's a local or remotely-controlled player
	-- (i.e. not AI)
	local deadObjectIsPlayer = IsPlayer(DeadObjectHandle);
	local killerObjectIsPlayer = IsPlayer(KillersHandle);

	local relationship = GetTeamRelationship(DeadObjectHandle, KillersHandle);

	local deadObjectScrapCost = GetActualScrapCost(DeadObjectHandle);

	-- Jira 2445: Don't count score/kills/deaths for Team 0 (props). -GBD
	if (deadObjectTeam ~= 0)
	then
		-- If the dead unit is directly controlled by a player (i.e. not
		-- one of their AI units)
		if(deadObjectIsPlayer)
		then
			-- Score goes down by the scrap cost of unit that died
			AddScore(DeadObjectHandle, -deadObjectScrapCost);

			-- Scoring: One death for players if they die as a pilot.
			if(isDeadPerson)
			then
				AddDeaths(DeadObjectHandle, 1);
			end
		else
			if(Mission.m_KillForAIKill) then
				AddDeaths(DeadObjectHandle, 1);
			end
			
			if(Mission.m_PointsForAIKill) then
				AddScore(DeadObjectHandle, -deadObjectScrapCost);
			end
		end

		-- If the killer was a human (directly, not via their AI units), then
		-- they get a kill and some score points.
		if (killerObjectIsPlayer)
		then
			if ((relationship == TEAMRELATIONSHIP_SAMETEAM) or
				(relationship == TEAMRELATIONSHIP_ALLIEDTEAM))
			then
				-- Dont count suicide / user bailout
				if (DeadObjectHandle ~= KillersHandle)
				then
					-- Being a jerk to same or allied team loses a kill
					AddKills(KillersHandle, -1);
					-- And killer loses score
					AddScore(KillersHandle, -deadObjectScrapCost);
				end
			else
				AddKills(KillersHandle, 1);
				-- And, bump their score by the scrap cost of what they just killed
				AddScore(KillersHandle, deadObjectScrapCost);
			end
		else
			if ((relationship == TEAMRELATIONSHIP_SAMETEAM) or
				(relationship == TEAMRELATIONSHIP_ALLIEDTEAM))
			then
				if (Mission.m_KillForAIKill) then
					AddKills(KillersHandle, -1);
				end
				
				if (Mission.m_PointsForAIKill) then
					AddScore(KillersHandle, -deadObjectScrapCost);
				end
			else
				if (Mission.m_KillForAIKill) then
					AddKills(KillersHandle, 1);
				end
				
				if (Mission.m_PointsForAIKill) then
					AddScore(KillersHandle, deadObjectScrapCost);
				end
			end
		end

		-- Was this a spawn kill?
		-- Spawnkill is a non-suicide, on a human by another human.  Added
		-- check for not isDeadAI NM 11/25/06 - APC soldiers dying around the
		-- same time as their human player would trip this up.
		local spawnKillTime = MaxSpawnKillTime * m_GameTPS; -- 15 seconds
		local isSpawnKill = (DeadObjectHandle ~= KillersHandle) and
			(not isDeadAI) and
			(deadObjectTeam > 0) and (deadObjectTeam < MAX_TEAMS) and
			(Mission.m_SpawnedAtTime[deadObjectTeam] > 0) and
			((Mission.m_ElapsedGameTime - Mission.m_SpawnedAtTime[deadObjectTeam]) < spawnKillTime);

		-- If this was a spawnkill, register that on the killers score
		if (isSpawnKill)
		then
			TempMsgString = TranslateString("mission", "Spawn kill by %s on %s\n"):format(GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle));
			AddToMessagesBox(TempMsgString);
			AddScore(KillersHandle, -ScoreDecrementForSpawnKill);
		end

		-- Check to see if we have a Mission.m_KillLimit winner
		if ((Mission.m_KillLimit > 0) and (GetKills(KillersHandle) >= Mission.m_KillLimit))
		then
			NoteGameoverByKillLimit(KillersHandle);
			DoGameover(10.0);
		end
	else
		return EJECTKILLRETCODES_DOEJECTPILOT; -- Someone on neutral team always gets default behavior
	end

	if(isDeadAI)
	then
		-- Snipe?
		if(isDeadPerson) then
			return EJECTKILLRETCODES_DLLHANDLED;
		else -- Nope. Eject.
			return _FECore.ObjectKilled(deadObjectHandle, killersHandle) or DoEjectRatio(DeadObjectHandle); --EJECTKILLRETCODES_DOEJECTPILOT;
		end
	else  -- Not DeadAI, i.e. a human!
		-- If this was a dead pilot, we need to build another pilot back
		-- at base. Otherwise, we just eject a pilot from the
		-- craft. [This is strat, nobody gets a craft for free when they
		-- lose one.]
		if(isDeadPerson) then
			return RespawnPilot(DeadObjectHandle, deadObjectTeam);
		else 
			return _FECore.ObjectKilled(deadObjectHandle, killersHandle) or EJECTKILLRETCODES_DOEJECTPILOT;
		end
	end
end