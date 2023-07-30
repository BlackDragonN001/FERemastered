-- New MPI Files for FE 
-- Written by General BlackDragon
-- Version 1.1 - 7-29-2023

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local _CrateSpawnHelper = require('_CrateSpawnHelper');
local _MegaBeam = require('_MegaBeamHelper');
local _EasyPools = require('_EasyPoolHelper');
local _RandomPools = require('_RandomPoolHelper');
local _RampageUnits = require('_RampageHelper');
local _CaptureObject = require('_CaptureObjectHelper');
local _Monster = require('_MonsterHelper');

-- VARS
local DEBUG = true;

local CPU_START_TEAM = 6;
local PLAYER_START_TEAM = 1;

--[[
local CPU_DIFFICULTY = 0;
local CPU_COMMANDER_ENABLED = 0;
local CPU_SUPER_UNITS = 0;
local CPU_REINFORCEMENTS = 0;

local CPU_SCAV_COUNT = 0;
local CPU_MAX_SCAVS = 16;
local MIN_CPU_SCAVS_AFTER_CLEANUP = 5;

local SAVAGE_UNITS = 0;
local ARTIFACTS = 0;
local WEAPON_CACHES = 0;
local SCRAP_SILOS = 0;

local TOTAL_AI_TEAMS = {};
local TOTAL_SPAWN_COUNT = 0;
--]]

local VEHICLE_SPACING_DISTANCE = 20.0;

-- CPU paths for base building.
-- TODO: Rename/export to separate file?
local CPUPaths = 
{
	"pgen1_edf", "pgen2_edf", "pgen3_edf", "pgen4_edf", "factory_edf", "armory_edf", "bunker_edf", "sbay_edf", "base_gtow1_edf", "base_gtow2_edf", "base_gtow3_edf", "base_gtow4_edf",
	"training_edf", "tech_edf", "bomber_edf", 
	"kiln_scion", "stro_scion", "dowe_scion", "jammer_scion", "base_spire1_scion", "base_spire2_scion", "base_spire3_scion", "base_spire4_scion", "ante_scion"
}

-- TABLES
local _MPI = {};

local MPIMission = 
{ 
	-- bools
	LegacyAIPs = false,
	--StartDone = false, 
	SiegeOn = false, 
	AntiAssault = false, 
	LateGame = false, 
	--HaveArmory = false, 
	--IraqiMode = false, 
	PastAIP0 = false, -- true when they've built a recyler building, or we get bored
	
	WeaponCrates = false,
	MegaBeam = false,
	RandomPools = false,
	EasyPools = false,
	CaptureObject = false,
	MonsterToggle = false,
	
	-- handles
	--HumanRecycler = nil, 
	--CPURecycler = nil, 
	--CPUScavList = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, -- List of CPU scav handles, used during cleanup.
	
	-- ints
	--StratTeam = 0, 
	SiegeCounter = 0, 
	AssaultCounter = 0, 
	--TimeCount = 0, 
	CPUReinforcementTime = 0, 
	HumanReinforcementTime = 0, 
	--CPUTeamNumber = 0, 
	--TurnCounter = 0, 
	NumHumans = 0, 
	--NumCPUScavs = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	CPUTurretAISkill = 0, -- ivar21
	CPUNonTurretAISkill = 0, -- ivar22
	HumanForce = 0, 
	CPUForce = 0, 
	FirstAIPSwitchTime = 0, -- ivar26
	TeamRace = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	CPUCommBunkerCount = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	LastCPUPlan = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },

	--New stuff...
	m_Difficulty = 0,


	--CPURecycler = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
	AICommander = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
	AIDemolishers = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
	
	HumanBuildings = {}
};

-- Save
function _MPI.Save()

    return 
		_CrateSpawnHelper.Save(), 
		_MegaBeam.Save(), 
		_RampageUnits.Save(),
		_CaptureObject.Save(),
		_Monster.Save(),
		MPIMission;
end

-- Load
function _MPI.Load(CrateSpawnerData, MegaBeamData, RampageData, CaptureObjectData, MonsterData, MPIMissionData)

	-- Load sub moduels.
	_CrateSpawnHelper.Load(CrateSpawnerData);
	_MegaBeam.Load(MegaBeamData);
	_RampageUnits.Load(RampageData);
	_CaptureObject.Load(CaptureObjectData);
	_Monster.Load(MonsterData);
	
	-- Load our data.
	MPIMission = MPIMissionData;
end

-- Initial Setup.
function _MPI.InitialSetup()

	SetAutoGroupUnits(false);

	-- Pull vars from  Shell.
	if IsNetworkOn() then
	
		-- For each team...
		for Team = 1, MAX_TEAMS-1 do
		
			-- Setup Races...
			if Team < CPU_START_TEAM then
				MPIMission.TeamRace[Team] = GetRaceOfTeam(Team);
			elseif (Team == CPU_START_TEAM) then
				MPIMission.TeamRace[Team] = string.char(GetVarItemInt("network.session.ivar13"));
			else
				-- If an AI is set to spawn on this team...
				local raceVar = IFace_GetInteger("network.session.ivar8" .. Team);
				if (raceVar ~= 0) then
					MPIMission.TeamRace[Team] = string.char(raceVar);
				end
			end
		end

		MPIMission.CPUTurretAISkill = GetVarItemInt("network.session.ivar21");
		if (MPIMission.CPUTurretAISkill < 0) then
			MPIMission.CPUTurretAISkill = 0;
		elseif (MPIMission.CPUTurretAISkill > 3) then
			MPIMission.CPUTurretAISkill = 3;
		end

		MPIMission.CPUNonTurretAISkill = GetVarItemInt("network.session.ivar22");
		if (MPIMission.CPUNonTurretAISkill < 0) then
			MPIMission.CPUNonTurretAISkill = 0;
		elseif (MPIMission.CPUNonTurretAISkill > 3) then
			MPIMission.CPUNonTurretAISkill = 3;
		end

		MPIMission.FirstAIPSwitchTime = GetVarItemInt("network.session.ivar26");
		if (MPIMission.FirstAIPSwitchTime == 0) then
			MPIMission.FirstAIPSwitchTime = SecondsToTurns(180);
		elseif (MPIMission.FirstAIPSwitchTime > 0) then
			MPIMission.FirstAIPSwitchTime = SecondsToTurns(MPIMission.FirstAIPSwitchTime);
		end
		
		MPIMission.HumanForce = GetVarItemInt("network.session.ivar23");
		if (MPIMission.HumanForce < 0) then
			MPIMission.HumanForce = 0;
		elseif (MPIMission.HumanForce > 3) then
			MPIMission.HumanForce = 3;
		end
		
		MPIMission.CPUForce = GetVarItemInt("network.session.ivar24");
		if (MPIMission.CPUForce < 0) then
			MPIMission.CPUForce = 0;
		elseif (MPIMission.CPUForce > 3) then
			MPIMission.CPUForce = 3;
		end

		MPIMission.NumHumans = CountPlayers();
		
		MPIMission.m_Difficulty = GetVarItemInt("network.session.ivar70");
		
		MPIMission.WeaponCrates = GetVarItemInt("network.session.ivar79");
		MPIMission.MegaBeam = GetVarItemInt("network.session.ivar72");
		MPIMission.CaptureObject = GetVarItemInt("network.session.ivar74");
		MPIMission.MonsterToggle = GetVarItemInt("network.session.ivar38");


		MPIMission.CPUReinforcementTime = SecondsToTurns(200);
		MPIMission.HumanReinforcementTime = SecondsToTurns(250);
	else
	
		MPIMission.m_Difficulty = IFace_GetInteger("options.play.difficulty");
		
		MPIMission.TeamRace[CPU_START_TEAM] = string.char(IFace_GetInteger("options.instant.hisrace"));
		
		MPIMission.CPUForce = IFace_GetInteger("options.instant.computerforce") + 1;
		
		MPIMission.CPUTurretAISkill = MPIMission.m_Difficulty + 1;
		MPIMission.CPUNonTurretAISkill = MPIMission.m_Difficulty + 1;
	
	
	end

	if MPIMission.MegaBeam then
		_MegaBeam.InitialSetup();
	end
	
	if MPIMission.MonsterToggle then
		_Monster.InitialSetup();
	end
	
	_RampageUnits.InitialSetup();

	-- Preload some ODFs.
	PreloadODF("evrecy_m");
	PreloadODF("fvrecy_m");
	PreloadODF("ivrecy_m");
	PreloadODF("cvrecycpu");
	PreloadODF("ivrecycpu");
	PreloadODF("evrecycpu");
	PreloadODF("fvrecycpu");
end

--[[
	Here is a list of all available custom IVARs. 
	-- Original MPI features:
	- Weapon Caches.
	- Rampage units
	- Monster Run
	- Capture Objects
	- Random Pools
	- Poweral Users
	
	
	- ivar70 - AI Difficulty.
	- ivar71 - AI Commander Spawning.
	- ivar72 - Mega Beam
	- ivar73 - AI Super Units.
	- ivar74 - AI Reinforcements.
	- ivar75 - AI Recycler Replacement.
	- ivar76 - AI Demolishers.
	- ivar77 - Savage units.
	- ivar78 - Artifacts.
	- ivar79 - Weapon Caches.
	- ivar80 - Scrap Silos.
]]

-- Start, find/save all vars from shell.
function _MPI.Start()	
	
	if MPIMission.EasyPools then
		_EasyPools.SetupEasyPools();
	end
	
	SetupExtraVehicles();
	
	DoTaunt(TAUNTS_GameStart);
	
	if MPIMission.WeaponCrates then
		_CrateSpawnHelper.Start();
	end
	
	if MPIMission.CaptureObject then
		_CaptureObject.Setup();
	end
	
	_RampageUnits.Start();

end

-- AddObject, called from Strategy.lua. -GBD
function _MPI.AddObject(h, IsStartingVehicles, TurnCounter, ODFName, ObjClass)

	local Team = GetTeamNum(h);
	
	-- Add to custom AI dispatcher.
	if (not IsStartingVehicles) then
		AddToDispatch(h, 15.0, false, 0, (MPIMission.m_Difficulty < 2));
	end

	-- generic MPI stuff...
	if (ObjClass == "CLASS_COMMBUNKER" or ObjClass == "CLASS_COMMTOWER") then
		MPIMission.CPUCommBunkerCount[Team] = MPIMission.CPUCommBunkerCount[Team] + 1;
	end
	
	-- If the Recycler was upgraded back into a vehicle, update the recy handle.
	if (ObjClass == "CLASS_RECYCLERVEHICLE" or ObjClass == "CLASS_RECYCLERVEHICLEH") then
		MPIMission.TeamRace[Team] = GetRace(h);
	end
	
	-- CPU Team.
	if (Team >= CPU_START_TEAM) then
		-- CPU Turrt/nonturret skill. Player skill set from Strategy.lua. -GBD
		local SkillLevel = 0;
		
		if (ObjClass == "CLASS_TURRETTANK") then
			SkillLevel = MPIMission.CPUTurretAISkill;
		else
			SkillLevel = MPIMission.CPUNonTurretAISkill;
		end
		
		-- Drop skill by 1 while creating StartingVehicles
		if (IsStartingVehicles) then
			if (SkillLevel > 0) then
				SkillLevel = SkillLevel - 1;
			end
		end
		
		-- Scale up difficulty
		if MPIMission.NumHumans > 2 then
			SkillLevel = 3; -- 3+ players, max skill.
		elseif MPIMission.NumHumans > 1 then
			SkillLevel = SkillLevel + 1;
		end
		
		if SkillLevel > 3 then
			SkillLevel = 3;
		end
		
		SetSkill(h, SkillLevel);
		
		if ((ObjClass == "CLASS_SCAVENGER") or (ObjClass == "CLASS_SCAVENGERH")) then
			--AddCPUScav(h);
			DoTaunt(TAUNTS_Random);
		end
	elseif (Team >= PLAYER_START_TEAM) then
		-- PLAYER Recycler deployed. (Commander or Thug recy) -GBD
		if (ObjClass == "CLASS_RECYCLER") then
			if (not MPIMission.PastAIP0) and (MPIMission.LegacyAIPs) then
				MPIMission.PastAIP0 = true;

				local stratchoice = TurnCounter % 2;

				if (stratchoice == 0) then
					SetCPUAIPlan(CPU_START_TEAM, AIPType1);
				elseif (stratchoice == 1) then
					SetCPUAIPlan(CPU_START_TEAM, AIPType2);
				elseif (stratchoice == 2) then
					SetCPUAIPlan(CPU_START_TEAM, AIPType3);
				end
			end
			
			DoTaunt(TAUNTS_Random);
		else
			if ((ObjClass == "CLASS_ASSAULTTANK") or (ObjClass == "CLASS_WALKER") or (ObjClass == "CLASS_ASSAULTHOVER")) then
				MPIMission.AssaultCounter = MPIMission.AssaultCounter + 1;
			end
		end
	end

	if ((not MPIMission.PastAIP0) and (MPIMission.FirstAIPSwitchTime > 0) and (TurnCounter > MPIMission.FirstAIPSwitchTime) and (MPIMission.LegacyAIPs)) then
		MPIMission.PastAIP0 = true;
		local stratchoice = TurnCounter % 2;

		if (stratchoice % 2 == 0) then
			SetCPUAIPlan(CPU_START_TEAM, AIPType1);
		elseif (stratchoice %2 == 1) then
			SetCPUAIPlan(CPU_START_TEAM, AIPType2);
		elseif (stratchoice %2 == 2) then
			SetCPUAIPlan(CPU_START_TEAM, AIPType3);
		end
	end
end

-- Delete object, called from Strategy.lua -GBD
function _MPI.DeleteObject(h)
	local ObjClass = GetClassLabel(h);
	local Team = GetTeamNum(h);

	if (GetTeamNum(h) < CPU_START_TEAM) then
		if ((ObjClass == "CLASS_ASSAULTTANK") or (ObjClass == "CLASS_WALKER") or (ObjClass == "CLASS_ASSAULTHOVER")) then
			MPIMission.AssaultCounter = MPIMission.AssaultCounter - 1;

			if (MPIMission.AssaultCounter < 0) then
				MPIMission.AssaultCounter = 0;
			end
		end
	else
		if (ObjClass == "CLASS_COMMBUNKER" or ObjClass == "CLASS_COMMTOWER") then
			MPIMission.CPUCommBunkerCount[Team] = MPIMission.CPUCommBunkerCount[Team] - 1;
		end
	end
end

-- Spawns an AI team. Called from Strategy.lua to flag Mission.m_TeamIsSetUp = true;
function _MPI.SetupAITeam(Team)

	local RecyH = GetObjectByTeamSlot(Team, DLL_TEAM_SLOT_RECYCLER);
	 -- If there's no AI Recycler pre-placed on the map, and we are set to have an AI race here, spawn one. -GBD
	if (RecyH == nil) and (MPIMission.TeamRace[Team] ~= 0) then
		local startRecyODF = nil;
		local pContents = nil;
		
		if (IsNetworkOn()) then
			pContents = GetCheckedNetworkSvar(12, NETLIST_Recyclers);
		else
			pContents = IFace_GetString("options.instant.string2");
		end

		if ((pContents ~= nil) and (pContents ~= "")) then
			startRecyODF = pContents;
		else
			startRecyODF = MPIMission.TeamRace[Team] .. "vrecycpu";
		end
		
		local pathName = "RecyclerEnemy_" .. Team;
		if(not DoesPathExist(pathName) and Team == CPU_START_TEAM) then
			pathName = "RecyclerEnemy";
		end

		RecyH = BuildStartingVehicle(Team, MPIMission.TeamRace[Team], startRecyODF, "vrecy", pathName);

	end

	if (RecyH ~= nil) then
		local RecPos = GetPosition(RecyH);
		MPIMission.TeamRace[Team] = GetRace(RecyH); -- update this in case an AI recy was pre-placed on the map. -GBD

		BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy1");
		BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy2");

		if (MPIMission.CPUForce > 0) then
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "bspir", "vturr", "gtow2");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "bspir", "vturr", "gtow3");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vsent", "vscout", GetPositionNear(RecPos, 20.0, 40.0)) --"SentryEnemy1");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vsent", "vscout", GetPositionNear(RecPos, 20.0, 40.0)) --"SentryEnemy2");
		end

		if (MPIMission.CPUForce > 1) then
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "bspir", "vturr", "gtow4");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "bspir", "vturr", "gtow5");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vtank", "vtank", GetPositionNear(RecPos, 20.0, 40.0)) --"tankEnemy1");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vtank", "vtank", GetPositionNear(RecPos, 20.0, 40.0)) --"tankEnemy2");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vtank", "vtank", GetPositionNear(RecPos, 20.0, 40.0)) --"tankEnemy3");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vsent", "vscout", GetPositionNear(RecPos, 20.0, 40.0)) --"SentryEnemy3");
			
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "bjamm", "vturr", "jamm1");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "bjamm", "vturr", "jamm2");
		end

		BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vscav", "vscav", GetPositionNear(RecPos, 20.0, 40.0)) --"ScavengerEnemy");

		if (not MPIMission.PastAIP0) then
			SetCPUAIPlan(Team, AIPType0);
		end

		SetScrap(Team, 40);
		
		return RecyH;
	end

	return nil;
end

-- Do generic strategy, from MPI code
function _MPI.Update(TurnCounter)

	local GameTPS = SecondsToTurns(1.0);
	
	-- Call helper functions.
	if MPIMission.WeaponCrates then
		_CrateSpawnHelper.Update();
	end
	
	if MPIMission.MegaBeam then
		_MegaBeam.Update();
	end
	
	if MPIMission.CaptureObject then
		_CaptureObject.Update();
	end
	
	if MPIMission.Monster then
		_Monster.Update(TurnCounter, MPIMission.m_Difficulty, CPU_START_TEAM, PLAYER_START_TEAM);
	end
	
	_RampageUnits.Update(TurnCounter, MPIMission.NumHumans, MPIMission.m_Difficulty, MPIMission.SiegeOn, MPIMission.LateGame);
	
	
	-- This could be enhanced to add some dropship code that'll drop units for the CPU Team via a dropship. - AI_Unit
	-- TODO Make TPS independent. -GBD
	if ((TurnCounter % MPIMission.CPUReinforcementTime) == 0) then
		if (MPIMission.CPUForce > 1) then
			for i = CPU_START_TEAM, MAX_TEAMS - 1 do
				AddScrap(i, 10);
			end
		end
	end

	-- Count the Human Players every 10 seconds.
	if ((TurnCounter % (10 * GameTPS)) == 0) then
		MPIMission.NumHumans = CountPlayers();
	end

	-- Handle scrap cheat. -GBD
	local turns = 0;
	local amount = 1;
	
	-- CPU Scrap cheat. Multiple teams.
	if (MPIMission.CPUForce == 0) then
		turns = GameTPS * 3; -- 1 scrap every 3 seconds.
	elseif (MPIMission.CPUForce == 1) then
		turns = GameTPS * 2; -- 1 scrap every 2 seconds.
	elseif (MPIMission.CPUForce == 2) then
		turns = GameTPS * 1; -- 1 scrap every 1 seconds.
	elseif (MPIMission.CPUForce == 3) then
		turns = GameTPS / 5; -- 1 scrap every 0.2 seconds (!)
	end
	if ((turns > 0) and (TurnCounter % turns == 0)) then
		for i = CPU_START_TEAM, MAX_TEAMS - 1 do
			AddScrap(i, amount);
		end
	end
	
	-- CPU cheat based on NumHumans.
	if (MPIMission.NumHumans == 1) then
		turns = GameTPS * 1; -- 1 scrap every 1 seconds.
	elseif (MPIMission.NumHumans == 2) then
		turns = GameTPS * 9 / 10; -- 1 scrap every 0.9 seconds.
	elseif (MPIMission.NumHumans == 3) then
		turns = GameTPS * 8 / 10; -- 1 scrap every 0.8 seconds.
	elseif (MPIMission.NumHumans == 4) then
		turns = GameTPS * 7 / 10; -- 1 scrap every 0.7 seconds.
	elseif (MPIMission.NumHumans == 5) then
		turns = GameTPS * 6 / 10; -- 1 scrap every 0.6 seconds.
	end
	if ((turns > 0) and (TurnCounter % turns == 0)) then
		for i = CPU_START_TEAM, MAX_TEAMS - 1 do
			AddScrap(i, amount);
		end
	end

	-- Human scrap cheat.
	if (MPIMission.HumanForce == 0) then
		turns = GameTPS * 10; -- 1 scrap every 10 seconds.
	elseif (MPIMission.HumanForce == 1) then
		turns = GameTPS * 8; -- 1 scrap every 8 seconds.
	elseif (MPIMission.HumanForce == 2) then
		turns = GameTPS * 6; -- 1 scrap every 6 seconds.
	elseif (MPIMission.HumanForce == 3) then
		turns = GameTPS * 4; -- 1 scrap every 4 seconds.
	end
	if ((turns > 0) and (TurnCounter % turns == 0)) then
		AddScrap(PLAYER_START_TEAM, amount);
	end

	-- Old stuff idk if any maps even use, left for backwards compatability. -GBD
	if (TurnCounter % MPIMission.HumanReinforcementTime == 0) then
		BuildObject("apammo", 0, "ammo1");
		BuildObject("apammo", 0, "ammo2");
		BuildObject("apammo", 0, "ammo3");
		BuildObject("aprepa", 0, "repair1");
		BuildObject("aprepa", 0, "repair2");
		BuildObject("aprepa", 0, "repair3");
	end

	-- Only run if using legacy AIPs. -GBD
	if (MPIMission.LegacyAIPs) then
	
		local closestEnemy = 0;
		local closestEnemyDist = 10,00000000; -- Originally 1e30f, changed. AI_Unit

		local RecyH = GetObjectByTeamSlot(CPU_START_TEAM, DLL_TEAM_SLOT_RECYCLER);
		if (IsAround(RecyH)) then
			closestEnemy = GetNearestEnemy(RecyH, true, true, SIEGE_DISTANCE);
		end

		if (closestEnemy ~= 0) then
			closestEnemyDist = GetDistance(closestEnemy, RecyH);
		else
			closestEnemy = 0;
			local FactoryH = GetObjectByTeamSlot(CPU_START_TEAM, DLL_TEAM_SLOT_FACTORY);

			if (IsAround(FactoryH)) then
				closestEnemy = GetNearestEnemy(FactoryH, true, true, SIEGE_DISTANCE);
			end

			if (closestEnemy ~= 0) then
				closestEnemyDist = GetDistance(closestEnemy, FactoryH);
			end
		end

		if (not MPIMission.SiegeOn) then
			if (closestEnemy) then
				MPIMission.SiegeCounter = MPIMission.SiegeCounter + 1;
			else
				MPIMission.SiegeCounter = 0;
			end

			local SiegeTime = 45 * GameTPS;
			if (MPIMission.SiegeCounter > SiegeTime) then
				MPIMission.SiegeOn = true;
				SetCPUAIPlan(CPU_START_TEAM, AIPTypeS);
			end
		else
			if (closestEnemy == 0) then
				SetCPUAIPlan(CPU_START_TEAM, AIPTypeL);

				if (MPIMission.LastCPUPlan == AIPTypeL) then
					MPIMission.SiegeOn = false;
					MPIMission.SiegeCounter = 0;
				end
			end
		end

		if ((not MPIMission.LateGame) and (not MPIMission.SiegeOn) and (not MPIMission.AntiAssault) and (MPIMission.AssaultCounter > 2)) then
			MPIMission.AntiAssault = true;
			SetCPUAIPlan(CPU_START_TEAM, AIPTypeA);
		else
			if ((MPIMission.AntiAssault) and (MPIMission.AssaultCounter < 3)) then
				MPIMission.AntiAssault = false;
				SetCPUAIPlan(CPU_START_TEAM, AIPTypeL);
			end
		end
	end
end



-- Build Starting Vehicles (ODF1 or ODF2) at a specified location.
function BuildStartingVehicle(aTeam, aRace, ODF1, ODF2, Where, aGrp)

	local length = string.len(ODF1);
	local TempODF = aRace .. string.sub(ODF1, 1, length);

	if (not DoesODFExist(TempODF)) then
		-- doesn't exist, so fallback to ODF2
		length = string.len(ODF2);
		TempODF = aRace .. string.sub(ODF2, 1, length);
	end

	-- If we're using a path, make sure it exists.
	if type(Where) == "string" then
		if not DoesPathExist(Where) then
			return;
		end	
	end
	
	local h = BuildObject(TempODF, aTeam, Where);
	
	if (h ~= nil) then
		--if (aGrp == -2) then
			SetBestGroup(h); -- Set Best group instead. -GBD
		--elseif (aGrp >= 0) then
		--	SetGroup(h, aGrp);
		--end
	end
	
	return h;
end

-- Set CPU AI Plan. Expanded to handle multiple teams and legacy AIPs. -GBD
function SetCPUAIPlan(Team, Type)
	if (not CheckedSVar3) then
		CheckedSVar3 = true;

		local pContents = nil;
		
		if (IsNetworkOn()) then
			pContents = GetCheckedNetworkSvar(3, NETLIST_AIPs);
		else
			pContents = IFace_GetString("options.instant.string0");
		end

		if ((pContents == nil) or (pContents == "")) then
			MPIMission.CustomAIPNameBase = "stock_";
		else 
			MPIMission.CustomAIPNameBase = pContents;
		end
	end

	if ((Type < 0) or (Type >= MAX_AIP_TYPE)) then
		Type = AIPType3;
	end

	if (((Type > AIPType3) and (MPIMission.CPUCommBunkerCount[Team] == 0)) and (MPIMission.LastCPUPlan[Team] <= AIPType3)) then
		return;
	end

	-- Based on a difficulty IVAR, we can set the difficulty of the AI. ivar70 will need to be changed when this is set up -- AI_Unit.
	-- Edited to be dynamic for multiple teams. Each team will use the same difficulty -- AI_Unit.
	local AIPFile = ("%s%s%d_%d.aip"):format(MPIMission.CustomAIPNameBase, MPIMission.TeamRace[Team], MPIMission.m_Difficulty, Team);
	
	if not DoesFileExist(AIPFile) then
		AIPFile = ("%s%s_%s.aip"):format(MPIMission.CustomAIPNameBase, MPIMission.TeamRace[Team], string.sub(AIPTypeExtensions, Type + 1, Type + 1));
		
		if not DoesFileExist(AIPFile) then
			AIPFile = ("%s%s%s%s.aip"):format(MPIMission.CustomAIPNameBase, MPIMission.TeamRace[Team], MPIMission.TeamRace[PLAYER_START_TEAM], string.sub(AIPTypeExtensions, Type + 1, Type + 1));
		end
		
		MPIMission.LegacyAIPs = true;
	end
	
	SetAIP(AIPFile, Team);

	MPIMission.LastCPUPlan[Team] = Type;

end

-- TODO: If this is not used by default, change to work like IA BuildStartingVehicle, where it tries race specific versionof ODF1, if it doesn't exist, try race specific version of ODF2.
-- i.e. ODF1 = "ivturr", then it'll always pass and replace i with the race letter, or if ODF1 = "ivmbike" and ODF2 = "ivmort", and ODF3 = "fvsent", etc. it'll try those till it finds a match, or won't spawn anything. -GBD
-- Spawns vehicles based on path points
function SetupExtraVehicles()
	local pathNames = GetAiPaths();
	local pathCount = #pathNames;
	
	if MPIMission.RandomPools then
		_RandomPools.SetupRandomPools(pathNames);
	end

	local CPUTeamRace = MPIMission.TeamRace[CPU_START_TEAM];
	local HumanTeamRace = MPIMission.TeamRace[PLAYER_START_TEAM];
	local length;

	for i = 1, pathCount do
		local Label = pathNames[i];

		if (string.sub(Label, 1, 3) == "mpi") then
			local ODF1 = nil;
			local ODF2 = nil;
			local ODF3 = nil;
			length = string.len(Label);

			local Underscore = string.find(Label, "_");

			if (Underscore == nil) then
				return;
			end

			local Underscore2 = string.find(Label, "_", Underscore + 1);

			if (Underscore2 == nil) then
				ODF1 = string.sub(Label, Underscore + 1, length);
			else
				ODF1 = string.sub(Label, Underscore + 1, Underscore2 - 1);
			end
			
			local Underscore3 = string.find(Label, "_", Underscore2 + 1);
			
			if (Underscore3 == nil) then
				ODF2 = string.sub(Label, Underscore2 + 1, length);
			else
				ODF2 = string.sub(Label,  Underscore2 + 1, Underscore3 - 1);
				
				ODF3 = string.sub(Label, Underscore3 + 1, length);
			end

			if (string.sub(Label, 1, 4) == "mpic") or (string.sub(Label, 1, 4) == "mpiC") then
				if (string.sub(ODF1, 1, 1) == CPUTeamRace) then
					BuildObject(ODF1, CPU_START_TEAM, Label);
				elseif (string.sub(ODF2, 1, 1) == CPUTeamRace) then
					BuildObject(ODF2, CPU_START_TEAM, Label);
				elseif (string.sub(ODF3, 1, 1) == CPUTeamRace) then
					BuildObject(ODF3, CPU_START_TEAM, Label);
				end
			elseif (string.sub(Label, 1, 4) == "mpih") or (string.sub(Label, 1, 4) == "mpiH") then
				local h;
				if (string.sub(ODF1, 1, 1) == HumanTeamRace) then
					h = BuildObject(ODF1, PLAYER_START_TEAM, Label);
					SetBestGroup(h);
				elseif (string.sub(ODF2, 1, 1) == HumanTeamRace) then
					h = BuildObject(ODF2, PLAYER_START_TEAM, Label);
					SetBestGroup(h);
				elseif (string.sub(ODF3, 1, 1) == HumanTeamRace) then
					h = BuildObject(ODF3, PLAYER_START_TEAM, Label);
					SetBestGroup(h);
				end
			end
		end
	end

	-- Scold the map if there are no path points.
	local pathsExist = true;
	
	-- Check if any of the paths listed 
	for i = 1, #CPUPaths do
		local path = CPUPaths[i];

		if (path ~= nil) then
			pathsExist = false;

			for j = 1, #pathNames do
				local aiPath = pathNames[j];
	
				if (aiPath == path) then
					pathsExist = true;
					break;
				end
			end
		end
	end

	-- Post a message to the chat.
	if (not pathsExist) then
		DoTaunt(TAUNTS_NoPath);
	end
	
end



































--[[
-- Add CPU Scav. Old legacy code to prevent AI overbuilding Scavengers... Just let AIP restrict using conditions. -GBD
function AddCPUScav(scavHandle, team)
	if (MPIMission.NumCPUScavs[team] < MAX_CPU_SCAVS) then
		MPIMission.CPUScavList[MPIMission.NumCPUScavs[team] + MPIMission.NumCPUScavs[team] + 1] = scavHandle;
	end

	if (MPIMission.NumCPUScavs[team] < MAX_CPU_SCAVS) then
		return;
	end

	DoTaunt(TAUNTS_Random);

	local newScavList = {};
	local newScavListCount = 0;

	for i = 1, MPIMission.NumCPUScavs[team] do
		local keepIt = false;

		local checkScav = MPIMission.CPUScavList[team][i];
		
		if (IsAround(checkScav) and (GetTeaNum(checkScav) == team) then
			local ObjClass = GetClassLabel(checkScav);
			keepIt = (ObjClass == "CLASS_SCAVENGER") or (ObjClass == "CLASS_SCAVENGERH");
		end

		keepIt = (checkScav == scavHandle);

		if (keepIt) then
			newScavList[newScavListCount + newScavListCount + 1] = checkScav;
		end
	end

	MPIMission.NumCPUScavs[team] = newScavListCount;

	while (MPIMission.NumCPUScavs[team] > MIN_CPU_SCAVS_AFTER_CLEANUP) do
		local i = MPIMission.NumCPUScavs[team] - 1;

		while ((i > 0) and (MPIMission.CPUScavList[i] == scavHandle)) do
			i = i - 1;
		end

		if (MPIMission.CPUScavList[i] == scavHandle) then
			break;
		end

		SetNoScrapFlagByHandle(MPIMission.CPUScavList[i]);
		SelfDamage(MPIMission.CPUScavList[i], 9999);

		MPIMission.NumCPUScavs[team] = MPIMission.NumCPUScavs[team] - 1;
		MPIMission.CPUScavList[MPIMission.NumCPUScavs] = nil;
	end
end\--]]















--[[ AI Unit orginal code.

function _MPI.AddObject(h)
	-- print(tostring(GetCfg(h)) .. "-" .. tostring(GetTeamNum(h)))
	local ObjBaseClass = GetBase(h);
	local ODFName = GetCfg(h);
	local ObjClass = GetClassLabel(h);
	local Team = GetTeamNum(h);

	if (GetTeamNum(h) == CPU_TEAM_NUMBER) then
		if (ObjBaseClass == "Demolisher") then
			AIVehicles.AIDemolishers[#AIVehicles.AIDemolishers + 1] = h;
		elseif (ObjClass == "CLASS_SCAVENGER" or ObjClass == "CLASS_SCAVENGERH") then
			_MPI.AddCPUScav(h);
		elseif (ObjClass == "CLASS_RECYCLERVEHICLE" or ObjClass == "CLASS_RECYCLERVEHICLEH" or ObjClass == "CLASS_RECYCLER") then
			AIVehicles.AIRecycler[Team] = h;
		end
	elseif (GetTeamNum(h) == 1) then
		if (IsBuilding(h)) then
			table.insert(HumanBuildings, h);
		end
	end
end

function _MPI.DeleteObject(h)
	local Team = GetTeamNum(h);
	if (GetCfg(h) == ("%svcmdr_c"):format(GetRaceOfTeam(CPU_TEAM_NUMBER))) then
		AIVehicles.AICommander[Team] = nil;
	end
end

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

	-- Grab a list of all available spawn points.
	TOTAL_SPAWN_COUNT = GetAllSpawnpoints();

	-- Call methods in order.
	_MPI.SpawnAITeams();
	
	if (WEAPON_CACHES == 1) then
		_CrateSpawnHelper.Start();
	end
	
end

function _MPI.Update()

	if (WEAPON_CACHES == 1) then
		_CrateSpawnHelper.Update();
	end

end

function _MPI.SpawnAITeams()
	-- Start at Team 6, as 1 - 5 are players.
	for team = 6, 8 do
		if (team < 6 or 0 == IFace_GetInteger("network.session.ivar8" .. team)) then
			return;
		end

		local AITeamRace = string.char(IFace_GetInteger("network.session.ivar8" .. team));

		-- If Debugging is enabled, we should print all available data related to the AI team
		if (DEBUG) then
			print("Current AITeamRace: (" .. AITeamRace .. ")");
			--Ally(1, team);
		end

		-- If the AI Recycler does not exist, build one for each team.
		if (GetObjectByTeamSlot(team, DLL_TEAM_SLOT_RECYCLER) == nil) then
			AIVehicles.AIRecycler[team] = BuildObject(AITeamRace .. "vrecy_m", team, "Recycler_" .. team);
			SetRandomHeadingAngle(AIVehicles.AIRecycler[team]);
		end

		local pos = GetPosition(AIVehicles.AIRecycler[team]);
		for i = 1, 3 do
		  BuildObject(("%svturr"):format(AITeamRace), team, GetPositionNear(pos, 20.0, 40.0)); --"TurretEnemy" .. i .. "_" .. tostring(team));
		  BuildObject(("%svtank"):format(AITeamRace), team, GetPositionNear(pos, 20.0, 40.0)); --"TankEnemy" .. i .. "_" .. tostring(team));
		end

		-- We could consider a variable here for AI starting forces, and build vehicles based on that.
		-- local AIStartingUnits = GetVarItemInt("network.session.ivar72");

		-- if (AIStartingUnits == 0) then
		-- 	_MPI.SpawnAdditionalAIUnits("turrets", team);
		-- else
		-- 	_MPI.SpawnAdditionalAIUnits("towers", team);
		-- end

		table.insert(TOTAL_AI_TEAMS, team);

		SetGroup(AIVehicles.AIRecycler[team], 0);
		SetScrap(team, 40);

		-- For each active AI team, insert their team number into a table for later use.
		-- Lastly, create the plan for the AI team.
		_MPI.SetAIPlan(team, AITeamRace);
	end

	-- We should handle setting any customised options here in methods. Make sure the options are enabled for them -- AI_Unit.
end

function _MPI.SpawnAdditionalAIUnits(choice, team) 
	local chosenUnit = nil;
	local race = string.char(IFace_GetInteger("network.session.ivar8" .. team));

	if (choice == "turrets") then
		chosenUnit = ("%svturr"):format(race);
	else
		-- We need to handle specific Gun Tower ODFs here based on the CPU Race -- AI_Unit.
		chosenUnit = ("%sbgtow"):format(race);
	end

	-- Spawn Extra Enemy units. We could probably do this based on difficulty -- AI_Unit.
	local CPUSpawnCount = {2, 4, 6, 8};

	for i = 1, CPUSpawnCount[CPU_DIFFICULTY + 1] do
		BuildObject(chosenUnit, team, "hold" .. i .. "_" .. tostring(team));
		BuildObject(chosenUnit, team, "gtow" .. i .. "_" .. tostring(team));
	end
end


-- Use this to iterate through all active AI teams and add scrap cheats based on options -- AI_Unit.
function _MPI.CustomUpdate()
	if (IsAlive(AIVehicles.AIDemolishers[#AIVehicles.AIDemolishers]) and IsIdle(AIVehicles.AIDemolishers[#AIVehicles.AIDemolishers])) then
		_MPI.HandleAIDemolisher(AIVehicles.AIDemolishers[#AIVehicles.AIDemolishers]);
	end
end

-- Experimental
function _MPI.HandleAIDemolisher(h)
	-- Select a target for these units to demolish. Potentially sensitive units, such as Extractors, etc -- AI_Unit.
	local target = HumanBuildings[math.floor(GetRandomFloat(1, #HumanBuildings))];

	if (IsAlive(target)) then
		SetCommand(h, 31, 1, target);
	end
end

function _MPI.CreateArtifacts()

end

function _MPI.CreateSavageUnits()

end

function _MPI.CompareAndRemove(handle, list)
	for i, v in ipairs(list) do
		if v == handle then
			table.remove(list, i)
			break
		end
	end
end
--]]

return _MPI;