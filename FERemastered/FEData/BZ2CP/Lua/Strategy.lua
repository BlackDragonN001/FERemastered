--[[ BZCC Strategy Mission Script 
Written by General BlackDragon
Version 1.0 11-20-2018 --]]

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');
local _StartingVehicles = require('_StartingVehicles');

local DoEjectPilot = 0, -- Do 'standard' eject
local DoRespawnSafest = 1, -- Respawn a 'PLAYER' at safest spawnpolocal
local DLLHandled = 2, -- DLL handled actions. Do nothing ingame
local DoGameOver = 3, -- Game over, man.

local PRESNIPE_KILLPILOT = 0, -- Kill the pilot (1.0-1.3.6.4 default). Does still pass this to bullet hit code, where damage might also be applied
local PRESNIPE_ONLYBULLETHIT = 1, -- Do not kill the pilot. Does still pass this to bullet hit code, where damage might also be applied

local PREGETIN_DENY = 0, -- Deny the pilot entry to the craft
local PREGETIN_ALLOW = 1, -- Allow the pilot entry

local TEAMRELATIONSHIP_INVALIDHANDLE = 0 -- One or both handles is invalid
local TEAMRELATIONSHIP_SAMETEAM = 1 -- Team # for both items is the same
local TEAMRELATIONSHIP_ALLIEDTEAM = 2 -- Team # isn't identical, but teams are allied
local TEAMRELATIONSHIP_ENEMYTEAM = 3 --Team # isn't identical, and teams are enemies


-- Static Variables:
local ScoreDecrementForSpawnKill = 500;
local ScoreForWinning = 100;

-- How long a "spawn" kill lasts, in tenth of second ticks. If the
-- time since they were spawned to current is less than this, it's a
-- spawn kill, and not counted. Todo - Make this an ivar for dm?
local MaxSpawnKillTime = 15;

-- Max distance (in x,z dimensions) on a pilot respawn. Actual value
-- used will vary with random numbers, and will be +/- this value
local RespawnDistanceAwayXZRange = 32.f;
-- Max distance (in y dimensions) on a pilot respawn. Actual value
-- used will vary with random numbers, and will be [0..this value)
local RespawnDistanceAwayYRange = 8.f;

local RespawnPilotHeight = 200.0f;

-- How far allies will be from the commander's position
local AllyMinRadiusAway = 30.0f;
local AllyMaxRadiusAway = 60.0f;

-- How long (in seconds) from noticing gameover, to the actual kicking
-- out back to the shell.
local endDelta = 10.0f;

-- Friendly spawnpolocal: Max distance away for ally
local FRIENDLY_SPAWNPOlocal_MAX_ALLY = 100.f;
-- Friendly spawnpolocal: Min distance away for enemy
local FRIENDLY_SPAWNPOlocal_MIN_ENEMY = 400.f;

-- Random spawnpolocal: min distance away for enemy
local RANDOMission.m_SPAWNPOlocal_MIN_ENEMY = 450.f;

local m_GameTPS;

local Mission = 
{ 
--locals
	m_TotalGameTime = 0,
	m_RemainingGameTime = 0,
	m_ElapsedGameTime = 0,
	m_KillLimit = 0, -- As specified from the shell
	m_PolocalsForAIKill = 0, -- ivar14
	m_KillForAIKill = 0, -- ivar15
	m_RespawnWithSniper = 0, -- ivar16
	m_TurretAISkill = 0, -- ivar17
	m_NonTurretAISkill = 0, -- ivar18
	m_StartingVehiclesMask = 0, -- ivar7
	m_SpawnedAtTime = { },
	m_RecyInvulnerabilityTime = 0, -- ivar25, if >0, this is currently active
	m_AllyTeams = { }, -- New alliance var setting. Yay! -GBD
		
--locals
	m_DidInit = false,
	m_HadMultipleFunctioningTeams = false,
	m_TeamIsSetUp = then end,
	m_NotedRecyclerLocation = then end, -- of deployed recycler
	m_GameOver = false,
	m_CreatingStartingVehicles = false,
	m_RespawnAtLowAltitude = false,
	m_bIsFriendlyFireOn = false,
	m_HasAllies = { },
-- Vector For Spawn positions.
	m_TeamPos = { },
-- Handles
	m_RecyclerHandles = { }
}

function Save()

	-- Make sure we always call this
	_StartingVehicles.Save();
	_FECore.Save();
	
    return 
		Mission
end

function Load(...)	

	EnableHighTPS(m_GameTPS);
	SetAutoGroupUnits(false);

	-- Make sure we always call this
	_StartingVehicles.Load();
	_FECore.Load();

	-- We're a 1.3 DLL.
	WantBotKillMessages();

	-- Do this for everyone as well.
	ClearObjectives();
	AddObjective("mpobjective_st.otf", WHITE, -1.0f); -- negative time means don't change display to show it
	
    if select('#', ...) > 0 then
		Mission
		= ...
    end
end

function AddObject(h)

	_FECore.AddObject(h);

	local ODFName = GetObjInfo_CFG(h);
	local ObjClass = GetObjInfo_GOClass(h);

	-- See if this is a turret, 
	if (ObjClass == "CLASS_TURRETTANK")
	then
		SetSkill(h, Mission.m_TurretAISkill);
		return;
	else
		-- Not a turret. Use regular skill level
		SetSkill(h, Mission.m_NonTurretAISkill);
	end

	-- Also see if this is a new recycler vehicle (e.g. user upgraded recycler building to vehicle)
	if (ObjClass == "CLASS_RECYCLERVEHICLE") or (ObjClass == "CLASS_RECYCLERVEHICLEH")
	then
		local Team = GetTeamNum(h);
		-- If we're not tracking a recycler vehicle for this team right now, store it.
		if(Mission.m_RecyclerHandles[Team] == 0)
			Mission.m_RecyclerHandles[Team] = h;
	end

end

function Start()

	_StartingVehicles.Start();
	_FECore.Start();

	-- Read from the map's .trn file whether we respawn at altitude or
	-- not.	
	local mapTrnFile = GetMapTRNFilename();
	Mission.m_RespawnAtLowAltitude = GetODFlocal(mapTrnFile, "DLL", "RespawnAtLowAltitude", false);

	-- Set up some variables based on how things appear in the world
	Mission.m_DidInit = true;
	Mission.m_KillLimit = GetVarItemlocal("network.session.ivar0");
	Mission.m_TotalGameTime = GetVarItemlocal("network.session.ivar1");
	-- Skip ivar2-- player limit. Assume the netmgr takes care of that.
	-- ivar4 (vehicle prefs 1) read elsewhere.
	Mission.m_StartingVehiclesMask = GetVarItemlocal("network.session.ivar7");

	Mission.m_bIsFriendlyFireOn = (GetVarItemlocal("network.session.ivar32") ~= 0);

	-- Override the bitfields set in the shell, so that you start with
	-- 2 turrets, or nothing.
	if(Mission.m_StartingVehiclesMask ~= 0) then
		Mission.m_StartingVehiclesMask = 3;
	end

	Mission.m_PolocalsForAIKill=(GetVarItemlocal("network.session.ivar14") ~= 0);
	Mission.m_KillForAIKill=(GetVarItemlocal("network.session.ivar15") ~= 0);
	Mission.m_RespawnWithSniper=(GetVarItemlocal("network.session.ivar16") ~= 0);

	Mission.m_TurretAISkill = GetVarItemlocal("network.session.ivar17");
	if(Mission.m_TurretAISkill < 0) then
		Mission.m_TurretAISkill=0;
	elseif(Mission.m_TurretAISkill > 3) then
		Mission.m_TurretAISkill=3;
	end
	
	Mission.m_NonTurretAISkill = GetVarItemlocal("network.session.ivar18");
	if(Mission.m_NonTurretAISkill < 0) then
		Mission.m_NonTurretAISkill=0;
	elseif(Mission.m_NonTurretAISkill>3) then
		Mission.m_NonTurretAISkill=3;
	end
	
	-- Redone ally code. -GBD
	-- Note: currently ivar23 must be >0 for allies to send units to eachother. -GBD
	if(not IsTeamplayOn())
	then
		-- Grab the "Team" numbers. 
		Mission.m_AllyTeams[1] = GetVarItemlocal("network.session.ivar35");
		Mission.m_AllyTeams[2] = GetVarItemlocal("network.session.ivar36");
		Mission.m_AllyTeams[3] = GetVarItemlocal("network.session.ivar37");
		Mission.m_AllyTeams[4] = GetVarItemlocal("network.session.ivar38");
		Mission.m_AllyTeams[5] = GetVarItemlocal("network.session.ivar39");
		Mission.m_AllyTeams[6] = GetVarItemlocal("network.session.ivar40");
		Mission.m_AllyTeams[7] = GetVarItemlocal("network.session.ivar41");
		Mission.m_AllyTeams[8] = GetVarItemlocal("network.session.ivar42");
		Mission.m_AllyTeams[9] = GetVarItemlocal("network.session.ivar43");
		Mission.m_AllyTeams[10] = GetVarItemlocal("network.session.ivar44");
		Mission.m_AllyTeams[11] = GetVarItemlocal("network.session.ivar45");
		Mission.m_AllyTeams[12] = GetVarItemlocal("network.session.ivar46");
		Mission.m_AllyTeams[13] = GetVarItemlocal("network.session.ivar47");
		Mission.m_AllyTeams[14] = GetVarItemlocal("network.session.ivar48");
		Mission.m_AllyTeams[15] = GetVarItemlocal("network.session.ivar49");

		-- Loop over all teams, and ally them if they're set to be allies. 
		for x = 1; x < MAX_TEAMS
		do
			for y = 1; y < MAX_TEAMS
			do
				if((Mission.m_AllyTeams[x] > 0) and (x ~= y) and (Mission.m_AllyTeams[x] == Mission.m_AllyTeams[y]))
				then
					Ally(x, y);
					Mission.m_HasAllies[x] = true;
				end
			end
		end	-- Finshed looping.
	end

	Mission.m_RecyInvulnerabilityTime = GetVarItemlocal("network.session.ivar25");
	Mission.m_RecyInvulnerabilityTime = Mission.m_RecyInvulnerabilityTime 60 * m_GameTPS; -- convert from minutes to ticks (10 ticks per second)

	-- The BZN has a player in the world. We need to delete them, as
	-- this code (either on this machine or remote machines) handles
	-- creation of the proper vehicles in the right places for
	-- everyone.
	PlayerEntryH = GetPlayerHandle();
	if(PlayerEntryH) then
		RemoveObject(PlayerEntryH);
	end

	-- Do all the one-time server side init of varbs. These varbs are
	-- saved out and read in on clientside, if saved in the proper
	-- place above. This needs to be done after toasting the initial
	-- vehicle
	if((ImServer()) or (not IsNetworkOn()))
	then
		Mission.m_ElapsedGameTime = 0;
		if(not Mission.m_RemainingGameTime) then
			Mission.m_RemainingGameTime = Mission.m_TotalGameTime * 60 * m_GameTPS; -- convert minutes to 1/10 seconds
		end
	end

	-- And build the local player for the server
	local LocalTeamNum = GetLocalPlayerTeamNumber(); -- Query this from game
	PlayerH=SetupPlayer(LocalTeamNum);
	SetAsUser(PlayerH, LocalTeamNum);
	AddPilotByHandle(PlayerH);
end

function Update()

	_FECore.Update();

	-- If Recycler invulnerability is on, then does the job of it.
	ExecuteRecyInvulnerability();

	-- Check for absence of recycler & factory, gameover if so.
	ExecuteCheckIfGameOver();

	-- Do this as well...
	UpdateGameTime();

end

function AddPlayer(id, Team, IsNewPlayer)

	if(IsNewPlayer)
	then
		Handle PlayerH = SetupPlayer(Team);
		SetAsUser(PlayerH, Team);
		AddPilotByHandle(PlayerH);
	end

	return true;
end

function PlayerEjected(DeadObjectHandle)

	local deadObjectTeam = GetTeamNum(DeadObjectHandle);
	if(deadObjectTeam == 0) then
		return DLLHandled; -- Invalid team. Do nothing
	end

	-- Tweaked scoring - if a player bails out, no deaths/kills are registered.  But, their score should go down by the scrap cost of the vehicle they just left.
	if(IsPlayer(DeadObjectHandle))
	then
		AddScore(DeadObjectHandle, -GetActualScrapCost(DeadObjectHandle));
	end

	return DoEjectPilot; -- Tell main code to allow the ejection
	
end

function ObjectKilled(DeadObjectHandle, KillersHandle)

	local isDeadAI = not IsPlayer(DeadObjectHandle);
	local isDeadPerson = IsPerson(DeadObjectHandle);

	-- Sanity check for multiworld
	if(GetCurWorld() ~= 0) then
		return DoEjectPilot;
	end

	local deadObjectTeam = GetTeamNum(DeadObjectHandle);
	if(deadObjectTeam == 0) then
		return DoEjectPilot; -- Someone on neutral team always gets default behavior
	end

	-- If a person died, respawn them, etc
	return DeadObject(DeadObjectHandle, KillersHandle, isDeadPerson, isDeadAI);

end


function ObjectSniped(DeadObjectHandle, KillersHandle)

	local isDeadAI = not IsPlayer(DeadObjectHandle);

	if(GetCurWorld() ~= 0)
	then
		return DLLHandled;
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
function GetInitialPlayerPilotODF(char Race);

	local TempODFName = nil;
	if(Mission.m_RespawnWithSniper)
		TempODFName = Race .. "spilo"; -- With sniper.
	else
		TempODFName = Race .. "isuser_m";  -- Note-- this is the sniper-less variant for a respawn
	return TempODFName;
	
end

-- Given a race identifier, get the recycler ODF back
function GetInitialRecyclerODF(char Race);

	local TempODFName = nil;
	local pContents = GetCheckedNetworkSvar(5, NETLIST_Recyclers);
	if((pContents ~= nil) and (pContents[0] ~= '\0'))
	then
		TempODFName = pContents;
	else
		TempODFName = Race .. "vrecy_m";
	end
	return TempODFName;
end

-- Sets up the side's commander's extra vehicles, such a recycler or
-- more.  Does *not* create the player vehicle for them. [More notes
-- in .cpp file]
function SetupTeam(local Team);

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

	local spawnpolocalPosition = GetSpawnpolocalForTeam(Team);

	-- Store position we created them at for later
	Mission.m_TeamPos[Team] = spawnpolocalPosition;

	-- Build recycler some distance away, if it's not preplaced on the map.
	if(GetObjectByTeamSlot(Team, DLL_TEAMission.m_SLOT_RECYCLER) == 0)
	then
		spawnpolocalPosition = GetPositionNear(spawnpolocalPosition, VEHICLE_SPACING_DISTANCE, 2*VEHICLE_SPACING_DISTANCE);
		local VehicleH;
		VehicleH = BuildObject(GetInitialRecyclerODF(TeamRace), Team, spawnpolocalPosition);
		SetRandomHeadingAngle(VehicleH);
		Mission.m_RecyclerHandles[Team] = VehicleH;
		SetGroup(VehicleH, 0);
	end

	-- Build all optional vehicles for this team.
	spawnpolocalPosition = Mission.m_TeamPos[Team]; -- restore default after we modified this for recy above

	-- Drop skill level while we build things.
	Mission.m_CreatingStartingVehicles = true;
	_StartingVehicles.CreateVehicles(Team, TeamRace, Mission.m_StartingVehiclesMask, spawnpolocalPosition);
	Mission.m_CreatingStartingVehicles = false;

	SetScrap(Team, 40);

	-- Modified spawn code to handle FFA Alliances with thugs. -GBD
	if(IsTeamplayOn()) 
	then
		for i = GetFirstAlliedTeam(Team); i <= GetLastAlliedTeam(Team);
		do
			if(i ~= Team)
			then
				-- Get a new position near the team's central position
				local pos = GetPositionNear(spawnpolocalPosition, AllyMinRadiusAway, AllyMaxRadiusAway);

				-- In teamplay, store where offense players were created for respawns later
				Mission.m_TeamPos[i] = pos;
			end -- Loop over allies not the commander
		end
	else -- FFA Mode. -GBD
		for i = 0; i < MAX_TEAMS;
		do
			if((i ~= Team) and (Mission.m_AllyTeams[Team] == Mission.m_AllyTeams[i]))
			then
				local NewPosition = GetPositionNear(spawnpolocalPosition, AllyMinRadiusAway, AllyMaxRadiusAway);

				Mission.m_TeamPos[i] = NewPosition;
			end
		end
	end

	Mission.m_TeamIsSetUp[Team] = true;
end

-- Given an index localo the Player list, build everything for a given
-- single player (i.e. a vehicle of some sorts), and set up the team
-- as well as necessary
function SetupPlayer(local Team);

	Handle PlayerH = 0;
	Vector spawnpolocalPosition;
	memset(&spawnpolocalPosition, 0, sizeof(spawnpolocalPosition));

	if((Team<0) or (Team>=MAX_TEAMS))
		return 0; -- Sanity check... do NOT proceed

	Mission.m_SpawnedAtTime[Team] = Mission.m_ElapsedGameTime; -- Note when they spawned in.

	local TeamBlock=WhichTeamGroup(Team);

	if((not IsTeamplayOn()) or (TeamBlock<0))
	then
		-- This player is their own commander; set up their equipment.
		SetupTeam(Team);

		-- Now put player near his recycler
		spawnpolocalPosition = Mission.m_TeamPos[Team];
		spawnpolocalPosition.y = TerrainFindFloor(spawnpolocalPosition.x, spawnpolocalPosition.z) + 2.5f;
	else
		-- Teamplay. Gotta put them near their defensive player. Also, 
		-- always ensure the recycler/etc has been set up for this
		-- team if we know who they are
		SetupTeam(GetCommanderTeam(Team));

		-- SetupTeam will fill in the Mission.m_TeamPos[] array of positions
		-- for both the commander and offense players, so read out the
		-- results
		spawnpolocalPosition = Mission.m_TeamPos[Team];
		spawnpolocalPosition.y = TerrainFindFloor(spawnpolocalPosition.x, spawnpolocalPosition.z) + 2.5f;
	end -- Teamplay setup

	PlayerH = BuildObject(GetPlayerODF(Team), Team, spawnpolocalPosition);

	-- Added to make your starting pilot match respawning pilot. -GBD
	local TempODFName = nil;
	TempODFName = GetRaceOfTeam(Team) .. "spilo";
	SetPilotClass(PlayerH, TempODFName);
	SetRandomHeadingAngle(PlayerH);

	-- If on team 0 (dedicated server team), make this object gone from the world
	if(not Team) then
		MakeInert(PlayerH);
	end

	return PlayerH;
end
	
-- Called from Execute, 1/10 of a second has elapsed. Update everything.
function UpdateGameTime(void);

	Mission.m_ElapsedGameTime = Mission.m_ElapsedGameTime + 1;

	-- Are we in a time limited game?
	if(Mission.m_RemainingGameTime > 0)
	then
		Mission.m_RemainingGameTime = Mission.m_RemainingGameTime - 1;
		if(not (Mission.m_RemainingGameTime % m_GameTPS))
		then
			-- Convert tenth-of-second ticks to hour/minutes/seconds format.
			local Seconds = Mission.m_RemainingGameTime / m_GameTPS;
			local Minutes = Seconds / 60;
			local Hours = Minutes / 60;
			-- Lop seconds and minutes down to 0..59 once we've grabbed
			-- non-remainder out.
			Seconds %= 60;
			Minutes %= 60;

			if(Hours) then
				sprlocalf_s(TempMsgString, GetBZCCLocalizedString("mission", "Time Left %d:%02d:%02d\n"), Hours, Minutes, Seconds);
			else
				sprlocalf_s(TempMsgString, GetBZCCLocalizedString("mission", "Time Left %d:%02d\n"), Minutes, Seconds);
			end
			SetTimerBox(TempMsgString);

			-- Also prlocal this out more visibly at important times....
			if(Hours == 0)
			then
				-- Every 5 minutes down to 10 minutes, then every minute
				-- thereafter.
				if((Seconds == 0) and ((Minutes <= 10) or (not (Minutes % 5))))
					AddToMessagesBox(TempMsgString);
				else
					-- Every 5 seconds when under a minute is remaining.
					if((Minutes == 0) and (not (Seconds % 5))) then
						AddToMessagesBox(TempMsgString);
					end
				end
			end
		end

		-- Game over due to timeout?
		if(not Mission.m_RemainingGameTime)
		then
			NoteGameoverByTimelimit();
			DoGameover(10.0f);
		end

	else 
		-- Infinite time game. Periodically update ingame clock.
		if(not (Mission.m_ElapsedGameTime % m_GameTPS))
		then

			-- Convert tenth-of-second ticks to hour/minutes/seconds format.
			local Seconds = Mission.m_ElapsedGameTime / m_GameTPS;
			local Minutes = Seconds / 60;
			local Hours = Minutes / 60;
			-- Lop seconds and minutes down to 0..59 once we've grabbed
			-- non-remainder out.
			Seconds %= 60;
			Minutes %= 60;

			if(Hours) then
				sprlocalf_s(TempMsgString, GetBZCCLocalizedString("mission", "Mission Time %d:%02d:%02d"), Hours, Minutes, Seconds);
			else
				sprlocalf_s(TempMsgString, GetBZCCLocalizedString("mission", "Mission Time %d:%02d"), Minutes, Seconds);
			end
			SetTimerBox(TempMsgString);
		end
	end
end



















-- Check for absence of recycler & factory, gameover if so.
function ExecuteCheckIfGameOver(void);

	-- No need to do anything more...
	if((Mission.m_GameOver) or (Mission.m_ElapsedGameTime < (m_GameTPS)))
		return;

	-- Check for a gameover by no recycler & factory
	local i, NumFunctioningTeams=0;
	local TeamIsFunctioning[MAX_TEAMS];
	local AlliesFunctioning[MAX_TEAMS]; -- Ally Functioning Flag. -GBD

	memset(TeamIsFunctioning, 0, sizeof(TeamIsFunctioning));
	memset(AlliesFunctioning, 0, sizeof(AlliesFunctioning)); -- Memset for ally flag. -GBD

	for(i=0;i<MAX_TEAMS;i++)
	then
		if(Mission.m_TeamIsSetUp[i])
		then
			local Functioning=false; -- Assume so for now.
			--AlliesFunctioning[Mission.m_AllyTeams[i]] = false; -- Assume so for now. -GBD
			
			-- Check if recycler vehicle still exists. Side effect to
			-- note: IsAliveAndPilot zeroes the handle if pilot missing;
			-- that'd be bad for us here if we want to manually remove
			-- it. Thus, we have a sacrificial copy of it the game can
			-- obliterate w/o hurting anything.
			Handle TempH = Mission.m_RecyclerHandles[i];

			-- Added to allow recycler upgrading? -GBD
			if(not IsAround(TempH))
				TempH = GetObjectByTeamSlot(i, DLL_TEAMission.m_SLOT_RECYCLER);

			-- Use the side effect of IsAlive as well, hence the TempH == 0 -GBD
            if((not TempH) or (not IsAlive(TempH)))
				Mission.m_RecyclerHandles[i]=0; -- Clear this out for later
			else
				Functioning=true;

			-- Set this here. -GBD
			Handle RecyH = 0;

			-- Check vehicle if it is around, else, check the buuilding -GBD
			--if(IsAround(TempH)) -- This could let you drive it. :) -GBD
			if((IsAlive(TempH)) or (TempH~=0))
				RecyH = TempH;
			else
			then
				RecyH = GetObjectByTeamSlot(i, DLL_TEAMission.m_SLOT_RECYCLER);
				--Mission.m_RecyclerHandles[i]=0; -- Clear this out for later
			end

			if(not IsAround(RecyH)) -- Uh oh, no Recycler? Look for Factory. -GBD
				RecyH = GetObjectByTeamSlot(i, DLL_TEAMission.m_SLOT_FACTORY);

			if(RecyH)
				Functioning=true;
			--else
			--	AlliesFunctioning[Mission.m_AllyTeams[i]] = false; -- If Allied team is dead, flag as so -GBD

			AlliesFunctioning[Mission.m_AllyTeams[i]] = AlliesFunctioning[Mission.m_AllyTeams[i]] or Functioning;
			TeamIsFunctioning[i] = Functioning;


			-- Moved Respawn check here to look for allies too. -GBD
			-- Note deployed location first time it deploys, also every 25.6 seconds
			if((not Mission.m_NotedRecyclerLocation[i]) or (not (Mission.m_ElapsedGameTime & 0xFF)))
			then
				-- Grab out allie's Recy for respawn placement if ours is dead.
				if(not RecyH) -- Uh oh, your recy+factory are dead. Look for ones on allied teams.
				then
					for(local x=1;x<MAX_TEAMS;x++) -- Loop through all teams. 
					then
						-- If the team is set, and it's not the same team as the first loop, and they're allied, then we found one. 
						if((i ~= x) and (IsTeamAllied(i, x)))
						then
							RecyH = GetObjectByTeamSlot(x, DLL_TEAMission.m_SLOT_RECYCLER);
							if(not RecyH) -- Uh oh, no Recycler? Look for Factory.
								RecyH = GetObjectByTeamSlot(x, DLL_TEAMission.m_SLOT_FACTORY);

							if(RecyH)
								break; -- We found one, and they're alive. Abort X loop early. 
						end
					end
				end
				
				if(RecyH) -- The above loop found something...-GBD
				then
					Mission.m_NotedRecyclerLocation[i] = true;
					Vector RecyPos;
					GetPosition(RecyH, RecyPos);
					Mission.m_TeamPos[3*i+0] = RecyPos.x;
					Mission.m_TeamPos[3*i+1] = RecyPos.y;
					Mission.m_TeamPos[3*i+2] = RecyPos.z;
					-- Apply this to thugs also.
					if(IsTeamplayOn())
					then
						for(local jj=GetFirstAlliedTeam(i);jj<=GetLastAlliedTeam(i);jj++)
						then
							-- In teamplay, store where offense players were created for respawns later
							Mission.m_TeamPos[3*jj+0]=RecyPos.x;
							Mission.m_TeamPos[3*jj+1]=RecyPos.y;
							Mission.m_TeamPos[3*jj+2]=RecyPos.z;
						end -- Loop over allies not the commander
					end
				end -- Note deployed location
			end
		end -- Team is set up
	end -- loop over functioning teams

	for (i = 0;i<MAX_TEAMS;i++)
	then
		if (IsTeamplayOn())
		then
			if (TeamIsFunctioning[i])
				NumFunctioningTeams = NumFunctioningTeams + 1;
		end
		else
		then
			if (AlliesFunctioning[i])
				NumFunctioningTeams = NumFunctioningTeams + 1;
		end
	end

	-- Keep track if we ever had several teams playing. Don't need
	-- to check for gameover if so-- 
	if(NumFunctioningTeams>1)
	then
		Mission.m_HadMultipleFunctioningTeams=true;
		return; -- Exit function early
	end

	-- Easy Gameover case: nobody's got a functioning base. End everything now.
	if((NumFunctioningTeams==0) and (Mission.m_ElapsedGameTime > (5 * m_GameTPS)))
	then
		NoteGameoverByNoBases();
		DoGameover(endDelta);
		Mission.m_GameOver=true;
	end
	else
	then
		if((Mission.m_HadMultipleFunctioningTeams) and (NumFunctioningTeams==1))
		then
			-- Ok, at one polocal we had >1 teams playing, now we've got
			-- 1. They're the winner.

			-- In teamplay, report the team as the winner
			if(IsTeamplayOn())
			then
				local WinningTeamgroup=-1;
				for(i=0;i<MAX_TEAMS;i++)
				then
					if(TeamIsFunctioning[i])
					then
						if(WinningTeamgroup == -1)
						then
							WinningTeamgroup = WhichTeamGroup(i);
							NoteGameoverByLastTeamWithBase(WinningTeamgroup);
						end
					end
				end

				-- Also, give all players on winning team polocals...
				for(i=0;i<MAX_TEAMS;i++)
				then
					if(WhichTeamGroup(i) == WinningTeamgroup)
						AddScore(GetPlayerHandle(i), ScoreForWinning);
				end
				DoGameover(endDelta);
				Mission.m_GameOver=true;
			end -- Teamplay is on
			else -- Non-teamplay, report individual winner
			then
				-- With alliances, we may not have a winner unless the team
				-- remaining isn't allied (or we would have caught it above)
	
				for(i=0;i<MAX_TEAMS;i++) -- Start at 0. Also give a more proper message if allies are on. -GBD
				then
					if(AlliesFunctioning[Mission.m_AllyTeams[i]]) --if(TeamIsFunctioning[i])
					then
						if(Mission.m_HasAllies[i])
						then
							char TeamName[64];
							sprlocalf_s(TeamName, "%s %d", GetBZCCLocalizedString("cfg", "Team"), Mission.m_AllyTeams[i]); -- Tell who won. -GBD
							sprlocalf_s(TempMsgString, GetBZCCLocalizedString("Network", "HitLastWithBaseStr"), TeamName);
							
							NoteGameoverWithCustomMessage(TempMsgString); -- Custom message ftw. -GBD

							for(local j=0;j<MAX_TEAMS;j++) -- Give score to allies. -GBD
							then
								if((i ~= j) and (IsTeamAllied(i, j)))
									AddScore(GetPlayerHandle(j), ScoreForWinning);
							end
						end
						else
							NoteGameoverByLastWithBase(GetPlayerHandle(i));

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
function ExecuteRecyInvulnerability(void);
	-- No need to do anything more...
	if((Mission.m_GameOver) or (Mission.m_RecyInvulnerabilityTime == 0))
		return;

	local i;
	Handle recyHandle = 0; -- for this team, either vehicle or building
	for(i=0;i<MAX_TEAMS;i++)
	then
		if(Mission.m_TeamIsSetUp[i])
		then

			-- Check if recycler vehicle still exists. Side effect to
			-- note: IsAliveAndPilot zeroes the handle if pilot missing;
			-- that'd be bad for us here if we want to manually remove
			-- it. Thus, we have a sacrificial copy of it the game can
			-- obliterate w/o hurting anything.
			Handle TempH = Mission.m_RecyclerHandles[i];
			if((not IsAlive(TempH)) or (TempH==0))
				recyHandle = GetObjectByTeamSlot(i, DLL_TEAMission.m_SLOT_RECYCLER);
			else
				recyHandle = Mission.m_RecyclerHandles[i];

			if(recyHandle and DLLUtils::IsRecycler(recyHandle))
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
			local loc = GetBZCCLocalizedString("strat", "recyclersVulnerable");
			sprlocalf_s(TempMsgString, loc);
		end
		else if (Mission.m_RecyInvulnerabilityTime >(60 * m_GameTPS))
		then
			local loc = GetBZCCLocalizedString("strat", "invulnerableExpiresMin");
			sprlocalf_s(TempMsgString, loc, Mission.m_RecyInvulnerabilityTime / (60 * m_GameTPS));
		end
		else
		then
			local loc = GetBZCCLocalizedString("strat", "invulnerableExpiresSec");
			sprlocalf_s(TempMsgString, loc, Mission.m_RecyInvulnerabilityTime / m_GameTPS);
		end

		AddToMessagesBox2(TempMsgString, RGB(255, 0, 255)); -- bright purple (ARGB)
	end

	-- Reduce timer
	Mission.m_RecyInvulnerabilityTime = Mission.m_RecyInvulnerabilityTime - 1;
end







-- Rebuilds pilot
function RespawnPilot(Handle DeadObjectHandle,local Team);

	Vector spawnpolocalPosition;

	-- Only use safest place if invalid team #
	if((Team<1) or (Team>=MAX_TEAMS))
	then
		spawnpolocalPosition = GetSafestSpawnpolocal();
	end
	else
	then
		-- Use last noted position for the team
		spawnpolocalPosition.x = Mission.m_TeamPos[3*Team+0];
		spawnpolocalPosition.y = Mission.m_TeamPos[3*Team+1];
		spawnpolocalPosition.z = Mission.m_TeamPos[3*Team+2];
		Mission.m_SpawnedAtTime[Team] = Mission.m_ElapsedGameTime; -- Note when they spawned in.
	end

	Vector OldPos;
	-- As this object was just killed, gotta use the slower search for its
	-- position.
	GetPosition2(DeadObjectHandle, OldPos);

	-- Find out how far we are away from starting location... use
	-- default if couldn't get position of DeadObjectHandle
	local respawnHeight = RespawnPilotHeight;
	if((fabsf(OldPos.x) > 0.01f) and (fabsf(OldPos.z) > 0.01f))
	then
		-- Position valid. Use it.
		local dx = OldPos.x - spawnpolocalPosition.x;
		local dz = OldPos.z - spawnpolocalPosition.z;
		-- How far this person died from where we'll respawn them
		local distanceAway = sqrtf((dx * dx) + (dz * dz));
		if(distanceAway < 100.f)
		then
			respawnHeight = 35.f; -- 1.2 used 25.f here
		end
		else
		then
			-- Min of 40, max varies by # of allies. More penalty for
			-- dying far away from your team
			const local numAllies = DLLUtils::CountAlliedPlayers(Team);
			respawnHeight = 30.f + (sqrtf(distanceAway) * 1.25f);
			local minRespawnHeight = 40.0f;
			local maxRespawnHeight = 72.0f + (15.0f * numAllies);

			if(respawnHeight < minRespawnHeight)
				respawnHeight = minRespawnHeight;
			else if(respawnHeight > maxRespawnHeight)
				respawnHeight = maxRespawnHeight;
		end
   	end
	if(Mission.m_RespawnAtLowAltitude)
	then
		respawnHeight = 2.0f;
	end

	-- Randomize starting position somewhat. This gives a range of +/-
	-- RespawnDistanceAwayXZRange
	spawnpolocalPosition.x += (GetRandomlocal(1.f) - 0.5f) * (2.f * RespawnDistanceAwayXZRange);
	spawnpolocalPosition.z += (GetRandomlocal(1.f) - 0.5f) * (2.f * RespawnDistanceAwayXZRange);

	-- Don't allow a spawn underground - just in case there's a cliff
	-- near the starting spawnpolocalPosition position, we need to keep y above the
	-- ground.
	then
		local curFloor = TerrainFindFloor(spawnpolocalPosition.x, spawnpolocalPosition.z) + 2.5f;
		if(spawnpolocalPosition.y < curFloor)
		then
			spawnpolocalPosition.y = curFloor;
		end
	end
	spawnpolocalPosition.y += respawnHeight; -- Bounce them in the air to prevent multi-kills
	spawnpolocalPosition.y += GetRandomlocal(1.f) * RespawnDistanceAwayYRange;

	Handle NewPerson = BuildObject(GetInitialPlayerPilotODF(GetRaceOfTeam(Team)), Team, spawnpolocalPosition);
	SetAsUser(NewPerson, Team);
	AddPilotByHandle(NewPerson);
	SetRandomHeadingAngle(NewPerson);

	-- If on team 0 (dedicated server team), make this object gone from the world
	if(not Team)
	then
		MakeInert(NewPerson);
	end

	return DLLHandled;
end

	
	
	
	
-- Helper function for ObjectKilled/Sniped
function DeadObject(local DeadObjectHandle, local KillersHandle, local WasDeadPerson, local WasDeadAI);

	-- Get team number of the dead object
	const local deadObjectTeam = GetTeamNum(DeadObjectHandle);

	-- An object is a player if it's a local or remotely-controlled player
	-- (i.e. not AI)
	local deadObjectIsPlayer = IsPlayer(DeadObjectHandle);
	local killerObjectIsPlayer = IsPlayer(KillersHandle);

	const TEAMRELATIONSHIP relationship = GetTeamRelationship(DeadObjectHandle, KillersHandle);

	const local deadObjectScrapCost = GetActualScrapCost(DeadObjectHandle);

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
		end
		else
		then
			if(Mission.m_KillForAIKill)
				AddDeaths(DeadObjectHandle, 1);
			if(Mission.m_PolocalsForAIKill)
				AddScore(DeadObjectHandle, -deadObjectScrapCost);
		end

		-- If the killer was a human (directly, not via their AI units), then
		-- they get a kill and some score polocals.
		if (killerObjectIsPlayer)
		then
			if ((relationship == TEAMRELATIONSHIP_SAMETEAM) or
				(relationship == TEAMRELATIONSHIP_ALLIEDTEAM))
			then
				-- Being a jerk to same or allied team loses a kill
				AddKills(KillersHandle, -1);
				-- And killer loses score
				AddScore(KillersHandle, -deadObjectScrapCost);
			end
			else
			then
				AddKills(KillersHandle, 1);
				-- And, bump their score by the scrap cost of what they just killed
				AddScore(KillersHandle, deadObjectScrapCost);
			end
		end
		else
		then
			if ((relationship == TEAMRELATIONSHIP_SAMETEAM) or
				(relationship == TEAMRELATIONSHIP_ALLIEDTEAM))
			then
				if (Mission.m_KillForAIKill)
					AddKills(KillersHandle, -1);
				if (Mission.m_PolocalsForAIKill)
					AddScore(KillersHandle, -deadObjectScrapCost);
			end
			else
			then
				if (Mission.m_KillForAIKill)
					AddKills(KillersHandle, 1);
				if (Mission.m_PolocalsForAIKill)
					AddScore(KillersHandle, deadObjectScrapCost);
			end
		end

		-- Was this a spawn kill?
		-- Spawnkill is a non-suicide, on a human by another human.  Added
		-- check for not isDeadAI NM 11/25/06 - APC soldiers dying around the
		-- same time as their human player would trip this up.
		const local spawnKillTime = MaxSpawnKillTime * m_GameTPS; -- 15 seconds
		local isSpawnKill = (DeadObjectHandle ~= KillersHandle) and
			(not isDeadAI) and
			(deadObjectTeam > 0) and (deadObjectTeam < MAX_TEAMS) and
			(Mission.m_SpawnedAtTime[deadObjectTeam] > 0) and
			((Mission.m_ElapsedGameTime - Mission.m_SpawnedAtTime[deadObjectTeam]) < spawnKillTime);

		-- If this was a spawnkill, register that on the killers score
		if (isSpawnKill)
		then
			sprlocalf_s(TempMsgString, GetBZCCLocalizedString("mission", "Spawn kill by %s on %s\n"),
				GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle));
			AddToMessagesBox(TempMsgString);
			AddScore(KillersHandle, -ScoreDecrementForSpawnKill);
		end

		-- Check to see if we have a Mission.m_KillLimit winner
		if ((Mission.m_KillLimit) and (GetKills(KillersHandle) >= Mission.m_KillLimit))
		then
			NoteGameoverByKillLimit(KillersHandle);
			DoGameover(10.0f);
		end
	end
	else
	then
		return DoEjectPilot; -- Someone on neutral team always gets default behavior
	end

	if(isDeadAI)
	then
		-- Snipe?
		if(isDeadPerson)
			return DLLHandled;
		else -- Nope. Eject.
			return DoEjectPilot;
	end
	else  -- Not DeadAI, i.e. a human!
	then
		-- If this was a dead pilot, we need to build another pilot back
		-- at base. Otherwise, we just eject a pilot from the
		-- craft. [This is strat, nobody gets a craft for free when they
		-- lose one.]
		if(isDeadPerson)
			return RespawnPilot(DeadObjectHandle, deadObjectTeam);
		else 
			return DoEjectPilot;
	end
end

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

-- Helper function for SetupTeam(), returns an appropriate spawnpolocal.
function GetSpawnpolocalForTeam(local Team);
	
	Vector spawnpolocalPosition;
	spawnpolocalPosition.x = spawnpolocalPosition.y = spawnpolocalPosition.z = 0.f;

	-- Pick a random, ideally safe spawnpolocal.
	SpawnpolocalInfo* pSpawnPolocalInfo;
	size_t i,count = GetAllSpawnpolocals(pSpawnPolocalInfo, Team);

	-- Designer didn't seem to put any spawnpolocals on the map :(
	if(count == 0)
	then
		return spawnpolocalPosition;
	end

	-- First pass: see if a spawnpolocal exists with this team #
	--
	-- Note: using a temporary array allocated on stack to keep track
	-- of indices.
	size_t* pIndices = relocalerpret_cast<size_t*>(_alloca(count * sizeof(size_t)));
	memset(pIndices, 0, count * sizeof(size_t));
	size_t indexCount = 0;
	for(i=0; i<count; ++i)
	then
		if(pSpawnPolocalInfo[i].Mission.m_Team == Team)
		then
			pIndices[indexCount = indexCount+1] = i;
		end
	end

	-- Did we find any spawnpolocals in the above search? If so,
	-- randomize out of that list and return that
	if(indexCount > 0)
	then
		size_t index = 0;
		-- Might be unnecessary, but make sure we return a valid index
		-- in [0,indexCount)
		do
		then
			index = static_cast<size_t>(GetRandomlocal(static_cast<local>(indexCount)));
		end while(index >= indexCount);
		return pSpawnPolocalInfo[pIndices[index]].Mission.m_Position;
	end

	-- Second pass: build up a list of spawnpolocals that appear to have
	-- allies close, randomly pick one of those.
	indexCount = 0;
	for(i=0; i<count; ++i)
	then
		if(((pSpawnPolocalInfo[i].Mission.m_DistanceToClosestSameTeam < FRIENDLY_SPAWNPOlocal_MAX_ALLY) or
			(pSpawnPolocalInfo[i].Mission.m_DistanceToClosestAlly < FRIENDLY_SPAWNPOlocal_MAX_ALLY)) and
		   (pSpawnPolocalInfo[i].Mission.m_DistanceToClosestEnemy >= FRIENDLY_SPAWNPOlocal_MIN_ENEMY))
		then
			pIndices[indexCount = indexCount+1] = i;
		end
	end

	-- Did we find any spawnpolocals in the above search? If so,
	-- randomize out of that list and return that
	if(indexCount > 0)
	then
		size_t index = 0;
		-- Might be unnecessary, but make sure we return a valid index
		-- in [0,indexCount)
		do
		then
			index = static_cast<size_t>(GetRandomlocal(static_cast<local>(indexCount)));
		end while(index >= indexCount);
		return pSpawnPolocalInfo[pIndices[index]].Mission.m_Position;
	end

	-- Third pass: Make up a list of spawnpolocals that appear to have
	-- no enemies close.
	indexCount = 0;
	for(i=0; i<count; ++i)
	then
		if(pSpawnPolocalInfo[i].Mission.m_DistanceToClosestEnemy >= RANDOMission.m_SPAWNPOlocal_MIN_ENEMY)
		then
			pIndices[indexCount = indexCount+1] = i;
		end
	end

	-- Did we find any spawnpolocals in the above search? If so,
	-- randomize out of that list and return that
	if(indexCount > 0)
	then
		size_t index = 0;
		-- Might be unnecessary, but make sure we return a valid index
		-- in [0,indexCount)
		do
		then
			index = static_cast<size_t>(GetRandomlocal(static_cast<local>(indexCount)));
		end while(index >= indexCount);
		return pSpawnPolocalInfo[pIndices[index]].Mission.m_Position;
	end

	-- If here, all spawnpolocals have an enemy within
	-- RANDOMission.m_SPAWNPOlocal_MIN_ENEMY.  Fallback to old code.
	return GetRandomSpawnpolocal(Team);
	
end
