assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

--Strings
_Text1 = "The Hadean rebels have helped us\ndestroy the StarPortal, but a\nstrong Hadean loyalist force\nremains. Set up the base and \ndefenses.";
_Text2 = "Intercept the incoming Cerberi\nforces.";
_Text3 = "Help our Hadean allies finish\noff the Cerberi!";
_Text4 = "Follow the Hadean rebels to see\nif they have any information for\nus.";
_Text5 = "Hold position. General Hardin is\nmonitoring your conversation\nwith Marshall Pantelas.";
_Text6 = "Use the Portal transit system to\ncapture the scrap field and its\ntwo biometal pools. Deploy a scav\non each of the island's pools.";
_Text7 = "Good job capturing the scrap\npools. There's even better news--\nthe Hadean rebels may have found\nLieutenant Schultz!";
_Text8 = "Find Schultz and bring him back\nto base. General Hardin will want\nto debrief him as soon as he\nreturns.";
_Text9 = "Take out the Hadean base. We\nmust capture the WorldPortal to\nFacility, in order to learn\nmore about the Hadean fleet.";
_Text10 = "Major Corber, you are disobeying\norders. You must attack and\ndestroy the Hadean Recycler as\nquickly as possible!";

local M = {
-- Bools
	MissionOver = false,
	CheckHadeanAlly = false,
	CheckSchultz = false,
	PortalsActive = false,
	Routine5Active = true,
	
-- Floats
	Routine1Timer = 0.0,
	Routine3Timer = 0.0,
	Routine5Timer = 0.0,
	Routine7Timer = 0.0,
	Routine8Timer = 0.0,
	Routine9Timer = 0.0,

-- Handles
	PlayerRecy = nil,
	HadeanRecy = nil,
	HadeanDropship = nil,
	CerbAttacker1 = nil,
	CerbAttacker2 = nil,
	CerbAttacker3 = nil,
	HadeanAlly1 = nil,
	HadeanAlly2 = nil,
	Player = nil,
	AmbushNav = nil,
	ScrapyardNav = nil,
	--PlayerScav = nil,
	CerbTalon1 = nil,
	CerbTalon2 = nil,
	Portal2 = nil,
	Schultz = nil,
	CerbGuard = nil,
	WorldPortal = nil,
	Portal4 = nil,	--(southern portal)
	PortalA0 = nil,
	PortalA1 = nil,
	BeamFence1 = nil,
	BeamFence2 = nil,
	HadeanPilot = nil,
-- Ints
	Routine1State = 0,
	Routine3State = 0,
	Routine7State = 0,
	Routine8State = 0,
	Variable2 =  0,--how many times player was warned about attacking Hadean base
	Variable5 =  1,	--beam fence 2 rotate speed
	Variable6 =  10.0, --beam fence 2 move speed
	Variable7 =  1, --beam fence 1 rotate speed
	Variable8 =  20.0, --beam fence 1 move speed
	
--Vectors
	Position1 = SetVector(-1403,0,1547),	--Move target for beam fence
	Position2 = SetVector(-1270,0,1508), --Move target for beam fence
	Position4 = SetVector(-1692,63,1959), --Cerb spawn
	Position5 = SetVector(1015,0,8), --Hadean Ally spawn
	Position6 = SetVector(-1341,93,1301), --Schultz spawn
	Position_ScrapYard = nil,
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

	PreloadODF("evtanku");
	PreloadODF("cvtank");
	PreloadODF("cvtalon02");
	PreloadODF("cvrbomb");
	PreloadODF("ivshul2");
	
	local preloadAudio = {
		"edf10a.wav",
		"edf10b.wav",
		"edf10c.wav",
		"edf10c2.wav",
		"edf10d.wav",
		"edf10e.wav",
		"edf10f.wav",
		"edf10g1.wav",
		"edf10g2.wav",
		"edf10z.wav"
	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Start()

	_FECore.Start();

	M.PlayerRecy = GetHandle("unnamed_ibrecy_r");
	M.HadeanRecy = GetHandle("unnamed_ebrecy");
	M.HadeanDropship = GetHandle("dropship");
	M.ScrapyardNav = GetHandle("scrapyard");
	M.Portal2 = GetHandle("portal2");
	M.WorldPortal = GetHandle("unnamed_hbportbig");
	M.Portal4 = GetHandle("portal4");
	M.PortalA0 = GetHandle("PortalA0");
	M.PortalA1 = GetHandle("PortalA1");
	
	M.Position_ScrapYard = GetPosition(M.ScrapyardNav);
	
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end


function AddObject(h)

	_FECore.AddObject(h);

	if IsOdf(h, "espilo") then
		M.HadeanPilot = h;
		M.Routine9Timer = GetTime() + 0.1;
	elseif IsOdf(h, "evtank") then
		GiveWeapon(h, "gfbgun_c");
	elseif IsOdf(h, "evturr") then
		GiveWeapon(h, "gslicer_c");
	end
end

function DeleteObject(h)

	_FECore.DeleteObject(h);

end

function PreSnipe(curWorld, shooterHandle, victimHandle, ordnanceTeam, ordnanceODF)
	if GetTeamNum(victimHandle) == 5 then
		--Bad player - fired at allied Hadeans!
		FailMission(GetTime() + 5, "edf10lose.des");
	end
end

function Update()

	_FECore.Update();

	M.Player = GetPlayerHandle();
	Routine1();
	Routine3();
	Routine5();
	Routine7();
	Routine8();
	Routine9();
	HandlePortals();
	CheckStuffIsAlive();
end

function Routine1()
	if M.Routine1Timer < GetTime() then
		if M.Routine1State == 0 then	
			SetScrap(1, 40);
			SetScrap(2, 40);
			Ally(2, 4);
			RemoveObject(M.ScrapyardNav);
			AudioMessage("edf10a.wav");	--Hardin:"Thank you for your help, Crown Prince Thanatos..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 45;
		elseif M.Routine1State == 1 then
			SetAnimation(M.HadeanDropship, "takeoff", 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 2 then
			StartAnimation(M.HadeanDropship);
			ClearObjectives();
			AddObjective(_Text1, "green");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 6;
		elseif M.Routine1State == 3 then
			RemoveObject(M.HadeanDropship);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 20;
		elseif M.Routine1State == 4 then
			M.CerbAttacker1 = BuildObject("cvtank", 4, M.Position4);
			Goto(M.CerbAttacker1, "ambush", 1);
			M.CerbAttacker2 = BuildObject("cvtank", 4, M.Position4);
			Goto(M.CerbAttacker2, "ambush", 1);
			M.CerbAttacker3 = BuildObject("cvtank", 4, M.Position4);
			Goto(M.CerbAttacker3, "ambush", 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 55;
		elseif M.Routine1State == 5 then
			SetAIP("edf10.aip", 2);
			Goto(M.CerbAttacker1, "ambush", 1);
			Goto(M.CerbAttacker2, "ambush", 1);
			Goto(M.CerbAttacker3, "ambush", 1);
			Ally(1,5);
			M.HadeanAlly1 = BuildObject("evtanku", 5, M.Position5);
			SetMaxHealth(M.HadeanAlly1, 5000);	--bumped up the Hadean allies' health so they don't die immediately
			SetCurHealth(M.HadeanAlly1, 5000);
			Goto(M.HadeanAlly1, "ambush", 0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 6 then
			M.HadeanAlly2 = BuildObject("evtanku", 5, M.Position5);
			SetMaxHealth(M.HadeanAlly2, 5000); 	--bumped up the Hadean allies' health so they don't die immediately
			SetCurHealth(M.HadeanAlly2, 5000);
			Goto(M.HadeanAlly2, "ambush", 0);
			M.CheckHadeanAlly = true; --RunSpeed,_Routine2,1,true
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 7 then
			ClearObjectives();
			AddObjective(_Text2, "green");
			AudioMessage("edf10b.wav");	--Sgt. Wong:"Sir, our scanners show several Cerberi units incoming from the South-West..."
			M.AmbushNav = BuildObject("ibnav", 1, "ambush");
			SetObjectiveName(M.AmbushNav, "Forces");
			SetObjectiveOn(M.AmbushNav);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 8 then	--LOC_35
			if GetDistance(M.HadeanAlly2, "ambush") < 100 
			or GetDistance(M.HadeanAlly2, M.CerbAttacker1) < 100
			or GetDistance(M.HadeanAlly2, M.CerbAttacker2) < 100
			or GetDistance(M.HadeanAlly2, M.CerbAttacker3) < 100 then
				SetObjectiveOn(M.HadeanAlly2);
				SetObjectiveName(M.HadeanAlly2, "Hadean Ally");
				AudioMessage("edf10c.wav");	--Hardin:"Our scanners identify those Hadeans as being on our side..."
				ClearObjectives();
				AddObjective(_Text3, "white");
				M.Routine1State = M.Routine1State + 1;
			end
		elseif M.Routine1State == 9 then	--LOC_42
			if not IsAround(M.CerbAttacker1) and not IsAround(M.CerbAttacker2) and not IsAround(M.CerbAttacker3) then
				SetObjectiveOff(M.AmbushNav);
				RemoveObject(M.AmbushNav);	--"Forces" nav is now removed once Cerb vehicles are destroyed.
				Goto(M.HadeanAlly2, "meeting", 1);
				Follow(M.HadeanAlly1, M.HadeanAlly2, 0);
				ClearObjectives();
				AddObjective(_Text4, "green");
				AudioMessage("edf10c2.wav");	--Hardin:"Follow that Hadean commander and see if he has any news for us."
				M.Routine1State = M.Routine1State + 1;
			elseif GetCurrentCommand(M.HadeanAlly1) == 0 then
				Attack(M.HadeanAlly1, GetNearestEnemy(M.HadeanAlly1), 0);
			elseif GetCurrentCommand(M.HadeanAlly2) == 0 then
				Attack(M.HadeanAlly2, GetNearestEnemy(M.HadeanAlly2), 0);
			end
		elseif M.Routine1State == 10 then	--LOC_53
			if GetDistance(M.Player, M.HadeanAlly2) < 40 and GetDistance(M.HadeanAlly2, "meeting") < 40 then
				LookAt(M.HadeanAlly2, M.Player, 1);
				AudioMessage("edf10d.wav");	--Pantelas:"The Prince, er, General has advised us to render all possible assistance to our new allies..."
				ClearObjectives();
				M.PortalsActive = true;
				AddObjective(_Text5, "white");
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 44;
			end
		elseif M.Routine1State == 11 then
			SetObjectiveOff(M.HadeanAlly2);
			M.ScrapyardNav = BuildObject("ibnav", 1, M.Position_ScrapYard);
			SetObjectiveName(M.ScrapyardNav, "Bio-metal Pools");
			SetObjectiveOn(M.ScrapyardNav);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 20;
		elseif M.Routine1State == 12 then
			SetObjectiveOn(M.PortalA0);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 20;
		elseif M.Routine1State == 13 then
			SetObjectiveOn(M.PortalA1);
			M.CheckHadeanAlly = false; --RunSpeed,_Routine2,0,true
			Follow(M.HadeanAlly1, M.PortalA0, 1);
			Follow(M.HadeanAlly2, M.PortalA0, 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 5;
		elseif M.Routine1State == 14 then
			Teleport(M.HadeanAlly1, M.PortalA1, 40, 0);
			Teleport(M.HadeanAlly2, M.PortalA1, 40, 0);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 15 then
			RemoveObject(M.HadeanAlly1);
			RemoveObject(M.HadeanAlly2);
			ClearObjectives();
			AddObjective(_Text6, "green");
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 10;
		elseif M.Routine1State == 16 then
			AudioMessage("edf10e.wav");	--Hardin:"Once you've secured our new base, I'll need you to take control over the island's scrap pools..."
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 17 then
			if CountUnitsNearObject(M.Portal2, 300, 1, "ibscav") > 1 then
				SetObjectiveOff(M.ScrapyardNav);
				ClearObjectives();
				AddObjective(_Text7, "white");
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 20;
			end
		elseif M.Routine1State == 18 then
			AudioMessage("edf10f.wav");	--Sgt. Wong:"We just received an encrypted message from our new allies. They've found Lt. Schultz..."
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 20;
		elseif M.Routine1State == 19 then
			--RunSpeed,_Routine9,1,true
			--RunSpeed,_Routine10,1,true
			Ally(3, 2);
			Ally(3, 4);
			Ally(1, 3);
			M.Schultz = BuildObject("ivshul2", 3, M.Position6);
			SetObjectiveOn(M.Schultz);
			M.CerbGuard = BuildObject("cvrbomb", 4, M.Position6);
			Defend2(M.CerbGuard, M.Schultz, 0);
			M.CheckSchultz = true; --RunSpeed,_Routine4,1,true
			AddObjective(_Text8, "white");
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 20 then
			if GetDistance(M.Player, "shultz") < 70 then
				SetTeamNum(M.Schultz, 1);
				AudioMessage("edf10z.wav");	--Schultz:"Is that you? Corber?..."
				Follow(M.Schultz, M.Player, 0);
				ClearObjectives();
				AddObjective(_Text8, "green");
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 50;
			end
		elseif M.Routine1State == 21 then
			if GetDistance(M.Schultz, M.PlayerRecy) < 150 then
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 5;
			end	
		elseif M.Routine1State == 22 then
			Goto(M.Schultz, M.PlayerRecy, 1);
			M.Routine1State = M.Routine1State + 1;
		elseif M.Routine1State == 23 then
			if GetDistance(M.Schultz, M.PlayerRecy) < 60 then
				Stop(M.Schultz, 1);
				AudioMessage("edf10g1.wav");	--Hardin:"Welcome home, Lt. Schultz. I imagine you have quite a story to tell..."
				M.Routine1State = M.Routine1State + 1;
				M.Routine1Timer = GetTime() + 60;
			end	
		elseif M.Routine1State == 24 then
			Goto(M.Schultz, M.PlayerRecy, 1);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 3;
		elseif M.Routine1State == 25 then
			M.CheckSchultz = false;
			RemoveObject(M.Schultz);
			M.Routine1State = M.Routine1State + 1;
			M.Routine1Timer = GetTime() + 15;
		elseif M.Routine1State == 26 then
			AudioMessage("edf10g2.wav");	--Hardin:"You've got to destroy that base as quick as you can..."
			ClearObjectives();
			AddObjective(_Text9, "green");
			SetObjectiveOn(M.WorldPortal);
			SetObjectiveName(M.WorldPortal, "WorldPortal");
			M.Routine5Active = false;--RunSpeed,_Routine5,0,true
			M.Routine1State = M.Routine1State + 1;
		end
	end
end

--spawns attackers
function Routine3()
	if M.Routine3Timer < GetTime() then
		if M.Routine3State == 0 then	--LOC_142
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 200;
		elseif M.Routine3State == 1 then
			if not IsAround(M.CerbTalon1) then
				M.CerbTalon1 = TeleportIn("cvtalon10", 4, M.Portal4, 10, 0);
				Patrol(M.CerbTalon1, "patrol", 0);
			end
			Attack(TeleportIn("evtank", 4, M.Portal2, 10, 0), M.PlayerRecy, 0);
			--Patrol(h, "attack1", 0);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 10;
		elseif M.Routine3State == 2 then
			Attack(TeleportIn("evmisl", 4, M.Portal2, 10, 0), M.PlayerRecy, 0);
			--Patrol(h, "attack1", 0);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 200;
		elseif M.Routine3State == 3 then
			if not IsAround(M.CerbTalon2) then
				M.CerbTalon2 = TeleportIn("cvtalon10", 4, M.Portal4, 20, 0);
				Patrol(M.CerbTalon2, "patrol", 0);
			end
			if CountUnitsNearObject(M.PlayerRecy, 300, 1, "ibpgen") >= 2 then
				Attack(TeleportIn("cvrbomb", 4, M.Portal4, 20, 0), M.PlayerRecy, 0);
			end
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 200;
		elseif M.Routine3State == 4 then
			local playerScav = GetHandle("unnamed_ivscav") or GetHandle("unnamed_ibscav");
			if playerScav ~= nil then
				Attack(TeleportIn("evkami", 4, M.Portal4, 20, 0), playerScav, 0);
			end
			M.Routine3State = 0;
		end
	end
end

--Gives player a warning if they attack the Hadean base too soon. If they ignore it too many times, fail them.
function Routine5()
	if M.Routine5Active and M.Routine5Timer < GetTime() and GetDistance(M.Player, M.HadeanRecy) < 500 then
		ClearObjectives();
		AddObjective(_Text10, "red");
		M.Variable2 = M.Variable2 + 1;
		if M.Variable2 > 2 then
			FailMission(GetTime() + 5, "badplayer.des");
			M.Routine5Active = false;
		else
			M.Routine5Timer = GetTime() + 20;
		end		
	end	
end

--beam gates by Schultz
function Routine7()
	if M.Routine7Timer < GetTime() then
		if M.Routine7State == 0 then
			if GetDistance(GetNearestVehicle("gate1", 1), "gate1") < 80 then
				M.BeamFence1 = BuildObject("beamfence10", 4, "gate1");
				M.Routine7State = M.Routine7State + 1;
			end
		elseif M.Routine7State == 1 then
			if Move(M.BeamFence1, M.Variable7, M.Variable8, M.Position1) then
				M.BeamFence1 = BuildObject("beamfence10", 4, "gate2");
				M.Routine7State = M.Routine7State + 1;
				M.Routine7Timer = GetTime() + 2;
			end
		elseif M.Routine7State == 2 then
			if Move(M.BeamFence1, M.Variable7, M.Variable8, M.Position2) then
				M.Routine7State = 0;
				M.Routine7Timer = GetTime() + 10;
			end
		end
	end	
end

--beam gates by Schultz
function Routine8()
	if M.Routine8Timer < GetTime() then
		if M.Routine8State == 0 then
			if GetDistance(GetNearestVehicle("gate3", 3), "gate3") < 100 then
				M.BeamFence2 = BuildObject("beamfence10", 4, "gate3");
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 1 then
			if Move(M.BeamFence2, M.Variable5, M.Variable6, M.Position1) then
				M.Routine8State = 0;
				M.Routine8Timer = GetTime() + 10;
			end
		end
	end
end

--Replaces ejected Hadean pilots with "maniach"s (jet pack bastards)
function Routine9()
	if M.Routine9Timer < GetTime() and IsAround(M.HadeanPilot) then
		ReplaceObject(M.HadeanPilot, "maniach", -1, 0.0, -1, false);
		M.HadeanPilot = nil;
	end
end

function HandlePortals()
	if M.PortalsActive then
		local h = GetNearestVehicle(M.PortalA0);
		if GetDistance(h, M.PortalA0) < 20 then
			Teleport(h, M.PortalA1, 40, 40);
			if h ~= M.Player then
				Stop(h, 0);
			end
		end
		h = GetNearestVehicle(M.PortalA1);
		if GetDistance(h, M.PortalA1) < 20 then
			Teleport(h, M.PortalA0, 40, 40);
			if h ~= M.Player then
				Stop(h, 0);
			end
		end
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if M.CheckHadeanAlly and not IsAlive(M.HadeanAlly2) then
			FailMission(GetTime() + 5, "edf10lose.des");
			M.MissionOver = true;
		elseif M.CheckSchultz and not IsAround(M.Schultz) then
			FailMission(GetTime() + 5, "shultz.des");
			M.MissionOver = true;
		elseif not IsAround(M.PlayerRecy) then
			FailMission(GetTime() + 5, "lose.des");
			M.MissionOver = true;
		elseif not IsAround(M.HadeanRecy) then
			SucceedMission(GetTime() + 5, "win.des");
			M.MissionOver = true;
		end	
	end
end

function Teleport(h, dest, offsetX, offsetZ)
	if not IsAround(h) then 
		return; 
	end
	
	BuildObject("teleportout", 0, GetPosition(h));
	local offset = SetVector(offsetX, 0, offsetZ);
	local dir = Normalize(offset);
	local pos = GetPosition(dest) + offset;
	BuildObject("teleportin", 0, pos);
	SetPosition(h, pos);
	SetVelocity(h, Length(GetVelocity(h))*dir);
	if h == GetPlayerHandle() then
		StartSoundEffect("teleport.wav", nil);	--sound effects seem to get cut off when player is teleporting
	end
end

function TeleportIn(odf, team, dest, offsetX, offsetZ)
	if IsAround(dest) then
		local pos = GetPosition(dest) + SetVector(offsetX, offsetZ);
		BuildObject("teleportin", 0, pos);
		return BuildObject(odf, team, pos);
	else
		return nil;
	end
end
