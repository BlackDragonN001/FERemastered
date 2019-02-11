assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

--Constants
local KAMI_WAVE1_COUNT = 8;
local KAMI_WAVE2_COUNT = 4;
local KAMI_SPAWN_DELAYS = {4,3,2,2,2,1,1,1};
local REINFORCEMENTS1 = {"evtank_15","evtank_15","evtank_15","evserv"};
local GROUPS1 = {4,4,4,5};
local REINFORCEMENTS2 = {"evtank_15","evtank_15","evtank_15", "evartl_15", "evturr", "evturr", "evserv"};
local GROUPS2 = {4,4,4,8,9,9,5};

--Strings
local _Text1 = "Scout the tunnel entrance that\nleads toward the Wormhole Control\nCenter. We need intel on enemy\ndefenses before we can attack.";
local _Text2 = "Captain Schultz will remain\nbehind to erect base defenses\nand assemble an assault force.";
local _Text3 = "      !E!M!E!R!G!E!N!C!Y!      \n !!RETURN TO BASE IMMEDIATELY!! ";
local _Text4 = "Hurry to Nav Beta, so you can\ndisable the Hadean defense grid\nby uploading Eisenstein's virus.";
local _Text5 = "You need to get out of your\nvehicle and stand within 40\nmeters of the Defense Nerve in\norder for the transmitter to\noverride the normal signal.";
local _Text6 = "Head to Nav Gamma, where Hadean\nrebel dropships will periodically\nland to unload reinforcements.";
local _Text7 = "More troops will land every 5\nminutes. Your task is to destroy\nthe Cerberi Recycler while our\nallies attack the tunnel as a\ndiversion.";
local _Text8 = "Uploading ARMAGEDDON II virus.";
local _Text9 = "ARMAGEDDON II virus uploaded\nand installed. . . . . . . .\nHadean automated defense system\noperating at 75 percent\n effectiveness.";
local _Text10 = "Hadean automated defense system\noperating at 50 percent\n effectiveness.";
local _Text11 = "Hadean automated defense system\noperating at 25 percent\n effectiveness.";
local _Text12 = "Hadean automated defense system\noperating at 10 percent\n effectiveness. Dropships are\nnow on final approach.";
local _Text13 = "Proceed to Nav Gamma if you wish\nto help the Hadean Rebels defeat\nthe Cerberi. Otherwise, head to\nthe tunnel entrance to stay with\nthe EDF.";

local M = {
-- Bools
	MissionOver = false,
	Routine2Active = false,
	Routine3Active = false,
	Routine4Active = false,
	Routine5Active = false,
	Routine7Active = false,
	SchultzInvincible = false,
	
-- Floats
	Routine1Timer = 0.0,
	Routine2Timer = 0.0,
	Routine3Timer = 0.0,
	Routine5Timer = 0.0,
	Routine7Timer = 0.0,

-- Handles
	Recycler = nil,
	Player = nil,
	CerbRecy = nil,
	Jammer = nil,
	Nerve = nil,
	Schultz = nil,
	Constructor = nil,	--Empty Constructor in player base
	TunnelEntranceNav = nil,
	NavBeta = nil,
	NavGamma = nil,
	HadeanDropship = nil,
	CerbMinelayer = nil,
	EdfNav = nil,
	HadeanNav = nil,
-- Ints
	TPS = 10,
	Routine1State = 0,
	Routine2State = 0,
	Routine3State = 0,
	Routine4State = 0,
	Routine5State = 0,
	Routine7State = 0,
	Variable6 = 0,	--Nerve upload percentage
	Variable7 = 0,	--Recy was destroyed by Kamis
	Variable8 = 0,	--spawn counter
	OldPlayerHealth,	--used to make player invincible during cutscene

--Vectors
	Position2 = nil,	--Xerrakis spawn loc above player recy
	Position5 = nil,	--Hadean reinforcements spawn location
	DropshipPosition = nil,	--Hadean dropship position (Matrix)
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
	
	PreloadODF("ibrecy");
	PreloadODF("evscout");
	PreloadODF("evkami");
	PreloadODF("evtank_15");
	PreloadODF("evartl_15");
	PreloadODF("evwalk_15");
	PreloadODF("evserv");
	PreloadODF("evdrop_l2");
	PreloadODF("evdrop_15a");
	PreloadODF("cbprop10");
	PreloadODF("cvmlay_15");
	PreloadODF("cerbmine");
	
	local preloadAudio = {
		"edf15a.wav",
		"edf15b.wav",
		"edf15c.wav",
		"edf15d.wav",
		"edf15f.wav",
		"edf15h.wav",
		"edf15i.wav",
		"edf15j.wav",
		"edf15k.wav",
		"edf15l.wav",
		"edf15m.wav",
		"edf15n.wav",
		"edf15edf.wav",
		"edf15hadean.wav",
		"edf15_5th.wav",
		"edf15hurry1.wav",
		"edf15hurry2.wav",
		"edf15hurry3.wav"
	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function GetHandleOrDie(name)
	return GetHandle(name) or error("Error: object '"..name.."' not found!", 2);
end

function Start()

	_FECore.Start()

	M.Recycler = BuildObject("ibrecy", 1, BuildDirectionalMatrix(GetPosition("recy")));
	M.CerbRecy = GetObjectByTeamSlot(5, 1);
	M.Jammer = GetHandleOrDie("cbjamm");
	M.Constructor = GetHandleOrDie("cons");
	M.HadeanDropship = GetHandleOrDie("condor");
	M.HadeanNav = GetHandleOrDie("dropnav");
	M.Position2 = GetPosition(M.Recycler);
	M.Position5 = GetPosition(M.HadeanNav);
	M.DropshipPosition = GetTransform(M.HadeanDropship);
	RemoveObject(M.HadeanDropship);
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)
	
	_FECore.AddObject(h);
	
end

function Update()

	_FECore.Update();

	M.Player = GetPlayerHandle();
	Routine1();
	Routine2();
	Routine3();
	Routine4();
	Routine5();
	Routine7();
	
	--keeps Schultz alive during cutscene
	if M.SchultzInvincible then
		SetCurHealth(M.Constructor, GetMaxHealth(M.Constructor));
	end
end

--main mission state.
function Routine1()
	if M.Routine1Timer < GetTime() then
		if M.Routine1State == 0 then
			M.Player = ReplaceObject(M.Player, "ivtank");
			GiveWeapon(M.Player, "gbchain_c");
			AudioMessage("edf15a.wav");	--Eisenstein:"The Excluder Jammer seems to be working perfectly..."
			M.SchultzInvincible = true;--RunSpeed,_Routine9,1,true
			SetScrap(1, 40);
			SetScrap(5, 40);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 25;
		elseif M.Routine1State == 1 then
			SetAIP("edf15.aip", 5);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 2 then
			M.Routine5Active = true;
			M.NavBeta = BuildObject("ibnav", 1, "navbeta");
			SetObjectiveName(M.NavBeta, "Nav Beta");
			SetObjectiveOn(M.NavBeta);
			M.Nerve = BuildObject("cbprop10", 5, "nerve");
			Attack(BuildObject("evscout", 5, "tunnel"), M.Player, 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 45;
		elseif M.Routine1State == 3 then
			AudioMessage("edf15b.wav");	--Stewart:"There's been a change in plans. Your tank's sensors just picked up a tunnel entrance nearby..."
			ClearObjectives();
			AddObjective(_Text1, "white");
			AddObjective(_Text2, "white");
			SetObjectiveOff(M.NavBeta);
			M.TunnelEntranceNav = BuildObject("ibnav", 1, "tunnel");
			SetObjectiveName(M.TunnelEntranceNav, "Tunnel Entrance");
			SetObjectiveOn(M.TunnelEntranceNav);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 50;
		elseif M.Routine1State == 4 then
			M.Routine7Active = true;--RunSpeed,_Routine7,1,true
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 5 then	--LOC_28
			if GetDistance(M.Player, M.TunnelEntranceNav) < 400 then
				AddHealth(M.Constructor, 500);
				SetObjectiveOff(M.TunnelEntranceNav);
				M.Routine7Active = false; --M.Variable5 = 1;
				SetPerceivedTeam(M.Player, 5);
				M.Routine4Active = true;--M.Variable1 = 1;
				M.Schultz = BuildObject("ispilo", 1, "shulz");	--changed Schultz to be an ispilo instead of espilo
				Goto(M.Schultz, M.Constructor, 1);
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 6 then	--LOC_37
			if GetDistance(M.Schultz, M.Constructor) < 8 then
				RemoveObject(M.Schultz);
				AudioMessage("edf15c.wav");	--Stewart:"Captain Schultz, get back here with that constructor!..."
				SetAnimation(M.Constructor, "startup", 1);
				StartAnimation(M.Constructor);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 5;
			end
		elseif M.Routine1State == 7 then
			M.Constructor = ReplaceObject(M.Constructor, "ivpcon", -1, 0.0, 0);
			Goto(M.Constructor, "demolish", 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 8 then
			RemoveObject(GetNearestEnemy(M.Constructor));--RunSpeed,_Routine10,1,true
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 9 then	--LOC_48
			if GetDistance(M.Constructor, GetPosition("demolish")) < 15 then
				SetAnimation(M.Constructor, "cons2", 1);
				StartAnimation(M.Constructor);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 1;
			end
		elseif M.Routine1State == 10 then
			RemoveObject(M.Jammer);
			EjectPilot(M.Constructor);
			M.SchultzInvincible = false;--RunSpeed,_Routine9,0,false
			AudioMessage("edf15d.wav");	--Stewart:"Captain Schultz, what the HELL are you doing?!..."
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 11 then	--LOC_57
			if not M.Routine4Active then
				SetPerceivedTeam(M.Player, 1);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 5;
			end
		elseif M.Routine1State == 12 then
			Attack(BuildObject("evscout", 5, "attack1"), M.Player, 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 25;
		elseif M.Routine1State == 13 then
			Attack(BuildObject("evscout", 5, "attack1"), M.Player, 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 20;
		elseif M.Routine1State == 14 then
			AudioMessage("edf15f.wav");	--Stewart:"We're undeploying the Vengeance and getting out of here..."
			ClearObjectives();
			AddObjective(_Text3, "white");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 30;
		elseif M.Routine1State == 15 then
			M.Variable7 = 1;
			AudioMessage("edf15h.wav");	--Hardin:"Col. Stewart, drop everything and get out of there..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 20;
		elseif M.Routine1State == 16 then
			Attack(BuildObject("evkami", 5, "attack1"), M.Recycler, 1);
			M.Variable8 = M.Variable8 + 1;
			if M.Variable8 == KAMI_WAVE1_COUNT then
				M.Variable8 = 0;
				M.Position2 = M.Position2 + SetVector(50, 100, 100);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 1;
			else
				M.Routine1Timer = GetTime() + KAMI_SPAWN_DELAYS[M.Variable8];
			end
		elseif M.Routine1State == 17 then	--LOC_98
			Attack(BuildObject("evkami", 5, M.Position2), M.Recycler, 1);
			M.Variable8 = M.Variable8 + 1;
			if M.Variable8 == KAMI_WAVE2_COUNT or not IsAround(M.Recycler) then
				RemoveObject(M.Recycler);
				M.Routine1State = M.Routine1State + 1;
			end
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 18 then
			AudioMessage("edf15i.wav");	--Hardin:"Aww that's it. The Vengeance is gone..."
			ClearObjectives();
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 90;
		elseif M.Routine1State == 19 then
			AddObjective(_Text4, "white");
			SetObjectiveOn(M.NavBeta);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 20 then	--LOC_115
			if GetDistance(M.Player, M.NavBeta) < 150 then
				ClearObjectives();
				AddObjective(_Text5, "white");
				AudioMessage("edf15j.wav");	--Eisenstein:"The transmitter's signal won't penetrate the hull of your tank..."
				SetObjectiveOn(M.Nerve);
				M.Routine1State = M.Routine1State + 1;
			end	
		elseif M.Routine1State == 21 then	--LOC_132
			if GetDistance(M.Player, M.Nerve) < 40 and IsPerson(M.Player) then
				M.Variable6 = M.Variable6 + 4;
				SetObjectiveName(M.Nerve, "Nerve: "..tostring(M.Variable6).."% Complete");
				if M.Variable6 >= 100 then					
					M.Routine1State = M.Routine1State + 1;
					M.Routine1Timer = GetTime() + 3;
				else
					M.Routine1Timer = GetTime() + 0.3;
				end
			end
		elseif M.Routine1State == 22 then
			ClearObjectives();
			AddObjective(_Text9, "green");
			SetObjectiveOff(M.NavBeta);
			SetObjectiveOff(M.Nerve);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 23 then
			ClearObjectives();
			AddObjective(_Text10, "green");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 24 then
			ClearObjectives();
			AddObjective(_Text11, "green");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 25 then
			ClearObjectives();
			AddObjective(_Text12, "green");
			AudioMessage("edf15k.wav");	--Eisenstein:"Great job sir. The virus is already working..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 10;
		elseif M.Routine1State == 26 then
			ClearObjectives();
			AddObjective(_Text6, "white");
			M.NavGamma = BuildObject("ibnav", 1, "gamma");
			SetObjectiveName(M.NavGamma, "Nav Gamma");
			SetObjectiveOn(M.NavGamma);
			M.HadeanDropship = BuildObject("evdrop_L2", 1, M.DropshipPosition);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 30;
		elseif M.Routine1State == 27 then	--LOC_162
			if GetDistance(M.Player, M.NavGamma) < 200 then
				SetAnimation(M.HadeanDropship, "land", 1);
				StartAnimation(M.HadeanDropship);
				AudioMessage("droptoff.wav");	--"dropoff.wav" doesn't exist!
				M.Position5.y = M.Position5.y + 5;
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 12;
			end
		elseif M.Routine1State == 28 then
			M.HadeanDropship = ReplaceObject(M.HadeanDropship, "evdrop_15a");
			SetAnimation(M.HadeanDropship, "deploy", 1);
			StartAnimation(M.HadeanDropship);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 29 then
			AudioMessage("dropdoor.wav");
			M.Variable8 = 0;
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 4;
		elseif M.Routine1State == 30 then
			M.Variable8 = M.Variable8 + 1;
			local h = BuildObject(REINFORCEMENTS1[M.Variable8], 1, BuildDirectionalMatrix(M.Position5));
			Goto(h, "units", 0);
			SetGroup(h, GROUPS1[M.Variable8]);
			if M.Variable8 == #REINFORCEMENTS1 then
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 5;
			else
				M.Routine1Timer = GetTime() + 1;
			end
		elseif M.Routine1State == 31 then
			M.Routine2Active = true;--M.Variable4 = 1;
			ClearObjectives();
			AddObjective(_Text7, "white");
			AudioMessage("edf15l.wav");	--Thanatos:"Our dropships will be landing every 5 minutes..."
			SetObjectiveOn(M.CerbRecy);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 32 then
			if not IsAround(M.CerbRecy) then
				AudioMessage("edf15m.wav");	--Thanatos:"General Hardin, I am honored to announce the first victory of our combined forces..."
				ClearObjectives();
				AddObjective(_Text7, "green")
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 70;
			end
		elseif M.Routine1State == 33 then
			AudioMessage("edf15n.wav");	--Hardin:"Maj. Corber, I have some interesting news for you..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 45;
		elseif M.Routine1State == 34 then
			ClearObjectives();
			local h = BuildObject("ibnav", 1, "tunnel");
			SetObjectiveName(h, "Tunnel");
			SetObjectiveOn(h);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 35 then
			local h = BuildObject("ibnav", 1, BuildDirectionalMatrix(M.Position5));
			SetObjectiveName(h, "Hadean Drop Ship");
			SetObjectiveOn(h);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 36 then
			AddObjective(_Text13, "white");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 4;
		elseif M.Routine1State == 37 then	--LOC_217
			if GetDistance(M.Player, M.Position5) < 150 then
				ChangeSide();
				AudioMessage("edf15hadean.wav");	--Thanatos:"Welcome Major Corber..."
				SucceedMission(GetTime() + 18, "edf15hadean.txt");
				M.Routine1State = M.Routine1State + 1;
			elseif GetDistance(M.Player, "tunnel") < 150 then
				AudioMessage("edf15edf.wav");	--Hardin:"Welcome back Joseph..."
				SucceedMission(GetTime() + 13, "edf15edf.txt");
				M.Routine1State = M.Routine1State + 1;
			end
		end
	end
end

--spawns Hadean reinforcements via dropship every 5 min
function Routine2()
	if M.Routine2Active and M.Routine2Timer < GetTime() then
		if M.Routine2State == 0 then
			M.Routine3Active = true;--RunSpeed,_Routine3,1,true
			SetAnimation(M.HadeanDropship, "takeoff", 1);
			StartAnimation(M.HadeanDropship);
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 3;
		elseif M.Routine2State == 1 then	--LOC_241
			AudioMessage("dropleav.wav");
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 300;
		elseif M.Routine2State == 2 then
			RemoveObject(M.HadeanDropship);
			M.HadeanDropship = BuildObject("evdrop_l2", 1, M.DropshipPosition);
			SetAnimation(M.HadeanDropship, "land", 1);
			StartAnimation(M.HadeanDropship);
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 15;
		elseif M.Routine2State == 3 then
			M.HadeanDropship = ReplaceObject(M.HadeanDropship, "evdrop_15a");
			SetCurHealth(M.HadeanDropship, GetMaxHealth(M.HadeanDropship));
			SetAnimation(M.HadeanDropship, "deploy", 1);
			StartAnimation(M.HadeanDropship);
			M.Variable8 = 0;
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 8;
		elseif M.Routine2State == 4 then
			M.Variable8 = M.Variable8 + 1;
			local h = BuildObject(REINFORCEMENTS2[M.Variable8], 1, BuildDirectionalMatrix(M.Position5));
			Goto(h, "units", 0);
			SetGroup(h, GROUPS2[M.Variable8]);
			if M.Variable8 == #REINFORCEMENTS2 then
				M.Routine2State = M.Routine2State + 1;
				M.Routine2Timer = GetTime() + 2;
			else
				M.Routine2Timer = GetTime() + 1;
			end
		elseif M.Routine2State == 5 then
			if IsAround(M.CerbRecy) then
				SetAnimation(M.HadeanDropship, "takeoff", 1);
				StartAnimation(M.HadeanDropship);
				M.Routine2State = 1;--to LOC_241
				M.Routine2Timer = GetTime() + 3;
			else
				--once Cerb recy is destroyed, reinforcements stop, and dropship stays landed.
				M.Routine2State = M.Routine2State + 1;
			end
		end
	end
end	

--Spawns Hadean walkers every 2 min that attack the Cerb base from the Tunnel
function Routine3()
	if M.Routine3Active and M.Routine3Timer < GetTime() then
		if M.Routine3State == 0 then
			Ally(1, 2);
			M.Routine3State = M.Routine3State + 1;
		elseif M.Routine3State == 1 then
			AudioMessage("edf15_5th.wav");	--Thanatos:"I am also deploying several heavy assault walkers to your North West..."
			M.Routine3State = M.Routine3State + 1;
		elseif M.Routine3State == 2 then	--LOC_288
			if IsAround(M.CerbRecy) then
				Goto(BuildObject("evwalk_15", 2, "tunnel"), GetPosition(M.CerbRecy), 0);
				M.Routine3State = M.Routine3State + 1;
				M.Routine3Timer = GetTime() + 1;
			else
				M.Routine3State = 99;
			end
		elseif M.Routine3State == 3 then
			Goto(BuildObject("evwalk_15", 2, "tunnel"), GetPosition(M.CerbRecy), 0);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 1;
		elseif M.Routine3State == 4 then
			Goto(BuildObject("evwalk_15", 2, "tunnel"), GetPosition(M.CerbRecy), 0);
			M.Routine3State = 2;--to LOC_288
			M.Routine3Timer = GetTime() + 120;
		end
	end
end

--Schultz's cutscene
function Routine4()
	if M.Routine4Active then
		if M.Routine4State == 0 then
			M.OldPlayerHealth = GetCurHealth(M.Player);
			Ally(1, 5);
			CameraReady();
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 1 then
			SetCurHealth(M.Player, M.OldPlayerHealth);
			if CameraPath("cam1", 5000, 800, M.Recycler) then
				CameraFinish();
				M.Routine4Active = false;
				UnAlly(1, 5);
				M.Routine4State = M.Routine4State + 1;
			end
		end
	end
end

--handles the Cerb minelayer
function Routine5()
	if M.Routine5Active and M.Routine5Timer < GetTime() then
		if M.Routine5State == 0 then
			M.CerbMinelayer = BuildObject("cvmlay_15", 5, "minelayer");
			SetIndependence(M.CerbMinelayer, 0);
			Patrol(M.CerbMinelayer, "mine1", 1);
			M.Routine5State = 1;
			M.Routine5Timer = GetTime() + 20;
		elseif M.Routine5State == 1 then	--LOC_310
			if IsAround(M.CerbMinelayer) then
				local pos = GetPosition(M.CerbMinelayer);
				pos.y = TerrainFindFloor(pos);
				BuildObject("cerbmine", 5, pos);
				M.Routine5Timer = GetTime() + 4;
			else
				M.Routine5State = 1;
				M.Routine5Timer = GetTime() + 124;
			end
		end
	end
end

--Stewart nagging player to investigate Nav Beta
function Routine7()
	if M.Routine7Active and M.Routine7Timer < GetTime() then
		if M.Routine7State == 0 then
			M.Routine7State = M.Routine7State + 1;
			M.Routine7Timer = GetTime() + 120;
		elseif M.Routine7State == 1 then
			AudioMessage("edf15hurry1.wav");	--Stewart:"Maj. Corber, we need you to scout out that tunnel entrance."
			M.Routine7State = M.Routine7State + 1;
			M.Routine7Timer = GetTime() + 120;
		elseif M.Routine7State == 2 then
			AudioMessage("edf15hurry2.wav");	--Stewart:"We don't have all day for this..."
			M.Routine7State = M.Routine7State + 1;
			M.Routine7Timer = GetTime() + 120;
		elseif M.Routine7State == 3 then
			AudioMessage("edf15hurry3.wav");	--Stewart:"Return to base immediately..."
			ClearObjectives();
			AddObjective(_Text1, "red");
			FailMission(GetTime() + 10, "edf15time.txt");
			M.Routine7State = M.Routine7State + 1;
		end
	end
end


function CheckStuffIsAlive()
	if not M.MissionOver then
		if M.Variable7 == 0 and not IsAround(M.Recycler) then
			ClearObjectives();
			AddObjective(_Text2, "red");
			FailMission(GetTime() + 10, "edf15recy.txt");
			M.MissionOver = true;
		end
	end
end
