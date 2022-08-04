----------------------------------------------------------------
-- FE edf02.lua Mission - Version 1.1 
-- Date Modified: 4/30/2022
-- Summary: Mission script for the EDF02 Forgotten Enemies Mission.
----------------------------------------------------------------

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

-- Variables Not saved. Constants that never change.
local NUM_PORTALS = 5;
local NUM_ATTACKERS = 8;

local Position2 = SetVector( -425, -120, -1480 ); -- -450, -120, -1460 );	--flying dropship start position
local Position3 = SetVector( -575, -155, -1200 ); -- -590, -155, -1190 );	--flying dropship end position
local Position4 = SetVector( 420, 0, 920 );	--deploy base location
local RecyDropshipPositionStart = SetVector(-1045, -178, -450); --start position recydrop
local RecyDropshipPositionStartAdjust = SetVector(-1500, -120, -860); -- facing inward
local RecyDropshipPositionEnd = SetVector(-845, -178, -840); --end position recydrop
local RecyDropshipSpawnRecy = SetVector(-835, -180, -837); --spawn inside dropship
local dropoff = SetVector(0, 60, -5); --dropoff recy
local Routines = {};
local SpawnDelaySTATE = 0;

local M = {
--Mission State
	RoutineState = {},
	RoutineWakeTime = {},
	RoutineActive = {},
	MissionOver = false,
-- Bools
	RecyTeleported = false,
	ScavTeleported = false,
	PlayerTeleported = false,
	StartLanding = false,
	LandingFinished = false,
	TroopGoto = false,
	StateSetup = false,
-- Floats
	StewartNextNagTime = 0.0,
-- Handles
	StayPut = nil,
	Portals = {},
	Recycler = nil,
	Player = nil,
	EnemyScout1 = nil,	--xypos that spawns right after enemy scav
	BaseNav = nil,
	InvestigateNav = nil,
	ScrapPool = nil,
	HadeanScav = nil,
	DropshipFlying = nil,
	DropshipFlyingNorm = nil,
	DropshipLanded = nil,
	RecyDropShip = nil,
	Attackers = {},
	Dino1 = nil,
	Dino2 = nil,
	smoke = nil,
	escort1 = nil, 
	escort2 = nil,
	escort3 = nil,
	escort4 = nil,
	
-- Ints
	TPS = 10,
	StewartNagCounter = 0,
	GunTowersBuilt = 0,
	AttackWave = 0,	--hadean attack wave counter
	AttackIndex = 0,
	maxFrames =0,
	curFrame =0
};

function DefineRoutine(routineID, func, activeOnStart)
	if routineID == nil or Routines[routineID]~= nil then
		error("DefineRoutine: duplicate or invalid routineID: "..tostring(routineID));
	elseif func == nil then
		error("DefineRoutine: func is nil for id "..tostring(routineID), 2);
	else
		Routines[routineID] = func;
		M.RoutineState[routineID] = 0;
		M.RoutineWakeTime[routineID] = 0.0;
		M.RoutineActive[routineID] = activeOnStart;
	end
end

function Advance(routineID, delay)
	routineID = routineID or error("Advance(): invalid routineID.", 2);
	SetState(routineID, M.RoutineState[routineID] + 1, delay);
end

function SetState(routineID, state, delay)
	routineID = routineID or error("SetState(): invalid routineID.", 2);
	delay = delay or 0.0;
	M.RoutineState[routineID] = state;
	M.RoutineWakeTime[routineID] = GetTime() + delay;
end

function Wait(routineID, delay)
	M.RoutineWakeTime[routineID] = GetTime() + delay;
end

function SetRoutineActive(routineID, active)
	M.RoutineActive[routineID] = active;
end

function DefineRoutines()
	DefineRoutine(1, HandleMainState, true);
	DefineRoutine(2, SpawnDinos, true);
	DefineRoutine(3, HandleScavTeleport, true);
	DefineRoutine(4, HandleHadeanAttack, true);
	DefineRoutine(5, HandleStewartNag, false);
end


function InitialSetup()

	_FECore.InitialSetup();
	
	M.TPS = EnableHighTPS();
	AllowRandomTracks(false);
	DefineRoutines();
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadODFs = {
		"stayput",
		"evscout_e02",
		"evtank",
		"evscav",
		"evmislu",
		"evtanku",
		"evmort",
		"ivrecy",
		"ivdrop_sh02",
		"ivdrop_land02",
		"ivpdrop"
	};
	local preloadAudio = {
		"edf02_01.wav",
		"edf02_02.wav",
		"edf02_03.wav",
		"edf02_04.wav",
		"edf02_05.wav",
		"edf02_05A.wav",
		"edf02_06.wav",
		"edf02_07.wav",
		"edf02_08.wav",
		"edf02_09.wav",
		"edf02_10.wav",
		"edf02_11.wav",
		"edf02_12.wav"
	};
	for k,v in pairs(preloadODFs) do
		PreloadODF(v);
	end
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Save()

	_FECore.Save();
	
    return M
end

function Load(...)
	
	_FECore.Load();
	
    if select('#', ...) > 0 then
		M = ...
    end
end

function Start()

	_FECore.Start();
	
	--M.Recycler = GetHandleOrDie("Recycler"); --commented out due to intro scene change moved into HandleMainState check
	M.DropshipLanded = GetHandleOrDie("DropShip"); --original dropship -Gravey
	M.Portals[1] = GetHandleOrDie("Portal1");	--first portal in canyon
	M.Portals[2] = GetHandleOrDie("Portal2");	--recycler portal east of deploy zone
	M.Portals[3] = GetHandleOrDie("Portal3");	--portal beside scrap pool
	M.Portals[4] = GetHandleOrDie("Portal4");	--south east portal
	M.Portals[5] = GetHandleOrDie("Portal5");	--player's portal (southern most one)
	
	--[[
	for i = 1, 5 do
		ClearPortalDest(M.Portals[i], true); -- Lock Portal to script only.
		--M.Portals[i] = GetHandleOrDie(string.format("Portal%d", i));
	end
	--]]
	
	-- Setup initial portl destinations:
	SetPortalDest(M.Portals[1], M.Portals[2]);
	SetPortalDest(M.Portals[2], M.Portals[1]);
	SetPortalDest(M.Portals[3], M.Portals[1]);
	SetPortalDest(M.Portals[4], M.Portals[1]);
	SetPortalDest(M.Portals[5], M.Portals[1]);
	
	M.ScrapPool = GetHandleOrDie("Pool1");
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end


function AddObject(h)
	
	_FECore.AddObject(h);
	
	if GetCfg(h) == "ibgtow" then
		M.GunTowersBuilt = M.GunTowersBuilt + 1;
	elseif GetCfg(h) == "ibrecy" then
		RemoveObject(M.BaseNav);
	end
	
	if GetCfg(h) == "ivrecy" then
		SetPosition(h, RecyDropshipSpawnRecy);
	end
	--update recy position here.
end

function Update()

	_FECore.Update();

	M.Player = GetPlayerHandle();
	for routineID,r in pairs(Routines) do
		if M.RoutineActive[routineID] and M.RoutineWakeTime[routineID] <= GetTime() then
			r(routineID, M.RoutineState[routineID]);
		end
	end
	--HandlePortals();
	CheckStuffIsAlive();
end

--Main mission state
function HandleMainState(R, STATE)
	if STATE == 0 then
		M.escort1 = GetHandle("Tank 1"); --Removed BuildObjectandLabel and instead had them prebuilt in the dropship. - Gravey
		M.escort2 = GetHandle("Scout 1");
		M.escort3 = GetHandle("Scout 2");
		M.escort4 = GetHandle("Scout 3");
		SetGroup(M.escort1, 2);	
		SetGroup(M.escort2, 1);	
		SetGroup(M.escort3, 1);
		SetGroup(M.escort4, 1);
		M.StayPut = BuildObjectAndLabel("stayput", 0, GetTransform(M.Player), "Stayput 1");
		--Stop(M.Recycler, 1);
		StartEarthQuake(10.0);
		M.DropshipFlying = BuildObjectAndLabel("ivdrop_sh02", 0, Position2, "Dropship Flying");
		-- SetObjectiveName(BuildObjectAndLabel("ibnav", 1, Position2), "Position2"); - Not sure why this is needed? - AI_Unit
		SetAnimation(M.DropshipFlying, "Shake", 0);
		Advance(R, 5.0);
	elseif STATE == 1 then
		AudioMessage("edf02_01.wav");	--Pilot:"That blast came awfully close..."
		Advance(R, 3.0);
	elseif STATE == 2 then
		SetAnimation(M.DropshipLanded, "Deploy", 1);
		StartAnimation(M.DropshipLanded);	--open the landed dropship doors while player isn't looking
		CameraReady();
		Advance(R);
	elseif STATE == 3 then
		Move(M.DropshipFlying, 0.0, 30.0, TerrainFloor(Position3));
		if CameraPath("CamPath", 12500, 3200, M.DropshipFlying) 
		or CameraCancelled() then
			CameraFinish();
			Advance(R);
		end
	elseif STATE == 4 then
		AudioMessage("xemt2.wav");
		
		StopEarthQuake();
		
		RemoveObject(M.DropshipFlying);
		
		RemoveObject(M.StayPut);
		
		SetPosition(M.Player, "PlacePlayer");
		SetVelocity(M.Player, SetVector(0, 0, 40));
		
		local escort1 = GetHandle("Tank 1"); --Removed BuildObjectandLabel and instead had them prebuilt in the dropship. - Gravey
		local escort2 = GetHandle("Scout 1");
		local escort3 = GetHandle("Scout 2");
		local escort4 = GetHandle("Scout 3");
		
		SetPosition(escort1, "PlacePlayer"); --need to make these more distributed? - Gravey
		SetVelocity(escort1, SetVector(10, 0, 40));
		SetPosition(escort2, "PlacePlayer");
		SetVelocity(escort2, SetVector(5, 0, 40));
		SetPosition(escort3, "PlacePlayer");
		SetVelocity(escort3, SetVector(15, 0, 40));
		SetPosition(escort4, "PlacePlayer");
		SetVelocity(escort4, SetVector(13, 0, 40));
		
		Advance(R, 1.0);
		
	elseif STATE == 5 then
	
		if not M.StartLanding then
			AudioMessage("edf02_02.wav");	--Stewart:"Good landing under the circumstances..."
		end
		
		DropLand();
		SetScrap(1, 30);
			
		if(GetDistance(M.Recycler, RecyDropshipPositionEnd) > 70.0 and M.LandingFinished  == true) then
			DropLeave();
			
			local escort1 = GetHandle("Tank 1"); --Removed BuildObjectandLabel and instead had them prebuilt in the dropship. - Gravey
			local escort2 = GetHandle("Scout 1");
			local escort3 = GetHandle("Scout 2");
			local escort4 = GetHandle("Scout 3");
			
			Follow(escort1, M.Recycler, 0);
			Follow(escort2, M.Recycler, 0);
			Follow(escort3, M.Recycler, 0);
			Follow(escort4, M.Recycler, 0);
			
			ClearObjectives();
			AddObjective("edf0201.otf", "white");
			
			Advance(R, 10.0);
		end
			
	elseif STATE == 6 then	
	
		SpawnDelaySTATE = 1;
		local Enemy = BuildObjectAndLabel("evscout_e02", 5, "Enemy1", "Hadean Scout 1");
		SetSkill(Enemy, 3);
		SetEjectRatio(Enemy, 0.0);
		Enemy = BuildObjectAndLabel("evscout_e02", 5, "Enemy2", "Hadean Scout 2");
		SetSkill(Enemy, 3);
		SetEjectRatio(Enemy, 0.0);
		
		Advance(R, 3.0);
	elseif STATE == 7 then
		Goto(M.Recycler, "RecyclerPath", 1);
		Advance(R, 30.0);
	elseif STATE == 8 then
		AudioMessage("edf02_03.wav");	--Stewart:"Our scanners just picked up a huge energy spike..."
		M.InvestigateNav = BuildObjectAndLabel("ibnav", 1, "NavSpawn", "Investigate Nav");
		SetObjectiveName(M.InvestigateNav, "Investigate");
		SetObjectiveOn(M.InvestigateNav);
		Advance(R, 220.0);
	elseif STATE == 9 then
		AudioMessage("edf02_04.wav");	--Stewart:"You've got enemy units in the canyon..."
		Advance(R, 5.0);
	elseif STATE == 10 then
		Patrol(BuildObjectAndLabel("evscout_e02", 5, "Spawn2", "Hadean Scout 3"), "Patrol2", 0);
		Advance(R, 5.0);
	elseif STATE == 11 then	--LOC_43
		if GetTime() > 780 then
			Goto(BuildObjectAndLabel("evtank", 5, "Spawn1", "Hadean Xares 1"), "Patrol1", 0);
			Advance(R, 27.0);
		else
			Advance(R);
		end
	elseif STATE == 12 then	--LOC_48
		Goto(BuildObjectAndLabel("evscout_e02", 5, "Spawn1", "Hadean Scout 4"), "Patrol1", 0);
		SetState(R, STATE-1, 48.0);--to LOC_43
	end
end

--handles respawning dinos around player base
function SpawnDinos(R, STATE)
	if GetTime() > 360 then
		if not IsAround(M.Dino1) then
			M.Dino1 = BuildObjectAndLabel("raptor01", 3, "DinoSpawn1", "Raptor 1");
			Goto(M.Dino1, "DinoPatrol1", 0);
		elseif not IsAround(M.Dino2) then
			M.Dino2 = BuildObjectAndLabel("raptor01", 3, "DinoSpawn1", "Raptor 2");
			Goto(M.Dino2, "DinoPatrol1", 0);
		end
	end
end

--spawns in the Hadean Scav and tells it to go through the portal
function HandleScavTeleport(R, STATE)
	if STATE == 0 then
		if GetDistance(M.Player, M.InvestigateNav) < 220 then
			SetObjectiveOff(M.InvestigateNav);
			ClearObjectives();
			AddObjective("edf0206.otf", "white");
			M.HadeanScav = BuildObjectAndLabel("evscav", 5, "EnemyScav", "Hadean Scav");
			SetObjectiveName(M.HadeanScav, "Observe");
			SetObjectiveOn(M.HadeanScav);
			Goto(M.HadeanScav, M.Portals[1], 1);
			Advance(R, 25.0);
		end
	elseif STATE == 1 then
		M.EnemyScout1 = BuildObjectAndLabel("evscout", 5, "Spawn2", "Hadean Scout 5");
		Goto(M.EnemyScout1, M.Portals[1], 0);
		Advance(R, 6.0);
	elseif STATE == 2 then
		if IsAround(M.EnemyScout1) then
			SetObjectiveOn(M.EnemyScout1);
			Advance(R);
		end
	end
end

--Scav teleport and Hadean assault waves
function HandleHadeanAttack(R, STATE)
	if STATE == 0 then
		if M.ScavTeleported then
			Advance(R, 3.0);
		end
	elseif STATE == 1 then
		AudioMessage("edf02_05.wav");	--Stewart:"Good God, that scav just vanished"
		Advance(R, 7.0);
	elseif STATE == 2 then
		SetObjectiveName(M.HadeanScav, "Teleported Harvester");
		SetObjectiveOff(M.HadeanScav);
		Stop(M.HadeanScav, 0);
		SetRoutineActive(5, true);--M.StewartNag = true;
		Advance(R, 900.0);
	elseif STATE == 3 then
		AudioMessage("edf02_08.wav");	--Stewart:"The first enemy squadron is closing in..."
		ClearObjectives();
		AddObjective("edf0210.otf", "white");
		M.HadeanAttackTime = GetTime() + 600.0;
		Advance(R);
	elseif STATE == 4 then	--LOC_94
		if M.HadeanAttackTime < GetTime() then
			SetState(R, STATE + 2, 50.0);--to LOC_104
		elseif M.GunTowersBuilt > 0 then
			M.HadeanAttackTime = M.HadeanAttackTime + 230.0;
			Advance(R);
		end
	elseif STATE == 5 then	--LOC_100
		if M.GunTowersBuilt > 1 or M.HadeanAttackTime < GetTime() then
			Advance(R, 50.0);
		end
	elseif STATE == 6 then	--LOC_104
		AudioMessage("edf02_09.wav");	--Stewart:"The hostiles are just seconds away..."
		ClearObjectives();
		AddObjective("edf0211.otf", "white");
		M.AttackIndex = 1;
		Advance(R);
	elseif STATE == 7 then	--LOC_107
		--Wave 1
		local odfs = {"evtank", "evtanku", "evscout_e02", "evmislu"};
		M.Attackers[M.AttackIndex] = BuildObjectAndLabel(odfs[M.AttackIndex], 5, "Wave1", string.format("Wave 1 Unit %d", M.AttackIndex));
		Goto(M.Attackers[M.AttackIndex], M.Recycler, 1);
		if M.AttackIndex == 4 then
			M.AttackIndex = 1;
			Advance(R, 3.0);
		else
			M.AttackIndex = M.AttackIndex + 1;
			Wait(R, 3.0);
		end
	elseif STATE == 8 then
		--Wave 2
		local odfs = {"evtanku", "evmislu", "evscout_e02", "evmort"};
		M.Attackers[M.AttackIndex+4] = BuildObjectAndLabel(odfs[M.AttackIndex], 5, "Wave2", string.format("Wave 2 Unit %d", M.AttackIndex));
		Goto(M.Attackers[M.AttackIndex+4], M.Recycler, 1);
		if M.AttackIndex == 4 then
			Advance(R, 3.0);
		else
			M.AttackIndex = M.AttackIndex + 1;
			Wait(R, 3.0);
		end
	elseif STATE == 9 then	--LOC_136
		local waveDead = true;
		for i = 1,NUM_ATTACKERS do
			if IsAlive(M.Attackers[i]) and GetTeamNum(M.Attackers[i]) == 5 then
				waveDead = false;
				break;
			end
		end
		if waveDead then
			M.AttackWave = M.AttackWave + 1;
			if M.AttackWave < 3 then
				SetState(R, 7)--to LOC_107
			else
				--Win
				AudioMessage("edf02_10.wav");	--Stewart:"Well done. You've smashed the Hadeans..."
				ClearObjectives();
				AddObjective("edf0205.otf", "green");
				SucceedMission(GetTime() + 18, "edf02W1.txt");
				Advance(R);
			end
		end
	end
end

--Stewart nagging player to go through the portal after the Hadean Scav
function HandleStewartNag(R, STATE)
	if STATE == 0 then	--LOC_259
		AudioMessage("EDF02_05A.wav");	--Stewart:"Try going through that arch."
		ClearObjectives();
		AddObjective("edf0209.otf", "white");
		M.StewartNextNagTime = GetTime() + 30.0;
		Advance(R);
	elseif STATE == 1 then
		if M.StewartNextNagTime < GetTime() then
			if M.StewartNagCounter > 3 then
				AudioMessage("EDF02_12.wav");	--Stewart:"You can't follow simple instructions..."
				FailMission(GetTime() + 12, "EDF02_L2.txt");
				M.MissionOver = true;
				SetState(R, 99);
			else
				AudioMessage("EDF02_05A.wav");	--Stewart:"Try going through the portal"
				M.StewartNagCounter = M.StewartNagCounter + 1;
				M.StewartNextNagTime = GetTime() + 30.0;
			end
		elseif M.PlayerTeleported then
			Advance(R, 3.0);
		end
	elseif STATE == 2 then
		AudioMessage("edf02_06.wav");	--Stewart:"Just as we suspected. It's a portal..."
		Advance(R, 3.0);
	elseif STATE == 3 then
		ClearObjectives();
		AddObjective("edf0207.otf", "white");
		Advance(R);
	elseif STATE == 4 then
		if M.RecyTeleported and GetDistance(M.Player, M.Recycler) < 150 then
			SetObjectiveOn(M.ScrapPool);
			Advance(R, 5.0);
		end
	elseif STATE == 5 then
		AudioMessage("edf02_07.wav");	--Stewart:"You've got incoming Hadeans. Get some GTs up."
		Advance(R);
	end
end

--[[
function HandlePortals()
	for i = 1,NUM_PORTALS do
		local h = GetNearestVehicle(M.Portals[i]);
		if GetDistance(h, M.Portals[i]) < 15 then
			OnPortalDist(M.Portals[i], h);
		end
	end
end
--]]

function PreTeleport(portal, h)
	if portal == M.Portals[1] then
		if GetCfg(h) == "ivrecy" then
			if not M.RecyTeleported and portal == M.Portals[1] then
				SetObjectiveOff(M.Portals[1]);
				M.BaseNav = BuildObjectAndLabel("ibnav", 1, Position4, "Base Location");
				SetObjectiveName(M.BaseNav, "Deploy Base");
				SetBestGroup(M.Recycler);
				SetObjectiveOn(M.BaseNav);
				SetPortalDest(portal, M.Portals[2]); --Teleport(h, M.Portals[2], 30);
				ClearObjectives();
				AddObjective("edf0204.otf", "white");
				M.RecyTeleported = true;
				return PRETELEPORT_ALLOW;
			else
				return PRETELEPORT_DENY;
			end
		elseif IsPlayer(h) then
			M.PlayerTeleported = true;
			SetPortalDest(portal, M.Portals[4]); --Teleport(h, M.Portals[4], 30);
		elseif math.random(1, 2) == 1 then
			SetPortalDest(portal, M.Portals[3]); --Teleport(h, M.Portals[3], 30);
		else
			SetPortalDest(portal, M.Portals[5]); --Teleport(h, M.Portals[5], 30);
		end

		if not M.ScavTeleported and h == M.HadeanScav then
			M.ScavTeleported = true;
		end
	else
		if IsPlayer(h) then
			SetPortalDest(portal, M.Portals[1]); --Teleport(h, M.Portals[1], 30);
		end
	end
	
	return PRETELEPORT_DEFAULT;
end

function PostTeleport(portal, h)

	if GetCfg(h) == "ivrecy" and portal == M.Portals[2] then
		Goto(M.Recycler, M.BaseNav, 0);
		
		return POSTTELEPORT_OVERRIDE;
	end
	
	if GetTeamNum(h) == 5 and portal ~= M.Portals[1] then
		Goto(h, M.Recycler, 0);
		
		return POSTTELEPORT_OVERRIDE;
	end
	
	return POSTTELEPORT_DEFAULT;
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if SpawnDelaySTATE > 0 then --updated to not fail on start
			if not IsAround(M.Recycler) then
				AudioMessage("edf02_11.wav");	--Stewart:"You lost the recycler..."
				ClearObjectives();
				AddObjective("edf0202.otf", "red");
				FailMission(GetTime() + 12, "edf02L1.txt");
				M.MissionOver = true;
			end
		end
	end
end

function DropLand()
	if (M.StartLanding == false and M.StateSetup == false)
	then
		M.RecyDropShip = BuildObjectAndLabel("ivdrop_land02", 1, RecyDropshipPositionStart, "RecyDropShip");
		StartEmitter(M.RecyDropShip, 1);
		StartEmitter(M.RecyDropShip, 2);
		SetAngle(M.RecyDropShip, 90.0);
		StartSoundEffect("droptoff.wav", M.RecyDropShip);
		StartAnimation(M.RecyDropShip);
		SetAnimation(M.RecyDropShip, "land", 1);
		M.maxFrames = SetAnimation(M.RecyDropShip, "land",1);
		M.StartLanding = true;
	
	elseif(M.StartLanding == true and M.StateSetup == false and M.TroopGoto == false) 
	then		
		M.curFrame = GetAnimationFrame(M.RecyDropShip, "land");
		if (M.curFrame == 1 and M.TroopGoto == false) 
		then
			Goto(M.escort1, "Escort1", 0);
			Goto(M.escort2, "Escort2", 0);
			Goto(M.escort3, "Escort3", 0);
			Goto(M.escort4, "Escort4", 0);
			M.TroopGoto = true;
			end
	
	elseif(M.StartLanding == true and M.StateSetup == false and M.StateSetup == false)
	then
		M.curFrame = GetAnimationFrame(M.RecyDropShip, "land");	
		if (M.curFrame >= M.maxFrames-1 and M.StateSetup == false and M.LandingFinished == false) --model has an animation bug and must be cut early.
		then
			M.RecyDropShip = ReplaceObject(M.RecyDropShip, "ivpdrop");
			StartEmitter(M.RecyDropShip, 1);
			StartEmitter(M.RecyDropShip, 2);
			M.maxFrames = SetAnimation(M.RecyDropShip, "deploy", 1);
			local RecySpawn = RecyDropshipSpawnRecy;
			RecySpawn.y = RecySpawn.y - 10;
			M.Recycler = BuildObjectAndLabel("ivrecy",1,RecySpawn, "Recycler");  
			SetAngle(M.Recycler, 90.0);
			SetGroup(M.Recycler, 10);
			StartAnimation(M.RecyDropShip);
			M.LandingFinished = true;
			end	
	end	
	if(M.LandingFinished == true and M.StateSetup == false)
	then
		M.curFrame = GetAnimationFrame(M.RecyDropShip, "deploy");
		if(M.curFrame == 15)
		then
			StartSoundEffect("dropdoor.wav", M.RecyDropShip);
			end	
		if(M.curFrame >= 60)
		then
			Goto(M.Recycler, "RecyDropoff", 1);
			M.StateSetup = true;
			end
		
	end
end

function DropLeave()
	M.maxFrames = SetAnimation(M.RecyDropShip, "takeoff",1);
	M.curFrame = GetAnimationFrame(M.RecyDropShip, "takeoff");
	SetAnimation(M.RecyDropShip,"takeoff",1);
	StartSoundEffect("dropdoor.wav",M.RecyDropShip);
	StartSoundEffect("dropleav.wav", M.RecyDropShip);
	StartAnimation(M.RecyDropShip);
	
	if(M.maxFrames - 1 <= M.curFrame) then
		RemoveObject(M.RecyDropShip);
	end
end

--[[
--work around for flickering caused by calling Move() on a building that was spawned off map (for dropship cutscene)
function Move2(h, r, v, dest)
	local oldTransform = GetTransform(h);
	local oldPos = GetTransform(h).posit;
	local d = dest - oldPos;
	if Length(d) < v / M.TPS then
		local newTransform = BuildDirectionalMatrix(dest);
		SetTransform(h, newTransform);
		SetInterpolablePosition(h, newTransform, oldTransform, true);
		return true;
	else
		local factor = v / (Length(d) * M.TPS);
		local offset = d * factor;
		local newPos = oldPos + offset;
		local newTransform = BuildDirectionalMatrix(newPos);
		SetTransform(h, newTransform);
		SetInterpolablePosition(h, newTransform, oldTransform, true);
		return false;
	end
end
--]]