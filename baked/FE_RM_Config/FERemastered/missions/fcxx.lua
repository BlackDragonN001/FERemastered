----------------------------------------------------------------
-- FE fcxx.lua Mission - Version 1.0
-- Date Modified: 11/01/2021
-- Summary: Mission script for the fcxx Forgotten Enemies Mission.
----------------------------------------------------------------

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

--Routines
local Routines = {};

local M = {
--Mission State
	RoutineState = {},
	RoutineWakeTime = {},
	RoutineActive = {},
	MissionOver = false,
-- Bools
	CheckMatriarch = false;
	CheckBomber = false;
	CheckTech = false;
-- Floats

-- Handles
	Player = nil,	--Player
	ScionFighter = nil,	--Bee
	CerbFact = nil,	--"unnamed_cbfact"?
	ScionDropship = nil,
	ScionRecy = nil,
	Sentry1 = nil,
	Sentry2 = nil,
	Sentry3 = nil,
	Sentry4 = nil,
	Scav1 = nil,
	Scav2 = nil,
	Scav3 = nil,
	Scav4 = nil,
	Attacker1 = nil,	--Imperial scout 1
	Attacker2 = nil,	--Imperial scout 2
	CerbPatrol1 = nil,	--Cerb walker patrolling around main target (respawning)
	CerbPatrol2 = nil,	--Cerb Triton patrolling around main target (respawning)
	CerbTurr1 = nil,
	CerbTurr2 = nil,
	CerbTurr3 = nil,
	CerbTurr4 = nil,
	MainTargetNav = nil,
	BombTarget = nil,
	BombTrigger = nil,
	HadeanTech = nil, --SciWizard Kranios
	CerbTalon1 = nil,
	CerbTalon2 = nil,
	CerbTalon3 = nil,
	CerbTalon4 = nil,
	TunnelEntrance = nil,	--Tunnel entrance building
	Jammer = nil,
	MapSign = nil,
	CerbGuard1 = nil,	--Cerb tank that attacks player when they are looking for tunnel
	CerbGuard2 = nil,	--Cerb Siren that attacks player when they are looking for tunnel
	CerbGuard3 = nil,	--Cerb Siren that attacks player when they are looking for tunnel
	CerbGuard4 = nil,	--Cerb tank that attacks player when they are looking for tunnel
	CerbGuard5 = nil,	--Cerb Siren that attacks player when they are looking for tunnel
	CerbGuard6 = nil,	--Cerb tank that goes after Kranios after you find the map
	CerbAtank1 = nil,
	CerbAtank2 = nil,
	CerbAtank3 = nil,
	CerbAtank4 = nil,
	CerbAtank5 = nil,
	CerbAtank6 = nil,
	CerbAtank7 = nil,
	Pool1Nav = nil,
	Pool2Nav = nil,
	Pool3Nav = nil,
	Pool4Nav = nil,
	TunnelNav1 = nil,
	TunnelNav2 = nil,
	BomberBay = nil,
	BomberPower = nil,
-- Ints
	TPS = 10,
	RepairPercentage =  0,	--Matriarch repair percentage
	RepairTimeLeft =  50,	--Seconds until Matriarch is repaired
	BeeLaunchSpeed =  60.0,	--Bee Move() speed
	Variable9 =  0,	--Routine1 timer for player taking too long
	FoundMap =  0,	--player found map to underground research facility
--Vectors
	Position1 = SetVector( 0,0,0 ),	--center of map, by scrap pools
	Position2 = SetVector( 0,0,0 ),	--Cerb fact position
	Position3 = SetVector( -1956,113,1894 ),	--top left of map
	Position4 = SetVector( 0,0,0 ),	--Scrap pool 1 pos
	Position5 = SetVector( 0,0,0 ),	--Scrap pool 2 pos
	Position6 = SetVector( 0,0,0 ),	--Scrap pool 3 pos
	Position7 = SetVector( 0,0,0 ),	--Scrap pool 4 pos
	Position8 = SetVector( 0,0,0 ),	--position of "target"
	Position11 = SetVector( -128,56,1922 ),	--Scion Recycler spawn position
	Position12 = SetVector( -1615,98,112 ),	--Move target for Bee
	Position13 = SetVector( 0,0,0 ),		--Kranios Position above map sign
	Position14 = SetVector( 1073,16,889 ),	--"Hidden Tunnel" nav location
	Position15 = SetVector( 1066,16,1583 ),	--"Hidden Entrance" nav location
	Position16 = SetVector( -1025,47,1438 ),	--Cerberi spawn pos
	--End
	endme = 0
}

function InitialSetup()

	_FECore.InitialSetup();
	
	M.TPS = EnableHighTPS();
	AllowRandomTracks(false);
	DefineRoutines();
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadOdf = {		
		"fbrecy_xx",
		"fvrecy",
		"fvrbomb",
		"fvatank",
		"evsc_IH",
		"evta_IH",
		"evmi_IH",
		"evatu_IH",
		"evwalk",
		"cvtalon",
		"cvhatank",
		"cvtank",
		"cvwalk",
		"cvscout",
		"cvturr",
		"cvrbomb",
		"eveisen",
		"scibomb",
		"poolmine",
		"poolmine2"
	};
	for k,v in pairs(preloadOdf) do
		PreloadODF(v);
	end
	local preloadAudio = {
		"fcxx_01.wav",
		"fcxx_02.wav",
		"fcxx_03.wav",
		"fcxx_03a.wav",
		"fcxx_03b.wav",
		"fcxx_03c.wav",
		"fcxx_04.wav",
		"fcxx_04b.wav",
		"fcxx_04c.wav",
		"fcxx_05.wav",
		"fcxx_06.wav",
		"fcxx_07.wav",
		"fcxx_08.wav",
		"fcxx_09.wav",
		"fcxx_10.wav"
	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Save()

	_FECore.Save();
	
    return M;
end

function Load(...)

	_FECore.Load();

	if select('#', ...) > 0 then
		M = ...;
    end
end

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

--advances the routine's state by 1
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
	DefineRoutine(1, Routine1, true);
	DefineRoutine(2, Routine2, true);
	DefineRoutine(3, Routine3, true);
	DefineRoutine(4, Routine4, true);
	DefineRoutine(5, Routine5, true);
	DefineRoutine(6, Routine6, true);
	DefineRoutine(9, Routine9, false);
	DefineRoutine(10, Routine10, false);
	DefineRoutine(12, Routine12, false);
	DefineRoutine(13, Routine13, false);
	DefineRoutine(14, Routine14, false);
	DefineRoutine(15, Routine15, false);
end

function Start()

	_FECore.Start();

	Ally(1, 5);
	Ally(5, 1);
	Ally(1, 13);
	Ally(1, 4);
	Ally(2, 3);
	Ally(2, 15);
	Ally(3, 15);
	Ally(2, 14);
	Ally(3, 14);
	Ally(14, 15);
	Ally(2, 13);
	Ally(3, 13);
	UnAlly(1, 2);
	UnAlly(1, 3);
	Ally(12, 2);
	Ally(12, 3);
	Ally(12, 13);
	Ally(12, 15);

	-- We decided to move the off-map player units to an allied team to prevent issues with Servicing, etc. They are not controlled by the player so better off unseen until they are used. -- AI_Unit
	Ally(1, 6);
	Ally(6, 1);
	
	M.ScionFighter = GetHandleOrDie("unnamed_fvsky00");
	M.CerbFact = GetHandleOrDie("unnamed_cbfact");
	--M.ScionDropship = GetHandleOrDie("unnamed_ivbomb");		--not around? probably exploded when I re-saved the map in the editor.
	M.Scav1 = GetHandleOrDie("scav1");
	M.Scav2 = GetHandleOrDie("scav2");
	M.Scav3 = GetHandleOrDie("scav3");
	M.Scav4 = GetHandleOrDie("scav4");
	M.BombTarget = GetHandleOrDie("target");
	M.BombTrigger = GetHandleOrDie("trigger");
	M.TunnelEntrance = GetHandleOrDie("unnamed_fpbones1");	--was "unnamed_fpbones", which didn't exist
	M.Jammer = GetHandleOrDie("jammer");
	SetMaxHealth(M.Jammer, 0);
	M.MapSign = GetHandleOrDie("unnamed_mapsign3");
	M.BomberBay = GetHandleOrDie("unnamed_ibbomb");
	M.BomberPower = GetHandleOrDie("unnamed_ibpgen");
	
	M.Position2 = GetPosition(M.CerbFact);
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)
	_FECore.AddObject(h);

	local cfg = GetCfg(h);

	-- TEMP: Remove EDF bomber that spawns with the EDF off-map Bomber Bay until we figure out a true solution. - AI_Unit.
	-- Give Cerberi weapons to the Royal Hadeans.
	if (cfg == "ivbomb") then
		RemoveObject(h);
	elseif (cfg == "evmi_IH") then
		SetEjectRatio(h, 0);
		GiveWeapon(h, "gcvfaf_c");
	elseif (cfg == "evsc_IH") then
		SetEjectRatio(h, 0);
		GiveWeapon(h, "gcrapier_c");
	elseif (cfg == "evta_IH" or cfg == "evatu_IH") then
		SetEjectRatio(h, 0);
		GiveWeapon(h, "gcplasma_c");
		GiveWeapon(h, "gcrapier_c");
	end
end

function DeleteObject(h)

	_FECore.DeleteObject(h);
	
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

--Main mission state. Handles fixing Matriarch, capturing all 4 pools, and sending in the bomber.
function Routine1(R, STATE)
	if STATE == 0 then
		SetColorFade(40,1,1);
		local pos = GetPosition(M.Player) + SetVector(0,450,0);
		SetPosition(M.Player, pos);
		pos = pos + SetVector(15,-20,15);
		M.HadeanTech = BuildObject("eveisen", 1, pos);
		SetObjectiveName(M.HadeanTech, "SciWizard Kranios");
		Follow(M.HadeanTech, M.Player, 1);
		SetObjectiveOn(M.HadeanTech);
		SetSkill(M.HadeanTech, 3);	--make Kranios a bit more resilient
		--M.ScionDropship = ReplaceObject(M.ScionDropship, "scibomb");
		M.ScionDropship = BuildObject("scibomb", 6, GetPosition(M.BomberBay) + SetVector(0,50,0));
		SetGroup(M.ScionDropship, 9);
		SetPerceivedTeam(M.ScionDropship, 0);
		SetPerceivedTeam(M.BomberBay, 0);
		SetPerceivedTeam(M.BomberPower, 0);
		SetTeamNum(M.BombTarget, 15);
		M.Position8 = GetPosition(M.BombTarget);
		KillPilot(M.ScionFighter);
		SetRoutineActive(10, true);--RunSpeed,_Routine10,1,false
		M.ScionRecy = BuildObject("fbrecy_xx", 1, BuildDirectionalMatrix(TerrainFloor(M.Position11)));
		M.Sentry1 = BuildObject("fvsent", 1, "scion");
		M.Sentry2 = BuildObject("fvsent", 1, "scion");
		M.Sentry3 = BuildObject("fvsent", 1, "scion");
		Goto(M.Sentry1, M.ScionRecy, 1);
		Goto(M.Sentry2, M.ScionRecy, 1);
		Goto(M.Sentry3, M.ScionRecy, 1);
		SetPerceivedTeam(M.Scav1, 1);
		M.Position4 = TerrainFloor(GetPosition(M.Scav1) + SetVector(30,0,35));
		M.Position5 = TerrainFloor(GetPosition(M.Scav2) + SetVector(35,0,35));
		M.Position6 = TerrainFloor(GetPosition(M.Scav3) + SetVector(35,0,35));
		M.Position7 = TerrainFloor(GetPosition(M.Scav4) + SetVector(35,0,35));
		M.Pool1Nav = BuildObject("ibnav", 3, M.Position4);
		M.Pool2Nav = BuildObject("ibnav", 3, M.Position5);
		M.Pool3Nav = BuildObject("ibnav", 3, M.Position6);
		M.Pool4Nav = BuildObject("ibnav", 3, M.Position7);
		SetTeamNum(M.Scav1, 3);
		SetTeamNum(M.Scav2, 3);
		SetTeamNum(M.Scav3, 3);
		SetTeamNum(M.Scav4, 3);
		ReplaceObject(GetObjectByTeamSlot(3, 1), "ebre_IH");
		ReplaceObject(GetObjectByTeamSlot(3, 2), "ebfa_IH");
		M.CheckTech = true;--RunSpeed,_Routine11,1,false
		M.CheckMatriarch = true;--RunSpeed,_Routine8,1,false
		M.CerbTalon1 = BuildObject("cvtalon", 2, M.Position2);
		Patrol(M.CerbTalon1, "patrol", 1);
		local TempH = BuildObject("evta_IH", 3, "attack");
		SetEjectRatio(TempH, 0.0);
		-- Give some Cerberi weapons? -GBD
		Goto(TempH, "attack", 1);
		TempH = BuildObject("evta_IH", 3, "attack");
		SetEjectRatio(TempH, 0.0);
		-- Give some Cerberi weapons? -GBD
		Goto(TempH, "attack", 1);
		ClearObjectives();
		AddObjective("fcxx01.otf", "white");
		AudioMessage("fcxx_01.wav");	--Kranios:"Lead me to the Scion Procreator..."
		Advance(R, 15.0);	--5.0
	elseif STATE == 1 then
		M.Attacker1 = BuildObject("evsc_IH", 3, M.Position4);
		SetEjectRatio(M.Attacker1, 0.0);
		Attack(M.Attacker1, M.ScionRecy, 1);
		Advance(R);
	elseif STATE == 2 then	--LOC_101
		if GetDistance(M.Attacker1, M.ScionRecy) < 200 then 
			Goto(M.HadeanTech, M.Jammer, 1);
			M.Attacker2 = BuildObject("evsc_IH", 3, M.Position4);
			SetEjectRatio(M.Attacker2, 0.0);
			Attack(M.Attacker2, M.ScionRecy, 1);
			Defend2(M.Sentry1, M.ScionRecy, 1);
			Defend2(M.Sentry2, M.ScionRecy, 1);
			Defend2(M.Sentry3, M.ScionRecy, 1);
			Advance(R);
		end
	elseif STATE == 3 then
		if GetDistance(M.HadeanTech, M.Jammer) < 200 then
			Goto(M.HadeanTech, M.Jammer, 1);
			Advance(R);
		end
	elseif STATE == 4 then	--LOC_109
		if GetDistance(M.HadeanTech, M.Jammer) < 20 then
			AudioMessage("fcxx_09.wav");	--Kranios:"My sensors are showing some abnormal Q-band interference..."
			Advance(R, 10.0);
		end
	elseif STATE == 5 then
		local pos = GetPosition(M.Jammer); -- save position before it is destroyed. -GBD
		SetMaxHealth(M.Jammer, 1000);
		Damage(M.Jammer, 100000); --SetCurHealth(M.Jammer, 1);
		BuildObject("poolmine", 2, pos);
		Goto(M.HadeanTech, M.ScionRecy, 1);
		Advance(R);
	elseif STATE == 6 then	--LOC_117
		M.RepairPercentage = M.RepairPercentage + 4;
		M.RepairTimeLeft = M.RepairTimeLeft - 2;
		ClearObjectives();
		local ObjectiveA = LoadFile("fcxx13.otf");
		AddObjective(string.format(ObjectiveA, M.RepairPercentage), "white");
		local ObjectiveB = LoadFile("fcxx14.otf");
		AddObjective(string.format(ObjectiveB, M.RepairTimeLeft), "white");
		if M.RepairTimeLeft <= 0 then
			SetScrap(1, 40);
			SetCurAmmo(M.HadeanTech, 50);
			Retreat(M.HadeanTech, "weller", 1);
			SetPerceivedTeam(M.HadeanTech, 2);
			SetObjectiveOff(M.HadeanTech);
			AudioMessage("fcxx_08.wav");	--Kranios:"I have restored the Matriarch to working order..."
			Advance(R);
		else
			Wait(R, 2.0);
		end
	elseif STATE == 7 then	--LOC_131
		ClearObjectives();
		AddObjective("fcxx01.otf", "green");
		AddObjective("fcxx02.otf", "white");
		M.Variable9 = GetTime() + 600;
		Advance(R);
	elseif STATE == 8 then	--LOC_136
		if M.Variable9 < GetTime()  then
			SetRoutineActive(15, true);--RunSpeed,_Routine15,1,false
			ClearObjectives();
			AddObjective("fcxx02.otf", "red");
			SetState(R, 6, 3.0);--to LOC_131
		elseif not IsAround(M.Scav1) then
			Advance(R, 2.0);
		end
	elseif STATE == 9 then	--LOC_146
		AudioMessage("fcxx_02.wav");	--Fox:"My commanding officer was killed after discovering a huge bio-metal field to the south..."
		local pos = TerrainFloor(SetVector(0,0,0));
		M.MainTargetNav = BuildObject("ibnav", 1, pos);
		SetObjectiveName(M.MainTargetNav, "Main Target");
		SetObjectiveOn(M.MainTargetNav);
		Advance(R);
	elseif STATE == 10 then	--LOC_152
		ClearObjectives();
		AddObjective("fcxx02.otf", "green");
		AddObjective("fcxx03.otf", "white");
		M.Variable9 = GetTime() + 500;
		Advance(R);
	elseif STATE == 11 then	--LOC_157
		if M.Variable9 < GetTime() then
			SetRoutineActive(15, true);--RunSpeed,_Routine15,1,false
			ClearObjectives();
			AddObjective("fcxx02.otf", "white");
			AddObjective("fcxx03.otf", "red");
			SetState(R, 10, 3.0);--to LOC_152
		elseif GetDistance(M.Player, M.MainTargetNav) < 40 then
			Ally(2, 1);
			Ally(3, 1);
			AudioMessage("fcxx_03.wav");	--Fox:"That bio-metal field is truly impressive..."
			CameraReady();
			Advance(R);
		end
	elseif STATE == 12 then
		if CameraPath("campath", 2000, 3000, M.BombTarget) or CameraCancelled() then
			CameraFinish();
			UnAlly(2, 1);
			UnAlly(3, 1);
			SetRoutineActive(12, true);--RunSpeed,_Routine12,1,false
			SetObjectiveOff(M.MainTargetNav);
			SetAIP("fcxx_3.aip", 3);
			SetTeamNum(M.BombTarget, 2);
			Advance(R, 10.0);
		end
	elseif STATE == 13 then
		ClearObjectives();
		AddObjective("fcxx03.otf", "green");
		AddObjective("fcxx04.otf", "white");
		AudioMessage("fcxx_03b.wav");	--Thanatos:"We lack the forces to take and hold the bio-metal field..."
		Advance(R, 28.0);
	elseif STATE == 14 then
		AudioMessage("fcxx_03c.wav");	--Kranios:"The Scions have created a plasma bomb with some very unusual characteristics..."
		Advance(R);
	elseif STATE == 15 then	--LOC_187
		if GetMaxScrap(1) > 119 then
			M.HadeanTech = BuildObject("eveisen", 1, "scion");
			Goto(M.HadeanTech, M.MapSign, 1);
			SetObjectiveName(M.HadeanTech, "SciWizard Kranios");
			M.Position13 = GetPosition(M.MapSign) + SetVector(0, 50, 0);
			Advance(R);
		end
	elseif STATE == 16 then	--LOC_195
		if GetScrap(1) > 119 then
			SetScrap(1, 0);
			SetPosition(M.HadeanTech, M.Position13);
			M.CheckMatriarch = false;--RunSpeed,_Routine8,0,false
			ClearObjectives();
			AddObjective("fcxx04.otf", "green");
			AddObjective("fcxx06.otf", "white");
			AudioMessage("fcxx_04.wav");	--LeBlanc:"My men have planted the smaller bombs at the 4 bio-metal pools..."
			SetObjectiveOn(M.HadeanTech);
			M.TunnelNav1 = BuildObject("ibnav", 5, M.Position14);
			SetObjectiveName(M.TunnelNav1, "Hidden Tunnel");
			SetObjectiveOn(M.TunnelNav1);
			Advance(R);
		end
	elseif STATE == 17 then	--LOC_208
		if GetDistance(M.Player, M.TunnelNav1) < 30 then
			SetObjectiveOff(M.TunnelNav1);
			RemoveObject(M.TunnelNav1);
			M.TunnelNav2 = BuildObject("ibnav", 5, M.Position15);
			SetObjectiveName(M.TunnelNav2, "Hidden Entrance");
			SetObjectiveOn(M.TunnelNav2);
			Advance(R);
		end
	elseif STATE == 18 then	--LOC_216
		if GetDistance(M.Player, M.TunnelNav2) < 30 then
			SetObjectiveOff(M.TunnelNav2);
			RemoveObject(M.TunnelNav2);
			Advance(R);
		end
	elseif STATE == 19 then	--LOC_221
		if GetDistance(M.Player, M.MapSign) < 10 then
			ClearObjectives();
			AddObjective("fcxx06.otf", "green");
			AddObjective("fcxx07.otf", "white");
			AudioMessage("fcxx_04b.wav");	--LeBlanc:"Our historians believe that the map you found points the way to the main research facility..."
			Goto(M.HadeanTech, "scion", 1);
			SetRoutineActive(14, true);--RunSpeed,_Routine14,1,false
			SetRoutineActive(13, true);--RunSpeed,_Routine13,1,false
			SetRoutineActive(10, false);--RunSpeed,_Routine10,0,false
			M.FoundMap = 1;
			--M.CheckBomber = true;--RunSpeed,_Routine7,1,false
			Advance(R, 10.0);
		end
	elseif STATE == 20 then
		Goto(M.HadeanTech, M.ScionRecy, 1);
		Advance(R, 10.0);
	elseif STATE == 21 then
		SetRoutineActive(15, true);--RunSpeed,_Routine15,1,false
		M.CerbAtank5 = BuildObject("cvhatank", 3, "scion");
		Goto(M.CerbAtank5, M.Pool1Nav, 1);
		M.CerbAtank6 = BuildObject("cvhatank", 3, GetPosition(M.CerbAtank5) + SetVector(0,0,-20));
		Attack(M.CerbAtank6, M.ScionRecy, 1);
		Advance(R, 70.0);
	elseif STATE == 22 then
		Attack(BuildObject("cvtank", 3, "scion"), M.HadeanTech, 1);
		M.CerbGuard6 = BuildObject("cvtank", 3, "scion");
		Attack(M.CerbGuard6, M.HadeanTech, 1);
		Advance(R, 10.0);
	elseif STATE == 23 then
		Goto(M.HadeanTech, M.CerbGuard6, 1);
		Advance(R);
	elseif STATE == 24 then	--LOC_249
		if IsOdf(M.Player, "fvsky00") then
			SetRoutineActive(13, false);--RunSpeed,_Routine13,0,false
			Advance(R);
		end
	elseif STATE == 25 then
		if Move(M.Player, 0, M.BeeLaunchSpeed, M.Position12) or GetDistance(M.Player, TerrainFloor(M.Position12)) < 10 then
			M.CerbTalon2 = BuildObject("cvtalon", 2, TerrainFloor(M.Position1));
			M.CerbTalon3 = BuildObject("cvtalon", 2, TerrainFloor(M.Position1));
			M.CerbTalon4 = BuildObject("cvtalon", 2, TerrainFloor(M.Position1));
			Patrol(M.CerbTalon2, "patrol2", 1);
			Patrol(M.CerbTalon3, "patrol", 1);
			SetPerceivedTeam(M.ScionDropship, 1);
			M.CheckBomber = true;
			AudioMessage("fcxx_10.wav");	--LeBlanc:"Our data link shows your systems to be in full working order..."
			Advance(R, 5.0);
		end
	elseif STATE == 26 then
		Patrol(M.CerbTalon4,"patrol2", 1);
		ClearObjectives();
		AddObjective("fcxx07.otf", "green");
		AddObjective("fcxx08.otf", "white");
		SetObjectiveOn(M.CerbTalon1);
		SetObjectiveOn(M.CerbTalon2);
		SetObjectiveOn(M.CerbTalon3);
		SetObjectiveOn(M.CerbTalon4);
		Advance(R);
	elseif STATE == 27 then	--LOC_269
		if not IsAround(M.CerbTalon1)
		and not IsAround(M.CerbTalon2)
		and not IsAround(M.CerbTalon3)
		and not IsAround(M.CerbTalon4) then
			ClearObjectives();
			AddObjective("fcxx08.otf", "green");
			AddObjective("fcxx05.otf", "white");
			SetGroup(M.ScionDropship, 9);
			SetUserTarget(M.ScionDropship);
			Attack(M.ScionDropship, M.BombTarget, 1);
			SetObjectiveOn(M.ScionDropship);
			Attack(BuildObject("cvtank", 2, M.Position6), M.ScionDropship, 1);
			Attack(BuildObject("cvtank", 2, M.Position14), M.ScionDropship, 1);
			Attack(BuildObject("cvtank", 2, TerrainFloor(M.Position1)), M.ScionDropship, 1);
			M.CerbTalon1 = BuildObject("cvtalon", 2, M.Position14);
			Attack(M.CerbTalon1, M.Player, 1);
			Advance(R, 4.0);
		end
	elseif STATE == 28 then	--LOC_293
		if not IsAround(M.BombTrigger) or GetCurHealth(M.BombTrigger) < 3000 then
			M.CheckBomber = false;--RunSpeed,_Routine7,0,false
			SetPosition(M.Player, M.Position3);
			SetRoutineActive(9, true);--RunSpeed,_Routine9,1,true
			AudioMessage("fcxx_05.wav");	--LeBlanc:"Excellent job, Colonel Corber. The bio-metal has been oxidized..."
			Advance(R, 2.0);
		end
	elseif STATE == 29 then
		M.BombTarget = ReplaceObject(M.BombTarget, "smoker4", 1);
		Advance(R);
	elseif STATE == 30 then	--LOC_303
		local h = GetNearestObject(M.BombTarget);
		local d = GetDistance(h, M.BombTarget);
		if d > 80 then
			M.BombTarget = ReplaceObject(M.BombTarget, "ibnav", 1);
			SetColorFade(-4000, 300, 1);
			SucceedMission(GetTime() + 8, "fcxxwin.des");
			Advance(R);
		elseif GetCfg(h) == "depool01" then
			BuildObject("poolmine2", 2, GetTransform(h));
			RemoveObject(h);
			Wait(R, 0.2);
		elseif GetCfg(h) ~= "scibomb" then
			BuildObject("poolmine", 2, GetTransform(h));
			RemoveObject(h);
			Wait(R, 0.2);
		end
	end
end

--Handles respawning Cerb Walker, scout, and 4 turrets by central pools
function Routine2(R, STATE)
	if not IsAround(M.CerbPatrol1) then
		M.CerbPatrol1 = BuildObject("cvwalk", 2, M.Position2);
		Patrol(M.CerbPatrol1, "patrol", 1);
		Wait(R, 50.0);
	elseif not IsAround(M.CerbPatrol2) then
		M.CerbPatrol2 = BuildObject("cvscout", 2, M.Position2);
		Patrol(M.CerbPatrol2, "patrol", 1);
		Wait(R, 50.0);
	elseif not IsAround(M.CerbTurr1) then
		M.CerbTurr1 = BuildObject("cvturr", 2, M.Position2);
		Goto(M.CerbTurr1, "walk1", 1);
		Wait(R, 50.0);
	elseif not IsAround(M.CerbTurr2) then
		M.CerbTurr2 = BuildObject("cvturr", 2, M.Position2);
		Goto(M.CerbTurr2, "walk2", 1);
		Wait(R, 50.0);
	elseif not IsAround(M.CerbTurr3) then
		M.CerbTurr3 = BuildObject("cvturr", 2, M.Position2);
		Goto(M.CerbTurr3, "walk3", 1);
		Wait(R, 50.0);
	elseif not IsAround(M.CerbTurr4) then
		M.CerbTurr4 = BuildObject("cvturr", 2, M.Position2);
		Goto(M.CerbTurr4, "walk4", 1);
		Wait(R, 50.0);
	end
end

--Sends 3 Imperial Xares to attack the Matriarch once the first scav has been destroyed
function Routine3(R, STATE)
	if STATE == 0 then	--LOC_363
		if not IsAround(M.Scav1) then
			local TempH = BuildObject("evta_IH", 3, "attack");
			SetEjectRatio(TempH, 0.0); -- Give cerberi weapons? -GBD
			Goto(TempH, "attack", 1);
			TempH = BuildObject("evta_IH", 3, "attack");
			SetEjectRatio(TempH, 0.0); -- Give cerberi weapons? -GBD
			Goto(TempH, "attack", 1);
			TempH = BuildObject("evta_IH", 3, "attack");
			SetEjectRatio(TempH, 0.0); -- Give cerberi weapons? -GBD
			Goto(TempH, "attack", 1);
			Advance(R);
		end
	end
end

--Sends Hadean attackers and Scion reinforcements once second scrap pool has been destroyed
function Routine4(R, STATE)
	if STATE == 0 then	--LOC_372
		if not IsAround(M.Scav2) then
			local leader = BuildObject("evmi_IH", 3, "attack");
			SetEjectRatio(leader, 0.0); -- Give cerberi weapons? -GBD
			Goto(leader, "attack", 1);
			local TempH = BuildObject("evmi_IH", 3, "attack");
			SetEjectRatio(TempH, 0.0); -- Give cerberi weapons? -GBD
			Follow(TempH, leader, 1);
			TempH = BuildObject("evta_IH", 3, "attack");
			SetEjectRatio(TempH, 0.0); -- Give cerberi weapons? -GBD
			Goto(BuildObject("evta_IH", 3, "attack"), "attack", 1);
			Defend2(M.Sentry1, M.ScionRecy, 0);
			SetBestGroup(M.Sentry1);
			Defend2(M.Sentry2, M.ScionRecy, 0);
			SetBestGroup(M.Sentry2);
			Defend2(M.Sentry3, M.ScionRecy, 0);
			SetBestGroup(M.Sentry3);
			M.Sentry1 = BuildObject("fvrbomb", 1, "scion");
			M.Sentry2 = BuildObject("fvrbomb", 1, "scion");
			Goto(M.Sentry1, "scion", 1);
			Goto(M.Sentry2, "scion", 1);
			Advance(R);
		end
	elseif STATE == 1 then	--LOC_387
		if GetDistance(M.Sentry1, M.ScionRecy) < 100 or GetDistance(M.Sentry2, M.ScionRecy) < 100 then
			Defend2(M.Sentry1, M.ScionRecy, 0);
			SetBestGroup(M.Sentry1);
			Defend2(M.Sentry2, M.ScionRecy, 0);
			SetBestGroup(M.Sentry2);
			Advance(R);
		end
	end
end

--Sends Hadean attackers and Scion reinforcements once third scrap pool has been destroyed
function Routine5(R, STATE)
	if STATE == 0 then	--LOC_392
		if not IsAround(M.Scav3) then
			local leader = BuildObject("evwalk", 3, "attack"); -- TODO make Imperial Walker? -GBD
			Goto(leader, "attack", 1);
			local TempH = BuildObject("evta_IH", 3, "attack");
			SetEjectRatio(TempH, 0.0); -- Give cerberi weapons? -GBD
			Follow(TempH, leader, 1);
			TempH = BuildObject("evta_IH", 3, "attack");
			SetEjectRatio(TempH, 0.0); -- Give cerberi weapons? -GBD
			Follow(TempH, leader, 1);
			M.Sentry4 = BuildObject("fvatank", 1, "scion");
			Goto(M.Sentry4, "scion", 1);
			SetUserTarget(M.Sentry4);
			Advance(R);
		end
	elseif STATE == 1 then
		if GetDistance(M.Sentry4, "scion", 0) < 10 then
			Stop(M.Sentry4, 0);
			SetBestGroup(M.Sentry4);
			Advance(R);
		end
	end
end

--Sends Hadean attackers and Scion reinforcements once fourth scrap pool has been destroyed
function Routine6(R, STATE)
	if STATE == 0 then	--LOC_392
		if not IsAround(M.Scav4) then
			local leader = BuildObject("evatu_IH", 3, "attack");
			SetEjectRatio(leader, 0.0); -- Give cerberi weapons? -GBD
			Goto(leader, "attack", 1);
			local TempH = BuildObject("evta_IH", 3, "attack");
			SetEjectRatio(TempH, 0.0); -- Give cerberi weapons? -GBD
			Follow(TempH, leader, 1);
			TempH = BuildObject("evta_IH", 3, "attack");
			SetEjectRatio(TempH, 0.0); -- Give cerberi weapons? -GBD
			Follow(TempH, leader, 1);
			Advance(R);
		end
	end
end

--runs the final camera cutscene
function Routine9(R, STATE)
	if STATE == 0 then
		CameraReady();
		Advance(R);
	elseif STATE == 1 then
		if CameraPath("campath", 5000, 1300, M.BombTarget) then
			CameraFinish();
			Advance(R);
		end
	end
end

--Checks to see if Player entered Bee too early
function Routine10(R, STATE)
	if not M.MissionOver and GetCfg(M.Player) == "fvsky00" then
		AudioMessage("fcxx_03a.wav");	--Scion voice:"Intruder alert! Unauthorized entry detected..."
		FailMission(GetTime() + 10, "fcxxjet.des");
		M.MissionOver = true;
	end
end

--Periodically spawns Cerb attackers
function Routine12(R, STATE)
	if STATE == 0 then	--LOC_442
		local leader = BuildObject("cvrbomb", 2, "cerbattack");
		Goto(leader, "cerbattack", 1);
		Follow(BuildObject("cvtank", 2, "cerbattack"), leader, 1);
		Advance(R, 600.0);
	elseif STATE == 1 then
		local leader = BuildObject("cvwalk", 2, "cerbattack");
		Goto(leader, "cerbattack", 1);
		Follow(BuildObject("cvtank", 2, "cerbattack"), leader, 1);
		SetState(R, 0, 600.0);
	end
end

--Checks to see if player is in the tunnels yet
function Routine13(R, STATE)
	if STATE == 0 then
		M.CerbGuard1 = BuildObject("cvtank", 2, M.Position3);
		Goto(M.CerbGuard1, M.TunnelEntrance, 1);
		M.CerbGuard2 = BuildObject("cvrbomb", 2, M.Position3);
		Goto(M.CerbGuard2, M.TunnelEntrance, 1);
		M.CerbGuard3 = BuildObject("cvrbomb", 2, M.Position16);
		M.CerbGuard4 = BuildObject("cvtank", 2, M.Position16);
		M.CerbGuard5 = BuildObject("cvrbomb", 2, M.Position16);
		Attack(M.CerbGuard3, M.Player, 1);
		Attack(M.CerbGuard4, M.Player, 1);
		Advance(R);
	elseif STATE == 1 then	--LOC_464
		local pos = GetPosition(M.Player);
		local h = pos.y - TerrainFindFloor(pos);
		if h < -60.0 then
			Attack(M.HadeanTech, M.CerbAtank1, 1);
			Attack(M.CerbGuard1, M.Player, 1);
			Attack(M.CerbGuard2, M.Player, 1);
			Attack(M.CerbGuard5, M.Player, 1);
			Advance(R);
		end
	elseif STATE == 2 then	--LOC_472
		Attack(M.CerbGuard2, M.Player, 1);
		if IsPerson(M.Player) then
			RemoveObject(M.CerbGuard3);
			RemoveObject(M.CerbGuard4);
			RemoveObject(M.CerbGuard5);
			RemoveObject(M.CerbGuard1);
			Advance(R);
		else
			Wait(R, 60.0);
		end
	end
end

--packs up the Scion recy and retreats it
function Routine14(R, STATE)
	if STATE == 0 then
		if not IsAround(M.HadeanTech) then
			Advance(R, 1.0);
		end
	elseif STATE == 1 then
		AudioMessage("fcxx_04c.wav");	--LeBlanc:"Colonel Corber, what the devil is taking you so long?..."
		M.ScionRecy = ReplaceObject(M.ScionRecy, "fvrecy");
		Goto(M.ScionRecy, "scion", 1);
		Advance(R);
	end
end

--Sends a bunch of Cerb Dominators after the Player's Recycler.
function Routine15(R, STATE)
	if STATE == 0 then
		M.CerbAtank4 = BuildObject("cvhatank", 3, M.Position6);
		Advance(R, 5.0);
	elseif STATE == 1 then	--LOC_493
		if not IsAround(M.CerbAtank1) then
			M.CerbAtank1 = BuildObject("cvhatank", 3, TerrainFloor(M.Position7));
			Goto(M.CerbAtank1, M.ScionRecy, 1);
			Wait(R, 5.0);
		elseif not IsAround(M.CerbAtank2) then
			M.CerbAtank2 = BuildObject("cvhatank", 3, TerrainFloor(M.Position1));
			Goto(M.CerbAtank2, M.Pool2Nav, 1);
			Wait(R, 5.0);
		elseif not IsAround(M.CerbAtank3) then
			M.CerbAtank3 = BuildObject("cvhatank", 3, TerrainFloor(M.Position1));
			Goto(M.CerbAtank3, M.Pool4Nav, 1);
			Wait(R, 5.0);
		elseif not IsAround(M.CerbAtank5) then
			M.CerbAtank5 = BuildObject("cvhatank", 3, TerrainFloor(M.Position5));
			Goto(M.CerbAtank5, M.Pool1Nav, 1);
			Wait(R, 5.0);
		elseif not IsAround(M.CerbAtank6) then
			M.CerbAtank6 = BuildObject("cvhatank", 3, TerrainFloor(M.Position7));
			Goto(M.CerbAtank6, M.ScionRecy, 1);
			Wait(R, 5.0);
		elseif not IsAround(M.CerbAtank7) then
			M.CerbAtank7 = BuildObject("cvhatank", 3, TerrainFloor(M.Position1));
			Goto(M.CerbAtank7, M.ScionRecy, 1);
			Wait(R, 5.0);
		elseif M.FoundMap == 1 or not IsAround(M.ScionRecy) then
			SetRoutineActive(R, false);--RunSpeed,_Routine15,0,false
		end
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if M.CheckBomber and not IsAround(M.ScionDropship) then
			ClearObjectives();
			AddObjective("fcxx05.otf", "red");
			AudioMessage("fcxx_07.wav");	--LeBlanc:"That was our only plasma bomb..."
			FailMission(GetTime() + 10, "fcxxbomb.des");
			M.MissionOver = true;
		elseif M.CheckMatriarch and not IsAround(M.ScionRecy) then
			ClearObjectives();
			AddObjective("fcxx10.otf", "red");
			AudioMessage("fcxx_06.wav");	--LeBlanc:"You've lost the Matriarch..."
			FailMission(GetTime() + 15, "fcxxrecy.des");
			M.MissionOver = true;
		elseif M.CheckTech then
			if not IsAround(M.HadeanTech) then
				FailMission(GetTime() + 10, "fcxxtech.des");
				M.MissionOver = true;
			elseif GetDistance(M.HadeanTech, "scion") < 100 then
				RemoveObject(M.HadeanTech);
				M.CheckTech = false;--RunSpeed,_Routine11,0,false
			end
		end
	end
end