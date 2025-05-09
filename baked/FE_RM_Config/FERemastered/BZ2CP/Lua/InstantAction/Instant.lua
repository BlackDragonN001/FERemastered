--[[
	Summary: BZCC FE Instant Action Mission Script
	Author: JJ (AI_Unit)
	Version: 1.0
	Last modified: 21/09/2022
--]]

-- File find fix.
assert(load(assert(LoadFile("_requirefix.lua")), "_requirefix.lua"))();

-- Load the core files.
local _FECore = require('_FECore');
local _MPI = require('_MPI');

-- Spacing distance between each vehicle from the Recycler's spawn point.
local VEHICLE_SPACING_DISTANCE = 20.0

-- How high a player pilot should spawn above their Recycler.
local RespawnPilotHeight = 200.0;

-- How long (in seconds) from noticing gameover, to the actual kicking out back to the shell.
local endDelta = 10.0;

-- Debug.
local debug = true;

-- IA Starting Vehicle handles.
local StartingVehicleTable =
{
	{ "vturr", "vturr", "vscav" },
	{ "vturr", "vturr", "vscav", "vtank", "vscout", "vscout" },
	{ "vturr", "vturr", "vscav", "vtank", "vtank",  "vtank", "vscout", "vscout", "vscout" },
}

local Mission =
{
	m_ElapsedGameTime = 0, -- turn counter.
	m_HumanRace = 'i',  -- CPU Race.
	--m_CPURace = 'i', 	-- CPU Race.
	--m_Difficulty = 0,     -- Chosen in IA shell.
	m_RespawnEnabled = 0,      -- Chosen in IA shell.
	m_HumanStartingForceSize = 1, -- Starting force size for humans.
	--m_CPUStartingForceSize = 1,     -- Start force size for CPU.
	m_GameOver = false,        -- Handle game over.
	--m_SetFirstAIP = false,     -- For SetPlan() taunts.
	--m_PlayerRespawnEnabled = false,     -- If player respawn is enabled.
	--m_SentFirstCPUScavToPool = false, 	-- To help the CPU, this flag will send the first spawned CPU Scav to a pool before Recycler deployment.
	m_BuildingStartingUnits = false, -- Halt the dispatcher until we're ready. This must be Saved so things will work correctly on a Load.
	m_EnemyRecycler = nil,        -- CPU Recycler.
	m_EnemyRecycler2 = nil,       -- If it's 3 way.
	m_Recycler = nil,             -- Human Recycler.
	m_MapPools = {},              -- Keep track of the maps pools.
}

-- Save game data.
function Save()
	return _FECore.Save(), _MPI.Save(), Mission;
end

-- Load game data.
function Load(FECoreData, MPIData, MissionData)
	-- Don't auto group units.
	SetAutoGroupUnits(false);

	-- Want to trigger ObjectKilled for AI units.
	WantBotKillMessages();

	-- Load sub modules.
	_FECore.Load(FECoreData);

	_MPI.Load(MPIData);

	-- Load mission data.
	Mission = MissionData;

	-- Do this for everyone as well.
	CreateObjectives();
end

-- Function for creating and displaying generic objective.
function CreateObjectives()
	ClearObjectives();
	AddObjective("InstantAction.otf", "WHITE", -1);
end

-- Pre-game initial setup.
function InitialSetup()
	-- Initiate sub modules.
	_FECore.InitialSetup();
	_MPI.InitialSetup();

	-- Don't auto group units.
	SetAutoGroupUnits(false);

	-- Want to trigger ObjectKilled for AI Units.
	WantBotKillMessages();
end

-- Handle when an object is added to the world.
function AddObject(h)
	-- Call core AddObject method.
	_FECore.AddObject(h);

	-- Grab our important details.
	local teamNum = GetTeamNum(h);
	local ODFName = GetCfg(h);
	local ObjClass = GetClassLabel(h);

	-- Player stuff.
	if (teamNum == PLAYER_START_TEAM) then
		SetSkill(h, 3);
		-- Check CPU stuff.
	elseif (teamNum >= CPU_START_TEAM) then
		-- CPU "Commander" pilots.
		if (string.sub(ODFName, 3, 9) == "cmdr_c") then
			SetSkill(h, 3); -- Set Commander maximum skill to 3.
		else
			-- Give the CPU a custom pilot config.
			if (not IsBuilding(h) and string.sub(ODFName, 1, 1) ~= "c") then
				SetPilotClass(h, string.sub(ODFName, 1, 1) .. "spilo_c");
			end

			--[[
			-- Replace the CPU natural extractor as we're using a different ODF.
			if (ODFName == string.sub(ODFName, 1, 1) .. "bscav") then
				ReplaceObject(h, string.sub(ODFName, 1, 1) .. "bscav_c");
				return; -- ReplaceObject removed us, we're done here, too dangerous to continue as we no longer exist. -GBD
			end
			--]]
		end
	elseif (teamNum == 0) then
		-- Keep track of the map pools.
		if (ObjClass == "CLASS_DEPOSIT") then
			table.insert(Mission.m_MapPools, h);
		end
	end

	-- Call MPI addobject.
	_MPI.AddObject(h, Mission.m_BuildingStartingUnits, Mission.m_ElapsedGameTime, ODFName, ObjClass);
end

-- Runs on mission state.
function Start()
	-- Teams for Stats...
	-- TODO? expose to Options? -GBD
	SetTeamNameForStat(PLAYER_START_TEAM, "Humans");
	SetTeamNameForStat(CPU_START_TEAM, "Computer");
	SetTeamNameForStat(CPU_START_TEAM + CPU2_TEAM_OFFSET, "Computer");
	-- SetTauntCPUName(""); -- To set the CPU Taunt team name to something custom. -GBD

	-- Get our difficulty.
	--Mission.m_Difficulty = IFace_GetInteger("shell.instant.difficulty");

	-- Remove any trace of old player vehicles left in the BZN.
	local PlayerEntryH = GetPlayerHandle();

	if (PlayerEntryH ~= nil) then
		RemoveObject(PlayerEntryH);
	end

	-- Rebuild the player.
	local LocalTeamNum = GetLocalPlayerTeamNumber();
	local PlayerH = SetupPlayer(LocalTeamNum);
	SetAsUser(PlayerH, LocalTeamNum);
	AddPilotByHandle(PlayerH);

	-- Put up Objectives.
	CreateObjectives();

	-- Call MPI start.
	_MPI.Start();

	-- Spawn the CPU.
	Mission.m_BuildingStartingUnits = true;
	Mission.m_EnemyRecycler = _MPI.SetupAITeam(CPU_START_TEAM);

	if (IFace_GetInteger("options.instant.int0") ~= 0) then
		Mission.m_EnemyRecycler2 = _MPI.SetupAITeam(CPU_START_TEAM + CPU2_TEAM_OFFSET);
	end

	Mission.m_BuildingStartingUnits = false;
end

-- Called per tick.
function Update()
	-- Call core AddObject method.
	_FECore.Update();

	-- turn counter.
	Mission.m_ElapsedGameTime = Mission.m_ElapsedGameTime + 1;

	-- Call MPI update.
	_MPI.Update(Mission.m_ElapsedGameTime);

	-- Test win conditions.
	TestGameOver();
end

-- Handle win conditions.
function TestGameOver()
	if (not Mission.m_GameOver) then
		-- Loop over AI teams
		local AITeamsAlive = false;
		for i = CPU_START_TEAM, MAX_TEAMS - 1 do
			-- AI Team 1.
			if i == CPU_START_TEAM then
				if (Mission.m_EnemyRecycler ~= nil) then
					if IsAround(Mission.m_EnemyRecycler) then
						AITeamsAlive = true;
						break;
					else
						local tempH = GetObjectByTeamSlot(i, DLL_TEAM_SLOT_RECYCLER);

						if (tempH ~= nil) then
							Mission.m_EnemyRecycler = tempH; -- Save it.
							AITeamsAlive = true;
							break;
						else
							DoTaunt(TAUNTS_CPURecyDestroyed);
						end
					end
				end
				-- AI Team 2
			elseif i == CPU_START_TEAM + CPU2_TEAM_OFFSET then
				if (Mission.m_EnemyRecycler2 ~= nil) then
					if IsAround(Mission.m_EnemyRecycler2) then
						AITeamsAlive = true;
						break;
					else
						local tempH = GetObjectByTeamSlot(i, DLL_TEAM_SLOT_RECYCLER);

						if (tempH ~= nil) then
							Mission.m_EnemyRecycler2 = tempH; -- Save it.
							AITeamsAlive = true;
							break;
						else
							DoTaunt(TAUNTS_CPURecyDestroyed);
						end
					end
				end
			end
		end

		if not AITeamsAlive then
			SucceedMission(GetTime() + 5.0, "instantw.txt");
			Mission.m_GameOver = true;
		end

		if (not IsAround(Mission.m_Recycler)) then
			local tempH = GetObjectByTeamSlot(PLAYER_START_TEAM, DLL_TEAM_SLOT_RECYCLER);

			if (tempH ~= 0) then
				Mission.m_Recycler = tempH; -- Save it.
			else
				DoTaunt(TAUNTS_HumanRecyDestroyed);
				FailMission(GetTime() + 5.0, "instantl.txt");
				Mission.m_GameOver = true;
			end
		end
	end
end

-- Setup the player.
function SetupPlayer()
	-- Check player race selection.
	Mission.m_HumanRace = string.char(IFace_GetInteger("options.instant.myrace"));

	-- Lua arrays start with an index of 1, not 0, so add + 1 for later use.
	Mission.m_HumanStartingForceSize = IFace_GetInteger("options.instant.playerforce") + 1;

	-- This player is their own commander; set up their equipment.
	local spawnpointPosition = GetPosition("Recycler");
	spawnpointPosition.y = TerrainFindFloor(spawnpointPosition.x, spawnpointPosition.z) + 2.5;

	-- Create the player.
	local PlayerH = BuildObject(Mission.m_HumanRace .. "vscout", PLAYER_START_TEAM, spawnpointPosition);

	SetPilotClass(PlayerH, Mission.m_HumanRace .. "spilo");
	SetRandomHeadingAngle(PlayerH);

	-- Build recycler some distance away, if it's not preplaced on the map.
	local chosenPlayerRecy = IFace_GetString("options.instant.string1");
	chosenPlayerRecy = Mission.m_HumanRace .. chosenPlayerRecy:sub(2);

	Mission.m_Recycler = BuildObject(chosenPlayerRecy, PLAYER_START_TEAM,
		GetPositionNear(spawnpointPosition, VEHICLE_SPACING_DISTANCE * 1.25, VEHICLE_SPACING_DISTANCE * 1.25));
	SetGroup(Mission.m_Recycler, 0);

	-- Spawn extra Human vehicles.
	SpawnTeamExtraVehicles(PLAYER_START_TEAM, Mission.m_HumanRace, spawnpointPosition, Mission.m_HumanStartingForceSize);

	-- Give some scrap.
	SetScrap(PLAYER_START_TEAM, 40);

	-- DEBUG
	if (debug) then
		BuildObject("ibpgen", PLAYER_START_TEAM, "debug_p");
		BuildObject("ibcbun", PLAYER_START_TEAM, "debug_b");
	end

	return PlayerH;
end

-- Handle destroyed player...
function PlayerDied(deadObjectHandle, sniped)
	-- Player is dead.
	if (not IsPerson(deadObjectHandle)) then
		-- Craft died. If it wasn't a snipe, then just kick the pilot out.
		if (not sniped) then
			-- Be mean...
			DoTaunt(TAUNTS_HumanShipDestroyed);

			-- Return DoEjectPilot.
			return _FECore.ObjectKilled(deadObjectHandle, killersHandle) or EJECTKILLRETCODES_DOEJECTPILOT;
		end
	end

	-- Local player got killed (pilot or snipe). Do respawn as needed.
	if (Mission.m_RespawnEnabled) and IsAround(Mission.m_Recycler) then
		-- Respawn them near their m_Recycler, up in the air.	
		local Where = GetPosition(Mission.m_Recycler, Where);

		Where = GetPositionNear(Where, 10.0, 50.0);
		Where.y = Where.y + 50.0;

		local PlayerODF = string.format("%cspilo", Mission.m_HumanRace);
		local PlayerH = BuildObject(PlayerODF, 1, Where);
		SetAsUser(PlayerH, 1);
		AddPilotByHandle(PlayerH);

		DoTaunt(TAUNTS_HumanShipDestroyed);
	else
		-- User can't respawn. Game over, man
		FailMission(GetTime() + 3);
	end

	-- Both cases of the above report that we handled things.
	return EJECTKILLRETCODES_DLLHANDLED;
end

-- Handle destroyed objects...
function ObjectKilled(deadObjectHandle, killersHandle)
	-- AI-controlled object is toast...
	if (not IsPlayer(deadObjectHandle)) then
		-- Should we eject a pilot instead?
		if (not IsPerson(deadObjectHandle)) then
			return _FECore.ObjectKilled(deadObjectHandle, killersHandle) or DoEjectRatio(deadObjectHandle); --EJECTKILLRETCODES_DOEJECTPILOT; -- Return DoEjectPilot.
		else
			return EJECTKILLRETCODES_DLLHANDLED;                                                   -- Return DLLHandled.
		end
	else
		-- Handle player death.
		return PlayerDied(deadObjectHandle, false);
	end
end

-- Handle sniped objects...
function ObjectSniped(deadObjectHandle, killersHandle)
	if (not IsPlayer(deadObjectHandle)) then
		return EJECTKILLRETCODES_DLLHANDLED; -- AI-controlled object is toast...
	else
		return PlayerDied(deadObjectHandle, true); -- Player dead.
	end
end

-- TODO: Move to core to be used universally?
function SpawnTeamExtraVehicles(Team, Race, Pos, Force)
	-- Get the correct amount of units to spawn based on Force parameter.
	local vehicles = StartingVehicleTable[Force];

	Mission.m_BuildingStartingUnits = true;

	-- Loop through each unit to handle their placement.
	for i, v in pairs(vehicles) do
		-- Get each handle within the table.
		local h = vehicles[i];

		-- Don't continue if the handle isn't found.
		if (h == nil) then
			return;
		end

		-- Prepend the race to the ODF name.
		h = Race .. h;

		-- Generate a position around given Pos vector.
		local pos = GetPositionNear(Pos, VEHICLE_SPACING_DISTANCE * 1.25, VEHICLE_SPACING_DISTANCE * 1.25);

		-- Finally, build it!
		local vehicle = BuildObject(h, Team, pos);
	end

	-- If we're the CPU team, spawn turrets around the map based on difficulty.
	if (Team >= CPU_START_TEAM) then
		for i = 1, Mission.m_Difficulty + 2 do
			local h = BuildObject(Race .. "vturr", Team, "hold" .. i);
		end

		-- Allow the dispatcher to continue...
		Mission.m_BuildingStartingUnits = false;
	end
end
