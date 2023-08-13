-- File: fercpu_i0.lua
-- Author(s): AI_Unit
-- Summary: Lua conditions for the EDF easy AIP.

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
-- Unit Checks
----------------

-- Condition for letting the CPU build Scavengers.
function ScavengerBuildLoopCondition(team, time)
  return validate('ScavengerBuildLoopCondition', {
    myScrap = AIPUtil.GetScrap(team, true) >= 20,
    poolsOrLooseToClaim = CanCollectScrapPool(team, time)
                             or CanCollectLooseScrap(team, time),
    cpuScavCount = CountCPUScavengers(team, time) < 3
  })
end

-- Condition for letting the CPU build Constructors.
function ConstructorBuildLoopCondition(team, time)
  return validate('ConstructorBuildLoopCondition', {
    myScrap = AIPUtil.GetScrap(team, true) >= 40,
    recyclerExists = DoesRecyclerExist(team, time),
    cpuConsCount = CountCPUConstructors(team, time) < 1
  })
end

-- Condition for letting the CPU build Turrets.
function TurretBuildLoopCondition(team, time)
  return validate('TurretBuildLoopCondition', {
    myScrap = AIPUtil.GetScrap(team, true) >= 40,
    recyclerExists = DoesRecyclerExist(team, time)
  })
end

-- Condition for letting the CPU build Service Trucks.
function ServiceTruckBuildLoopCondition(team, time)
  return validate('ServiceTruckBuildLoopCondition', {
    myScrap = AIPUtil.GetScrap(team, true) >= 50,
    recyclerExists = DoesRecyclerExist(team, time),
    serviceBayExists = DoesServiceBayExist(team, time)
  })
end

-- Condition for letting the CPU build Gun Tower Constructors.
function GunTowerConstructorBuildLoopCondition(team, time)
  return validate('GunTowerConstructorBuildLoopCondition', {
    myScrap = AIPUtil.GetScrap(team, true) >= 40,
    recyclerExists = DoesRecyclerExist(team, time)
  })
end

-- Condition for letting the CPU build a Bomber.
function BomberBuildLoopCondition(team, time)
  return validate('BomberBuildLoopCondition', {
    myScrap = AIPUtil.GetScrap(team, true) >= 75,
    factoryExists = DoesFactoryExist(team, time),
    bomberBayExists = DoesBomberBayExist(team, time),
    bomberExists = not DoesBomberExist(team, time)
  })
end

----------------
-- Building Checks
----------------

-- Allow the CPU to build a Gun Tower on the gtow1 path.
function BuildGunTower1(team, time)
  return validate('BuildGunTower1', {
    myScrap = AIPUtil.GetScrap(team, true) >= 50,
    gtow1Exists = AIPUtil.PathExists("gtow1")
  })
end

-- Allow the CPU to build a Gun Tower on the gtow2 path.
function BuildGunTower2(team, time)
  return validate('BuildGunTower2', {
    myScrap = AIPUtil.GetScrap(team, true) >= 50,
    gtow2Exists = AIPUtil.PathExists("gtow2")
  })
end

-- Allow the CPU to build a Gun Tower on the gtow3 path.
function BuildGunTower3(team, time)
  return validate('BuildGunTower3', {
    myScrap = AIPUtil.GetScrap(team, true) >= 50,
    gtow3Exists = AIPUtil.PathExists("gtow3")
  })
end

-- Allow the CPU to build a Gun Tower on the gtow4 path.
function BuildGunTower4(team, time)
  return validate('BuildGunTower4', {
    myScrap = AIPUtil.GetScrap(team, true) >= 50,
    gtow4Exists = AIPUtil.PathExists("gtow4")
  })
end

-- Allow the CPU to build a Power Generator
function BuildPowerGenerator(team, time)
  return validate('BuildPowerGenerator', {
    myScrap = AIPUtil.GetScrap(team, true) >= 30,
    cpuConsCount = CountCPUConstructors(team, time) > 0,
    powerCount = CountCPUPower(team, time) <= 0
  })
end

-- Allow the CPU to build a Factory.
function BuildFactory(team, time)
  return validate('BuildFactory', {
    myScrap = AIPUtil.GetScrap(team, true) >= 55,
    cpuConsCount = CountCPUConstructors(team, time) > 0,
    powerCount = AIPUtil.GetPower(team, true) > 0,
    factoryExists = not DoesFactoryExist(team, time)
  })
end

-- Allow the CPU to build an Armory.
function BuildArmory(team, time)
  return validate('BuildArmory', {
    myScrap = AIPUtil.GetScrap(team, true) >= 60,
    cpuConsCount = CountCPUConstructors(team, time) > 0,
    powerCount = AIPUtil.GetPower(team, true) > 0,
    armoryExists = not DoesArmoryExist(team, time)
  })
end

-- Allow the CPU to build a Comm Bunker.
function BuildCommBunker(team, time)
  return validate('BuildCommBunker', {
    myScrap = AIPUtil.GetScrap(team, true) >= 50,
    cpuConsCount = CountCPUConstructors(team, time) > 0,
    powerCount = AIPUtil.GetPower(team, true) > 0,
    commBunkerExists = not DoesCommBunkerExist(team, time)
  })
end

-- Allow the CPU to build a Service Bay
function BuildServiceBay(team, time)
  return validate('BuildServiceBay', {
    myScrap = AIPUtil.GetScrap(team, true) >= 50,
    cpuConsCount = CountCPUConstructors(team, time) > 0,
    powerCount = AIPUtil.GetPower(team, true) > 0,
    serviceBayExists = not DoesServiceBayExist(team, time)
  })
end

-- Allow the CPU to build a Training Center
function BuildTraningCenter(team, time)
  return validate('BuildTraningCenter', {
    myScrap = AIPUtil.GetScrap(team, true) >= 70,
    cpuConsCount = CountCPUConstructors(team, time) > 0,
    powerCount = AIPUtil.GetPower(team, true) > 0,
    trainingCenterExists = not DoesTrainingCenterExist(team, time)
  })
end

-- Allow the CPU to build a Tech Center.
function BuildTechCenter(team, time)
  return validate('BuildTechCenter', {
    myScrap = AIPUtil.GetScrap(team, true) >= 80,
    cpuConsCount = CountCPUConstructors(team, time) > 0,
    powerCount = AIPUtil.GetPower(team, true) > 0,
    techCenterExists = not DoesTechCenterExist(team, time)
  })
end

-- Allow the CPU to build a Bomber Bay
function BuildBomberBay(team, time)
  return validate('BuildBomberBay', {
    myScrap = AIPUtil.GetScrap(team, true) >= 100,
    cpuConsCount = CountCPUConstructors(team, time) > 0,
    powerCount = AIPUtil.GetPower(team, true) > 0,
    bomberBayExists = not DoesBomberBayExist(team, time)
  })
end

-- Allow the CPU to build a Gun Tower at base
function BuildBaseGunTower(team, time)
  return validate('BuildBaseGunTower', {
    myScrap = AIPUtil.GetScrap(team, true) >= 50,
    cpuConsCount = CountCPUConstructors(team, time) > 0,
    powerCount = AIPUtil.GetPower(team, true) > 0,
    commBunkerExists = DoesCommBunkerExist(team, time)
  })
end

----------------
-- Exist Checks
----------------

-- Condition for trying to collect pools.
function CanCollectScrapPool(team, time)
  return validate('CanCollectScrapPool', {
    hasRecycler = DoesRecyclerExist(team, time),
    hasPool = DoesVacantScrapPoolExist(team, time)
  })
end

-- Condition for trying to collect scrap.
function CanCollectLooseScrap(team, time)
  return validate('CanCollectLooseScrap', {
    hasRecycler = DoesRecyclerExist(team, time),
    hasField = DoesLooseScrapExist(team, time)
  })
end

-- Checks if the Recycler exists.
function DoesRecyclerExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_RECYCLERBUILDING", 'sameteam', true) > 0;
end

-- Checks if the Factory exists.
function DoesFactoryExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_FACTORY", 'sameteam', true) > 0;
end

-- Checks if the Armory exists.
function DoesArmoryExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_ARMORY", 'sameteam', true) > 0;
end

-- Checks if the Service Bay exists.
function DoesServiceBayExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SUPPLYDEPOT", 'sameteam', true) > 0;
end

-- Checks if a Comm Bunker exists.
function DoesCommBunkerExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMBUNKER", 'sameteam', true) > 0;
end

-- Checks if the Training Center exists.
function DoesTrainingCenterExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_BARRACKS", 'sameteam', true) > 0;
end

-- Checks if the Tech Center exists.
function DoesTechCenterExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_TECHCENTER", 'sameteam', true) > 0;
end

-- Checks if the Bomber Bay exists.
function DoesBomberBayExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_BOMBERBAY", 'sameteam', true) > 0;
end

-- Checks if the Bomber exists.
function DoesBomberExist(team, time)
    return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_BOMBER", 'sameteam', true) > 0;
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

-- Returns the amount of power the CPU has available.
function CountCPUPower(team, time)
    return AIPUtil.GetPower(team, false);
end

----------------
-- Human Checks
----------------

-- Check if the player has any Gun Towers.
function DoesHumanHaveGunTowers(team, time)
    return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_GUNTOWER", 'sameteam', true) > 0
end

----------------
-- Upgrade Checks
----------------

-- Allow the CPU to upgrade their first Extractor.
function UpgradeFirstExtractor(team, time)
  return validate('UpgradeFirstExtractor', {
    myScrap = AIPUtil.GetScrap(team, true) >= 60,
    cpuConsCount = CountCPUConstructors(team, time) >= 1,
    cpuExtractorCount = CountCPUExtractors(team, time) >= 1
  })
end

-- All the CPU to upgrade their second Extractor.
function UpgradeSecondExtractor(team, time)
  return validate('UpgradeSecondExtractor', {
    myScrap = AIPUtil.GetScrap(team, true) >= 60,
    cpuConsCount = CountCPUConstructors(team, time) >= 1,
    cpuExtractorCount = CountCPUExtractors(team, time) >= 2
  })
end

-- All the CPU to upgrade their third Extractor.
function UpgradeThirdExtractor(team, time)
  return validate('UpgradeThirdExtractor', {
    myScrap = AIPUtil.GetScrap(team, true) >= 60,
    cpuConsCount = CountCPUConstructors(team, time) >= 1,
    cpuExtractorCount = CountCPUExtractors(team, time) >= 3
  })
end

-- All the CPU to upgrade their fourth Extractor.
function UpgradeFourthExtractor(team, time)
  return validate('UpgradeFourthExtractor', {
    myScrap = AIPUtil.GetScrap(team, true) >= 60,
    cpuConsCount = CountCPUConstructors(team, time) >= 1,
    cpuExtractorCount = CountCPUExtractors(team, time) >= 4
  })
end

----------------
-- Attack Checks
----------------

-- Send Scouts to attack enemy Pools if we don't have enough.
function SendExtractorAttacks(team, time)
  return validate('SendExtractorAttacks', {
    cpuExtractorCount = CountCPUExtractors(team, time) < 3
  })
end

-- Allow for early game harassment by the AI.
function SendEarlyScoutHarassment(team, time)
  return validate('SendEarlyScoutHarassment', {
    factoryExists = not DoesFactoryExist(team, time)
  })
end

-- Allow for harassment after the Factory has been built.
function SendMediumHarassment(team, time)
  return validate('SendMediumHarassment', {
    factoryExists = DoesFactoryExist(team, time)
  })
end

-- Allow for harassment after the factory and armory has been built by the AI.
function SendArtilleryHarassment(team, time)
  return validate('SendArtilleryHarassment', {
    factoryExists = DoesFactoryExist(team, time),
    armoryExists = DoesArmoryExist(team, time)
  })
end

-- Allow for harassment after the necessary required buildings has been built by the AI.
function SendAssaultHarassment(team, time)
  return validate('SendAssaultHarassment', {
    factoryExists = DoesFactoryExist(team, time),
    armoryOrSbayExists = DoesArmoryExist(team, time)
                      or DoesServiceBayExist(team, time),
    commBunkerExists = DoesCommBunkerExist(team, time)
  })
end

-- Allow for harassment after the necessary required buldings has been built by the AI.
function SendTankHarassment(team, time)
  return validate('SendTankHarassment', {
    factoryExists = DoesFactoryExist(team, time),
    commBunkerExists = DoesCommBunkerExist(team, time)
  })
end

-- Anti Gun Tower attack.
function SendGunTowerAttacks(team, time)
  return validate('SendGunTowerAttacks', {
    unitsAvailable = SendTankHarassment(team, time)
                  or SendAssaultHarassment(team, time)
                  or SendAPCAttacks(team, time),
    humanHasGunTowers = DoesHumanHaveGunTowers(team, time)
  })
end

-- APC attack.
function SendAPCAttacks(team, time)
  return validate('SendAPCAttacks', {
    factoryExists = DoesFactoryExist(team, time),
    trainingCenterExists = DoesTrainingCenterExist(team, time)
  })
end

-- Bomber attack.
function SendBomberAttacks(team, time)
  return validate('SendBomberAttacks', {
    bomberExists = DoesBomberExist(team, time)
  })
end

-- Technical attack.
function SendTechnicalAttacks(team, time)
  return validate('SendTechnicalAttacks', {
    factoryExists = DoesFactoryExist(team, time),
    doesTechCenterExist = DoesTechCenterExist(team, time)
  })
end