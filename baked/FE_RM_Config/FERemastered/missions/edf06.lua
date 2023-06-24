----------------------------------------------------------------
-- FE edf06.lua Mission - Version 1.0
-- Date Modified: 11/01/2021
-- Summary: Mission script for the EDF06 Forgotten Enemies Mission.
----------------------------------------------------------------

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

-- Variables Not saved. Constants that never change.
local AUDIO_MESSAGE_COUNT = 16;
local h	--temp handle

local M = {
-- Bools
	WindexNag = false,
	DoRadioInterference = false,
	DamageHadeans = false,
	CheckTransport = false,

-- Floats
	MissionTimer = 0.0,
	WindexNagTimer = 0.0,
	InterferenceTimer = 0.0,
	DamageHadeansTimer = 0.0,
	CameraEndTime = 0.0,
-- Handles
	Transport = nil,	--transport
	Portal = nil,	--portal
	Wingman = nil,	--wingman
	Recycler = nil,	--recycler
	CerbAttacker1 = nil,	--Cerb Siren (cutscene)
	CerbAttacker2 = nil,	--Cerb scout (cutscene)
	HadeanScout1 = nil,	--Hadean scout (cutscene)
	HadeanScout2 = nil, --Hadean scout (cutscene)
	Player = nil, --Player
	CerbRelay = nil,	--cerb relay
	InterferenceNav = nil,	--"Source" nav
-- Ints
	TPS = 10,
	MissionState = 0,
	WindexNagState = 0,
	InterferenceState = 0,
	DamageHadeansState = 0,
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
	
	--Preload ODFs to reduce lag spikes when things are spawned in for the first time
	PreloadODF("ivrecyE6");
	PreloadODF("ivcargo");
	PreloadODF("evscout");
	PreloadODF("evtank");
	PreloadODF("cvscout");
	PreloadODF("cvrbomb");
	
	for i = 1,AUDIO_MESSAGE_COUNT do
		PreloadAudioMessage(string.format("edf06_%02d.wav", i));
	end
	PreloadAudioMessage("rdr_short.wav");
	PreloadAudioMessage("rdr_long.wav");
end

function Start()

	_FECore.Start();

	M.Recycler = GetHandle("ivrecy");
	M.Transport = GetHandle("ivcargo1");
	M.Wingman = GetHandle("unnamed_ivtank");
	M.Portal = GetHandle("portal");
	ClearPortalDest(M.Portal, true); -- Lock Portal to script only.
	M.CerbRelay = GetHandle("relay");
	
	local TempH = GetHandleOrDie("portal_in");
	ClearPortalDest(TempH, true); -- Lock Portal to script only.
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end


function AddObject(h)

	_FECore.AddObject(h);

end

function Update()

	_FECore.Update();

	M.Player = GetPlayerHandle();
	if(M.MissionTimer < GetTime()) then
		if M.MissionState == 0 then
			Ally(1, 2);
			Ally(4, 5);
			M.Recycler = ReplaceObject(M.Recycler,"ivrecyE6", 2, 0.0, 0);	--last 2 params are essential, otherwise recy spawns without pilot!!!
			M.Transport = ReplaceObject(M.Transport,"ivcargo", 2);
			M.Wingman = ReplaceObject(M.Wingman,"ivtank", 2);
			M.CheckTransport = true;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 1 then
			Defend2(M.Wingman, M.Recycler, 1);
			Goto(M.Recycler, "player_base", 0, 0);
			Follow(M.Transport, M.Recycler, 1);
			M.DoRadioInterference = true; --RunSpeed,_Routine6,1,false
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 3;
		elseif M.MissionState == 2 then
			AddObjective("edf0603.otf", "white");
			AudioMessage("edf06_01.wav");	--Windex:"Anyone know what planet this is?..."
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 12;
		elseif M.MissionState == 3 then
			AudioMessage("edf06_02.wav");	--Windex:"We're picking up Hadean military radar..."
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 48;
		elseif M.MissionState == 4 then
			Attack(TeleportIn("evscout", 5, M.Portal, 15), M.Recycler, 1);
			Attack(TeleportIn("evscout", 5, M.Portal, 35), M.Recycler, 1);
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 17;
		elseif M.MissionState == 5 then	--LOC_22
			if(GetDistance(M.Recycler, "player_base") < 50) then
				M.MissionState = M.MissionState + 1;
				M.MissionTimer = GetTime() + 2;
			end
		elseif M.MissionState == 6 then
			AudioMessage("edf06_03.wav");	--Windex:"Set up a base and some defenses..."
			--If the recy is transferred via SetTeamNum(), the max scrap is not updated properly! 
			--Workaround is to use ReplaceObject to create a new recy on team 1.
			M.Recycler = ReplaceObject(M.Recycler,"ivrecyE6", 1, 0.0, 0);	
			Follow(M.Transport, M.Recycler);
			Defend2(M.Wingman, M.Recycler, 1);
			SetGroup(M.Recycler, 0);
			Goto(M.Recycler, "player_base", 0);
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 7 then
			SetScrap(1, 25);
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 23;
		elseif M.MissionState == 8 then
			AudioMessage("edf06_04.wav");	--Eisenstein:"Something's interfering with our radios..."
			Attack(TeleportIn("evtank", 5, M.Portal, 15), M.Recycler, 1);
			Attack(TeleportIn("evscout", 5, M.Portal, 35), M.Recycler, 1);
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 109;
		elseif M.MissionState == 9 then
			Attack(TeleportIn("evtank", 5, M.Portal, 15), M.Recycler, 1);
			Attack(TeleportIn("evscout", 5, M.Portal, 35), M.Recycler, 1);
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 102;
		elseif M.MissionState == 10 then
			Attack(TeleportIn("evscout", 5, M.Portal, 15), M.Recycler, 1);
			Attack(TeleportIn("evscout", 5, M.Portal, 35), M.Recycler, 1);
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 120;
		elseif M.MissionState == 11 then
			Attack(TeleportIn("evscout", 5, M.Portal, 15), M.Recycler, 1);
			Attack(TeleportIn("evscout", 5, M.Portal, 35), M.Recycler, 1);
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 77;
		elseif M.MissionState == 12 then
			M.Player = GetPlayerHandle();
			Follow(M.Wingman, M.Player, 1);
			AudioMessage("edf06_05.wav");	--Eisenstein:"We're still getting interference..."
			Attack(TeleportIn("evscout", 5, M.Portal, 15), M.Recycler, 1);
			Attack(TeleportIn("evscout", 5, M.Portal, 35), M.Recycler, 1);
			M.DoRadioInterference = true; --RunSpeed,_Routine6,4,true
			M.WindexNag = true; 	--RunSpeed,_Routine5,1,true
			ClearObjectives();
			AddObjective("edf0609.otf", "white");
			M.InterferenceNav = BuildObject("ibnav", 1, "relay");
			SetObjectiveName(M.InterferenceNav, "Source");
			SetObjectiveOn(M.InterferenceNav);
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 13 then	--LOC_59
			if GetDistance(M.Player, "relay") < 150 then
				M.WindexNag = false;	--RunSpeed,_Routine5,0,false
				AudioMessage("edf06_06.wav");	--Eisenstein:"We're monitoring your scanners..."
				Goto(M.Transport, "cargo_path", 1);
				SetObjectiveOn(M.Transport);
				SetObjectiveOff(M.InterferenceNav);
				ClearObjectives();
				AddObjective("edf0605.otf", "white");
				M.MissionState = M.MissionState + 1;
				M.MissionTimer = GetTime() + 5;
			end
		elseif M.MissionState == 14 then
			BuildObject("cvscout", 5, "cerb_base");
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 15 then	--LOC_70
			if GetDistance(M.Transport, "relay") < 150 then
				Stop(M.Transport, 1);
				M.MissionState = M.MissionState + 1;
				M.MissionTimer = GetTime() + 3;
			end
		elseif M.MissionState == 16 then
			M.CerbAttacker1 = BuildObject("cvrbomb", 0, GetPosition("c_cspawn") + SetVector(75,0,-50));
			M.CerbAttacker2 = BuildObject("cvscout", 4, "c_cspawn");
			M.HadeanScout1 = BuildObject("evscout", 6, "p_spwn");
			M.HadeanScout2 = BuildObject("evscout", 6, "p_spwn");
			SetSkill(M.HadeanScout1, 1);
			SetSkill(M.HadeanScout2, 1);
			SetSkill(M.CerbAttacker1, 3);
			SetSkill(M.CerbAttacker2, 3);
			AudioMessage("edf06_07.wav");	--Eisenstein:"This equipment is radically different from Hadean interfaces..."
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 7;
		elseif M.MissionState == 17 then
			SetTeamNum(M.CerbAttacker1, 4);
			Attack(M.CerbAttacker1, M.HadeanScout1, 1);	--Cerb siren not attacking during cutscene for some reason...
			Attack(M.CerbAttacker2, M.HadeanScout2, 1);
			Attack(M.HadeanScout1, M.CerbAttacker2, 1);
			Attack(M.HadeanScout2, M.CerbAttacker1, 1);
			CameraReady();
			M.DamageHadeans = true;	--RunSpeed,_Routine7,1,true
			M.MissionState = M.MissionState + 1;
			M.CameraEndTime = GetTime() + 20;
		elseif M.MissionState == 18 then
			CameraOf(M.CerbAttacker1, -25);
			if(M.CameraEndTime < GetTime()) then
				CameraFinish();
				M.MissionState = M.MissionState + 1;
				M.MissionTimer = GetTime() + 7;
			end
		elseif M.MissionState == 19 then
			EjectPilot(M.HadeanScout1);
			EjectPilot(M.HadeanScout2);
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 5;
		elseif M.MissionState == 20 then
			AudioMessage("edf06_08.wav");	--Eisenstein:"Hold on, this unit's radar is going crazy..."
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 3;
		elseif M.MissionState == 21 then
			ClearObjectives();
			AddObjective("edf0606.otf", "white");
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 5;
		elseif M.MissionState == 22 then
			Attack(BuildObject("cvscout",5,"cerb_base"), M.Transport, 1);
			Attack(BuildObject("cvscout",5,"cerb_base"), M.Transport, 1);
			Attack(BuildObject("cvscout",5,"cerb_base"), M.Transport, 1);
			AudioMessage("edf06_09.wav");	--Windex:"We're showing the attackers on our radar too..."
			M.CheckTransport = false; --RunSpeed,_Routine4,0,false
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 5;
		elseif M.MissionState == 23 then
			local pos = GetPosition(M.Transport) + SetVector(10,0,0);
			Attack(BuildObject("cvscout", 5, pos), Transport, 1);
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 5;
		elseif M.MissionState == 24 then
			EjectPilot(M.Transport);
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 3;
		elseif M.MissionState == 25 then
			Attack(M.CerbAttacker1, M.Recycler, 1);
			Attack(M.CerbAttacker2, M.Recycler, 1);
			--RunSpeed,_Routine3,0,false
			AudioMessage("edf06_10.wav");	--Windex:"The VENGEANCE is under attack..."
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 5;
		elseif M.MissionState == 26 then
			--RunSpeed,_Routine3,1,true
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 5;
		elseif M.MissionState == 27 then
			AudioMessage("edf06_11.wav");	--Windex:"All fighters and scouts deploy along defense perimeter Gamma..."
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 5;
		elseif M.MissionState == 28 then
			M.Recycler = ReplaceObject(M.Recycler, "ivrecy", 1, 0.0, 0);
			Stop(M.Recycler, 1);
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 7;
		elseif M.MissionState == 29 then
			AudioMessage("edf06_12.wav");	--Windex:"VENGEANCE will now retreat to the north..."
			SetObjectiveOff(M.CerbRelay);
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 2;
		elseif M.MissionState == 30 then
			SetObjectiveOn(M.Recycler);
			Defend2(M.Wingman, M.Recycler, 1);
			ClearObjectives();
			AddObjective("edf0607.otf", "white");
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + 2;
		elseif M.MissionState == 31 then
			Attack(BuildObject("cvscout", 4, "spawn_AF"), M.Recycler, 1);
			Attack(BuildObject("cvscout", 4, "spawn_AF"), M.Recycler, 1);
			h = BuildObject("cvscout", 4, "spawn_AF");
			SetSkill(h, 3);
			Attack(h, Recycler, 1);
			Attack(BuildObject("cvscout", 4, "cerb_base"), M.Recycler, 1);
			Attack(BuildObject("cvscout", 4, "cerb_base"), M.Recycler, 1);
			Attack(BuildObject("cvscout", 4, "cerb_base"), M.Recycler, 1);
			h = BuildObject("cvscout", 4, "spawn_AF");
			SetSkill(h, 3);
			Attack(h, M.Recycler, 1);
			Goto(M.Recycler, "recescape", 1);
			Attack(BuildObject("cvscout", 4, "cerb_base"), M.Recycler, 1);
			Attack(BuildObject("cvscout", 4, "cerb_base"), M.Recycler, 1);
			Attack(BuildObject("cvscout", 4, "cerb_base"), M.Recycler, 1);
			Attack(BuildObject("cvscout", 4, "spawn_S"), M.Recycler, 1);
			h = BuildObject("cvscout", 4, "spawn_S");
			SetSkill(h, 3);
			Attack(h, M.Recycler, 1);
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 32 then	--LOC_165
			if GetDistance(M.Recycler, "escape_s") < 60 then
				ClearObjectives();
				AudioMessage("edf06_13.wav");	--Shultz:"Major Windt-Essex, the enemy appears to be retreating..."
				M.MissionState = M.MissionState + 1;
				M.MissionTimer = GetTime() + 27;
			end
		elseif M.MissionState == 33 then
			ClearObjectives();
			AddObjective("edf0608.otf", "green");
			SucceedMission(GetTime() + 5, "edf06Win.des");
			M.MissionState = M.MissionState + 1;
		end
	end

	WindexNag();
	RadioInterference();
	DamageHadeans();
	CheckStuffIsAlive();
end

--Windex repeatedly reminding player to investigate the interference. If the player ignores the order, this fails them.
function WindexNag()	--Routine5
	if M.WindexNagTimer < GetTime() and M.WindexNag then
		if M.WindexNagState == 0 then
			M.WindexNagState = M.WindexNagState + 1;
			M.WindexNagTimer = GetTime() + 70;
		elseif M.WindexNagState == 1 then
			AudioMessage("edf06_14.wav"); --Windex:"Corber, I gave you an order..."
			M.WindexNagState = M.WindexNagState + 1;
			M.WindexNagTimer = GetTime() + 56;
		elseif M.WindexNagState == 2 then
			AudioMessage("edf06_15.wav");	--Windex:"Corber, you're already being investigated for cowardice..."
			M.WindexNagState = M.WindexNagState + 1;
			M.WindexNagTimer = GetTime() + 45;
		elseif M.WindexNagState == 3 then
			AudioMessage("edf06_16.wav");	
			ClearObjectives();
			AddObjective("edf0604.otf", "red");	--Windex:"Corber, I'm relieving you..."
			M.WindexNagState = M.WindexNagState + 1;
			M.WindexNagTimer = GetTime() + 17;
		elseif M.WindexNagState == 4 then
			FailMission(GetTime() + 5, "edf06L3.des");
			M.WindexNagState = M.WindexNagState + 1;
		end
	end
end

--Randomly flickers on the objective marker for the cerberi comm bunker and sends gibberish over the radio
function RadioInterference()	--Routine6
	local jmp = {1,3,5,9,13};
	if M.InterferenceTimer < GetTime() and M.DoRadioInterference then
		if M.InterferenceState == 0 then	--LOC_214
			M.InterferenceState = jmp[math.random(1,5)];
		elseif M.InterferenceState == 1 then
			SetObjectiveOn(M.CerbRelay);
			AudioMessage("rdr_short.wav");
			M.InterferenceState = M.InterferenceState + 1;
			M.InterferenceTimer = GetTime() + 0.1;
		elseif M.InterferenceState == 2 then
			SetObjectiveOff(M.CerbRelay);
			M.InterferenceState = 0;
			M.InterferenceTimer = GetTime() + 22;
		elseif M.InterferenceState == 3 then	--LOC_220
			SetObjectiveOn(M.CerbRelay);
			AudioMessage("rdr_long.wav");
			M.InterferenceState = M.InterferenceState + 1;
			M.InterferenceTimer = GetTime() + 1;
		elseif M.InterferenceState == 4 then
			SetObjectiveOff(M.CerbRelay);
			M.InterferenceState = 0;
			M.InterferenceTimer = GetTime() + 25;
		elseif M.InterferenceState == 5 then	--LOC_226
			SetObjectiveOn(M.CerbRelay);
			AudioMessage("rdr_short.wav");
			M.InterferenceState = M.InterferenceState + 1;
			M.InterferenceTimer = GetTime() + 0.1;
		elseif M.InterferenceState == 6 then
			SetObjectiveOff(M.CerbRelay);
			M.InterferenceState = M.InterferenceState + 1;
			M.InterferenceTimer = GetTime() + 1;
		elseif M.InterferenceState == 7 then
			SetObjectiveOn(M.CerbRelay);
			AudioMessage("rdr_short.wav");
			M.InterferenceState = M.InterferenceState + 1;
		elseif M.InterferenceState == 8 then
			SetObjectiveOff(M.CerbRelay);
			M.InterferenceState = 0;
			M.InterferenceTimer = GetTime() + 27;
		elseif M.InterferenceState == 9 then	--LOC_235
			SetObjectiveOn(M.CerbRelay);
			AudioMessage("rdr_long.wav");
			M.InterferenceState = M.InterferenceState + 1;
			M.InterferenceTimer = GetTime() + 1;
		elseif M.InterferenceState == 10 then
			SetObjectiveOff(M.CerbRelay);
			M.InterferenceState = M.InterferenceState + 1;
			M.InterferenceTimer = GetTime() + 1;
		elseif M.InterferenceState == 11 then
			SetObjectiveOn(M.CerbRelay);
			AudioMessage("rdr_short.wav");
			M.InterferenceState = M.InterferenceState + 1;
		elseif M.InterferenceState == 12 then
			SetObjectiveOff(M.CerbRelay);
			M.InterferenceState = 0;
			M.InterferenceTimer = GetTime() + 27;
		elseif M.InterferenceState == 13 then	--LOC_245
			SetObjectiveOn(M.CerbRelay);
			AudioMessage("rdr_long.wav");
			M.InterferenceState = M.InterferenceState + 1;
			M.InterferenceTimer = GetTime() + 1;
		elseif M.InterferenceState == 14 then
			SetObjectiveOff(M.CerbRelay);
			M.InterferenceState = M.InterferenceState + 1;
			M.InterferenceTimer = GetTime() + 1;
		elseif M.InterferenceState == 15 then
			SetObjectiveOn(M.CerbRelay);
			AudioMessage("rdr_long.wav");
			M.InterferenceState = M.InterferenceState + 1;
			M.InterferenceTimer = GetTime() + 0.1;
		elseif M.InterferenceState == 16 then
			SetObjectiveOff(M.CerbRelay);
			M.InterferenceState = 0;
			M.InterferenceTimer = GetTime() + 27;
		end
	end
end

function DamageHadeans()
	if M.DamageHadeansTimer < GetTime() and M.DamageHadeans then
		if M.DamageHadeansState == 0 then
			M.DamageHadeansState = M.DamageHadeansState + 1;
			M.DamageHadeansTimer = GetTime() + 15;
		elseif M.DamageHadeansState == 1 then
			SetCurHealth(M.HadeanScout1, 1);
			M.DamageHadeansState = M.DamageHadeansState + 1;
			M.DamageHadeansTimer = GetTime() + 3;
		elseif M.DamageHadeansState == 2 then
			SetCurHealth(M.HadeanScout2, 1);
			M.DamageHadeansState = M.DamageHadeansState + 1;
		end
	end
end

function CheckStuffIsAlive()
	if not IsAround(M.Recycler) and not M.MissionFailed then
		ClearObjectives();
		AddObjective("edf0601.otf", "red");
		FailMission(GetTime() + 5, "edf06L1.des");
		M.MissionFailed = true;
	end
	if not IsAround(M.Transport) and not M.MissionFailed and M.CheckTransport then
		ClearObjectives();
		AddObjective("edf0602.otf", "red");
		FailMission(GetTime() + 5, "edf06L2aa.des");
		M.MissionFailed = true;
	end
end