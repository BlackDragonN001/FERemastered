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
	Object1 = nil,	--Wingman
	Object2 = nil,	--EDF dropship
	Object3 = nil, --Recycler
	Object6 = nil,	--Hadean Recy
	Object7 = nil,	--Hadean factory 1 (near Player base)
	Object8 = nil, --Hadean factory 2 (at Hadean base)
	Object10 = nil, --Player
	Object12 = nil, --Hadean backup Procreator
	Object14 = nil, --Wormhole Generator
	Object15 = nil, --Hadean nav
	Object16 = nil,	--Rebel dropship
	Object17 = nil,	--Rebel tech officer
	Object18 = nil,	--Rebel escort
	Object19 = nil,	--Hadean loyalist dropship
	Object20 = nil,	--Loyalist 1
	Object21 = nil,	--Loyalist 2
	Object22 = nil,	--Loyalist 3
	Object23 = nil,	--cheat extractor
	Object24 = nil,	--cheat extractor
	Object25 = nil,	--Hadean Constructor
	Object28 = nil,	--Respawning Hadean TIE
	Object29 = nil,	--Respawning Hadean TIE
	Object30 = nil,	--Respawning Hadean TIE
	Object31 = nil,	--Respawning Hadean TIE
	Object32 = nil,	--"cerberi2" landing zone nav
	Object34 = nil,	--Cerb dropship
	Object35 = nil,	--Cerb attacker
	Object37 = nil,	--EDF Base nav
	Object38 = nil, --Hadean walker
	Object40 = nil,	--Hadean "elite" forces landing zone
	Object41 = nil,	--Pool A
	Object42 = nil,	--Pool B
	Object44 = nil,	--Elite Hadean forces dropship
	Object45 = nil,	--"Rebel Landing Site" nav
	Object46 = nil,	--player Sbay
	Object50 = nil,	--Hadean atlas
	Object51 = nil, --EDF Bomber
	Object52 = nil,	--dummy object for final cutscene
	Object53 = nil, --dummy object for final cutscene
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
	M.Object10 = GetPlayerHandle();
	M.HackerScout = M.Object10;
	SetObjectiveName(M.Object10, "Hacker Scout");
	M.Object1 = GetHandleOrDie("Wingman");
	SetObjectiveName(M.Object1, "Wingman");
	Patrol(M.Object1, "bio_patrol", 1);
	M.Object3 = GetHandleOrDie("Recycler");
	M.Object37 = GetHandleOrDie("edfbase");
	SetObjectiveOn(M.Object37);
	SetScrap(1, 40);
	M.Object6 = GetHandleOrDie("ebrecy");
	M.Position7 = GetPosition(M.Object6);
	M.Object8 = GetHandleOrDie("unnamed_ebfact");
	M.Position8 = GetPosition(M.Object8);
	M.Object7 = GetHandleOrDie("ebfact");
	M.Object12 = GetHandleOrDie("recy2");
	M.Object14 = GetHandleOrDie("wormgen");
	M.Object32 = GetHandleOrDie("cerberi2");
	M.Object40 = GetHandleOrDie("elite");
	M.Position21 = BuildDirectionalMatrix(GetPosition(M.Object40), SetVector(0,0,-1)); 
	local cerb1 = GetHandleOrDie("cerberi1");
	local cerb2 = GetHandleOrDie("cerberi2");
	local cerb3 = GetHandleOrDie("cerberi3");
	M.CerbLandingPos[1] = BuildDirectionalMatrix(GetPosition(cerb1), SetVector(0,0,1));
	M.CerbLandingPos[2] = BuildDirectionalMatrix(GetPosition(cerb2), SetVector(-1,0,0));
	M.CerbLandingPos[3] = BuildDirectionalMatrix(GetPosition(cerb3), SetVector(-1,0,0));
	M.CerbLandingSpawn[1] = BuildDirectionalMatrix(GetPosition(cerb1)+SetVector(0,10,10), SetVector(0,0,1));
	M.CerbLandingSpawn[2] = BuildDirectionalMatrix(GetPosition(cerb2)+SetVector(-10,10,0), SetVector(-1,0,0));
	M.CerbLandingSpawn[3] = BuildDirectionalMatrix(GetPosition(cerb3)+SetVector(-10,10,0), SetVector(-1,0,0));
	SetObjectiveOn(M.Object14);

	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)

	_FECore.AddObject(h);

	if GetOdf(h) == "ibsbay.odf" then
		M.Object46 = h;
		SetObjectiveName(M.Object46, "Service Bay");
		SetObjectiveOn(M.Object46);
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

	M.Object10 = GetPlayerHandle();
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
			M.Object15 = BuildObject("ibnav", 2, M.Position7);
			SetObjectiveName(M.Object15, "hadeannav");
			M.Routine5Active = true;--RunSpeed,_Routine5,1,false
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 1 then	--LOC_39
			if GetTime() > 200 or GetOdf(M.Object3) == "ibrecy.odf" then
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 2 then	--LOC_43
			SetObjectiveOff(M.Object37);
			AudioMessage("edf16_02.wav");	--Hardin:"We estimate that the main body of the Hadean fleet is about 15 min from the wormhole jump point..."
			ClearObjectives();
			AddObjective("edf1602.otf", "white");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 3 then
			StartCockpitTimer(900);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 4 then	--LOC_49
			AddHealth(M.Object6, 500);
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
			if not IsAround(M.Object6) then
				SetTeamNum(M.Object14, 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 6;
			end
		elseif M.Routine1State == 11 then	--LOC_83
			if IsInfo("wormgen3") then
				if M.Object10 == M.HackerScout then
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
				SetTeamNum(M.Object14, 0);
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
				M.Object14 = ReplaceObject(M.Object14, "wormgen5");
				SetTeamNum(M.Object14, 1);
				SetTeamNum(M.Object3, 6);
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
				M.Object2 = BuildObject("ivdrop2_ld", 1, Position10);
				SetAnimation(M.Object2, "land", 1);
				StartAnimation(M.Object2);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 10;
			end
		elseif M.Routine1State == 19 then
			SetObjectiveOn(M.Object2);
			SetAnimation(M.Object2, "deploy", 1);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 20 then
			if GetDistance(M.Object10, M.Object2) < 10 then
				M.Routine1State = M.Routine1State + 1;
			elseif GetCockpitTimer() <= 1 then
				AudioMessage("edf16_11.wav");	--Condor Pilot:"Star ship Intrepid, this is Condor. Lifting off now..."
				M.Routine1State = 24;--to LOC_175
				M.Routine1Timer = GetTime() + 9;
			end
		elseif M.Routine1State == 21 then	--LOC_158
			SetTeamNum(M.Object2, 6);
			M.Routine10Active = false;--RunSpeed,_Routine10,0,false --RunSpeed,_Routine11,0,false
			CameraReady();
			M.CameraEndTime = GetTime() + 7;
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 22 then
			CameraObject(M.Object14, Position16, M.Object14)
			if M.CameraEndTime < GetTime() then
				local viewstand = GetHandleOrDie("unnamed_viewstand");
				local pos = GetPosition(viewstand);
				M.Object53 = BuildObject("dummy2",0, pos);
				pos.z = pos.z + 600;
				M.Object52 = BuildObject("dummy2",0, pos);
				LookAt(M.Object53, M.Object52, 1);
				M.Routine2Active = true;--RunSpeed,_Routine2,1,false
				M.CameraEndTime = GetTime() + 3;
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 23 then
			if CameraObject(M.Object53, Position23, M.Object52) then
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
			M.Object7 = GetObjectByTeamSlot(2, 2);
			M.Object8 = GetObjectByTeamSlot(3, 2);
			if not IsAround(M.Object7) and not IsAround(M.Object8) 
			and not IsAround(M.Object6) then
				AudioMessage("edf16_06.wav");	--Rebel Tech:"Our dropship is beginning its descent..."
				CalcCliffs(M.Object14, nil, 400);	--fixes mysterious annoying pathing problems in Hadean base after some buildings are destroyed
				ClearObjectives();
				AddObjective("edf1607.otf", "white");
				M.Object45 = BuildObject("ibnav", 1, Position10);
				SetObjectiveName(M.Object45, "Rebel Landing Site");
				SetObjectiveOn(M.Object45);
				M.Routine4State = M.Routine4State + 1;
				M.Routine4Timer = GetTime() + 30;				
			end
		elseif M.Routine4State == 2 then
			M.Object16 = BuildObject("evdrop_l2", 6, Position10);
			SetAnimation(M.Object16, "land", 1);
			StartAnimation(M.Object16);
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 20;
		elseif M.Routine4State == 3 then
			M.Object16 = ReplaceObject(M.Object16, "evdroptf");
			M.Object17 = BuildObject("evscout", 6, Position10);
			M.Object18 = BuildObject("evscout", 6, Position10);
			SetSkill(M.Object17, 3);
			SetSkill(M.Object18, 3);
			SetObjectiveName(M.Object17, "Rebel Tech Officer");
			SetObjectiveOn(M.Object17);
			M.Object19 = BuildObject("evdrop_l2", 2, BuildDirectionalMatrix(Position11));
			SetAnimation(M.Object19, "land", 1);
			StartAnimation(M.Object19);
			SetAnimation(M.Object16, "deploy", 1);
			StartAnimation(M.Object16);
			Follow(M.Object17, M.Object10, 1);
			Follow(M.Object18, M.Object10, 1);
			M.CheckRebelTech = true;
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 20;
		elseif M.Routine4State == 4 then
			M.Object19 = ReplaceObject(M.Object19, "evdroptf");
			SetAnimation(M.Object19, "deploy", 1);
			StartAnimation(M.Object19);
			M.Object20 = BuildObject("evscout", 2, Position11);
			M.Object21 = BuildObject("evscout", 2, Position11);
			M.Object22 = BuildObject("evscout", 2, Position11);
			Goto(M.Object20, M.Object17, 1);
			Goto(M.Object21, M.Object17, 1);
			Goto(M.Object22, M.Object17, 1);
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 3;
		elseif M.Routine4State == 5 then
			Attack(M.Object20, M.Object17, 1);
			Attack(M.Object21, M.Object17, 1);
			Attack(M.Object22, M.Object17, 1);
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 6 then	--LOC_257
			if GetDistance(M.Object17, M.Object10) < 40 then
				LookAt(M.Object17, M.Object10, 1);
				M.Variable6 = M.Variable6 + 4;
				ClearObjectives();
				AddObjective(string.format("edf1609.otf", M.Variable6), "white");
				if M.Variable6 >= 100 then
					M.Routine4State = M.Routine4State + 1;
				end
				M.Routine4Timer = GetTime() + 1;
			end	
		elseif M.Routine4State == 7 then
			LookAt(M.Object17, M.Object10, 1);
			AudioMessage("edf16_07.wav");	--Rebel Tech:"The new encryption algorithm has been installed..."
			ClearObjectives();
			AddObjective("edf1610.otf", "green");
			SetObjectiveOff(M.Object45);			
			M.DownloadFinished = true;
			SetAnimation(M.Object19, "takeoff", 1);
			StartAnimation(M.Object19);
			M.Variable2 = 30.0;
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 8 then
			if Move(M.Object19, 0, M.Variable2, Position15) then
				RemoveObject(M.Object19);
				M.Routine4State = M.Routine4State + 1;
				M.Routine4Timer = GetTime() + 20;	--lowered time Hadean Tech spends waiting from 40s to 20s
			end
		elseif M.Routine4State == 9 then
			Goto(M.Object17, M.Object45, 1);
			Goto(M.Object18, M.Object45, 1);
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 10 then
			if GetDistance(M.Object17, M.Object45) < 200 then
				M.Routine4State = M.Routine4State + 1;
				M.Routine4Timer = GetTime() + 2;
			end
		elseif M.Routine4State == 11 then
			if Move(M.Object17, 0, M.Variable2, Position10) then
				M.CheckRebelTech = false;
				RemoveObject(M.Object17);
				RemoveObject(M.Object18);
				M.Routine10Active = true;--RunSpeed,_Routine10,1,false
				AudioMessage("edf16_08.wav");	--Hardin:"You'd better build plenty of automated defenses around the Wormhole Controller..."
				--ClearObjectives();	--want to keep the password in the objectives box!
				AddObjective("edf1611.otf", "white");
				SetAnimation(M.Object16, "takeoff", 1);
				StartAnimation(M.Object16);
				M.Routine4State = M.Routine4State + 1;
			end
		elseif M.Routine4State == 12 then
			if Move(M.Object16, 0, M.Variable2, Position15) then
				RemoveObject(M.Object16);
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
			M.Object23 = ReplaceObject(GetHandle("cheat3"), "ebscup_16");
			M.Object24 = ReplaceObject(GetHandle("cheat2"), "ebscup_16");
			SetScrap(3, 0);
			M.Object41 = GetHandle("mapoolA");
			M.Object42 = GetHandle("mapoolB");
			Goto(BuildObject("evscav", 3, GetPosition(M.Object7)), M.Object41, 1);
			Goto(BuildObject("evscav", 3, GetPosition(M.Object7)), M.Object42, 1);
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 1 then	--LOC_309
			local hasDeployedRecy = IsAround(M.Object6) or (IsAround(M.Object12) and GetOdf(M.Object12) == "ebrecy_m.odf");
			local hasRecy = IsAround(M.Object6) or IsAround(M.Object12);
			if not hasRecy then
				CalcCliffs(M.Object14, nil, 400);	--fixes mysterious annoying pathing problems in Hadean base after some buildings are destroyed
				M.Routine5State = 99;
			elseif not hasDeployedRecy then
				--wait for Hadean team to deploy their backup Procreator
			elseif not IsAround(M.Object25) and not IsAround(M.Object7) then
				M.Object25 = BuildObject("evcons", 3, M.Position7);
				M.Routine5State = M.Routine5State + 1;
			elseif not IsAround(M.Object28) then
				M.Object28 = BuildObject("evsky", 7, M.Position7);
				Patrol(M.Object28, "team3_path", 1);
			elseif not IsAround(M.Object29) then
				M.Object29 = BuildObject("evsky", 7, M.Position7);
				Patrol(M.Object29, "team2_patrol", 1);
			elseif not IsAround(M.Object30) then
				M.Object30 = BuildObject("evsky", 7, M.Position7);
				Patrol(M.Object30, "worm_patrol", 1);
			elseif not IsAround(M.Object31) then
				M.Object31 = BuildObject("evsky", 7, M.Position7);
				Patrol(M.Object31, "team2_patrol", 1);
				--SetAIP("edf163.aip", 3);
			end
			M.Routine5Timer = GetTime() + 60;
		elseif M.Routine5State == 2 then
			if IsAround(M.Object6) and IsAround(M.Object25) then
				Defend2(BuildObject("evscout", 7, M.Position7), M.Object25, 1);
				Defend2(BuildObject("evscout", 7, M.Position7), M.Object25, 1);
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
			M.Object34 = BuildObject("evdroptf", 5, M.Position18);
			SetAnimation(M.Object34, "land", 1);
			StartAnimation(M.Object34);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 18;
		elseif M.Routine6State == 3 then
			SetAnimation(M.Object34, "deploy", 1);
			StartAnimation(M.Object34);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 10;
		elseif M.Routine6State == 4 then
			M.Object35 = BuildObject("cvtank", 5, M.Position19);
			Goto(M.Object35, M.Object3, 1);
			Follow(BuildObject("cvtank", 5, M.Position19), M.Object35, 0);
			Follow(BuildObject("cvtank", 5, M.Position19), M.Object35, 0);
			Follow(BuildObject("cvtank", 5, M.Position19), M.Object35, 0);
			M.Variable2 = 30.0;
			SetAnimation(M.Object34, "takeoff", 1);
			StartAnimation(M.Object34);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 10;
		elseif M.Routine6State == 5 then
			if Move(M.Object34, 0, M.Variable2, Position15) then
				RemoveObject(M.Object34);
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
			M.Object34 = BuildObject("evdroptf", 5, M.Position18);
			SetAnimation(M.Object34, "land", 1);
			StartAnimation(M.Object34);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 18;
		elseif M.Routine6State == 8 then
			SetAnimation(M.Object34, "deploy", 1);
			StartAnimation(M.Object34);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 10;
		elseif M.Routine6State == 9 then
			M.Object35 = BuildObject("cvrbomb", 5, M.Position19);
			Follow(BuildObject("cvtank", 5, M.Position19), M.Object35, 1);
			Follow(BuildObject("cvtank", 5, M.Position19), M.Object35, 1);
			Follow(BuildObject("cvtank", 5, M.Position19), M.Object35, 1);
			Attack(M.Object35, M.Object3, 1);
			SetAnimation(M.Object34, "takeoff", 1);
			StartAnimation(M.Object34);
			M.Routine6State = M.Routine6State + 1;
			M.Routine6Timer = GetTime() + 10;
		elseif M.Routine6State == 10 then
			if Move(M.Object34, 0, M.Variable2, Position15) then
				RemoveObject(M.Object34);
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
			--M.Object40 = GetHandleOrDie("elite");
			--M.Position21 = GetPosition(M.Object40);
			M.Routine7State = M.Routine7State + 1;
		elseif M.Routine7State == 1 then	--LOC_404
			if not IsAround(M.Object50) and IsAround(M.Object6) and M.AtlasRespawnTime < GetTime() then
				M.Object50 = BuildObject("evartl2", 7, M.Position7);
				M.AtlasRespawnTime = GetTime() + 90;
				--M.Object51 = GetHandle("unnamed_ivbomb");
				--Attack(M.Object50, M.Object51, 1);
			elseif not IsAround(M.Object6) then
				SetTeamNum(M.Object14, 0);
				if not IsAround(M.Object12) then
					M.Routine7State = 4;--to LOC_421
				else
					SetTeamNum(M.Object12, 2);
					Goto(M.Object12, "recyrun", 1);
					Follow(BuildObject("evtanku", 4, M.Position21), M.Object12, 0);
					M.Routine7State = M.Routine7State + 1;
				end
			end
		elseif M.Routine7State == 2 then
			if M.DownloadFinished then
				M.Routine8Active = true;--RunSpeed,_Routine8,1,false
				M.Routine7State = M.Routine7State + 1;
			end
		elseif M.Routine7State == 3 then
			if GetDistance(M.Object12, "ebrecy") < 150 then
				Dropoff(M.Object12, "ebrecy", 0);
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
			local pos = GetPosition(M.Object40);
			pos.y = TerrainFindFloor(pos);
			M.Position21 = BuildDirectionalMatrix(pos, SetVector(0,0,-1));
			M.Object44 = BuildObject("evdroptf", 4, M.Position21);
			SetAnimation(M.Object44, "land", 1);
			StartAnimation(M.Object44);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 15;
		elseif M.Routine8State == 1 then
			SetAnimation(M.Object44, "deploy", 1);
			StartAnimation(M.Object44);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 10;
		elseif M.Routine8State == 2 then
			M.Object38 = BuildObject("evwalk", 4, M.Position21);
			if IsAround(M.Object12) then
				Follow(BuildObject("evtanku", 4, M.Position21), M.Object12, 0);
				Follow(BuildObject("evtanku", 4, M.Position21), M.Object12, 0);
			end
			Follow(BuildObject("evtanku", 4, M.Position21), M.Object38, 0);
			Follow(BuildObject("evtanku", 4, M.Position21), M.Object38, 0);
			Goto(M.Object38, "endgame", 0);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 10;
		elseif M.Routine8State == 3 then
			SetAnimation(M.Object44, "takeoff", 1);
			StartAnimation(M.Object44);
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 4 then
			if Move(M.Object44, 0, M.Variable2, Position15) then
				RemoveObject(M.Object44);
				M.Routine8State = M.Routine8State + 1;
				M.Routine8Timer = GetTime() + 300;
			end	
		elseif M.Routine8State == 5 then
			if IsAround(M.Object12) and GetOdf(M.Object12) == "ebrecy_m.odf" then
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
			M.Object44 = BuildObject("evdroptf", 4, M.Position21);
			SetAnimation(M.Object44, "land", 1);
			StartAnimation(M.Object44);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 18;
		elseif M.Routine9State == 3 then
			Goto(BuildObject("evwalk", 4, M.Position21), "endgame", 1);
			Attack(BuildObject("evkami", 4, M.Position21), M.Object14, 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 3;
		elseif M.Routine9State == 4 then
			Attack(BuildObject("evkami", 4, M.Position21), M.Object14, 1);
			Goto(BuildObject("evtanku", 4, M.Position21), "endgame", 1);
			Goto(BuildObject("evtanku", 4, M.Position21), "endgame", 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 3;
		elseif M.Routine9State == 5 then
			Goto(BuildObject("evtanku", 4, M.Position21), "endgame", 1);
			Goto(BuildObject("evtanku", 4, M.Position21), "endgame", 1);
			Goto(BuildObject("evtanku", 4, M.Position21), "endgame", 1);
			Goto(BuildObject("evwalk", 4, M.Position21), "endgame", 1);
			SetAnimation(M.Object44, "takeoff", 1);
			StartAnimation(M.Object44);
			M.Routine9State = M.Routine9State + 1;
		elseif M.Routine9State == 6 then
			if Move(M.Object44, 0, M.Variable2, Position15) then
				RemoveObject(M.Object44);
				M.Routine9State = 2;--to LOC_459
				M.Routine9Timer = GetTime() + 50;
			end
		end
	end
end

--orders all offensive units to evacuate the map during final countdown (merged with Routine11)
function Routine10()
	if M.Routine10Active and M.Routine10Timer < GetTime() then
		local h = GetNearestVehicle(M.Object32);
		if GetDistance(h, M.Object32) < 150 and h ~= M.Object10 and h ~= M.HackerScout then
			RemoveObject(h);
		end
		if #M.EvacuateUnits > 0 then
			local h = M.EvacuateUnits[1];
			if GetTeamNum(h) == 1 and IsAlive(h) and h ~= M.Object10 then
				Goto(h, M.Object32, 1);
			end
			table.remove(M.EvacuateUnits, 1);
		end
		M.Routine10Timer = GetTime() + 2;
	end
end

--when one of the Hadean production facilities is destroyed, plays an audio message
function Routine12()
	if M.Routine12Active then
		M.Object8 = GetObjectByTeamSlot(3, 2);
		M.Object7 = GetObjectByTeamSlot(2, 2);
		if not IsAround(M.Object8) or not IsAround(M.Object7) or not IsAround(M.Object6) then
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
		if not IsAround(M.Object3) then
			AudioMessage("edf16_15.wav");	--Hardin:"The Peacemaker has been destroyed..."
			FailMission(GetTime() + 18, "lostrecy16.des");
			M.MissionOver = true;
		elseif not IsAround(M.Object14) then
			AudioMessage("edf16_14.wav");	--Hardin:"Your briefing was very clear about the need to protect that Wormhole Controller..."
			FailMission(GetTime() + 14, "lostgen16.des");
			M.MissionOver = true;
		elseif M.CheckHackerScout and not IsAround(M.HackerScout) then
			AudioMessage("edf16_13.wav");	--Hardin:"I can't believe you lost the Hacker Scout..."
			FailMission(GetTime() + 19, "losthack.des");
			M.MissionOver = true;
		elseif M.CheckRebelTech and not IsAlive(M.Object17) then
			FailMission(GetTime() + 5, "5cdead16.des");
			M.MissionOver = true;
		end
	end
end