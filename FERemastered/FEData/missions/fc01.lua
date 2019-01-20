assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
require('_FECore');

local NUM_SOLDIERS = 7;
local NUM_GTOWS = 5;

--Strings
local _Text1 = "fOLLOW gENERAL tHANATOS aS hE\ngATHERS tHE rEBEL sCOUTS. wATCH\nyOUR dISPLAY tO aVOID fIRING oN\naLLIED uNITS. oUR fORCES aRE\nhIGHLIGHTED iN bLUE.";
local _Text2 = "a sTRANGE eNERGY sIGNATURE hAS\nmANIFESTED iTSELF nEAR oUR bASE.\nhURRY tO tHE hIGHLIGHTED nAV\nbEACON aND iNVESTIGATE tHE\npHENOMENON.";
local _Text3 = "yOUR fAILURE tO iNVESTIGATE tHE\neNERGY sIGNATURE hAS aNGERED\nsLASHER/pRIME tHANATOS. rETURN\ntO bASE iMMEDIATELY.";
local _Text4 = "oUR pROCREATOR hAS bEEN\ndESTROYED. iT wAS fOOLISH oF uS\ntO rELY oN a sOFT-sKINNED\ncREATURE fOR sUCH aN iMPORTANT\ntASK!";
local _Text5 = "  iNCOMING hUMAN mESSAGE:  \n||Colonel Corber, our trap is\nset. Lure the drone-carrier and\nits drones to our position as\nquickly as possible!";
local _Text6 = "yOU lOST a vALUABLE sCOUT wITH\nhARDLY a fIGHT. yOUR rACE iS\ndOOMED iF oTHER hUMANS fIGHT aS\npOORLY aS yOU dO!";
local _Text7 = "dEFEND oUR hARVESTERS aND\nrESOURCERS sO tHAT wE mAY gATHER\neNOUGH sCRAP tO bUILD aN aSSAULT\nfORCE.";
local _Text8 = "yOUR bLOOD-lUST iS cOMMENDABLE,\nbUT yOU mUST bE pATIENT. tHE\npROCREATOR wILL sOON bUILD a\nrEPLACEMENT sCOUT sO yOU mAY\nrETURN tO bATTLE!";
local _Text9 = "yOU cLAIM tO bE oUR aLLY, yET\nyOU fAIL tO aCT lIKE oNE! oUR\nfORCES aRE nOW wARY oF yOU, aND\naRE uNLIKELY tO cOOPERATE\nfULLY!";
local _Text10 = "aLL cERBERI gUN-tOWERS hAVE\nfALLEN! oUR wARRIORS aRE aS\nfEROCIOUS aS kALI-wOLVES, aND\ntHE bLOOD oF hEROES fLOWS iN\ntHEIR vEINS!";
local _Text11 = "aNOTHER cERBERI eNERGY-pORTAL\nhAS aPPEARED nEAR oUR bASE.\npREPARE fOR a mAJOR aSSAULT!";
local _Text12 = "rEMEMBER, wE aRE pOSING aS tHE\ncERBERI'S aLLIES! yOU mUST nOT\nfIRE aNY wEAPONS uNTIL tHE\ncOMMAND iS gIVEN!";
local _Text13 = "tHE cERBERI aRE mOVING iNTO\naTTACK fORMATION! pROTECT tHE\npROCREATOR aND yOUR vEHICLE! nO\nsHIPS cAN bE rEPLACED uNTIL tHE\npROCREATOR dEPLOYS.";
local _Text14 = "eSCORT tHE pROCREATOR aS wE\npILOT iT tO sAFETY. aVOID fIRING\nyOUR wEAPONS oR mAKING aNY\nsUSPICIOUS mOVEMENTS.";
local _Text15 = "bETRAYAL wILL nOT bE tOLERATED!";	--added failure condition if Thanatos dies before reaching Cerb base

local M = {
-- Bools
	MissionOver = false,
	CanLoseShip = false,	--whether the player is allowed to lose their starting ship
	CheckThanatos = false,
	Routine4Active = false,
	Routine8Active = false,
	Routine9Active = false,
	Routine10Active = false,
	Routine11Active = false,
	Routine14Active = true,
	
-- Floats
	Routine1Timer = 0.0,
	Routine4Timer = 0.0,
	Routine8Timer = 0.0,
	Routine9Timer = 0.0,
	Routine10Timer = 0.0,
	Routine11Timer = 0.0,
	Routine14Timer = 0.0,

-- Handles
	Object1 = nil,	--Procreator
	Object2 = nil,	--Player
	Object3 = nil,	--Hadean Commander
	Object4 = nil,	--Hadean Escort 1 (xypos)
	Object5 = nil,	--Hadean Escort 2 (xypos)
	Object6 = nil,	--Hadean Escort 3 (xypos)
	Object7 = nil,	--Hadean Escort 4 (xares)
	Object9 = nil,	--Cerb1 (cvtank)
	Object10 = nil,	--Cerb2 (cvscout)
	Object11 = nil,	--Cerb3 (cvtank)
	Object12 = nil,	--Cerb4 (cvscout)
	Object13 = nil,	--Dropship, scratch for AuroraBolt, lure nav
	Object14 = nil,	--Cerb Portal Aurora
	Object15 = nil,	--Cerb Portal Aurora
	Object16 = nil,	--Cerb Portal Aurora
	Object17 = nil,	--Cerb Portal Aurora field
	Object18 = nil, --Cerb Portal Aurora 2
	Object19 = nil, --Cerb Portal Aurora 2
	Object20 = nil, --Cerb Portal Aurora 2
	Object21 = nil, --Cerb Portal Aurora field 2
	Object24 = nil,	--Cerb Drone carrier
	Object25 = nil,	--EDF Sgt. Steinman (pilot)
	Object26 = nil,	--Player's scout
	Object30 = nil,	--EDF Lt. Miller (soldier)
	Object31 = nil,	--"Energy Disturbance" nav
	Object33 = nil,-- Cerb recycler <2>
	Object35 = {},	--Cerb Gtows (array)
	Object40 = nil,	--Player's Service trucks
	Object41 = {},	--Hadean assault tanks (array<4>)
	Object45 = nil,-- Targeted Cerb gun tower <2>
	BasePatrol1 = nil,
	BasePatrol2 = nil,
	NewObjs = {},
-- Ints
	TPS = 10,
	Routine1State = 0,
	Routine4State = 0,
	Routine8State = 0,
	Routine9State = 0,
	Routine10State = 0,
	--Routine11State = 0,
	Routine14State = 0,
	Variable1 =  0,	--Hadean assault in progress
	Variable2 =  0,	--Thanatos nag timer
	Variable3 =  0,	--Miller ambush counter
	Variable4 =  0,	--# of player turrets
	Variable5 =  0,	--# of turrets to build
	Variable6 =  0,	--# of player service trucks
	Variable7 =  1,	--# of service trucks to build
	Variable8 =  0,	--# of player scouts
	Variable9 =  0,	--# of scouts to build
	Variable12 =  0,	--Thanatos nag counter
	Variable13 =  0,	--# of soldiers that survived the drone carrier ambush
	Variable14 =  380,	--scan radius for NearObjectCount (Routine9)
	Variable15 =  0,	--# Hadean atanks built
	Variable16 =  0,	--always 0
	Variable18 =  2000,	--radius for NearObjectCount (Routine8)
	Variable19 =  0,	--Cerb portal location (0: behind Hadean base, 1:at Hadean base)
	GTowsRemaining = NUM_GTOWS,	--number of Cerb gun towers left

--Vectors
	Position1 = SetVector( -380,0,-870),	--Cerb Portal location ("Energy Disturbance")
	Position2 = SetVector( 360,0,-385),		--Cerb portal location
	Position3 = SetVector( 380,0,-580),		--Cerb portal location
	--Position4 = SetVector( -1000,0,-1000),	--temp pos for teleporting cerb units
	Position5 = SetVector( -5,5,10),	--was ( -1,1,4) Camera offset for Steinman cutscene (changed due to FOV bug in 1.3.7.2)
	Position6 = SetVector( 4,13,2),	--was ( 4,3,2); offset 1 for CamPos (Lt. Miller cutscene)
	Position7 = SetVector( 4,12,-2),	--was ( 4,2,-2); offset 2 for CamPos (Lt. Miller cutscene)
--End
	endme = 0
}

function Save()
    return M
end

function Load(...)
    if select('#', ...) > 0 then
		M = ...
    end
end

function InitialSetup()
	M.TPS = EnableHighTPS();
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadOdf = {
		"evrecy_m",
		"AuroraBolt",
		"aurora1",
		"aurora2",
		"aurora3",
		"aurorafield",
		"chainmin"
	};
	for k,v in pairs(preloadOdf) do
		PreloadODF(v);
	end
	--Preload audio messages
	local preloadAudio = {
		"fc01_01.wav",
		"fc01_02.wav",
		"fc01_03.wav",
		"fc01_04.wav",
		"fc01_05.wav",
		"fc01_05b.wav",
		"fc01_06.wav",
		"fc01_07.wav",
		"fc01_08.wav",
		"fc01_09.wav",
		"fc01_10.wav",
		"fc01_11.wav",
		"fc01_11b.wav",
		"fc01_12.wav",
		"fc01_12a.wav",
		"fc01_13.wav",
		"fc01_14.wav",
		"fc01_15.wav",
		"fc01_16.wav",
		"fc01_17.wav",
		"fc01_18.wav"
	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
	
	WantBotKillMessages();
end

--gets an object handle by label. If it doesn't exist, throws an error.
function GetHandleOrDie(name)
	return GetHandle(name) or error("Error: object '"..name.."' not found!", 2);
end

function Start()
	Ally(1,3);
	Ally(2,3);
	--Ally(6,2);
	--Ally(6,3);
	Ally(1,4);
	Ally(2,4);
	Ally(3,4);
	--Ally(6,4);
	
	M.Object1 = BuildObject("evrecy_m", 3, "Recycler");
	M.Object13 = GetHandleOrDie("DropShip");
	M.Object25 = GetHandleOrDie("InfoPilot");
	M.Object26 = GetPlayerHandle();
	M.Object30 = GetHandleOrDie("Soldier0");
	M.Object33 = GetHandleOrDie("RecyclerEnemy");
	M.Object35[1] = GetHandleOrDie("CerbGT0");
	M.Object35[2] = GetHandleOrDie("CerbGT1");
	M.Object35[3] = GetHandleOrDie("CerbGT2");
	M.Object35[4] = GetHandleOrDie("CerbGT3");
	M.Object35[5] = GetHandleOrDie("CerbGT4");
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)
	if GetCfg(M.Object1) == "ebrecy_m" and not IsPlayer(h) then
		if GetCfg(h) == "ebscav" or GetCfg(h) == "ebscup" then
			SetObjectiveName(h, "Defend Resourcer");
			SetObjectiveOn(h);
		elseif GetCfg(h) == "evserv" then
			M.Variable6 = M.Variable6 + 1;
			SetTeamNum(h, 1);
			SetGroup(h, 3);
		elseif GetCfg(h) == "evturr" then
			M.Variable4 = M.Variable4 + 1;
			SetTeamNum(h, 1);
			SetGroup(h, 2);
			--RunSpeed,_Routine13,6,true
		elseif GetCfg(h) == "evscout" then
			M.Variable8 = M.Variable8 + 1;
			GiveWeapon(h, "gshellgun_c");
			SetTeamNum(h, 1);
			SetGroup(h, 1);
		--elseif GetCfg(h) == "espilo" or 
		--	   GetCfg(h) == "error" then
		--	SetTeamNum(h, 3);	--doesn't seem to work here
		elseif GetCfg(h) == "evatank" then
			SetTeamNum(h, 4);
		elseif GetCfg(h) == "evtank" then
			if not IsAround(M.BasePatrol1) then
				M.BasePatrol1 = h;
				SetTeamNum(h, 4);
			elseif not IsAround(M.BasePatrol2) then
				M.BasePatrol2 = h;
				SetTeamNum(h, 4);
			end
		end
		
		--Defer processing of new Objects until the next update, since some funcs don't seem to work properly if called here
		if GetTeamNum(h) == 4 then
			table.insert(M.NewObjs, h);
		end
	end
end

function AddObjectDeferred(h)
	if GetCfg(M.Object1) == "ebrecy_m" and not IsPlayer(h) then
		if GetCfg(h) == "evtank" then
			Patrol(h, "Patrol2", 0);
		--elseif GetCfg(h) == "evscav" then
		--	Goto(h, "DroneCarrier1", 0);	
		elseif GetCfg(h) == "evatank" then
			for i = 1,3 do
				if not IsAround(M.Object41[i]) then
					M.Object41[i] = h;
					if i == 1 then
						Goto(h, "StagePoint1A", 0);
					elseif i == 2 then
						Goto(h, "StagePoint2A", 0);
					elseif i == 3 then
						Goto(h, "StagePoint3A", 0);
					end
					break;
				end
			end
		elseif GetCfg(h) == "espilo" or 
			   GetCfg(h) == "error" then
			SetTeamNum(h, 3);
		end
	end
end

function ObjectKilled(deadObj, killerObj)
	if GetTeamNum(h) == 3 and IsPlayer(killerObj) then
		ClearObjectives();
		AddObjective(_Text9, "red");
		M.Variable5 = M.Variable5 - 1;
		M.Variable7 = M.Variable7 - 1;
		M.Variable9 = M.Variable9 - 1;
		AddScrap(3, -60);
	end
	
	return 0;
end

function DeleteObject(h)
	if GetTeamNum(h) == 2 and GetCfg(h) == "cbgtow" then	--original script checked for "ebgtow". How did this work before??
		M.GTowsRemaining = M.GTowsRemaining - 1;
		if M.GTowsRemaining > 0 then
			AudioMessage("fc01_17.wav");	--Thanatos:"Another Cerberi Gun Tower has fallen..."
		end
	end

	if GetCfg(M.Object1) == "ebrecy_m" then
		if GetCfg(h) == "evserv" then
			M.Variable6 = M.Variable6 - 1;
		elseif GetCfg(h) == "evturr" and GetTeamNum(h) == 1 and h ~= M.Object2 then
			M.Variable4 = M.Variable4 - 1;
		elseif GetCfg(h) == "evscout" then
			M.Variable8 = M.Variable8 - 1;
		end
	end
end

function Update()
	M.Object2 = GetPlayerHandle();
	Routine1();
	Routine4();
	Routine8();
	Routine9();
	Routine10();
	Routine11();
	Routine14();
	CheckStuffIsAlive();
	
	for i=1,#M.NewObjs do
		AddObjectDeferred(M.NewObjs[i]);
	end
	M.NewObjs = {};
end

--Main mission state
--Handles patrol, escorting Hadean Procreator, and Cerb portal
function Routine1()
	if M.Routine1Timer < GetTime() then
		if M.Routine1State == 0 then			
			GiveWeapon(M.Object2, "gshellgun_c");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 1 then
			SetAnimation(M.Object13, "takeoff", 1);
			StartAnimation(M.Object13);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 4;
		elseif M.Routine1State == 2 then
			AudioMessage("dropleav.wav");
			M.Object3 = BuildObject("evscout", 3, "Escort0");
			GiveWeapon(M.Object3, "gshellgun_c");
			SetObjectiveName(M.Object3, "Hadean Commander");
			SetObjectiveOn(M.Object3);
			Goto(M.Object3, "MeetPlayer", 0);
			M.CheckThanatos = true;
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 4;
		elseif M.Routine1State == 3 then
			RemoveObject(M.Object13);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 4 then	--LOC_22
			if GetCurrentCommand(M.Object3) == 0 then
				LookAt(M.Object3, M.Object2, 0);
				AddObjective(_Text1, "white");
				AudioMessage("fc01_01.wav");	--Thanatos:"Welcome, Talon Corber..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 20;
			end
		elseif M.Routine1State == 5 then
			Goto(M.Object3, "Follow1", 0);
			M.Object4 = BuildObject("evscout", 3, "Escort1");
			GiveWeapon(M.Object4, "gshellgun_c");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 6 then	--LOC_32
			if GetCurrentCommand(M.Object3) == 0 then
				LookAt(M.Object3, M.Object4);
				LookAt(M.Object4, M.Object3);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 3;
			end
		elseif M.Routine1State == 7 then	--LOC_37
			if GetDistance(M.Object2, M.Object3) < 80 then
				AudioMessage("fc01_02.wav");	--Thanatos:"As you can see, we are all piloting Xypos scouts..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 6;
			end
		elseif M.Routine1State == 8 then
			Goto(M.Object3, "Follow2", 0);
			Follow(M.Object4, M.Object3, 0);
			M.Object5 = BuildObject("evscout", 3, "Escort2");
			GiveWeapon(M.Object5, "gshellgun_c");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 9 then	--LOC_46
			if GetCurrentCommand(M.Object3) == 0 then
				LookAt(M.Object3, M.Object5);
				LookAt(M.Object5, M.Object3);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 3;
			end
		elseif M.Routine1State == 10 then	--LOC_51
			if GetDistance(M.Object2, M.Object3) < 60 then
				AudioMessage("fc01_03.wav");	--Hadean Scout:"We have discovered why our allies failed to make the rendezvous..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 16;
			end
		elseif M.Routine1State == 11 then
			Goto(M.Object3, "Follow3", 0);
			Follow(M.Object5, M.Object3, 0);
			M.Object6 = BuildObject("evscout", 3, "Escort3");
			GiveWeapon(M.Object6, "gshellgun_c");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 12 then	--LOC_60
			if GetCurrentCommand(M.Object3) == 0 then
				LookAt(M.Object3, M.Object6);
				LookAt(M.Object6, M.Object3);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 3;
			end
		elseif M.Routine1State == 13 then
			if GetDistance(M.Object2, M.Object3) < 60 then
				Goto(M.Object3, "Follow4", 0);
				Follow(M.Object6, M.Object3, 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 8;
			end
		elseif M.Routine1State == 14 then
			AudioMessage("fc01_04.wav");	--Corber:"These Space Hawks are heavily shielded sir..."
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 15 then	--LOC_72
			if GetCurrentCommand(M.Object3) == 0 then
				SetObjectiveName(M.Object25, "EDF Sgt. Steinman");
				SetObjectiveOn(M.Object25);
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 16 then
			if GetDistance(M.Object2, M.Object3) < 40 then
				LookAt(M.Object3, M.Object25, 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 2;
			end
		elseif M.Routine1State == 17 then
			AudioMessage("fc01_05.wav");	--Steinman:"You're right. The Cerberi have a few heavy beam weapons we did not know about..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 18 then
			CameraReady();
			M.CameraEndTime = GetTime() + 7;
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 19 then
			CameraObject(M.Object25, M.Position5, M.Object25);
			if M.CameraEndTime < GetTime() or CameraCancelled() then
				CameraFinish();
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 15;
			end
		elseif M.Routine1State == 20 then
			SetObjectiveOff(M.Object25);
			Goto(M.Object3,"Follow5", 0);
			SetPerceivedTeam(M.Object2, 2);
			M.Object7 = BuildObject("evtank", 3, "Escort4");
			M.Object24 = BuildObject("cvdcar_01", 2, "DroneCarrier1");
			SetMaxAmmo(M.Object24, 6000);
			SetCurAmmo(M.Object24, 6000);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 21 then	--LOC_93
			if GetCurrentCommand(M.Object3) == 0 then
				LookAt(M.Object3, M.Object7);
				LookAt(M.Object7, M.Object3);
				AudioMessage("fc01_05b.wav");	--Hadean Tank:"The remaining EDF survivors are waiting just east of us..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 5;
			end
		elseif M.Routine1State == 22 then	--LOC_99
			if GetDistance(M.Object2, M.Object3) < 60 then
				M.Object9 = BuildObject("cvtank", 2 ,"Cerb1");
				M.Object10 = BuildObject("cvscout", 2 ,"Cerb2");
				M.Object11 = BuildObject("cvtank", 2 ,"Cerb3");
				M.Object12 = BuildObject("cvscout", 2 ,"Cerb4");
				Goto(M.Object3, "SoldierMeet", 0);
				Follow(M.Object7, M.Object3, 0);
				RemoveObject(M.Object25);
				ClearObjectives();
				AddObjective(_Text12, "white");
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 23 then	--LOC_111
			if GetCurrentCommand(M.Object3) == 0 then
				SetObjectiveName(M.Object30, "EDF Lt. Miller");
				SetObjectiveOn(M.Object30);
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 24 then	--LOC_115
			if GetDistance(M.Object2, M.Object3) < 60 then
				LookAt(M.Object3, M.Object33, 0);
				AudioMessage("fc01_06.wav");	--Miller:"General Thanatos, it's an honor to meet you..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 15;
			end
		elseif M.Routine1State == 25 then
			CameraReady();
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 26 then
			if CameraPos(M.Object30, M.Object30, M.Position6, M.Position7, 30) then
				CameraFinish();
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 13;--16
			end
		elseif M.Routine1State == 27 then
			LookAt(M.Object3, M.Object22, 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;--10
		elseif M.Routine1State == 28 then
			AudioMessage("fc01_07.wav");	--Thanatos:"We will now enter the Cerberi base and retrieve the Procreator..."
			Goto(M.Object3, "MeetRecycler", 0);
			SetObjectiveOff(M.Object30);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 29 then	--LOC_128
			if GetCurrentCommand(M.Object3) == 0 then
				LookAt(M.Object3, M.Object1, 0);
				Goto(M.Object1, "RecyclerFollow", 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 15;
			end
		elseif M.Routine1State == 30 then
			AudioMessage("fc01_08.wav");	--Thanatos:"The authorization codes are working..."
			Follow(M.Object3, M.Object1, 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 31 then
			ClearObjectives();
			AddObjective(_Text14, "white");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 32 then	--LOC_138
			if GetDistance(M.Object1, "UnallyPoint") < 60 then
				UnAlly(2,3);
				UnAlly(2,4);
				SetPerceivedTeam(M.Object2, 1);
				Goto(M.Object9, M.Object1, 0);
				Goto(M.Object10, M.Object1, 0);
				Goto(M.Object11, M.Object1, 0);
				Goto(M.Object12, M.Object1, 0);
				Defend2(M.Object3, M.Object2, 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 6;
			end
		elseif M.Routine1State == 33 then
			AudioMessage("fc01_09.wav");	--Cerberi:"Return the procreator immediately and prepare to be liquidated..."
			ClearObjectives();
			AddObjective(_Text13, "white");
			M.CheckThanatos = false;	--added check to make sure player doesn't backstab Thanatos before this point
			BuildObject("AuroraBolt", 2, "Bolt2");
			BuildObject("AuroraBolt", 2, "Bolt3");
			BuildObject("AuroraBolt", 2, "Bolt6");
			BuildObject("AuroraBolt", 2, "Bolt8");
			BuildObject("AuroraBolt", 2, "Bolt9");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 34 then		--LOC_156
			if not IsAround(M.Object9) and not IsAround(M.Object10) 
			and not IsAround(M.Object11) and not IsAround(M.Object12) then
				ClearObjectives();
				Goto(M.Object1, "RecyclerNext", 0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 5;
			end
		elseif M.Routine1State == 35 then
			AudioMessage("fc01_10.wav");	--Miller:"We've laid a trap for that drone carrier..."
			ClearObjectives();
			AddObjective(_Text5, "white");
			M.Routine4Active = true;--RunSpeed,_Routine4,1,true
			M.Object13 = BuildObject("ibnav", 1, "SoldierMeet");
			SetObjectiveName(M.Object13, "Lure Carrier and Drones Here!");
			SetObjectiveOn(M.Object13);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 4;
		elseif M.Routine1State == 36 then
			SetTeamNum(M.Object3, 4);
			SetTeamNum(M.Object4, 4);
			SetTeamNum(M.Object5, 4);
			SetTeamNum(M.Object6, 4);
			SetTeamNum(M.Object7, 4);
			Follow(M.Object3, M.Object2, 0);
			Follow(M.Object4, M.Object2, 0);
			Follow(M.Object5, M.Object2, 0);
			Follow(M.Object6, M.Object2, 0);
			Follow(M.Object7, M.Object2, 0);
			--Follow(M.Object8, M.Object2, 0);	--Object8 does not exist!
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 37 then	--LOC_182
			if GetCurrentCommand(M.Object1) == 0 then
				Stop(M.Object3, 0);
				M.CanLoseShip = true;--RunSpeed,_Routine3,0,true
				Dropoff(M.Object1, "RecyclerDeploy", 1);
				M.Routine1State = M.Routine1State + 1;
			end 
		elseif M.Routine1State == 38 then	--LOC_187
			if GetCfg(M.Object1) ~= "evrecy_m" then
				--M.Variable10 = -GetTime();	--??
				SetScrap(3, 40);
				M.Routine8Active = true;--RunSpeed,_Routine8,1,true
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 39 then	--LOC_193
			if not IsAround(M.Object24) then
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 3;
			end
		elseif M.Routine1State == 40 then
			RemoveObject(M.Object13);
			Patrol(M.Object3, "Patrol1", 0);
			Patrol(M.Object4, "Patrol1", 0);
			Patrol(M.Object5, "Patrol1", 0);
			Patrol(M.Object6, "Patrol1", 0);
			Patrol(M.Object7, "Patrol1", 0);
			AudioMessage("fc01_11.wav");	--Thanatos:"Excellent work, Talon Corber..."
			M.Object9 = BuildObject("cvtank", 2, "Cerb1");
			Goto(M.Object9, M.Object1, 0);
			M.Object10 = BuildObject("cvtank", 2, "Cerb2");
			Goto(M.Object10, M.Object1, 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 60;
		elseif M.Routine1State == 41 then	--LOC_208
			if not IsAround(M.Object9) and not IsAround(M.Object10) then
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 10;
			end
		elseif M.Routine1State == 42 then
			AudioMessage("fc01_11b.wav");	--SciWizard:"The Crucible guards a Research Node crucial to the Cerberi Weapons development program..."
			ClearObjectives();
			AddObjective(_Text7, "white");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 10;
		elseif M.Routine1State == 43 then
			M.Routine9Active = true;--RunSpeed,_Routine9,1,false
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 600;
		elseif M.Routine1State == 44 then
			M.Position1 = TerrainFloor(M.Position1) + SetVector(0, 40, 0);
			M.Object14 = BuildObject("aurora1", 2, M.Position1);
			M.Object15 = BuildObject("aurora2", 2, M.Position1);
			M.Object16 = BuildObject("aurora3", 2, M.Position1);
			M.Object17 = BuildObject("aurorafield", 2, M.Position1);
			M.Position2 = TerrainFloor(M.Position2) + SetVector(0, 40, 0);
			M.Object31 = BuildObject("ibnav", 1, "Investigate1");
			SetObjectiveName(M.Object31, "Energy Disturbance");
			SetObjectiveOn(M.Object31);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 45 then	--LOC_230
			AudioMessage("fc01_12.wav");	--Thanatos:"Our SciWizards have detected a strange energy signature nearby..."
			ClearObjectives();
			AddObjective(_Text2, "white");
			M.Variable2 = GetTime() + 35;
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 46 then
			if GetDistance(M.Object2, M.Object31) < 60 then
				ClearObjectives();
				AddObjective(_Text2, "green");
				AudioMessage("fc01_12A.wav");	--SciWizard:"Your scout's sensors have just detected a teleportation..."
				M.Routine1State = M.Routine1State + 1;
			elseif M.Variable2 < GetTime() then
				M.Variable12 = M.Variable12 + 1;
				if M.Variable12 < 5 then
					M.Routine1State = M.Routine1State - 1;
				else
					AudioMessage("fc01_13.wav");	--Thanatos:"You have failed to investigate the energy source..."
					ClearObjectives();
					AddObjective(_Text3, "red");
					FailMission(GetTime() + 30);	--(bumped up from 10s) TODO: custom failure text for this condition
					M.MissionOver = true;
					M.Routine1State = 99;
				end
			end
		elseif M.Routine1State == 47 then	--LOC_250
			local h = TeleportIn("cvtank", 2, M.Object14, 30);
			SetAngle(h, 8000);
			Goto(h, M.Object1, 0);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 48 then
			if GetTime() < 2000 then
				local h = TeleportIn("cvrbomb",2,M.Object14, 30);
				Goto(h, M.Object1, 0);
				M.Routine1Timer = GetTime() + 20;
			end
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 49 then	--LOC_261
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 110;
		elseif M.Routine1State == 50 then
			local h = TeleportIn("cvtank", 2, M.Object14, 30);
			SetAngle(h, 8000);
			Attack(h, M.Object1, 0);
			local h = TeleportIn("cvrbomb", 2, M.Object14, 30);
			SetAngle(h, 10000);
			Goto(h, M.Object1, 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 110;
		elseif M.Routine1State == 51 then
			local h = TeleportIn("cvdcar", 2, M.Object14, 30);
			SetAngle(h, 1500);
			if GetTime() < 2300 or M.Variable1 == 1 then
				SetMaxHealth(h, 5500);
				SetCurHealth(h, 5500);
			else
				SetMaxHealth(h, 6750);
				SetCurHealth(h, 6750);
			end
			Goto(h, M.Object1, 0);
			M.Routine1State = 47;--to LOC_250
			M.Routine1Timer = GetTime() + 110;
		end
	end
end

--Code for Miller's soldiers ambushing the Cerb drone carrier
function Routine4()
	if M.Routine4Active and M.Routine4Timer < GetTime() then
		if M.Routine4State == 0 then
			if not IsAround(M.Object24) then
				M.Routine4State = 4;--to LOC_323
			elseif GetWhoShotMe(M.Object24) == M.Object2 then
				SetIndependence(M.Object24, 0);
				FireAt(M.Object24, nil);
				Follow(M.Object24, M.Object2, 1);
				ClearObjectives();
				AddObjective("DEBUG: dcar aggroed.");
				M.Routine4State = M.Routine4State + 1;
			end
		elseif M.Routine4State == 1 then
			if not IsAround(M.Object24) then
				M.Routine4State = 4;--to LOC_323
			elseif GetDistance(M.Object2, "SoldierMeet") < 100 then
				ClearObjectives();
				SetIndependence(M.Object24, 0);
				FireAt(M.Object24, nil);
				AddObjective("DEBUG: dcar heading to ambush.");
				Goto(M.Object24, "SoldierMeet", 1);
				M.Routine4State = M.Routine4State + 1;
			end
		elseif M.Routine4State == 2 then
			if not IsAround(M.Object24) then
				M.Routine4State = 4;--to LOC_323
			elseif GetDistance(M.Object24, "SoldierMeet") < 80 then
				FireAt(M.Object24, nil);
				--SetIndependence(M.Object24, 1);
				--Goto(M.Object24, "SoldierMeet", 0);
				M.Routine4State = M.Routine4State + 1;
			end
		elseif M.Routine4State == 3 then	--LOC_313
			if not IsAround(M.Object24) then
				M.Routine4State = M.Routine4State + 1;--to LOC_323
			else
				BuildObject("chainmin", 1, "Mine0");
				BuildObject("chainmin", 1, "Mine1");
				BuildObject("chainmin", 1, "Mine2");
				BuildObject("chainmin", 1, "Mine3");
				BuildObject("chainmin", 1, "Mine4");
				M.Variable3 = M.Variable3 + 1;
				if M.Variable3 == 1 then
					FireAt(M.Object24, nil);
				elseif M.Variable3 == 2 then
					SetIndependence(M.Object24, 1);
				elseif M.Variable3 >= 5 then
					M.Routine4State = M.Routine4State + 1;
				end
				M.Routine4Timer = GetTime() + 15;
			end
		elseif M.Routine4State == 4 then	--LOC_323
			--M.Variable3 = 0;
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 60;
		elseif M.Routine4State == 6 then	--LOC_325
			for i = 0,NUM_SOLDIERS do
				local h = GetHandle(string.format("Soldier%i", i));
				if IsAround(h) then
					M.Variable13 = M.Variable13 + 1;
					if M.Variable13 < 3 then
						Goto(h, string.format("SoldierDest%i", M.Variable13), 0);
					else
						RemoveObject(h);
					end
				end
			end
			M.Routine4State = M.Routine4State + 1;
		end
	end
end

--Sets the AIP of the Hadean team according to which units should be built
--Starts when Hadean Procreator is deployed.
function Routine8()
	if M.Routine8Active and M.Routine8Timer < GetTime() then
		if M.Routine8State == 0 then
			if not IsAround(M.Object26) then
				SetAIP("fc01_1h.aip", 3);
				ClearObjectives();
				AddObjective(_Text8, "white");
				M.Routine8State = M.Routine8State + 1;
			else
				M.Routine8State = M.Routine8State + 2;
			end
		elseif M.Routine8State == 1 then	--LOC_461
			if M.Variable8 > 0 then
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 2 then	--LOC_465
			M.Routine10Active = true;--RunSpeed,_Routine10,1,true
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 3 then	--LOC_466
			if M.Variable8 < M.Variable9 then
				SetAIP("fc01_1h.aip", 3);
				M.Routine8State = 8;--to LOC_493
			elseif M.Variable4 < M.Variable5 then
				SetAIP("fc01_2h.aip", 3);
				M.Routine8State = 7;--to LOC_489
			elseif CountUnitsNearObject(M.Object1, M.Variable18, 3, "ebsbay") > 0 and M.Variable6 < M.Variable7 then
				SetAIP("fc01_3h.aip", 3);
				M.Routine8State = 6;--to LOC_485
			else
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 4 then	--LOC_474
			SetAIP("fc01_0h.aip", 3);
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 5 then
			if M.Variable8 < M.Variable9 then
				SetAIP("fc01_1h.aip", 3);
				M.Routine8State = 8;--to LOC_493
			elseif M.Variable4 < M.Variable5 then
				SetAIP("fc01_2h.aip", 3);
				M.Routine8State = 7;--to LOC_489
			elseif CountUnitsNearObject(M.Object1, M.Variable18, 3, "ebsbay") > 0 and M.Variable6 < M.Variable7 then
				SetAIP("fc01_3h.aip", 3);
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 6 then	--LOC_485
			if M.Variable6 >= M.Variable7 then
				M.Routine8State = 3;--to LOC_466
			end
		elseif M.Routine8State == 7 then	--LOC_489
			if M.Variable4 >= M.Variable5 then
				M.Routine8State = 3;--to LOC_466
			end
		elseif M.Routine8State == 8 then	--LOC_493
			if M.Variable8 >= M.Variable9 then
				M.Routine8State = 3;--to LOC_466
			end
		end
	end
end

--Switches the Cerb AIP if Hadean assault tanks are close to their Foundry
function Routine9()
	if M.Routine9Active and M.Routine9Timer < GetTime() then
		if M.Routine9State == 0 then	--LOC_497
			SetAIP("fc01_0C.aip", 2);
			M.Variable14 = 1100;
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 1 then	--LOC_499
			if CountUnitsNearObject(M.Object33, M.Variable14, 3, "evatank") > 0 then
				SetAIP("fc01_1C.aip", 2);
				M.Variable14 = 1300;
				M.Routine9State = M.Routine9State + 1;
				M.Routine9Timer = GetTime() + 2;
			else
				M.Routine9Timer = GetTime() + 2;
			end
		elseif M.Routine9State == 2 then	--LOC_504
			AddScrap(2,1);
			if CountUnitsNearObject(M.Object33, M.Variable14, 3, "evatank") > 0 then
				M.Routine9Timer = GetTime() + 2;
			else
				M.Routine9State = 0;
			end
		end
	end
end

--Gradually increments the target number of ships to be built by the Hadean team
--Builds 2 portals which spawn Cerb units
function Routine10()
	if M.Routine10Active and M.Routine10Timer < GetTime() then
		if M.Routine10State == 0 then
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 180;
		elseif M.Routine10State == 1 then
			M.Variable9 = M.Variable9 + 1;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 180;
		elseif M.Routine10State == 2 then
			M.Variable5 = M.Variable5 + 1;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 250;
		elseif M.Routine10State == 3 then
			M.Variable9 = M.Variable9 + 1;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 20;
		elseif M.Routine10State == 4 then
			M.Variable5 = M.Variable5 + 2;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 360;
		elseif M.Routine10State == 5 then
			M.Variable9 = M.Variable9 + 1;
			M.Variable5 = M.Variable5 + 1;
			M.Variable7 = M.Variable7 + 1;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 300;
		elseif M.Routine10State == 6 then
			M.Variable9 = M.Variable9 + 1;
			M.Variable5 = M.Variable5 + 1;
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 240;
		elseif M.Routine10State == 7 then
			M.Variable7 = M.Variable7 + 1;
			M.Position2 = TerrainFloor(M.Position2) + SetVector(0, 40, 0);
			M.Position3 = TerrainFloor(M.Position3) + SetVector(0, 40, 0);
			M.Routine10State = M.Routine10State + 1;
		elseif M.Routine10State == 8 then	--LOC_531
			M.Object18 = BuildObject("aurora1", 2, BuildDirectionalMatrix(M.Position3));
			M.Object19 = BuildObject("aurora2", 2, BuildDirectionalMatrix(M.Position3));
			M.Object20 = BuildObject("aurora3", 2, BuildDirectionalMatrix(M.Position3));
			M.Object21 = BuildObject("aurorafield", 2, BuildDirectionalMatrix(M.Position3));
			AudioMessage("fc01_15.wav");	--Thanatos:"The Cerberi have created one of their energy portals near our base..."
			ClearObjectives();
			AddObjective(_Text11, "white");
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 60;
		elseif M.Routine10State == 9 then
			M.Routine11Active = true;--RunSpeed,_Routine11,1,true
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 250;
		elseif M.Routine10State == 10 then
			M.Routine11Active = false;--RunSpeed,_Routine11,0,true
			RemoveObject(M.Object18);
			RemoveObject(M.Object19);
			RemoveObject(M.Object20);
			RemoveObject(M.Object21);
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 240;
		elseif M.Routine10State == 11 then
			M.Variable19 = 1;
			M.Object18 = BuildObject("aurora1", 2, BuildDirectionalMatrix(M.Position2));
			M.Object19 = BuildObject("aurora2", 2, BuildDirectionalMatrix(M.Position2));
			M.Object0 = BuildObject("aurora3", 2, BuildDirectionalMatrix(M.Position2));
			M.Object21 = BuildObject("aurorafield", 2, BuildDirectionalMatrix(M.Position2));
			ClearObjectives();
			AddObjective(_Text11, "white");
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 60;
		elseif M.Routine10State == 12 then
			M.Routine11Active = true;--RunSpeed,_Routine11,1,true
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 250;
		elseif M.Routine10State == 13 then
			M.Routine11Active = false;--RunSpeed,_Routine11,0,true
			RemoveObject(M.Object18);
			RemoveObject(M.Object19);
			RemoveObject(M.Object20);
			RemoveObject(M.Object21);
			M.Routine10State = 8;--to LOC_531
			M.Routine10Timer = GetTime() + 300;
		end	
	end
end

--teleports in a Cerb walker every 35s from the currently active portal
function Routine11()
	if M.Routine11Active and M.Routine11Timer < GetTime() then
		M.Object23 = TeleportIn("cvwalk", 2, M.Object18, 10);
		if M.Variable19 == 1 then
			SetAngle(M.Object23, 18000);
		end
		Goto(M.Object23, M.Object1, 0);
		M.Routine11Timer = GetTime() + 35;
	end
end

--Sets team of new object to 1 twice?? Seems redundant.
--function Routine13()
--	if GetTeamNum(M.Object40) ~= 1 then
--		SetTeamNum(M.Object40, 1);
--	end
--end

--sends groups of Hadean atanks against Cerb gtows
function Routine14()
	if M.Routine14Active and M.Routine14Timer < GetTime() then
		if M.Routine14State == 0 then	--LOC_603
			if IsAround(M.Object41[1]) and IsAround(M.Object41[2]) and IsAround(M.Object41[3]) then
				M.Object45 = nil;
				for i = 1,NUM_GTOWS do
					if IsAround(M.Object35[i]) then
						M.Object45 = M.Object35[i];
						break;
					end
				end
				M.Routine14Active = (M.Object45 ~= nil);	--stop sending waves if final gtow is destroyed
				M.Routine14State = M.Routine14State + 1;
			end
		elseif M.Routine14State == 1 then
			if (not IsAround(M.Object41[1]) or GetDistance(M.Object41[1], M.Object33) < 700 or GetCurrentCommand(M.Object41[1]) ~= 3)
			and (not IsAround(M.Object41[2]) or GetDistance(M.Object41[2], M.Object33) < 700 or GetCurrentCommand(M.Object41[2]) ~= 3)
			and (not IsAround(M.Object41[3]) or GetDistance(M.Object41[3], M.Object33) < 700 or GetCurrentCommand(M.Object41[3]) ~= 3) then
				M.Variable1 = 1;
				AudioMessage("fc01_14.wav");	--Thanatos:"The assault tanks are moving to attack the Gun Towers..."
				SetObjectiveName(M.Object45, "Targeted Gun Tower");
				SetObjectiveOn(M.Object45);
				if GetDistance(M.Object45, M.Object41[1]) > 400 or
				   GetDistance(M.Object45, M.Object41[2]) > 400 or
				   GetDistance(M.Object45, M.Object41[3]) > 400 then
					Goto(M.Object41[1], "StagePoint1B", 0);
					Goto(M.Object41[2], "StagePoint2B", 0);
					Goto(M.Object41[3], "StagePoint3B", 0);
					M.Routine14State = M.Routine14State + 1;
				else
					M.Routine14State = M.Routine14State + 2;--to LOC_648
			    end
			end
		elseif M.Routine14State == 2 then	--LOC_642
			if GetCurrentCommand(M.Object41[1]) == 0 and 
			   GetCurrentCommand(M.Object41[2]) == 0 and 
			   GetCurrentCommand(M.Object41[3]) == 0 then
				M.Routine14State = M.Routine14State + 1;
			end
		elseif M.Routine14State == 3 then	--LOC_648
			Attack(M.Object41[1], M.Object45, 0);
			Attack(M.Object41[2], M.Object45, 0);
			Attack(M.Object41[3], M.Object45, 0);
			M.Routine14State = M.Routine14State + 1;
		elseif M.Routine14State == 4 then	--LOC_651
			if GetCurrentCommand(M.Object41[1]) ~= 4 and 
			   GetCurrentCommand(M.Object41[2]) ~= 4 and 
			   GetCurrentCommand(M.Object41[3]) ~= 4 then 
				SetObjectiveName(M.Object45, "Gun Tower");
				SetObjectiveOff(M.Object45);
				M.Variable1 = 0;
				if GetDistance(M.Object41[1], M.Object33) < 400 then
					Goto(M.Object41[1], "StagePoint1B", 0);
				end
				if GetDistance(M.Object41[2], M.Object33) < 400 then
					Goto(M.Object41[2], "StagePoint2B", 0);
				end
				if GetDistance(M.Object41[3], M.Object33) < 400 then
					Goto(M.Object41[3], "StagePoint3B", 0);
				end
				M.Routine14State = 0;--to LOC_603
			end
		end
	end
end

--Sets any pilots ejected from player controlled Hadean ships back to team 3
--function HandleEjectedPilots()
--	if table.getn(M.EjectedPilots) > 0 then
--		local pilot = M.EjectedPilots[1];
--		SetTeamNum(pilot, 3);
--		table.remove(M.EjectedPilots, 1);
--	end
--end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if not IsAround(M.Object1) then
			ClearObjectives();
			AddObjective(_Text4, "red");
			AudioMessage("fc01_16.wav");	--Thanatos:"You failed to defend the base..."
			FailMission(GetTime() + 13, "FC01L1.txt");
			M.MissionOver = true;
		elseif not M.CanLoseShip and not IsAround(M.Object26) then
			ClearObjectives();
			AddObjective(_Text6, "red");
			FailMission(GetTime() + 10, "FC01L2.txt");
			M.MissionOver = true;
		elseif M.CheckThanatos and not IsAlive(M.Object3) then
			--Player is a traitor and shot Thanatos
			ClearObjectives();
			AddObjective(_Text15, "red");
			FailMission(GetTime() + 10);	--TODO: write some text chastising the player
			M.MissionOver = true;
		elseif not (IsAround(M.Object35[1]) or IsAround(M.Object35[2]) 
				   or IsAround(M.Object35[3]) or IsAround(M.Object35[4]) 
				   or IsAround(M.Object35[5])) then
			M.Routine10Active = false;
			AudioMessage("fc01_18.wav");	--Thanatos:"The last Gun Tower has been destroyed..."
			ClearObjectives();
			AddObjective(_Text10, "green");
			SucceedMission(GetTime() + 30, "FC01W1.txt");
			M.MissionOver = true;
		end
	end
end

function TeleportIn(odf,  team,  dest, offset)
	if IsAround(dest) then
		local pos = GetPosition(dest);
		pos.x = pos.x + offset;
		--pos.y = TerrainFindFloor(pos.x, pos.z) + 5;
		BuildObject("teleportin",  0,  pos);
		return BuildObject(odf,  team,  pos);
	else
		return nil;
	end
end

function TerrainFloor(pos)
	return SetVector(pos.x, TerrainFindFloor(pos), pos.z);
end
