assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
require('_FECore');

--Strings
local WAIT_BEFORE_START = 2.0;
local WAIT_BETWEEN_ANIMS = 0.0;
local WAIT_BETWEEN_OBJS = 1.0;


local M = {
--Mission State
	MissionState = 0,
	MissionTimer = 0.0,
	MissionOver = false,
-- Bools

-- Current Animation vars
	--AnimEndTime = 0.0,
	AnimHandle = nil,
	AnimODF = "",
	AnimName = "",
	AnimFrames = 0,
	AnimFrame = 0,
-- Handles
	Player = nil,	--Player
	AnimObjects = {},
-- Ints
	TPS = 10,
	ObjectIndex = 0,
	AnimIndex = 0,
--Vectors

--End
	endme = 0
}

function InitialSetup()
	M.TPS = EnableHighTPS();
	--Preload to reduce lag spikes when resources are used for the first time.
	local preloadOdf = {		

	};
	for k,v in pairs(preloadOdf) do
		PreloadODF(v);
	end
	local preloadAudio = {

	};
	for k,v in pairs(preloadAudio) do
		PreloadAudioMessage(v);
	end
end

function Save()
    return M;
end

function Load(...)
	if select('#', ...) > 0 then
		M = ...;
    end
end

function Start()
	GLOBAL_lock(_G);	--prevents script from accidentally creating new global variables.
end

function AddObject(h)
	if not IsPlayer(h) then
		local odfName = GetOdf(h);
		local animCount = GetODFInt(odfName, "GameObjectClass", "animCount");
		if animCount ~= nil and animCount > 0 then
			print(odfName .. " animations: "..animCount);
			local animArr = {};
			for i=1,animCount do
				local animName = GetODFString(odfName, "GameObjectClass", string.format("animName%d", i));
				local animFile = GetODFString(odfName, "GameObjectClass", string.format("animFile%d", i));
				print("animName: "..animName);
				animArr[#animArr+1] = {name=animName, file=animFile};
			end	
			M.AnimObjects[#M.AnimObjects+1] = {handle=h, odf=odfName, anims=animArr};
		end
	end
end

function DeleteObject(h)
	
end

function Info(s)
	print(s);
	ClearObjectives();
	AddObjective(s, "white");
end

function Update()
	M.Player = GetPlayerHandle();
	if M.MissionTimer < GetTime() then
		if M.MissionState == 0 then
			Info(string.format("Found %d objects with animations.", #M.AnimObjects));
			M.ObjectIndex = 0;
			M.MissionState = M.MissionState + 1;
			M.MissionTimer = GetTime() + WAIT_BEFORE_START;
		elseif M.MissionState == 1 then
			M.ObjectIndex = M.ObjectIndex + 1;
			if M.ObjectIndex > #M.AnimObjects then
				Info("Done.");
				M.MissionState = 99;
			else
				M.AnimIndex = 0;
				M.AnimHandle = M.AnimObjects[M.ObjectIndex]["handle"];
				M.AnimODF = M.AnimObjects[M.ObjectIndex]["odf"];
				print("Playing animations for "..tostring(M.AnimODF));
				SetObjectiveOn(M.AnimHandle);
				M.MissionState = M.MissionState + 1;
				if M.ObjectIndex > 1 then
					M.MissionTimer = GetTime() + WAIT_BETWEEN_OBJS;
				end
			end
		elseif M.MissionState == 2 then
			M.AnimIndex = M.AnimIndex + 1;
			if M.AnimIndex > #M.AnimObjects[M.ObjectIndex]["anims"] then
				SetObjectiveOff(M.AnimHandle);
				M.MissionState = M.MissionState - 1;
			else
				M.MissionState = M.MissionState + 1;
				if M.AnimIndex > 1 then
					M.MissionTimer = GetTime() + WAIT_BETWEEN_ANIMS;
				end
			end
		elseif M.MissionState == 3 then
			M.AnimName = M.AnimObjects[M.ObjectIndex]["anims"][M.AnimIndex]["name"];
			M.AnimFrames = SetAnimation(M.AnimHandle, M.AnimName);	--returns #ticks at 30TPS no matter what the actual TPS is??
			M.AnimFrame = 0;
			StartAnimation(M.AnimHandle);
			print(string.format("Playing animation: '%s' (%d frames)", M.AnimName, M.AnimFrames));
			M.MissionState = M.MissionState + 1;
			--M.AnimEndTime = GetTime() + M.AnimFrames / M.TPS;
		elseif M.MissionState == 4 then
			M.AnimFrame = M.AnimFrame + 1;
			if M.AnimFrame > M.AnimFrames then
				local handle = M.AnimObjects[M.ObjectIndex]["handle"];
				--SetAnimation(handle, "");	--need a StopAnimation()!
				M.MissionState = M.MissionState - 2;
			else
				local numAnims = #M.AnimObjects[M.ObjectIndex]["anims"];
				ClearObjectives();
				AddObjective(string.format("ODF: %s", M.AnimODF));
				AddObjective(string.format("Playing animation %d of %d: '%s' (frame %d/%d)", M.AnimIndex, numAnims, M.AnimName, M.AnimFrame, M.AnimFrames));
			end
		end
	end
end
