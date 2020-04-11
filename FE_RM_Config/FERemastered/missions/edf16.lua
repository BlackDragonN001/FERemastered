assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

local Position10 = BuildDirectionalMatrix(SetVector(-1000,0,-92));	--Rebel dropship landing site (matrix)
local Position11 = BuildDirectionalMatrix(SetVector(-1000,0,165));	--Loyalist dropship landing site (matrix)
local Position15 = SetVector(-1000,1000,0);	--Dropship exit target (off map)
local Position16 = SetVector(0,100,100);	--Camera offset in final cutscene
local Position23 = SetVector(0,0,3);	--Camera offset in final cutscene

local EvacuateBlacklist = { --Anything not on this list will be evacuated.
	["ivturr.odf"]=true, 
	["ivcons.odf"]=true, 
	["ivserv.odf"]=true, 
	["ivhack.odf"]=true,
	["ibgtow.odf"]=true,
	["ivrecy.odf"]=true
};

local M = {
-- Bools
	MissionOver = false,
	Routine2Active = false,
	Routine4Active = false,
	Routine5Active = false,
	Routine7Active = false,
	Routine8Active = false,
	Routine9Active = false,
	Routine10Active = false,
	Routine12Active = false,
	CheckRebelTech = false,
	CheckHackerScout = true,
	DownloadFinished = false,
	
-- Floats
	Routine1Timer = 0.0,
	Routine2Timer = 0.0,
	Routine4Timer = 0.0,
	Routine5Timer = 0.0,
	Routine6Timer = 0.0,
	Routine7Timer = 0.0,
	Routine8Timer = 0.0,
	Routine9Timer = 0.0,
	Routine10Timer = 0.0,
	CameraEndTime = 0.0,
	AtlasRespawnTime = 0.0,

-- Handles
	Wingman = nil,	--Wingman
	EDFDropship = nil,	--EDF dropship
	Recycler = nil, --Recycler
	HadeanRecycler = nil,	--Hadean Recy
	HadeanFactory1 = nil,	--Hadean factory 1 (near Player base)
	HadeanFactory2 = nil, --Hadean factory 2 (at Hadean base)
	Player = nil, --Player
	HadeanBackupRecycler = nil, --Hadean backup Procreator
	WormholeGenerator = nil, --Wormhole Generator
	HadeanNav = nil, --Hadean nav
	RebelDropship = nil,	--Rebel dropship
	RebelTechOfficer = nil,	--Rebel tech officer
	RebelEscort = nil,	--Rebel escort
	HadeanLoyalistDropship = nil,	--Hadean loyalist dropship
	Loyalist1 = nil,	--Loyalist 1
	Loyalist2 = nil,	--Loyalist 2
	Loyalist3 = nil,	--Loyalist 3
	CheatExtractor1 = nil,	--cheat extractor
	CheatExtractor2 = nil,	--cheat extractor
	HadeanConstructor = nil,	--Hadean Constructor
	HadeanTIE1 = nil,	--Respawning Hadean TIE
	HadeanTIE2 = nil,	--Respawning Hadean TIE
	HadeanTIE3 = nil,	--Respawning Hadean TIE
	HadeanTIE4 = nil,	--Respawning Hadean TIE
	CerbLandingZoneNav = nil,	--"cerberi2" landing zone nav
	CerberiDropship = nil,	--Cerb dropship
	CerberiAttacker = nil,	--Cerb attacker
	EDFBaseNav = nil,	--EDF Base nav
	HadeanWalker = nil, --Hadean walker
	HadeanLandingZone = nil,	--Hadean "elite" forces landing zone
	PoolA = nil,	--Pool A
	PoolB = nil,	--Pool B
	HadeanEliteDropship = nil,	--Elite Hadean forces dropship
	RebelLandingSiteNav = nil,	--"Rebel Landing Site" nav
	PlayerServiceBay = nil,	--player Sbay
	HadeanAtlas = nil,	--Hadean atlas
	EDFBomber = nil, --EDF Bomber
	DummyObject1 = nil,	--dummy object for final cutscene
	DummyObject2 = nil, --dummy object for final cutscene
	HackerScout = nil,	--added separate variable for this, since player can hop out of it.
	EvacuateUnits = {},	--list of all player units that will be evacuated after Hadean download is finished

-- Ints
	TPS = 10,
	Routine1State = 0,
	Routine2State = 0,
	Routine4State = 0,
	Routine5State = 0,
	Routine6State = 0,
	Routine7State = 0,
	Routine8State = 0,
	Routine9State = 0,
	Variable2 = 60,	--dropship move speed
	Variable3 = 0,	--(boolean) wormhole timer is at 2 min left
	Variable6 = 0,	--Hadean Tech upload percentage

--Vectors
	Position7 = nil,	--Hadean reinforcements spawn ("hadeannav")
	Position18 = nil,	--next landing site for Cerb dropship (matrix)
	Position19 = nil,	--spawn loc for Cerb forces exiting dropship (matrix)
	CerbLandingPos = {},	--landing sites for cerb dropships (matrix array)
	CerbLandingSpawn = {},	--landing sites for cerb dropships (matrix array)
	Position21 = nil,	--Hadean elite forces landing zone (matrix)

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
	--Preloading reduces lag spikes when resources are used for the first time
	local preloadOdf = {
		"ivrecy",
		"cvtank",
		"cvrbomb",
		"evsky",
		"evartl2",
		"evdroptf",
		"evdrop_L2",
		"ivdrop2_ld",
		"dummy2"
	}
	local preloadAudio = {
		"edf16_01.wav",
		"edf16_02.wav",
		"edf16_03.wav",
		"edf16_04.wav",
		"edf16_04b.wav",
		"edf16_05.wav",
		"edf16_06.wav",
		"edf16_07.wav",
		"edf16_08.wav",
		"edf16_09.wav",
		"edf16_10.wav",
		"edf16_11.wav",
		"edf16_12.wav",
		"edf16_13.wav",
		"edf16_14.wav",
		"edf16_15.wav",
		"edf16_16.wav",
	};
	for k,v in pairs(preloadOdf) do
		PreloadODF(v);
	end
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Start()

	_FECore.Start();

	Ally(1, 6);
	Ally(2, 3);
	Ally(3, 4);
	Ally(2, 4);
	Ally(5, 2);
	Ally(5, 3);
	Ally(2, 7);
	Ally(3, 7);
	Ally(4, 7);
	Ally(5, 7);
	UnAlly(1, 3);
	UnAlly(1, 5);
	UnAlly(1, 4);
	UnAlly(1, 7);
	UnAlly(6, 4);
	UnAlly(6, 7);
	SetTeamColor(6, 0, 50, 50);
	SetTeamColor(4, 70, 0, 0);
	M.Player = GetPlayerHandle();
	M.HackerScout = M.Player;
	SetObjectiveName(M.Player, "Hacker Scout");
	M.Wingman = GetHandleOrDie("Wingman");
	SetObjectiveName(M.Wingman, "Wingman");
	Patrol(M.Wingman, "bio_patrol", 1);
	M.Recycler = GetHandleOrDie("Recycler");
	M.EDFBaseNav = GetHandleOrDie("edfbase");
	SetObjectiveOn(M.EDFBaseNav);
	SetScrap(1, 40);
	M.HadeanRecycler = GetHandleOrDie("ebrecy");
	M.Position7 = GetPosition(M.HadeanRecycler);
	M.HadeanFactory2 = GetHandleOrDie("unnamed_ebfact");
	M.Position8 = GetPosition(M.HadeanFactory2);
	M.HadeanFactory1 = GetHandleOrDie("ebfact");
	M.HadeanBackupRecycler = GetHandleOrDie("recy2");
	M.WormholeGenerator = GetHandleOrDie("wormgen");
	M.CerbLandingZoneNav = GetHandleOrDie("cerberi2");
	M.HadeanLandingZone = GetHandleOrDie("elite");
	M.Position21 = BuildDirectionalMatrix(GetPosition(M.HadeanLandingZone), SetVector(0,0,-1)); 
	local cerb1 = GetHandleOrDie("cerberi1");
	local cerb2 = GetHandleOrDie("cerberi2");
	local cerb3 = GetHandleOrDie("cerberi3");
	M.CerbLandingPos[1] = BuildDirectionalMatrix(GetPosition(cerb1), SetVector(0,0,1));
	M.CerbLandingPos[2] = BuildDirectionalMatrix(GetPosition(cerb2), SetVector(-1,0,0));
	M.CerbLandingPos[3] = BuildDirectionalMatrix(GetPosition(cerb3), SetVector(-1,0,0));
	M.CerbLandingSpawn[1] = BuildDirectionalMatrix(GetPosition(cerb1)+SetVector(0,10,10), SetVector(0,0,1));
	M.CerbLandingSpawn[2] = BuildDirectionalMatrix(GetPosition(cerb2)+SetVector(-10,10,0), SetVector(-1,0,0));
	M.CerbLandingSpawn[3] = BuildDirectionalMatrix(GetPosition(cerb3)+SetVector(-10,10,0), SetVector(-1,0,0));
	SetObjectiveOn(M.WormholeGenerator);

	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)

	_FECore.AddObject(h);

	if GetOdf(h) == "ibsbay.odf" then
		M.PlayerServiceBay = h;
		SetObjectiveName(M.PlayerServiceBay, "Service Bay");
		SetObjectiveOn(M.PlayerServiceBay);
	elseif GetOdf(h) == "espilo.odf" and GetTeamNum(h) == 7 then
		SetTeamNum(h, 3);
	end
	
	if GetTeamNum(h) == 1
	   and IsCraftButNotPerson(h)
	   and IsAlive(h) 
	   and not EvacuateBlacklist[GetOdf(h)] then
		table.insert(M.EvacuateUnits, h);
	end
end

function DeleteObject(h)

	_FECore.DeleteObject(h);
	
	for i=1,#M.EvacuateUnits do
		if M.EvacuateUnits[i] == h then
			table.remove(M.EvacuateUnits, i);
			break;
		end
	end
end

function PreGetIn(world, pilot, craft)
	if GetTeamNum(craft) == 1
	   and IsCraftButNotPerson(craft)
	   and not EvacuateBlacklist[GetOdf(craft)] 
	   and not IsPlayer(pilot) then
		print("insert "..tostring(craft));
		table.insert(M.EvacuateUnits, craft);
	end
end

function Update()

	_FECore.Update();

	M.Player = GetPlayerHandle();
	Routine1();
	Routine2();
	Routine4();
	Routine5();
	Routine6();
	Routine7();
	Routine8();
	Routine9();
	Routine10();
	Routine12();
	CheckStuffIsAlive();
end

--main mission state.
function Routine1()
	if M.Routine1Timer < GetTime() then
		if M.Routine1State == 0 then
			AudioMessage("edf16_01.wav");	--Eisenstein:"Our forward scouts have located the Wormhole Control center..."
			AddObjective("edf1601.otf", "white");
			M.HadeanNav = BuildObject("ibnav", 2, M.Position7);
			SetObjectiveName(M.HadeanNav, "hadeannav");
			M.Routine5Active = true;--RunSpeed,_Routine5,1,false
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 1 then	--LOC_39
			if GetTime() > 200 or GetOdf(M.Recycler) == "ibrecy.odf" then
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 2 then	--LOC_43
			SetObjectiveOff(M.EDFBaseNav);
			AudioMessage("edf16_02.wav");	--Hardin:"We estimate that the main body of the Hadean fleet is about 15 min from the wormhole jump point..."
			ClearObjectives();
			AddObjective("edf1602.otf", "white");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 3 then
			StartCockpitTimer(900);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 4 then	--LOC_49
			AddHealth(M.HadeanRecycler, 500);
			if M.Variable3 == 0 and GetCockpitTimer() < 120 then
				AudioMessage("edf16_03.wav");	--EDF Officer:"The Hadean fleet has assembled at the jump point..."
				ClearObjectives();
				AddObjective("edf1603.otf", "white");
				StartEarthQuake(1.0);
				M.Variable3 = 1;
			elseif GetCockpitTimer() <= 1 then
				UpdateEarthQuake(3.0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 2;
			end
		elseif M.Routine1State == 5 then
			UpdateEarthQuake(10.0);
			AudioMessage("edf16_04.wav");	--EDF Officer:"The wormhole has been activated..."
			ClearObjectives();
			AddObjective("edf1604.otf", "red");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 6 then
			UpdateEarthQuake(3.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 7 then
			StopEarthQuake();
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 35;
		elseif M.Routine1State == 8 then
			AudioMessage("edf16_04b.wav");	--Hardin:"It's time for us to try plan B..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 9 then
			ClearObjectives();
			AddObjective("edf1605.otf", "white");
			HideCockpitTimer();
			SetAIP("edf16_team2.aip", 2);
			M.Routine12Active = true;--RunSpeed,_Routine12,1,false
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 10 then	--LOC_79
			if not IsAround(M.HadeanRecycler) then
				SetTeamNum(M.WormholeGenerator, 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 6;
			end
		elseif M.Routine1State == 11 then	--LOC_83
			if IsInfo("wormgen3") then
				if M.Player == M.HackerScout then
					ClearObjectives();
					IFace_Exec("wormgen.cfg");
					M.Routine1State = M.Routine1State + 1;
					M.Routine1Timer = GetTime() + 2;
				else
					--Player used something other than the Hacker scout to login...
					ClearObjectives();
					AddObjective("edf1610.otf", "green");
					AddObjective("edf1615.otf", "red");
					M.Routine1Timer = GetTime() + 4;
				end
			end
		elseif M.Routine1State == 12 then
			FreeCamera();
			IFace_SetInteger("mission.var4", 0);
			IFace_Activate("Win1");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 13 then
			IFace_Deactivate("Win1");
			IFace_Activate("Win2");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 14 then	--LOC_99
			local var4 = IFace_GetInteger("mission.var4");
			if var4 == 2 then
				FreeFinish();
				M.Routine1State = M.Routine1State + 2;--to LOC_111
				M.Routine1Timer = GetTime() + 10;
			elseif var4 > 0 then
				IFace_SetInteger("mission.var4", 0);
				if IFace_GetInteger("mission.pass") == 852 then
					if not M.DownloadFinished then
						M.Routine1State = M.Routine1State + 1;--to LOC_105
					else
						IFace_Activate("Win4");
						M.Routine1State = 17;--to LOC_119
					end
				else
					IFace_Activate("Win3");
					M.Routine1State = M.Routine1State + 1;
					M.Routine1Timer = GetTime() + 7;
				end
			end
		elseif M.Routine1State == 15 then	--LOC_105
			--player entered wrong password
			IFace_Deactivate("Win3");
			FreeFinish();
			ClearObjectives();
			AddObjective("edf1614.otf", "red");
			FailMission(GetTime() + 8, "nopass16.des");
			M.Routine1State = 99;
		elseif M.Routine1State == 16 then	--LOC_111
			if M.Variable5 == 1 then
				SetTeamNum(M.WormholeGenerator, 0);
			end
			M.Routine1State = 11;--to LOC_83
		elseif M.Routine1State == 17 then	--LOC_119
			local var4 = IFace_GetInteger("mission.var4");
			if var4 == 1 then	--"Activate"
				IFace_SetInteger("mission.var4", 0);
				FreeFinish();
				AudioMessage("edf16_09.wav");	--Hadean AI:"Wormhole activation sequence initiated..."	
				ClearObjectives();
				AddObjective("edf1612.otf", "white");
				M.WormholeGenerator = ReplaceObject(M.WormholeGenerator, "wormgen5");
				SetTeamNum(M.WormholeGenerator, 1);
				SetTeamNum(M.Recycler, 6);
				SetTeamNum(GetObjectByTeamSlot(1, 2), 6);
				SetTeamNum(GetObjectByTeamSlot(1, 3), 6);
				SetTeamNum(GetObjectByTeamSlot(1, 5), 6);
				StartCockpitTimer(600); -- Corrected to 10 minutes as per what is said by the audio message. - AI_Unit
				M.Routine9Active = true;--RunSpeed,_Routine9,1,false
				M.CheckHackerScout = false;--RunSpeed,_Routine3,0,false
				M.Routine1State = M.Routine1State + 1;
			elseif var4 == 2 then	--"Logout"
				FreeFinish();
				M.Routine1State = M.Routine1State - 1;--to LOC_111
			elseif var4 == 3 then	--"Shutdown"
				M.Routine1State = 15;--to LOC_105
			end
		elseif M.Routine1State == 18 then	--LOC_140
			if GetCockpitTimer() < 90 then
				AudioMessage("edf16_10.wav");	--Hardin:"I've sent the Condor down to pick you up..."
				ClearObjectives();
				AddObjective("edf1613.otf", "white");
				M.EDFDropship = BuildObject("ivdrop2_ld", 1, Position10);
				SetAnimation(M.EDFDropship, "land", 1);
				StartAnimation(M.EDFDropship);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 10;
			end
		elseif M.Routine1State == 19 then
			SetObjectiveOn(M.EDFDropship);
			SetAnimation(M.EDFDropship, "deploy", 1);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 20 then
			if GetDistance(M.Player, M.EDFDropship) < 10 then
				M.Routine1State = M.Routine1State + 1;
			elseif GetCockpitTimer() <= 1 then
				AudioMessage("edf16_11.wav");	--Condor Pilot:"Star ship Intrepid, this is Condor. Lifting off now..."
				M.Routine1State = 24;--to LOC_175
				M.Routine1Timer = GetTime() + 9;
			end
		elseif M.Routine1State == 21 then	--LOC_158
			SetTeamNum(M.EDFDropship, 6);
			M.Routine10Active = false;--RunSpeed,_Routine10,0,false --RunSpeed,_Routine11,0,false
			CameraReady();
			M.CameraEndTime = GetTime() + 7;
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 22 then
			CameraObject(M.WormholeGenerator, Position16, M.WormholeGenerator)
			if M.CameraEndTime < GetTime() then
				local viewstand = GetHandleOrDie("unnamed_viewstand");
				local pos = GetPosition(viewstand);
				M.DummyObject2 = BuildObject("dummy2",0, pos);
				pos.z = pos.z + 600;
				M.DummyObject1 = BuildObject("dummy2",0, pos);
				LookAt(M.DummyObject2, M.DummyObject1, 1);
				M.Routine2Active = true;--RunSpeed,_Routine2,1,false
				M.CameraEndTime = GetTime() + 3;
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 23 then
			if CameraObject(M.DummyObject2, Position23, M.DummyObject1) then
				--CameraFinish();	--camera stays in cutscene mode until mission ends
				M.Routine1State = 99;
			end
		elseif M.Routine1State == 24 then	--LOC_175
			AudioMessage("edf16_16.wav");	--Hardin:"I was very sorry to hear that you missed the Condor..."
			FailMission(GetTime() + 14, "misscondor.des");
			M.Routine1State = 99;
		end
	end
end

--succeeds the mission
function Routine2()
	if M.Routine2Active and M.Routine2Timer < GetTime() then
		if M.Routine2State == 0 then
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 1;
		elseif M.Routine2State == 1 then
			AudioMessage("edf16_11.wav");	--Condor Pilot:"Star ship Intrepid, this is Condor. Lifting off now..."
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 9;
		elseif M.Routine2State == 2 then
			AudioMessage("edf16_12.wav");	--Hardin:"Well done, Joe. Let's go home..."
			SucceedMission(GetTime() + 10, "win16.des");
			M.Routine2State = M.Routine2State + 1;
		end
	end
end

--spawns the rebel tech and loyalist hadeans that try to intercept them
--the rebel tech meets with player to do the download, then leaves via dropship
function Routine4()
	if M.Routine4Active and M.Routine4Timer < GetTime() then
		if M.Routine4State == 0 then 
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 10;
		elseif M.Routine4State == 1 then	--LOC_215
			M.HadeanFactory1 = GetObjectByTeamSlot(2, 2);
			M.HadeanFactory2 = GetObjectByTeamSlot(3, 2);
			if not IsAround(M.HadeanFactory1) and not IsAround(M.HadeanFactory2) 
			and not IsAround(M.HadeanRecycler) then
				AudioMessage("edf16_06.wav");	--Rebel Tech:"Our dropship is beginning its descent..."
				CalcCliffs(M.WormholeGenerator, nil, 400);	--fixes mysterious annoying pathing problems in Hadean base after some buildings are destroyed
				ClearObjectives();
				AddObjective("edf1607.otf", "white");
				M.RebelLandingSiteNav = BuildObject("ibnav", 1, Position10);
				SetObjectiveName(M.RebelLandingSiteNav, "Rebel Landing Site");
				SetObjectiveOn(M.RebelLandingSiteNav);
				M.Routine4State = M.Routine4State + 1;
				M.Routine4Timer = GetTime() + 30;				
			end
		elseif M.Routine4State == 2 then
			M.RebelDropship = BuildObject("evdrop_l2", 6, Position10);
			SetAnimation(M.RebelDropship, "land", 1);
			StartAnimation(M.RebelDropship);
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 20;
		elseif M.Routine4State == 3 then
			M.RebelDropship = ReplaceObject(M.RebelDropship, "evdroptf");
			M.RebelTechOfficer = BuildObject("evscout", 6, Position10);
			M.RebelEscort = BuildObject("evscout", 6, Position10);
			SetSkill(M.RebelTechOfficer, 3);
			SetSkill(M.RebelEscort, 3);
			SetObjectiveName(M.RebelTechOfficer, "Rebel Tech Officer");
			SetObjectiveOn(M.RebelTechOfficer);
			M.HadeanLoyalistDropship = BuildObject("evdrop_l2", 2, BuildDirectionalMatrix(Position11));
			SetAnimation(M.HadeanLoyalistDropship, "land", 1);
			StartAnimation(M.HadeanLoyalistDropship);
			SetAnimation(M.RebelDropship, "deploy", 1);
			StartAnimation(M.RebelDropship);
			Follow(M.RebelTechOfficer, M.Player, 1);
			Follow(M.RebelEscort, M.Player, 1);
			M.CheckRebelTech = true;
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 20;
		elseif M.Routine4State == 4 then
			M.HadeanLoyalistDropship = ReplaceObject(M.HadeanLoyalistDropship, "evdroptf");
			SetAnimation(M.HadeanLoyalistDropship, "deploy", 1);
			StartAnimation(M.HadeanLoyalistDropship);
			M.Loyalist1 = BuildObject("evscout", 2, Position11);
			M.Loyalist2 = BuildObject("evscout", 2, Position11);
			M.Loyalist3 = BuildObject("evscout", 2, Position11);
			Goto(M.Loyalist1, M.RebelTechOfficer, 1);
			Goto(M.Loyalist2, M.RebelTechOfficer, 1);
			Goto(M.Loyalist3, M.RebelTechOfficer, 1);
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 3;
		elseif M.Routine4State == 5 then
			Attack(M.Loyalist1, M.RebelTechOfficer, 1);
			Attack(M.Loyalist2, M.RebelTechOfficer, 1);
			Attack(M.Loyalist3, M.RebelTechOfficer, 1);
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 6 then	--LOC_257
			if GetDistance(M.RebelTechOfficer, M.Player) < 40 then
				LookAt(M.RebelTechOfficer, M.Player, 1);
				M.Variable6 = M.Variable6 + 4;
				ClearObjectives();
				AddObjective(string.format("edf1609.otf", M.Variable6), "white");
				if M.Variable6 >= 100 then
					M.Routine4State = M.Routine4State + 1;
				end
				M.Routine4Timer = GetTime() + 1;
			end	
		elseif M.Routine4State == 7 then
			LookAt(M.RebelTechOfficer, M.Player, 1);
			AudioMessage("edf16_07.wav");	--Rebel Tech:"The new encryption algorithm has been installed..."
			ClearObjectives();
			AddObjective("edf1610.otf", "green");
			SetObjectiveOff(M.RebelLandingSiteNav);			
			M.DownloadFinished = true;
			SetAnimation(M.HadeanLoyalistDropship, "takeoff", 1);
			StartAnimation(M.HadeanLoyalistDropship);
			M.Variable2 = 30.0;
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 8 then
			if Move(M.HadeanLoyalistDropship, 0, M.Variable2, Position15) then
				RemoveObject(M.HadeanLoyalistDropship);
				M.Routine4State = M.Routine4State + 1;
				M.Routine4Timer = GetTime() + 20;	--lowered time Hadean Tech spends waiting from 40s to 20s
			end
		elseif M.Routine4State == 9 then
			Goto(M.RebelTechOfficer, M.RebelLandingSiteNav, 1);
			Goto(M.RebelEscort, M.RebelLandingSiteNav, 1);
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 10 then
			if GetDistance(M.RebelTechOfficer, M.RebelLandingSiteNav) < 200 then
				M.Routine4State = M.Routine4State + 1;
				M.Routine4Timer = GetTime() + 2;
			end
		elseif M.Routine4State == 11 then
			if Move(M.RebelTechOfficer, 0, M.Variable2, Position10) then
				M.CheckRebelTech = false;
				RemoveObject(M.RebelTechOfficer);
				RemoveObject(M.RebelEscort);
				M.Routine10Active = true;--RunSpeed,_Routine10,1,false
				AudioMessage("edf16_08.wav");	--Hardin:"You'd better build plenty of automated defenses around the Wormhole Controller..."
				--ClearObjectives();	--want to keep the password in the objectives box!
				AddObjective("edf1611.otf", "white");
				SetAnimation(M.RebelDropship, "takeoff", 1);
				StartAnimation(M.RebelDropship);
				M.Routine4State = M.Routine4State + 1;
			end
		elseif M.Routine4State == 12 then
			if Move(M.RebelDropship, 0, M.Variable2, Position15) then
				RemoveObject(M.RebelDropship);
				M.Routine4State = M.Routine4State + 1;
			end
		end
	end
end

--spawns patrolling Hadean TIEs and a Creator that tries to rebuild their Factory near the Player base
--patrolling units switched to team 7 to prevent AIP from ordering them elsewhere
function Routine5()
	if M.Routine5Active and M.Routine5Timer < GetTime() then
		if M.Routine5State == 0 then
			SetAIP("edf163.aip", 3);	--Moved AIP call to start of mission
			M.CheatExtractor1 = ReplaceObject(GetHandle("cheat3"), "ebscup_16");
			M.CheatExtractor2 = ReplaceObject(GetHandle("cheat2"), "ebscup_16");
			SetScrap(3, 0);
			M.PoolA = GetHandle("mapoolA");
			M.PoolB = GetHandle("mapoolB");
			Goto(BuildObject("evscav", 3, GetPosition(M.HadeanFactory1)), M.PoolA, 1);
			Goto(BuildObject("evscav", 3, GetPosition(M.HadeanFactory1)), M.PoolB, 1);
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 1 then	--LOC_309
			local hasDeployedRecy = IsAround(M.HadeanRecycler) or (IsAround(M.HadeanBackupRecycler) and GetOdf(M.HadeanBackupRecycler) == "ebrecy_m.odf");
			local hasRecy = IsAround(M.HadeanRecycler) or IsAround(M.HadeanBackupRecycler);
			if not hasRecy then
				CalcCliffs(M.WormholeGenerator, nil, 400);	--fixes mysterious annoying pathing problems in Hadean base after some buildings are destroyed
				M.Routine5State = 99;
			elseif not hasDeployedRecy then
				--wait for Hadean team to deploy their backup Procreator
			elseif not IsAround(M.HadeanConstructor) and not IsAround(M.HadeanFactory1) then
				M.HadeanConstructor = BuildObject("evcons", 3, M.Position7);
				M.Routine5State = M.Routine5State + 1;
			elseif not IsAround(M.HadeanTIE1) then
				M.HadeanTIE1 = BuildObject("evsky", 7, M.Position7);
				Patrol(M.HadeanTIE1, "team3_path", 1);
			elseif not IsAround(M.HadeanTIE2) then
				M.HadeanTIE2 = BuildObject("evsky", 7, M.Position7);
				Patrol(M.HadeanTIE2, "team2_patrol", 1);
			elseif not IsAround(M.HadeanTIE3) then
				M.HadeanTIE3 = BuildObject("evsky", 7, M.Position7);
				Patrol(M.HadeanTIE3, "worm_patrol", 1);
			elseif not IsAround(M.HadeanTIE4) then
				M.HadeanTIE4 = BuildObject("evsky", 7, M.Position7);
				Patrol(M.HadeanTIE4, "team2_patrol", 1);
				--SetAIP("edf163.aip", 3);
			end
			M.Routine5Timer = GetTime() + 60;
		elseif M.Routine5State == 2 then
			if IsAround(M.HadeanRecycler) and IsAround(M.HadeanConstructor) then
				Defend2(BuildObject("evscout", 7, M.Position7), M.HadeanConstructor, 1);
				Defend2(BuildObject("evscout", 7, M.Position7), M.HadeanConstructor, 1);
			end
			M.Routine5State = 1;--to LOC_309
			M.Routine5Timer = GetTime() + 120;
		end
	end
end

--spawns Cerberi reinforcements via dropships
function Routine6()
	if M.Routine6Timer < GetTime() then
		if M.Routine6State == 0 then
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 1000;
		elseif M.Routine6State == 1 then
			SetAIP("cerberi.aip", 5);
			M.Routine6State = M.Routine6State + 1;
		elseif M.Routine6State == 2 then	--LOC_366
			local r = math.random(1,3);
			M.Position18 = M.CerbLandingPos[r];
			M.Position19 = M.CerbLandingSpawn[r];
			M.CerberiDropship = BuildObject("evdroptf", 5, M.Position18);
			SetAnimation(M.CerberiDropship, "land", 1);
			StartAnimation(M.CerberiDropship);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 18;
		elseif M.Routine6State == 3 then
			SetAnimation(M.CerberiDropship, "deploy", 1);
			StartAnimation(M.CerberiDropship);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 10;
		elseif M.Routine6State == 4 then
			M.CerberiAttacker = BuildObject("cvtank", 5, M.Position19);
			Goto(M.CerberiAttacker, M.Object3, 1);
			Follow(BuildObject("cvtank", 5, M.Position19), M.CerberiAttacker, 0);
			Follow(BuildObject("cvtank", 5, M.Position19), M.CerberiAttacker, 0);
			Follow(BuildObject("cvtank", 5, M.Position19), M.CerberiAttacker, 0);
			M.Variable2 = 30.0;
			SetAnimation(M.CerberiDropship, "takeoff", 1);
			StartAnimation(M.CerberiDropship);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 10;
		elseif M.Routine6State == 5 then
			if Move(M.CerberiDropship, 0, M.Variable2, Position15) then
				RemoveObject(M.CerberiDropship);
				M.Routine6State = M.Routine6State + 1;
				M.Routine6Timer = GetTime() + 420;
			end
		elseif M.Routine6State == 6 then
			if GetTime() < 4000 then
				M.Routine6State = 2;
			else
				SetAIP("cerberi2.aip", 5);
				M.Routine6State = M.Routine6State + 1;
				M.Routine6Timer = GetTime() + 18;
			end
		elseif M.Routine6State == 7 then	--LOC_384
			local r = math.random(1,3);
			M.Position18 = M.CerbLandingPos[r];
			M.Position19 = M.CerbLandingSpawn[r];
			M.CerberiDropship = BuildObject("evdroptf", 5, M.Position18);
			SetAnimation(M.CerberiDropship, "land", 1);
			StartAnimation(M.CerberiDropship);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 18;
		elseif M.Routine6State == 8 then
			SetAnimation(M.CerberiDropship, "deploy", 1);
			StartAnimation(M.CerberiDropship);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 10;
		elseif M.Routine6State == 9 then
			M.CerberiAttacker = BuildObject("cvrbomb", 5, M.Position19);
			Follow(BuildObject("cvtank", 5, M.Position19), M.CerberiAttacker, 1);
			Follow(BuildObject("cvtank", 5, M.Position19), M.CerberiAttacker, 1);
			Follow(BuildObject("cvtank", 5, M.Position19), M.CerberiAttacker, 1);
			Attack(M.CerberiAttacker, M.Recycler, 1);
			SetAnimation(M.CerberiDropship, "takeoff", 1);
			StartAnimation(M.CerberiDropship);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 10;
		elseif M.Routine6State == 10 then
			if Move(M.CerberiDropship, 0, M.Variable2, Position15) then
				RemoveObject(M.CerberiDropship);
				if M.DownloadFinished then
					M.Routine6State = M.Routine6State + 1;
				else
					M.Routine6State = 7;--to LOC_384
					M.Routine6Timer = GetTime() + 420;
				end
			end
		end
	end	
end

--spawns Atlas at Hadean base and deploys a backup Procreator if the main one is destroyed.
function Routine7()
	if M.Routine7Timer < GetTime() then
		if M.Routine7State == 0 then
			--M.HadeanLandingZone = GetHandleOrDie("elite");
			--M.Position21 = GetPosition(M.HadeanLandingZone);
			M.Routine7State = M.Routine7State + 1;
		elseif M.Routine7State == 1 then	--LOC_404
			if not IsAround(M.HadeanAtlas) and IsAround(M.HadeanRecycler) and M.AtlasRespawnTime < GetTime() then
				M.HadeanAtlas = BuildObject("evartl2", 7, M.Position7);
				M.AtlasRespawnTime = GetTime() + 90;
				--M.EDFBomber = GetHandle("unnamed_ivbomb");
				--Attack(M.HadeanAtlas, M.EDFBomber, 1);
			elseif not IsAround(M.HadeanRecycler) then
				SetTeamNum(M.WormholeGenerator, 0);
				if not IsAround(M.HadeanBackupRecycler) then
					M.Routine7State = 4;--to LOC_421
				else
					SetTeamNum(M.HadeanBackupRecycler, 2);
					Goto(M.HadeanBackupRecycler, "recyrun", 1);
					Follow(BuildObject("evtanku", 4, M.Position21), M.HadeanBackupRecycler, 0);
					M.Routine7State = M.Routine7State + 1;
				end
			end
		elseif M.Routine7State == 2 then
			if M.DownloadFinished then
				M.Routine8Active = true;--RunSpeed,_Routine8,1,false
				M.Routine7State = M.Routine7State + 1;
			end
		elseif M.Routine7State == 3 then
			if GetDistance(M.HadeanBackupRecycler, "ebrecy") < 150 then
				Dropoff(M.HadeanBackupRecycler, "ebrecy", 0);
				M.Routine7State = M.Routine7State + 1;
			end
		elseif M.Routine7State == 4 then	--LOC_421
			M.Routine8Active = true;--RunSpeed,_Routine8,1,false
			M.Routine7State = M.Routine7State + 1;
		end
	end
end

--spawns elite Hadean forces
function Routine8()
	if M.Routine8Active and M.Routine8Timer < GetTime() then
		if M.Routine8State == 0 then	--LOC_430
			local pos = GetPosition(M.HadeanLandingZone);
			pos.y = TerrainFindFloor(pos);
			M.Position21 = BuildDirectionalMatrix(pos, SetVector(0,0,-1));
			M.HadeanEliteDropship = BuildObject("evdroptf", 4, M.Position21);
			SetAnimation(M.HadeanEliteDropship, "land", 1);
			StartAnimation(M.HadeanEliteDropship);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 15;
		elseif M.Routine8State == 1 then
			SetAnimation(M.HadeanEliteDropship, "deploy", 1);
			StartAnimation(M.HadeanEliteDropship);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 10;
		elseif M.Routine8State == 2 then
			M.HadeanWalker = BuildObject("evwalk", 4, M.Position21);
			if IsAround(M.HadeanBackupRecycler) then
				Follow(BuildObject("evtanku", 4, M.Position21), M.HadeanBackupRecycler, 0);
				Follow(BuildObject("evtanku", 4, M.Position21), M.HadeanBackupRecycler, 0);
			end
			Follow(BuildObject("evtanku", 4, M.Position21), M.HadeanWalker, 0);
			Follow(BuildObject("evtanku", 4, M.Position21), M.HadeanWalker, 0);
			Goto(M.HadeanWalker, "endgame", 0);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 10;
		elseif M.Routine8State == 3 then
			SetAnimation(M.HadeanEliteDropship, "takeoff", 1);
			StartAnimation(M.HadeanEliteDropship);
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 4 then
			if Move(M.HadeanEliteDropship, 0, M.Variable2, Position15) then
				RemoveObject(M.HadeanEliteDropship);
				M.Routine8State = M.Routine8State + 1;
				M.Routine8Timer = GetTime() + 300;
			end	
		elseif M.Routine8State == 5 then
			if IsAround(M.HadeanBackupRecycler) and GetOdf(M.HadeanBackupRecycler) == "ebrecy_m.odf" then
				M.Routine8Timer = GetTime() + 500;
			end
			M.Routine8State = 0;--to LOC_430
		end
	end
end

--spawns elite Hadean forces via dropship that try to destroy the Wormhole Gen
function Routine9()
	if M.Routine9Active and M.Routine9Timer < GetTime() then
		if M.Routine9State == 0 then
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 25;
		elseif M.Routine9State == 1 then	
			SetAIP("elite.aip", 4);
			M.Routine9State = M.Routine9State + 1;
		elseif M.Routine9State == 2 then	--LOC_459
			M.HadeanEliteDropship = BuildObject("evdroptf", 4, M.Position21);
			SetAnimation(M.HadeanEliteDropship, "land", 1);
			StartAnimation(M.HadeanEliteDropship);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 18;
		elseif M.Routine9State == 3 then
			Goto(BuildObject("evwalk", 4, M.Position21), "endgame", 1);
			Attack(BuildObject("evkami", 4, M.Position21), M.WormholeGenerator, 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 3;
		elseif M.Routine9State == 4 then
			Attack(BuildObject("evkami", 4, M.Position21), M.WormholeGenerator, 1);
			Goto(BuildObject("evtanku", 4, M.Position21), "endgame", 1);
			Goto(BuildObject("evtanku", 4, M.Position21), "endgame", 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 3;
		elseif M.Routine9State == 5 then
			Goto(BuildObject("evtanku", 4, M.Position21), "endgame", 1);
			Goto(BuildObject("evtanku", 4, M.Position21), "endgame", 1);
			Goto(BuildObject("evtanku", 4, M.Position21), "endgame", 1);
			Goto(BuildObject("evwalk", 4, M.Position21), "endgame", 1);
			SetAnimation(M.HadeanEliteDropship, "takeoff", 1);
			StartAnimation(M.HadeanEliteDropship);
			M.Routine9State = M.Routine9State + 1;
		elseif M.Routine9State == 6 then
			if Move(M.HadeanEliteDropship, 0, M.Variable2, Position15) then
				RemoveObject(M.HadeanEliteDropship);
				M.Routine9State = 2;--to LOC_459
				M.Routine9Timer = GetTime() + 50;
			end
		end
	end
end

--orders all offensive units to evacuate the map during final countdown (merged with Routine11)
function Routine10()
	if M.Routine10Active and M.Routine10Timer < GetTime() then
		local h = GetNearestVehicle(M.CerbLandingZoneNav);
		if GetDistance(h, M.CerbLandingZoneNav) < 150 and h ~= M.Player and h ~= M.HackerScout then
			RemoveObject(h);
		end
		if #M.EvacuateUnits > 0 then
			local h = M.EvacuateUnits[1];
			if GetTeamNum(h) == 1 and IsAlive(h) and h ~= M.Player then
				Goto(h, M.CerbLandingZoneNav, 1);
			end
			table.remove(M.EvacuateUnits, 1);
		end
		M.Routine10Timer = GetTime() + 2;
	end
end

--when one of the Hadean production facilities is destroyed, plays an audio message
function Routine12()
	if M.Routine12Active then
		M.HadeanFactory2 = GetObjectByTeamSlot(3, 2);
		M.HadeanFactory1 = GetObjectByTeamSlot(2, 2);
		if not IsAround(M.HadeanFactory2) or not IsAround(M.HadeanFactory1) or not IsAround(M.HadeanRecycler) then
			AudioMessage("edf16_05.wav");	--Rebel Tech:"Our scanners are still showing Imperial Factories or Recyclers..."
			ClearObjectives();
			AddObjective("edf1606.otf", "white");
			M.Routine4Active = true;--RunSpeed,_Routine4,1,false
			M.Routine12Active = false;
		end
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if not IsAround(M.Recycler) then
			AudioMessage("edf16_15.wav");	--Hardin:"The Peacemaker has been destroyed..."
			FailMission(GetTime() + 18, "lostrecy16.des");
			M.MissionOver = true;
		elseif not IsAround(M.WormholeGenerator) then
			AudioMessage("edf16_14.wav");	--Hardin:"Your briefing was very clear about the need to protect that Wormhole Controller..."
			FailMission(GetTime() + 14, "lostgen16.des");
			M.MissionOver = true;
		elseif M.CheckHackerScout and not IsAround(M.HackerScout) then
			AudioMessage("edf16_13.wav");	--Hardin:"I can't believe you lost the Hacker Scout..."
			FailMission(GetTime() + 19, "losthack.des");
			M.MissionOver = true;
		elseif M.CheckRebelTech and not IsAlive(M.RebelTechOfficer) then
			FailMission(GetTime() + 5, "5cdead16.des");
			M.MissionOver = true;
		end
	end
end