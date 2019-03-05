local _GlobalVariables = {};

-- TEAM RELATIONSHIPS
_GlobalVariables.TEAMRELATIONSHIP_INVALIDHANDLE = 0 -- One or both handles is invalid
_GlobalVariables.TEAMRELATIONSHIP_SAMETEAM = 1 -- Team # for both items is the same
_GlobalVariables.TEAMRELATIONSHIP_ALLIEDTEAM = 2 -- Team # isn't identical, but teams are allied
_GlobalVariables.TEAMRELATIONSHIP_ENEMYTEAM = 3 --Team # isn't identical, and teams are enemies

-- TEAM SLOT VARS
_GlobalVariables.DLL_TEAM_SLOT_RECYCLER = 1
_GlobalVariables.DLL_TEAM_SLOT_FACTORY = 2
_GlobalVariables.DLL_TEAM_SLOT_ARMORY = 3
_GlobalVariables.DLL_TEAM_SLOT_TRAINING = 4
_GlobalVariables.DLL_TEAM_SLOT_BOMBERBAY = 5
_GlobalVariables.DLL_TEAM_SLOT_SERVICE = 6
_GlobalVariables.DLL_TEAM_SLOT_TECHCENTER = 7
_GlobalVariables.DLL_TEAM_SLOT_COMMTOWER = 8
_GlobalVariables.DLL_TEAM_SLOT_BASE4 = 9
_GlobalVariables.DLL_TEAM_SLOT_BASE5 = 10
_GlobalVariables.DLL_TEAM_SLOT_BASE6 = 11
_GlobalVariables.DLL_TEAM_SLOT_BASE7 = 12
_GlobalVariables.DLL_TEAM_SLOT_BASE8 = 13
_GlobalVariables.DLL_TEAM_SLOT_BASE9 = 14

-- NETLIST VARS
_GlobalVariables.NETLIST_MPVehicles = 0
_GlobalVariables.NETLIST_StratStarting = 1
_GlobalVariables.NETLIST_Recyclers = 2
_GlobalVariables.NETLIST_AIPs = 3
_GlobalVariables.NETLIST_Animals = 4
_GlobalVariables.NETLIST_STCTFGoals = 5
_GlobalVariables.NETLIST_IAHumanRecyList = 6
_GlobalVariables.NETLIST_IACPURecyclers = 7
_GlobalVariables.NETLIST_IAAIPs = 8

_GlobalVariables.MAX_TEAMS = 16

_GlobalVariables.PREGETIN_DENY = 0 -- Deny the pilot entry to the craft
_GlobalVariables.PREGETIN_ALLOW = 1 -- Allow the pilot entry

_GlobalVariables.PRESNIPE_KILLPILOT = 0 -- Kill the pilot (1.0-1.3.6.4 default). Does still pass this to bullet hit code, where damage might also be applied
_GlobalVariables.PRESNIPE_ONLYBULLETHIT = 1 -- Do not kill the pilot. Does still pass this to bullet hit code, where damage might also be applied

_GlobalVariables.DoEjectPilot = 0 -- Do 'standard' eject
_GlobalVariables.DoRespawnSafest = 1 -- Respawn a 'PLAYER' at safest spawnpoint
_GlobalVariables.DLLHandled = 2 -- DLL handled actions. Do nothing ingame
_GlobalVariables.DoGameOver = 3 -- Game over, man.

return _GlobalVariables;