-- BZCC mercedf1.lua converted by AI_Unit.

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');
local _SPUtils = require("_SPUtils"); --spawn clustering adjustments via function --by JJ 

local Position11 = SetVector(-674, 1000, -783);
local Position12 = SetVector(0, 0, 100);

local M = {
	-- Bools
	PlayerCanMove = false,
	EnableFailCheck = false,
	RunPowerAIStateMachine = false,
	RunPowerPlayerStateMachine = false,
	CerbRoutine = false,
	ConvoyContinueToBase = false,
	PreventPowerDamage = true,
	SetGun10Health = false,
	Routine4Enable = false,
	Routine7Enable = false,
	FlankSpawn = false,
	CondorTakeoff = false,
	ScoutsPassedToPlayer = false,
	FirstWave = false,
	-- Floats
	MissionTimer = 0.0,
	convoyWaitTillTime = 0.0,
	powerPlayerWaitTillTime = 0.0,
	CerbWaitTillTime = 0.0,
	Routine4WaitTillTime = 0.0,
	HandleCounter = 0.0,
	-- Handles
	Object_Power1 = nil,
	Object_Power2 = nil,
	Object_Power3 = nil,
	Object_Power4 = nil,
	Object_Power5 = nil,
	Object_Power6 = nil,
	Object_Power7 = nil,
	Object_Radar1 = nil,
	Object_Radar2 = nil,
	Object_Gun1 = nil,
	Object_Gun2 = nil,
	Object_Gun3 = nil,
	Object_Gun4 = nil,
	Object_Gun5 = nil,
	Object_Gun6 = nil,
	Object_Gun7 = nil,
	Object_Gun8 = nil,
	Object_Gun9 = nil,
	Object_Gun10 = nil,
	Object_WyndtEssex = nil,
	Object_Corbernav = nil,
	Object_Condor = nil,
	Object_ServiceBay = nil,
	Object_Carrier = nil,
	Object_Player = nil,
	Object_Stayput = nil,
	Object_Scout1 = nil,
	Object_Scout2 = nil,
	Object_Scout3 = nil,
	Object_ServTruck1 = nil,
	Object_ServTruck2 = nil,
	Object_Cargo1 = nil,
	Object_Cargo2 = nil,
	Object_Nadir1 = nil,
	Object_Nadir2 = nil,
	Object_Nadir3 = nil,
	Object_Nadir4 = nil,
	Object_CerbUnit = nil,
	Object_CarrierLaunchCamDummy = nil,
	Object_HardinPilot = nil,
	StoredHandle = nil,

	-- ODF Specific Variables
	SCOUTODF = "ivscout11",
	SERVODF = "ivserv",
	CARGOODF = "ivcargo",
	DRONEODF = "nadir",

	-- Ints
	Routine1State = 0,
	Routine2State = 0,
	Routine3State = 0,
	Routine4State = 0,
	Routine5State = 0,
	Routine6State = 0,
	Routine7State = 0,

	Routine1Timer = 0,
	Routine2Timer = 0,
	Routine3Timer = 0,
	Routine4Timer = 0,
	Routine5Timer = 0,
	Routine6Timer = 0,
	Routine7Timer = 0,

	-- Vectors
	Position1 = SetVector(0, 0, 0),
	Position2 = SetVector(0, 0, 0),
	Position3 = SetVector(0, 0, 0),
	Position4 = SetVector(0, 0, 0),
	Position5 = SetVector(0, 0, 0),
	--Arrays and Tables
	Controls = {},
	AIScouts = {},
	FindingHardin = {},
	--Frame Timing 
	CurFrame =nil,
	MaxFrame =nil,
}

function Save()
	_FECore.Save();
	
	return M;
end

function Load(...)
	_FECore.Load();
	
	if (select('#', ...) > 0) then
		M = ...;
	end
end

function AddObject(h)

	_FECore.AddObject(h);
	
	if(GetOdf(h) == "ispilo.odf" and M.Object_HardinPilot == nil) then
				table.insert(M.FindingHardin, h);
				
	end
end

function DeleteObject(h)
	_FECore.DeleteObject(h);
end

function InitialSetup()
	_FECore.InitialSetup();
	
	AllowRandomTracks(false);
	
	PreloadODF("cvscout");
	PreloadODF("nadir");
	PreloadODF("ivscout11");
	PreloadODF("ivserv");
	PreloadODF("ivcargo");
	
	local preloadAudio = {
		"hardm1.wav",
		"merc01.wav",
		"mercury_00a.wav",
		"mercury_01a.wav",
		"mercury_01b.wav",
		"mercury_01c.wav",
		"mercury_02.wav",
		"mercury_02a.wav",
		"mercury_03.wav",
		"mercury_04.wav",
		"mercury_05.wav",
		"mercury_06.wav",
		"mercury_07.wav",
		"mercury_07a.wav",
		"mercury_08.wav",
		"mercury_08a.wav",
		"mercury_09.wav"
	};
	
	for k, v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Start()
	_FECore.Start();
	M.Object_WyndtEssex = GetHandle("Rodriguez");
	Stop(M.Object_WyndtEssex, 1); --added to prevent targeting. -Gravey
	M.Object_Corbernav = GetHandle("Corbernav");
	M.Object_Condor = GetHandle("condor");

	M.Object_ServiceBay = GetHandle("unnamed_ibsbay");
	M.Object_Carrier = GetHandle("unnamed_ivcarrs");

	M.Object_Power1 = GetHandle("power1");
	M.Object_Power2 = GetHandle("power2");
	M.Object_Power3 = GetHandle("power3");
	M.Object_Power4 = GetHandle("power4");
	M.Object_Power5 = GetHandle("power5");
	M.Object_Power6 = GetHandle("power6");
	M.Object_Power7 = GetHandle("power7");

	M.Object_Gun1 = GetHandle("gun1");
	M.Object_Gun2 = GetHandle("gun2");
	M.Object_Gun3 = GetHandle("gun3");
	M.Object_Gun4 = GetHandle("gun4");
	M.Object_Gun5 = GetHandle("gun5");
	M.Object_Gun6 = GetHandle("gun6");
	M.Object_Gun7 = GetHandle("gun7");
	M.Object_Gun8 = GetHandle("gun8");
	M.Object_Gun9 = GetHandle("gun9");
	M.Object_Gun10 = GetHandle("gun10");
	StopGt10Heal = false; --Gravey added for better GT10 heal.
	M.Object_Radar1 = GetHandle("Radar1");
	M.Object_Radar2 = GetHandle("Radar2");
	
	M.Position1 = GetPosition("landing_zone");
	M.Position2 = GetPosition(M.Object_ServiceBay);
	M.Position3 = GetPosition("hardin_spawn");
	M.Position4 = GetPosition("red_spawn");
	M.Position5 = GetPosition("blue_spawn");
	M.Object_Player = GetPlayerHandle(1); --Initial set for player handle at mission start -Gravey
	M.MessagePlayed = false; --added for looping audio.
	
	GLOBAL_lock(_G); --prevents script from accidentally creating new global variables.
end

function Update()
	_FECore.Update();
	-- Handle Routines.
	Routine1();
	Routine2();
	Routine3();
	Routine4();
	Routine6();
	Routine5();
	Routine7(); --Controls scout f1 groups -Gravey
	DamagePrevention();
	UpdateShipHandles(); --Controls handle swapping by player "pick me up" -Gravey
	DropshipTakeoff();-- added for effect -Gravey
	PlayerControls(); --Gravey, thanks N1 and GBD
	
	
end
function PlayerControls()	

	if(M.PlayerCanMove == false) then
	
	M.Controls = {["braccel"] = 0.0,  ["pitch"] = nil, ["strafe"] =0.0, ["jump"] = false, ["deploy"] = false, ["eject"] = false, ["abandon"] = false, ["fire"] = false};
	SetControls(M.Object_Player, M.Controls);
	
	end

end
function FindHardin();
		
	if(M.Object_HardinPilot == nil) then		
		for k,v in ipairs(M.FindingHardin) do
			if(HoppedOutOf(M.FindingHardin[k]) == M.Object_Hardin) then
				M.Object_HardinPilot =  M.FindingHardin[k];
				
			end
		end
	
	end
end
function UpdateShipHandles()
--Gravey, created this to not have to rewrite end code for game breaking bug crashing mission script from ship variables having the same handle at once. 
if (M.Object_Player ~= GetPlayerHandle(1)) then
		
		M.HandleCounter = M.HandleCounter + 1;
		if(M.HandleCounter == 1) then --sets hop out of ship to stored handle
			M.LastShipHandle = M.Object_Player;
		end
		
		M.Object_Player = GetPlayerHandle(1); --updates M.Object_Player to what should be a pilot player handle first, then on the following iteration: the ship the player got into
		
		if(M.HandleCounter >= 2 ) then --if player has a new handle again then update new ship to old stored handle
			
			if(M.Object_Scout1 == GetPlayerHandle(1)) then
				M.Object_Scout1 = M.LastShipHandle;
				M.HandleCounter = 0;
			elseif(M.Object_Scout2 == GetPlayerHandle(1)) then
				M.Object_Scout2 = M.LastShipHandle;
				M.HandleCounter = 0;
			elseif(M.Object_Scout3 == GetPlayerHandle(1)) then
				M.Object_Scout3 = M.LastShipHandle;
				M.HandleCounter = 0;
			else
			M.HandleCounter = 0;
			end
		end
	end
end

function DropshipTakeoff()
	M.Object_Condor = GetHandle("condor");
	if(GetDistance(M.Object_Player, M.Object_Condor) > 30.0 and M.CondorTakeoff == false) then
		
		SetAnimation(M.Object_Condor,"takeoff", 1);
		M.MaxFrame = SetAnimation(M.Object_Condor,"takeoff", 1);
		StartSoundEffect("dropdoor.wav",M.Object_Condor);
		StartAnimation(M.Object_Condor);
		StartEmitter(M.Object_Condor,1);
		StartEmitter(M.Object_Condor,2);
		M.CondorTakeoff = true;
		
		end
	if(M.CondorTakeoff == true) then
		M.CurFrame = GetAnimationFrame(M.Object_Condor, "takeoff");
		
		if(M.CurFrame >= M.MaxFrame -2) then
		
		RemoveObject(M.Object_Condor);
		end
	end
end

function Routine1() 
	if (M.Routine1Timer < GetTime()) then
	
		if (M.Routine1State == 0) then
			PlayerControls();
			SetGroup(M.Object_WyndtEssex, 0); -- moved from line 269 changed to group 0
			SetGroup(M.Object_ServTruck1, 0); --moved gravey from line 282 changed to group 0
			-- prevents player from using f1 on wynd and truck at start
			StartEarthQuake(1.5);
			M.Position_LandingZone3 = GetPosition(M.Object_Player);
			M.Object_Stayput = BuildObjectAndLabel("stayput", 0, M.Position_LandingZone3, "Stayput 1");
			M.convoyWaitTillTime = GetTime() + 1;
			
			M.Routine1State = M.Routine1State + 1;
		elseif (M.Routine1State == 1) then
			if (GetTime() >= M.convoyWaitTillTime) then
				Ally(1,9);
				UnAlly(9,2);

				IFace_EnterMenuMode();
				IFace_Exec("merc01.cfg");

				FreeCamera();

				IFace_Activate("INFO1");
				IFace_Activate("Start1");

				M.Routine1State = M.Routine1State + 1
			end
		elseif (M.Routine1State == 2) then
			if (CameraReady()) then
				local pos = M.Position_LandingZone3; -- LandingZone3 is already set to the position of the player. We should reuse this as it's not reassigned. - AI_Unit.
				local ang = GetFront(M.Object_Player);

				pos.y = pos.y + 3.0;
				
				SetCameraPosition(pos, ang);
				IFace_Deactivate("Start1");
				IFace_Activate("Message");
				
				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 3) then
			local iFaceVal = IFace_GetInteger("images.page");

			if (iFaceVal == 4) then
				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 4) then
			IFace_Deactivate("INFO1");
			IFace_Deactivate("Message");
			IFace_Exec("mercedf1.cfg");
			IFace_Activate("INFO");
			
			M.Routine1State = M.Routine1State + 1;
		elseif (M.Routine1State == 5) then
			--M.Object_CarrierLaunchCamDummy = BuildObjectAndLabel("dummy", 2, Position11, "Dummy 1");
			
			--SetGroup(M.Object_WyndtEssex, 10); --moved gravey
			SetObjectiveName(M.Object_WyndtEssex, "Wyndt-Essex");
			
			--M.Object_Hardin = BuildObjectAndLabel(M.SCOUTODF, 9, M.Position3, "Hardin");
			--SetObjectiveName(M.Object_Hardin, "Hardin");
			--
			--M.Object_Scout1 = BuildObjectAndLabel(M.SCOUTODF, 9, M.Position4, "Scout 1");
			--M.Object_Scout2 = BuildObjectAndLabel(M.SCOUTODF, 9, M.Position4, "Scout 2");
			--M.Object_Scout3 = BuildObjectAndLabel(M.SCOUTODF, 9, M.Position5, "Scout 3");
			--M.Object_ServTruck1 = BuildObjectAndLabel(M.SERVODF, 1, M.Position5, "Service Truck 1");
			
			--SetGroup(M.Object_ServTruck1, 10); --moved gravey
			
			--M.Object_ServTruck2 = BuildObjectAndLabel(M.SERVODF, 9, M.Position1, "Service Truck 2");
			--M.Object_Cargo1 = BuildObjectAndLabel(M.CARGOODF, 9, M.Position1, "Cargo 1");
			--SetCanSnipe(M.Object_Cargo1, 0); --Gravey
			--M.Object_Cargo2 = BuildObjectAndLabel(M.CARGOODF, 9, M.Position1, "Cargo 2");
			--SetCanSnipe(M.Object_Cargo2, 0); --Gravey
			
			
			M.AIScouts = {M.Object_Scout1,M.Object_Scout2,M.Object_Scout3,M.Object_Hardin,M.Object_WyndtEssex};
			
			
			
			
			M.Routine1State = M.Routine1State + 1;
		elseif (M.Routine1State == 6) then
			local iFaceVal = IFace_GetInteger("images.page");

			if (iFaceVal == 3) then
				IFace_ExitMenuMode();
				FreeFinish();

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 7) then
			M.Routine1State = M.Routine1State + 1; -- Wait one more turn for FreeFinish() to Finish. -GBD
		elseif (M.Routine1State == 8) then
			CameraFinish();
			M.Routine1State = M.Routine1State + 1;
		elseif (M.Routine1State == 9) then
			IFace_Deactivate("INFO");
			
			
			M.convoyWaitTillTime = GetTime() + 1;
			M.Routine1State = M.Routine1State + 1;
		elseif (M.Routine1State == 10) then
			if (GetTime() >= M.convoyWaitTillTime) then
				UpdateEarthQuake(4.0);

				LookAt(M.Object_WyndtEssex, M.Object_Player, 1);
				M.convoyWaitTillTime = GetTime() + 1;

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 11) then
			if (GetTime() >= M.convoyWaitTillTime) then
				AudioMessage("mercury_02.wav");

				M.convoyWaitTillTime = GetTime() + 9;

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 12) then
			if (GetTime() >= M.convoyWaitTillTime) then
				
				
				
				
				
				SetObjectiveOn(M.Object_Cargo2);
				AddObjective("mercedf101.otf", "white");

				StopEarthQuake();
				SetAnimation(M.Object_Condor, "deploy", 1);
				StartAnimation(M.Object_Condor);
				AudioMessage("dropdoor.wav");
				RemoveObject(M.Object_Stayput);
				
				
				M.Object_Hardin = BuildObjectAndLabel(M.SCOUTODF, 9, M.Position3, "Hardin");
				SetObjectiveName(M.Object_Hardin, "Hardin");
				
				M.Object_Scout1 = BuildObjectAndLabel(M.SCOUTODF, 9, M.Position4, "Scout 1");
				M.Object_Scout2 = BuildObjectAndLabel(M.SCOUTODF, 9, M.Position4, "Scout 2");
				M.Object_Scout3 = BuildObjectAndLabel(M.SCOUTODF, 9, M.Position5, "Scout 3");
				M.Object_ServTruck1 = BuildObjectAndLabel(M.SERVODF, 1, M.Position5, "Service Truck 1");
				
				
				
				M.Object_ServTruck2 = BuildObjectAndLabel(M.SERVODF, 9, M.Position1, "Service Truck 2");
				M.Object_Cargo1 = BuildObjectAndLabel(M.CARGOODF, 9, "Cargo1Spawn", "Cargo 1");
				SetCanSnipe(M.Object_Cargo1, 0); --Gravey
				M.Object_Cargo2 = BuildObjectAndLabel(M.CARGOODF, 9, M.Position1, "Cargo 2");
				SetCanSnipe(M.Object_Cargo2, 0); --Gravey
				Goto(M.Object_Cargo1, "convoy", 1);
				
				M.AIScouts = {M.Object_Scout1,M.Object_Scout2,M.Object_Scout3,M.Object_Hardin,M.Object_WyndtEssex};
				
				
				
				Defend2(M.Object_Scout2, M.Object_Scout1, 1); --changed to Defend2 
				--Defend2(M.Object_WyndtEssex, M.Object_Cargo2, 1); moved to prevent Wynd from climbing the walls inside the dropship.
				LookAt(M.Object_WyndtEssex, M.Object_Cargo2, 1); --added to turn wynd to face the exit before moving. 
				Follow(M.Object_ServTruck1, M.Object_Cargo2, 1);
				Follow(M.Object_ServTruck2, M.Object_Cargo1, 1);
				Follow(M.Object_Hardin, M.Object_Cargo1, 1);
				Follow(M.Object_Scout1, M.Object_Cargo1, 1);
				Defend2(M.Object_Scout3, M.Object_Hardin, 1); --changed to Defend2 

				M.EnableFailCheck = true;
				M.convoyWaitTillTime = GetTime() + 5;

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 13) then
			if (GetTime() >= M.convoyWaitTillTime) then
				Goto(M.Object_Cargo2, "convoy", 1);
				Defend2(M.Object_WyndtEssex, M.Object_Cargo2, 1); --moved down from above. 
				M.PlayerCanMove = true;
				M.convoyWaitTillTime = GetTime() + 30;
				M.Object_Nadir1 = BuildObjectAndLabel(M.DRONEODF, 2, "NadirFirstSpawn", "Nadir 1"); --moved spawn time up so player doesn't see it POOF from thin air. 
				Attack(M.Object_Nadir1, M.Object_Cargo2, 1);
				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 14) then
			if (GetTime() >= M.convoyWaitTillTime) then
				--M.Object_Nadir1 = BuildObjectAndLabel(M.DRONEODF, 2, "NadirFirstSpawn", "Nadir 1"); -- updated path location was Position12 --Gravey

				SetPerceivedTeam(M.Object_Nadir1, 1);
				--Attack(M.Object_Nadir1, M.Object_Cargo2, 1); moved to line 338

				AudioMessage("mercury_02a.wav");

				M.convoyWaitTillTime = GetTime() + 13;

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 15) then
			if (GetTime() >= M.convoyWaitTillTime) then
				SetPerceivedTeam(M.Object_Nadir1, 2);

				if (GetDistance(M.Object_Cargo1, "convoy_halt") <= 50 and GetDistance(M.Object_Cargo1, "convoy_halt") >=40) then
					
					for i=1,4 do --created array logic to prevent scouts from playing bumper scouts. -Gravey
						Goto(M.AIScouts[i], GetPositionNear("convoy_halt",0, 5, 10), 1);
					end
				end	
				if (GetDistance(M.Object_Cargo2, "convoy_halt") <= 20) then
				SetObjectiveOff(M.Object_Cargo2);
				AudioMessage("mercury_03.wav");
				Stop(M.Object_WyndtEssex,1); -- added stop line for Wyndt.
				M.convoyWaitTillTime = GetTime() + 19;

				M.Routine1State = M.Routine1State + 1;
				end
				
			end
		elseif (M.Routine1State == 16) then
			if (GetTime() >= M.convoyWaitTillTime) then
				ClearObjectives();
				AddObjective("mercedf102.otf", "WHITE");

				-- Run new routines.
				M.RunPowerAIStateMachine = true;
				M.RunPowerPlayerStateMachine = true;

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 17) then            
			if (GetTeamNum(M.Object_Radar1) == 0 and GetTeamNum(M.Object_Radar2) == 0) then
				SetTeamNum(M.Object_Gun1, 0);
				SetTeamNum(M.Object_Gun2, 0);
				SetTeamNum(M.Object_Gun3, 0);
				SetTeamNum(M.Object_Gun4, 0);
				SetTeamNum(M.Object_Gun5, 0);
				SetTeamNum(M.Object_Gun6, 0);
				SetTeamNum(M.Object_Gun7, 0);
				SetTeamNum(M.Object_Gun8, 0);
				
				M.convoyWaitTillTime = GetTime() + 8;
				
				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 18) then 
			if (GetTime() >= M.convoyWaitTillTime and GetDistance(M.Object_WyndtEssex, "convoy_halt") <= 100) then --added logic to wait for wyndt to play audio message. 
				AudioMessage("mercury_07.wav");

				AddObjective("mercedf111.otf", "white");

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 19) then 
			if (M.ConvoyContinueToBase == true) then
				Goto(M.Object_Hardin, "hardin", 1);
				
				M.convoyWaitTillTime = GetTime() + 15;
				
				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 20) then
			if (GetTime() >= M.convoyWaitTillTime) then
				Goto(M.Object_WyndtEssex, "hardin", 1);

				M.convoyWaitTillTime = GetTime() + 5;

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 21) then
			if (GetTime() >= M.convoyWaitTillTime) then
				Goto(M.Object_Cargo1, "transport1", 1);

				M.convoyWaitTillTime = GetTime() + 10;

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 22) then
			Goto(M.Object_Cargo2, "transport1", 1);

			M.Routine1State = M.Routine1State + 1;
		elseif (M.Routine1State == 23) then
			local d1 = GetDistance(M.Object_Cargo1, M.Object_ServiceBay);
			local d2 = GetDistance(M.Object_Cargo2, M.Object_ServiceBay);
			local d3 = GetDistance(M.Object_WyndtEssex, M.Object_ServiceBay);
			
			if (d1 <= 300 and d2 <= 300 and d3 <= 300) then
				
				M.RunPowerPlayerStateMachine = false;
				M.RunPowerAIStateMachine = false;
				M.CerbRoutine = false;
				
				
				SetObjectiveOn(M.Object_Hardin);
				
				Ally(2,9);
				
				SetTeamNum(M.Object_Scout1, 9);
				SetTeamNum(M.Object_Scout2, 9);
				SetTeamNum(M.Object_Scout3, 9);
				SetTeamNum(M.Object_ServTruck1, 9);--added to give trucks back to t9 so player isn't left with half their units. --Gravey
				SetTeamNum(M.Object_ServTruck2, 9);--added to give trucks back to t9 so player isn't left with half their units.
				Retreat(M.Object_Scout1, "hardin", 1);
				Retreat(M.Object_Scout2, "hardin", 1);
				Retreat(M.Object_Scout3, "hardin", 1);
				
				ClearObjectives();
				LookAt(M.Object_Hardin, M.Object_Player, 1);
				AddObjective("mercedf106.otf", "white");
				AudioMessage("mercury_08.wav");
				SetObjectiveName(M.Object_Corbernav, "Enter StormPetrel here");
				
				SetTeamNum(M.Object_Gun1, 0);
				SetTeamNum(M.Object_Gun2, 1);
				SetTeamNum(M.Object_Gun3, 0);
				SetTeamNum(M.Object_Gun4, 1);
				SetTeamNum(M.Object_Gun5, 0);
				SetTeamNum(M.Object_Gun6, 1);
				SetTeamNum(M.Object_Gun7, 0);
				SetTeamNum(M.Object_Gun8, 0);
				
				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 24) then
			if (GetDistance(M.Object_Hardin, M.Object_Player) <= 200) then
				Goto(M.Object_WyndtEssex, M.Object_ServiceBay, 1);
				Goto(M.Object_Scout1, M.Object_ServiceBay, 1);
				Goto(M.Object_Scout2, M.Object_ServiceBay, 1);
				Goto(M.Object_Scout3, M.Object_ServiceBay, 1);
				
				HopOut(M.Object_Hardin);
				
				FindHardin(); -- added to find Hardin's pilot
				
				SetObjectiveName(M.Object_Hardin, "Scout"); --sets hardins old scout to "Scout" instead of "Hardin"
				
				--M.Object_Hardin = HoppedOutOf(M.Object_Hardin); --update M.Object_Hardin with pilot handle here to fix fail condition 
				
				--Stop(M.Object_HardinPilot); --give order to stop instead of trying to enter the players empty? 
				
				SetTeamNum(M.Object_Corbernav, 1);
				
				SetObjectiveOn(M.Object_Corbernav);
				SetObjectiveOff(M.Object_Hardin);
				
				M.Routine1State = M.Routine1State + 1;
				
			end
		elseif (M.Routine1State == 25) then
				FindHardin();
			if (IsAliveAndPilot(M.Object_Player))then -- added for logic to control pilot from moving when the player jumps out. 
				Defend(M.Object_HardinPilot,1);
				end
			if (GetDistance(M.Object_Corbernav,M.Object_Player ) <= 10 and IsAliveAndPilot(M.Object_Player) and M.Object_HardinPilot ~= nil) then --updated so cutscene requires player to get out of ship. --Gravey
				StartEarthQuake(4.0);
				Stop(M.Object_Hardin);
				ClearObjectives();
				AddObjective("mercedf105.otf", "green");

				AudioMessage("mercury_08a.wav");

				HopOut(M.Object_Scout1);
				HopOut(M.Object_Scout2);
				HopOut(M.Object_Scout3);

				M.convoyWaitTillTime = GetTime() + 3;

				M.Routine1State = M.Routine1State + 1;
				--M.EnableFailCheck = false; -- previous location
			end
		elseif (M.Routine1State == 26) then
			if (GetTime() >= M.convoyWaitTillTime) then
				M.EnableFailCheck = false;
				RemoveObject(M.Object_Cargo1);
				RemoveObject(M.Object_Cargo2);

				M.Routine4Enable = true;

				local mat = GetTransform(M.Object_Carrier);

				RemoveObject(M.Object_Carrier);

				M.Object_Carrier = BuildObjectAndLabel("ivcarrs_ani", 1, mat, "Carrier 1");

				M.convoyWaitTillTime = GetTime() + 7;

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 27) then
			if (GetTime() >= M.convoyWaitTillTime) then
				AudioMessage("dropleav.wav");

				M.convoyWaitTillTime = GetTime() + 10;

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 28) then
			if (GetTime() >= M.convoyWaitTillTime) then
				AudioMessage("mercury_09.wav");

				M.convoyWaitTillTime = GetTime() + 12;

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 29) then
			if (GetTime() >= M.convoyWaitTillTime) then
				local mat = GetTransform(M.Object_Carrier);

				RemoveObject(M.Object_Carrier);

				M.Object_Carrier = BuildObjectAndLabel("ivcarrs", 1, mat, "Carrier 2");

				M.convoyWaitTillTime = GetTime() + 12;

				M.Routine1State = M.Routine1State + 1;
			end
		elseif (M.Routine1State == 30) then
			if (GetTime() >= M.convoyWaitTillTime) then
				StopEarthQuake();
				SucceedMission(0, "winmerc.des");
				M.MissionState = M.MissionState + 1;
			end
		end
	end
end

-- Handles sending the friendly AI scouts to attack a set of power generators.
function Routine2()
	if (M.RunPowerAIStateMachine) then
		if (M.Routine2State == 0) then
			Goto(M.Object_Scout2, "scout1", 1);
			Goto(M.Object_Scout1, "scout1", 1);
			
			M.Routine2State = M.Routine2State + 1;
		elseif (M.Routine2State == 1) then
			if (GetDistance(M.Object_Scout1, "red_goto_power") <= 20) then
				M.Routine2Timer = GetTime() + 5;

				M.Routine2State = M.Routine2State + 1;
			end
		elseif (M.Routine2State == 2) then
			if (GetTime() >= M.Routine2Timer) then
				RemoveObject(M.Object_Gun9);
				Attack(M.Object_Scout2, M.Object_Power7, 1);
				Attack(M.Object_Scout1, M.Object_Power7, 1);

				M.Routine2State = M.Routine2State + 1;
			end
		elseif (M.Routine2State == 3) then
			if (not IsAround(M.Object_Power7)) then
				SetCurAmmo(M.Object_Scout2, 800);
				SetCurAmmo(M.Object_Scout1, 800);
				Attack(M.Object_Scout2, M.Object_Power6, 1);
				Attack(M.Object_Scout1, M.Object_Power6, 1);

				M.Routine2State = M.Routine2State + 1;
			end
		elseif (M.Routine2State == 4) then
			if (not IsAround(M.Object_Power6)) then
				SetCurAmmo(M.Object_Scout2, 800);
				SetCurAmmo(M.Object_Scout1, 800);
				Attack(M.Object_Scout2, M.Object_Power5, 1);
				Attack(M.Object_Scout1, M.Object_Power5, 1);

				M.Routine2State = M.Routine2State + 1;
			end
		elseif (M.Routine2State == 5) then
			if (not IsAround(M.Object_Power5)) then
				SetTeamNum(M.Object_Radar1, 0);

				Goto(M.Object_Scout2, "scout3", 0);
				Goto(M.Object_Scout1, "scout3", 0);

				M.Routine2State = M.Routine2State + 1;
			end
		end
	end
end

-- Handles the player side of attacking a set of power generators.
function Routine3() 
	if (M.RunPowerPlayerStateMachine) then
		if (IsPlayer(GetWhoShotMe(M.Object_Gun10))) then
			M.StopGt10Heal = true;
			
		elseif (M.StopGt10Heal == true) then --added to run looping hp hold. moved out of 3State = 0 -Gravey
				
			
		else
			SetCurHealth(M.Object_Gun10, 3000); --cleanup -Gravey
		end
		if (M.Routine3State == 0) then
			
			SetObjectiveOn(M.Object_WyndtEssex);
			LookAt(M.Object_WyndtEssex, M.Object_Player, 1);
			
			AudioMessage("mercury_04.wav");
			
			M.Object_Nadir1 = BuildObjectAndLabel(M.DRONEODF, 2, Position12, "Nadir 1");
			
			Attack(M.Object_Nadir1, M.Object_WyndtEssex, 1);
			Goto(M.Object_WyndtEssex, "rod1", 1);
			
			SetMaxHealth(M.Object_Power1, 800);
			SetMaxHealth(M.Object_Power2, 800);
			SetMaxHealth(M.Object_Power3, 800);
			SetMaxHealth(M.Object_Power4, 800);
			
			M.Routine3State = M.Routine3State + 1;
		elseif (M.Routine3State == 1) then
			if (GetDistance(M.Object_WyndtEssex, "blue_goto_power_1") <= 20 and GetDistance(M.Object_Player, M.Object_WyndtEssex) <= 100) then
				LookAt(M.Object_WyndtEssex, M.Object_Player, 1);
				SetCurHealth(M.Object_Gun10, 3000); --cleanup -Gravey
				AudioMessage("mercury_05.wav");

				M.Routine3Timer = GetTime() + 1;

				M.Routine3State = M.Routine3State + 1;
			end
		elseif (M.Routine3State == 2) then
			if (GetTime() >= M.Routine3Timer) then
				
				ClearObjectives();
				AddObjective("mercedf103.otf", "white");

				M.CerbRoutine = true;

				SetObjectiveOn(M.Object_Gun10);
				
				M.Routine3State = M.Routine3State + 1;
			end
		elseif (M.Routine3State == 3) then
			 
			if (not IsAround(M.Object_Gun10)) then 
				Goto(M.Object_WyndtEssex, "blue_goto_power_2", 1);
				ClearObjectives();
				AddObjective("mercedf103.otf", "green");
				AddObjective("mercedf104.otf", "white");

				M.Routine3Timer = GetTime() + 22;

				M.Routine3State = M.Routine3State + 1;
			end
		elseif (M.Routine3State == 4) then
			if (M.MessagePlayed == false and not IsAround(M.Object_Power3) and not IsAround(M.Object_Power4) and not IsAround(M.Object_Gun10) ) then --Updated VO logic.
					AudioMessage("mercury_06.wav"); --moved for logical order and player attention to go to wynd --Gravey
					M.MessagePlayed = true;
				end
			
			if (GetDistance(M.Object_Player, M.Object_WyndtEssex) <= 50 and M.FlankSpawn == false) then --added for gameplay fluidity - Gravey
				M.FlankSpawn = true;
				ClearObjectives();
				AddObjective("mercedf102.otf", "white");
				Retreat(M.Object_WyndtEssex, "WyndtRetreat",1);
				
				
			elseif (GetDistance(M.Object_WyndtEssex, "FlankTarget") <= 150 and M.FlankSpawn == true) then --additional spawn logic for consistency.
				M.Object_Nadir1 = BuildObjectAndLabel(M.DRONEODF, 2, "NadirFlank", "Nadir 2"); --changed from NaidrFirstSpawn to new OH SHIT momoent when they come around the corner
				M.Object_Nadir2 = BuildObjectAndLabel(M.DRONEODF, 2, "NadirAttackSpawn", "Nadir 3"); --This was an unintended change when I was adjusting path points. But it felt good. -Gravey
				M.FlankSpawn = false;
				Attack(M.Object_Nadir1, M.Object_WyndtEssex, 1);
				Attack(M.Object_Nadir2, M.Object_Player, 1);
				M.Routine3State = M.Routine3State + 1;
				end
				
			if (not IsAround(M.Object_Power1) and not IsAround(M.Object_Power2) and not IsAround(M.Object_Power3) and not IsAround(M.Object_Power4)  ) then 
				SetTeamNum(M.Object_Radar2, 0);
							
			end
			
		elseif (M.Routine3State == 5) then
					
			if (GetDistance(M.Object_WyndtEssex, "convoy_halt") <= 100) then --was 200
				SetObjectiveOff(M.Object_WyndtEssex);
				M.Routine7Enable = true;		--add custom routine bool true here.
				
				
				SetTeamNum(M.Object_Scout3, 1);
				SetGroup(M.Object_Scout3, 0);
				
				if(M.FirstWave == false) then
				
				M.Object_Nadir1 = BuildObjectAndLabel(M.DRONEODF, 2, "ReturnNadirSpawn", "Nadir 4");
				Attack(M.Object_Nadir1, M.Object_Cargo1, 1);
				
				M.Attackwave = true;
				end
				
				

				--Follow(M.Object_Scout3, M.Object_Player, 0); --Disabled, units shouldn't be given orders to do things before being handed to player. --Gravey
				Stop(M.Object_Scout3, 0); --added so F1 scout is given to player
				SetTeamNum(M.Object_ServTruck2, 1);
				SetGroup(M.Object_ServTruck1, 3);
				SetGroup(M.Object_ServTruck2, 3);
				

				Service(M.Object_ServTruck1, M.Object_Cargo1, 0);
				Service(M.Object_ServTruck2, M.Object_Cargo2, 0);

				M.Routine3Timer = GetTime() + 60;  --was 80

				M.Routine3State = M.Routine3State + 1;
				M.FirstWave=false;
			end
		elseif (M.Routine3State == 6) then
			
			if(not IsAround(M.Object_Nadir1) and not IsAround(M.Object_Nadir2) and M.FirstWave == false)then -- added 2nd wave before x3 and x4 drone waves to feel more like a natural progression and keep the player engaged instead of waiting.
				local Attackwave = {M.DRONEODF,M.DRONEODF};
				_SPUtils.BuildObjectSpread(Attackwave,2,"ReturnNadirSpawn","Nadir")
				M.Object_Nadir1 = GetHandle("Nadir1");
				M.Object_Nadir2 = GetHandle("Nadir2");
				Attack(M.Object_Nadir1, M.Object_Cargo1, 1);
				Attack(M.Object_Nadir2, M.Object_Cargo2, 1);
				M.FirstWave = true
				end
			if (M.ScoutsPassedToPlayer == true) then
			
				--M.Object_Nadir1 = BuildObjectAndLabel(M.DRONEODF, 2, "NadirAttackSpawn", "Nadir 4");
				--M.Object_Nadir2 = BuildObjectAndLabel(M.DRONEODF, 2, "NadirAttackSpawn", "Nadir 5");
				--M.Object_Nadir3 = BuildObjectAndLabel(M.DRONEODF, 2, "NadirAttackSpawn", "Nadir 6");
				local Attackwave = {M.DRONEODF,M.DRONEODF,M.DRONEODF};
				_SPUtils.BuildObjectSpread(Attackwave,2,"NadirAttackSpawn","Nadir")
				M.Object_Nadir1 = GetHandle("Nadir1");
				M.Object_Nadir2 = GetHandle("Nadir2");
				M.Object_Nadir3 = GetHandle("Nadir3");
				Attack(M.Object_Nadir1, M.Object_WyndtEssex, 1);
				Attack(M.Object_Nadir2, M.Object_Cargo2, 1);
				Attack(M.Object_Nadir3, M.Object_Player, 1);

				M.Routine3State = M.Routine3State + 1;
			end
		elseif (M.Routine3State == 7) then
			if (not IsAround(M.Object_Nadir1) and not IsAround(M.Object_Nadir2) and not IsAround(M.Object_Nadir3)) then
				M.ConvoyContinueToBase = true;

				--M.Object_Nadir1 = BuildObjectAndLabel(M.DRONEODF, 2, "NadirAttackSpawn", "Nadir 7");
				--M.Object_Nadir2 = BuildObjectAndLabel(M.DRONEODF, 2, "NadirAttackSpawn", "Nadir 8");
				--M.Object_Nadir3 = BuildObjectAndLabel(M.DRONEODF, 2, "NadirAttackSpawn", "Nadir 9");
				--M.Object_Nadir4 = BuildObjectAndLabel(M.DRONEODF, 2, "NadirAttackSpawn", "Nadir 10");
				local Attackwave = {M.DRONEODF,M.DRONEODF,M.DRONEODF,M.DRONEODF};
				_SPUtils.BuildObjectSpread(Attackwave,2,"NadirAttackSpawn","Nadir")
				M.Object_Nadir1 = GetHandle("Nadir1");
				M.Object_Nadir2 = GetHandle("Nadir2");
				M.Object_Nadir3 = GetHandle("Nadir3");
				M.Object_Nadir4 = GetHandle("Nadir4");
				Attack(M.Object_Nadir1, M.Object_Player, 1);
				Attack(M.Object_Nadir2, M.Object_Player, 1);

				Goto(M.Object_Nadir3, "hardin", 1);
				Goto(M.Object_Nadir4, "hardin", 1);

				M.Routine3Timer = GetTime() + 35;

				M.Routine3State = 6;
			end
		end
	end
end

-- Routine for the final cutscene of the mission.
function Routine4()
	if (M.Routine4Enable == true) then
		if (M.Routine4State == 0) then
			CameraReady();

			-- Ally both edf teams with the drones to prevent any accidents during cutscene
			Ally(1, 2);
			Ally(2, 9);

			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 1 then
			if (CameraPath("end", 4000, 1000, M.Object_Carrier)) then
				M.Routine4WaitTillTime = GetTime() + 27;
				
				M.Routine4State = M.Routine4State + 1;
			end
		elseif M.Routine4State == 2 then
			SetCameraPosition(GetPosition(M.Object_CarrierLaunchCamDummy), SetVector(0,1,0));
			
			if (GetTime() >= M.Routine4WaitTillTime) then
				CameraFinish();
				M.Routine4State = M.Routine4State + 1;
			end
		end
	end
end

-- Handles checking if special units exist within the mission.
function Routine5()
	if (M.EnableFailCheck) then
		if (not IsAround(M.Object_WyndtEssex)) then
			M.EnableFailCheck = false;
			
			ClearObjectives();
			AddObjective("mercedf108.otf", "red");
			FailMission(GetTime() + 10, "rodmerc.des");
		elseif (not IsAround(M.Object_Cargo2)) then
			M.EnableFailCheck = false;
			
			ClearObjectives();
			AddObjective("mercedf110.otf", "red");
			FailMission(GetTime() + 10, "transmerc.des");
		elseif (not IsAround(M.Object_Hardin)) then
			M.EnableFailCheck = false;
			
			ClearObjectives();
			AddObjective("mercedf109.otf", "red");
			FailMission(GetTime() + 10, "hardmerc.des");
		
		elseif (not IsAround(M.Object_HardinPilot) and HasPilot(M.Object_Hardin) == false) then
			M.EnableFailCheck = false;
			
			ClearObjectives();
			AddObjective("mercedf109.otf", "red");
			FailMission(GetTime() + 10, "hardmerc.des");
		elseif (M.CerbRoutine and not IsAround(M.Object_CerbUnit)) then 
			M.EnableFailCheck = false;
		
			ClearObjectives();
			AddObjective("mercedf112.otf", "red");
			FailMission(GetTime() + 10, "cerbmerc.des"); -- WRITE ME! AHadley? "You failed to follow wynt essex's orders, blablabla."
		end
	end
end

-- Handle the logic of the "Unknown" Cerberi unit that is venturing through some of the EDF buildings.
function Routine6() 
	if (M.CerbRoutine) then
		if (M.Routine6State == 0) then
			M.Object_CerbUnit = BuildObjectAndLabel("cvscout", 4, "TritonSpawn", "CerbUnit"); --updating location to be in a better spot no blue_goto_power_2 -Gravey
			
			SetObjectiveName(M.Object_CerbUnit, "Unknown");
			
			--Goto(M.Object_CerbUnit, M.Object_Gun10, 1); removed to make better sense with new spawn point.
			
			M.Routine6Timer = GetTime() + 8;
			
			M.Routine6State = M.Routine6State + 1;
		elseif (M.Routine6State == 1) then
			if (GetTime() >= M.Routine6Timer) then
				Retreat(M.Object_CerbUnit, "path_2", 1);
				
				M.Routine6State = M.Routine6State + 1;
			end
		elseif (M.Routine6State == 2) then
			if (GetDistance(M.Object_CerbUnit, "DeleteTriton") <= 10) then --changed path point
				M.CerbRoutine = false; --stop cerb routine failcheck. --Gravey
				RemoveObject(M.Object_CerbUnit); -- delete triton when it reaches out of bounds Gravey
				--M.Routine6State = M.Routine6State + 1;
			else
				local h = GetWhoShotMe(M.Object_CerbUnit);
				
			end
				if (IsPlayer(h)) then
					AudioMessage("mercury_07a.wav");
					M.Routine6State = M.Routine6State + 1;
				end
			end
		elseif (M.Routine6State == 3) then
			--RemoveObject(M.Object_CerbUnit); -- I don't like the idea of this poofing into nothingness. Do something else? either leave it till it's offmap, or zoof it up into space? actually, hold that thought...
			--SetVelocity(M.Object_CerbUnit, SetVector(0, 10000, 0)); -- Just kidding... :P
			--local OffMap = SetVector(-4000, TerrainFindFloor(-4000, -4000), -4000);
			--Goto(M.CerbUnit, OffMap, 1);
			if (GetDistance(M.Object_CerbUnit, "DeleteTriton") <= 10) then --changed path point
				M.CerbRoutine = false; --stop cerb routine failcheck. --Gravey
				RemoveObject(M.Object_CerbUnit);
			end
		--	M.Routine6State = M.Routine6State + 1;
		--Unecessary state check -- Gravey
		end
		
		-- If cerb unit dies, fail mission.
		if(M.Routine6State > 0) then
		
		end
	end
--handles giving player scouts based on their arrival to "convoy_halt"
function Routine7()  
	if (M.Routine7Enable == true) then
	
		if(GetDistance(M.Object_Scout1, "convoy_halt") <= 100 and (GetDistance(M.Object_Scout2, "convoy_halt") <= 100) and M.Routine7State < 1) then --added condition so player cannot break their return path early --Gravey
			SetTeamNum(M.Object_Scout1, 1);
			SetTeamNum(M.Object_Scout2, 1);
			SetGroup(M.Object_Scout1, 0);
			SetGroup(M.Object_Scout2, 0);
			Goto(M.Object_Scout2,"convoy_halt", 0);
			Goto(M.Object_Scout1,"convoy_halt", 0);
			M.Routine7State = M.Routine7State + 1;
			M.ScoutsPassedToPlayer = true;
		end
		
		
	end
end
-- Prevent meteor damage to key structures until we need this to happen.
function DamagePrevention()
	if (M.PreventPowerDamage) then
		if (not M.SetGun10Health) then
			SetCurHealth(M.Object_Gun10, 20000); --cleanup to avoid visual HP spike -Gravey
			--SetCurHealth(M.Object_Gun10, 3000);
			SetCurHealth(M.Object_Power1, 800);
			SetCurHealth(M.Object_Power2, 800);
			SetCurHealth(M.Object_Power3, 800);
			SetCurHealth(M.Object_Power4, 800);

			M.SetGun10Health = true;
		end
		
		if (IsPlayer(GetWhoShotMe(M.Object_Gun10))) then
			SetCurHealth(M.Object_Gun10, 3000);
			SetCurHealth(M.Object_Power1, 800);
			SetCurHealth(M.Object_Power2, 800);
			SetCurHealth(M.Object_Power3, 800);
			SetCurHealth(M.Object_Power4, 800);
			
			M.PreventPowerDamage = false;
		end
	end
end