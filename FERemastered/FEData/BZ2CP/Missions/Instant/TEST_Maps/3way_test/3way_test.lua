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
    PreloadODF("cvrecy03");

    PreloadODF("ivscout");
    PreloadODF("fvscout");
    PreloadODF("evscout");
    PreloadODF("cvscout");
end

function Start()
    M.TWPlayerRace = IFace_GetInteger("3way.race");

    M.TWPStartingForce = IFace_GetInteger("3way.startingforce");

    M.TWEDFScrapCheat = IFace_GetInteger("3way.team1cheat");
    M.TWScionScrapCheat = IFace_GetInteger("3way.team2cheat");
    M.TWPlayerCheat = IFace_GetInteger("3way.playercheat");

    M.TWKeepBasePools = IFace_GetInteger("3way.keepbasepools");
    M.KeepPool = IFace_GetInteger("3way.keeppools");

    M.EnemyTeam1Race = IFace_GetInteger("3way.team1_race");
    M.EnemyTeam2Race = IFace_GetInteger("3way.team2_race");
end

function AddObject(h)
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

    M.Player = GetPlayerHandle();
    if (M.MissionTimer < GetTime()) then
        if (M.MissionState == 0) then
		    -- Set Enemy Team Race Letter
		    if (M.EnemyTeam1Race == 0) then
		    	M.EnemyTeam1Race = "i";
		    elseif (M.EnemyTeam1Race == 1) then
				M.EnemyTeam1Race = "f";
		    elseif (M.EnemyTeam1Race == 2) then
				M.EnemyTeam1Race = "e";
		    else
				M.EnemyTeam1Race = "c";
		    end

		    if (M.EnemyTeam2Race == 0) then
		    	M.EnemyTeam2Race = "i";
		    elseif (M.EnemyTeam2Race == 1) then
				M.EnemyTeam2Race = "f";
		    elseif (M.EnemyTeam2Race == 2) then
				M.EnemyTeam2Race = "e";
		    else
				M.EnemyTeam2Race = "c";
		    end

            if (M.TWPlayerRace == 0) then
                M.PlayerRecy = BuildObject("ivrecy", M.PlayerTeamNum, "Player");
                M.PlayerRace = 'i';
            elseif (M.TWPlayerRace == 1) then
                M.PlayerRecy = BuildObject("fvrecy", M.PlayerTeamNum, "Player");
                M.PlayerRace = 'f';
            elseif (M.TWPlayerRace == 2) then
                M.PlayerRecy = BuildObject("evrecy", M.PlayerTeamNum, "Player");
                M.PlayerRace = 'e';
            elseif (M.TWPlayerRace == 3) then
                M.PlayerRecy = BuildObject("cvrecy03", M.PlayerTeamNum, "Player");
                M.PlayerRace = 'c';
            end

            SetGroup(M.PlayerRecy, 1);

            local PlayerEntryH = GetPlayerHandle();
            local Temp = ("%svscout"):format(M.PlayerRace)
            if M.PlayerRace == 'c' then
                Temp = "cvscoutP"
                SetAsUser(BuildObject(Temp, M.PlayerTeamNum, GetPositionNear(GetPosition("Player"), 25.0, 25.0)), M.PlayerTeamNum);
            else
                SetAsUser(BuildObject(Temp, M.PlayerTeamNum, GetPositionNear(GetPosition("Player"), 25.0, 25.0)), M.PlayerTeamNum);
            end

            RemoveObject(PlayerEntryH);         

            if (M.EnemyTeam1Race == "c") then
                M.EnemyTeam1Recy = BuildObject("cvrecy02", M.EnemyTeam1, "EnemyTeam1");
            else
                local Temp = ("%svrecy"):format(M.EnemyTeam1Race)
                M.EnemyTeam1Recy = BuildObject(Temp, M.EnemyTeam1, "EnemyTeam1");
            end

            if (M.EnemyTeam2Race == "c") then
                M.EnemyTeam2Recy = BuildObject("cvrecy02", M.EnemyTeam2, "EnemyTeam2");
            else
                local Temp = ("%svrecy"):format(M.EnemyTeam2Race)
                M.EnemyTeam2Recy = BuildObject(Temp, M.EnemyTeam2, "EnemyTeam2");
            end
            
            SetScrap(M.PlayerTeamNum, 40);
            SetScrap(M.EnemyTeam1, 40);
            SetScrap(M.EnemyTeam2, 40);
            
            M.MissionState = M.MissionState + 1;
        elseif (M.MissionState == 1) then
            local turret = ("%svturr"):format(M.PlayerRace);
            local atank = ("%svatank"):format(M.PlayerRace);
            local tank = ("%svtank"):format(M.PlayerRace);
            local scout = ("%svscout"):format(M.PlayerRace);

            if (M.TWPStartingForce == 0) then
                for i = 1, 2 do
                    SetGroup(BuildObject(turret, M.PlayerTeamNum, GetPositionNear(GetPosition("Player"), 25.0, 25.0)), 0);
                end
            elseif (M.TWPStartingForce == 1) then
                for i = 1, 2 do
                    SetGroup(BuildObject(turret, M.PlayerTeamNum, GetPositionNear(GetPosition("Player"), 25.0, 25.0)), 0);
                    SetGroup(BuildObject(atank, M.PlayerTeamNum, GetPositionNear(GetPosition("Player"), 25.0, 25.0)), 2);
                end
            elseif (M.TWPStartingForce == 2) then
                for i = 1, 2 do
                    SetGroup(BuildObject(turret, M.PlayerTeamNum, GetPositionNear(GetPosition("Player"), 25.0, 25.0)), 0);
                    SetGroup(BuildObject(atank, M.PlayerTeamNum, GetPositionNear(GetPosition("Player"), 25.0, 25.0)), 2);
                    SetGroup(BuildObject(tank, M.PlayerTeamNum, GetPositionNear(GetPosition("Player"), 25.0, 25.0)), 3);
                    SetGroup(BuildObject(scout, M.PlayerTeamNum, GetPositionNear(GetPosition("Player"), 25.0, 25.0)), 4);
                end
            end

            local AIPFile = ("%s_CPU_1.aip"):format(M.EnemyTeam1Race);
            SetAIP(AIPFile, M.EnemyTeam1);

            AIPFile = ("%s_CPU_2.aip"):format(M.EnemyTeam2Race);
            SetAIP(AIPFile, M.EnemyTeam2);

            M.MissionState = M.MissionState + 1;
        end
    end
end

function CheckIfStuffAlive()
    if not M.IsGameOver then
        if not IsAround(M.EnemyTeam1Recy) and not IsAround(M.EnemyTeam2Recy) then
            -- Player Wins
        elseif not IsAround(M.EnemyTeam2Recy) and not IsAround(M.PlayerRecy) then
            -- Enemy Team 1 Wins
        elseif not IsAround(M.EnemyTeam1Recy) and not IsAround(M.PlayerRecy) then
            -- Enemy Team 2 Wins
        end
        M.IsGameOver = true
    end
end

function UpgradeUnitWeapons(handle)

end