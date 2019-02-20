-- Testing the incrementation of Global Variables (AI_Unit);
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local File1 = require('Increment_Test_1');
local File2 = require('Increment_Test_2');

function Start()
	File1.IncrementMethod();
	File2.IncrementMethod();
end