_Text1 = "Protect your assigned transport,\nhighlighted with a blue beacon.\nIt's carrying biometal-refining\nmodules for our Recycler, so\ndon't lose it!";
_Text2 = "Follow Major Wyndt-Essex. Stay\nin loose formation, and cover\nher as necessary.";
_Text3 = "Take out the gun tower near\nthe bridge. Major Wyndt-Essex\nwill stay out of range and watch\nfor enemy patrols.";
_Text4 = "Now, take out the power supply.\nAnd hurry up; the Major says you\nare taking far too long!";
_Text5 = "ATTENTION ALL UNITS: Begin to\nboard the StormPetrel in an\norderly fashion.";
_Text6 = "Follow Hardin and head over to\nthe Training Center at the base.\nHop out of your vehicle and join\nthe General inside.";
_Text7 = "Get into the StormPetrel.";
_Text8 = "Your negligence and cowardice\nhave led to the death of Major\nWyndt-Essex.";
_Text9 = "General Hardin is dead, and\nwith him all our hopes for \ndefending Earth from the Hadean\ninvasion.";
_Text10 = "You failed to protect the\ntransport as directed. Without\nthe biometal-refining modules,\nour mission cannot continue.\nPrepare to head back to Earth.";
_Text11 = "Defend the transports in the\nconvoy. Each one is carrying\ncritical components necessary\nfor our mission's success.";
_Text12 = "haha, you lazy mpi players\njust plain suck. LOL";

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

-- Floats
	MissionTimer = 0.0,
	convoyWaitTillTime = 0.0,
	powerPlayerWaitTillTime = 0.0,
	CerbWaitTillTime = 0.0,
	Routine4WaitTillTime = 0.0,

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
	Object_CerbUnitShotBy = nil,

	SCOUTODF = "ivscout11",
	SERVODF = "ivserv",
	CARGOODF = "ivcargo",
	DRONEODF = "nadir",

-- Ints
	MissionState = 0,
	RunAIPowerState = 0,
	RunPowerPlayerState = 0,
	CerbState = 0,
	Routine4State = 0,

-- Vectors
	Position_LandingZone1 = SetVector(-674.0,1000.0,-783.0),
	Position_LandingZone2 = 0,
	Position_LandingZone3 = 0,
	Position_CarrierLaunchCamDummy = SetVector(-674.0,80.0,-782.0),
	Position_ServiceBay = 0
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
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Start()
	M.Object_WyndtEssex = GetHandle("Rodriguez");
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

	M.Object_Radar1 = GetHandle("Radar1");
	M.Object_Radar2 = GetHandle("Radar2");
end

function AddObject(h)

end

function DeleteObject(h)

end

function Update()
	M.Object_Player = GetPlayerHandle();
	if(M.MissionTimer < GetTime()) then
		if M.MissionState == 0 then
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 1 then
			StartEarthQuake(1.5);
			M.Position_LandingZone3 = GetPosition(M.Object_Player);
			M.Object_Stayput = BuildObject("stayput", 0, M.Position_LandingZone3);
			M.convoyWaitTillTime = GetTime() + 1;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 2 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 3 then
			Ally(1,9);
			UnAlly(9,2);
			IFace_Exec("merc01.cfg");
			FreeCamera();
			IFace_Activate("INFO1");
			IFace_Activate("Start1");
			M.MissionState = M.MissionState + 1
		elseif M.MissionState == 4 then
			if(CameraReady()) then
				local pos = GetPosition(M.Object_Player);
				local ang = GetFront(M.Object_Player);
				pos.y = pos.y + 3.0;
				SetCameraPosition(pos, ang);
				IFace_Deactivate("Start1");
				IFace_Activate("Message");
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 5 then
			local ifaceVal = IFace_GetInteger("images.page");
			if(ifaceVal == 4) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 6 then
			IFace_Deactivate("INFO1");
			IFace_Deactivate("Message");
			IFace_Exec("mercedf1.cfg");
			IFace_Activate("INFO");
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 7 then
			--M.Object_CarrierLaunchCamDummy = BuildObject("dummy",2,M.Position_LandingZone1);
			M.Position_ServiceBay = GetPosition(M.Object_ServiceBay);
			SetGroup(M.Object_WyndtEssex,10);
			SetObjectiveName(M.Object_WyndtEssex,"Wyndt-Essex");
			M.Object_Hardin = BuildObject(M.SCOUTODF,9,"hardin_spawn");
			SetObjectiveName(M.Object_Hardin,"Hardin");
			M.Object_Scout1 = BuildObject(M.SCOUTODF,9,"red_spawn");
			M.Object_Scout2 = BuildObject(M.SCOUTODF,9,"red_spawn");
			M.Object_Scout3 = BuildObject(M.SCOUTODF,9,"blue_spawn");
			M.Object_ServTruck1 = BuildObject(M.SERVODF,1,"blue_spawn");
			SetGroup(M.Object_ServTruck1,10);
			M.Object_ServTruck2 = BuildObject(M.SERVODF,9,"landing_zone");
			M.Object_Cargo1 = BuildObject(M.CARGOODF,9,"landing_zone");
			M.Object_Cargo2 = BuildObject(M.CARGOODF,9,"landing_zone");
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 8 then
			local ifaceVal = IFace_GetInteger("images.page");
			if(ifaceVal == 3) then
				FreeFinish();
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 9 then
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 10 then
			CameraFinish();
			IFace_Deactivate("INFO");
			Goto(M.Object_Cargo1, "convoy", 1);
			M.convoyWaitTillTime = GetTime() + 1;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 11 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 12 then
			UpdateEarthQuake(4.0);
			LookAt(M.Object_WyndtEssex, M.Object_Player, 1);
			M.convoyWaitTillTime = GetTime() + 1;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 13 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 14 then
			AudioMessage("mercury_02.wav");
			M.convoyWaitTillTime = GetTime() + 9;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 15 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 16 then
			SetObjectiveOn(M.Object_Cargo2);
			AddObjective(_Text1, "white");
			StopEarthQuake();
			SetAnimation(M.Object_Condor, "deploy", 1);
			StartAnimation(M.Object_Condor);
			AudioMessage("dropdoor.wav");
			RemoveObject(M.Object_Stayput);
			M.PlayerCanMove = true;
			Goto(M.Object_Scout2, "convoy", 1);
			Defend2(M.Object_WyndtEssex, M.Object_Cargo2, 1);
			Follow(M.Object_ServTruck1, M.Object_Cargo2, 1);
			Follow(M.Object_ServTruck2, M.Object_Cargo2, 1);
			Follow(M.Object_Hardin, M.Object_Cargo1, 1);
			Follow(M.Object_Scout1, M.Object_Cargo1, 1);
			Goto(M.Object_Scout3, "convoy", 1);
			M.EnableFailCheck = true;
			M.convoyWaitTillTime = GetTime() + 5;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 17 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 18 then
			Goto(M.Object_Cargo2, "convoy", 1);
			M.convoyWaitTillTime = GetTime() + 30;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 19 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 20 then
			M.Object_Nadir1 = BuildObject(M.DRONEODF, 2, "NadirAttackSpawn");
			SetPerceivedTeam(M.Object_Nadir1, 1);
			Attack(M.Object_Nadir1, M.Object_Cargo2, 1);
			AudioMessage("mercury_02a.wav");
			M.convoyWaitTillTime = GetTime() + 13;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 21 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 22 then
			SetPerceivedTeam(M.Object_Nadir1, 2);
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 23 then
			if(GetDistance(M.Object_Cargo2, "convoy_halt") <= 50) then
				SetObjectiveOff(M.Object_Cargo2);
				AudioMessage("mercury_03.wav");
				M.convoyWaitTillTime = GetTime() + 19;
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 24 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 25 then
			ClearObjectives();
			AddObjective(_Text2, "white");
			M.RunPowerAIStateMachine = true;
			M.RunPowerPlayerStateMachine = true;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 26 then
			local radar1 = GetTeamNum(M.Object_Radar1);
			local radar2 = GetTeamNum(M.Object_Radar2);
			if(radar1 == 0 and radar2 == 0) then
				SetTeamNum(M.Object_Gun1, 0);
				SetTeamNum(M.Object_Gun2, 0);
				SetTeamNum(M.Object_Gun3, 0);
				SetTeamNum(M.Object_Gun4, 0);
				SetTeamNum(M.Object_Gun5, 0);
				SetTeamNum(M.Object_Gun6, 0);
				SetTeamNum(M.Object_Gun7, 0);
				SetTeamNum(M.Object_Gun8, 0);
				M.convoyWaitTillTime = GetTime() + 8;
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 27 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 28 then
			AudioMessage("mercury_07.wav");
			AddObjective(_Text11, "white");
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 29 then
			if M.ConvoyContinueToBase == true then
				Goto(M.Object_Hardin, "hardin", 1);
				M.convoyWaitTillTime = GetTime() + 15;
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 30 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 31 then
			Goto(M.Object_WyndtEssex, "hardin", 1);
			M.convoyWaitTillTime = GetTime() + 5;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 32 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 33 then
			Goto(M.Object_Cargo1, "transport1", 1);
			M.convoyWaitTillTime = GetTime() + 10;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 34 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 35 then
			Goto(M.Object_Cargo2, "transport1", 1);
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 36 then
			local d1 = GetDistance(M.Object_Cargo1, M.Object_ServiceBay);
			local d2 = GetDistance(M.Object_Cargo2, M.Object_ServiceBay);
			local d3 = GetDistance(M.Object_WyndtEssex, M.Object_ServiceBay);
			if d1 <= 300 and d2 <= 300 and d3 <= 300 then
				M.EnableFailCheck = false;
				M.RunPowerPlayerStateMachine = false;
				SetObjectiveOn(M.Object_Hardin);
				Ally(2,9);
				SetTeamNum(M.Object_Scout1, 9);
				SetTeamNum(M.Object_Scout2, 9);
				SetTeamNum(M.Object_Scout3, 9);
				Retreat(M.Object_Scout1, "hardin", 1);
				Retreat(M.Object_Scout2, "hardin", 1);
				Retreat(M.Object_Scout3, "hardin", 1);
				ClearObjectives();
				LookAt(M.Object_Hardin, M.Object_Player, 1);
				AddObjective(_Text6, "white");
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
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 37 then
			if(GetDistance(M.Object_Hardin, M.Object_Player) <= 200) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 38 then
			Goto(M.Object_WyndtEssex, M.Object_ServiceBay, 1);
			Goto(M.Object_Scout1, M.Object_ServiceBay, 1);
			Goto(M.Object_Scout2, M.Object_ServiceBay, 1);
			Goto(M.Object_Scout3, M.Object_ServiceBay, 1);
			HopOut(M.Object_Hardin);
			SetTeamNum(M.Object_Corbernav, 1);
			SetObjectiveOn(M.Object_Corbernav);
			SetObjectiveOff(M.Object_Hardin);
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 39 then
			if(GetDistance(M.Object_Corbernav, M.Object_Player) <= 10) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 40 then
			StartEarthQuake(4.0);
			M.CerbRoutine = false;
			ClearObjectives();
			AddObjective(_Text5, "green");
			AudioMessage("mercury_08a.wav");
			HopOut(M.Object_Scout1);
			HopOut(M.Object_Scout2);
			HopOut(M.Object_Scout3);
			M.convoyWaitTillTime = GetTime() + 3;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 41 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 42 then
			RemoveObject(M.Object_Cargo1);
			RemoveObject(M.Object_Cargo2);
			M.Routine4Enable = true;
			local mat = GetTransform(M.Object_Carrier);
			RemoveObject(M.Object_Carrier);
			M.Object_Carrier = BuildObject("ivcarrs_ani", 1, mat);
			M.convoyWaitTillTime = GetTime() + 7;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 43 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 44 then
			AudioMessage("dropleav.wav");
			M.convoyWaitTillTime = GetTime() + 10;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 45 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 46 then
			AudioMessage("mercury_09.wav");
			M.convoyWaitTillTime = GetTime() + 12;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 47 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 48 then
			local mat = GetTransform(M.Object_Carrier);
			RemoveObject(M.Object_Carrier);
			M.Object_Carrier = BuildObject("ivcarrs", 1, mat);
			M.convoyWaitTillTime = GetTime() + 12;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 49 then
			if(GetTime() >= M.convoyWaitTillTime) then
				M.MissionState = M.MissionState + 1;
			end
		elseif M.MissionState == 50 then
			StopEarthQuake();
			SucceedMission(0, "winmerc.des");
			M.MissionState = M.MissionState + 1;
		end
	end
	
	RunAIPowerState();
	RunPlayerPowerState();
	RunCerbRoutine();
	FailCheckFunction();
	DamagePrevention();
	Routine4();
end

function RunAIPowerState() -- Handle AI Power Attacking
	if M.RunPowerAIStateMachine == true then
		if M.RunAIPowerState == 0 then
			M.RunAIPowerState = M.RunAIPowerState + 1;
		elseif M.RunAIPowerState == 1 then
			Goto(M.Object_Scout2, "scout1", 1);
			Goto(M.Object_Scout1, "scout1", 1);
			M.RunAIPowerState = M.RunAIPowerState + 1;
		elseif M.RunAIPowerState == 2 then
			if(GetDistance(M.Object_Scout1, "red_goto_power") <= 20) then
				M.RunAIPowerState = M.RunAIPowerState + 1;
			end
		elseif M.RunAIPowerState == 3 then
			RemoveObject(M.Object_Gun9);
			Attack(M.Object_Scout2, M.Object_Power7, 1);
			Attack(M.Object_Scout1, M.Object_Power7, 1);
			M.RunAIPowerState = M.RunAIPowerState + 1;
		elseif M.RunAIPowerState == 4 then
			if not IsAround(M.Object_Power7) then
				M.RunAIPowerState = M.RunAIPowerState + 1;
			end
		elseif M.RunAIPowerState == 5 then
			SetCurAmmo(M.Object_Scout2, 800);
			SetCurAmmo(M.Object_Scout1, 800);
			Attack(M.Object_Scout2, M.Object_Power6, 1);
			Attack(M.Object_Scout1, M.Object_Power6, 1);
			M.RunAIPowerState = M.RunAIPowerState + 1;
		elseif M.RunAIPowerState == 6 then
			if not IsAround(M.Object_Power6) then
				M.RunAIPowerState = M.RunAIPowerState + 1;
			end	
		elseif M.RunAIPowerState == 7 then
			SetCurAmmo(M.Object_Scout2, 800);
			SetCurAmmo(M.Object_Scout1, 800);
			Attack(M.Object_Scout2, M.Object_Power5, 1);
			Attack(M.Object_Scout1, M.Object_Power5, 1);
			M.RunAIPowerState = M.RunAIPowerState + 1;
		elseif M.RunAIPowerState == 8 then
			if not IsAround(M.Object_Power5) then
				M.RunAIPowerState = M.RunAIPowerState + 1;
			end
		elseif M.RunAIPowerState == 9 then
			SetTeamNum(M.Object_Radar1, 0);
			Goto(M.Object_Scout2, "scout3", 0);
			Goto(M.Object_Scout1, "scout3", 0);
			M.RunAIPowerState = M.RunAIPowerState + 1;
		end
	end
end

function RunPlayerPowerState() -- Handle Player Attacking Power
	if M.RunPowerPlayerStateMachine == true then
		if M.RunPowerPlayerState == 0 then
			M.RunPowerPlayerState = M.RunPowerPlayerState + 1
		elseif M.RunPowerPlayerState == 1 then
			SetCurHealth(M.Object_Gun10, 20000);
			SetObjectiveOn(M.Object_WyndtEssex);
			LookAt(M.Object_WyndtEssex, M.Object_Player, 1);
			AudioMessage("mercury_04.wav");
			M.Object_Nadir1 = BuildObject(M.DRONEODF, 2 ,"NadirAttackSpawn");
			Attack(M.Object_Nadir1, M.Object_WyndtEssex, 1);
			Goto(M.Object_WyndtEssex, "rod1", 1);
			SetMaxHealth(M.Object_Power1, 800);
			SetMaxHealth(M.Object_Power2, 800);
			SetMaxHealth(M.Object_Power3, 800);
			SetMaxHealth(M.Object_Power4, 800);
			M.RunPowerPlayerState = M.RunPowerPlayerState + 1
		elseif M.RunPowerPlayerState == 2 then
			if(GetDistance(M.Object_WyndtEssex, "blue_goto_power_1") <= 20) then
				M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
			end
		elseif M.RunPowerPlayerState == 3 then
			if(GetDistance(M.Object_Player, M.Object_WyndtEssex) <= 50) then
				M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
			end
		elseif M.RunPowerPlayerState == 4 then
			LookAt(M.Object_WyndtEssex, M.Object_Player, 1);
			AudioMessage("mercury_05.wav");
			M.powerPlayerWaitTillTime = GetTime() + 1;
			M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
		elseif M.RunPowerPlayerState == 5 then
			if(GetTime() >= M.powerPlayerWaitTillTime) then
				M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
			end
		elseif M.RunPowerPlayerState == 6 then
			ClearObjectives();
			AddObjective(_Text3, "white");
			M.CerbRoutine = true;
			SetObjectiveOn(M.Object_Gun10);
			M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
		elseif M.RunPowerPlayerState == 7 then
			if not IsAround(M.Object_Gun10) then
				M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
			end
		elseif M.RunPowerPlayerState == 8 then
			Goto(Object_WyndtEssex,"blue_goto_power_2",1);
			ClearObjectives();
			AddObjective(_Text3, "green");
			AddObjective(_Text4, "white");
			M.powerPlayerWaitTillTime = GetTime() + 22;
			M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
		elseif M.RunPowerPlayerState == 9 then
			if(GetTime() >= M.powerPlayerWaitTillTime) then
				M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
			end
		elseif M.RunPowerPlayerState == 10 then
			SetPosition(M.Object_WyndtEssex, "blue_goto_power_2");
			M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
		elseif M.RunPowerPlayerState == 11 then
			if not IsAround(M.Object_Power1) and not IsAround(M.Object_Power2) and not IsAround(M.Object_Power3) and not IsAround(M.Object_Power4) then
				M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
			end
		elseif M.RunPowerPlayerState == 12 then
			SetTeamNum(M.Object_Radar2, 0);
			ClearObjectives();
			AddObjective(_Text2, "white");
			AudioMessage("mercury_06.wav");
			Goto(M.Object_WyndtEssex, "path_1", 1);
			M.Object_Nadir1 = BuildObject(M.DRONEODF, 2, "NadirAttackSpawn");
			M.Object_Nadir2 = BuildObject(M.DRONEODF, 2, "NadirAttackSpawn");
			Attack(M.Object_Nadir1, M.Object_WyndtEssex, 1);
			Attack(M.Object_Nadir2, M.Object_Player, 1);
			M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
		elseif M.RunPowerPlayerState == 13 then
			if(GetDistance(M.Object_WyndtEssex, "convoy_halt") <= 50) then
				M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
			end
		elseif M.RunPowerPlayerState == 14 then
			SetObjectiveOff(M.Object_WyndtEssex);
			SetTeamNum(M.Object_Scout2, 1);
			SetTeamNum(M.Object_Scout3, 1);
			SetGroup(M.Object_Scout2, 0);
			SetGroup(M.Object_Scout3, 0);
			Follow(M.Object_Scout3, M.Object_Player, 0);
			SetTeamNum(M.Object_Scout1, 1);
			SetTeamNum(M.Object_ServTruck2, 1);
			SetGroup(M.Object_Scout1, 0);
			SetGroup(M.Object_ServTruck2, 8);
			SetGroup(M.Object_ServTruck1, 8);
			Service(M.Object_ServTruck1, M.Object_Cargo1, 0);
			Service(M.Object_ServTruck2, M.Object_Cargo2, 0);
			M.powerPlayerWaitTillTime = GetTime() + 80;
			M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
		elseif M.RunPowerPlayerState == 15 then
			if(GetTime() >= M.powerPlayerWaitTillTime) then
				M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
			end
		elseif M.RunPowerPlayerState == 16 then
			M.Object_Nadir1 = BuildObject(M.DRONEODF, 2, "NadirAttackSpawn");
			M.Object_Nadir2 = BuildObject(M.DRONEODF, 2, "NadirAttackSpawn");
			M.Object_Nadir3 = BuildObject(M.DRONEODF, 2, "NadirAttackSpawn");
			Attack(M.Object_Nadir1, M.Object_WyndtEssex, 1);
			Attack(M.Object_Nadir2, M.Object_Cargo2, 1);
			Attack(M.Object_Nadir3, M.Object_Player, 1);
			M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
		elseif M.RunPowerPlayerState == 17 then
			if not IsAround(M.Object_Nadir1) and not IsAround(M.Object_Nadir2) and not IsAround(M.Object_Nadir3) then
				M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
			end
		elseif M.RunPowerPlayerState == 18 then
			M.ConvoyContinueToBase = true;
			M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
		elseif M.RunPowerPlayerState == 19 then
			M.powerPlayerWaitTillTime = GetTime() + 35;
			M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
		elseif M.RunPowerPlayerState == 20 then
			if(GetTime() >= M.powerPlayerWaitTillTime) then
				M.RunPowerPlayerState = M.RunPowerPlayerState + 1;
			end
		elseif M.RunPowerPlayerState == 21 then
			M.Object_Nadir1 = BuildObject(M.DRONEODF, 2, "NadirAttackSpawn");
			M.Object_Nadir2 = BuildObject(M.DRONEODF, 2, "NadirAttackSpawn");
			M.Object_Nadir3 = BuildObject(M.DRONEODF, 2, "NadirAttackSpawn");
			M.Object_Nadir4 = BuildObject(M.DRONEODF, 2, "NadirAttackSpawn");
			Attack(M.Object_Nadir1, M.Object_Player, 1);
			Attack(M.Object_Nadir2, M.Object_Player, 1);
			Goto(M.Object_Nadir3, "hardin", 1);
			Goto(M.Object_Nadir4, "hardin", 1);
			M.RunPowerPlayerState = 19;
		end
	end
end

function RunCerbRoutine()
	if M.CerbRoutine == true then
		if M.CerbState == 0 then
			M.CerbState = M.CerbState + 1;
		elseif M.CerbState == 1 then
			M.Object_CerbUnit = BuildObject("cvscout", 4, "blue_goto_power_2");
			SetObjectiveName(M.Object_CerbUnit, "Unknown");
			Goto(M.Object_CerbUnit, M.Object_Gun10, 1);
			M.CerbWaitTillTime = GetTime() + 8;
			M.CerbState = M.CerbState + 1;
		elseif M.CerbState == 2 then
			if(GetTime() >= M.CerbWaitTillTime) then
				M.CerbState = M.CerbState + 1;
			end
		elseif M.CerbState == 3 then
			Retreat(M.Object_CerbUnit, "path_2", 1);
			M.CerbState = M.CerbState + 1;
		elseif M.CerbState == 4 then
			if(GetDistance(M.Object_CerbUnit, "path_2", 3) <= 100) then
				M.CerbState = 7;
			else
				M.Object_CerbUnitShotBy = GetWhoShotMe(M.Object_CerbUnit);
				if(IsPlayer(M.Object_CerbUnitShotBy)) then
					AudioMessage("mercury_07a.wav");
					M.CerbState = M.CerbState + 1;
				end
			end
		elseif M.CerbState == 5 then
			if(GetDistance(M.Object_CerbUnit, "path_2", 3) <= 10) then
				M.CerbState = 7;
			else
				if(GetCurHealth(M.Object_CerbUnit) <= 1000) then
					EjectPilot(Object_Player);
					AddObjective(_Text12, "violet");
					M.CerbState = M.CerbState + 1;
				end
			end
		elseif M.CerbState == 6 then
			return;
		elseif M.CerbState == 7 then
			RemoveObject(M.Object_CerbUnit);
			M.CerbState = M.CerbState + 1;
		end
	end
end

function FailCheckFunction()
	if M.EnableFailCheck == true then
		if not IsAround(M.Object_WyndtEssex) then
			M.EnableFailCheck = false;
			ClearObjectives();
			AddObjective(_Text8, "red");
			FailMission(GetTime() + 10, "rodmerc.des");
		elseif not IsAround(M.Object_Cargo2) then
			M.EnableFailCheck = false;
			ClearObjectives();
			AddObjective(_Text10, "red");
			FailMission(GetTime() + 10, "transmerc.des");
		elseif not IsAround(M.Object_Hardin) then
			M.EnableFailCheck = false;
			ClearObjectives();
			AddObjective(_Text9, "red");
			FailMission(GetTime() + 10, "hardmerc.des");
		end
	end
end

function Routine4()
	if M.Routine4Enable == true then
		if M.Routine4State == 0 then
			M.RunPowerPlayerStateMachine = false;
			CameraReady()
			M.Routine4State = M.Routine4State + 1;
		elseif M.Routine4State == 1 then
			if(CameraPath("end", 4000, 1000, M.Object_Carrier)) then
				M.Routine4WaitTillTime = GetTime() + 27;
				M.Routine4State = M.Routine4State + 1;
			end
		elseif M.Routine4State == 2 then
			SetCameraPosition(M.Position_CarrierLaunchCamDummy, SetVector(0,1,0));
			if(GetTime() >= M.Routine4WaitTillTime) then
				CameraFinish();
				M.Routine4State = M.Routine4State + 1;
			end
		end
	end
end

function DamagePrevention()
	if M.PreventPowerDamage == true then
		if M.SetGun10Health == false then
			SetCurHealth(M.Object_Gun10, 20000);

			SetCurHealth(M.Object_Gun10, 3000);
			SetCurHealth(M.Object_Power1, 800);
			SetCurHealth(M.Object_Power2, 800);
			SetCurHealth(M.Object_Power3, 800);
			SetCurHealth(M.Object_Power4, 800);

			M.SetGun10Health = true;
		end
		
		if IsPlayer(GetWhoShotMe(M.Object_Gun10)) then
			SetCurHealth(M.Object_Gun10, 3000);
			SetCurHealth(M.Object_Power1, 800);
			SetCurHealth(M.Object_Power2, 800);
			SetCurHealth(M.Object_Power3, 800);
			SetCurHealth(M.Object_Power4, 800);
			M.PreventPowerDamage = false;
		end
	end
end