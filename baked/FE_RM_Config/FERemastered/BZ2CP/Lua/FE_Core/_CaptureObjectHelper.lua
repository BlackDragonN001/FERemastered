--[[ FE:Remastered Capture Object Helper
Written by General BlackDragon
Version 1.0 7-30-2023 --]]

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');

local _CaptureObject = {}


local Capture = {
	Capturee = nil,
	Done = false,
 }
  
function _CaptureObject.Save()
    return 
		Capture;
end

function _CaptureObject.Load(CaptureObjectData)	
	Capture = CaptureObjectData;
end

function _CaptureObject.Setup()

	local CaptureeODF = GetVarItemStr("network.session.svar20");
	if(CaptureeODF ~= nil and CaptureeODF ~= "") then
		Capture.Capturee = BuildObject(CaptureeODF, 0, "Capturee");
		if not IsAround(Capture.Capturee) then
			Capture.Done = true;
		end
	end
end

function _CaptureObject.Update()

	if Capture.Done then
		return;
	end
	
	local Capturer = GetNearestVehicle(Capture.Capturee);
	if (GetDistance(Capturer, Capture.Capturee) <= 40.0) then
		local CapturerTeamNum = GetTeamNum(Capturer);

		-- switch teams to team of capturer
		if (GetTeamNum(Capture.Capturee) == 0) then
		--	PrintConsoleMessage(">>>>>>>> Item has been captured!");

			-- This is a test to fix the power generator issue remove if it totally destabilizes everything
			Capture.Capturee = ReplaceObject(CaptureObject.Capture, nil, CapturerTeamNum);
			SetSkill(Capture.Capturee, 2);

			--SetTeamNum(Capture.Capturee, CapturerTeamNum);
			--SetSkill(Capture.Capturee, 2);
		end
		Capture.done = true;
	end
end

return _CaptureObject;