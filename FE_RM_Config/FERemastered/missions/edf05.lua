----------------------------------------------------------------
-- FE edf05.lua Mission - Version 1.0
-- Date Modified: 11/01/2021
-- Summary: Mission script for the EDF05 Forgotten Enemies Mission.
----------------------------------------------------------------

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

-- Variables Not saved. Constants that never change.
local NUM_DEFENDERS = 11	--Player's starting forces
local NUM_PILOTS = 8	--number of pilots that get out of Transport to crew empty Hadean ships by supply depot

local Routines = {};

local M = {
--Mission State
	RoutineState = {},
	RoutineWakeTime = {},
	RoutineActive = {},
	MissionOver = false,
-- Bools
	CheckRecy = false, -- recy teleported out
	CheckTrans = false, -- transport teleported out
	PlayerTeleportedOut = false, -- If the player exits the portal, setcolorfade.
	RecyTeleported = false,	--recy went through 1st portal
	TransportArrivedAtBase = false,	--transport reached "basedeploy"
	HadTurr1Sniped = false,
	HadTurr2Sniped = false,
	HighlightTransport = false,
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
	RecyclerState = 0,	--recycler state (0:heading to Portal1,1:teleported through portal1,2:player met up with convoy,3:player went through portal1,4:Recycler is at "basedeploy")
	Variable6 = 0,	--recy rendezvous timer
	Variable7 = 0,	--player was left behind
	PilotIndex = 0,	--for edf pilots capturing hadean ships
	UnitsTransported = 0, -- For counting all the units passing through Portal1.
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

function DefineRoutines()
	DefineRoutine(1, HandleMainState, true);
	DefineRoutine(2, HandleRecyEscort, false);
	DefineRoutine(3, HandleRecyRetreat, true);
	DefineRoutine(4, SpawnPlateauAttackers, true);
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
	M.Portal2 = GetHandleOrDie("portal2");
	M.ExitPortal = GetHandleOrDie("exitportal");
	SetPortalDest(M.Portal1, M.Portal2);
	SetPortalDest(M.Portal2, M.Portal1);
	SetPortalDest(M.ExitPortal, M.Portal2);
	SetObjectiveName(M.ExitPortal, "Star Portal");
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
	M.Defenders[11] = GetPlayerHandle();
	
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

	-- Very minor detail.
	SetScrap(1, 40);
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
		if M.RecyclerState > 0 then
			Advance(R);
		end
	elseif STATE == 3 then
		if M.TransportArrivedAtBase == true then
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
		if (not M.HadTurr1Sniped and not IsAliveAndPilot(M.HadTurr1)) then
			SetObjectiveOff(M.HadTurr1);
			M.HadTurr1Sniped = true;
		end

		if (not M.HadTurr2Sniped and not IsAliveAndPilot(M.HadTurr2)) then
			SetObjectiveOff(M.HadTurr2);
			M.HadTurr2Sniped = true;
		end

		if (M.HadTurr1Sniped and M.HadTurr2Sniped and not M.HighlightTransport) then
			SetObjectiveOn(M.Transport);
			ClearObjectives();
			AddObjective("edf0505.otf", "GREEN");
			AddObjective("edf0506.otf", "WHITE");
			M.HighlightTransport = true;
		end

		if GetDistance(M.Transport, "apcdeploy") < 30 then
			if IsAround(M.EmptyShips[M.PilotIndex]) and not HasPilot(M.EmptyShips[M.PilotIndex]) then
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
		if GetDistance(M.Recycler, M.ExitPortal) < 300 then
			AudioMessage("edf0509.wav");	--O'Ryan:"This portal leads away from earth, if we can hold on a few minutes, i can reprogram it"
			AudioMessage("edf0510.wav");	--Windex:"Corporal, we don't have a few minutes..."
			Advance(R);
		end
	elseif STATE == 9 then	--LOC_93
		if M.CheckRecy == false and M.CheckTrans == false then
			Advance(R);
		end
	elseif STATE == 10 then	--LOC_102
		if M.PlayerTeleportedOut == true then
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
		SetObjectiveOn(M.Portal1);
		for i = 1, NUM_DEFENDERS do -- Any survivors, try to make it to the Portal.
			if not IsPlayer(M.Defenders[i]) then
				Goto(M.Defenders[i], "blockade", 1);
			end
		end
		StartCockpitTimer(60);
		Advance(R, 60.0);
	elseif STATE == 2 then
		BuildObject("slagb2", 2, "blockade");
		ClearPortalDest(M.Portal2, true);
		RemoveObject(M.Portal1);
		for i = 1, NUM_DEFENDERS do -- Portal's blown up, try to find another way.
			if not IsPlayer(M.Defenders[i]) then
				Follow(M.Defenders[i], M.Transport, 1);
			end
		end
		Advance(R, 3.0);
	elseif STATE == 3 then
		HideCockpitTimer();
		if M.RecyclerState == 3 then
			SetState(R, 5);--to LOC_265
		else
			M.Variable7 = 1;
			local anyAlive = false
			for i = 1, NUM_DEFENDERS do -- Did any survive?
				if not IsPlayer(M.Defenders[i]) and IsAliveAndPilot(M.Defenders[i]) then
					anyAlive = true;
				end
			end
			if not anyAlive then
				AudioMessage("edf0504.wav");	--Windex:"I can't believe you let all our men die on the platue, you better escort me!" -- Was edf0510.wav for some reason...
			end
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
		M.RecyclerState = 2;
		TeleportIn("evscout", 2, M.Portal2, -10);
		Advance(R);
	elseif STATE == 6 then	--LOC_269
		if M.RecyTeleported then
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
		if (M.RecyclerState == 1) then -- Recy is through
			Advance(R);
		end
	elseif STATE == 1 then	--LOC_151
		if M.UnitsTransported == 2 then -- Transport is through.
			Advance(R);
		end
	elseif STATE == 2 then	--LOC_158
		if (M.UnitsTransported == 4) or 
		((not IsAround(M.ServiceTruck1) or not IsAround(M.ServiceTruck2)) and M.UnitsTransported == 3) or
		(not IsAround(M.ServiceTruck1) and not IsAround(M.ServiceTruck2) and M.UnitsTransported == 2) then -- recy, transport, and 2 service trucks are through, if they're alive.
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
		Follow(M.Transport, M.Recycler, 1);
		Defend2(M.ServiceTruck1, M.Transport, 0);
		Defend2(M.ServiceTruck2, M.Transport, 0);
		M.RecyTeleported = true;
		Advance(R, 60.0);
	elseif STATE == 5 then	--LOC_184
		if GetDistance(M.Recycler, "basedeploy") < 25 then
			M.RecyclerState = 4;
			Advance(R);
		end
	elseif STATE == 6 then	--LOC_187
		if GetDistance(M.Player, M.Recycler) < 150 then
			Advance(R);
		end
	elseif STATE == 7 then
		if GetDistance(M.Transport, "basedeploy") < 200 then
			M.TransportArrivedAtBase = true;
			Advance(R);
		end
	end
end

--spawns Hadean attack waves during intro battle
function SpawnPlateauAttackers(R, STATE)
	if STATE == 0 then
		Advance(R, 45.0);
	elseif STATE == 1 then
		ClearObjectives();
		AddObjective("edf0509.otf", "white");
		Goto(BuildObject("evatank", 2, "attackerspawn"), "tankpath", 1);
		Goto(BuildObject("evscout", 2, "attackerspawn"), "zeuspath", 1);
		Goto(BuildObject("evscout", 2, "attackerspawn"), "walkpath", 1);
		Goto(BuildObject("evscout", 2, "attackerspawn"), "mortpath", 1);
		Goto(BuildObject("evwalk", 2, "attackerspawn"), "walkpath", 1);	--changed from "ivewalk"
		Advance(R, 45.0);
	elseif STATE == 2 then
		Goto(BuildObject("evscout", 2, "attackerspawn"), "tankpath", 1);
		Goto(BuildObject("evscout", 2, "attackerspawn"), "zeuspath", 1);
		Goto(BuildObject("evscout", 2, "attackerspawn"), "walkpath", 1);
		Goto(BuildObject("evtank", 2, "attackerspawn"), "mortpath", 1);
		Goto(BuildObject("evwalk", 2, "attackerspawn"), "walkpath", 1);	--changed from "ivewalk"
		Goto(BuildObject("evscout", 2, "attackerspawn"), "tankpath", 1);
		Advance(R, 45.0);
	elseif STATE == 3 then
		Goto(BuildObject("evtank", 2, "attackerspawn"), "tankpath", 1);
		Goto(BuildObject("evtank", 2, "attackerspawn"), "tankpath", 1);
		Goto(BuildObject("evmisl", 2, "attackerspawn"), "zeuspath", 1);
		Goto(BuildObject("evmisl", 2, "attackerspawn"), "zeuspath", 1);
		Advance(R, 45.0);
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

function PreTeleport(portal, h)
	if portal == M.Portal1 then
		if h == M.Player then
			if M.RecyclerState == 0 then
				FailMission(GetTime() + 5, "edf5tele.txt");
				M.MissionOver = true;
			elseif M.RecyclerState == 1 then
				M.RecyclerState = 3;
				return PRETELEPORT_ALLOW;
			end
		elseif h == M.Recycler then
			AudioMessage("edf0502.wav");	--Windex:"We found a short range portal..."
			ClearObjectives();
			AddObjective("edf0502.otf", "white");
			M.RecyclerState = 1;
			Goto(M.Transport, "blockade", 1);
			M.UnitsTransported = M.UnitsTransported + 1;
			return PRETELEPORT_ALLOW;
		elseif h == M.Transport then
			SetRoutineActive(2, true);--M.RecyRetreat = true;
			Goto(M.ServiceTruck1, "blockade", 1);
			Goto(M.ServiceTruck2, "blockade", 1);
			M.UnitsTransported = M.UnitsTransported + 1;
			return PRETELEPORT_ALLOW;
		elseif h == M.ServiceTruck1 then
			Defend2(M.ServiceTruck1, M.Transport, 1);
			M.UnitsTransported = M.UnitsTransported + 1;
			return PRETELEPORT_ALLOW;
		elseif h == M.ServiceTruck2 then
			Defend2(M.ServiceTruck2, M.Transport, 1);
			M.UnitsTransported = M.UnitsTransported + 1;
			return PRETELEPORT_ALLOW;
		end
	elseif portal == M.ExitPortal then	
		if h == M.Recycler then
			M.CheckRecy = false; --M.Variable3 = 1;
			DeleteAfterDelay(M.Recycler);
			Goto(M.Transport, "recyclerexit", 1);
			AudioMessage("edf05end.wav");	--Shultz:"Aw man, what are we getting into?"
			Attack(TeleportIn("cvtank", 2, M.ExitPortal, 10), M.Player, 1);
			return PRETELEPORT_ALLOW;
		elseif h == M.Transport then
			M.CheckTrans = false; --M.Variable4 = 1;
			DeleteAfterDelay(M.Transport);
			Attack(TeleportIn("cvtank", 2, M.ExitPortal, 10), M.Player, 1);
			return PRETELEPORT_ALLOW;
		elseif h == M.ServiceTruck1 then
			DeleteAfterDelay(M.ServiceTruck1);
			return PRETELEPORT_ALLOW;
		elseif h == M.ServiceTruck2 then
			DeleteAfterDelay(M.ServiceTruck2);
			return PRETELEPORT_ALLOW;
		elseif h == M.Player then
			SucceedMission(GetTime() + 2, "edf5win.des");
			M.PlayerTeleportedOut = true;
			return PRETELEPORT_ALLOW;
		end
	end
	
	return PRETELEPORT_DENY; -- This mission's portals are strictly locked.
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if M.CheckRecy and not IsAround(M.Recycler) then
			FailMission(GetTime() + 5, "edf5recy.txt");
			M.MissionOver = true;
		elseif M.CheckTrans and not IsAround(M.Transport) then
			FailMission(GetTime() + 5, "edf5trans.txt");
			MissionOver = true;
		elseif GetDistance(M.Player, "pointofnoreturn") < 100 and M.RecyclerState == 0 then
			BuildObject("deathbomb", 2, "pointofnoreturn");
			FailMission(GetTime() + 25, "edf5close.txt");
			M.MissionOver = true;
		end
	end
end