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
    if (myScrap >= 10 and recyclerExists and (poolsToClaim or looseScrapToClaim) and cpuScavCount < 2) then
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

    -- If the conditions above are true, let the AIP build a Scavenger for pools/scrap.
    if (myScrap >= 20 and recyclerExists and cpuConsCount < 1) then
        return true, "ConstructorBuildLoopCondition: Conditions met. Proceeding...";
    else
        return false, "ConstructorBuildLoopCondition: Conditions unmet. Halting plan.";
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

-- Checks how many Scavengers the CPU has.
function CountCPUScavengers(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SCAVENGER", 'sameteam', true);
end

-- Checks how many Constructors the CPU has.
function CountCPUConstructors(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", 'sameteam', true);
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
function CanSendEarlyScoutToAttackPlayerResources(team, time)
    -- Allow this attack if all of these conditions are met.
    if ((DoesHumanHaveScavengers(team, time) or DoesHumanHaveExtractors(team, time))) then
        return true, "CanSendEarlyScoutToAttackPlayerResources: Conditions met. Proceeding...";
    else 
        return false, "CanSendEarlyScoutToAttackPlayerResources: Conditions unmet. Halting plan. Time is " .. time;
    end
end