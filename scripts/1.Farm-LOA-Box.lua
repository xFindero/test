----------------------------------
-- Script for Hunting RB near Nornil Cave 
----------------------------------
debug			= true
NxtTrgtDelay	=	10		-- in sec
NxtTrgtHP		=	70		-- in %
LastNxtTrgt		=	0		-- time when it used for last time
FightRange		=	1000		-- range to find monsters
lastChangeTime	=	0
idleTime		=	45		-- in min (inactivity time, go to rest point)
SleepTimeFrom	=	15		-- in min (rest tim from x min to xx min)
SleepTimeTo		=	25		-- in min (rest tim from x min to xx min)
returnPvPDelay	=	35		-- in munites, delay to keep in safe
weArePL			=	false
stopFarm		=	false
----------------------------------
-- ====================== НАЛАШТУВАННЯ ======================
SpoilInterval   = 14
MoveInterval	= 25
LastCheckTime   = 0
SweepRange		= 400
massSweep		= 444	-- SweeperFestival 
SpoilBomb		= 537	-- Spoil Bomb
SpoilFestival	= 302	-- Spoil Festival
-- ====================== НАЛАШТУВАННЯ ======================
bonusHat 		=	{31303, 31302 ,31301};  -- Brave Wolf Hat, Brave Piggy Hat, Brave Chick Hat
----------------------------------
keyName = "Maestro's Key" 
keyID = nil          --initial parametrs, will be set in HasKey func.
keyCount = 0         --initial parametrs, will be set in HasKey func.
noKeysLeft = false   --initial parametrs to avoid check invertory for keys at every start Targeting function
----------------------------------
RushSkills 		=	{628, 998, 6292, 6296, 484, 994}  -- Warp-628, 998 - Blazing Boost, 484, 6292, 6296 - Rush, 994 Rush WLs
Rush 			=	nil
RushDist 		=	550
----------------------------------
--- Alt+B Heal
HealLastUsed       = 0
HealCooldown       = 60000          
HealHpPercent      = 90
HealMpPercent      = 80
HealCpPercent      = 90
----------------------------------
blackList			=	{"Bloodthirsty Punisher", "Pain Hunter", "Tortured Sinner", "Death Hound", "Merciless Punisher", "Maluk Sniper"}
highPriorityList	=	{"Treasure Chest"}
lowPriorityList 	=	{"Treasure Box"}
----------------------------------
buffID = {1499, 1500, 1502, 1504}
-- 1499	Improved Combat
-- 1500	Improved Magic
-- 1502	Improved Critical Attack
-- 1504	Improved Movement
buffMagID =  {1357, 1500, 1501}
-- 1357	Prophecy of Wind
-- 1363	Chant of Victory
-- 1413	Magnus' Chant
-- 1500	Improved Magic
-- 1501	Improved Condition
----------------------------------
CheckSoundDC = GetDir() .. "\\sound\\found.wav";


function Sound()
	local result = false;
	if ( PlaySound(CheckSoundDC)) then
		--ShowToClient("#", "Succes!")
		result = true;
	else
		ShowToClient("#", "Fail to play sound!")
	end
	return result
end

function GotoSpot(spotX,spotY,spotZ, dist)

		local startMoveTime = GetTime()
		local startLoc		= GetMe():GetLocation()
		local delta			= 50
		
		ShowTrace(FVector(spotX, spotY, spotZ));
		if debug then ShowToClient(os.date("%X"), "spotX " .. spotX,20) end
		MoveToNoWait(spotX, spotY, spotZ)
		Sleep(1500)
		checkAlive()
		contrKill()
		if ( GetMe():GetRangeTo(spotX, spotY, spotZ) >= dist )	then
			if ( GetMe():IsBlocked(true) ) then
				if IsPaused() then
					if debug then ShowToClient(os.date("%X"), "try to fight for 5sec",20) end
					SetPause(false)
					Sleep(5000)
					SetPause(false)
				end
			else
				if ( GetMe():GetRangeTo(startLoc.X,startLoc.Y,startLoc.Z) <= 200 )	then
					if debug then ShowToClient(os.date("%X"), "unstuck step: " .. 300,20); end
					local tx = GetMe():GetLocation().X + math.random(-300, 300)
					local ty = GetMe():GetLocation().Y + math.random(-330, 300)
					ShowTrace(FVector(tx, ty, GetMe():GetLocation().Z));
					MoveToNoWait(tx, ty, GetMe():GetLocation().Z)
					Sleep(1500)
					MoveTo(spotX+ math.random(-delta, delta), spotY+ math.random(-delta, delta), spotZ,dist)
				else
					MoveTo(spotX+ math.random(-delta, delta), spotY+ math.random(-delta, delta), spotZ,dist)
				end
			end
		end
end;

function ClearT()
	ClearTargets();
	CancelTarget(true);
	Sleep(123);
	ClearTargets();
end

function SweepDrop(range)
	local monsterlist = GetMonsterList();
	local count = 0;
	local corps = 0;
	for mob in monsterlist.list do
		if (mob:GetDistance() < range) then
			if ( mob:IsAlikeDeath() and mob:IsSpoiled() ) then -- mass sweep has range 200-300
				corps = corps + 1
			else
				count = count + 1;
			end;
		end;
	end;
	if ( count > 15 ) then 
		ShowToClient(os.date("%X") .. " mobs around ", "..." .. count, 20);
	end
	if ( corps >= 1 ) then 
		UseSkillH(massSweep)
		Command("/attack")
	end
	return 0
end;

function ClickAndWait(link,name)
	QuestReply(link);
	Sleep(1421)
end;

function contrKill()
	myHP = GetMe():GetHpPercent();
	--ShowToClient(os.date("%X"), "Check contrKill.",20);
	if ( myHP < 95 and  myHP > 0 ) then
		--ShowToClient(os.date("%X"), "Start contrKill.",20);
		if debug then ShowToClient("#", "GoToSpot. HP: " .. math.floor(myHP), 20); end
		KillMons()
	end
	return 0
end

function checkRushSkill(Skills)
	local Rush
	for Skill = 1, #Skills do
		local UseSkill = GetSkills():FindById(Skills[Skill]);
			if (UseSkill ~= nil) then		
				Rush = Skills[Skill]
				--ShowToClient(os.date("%X"), "Skill " .. Skills[Skill] .. " will be used", 20);
			--else
				--ShowToClient(os.date("%X"), "Skill " .. Skills[Skill] .. " not found", 20);
			end;
	end;
	return Rush
end;

function UseSkillH(skill)
	if ( skill ~= nil ) then
		local UseSkill = GetSkills():FindById(skill);
		if (UseSkill ~= nil) and (UseSkill:CanBeUsed()) then		
				UseSkillRaw(skill, false, false);
				Command("/useshortcut 1 4");
				Sleep(200);
				Command("/useshortcut 1 4");
		else
			if (UseSkill == nil) then
				ShowToClient(os.date("%X"), "Skill " .. skill .. " not found", 20);
			end
		end;
	else
		ShowToClient(os.date("%X"), "Skill " .. tostring(skill) .. " is nil", 20);
	end

end;

function UseKey()
	--Sound()
    if keyID == nil then
		ShowToClient(os.date("%X"), "UseKey. Id is nil", 20);
		return false
	--else
		--ShowToClient(os.date("%X"), "UseKey. Keys left " .. keyCount, 20);
	end
		
	if GetTarget() then
		UseItem(keyID)
		keyCount = (keyCount - 1)
		return true
	else
		ShowToClient("UseKey", "No target to use a Key", 20);
	end
    return false
end

-- ====================== CORE TARGET FINDER (unified) ======================

function GetNearestByPriority(range, priorityType)
    local monsterlist = GetMonsterList()
    if not monsterlist or monsterlist:GetCount() == 0 then
        return nil
    end
	
    local prioList = nil
    if priorityType == "high" then
        prioList = highPriorityList
    elseif priorityType == "low" then
        prioList = lowPriorityList
    elseif priorityType == "general" then
        prioList = nil   -- general = no name priority list
    else
        ShowToClient(os.date("%X"), "Invalid priorityType: " .. tostring(priorityType), 20)
        return nil
    end

    local nearestMob = nil
    local nearestDist = 999999

    for mob in monsterlist.list do
        local mobDist = mob:GetDistance()
        if mobDist >= range then
			goto continue
		end
        -- 1. Blacklist (applies to ALL priorities)
        local isBlacklisted = false
        for i = 1, #blackList do
            if string.find(mob:GetName(), blackList[i]) then
				--ShowToClient(os.date("%X"), mob:GetName() .. " [" .. mob:GetDistance() .. "] Blaclisted!" , 20)
                mob:SetBlock(true)
                isBlacklisted = true
                break
            end
        end
        
		if isBlacklisted then goto continue end

        -- 2. Priority name match (skip for "general")
        local matchesPriority = (priorityType == "general")
        if prioList then
            for i = 1, #prioList do
                if string.find(mob:GetName(), prioList[i]) then
                    matchesPriority = true
                    break
                end
            end
        end
        if not matchesPriority then
			goto continue	
		end

        -- 4. Alive & not blocked
        if mob:IsAlikeDeath() then
			goto continue
		end
		
		if mob:IsBlock() and priorityType ~= "high" then
			goto continue
		end

        -- Candidate → check distance
        if mobDist < nearestDist then
            nearestDist = mobDist
            nearestMob = mob
        end

        ::continue::
    end
    return nearestMob
end


-- ====================== LOW PRIORITY SPECIAL HANDLING ======================
-- (unchanged from previous version – only using the new unified finder)

function HandleLowPriorityChest(lowMob)
    local dist = lowMob:GetDistance()
	
    if dist > 200 then
        local tx = lowMob:GetLocation().X + math.random(-60, 60)
        local ty = lowMob:GetLocation().Y + math.random(-60, 60)
        MoveToNoWait(tx, ty, lowMob:GetLocation().Z)
        Sleep(2200)
    end

    ClearT()
    Sleep(300)

    -- Find nearest attacking monster (within ~200)
	--ShowToClient(os.date("%X"), "Find nearest attacking monster" , 20)
    local attacker = nil
    local attackerDist = 999999
    local monsterlist = GetMonsterList()

    for mob in monsterlist.list do
        local d = mob:GetDistance()
        if d >= 200 then goto cont2 end
        if mob:IsAlikeDeath() or mob:IsBlock() then goto cont2 end

        if  mob:IsAttacking()  then
            if d < attackerDist then
                attackerDist = d
                attacker = mob
            end
        end
        ::cont2::
    end

    if attacker ~= nil then
        --ShowToClient(os.date("%X"), "Defending vs attacker", 20)
        Target(attacker)
        return
    end

    -- No attackers → open logic
    local hp = GetMe():GetHpPercent()
	--ShowToClient(os.date("%X"), "Check HP before open Box" , 20)
    if hp > 80 then
		local tx = lowMob:GetLocation().X + math.random(-60, 60)
        local ty = lowMob:GetLocation().Y + math.random(-60, 60)
        MoveToNoWait(tx, ty, lowMob:GetLocation().Z)
        Sleep(1000)
        --ShowToClient(os.date("%X"), "Safe - Opening chest", 20)
        SetPause(true)
        Target(lowMob)
        Sleep(400)
        UseKey()           -- assume you have this function from previous version
        Sleep(1500)
        SetPause(false)
        ClearT()
    else
        -- Low HP logic (same as before)
		--ShowToClient(os.date("%X"), "Check HP/ Low HP logic" , 20)
        local hasOtherMobs = false
        for mob in monsterlist.list do
            local d = mob:GetDistance()
            if d < 200 and not mob:IsAlikeDeath() and not mob:IsBlock() then
                local isLow = false
                for i = 1, #lowPriorityList do
                    if string.find(mob:GetName(), lowPriorityList[i]) then
                        isLow = true
                        break
                    end
                end
                if not isLow then
                    hasOtherMobs = true
                    break
                end
            end
        end

        if not hasOtherMobs then
            --ShowToClient(os.date("%X"), "Low HP but safe - Opening", 20)
            SetPause(true)
            Target(lowMob)
            Sleep(400)
            UseKey()
            Sleep(1500)
            SetPause(false)
            ClearT()
        else
            --ShowToClient(os.date("%X"), "Low HP + mobs - Fight general first", 20)
            local gen = GetNearestByPriority(200, "general")
            if gen then Target(gen) end
        end
    end
end


-- ====================== MAIN TARGET FUNCTION ======================
function TargetPriority(range)
    -- 1. HIGH priority first
	--ShowToClient(os.date("%X"), "HIGH priority first", 20)
    local high = GetNearestByPriority(range, "high")
    if high ~= nil then
		--ShowToClient(os.date("%X"), "HIGH mob near: " .. high:GetName() )
        ApproachAndTarget(high, range)
        return
    end

    -- 2. LOW priority (only if we have key)
	if HasKey() then
        local low = GetNearestByPriority(range*2, "low")
        if low ~= nil then
            HandleLowPriorityChest(low)
            return
        end
	else
		ShowToClient(os.date("%X"), "We have no key)", 20)
    end

    -- 3. GENERAL fallback
	if ( (GetMe():IsMyPartyMemberMaster() or weArePL ) and not stopFarm) then
		local general = GetNearestByPriority(range, "general")
		if general == nil then
			--ShowToClient(os.date("%X"), "No valid targets - move To Spot!", 20)
			--moveToNext()		-- to farm spot
			Sleep(3400)
			return
		end
		ApproachAndTarget(general, range)
	end
end

-- ====================== HELPER FUNCTIONS ======================

function HasKey()
	--ShowToClient(os.date("%X"), "noKeysLeft: " .. tostring(noKeysLeft), 20)
	if noKeysLeft then return false end
--- перевірка глобальної змінної і стану ключів щоб не робити ліст сумки щоразу
	if ( keyID ~= nil and keyCount > 0 ) then
		--ShowToClient(os.date("%X"), "HasKey. " .. keyCount .. " keys left", 20);
		return true
	else
		--ShowToClient("HasKey", "var KeyID ~ nil or num ~ 0 ", 20);
		local invList = GetInventory()
		if not invList then
			ShowToClient("HasKey", "GetInventory failed", 20);
			return false
		--else
			--ShowToClient("HasKey", "GetInventory success", 20);
		end

		for item in invList.list do
			if item.Name == keyName and item.ItemNum > 0 then
				--ShowToClient(os.date("%X"), "Keys: " .. item.Name .. " DisplayId: " .. item.displayId .. " Num: " .. item.ItemNum, 20);
				ShowToClient(os.date("%X"), "Keys: " .. item.Name .. " Num: " .. item.ItemNum, 20);
				keyID = item.displayId		-- save keys id info in global env
				keyCount = item.ItemNum
				return true
			else
				--ShowToClient(os.date("%X"), "Keys not found");
				--Sound();
			end
			--else if not found
		end
		noKeysLeft = true
	end
	ShowToClient(os.date("%X"), "HasKey. Keys not found", 20);
    return false
end

-- ====================== HELPER: Mistarget approach & target ======================
function ApproachAndTarget(mob, maxRange)
    if not mob then return end

    local dist = mob:GetDistance()
    local offsetX, offsetY, sleepAfter = 0, 0, 0

    if dist <= 200 then
        offsetX = math.random(10, 30)
        offsetY = math.random(5, 20)
        sleepAfter = 100
    elseif dist <= 400 then
        offsetX = math.random(30, 90)
        offsetY = math.random(50, 100)
        sleepAfter = 250
    else
        offsetX = math.random(150, 250)
        offsetY = math.random(50, 150)
        sleepAfter = 1300
    end

    local tx = mob:GetLocation().X + offsetX
    local ty = mob:GetLocation().Y + offsetY
    local tz = mob:GetLocation().Z

    MoveToNoWait(tx, ty, tz)
    Sleep(sleepAfter)

    Target(mob)
    Sleep(250)

    local target = GetTarget()
    if target == nil then
        --moveToNext()
		Sleep(1200)
        return
    end

    -- HP life-hack
    local me = GetMe()
    if me:GetHpPercent() <= NxtTrgtHP and (GetTime() - LastNxtTrgt or 0) > (NxtTrgtDelay * 1000) then
        LastNxtTrgt = GetTime()
        if debug then ShowToClient(os.date("%X"), "Low HP - next target", 20) end
        Command("/useshortcut 1 1")
    end

    Sleep(400)
end
-----------------

function moveToNext()
-- Approach with random offset (anti-detection / geometry trick)
    local offsetX, offsetY = 0, 0

    offsetX = math.random(-250, 250)
    offsetY = math.random(-250, 250)

	--GotoSpot(148722, 111951, -3705, moveDistance); spot
    local tx = 147355 + offsetX
    local ty = 111971 + offsetY
    local tz = -3720
	
	--ShowToClient(os.date("%X"), "Life-hack = try to move somewhere", 20);
    MoveToNoWait(tx, ty, tz)
	Sleep(1210)
end

function toSafePlace()
	local moveDistance	=	100
	SetPause(true);
	if 	( GetMe():GetRangeTo(147355, 111971, -3720) < 1000 ) then		--на точці в ЛОА
		if debug then ShowToClient(os.date("%X"), "At farm point", 20); end
		GotoSpot(146760, 111764, -3558, moveDistance);
		GotoSpot(146641, 111631, -3541, moveDistance);
		GotoSpot(146140, 111220, -3567, moveDistance);
		Sleep(2000)
		KillMons()
		Sleep(7000)
		KillMons()
	else
		if debug then ShowToClient(os.date("%X"), "Unknown place, SOE in 10 sec", 20); end
		Sleep(10000)
		Sound()
		ProcessCommand("/scriptStart Go-Loa-DeepInside.lua")
		Sleep(2000)
		KillMons()
		Sleep(7000)
		KillMons()
		deltaMove()
	end	
end

function GoLoaBridge()
if debug then ShowToClient(os.date("%X"), "GoLoaBridge()") end
local moveDistance	= 80;

	if 	( GetMe():GetRangeTo(117240, 76802, -2695) < 1000 ) then		--Біля ТП Хантер
			if debug then ShowToClient(os.date("%X"), "In Hunter near TP", 20); end
			MoveTo(116977, 76821, -2704, moveDistance)
			tpThrouSoul()

	else
		ClickAndWait("_bbshome", "");
		ClickAndWait("voice .teleporterservice h scl", "");
		ClickAndWait("voice .teleporterservice h sl STC_TOWN_AREAS", "");
		ClickAndWait("voice .teleporterservice t s S_HUNTERS STC_TOWN_AREAS", "");
		while GetMe():GetRangeTo(117240, 76802, -2695) > 1000 do	--wait for tp to Hunter
			Sleep(2500)
			if debug then ShowToClient(os.date("%X"), "Wait for tp to Hunter", 20); end
		end
		if tpThrouSoul() then
			if debug then ShowToClient(os.date("%X"), "in GoLoaBridge - tpThrouSoul successful"); end
		end
	end
	ClearT()
end

function FromBridgeToSpot()
	if debug then ShowToClient(os.date("%X"), "FromBridgeToSpot()"); end
	local moveDistance	=	100
	MoveTo(146185, 111288, -3570, moveDistance);
	MoveTo(146649, 111625, -3540, moveDistance);
	MoveTo(147229, 111977, -3720, moveDistance);
	MoveTo(147996, 112013, -3720, moveDistance);
	MoveTo(148591, 112211, -3717, moveDistance);
	MoveTo(149017, 113122, -3720, moveDistance);
	MoveTo(149237, 113946, -3720, moveDistance);
	MoveTo(149367, 115146, -3720, moveDistance);
	MoveTo(149456, 115712, -3699, moveDistance);
	MoveTo(149700, 116195, -3701, moveDistance);	-- з кола на місточок до Серця
	GotoSpot(149932, 116537, -3701, moveDistance);
	GotoSpot(150217, 117070, -3695, moveDistance);
	GotoSpot(150669, 117863, -3690, moveDistance);
	GotoSpot(150998, 118130, -3721, moveDistance);
	GotoSpot(151563, 118464, -3894, moveDistance);
	GotoSpot(151749, 118786, -3866, moveDistance);
	GotoSpot(151967, 118943, -3811, moveDistance);
	GotoSpot(152440, 119314, -3788, moveDistance);
	GotoSpot(152579, 119524, -3787, moveDistance);
	if debug then ShowToClient(os.date("%X"), "FromBridgeToSpot() finished"); end
end

function tpThrouSoul()
	local teleported = false
	local timeout = GetTime() + 30000
	MoveTo(117240, 76802, -2695, 80);
	TargetNpc("Separated Soul", 32864);
	Talk();
	ClickAndWait("Quest SeparatedSoul 5", "Antharas' Lair -  Magic Force Field Bridge");
	while GetMe():GetRangeTo(146134, 111227, -3568) > 1000 and GetTime() < timeout do
		Sleep(2500)
	end
	if GetMe():GetRangeTo(146134, 111227, -3568) < 1000 then
		teleported = true
	else
		SetPause(true);
		if debug then ShowToClient(os.date("%X"), "We can't teleport") end
	end
	return teleported
end

function deltaMove()
	--ShowToClient(os.date("%X"), "Delta step...",20);
	local tx = GetMe():GetLocation().X + math.random(-30, 30)+ ((string.sub(MyID,-2))/2)
	local ty = GetMe():GetLocation().Y + math.random(-30, 30)
	MoveToNoWait(tx, ty, GetMe():GetLocation().Z);
end

function moveToStart()
	if debug then ShowToClient(os.date("%X"), "moveToStart") end
	SetPause(true);
	local moveDistance	=	100
	
	if 	( GetMe():GetRangeTo(152579, 119524, -3787) < 1500 ) then		--на точці фарму в ЛОА
		if debug then ShowToClient(os.date("%X"), "At Farm spot (Not far from Heart)", 20) end
		GotoSpot(152579, 119524, -3787, moveDistance)
		deltaMove()
	elseif ( GetMe():GetRangeTo(146134, 111227, -3568) < 1000 ) then	-- На мосту в ЛОА
		if debug then ShowToClient(os.date("%X"), "At Bridge LOA") end
		FromBridgeToSpot()
	elseif ( GetMe():GetRangeTo(151912, 121218, -3808) < 1500 ) then	-- На за мостом в глиб тунелю біля ящика
		if debug then ShowToClient(os.date("%X"), "At spot, close to Heart") end
		deltaMove()
	else
		if debug then ShowToClient(os.date("%X"), "Unknown place, teleport to Hunter", 20) end
		Sound()
		GoLoaBridge()
		if debug then ShowToClient(os.date("%X"), "GoLoaBridge finished") end
		FromBridgeToSpot()
	end
	ClearT()
	SetPause(false);
	if debug then ShowToClient(os.date("%X"), "moveToStart finished, ON"); end
end;

function KillMons()
	local stopDefence = false
	
	ClearT()
	
	while not stopDefence do
	    local attacker = nil
		local attackerDist = 999999
		local monsterlist = GetMonsterList()
		
		--ShowToClient(os.date("%X"), "Find attacker" , 20)
		for mob in monsterlist.list do
			local d = mob:GetDistance()
			if d >= 300 or mob:IsAlikeDeath() or mob:IsBlock() then goto cont2 end
			if  mob:IsAttacking()  then
				--ShowToClient(os.date("%X"), "monster " .. mob:GetName() .. " [".. mob:GetDistance() .."] Is attacking: " .. tostring(mob:IsAttacking()), 20)
				if d < attackerDist then
					attackerDist = d
					attacker = mob
				end
			end
			::cont2::
			--ShowToClient(os.date("%X"), "No monsters near" , 20)
		end

		if attacker ~= nil then
			--ShowToClient(os.date("%X"), "Defending vs attacker: " .. attacker:GetName(), 20)
			Target(attacker)
			SetPause(false);
			--ShowToClient(os.date("%X"), "ON - KillMons");
		else
			--ShowToClient(os.date("%X"), "not need to defend. no Agro mobs near" , 20)
			stopDefence = true
		end
		Sleep(500)
	end
	--ShowToClient(os.date("%X"), "All agro monsters cleared" , 20)
	SetPause(true)
	SweepDrop(SweepRange)
	--ShowToClient(os.date("%X"), "OFF");
end

function checkIdle(startTime)
	local result = false
	if (GetTime() - startTime >= idleTime*60000) then
		if debug then ShowToClient(os.date("%X"), "Time to finish. Go to Safe place",20) end
		stopFarm	=	true
		if (not GetMe():IsInCombat()) then
			ShowToClient(os.date("%X"), "Go to Safe place",20);
			result	= true
		end
		Sleep(545);  -- Prevent immediate re-trigger
	end
	return result
end

function CheckMovement()
    local currentTime = GetTime()
	local timeout = stuckTimeout

    -- Перевіряємо не частіше, ніж раз на movementCheckInterval
    if (currentTime - lastLocCheck) < movementCheckInterval then
        return
    end

    lastLocCheck = currentTime

    local me = GetMe()
    if me == nil then return end

    local currX = me:GetLocation().X
    local currY = me:GetLocation().Y
    local currZ = me:GetLocation().Z

    -- Розрахунок дистанції від попередньої позиції
    local distMoved = me:GetRangeTo(lastX, lastY, lastZ)

    -- Оновлюємо позицію для наступної перевірки
    lastX, lastY, lastZ = currX, currY, currZ

    if distMoved < stuckDistance and not me:IsInCombat() then
        -- === Персонаж майже не рухався ===
        --ShowToClient(os.date("%X"), string.format("Not moving! Dist moved: %.0f  - Trying to unstuck", distMoved), 20);
       
        
        -- Додаткова перевірка: якщо довго не рухався — повертаємося на старт
		if not weArePL then
			timeout = 3 * timeout
		end
		
		if weArePL then
			moveToNext()          -- спочатку пробуємо локальний unstuck (якщо є така функція)
		else
			--ShowToClient(os.date("%X"), "Assist to PL " .. (timeout/1000), 20);
			Command("/useshortcut 1 3");
			Sleep(7000)
			ClearT()
			deltaMove()
		end
		
        if (currentTime - lastChangeTime) >= timeout then
 
			ShowToClient(os.date("%X"), "No movement for " .. (timeout/1000) .. " seconds - Returning to farm spot", 20);
			moveToStart();
			Sleep(800);
        end

    else
        lastChangeTime = currentTime
    end
end

function checkAlive()
	CheckPVP()
	if not GetMe():IsAlikeDeath() then 
		return true
	else
		ShowToClient(os.date("%X"), " DIED - Return to farm")
		Sound()

		-------------- pvp / war status
		local pvpNear = false
		playerlist = GetPlayerList()
		if playerlist and playerlist.list then
			for player in playerlist.list do
				local pDist = player:GetDistance()
				if pDist >= 1000 then goto cont3 end
				if player:IsAlikeDeath() then goto cont3 end
				
				if ( (not player:IsMyPartyMember() or not player:IsMyClanMember() or not player:IsMyAllianceMember()) and (player:IsEnemy() or player:GetReputation() < 0 or player:IsClanWar2Side() or player:IsPvPFlag() or player:IsPvPFlagBlink())) then
					pvpNear = true
					ShowToClient(os.date("%X"), "PVP/W or Suspicious player near: " .. player:GetName() .. "Clan: " ..  tostring( player:GetClanName()) .. " [" .. pDist .. "]", 20)
					break
				end
				::cont3::
			end
		end

		if not IsPaused() then
			SetPause(true)
			ShowToClient(os.date("%X"), "OFF - checkAlive");
		end
		local deathTime = GetTime()
		-- Force respawn if still dead
		RequestRestartPoint(2) -- To Village
        Sleep(1000)

		    -- === ВИЗНАЧЕННЯ PvP vs PvE ===
		local me = GetMe()
		local isPvPDeath = (me:GetCpPercent() < 50) or me:IsPvPFlag() or me:IsPvPFlagBlink() or pvpNear
		if isPvPDeath then
			ShowToClient(os.date("%X"), "=== PvP DEATH DETECTED === Stopping all scripts")
			Sound()
			startDelay = (returnPvPDelay*60000 + math.random(-5 * 60000, 15 * 60000));
			ShowToClient(os.date("%X"), "Delay in Farm for " .. math.floor(startDelay/1000) .. " sec")
			Sleep(startDelay)
			
		else
			-- PvE смерть — повертаємося на фарм
			ShowToClient(os.date("%X"), "PvE death - returning to farm spot", 20)
			Sound()
			while ( GetMe():IsInCombat() ) do
				ShowToClient("[Escape] ", " InCombat: ".. tostring(GetMe():IsInCombat()),20);
				Sleep(1432)
			end
		end
		
		while (GetTime() - deathTime < 16000) do	-- чекаємо 15 сек щоб вийти з бою
			Sleep(3000)
		end
		
		-- Force respawn if still dead
		if GetMe():IsAlikeDeath() then
			ShowToClient(os.date("%X"), "!!!! not ressurected for the first time!")
			RequestRestartPoint(2) -- To Village
			Sleep(5000)
		end
		
		ShowToClient(os.date("%X"), "Respawned - Going back to LOA", 20)
		
		if not Rebuff() then
			ShowToClient(os.date("%X"), "Failed to buff", 20)
			stopFarm = true
		else
			ShowToClient(os.date("%X"), "Buff - OK", 20)
			--Sleep(3000 + math.random(0, 1000));   
			moveToStart()
		end
	end
end


function Rebuff()
	--ShowToClient(os.date("%X"), "Rebuff", 20)
    local combatStartTime = GetTime()
    while GetMe():IsInCombat() do
        if (GetTime() - combatStartTime) > 30000 then
            return false
        end
        Sleep(2500)
    end
	-- Quick check first - maybe we already have buffs
    if WeHaveBuff() then
        HealthCheck()
        return true
    end

    -- Buff order: Shortcut first
    Command("/useshortcut 4 5")
    Sleep(7200)
    if WeHaveBuff() then
        HealthCheck()
        return true
    end

    Command(".buffset FFA")
    Sleep(2800)
    if WeHaveBuff() then
        HealthCheck()
        return true
    end

    Command(".buffset FF")
    Sleep(2800)
    
    local result = WeHaveBuff()
    if result then
        HealthCheck()
    else
        ShowToClient(os.date("%X"), "All buff methods failed!", 20)
    end
    return result
end

function WeHaveBuff()
	--ShowToClient(os.date("%X"), "WeHaveBuff in", 20)
    local BUFF_RENEW_SEC = 55
    local me = GetMe()
  
	--ShowToClient(os.date("%X"), "Class " .. me:GetClass(), 20)
	-- 95 Necr, 94 Sorc, 110 SH
    if (me:GetClass() ==  94 or me:GetClass() ==  95 or me:GetClass() ==  110)  then		
		buffID = buffMagID
		--ShowToClient(os.date("%X"), "We are Mag! check Mag buff", 20)
	end
	for i = 1, #buffID do
        local curId = buffID[i]
        if not me:GotBuff(curId) then
            ShowToClient(os.date("%X"), "Missing buff: " .. curId .. " Rebuff!", 20)
            return false
        end
        
        local buff = me:GetBuff(curId)
        if buff then
            local timeLeft = math.floor((buff.endTime - GetTime()) / 1000)
            if timeLeft < BUFF_RENEW_SEC then
                ShowToClient(os.date("%X"), "Buff " .. curId .. " expires soon (" .. timeLeft .. "s)", 20)
                return false
            end
        end
    end
	--ShowToClient(os.date("%X"), "WeHaveBuff out", 20)
    return true
end

function deltaMoveT(target) 	-- move to the front of the target
	local currentTime = GetTime()
    if (currentTime - LastCheckTime) > MoveInterval*1000 then
		LastCheckTime = currentTime
		if target ~= nil and target:IsValid() then
			--if debug then ShowToClient(os.date("%X"), "Random step...",20) end
			local tx = target:GetLocation().X + math.random(-150, 150)
			local ty = target:GetLocation().Y + math.random(-150, 150)
			MoveToNoWait(tx, ty, GetMe():GetLocation().Z);
			--if debug then ShowToClient(os.date("%X"), "Sleep after step", 20); end
			Sleep(1000)
			Command("/attack")
		end
	--else
		--if debug then ShowToClient(os.date("%X"), "No need to move",20); end
	end
end;


function HealthCheck()
	--ShowToClient(os.date("%X"), "HealthCheck in", 20)
    local me = GetMe()
    local timeNow = GetTime()
    local delta = timeNow - HealLastUsed

	--start Boot for 1 second to use potions and recovery scrolls
	SetPause(false)
	Sleep(2000)
	SetPause(true)

    if (me:GetHpPercent() <= HealHpPercent or 
        me:GetMpPercent() <= HealMpPercent or 
        me:GetCpPercent() <= HealCpPercent) 
        and not me:IsInCombat() and delta >= HealCooldown then
        
        ClickAndWait("_bbshome", "")
        ClickAndWait("voice .bufferservice", "")
        ClickAndWait("voice .bufferservice t p h", "")
        HealLastUsed = GetTime()
    end
	--ShowToClient(os.date("%X"), "HealthCheck out", 20)
end

function CheckPVP()
	local me = GetMe()
    local isPvP = (me:GetCpPercent() < 80) or me:IsPvPFlag() or me:IsPvPFlagBlink()
	
	if isPvP then
		ShowToClient(os.date("%X"), "PVP detected - going to safe place", 20);
		EscapePVP();
		SleepTime = returnPvPDelay*60000 + math.random(-math.floor(returnPvPDelay/5), math.floor(returnPvPDelay/5))*60000
		ShowToClient(os.date("%X"), "Farm paused for " .. math.floor((SleepTime/1000)/60) .. " min", 20);
		Sleep(SleepTime);
		moveToStart();
		startTime = GetTime();
	--else
		--if debug then ShowToClient(os.date("%X"), "PVP not detected", 20); end
	end
end

function EscapePVP()
	ShowToClient(os.date("%X"), "Try to Escape using BSOE", 20)
	local bsoe = false;
	local bsoeID = false;
	local invList = GetInventory();
	for item in invList.list do
		if (item.Name == "Blessed Scroll of Escape") then
			bsoe = true;
			bsoeID = item.displayId;
			break;
		end
	end;
	if bsoe then
		ShowToClient(os.date("%X"), "BSOE found - using it", 20)
		UseItem(bsoeID);
	else
		ShowToClient(os.date("%X"), "BSOE not found - try to move to safe place", 20)
		toSafePlace();
	end
	return bsoe;
end
------------------------------------------------------------------------------------
--- MAIN ---
ShowToClient(os.date("%X"), "Start Loa Farm", 20);
ShowToClient(os.date("%X"), "Farm for " .. idleTime .. " min", 20);

LastHatCheck			= GetTime()
-- === Змінні для перевірки руху ===
lastLocCheck			= GetTime()
startTime				= GetTime()
lastChangeTime			= GetTime()
lastX, lastY, lastZ		= 0, 0, 0
movementCheckInterval	= 25 * 1000   -- перевіряти кожні 25 секунд
stuckDistance			= 180             -- якщо змістився менше ніж на цю відстань = застряг
stuckTimeout			= 60 * 1000       -- якщо не рухався 60 секунд і не
MyID					= GetMe():GetId()
Rush					= checkRushSkill(RushSkills);   -- припускаю, що ця функція десь визначена вище
weArePL					= false;
isPausedPreviously		= false   -- змінна для відстеження стану паузи
stopFarm				= false
------------------
if GetMe():IsMyPartyMemberMaster() then
    weArePL = true;
    ShowToClient("#", "We are PL", 20);
end

-- Початкові дії
if GetMe():IsInCombat() then
	ShowToClient("[Escape]", "In Combat on start!", 20);
	KillMons()
else
	Rebuff()
end

moveToStart();                     -- перший раз йдемо на спот

while not stopFarm do
    -- === ОБРОБКА СМЕРТІ ===
    checkAlive()
    -- === ОСНОВНА ЛОГІКА ===
    local currentlyPaused = IsPaused();
    if currentlyPaused then
        if not isPausedPreviously then
            -- Тільки при переході в паузу
            ShowToClient(os.date("%X"), "Script is Paused", 20);
            isPausedPreviously = true;
        end
    else
        if isPausedPreviously then
            -- Тільки при знятті з паузи
            ShowToClient(os.date("%X"), "Farm resumed", 20);
            isPausedPreviously = false;
        end
		CheckMovement()
		CheckPVP()
        -- Основний фарм (виконується тільки коли не на паузі)
		local MyTarget = GetTarget();
        if (MyTarget ~= nil and MyTarget:IsMonster() and not MyTarget:IsAlikeDeath()) then
            if (MyTarget:GetDistance() >= RushDist and Rush ~= nil) then
                UseSkillH(Rush);
            end
        else
            TargetPriority(FightRange);
        end
		deltaMoveT(MyTarget)
		SweepDrop(SweepRange)
    end
	Sleep(5000)
end
	
SetPause(true);
ShowToClient(os.date("%X"), "Final OFF");