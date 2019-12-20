assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

--Strings
_Text1 = "Take out the Hadean recycler.";
_Text2 = "Escort the PEACEMAKER and\nlook around for a good location\nto establish a base. Hurry,\nbecause several units were\ndamaged in the crash.";
_Text3 = "Deploy the PEACEMAKER, then\nsearch for biometal deposits.\nSkyEye has documented\nsubstantial quantities buried\ndeep beneath the surface.";
_Text4 = "SkyEye has tagged several\nlarge boulders in the area\nwhich may be capstones for\nbiometal veins. Destroy them\nto find any hidden scrap pools.";
_Text5 = "Establish a base and fortify\nit carefully. The Hadeans have\ndetected our presence and\nhave already generated a\nformidable assault force!";
_Text6 = "Recon the area near this nav\nbeacon until further notice.\nDo NOT leave this vicinity for\nany reason!";
_Text7 = "Head to the nav beacon and\nrecon that area quickly! Time\nis running out, and we need\nto know what's happening down\nthere!";
_Text8 = "Do NOT leave this area! Micro-\ntremors and electromagnetic\nactivity are peaking. Return to\nthe nav beacon and continue to\nobserve!";
_Text9 = "Build an assault force and\ndestroy the Nexus. It's heavily\nshielded, so you'll need\nsubstantial firepower!";
_Text10 = "You've lost the PEACEMAKER, and\nallowed the Imperials to create\nan overwhelming Nexus force.\nEarth will soon be under the\nEmperor's control!";

local M = {
-- Bools
	MissionOver = false,
	Routine2Active = true,
	Routine5Active = false,
	Routine6Active = false,
	Routine7Active = false,
	Routine8Active = false,
	Routine10Active = false,
	Routine11Active = false,
	Routine16Active = false,
	Routine17Active = false,
	SpawnPool = false,
	
-- Floats
	Routine1Timer = 0.0,
	Routine2Timer = 0.0,
	Routine5Timer = 0.0,
	Routine6Timer = 0.0,
	Routine7Timer = 0.0,
	Routine8Timer = 0.0,
	Routine10Timer = 0.0,
	Routine11Timer = 0.0,
	Routine16Timer = 0.0,
	CameraEndTime = 0.0,
	PoolSpawnTime = 0.0,

-- Handles
	BaseNav = nil,	--Base nav
	HadeanTurret = nil,	--Hadean turret
	Player = nil,	--Player
	Nexus = nil,	--Nexus
	NexusHangar = nil,	--Nexus hangar
	NexusAttacker = nil,	--units spawned by Nexus
	Recycler = nil,	--Recycler
	Enemy1 = nil,	--enemy 1
	Enemy2 = nil,	--enemy 2
	Enemy3 = nil,	--enemy 3
	CamNav = nil,	--Cam nav
	HadeanActivityNav = nil,	--"Hadean Activity" nav
	Scout1 = nil,	--Scout 1
	Scout2 = nil,	--Scout 2
	Wingman1 = nil,	--Wingman 1 (tank)
	Wingman2 = nil,	--Wingman 2 (tank)
	PlayerTurret = nil,	--EDF Turret
	TartarusBldg1 = nil,	--Tartarus IV Bldg
	TartarusBldg2 = nil,	--Tartarus IV Bldg
	NexusTube = nil,	--Nexus tube
	NexusBolt = nil,	--Nexus bolt
	ScrapRock01 = nil,	--Scrap rock 01 (for cutscene)
	HadeanTurret8 = nil,	--nearest vehicle that nexus spawned
	NewPatroller = nil, --New Hadean Patrol guy
	HadeanSbay = nil,	--Hadean Sbay
	HadeanFact = nil,	--Hadean Fact
	HadeanRecy = nil,	--Hadean Recy
	HadeanPatrols = {}, --Hadeans patrolling area around nexus hangar
	NewScrapPool = nil,
-- Ints
	TPS = 10,
	Routine1State = 0,
	Routine2State = 0,
	Routine5State = 0,
	Routine6State = 0,
	Routine7State = 0,
	Routine8State = 0,
	Routine10State = 0,
	Routine11State = 0,
	Routine16State = 0,
	
	Variable2 = 80,	--nexus turn speed
	Variable3 = 30.0,	--nexus move speed
	Variable6 = 9.0,	--Tartarus IV Bldg move speed
	Variable9 = 0,		--Nexus state.0=Moving 1=Can build units 2=Repairing 3=Damaged, heading back to hangar
	Variable10 = 0,		--fury/typhon/claw spawn timer
	Variable11 = 50000,	--nexus max health
	Variable12 = 47500,	--below this, nexus is considered to be damaged
	Variable13 = 0,		--number of scrap rocks destroyed
	Variable15 = 2,	--the active AIP (0,1,2)
	Variable16 = 0,	--# of gtows player has built
	Variable18 = 0,	--nexus destination (0 or 1)
	Variable19 = 0,	--fail timer for getting back to observe Hadean activity
	Variable20 = 0,	--routine11 timer?
	Variable28 = 0,	--fvfurytk spawn counter
	Variable29 = 0,	--claw/tyrant spawn counter
	HardinNagCount = 0,	--how many times Hardin has told the player to investigate the hadean activity

--Vectors
	Position1 = SetVector(-25,-65,150),	--"Hadean Activity" nav loc
	Position2 = SetVector( 0,0,0),	--Nexus bolt pos
	Position4 = SetVector( 0,0,0),		--used for placing/moving Nexus towers
	Position5 = SetVector( 0,0,0),		--used for placing/moving Nexus towers
	Position7 = SetVector( -2,2,-5),	--CameraOf offset
	Position8 = SetVector( 5,2,2),		--CameraOf offset
	Position9 = SetVector( 160,160,80),		--offset for CamPos
	Position10 = SetVector( 20,25,-70),		--move to for CamPos
	Position11 = SetVector( 140,100,140),	--CameraObject offset
	Position13 = SetVector( 0,100,100),		--offset for CamPos
	Position14 = SetVector( 150,180,150),	--move to for CamPos
	Position15 = SetVector( -240,180,70),	--dead Nexus spawn location (for cutscene)
	Position16 = SetVector( -270,250,40),	--dead Nexus move target
	Position17 = SetVector( -320,150,-95),	--Nexus crash location
	Position19 = SetVector( 0,0,0),	--old player position
	PoolSpawnPos = nil,
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
	--Preload to reduce lag spikes when things are spawned in for the first time.
	local preloadOdf = {
		"ivrecy",
		"evcons",
		"mepool01",
		"ebnexus01",
		"evnexus01",
		"tartow01",
		"nexusbolt",
		"nexustube",
		"fvfurytk",
		"cvtyrant",
		"cvclaw"
	};
	local preloadAudio = {
		"edflast_01.wav",
		"edflast_01a.wav",
		"edflast_02.wav",
		"edflast_03.wav",
		"edflast_04.wav",
		"edflast_05.wav",
		"edflast_06.wav",
		"edflast_06a.wav",
		"edflast_06b.wav",
		"edflast_07.wav",
		"edflast_08.wav",
		"edflast_8a.wav",
		"edflast_09.wav",
		"edflast_10.wav",
		"edflast_11.wav",
		"edflast_12.wav",
		"edflast_13.wav",
		"edflast_14.wav",
		"edflast_15.wav",
		"edflast_15a.wav",
		"edflast_15b.wav",
		"edflast_16.wav"
	};
	for k,v in pairs(preloadOdf) do
		PreloadODF(v);
	end
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

--gets an object handle by label. If it doesn't exist, throws an error.
function GetHandleOrDie(name)
	return GetHandle(name) or error("Error: object '"..name.."' not found!", 2);
end

--snaps a position to the terrain height at that location
function TerrainFloor(pos)
	return SetVector(pos.x, TerrainFindFloor(pos), pos.z);
end

function Start()

	_FECore.Start();
	
	GiveWeapon(GetPlayerHandle(), "gtytech");--DEBUG!
	M.NexusHangar = GetHandleOrDie("nexhangar");
	M.Recycler = BuildObject("ivrecy", 1, "Friend1");
	M.ScrapRock01 = GetHandleOrDie("ScrapRock01");
	M.HadeanSbay = GetHandleOrDie("ServiceBayEnemy");
	M.HadeanFact = GetHandleOrDie("FactoryEnemy");
	M.HadeanRecy = GetHandleOrDie("RecyclerEnemy");
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)

	_FECore.AddObject(h);
	
	local odf = GetCfg(h);
	if odf == "ibgtow" then
		M.Variable16 = M.Variable16 + 1;
		if M.Variable15 == 2 then
			M.Variable15 = 0;
			SetAIP("edflast0.aip", 5);
		end
	--elseif odf == "ibscav" or odf == "ibscup" then
	--	SetAIP(string.format("edflast%i.aip", M.Variable15), 5);
	elseif odf == "evatanku" then
		M.NewPatroller = h;
		Routine13();--RunSpeed,_Routine13,7,true
	elseif odf == "evscout" then
		GiveWeapon(h, "gshellgun_c");
	elseif odf == "ebsbay" then
		M.HadeanSbay = h;
	elseif odf == "ebfact" or odf == "ebfact2" then
		M.HadeanFact = h;
	elseif odf == "evtanku" or odf == "evmislu" then
		for i = 1,8 do
			if not IsAround(M.HadeanPatrols[i]) then
				M.HadeanPatrols[i] = h;
				if M.Variable15 == 1 then
					M.NewPatroller = h;
					Routine13();--RunSpeed,_Routine13,7,true
				end
			end
		end
	end
end

function DeleteObject(h)

	_FECore.DeleteObject(h);

	local odf = GetCfg(h);
	if odf == "scraprock03" or odf == "scraprock01" then
		if h == M.ScrapRock01 then
			M.PoolSpawnPos = GetPosition2(h);
			M.SpawnPool = true;
			M.PoolSpawnTime = GetTime() + 0.2;
			M.ScrapRock01 = BuildObject("ibnav", 2, M.PoolSpawnPos);
			Goto(M.Enemy3, M.ScrapRock01, 0);
			LookAt(M.Scout1, M.ScrapRock01, 1);
			AudioMessage("edflast_03.wav");	--Scout:"The Hadeans just found a scrap pool under that boulder sir..."
		else
			M.Variable13 = M.Variable13 + 1;
			if M.Variable13 % 2 == 1 then
				M.PoolSpawnPos = GetPosition2(h);
				M.SpawnPool = true;
				M.PoolSpawnTime = GetTime() + 0.2;
				--BuildObject("mepool01", 0, pos);	--if called here, it screws up terrain!
			end
		end
	elseif odf == "ibgtow" then
		M.Variable16 = M.Variable16 - 1;
		if M.Variable16 == 0 and M.Variable15 ~= 2 then
			SetAIP("edflast2.aip", 5);
			M.Variable15 = 2;
		end
	end
	
end

function Update()

	_FECore.Update();
	
	M.Player = GetPlayerHandle();
	Routine1();
	Routine2();
	Routine5();
	Routine6();
	Routine7();
	Routine8();
	Routine10();
	Routine11();
	Routine16();
	Routine17();
	CheckStuffIsAlive();
	
	--spawns a scrap pool where the destroyed rock was
	if M.SpawnPool and M.PoolSpawnTime < GetTime() then
		M.PoolSpawnPos = M.PoolSpawnPos - SetVector(16,0,16);
		M.NewScrapPool = BuildObject("mepool01", 0, BuildDirectionalMatrix(TerrainFloor(M.PoolSpawnPos)));
		M.SpawnPool = false;
	end
end

--main mission state.
function Routine1()
	if M.Routine1Timer < GetTime() then
		if M.Routine1State == 0 then
			SetPerceivedTeam(M.ScrapRock01, 1);
			Damage(M.Recycler, 1000);
			M.Routine9Active = true;--RunSpeed,_Routine9,1,false
			Patrol(M.Recycler, "RecyPath", 1);
			--M.BaseNav = BuildObject("ibnav", 1, "RecyclerStart");	--this location is way off map??
			M.BaseNav = BuildObject("ibnav", 1, "RecyclerDest");
			SetObjectiveName(M.BaseNav, "Base");
			SetObjectiveOn(M.BaseNav);
			Damage(M.Player, 450);
			M.PlayerTurret = BuildObject("ivturr", 1, "Turret1");
			Damage(M.PlayerTurret, 400);
			SetGroup(M.PlayerTurret, 3);
			Follow(M.PlayerTurret, M.Recycler, 0);
			M.BaseNav2 = BuildObject("ivscav", 1, "Scav1");
			Damage(M.BaseNav2, 2700);
			SetGroup(M.BaseNav2, 4);
			Follow(M.BaseNav2, M.Recycler, 0);
			M.Wingman2 = BuildObject("ivtank", 1, "Friend2");
			Damage(M.Wingman2, 2500);
			SetGroup(M.Wingman2, 1);
			Follow(M.Wingman2, M.Recycler, 0);
			--M.Routine1Active = true;--RunSpeed,_Routine1,1,true
			M.Wingman1 = BuildObject("ivtank", 1, "Friend2");
			Damage(M.Wingman1, 500);
			SetGroup(M.Wingman1, 1);
			Follow(M.Wingman1, M.Recycler, 0);
			M.Scout1 = BuildObject("ivscout", 1, "Scout1");
			Damage(M.Scout1, 100);
			SetGroup(M.Scout1, 2);
			Follow(M.Scout1, M.Recycler, 1);
			M.Scout2 = BuildObject("ivscout", 1, "Scout2");
			Damage(M.Scout2, 200);
			SetGroup(M.Scout2, 2);
			Follow(M.Scout2, M.Recycler, 1);
			SetPerceivedTeam(M.Scout1, 5);
			SetPerceivedTeam(M.Scout2, 5);
			SetScrap(1, 40);
			M.HadeanTurret = BuildObject("evturr", 5, "TurretTrap1");
			Patrol(BuildObject("evtank", 5, "TarPatrol1"), "TarPatrol1", 1);
			Patrol(BuildObject("evtank", 5, "TarPatrol1"), "TarPatrol1", 1);
			Patrol(BuildObject("evtank", 5, "TarPatrol2"), "TarPatrol2", 1);
			Patrol(BuildObject("evtank", 5, "TarPatrol2"), "TarPatrol2", 1);
			Patrol(BuildObject("evtank", 5, "TarPatrol3"), "TarPatrol3", 1);
			M.Routine17Active = true;--RunSpeed,_Routine17,6,true			
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 8;
		elseif M.Routine1State == 1 then
			Goto(M.Recycler, "RecyclerDest", 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 2 then
			Follow(M.Wingman1, M.Recycler, 0);
			Follow(M.Wingman2, M.Recycler, 0);
			Follow(M.Scout1, M.Wingman2, 0);
			Follow(M.Scout2, M.Scout1, 0);
			M.Enemy1 = BuildObject("evtank", 5, "Enemy1");
			--GiveWeapon(M.Enemy1, "gcphcg_c");--Particle Gun??
			Goto(M.Enemy1, M.Recycler, 1);
			M.Enemy2 = BuildObject("evtank", 5, "Enemy1");
			Goto(M.Enemy2, M.Recycler, 1);
			M.Enemy3 = BuildObject("evscout", 5, "Enemy1");
			Goto(M.Enemy3, M.Recycler, 1);
			M.Routine5Active = true;--RunSpeed,_Routine5,1,true
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 45;
		elseif M.Routine1State == 3 then
			--Goto(M.PlayerTurret, "TurretDest", 0);	--your turret randomly deciding to go to the base loc on its own and dying is annoying. removed.
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 4 then	--LOC_71
			if GetDistance(M.Recycler, "RecyclerDest") < 100 then
				Goto(M.Recycler, "RecyclerDest", 0);
				--Stop(M.Recycler, 0);
				SetBestGroup(M.Recycler);--SetGroup(M.Recycler, 0);
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 5 then	--LOC_74
			if (not IsAlive(M.HadeanTurret) or GetTeamNum(M.HadeanTurret) ~= 5) 
			and (not IsAlive(M.Enemy1) or GetTeamNum(M.Enemy1) ~= 5)
			and (not IsAlive(M.Enemy2) or GetTeamNum(M.Enemy2) ~= 5)
			and (not IsAlive(M.Enemy3) or GetTeamNum(M.Enemy3) ~= 5) then
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 2;
			end
		elseif M.Routine1State == 6 then	--LOC_88
			AudioMessage("edflast_1a.wav");	--Corber:"Well done, everyone..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 7 then
			Goto(M.Scout1, "ScoutPatrol1", 1);
			Retreat(M.Scout2, "ScoutPatrol2", 1);
			SetPerceivedTeam(M.Scout1, 5);
			SetPerceivedTeam(M.Scout2, 5);
			ClearObjectives();
			AddObjective(_Text3, "white");
			M.BaseNav2 = BuildObject("evcons", 5, "EnemySpawn0");
			SetAIP("edflast2.aip", 5);
			M.Variable15 = 2;
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 35;	--bumped up from 25 to ensure scout reaches destination in time for cutscene
		elseif M.Routine1State == 8 then
			M.Enemy1 = BuildObject("evtank", 5, "Enemy1");
			Goto(M.Enemy1, M.Recycler, 1);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 9 then	--LOC_103
			if GetCurrentCommand(M.Scout1) == 0 and (GetTeamNum(M.Enemy1) ~= 5 or not IsAlive(M.Enemy1)) then
				LookAt(M.Scout1, M.ScrapRock01, 1);
				M.Enemy1 = BuildObject("evatank", 5, "Enemy2");
				SetPerceivedTeam(M.Enemy1, 1);
				Attack(M.Enemy1, M.ScrapRock01, 1);
				M.Enemy2 = BuildObject("evscout", 5, "Enemy2");
				SetPerceivedTeam(M.Enemy2, 1);
				GiveWeapon(M.Enemy2, "gshellgun_c");
				Attack(M.Enemy2, M.ScrapRock01, 1);
				M.Enemy3 = BuildObject("evscav", 5, "EnemyScav");
				SetPerceivedTeam(M.Enemy3, 1);
				Goto(M.Enemy3, M.ScrapRock01, 1);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 5;
			end
		elseif M.Routine1State == 10 then
			SetUserTarget(M.Scout1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 11 then
			AudioMessage("edflast_02.wav");	--Scout:"I've got a visual on a Hadean contact..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 12 then
			if IsAround(M.Scout1) then
				CameraReady();
				M.CameraEndTime = GetTime() + 20;
				M.Routine1State = M.Routine1State + 1;
			else
				M.Routine1State = M.Routine1State + 2;
			end
		elseif M.Routine1State == 13 then
			CameraOf(M.Scout1, M.Position7);
			if M.CameraEndTime < GetTime() then
				CameraFinish();
				Goto(M.Scout1, "Friend1", 0);
				SetBestGroup(M.Scout1);
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 14 then	--LOC_129
			SetPerceivedTeam(M.Enemy1, 5);
			SetPerceivedTeam(M.Enemy2, 5);
			SetPerceivedTeam(M.Enemy3, 5);
			Goto(M.Enemy3, M.NewScrapPool, 0);	--get the Hadean scav to deploy on the new scrap pool
			--OnNewObject,100,_Routine3,Object21
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 15 then
			for i= 0,9 do
				local h = GetHandle("ScrapRock0"..tostring(i));
				SetTeamNum(h, 5);
			end
			ClearObjectives();
			AddObjective(_Text4, "white");
			Goto(BuildObject("evtank", 5, "TarPatrol1"), M.Recycler, 0);
			Goto(M.Enemy1, M.Recycler, 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 13;
		elseif M.Routine1State == 16 then
			SetUserTarget(M.NexusTube);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 17 then	--LOC_145
			if GetCurrentCommand(M.Scout2) == 0 then
				LookAt(M.Scout2, M.HadeanRecy, 1);
				SetUserTarget(M.Scout2);
				SetObjectiveOn(M.HadeanRecy);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 4;
			end
		elseif M.Routine1State == 18 then
			AudioMessage("edflast_04.wav");	--Scout:"I've just reached their base..."
			CameraReady();
			M.CameraEndTime = GetTime() + 7;
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 19 then
			CameraOf(M.Scout2, M.Position8);
			if M.CameraEndTime < GetTime() then
				CameraFinish();
				SetUserTarget(M.NexusTube);
				Retreat(M.Scout2, "Scout2Return", 1);
				SetObjectiveOff(M.HadeanRecy);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 20;
			end
		elseif M.Routine1State == 20 then
			SetPerceivedTeam(M.Scout1, 1);
			SetPerceivedTeam(M.Scout2, 1);
			M.Routine17Active = false;--RunSpeed,_Routine17,0,true
			BuildObject("evturr", 5, "EnemySpawn0");
			BuildObject("evturr", 5, "EnemySpawn1");
			BuildObject("evturr", 5, "EnemySpawn2");
			SetObjectiveOn(M.Enemy1);--DEBUG
			Goto(M.Enemy1, M.Recycler, 0);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 21 then	--LOC_163
			if not IsAround(M.Enemy1) then
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 3;
			end
		elseif M.Routine1State == 22 then
			AddAmmo(M.Enemy2, 1000);
			Goto(M.Enemy2, M.Recycler, 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 20;
		elseif M.Routine1State == 23 then
			Goto(M.Scout2, "Scav1", 0);
			SetBestGroup(M.Scout2);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 24 then
			if GetTime() > 390 or GetMaxScrap(1) >= 60 then
				ClearObjectives();
				AddObjective(_Text5, "white");
				AudioMessage("edflast_05.wav");	--Rubikov:"Skyeye has just detected a series of electromagnetic pulses..."
				M.HadeanActivityNav = BuildObject("ibnav", 1, M.Position1);
				SetObjectiveName(M.HadeanActivityNav, "Hadean Activity");
				SetObjectiveOn(M.HadeanActivityNav);
				M.Routine1State = M.Routine1State + 1;
			end
		end
	end
end

--handles opening cutscene, nexus appearing, and nexus destroyed cutscenes
function Routine2()
	if M.Routine2Active and M.Routine2Timer < GetTime() then
		if M.Routine2State == 0 then
			M.CamNav = BuildObject("ibnav", 2, "CamNav");
			--AudioMessage("xemt2.wav");
			SetColorFade(2, 1, Make_RGB(0,0,0));
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 2;
		elseif M.Routine2State == 1 then
			AudioMessage("edflast_01.wav");	--Rubikov:"Welcome to Earth..."
			CameraReady();
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 2 then
			if CameraPos(M.CamNav, M.CamNav, M.Position9, M.Position10, 1500) or CameraCancelled() then
				CameraFinish();
				ClearObjectives();
				AddObjective(_Text2, "white");
				RemoveObject(M.CamNav);
				M.Routine2Active = false;--RunSpeed,_Routine2,0,true
				M.Routine2State = M.Routine2State + 1;
			end
		elseif M.Routine2State == 3 then
			SetAnimation(M.NexusHangar, "open", 1);
			StartAnimation(M.NexusHangar);
			CameraReady();
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 4 then
			if CameraPos(M.NexusHangar, M.NexusHangar, M.Position13, M.Position14, 900.0) or CameraCancelled() then
				CameraFinish();
				M.Routine2State = M.Routine2State + 1;
			end
		elseif M.Routine2State == 5 then	--LOC_190
			if IsAround(M.NexusAttacker) then
				AudioMessage("edflast_11.wav");	--Rubikov:"We've just spotted something emerging from the Nexus..."
				CameraReady();
				M.CameraEndTime = GetTime() + 10;
				M.Routine2State = M.Routine2State + 1;
			end
		elseif M.Routine2State == 6 then
			CameraObject(M.NexusTube, M.Position11, M.NexusAttacker);
			if M.CameraEndTime < GetTime() then
				CameraFinish();
				M.Routine2State = M.Routine2State + 1;
			end
		elseif M.Routine2State == 7 then	--LOC_194
			if M.Variable3 == 25.1 then
				AudioMessage("edflast_12.wav");	--Rubikov:"We've discovered a massive repair field at the Tartarus base..."
				M.Routine2State = M.Routine2State + 1;
				M.Routine2Timer = GetTime() + 1;
			end
		elseif M.Routine2State == 8 then
			CameraReady();
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 9 then
			if CameraPath("UFOCamPath", 3800, 3500, M.Nexus) or CameraCancelled() then
				CameraFinish();
				M.Routine2Active = false; --RunSpeed,_Routine2,0,true
				M.Routine2State = M.Routine2State + 1;
			end
		elseif M.Routine2State == 10 then	--LOC_200
			M.Routine16State = 3;--SetStep,_Routine16,LOC_779
			M.Routine16Active = true;--RunSpeed,_Routine16,1,true
			CameraReady();
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 11 then
			if CameraPath("CrashCam", 15000, 1200, M.Nexus) or CameraCancelled() then
				CameraFinish();
				M.Routine2State = M.Routine2State + 1;
			end
		elseif M.Routine2State == 12 then
			if IsAround(M.HadeanRecy) then
				M.Nexus = ReplaceObject(M.Nexus, "ebnexus01");
				SetTeamNum(M.Nexus, 0);
				ClearObjectives();
				AddObjective(_Text1, "white");
			end
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 13 then	--LOC_210
			SetCurHealth(M.Nexus, 4000);
			--stays in LOC_210
		elseif M.Routine2State == 14 then	--LOC_212
			M.Position19 = GetPosition(M.Player);
			SetPosition(M.Player, "SafePlayer");
			CameraReady();
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 15 then
			if CameraPath("FinalCam", 15000, 800, M.Nexus) then
				CameraFinish();
				M.Routine2State = M.Routine2State + 1;
			end
		end
	end
end

--Spawns the Nexus and Tartarus IV buildings, moves the Nexus around
function Routine5()
	if M.Routine5Active and M.Routine5Timer < GetTime() then
		if M.Routine5State == 0 then
			M.Position1 = GetPosition(M.NexusHangar);
			M.Position1.y = M.Position1.y - 60;--100
			M.Nexus = BuildObject("ebnexus01", 5, BuildDirectionalMatrix(M.Position1));
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 1200;
		elseif M.Routine5State == 1 then
			ClearObjectives();
			AddObjective(_Text7, "white");
			StartCockpitTimer(240);
			AudioMessage("edflast_06.wav");	--Rubikov:"We're reading microtremors..."
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 2 then	--LOC_347
			if M.HardinNagCount == 0 and  GetCockpitTimer() < 160 then
				AudioMessage("edflast_06a.wav");	--Hardin:"Get your butt over to that nav beacon quickly..."
				M.HardinNagCount = M.HardinNagCount + 1;
			elseif M.HardinNagCount == 1 and  GetCockpitTimer() < 80 then
				AudioMessage("edflast_06b.wav");	--Hardin:"Get moving now!"
				M.HardinNagCount = M.HardinNagCount + 1;
			elseif M.HardinNagCount == 2 and  GetCockpitTimer() <= 1 then
				AudioMessage("edflast_13.wav");	--Hardin:"You were ordered to investigate the area..."
				ClearObjectives();
				AddObjective(_Text7, "red");
				FailMission(GetTime() + 15, "EDFLastL1.txt");
				M.HardinNagCount = M.HardinNagCount + 1;
				M.Routine5State = 99;
			elseif GetDistance(M.Player, M.Nexus) < 240 then
				HideCockpitTimer();
				M.Routine10Active = true;--RunSpeed,_Routine10,1,true
				ClearObjectives();
				AddObjective(_Text6, "white");
				AudioMessage("edflast_07.wav");	--Rubikov:"We're recording your video feed..."			
				M.Routine5State = M.Routine5State + 1;
				M.Routine5Timer = GetTime() + 20;
			end
		elseif M.Routine5State == 3 then
			AudioMessage("edflast_08.wav");		--Hardin:"Keep an eye on that strange platform..."		
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 20;
		elseif M.Routine5State == 4 then
			StartEarthQuake(40.0);
			AudioMessage("xemt2.wav");
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 3;
		elseif M.Routine5State == 5 then
			UpdateEarthQuake(10.0);
			M.Position1.y = 0;--TerrainFindFloor(M.Position1) - 70;
			M.Position4 = M.Position1 + SetVector(0,-160,-160);
			M.Routine6Active = true;--RunSpeed,_Routine6,1,true
			local pos = BuildDirectionalMatrix(M.Position4, SetVector(-1,0,0));
			M.TartarusBldg1 = BuildObject("tartow01", 5, pos);
			SetObjectiveOn(M.TartarusBldg1);
			M.Position4.y = M.Position4.y + 230;--330
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 6 then
			if Move(M.TartarusBldg1, 0, M.Variable6, M.Position4) then
				SetObjectiveName(M.TartarusBldg1, "Tartarus IV Bldg");
				SetObjectiveOff(M.TartarusBldg1);
				M.Routine5State = M.Routine5State + 1;
				M.Routine5Timer = GetTime() + 3;
			end
		elseif M.Routine5State == 7 then
			AudioMessage("xemt2.wav");
			UpdateEarthQuake(40.0);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 3;
		elseif M.Routine5State == 8 then
			UpdateEarthQuake(10.0);
			AudioMessage("edflast_09.wav");	--Rubikov:"Holy shit, are those buildings rising up from the ground?..."
			M.Position4 = M.Position1 + SetVector(-160,-160, 0);
			local pos = BuildDirectionalMatrix(M.Position4, SetVector(0, 0, 1));
			M.TartarusBldg1 = BuildObject("tartow01", 5, pos);
			SetObjectiveOn(M.TartarusBldg1);
			M.Position4.y = M.Position4.y + 230;--330
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 9 then
			if Move(M.TartarusBldg1, 0, M.Variable6, M.Position4) then
				SetObjectiveName(M.TartarusBldg1, "Tartarus IV Bldg");
				SetObjectiveOff(M.TartarusBldg1);
				UpdateEarthQuake(6.0);
				--RunSpeed,_Routine5,20,true
				--RemoveObject(M.Object3);
				M.Routine16Active = true;--RunSpeed,_Routine16,1,true
				M.Routine2Active = true;--RunSpeed,_Routine2,1,true
				M.Routine10Active = false;--RunSpeed,_Routine10,0,true
				AudioMessage("edflast_10.wav");	--Rubikov:"The tremors are spiking again..."
				M.Variable3 = 14.0;--7.0
				M.Routine5State = M.Routine5State + 1;
				M.Routine5Timer = GetTime() + 3;
			end
		elseif M.Routine5State == 10 then
			--Nexus emerging from hangar
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position1) then
				M.Position1.y = M.Position1.y + 125;
				M.Variable3 = 40.0;--16.0
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 11 then
			--Nexus rising up from hangar platform
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position1) then
				M.Position1 = GetPosition(M.Nexus);
				M.Nexus = ReplaceObject(M.Nexus, "evnexus01");
				SetObjectiveName(M.Nexus, "Nexus");
				SetObjectiveOn(M.Nexus);
				M.Position1.y = M.Position1.y + 70;
				M.Variable3 = 5.0;
				M.Routine5State = M.Routine5State + 1;
			end	
		elseif M.Routine5State == 12 then
			--Nexus rising up, now damageable
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position1) then
				AudioMessage("nexus1.wav");
				M.Position1 = GetPosition(M.Nexus);
				M.Position1.y = M.Position1.y + 135;
				M.Variable3 = 25.0;
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 13 then
			--Nexus floating up even more
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position1) then
				M.Position2 = GetPosition(M.Nexus);
				M.Position2 = M.Position2 + SetVector(0, 30, 90);
				StopEarthQuake();
				M.Variable9 = 0;
				M.Routine10Active = false;--RunSpeed,_Routine10,0,true
				M.Routine7Active = true;--RunSpeed,_Routine7,3,true
				M.Variable26 = GetCurHealth(M.Nexus);
				M.Routine8Active = true;--RunSpeed,_Routine8,3,true
				M.Routine11Active = true;--RunSpeed,_Routine11,1,true
				ClearObjectives();
				AddObjective(_Text9, "white");
				M.Variable3 = 20.0;
				RemoveObject(M.HadeanActivityNav);
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 14 then	--LOC_452
			if M.Variable18 ~= 1 then
				M.Position1 = SetVector(-1360, 0, 110);
				M.Variable18 = 1;
			else
				M.Position1 = SetVector(940, 0, 840);
				M.Variable18 = 0;
			end
			M.Position2 = M.Position1;
			M.Position2.y = TerrainFindFloor(M.Position2) + 34;
			M.Position1.y = TerrainFindFloor(M.Position1) + 220;--290
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 15 then
			--Moving from Nexus Hangar to Mining Position
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position1) then
				AddHealth(M.Nexus, 4000);
				M.Position1.y = M.Position1.y - 185;
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 16 then
			--Moving down to mining position
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position1) then
				M.NexusBolt = BuildObject("nexusbolt", 5, M.Position2);
				M.Position2 = M.Position2 + SetVector(16, -44, -16);
				M.NexusTube = BuildObject("nexustube", 5, M.Position2);
				M.NexusMoveTime = GetTime() + 32000; --M.Variable3 = 32000;
				M.Variable9 = 1;
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 17 then
			Move(M.Nexus, M.Variable2, M.NexusMoveTime);	--Rotating in place at mining position
			if M.NexusMoveTime < GetTime() then
				RemoveObject(M.NexusTube);
				RemoveObject(M.NexusBolt);
				M.Variable9 = 3;
				M.Variable3 = 15.0;
				M.Position1.y = M.Position1.y + 110;--210
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 18 then
			--Moving up from mining position
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position1) then
				M.Position1 = SetVector(-25, 350, 150);
				M.Variable3 = 25.0;
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 19 then
			--Moving to Nexus Hangar
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position1) then
				M.Variable3 = 25.1;
				M.Position1.y = M.Position1.y - 280;--165
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 20 then
			--Moving down into Repair position
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position1) then
				M.Variable9 = 2;
				M.NexusMoveTime = GetTime() + 32000;--M.Variable3 = 32000;
				M.Position2 = M.Position1;
				M.Position2.y = TerrainFindFloor(M.Position2) + 34;
				M.NexusBolt = BuildObject("nexusbolt", 5, M.Position2);
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 21 then
			Move(M.Nexus, M.Variable2, M.NexusMoveTime);	--Rotating in place at repair position
			if M.NexusMoveTime < GetTime() then
				RemoveObject(M.NexusBolt);
				M.Variable3 = 15.0;
				M.Variable9 = 0;
				M.Position1.y = M.Position1.y + 65;--165
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 22 then
			--Moving up from repair position
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position1) then
				AddHealth(M.Nexus, 4000);
				M.Routine5State = 14;--to LOC_452
			end
		end
	end
end

--Spawns 2 of the Tartarus IV buildings by the nexus
function Routine6()
	if M.Routine6Active and M.Routine6Timer < GetTime() then
		if M.Routine6State == 0 then
			M.Position5 = M.Position1 + SetVector(0, -160, 160);
			local pos = BuildDirectionalMatrix(M.Position5, SetVector(1,0,0));
			M.TartarusBldg2 = BuildObject("tartow01", 5, pos);
			SetObjectiveOn(M.TartarusBldg2);
			M.Position5.y = M.Position5.y + 230;--330
			M.Routine6State = M.Routine6State + 1;
		elseif M.Routine6State == 1 then
			if Move(M.TartarusBldg2, 0, M.Variable6, M.Position5) then
				SetObjectiveName(M.TartarusBldg2, "Tartarus IV Bldg");
				SetObjectiveOff(M.TartarusBldg2);
				M.Routine6State = M.Routine6State + 1;
				M.Routine6Timer = GetTime() + 6;
			end
		elseif M.Routine6State == 2 then
			M.Position5 = M.Position1 + SetVector(160, -160, 0);
			local pos = BuildDirectionalMatrix(M.Position5, SetVector(0,0,-1));
			M.TartarusBldg2 = BuildObject("tartow01", 5, pos);
			SetObjectiveOn(M.TartarusBldg2);
			M.Position5.y = M.Position5.y + 230;--330
			M.Routine6State = M.Routine6State + 1;
		elseif M.Routine6State == 3 then
			if Move(M.TartarusBldg2, 0, M.Variable6, M.Position5) then
				SetObjectiveName(M.TartarusBldg2, "Tartarus IV Bldg");
				SetObjectiveOff(M.TartarusBldg2);
				M.Routine6Active = false;
				M.Routine6State = M.Routine6State + 1;
			end
		end
	end
end

--spawns furies, claws, and tyrants that harass the player's forces
function Routine7()
	if M.Routine7Active and M.Routine7Timer < GetTime() then
		if M.Routine7State == 0 then
			M.Routine7State = M.Routine7State + 1;
		elseif M.Routine7State == 1 then	--LOC_529
			if not IsAround(M.Nexus) then
				M.Routine7State = 99;
			elseif M.Variable9 == 1 then
				M.Routine7State = M.Routine7State + 1;
			elseif M.Variable9 == 2 then
				M.Routine7State = 6;--to LOC_584
			end
		elseif M.Routine7State == 2 then	--LOC_535
			if GetCurHealth(M.Nexus) < 22000 then
				M.NexusMoveTime = 0;--M.Variable3 = 0;
				M.Routine7State = 1;--to LOC_529
			else
				M.Routine7State = M.Routine7State + 1;
			end
		elseif M.Routine7State == 3 then	--LOC_540
			if GetTime() < M.Variable10 then
				M.Routine7State = 1;--to LOC_529
			else
				M.Routine7State = M.Routine7State + 1;
				M.Routine7Timer = GetTime() + 4;
			end
		elseif M.Routine7State == 4 then
			if M.Variable18 == 0 then
				M.Position2 = GetPosition(M.Nexus) + SetVector(-70,30,0);
			else
				M.Position2 = GetPosition(M.Nexus) + SetVector(45,30,60);
			end
			if M.Variable28 <= 2 then
				M.NexusAttacker = BuildObject("fvfurytk", 5, M.Position2);
				M.Variable28 = M.Variable28 + 1;
			else
				M.Variable28 = 0;
				if M.Variable29 > 0 then
					M.NexusAttacker = BuildObject("cvtyrant", 5, M.Position2);
					M.Variable29 = 0;
				else
					M.NexusAttacker = BuildObject("cvclaw", 5, M.Position2);
					M.Variable29 = 1;
				end
			end
			M.Routine7State = M.Routine7State + 1;
		elseif M.Routine7State == 5 then	--LOC_562
			local h = GetNearestEnemy(M.Nexus);
			if h ~= M.Player and GetDistance(h, M.Nexus) < 220 then
				Attack(M.NexusAttacker, h, 0);
				M.Variable10 = GetTime() + 90;
				M.Routine7State = 1;--to LOC_529
			else
				if M.Variable16 == 0 then
					Attack(M.NexusAttacker, M.Recycler, 0);
				end
				if GetTime() < 2560 then
					M.Variable10 = GetTime() + 190;
				else
					M.Variable10 = GetTime() + 155;
				end
				M.Variable10 = M.Variable10 + math.min(M.Variable16 * -5, -70);
			end
			M.Routine7State = 1;--to LOC_529
		elseif M.Routine7State == 6 then	--LOC_584
			--this heals the nexus while it is in the repair state above the hangar. heals around 640 hp/s
			if GetCurHealth(M.Nexus) < M.Variable11 then
				local addHealth = math.max((GetCurHealth(M.Nexus) - 14000) / 25.0, 0);
				AddHealth(M.Nexus, addHealth);
				M.Routine7Timer = GetTime() + 0.5;
			else
				M.NexusMoveTime = 0;--M.Variable3 = 0;
				M.Routine7Timer = GetTime() + 2;
			end
			M.Routine7State = 1;--to LOC_529
		end
	end
end

--Handles the Nexus crash sequence
function Routine8()
	if M.Routine8Active and M.Routine8Timer < GetTime() then
		if M.Routine8State == 0 then
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 1 then	--LOC_597
			local nexusHealth = GetCurHealth(M.Nexus);
			if not IsAround(M.Nexus) or nexusHealth < 5000 then
				M.Routine8State = M.Routine8State + 1;--to LOC_625
			elseif nexusHealth < M.Variable12 then
				local h = GetNearestEnemy(M.Nexus);	--LOC_606
				if (GetDistance(M.Nexus, h) < 300 or M.Variable9 > 1) then
					if M.Variable15 == 0 then	--LOC_619
						SetAIP("edflast1.aip", 5);
						M.Variable15 = 1;
						Routine15();--RunSpeed,_Routine15,100,true
					end
				elseif M.Variable15 == 1 then
					SetAIP("edflast0.aip", 5);
					M.Variable15 = 0;
					Routine14();--RunSpeed,_Routine14,100,true
				end
			elseif M.Variable15 == 1 then
				M.Variable15 = 0;
				SetAIP("edflast0.aip", 5);
				Routine14();--RunSpeed,_Routine14,100,true
			end
		elseif M.Routine8State == 2 then	--LOC_625
			--M.Routine8Active = true; --RunSpeed,_Routine8,20,true
			M.Routine5Active = false;--RunSpeed,_Routine5,0,true
			RemoveObject(M.Nexus);
			RemoveObject(M.NexusTube);
			RemoveObject(M.NexusBolt);
			M.Position15.y = M.Position15.y - 100;	--y pos is offset by 100m for some reason...
			M.Position16.y = M.Position16.y - 100;	--y pos is offset by 100m for some reason...
			M.Position17.y = M.Position17.y - 100;	--y pos is offset by 100m for some reason...
			M.Nexus = BuildObject("ebnexus01", 0, M.Position15);
			AudioMessage("edflast_15.wav");	--Rubikov:"The Nexus is losing power..."
			M.Variable3 = 17.0;
			M.Routine2State = 10;--SetStep,_Routine2,LOC_200
			M.Routine2Active = true;--RunSpeed,_Routine2,1,true
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 3 then
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position16) then
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 4 then
			if Move(M.Nexus, M.Variable2, M.Variable3, M.Position17) then
				AudioMessage("xemt2.wav");
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 5 then
			if IsAround(M.HadeanRecy) then
				AudioMessage("edflast_15a.wav");	--Hardin:"It's not over yet..."
				Routine14();--RunSpeed,_Routine14,100,true
				M.Variable15 = 0;
				SetAIP("edflast0.aip", 5);
				M.Routine8State = M.Routine8State + 1;
			else
				M.Routine8State = M.Routine8State + 2;
				M.Routine8Timer = GetTime() + 2;
			end	
		elseif M.Routine8State == 6 then	--LOC_644
			if not IsAround(M.HadeanRecy) then
				ClearObjectives();
				AddObjective(_Text1, "green");
				M.Routine8State = M.Routine8State + 1;
				M.Routine8Timer = GetTime() + 2;
			end
		elseif M.Routine8State == 7 then	--LOC_648
			AudioMessage("edflast_15b.wav");	--Hardin:"Excellent job. The Hadeans are packing up..."
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 10;
		elseif M.Routine8State == 8 then
			Ally(1, 5);
			M.Routine2State = 14;--SetStep,_Routine2,LOC_212
			M.Routine2Active = true;--RunSpeed,_Routine2,1,true
			AudioMessage("edflast_16.wav");	--Corber:"Our force helped save humanity..."
			SucceedMission(GetTime() + 44, "EDFLastW1.txt");
			M.Routine8State = M.Routine8State + 1;
		end
	end
end

--nags the player to stay within range of the nexus hangar 
--while the player is investigating Hadean Activity
function Routine10()
	if M.Routine10Active and M.Routine10Timer < GetTime() then
		if M.Routine10State == 0 then	--LOC_665
			if GetDistance(M.Player, M.Nexus) > 295 then
				ClearObjectives();
				AddObjective(_Text8, "white");
				AudioMessage("edflast_8a.wav");	--Hardin:"Get back to the nav beacon..."
				M.Variable19 = GetTime() + 35;
				M.Routine10State = M.Routine10State + 1;
				M.Routine10Timer = GetTime() + 1;
			end
		elseif M.Routine10State == 1 then
			if GetDistance(M.Nexus, M.Player) < 275 then
				M.Routine10State = 0;--to LOC_665
				M.Routine10Timer = GetTime() + 1;
			elseif M.Variable19 < GetTime() then
				ClearObjectives();
				AddObjective(_Text8, "red");
				AudioMessage("edflast_13.wav");	--Hardin:"You were ordered to investigate the nav beacon..."
				FailMission(GetTime() + 15, "EDFLastL3.txt");
				M.Routine10State = M.Routine10State + 1;
			end
		end
	end
end

--sends any idle units spawned by Nexus after player recy
function Routine11()
	if M.Routine11Active and M.Routine11Timer < GetTime() then
		if M.Routine11State == 0 then	--LOC_682
			M.HadeanTurret8 = GetNearestVehicle(M.Nexus);
			if (GetCfg(M.HadeanTurret8) == "cvtyrant"
			or GetCfg(M.HadeanTurret8) == "cvclaw"
			or GetCfg(M.HadeanTurret8) == "fvfurytk")
			and GetDistance(M.HadeanTurret8, M.Nexus) < 200 then
				if GetCfg(M.HadeanTurret8) == "fvfurytk" then
					M.Variable20 = GetTime() + 15;
				else
					M.Variable20 = GetTime() + 25;
				end
				M.Routine11State = M.Routine11State + 1;
			end
		elseif M.Routine11State == 1 then
			if not IsAround(M.HadeanTurret8) or GetDistance(M.HadeanTurret8, M.Nexus) > 200 then
				M.Routine11State = 0;
			elseif M.Variable20 < GetTime() then
				--Stop(M.HadeanTurret8, 0);
				if GetTarget(M.HadeanTurret8) == nil then
					Goto(M.HadeanTurret8, M.Recycler, 0);
				end
				M.Routine11State = 0;--to LOC_682
			end
		end
	end
end

--code that tells hadean service trucks to service gtows if damaged.
--probably redundant with new 1.3 AI
--function Routine12()
--
--end

--tells NewPatroller to patrol around the nexus
function Routine13()
	if GetCfg(M.NewPatroller) == "evatanku" then
		Patrol(M.NewPatroller, "TarPatrol2", 0);
	else
		Patrol(M.NewPatroller, "TarPatrol1", 0);
	end
end

--tells Hadean attackers to stop
function Routine14()
	for i=1,8 do
		if IsAround(M.HadeanPatrols[i]) then
			Stop(M.HadeanPatrols[i], 0);
		end
	end
end

--tells Hadean attackers to patrol around the nexus
function Routine15()
	for i=1,8 do
		if IsAround(M.HadeanPatrols[i]) then
			Patrol(M.HadeanPatrols[i], "TarPatrol1", 0);
		end
	end
end

--moves player to a safe place during cutscenes
function Routine16()
	if M.Routine16Active and M.Routine16Timer < GetTime() then
		if M.Routine16State == 0 then
			SetPosition(M.Player, GetPosition("SafePlayer"));
			M.Routine16State = M.Routine16State + 1;
			M.Routine16Timer = GetTime() + 17;
		elseif M.Routine16State == 1 then
			SetPerceivedTeam(M.Player, 5);
			SetPosition(M.Player, GetPosition("PutPlayer1"));
			M.Routine16State = M.Routine16State + 1;
			M.Routine16Timer = GetTime() + 14;
		elseif M.Routine16State == 2 then
			SetPerceivedTeam(M.Player, 1);
			M.Routine16Active = false;--RunSpeed,_Routine16,0,true
			M.Routine16State = M.Routine16State + 1;
		elseif M.Routine16State == 3 then	--LOC_779
			M.Position19 = GetPosition(M.Player);
			SetPosition(M.Player, GetPosition("SafePlayer"));
			M.Routine16State = M.Routine16State + 1;
			M.Routine16Timer = GetTime() + 6;
		elseif M.Routine16State == 4 then
			SetPosition(M.Player, M.Position19);
			M.Routine16State = M.Routine16State + 1;
		end
	end
end

--makes Scout 1 and Scout 2 invincible until the scrap pool and Hadean base cutscenes are finished.
function Routine17()
	if M.Routine17Active then
		SetCurHealth(M.Scout1, math.max(GetCurHealth(M.Scout1), 900));
		SetCurHealth(M.Scout2, math.max(GetCurHealth(M.Scout2), 900));
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if not IsAround(M.Recycler) then
			ClearObjectives();
			AddObjective(_Text10, "red");
			AudioMessage("edflast_14.wav");	--Hardin:"You've just lost the only Recycler on the entire planet..."
			FailMission(GetTime() + 18, "EDFLastL2.txt");
			M.MissionOver = true;
		end
	end
end
