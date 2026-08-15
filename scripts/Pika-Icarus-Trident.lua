-- Change weapon if surrounding targets more than X
------------
TimeToStun	=	3	--sek
FightTime	=	10	--sek
MonToStun	=	5	-- min surrounding mobs
------------
Demitelum	=	15889
Trident		=	10450
Mamba		=	16157	 -- Mamba Edge Dual Daggers {PvP}


function CurrentWeaponID()	
	local invList = GetInventory();
	local result = nil;
	local me = GetMe();
	local CurrentWeapon	=	nil;
	
	for item in invList.list do
		--ShowToClient("#", item.Name .." [".. item.displayId .. "]" ); --.. " type= " .. tostring(item.Weapontype())); --Weapontype
		-- Find weapom 
		if ( item.IsEquipped and (item.displayId == Demitelum or item.displayId == Mamba) )then	-- Demitelum
			ShowToClient("#", " Equipped weapon: " .. item.Name .." [".. item.displayId .. "]");
			CurrentWeapon = item.displayId;	-- отримуємо ІД вдягненої зброї	
		else
			if (item.displayId == Trident) then	-- Icarus Trident
			ShowToClient("#", "Second weapon " .. item.Name .." [".. item.displayId .. "]");
			result = item.displayId;	-- отримуємо ІД, який співпав із заданою зброєю	KastetID
			end;
		end;
	end;
	if ( CurrentWeapon == nil and  result ~= nil ) then -- false == nill?
		ShowToClient("#", " No any weapon equiped, we can use this: " .. result);
	elseif ( CurrentWeapon == nil and  result == nil ) then
		ShowToClient("#", " No any weapon Found :(" );
	else
		result = CurrentWeapon;
	end;
	return result;
end;

function HowManyMobsAround(range)
	--ShowToClient(tostring(os.date("%X")) .. "[hma]", "check KillMons...", 20);
	local monsterlist = GetMonsterList();
	local count = 0;
	local corps = 0;
	for mob in monsterlist.list do
		if (mob:GetDistance() < range and not mob:IsAlikeDeath() and mob:IsAttacking()) then
			count = count + 1;
		end;
		if ( mob:IsAlikeDeath() and mob:GetDistance() < range ) then
			if ( mob:IsSpoiled() == true ) then
				corps = corps + 1;
			end
		end
	end;
		if ( count > 10 ) then 
			ShowToClient(tostring(os.date("%X")) .. "mobs around ", "..." .. count, 20);
		end
		
	return count;
end;

--+ Find and equip wepon + Shield - v01
function UseWeapon(WeaponID,ShieldID)
	local NotEquipped = true;
	local me = GetMe();
	round = 1;
	while ( NotEquipped and not (me:IsAlikeDeath()) ) do
		--ShowToClient("#", " Round=" .. round);
		round = round + 1;
		
		local invList = GetInventory();
		
		while ( me:IsBlocked(true) ) do
			ShowToClient("#", " waiting... blocked...")
			Sleep(333)
		end;
		-- add HP check...
		--
		for item in invList.list do	
			if ( WeaponID ~= nil and item.displayId == WeaponID ) then
				if ( not item.IsEquipped ) then 	-- в нас є потрібна зброя, не вдягнена
					--ShowToClient("#", item.Name .. " [ ".. item.displayId .. " ] found. Try to wear...")
					UseItem(WeaponID);
					Sleep(444);
				else
					--ShowToClient("#", item.Name .. " [ ".. item.displayId .. " ] already Equiped.")
					NotEquipped = false;
				end;
			end;
			if ( ShieldID ~= nil and item.displayId == ShieldID ) then
				if ( not item.IsEquipped ) then 	-- в нас є потрібна зброя, не вдягнена
					--ShowToClient("#", item.Name .. " [ ".. item.displayId .. " ] found. Try to wear...")
					UseItem(ShieldID);
					Sleep(444);
				else
					--ShowToClient("#", item.Name .. " [ ".. item.displayId .. " ] already Equiped.")
					NotEquipped = false;
				end;
			end;
		end;
		Sleep(434);
	end;
end;

-- Main --
ShowToClient(tostring(os.date("%X")), "Use Icarus Trident");



while ( GetMe():IsInCombat() ) do
		local CurrentWeapon	= CurrentWeaponID()
		if ( CurrentWeapon and (HowManyMobsAround(300) >= MonToStun ) )  then
			UseWeapon(Trident,0);
			Sleep(TimeToStun*1000);
			UseWeapon(CurrentWeapon,0);
		end
		Sleep(FightTime*1000)
end
