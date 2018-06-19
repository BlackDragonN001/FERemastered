require "FE13Dev.FEAddon.lua.GlobalHandler";

--Strings
local _Text1 = "Build up the base defenses and\ncreate more offensive units\nwhile Wyndt-Essex attacks the\nfirst missile turret.";
local _Text2 = "You failed to protect the\nVENGEANCE. The Cerberi are\nvictorious.";
local _Text3 = "Protect the base while our\ntechnicians analyze the data\ngathered during Windex's ill-\nfated attack. Perhaps we can\nfind some weakness.";
local _Text4 = "We need info on the highlighted\nportal. Approach to within\n250 meters to allow our scanners\nto take a reading.";
local _Text5 = "Level the Cerberi base, but do\nNOT destroy the interplanetary\nportal. We may need it in\norder to escape Miasma.";
local _Text6 = "Halt the Cerberi attack-wave,\nbut do NOT destroy the \ninterplanetary portal!";

local M = {
-- Bools
	AIP2Loaded = false,

-- Floats
	MissionTimer = 0.0,
	Routine1Timer = 0.0,
	Routine9Timer = 0.0,

-- Handles
	Portal = nil,
	Player = nil,
	Recycler = nil,
	Windex = nil,
	Delta1 = nil,
	Delta2 = nil,
	Delta3 = nil,
	Delta4 = nil,
	Delta5 = nil,
	Wingman1 = nil,
	Wingman2 = nil,
	CerbMissileTurret = nil,
	CerbRecy = nil,
	CerbFact = nil,
	FinalWave = {}, 		--cerb final attack wave
	CerbMinelayer = nil,
-- Ints
	MissionState = 0,
	Routine1State = 0,
	Routine9State = 0,
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
	local preloadAudio = {
		"edf08_01.wav",
		"edf08_02.wav",
		"edf08_03.wav",
		"edf08_04.wav",
		"edf08_05.wav",
		"edf08_06.wav",
		"edf08_06b.wav",
		"edf08_07.wav",
		"edf08_08.wav"
	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Start()
	M.Portal = GetHandle("unnamed_ebport_e8");
	M.Recycler = GetHandle("unnamed_ivrecy_r");
	M.CerbMissileTurret = GetHandle("MisTur");
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end


function AddObject(h)
	--SetSkill(h, 3);
	if IsOdf(h, "cvmlay8") then
		M.CerbMinelayer = h;
	elseif IsOdf(h, "ibsbay") then
		SetObjectiveOn(h);
	end	
end

function DeleteObject(h)

end

function Update()
	M.Player = GetPlayerHandle();
	
	Routine1();
	Routine9();
	CheckStuffIsAlive();
	
	if M.WindexInvincible then
		AddHealth(M.Windex, 200);
		AddHealth(M.Delta1, 200);	--made rest of Windex's squad invincible too, otherwise they die too quickly
		AddHealth(M.Delta2, 200);
		AddHealth(M.Delta3, 200);
		AddHealth(M.Delta4, 200);
		AddHealth(M.Delta5, 200);
	end
	if GetTime() > 1500 and not M.AIP2Loaded then
		SetAIP("edf08b.aip", 5);
		M.AIP2Loaded = true;
	end
end

--main mission state
function Routine1()
	if(M.Routine1Timer < GetTime()) then
		if M.Routine1State == 0 then
			Ally(1, 2);
			Ally(5, 6);
			SetTeamColor(2, 0, 0, 150);
			SetScrap(1, 40);
			Dropoff(M.Recycler, "Deploy", 1);
			M.Windex = BuildObject("ivtank8", 2, "TL");
			M.WindexInvincible = true; --RunSpeed,_Routine10,1,false
			LookAt(M.Windex, M.Recycler, 1);
			SetObjectiveName(M.Windex, "Wyndt-Essex");
			SetObjectiveOn(M.Windex);
			M.Delta1 = BuildObject("ivtank8", 2, "T1");
			LookAt(M.Delta1, M.Recycler, 1);
			M.Delta2 = BuildObject("ivtank8", 2, "T2");
			LookAt(M.Delta2, M.Recycler, 1);
			M.Delta3 = BuildObject("ivmisl8", 2, "M1");
			LookAt(M.Delta3, M.Recycler, 1);
			M.Delta4 = BuildObject("ivmisl8", 2, "M2");
			LookAt(M.Delta4, M.Recycler, 1);
			M.Delta5 = BuildObject("ivmisl8", 2, "M3");
			LookAt(M.Delta5, M.Recycler, 1);
			AudioMessage("edf08_01.wav");	--Sgt. Wong:"Our sensors show the StarPortal in geosynchronous orbit directly overhead..."
			SetPosition(M.Player, "PSP");
			CameraReady();
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 1 then
			if CameraPath("RecyCam", 1000, 300, M.Recycler) or CameraCancelled() then
				CameraFinish();
				AudioMessage("edf08_02.wav");	--Windex:"Attack squadron Delta, form up on me and we'll take out that missile turret..."
				Goto(M.Windex, "TooMT", 1);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 1;
			end
		elseif M.Routine1State == 2 then
			Goto(M.Delta1, "TooMT", 1);
			Goto(M.Delta2, "TooMT", 1);
			Goto(M.Delta3, "TooMT", 1);
			Goto(M.Delta4, "TooMT", 1);
			Goto(M.Delta5, "TooMT", 1);
			M.Wingman1 = BuildObject("ivscout8", 2, "BSP1");
			M.Wingman2 = BuildObject("ivscout8", 2, "BSP1");
			Patrol(M.Wingman1, "BSP1", 1);
			Patrol(M.Wingman2, "BSP1", 1);
			ClearObjectives();
			AddObjective(_Text1, "white");
			M.Routine1State = M.Routine1State + 1;
			--M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 3 then
			local h = BuildObject("ivturr", 1, "TurrS");
			SetGroup(h, 8);
			Goto(h, "T1", 0);
			h = BuildObject("ivturr", 1, "TurrS");
			SetGroup(h, 8);
			Goto(h, "T2", 0);
			BuildObject("cvturr02", 5, "CST1");
			BuildObject("cvturr02", 5, "CST2");
			BuildObject("cvturr02", 5, "CST3");
			BuildObject("cvturr02", 5, "CST4");
			BuildObject("cvturr02", 5, "CST5");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 50;
		elseif M.Routine1State == 4 then
			StartEarthQuake(10.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 10;
		elseif M.Routine1State == 5 then
			UpdateEarthQuake(15.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 6 then
			UpdateEarthQuake(17.5);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 7 then
			UpdateEarthQuake(15.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 8 then
			UpdateEarthQuake(12.5);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 9 then
			UpdateEarthQuake(7.5);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 10 then
			UpdateEarthQuake(10.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 11 then
			StopEarthQuake();
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 12 then
			--SetAIP("edf08a.aip", 5);
			AudioMessage("edf08_03.wav");	--Windex:"This must be the turret, but it doesn't look any different from all the others..."
			CameraReady();
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 13 then
			if CameraPath("MTP", 3000, 2000, M.CerbMissileTurret) or CameraCancelled() then
				--CameraFinish();
				Attack(M.Windex, M.CerbMissileTurret, 1);
				Attack(M.Delta1, M.CerbMissileTurret, 1);
				Attack(M.Delta2, M.CerbMissileTurret, 1);
				Attack(M.Delta3, M.CerbMissileTurret, 1);
				Attack(M.Delta4, M.CerbMissileTurret, 1);
				Attack(M.Delta5, M.CerbMissileTurret, 1);
				M.CameraEndTime = GetTime() + 10;
				M.WindexInvincible = false;
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 14 then
			CameraOf(M.Windex, -15);
			if not IsAround(M.Windex) or M.CameraEndTime < GetTime() then
				AudioMessage("edf08_04.wav");	--Delta 1:"Something's wrong. This thing's got awesome firepower. My guns aren't even scratching it..."
				M.DeathFieldSpawnTime = GetTime() + 5;
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 15 then
			if M.DeathFieldSpawnTime < GetTime() and M.Object2 == nil then		
				M.Object2 = BuildObject("e8_df", 5, GetPosition(M.CerbMissileTurret));
			end
			if CameraPath("MTP", 3000, 1000, M.CerbMissileTurret) or CameraCancelled() then
				CameraFinish();
				AudioMessage("edf08_05.wav");	--Wong:"We've lost contact with the entire squadron..."
				StartEarthQuake(20.0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 3;
			end
		elseif M.Routine1State == 16 then
			UpdateEarthQuake(25.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 17 then
			UpdateEarthQuake(22.5);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 18 then
			UpdateEarthQuake(20.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 19 then
			UpdateEarthQuake(17.5);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 20 then
			UpdateEarthQuake(15.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 21 then
			UpdateEarthQuake(10.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 2;
		elseif M.Routine1State == 22 then
			StopEarthQuake();
			SetAIP("edf08a.aip", 5);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 15;
		elseif M.Routine1State == 23 then
			local h = BuildObject("cvdcar", 5, "Spawna");
			Attack(h, M.Recycler, 1);
			ClearObjectives();
			AddObjective(_Text3, "white");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 750;
		elseif M.Routine1State == 24 then
			ClearObjectives();
			AddObjective(_Text4, "white");
			TeleportIn("cvrbomb", 5, M.Portal, 20, 0);
			AudioMessage("edf08_06.wav");	--Wong:"One of our scouts spotted a Cerberi unit coming through a portal in the center of their base..."
			SetObjectiveOn(M.Portal);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 25 then	--LOC_113
			if GetDistance(M.Player, M.Portal) < 250 then
				AudioMessage("edf08_06b.wav");	--Wong:"I have a clear reading now sir. That is definitely an interplanetary portal..."
				ClearObjectives();
				AddObjective(_Text5, "white");
				StartEarthQuake(25.0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 11;
			end
		elseif M.Routine1State == 26 then
			UpdateEarthQuake(20.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 27 then
			UpdateEarthQuake(17.5);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 28 then
			UpdateEarthQuake(15.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 29 then
			UpdateEarthQuake(12.5);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 30 then
			UpdateEarthQuake(10.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 31 then
			UpdateEarthQuake(5.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 32 then
			StopEarthQuake();
			M.CerbRecy = GetObjectByTeamSlot(5, 1);
			M.CerbFact = GetObjectByTeamSlot(5, 2);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 33 then	--LOC_134
			if not IsAround(M.CerbRecy) and not IsAround(M.CerbFact) then
				AudioMessage("edf08_07.wav");	--Wong:"Sir, I'm showing a big wave of heavy Cerberi reinforcements coming through their StarPortal..."
				ClearObjectives();
				AddObjective(_Text5, "green");
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 4;
			end
		elseif M.Routine1State == 34 then
			--final Cerb assault wave spawns after destruction of the Cerb base
			local spawnOdfs = {"cvdcar", "cvdcar", "cvatank2", "cvatank2", "cvhatank", "cvwalk"};
			for i = 1, table.getn(spawnOdfs) do
				M.FinalWave[i] = TeleportIn(spawnOdfs[i], 5, M.Portal, math.random(-40,40), math.random(-40,40));
				Attack(M.FinalWave[i], M.Recycler, 1);
			end
			ClearObjectives();
			AddObjective(_Text6, "white");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 35 then
			local finalWaveDead = true;
			for i = 1, table.getn(M.FinalWave) do
				if IsAround(M.FinalWave[i]) then
					finalWaveDead = false;
					break;
				end
			end
			if finalWaveDead then
				AudioMessage("edf08_08.wav");	--Corber:"Looks like that's the last of them for now..."
				StartEarthQuake(10.0);
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 2;
			end
		elseif M.Routine1State == 36 then
			UpdateEarthQuake(15.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 37 then
			UpdateEarthQuake(20.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 38 then
			UpdateEarthQuake(30.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 39 then
			UpdateEarthQuake(15.0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 40 then
			UpdateEarthQuake(12.5);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 41 then
			UpdateEarthQuake(7.5);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 1;
		elseif M.Routine1State == 42 then
			StopEarthQuake();
			ClearObjectives();
			AddObjective(_Text6, "green");
			SucceedMission(GetTime() + 15, "edf08w.des");
			M.Routine1State = M.Routine1State + 1;
		end
	end
end

--manually controls cerb minelayer
function Routine9()
	if M.Routine9Timer < GetTime() then
		if M.Routine9State == 0 then	--LOC_230
			if IsAround(M.CerbMinelayer) then
				M.Routine9State = M.Routine9State + 1;
			end
		elseif M.Routine9State == 1 then
			Goto(M.CerbMinelayer, "minegt", 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 120;
		elseif M.Routine9State == 2 then
			Patrol(M.CerbMinelayer, "mine1", 1);
			M.Routine9State = M.Routine9State + 1;
		elseif M.Routine9State == 3 then	--LOC_235
			if not IsAround(M.CerbMinelayer) then
				M.Routine9State = 0;
			else
				local pos = GetPosition(M.CerbMinelayer);
				pos.y = TerrainFindFloor(pos);
				BuildObject("cerbmine", 5, pos);
				M.Routine9Timer = GetTime() + 4;
			end
		end	
	end
end	

function CheckStuffIsAlive()
	if not M.MissionFailed then
		if not IsAround(M.Recycler) then
			ClearObjectives();
			AddObjective(_Text2, "red");
			FailMission(GetTime() + 10, "edf08l1.des");
			M.MissionFailed = true;
		elseif not IsAround(M.Portal) then
			ClearObjectives();
			AddObjective(_Text5, "red");
			FailMission(GetTime() + 10, "edf08l2.des");
			M.MissionFailed = true;
		end
	end
end

function TeleportIn(odf, team, dest, offsetX, offsetZ)
	local pos = GetPosition(dest) + SetVector(offsetX, 0, offsetZ);
	BuildObject("teleportin", 0, pos);
	return BuildObject(odf, team, pos);
end
