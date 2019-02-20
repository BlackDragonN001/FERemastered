-- Testing the incrementation of Global Variables (AI_Unit);

local Globals = {}

local int_test = 1;

function Globals.Increment() 
	int_test = int_test + 1;
	print("Global: Incrementing int to " .. int_test);
end

return Globals;