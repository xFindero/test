----------------------------------
-- Script for Hunting Monsters near Nornil Cave 
--- v.4 2026-04-11	--added avoid attack other users general monsters *GetNearestByPriority(range, priorityType)
--- v.3 2026-04-09	--added PVP/PVE death reaction
----------------------------------
debug					= false
NxtTrgtDelay			= 5		-- in sec
NxtTrgtHP				= 70		-- in %
FightRange				= 5000	-- range to find monsters
farmTime				= 10		-- in min (farm time, then go to rest point)
weArePL					= false
stopFarm				= false
stopScript				= false
restartMovement			= false
returnPvPDelay			= 25		-- in munites, delay to keep in safe
avoidPlayersMobDist 	= 600
PLDistToFarmSolo	 	= 500
mytargetid				= 0
----------------------------------
LastNxtTrgt			= 0		-- time when it used for last time
moveNextCounter		= 0
lastChangeTime		= 0
--- Alt+B Heal
HealLastUsed		= 0
HealCooldown		= 60000          -- 60 секунд (1 хвилина)
HealHpPercent		= 90
HealMpPercent		= 50
HealCpPercent		= 90
----------------------------------
bonusHat 			= {31303, 31302 ,31301};  -- Brave Wolf Hat, Brave Piggy Hat, Brave Chick Hat
----------------------------------
buffID				= {1499, 1500, 1501, 1502, 1504}
	-- 1499	Improved Combat
	-- 1500	Improved Magic
	-- 1501	Improved Condition
	-- 1502	Improved Critical Attack
	-- 1504	Improved Movement
----------------------------------
keyName = "Maestro's Key" 
keyID = nil          --initial parametrs, will be set in HasKey func.
keyCount = 0         --initial parametrs, will be set in HasKey func.
noKeysLeft = false   --initial parametrs to avoid check invertory for keys at every start Targeting function
----------------------------------
RushSkills 		= {628, 998, 6292, 6296, 484, 994}  -- Warp-628, 998 - Blazing Boost, 484, 6292, 6296 - Rush, 994 Rush WLs
Rush 			= nil
RushDist 		= 450
-- ====================== GLOBAL SETTINGS ======================
blackList			= {"Treasure Chest", "Treasure Box","Bloodthirsty Punisher", "Pain Hunter", "Tortured Sinner", "Death Hound", "Merciless Punisher"}
highPriorityList	= {"Elite Envoy", "Dreadmaw", "Backbite", "Fleshreaper"}
lowPriorityList 	= {}
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
	local unstuckCounter = 0
	
	if restartMovement then return end
	ShowTrace(FVector(spotX, spotY, spotZ));
	-- Вимикаємо бота повністю на час руху (щоб не атакував мобів по дорозі)
	local wasPaused = IsPaused()
	if not wasPaused then
		SetPause(true)
	end
	--ShowToClient(os.date("%X"), "moveTo " .. spotX, 20)
    MoveToNoWait(spotX, spotY, spotZ)
	if Rush then
		--ShowToClient(os.date("%X"), "Rush from GotoSpot()", 20);
		Sleep(200)
		UseSkillH(Rush)
		MoveToNoWait(spotX, spotY, spotZ)
	end

    while (not arrived or not restartMovement) do
        Sleep(200)

        -- Перевірка смерті (дуже важливо викликати регулярно)
		-- Якщо персонаж загинув — checkDeath() вже обробив респ + місто
        -- Тому просто виходимо з GotoSpot повністю
		--ShowToClient(os.date("%X"), "GotoSpot. to checkDeath ", 20)
		if checkDeath() then
			restartMovement = true
			--ShowToClient(os.date("%X"), "restartMovement", 20)
			break
		else
			--ShowToClient(os.date("%X"), "Alive, move to next", 20)
		end
		--ShowToClient(os.date("%X"), "GotoSpot. to contrKill ", 20)
        contrKill()   -- захист від мобів - Low HP
		
        local currentTime = GetTime()
        local me = GetMe()
		--ShowToClient(os.date("%X"), "GotoSpot. to timeout ", 20)
        -- Таймаут руху (90 секунд максимум)
        if (currentTime - startTime) > 90000 then
            ShowToClient(os.date("%X"), "GotoSpot: Timeout (90s) - aborting", 20)
            break
        end

        -- Перевірка прибуття
        if me:GetRangeTo(spotX, spotY, spotZ) <= dist then
            --ShowToClient(os.date("%X"), "GotoSpot: Successfully arrived at target!", 20)
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
                if debug then ShowToClient(os.date("%X"), "GotoSpot: Stuck detected (" .. math.floor(distMoved) .. ") - unstuck", 20) end

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
		if unstuckCounter > 3 then
			restartMovement = true
			--ShowToClient(os.date("%X"), "restartMovement", 20)
			break
		end
		

        -- Якщо заблоковані: stun, root
        if me:IsBlocked(true) then
            ShowToClient(os.date("%X"), "GotoSpot: Blocked - fighting nearby mobs", 20)
            KillMons()
            Sleep(800)
        end
    end

    -- Фінальна очистка
    Sleep(700)
    contrKill()

    -- Повертаємо попередній стан паузи (якщо був увімкнений до виклику)
    if not wasPaused then
        SetPause(false)
    end

    --ShowToClient(os.date("%X"), "GotoSpot finished.", 20)
end

function contrKill()
	myHP = GetMe():GetHpPercent();
	--ShowToClient(os.date("%X"), "Check contrKill.",20);
	if ( myHP < 85 and  myHP > 0 ) then
		--ShowToClient(os.date("%X"), "Start contrKill.",20);
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
			end;
	end;
	return Rush
end;

function UseSkillH(skill)
	if ( skill ~= nil ) then
		local UseSkill = GetSkills():FindById(skill);
		if (UseSkill ~= nil) and (UseSkill:CanBeUsed()) then		
				UseSkillRaw(skill, false, false);
				--Command("/useshortcut 1 4");
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
        ShowToClient(os.date("%X"), "Invalid priorityType: " .. tostring(priorityType), 20)
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


            --ShowToClient(os.date("%X"), "Skip mob " .. mob:GetName() .. " - other player near " .. scippedPlayerMob, 20)
            goto continue
        end
----------------------------
        -- NEW: AVOID MONSTERS WITH BIG Z DIFFERENCE (floors / heights / under us)
        local mobZ = mob:GetLocation().Z
        local zDiff = math.abs(myZ - mobZ)

        if zDiff >= 150 then
            -- Optional debug (uncomment to see skipped ones)
            -- ShowToClient(os.date("%X"), "Skipped " .. mob:GetName() .. " - big Z diff (" .. math.floor(zDiff) .. ")", 20)
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
	--scippedPlayerMob = ""
    return nearestMob
end


-- ====================== LOW PRIORITY SPECIAL HANDLING ======================
-- (unchanged from previous version – only using the new unified finder)

function HandleLowPriorityChest(lowMob)
    local dist = lowMob:GetDistance()

    --ShowToClient(os.date("%X"), "LOW PRIORITY CHEST detected! Dist: " .. math.floor(dist), 20)

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
	--ShowToClient(os.date("%X"), "Find nearest attacking monster" , 20)
    local attacker = nil
    local attackerDist = 999999
    local monsterlist = GetMonsterList()

    for mob in monsterlist.list do
        local d = mob:GetDistance()
        if d >= 200 then goto cont2 end
        if mob:IsAlikeDeath() or mob:IsBlock() then goto cont2 end
		--ShowToClient(os.date("%X"), "monster near" , 20)
        -- Is attacking us? (adjust method if your L2Tower version differs)
        --local tgt = mob:GetTarget()
        if  mob:IsAttacking()  then
            if d < attackerDist then
                attackerDist = d
                attacker = mob
            end
        end
        ::cont2::
		--ShowToClient(os.date("%X"), "No monsters near" , 20)
    end

    if attacker ~= nil then
        --ShowToClient(os.date("%X"), "Defending vs attacker", 20)
        Target(attacker)
        return
	--else
		--ShowToClient(os.date("%X"), "not need to defend" , 20)
    end

    -- No attackers - open logic
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
	--ShowToClient(os.date("%X"), "TargetPriority. range: " .. range, 20)
    -- 1. HIGH priority first
	--ShowToClient(os.date("%X"), "HIGH priority first", 20)
    local high = GetNearestByPriority(range, "high")
    if high ~= nil then
		--ShowToClient(os.date("%X"), "HIGH mob near. " .. high:GetName())
		--Sound()
        ApproachAndTarget(high, range)
        return
	else
		--ShowToClient(os.date("%X"), "no HIGH mob near", 20)
    end

    -- 2. LOW priority (only if we have key)
	--ShowToClient(os.date("%X"), "LOW priority (only if we have key)", 20)
	if HasKey() then		-- запускається при кожному пошуку моба... бажано робобити 1 раз при запуску скрипта або з якоюсь періодичністю..
        local low = GetNearestByPriority(range, "low")
        if low ~= nil then
            HandleLowPriorityChest(low)
            return
		--else
			--ShowToClient(os.date("%X"), "no LOW mob near", 20)
        end
    end

    -- 3. GENERAL fallback
	if ( (GetMe():IsMyPartyMemberMaster() or weArePL ) and not stopFarm) then
		--ShowToClient(os.date("%X"), " GENERAL fallback, for PL only", 20)
		local general = GetNearestByPriority(1000, "general")
		if moveNextCounter > 2 then
			if debug then ShowToClient(os.date("%X"), " GENERAL fallback 3 times, move to start", 20) end
			moveToStart();
			moveNextCounter = 0
		else
			if general == nil then
				--ShowToClient(os.date("%X"), "No valid targets - moveToNext! [" .. moveNextCounter .. "]", 20)
				moveToNext()
				Sleep(400)
				moveNextCounter = moveNextCounter + 1
				return
			end
		end

		ApproachAndTarget(general, range)
	--else
		--ShowToClient(os.date("%X"), "Not targeting general mobs, I'm not PL", 20)
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
	local target = GetTarget()
	if target then 
		mytargetid = target:GetId()
	else
		mytargetid = 0
	end
	local tid = mob:GetId()
	
	if mytargetid == tid then
		if debug then ShowToClient(os.date("%X"), "The same target, skip", 20) end
		return
	else
		if debug then ShowToClient(os.date("%X"), "new target, get ID", 20) end
        mytargetid = tid
    end
	-------
	local useRush = false

    local dist = mob:GetDistance()
    local offsetX, offsetY, sleepAfter = 0, 0, 0

    if dist > 300 then
		if dist <= 500 then
			offsetX = math.random(10, 30)
			offsetY = math.random(5, 20)
			sleepAfter = 100
		elseif dist <= 1000 then
			offsetX = math.random(30, 90)
			offsetY = math.random(50, 100)
			sleepAfter = 550
			useRush = true
		else
			offsetX = math.random(150, 250)
			offsetY = math.random(50, 150)
			sleepAfter = 1300
			useRush = true
		end

		local tx = mob:GetLocation().X + offsetX
		local ty = mob:GetLocation().Y + offsetY
		local tz = mob:GetLocation().Z

		MoveToNoWait(tx, ty, tz)
		-------------
		if useRush and Rush then
			Sleep(200)
			UseSkillH(Rush)
			MoveToNoWait(tx, ty, tz)
			Sleep(sleepAfter)
		else
			Sleep(sleepAfter)
		end		
	end
	-------------
    Target(mob)
    Sleep(250)

    
    if target == nil then
        moveToNext()
        return
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
	
	if debug then ShowToClient(os.date("%X"), "Life-hack = try to move somewhere", 20) end
    MoveToNoWait(tx, ty, tz)
	Sleep(3210)
end

function toSafePlace()
	local moveDistance	= 250
	SetPause(true);
	if 	( GetMe():GetRangeTo(-90942, 39931, -2363) < 2000 )	then	--на перехресті під горою біля каменю
		ShowToClient(os.date("%X"), "move to big Rock", 20);
		GotoSpot(-91206, 40431, -2308, moveDistance);
		GotoSpot(-91154, 40382, -2312, moveDistance);
		GotoSpot(-91157, 40393, -2312, moveDistance);
		GotoSpot(-91292, 40528, -2297, moveDistance);
		GotoSpot(-91525, 40550, -2278, moveDistance);
		GotoSpot(-91834, 40574, -2262, moveDistance);
		GotoSpot(-92026, 40720, -2209, moveDistance);
		GotoSpot(-92103, 40834, -2126, moveDistance);
		GotoSpot(-92029, 40927, -2073, moveDistance);
		GotoSpot(-91933, 41003, -2050, moveDistance);
		GotoSpot(-91840, 40992, -2050, moveDistance);
		moveDistance	= 50
		GotoSpot(-91764, 41071, -2075, moveDistance);
		GotoSpot(-91866, 40985, -2059, moveDistance);
		GotoSpot(-91916, 40979, -2073, moveDistance);
		GotoSpot(-91867, 40976, -2055, moveDistance);
		GotoSpot(-91823, 40981, -2036, moveDistance);
		GotoSpot(-91774, 41014, -2041, moveDistance);
		GotoSpot(-91747, 41049, -2069, moveDistance);
		GotoSpot(-91754, 41064, -2076, moveDistance);
		GotoSpot(-91757, 41058, -2071, moveDistance);
		Sleep(7000)
		KillMons()
	elseif 	( GetMe():GetRangeTo(-93453, 39495, -2399) < 1500 ) then		--на в середині хвоста, між перехрестям і горкою з мобами
		ShowToClient(os.date("%X"), "Near Tail - mobs hil, go to great Hil", 20);
		GotoSpot(-94533, 39337, -2468, moveDistance);
		GotoSpot(-95712, 39633, -2455, moveDistance);
		GotoSpot(-96626, 39853, -2410, moveDistance);
		GotoSpot(-97455, 39892, -2413, moveDistance);
		GotoSpot(-98305, 40182, -2347, moveDistance);
		GotoSpot(-98204, 40563, -2211, moveDistance);
		GotoSpot(-98663, 41047, -1912, moveDistance);
		GotoSpot(-98510, 41467, -1618, moveDistance);
		GotoSpot(-98276, 42094, -1314, moveDistance);
		GotoSpot(-98062, 41975, -1443, moveDistance);
		GotoSpot(-97546, 41947, -1528, moveDistance);
		GotoSpot(-97105, 42016, -1419, moveDistance);
		GotoSpot(-96500, 42577, -1148, moveDistance);
		GotoSpot(-96262, 42563, -993, moveDistance);
		GotoSpot(-95860, 42513, -921, moveDistance);
		GotoSpot(-95547, 42450, -905, moveDistance);
		GotoSpot(-94643, 42275, -1191, moveDistance);
		GotoSpot(-94297, 42152, -1298, moveDistance);
		GotoSpot(-94239, 42121, -1311, moveDistance);
		GotoSpot(-93945, 42068, -1463, moveDistance);
		GotoSpot(-93678, 41947, -1417, moveDistance);
		GotoSpot(-93304, 41853, -1353, moveDistance);
		GotoSpot(-93096, 41766, -1334, moveDistance);
		deltaMove()
	---------------------------
	elseif 	( GetMe():GetRangeTo(-93096, 41766, -1334) < 500 ) then		--на горі
		ShowToClient(os.date("%X"), "on safe place", 20);
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-89012, 33372, -2504) < 2600 ) then		--між перехрестям і хардом
		ShowToClient(os.date("%X"), "Near HARD", 20);
		GotoSpot(-87836, 39672, -2528, moveDistance);
		GotoSpot(-88178, 39678, -2531, moveDistance);
		GotoSpot(-88600, 39696, -2518, moveDistance);
		GotoSpot(-88874, 39919, -2417, moveDistance);
		GotoSpot(-89161, 40561, -2323, moveDistance);
		GotoSpot(-89286, 40500, -2297, moveDistance);
		GotoSpot(-89364, 40588, -2189, moveDistance);
		GotoSpot(-89600, 40674, -2046, moveDistance);
		GotoSpot(-89883, 40858, -1936, moveDistance);
		deltaMove()
		Sleep(7000)
		KillMons()
	elseif 	( GetMe():GetRangeTo(-91066, 38798, -3464) < 1600 ) then		--біля Перехрестя
		ShowToClient(os.date("%X"), "Not far from TP - Cross - move to Wratfull", 20);
		GotoSpot(-92072, 38735, -2447, moveDistance);
		GotoSpot(-92784, 38877, -2468, moveDistance);
		GotoSpot(-93623, 38956, -2472, moveDistance);
		GotoSpot(-94165, 39033, -2470, moveDistance);
		GotoSpot(-94541, 39117, -2467, moveDistance);
		GotoSpot(-95094, 39325, -2467, moveDistance);
		GotoSpot(-95800, 39511, -2457, moveDistance);
		GotoSpot(-96727, 39653, -2417, moveDistance);
		GotoSpot(-97254, 39604, -2411, moveDistance);
		GotoSpot(-98516, 39152, -2211, moveDistance);
		GotoSpot(-98465, 39198, -2238, moveDistance);
		deltaMove()
		
	elseif 	( GetMe():GetRangeTo(-94070, 39609, -2426) < 1200 ) then		--в хвості за перехрестям
		ShowToClient(os.date("%X"), "Not far from - Cross - tail", 20);
		GotoSpot(-95997, 40127, -2357, moveDistance);
		GotoSpot(-95921, 40068, -2388, moveDistance);
		GotoSpot(-96007, 39833, -2425, moveDistance);
		GotoSpot(-96868, 39791, -2412, moveDistance);
		GotoSpot(-98470, 39551, -2385, moveDistance);
		GotoSpot(-98628, 39185, -2205, moveDistance);
		deltaMove()	
	elseif 	( GetMe():GetRangeTo(-99652, 39215, -2418) < 1000 ) then		--в хвості
		ShowToClient(os.date("%X"), "Not far fom tail", 20);
		deltaMove()	

	elseif 	( GetMe():GetRangeTo(-86516, 37011, -2054) < 2500 ) then		--біля ТП 
		ShowToClient(os.date("%X"), "move to rest point betwen Hard and Cross", 20);
		------------ point betwen Hard and Cross
		GotoSpot(-86842, 37007, -2116, moveDistance);
		GotoSpot(-87009, 37066, -2123, moveDistance);
		GotoSpot(-87165, 37494, -2044, moveDistance);
		GotoSpot(-87360, 37754, -1998, moveDistance);
		GotoSpot(-87595, 38883, -2354, moveDistance);
		GotoSpot(-88288, 39639, -2529, moveDistance);
		GotoSpot(-88745, 40011, -2418, moveDistance);
		GotoSpot(-89127, 40354, -2366, moveDistance);
		GotoSpot(-89150, 40664, -2305, moveDistance);
		GotoSpot(-89244, 40800, -2208, moveDistance);
		GotoSpot(-89449, 40778, -2070, moveDistance);
		GotoSpot(-89692, 40786, -1982, moveDistance);
		GotoSpot(-89871, 40862, -1930, moveDistance);
		GotoSpot(-90020, 40890, -1926, moveDistance);
		GotoSpot(-91020, 40890, -1926, moveDistance);
		GotoSpot(-89960, 40952, -1926, moveDistance);
		deltaMove()
		Sleep(7000)
		KillMons()
	---------------------------
	else
		ShowToClient(os.date("%X"), "move to our safe place", 20);
		moveDistance = 250;
		--
		while ( GetMe():IsInCombat() ) do
			if debug then ShowToClient("[Escape] ", " InCombat: ".. tostring(GetMe():IsInCombat()),20) end
			KillMons()
			Sleep(1432)
		end
		
		tpToKamael()
		Sleep(1321)
		if ( GetMe():GetRangeTo(-116901, 46601, 366) < 500 ) then
			TPtoMid()
			-----------
			local tpCounter = 0
			while ( GetMe():GetRangeTo(-116901, 46601, 366) < 500 ) do
				ShowToClient(os.date("%X"), "We can't teleport",20);
				Sound() 
				TPtoMid()
				tpCounter = tpCounter +1
				Sleep(15000)
				if tpCounter > 3 then
					ShowToClient(os.date("%X"), "We can't teleport, Break",20);
					break
				end
			end
			-----------
			if ( GetMe():GetRangeTo(-86516, 37011, -2054) < 1000 ) then
				GotoSpot(-86516, 37011, -2054, moveDistance);
				GotoSpot(-86569, 36983, -2054, moveDistance);
				GotoSpot(-88319, 37115, -2197, moveDistance);
				GotoSpot(-89689, 37624, -2278, moveDistance);
				GotoSpot(-90242, 37974, -2317, moveDistance);
				GotoSpot(-91987, 38886, -2458, moveDistance);
				GotoSpot(-92749, 39086, -2475, moveDistance);
				GotoSpot(-93684, 39138, -2475, moveDistance);
				GotoSpot(-94533, 39337, -2468, moveDistance);
				GotoSpot(-95712, 39633, -2455, moveDistance);
				GotoSpot(-96626, 39853, -2410, moveDistance);
				GotoSpot(-97455, 39892, -2413, moveDistance);
				GotoSpot(-98305, 40182, -2347, moveDistance);
				GotoSpot(-98204, 40563, -2211, moveDistance);
				GotoSpot(-98663, 41047, -1912, moveDistance);
				GotoSpot(-98510, 41467, -1618, moveDistance);
				GotoSpot(-98276, 42094, -1314, moveDistance);
				GotoSpot(-98062, 41975, -1443, moveDistance);
				GotoSpot(-97546, 41947, -1528, moveDistance);
				GotoSpot(-97105, 42016, -1419, moveDistance);
				GotoSpot(-96500, 42577, -1148, moveDistance);
				GotoSpot(-96262, 42563, -993, moveDistance);
				GotoSpot(-95860, 42513, -921, moveDistance);
				GotoSpot(-95547, 42450, -905, moveDistance);
				GotoSpot(-94643, 42275, -1191, moveDistance);
				GotoSpot(-94297, 42152, -1298, moveDistance);
				GotoSpot(-94239, 42121, -1311, moveDistance);
				GotoSpot(-93945, 42068, -1463, moveDistance);
				GotoSpot(-93678, 41947, -1417, moveDistance);
				GotoSpot(-93304, 41853, -1353, moveDistance);
				GotoSpot(-93096, 41766, -1334, moveDistance);
				deltaMove()
			else
				while ( IsPaused() ) do
				ShowToClient(os.date("%X"), "We not on spot!",20);
				Sound();
				Sleep(30000)
			end
			end
		else
			ShowToClient(os.date("%X"), "Where you ARE?",20);
		end
	end
end;

function TPtoMid()
	if debug then ShowToClient(os.date("%X"), "In Kamael on TP, tp to MID",20) end
	GotoSpot(-116901, 46601, 366, 100)
	TargetNpc("Ragara", 32163);
	Sleep(1000)
	Talk()
	Sleep(2000)
	ClickText("Teleport");
	Sleep(1421)
	ClickText("Stronghold III");
	Sleep(4321)
end

function deltaMove()
	--ShowToClient(os.date("%X"), "Delta step...",20);
	local tx = GetMe():GetLocation().X + math.random(-30, 30)+ ((string.sub(MyID,-2))/2)
	local ty = GetMe():GetLocation().Y + math.random(-30, 30)
	MoveToNoWait(tx, ty, GetMe():GetLocation().Z);
end

function tpToKamael()
	ShowToClient(os.date("%X"), "tp to Kamael >>",20);
	ClickAndWait("_bbshome", "");
	ClickAndWait("voice .teleporterservice h scl", "");
	ClickAndWait("voice .teleporterservice h sl STC_OTHER_LOCATIONS", "");
	ClickAndWait("voice .teleporterservice t s S_L2U_KAMAEL_VILLAGE STC_OTHER_LOCATIONS", "");
	while ( GetMe():GetRangeTo(-116901, 46601, 366) > 500 ) do
		Sleep(1500)
		if debug then ShowToClient(os.date("%X"), "wait", 20) end
		while ( GetMe():IsInCombat() ) do
			if debug then ShowToClient("[Escape] ", " InCombat: ".. tostring(GetMe():IsInCombat()),20) end
			KillMons()
			Sleep(1432)
		end
	end
end

function tpFromKamael()
	local moveDistance = 250
	local tpCounter = 0
		if ( GetMe():GetRangeTo(-116901, 46601, 366) < 1500 ) then
			TPtoMid()
			-----------
			while ( GetMe():GetRangeTo(-116901, 46601, 366) < 500 ) do
				ShowToClient(os.date("%X"), "We can't teleport",20);
				Sound() 
				TPtoMid()
				tpCounter = tpCounter +1
				Sleep(10000)
				if tpCounter > 3 then
					ShowToClient(os.date("%X"), "We can't teleport, Break",20);
					break
				end
			end
			-----------
			if ( GetMe():GetRangeTo(-86516, 37011, -2054) < 1000 ) then
				GotoSpot(-86927, 37032, -2118, moveDistance);
				GotoSpot(-88168, 37246, -2190, moveDistance);
				GotoSpot(-89445, 37515, -2262, moveDistance);
				GotoSpot(-90461, 37828, -2360, moveDistance);
				GotoSpot(-91478, 38404, -2422, moveDistance);
				--перехрестя
				GotoSpot(-91436, 38822, -2456, moveDistance);
				deltaMove()
				-------------
			else
				while ( IsPaused() ) do
				ShowToClient(os.date("%X"), "We not on spot!",20);
				Sound();
				Sleep(30000)
				end
			end
		end
end

function unstuckFromRocks()
	local result = false
	local moveDistance	= 250
	SetPause(true)
	
	if 	( GetMe():GetRangeTo(-88274, 36324, -2091) < 500 ) then		
		ShowToClient(os.date("%X"), "Near First Tree", 20);
		GotoSpot(-89046, 37981, -2263, moveDistance);
		GotoSpot(-89059, 38005, -2269, moveDistance);
		GotoSpot(-90122, 39230, -2491, moveDistance);
		result = true
	elseif 	( GetMe():GetRangeTo(-89066, 36025, -2139) < 500 ) then	
		ShowToClient(os.date("%X"), "Near First Rock", 20);
		GotoSpot(-89046, 37981, -2263, moveDistance);
		GotoSpot(-89059, 38005, -2269, moveDistance);
		GotoSpot(-90122, 39230, -2491, moveDistance);
		result = true
	elseif 	( GetMe():GetRangeTo(-89534, 35888, -2191) < 500 or GetMe():GetRangeTo(-89928, 36615, -2219) < 300 or
			  GetMe():GetRangeTo(-90766, 36984, -2265) < 300 or GetMe():GetRangeTo(-91347, 37335, -2264) < 300 or
			  GetMe():GetRangeTo(-91969, 37641, -2345) < 300 or GetMe():GetRangeTo(-92381, 38020, -2376) < 300 ) then	
		ShowToClient(os.date("%X"), "Near other Trees", 20);
		GotoSpot(-89524, 38629, -2408, moveDistance);
		GotoSpot(-90122, 39230, -2491, moveDistance);
		result = true
	else
		ShowToClient(os.date("%X"), "unstuckFromRocks. unknown place, try to move 1-2 step", 20);
		GotoSpot(-91593, 38866, -2462, moveDistance);	--перехрестя	
	end
	ClearT()
	SetPause(false);
	return result
end

function moveToStart()
	restartMovement = false
	SetPause(true);
	local moveDistance	= 250
	if 	( GetMe():GetRangeTo(-91593, 38866, -2462) < 600 ) then		--на перехресті
		if debug then ShowToClient(os.date("%X"), "At start point", 20) end
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-88240, 38756, -2392) < 3000 ) then		--між перехрестям і хардом
		if debug then ShowToClient(os.date("%X"), "Not far from start point - close to Hard", 20) end
		GotoSpot(-91593, 38866, -2462, moveDistance);
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-91824, 40903, -2014) < 1000 ) then		--на великому камені біля перехрестя
		if debug then ShowToClient(os.date("%X"), "On a Rock near Cross", 20)end
		GotoSpot(-91763, 41069, -2075, moveDistance);
		GotoSpot(-91887, 40966, -2057, moveDistance);
		GotoSpot(-91919, 41021, -2041, moveDistance);
		GotoSpot(-91981, 40932, -2089, moveDistance);
		GotoSpot(-92038, 40831, -2141, moveDistance);
		GotoSpot(-92012, 40765, -2187, moveDistance);
		GotoSpot(-91932, 40494, -2278, moveDistance);
		GotoSpot(-91676, 39693, -2356, moveDistance);
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-116901, 46601, 366) < 1500 ) then		-- на ТП в Камаелі
		if debug then ShowToClient(os.date("%X"), "TP Kamael", 20) end
		tpFromKamael()
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-90799, 40586, -2308) < 2000 ) then		--від перехрестя під гору
		if debug then ShowToClient(os.date("%X"), "Not far from Cross", 20)end
		GotoSpot(-89332, 39225, -2496, moveDistance);
		GotoSpot(-89143, 39003, -2441, moveDistance);
		GotoSpot(-88984, 38440, -2352, moveDistance);
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-92787, 40453, -2255) < 2200 ) then		--біля перехрестя, праворуч від каменю
		if debug then ShowToClient(os.date("%X"), "Near Cross, to right from Rock", 20) end
		GotoSpot(-92595, 40208, -2301, moveDistance);
		GotoSpot(-91628, 38891, -2460, moveDistance);
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-88935, 37620, -2200) < 1600 ) then		--між ТП і перехрестям
		if debug then ShowToClient(os.date("%X"), "Not far from TP - Cross", 20) end
		GotoSpot(-90461, 37828, -2360, moveDistance);
		GotoSpot(-91478, 38404, -2422, moveDistance);
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-98465, 39198, -2238) < 1600 ) then		--біля Wratfull
		if debug then ShowToClient(os.date("%X"), "Not far from Wratfull - move to Cross", 20) end
		GotoSpot(-98516, 39152, -2211, moveDistance);
		GotoSpot(-97254, 39604, -2411, moveDistance);
		GotoSpot(-95267, 39634, -2460, moveDistance);
		GotoSpot(-94328, 39340, -2465, moveDistance);
		GotoSpot(-93551, 39159, -2475, moveDistance);
		GotoSpot(-92197, 38888, -2466, moveDistance);
		GotoSpot(-91381, 38792, -2461, moveDistance);
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-93096, 41766, -1334) < 500 ) then		--на горі
		if debug then ShowToClient(os.date("%X"), "on safe place, go to 1", 20) end
		local moveDistance	=	50
		GotoSpot(-93096, 41766, -1334, moveDistance);
		GotoSpot(-92996, 41709, -1348, moveDistance);
		GotoSpot(-92910, 41489, -1354, moveDistance);
		GotoSpot(-92622, 41067, -1642, moveDistance);
		GotoSpot(-92481, 40325, -2292, moveDistance);
		GotoSpot(-91593, 38866, -2462, moveDistance);
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-94070, 39609, -2426) < 1200 ) then		--в хвості за перехрестям
		if debug then ShowToClient(os.date("%X"), "Not far fom - Cross - tail", 20) end 
		GotoSpot(-94025, 39326, -2465, moveDistance);
		GotoSpot(-94011, 39299, -2469, moveDistance);
		GotoSpot(-92632, 39026, -2475, moveDistance);
		GotoSpot(-91525, 38826, -2460, moveDistance);
		deltaMove()	
	elseif 	( GetMe():GetRangeTo(-99652, 39215, -2418) < 1000 ) then		--в хвості
		if debug then ShowToClient(os.date("%X"), "Not far fom - Cross - tail", 20) end
		GotoSpot(-99563, 39563, -2408, moveDistance);
		GotoSpot(-98721, 39821, -2399, moveDistance);
		GotoSpot(-97471, 39842, -2414, moveDistance);
		GotoSpot(-95395, 39637, -2461, moveDistance);
		GotoSpot(-94025, 39326, -2465, moveDistance);
		GotoSpot(-94011, 39299, -2469, moveDistance);
		GotoSpot(-92632, 39026, -2475, moveDistance);
		GotoSpot(-91525, 38826, -2460, moveDistance);
		deltaMove()
	elseif 	( GetMe():GetRangeTo(-89960, 40952, -1926) < 1200 ) then		--на гірці біля Харду
		if debug then ShowToClient(os.date("%X"), "Not far fom - Cross - tail", 20) end
		GotoSpot(-90128, 39244, -2491, moveDistance);
		GotoSpot(-90132, 39314, -2488, moveDistance);
		GotoSpot(-90262, 39159, -2491, moveDistance);
		deltaMove()	

	elseif 	( GetMe():GetRangeTo(-86516, 37011, -2054) < 2500 ) then		--біля ТП
		if debug then ShowToClient(os.date("%X"), "Near TP - move to Cross", 20) end
		GotoSpot(-86927, 37032, -2118, moveDistance);
		GotoSpot(-88168, 37246, -2190, moveDistance);
		GotoSpot(-89445, 37515, -2262, moveDistance);
		GotoSpot(-90461, 37828, -2360, moveDistance);
		GotoSpot(-91478, 38404, -2422, moveDistance);
		--перехрестя
		deltaMove()
	else
		ShowToClient(os.date("%X"), "unknown place, teleport", 20);
		while ( GetMe():IsInCombat() ) do
			if debug then ShowToClient("[Escape] ", " InCombat: ".. tostring(GetMe():IsInCombat()),20) end
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
        ShowToClient(os.date("%X"), "In town after death - skip KillMons", 20)
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
		
		--ShowToClient(os.date("%X"), "Find attacker" , 20)
		for mob in monsterlist.list do
			local d = mob:GetDistance()
			if d >= 300 then goto cont1 end
			if mob:IsAlikeDeath() or mob:IsBlock() then goto cont1 end
			--ShowToClient(os.date("%X"), "monster " .. mob:GetName() .. " [".. mob:GetDistance() .."]", 20)
			if  mob:IsAttacking()  then
				--ShowToClient(os.date("%X"), "monster " .. mob:GetName() .. " [".. mob:GetDistance() .."] Is attacking: " .. tostring(mob:IsAttacking()), 20)
				if d < attackerDist then
					attackerDist = d
					attacker = mob
				end
			end
			::cont1::
			--ShowToClient(os.date("%X"), "No monsters near" , 20)
		end

		if attacker ~= nil then
			--ShowToClient(os.date("%X"), "Defending vs attacker: " .. attacker:GetName(), 20)
			Target(attacker)
			SetPause(false);
		else
			--ShowToClient(os.date("%X"), "not need to defend. no Agro mobs near" , 20)
			stopDefence = true
		end
		Sleep(5432)
	end
	--ShowToClient(os.date("%X"), "All agro monsters cleared" , 20)
	SetPause(true);
end

function checkIdle(startTime)
	local result = false
	if (GetTime() - startTime >= farmTime*60000) then
		ShowToClient(os.date("%X"), "Time to finish. Go to Safe place",20);
		stopFarm	= true
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
        -- Додаткова перевірка: якщо довго не рухався — повертаємося на старт
		if not weArePL then
			timeout = 2 * timeout
		end
		
		if weArePL then
			if not unstuckFromRocks() then
				moveToNext()          -- спочатку пробуємо локальний unstuck (якщо є така функція)
			end
		else
			--ShowToClient(os.date("%X"), "Assist to PL " .. (timeout/1000), 20);
			--Command("/useshortcut 1 3");
			Command("/target wild");
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
        -- === Персонаж рухався нормально ===
        lastChangeTime = currentTime
    end
end

function checkDeath()
	
	if not GetMe():IsAlikeDeath() then
		return false 
	end
    ShowToClient(os.date("%X"), "DIED during farm", 20)
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
	
	-------------------------------
	if IsPaused() then
		SetPause(false)
	end
	
    local deathTime = GetTime()
    while GetMe():IsAlikeDeath() and (GetTime() - deathTime < 60000) do
        Sleep(5000)
    end
	if GetMe():IsAlikeDeath() then -- try to return manualy
		RequestRestartPoint(2); --- To Village
		Sleep(5000)
	end
    if GetMe():IsAlikeDeath() then
        ShowToClient(os.date("%X"),"Failed to resurrect in time", 20)
        return false
    end
	SetPause(true)	-- відключаємо все що може заважати в процесі переміщення до Farm Spot
    -- === ВИЗНАЧЕННЯ PvP vs PvE ===
	local me = GetMe()
    local isPvPDeath = (me:GetCpPercent() < 50) or me:IsPvPFlag() or me:IsPvPFlagBlink() or pvpNear
    if isPvPDeath then
        ShowToClient(os.date("%X"), "=== PvP DEATH DETECTED === Stopping all scripts")
        Sound()
		startDelay = (returnPvPDelay*60000 + math.random(-30000, 60000));
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
	Rebuff()
    LastHatCheck = GetTime()
    startTime = GetTime()
	moveToStart()
	return true
end

function somethingWeird()
	while ( GetMe():IsInCombat() ) do
		if debug then ShowToClient("[Escape] ", " InCombat: ".. tostring(GetMe():IsInCombat()),20) end
		KillMons()
		Sleep(1432)
	end
	if (GetMe():IsAlikeDeath()) then
		ShowToClient("somethingWeird", "Person is dead...go to town",20);
		RequestRestartPoint(2); --- To Village
	end
	ShowToClient(os.date("%X"), "Something went wrong! Logout", 20);
	--Log("Something went wrong! Logout");
end

function Rebuff()
	local result = false
	Command(".buffset FFA")
	Sleep(3000)
	result = WeHaveBuff()
	if not result then
		somethingWeird()
	else
		HealthCheck()
	end

	return result
end

function WeHaveBuff()
	local BUFF_RENEW_SEC = 60
	local result = true;
	local me = GetMe();

  if me:IsAlikeDeath() then
    ShowToClient(os.date("%X"), "Murdered", 20);
    return false;
  end

  for i = 1, #buffID do
    if not me:GotBuff(buffID[i]) then
      ShowToClient(os.date("%X"),"We Have No Buff " .. buffID[i] .. " ",20)
      result = false;
    else
      local buff = me:GetBuff(buffID[i]);
      local timeToEnd = math.floor((buff.endTime - GetTime())/1000);
      if timeToEnd < BUFF_RENEW_SEC then 
		 ShowToClient(os.date("%X"), "Buff ends in few sec", 20);
        result = false;
      end
    end
  end
  return result;
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

            if dist > PLDistToFarmSolo then
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


function escapeDeath()
    -- HP life-hack
    local me = GetMe()
    if me:GetHpPercent() <= NxtTrgtHP and (GetTime() - LastNxtTrgt or 0) > (NxtTrgtDelay * 1000) then
        LastNxtTrgt = GetTime()
        ShowToClient(os.date("%X"), "Low HP - next target", 20)
        Command("/useshortcut 1 1")
    end
end

function HealthCheck()
    local me = GetMe()
    if me == nil then return end

    local timeNow = GetTime()
    local delta   = timeNow - HealLastUsed

    -- Перевіряємо, чи потрібно хілитись
    if (me:GetHpPercent() <= HealHpPercent or me:GetMpPercent() <= HealMpPercent or me:GetCpPercent() <= HealCpPercent) and not me:IsInCombat() and delta >= HealCooldown then
        --ShowToClient("#", string.format("HealthCheck: Restoring HP/MP/CP (%.0f sec since last)", delta/1000), 20)
        -- Виконуємо Alt+B → Buffer → Restore
        ClickAndWait("_bbshome", "")
        ClickAndWait("voice .bufferservice", "")
        ClickAndWait("voice .bufferservice t p h", "")   -- t p h = твоя команда на відновлення
        HealLastUsed = GetTime()
    else
		ShowToClient("#", string.format("HealthCheck: Restoring HP/MP/CP (%.0f sec since last) not Need", delta/1000), 20)
	end
end

function CheckPVP()
	local me = GetMe()
    local isPvP = (me:GetCpPercent() < 50) or me:IsPvPFlag() or me:IsPvPFlagBlink()
	
	if isPvP then
		ShowToClient(os.date("%X"), "PVP detected - going to safe place", 20);
		toSafePlace();
		SleepTime = returnPvPDelay*60000 + math.random(-math.floor(returnPvPDelay/5), math.floor(returnPvPDelay/5))*60000
		ShowToClient(os.date("%X"), "Farm paused for " .. math.floor((SleepTime/1000)/60) .. " min", 20);
		Sleep(SleepTime);
		moveToStart();
		startTime = GetTime();
	end
end

--- MAIN ---
ShowToClient(os.date("%X"), "Start Nornil Farm", 20);
ShowToClient(os.date("%X"), "Farm time: " .. farmTime .. " min", 20);

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

ActivateSoulShot(1467,true)	--1467	Soulshot (S-Grade)
ActivateSoulShot(3952,true)	--3952	Blessed Spiritshot (S-Grade)

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
end
if Rebuff() then	-- якщо в нас є баф, ми можемо йти фармити.
	if ( GetMe():GetRangeTo(-90470,38701,-2424) > 2400 ) then		--в Міду точка в центрі неподалік перехрестя
		moveToStart();                     							-- перший раз йдемо на спот
	end

	----------- Старт скрипта
	SetPause(false)
	----------

	if weArePL then
		Command("/invite Axy");
		Sleep(500);
	end

	local isPausedPreviously = false   -- змінна для відстеження стану паузи

	while not stopScript do

		-- === ОБРОБКА СМЕРТІ ===
		if checkDeath() or restartMovement then
			ShowToClient(os.date("%X"), "Start moveToStart if Died or restartMovement");
			restartMovement = false
			moveToStart()
			Sleep(1500)
		end
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
			escapeDeath()
			if (GetTime() - LastHatCheck > 60*1000) then
				BonusHatOn()
				CheckParty()
				LastHatCheck = GetTime();
			end
			

			if checkIdle(startTime) then
				ShowToClient("#", "Time to go to the safe place", 20);
				toSafePlace();
				stopScript = true
				ShowToClient(os.date("%X"), "Farm RB Finished ", 20);
			else
				local MyTarget = GetTarget();
				if ( MyTarget and MyTarget:IsMonster() and MyTarget:IsAlikeDeath()) then
					ClearT()
				elseif MyTarget and MyTarget:IsMonster() then
					if MyTarget:GetDistance() >= RushDist and Rush then
						UseSkillH(Rush);
					end
				end
				TargetPriority(FightRange)
			end
			------------------
		end
		-- Затримка циклу
		Sleep(2800 + math.random(-800, 2200));
	end
else
	ShowToClient(os.date("%X"), "We have no Buff", 20);
	somethingWeird()
	tpToKamael()
	deltaMove()
end	
SetPause(true);
Command("/cp");