--- * v.4.23 - added math.randomseed, changed SaySomething() for math.random, TranslitCoded(str) rebuild for search Latin symbols first
--- * v.4.22 - debug Mode for PM added

function OnCreate()
	ShowToClient(os.date("%X"), "Alarm Plugin v.4.23", 20)
    this:RegisterCommand("aa", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME)
    this:RegisterCommand("debug", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME)

-- ====================== НАЛАШТУВАННЯ ======================
	AlarmStatus     = false
	CheckInterval   = 10
	msgDelay        = 15
	WarMsgDelay     = 8
	-- Відстані для PVP
	DangerRadiusNormal = 2500
	DangerRadiusPvP    = 1000
	-- Відстані для PVE
	GeneralClose	= 400
	GeneralNear		= 700
	GeneralInRange	= 1000
	-- Звуки
	SirenaSound     = GetDir() .. "\\sound\\sirena.wav"
	PlayerSound     = GetDir() .. "\\sound\\PlayerAlarm.wav"
	FoundSound      = GetDir() .. "\\sound\\found.wav"
	AlarmSound      = GetDir() .. "\\sound\\alarm.wav"
	MsgSound 		= GetDir() .. "\\sound\\msg.wav"
-- ====================== Фрази ======================
	FrasesPVP 	= {"a.","ee","34444aaass","7d77","bla","lol",":)",")~"};
	FrasesPVE 	= {"b.","ui","2222sss","333rr","blat","lolo",":(","arr~"};
-- ====================== ТАЙМЕРИ ДЛЯ ЧАТУ ======================
	LastCheckTime       = 0
	LastChatMessageTime = 0
	LastReplyTime       = 0
	ChatReplyPending    = false
	NearbyPlayers       = {}
	DangerousPlayers    = {}
end

 function OnLogin(username)
	math.randomseed(
        os.time() * 1000 + 
        math.floor(os.clock() * 1000000) + 
        GetMe():GetId()
    )
	
 -- ====================== ШЛЯХ ДО ЛОГІВ ======================
		local MyName = GetMe():GetName() or GetMe():GetId()
		LogFile  = GetDir() .. "logs\\AlarmLog_" .. TranslitCoded(MyName) .. ".txt"
end;

function OnCommand_aa(vCommandChatType, vNick, vCommandParam)
    AlarmStatus = not AlarmStatus

    if AlarmStatus then
        ShowToClient(os.date("%X"), "Alarm: FULL MODE (All players)", 20)
        LogToFile("=== ALARM FULL MODE ACTIVATED ===")
    else
        ShowToClient(os.date("%X"), "Alarm: SILENT MODE (Only dangerous players)", 20)
        LogToFile("=== ALARM SILENT MODE ACTIVATED ===")
    end

    Sound(MsgSound)
end

function OnCommand_debug(vCommandChatType, vNick, vCommandParam)
    Debugmode = not Debugmode

    if Debugmode then
        ShowToClient(os.date("%X"), "DEBUG MODE ON", 20)
    else
        ShowToClient(os.date("%X"), "DEBUG MODE OFF", 20)
    end
end
 -- ====================== ДОПОМІЖНІ ФУНКЦІЇ ======================
function LogToFile(text)
	if not LogFile then
	    ShowToClient("#", "ERROR: LogFile is nil!", 20)
		return
	end
    local file = io.open(LogFile, "a")
    if file then
        file:write("[" .. os.date("%Y-%m-%d %X") .. "] " .. text .. "\n")
        file:close()
    else
        -- Якщо не вдалося відкрити файл — пишемо в чат (рідкісний випадок)
        ShowToClient("#", "ERROR: Cannot write to log file!", 20)
    end
end

function Sound(alarm)
    PlaySound(alarm)
end

function ClearT()
	ClearTargets();
	CancelTarget(false);
	Sleep(123);
	ClearTargets();
end

-- ====================== ТРАНСЛІТЕРАЦІЯ З ПЕРЕВІРКОЮ ТИПУ НІКА ======================
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

function debugText(txt)
	local bText = ""
    for i = 1, #txt do
        local byte = string.byte(txt, i)
        bText = bText .. " " .. byte .. " "
    end
	LogToFile(bText)
	bText = ""
end

-- ====================== Відкладена логіка після смерті ======================
function DelayedDieLogic()
    UnregisterTimer("DelayedDieLogic")   -- видаляємо таймер після виконання

    -- Перевіряємо, чи ми ще мертві
    if not GetMe():IsAlikeDeath() then
        return
    end

    if GetMe():GetCpPercent() < 70 then
        -- Вбито гравцем
        ShowToClient(os.date("%X"), "Killed by Player", 20)
        Sound(SirenaSound)

        local playersNear = GetPlayerList()
        if playersNear and playersNear.list then
            for player in playersNear.list do
                if not player:IsMyPartyMember() and player:GetDistance() < 2000 then
                    local safeName = TranslitCoded(player:GetName() or "Unknown")
                    local safeClan = TranslitCoded(player:GetClanName() or "No Clan")

                    ShowToClient(os.date("%X"), 
                        "Near us was: " .. safeName .. 
                        " Dist [" .. math.floor(player:GetDistance()) .. 
                        "], PVP: " .. tostring(player:IsPvPFlag()) .. 
                        ", Clan: " .. safeClan, 20)

                    LogToFile("Near us was: " .. safeName .. 
                              " Dist [" .. math.floor(player:GetDistance()) .. 
                              "], PVP: " .. tostring(player:IsPvPFlag()) .. 
                              ", Clan: " .. safeClan)
                end
            end
        end
    else
        -- Вбито монстрами
        local safeMyName = TranslitCoded(GetMe():GetName() or "Me")
        ShowToClient(os.date("%X"), safeMyName .. " Killed by monsters", 20)
        LogToFile(safeMyName .. " Killed by monsters")
    end
end

-- ====================== SaySomething (оновлена) ======================
function SaySomething()
    if GetMe():GetCpPercent() <= 90 then
        local idx = math.random(1, #FrasesPVP)
        Command(FrasesPVP[idx])
        LogToFile("Said PVP phrase: " .. FrasesPVP[idx])
    else
        local idx = math.random(1, #FrasesPVE)
        Command(FrasesPVE[idx])
        LogToFile("Said PVE phrase: " .. FrasesPVE[idx])
    end
end


function GetDangerInfo(player)
    if not player then return false, 0 end

    local isPvPFlag = player:IsPvPFlag() or player:IsPvPFlagBlink()
    local isOtherDanger = player:IsEnemy() or 
                          player:GetReputation() < 0 or 
                          player:IsClanWar2Side()

    if isPvPFlag then
        return true, DangerRadiusPvP      -- PvP Flag - 1000
    elseif isOtherDanger then
        return true, DangerRadiusNormal   -- Інші небезпечні - 2500
    end

    return false, 0
end

function weArePL()
    local result = false   -- спочатку скидаємо
	local MyPL = GetPartyMaster();
	if MyPL then
		if ( MyPL:IsMe() ) then
			--ShowToClient(os.date("%X"), "I'm PL - alarm here",20);
			result = true
		else
			local dist = MyPL:GetDistance()
			if dist > 1500 then
                result = true
                --ShowToClient("#", "Party Leader is far (" .. math.floor(dist) .. " dist) - acting as PL", 20)
           -- else
				--ShowToClient(os.date("%X"), "I'm not PL, shhhh",20);
            end
		end
	else	--solo 
		result = true   -- якщо не в партії — вважаємо себе "PL" (самостійний фарм)
		--ShowToClient("#", "Not in party - acting as PL", 20)
	end
	--ShowToClient("#", "exiting WeArePL() - " .. tostring(result), 20)
	return result
end

-- ====================== ОПТИМІЗОВАНА ЛОГІКА (виконується кожні 5 сек) ======================
function OnLTick1s()
    local currentTime = GetTime()

    if (currentTime - LastCheckTime) < CheckInterval*1000 then
        return
    end

    LastCheckTime = currentTime

    if (GetZoneType() == L2ZoneType.PEACEFUL and not Debugmode )then return end

    local isPaused = IsPaused()
    local fullMode = AlarmStatus and not isPaused

    local playerList = GetPlayerList()
    if not playerList or not playerList.list then return end

    for player in playerList.list do
        if player:IsMe() or player:IsMyPartyMember() or ( (player:IsMyAllianceMember() or player:IsMyClanMember() ) and not fullMode ) then goto continue end

        local pDist = player:GetDistance()
        if pDist > 2500 then
            NearbyPlayers[player:GetId()] = nil
            DangerousPlayers[player:GetId()] = nil
            goto continue
        end

        local playerId   = player:GetId()
		local rawName = player:GetName() or "--"
		local playerName = TranslitCoded(rawName)
		--------------
        local rawClan = player:GetClanName() or "No Clan"
		local clanName = TranslitCoded(rawClan)
        local isDanger, dangerRadius = GetDangerInfo(player)

        -- ==================== НЕБЕЗПЕЧНИЙ ГРАВЕЦЬ ====================
        if isDanger then
            if pDist > dangerRadius then
                DangerousPlayers[playerId] = nil
                goto continue
            end

            if not DangerousPlayers[playerId] then
                DangerousPlayers[playerId] = { firstSeen = currentTime }
                LogToFile("DANGER DETECTED: " .. playerName .. " | Clan: " .. clanName .. " | Dist: " .. math.floor(pDist))
            end

            if (currentTime - (warMsgTime or 0)) > WarMsgDelay * 1000 then
                Sound(SirenaSound)
                ShowToClient(os.date("%X"), 
                    "! DANGER ! " .. playerName .. 
                    " | Clan: " .. clanName .. " | [" .. math.floor(pDist) .. "]", 2)

                LogToFile("DANGER ALARM - " .. playerName .. " | [" .. math.floor(pDist) .. "]")

                warMsgTime = currentTime
            end
            goto continue
        end

        -- ==================== ЗВИЧАЙНИЙ ГРАВЕЦЬ ====================
        if fullMode then
			if not NearbyPlayers[playerId] then
                NearbyPlayers[playerId] = { 
                    lastAlertTime = 0,
                    close400Count = 0,        -- кількість сповіщень у зоні ≤ 400
                    lastDistanceLevel = pDist
                }
                LogToFile("Player entered zone: " .. playerName .. " | Dist: " .. math.floor(pDist))
            end

            local info = NearbyPlayers[playerId]

            -- Оновлюємо лічильник, якщо гравець увійшов у радіус ≤ 400 GeneralClose
            if pDist <= GeneralClose then
                if info.lastDistanceLevel > GeneralClose then
                    info.close400Count = info.close400Count + 1   -- +1 при входженні
                    LogToFile("CLOSE 400 ENTER #" .. info.close400Count .. ": " .. playerName .. " [" .. math.floor(pDist) .. "]")
                end
            end

            -- Визначаємо інтервал сповіщення
            local alertInterval = 999999
            if pDist <= GeneralClose then
                alertInterval = 5000      -- кожні 5 сек
            elseif pDist <= GeneralNear then
                alertInterval = 10000     -- кожні 10 сек
            elseif pDist <= GeneralInRange then
                alertInterval = 999999    -- тільки 1 раз
            end

           -- Сповіщаємо згідно з інтервалом
            if ((currentTime - info.lastAlertTime) > alertInterval and weArePL()) then

                local soundType = (pDist <= GeneralClose) and PlayerSound or FoundSound
                local chatType  = (pDist <= GeneralNear) and 2 or 20

                local countStr = ""
                if pDist <= GeneralClose then
                    info.close400Count = info.close400Count + 1   -- ← ЗБІЛЬШУЄМО КОЖЕН РАЗ ПРИ СПОВІЩЕННІ
                    countStr = " (x" .. info.close400Count .. ")"
                end

                local message = ""
                if pDist <= GeneralClose then			-- 400-
                    message = "VERY CLOSE!" .. countStr .. " [" .. math.floor(pDist) .. "]"
                elseif pDist <= GeneralNear then		-- 700-
                    message = "Near player [" .. math.floor(pDist) .. "]"
                elseif pDist <= GeneralInRange then		-- 1000-
                    message = "Player In farm Range [" .. math.floor(pDist) .. "]"
                end

                Sound(soundType)
                ShowToClient(os.date("%X"), 
                    message .. " " .. playerName .. " | Clan: " .. clanName .. " | Dist: " .. math.floor(pDist), chatType)
                LogToFile("ALERT: " .. message .. " - " .. playerName)
                info.lastAlertTime = currentTime
            end
            -- Зберігаємо поточний рівень дистанції для наступної перевірки
            info.lastDistanceLevel = pDist
        end
		-- === НОВА ЛОГІКА ВІДПОВІДІ НА ЧАТ ===
		if ChatReplyPending then
			-- Чекаємо приблизно 5 секунд
			if (currentTime - LastChatMessageTime) >= 8000 then
				if (currentTime - LastReplyTime) >= 60 * 1000 then   -- не відповідати частіше 1 разу на хвилину
					SaySomething()
					LastReplyTime = currentTime
					ChatReplyPending = false
					--ShowToClient(os.date("%X"), "Replied to local chat", 20)
					--LogToFile("Replied to local chat after 5 sec")
				else
					ChatReplyPending = false  -- скасовуємо, бо ще не минула хвилина
				end
			end
		end
        ::continue::
    end

    -- Очищення старих записів
    for id, data in pairs(NearbyPlayers) do
        if (currentTime - (data.lastAlertTime or 0)) > 180000 then
            NearbyPlayers[id] = nil
        end
    end
    for id, data in pairs(DangerousPlayers) do
        if (currentTime - (data.firstSeen or 0)) > 60000 then
            DangerousPlayers[id] = nil
        end
    end
end

-- ====================== OnChatUserMessage ======================
function OnChatUserMessage(chatType, nick, msg)
    local currentTime = GetTime()
    local fixedNick = TranslitCoded(nick or "")
    local fixedMsg  = TranslitCoded(msg or "")
	local myNick	= GetMe():GetName() or "Me"

    -- 1. Логуємо будь-яке повідомлення
    if chatType == 2 or chatType == 0 and  nick ~= myNick then
        Sound(MsgSound)
        LogToFile("CHAT: [" .. (chatType == 2 and "PM" or "General") .. "] from " .. fixedNick .. " : " .. fixedMsg)
		if Debugmode then
			debugText(msg)
		end
    end

    -- 2. Реагуємо тільки на локальний чат (chatType == 0)
    if chatType == 0 and AlarmStatus and nick ~= myNick then
		if weArePL() then
			--ShowToClient(os.date("%X"), "get msg - going to reply", 20)
			LastChatMessageTime = currentTime
			ChatReplyPending = true
		--else
			--ShowToClient(os.date("%X"), "We are not  a PL, do not Reply", 20)
		end
    end
end


function OnDisconnect(mode)
	local rawNick = GetMe():GetName();
    LogToFile(TranslitCoded(rawNick) .. " DISCONNECTED!")
    Sound(AlarmSound)
end

-- function OnDie(user, spoiled)
    -- -- Жорсткий захист
    -- if not user or not user:IsMe() then
        -- return
    -- end

    -- -- Мінімальна логіка відразу після смерті
    -- Sound(DieSound)
    -- --ShowToClient(os.date("%X"), "Player died", 20)

    -- -- Відкладений виклик важкої логіки (через 800 мс)
    -- --RegisterTimer("DelayedDieLogic", 1500, DelayedDieLogic)
-- end

-- ====================== ЯКЩО НАС АТАКУЮТЬ ======================
function OnAttack(user, target) -- On Attack to usser
	if ( (GetTime() - (msgTime1 or 0)) > msgDelay * 1000 and AlarmStatus == true) then -- enable only 1 toon, to not make mass noise
		if (target:IsMe() or target:IsMyPartyMember()) and (user:IsPlayer()) then -- if target is me or my pt member and attacker is player
			Sound(SirenaSound)
			ShowToClient(os.date("%X"), "Attackker: " .. TranslitCoded(user:GetName()),20);
			ShowToClient(os.date("%X"), "Attackker Clan: " .. TranslitCoded(user:GetClanName()), 20);
			msgTime1 = GetTime();
		end; 
	end; 
end;

function OnMagicSkillLaunched(user, target, skillId)
	if ( (GetTime() - (msgTime2 or 0)) > msgDelay * 1000 and AlarmStatus == true) then
		if (user == nil ) then
			ShowToClient(os.date("%X"), "user NotDefined")
		end
		if ( user ~= nil and target ~= nil ) then
			if (target:IsMe() or target:IsMyPartyMember()) and (user:IsPlayer() and not user:IsMyPartyMember() and not user:IsMe() ) then -- if target is me or my pt member and attacker is player
				Sound(SirenaSound)
				ShowToClient(os.date("%X"), "Player: " .. TranslitCoded(user:GetName()) .. " Clan: " .. TranslitCoded(user:GetClanName()) .. " target: " .. TranslitCoded(target:GetName()) .. " ID: " .. skillId,20);
				msgTime2 = GetTime();
			end;
		end
	end;
end;
