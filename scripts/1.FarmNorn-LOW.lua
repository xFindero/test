----------------------------------
-- Script for Hunting Monsters near Nornil Cave 
--- v.4 2026-04-11	--added avoid attack other users general monsters *GetNearestByPriority(range, priorityType)
--- v.3 2026-04-09	--added PVP/PVE death reaction
----------------------------------
NxtTrgtDelay	=	10		-- in sec
NxtTrgtHP		=	70		-- in %
LastNxtTrgt		=	0		-- time when it used for last time
FightRange		=	3000	-- range to find monsters
lastChangeTime	=	0
farmTime		=	45		-- in min (farm time, then go to rest point)
restTime		=	55		-- in min (rest time, then go to rest point)
weArePL			=	false
stopFarm		=	false
restartMovement	=	false
returnPvPDelay	=	35		-- in munites, delay to keep in safe
avoidPlayersMobDist 	=	300
moveNextCounter	=	0
----------------------------------
--- Alt+B Heal
HealLastUsed       = 0
HealCooldown       = 60000          -- 60 секунд (1 хвилина)
HealHpPercent      = 90
HealMpPercent      = 50
HealCpPercent      = 90
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
RushDist 		=	500
----------------------------------
-- ====================== GLOBAL SETTINGS ======================
blackList			=	{"Treasure Chest", "Treasure Box", "Muertos Warrior", "Crimson Spider", "Muertos Captain", "Skull Crusher", "Butcher's Son", "Infernal Sentry", "Rejected Servant", "Wild Creature"}
highPriorityList	=	{"Elite Envoy", "Dreadmaw", "Backbite", "Fleshreaper"}
lowPriorityList 	=	{"123"}
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
	local dist = dist or 180
	local startMoveTime = GetTime()
	local startLoc		= GetMe():GetLocation()
	local delta			= 50
	local startTime     = GetTime()
    local lastCheckTime = GetTime()
    local lastX, lastY, lastZ = GetMe():GetLocation().X, GetMe():GetLocation().Y, GetMe():GetLocation().Z
	local arrived		= false
	
	if restartMovement then return end
	ShowTrace(FVector(spotX, spotY, spotZ));
	-- Вимикаємо бота повністю на час руху (щоб не атакував мобів по дорозі)
	local wasPaused = IsPaused()
	if not wasPaused then
		SetPause(true)
	end
	--ShowToClient(tostring(os.date("%X")), "moveTo " .. spotX, 20)
    MoveToNoWait(spotX, spotY, spotZ)

    while (not arrived or not restartMovement) do
        Sleep(400)

        -- Перевірка смерті (дуже важливо викликати регулярно)
		-- Якщо персонаж загинув — checkDeath() вже обробив респ + місто
        -- Тому просто виходимо з GotoSpot повністю
		--ShowToClient(tostring(os.date("%X")), "GotoSpot. to checkDeath ", 20)
		if checkDeath() then
			restartMovement = true
			--ShowToClient(tostring(os.date("%X")), "restartMovement", 20)
			break
		else
			--ShowToClient(tostring(os.date("%X")), "Alive, move to next", 20)
		end
		--ShowToClient(tostring(os.date("%X")), "GotoSpot. to contrKill ", 20)
        contrKill()   -- захист від мобів - Low HP
		
        local currentTime = GetTime()
        local me = GetMe()
		--ShowToClient(tostring(os.date("%X")), "GotoSpot. to timeout ", 20)
        -- Таймаут руху (90 секунд максимум)
        if (currentTime - startTime) > 90000 then
            ShowToClient(tostring(os.date("%X")), "GotoSpot: Timeout (90s) - aborting", 20)
            break
        end

        -- Перевірка прибуття
        if me:GetRangeTo(spotX, spotY, spotZ) <= dist then
            --ShowToClient(tostring(os.date("%X")), "GotoSpot: Successfully arrived at target!", 20)
            arrived = true
            break
        end

        -- Періодична перевірка кожні ~2 секунди
        if (currentTime - lastCheckTime) >= 2000 then
            lastCheckTime = currentTime

            local currX = me:GetLocation().X
            local currY = me:GetLocation().Y
            local currZ = me:GetLocation().Z

            local distMoved = me:GetRangeTo(lastX, lastY, lastZ)

            -- Unstuck логіка
            if distMoved < 180 and not me:IsInCombat() then
                ShowToClient(tostring(os.date("%X")), "GotoSpot: Stuck detected (" .. math.floor(distMoved) .. ") - unstuck", 20)

                local tx = currX + math.random(-350, 350)
                local ty = currY + math.random(-350, 350)
                ShowTrace(FVector(tx, ty, currZ))
                MoveToNoWait(tx, ty, currZ)
                Sleep(1400)
            end

            -- Повертаємося до цілі з невеликим розкидом
            MoveToNoWait(spotX + math.random(-delta, delta), 
                         spotY + math.random(-delta, delta), spotZ)

            lastX, lastY, lastZ = currX, currY, currZ
        end

        -- Якщо заблоковані: stun, root
        if me:IsBlocked(true) then
            ShowToClient(tostring(os.date("%X")), "GotoSpot: Blocked - fighting nearby mobs", 20)
            KillMons()
            Sleep(800)
        end
    end

    -- Фінальна очистка
	--ShowToClient(tostring(os.date("%X")), "GotoSpot. Finish to contrKill ", 20)
    Sleep(700)
    contrKill()

    -- Повертаємо попередній стан паузи (якщо був увімкнений до виклику)
    if not wasPaused then
        SetPause(false)
    end

    --ShowToClient(tostring(os.date("%X")), "GotoSpot finished.", 20)
end

function contrKill()
	myHP = GetMe():GetHpPercent();
	--ShowToClient(tostring(os.date("%X")), "Check contrKill.",20);
	if ( myHP < 85 and  myHP > 0 ) then
		--ShowToClient(tostring(os.date("%X")), "Start contrKill.",20);
		ShowToClient("#", "GoToSpot. HP: " .. math.floor(myHP), 20);
		KillMons()
	end
	return 0
end

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
							--ShowToClient("[HatOn]", "Try to Wear Hat: " .. item.Name .." [".. item.displayId .. "]", 20);
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
	Sound()
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
	--local scippedPlayerMob = ""
    local monsterlist = GetMonsterList()
    if not monsterlist or monsterlist:GetCount() == 0 then
        return nil
    end

    local playerlist = GetPlayerList()  -- get all visible players once (optimization)

    local me     = GetMe()
	local myZ    = me:GetLocation().Z   -- our current Z height
    local prioList = nil

    if priorityType == "high" then
        prioList = highPriorityList
    elseif priorityType == "low" then
        prioList = lowPriorityList
    elseif priorityType == "general" then
        prioList = nil
    else
        ShowToClient(tostring(os.date("%X")), "Invalid priorityType: " .. tostring(priorityType), 20)
        return nil
    end

    local nearestMob = nil
    local nearestDist = 999999

    for mob in monsterlist.list do
        local mobDist = mob:GetDistance()
        if mobDist >= range then goto continue end

        -- Blacklist (name-based)
        local isBlacklisted = false
        for i = 1, #blackList do
            if string.find(mob:GetName(), blackList[i]) then
                mob:SetBlock(true)
                isBlacklisted = true
                break
            end
        end
        if isBlacklisted then goto continue end

        -- Priority name match
        local matchesPriority = (priorityType == "general")
        if prioList then
            for i = 1, #prioList do
                if string.find(mob:GetName(), prioList[i]) then
                    matchesPriority = true
                    break
                end
            end
        end
        if not matchesPriority then goto continue end

        -- NEW: AVOID OTHER PLAYERS HUNTING NEAR THIS MOB
        local mobLoc = mob:GetLocation()
        local claimedByOther = false

        for player in playerlist.list do
            if player == nil or player:IsAlikeDeath() then goto nextPlayer end

            -- Skip our own party members
            if player:IsMyPartyMember() or player:IsMe() then goto nextPlayer end

            -- Option B: if above doesn't exist, use distance to us + assume party share
            -- But better use party check if available

            local playerDistToMob = player:GetRangeTo(mobLoc.X, mobLoc.Y, mobLoc.Z)
            -- Alternative if no GetDistanceTo(location): calculate manually
            -- local dx = player:GetLocation().X - mobLoc.X
            -- local dy = player:GetLocation().Y - mobLoc.Y
            -- local dz = player:GetLocation().Z - mobLoc.Z
            -- local playerDistToMob = math.sqrt(dx*dx + dy*dy + dz*dz)

            if playerDistToMob <= avoidPlayersMobDist then
                claimedByOther = true
				--scippedPlayerMob = player:GetName()
                break  -- no need to check more players
            end

            ::nextPlayer::
        end

        if claimedByOther and priorityType == "general" then
            --ShowToClient(tostring(os.date("%X")), "Skiped mob (other player near) " .. mob:GetName() .. " ID: " .. mob:GetId())
            goto continue
        end
----------------------------
        -- NEW: AVOID MONSTERS WITH BIG Z DIFFERENCE (floors / heights / under us)
        local mobZ = mob:GetLocation().Z
        local zDiff = math.abs(myZ - mobZ)

        if zDiff >= 150 then
            -- Optional debug (uncomment to see skipped ones)
            -- ShowToClient(tostring(os.date("%X")), "Skipped " .. mob:GetName() .. " - big Z diff (" .. math.floor(zDiff) .. ")", 20)
            goto continue
        end
----------------------------
        -- Alive & not blocked
        if mob:IsAlikeDeath() or mob:IsBlock() then goto continue end

        -- Good candidate
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

    ShowToClient(tostring(os.date("%X")), "LOW PRIORITY CHEST detected! Dist: " .. math.floor(dist), 20)

    if dist > 200 then
        local tx = lowMob:GetLocation().X + math.random(-60, 60)
        local ty = lowMob:GetLocation().Y + math.random(-60, 60)
        MoveToNoWait(tx, ty, lowMob:GetLocation().Z)
        Sleep(2200)
        --return
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
		--ShowToClient(tostring(os.date("%X")), "monster near" , 20)
        -- Is attacking us? (adjust method if your L2Tower version differs)
        --local tgt = mob:GetTarget()
        if  mob:IsAttacking()  then
            if d < attackerDist then
                attackerDist = d
                attacker = mob
            end
        end
        ::cont2::
		--ShowToClient(tostring(os.date("%X")), "No monsters near" , 20)
    end

    if attacker ~= nil then
        --ShowToClient(tostring(os.date("%X")), "Defending vs attacker", 20)
        Target(attacker)
        return
	--else
		--ShowToClient(tostring(os.date("%X")), "not need to defend" , 20)
    end

    -- No attackers - open logic
    local hp = GetMe():GetHpPercent()
	--ShowToClient(tostring(os.date("%X")), "Check HP before open Box" , 20)
    if hp > 80 then
		local tx = lowMob:GetLocation().X + math.random(-60, 60)
        local ty = lowMob:GetLocation().Y + math.random(-60, 60)
        MoveToNoWait(tx, ty, lowMob:GetLocation().Z)
        Sleep(1000)
        ShowToClient(tostring(os.date("%X")), "Safe - Opening chest", 20)
        SetPause(true)
        Target(lowMob)
        Sleep(400)
        UseKey()           -- assume you have this function from previous version
        Sleep(1500)
        SetPause(false)
        ClearT()
    else
        -- Low HP logic (same as before)
		ShowToClient(tostring(os.date("%X")), "Check HP/ Low HP logic" , 20)
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
            ShowToClient(tostring(os.date("%X")), "Low HP but safe - Opening", 20)
            SetPause(true)
            Target(lowMob)
            Sleep(400)
            UseKey()
            Sleep(1500)
            SetPause(false)
            ClearT()
        else
            ShowToClient(tostring(os.date("%X")), "Low HP + mobs - Fight general first", 20)
            local gen = GetNearestByPriority(200, "general")
            if gen then Target(gen) end
        end
    end
end


-- ====================== MAIN TARGET FUNCTION ======================
function TargetPriority(range)
	--ShowToClient(tostring(os.date("%X")), "TargetPriority. range: " .. range, 20)
    -- 1. HIGH priority first
	--ShowToClient(tostring(os.date("%X")), "HIGH priority first", 20)
    local high = GetNearestByPriority(range, "high")
    if high ~= nil then
		ShowToClient(tostring(os.date("%X")), "HIGH mob near. " .. high:GetName())
		Sound()
        ApproachAndTarget(high, range)
        return
	else
		--ShowToClient(tostring(os.date("%X")), "no HIGH mob near", 20)
    end

    -- 2. LOW priority (only if we have key)
	--ShowToClient(tostring(os.date("%X")), "LOW priority (only if we have key)", 20)
	if HasKey() then		-- запускається при кожному пошуку моба... бажано робобити 1 раз при запуску скрипта або з якоюсь періодичністю..
        local low = GetNearestByPriority(range, "low")
        if low ~= nil then
            HandleLowPriorityChest(low)
            return
		--else
			--ShowToClient(tostring(os.date("%X")), "no LOW mob near", 20)
        end
	else
		ShowToClient(tostring(os.date("%X")), "We have no key)", 20)
    end

    -- 3. GENERAL fallback
	if ( (GetMe():IsMyPartyMemberMaster() or weArePL ) and not stopFarm) then
		--ShowToClient(tostring(os.date("%X")), " GENERAL fallback, for PL only", 20)
		local general = GetNearestByPriority(range, "general")
		if moveNextCounter > 5 then
			ShowToClient(tostring(os.date("%X")), " GENERAL fallback 5 times, move to start", 20)
			moveToStart();
			moveNextCounter = 0
		else
			if general == nil then
				ShowToClient(tostring(os.date("%X")), "No valid targets - moveToNext!", 20)
				moveToNext()
				Sleep(400)
				moveNextCounter = moveNextCounter + 1
				return
			end
		end

		ApproachAndTarget(general, range)
	--else
		--ShowToClient(tostring(os.date("%X")), "Not targeting general mobs, I'm not PL", 20)
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

    if dist <= 500 then
        offsetX = math.random(10, 30)
        offsetY = math.random(5, 20)
        sleepAfter = 100
    elseif dist <= 1000 then
        offsetX = math.random(30, 90)
        offsetY = math.random(50, 100)
        sleepAfter = 750
    else
        offsetX = math.random(150, 250)
        offsetY = math.random(50, 150)
        sleepAfter = 2300
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
        moveToNext()
        return
    end

    -- HP life-hack
    local me = GetMe()
    if me:GetHpPercent() <= NxtTrgtHP and (GetTime() - LastNxtTrgt or 0) > (NxtTrgtDelay * 1000) then
        LastNxtTrgt = GetTime()
        --ShowToClient(tostring(os.date("%X")), "Low HP - next target", 20)
        Command("/useshortcut 1 1")
    end

    Sleep(400)
end
-----------------

function moveToNext()
-- Approach with random offset (anti-detection / geometry trick)
    local offsetX, offsetY = 0, 0

    offsetX = math.random(-600, 600)
    offsetY = math.random(-600, 600)


    local tx = GetMe():GetLocation().X + offsetX
    local ty = GetMe():GetLocation().Y + offsetY
    local tz = GetMe():GetLocation().Z
	
    MoveToNoWait(tx, ty, tz)
	Sleep(3210)
end

function toSafePlace()
	local moveDistance	=	250
	SetPause(true);
	if 	( GetMe():GetRangeTo(-84151, 39472, -2449) < 2500 )	then	--на фарм споті
		ShowToClient(tostring(os.date("%X")), "On Farm, move to Rest zone", 20);
		GotoSpot(-84151, 39472, -2449, moveDistance);
		GotoSpot(-84344, 39373, -2434, moveDistance);
		GotoSpot(-84796, 39001, -2377, moveDistance);
		GotoSpot(-85183, 38654, -2311, moveDistance);
		GotoSpot(-85230, 38430, -2166, moveDistance);
		GotoSpot(-85177, 38201, -2065, moveDistance);
		GotoSpot(-85147, 38099, -2035, moveDistance);
		Sleep(7000)
		KillMons()
		deltaMove()	
	elseif 	( GetMe():GetRangeTo(-85237, 37995, -2022) < 900 ) then		--точка відпочинку
		ShowToClient(tostring(os.date("%X")), "On rest point", 20);
		deltaMove()	
	elseif 	( GetMe():GetRangeTo(-86516, 37011, -2054) < 2500 ) then		--біля ТП 
		ShowToClient(tostring(os.date("%X")), "On TP, move to rest point under Tree", 20);
		GotoSpot(-86276, 37838, -2108, moveDistance);
		GotoSpot(-86233, 37910, -2107, moveDistance);
		GotoSpot(-85914, 37991, -2110, moveDistance);
		GotoSpot(-85496, 37639, -2111, moveDistance);
		GotoSpot(-85222, 37969, -2018, moveDistance);
		deltaMove()
		Sleep(7000)
		KillMons()
	---------------------------
	else
		ShowToClient(tostring(os.date("%X")), "move to our safe place", 20);
		moveDistance = 250;
		--
		ClickAndWait("_bbshome", "");
		ClickAndWait("voice .teleporterservice h scl", "");
		ClickAndWait("voice .teleporterservice h sl STC_OTHER_LOCATIONS", "");
		while ( GetMe():IsInCombat() ) do
			ShowToClient("[Escape] ", " InCombat: ".. tostring(GetMe():IsInCombat()),20);
			KillMons()
			Sleep(1432)
		end
		ClickAndWait("voice .teleporterservice t s S_L2U_KAMAEL_VILLAGE STC_OTHER_LOCATIONS", "");
		Sleep(4321)
		if ( GetMe():GetRangeTo(-116901, 46601, 366) < 500 ) then
			ShowToClient(tostring(os.date("%X")), "In Kamael on TP",20);
			TargetNpc("Ragara", 32163);
			Sleep(1000)
			Talk();
			ClickText("Teleport");
			Sleep(1421)
			ClickText("Stronghold III");
			Sleep(4321)
			-----------
			while ( GetMe():GetRangeTo(-116812, 46576, 366) < 500 ) do
				ShowToClient(tostring(os.date("%X")), "We can't teleport",20);
				Sound();
				Sleep(30000)
			end
			-----------
			if ( GetMe():GetRangeTo(-86516, 37011, -2054) < 1000 ) then
			GotoSpot(-86276, 37838, -2108, moveDistance);
			GotoSpot(-86233, 37910, -2107, moveDistance);
			GotoSpot(-85914, 37991, -2110, moveDistance);
			GotoSpot(-85496, 37639, -2111, moveDistance);
			GotoSpot(-85222, 37969, -2018, moveDistance);
				deltaMove()
			else
				while ( IsPaused() ) do
				ShowToClient(tostring(os.date("%X")), "We not on spot!",20);
				Sound();
				Sleep(30000)
			end
			end
		else
			ShowToClient(tostring(os.date("%X")), "Where you ARE?",20);
		end
	end
end;

function deltaMove()
	--ShowToClient(tostring(os.date("%X")), "Delta step...",20);
	local tx = GetMe():GetLocation().X + math.random(-30, 30)+ ((string.sub(MyID,-2))/2)
	local ty = GetMe():GetLocation().Y + math.random(-30, 30)
	MoveToNoWait(tx, ty, GetMe():GetLocation().Z);
end

function tpToKamael()
		ClickAndWait("_bbshome", "");
		ClickAndWait("voice .teleporterservice h scl", "");
		ClickAndWait("voice .teleporterservice h sl STC_OTHER_LOCATIONS", "");
		ClickAndWait("voice .teleporterservice t s S_L2U_KAMAEL_VILLAGE STC_OTHER_LOCATIONS", "");
		while ( GetMe():GetRangeTo(-116901, 46601, 366) > 1000 ) do
			Sleep(1500)
			ShowToClient(tostring(os.date("%X")), "wait", 20);
		end
		ShowToClient(tostring(os.date("%X")), "go!", 20);
end

function tpFromKamael()
	local 	moveDistance = 250

		if ( GetMe():GetRangeTo(-116901, 46601, 366) < 1500 ) then
			ShowToClient(tostring(os.date("%X")), "In Kamael on TP",20);
			GotoSpot(-116901, 46601, 366, moveDistance);
			TargetNpc("Ragara", 32163);
			Sleep(1500)
			Talk();
			ClickText("Teleport");
			Sleep(2121)
			ClickText("Stronghold III");
			Sleep(4321)
			-----------
			while ( GetMe():GetRangeTo(-116812, 46576, 366) < 500 ) do
				ShowToClient(tostring(os.date("%X")), "We can't teleport",20);
				Sound();
				Sleep(15000)
			end
			-----------
			if ( GetMe():GetRangeTo(-86516, 37011, -2054) < 1000 ) then
				GotoSpot(-85956, 38256, -2079, moveDistance);
				GotoSpot(-85972, 38150, -2081, moveDistance);
				GotoSpot(-85917, 38164, -2080, moveDistance);
				GotoSpot(-85692, 38445, -2095, moveDistance);
				GotoSpot(-84889, 38979, -2371, moveDistance);

				deltaMove()
				-------------
			else
				while ( IsPaused() ) do
				ShowToClient(tostring(os.date("%X")), "We not on spot!",20);
				Sound();
				Sleep(30000)
				end
			end
		else
			ShowToClient(tostring(os.date("%X")), "Where you ARE?. tpFromKamael() - Failed",20);
		end
end

function unstuckFromRocks()
	local result = false
	local moveDistance	=	250
	SetPause(true)
	
	if 	( GetMe():GetRangeTo(-88274, 36324, -2091) < 500 ) then		
		ShowToClient(tostring(os.date("%X")), "Near First Tree", 20);
		GotoSpot(-89046, 37981, -2263, moveDistance);
		GotoSpot(-89059, 38005, -2269, moveDistance);
		GotoSpot(-90122, 39230, -2491, moveDistance);
		result = true
	elseif 	( GetMe():GetRangeTo(-89066, 36025, -2139) < 500 ) then	
		ShowToClient(tostring(os.date("%X")), "Near First Rock", 20);
		GotoSpot(-89046, 37981, -2263, moveDistance);
		GotoSpot(-89059, 38005, -2269, moveDistance);
		GotoSpot(-90122, 39230, -2491, moveDistance);
		result = true
	elseif 	( GetMe():GetRangeTo(-89534, 35888, -2191) < 500 or GetMe():GetRangeTo(-89928, 36615, -2219) < 300 or
			  GetMe():GetRangeTo(-90766, 36984, -2265) < 300 or GetMe():GetRangeTo(-91347, 37335, -2264) < 300 or
			  GetMe():GetRangeTo(-91969, 37641, -2345) < 300 or GetMe():GetRangeTo(-92381, 38020, -2376) < 300 ) then	
		ShowToClient(tostring(os.date("%X")), "Near other Trees", 20);
		GotoSpot(-89524, 38629, -2408, moveDistance);
		GotoSpot(-90122, 39230, -2491, moveDistance);
		result = true
	else
		ShowToClient(tostring(os.date("%X")), "unstuckFromRocks. unknown place, try to move 1-2 step", 20);
	end
	ClearT()
	SetPause(false);
	return result
end

function moveToStart()
	restartMovement = false
	SetPause(true);
	local moveDistance	=	250
	if 	( GetMe():GetRangeTo(-84592, 38985, -2388) < 600 ) then		--в центрі LOW
		ShowToClient(tostring(os.date("%X")), "At start point", 20);
		GotoSpot(-84889, 38979, -2371, moveDistance);
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-85097, 38001, -2000) < 1500 ) then		-- на відпочинку 
		ShowToClient(tostring(os.date("%X")), "Rest point near TP", 20);
		GotoSpot(-85491, 38518, -2122, moveDistance);
		GotoSpot(-85501, 38667, -2249, moveDistance);
		GotoSpot(-85087, 38834, -2347, moveDistance);
		GotoSpot(-84889, 38979, -2371, moveDistance);
		deltaMove()
	else
		ShowToClient(tostring(os.date("%X")), "unknown place, teleport", 20);
		while ( GetMe():IsInCombat() ) do
			ShowToClient("[Escape] ", " InCombat: ".. tostring(GetMe():IsInCombat()),20);
			KillMons()
			Sleep(1432)
		end
		tpToKamael()
		tpFromKamael()
	end
	ClearT()
	SetPause(false);
end;

function KillMons()
	-- Захист: не воюємо в місті після смерті
    if GetMe():GetRangeTo(-116901, 46601, 366) < 3000 then  -- Kamael TP
        ShowToClient(tostring(os.date("%X")), "In town after death - skip KillMons", 20)
        SetPause(true)
        return
    end
	
	local stopDefence = false
	
	ClearT()
	
	while not stopDefence do
		if checkDeath() then
			stopDefence = true
			break
		end
	    local attacker = nil
		local attackerDist = 999999
		local monsterlist = GetMonsterList()
		
		ShowToClient(tostring(os.date("%X")), "Find attacker" , 20)
		for mob in monsterlist.list do
			local d = mob:GetDistance()
			if d >= 200 then goto cont1 end
			if mob:IsAlikeDeath() or mob:IsBlock() then goto cont1 end
			--ShowToClient(tostring(os.date("%X")), "monster " .. mob:GetName() .. " [".. mob:GetDistance() .."]", 20)
			if  mob:IsAttacking()  then
				--ShowToClient(tostring(os.date("%X")), "monster " .. mob:GetName() .. " [".. mob:GetDistance() .."] Is attacking: " .. tostring(mob:IsAttacking()), 20)
				if d < attackerDist then
					attackerDist = d
					attacker = mob
				end
			end
			::cont1::
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
	if (GetTime() - startTime >= farmTime*60000) then
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
        -- Додаткова перевірка: якщо довго не рухався — повертаємося на старт
		if not weArePL then
			timeout = 4 * timeout
		end
		
		if weArePL then
			if not unstuckFromRocks() then
				moveToNext()          -- спочатку пробуємо локальний unstuck (якщо є така функція)
			end
		else
			--ShowToClient(tostring(os.date("%X")), "Assist to PL " .. (timeout/1000), 20);
			Command("/useshortcut 1 3");
			Sleep(7000)
			ClearT()
			deltaMove()
		end
		
        if (currentTime - lastChangeTime) >= timeout then
 
			ShowToClient(tostring(os.date("%X")), "No movement for " .. (timeout/1000) .. " seconds - Returning to farm spot", 20);
			moveToStart();
			Sleep(800);
        end

    else
        -- === Персонаж рухався нормально ===
        lastChangeTime = currentTime
    end
end

function checkDeath()
	if not GetMe():IsAlikeDeath() then 
		return false 
	end
    ShowToClient(tostring(os.date("%X")), "=== DIED during movement ===", 20)
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
				ShowToClient(tostring(os.date("%X")), "PVP/W or Suspicious player near: " .. player:GetName() .. "Clan: " ..  tostring( player:GetClanName()) .. " [" .. pDist .. "]", 20)
				break
			end
			::cont3::
		end
	end
	
	-------------------------------
	if IsPaused() then
		SetPause(false)
	end
	
    local deathTime = GetTime()
    while GetMe():IsAlikeDeath() and (GetTime() - deathTime < 60000) do
        Sleep(5000)
    end

    if GetMe():IsAlikeDeath() then
        ShowToClient("Failed to resurrect in time", 20)
        return false
    end
	SetPause(true)	-- відключаємо все що може заважати в процесі переміщення до Farm Spot
    -- === ВИЗНАЧЕННЯ PvP vs PvE ===
    local me = GetMe()
    local isPvPDeath = (me:GetCpPercent() < 50) or me:IsPvPFlag() or me:IsPvPFlagBlink() or pvpNear

    if isPvPDeath then
        ShowToClient(tostring(os.date("%X")), "=== PvP DEATH DETECTED === Stopping all scripts")
        Sound()
		startDelay = (returnPvPDelay*60000 + math.random(-30000, 60000));
		ShowToClient(tostring(os.date("%X")), "Delay in Farm for " .. math.floor(startDelay/1000) .. " sec")
		Sleep(startDelay)
		
    else
        -- PvE смерть — повертаємося на фарм
        ShowToClient(tostring(os.date("%X")), "PvE death - returning to farm spot", 20)
		Sound()
		while ( GetMe():IsInCombat() ) do
			ShowToClient("[Escape] ", " InCombat: ".. tostring(GetMe():IsInCombat()),20);
			Sleep(1432)
		end
    end
	Rebuff()
    LastHatCheck = GetTime()
    startTime = GetTime()
	moveToStart()
	return true
end

function Rebuff()
	Command(".buffset FFA")
	Sleep(3000)
	HealthCheck()
end


function CheckParty()
    weArePL = false   -- спочатку скидаємо

    local me = GetMe()
    if me == nil then return end

    -- Варіант 1: Ми самі є лідером партії
    if me:IsMyPartyMemberMaster() then
        weArePL = true
        --ShowToClient("#", "Now We are Party Leader (PL)*", 20)
        return
    end

    -- Варіант 2: Ми не в партії взагалі
    local PartyList = GetPartyList()
    if not PartyList or not PartyList.list or PartyList:GetCount() == 0 then
        weArePL = true   -- якщо не в партії — вважаємо себе "PL" (самостійний фарм)
        --ShowToClient("#", "Not in party - acting as PL", 20)
        return
    end

    -- Варіант 3: Ми в партії, але лідер далеко
    for member in PartyList.list do
        if member:IsMyPartyMemberMaster() then
            local dist = member:GetDistance()

            if dist > 1500 then
                weArePL = true
                --ShowToClient("#", "Party Leader is far (" .. math.floor(dist) .. " dist) - acting as PL", 20)
            else
                weArePL = false
                --ShowToClient("#", "Party Leader nearby (" .. math.floor(dist) .. " dist)", 20)
            end
            return   -- знайшли лідера — більше не потрібно шукати
        end
    end

    -- Якщо чомусь не знайшли лідера в списку (рідкісний випадок)
    weArePL = true
    --ShowToClient("#", "Could not find Party Leader - acting as PL", 20)
end

function HealthCheck()
    local me = GetMe()
    if me == nil then return end

    local timeNow = GetTime()
    local delta   = timeNow - HealLastUsed

    -- Перевіряємо, чи потрібно хілитись
    if (me:GetHpPercent() <= HealHpPercent or me:GetMpPercent() <= HealMpPercent or me:GetCpPercent() <= HealCpPercent) and not me:IsInCombat() and delta >= HealCooldown then
        ShowToClient("#", string.format("HealthCheck: Restoring HP/MP/CP (%.0f sec since last)", delta/1000), 20)
        -- Виконуємо Alt+B → Buffer → Restore
        ClickAndWait("_bbshome", "")
        ClickAndWait("voice .bufferservice", "")
        ClickAndWait("voice .bufferservice t p h", "")   -- t p h = твоя команда на відновлення
        HealLastUsed = GetTime()
    else
		ShowToClient("#", string.format("HealthCheck: Restoring HP/MP/CP (%.0f sec since last) not Need", delta/1000), 20)
	end
end

--- MAIN ---
ShowToClient(tostring(os.date("%X")), "Start Nornil LOW Farm", 20);
ShowToClient(tostring(os.date("%X")), "Farm time: " .. farmTime .. " min", 20);

LastHatCheck			= GetTime()
-- === Змінні для перевірки руху ===
lastLocCheck			= GetTime()
startTime				= GetTime()
lastChangeTime			= GetTime()
lastX, lastY, lastZ		= 0, 0, 0
movementCheckInterval	= 15 * 1000   -- перевіряти кожні 25 секунд
stuckDistance			= 180             -- якщо змістився менше ніж на цю відстань = застряг
stuckTimeout			= 30 * 1000       -- якщо не рухався 60 секунд і не
------------------
MyID = GetMe():GetId();
Rush = checkRushSkill(RushSkills)

math.randomseed(
    os.time() * 1000 + 
    math.floor(os.clock() * 1000000) + 
    GetMe():GetId()
)

local myClass = GetMe():GetClass();
if myClass == 134 or GetMe():IsMyPartyMemberMaster() then
    weArePL = true;
    --ShowToClient("#", "We are PL or Trickster", 20);
end

-- Початкові дії
if GetMe():IsInCombat() then
	ShowToClient("[Escape]", "In Combat on start!", 20);
	KillMons()
else
    Rebuff()
end


if ( GetMe():GetRangeTo(-84592, 38985, -2388) > 2000 ) then		--в LOW точка в центрі неподалік ТП

	moveToStart();                     							-- перший раз йдемо на спот
end

----------- Старт скрипта
SetPause(false)
----------

local isPausedPreviously = false   -- змінна для відстеження стану паузи

while true do

    -- === ОБРОБКА СМЕРТІ ===
    if checkDeath() or restartMovement then
		ShowToClient(tostring(os.date("%X")), "Start moveToStart if Died or restartMovement");
		restartMovement = false
		moveToStart()
		Sleep(1500)
	end
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
            BonusHatOn()
			CheckParty()
            LastHatCheck = GetTime();
        end

        if checkIdle(startTime) then
            ShowToClient("#", "Idle detected - going to safe place", 20);
            toSafePlace();
			--SleepTime = 45*60000 + math.random(-10, 40)*60000
			SleepTime = restTime*60000 + math.random(-math.floor(restTime/3), math.floor(restTime/2))*60000
			ShowToClient(tostring(os.date("%X")), "Farm paused for " .. math.floor((SleepTime/1000)/60) .. " min", 20);
			Sleep(SleepTime);
			moveToStart();
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
    Sleep(1500 + math.random(-800, 700));
end
	
ShowToClient(tostring(os.date("%X")), "Stop all.", 20);
SetPause(true);