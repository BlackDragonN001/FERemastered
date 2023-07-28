--[[ FE:Remastered Crate Spawn Helper
Written by General BlackDragon
Version 1.0 7-20-2023 --]]

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');

local _CrateSpawner = {}
	
local CrateSpawner = {
	CrateHandle = { nil, nil, nil },
	SpawnTimer = 0,
 }

function _CrateSpawner.Save()
    return CrateSpawner;
end

function _CrateSpawner.Load(CrateSpawnerData)	
	CrateSpawner = CrateSpawnerData;
end

-- Set initial timers.
function _CrateSpawner.InitialSetup()

	-- If the beam timer is <= 0, set a new timer.
	if CrateSpawner.SpawnTimer <= 0 then 
		ResetTimer();
	end

end

-- Update the beam movement/timers.
function _CrateSpawner.Update()

	if CrateSpawner.SpawnTimer <= 0 then 
		SpawnWeaponCrates();
	else -- count down timer.
		CrateSpawner.SpawnTimer = CrateSpawner.SpawnTimer - 1;
	end

end

-- Spawn Crates
function SpawnWeaponCrates(handle, difficulty, late_game)

	local MinRadiusAway = 150.0;
	local MaxRadiusAway = 250.0;
	local Team = 0;

	-- Remove old Crates
	for i = 1, 3 do
		if IsAround(CrateSpawner.CrateHandle[i]) then
			RemoveObject(CrateSpawner.CrateHandle[i]);
		end
	end

	-- TODO: Export list of powerups to a external file and randomly pick from it. -GBD
	-- Spawn new crates.
	if (not late_game) then
		hCrate1 = SpawnObjectAround("apbolter", Team, handle, MinRadiusAway, MaxRadiusAway);
		hCrate2 = SpawnObjectAround("apbhole", Team, handle, MinRadiusAway, MaxRadiusAway);
		hCrate3 = SpawnObjectAround("apfirestorm", Team, handle, MinRadiusAway, MaxRadiusAway);
	elseif (difficulty ~= DIFFICULTY_HARD) then
		hCrate1 = SpawnObjectAround("ap8brock", Team, handle, MinRadiusAway, MaxRadiusAway);
		hCrate2 = SpawnObjectAround("approton", Team, handle, MinRadiusAway, MaxRadiusAway);
		hCrate3 = SpawnObjectAround("aphfire2", Team, handle, MinRadiusAway, MaxRadiusAway);
	end

	ResetTimer();
	
end

function ResetTimer()
	CrateSpawner.SpawnTimer = SecondsToTurns(120.0) + SecondsToTurns((CountPlayers() - 1) * 25.0) + SecondsToTurns(GetRandomFloat(60));
end


return _CrateSpawner;