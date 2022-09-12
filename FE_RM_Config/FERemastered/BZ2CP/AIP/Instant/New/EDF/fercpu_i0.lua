-- File: fercpu_i0.lua
-- Author(s): AI_Unit
-- Summary: Lua conditions for the EDF easy AIP.

-- Initiate AIP Lua Conditions.
function InitAIPLua(team)
    AIPUtil.print(team, "Running AIP Lua Condition Script for CPU Team: " .. team);
end

----------------
-- Map Checks
----------------

-- Check if any vacant pools exist on the map.
function DoesVacantScrapPoolExist(team, time)
    return AIPUtil.CountUnits(team, "biometal", "friendly", true) > 0;
end

-- Check if any scrap exists on the map.
function DoesLooseScrapExist(team, time)
    return AIPUtil.CountUnits(team, "resource", "friendly", true) > 0;
end

----------------
-- CPU Checks
----------------

-- Condition for letting the CPU build Scavengers.
function ScavengerBuildLoopCondition(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Does the Recycler exist?
    local recyclerExists = DoesRecyclerExist(team, time);

    -- Check if any pools exist that are currently unclaimed.
    local poolsToClaim = DoesVacantScrapPoolExist(team, time);

    -- Check if any loose scrap exists on the map.
    local looseScrapToClaim = DoesLooseScrapExist(team, time);

    -- Keep track of the count of Scavengers we already have to stop overbuilding.
    local cpuScavCount = CountCPUScavengers(team, time);

    -- If the conditions above are true, let the AIP build a Scavenger for pools/scrap.
    if (myScrap >= 20 and recyclerExists and (poolsToClaim or looseScrapToClaim) and cpuScavCount < 2) then
        return true, "ScavengerBuildLoopCondition: Conditions met. Proceeding...";
    else
        return false, "ScavengerBuildLoopCondition: Conditions unmet. Halting plan.";
    end
end

-- Condition for letting the CPU build Constructors.
function ConstructorBuildLoopCondition(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Does the Recycler exist?
    local recyclerExists = DoesRecyclerExist(team, time);

    -- Keep track of the count of Scavengers we already have to stop overbuilding.
    local cpuConsCount = CountCPUConstructors(team, time);

    -- If the conditions above are true, let the AIP build a Constructor.
    if (myScrap >= 40 and recyclerExists and cpuConsCount < 1) then
        return true, "ConstructorBuildLoopCondition: Conditions met. Proceeding...";
    else
        return false, "ConstructorBuildLoopCondition: Conditions unmet. Halting plan.";
    end
end

-- Condition for letting the CPU build Turrets.
function TurretBuildLoopCondition(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Does the Recycler exist?
    local recyclerExists = DoesRecyclerExist(team, time);

    -- If the conditions above are true, let the AIP build a Turret.
    if (myScrap >= 40 and recyclerExists) then
        return true, "TurretBuildLoopCondition: Conditions met. Proceeding...";
    else
        return false, "TurretBuildLoopCondition: Conditions unmet. Halting plan.";
    end
end

-- Condition for letting the CPU build Gun Tower Constructors.
function GunTowerConstructorBuildLoopCondition(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Does the Recycler exist?
    local recyclerExists = DoesRecyclerExist(team, time);

    -- If the conditions above are true, let the AIP build a Constructor.
    if (myScrap >= 40 and recyclerExists) then
        return true, "GunTowerConstructorBuildLoopCondition: Conditions met. Proceeding...";
    else
        return false, "GunTowerConstructorBuildLoopCondition: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Gun Tower on the gtow1 path.
function BuildGunTower1(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Check to make sure the path exists first.
    local gtow1Exists = AIPUtil.PathExists("gtow1");

    -- If the conditions above are true, let the AIP build a Gun Tower on gtow1.
    if (myScrap >= 50 and gtow1Exists) then
        return true, "BuildGunTower1: Conditions met. Proceeding...";
    else
        return false, "BuildGunTower1: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Gun Tower on the gtow2 path.
function BuildGunTower2(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Check to make sure the path exists first.
    local gtow2Exists = AIPUtil.PathExists("gtow2");

    -- If the conditions above are true, let the AIP build a Gun Tower on gtow2.
    if (myScrap >= 50 and gtow2Exists) then
        return true, "BuildGunTower2: Conditions met. Proceeding...";
    else
        return false, "BuildGunTower2: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Gun Tower on the gtow3 path.
function BuildGunTower3(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Check to make sure the path exists first.
    local gtow3Exists = AIPUtil.PathExists("gtow3");

    -- If the conditions above are true, let the AIP build a Gun Tower on gtow3.
    if (myScrap >= 50 and gtow3Exists) then
        return true, "BuildGunTower3: Conditions met. Proceeding...";
    else
        return false, "BuildGunTower3: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Gun Tower on the gtow4 path.
function BuildGunTower4(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Check to make sure the path exists first.
    local gtow4Exists = AIPUtil.PathExists("gtow4");

    -- If the conditions above are true, let the AIP build a Gun Tower on gtow4.
    if (myScrap >= 50 and gtow4Exists) then
        return true, "BuildGunTower4: Conditions met. Proceeding...";
    else
        return false, "BuildGunTower4: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Power Generator
function BuildPowerGenerator(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Count CPU constructors.
    local cpuConsCount = CountCPUConstructors(team, time);

    -- If the conditions above are true, let the AIP build a Power Plant.
    if (myScrap >= 30 and cpuConsCount > 0) then
        return true, "BuildPowerGenerator: Conditions met. Proceeding...";
    else
        return false, "BuildPowerGenerator: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Factory.
function BuildFactory(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Count CPU constructors.
    local cpuConsCount = CountCPUConstructors(team, time);

    -- Check our Power levels.
    local powerCount = AIPUtil.GetPower(team, true);

    -- Check if Factory exists.
    local factoryExists = DoesFactoryExist(team, time);

    -- If the conditions above are true, let the AIP build a Power Plant.
    if (myScrap >= 55 and cpuConsCount > 0 and powerCount > 0 and not factoryExists) then
        return true, "BuildFactory: Conditions met. Proceeding...";
    else
        return false, "BuildFactory: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to upgrade their first Extractor.
function UpgradeFirstExtractor(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Count CPU constructors.
    local cpuConsCount = CountCPUConstructors(team, time);

    -- Count CPU extractors.
    local cpuExtractorCount = CountCPUExtractors(team, time);

    -- Count CPU Upgraded extractors.
    local cpuUpgradedExtractorCount = CountCPUUpgradedExtractors(team, time);

    if (myScrap >= 60 and cpuConsCount >= 1 and cpuExtractorCount >= 1 and cpuUpgradedExtractorCount <= 0) then
        return true, "UpgradeFirstExtractor: Conditions met. Proceeding...";
    else
        return false, "UpgradeFirstExtractor: Conditions unmet. Halting plan.";
    end
end

-- Condition for trying to collect pools.
function CanCollectScrapPool(team, time)
    if (DoesRecyclerExist(team, time) and DoesVacantScrapPoolExist(team, time)) then
        return true, "CanCollectScrapPool: Conditions met. Proceeding...";
    else
        return false, "CanCollectScrapPool: Conditions unmet. Halting plan.";
    end
end

-- Condition for trying to collect scrap.
function CanCollectLooseScrap(team, time)
    if (DoesRecyclerExist(team, time) and DoesLooseScrapExist(team, time)) then
        return true, "CanCollectLooseScrap: Conditions met. Proceeding...";
    else
        return false, "CanCollectLooseScrap: Conditions unmet. Halting plan.";
    end
end

-- Checks if the Recycler exists.
function DoesRecyclerExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_RECYCLERBUILDING", 'sameteam', true) > 0;
end

-- Checks if the Factory exists.
function DoesFactoryExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_FACTORY", 'sameteam', true) > 0;
end

-- Checks how many Scavengers the CPU has.
function CountCPUScavengers(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SCAVENGER", 'sameteam', true);
end

-- Checks how many Constructors the CPU has.
function CountCPUConstructors(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", 'sameteam', true);
end

-- Checks how many Extractors the CPU has.
function CountCPUExtractors(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR", 'sameteam', true);
end

-- Checks how many upgraded Extractors the CPU has.
function CountCPUUpgradedExtractors(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR_Upgraded", 'sameteam', true);
end

----------------
-- Human Checks
----------------

-- Check if the player has any Scavengers.
function DoesHumanHaveScavengers(team, time)
    return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_SCAVENGER", 'sameteam', true) > 0;
end

-- Check if the player has any Extractors.
function DoesHumanHaveExtractors(team, time)
    return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_EXTRACTOR", 'sameteam', true) > 0;
end

----------------
-- Attack Checks
----------------

-- Allow for early game harassment by the AI.
function SendEarlyScoutHarassment(team, time)
    -- Check if Factory exists.
    local factoryExists = DoesFactoryExist(team, time);

    -- Allow this attack if all of these conditions are met.
    if (not factoryExists) then
        return true, "SendEarlyScoutHarassment: Conditions met. Proceeding...";
    else 
        return false, "SendEarlyScoutHarassment: Conditions unmet. Halting plan. Time is " .. time;
    end
end

-- Allow for early game harassment after the factory has been built by the AI.
