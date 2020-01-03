assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

-- Variables Not saved. Constants that never change.
local NUM_DEFENDERS = 10	--Player's starting forces
local NUM_PILOTS = 8	--number of pilots that get out of Transport to crew empty Hadean ships by supply depot

local Routines = {};

local M = {
--Mission State
	RoutineState = {},
	RoutineWakeTime = {},
	RoutineActive = {},
	MissionOver = false,
-- Bools
	CheckRecy = false,
	CheckTrans = false,
-- Floats
	
-- Handles
	Recycler = nil,	--recycler
	Player = nil,	--player
	ServiceTruck1 = nil,	--service truck
	ServiceTruck2 = nil,	--service truck
	Transport = nil, --transport
	Pilots = {},
	Portal1 = nil,
	Portal2 = nil,
	ExitPortal = nil,
	Defenders = {},	--edf units on plateau 
	ServiceTruck3 = nil,
	ServiceTruck4 = nil,
	HadeanTrain = nil,	--doesn't seem to be set. Was probably intended to be the Hadean believers vat by the repair depot
	EmptyShips = {},	--empty ships at Hadean supply outpost
	HadTurr1 = nil,
	HadTurr2 = nil,
	HangGliderPickup,
-- Ints
	TPS = 10,
	Variable2 = 0,	--recycler state (0:heading to Portal1,1:teleported through portal1,2:player met up with convoy,3:player went through portal1,4:Recycler is at "basedeploy")
	--Variable3 = 0,	--recy teleported out
	--Variable4 = 0,	--transport teleported out
	Variable5 = 0,	--transport reached "basedeploy"
	Variable6 = 0,	--recy rendezvous timer
	Variable7 = 0,	--player was left behind
	Variable8 = 0,	--recy went through 1st portal
	PilotIndex = 0,	--for edf pilots capturing hadean ships
	endme = 0
}

function DefineRoutine(routineID, func, activeOnStart)
	if routineID == nil or Routines[routineID]~= nil then
		error("DefineRoutine: duplicate or invalid routineID: "..tostring(routineID));
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
	DefineRoutine(2, HandleRecyEscort, false);
	DefineRoutine(3, HandleRecyRetreat, true);
	DefineRoutine(4, SpawnPlateauAttackers, true);
	DefineRoutine(5, HandlePortal, true);
end


function InitialSetup()

	_FECore.InitialSetup();

	M.TPS = EnableHighTPS();
	AllowRandomTracks(false);
	
	DefineRoutines();
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadODFs = {
		"ivrecy",
		"edf5trans",
		"ispilo",
		"evturr",
		"evscout",
		"evtank",
		"evmisl",
		"evmort",
		"evwalk",	--ivewalk
		"espilo",
		"cvtank",
		"ptera01",
		"ptera02",
		"ptera03",
		"slagb2",
		"deathbomb",
		"aphanglider",
		"teleportin",
		"teleportout"
	};
	local preloadAudio = {
		"edf0501.wav",
		"edf0502.wav",
		"edf0503.wav",
		"edf0504.wav",
		"edf0505.wav",
		"edf0506.wav",
		"edf0507.wav",
		"edf0508.wav",
		"edf0509.wav",
		"edf0510.wav",
		"edf05end.wav"
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

	M.Portal1 = GetHandleOrDie("portal1");
	ClearPortalDest(M.Portal1, true); -- Lock Portal to script only.
	M.Portal2 = GetHandleOrDie("portal2");
	ClearPortalDest(M.Portal2, true); -- Lock Portal to script only.
	M.ExitPortal = GetHandleOrDie("exitportal");
	ClearPortalDest(M.ExitPortal, true); -- Lock Portal to script only.
	--M.HadeanTrain = GetHandleOrDie("hadeantrain");
	
	--spawn player's starting forces
	M.Recycler = BuildObject("ivrecy", 1, "recyclerspawn");
	Goto(M.Recycler, "recyclerpath", 1);
	SetObjectiveOn(M.Recycler);
	M.Transport = BuildObject("edf5trans", 1, "recyclerspawn");
	SetObjectiveName(M.Transport, "Transport");
	Goto(M.Transport, "recyclerpath", 1);
	M.ServiceTruck1 = BuildObject("ivserv", 1, "recyclerspawn");
	Defend2(M.ServiceTruck1, M.Transport, 1);
	M.ServiceTruck2 = BuildObject("ivserv", 1, "recyclerspawn");
	Defend2(M.ServiceTruck2, M.Transport, 1);
	M.ServiceTruck3 = BuildObject("ivserv", 1, "turret1");
	SetGroup(M.ServiceTruck3, 5);
	M.ServiceTruck4 = BuildObject("ivserv", 1, "turret1");
	SetGroup(M.ServiceTruck4, 5);
	M.Defenders[1] = BuildObject("ivturr", 1, "turret1");
	SetGroup(M.Defenders[1], 0);
	M.Defenders[2] = BuildObject("ivturr", 1, "turret2");
	SetGroup(M.Defenders[2], 0);
	M.Defenders[3] = BuildObject("ivscout", 1, "turret3");
	SetGroup(M.Defenders[3], 4);
	M.Defenders[4] = BuildObject("ivscout", 1, "turret4");
	SetGroup(M.Defenders[4], 4);
	M.Defenders[5] = BuildObject("ivtank", 1, "tank1");
	SetGroup(M.Defenders[5], 1);
	M.Defenders[6] = BuildObject("ivtank", 1, "tank2");
	SetGroup(M.Defenders[6], 1);
	M.Defenders[7] = BuildObject("ivmisl", 1, "tank3");
	SetGroup(M.Defenders[7], 2);
	M.Defenders[8] = BuildObject("ivmisl", 1, "tank4");
	SetGroup(M.Defenders[8], 2);
	M.Defenders[9] = BuildObject("ivrbomb", 1, "tank5");
	SetGroup(M.Defenders[9], 3);
	M.Defenders[10] = BuildObject("ivrbomb", 1, "tank6");
	SetGroup(M.Defenders[10], 3);
	
	--spawn birds
	local birdOdfs = { 
		"ptera01", 
		"ptera01", 
		"ptera01", 
		"ptera02", 
		"ptera02", 
		"ptera02", 
		"ptera03", 
		"ptera03", 
		"ptera03", 
		"ptera03", 
		"ptera03", 
		"ptera01", 
		"ptera01",
		"ptera01", 
		"ptera02", 
		"ptera02", 
		"ptera02", 
		"ptera03", 
		"ptera01", 
		"ptera01", 
		"ptera01", 
		"ptera02", 
		"ptera02", 
		"ptera01" };
	for i = 1, 8 do
		local path = string.format("birdpath%d", i);
		for j = 1, 3 do 
			Patrol(BuildObject(birdOdfs[(i-1)*3 + j], 0, path), path, 1);
		end
	end
end


function AddObject(h)

	_FECore.AddObject(h);

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

--Main mission state.
function HandleMainState(R, STATE)
	if STATE == 0 then
		M.CheckRecy = true;
		M.CheckTrans = true;
		Advance(R, 5.0);
	elseif STATE == 1 then
		AudioMessage("edf0501.wav");	--Windex:"The Hadeans have us surrounded..."
		ClearObjectives();
		AddObjective("edf0501.otf", "white");
		Advance(R, 3.0);
	elseif STATE == 2 then	--LOC_20
		if M.Variable2 > 0 then
			Advance(R);
		end
	elseif STATE == 3 then
		if M.Variable5 == 1 then
			Advance(R, 5.0);--15.0
		end
	elseif STATE == 4 then
		AudioMessage("edf0505.wav");	--O'Ryan:"We should be safe up here for a while..."
		ClearObjectives();
		AddObjective("edf0505.otf", "white");
		M.HangGliderPickup = BuildObject("aphanglider", 1, "gliderspawn");
		Goto(M.Transport, "apcpathtobase", 1);
		SetObjectiveOn(M.HangGliderPickup);
		M.DoHadeanAlarm = true;
		M.EmptyShips[1] = BuildObject("evscout", 0, "hadeanscout1");
		KillPilot(M.EmptyShips[1]);
		M.EmptyShips[2] = BuildObject("evscout", 0, "hadeanscout2");
		KillPilot(M.EmptyShips[2]);
		M.EmptyShips[3] = BuildObject("evtank", 0, "hadeantank1");
		KillPilot(M.EmptyShips[3]);
		M.EmptyShips[4] = BuildObject("evtank", 0, "hadeantank2");
		KillPilot(M.EmptyShips[4]);
		M.EmptyShips[5] = BuildObject("evmisl", 0, "hadeanzeus1");
		KillPilot(M.EmptyShips[5]);
		M.EmptyShips[6] = BuildObject("evmisl", 0, "hadeanzeus2");
		KillPilot(M.EmptyShips[6]);
		M.HadTurr1 = GetHandle("hadeanturret1");
		SetObjectiveOn(M.HadTurr1);
		M.HadTurr2 = GetHandle("hadeanturret2");
		SetObjectiveOn(M.HadTurr2);
		M.EmptyShips[7] = M.HadTurr1;
		M.EmptyShips[8] = M.HadTurr2;
		M.PilotIndex = 1;
		Advance(R);
	elseif STATE == 5 then
		if GetDistance(M.Transport, "apcdeploy") < 100 then
			if IsAround(M.EmptyShips[M.PilotIndex])
			and not HasPilot(M.EmptyShips[M.PilotIndex]) then
				M.Pilots[M.PilotIndex] = BuildObject("ispilo", 1, "apcdeploy");
				SetIndependence(M.Pilots[M.PilotIndex], 0);
				Goto(M.Pilots[M.PilotIndex], M.EmptyShips[M.PilotIndex], 1);
			end
			M.PilotIndex = M.PilotIndex + 1;
			if M.PilotIndex > NUM_PILOTS then
				Advance(R, 1.0);
			else
				Wait(R, 1.0);
			end
		end
	elseif STATE == 6 then
		SetObjectiveOff(M.HadTurr1);
		SetObjectiveOff(M.HadTurr2);
		SetObjectiveOn(M.ExitPortal);
		AudioMessage("edf0508.wav");	--Windex:"There's the portal up ahead on radar..."
		ClearObjectives();
		AddObjective("edf0508.otf", "white");
		Advance(R, 60.0);
	elseif STATE == 7 then
		Goto(M.Recycler, "recyclerexit", 1);
		Follow(M.Transport, M.Recycler, 1);
		Advance(R);
	elseif STATE == 8 then	--LOC_83
		if GetDistance(M.Recycler, M.ExitPortal) < 25 then
			M.CheckRecy = false;--M.Variable3 = 1;
			Teleport(M.Recycler, M.Portal2, -20);
			RemoveObject(M.Recycler);
			Goto(M.Transport, "recyclerexit", 1);
			AudioMessage("edf05end.wav");	--Shultz:"Aw man, what are we getting into?"
			Attack(TeleportIn("cvtank", 2, M.ExitPortal, 10), M.Player, 1);
			Advance(R);
		end
	elseif STATE == 9 then	--LOC_93
		if GetDistance(M.Transport, M.ExitPortal) < 25 then
			M.CheckTrans = false;--M.Variable4 = 1;
			Teleport(M.Transport, M.Portal2, -20);
			RemoveObject(M.Transport);
			Attack(TeleportIn("cvtank", 2, M.ExitPortal, 10), M.Player, 1);
			Advance(R);
		end
	elseif STATE == 10 then	--LOC_102
		if GetDistance(M.Player, M.ExitPortal) < 25 then
			Teleport(M.Player, M.Portal2, -10);
			SucceedMission(GetTime() + 2, "edf5win.des");
			Advance(R);
		end
	elseif STATE == 11 then
		SetColorFade(4, 0.1, Make_RGB(20, 0, 0));	--added red fade at end of mission to hide the fact that we're actually still on Spartacus
	end
end

--activated once Recy + Transport have gone through portal.
--retreats all plateau units and removes control from player
--starts countdown for player to reach portal
--sends a few scouts after recy after player goes through portal
function HandleRecyEscort(R, STATE)
	if STATE == 0 then
		Advance(R, 10.0);
	elseif STATE == 1 then
		AudioMessage("edf0503.wav");	--Windex:"My engineers have deactivated the heavy mines..."
		ClearObjectives();
		AddObjective("edf0503.otf", WHITE);
		for i = 1, NUM_DEFENDERS do
			if not IsPlayer(M.Defenders[i]) then
				Follow(M.Defenders[i], M.Transport, 1);
			end
		end
		StartCockpitTimer(60);
		Advance(R, 60.0);
	elseif STATE == 2 then
		BuildObject("slagb2", 2, "blockade");
		RemoveObject(M.Portal1);
		Advance(R, 3.0);
	elseif STATE == 3 then
		HideCockpitTimer();
		if M.Variable2 == 3 then
			SetState(R, 5);--to LOC_265
		else
			M.Variable7 = 1;
			--audio doesn't make sense here?
			AudioMessage("edf0510.wav");	--Windex:"Corporal, we don't have a few minutes..."
			ClearObjectives();
			AddObjective("edf0510.otf", "red");
			Advance(R, 60.0);
		end
	elseif STATE == 4 then
		Attack(BuildObject("evscout", 2, "attackerspawn2"), M.Recycler, 1);
		Attack(BuildObject("evscout", 2, "attackerspawn2"), M.Transport, 1);
		Advance(R);
	elseif STATE == 5 then	--LOC_265
		M.Variable7 = 0;
		M.Variable2 = 2;
		TeleportIn("evscout", 2, M.Portal2, -10);
		Advance(R);
	elseif STATE == 6 then	--LOC_269
		if M.Variable8 then
			Advance(R, 30.0);
		end
	elseif STATE == 7 or STATE == 8 then
		Attack(BuildObject("evscout", 2, "attackerspawn2"), M.Recycler, 1);
		Advance(R, 45.0);
	elseif STATE == 9 then
		Attack(BuildObject("evscout", 2, "attackerspawn2"), M.Recycler, 1);
		Advance(R, 120.0);
	elseif STATE == 10 then
		Attack(BuildObject("evscout", 2, "attackerspawn2"), M.Recycler, 1);
		Advance(R);
	end
end

--retreats the Recycler, Transport, and 2 Service Trucks through the Portal
function HandleRecyRetreat(R, STATE)
	if STATE == 0 then	--LOC_142
		if GetDistance(M.Recycler, M.Portal1) < 25 then
			AudioMessage("edf0502.wav");	--Windex:"We found a short range portal..."
			ClearObjectives();
			AddObjective("edf0502.otf", "white");
			M.Variable2 = 1;
			Teleport(M.Recycler, M.Portal2, -30);
			Stop(M.Recycler, 1);
			Goto(M.Transport, "blockade", 1);
			Advance(R);
		end
	elseif STATE == 1 then	--LOC_151
		if GetDistance(M.Transport, "blockade") < 25 then
			Teleport(M.Transport, M.Portal2, -20);
			Stop(M.Transport, 1);
			SetRoutineActive(2, true);--M.RecyRetreat = true;
			Goto(M.ServiceTruck1, "blockade", 1);
			Goto(M.ServiceTruck2, "blockade", 1);
			Advance(R);
		end
	elseif STATE == 2 then	--LOC_158
		if GetDistance(M.ServiceTruck1, "blockade") < 25
		or GetDistance(M.ServiceTruck2, "blockade") < 25 
		or not IsAround(M.ServiceTruck1)
		or not IsAround(M.ServiceTruck2) then
			Teleport(M.ServiceTruck1, M.Portal2, -20);
			Defend2(M.ServiceTruck1, M.Transport, 1);
			Teleport(M.ServiceTruck2, M.Portal2, -20);
			Defend2(M.ServiceTruck2, M.Transport, 1);
			M.Variable6 = GetTime() + 300;
			Advance(R);
		end
	elseif STATE == 3 then	--LOC_171
		if M.Variable6 < GetTime() or GetDistance(M.Recycler, M.Player) < 150 then
			Advance(R);
		end
	elseif STATE == 4 then	--LOC_176
		SetGroup(M.ServiceTruck1, 0);
		SetGroup(M.ServiceTruck2, 0);
		Goto(M.Recycler, "recyclerpath1", 1);
		Goto(M.Transport, "recyclerpath1", 1);
		Defend2(M.ServiceTruck1, M.Transport, 0);
		Defend2(M.ServiceTruck2, M.Transport, 0);
		M.Variable8 = 1;
		Advance(R, 60.0);
	elseif STATE == 5 then	--LOC_184
		if GetDistance(M.Recycler, "basedeploy") < 25 then
			M.Variable2 = 4;
			Advance(R);
		end
	elseif STATE == 6 then	--LOC_187
		if GetDistance(M.Player, M.Recycler) < 150 then
			Advance(R);
		end
	elseif STATE == 7 then
		if GetDistance(M.Transport, "basedeploy") < 200 then
			M.Variable5 = 1;
			Advance(R);
		end
	end
end

--spawns Hadean attack waves during intro battle
function SpawnPlateauAttackers(R, STATE)
	if STATE == 0 then
		Advance(R, 30.0);
	elseif STATE == 1 then
		ClearObjectives();
		AddObjective("edf0509.otf", "white");
		Goto(BuildObject("evatank", 2, "attackerspawn"), "tankpath", 1);
		Goto(BuildObject("evscout", 2, "attackerspawn"), "zeuspath", 1);
		Goto(BuildObject("evscout", 2, "attackerspawn"), "walkpath", 1);
		Goto(BuildObject("evscout", 2, "attackerspawn"), "mortpath", 1);
		Goto(BuildObject("evwalk", 2, "attackerspawn"), "walkpath", 1);	--changed from "ivewalk"
		Advance(R, 30.0);
	elseif STATE == 2 then
		Goto(BuildObject("evscout", 2, "attackerspawn"), "tankpath", 1);
		Goto(BuildObject("evscout", 2, "attackerspawn"), "zeuspath", 1);
		Goto(BuildObject("evscout", 2, "attackerspawn"), "walkpath", 1);
		Goto(BuildObject("evtank", 2, "attackerspawn"), "mortpath", 1);
		Goto(BuildObject("evwalk", 2, "attackerspawn"), "walkpath", 1);	--changed from "ivewalk"
		Goto(BuildObject("evscout", 2, "attackerspawn"), "tankpath", 1);
		Advance(R, 30.0);
	elseif STATE == 3 then
		Goto(BuildObject("evtank", 2, "attackerspawn"), "tankpath", 1);
		Goto(BuildObject("evtank", 2, "attackerspawn"), "tankpath", 1);
		Goto(BuildObject("evmisl", 2, "attackerspawn"), "zeuspath", 1);
		Goto(BuildObject("evmisl", 2, "attackerspawn"), "zeuspath", 1);
		Advance(R, 30.0);
	elseif STATE == 4 then
		Goto(BuildObject("evwalk", 2, "attackerspawn"), "walkpath", 1);
		Goto(BuildObject("evmisl", 2, "attackerspawn"), "zeuspath", 1);
		Goto(BuildObject("evmisl", 2, "attackerspawn"), "zeuspath", 1);
		Goto(BuildObject("evscout", 2, "attackerspawn"), "tankpath", 1);
		Goto(BuildObject("evmort", 2, "attackerspawn"), "mortpath", 1);
		Goto(BuildObject("evmort", 2, "attackerspawn"), "mortpath", 1);
		Goto(BuildObject("evmort", 2, "attackerspawn"), "mortpath", 1);
		Goto(BuildObject("evmort", 2, "attackerspawn"), "mortpath", 1);
		Advance(R);
	end
end

function HandlePortal(R, STATE)
	if GetDistance(M.Player, M.Portal1) < 25 then
		if M.Variable2 == 0 and not M.MissionOver then
			FailMission(GetTime() + 5, "edf5tele.txt");
			M.MissionOver = true;
		elseif M.Variable2 == 1 then
			Teleport(M.Player, M.Portal2, -10);
			M.Variable2 = 3;
		end
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if M.CheckRecy and not IsAround(M.Recycler) then
			FailMission(GetTime() + 5, "edf5recy.txt");
			M.MissionOver = true;
		elseif M.CheckTrans and not IsAround(M.Transport) then
			FailMission(GetTime() + 5, "edf5trans.txt");
			MissionOver = true;
		elseif GetDistance(M.Player, "pointofnoreturn") < 100 and M.Variable2 == 0 then
			BuildObject("deathbomb", 2, "pointofnoreturn");
			FailMission(GetTime() + 25, "edf5close.txt");
			M.MissionOver = true;
		end
	end
end

function Teleport(h, dest, offset)
	BuildObject("teleportout", 0, GetPosition(h));
	local pos = GetPosition(dest);
	pos.x = pos.x + offset;
	BuildObject("teleportin", 0, pos);
	SetPosition(h, pos);
	if h == GetPlayerHandle() then
		AudioMessage("teleport.wav");	--sound effects seem to get cut off when player is teleporting
	end
end

function TeleportIn(odf,  team,  dest, offset)
	local pos = GetPosition(dest);
	pos.x = pos.x + offset;
	BuildObject("teleportin",  0,  pos);
	return BuildObject(odf,  team,  pos);
end

