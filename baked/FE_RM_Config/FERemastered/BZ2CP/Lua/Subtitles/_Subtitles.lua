--[[ 
	BZCC Subtitles
	Written by AI_Unit
	Version 1.0 14/09/2022
--]]

-- Return this to whatever file calls it.
local _Subtitles = {}

-- Only so we execute the CFG once.
local subtitlesLoaded = false;

-- Check to see if the subtitle panel is visible.
local startSubtitles = false;

-- Chosen subtitle.
local subtitleToUse = nil;

-- Store the playing clip so we can use it when it's finished.
local audioClip = nil;

-- Set the audioClip variable up so we can track when it's finished.
function _Subtitles.AudioWithSubtitles(clip)
	-- We need this to load subtitles into the List Box.
	subtitleToUse = RemoveWavExtension(clip) .. "_subtitle.txt";

	-- Set this global variable so we can keep track of the clip until it's finished.
	audioClip = AudioMessage(clip);

	-- Mark this as invisible so we can start the subtitles.
	startSubtitles = true;
end

-- Run every tick to maintain behaviour.
function _Subtitles.Run() 
	if (startSubtitles) then
		-- If we haven't loaded the module, load it up.
		if (not subtitlesLoaded) then
			IFace_Exec("bzgame_subtitles.cfg");
			subtitlesLoaded = true;
		end

		-- If the Subtitle file exists...
		if DoesFileExist(subtitleToUse) then
			-- Fill the listbox.
			IFace_FillListBoxFromText("SubtitlesPanel", subtitleToUse)

			-- Active the subtitle panel.
			IFace_Activate("SubtitlesPanel");
		end

		-- So we only run once.
		startSubtitles = false;
	end

	if (audioClip ~= nil) then
		if (IsAudioMessageDone(audioClip)) then
			IFace_Deactivate("SubtitlesPanel");
		end
	end
end

function RemoveWavExtension(string)
	return string:gsub("%.wav", "");
end

return _Subtitles;