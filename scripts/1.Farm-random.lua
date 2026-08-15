----------------------------------
-- Script for Hunting
----------------------------------
NxtTrgtDelay	=	10		-- in sec
NxtTrgtHP		=	70		-- in %
LastNxtTrgt		=	0		-- time when it used for last time
FightRange		=	1000		-- range to find monsters
lastChangeTime	=	0
idleTime		=	45		-- in min (inactivity time, go to rest point)
SleepTimeFrom	=	15		-- in min (rest tim from x min to xx min)
SleepTimeTo		=	25		-- in min (rest tim from x min to xx min)
weArePL			=	false
stopFarm		=	false
----------------------------------
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
-- ====================== GLOBAL SETTINGS ======================
blackList			=	{"Bloodthirsty Punisher", "Pain Hunter", "Tortured Sinner", "Death Hound", "Merciless Punisher"}
highPriorityList	=	{"Elite Dragon Knight", "Dragon Knight","Elite Envoy", "Maluk Princess", "Maluk Hunter"}
lowPriorityList 	=	{"Treasure Chest", "Treasure Box"}
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
		MoveToNoWait(spotX, spotY, spotZ)
		Sleep(2700)
		checkAlive()
		if ( GetMe():GetRangeTo(spotX, spotY, spotZ) >= dist )	then
			if ( GetMe():IsBlocked(true) ) then
				if IsPaused() then
					ShowToClient(tostring(os.date("%X")), "try to fight for 5sec",20)
					SetPause(false)
					Sleep(5000)
					SetPause(false)
				end
			else
				if ( GetMe():GetRangeTo(startLoc.X,startLoc.Y,startLoc.Z) <= 200 )	then
					ShowToClient(tostring(os.date("%X")), "unstuck step: " .. 300,20);
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

function ClickAndWait(link,name)
	QuestReply(link);
	Sleep(1421)
end;

function BonusHatOn()
	local HatOn = false;
	local invList = GetInventory();
		for item in invList.list do
			for Hat = 1, #bonusHat do 
					if ( item.IsEquipped and ( item.displayId == bonusHat[Hat]) )then
						HatOn = true;
						LastHatCheck = GetTime()	
						--ShowToClient("[HatOn]",  "Equipped: " .. item.Name .." [".. item.displayId .. "]", 20);
					else
						if ( item.displayId == bonusHat[Hat] and not HatOn )then
							UseItem(bonusHat[Hat]);
							HatOn = true;
							LastHatCheck = GetTime()	
							ShowToClient("[HatOn]", "Try to Wear Hat: " .. item.Name .." [".. item.displayId .. "]", 20);
							--Sleep(5547);
						end;
					end;
					--ShowToClient("[HatOn]", "HatOn: " .. tostring(HatOn), 20);
					--Sleep(547);
					if ( HatOn ) then
						break;
					end
			end
		end;
	return 0;
end


function checkRushSkill(Skills)
	local Rush
	for Skill = 1, #Skills do
		local UseSkill = GetSkills():FindById(Skills[Skill]);
			if (UseSkill ~= nil) then		
				Rush = Skills[Skill]
				--ShowToClient(tostring(os.date("%X")), "Skill " .. Skills[Skill] .. " will be used", 20);
			--else
				--ShowToClient(tostring(os.date("%X")), "Skill " .. Skills[Skill] .. " not found", 20);
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
				ShowToClient(tostring(os.date("%X")), "Skill " .. skill .. " not found", 20);
			end
		end;
	else
		ShowToClient(tostring(os.date("%X")), "Skill " .. tostring(skill) .. " is nil", 20);
	end

end;

function UseKey()
	--Sound()
    if keyID == nil then
		ShowToClient(tostring(os.date("%X")), "UseKey. Id is nil", 20);
		return false
	--else
		--ShowToClient(tostring(os.date("%X")), "UseKey. Keys left " .. keyCount, 20);
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
        ShowToClient(tostring(os.date("%X")), "Invalid priorityType: " .. tostring(priorityType), 20)
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
				--ShowToClient(tostring(os.date("%X")), mob:GetName() .. " [" .. mob:GetDistance() .. "] Blaclisted!" , 20)
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
	--ShowToClient(tostring(os.date("%X")), "Find nearest attacking monster" , 20)
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
        --ShowToClient(tostring(os.date("%X")), "Defending vs attacker", 20)
        Target(attacker)
        return
    end

    -- No attackers → open logic
    local hp = GetMe():GetHpPercent()
	--ShowToClient(tostring(os.date("%X")), "Check HP before open Box" , 20)
    if hp > 80 then
		local tx = lowMob:GetLocation().X + math.random(-60, 60)
        local ty = lowMob:GetLocation().Y + math.random(-60, 60)
        MoveToNoWait(tx, ty, lowMob:GetLocation().Z)
        Sleep(1000)
        --ShowToClient(tostring(os.date("%X")), "Safe - Opening chest", 20)
        SetPause(true)
        Target(lowMob)
        Sleep(400)
        UseKey()           -- assume you have this function from previous version
        Sleep(1500)
        SetPause(false)
        ClearT()
    else
        -- Low HP logic (same as before)
		--ShowToClient(tostring(os.date("%X")), "Check HP/ Low HP logic" , 20)
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
            --ShowToClient(tostring(os.date("%X")), "Low HP but safe - Opening", 20)
            SetPause(true)
            Target(lowMob)
            Sleep(400)
            UseKey()
            Sleep(1500)
            SetPause(false)
            ClearT()
        else
            --ShowToClient(tostring(os.date("%X")), "Low HP + mobs - Fight general first", 20)
            local gen = GetNearestByPriority(200, "general")
            if gen then Target(gen) end
        end
    end
end


-- ====================== MAIN TARGET FUNCTION ======================
function TargetPriority(range)
    -- 1. HIGH priority first
	--ShowToClient(tostring(os.date("%X")), "HIGH priority first", 20)
    local high = GetNearestByPriority(range, "high")
    if high ~= nil then
		--ShowToClient(tostring(os.date("%X")), "HIGH mob near: " .. high:GetName() )
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
	--else
		--ShowToClient(tostring(os.date("%X")), "We have no key)", 20)
    end

    -- 3. GENERAL fallback
	if ( (GetMe():IsMyPartyMemberMaster() or weArePL ) and not stopFarm) then
		local general = GetNearestByPriority(range, "general")
		if general == nil then
			ShowToClient(tostring(os.date("%X")), "No valid targets - move To Spot!", 20)
			moveToNext()		-- to farm spot
			Sleep(3400)
			return
		end
		ApproachAndTarget(general, range)
	end
end

-- ====================== HELPER FUNCTIONS ======================

function HasKey()
	--ShowToClient(tostring(os.date("%X")), "noKeysLeft: " .. tostring(noKeysLeft), 20)
	if noKeysLeft then return false end
--- перевірка глобальної змінної і стану ключів щоб не робити ліст сумки щоразу
	if ( keyID ~= nil and keyCount > 0 ) then
		--ShowToClient(tostring(os.date("%X")), "HasKey. " .. keyCount .. " keys left", 20);
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
				--ShowToClient(tostring(os.date("%X")), "Keys: " .. item.Name .. " DisplayId: " .. item.displayId .. " Num: " .. item.ItemNum, 20);
				ShowToClient(tostring(os.date("%X")), "Keys: " .. item.Name .. " Num: " .. item.ItemNum, 20);
				keyID = item.displayId		-- save keys id info in global env
				keyCount = item.ItemNum
				return true
			else
				--ShowToClient(tostring(os.date("%X")), "Keys not found");
				--Sound();
			end
			--else if not found
		end
		noKeysLeft = true
	end
	ShowToClient(tostring(os.date("%X")), "HasKey. Keys not found", 20);
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
        ShowToClient(tostring(os.date("%X")), "Low HP - next target", 20)
        Command("/useshortcut 1 1")
    end

    Sleep(400)
end
-----------------

function moveToNext()
-- Approach with random offset (anti-detection / geometry trick)
    local offsetX, offsetY = 0, 0

    offsetX = math.random(-50, 50)
    offsetY = math.random(-50, 50)

	--GotoSpot(143496, 112273, -3950, moveDistance) spot
    local tx = 143496 + offsetX
    local ty = 112273 + offsetY
    local tz = -3950
	
	--ShowToClient(tostring(os.date("%X")), "Life-hack = try to move somewhere", 20);
    MoveToNoWait(tx, ty, tz)
	Sleep(3210)
end

function toSafePlace()
	local moveDistance	=	100
	SetPause(true);
	if 	( GetMe():GetRangeTo(143496, 112273, -3950) < 1500 ) then		--на точці в ЛОА
		ShowToClient(tostring(os.date("%X")), "At farm point", 20);
		GotoSpot(142857, 111745, -3950, moveDistance);
		GotoSpot(142772, 111505, -3950, moveDistance);
		GotoSpot(142666, 111163, -3950, moveDistance);
		Sleep(2000)
		KillMons()
		Sleep(7000)
		KillMons()
	else
		ShowToClient(tostring(os.date("%X")), "Unknown place, SOE in 10 sec", 20);
		Sleep(10000)
		Sound()
		ProcessCommand("/scriptStart Go-Loa-DeepInside.lua")
		Sleep(2000)
		KillMons()
		Sleep(7000)
		KillMons()
	end	
end;

function tpToKamael()
		ClickAndWait("_bbshome", "");
		ClickAndWait("voice .teleporterservice h scl", "");
		ClickAndWait("voice .teleporterservice h sl STC_OTHER_LOCATIONS", "");
		ClickAndWait("voice .teleporterservice t s S_L2U_KAMAEL_VILLAGE STC_OTHER_LOCATIONS", "");
		while ( GetMe():GetRangeTo(-116901, 46601, 366) > 1000 ) do
			Sleep(1500)
			ShowToClient(tostring(os.date("%X")), "wait", 20);
			while ( GetMe():IsInCombat() ) do
				ShowToClient("[Escape] ", " InCombat: ".. tostring(GetMe():IsInCombat()),20);
				KillMons()
				Sleep(1432)
			end
			somethingWeird()
		end
		ShowToClient(tostring(os.date("%X")), "go!", 20);
end

function deltaMove()
	--ShowToClient(tostring(os.date("%X")), "Delta step...",20);
	local tx = GetMe():GetLocation().X + math.random(-30, 30)+ ((string.sub(MyID,-2))/2)
	local ty = GetMe():GetLocation().Y + math.random(-30, 30)
	MoveToNoWait(tx, ty, GetMe():GetLocation().Z);
end

function moveToStart()

	SetPause(true);
	local moveDistance	=	100
	
	if 	( GetMe():GetRangeTo(143496, 112273, -3950) < 1500 ) then		--на точці в ЛОА
		ShowToClient(tostring(os.date("%X")), "At start point", 20);
		GotoSpot(143496, 112273, -3950, moveDistance)
		deltaMove()
	
	elseif ( GetMe():GetRangeTo(142666, 111163, -3950) < 2000 ) then	-- десь в лоа
			GotoSpot(142857, 111745, -3950, moveDistance)
			GotoSpot(143496, 112273, -3950, moveDistance)
			deltaMove()
	else
		ShowToClient(tostring(os.date("%X")), "unknown place, teleport?", 20)
		Sound()
		GoLoaFarmSpot()
	end
	ClearT()
	SetPause(false);
	ShowToClient(tostring(os.date("%X")), "Exit from moveToStart", 20)
end;

function GoLoaFarmSpot()
-----------------
moveDistance	= 80;
HardMarch		= 479	-- Hard March
-----------------

ClickAndWait("_bbshome", "");
ClickAndWait("voice .teleporterservice h scl", "");
ClickAndWait("voice .teleporterservice h sl STC_TOWN_AREAS", "");
ClickAndWait("voice .teleporterservice t s S_HUNTERS STC_TOWN_AREAS", "");
Sleep(5000)
MoveTo(117240, 76802, -2695, moveDistance);
TargetNpc("Separated Soul", 32864);
Talk();
ClickAndWait("Quest SeparatedSoul 6", "Deep inside Antharas' Lair");
Sleep(5000)
MoveTo(148452, 110577, -3950, moveDistance);
UseSkillH(HardMarch);
MoveTo(148440, 110559, -3950, moveDistance);
MoveTo(147963, 110281, -3950, moveDistance);
MoveTo(146880, 109678, -3950, moveDistance);
MoveTo(145888, 109158, -3950, moveDistance);
MoveTo(145390, 108722, -3950, moveDistance);
MoveTo(145371, 108706, -3950, moveDistance);
MoveTo(145371, 108706, -3950, moveDistance);
MoveTo(144959, 108372, -3941, moveDistance);
MoveTo(144264, 107725, -3950, moveDistance);
MoveTo(143780, 107365, -3950, moveDistance);
MoveTo(143153, 107214, -3950, moveDistance);
MoveTo(143113, 107215, -3950, moveDistance);
MoveTo(143085, 107215, -3950, moveDistance);
MoveTo(143085, 107215, -3950, moveDistance);
MoveTo(142574, 107224, -3949, moveDistance);
MoveTo(142446, 107226, -3950, moveDistance);
MoveTo(141178, 107251, -3950, moveDistance);
MoveTo(140801, 107349, -3950, moveDistance);
MoveTo(140645, 107599, -3950, moveDistance);
MoveTo(140691, 108018, -3950, moveDistance);
MoveTo(140905, 108182, -3950, moveDistance);
MoveTo(141126, 108465, -3950, moveDistance);
MoveTo(141136, 108477, -3950, moveDistance);
MoveTo(141136, 108477, -3950, moveDistance);
MoveTo(141450, 108875, -3950, moveDistance);
MoveTo(141834, 109322, -3950, moveDistance);
MoveTo(142169, 109530, -3950, moveDistance);
MoveTo(142169, 109530, -3950, moveDistance);
MoveTo(142401, 109862, -3941, moveDistance);
MoveTo(142452, 110058, -3950, moveDistance);
MoveTo(142627, 111187, -3950, moveDistance);
MoveTo(142921, 111411, -3950, moveDistance);
ClearT()
Sleep(3000)
UseSkillH(HardMarch);
end

function KillMons()
	local stopDefence = false
	
	ClearT()
	
	while not stopDefence do
	    local attacker = nil
		local attackerDist = 999999
		local monsterlist = GetMonsterList()
		
		ShowToClient(tostring(os.date("%X")), "Find attacker" , 20)
		for mob in monsterlist.list do
			local d = mob:GetDistance()
			if d >= 200 then goto cont2 end
			if mob:IsAlikeDeath() or mob:IsBlock() then goto cont2 end
			--ShowToClient(tostring(os.date("%X")), "monster " .. mob:GetName() .. " [".. mob:GetDistance() .."]", 20)
			if  mob:IsAttacking()  then
				--ShowToClient(tostring(os.date("%X")), "monster " .. mob:GetName() .. " [".. mob:GetDistance() .."] Is attacking: " .. tostring(mob:IsAttacking()), 20)
				if d < attackerDist then
					attackerDist = d
					attacker = mob
				end
			end
			::cont2::
			--ShowToClient(tostring(os.date("%X")), "No monsters near" , 20)
		end

		if attacker ~= nil then
			--ShowToClient(tostring(os.date("%X")), "Defending vs attacker: " .. attacker:GetName(), 20)
			Target(attacker)
			SetPause(false);
		else
			--ShowToClient(tostring(os.date("%X")), "not need to defend. no Agro mobs near" , 20)
			stopDefence = true
		end
		Sleep(5432)
	end
	--ShowToClient(tostring(os.date("%X")), "All agro monsters cleared" , 20)
	SetPause(true);
end

function checkIdle(startTime)
	local result = false
	if (GetTime() - startTime >= idleTime*60000) then
		ShowToClient(tostring(os.date("%X")), "Time to finish. Go to Safe place",20);
		stopFarm	=	true
		if (not GetMe():IsInCombat()) then
			ShowToClient(tostring(os.date("%X")), "Go to Safe place",20);
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
        --ShowToClient(tostring(os.date("%X")), string.format("Not moving! Dist moved: %.0f  - Trying to unstuck", distMoved), 20);
       
        
        -- Додаткова перевірка: якщо довго не рухався — повертаємося на старт
		if not weArePL then
			timeout = 3 * timeout
		end
		
		if weArePL then
			moveToNext()          -- спочатку пробуємо локальний unstuck (якщо є така функція)
		else
			--ShowToClient(tostring(os.date("%X")), "Assist to PL " .. (timeout/1000), 20);
			Command("/useshortcut 1 3");
			Sleep(7000)
			ClearT()
			deltaMove()
		end
		
        if (currentTime - lastChangeTime) >= timeout then
 
			ShowToClient(tostring(os.date("%X")), "No movement for " .. (timeout/1000) .. " seconds - Returning to farm spot", 20);
			--moveToStart()
			deltaMove()
			Sleep(800);
        end

    else
        lastChangeTime = currentTime
    end
end

function checkAlive()
	if GetMe():IsAlikeDeath() then
		if IsPaused() then
			SetPause(false)
		end
        ShowToClient(tostring(os.date("%X")), "=== DIED === Waiting for resurrection...", 20);
        Sound()

        local waitStart = GetTime();
        while GetMe():IsAlikeDeath() and (GetTime() - waitStart < 60000) do
            Sleep(5000);
        end
		ShowToClient(tostring(os.date("%X")), "Resurrected. Returning to farm spot...", 20);
		SetPause(true)
		while ( GetMe():IsInCombat() ) do 
			Sleep(3000 + math.random(0, 2000));
			ShowToClient("[Buff] ", " Sleep 3-5sec",20);
		end
		Command(".buffset FFA");
		Sleep(3000 + math.random(0, 1000));   
        moveToStart();
        LastHatCheck = GetTime();
        startTime    = GetTime();
        Sleep(500);
    end
end
------------------------------------------------------------------------------------
--- MAIN ---
ShowToClient(tostring(os.date("%X")), "Start Loa Farm", 20);
ShowToClient(tostring(os.date("%X")), "Farm for " .. idleTime .. " min", 20);

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
    Command(".buffset FFA");
end

moveToStart();                     -- перший раз йдемо на спот

while true do
    -- === ОБРОБКА СМЕРТІ ===
    checkAlive()
    -- === ОСНОВНА ЛОГІКА ===
    local currentlyPaused = IsPaused();
    if currentlyPaused then
        if not isPausedPreviously then
            -- Тільки при переході в паузу
            ShowToClient(tostring(os.date("%X")), "Script is Paused", 20);
            isPausedPreviously = true;
        end
    else
        if isPausedPreviously then
            -- Тільки при знятті з паузи
            ShowToClient(tostring(os.date("%X")), "Farm resumed", 20);
            isPausedPreviously = false;
        end
		CheckMovement()
        -- Основний фарм (виконується тільки коли не на паузі)
        if (GetTime() - LastHatCheck > 60*1000) then
            BonusHatOn();
            LastHatCheck = GetTime();
        end

        if checkIdle(startTime) then
            ShowToClient("#", "Idle detected - going to safe place", 20);
            toSafePlace();
			SleepTime = SleepTimeFrom*60000 + math.random(-SleepTimeFrom/3, SleepTimeTo)*60000
			ShowToClient(tostring(os.date("%X")), "Farm paused for " .. math.floor((SleepTime/1000)/60) .. " min", 20);
			Sleep(SleepTime);
			--moveToStart();
            startTime = GetTime();
        else
			local MyTarget = GetTarget();
            if (MyTarget ~= nil and MyTarget:IsMonster() and not MyTarget:IsAlikeDeath()) then
                if (MyTarget:GetDistance() >= RushDist and Rush ~= nil) then
                    UseSkillH(Rush);
                end
            else
                TargetPriority(FightRange);
            end
        end
		------------------
    end

    -- Затримка циклу
    Sleep(1800 + math.random(-800, 2200));
end
	
ShowToClient(tostring(os.date("%X")), "Stop all.", 20);
SetPause(true);