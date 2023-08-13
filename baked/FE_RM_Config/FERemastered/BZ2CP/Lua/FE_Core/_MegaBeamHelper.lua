--[[ FE:Remastered Mega Beam Helper
Written by General BlackDragon
Version 1.0 6-6-2023 --]]

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');

local BeamSpin = 90.0;
local BeamSpeed = 7.0;
local BeamDirection = { 
		SetVector( 4000, 0, 4000),
		SetVector( -4000, 0, 4000),
		SetVector( 4000, 0, -4000),
		SetVector( -4000, 0, -4000),
}

local _MegaBeam = {}

local MegaBeam = {
	Handle = nil,
	Timer = 0.0,
	Active = false,
	Direction = 0,
	Pos = SetVector(0, 0, 0),
 }

function _MegaBeam.Save()
    return 
		MegaBeam;
end

function _MegaBeam.Load(MegaBeamData)	
	MegaBeam = MegaBeamData;
end

-- Set initial timers.
function _MegaBeam.InitialSetup()

	-- If the beam timer is <= 0, set a new timer.
	if MegaBeam.Timer <= 0 then 
		_MegaBeam.ResetTimer();
	end

end

-- Update the beam movement/timers.
function _MegaBeam.Update()

	if not MegaBeam.Active then
		-- If the beam timer is <= 0, Juli, do the thing!
		if MegaBeam.Timer <= 0 then 
			-- Target a random player.
			local Target = GetRandomPlayer();
			local TargetTeam = 0;
			
			-- if there is a valid target...
			if Target ~= nil then
			
				TargetTeam = GetTeamNum(Target);
				
				-- Prioritize Recycler, if deployed, otherwise target Player.
				local Recy = GetObjectByTeamSlot(TargetTeam, DLL_TEAM_SLOT_RECYCLER);
				if Recy ~= nil then
					Target = Recy;
				end
				
				-- Choose a scavenger? 20% chance, if one exists...
				local ScavChance = GetRandomFloat(1.0);
				if ScavChance < 0.2 then
					local Scavenger = GetEscortTarget(GetTeamNum(Target), TEAMRELATIONSHIP_ALLIEDTEAM);
					if Scavenger ~= nil then
						Target = Scavenger;
					end
				end
				
				_MegaBeam.StartBeam(Target);
				
			end	
		else -- count down timer.
			MegaBeam.Timer = MegaBeam.Timer - 1;
		end
	else -- Mega Beam is active.
	
		-- When it's finished moving, reset.
		if Move(MegaBeam.Handle, BeamSpin, BeamSpeed, BeamDirection[MegaBeam.Direction], true, true) then
			_MegaBeam.StopBeam();
		end
	end

end

-- Start a Mega Beam.
function _MegaBeam.StartBeam(Target)

	-- Get target data.
	MegaBeam.Pos = GetPosition(Target);
	
	MegaBeam.Pos.x = MegaBeam.Pos.x + 15.0 + GetRandomFloat(70.0);
	MegaBeam.Pos.z = MegaBeam.Pos.z + 15.0 + GetRandomFloat(70.0);
	MegaBeam.Pos.y = TerrainFindFloor(MegaBeam.Pos.x, MegaBeam.Pos.z);
	
	-- Choose a random diagonal direction.
	local Dir = 1 + math.floor(GetRandomFloat(4));
	if Dir > 4 then
		Dir = 4
	end
	
	MegaBeam.Direction = Dir;
	
	-- Start the Beam.
	--_MegaBeam.ResetTimer();
	StartEarthQuake(10.0);
	MegaBeam.Handle = BuildObject("mbbeam3", 15, MegaBeam.Pos);
	MegaBeam.Active = true;

end

-- Stop a Mega Beam.
function _MegaBeam.StopBeam()

	-- If the old beam is still alive, kill it.
	if IsAround(MegaBeam.Handle) then
		RemoveObject(MegaBeam.Handle);
	end
	
	-- Reset things
	StopEarthQuake();
	_MegaBeam.ResetTimer();
	MegaBeam.Active = false;

end

function _MegaBeam.ResetTimer()

	MegaBeam.Timer = SecondsToTurns(60.0 + GetRandomFloat(120)); -- Start the beam every 1-3 minutes. 
end


return _MegaBeam;