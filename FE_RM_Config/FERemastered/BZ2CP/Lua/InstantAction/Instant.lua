--[[ 
	Summary: BZCC FE Instant Action Mission Script 
	Author: JJ (AI_Unit)
	Version: 1.0 
	Last modified: 21/09/2022 
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

-- IA Starting Vehicle handles.
local StartingVehicleTable = 
{
    {"vturr", "vturr", "vscav"},
    {"vturr", "vturr", "vscav", "vtank", "vscout", "vscout"},
    {"vturr", "vturr", "vscav", "vtank", "vtank", "vtank", "vscout", "vscout", "vscout"},
}

-- Pilot weapon randomisation for the enemy Commander.
local CommanderPilotWeapons = 
{
	["EDF"] = {"igbzka_c", "igshot_c", "igsnip_c"},
	["Scion"] = {"fgbzka_c", "fgsnip_c"},
	["Hadean"] = {}
}

-- Packs randomisation for the enemy Commander.
local CommandPilotPacks = 
{
	["EDF"] = {"igjetp", "iggren"},
	["Scion"] = {"fgjetp", "fggren"},
	["Hadean"] = {}
}

-- CPU paths for base building.
local CPUPaths = 
{
	"pgen1_edf", "pgen2_edf", "pgen3_edf", "pgen4_edf", "factory_edf", "armory_edf", "bunker_edf", "sbay_edf", "base_gtow1_edf", "base_gtow2_edf", "base_gtow3_edf", "base_gtow4_edf",
	"training_edf", "tech_edf", "bomber_edf", "kiln_scion", "stro_scion", "dowe_scion", "jammer_scion", "base_spire1_scion", "base_spire2_scion", "base_spire3_scion", "base_spire4_scion",
	"ante_scion"
}

-- Let's spice things up with the AI kicking off if no base building paths are found.
local NoPathsResponse = 
{
	"Hey, map maker, where are my paths man?!",
	"Seriously?! I have to randomize my base?",
	"What's a CPU gotta do to get some paths around here?",
	"No base paths? Sure...",
	"It was silly of me to expect any paths.",
	"Don't blame me if my base looks bad.",
	"I'm sensing some laziness.",
	"If you're expecting well-placed buildings, don't.",
	"What's the key combination for self-destruction?"
}

local Mission = 
{
    m_HumanTeamNum = 1,     -- Human team.
	m_HumanRace = 'i', 	-- CPU Race.
    m_CPUTeamNum = 6,     -- CPU team.
	m_CPURace = 'i', 	-- CPU Race.
    m_Difficulty = 0,     -- Chosen in IA shell.
	m_RespawnEnabled = 0, 	-- Chosen in IA shell.
    m_HumanStartingForceSize = 1,     -- Starting force size for humans.
    m_CPUStartingForceSize = 1,     -- Start force size for CPU.
    m_GameOver = false,     -- Handle game over.
	m_SetFirstAIP = false,     -- For SetPlan() taunts.
    m_PlayerRespawnEnabled = false,     -- If player respawn is enabled.
	m_SentFirstCPUScavToPool = false, 	-- To help the CPU, this flag will send the first spawned CPU Scav to a pool before Recycler deployment.
	m_StopAddToDispatch = true, 	-- Halt the dispatcher until we're ready. This must be Saved so things will work correctly on a Load.
	m_EnemyRecycler = nil, -- CPU Recycler.
	m_Recycler = nil, -- Human Recycler.
	m_MapPools = {}, 	-- Keep track of the maps pools.
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

	-- Want to trigger ObjectKilled for AI units.
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
	AddObjective("InstantAction.otf", "WHITE", -1);
end

-- Pre-game initial setup.
function InitialSetup()
    -- Enable high TPS.
	m_GameTPS = EnableHighTPS();

    -- Initiate sub modules.
    _FECore.InitialSetup();

    -- Don't auto group units.
	SetAutoGroupUnits(false);

	-- Want to trigger ObjectKilled for AI Units.
	WantBotKillMessages();

	-- Preload some ODFs.
	PreloadODF("ivrecy_m");
	PreloadODF("fvrecy_m");
	PreloadODF("evrecy_m");
end

-- Handle when an object is added to the world.
function AddObject(h) 
    -- Call core AddObject method.
    _FECore.AddObject(h);

    -- Grab our important details.
    local teamNum = GetTeamNum(h);
	local ODFName = GetCfg(h);
	local ObjClass = GetClassLabel(h);
	
	-- Add Dispatcher for CPU units. (Include even players units, in case an AI enemy pilot hops into an empty ship. -GBD)
	if (not Mission.m_StopAddToDispatch) then
		AddToDispatch(h, 15.0, false, 0, false, false, true, true);
	end

    -- Check CPU stuff.
    if (teamNum == Mission.m_CPUTeamNum) then		
		--Spice things up.
		if (ObjClass == "CLASS_RECYCLER") then
			-- Be mean. (Moved to Recy deployment so Objectives don't hide it. -GBD
			DoTaunt(TAUNTS_GameStart);
		elseif(ObjClass == "CLASS_SCAVENGER") or (ObjClass == "CLASS_SCAVENGERH") then
			DoTaunt(TAUNTS_Random);
		end

		-- CPU "Commander" pilots.
		if (ODFName == (Mission.m_CPURace .. "vcmdr_c") or ODFName == (Mission.m_CPURace .. "scmdr_c")) then
			SetSkill(h, 3); -- Set Commander maximum skill to 3.

			-- TODO: Make the above check only for PARTIAL match, skip first RACE letter (only works for ISDF atm) -GBD
			-- Also maybe just use a _config.odf?
			if (ODFName == (Mission.m_CPURace .. "scmdr_c")) then
				local selectedWeaponsTable;
				local selectedPackTable;

				if (Mission.m_CPURace == "e") then -- Enemy is Hadean?
					selectedWeaponsTable = CommanderPilotWeapons["Hadean"];
					selectedPackTable = CommandPilotPacks["Hadean"];
				elseif (Mission.m_CPURace == "f") then -- Enemy is Scion?
					selectedWeaponsTable = CommanderPilotWeapons["Scion"];
					selectedPackTable = CommandPilotPacks["Scion"];
				else -- Default to 'i'
					selectedWeaponsTable = CommanderPilotWeapons["EDF"];
					selectedPackTable = CommandPilotPacks["EDF"];
				end

				local wepChance = math.floor(GetRandomFloat(1, #selectedWeaponsTable));
				local packChance = math.floor(GetRandomFloat(1, #selectedPackTable));

				local wep = selectedWeaponsTable[wepChance];
				local pack = selectedPackTable[packChance];
				
				GiveWeapon(h, wep);
				GiveWeapon(h, pack);
			end
		else 
			-- Set the skill of all enemy units based on IA difficulty.
			SetSkill(h, Mission.m_Difficulty + 1);

			-- Replace the CPU natural extractor as we're using a different ODF.
			-- Remind me to poke this later... -GBD
			if (ODFName == "ibscav") then
				ReplaceObject(h, "ibscav_c");
			elseif (ODFName == "fbscav") then
				ReplaceObject(h, "fbscav_c");
			end
		end
    elseif (teamNum == Mission.m_HumanTeamNum) then
		if (ObjClass == "CLASS_SUPPLYDEPOT") then -- Did original FE do this? -GBD
			SetObjectiveOn(h);
		end
	elseif (teamNum == 0) then
		-- Keep track of the map pools.
		if (ObjClass == "CLASS_DEPOSIT") then
			table.insert(Mission.m_MapPools, h);
		end
	end
end

-- Runs on mission state.
function Start()
	-- Teams for Stats...
	-- TODO? expose to Options? -GBD
	SetTeamNameForStat(Mission.m_HumanTeamNum, "Humans");
	SetTeamNameForStat(Mission.m_CPUTeamNum, "Computer");
	-- SetTauntCPUName(""); -- To set the CPU Taunt team name to something custom. -GBD

	-- Get our difficulty.
	Mission.m_Difficulty = IFace_GetInteger("shell.instant.difficulty");

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
	
	-- Spawn the CPU.
	SetupCPU(Mission.m_CPUTeamNum);
	
	-- Put up Objectives.
	CreateObjectives();
end

-- Called per tick.
function Update()
    -- Call core AddObject method.
    _FECore.Update();
	
	-- Test win conditions.
	-- TestGameOver();
end

-- Handle win conditions.
function TestGameOver()
	if (not Mission.m_GameOver) then
		if (not IsAround(Mission.m_EnemyRecycler)) then	
			local tempH = GetObjectByTeamSlot(Mission.m_CPUTeamNum, DLL_TEAM_SLOT_RECYCLER);
			
			if (tempH ~= nil) then
				Mission.m_EnemyRecycler = tempH; -- Save it.
			else
				DoTaunt(TAUNTS_CPURecyDestroyed);
				SucceedMission(GetTime() + 5.0, "instantw.txt");
				Mission.m_GameOver = true;
			end
		end
		
		if (not IsAround(Mission.m_Recycler)) then
			local tempH = GetObjectByTeamSlot(Mission.m_HumanTeamNum, DLL_TEAM_SLOT_RECYCLER);
			
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
	local PlayerH = BuildObject(Mission.m_HumanRace .. "vscout", Mission.m_HumanTeamNum, spawnpointPosition, Mission.m_HumanStartingForceSize);

	SetPilotClass(PlayerH, Mission.m_HumanRace .. "spilo");
	SetRandomHeadingAngle(PlayerH);

	-- Build recycler some distance away, if it's not preplaced on the map.
	Mission.m_Recycler = SpawnTeamRecycler(Mission.m_HumanTeamNum, Mission.m_HumanRace, spawnpointPosition);
	SetGroup(Mission.m_Recycler, 0);

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
	Mission.m_EnemyRecycler = SpawnTeamRecycler(Mission.m_CPUTeamNum, Mission.m_CPURace, spawnpointPosition);
	SetGroup(Mission.m_EnemyRecycler, 0);

	-- Spawn extra CPU vehicles.
	SpawnTeamExtraVehicles(Mission.m_CPUTeamNum, Mission.m_CPURace, spawnpointPosition, Mission.m_CPUStartingForceSize);
	
	-- Give some scrap.
	SetScrap(Team, 40);
	
	-- Set a plan.
	SetAIPlan(Team);

	-- Scold the map if there are no path points.
	local paths = GetAiPaths();
	local pathsExist = true;

	-- Check if any of the paths listed 
	for i = 1, #CPUPaths do
		local path = CPUPaths[i];

		if (path ~= nil) then
			pathsExist = false;

			for j = 1, #paths do
				local aiPath = paths[j];
	
				if (aiPath == path) then
					pathsExist = true;
					break;
				end
			end
		end
	end

	-- Post a message to the chat.
	if (not pathsExist) then
		AddToMessagesBox("Computer: " .. NoPathsResponse[math.floor(GetRandomFloat(1, #NoPathsResponse))]);
	end
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
	
	if (m_SetFirstAIP) then
		DoTaunt(TAUNTS_Random);
	end
	
	m_SetFirstAIP = true;
end

-- TODO: Move to core to be used universally?
function GetInitialRecyclerODF(Race);
	local TempODFName = nil;
	local pContents = GetCheckedNetworkSvar(2, NETLIST_Recyclers);

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
	
	local VehicleH = nil;

	-- Build the team Recycler.
	if (GetObjectByTeamSlot(Team, DLL_TEAM_SLOT_RECYCLER) == nil) then
		VehicleH = BuildObject(GetInitialRecyclerODF(Race), Team, GetPositionNear(Pos, VEHICLE_SPACING_DISTANCE, 2 * VEHICLE_SPACING_DISTANCE));
	end
	
	return VehicleH;
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
		Mission.m_StopAddToDispatch = false;
	end
end

-- TODO: Move to core to be used universally? 
function GetClosestObjectToPath(listOfUnits, pathPoint)
	local closestObject = nil;
	local closestDistance = 9999999999;

	for i, v in pairs (listOfUnits) do
		local dist = GetDistance(v, pathPoint);

		if (dist < closestDistance) then
			closestObject = v;
			closestDistance = dist;
		end
	end

	return closestObject;
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
			return DoEjectPilot;
		end
	end

	-- Local player got killed (pilot or snipe). Do respawn as needed.
	if (Mission.m_RespawnEnabled) then
		-- Respawn them near their m_Recycler, up in the air.
	else
		-- User can't respawn. Game over, man
		FailMission(GetTime() + 3);
	end

	-- Both cases of the above report that we handled things.
	return DLLHandled;
end

-- Handle destroyed objects...
function ObjectKilled(deadObjectHandle, killersHandle)
	-- AI-controlled object is toast...
	if (not IsPlayer(deadObjectHandle)) then
		-- Should we eject a pilot instead?
		if (not IsPerson(deadObjectHandle)) then
			return DoEjectPilot; -- Return DoEjectPilot.
		else
			return DLLHandled; -- Return DLLHandled.
		end
	else
		-- Handle player death.
		return PlayerDied(deadObjectHandle, false);
	end
end

-- Handle sniped objects...
function ObjectSniped(deadObjectHandle, killersHandle)
	if (not IsPlayer(deadObjectHandle)) then
		return DLLHandled; -- AI-controlled object is toast...
	else
		return PlayerDied(deadObjectHandle, true); -- Player dead.
	end
end