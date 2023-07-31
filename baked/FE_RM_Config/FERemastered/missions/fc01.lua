----------------------------------------------------------------
-- FE fc01.lua Mission - Version 1.1
-- Date Modified: 8/9/2022
-- Summary: Mission script for the fc01 Forgotten Enemies Mission.
----------------------------------------------------------------

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

local NUM_SOLDIERS = 7;
local NUM_GTOWS = 5;

local Position5 = SetVector( -5,5,10);	--was ( -1,1,4) Camera offset for Steinman cutscene (changed due to FOV bug in 1.3.7.2)
local Position6 = SetVector( 4,13,2);	--was ( 4,3,2); offset 1 for CamPos (Lt. Miller cutscene)
local Position7 = SetVector( 4,12,-2);	--was ( 4,2,-2); offset 2 for CamPos (Lt. Miller cutscene)

local M = {
-- Bools
	MissionOver = false,
	CanLoseShip = false,	--whether the player is allowed to lose their starting ship
	Routine4Active = false,
	Routine8Active = false,
	Routine9Active = false,
	Routine10Active = false,
	Routine11Active = false,
	Routine14Active = true,
	
-- Floats
	Routine1Timer = 0.0,
	Routine4Timer = 0.0,
	Routine8Timer = 0.0,
	Routine9Timer = 0.0,
	Routine10Timer = 0.0,
	Routine11Timer = 0.0,
	Routine14Timer = 0.0,

-- Handles
	Procreator = nil,	--Procreator
	Player = nil,	--Player
	HadeanCommander = nil,	--Hadean Commander
	HadeanEscort1 = nil,	--Hadean Escort 1 (xypos)
	HadeanEscort2 = nil,	--Hadean Escort 2 (xypos)
	HadeanEscort3 = nil,	--Hadean Escort 3 (xypos)
	HadeanEscort4 = nil,	--Hadean Escort 4 (xares)
	Cerb1 = nil,	--Cerb1 (cvtank)
	Cerb2 = nil,	--Cerb2 (cvscout)
	Cerb3 = nil,	--Cerb3 (cvtank)
	Cerb4 = nil,	--Cerb4 (cvscout)
	Object13 = nil,	--Dropship, scratch for AuroraBolt, lure nav
	Aurora1 = nil,	--Cerb Portal Aurora
	Aurora2 = nil,	--Cerb Portal Aurora
	Aurora3 = nil,	--Cerb Portal Aurora
	Aurora4 = nil,	--Cerb Portal Aurora field
	Aurora5 = nil, --Cerb Portal Aurora 2
	Aurora6 = nil, --Cerb Portal Aurora 2
	Aurora7 = nil, --Cerb Portal Aurora 2
	Aurora8 = nil, --Cerb Portal Aurora field 2
	CerbDroneCarrier = nil,	--Cerb Drone carrier
	EDFSteinman = nil,	--EDF Sgt. Steinman (pilot)
	PlayerScout = nil,	--Player's scout
	EDFMiller = nil,	--EDF Lt. Miller (soldier)
	EnergyDisturbanceNav = nil,	--"Energy Disturbance" nav
	CerbRecycler = nil,-- Cerb recycler <2>
	CerbGunTowers = {},	--Cerb Gtows (array)
	PlayerTrucks = nil,	--Player's Service trucks
	HadeanAssaultTanks = {},	--Hadean assault tanks (array<4>)
	TargetedCerbGunTower = nil,-- Targeted Cerb gun tower <2>
	BasePatrol1 = nil,
	BasePatrol2 = nil,
	NewObjs = {},
	Resourcers = {},

-- Ints
	TPS = 10,
	Routine1State = 0,
	Routine4State = 0,
	Routine8State = 0,
	Routine9State = 0,
	Routine10State = 0,
	--Routine11State = 0,
	Routine14State = 0,
	Variable1 =  0,	--Hadean assault in progress
	Variable2 =  0,	--Thanatos nag timer
	Variable3 =  0,	--Miller ambush counter
	Variable4 =  0,	--# of player turrets
	Variable5 =  0,	--# of turrets to build
	Variable6 =  0,	--# of player service trucks
	Variable7 =  1,	--# of service trucks to build
	Variable8 =  0,	--# of player scouts
	Variable9 =  0,	--# of scouts to build
	Variable12 =  0,	--Thanatos nag counter
	Variable13 =  0,	--# of soldiers that survived the drone carrier ambush
	Variable14 =  380,	--scan radius for NearObjectCount (Routine9)
	Variable15 =  0,	--# Hadean atanks built
	Variable16 =  0,	--always 0
	Variable18 =  2000,	--radius for NearObjectCount (Routine8)
	Variable19 =  0,	--Cerb portal location (0: behind Hadean base, 1:at Hadean base)
	GTowsRemaining = NUM_GTOWS,	--number of Cerb gun towers left

--Vectors
	Position1 = SetVector( -380,0,-870),	--Cerb Portal location ("Energy Disturbance")
	Position2 = SetVector( 360,0,-385),		--Cerb portal location
	Position3 = SetVector( 380,0,-580),		--Cerb portal location
	--Position4 = SetVector( -1000,0,-1000),	--temp pos for teleporting cerb units

--End
	endme = 0
}

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

function InitialSetup()

	_FECore.InitialSetup();
	
	M.TPS = EnableHighTPS();
	AllowRandomTracks(false);
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadOdf = {
		"evrecy_m",
		"AuroraBolt",
		"aurora1",
		"aurora2",
		"aurora3",
		"aurorafield",
		"chainmin"
	};
	for k,v in pairs(preloadOdf) do
		PreloadODF(v);
	end
	--Preload audio messages
	local preloadAudio = {
		"fc01_01.wav",
		"fc01_02.wav",
		"fc01_03.wav",
		"fc01_04.wav",
		"fc01_05.wav",
		"fc01_05b.wav",
		"fc01_06.wav",
		"fc01_07.wav",
		"fc01_08.wav",
		"fc01_09.wav",
		"fc01_10.wav",
		"fc01_11.wav",
		"fc01_11b.wav",
		"fc01_12.wav",
		"fc01_12a.wav",
		"fc01_13.wav",
		"fc01_14.wav",
		"fc01_15.wav",
		"fc01_16.wav",
		"fc01_17.wav",
		"fc01_18.wav"
	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
	
	WantBotKillMessages();
end

function Start()

	_FECore.Start();
	
	Ally(1,3);
	Ally(2,3);
	--Ally(6,2);
	--Ally(6,3);
	Ally(1,4);
	Ally(2,4);
	Ally(3,4);
	--Ally(6,4);
	
	M.Procreator = BuildObject("evrecy_m", 3, "Recycler");
	M.Object13 = GetHandleOrDie("DropShip");
	M.EDFSteinman = GetHandleOrDie("InfoPilot");
	M.PlayerScout = GetPlayerHandle();
	M.EDFMiller = GetHandleOrDie("Soldier0");
	M.CerbRecycler = GetHandleOrDie("RecyclerEnemy");
	M.CerbGunTowers[1] = GetHandleOrDie("CerbGT0");
	M.CerbGunTowers[2] = GetHandleOrDie("CerbGT1");
	M.CerbGunTowers[3] = GetHandleOrDie("CerbGT2");
	M.CerbGunTowers[4] = GetHandleOrDie("CerbGT3");
	M.CerbGunTowers[5] = GetHandleOrDie("CerbGT4");
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)

	_FECore.AddObject(h);
		
	if GetCfg(M.Procreator) == "ebrecy_m" and not IsPlayer(h) then
		if GetCfg(h) == "ebscav" or GetCfg(h) == "ebscup" then
			SetObjectiveName(h, "Defend Resourcer");
			SetObjectiveOn(h);
			table.insert(M.Resourcers, h);
			
		elseif GetCfg(h) == "evserv" then
			M.Variable6 = M.Variable6 + 1;
			SetTeamNum(h, 1);
			SetGroup(h, 3);
		elseif GetCfg(h) == "evturr" then
			M.Variable4 = M.Variable4 + 1;
			SetTeamNum(h, 1);
			SetGroup(h, 2);
			--RunSpeed,_Routine13,6,true
		elseif GetCfg(h) == "evscout" then
			M.Variable8 = M.Variable8 + 1;
			GiveWeapon(h, "gshellgun_c");
			SetTeamNum(h, 1);
			SetGroup(h, 1);
		--elseif GetCfg(h) == "espilo" or 
		--	   GetCfg(h) == "error" then
		--	SetTeamNum(h, 3);	--doesn't seem to work here
		elseif GetCfg(h) == "evatank" then
			SetTeamNum(h, 4);
		elseif GetCfg(h) == "evtank" then
			if not IsAround(M.BasePatrol1) then
				M.BasePatrol1 = h;
				SetTeamNum(h, 4);
			elseif not IsAround(M.BasePatrol2) then
				M.BasePatrol2 = h;
				SetTeamNum(h, 4);
			end
		end
		
		--Defer processing of new Objects until the next update, since some funcs don't seem to work properly if called here
		if GetTeamNum(h) == 4 then
			table.insert(M.NewObjs, h);
		end
	end
end

function AddObjectDeferred(h)
	if GetCfg(M.Procreator) == "ebrecy_m" and not IsPlayer(h) then
		if GetCfg(h) == "evtank" then
			Patrol(h, "Patrol2", 0);
		--elseif GetCfg(h) == "evscav" then
		--	Goto(h, "DroneCarrier1", 0);	
		elseif GetCfg(h) == "evatank" then
			for i = 1,3 do
				if not IsAround(M.HadeanAssaultTanks[i]) then
					M.HadeanAssaultTanks[i] = h;
					if i == 1 then
						Goto(h, "StagePoint1A", 0);
					elseif i == 2 then
						Goto(h, "StagePoint2A", 0);
					elseif i == 3 then
						Goto(h, "StagePoint3A", 0);
					end
					break;
				end
			end
		elseif GetCfg(h) == "espilo" or 
			   GetCfg(h) == "error" then
			SetTeamNum(h, 3);
		end
	end
end

function ObjectKilled(deadObj, killerObj)
	if GetTeamNum(deadObj) == 3 and IsPlayer(killerObj) then
		if (deadObj == M.HadeanCommander) then
			--Player is a traitor and shot Thanatos
			ClearObjectives();
			AddObjective("fc0115.otf", "red");
			FailMission(GetTime() + 10);	--TODO: write some text chastising the player
			M.MissionOver = true;
		else
			ClearObjectives();
			AddObjective("fc0109.otf", "red");
			M.Variable5 = M.Variable5 - 1;
			M.Variable7 = M.Variable7 - 1;
			M.Variable9 = M.Variable9 - 1;
			AddScrap(3, -60);
		end
	end
	
	if IsPlayer(deadObj) then
		return EJECTKILLRETCODES_DOEJECTPILOT;
	else
		return DoEjectRatio(deadObj);
	end
end

function DeleteObject(h)

	_FECore.DeleteObject(h);
	
	if GetTeamNum(h) == 2 and GetCfg(h) == "cbgtow" then	--original script checked for "ebgtow". How did this work before??
		M.GTowsRemaining = M.GTowsRemaining - 1;
		if M.GTowsRemaining > 0 then
			AudioMessage("fc01_17.wav");	--Thanatos:"Another Cerberi Gun Tower has fallen..."
		end
	end

	if GetCfg(M.Procreator) == "ebrecy_m" then
		if GetCfg(h) == "evserv" then
			M.Variable6 = M.Variable6 - 1;
		elseif GetCfg(h) == "evturr" and GetTeamNum(h) == 1 and h ~= M.Player then
			M.Variable4 = M.Variable4 - 1;
		elseif GetCfg(h) == "evscout" then
			M.Variable8 = M.Variable8 - 1;
		end
	end
end

function Update()

	_FECore.Update();
	
	M.Player = GetPlayerHandle();
	Routine1();
	Routine4();
	Routine8();
	Routine9();
	Routine10();
	Routine11();
	Routine14();
	CheckStuffIsAlive();
	for i=1,#M.NewObjs do
		AddObjectDeferred(M.NewObjs[i]);
	end
	M.NewObjs = {};
end

--Main mission state
--Handles patrol, escorting Hadean Procreator, and Cerb portal
function Routine1()
	if M.Routine1Timer < GetTime() then
		if M.Routine1State == 0 then			
			GiveWeapon(M.Player, "gshellgun_c");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 1 then
			SetAnimation(M.Object13, "takeoff", 1);
			StartAnimation(M.Object13);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 4;
		elseif M.Routine1State == 2 then
			AudioMessage("dropleav.wav");
			M.HadeanCommander = BuildObject("evscout", 3, "Escort0");
			GiveWeapon(M.HadeanCommander, "gshellgun_c");
			SetObjectiveName(M.HadeanCommander, "Hadean Commander");
			SetObjectiveOn(M.HadeanCommander);
			Goto(M.HadeanCommander, "MeetPlayer", 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 4;
		elseif M.Routine1State == 3 then
			RemoveObject(M.Object13);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 4 then	--LOC_22
			if GetDistance(M.HadeanCommander, M.Player) < 50 then
				Stop(M.HadeanCommander);
				LookAt(M.HadeanCommander, M.Player, 0);
				AddObjective("fc0101.otf", "white");
				AudioMessage("fc01_01.wav");	--Thanatos:"Welcome, Talon Corber..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 20;
			end
		elseif M.Routine1State == 5 then
			Goto(M.HadeanCommander, "Follow1", 0);
			M.HadeanEscort1 = BuildObject("evscout", 3, "Escort1");
			GiveWeapon(M.HadeanEscort1, "gshellgun_c");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 6 then	--LOC_32
			if GetCurrentCommand(M.HadeanCommander) == 0 then
				LookAt(M.HadeanCommander, M.HadeanEscort1);
				LookAt(M.HadeanEscort1, M.HadeanCommander);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 3;
			end
		elseif M.Routine1State == 7 then	--LOC_37
			if GetDistance(M.Player, M.HadeanCommander) < 80 then
				AudioMessage("fc01_02.wav");	--Thanatos:"As you can see, we are all piloting Xypos scouts..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 6;
			end
		elseif M.Routine1State == 8 then
			Goto(M.HadeanCommander, "Follow2", 0);
			Follow(M.HadeanEscort1, M.HadeanCommander, 0);
			M.HadeanEscort2 = BuildObject("evscout", 3, "Escort2");
			GiveWeapon(M.HadeanEscort2, "gshellgun_c");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 9 then	--LOC_46
			if GetCurrentCommand(M.HadeanCommander) == 0 then
				LookAt(M.HadeanCommander, M.HadeanEscort2);
				LookAt(M.HadeanEscort2, M.HadeanCommander);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 3;
			end
		elseif M.Routine1State == 10 then	--LOC_51
			if GetDistance(M.Player, M.HadeanCommander) < 60 then
				AudioMessage("fc01_03.wav");	--Hadean Scout:"We have discovered why our allies failed to make the rendezvous..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 16;
			end
		elseif M.Routine1State == 11 then
			Goto(M.HadeanCommander, "Follow3", 0);
			Follow(M.HadeanEscort2, M.HadeanCommander, 0);
			M.HadeanEscort3 = BuildObject("evscout", 3, "Escort3");
			GiveWeapon(M.HadeanEscort3, "gshellgun_c");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 12 then	--LOC_60
			if GetCurrentCommand(M.HadeanCommander) == 0 then
				LookAt(M.HadeanCommander, M.HadeanEscort3);
				LookAt(M.HadeanEscort3, M.HadeanCommander);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 3;
			end
		elseif M.Routine1State == 13 then
			if GetDistance(M.Player, M.HadeanCommander) < 60 then
				Goto(M.HadeanCommander, "Follow4", 0);
				Follow(M.HadeanEscort3, M.HadeanCommander, 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 8;
			end
		elseif M.Routine1State == 14 then
			AudioMessage("fc01_04.wav");	--Corber:"These Space Hawks are heavily shielded sir..."
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 15 then	--LOC_72
			if GetCurrentCommand(M.HadeanCommander) == 0 then
				SetObjectiveName(M.EDFSteinman, "EDF Sgt. Steinman");
				SetObjectiveOn(M.EDFSteinman);
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 16 then
			if GetDistance(M.Player, M.HadeanCommander) < 40 then
				LookAt(M.HadeanCommander, M.EDFSteinman, 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 2;
			end
		elseif M.Routine1State == 17 then
			AudioMessage("fc01_05.wav");	--Steinman:"You're right. The Cerberi have a few heavy beam weapons we did not know about..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 18 then
			CameraReady();
			M.CameraEndTime = GetTime() + 7;
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 19 then
			CameraObject(M.EDFSteinman, Position5, M.EDFSteinman);
			if M.CameraEndTime < GetTime() or CameraCancelled() then
				CameraFinish();
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 15;
			end
		elseif M.Routine1State == 20 then
			SetObjectiveOff(M.EDFSteinman);
			Goto(M.HadeanCommander,"Follow5", 0);
			SetPerceivedTeam(M.Player, 2);
			M.HadeanEscort4 = BuildObject("evtank", 3, "Escort4");
			M.CerbDroneCarrier = BuildObject("cvdcar_01", 2, "DroneCarrier1");
			SetMaxAmmo(M.CerbDroneCarrier, 6000);
			SetCurAmmo(M.CerbDroneCarrier, 6000);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 21 then	--LOC_93
			if GetCurrentCommand(M.HadeanCommander) == 0 then
				LookAt(M.HadeanCommander, M.HadeanEscort4);
				LookAt(M.HadeanEscort4, M.HadeanCommander);
				AudioMessage("fc01_05b.wav");	--Hadean Tank:"The remaining EDF survivors are waiting just east of us..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 5;
			end
		elseif M.Routine1State == 22 then	--LOC_99
			if GetDistance(M.Player, M.HadeanCommander) < 60 then
				M.Cerb1 = BuildObject("cvtank", 2 ,"Cerb1");
				M.Cerb2 = BuildObject("cvscout", 2 ,"Cerb2");
				M.Cerb3 = BuildObject("cvtank", 2 ,"Cerb3");
				M.Cerb4 = BuildObject("cvscout", 2 ,"Cerb4");
				Goto(M.HadeanCommander, "SoldierMeet", 0);
				Follow(M.HadeanEscort4, M.HadeanCommander, 0);
				RemoveObject(M.EDFSteinman);
				ClearObjectives();
				AddObjective("fc0112.otf", "white");
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 23 then	--LOC_111
			if GetCurrentCommand(M.HadeanCommander) == 0 then
				SetObjectiveName(M.EDFMiller, "EDF Lt. Miller");
				SetObjectiveOn(M.EDFMiller);
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 24 then	--LOC_115
			if GetDistance(M.Player, M.HadeanCommander) < 60 then
				LookAt(M.HadeanCommander, M.CerbRecycler, 0);
				AudioMessage("fc01_06.wav");	--Miller:"General Thanatos, it's an honor to meet you..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 15;
			end
		elseif M.Routine1State == 25 then
			CameraReady();
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 26 then
			if CameraPos(M.EDFMiller, M.EDFMiller, Position6, Position7, 30) then
				CameraFinish();
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 13;--16
			end
		elseif M.Routine1State == 27 then
			LookAt(M.HadeanCommander, M.Object22, 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;--10
		elseif M.Routine1State == 28 then
			AudioMessage("fc01_07.wav");	--Thanatos:"We will now enter the Cerberi base and retrieve the Procreator..."
			Goto(M.HadeanCommander, "MeetRecycler", 0);
			SetObjectiveOff(M.EDFMiller);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 29 then	--LOC_128
			if GetCurrentCommand(M.HadeanCommander) == 0 then
				LookAt(M.HadeanCommander, M.Procreator, 0);
				Goto(M.Procreator, "RecyclerFollow", 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 15;
			end
		elseif M.Routine1State == 30 then
			AudioMessage("fc01_08.wav");	--Thanatos:"The authorization codes are working..."
			Follow(M.HadeanCommander, M.Procreator, 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 31 then
			ClearObjectives();
			AddObjective("fc0114.otf", "white");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 32 then	--LOC_138
			if GetDistance(M.Procreator, "UnallyPoint") < 60 then
				UnAlly(2,3);
				UnAlly(2,4);
				SetPerceivedTeam(M.Player, 1);
				Goto(M.Cerb1, M.Procreator, 0);
				Goto(M.Cerb2, M.Procreator, 0);
				Goto(M.Cerb3, M.Procreator, 0);
				Goto(M.Cerb4, M.Procreator, 0);
				Defend2(M.HadeanCommander, M.Player, 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 6;
			end
		elseif M.Routine1State == 33 then
			AudioMessage("fc01_09.wav");	--Cerberi:"Return the procreator immediately and prepare to be liquidated..."
			ClearObjectives();
			AddObjective("fc0113.otf", "white");
			BuildObject("AuroraBolt", 2, "Bolt2");
			BuildObject("AuroraBolt", 2, "Bolt3");
			BuildObject("AuroraBolt", 2, "Bolt6");
			BuildObject("AuroraBolt", 2, "Bolt8");
			BuildObject("AuroraBolt", 2, "Bolt9");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 34 then		--LOC_156
			if not IsAround(M.Cerb1) and not IsAround(M.Cerb2) 
			and not IsAround(M.Cerb3) and not IsAround(M.Cerb4) then
				ClearObjectives();
				Goto(M.Procreator, "RecyclerNext", 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 5;
			end
		elseif M.Routine1State == 35 then
			AudioMessage("fc01_10.wav");	--Miller:"We've laid a trap for that drone carrier..."
			ClearObjectives();
			AddObjective("fc0105.otf", "white");
			M.Routine4Active = true;--RunSpeed,_Routine4,1,true
			M.Object13 = BuildObject("ibnav", 1, "SoldierMeet");
			SetObjectiveName(M.Object13, "Lure Carrier and Drones Here!");
			SetObjectiveOn(M.Object13);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 4;
		elseif M.Routine1State == 36 then
			SetTeamNum(M.HadeanCommander, 4);
			SetTeamNum(M.HadeanEscort1, 4);
			SetTeamNum(M.HadeanEscort2, 4);
			SetTeamNum(M.HadeanEscort3, 4);
			SetTeamNum(M.HadeanEscort4, 4);
			Follow(M.HadeanCommander, M.Player, 0);
			Follow(M.HadeanEscort1, M.Player, 0);
			Follow(M.HadeanEscort2, M.Player, 0);
			Follow(M.HadeanEscort3, M.Player, 0);
			Follow(M.HadeanEscort4, M.Player, 0);
			--Follow(M.Object8, M.Player, 0);	--Object8 does not exist!
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 37 then	--LOC_182
			if GetCurrentCommand(M.Procreator) == 0 then
				Stop(M.HadeanCommander, 0);
				M.CanLoseShip = true;--RunSpeed,_Routine3,0,true
				Dropoff(M.Procreator, "RecyclerDeploy", 1);
				M.Routine1State = M.Routine1State + 1;
			end 
		elseif M.Routine1State == 38 then	--LOC_187
			if GetCfg(M.Procreator) ~= "evrecy_m" then
				--M.Variable10 = -GetTime();	--??
				SetScrap(3, 40);
				M.Routine8Active = true;--RunSpeed,_Routine8,1,true
				M.Routine1State = M.Routine1State + 1;
				Patrol(M.HadeanCommander, "Patrol1", 0);
				Patrol(M.HadeanEscort1, "Patrol1", 0); -- moved to an earlier state so they dont hump walls. 
				Patrol(M.HadeanEscort2, "Patrol1", 0);
				Patrol(M.HadeanEscort3, "Patrol1", 0);
				Patrol(M.HadeanEscort4, "Patrol1", 0);
			end
		elseif M.Routine1State == 39 then	--LOC_193
			if not IsAround(M.CerbDroneCarrier) then
				M.Routine1State = M.Routine1State + 1; 
				M.Routine1Timer = GetTime() + 3;
				
			end
		elseif M.Routine1State == 40 then
			RemoveObject(M.Object13);
			
			AudioMessage("fc01_11.wav");	--Thanatos:"Excellent work, Talon Corber..."
			M.Cerb1 = BuildObject("cvtank", 2, "Cerb1");
			Goto(M.Cerb1, M.Procreator, 0);
			M.Cerb2 = BuildObject("cvtank", 2, "Cerb2");
			Goto(M.Cerb2, M.Procreator, 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 60;
		elseif M.Routine1State == 41 then	--LOC_208
			if not IsAround(M.Cerb1) and not IsAround(M.Cerb2) then
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 10;
				Patrol(M.HadeanCommander, "Patrol1", 0);
				Patrol(M.HadeanEscort1, "Patrol1", 0); -- moved to an earlier state so they dont hump walls. 
				Patrol(M.HadeanEscort2, "Patrol1", 0);
				Patrol(M.HadeanEscort3, "Patrol1", 0);
				Patrol(M.HadeanEscort4, "Patrol1", 0);
			elseif(GetDistance(M.Cerb1, M.Procreator) < 300 or GetDistance(M.Cerb2, M.Procreator) < 300) --added to help the player, otherwise this may end in failure early.
			then
			    Attack(M.HadeanCommander, M.Cerb1, 0);
				Attack(M.HadeanEscort1, M.Cerb1, 0); -- moved to an earlier state so they dont hump walls. 
				Attack(M.HadeanEscort2, M.Cerb2, 0);
				Attack(M.HadeanEscort3, M.Cerb2, 0);
				Attack(M.HadeanEscort4, M.Cerb2, 0);
			end
			
		elseif M.Routine1State == 42 then
			AudioMessage("fc01_11b.wav");	--SciWizard:"The Crucible guards a Research Node crucial to the Cerberi Weapons development program..."
			ClearObjectives();
			AddObjective("fc0107.otf", "white");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 10;
		elseif M.Routine1State == 43 then
			M.Routine9Active = true;--RunSpeed,_Routine9,1,false
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 600;
		elseif M.Routine1State == 44 then
			M.Position1 = TerrainFloor(M.Position1) + SetVector(0, 40, 0);
			M.Aurora1 = BuildObject("aurora1", 2, M.Position1);
			M.Aurora2 = BuildObject("aurora2", 2, M.Position1);
			M.Aurora3 = BuildObject("aurora3", 2, M.Position1);
			M.Aurora4 = BuildObject("aurorafield", 2, M.Position1);
			M.Position2 = TerrainFloor(M.Position2) + SetVector(0, 40, 0);
			M.EnergyDisturbanceNav = BuildObject("ibnav", 1, "Investigate1");
			SetObjectiveName(M.EnergyDisturbanceNav, "Energy Disturbance");
			SetObjectiveOn(M.EnergyDisturbanceNav);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 45 then	--LOC_230
			AudioMessage("fc01_12.wav");	--Thanatos:"Our SciWizards have detected a strange energy signature nearby..."
			ClearObjectives();
			AddObjective("fc0102.otf", "white");
			M.Variable2 = GetTime() + 35;
			M.Routine1State = M.Routine1State + 1;
			for i = 1,3 do --at this point the player no longer needs to protect the resourcers.
					if IsAround(M.Resourcers[i]) then
						SetObjectiveOff(M.Resourcers[i]);
					end
				end
		elseif M.Routine1State == 46 then
			if GetDistance(M.Player, M.EnergyDisturbanceNav) < 60 then
				ClearObjectives();
				AddObjective("fc0102.otf", "green");
				AudioMessage("fc01_12A.wav");	--SciWizard:"Your scout's sensors have just detected a teleportation..."
				M.Routine1State = M.Routine1State + 1;
			elseif M.Variable2 < GetTime() then
				M.Variable12 = M.Variable12 + 1;
				if M.Variable12 < 5 then
					M.Routine1State = M.Routine1State - 1;
				else
					AudioMessage("fc01_13.wav");	--Thanatos:"You have failed to investigate the energy source..."
					ClearObjectives();
					AddObjective("fc0103.otf", "red");
					FailMission(GetTime() + 30);	--(bumped up from 10s) TODO: custom failure text for this condition
					M.MissionOver = true;
					M.Routine1State = 99;
				end
			end
		elseif M.Routine1State == 47 then	--LOC_250
			local h = TeleportIn("cvtank", 2, M.Aurora1, 30);
			SetAngle(h, 8000);
			Goto(h, M.Procreator, 0);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 48 then
			if GetTime() < 2000 then
				local h = TeleportIn("cvrbomb",2,M.Aurora1, 30);
				Goto(h, M.Procreator, 0);
				M.Routine1Timer = GetTime() + 20;
			end
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 49 then	--LOC_261
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 110;
		elseif M.Routine1State == 50 then
			local h = TeleportIn("cvtank", 2, M.Aurora1, 30);
			SetAngle(h, 8000);
			Attack(h, M.Procreator, 0);
			local h = TeleportIn("cvrbomb", 2, M.Aurora1, 30);
			SetAngle(h, 10000);
			Goto(h, M.Procreator, 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 110;
		elseif M.Routine1State == 51 then
			local h = TeleportIn("cvdcar", 2, M.Aurora1, 30);
			SetAngle(h, 1500);
			if GetTime() < 2300 or M.Variable1 == 1 then
				SetMaxHealth(h, 5500);
				SetCurHealth(h, 5500);
			else
				SetMaxHealth(h, 6750);
				SetCurHealth(h, 6750);
			end
			Goto(h, M.Procreator, 0);
			M.Routine1State = 47;--to LOC_250
			M.Routine1Timer = GetTime() + 110;
		end
	end
end
--Code for Miller's soldiers ambushing the Cerb drone carrier
function Routine4()
	if M.Routine4Active and M.Routine4Timer < GetTime() then  --added so soldiers don't jump off 
		if M.Routine4State < 3 then
		for i = 0,NUM_SOLDIERS do
				local h = GetHandle(string.format("Soldier%i", i));
			if IsAround(h) then
				Defend(h)
			end
		end
	end
	
		if M.Routine4State == 0 then
			if not IsAround(M.CerbDroneCarrier) then
				M.Routine4State = 4;--to LOC_323
			elseif GetDistance(M.Player, M.CerbDroneCarrier) < 250 then --GetWhoShotMe(M.CerbDroneCarrier) == M.Player
				SetIndependence(M.CerbDroneCarrier, 0);
				FireAt(M.CerbDroneCarrier, nil);
				Follow(M.CerbDroneCarrier, M.Player, 1);
				--ClearObjectives();
				--AddObjective("DEBUG: dcar aggroed.");
				M.Routine4State = M.Routine4State + 1;
			end
		elseif M.Routine4State == 1 then
			if not IsAround(M.CerbDroneCarrier) then
				M.Routine4State = 4;--to LOC_323
			elseif GetDistance(M.Player, "SoldierMeet") < 100 then
				--ClearObjectives();
				SetIndependence(M.CerbDroneCarrier, 0);
				FireAt(M.CerbDroneCarrier, nil);
				--AddObjective("DEBUG: dcar heading to ambush.");
				Goto(M.CerbDroneCarrier, "SoldierMeet", 1);
				M.Routine4State = M.Routine4State + 1;
			end
		elseif M.Routine4State == 2 then
			if not IsAround(M.CerbDroneCarrier) then
				M.Routine4State = 4;--to LOC_323
			elseif GetDistance(M.CerbDroneCarrier, "SoldierMeet") < 30 then
				FireAt(M.CerbDroneCarrier, nil);
				--SetIndependence(M.CerbDroneCarrier, 1);
				--Goto(M.CerbDroneCarrier, "SoldierMeet", 0);
				M.Routine4State = M.Routine4State + 1;
				SetObjectiveOff(M.Object13); --moved line to more accurate timing.
			end
		elseif M.Routine4State == 3 then	--LOC_313
			if not IsAround(M.CerbDroneCarrier) then
				M.Routine4State = M.Routine4State + 1;--to LOC_323
			else
				BuildObject("chainmin", 1, "Mine0");
				BuildObject("chainmin", 1, "Mine1");
				BuildObject("chainmin", 1, "Mine2");
				BuildObject("chainmin", 1, "Mine3");
				BuildObject("chainmin", 1, "Mine4");
				Defend(M.CerbDroneCarrier);
				M.Variable3 = M.Variable3 + 1;
				if M.Variable3 == 1 then
					FireAt(M.CerbDroneCarrier, nil);
				elseif M.Variable3 == 2 then
					SetIndependence(M.CerbDroneCarrier, 1);
				elseif M.Variable3 >= 5 then
					M.Routine4State = M.Routine4State + 1;
				end
				M.Routine4Timer = GetTime() + 15;
			end
		elseif M.Routine4State == 4 then	--LOC_323
			--M.Variable3 = 0;
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 60;
			for i = 0,NUM_SOLDIERS do
				local h = GetHandle(string.format("Soldier%i", i));
				if IsAround(h) then
							Attack(h, M.CerbDroneCarrier);
				
				end
			end
		--elseif M.Routine4State == 6 then	--LOC_325
		--	for i = 0,NUM_SOLDIERS do
			--	local h = GetHandle(string.format("Soldier%i", i));
			--	if IsAround(h) then
				--	M.Variable13 = M.Variable13 + 1;
				--	if M.Variable13 < 3 then
				--		Goto(h, string.format("SoldierDest%i", M.Variable13), 0);
				--	else
						--RemoveObject(h);
				--	end
			--	end
			--end
			--M.Routine4State = M.Routine4State + 1;
		end
	end
end

--Sets the AIP of the Hadean team according to which units should be built
--Starts when Hadean Procreator is deployed.
function Routine8()
	if M.Routine8Active and M.Routine8Timer < GetTime() then
		if M.Routine8State == 0 then
			if not IsAround(M.PlayerScout) then
				SetAIP("fc01_1h.aip", 3);
				ClearObjectives();
				AddObjective("fc0108.otf", "white");
				M.Routine8State = M.Routine8State + 1;
			else
				M.Routine8State = M.Routine8State + 2;
			end
		elseif M.Routine8State == 1 then	--LOC_461
			if M.Variable8 > 0 then
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 2 then	--LOC_465
			M.Routine10Active = true;--RunSpeed,_Routine10,1,true
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 3 then	--LOC_466
			if M.Variable8 < M.Variable9 then
				SetAIP("fc01_1h.aip", 3);
				M.Routine8State = 8;--to LOC_493
			elseif M.Variable4 < M.Variable5 then
				SetAIP("fc01_2h.aip", 3);
				M.Routine8State = 7;--to LOC_489
			elseif CountUnitsNearObject(M.Procreator, M.Variable18, 3, "ebsbay") > 0 and M.Variable6 < M.Variable7 then
				SetAIP("fc01_3h.aip", 3);
				M.Routine8State = 6;--to LOC_485
			else
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 4 then	--LOC_474
			SetAIP("fc01_0h.aip", 3);
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 5 then
			if M.Variable8 < M.Variable9 then
				SetAIP("fc01_1h.aip", 3);
				M.Routine8State = 8;--to LOC_493
			elseif M.Variable4 < M.Variable5 then
				SetAIP("fc01_2h.aip", 3);
				M.Routine8State = 7;--to LOC_489
			elseif CountUnitsNearObject(M.Procreator, M.Variable18, 3, "ebsbay") > 0 and M.Variable6 < M.Variable7 then
				SetAIP("fc01_3h.aip", 3);
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 6 then	--LOC_485
			if M.Variable6 >= M.Variable7 then
				M.Routine8State = 3;--to LOC_466
			end
		elseif M.Routine8State == 7 then	--LOC_489
			if M.Variable4 >= M.Variable5 then
				M.Routine8State = 3;--to LOC_466
			end
		elseif M.Routine8State == 8 then	--LOC_493
			if M.Variable8 >= M.Variable9 then
				M.Routine8State = 3;--to LOC_466
			end
		end
	end
end

--Switches the Cerb AIP if Hadean assault tanks are close to their Foundry
function Routine9()
	if M.Routine9Active and M.Routine9Timer < GetTime() then
		if M.Routine9State == 0 then	--LOC_497
			SetAIP("fc01_0C.aip", 2);
			M.Variable14 = 1100;
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 1 then	--LOC_499
			if CountUnitsNearObject(M.CerbRecycler, M.Variable14, 3, "evatank") > 0 then
				SetAIP("fc01_1C.aip", 2);
				M.Variable14 = 1300;
				M.Routine9State = M.Routine9State + 1;
				M.Routine9Timer = GetTime() + 2;
			else
				M.Routine9Timer = GetTime() + 2;
			end
		elseif M.Routine9State == 2 then	--LOC_504
			AddScrap(2,1);
			if CountUnitsNearObject(M.CerbRecycler, M.Variable14, 3, "evatank") > 0 then
				M.Routine9Timer = GetTime() + 2;
			else
				M.Routine9State = 0;
			end
		end
	end
end

--Gradually increments the target number of ships to be built by the Hadean team
--Builds 2 portals which spawn Cerb units
function Routine10()
	if M.Routine10Active and M.Routine10Timer < GetTime() then
		if M.Routine10State == 0 then
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 180;
		elseif M.Routine10State == 1 then
			M.Variable9 = M.Variable9 + 1;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 180;
		elseif M.Routine10State == 2 then
			M.Variable5 = M.Variable5 + 1;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 250;
		elseif M.Routine10State == 3 then
			M.Variable9 = M.Variable9 + 1;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 20;
		elseif M.Routine10State == 4 then
			M.Variable5 = M.Variable5 + 2;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 360;
		elseif M.Routine10State == 5 then
			M.Variable9 = M.Variable9 + 1;
			M.Variable5 = M.Variable5 + 1;
			M.Variable7 = M.Variable7 + 1;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 300;
		elseif M.Routine10State == 6 then
			M.Variable9 = M.Variable9 + 1;
			M.Variable5 = M.Variable5 + 1;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 240;
		elseif M.Routine10State == 7 then
			M.Variable7 = M.Variable7 + 1;
			M.Position2 = TerrainFloor(M.Position2) + SetVector(0, 40, 0);
			M.Position3 = TerrainFloor(M.Position3) + SetVector(0, 40, 0);
			M.Routine10State = M.Routine10State + 1;
		elseif M.Routine10State == 8 then	--LOC_531
			M.Aurora5 = BuildObject("aurora1", 2, BuildDirectionalMatrix(M.Position3));
			M.Aurora6 = BuildObject("aurora2", 2, BuildDirectionalMatrix(M.Position3));
			M.Aurora7 = BuildObject("aurora3", 2, BuildDirectionalMatrix(M.Position3));
			M.Aurora8 = BuildObject("aurorafield", 2, BuildDirectionalMatrix(M.Position3));
			AudioMessage("fc01_15.wav");	--Thanatos:"The Cerberi have created one of their energy portals near our base..."
			ClearObjectives();
			AddObjective("fc0111.otf", "white");
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 60;
		elseif M.Routine10State == 9 then
			M.Routine11Active = true;--RunSpeed,_Routine11,1,true
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 250;
		elseif M.Routine10State == 10 then
			M.Routine11Active = false;--RunSpeed,_Routine11,0,true
			RemoveObject(M.Aurora5);
			RemoveObject(M.Aurora6);
			RemoveObject(M.Aurora7);
			RemoveObject(M.Aurora8);
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 240;
		elseif M.Routine10State == 11 then
			M.Variable19 = 1;
			M.Aurora5 = BuildObject("aurora1", 2, BuildDirectionalMatrix(M.Position2));
			M.Aurora6 = BuildObject("aurora2", 2, BuildDirectionalMatrix(M.Position2));
			M.Aurora7 = BuildObject("aurora3", 2, BuildDirectionalMatrix(M.Position2));
			M.Aurora8 = BuildObject("aurorafield", 2, BuildDirectionalMatrix(M.Position2));
			ClearObjectives();
			AddObjective("fc0111.otf", "white");
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 60;
		elseif M.Routine10State == 12 then
			M.Routine11Active = true;--RunSpeed,_Routine11,1,true
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 250;
		elseif M.Routine10State == 13 then
			M.Routine11Active = false;--RunSpeed,_Routine11,0,true
			RemoveObject(M.Aurora5);
			RemoveObject(M.Aurora6);
			RemoveObject(M.Aurora7);
			RemoveObject(M.Aurora8);
			M.Routine10State = 8;--to LOC_531
			M.Routine10Timer = GetTime() + 300;
		end	
	end
end

--teleports in a Cerb walker every 35s from the currently active portal
function Routine11()
	if M.Routine11Active and M.Routine11Timer < GetTime() then
		M.Object23 = TeleportIn("cvwalk", 2, M.Aurora5, 10);
		if M.Variable19 == 1 then
			SetAngle(M.Object23, 18000);
		end
		Goto(M.Object23, M.Procreator, 0);
		M.Routine11Timer = GetTime() + 35;
	end
end

--Sets team of new object to 1 twice?? Seems redundant.
--function Routine13()
--	if GetTeamNum(M.PlayerTrucks) ~= 1 then
--		SetTeamNum(M.PlayerTrucks, 1);
--	end
--end

--sends groups of Hadean atanks against Cerb gtows
function Routine14()
	if M.Routine14Active and M.Routine14Timer < GetTime() then
		if M.Routine14State == 0 then	--LOC_603
			if IsAround(M.HadeanAssaultTanks[1]) and IsAround(M.HadeanAssaultTanks[2]) and IsAround(M.HadeanAssaultTanks[3]) then
				M.TargetedCerbGunTower = nil;
				for i = 1,NUM_GTOWS do
					if IsAround(M.CerbGunTowers[i]) then
						M.TargetedCerbGunTower = M.CerbGunTowers[i];
						break;
					end
				end
				M.Routine14Active = (M.TargetedCerbGunTower ~= nil);	--stop sending waves if final gtow is destroyed
				M.Routine14State = M.Routine14State + 1;
			end
		elseif M.Routine14State == 1 then
			if (not IsAround(M.HadeanAssaultTanks[1]) or GetDistance(M.HadeanAssaultTanks[1], M.CerbRecycler) < 700 or GetCurrentCommand(M.HadeanAssaultTanks[1]) ~= 3)
			and (not IsAround(M.HadeanAssaultTanks[2]) or GetDistance(M.HadeanAssaultTanks[2], M.CerbRecycler) < 700 or GetCurrentCommand(M.HadeanAssaultTanks[2]) ~= 3)
			and (not IsAround(M.HadeanAssaultTanks[3]) or GetDistance(M.HadeanAssaultTanks[3], M.CerbRecycler) < 700 or GetCurrentCommand(M.HadeanAssaultTanks[3]) ~= 3) then
				M.Variable1 = 1;
				AudioMessage("fc01_14.wav");	--Thanatos:"The assault tanks are moving to attack the Gun Towers..."
				SetObjectiveName(M.TargetedCerbGunTower, "Targeted Gun Tower");
				SetObjectiveOn(M.TargetedCerbGunTower);
				if GetDistance(M.TargetedCerbGunTower, M.HadeanAssaultTanks[1]) > 400 or
				   GetDistance(M.TargetedCerbGunTower, M.HadeanAssaultTanks[2]) > 400 or
				   GetDistance(M.TargetedCerbGunTower, M.HadeanAssaultTanks[3]) > 400 then
					Goto(M.HadeanAssaultTanks[1], "StagePoint1B", 0);
					Goto(M.HadeanAssaultTanks[2], "StagePoint2B", 0);
					Goto(M.HadeanAssaultTanks[3], "StagePoint3B", 0);
					M.Routine14State = M.Routine14State + 1;
				else
					M.Routine14State = M.Routine14State + 2;--to LOC_648
			    end
			end
		elseif M.Routine14State == 2 then	--LOC_642
			if GetCurrentCommand(M.HadeanAssaultTanks[1]) == 0 and 
			   GetCurrentCommand(M.HadeanAssaultTanks[2]) == 0 and 
			   GetCurrentCommand(M.HadeanAssaultTanks[3]) == 0 then
				M.Routine14State = M.Routine14State + 1;
			end
		elseif M.Routine14State == 3 then	--LOC_648
			Attack(M.HadeanAssaultTanks[1], M.TargetedCerbGunTower, 0);
			Attack(M.HadeanAssaultTanks[2], M.TargetedCerbGunTower, 0);
			Attack(M.HadeanAssaultTanks[3], M.TargetedCerbGunTower, 0);
			M.Routine14State = M.Routine14State + 1;
		elseif M.Routine14State == 4 then	--LOC_651
			if GetCurrentCommand(M.HadeanAssaultTanks[1]) ~= 4 and 
			   GetCurrentCommand(M.HadeanAssaultTanks[2]) ~= 4 and 
			   GetCurrentCommand(M.HadeanAssaultTanks[3]) ~= 4 then 
				SetObjectiveName(M.TargetedCerbGunTower, "Gun Tower");
				SetObjectiveOff(M.TargetedCerbGunTower);
				M.Variable1 = 0;
				if GetDistance(M.HadeanAssaultTanks[1], M.CerbRecycler) < 400 then
					Goto(M.HadeanAssaultTanks[1], "StagePoint1B", 0);
				end
				if GetDistance(M.HadeanAssaultTanks[2], M.CerbRecycler) < 400 then
					Goto(M.HadeanAssaultTanks[2], "StagePoint2B", 0);
				end
				if GetDistance(M.HadeanAssaultTanks[3], M.CerbRecycler) < 400 then
					Goto(M.HadeanAssaultTanks[3], "StagePoint3B", 0);
				end
				M.Routine14State = 0;--to LOC_603
			end
		end
	end
end

--Sets any pilots ejected from player controlled Hadean ships back to team 3
--function HandleEjectedPilots()
--	if #M.EjectedPilots > 0 then
--		local pilot = M.EjectedPilots[1];
--		SetTeamNum(pilot, 3);
--		table.remove(M.EjectedPilots, 1);
--	end
--end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if not IsAround(M.Procreator) then
			ClearObjectives();
			AddObjective("fc0104.otf", "red");
			AudioMessage("fc01_16.wav");	--Thanatos:"You failed to defend the base..."
			FailMission(GetTime() + 13, "FC01L1.txt");
			M.MissionOver = true;
		elseif not M.CanLoseShip and not IsAround(M.PlayerScout) then
			ClearObjectives();
			AddObjective("fc0106.otf", "red");
			FailMission(GetTime() + 10, "FC01L2.txt");
			M.MissionOver = true;
		elseif not (IsAround(M.CerbGunTowers[1]) or IsAround(M.CerbGunTowers[2]) 
				   or IsAround(M.CerbGunTowers[3]) or IsAround(M.CerbGunTowers[4]) 
				   or IsAround(M.CerbGunTowers[5])) then
			M.Routine10Active = false;
			AudioMessage("fc01_18.wav");	--Thanatos:"The last Gun Tower has been destroyed..."
			ClearObjectives();
			AddObjective("fc0110.otf", "green");
			SucceedMission(GetTime() + 30, "FC01W1.txt");
			M.MissionOver = true;
		end
	end
end
