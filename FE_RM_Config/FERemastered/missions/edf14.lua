assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

local NUM_PATROLS = 5;	--pairs of Hadean scouts that will try to warn their base if attacked
local NUM_JAMMERS = 5;

local M = {
-- Bools
	MissionOver = false,
	CheckHadeanBuilder = true,
	Routine2Active = false,
	Routine3Active = true,
	Routine5Active = false,
	
-- Floats
	Routine1Timer = 0.0,
	Routine3Timer = 0.0,
	Routine5Timer = 0.0,
	Routine8Timer = 0.0,

-- Handles
	Schultz = nil,
	Player = nil,
	HadeanBuilder = nil,
	Recycler = nil,
	NextNavBeacon = nil,
	HadeanScoutA = nil,
	HadeanScoutB = nil,
	CommJammers = {},
	HadeanGtow1 = nil,
	HadeanGtow2 = nil,
	GeothermalControlCen = nil,	
-- Ints
	TPS = 10,
	Routine1State = 0,
	Routine3State = 0,
	Routine5State = 0,
	Routine8State = 0,
	Variable1 = 0,	--Jammers built
	Variable2 = 0,	--Hadean Scout index
	Variable4 = 0,	--player has deployed a scav
	Variable5 = 0,	--whether player is using Cerb units to attack
	Variable8 = 0,	--Player warned about not using Cerb units to attack gtows

--Vectors
	Position2 = SetVector(-430,100,-720),	--Pilots spawn location
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
	
	PreloadODF("ivrecy_e14");
	PreloadODF("evcons_e14");
	
	local preloadAudio = {
		"EDF14z01.wav",
		"EDF14z02.wav",
		"EDF14z03.wav",
		"EDF14z04.wav",
		"EDF14z04a.wav",
		"EDF14z04b.wav",
		"EDF14z05.wav",
		"EDF14z05a.wav",
		"EDF14z05b.wav",
		"EDF14z06.wav",
		"EDF14z07.wav",
		"EDF14z08.wav",
		"EDF14z09.wav",
		"edf14z10.wav"
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
	
	M.HadeanBuilder = BuildObject("evcons_e14",1,"Constructor");
	M.Recycler = BuildObject("ivrecy_e14", 1, "Recycler");
	M.HadeanGtow1 = GetHandle("gtow1");
	M.HadeanGtow2 = GetHandle("gtow2");
	M.GeothermalControlCen = GetHandle("TechCenter");
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)

	_FECore.AddObject(h);
	
	if GetOdf(h) == "ebcbun_e14.odf" then
		M.CommJammers[M.Variable1] = h;
	elseif GetOdf(h) == "ibscav.odf" then
		M.Variable4 = 1;
	elseif GetOdf(h) == "evtanku.odf" then
		Patrol(h, "HadeanDefend", 0);
	elseif GetOdf(h) == "ispilo.odf" then
		--if player orders Schultz to pick them up
		local h2 = GetNearestVehicle(h);
		if h2 == M.Schultz and GetDistance(h2, h) < 15 then
			SetObjectiveOff(M.Schultz);
			SetObjectiveName(M.Schultz, "Spider Tank");
			M.Routine5Active = true; --RunSpeed,_Routine5,1,true
			M.Schultz = h;
		end
	end	
end

function PreSnipe(curWorld, shooterHandle, victimHandle, ordnanceTeam, ordnanceODF)
	if GetOdf(victimHandle) == "evscout.odf" then
		--spawn EDF pilot to commandeer the sniped ship
		local pilot = BuildObject("ispilo", 2, M.Position2);
		SetIndependence(pilot, 0);	--stops pilots from sometimes trying to attack the empty ships instead of getting in
		Goto(pilot, victimHandle, 1);
		SetObjectiveOn(pilot);
		SetObjectiveOff(victimHandle);
	end

	-- Return a value to stop an Invalid Params in console - AI_Unit
	return 0; -- PRESNIPE_KILLPILOT 
end

function Update()

	_FECore.Update();
	
	M.Player = GetPlayerHandle();
	Routine1();
	Routine2();
	Routine3();
	Routine5();
	Routine8();
end

--main mission state.
function Routine1()
	if M.Routine1Timer < GetTime() then
		if M.Routine1State == 0 then
			Ally(1, 2);
			SetScrap(1, 40);
			SetObjectiveOn(M.HadeanBuilder);
			Dropoff(M.Recycler, "Deploy", 1);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 1 then	--LOC_6
			Build(M.HadeanBuilder, "ebcbun_e14", 1);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 2 then
			Dropoff(M.HadeanBuilder, "Jam"..tostring(M.Variable1), 1);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 3 then	--LOC_8
			if GetCurrentCommand(M.HadeanBuilder) == 0 then
				M.Variable1 = M.Variable1 + 1;
				RemoveObject(M.NextNavBeacon);
				M.NextNavBeacon = BuildObject("ibnav", 1, "Jam"..tostring(M.Variable1));
				SetObjectiveName(M.NextNavBeacon, "Build Comm Jammer "..tostring(M.Variable1));
				SetObjectiveOn(M.NextNavBeacon);
				if M.Variable1 < 6 then
					M.Routine1State = 1;--to LOC_6
				else
					AudioMessage("EDF14z02.wav");	--Stewart:"The Hadean Creator has self destructed as ordered..."
					RemoveObject(M.NextNavBeacon);
					M.CheckHadeanBuilder = false;--RunSpeed,_Routine7,0,true
					EjectPilot(M.HadeanBuilder);
					Goto(BuildObject("evturr", 5, "Spawn1"), "Turret1", 0);
					Goto(BuildObject("evturr", 5, "Spawn1"), "Turret2", 0);
					Goto(BuildObject("evturr", 5, "Spawn1"), "Turret3", 0);
					M.NextNavBeacon = BuildObject("ibnav", 1, "nav1");
					SetObjectiveName(M.NextNavBeacon, "Biometal Pool");
					SetObjectiveOn(M.NextNavBeacon);
					ClearObjectives();
					AddObjective("edf1404.otf", "white");
					M.Routine1State = M.Routine1State + 1;
					M.Routine1Timer = GetTime() + 60;
				end
			end
		elseif M.Routine1State == 4 then
			SetAIP("edf14_0.aip", 5);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 5 then	--LOC_34
			if M.Variable4 > 0 then
				AudioMessage("EDF14z03.wav");	--Stewart:"The Vengeance has been programmed to manufacture counterfeit Cerberi Spider Tanks and Sirens..."
				ClearObjectives();
				AddObjective("edf1405.otf", "white");
				SetObjectiveOn(M.HadeanGtow1);
				SetObjectiveOn(M.HadeanGtow2);
				M.Routine2Active = true;--RunSpeed,_Routine2,1,true
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 6 then	--LOC_44
			local gtow1Alive = IsAround(M.HadeanGtow1);
			local gtow2Alive = IsAround(M.HadeanGtow2);
			if M.Variable5 == 0 then
				if gtow1Alive ~= gtow2Alive and M.Variable8 == 0 then
					--player destroyed one of the gtows without using Cerb units
					ClearObjectives();
					AddObjective("edf1406.otf", "red");
					AudioMessage("EDF14z04a.wav");	--Stewart:"Perhaps I didn't make myself clear enough..."
					M.Variable8 = 1;
					M.Routine1State = M.Routine1State + 1;
					M.Routine1Timer = GetTime() + 1;
				elseif not gtow1Alive and not gtow2Alive then
					--player destroyed both gtows without using Cerb units.
					AudioMessage("EDF14z04b.wav");	--Stewart:"The whole point of this deception was to attack the gun towers with Cerberi units..."
					ClearObjectives();
					AddObjective("edf1407.otf", "red");
					FailMission(GetTime() + 20, "EDF14l4.txt");
					M.MissionOver = true;
					M.Routine1State = 99;
				end
			elseif not gtow1Alive and not gtow2Alive then
				--player destroyed the gtows using Cerb units
				AudioMessage("EDF14z04.wav");	--Stewart:"Well done. The Hadeans have reported a Cerberi attack..."
				M.Routine2Active = false;--RunSpeed,_Routine2,0,false
				BuildObject("evserv", 5, "Serv1");
				ClearObjectives();
				AddObjective("edf1408.otf", "white");
				SetObjectiveName(M.GeothermalControlCen, "Geothermal Control Center");				
				M.Routine1State = 9;
			end
		elseif M.Routine1State == 7 then
			ClearObjectives();
			AddObjective(_Text6, "white");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 8 then
			ClearObjectives();
			AddObjective(_Text6, "red");
			M.Routine1State = 6;--to LOC_44
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 9 then	--LOC_97
			if GetDistance(M.Player, M.GeothermalControlCen) < 300 then
				SetObjectiveOn(M.GeothermalControlCen);
				AudioMessage("edf14z10.wav");	--Stewart:"There's the Geothermal Control Station..."
				ClearObjectives();
				AddObjective("edf1410.otf", "green");
				M.Routine1State = M.Routine1State + 1;
			end	
		elseif M.Routine1State == 10 then	--LOC_104
			if not IsAround(M.GeothermalControlCen) then
				AudioMessage("EDF14z05.wav");	--Stewart:"Well done, Joseph..."
				ClearObjectives();
				AddObjective("edf1409.otf", "green");
				SucceedMission(GetTime() + 20, "edf14w1.txt");
				M.Routine1State = M.Routine1State + 1;
			end
		end	
	end
end

--checks to see if player is using Cerb units to attack the Hadean gtows
function Routine2()
	if M.Routine2Active then
		if IsAround(M.HadeanGtow1) then
			local h1 = GetWhoShotMe(M.HadeanGtow1);
			if GetOdf(h1) == "ivspider.odf" or GetOdf(h1) == "ivsiren.odf" then
				M.Variable5 = 1;
			end
		end
		if IsAround(M.HadeanGtow2) then
			local h2 = GetWhoShotMe(M.HadeanGtow2);
			if GetOdf(h2) == "ivspider.odf" or GetOdf(h2) == "ivsiren.odf" then
				M.Variable5 = 1;
			end
		end
	end
end

--retreats scouts back to their base when player attacks them
function Routine3()
	if M.Routine3Active and M.Routine3Timer < GetTime() then
		if M.Routine3State == 0 then	--LOC_135
			M.HadeanScoutA = GetHandle("ScoutA"..tostring(M.Variable2));
			M.HadeanScoutB = GetHandle("ScoutB"..tostring(M.Variable2));
			if GetDistance(M.HadeanScoutA, "Retreat") < 100 or GetDistance(M.HadeanScoutB, "Retreat") < 100 then
				ClearObjectives();
				AddObjective("edf1403.otf", "red");
				FailMission(GetTime() + 11, "edf14L1.txt");
				M.Routine3State = 99;
			elseif IsAlive(M.HadeanScoutA) and GetTeamNum(M.HadeanScoutA) == 2 and GetCurrentCommand(M.HadeanScoutA) == 0 then
				SetObjectiveOff(M.HadeanScoutA);
				Patrol(M.HadeanScoutA, "FriendPatrol", 1);
			elseif IsAlive(M.HadeanScoutB) and GetTeamNum(M.HadeanScoutB) == 2 and GetCurrentCommand(M.HadeanScoutB) == 0 then
				SetObjectiveOff(M.HadeanScoutB);
				Patrol(M.HadeanScoutB, "FriendPatrol", 1);
			elseif IsAggroed(M.HadeanScoutA) and not IsNeutralized(M.HadeanScoutB) and not IsRunning(M.HadeanScoutB) then
				M.Routine3State = 1;
				M.Routine3Timer = GetTime() + 3;
			elseif IsAggroed(M.HadeanScoutB) and not IsNeutralized(M.HadeanScoutA) and not IsRunning(M.HadeanScoutA) then
				M.Routine3State = 2;
				M.Routine3Timer = GetTime() + 3;
			else
				M.Variable2 = (M.Variable2 + 1) % NUM_PATROLS;	--cycle through the rest of the pairs of scouts
			end
		elseif M.Routine3State == 1 then
			Retreat(M.HadeanScoutB, "Retreat", 1);
			SetObjectiveOn(M.HadeanScoutB);
			SetUserTarget(M.HadeanScoutB);
			AudioMessage("EDF14z05a.wav");	--Stewart:"There's another scout! Don't let him get away!"
			if IsAlive(M.HadeanScoutA) then
				if GetDistance(M.HadeanScoutA, M.Player) < GetDistance(M.HadeanScoutA, M.HadeanBuilder) then
					Attack(M.HadeanScoutA, M.Player);
				else
					Attack(M.HadeanScoutA, M.HadeanBuilder);
				end
			end
			M.Routine3State = 0;
		elseif M.Routine3State == 2 then
			Retreat(M.HadeanScoutA, "Retreat", 1);
			SetObjectiveOn(M.HadeanScoutA);
			SetUserTarget(M.HadeanScoutA);
			AudioMessage("EDF14z05b.wav");	--Stewart:"Stop that scout before he reaches the Hadean base!"
			if IsAlive(M.HadeanScoutB) then
				if GetDistance(M.HadeanScoutB, M.Player) < GetDistance(M.HadeanScoutB, M.HadeanBuilder) then
					Attack(M.HadeanScoutB, M.Player);
				else
					Attack(M.HadeanScoutB, M.HadeanBuilder);
				end	
			end
			M.Routine3State = 0;
		end
	end
end	

function IsNeutralized(h)
	return not IsAlive(h) or GetTeamNum(h) ~= 5;
end

function IsAggroed(h)
	return IsNeutralized(h) 
	or GetHealth(h) < 0.6 
	or GetDistance(h, M.Player) < 100 
	or GetDistance(h, M.HadeanBuilder) < 120;
end

function IsRunning(h)
	return not IsNeutralized(h) and GetCurrentCommand(h) > 0;
end

--runs when player tells Schultz to pick them up.
function Routine5()
	if M.Routine5Active and M.Routine5Timer < GetTime() then
		if M.Routine5State == 0 then
			SetObjectiveName(M.Schultz, "Schultz");
			SetObjectiveOn(M.Schultz);
			SetIndependence(M.Schultz, 0);
			Goto(M.Schultz, M.Recycler, 0);
			GiveWeapon(M.Schultz, "igjetp14");
			AudioMessage("EDF14z09.wav");	--Schultz:"Got your heart set on this fine little spider tank, huh..."
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 4;
		elseif M.Routine5State == 1 then
			if GetDistance(M.Schultz, M.Recycler) > 150 then
				--Schultz jetpacks back to base if far away from recy
				SetWeaponMask(M.Schultz, 4);
				FireAt(M.Schultz, nil, false);
			end
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 20;
		elseif M.Routine5State == 2 then
			RemoveObject(M.Schultz);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Active = false;
		end
	end
end	

--plays mission intro audio message, spawns a few Hadeans that attack the recycler, and spawns Schultz
function Routine8()
	if M.Routine8Timer < GetTime() then
		if M.Routine8State == 0 then
			GiveWeapon(M.Player, "gshadow_c");
			SetMaxAmmo(M.Player, 1500);
			SetCurAmmo(M.Player, 1500);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 3;
		elseif M.Routine8State == 1 then
			AudioMessage("EDF14z01.wav");	--Stewart:"Let's get started, Joseph..."
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 2;
		elseif M.Routine8State == 2 then
			ClearObjectives();
			AddObjective("edf1401.otf", "white");
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 300;
		elseif M.Routine8State == 3 then
			Goto(BuildObject("evtank", 5, "Retreat"), M.Recycler, 0);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 100;
		elseif M.Routine8State == 4 then
			Goto(BuildObject("evtank", 5, "Retreat"), M.Recycler, 0);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 100;
		elseif M.Routine8State == 5 then
			M.Schultz = BuildObject("ivspider", 1, "Recycler");
			SetGroup(M.Schultz, GetFirstEmptyGroup(1));
			Goto(M.Schultz, "FriendPatrol", 0);
			SetObjectiveName(M.Schultz, "Schultz");
			SetObjectiveOn(M.Schultz);
			AudioMessage("EDF14z08.wav");	--Schultz:"Hey Joe, the docs have finally given me back my wings..."
			M.Routine8State = M.Routine8State + 1;
		end
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if M.CheckHadeanBuilder and not IsAround(M.HadeanBuilder) then
			ClearObjectives();
			AddObjective("edf1402.otf", "red");
			AudioMessage("EDF14z06.wav");	--Stewart:"I can't believe you lost that Creator..."
			FailMission(GetTime() + 11, "edf14L3.txt");
			M.MissionOver = true;
		elseif not IsAround(M.Recycler) then
			ClearObjectives();
			AddObjective("edf1411.otf", "red");
			AudioMessage("EDF14z07.wav");	--Hardin:"The Vengeance has been destroyed and Col. Stewart is dead..."
			FailMission(GetTime() + 11, "edf14L2.txt");
			M.MissionOver = true;
		end
	end
end