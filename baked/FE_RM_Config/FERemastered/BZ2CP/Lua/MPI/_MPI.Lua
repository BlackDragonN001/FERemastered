-- New MPI Files for FE
-- Written by General BlackDragon
-- Version 1.1 - 7-29-2023

assert(load(assert(LoadFile("_requirefix.lua")), "_requirefix.lua"))();

local _CrateSpawnHelper = require('_CrateSpawnHelper');
local _MegaBeam = require('_MegaBeamHelper');
local _EasyPools = require('_EasyPoolHelper');
local _RandomPools = require('_RandomPoolHelper');
local _RampageUnits = require('_RampageHelper');
local _CaptureObject = require('_CaptureObjectHelper');
local _Monster = require('_MonsterHelper');
local _PortalUser = require('_PortalUserHelper');

-- VARS
local DEBUG = true;

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
	"pgen1_edf", "pgen2_edf", "pgen3_edf", "pgen4_edf", "factory_edf", "armory_edf", "bunker_edf", "sbay_edf",
	"base_gtow1_edf", "base_gtow2_edf", "base_gtow3_edf", "base_gtow4_edf",
	"training_edf", "tech_edf", "bomber_edf",
	"kiln_scion", "stro_scion", "dowe_scion", "jammer_scion", "base_spire1_scion", "base_spire2_scion",
	"base_spire3_scion", "base_spire4_scion", "ante_scion"
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
	EasyPools = false,
	CaptureObject = false,

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
	HumanScrapCheat = 0,
	CPUScrapCheat = 0,
	FirstAIPSwitchTime = 0, -- ivar26
	TeamRace = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil },
	CPUCommBunkerCount = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	LastCPUPlan = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },

	--New stuff...
	m_Difficulty = 0,
	MonsterDelay = 0,

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
		_PortalUser.Save(),
		MPIMission;
end

-- Load
function _MPI.Load(CrateSpawnerData, MegaBeamData, RampageData, CaptureObjectData, MonsterData, PortalUserData,
				   MPIMissionData)
	-- Load sub moduels.
	_CrateSpawnHelper.Load(CrateSpawnerData);
	_MegaBeam.Load(MegaBeamData);
	_RampageUnits.Load(RampageData);
	_CaptureObject.Load(CaptureObjectData);
	_Monster.Load(MonsterData);
	_PortalUser.Load(PortalUserData);

	-- Load our data.
	MPIMission = MPIMissionData;
end

--[[
	Here is a list of all available custom IVARs.
	-- Original MPI features:
	- ivar 71 - Weapon Caches.
	- ivar  - Rampage units
	- ivar 73 - Capture Objects
	- ivar 74 - Monster Run
	- ivar 75 - Random Pools
	- Poweral Users
	
	- ivar70 - AI Difficulty.
	- ivar72 - Mega Beam
	
	- AI Commander Spawning.
	- AI Super Units.
	- AI Reinforcements.
	- AI Recycler Replacement.
	- AI Demolishers.
	- Savage units.
	- Artifacts.
	- Weapon Caches.
	- Scrap Silos.
]]


-- Initial Setup.
function _MPI.InitialSetup()
	SetAutoGroupUnits(false);

	-- Pull vars from  Shell.
	if (IsNetworkOn()) then
		-- For each team...
		for Team = 1, MAX_TEAMS - 1 do
			-- Setup Races...
			if (Team < CPU_START_TEAM) then -- Player Team(s), 1-5.
				MPIMission.TeamRace[Team] = GetRaceOfTeam(Team);
			elseif (Team == CPU_START_TEAM) then -- CPU first Team 6.
				MPIMission.TeamRace[Team] = string.char(GetVarItemInt("network.session.ivar13"));
			else                        -- CPU Team(s), 7 - 15.
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

		MPIMission.PlayerScrapCheat = GetVarItemInt("network.session.ivar23");

		if (MPIMission.PlayerScrapCheat < 0) then
			MPIMission.PlayerScrapCheat = 0;
		elseif (MPIMission.PlayerScrapCheat > 3) then
			MPIMission.PlayerScrapCheat = 3;
		end

		MPIMission.CPUScrapCheat = GetVarItemInt("network.session.ivar24");

		if (MPIMission.CPUScrapCheat < 0) then
			MPIMission.CPUScrapCheat = 0;
		elseif (MPIMission.CPUScrapCheat > 3) then
			MPIMission.CPUScrapCheat = 3;
		end

		MPIMission.CPUForce = GetVarItemInt("network.session.ivar7");
		MPIMission.NumHumans = CountPlayers();
		MPIMission.m_Difficulty = GetVarItemInt("network.session.ivar70");
		MPIMission.WeaponCrates = (GetVarItemInt("network.session.ivar71") == 1); --36
		MPIMission.MegaBeam = (GetVarItemInt("network.session.ivar72") == 1);
		MPIMission.CaptureObject = (GetVarItemInt("network.session.ivar73") == 1); --39
		MPIMission.MonsterDelay = GetVarItemInt("network.session.ivar74"); --38, 40
		MPIMission.EasyPools = (GetVarItemInt("network.session.ivar75") == 1); --37
		MPIMission.CPUReinforcementTime = SecondsToTurns(200);
		MPIMission.HumanReinforcementTime = SecondsToTurns(250);
	else
		--[[
		M.TWPlayerCheat = IFace_GetInteger("options.instant.int1");
		M.CPUScrapCheat = IFace_GetInteger("options.instant.int2");
		M.TWEnemyTeam2Cheat = IFace_GetInteger("options.instant.int3");

-- TODO: Add me? -GBD
		M.TWRemoveBasePools = IFace_GetInteger("options.instant.int4");
		--]]

		MPIMission.TeamRace[CPU_START_TEAM] = string.char(IFace_GetInteger("options.instant.hisrace"));
		MPIMission.TeamRace[CPU_START_TEAM + CPU2_TEAM_OFFSET] = string.char(IFace_GetInteger("options.instant.int0"));

		MPIMission.m_Difficulty = GetInstantDifficulty(); --IFace_GetInteger("options.play.difficulty");
		MPIMission.CPUForce = GetInstantCompForce();

		MPIMission.WeaponCrates = (IFace_GetInteger("options.instant.bool5") == 1);
		MPIMission.MegaBeam = (IFace_GetInteger("options.instant.bool6") == 1);
		MPIMission.CaptureObject = (IFace_GetInteger("options.instant.bool7") == 1);
		MPIMission.MonsterDelay = IFace_GetInteger("options.instant.int1");
		MPIMission.EasyPools = (IFace_GetInteger("options.instant.bool8") == 1);

		MPIMission.CPUTurretAISkill = MPIMission.m_Difficulty + 1;
		MPIMission.CPUNonTurretAISkill = MPIMission.m_Difficulty + 1;
	end

	if (MPIMission.MegaBeam) then
		_MegaBeam.InitialSetup();
	end

	if (MPIMission.MonsterDelay > 0) then
		_Monster.InitialSetup();
	end

	if (MPIMission.WeaponCrates) then
		_CrateSpawnHelper.InitialSetup();
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
	PreloadODF("cvrecycpu");
end

-- Start, find/save all vars from shell.
function _MPI.Start()
	if (debug) then
		print("CPUForce: ", MPIMission.CPUForce);
		print("NumHumans: ", MPIMission.NumHumans);
		print("m_Difficulty: ", MPIMission.m_Difficulty);
		print("WeaponCrates: ", MPIMission.WeaponCrates);
		print("MegaBeam: ", MPIMission.MegaBeam);
		print("CaptureObject: ", MPIMission.CaptureObject);
		print("MonsterDelay: ", MPIMission.MonsterDelay);
		print("EasyPools: ", MPIMission.EasyPools);
		print("CPUReinforcementTime: ", MPIMission.CPUReinforcementTime);
		print("HumanReinforcementTime: ", MPIMission.HumanReinforcementTime);
	end

	if (MPIMission.EasyPools) then
		_EasyPools.SetupEasyPools();
	end

	if (MPIMission.CaptureObject) then
		_CaptureObject.Setup();
	end

	_RampageUnits.Start();

	SetupExtraVehicles();

	DoTaunt(TAUNTS_GameStart);
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

		if (SkillLevel > 3) then
			SkillLevel = 3;
		end

		SetSkill(h, SkillLevel);

		if ((ObjClass == "CLASS_SCAVENGER") or (ObjClass == "CLASS_SCAVENGERH")) then
			--AddCPUScav(h);
			DoTaunt(TAUNTS_Random);

			-- For the CPU, send the first built Scavenger to the nearest pool.
			if (TurnCounter <= 1) then
				local path = Team .. "_RecyclerEnemy";

				if not DoesPathExist(path) then
					path = "RecyclerEnemy";
				end

				local closestPool = GetNearestObjectByClass(path, "CLASS_DEPOSIT");

				if closestPool ~= nil then
					Goto(h, closestPool, 1);
				end
			end
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
		elseif (stratchoice % 2 == 1) then
			SetCPUAIPlan(CPU_START_TEAM, AIPType2);
		elseif (stratchoice % 2 == 2) then
			SetCPUAIPlan(CPU_START_TEAM, AIPType3);
		end
	end

	_PortalUser.AddObject(h, Team, ObjClass, ODFName, MPIMission.m_Difficulty, MPIMission.NumHumans);
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

		RecyH = BuildStartingVehicle(Team, MPIMission.TeamRace[Team], startRecyODF, "vrecy", "RecyclerEnemy");
	end

	if (RecyH ~= nil) then
		local RecPos = GetPosition(RecyH);
		MPIMission.TeamRace[Team] = GetRace(RecyH);                                                            -- update this in case an AI recy was pre-placed on the map. -GBD

		BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy1");
		BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy2");
		BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy3");
		BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy4");

		if (MPIMission.CPUForce > 3 or MPIMission.CPUForce == -1) then
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", "turr1");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", "turr2");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", "turr3");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy5");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy6");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vsent", "vscout", GetPositionNear(RecPos, 20.0, 40.0)) --"SentryEnemy1");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vsent", "vscout", GetPositionNear(RecPos, 20.0, 40.0)) --"SentryEnemy2");
		end

		if (MPIMission.CPUForce > 51 or MPIMission.CPUForce == -1) then
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", "turr4");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", "turr5");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy7");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy8");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy9");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vturr", "vturr", GetPositionNear(RecPos, 20.0, 40.0)) --"turretEnemy10");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vtank", "vtank", GetPositionNear(RecPos, 20.0, 40.0)) --"tankEnemy1");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vtank", "vtank", GetPositionNear(RecPos, 20.0, 40.0)) --"tankEnemy2");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vtank", "vtank", GetPositionNear(RecPos, 20.0, 40.0)) --"tankEnemy3");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vsent", "vscout", GetPositionNear(RecPos, 20.0, 40.0)) --"SentryEnemy3");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vsent", "vscout", GetPositionNear(RecPos, 20.0, 40.0)) --"SentryEnemy4");
			BuildStartingVehicle(Team, MPIMission.TeamRace[Team], "vsent", "vscout", GetPositionNear(RecPos, 20.0, 40.0)) --"SentryEnemy5");

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
	if (MPIMission.WeaponCrates) then
		_CrateSpawnHelper.Update(MPIMission.m_Difficulty, MPIMission.LateGame);
	end

	if (MPIMission.MegaBeam) then
		_MegaBeam.Update();
	end

	if (MPIMission.CaptureObject) then
		_CaptureObject.Update();
	end

	if (MPIMission.Monster) then
		_Monster.Update(MPIMission.m_Difficulty, CPU_START_TEAM, PLAYER_START_TEAM);
	end

	_RampageUnits.Update(MPIMission.NumHumans, MPIMission.m_Difficulty, MPIMission.SiegeOn, MPIMission.LateGame);
	_PortalUser.Update(MPIMission.NumHumans, MPIMission.m_Difficulty, MPIMission.SiegeOn, MPIMission.AntiAssault,
		MPIMission.LateGame);

	-- This could be enhanced to add some dropship code that'll drop units for the CPU Team via a dropship. - AI_Unit
	-- TODO Make TPS independent. -GBD
	if ((TurnCounter % MPIMission.CPUReinforcementTime) == 0) then
		if (MPIMission.CPUScrapCheat > 1) then
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
	if (MPIMission.CPUScrapCheat == 0) then
		turns = GameTPS * 3; -- 1 scrap every 3 seconds.
	elseif (MPIMission.CPUScrapCheat == 1) then
		turns = GameTPS * 2; -- 1 scrap every 2 seconds.
	elseif (MPIMission.CPUScrapCheat == 2) then
		turns = GameTPS * 1; -- 1 scrap every 1 seconds.
	elseif (MPIMission.CPUScrapCheat == 3) then
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
	if (MPIMission.PlayerScrapCheat == 0) then
		turns = GameTPS * 10; -- 1 scrap every 10 seconds.
	elseif (MPIMission.PlayerScrapCheat == 1) then
		turns = GameTPS * 8; -- 1 scrap every 8 seconds.
	elseif (MPIMission.PlayerScrapCheat == 2) then
		turns = GameTPS * 6; -- 1 scrap every 6 seconds.
	elseif (MPIMission.PlayerScrapCheat == 3) then
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
		local closestEnemyDist = 1000000000; -- Originally 1e30f, changed. AI_Unit

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
				_PortalUser.UpdateTimer(MPIMission.Difficulty, false);
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
			_PortalUser.UpdateTimer(MPIMission.Difficulty, false);
		else
			if ((MPIMission.AntiAssault) and (MPIMission.AssaultCounter < 3)) then
				MPIMission.AntiAssault = false;
				SetCPUAIPlan(CPU_START_TEAM, AIPTypeL);
				_PortalUser.UpdateTimer(MPIMission.Difficulty, true);
			end
		end
	end
end

-- Build Starting Vehicles (ODF1 or ODF2) at a specified location.
function BuildStartingVehicle(aTeam, aRace, ODF1, ODF2, Where, aGrp)
	local length = string.len(ODF1);
	local TempODF = aRace .. string.sub(ODF1, 1, length);
	local Where2 = Where;

	if (not DoesODFExist(TempODF)) then
		-- doesn't exist, so fallback to ODF2
		length = string.len(ODF2);
		TempODF = aRace .. string.sub(ODF2, 1, length);
	end

	-- If we're using a path, make sure it exists.
	if (type(Where) == "string") then
		-- First pass, try to find a team_ version of this path.
		local TeamPathPrefix = "" .. aTeam .. "_";
		Where2 = TeamPathPrefix .. Where;

		-- if it doesn't exist, and this is CPU_START_TEAM, try old school path method.
		if (not DoesPathExist(Where2) and aTeam == CPU_START_TEAM) then
			Where2 = Where;
		end

		if (not DoesPathExist(Where2)) then
			print("ERROR: BuildStartingVehicle Path '" .. Where2 .. "' doesn't exist!");
			return;
		end
	end

	local h = BuildObject(TempODF, aTeam, Where2);

	if (h ~= nil) then
		SetBestGroup(h); -- Set Best group instead. -GBD
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
	local AIPFile = ("%s%s%d_%d.aip"):format(MPIMission.CustomAIPNameBase, MPIMission.TeamRace[Team],
		MPIMission.m_Difficulty, Team);

	if (not DoesFileExist(AIPFile)) then
		print("AIP File '" .. AIPFile .. "' Not found! Trying alternates...");

		AIPFile = ("%s%s_%s.aip"):format(MPIMission.CustomAIPNameBase, MPIMission.TeamRace[Team],
			string.sub(AIPTypeExtensions, Type + 1, Type + 1));

		if (not DoesFileExist(AIPFile)) then
			print("AIP File '" .. AIPFile .. "' Not found! Trying DEFAULT!");
			AIPFile = ("%s%s%s%s.aip"):format(MPIMission.CustomAIPNameBase, MPIMission.TeamRace[Team],
				MPIMission.TeamRace[PLAYER_START_TEAM], string.sub(AIPTypeExtensions, Type + 1, Type + 1));
		end

		MPIMission.LegacyAIPs = true;
	end

	SetAIP(AIPFile, Team);

	MPIMission.LastCPUPlan[Team] = Type;
end

-- TODO: If this is not used by default, change to work like IA BuildStartingVehicle, where it tries race specific version of ODF1, if it doesn't exist, try race specific version of ODF2.
-- i.e. ODF1 = "ivturr", then it'll always pass and replace i with the race letter, or if ODF1 = "ivmbike" and ODF2 = "ivmort", and ODF3 = "fvsent", etc. it'll try those till it finds a match, or won't spawn anything. -GBD
-- Spawns vehicles based on path points
function SetupExtraVehicles()
	local pathNames = GetAiPaths();
	local pathCount = #pathNames;

	_RandomPools.SetupRandomPools(pathNames);

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
				ODF2 = string.sub(Label, Underscore2 + 1, Underscore3 - 1);

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

return _MPI;
