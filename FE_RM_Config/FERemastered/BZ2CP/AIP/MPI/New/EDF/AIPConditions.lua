function InitAIPLua(team)
    AIPUtil.print("Initiating AIP Plan Conditions - AI_Unit")
end

-- Conditional checks against the CPU Team for units and buildings that are present.
function CPURecyclerExists(team, time)
    local cpuHasRecycler = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_RECYCLERBUILDING", 'sameteam', true);

    if (cpuHasRecycler >= 1) then
        return true, "CPU Recycler is present.";
    else
        return false, "CPU Recycler is not present.";
    end
end

function CPUFactoryExists(team, time)
    local cpuHasFactory = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_FACTORY", "sameteam", true);

    if (cpuHasFactory >= 1) then
        return true, "CPU Factory is present.";
    else
        return false, "CPU Factory is not present.";
    end
end

function CPUArmoryExists(team, time)
    local cpuHasArmory = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_ARMORY", "sameteam", true);

	if (cpuHasArmory >= 1) then
		return true, "CPU Armory is present.";
	else
		return false, "CPU Armory is not present.";
	end
end

function CPUServiceBayExists(team, time)
    local cpuHasServiceBay = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SUPPLYDEPOT", "sameteam", true);

    if (cpuHasServiceBay >= 1) then
        return true, "CPU Service Bay is present.";
    else
        return true, "CPU Service Bay is not present.";
    end
end

function CPUBunkerExists(team, time)
	local cpuHasRelayBunker = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMTOWER", "sameteam", true)

	if (cpuHasRelayBunker >= 1) then
		return true, "CPU Relay Bunker is present."
	else
		return false, "CPU Relay Bunker is not present."
	end
end

function CPUTrainingExists(team, time)
	local cpuHasTraining = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_TRAININGFACILITY", "sameteam", true)

	if (cpuHasTraining >= 1) then
		return true, "CPU Training Facility is present.";
	else
		return false, "CPU Training Facility is not present.";
	end
end

function CPUTechExists(team, time)
	local cpuHasTech = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_TECHCENTER", "sameteam", true);

	if (cpuHasTech >= 1) then
		return true, "CPU Tech Centre is present.";
	else
		return false, "CPU Tech Centre is not present.";
	end
end

function CPUBuilderExists(team, time)
    local cpuHasBuilder = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true);

	if (cpuHasBuilder >= 1) then
		return true, "CPU Builder is present.";
	else
		return false, "CPU Builder is not present.";
	end
end

function CPUScavExists(team, time)
    local cpuHasScav = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SCAVENGER", "sameteam", true);

	if (cpuHasScav >= 1) then
		return true, "CPU Scavenger is present.";
	else
		return false, "CPU Scavenger is not present.";
	end
end

function CPUExtractorExists(team, time)
	local cpuHasExtractor = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR", "sameteam", true);

	if (cpuHasExtractor >= 1) then
		return true, "CPU Extractor is present.";
	else
		return false, "CPU Extractor is not present.";
	end
end

-- CPU Power Checker
function CPUHasPositivePower(team, time)
    local cpuHasPositivePower = AIPUtil.GetPower(team, false);

    if (cpuHasPositivePower >= 1) then
        return true, "CPU has enough power.";
    else
        return false, "CPU has not got enough power.";
    end
end

-- CPU Path Checker
function BuildGunTower1(team, time)
	local gtow1Exists = AIPUtil.PathExists("gtow1");
	local gtow1Taken = AIPUtil.PathBuildingExists("gtow1");
	local cpuHasBuilder = CPUBuilderExists(team);

	if (gtow1Exists and not gtow1Taken and cpuHasBuilder) then
		return true, "I can build a Gun Tower on gtow1.";
	else
		return false, "GTOW1 is occupied or doesn't exist, or I don't have a builder.";
	end
end

function BuildGunTower2(team, time)
	local gtow2Exists = AIPUtil.PathExists("gtow2");
	local gtow2Taken = AIPUtil.PathBuildingExists("gtow2");
	local cpuHasBuilder = CPUBuilderExists(team);

	if (gtow2Exists and not gtow2Taken and cpuHasBuilder) then
		return true, "I can build a Gun Tower on gtow2";
	else
		return false, "GTOW2 is occupied or doesn't exist, or I don't have a builder.";
	end
end

function BuildGunTower3(team, time)
	local gtow3Exists = AIPUtil.PathExists("gtow3");
	local gtow3Taken = AIPUtil.PathBuildingExists("gtow3");
	local cpuHasBuilder = CPUBuilderExists(team);

	if (gtow3Exists and not gtow3Taken and cpuHasBuilder) then
		return true, "I can build a Gun Tower on gtow3";
	else
		return false, "GTOW3 is occupied or doesn't exist, or I don't have a builder.";
	end
end

function BuildGunTower4(team, time)
	local gtow4Exists = AIPUtil.PathExists("gtow4");
	local gtow4Taken = AIPUtil.PathBuildingExists("gtow4");
	local cpuHasBuilder = CPUBuilderExists(team);

	if (gtow4Exists and not gtow4Taken and cpuHasBuilder) then
		return true, "I can build a Gun Tower on gtow4";
	else
		return false, "GTOW4 is occupied or doesn't exist, or I don't have a builder.";
	end
end

function BuildGunTower5(team, time)
	local gtow5Exists = AIPUtil.PathExists("gtow5");
	local gtow5Taken = AIPUtil.PathBuildingExists("gtow5");
	local cpuHasBuilder = CPUBuilderExists(team);

	if (gtow5Exists and not gtow5Taken and cpuHasBuilder) then
		return true, "I can build a Gun Tower on gtow5";
	else
		return false, "GTOW5 is occupied or doesn't exist, or I don't have a builder.";
	end
end

function BuildGunTower6(team, time)
	local gtow6Exists = AIPUtil.PathExists("gtow6");
	local gtow6Taken = AIPUtil.PathBuildingExists("gtow6");
	local cpuHasBuilder = CPUBuilderExists(team);

	if (gtow6Exists and not gtow6Taken and cpuHasBuilder) then
		return true, "I can build a Gun Tower on gtow6";
	else
		return false, "GTOW6 is occupied or doesn't exist, or I don't have a builder.";
	end
end

-- Forgotten Enemies Specific 
function HoldCheckPlan1(team, time)
	local hold1Exists = AIPUtil.PathExists("hold1");
	local cpuHasRecycler = CPURecyclerExists(team, time);

	if (hold1Exists and cpuHasRecycler) then
		return true, "I can add a turret to the Hold 1 path.";
	else
		return false, "I can't add a turret to the Hold 1 path.";
	end
end

function HoldCheckPlan2(team, time)
	local hold2Exists = AIPUtil.PathExists("hold2");
	local cpuHasRecycler = CPURecyclerExists(team, time);

	if (hold2Exists and cpuHasRecycler) then
		return true, "I can add a turret to the Hold 2 path.";
	else
		return false, "I can't add a turret to the Hold 2 path.";
	end
end

-- Count units
function CountCPUScavengers(team, time)
	return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SCAVENGER", "sameteam", true);
end

function CountCPUExtractors(team, time) 
	return AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR", "sameteam", true);
end

function CountCPUConstructor(team, time)
	return AIPUtils.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true);
end

-- Start up conditions. Make sure we have a Recycler and a certain amount of pools.
function CollectPoolPlanCheck1(team, time) 
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUScavCount = CountCPUScavengers(team, time);
	local CPUExtractorCount = CountCPUExtractors(team, time);

	if (CPUHasRecy and CPUScavCount <= 0 and CPUExtractorCount < 1) then
		return true, "I need to send a Scavenger to my first pool.";
	else 
		return false, "I have too many Extractors to execute this plan.";
	end
end

function CollectPoolPlanCheck2(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUExtractorCount = CountCPUExtractors(team, time);

	if (CPUHasRecy and CPUExtractorCount < 3) then
		return true, "I need to send a Scavenger to more pools.";
	else
		return false, "I have too many Extractors to execute this plan.";
	end
end

function BuildConstructorCheck1(team, time)
	local CPUHasRecy = CPURecyclerExists(team, time);
	local CPUConstructorCount = CountCPUConstructor(team, time);

	if (CPUHasRecy and CPUConstructorCount <= 0) then
		return true, "I need to build my first constructor";
	else
		return false, "I already have a Constructor.";
	end
end