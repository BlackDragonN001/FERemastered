print("Loading _FECore.lua");
--===================================================
-- Forgotten Enemies Core Helper Lua.
-- Written by General BlackDragon.
-- Links all the individual Lua Moduels together.
--===================================================

-- Key Asset/Require Loader.
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');
require('_DLLUtils');
local _Subtitles = require('_Subtitles');
local _MapReloader = require('_MapReloader');
local _PropHeightFix = require('_PropHeightFix');
local _ObjectReplacer = require('_ObjectReplacer');

-- FE Moduels.
--require('_PortalHelper');
--require('_DispatchHelper');
--require('_AttacherHelper');
--require('_AIWeaponHelper');
--require('_CarrierHelper');


local _FECore = {}

local KillEjectedPilot = nil -- boolean used by AddObject, ObjectKilled, PlayerEjected

-- Core game functions.
function _FECore.InitialSetup()

-- Call helper functions.

	_ObjectReplacer.InitialSetup();

end

function _FECore.Start()

-- Call helper functions.
	_MapReloader.Start();
	_PropHeightFix.Start();

end

function _FECore.Load()

-- Call helper functions.

end

function _FECore.Save()

-- Call helper functions.

end

function _FECore.AddObject(h)

-- Call helper functions.

	_PropHeightFix.AddObject(h);
	
	-- Setup Difficulty settings. Used in SP/IA only! (Individual mission scripts can override after BuildObject() call.
	if not IsNetworkOn() then
		local Difficulty = IFace_GetInteger("options.play.difficulty");
		local Team = GetTeamNum(h);
		
		if (Team > 0) then
			if IsTeamAllied(GetTeamNum(h), 1) then -- Always max out player's units. -GBD
				SetSkill(h, 3);
			else -- Set Enemy based on Difficulty setting in Options. -GBD
				SetSkill(h, Difficulty + 1);
			end
		end
--	else -- For MPI, Add Turrets to custom Dispatcher. Leave SP missions alone.
--		AddToDispatch(h, 15.0, false, 0, (Difficulty < 2)); -- Based on Difficulty, if Hard, AI can Cloak on their own, and doesn't Flee.
	end

	-- Special logic for evkami, kill the ejected pilot
	if KillEjectedPilot == true then
		KillEjectedPilot = nil
		SetLifeSpan(h, 1e-30)
	end
end

function _FECore.DeleteObject(h)

-- Call helper functions.

end

function _FECore.Update()

-- Call helper functions.
	_Subtitles.Run();

end


-- Special logic for evkami, kamakazi unit. Don't let the Player eject.
function _FECore.PlayerEjected(DeadObjectHandle)
	-- Special logic for evkami, kill the ejected pilot
	if GetODFBool(DeadObjectHandle, "CraftClass", "killEjectedPilot", false) then
		KillEjectedPilot = true -- AddObject checks this value
		return 0 -- EJECTKILLRETCODES_DOEJECTPILOT; triggers AddObject on the ejected pilot's handle
	else	
		return nil
	end
end

function _FECore.ObjectKilled(DeadObjectHandle, KillersHandle)
	-- Special logic for evkami, kill the ejected pilot
	if GetODFBool(DeadObjectHandle, "CraftClass", "killEjectedPilot", false) then
		KillEjectedPilot = true -- AddObject checks this value
		return 0 -- EJECTKILLRETCODES_DOEJECTPILOT; triggers AddObject on the ejected pilot's handle
	else	
		return nil
	end
end

function _FECore.AudioWithSubtitles(clip)
	_Subtitles.AudioWithSubtitles(clip);
end

function PreOrdnanceHit(ShooterHandle, VictimHandle, OrdnanceTeam, OrdnanceODF)

-- Call helper functions.

	if ((not IsNetworkOn()) and (GetVarItemInt("network.session.ivar116") == 1)) and IsPlayer(ShooterHandle) and GetTarget(ShooterHandle) == VictimHandle then
		Damage(VictimHandle, 10000); -- It's over 9000! -GBD
	end

end

--]]

print("Loaded _FECore.lua");

return _FECore;
