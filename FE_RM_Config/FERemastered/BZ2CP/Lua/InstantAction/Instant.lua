--[[ 
	Summary: BZCC FE Instant Action Mission Script 
	Author: JJ (AI_Unit)
	Version: 1.0 
	Last modified: 03/09/2022 
--]]

-- File find fix.
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

-- Load the core files.
local _FECore = require('_FECore');

-- Spacing distance between each vehicle from the Recycler's spawn point.
local VEHICLE_SPACING_DISTANCE = 20.0

-- How high a player pilot should spawn above their Recycler.
local RespawnPilotHeight = 200.0;

-- How long (in seconds) from noticing gameover, to the actual kicking out back to the shell.
local endDelta = 10.0;

-- Game TPS.
local m_GameTPS = 20;

-- Halt the dispatcher until we're ready.
local StopAddToDispatch = true;

-- IA Starting Vehicle handles.
local StartingVehicleTable = 
{
    {"vturr", "vturr", "vscav"},
    {"vturr", "vturr", "vscav", "vtank", "vscout", "vscout"},
    {"vturr", "vturr", "vscav", "vtank", "vtank", "vtank", "vscout", "vscout", "vscout"},
}

local Mission = 
{
    -- Human team.
    m_HumanTeamNum = 1,

	-- CPU Race.
	m_HumanRace = 'i',

    -- CPU team.
    m_CPUTeamNum = 6,

	-- CPU Race.
	m_CPURace = 'i',

    -- Chosen in IA shell.
    m_Difficulty = 0,

    -- Starting force size for humans.
    m_HumanStartingForceSize = 1,

    -- Start force size for CPU.
    m_CPUStartingForceSize = 1,

    -- Handle game over.
    m_GameOver = false,

    -- If player respawn is enabled.
    m_PlayerRespawnEnabled = false,

	-- To help the CPU, this flag will send the first spawned CPU Scav to a pool before Recycler deployment.
	m_SentFirstCPUScavToPool = false,

	-- Keep track of the maps pools.
	m_MapPools = {},
}

-- Save game data.
function Save()
    return _FECore.Save(), Mission;
end

-- Load game data.
function Load(FECoreData, MissionData)
    -- Enable high TPS.
	m_GameTPS = EnableHighTPS();

    -- Don't auto group units.
	SetAutoGroupUnits(false);

	-- We're a 1.3 DLL.
	WantBotKillMessages();
	
	-- Load sub modules.
	_FECore.Load(FECoreData);

	-- Load mission data.
	Mission = MissionData;
	
	-- Do this for everyone as well.
	CreateObjectives();
end

-- Function for creating and displaying generic objective.
function CreateObjectives()
	ClearObjectives();
	AddObjective("mpobjective_st.otf", "WHITE", -1.0);
end

-- Pre-game initial setup.
function InitialSetup()
    -- Enable high TPS.
	m_GameTPS = EnableHighTPS();

    -- Initiate sub modules.
    _FECore.InitialSetup();

    -- Don't auto group units.
	SetAutoGroupUnits(false);

	-- We're a 1.3 DLL.
	WantBotKillMessages();

	-- Do this for everyone as well.
	CreateObjectives();

	-- Preload some ODFs.
	PreloadODF("ivrecy_c");
	PreloadODF("ivrecy_t");
end

-- Handle when an object is added to the world.
function AddObject(h) 
    -- Call core AddObject method.
    _FECore.AddObject(h);

    -- Grab our important details.
    local teamNum = GetTeamNum(h);
	local ODFName = GetCfg(h);
	local ObjClass = GetClassLabel(h);

    -- Check for CPU Armory.
    if (teamNum == Mission.m_CPUTeamNum) then
		-- Add Dispatcher for CPU units.
		if (not StopAddToDispatch) then
			AddToDispatch(h, 5.0, false, 0, false, false, true, true);
		end

		if (ODFName == "ivcmdr_c") then
			-- Set Commander maximum skill to 3.
			SetSkill(h, 3);
		else 
			-- Set the skill of all enemy units based on IA difficulty.
			SetSkill(h, Mission.m_Difficulty + 1);
		end
    end

    -- Per standard FE behaviour, highlight the Service Bay.
    if (teamNum == Mission.m_HumanTeamNum and ObjClass == "CLASS_SUPPLYDEPOT") then
        SetObjectiveOn(h);
    end

	-- Keep track of the map pools.
	if (teamNum == 0 and ObjClass == "CLASS_DEPOSIT") then
		table.insert(Mission.m_MapPools, h);
	end
end

-- Runs on mission state.
function Start()
	-- Get our difficulty.
	-- Mission.m_Difficulty = GetDifficulty();
	Mission.m_Difficulty = IFace_GetInteger("shell.instant.difficulty");

    -- Remove any trace of old player vehicles left in the BZN.
	local PlayerEntryH = GetPlayerHandle();

	if (PlayerEntryH ~= nil) then
		RemoveObject(PlayerEntryH);
	end

	-- Spawn the CPU.
	SetupCPU(Mission.m_CPUTeamNum);

    -- Rebuild the player.
	local LocalTeamNum = GetLocalPlayerTeamNumber();
	local PlayerH = SetupPlayer(LocalTeamNum);

	SetAsUser(PlayerH, LocalTeamNum);
	AddPilotByHandle(PlayerH);
end

-- Called per tick.
function Update()
    -- Call core AddObject method.
    _FECore.Update();
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
	local PlayerH = BuildObject(GetPlayerODF(Mission.m_HumanTeamNum), Mission.m_HumanTeamNum, spawnpointPosition, Mission.m_HumanStartingForceSize);

	SetPilotClass(PlayerH, Mission.m_HumanRace .. "spilo");
	SetRandomHeadingAngle(PlayerH);

	-- Build recycler some distance away, if it's not preplaced on the map.
	SpawnTeamRecycler(Mission.m_HumanTeamNum, Mission.m_HumanRace, spawnpointPosition);

	-- Spawn extra Human vehicles.
	SpawnTeamExtraVehicles(Mission.m_HumanTeamNum, Mission.m_HumanRace, spawnpointPosition, Mission.m_HumanStartingForceSize);

	-- Give some scrap.
	SetScrap(Mission.m_HumanTeamNum, 40);

	return PlayerH;
end

-- Setup the CPU.
function SetupCPU(Team)
	-- Store the CPU team race.
	Mission.m_CPURace = string.char(IFace_GetInteger("options.instant.hisrace"));

	-- Lua arrays start with an index of 1, not 0, so add + 1 for later use.
	Mission.m_CPUStartingForceSize = IFace_GetInteger("options.instant.computerforce") + 1;

	-- What's our spawn position?
	local spawnpointPosition = GetPosition("RecyclerEnemy");

	-- Build recycler some distance away, if it's not preplaced on the map.
	SpawnTeamRecycler(Mission.m_CPUTeamNum, Mission.m_CPURace, spawnpointPosition);

	-- Give some scrap.
	SetScrap(Team, 40);

	-- Spawn extra CPU vehicles.
	SpawnTeamExtraVehicles(Mission.m_CPUTeamNum, Mission.m_CPURace, spawnpointPosition, Mission.m_CPUStartingForceSize);
	
	-- Set a plan.
	SetAIPlan(Team);
end

-- TODO: Move to core to be used universally?
function SetAIPlan(team)
	-- Check for the custom option first.
	local planName = IFace_GetString("options.instant.string0");

    -- If planName is empty, default to stock AIPs.
	if (planName == nil) then
		planName = "stock13_";
	end

	-- Set our plan name.
	planName = ("%s%s%d.aip"):format(planName, Mission.m_CPURace, Mission.m_Difficulty);

	-- Set the AIP Plans.
	SetAIP(planName, team);
end

-- TODO: Move to core to be used universally?
function GetInitialRecyclerODF(Race);
	local TempODFName = nil;
	local pContents = GetCheckedNetworkSvar(5, NETLIST_Recyclers);

	if ((pContents ~= nil) and (pContents ~= "")) then
		TempODFName = Race .. string.sub(pContents, 2);
	else
		TempODFName = Race .. "vrecy_m";
	end

	return TempODFName;
end

-- TODO: Move to core to be used universally?
function SpawnTeamRecycler(Team, Race, Pos)
	-- Return early.
	if ((Team < 1) or (Team >= MAX_TEAMS)) then
		return;
	end

	-- Return early.
	if (Race == nil) then
		return;
	end

	-- Build the team Recycler.
	if (GetObjectByTeamSlot(Team, DLL_TEAM_SLOT_RECYCLER) == nil) then
		local VehicleH = BuildObject(GetInitialRecyclerODF(Race), Team, GetPositionNear(Pos, VEHICLE_SPACING_DISTANCE, 2 * VEHICLE_SPACING_DISTANCE));
		SetGroup(VehicleH, 0);
	end
end

-- TODO: Move to core to be used universally?
function SpawnTeamExtraVehicles(Team, Race, Pos, Force)
	-- Get the correct amount of units to spawn based on Force parameter.
	local vehicles = StartingVehicleTable[Force];

	-- Loop through each unit to handle their placement.
	for i, v in pairs (vehicles) do
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
		
		-- If the team is the CPU team, append _c to the ODF name.
		if (Team == Mission.m_CPUTeamNum) then
			if (i > 0 and i < 3) then
				pos = GetPosition("turretEnemy" .. i);
			end

			-- Do not include Scavs in this modification otherwise it'll break the
			if (h ~= Race .. "vscav") then
				h = h .."_c";
			end
		end

		-- Finally, build it!
		local vehicle = BuildObject(h, Team, pos);

        -- For the CPU, send the first built Scavenger to the nearest pool.
        if (not Mission.m_SentFirstCPUScavToPool and Team == Mission.m_CPUTeamNum and h ==  Race .. "vscav") then
            -- Find the closest scrap pool to the CPU spawn.
            local closestPool = GetClosestObjectToPath(Mission.m_MapPools, "RecyclerEnemy");

            -- Sent the first Scav that's spawned in to the closest pool.
            Goto(vehicle, closestPool, 1);

            -- So we don't repeat, we only want to do it for the first Scavenger.
            Mission.m_SentFirstCPUScavToPool = true;
        end
	end

	-- If we're the CPU team, spawn turrets around the map based on difficulty.
	if (Team == Mission.m_CPUTeamNum) then
		for i = 1, Mission.m_Difficulty + 2 do
			local h = BuildObject(Race .. "vturr_c", Mission.m_CPUTeamNum, "hold" .. i);

			-- Set Label to stop dispatcher from doing stuff with these units.
			SetLabel(h, "nodispatch");
		end

		-- Allow the dispatcher to continue...
		StopAddToDispatch = false;
	end
end

-- TODO: Move to core to be used universally? 
function GetClosestObjectToPath(listOfUnits, pathPoint)
	local closestObject = nil;
	local closestDistance = nil

	for i, v in pairs (listOfUnits) do
		local dist = GetDistance(v, pathPoint);

		if (closestObject == nil or dist < closestDistance) then
			closestObject = v;
			closestDistance = dist;
		end
	end

	return closestObject;
end