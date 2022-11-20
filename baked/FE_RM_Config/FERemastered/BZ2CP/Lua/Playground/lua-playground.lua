-- Testing the incrementation of Global Variables (AI_Unit);
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local File1 = require('Increment_Test_1');
local File2 = require('Increment_Test_2');

local _SPUtils = require('_SPUtils');

function Start()
	EnableHighTPS();

	File1.IncrementMethod();
	File2.IncrementMethod();

	local units = {'ivtank', 'ivscout', 'ivmisl', 'ivtank'};

	_SPUtils.BuildObjectSpread(units, 1, 'spawn_1', 'ISDF_');
	_SPUtils.PortalUnitsSpread(units, 1, GetHandle('portal'), 'spawn_1_dropoff', 'ISDF_PORTAL_');
end