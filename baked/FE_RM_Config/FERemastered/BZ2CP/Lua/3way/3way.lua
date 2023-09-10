--[[ BZCC FE 3way Mission Script 
Written by JJ (AI_Unit)
Version 1.0 19/11/2019 --]]

local M = {
    Player = nil,
    PlayerRecy = nil,
    EnemyTeam1Recy = nil,
    EnemyTeam2Recy = nil,

    PlayerRace = nil,
    PlayerTeamNum = 1,
    EnemyTeam1 = 5,
    EnemyTeam2 = 11,
    EnemyTeam1Race = nil,
    EnemyTeam2Race = nil,

    EnemyTeam1Crazy = nil,
    EnemyTeam2Crazy = nil,

    EnemyTeam1Armory = false,
    EnemyTeam2Armory = false,

    MissionState = 0,
    MissionTimer = 0,

    TWPStartingForce = nil,
    TWEnemyTeam1Cheat = nil,
    TWEnemyTeam2Cheat = nil,
    TWPlayerCheat = nil,
    TWKeepBasePools = nil,

    IsGameOver = false,
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
	PreloadODF("ivrecy");
	PreloadODF("fvrecy");
	PreloadODF("evrecy");
    PreloadODF("cvrecy02");

    PreloadODF("ivscout");
    PreloadODF("fvscout");
    PreloadODF("evscout");
    PreloadODF("cvscout");
end

function Start()
    M.PlayerRace = string.char(IFace_GetInteger("options.instant.myrace"));

    M.TWPStartingForce = IFace_GetInteger("options.instant.playerforce");

    M.TWPlayerCheat = IFace_GetInteger("options.instant.int1");
    M.TWEnemyTeam1Cheat = IFace_GetInteger("options.instant.int2");
    M.TWEnemyTeam2Cheat = IFace_GetInteger("options.instant.int3");

    M.TWRemoveBasePools = IFace_GetInteger("options.instant.int4");

    M.EnemyTeam1Race = string.char(IFace_GetInteger("options.instant.hisrace"));
    M.EnemyTeam2Race = string.char(IFace_GetInteger("options.instant.int0"));
end

function AddObject(h)
-- Set enemy team pilot's to the "maniac" pilots.
-- Change maniac%c.odf files to %cmaniac.odf to make internal game race code work correctly.

	if IsCraftButNotPerson(h) and GetTeamNum(h) ~= 1 then 
	
	
	end

    if (GetTeamNum(h) == M.PlayerTeamNum) then
        if (GetClassLabel(h) == "CLASS_SUPPLYDEPOT") then
            SetObjectiveOn(h);
        end
    end

    if (GetTeamNum(h) == M.EnemyTeam1) then
        if (GetClassLabel(h) == "CLASS_ARMORY") then
            M.EnemyTeam1Armory = true;
        end
    end

    if (GetTeamNum(h) == M.EnemyTeam2) then
        if (GetClassLabel(h) == "CLASS_ARMORY") then
            M.EnemyTeam2Armory = true;
        end
    end

    -- Possible Armory Logic here for both AI teams?
    if (GetTeamNum(h) == M.EnemyTeam1) then
        if (M.EnemyTeam1Armory) then
    	   UpgradeUnitWeapons(h);
        end
    end

    if (GetTeamNum(h) == M.EnemyTeam2) then
        if (M.EnemyTeam2Armory) then
    	   UpgradeUnitWeapons(h);
        end
    end
end

function DeleteObject(h)
    if (GetTeamNum(h) == M.EnemyTeam1) then
        if (GetClassLabel(h) == "CLASS_ARMORY") then
            M.EnemyTeam1Armory = false;
        end
    end

    if (GetTeamNum(h) == M.EnemyTeam2) then
        if (GetClassLabel(h) == "CLASS_ARMORY") then
            M.EnemyTeam2Armory = false;
        end
    end
end

function Update()
    if M.MissionState > 1 then
        CheckIfStuffAlive();
    end

    -- Vars
    M.Player = GetPlayerHandle();

    if (M.MissionTimer < GetTime()) then
        if (M.MissionState == 0) then
			
			  local playerStart = GetPositionNear(GetPosition("Player"), 25.0, 25.0);
			
			-- Spawn Player Recycler.
			local chosenPlayerRecy = IFace_GetString("options.instant.string1");
			chosenPlayerRecy = M.PlayerRace .. chosenPlayerRecy:sub(2);
			if (M.PlayerRace == "c") then
				chosenPlayerRecy = "cvrecy02";
			end
			M.PlayerRecy = BuildObject(chosenPlayerRecy, M.PlayerTeamNum, "Player");
            SetGroup(M.PlayerRecy, 1);
			SetScrap(M.PlayerTeamNum, 40);
			
			-- Spawn Player.
            local PlayerEntryH = GetPlayerHandle();
            local Temp = ("%svscout"):format(M.PlayerRace)
            SetAsUser(BuildObject(Temp, M.PlayerTeamNum, playerStart), M.PlayerTeamNum);
            RemoveObject(PlayerEntryH);         

			-- Spawn CPU 1
			local chosenEnemy1Recy = IFace_GetString("options.instant.string2");
			chosenEnemy1Recy = M.EnemyTeam1Race .. chosenEnemy1Recy:sub(2);
            if (M.EnemyTeam1Race == "c") then
				chosenEnemy1Recy = "cvrecy02";
			end
            M.EnemyTeam1Recy = BuildObject(chosenEnemy1Recy, M.EnemyTeam1, "EnemyTeam1");
            SetScrap(M.EnemyTeam1, 40);
			local AIPFile = ("%s_CPU_1.aip"):format(M.EnemyTeam1Race);
            SetAIP(AIPFile, M.EnemyTeam1);
			
			-- Spawn CPU 2
			if (M.EnemyTeam2Race ~= '') then
				local chosenEnemy2Recy = IFace_GetString("options.instant.string2");
				chosenEnemy2Recy = M.EnemyTeam2Race .. chosenEnemy2Recy:sub(2);
				if (M.EnemyTeam2Race == "c") then
					chosenEnemy2Recy = "cvrecy02";
				end
				M.EnemyTeam2Recy = BuildObject(chosenEnemy2Recy, M.EnemyTeam2, "EnemyTeam2");
				SetScrap(M.EnemyTeam2, 40);	
				AIPFile = ("%s_CPU_2.aip"):format(M.EnemyTeam2Race);
				SetAIP(AIPFile, M.EnemyTeam2);
			end
			
            M.MissionState = M.MissionState + 1;
        elseif (M.MissionState == 1) then
            local turret = ("%svturr"):format(M.PlayerRace);
            local atank = ("%svatank"):format(M.PlayerRace);
            local tank = ("%svtank"):format(M.PlayerRace);
            local scout = ("%svscout"):format(M.PlayerRace);

            if (M.TWPStartingForce == 0) then
                for i = 1, 2 do
                    SetGroup(BuildObject(turret, M.PlayerTeamNum, playerStart), 0);
                end
            elseif (M.TWPStartingForce == 1) then
                for i = 1, 2 do
                    SetGroup(BuildObject(turret, M.PlayerTeamNum, playerStart), 0);
                    SetGroup(BuildObject(atank, M.PlayerTeamNum, playerStart), 2);
                end
            elseif (M.TWPStartingForce == 2) then
                for i = 1, 2 do
                    SetGroup(BuildObject(turret, M.PlayerTeamNum, playerStart), 0);
                    SetGroup(BuildObject(atank, M.PlayerTeamNum, playerStart), 2);
                    SetGroup(BuildObject(tank, M.PlayerTeamNum, playerStart), 3);
                    SetGroup(BuildObject(scout, M.PlayerTeamNum, playerStart), 4);
                end
            end

            M.MissionState = M.MissionState + 1;
        end
    end
end

function CheckIfStuffAlive()
    if not M.IsGameOver then
        if not IsAround(M.EnemyTeam1Recy) and not IsAround(M.EnemyTeam2Recy) then
            AddObjective("Game Over - Player Wins");
			DoGameover(10.0);
			M.IsGameOver = true;
        elseif not IsAround(M.EnemyTeam2Recy) and not IsAround(M.PlayerRecy) then
			AddObjective("Game Over - AI Team 1 Wins");
			DoGameover(10.0);
			M.IsGameOver = true;
        elseif not IsAround(M.EnemyTeam1Recy) and not IsAround(M.PlayerRecy) then
          	AddObjective("Game Over - AI Team 2 Wins");
			DoGameover(10.0);
			M.IsGameOver = true;
        end
    end
end

function UpgradeUnitWeapons(handle)
	local unit = GetOdf(handle);

	-- Handle different upgrades per unit.
	if (unit == "ivtank.odf") then
		GiveWeapon(handle, "gspstab_c");
	elseif (unit == "ivscout.odf") or (unit == "ivturr.odf") then
		GiveWeapon(handle, "gchain_c");
	elseif (unit == "ivatank.odf") then
		--GiveWeapon(handle, "gblast_a");
	elseif (unit == "fvtank.odf" or unit == "fvscout.odf") then
		--GiveWeapon(handle, "garc_c");
		GiveWeapon(handle, "gshield");
	elseif (unit == "fvsent.odf") then
		GiveWeapon(handle, "gdeflect");
	elseif (unit == "fvarch.odf") then
		GiveWeapon(handle, "gabsorb");
	elseif (unit == "fvartl.odf") then
		GiveWeapon(handle, "gpopgun");
	end
end

function HandleAICrazyUnits()

end