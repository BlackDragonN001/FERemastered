assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

-- Variables Not saved. Constants that never change.
local NUM_PORTALS = 6;
local NUM_GUARDIANS = 4;
local NUM_KRULS = 5;
local NUM_TURRETS1 = 4;
local NUM_TURRETS2 = 4;

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
	MegaGun,
	MegaGuard1,
	MegaGuard2,
	Portals = {},
	CutsceneTarget,	--"stick" in final megagun cutscene
	Recycler,
	Player,
	EngineerTransport,
	Dropship,
	Engineer,
	Turrets1 = {},
	Turrets2 = {},
	Kruls = {},
	HadeanGuardianTurrets = {}, --hadean base guardian turrets
	BaseNav,
	MegaGunNav,
	HadeanBaseNav,
	NavDelta,
-- Ints
	TPS = 10,
	MegaGuardIndex = 0,
	endme = 0
}

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
	DefineRoutine(1, HandleIntro, true);
	DefineRoutine(2, HandleMainState, true);
	DefineRoutine(3, SpawnKruls, false);
	DefineRoutine(4, SpawnTurrets, false);
	DefineRoutine(5, DestroyMegaturrets, false);
	DefineRoutine(6, HandleRecyclerRetreat, false);
	DefineRoutine(7, HandleMegaGunRetaliate, true);
end


function InitialSetup()

	_FECore.InitialSetup();

	M.TPS = EnableHighTPS();
	AllowRandomTracks(false);
	
	DefineRoutines();
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadODFs = {
		"cvhtank",
		"cvhscout"
	};
	local preloadAudio = {
		"edf0401.wav",
		"edf0402.wav",
		"edf0403.wav",
		"edf0404.wav",
		"edf0405.wav",
		"edf0406.wav",
		"edf0407.wav",
		"edf0408.wav",
		"edf0409.wav",
		"edf0410.wav",
		"edf0411.wav",
		"edf0412.wav",
		"edf0413.wav",
		"edf0414.wav",
		"edf0415.wav",
		"edf0416.wav",
		"edf0417.wav",
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
	
	Ally(1, 2);
	M.MegaGun = GetHandleOrDie("Mega Gun");
	M.MegaGuard1 = GetHandleOrDie("MGD1");
	M.MegaGuard2 = GetHandleOrDie("MGD2");
	M.Recycler = GetHandleOrDie("unnamed_ivrecy");
	M.EngineerTransport = GetHandleOrDie("Tran1");
	M.Dropship = GetHandleOrDie("Drop3");
	for i = 1, NUM_PORTALS do
		M.Portals[i] = GetHandleOrDie(string.format("Portal%d", i));
			ClearPortalDest(M.Portals[i], true); -- Lock Portal to script only.
	end	
	for i = 1, NUM_GUARDIANS do
		M.HadeanGuardianTurrets[i] = GetHandleOrDie(string.format("ET%d", i));
	end
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end


function AddObject(h)

	_FECore.AddObject(h);
	
	--SetSkill(h, 3);
	if GetCfg(h) == "ibfact_s" then
		Attack(TeleportIn("cvhtank", 6, M.Portals[4], 20), h, 1);
	elseif GetCfg(h) == "ibgtow" then
		Attack(TeleportIn("cvhscout", 6, M.Portals[2], 20), h, 1);
	elseif GetCfg(h) == "ibpgen" then
		Attack(TeleportIn("cvhscout", 6, M.Portals[4], 20), h, 1);
	elseif GetCfg(h) == "ibsbay" then
		SetObjectiveOn(h);
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

--Builds 3 Hadean turrets by base site, lifts off dropship, and spawns birds
function HandleIntro(R, STATE)
	if STATE == 0 then
		BuildObject("evturr", 6, "path_5");
		BuildObject("evturr", 6, "path_6");
		BuildObject("evturr", 6, "path_7");
		SetAnimation(M.Dropship, "takeoff", 1);
		StartAnimation(M.Dropship);
		Advance(R, 15.0);
	elseif STATE == 1 then
		RemoveObject(M.Dropship);
		Patrol(BuildObject("ptera02", 0, "aniwalk1"), "aniwalk1", 1);
		Patrol(BuildObject("ptera03", 0, "aniwalk2"), "aniwalk2", 1);
		Patrol(BuildObject("herbiv01", 0, "aniwalk3"), "aniwalk3", 1);
		BuildObject("compy01", 0, "anidrink1");
		BuildObject("compy01", 0, "anidrink3");
		BuildObject("raptor01", 0, "anidrink2");
		Advance(R);
	end
end

--Main mission state
function HandleMainState(R, STATE)
	if STATE == 0 then
		SetScrap(1, 40);
		AudioMessage("edf0401.wav");	--Windex:"Attention Spartacus task force..."
		SetObjectiveOn(M.EngineerTransport);
		CameraReady();
		Advance(R);
	elseif STATE == 1 then
		if CameraPath("rcam", 1500, 2000, M.Recycler) or CameraCancelled() then
			CameraFinish();
			AddObjective("edf0401.otf", "white");
			M.BaseNav = BuildObject("ibnav", 1, "bss");
			SetObjectiveName(M.BaseNav, "Base Site");
			SetObjectiveOn(M.BaseNav);
			--SetAIP("edf04a.aip", 6);	--causes Hadeans to rush Player before they set up the Recycler
			Advance(R);
		end
	elseif STATE == 2 then	--LOC_46
		if IsOdf(M.Recycler, "ibrecy_s") then
			if GetDistance(M.Recycler, M.BaseNav) > 200 then
				AudioMessage("edf0402.wav");	--Windex:"You were clearly ordered to deploy near the nav beacon..."
				FailMission(GetTime() + 10, "edf04l2.des");
				SetState(R, 99);
			else
				RemoveObject(M.BaseNav);
				ClearObjectives();
				AddObjective(_Te"edf0410.otf"xt10, "white");
				M.HadeanBaseNav = BuildObject("ibnav", 1, "ebs");
				SetObjectiveName(M.HadeanBaseNav, "Hadean Base");
				SetObjectiveOn(M.HadeanBaseNav);
				AudioMessage("edf0403.wav");	--Skyeye:"We've pinpointed the Hadean stronghold..."
				Advance(R, 10.0);
			end
		end
	elseif STATE == 3 then
		AddObjective("edf0402.otf", "white");
		AudioMessage("edf0404.wav");	--Skyeye:"We've found the Mega Gun location..."
		M.MegaGunNav = BuildObject("ibnav", 1, "mgs");
		SetObjectiveName(M.MegaGunNav, "Mega Gun");
		SetObjectiveOn(M.MegaGunNav);
		SetAIP("edf04b.aip", 6);
		SetRoutineActive(3, true);
		SetRoutineActive(4, true);
		Advance(R);
	elseif STATE == 4 then	--LOC_69
		if GetDistance(M.Player, M.MegaGunNav) < 250 then
			AudioMessage("edf0405.wav");	--O'Ryan:"Interesting, the Guardian turrets seem to be inactive..."
			Advance(R);
		end
	elseif STATE == 5 then	--LOC_79
		if GetDistance(M.EngineerTransport, M.MegaGun) < 75 then
			Stop(M.EngineerTransport, 1);
			M.Engineer = BuildObject("ispilo", 1, GetPosition(M.EngineerTransport));
			SetObjectiveName(M.Engineer, "Engineer");
			SetObjectiveOn(M.Engineer);
			SetObjectiveOff(M.MegaGun);
			SetObjectiveOff(M.MegaGunNav);
			SetObjectiveOff(M.EngineerTransport);
			Goto(M.Engineer, M.MegaGun, 0);
			Advance(R);
		end
	elseif STATE == 6 then	--LOC_90
		if GetDistance(M.Engineer, M.MegaGun) < 40 then
			RemoveObject(M.Engineer);
			ClearObjectives();
			AddObjective("edf0403.otf", "green");
			AudioMessage("edf0406.wav");	--O'Ryan:"I'm inside the megagun..."
			Advance(R, 15.0);
		end
	elseif STATE == 7 then
		ClearObjectives();
		AddObjective("edf0402.otf", "green");
		AddObjective("edf0404.otf", "white");
		AudioMessage("edf0407.wav");	--O'Ryan:"Yes! The megagun is online..."
		SetTeamNum(M.MegaGun, 1);
		SetTeamNum(M.MegaGuard1, 1);
		SetTeamNum(M.MegaGuard2, 1);			
		Advance(R, 10.0);
	elseif STATE == 8 then
		AudioMessage("edf0408.wav");	--Windex:"Good work O'Ryan..."
		SetAIP("edf04c.aip", 6);
		Advance(R);
	elseif STATE == 9 then	--LOC_107
		if GetScrap(1) >= 110 then
			AudioMessage("edf0409.wav");	--Skyeye:"We've just detected a massive energy spike on the planet Athena..."
			ClearObjectives();
			AddObjective("edf0405.otf", "red");
			Advance(R, 60.0);
		end
	elseif STATE == 10 then
		BuildObject("mbbeam", 9, "mgbbb");
		BuildObject("mbfire", 9, "mgbbb");
		BuildObject("mbrocks", 9, "mgbbb");
		Advance(R, 15.0);
	elseif STATE == 11 then
		AudioMessage("edf0410.wav");	--Windex:"That was far too close..."
		ClearObjectives();
		AddObjective("edf0404.otf", "white");
		Advance(R);
	elseif STATE == 12 then	--LOC_119
		if GetScrap(1) >= 160 then
			AudioMessage("edf0411.wav");	--Skyeye:"Well done engineering crew. The first shot is away..."
			CameraReady();
			Advance(R);
		end
	elseif STATE == 13 then
		if CameraPath("cam1", 5000, 2000, M.MegaGun) or CameraCancelled() then
			CameraFinish();
			SetScrap(1, 0);
			ClearObjectives();
			AddObjective("edf0404.otf", "green");
			SetRoutineActive(7, true);--M.HadRetaliate = true;
			AudioMessage("edf0413.wav");	--Skyeye:"We're picking up substantial energy pulsations.."
			Advance(R);
		end
	elseif STATE == 14 then	--LOC_130
		if GetScrap(1) >= 160 then
			CameraReady();
			Advance(R);
		end
	elseif STATE == 15 then
		if CameraPath("cam2", 5000, 2000, M.MegaGun) or CameraCancelled() then
			CameraFinish();
			SetScrap(1, 0);
			ClearObjectives();
			AddObjective("edf0406.otf", "green");
			Advance(R, 5.0);
		end
	elseif STATE == 16 then
		AudioMessage("edf0414.wav");	--Skyeye:"We just wiped out the megagun on planet Troy..."
		AddObjective("edf0407.otf", "white");
		SetAIP("edf04d.aip", 6);
		SetRoutineActive(7, true);--M.HadRetaliate = true;
		Goto(M.EngineerTransport, M.MegaGunNav, 1);
		M.CuttingItCloseTime = GetTime() + 1200;
		Advance(R);
	elseif STATE == 17 then
		if M.CuttingItCloseTime < GetTime() then
			AudioMessage("edf0415.wav");	--Skyeye:"The Hadeans are powering up the Alexandria Megagun..."
			StartCockpitTimer(300);
			Advance(R);
		elseif GetScrap(1) >= 160 then
			SetState(R, 19);--to LOC_152
		end
	elseif STATE == 18 then	--LOC_147
		if GetCockpitTimer() == 0 then
			--player took too long. Mission failed
			local pos1 = GetPosition(M.MegaGun) + SetVector(0, 10, 0);
			local pos2 = GetPosition(M.MegaGun) + SetVector(0, 15, 0);
			M.CutsceneTarget = BuildObject("stick", 0, pos1);
			BuildObject("mbbeam", 9, pos2);
			BuildObject("mbfire", 9, pos2);
			CameraReady();
			SetState(R, 199);
		elseif GetScrap(1) >= 160 then
			StopCockpitTimer();
			Advance(R);
		end
	elseif STATE == 19 then	--LOC_152
		AudioMessage("edf0416.wav");	--O'Ryan:"Fire!"
		SetRoutineActive(6, true);--M.RecyclerRetreat = true;
		local pos = GetPosition(M.MegaGun) + SetVector(0, 10, 0);
		M.CutsceneTarget = BuildObject("stick", 0, pos);
		SetRoutineActive(5, true);--M.DestroyMegaturrets = true;
		CameraReady();
		Advance(R);
	elseif STATE == 20 then
		if CameraPath("cam3", 5000, 2500, M.CutsceneTarget) or CameraCancelled() then
			--CameraFinish();
			RemoveObject(M.CutsceneTarget);
			Advance(R);
		end
	elseif STATE == 21 then
		if CameraPathDir("mtcam", 3000, 3000) or CameraCancelled() then
			--CameraFinish();
			M.CutsceneTarget = GetHandle("FN");
			Advance(R);
		end
	elseif STATE == 22 then
		if CameraPath("dtcam", 5000, 1750, M.CutsceneTarget) or CameraCancelled() then
			CameraFinish();
			RemoveObject(M.CutsceneTarget);
			SetScrap(1, 0);
			ClearObjectives();
			AddObjective("edf0411.otf", "white");
			AudioMessage("edf0417.wav");
			SetRoutineActive(3, false);--M.SpawnTurrets = false;
			SetRoutineActive(4, false);--M.SpawnKruls = false;
			M.NavDelta = BuildObject("ibnav", 1, "NGTE");
			SetObjectiveName(M.NavDelta, "Nav Delta");
			SetObjectiveOn(M.NavDelta);
			Advance(R);
		end
	elseif STATE == 23 then	--LOC_173
		if GetDistance(M.Recycler, M.NavDelta) < 30 
		and GetDistance(M.Player, M.NavDelta) < 75 then
			ClearObjectives();
			AddObjective("edf0411.otf", "green");
			SucceedMission(GetTime() + 10, "edf04w1.des");
			Advance(R);
		end
	elseif STATE == 199 then	--LOC_180
		if CameraPath("cam3", 5000, 2500, M.CutsceneTarget) or CameraCancelled() then
			CameraFinish();
			RemoveObject(M.CutsceneTarget);
			FailMission(GetTime() + 2, "edf04l4.des");
			Advance(R);
		end
	end
end

--spawns the megagun beam that destroys the MegaGun, then destroys the 4 Guardian turrets at the Hadean base
function DestroyMegaturrets(R, STATE)
	if STATE == 0 then
		Advance(R, 11.0);--9.0
	elseif STATE == 1 then
		local pos = GetPosition(M.MegaGun) + SetVector(0, 15, 0);
		BuildObject("mbbeam", 9, pos);
		BuildObject("mbfire", 9, pos);
		Advance(R, 11.0);--14.0
	elseif STATE == 2 then
		EjectPilot(M.MegaGuard1);
		EjectPilot(M.MegaGuard2);
		M.MegaGuardIndex = 1;
		Advance(R, 3.0);
	elseif STATE == 3 then
		EjectPilot(M.HadeanGuardianTurrets[M.MegaGuardIndex]);
		M.MegaGuardIndex = M.MegaGuardIndex + 1;
		if M.MegaGuardIndex > NUM_GUARDIANS then
			Advance(R);
		else
			Wait(R, 2.0);
		end
	end
end

--every 220s, respawns 5 patrolling Kruls near center pool
function SpawnKruls(R, STATE)
	local patrols = {"STDpath","STDpath","STDpath","STDs1","STDs2"};
	for i = 1,NUM_KRULS do
		if not IsAround(M.Kruls[i]) then
			M.Kruls[i] = TeleportIn("cvhtank", 6, M.Portals[6], 30);
			Patrol(M.Kruls[i], patrols[i], 1);
		end
	end
	Wait(R, 220.0);
end

--respawns 2 sets of 4 turrets that go to the northern pool and southwest pool
function SpawnTurrets(R, STATE)
	local dest1 = { "ST1one", "ST1two", "ST1three", "ST1four" };
	local dest2 = { "ST2one", "ST2two", "ST2three", "ST2four" };
	if STATE == 0 then	--LOC_232
		Advance(R, 60.0);
	elseif STATE == 1 then	--LOC_238
		for i = 1,NUM_TURRETS1 do
			if not IsAround(M.Turrets1[i]) then
				M.Turrets1[i] = TeleportIn("evturr", 6, M.Portals[3], 30);
				Goto(M.Turrets1[i], dest1[i]);
			end
		end
		Advance(R, 60.0);
	elseif STATE == 2 then	--LOC_253
		for i = 1,NUM_TURRETS2 do
			if not IsAround(M.Turrets2[i]) then
				M.Turrets2[i] = TeleportIn("evturr", 6, M.Portals[5], 30);
				Goto(M.Turrets2[i], dest2[i]);
			end
		end
		SetState(R, 0, 60.0);
	end
end

--enemy off planet MegaGuns target Player's extractors after each MegaGun shot
function HandleMegaGunRetaliate(R, STATE)
	local targets = { "CerbTL", "CerbBL", "CerbBR", "CerbTR", "CerbC" };
	local odfs = { "cvhscout", "cvhscout", "cvhtank", "cvhscout", "cvhtank", };
	local portals = {5,5,3,3,6};
	
	if STATE == 0 then	--LOC_325
		Advance(R, 2.0);
		SetRoutineActive(R, false);
	elseif STATE == 1 then
		--spawn in some random cerb units to harrass player's extractors
		for i = 1,6 do
			local r = math.random(1,5);
			Goto(TeleportIn(odfs[r], 6, M.Portals[portals[r]], 20), targets[r], 0);
		end
		Attack(TeleportIn("cvhtank", 6, M.Portals[4], 20), M.Recycler, 1);
		Attack(TeleportIn("cvhscout", 6, M.Portals[4], 20), M.Recycler, 1);
		Attack(TeleportIn("cvhtank", 6, M.Portals[4], 20), M.Recycler, 1);
		Attack(TeleportIn("cvhscout", 6, M.Portals[4], 20), M.Recycler, 1);
		Advance(R, 15.0);
	elseif STATE == 2 then
		--Hadean off planet megaguns target a random extractor on the map
		local r = math.random(1,5);
		BuildObject("mbbeam", 9, targets[r]);
		BuildObject("mbfire", 9, targets[r]);
		BuildObject("mbrocks", 9, targets[r]);
		SetState(R, 0);
	end
end

--packs up the Recycler and moves it to nav Delta once player gets within range
function HandleRecyclerRetreat(R, STATE)
	if STATE == 0 then
		M.Recycler = ReplaceObject(M.Recycler, "ivrecy");
		SetObjectiveOn(M.Recycler);	--added objective marker to the recycler
		SetTeamNum(M.Recycler, 2);
		SetAIP("edf04e.aip", 6);
		Advance(R);
	elseif STATE == 1 then 
		if GetDistance(M.Recycler, M.Player) < 75 then
			Goto(M.Recycler, M.NavDelta, 1);
			Advance(R);
		end
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if not IsAround(M.Recycler) then
			FailMission(GetTime() + 10, "edf04l1.des");
			M.MissionOver = true;
		elseif not IsAround(M.EngineerTransport) then
			ClearObjectives();
			AddObjective("edf0409.otf", "red");
			--AudioMessage("edf04l3.wav");	--doesn't exist (that's an 'L', not a '1')
			--AudioMessage("edf0413a.wav");	--O'Ryan:"AAARRRGGGGH!"
			FailMission(GetTime() + 10, "edf04l3.des");
			M.MissionOver = true;
		end
	end
end

function TeleportIn(odf,  team,  dest, offset)
	local pos = GetPosition(dest);
	pos.x = pos.x + offset;
	BuildObject("teleportin",  0,  pos);
	return BuildObject(odf,  team,  pos);
end

