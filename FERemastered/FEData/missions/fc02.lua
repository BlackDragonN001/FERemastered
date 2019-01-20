assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
require('_FECore');

--Strings
_Text1 = "dEPLOY tHE pROCREATOR aT a\nsECURE lOCATION, tHEN bUILD tHE\nbASE. mAJOR cERBERI aSSAULTS aRE\neXPECTED, sO mARSHAL yOUR\ndEFENSES cAREFULLY.";
_Text2 = "aDMIRAL lEbLANC'S pARTY wILL\nsOON tELEPORT fROM oRBIT tO a\nlOCATION nORTH oF oUR bASE.\naSSEMBLE a pOWERFUL eSCORT tO\nbRING tHEM hERE sAFELY.";
_Text3 = "tHE sCION eMISSARIES hAVE\naRRIVED oN cORE. eSCORT tHEM tO\ntHE bASE iN sAFETY.";
_Text4 = "**wARNING!! aMBUSH aHEAD!!**\naN eNERGY pORTAL hAS aPPEARED\ndIRECTLY iN yOUR pATH. tHE\ncONVOY'S gUIDANCE sYSTEM wILL\nfOLLOW aN aLTERNATE rOUTE.";
_Text5 = "aPPROACH tHE aSSEMBLER aND\ntARGET iT uSING tHE 't' kEY.\nwITH tHE aSSEMBLER sELECTED,\ndEPLOY tHE bEACON tO fIRE\ntHE aRK II'S aNTIMATTER bEAM.";
_Text6 = "bEWARE oF tHE pOWER gLOBE!!\nwEAPONS aND tARGETING aRE\nuNRELIABLE iN iTS vICINITY.\naPPROACHING oR dESTROYING tHE\ngLOBE iS eXTREMELY hAZARDOUS!";


local M = {
-- Bools
	MissionOver = false,
	ScionLeaderAround = false,
	ArkComlinkAround = false,
	Routine3Active = false,
	Routine4Active = true,
	Routine7Active = false,
-- Floats
	Routine1Timer = 0.0,
	Routine2Timer = 0.0,
	Routine3Timer = 0.0,
	Routine4Timer = 0.0,
	Routine6Timer = 0.0,
	RendezvousDeadline = 0.0,
-- Handles
	Player = nil,
	Procreator = nil,
	ScionLeader = nil,
	RoyalGuard = nil,	--Scion Royal Guard, reused for other Scion units
	Portal1Aurora1 = nil,
	Portal1Aurora2 = nil,
	Portal1Aurora3 = nil,
	Portal1Aurora4 = nil,
	Portal2Aurora1 = nil,
	Portal2Aurora2 = nil,
	Portal2Aurora3 = nil,
	Portal2Aurora4 = nil,
	AssemblerUnit = nil,	--Cerb atank at Assembler
	AssemblerCage = nil,
	CerbAssembler = nil,
	ArkUplinkPickup = nil,
	AssemblerPortal = nil,
	ArkUplink = nil,	--Ark II uplink (deployed by player)
	PowerOrbit = nil,
	PowerField = nil,
	PowerGlobe = nil,
-- Ints
	TPS = 10,
	Routine1State = 0,
	Routine2State = 0,
	Routine3State = 0,
	Routine4State = 0,
	Routine6State = 0,
	WarningCount = 0,	--how many times "beware the power globe" has flashed in objectives window
	Variable1 = 500,	--NearObjectCount scan range
	Variable2 = 0,	--Cerb walker spawn counter
	Variable3 = 0,	--Cerb tank spawn counter

--Vectors
	--Position1 = SetVector( -2000,100,-2000 ),	--off map temp pos for teleporting Cerb units
	Position2 = SetVector( -1154,21,-1179 ),	--portal spawn pos
	Position3 = SetVector( 860,0,787 ),	--Scion leader spawn pos
	Position4 = SetVector( -609,14,304 ),	--Cerb attacker spawn
	Position5 = SetVector( -189,44,23 ),	--portal spawn pos
	Position6 = SetVector( -465,15,-406 ),	--portal spawn pos
	Position7 = SetVector( 173,47,-1084 ),	--portal spawn pos
	Position9 = SetVector( -264,0,-1127 ),	--Ark II Comlink pickup spawn location
	Position10 = SetVector( -528,16,1178 ),	--recfield pos
	Position11 = SetVector( -712,-15,765 ), --recfield pos
	Position12 = SetVector( -698,0,1080 ),	--Hadean assault tank at assembler
	Position13 = SetVector( -689,0,995 ),	--Hadean assault tank at assembler
	Position14 = SetVector( -787,0,997 ),	--Hadean assault tank at assembler
	Position15 = SetVector( -783,0,1093 ),	--Hadean assault tank at assembler
--End
	endme = 0
}

function InitialSetup()
	M.TPS = EnableHighTPS();
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadOdf = {
		"recfield",
		"fvturr",
		"fvtank",
		"fvburn",
		"aurora1",
		"aurora2",
		"aurora3",
		"aurorafield",
		"zapmine_sp",
		"cvtank",
		"cvscout",
		"chvatank",
		"pgorbit",
		"pgfield",
		"pgfield2"
	};
	for k,v in pairs(preloadOdf) do
		PreloadODF(v);
	end
	local preloadAudio = {
		"fc02_01.wav",
		"fc02_02.wav",
		"fc02_03.wav",
		"fc02_03a.wav",
		"fc02_03b.wav",
		"fc02_04.wav",
		"fc02_05.wav"
	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Save()
    return M
end

function Load(...)
    if select('#', ...) > 0 then
		M = ...
    end
end

--gets an object handle by label. If it doesn't exist, throws an error.
function GetHandleOrDie(name)
	return GetHandle(name) or error("Error: object '"..name.."' not found!", 2);
end

function Start()
	Ally(6, 1);
	M.Procreator = GetHandleOrDie("unnamed_evrecy");
	M.CerbAssembler = GetHandleOrDie("Cerberi Assembler");
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)
	if GetCfg(h) == "zapmine" then
		M.ArkUplink = h;
	end
end

function DeleteObject(h)
	
end

function Update()
	M.Player = GetPlayerHandle();
	Routine1();
	Routine2();
	Routine3();
	Routine4();
	Routine6();
	Routine7();
	
	CheckStuffIsAlive();
end

--Main mission state. Spawns Scion convoy, handles escort, and Ark II Comlink pickup
function Routine1()
	if M.Routine1Timer < GetTime() then
		if M.Routine1State == 0 then			
			AddScrap(1, 40);
			AddObjective(_Text1, "white");
			AudioMessage("fc02_01.wav");	--Thanatos:"This is a suitable area to deploy..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1400;
		elseif M.Routine1State == 1 then
			BuildObject("recfield", 5, M.Position10);
			BuildObject("recfield", 5, M.Position11);
			ClearObjectives();
			AddObjective(_Text2, "white");
			AudioMessage("fc02_02.wav");	--SciWizard:"The Scion representatives have sent a coded message..."
			BuildObject("fvturr", 6, "turr1");
			BuildObject("fvturr", 6, "turr2");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 300;
		elseif M.Routine1State == 2 then
			M.ScionLeader = BuildObject("fvburn", 6, M.Position3);
			SetObjectiveOn(M.ScionLeader);
			M.ScionLeaderAround = true;--RunSpeed,_Routine6,1,true
			ClearObjectives();
			AddObjective(_Text3, "white");
			AudioMessage("fc02_03.wav");	--Thanatos:"The Scion admiral and his party have just travelled through the orbital teleporter..."
			M.RoyalGuard = BuildObject("fvtank", 6, M.Position3);
			GiveWeapon(M.RoyalGuard, "gshield");
			GiveWeapon(M.RoyalGuard, "gbolt_c");
			SetObjectiveName(M.RoyalGuard, "Royal Guard");
			SetSkill(M.RoyalGuard, 3);
			Follow(M.RoyalGuard, M.ScionLeader, 0);
			M.Routine7Active = true;--RunSpeed,_Routine7,1,true
			M.RendezvousDeadline = GetTime() + 200;
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 3 then	--LOC_27
			if GetDistance(M.Player, M.ScionLeader) < 50 then
				AudioMessage("fc02_03b.wav");	--LeBlanc:"Greetings, Colonel Corber..."
				M.Routine7Active = false;--RunSpeed,_Routine7,0,true
				Goto(M.ScionLeader, "lead", 0);
				Attack(BuildObject("cvtank", 5, M.Position4), M.ScionLeader, 0);
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 4 then	--LOC_35
			if GetDistance(M.ScionLeader, "ambush") < 140 then
				AddObjective(_Text4, "white");
				AudioMessage("fc02_04.wav");	--SciWizard:"The Cerberi have deployed an energy portal directly in your path..."
				M.Routine4Active = false;--RunSpeed,_Routine4,0,true
				local portalPos = TerrainFloor(M.Position5) + SetVector(0,40,0);
				M.Portal2Aurora1 = BuildObject("aurora1", 5, portalPos);
				M.Portal2Aurora2 = BuildObject("aurora2", 5, portalPos);
				M.Portal2Aurora3 = BuildObject("aurora3", 5, portalPos);
				M.Portal2Aurora4 = BuildObject("aurorafield", 5, portalPos);
				Goto(TeleportIn("cvrbomb", 5, M.Portal2Aurora1, 0), "retreat", 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 2;				
			end
		elseif M.Routine1State == 5 then
			local h = TeleportIn("cvwalk", 5, M.Portal2Aurora1, 0);
			SetSkill(h, 3);
			Goto(h, "walk", 1);
			Goto(M.ScionLeader, "retreat", 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 26;
		elseif M.Routine1State == 6 then	--LOC_56
			M.Variable3 = M.Variable3 + 1;
			if M.Variable3 > 10 then
				M.Routine1State = M.Routine1State + 2;--to LOC_69
				M.Routine1Timer = GetTime() + 10;
			else
				local h = TeleportIn("cvtank", 5, M.Portal2Aurora1, 0);
				SetSkill(h, 3);
				Patrol(h, "retreat", 1);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 20;
			end
		elseif M.Routine1State == 7 then
			M.Variable2 = M.Variable2 + 1;
			if M.Variable2 <= 3 then
				local h = TeleportIn("cvwalk", 5, M.Portal2Aurora1, 0);
				SetSkill(h, 3);
				Goto(h, "ambush", 1);
			end
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 10;
		elseif M.Routine1State == 8 then	--LOC_69
			if GetDistance(M.ScionLeader, M.Procreator) > 200 then
				M.Routine1State = 6;--to LOC_56
			else
				M.Routine4Active = true;--RunSpeed,_Routine4,1,true
				M.ScionLeaderAround = false;--RunSpeed,_Routine6,0,true
				RemoveObject(M.Portal2Aurora1);
				RemoveObject(M.Portal2Aurora2);
				RemoveObject(M.Portal2Aurora3);
				RemoveObject(M.Portal2Aurora4);
				RemoveObject(M.ScionLeader);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 10;--25
			end
		elseif M.Routine1State == 9 then
			ClearObjectives();
			AddObjective(_Text5, "white");
			AudioMessage("fc02_05.wav");	--LeBlanc:"I have directed the Ark II into a distant orbit..."
			M.ArkUplinkPickup = BuildObject("zapmine_sp", 0, M.Position9);
			SetObjectiveName(M.ArkUplinkPickup, "Ark II Comlink");
			SetObjectiveOn(M.ArkUplinkPickup);
			M.Routine3Active = true;--RunSpeed,_Routine3,1,true
			M.ArkComlinkAround = true;--RunSpeed,_Routine8,1,false
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 30;
		elseif M.Routine1State == 10 then	--LOC_89
			if GetDistance(M.Player, M.PowerField) < 750 then
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 11 then
			ClearObjectives()
			AddObjective(_Text6, "red");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 12 then
			ClearObjectives();
			M.WarningCount = M.WarningCount + 1;
			if M.WarningCount < 5 then
				M.Routine1State = M.Routine1State - 1;
				M.Routine1Timer = GetTime() + 1;
			else
				M.Routine1State = M.Routine1State + 1;
			end
		end
	end
end

--builds units at the Cerb assembler
function Routine2()
	if M.Routine2Timer < GetTime() then
		if M.Routine2State == 0 then
			BuildObject("evatank", 0, BuildDirectionalMatrix(M.Position12));
			BuildObject("recfield", 5, BuildDirectionalMatrix(M.Position12));
			BuildObject("evatank", 0, BuildDirectionalMatrix(M.Position13));
			BuildObject("recfield", 5, BuildDirectionalMatrix(M.Position13));
			BuildObject("evatank", 0, BuildDirectionalMatrix(M.Position14));
			BuildObject("recfield", 5, BuildDirectionalMatrix(M.Position14));
			BuildObject("evatank", 0, BuildDirectionalMatrix(M.Position15));
			BuildObject("recfield", 5, BuildDirectionalMatrix(M.Position15));
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 1 then	--LOC_122
			M.AssemblerUnit = BuildObject("evatank", 5, "start");
			Goto(M.AssemblerUnit, "finish", 1);
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = M.Routine2Timer + 20;
		elseif M.Routine2State == 2 then
			local pos = GetTransform(M.AssemblerUnit);
			M.AssemblerCage = BuildObject("cage", 5, pos);
			M.AssemblerUnit = ReplaceObject(M.AssemblerUnit, "chvatank");
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = M.Routine2Timer + 3;
		elseif M.Routine2State == 3 then
			Goto(M.AssemblerUnit, "finish2", 1);
			RemoveObject(M.AssemblerCage);
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = M.Routine2Timer + 7;
		elseif M.Routine2State == 4 then
			local pos = GetTransform(M.AssemblerUnit);
			M.AssemblerPortal = BuildObject("aurorafield", 2, pos);
			BuildObject("teleportout", 0, pos);
			BuildObject("teleportin", 0, GetPosition(M.CerbAssembler) + SetVector(5,0,0));
			RemoveObject(M.AssemblerUnit);
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = M.Routine2Timer + 3;
		elseif M.Routine2State == 5 then
			RemoveObject(M.AssemblerPortal);
			M.Routine2State = 1;--to LOC_122
		end
	end
end

--Places Power Globe above Cerb Assembler, handles player placing Ark II Comlink
function Routine3()
	if M.Routine3Active and M.Routine3Timer < GetTime() then
		if M.Routine3State == 0 then
			SetObjectiveOn(M.CerbAssembler);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 10;
		elseif M.Routine3State == 1 then
			local pos = GetPosition(M.CerbAssembler) + SetVector(40,20,0);
			M.PowerOrbit = BuildObject("pgorbit", 5, pos);
			M.PowerField = BuildObject("pgfield", 5, pos);
			AddHealth(M.PowerField, -700);
			SetObjectiveName(M.PowerField, "Shield Globe");
			M.PowerGlobe = BuildObject("pgfield2", 5, pos);
			AddHealth(M.PowerGlobe, -700);
			SetObjectiveName(M.PowerGlobe, "Power Globe");
			M.Routine3State = M.Routine3State + 1;
		elseif M.Routine3State == 2 then	--LOC_153
			if IsAround(M.ArkUplink) then
				if GetDistance(M.ArkUplink, M.CerbAssembler) < 500 and GetUserTarget() == M.CerbAssembler then
					AudioMessage("dust01.wav");
					M.Routine3State = M.Routine3State + 1;
					M.Routine3Timer = GetTime() + 4;
				else
					RemoveObject(M.ArkUplink);
					AudioMessage("fvarch13.wav");
				end
			end
		elseif M.Routine3State == 3 then
			AudioMessage("fvarch06.wav");
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 15;
		elseif M.Routine3State == 4 then
			RemoveObject(M.ArkUplink);
			AddHealth(M.PowerField, -80);
			AddHealth(M.PowerGlobe, -80);
			M.Routine3State = 2;--to LOC_153
		end
	end
end

--Spawns various portals around player's base which spawn Cerb units
function Routine4()
	if M.Routine4Active and M.Routine4Timer < GetTime() then
		if M.Routine4State == 0 then
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 20;
		elseif M.Routine4State == 1 then
			local pos = TerrainFloor(M.Position2) + SetVector(0,40,0);
			M.Portal1Aurora1 = BuildObject("aurora1", 5, M.Position2);
			M.Portal1Aurora2 = BuildObject("aurora2", 5, M.Position2);
			M.Portal1Aurora3 = BuildObject("aurora3", 5, M.Position2);
			M.Portal1Aurora4 = BuildObject("aurorafield", 5, M.Position2);
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 2 then	--LOC_183
			Attack(TeleportIn("cvtank", 5, M.Portal1Aurora1, 0), M.Procreator, 0);
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 10;
		elseif M.Routine4State == 3 then	--LOC_187
			Attack(TeleportIn("cvscout", 5, M.Portal1Aurora1, 0), M.Procreator, 0);
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 40;
		elseif M.Routine4State == 4 then	--LOC_191
			if GetHandle("unnamed_ebcbun") ~= nil then
				M.Routine4State = M.Routine4State + 1;
				M.Routine4Timer = GetTime() + 50;
			else
				M.Routine4State = 6;--to LOC_212
			end
		elseif M.Routine4State == 5 then
			RemoveObject(M.Portal1Aurora1);
			RemoveObject(M.Portal1Aurora2);
			RemoveObject(M.Portal1Aurora3);
			RemoveObject(M.Portal1Aurora4);
			local pos = TerrainFloor(M.Position6) + SetVector(0,40,0);
			M.Portal1Aurora1 = BuildObject("aurora1", 5, pos);
			M.Portal1Aurora2 = BuildObject("aurora2", 5, pos);
			M.Portal1Aurora3 = BuildObject("aurora3", 5, pos);
			M.Portal1Aurora4 = BuildObject("aurorafield", 5, pos);
			local h = TeleportIn("cvwalk", 5, M.Portal1Aurora1, 0);
			GiveWeapon(h, "gbeam_a");
			Patrol(h, "chattack", 0);
			Attack(TeleportIn("chvatank", 5, M.Portal1Aurora1, 0), M.Procreator, 0);
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 6 then	--LOC_212
			local jmp = {2,3,7};
			M.Routine4State = jmp[math.random(1,3)];
			M.Routine4Timer = GetTime() + 15;
		elseif M.Routine4State == 7 then
			if CountUnitsNearObject(M.Procreator, M.Variable1, 1, "ebpgen") >= 2 then
				RemoveObject(M.Portal1Aurora1);
				RemoveObject(M.Portal1Aurora2);
				RemoveObject(M.Portal1Aurora3);
				RemoveObject(M.Portal1Aurora4);
				local pos = TerrainFloor(M.Position7) + SetVector(0,40,0);
				M.Portal1Aurora1 = BuildObject("aurora1", 5, pos);
				M.Portal1Aurora2 = BuildObject("aurora2", 5, pos);
				M.Portal1Aurora3 = BuildObject("aurora3", 5, pos);
				M.Portal1Aurora4 = BuildObject("aurorafield", 5, pos);
				Attack(TeleportIn("chvatank", 5, M.Portal1Aurora1, 0), M.Procreator, 0);
				M.Routine4Timer = GetTime() + 60;
			end
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 8 then	--LOC_230
			local jmp = {2,3,4};
			M.Routine4State = jmp[math.random(1,3)];
		end
	end
end

--Regenerates health of Scion leader and Royal Guard 
function Routine6()
	if M.ScionLeaderAround and M.Routine6Timer < GetTime() then
		AddHealth(M.ScionLeader, 10);
		AddHealth(M.RoyalGuard, 5);
		M.Routine6Timer = GetTime() + 1;
	end
end

--Fails the mission if the player takes too long to rendezvous with the convoy
function Routine7()
	if M.Routine7Active and M.RendezvousDeadline < GetTime() then
		AudioMessage("fc02_03a.wav");	--Royal Guard:"Admiral, our escort does not appear to be coming..."
		FailMission(GetTime() + 23, "fc02b.des");
		M.Routine7Active = false;
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if M.ArkComlinkAround and not IsAround(M.CerbAssembler) then
			AddObjective(_Text5, "green");
			SucceedMission(GetTime() + 5, "fc02win.des");
			M.MissionOver = true;
		elseif not IsAround(M.Procreator) then
			FailMission(GetTime() + 5, "fc02a.des");
			M.MissionOver = true;
		elseif M.ScionLeaderAround and not IsAround(M.ScionLeader) then
			FailMission(GetTime() + 7, "fc02c.des");
			M.MissionOver = true;
		end
	end
end

function TeleportIn(odf,  team,  dest, offset)
	local pos = GetPosition(dest);
	pos.x = pos.x + offset;
	--pos.y = TerrainFindFloor(pos.x, pos.z) + 5;
	BuildObject("teleportin",  0,  pos);
	return BuildObject(odf,  team,  pos);
end

--snaps the pos to the terrain height at that location
function TerrainFloor(pos)
	return SetVector(pos.x, TerrainFindFloor(pos), pos.z);
end
