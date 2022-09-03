--[[ BZCC FE 3way Mission Script 
Written by JJ (AI_Unit)
Version 1.0 19/11/2019 --]]

-- File find fix.
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

-- Load the core files.
local _FECore = require('_FECore');

-- Spacing distance between each vehicle from the Recycler's spawn point.
local VEHICLE_SPACING_DISTANCE = 20.0

-- How high a player pilot should spawn above their Recycler.
local RespawnPilotHeight = 200.0;

-- How long (in seconds) from noticing gameover, to the actual kicking
-- out back to the shell.
local endDelta = 10.0;

-- Game TPS.
local m_GameTPS = 20;

-- IA Starting Vehicle handles.
local StartingVehicleODFs = 
{
    {"ivturr", "ivturr", "ivscav"},
    {"ivturr", "ivturr", "ivscav", "ivtank", "ivscout", "ivscout"},
    {"ivturr", "ivturr", "ivscav", "ivtank", "ivtank", "ivtank", "ivscout", "ivscout", "ivscout"},
}

local Mission = 
{
    -- Human team.
    m_HumanTeamNum = 1,
    -- CPU team.
    m_CPUTeamNum = 6,
    -- Chosen in IA shell.
    m_Difficulty = 0,
    -- Starting force size for humans.
    m_HumanStartingForceSize = 0,
    -- Start force size for CPU.
    m_CPUStartingForceSize = 0,
    -- Handle game over.
    m_GameOver = false,
    -- If the CPU has an armory.
    m_CPUArmoryPresent = false,
    -- If player respawn is enabled.
    m_PlayerRespawnEnabled = false,
    -- Keep track of each team that is setup.
    m_TeamIsSetUp = { },
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
end

-- Handle when an object is added to the world.
function AddObject(h) 
    -- Call core AddObject method.
    _FECore.AddObject(h);

    -- Grab our important details.
    local teamNum = GetTeamNum(h);
	local ODFName = GetCfg(h);
	local ObjClass = GetClassLabel(h);

    -- Max out human vehicle skill.
    if (IsVehicle(h)) then
        if (teamNum == Mission.m_HumanTeamNum) then
            SetSkill(h, 3);
        elseif (teamNum == Mission.m_CPUTeamNum) then
            SetSkill(h, Mission.m_Difficulty);

            if (Mission.m_CPUArmoryPresent) then
                -- Call method to upgrade weapons.
            end
        end
    end

    -- Check for CPU Armory.
    if (teamNum == Mission.m_CPUTeamNum and ObjClass == "CLASS_ARMORY") then
        Mission.m_CPUArmoryPresent = true;
    end

    -- Per standard FE behaviour, highlight the Service Bay.
    if (teamNum == Mission.m_HumanTeamNum and ObjClass == "CLASS_SUPPLYDEPOT") then
        SetObjectiveOn(h);
    end
end

-- Runs on mission state.
function Start()
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
end

-- Called per tick.
function Update()
    -- Call core AddObject method.
    _FECore.Update();
end

-- Setup any team that as per the number that is passed into this method.
function SetupTeam(Team);
	if ((Team < 1) or (Team >= MAX_TEAMS)) then
		return;
	end

	if (Mission.m_TeamIsSetUp[Team]) then
		return;
	end

	local TeamRace = GetRaceOfTeam(Team);
	local spawnpointPosition = GetSafestspawnpoint();

	-- Store position we created them at for later
	Mission.m_TeamPos[Team] = spawnpointPosition;

	-- Build recycler some distance away, if it's not preplaced on the map.
	if (GetObjectByTeamSlot(Team, DLL_TEAM_SLOT_RECYCLER) == nil) then
		spawnpointPosition = GetPositionNear(spawnpointPosition, VEHICLE_SPACING_DISTANCE, 2 * VEHICLE_SPACING_DISTANCE);
		local VehicleH = BuildObject(GetInitialRecyclerODF(TeamRace), Team, spawnpointPosition);
		SetRandomHeadingAngle(VehicleH);
		Mission.m_RecyclerHandles[Team] = VehicleH;
		SetGroup(VehicleH, 0);
	end

	-- Build all optional vehicles for this team.
	spawnpointPosition = Mission.m_TeamPos[Team]; -- restore default after we modified this for recy above

    -- Give the correct amount of scrap.
	SetScrap(Team, 40);

    -- If this is the CPU team, set an AIP.
    if (Team == Mission.m_CPUTeamNum) then
        SetAIPlan(Team);
    end

	Mission.m_TeamIsSetUp[Team] = true;
end

-- Setup the player.
function SetupPlayer(Team);
	local PlayerH = nil;
	local spawnpointPosition = SetVector(0, 0, 0);

	if ((Team < 0) or (Team >= MAX_TEAMS)) then
		return nil; -- Sanity check... do NOT proceed
	end

    -- This player is their own commander; set up their equipment.
    SetupTeam(Team);

    -- Now put player near his recycler
    spawnpointPosition = Mission.m_TeamPos[Team];
    spawnpointPosition.y = TerrainFindFloor(spawnpointPosition.x, spawnpointPosition.z) + 2.5;

	PlayerH = BuildObject(GetPlayerODF(Team), Team, spawnpointPosition);

	-- Added to make your starting pilot match respawning pilot. -GBD
	local TempODFName = GetRaceOfTeam(Team) .. "spilo";

	SetPilotClass(PlayerH, TempODFName);
	SetRandomHeadingAngle(PlayerH);

	return PlayerH;
end

-- TODO: Move to core to be used universally?
function UpgradeCPUVehicleWeapons(h)
end

-- TODO: Move to core to be used universally?
function CheckCPUWeaponConditions(weaponHandle)
end

-- TODO: Move to core to be used universally?
function SetAIPlan(team)
	local pContents = GetCheckedNetworkSvar(3, NETLIST_AIPS);

    -- If pContents is empty, default to stock AIPs.
	if (pContents ~= nil) then
		planNameBase = "stock13_";
	end

	local planName = ("%s_%s%d.aip"):format(planNameBase, GetRaceOfTeam(team), CPU_DIFFICULTY);

	-- Ensure that at least one CPU unit has spawned before setting the AIP here -- AI_Unit.
	SetAIP(planName, team);
end