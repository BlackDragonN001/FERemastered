assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

--Strings
local _Text1 = "yOU aRE nEAR tHE mAIN eNTRANCE\ntO tHE cERBERI bASE. dEPLOY tHE\npROCREATOR aND pREPARE a sOLID\ndEFENSE bEFORE tHE eNEMY mOUNTS\na mAJOR aTTACK!";
local _Text2 = "dESTROY tHE cERBERI fOUNDRY.\ntHIS wILL dISABLE mOST oF tHE\naUTONOMOUS dEFENSES gUARDING tHE\nmAIN aPPROACH tO tHE tRANSPORTER\naND cERBERIZERS.";
local _Text3 = "fOOL! bY lOSING tHE pROCREATOR,\nyOU hAVE aBOLISHED aLL hOPE oF\nsTOPPING tHE cERBERI oNSLAUGHT!\naLL uNITS, rETREAT tO yOUR\ndROPSHIPS aT oNCE!";
local _Text4 = "tHE tRANSPORTER iS sITED aLONG\ntHE mAIN aPPROACH rOUTE. dESTROY\ntHE cATALYZER tO iGNITE a cHAIN\nrEACTION tHAT wILL dEMOLISH tHE\ntRANSPORTER.";
local _Text5 = "eXCELLENT jOB--tHE cATALYZER\naND tRANSPORTER hAVE bEEN\ndESTROYED! yOUR rEINFORCEMENTS\nwILL dEACTIVATE tHE cERBERIZER\nvATS, tHEN dESTROY tHEM.";

local NUM_POWERGLOBES = 4;
local NUM_BOLTMINES = 20;

--Routines
local Routines = {};

local M = {
--Mission State
	RoutineState = {},
	RoutineWakeTime = {},
	RoutineActive = {},
	MissionOver = false,
-- Bools
	CheckProcreator = false;
-- Floats
	EscapeShipMoveTime = 0.0,
-- Handles
	Object1 = nil,	--Cerb escape craft
	Object2 = nil, --<2>Weird Cerb constructor  (respawning)
	Object4 = nil, --<2>scratch for OnDelObject
	Object6 = nil,	--scratch for OnPortalDist
	--Object7 = nil,	--off map position for teleporting out units
	Object8 = nil,	--Cerb Drone (respawning)
	Object9 = nil,	--Cerb Drone (respawning)
	Object10 = nil,	--scratch
	Object11 = nil,		--Player
	Object12 = nil,	--Schulz
	PowerGlobes = {},	--Cerb power globes before Catalyser (array<4>)
	Object30 = nil,	--Cerb Catalyser
	Object31 = nil,	--Cerb Foundry
	CerbFact = nil,	--Cerb Crucible
	Object32 = nil,	--Procreator
-- Ints
	TPS = 10,
	Variable1 = 0,	--Escape craft move speed
	--Variable2 = 0,	--scratch
	Variable3 = 4,	--Schulz taunt index
	Variable4 = 7,	--Schulz taunt index 2
	--Variable5 = 0,	--Escape craft rotation speed (always 0)
--Vectors
	Position1 = SetVector( 0,0,0 ),	--Escape Craft starting position
	Position2 = SetVector( 0,0,0 ),	--Escape Craft finish position
	--Position3 = SetVector(  0,0,0 ),	--portal spawn location (scratch)
	--Position4 = SetVector( 1000,0,1000 ),	--off map position for teleporting out units
	Position5 = SetVector( 90,80,40 ),	--CamPos offset 1
	Position6 = SetVector( -20,10,5 ),	--CamPos offset 2
	Position7 = SetVector( 0,0,0 ),		--Old player position
	Position8 = SetVector( 40,250,40 ),	--CamPos offset 1
	Position9 = SetVector( -40,40,40 ),	--CamPos offset 2
--End
	endme = 0
}

function InitialSetup()

	_FECore.InitialSetup();

	M.TPS = EnableHighTPS();
	DefineRoutines();
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadOdf = {		
		"evrecy",
		"aurora1",
		"aurora2",
		"aurora3",
		"aurorafield",
		"dclightmine",
		"cpgfield2",
		"cpgfield",
		"cpgorbit",
		"cvschulz",
		"cvcons"
	};
	for k,v in pairs(preloadOdf) do
		PreloadODF(v);
	end
	local preloadAudio = {
		--TODO: Preload Audio messages
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

--gets an object handle by label. If it doesn't exist, throws an error.
function GetHandleOrDie(name)
	return GetHandle(name) or error("Error: object '"..name.."' not found!", 2);
end

function DefineRoutines()
	DefineRoutine(1, Routine1, true);
	DefineRoutine(2, Routine2, true);
	DefineRoutine(3, Routine3, true);
	DefineRoutine(5, Routine5, false);
	DefineRoutine(7, Routine7, false);
	DefineRoutine(8, Routine8, true);
	DefineRoutine(12, Routine12, true);
end

function Start()
	
	_FECore.Start();

	M.Object1 = GetHandleOrDie("EscapeCraft");
	M.Object30 = GetHandleOrDie("Catalyser");
	M.Object31 = GetHandleOrDie("RecyclerEnemy");
	M.CerbFact = GetHandleOrDie("FactoryEnemy");
	M.Object32 = BuildObject("evrecy", 1, "RecyclerFriend");
	
	SetMaxHealth(M.Object1, 10000);
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)

	_FECore.AddObject(h);

end

function DeleteObject(h)

	_FECore.DeleteObject(h);

	if h == M.Object12 then
		AudioMessage("fclast_12.wav");	--Schultz:"You may have gotten lucky and destroyed my ship, but you'll never destroy me..."
		SetRoutineActive(5, false);--RunSpeed,_Routine5,0,true
		--OnDelObject,0
	elseif IsAround(M.Object12) and GetDistance(M.Object11, M.Object12) < 380 and GetTeamNum(h) == 1 then
		if GetCfg(h) ~= "ebrecy" then
			AudioMessage(string.format("fclast_%02i.wav", M.Variable4));	--Schultz taunting player
			M.Variable4 = M.Variable4 + 1;
			if M.Variable4 == 11 then
				M.Variable4 = 7;
			end
		end
	end
end

function Update()

	_FECore.Update();

	M.Object11 = GetPlayerHandle();
	for routineID,r in pairs(Routines) do
		if M.RoutineActive[routineID] and M.RoutineWakeTime[routineID] <= GetTime() then
			r(routineID, M.RoutineState[routineID]);
		end
	end
	HandlePortal();
	CheckStuffIsAlive();
end

--Main Mission State
function Routine1(R, STATE)
	if STATE == 0 then
		SetScrap(1, 40);
		SetGroup(M.Object32, 0);
		Goto(M.Object32, "RecyclerFriend", 0);
		AddObjective(_Text1, "white");
		AudioMessage("fclast_01.wav");	--Thanatos:"You are near the main approach to the Cerberi stronghold..."
		M.CheckProcreator = true;
		Advance(R);
	elseif STATE == 1 then	--LOC_2
		if GetCfg(M.Object32) == "ebrecy" then
			AddObjective(_Text2, "white");
			AudioMessage("fclast_02.wav");	--Thanatos:"The Cerberi Foundry controls a network of virtually impenetrable defenses..."
			SetObjectiveOn(M.Object31);
			Advance(R, 170.0);
		end
	elseif STATE == 2 then
		SetAIP("fclast0.aip", 2);
		Advance(R);
	elseif STATE == 3 then	--LOC_10
		if not IsAround(M.Object31) then
			SetAIP("fclast1.aip", 2);
			SetState(2, 10);--SetStep,_Routine2,LOC_126
			SetRoutineActive(7, true);--RunSpeed,_Routine7,1,false
			SetRoutineActive(8, true);--RunSpeed,_Routine8,1,false
			--SetPortal,Object30
			local pos = BuildDirectionalMatrix(GetPosition(M.Object30) + SetVector(0, -85, 0));
			BuildObject("aurora1", 2, pos);
			BuildObject("aurora2", 2, pos);
			BuildObject("aurora3", 2, pos);
			BuildObject("aurorafield", 2, pos);
			for i = 0, NUM_BOLTMINES do
				RemoveObject(GetHandle(string.format("BoltA%d", i)));
			end
			for i = 1, NUM_POWERGLOBES do
				local h = GetHandle(string.format("Power%d", i));
				local pos = BuildDirectionalMatrix(GetPosition(h) + SetVector(0, 45, 0));
				BuildObject("dclightmine", 0, pos);
				BuildObject("cpgfield2", 2, pos);
				BuildObject("cpgfield", 2, pos);
				M.PowerGlobes[i] = BuildObject("cpgorbit", 3, pos);
				SetPerceivedTeam(M.PowerGlobes[i], 2);
			end
			SetRoutineActive(12, true);--RunSpeed,_Routine12,1,false
			M.Object12 = BuildObject("cvschulz", 2, "SchulzPath");
			SetRoutineActive(5, true);--RunSpeed,_Routine5,1,true
			AudioMessage("fclast_03.wav");	--Schultz:"Don't kid yourself, Corber..."
			Advance(R, 5.0);
		end
	elseif STATE == 4 then
		M.Position7 = GetPosition(M.Object11);
		SetPosition(M.Object11, "PlayerStow");
		CameraReady();
		Advance(R);
	elseif STATE == 5 then
		if CameraPos(M.Object12, M.Object12, M.Position5, M.Position6, 900) or CameraCancelled() then
			CameraFinish();
			SetPosition(M.Object11, M.Position7);
			Patrol(M.Object12, "SchulzPath", 0);
			Advance(R, 2.0);
		end
	elseif STATE == 6 then
		ClearObjectives();
		AudioMessage("fclast_03a.wav");	--Thanatos:"The Cerberi transporter is located deep inside the stronghold..."
		AddObjective(_Text4, "white");
		local h = BuildObject("ibnav", 1, "Nav01");
		SetObjectiveName(h, "Cerberi Main Route");
		SetObjectiveOn(h);
		Advance(R);
	elseif STATE == 7 then	--LOC_77
		if GetDistance(M.Object11, M.Object30) < 350 then
			SetObjectiveOn(M.Object30);
			Advance(R);
		end
	elseif STATE == 8 then	--LOC_81
		if GetDistance(M.Object11, M.Object30) > 430 then
			SetObjectiveOff(M.Object30);
			SetState(R, STATE - 1);--to LOC_77
		end
	end
end

function Routine2(R, STATE)
	if STATE == 0 then
		Advance(R, 2.0);
	elseif STATE == 1 then
		Goto(BuildObject("cvscout", 2, "CerbPath1"), M.Object32, 0);
		Goto(BuildObject("cvtank", 2, "CerbPath1"), M.Object32, 0);
		Advance(R, 120.0);
	elseif STATE == 2 then
		Goto(BuildObject("cvscout", 2, "CerbPath2"), M.Object32, 0);
		Goto(BuildObject("cvtank", 2, "CerbPath2"), M.Object32, 0);
		Advance(R, 120.0);
	elseif STATE == 3 then
		Goto(BuildObject("cvscout", 2, "CerbPath2"), M.Object32, 0);
		Goto(BuildObject("cvtank", 2, "CerbPath2"), M.Object32, 0);
		Advance(R, 160.0);
	elseif STATE == 4 then
		Goto(BuildObject("cvrbomb", 2, "CerbPath3"), M.Object32, 0);
		Goto(BuildObject("cvtank", 2, "CerbPath3"), M.Object32, 0);
		Advance(R);
	elseif STATE == 5 then	--LOC_107
		Goto(BuildObject("cvtank", 2, "CerbPath3"), M.Object32, 0);
		Advance(R, 80.0);
	elseif STATE == 6 then
		Goto(BuildObject("cvscout", 2, "CerbPath2"), M.Object32, 0);
		Advance(R, 80.0);
	elseif STATE == 7 then
		Goto(BuildObject("cvtank", 2, "CerbPath1"), "CerbPath1", 0);
		Advance(R, 80.0);
	elseif STATE == 8 then
		Goto(BuildObject("cvscout", 2, "CerbPath3"), M.Object32, 0);
		Advance(R, 80.0);
	elseif STATE == 9 then
		Goto(BuildObject("cvtank", 2, "CerbPath1"), "CerbPath1", 0);
		SetState(R, 5, 80.0);--to LOC_107
	elseif STATE == 10 then	--LOC_126
		Goto(BuildObject("cvscout", 2, "CerbPath3"), M.Object32, 0);
		Goto(BuildObject("cvtank", 2, "CerbPath3"), M.Object32, 0);
		Advance(R, 100.0);
	elseif STATE == 11 then
		Goto(BuildObject("cvscout", 2, "CerbPath2"), M.Object32, 0);
		Goto(BuildObject("cvtank", 2, "CerbPath2"), "CerbPath2", 0);
		Advance(R, 100.0);
	elseif STATE == 12 then
		Goto(BuildObject("cvscout", 2, "CerbPath1"), "CerbPath1", 0);
		Goto(BuildObject("cvtank", 2, "CerbPath1"), "CerbPath1", 0);
		Advance(R, 100.0);
	elseif STATE == 13 then
		Attack(BuildObject("cvdcar", 2, "CerbPath1"), M.Object32, 0);
		SetState(R, 10, 55.0);--to LOC_126
	end
end

--Creates repawning Cerb drones
function Routine3(R, STATE)
	if not IsAround(M.CerbFact) then
		SetRoutineActive(R, false);	--stop respawning once factory is destroyed.
	elseif not IsAround(M.Object9) then
		M.Object9 = BuildObject("cvgdron", 2, "DronePatrol");
		Patrol(M.Object9, "DronePatrol", 0);
		Wait(R, 50);	--30
	elseif not IsAround(M.Object8) then
		M.Object8 = BuildObject("cvgdron", 2, "DronePatrol");
		Patrol(M.Object8, "DronePatrol", 0);
		Wait(R, 50);	--30
	end
end

--Cerb Catalyser portal for teleporting out units
--function Routine4(R, STATE)
--	if STATE == 0 then
--		M.Object7 = BuildObject("ibnav", 2, M.Position4);
		--OnPortalDist,100,_Routine4,Object6,50
--	end
--end

--Schulz taunting player
function Routine5(R, STATE)
	if STATE == 0 then
		Advance(R, 30.0);
	elseif STATE == 1 then
		if IsAround(M.Object12) and GetDistance(M.Object11, M.Object12) < 380 then
			AudioMessage(string.format("fclast_0%d.wav", M.Variable3));	--Schultz taunting player
			M.Variable3 = M.Variable3 + 1;
			if M.Variable3 == 6 then
				M.Variable3 = 4;
			end
			Wait(R, 50.0);
		end
	end
end

function HandlePortal()
	local h = GetNearestVehicle(M.Object30);
	local dist = GetDistance(h, M.Object30);
	if dist < 50 and GetTeamNum(h) == 2 then
		local odf = GetCfg(h);
		if odf == "cvrbomb" or odf == "cvscout" or odf == "cvtank" then
			TeleportOut(h);
		end
	end
end

--respawning Cerb constructor
function Routine7(R, STATE)
	if STATE == 0 then
		if not IsAround(M.Object2) then
			Advance(R, 50.0);
		end
	elseif STATE == 1 then
		if not IsAround(M.CerbFact) then
			SetRoutineActive(R, false);	--stop respawning once factory is destroyed.
		else
			M.Object2 = BuildObject("cvcons", 2, "ConstructorEnemy");
			SetState(R, 0, 50.0);
		end
	end
end

--handles ending cutscene with escaping Cerb ship when Catalyser is destroyed
function Routine8(R, STATE)
	if STATE == 0 then
		SetMaxHealth(M.Object30, 10000);
		SetCurHealth(M.Object30, 10000);
		Advance(R);
	elseif STATE == 1 then
		if not IsAround(M.Object30) then
			M.CheckProcreator = false;--RunSpeed,_Routine11,0,true
			ClearObjectives();
			AddObjective(_Text5, "green");
			Advance(R, 8.0);
		end
	elseif STATE == 2 then
		AudioMessage("fclast_13a.wav");	--Thanatos:"By the sword of Andros! That building is not a building at all..."
		M.Position1 = GetPosition(M.Object1);
		M.Position2 = M.Position1 + SetVector(0, 30000, 0);
		M.EscapeShipMoveTime = GetTime() + 1;--SetStep,_Routine9,LOC_254
		--RunSpeed,_Routine10,2,true
		--RunSpeed,_Routine8,5,true --??
		--RunSpeed,_Routine8,10,true --??
		SetPosition(M.Object11, GetPosition("PlayerStow"));
		CameraReady();
		Advance(R);
	elseif STATE == 3 then
		if M.EscapeShipMoveTime < GetTime() then
			Move(M.Object1, 0, M.Variable1, M.Position2);
			M.Variable1 = math.min(600, M.Variable1 + 2);
		end
		if CameraPath("watch_escape", 500, 800, M.Object1) then
			--CameraFinish();
			--RunSpeed,_Routine8,10,true	--??
			AudioMessage("fclast_13b.wav");	--Corber:"We have done it..."
			SucceedMission(GetTime() + 55, "fclastw1.txt");
			M.Variable1 = 0;
			M.EscapeShipMoveTime = GetTime() + 1;--SetStep,_Routine9,LOC_256
			--SetStep,_Routine10,LOC_259
			SetPosition(M.Object1, M.Position1);
			Advance(R);
		end
	elseif STATE == 4 then
		if M.EscapeShipMoveTime < GetTime() then
			Move(M.Object1, 0, M.Variable1, M.Position2);
			M.Variable1 = math.min(600, M.Variable1 + 2);
		end
		if CameraPos(M.Object1, M.Object1, M.Position8, M.Position9, 400) then
			CameraFinish();
			Advance(R);
		end
	end
end

function Routine12()
	for i = 1, NUM_POWERGLOBES do
		SetPerceivedTeam(M.PowerGlobes[i], 2);
	end
end

function CheckStuffIsAlive()
	SetCurHealth(M.Object1, 10000);	--make Cerb escape ship invincible
	if not M.MissionOver then
		if M.CheckProcreator and not IsAround(M.Object32) then
			ClearObjectives();
			AddObjective(_Text3, "red");
			AudioMessage("fclast_14.wav");	--Thanatos:"The Procreator has been destroyed..."
			FailMission(GetTime() + 13, "fclastL1.txt");
			M.MissionOver = true;
		end
	end
end

--snaps the pos to the terrain height at that location
function TerrainFloor(pos)
	return SetVector(pos.x, TerrainFindFloor(pos), pos.z);
end

--removes the object with a teleportout effect
function TeleportOut(h)
	BuildObject("teleportout", 0, GetPosition(h));
	RemoveObject(h);
end
