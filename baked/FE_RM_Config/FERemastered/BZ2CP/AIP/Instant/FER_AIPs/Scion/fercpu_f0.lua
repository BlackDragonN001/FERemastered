-- File: fercpu_i0.lua
-- Author(s): AI_Unit
-- Summary: Lua conditions for the Scion easy AIP.

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

    -- Check if any pools exist that are currently unclaimed.
    local poolsToClaim = CanCollectScrapPool(team, time);

    -- Check if any loose scrap exists on the map.
    local looseScrapToClaim = CanCollectLooseScrap(team, time);

    -- Keep track of the count of Scavengers we already have to stop overbuilding.
    local cpuScavCount = CountCPUScavengers(team, time);

    -- If the conditions above are true, let the AIP build a Scavenger for pools/scrap.
    if (myScrap >= 20 and (poolsToClaim or looseScrapToClaim) and cpuScavCount < 3) then
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
    if (myScrap >= 40 and recyclerExists and cpuConsCount < 3) then
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

----------------
-- Building Checks
----------------

-- Allow the CPU to build a Kiln.
function BuildKiln(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Count CPU constructors.
    local cpuConsCount = CountCPUConstructors(team, time);

    -- Check if Factory exists.
    local factoryExists = DoesKilnExist(team, time);

    -- If the conditions above are true, let the AIP build a Factory.
    if (myScrap >= 60 and cpuConsCount > 0 and not factoryExists) then
        return true, "BuildKiln: Conditions met. Proceeding...";
    else
        return false, "BuildKiln: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Dower.
function BuildDower(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Count CPU constructors.
    local cpuConsCount = CountCPUConstructors(team, time);

    -- Check if Factory exists.
    local forgeExists = DoesForgeExist(team, time);

    -- Make sure the Dower doesn't exist.
    local dowerExists = DoesDowerExist(team, time);

    -- If the conditions above are true, let the AIP build a Factory.
    if (myScrap >= 60 and cpuConsCount > 0 and forgeExists and not dowerExists) then
        return true, "BuildDower: Conditions met. Proceeding...";
    else
        return false, "BuildDower: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Gun Spire at base
function BuildBaseGunSpire(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Count CPU constructors.
    local cpuConsCount = CountCPUConstructors(team, time);

    -- If the conditions above are true, let the AIP build a Power Plant.
    if (myScrap >= 75 and cpuConsCount > 0) then
        return true, "BuildBaseGunSpire: Conditions met. Proceeding...";
    else
        return false, "BuildBaseGunSpire: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Gun Spire on the gtow1 path.
function BuildGunSpire1(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Check to make sure the path exists first.
    local gtow1Exists = AIPUtil.PathExists("gtow1");

    -- If the conditions above are true, let the AIP build a Gun Tower on gtow1.
    if (myScrap >= 75 and gtow1Exists) then
        return true, "BuildGunSpire1: Conditions met. Proceeding...";
    else
        return false, "BuildGunSpire1: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Gun Spire on the gtow1 path.
function BuildGunSpire2(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Check to make sure the path exists first.
    local gtow2Exists = AIPUtil.PathExists("gtow2");

    -- If the conditions above are true, let the AIP build a Gun Tower on gtow1.
    if (myScrap >= 75 and gtow2Exists) then
        return true, "BuildGunSpire2: Conditions met. Proceeding...";
    else
        return false, "BuildGunSpire2: Conditions unmet. Halting plan.";
    end
end

----------------
-- Exist Checks
----------------

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

-- Checks if the Kiln exists.
function DoesKilnExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_FACTORY", 'sameteam', true) > 0;
end

-- Checks if the Forge exists.
function DoesForgeExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_FACTORY_U", 'sameteam', true) > 0;
end

-- Checks if the Forge exists.
function DoesDowerExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SUPPLYDEPOT", 'sameteam', true) > 0;
end

----------------
-- Counts
----------------

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

-- Check if the player has any Gun Towers.
function CountCPUGunSpires(team, time)
    return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_GUNTOWER", 'sameteam', true) > 0;
end

----------------
-- Human Checks
----------------

-- Check if the player has any Gun Towers.
function DoesHumanHaveGunTowers(team, time)
    return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_GUNTOWER", 'sameteam', true) > 0;
end

----------------
-- Upgrade Checks
----------------

-- Allow the CPU to upgrade their first Extractor.
function UpgradeKiln(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Count CPU constructors.
    local cpuConsCount = CountCPUConstructors(team, time);

    -- Count CPU extractors.
    local doesKilnExist = DoesKilnExist(team, time);

    -- Count CPU Gun Spires.
    local gunSpireCount = CountCPUGunSpires(team, time);

    if (myScrap >= 60 and cpuConsCount >= 1 and gunSpireCount >= 2 and doesKilnExist) then
        return true, "UpgradeKiln: Conditions met. Proceeding...";
    else
        return false, "UpgradeKiln: Conditions unmet. Halting plan.";
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

    if (myScrap >= 60 and cpuConsCount >= 1 and cpuExtractorCount >= 1) then
        return true, "UpgradeFirstExtractor: Conditions met. Proceeding...";
    else
        return false, "UpgradeFirstExtractor: Conditions unmet. Halting plan.";
    end
end

----------------
-- Attack Checks
----------------

-- Send Scouts to attack enemy Pools if we don't have enough.
function SendExtractorAttacks(team, time)
    -- Count CPU extractors.
    local cpuExtractorCount = CountCPUExtractors(team, time);

    -- Allow this attack if all of these conditions are met.
    if (cpuExtractorCount < 3) then
        return true, "SendExtractorAttacks: Conditions met. Proceeding...";
    else 
        return false, "SendExtractorAttacks: Conditions unmet. Halting plan. Time is " .. time;
    end
end

-- Allow for early game harassment by the AI.
function SendEarlyScoutHarassment(team, time)
    -- Make sure Kiln exists.
    local kilnExists = DoesKilnExist(team, time);

    -- Check if Factory exists.
    local forgeExists = DoesForgeExist(team, time);

    -- Allow this attack if all of these conditions are met.
    if (kilnExists and not forgeExists) then
        return true, "SendEarlyScoutHarassment: Conditions met. Proceeding...";
    else 
        return false, "SendEarlyScoutHarassment: Conditions unmet. Halting plan. Time is " .. time;
    end
end

-- Allow for harassment after the Factory has been built.
function SendMediumHarassment(team, time)
    -- Check if Factory exists.
    local forgeExists = DoesForgeExist(team, time);
    
    -- Allow this attack if all of these conditions are met.
    if (forgeExists) then
        return true, "SendMediumHarassment: Conditions met. Proceeding...";
    else 
        return false, "SendMediumHarassment: Conditions unmet. Halting plan. Time is " .. time;
    end
end