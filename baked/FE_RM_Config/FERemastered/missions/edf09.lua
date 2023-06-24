----------------------------------------------------------------
-- FE edf09.lua Mission - Version 1.0
-- Date Modified: 11/01/2021
-- Summary: Mission script for the EDF09 Forgotten Enemies Mission.
----------------------------------------------------------------

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

local Position2 = SetVector(-800,22,-326);	--cerb reinforcements spawn location
local Position3 = SetVector(-80,30,700);	--cerb attacker spawn
local Position4 = SetVector(315,-15,-525);	--debris spawn
local Position7 = SetVector(-183,-12,55);	--mlight move target

-- EarthQuake Damage Value Ratios. (Ratio of MaxHealth to damage, min and max randomized)
local damageValues = {
	{"0.05", "0.10"}, -- First stage min/max.
	{"0.10", "0.15"}, -- Second stage min/max.
	{"0.15", "0.20"}, -- Third stage min/max.
	{"0.20", "0.30"} -- Critical stage min/max.
};

local M = {
-- Bools
	EarthquakeStarted = false,
	SettleEarthquake = false,
	SpawnFireEffects = false,
	SpawnFirstMeteor = false,
	SpawnSecondMeteor = false,
	Routine4Active = false,

-- Floats
	EarthquakeCooldown = 0.0,

	Routine1Timer = 0.0,
	Routine2Timer = 0.0,
	Routine3Timer = 0.0,
	Routine4Timer = 0.0,

-- Handles
	RecyDeployed = nil,
	HadeanRecy = nil,
	Recycler = nil,	--Recycler (undeployed)
	MLight = nil,
	Portal = nil,
	BuildingsToDamage = {},

-- Ints
	EarthquakeStage = 1,
	EarthquakeStageProgressTracker = 0,

	TriggerEQStage2 = 6,
	TriggerEQStage3 = 10,
	TriggerEQStage4 = 16, -- If the player hasn't undeplyed their Recycler, apply a critical amount of damage.

	Routine1State = 0,
	Routine2State = 0,
	Routine3State = 0,
	Routine4State = 0,
	Variable2 = 40,	--mlight rotate rate
	Variable3 = 100,	--mlight move speed

-- Bools
	RecyTeleported = false,
	EnablePlayerTeleport = false,

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
	
	AllowRandomTracks(false);
	
	PreloadODF("ibrecy09");
	PreloadODF("evrecy");
	PreloadODF("cvscout");
	PreloadODF("cvdcar");
	PreloadODF("cvtank");
	PreloadODF("cvrbomb");
	PreloadODF("meteor");
	PreloadODF("vsmoke");
	PreloadODF("vfire");
	PreloadODF("mlight");
	
	local preloadAudio = {
		"edf09a.wav",
		"edf09b.wav",
		"edf09c.wav",
		"edf09t.wav",
		"edf09t2.wav"
	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Start()
	_FECore.Start();
	
	M.Portal = GetHandle("unnamed_hbport");
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end


function AddObject(h)
	_FECore.AddObject(h);

	if GetOdf(h) == "ivrecy09.odf" then	--GetCfg() sometimes returns the name with ":1" appended to it.
		M.Recycler = h;
	end

	-- Added a check to store any 
	local teamNum = GetTeamNum(h);
	local isBuilding = (IsBuilding(h) or GetClassLabel(h) == "VIRTUAL_CLASS_GUNTOWER"); -- Gun Towers are classed as craft so need a special check.

	if (teamNum > 0 and teamNum < MAX_TEAMS and IsBuilding(h)) then
		table.insert(M.BuildingsToDamage, h);
	end
end

function DeleteObject(h)
	_FECore.DeleteObject(h);	
end

function Update()
	_FECore.Update();

	Routine1();
	Routine2();

	-- Only do this method when the initial Recycler has been built by the first routine.
	if (M.Routine1State > 0) then
		Routine3();
	end

	Routine4();
	TeleportRoutine();
end

function Succeed(time)
	SucceedMission(time, "edf09c.des");
end

function TeleportAndSucceed()
	BuildObject("teleportout", 0, BuildDirectionalMatrix(GetPosition(GetPlayerHandle())));
	SetColorFade(2.0, 1.0, 32767);
	StartSoundEffect("teleport.wav", nil);
	Succeed(GetTime() + 0.5);
end

--handles undeploying the recycler, checks if Recycler died
function Routine1()
	if M.Routine1Timer < GetTime() then
		if M.Routine1State == 0 then
			local pos = GetPosition("Deploy");
			pos.y = TerrainFindFloor(pos);
			M.RecyDeployed = BuildObject("ibrecy09", 1, BuildDirectionalMatrix(pos));
			SetScrap(1, 40);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 1 then
			ClearObjectives();
			AddObjective("edf0901.otf", "white");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 2 then	--LOC_5
			if IsAround(M.Recycler) then
				RemoveObject(M.RecyDeployed);
				SetObjectiveOn(M.Recycler);
				SetObjectiveName(M.Recycler, "Recycler");
				Goto(M.Recycler, "recy", 1);
				ClearObjectives();
				AudioMessage("edf09b.wav");
				AddObjective("edf0905.otf", "white");

				-- Spawn Drone Carrier:
				Attack(BuildObject("cvdcar", 5, Position3), M.Recycler, 0);

				M.Routine1State = M.Routine1State + 1;
			elseif not IsAround(M.RecyDeployed) then
				M.Routine1State = 4;
			end
		elseif M.Routine1State == 3 then --LOC_17
			if not IsAround(M.Recycler) then
				M.Routine1State = M.Routine1State + 1;
			elseif IsDeployed(M.Recycler) then
				--player redeployed the recycler after undeploying
				FailMission(GetTime() + 5, "edf09b.des");
				M.Routine1State = 99;
			end
		elseif M.Routine1State == 4 then
			-- Recycler has teleported out, no need to check if it is alive
			if (M.RecyTeleported == true) then
				M.Routine1State = 99;
				return;
			end

			--recycler was destroyed
			FailMission(GetTime() + 5, "edf09a.des");
			M.Routine1State = M.Routine1State + 1;
		end
	end
end

--handles the escort
function Routine2()
	if M.Routine2Timer < GetTime() then
		if M.Routine2State == 0 then
			SetObjectiveOn(M.Portal);
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 5;
		elseif M.Routine2State == 1 then
			AudioMessage("edf09a.wav");
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 2 then
			if IsAround(M.Recycler) then
				M.Routine2State = M.Routine2State + 1;
			end
		elseif M.Routine2State == 3 then
			if (GetDistance(M.Recycler, "recy_breakdown") < 35) then
				Attack(BuildObject("cvscout", 5, Position3), M.Recycler, 1);
				Stop(M.Recycler, 1);
				AudioMessage("edf09t.wav");
				ClearObjectives();
				AddObjective("edf0907.otf", "white");
				M.MLight = BuildObject("mlight", 5, "mlight");
				M.Routine2State = M.Routine2State + 1;
			end
		elseif M.Routine2State == 4 then
			if Move(M.MLight, M.Variable2, M.Variable3, Position7) then
				M.Routine2State = M.Routine2State + 1;
				M.Routine2Timer = GetTime() + 50;
			end
		elseif M.Routine2State == 5 then
			Attack(BuildObject("cvgdron", 5, Position3), M.Recycler, 0);
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 50;
		elseif M.Routine2State == 6 then
			Attack(TeleportIn("evscout", 6, M.Portal, 25), M.Recycler, 0);
			M.HadeanRecy = TeleportIn("evrecy", 6, M.Portal, 50, 0);
			Goto(M.HadeanRecy, "turr1", 0);
			local h1 = TeleportIn("evmisl", 6, M.Portal, 40);
			local h2 = TeleportIn("evmisl", 6, M.Portal, 30);
			--Follow(h1, M.HadeanRecy);
			--Goto(h2, "turr1", 0);
			SetAIP("edf09.aip", 6);	--moved this here so recy doesn't sit there doing nothing during cutscene
			AudioMessage("edf09c.wav");
			CameraReady();
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 7 then
			if CameraPath("cam", 1000, 800, M.Portal) or CameraCancelled() then
				CameraFinish();
				local h = TeleportIn("evscout",6,M.Portal, 20);
				GiveWeapon(h, "gslicer_c");
				Attack(h, M.Recycler, 1);
				M.Routine2State = M.Routine2State + 1;
				M.Routine2Timer = GetTime() + 5;
			end
		elseif M.Routine2State == 8 then
			ClearObjectives();
			AddObjective("edf0902.otf", "white");
			AudioMessage("edf09t2.wav");
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 5;
		elseif M.Routine2State == 9 then
			--SetAIP("edf09.aip", 6);
			Goto(M.Recycler, "recy", 1);
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 10 then
			if not IsAround(M.HadeanRecy) then
				ClearObjectives();
				AddObjective("edf0903.otf", "white");
				M.Routine4Active = true;--RunSpeed,_Routine4,1,true
				M.Routine2State = M.Routine2State + 1;
			end
		elseif M.Routine2State == 11 then
			if GetDistance(M.Recycler, M.Portal) < 40 then
				TeleportOut(M.Recycler);
				M.RecyTeleported = true;
				M.EnablePlayerTeleport = true;
				Succeed(GetTime() + 6);
				-- SucceedMission(GetTime() + 6, "edf09c.des");
				M.Routine2State = M.Routine2State + 1;
			end
		end
	end
end	

--slowly damages the player's base and handles earthquakes/meteors
function Routine3()
	-- Return early if the Recycler has undeployed.
	if (not IsAround(M.RecyDeployed)) then
		if (not M.SettleEarthquake) then
			 -- This is set when the Recycler undeploys.
			UpdateEarthQuake(6.0);
			-- Do this only once.
			M.SettleEarthquake = true;
		end

		-- Keep EQ stage at first stage. 
		-- This is so we only apply minor damage to buildings when the Recycler undeploys.
		-- As per the original routine, the EQ settles once Sgt. Wong starts moving towards the portal.
		M.EarthquakeStage = 1; 
	end;

	if (M.EarthquakeCooldown < GetTime()) then
		-- Start the EQ.
		if (not M.EarthquakeStarted) then
			StartEarthQuake(5.0);
			M.EarthquakeStarted = true;
		end

		-- Keep track of our earthquake progress.
		M.EarthquakeStageProgressTracker = M.EarthquakeStageProgressTracker + 1;

		-- Choose our specific min/max range based on the stage of the EQ.
		local minMaxValues = damageValues[M.EarthquakeStage];

		-- Logic for damaging all buildings on the map per EQ stage.
		for i, handle in pairs(M.BuildingsToDamage) do
			-- Check if building is still alive....
			if(IsAround(handle)) then

				-- minMaxValues[1] is the minimum value of the chosen range in minMaxValues.
				-- minMaxValues[2] is the maximum value of the chosen range in minMaxValues.
				local damageToApply = GetRandomFloat(minMaxValues[1], minMaxValues[2]);

				-- Take the random damage number and round it down.
				local flooredDamage = math.floor(GetMaxHealth(handle) * damageToApply);

				-- Apply the damage value to the handle.
				Damage(handle, flooredDamage);
			end
		end

		-- Specific logic per EQ stage.
		if (M.EarthquakeStage == 2) then

			-- Spawn a friendly Krul to meet us.
			Attack(BuildObject("cvtank", 5, Position3), M.RecyDeployed, 0);

			-- Spawn meteors.
			if (not M.SpawnFirstMeteor) then
				BuildObject("meteor", 5, "Deploy");
				M.SpawnFirstMeteor = true;
				
				-- Intensify the EQ.
				UpdateEarthQuake(10.0);
			end
		elseif (M.EarthquakeStage == 3) then
			-- Build some effects to show the planet is burning.
			-- Added this boolean check so we don't flood the map with the same object in the same position.
			if (not M.SpawnFireEffects) then
				BuildObject("vfire", 5, "vol1");
				BuildObject("vsmoke", 5, "vol1");
				BuildObject("vfire", 5, "vol2");
				BuildObject("vsmoke", 5, "vol2");
				BuildObject("vfire", 5, Position4);
				BuildObject("vsmoke", 5, Position4);
				M.SpawnFireEffects = true;
				
				-- Intensify the EQ.
				UpdateEarthQuake(15.0);
			end
		elseif (M.EarthquakeStage == 4) then
			if (not M.SpawnSecondMeteor) then
				BuildObject("meteor", 5, "EGT1");
				-- Intensify the EQ.
				UpdateEarthQuake(20.0);
			end
		end

		-- Up the intensity if the player decides to stick around.
		if (M.EarthquakeStageProgressTracker == M.TriggerEQStage2) then
			M.EarthquakeStage = 2;
		elseif (M.EarthquakeStageProgressTracker == M.TriggerEQStage3) then
			M.EarthquakeStage = 3;
		elseif (M.EarthquakeStageProgressTracker == M.TriggerEQStage4) then
			M.EarthquakeStage = 4;
		end

		-- When done, set the cooldown.
		M.EarthquakeCooldown = GetTime() + GetRandomFloat(30.0, 40.0);
	end
end

--[[ function Routine3()
	if M.Routine3Timer < GetTime() then
		if M.Routine3State == 0 then
			StartEarthQuake(6.0);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 50;
		elseif M.Routine3State == 1 then	--LOC_81
			M.Variable1 = M.Variable1 + 1;
			if M.Variable1 > 8 or not IsAround(M.RecyDeployed) then
				M.Routine3State = 3;--to LOC_110
			else
				M.RecyDeployed = GetHandle("unnamed_ibrecy09");
				M.Factory = GetHandle("unnamed_ibfact_s");
				M.PowerGen = GetHandle("unnamed_ibpgen");
				M.GunTower = GetHandle("unnamed_ibgtow");
				M.Scavenger = GetHandle("unnamed_ivscav");
				M.ServiceBay = GetHandle("unnamed_ibsbay");
				M.RelayBunk = GetHandle("unnamed_ibcbun");
				M.Constructor = GetHandle("unnamed_ivcons_r");
				M.Extractor = GetHandle("unnamed_ibscav");

				UpdateEarthQuake(15.0);
				Damage(M.RecyDeployed, 1000);
				Damage(M.Factory, 1000);
				Damage(M.PowerGen, 1000);
				Damage(M.GunTower, 200);
				Damage(M.Scavenger, 500);
				Damage(M.ServiceBay, 1000);
				Damage(M.RelayBunk, 1000);
				Damage(M.Constructor, 200);
				Damage(M.Extractor, 1200);
				M.Routine3State = M.Routine3State + 1;
				M.Routine3Timer = GetTime() + 20;
			end
		elseif M.Routine3State == 2 then
			if IsAround(M.RecyDeployed) then
				Damage(M.RecyDeployed, 300);
				Damage(M.Scavenger, 500);
				Damage(M.Extractor, 1200);
				ClearObjectives();
				AddObjective("edf0904.otf", "white");
				UpdateEarthQuake(6.0);
				M.Routine3State = 1; --to LOC_81
				M.Routine3Timer = GetTime() + 20;
			else
				M.Routine3State = M.Routine3State + 1;
				M.Routine3Timer = GetTime() + 20;
			end
		elseif M.Routine3State == 3 then	--LOC_110
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 2;
		elseif M.Routine3State == 4 then
			local h = BuildObject("cvtank", 5, Position3);
			--GiveWeapon(h, "gclaser_c");	--cvtank doesn't have a gun slot???
			Attack(h, M.Recycler, 0);
			UpdateEarthQuake(15.0);
			BuildObject("meteor", 5, "Deploy");
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 3;
		elseif M.Routine3State == 5 then
			UpdateEarthQuake(6.0);
			Damage(M.RecyDeployed, 1000);
			BuildObject("vfire", 5, "vol1");
			BuildObject("vsmoke", 5, "vol1");
			BuildObject("vfire", 5, "vol2");
			BuildObject("vsmoke", 5, "vol2");
			BuildObject("vfire", 5, Position4);
			BuildObject("vsmoke", 5, Position4);
			--local pos = GetPosition(GetHandle("pool"));	--doesn't exist
			--BuildObject("meteor", 5, pos);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 30;
		elseif M.Routine3State == 6 then
			BuildObject("meteor", 5, "EGT1");
			M.Routine3State = M.Routine3State + 1;
		elseif M.Routine3State == 7 then	--LOC_130
			Damage(M.RecyDeployed, 2500);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 25;
		elseif M.Routine3State == 8 then
			Damage(M.RecyDeployed, 3000);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 30;
		elseif M.Routine3State == 9 then
			Damage(M.RecyDeployed, 3500);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 30;
		elseif M.Routine3State == 10 then
			Damage(M.RecyDeployed, 4000);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 30;
		elseif M.Routine3State == 11 then
			Damage(M.RecyDeployed, 5000);
			if IsAround(M.RecyDeployed) then
				M.Routine3State = 7; --to LOC_130
			else
				local h = BuildObject("cvdcar", 5, Position3);
				--GiveWeapon(h, "gclaser_c");	--cvdcar doesn't have a gun slot???
				Attack(h, M.Recycler, 0);
				M.Routine3State = M.Routine3State + 1;
			end
		end
	end
end --]]

function Routine4()
	if M.Routine4Active and M.Routine4Timer < GetTime() then
		if M.Routine4State == 0 then
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 30;
		elseif M.Routine4State == 1 then
			if GetDistance(M.Recycler, M.Portal) < 200 then
				ClearObjectives();
				AddObjective("edf0906.otf", "white");
				M.Routine4State = M.Routine4State + 1;
			end
		elseif M.Routine4State == 2 then	--LOC_150
			Attack(BuildObject("cvrbomb", 5, Position2), M.Recycler, 1);
			Attack(BuildObject("cvrbomb", 5, Position2), M.Recycler, 0);
			Attack(BuildObject("cvtank", 5, Position2), M.Recycler, 0);
			Attack(BuildObject("cvtank", 5, Position2), M.Recycler, 0);
			M.Routine4Timer = GetTime() + 60;
		end
	end
end

function TeleportRoutine()
	if (M.EnablePlayerTeleport == true and GetDistance(GetPlayerHandle(), M.Portal) < 10) then
		TeleportAndSucceed();
		M.EnablePlayerTeleport = false;
	end
end