----------------------------------
bonusHat 		= {31015,31014,31013,31012,31011}--,31303,31302,31301};  -- Brave Wolf Hat, Brave Piggy Hat, Brave Chick Hat
LastHatCheck 	= 0
----------------------------------
Rush		= 998	-- Blazing Boost
Sweep		= 42	-- Sweeper
massSweep	= 444	-- SweeperFestival
----------------------------------
IdleCheckTime	=	15		--	in seconds 15-30 sek optimal
MonHPtoBackstab	=	180000	-- if monster has more HP than - step back to use BackStab skill


function RUUToRadiant(x) --0 to 2*pi
return (math.pi/180) * (360/math.pow(2,16)) * x;
end;
 
function RUUToDegrees(x) -- 0 - 360
return 1 * (360/math.pow(2,16)) * x;
end;
 
function GetInvertedBy180AndRange(x, range) --RUU only
	if x ~= nil and x:IsValid() then
		--ShowToClient(tostring(RUUToRadiant(x:GetRotation().Yaw)), tostring(RUUToDegrees(x:GetRotation().Yaw)));
		local Yaw = x:GetRotation().Yaw;
		local loc = x:GetLocation();
		loc.Y = loc.Y - range * math.sin( Yaw * (math.pi / 32768) ) ;--you need round here
		loc.X = loc.X - range * math.cos( Yaw * (math.pi / 32768) ) ;--you need round here
		return loc;
	end;
return FVector(0,0,0);
end;
 
 
function GetInvertedBy180AndRange2(x, range) --Radians only
	if x ~= nil and x:IsValid() then
		--ShowToClient(tostring(RUUToRadiant(x:GetRotation().Yaw)), tostring(RUUToDegrees(x:GetRotation().Yaw)));
		local Yaw = RUUToRadiant(x:GetRotation().Yaw) + math.pi;
		local loc = x:GetLocation();
		loc.Y = loc.Y + range * math.sin( Yaw ) ;--you need round here
		loc.X = loc.X + range * math.cos( Yaw ) ;--you need round here
		return loc;
	end;
return FVector(0,0,0);
end;

function ClearT()
	ClearTargets();
	CancelTarget(false);
	Sleep(123);
	ClearTargets();
end

function BonusHatOn()
	local HatOn = false;
	local invList = GetInventory();
		for item in invList.list do
			for Hat = 1, #bonusHat do 
					if ( item.IsEquipped and ( item.displayId == bonusHat[Hat]))then
						HatOn = true;
						LastHatCheck = GetTime()	
						--ShowToClient(os.date("%X"),  "Equipped: " .. item.Name .." [".. item.displayId .. "]", 20);
					else
						if ( item.displayId == bonusHat[Hat] and not HatOn )then
							UseItem(bonusHat[Hat]);
							HatOn = true;
							LastHatCheck = GetTime()	
							ShowToClient(os.date("%X"), "Try to Wear Hat: " .. item.Name .." [".. item.displayId .. "]", 20);
							--Sleep(5547);
						end;
					end;
					--ShowToClient(os.date("%X"), "HatOn: " .. tostring(HatOn), 20);
					--Sleep(547);
					if ( HatOn ) then
						break;
					end
			end
		end;
	return 0;
end

function UseSkillH(skill)
local UseSkill = GetSkills():FindById(skill);
--ShowToClient(tostring(os.date("%X")) .. "[useSkill]", "skill: " .. tostring(UseSkill.name), 20);
	if (UseSkill ~= nil) and (UseSkill:CanBeUsed() and not GetMe():IsBlocked(true)) then		
			UseSkillRaw(skill, false, false);
			Sleep(300);
	--else
		--ShowToClient(tostring(os.date("%X")) .. "#", UseSkill.name ..  " - Can't Be Used", 20);
	end;

end;


function KillMons(range)
	--ShowToClient(tostring(os.date("%X")) .. "[KM]", "Start KillMons ...", 20);
	while HowManyMobsAround(range) >= 1 do 
			--ShowToClient(tostring(os.date("%X")) .. "[KM]", "after MHA KillMons ...", 20);
			Mobs = GetTarget()
			if (  Mobs ~= nil ) then
				if ( Mobs:IsAlikeDeath() )  then	-- 1% HP щоб переключитись на сусіднього моба
					if (  Mobs:IsSpoiled() ) then
						--ShowToClient(tostring(os.date("%X")) .. "[KM]", "Mobs:IsAlikeDeath and spoilled", 20);
						UseSkillH(Sweep);
					else
						--ShowToClient(tostring(os.date("%X")) .. "[KM]", "Mobs:IsAlikeDeath and NOT spoilled, clearTarget", 20);
						ClearT();
					end
				else
				if ( Mobs:GetHp() > MonHPtoBackstab  ) then --or  Mobs:GetName() == "Treasure Chest"
					ShowToClient(os.date("%X"), "Move back, 7s", 20);
					MoveToNoWait(GetInvertedBy180AndRange2(Mobs , 80));
					Sleep(7000);
				else
					--ShowToClient(os.date("%X"), "Mobs:GetHp() " .. tostring(Mobs:GetHp()), 20);
					Sleep(3000);
				end
				end;
			end;
			Sleep(435);
	end;
	--ShowToClient(tostring(os.date("%X")) .. "[KM]", "Stoping KillMons...", 20);
end



function HowManyMobsAround(range)
	--ShowToClient(tostring(os.date("%X")) .. "[hma]", "check KillMons...", 20);
	local monsterlist = GetMonsterList();
	local count = 0;
	local corps = 0;
	for mob in monsterlist.list do
		if (mob:GetDistance() < range and not mob:IsAlikeDeath() and mob:IsAttacking()) then
			count = count + 1;
		end;
		if ( mob:IsAlikeDeath() and mob:GetDistance() < range/2 ) then -- mass sweep has range 200-300
			if ( mob:IsSpoiled() == true ) then
				corps = corps + 1;
			end
		end
	end;
		if ( count > 15 ) then 
			ShowToClient(tostring(os.date("%X")) .. " mobs around ", "..." .. count, 20);
		end
		if ( corps >= 1 ) then 
			--Command("/useshortcut 2 2"); --mass sweep
			UseSkillH(massSweep);
		elseif ( count == 0 and corps >= 1 ) then
			--Command("/useshortcut 2 2"); --mass sweep
			UseSkillH(massSweep);
			--ShowToClient(tostring(os.date("%X")) .. "[hma]", "sweep last dead mob ", 20);
		end
		
	return count;
end;

function FixTarget()
	--ShowToClient(tostring(os.date("%X")) .. "[FT]", "Clear all ", 20);
	MyTarget = GetTarget();
		if ( MyTarget ~= nil ) then
			--Rush
			if ( (MyTarget:IsMonster()) and not (MyTarget:IsAlikeDeath()) ) then
				if ( MyTarget:GetDistance() >= 250 ) then 
					UseSkillH(Rush);
				--else
					--noop нехай Tower сам працює
				end
			end;
			--Ress
			if ( not MyTarget:IsAlikeDeath() and MyTarget:IsPlayer() and MyTarget:IsMyPartyMember() ) then
				ClearT();
			elseif ( MyTarget:IsAlikeDeath() and MyTarget:IsPlayer() and MyTarget:IsMyPartyMember() ) then
				ShowToClient(tostring(os.date("%X")) .. "[FT]", "Try to Ress? ", 20);
				UseItem(3936); -- Blessed Scroll of Resurrection
			end;
		end;
end;

function moveToNext(targetUser)
	local locTMP = 0
	--ShowToClient(os.date("%X"), "Life-hack = try to move somewhere", 20);
	locTMP = targetUser:GetLocation()
	local  choise = math.random(1,10)
	if (choise < 5) then
		if (choise <= 3) then
			MoveToNoWait(locTMP.X + math.random(25,50), locTMP.Y + math.random(25,50), locTMP.Z);
		else
			MoveToNoWait(locTMP.X + math.random(25,50), locTMP.Y - math.random(25,50), locTMP.Z);
		end
	else
		if (choise <= 8) then
			MoveToNoWait(locTMP.X - math.random(25,50), locTMP.Y - math.random(25,50), locTMP.Z);
		else
			MoveToNoWait(locTMP.X - math.random(25,50), locTMP.Y + math.random(25,50), locTMP.Z);
		end
	end
	Sleep(310)
end

function WeinParty()
	local NearesMember		= nil;
	local PartyList			= GetPartyList();
	local partyCounter		= 0;
	local NearMemberDist	= 0;
	local MembersRange		= 1500;
	
	for member in PartyList.list do
		local MemberDist = member:GetDistance()
		if ( not member:IsAlikeDeath() ) and ( MemberDist < MembersRange ) then
			--We in party, Alive member near
			if (NearMemberDist == 0) then
					--ShowToClient(os.date("%X"), "First Member dist: " .. tostring(MemberDist), 20);
					NearMemberDist = MemberDist
					NearesMember = member
			else
				--ShowToClient(os.date("%X"), "HMA.Find nearest Member", 20);
				if ( MemberDist < NearMemberDist) then
					--ShowToClient(os.date("%X"), "Nearest Member dist: " .. tostring( Member:GetDistance()), 20);
					--ShowToClient(os.date("%X"), "Member lvl: " .. tostring( Member:GetLevel()), 20);
					NearMemberDist = MemberDist
					NearesMember = member
				--else
				--ShowToClient(os.date("%X"), "HMA. " .. tostring(Member:GetName()) .. "dist > First. [" .. MemberDist .. "]", 20);
				end
			end			
		end;
	end;
	
	return NearesMember;
end;

function CheckIdle()
			if ( GetTime() - lastLocCheck > IdleCheckTime*1000 ) then
				lastLocCheck = GetTime()
				--ShowToClient(os.date("%X"), "check IDLE", 20);
				-------------
				MasterUser = WeinParty();
				if ( MasterUser ~= nil ) then
					-- go to nearest party member
					--ShowToClient(os.date("%X"), "MasterUser: " .. MasterUser:GetName(), 20); 
				else
					-- make some moves around my position
					MasterUser = GetMe();
				end
				-------------
				if ( not GetMe():IsInCombat() or not GetMe():IsAttacking() ) then
					if ( GetMe():GetRangeTo(MasterUser) > 300 ) then
						--ShowToClient(os.date("%X"), "Stop farm. Move to PartyMember " .. (tostring(GetMe():GetRangeTo(MasterUser))), 20);	
						moveToNext(MasterUser)
						ShowTrace( MasterUser:GetLocation() )
						--------------	
					else
						ShowTrace( MasterUser:GetLocation() )
						Sleep (5000 + math.random(100,5000));	-- чекаємо 0.6-1.2сек і повторно перевіряємо
						moveToNext(MasterUser)	--try to move somewhere
						--lastChangeTime = GetTime()  -- Update timestamp on movement
						--ShowToClient(os.date("%X"), "Farming. Update timestamp. Dist: " .. (tostring(GetMe():GetRangeTo(lastX, lastY, lastZ))), 20);
					end
				--else --in combat but no mons or not atacking
					--noop
				end
				--locTMP = GetMe():GetLocation()
				--lastX, lastY, lastZ  = locTMP.X, locTMP.Y , locTMP.Z
				-- Check if idle for 45s and not fighting
				-- if (GetTime() - lastChangeTime >= idleTime) and (not GetMe():IsInCombat()) then
					-- ShowToClient(os.date("%X"), "No movement for " .. (idleTime/1000) .."s and not in combat.",20);
					-- --ReBuff();
					-- Sleep(545);  -- Prevent immediate re-trigger
				-- --else
					-- --ShowToClient(os.date("%X"), "Moving during last  25s, deltaTime: " .. (tostring(GetTime() - lastChangeTime)), 20);
				-- end
			end

end;
---------------------------------------------------------------------
--- MAIN ---
ShowToClient(os.date("%X"), "Start [Spoil]",20);
----------------------------------
local msgCounter = 	0	-- counter to send msg only for 1 time
lastLocCheck	=	0	-- default start time, always 0
lastChangeTime	=	0	-- default start time, always 0
----------------------------------

	while ( true ) do
		while ( GetMe():IsAlikeDeath() or IsPaused() or GetZoneType() ~= L2ZoneType.GENERAL ) do
			if ( msgCounter < 1 ) then
				if ( not IsPaused() ) then
					ShowToClient(os.date("%X"), "Wait for Ressurection");
				else
					ShowToClient(os.date("%X"), "Wait to bee ON", 20);
				end
				msgCounter = msgCounter + 1
			end
			Sleep (4500 + math.random(150,1505));	-- чекаємо 4-6сек і повторно перевіряємо
		end
		msgCounter = 0
		if ( GetTime() - LastHatCheck > 60*1000 ) then
			BonusHatOn() -- Check bonus Hat every minute
		end
		CheckIdle();
		FixTarget()
		KillMons(500);
		Sleep (600 + math.random(150,605));	-- чекаємо 0.6-1.2сек і повторно перевіряємо
	end

ShowToClient(os.date("%X"), "We in town...stop all", 20);
SetPause(true);