--[[ FE:Remastered Rampage Helper
Written by General BlackDragon
Version 1.0 7-29-2023 --]]

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');

local _SaveLoad = require("_SaveLoad");

local _Rampage = {}

MAX_RAMPAGE_UNITS = 32

local Rampage = {
	SpawnTrigger = false,
	UnitLimit = 0,
	Timer = 0,
	SpawnSpacer = 0,
	UnitsSpawned = 0,
	Units = {},
 }
 
 -- Register Save/Load for saveload system
_SaveLoad.RegisterSave("_RampageHelper", function()
    return Rampage
end)

_SaveLoad.RegisterLoad("_RampageHelper", function(RampageData)
	if RampageData ~= nil then
		for k,v in pairs(RampageData) do
			Rampage[k] = v
		end
	else
        print("WARNING: _RampageHelper Load called with nil data")
    end
end)

function _Rampage.InitialSetup()

	if IsNetworkOn() then
		Rampage.UnitLimit = GetVarItemInt("network.session.ivar76"); --35
	else
		Rampage.UnitLimit = IFace_GetInteger("options.instant.int5");
	end
	
	if Rampage.UnitLimit > MAX_RAMPAGE_UNITS then
		Rampage.UnitLimit = MAX_RAMPAGE_UNITS;
	elseif Rampage.UnitLimit < 0 then
		Rampage.UnitLimit = 4;
	end

end

function _Rampage.Start()

	if Rampage.UnitLimit <= 0 then
		return;
	end
	
	local iCheck = GetRandomFloat(600);
	Rampage.Timer = SecondsToTurns(420 + ((iCheck % 3) * 60) + (iCheck % 60));

end

function _Rampage.Update(NumHumans, Difficulty, siege_on, late_game)

	if Rampage.UnitLimit <= 0 then
		return;
	end
	
	-- time to kick into gear and spawn some units
	if (GetTurnCount() == Rampage.Timer and (Rampage.UnitLimit > 0)) then
		-- Speed things up a bit
		if (siege_on) then
			Rampage.Timer = (GetTurnCount() + SecondsToTurns(240)) - SecondsToTurns(((NumHumans - 1) * 40)) + ((GetTurnCount() / TPS) % SecondsToTurns(60));
		else -- Set next normal spawn time
			Rampage.Timer = (GetTurnCount() + SecondsToTurns(540)) - SecondsToTurns(((NumHumans - 1) * 90)) + ((GetTurnCount() / TPS) % SecondsToTurns(60));
		end

		Rampage.SpawnTrigger = true;	-- Trigger spawning
		Rampage.SpawnSpacer = 0;		-- Spawn now
		Rampage.UnitsSpawned = 0;		-- No units spawned yet this round
	end

	-- Create a delay between spawning calls
	if (Rampage.SpawnSpacer > 0) then
		Rampage.SpawnSpacer = Rampage.SpawnSpacer - 1;
	end

	-- Reset the spawn trigger once we have built enough units
	if (Rampage.UnitsSpawned >= Rampage.UnitLimit) then
		Rampage.SpawnTrigger = false;
	end

	-- This section spawns the units
	if (Rampage.SpawnTrigger and (Rampage.SpawnSpacer == 0) and (Rampage.UnitsSpawned < Rampage.UnitLimit))	then
		if (siege_on) then		
			if (not late_game) then
				if Difficulty == DIFFICULTY_HARD then
					SpawnRampage("Rampage2", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage("Rampage1", Rampage.UnitsSpawned);
				end
			else
			
				if Difficulty == DIFFICULTY_HARD then
					local iWhichUnit = GetRandomFloat(3.0);
					if (iWhichUnit > 1) then
						SpawnRampage("Rampage3",  Rampage.UnitsSpawned);
					else
						SpawnRampage("Rampage2",  Rampage.UnitsSpawned);
					end
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage("Rampage2", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_EASY then
						SpawnRampage("Rampage1", Rampage.UnitsSpawned);
				end
			end
		elseif (GetTurnCount() < SecondsToTurns(1800)) then -- less than 30 minutes in
			if (not late_game) then
			
				if Difficulty == DIFFICULTY_HARD then
					SpawnRampage("Rampage1", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage("Rampage1", Rampage.UnitsSpawned);
				end
			else
			
				if Difficulty == DIFFICULTY_HARD then
					SpawnRampage("Rampage2", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage("Rampage1", Rampage.UnitsSpawned);
				end
			end
		elseif (GetTurnCount() < SecondsToTurns(3600)) then -- less than 60 minutes in
		
			if (not late_game) then
			
				if Difficulty == DIFFICULTY_HARD then
					SpawnRampage("Rampage2", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage("Rampage2", Rampage.UnitsSpawned);
				end
			else
			
				if Difficulty == DIFFICULTY_HARD then
					SpawnRampage("Rampage2", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage("Rampage2", Rampage.UnitsSpawned);
				end
			end
		else --the rest of the game
		
			if Difficulty == DIFFICULTY_HARD then
				local iWhichUnit = GetRandomFloat(3.0);
				if (iWhichUnit > 1) then
					SpawnRampage("Rampage3",  Rampage.UnitsSpawned);
				else
					SpawnRampage("Rampage2", Rampage.UnitsSpawned);
				end
			elseif Difficulty == DIFFICULTY_NORMAL then
				SpawnRampage("Rampage2",  Rampage.UnitsSpawned);
			end
		end

		Rampage.SpawnSpacer = 20;  -- Reset the spacer
		Rampage.UnitsSpawned = Rampage.UnitsSpawned + 1;   -- Increment the number of units spawned this cycle
	end

end

-- Spawns missing rampage unit(s)
function SpawnRampage(RampageUnit, RampageCurrentSlot)

	local strat_team = 1; -- Assume player team 1.
	
	if (not IsAround(Rampage.Units[RampageCurrentSlot])) then
		Rampage.Units[RampageCurrentSlot] = nil;
	end

	if (Rampage.Units[RampageCurrentSlot] == nil) then
	
		if DoesPathExist("6_RecyclerEnemy") then
			Rampage.Units[RampageCurrentSlot] = BuildObject(RampageUnit, comp_team, "6_RecyclerEnemy");
		else
			Rampage.Units[RampageCurrentSlot] = BuildObject(RampageUnit, comp_team, "RecyclerEnemy");
		end
		
		SetSkill(Rampage.Units[RampageCurrentSlot], 2);
		local hRampageTarget = GetObjectByTeamSlot(strat_team, ((RampageCurrentSlot % 5) + 1));

		if (not IsAround(hRampageTarget)) then
			hRampageTarget = GetObjectByTeamSlot(strat_team, DLL_TEAM_SLOT_FACTORY);
			if (not IsAround(hRampageTarget)) then
				hRampageTarget = GetObjectByTeamSlot(strat_team, DLL_TEAM_SLOT_RECYCLER);
			end
		end

		Attack(Rampage.Units[RampageCurrentSlot], hRampageTarget);
	end
	
end

return _Rampage;