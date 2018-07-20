require ("FE13Dev.FEAddon.lua.GlobalHandler");

--Strings
local TRY_TO_CRASH = false;	--some tests may crash BZ2. Set this to true to run them anyways. If this is false, the offending code will be skipped.
local _Instructions = "Select a test to run, or click 'Run All' to run all tests.";

local M = {
-- Bools
	TestFinished = false,
	TestFailed = false,
	TestAborted = false,
	TestSkipped = false,
-- Floats
	MissionTimer = 0.0,
	TestTimer = 0.0,
	CameraEndTime = 0.0,
	Timer1 = 0.0,
	Timer2 = 0.0,
	Variable1 = 0.0,
-- Handles
	Navs = {},
	Object01 = nil,
	Object02 = nil,
	Object03 = nil,
	NewObject = nil,	--the most recent object added to the world
-- Ints
	TPS = 10,
	MissionState = 0,
	TestState = 0,
	Counter1 = 0,
--Vectors
	Position1 = nil,
	Position2 = nil,
	Direction1 = nil,
--Misc
	RunAll = false,
	StartTest = false,
	TestName = nil,
	CurrentTest = nil,
	ErrorMsg = nil,
	endme = 0
}

local Tests = { ... };

function IsNAN(n)
	if n ~= n then
		return true;
	end
	return false;
end

function Save()
    return M
end

function Load(...)
	if select('#', ...) > 0 then
		M = ...
    end
end

function GetHandleOrDie(name)
	return GetHandle(name) or error("Error: object '"..name.."' not found!");
end

function Info(str)
	ClearObjectives();
	AddObjective(str, "white");
end

function InfoErr(str)
	ClearObjectives();
	AddObjective(str, "red");
	PrintConsoleMessage(str);
end

function InfoGood(str)
	ClearObjectives();
	AddObjective(str, "green");
	PrintConsoleMessage(str);
end

function Start()
	M.TPS = EnableHighTPS();
	M.Navs[1] = GetHandleOrDie("nav1");
	M.Navs[2] = GetHandleOrDie("nav2");
	M.Navs[3] = GetHandleOrDie("nav3");
	M.Navs[4] = GetHandleOrDie("nav4");
	M.Navs[5] = GetHandleOrDie("nav5");
	SetTransform(GetPlayerHandle(), BuildDirectionalMatrix(GetPosition(GetPlayerHandle()), Normalize(GetPosition(M.Navs[1]) - GetPosition(GetPlayerHandle())))); 
	WantBotKillMessages();
	SetAutoGroupUnits(true);
	AllowRandomTracks(true);
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function SetupTestTable()
	Tests["MathFuncs"] = Test_MathFuncs;
	Tests["IFace_SetString"] = Test_IFace_SetString;
	Tests["HasPilot"] = Test_HasPilot;
	Tests["CameraOf"] = Test_CameraOf;
	Tests["CameraFinish"] = Test_CameraFinish;
	Tests["Move"] = Test_Move;
	Tests["Move2"] = Test_Move2;
	Tests["Move3"] = Test_Move3;
	Tests["Scrap funcs"] = Test_ScrapFuncs;
	Tests["ReplaceObject"] = Test_ReplaceObject;
	Tests["ReplaceObject2"] = Test_ReplaceObject2;
	Tests["SetColorFade"] = Test_SetColorFade;
	Tests["Jetpack"] = Test_Jetpack;
	Tests["SetCameraPos"] = Test_SetCameraPos;
	Tests["SoundEffects"] = Test_SoundEffects;
	Tests["Audio3D"] = Test_Audio3D;
	Tests["TerrainFuncs"] = Test_TerrainFuncs;
	Tests["Tug"] = Test_Tug;
	Tests["Health & Ammo"] = Test_HealthAmmo;
	Tests["AtTerminal"] = Test_AtTerminal;
	Tests["ShotBy"] = Test_ShotBy;
	Tests["Paths"] = Test_Paths;
	Tests["NearestObject"] = Test_GetNearestObject;
	Tests["SetControls"] = Test_Controls;
	Tests["IsSelected"] = Test_IsSelected;
	Tests["RGB"] = Test_RGB;
	Tests["Deploy"] = Test_Deploy;
	Tests["Build"] = Test_Build;
	Tests["MessagesBox"] = Test_MessagesBox;
	Tests["SetVelocity"] = Test_SetVelocity;
	Tests["Animations"] = Test_Animations;
	Tests["Emitters"] = Test_Emitters;
	Tests["IsFollowing"] = Test_IsFollowing;
	Tests["Lifespan"] = Test_Lifespan;
	Tests["Read ODF"] = Test_ODF;
	Tests["Load File"] = Test_LoadFile;
	Tests["Write File"] = Test_WriteFile;
	Tests["GetMapTRNFilename"] = Test_GetTRNFilename;
	Tests["SetLabel"] = Test_GetSetLabel;
	Tests["SetTap"] = Test_SetTap;
	Tests["Set Pilot Race"] = Test_Race;
	Tests["Earthquake"] = Test_EarthQuake;
	Tests["No Scrap Flag"] = Test_NoScrapFlag;
	Tests["SetGravity"] = Test_Gravity;
	Tests["Identity"] = Test_Identity;
	Tests["CountThreats"] = Test_CountThreats;
	Tests["LocalAmmo"] = Test_LocalAmmo;
	Tests["SetOwner"] = Test_SetOwner;
	Tests["ServerInfo"] = Test_ServerInfo;
	Tests["Score"] = Test_Score;
	Tests["Ally"] = Test_Ally;
	Tests["Scavenger"] = Test_Scavenger;
	Tests["InstantInfo"] = Test_InstantInfo;
	Tests["TPS"] = Test_TPS;
	Tests["SetAsUser"] = Test_SetAsUser;
	Tests["GetOdf"] = Test_GetOdf;
	Tests["WeaponConfig"] = Test_WeaponConfig;
	Tests["CanSnipe"] = Test_CanSnipe;
	Tests["GetRecyclerHandle"] = Test_GetRecyclerHandle;
	Tests["GetPositionNear"] = Test_GetPositionNear;
	Tests["ScrapCost"] = Test_ScrapCost;
	Tests["Groups"] = Test_Groups;
	Tests["IsInsideArea"] = Test_IsInsideArea;
	Tests["TeamColors"] = Test_TeamColors;
	Tests["Spawnpoint"] = Test_Spawnpoint;
	Tests["CountUnitsNearObject"] = Test_CountUnitsNearObject;
	Tests["SetTimerBox"] = Test_SetTimerBox;
	Tests["SetCommand"] = Test_SetCommand;
	Tests["GetOmega"] = Test_GetOmega;
	Tests["SetAvoidType"] = Test_SetAvoidType;
	Tests["PerceivedTeam"] = Test_PerceivedTeam;
	Tests["ObjectiveName"] = Test_ObjectiveName;
	Tests["GetAllGameObjectHandles"] = Test_GetAllGameObjectHandles;
	Tests["MakeInert"] = Test_MakeInert;
	Tests["Service"] = Test_Service;
	Tests["IFace_ConsoleCommand"] = Test_IFaceConsoleCommand;
	Tests["FlagFuncs"] = Test_FlagFuncs;
	Tests["CategoryType"] = Test_GetCategoryType;
	Tests["MoneyScore"] = Test_MoneyScore;
	Tests["SetAngle"] = Test_SetAngle;
	Tests["SetVarItems"] = Test_SetVarItems;
	Tests["KickPlayer"] = Test_KickPlayer;
	Tests["NoteGameover"] = Test_NoteGameover;
	Tests["GetGroup2"] = Test_GetGroup2;
	Tests["SetMPTeamRace"] = Test_SetMPTeamRace;
	Tests["ResetTeamSlot"] = Test_ResetTeamSlot;
	Tests["SetSkill"] = Test_SetSkill;
	Tests["SetIndependence"] = Test_SetIndependence;
	Tests["SetAIP"] = Test_SetAIP;
	Tests["GetCurrentWho"] = Test_GetCurrentWho;
	Tests["CanCommand"] = Test_CanCommand;
	Tests["MPTeamplay"] = Test_MPTeamplay;
	
	--Tests["Hang BZ2"] = Test_HangBZ2;
end

function PassTest()
	M.TestFinished = true;
	M.TestFailed = false;
	M.TestAborted = false;
end

function FailTest(msg)
	M.TestFinished = true;
	M.TestFailed = true;
	M.TestAborted = false;
	M.ErrorMsg = msg;
end

function AddObject(h)
	M.NewObject = h;
end

function DeleteObject(h)

end

function ProcessCommand(crc)
	if crc == CalcCRC("tests.run") then
		if not M.TestFinished then
			PrintConsoleMessage("Test is in progress. Type 'tests.abort' to stop the test.");
		else
			M.TestName = IFace_GetSelectedItem("TestRunner.TestList.List", "", 100 );
			M.CurrentTest = Tests[M.TestName];
			if M.CurrentTest ~= nil then
				M.RunAll = false;
				M.StartTest = true;
			else
				PrintConsoleMessage("Test '"..M.TestName.."' not found.");
			end
		end
	elseif crc == CalcCRC("tests.runall") then
		if not M.TestFinished then
			PrintConsoleMessage("Test is in progress. Type 'tests.abort' to stop the test.");
		else
			M.RunAll = true;
			M.StartTest = true;
		end
	elseif crc == CalcCRC("tests.abort") then
		M.TestFinished = true;
		M.TestAborted = true;
	elseif crc == CalcCRC("tests.close") then
		FreeFinish();
		IFace_Deactivate("TestRunner");
		M.MissionState = 99;
	elseif crc == CalcCRC("tests.skip") then
		M.TestFinished = true;
		M.TestSkipped = true;
	elseif crc == CalcCRC("tests.listglobalvars") then
		--lists the global constants available to lua (like AiCommand)
		for k,v in pairs(_G) do
			if type(v) ~= "function" then
				print(tostring(k));
			end
		end
	end
end

--function AddPlayer(id)	--not called in SP
--	print("AddPlayer("..tostring(id)..")");
--end

--function DeletePlayer(id)	--not called in SP
--	print("DeletePlayer("..tostring(id)..")");
--end

function PlayerEjected(deadObjectHandle)
	--note: the starting "player" tank has eject using CTRL-B disabled. Try using an ivtank instead.
	--print("PlayerEjected("..tostring(deadObjectHandle)..")");
end

function ObjectKilled(deadObjectHandle, killerHandle)	--not called by default. To enable, call WantBotKillMessages()
	--print("ObjectKilled("..tostring(deadObjectHandle)..", "..tostring(killerHandle)..")");
	return 0;
end

function ObjectSniped(deadObjectHandle, killerHandle) --not called by default. To enable, call WantBotKillMessages()
	--print("ObjectSniped("..tostring(deadObjectHandle)..", "..tostring(killerHandle)..")");
end

function PreOrdinanceHit(shooterHandle, victimHandle, ordinanceTeam, ordinanceOdf)	--not called in SP
	print("PreOrdinanceHit "..tostring(shooterHandle)..", "
	..tostring(victimHandle)..", "
	..tostring(ordinanceTeam)..", "
	..tostring(ordinanceOdf));
end

--PreSnipeReturnCodes:
--PRESNIPE_KILLPILOT=0	--(default) Allows the sniper round to kill the pilot.
--PRESNIPE_ONLYBULLETHIT=1	--Prevents the pilot from being killed. The bullet still counts as a normal hit on the target craft.
function PreSnipe(curWorld,shooterHandle,victimHandle,ordnanceTeam,pOrdnanceODF)
	print("PreSnipe "..tostring(curWorld)..", "
	..tostring(shooterHandle)..", "
	..tostring(victimHandle)..", "
	..tostring(ordnanceTeam)..", "
	..tostring(pOrdnanceODF));
end

--PreGetInReturnCodes:
--PREGETIN_DENY=0 --Prevents the pilot from entering the craft.
--PREGETIN_ALLOW=1 -- (default)Allows the pilot to enter the craft.
function PreGetIn(world, pilot, craft)
	print("PreGetIn "..tostring(world)..", "..tostring(pilot)..", "..tostring(craft));
end

--PrePickupPowerupReturnCodes:
--PREPICKUPPOWERUP_DENY=0	--Prevents the powerup from being picked up.
--PREPICKUPPOWERUP_ALLOW=1	--(default)Allows the powerup to be picked up.
--Note: Still gets called even if the powerup is not eligible to be picked up 
--(Ex: apserv if craft has full health, or apchain if craft already has chain)
function PrePickupPowerup(world, me, powerup)
	print("PrePickupPowerup "..tostring(world)..", "..tostring(me)..", "..tostring(powerup));
end

--function PostTargetChangedCallback(craft, prevTarget, newTarget)	--not called in SP?
--	print("PostTargetChangedCallback "..tostring(craft)..", "..tostring(prevTarget)..", "..tostring(newTarget));
--end

function Update()
	if table.getn(Tests) == 0 then
		SetupTestTable();
	end
	if M.MissionTimer < GetTime() then
		if M.MissionState == 0 then
			Info(_Instructions);
			IFace_CreateCommand("tests.run");
			IFace_CreateCommand("tests.runall");
			IFace_CreateCommand("tests.abort");
			IFace_CreateCommand("tests.close");
			IFace_CreateCommand("tests.skip");
			IFace_CreateCommand("tests.listglobalvars");
			IFace_CreateString("tests.testlist", "");		
			
			IFace_Exec("lua_api_test.cfg");
			for k,v in pairs(Tests) do
				IFace_AddTextItem("TestRunner.TestList.List", k);
			end
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 1 then
			FreeCamera();
			IFace_Activate("TestRunner");	--select test dialog
			M.TestFinished = true;
			M.MissionState = M.MissionState + 1;
		elseif M.MissionState == 2 then
			if M.StartTest then
				M.StartTest = false;
				IFace_Deactivate("TestRunner");
				FreeFinish();
				if M.RunAll == false then
					M.MissionState = M.MissionState + 1;
				else
					M.TestName = nil;
					M.MissionState = 5;
				end
			end
		elseif M.MissionState == 3 then	--run single test
			if M.CurrentTest ~= nil then
				Info("Starting test "..M.TestName);
				M.TestFinished = false;
				M.TestFailed = false;
				M.TestAborted = false;
				M.TestSkipped = false;
				M.TestState = 0;
				M.TestTimer = 0.0;
				M.MissionState = M.MissionState + 1;
				M.MissionTimer = GetTime() + 1;
			else
				PrintConsoleMessage("Test '"..M.TestName.."' not found.");
				M.MissionState = 1;
			end
		elseif M.MissionState == 4 then
			M.CurrentTest();
			if M.TestFinished then
				if M.TestAborted then
					InfoErr("Test '"..M.TestName .. "' aborted.", "red");
				elseif M.TestSkipped then
					InfoErr("Test '"..M.TestName .. "' skipped.", "red");
				elseif not M.TestFailed then
					InfoGood("Test '"..M.TestName .. "' passed.");
				else
					InfoErr("Test '"..M.TestName .. "' failed. '" ..tostring(M.ErrorMsg) .. "'.", "red");
				end
				M.MissionState = 1;
			end
		elseif M.MissionState == 5 then	--run all tests
			M.TestName,M.CurrentTest = next(Tests, M.TestName);
			if M.TestName ~= nil then 
				Info("Starting test "..M.TestName);
				M.TestFinished = false;
				M.TestFailed = false;
				M.TestAborted = false;
				M.TestSkipped = false;
				M.TestState = 0;
				M.TestTimer = 0.0;
				M.MissionState = M.MissionState + 1;
				M.MissionTimer = GetTime() + 2;
			else
				Info("Done.");
				PrintConsoleMessage("Tests finished.");
				M.MissionState = 1;
			end		
		elseif M.MissionState == 6 then
			M.CurrentTest();
			if M.TestFinished then
				if M.TestAborted then
					InfoErr("Test all aborted.", "red");
					M.MissionState = 1;
				elseif M.TestSkipped then
					InfoErr("Test '"..M.TestName.."' skipped.", "red");
					M.MissionState = M.MissionState - 1;
				elseif not M.TestFailed then
					InfoGood("Test '"..M.TestName .. "' passed.");
					M.MissionState = M.MissionState - 1;
				else
					InfoErr("Test '"..M.TestName .. "' failed. '" ..M.ErrorMsg .. "'.", "red");
					M.MissionState = M.MissionState - 1;
				end
				M.MissionTimer = GetTime() + 1;
			end
		end
	end
end

--Tests Vector and Matrix helper funcs
function Test_MathFuncs()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if SetVector == nil then
				FailTest("SetVector is nil!");
			elseif DotProduct == nil then
				FailTest("DotProduct is nil!");
			elseif CrossProduct == nil then
				FailTest("CrossProduct is nil!");
			elseif Normalize == nil then
				FailTest("Normalize is nil!");
			elseif Length == nil then
				FailTest("Length is nil!");
			elseif LengthSquared  == nil then
				FailTest("LengthSquared  is nil!");
			elseif Distance2D == nil then
				FailTest("Distance2D is nil!");
			elseif Distance2DSquared == nil then
				FailTest("Distance2DSquared is nil!");
			elseif Distance3D == nil then
				FailTest("Distance3D is nil!");
			elseif Distance3DSquared == nil then
				FailTest("Distance3DSquared is nil!");
			elseif IdentityMatrix == nil then
				FailTest("IdentityMatrix is nil!");
			elseif BuildAxisRotationMatrix == nil then
				FailTest("BuildAxisRotationMatrix is nil!");
			elseif BuildPositionRotationMatrix == nil then
				FailTest("BuildPositionRotationMatrix is nil!");
			elseif BuildOrthogonalMatrix  == nil then
				FailTest("BuildOrthogonalMatrix is nil!");
			elseif BuildDirectionalMatrix  == nil then
				FailTest("BuildDirectionalMatrix is nil!");
			else
				Info("Testing vector functions...");
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then	--test normal use cases for vector stuff
			local v = SetVector(0,0,0);
			local v2 = SetVector(2,0,0);
			local v3 = SetVector(0,2,0);
			local v4 = Normalize(v2);
			local v5 = Normalize(v3);
			local v6 = CrossProduct(v4,v5);
			local v7 = SetVector(0,0,1);
			local v8 = v2 * 2;
			local v9 = v2 / 2;
			local v10 = v2 + v3;
			local v11 = v2 - v3;
			if math.abs(Length(v)) > 0.001 then
				FailTest("Length() returned non-zero for zero vector.");
				M.TestState = M.TestState + 1;
			elseif math.abs(Length(v2) - 2.0) > 0.001 then
				FailTest("Length() returned wrong value for."..tostring(v2));
			elseif math.abs(Length(v4) - 1.0) > 0.001 then
				FailTest("Normalize("..tostring(v2)..") returned "..tostring(v4).." (length is wrong).");
			elseif math.abs(LengthSquared(v2) - 4.0) > 0.001 then
				FailTest("LengthSquared() returned wrong value for."..tostring(v2));
			elseif math.abs(DotProduct(v2,v2) - 4.0) > 0.001 then
				FailTest("DotProduct(v2,v2) was "..tostring(DotProduct(v2,v2)).." but expected 4.");
			elseif math.abs(DotProduct(v2,v3)) > 0.001 then
				FailTest("DotProduct(v2,v3) was not 0.");
			elseif math.abs(Length(CrossProduct(v4,v5)) - 1.0) > 0.001 then
				FailTest("CrossProduct(v4,v5) has wrong magnitude.");
			elseif math.abs(CrossProduct(v4,v5).z) - 1.0 > 0.001 then
				FailTest("CrossProduct(v4,v5).z should be 1.0, but got "..tostring(CrossProduct(v4,v5).z)..".");
			elseif math.abs(Distance2D(v4,v5) - 1.0) > 0.001 then
				FailTest("Distance2D(v4,v5): expected 1.0, but got "..tostring(Distance2D(v4,v5))..".");
			elseif math.abs(Distance3D(v4,v5) - math.sqrt(2)) > 0.001 then
				FailTest("Distance2D(v4,v5): expected ".. math.sqrt(2)..", but got "..tostring(Distance3D(v4,v5))..".");
			elseif math.abs(Distance2DSquared(v4,v5) - 1.0) > 0.001 then
				FailTest("Distance2DSquared(v4,v5): expected 1.0, but got "..tostring(Distance2DSquared(v4,v5))..".");
			elseif math.abs(Distance3DSquared(v4,v5) - 2) > 0.001 then
				FailTest("Distance3DSquared(v4,v5): expected 2.0, but got "..tostring(Distance3DSquared(v4,v5))..".");
			elseif v8 ~= SetVector(4,0,0) then
				FailTest("v2*2 was not (4,0,0)");
			elseif v9 ~= SetVector(1,0,0) then
				FailTest("v2/2 was not (1,0,0)");
			elseif v10 ~= SetVector(2,2,0) then
				FailTest("v2+v3 was not (2,2,0)");
			elseif v11 ~= SetVector(2,-2,0) then
				FailTest("v2-v3 was not (2,-2,0)");
			else
				Info("Testing abnormal vector func cases");
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 1;
			end
		elseif M.TestState == 2 then	--test abnormal uses of vector funcs
			local v1 = SetVector(0,0,0);
			local v2 = SetVector(0,0,0);
			local v3 = Normalize(v1);	--normalizing the zero vector gives undefined results 
			local v4 = CrossProduct(v1,v2);	
			if not IsNAN(v3.x) then
				FailTest("Normalize(zerovec): expected indeterminate, but got "..tostring(v3));
			elseif math.abs(Length(v4)) > 0.001 then
				FailTest("Cross(zerovec,zerovec): expected zerovec, but got "..tostring(v4));
			else
				Info("Testing matrix funcs...");
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 1;
			end
		elseif M.TestState == 3 then	--try calling the matrix funcs
			local upAxis = SetVector(0,1,0);
			local xAxis = SetVector(1,0,0);
			local v1 = SetVector(1,1,1);
			--Probably need to do more testing later. For now, we are satisfied if they exist and
			--can be called without crashing :D
			BuildAxisRotationMatrix(45, 1,1,1);
			BuildAxisRotationMatrix(45, upAxis);
			BuildPositionRotationMatrix(1,2,3,1,2,3);
			BuildPositionRotationMatrix(1,2,3,v1);
			BuildOrthogonalMatrix(upAxis,xAxis);
			local m = BuildDirectionalMatrix(v1, xAxis);
			local m2 = m * IndentityMatrix;
			local v2 = m * v1;
			M.TestState = M.TestState + 1;
		elseif M.TestState == 4 then
			PassTest();
		end
	end
end

--tests the Move() function
--1. Spawns a dropship at nav1 and moves it to nav2 at 15 m/s
--2. Moves the dropship to nav3 at 10m/s with rotation of 40 deg/s
--3. Rotates the dropship in place at nav3 at 70 deg/s
function Test_Move()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then	--test the 1st version of Move() that moves and rotates
			if Move == nil then
				FailTest("Error: Move() is not defined!");
				M.TestState = 99;
			else
				M.Object01 = BuildObject("ivdrop_fly", 1, M.Navs[1]);
				Info("Moving to nav2 at 15m/s with no rotation.");
				M.Position1 = GetPosition(M.Navs[1]);
				M.Position2 = GetPosition(M.Navs[2]);
				M.Timer1 = GetTime();
				M.Timer2 = GetTime() + Distance2D(M.Position2, M.Position1) + 0.2;
				M.Direction1 = GetFront(M.Object1);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then
			if M.Timer2 < GetTime() then
				RemoveObject(M.Object01);
				FailTest("Move() took too long to get to dest!");
				M.TestState = 99;
			elseif Move(M.Object01, 0.0, 15, M.Position2) then
				local dist = Distance2D(M.Position2, M.Position1);
				local t = GetTime() - M.Timer1;
				local expectedT = dist / 15;
				if GetDistance(M.Object01, M.Position2) > 10 then
					RemoveObject(M.Object01);
					FailTest("Move() returned true but object is not at dest ("..tostring(GetDistance(M.Object01, M.Position2)).."m away)!");
					M.TestState = 99;
				elseif math.abs(t-expectedT) > 1.0 then
					RemoveObject(M.Object01);
					FailTest("Move() speed was wrong. Expected to take "..expectedT.."s but took "..t.."s.");
					M.TestState = 99;
				else
					Info("Moved ".. tostring(dist) .."m in " .. tostring(t) .." seconds.");
					M.TestState = M.TestState + 1;
					M.TestTimer = GetTime() + 1;
				end
			end
		elseif M.TestState == 2 then
			M.Position1 = GetPosition(M.Navs[2]);
			M.Position2 = GetPosition(M.Navs[3]);
			M.Timer1 = GetTime();
			M.Timer2 = GetTime() + Distance2D(M.Position2, M.Position1) + 10;
			M.Direction1 = GetFront(M.Object1);
			Info("Moving to nav 3 at 10m/s with rotation of 40deg/s.");
			M.TestState = M.TestState + 1;
		elseif M.TestState == 3 then
			if M.Timer2 < GetTime() then
				FailTest("Move() took too long to get to dest!");
				M.TestState = 99;
			elseif Move(M.Object01, 40, 10, M.Position2) then
				local dist = Distance2D(M.Position2, M.Position1);
				local t = GetTime() - M.Timer1;
				local expectedT = dist / 10;
				if GetDistance(M.Object01, M.Position2) > 10 then
					RemoveObject(M.Object01);
					FailTest("Move() returned true but object is not at dest("..tostring(GetDistance(M.Object01, M.Position2)).."m away)!");
					M.TestState = 99;
				elseif math.abs(t-expectedT) > 1.0 then
					RemoveObject(M.Object01);
					FailTest("Move() speed was wrong. Expected to take "..expectedT.."s but took "..t.."s.");
					M.TestState = 99;
				else
					Info("Moved ".. tostring(dist) .."m in " .. tostring(t) .." seconds.");
					M.TestState = M.TestState + 1;
					M.TestTimer = GetTime() + 1;
				end
			end
		elseif M.TestState == 4 then	--testing the 2nd version of Move() that rotates in place
			Info("Testing spinning in place at 70deg/sec.");
			M.Timer1 = GetTime() + 5;
			M.TestState = M.TestState + 1;
		elseif M.TestState == 5 then
			if Move(M.Object01, 70, M.Timer1) then
				M.Position1 = GetPosition(M.Navs[3]);
				M.Position1.y = M.Position1.y + 100;
				M.Object1YPos = GetPosition(M.Object1).y;
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 1;
			end
		elseif M.TestState == 6 then
			Info("Testing moving vertically.");
			M.TestState = M.TestState + 1;
		elseif M.TestState == 7 then
			--test moving straight up
			if Move(M.Object01, 0, 40, M.Position1) then
				local y = GetPosition(M.Object1).y;
				local expectedY = M.Object1YPos + 100;
				if y - expectedY > 0.1 then
					FailTest(string.format("Moving vertically failed. Ending y was %f but expected %f.", y, expectedY));
				end
				Info("Testing with dest position same as origin");
				M.Timer1 = GetTime() + 5;
				SetPosition(M.Object01, GetPosition(M.Navs[3]));
				M.Position1 = GetPosition(M.Object01);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 1;
			end
		elseif M.TestState == 8 then
			--Test with dest same as origin
			Move(M.Object01, 0.0, 40.0, M.Position1);
			if M.Timer1 < GetTime() then
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 9 then
			RemoveObject(M.Object01);
			PassTest();
			M.TestState = M.TestState + 1;
		end
	end
end

function Test_Move2()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Position1 = GetPosition(M.Navs[1]);
			M.Position2 = GetPosition(M.Navs[2]) + SetVector(200, 0, 0);
			M.Object01 = BuildObject("ivdrop_fly", 0, BuildDirectionalMatrix(M.Position1, Normalize(M.Position2 - M.Position1)));
			M.Object02 = BuildObject("dropflame", 0, BuildDirectionalMatrix(M.Position1, SetVector(1,0,0)));
			--print(GetTransform(M.Object01).posit - GetPosition(M.Object01));	
			M.Timer1 = GetTime();
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			local m = GetTransform(M.Object01);
			local v = SetVector(20, 37, -15);
			SetPosition(M.Object02, m*v);
			
			if M.Timer1 < GetTime() then
				local r = math.random(1,10);
				if r < 5 then
					MaskEmitter(M.Object01, 2);
					M.Timer1 = GetTime() + 0.4;
				else
					MaskEmitter(M.Object01, 3);
					M.Timer1 = GetTime() + 0.1;
				end
			end
			if Move(M.Object01, 00.0, 20.0, M.Position2) then
				RemoveObject(M.Object01);
				RemoveObject(M.Object02);
				PassTest();
			end
		end
	end
end

function Test_Move3()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ivdrop_fly", 0, M.Navs[1]);
			M.Position1 =  GetPosition(M.Navs[1]) + SetVector(0,-20,0);
			M.Position2 =  GetPosition(M.Navs[2]) + SetVector(0,-20,0);
			CameraReady();
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			if Move(M.Object01, 0, 30, M.Position2) or CameraPath("nav_path", 5000, 2000, M.Object01) or CameraCancelled() then
				CameraFinish();
				M.TestState = M.TestState + 1;
			end
			--SetPosition(M.Object01, pos2);
		elseif M.TestState == 2 then
			
		end
	end
end

--Test_IFace_SetString()
--tests the max length allowed for IFace_SetString() and IFace_GetString()
--Tests IFace_CreateString(), IFace_SetString(), IFace_GetString()
--Warning: trying to get a string longer than 2047 chars crashes BZ2!
function Test_IFace_SetString()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Counter1 = 1;
			IFace_CreateString("test1234", "");
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			local str = string.rep("a", M.Counter1);
			IFace_SetString("test1234", str);
			if IFace_GetString("test1234", M.Counter1 + 1) ~= str then	--Getting a string longer than 2047 chars crashes BZ2!
				FailTest("IFace_GetString(): Strings do not match! (Length="..tostring(M.Counter1));
				M.TestState = M.TestState + 1;
			else
				Info("Length "..tostring(M.Counter1).." OK");
				M.Counter1 = M.Counter1 * 2;
				if M.Counter1 > 2047 and not TRY_TO_CRASH then
					M.TestState = M.TestState + 1;
				end
				M.TestTimer = GetTime() + 0.3;
			end
		elseif M.TestState == 2 then
			PassTest();
			M.TestState = M.TestState + 1;
		end
	end
end

--spawns various objects and tests if they have pilots
--Tests HasPilot(), KillPilot(), RemovePilot(), IsAround(), IsValid(), IsAlive(), IsAliveAndPilot(), HopOut(), GetIn(), IsNotDeadAndPilot2()
--Does not test HoppedOutOf() here, since it only works for the player
--Note: there are some weird cases where these funcs don't return what you would expect!
--Ex: ivrecy is alive, but doesn't have a pilot.
--Ex: apserv is alive and does have a pilot
--Note: HoppedOutOf() only works for the player. If used on AI pilots it always returns nil.
--Note: IsNotDeadAndPilot2() seems to return true for a ship without a pilot! Unintuitive!
function Test_HasPilot()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if HasPilot == nil then
				FailTest("Error: HasPilot is not defined!");
			else 
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			if not IsAround(M.Object01) then
				FailTest("Failed to create ivtank!");
			elseif not IsValid(M.Object01) then
				FailTest("IsValid() returned false for ivtank!");
			elseif not HasPilot(M.Object01) then	
				FailTest("HasPilot() returned false for ivtank with pilot!");
			elseif not IsAliveAndPilot(M.Object01) then	
				FailTest("IsAliveAndPilot() returned false for ivtank with pilot!");
			elseif not IsNotDeadAndPilot2(M.Object01) then	
				FailTest("IsNotDeadAndPilot2() returned false for ivtank with pilot!");
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 2 then
			KillPilot(M.Object01);
			if HasPilot(M.Object01) then
				FailTest("HasPilot() returned true after killing pilot!");
			elseif IsAliveAndPilot(M.Object01) then
				FailTest("IsAliveAndPilot() returned true after killing pilot!");
			--elseif not IsNotDeadAndPilot2(M.Object01) then	
			--	FailTest("IsNotDeadAndPilot2() returned true after killing pilot!");
			elseif IsAlive(M.Object01) then
				FailTest("IsAlive() returned true after killing pilot!");
			elseif not IsAround(M.Object01) then
				FailTest("IsAround() returned false after killing pilot!");
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 3 then
			RemoveObject(M.Object01);
			if IsValid(M.Object01) then
				FailTest("IsValid() returned true for deleted object.");
			end
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			RemovePilot(M.Object01);
			if IsAlive(M.Object01) then
				FailTest("IsAlive() returned true after RemovePilot().");
			elseif not IsAround(M.Object01) then
				FailTest("IsAround() returned false after RemovePilot().");
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 4 then	--Test HopOut()
			RemoveObject(M.Object01);	
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 5 then
			M.NewObject = nil;
			HopOut(M.Object01);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 6 then
			if M.NewObject ~= nil and IsOdf(M.NewObject, "ispilo") then
				if HasPilot(M.Object01) then
					FailTest("HasPilot() is true after HopOut()!");
				end
				M.Object02 = M.NewObject;
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 7 then
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			PassTest();
		end
	end
end

--Test_CameraOf()
--1. camera of ivtank #1 looking at tank#2, then tank #3 with an offset of (10,0,-25)
--2. camera of ivtank #3 looking at tank#1, then tank #2 with an offset of (0,0,0)
--3. still using ivtank #3, zoom in from z=-30 to z=+30 and back to z=-30 with x,y=0
--4. change y from 0 to +30 and back with z offset of -10
--5. change x from 0 to +30 and down to -30 with z offset of -10
function Test_CameraOf()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if CameraOf == nil then
				FailTest("Error: CameraOf() is not defined!");
				M.TestState = 99;
			else
				M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
				M.Object02 = BuildObject("ivtank", 1, M.Navs[3]);
				M.Object03 = BuildObject("ivtank", 1, M.Navs[5]);
				CameraReady();
				Info("Testing CameraOf(ivtank #1) with offset of (10,0,-25)");
				M.TestState = M.TestState + 1;
				M.CameraEndTime = GetTime() + 3;
			end
		elseif M.TestState == 1 then
			CameraOf(M.Object01, SetVector(10,0,-25));
			if M.CameraEndTime < GetTime() then 
				LookAt(M.Object01, M.Object02);
				Info("ivtank #1 LookAt tank#2");
				M.TestState = M.TestState + 1;
				M.CameraEndTime = GetTime() + 3;
			end
		elseif M.TestState == 2 then
			CameraOf(M.Object01, SetVector(10,0,-25));
			if M.CameraEndTime < GetTime() then 
				LookAt(M.Object01, M.Object03);
				Info("ivtank #1 LookAt tank#3");
				M.TestState = M.TestState + 1;
				M.CameraEndTime = GetTime() + 3;
			end
		elseif M.TestState == 3 then
			CameraOf(M.Object01, SetVector(10,0,-25));
			if M.CameraEndTime < GetTime() then 
				CameraFinish();
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 4 then
			LookAt(M.Object03, M.Object01);
			Info("CameraOf(tank#3) looking at tank#1 with offset (0,0,0)");
			CameraReady();
			M.CameraEndTime = GetTime() + 3;
			M.TestState = M.TestState + 1;
		elseif M.TestState == 5 then
			CameraOf(M.Object03, SetVector(0,0,0));
			if M.CameraEndTime < GetTime() then 
				LookAt(M.Object03, M.Object02);
				Info("ivtank #3 LookAt tank#2");
				M.CameraEndTime = GetTime() + 5;
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 6 then
			CameraOf(M.Object03, SetVector(0,0,0));
			if M.CameraEndTime < GetTime() then 
				Info("zooming in from z=-30 to z=+30");
				M.CameraEndTime = GetTime() + 5;
				M.Counter1 = -30;
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 7 then	--zoom in/out
			M.Counter1 = M.Counter1 + 2;
			CameraOf(M.Object03, SetVector(0,0,M.Counter1));
			if M.Counter1 >= 30 then
				Info("zooming out from z=+30 to z=-30");
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 8 then
			M.Counter1 = M.Counter1 - 2;
			CameraOf(M.Object03, SetVector(0,0,M.Counter1));
			if M.Counter1 <= -30 then
				Info("increasing y from 0 to +30 with z=-10");
				M.Counter1 = 0;
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 9 then	--go up/down
			M.Counter1 = M.Counter1 + 2;
			CameraOf(M.Object03, SetVector(0,M.Counter1,-10));
			if M.Counter1 >= 30 then
				Info("decreasing y from +30 to 0 with z=-10");
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 10 then
			M.Counter1 = M.Counter1 - 2;
			CameraOf(M.Object03, SetVector(0,M.Counter1,-10));
			if M.Counter1 <= 0 then
				Info("increasing x from 0 to +30 with z=-10");
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 11 then	--go left/right
			M.Counter1 = M.Counter1 + 2;
			CameraOf(M.Object03, SetVector(M.Counter1,0,-10));
			if M.Counter1 >= 30 then
				Info("decreasing x from +30 to -30 with z=-10");
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 12 then
			M.Counter1 = M.Counter1 - 2;
			CameraOf(M.Object03, SetVector(M.Counter1,0,-10));
			if M.Counter1 <= -30 then
				CameraFinish();
				RemoveObject(M.Object01);
				RemoveObject(M.Object02);
				RemoveObject(M.Object03);
				PassTest();
				M.TestState = M.TestState + 1;
			end
		end
	end
end

function Test_CameraFinish()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			CameraReady();
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 0.1;	--without this delay the camera will hang!
		elseif M.TestState == 1 then
			CameraFinish();
			PassTest();
			M.TestState = M.TestState + 1;
		end
	end
end

--Tests the scrap management functions: GetScrap(), SetScrap(), SetMaxScrap(), GetMaxScrap(), AddScrap()
function Test_ScrapFuncs()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			Info("Spawning in recy");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 1 then	--see if spawning in a recy increases the max scrap by 40
			local maxScrap = GetMaxScrap(1);
			M.Object01 = BuildObject("ivrecy", 1, M.Navs[1]);
			if GetMaxScrap(1) ~= maxScrap + 40 then
				FailTest("Max scrap not increased by correct amount after spawning recy");
				RemoveObject(M.Object01);
				M.TestState = 99;
			else
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 1;
			end
		elseif M.TestState == 2 then	--test SetScrap()
			Info("Testing SetScrap()");
			SetScrap(1,25);
			if GetScrap(1) ~= 25 then
				RemoveObject(M.Object01);
				FailTest("SetScrap() did not set correct scrap value.");
			else
				RemoveObject(M.Object01);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 1;
			end
		elseif M.TestState == 3 then	--test SetMaxScrap()
			Info("Testing SetMaxScrap()");
			SetMaxScrap(1,0);
			if GetMaxScrap(1) ~= 0 then
				FailTest("SetMaxScrap(0) failed!");
				M.TestState = 99;
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 4 then
			SetMaxScrap(1,100);
			if GetMaxScrap(1) ~= 100 then
				FailTest("SetMaxScrap(100) failed!");
				M.TestState = 99;
			else
				SetScrap(1,100);
				if GetScrap(1) ~= 100 then
					FailTest("SetScrap(100) failed.");
					M.TestState = 99;
				else
					M.TestState = M.TestState + 1;
					M.TestTimer = GetTime() + 1;
				end
			end
		elseif M.TestState == 5 then	--test AddScrap()
			Info("Testing AddScrap()");
			SetMaxScrap(1,40);
			SetScrap(1, 20);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 6 then
			AddScrap(1, 10);
			if GetScrap(1) ~= 30 then
				FailTest("AddScrap(10) not working!");
				M.TestState = 99;
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 7 then
			AddScrap(1, -10);
			if GetScrap(1) ~= 20 then
				FailTest("AddScrap(-10) not working!");
				M.TestState = 99;
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 8 then
			SetMaxScrap(1, 0);
			SetScrap(1,0);
			PassTest();
			M.TestState = M.TestState + 1;
		end
	end
end

--Tests the ReplaceObject() function.
--parameters: H, *ODF, Team, HeightOffset, Empty, RestoreWeapons, Group, CanSnipe, KeepCommand, NewCommand, Priority,  NewWho, NewWhere
function Test_ReplaceObject()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then	--test ReplaceObject() with all default params. replace a scout
			if ReplaceObject == nil then
				FailTest("ReplaceObject is not defined!");
			else	
				Info("Testing ReplaceObject(h) with default parameters.");
				M.Object01 = BuildObject("ivscout", 1, M.Navs[1]);
				M.Direction1 = GetFront(M.Object01);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then
			M.Object01 = ReplaceObject(M.Object01);
			if not IsAround(M.Object01) then
				FailTest("ReplaceObject(h) failed. The new object is not around.");
			elseif not IsAlive(M.Object01) then
				FailTest("ReplaceObject(h) failed. The new object is not alive.");
			elseif GetDistance(M.Object01, M.Navs[1]) > 25  then
				FailTest("ReplaceObject(h) failed. The new object is in the wrong location.");
			elseif DotProduct(M.Direction1, GetFront(M.Object01)) < 0.99 then
				FailTest("ReplaceObject(h) failed. The new object is facing the wrong direction.");
			else
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 0.5;
			end
		elseif M.TestState == 2 then	--test replacing ivtank with fvscout with different team
			RemoveObject(M.Object01);
			Info("Testing ReplaceObject(h, odf, team) with ivtank and fvscout");
			M.Object01 = BuildObject("ivtank", 1, M.Navs[2]);
			M.Direction1 = GetFront(M.Object01);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 0.5;
		elseif M.TestState == 3 then
			M.Object01 = ReplaceObject(M.Object01, "fvscout", 0);
			if not IsAround(M.Object01) then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is not around.");
			elseif not IsAlive(M.Object01) then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is not alive.");
			elseif GetDistance(M.Object01, M.Navs[2]) > 25  then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is in the wrong location.");
			elseif DotProduct(M.Direction1, GetFront(M.Object01)) < 0.99  then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is facing the wrong direction.");
			elseif not IsOdf(M.Object01, "fvscout") then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is the wrong odf.");
			elseif GetTeamNum(M.Object01) ~= 0 then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is on the wrong team.");
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 4 then	--test out a building with a baseplate
			RemoveObject(M.Object01);
			local pos = GetPosition(M.Navs[3]);
			pos.y = TerrainFindFloor(pos);
			M.Object01 = BuildObject("ibfact", 1, pos);
			M.Direction1 = GetFront(M.Object01);
			M.Position1 = GetPosition(M.Object01);
			Info("Testing ReplaceObject(h, odf, team) with ibfact and ibsbay");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 0.5;
		elseif M.TestState == 5 then
			M.Object01 = ReplaceObject(M.Object01, "ibsbay", 0);
			if not IsAround(M.Object01) then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is not around.");
			elseif not IsAlive(M.Object01) then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is not alive.");
			elseif GetDistance(M.Object01, M.Position1) > 25  then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is in the wrong location.");
			elseif DotProduct(M.Direction1, GetFront(M.Object01)) < 0.99  then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is facing the wrong direction.");
			elseif not IsOdf(M.Object01, "ibsbay") then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is the wrong odf.");
			elseif GetTeamNum(M.Object01) ~= 0 then
				FailTest("ReplaceObject(h, odf, team) failed. The new object is on the wrong team.");
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 6 then	--test with ivrecy. (checks for bug where ivrecy would have no pilot after being replaced)
			RemoveObject(M.Object01);
			Info("testing replacing an ivrecy with itself and checking pilot");
			M.Object01 = BuildObject("ivrecy", 1, M.Navs[4]);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 7 then
			M.Object01 = ReplaceObject(M.Object01);
			if not IsAround(M.Object01) then
				FailTest("ReplaceObject with ivrecy  failed. The new object is not around.");
			elseif not IsAlive(M.Object01) then
				FailTest("ReplaceObject with ivrecy failed. The new object is not alive.");
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 8 then	--test empty, damaged ship
			RemoveObject(M.Object01);
			M.Object01 = BuildObject("fvtank", 1, M.Navs[5]);
			Damage(M.Object01, 100);
			KillPilot(M.Object01);
			Info("Testing empty, damaged ship");
			M.OldHealth = GetCurHealth(M.Object01);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 0.5;
		elseif M.TestState == 9 then
			M.Object01 = ReplaceObject(M.Object01);
			if not IsAround(M.Object01) then
				FailTest("ReplaceObject with empty,damaged ship failed. The new object is not around.");
			elseif IsAlive(M.Object01) then
				FailTest("ReplaceObject with empty,damaged ship failed. The new object is alive, but should not be.");
			elseif HasPilot(M.Object01) then
				FailTest("ReplaceObject with empty,damaged ship failed. The new object has a pilot, but should be empty.");
			elseif GetCurHealth(M.Object01) ~= M.OldHealth then
				FailTest("ReplaceObject with empty,damaged ship failed. The new object has the wrong health.");
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 10 then	--test extended params
			RemoveObject(M.Object01);
			M.Object01 = BuildObject("ivtank", 0, M.Navs[1]);
			Damage(M.Object01, 123);
			M.OldHealth = GetCurHealth(M.Object01);
			M.Position1 = GetPosition(M.Object01);
			Info("Testing extended parameters.");
			M.TestState = M.TestState + 1;
		elseif M.TestState == 11 then
			M.Object01 = ReplaceObject(M.Object01, "ivtank", 1, 100.0, 0, false, 4, 1, false, AiCommand.CMD_FOLLOW, 0, GetPlayerHandle());
			if not IsAround(M.Object01) then
				FailTest("ReplaceObject extended test failed. The new object is not around.");
			elseif not HasPilot(M.Object01) then
				FailTest("ReplaceObject extended test failed. The new object has no pilot.");
			elseif GetCurHealth(M.Object01) ~= M.OldHealth then
				FailTest("ReplaceObject extended test failed. The new object has the wrong health.");
			elseif math.abs(GetPosition(M.Object01).y - M.Position1.y - 100.0) > 10 then
				FailTest("ReplaceObject extended test failed. The new object has the wrong height offset.");
			elseif GetGroup(M.Object01) ~= 4 then
				FailTest("ReplaceObject extended test failed. The object is in the wrong group. Expected 4 but got "..GetGroup(M.Object01));
			elseif not IsFollowing(M.Object01) then
				FailTest("ReplaceObject extended test failed. The new command was not set.");
			elseif not GetCanSnipe(M.Object01) then
				FailTest("ReplaceObject extended test failed. CanSnipe is false when it should be true.");
			end
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 12 then
			RemoveObject(M.Object01);
			M.Object01 = BuildObject("ispilo", 1, M.Navs[3]);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 13 then	--check that new object has the weapons of the new odf if RestoreWeapons=false
			M.Object01 = ReplaceObject(M.Object01, "maniach", -1, 0.0, -1, false);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 14 then
			if not string.match(GetWeaponConfig(M.Object01, 0), "hbazook_c") then
				FailTest("ReplaceObject weapon config. The new unit did not have the correct weapon.");
			end
			RemoveObject(M.Object01);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 15 then
			PassTest();
			M.TestState = M.TestState + 1;
		end
	end
end

--ReplaceObject crashes when called on a unit that was told by a player to go to a nav beacon
function Test_ReplaceObject2()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			Info("Order the tank to a nav beacon (game may crash)");
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			Follow(M.Object01, M.Navs[2], 0);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 5;
		elseif M.TestState == 1 then
			--Goto(M.Object01, M.Navs[1], 0);
			--M.Object01 = ReplaceObject(M.Object01, "ivtank_e01");
			GetCurrentCommandWhere(M.Object01);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 2 then
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--tests the SetColorFade() func with various ratios/colors
function Test_SetColorFade()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			Info("SetColorFade(1,0.5,Make_RGBA(0,0,0,255))");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 0.5;
		elseif M.TestState == 1 then
			SetColorFade(1,0.5,Make_RGBA(0,0,0,255));
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 2 then
			Info("SetColorFade(4,0.2,Make_RGBA(255,0,0,255))");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 0.5;
		elseif M.TestState == 3 then
			SetColorFade(4,0.2,Make_RGBA(0,0,0,255));
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 4 then
			Info("SetColorFade(10,1,Make_RGBA(0,255,0,255))");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 0.5;
		elseif M.TestState == 5 then
			SetColorFade(10,1,Make_RGBA(0,255,0,255));
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 6 then
			Info("SetColorFade(.1,1,Make_RGBA(0,255,0,255))");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 0.5;
		elseif M.TestState == 7 then
			SetColorFade(0.1,1,Make_RGBA(0,255,0,255));
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 8 then
			Info("SetColorFade(1,0.1,Make_RGBA(0,255,0,255))");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 0.5;
		elseif M.TestState == 9 then
			SetColorFade(1,0.1,Make_RGBA(0,255,0,255));
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 10 then
			Info("SetColorFade(0,-10,Make_RGBA(0,255,0,255))");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 0.5;
		elseif M.TestState == 11 then
			SetColorFade(0,-10,Make_RGBA(0,255,0,255));
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 12 then
			Info("SetColorFade(4,0.2,Make_RGBA(0,0,0,255))");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 0.5;
		elseif M.TestState == 13 then
			SetColorFade(4,0.2,Make_RGBA(0,0,0,255));
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 14 then
			PassTest();
		end
	end
end

--spawns a pilot and makes him jetpack up into the air
--Tests SetWeaponMask(), GetWeaponMask()
function Test_Jetpack()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ispilo", 1, M.Navs[1]);
			SetWeaponMask(M.Object01, 4+2);	--standard jetpack does not activate with FireAt unless the weapon mask includes another weapon
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			FireAt(M.Object01, nil);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 5;
		elseif M.TestState == 2 then		
			local pos = GetPosition(M.Object01);
			if pos.y < TerrainFindFloor(pos) + 10 then
				FailTest();
			elseif GetWeaponMask(M.Object01) ~= 6 then
				FailTest("GetWeaponMask(): expected 6 but got "..tostring(GetWeaponMask(M.Object01)));
			else
				RemoveObject(M.Object01);
				PassTest();
			end
		end
	end
end

--tests various inputs to SetCameraPosition()
function Test_SetCameraPos()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ibcrat00", 0, SetVector(0, 5, 0));
			SetObjectiveOn(M.Object01);
			CameraReady();
			SetPosition(M.Object01, SetVector(50, 0, 0));
			Info("Camera at origin looking at +X axis. You should be looking straight at the crate.");
			M.CameraTimer = GetTime() + 2;
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then			
			SetCameraPosition(SetVector(0,0,0), SetVector(1,0,0));		
			if M.CameraTimer < GetTime() then
				Info("Camera at origin looking at -Z axis. You should be looking straight at the crate.");
				SetPosition(M.Object01, SetVector(0, 0, -50));
				M.CameraTimer = GetTime() + 2;
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 2 then			
			SetCameraPosition(SetVector(0,0,0), SetVector(0,0,-1));
			if M.CameraTimer < GetTime() then
				Info("Passing in zero vec for direction...");
				RemoveObject(M.Object01);
				M.CameraTimer = GetTime() + 2;
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 3 then
			SetCameraPosition(SetVector(0,0,0), SetVector(0,0,0));
			if M.CameraTimer < GetTime() then
				Info("Passing in nil position...");
				M.CameraTimer = GetTime() + 1;
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 4 then
			--Call SetCameraPosition() with bad parameters. Should give an error, but it shouldn't crash the game.
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
			--the following line will cause an error, so increment the state first so the script doesn't get stuck
			SetCameraPosition(nil, nil);	--Passing in nil position caused a crash. Fixed on 12/09/17
		elseif M.TestState == 5 then 
			--ResetCameraPosition() should reset the camera position to where it was when CameraReady() was called.
			Info("Resetting camera position...");
			ResetCameraPosition();
			M.CameraTimer = GetTime() + 2;
			M.TestState = M.TestState + 1;
		elseif M.TestState == 6 then
			if M.CameraTimer < GetTime() then
				CameraFinish();
				PassTest();
				M.TestState = M.TestState + 1;
			end
		end
	end
end

--tests playing audio messages and sound effects
--Tests AudioMessage(), StartSoundEffect(), FindSoundEffect(), StopSoundEffect(), IsAudioMessageDone(), StopAudio()
--Also calls but doesnt test PauseAudio()/ResumeAudio(), and SetVolume, which don't seem to work...
--TODO: test PurgeAudioMessage
function Test_SoundEffects()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then	--play an audio message
			M.Object01 = BuildObject("ibcrat00", 0, M.Navs[1]);
			SetObjectiveOn(M.Object01);
			Info("Playing audio message...");
			M.AudioHandle = AudioMessage("team0101.wav");
			local audioTime = 0;
			if TRY_TO_CRASH then
				audioTime = GetAudioFileDuration(M.AudioHandle);	--CRASHES BZ2!!!	
			else
				audioTime = 4;	--placeholder for audio duration
			end
			if type(audioTime) ~= "number" or audioTime < 0 or audioTime > 5 then
				FailTest("GetAudioFileDuration() returned bad result: "..tostring(audioTime));
			end
			M.AudioTimeout = GetTime() + audioTime + 0.1;
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			if IsAudioMessageDone(M.AudioHandle) then
				M.TestState = M.TestState + 1;
			elseif M.AudioTimeout < GetTime() then
				FailTest("IsAudioMessageDone() did not return true when audio message was finished!");
			elseif M.AudioHandle == nil then
				FailTest("AudioMessage() returned nil.");
			end
		elseif M.TestState == 2 then	--play a sound effect
			Info("Playing sound effect at crate...");
			M.AudioHandle = StartSoundEffect("team0101.wav", M.Object01);
			M.AudioTimeout = GetTime() + 5;
			M.TestState = M.TestState + 1;
		elseif M.TestState == 3 then
			if IsAudioMessageDone(M.AudioHandle) then
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 2;
			elseif M.AudioTimeout < GetTime() then
				FailTest("IsAudioMessageDone() did not return true when sound effect was finished!");
			elseif M.AudioHandle == nil then
				FailTest("StartSoundEffect() returned nil.");
			end
		elseif M.TestState == 4 then	--find and stop a sound effect in progress
			Info("Finding and stopping a sound effect...");
			M.AudioHandle = StartSoundEffect("team0101.wav", M.Object01);
			M.TestTimer = GetTime() + 0.5;
			M.TestState = M.TestState + 1;
		elseif M.TestState == 5 then
			local audioHandle = FindSoundEffect("team0101.wav", M.Object01);
			if audioHandle ~= M.AudioHandle then
				FailTest("FindSoundEffect(): expected "..tostring(M.AudioHandle).." but got "..tostring(audioHandle));
			else
				StopSoundEffect(M.AudioHandle);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 6 then
			if not IsAudioMessageDone(M.AudioHandle) then
				FailTest("StopSoundEffect(): The sound effect is still playing.");
			else
				RemoveObject(M.Object01);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 7 then	--test Pause/Resume
			Info("Testing Pause/Resume...");
			M.AudioHandle = AudioMessage("mes0101.wav");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 8 then
			--if IsAudioMessageDone(M.AudioHandle) then
			--	FailTest("IsAudioMessageDone() returned true for 'mes0101.wav'.");
			--else
				Info("Pausing audio...");	--PauseAudio doesn't work?
				PauseAudio(M.AudioHandle);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 3;
			--end
		elseif M.TestState == 9 then
			if IsAudioPlaying(M.AudioHandle) and false then
				FailTest("PauseAudio() failed. The audio is still playing.");
			else
				Info("Resuming audio...");
				ResumeAudio(M.AudioHandle);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 3;
			end
		elseif M.TestState == 10 then
			if not IsAudioPlaying(M.AudioHandle) and false then
				FailTest("ResumeAudio() failed. The audio is not playing.");
			else
				Info("Setting volume to full...");
				SetVolume(M.AudioHandle, 1.0, false);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 3;
			end
		elseif M.TestState == 11 then
			Info("Setting volume to 0.1...");
			SetVolume(M.AudioHandle, 0.1, false);	--SetVolume doesn't seem to do anything...
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 12 then
			Info("Stopping audio...");
			StopAudio(M.AudioHandle);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 13 then
			if IsAudioPlaying(M.AudioHandle) and false then
				FailTest("StopAudio() failed. The audio is still playing.");
			else
				PassTest();
			end
		end
	end
end

--tests playing sounds with the Audio3D function
--IsAudioPlaying() is giving some funky results. IsAudioMessageDone() is more reliable.
--Note: Audio messages first start playing the following tick after they are started. 
--IsAudioPlaying() will return false if you call it the same tick you call StartAudio3D()/AudioMessage(),etc
--This test is screwed up ATM, due to some weirdness with IsAudioPlaying().
--TODO: test IsPlayingLooped()
function Test_Audio3D()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then	--test Audio3D funcs
			Info("Testing Audio3D...");
			--M.AudioHandle = StartAudio3D("mes0101.wav", GetPlayerHandle(), 3, false, false);
			--M.AudioHandle = AudioMessage("team0101.wav");
			M.AudioHandle = AudioMessage("mes0101.wav");
			--M.AudioHandle = StartSoundEffect("mes0101.wav");
			M.TestState = M.TestState + 1;
			--M.TestTimer = GetTime() + 1;
		elseif M.TestState == 1 then
			--print(tostring(M.AudioHandle));
			--print(tostring("IsAudioPlaying():"..tostring(IsAudioPlaying(M.AudioHandle))));
			--print(tostring(IsAudioMessageDone(M.AudioHandle)));
			if not IsAudioPlaying(M.AudioHandle) then	--IsAudioPlaying() seems to be a bit wonky. Doesn't always work...
				FailTest("IsAudioPlaying() returned false.");
			else
				Info("Pausing audio...");
				PauseAudio(M.AudioHandle);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 3;
			end
		elseif M.TestState == 2 then
			if IsAudioPlaying(M.AudioHandle) then
				FailTest("PauseAudio() failed. The audio is still playing.");
			else
				Info("Resuming audio...");
				ResumeAudio(M.AudioHandle);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 3;
			end
		elseif M.TestState == 3 then
			if not IsAudioPlaying(M.AudioHandle) then
				FailTest("ResumeAudio() failed. The audio is not playing.");
			else
				Info("Setting volume to full...");
				SetVolume(M.AudioHandle, 1.0);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 3;
			end
		elseif M.TestState == 4 then
			Info("Setting volume to 0.1...");
			SetVolume(M.AudioHandle, 0.1);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 5 then
			Info("Stopping audio...");
			StopAudio(M.AudioHandle);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 6 then
			if IsAudioPlaying(M.AudioHandle) then
				FailTest("StopAudio() failed. The audio is still playing.");
			else
				PassTest();
				M.TestState = M.TestState + 1;
			end
		end
	end
end

--tests the terrain funcs on some path locations {"water_pos", "slope_pos", "land_pos"} around a a pool of water on the left.
--water_pos is on flat land at height -10 and in the middle of the water
--slope_pos is on the slope on the edge of the water
--land_pos is on flat land outside the water at height 0
--Tests TerrainFindFloor(), TerrainIsWater(), GetTerrainHeightAndNormal()
function Test_TerrainFuncs()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.WaterPos = GetPosition("water_pos");
			M.LandPos = GetPosition("land_pos");
			M.SlopePos = GetPosition("slope_pos");
			if M.WaterPos == nil then
				FailTest("Error: path point 'water_pos' not found!");
			elseif M.LandPos == nil then
				FailTest("Error: path point 'land_pos' not found!");
			elseif M.SlopePos == nil then
				FailTest("Error: path point 'slope_pos' not found!");
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			--checks to see if TerrainFindFloor is returning the correct height.
			--water_pos should be at -10.0m and land_pos should be at 0.0m
			local waterHeight = TerrainFindFloor(M.WaterPos);
			local landHeight = TerrainFindFloor(M.LandPos);
			if math.abs(waterHeight + 10.0) > 0.001 then
				FailTest(string.format("TerrainFindFloor(): expected %f but got %f at 'water_pos'.", -10.0, waterHeight));
			elseif math.abs(landHeight) > 0.001 then
				FailTest(string.format("TerrainFindFloor(): expected %f but got %f at 'land_pos'.", 0.0, landHeight));
			end
			M.Object01 = BuildObject("ibcrat00", 0, M.WaterPos);
			M.Object02 = BuildObject("ibcrat00", 0, M.LandPos);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 2 then		
			--TerrainIsWater should return true for water_pos and false for land_pos
			if not TerrainIsWater(M.WaterPos) then
				FailTest("TerrainIsWater(<vector>) returned false for water_pos.");
			elseif not TerrainIsWater(M.Object01) then
				FailTest("TerrainIsWater(<Handle>) returned false for water_pos.");
			elseif not TerrainIsWater("water_pos") then
				FailTest("TerrainIsWater(<path>) returned false for water_pos.");	--TerrainIsWater(<path>)always returning false fixed on 14/09/17
			elseif not TerrainIsWater(GetTransform(M.Object01)) then
				FailTest("TerrainIsWater(<matrix>) returned false for water_pos.");
			elseif TerrainIsWater(M.Object02) then
				FailTest("TerrainIsWater(<Handle>) returned true for land_pos.");
			elseif TerrainIsWater(M.LandPos) then
				FailTest("TerrainIsWater(<vector>) returned true for land_pos.");
			elseif TerrainIsWater("land_pos") then
				FailTest("TerrainIsWater(<path>) returned true for land_pos.");
			elseif TerrainIsWater(M.LandPos.x, M.LandPos.z) then
				FailTest("TerrainIsWater(<x,z>) returned true for land_pos.");
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 3 then
			--water_pos should have a height of -10.0 and a normal pointing straight up		
			local height, norm = GetTerrainHeightAndNormal(M.Object01);
			if math.abs(height + 10.0) > 0.001 then
				FailTest(string.format("GetTerrainHeightAndNormal(): expected height of %f but got %f.", -10.0, height));
			elseif math.abs(norm.y - 1.0) > 0.001 then
				FailTest(string.format("GetTerrainHeightAndNormal(): expected norm.y == 1.0 but got %f", 1.0, norm.y));
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 4 then
			--if useWater=true, then it should return a height of -5 for water_pos
			local height, norm = GetTerrainHeightAndNormal(M.Object01, true);
			if math.abs(height + 5.0) > 0.001 then
				FailTest(string.format("GetTerrainHeightAndNormal(): expected height of %f but got %f.", -5.0, height));
			elseif math.abs(norm.y - 1.0) > 0.001 then
				FailTest(string.format("GetTerrainHeightAndNormal(): expected norm.y == 1.0 but got %f", 1.0, norm.y));
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 5 then
			--slope_pos should have a height somewhere inbetween and a normal with x = 0, y < 1.0 and z < 0, since the slope is facing south
			local height, norm = GetTerrainHeightAndNormal(GetPosition("slope_pos"));
			if height > 0.0 or height < -10 then
				FailTest(string.format("GetTerrainHeightAndNormal(): expected height of %f but got %f.", -7.0, height));
			elseif norm.y > 0.95 or norm.z > -0.1 or math.abs(norm.x) > 0.01 then
				FailTest("GetTerrainHeightAndNormal(): incorrect normal for slope_pos: "..tostring(normal));
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 6 then
			PassTest();
		end
	end
end

--Tells a tug to pickup a crate, then move to another nav, then drop it off.
--tests Pickup(), GetTug(), and HasCargo(). 
function Test_Tug()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ivtug", 1, M.Navs[1]);
			M.Object02 = BuildObject("ibcrat00", 0, M.Navs[2]);
			SetObjectiveOn(M.Object01);
			SetObjectiveOn(M.Object02);
			Info("Picking up crate...");
			Pickup(M.Object01, M.Object02, 1);
			if GetTug(M.Object02) ~= nil then
				FailTest("GetTug() was not nil before crate was picked up by tug.");
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			if HasCargo(M.Object01) then
				local tug = GetTug(M.Object02);
				if tug ~= M.Object01 then
					FailTest("GetTug() returned the wrong object! Expected "..tostring(M.Object01).." but got "..tostring(tug));
				else
					Goto(M.Object01, M.Navs[3], 1);
					Info("Going to nav 3");
					M.TestState = M.TestState + 1;
				end
			end
		elseif M.TestState == 2 then
			if GetDistance(M.Object01, M.Navs[3]) < 25 then
				Info("Dropping off");
				Dropoff(M.Object01, M.Navs[3], 1);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 3 then
			if not HasCargo(M.Object01) then
				local tug = GetTug(M.Object02);
				if tug ~= nil then
					FailTest("GetTug() was not nil after crate was dropped off! Got "..tostring(tug));
				else
					RemoveObject(M.Object01);
					RemoveObject(M.Object02);
					PassTest();
				end
			end
		end
	end
end

--Tests Damage(), GetHealth(), GetCurHealth(), GetMaxHealth(), SetCurHealth(), SetMaxHealth(), 
--AddHealth(), GetAmmo(), GetCurAmmo(), GetMaxAmmo(), SetCurAmmo(), SetMaxAmmo(), AddAmmo()
function Test_HealthAmmo()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			local MAX_HEALTH = 3500;
			local MAX_AMMO = 2200;
			local maxHealth = GetMaxHealth(M.Object01);
			local maxAmmo = GetMaxAmmo(M.Object01);
			local curHealth = GetCurHealth(M.Object01);
			local curAmmo = GetCurAmmo(M.Object01);
			local healthF = GetHealth(M.Object01);
			local ammoF = GetAmmo(M.Object01);
			if maxHealth ~= MAX_HEALTH then
				FailTest("GetMaxHealth(): expected "..tostring(MAX_HEALTH).." but got "..tostring(maxHealth));
			elseif maxAmmo ~= MAX_AMMO then
				FailTest("GetMaxAmmo(): expected "..tostring(MAX_AMMO).." but got "..tostring(maxAmmo));
			elseif curHealth ~= MAX_HEALTH then
				FailTest("GetCurHealth(): expected "..tostring(MAX_HEALTH).." but got "..tostring(curHealth));
			elseif curAmmo ~= MAX_AMMO then
				FailTest("GetCurAmmo(): expected "..tostring(MAX_AMMO).." but got "..tostring(curAmmo));
			elseif healthF ~= 1.0 then
				FailTest("GetHealth(): expected 1.0 but got "..tostring(healthF));
			elseif ammoF ~= 1.0 then
				FailTest("GetAmmo(): expected 1.0 but got "..tostring(ammoF));
			end
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 1 then
			SetMaxHealth(M.Object01, 10000);
			SetMaxAmmo(M.Object01, 10000);
			if GetMaxHealth(M.Object01) ~= 10000 then
				FailTest("SetMaxHealth(): new max health was not set.");
			elseif GetMaxAmmo(M.Object01) ~= 10000 then
				FailTest("SetMaxAmmo(): new max ammo was not set.");
			end
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 2 then
			SetCurHealth(M.Object01, 10000);
			Damage(M.Object01, 5001);
			SetCurAmmo(M.Object01, 5000);
			AddAmmo(M.Object01, 100);
			if GetCurHealth(M.Object01) ~= 4999 then
				FailTest("GetCurHealth() returned wrong health after Damage()");
			elseif GetHealth(M.Object01) > 0.5 or GetHealth(M.Object01) < 0.4 then
				FailTest("GetHealth() returned wrong value after Damage()");
			elseif GetCurAmmo(M.Object01) ~= 5100 then
				FailTest("GetCurAmmo() returned wrong value after AddAmmo()");
			elseif GetAmmo(M.Object01) < 0.5 or GetAmmo(M.Object01) > 0.6 then
				FailTest("GetAmmo() returned wrong value after AddAmmo()");
			end
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 3 then
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--Tests AtTerminal() and InBuilding().
--AtTerminal() returns the building the handle is logged into
--InBuilding() returns the building the handle is inside (doesn't need to be logged in).
function Test_AtTerminal()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			local pos = GetPosition(M.Navs[1]);
			pos.y = TerrainFindFloor(pos);
			M.Object01 = BuildObject("ibcbun", 1, BuildDirectionalMatrix(pos));
			AddPower(1,1);
			Info("Log into the comm bunk");
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			if AtTerminal(GetPlayerHandle()) == M.Object01 then
				if InBuilding(GetPlayerHandle()) ~= M.Object01 then
					FailTest("InBuilding() returned false when player was in bunker.");
				end
				Info("Logged in. Now log out.");
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 2 then
			if AtTerminal(GetPlayerHandle()) == nil then
				Info("Logged out.");
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 1;
			end
		elseif M.TestState == 3 then
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--Tests GetWhoShotMe(), GetLastFriendShot(), GetLastEnemyShot(), Annoy()
--TODO: test Annoy() more thoroughly
function Test_ShotBy()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			SetMaxHealth(M.Object01, 10000);
			SetCurHealth(M.Object01, 10000);
			local pos = GetPosition(M.Object01) + SetVector(0,0,25);
			M.Object02 = BuildObject("ivtank", 1, pos);
			LookAt(M.Object01, M.Object02);
			LookAt(M.Object02, M.Object01);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 1 then
			FireAt(M.Object01, M.Object02);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 2 then
			if GetWhoShotMe(M.Object02) ~= M.Object01 then
				FailTest("GetWhoShotMe() returned wrong handle.");
			elseif GetLastFriendShot(M.Object02) < GetTime() - 2 then
				FailTest("GetLastFriendShot() returned wrong time.");
			end
			RemoveObject(M.Object02);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 3 then
			local pos = GetPosition(M.Object01) + SetVector(0,0,25);
			M.Object02 = BuildObject("fvtank", 2, pos);
			SetMaxHealth(M.Object02, 10000);
			SetCurHealth(M.Object02, 10000);
			LookAt(M.Object01, M.Object02);
			LookAt(M.Object02, M.Object01);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 4 then
			Attack(M.Object01, M.Object02);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 5 then
			if GetWhoShotMe(M.Object02) ~= M.Object01 then
				FailTest("GetWhoShotMe() returned wrong handle.");
			elseif GetLastEnemyShot(M.Object02) < GetTime() - 2 then
				FailTest("GetLastEnemyShot() returned wrong time.");
			else
				RemoveObject(M.Object01);
				RemoveObject(M.Object02);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 6 then	--test Annoy(). Object02 should think that Object01 shot it
			if Annoy == nil then
				FailTest("Annoy(): function not defined.");
			else
				M.Object01 = BuildObject("ivmisl", 1, M.Navs[1]);
				M.Object02 = BuildObject("ivmbike", 2, M.Navs[2]);
				Annoy(M.Object01, M.Object02);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 7 then
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			PassTest();
		end
	end
end

--Tests GetPathPoints(), SetPathType(). 
--SetPathOneWay() is equivalent to SetPathType() with type=0.
--SetPathRoundTrip() is equivalent to SetPathType() with type=1. 
--SetPathLoop() is equivalent to SetPathType() with type=2. 
function Test_Paths()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			--Test GetPathPoints(). On the test map, "nav_path" is a path with 5 points that are almost exactly where the navs are.
			local pathPoints = GetPathPoints("nav_path");
			if pathPoints == nil then
				FailTest("GetPathPoints() returned nil for 'nav_path'.");
			elseif table.getn(pathPoints) ~= 5 then
				FailTest("GetPathPoints() expected 5 points but got "..table.getn(pathPoints)..".");
			else
				--each path point should be close to the corresponding Nav beacon.
				for i = 1,5 do
					local p1 = pathPoints[i];
					local p2 = GetPosition(M.Navs[i]);
					local dx = p1.x - p2.x;
					local dz = p1.z - p2.z;
					local d = math.sqrt(dx*dx+dz*dz);
					if d > 15 then 
						FailTest("GetPathPoints(): point "..tostring(i).." is wrong. Expected "..tostring(p2).." but got "..tostring(p1).." (err="..tostring(d).." m).");
					end
				end
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then
			--Send an ivscout a 1 way path. It should stop once it reaches the last point.
			SetPathType("nav_path", 0);
			Info("Retreating along one way path...");
			M.Object01 = BuildObject("ivscout", 1, "nav_path");
			Retreat(M.Object01, "nav_path", 1);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 2 then
			if GetDistance(M.Object01, M.Navs[5]) < 25 then
				Info("Reached destination.");
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 5;
			end
		elseif M.TestState == 3 then
			if GetCurrentCommand(M.Object01) ~= 0 then
				FailTest("SetPathType(): path should be one way, but GetCurrentCommand() ~= 0 after reaching last point.");
			else
				RemoveObject(M.Object01);
				M.TestState = M.TestState + 1;
			end			
		elseif M.TestState == 4 then
			--Send an ivscout to do a round trip. It should go back the way it came once it reaches the final point.
			SetPathType("nav_path", 1);
			Info("Doing a round trip...");
			M.Object01 = BuildObject("ivscout", 1, "nav_path");
			Retreat(M.Object01, "nav_path", 1);
			--M.TestState = M.TestState + 1;	--!!!Round trip paths seem to be broken...
			M.TestState = 8; --Skip testing the round trip.
		elseif M.TestState == 5 then
			if GetDistance(M.Object01, M.Navs[5]) < 25 then
				Info("Reached final point.");
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 5;
			end
		elseif M.TestState == 6 then
			if GetCurrentCommand(M.Object01) == 0 then
				FailTest("SetPathType(): unit stopped at final path point after setting path type to round trip");
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 7 then
			if GetDistance(M.Object01, M.Navs[1]) < 25 then
				FailTest("SetPathType(): unit did not go back the way it came for round trip path.");
			elseif GetDistance(M.Object01, M.Navs[4]) < 25 then
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 8 then
			--Send an ivscout to do a loop. It should head straight to the starting point once it reaches the final point.
			RemoveObject(M.Object01);
			SetPathType("nav_path", 2);
			Info("Setting path type to loop...");
			M.Object01 = BuildObject("ivscout", 1, "nav_path");
			Retreat(M.Object01, "nav_path", 1);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 9 then
			if GetDistance(M.Object01, M.Navs[5]) < 25 then
				Info("Reached final point.");
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 5;
			end
		elseif M.TestState == 10 then
			if GetCurrentCommand(M.Object01) == 0 then
				FailTest("SetPathType(): unit stopped at final path point after setting path type to loop.");
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 11 then
			if GetDistance(M.Object01, M.Navs[4]) < 25 then
				FailTest("SetPathType(): unit did not go back to first point for path type=loop.");
			elseif GetDistance(M.Object01, M.Navs[1]) < 25 then
				RemoveObject(M.Object01);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 12 then
			PassTest();
		end
	end
end

--Tests GetNearestObject(), GetNearestVehicle(), GetNearestEnemy(), GetNearestBuilding(), GetNearestPowerup(), GetNearestPerson()
function Test_GetNearestObject()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			local pos = SetVector(200,0,0);	--Nav beacons count for GetNearestObject(), so do this test away from the navs
			M.Object01 = BuildObject("ivscav", 1, pos);
			pos.z = pos.z + 25;	
			M.Object02 = BuildObject("ivtug", 1, pos);
			pos.z = pos.z + 25;
			M.Object03 = BuildObject("sspilo", 2, pos);
			pos.z = pos.z + 25;
			M.Object04 = BuildObject("fvscav", 2, pos);
			pos.z = pos.z + 25;
			M.Object05 = BuildObject("fvtug", 2, pos);
			pos.z = pos.z + 25;
			M.Object06 = BuildObject("ibpgen", 2, BuildDirectionalMatrix(pos));
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			if GetNearestObject(M.Object01) ~= M.Object02 then
				FailTest("GetNearestObject() did not return ivtug");
			elseif GetNearestEnemy(M.Object01) ~= M.Object03 then
				FailTest("GetNearestEnemy() did not return sspilo");
			elseif GetNearestEnemy(M.Object01, true, false) ~= M.Object04 then
				FailTest("GetNearestEnemy() with ignorepilots=true, ignorescavs=false did not return fvscav");
			elseif GetNearestEnemy(M.Object01, true, true) ~= M.Object05 then
				FailTest("GetNearestEnemy() with ignorepilots=true, ignorescavs=true did not return fvrecy");
			elseif GetNearestBuilding(M.Object01) ~= M.Object06 then
				FailTest("GetNearestBuilding() did not return ibpgen");
			end
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			RemoveObject(M.Object03);
			RemoveObject(M.Object04);
			RemoveObject(M.Object05);
			RemoveObject(M.Object06);
			local pos = SetVector(200,0,0);
			M.Object01 = BuildObject("ivtank", 1, pos);
			pos.z = pos.z + 25
			M.Object02 = BuildObject("ispilo", 1, pos);
			pos.z = pos.z + 25
			M.Object03 = BuildObject("apserv", 0, pos);
			pos.z = pos.z + 25
			M.Object04 = BuildObject("apchain", 0, pos);
			M.TestState = M.TestState + 1;
			pos.z = pos.z + 25
			M.Object05 = BuildObject("ispilo", 2, pos);
		elseif M.TestState == 2 then
			if GetNearestPowerup(M.Object01) ~= M.Object03 then
				FailTest("GetNearestPowerup(): did not return apserv");
			elseif GetNearestPerson(M.Object01, false) ~= M.Object02 then
				FailTest("GetNearestPerson(): did not return Object02");
			elseif GetNearestPerson(M.Object01, true) ~= M.Object05 then
				FailTest("GetNearestPerson(): did not return Object05");
			else
				RemoveObject(M.Object01);
				RemoveObject(M.Object02);
				RemoveObject(M.Object03);
				RemoveObject(M.Object04);
				RemoveObject(M.Object05);
				PassTest();
			end
		end
	end
end

--Tests SetControls(), ClearThrust() 
--Note: SetControls() must be called each tick for the duration you want to disable the controls.
--Available controls are: { braccel=0, steer=0, pitch=0, strafe=0, jump=false, deploy=false, eject=false, abandon=false, fire=false }
function Test_Controls()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			Info("braccel disabled...");	
			M.TestState = M.TestState + 1;
			M.Timer1 = GetTime() + 3;
		elseif M.TestState == 1 then
			SetControls(GetPlayerHandle(), {braccel=0});
			if M.Timer1 < GetTime() then
				Info("steer disabled...");	
				M.TestState = M.TestState + 1;
				M.Timer1 = GetTime() + 3;
			end
		elseif M.TestState == 2 then
			SetControls(GetPlayerHandle(), {steer=0});
			if M.Timer1 < GetTime() then
				Info("pitch disabled...");	
				M.TestState = M.TestState + 1;
				M.Timer1 = GetTime() + 3;
			end
		elseif M.TestState == 3 then
			SetControls(GetPlayerHandle(), {pitch=0});
			if M.Timer1 < GetTime() then
				Info("strafe disabled...");	
				M.TestState = M.TestState + 1;
				M.Timer1 = GetTime() + 3;
			end
		elseif M.TestState == 4 then
			SetControls(GetPlayerHandle(), {strafe=0});
			if M.Timer1 < GetTime() then
				Info("jump disabled...");	
				M.TestState = M.TestState + 1;
				M.Timer1 = GetTime() + 3;
			end
		elseif M.TestState == 5 then
			SetControls(GetPlayerHandle(), {jump=0});
			if M.Timer1 < GetTime() then
				Info("deploy disabled...");	
				M.TestState = M.TestState + 1;
				M.Timer1 = GetTime() + 3;
			end
		elseif M.TestState == 6 then
			SetControls(GetPlayerHandle(), {deploy=0});
			if M.Timer1 < GetTime() then
				Info("eject disabled...");	
				M.TestState = M.TestState + 1;
				M.Timer1 = GetTime() + 3;
			end
		elseif M.TestState == 7 then
			SetControls(GetPlayerHandle(), {eject=0});
			if M.Timer1 < GetTime() then
				Info("abandon disabled...");	
				M.TestState = M.TestState + 1;
				M.Timer1 = GetTime() + 3;
			end
		elseif M.TestState == 8 then
			SetControls(GetPlayerHandle(), {abandon=0});
			if M.Timer1 < GetTime() then
				Info("fire disabled...");
				M.TestState = M.TestState + 1;
				M.Timer1 = GetTime() + 3;
			end
		elseif M.TestState == 9 then
			SetControls(GetPlayerHandle(), {fire=0});
			if M.Timer1 < GetTime() then
				Info("Clearing thrust...");
				M.TestState = M.TestState + 1;
				M.Timer1 = GetTime() + 3;
			end
		elseif M.TestState == 10 then
			ClearThrust(GetPlayerHandle());
			if M.Timer1 < GetTime() then
				PassTest();
			end
		end
	end
end

--Tests IsSelected(), GetUserTarget(), IsInfo(), GetLocalUserInspectHandle(), GetLocalUserSelectHandle(),
--GetTarget(), WhoIsTargeting()
--This is a manual test requiring player input.
function Test_IsSelected()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			SetObjectiveName(M.Object01, "SELECT ME!");
			SetObjectiveOn(M.Object01);
			Info("Select the tank");		
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			if IsSelected(M.Object01) then
				if GetLocalUserSelectHandle() ~= M.Object01 then
					FailTest("GetLocalUserSelectHandle() did not return correct handle!");
				else
					Info("Unit selected.");
					M.TestState = M.TestState + 1;
					M.TestTimer = GetTime() + 1;
				end
			end
		elseif M.TestState == 2 then
			Info("Use your i key on the tank.");
			SetObjectiveName(M.Object01, "IDENTIFY ME!");
			M.TestState = M.TestState + 1;
		elseif M.TestState == 3 then
			if IsInfo(M.Object01) then
				if GetLocalUserInspectHandle() ~= M.Object01 then
					FailTest("GetLocalUserInspectHandle() did not return correct handle!");
				else
					Info("Unit info'd.");
					M.TestState = M.TestState + 1;
					M.TestTimer = GetTime() + 1;
				end
			end
		elseif M.TestState == 4 then
			SetUserTarget(nil);
			SetObjectiveName(M.Object01, "TARGET ME!");
			Info("Now target the tank.");
			M.TestState = M.TestState + 1;
		elseif M.TestState == 5 then
			if GetUserTarget() == M.Object01 then
				local objs = WhoIsTargeting(M.Object01);
				if objs == nil or table.getn(objs) == 0 then
					FailTest("WhoIsTargeting() did not return player.");
				elseif GetTarget(GetPlayerHandle()) ~= M.Object01 then
					FailTest("GetTarget() returned wrong result.");
				else
					Info("Unit targeted.");
					M.TestState = M.TestState + 1;
					M.TestTimer = GetTime() + 1;
				end
			end
		elseif M.TestState == 6 then
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--Tests Make_RGB() and Make_RGBA()
--Displays some objective text in different colors and alphas.
function Test_RGB()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			local red = Make_RGB(255,0,0);
			local green = Make_RGB(0,255,0);
			local blue = Make_RGB(0,0,255);
			ClearObjectives();
			AddObjective("Red", red);
			AddObjective("Green", green);
			AddObjective("Blue", blue);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 1 then
			local opacity100 = Make_RGBA(255,255,255,255);
			local opacity50 = Make_RGBA(255,255,255,127);
			local opacity25 = Make_RGBA(255,255,255,64);
			ClearObjectives();
			AddObjective("100% Opacity", opacity100);
			AddObjective("50% Opacity", opacity50);
			AddObjective("25% Opacity", opacity25);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 2 then
			PassTest();
		end
	end
end

--Spawns in a turret and tries to deploy and undeploy it.
--Tests Deploy() and IsDeployed().
function Test_Deploy()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ivturr", 1, M.Navs[1]);
			Info("Deploying...");
			Deploy(M.Object01);
			M.TestState = M.TestState + 1;
			M.Timer1 = GetTime() + 10;
		elseif M.TestState == 1 then
			if IsDeployed(M.Object01) then
				Info("Deployed.");
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 3;
			elseif M.Timer1 < GetTime() then
				FailTest("Deploy(): turret failed to deploy.");
			end
		elseif M.TestState == 2 then
			Info("Undeploying...");
			Deploy(M.Object01);
			M.TestState = M.TestState + 1;
			M.Timer1 = GetTime() + 10;
		elseif M.TestState == 3 then
			if not IsDeployed(M.Object01) then
				Info("Undeployed.");
				Goto(M.Object01, M.Navs[2]);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 2;
			elseif M.Timer1 < GetTime() then
				FailTest("Deploy(): turret failed to undeploy.");
			end
		elseif M.TestState == 4 then
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--Gets a constructor to build a relay bunker
--Tests Build(), Dropoff()
function Test_Build()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			local cons_pos = GetPosition(M.Navs[1]);
			cons_pos.z = cons_pos.z + 25;
			M.Object01 = BuildObject("ivcons", 1, cons_pos);
			local pos = GetPosition(M.Navs[5]);
			pos.y = TerrainFindFloor(pos);
			M.Object02 = BuildObject("ibpgen", 1, BuildDirectionalMatrix(pos));
			pos.z = pos.z - 32;
			M.Object03 = BuildObject("ibscup", 1, BuildDirectionalMatrix(pos));
			pos.z = pos.z - 32;
			M.Object04 = BuildObject("ibscup", 1, BuildDirectionalMatrix(pos));
			pos.z = pos.z - 32;
			M.Object05 = BuildObject("ibscup", 1, BuildDirectionalMatrix(pos));
			pos.z = pos.z - 32;
			M.Object06 = BuildObject("ibscup", 1, BuildDirectionalMatrix(pos));
			AddScrap(1, 80);		
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			SetObjectiveOn(M.Object01);
			Build(M.Object01, "ibcbun", 1);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 2 then
			Dropoff(M.Object01, M.Navs[1], 1);
			M.NewObject = nil;
			M.TestState = M.TestState + 1;
		elseif M.TestState == 3 then
			if GetOdf(M.NewObject) == "ibcbun.odf" then
				RemoveObject(M.Object01);
				RemoveObject(M.Object02);
				RemoveObject(M.Object03);
				RemoveObject(M.Object04);
				RemoveObject(M.Object05);
				RemoveObject(M.Object06);
				RemoveObject(M.NewObject);
				PassTest();
			end
		end
	end
end

--Adds some text to the messages box
--Tests AddToMessagesBox()
function Test_MessagesBox()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			ClearObjectives();
			AddToMessagesBox("Red", Make_RGB(255,0,0));
			AddToMessagesBox("Green", "green");
			AddToMessagesBox("Blue", "blue");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 3;
		elseif M.TestState == 1 then
			AddToMessagesBox("The quick brown fox jumped over the lazy dog.\nThe quick brown fox jumped over the lazy dog.", "white");
			AddToMessagesBox("All work and no play makes Jack a dull boy.", "white");
			AddToMessagesBox("All work and no play makes Jack a dull boy.", "white");
			M.TestState = M.TestState + 1;
		elseif M.TestState == 2 then
			PassTest();
		end
	end
end

--Tests SetVelocity(), IsWithin()
function Test_SetVelocity()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			M.Timer1 = GetTime() + 6;
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			local dir = GetPosition(M.Navs[2]) - GetPosition(M.Navs[1]);
			local dist = Length(dir);
			dir = Normalize(dir);
			local speed = dist / 4;
			SetVelocity(M.Object01, speed * dir);
			if M.Timer1 < GetTime() then
				FailTest("SetVelocity(): took too long to reach nav 2.");
			elseif IsWithin(M.Object01, M.Navs[2], 25) then
				RemoveObject(M.Object01);
				PassTest();
			end
		end		
	end
end

--Tests SetAnimation(), StartAnimation(), GetAnimationFrame(),
--Note: an animation will end at the <AnimationFrames - 1>th frame. It starts playing on the same tick as it is called.
function Test_Animations()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then	--1 way animation. the dropship should open its doors and they should stay open.
			M.Object01 = BuildObject("ivpdrop", 1, M.Navs[1]);
			M.AnimationFrames = SetAnimation(M.Object01, "deploy", 1);
			StartAnimation(M.Object01);
			if type(M.AnimationFrames) ~= "number" or M.AnimationFrames <= 0 then
				FailTest("SetAnimation() returned bad frame count: "..tostring(M.AnimationFrames));
			else
				Info("Starting 1 way animation ("..tostring(M.AnimationFrames).." frames)");
				M.TestTimeout = GetTime() + 10;
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then
			if M.TestTimeout < GetTime() then
				FailTest("SetAnimation(): 1 way Animation took too long to finish.");
			elseif GetAnimationFrame(M.Object01, "deploy") >= M.AnimationFrames - 1 then	--GetAnimationFrame() stops on framecount - 1 for some reason
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 1;
			end
		elseif M.TestState == 2 then
			M.AnimationFrames = SetAnimation(M.Object01, "deploy", 0);--loop animation. the animation should go back from the starting frame when it reaches the last frame.
			StartAnimation(M.Object01);
			if type(M.AnimationFrames) ~= "number" or M.AnimationFrames <= 0 then
				FailTest("SetAnimation() returned bad frame count: "..tostring(M.AnimationFrames));
			else
				Info("Starting loop animation ("..tostring(M.AnimationFrames).." frames)");
				M.TestTimeout = GetTime() + 10;
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 3 then
			if M.TestTimeout < GetTime() then
				FailTest("SetAnimation(): loop Animation took too long to finish.");
			elseif GetAnimationFrame(M.Object01, "deploy") == M.AnimationFrames - 1 then
				Info("One cycle completed.");
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 4 then
			if GetAnimationFrame(M.Object01, "deploy") <= 1 then
				FailTest("SetAnimation(): loop animation did not reset after reaching last frame.");
			end
			M.TestTimeout = GetTime() + 10;
			M.TestState = M.TestState + 1;
		elseif M.TestState == 5 then
			if M.TestTimeout < GetTime() then
				FailTest("SetAnimation(): loop Animation took too long to finish.");
			elseif GetAnimationFrame(M.Object01, "deploy") == M.AnimationFrames - 1 then
				RemoveObject(M.Object01);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 1;
			end
		elseif M.TestState == 6 then
			if ClearIdleAnims == nil then
				FailTest("ClearIdleAnims(): function is not defined.");
			elseif AddIdleAnim == nil then
				FailTest("AddIdleAnim(): function is not defined.");
			else
				M.Object01 = BuildObject("mcjak01", 1, M.Navs[1]);
				Info("Setting idle animation 'eat1'...");
				ClearIdleAnims(M.Object01);
				AddIdleAnim(M.Object01, "eat1");
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 5;
			end
		elseif M.TestState == 7 then
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--Spawns a dropship and turns the engines on/off
--Tests MaskEmitter(), StartEmitter(), StopEmitter()
--Note: StartEmitter()/StopEmitter() use 1 based indices.
function Test_Emitters()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			Info("Both engines on");
			M.Object01 = BuildObject("ivpdrop", 1, M.Navs[1]);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 1 then
			Info("Both engines off");
			MaskEmitter(M.Object01, 0);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 2 then
			Info("Right engine on");
			MaskEmitter(M.Object01, 1);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 3 then
			Info("Left engine on");
			MaskEmitter(M.Object01, 2);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 4 then
			Info("Both engines off");
			StopEmitter(M.Object01, 2);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 5 then
			Info("Both engines on");
			StartEmitter(M.Object01, 1);
			StartEmitter(M.Object01, 2);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 6 then
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--Tells a scout to follow a tug
--Tests IsIdle(), IsFollowing(), WhoFollowing(), SetVerbose(), GetCurrentWho()
function Test_IsFollowing()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if IsIdle == nil then
				FailTest("IsIdle(): function not defined.");
			else
				M.Object01 = BuildObject("ivscout", 1, M.Navs[1]);
				M.Object02 = BuildObject("ivtug", 1, M.Navs[2]);
				Follow(M.Object01, M.Object02);
				M.TestState = M.TestState + 1;
			end	
		elseif M.TestState == 1 then
			if IsIdle(M.Object01) then
				FailTest("Follow(): IsIdle returned true after telling scout to follow tug.");
			elseif not IsFollowing(M.Object01) then
				FailTest("Follow(): IsFollowing returned false after telling scout to follow tug.");
			elseif WhoFollowing(M.Object01) ~= M.Object02 then
				FailTest("WhoFollowing() returned wrong handle.");
			elseif GetCurrentWho(M.Object01) ~= M.Object02 then
				FailTest("GetCurrentWho() returned wrong handle.");
			else
				RemoveObject(M.Object01);
				RemoveObject(M.Object02);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 2 then
			if SetVerbose == nil then
				FailTest("SetVerbose(): function not defined.");
			else
				M.Object01 = BuildObject("ivscout", 1, M.Navs[1]);
				SetVerbose(M.Object01, true);
				Info("Following player...");
				Follow(M.Object01, GetPlayerHandle(), 0);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 2;
			end
		elseif M.TestState == 3 then
			if not IsFollowing(M.Object01) then
				FailTest("Follow(player): scout is not following.");
			else
				Stop(M.Object01);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 4 then
			if GetCurrentWho(M.Object01) ~= nil then
				FailTest("GetCurrentWho() did not return nil after Stop()");
			elseif WhoFollowing(M.Object01) ~= nil then
				FailTest("WhoFollowing() did not return nil after Stop()");
			else
				RemoveObject(M.Object01);
				PassTest();
			end
		end
	end
end

--Spawns a prox mine and sets its lifespan to something short and checks to see if it dies.
--Tests GetLifespan(), GetRemainingLifespan(), SetLifespan()
--Note: in GetLifeSpan(), "S" is capitalized while in GetRemainingLifespan(), and SetLifespan() it is lowercase!
function Test_Lifespan()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if GetLifeSpan == nil then
				FailTest("GetLifeSpan(): function not defined.");
			elseif GetRemainingLifespan == nil then
				FailTest("GetRemainingLifespan(): function not defined.");
			elseif SetLifespan == nil then
				FailTest("SetLifespan(): function not defined.");
			else
				M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
				local lifetime = GetLifeSpan(M.Object01);
				if type(lifetime) ~= "number" or lifetime > 0 then
					FailTest("GetLifespan() returned bad result for ivtank: "..tostring(lifetime));
				end
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then
			local lifetime = GetRemainingLifespan(M.Object01);
			if type(lifetime) ~= "number" or lifetime > 0 then
				FailTest("GetRemainingLifespan() returned bad result: "..tostring(lifetime));
			else
				SetLifespan(M.Object01, 0.5);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 2;
			end
		elseif M.TestState == 2 then
			if IsAround(M.Object01) then
				FailTest("SetLifespan(): object is still around after it should have expired.");
			else
				PassTest();
			end
		end
	end
end

--Tests the ODF reading functions by getting a bunch of values from a test ODF
function Test_ODF()
	local ODF_NAME = "lua-api-test";
	local ODF_FILE = ODF_NAME .. ".odf";
	local SECTION = "Section1";
	local BAD_ODF = "sadghagdhaj.xyz";
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if GetODFHexInt == nil then
				FailTest("GetODFHexInt(): function is nil.");
			elseif GetODFInt == nil then
				FailTest("GetODFInt(): function is nil.");
			elseif GetODFLong == nil then
				FailTest("GetODFLong(): function is nil.");
			elseif GetODFFloat == nil then
				FailTest("GetODFFloat(): function is nil.");
			elseif GetODFDouble == nil then
				FailTest("GetODFDouble(): function is nil.");
			elseif GetODFChar == nil then
				FailTest("GetODFChar(): function is nil.");
			elseif GetODFBool == nil then
				FailTest("GetODFBool(): function is nil.");
			elseif GetODFString == nil then
				FailTest("GetODFString(): function is nil.");
			elseif GetODFColor == nil then
				FailTest("GetODFColor(): function is nil.");
			elseif GetODFVector == nil then
				FailTest("GetODFVector(): function is nil.");
			elseif DoesODFExist == nil then
				FailTest("DoesOdfExist(): function is nil.");
			elseif not DoesODFExist(ODF_NAME) then
				FailTest("DoesODFExist(): can't locate file: "..ODF_FILE);
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			local myHexInt, b1 = GetODFHexInt(ODF_FILE, SECTION, "myHexInt");
			local myInt, b2  = GetODFInt(ODF_FILE, SECTION, "myInt");
			local myLong, b3 = GetODFLong(ODF_FILE, SECTION, "myLong");
			local myFloat, b4  = GetODFFloat(ODF_FILE, SECTION, "myFloat");
			local myDouble, b5  = GetODFDouble(ODF_FILE, SECTION, "myDouble");
			local myChar, b6  = GetODFChar(ODF_FILE, SECTION, "myChar");
			local myBool, b7 = GetODFBool(ODF_FILE, SECTION, "myBool");
			local myString, b8 = GetODFString(ODF_FILE, SECTION, "myString");
			local myColor, b9  = GetODFColor(ODF_FILE, SECTION, "myColor");
			local myVector, b10 = GetODFVector(ODF_FILE, SECTION, "myVector");
			
			if type(myHexInt) ~= "number" or myHexInt ~= 43981 then
				FailTest("GetODFHexInt(): expected 43981 but got "..tostring(myHexInt));
			elseif type(myInt) ~= "number" or myInt ~= 1234 then
				FailTest("GetODFInt(): expected 1234 but got "..tostring(myInt));
			elseif type(myLong) ~= "number" or myLong ~= 123 then
				FailTest("GetODFLong(): expected 123 but got "..tostring(myLong));
			elseif type(myFloat) ~= "number" or myFloat ~= 1.5 then
				FailTest("GetODFFloat(): expected 1.5 but got "..tostring(myFloat));
			elseif type(myDouble) ~= "number" or myDouble ~= 2.0 then
				FailTest("GetODFDouble(): expected 2.0 but got "..tostring(myDouble));
			elseif type(myChar) ~= "string" or myChar ~= "k" then
				FailTest("GetODFChar(): expected 'k' but got "..tostring(myChar));
			elseif type(myBool) ~= "boolean" or not myBool then
				FailTest("GetODFBool(): expected true but got "..tostring(myBool));
			elseif type(myString) ~= "string" or myString ~= "hello" then
				FailTest("GetODFString(): expected 'hello' but got "..tostring(myString));
			elseif type(myColor) ~= "number" or myColor ~= 0 then
				FailTest("GetODFColor(): expected 0 but got "..tostring(myColor));
			elseif myVector ~= SetVector(1,0,0) then
				FailTest("GetODFVector(): expected {1,0,0} but got "..tostring(myVector));
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 2 then	--try to read values from a non existant odf. Should return the default values we pass in and not crash.
			local myHexInt, b1 = GetODFHexInt(BAD_ODF, SECTION, "myHexInt", 123);
			local myInt, b2  = GetODFInt(BAD_ODF, SECTION, "myInt", 1234);
			local myLong, b3 = GetODFLong(BAD_ODF, SECTION, "myLong", 12345);
			local myFloat, b4  = GetODFFloat(BAD_ODF, SECTION, "myFloat", 1.0);
			local myDouble, b5  = GetODFDouble(BAD_ODF, SECTION, "myDouble", 2.0);
			local myChar, b6  = GetODFChar(BAD_ODF, SECTION, "myChar", "c");
			local myBool, b7 = GetODFBool(BAD_ODF, SECTION, "myBool", false);
			local myString, b8 = GetODFString(BAD_ODF, SECTION, "myString", "mystring");
			local myColor, b9  = GetODFColor(BAD_ODF, SECTION, "myColor", 789);
			local myVector, b10 = GetODFVector(BAD_ODF, SECTION, "myVector", SetVector(1,0,1));
			
			if type(myHexInt) ~= "number" or myHexInt ~= 123 then
				FailTest("GetODFHexInt(): expected 123 but got "..tostring(myHexInt));
			elseif type(myInt) ~= "number" or myInt ~= 1234 then
				FailTest("GetODFInt(): expected 1234 but got "..tostring(myInt));
			elseif type(myLong) ~= "number" or myLong ~= 12345 then
				FailTest("GetODFLong(): expected 12345 but got "..tostring(myLong));
			elseif type(myFloat) ~= "number" or myFloat ~= 1.0 then
				FailTest("GetODFFloat(): expected 1.0 but got "..tostring(myFloat));
			elseif type(myDouble) ~= "number" or myDouble ~= 2.0 then
				FailTest("GetODFDouble(): expected 2.0 but got "..tostring(myDouble));
			elseif type(myChar) ~= "string" or myChar ~= "c" then
				FailTest("GetODFChar(): expected 'c' but got "..tostring(myChar));
			elseif type(myBool) ~= "boolean" or myBool then
				FailTest("GetODFBool(): expected false but got "..tostring(myBool));
			elseif type(myString) ~= "string" or myString ~= "mystring" then
				FailTest("GetODFString(): expected 'mystring' but got "..tostring(myString));
			elseif type(myColor) ~= "number" or myColor ~= 789 then
				FailTest("GetODFColor(): expected 789 but got "..tostring(myColor));
			elseif myVector ~= SetVector(1,0,1) then
				FailTest("GetODFVector(): expected {1,0,1} but got "..tostring(myVector));
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 3 then
			PassTest();
		end
	end
end

--Tries to load "lua-api-test.txt" (contains "12345")
--Tests DoesFileExist(), LoadFile()
function Test_LoadFile()
	local FILENAME = "lua-api-test.txt";
	if DoesFileExist == nil then
		FailTest("DoesFileExist(): function is nil");
	elseif LoadFile == nil then
		FailTest("LoadFile(): function is nil");
	elseif not DoesFileExist("lua-api-test.txt") then
		FailTest("DoesFileExist(): "..FILENAME.." not found.");
	end
	
	local contents = LoadFile(FILENAME);
	if contents ~= "12345" then
		FailTest("LoadFile(): returned wrong contents. Expected '12345' but got "..tostring(contents));
	else
		PassTest();
	end
end

--Tests WriteToFile()
function Test_WriteFile()
	local FILENAME = "lua-api-test-temp.txt";
	if WriteToFile == nil then
		FailTest("WriteToFile(): function is nil");
	else
		WriteToFile(FILENAME, "123", false);
		if TRY_TO_CRASH then
			WriteToFile(FILENAME, "456", true);	--Crashes BZ2 if WriteToFile() is called twice in a row! Expected behavior is that it appends "456" to existing file contents. 
		end
		if not DoesFileExist(FILENAME) then
			FailTest("WriteToFile() did not create the file.");
		elseif LoadFile(FILENAME) ~= "123456" then
			FailTest();
		else
			PassTest();
		end
	end
end

--Tests GetTRNFilename()
function Test_GetTRNFilename()
	local TRN_FILENAME = "lua-api-test.trn";
	if GetMapTRNFilename == nil then
		FailTest("GetMapTRNFilename(): function is nil");
	elseif GetMapTRNFilename() ~= TRN_FILENAME then
		FailTest("GetMapTRNFilename(): expected "..TRN_FILENAME.." but got ".. tostring(GetMapTRNFilename()));
	else
		PassTest();
	end
end

--Tests GetLabel(), SetLabel()
function Test_GetSetLabel()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if GetLabel == nil then
				FailTest("GetLabel(): function is nil");
			elseif SetLabel == nil then
				FailTest("SetLabel(): function is nil");
			else
				M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
				M.Object02 = BuildObject("ivscout", 1, M.Navs[2]);
				SetLabel(M.Object01, "Object01");
				SetLabel(M.Object02, "Object02");
				SetLabel(nil, "");
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then
			if GetLabel(M.Object01) ~= "Object01" then
				FailTest("GetLabel(): expected 'Object01' but got "..tostring(GetLabel(M.Object01)));
			elseif GetLabel(M.Object02) ~= "Object02" then
				FailTest("GetLabel(): expected 'Object02' but got "..tostring(GetLabel(M.Object02)));
			elseif GetHandle("Object01") ~= M.Object01 then
				FailTest("GetHandle(Object01) returned wrong result");
			elseif GetHandle("Object02") ~= M.Object02 then
				FailTest("GetHandle(Object02) returned wrong result");
			elseif GetLabel(nil) ~= nil then
				FailTest("GetLabel(nil) did not return nil.");
			else
				RemoveObject(M.Object01);
				RemoveObject(M.Object02);
				PassTest();
			end
		end
	end
end

--Builds a gun spire, removes the lung, then replaces it
--tests SetTap(), GetTap()
function Test_SetTap()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			local pos = GetPosition(M.Navs[1]);
			pos.y = TerrainFindFloor(pos);
			pos.z = pos.z + 50;
			M.Object01 = BuildObject("fbspir", 1, BuildDirectionalMatrix(pos));
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			M.Object02 = GetTap(M.Object01, 0);
			if M.Object02 == nil then
				FailTest("GetTap() returned nil for fbspir");
			else
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 1;
			end
		elseif M.TestState == 2 then
			Info("Removing lung...");
			M.Position1 = GetTransform(M.Object02);
			RemoveObject(M.Object02);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 3 then
			if GetTap(M.Object01, 0) ~= nil then
				FailTest("GetTap(): expected nil but got "..tostring(GetTap(M.Object01, 0)));
			end
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 4 then
			Info("Replacing lung...");
			M.Object02 = BuildObject("fblung", 1, M.Position1);
			SetTap(M.Object01, 0, M.Object02);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 5 then
			if GetTap(M.Object01, 0) ~= M.Object02 then
				FailTest("SetTap() did not set the new tap");
			else
				--RemoveObject(M.Object02);	--not necessary
				RemoveObject(M.Object01);
				M.TestState = M.TestState + 1;
				PassTest();
			end
		end
	end
end

--Spawns an ivtank and fvscout and swaps the pilot races
--Tests GetRace(), AddPilotByHandle(), SetPilotClass(), GetPilotClass()
function Test_Race()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if GetRace == nil then
				FailTest("GetRace(): function not defined.");
			elseif AddPilotByHandle == nil then
				FailTest("AddPilotByHandle(): function not defined.");
			elseif GetPilotClass == nil then
				FailTest("GetPilotClass(): function not defined.");
			elseif SetPilotClass == nil then
				FailTest("SetPilotClass(): function not defined.");
			else
				M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
				M.Object02 = BuildObject("fvscout", 1, M.Navs[2]);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then
			if GetRace(M.Object01) ~= "i" then
				FailTest("GetRace(ivtank): expected 'i' but got "..tostring(GetRace(M.Object01)));
			elseif GetRace(M.Object02) ~= "f" then
				FailTest("GetRace(ivtank): expected 'f' but got "..tostring(GetRace(M.Object02)));
			elseif GetRace(nil) ~= nil then
				FailTest("GetRace(nil): expected nil but got "..tostring(GetRace(nil)));
			elseif GetPilotClass(M.Object01) ~= "ispilo.odf" then
				FailTest("GetPilotClass(ivtank): expected 'ispilo.odf' but got "..GetPilotClass(M.Object01));
			elseif GetPilotClass(M.Object02) ~= "fspilo.odf" then
				FailTest("GetPilotClass(fvscout): expected 'fspilo.odf' but got "..GetPilotClass(M.Object02));
			elseif GetPilotClass(nil) ~= nil then
				FailTest("GetPilotClass(nil): expected nil but got "..GetPilotClass(nil));
			else
				KillPilot(M.Object01);
				KillPilot(M.Object01);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 2 then
			AddPilotByHandle(M.Object01);
			AddPilotByHandle(M.Object02);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 3 then
			if not HasPilot(M.Object01) or not HasPilot(M.Object02) then
				FailTest("AddPilotByHandle(): the target object did not get a pilot");
			elseif GetPilotClass(M.Object01) ~= "ispilo.odf" then
				FailTest("AddPilotByHandle(ivtank): expected 'ispilo.odf' but got "..GetPilotClass(M.Object01));
			elseif GetPilotClass(M.Object02) ~= "fspilo.odf" then
				FailTest("AddPilotByHandle(fvscout): expected 'fspilo.odf' but got "..GetPilotClass(M.Object02));
			else
				KillPilot(M.Object01);
				KillPilot(M.Object01);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 4 then	--make ivtank have scion pilot and vice versa for scion scout
			SetPilotClass(M.Object01, "fspilo");
			AddPilotByHandle(M.Object01);
			SetPilotClass(M.Object02, "ispilo");
			AddPilotByHandle(M.Object02);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 5 then
			if not HasPilot(M.Object01) or not HasPilot(M.Object02) then
				FailTest("AddPilotByHandle(): the target object did not get a pilot after SetPilotClass()");
			elseif GetPilotClass(M.Object01) ~= "fspilo.odf" then
				FailTest("SetPilotClass(ivtank): expected 'fspilo.odf' but got "..GetPilotClass(M.Object01));
			elseif GetPilotClass(M.Object02) ~= "ispilo.odf" then
				FailTest("SetPilotClass(fvscout): expected 'ispilo.odf' but got "..GetPilotClass(M.Object02));
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 6 then
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			PassTest();
		end
	end
end

--Starts an earthquake, updates the magnitude, then stops the earthquake.
--Tests StartEarthQuake(), UpdateEarthQuake(), StopEarthQuake()
function Test_EarthQuake()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			Info("Starting earthquake with magnitude 1.0");
			StartEarthQuake(1.0);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 1 then
			UpdateEarthQuake(10.0);
			Info("Updating earthquake to magnitude 10.0");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 2 then
			UpdateEarthQuake(100.0);
			Info("Updating earthquake to magnitude 100.0");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 3 then
			Info("Stopping earthquake.");
			StopEarthQuake();
			PassTest();
		end
	end
end

--Tests SetNoScrapFlagByHandle(), ClearNoScrapFlagByHandle(), SelfDamage()
function Test_NoScrapFlag()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if SetNoScrapFlagByHandle == nil then
				FailTest("SetNoScrapFlagByHandle(): function is not defined.");
			elseif ClearNoScrapFlagByHandle == nil then
				FailTest("ClearNoScrapFlagByHandle(): function is not defined.");
			else
				M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
				M.Object02 = BuildObject("fvtank", 1, M.Navs[2]);
				RemovePilot(M.Object01);
				RemovePilot(M.Object02);
				SetNoScrapFlagByHandle(M.Object01);
				SetNoScrapFlagByHandle(M.Object02);
				M.TestState = M.TestState + 1;
			end	
		elseif M.TestState == 1 then
			Info("ivtank should not drop scrap. fvtank should drop scrap.");
			ClearNoScrapFlagByHandle(M.Object02);
			SelfDamage(M.Object01, 9999);
			SelfDamage(M.Object02, 9999);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 2 then
			PassTest();		
		end
	end
end

--TODO: TranslateString() parameter list doesn't make sense in lua. TODO: Fix in C++.
--function Test_TranslateString()
--	TranslateString(buf,bufSize,key)
--end

--Tests SetGravity(). The default value is 12.5
function Test_Gravity()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if SetGravity == nil then
				FailTest("SetGravity(): function not defined.");
			else
				Info("Setting gravity to 999.0");
				SetGravity(999.0);
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 5;
			end
		elseif M.TestState == 1 then
			Info("Setting gravity to 0.5");
			SetGravity(0.5);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 5;
		elseif M.TestState == 2 then
			Info("Resetting gravity to default");
			SetGravity();	--should reset gravity to default
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 3 then
			PassTest();
		end
	end
end

--Spawns 4 objects: ivtank, ispilo, fbjamm, and apchain and tests the identity functions on them
--Tests IsCraftButNotPerson(), IsCraftOrPerson(), IsBuilding(), IsPowerup()
function Test_Identity()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if IsCraftButNotPerson == nil then
				FailTest("IsCraftButNotPerson(): function not defined");
			elseif IsCraftOrPerson == nil then
				FailTest("IsCraftOrPerson(): function not defined");
			elseif IsBuilding == nil then
				FailTest("IsBuilding(): function not defined");
			elseif IsPowerup == nil then
				FailTest("IsPowerup(): function not defined");
			else
				M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
				M.Object02 = BuildObject("ispilo", 1, M.Navs[2]);
				M.Object03 = BuildObject("fbjamm", 1, M.Navs[3]);
				M.Object04 = BuildObject("apchain", 0, M.Navs[4]);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then
			if not IsCraftButNotPerson(M.Object01) then
				FailTest("IsCraftButNotPerson() returned false for ivtank");
			elseif IsCraftButNotPerson(M.Object02) then
				FailTest("IsCraftButNotPerson() returned true for ispilo");
			elseif IsCraftButNotPerson(M.Object03) then
				FailTest("IsCraftButNotPerson() returned true for fbjamm");
			elseif IsCraftButNotPerson(M.Object04) then
				FailTest("IsCraftButNotPerson() returned true for apchain");
			elseif not IsCraftOrPerson(M.Object01) then
				FailTest("IsCraftOrPerson() returned false for ivtank");
			elseif not IsCraftOrPerson(M.Object02) then
				FailTest("IsCraftOrPerson() returned false for ispilo");
			elseif IsCraftOrPerson(M.Object03) then
				FailTest("IsCraftOrPerson() returned true for fbjamm");
			elseif IsCraftOrPerson(M.Object04) then
				FailTest("IsCraftOrPerson() returned true for apchain");
			elseif IsBuilding(M.Object01) then
				FailTest("IsBuilding() returned true for ivtank");
			elseif IsBuilding(M.Object02) then
				FailTest("IsBuilding() returned true for ispilo");
			elseif not IsBuilding(M.Object03) then
				FailTest("IsBuilding() returned false for fbjamm");
			elseif IsBuilding(M.Object04) then
				FailTest("IsBuilding() returned true for apchain");
			elseif IsPowerup(M.Object01) then
				FailTest("IsPowerup() returned true for ivtank");
			elseif IsPowerup(M.Object02) then
				FailTest("IsPowerup() returned true for ispilo");
			elseif IsPowerup(M.Object03) then
				FailTest("IsPowerup() returned true for fbjamm");
			elseif not IsPowerup(M.Object04) then
				FailTest("IsPowerup() returned false for apchain");
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 2 then
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			RemoveObject(M.Object03);
			RemoveObject(M.Object04);
			PassTest();
		end
	end
end

--Completely locks up BZ2
--Don't call this unless you want to hang the game
function Test_HangBZ2()
	Info("Hanging BZ2...");
	while(true) do
		PrintConsoleMessage("Hanging BZ2...");
	end
end

--Spawns 2 tanks 100m away from the player, and 2 more 300m away. 
--CountThreats() should return 2 for 'here', and 2 for 'coming'
--Tests CountThreats()
function Test_CountThreats()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if CountThreats == nil then
				FailTest("CountThreats(): function not defined");
			else
				local pos = GetPosition(GetPlayerHandle());
				pos.z = pos.z + 100;
				M.Object01 = BuildObject("ivtank", 2, pos);
				M.Object02 = BuildObject("ivtank", 2, pos);
				pos.z = pos.z + 200;
				M.Object03 = BuildObject("ivtank", 2, pos);
				M.Object04 = BuildObject("ivtank", 2, pos);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then
			local here, coming = CountThreats(GetPlayerHandle(), 200);
			if type(here) ~= "number" or type(coming) ~= "number" then
				FailTest("CountThreats() did not return a number");
			elseif here < 2 then
				FailTest("CountThreats(): 'here': expected at least 2 but got "..tostring(here));
			elseif coming < 2 then
				FailTest("CountThreats(): 'coming': expected at least 2 but got "..tostring(coming));
			else
				RemoveObject(M.Object01);
				RemoveObject(M.Object02);
				RemoveObject(M.Object03);
				RemoveObject(M.Object04);
				PassTest();
			end
		end
	end
end

--Tests AddCurLocalAmmo(), GetCurLocalAmmo(), SetCurLocalAmmo(), GetMaxLocalAmmo()
function Test_LocalAmmo()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			if GetCurLocalAmmo == nil then
				FailTest("GetCurLocalAmmo(): function is not defined");
			elseif AddLocalAmmo == nil then
				FailTest("AddCurLocalAmmo(): function is not defined");
			elseif GetMaxLocalAmmo == nil then
				FailTest("GetMaxLocalAmmo(): function is not defined");
			elseif SetCurLocalAmmo == nil then
				FailTest("GetMaxLocalAmmo(): function is not defined");
			end
			M.Object01 = BuildObject("ispilo", 1, M.Navs[1]);
			GiveWeapon(M.Object01, "igjetp");
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then	
			if GetCurLocalAmmo(M.Object01, 2) ~= 1 then
				FailTest("GetCurLocalAmmo(): expected 1 but got "..tostring(GetCurLocalAmmo(M.Object01, 2)));
			elseif GetMaxLocalAmmo(M.Object01, 2) ~= 1 then
				FailTest("GetMaxLocalAmmo(): expected 1 but got "..tostring(GetMaxLocalAmmo(M.Object01, 2)));
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 2 then
			AddLocalAmmo(M.Object01, -1, 2);
			if GetCurLocalAmmo(M.Object01, 2) ~= 0 then
				FailTest("AddCurLocalAmmo(): expected 0 but got "..tostring(GetCurLocalAmmo(M.Object01, 2)));
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 3 then
			SetCurLocalAmmo(M.Object01, 1, 2);
			if GetCurLocalAmmo(M.Object01, 2) ~= 1 then
				FailTest("SetCurLocalAmmo(): expected 1 but got "..tostring(GetCurLocalAmmo(M.Object01, 2)));
			else
				RemoveObject(M.Object01);
				PassTest();
			end
		end
	end
end

--Tests GetOwner(), GetTap() TODO: SetOwner()
--Note: GetOwner() only works for a few units and buildings. For most units it will simply return the same handle passed in.
--not sure how to test SetOwner(). Need to find a situation that it would be used in...
function Test_SetOwner()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			local pos = GetPosition(M.Navs[1]);
			pos.y = TerrainFindFloor(pos);
			M.Object01 = BuildObject("fbspir", 1, BuildDirectionalMatrix(pos));
			M.Object02 = GetTap(M.Object01, 0);
			if GetOwner(M.Object02) ~= M.Object01 then
				FailTest("GetOwner(): expected "..tostring(M.Object01).." but got "..tostring(GetOwner(M.Object02)))
			end
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--Tests ally funcs 
--Tests GetTeamNum(), SetTeamNum(), Ally(), UnAlly(), GetTeamRelationship(), IsAlly()
function Test_Ally()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			M.Object02 = BuildObject("fvtank", 1, M.Navs[2]);
			M.Object03 = BuildObject("ivatank", 3, M.Navs[3]);
			SetTeamNum(M.Object02, 2);
			if GetTeamNum(M.Object02) ~= 2 then
				FailTest("GetTeamNum(): expected 2 but got "..tostring(GetTeamNum(M.Object02)));
			else
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 1 then
			Ally(1,3);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 2 then
			if not IsTeamAllied(1, 3) then
				FailTest("IsTeamAllied(1,3): expected false but got "..tostring(IsTeamAllied(1, 3)));
			elseif IsTeamAllied(1, 2) then
				FailTest("IsTeamAllied(1,2): expected true but got "..tostring(IsTeamAllied(1, 2)));
			elseif not IsAlly(M.Object01, M.Object03) then
				FailTest("IsAlly(Object01,Object03): expected true but got "..tostring(IsAlly(M.Object01, M.Object03)));
			elseif IsAlly(M.Object01, M.Object02) then
				FailTest("IsAlly(Object01,Object02): expected false but got "..tostring(IsAlly(M.Object01, M.Object02)));
			else
				UnAlly(1,3);
				RemoveObject(M.Object01);
				RemoveObject(M.Object02);
				RemoveObject(M.Object03);
				PassTest();
			end
		end
	end
end

--Tests GetScavengerCurScrap(), GetScavengerMaxScrap(), SetScavengerCurScrap(), SetScavengerMaxScrap()
function Test_Scavenger()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ivscav", 1, M.Navs[1]);
			M.TestState = M.TestState + 1;
		elseif M.TestState == 1 then
			if GetScavengerCurScrap(M.Object01) ~= 0 then
				FailTest("GetScavengerCurScrap(): expected 0 but got "..tostring(GetScavengerCurScrap(M.Object01)));
			elseif GetScavengerMaxScrap(M.Object01) ~= 20 then
				FailTest("GetScavengerMaxScrap(): expected 20 but got "..tostring(GetScavengerMaxScrap(M.Object01)));
			else
				SetScavengerMaxScrap(M.Object01, 100);
				SetScavengerCurScrap(M.Object01, 50);
				M.TestState = M.TestState + 1;
			end
		elseif M.TestState == 2 then
			if GetScavengerCurScrap(M.Object01) ~= 50 then
				FailTest("GetScavengerCurScrap(): expected 50 but got "..tostring(GetScavengerCurScrap(M.Object01)));
			elseif GetScavengerMaxScrap(M.Object01) ~= 100 then
				FailTest("GetScavengerMaxScrap(): expected 100 but got "..tostring(GetScavengerMaxScrap(M.Object01)));
			else
				RemoveObject(M.Object01);
				PassTest();
			end
		end
	end
end

--Tests SecondsToTurns(), TurnsToSeconds(), GetTimeStep()
function Test_TPS()
	print("TPS="..tostring(M.TPS));
	if not type(M.TPS) == "number" or M.TPS == 0 then
		FailTest("Variable 'M.TPS' has bad value: "..tostring(M.TPS));
	elseif SecondsToTurns(3) ~= 3*M.TPS then
		FailTest("SecondsToTurns(3): expected "..tostring(3*M.TPS).." but got "..tostring(SecondsToTurns(3)));
	elseif(TurnsToSeconds(30)) ~= 30/M.TPS then
		FailTest("TurnsToSeconds(30): expected "..tostring(30/M.TPS).." but got "..tostring(SecondsToTurns(30)));
	elseif math.abs(GetTimeStep() - 1/M.TPS) > 0.0001 then
		FailTest("GetTimeStep(): expected "..tostring(1/M.TPS).." but got "..tostring(GetTimeStep()));
	else
		PassTest();
	end
end

--Tests SetAsUser()
function Test_SetAsUser()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			Info("Switching player to fvtank");
			M.Object01 = BuildObject("fvtank", 1, M.Navs[1]);
			M.OldHandle = GetPlayerHandle();
			SetAsUser(M.Object01, 1);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 2;
		elseif M.TestState == 1 then		
			if GetPlayerHandle() ~= M.Object01 then
				FailTest("SetAsUser(): did not swap player");
			else
				Info("Switching back");
				SetAsUser(M.OldHandle, 1);
				RemoveObject(M.Object01);
				PassTest();
			end
			
		end
	end
end

--Tests GetCfg, GetOdf, GetBase, GetClassSig, GetClassLabel, DoesODFExist
function Test_GetOdf()
	if M.TestState == 0 then
		M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
		M.Object02 = BuildObject("ivtank4", 1, M.Navs[2]);
		if GetOdf(M.Object01) ~= "ivtank.odf" then
			FailTest("GetOdf(Object01): expected 'ivtank.odf' but got "..tostring(GetOdf(M.Object01)));
		elseif GetOdf(M.Object02) ~= "ivtank4.odf" then
			FailTest("GetOdf(Object02): expected 'ivtank4.odf' but got "..tostring(GetOdf(M.Object02)));
		elseif GetCfg(M.Object01) ~= "ivtank" then
			FailTest("GetCfg(Object01): expected 'ivtank' but got "..tostring(GetCfg(M.Object01)));
		elseif GetCfg(M.Object02) ~= "ivtank4" then
			FailTest("GetCfg(Object02): expected 'ivtank4' but got "..tostring(GetCfg(M.Object02)));
		elseif GetBase(M.Object01) ~= "ivtank" then
			FailTest("GetBase(Object01): expected 'ivtank' but got "..tostring(GetBase(M.Object01)));
		elseif GetBase(M.Object02) ~= "ivtank" then
			FailTest("GetBase(Object02): expected 'ivtank' but got "..tostring(GetBase(M.Object02)));
		elseif GetClassSig(M.Object01) ~= "CLASS_ID_CRAFT" then
			FailTest("GetClassSig(Object01): expected 'CLASS_ID_CRAFT' but got "..tostring(GetClassSig(M.Object01)));
		elseif GetClassLabel(M.Object01) ~= "CLASS_WINGMAN" then
			FailTest("GetClassSig(Object01): expected 'CLASS_WINGMAN' but got "..tostring(GetClassLabel(M.Object01)));
		elseif not DoesODFExist("ivtank") then
			FailTest("DoesODFExist() returned false for 'ivtank'");
		elseif DoesODFExist("xxxxxxxxx") then
			FailTest("DoesODFExist(xxxxxxxxx) returned true.");
		else
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		RemoveObject(M.Object01);
		RemoveObject(M.Object02);
		PassTest();
	end
end

--Tests GetWeaponConfig, GetWeaponODF, GetWeaponGOClass,
function Test_WeaponConfig()
	if M.TestState == 0 then
		M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
		if GetWeaponConfig(M.Object01) ~= "gatstab_c" then
			FailTest("GetWeaponConfig(): expected 'gatstab_c' but got "..tostring(GetWeaponConfig(M.Object01)));
		elseif GetWeaponConfig(M.Object01, 1) ~= "gminigun_c" then
			FailTest("GetWeaponConfig(): expected 'gminigun_c' but got "..tostring(GetWeaponConfig(M.Object01, 1)));
		elseif GetWeaponODF(M.Object01) ~= "gatstab_c.odf" then
			FailTest("GetWeaponODF(): expected 'gatstab_c.odf' but got "..tostring(GetWeaponODF(M.Object01)));
		elseif GetWeaponODF(M.Object01, 1) ~= "gminigun_c.odf" then
			FailTest("GetWeaponODF(): expected 'gminigun_c.odf' but got "..tostring(GetWeaponODF(M.Object01, 1)));
		elseif GetWeaponGOClass(M.Object01) ~= "CLASS_CANNON" then
			FailTest("GetWeaponGOClass(): expected 'CLASS_CANNON' but got "..tostring(GetWeaponGOClass(M.Object01)));
		elseif GetWeaponGOClass(M.Object01, 1) ~= "CLASS_CANNON_MACHINEGUN" then
			FailTest("GetWeaponGOClass(): expected 'CLASS_CANNON_MACHINEGUN' but got "..tostring(GetWeaponGOClass(M.Object01, 1)));
		else
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		RemoveObject(M.Object01);
		PassTest();
	end
end

--Tests SetCanSnipe(), GetCanSnipe()
function Test_CanSnipe()
	if M.TestState == 0 then
		M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
		if not GetCanSnipe(M.Object01) then
			FailTest("GetCanSnipe(): expected true but got "..tostring(GetCanSnipe(M.Object01)));
		else
			SetCanSnipe(M.Object01, 0);
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		if GetCanSnipe(M.Object01) then
			FailTest("GetCanSnipe(): expected false but got "..tostring(GetCanSnipe(M.Object01)));
		else
			SetCanSnipe(M.Object01, -1);
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 2 then
		if not GetCanSnipe(M.Object01) then
			FailTest("GetCanSnipe(): expected true but got "..tostring(GetCanSnipe(M.Object01)));
		else
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--Tests GetRecyclerHandle(), GetFactoryHandle(), GetArmoryHandle()
function Test_GetRecyclerHandle()
	if M.TestState == 0 then
		if GetRecyclerHandle(1) ~= nil then
			FailTest("GetRecyclerHandle(1): expected nil, but got "..tostring(GetRecyclerHandle(1)));
		elseif GetFactoryHandle(1) ~= nil then
			FailTest("GetFactoryHandle(1): expected nil, but got "..tostring(GetFactoryHandle(1)));
		elseif GetArmoryHandle(1) ~= nil then
			FailTest("GetArmoryHandle(1): expected nil, but got "..tostring(GetArmoryHandle(1)));
		else
			local pos1 = GetPosition(M.Navs[1]);
			local pos2 = GetPosition(M.Navs[2]);
			local pos3 = GetPosition(M.Navs[3]);
			pos1.y = 0;
			pos2.y = 0;
			pos3.y = 0;
			M.Object01 = BuildObject("ibrecy", 1, BuildDirectionalMatrix(pos1));
			M.Object02 = BuildObject("ibfact", 1, BuildDirectionalMatrix(pos2));
			M.Object03 = BuildObject("ibarmo", 1, BuildDirectionalMatrix(pos3));
			M.TestState = M.TestState + 1;
		end	
	elseif M.TestState == 1 then
		if GetRecyclerHandle(1) ~= M.Object01 then
			FailTest("GetRecyclerHandle(1): expected "..tostring(M.Object01).." but got "..tostring(GetRecyclerHandle(1)));
		elseif GetFactoryHandle(1) ~= M.Object02 then
			FailTest("GetRecyclerHandle(1): expected "..tostring(M.Object02).." but got "..tostring(GetFactoryHandle(1)));
		elseif GetArmoryHandle(1) ~= M.Object03 then
			FailTest("GetArmoryHandle(1): expected "..tostring(M.Object03).." but got "..tostring(GetArmoryHandle(1)));
		else
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			RemoveObject(M.Object03);
			PassTest();
		end
	end
end

--Tests GetPositionNear(), BuildEmptyCraftNear(), GetCircularPos()
function Test_GetPositionNear()
	if M.TestState == 0 then
		local p1 = GetPositionNear(M.Navs[1], 5, 10);
		local p2 = GetPositionNear("nav_path", 0, 5, 10);
		local p3 = GetPositionNear(GetPosition(M.Navs[1]), 5, 10);
		local p4 = GetPositionNear(GetTransform(M.Navs[1]), 5, 10);
		local p5 = GetPositionNear(nil);
		local v1 = p1 - GetPosition(M.Navs[1]);
		local v2 = p2 - GetPosition(M.Navs[1]);
		local v3 = p3 - GetPosition(M.Navs[1]);
		local v4 = p4 - GetPosition(M.Navs[1]);	
		local d1 = math.sqrt(v1.x*v1.x + v1.z*v1.z);
		local d2 = math.sqrt(v2.x*v2.x + v2.z*v2.z);
		local d3 = math.sqrt(v3.x*v3.x + v3.z*v3.z);
		local d4 = math.sqrt(v4.x*v4.x + v4.z*v4.z);
		
		if d1 < 5 or d1 > 10 then
			FailTest("GetPositionNear(<handle>): point returned was outside the radius requested{5,10}. d="..tostring(d1));
		elseif d2 < 2 or d2 > 13 then	--allow some more slack, since path is not perfectly lined up with nav
			FailTest("GetPositionNear(<path>): point returned was outside the radius requested {5,10}. d="..tostring(d2));
		elseif d3 < 5 or d3 > 10 then
			FailTest("GetPositionNear(<vector>): point returned was outside the radius requested {5,10}. d="..tostring(d3));
		elseif d4 < 5 or d4 > 10 then
			FailTest("GetPositionNear(<matrix>): point returned was outside the radius requested{5,10}. d="..tostring(d4));
		--elseif p5 ~= nil then	--GetPositionNear(nil) returns 0 vector, but maybe it should return nil or throw error?
		--	FailTest("GetPositionNear(nil): expected nil but got "..tostring(p5));
		else
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		M.Object01 = BuildEmptyCraftNear(M.Navs[1], "ivtank", 1, 5, 10);
		if not IsAround(M.Object01) then
			FailTest("BuildEmptyCraftNear(): failed to build object.");
		elseif GetCfg(M.Object01) ~= "ivtank" then
			FailTest("BuildEmptyCraftNear(): expected ivtank but got "..tostring(GetCfg(M.Object01)));
		else
			local v = GetPosition(M.Object01) - GetPosition(M.Navs[1]);
			local d = math.sqrt(v.x*v.x + v.z*v.z);
			if d < 5 or d > 10 then
				FailTest("BuildEmptyCraftNear(): craft was placed outside the radius requested");
			else
				M.TestState = M.TestState + 1;
			end
		end
	elseif M.TestState == 2 then
		RemoveObject(M.Object01);
		local p1 = GetCircularPos(GetPosition(M.Navs[1]), 25, 0);	--east
		local p2 = GetCircularPos(GetPosition(M.Navs[1]), 25, math.pi/4);	--NE
		local p3 = GetCircularPos(GetPosition(M.Navs[1]), 25, math.pi);	--west
		local p4 = GetCircularPos(GetPosition(M.Navs[1]), 25, 3*math.pi/2);--south
		local e1 = GetPosition(M.Navs[1]) + SetVector(25,0,0);
		local e2 = GetPosition(M.Navs[1]) + SetVector(25*math.sqrt(2)/2,0,25*math.sqrt(2)/2);
		local e3 = GetPosition(M.Navs[1]) + SetVector(-25,0,0);
		local e4 = GetPosition(M.Navs[1]) + SetVector(0,0,-25);
		local d1 = Distance2D(p1,e1);
		local d2 = Distance2D(p2,e2);
		local d3 = Distance2D(p3,e3);
		local d4 = Distance2D(p4,e4);
		if d1 > 0.001 then
			FailTest("GetCircularPos(p1): expected "..tostring(e1).." but got "..tostring(p1));
		elseif d2 > 0.001 then
			FailTest("GetCircularPos(p2): expected "..tostring(e2).." but got "..tostring(p2));
		elseif d3 > 0.001 then
			FailTest("GetCircularPos(p3): expected "..tostring(e3).." but got "..tostring(p3));
		elseif d4 > 0.001 then
			FailTest("GetCircularPos(p4): expected "..tostring(e4).." but got "..tostring(p4));
		else
			PassTest();
		end
	end
end

--Tests GetBaseScrapCost(), GetActualScrapCost()
function Test_ScrapCost()
	if M.TestState == 0 then
		M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
		M.Object02 = BuildObject("ispilo", 1, M.Navs[2]);
		M.Object03 = BuildObject("apserv", 1, M.Navs[3]);
		if GetBaseScrapCost(M.Object01) ~= 55 then
			FailTest("GetBaseScrapCost(ivtank): expected 55 but got "..tostring(GetBaseScrapCost(M.Object01)));
		elseif GetActualScrapCost(M.Object01) ~= 55 then
			FailTest("GetActualScrapCost(ivtank): expected 55 but got "..tostring(GetActualScrapCost(M.Object01)));
		elseif GetBaseScrapCost(M.Object02) ~= 0 then
			FailTest("GetBaseScrapCost(ispilo): expected 0 but got "..tostring(GetBaseScrapCost(M.Object02)));
		elseif GetActualScrapCost(M.Object02) ~= 0 then
			FailTest("GetActualScrapCost(ispilo): expected 0 but got "..tostring(GetActualScrapCost(M.Object02)));
		elseif GetBaseScrapCost(M.Object03) ~= 2 then
			FailTest("GetBaseScrapCost(apserv): expected 2 but got "..tostring(GetBaseScrapCost(M.Object03)));
		elseif GetActualScrapCost(M.Object03) ~= 2 then
			FailTest("GetActualScrapCost(apserv): expected 2 but got "..tostring(GetActualScrapCost(M.Object03)));
		else
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		RemoveObject(M.Object01);
		RemoveObject(M.Object02);
		RemoveObject(M.Object03);
		PassTest();
	end
end

--Tests SetBestGroup(), GetGroup(), SetGroup(), GetGroupCount(), GetFirstEmptyGroup()
function Test_Groups()
	if M.TestState == 0 then
		if GetFirstEmptyGroup(1) ~= 0 then
			FailTest("GetFirstEmptyGroup(): expected 0 but got "..tostring(GetFirstEmptyGroup(1)));
		else
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			M.Object02 = BuildObject("ivtank", 1, M.Navs[1]);
			M.Object03 = BuildObject("ivtank", 1, M.Navs[1]);
			SetBestGroup(M.Object01);
			SetGroup(M.Object02, 1);
			SetGroup(M.Object03, 1);
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		if GetGroup(M.Object01) ~= 0 then
			FailTest("GetGroup(Object01): expected 0 but got "..tostring(GetGroup(M.Object01)));
		elseif GetGroup(M.Object02) ~= 1 or GetGroup(M.Object03) ~= 1 then
			FailTest("GetGroup(Object02): expected 1 but got "..GetGroup(M.Object02));
		elseif GetGroupCount(1, 1) ~= 2 then
			FailTest("GetGroupCount(1,1): expected 2 but got "..tostring(GetGroupCount(1, 1)));
		else
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			RemoveObject(M.Object03);
			PassTest();
		end
	end
end

--Tests GetGroup() (alternate version), GetGroupCount()
--GetGroup (int Team, int Group, int ObjectType)
--int ObjectType { 0:Get_CFG, 1:Get_ODF, 2:GetGOClass_gCfg }
function Test_GetGroup2()
	if M.TestState == 0 then
		M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
		M.Object02 = BuildObject("ivtank", 1, M.Navs[2]);
		SetGroup(M.Object01, 1);
		SetGroup(M.Object02, 1);
		M.TestState = M.TestState + 1;
	elseif M.TestState == 1 then
		if GetGroup(1, 1, 0) ~= "ivtank" then
			FailTest("GetGroup(1,1,0): expected 'ivtank' but got "..tostring(GetGroup(1, 1, 0)));
		elseif GetGroup(1, 1, 1) ~= "ivtank.odf" then
			FailTest("GetGroup(1,1,1): expected 'ivtank' but got "..tostring(GetGroup(1, 1, 1)));
		elseif GetGroup(1, 1, 2) ~= "ivtank" then
			FailTest("GetGroup(1,1,2): expected 'ivtank' but got "..tostring(GetGroup(1, 1, 2)));
		elseif GetGroup(1,9,0) ~= "" then
			FailTest("GetGroup(1,9,0): expected '' but got "..tostring(GetGroup(1, 9, 0)));
		elseif GetGroupCount(1,1) ~= 2 then
			FailTest("GetGroupCount(): expected 2 but got "..tostring(GetGroupCount(1,1)));
		else
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			PassTest();
		end
	end
end

--Spawns 2 ivtanks, 1 inside and 1 outside the area enclosed by "nav_path"
--The winding number for the inside tank should be non zero and the outside one should be 0
--Tests IsInsideArea(), GetWindingNumber()
function Test_IsInsideArea()
	if M.TestState == 0 then
		local posInside = GetPosition(M.Navs[1]) + SetVector(0,0,50);
		local posOutside = GetPosition(M.Navs[1]) + SetVector(0,0,-50);
		M.Object01 = BuildObject("ivtank", 1, posInside);
		M.Object02 = BuildObject("ivtank", 1, posOutside);
		M.TestState = M.TestState + 1;
	elseif M.TestState == 1 then
		if not IsInsideArea("nav_path", M.Object01) then
			FailTest("IsWithin(Object01): expected true but got "..tostring(IsInsideArea("nav_path", M.Object01)));
		elseif IsInsideArea("nav_path", M.Object02) then
			FailTest("IsWithin(Object02): expected false but got "..tostring(IsInsideArea("nav_path", M.Object02)));
		elseif not IsInsideArea("nav_path", GetPosition(M.Object01)) then
			FailTest("IsWithin(<vector>): expected true but got "..tostring(IsInsideArea("nav_path", GetPosition(M.Object01))));
		elseif IsInsideArea("nav_path", GetPosition(M.Object02)) then
			FailTest("IsWithin(<vector>): expected false but got "..tostring(IsInsideArea("nav_path", GetPosition(M.Object02))));
		elseif not IsInsideArea("nav_path", GetTransform(M.Object01)) then
			FailTest("IsWithin(<matrix>): expected true but got "..tostring(IsInsideArea("nav_path", GetTransform(M.Object01))));
		elseif IsInsideArea("nav_path", GetTransform(M.Object02)) then
			FailTest("IsWithin(<matrix>): expected false but got "..tostring(IsInsideArea("nav_path", GetTransform(M.Object02))));
		elseif GetWindingNumber("nav_path", M.Object01) == 0 then
			FailTest("GetWindingNumber(Object01): expected nonzero but got 0");
		elseif GetWindingNumber("nav_path", M.Object02) ~= 0 then
			FailTest("GetWindingNumber(Object01): expected 0 but got "..tostring(GetWindingNumber("nav_path", M.Object02)));
		elseif GetWindingNumber("nav_path", GetPosition(M.Object01)) == 0 then
			FailTest("GetWindingNumber(<vector>): expected nonzero but got 0");
		elseif GetWindingNumber("nav_path", GetPosition(M.Object02)) ~= 0 then
			FailTest("GetWindingNumber(<vector>): expected 0 but got "..tostring(GetWindingNumber("nav_path", GetPosition(M.Object02))));
		elseif GetWindingNumber("nav_path", GetTransform(M.Object01)) == 0 then
			FailTest("GetWindingNumber(<matrix>): expected nonzero but got 0");
		elseif GetWindingNumber("nav_path", GetTransform(M.Object02)) ~= 0 then
			FailTest("GetWindingNumber(<matrix>): expected 0 but got "..tostring(GetWindingNumber("nav_path", GetTransform(M.Object02))));
		else
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			PassTest();
		end
	end
end

--Tests ClearTeamColors(), DefaultTeamColors(), TeamplayTeamColors(), SetTeamColor(), ClearTeamColor(), SetTeamColors()
--SetFFATeamColors(), GetFFATeamColor(), GetFFATeamColorVector(), GetTeamColorsAreFFA(), 
--SetTeamStratColors(), GetTeamStratColor(), GetTeamStratColorVector(), SwapTeamStratColors(), GetTeamStratIndividualColor()
function Test_TeamColors()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			M.Object01 = BuildObject("ivscav", 1, M.Navs[1]);
			M.Object02 = BuildObject("ivscav", 2, M.Navs[2]);
			Info("Clearing team colors");
			ClearTeamColors();
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 1 then
			Info("Default team colors");
			DefaultTeamColors();
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 2 then
			Info("Teamplay team colors");
			TeamplayTeamColors();
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 3 then
			Info("Setting team 1 to red, team 2 to green");
			SetTeamColor(1, 255,0,0);
			SetTeamColor(2, SetVector(0,255,0));
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 4 then
			Info("Clearing team color for 1,2");
			ClearTeamColor(1);
			ClearTeamColor(2);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 5 then
			SetFFATeamColors(0);
			Info("Setting FFA team colors (1:"..tostring(GetFFATeamColorVector(0,1))..") (2:"..tostring(GetFFATeamColorVector(0,2))..")");
			local r1,g1,b1 = GetFFATeamColor(0, 1);
			local r2,g2,b2 = GetFFATeamColor(0, 2);
			if not GetTeamColorsAreFFA() then
				FailTest("GetTeamColorsAreFFA(): expected true but got false");
			else
				M.TestState = M.TestState + 1;
				M.TestTimer = GetTime() + 1;
			end
		elseif M.TestState == 6 then
			SetTeamStratColors(0);
			Info("Setting TeamStrat team colors (1:"..tostring(GetTeamStratColorVector(0,1))..") (2:"..tostring(GetTeamStratColorVector(0,2))..")");
			local r1,g1,b1 = GetTeamStratColor(0, 1);
			local r2,g2,b2 = GetTeamStratColor(0, 2);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 7 then
			SwapTeamStratColors();
			local r,g,b = GetTeamStratIndividualColor(0, 1);
			Info("Swapping team strat colors (1:"..tostring(r)..","..tostring(g)..","..tostring(b)..")");
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 1;
		elseif M.TestState == 8 then
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			PassTest();
		end
	end
end

--Tests CountUnitsNearObject()
function Test_CountUnitsNearObject()
	if M.TestState == 0 then
		local pos = GetPosition(M.Navs[1]);		
		M.Object01 = BuildObject("ivtank", 1, pos);
		pos.z = pos.z + 50;
		M.Object02 = BuildObject("fvscout", 2, pos);
		pos.z = pos.z + 50;
		M.Object03 = BuildObject("ivscout", 1, pos);
		M.TestState = M.TestState + 1;
	elseif M.TestState == 1 then
		if CountUnitsNearObject(M.Navs[1], 25, 1, "ivtank") ~= 1 then
			FailTest("CountUnitsNearObject(nav1, 25, 1, ivtank): expected 1 but got "..tostring(CountUnitsNearObject(M.Navs[1], 25, 1, "ivtank")));
		elseif CountUnitsNearObject(M.Navs[1], 25, 1, "fvscout") ~= 0 then
			FailTest("CountUnitsNearObject(nav1, 25, 1, fvscout): expected 0 but got "..tostring(CountUnitsNearObject(M.Navs[1], 25, 1, "fvscout")));
		elseif CountUnitsNearObject(M.Navs[1], 150, 1, "ivscout") ~= 1 then
			FailTest("CountUnitsNearObject(nav1, 150, 1, ivscout): expected 1 but got "..tostring(CountUnitsNearObject(M.Navs[1], 150, 1, "ivscout")));
		else
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			RemoveObject(M.Object03);
			PassTest();
		end
	end
end

--Tests SetTimerBox() - MP only? doesnt do anything in SP when I tried it
function Test_SetTimerBox()
	if M.TestState == 0 then
		Info("Setting timer box to 'hello'");
		M.Timer1 = GetTime() + 5;
		SetTimerBox("Hello");
		M.TestState = M.TestState + 1;
	elseif M.TestState == 1 then
		SetTimerBox("Hello");
		if M.Timer1 < GetTime() then
			PassTest();
		end
	end
end

--Tests SetCommand()
function Test_SetCommand()
	if M.TestState == 0 then
		M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
		SetCommand(M.Object01, AiCommand.CMD_FOLLOW, 1, GetPlayerHandle());
		M.TestState = M.TestState + 1;
	elseif M.TestState == 1 then
		if IsFollowing(M.Object01) then 
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--Tests GetOmega()
function Test_GetOmega()
	if M.TestState == 0 then
		Info("Spin around...");
		M.TestState = M.TestState + 1;
	elseif M.TestState == 1 then
		if Length(GetOmega(GetPlayerHandle())) > 0 then
			PassTest();
		end
	end
end

--Tests SetAvoidType()
function Test_SetAvoidType()
	if M.TestState == 0 then
		local avoidType = 2;
		Info("Setting avoid type = "..avoidType);
		local start_pos = GetPosition(M.Navs[1]);
		start_pos.y = TerrainFindFloor(start_pos);
		local obstr_pos = start_pos + SetVector(0,0,50);
		local end_pos = start_pos + SetVector(0,0,100);
		M.Object01 = BuildObject("ivtank", 1, start_pos);
		M.Object02 = BuildObject("ibcrat00", 0, BuildDirectionalMatrix(obstr_pos));
		M.Object03 = BuildObject("ivscav", 0, end_pos);
		SetAvoidType(M.Object01, avoidType);
		M.TestState = M.TestState + 1;
	elseif M.TestState == 1 then
		Goto(M.Object01, M.Object03, 1);
		M.TestState = M.TestState + 1;
	elseif M.TestState == 2 then
		if GetDistance(M.Object01, M.Object03) < 20 then
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			RemoveObject(M.Object03);
			PassTest();
		end
	end
end

--Tests SetPerceivedTeam(), GetPerceivedTeam()
function Test_PerceivedTeam()
	if M.TestState == 0 then
		M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
		M.Object02 = BuildObject("fvscout", 2, M.Navs[2]);
		if GetPerceivedTeam(M.Object01) ~= 1 or GetPerceivedTeam(M.Object02) ~= 2 then
			FailTest("GetPerceivedTeam(): wrong perceived team for fresh units. Expected (1,2), but got ("..tostring(GetPerceivedTeam(M.Object01))..","..tostring(GetPerceivedTeam(M.Object02)..")"));
		else
			SetPerceivedTeam(M.Object01, 2);
			SetPerceivedTeam(M.Object02, 2);
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		if GetPerceivedTeam(M.Object01) ~= 2 then
			FailTest("GetPerceivedTeam(Object01): expected 2 but got "..GetPerceivedTeam(M.Object01));
		elseif GetPerceivedTeam(M.Object02) ~= 2 then
			FailTest("GetPerceivedTeam(Object02): expected 2 but got "..GetPerceivedTeam(M.Object02));
		else
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			PassTest();
		end
	end
end

--Tests GetObjectiveName(), SetObjectiveName()
function Test_ObjectiveName()
	if M.TestState == 0 then
		if GetObjectiveName == nil then
			FailTest("GetObjectiveName: function is nil.");
		else
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
		if GetObjectiveName(M.Object01) ~= "Sabre" and GetObjectiveName(M.Object01) ~= "Tank" then
			FailTest("GetObjectiveName(): expected 'Tank' or 'Sabre' for fresh tank but got "..tostring(GetObjectiveName(M.Object01)));
		else
			SetObjectiveName(M.Object01, "asdf");
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 2 then
		if GetObjectiveName(M.Object01) ~= "asdf" then
			FailTest("GetObjectiveName(): expected 'asdf' but got "..tostring(GetObjectiveName(M.Object01)));
		else
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--Tests GetAllGameObjectHandles()
function Test_GetAllGameObjectHandles()
	if M.TestState == 0 then
		M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
		M.Object02 = BuildObject("ispilo", 2, pos);
		local pos = GetPosition(M.Navs[3]);
		pos.y = TerrainFindFloor(pos);
		M.Object03 = BuildObject("ibpgen", 3, BuildDirectionalMatrix(M.Navs[3]));
		M.TestState = M.TestState + 1;
	elseif M.TestState == 1 then
		local allHandles = GetAllGameObjectHandles();
		if type(allHandles) ~= "table" then
			FailTest("GetAllGameObjectHandles(): expected table but got "..tostring(type(allHandles)));
		elseif table.getn(allHandles) < 3 then
			FailTest("GetAllGameObjectHandles(): expected >=3 entries but got "..tostring(table.getn(allHandles)));
		else
			for k,v in pairs(allHandles) do
				if type(v) ~= "userdata" then
					RemoveObject(M.Object01);
					RemoveObject(M.Object02);
					RemoveObject(M.Object03);
					FailTest("GetAllGameObjectHandles(): expected array of handles but got array of "..tostring(type(v)));
				elseif not IsAround(v) then
					FailTest(string.format("GetAllGameObjectHandles(): handle is not around. key:'%s' => val:'%s'", tostring(k), tostring(v)));
					break;
				end
			end
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 2 then
		RemoveObject(M.Object01);
		RemoveObject(M.Object02);
		RemoveObject(M.Object03);
		PassTest();
	end	
end

--Tests MakeInert()
--makes the tank invisible, but the 'inert' tank still collides with projectiles.
function Test_MakeInert()
	if M.TestTimer < GetTime() then
		if M.TestState == 0 then
			Info("Making tank inert for 5s...");
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			MakeInert(M.Object01);
			M.TestState = M.TestState + 1;
			M.TestTimer = GetTime() + 5;
		elseif M.TestState == 1 then
			RemoveObject(M.Object01);
			PassTest();
		end
	end
end

--Tests Service()
function Test_Service()
	if M.TestState == 0 then
		M.Object01 = BuildObject("ivserv", 1, M.Navs[1]);
		local pos = GetPosition(M.Navs[1]);
		pos.z = pos.z + 100;
		M.Object02 = BuildObject("ivscav", 1, pos);
		SetCurHealth(M.Object02, 1000);
		SetMaxHealth(M.Object02, 2000);
		Service(M.Object01, M.Object02, 1);
		M.TestState = M.TestState + 1;
		M.Timer1 = GetTime() + 10;
	elseif M.TestState == 1 then
		if M.Timer1 < GetTime() then
			FailTest("Service(): scav was not serviced within timeout.");
		elseif GetCurHealth(M.Object02) > 1050 then
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			PassTest();
		end
	end
end

--Tests IFace_ConsoleCmd
function Test_IFaceConsoleCommand()
	if M.TestState == 0 then
		if IFace_ConsoleCmd == nil then
			FailTest();
		else
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		Info("Setting sky to white.");
		IFace_ConsoleCmd("sky.color 255 255 255");
		PassTest();
	end
end

--Tests GetCategoryType(), GetCategoryTypeOverride()
--Need better documentation about category type before I can test this further.
--The category type of ivtank is apparently 22. I assume that's ok.
function Test_GetCategoryType()
	if M.TestState == 0 then
		if GetCategoryType == nil then
			FailTest("GetCategoryType: function is nil.");
		elseif GetCategoryTypeOverride == nil then
			FailTest("GetCategoryTypeOverride: function is nil.");
		else
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		if GetCategoryType(nil) >= 0 then
			FailTest("GetCategoryType(nil): expected -2 but got "..tostring(GetCategoryType(nil)));
		elseif GetCategoryTypeOverride(nil) >= 0 then
			FailTest("GetCategoryTypeOverride(nil): expected -2 but got "..tostring(GetCategoryType(nil)));
		elseif GetCategoryType(M.Object01) <= 0 then
			FailTest("GetCategoryType(): expected non-zero but got "..tostring(GetCategoryType(M.Object01)));
		--elseif GetCategoryTypeOverride(M.Object01) <= 0 then
		--	FailTest("GetCategoryTypeOverride(): expected non-zero but got "..tostring(GetCategoryTypeOverride(M.Object01)));
		end
		M.TestState = M.TestState + 1;
	end
end

--Tests SetAngle(), SetRandomHeadingAngle()
--Note: an angle of 0 degrees means facing North.
function Test_SetAngle()
	if M.TestState == 0 then
		M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
		SetAngle(M.Object01, 90);
		local front = Normalize(GetFront(M.Object01));
		if DotProduct(front, SetVector(1,0,0)) < 0.99  then 
			FailTest("SetAngle(): object not facing the right direction. front="..tostring(GetFront(M.Object01)));
		else
			M.Object02 = BuildObject("ivtank", 1, M.Navs[2]);
			M.Object03 = BuildObject("ivtank", 1, M.Navs[3]);
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		SetRandomHeadingAngle(M.Object01);
		SetRandomHeadingAngle(M.Object02);
		SetRandomHeadingAngle(M.Object03);	
		if DotProduct(Normalize(GetFront(M.Object01)), Normalize(GetFront(M.Object02))) > 0.99 and DotProduct(Normalize(GetFront(M.Object01)), Normalize(GetFront(M.Object03))) > 0.99 then
			FailTest("SetRandomHeadingAngle(): headings not random: "..tostring(GetFront(M.Object01)));
		else
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			RemoveObject(M.Object03);
			PassTest();
		end
	end
end

--Tests SetSkill(), GetSkill()
function Test_SetSkill()
	if M.TestState == 0 then
		if SetSkill == nil then
			FailTest("SetSkill: function is nil.");
		elseif GetSkill == nil then
			FailTest("GetSkill: function is nil.");
		else
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			M.Object02 = BuildObject("ivtank", 1, M.Navs[2]);
			SetSkill(M.Object01, 1);
			SetSkill(M.Object02, 3);
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		if GetSkill(M.Object01) ~= 1 then
			FailTest("GetSkill(Object01): expected 1 but got "..tostring(GetSkill(M.Object01)));
		elseif GetSkill(M.Object02) ~= 3 then
			FailTest("GetSkill(Object02): expected 3 but got "..tostring(GetSkill(M.Object02)));
		elseif GetSkill(nil) ~= nil then
			FailTest("GetSkill(nil): expected nil but got "..tostring(GetSkill(nil)));
		else
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			PassTest();
		end
	end
end

--Tests SetIndependence(), GetIndependence()
function Test_SetIndependence()
	if M.TestState == 0 then
		if SetIndependence == nil then
			FailTest("SetIndependence: function is nil.");
		elseif GetIndependence == nil then
			FailTest("GetIndependence: function is nil.");
		else
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			M.Object02 = BuildObject("ivtank", 1, M.Navs[2]);
			SetIndependence(M.Object01, 1);
			SetIndependence(M.Object02, 0);
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		if GetIndependence(M.Object01) ~= 1 then
			FailTest("GetIndependence(Object01): expected 1 but got "..tostring(GetIndependence(M.Object01)));
		elseif GetIndependence(M.Object02) ~= 0 then
			FailTest("GetIndependence(Object02): expected 0 but got "..tostring(GetIndependence(M.Object02)));
		elseif GetIndependence(nil) ~= nil then
			FailTest("GetIndependence(nil): expected nil but got "..tostring(GetIndependence(nil)));
		else
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			PassTest();
		end
	end
end	

--Tests SetAIP, GetAIP, GetPlan()
function Test_SetAIP()
	if M.TestState == 0 then
		if SetAIP == nil then
			FailTest("SetAIP: function is nil.");
		elseif GetAIP == nil then
			FailTest("GetAIP: function is nil.");
		elseif GetPlan == nil then
			FailTest("GetPlan: function is nil.");
		else
			SetAIP("isdf0401.aip", 2);
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		if GetAIP(2) ~= "isdf0401.aip" then
			FailTest("GetAIP(): expected 'isdf0401.aip' but got "..tostring(GetAIP(2)));
		elseif GetPlan(2) ~= "isdf0401.aip" then
			FailTest("GetPlan(): expected 'isdf0401.aip' but got "..tostring(GetPlan(2)));
		end
	end
end

--Tests GetCurrentWho(), GetCurrentCommandWhere()
function Test_GetCurrentWho()
	if M.TestState == 0 then
		M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
		M.Object02 = BuildObject("fvtank", 2, M.Navs[2]);
		Attack(M.Object01, M.Object02, 1);
		M.TestState = M.TestState + 1;
	elseif M.TestState == 1 then
		if GetCurrentWho(M.Object01) ~= M.Object02 then
			FailTest("GetCurrentWho(): expected "..tostring(M.Object02).." but got "..tostring(GetCurrentWho(M.Object01)));
		else
			RemoveObject(M.Object02);
			Goto(M.Object01, M.Navs[2], 1);
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 2 then
		local expected = GetPosition(M.Navs[2]);
		expected.y = TerrainFindFloor(expected);
		if Length(GetCurrentCommandWhere(M.Object01) - expected) > 0.1 then
			FailTest("GetCurrentCommandWhere(): expected "..tostring(expected).." but got "..tostring(GetCurrentCommandWhere(M.Object01)));
		else
			RemoveObject(M.Object01);
			PassTest();
		end	
	end
end

--Tests CanCommand()
function Test_CanCommand()
	if M.TestState == 0 then
		if CanCommand == nil then
			FailTest("CanCommand: function is nil.");
		else
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			M.Object02 = BuildObject("ivtank", 1, M.Navs[2]);
			Goto(M.Object01, M.Navs[2], 0);
			Goto(M.Object02, M.Navs[1], 1);
			M.TestState = M.TestState + 1;
		end		
	elseif M.TestState == 1 then
		if not CanCommand(M.Object01) then
			FailTest("CanCommand(Object01): expected true but got "..tostring(CanCommand(M.Object01)));
		elseif not CanCommand(M.Object02) then
			FailTest("CanCommand(Object02): expected false but got "..tostring(CanCommand(M.Object02)));
		elseif CanCommand(nil) then
			FailTest("CanCommand(nil): expected false but got "..tostring(CanCommand(nil)));
		else
			RemoveObject(M.Object01);
			RemoveObject(M.Object02);
			PassTest();
		end
	end
end

----------------------------------
-------INSTANT ACTION-------------
----------------------------------

--Spits out a bunch of IA info
--Tests GetInstantMyForce, GetInstantCompForce, GetInstantDifficulty, GetInstantGoal, GetInstantType, GetInstantFlag, GetInstantMySide
function Test_InstantInfo()
	print("GetInstantMyForce: "..tostring(GetInstantMyForce()));
	print("GetInstantCompForce: "..tostring(GetInstantCompForce()));
	print("GetInstantDifficulty: "..tostring(GetInstantDifficulty()));
	print("GetInstantGoal: "..tostring(GetInstantGoal()));
	print("GetInstantType: "..tostring(GetInstantType()));
	print("GetInstantFlag: "..tostring(GetInstantFlag()));
	print("GetInstantMySide: "..tostring(GetInstantMySide()));
	PassTest();
end

----------------------------------
-------MULTIPLAYER TESTS----------
----------------------------------

--Spits out a bunch of info about the current server
--Tests IsNetworkOn(), IsNetGame(), IsHosting(), ImServer(), ImDedicatedServer(), IsTeamplayOn(), 
--CountPlayers(), GetCurWorld(),GetLocalPlayerTeamNumber(), GetLocalPlayerDPID()
function Test_ServerInfo()
	print("IsNetworkOn: "..tostring(IsNetworkOn()));
	print("IsNetGame: "..tostring(IsNetGame()));
	print("IsHosting: "..tostring(IsHosting()));
	print("ImServer: "..tostring(ImServer()));
	print("ImDedicatedServer: "..tostring(ImDedicatedServer()));
	print("IsTeamplayOn: "..tostring(IsTeamplayOn()));
	print("CountPlayers: "..tostring(CountPlayers()));
	print("GetCurWorld: "..tostring(GetCurWorld()));
	print("GetLocalPlayerTeamNumber: "..tostring(GetLocalPlayerTeamNumber()));
	print("GetLocalPlayerDPID: "..tostring(GetLocalPlayerDPID()));
	PassTest();
end

--Tests GetDeaths(), GetKills(), GetScore(), SetDeaths(), SetKills(), SetScore(), AddDeaths(), AddKills(), AddScore()
function Test_Score()
	local h = GetPlayerHandle();
	SetDeaths(h, 11);
	SetKills(h, 22);
	SetScore(h, 33);
	AddDeaths(h, 1);
	AddKills(h, 1);
	AddScore(h, 1);
	if GetDeaths(h) ~= 12 then
		FailTest("GetDeaths(): expected 12 but got "..tostring(GetDeaths(h)));
	elseif GetKills(h) ~= 23 then
		FailTest("GetDeaths(): expected 23 but got "..tostring(GetDeaths(h)));
	elseif GetScore(h) ~= 34 then
		FailTest("GetDeaths(): expected 34 but got "..tostring(GetDeaths(h)));
	else
		PassTest();
	end
end

--Tests FlagSteal(), FlagRecover(), FlagScore()
--I have no idea how to use these, so I'll just call them and if it doesn't crash, consider it good.
function Test_FlagFuncs()
	if M.TestState == 0 then
		if FlagSteal == nil then
			FailTest("FlagSteal: function is nil.");
		elseif FlagRecover == nil then
			FailTest("FlagRecover: function is nil.");
		elseif FlagScore == nil then
			FailTest("FlagScore: function is nil.");
		else
			M.Object01 = BuildObject("ivtank", 1, M.Navs[1]);
			M.Object02 = BuildObject("fvtank", 2, M.Navs[2]);
			local pos = GetPosition(M.Navs[1]);
			pos.z = pos.z + 50;
			M.Object03 = BuildObject("ioflag01", 0, pos);
			M.TestState = M.TestState + 1;
		end
	elseif M.TestState == 1 then
		FlagSteal(M.Object03, M.Object01);
		M.TestState = M.TestState + 1;
	elseif M.TestState == 2 then
		FlagScore(M.Object03, M.Object01);
		M.TestState = M.TestState + 1;
	elseif M.TestState == 3 then
		FlagSteal(M.Object03, M.Object02);
		M.TestState = M.TestState + 1;
	elseif M.TestState == 4 then
		Damage(M.Object02, 9999);
		M.TestState = M.TestState + 1;
	elseif M.TestState == 5 then
		FlagRecover(M.Object03, M.Object01);
		M.TestState = M.TestState + 1;
	elseif M.TestState == 6 then
		RemoveObject(M.Object01);
		RemoveObject(M.Object02);
		RemoveObject(M.Object03);
		PassTest();
	end
end

--Tests MoneyScore()
function Test_MoneyScore()
	if MoneyScore == nil then
		FailTest("MoneyScore: function is nil");
	else
		local player = GetPlayerHandle(1);
		local oldscore = GetScore(player);
		MoneyScore(100, player);
		if GetScore(player) == oldscore + 100 then
			PassTest();
		else
			FailTest("MoneyScore(): score did not change.");
		end
	end
end

--Tests GetVarItemStr(), GetVarItemInt(), GetCVarItemInt(), GetCVarItemStr()
--Unsure of how to test
function Test_SetVarItems()
	if GetVarItemStr == nil then
		FailTest("GetVarItemStr(): function is nil");
	elseif GetVarItemInt == nil then
		FailTest("GetVarItemInt(): function is nil");
	elseif GetCVarItemInt == nil then
		FailTest("GetVarItemInt(): function is nil");
	elseif GetCVarItemStr == nil then
		FailTest("GetVarItemInt(): function is nil");
	else
		print("network.session.svar6="..tostring(GetVarItemStr("network.session.svar6")));
		print("GetVarItemInt(1,1)="..tostring(GetVarItemInt(1, 1)));
		print("GetCVarItemInt(1,1)="..tostring(GetCVarItemInt(1,1)));
		print("GetCVarItemStr(1,1)="..tostring(GetCVarItemStr(1,1)));
		PassTest()
	end
end

--Just call these funcs and make sure they don't crash
--Tests GetSafestSpawnpoint, GetSpawnpoint, GetSpawnpointHandle, GetRandomSpawnpoint, GetAllSpawnpoints, GetPlayerODF()
function Test_Spawnpoint()
	print("GetSafestSpawnpoint():"..tostring(GetSafestSpawnpoint(1)));
	print("GetSpawnpointHandle():"..tostring(GetSpawnpointHandle(1)));
	print("GetSpawnpoint():"..tostring(GetSpawnpoint(1)));
	print("GetRandomSpawnpoint():"..tostring(GetRandomSpawnpoint(1)));
	print("GetAllSpawnpoints():"..tostring(GetAllSpawnpoints(1)));
	print("GetPlayerODF():"..tostring(GetPlayerODF(1,2)));
	PassTest();
end

--Tests KickPlayer()
--doesn't work in SP, haven't tried in MP
function Test_KickPlayer()
	print("Kicking Player 2...");
	if KickPlayer == nil then
		FailTest("KickPlayer: function is nil.");
	elseif GetPlayerHandle(2) == nil then
		print("Player 2 not found.");
		PassTest();
	else
		KickPlayer(GetPlayerHandle(2), "Test_KickPlayer");
		PassTest();
	end
end

--Tests NoteGameoverByTimeLimit(), NoteGameoverByKillLimit(), NoteGameoverByScore(), 
--NoteGameoverByLastWithBase(),NoteGameoverByLastTeamWithBase(),NoteGameoverByNoBases(),
--DoGameover(), NoteGameoverWithCustomMessage()
--This doesn't seem to do anything in SP...
function Test_NoteGameover()
	NoteGameoverByTimeLimit();
	NoteGameoverByKillLimit(GetPlayerHandle(1));
	NoteGameoverByScore(GetPlayerHandle(1));
	NoteGameoverByLastWithBase(GetPlayerHandle(1));
	NoteGameoverByLastTeamWithBase(1);
	NoteGameoverByNoBases();
	NoteGameoverWithCustomMessage("Test_NoteGameover");
	DoGameover(0);
	PassTest();
end

--Tests SetMPTeamRace()
function Test_SetMPTeamRace()
	if SetMPTeamRace == nil then
		FailTest("SetMPTeamRace: function is not defined.");
	else
		SetMPTeamRace(1, "i");
		PassTest();
	end
end

--Tests ResetTeamSlot()
function Test_ResetTeamSlot()
	if ResetTeamSlot == nil then
		FailTest("ResetTeamSlot: function is not defined.");
	else
		ResetTeamSlot(GetPlayerHandle(1));
		PassTest();
	end
end

--Tests GetCommanderTeam(), GetFirstAlliedTeam(), GetLastAlliedTeam(), GetTeamplayRanges(), 
--IsTeamAllied(), DefaultAllies(), TeamplayAllies()
function Test_MPTeamplay()
	TeamplayAllies();
	print("GetCommanderTeam(1): "..tostring(GetCommanderTeam(1)));
	print("GetFirstAlliedTeam(1): "..tostring(GetFirstAlliedTeam(1)));
	print("GetLastAlliedTeam(1): "..tostring(GetLastAlliedTeam(1)));
	local i1,i2,i3 = GetTeamplayRanges(1);
	print("GetTeamplayRanges(1): ("..tostring(i1)..","..tostring(i2)..","..tostring(i3)..")");
	print("IsTeamAllied(1,2): "..tostring(IsTeamAllied(1,2)));
	DefaultAllies();
	PassTest();
end

--TODO: 
--LogFloat --unsure of how to use/test
--PanDone() --unsure of when to use
--PlayMovie(), StopMovie() --unsure of how to use/test!
--PlayRecording(), PlayMove(), PlaybackVehicle() --unsure of how to use/test!
--Network_SetString Network_SetInteger --unsure of how to use/test
--TranslateString
--GetNetworkListItem, GetNetworkListCount --unsure of how to use/test
--PetWatchdogThread
