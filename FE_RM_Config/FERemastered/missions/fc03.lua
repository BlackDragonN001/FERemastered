assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

local M = {
-- Bools
	MissionOver = false,
	RescuedMatriarch = false,
	Routine4Active = false,
	Routine7Active = false,
-- Floats
	Routine1Timer = 0.0,
	Routine4Timer = 0.0,
	Routine5Timer = 0.0,
	Routine7Timer = 0.0,	
-- Handles
	Hauler1 = nil,
	Hauler2 = nil,
	Matriarch = nil,
	Attacker1 = nil,
	Attacker2 = nil,
	HadeanBuilder = nil,
	ScionPortal = nil,
	Player = nil,
	NewPortal = nil,	--Reinforcements Portal built by Hadean Builder
	Portal1Aurora1 = nil,
	Portal1Aurora2 = nil,
	Portal1Aurora3 = nil,
	Portal1Aurora4 = nil,
	Portal2Aurora1 = nil,
	Portal2Aurora2 = nil,
	Portal2Aurora3 = nil,
	Portal2Aurora4 = nil,
	MatriarchHolder = nil,	--recfield2 holding Captured Matriarch in place <2>
	CerbPowerGen = nil,
	GunSpire = nil,
	CerbMinelayer = nil,
	WeaponsCacheNav = nil,
	BeamTurret1 = nil,
	BeamTurret2 = nil,
	
-- Ints
	TPS = 10,
	Routine1State = 0,
	Routine4State = 0,
	Routine5State = 0,
	Routine7State = 0,
	Variable2 = 0,	--Cerb attack wave counter
	Variable3 = 1000,	--radius for NearObjectCount
	Variable4 = 0,	--# of Titans
	Variable5 = 0,	--# of Lancers
	Variable6 = 0,	--# of Maulers
	Variable10 = 0,		--Routine4 loop counter
	Variable11 = 0,		--if player was warned about too many unspent points in the reinforcements GUI
--Vectors
	Position3 = SetVector( 1102,85,1008 ),	--Captured Scion Matriarch location
	Position4 = SetVector( 762,0,-651 ),	--Portal spawn location
	Position5 = SetVector( 700,50,521 ),	--Portal spawn location
	Position6 = SetVector( 386,50,738 ),	--Portal spawn location
	Position9 = SetVector( 0,0,0 ),	--Portal spawn location (set later)
--End
	endme = 0,

	-- New Variables - AI_Unit
	ScionSpireCount = 0
}

function InitialSetup()
	
	_FECore.InitialSetup();
	
	M.TPS = EnableHighTPS();
	AllowRandomTracks(false);
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadOdf = {
		"fbdummy",
		"fvrecy",
		"evconsfc03",
		"aurora1",
		"aurora2",
		"aurora3",
		"aurorafield",
		"recfield2",
		"cvscout",
		"cvtank",
		"cvwalk",
		"cvrbomb",
		"cvdcar",
		"cvmlay03",
		"cvatank2",
		"cvtalon02"
	};
	for k,v in pairs(preloadOdf) do
		PreloadODF(v);
	end
	local preloadAudio = {
		"fc03_01.wav",
		"fc03_01a.wav",
		"fc03_02.wav",
		"fc03_02b.wav",
		"fc03_02c.wav",
		"fc03_03.wav",
		"fc03_03b.wav",
		"fc03_04.wav",
		"fc03_05.wav"
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

--gets an object handle by label. If it doesn't exist, throws an error.
function GetHandleOrDie(name)
	return GetHandle(name) or error("Error: object '"..name.."' not found!", 2);
end

function Start()

	_FECore.Start();
	
	Ally(6, 1);
	M.ScionPortal = GetHandleOrDie("portalfriend");
	ClearPortalDest(M.ScionPortal, true); -- Lock Portal to script only.
	M.CerbPowerGen = GetHandleOrDie("power2");
	M.WeaponsCacheNav = GetHandleOrDie("west");
	M.BeamTurret1 = GetHandleOrDie("defense1");
	M.BeamTurret2 = GetHandleOrDie("defense2");
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)

	_FECore.AddObject(h);

	if (GetTeamNum(h) == 6) then
		if (M.RescuedMatriarch) then
			--ReplaceObject(h, "anti", 6, 0.0, -1, false); -- Removed as this was breaking the "Pick me Up" command for the player when the Matriarch was deployed. Replaced with "SetPilotClass" instead. - AI_Unit.
			SetPilotClass(h, "anti");
		end
	
		if (GetCfg(h) == "fvsentfc03") then
			SetTeamNum(h, 1);
			SetGroup(h, 8);
		elseif (GetCfg(h) == "fvrbomb03") then
			SetTeamNum(h, 1);
			SetGroup(h, 9);
		elseif (GetCfg(h) == "fbspir") then
			M.ScionSpireCount = M.ScionSpireCount + 1;
		end
	end
end

function DeleteObject(h)

	_FECore.DeleteObject(h);
	
	-- Added new method of counting Scion Spires as the old way was broken.
	if (GetTeamNum(h) == 6) then
		if (GetCfg(h) == "fbspir") then
			M.ScionSpireCount = M.ScionSpireCount - 1;
		end
	end

end

function Update()

	_FECore.Update();

	M.Player = GetPlayerHandle();
	Routine1();
	Routine4();
	Routine5();
	Routine7();

	CheckStuffIsAlive();
end

--Main mission state. Handles escorting the Neohydrium tugs, rescuing Scion Matriarch
function Routine1()
	if M.Routine1Timer < GetTime() then
		if M.Routine1State == 0 then			
			M.Hauler1 = TeleportIn("fvtug", 1, M.ScionPortal, 30);
			AddHealth(M.Hauler1, -500);
			SetObjectiveName(M.Hauler1, "Neohydrium");
			SetObjectiveOn(M.Hauler1);
			M.Hauler2 = TeleportIn("fvtug", 1, M.ScionPortal, 20);
			AddHealth(M.Hauler2, -500);
			SetObjectiveName(M.Hauler2, "Neohydrium");
			SetObjectiveOn(M.Hauler2);
			Goto(M.Hauler1, "back", 1);
			Goto(M.Hauler2, "back", 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 1 then
			M.TugsAround = true;--RunSpeed,_Routine3,1,true
			local h = TeleportIn("evtank", 1, M.ScionPortal, 30);
			AddHealth(h, -1500);
			SetGroup(h, 4);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 2 then
			local h = TeleportIn("evtank", 1, M.ScionPortal, 20);
			AddHealth(h, -500);
			SetGroup(h, 4);
			h = TeleportIn("fvturr", 1, M.ScionPortal, 20);
			AddHealth(h, -2000);
			SetGroup(h, 5);
			AddObjective("fc0301.otf", "white");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 4;
		elseif M.Routine1State == 3 then
			AudioMessage("fc03_01.wav");	--Scion:"That was close. We were attacked on our way to the portal..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 10;
		elseif M.Routine1State == 4 then
			M.Attacker1 = TeleportIn("cvscout", 5, M.ScionPortal, 20);
			AddHealth(M.Attacker1, -1000);
			Attack(M.Attacker1, M.Player, 1);
			SetPerceivedTeam(M.Hauler1, 5);
			SetPerceivedTeam(M.Hauler2, 5);
			Stop(M.Hauler1);
			Stop(M.Hauler2);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 5 then	--LOC_42
			if not IsAround(M.Attacker1) then
				SetPerceivedTeam(M.Hauler1, 1);
				SetPerceivedTeam(M.Hauler2, 1);
				AudioMessage("fc03_01a.wav");	--LeBlanc:"Each of these Haulers contains 3 Neohydrium rods..."
				Goto(M.Hauler1, "back", 1);
				Goto(M.Hauler2, "back", 1);
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 6 then	--LOC_51
			if GetDistance(M.Hauler1, "back") < 30 then
				ClearObjectives();
				AddObjective("fc0302.otf", "red");
				AudioMessage("fc03_02.wav");	--LeBlanc:"The Cerberi have launched a surprise attack on the Shipyard..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 3;
			end
		elseif M.Routine1State == 7 then
			Goto(M.Hauler1, "base", 1);
			Goto(M.Hauler2, "base", 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 8 then
			local pos = BuildDirectionalMatrix(TerrainFloor(M.Position4) + SetVector(0, 40, 0));
			M.Portal1Aurora1 = BuildObject("aurora1", 5, pos);
			M.Portal1Aurora2 = BuildObject("aurora2", 5, pos);
			M.Portal1Aurora3 = BuildObject("aurora3", 5, pos);
			M.Portal1Aurora4 = BuildObject("aurorafield", 5, pos);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 9 then	--LOC_67
			M.Attacker2 = TeleportIn("cvscout",5, M.Portal1Aurora1, 1);
			Attack(M.Attacker2, M.Hauler1, 0);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 10 then	--LOC_70
			if not IsAround(M.Attacker2) then
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 20;
			end
		elseif M.Routine1State == 11 then
			if GetDistance(M.Hauler1, "base") < 40 and GetDistance(M.Hauler2, "base") < 40 then
				RemoveObject(M.Portal1Aurora1);
				RemoveObject(M.Portal1Aurora2);
				RemoveObject(M.Portal1Aurora3);
				RemoveObject(M.Portal1Aurora4);
				AudioMessage("fc03_02b.wav");	--LeBlanc:"The Cerberi just captured our Matriarch..."
				ClearObjectives();
				AddObjective("fc0303.otf", "white");
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 10;
			else
				M.Routine1State = 9;--to LOC_67
			end
		elseif M.Routine1State == 12 then
			M.HadeanBuilder = TeleportIn("evconsfc03", 1, M.ScionPortal, 20);
			SetGroup(M.HadeanBuilder, 11);
			M.Routine4Active = true;--RunSpeed,_Routine4,1,true
			Build(M.HadeanBuilder, "hbportfc03", 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 13 then
			--M.Routine4Active = true;--RunSpeed,_Routine4,1,true
			M.HadeanBuilderAround = true;--RunSpeed,_Routine2,1,true
			Dropoff(M.HadeanBuilder, "patrol", 1);
			AudioMessage("fc03_02c.wav");	--Thanatos:"We have sent a builder through the portal..."
			AddObjective("fc0304.otf", "white");
			Follow(M.Hauler1, M.ScionPortal, 1);
			Follow(M.Hauler2, M.ScionPortal, 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 14 then
			local h = TeleportIn("evserv",1,M.ScionPortal, 20);
			SetGroup(h, 6);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 40;
		elseif M.Routine1State == 15 then
			AudioMessage("fc03_03.wav");	--LeBlanc:"We've secured the other side of the portal..."
			SetObjectiveName(M.WeaponsCacheNav, "Weapons Cache");
			SetObjectiveOn(M.WeaponsCacheNav);
			ClearObjectives();
			AddObjective("fc0305.otf", "white");
			M.TugsAround = false;--RunSpeed,_Routine3,0,true
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 10;
		elseif M.Routine1State == 16 then
			TeleportOut(M.Hauler1);
			TeleportOut(M.Hauler2);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 12;
		elseif M.Routine1State == 17 then
			local pos = BuildDirectionalMatrix(TerrainFloor(M.Position5) + SetVector(0, 40, 0));
			M.Portal1Aurora1 = BuildObject("aurora1", 5, pos);
			M.Portal1Aurora2 = BuildObject("aurora2", 5, pos);
			M.Portal1Aurora3 = BuildObject("aurora3", 5, pos);
			M.Portal1Aurora4 = BuildObject("aurorafield", 5, pos);
			M.Routine7Active = true;--RunSpeed,_Routine7,1,true
			Patrol(TeleportIn("cvtank", 5, M.Portal1Aurora1, 0), "attack", 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 18 then
			Patrol(TeleportIn("cvwalk", 5, M.Portal1Aurora1, 0), "attack", 0);
			RemoveObject(M.Portal1Aurora1);
			RemoveObject(M.Portal1Aurora2);
			RemoveObject(M.Portal1Aurora3);
			RemoveObject(M.Portal1Aurora4);
			M.MatriarchHolder = BuildObject("recfield2", 5, BuildDirectionalMatrix(M.Position3));
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 19 then
			M.Matriarch = BuildObject("fbdummy",6,BuildDirectionalMatrix(M.Position3));
			Ally(6, 5);
			local pos = BuildDirectionalMatrix(TerrainFloor(M.Position5) + SetVector(0, 40, 0));
			M.Portal1Aurora1 = BuildObject("aurora1", 5, pos);
			M.Portal1Aurora2 = BuildObject("aurora2", 5, pos);
			M.Portal1Aurora3 = BuildObject("aurora3", 5, pos);
			M.Portal1Aurora4 = BuildObject("aurorafield", 5, pos);
			Patrol(TeleportIn("cvwalk", 5, M.Portal1Aurora1, 0), "attack2", 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 20 then
			Patrol(TeleportIn("cvrbomb", 5, M.Portal1Aurora1, 0), "attack2", 0);
			RemoveObject(M.Portal1Aurora1);
			RemoveObject(M.Portal1Aurora2);
			RemoveObject(M.Portal1Aurora3);
			RemoveObject(M.Portal1Aurora4);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 10;
		elseif M.Routine1State == 21 then
			SetObjectiveName(M.Matriarch, "Captured Matriarch");
			SetObjectiveOn(M.Matriarch);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 10;
		elseif M.Routine1State == 22 then
			SetObjectiveOn(M.BeamTurret1);
			SetObjectiveOn(M.BeamTurret2);
			ClearObjectives();
			AddObjective("fc0306.otf", "green");
			AudioMessage("fc03_03b.wav");	--LeBlanc:"Two masked turrets were not destroyed during the Cerberi takeover..."
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 23 then	--LOC_166
			if GetDistance(M.Player, M.BeamTurret1) < 400 then
				SetTeamNum(M.BeamTurret1, 1);
				SetTeamNum(M.BeamTurret2, 1);
				SetSkill(M.BeamTurret1, 3);
				SetSkill(M.BeamTurret2, 3);
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 24 then
			if not IsAround(M.CerbPowerGen) then
				UnAlly(6, 5);
				RemoveObject(M.MatriarchHolder);
				M.Matriarch = ReplaceObject(M.Matriarch, "fvrecy");
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 2;
			end
		elseif M.Routine1State == 25 then
			SetAIP("fc03.aip", 6);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 26 then
			ClearObjectives();
			AddObjective("fc0308.otf", "green");
			AudioMessage("fc03_04.wav");	--LeBlanc:"The surviving Scions will start building a more solid line of defenses..."
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 27 then	--LOC_185
			AddHealth(M.Matriarch, 5);
			if not M.MissionOver and not IsAround(M.Matriarch) then
				FailMission(GetTime() + 8, "fc03lose.des");
				M.MissionOver = true;
			elseif M.ScionSpireCount >= 5 then
				AudioMessage("fc03_05.wav");	--LeBlanc:"I have ordered the haulers through the portal once again..."
				ClearObjectives();
				AddObjective("fc0309.otf", "green");
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 90;
			else
				M.Routine1Timer = GetTime() + 1;
			end
		elseif M.Routine1State == 28 then
			M.Hauler1 = TeleportIn("fvtug", 1, M.ScionPortal, 20);
			SetObjectiveName(M.Hauler1, "Neohydrium");
			SetObjectiveOn(M.Hauler1);
			M.Hauler2 = TeleportIn("fvtug", 1, M.ScionPortal, 10);
			SetObjectiveName(M.Hauler2, "Neohydrium");
			SetObjectiveOn(M.Hauler2);
			M.TugsAround = true;--RunSpeed,_Routine3,1,true
			Goto(M.Hauler1, "hold3", 1);
			Goto(M.Hauler2, "hold3", 1);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 29 then	--LOC_205
			if GetDistance(M.Hauler1, "hold3") < 100 then
				SucceedMission(GetTime() + 8, "fc03win.des");
				M.Routine1State = M.Routine1State + 1;
			end
		end
	end
end

--opens a GUI to let player spawn in Scion reinforcements
function Routine4()
	if M.Routine4Active and M.Routine4Timer < GetTime() then
		if M.Routine4State == 0 then
			M.NewPortal = GetHandle("unnamed_hbportfc03");
			if M.NewPortal ~= nil then
				SetTeamNum(M.NewPortal, 0);
				M.HadeanBuilderAround = false;--RunSpeed,_Routine2,0,true
				M.Routine4State = M.Routine4State + 1;
				M.Routine4Timer = GetTime() + 2;
			end
		elseif M.Routine4State == 1 then
			TeleportOut(M.HadeanBuilder);
			IFace_Exec("fc03i01.cfg");
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 5;
		elseif M.Routine4State == 2 then	--LOC_234
			IFace_SetInteger("mission.var1", 0);
			IFace_SetInteger("mission.var2", 0);
			IFace_SetInteger("mission.var3", 0);
			IFace_SetInteger("mission.var4", 0);
			IFace_Activate("Window1");
			FreeCamera();
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 3 then
			if IFace_GetInteger("mission.var4") ~= 0 then
				IFace_SetInteger("mission.var4", 0);
				FreeFinish();
				M.Variable4 = IFace_GetInteger("mission.var1");
				M.Variable5 = IFace_GetInteger("mission.var2");
				M.Variable6 = IFace_GetInteger("mission.var3");
				M.Variable10 = 0;
				local sum = M.Variable4 * 90 + M.Variable5 * 55 + M.Variable6 * 55;
				if sum <= 200 and sum > 145 then
					M.Routine4State = M.Routine4State + 2;--to LOC_266
				else
					IFace_Activate("Window2");
					M.Routine4State = M.Routine4State + 1;
				end
			end
		elseif M.Routine4State == 4 then
			if IFace_GetInteger("mission.var4") ~= 0 then
				IFace_SetInteger("mission.var4", 0);
				FreeFinish();
				if M.Variable11 == 0 then
					M.Variable11 = 1;
					M.Routine4State = 2;--to LOC_234
				else
					M.Routine4State = M.Routine4State + 1;
				end
			end
		elseif M.Routine4State == 5 then	--LOC_266
			M.Variable10 = M.Variable10 + 1;
			if M.Variable10 > M.Variable4 then
				M.Variable10 = 0;
				M.Routine4State = M.Routine4State + 1;
			else
				local h = TeleportIn("fvatank", 1, M.ScionPortal, 20);
				SetGroup(h, 1);
				M.Routine4Timer = GetTime() + 0.5;
			end
		elseif M.Routine4State == 6 then	--LOC_273
			M.Variable10 = M.Variable10 + 1;
			if M.Variable10 > M.Variable5 then
				M.Variable10 = 0;
				M.Routine4State = M.Routine4State + 1;
			else
				local h = TeleportIn("fvarch", 1, M.ScionPortal, 20);
				GiveWeapon(h, "gabsorb");
				SetGroup(h, 2);
				M.Routine4Timer = GetTime() + 0.5;
			end
		elseif M.Routine4State == 7 then
			M.Variable10 = M.Variable10 + 1;
			if M.Variable10 > M.Variable6 then
				AddObjective("fc0307.otf", "green");
				M.Routine4State = M.Routine4State + 1;
			else
				local h = TeleportIn("fvwalk", 1, M.ScionPortal, 20);
				SetGroup(h, 3);
				M.Routine4Timer = GetTime() + 0.5;
			end
		end
	end
end

--Spawns Cerb portals and units near the Scion base once the Scion Matriarch has been rescued.
function Routine5()
	if M.Routine5Timer < GetTime() then
		if M.Routine5State == 0 then
			if not IsAround(M.CerbPowerGen) then
				M.RescuedMatriarch = true;--RunSpeed,_Routine6,1,true
				M.Routine5State = M.Routine5State + 1;
				M.Routine5Timer = GetTime() + 100;
			end
		elseif M.Routine5State == 1 then	--LOC_295
			M.Variable2 = 0;
			local pos = BuildDirectionalMatrix(TerrainFloor(M.Position5) + SetVector(0,40,0));
			M.Portal1Aurora1 = BuildObject("aurora1", 5, pos);
			M.Portal1Aurora2 = BuildObject("aurora2", 5, pos);
			M.Portal1Aurora3 = BuildObject("aurora3", 5, pos);
			M.Portal1Aurora4 = BuildObject("aurorafield", 5, pos);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 20;
		elseif M.Routine5State == 2 then	--LOC_302
			if M.ScionSpireCount > 4 then
				M.Routine5State = 12;--to LOC_376
			else
				Patrol(TeleportIn("cvtalon02", 5, M.Portal1Aurora1, 0), "mine1", 0);
				M.Routine5State = M.Routine5State + 1;
				M.Routine5Timer = GetTime() + 3;
			end
		elseif M.Routine5State == 3 then
			Patrol(TeleportIn("cvrbomb", 5, M.Portal1Aurora1, 0), "attack2", 0);
			M.Variable2 = M.Variable2 + 1;
			if M.Variable2 < 2 then
				M.Routine5State = 2;--to LOC_302
				M.Routine5Timer = GetTime() + 50;
			else
				M.Routine5State = M.Routine5State + 1;
				M.Routine5Timer = GetTime() + 25;
			end
		elseif M.Routine5State == 4 then
			RemoveObject(M.Portal1Aurora1);
			RemoveObject(M.Portal1Aurora2);
			RemoveObject(M.Portal1Aurora3);
			RemoveObject(M.Portal1Aurora4);
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 5 then	--LOC_320
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 50;
		elseif M.Routine5State == 6 then
			RemoveObject(M.Portal1Aurora1);
			RemoveObject(M.Portal1Aurora2);
			RemoveObject(M.Portal1Aurora3);
			RemoveObject(M.Portal1Aurora4);
			local pos = BuildDirectionalMatrix(TerrainFloor(M.Position6) + SetVector(0,40,0));
			M.Portal1Aurora1 = BuildObject("aurora1", 5, pos);
			M.Portal1Aurora2 = BuildObject("aurora2", 5, pos);
			M.Portal1Aurora3 = BuildObject("aurora3", 5, pos);
			M.Portal1Aurora4 = BuildObject("aurorafield", 5, pos);
			Attack(TeleportIn("cvtank", 5, M.Portal1Aurora1, 0), M.Matriarch, 0);
			Attack(TeleportIn("cvwalk", 5, M.Portal1Aurora1, 0), M.Matriarch, 0);
			M.GunSpire = GetHandle("unnamed_fbspir");
			if M.GunSpire == nil then
				M.Routine5State = 10;--to LOC_364
			else
				M.Routine5State = M.Routine5State + 1;
				M.Routine5Timer = GetTime() + 20;
			end
		elseif M.Routine5State == 7 then
			local pos = BuildDirectionalMatrix(TerrainFloor(M.Position5) + SetVector(0,40,0));
			M.Portal2Aurora1 = BuildObject("aurora1", 5, pos);
			M.Portal2Aurora2 = BuildObject("aurora2", 5, pos);
			M.Portal2Aurora3 = BuildObject("aurora3", 5, pos);
			M.Portal2Aurora4 = BuildObject("aurorafield", 5, pos);
			Attack(TeleportIn("cvdcar", 5, M.Portal2Aurora1, 0), M.GunSpire, 0);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 10;
		elseif M.Routine5State == 8 then
			local scionBuilder = GetHandle("unnamed_fvcons");
			Attack(TeleportIn("cvatank2", 5, M.Portal2Aurora1, 0), scionBuilder, 0);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 10;
		elseif M.Routine5State == 9 then
			local h = TeleportIn("cvwalk", 5, M.Portal2Aurora1, 0);
			GiveWeapon(h, "gbeam_a");
			Attack(h, M.GunSpire, 0);
			RemoveObject(M.Portal2Aurora1);
			RemoveObject(M.Portal2Aurora2);
			RemoveObject(M.Portal2Aurora3);
			RemoveObject(M.Portal2Aurora4);
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 10 then	--LOC_364
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 10;
		elseif M.Routine5State == 11 then
			RemoveObject(M.Portal1Aurora1);
			RemoveObject(M.Portal1Aurora2);
			RemoveObject(M.Portal1Aurora3);
			RemoveObject(M.Portal1Aurora4);
			if M.ScionSpireCount > 4 or IsAround(M.Hauler1) then
				M.Routine5State = M.Routine5State + 1;
			else
				local jmp = {5, 1, 2, 1};
				M.Routine5State = jmp[math.random(1,4)];
			end
		elseif M.Routine5State == 12 then	--LOC_376
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 25;
		elseif M.Routine5State == 13 then
			M.Position9 = GetPosition(M.Hauler1);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 5;
		elseif M.Routine5State == 14 then
			local pos = BuildDirectionalMatrix(TerrainFloor(M.Position9) + SetVector(0,40,0));
			M.Portal1Aurora1 = BuildObject("aurora1", 2, pos);
			M.Portal1Aurora2 = BuildObject("aurora2", 2, pos);
			M.Portal1Aurora3 = BuildObject("aurora3", 2, pos);
			M.Portal1Aurora4 = BuildObject("aurorafield", 2, pos);
			Attack(TeleportIn("cvscout", 5, M.Portal1Aurora1, 0), M.Hauler1, 0);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 20;
		elseif M.Routine5State == 15 then
			RemoveObject(M.Portal1Aurora1);
			RemoveObject(M.Portal1Aurora2);
			RemoveObject(M.Portal1Aurora3);
			RemoveObject(M.Portal1Aurora4);
			local pos = BuildDirectionalMatrix(TerrainFloor(M.Position5) + SetVector(0,40,0));
			M.Portal2Aurora1 = BuildObject("aurora1", 2, pos);
			M.Portal2Aurora2 = BuildObject("aurora2", 2, pos);
			M.Portal2Aurora3 = BuildObject("aurora3", 2, pos);
			M.Portal2Aurora4 = BuildObject("aurorafield", 2, pos);
			local h = TeleportIn("cvwalk",5,M.Portal2Aurora1, 0);
			GiveWeapon(h, "gbeam_a");
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 25;
		elseif M.Routine5State == 16 then
			RemoveObject(M.Portal2Aurora1);
			RemoveObject(M.Portal2Aurora2);
			RemoveObject(M.Portal2Aurora3);
			RemoveObject(M.Portal2Aurora4);
			M.Routine5State = 12;--to LOC_376
		end
	end
end

--spawns a Cerb minelayer and lays mines along path "mine1"
function Routine7()
	if M.Routine7Active and M.Routine7Timer < GetTime() then
		if M.Routine7State == 0 then
			M.CerbMinelayer = BuildObject("cvmlay03", 5, M.Position5);
			Patrol(M.CerbMinelayer, "mine1", 1);
			M.Routine7State = M.Routine7State + 1;
			M.Routine7Timer = GetTime() + 20;
		elseif M.Routine7State == 1 then	--LOC_426
			if IsAround(M.CerbMinelayer) then
				local pos = BuildDirectionalMatrix(TerrainFloor(GetPosition(M.CerbMinelayer)));
				BuildObject("cerbmine", 5, pos);
				M.Routine7Timer = GetTime() + 7;
			else
				M.Routine7State = M.Routine7State + 1;
			end
		end
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if M.HadeanBuilderAround and not IsAround(M.HadeanBuilder) then
			FailMission(GetTime() + 5, "fc03b.des");
			M.MissionOver = true;
		elseif M.TugsAround and (not IsAround(M.Hauler1) or not IsAround(M.Hauler2)) then
			FailMission(GetTime() + 5, "fc03a.des");
			M.MissionOver = true;
		end
	end
end

--spawns a unit with a 'teleportin' effect at the dest object with given x offset
function TeleportIn(odf,  team,  dest, offset)
	local pos = GetPosition(dest);
	pos.x = pos.x + offset;
	--pos.y = TerrainFindFloor(pos.x, pos.z) + 5;
	pos = BuildDirectionalMatrix(pos);
	BuildObject("teleportin",  0,  pos);
	return BuildObject(odf,  team,  pos);
end

--removes the object with a 'teleportout' effect
function TeleportOut(h)
	BuildObject("teleportout", 0, BuildDirectionalMatrix(GetPosition(h)));
	RemoveObject(h);
end

--snaps the pos to the terrain height at that location
function TerrainFloor(pos)
	return SetVector(pos.x, TerrainFindFloor(pos), pos.z);
end
