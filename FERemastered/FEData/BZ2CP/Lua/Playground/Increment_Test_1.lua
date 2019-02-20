-- Testing the incrementation of Global Variables (AI_Unit);
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local Globals = require('Global_Variables');

local test_1 = {}

function test_1.IncrementMethod() 
	print("Incrementing global int value in File 1");
	Globals.Increment();
	print("Incrementing complete");
end

return test_1;