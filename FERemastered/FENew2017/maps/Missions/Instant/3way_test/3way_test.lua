local _Text1 = "SCION: %i Scrap Cheat"
local _Text2 = "EDF: %i Scrap Cheat"
local _Text3 = "HADEAN: %i Scrap Cheat"
local _Text4 = "Remove Enemey Base Pool (0 = No, 1 = Yes): %i"
local _Text5 = "Starting Force (0 = None, 1 = Small, 2 = Large): %i"

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

    MissionState = 0,
    MissionTimer = 0,

    TWPlayerRace = nil,
    TWPStartingForce = nil,
    TWEDFScrapCheat = nil,
    TWScionScrapCheat = nil,
    TWHadeanScrapCheat = nil,
    TWCerberiScrapCheat = nil,
    TWKeepBasePools = nil,
    TWKeepPool = nil,

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
    PreloadODF("cvrecy");

    PreloadODF("ivscout");
    PreloadODF("fvscout");
    PreloadODF("evscout");
    PreloadODF("cvscout");
end

function Start()
    M.TWPlayerRace = IFace_GetInteger("3way.race");
    M.TWPStartingForce = IFace_GetInteger("3way.startingforce");
    M.TWEDFScrapCheat = IFace_GetInteger("3way.edfcheat");
    M.TWScionScrapCheat = IFace_GetInteger("3way.scioncheat");
    M.TWHadeanScrapCheat = IFace_GetInteger("3way.hadeancheat");
    M.TWCerberiScrapCheat = IFace_GetInteger("3way.cerbericheat");
    M.TWKeepBasePools = IFace_GetInteger("3way.keepbasepools");
    M.KeepPool = IFace_GetInteger("3way.keeppools");
    M.EnemyTeam1Race = IFace_GetString("3way.eteam1race");
    M.EnemyTeam2Race = IFace_GetString("3way.eteam2race");
end

function AddObject(h)
    if GetTeamNum(h) == M.PlayerTeamNum then
        if GetClassLabel(h) == "CLASS_SUPPLYDEPOT" then
            SetObjectiveOn(h);
        end
    end

    -- Possible Armory Logic here for both AI teams?
end

function DeleteObject(h)

end

function Update()
    if M.MissionState > 1 then
        CheckIfStuffAlive();
    end

    M.Player = GetPlayerHandle();
    if (M.MissionTimer < GetTime()) then
        if (M.MissionState == 0) then
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
            --SetAIP(AIPFile, M.EnemyTeam1);

            AIPFile = ("%s_CPU_2.aip"):format(M.EnemyTeam2Race);
            --SetAIP(AIPFile, M.EnemyTeam2);

            M.MissionState = M.MissionState + 1;
        end
    end
end

function CheckIfStuffAlive()
    if not IsGameOver then
        if not IsAround(M.EnemyTeam1Recy) and not IsAround(M.EnemyTeam2Recy) then
            -- Player Wins
        elseif not IsAround(M.EnemyTeam2Recy) and not IsAround(M.PlayerRecy) then
            -- Enemy Team 1 Wins
        elseif not IsAround(M.EnemyTeam1Recy) and not IsAround(M.PlayerRecy) then
            -- Enemy Team 2 Wins
        end
        IsGameOver = true
    end
end