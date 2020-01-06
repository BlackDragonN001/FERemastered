assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

-- Variables Not saved. Constants that never change.
local NUM_MEGATURRETS = 4;
local NUM_BLOCKAGES = 7;

local Routines = {};

local M = {
--Mission State
	RoutineState = {},
	RoutineWakeTime = {},
	RoutineActive = {},
	MissionOver = false,
-- Bools

-- Floats
	
-- Handles
	Engineer = nil,	--engineer that walks into megapower
	Dropship = nil,
	Player = nil,
	Recycler = nil,
	HadeanRecy = nil,
	MegaPower = nil,
	HadeanScout = nil,
	CutsceneNav = nil,
	CanyonNav = nil,	--canyon blockage nav
	MegaPowerNav = nil,
	CityRuinsNav = nil,
	SatchelPickupNav = nil,
	EngineerTransport = nil,
	Rocks = {},	--canyon blockages
	MegaTurretVictim = nil,
	BaseNav = nil,
	FlightRecorder = nil,
	MegaTurrets = {},
--Vectors
	Position8 = SetVector( -911, 76, -726 ),	--Hadean scout spawn
	Position9 = SetVector( -467, 40, -308 ),	--Hadean scout spawn
	Position12 = SetVector( -624, 59, -1056 ),	--Canyon Nav position
	Position13 = SetVector( 1133, -1, 351 ),	--MegaPower nav position
	Position14 = SetVector( 662, -55, -501 ),	--City Ruins Nav position
	OldPlayerPos = nil,
-- Ints
	TPS = 10,
	endme = 0
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

--gets an object handle by label. If it doesn't exist, throws an error.
function GetHandleOrDie(name)
	return GetHandle(name) or error("Error: object '"..name.."' not found!", 2);
end

function DefineRoutines()
	DefineRoutine(1, HandleMainState, true);
	DefineRoutine(2, HandleDinos, true);
	DefineRoutine(3, RemoveRocks, false);
	DefineRoutine(4, HandleEngineerTransport, false);
	DefineRoutine(5, TeleportPlayer, false);
end


function InitialSetup()

	_FECore.InitialSetup();
	
	M.TPS = EnableHighTPS();
	AllowRandomTracks(false);
	DefineRoutines();
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadODFs = {
		"lneck01",
		"ptera01",
		"ptera02",
		"ptera03",
		"compy01",
		"raptor01",
		"cvhtank",
		"cvhscout",
		"ivcargo"
	};
	local preloadAudio = {
		"edf0301.wav",	
		"edf0302.wav",
		"edf0303.wav",
		"edf0304.wav",
		"edf0305.wav",
		"edf0306.wav",
		"edf0307.wav",
		"edf0307a.wav",
		"edf0308.wav",
		"edf0309.wav",
		"edf0310.wav",
		"edf0311.wav",
		--"edf0312.wav",	//doesn't exist!
		"edf0313.wav",
		"edf0314.wav",
		"edf0315.wav",
		"edf0316.wav",
		"edf0317.wav",
		"edf0318.wav",
		"edf0319.wav",
		"edf0330.wav",
		"edf0331.wav",
		"edf0332.wav"
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

	Ally(2, 3);
	M.Recycler = GetHandleOrDie("myrecycler");
	--M.Player = GetHandleOrDie("player");
	M.Dropship = GetHandleOrDie("dropship");
	M.HadeanRecy = GetHandleOrDie("theirrecycler");
	M.MegaPower = GetHandleOrDie("megapower");
	for i = 1, NUM_MEGATURRETS do
		M.MegaTurrets[i] = GetHandleOrDie(string.format("megaturr%d", i));
	end
	for i = 1, NUM_BLOCKAGES do
		M.Rocks[i] = GetHandleOrDie(string.format("blockage%d", i));
	end
end


function AddObject(h)

	_FECore.AddObject(h);

	--SetSkill(h, 3);
	if GetCfg(h) == "satchel" or GetCfg(h) == "satchel1" then
		GiveWeapon(M.Player, "igjetp");
		if GetDistance(h, M.Rocks[1]) > 100 then
			FailMission(GetTime() + 30, "edf3stupid.des");
			M.MissionOver = true;
		else
			SetRoutineActive(3, true);
		end
	elseif GetCfg(h) == "ibfact" then
		M.FactoryBuilt = true;
	end
end

function Update()

	_FECore.Update();

	M.Player = GetPlayerHandle();
	for routineID,r in pairs(Routines) do
		if M.RoutineActive[routineID] and M.RoutineWakeTime[routineID] <= GetTime() then
			r(routineID, M.RoutineState[routineID]);
		end
	end
	CheckStuffIsAlive();
end

--Main mission state
function HandleMainState(R, STATE)
	if STATE == 0 then
		Stop(M.Recycler, 1);
		Advance(R, 5.0);--10.0
	elseif STATE == 1 then
		SetScrap(1, 40);
		SetAIP("edf3a.aip", 2);
		ClearObjectives();
		AddObjective("edf0301.otf", WHITE);
		AudioMessage("edf0301.wav");	--Stewart:"We're a good 2 clicks from the deployment point"
		M.BaseNav = BuildObjectAndLabel("ibnav", 1, "deploy", "Base Location");
		SetObjectiveName(M.BaseNav, "BASE SITE");
		SetObjectiveOn(M.BaseNav);
		Advance(R, 20.0);
	elseif STATE == 2 then
		M.HadeanScout = BuildObjectAndLabel("evscout", 2, M.Position8, "Hadean Scout 1");
		Attack(M.HadeanScout, M.Recycler, 1);
		AudioMessage("edf0302.wav");	--Stewart:"Heads up. Hostiles incoming."
		Advance(R, 10.0);
	elseif STATE == 3 then	--LOC_41
		AudioMessage("edf0303.wav");	--Stewart:"Keep sharp, Corber"
		Advance(R);
	elseif STATE == 4 then
		if not IsAlive(M.HadeanScout) or GetTeamNum(M.HadeanScout) ~= 2 then
			AudioMessage("edf0304.wav");	--Stewart:"Good shooting, lads"
			Advance(R, 10.0);
		end
	elseif STATE == 5 then
		Attack(BuildObjectAndLabel("evscout", 2, M.Position9, "Hadean Scout 2"), M.Recycler, 1);
		Advance(R, 15.0);
	elseif STATE == 6 then
		AudioMessage("edf0305.wav");	--Stewart:"Hold on Corber, here comes another attack wave"
		Advance(R, 60.0);
	elseif STATE == 7 then
		Attack(BuildObjectAndLabel("evscout", 2, M.Position9, "Hadean Scout 3"), M.Recycler, 1);
		Attack(BuildObjectAndLabel("evscout", 2, "stage1", "Hadean Scout 4"), M.Recycler, 1);
		Advance(R, 60.0);
	elseif STATE == 8 then	--LOC_54
		Attack(BuildObjectAndLabel("evscout", 2, "stage1", "Hadean Scout 5"), M.Recycler, 1);
		Attack(BuildObjectAndLabel("evscout", 2, "stage1", "Hadean Scout 6"), M.Recycler, 1);
		Advance(R);
	elseif STATE == 9 then	--LOC_61
		if IsAround(M.Recycler) and GetCfg(M.Recycler) ~= "ivrecy" then
			SetObjectiveOff(M.BaseNav);
			RemoveObject(M.BaseNav);
			AudioMessage("edf0306.wav");	--Stewart:"Well done. We have a little breathing room now"
			SetAIP("edf3b.aip", 2);
			Advance(R);
		end
	elseif STATE == 10 then	--LOC_67
		if M.FactoryBuilt then
			Advance(R, 200.0);
		end
	elseif STATE == 11 then
		ClearObjectives();
		AddObjective("edf0314.otf", "white");
		AudioMessage("edf0307.wav");	--Stewart:"An APC went down. Get the flight recorder..."
		BuildObjectAndLabel("peapc", 0, "bunker4", "APC");
		M.FlightRecorder = BuildObjectAndLabel("gbag01", 0, "gtow7", "Flight Recorder");
		SetObjectiveName(M.FlightRecorder, "Flight Recorder");
		SetObjectiveOn(M.FlightRecorder);
		Advance(R);
	elseif STATE == 12 then	--LOC_77
		if GetDistance(M.Player, M.FlightRecorder) < 300 then
			AudioMessage("edf0307a.wav");	--Stewart:"Try to pick up that object if you can"
			Advance(R);
		end
	elseif STATE == 13 then	--LOC_81
		if GetDistance(M.Player, M.FlightRecorder) < 5 then
			RemoveObject(M.FlightRecorder);
			AudioMessage("pickup01.wav");
			ClearObjectives();
			AddObjective("edf0302.otf", "white");
			AudioMessage("edf0308.wav");	--Stewart:"Your cargo is extremely important. Get back to base."
			Advance(R);
		end
	elseif STATE == 14 then	--LOC_90
		if GetDistance(M.Player, "deploy") < 150 then
			AudioMessage("edf0309.wav");	--Stewart:"The flight recorder is in bad shape..."
			Advance(R, 150.0);
		end
	elseif STATE == 15 then
		AudioMessage("edf0310.wav");	--Stewart:"Head to canyon nav and grab satchel"
		Advance(R, 5.0);
	elseif STATE == 16 then
		ClearObjectives();
		AddObjective("edf0303.otf", "white");
		M.CanyonNav = BuildObjectAndLabel("ibnav", 1, M.Position12, "Canyon Nav");
		SetObjectiveName(M.CanyonNav, "Canyon Blockage");
		SetObjectiveOn(M.CanyonNav);
		BuildObjectAndLabel("apsatc", 1, "satchelspawn3", "Satchel Pack");
		M.SatchelPickupNav = BuildObjectAndLabel("ibnav", 1, "satchelspawn3", "Satchel Pack Nav");
		SetObjectiveOn(M.SatchelPickupNav);
		SetObjectiveName(M.SatchelPickupNav, "pack explosive");
		Advance(R);
	elseif STATE == 17 then	--LOC_106
		if GetDistance(M.Player, M.CanyonNav) < 100 then
			SetObjectiveOff(M.CanyonNav);
			SetObjectiveOff(M.SatchelPickupNav);
			Advance(R);
		end
	elseif STATE == 18 then	--LOC_111
		if not IsAround(M.Rocks[1]) then
			ClearObjectives();
			AddObjective("edf0304.otf", "white");
			AudioMessage("edf0311.wav");	--Stewart:"Our map shows abandoned structures at the other end of the canyon..."
			RemoveObject(M.SatchelPickupNav);
			RemoveObject(M.CanyonNav);
			M.CityRuinsNav = BuildObjectAndLabel("ibnav", 1, M.Position14, "City Ruins Nav");
			SetObjectiveName(M.CityRuinsNav, "cityruins");
			SetObjectiveOn(M.CityRuinsNav);
			Advance(R);
		end
	elseif STATE == 19 then	--LOC_121
		if GetDistance(M.Player, M.CityRuinsNav) < 150 then
			RemoveObject(M.CityRuinsNav);
			ClearObjectives();
			AddObjective("edf0305.otf", "white");
			--AudioMessage("edf0312.wav");	//missing?
			Advance(R, 30.0);
		end
	elseif STATE == 20 then
		AudioMessage("edf0330.wav");	--Cervelli:"These new enemies are emitting anomalous readings..."
		Advance(R, 30.0);
	elseif STATE == 21 then
		AudioMessage("edf0331.wav");	--Cervelli:"We've finally managed to get some useful readings on the unknowns..."
		Advance(R, 30.0);
	elseif STATE == 22 then
		AudioMessage("edf0313.wav");	--Stewart:"We've just picked up a power surge east of the city"
		SetRoutineActive(5, true);
		CameraReady();
		Advance(R);
	elseif STATE == 23 then
		if CameraPath("megacam", 1000, 1200, M.MegaPower) or CameraCancelled() then
			CameraFinish();
			M.MegaPowerNav = BuildObjectAndLabel("ibnav", 1, M.Position13, "Mega Power Nav");
			ClearObjectives();
			AddObjective("edf0306.otf", "white");
			SetObjectiveName(M.MegaPowerNav, "power disturbance");
			SetObjectiveOn(M.MegaPowerNav);
			Advance(R);
		end
	elseif STATE == 24 then	--LOC_142
		if GetDistance(M.Player, M.MegaPowerNav) < 50 then
			SetObjectiveOff(M.MegaPowerNav);
			ClearObjectives();
			AddObjective("edf0307.otf", "white");
			Advance(R);
		end
	elseif STATE == 25 then
		if IsInfo("ebmgen") then
			ClearObjectives();
			AddObjective("edf0307.otf", "green");
			AudioMessage("edf0314.wav");	--Stewart:"Good work. We've got a clear scan of the structure"
			Advance(R, 10.0);
		end
	elseif STATE == 26 then
		SetTeamNum(M.MegaPower, 0);
		SetRoutineActive(4, true);--M.SpawnEngTransport = true;
		Advance(R, 60.0);
	elseif STATE == 27 then
		AudioMessage("edf0332.wav");	--Cervelli:"The unknowns are interfering with our scans..."
		Advance(R);
	elseif STATE == 28 then
		if GetDistance(M.EngineerTransport, M.MegaPower) < 150 then
			SetTeamNum(M.MegaPower, 1);
			M.Engineer = BuildObjectAndLabel("ispilo", 1, GetPosition(M.EngineerTransport), "Engineer Transport");
			Goto(M.Engineer, M.MegaPower, 1);
			Advance(R, 25.0);--30.0
		end
	elseif STATE == 29 then
		RemoveObject(M.Engineer);
		SetTeamNum(M.MegaPower, 1);
		for i = 1, NUM_MEGATURRETS do
			SetTeamNum(M.MegaTurrets[i], 1);
		end
		SetAIP("edf3c.aip", 2);
		AudioMessage("edf0316.wav");	--Stewart:"You've captured the megapower. The gate defenses are on our side now..."
		SetObjectiveOff(M.EngineerTransport);
		ClearObjectives();
		AddObjective("edf0311.otf", "white");
		M.MegaTurretVictim = BuildObjectAndLabel("evtank", 2, "spawnvictim", "Mega Turret Victim");
		Attack(M.MegaTurretVictim, M.MegaTurrets[3], 1);
		SetRoutineActive(5, true);
		CameraReady();
		Advance(R);
	elseif STATE == 30 then
		if not IsAround(M.MegaTurretVictim) 
		or CameraPath("victimcam", 3000, 1800, M.MegaTurretVictim) 
		or CameraCancelled() then
			CameraFinish();
			RemoveObject(M.MegaTurretVictim);
			Advance(R, 15.0);
		end
	elseif STATE == 31 then
		ClearObjectives();
		Advance(R, 120.0);
	elseif STATE == 32 then
		AudioMessage("edf0316a.wav");	--Cervelli:"Incoming energy beam..."
		BuildObjectAndLabel("kaboom", 2, "deploy");
		BuildObjectAndLabel("kaboom", 2, "deploy");
		BuildObjectAndLabel("kaboom", 2, "deploy");
		Advance(R, 28.0);
	elseif STATE == 33 then
		M.BaseDestroyed = true;
		ClearObjectives();
		BuildObjectAndLabel("g3beamd", 2, "deploy");
		AudioMessage("edf0317.wav");	--Stewart:"<PAIN> We've just been hit..."
		AddObjective("edf0313.otf", "white");
		M.CutsceneNav = BuildObjectAndLabel("ibnav", 1, "deploy", "Cutscene Nav");
		SetRoutineActive(5, true);
		CameraReady();
		Advance(R);
	elseif STATE == 34 then
		if CameraPath("recyclercam", 2000, 1000, M.CutsceneNav) or CameraCancelled() then
			CameraFinish();
			RemoveObject(M.Recycler);
			RemoveObject(M.CutsceneNav);
			ClearObjectives();
			AddObjective("edf0308.otf", "white");
			Advance(R, 30.0);
		end
	elseif STATE == 35 then
		AudioMessage("edf0318.wav");	--Cervelli:"We're evacuating survivors. Take out the Hadean base..."
		Advance(R);
	elseif STATE == 36 then
		if not IsAround(M.HadeanRecy) then
			AudioMessage("edf0319.wav");	--Cervelli:"Good work commander..."
			SucceedMission(GetTime() + 23, "edf3win.des");
			Advance(R);
		end
	end
end

--spawns dinos around map, spawns in Cerb "Unknown" units by ruins, deploys Recycler once it reaches the deploy site
function HandleDinos(R, STATE)
	if STATE == 0 then
		SetAnimation(M.Dropship, "takeoff", 1);
		StartAnimation(M.Dropship);
		Advance(R, 15.0);
	elseif STATE == 1 then
		RemoveObject(M.Dropship);
		Goto(M.Recycler, "recyclerpath", 1);
		Patrol(BuildObjectAndLabel("lneck01", 0, "brontopath", "Bronto 1"), "brontopath", 1);
		Patrol(BuildObjectAndLabel("lneck01", 0, "brontopath2", "Bronto 2"), "brontopath2", 1);
		for i = 1,3 do
			Patrol(BuildObjectAndLabel("ptera01", 0, "pterosaur1", "Ptero 1"), "pterosaur1", 1);
		end
		for i = 1,4 do
			Patrol(BuildObjectAndLabel("ptera02", 0, "pterosaur2", "Ptero 2"), "pterosaur2", 1);
		end
		for i = 1,5 do
			Patrol(BuildObjectAndLabel("ptera03", 0, "pterosaur3", "Ptero 3"), "pterosaur3", 1);
		end
		for i = 1,6 do
			Patrol(BuildObjectAndLabel("compy01", 9, "littledino1", "Little Dino 1"), "littledino1", 1);
		end
		Advance(R, 15.0);
	elseif STATE == 2 then
		Patrol(BuildObjectAndLabel("raptor01", 9, "dino1"), "dino1", 1);
		Advance(R, 15.0);
	elseif STATE == 3 then
		Patrol(BuildObjectAndLabel("raptor01", 9, "dino1"), "dino1", 1);
		--changed Cerb units from team 2 to team 3, since they
		--were driving across the map and attacking player's base!
		Patrol(BuildObjectAndLabel("cvhtank", 3, "cerberi1", "Cerberi 1"), "cerberi1", 1);
		Patrol(BuildObjectAndLabel("cvhtank", 3, "cerberi1", "Cerberi 2"), "cerberi1", 1);
		Patrol(BuildObjectAndLabel("cvhscout", 3, "cerberi1", "Cerberi 3"), "cerberi1", 1);
		Advance(R, 2.0);
	elseif STATE == 4 then
		Patrol(BuildObjectAndLabel("cvhscout", 3, "cerberi1", "Cerberi 4"), "cerberi1", 1);
		Advance(R, 2.0);
	elseif STATE == 5 then
		Patrol(BuildObjectAndLabel("cvhscout", 3, "cerberi1", "Cerberi 5"), "cerberi1", 1);
		Advance(R);
	elseif STATE == 6 then
		if GetCurrentCommand(M.Recycler) == 0 then
			Dropoff(M.Recycler, "deploy", 1);
			Advance(R);
		end
	end
end

--Removes canyon boulders once satchel charge goes off
function RemoveRocks(R, STATE)
	if STATE == 0 then
		Advance(R, 30.0);
	elseif STATE == 1 then
		BuildObjectAndLabel("satchelmine", 2, GetPosition(M.Rocks[5]), "Satchel Mine");
		for i = 1,NUM_BLOCKAGES do
			RemoveObject(M.Rocks[i]);
		end
		IFace_Activate("ai.calccliffs");
		Advance(R);
	end
end

--code for spawning eng transport and it following the player
function HandleEngineerTransport(R, STATE)
	if STATE == 0 then
		M.EngineerTransport = BuildObjectAndLabel("ivcargo", 1, "engineerspawn", "Engineer Transport");
		Stop(M.EngineerTransport, 1);
		SetObjectiveOn(M.EngineerTransport);
		AddObjective("edf0309.otf", "white");
		AudioMessage("edf0315.wav");
		Advance(R, 20.0);
	elseif STATE == 1 then
		M.EngineerTransportArrived = true;
		Advance(R);
	elseif STATE == 2 then	--LOC_340
		if GetDistance(M.EngineerTransport, M.MegaPower) < 500 then
			Goto(M.EngineerTransport, M.MegaPower, 1);
			Advance(R);
		elseif GetDistance(M.Player, M.EngineerTransport) > 300
		and GetCurrentCommand(M.EngineerTransport) ~= 0 then
			Stop(M.EngineerTransport, 1);
		elseif GetDistance(M.Player, M.EngineerTransport) < 300
		and GetCurrentCommand(M.EngineerTransport) == 0 then
			Follow(M.EngineerTransport, M.Player, 1);
		end
	end
end

--temporarily moves player somewhere safe during camera cutscenes
function TeleportPlayer(R, STATE)
	if STATE == 0 then
		M.OldPlayerPos = GetTransform(M.Player);
		SetPosition(M.Player, "engineerspawn");
		Advance(R, 12.0);
	elseif STATE == 1 then
		SetTransform(M.Player, M.OldPlayerPos);
		SetState(R, 0);
		SetRoutineActive(R, false);
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if not IsAround(M.MegaPower) then
			FailMission(GetTime() + 5, "edf3mega.des");
			M.MissionOver = true;
		elseif not M.BaseDestroyed and not IsAround(M.Recycler) then
			FailMission(GetTime() + 5, "edf3recy.des");
			M.MissionOver = true;
		elseif M.EngineerTransportArrived and not IsAround(M.EngineerTransport) then
			FailMission(GetTime() + 5, "edf3eng.des");
			M.MissionOver = true;
		end
	end
end