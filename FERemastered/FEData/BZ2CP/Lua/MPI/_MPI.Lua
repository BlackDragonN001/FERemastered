-- New MPI Files for FE 
-- Written by JJ (AI_Unit)
-- Version 1.0 - 26/02/2019
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local _FECore = require('_FECore');
local _DLLUtils = require('_DLLUtils');
local _StartingVehicles = require('_StartingVehicles');

-- VARS
local DEBUG = true;

local CPU_TEAM_NUMBER = 1; -- DEBUG: NEED TO CHANGE BACK TO 5
local CPU_DIFFICULTY = 0;
local CPU_Spawned = false;

local VEHICLE_SPACING_DISTANCE = 20.0;

-- TABLES
local _MPI = {};

local AIVehicles = {
	AIRecycler = nil,
};

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
	CPU_DIFFICULTY = GetVarItemInt("network.session.ivar70");

	-- If Debugging is enabled, we should print all available data related to the AI team
	if (DEBUG) then
		print("Current Race of AI Team: (" .. CPU_TEAM_NUMBER .. "): ");
	end

	-- Call methods in order.
	_MPI.SpawnAITeam();
	_MPI.SetAIPlan();
end

function _MPI.Taunt(event)
	DoTaunt(event);
end

function _MPI.SpawnAITeam()
	-- Grab the path point to spawn the Enemy Recycler
	local AISpawnPosition = GetPosition("RecyclerEnemy");
	local AITeamRace = GetRaceOfTeam(CPU_TEAM_NUMBER);
	
	-- If the AI Recycler does not exist, build one for Team 5.
	if (GetObjectByTeamSlot(CPU_TEAM_NUMBER, DLL_TEAM_SLOT_RECYCLER) == nil) then
		AISpawnPosition = GetPositionNear(AISpawnPosition, VEHICLE_SPACING_DISTANCE, 2 * VEHICLE_SPACING_DISTANCE);
		AIVehicles.AIRecycler = BuildObject("ivrecy_m", CPU_TEAM_NUMBER, AISpawnPosition);
		SetRandomHeadingAngle(AIVehicles.AIRecycler);
	end

	-- We could consider a variable here for AI starting forces, and build vehicles based on that.
	local AIStartingUnits = GetVarItemInt("network.session.ivar72");

	if (AIStartingUnits == 0) then
		_MPI.SpawnAdditionalAIUnits("turrets");
	else
		_MPI.SpawnAdditionalAIUnits("towers");
	end

	SetGroup(AIVehicles.AIRecycler, 0);
	SetScrap(CPU_TEAM_NUMBER, 40);

	CPU_Spawned = true;
end

function _MPI.SpawnAdditionalAIUnits(choice) 
	local chosenUnit = nil;

	if (choice == "turrets") then
		chosenUnit = ("%svturr"):format(GetRaceOfTeam(CPU_TEAM_NUMBER));
	else
		-- We need to handle specific Gun Tower ODFs here based on the CPU Race.
		chosenUnit = ("%sbgtow"):format(GetRaceOfTeam(CPU_TEAM_NUMBER));
	end

	-- Spawn Extra Enemy units. We could probably do this based on difficulty.
	if (CPU_DIFFICULTY == 0) then
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "hold1");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "gtow1");
	elseif (CPU_DIFFICULTY == 1) then
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "hold1");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "gtow1");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "hold2");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "gtow2");
	elseif (CPU_DIFFICULTY == 2) then
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "hold1");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "gtow1");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "hold2");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "gtow2");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "hold3");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "gtow3");
	elseif (CPU_DIFFICULTY == 3) then
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "hold1");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "gtow1");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "hold2");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "gtow2");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "hold3");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "gtow3");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "hold4");
		BuildObject(chosenUnit, CPU_TEAM_NUMBER, "gtow4");
	end
end

function _MPI.SetAIPlan()
	local planName = nil;
	local planNameBase = "stock13_";

	local pContents = GetCheckedNetworkSvar(3, NETLIST_AIPS);
	if (pContents ~= nil) then
		planNameBase = pContents;
	end

	-- Based on a difficulty IVAR, we can set the difficulty of the AI. ivar70 will need to be changed when this is set up.
	planName = ("%s%s_%d.aip"):format(planNameBase, GetRaceOfTeam(CPU_TEAM_NUMBER), CPU_DIFFICULTY);

	if (CPU_Spawned) then
		SetAIP(planName, CPU_TEAM_NUMBER);
	end
end

return _MPI;