-- New MPI Files for FE 
-- Written by JJ (AI_Unit)
-- Version 1.0 - 26/02/2019

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');
local _DLLUtils = require('_DLLUtils');
local _StartingVehicles = require('_StartingVehicles');


local CPU_TEAM_NUMBER = 1; -- DEBUG: NEED TO CHANGE BACK TO 5
local DLL_TEAM_SLOT_RECYCLER = 1;

local NETLIST_Recyclers = 2
local NETLIST_AIPs = 3

local VEHICLE_SPACING_DISTANCE = 20.0;

local _MPI = {};

local AIVehicles = {
	AIRecycler = nil,
};

local AISpawned = false;

-- Utility Methods
function GetInitialRecyclerODF(Race);

	local TempODFName = nil;
	local pContents = _DLLUtils.GetCheckedNetworkSvar(5, NETLIST_Recyclers);
	if((pContents ~= nil) and (pContents[0] ~= '\0'))
	then
		TempODFName = pContents;
	else
		TempODFName = Race .. "vrecy_m";
	end
	return TempODFName;
end

function _MPI.Start()
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

	SetGroup(AIVehicles.AIRecycler, 0);
	SetScrap(CPU_TEAM_NUMBER, 40);

	AISpawned = true;
end

function _MPI.SetAIPlan()
	local planName = nil;
	local planNameBase = "stock13_";

	local pContents = _DLLUtils.GetCheckedNetworkSvar(3, NETLIST_AIPS);
	if (pContents ~= nil) then
		planNameBase = pContents;
	end

	-- Based on a difficulty IVAR, we can set the difficulty of the AI. ivar70 will need to be changed when this is set up.
	planName = ("%s%s_%d.aip"):format(planName, GetRaceOfTeam(CPU_TEAM_NUMBER), GetVarItemInt("network.session.ivar70"));

	if (AISpawned) then
		SetAIP(planName, CPU_TEAM_NUMBER);
	end
end

return _MPI;