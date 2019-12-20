assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _FECore = require('_FECore');

-- Variables Not saved or constants that never change.
local h	--temp handle
local ZERO_VECTOR = SetVector(0,0,0);
local UP_VECTOR = SetVector(0,1,0);

--Strings
local _Text1 = "Escort the convoy and establish\na base. Beware of the molten\nbiometal rivers!\n\nKeep the ECM pod near the\nRecycler to reduce its radar\nprofile."
local _Text2 = "Long-range scans have detected\na comm bunker bearing an\nunusual friend-or-foe\nidentity code. Go to the\nindicated nav beacon and\ninvestigate."
local _Text3 = "Hop out of your tank,\nand enter the comm bunker\non foot. Access the\ninterface if possible."
local _Text4 = "Once you clear the targeted\nguntower, the Recycler will\nmove across the bridge."
local _Text5 = "Clear the other guntower\nbefore your recycler is fried.\nMake SURE to carefully recon\nthe remainder of the route!"
local _Text6 = "We must bomb the bridge to\nblock a massive counterattack.\nClimb to the observation point\nand target the weakest bridge\nsegment using the 'T' key."
local _Text7 = "Major Wyndt-Essex has ordered\nyou to deploy the Recycler\nat the point she recommends.\nDisobey her at your peril."
local _Text8 = "Enemy attack waves detected.\nBuild defenses and key\nstructures (power, factory,\narmory), and await further\norders."
local _Text9 = "Engineers have placed a\nbooster-pad to help you\ncatapult across the river.\nHover on the pad's center for\n5 seconds in order to launch."
local _Text10 = "Conduct a security patrol\nalong the nav points with\nSchultz. Engage and destroy all\nenemies inside the perimeter."
local _Text11 = "CONDITION EPSILON: Return\nto base at once to assist\nwith defense! Lt. Schultz is\nto finish patrol alone."
local _Text12 = "CONDITION EPSILON: ALL\nUNITS EXCEPT SCHULTZ RTB\nIMMEDIATELY! Lt. Schul@#\nmust mainta]n patr@]\nto secur@ p@r|m@+er."
local _Text13 = "A large assault force is needed\nto rescue Schultz. Lead the Hadean\nBuilder to the Repair Point\nand it will rebuild the bridge."
local _Text14 = "The crater has been sealed off.\nGrab the nuclear satchel-bomb\nand deploy it at the nav point\nin order to breach the rim\nand rescue Schultz."
local _Text15 = "You'll need to build a large\nforce to storm the base.\nDestroy the Foundry AND the\nCrucible in order to gain\ncontrol of the Proteus facility."
local _Text16 = "You placed the nuclear excavator\ntoo far from the designated\ndrop point. Deploy it in the\nindicated position next time!"
local _Text17 = "You just lost the Recycler,\nalong with all our hopes of\nescaping this wretched planet!"
local _Text18 = "Schultz remains a prisoner, but\nyou've bought us a chance to\nland the StormPetrel safely.\nReturn to base at once."
local _Text19 = "You failed to protect your\nwingman. Now he's dead, or a\nprisoner of the alien machines.\nReturn to base immediately!"
local _Text20 = "You have lost the Builder that\nour new allies had sent to help\nus. The Hadean Fifth Column\nwill be most displeased."
local _Text21 = "A biometal storage facility\nhas been found near your\nposition. Destroy the\ntanks to harvest the scrap."

local M = {
-- Bools
	MissionOver = false,
	Routine4Active = false,
	Routine5Active = true,
	Routine6Active = true,
	Routine9Active = false,
	Routine10Active = false,
	Routine11Active = false,
	Routine12Active = false,
	Routine13Active = false,
	Routine14Active = false,
	Routine15Active = false,
	Routine16Active = true,
	Routine17Active = true,
	Routine18Active = true,
	Routine19Active = false,

-- Floats
	MissionTimer = 0.0,
	Routine2Timer = 0.0,
	Routine3Timer = 0.0,
	Routine4Timer = 0.0,
	Routine5Timer = 0.0,
	Routine6Timer = 0.0,
	Routine7Timer = 0.0,
	Routine8Timer = 0.0,
	Routine9Timer = 0.0,
	Routine10Timer = 0.0,
	Routine11Timer = 0.0,
	Routine12Timer = 0.0,
	Routine13Timer = 0.0,
	Routine14Timer = 0.0,
	Routine15Timer = 0.0,
	Routine16Timer = 0.0,
	Routine17Timer = 0.0,
	--Routine18Timer = 0.0,
	Routine19Timer = 0.0,
	Routine19CamTime = 0.0,
-- Handles
	HadeanCommBunk = nil,
	HadeanPower = nil,	--powers hadean comm bunk while player is uploading the data
	Tug1 = nil,
	Tug2 = nil,
	Recycler = nil,
	BridgeGuard1 = nil,
	BridgeGuard2 = nil,
	Breach = nil,	--"breach7z", smoke
	Bridge1 = nil,	--Weakest segment
	Bridge2 = nil,
	Bridge3 = nil,
	Bomb1 = nil,	--daywrecker 1 (destroys bridge)
	Bomb2 = nil,	--daywrecker 2 (destroys bridge)
	Bomb3 = nil,	--daywrecker 3 (destroys bridge)
	HadeanBuilder = nil,
	BridgeRepairNav = nil,	--"Repair Point" nav
	RepairBomb = nil,	--"bombs" that rebuild the bridge
	SatchelPickup = nil,	--nuclear satchel
	Player = nil,
	Constructor = nil,	--player's constructor
	WindexDeployNav = nil,	--"Wyndt-Essex's Deploy Point" nav
	SchultzDeployNav = nil,	--"Schultz's Alternate Point" nav
	EcmJammer = nil,
	NextWaypointNav = nil,
	Schultz = nil,
	Routine13MoveHandle1 = nil,	--object being catapulted (from west)
	Routine13MoveHandle2 = nil,	--object being catapulted (from east)
	CatapultNavE = nil,	--"East Catapult Site" nav
	CatapultNavW = nil,	--"West Catapult Site" nav
	CerbTransport = nil,
	CerbRecy = nil,
	CameraNav = nil,	--camera nav for cerb transport lifting off cutscene
	CerbFact = nil,
	Routine16MoveHandle = nil,	--for Routine16 to prevent player from driving through the tunnel into the Cerb base
	ServicePod = nil, 	--XP Service Pod
	Routine17MoveHandle = nil,
	Attacker01 = nil,
	Attacker02 = nil,
	Attacker03 = nil,
	Attacker04 = nil,
	Attacker05 = nil,
	Attacker06 = nil,
	Attacker07 = nil,
	Attacker08 = nil,
	Attacker09 = nil,
	Attacker10 = nil,
	Attacker11 = nil,
	Attacker12 = nil,	
	Attacker13 = nil,
	Attacker14 = nil,
	Attacker15 = nil,
	Attacker16 = nil,
	Attacker17 = nil,
	Attacker18 = nil,
	Attacker19 = nil,
	Attacker20 = nil,
	Attacker21 = nil,
	Attacker22 = nil,
	Attacker23 = nil,
	Attacker24 = nil,
	Attacker25 = nil,
	BridgeLookoutNav = nil,
-- Ints
	TPS = 0,
	MissionState = 0, 
	Routine2State = 0,
	Routine3State = 0,
	Routine4State = 0,
	Routine5State = 0,
	Routine6State = 0,
	Routine7State = 0,
	Routine8State = 0,
	Routine9State = 0,
	Routine10State = 0,
	Routine11State = 0,
	Routine12State = 0,
	Routine13State = 0,
	Routine14State = 0,
	Routine15State = 0,
	Routine16State = 0,
	Routine17State = 0,
	--Routine18State = 0,
	Routine19State = 0,
	
	BombRotRate = 90, 	--bridge bomb rotation rate (const)
	BombDropSpeed =  90.0,	--bridge bomb drop speed (const)
	Pod2RotRate =  36,	--service pod 2 turn speed (const), also used for cerb transport
	Pod2MoveSpeed =  50.0,	--service pod 2 move speed (const), also used for cerb transport
	Pod1RotRate =  72,	--service pod 1 turn speed (const)
	Pod1MoveSpeed =  100.0,	--service pod 1 move speed (const)
	CatapultMoveSpeed =  75.0,	--catapult move speed (const)
	SirenRespawnTimer =  0, 	--Siren respawn timer
	KrulRespawnTimer =  0, 	--Krul respawn timer
	DemonRespawnTimer =  0, 	--Demon respawn timer
	TalonRespawnTimer =  0,		--Talon respawn timer
	DisobeyedWindex =  0,	--if you disobeyed windex and deployed at Shultz's deploy site
	JammerState =  1,	--how far recy is from jammer	
	Routine6Counter =  0,	--routine5&6 loop counter
	Routine5Counter =  0,	--Routine5 jammer counter
	Routine14Counter =  0,	--Routine14 loop counter
	BridgeBombStart =  0,	--bridge bombing sequence started
	BridgeDestroyed =  0,	--bridge bombing sequence ended
	Routine11Counter =  0,	--routine11 loop counter
	Routine9Counter =  0,	--routine9, routine11 loop counter
	PlayerIsUsingCatapult =  0,	--player is currently using one of the catapults
	SchultzAmbushed =  0,	--shultz was ambushed
	NukeFailCount =  0,	--how many times the player screwed up placing the nuke
	SchultzState =  0,	--Shultz state. 0=not spawned, 1=patrolling with player, 2=ambushed
	CbunkUploadFinished =  0,	--done with the hadean comm bunk
	PlayerUsingCbunk =  0,	--player is using hadean comm bunk
	Routine8Counter =  0,	--routine8 spawn attacker loop counter
	HadeanBuilderArrived =  0,	--hadean builder spawned
	PlayerRecalledToBase =  0,	--player called back to base
	RecyOldHealth =  0,	--recycler old health
	BreachOpened =  0,	--breach opened
--Vector
	Position2 = SetVector(0,0,0),	--bridge seg 1 pos
	Position3 = SetVector(0,0,0),	--bridge seg 2 pos
	Position4 = SetVector(0,0,0),	--bridge seg 3 pos
	Position6 = SetVector(1036,42,872),	--"breach7z" spawn location
	Position7 = SetVector(1036, 49, 879), --check terrain height here to see if we need to build another breach7z
	Position17 = SetVector(0,0,0),	--Shultz spawn location
	Position18 = SetVector(0,0,0),	--Cerb transport move target
	Position23 = SetVector(0,10,10),	--used for cam offset in routine20
	Position28 = SetVector(817,53,851),	--move target for routine16
	Position29 = SetVector(-1544,104,-948),	--move target for routine17
	Position30 = SetVector(0,0,0),	--move to position for tug service pods
	endme = 0
}

function Save()

	_FECore.Save();
	
	return M;
end

function Load(...)

	_FECore.Load();
	
    if select('#', ...) > 0 then
		M = ...;
    end
end

function InitialSetup()

	_FECore.InitialSetup();

	M.TPS = EnableHighTPS();
	AllowRandomTracks(false);
	
	--Preload ODFs to reduce lag spikes when things are spawned in for the first time
	PreloadODF("evcons");
	PreloadODF("ivshul1");
	
	local preloadAudio = {
		"07iface_1.wav",
		"07iface_2.wav",
		"07iface_3.wav",
		"menv03.wav",
		"e7start.wav",
		"skyeye.wav",
		"e7bridtow1.wav",
		"findbunk.wav",
		"e7bridtow2.wav",
		"letsbomb.wav",
		"abetty10.wav",
		"lock02.wav",
		"fmiss01.wav",
		"Eyedown.wav",
		"e7deploy1.wav",
		"rodrprmd.wav",
		"Shultank.wav",
		"dronewow.wav",
		"Shulhere.wav",
		"abetty6.wav",
		"baseattack.wav",
		"chatter1.wav",
		"stat01.wav",
		"steam2.wav",
		"kidnap1a.wav",
		"chatter6.wav",
		"chatter7.wav",
		"RodWimp.wav",
		"here2hlp.wav",
		"evcons05.wav",
		"rodwimp2.wav",
		"iabomb01.wav",
		"recydead.wav",
		"Shulgone.wav"
	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Start()

	_FECore.Start();

	M.HadeanCommBunk = GetHandleOrDie("unnamed_ebcbun7");
	M.HadeanPower = GetHandleOrDie("uplink_ebpgen");
	M.Tug1 = GetHandleOrDie("conship1_ivtug");
	M.Tug2 = GetHandleOrDie("conship2_ivtug");
	M.Recycler = GetHandleOrDie("convoy_ivrecy");
	M.BridgeGuard1 = GetHandleOrDie("bridguard1_ebdturr07");
	M.BridgeGuard2 = GetHandleOrDie("bridguard2_ebdturr07");
	M.EcmJammer = GetHandleOrDie("unnamed_edfjamm7");
	--M.NextWaypointNav = GetHandleOrDie("Hadean Labs");
	RemoveObject(GetHandle("Hadean Labs"));
	M.CerbTransport = GetHandleOrDie("cerbtran_cbprop04");
	M.CerbRecy = GetObjectByTeamSlot(5, 1);
	M.CerbFact = GetObjectByTeamSlot(5, 2);

	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function GetHandleOrDie(name)
	return GetHandle(name) or error("Error: object '"..name.."' not found!");
end

function AddObject(h)

	_FECore.AddObject(h);

	if M.BreachOpened and IsPlayer(h) and IsPerson(h) then
		GiveWeapon(h, "igjetp");
	elseif IsOdf(h, "ivcons") then
		M.Constructor = h;
	end
end

function DeleteObject(h)

	_FECore.DeleteObject(h);

end

function Update()

	_FECore.Update();

	M.Player = GetPlayerHandle();
	Routine2();
	Routine3();
	Routine4();
	Routine5();
	Routine6();
	Routine7();
	Routine8();
	Routine9();
	Routine10();
	Routine11();
	Routine12();
	Routine13();
	Routine14();
	Routine15();
	Routine16();
	Routine17();
	Routine18();
	Routine19();
	CheckStuffIsAlive();
end

--handles the edf jammer
function Routine2()	
	if M.Routine2Timer < GetTime() then
		if M.Routine2State == 0 then
			SetMaxHealth(M.Player, 7500);
			SetMaxAmmo(M.Player, 5000);
			Stop(M.Recycler, 1);
			Ally(4, 5);
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 60;
		elseif M.Routine2State == 1 then	--LOC_13
			M.Routine2State = M.Routine2State + 1;
			M.Routine2Timer = GetTime() + 5;
		elseif M.Routine2State == 2 then
			M.JammerState = 1;
			if not IsAround(M.EcmJammer) then
				M.JammerState = 3;
				M.Routine2State = 99;
			else
				local jammerDist = GetDistance(M.EcmJammer, M.Recycler);
				if jammerDist > 200 and jammerDist < 300 then
					M.JammerState = 2;
				elseif jammerDist > 300 then
					M.JammerState = 3;
				end
				M.Routine2State = 1;
			end
		end
	end
end

--Handles the Hadean Comm bunker
function Routine3()
	if M.Routine3Timer < GetTime() then
		if M.Routine3State == 0 then
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 7;
		elseif M.Routine3State == 1 then	--LOC_50
			if InBuilding(M.Player) == M.HadeanCommBunk then
				M.PlayerUsingCbunk = 1;
				Ally(1, 5);
				SetTeamNum(M.HadeanCommBunk, 1);
				SetTeamNum(M.HadeanPower, 1);
				M.Routine3State = M.Routine3State + 1;
			end
		elseif M.Routine3State == 2 then	--LOC_58
			if AtTerminal(M.Player) == M.HadeanCommBunk then
				IFace_Exec("07iface.cfg");
				FreeCamera();
				IFace_Activate("Rauschen");
				AudioMessage("07iface_1.wav");	--Eisenstein:"Decoding and translation in progress..."
				M.Routine3State = M.Routine3State + 1;
				M.Routine3Timer = GetTime() + 1;
			end
		elseif M.Routine3State == 3 then
			IFace_Activate("Bar");
			IFace_Deactivate("Bar.Blueprints");
			IFace_Deactivate("Bar.Sending");
			M.Routine4Active = true; --RunSpeed,_Routine4,1,false
			M.Routine3State = M.Routine3State + 1;
			--M.Routine3Timer = GetTime() + 15;
		elseif M.Routine3State == 4 then
			if not M.Routine4Active then
				IFace_Deactivate("Bar.Bar7");
				IFace_Deactivate("Bar");
				IFace_Deactivate("Rauschen");
				IFace_Activate("EMAIL1");
				M.Routine3State = M.Routine3State + 1;
				M.Routine3Timer = GetTime() + 5;
			end
		elseif M.Routine3State == 5 then
			AudioMessage("07iface_2.wav");	--Eisenstein:"Sir, I've found more relevant information in the database. Looks like technical blueprints."
			--M.Routine4Active = true; --RunSpeed,_Routine4,1,false
			M.Routine3State = M.Routine3State + 1;
			--M.Routine3Timer = GetTime() + 15;
			M.Routine3Timer = GetTime() + 6;
		elseif M.Routine3State == 6 then
			IFace_Activate("Bar");
			IFace_Deactivate("Bar.Decoding");
			IFace_Activate("Bar.Blueprints");
			IFace_Deactivate("Bar.Sending");
			M.Routine4Active = true;
			M.Routine3State = M.Routine3State + 1;
		elseif M.Routine3State == 7 then
			if not M.Routine4Active then
				IFace_Deactivate("Bar");
				IFace_Deactivate("Bar.Bar7");
				IFace_Deactivate("Bar.Blueprints");
				IFace_Deactivate("EMAIL1");
				IFace_Activate("EMAIL2");
				M.Routine3State = M.Routine3State + 1;
				M.Routine3Timer = GetTime() + 10;
			end
		elseif M.Routine3State == 8 then
			AudioMessage("07iface_3.wav");	--Eisenstein:"Sir, I've found a way to send this message to the fifth column..."
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 10;
		elseif M.Routine3State == 9 then
			IFace_Activate("EMAIL3");
			IFace_Deactivate("EMAIL2");
			M.Routine3State = M.Routine3State + 1;
		elseif M.Routine3State == 10 then	--LOC_87
			if IFace_GetInteger("end.count") ~= 0 then
				IFace_Deactivate("EMAIL3");
				IFace_Activate("Bar");
				IFace_Deactivate("Bar.Decoding");
				IFace_Deactivate("Bar.Blueprints");
				IFace_Activate("Bar.Sending");
				M.Routine4Active = true; --RunSpeed,_Routine4,1,false
				M.Routine3State = M.Routine3State + 1;
				M.Routine3Timer = GetTime() + 2;
			end
		elseif M.Routine3State == 11 then
			AudioMessage("menv03.wav");
			M.Routine3State = M.Routine3State + 1;
			--M.Routine3Timer = GetTime() + 13;
		elseif M.Routine3State == 12 then
			if not M.Routine4Active then
				IFace_Deactivate("Bar");
				IFace_Deactivate("Bar.Bar7");
				IFace_Deactivate("Bar.Sending");
				FreeFinish();
				M.Routine3State = M.Routine3State + 1;
			end
		elseif M.Routine3State == 13 then
			if AtTerminal(M.Player) ~= M.HadeanCommBunk then
				ClearObjectives();
				AddObjective(_Text3, "green");
				SetTeamNum(M.HadeanPower, 0);
				RemoveObject(M.HadeanPower);
				M.CbunkUploadFinished = 1;
				M.PlayerUsingCbunk = 0;
				UnAlly(1, 5);
				SetCurHealth(M.HadeanCommBunk, 5000);
				M.Attacker13 = BuildObject("cvrbomb",5,"hadconstart");
				Attack(M.Attacker13,Player,1);
				M.Attacker14 = BuildObject("cvtank",5,"hadconstart");
				Attack(M.Attacker14,Player,1);
				M.Routine3State = M.Routine3State + 1;
				M.Routine3Timer = GetTime() + 3;
			end
		elseif M.Routine3State == 14 then
			M.Attacker15 = BuildObject("cvtalon02",5,"waterstart");
			Attack(M.Attacker15,M.HadeanCommBunk,1);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 2;
		elseif M.Routine3State == 15 then
			SetCurHealth(M.HadeanCommBunk,2500);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 2;
		elseif M.Routine3State == 16 then
			SetCurHealth(M.HadeanCommBunk,500);
			M.Routine3State = M.Routine3State + 1;
			M.Routine3Timer = GetTime() + 2;
		elseif M.Routine3State == 17 then
			Damage(M.HadeanCommBunk, 501);
			M.Routine3State = M.Routine3State + 1;
		end
	end
end

--Progress bar for hadean comm bunk
function Routine4()
	if M.Routine4Timer < GetTime() and M.Routine4Active then
		if M.Routine4State == 0 then
			IFace_Activate("Bar.Bar1");
			IFace_Deactivate("Bar.Bar2");
			IFace_Deactivate("Bar.Bar3");
			IFace_Deactivate("Bar.Bar4");
			IFace_Deactivate("Bar.Bar5");
			IFace_Deactivate("Bar.Bar6");
			IFace_Deactivate("Bar.Bar7");
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 2;
		elseif M.Routine4State < 7 then
			IFace_Activate("Bar.Bar"..tostring(M.Routine4State + 1));
			IFace_Deactivate("Bar.Bar"..tostring(M.Routine4State));
			M.Routine4State = M.Routine4State + 1;
			M.Routine4Timer = GetTime() + 1;
		else
			M.Routine4Active = false;
			M.Routine4State = 0;
			M.Routine4Timer = GetTime() + 1;
		end
	end
end

--spawns attackers during the escort part of the mission.
function Routine5()
	if M.Routine5Active and M.Routine5Timer < GetTime() then
		if M.Routine5State == 0 then
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 75;
		elseif M.Routine5State == 1 then	--LOC_147
			M.Routine6Counter = M.JammerState;
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 2 then	--LOC_148
			if GetDistance(M.Recycler, "bendstop") < 200 then
				M.Routine5State = 7;	--to LOC_170
			else
				M.Routine5State = M.Routine5State + 1;
				M.Routine5Timer = GetTime() + 25;
			end
		elseif M.Routine5State == 3 then
			M.Routine6Counter = M.Routine6Counter + 1;
			if M.Routine6Counter < 4 then 
				M.Routine5State = 2;
			else
				M.Routine6Counter = 0;
				M.Attacker01 = BuildObject("cvtank",5,"hadconstart");
				Patrol(M.Attacker01, "conpatrol",1);
				M.Attacker02 = BuildObject("cvscout",5,"hadconstart");
				Patrol(M.Attacker02, "conpatrol",1);
				Goto(BuildObject("cvturr02", 5, "hadconstart"), "bendstop", 1);
				M.Routine5State = M.Routine5State + 1;
				M.Routine5Timer = GetTime() + 10;
			end
		elseif M.Routine5State == 4 then
			if M.JammerState ~= 1 then
				SetSkill(Attacker01, 3);
				SetSkill(Attacker02, 3);
				M.Routine5Counter = M.Routine5Counter + 1;
				if M.Routine5Counter < M.JammerState then
					M.Routine5State = 1;
				else
					M.Routine5Counter = 0;
					M.Routine5State = M.Routine5State + 1;
				end
			else
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 5 then	--LOC_168
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 15;
		elseif M.Routine5State == 6 then
			M.Routine5Counter = 0;
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 7 then	--LOC_170
			if M.PlayerUsingCbunk ~= 1 then
				M.Routine5State = M.Routine5State + 1;
				M.Routine5Timer = GetTime() + (4 - M.JammerState) * 25;	--cerbs are more frequent if ECM jammer is dead or too far from recy
			end	
		elseif M.Routine5State == 8 then
			M.Attacker01 = BuildObject("cvrbomb", 5, "hadconstart");
			Patrol(M.Attacker01, "conpatrol", 1);
			M.Attacker02 = BuildObject("cvscout", 5, "hadconstart");
			Patrol(M.Attacker02, "conpatrol2", 1);
			M.Attacker03 = BuildObject("cvturr02", 5, "hadconstart");
			Goto(M.Attacker03, "BridWest", 1);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 10;
		elseif M.Routine5State == 9 then
			if M.JammerState == 1 then
				M.Routine5State = M.Routine5State + 1;
			else
				SetSkill(M.Attacker01, 3);
				SetSkill(M.Attacker02, 3);
				M.Routine5Counter = M.Routine5Counter + 1;
				if M.Routine5Counter < M.JammerState then
					M.Routine5State = 7; --to LOC_170
				else
					M.Routine5State = M.Routine5State + 1;
				end
			end	
		elseif M.Routine5State == 10 then	--LOC_192
			M.Routine5Counter = 0;
			M.Routine5State = M.Routine5State + 1;
		elseif M.Routine5State == 11 then	--LOC_193
			if M.CbunkUploadFinished > 0 then
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 12 then	--LOC_196
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + (4 - M.JammerState) * 40;	--cerbs are more frequent if ECM jammer is dead or too far from recy
		elseif M.Routine5State == 13 then
			Patrol(BuildObject("cvtank", 5, "hadconstart"), "conpatrol", 1);
			Goto(BuildObject("cvturr02", 5, "hadconstart"), "patrolp3", 1);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 30;	
		elseif M.Routine5State == 14 then
			M.Routine5Counter = M.Routine5Counter + 1;
			if M.Routine5Counter < M.JammerState then
				M.Routine5State = 12;--to LOC_196
			else
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 15 then	--LOC_209
			if M.BridgeBombStart > 0 then
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 16 then	--LOC_212
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 30;
		elseif M.Routine5State == 17 then
			M.Attacker01 = BuildObject("cvscout", 5, "HadStart");
			M.Attacker02 = BuildObject("cvhatank", 5, "HadStart");
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 15;
		elseif M.Routine5State == 18 then
			Patrol(M.Attacker01,"cerbsault_1",1);
			Patrol(M.Attacker02,"cerbsault_1",1);
			M.Attacker03 = BuildObject("cvrbomb", 5, "hadconstart");
			Patrol(M.Attacker03, "cerbsault_1", 1);
			M.Attacker04 = BuildObject("cvturr02", 5, "hadconstart");
			Goto(M.Attacker04, "BridWest", 1);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 35;
		elseif M.Routine5State == 19 then
			Attack(M.Attacker02, Recycler, 1);
			Attack(M.Attacker03, Player, 1);
			M.Routine5Counter = M.Routine5Counter + 1;
			if M.Routine5Counter < M.JammerState then
				M.Routine5State = 16;--to LOC_212
			else
				M.Routine5Counter = 0;
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 20 then	--LOC_228
			if M.BridgeDestroyed >= 1 then
				M.Routine5State = M.Routine5State + 1;
			end
		elseif M.Routine5State == 21 then	--LOC_231
			M.Attacker01 = BuildObject("cvmlay", 5, "portalsouth");
			Goto(M.Attacker01, "convendpoint", 1);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 10;
		elseif M.Routine5State == 22 then
			Mine(M.Attacker01, "watertack2", 1);
			M.Attacker02 = BuildObject("cvhatank", 5, "portalsouth");
			Goto(M.Attacker02, "convendpoint", 1);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 10;
		elseif M.Routine5State == 23 then
			Patrol(M.Attacker02, "convoy_1", 1);
			M.Attacker03 = BuildObject("cvtalon02",5,"portalsouth");
			Goto(M.Attacker03, "convendpoint", 1);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 10;
		elseif M.Routine5State == 24 then
			Patrol(M.Attacker03, "convoy_1", 1);
			M.Attacker04 = BuildObject("cvturr02",5,"portalsouth");
			Goto(M.Attacker04, "convendpoint", 1);
			M.Routine5State = M.Routine5State + 1;
			M.Routine5Timer = GetTime() + 20;
		elseif M.Routine5State == 25 then
			Attack(M.Attacker02, M.Player, 1);
			Attack(M.Attacker03, M.Player, 1);
			M.Routine5Counter = M.Routine5Counter + 1;
			if M.Routine5Counter < M.JammerState then
				M.Routine5State = 21;--to LOC_231
			else
				M.Routine5Counter = 0;
				M.Routine5State = M.Routine5State + 1;
			end
		end
	end
end

--spawns attackers while player is not in the hadean comm bunker.
--stops when bridge is destroyed.
function Routine6()
	local jmp = {3,4,7};
	if M.Routine6Active and M.Routine6Timer < GetTime() then 
		if M.Routine6State == 0 then	--LOC_252
			if M.PlayerUsingCbunk ~= 1 then
				M.Routine6State = M.Routine6State  + 1;
				M.Routine6Timer = GetTime() + 5;
			end
		elseif M.Routine6State == 1 then	--LOC_256
			if M.BridgeBombStart > 0 then
				M.Routine6State = 99;
			else
				--JammerState is 1 if ECM pod is < 200m from recy, 2 if 200-300m away, and 3 if >300m away.
				local spawnDelay = (4 - M.JammerState) * 30;
				M.Routine6State = M.Routine6State + 1;
				M.Routine6Timer = GetTime() + spawnDelay;
			end
		elseif M.Routine6State == 2 then
				M.Routine6State = jmp[math.random(1,3)];
		elseif M.Routine6State == 3 then
			if not IsAround(M.Attacker20) then
				M.Attacker20 = BuildObject("cvtank", 5, "hadconstart");
				Patrol(M.Attacker20, "conpatrol2", 1);
			end
			if not IsAround(M.Attacker21) then
				M.Attacker21 = BuildObject("cvturr02", 5, "hadconstart");
				Goto(M.Attacker21, "bendstop", 1);
			end
			M.Routine6State = 0;
		elseif M.Routine6State == 4 then	--LOC_271
			if not IsAround(M.Attacker22) then
				if math.random(1,2) == 1 then
					--M.Attacker22 = BuildObject("cvtalon02",5,"hadconstart");	--was "cvtalon", but that doesn't exist!
					--Patrol(M.Attacker22, "conpatrol", 1);
					M.Routine6State = 6;--to LOC_280
				else
					M.Routine6State = M.Routine6State + 1;
					M.Routine6Timer = GetTime() + 30;
				end
			else
				M.Routine6State = 6;--to LOC_280
			end
		elseif M.Routine6State == 5 then	--LOC_277
			M.Attacker22 = BuildObject("cvhatank", 5, "hadconstart");
			Patrol(M.Attacker22, "bridatck", 1);
			M.Routine6State = M.Routine6State + 1;
		elseif M.Routine6State == 6 then	--LOC_280
			if not IsAround(M.Attacker23) then
				M.Attacker23 = BuildObject("cvrbomb", 5, "hadconstart");
				Patrol(M.Attacker23, "conpatrol2", 1);
			end
			M.Routine6State = 0;
		elseif M.Routine6State == 7 then	--LOC_285
			if not IsAround(M.Attacker24) then
				M.Attacker24 = BuildObject("cvscout", 5, "hadconstart");
				Patrol(M.Attacker24, "conpatrol", 1);
			end
			if not IsAround(M.Attacker25) then
				M.Attacker25 = BuildObject("cvtank", 5, "hadconstart");
				Goto(M.Attacker25, "BridEast", 1);
				M.Routine6Timer = GetTime() + 20;
			end
			M.Routine6State = M.Routine6State + 1;
		elseif M.Routine6State == 8 then
			Patrol(M.Attacker25, "bridatck", 1);
			M.Routine6State = 0;
		end
	end
end

--poops out service pods from tugs
function Routine7()
	if M.Routine7Timer < GetTime() then
		if M.Routine7State == 0 then
			M.Routine7State = M.Routine7State + 1;
			M.Routine7Timer = GetTime() + 30;
		elseif M.Routine7State == 1 then	--LOC_300
			M.Routine7State = M.Routine7State + 1;
			M.Routine7Timer = GetTime() + 25;
		elseif M.Routine7State == 2 then
			if IsAround(M.Tug1) then
				local pos = GetPosition(M.Tug1);
				M.ServicePod = BuildObject("apserv07", 1, pos);				
				M.Position30 = SetVector(pos.x + 10, pos.y + 15, pos.z + 10);
				M.Routine7State = M.Routine7State + 1;
			else
				M.Routine7State = 4;
			end
		elseif M.Routine7State == 3 then
			if Move(M.ServicePod, M.Pod1RotRate, M.Pod1MoveSpeed, M.Position30, false) then
				M.Routine7State	= M.Routine7State + 1;
			end
			SetVelocity(M.ServicePod, ZERO_VECTOR);
		elseif M.Routine7State == 4 then	--LOC_307
			M.Routine7State	= M.Routine7State + 1;
			M.Routine7Timer = GetTime() + 25;
		elseif M.Routine7State == 5 then
			if IsAround(M.Tug2) then
				local pos = GetPosition(M.Tug2);
				M.ServicePod = BuildObject("apserv07", 1, pos);				
				M.Position30 = SetVector(pos.x + 10, pos.y + 15, pos.z + 10);
				M.Routine7State = M.Routine7State + 1;
			else
				M.Routine7State = 7;
			end
		elseif M.Routine7State == 6 then	--LOC_314
			if Move(M.ServicePod, M.Pod2RotRate, M.Pod2MoveSpeed, M.Position30, false) then
				M.Routine7State	= M.Routine7State + 1;
			end
			SetVelocity(M.ServicePod, ZERO_VECTOR);
		elseif M.Routine7State == 7 then
			if IsOdf(M.Recycler, "ivrecy") and (IsAround(M.Tug1) or IsAround(M.Tug2)) then
				M.Routine7State = 1;
			else
				M.Routine7State = M.Routine7State + 1;
			end
		end
	end
end

--handles the convoy escort and deployment of the recycler
function Routine8()
	if M.Routine8Timer < GetTime() then
		if M.Routine8State == 0 then
			Stop(M.Recycler, 1);
			M.NextWaypointNav = BuildObject("ibnav",1,"bendstop");
			SetObjectiveName(M.NextWaypointNav, "First Waypoint");
			SetObjectiveOn(M.NextWaypointNav);
			--SetCockpitTimer(15); --??
			AddObjective(_Text1, "white");
			AudioMessage("e7start.wav");	--Windex:"Corber, you're in charge of escorting the convoy..."
			SetObjectiveOn(M.Recycler);	--added objective marker on recy for the duration of the escort
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 25;	--bumped up from 10 to give the player a bit more time to prepare
		elseif M.Routine8State == 1 then
			Patrol(M.Recycler, "convoy_1", 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 5;
		elseif M.Routine8State == 2 then
			Stop(M.Recycler, 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 3;
		elseif M.Routine8State == 3 then	--LOC_337
			Patrol(M.Recycler, "convoy_1", 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 4;
		elseif M.Routine8State == 4 then
			Stop(M.Recycler, 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 3;
		elseif M.Routine8State == 5 then
			if GetDistance(M.Recycler, "bendstop") < 500 then
				AudioMessage("skyeye.wav");	--Eisenstein:"General Hardin sent one of the StormPetrel's defense craft through the portal..."
				M.Routine8State = M.Routine8State + 1;
			else
				M.Routine8State = 3;--to LOC_337
			end
		elseif M.Routine8State == 6 then	--LOC_344
			Patrol(M.Recycler, "convoy_1", 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 6;
		elseif M.Routine8State == 7 then
			Stop(M.Recycler, 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 1;
		elseif M.Routine8State == 8 then
			if GetDistance(M.Recycler, "bendstop") < 75 then
				if IsAround(M.BridgeGuard1) then
					Stop(M.Recycler, 1);
					AudioMessage("e7bridtow1.wav");	--Windex:"Mr Corber, you were supposed to clear our path of all threats..."
					ClearObjectives();
					AddObjective(_Text4, "white");
					SetObjectiveName(M.BridgeGuard1, "Eliminate MegaGuard!");
					SetObjectiveOn(M.BridgeGuard1);
					M.Routine8State = M.Routine8State + 1;
				else
					M.Routine8State = 10;--to LOC_362
				end
			else
				M.Routine8State = 6;--to LOC_344
			end
		elseif M.Routine8State == 9 then	--LOC_358
			if not IsAround(M.BridgeGuard1) then
				ClearObjectives();
				AddObjective(_Text4, "green");
				M.Routine8State = M.Routine8State + 1;
				M.Routine8Timer = GetTime() + 3;
			end
		elseif M.Routine8State == 10 then	--LOC_362
			RemoveObject(M.NextWaypointNav);
			M.NextWaypointNav = BuildObject("ibnav",1,"BridEast");
			SetObjectiveName(M.NextWaypointNav, "Second Waypoint");
			SetObjectiveOn(M.NextWaypointNav);
			Patrol(M.Recycler, "convoy_1", 1);
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 11 then	--LOC_367
			if GetDistance(M.Recycler, "BridEast") < 100 then
				Stop(M.Recycler, 1);
				if M.CbunkUploadFinished > 0 then
					M.Routine8State = 14;--to LOC_386
				else
					if M.Variable17 == 1 then
						M.Routine5Active = false;	--disable Cerb spawning while player is using the comm bunk. Should also fix Cerb units showing up as blue on radar.
					end
					M.PlayerUsingCbunk = 1;
					ClearObjectives();
					AddObjective(_Text2, "white");
					AudioMessage("findbunk.wav");	--Eisenstein:"Skyeye is picking up some unusual radio signals coming from a nearby comm bunker..."
					SetObjectiveName(M.HadeanCommBunk, "Investigate");
					SetObjectiveOn(M.HadeanCommBunk);
					M.Routine8State = M.Routine8State + 1;
				end
			end
		elseif M.Routine8State == 12 then	--LOC_379
			if GetDistance(M.Player, M.HadeanCommBunk) < 100 then
				ClearObjectives();
				AddObjective(_Text3, "white");
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 13 then	--LOC_383
			if M.CbunkUploadFinished > 0 then
				M.Routine5Active = true;	--reenable Cerb spawning once player is done with the comm bunker. Should also fix Cerb units showing up as blue on radar.
				SetObjectiveOff(M.HadeanCommBunk);
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 14 then	--LOC_386
			if not IsAround(M.BridgeGuard2) then
				M.Routine8State = 17;--to LOC_401
			else
				M.Routine8State = M.Routine8State + 1;
				M.Routine8Timer = GetTime() + 25;
			end	
		elseif M.Routine8State == 15 then
			AudioMessage("e7bridtow2.wav");	--Windex:"Corber, your blundering incompetence is going to get us all killed..."
			ClearObjectives();
			AddObjective(_Text5, "white");
			SetObjectiveName(M.BridgeGuard2, "Destroy 2nd MegaGuard!");
			SetObjectiveOn(M.BridgeGuard2);
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 16 then	--LOC_394
			if not IsAround(M.BridgeGuard2) then
				ClearObjectives();
				AddObjective(_Text5, "green");
				M.Routine8State = M.Routine8State + 1;
				M.Routine8Timer = GetTime() + 10;
			end
		elseif M.Routine8State == 17 then	--LOC_401
			RemoveObject(M.NextWaypointNav);
			--RemoveObject(GetHandle("Hadean Labs"));
			M.NextWaypointNav = BuildObject("ibnav", 1, "BridWest");
			SetObjectiveName(M.NextWaypointNav, "Third Waypoint");
			SetObjectiveOn(M.NextWaypointNav);
			Patrol(M.Recycler, "convoy_1", 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 5;
		elseif M.Routine8State == 18 then	--LOC_409
			if GetDistance(M.Recycler, "BridWest") < 75 then
				M.Routine8State = M.Routine8State + 1;
				M.Routine8Timer = GetTime() + 10;
			end
		elseif M.Routine8State == 19 then
			Stop(M.Recycler, 1);
			ClearObjectives();
			AddObjective(_Text6, "white");
			AudioMessage("letsbomb.wav");	--Skyeye:"Reporting a massive wave of heavy armor approaching the river from the east..."
			M.Bridge1 = GetHandle("bomseg1_hbbseg07d");
			M.Bridge2 = GetHandle("bomseg2_hbbseg07");
			M.Bridge3 = GetHandle("bomseg3_hbbseg07");
			M.Position2 = GetPosition(M.Bridge1);
			M.Position3 = GetPosition(M.Bridge2);
			M.Position4 = GetPosition(M.Bridge3);
			SetObjectiveName(M.Bridge1, "Weakest Segment");
			M.BridgeLookoutNav = BuildObject("ibnav", 1, "West_Tower");
			SetObjectiveName(M.BridgeLookoutNav, "Observation Point");
			SetObjectiveOn(M.BridgeLookoutNav);
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 20 then	--LOC_426
			Goto(BuildObject("cvhatank", 5, "hadconstart"), "BridEast", 1);
			Goto(BuildObject("evartl07", 5, "hadconstart"), "BridEast", 1);
			M.Routine8Counter = M.Routine8Counter + 1;
			if M.Routine8Counter >= 2 then
				M.Routine8State = M.Routine8State + 1
			else
				M.Routine8Timer = GetTime() + 0.2;
			end
		elseif M.Routine8State == 21 then	--LOC_436
			if GetDistance(M.Player, M.BridgeLookoutNav) < 50 then
				--AudioMessage("abetty10.wav");
				StartSoundEffect("abetty10.wav", M.Player);
				M.Routine8Counter = 0;
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 22 then	--LOC_441
			Goto(BuildObject("cvhatank", 5, "bridstop"), "BridWest", 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 3;
		elseif M.Routine8State == 23 then
			M.Attacker05 = BuildObject("evartl07", 5, "bridstop");
			Goto(M.Attacker05, "BridWest", 1);
			M.Attacker06 = BuildObject("cvhatank", 5, "BridEast");
			Goto(M.Attacker06, "bridatck", 1);
			M.Attacker07 = BuildObject("evartl07", 5, "BridEast");
			Patrol(M.Attacker07, "bridatck", 1);
			M.Routine8Counter = M.Routine8Counter + 1;
			if M.Routine8Counter <= 2 then
				M.Routine8State = 22;--to LOC_441
			else
				Goto(BuildObject("cvturr02", 5, "portalsouth"), "recy_deploy1", 1);
				Goto(BuildObject("cvturr02", 5, "portalsouth"), "recy_deploy2", 1);
				M.Routine8State = M.Routine8State + 1;
				M.Routine8Timer = GetTime() + 3;
			end	
		elseif M.Routine8State == 24 then	--LOC_456
			if GetUserTarget() == M.Bridge1 then
				M.BridgeBombStart = 1;
				AudioMessage("lock02.wav");
				M.Routine8State = M.Routine8State + 1;
				M.Routine8Timer = GetTime() + 2;
			end
		elseif M.Routine8State == 25 then
			AudioMessage("fmiss01.wav");
			M.Position2.y = M.Position2.y + 512;
			M.Position3.y = M.Position3.y + 512;
			M.Position4.y = M.Position4.y + 512;
			M.Bomb1 = BuildObject("apwrck7", 0, M.Position2);
			M.Position2.y = M.Position2.y - 512;
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 26 then
			if Move(M.Bomb1, M.BombRotRate, M.BombDropSpeed, M.Position2, false) then
				M.Bridge1 = ReplaceObject(M.Bridge1, "e7bbdesty");
				AudioMessage("fmiss01.wav");
				M.Bomb2 = BuildObject("apwrck7", 0, M.Position3);
				M.Position3.y = M.Position3.y - 512;
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 27 then
			if Move(M.Bomb2, M.BombRotRate, M.BombDropSpeed, M.Position3, false) then
				M.Bridge2 = ReplaceObject(M.Bridge2, "e7porock");
				AudioMessage("fmiss01.wav");
				M.Bomb3 = BuildObject("apwrck7", 0, M.Position4);
				M.Position4.y = M.Position4.y - 512;
				M.Routine8State = M.Routine8State + 1;
			end
		elseif M.Routine8State == 28 then
			if Move(M.Bomb3, M.BombRotRate, M.BombDropSpeed, M.Position4, false) then
				M.Bridge3 = ReplaceObject(M.Bridge3, "e7bbdestz");
				Damage(M.Attacker05, 1500);
				Damage(M.Attacker06, 2000);
				Damage(M.Attacker07, 2500);
				ClearObjectives();
				AddObjective(_Text6, "green");
				RemoveObject(M.BridgeLookoutNav);
				M.Routine8State = M.Routine8State + 1;
				M.Routine8Timer = GetTime() + 1;
			end
		elseif M.Routine8State == 29 then
			Patrol(M.Recycler,"convoy_1", 1);
			M.BridgeDestroyed = M.BridgeDestroyed + 1;
			RemoveObject(M.NextWaypointNav);
			M.NextWaypointNav = BuildObject("ibnav", 1, "MtnPass");
			SetObjectiveName(M.NextWaypointNav, "Fourth Waypoint");
			SetObjectiveOn(M.NextWaypointNav);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 5;
		elseif M.Routine8State == 30 then
			AudioMessage("Eyedown.wav");	--Skyeye:"One of those huge towers has just fired and the missile is tracking flawlessly..."
			M.Routine8State = M.Routine8State + 1;
		elseif M.Routine8State == 31 then	--LOC_492
			Stop(M.Recycler, 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 1;
		elseif M.Routine8State == 32 then
			Patrol(M.Recycler, "convoy_1", 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 8;
		elseif M.Routine8State == 33 then
			if GetDistance(M.Recycler, "MtnPass") < 100 then
				RemoveObject(M.NextWaypointNav);
				M.NextWaypointNav = BuildObject("ibnav", 1, "convendpoint");
				SetObjectiveName(M.NextWaypointNav, "Final Waypoint");
				SetObjectiveOn(M.NextWaypointNav);
				M.Routine8State = M.Routine8State + 1;
			else
				M.Routine8State = 31;--to LOC_492
			end
		elseif M.Routine8State == 34 then	--LOC_502
			Stop(M.Recycler, 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 1;
		elseif M.Routine8State == 35 then
			Patrol(M.Recycler, "convoy_1", 1);
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 8;
		elseif M.Routine8State == 36 then
			if GetDistance(M.Recycler, "convendpoint") < 100 then
				Stop(M.Recycler, 0);
				AudioMessage("e7deploy1.wav");	--Shultz:"Major Windt-Essex, this deployment point seems awfully prone to assault..."
				M.WindexDeployNav = BuildObject("ibnav", 1, "recy_deploy1");
				SetObjectiveName(M.WindexDeployNav, "Wyndt-Essex's Deploy Point");
				SetObjectiveOn(M.WindexDeployNav);
				M.SchultzDeployNav = BuildObject("ibnav", 1, "recy_deploy2");
				SetObjectiveName(M.SchultzDeployNav, "Schultz's Alternate Point");
				SetObjectiveOn(M.SchultzDeployNav);
				ClearObjectives();
				AddObjective(_Text7, "red");
				M.Routine8State = M.Routine8State + 1;
				M.Routine8Timer = GetTime() + 30;
			else
				M.Routine8State = 34;--to LOC_502
			end
		elseif M.Routine8State == 37 then	--LOC_519
			if not IsOdf(M.Recycler, "ivrecy") then
				if IsAround(M.Tug1) then
					AddScrap(1, 20);
				end
				if IsAround(M.Tug2) then
					AddScrap(1, 20);
				end
				if GetDistance(M.Recycler, "recy_deploy1") > 300 then
					AudioMessage("rodrprmd.wav");	--Windex:"Commander, you have chosen to ignore my direct order on deployment of the recycler..."
					M.DisobeyedWindex = M.DisobeyedWindex + 1;
				end
				SetObjectiveOff(M.Recycler);
				M.Routine8State =  M.Routine8State + 1;
			end
		elseif M.Routine8State == 38 then	--LOC_531
			ClearObjectives();
			AddObjective(_Text8, "white");
			M.Routine8State =  M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 10;
		elseif M.Routine8State == 39 then
			RemoveObject(M.WindexDeployNav);
			RemoveObject(M.SchultzDeployNav);
			RemoveObject(M.NextWaypointNav);
			M.Routine8State =  M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 15;
		elseif M.Routine8State == 40 then
			M.NextWaypointNav = BuildObject("ibnav", 1, "biotanks");
			SetObjectiveName(M.NextWaypointNav, "Resources Detected");
			SetObjectiveOn(M.NextWaypointNav);
			AddObjective(_Text21, "white");
			M.Routine10Active = true;--RunSpeed,_Routine10,1,false
			AudioMessage("Shultank.wav");	--Shultz:"Good news for your scav jockeys..."
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 45;
		elseif M.Routine8State == 41 then
			M.Routine9Active = true; --RunSpeed,_Routine9,1,false
			M.Routine8State = M.Routine8State + 1;
			M.Routine8Timer = GetTime() + 300;
		elseif M.Routine8State == 42 then
			RemoveObject(M.NextWaypointNav);
			M.Routine8State = M.Routine8State + 1;
		end
	end
end

--activated after player has established base
--spawns Cerb attackers that patrol the area and attack the player's base
--Cerb spawn at higher rate if the ECM Jammer was destroyed.
function Routine9()
	if M.Routine9Active and M.Routine9Timer < GetTime() then
		if M.Routine9State == 0 then	--LOC_549
			if GetObjectByTeamSlot(1,3) ~= nil then
				M.Routine9State = 11;--to LOC_608
			else
				M.Routine9State = M.Routine9State + 1;
				M.Routine9Timer = GetTime() + 1;
			end
		elseif M.Routine9State == 1 then
			if not IsAround(M.Attacker13) then
				M.Attacker13 = TeleportIn("cvrbomb", 5, "waterport", 10);
			end
			M.Routine9State = M.Routine9State + 1;
		elseif M.Routine9State == 2 then	--LOC_558
			M.Attacker14 = TeleportIn("cvatank2", 5, "portalsouth", 10);
			--M.Attacker15 = BuildObject("cvtank", 5, "waterstart");	--"waterstart"/"watershort" is on other side of river. units get stuck and pile up!
			Patrol(M.Attacker13, "waterportpath", 1);
			Patrol(M.Attacker14, "portalsouthpath", 1);
			--Patrol(M.Attacker15, "watershort", 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 30;
		elseif M.Routine9State == 3 then
			Attack(M.Attacker13, M.Recycler, 1);
			--M.Constructor = GetHandle("unnamed_ivcons");
			if M.Constructor ~= nil then
				Attack(M.Attacker14, M.Constructor, 1);
				--Attack(M.Attacker15, M.Constructor, 1);
			end			
			SetCurHealth(M.Attacker14, 6000);
			M.Attacker16 = TeleportIn("cvscout", 5, "islandstart", 10);
			M.Attacker17 = TeleportIn("cvturr02", 5, "islandstart", 10);
			Patrol(M.Attacker16, "islandpath", 1);
			Patrol(M.Attacker17, "islandpath", 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 20;
		elseif M.Routine9State == 4 then
			SetCurHealth(M.Attacker16, 2200);
			SetCurHealth(M.Attacker16, 2500);
			Goto(M.Attacker14, "waterstart2", 1);
			Goto(M.Attacker16, "waterstart2", 1);
			Goto(M.Attacker17, "waterstart2", 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 20;
		elseif M.Routine9State == 5 then
			if math.random(1,2)==1 then
				M.Routine9State = 7;--to LOC_588
			else
				Attack(M.Attacker13, M.Player, 1);
				Patrol(M.Attacker14, "watertack1", 1);
				Patrol(M.Attacker16, "watertack1", 1);
				Patrol(M.Attacker17, "watertack1", 1);
				M.Routine9State = M.Routine9State + 1;
				M.Routine9Timer = GetTime() + 20;
			end
		elseif M.Routine9State == 6 then
			Stop(M.Attacker17, 1);
			M.Routine9State = 9;--to LOC_595
		elseif M.Routine9State == 7 then	--LOC_588
			if IsAround(M.Constructor) then
				Attack(M.Attacker13, M.Constructor, 1);
			end
			Patrol(M.Attacker14, "watertack2", 1);
			Patrol(M.Attacker16, "watertack2", 1);
			Patrol(M.Attacker17, "watertack2", 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 20;
		elseif M.Routine9State == 8 then
			Stop(M.Attacker17, 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 30;
		elseif M.Routine9State == 9 then --LOC_595
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 1;
		elseif M.Routine9State == 10 then
			--check if player built an armory
			if IsAround(GetObjectByTeamSlot(1,3)) then
				M.Routine9State = M.Routine9State + 1;--to LOC_608
			else
				M.Routine9State = 0;--to LOC_549
				if M.JammerState < 2 then
					M.Routine9Timer = 120;
				elseif M.JammerState == 2 then
					M.Routine9Timer = 60;
				else
					M.Routine9Timer = 30;
				end
			end
		elseif M.Routine9State == 11 then	--LOC_608
			--player has just built an armory
			M.Routine9Counter = 0;
			ClearObjectives();
			AddObjective(_Text8, "green");
			M.Attacker18 = TeleportIn("cvdcar", 5, "islandstart", 10);
			Patrol(M.Attacker18, "islandpath", 1);
			M.Attacker19 = TeleportIn("cvtalon02", 5, "portalsouth", 10);
			Goto(M.Attacker19, "waterstart2", 1);
			AudioMessage("dronewow.wav");	--Random Dude:"Sir, this is scout patrol Gamma by the river. We just spotted some kind of huge hovercraft headed your way..."
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 20;
		elseif M.Routine9State == 12 then
			Goto(M.Attacker18, "recy_deploy1", 1);
			Patrol(M.Attacker19, "watertack1", 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 20;
		elseif M.Routine9State == 13 then
			Attack(M.Attacker18, M.Recycler, 1);
			Attack(M.Attacker19, M.Recycler, 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 35;
		elseif M.Routine9State == 14 then
			M.Attacker16 = TeleportIn("cvrbomb", 5, "portalsouth", 10);
			M.Attacker17 = TeleportIn("cvdcar", 5, "islandstart", 10);
			Patrol(M.Attacker16, "portalsouthpath", 1);
			Patrol(M.Attacker17, "islandpath", 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 20;
		elseif M.Routine9State == 15 then
			SetCurHealth(M.Attacker17, 8000);
			M.Routine11Active = true;--RunSpeed,_Routine11,1,false
			M.Routine9State = M.Routine9State + 1;
		elseif M.Routine9State == 16 then	--LOC_630
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 17 then
			if M.PlayerRecalledToBase then
				M.Routine9State = M.Routine9State + 1;
				M.RecyOldHealth = GetCurHealth(M.Recycler);
			end
		elseif M.Routine9State == 18 then	--LOC_634
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 19 then
			if GetCurHealth(M.Recycler) < M.RecyOldHealth then	--keeps recy alive while player is away from base
				AddHealth(M.Recycler, 200);
				if GetDistance(M.Player, M.Recycler) > 750 then
					M.Routine9State = M.Routine9State - 1;--to LOC_634
				else
					Attack(M.Attacker13, M.Recycler, 1);
					Attack(M.Attacker14, M.Recycler, 1);
					Attack(M.Attacker15, M.Recycler, 1);
					Attack(M.Attacker16, M.Recycler, 1);
					Attack(M.Attacker17, M.Recycler, 1);
					M.Routine9State = M.Routine9State + 1;
					M.Routine9Timer = GetTime() + 62;
				end
			else
				M.Routine9State = M.Routine9State - 1;--to LOC_634
			end	
		elseif M.Routine9State == 20 then
			SetCurHealth(M.Attacker13, 500);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 21 then
			SetCurHealth(M.Attacker13, 10);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 22 then
			Damage(M.Attacker13, 11);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 23 then
			SetCurHealth(M.Attacker14, 500);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 24 then
			SetCurHealth(M.Attacker14, 10);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 25 then
			Damage(M.Attacker14, 11);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 26 then
			SetCurHealth(M.Attacker15, 500);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 27 then
			SetCurHealth(M.Attacker15, 10);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 28 then
			Damage(M.Attacker15, 11);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 29 then
			SetCurHealth(M.Attacker16, 500);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 30 then
			SetCurHealth(M.Attacker16, 10);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 31 then
			Damage(M.Attacker16, 11);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 32 then
			SetCurHealth(M.Attacker17, 500);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 33 then
			SetCurHealth(M.Attacker17, 10);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 34 then
			Damage(M.Attacker17, 11);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 35 then
			SetCurHealth(M.Attacker18, 500);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 36 then
			SetCurHealth(M.Attacker18, 10);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 37 then
			Damage(M.Attacker18, 11);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 2;
		elseif M.Routine9State == 38 then	--LOC_683
			M.Routine9State = M.Routine9State + 1;
			if IsAround(M.EcmJammer) then
				M.Routine9Timer = GetTime() + 75;
			else
				M.Routine9Timer = GetTime() + 25;
			end
		elseif M.Routine9State == 39 then
			local jmp = {40,40,42,44};
			M.Routine9State = jmp[math.random(1,4)];
		elseif M.Routine9State == 40 then	--LOC_688
			if not IsAround(M.Attacker13) then
				M.Attacker13 = TeleportIn("cvtank", 5, "waterport", 10);
				SetSkill(M.Attacker13, 3);
				Goto(M.Attacker13, "waterstart2", 1);
				M.Routine9State = M.Routine9State + 1;
			else
				M.Routine9State = M.Routine9State + 2;--to LOC_700
			end
		elseif M.Routine9State == 41 then
			if GetDistance(M.Attacker13, "waterstart2") < 50 then
				if math.random(1,2) == 1 then
					Patrol(M.Attacker13, "watertack1", 1);
				else
					Patrol(M.Attacker13, "watertack2", 1);
				end
				M.Routine9State = M.Routine9State + 1;
			elseif not IsAround(M.Attacker13) then
				M.Routine9State = M.Routine9State + 1;
			end
		elseif M.Routine9State == 42 then	--LOC_700
			if not IsAround(M.Attacker14) then
				if math.random(1,2) == 1 then
					M.Attacker14 = TeleportIn("cvhatank", 5, "portalsouth", 10);
				else
					M.Attacker14 = TeleportIn("cvtank", 5, "portalsouth", 10);
				end
				SetSkill(M.Attacker14, 3);
				Patrol(M.Attacker14, "portalsouthpath", 1);
			end
			M.Routine9State = 38;--to LOC_683
		elseif M.Routine9State == 43 then	--LOC_711
			if not IsAround(M.Attacker15) then
				M.Attacker15 = TeleportIn("cvrbomb", 5, "islandstart", 10);
				SetSkill(M.Attacker15, 3);
				Patrol(M.Attacker15, "islandpath", 1);
			elseif not IsAround(M.Attacker16) then
				M.Attacker16 = TeleportIn("cvscout", 5, "portalsouth", 10);
				SetSkill(M.Attacker16, 3);
				Patrol(M.Attacker16, "portalsouthpath", 1);
			end
			M.Routine9State = 38;--to LOC_683
		elseif M.Routine9State == 44 then	--LOC_723
			if not IsAround(M.Attacker17) then
				M.Attacker17 = TeleportIn("cvscout", 5, "waterport", 10);
				SetSkill(M.Attacker17, 3);
				Patrol(M.Attacker17, "waterportpath", 1);
				M.Routine9State = M.Routine9State + 1;
				M.Routine9Timer = GetTime() + 20;
			else
				M.Routine9State = M.Routine9State + 3;--LOC_735
			end
		elseif M.Routine9State == 45 then
			Goto(M.Attacker17, "waterstart2", 1);
			M.Routine9State = M.Routine9State + 1;
			M.Routine9Timer = GetTime() + 5;
		elseif M.Routine9State == 46 then
			if math.random(1,2) == 1 then
				Patrol(M.Attacker17, "watertack1", 1);
			else
				Patrol(M.Attacker17, "watertack2", 1);
			end
			M.Routine9State = M.Routine9State + 1;
		elseif M.Routine9State == 47 then	--LOC_735
			if IsAround(M.Attacker18) then
				M.Attacker18 = BuildObject("cvatank2", 5, "islandstart");
				SetSkill(M.Attacker18, 3);
				Patrol(M.Attacker18, "islandpath", 1);
				M.Routine9State = M.Routine9State + 1;
				M.Routine9Timer = GetTime() + 20;
			else
				M.Routine9State = 38;--to LOC_683
			end	
		elseif M.Routine9State == 48 then
			if math.random(1,2) == 1 then
				Patrol(M.Attacker18, "islandpath", 1);
			else
				if IsAround(M.EcmJammer) then
					Attack(M.Attacker18, M.EcmJammer, 1);
				else
					Attack(M.Attacker18, M.Recycler, 1);
				end
			end
			M.Routine9State = 38;--to LOC_683
		end
	end
end

--Spawns Cerb attackers from crater portal after player has established a base
--Cerb spawns are more frequent if the ECM Jammer has been destroyed.
function Routine10()
	if M.Routine10Active and M.Routine10Timer < GetTime() then
		if M.Routine10State == 0 then	--LOC_751
			M.Routine10State = M.Routine10State + 1;
			if IsAround(M.EcmJammer) then
				M.Routine10Timer = GetTime() + 35;
			end
		elseif M.Routine10State == 1 then	--LOC_754
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 15;
		elseif M.Routine10State == 2 then
			local jmp = {3,8,16};
			M.Routine10State = jmp[math.random(1,3)];
		elseif M.Routine10State == 3 then
			if not IsAround(M.Attacker20) then
				M.Attacker20 = TeleportIn("cvtank", 5, "westcratport", 10);
				SetSkill(M.Attacker20, 3);
				Goto(M.Attacker20, "westcratatkin", 1);
				M.Routine10State = M.Routine10State + 1;
				M.Routine10Timer = GetTime() + 10;
			else
				M.Routine10State = 6;--to LOC_768
			end
		elseif M.Routine10State == 4 then
			Goto(M.Attacker20, "westcratatkout", 1);
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 10;
		elseif M.Routine10State == 5 then
			if math.random(1,2) == 1 then
				Patrol(M.Attacker20, "westcratatk1", 1);
			else
				Patrol(M.Attacker20, "westcratatk2", 1);
			end
			M.Routine10State = M.Routine10State + 1;
		elseif M.Routine10State == 6 then	--LOC_768
			if not IsAround(M.Attacker21) then
				M.Routine10State = M.Routine10State + 1;
				M.Routine10Timer = GetTime() + 20;
			else
				M.Routine10State = 0;--to LOC_751
			end
		elseif M.Routine10State == 7 then
			M.Attacker21 = BuildObject("cvtalon02", 5, M.Position29);
			SetSkill(M.Attacker21, 1);
			if math.random(1,2) == 1 then
				Patrol(M.Attacker21, "westcratatk1", 1);
			else
				Patrol(M.Attacker21, "westcratatk2", 1);
			end
			M.Routine10State = 0;--to LOC_751
		elseif M.Routine10State == 8 then	--LOC_778
			if not IsAround(M.Attacker22) then
				M.Attacker22 = TeleportIn("cvscout", 5, "westcratport", 10);
				SetSkill(M.Attacker22, 3);
				Goto(M.Attacker22, "westcratatkin", 1);
				M.Routine10State = M.Routine10State + 1;
				M.Routine10Timer = GetTime() + 10;
			else
				M.Routine10State = 11;--to LOC_790
			end
		elseif M.Routine10State == 9 then
			Goto(M.Attacker22, "westcratatkout", 1);
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 10;
		elseif M.Routine10State == 10 then
			if math.random(1,2) then
				Patrol(M.Attacker22, "westcratatk1", 1);
			else
				Patrol(M.Attacker22, "westcratatk2", 1);
			end
			M.Routine10State = M.Routine10State + 1;
		elseif M.Routine10State == 11 then	--LOC_790
			if not IsAround(M.Attacker23) then
				M.Attacker23 = TeleportIn("cvmlay", 5, "westcratport", 10);
				SetSkill(M.Attacker23, 3);
				Goto(M.Attacker23, "westcratatkin", 1);
				M.Routine10State = M.Routine10State + 1;
				M.Routine10Timer = GetTime() + 10;
			else
				M.Routine10State = 0;--to LOC_751
			end
		elseif M.Routine10State == 12 then
			Goto(M.Attacker23, "westcratatkout", 1);
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 10;
		elseif M.Routine10State == 13 then
			if math.random(1,2) == 1 then
				Mine(M.Attacker23, "westcratatk2", 1);
				M.Routine10State = 0;
			else
				Patrol(M.Attacker23, "westcratatk2", 1);
				M.Routine10State = M.Routine10State + 1;
				M.Routine10Timer = GetTime() + 10;
			end
		elseif M.Routine10State == 14 then
			Patrol(M.Attacker23, "watertack1", 1);
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 10;
		elseif M.Routine10State == 15 then
			Mine(M.Attacker23, "watertack1", 1);
			M.Routine10State = 0;--to LOC_751
		elseif M.Routine10State == 16 then	--LOC_807
			if not IsAround(M.Attacker24) then
				M.Attacker24 = TeleportIn("cvhatank", 5, "westcratport", 10);
				SetSkill(M.Attacker24, 3);
				Goto(M.Attacker24, "westcratatkin", 1);
				M.Routine10State = M.Routine10State + 1;
				M.Routine10Timer = GetTime() + 10;
			else
				M.Routine10State = 19;--to LOC_819
			end
		elseif M.Routine10State == 17 then
			Goto(M.Attacker24, "westcratatkout", 1);
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 30;
		elseif M.Routine10State == 18 then	
			if math.random(1,2) == 1 then
				Patrol(M.Attacker24, "westcratatk1", 1);
			else
				Patrol(M.Attacker24, "westcratatk2", 1);
			end
			M.Routine10State = M.Routine10State + 1;
		elseif M.Routine10State == 19 then	--LOC_819
			if not IsAround(M.Attacker25) then
				M.Attacker25 = TeleportIn("cvtank", 5, "westcratport", 10);
				SetSkill(M.Attacker25, 3);
				Goto(M.Attacker25, "westcratatkin", 1);
				M.Routine10State = M.Routine10State + 1;
				M.Routine10Timer = GetTime() + 10;
			else
				M.Routine10State = 0;--to LOC_751
			end
		elseif M.Routine10State == 20 then
			Goto(M.Attacker25, "westcratatkout", 1);
			M.Routine10State = M.Routine10State + 1;
			M.Routine10Timer = GetTime() + 30;
		elseif M.Routine10State == 21 then	
			if math.random(1,2) == 1 then
				Patrol(M.Attacker25, "westcratatk1", 1);
			else
				Patrol(M.Attacker25, "westcratatk2", 1);
			end
			M.Routine10State = 0;--to LOC_751
		end
	end
end

--code for Schultz's patrol and capture
function Routine11() 
	if M.Routine11Active and M.Routine11Timer < GetTime() then
		if M.Routine11State == 0 then
			local h = GetObjectByTeamSlot(1,2);--player's factory
			M.Position17 = GetPosition(h);
			M.Position17.y = M.Position17.y + 30;
			M.Routine11State = M.Routine11State + 1;
			M.Routine11Timer = GetTime() + 45;
		elseif M.Routine11State == 1 then
			M.Schultz = BuildObject("ivshul1", 1, M.Position17);
			M.SchultzState = 1;
			SetObjectiveName(M.Schultz, "Schultz");
			SetObjectiveOn(M.Schultz);
			SetGroup(M.Schultz, 10);
			Follow(M.Schultz, M.Player, 0);
			AudioMessage("Shulhere.wav");	--Schultz:"Hey Corber, this is Schultz. Windex asked me to babysit you again..."
			RemoveObject(M.NextWaypointNav);
			ClearObjectives();
			AddObjective(_Text10, "white");
			M.NextWaypointNav = BuildObject("ibnav", 1, "MtnPass");
			SetObjectiveName(M.NextWaypointNav, "First Patrol Point");
			SetObjectiveOn(M.NextWaypointNav);
			M.Routine11State = M.Routine11State + 1;
			M.Routine11Timer = GetTime() + 30;
		elseif M.Routine11State == 2 then
			Follow(M.Schultz, M.Player, 0);
			M.Routine11State = M.Routine11State + 1;
		elseif M.Routine11State == 3 then	--LOC_853
			if GetDistance(M.Player, "MtnPass") < 50 then
				M.Attacker05 = BuildObject("cvtank", 5, "patrolp1");
				RemoveObject(M.NextWaypointNav);
				AudioMessage("lock02.wav");
				M.NextWaypointNav = BuildObject("ibnav", 1, "BridWest");
				SetObjectiveName(M.NextWaypointNav, "Second Patrol Point");
				SetObjectiveOn(M.NextWaypointNav);
				Follow(M.Schultz, M.Player, 0);
				M.Routine11State = M.Routine11State + 1;
			end
		elseif M.Routine11State == 4 then	--LOC_863
			if GetDistance(M.Player, "BridWest") < 50 then
				M.Attacker06 = BuildObject("cvhatank", 5, "patrolp2");
				RemoveObject(M.NextWaypointNav);
				AudioMessage("lock02.wav");
				M.NextWaypointNav = BuildObject("ibnav", 1, "patrolp1");
				SetObjectiveName(M.NextWaypointNav, "Third Patrol Point");
				SetObjectiveOn(M.NextWaypointNav);
				Follow(M.Schultz, M.Player, 0);
				M.Routine13Active = true;--RunSpeed,_Routine13,1,true
				M.Routine11State = M.Routine11State + 1;
			end
		elseif M.Routine11State == 5 then	--LOC_876
			if GetDistance(M.Player, "patrolp1") < 50 then
				RemoveObject(M.NextWaypointNav);
				AudioMessage("lock02.wav");
				ClearObjectives();
				M.Routine11State = M.Routine11State + 1;
				M.Routine11Timer = GetTime() + 2;
			end
		elseif M.Routine11State == 6 then
			--SetCockpitTimer(12);--??
			AddObjective(_Text9, "white");
			M.NextWaypointNav = BuildObject("ibnav", 1, "patrolp2");
			SetObjectiveName(M.NextWaypointNav, "Fourth Patrol Point");
			SetObjectiveOn(M.NextWaypointNav);
			M.Attacker08 = BuildObject("cvtalon02", 5, "BridEast");
			Goto(M.Attacker08, "patrolp2", 1);
			M.Routine11State = M.Routine11State + 1;
		elseif M.Routine11State == 7 then	--LOC_890
			if GetDistance(M.Player, "patrolp2") < 100 then
				Attack(M.Attacker08, M.Player, 1);
				RemoveObject(M.NextWaypointNav);
				AudioMessage("lock02.wav");
				M.NextWaypointNav = BuildObject("ibnav", 1, "patrolp3");
				SetObjectiveName(M.NextWaypointNav, "Fifth Patrol Point");
				SetObjectiveOn(M.NextWaypointNav);
				M.Routine9Counter = 0;
				AudioMessage("abetty6.wav");
				AudioMessage("baseattack.wav");
				M.Routine11State = M.Routine11State + 1;
			end
		elseif M.Routine11State == 8 then	--LOC_902
			M.Attacker05 = BuildObject("cvrbomb", 5, "westcratatkout");
			M.Attacker06 = BuildObject("cvhatank", 5, "westcratatkout");
			Patrol(M.Attacker05, "westcratatk2", 1);
			Patrol(M.Attacker06, "westcratatk2", 1);
			M.Attacker01 = BuildObject("cvdcar",5,"islandstart");
			M.Attacker02 = BuildObject("cvtalon02", 5, "islandstart");
			Patrol(M.Attacker01, "islandpath", 1);
			Patrol(M.Attacker02, "islandpath", 1);
			M.Routine9Counter = M.Routine9Counter + 1;
			if M.Routine9Counter < 3 then
				M.Routine11Timer = GetTime() + 1;
			else
				M.Routine9Counter = 0;
				Attack(M.Attacker01, M.Recycler, 1);
				Attack(M.Attacker02, M.Recycler, 1);
				Attack(M.Attacker05, M.Recycler, 1);
				Attack(M.Attacker06, M.Recycler, 1);
				M.PlayerRecalledToBase = M.PlayerRecalledToBase + 1;
				Goto(M.Schultz, "patrolp3", 1);
				M.Routine11State = M.Routine11State + 1;
			end
		elseif M.Routine11State == 9 then	--LOC_919
			ClearObjectives();
			AddObjective(_Text11, "red");
			M.Routine11State = M.Routine11State + 1;
			M.Routine11Timer = GetTime() + 1;
		elseif M.Routine11State == 10 then
			ClearObjectives();
			AddObjective(_Text11, "white");
			M.Routine11State = M.Routine11State + 1;
			M.Routine11Timer = GetTime() + 1;
		elseif M.Routine11State == 11 then
			M.Routine11Counter = M.Routine11Counter + 1;
			if M.Routine11Counter < 3 then
				M.Routine11State = 9;--to LOC_919
			else
				AudioMessage("chatter1.wav");
				ClearObjectives();
				AddObjective(_Text11, "red");
				M.Routine11State = M.Routine11State + 1;
				M.Routine11Timer = GetTime() + 2;
			end
		elseif M.Routine11State == 12 then
			AudioMessage("stat01.wav");
			ClearObjectives();
			AddObjective(_Text12, "red");
			M.Routine11State = M.Routine11State + 1;
			M.Routine11Timer = GetTime() + 1;
		elseif M.Routine11State == 13 then
			AudioMessage("stat01.wav");
			M.Routine11State = M.Routine11State + 1;
		elseif M.Routine11State == 14 then	--LOC_945
			if GetDistance(M.Schultz, M.Player) > 250 then
				SetObjectiveOff(M.Schultz);	--remove objective marker, otherwise Schultz will show up in red on HUD
				SetPerceivedTeam(M.Schultz, 5);
				Goto(M.Schultz, "ambush", 1);
				SetCurHealth(M.Schultz, 12000);
				M.SchultzAmbushed = M.SchultzAmbushed + 1;
				M.Routine11State = M.Routine11State + 1;
			end
		elseif M.Routine11State == 15 then	--LOC_951
			SetCurHealth(M.Schultz, 12000);
			if GetDistance(M.Player, M.Schultz) > 750 then
				M.SchultzState = M.SchultzState + 1;
				M.Routine11State = M.Routine11State + 1;
				M.Routine5Timer = GetTime() + 5;
			end
		elseif M.Routine11State == 16 then
			SetTeamNum(M.Schultz, 5);
			SetPosition(M.Schultz, "ambush");
			M.Routine11State = M.Routine11State + 1;
			M.Routine5Timer = GetTime() + 2;
		elseif M.Routine11State == 17 then
			M.Routine14Active = true;--RunSpeed,_Routine14,1,true
			SetObjectiveOff(M.NextWaypointNav);
			M.Routine11State = M.Routine11State + 1;
		elseif M.Routine11State == 18 then	--LOC_962
			if IsAround(M.Schultz) then
				SetCurHealth(M.Schultz, 12000);
			else
				M.Routine11State = M.Routine11State + 1;
			end
		end
	end
end

--catapults Schultz along with the player when the catapults are used
function Routine12()
	if M.Routine12Active and M.Routine12Timer < GetTime() then
		if M.Routine12State == 0 then	--LOC_966
			if M.SchultzAmbushed > 0 then
				M.Routine12State = 99;
			elseif GetDistance(M.Schultz, M.Player) < 200 then
				if M.PlayerIsUsingCatapult == 1 then
					M.Position11 = M.Position11 + SetVector(35,30,15);
					M.Routine12State = M.Routine12State + 1;
				elseif M.PlayerIsUsingCatapult == 2 then
					M.Position12 = M.Position12 + SetVector(-35,30,-15);
					M.Routine12State = M.Routine12State + 2;
				end
			end
		elseif M.Routine12State == 1 then
			if Move(M.Schultz, 0, M.CatapultMoveSpeed, M.Position11) then
				M.PlayerIsUsingCatapult = 0;
				M.Routine12State = 0;
			end
		elseif M.Routine12State == 2 then
			if Move(M.Schultz, 0, M.CatapultMoveSpeed, M.Position12) then
				M.PlayerIsUsingCatapult = 0;
				M.Routine12State = 0;
			end
		end
	end
end

--handles the east and west catapults
function Routine13()
	if M.Routine13Active and M.Routine13Timer < GetTime() then
		if M.Routine13State == 0 then
			M.Routine12Active = true;--RunSpeed,_Routine12,1,true
			M.Object28 = BuildObject("iostand01", 0, "ecatsite");
			M.CatapultNavE = BuildObject("ibnav", 1, "ecatsite");
			M.Position11 = GetPosition(M.CatapultNavE);
			M.Object29 = BuildObject("iostand01", 0, "wcatsite");
			M.CatapultNavW = BuildObject("ibnav", 1, "wcatsite");
			M.Position12 = GetPosition(M.CatapultNavW);
			SetObjectiveName(M.CatapultNavE, "East Catapult Site");
			SetObjectiveName(M.CatapultNavW, "West Catapult Site");
			SetObjectiveOn(M.CatapultNavE);
			SetObjectiveOn(M.CatapultNavW);
			M.Routine13State = M.Routine13State + 1;			
		elseif M.Routine13State == 1 then	--LOC_993
			M.Position12 = GetPosition(M.CatapultNavW);
			M.Routine13MoveHandle1 = GetNearestVehicle(M.CatapultNavW);
			if GetDistance(M.Routine13MoveHandle1, M.CatapultNavW) < 15 then
				M.Routine13State = M.Routine13State + 1;
				M.Routine13Timer = GetTime() + 5;
			else
				M.Routine13State = 4;--to LOC_1004
			end
		elseif M.Routine13State == 2 then
			if GetDistance(M.Routine13MoveHandle1, M.CatapultNavW) < 15 then
				StartSoundEffect("steam2.wav", M.Routine13MoveHandle2);
				M.PlayerIsUsingCatapult = M.PlayerIsUsingCatapult + 1;
				M.Position11 = M.Position11 + SetVector(35,30,15);
				M.Routine13State = M.Routine13State + 1;
			else
				M.Routine13State = M.Routine13State + 2;--to LOC_1004
			end
		elseif M.Routine13State == 3 then
			if Move(M.Routine13MoveHandle1,0, M.CatapultMoveSpeed, M.Position11) then
				M.Routine13State = M.Routine13State + 1;
			end
		elseif M.Routine13State == 4 then	--LOC_1004
			M.Position11 = GetPosition(M.CatapultNavE);
			M.Routine13MoveHandle2 = GetNearestVehicle(M.CatapultNavE);
			if GetDistance(M.Routine13MoveHandle2, M.CatapultNavE) < 15 then
				M.Routine13State = M.Routine13State + 1;
				M.Routine13Timer = GetTime() + 5;
			else
				M.Routine13State = 1;--to LOC_993
			end
		elseif M.Routine13State == 5 then
			if GetDistance(M.Routine13MoveHandle2, M.CatapultNavE) < 15 then
				StartSoundEffect("steam2.wav", M.Routine13MoveHandle2);
				M.PlayerIsUsingCatapult = M.PlayerIsUsingCatapult + 1;
				M.Position12 = M.Position12 + SetVector(-35,30,-15);
				M.Routine13State = M.Routine13State + 1;
			else
				M.Routine13State = 1;--to LOC_993
			end
		elseif M.Routine13State == 6 then
			if Move(M.Routine13MoveHandle2, 0, M.CatapultMoveSpeed, M.Position12) then
				M.Routine13State = 1;--to LOC_993
			end
		end
	end
end

--handles schultz getting captured, hadean builder, the nuke, and crater breach
function Routine14()
	if M.Routine14Active and M.Routine14Timer < GetTime() then
		if M.Routine14State == 0 then
			local pos = GetPosition(M.Schultz);
			local pos1 = pos + SetVector(30, 0, 0);
			local pos2 = pos + SetVector(-30, 0, 0);
			local pos3 = pos + SetVector(0, 0, 30);
			local pos4 = pos + SetVector(0, 0, -30);
			M.Attacker09 = BuildObject("cvrbomb", 5, pos1);
			M.Attacker10 = BuildObject("cvrbomb", 5, pos2);
			M.Attacker11 = BuildObject("cvtank", 5, pos3);
			M.Attacker12 = BuildObject("cvtank", 5, pos4);
			M.Routine11Active = false;--RunSpeed,_Routine11,0,false
			SetCurHealth(M.Schultz, 200);
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 5;
		elseif M.Routine14State == 1 then
			M.Routine15Active = true;--RunSpeed,_Routine15,1,true
			AllLookAt(5, M.Schultz, 1);
			AudioMessage("kidnap1a.wav");	--Schultz:"Hey Corber, I got a little problem here..."
			Patrol(M.Attacker09, "kidnapath", 1);
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 2;
		elseif M.Routine14State == 2 then
			Patrol(M.Schultz, "kidnapath", 1);
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 4;
		elseif M.Routine14State == 3 then
			Patrol(M.Attacker11, "kidnapath", 1);
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 2;
		elseif M.Routine14State == 4 then
			Patrol(M.Attacker12, "kidnapath", 1);
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 2;
		elseif M.Routine14State == 5 then
			Patrol(M.Attacker10, "kidnapath", 1);
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 30;
		elseif M.Routine14State == 6 then
			--RunSpeed,_Routine23,0,false
			RemoveObject(M.Schultz);
			Goto(M.Attacker11, "portalout", 1);
			Goto(M.Attacker12, "portalout", 1);
			Goto(M.Attacker10, "HadStart", 1);
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 15;
		elseif M.Routine14State == 7 then
			Patrol(M.Attacker11, "conpatrol", 1);
			Patrol(M.Attacker12, "kidnapath", 1);
			Patrol(M.Attacker10, "conpatrol", 1);
			--Attack(M.Attacker05, M.Recycler, 1);
			--Attack(M.Attacker06, M.Recycler, 1);
			M.Routine14Counter = 0;
			M.Routine14State = M.Routine14State + 1;
		elseif M.Routine14State == 8 then	--LOC_1054
			M.Attacker05 = BuildObject("cvrbomb",5,"westcratatkout");
			M.Attacker06 = BuildObject("cvtank", 5, "westcratatkout");
			Patrol(M.Attacker05, "westcratatk2", 1);
			Patrol(M.Attacker06, "westcratatk1", 1);
			M.Attacker01 = BuildObject("cvatank2", 5, "islandstart");
			M.Attacker02 = BuildObject("cvscout", 5, "islandstart");
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 10;
		elseif M.Routine14State == 9 then
			Attack(M.Attacker01, M.Recycler, 1);
			Attack(M.Attacker02, M.Recycler, 1);
			M.Routine14Counter = M.Routine14Counter + 1;
			if M.Routine14Counter < 3 then
				M.Routine14State = M.Routine14State - 1;--to LOC_1054
			else
				M.Routine14State = M.Routine14State + 1;
				M.Routine14Timer = GetTime() + 240;
			end
		elseif M.Routine14State == 10 then
			AudioMessage("chatter6.wav");
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 5;
		elseif M.Routine14State == 11 then
			AudioMessage("chatter7.wav");
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 5;
		elseif M.Routine14State == 12 then
			AudioMessage("RodWimp.wav");	--Windex:"Gentlemen, this frequency is for combat operations only..."
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 40;
		elseif M.Routine14State == 13 then
			--M.HadeanBuilderArrived = 1;
			SetAIP("edf07.aip", 5);
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 110;
		elseif M.Routine14State == 14 then
			SetPerceivedTeam(M.Player, 5);
			M.OldPlayerHealth = GetCurHealth(M.Player);	--made player invincible during cutscene
			M.HadeanBuilder = BuildObject("evcons", 1, "builderstart");
			M.HadeanBuilderArrived = 1;
			SetMaxHealth(M.HadeanBuilder, 4000);
			SetCurHealth(M.HadeanBuilder, 4000);
			SetPerceivedTeam(M.HadeanBuilder, 5);
			Goto(M.HadeanBuilder, "EnterFixer", 1);
			AudioMessage("here2hlp.wav");	--Hadean Builder:"This is automated unit 73412R reporting my reactivation..."
			CameraReady();
			M.Routine14State = M.Routine14State + 1;
		elseif M.Routine14State == 15 then
			SetCurHealth(M.Player, M.OldPlayerHealth);
			if CameraPath("buildercam" ,8000, 800, M.HadeanBuilder) or CameraCancelled() then
				CameraFinish();
				SetObjectiveName(M.HadeanBuilder, "Hadean Builder");
				SetObjectiveOn(M.HadeanBuilder);
				SetPerceivedTeam(M.HadeanBuilder, 1);
				SetPerceivedTeam(M.Player, 1);
				ClearObjectives();
				AddObjective(_Text13, "white");
				Stop(M.HadeanBuilder, 1);
				M.Routine9Counter = 0;
				M.Routine14State = M.Routine14State + 1;
			end
		elseif M.Routine14State == 16 then	--LOC_1096
			local h = GetNearestVehicle(M.HadeanBuilder);
			if GetDistance(h, M.HadeanBuilder) < 80 and GetTeamNum(h) == 1 then 
				Patrol(M.HadeanBuilder, "builderpath", 1);
				M.BridgeRepairNav = BuildObject("ibnav", 1, "BridWest");
				SetObjectiveName(M.BridgeRepairNav, "Repair Point");
				SetObjectiveOn(M.BridgeRepairNav);
				M.Routine14State = M.Routine14State + 1;
				M.Routine14Timer = GetTime() + 5;
			end	
		elseif M.Routine14State == 17 then	--LOC_1106
			M.Attacker01 = BuildObject("cvtank", 5, "MtnPass");
			M.Attacker02 = BuildObject("cvscout", 5, "westcratatkin");
			M.Attacker03 = BuildObject("cvturr02", 5, "MtnPass");
			--M.Attacker04 = BuildObject(" ", 5, "MtnPass");--???
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 10;
		elseif M.Routine14State == 18 then
			Attack(M.Attacker01, M.HadeanBuilder, 1);
			Attack(M.Attacker02, M.HadeanBuilder, 1);
			M.Routine9Counter = M.Routine9Counter + 1;
			if M.Routine9Counter < 2 then
				M.Routine14State = M.Routine14State - 1;--to LOC_1106
			else
				M.Routine14State = M.Routine14State + 1;
			end	
		elseif M.Routine14State == 19 then	--LOC_1116
			if GetDistance(M.HadeanBuilder, "BridWest") < 350 then
				M.Attacker01 = BuildObject("cvtank", 5, "MtnPass");
				M.Attacker02 = BuildObject("cvscout", 5, "westcratatkin");
				Attack(M.Attacker01, M.HadeanBuilder, 1);
				Attack(M.Attacker02, M.HadeanBuilder, 1);
				M.Routine14State = M.Routine14State + 1;
			end
		elseif M.Routine14State == 20 then	--LOC_1122
			if GetDistance(M.HadeanBuilder, "BridWest") < 100 then
				Stop(M.HadeanBuilder, 1);
				LookAt(M.HadeanBuilder, M.Bridge1, 1);
				SetAnimation(M.HadeanBuilder, "cons", 1);
				AudioMessage("evcons05.wav");
				M.Routine14State = M.Routine14State + 1;
				M.Routine14Timer = GetTime() + 1;
			end	
		elseif M.Routine14State == 21 then
			M.Position2.y = M.Position2.y + 32;
			M.RepairBomb = BuildObject("apwrck8", 3, M.Position2);
			M.Position2.y = M.Position2.y - 128;
			M.Routine14State = M.Routine14State + 1;
		elseif M.Routine14State == 22 then
			if Move(M.RepairBomb, M.BombRotRate, M.BombDropSpeed, M.Position2) then
				M.Bridge1 = ReplaceObject(M.Bridge1, "ibbseg1");
				M.Routine14State = M.Routine14State + 1;
				M.Routine14Timer = GetTime() + 3;
			end
		elseif M.Routine14State == 23 then
			M.Position3.y = M.Position3.y + 32;
			M.RepairBomb = BuildObject("apwrck8", 3, M.Position3);
			M.Position3.y = M.Position3.y - 128;
			M.Routine14State = M.Routine14State + 1;
		elseif M.Routine14State == 24 then
			if Move(M.RepairBomb, M.BombRotRate, M.BombDropSpeed, M.Position3) then
				M.Bridge2 = ReplaceObject(M.Bridge2, "ibbseg1");
				M.Routine14State = M.Routine14State + 1;
				M.Routine14Timer = GetTime() + 3;
			end
		elseif M.Routine14State == 25 then
			M.Position4.y = M.Position4.y + 32;
			M.RepairBomb = BuildObject("apwrck8", 3, M.Position4);
			M.Position4.y = M.Position4.y - 128;
			M.Routine14State = M.Routine14State + 1;
		elseif M.Routine14State == 26 then
			if Move(M.RepairBomb, M.BombRotRate, M.BombDropSpeed, M.Position4) then
				M.Bridge3 = ReplaceObject(M.Bridge3, "ibbseg1");
				SetObjectiveOff(M.HadeanBuilder);
				SetObjectiveOff(M.CatapultNavE);
				SetObjectiveOff(M.CatapultNavW);
				Stop(M.HadeanBuilder, 0);
				SetGroup(M.HadeanBuilder, GetFirstEmptyGroup());
				AudioMessage("rodwimp2.wav");	--Windex:"Mr. Corber, I have NOT authorized a rescue mission..."
				M.Routine14State = M.Routine14State + 1;
				M.Routine14Timer = GetTime() + 5;
			end
		elseif M.Routine14State == 27 then
			M.Position1 = GetPosition(M.BridgeRepairNav);
			RemoveObject(M.BridgeRepairNav);
			M.Position1.y = M.Position1.y + 50;
			M.SatchelPickup = BuildObject("APE7bomb", 1, M.Position1);
			SetObjectiveName(M.SatchelPickup, "Nuclear Satchel-Bomb");
			SetObjectiveOn(M.SatchelPickup);
			M.NextWaypointNav = BuildObject("ibnav", 1, "breechnav");
			SetObjectiveName(M.NextWaypointNav, "Bomb Set Point");
			SetObjectiveOn(M.NextWaypointNav);
			ClearObjectives();
			AddObjective(_Text14, "white");
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 5;
		elseif M.Routine14State == 28 then
			AddObjective(_Text15, "white");
			M.Routine14State = M.Routine14State + 1;
		elseif M.Routine14State == 29 then	--LOC_1163
			if not IsAround(M.SatchelPickup) then
				M.Routine14State = M.Routine14State + 1;
			end	
		elseif M.Routine14State == 30 then	--LOC_1166
			--player planted the satchel
			if GetCockpitTimer() == 28 then	
				if GetDistance(M.Player, M.NextWaypointNav) < 100 then
					M.Attacker05 = BuildObject("cvtalon02", 5, "CBAY");
					Attack(M.Attacker05, M.Player, 1);
					M.Attacker06 = BuildObject("cvtalon02", 5, "CBAY");
					Attack(M.Attacker06, M.Player, 1);
					M.Routine14State = M.Routine14State + 1;
				else
					M.Routine14State = 39;--to LOC_1259
				end
			end
		elseif M.Routine14State == 31 then	--LOC_1175
			if GetCockpitTimer() <= 1 then
				M.BreachOpened = M.BreachOpened + 1;
				StartEarthQuake(25);
				M.Routine14State = M.Routine14State + 1;
				M.Routine14Timer = GetTime() + 2;
			end
		elseif M.Routine14State == 32 then
			SetCurHealth(M.Attacker05, 50);
			SetCurHealth(M.Attacker06, 10);
			SetColorFade(4, 0.2, Make_RGBA(0,0,0,255));
			--need to use the matrix version of BuildObject here, since the vector version 
			--will place it at the terrain height rather than the actual position we want!
			M.Breach = BuildObject("breach7z", 0, BuildDirectionalMatrix(M.Position6));
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 1;
		elseif M.Routine14State == 33 then
			if GetMaxHealth(M.Player) < 500 then
				--player was outside their tank when the nuke went off.
				FailMission(GetTime() + 5, "e7nukef.des");
				M.Routine14State = 99;--to LOC_1271
			else
				M.Routine14State = M.Routine14State + 1;
			end
		elseif M.Routine14State == 34 then
			RemoveObject(M.Breach);
			M.Breach = BuildObject("smokeb2", 0, M.Position6);
			M.Routine14State = M.Routine14State + 1;
		elseif M.Routine14State == 35 then
			StopEarthQuake();
			Damage(M.Attacker05, 51);
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 2;
		elseif M.Routine14State == 36 then
			ClearObjectives();
			AddObjective(_Text14, "green");
			M.Routine14State = M.Routine14State + 1;
			M.Routine14Timer = GetTime() + 13;
		elseif M.Routine14State == 37 then
			AddObjective(_Text13, "white");
			RemoveObject(M.Attacker09);
			RemoveObject(M.Attacker10);
			RemoveObject(M.Attacker11);
			RemoveObject(M.Attacker12);
			M.Routine19Active = true;--RunSpeed,_Routine19,1,true
			M.Routine14State = M.Routine14State + 1;
		elseif M.Routine14State == 38 then	--LOC_1203
			--at this point, this routine remains in this state until game is over.
			if not IsAround(M.Attacker09) and GetTime() < M.TalonRespawnTimer then
				M.Attacker09 = BuildObject("cvtalon02", 5, "bendstop");
				Goto(M.Attacker09, M.Player, 1);
				M.TalonRespawnTimer = GetTime() + 150;	--bumped up from 140
			end
			if not IsAround(M.Attacker10) and GetTime() < M.DemonRespawnTimer then
				M.Attacker10 = BuildObject("cvdcar", 5, "bendstop");
				Goto(M.Attacker10, M.Player, 1);
				M.DemonRespawnTimer = GetTime() + 210;	--bumped up from 200
			end
			M.CerbFact = GetObjectByTeamSlot(5,2);
			M.CerbRecy = GetObjectByTeamSlot(5,1);
			if IsAround(M.CerbFact) then 
				if not IsAround(M.Attacker11) and M.KrulRespawnTimer < GetTime() then
					M.Attacker11 = BuildObject("cvtank", 5, "CFACT");
					Defend2(M.Attacker11, M.CerbFact, 1);
					M.KrulRespawnTimer = GetTime() + 50;	--bumped up from 40
				end
				if not IsAround(M.Attacker12) and M.SirenRespawnTimer < GetTime() then
					M.Attacker12 = BuildObject("cvrbomb", 5, "CFACT");
					Defend2(M.Attacker12, M.CerbRecy, 1);
					M.SirenRespawnTimer = GetTime() + 70;	--bumped up from 60
				end
			end
			if TerrainFindFloor(M.Position7) > 75 then
				--if you save and reload the game, the terrain resets, so we need to check for this
				--and build another "breach7z" if necessary.
				M.Breach = BuildObject("breach7z", 0, BuildDirectionalMatrix(M.Position6));
				M.Routine14State = 40;
			end	
		elseif M.Routine14State == 39 then	--LOC_1259
			if GetCockpitTimer() <= 1 then
				if GetMaxHealth(M.Player) < 500 then
					FailMission(GetTime() + 5, "e7nukef.des");
					M.Routine14State = 99;
				else
					M.NukeFailCount = M.NukeFailCount + 1;
					if M.NukeFailCount > 1 then
						FailMission(GetTime() + 5, "e7nonukf.des");
						M.Routine14State = 99;
					else
						ClearObjectives();
						AddObjective(_Text16, "red");
						M.Routine14State = 30;--to LOC_1166
					end
				end
			end
		elseif M.Routine14State == 40 then
			RemoveObject(M.Breach);
			M.Routine14State = 38;
		end
	end
end

--handles the camera during Shultz's capture cutscene
function Routine15()
	if M.Routine15Active and M.Routine15Timer < GetTime() then
		if M.Routine15State == 0 then
			M.OldPlayerHealth = GetCurHealth(M.Player);	--made player invincible during the cutscene
			SetPerceivedTeam(M.Player, 5);
			CameraReady();
			M.Routine15State = M.Routine15State  + 1;
		elseif M.Routine15State == 1 then
			SetCurHealth(M.Player, M.OldPlayerHealth);
			if CameraPath("kidnapcam", 2000, 2500, M.Schultz) then
				CameraFinish();
				AudioMessage("iabomb01.wav");
				SetPerceivedTeam(M.Player, 1);
				M.Routine15State = M.Routine15State  + 1;
			end
		end
	end
end	

--prevents player from driving through tunnel into cerb base
--removes the tunnel once shultz has been captured and hadean builder spawns
function Routine16()
	if M.Routine16Active and M.Routine16Timer < GetTime() then
		if M.Routine16State == 0 then	--LOC_1284
			M.Routine16MoveHandle = GetNearestVehicle("basetunin");
			if M.HadeanBuilderArrived > 0 then
				M.Routine16State = 2;
			elseif GetDistance(M.Routine16MoveHandle, "basetunin") < 50 then
				M.Routine16State = M.Routine16State + 1;
			end
		elseif M.Routine16State == 1 then
			if Move(M.Routine16MoveHandle, 0, M.CatapultMoveSpeed, M.Position28) then
				M.Routine16State = 0;
			end
		elseif M.Routine16State == 2 then
			RemoveObject(GetHandle("base_pbtunn05"));
			RemoveObject(GetHandle("out_pbtunn03"));
			RemoveObject(GetHandle("in_pbtunn03"));
			M.Routine18Active = false;--RunSpeed,_Routine18,0,false
			M.Routine17Active = false;--RunSpeed,_Routine17,0,false
		end	
	end
end

--pulls cerb vehicles through tunnel at west crater portal
function Routine17()
	if M.Routine17Active and M.Routine17Timer < GetTime() then
		if M.Routine17State == 0 then	--LOC_1300
			M.Routine17MoveHandle = GetNearestVehicle("westcratatkin");
			if GetDistance(M.Routine17MoveHandle, "westcratatkin") < 75 
			and GetTeamNum(M.Routine17MoveHandle) ~= 1 
			and not IsOdf(M.Routine17MoveHandle, "cbmtow") then
				M.Routine17State = M.Routine17State + 1;
			end
		elseif M.Routine17State == 1 then
			if Move(M.Routine17MoveHandle, 0, M.CatapultMoveSpeed, M.Position29) then
				M.Routine17State = 0;
			end
		end
	end
end

--handles Cerb portal teleportations
function Routine18()
	if M.Routine18Active then
		local h = GetNearestVehicle("portalin");
		if GetDistance(h, "portalin") < 75 and GetTeamNum(h) ~= 1 then
			Teleport(h, "portalsouth");
		end
		h = GetNearestVehicle("portalin2");
		if GetDistance(h, "portalin2") < 75 and GetTeamNum(h) ~= 1 then
			Teleport(h, "islandstart");
		end
	end
end

--Cerb transport lifting off cutscene
function Routine19()
	if M.Routine19Active and M.Routine19Timer < GetTime() then
		if M.Routine19State == 0 then
			SetPerceivedTeam(M.Player, 5);	--added to prevent Cerbs from attacking player during cutscene
			M.CameraNav = BuildObject("ibnav", 1, "camnav");
			M.Position18 = GetPosition(M.CerbTransport);
			M.Position18.y = M.Position18.y + 500;
			AudioMessage("Shulgone.wav");	--Schultz:"Corber! Eisenstein! Anybody! Please, you've got to do something..."
			CameraReady();
			M.Routine19CamTime = GetTime() + 5;
			M.Routine19State = M.Routine19State + 1;
		elseif M.Routine19State == 1 then
			Move(M.CerbTransport,M.Pod2RotRate,M.Pod2MoveSpeed,M.Position18);
			CameraObject(M.CameraNav, M.Position23, M.CerbTransport);
			if M.Routine19CamTime < GetTime() or CameraCancelled() then
				CameraFinish();
				RemoveObject(M.CerbTransport);
				RemoveObject(M.CameraNav);
				SetPerceivedTeam(M.Player, 1);
				M.Routine19State = M.Routine19State + 1;
			end
		end
	end
end

function CheckStuffIsAlive()
	if not M.MissionOver then
		if M.SchultzState == 1 and not IsAround(M.Schultz) then
			ClearObjectives();
			AudioMessage("abetty8.wav");
			AddObjective(_Text19, "red");
			FailMission(GetTime() + 7, "e7shultz.des");
			M.MissionOver = true;
		elseif not IsAround(M.Recycler) then
			ClearObjectives();
			AddObjective(_Text17, "red");
			AudioMessage("recydead.wav");
			FailMission(GetTime() + 7, "e7recyf.des");
			M.MissionOver = true;
		elseif M.HadeanBuilderArrived > 0 and not IsAround(M.HadeanBuilder) and not IsAround(M.Bridge2) then
			AddObjective(_Text20, "red");
			FailMission(GetTime() + 13, "fixerded.des");
			M.MissionOver = true;
		elseif not IsAround(M.CerbRecy) and not IsAround(M.CerbFact) then
			ClearObjectives();
			AddObjective(_Text18, "green");
			if M.DisobeyedWindex < 1 then
				SucceedMission(GetTime() + 7, "e7win.des");
			else
				SucceedMission(GetTime() + 7, "e7winrod.des");
			end
			M.MissionOver = true;
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

function TeleportIn(odf,  team,  dest, offset)
	local pos = GetPosition(dest);
	pos.x = pos.x + offset;
	pos.y = TerrainFindFloor(pos.x, pos.z) + 5;
	BuildObject("teleportin",  0,  pos);
	return BuildObject(odf,  team,  pos);
end


