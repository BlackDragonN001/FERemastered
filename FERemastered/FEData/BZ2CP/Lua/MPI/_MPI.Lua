-- New MPI Files for FE 
-- Written by JJ (AI_Unit)
-- Version 1.0 - 26/02/2019

--[[ TO DO Notes: -GBD

Rewrite for dynamic spawning / function.

-Table to store MPI specific vars. MPI ONLY vars go in this file.

-SetupAITeam: pass in team number, and spawn using Enemy_# path points. (5 ... 1)

-Save/load to be called from ST. (setup like StartingVehicles does)

-Start function: read in vars and save them, setup / spawn AI team(s).
-- Iterate over AI, spawn them if they're set, and if the map supports / allows that many AI.
-- In AddObject Count how many Spawn points there are for total spawn areas.
-- For FFA, use Player Limit to deduct from total base areas. For teamplay, use ivar11 to determine how many spots to reserve for players.
-- Start AI at Team 15, and work backwards to 11. This way, 2 Teams of humans (Team 1-10) could be used vs multiple AI Teams if TeamPlay is on. (Team A vs Team B vs up to 5 AI) for a total support of 7 bases in Teamplay.

-Update function: Iterate over AI Teams, perform scrap cheat updates.

-AddObject: Call the AddToDispatch function for AI objects here, based on cpu difficulty. (read difficulty from [Start] section in AIP.)
-- GBD TODO: Add Lua Callback for AddToDispatch.
--]]
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local _FECore = require('_FECore');
local _DLLUtils = require('_DLLUtils');
local _StartingVehicles = require('_StartingVehicles');

-- VARS
local DEBUG = true;

local CPU_TEAM_NUMBER = 6;
local CPU_DIFFICULTY = 0;
local CPU_COMMANDER_ENABLED = 0;
local CPU_SUPER_UNITS = 0;
local CPU_REINFORCEMENTS = 0;

local SAVAGE_UNITS = 0;
local ARTIFACTS = 0;
local WEAPON_CACHES = 0;
local SCRAP_SILOS = 0;

local TOTAL_AI_TEAMS = {};
local TOTAL_SPAWN_COUNT = 0;

local VEHICLE_SPACING_DISTANCE = 20.0;
local MAX_TEAMS = 16;

-- TABLES
local _MPI = {};

local AIVehicles = {
	AIRecycler = nil,
};

local MPIValues = {
	-- How long the Bad Weather on the map will last.
	BadWeatherTimer = 60;
	-- Set the cooldown to 10 minutes by default.
	BadWeatherCooldown = 600;
}

--[[
	Here is a list of all available custom IVARs. 
	- ivar70 - AI Difficulty.
	- ivar71 - AI Commander Spawning.
	- ivar72 - Starting units choice. I'd like to add this for balance.
	- ivar73 - AI Super Units.
	- ivar74 - AI Reinforcements.
	- ivar75 - AI Recycler Replacement.
	- ivar76 - AI Demolishers.
	- ivar77 - Savage units.
	- ivar78 - Artifacts.
	- ivar79 - Weapon Caches.
	- ivar80 - Scrap Silos.
	- ivar81 - Bad Weather.
]]

function _MPI.Start()
	-- Define Custom Variables here for options - AI_Unit
	CPU_DIFFICULTY = GetVarItemInt("network.session.ivar70");
	CPU_COMMANDER_ENABLED = GetVarItemInt("network.session.ivar71");
	CPU_SUPER_UNITS = GetVarItemInt("network.session.ivar73");
	CPU_REINFORCEMENTS = GetVarItemInt("network.session.ivar74");
	SAVAGE_UNITS = GetVarItemInt("network.session.ivar77");
	ARTIFACTS = GetVarItemInt("network.session.ivar78");
	WEAPON_CACHES = GetVarItemInt("network.session.ivar79");
	SCRAP_SILOS = GetVarItemInt("network.session.ivar80");

	-- If Debugging is enabled, we should print all available data related to the AI team
	if (DEBUG) then
		print("Current Race of AI Team: (" .. CPU_TEAM_NUMBER .. "): ");
		Ally(1, CPU_TEAM_NUMBER);
	end

	-- Grab a list of all available spawn points.
	TOTAL_SPAWN_COUNT = GetAllSpawnPoints();

	-- Call methods in order.
	_MPI.SpawnAITeams();
end

function _MPI.Taunt(event)
	DoTaunt(event);
end

function _MPI.SpawnAITeams()
	-- Grab the path point to spawn the Enemy Recycler
	local AISpawnPosition = GetPosition("RecyclerEnemy");
	local AITeamRace = GetRaceOfTeam(CPU_TEAM_NUMBER);
	
	-- If the AI Recycler does not exist, build one for Team 5.
	if (GetObjectByTeamSlot(CPU_TEAM_NUMBER, DLL_TEAM_SLOT_RECYCLER) == nil) then
		AISpawnPosition = GetPositionNear(AISpawnPosition, VEHICLE_SPACING_DISTANCE, 2 * VEHICLE_SPACING_DISTANCE);
		AIVehicles.AIRecycler = BuildObject("ivrecy_m", CPU_TEAM_NUMBER, AISpawnPosition);
		SetRandomHeadingAngle(AIVehicles.AIRecycler);
	end

	local AIStartingUnits = GetVarItemInt("network.session.ivar72");

	if (AIStartingUnits == 0) then
		_MPI.SpawnAdditionalAIUnits("turrets", CPU_TEAM_NUMBER);
	else
		_MPI.SpawnAdditionalAIUnits("towers", CPU_TEAM_NUMBER);
	end

	-- Commented out for now, experimental.
	-- Don't do team 1, this is the human team.
	--[[for team = 2, MAX_TEAMS do
		if (team == 1) then
			return;
		end

		-- Spawn the right amount of AI units based on options.
		for i = 1, TOTAL_SPAWN_COUNT do
			local chosenPoint = GetSafestSpawnPoint();
			-- If the AI Recycler does not exist, build one for each team.
			if (GetObjectByTeamSlot(team, DLL_TEAM_SLOT_RECYCLER) == nil) then
				AISpawnPosition = GetPositionNear(chosenPoint, VEHICLE_SPACING_DISTANCE, 2 * VEHICLE_SPACING_DISTANCE);
				AIVehicles.AIRecycler = BuildObject("ivrecy_m", team, chosenPoint);
				SetRandomHeadingAngle(AIVehicles.AIRecycler);
			end
		end

		-- We could consider a variable here for AI starting forces, and build vehicles based on that.
		local AIStartingUnits = GetVarItemInt("network.session.ivar72");

		if (AIStartingUnits == 0) then
			_MPI.SpawnAdditionalAIUnits("turrets", team);
		else
			_MPI.SpawnAdditionalAIUnits("towers", team);
		end

		table.insert(TOTAL_AI_TEAMS, team);

		SetGroup(AIVehicles.AIRecycler, 0);
		SetScrap(team, 40);

		-- For each active AI team, insert their team number into a table for later use.
		-- Lastly, create the plan for the AI team.
		_MPI.SetAIPlan(team);
	end]]--

	SetGroup(CPU_TEAM_NUMBER.AIRecycler, 0);
	SetScrap(CPU_TEAM_NUMBER, 40);

	_MPI.SetAIPlan(CPU_TEAM_NUMBER);

	-- We should handle setting any customised options here in methods. Make sure the options are enabled for them.
end

function _MPI.SpawnAdditionalAIUnits(choice, team) 
	local chosenUnit = nil;

	if (choice == "turrets") then
		chosenUnit = ("%svturr"):format(GetRaceOfTeam(team));
	else
		-- We need to handle specific Gun Tower ODFs here based on the CPU Race.
		chosenUnit = ("%sbgtow"):format(GetRaceOfTeam(team));
	end

	-- Spawn Extra Enemy units. We could probably do this based on difficulty.
	local CPUSpawnCount = {2, 4, 6, 8};

	for i = 1, CPUSpawnCount[CPU_DIFFICULTY + 1] do
		BuildObject(chosenUnit, team, "hold" .. i);
		BuildObject(chosenUnit, team, "gtow" .. i);
	end
end

function _MPI.SetAIPlan(team)
	local planName = nil;
	local planNameBase = "stock13_";

	local pContents = GetCheckedNetworkSvar(3, NETLIST_AIPS);
	if (pContents ~= nil) then
		planNameBase = pContents;
	end

	-- Based on a difficulty IVAR, we can set the difficulty of the AI. ivar70 will need to be changed when this is set up.
	-- Edited to be dynamic for multiple teams. Each team will use the same difficulty.
	planName = ("%s%s_%d.aip"):format(planNameBase, GetRaceOfTeam(team), CPU_DIFFICULTY);

	-- Ensure that at least one CPU unit has spawned before setting the AIP here.
	if (CPU_Spawned) then
		SetAIP(planName, team);
	end
end

-- Use this to iterate through all active AI teams and add scrap cheats based on options.
function _MPI.Update()

end

-- Experimental
function _MPI.HandleAICommander()

end

function _MPI.HandleAIDemolishers()

end

function _MPI.CreateArtifacts()

end

function _MPI.CreateSavageUnits()

end

return _MPI;