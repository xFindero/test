----------------------------------
-- Script for farming RB in Kamaloka 
-- p.def без дебафу	24 258, з дебафом 8 247,  
-- m.def без дебафу	 3 955, з дебафом 1 344, 
----------------------------------
NxtTrgtDelay	=	10		-- in sec
NxtTrgtHP		=	70		-- in %
LastNxtTrgt		=	0		-- time when it used for last time
FightRange		=	1400	-- range to find monsters
idleTime		=	60		-- in min (inactivity time, go to rest point)
stopScript		=	false
weArePL			=	false
atSpot0		=	false
atSpot1		=	false
atSpot2		=	false
atSpot3		=	false
----------------------------------
--- Alt+B Heal
HealLastUsed       = 0
HealCooldown       = 60000          
HealHpPercent      = 90
HealMpPercent      = 50
HealCpPercent      = 90
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
RushSkills				=	{628, 998, 6292, 6296, 484, 994}	-- Warp-628, 998 - Blazing Boost, 484, 6292, 6296 - Rush, 994 Rush WLs
FocusAttack				=	317									-- Focus Attack WL
Rush					=	nil
RushDist				=	550
-- ====================== GLOBAL SETTINGS ======================
blackList			=	{"Lost Warden"}
highPriorityList	=	{"Lost Assistant Guard"}
secondPriorityList	=	{"Lost Guard"}
octagonPoints	= {}				-- Масив точок восьмикутника
----------------------------------

CheckSoundDC = GetDir() .. "\\sound\\found.wav";
function Sound()
	if PlaySound(CheckSoundDC) then
		return true
	else
		ShowToClient(os.date("%X"), "Fail to play sound!", 20)
		return false
	end
end

function TranslitCoded(str)
    if not str or type(str) ~= "string" or str == "" then 
        return "-" 
    end
	-- Спочатку перевіряємо, чи є в ніку хоча б один "латиничний" байт
	local isLatinic = false
	local mapBytes = {
		74, 75, 80, 81, 82, 83, 85, 88, 89, 90, 97, 98, 99, 100,
		101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
		112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122 
    }
	for i = 1, #str do
        local byte = string.byte(str, i)
        for _, latByte in ipairs(mapBytes) do
            if byte == latByte then
                isLatinic = true
                break
            end
        end
        if isLatinic then break end
    end
	-- Якщо це Латина (немає жодного кириличного байту) — повертаємо як є
    if isLatinic then
        return str
    end
	-----------------

    -- === Якщо це кирилиця — виконуємо транслітерацію ===
    local result = {}

    for i = 1, #str do
        local byte = string.byte(str, i)

        local map = {
            [16] = "A",  [17] = "B",  [18] = "V",  [19] = "G",
            [20] = "D",  [21] = "E",  [22] = "Zh", [23] = "Z",
            [24] = "I",  [25] = "Y",  [26] = "K",  [27] = "L",
            [28] = "M",  [29] = "N",  [30] = "O",  [31] = "P",
            [32] = "R",  [33] = "S",  [34] = "T",  [35] = "U",
            [36] = "F",  [37] = "H",  [38] = "Ts", [39] = "Ch",
            [40] = "Sh", [41] = "Sch",[44] = "'",  [46] = "Yu",
            [47] = "Ya",

            [48] = "a",  [49] = "b",  [50] = "v",  [51] = "g",
            [52] = "d",  [53] = "e",  [54] = "zh", [55] = "z",
            [56] = "i",  [57] = "y",  [58] = "k",  [59] = "l",
            [60] = "m",  [61] = "n",  [62] = "o",  [63] = "p",
            [64] = "r",  [65] = "s",  [66] = "t",  [67] = "u",
            [68] = "f",  [69] = "h",  [70] = "ts", [71] = "ch",
            [72] = "sh", [73] = "sch",[76] = "'",  [78] = "yu",
            [79] = "ya",

            [4]  = "Ye", [6]  = "I",  [7]  = "Yi", [84] = "ye",
            [86] = "i",  [87] = "yi"
        }

        table.insert(result, map[byte] or string.char(byte))
    end

    -- Додаємо мітку, що це було перетворено з кирилиці (можна прибрати пізніше)
    table.insert(result, "~")

    return table.concat(result)
end

function ClickAndWait(link, name)
	QuestReply(link)
	Sleep(821)
end

function ClearT()
	ClearTargets()
	CancelTarget(true)
	Sleep(123)
	ClearTargets()
end

function checkRushSkill(Skills)
	for i = 1, #Skills do
		local skill = GetSkills():FindById(Skills[i])
		if skill ~= nil then
			return Skills[i]
		end
	end
	return nil
end

function UseSkillH(skill)
	if skill == nil then return end
	local UseSkill = GetSkills():FindById(skill)
	if UseSkill and UseSkill:CanBeUsed() then
		UseSkillRaw(skill, false, false)
		Command("/useshortcut 1 4")
		Sleep(200)
		Command("/useshortcut 1 4")
	end
end

-- ====================== CORE TARGET FINDER ======================
function GetNearestByPriority(range, priorityType)
    local monsterlist = GetMonsterList()
    if not monsterlist or monsterlist:GetCount() == 0 then return nil end

    local me = GetMe()
    local prioList = nil
    if priorityType == "high" then
        prioList = highPriorityList
    elseif priorityType == "low" then
        prioList = secondPriorityList
    elseif priorityType ~= "general" then
        return nil
    end

    local nearestMob = nil
    local nearestDist = 999999

    for mob in monsterlist.list do
        if mob:GetDistance() >= range then goto continue end
        if mob:IsAlikeDeath() then goto continue end

        -- Blacklist
        for i = 1, #blackList do
            if string.find(mob:GetName(), blackList[i]) then
                mob:SetBlock(true)
                goto continue
            end
        end

        -- Priority check
        local matches = (priorityType == "general")
        if prioList then
            for i = 1, #prioList do
                if string.find(mob:GetName(), prioList[i]) then
                    matches = true
                    break
                end
            end
        end
        if not matches then goto continue end

        if mob:GetDistance() < nearestDist then
            nearestDist = mob:GetDistance()
            nearestMob = mob
        end
        ::continue::
    end
    return nearestMob
end

-- ====================== MAIN TARGET FUNCTION ======================
function TargetPriority(range)
    local target = GetTarget()

    -- High priority
    local high = GetNearestByPriority(range, "high")
    if high then
        if not target or target:GetId() ~= high:GetId() then
            TargetMonsters(high, range)
        end
        return
    end

    -- Low priority
    local low = GetNearestByPriority(range, "low")
    if low then
        TargetMonsters(low, range)
        return
    end

    -- General
    local general = GetNearestByPriority(range, "general")
    if general then
        if not target or not target:IsMonster() or target:IsAlikeDeath() then
            TargetMonsters(general, range)
        end
    else
        ShowToClient(os.date("%X"), "No targets - moving to next spot", 20)
        if not GetMe():IsAlikeDeath() then
			--ShowToClient(os.date("%X"), "Setup stopScript to True if player is  alive!", 20)
			stopScript = true
		end
    end
end

-- ====================== HELPER: Mistarget approach & target ======================
function TargetMonsters(mob, maxRange)
    if not mob then return end
    local dist = mob:GetDistance()
    local offsetX, offsetY, sleepAfter = 0, 0, 0

    if dist >= 500 and dist <= 1000 then
        offsetX = math.random(30, 90)
        offsetY = math.random(50, 100)
        sleepAfter = 350
    elseif  dist > 1000	then
        offsetX = math.random(150, 250)
        offsetY = math.random(50, 150)
        sleepAfter = 1300
    end

    if sleepAfter > 0 then
		local loc = mob:GetLocation()
		ShowToClient(os.date("%X"), "move to monster")
		MoveToNoWait(loc.X + offsetX, loc.Y + offsetY, loc.Z)
		Sleep(sleepAfter)
	end
    Target(mob)
    Sleep(450)
end


function deltaMove()
	local MyID = GetMe():GetId();
	local tx = GetMe():GetLocation().X + math.random(-30, 30) + ((string.sub(MyID,-2))/2)
	local ty = GetMe():GetLocation().Y + math.random(-30, 30)
	MoveToNoWait(tx, ty, GetMe():GetLocation().Z);
end

function checkIdle(startTime)
	if GetTime() - startTime >= idleTime * 60000 then
		if not GetMe():IsInCombat() then
			ShowToClient(os.date("%X"), "Go to Safe place",20);
			return true
		end
	end
	return false
end

-- ==================== IMPROVED DEATH HANDLING ====================
function isAlive()
	if not GetMe():IsAlikeDeath() then 
		return true
	else
		ShowToClient(os.date("%X"), "DIED - Return to farm")
		Sound()

		if not IsPaused() then
			SetPause(true)
		end
		local deathTime = GetTime()
		-- Force respawn if still dead
		RequestRestartPoint(2) -- To Village
        Sleep(1000)
		
		while (GetTime() - deathTime < 16000) do	-- чекаємо 15 сек щоб вийти з бою
			Sleep(3000)
		end
		
		-- Force respawn if still dead
		if GetMe():IsAlikeDeath() then
			ShowToClient(os.date("%X"), "!!!! not ressurected for the first time!")
			RequestRestartPoint(2) -- To Village
			Sleep(5000)
		end
		
		ShowToClient(os.date("%X"), "Respawned - Going back to Kamaloka", 20)
	
	end

    return false
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

function HealthCheck()
	if GetMe():IsInCombat() then return end
	--ShowToClient(os.date("%X"), "HealthCheck in", 20)
    local me = GetMe()
    local timeNow = GetTime()
    local delta = timeNow - HealLastUsed

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

function escapeDeath()
    -- HP life-hack
    local me = GetMe()
    if me:GetHpPercent() <= NxtTrgtHP and (GetTime() - LastNxtTrgt or 0) > (NxtTrgtDelay * 1000) then
        LastNxtTrgt = GetTime()
        --ShowToClient(os.date("%X"), "Low HP - next target", 20)
        Command("/useshortcut 1 1")
    end
end

function inParty()
    local me = GetMe()
    if me:IsMyPartyMemberMaster() then
        return true
    end

    local PartyList = GetPartyList()
    if not PartyList or PartyList:GetCount() == 0 then
        return false
    end

    for member in PartyList.list do
        if member:IsMyPartyMemberMaster() then
			while member:GetDistance() <= 500 do 
				--ShowToClient(os.date("%X"), "Wait PL to Enter Kamaloka", 20)
				Sleep(2000)
			end
			ShowToClient(os.date("%X"), "Party leader is inside? Help him!", 20)
			return true
        end
    end
    return true
end

function goToBatista()
	local moveDistance = 100
	MoveTo(-116803, 46600, 366, moveDistance);
	MoveTo(-116776, 46617, 366, moveDistance);
	MoveTo(-116286, 46838, 438, moveDistance);
	MoveTo(-116053, 46944, 503, moveDistance);
	MoveTo(-116062, 47102, 505, moveDistance);
	Sleep(1500)
end;

function enterKamaloka()
	if not inParty() then 
		ShowToClient(os.date("%X"), "Not party leader - cannot enter Kamaloka", 20)
		return false
	end
	if GetMe():GetRangeTo(-116062, 47102, 505) < 500	then
		TargetNpc("Batista", 100400)
		Sleep(800)
		Talk()
		Sleep(1200)
		ClickText("Enter Kamaloka")
		Sleep(1800)
		ClickText("level 84")
		while GetMe():GetRangeTo(21836, -174922, -10911) > 600 do	--додати перевірку для випадків коли не можемо зайти в Камалоку і ми залишаємося біля Батісти
			Sleep(5000)
			ShowToClient(os.date("%X"), "Waiting to enter Kamaloka", 20)
		end
		atSpot0 = true
		return true
	else
		ShowToClient(os.date("%X"), "Not near Batista - cannot enter Kamaloka, restart recursively F.moveToStart", 20)
		moveToStart()
	end
end

function tpToKamael()
	while GetMe():IsInCombat() do
		local target = GetTarget()
		if target and target:IsMonster() and not target:IsAlikeDeath() then
			Command("/attack")
		else
			ClearT()
		end
        Sleep(2500)
    end
	ClickAndWait("_bbshome", "")
	ClickAndWait("voice .teleporterservice h scl", "")
	ClickAndWait("voice .teleporterservice h sl STC_OTHER_LOCATIONS", "")
	ClickAndWait("voice .teleporterservice t s S_L2U_KAMAEL_VILLAGE STC_OTHER_LOCATIONS", "")
	
	local timeout = GetTime() + 30000
	while GetMe():GetRangeTo(-116901, 46601, 366) > 1000 and GetTime() < timeout do
		Sleep(2000)
	end
end

function moveToStart()
	atSpot0 = false
	atSpot1 = false
	atSpot2 = false
	atSpot3 = false

	local me = GetMe()

	-- After death we usually spawn in town
	if me:GetRangeTo(-116901, 46601, 366) < 800 then  -- near Kamael Village TP
		ShowToClient(os.date("%X"), "[to start] Respawned in town - going to Batista", 20)
		goToBatista()
		deltaMove()
		return enterKamaloka()
		
	elseif me:GetRangeTo(-116062, 47102, 505) < 1300 then  -- near Batista
		ShowToClient(os.date("%X"), "[to start] Near Batista", 20)
		MoveTo(-116130, 47210, 501, 100)
		--deltaMove()
		return enterKamaloka()
		
	elseif me:GetRangeTo(21836, -174922, -10911) < 600 then
		ShowToClient(os.date("%X"), "[to start] at Spot 0", 20)
		atSpot0 = true
		return true
	elseif me:GetRangeTo(20501, -174886, -10916) < 1300 then
		ShowToClient(os.date("%X"), "[to start] at Spot 1", 20)
		atSpot1 = true
		return true
	elseif me:GetRangeTo(18177, -174892, -10653) < 1300 then
		ShowToClient(os.date("%X"), "[to start] atSpot2", 20)
		atSpot2 = true
		return true
	elseif me:GetRangeTo(12796, -174688, -9938) < 1400 then
		ShowToClient(os.date("%X"), "[to start] atSpot3", 20)
		atSpot3 = true
		return true
	else
		ShowToClient(os.date("%X"), "[to start] Unknown location - teleporting to Kamael", 20)
		tpToKamael()
		goToBatista()
		deltaMove()
		return enterKamaloka()
	end
end

-- Spot movement functions (unchanged but cleaned)
function moveToSpot1()
	ShowToClient(os.date("%X"), "move To Spot 1", 20)
	local moveDistance	=	150
	MoveTo(21816, -174943, -10912, moveDistance);
	MoveTo(21400, -174884, -10897, moveDistance);
	MoveTo(21194, -174888, -10900, moveDistance);
	MoveTo(20819, -174602, -10896, moveDistance);
	ShowToClient(os.date("%X"), "At Spot 1", 20)
	atSpot1 = true
end

function moveToSpot2()
	ShowToClient(os.date("%X"), "move To Spot 2", 20)
	local moveDistance	=	150
	MoveTo(20018, -174896, -10900, moveDistance);
	MoveTo(20046, -174892, -10900, moveDistance);
	MoveTo(19341, -174891, -10766, moveDistance);
	MoveTo(19048, -174885, -10641, moveDistance);
	MoveTo(18724, -174888, -10637, moveDistance);
	MoveTo(18385, -174520, -10633, moveDistance);
	ShowToClient(os.date("%X"), "At Spot 2", 20)
	atSpot2 = true
end

function moveToSpot3()
	ShowToClient(os.date("%X"), "move To Spot 3", 20)
	local moveDistance	=	150
	MoveTo(17716, -174873, -10637, moveDistance);
	MoveTo(17709, -174885, -10637, moveDistance);
	MoveTo(17021, -174887, -10510, moveDistance);
	MoveTo(16725, -174889, -10384, moveDistance);
	MoveTo(16316, -174867, -10374, moveDistance);
	MoveTo(15841, -174774, -10390, moveDistance);
	MoveTo(15383, -174889, -10374, moveDistance);
	MoveTo(14527, -174890, -10356, moveDistance);
	MoveTo(14127, -174893, -10191, moveDistance);
	MoveTo(13647, -174891, -9994, moveDistance);
	MoveTo(13165, -174876, -9968, moveDistance);
	MoveTo(12989, -174868, -9938, moveDistance);
	MoveTo(12695, -174791, -9958, moveDistance);
	ShowToClient(os.date("%X"), "At Spot3", 20)
	atSpot3 = true
	UseSkillH(FocusAttack)
end

function findSpot()
--------
	if GetMe():IsInCombat() then
		farmKamaloka(500)
	else
		HealthCheck()
	end

	ShowToClient(os.date("%X"), "Find position", 20)
	if atSpot0 then
		moveToSpot1()
	elseif atSpot1 then 
		moveToSpot2()
	elseif atSpot2 then 
		moveToSpot3()
	elseif atSpot3 then 
		farmKamaloka(1600)
	else
		ShowToClient(os.date("%X"), "not in spot?", 20)
	end
end

function saveSettings()
	SCONFIG = L2TConfig.GetConfig();
	PrevConfig_targeting_option = SCONFIG.targeting.option;
	PrevConfig_targeting_range = SCONFIG.targeting.range;
	PrevConfig_targeting_z_range = SCONFIG.targeting.z_range;
	--ShowToClient("[KillMons] ", "old Settings saved.",20);
end

function restoreSettings()
	SCONFIG = L2TConfig.GetConfig();
	SCONFIG.targeting.option = PrevConfig_targeting_option;
	SCONFIG.targeting.range = PrevConfig_targeting_range;
	SCONFIG.targeting.z_range = PrevConfig_targeting_z_range;
	--ShowToClient("[KillMons] ", "old Settings restored.",20);
end

function farmKamaloka(spotRange)
	-------
	saveSettings()

	SCONFIG.targeting.option = L2TConfig.ETargetingType.TT_RANGE_FROM_CHAR;
	SCONFIG.targeting.range = spotRange;
	SCONFIG.targeting.z_range = 100;
	------
	ShowToClient(os.date("%X"), "Start Farm", 20)
	local isPausedPreviously	= false		-- змінна для відстеження стану паузи
	SetPause(false)
	stopScript = false
	local startTime = GetTime()
	
	while not stopScript and isAlive() do
	------------
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
			-- Основний фарм (виконується тільки коли не на паузі)
			escapeDeath()

			if checkIdle(startTime) then
				ShowToClient(os.date("%X"), "Idle timeout - ending", 20)
				tpToKamael()
			else
				local target = GetTarget()
				if target and target:IsMonster() and target:IsAlikeDeath() then
					ClearT()
				elseif target and target:IsMonster() then
					if target:GetDistance() >= RushDist and Rush then
						UseSkillH(Rush)
					end
					if target:GetName() == "Lost Captain" and target:GetHpPercent() <= 2 and not weArePL then
						SetPause(true)
						ShowToClient(os.date("%X"), "Lost Captain's HP <= 1%, we not a PL")
						stopScript = true
						local timeout = GetTime() + 20000
						while GetMe():GetRangeTo(12092, -174901, -9945) < 1500 and GetTime() < timeout do
							ShowToClient(os.date("%X"), "using Blessed Scroll of Escape")
							UseItem(1538); -- Blessed Scroll of Escape
							Sleep(3500)
						end
					end
				end
				TargetPriority(FightRange)
			end
		end

		Sleep(1400 + math.random(-700, 900))
	end

	SetPause(true)
	restoreSettings()
end

-- Генерація 8 точок
function GenerateOctagon(newradius, startLoc)
		
    octagonPoints = {}
	
    for i = 0, 7 do
        local angle = i * 45   -- 45 градусів між точками
        local rad = math.rad(angle)
        
        local x = startLoc.X + math.floor(newradius * math.cos(rad))
        local y = startLoc.Y + math.floor(newradius * math.sin(rad))
        
        table.insert(octagonPoints, {X = x, Y = y, Z = startLoc.Z})
    end
    --ShowToClient(os.date("%X"), "Octagon generated with 8 points, radius " .. newradius, 20)
end


-- Основна функція руху по восьмикутнику
function MoveInOctagonOnce(radius)
	local layerWidth	=	150
	local moveDistance	=	150   -- відстань, на якій вважається, що точка досягнута
	local toRad			=	math.floor(radius/layerWidth)
	local startLoc		= GetMe():GetLocation()
	
	--ShowToClient(os.date("%X"), "Octagon layers: " .. toRad, 20)
	
	for counter=1, toRad do
		--ShowToClient(os.date("%X"), "Layer: " .. counter, 20)
		GenerateOctagon(counter*layerWidth, startLoc)
	
		if #octagonPoints == 0 then return end
		
		
		
		for i = 1, 7 do
			local point = octagonPoints[i]
			--ShowToClient(os.date("%X"), "Octagon point " .. i .. "/8", 20)
			MoveToNoWait(point.X, point.Y, point.Z)
			Sleep(300)
			for a = 1,3 do
				--ShowToClient(os.date("%X"), "pickup " .. a, 20)
				Command("/pickup")
				Sleep(800 + math.random(-300,200))
			end
		end
	end
end

-- ====================== MAIN LOOT FUNCTION ======================
function SmartLoot(radius)
    radius = radius or 600
    local maxLootTime = 60000          -- 60 секунд (1 хвилина)
    local me = GetMe()
    local mgr = GetItemManager()
    
    local lootList = {}
    local startTime = GetTime()

    ShowToClient(os.date("%X"), "Searching items within " .. radius .. " range", 20)

    -- === Збір усіх предметів ===
    for i = 0, mgr:GetCount() - 1 do
        local item = mgr:GetByIdx(i)
        if item then
            local dist = item:GetRangeFixedTo(me)
            if dist <= radius then
                local loc = item:GetLocation()
                
                table.insert(lootList, {
                    x = loc.X,
                    y = loc.Y,
                    z = loc.Z,
                    name = item:GetName(),
                    qty = item:GetQuantity(),
                    id = item:GetNameId(),
                    distance = dist
                })
            end
        end
    end

    if #lootList == 0 then
        ShowToClient(os.date("%X"), "No items found nearby.", 20)
		MoveInOctagonOnce(radius)
        return 0
    end

    -- === Сортування по відстані (від найближчого до найдальшого) ===
    table.sort(lootList, function(a, b) 
        return a.distance < b.distance 
    end)

    ShowToClient(os.date("%X"), "Found " .. #lootList .. " items. Starting pickup from closest...", 20)

    local picked = 0

    -- === Підбір з обмеженням часу ===
    for i, item in ipairs(lootList) do
        -- Перевірка часу
        if (GetTime() - startTime) > maxLootTime then
            ShowToClient(os.date("%X"), " Loot time limit (60s) reached!", 20)
            break
        end

        ShowToClient(os.date("%X"), string.format("%d/%d | %s x%d (%.0f)", i, #lootList, item.name, item.qty, item.distance), 20)
		--LogMessage(tostring(os.date("%Y-%m-%d : %X ")) .. TranslitCoded(me:GetName()) .. "\t |\t" ..  item.qty .. "\t|\t" .. tostring(item.name) .. " [" .. math.floor(item.distance) .."]" )
        -- Рух до предмета
        MoveTo(item.x, item.y, item.z, 90)

        Sleep(500 + math.random(-200, 200))

        -- Підбір
        Command("/pickup")
        Sleep(600 + math.random(-200, 300))
        
        Command("/pickup")  -- другий раз на випадок кількох предметів
        Sleep(400)

        picked = picked + 1
    end

    ShowToClient(os.date("%X"), "Loot finished. Picked: " .. picked .. "/" .. #lootList, 20)
    return picked
end

function init()
	startTime = GetTime()
	Rush = checkRushSkill(RushSkills)
	counter = 0
	ActivateSoulShot(1467,true)	--1467	Soulshot (S-Grade)
	ActivateSoulShot(3952,true)	--3952	Blessed Spiritshot (S-Grade)
	if GetMe():IsMyPartyMemberMaster() then
		weArePL = true
		Command("/rbsstart")
		Command("/statreset")
	end

end

-- ====================== MAIN ======================
ShowToClient(os.date("%X"), "=== Kamaloka RB Farm Started ===", 20)

init()

while true do
	counter = counter + 1
	ShowToClient(os.date("%X"), "Start # " .. counter, 20)
	if counter > 15 then
		Sound()
        ShowToClient(os.date("%X"), "Too many starts, RB is difficult?", 20)
		if counter > 25 then
			ShowToClient(os.date("%X"), "5+ Dies..Stop Farm", 20)
			break
		end
    end
    if not moveToStart() then
        ShowToClient(os.date("%X"), "Failed to enter Kamaloka", 20)
        break
    end
	
	if not Rebuff() then
        ShowToClient(os.date("%X"), "Failed to buff", 20)
        break
    end

	findSpot()    
	if atSpot0 then
		farmKamaloka(600)
	else
		farmKamaloka(1600)
	end
	

    -- If we reach here without dying or idle → one full cycle done
	if atSpot3 and stopScript then
		ShowToClient(os.date("%X"), "Farm finished successfully.", 20)
		Sound()
		--ShowToClient(os.date("%X"), "Grab my drop!!!!");
		if weArePL then
			SmartLoot(300)
			Command("/rbsdmp")
		end
		
		break
	end
end

deltaMove()
Command("/rbsstop")
ShowToClient(os.date("%X"), "Stop RB Farm. End", 20)
SetPause(true)