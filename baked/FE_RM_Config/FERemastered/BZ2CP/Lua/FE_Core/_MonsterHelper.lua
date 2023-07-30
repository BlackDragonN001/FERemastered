--[[ FE:Remastered Monster Helper
Written by General BlackDragon
Version 1.0 7-30-2023 --]]

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');

local _Monster = {}

local Monster = {
	Monster1 = nil,
	Monster2 = nil,
	Delay = 0,
 }
 
function _Monster.Save()
    return 
		Monster;
end

function _Monster.Load(MonsterData)	
	Monster = MonsterData;
end

function _Monster.InitialSetup()

	Monster.Delay = GetVarItemInt("network.session.ivar40");

	if (Monster.Delay < 0) then
		Monster.Delay = 60;
	elseif (Monster.Delay > 1800) then
		Monster.Delay = 600;
	end

	local iShift = GetRandomFloat(Monster.Delay * 0.2);
	Monster.Delay = ((Monster.Delay * 0.9) + iShift) * 10;

end

function _Monster.Update(time_count, Difficulty, CPUTeam, HumanTeam)

	if Monster.Delay == time_count then
		local MonsterODF = GetVarItemStr("network.session.svar19");
		if(MonsterODF == nil or MonsterODF == "") then
			MonsterODF = "monster";
		end

		local enemy_recycler = GetObjectByTeamSlot(CPUTeam, DLL_TEAM_SLOT_RECYCLER);
		
		if (IsAround(enemy_recycler) and (Difficulty ~= DIFFICULTY_EASY)) then
			Monster.Monster1 = BuildObject(MonsterODF, CPUTeam, "Monster1");
			Monster.Monster2 = BuildObject(MonsterODF, CPUTeam, "Monster2");

			local hTarget1 = GetObjectByTeamSlot(HumanTeam, DLL_TEAM_SLOT_RECYCLER);
			if (not IsAround(hTarget1)) then
				hTarget1 = GetObjectByTeamSlot(HumanTeam, DLL_TEAM_SLOT_FACTORY);
				if (not IsAround(hTarget1)) then
					return;
				end
			end
			
			if (IsAround(Monster.Monster1)) then
				SetSkill(Monster.Monster1, 3);
				Attack(Monster.Monster1, hTarget1);
			end

			if (IsAround(Monster.Monster2)) then
				SetSkill(Monster.Monster2, 3);
				Attack(Monster.Monster2, hTarget1);
			end

			AudioMessage("bullcall.wav", false);
		end
	end
end

return _Monster;