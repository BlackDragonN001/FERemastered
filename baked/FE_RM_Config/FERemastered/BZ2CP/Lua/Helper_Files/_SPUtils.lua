print("Loading _SPUtils.lua");

local _FECore = require('_FECore');
local _SPUtils = {}

-- function: BuildObjectSpread Breakdown
------------------------------------------------------------------------------
-- h_list is a list of handles to spawn so should be passed in as a table.
------------------------------------------------------------------------------
-- team is the team number of what the handles should be placed on.
------------------------------------------------------------------------------
-- pos is the position of where they should spawn. 
-- pos is also used to find a dropoff point to send the units after they spawn.
------------------------------------------------------------------------------
-- label is used to label the unit for BuildObjectAndLabel so we can use that label in GetHandle();

function _SPUtils.BuildObjectSpread(h_list, team, pos, label)
	if (h_list == nil or label == nil) then
		print("The list of objects or label cannot be nil.");
		return;
	end

	local dropoff = pos .. '_dropoff';

	for i, v in ipairs(h_list) do
		-- Build the unit we need.
		local unit = BuildObjectAndLabel(h_list[i], team, GetPositionNear(GetPosition(pos), 5, 15), label .. i);

		-- Set the unit to a group.
		SetGroup(unit, i - 1);

		-- Send the the unit to the dropoff point.
		Goto(unit, dropoff, 0);
	end
end

-- function: PortalUnitsSpread Breakdown
------------------------------------------------------------------------------
-- h_list is a list of handles to spawn so should be passed in as a table.
------------------------------------------------------------------------------
-- team is the team number of what the handles should be placed on.
------------------------------------------------------------------------------
-- portal is the object of where they should teleport from. 
-- portal is also used to find a dropoff point to send the units after they spawn.
------------------------------------------------------------------------------
-- dropoff is used to send a unit to a position after it has been teleported in. 

function _SPUtils.PortalUnitsSpread(h_list, team, portal, dropoff, label) 
	if (h_list == nil or portal == nil or label == nil) then
		print("The list of objects, label or the portal value cannot be nil.");
		return;
	end

	for i, v in ipairs(h_list) do
		-- Build the unit we need.
		local unit = TeleportIn(h_list[i], team, portal, 30, label .. i);

		-- Set the unit to a group.
		SetGroup(unit, i - 1);

		-- Send the the unit to the dropoff point.
		Goto(unit, dropoff, 0);
	end
end

return _SPUtils;