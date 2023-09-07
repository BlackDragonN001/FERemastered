--[[ FE:Remastered Portal User Helper
Written by General BlackDragon
Version 1.0 7-30-2023 --]]

-- Helper Luas.
require('_GlobalHandler');
require('_GlobalVariables');

ALLY_CERBERI = "c"
ALLY_HADEAN = "e"
ALLY_ISDF = "i"
ALLY_SCION = "f"

local _PortalUser = {}

local PortalUser = {
	PUser = nil,
	Target = nil,
	TargetType = 0,
	Trigger = 0,
	NextAttack = 0,
	Race = nil,
	SendAttack = false,
	PortalE = nil,
	Portals  = {},
	PortalToUse = nil,
	DeadPortal = false,
	DrathRush = false,
	WaitCount = 0,
	RacesInUse = {},
	Types = {},
 }
 
 local ODFType =
{
	"vputank",
	"vpuatank",
	"vpuwalk",
	"vpuewalk",
	"vpuscout",
	"vpusent",
	"vpumisl",
	"vpuarch",
	"vpurckt",
	"vpuscav",
	"vpuserv",
	"vpumbike",
	"vpumort",
	"vputanku",
	"vpuatanku",
	"vpumislu",
	"vpurbomb",
	"vputurr",
	"vpuimbk2",
	"vpuirbmb2",
	"vpuirckt2",
	"vpuesct2",
	"vpuemisl2",
	"vpueatnk2",
	"vpufsct2",
	"vpufrbmb2",
	"vpufwalk2",
}

function IsType(h, odfname)

--	print("IsType: " .. GetOdf(h) .. ", " .. odfname);
	local odf = GetRace(h) .. odfname;
	return IsOdf(h, odf);

end


 
function _PortalUser.Save()
    return 
		PortalUser;
end

function _PortalUser.Load(PortalUserData)	
	PortalUser = PortalUserData;
end

function _PortalUser.InitialSetup()


end

function _PortalUser.Start()

end

function _PortalUser.AddObject(h, Team, ObjClass, ODFName, Difficulty, NumHumans)

	-- Initial run on pre-placed objects.
	if GetTurnCount() < 1 then
		local label = GetLabel(h);
		
		-- This better be a portal... -GBD
		if string.sub(label, 1, 7) == "PortalE" then
			if PortalUser.PortalE == nil then -- Save first PortalE found.
				PortalUser.PortalE = h;
				print("Saving PortalE as: '" .. label .. "'");
			end
			table.insert(PortalUser.Portals, h);
			
			print("Found GroupE Portal: '" .. label .. "', Num PortalE: " .. #PortalUser.Portals);
		end
		
		-- Check for pre-placed portalUsers on the map...
		if string.sub(label, 1, 10) == "PortalUser" then
			-- If this is a PortalUserType, save it's portal handle in a table indexed by ODFName.
			local PortalToUse = GetNearestBuilding(h);
			if GetPortalGroup(PortalToUse) ~= 0 then
				PortalUser.Types[ODFName] = PortalToUse;
			end
			RemoveObject(h); -- remove it
		end
		
	end
	
	-- Save which race(s) are in use, so we know which ALLY_RACE to spawn.
	if IsRecycler(h) then
		local add = true;
		local race = GetRace(h);
		for i = 1, #PortalUser.RacesInUse do
			if PortalUser.RacesInUse[i] == race then
				add = false;
				break;
			end
		end
		if add then
			--table.insert(PortalUser.RacesInUse, race);
			PortalUser.RacesInUse[race] = true;
			
			PortalUser.Race = UpdateGroupERace();
		end
	end
	

	if GetPlayerHandle(Team) ~= nil then
	
		if (ObjClass == "CLASS_FACTORY") then
			if (PortalUser.Trigger == 0) then
				-- set the alien attack trigger
				PortalUser.Trigger = (GetTurnCount() % 2) + 1;
			end
		elseif (ObjClass == "CLASS_ARMORY") then
			if (PortalUser.NextAttack == 0 and PortalUser.Trigger == 1) then
				-- initialize the alien attack interval
				PortalUser.NextAttack = GetTurnCount() + SecondsToTurns(720) - ((NumHumans - 1) * SecondsToTurns(90)) + ((GetTurnCount() / TPS) % SecondsToTurns(60));
			end
		elseif (ObjClass == "CLASS_SUPPLYDEPOT") then
			if (PortalUser.NextAttack == 0 and PortalUser.Trigger == 2) then
				-- initialize the alien attack interval
				PortalUser.NextAttack = GetTurnCount() + SecondsToTurns(720) - ((NumHumans - 1) * SecondsToTurns(90)) + ((GetTurnCount() / TPS) % SecondsToTurns(60));
			end
		elseif (ObjClass == "CLASS_COMMBUNKER" or ObjClass == "CLASS_COMMTOWER") then
			if (PortalUser.NextAttack == 0 and PortalUser.Trigger == 3) then
				-- initialize the alien attack interval
				PortalUser.NextAttack = GetTurnCount() + SecondsToTurns(720) - ((NumHumans - 1) * SecondsToTurns(90)) + ((GetTurnCount() / TPS) % SecondsToTurns(60));
			end
		elseif ((ObjClass == "CLASS_ASSAULTTANK") or (ObjClass == "CLASS_ASSAULTHOVER")) then
			if (anti_assault) then
				PortalUser.TargetType = 1;
				PortalUser.SendAttack = true;
			end
		elseif (ObjClass == "CLASS_WALKER") then
			if (anti_assault) then
				PortalUser.TargetType = 2;
				PortalUser.SendAttack = true;
			end
		elseif (ObjClass == "CLASS_TURRET") then
			
			if (Difficulty ~= DIFFICULTY_EASY) then
				hPrevGT = hLastGT;
				hLastGT = h;

				PortalUser.Target = h;
				PortalUser.TargetType = 3;
				PortalUser.SendAttack = true;
			end

		elseif (ObjClass == "CLASS_PLANT") then
			
			if ODFName == "fblung" then

				if ((GetTurnCount() / TPS) % 3 == 0) then
					if (Difficulty == DIFFICULTY_HARD) then
						PortalUser.Target = h;
						PortalUser.TargetType = 4;
						PortalUser.SendAttack = true;
					end
				end
			else
				if (Difficulty == DIFFICULTY_HARD) then
					PortalUser.Target = h;
					PortalUser.TargetType = 4;
					PortalUser.SendAttack = true;
				end
			end
		end		
	else
	
	-- See if this unit should go to a portal.
	-- Cerberi handled in DoGenericStrategy
		if ((GetRace(h) ~= 'c') or (GetRace(h) ~= 'a')) then
			local TempHandle = GetPortalToUse(h, ODFName);
			if (TempHandle ~= nil and PortalUser.PUser == nil) then
			
				--print("--- PortalUser Created");

				PortalUser.PUser = h;
				PortalUser.WaitCount = 0;
				PortalUser.PortalToUse = TempHandle;
			else
			
				if (IsOdf(h, "evpumislu") or IsOdf(h, "ivpurckt") or IsOdf(h,"fvpuarch")) then
					m_PortalGroup = 0;
					PortalUser.PUser = h;
					PortalUser.WaitCount = 0;
					PortalUser.PortalToUse = nil;
				elseif (IsOdf(h, "evpuatank") or IsOdf(h, "ivpurbomb") or IsOdf(h, "fvpurbomb")) then
					m_PortalGroup = 1;
					PortalUser.PUser = h;
					PortalUser.WaitCount = 0;
					PortalUser.PortalToUse = nil;
				elseif (IsOdf(h, "evpuatanku") or IsOdf(h, "ivpuatank") or IsOdf(h, "fvpuwalk")) then
					m_PortalGroup = 2;
					PortalUser.PUser = h;
					PortalUser.WaitCount = 0;
					PortalUser.PortalToUse = nil;
				elseif (IsOdf(h, "ivpuewalk") or IsOdf(h, "ivpuwalk") or IsOdf(h, "fvpuatank")) then
					m_PortalGroup = 3;
					PortalUser.PUser = h;
					PortalUser.WaitCount = 0;
					PortalUser.PortalToUse = nil;
				elseif (IsType(h, "vputank") or IsType(h, "vpuscout") or IsType(h, "vpusent")) then
					m_PortalGroup = 5;
					PortalUser.PUser = h;
					PortalUser.WaitCount = 0;
					PortalUser.PortalToUse = nil;
				elseif (IsType(h, "vpuscav") or IsType(h, "vpuserv") or IsType(h, "vpumbike") or IsType(h, "vpumort") or IsType(h, "vputanku")) then
					RemoveObject(h);
				end
			end
		end
	end

end

function _PortalUser.Update(NumHumans, Difficulty, siege_on, anti_assault, late_game)


	-- If a portal user has been created then send him to his designated portal.
	if (PortalUser.PUser ~= nil) then
		if (#PortalUser.Portals) then	--@@@NB_FE_MPI02
			-- Give the unit 1 second after creation, then command it to the portal.
			PortalUser.WaitCount = PortalUser.WaitCount + 1;
			if (PortalUser.WaitCount > TPS) then
				if (IsAround(PortalUser.PortalToUse)) then
					Goto(PortalUser.PUser, PortalUser.PortalToUse, 1);
					PortalUser.PUser = nil;
				else
					PortalUser.DeadPortal = true; --@@@NB_FE_MPI02
				end
			end
		end

		--@@@NB_FE_MPI02
		if (#PortalUser.Portals <= 1 or PortalUser.DeadPortal) then
		
			if IsAround(PortalUser.PortalToUse) then
			
				local portalGroup = GetPortalGroup(PortalUser.PortalToUse);
				if portalGroup ~= 0 then
			
					if PortalGroup == "A" then --case 0:
						Goto(NearVehicle, "hold1");
					elseif PortalGroup == "B" then --case 1:
						Goto(NearVehicle, "hold2");
					elseif PortalGroup == "C" then --case 2:
						Goto(NearVehicle, "hold3");
					elseif PortalGroup == "D" then --case 3:
						Goto(NearVehicle, "hold4");
					elseif PortalGroup == "E" then --case 4: --Cerberi attack squads
						RemoveObject(PortalUser.PUser);	-- Cerberi
					else
						
						print("--- Update PortalUser Send");
						
						local Team = GetTeamNum(PortalUser.PUser);
					
						if (IsType(PortalUser.PUser,"vpuscout") or IsType(PortalUser.PUser,"vpusent")) then
							Patrol(PortalUser.PUser, Team .. "Patrol1");
						elseif (IsType(PortalUser.PUser,"vputank")) then
							Patrol(PortalUser.PUser, Team .. "Patrol2");
						else
							local hTarget = GetObjectByTeamSlot(1, (((GetTurnCount() / TPS) % 5) + 1));
							if (not IsAround(hTarget)) then
								hTarget = GetObjectByTeamSlot(strat_team, DLL_TEAM_SLOT_RECYCLER);
								if (not IsAround(hTarget)) then
									hTarget = GetObjectByTeamSlot(strat_team, DLL_TEAM_SLOT_FACTORY);
								end
							end
							Attack(PortalUser.PUser, hTarget);
						end
					end
				end
			end
			PortalUser.PUser = nil;
		end
	end	


	--@@@NB_FE_MPI02
	-- build alien off-map reinforcements
	--
	--@@@Centerline_FE_MPI - modified to check if a DestinationPortal exists before we make
	-- more units. If no DestinationPortal exists for groupE then we shouldn't build anymore
	-- units.
	--
	--if (have_groupE and IsAround(PortalUser.PortalE))
	if (IsAround(PortalUser.PortalE) and DestinationPortal() ~= nil) then
		local hTemp = nil;
		local tmpint = 0;
		local iX;

		if (PortalUser.SendAttack) then
			if (PortalUser.TargetType == 1) then	-- assault tank
			
				print(">>>>>>>> Cerberi should attack tank.");

				if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpurbomb", CPU_START_TEAM, "groupE");
				elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuemisl2", CPU_START_TEAM, "groupE");
				elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirbmb2", CPU_START_TEAM, "groupE");
				elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufrbmb2", CPU_START_TEAM, "groupE"); end
				Goto(hTemp, PortalUser.PortalE, 1);

				for iX = 1, NumHumans + 1 do
					if ((GetTurnCount() / TPS) % (2 + iX) > 0) then
						if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvputank", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuemisl2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirbmb2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufrbmb2", CPU_START_TEAM, "groupE"); end
						Goto(hTemp, PortalUser.PortalE, 1);
					end
				end
			elseif (PortalUser.TargetType == 2) then	-- walker
			
				print(">>>>>>>> Cerberi should attack walker.");

				--@@@Centerline_FE_MPI - Reenabled the cvpuwalk and disabled the cvpurbomb
				if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpuwalk", CPU_START_TEAM, "groupE");
				--if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpurbomb", CPU_START_TEAM, "groupE");
				elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpueatnk2", CPU_START_TEAM, "groupE");
				elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirckt2", CPU_START_TEAM, "groupE");
				elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufwalk2", CPU_START_TEAM, "groupE"); end
				Goto(hTemp, PortalUser.PortalE, 1);

				for iX = 1, NumHumans + 1 do
					if ((GetTurnCount() / TPS) % (2 + iX) > 0) then
						if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvputank", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuemisl2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirbmb2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufrbmb2", CPU_START_TEAM, "groupE"); end
						Goto(hTemp, PortalUser.PortalE, 1);
					end
				end
			elseif (PortalUser.TargetType == 3) then	-- tower
			
				print(">>>>>>>> Cerberi should attack tower.");

				if (Difficulty == DIFFICULTY_HARD) then
					if (late_game or anti_assault) then
						if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpurbomb", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuemisl2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirbmb2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufrbmb2", CPU_START_TEAM, "groupE"); end
						Goto(hTemp, PortalUser.PortalE, 1);
					else
						if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvputank", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuemisl2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirbmb2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufrbmb2", CPU_START_TEAM, "groupE"); end
						Goto(hTemp, PortalUser.PortalE, 1);
					end
				end

				if (not IsOdf(PortalUser.Target,"ebgt2g")) then
					--if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpuatank", CPU_START_TEAM, "groupE");
					if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpurbomb", CPU_START_TEAM, "groupE");
					elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuemisl2", CPU_START_TEAM, "groupE");
					elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirbmb2", CPU_START_TEAM, "groupE");
					elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufrbmb2", CPU_START_TEAM, "groupE"); end
					Goto(hTemp, PortalUser.PortalE, 1);
				end

				if (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuesct2", CPU_START_TEAM, "groupE");
				elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuimbk2", CPU_START_TEAM, "groupE");
				elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufsct2", CPU_START_TEAM, "groupE"); end
				if (PortalUser.Race ~= ALLY_CERBERI) then Goto(hTemp, PortalUser.PortalE, 1); end

				for iX = 1, NumHumans + 1 do
					if ((GetTurnCount() / TPS) % (2 + iX) > 0) then
						if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpuscout", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuesct2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuimbk2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufsct2", CPU_START_TEAM, "groupE"); end
						Goto(hTemp, PortalUser.PortalE, 1);
					end
				end
			elseif (PortalUser.TargetType == 4) then -- power
				print(">>>>>>>> Cerberi should attack power.");

				if (late_game or anti_assault) then
					if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpurbomb", CPU_START_TEAM, "groupE");
					elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuemisl2", CPU_START_TEAM, "groupE");
					elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirbmb2", CPU_START_TEAM, "groupE");
					elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufrbmb2", CPU_START_TEAM, "groupE"); end
					Goto(hTemp, PortalUser.PortalE, 1);
				end

				if (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuesct2", CPU_START_TEAM, "groupE");
				elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuimbk2", CPU_START_TEAM, "groupE");
				elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufsct2", CPU_START_TEAM, "groupE"); end
				if (PortalUser.Race ~= ALLY_CERBERI) then Goto(hTemp, PortalUser.PortalE, 1); end

				for iX = 1, NumHumans + 1 do
					if ((GetTurnCount() / TPS) % (3 + iX) > 0) then
						if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpuscout", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuesct2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuimbk2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufsct2", CPU_START_TEAM, "groupE"); end
						Goto(hTemp, PortalUser.PortalE, 1);
					end
				end
			end
			PortalUser.SendAttack = false;
		end

		if (GetTurnCount() == PortalUser.NextAttack) then
			print(">>>>>>>> Cerberi should attack base.");

			-- Drath rush
			if (PortalUser.DrathRush and (Difficulty == DIFFICULTY_HARD)) then
			
				for iX = 1, NumHumans + 2 do
					if ((GetTurnCount() / TPS) % (2 + iX) > 0) then
						--@@@Centerline_FE_MPI - Reenabled the cvpuwalk and disabled the cvpurbomb
						if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpuwalk", CPU_START_TEAM, "groupE");
						--if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpurbomb", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpueatnk2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirckt2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufwalk2", CPU_START_TEAM, "groupE"); end
						Goto(hTemp, PortalUser.PortalE, 1);
					end
				end
				PortalUser.DrathRush = false;
			end

			if (Difficulty == DIFFICULTY_HARD) then
			
				for iX = 1, NumHumans + 1 do
					if ((GetTurnCount() / TPS) % (3 + iX) > 0) then
						--if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpuwalk", CPU_START_TEAM, "groupE");
						if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpurbomb", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpueatnk2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirckt2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufwalk2", CPU_START_TEAM, "groupE"); end
						Goto(hTemp, PortalUser.PortalE, 1);
					end
				end
			end

			if (Difficulty == DIFFICULTY_MEDIUM) then
			
				for iX = 1, NumHumans + 1 do
					if ((GetTurnCount() / TPS) % (3 + iX) > 0) then
						--if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpuatank", CPU_START_TEAM, "groupE");
						if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpurbomb", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuemisl2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirbmb2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufrbmb2", CPU_START_TEAM, "groupE"); end
						Goto(hTemp, PortalUser.PortalE, 1);
					end
				end
			end

			if ((NumHumans > 1) and (Difficulty ~= DIFFICULTY_EASY)) then
			
				for iX = 1, NumHumans - 1 do
					if ((GetTurnCount() / TPS) % (2 + iX) > 0) then
						if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpurbomb", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuemisl2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuirbmb2", CPU_START_TEAM, "groupE");
						elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufrbmb2", CPU_START_TEAM, "groupE"); end
						Goto(hTemp, PortalUser.PortalE, 1);
					end
				end
			end

			if (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuesct2", CPU_START_TEAM, "groupE");
			elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuimbk2", CPU_START_TEAM, "groupE");
			elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufsct2", CPU_START_TEAM, "groupE"); end
			if (PortalUser.Race ~= ALLY_CERBERI) then Goto(hTemp, PortalUser.PortalE, 1); end

			for iX = 1, NumHumans + 1 do
				if ((GetTurnCount() / TPS) % (3 + iX) > 0) then
					if (PortalUser.Race == ALLY_CERBERI) then hTemp = BuildObject("cvpuscout", CPU_START_TEAM, "groupE");
					elseif (PortalUser.Race == ALLY_HADEAN) then hTemp = BuildObject("avpuesct2", CPU_START_TEAM, "groupE");
					elseif (PortalUser.Race == ALLY_ISDF) then hTemp = BuildObject("avpuimbk2", CPU_START_TEAM, "groupE");
					elseif (PortalUser.Race == ALLY_SCION) then hTemp = BuildObject("avpufsct2", CPU_START_TEAM, "groupE"); end
					Goto(hTemp, PortalUser.PortalE, 1);
				end
			end

			if (early_game) then
				tmpint = SecondsToTurns(660);
			else
				tmpint = SecondsToTurns(540);
			end
			
			if (Difficulty == DIFFICULTY_EASY) then
				tmpint = tmpint + SecondsToTurns(300);
			end
			
			tmpint = tmpint - ((NumHumans - 1) * SecondsToTurns(90));
			tmpint = tmpint + ((GetTurnCount() / TPS) % SecondsToTurns(60));
			
			if (siege_on) then
				tmpint = tmpint / 2;
			end
			
			PortalUser.NextAttack = GetTurnCount() + tmpint;
		end
	end

end

function PostTeleport(Portal, NearVehicle)

	--local TeleportedGroupE = false;
	
	if(NearVehicle == PortalUser.PUser) then
	
		local portalGroup = GetPortalGroup(Portal);
		if portalGroup ~= 0 then
			
			if PortalGroup == "A" then --case 0:
				Goto(NearVehicle, "hold1");
				return POSTTELEPORT_OVERRIDE;
			elseif PortalGroup == "B" then --case 1:
				Goto(NearVehicle, "hold2");
				return POSTTELEPORT_OVERRIDE;
			elseif PortalGroup == "C" then --case 2:
				Goto(NearVehicle, "hold3");
				return POSTTELEPORT_OVERRIDE;
			elseif PortalGroup == "D" then --case 3:
				Goto(NearVehicle, "hold4");
				return POSTTELEPORT_OVERRIDE;
			elseif PortalGroup == "E" then --case 4: --Cerberi attack squads
			
				--TeleportedGroupE = true;	--@@@Centerline_FE_MPI
				
				if (IsAround(PortalUser.Target)) then
					Attack(NearVehicle, PortalUser.Target);
					return POSTTELEPORT_OVERRIDE;
				else
					local hTarget = GetObjectByTeamSlot(1, (((GetTurnCount() / TPS) % 5) + 1));
					if (not IsAround(hTarget)) then
						hTarget = GetObjectByTeamSlot(1, DLL_TEAM_SLOT_RECYCLER);
						if (not IsAround(hTarget)) then
							hTarget = GetObjectByTeamSlot(1, DLL_TEAM_SLOT_FACTORY);
						end
					end
					Attack(NearVehicle, hTarget);
					return POSTTELEPORT_OVERRIDE;
				end
			elseif PortalGroup == "F" then --case 5: -- Patrol squads
				local PortalNumber = string.sub(label, 7, 8);
				local PatrolPath = "partalPatrol" .. PortalNumber;
				Patrol(NearVehicle, PatrolPath);
				return POSTTELEPORT_OVERRIDE;
			end
		end
	end
	
	return POSTTELEPORT_DEFAULT;
end

function _PortalUser.UpdateTimer(difficulty, drath_rush)
	if (PortalUser.NextAttack > 0) then
		PortalUser.NextAttack = GetTurnCount() + SecondsToTurns(10);
	end
	
	if (difficulty == DIFFICULTY_HARD) and drath_rush then
		PortalUser.DrathRush = true;
	end
end

function DestinationPortal()

	if #PortalUser.Portals > 1 then
	
		for i = 1, #PortalUser.Portals do
			if i > 1 and IsAround(PortalUser.Portals[i]) then
				return true;
			end
		end
	end

	return false;
end

function GetPortalToUse(h, ODFName)

	return PortalUser.Types[ODFName];
end

function GetPortalGroup(portal)

	local group = 0;
	if IsAround(portal) then
		local label = GetLabel(portal);
			
		if string.sub(label, 1, 6) == "Portal" then
			-- PortalGroup 0 = A, 1 = B, 2 = C, 3 = D, 4 = E, 5 = F,
			local portalGroup = string.sub(label, 6, 7);
			group = portalGroup;
		end
	end
	
	return group;
end

function UpdateGroupERace()

	-- Try GroupE Race by priority, avoid races in use.
	if PortalUser.RacesInUse["c"] == nil then
		return "c";
	elseif PortalUser.RacesInUse["e"] == nil then
		return "e";
	elseif PortalUser.RacesInUse["f"] == nil then
		return "f";
	elseif PortalUser.RacesInUse["i"] == nil then
		return "i";
	else
		return "c"; -- default to cerberi
	end
end


return _PortalUser;