-- Testing the incrementation of Global Variables (AI_Unit);
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local Globals = require('Global_Variables');

local test2 = {}

function test2.IncrementMethod() 
	print("Incrementing global int value in File 2");
	Globals.Increment();
	print("Incrementing complete");
end

return test2;