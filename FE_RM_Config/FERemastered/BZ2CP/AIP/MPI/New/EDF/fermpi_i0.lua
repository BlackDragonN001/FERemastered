local EasyAIPConstructorWaitThreshold = 60 * 8; -- Make sure we don't build any constructors for 8 minutes.
local EasyAIPScoutAttackThreshold = 60 * 11; -- Use scouts to attack for the first 11 minutes of the game.
local EasyAIPFactoryBuildThreshold = 60 * 12; -- Make sure the AIP doesn't build a factory until 12 minutes in.
local EasyAIPFactoryAttackThreshold = 60 * 13; -- Start sending units from our factory after this timeframe has passed.
local EasyAIPArmoryBuildThreshold = 60 * 15; -- Build the Armory at the 15 minute mark.
local EasyAIPServiceBayBuildThreshold = 60 * 18; -- Build our Service Bay at the 18 minute mark.

local EasyAIPScoutAttacksSent = 0; -- Used to keep track of how many scout attacks have been sent by the AIP.
local EasyAIPMortarBikeAttacksSend = 0; -- Used to keep track of how many mortar bikes have been sent by the AIP.

function InitAIPLua(team)
	AIPUtil.print(team, "Starting AIP Lua Conditionals. - AI_Unit ");
end

function GetCurrentMissionTime(team, time)
	-- We need a way of getting the current game TPS. Right now it's hardcoded at default 20 as standard.
	-- According to calculations, this should get us the accurate game time in seconds.
	return time / (20 * 20);
end

--------------------------------------------------------------------------------------------------------
-- CPU Conditional Checks
--------------------------------------------------------------------------------------------------------
function CPURecyclerExists(team, time)
	local CPUHasRecy = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_RECYCLERBUILDING", "sameteam", true);

	if (CPUHasRecy > 0) then
		AIPUtil.print(team, "CPU Recycler is present. ");
		return true;
	else
		AIPUtil.print(team, "CPU Recycler is not present. ");
		return false;
	end
end

function CPUFactoryExists(team, time)
	local CPUHasFactory = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_FACTORY", "sameteam", true);

	if (CPUHasFactory > 0) then
		AIPUtil.print(team, "CPU Factory is present. ");
		return true;
	else
		AIPUtil.print(team, "CPU Factory is not present. ");
		return false;
	end
end

function CPUArmoryExists(team, time)
	local CPUHasArmory = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_ARMORY", "sameteam", true);

	if (CPUHasArmory > 0) then
		AIPUtil.print(team, "CPU Armory is present. ");
		return true;
	else
		AIPUtil.print(team, "CPU Armory is not present. ");
		return false;
	end
end

function CPUServiceBayExists(team, time)
	local CPUHasServiceBay = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SUPPLYDEPOT", "sameteam", true);

	if (CPUHasServiceBay > 0) then
		AIPUtil.print(team, "CPU Service Bay is present. ");
		return true;
	else
		AIPUtil.print(team, "CPU Service Bay is not present. ");
		return false;
	end
end

function CPUBunkerExists(team, time)
	local CPUHasRelayBunker = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMTOWER", "sameteam", true);

	if (CPUHasRelayBunker > 0) then
		AIPUtil.print(team, "CPU Relay Bunker is present. ");
		return true;
	else
		AIPUtil.print(team, "CPU Relay Bunker is not present. ");
		return false;
	end
end

function CPUTrainingExists(team, time)
	local CPUHasTraining = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_TRAININGFACILITY", "sameteam", true);

	if (CPUHasTraining > 0) then
		AIPUtil.print(team, "CPU Training Facility is present. ");
		return true;
	else
		AIPUtil.print(team, "CPU Training Facility is not present. ");
		return false;
	end
end

function CPUTechExists(team, time)
	local cpuHasTech = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_TECHCENTER", "sameteam", true);

	if (CPUHasTech >= 1) then
		AIPUtil.print(team, "CPU Tech Centre is present. ");
		return true;
	else
		AIPUtil.print(team, "CPU Tech Centre is not present. ");
		return false;
	end
end

function CPUBuilderExists(team, time)
	local CPUHasBuilder = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true);

	if (CPUHasBuilder > 0) then
		AIPUtil.print(team, "CPU Builder is present.  ");
		return true;
	else
		AIPUtil.print(team, "CPU Builder is not present. ");
		return false;
	end
end

function CPUScavExists(team, time)
	local CPUHasScav = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SCAVENGER", "sameteam", true);

	if (CPUHasScav > 0) then
		AIPUtil.print(team, "CPU Scavenger is present. ");
		return true;
	else
		AIPUtil.print(team, "CPU Scavenger is not present. ");
		return false;
	end
end

function CPUExtractorExists(team, time)
	local CPUHasExtractor = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR", "sameteam", true);

	if (CPUHasExtractor >= 1) then
		AIPUtil.print(team, "CPU Extractor is present. ");
		return true;
	else
		AIPUtil.print(team, "CPU Extractor is not present. ");
		return false;
	end
end

function CPUHasPositivePower(team, time)
	local CPUHasPositivePower = AIPUtil.GetPower(team, false);

	if (CPUHasPositivePower > 0) then
		AIPUtil.print(team, "CPU has enough power.  ");
		return true;
	else
		AIPUtil.print(team, "CPU doesn't have enough power. ");
		return false;
	end
end

--------------------------------------------------------------------------------------------------------
-- CPU Path Checkers
--------------------------------------------------------------------------------------------------------
function BuildGunTower1(team, time)
	local gtow1Exists = AIPUtil.PathExists("gtow1");
	local gtow1Taken = AIPUtil.PathBuildingExists("gtow1");
	local CPUBuilderExists = CPUBuilderExists(team);

	if (gtow1Exists and not gtow1Taken and CPUBuilderExists) then
		AIPUtil.print(team, "CPU can build a Gun Tower on path: gtow1. ");
		return true;
	else
		AIPUtil.print(team, "CPU can't build a Gun Tower on path: gtow1. ");
		return false;
	end
end

function BuildGunTower2(team, time)
	local gtow2Exists = AIPUtil.PathExists("gtow2");
	local gtow2Taken = AIPUtil.PathBuildingExists("gtow2");
	local cpuHasBuilder = CPUBuilderExists(team);

	if (gtow2Exists and not gtow2Taken and cpuHasBuilder) then
		AIPUtil.print(team, "CPU can build a Gun Tower on path: gtow2. ");
		return true;
	else
		AIPUtil.print(team, "CPU can't build a Gun Tower on path: gtow2. ");
		return false;
	end
end

function BuildGunTower3(team, time)
	local gtow3Exists = AIPUtil.PathExists("gtow3");
	local gtow3Taken = AIPUtil.PathBuildingExists("gtow3");
	local cpuHasBuilder = CPUBuilderExists(team);

	if (gtow3Exists and not gtow3Taken and cpuHasBuilder) then
		AIPUtil.print(team, "CPU can build a Gun Tower on path: gtow3. ");
		return true;
	else
		AIPUtil.print(team, "CPU can't build a Gun Tower on path: gtow3. ");
		return false;
	end
end

function BuildGunTower4(team, time)
	local gtow4Exists = AIPUtil.PathExists("gtow4");
	local gtow4Taken = AIPUtil.PathBuildingExists("gtow4");
	local cpuHasBuilder = CPUBuilderExists(team);

	if (gtow4Exists and not gtow4Taken and cpuHasBuilder) then
		AIPUtil.print(team, "CPU can build a Gun Tower on path: gtow4. ");
		return true;
	else
		AIPUtil.print(team, "CPU can't build a Gun Tower on path: gtow4. ");
		return false;
	end
end

function BuildGunTower5(team, time)
	local gtow5Exists = AIPUtil.PathExists("gtow5");
	local gtow5Taken = AIPUtil.PathBuildingExists("gtow5");
	local cpuHasBuilder = CPUBuilderExists(team);

	if (gtow5Exists and not gtow5Taken and cpuHasBuilder) then
		AIPUtil.print(team, "CPU can build a Gun Tower on path: gtow5. ");
		return true;
	else
		AIPUtil.print(team, "CPU can't build a Gun Tower on path: gtow5. ");
		return false;
	end
end

function BuildGunTower6(team, time)
	local gtow6Exists = AIPUtil.PathExists("gtow6");
	local gtow6Taken = AIPUtil.PathBuildingExists("gtow6");
	local cpuHasBuilder = CPUBuilderExists(team);

	if (gtow6Exists and not gtow6Taken and cpuHasBuilder) then
		AIPUtil.print(team, "CPU can build a Gun Tower on path: gtow6. ");
		return true;
	else
		AIPUtil.print(team, "CPU can't build a Gun Tower on path: gtow6. ");
		return false;
	end
end

--------------------------------------------------------------------------------------------------------
-- Count Units
--------------------------------------------------------------------------------------------------------
function CountCPUScavengers(team, time)
	return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SCAVENGER", "sameteam", true);
end

function CountCPUExtractors(team, time) 
	return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR", "sameteam", true);
end

function CountCPUConstructor(team, time)
	return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true);
end

function CountCPUPowerGenerators(team, time)
	return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_POWERPLANT", "sameteam", true);
end

function CountCPUServiceTrucks(team, time)
	return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SERVICETRUCK", "sameteam", true);
end

-- Count Human units
function CountHumanScavengers(team, time) 
	return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_SCAVENGER", "sameteam", true);
end

function CountHumanExtractors(team, time) 
	return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_EXTRACTOR", "sameteam", true);
end

function CountHumanRecyclerBuildings(team, time)
	return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_RECYCLERBUILDING", 'sameteam', true);
end

function CountHumanConstructors(team, time)
	return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_CONSTRUCTIONRIG", 'sameteam', true);
end

function CountHumanGunTowers(team, time)
	return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_GUNTOWER", 'sameteam', true);
end

function CountHumanAssaultUnits(team, time)
	return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_ASSAULTTANK", 'sameteam', true);
end

function CountHumanTechCentres(team, time)
	return AIPUtil.CountUnits(1, "VIRTUAL_CLASS_TECHCENTER", 'sameteam', true);
end

--------------------------------------------------------------------------------------------------------
-- FE EASY CONDITIONAL CHECKS
--------------------------------------------------------------------------------------------------------

-- Start up conditions. Make sure we have a Recycler and a certain amount of pools.
function BuildScavengerCheck1(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUScavCount = CountCPUScavengers(team, time);

	local buildScavs = CPUHasRecy and CPUScavCount < 2;

	if (buildScavs) then
		AIPUtil.print(team, "Building first scavenger set. ");
		return true;
	else
		AIPUtil.print(team, "Scavenger not needed, two already exist. ");
		return false;
	end
end

function BuildScavengerCheck2(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUScavCount = CountCPUScavengers(team, time);

	local buildScavs = CPUHasRecy and CPUScavCount < 4;

	if (buildScavs) then
		AIPUtil.print(team, "Building second scavenger set. ");
		return true;
	else
		AIPUtil.print(team, "Scavenger not needed, four already exist. ");
		return false;
	end
end

function BuildConstructorCheck1(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);

	local buildCons = CPUHasRecy and GetCurrentMissionTime(team, time) > EasyAIPConstructorWaitThreshold;

	if (buildCons) then
		AIPUtil.print(team, "I need to build my first constructor. ");
		return true;
	else
		AIPUtil.print(team, "I already have a constructor. ");
		return false;
	end
end

-- Attacker Conditions
function SendFirstScoutAttackWave(team, time) -- First scout function. Send out some scouts if it's safe enough, don't waste scrap if a player has enough defenses.
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUExtractorCount = CountCPUExtractors(team, time);
	local CPUHasFactory = CPUFactoryExists(team, time);
	local HumanScavCount = CountHumanScavengers(team, time);
	local HumanExtractorCount = CountHumanExtractors(team, time);

	local shouldAttack = (CPUHasRecy 
						  and CPUExtractorCount >= 2 
						  and (HumanScavCount > 0 or HumanExtractorCount > 0) 
						  and not CPUHasFactory 
						  and GetCurrentMissionTime(team, time) <= EasyAIPScoutAttackThreshold);

	if (shouldAttack) then
		AIPUtil.print(team, "Sending first attack party at enemy Scavengers. ");
		EasyAIPScoutAttacksSent = EasyAIPScoutAttacksSent + 1;

		return true;
	else
		AIPUtil.print(team, "Could not send first scout attack party. Conditions haven't been met. ");
		return false;
	end
end

function SendSecondScoutAttackWave(team, time) -- Second scout function. Send out some scouts if it's safe enough, don't waste scrap if a player has enough defenses.
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUExtractorCount = CountCPUExtractors(team, time);
	local HumanRecyclerBuildingCount = CountHumanRecyclerBuildings(team, time);
	local HumanGunTowerCount = CountHumanGunTowers(team, time); 

	local shouldAttack = (CPUHasRecy 
						  and CPUExtractorCount >= 2 
						  and HumanRecyclerBuildingCount > 0 
						  and HumanGunTowerCount <= 0 
						  and GetCurrentMissionTime(team, time) <= EasyAIPScoutAttackThreshold);

	if (shouldAttack) then
		AIPUtil.print(team, "Sending second attack party at enemy Recycler. ");
		EasyAIPScoutAttacksSent = EasyAIPScoutAttacksSent + 1;

		return true;
	else
		AIPUtil.print(team, "Could not send second scout attack party. Conditions haven't been met. ");
		return false;
	end
end

function SendMissileScoutAttackWave1(team, time) -- Send two missile scouts to target player units around the map.
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUExtractorCount = CountCPUExtractors(team, time);
	local CPUHasFactory = CPUFactoryExists(team, time);
	local HumanGunTowerCount = CountHumanGunTowers(team, time);
	local HumanAssaultUnitCount = CountHumanAssaultUnits(team, time); 

	local shouldAttack = (CPUHasRecy 
						  and CPUExtractorCount >= 2
						  and CPUHasFactory
						  and HumanGunTowerCount < 3
						  and HumanAssaultUnitCount <= 0
						  and GetCurrentMissionTime(team, time) > EasyAIPFactoryAttackThreshold);

	if (shouldAttack) then
		AIPUtil.print(team, "Sending third attack party at enemy units. ");
		return true;
	else
		AIPUtil.print(team, "Could not send third attack party. Conditions haven't been met. ");
		return false;
	end
end

function SendTankAttackPartyWave1(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUExtractorCount = CountCPUExtractors(team, time);
	local CPUHasFactory = CPUFactoryExists(team, time);
	local HumanGunTowerCount = CountHumanGunTowers(team, time);
	local HumanAssaultUnitCount = CountHumanAssaultUnits(team, time); 
	local CPUHasRelayBunker = CPUBunkerExists(team, time);

	local shouldAttack = (CPUHasRecy 
					  and CPUExtractorCount >= 2
					  and CPUHasFactory
					  and HumanGunTowerCount < 5
					  and HumanAssaultUnitCount <= 2
					  and CPUHasRelayBunker
					  and GetCurrentMissionTime(team, time) > EasyAIPFactoryAttackThreshold);

	if (shouldAttack) then
		AIPUtil.print(team, "Sending fourth attack party at enemy units. ");
		return true;
	else
		AIPUtil.print(team, "Could not send fourth attack party. Conditions haven't been met. ");
		return false;
	end
end

function SendMortarBikeAttackPartyWave1(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUExtractorCount = CountCPUExtractors(team, time);
	local CPUHasFactory = CPUFactoryExists(team, time);
	local CPUArmoryExists = CPUArmoryExists(team, time);
	local HumanGunTowerCount = CountHumanGunTowers(team, time);
	local HumanTechCentreExists = CountHumanTechCentres(team, time) > 0;

	local shouldAttack = (CPUHasRecy 
					  and CPUExtractorCount >= 2
					  and CPUHasFactory
					  and HumanGunTowerCount > 0
					  and CPUArmoryExists
					  and not HumanTechCentreExists
					  and GetCurrentMissionTime(team, time) > EasyAIPArmoryBuildThreshold);

	if (shouldAttack) then
		EasyAIPMortarBikeAttacksSend = EasyAIPMortarBikeAttacksSend + 1;

		AIPUtil.print(team, "Sending fifth attack party at enemy units. ");
		return true;
	else
		AIPUtil.print(team, "Could not send fifth attack party. Conditions haven't been met. ");
		return false;
	end
end

-- Base functions
function PowerGeneratorCheck(team, time) -- Build our first Power Generator if necessary.
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUBuilderExists = CPUBuilderExists(team, time);
	local CPUHasPositivePower = CPUHasPositivePower(team, time);

	local buildPower = (CPUHasRecy
						and CPUBuilderExists
						and not CPUHasPositivePower
						and GetCurrentMissionTime(team, time) > EasyAIPConstructorWaitThreshold);

	if (buildPower) then
		AIPUtil.print(team, "Building first power plant. ");
		return true;
	else
		AIPUtil.print(team, "Could not build a Power Generator. Conditions haven't been met. ");
		return false;
	end
end

function RelayBunkerCheck(team, time) -- Build our Relay Bunker generator if necessary.
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUBuilderExists = CPUBuilderExists(team, time);
	local CPURelayBunkerExists = CPUBunkerExists(team, time);
	local CPUHasPositivePower = CPUHasPositivePower(team, time);

	local buildBunker = (CPUHasRecy
						and CPUBuilderExists
						and CPUHasPositivePower
						and not CPURelayBunkerExists
						and GetCurrentMissionTime(team, time) > EasyAIPConstructorWaitThreshold);

	if (buildBunker) then
		AIPUtil.print(team, "Building a Relay Bunker. ");
		return true;
	else
		AIPUtil.print(team, "Could not build a Relay Bunker. Conditions haven't been met. ");
		return false;
	end
end

function FactoryCheck(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUBuilderExists = CPUBuilderExists(team, time);
	local CPUFactoryExists = CPUFactoryExists(team, time);
	local CPUHasPositivePower = CPUHasPositivePower(team, time);

	local buildFactory = (CPUHasRecy
						 and CPUBuilderExists
						 and CPUHasPositivePower
						 and not CPUFactoryExists
						 and GetCurrentMissionTime(team, time) > EasyAIPFactoryBuildThreshold);

	if (buildFactory) then
		AIPUtil.print(team, "Building a Factory. ");
		return true;
	else
		AIPUtil.print(team, "Could not build a Factory. Conditions haven't been met. ");
		return false;
	end
end

function FirstBaseGunTowersCheck(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUBuilderExists = CPUBuilderExists(team, time);
	local CPUHasPositivePower = CPUHasPositivePower(team, time);

	local buildGunTowers = (CPUHasRecy
					   		and CPUBuilderExists
					   		and CPUHasPositivePower
					   		and EasyAIPScoutAttacksSent > 2);

	if (buildGunTowers) then
		AIPUtil.print(team, "Building my first two base Gun Towers. ");
		return true;
	else
		AIPUtil.print(team, "Could not build my first two Gun Towers. Conditions haven't been met. ");
		return false;
	end
end

function SecondBaseGunTowersCheck(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUBuilderExists = CPUBuilderExists(team, time);
	local CPUHasPositivePower = CPUHasPositivePower(team, time);
	local CPUHasServiceBay = CPUServiceBayExists(team, time);

	local buildGunTowers = (CPUHasRecy
				   		and CPUBuilderExists
				   		and CPUHasPositivePower
				   		and CPUHasServiceBay
				   		and EasyAIPMortarBikeAttacksSend > 1);

	if (buildGunTowers) then
		AIPUtil.print(team, "Building my second base Gun Towers. ");
		return true;
	else
		AIPUtil.print(team, "Could not build my second two Gun Towers. Conditions haven't been met. ");
		return false;
	end
end

function ArmoryCheck(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUBuilderExists = CPUBuilderExists(team, time);
	local CPUArmoryExists = CPUArmoryExists(team, time);
	local CPUHasPositivePower = CPUHasPositivePower(team, time);

	local buildArmory = (CPUHasRecy
						 and CPUBuilderExists
						 and CPUHasPositivePower
						 and not CPUArmoryExists
						 and GetCurrentMissionTime(team, time) > EasyAIPArmoryBuildThreshold);

	if (buildArmory) then
		AIPUtil.print(team, "Building an Armory. ");
		return true;
	else
		AIPUtil.print(team, "Could not build an Armory. Conditions haven't been met. ");
		return false;
	end
end

function ServiceBayCheck(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUBuilderExists = CPUBuilderExists(team, time);
	local CPUServiceBayExists = CPUServiceBayExists(team, time);
	local CPUHasPositivePower = CPUHasPositivePower(team, time);

	local buildServiceBay = (CPUHasRecy
					 and CPUBuilderExists
					 and CPUHasPositivePower
					 and not CPUServiceBayExists
					 and GetCurrentMissionTime(team, time) > EasyAIPServiceBayBuildThreshold);

	if (buildServiceBay) then
		AIPUtil.print(team, "Building a Service Bay. ");
		return true;
	else
		AIPUtil.print(team, "Could not build a Service Bay. Conditions haven't been met. ");
		return false;
	end
end

function ServiceTruckCheck(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUServiceBayExists = CPUServiceBayExists(team, time);
	local CPUServiceTruckCount = CountCPUServiceTrucks(team, time);

	local buildServiceTrucks = (CPUHasRecy
				 and CPUBuilderExists
				 and CPUServiceBayExists
				 and CPUServiceTruckCount < 5
				 and GetCurrentMissionTime(team, time) > EasyAIPServiceBayBuildThreshold);

	if (buildServiceTrucks) then
		AIPUtil.print(team, "Building Service Trucks. ");
		return true;
	else
		AIPUtil.print(team, "Could not build Service Trucks. Conditions haven't been met. ");
		return false;
	end
end