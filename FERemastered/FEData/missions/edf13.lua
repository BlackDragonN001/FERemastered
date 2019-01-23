assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
require('_FECore');

--Strings
local _Text1 = "Search the caves for the two\nearly-warning control nodes.\nEscort Captain Eisenstein to\nboth stations. Be careful--\nthese caves are very unstable.";
local _Text2 = "Now, find the other control\nstation and escort Captain\nEisenstein there.";
local _Text3 = "Captain Eisenstein has learned\nof a service elevator somewhere\nnearby. Find the exit, so he\ncan hot-wire the elevator.";
local _Text4 = "Escort your convoy to the exit\nyou have found. Eisenstein will\nget the elevator working.";
local _Text5 = "There's the exit--but we'll\nneed to disable both control\nstations before we can leave.";
local _Text6 = "There's the exit we need. Get\nyour units to that service\nelevator so Eisenstein can get\nus out of these caves.";
local _Text7 = "Here's the elevator. Captain\nEisenstein says he can have it\nrunning in just a few minutes.";
local _Text8 = "Captain Eisenstein's Tech\nSupport Vehicle was crucial to\nthis mission. Without it, we\nhave no hope of penetrating\nFacility's defenses.";
local _Text9 = "You have failed utterly. The\nEDF-Recycler VENGEANCE is lost, \nand her entire crew has been\ncaptured.";
local _Text10 = "Data Point: 'TARTARUS IV WAS\n&>$ANCIENT HADEAN RESEARCH BASE\n@#^DEFENSE SYSTEM#$%COMBAT FURY\nAGGRESSI*#$ EST. LOCAT&: HUMAN\nSOLA& SYS#'";
local _Text11 = "Data Point: 'TARTARUS IV WAS\nORIGIN@!$ NEXUS BATTLE TECH*&@\nADVANCED *&#OMNI-SHIELD, PULSAR\nCANNON*#! QUANTUM PROP&# TO*@\nCOMBAT FURY THREAT*&'";
local _Text12 = "WARNING: Structural compromise\ndetected! Cave walls weakened\nin vicinity of VENGEANCE; \ncollapse imminent!";

local M = {
-- Bools
	MissionOver = false,
	CaveCollapse = false,
	
-- Floats
	Routine1Timer = 0.0,
	Routine2Timer = 0.0,
	Routine5Timer = 0.0,
	Routine6Timer = 0.0,
	CaveCollapseTime = 0.0,

-- Handles
	HadeanPatrol1 = nil,
	HadeanPatrol2 = nil,
	Recycler = nil,
	TechSupport = nil,
	TechCenter1 = nil,
	TechCenter2 = nil,
	ExitShaft = nil,
	ServiceTruck = nil,
	Player = nil,
	HadeanTurr1 = nil,
	HadeanTurr2 = nil,
	PlayerScout = nil,
	HadeanScout = nil,
-- Ints
	TPS = 10,
	Routine1State = 0,
	Routine2State = 0,
	Routine5State = 0,
	Routine6State = 0,
	Variable1 = 0,	--player found tech center 1
	Variable2 = 0,	--player found tech center 2
	Variable3 = 0,	--hacked 1st tech center
	Variable4 = 0, 	--hacked 2nd tech center
	Variable5 = 0,	--player found the exit shaft
	Variable6 = 0,	--number of tech centers hacked
--Vectors

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
	PreloadODF("ivrecy");
	PreloadODF("ivscout");
	PreloadODF("ivtank");
	PreloadODF("ivtug");
	PreloadODF("ivserv");
	PreloadODF("evtank");
	PreloadODF("evscout_e13");
	PreloadODF("evturr");
	PreloadODF("firefly");
	
	--Preload Audio
	local preloadAudio = {
		"edf13_01.wav",
		"edf13_02.wav",	
		"edf13_02b.wav",	
		"edf13_03.wav",	
		"edf13_04.wav",	
		"edf13_05.wav",	
		"edf13_06.wav",	
		"edf13_07.wav",	
		"edf13_08a.wav",	
		"edf13_08b.wav",	
		"edf13_09.wav",	
		"edf13_10.wav",	
		"edf13_11.wav",	
		"edf13_11b.wav",	
	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function GetHandleOrDie(name)
	return GetHandle(name) or error("Error: object '"..name.."' not found!", 2);
end

function Start()

	_FECore.Start();
	
	M.TechCenter1 = GetHandleOrDie("Tech1");
	M.TechCenter2 = GetHandleOrDie("Tech2");
	M.ExitShaft = GetHandleOrDie("Shaft");
	M.Recycler = BuildObject("ivrecy", 1, "Recycler");
	M.PlayerScout = BuildObject("ivscout", 1, "Recycler");	
	M.ServiceTruck = BuildObject("ivserv", 1, "ServTruck");
	M.TechSupport = BuildObject("ivtug", 1, "Techie");
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)

	_FECore.AddObject(h);

	if IsOdf(h, "ibrecy") then	--Player tried to deploy the recycler
		SetTeamNum(M.Recycler, 0);
		StartEarthQuake(30.0);
		AddObjective(_Text12, "red");
		AudioMessage("edf13_07.wav");	--Eisenstein:"Our instruments are showing dangerous weaknesses in the cave walls near the Recycler!..."
		M.CaveCollapse = true;
		M.CaveCollapseTime = GetTime() + 12;
	end
end

function Update()

	_FECore.Update();
	
	M.Player = GetPlayerHandle();
	Routine1();
	Routine2();
	Routine3();
	Routine5();
	Routine6();
	CheckStuffIsAlive();
	
	if M.CaveCollapse and M.CaveCollapseTime < GetTime() and not M.MissionOver then
		AudioMessage("xcollapse.wav");
		SetColorFade(100.0, 0.1, 0);
		FailMission(GetTime() + 8, "edf13L3.txt");
		M.MissionOver = true;
	end
end

--main mission state.
--Mission succeeds when player gets recy and tech support crew 
--to the exit shaft after hacking the tech centers.
function Routine1()
	if M.Routine1Timer < GetTime() then
		if M.Routine1State == 0 then
			SetGroup(M.Recycler, 0);
			SetGroup(M.PlayerScout, 1);
			SetGroup(M.ServiceTruck, 2);
			SetGroup(M.TechSupport, 3);
			SetObjectiveName(M.TechSupport, "Tech Support Crew");
			SetObjectiveName(M.TechCenter1, "Technical Center");
			SetPerceivedTeam(M.TechCenter1, 1);
			SetObjectiveName(M.TechCenter2, "Technical Center");
			SetPerceivedTeam(M.TechCenter2, 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 4;
		elseif M.Routine1State == 1 then
			AudioMessage("edf13_01.wav");	--Eisenstein:"General Thanatos says these caves hold the primary control stations for this region's early warning systems..."
			ClearObjectives();
			AddObjective(_Text1, "white");
			Goto(M.TechSupport, "RecyclerDest", 0);
			SetObjectiveOn(M.TechSupport);
			Goto(M.ServiceTruck, "ServDest", 0);
			Goto(M.Recycler, "RecyclerDest", 0);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 2 then	--LOC_23
			if M.Variable3 == 0 and IsAround(M.TechCenter1) and GetDistance(M.TechSupport, M.TechCenter1) < 140 then
				Goto(M.TechSupport, "TechPoint1", 1);
				M.Routine1State = M.Routine1State + 1;
			else
				M.Routine1State = 5;--to LOC_48
			end
		elseif M.Routine1State == 3 then	--LOC_30
			if GetCurrentCommand(M.TechSupport) == 0 then
				M.Variable3 = 1;
				M.Variable6 = M.Variable6 + 1;
				if M.Variable6 < 2 then
					ClearObjectives();
					AddObjective(_Text10, "white");
					AudioMessage("edf13_05.wav");	--Eisenstein:"Hey, here is something interesting, sir..."
				else
					ClearObjectives();
					AddObjective(_Text11, "white");
					AudioMessage("edf13_06.wav");	--Eisenstein:"Just give me another minute, sir..."
				end
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 30;
			end
		elseif M.Routine1State == 4 then	--LOC_42
			Stop(M.TechSupport, 0);
			if M.Variable4 > 0 then
				M.Routine1State = 8;--to LOC_74
			else
				ClearObjectives();
				AddObjective(_Text2, "white");
				AudioMessage("edf13_03.wav");
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 5 then	--LOC_48
			if M.Variable4 == 0 and IsAround(M.TechCenter2) and GetDistance(M.TechSupport, M.TechCenter2) < 140 then
				Goto(M.TechSupport, "TechPoint2", 1);
				M.Routine1State = M.Routine1State + 1;
			else
				M.Routine1State = 2;--to LOC_23
			end
		elseif M.Routine1State == 6 then	--LOC_55
			if GetCurrentCommand(M.TechSupport) == 0 then
				M.Variable4 = 1;
				M.Variable6 = M.Variable6 + 1;
				if M.Variable6 < 2 then
					ClearObjectives();
					AddObjective(_Text10, "white");
					AudioMessage("edf13_05.wav");	--Eisenstein:"Hey, here is something interesting, sir..."
				else
					ClearObjectives();
					AddObjective(_Text11, "white");
					AudioMessage("edf13_06.wav");	--Eisenstein:"Just give me another minute, sir..."
				end
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 30;
			end
		elseif M.Routine1State == 7 then	--LOC_67
			Stop(M.TechSupport, 0);
			if M.Variable3 > 0 then
				M.Routine1State = M.Routine1State + 1;
			else
				M.Routine1State = 2;--to LOC_23
			end	
		elseif M.Routine1State == 8 then	--LOC_74
			if M.Variable5 == 0 then
				AudioMessage("edf13_04.wav");	--Eisenstein:"According to the Hadean computer, there is an elevator shaft in this cave..."
				AddObjective(_Text3, "white");
				M.Routine1State = M.Routine1State + 1;
			else
				M.Routine1State = 10;--to LOC_81
			end	
		elseif M.Routine1State == 9 then	--LOC_78
			if M.Variable5 > 0 then
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 10 then	--LOC_81
			ClearObjectives();
			AddObjective(_Text4, "white");
			AudioMessage("edf13_09.wav");	--Eisenstein:"This takes care of the early warning systems for this sector, sir..."
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 11 then	--LOC_84
			if GetDistance(M.Player, M.ExitShaft) < 80
			   and GetDistance(M.TechSupport, M.ExitShaft) < 80
			   and GetDistance(M.Recycler, M.ExitShaft) < 80 then
				AudioMessage("edf13_10.wav");	--Eisenstein:"Here's the elevator, sir..."
				ClearObjectives();
				AddObjective(_Text7, "green");
				SucceedMission(GetTime() + 14, "edf13w1.txt");
				M.Routine1State = M.Routine1State + 1;
		    end
		end
	end
end

--handles respawning Hadean patrols
function Routine2()
	if M.Routine2Timer < GetTime() then
		if M.Routine2State == 0 then
			SpawnBirds(0, 5, "firefly", 0, "FireFly1");
			SpawnBirds(1, 5, "firefly", 0, "FireFly2");
			M.HadeanPatrol1 = BuildObject("evtank", 2, "Spawn1");
			Patrol(M.HadeanPatrol1, "Patrol1", 0);
			M.HadeanScout = BuildObject("evscout_e13", 2, "Spawn1");
			Patrol(M.HadeanScout, "Patrol1", 0);
			M.HadeanPatrol2 = BuildObject("evtank", 2, "Spawn2");
			Patrol(M.HadeanPatrol2, "Patrol2", 0);
			M.HadeanScout = BuildObject("evscout_e13", 2, "Spawn2");
			Patrol(M.HadeanScout, "Patrol2", 0);
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 1 then	--LOC_105
			if GetTeamNum(M.HadeanPatrol1) ~= 2 or not HasPilot(M.HadeanPatrol1) then
				M.HadeanPatrol1 = BuildObject("evtank", 2, "Spawn1");
				SetMaxAmmo(M.HadeanPatrol1, 4000);
				SetCurAmmo(M.HadeanPatrol1, 4000);
				Patrol(M.HadeanPatrol1, "Patrol1", 0);
				M.HadeanScout = BuildObject("evscout_e13", 2, "Spawn1");
				Patrol(M.HadeanScout, "Patrol1", 0);
			end
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 40;	--bumped up the respawn time for hadean patrols from 20
		elseif M.Routine2State == 2 then	--LOC_116
			if GetTeamNum(M.HadeanPatrol2) ~= 2 or not HasPilot(M.HadeanPatrol2) then
				M.HadeanPatrol2 = BuildObject("evtank", 2, "Spawn2");
				SetMaxAmmo(M.HadeanPatrol2, 4000);
				SetCurAmmo(M.HadeanPatrol2, 4000);
				Patrol(M.HadeanPatrol2, "Patrol2", 0);
				M.HadeanScout = BuildObject("evscout_e13", 2, "Spawn2");
				Patrol(M.HadeanScout, "Patrol2", 0);
			end
			M.Routine2State = 1;--to LOC_105
			M.Routine2Timer = GetTime() + 40; 	--bumped up the respawn time for hadean patrols from 20
		end
	end
end

--plays an audio message when player locates the exit shaft.
--message is different if player has already hacked the tech centers
function Routine3()
	if M.Variable5 == 0 and GetDistance(M.Player, M.ExitShaft) < 230 then
		if M.Variable3 == 1 and M.Variable4 == 1 then
			ClearObjectives();
			AddObjective(_Text6, "white");
			AudioMessage("edf13_11b.wav");	--Eisenstein:"There's the elevator shaft, major..."
		else
			ClearObjectives();
			AudioMessage("edf13_11.wav");	--Eisenstein:"There's an elevator shaft, major..."
		end
		M.Variable5 = 1;
	end
end

--spawns turrets that guard the exit shaft
function Routine5()
	if M.Routine5Timer < GetTime() then
		if M.Routine5State == 0 then
			M.HadeanTurr1 = BuildObject("evturr", 2, "Turret1");
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 1 then	--LOC_164
			if not IsAround(M.HadeanTurr1) then
				M.HadeanTurr1 = BuildObject("evturr", 2, "Spawn2");
				Goto(M.HadeanTurr1, "Turret1", 0);
			end
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 40;
		elseif M.Routine5State == 2 then	--LOC_169
			if not IsAround(M.HadeanTurr2) then
				M.HadeanTurr2 = BuildObject("evturr", 2, "Spawn2");
				Goto(M.HadeanTurr2, "Turret2", 0);
			end
			M.Routine5State = 1;--to LOC_164
			M.Routine5Timer = GetTime() + 60;
		end
	end
end

--highlights the tech center and plays an audio message when player gets into range
function Routine6()
	if M.Routine6Timer < GetTime() then
		if M.Routine6State == 0 then
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 20;
		elseif M.Routine6State == 1 then
			if M.Variable1 == 0 and GetDistance(M.Player, M.TechCenter1) < 275 then
				SetObjectiveOn(M.TechCenter1);
				if M.Variable2 == 0 then
					AudioMessage("edf13_02.wav");	--Eisenstein:"There's one of the control stations, sir..."
				else
					AudioMessage("edf13_02b.wav");	--Eisenstein:"There's the other control station..."
					M.Routine6State = M.Routine6State + 1;
				end
				M.Variable1 = 1;
			end
			if M.Variable2 == 0 and GetDistance(M.Player, M.TechCenter2) < 275 then
				SetObjectiveOn(M.TechCenter2);
				if M.Variable1 == 0 then
					AudioMessage("edf13_02.wav");	--Eisenstein:"There's one of the control stations, sir..."
				else
					AudioMessage("edf13_02b.wav");	--Eisenstein:"There's the other control station..."
					M.Routine6State = M.Routine6State + 1;
				end
				M.Variable2 = 1;
			end
		end
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if not IsAround(M.Recycler) then
			ClearObjectives();
			AddObjective(_Text9, "red");
			AudioMessage("edf13_08b.wav");	--Eisenstein:"Sir, we lost the Vengeance..."
			FailMission(GetTime() + 15, "edf13L2.txt");
			M.MissionOver = true;
		elseif not IsAround(M.TechSupport) then
			ClearObjectives();
			AddObjective(_Text8, "red");
			AudioMessage("edf13_08a.wav");	--Wong:"I've lost Captain Eisenstein's signal..."
			FailMission(GetTime() + 15, "edf13L1.txt");
			M.MissionOver = true;
		end
	end
end
