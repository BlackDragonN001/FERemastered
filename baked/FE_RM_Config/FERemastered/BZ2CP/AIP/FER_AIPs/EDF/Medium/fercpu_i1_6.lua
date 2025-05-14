-- File: fercpu_i1.lua
-- Author(s): AI_Unit
-- Summary: Lua conditions for the EDF medium AIP.

function InitAIPLua(team)
    AIPUtil.print(team, "Running AIP Lua Condition Script for CPU Team: " .. team);
end

function Validate(planName, conditions)
    local msg = '';
    local go = true;

    for k, v in pairs(conditions) do
        msg = msg .. k .. ':' .. tostring(v) .. ' '
        go = go and v
    end

    if (go) then
        return true, planName .. ": " .. msg .. ". Proceeding...";
    else
        return false, planName .. ": " .. msg .. ". Halting plan.";
    end
end

----------------
-- Map Checks
----------------
function DoesVacantScrapPoolExist(team, time)
    return AIPUtil.CountUnits(team, "biometal", "friendly", true) > 0;
end

function DoesLooseScrapExist(team, time)
    return AIPUtil.CountUnits(team, "resource", "friendly", true) > 0;
end

----------------
-- Unit Checks
----------------
function ScavengerBuildLoopCondition(team, time)
    return Validate('ScavengerBuildLoopCondition', {
        myScrap = AIPUtil.GetScrap(team, true) >= 20,
        poolsOrLooseToClaim = CanCollectScrapPool(team, time) or CanCollectLooseScrap(team, time),
        cpuScavCount = CountCPUScavengers(team, time) < 2
    })
end

function ConstructorBuildLoopCondition(team, time)
    return Validate('ConstructorBuildLoopCondition', {
        myScrap = AIPUtil.GetScrap(team, true) >= 40,
        recyclerExists = DoesRecyclerExist(team, time),
        cpuConsCount = CountCPUConstructors(team, time) < 1
    })
end

function TurretBuildLoopCondition(team, time)
    return Validate('TurretBuildLoopCondition', {
        myScrap = AIPUtil.GetScrap(team, true) >= 40,
        recyclerExists = DoesRecyclerExist(team, time)
    })
end

function GunTowerConstructorBuildLoopCondition(team, time)
    return Validate('GunTowerConstructorBuildLoopCondition', {
        myScrap = AIPUtil.GetScrap(team, true) >= 40,
        recyclerExists = DoesRecyclerExist(team, time)
    })
end

----------------
-- Building Checks
----------------
function BuildPowerGenerator(team, time)
    return Validate('BuildPowerGenerator', {
        myScrap = AIPUtil.GetScrap(team, true) >= 30,
        cpuConsCount = CountCPUConstructors(team, time) > 0,
        powerCount = CountCPUPower(team, time) <= 0
    })
end

function BuildFactory(team, time)
    return Validate('BuildFactory', {
        myScrap = AIPUtil.GetScrap(team, true) >= 55,
        cpuConsCount = CountCPUConstructors(team, time) > 0,
        powerCount = AIPUtil.GetPower(team, true) > 0,
        factoryExists = not DoesFactoryExist(team, time)
    })
end

function BuildArmory(team, time)
    return Validate('BuildArmory', {
        myScrap = AIPUtil.GetScrap(team, true) >= 60,
        cpuConsCount = CountCPUConstructors(team, time) > 0,
        powerCount = AIPUtil.GetPower(team, true) > 0,
        armoryExists = not DoesArmoryExist(team, time)
    })
end

function BuildCommBunker(team, time)
    return Validate('BuildCommBunker', {
        myScrap = AIPUtil.GetScrap(team, true) >= 50,
        cpuConsCount = CountCPUConstructors(team, time) > 0,
        powerCount = AIPUtil.GetPower(team, true) > 0,
        commBunkerExists = not DoesCommBunkerExist(team, time)
    })
end

function BuildServiceBay(team, time)
    return Validate('BuildServiceBay', {
        myScrap = AIPUtil.GetScrap(team, true) >= 50,
        cpuConsCount = CountCPUConstructors(team, time) > 0,
        powerCount = AIPUtil.GetPower(team, true) > 0,
        serviceBayExists = not DoesServiceBayExist(team, time)
    })
end

function BuildGunTower1(team, time)
    return Validate('BuildGunTower1', {
        myScrap = AIPUtil.GetScrap(team, true) >= 50,
        gtow1Exists = AIPUtil.PathExists("6_gtow1")
    })
end

function BuildGunTower2(team, time)
    return Validate('BuildGunTower2', {
        myScrap = AIPUtil.GetScrap(team, true) >= 50,
        gtow2Exists = AIPUtil.PathExists("6_gtow2")
    })
end

function BuildGunTower3(team, time)
    return Validate('BuildGunTower3', {
        myScrap = AIPUtil.GetScrap(team, true) >= 50,
        gtow3Exists = AIPUtil.PathExists("6_gtow3")
    })
end

function BuildGunTower4(team, time)
    return Validate('BuildGunTower4', {
        myScrap = AIPUtil.GetScrap(team, true) >= 50,
        gtow4Exists = AIPUtil.PathExists("6_gtow4")
    })
end

----------------
-- Exist Checks
----------------
function CanCollectScrapPool(team, time)
    return Validate('CanCollectScrapPool', {
        hasRecycler = DoesRecyclerExist(team, time),
        hasPool = DoesVacantScrapPoolExist(team, time)
    })
end

function CanCollectLooseScrap(team, time)
    return Validate('CanCollectLooseScrap', {
        hasRecycler = DoesRecyclerExist(team, time),
        hasField = DoesLooseScrapExist(team, time)
    })
end

function DoesRecyclerExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_RECYCLERBUILDING", 'sameteam', true) > 0;
end

function DoesFactoryExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_FACTORY", 'sameteam', true) > 0;
end

function DoesCommBunkerExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMBUNKER", 'sameteam', true) > 0;
end

function DoesArmoryExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_ARMORY", 'sameteam', true) > 0;
end

function DoesServiceBayExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SUPPLYDEPOT", 'sameteam', true) > 0;
end

----------------
-- Counts
----------------
function CountCPUScavengers(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SCAVENGER", 'sameteam', true);
end

function CountCPUConstructors(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", 'sameteam', true);
end

function CountCPUPower(team, time)
    return AIPUtil.GetPower(team, false);
end

function CountCPUExtractors(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR", 'sameteam', true);
end

----------------
-- Upgrade Checks
----------------
function UpgradeFirstExtractor(team, time)
    return Validate('UpgradeFirstExtractor', {
        myScrap = AIPUtil.GetScrap(team, true) >= 60,
        cpuConsCount = CountCPUConstructors(team, time) >= 1,
        cpuExtractorCount = CountCPUExtractors(team, time) >= 1
    })
end

function UpgradeSecondExtractor(team, time)
    return Validate('UpgradeSecondExtractor', {
        myScrap = AIPUtil.GetScrap(team, true) >= 60,
        cpuConsCount = CountCPUConstructors(team, time) >= 1,
        cpuExtractorCount = CountCPUExtractors(team, time) >= 2
    })
end

function UpgradeThirdExtractor(team, time)
    return Validate('UpgradeThirdExtractor', {
        myScrap = AIPUtil.GetScrap(team, true) >= 60,
        cpuConsCount = CountCPUConstructors(team, time) >= 1,
        cpuExtractorCount = CountCPUExtractors(team, time) >= 3
    })
end

function UpgradeFourthExtractor(team, time)
    return Validate('UpgradeFourthExtractor', {
        myScrap = AIPUtil.GetScrap(team, true) >= 60,
        cpuConsCount = CountCPUConstructors(team, time) >= 1,
        cpuExtractorCount = CountCPUExtractors(team, time) >= 4
    })
end

----------------
-- Attack Checks
----------------
function SendExtractorAttacks(team, time)
    return Validate('SendExtractorAttacks', {
        cpuExtractorCount = CountCPUExtractors(team, time) < 3
    })
end

function SendMediumHarassment(team, time)
    return Validate('SendMediumHarassment', {
        factoryExists = DoesFactoryExist(team, time)
    })
end

function SendArtilleryHarassment(team, time)
    return Validate('SendArtilleryHarassment', {
        factoryExists = DoesFactoryExist(team, time),
        armoryExists = DoesArmoryExist(team, time)
    })
end

function SendTankHarassment(team, time)
    return Validate('SendTankHarassment', {
        factoryExists = DoesFactoryExist(team, time),
        commBunkerExists = DoesCommBunkerExist(team, time)
    })
end
