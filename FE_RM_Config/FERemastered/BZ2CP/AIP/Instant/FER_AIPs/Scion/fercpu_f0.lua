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
    if (myScrap >= 40 and recyclerExists and cpuConsCount < 2) then
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

-- Condition for letting the CPU build Service Trucks.
function ServiceTruckBuildLoopCondition(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Does the Recycler exist?
    local recyclerExists = DoesRecyclerExist(team, time);

    -- Does the Service Bay exist?
    local serviceBayExists = DoesServiceBayExist(team, time);

    -- If the conditions above are true, let the AIP build a Turret.
    if (myScrap >= 50 and recyclerExists and serviceBayExists) then
        return true, "ServiceTruckBuildLoopCondition: Conditions met. Proceeding...";
    else
        return false, "ServiceTruckBuildLoopCondition: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Gun Tower at base
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

-- Allow the CPU to build a Gun Spire on the gtow2 path.
function BuildGunSpire2(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Check to make sure the path exists first.
    local gtow2Exists = AIPUtil.PathExists("gtow2");

    -- If the conditions above are true, let the AIP build a Gun Tower on gtow2.
    if (myScrap >= 75 and gtow2Exists) then
        return true, "BuildGunSpire2: Conditions met. Proceeding...";
    else
        return false, "BuildGunSpire2: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Gun Spire on the gtow3 path.
function BuildGunSpire3(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Check to make sure the path exists first.
    local gtow3Exists = AIPUtil.PathExists("gtow3");

    -- If the conditions above are true, let the AIP build a Gun Tower on gtow3.
    if (myScrap >= 75 and gtow3Exists) then
        return true, "BuildGunSpire3: Conditions met. Proceeding...";
    else
        return false, "BuildGunSpire3: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Gun Spire on the gtow4 path.
function BuildGunSpire4(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Check to make sure the path exists first.
    local gtow4Exists = AIPUtil.PathExists("gtow4");

    -- If the conditions above are true, let the AIP build a Gun Tower on gtow4.
    if (myScrap >= 75 and gtow4Exists) then
        return true, "BuildGunSpire4: Conditions met. Proceeding...";
    else
        return false, "BuildGunSpire4: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to build a Kiln.
function BuildKiln(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Count CPU Builders.
    local cpuConsCount = CountCPUConstructors(team, time);

    -- Check if Kiln exists.
    local factoryExists = DoesKilnExist(team, time);

    -- If the conditions above are true, let the AIP build a Kiln.
    if (myScrap >= 60 and cpuConsCount > 0 and not factoryExists) then
        return true, "BuildKiln: Conditions met. Proceeding...";
    else
        return false, "BuildKiln: Conditions unmet. Halting plan.";
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

-- Checks if the Kiln exists.
function DoesKilnExist(team, time)
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
-- Upgrade Checks
----------------

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

-- Allow the CPU to upgrade their second Extractor.
function UpgradeSecondExtractor(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Count CPU constructors.
    local cpuConsCount = CountCPUConstructors(team, time);

    -- Count CPU extractors.
    local cpuExtractorCount = CountCPUExtractors(team, time);

    -- Count CPU Upgraded extractors.
    local cpuUpgradedExtractorCount = CountCPUUpgradedExtractors(team, time);

    if (myScrap >= 60 and cpuConsCount >= 1 and cpuExtractorCount >= 2 and cpuUpgradedExtractorCount <= 2) then
        return true, "UpgradeSecondExtractor: Conditions met. Proceeding...";
    else
        return false, "UpgradeSecondExtractor: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to upgrade their third Extractor.
function UpgradeThirdExtractor(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);

    -- Count CPU constructors.
    local cpuConsCount = CountCPUConstructors(team, time);

    -- Count CPU extractors.
    local cpuExtractorCount = CountCPUExtractors(team, time);

    -- Count CPU Upgraded extractors.
    local cpuUpgradedExtractorCount = CountCPUUpgradedExtractors(team, time);

    if (myScrap >= 60 and cpuConsCount >= 1 and cpuExtractorCount >= 3 and cpuUpgradedExtractorCount <= 3) then
        return true, "UpgradeThirdExtractor: Conditions met. Proceeding...";
    else
        return false, "UpgradeThirdExtractor: Conditions unmet. Halting plan.";
    end
end

-- Allow the CPU to upgrade their Kiln.
function UpgradeKiln(team, time)
    -- Get my scrap in a local variable.
    local myScrap = AIPUtil.GetScrap(team, true);
    
    -- Count CPU constructors.
    local cpuConsCount = CountCPUConstructors(team, time);
   
    -- Check if the Kiln exists.
    local kilnExists = DoesKilnExist(team, time);

    if (myScrap >= 60 and cpuConsCount >= 1 and kilnExists) then
        return true, "UpgradeKiln: Conditions met. Proceeding...";
    else
        return false, "UpgradeKiln: Conditions met. Proceeding...";
    end
end

----------------
-- Attack Checks
----------------

-- Allow for early game harassment by the AI.
function SendEarlyScoutHarassment(team, time)
    -- Check if Factory exists.
    local kilnExists = DoesKilnExist(team, time);

    -- Allow this attack if all of these conditions are met.
    if (not kilnExists) then
        return true, "SendEarlyScoutHarassment: Conditions met. Proceeding...";
    else 
        return false, "SendEarlyScoutHarassment: Conditions unmet. Halting plan. Time is " .. time;
    end
end

-- Allow for medium game harassment by the AI.
function SendMediumHarassment(team, time)
    -- Check if Factory exists.
    local kilnExists = DoesKilnExist(team, time);
    
    -- Allow this attack if all of these conditions are met.
    if (kilnExists) then
        return true, "SendMediumHarassment: Conditions met. Proceeding...";
    else 
        return false, "SendMediumHarassment: Conditions unmet. Halting plan. Time is " .. time;
    end
end