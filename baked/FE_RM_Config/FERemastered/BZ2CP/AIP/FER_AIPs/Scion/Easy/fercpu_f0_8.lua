-- File: fercpu_i0.lua
-- Author(s): ScarleTomato
-- Summary: Lua conditions for the Scion easy AIP.

-- Initiate AIP Lua Conditions.
function InitAIPLua(team)
    AIPUtil.print(team, "Running AIP Lua Condition Script for CPU Team: " .. team);
end

function validate(planName, conditions)
  msg = ''
  go = true
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
  return validate('ScavengerBuildLoopCondition', {
    has20Scrap = AIPUtil.GetScrap(team, true) >= 20,
    poolOrFieldExists = CanCollectScrapPool(team, time)
                     or CanCollectLooseScrap(team, time),
    lacks3Scavs = CountCPUScavengers(team, time) < 3
  })
end

-- Condition for letting the CPU build Constructors.
function ConstructorBuildLoopCondition(team, time)
  return validate('ConstructorBuildLoopCondition', {
    has40Scrap = AIPUtil.GetScrap(team, true) >= 40,
    recyclerExists = DoesRecyclerExist(team, time)
  })
end

-- Condition for letting the CPU build Turrets.
function TurretBuildLoopCondition(team, time)
  return validate('TurretBuildLoopCondition', {
    scrapOver45 = AIPUtil.GetScrap(team, true) >= 45,
    recyclerExists = DoesRecyclerExist(team, time)
  })
end

function ServiceTruckBuildLoopCondition(team, time)
  return validate('ServiceTruckBuildLoopCondition', {
    hasScrap = AIPUtil.GetScrap(team, true) >= 50,
    recyExists = DoesRecyclerExist(team, time),
    sbayExists = DoesDowerExist(team, time)
  })
end

----------------
-- Building Checks
----------------

-- Allow the CPU to build a Kiln.
function BuildKiln(team, time)
  return validate('BuildKiln', {
    scrapOver60 = AIPUtil.GetScrap(team, true) >= 60,
    hasCons = CountCPUConstructors(team, time) > 0,
    lacksKiln = not DoesKilnExist(team, time)
  })
end

-- Allow the CPU to build an Antenna.
function BuildAntenna(team, time)
  return validate('BuildAntenna', {
    scrapOver60 = AIPUtil.GetScrap(team, true) >= 60,
    recyclerExists = DoesRecyclerExist(team, time),
    consExist = CountCPUConstructors(team, time) > 0,
    factoryExists = DoesKilnExist(team, time),
    noAntennaExists = not DoesAntennaExist(team, time)
  })
end

-- Allow the CPU to build a Stronghold.
function BuildStronghold(team, time)
  return validate('BuildStronghold', {
    scrapOver70 = AIPUtil.GetScrap(team, true) >= 70,
    consExist = CountCPUConstructors(team, time) > 0,
    forgeExists = DoesForgeExist(team, time),
    lacksStronghold = not DoesStrongholdExist(team, time)
  })
end

-- Allow the CPU to build a Jammer.
function BuildJammer(team, time)
  return validate('BuildJammer', {
    scrapOver50 = AIPUtil.GetScrap(team, true) >= 50,
    consExist = CountCPUConstructors(team, time) > 0,
    overseerExists = DoesOverseerExist(team, time),
    lacksJammer = DoesJammerExist(team, time)
  })
end

-- Allow the CPU to build a Dower.
function BuildDower(team, time)
  return validate('BuildDower', {
    scrapOver60 = AIPUtil.GetScrap(team, true) >= 60,
    consExist = CountCPUConstructors(team, time) > 0,
    hasForge = DoesForgeExist(team, time),
    lacksDower = not DoesDowerExist(team, time)
  })
end

-- Allow the CPU to build a Gun Spire at base
function BuildBaseGunSpire(team, time)
  return validate('BuildBaseGunSpire', {
    scrapOver75 = AIPUtil.GetScrap(team, true) >= 75,
    consExist = CountCPUConstructors(team, time) > 0
  })
end

-- Allow the CPU to build a Gun Spire on the gtow1 path.
function BuildGunSpire1(team, time)
  return validate('BuildGunSpire1', {
    hasScrap = AIPUtil.GetScrap(team, true) >= 75,
    gtow1Exists = AIPUtil.PathExists("8_gtow1")
  })
end
function BuildGunSpire2(team, time)
  return validate('BuildGunSpire2', {
    hasScrap = AIPUtil.GetScrap(team, true) >= 75,
    gtow1Exists = AIPUtil.PathExists("8_gtow2")
  })
end
function BuildGunSpire3(team, time)
  return validate('BuildGunSpire3', {
    hasScrap = AIPUtil.GetScrap(team, true) >= 75,
    gtow1Exists = AIPUtil.PathExists("8_gtow3")
  })
end
function BuildGunSpire4(team, time)
  return validate('BuildGunSpire4', {
    hasScrap = AIPUtil.GetScrap(team, true) >= 75,
    gtow1Exists = AIPUtil.PathExists("8_gtow4")
  })
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
function DoesStrongholdExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_ARMORY", 'sameteam', true) > 0;
end

-- Checks if the Kiln exists.
function DoesAntennaExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMBUNKER", 'sameteam', true) > 0;
end

-- Checks if the Forge exists.
function DoesOverseerExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMBUNKER_U", 'sameteam', true) > 0;
end

-- Checks if the Forge exists.
function DoesDowerExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SUPPLYDEPOT", 'sameteam', true) > 0;
end

-- Checks if the Forge exists.
function DoesJammerExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_JAMMER", 'sameteam', true) > 0;
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
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR_UPGRADED", 'sameteam', true);
end

-- Checks how many Gun Towers the CPU has.
function CountCPUGunSpires(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_GUNTOWER", 'sameteam', true);
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

-- Allow the CPU to upgrade their Kiln.
function UpgradeKiln(team, time)
  return validate('UpgradeKiln', {
    hasScrap = AIPUtil.GetScrap(team, true) >= 60,
    cpuConsCount = CountCPUConstructors(team, time) >= 1,
    gunSpireCount = CountCPUGunSpires(team, time) >= 2,
    doesKilnExist = DoesKilnExist(team, time),
    noForgeExist = not DoesForgeExist(team, time)
  })
end

-- Allow the CPU to upgrade their Antenna.
function UpgradeAntenna(team, time)
  return validate('UpgradeAntenna', {
    hasScrap = AIPUtil.GetScrap(team, true) >= 80,
    cpuConsCount = CountCPUConstructors(team, time) >= 1,
    doesAntennaExist = DoesAntennaExist(team, time),
    noOverseerExist = not DoesOverseerExist(team, time)
  })
end

-- Allow the CPU to upgrade their first Extractor.
function UpgradeFirstExtractor(team, time)
  return validate('UpgradeFirstExtractor', {
    hasScrap = AIPUtil.GetScrap(team, true) >= 60,
    cpuConsCount = CountCPUConstructors(team, time) >= 1,
    has1Extractors = CountCPUExtractors(team, time) >= 1,
    lacks1Upgraded = CountCPUUpgradedExtractors(team, time) < 1
  })
end
function UpgradeSecondExtractor(team, time)
  return validate('UpgradeSecondExtractor', {
    hasScrap = AIPUtil.GetScrap(team, true) >= 60,
    cpuConsCount = CountCPUConstructors(team, time) >= 1,
    has2Extractors = CountCPUExtractors(team, time) >= 2,
    lacks2Upgraded = CountCPUUpgradedExtractors(team, time) < 2
  })
end
function UpgradeThirdExtractor(team, time)
  return validate('UpgradeThirdExtractor', {
    hasScrap = AIPUtil.GetScrap(team, true) >= 60,
    cpuConsCount = CountCPUConstructors(team, time) >= 1,
    has3Extractors = CountCPUExtractors(team, time) >= 3,
    lacks3Upgraded = CountCPUUpgradedExtractors(team, time) < 3
  })
end
function UpgradeFourthExtractor(team, time)
  return validate('UpgradeFourthExtractor', {
    hasScrap = AIPUtil.GetScrap(team, true) >= 60,
    cpuConsCount = CountCPUConstructors(team, time) >= 1,
    has4Extractors = CountCPUExtractors(team, time) >= 4,
    lacks4Upgraded = CountCPUUpgradedExtractors(team, time) < 4
  })
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

-- Allow for harassment after the Factory and Antenna has been built.
function SendLancerHarassment(team, time)
  return validate('SendLancerHarassment', {
    kilnExists = DoesKilnExist(team, time),
    antennaExists = DoesAntennaExist(team, time)
  })
end

-- Allow for harassment after the Factory has been built.
function SendMediumHarassment(team, time)
  return validate('SendMediumHarassment', {
    kilnExists = DoesKilnExist(team, time)
  })
end

-- Allow for harassment after the Factory has been built.
function SendTankHarassment(team, time)
  return validate('SendTankHarassment', {
    forgeExists = DoesForgeExist(team, time)
  })
end

-- Can I attack with tanks, lancers or walkers?
function SendAssaultHarassment(team, time)
  return validate('SendAssaultHarassment', {
    kilnExists = DoesKilnExist(team, time),
    antOrForgeExists = DoesAntennaExist(team, time)
                    or DoesForgeExist(team, time)
  })
end

-- Can I attack with tanks, lancers or walkers?
function SendArcherAttacks(team, time)
  return validate('SendArcherAttacks', {
    forgeExists = DoesKilnExist(team, time),
    overseerExists = DoesOverseerExist(team, time)
  })
end

-- Anti Gun Tower attack.
function SendGunTowerAttacks(team, time)
  return validate('SendGunTowerAttacks', {
    unitsAvailable = SendTankHarassment(team, time)
                  or SendAssaultHarassment(team, time)
                  or SendArcherAttacks(team, time),
    humanHasGunTowers = DoesHumanHaveGunTowers(team, time)
  })
end

-- End game units are available
function SendTechnicalAttacks(team, time)
  return validate('SendTechnicalAttacks', {
    forgeExists = DoesForgeExist(team, time),
    OverseerExists = DoesOverseerExist(team, time)
  })
end