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

	if IsNetworkOn() then
		Monster.Delay = GetVarItemInt("network.session.ivar70"); --40
	else
		Monster.Delay = IFace_GetInteger("options.instant.int1");
	end
	
	Monster.Delay = Monster.Delay * 60.0; -- convert to minutes.

	if (Monster.Delay < 0) then
		Monster.Delay = 60; -- min one minute.
	elseif (Monster.Delay > 1800) then -- 5 hours? naw too long, set for 10 minutes.
		Monster.Delay = 600;
	end

	local iShift = GetRandomFloat(Monster.Delay * 0.2);
	Monster.Delay = ((Monster.Delay * 0.9) + iShift) * TPS;

end

function _Monster.Update(Difficulty, CPUTeam, HumanTeam)

	if Monster.Delay == GetTurnCount() then --if Monster.Delay % GetTurnCount() == 0 then -- Set this to repeat the event... Original Rev D code didn't repeat. Rev C might have tho...
		local MonsterODF = nil;
		
		if IsNetworkOn() then
			MonsterODF = GetVarItemStr("network.session.svar19");
		else
			MonsterODF = IFace_GetString("options.instant.string5");
		end
		
		if(MonsterODF == nil or MonsterODF == "") then
			MonsterODF = "monster";
		end

		local enemy_recycler = GetObjectByTeamSlot(CPUTeam, DLL_TEAM_SLOT_RECYCLER);
		
		if (IsAround(enemy_recycler) and (Difficulty ~= DIFFICULTY_EASY)) then
			
			if DoesPathExist("Monster1") then
				Monster.Monster1 = BuildObject(MonsterODF, CPUTeam, "Monster1");
			else
				Monster.Monster1 = BuildObject(MonsterODF, CPUTeam, GetPositionNear(enemy_recycler, 20.0, 30.0));
			end
			
			if DoesPathExist("Monster2") then
				Monster.Monster2 = BuildObject(MonsterODF, CPUTeam, "Monster2");
			else
				Monster.Monster2 = BuildObject(MonsterODF, CPUTeam, GetPositionNear(enemy_recycler, 20.0, 30.0));
			end
			
			if (Difficulty >= DIFFICULTY_HARD) then
				if DoesPathExist("Monster3") then
					Monster.Monster2 = BuildObject(MonsterODF, CPUTeam, "Monster3");
				else
					Monster.Monster2 = BuildObject(MonsterODF, CPUTeam, GetPositionNear(enemy_recycler, 20.0, 30.0));
				end
			end

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