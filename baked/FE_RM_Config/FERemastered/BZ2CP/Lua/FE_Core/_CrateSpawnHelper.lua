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
		_CrateSpawner.ResetTimer();
	end

end

-- Update the beam movement/timers.
function _CrateSpawner.Update(difficulty, late_game)

	if CrateSpawner.SpawnTimer <= 0 then 
		SpawnWeaponCrates(difficulty, late_game);
	else -- count down timer.
		CrateSpawner.SpawnTimer = CrateSpawner.SpawnTimer - 1;
	end

end

-- Spawn Crates
function SpawnWeaponCrates(difficulty, late_game)

	local MinRadiusAway = 150.0;
	local MaxRadiusAway = 250.0;
	local Team = 0;
	local handle = GetObjectByTeamSlot(1, DLL_TEAM_SLOT_RECYCLER);

	-- Remove old Crates
	for i = 1, 3 do
		if IsAround(CrateSpawner.CrateHandle[i]) then
			RemoveObject(CrateSpawner.CrateHandle[i]);
		end
	end

	-- TODO: Export list of powerups to a external file and randomly pick from it. -GBD
	-- Spawn new crates.
	if (handle ~= nil) then
		if (not late_game) then
			CrateSpawner.CrateHandle[1] = SpawnObjectAround("apbolter", Team, handle, MinRadiusAway, MaxRadiusAway);
			CrateSpawner.CrateHandle[2] = SpawnObjectAround("apbhole", Team, handle, MinRadiusAway, MaxRadiusAway);
			CrateSpawner.CrateHandle[3] = SpawnObjectAround("apfirestorm", Team, handle, MinRadiusAway, MaxRadiusAway);
		elseif (difficulty ~= DIFFICULTY_HARD) then
			CrateSpawner.CrateHandle[1] = SpawnObjectAround("ap8brock", Team, handle, MinRadiusAway, MaxRadiusAway);
			CrateSpawner.CrateHandle[2] = SpawnObjectAround("approton", Team, handle, MinRadiusAway, MaxRadiusAway);
			CrateSpawner.CrateHandle[3] = SpawnObjectAround("aphfire", Team, handle, MinRadiusAway, MaxRadiusAway);
		end
	end

	_CrateSpawner.ResetTimer();
	
end

function _CrateSpawner.ResetTimer()
	CrateSpawner.SpawnTimer = SecondsToTurns(120.0 + ((CountPlayers() - 1) * 25.0) + GetRandomFloat(60));
	--print("Crate Respawn Time: " .. CrateSpawner.SpawnTimer);
end


return _CrateSpawner;