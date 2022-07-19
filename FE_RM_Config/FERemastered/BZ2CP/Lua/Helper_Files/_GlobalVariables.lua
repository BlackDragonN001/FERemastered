--[[ Global Constants of BZCC. Do *NOT* try to change these. --]]

local _AICmd = require('_AICmd');

local _GlobalVariables = {};

DPID_UNKNOWN = 0xFFFFFFFF

-- TEAM RELATIONSHIPS
TEAMRELATIONSHIP_INVALIDHANDLE = 0 -- One or both handles is invalid
TEAMRELATIONSHIP_SAMETEAM = 1 -- Team # for both items is the same
TEAMRELATIONSHIP_ALLIEDTEAM = 2 -- Team # isn't identical, but teams are allied
TEAMRELATIONSHIP_ENEMYTEAM = 3 --Team # isn't identical, and teams are enemies

-- TEAM SLOT VARS
DLL_TEAM_SLOT_RECYCLER = 1
DLL_TEAM_SLOT_FACTORY = 2
DLL_TEAM_SLOT_ARMORY = 3
DLL_TEAM_SLOT_TRAINING = 4
DLL_TEAM_SLOT_BOMBERBAY = 5
DLL_TEAM_SLOT_SERVICE = 6
DLL_TEAM_SLOT_TECHCENTER = 7
DLL_TEAM_SLOT_COMMTOWER = 8
DLL_TEAM_SLOT_BASE4 = 9
DLL_TEAM_SLOT_BASE5 = 10
DLL_TEAM_SLOT_BASE6 = 11
DLL_TEAM_SLOT_BASE7 = 12
DLL_TEAM_SLOT_BASE8 = 13
DLL_TEAM_SLOT_BASE9 = 14

-- NETLIST VARS
NETLIST_MPVehicles = 0
NETLIST_StratStarting = 1
NETLIST_Recyclers = 2
NETLIST_AIPs = 3
NETLIST_Animals = 4
NETLIST_STCTFGoals = 5
NETLIST_IAHumanRecyList = 6
NETLIST_IACPURecyclers = 7
NETLIST_IAAIPs = 8

MAX_TEAMS = 16
MAX_MULTIPLAYER_TEAMS = 2
MAX_MP_VEHICLES_ENTRIES = 32
MAX_STARTING_VEHICLES = 32

PREGETIN_DENY = 0 -- Deny the pilot entry to the craft
PREGETIN_ALLOW = 1 -- Allow the pilot entry

PREPICKUPPOWERUP_DENY = 0 -- Deny the powerup from being picked up
PREPICKUPPOWERUP_ALLOW = 1 -- Allow the powerup to be picked up

PRESNIPE_KILLPILOT = 0 -- Kill the pilot (1.0-1.3.6.4 default). Does still pass this to bullet hit code, where damage might also be applied
PRESNIPE_ONLYBULLETHIT = 1 -- Do not kill the pilot. Does still pass this to bullet hit code, where damage might also be applied

DoEjectPilot = 0 -- Do 'standard' eject
DoRespawnSafest = 1 -- Respawn a 'PLAYER' at safest spawnpoint
DLLHandled = 2 -- DLL handled actions. Do nothing ingame
DoGameOver = 3 -- Game over, man.

DMSubtype_Normal = 0
DMSubtype_KOH = 1
DMSubtype_CTF = 2
DMSubtype_Loot = 3
DMSubtype_RESERVED1 = 4 -- For internal Pandemic use-- Andrew's work
DMSubtype_Race1 = 5 -- Race, respawn as person
DMSubtype_Race2 = 6 -- Race, respawn as vehicle
DMSubtype_Normal2 = 7 -- Normal, but respawn as vehicle (no person)
DMIsRaceSubtype = {false,false,false,false,false,true,true,false};

HP1_ON = 1
HP2_ON = 2
HP3_ON = 4
HP4_ON = 8
HP5_ON = 16

Randomize_None = 0 -- Don't modify what they selected in the shell.
Randomize_ByRace = 1
Randomize_Any = 2

AUDIO_CAT_UNKNOWN = 0
AUDIO_CAT_UNIT_DLG = 1
AUDIO_CAT_MISSION_DLG = 2
AUDIO_CAT_INTERFACE = 3
AUDIO_CAT_WEAPON = 4
AUDIO_CAT_ORDNANCE = 5
AUDIO_CAT_EXPLOSION = 6
AUDIO_CAT_ENGINE = 7
AUDIO_CAT_AMBIENT = 8
AUDIO_CAT_MUSIC = 9

TEAMCOLOR_TYPE_DEFAULT = 0 -- Defaults
TEAMCOLOR_TYPE_GAMEPREFS = 1 -- What's set in gameprefs
TEAMCOLOR_TYPE_SERVER = 2 -- What the server sent us.
TEAMCOLOR_TYPE_CURRENT = 3 -- Valid only to GetFFATeamColor().

ONE_WAY_PATH = 0
ROUND_TRIP_PATH = 1
LOOP_PATH = 2 
BAD_PATH = 3 -- when it couldn't find a route. Used by HuntTask, Recycle[H]Task

TAUNTS_GameStart = 0
TAUNTS_NewHuman = 1
TAUNTS_LeftHuman = 2
TAUNTS_HumanShipDestroyed = 3
TAUNTS_HumanRecyDestroyed = 4
TAUNTS_CPURecyDestroyed = 5
TAUNTS_Random = 6
TAUNTS_Category7 = 7 -- Custom taunts headers, not used yet, but code now expects a max of 16 types for modding via Taunt ODFs. -GBD
TAUNTS_Category8 = 8
TAUNTS_Category9 = 9
TAUNTS_Category10 = 10
TAUNTS_Category11 = 11
TAUNTS_Category12 = 12
TAUNTS_Category13 = 13
TAUNTS_Category14 = 14
TAUNTS_Category15 = 15

CTRL_BRACCEL = bit32.lshift(1, 0)
CTRL_STEER = bit32.lshift(1, 1)
CTRL_PITCH = bit32.lshift(1, 2)
CTRL_STRAFE = bit32.lshift(1, 3)
CTRL_JUMP = bit32.lshift(1, 4)
CTRL_DEPLOY = bit32.lshift(1, 5)
CTRL_EJECT = bit32.lshift(1, 6)
CTRL_ABANDON = bit32.lshift(1, 7)
CTRL_FIRE = bit32.lshift(1, 8)

MAX_FLOAT = 3.402823466e+38


--[[ FE Custom Constants ]]--

PRETELEPORT_DEFAULT = 0 -- Allow default behavior.
PRETELEPORT_ALLOW = 1 -- Allow the teleport, reguardless.
PRETELEPORT_DENY = 2 -- Deny the teleport.

POSTTELEPORT_DEFAULT = 0 -- Default, does a Goto to the Portal exit point.
POSTTELEPORT_OVERRIDE = 1 -- Override Goto from Teleporter exit.


return _GlobalVariables;