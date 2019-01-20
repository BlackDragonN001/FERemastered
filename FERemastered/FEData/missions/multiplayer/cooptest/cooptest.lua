
require "FE13Dev.FEAddon.lua.GlobalHandler";

--Strings
local _Text1 = "Destroy the Cerberi and Imperial Hadean bases.";
local _Text2 = "Well done!";

--Routines
local Routines = {};

local M = {
--Mission State
	RoutineState = {},
	RoutineWakeTime = {},
	RoutineActive = {},
	MissionOver = false,
	CheckRecyclers = false,
-- Bools

-- Floats

-- Handles
	Player1 = nil,
	Player2 = nil,
	--Portal1 = nil,
	--Portal2 = nil,
	HadeanRecy = nil,
	HadeanFact = nil,
	CerbRecy = nil,
	CerbFact = nil,
	Team1Recycler = nil,
	Team2Recycler = nil,
-- Ints
	Player1Race = nil,
	Player2Race = nil,
--Vectors

--End
	endme = 0
}

function InitialSetup()
	M.TPS = EnableHighTPS();
	DefineRoutines();
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadOdf = {		
		"ivrecy",
		"fvrecy",
		"evrecy",
	};
	for k,v in pairs(preloadOdf) do
		PreloadODF(v);
	end
	local preloadAudio = {

	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Save()
    return M;
end

function Load(...)
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
	DefineRoutine(2, Routine2, false);
end

function Start()
	Ally(1, 2);
	Ally(5, 6);
	UnAlly(1, 5);
	UnAlly(2, 5);
	UnAlly(1, 6);
	UnAlly(2, 6);
	
	M.CerbRecy = GetHandleOrDie("CerbRecy");
	M.CerbFact = GetHandleOrDie("CerbFact");
	M.HadeanRecy = GetHandleOrDie("HadeanRecy");
	M.HadeanFact = GetHandleOrDie("HadeanFact");
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddPlayer(id, Team, IsNewPlayer)
	--print(string.format("AddPlayer() id=%d, team=%d, isnewplayer=%s", id, Team, tostring(IsNewPlayer)));
	SetPlayerStartingCraft(Team);
end

function SetPlayerStartingCraft(team)
	local oldPlayer = GetPlayerHandle(team);
	local h = BuildObject(GetPlayerODF(team), team, TerrainFloor(SetVector(1,1,1)));
	SetAsUser(h, team);
	AddPilotByHandle(h);
	
	RemoveObject(oldPlayer);
	
	local spawnLoc = GetPosition(string.format("Team%dBase", team)) + SetVector(10,5,10);
	SetPosition(h, spawnLoc);
	return h;
end

function GetStartingRecy(team)
	local raceChar = string.sub(GetPlayerODF(team), 1, 1);
	return string.format("%svrecy", raceChar);
end

function DeletePlayer(id)
	print("DeletePlayer() id="..tostring(id));
end

function AddObject(h)

end

function DeleteObject(h)
	
end

-- enum EjectKillRetCodes 
-- {
	-- DoEjectPilot, // Do 'standard' eject
	-- DoRespawnSafest, // Respawn a 'PLAYER' at safest spawnpoint
	-- DLLHandled, // DLL handled actions. Do nothing ingame
	-- DoGameOver, // Game over, man.
-- };
function ObjectKilled(deadHandle, killerHandle)
	--respawns players if they are killed
	if not IsPerson(deadHandle) then
		return 0;
	elseif deadHandle == M.Player1 then
		print("Player1 was killed. Respawning...");
		SetPlayerStartingCraft(1);
	elseif deadHandle == M.Player2 then
		print("Player2 was killed. Respawning...");
		SetPlayerStartingCraft(2);
	end
end

function Update()
	M.Player1 = GetPlayerHandle(1);
	M.Player2 = GetPlayerHandle(2);
	for routineID,r in pairs(Routines) do
		if M.RoutineActive[routineID] and M.RoutineWakeTime[routineID] <= GetTime() then
			r(routineID, M.RoutineState[routineID]);
		end
	end
	CheckStuffIsAlive();
end

function Routine1(R, STATE)
	if STATE == 0 then
		if IsAround(M.Player1) then
			SetPlayerStartingCraft(1);
		end
		if IsAround(M.Player2) then
			SetPlayerStartingCraft(2);
		end
		AddObjective("Waiting for player 2 to join...");
		Advance(R);
	elseif STATE == 1 then
		if M.Player1 ~= nil and M.Player2 ~= nil then
			ClearObjectives();	
			AddObjective(_Text1, "white");
			
			--spawn in appropriate recyclers
			local recySpawn1 = GetPosition("Team1Base") + SetVector(30,5,30);
			local recySpawn2 = GetPosition("Team2Base") + SetVector(30,5,30);
			M.Team1Recycler = BuildObject(GetStartingRecy(1), 1, recySpawn1);
			SetGroup(M.Team1Recycler, 0);
			M.Team2Recycler = BuildObject(GetStartingRecy(2), 2, recySpawn2);
			SetGroup(M.Team2Recycler, 0);
			SetScrap(1, 40);
			SetScrap(2, 40);
			SetScrap(5, 40);
			SetScrap(6, 40);
			M.CheckRecyclers = true;
			
			--set enemy AIPs and patrols
			--SetAIP("xxx.aip", 5);
			--SetAIP("xxx.aip", 6);
			Patrol(BuildObject("cvtank", 5, "Patrol1"), "Patrol1", 0);
			Patrol(BuildObject("cvtank", 5, "Patrol2"), "Patrol2", 0);
			Patrol(BuildObject("cvtank", 5, "Patrol3"), "Patrol3", 0);
			Patrol(BuildObject("cvscout", 5, "Patrol1"), "Patrol1", 0);
			Patrol(BuildObject("cvscout", 5, "Patrol2"), "Patrol2", 0);
			Patrol(BuildObject("cvscout", 5, "Patrol3"), "Patrol3", 0);
			
			SetRoutineActive(2, true);
			
			Advance(R);
		end
	elseif STATE == 2 then
		if not IsAround(M.CerbRecy) and not IsAround(M.HadeanRecy) then
			ClearObjectives();
			AddObjective(_Text2, "green");
			SucceedMission(GetTime() + 10);
			Advance(R);
		end
	end
end

--Hadean attacks
function Routine2(R, STATE)
	if not IsAround(M.HadeanRecy) then
		SetRoutineActive(R, false);
	elseif STATE == 0 then
		Advance(R, 120.0);
	elseif STATE == 1 then
		Attack(BuildObject("evscout", 6, GetCircularPos(M.HadeanRecy, 20, 0)), M.Team1Recycler, 0);
		Attack(BuildObject("evscout", 6, GetCircularPos(M.HadeanRecy, 20, 20)), M.Team1Recycler, 0);
		Attack(BuildObject("evscout", 6, GetCircularPos(M.HadeanRecy, 20, 40)), M.Team1Recycler, 0);
		Attack(BuildObject("evscout", 6, GetCircularPos(M.HadeanRecy, 20, 60)), M.Team2Recycler, 0);
		Attack(BuildObject("evscout", 6, GetCircularPos(M.HadeanRecy, 20, 80)), M.Team2Recycler, 0);
		Attack(BuildObject("evscout", 6, GetCircularPos(M.HadeanRecy, 20, 100)), M.Team2Recycler, 0);
		Advance(R, 120.0);
	elseif STATE == 2 then
		Attack(BuildObject("evtank", 6, GetCircularPos(M.HadeanRecy, 20, 0)), M.Team1Recycler, 0);
		Attack(BuildObject("evtank", 6, GetCircularPos(M.HadeanRecy, 20, 20)), M.Team1Recycler, 0);
		Attack(BuildObject("evmisl", 6, GetCircularPos(M.HadeanRecy, 20, 40)), M.Team1Recycler, 0);
		Attack(BuildObject("evtank", 6, GetCircularPos(M.HadeanRecy, 20, 60)), M.Team2Recycler, 0);
		Attack(BuildObject("evtank", 6, GetCircularPos(M.HadeanRecy, 20, 80)), M.Team2Recycler, 0);
		Attack(BuildObject("evmisl", 6, GetCircularPos(M.HadeanRecy, 20, 100)), M.Team2Recycler, 0);
		Advance(R, 200.0);	
	elseif STATE == 3 then
		Attack(BuildObject("evmort", 6, GetCircularPos(M.HadeanRecy, 20, 0)), M.Team1Recycler, 0);
		Attack(BuildObject("evtank", 6, GetCircularPos(M.HadeanRecy, 20, 20)), M.Team1Recycler, 0);
		Attack(BuildObject("evmisl", 6, GetCircularPos(M.HadeanRecy, 20, 40)), M.Team1Recycler, 0);
		Attack(BuildObject("evmort", 6, GetCircularPos(M.HadeanRecy, 20, 60)), M.Team2Recycler, 0);
		Attack(BuildObject("evtank", 6, GetCircularPos(M.HadeanRecy, 20, 80)), M.Team2Recycler, 0);
		Attack(BuildObject("evmisl", 6, GetCircularPos(M.HadeanRecy, 20, 100)), M.Team2Recycler, 0);
		Advance(R, 150.0);
	elseif STATE == 4 then
		Attack(BuildObject("evmislu", 6, GetCircularPos(M.HadeanRecy, 20, 0)), M.Team1Recycler, 0);
		Attack(BuildObject("evmislu", 6, GetCircularPos(M.HadeanRecy, 20, 20)), M.Team1Recycler, 0);
		Attack(BuildObject("evmislu", 6, GetCircularPos(M.HadeanRecy, 20, 40)), M.Team1Recycler, 0);
		Attack(BuildObject("evmislu", 6, GetCircularPos(M.HadeanRecy, 20, 60)), M.Team2Recycler, 0);
		Attack(BuildObject("evmislu", 6, GetCircularPos(M.HadeanRecy, 20, 80)), M.Team2Recycler, 0);
		Attack(BuildObject("evmislu", 6, GetCircularPos(M.HadeanRecy, 20, 100)), M.Team2Recycler, 0);
		Advance(R, 200.0);
	elseif STATE == 5 then
		Attack(BuildObject("evtanku", 6, GetCircularPos(M.HadeanRecy, 20, 0)), M.Team1Recycler, 0);
		Attack(BuildObject("evtanku", 6, GetCircularPos(M.HadeanRecy, 20, 20)), M.Team1Recycler, 0);
		Attack(BuildObject("evmislu", 6, GetCircularPos(M.HadeanRecy, 20, 40)), M.Team1Recycler, 0);
		Attack(BuildObject("evmort", 6, GetCircularPos(M.HadeanRecy, 20, 60)), M.Team1Recycler, 0);
		Attack(BuildObject("evmort", 6, GetCircularPos(M.HadeanRecy, 20, 80)), M.Team1Recycler, 0);
		Attack(BuildObject("evmort", 6, GetCircularPos(M.HadeanRecy, 20, 100)), M.Team1Recycler, 0);
		Attack(BuildObject("evtanku", 6, GetCircularPos(M.HadeanRecy, 20, 0)), M.Team2Recycler, 0);
		Attack(BuildObject("evtanku", 6, GetCircularPos(M.HadeanRecy, 20, 20)), M.Team2Recycler, 0);
		Attack(BuildObject("evmislu", 6, GetCircularPos(M.HadeanRecy, 20, 40)), M.Team2Recycler, 0);
		Attack(BuildObject("evmort", 6, GetCircularPos(M.HadeanRecy, 20, 60)), M.Team2Recycler, 0);
		Attack(BuildObject("evmort", 6, GetCircularPos(M.HadeanRecy, 20, 80)), M.Team2Recycler, 0);
		Attack(BuildObject("evmort", 6, GetCircularPos(M.HadeanRecy, 20, 100)), M.Team2Recycler, 0);
		SetState(R, 4, 120.0);
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if M.CheckRecyclers and not IsAround(M.Team1Recycler) then
			ClearObjectives();
			AddObjective("Player1 lost their Recycler. Mission Failed.", "red");
			FailMission(GetTime() + 5);
			M.MissionOver = true;
		elseif M.CheckRecyclers and not IsAround(M.Team2Recycler) then
			ClearObjectives();
			AddObjective("Player2 lost their Recycler. Mission Failed.", "red");
			FailMission(GetTime() + 5);
			M.MissionOver = true;
		end
	end
end

function TerrainFloor(pos)
	return SetVector(pos.x, TerrainFindFloor(pos), pos.z);
end



