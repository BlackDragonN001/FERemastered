--[[ FE:Remastered Rampage Helper
Written by General BlackDragon
Version 1.0 7-29-2023 --]]

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');

local _RampageUnits = {}

MAX_RAMPAGE_UNITS = 32

local Rampage = {
	SpawnTrigger = false,
	UnitLimit = 0,
	Timer = 0,
	SpawnSpacer = 0,
	UnitsSpawned = 0,
	Units = {},
 }
  
function _RampageUnits.Save()
    return 
		Rampage;
end

function _RampageUnits.Load(RampageUnitData)	
	Rampage = RampageUnitData;
end

function _RampageUnits.InitialSetup()

	if IsNetworkOn() then
		Rampage.UnitLimit = GetVarItemInt("network.session.ivar35");
	else
		Rampage.UnitLimit =  IFace_GetInteger("options.instant.int5");
	end
	
	if Rampage.UnitLimit > MAX_RAMPAGE_UNITS then
		Rampage.UnitLimit = MAX_RAMPAGE_UNITS;
	elseif Rampage.UnitLimit < 0 then
		Rampage.UnitLimit = 4;
	end

end

function _RampageUnits.Start()

	if Rampage.UnitLimit <= 0 then
		return;
	end
	
	local iCheck = GetRandomFloat(6000);
	RampageTimer = 4200 + ((iCheck % 3) * 600) + (iCheck % 600);

end

function _RampageUnits.Update(time_count, NumHumans, Difficulty, siege_on, late_game)

	if Rampage.UnitLimit <= 0 then
		return;
	end
	
	-- time to kick into gear and spawn some units
	if (time_count == Rampage.Timer and (Rampage.UnitLimit > 0)) then
		-- Speed things up a bit
		if (siege_on) then
			Rampage.Timer = (time_count + 2400) - ((NumHumans - 1) * 400) + ((time_count / 10) % 600); 
		else -- Set next normal spawn time
			Rampage.Timer = (time_count + 5400) - ((NumHumans - 1) * 900) + ((time_count / 10) % 600); 
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
					SpawnRampage ("Rampage2", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage ("Rampage1", Rampage.UnitsSpawned);
				end
			else
			
				if Difficulty == DIFFICULTY_HARD then
					local iWhichUnit = GetRandomFloat(3.0);
					if (iWhichUnit > 1) then
						SpawnRampage ("Rampage3",  Rampage.UnitsSpawned);
					else
						SpawnRampage ("Rampage2",  Rampage.UnitsSpawned);
					end
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage ("Rampage2", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_EASY then
						SpawnRampage ("Rampage1", Rampage.UnitsSpawned);
				end
			end
		elseif (time_count < 18000) then -- less than 30 minutes in
			if (not late_game) then
			
				if Difficulty == DIFFICULTY_HARD then
					SpawnRampage ("Rampage1", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage ("Rampage1", Rampage.UnitsSpawned);
				end
			else
			
				if Difficulty == DIFFICULTY_HARD then
					SpawnRampage ("Rampage2", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage ("Rampage1", Rampage.UnitsSpawned);
				end
			end
		elseif (time_count < 36000) then -- less than 60 minutes in
		
			if (not late_game) then
			
				if Difficulty == DIFFICULTY_HARD then
					SpawnRampage ("Rampage2", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage ("Rampage2", Rampage.UnitsSpawned);
				end
			else
			
				if Difficulty == DIFFICULTY_HARD then
					SpawnRampage ("Rampage2", Rampage.UnitsSpawned);
				elseif Difficulty == DIFFICULTY_NORMAL then
					SpawnRampage ("Rampage2", Rampage.UnitsSpawned);
				end
			end
		else --the rest of the game
		
			if Difficulty == DIFFICULTY_HARD then
				local iWhichUnit = GetRandomFloat(3.0);
				if (iWhichUnit > 1) then
					SpawnRampage ("Rampage3",  Rampage.UnitsSpawned);
				else
					SpawnRampage ("Rampage2", Rampage.UnitsSpawned);
				end
			elseif Difficulty == DIFFICULTY_NORMAL then
				SpawnRampage ("Rampage2",  Rampage.UnitsSpawned);
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
		Rampage.Units[RampageCurrentSlot] = BuildObject(RampageUnit, comp_team, "RecyclerEnemy");
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

return _RampageUnits;