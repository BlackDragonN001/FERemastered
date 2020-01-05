assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

local M = {
-- Bools
	Routine4Active = false;

-- Floats
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
	Factory = nil, 	--Player Fact
	PowerGen = nil,	--Player Pgen
	GunTower = nil,	--Player Gtow
	Scavenger = nil,	--Player Scav
	ServiceBay = nil, --Player sbay
	RelayBunk = nil,	--Player CBun
	Constructor = nil,	--Player Constructor
-- Ints
	Routine1State = 0,
	Routine2State = 0,
	Routine3State = 0,
	Routine4State = 0,
	Variable1 = 0,	--routine3 counter
	Variable2 = 40,	--mlight rotate rate
	Variable3 = 100,	--mlight move speed
	
--Vectors
	Position1 = SetVector(-799,0,-658),	--temp spawn location
	Position2 = SetVector(-800,22,-326),	--cerb reinforcements spawn location
	Position3 = SetVector(-80,30,700),	--cerb attacker spawn
	Position4 = SetVector(315,-15,-525),	--debris spawn
	--Position5 = SetVector(0,0,0),	--temp
	--Position6 = SetVector(0,0,0),	--unused
	Position7 = SetVector(-183,-12,55),	--mlight move target
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
	--M.Recycler = GetHandle("unnamed_ivrecy091");
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end


function AddObject(h)

	_FECore.AddObject(h);

	if GetOdf(h) == "ivrecy09.odf" then	--GetCfg() sometimes returns the name with ":1" appended to it.
		M.Recycler = h;
	end
end

function DeleteObject(h)

	_FECore.DeleteObject(h);
	
end

function Update()

	_FECore.Update();

	Routine1();
	Routine2();
	Routine3();
	Routine4();
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
				M.Routine2Timer = GetTime() + 200;
			end
		elseif M.Routine2State == 3 then
			Attack(BuildObject("cvscout", 5, M.Position3), M.Recycler, 1);
			Stop(M.Recycler, 1);
			AudioMessage("edf09t.wav");
			ClearObjectives();
			AddObjective("edf0907.otf", "white");
			M.MLight = BuildObject("mlight", 5, "mlight");
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 4 then
			if Move(M.MLight, M.Variable2, M.Variable3, M.Position7) then
				M.Routine2State = M.Routine2State + 1;
				M.Routine2Timer = GetTime() + 50;
			end
		elseif M.Routine2State == 5 then
			Attack(BuildObject("cvgdron", 5, M.Position3), M.Recycler, 0);
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 50;
		elseif M.Routine2State == 6 then
			Attack(TeleportIn("evscout", 6, M.Portal, 25, 0), M.Recycler, 0);
			M.HadeanRecy = TeleportIn("evrecy", 6, M.Portal, 50, 0);
			Goto(M.HadeanRecy, "turr1", 0);
			local h1 = TeleportIn("evmisl", 6, M.Portal, 40, -20);
			local h2 = TeleportIn("evmisl", 6, M.Portal, 30, 20);
			--Follow(h1, M.HadeanRecy);
			--Goto(h2, "turr1", 0);
			SetAIP("edf09.aip", 6);	--moved this here so recy doesn't sit there doing nothing during cutscene
			AudioMessage("edf09c.wav");
			CameraReady();
			M.Routine2State = M.Routine2State + 1;
		elseif M.Routine2State == 7 then
			if CameraPath("cam", 1000, 800, M.Portal) or CameraCancelled() then
				CameraFinish();
				local h = TeleportIn("evscout",6,M.Portal, 20, 0);
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
				Teleport(M.Recycler, GetHandle("unnamed_rwpool1"));
				SucceedMission(GetTime() + 6, "edf09c.des");
				M.Routine2State = M.Routine2State + 1;
			end
		end
	end
end	

--slowly damages the player's base and handles earthquakes/meteors
function Routine3()
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
				M.Scavenger = GetHandle("unnamed_ibsbay");
				M.ServiceBay = GetHandle("unnamed_ivscav1");
				M.RelayBunk = GetHandle("unnamed_ibcbun");
				M.Constructor = GetHandle("unnamed_ivcons_r");
				UpdateEarthQuake(15.0);
				Damage(M.RecyDeployed, 1000);
				Damage(M.Factory, 1000);
				Damage(M.PowerGen, 1000);
				Damage(M.GunTower, 200);
				Damage(M.Scavenger, 500);
				Damage(M.ServiceBay, 1000);
				Damage(M.RelayBunk, 1000);
				Damage(M.Constructor, 200);
				M.Routine3State = M.Routine3State + 1;
				M.Routine3Timer = GetTime() + 20;
			end
		elseif M.Routine3State == 2 then
			if IsAround(M.RecyDeployed) then
				Damage(M.RecyDeployed, 300);
				Damage(M.Scavenger, 500);
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
			local h = BuildObject("cvtank", 5, M.Position3);
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
			BuildObject("vfire", 5, M.Position4);
			BuildObject("vsmoke", 5, M.Position4);
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
				local h = BuildObject("cvdcar", 5, M.Position3);
				--GiveWeapon(h, "gclaser_c");	--cvdcar doesn't have a gun slot???
				Attack(h, M.Recycler, 0);
				M.Routine3State = M.Routine3State + 1;
			end
		end
	end
end

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
			Attack(BuildObject("cvrbomb", 5, M.Position2), M.Recycler, 1);
			Attack(BuildObject("cvrbomb", 5, M.Position2), M.Recycler, 0);
			Attack(BuildObject("cvtank", 5, M.Position2), M.Recycler, 0);
			Attack(BuildObject("cvtank", 5, M.Position2), M.Recycler, 0);
			M.Routine4Timer = GetTime() + 60;
		end
	end
end

function Teleport(h, dest)
	BuildObject("teleportout", 0, GetPosition(h));
	local pos = GetPosition(dest);
	pos.y = TerrainFindFloor(pos.x, pos.z) + 5;
	BuildObject("teleportin", 0, pos);
	SetPosition(h, pos);
end

function TeleportIn(odf, team, dest, offsetX, offsetZ)
	local pos = GetPosition(dest) + SetVector(offsetX, offsetZ);
	BuildObject("teleportin", 0, pos);
	return BuildObject(odf, team, pos);
end

-- New method for building and labelling units. - AI_Unit.
function BuildObjectAndLabel(handle, team, pos, label) 
    local h = BuildObject(handle, team, pos);

    if (label ~= nil) then
        SetLabel(h, label);
    end

    return h;
end