-- ====================== Включення системи сповіщення ======================
function OnCreate()
	ShowToClient(tostring(os.date("%X")), "Alarm Plugin v.5.11", 20)
    this:RegisterCommand("aaa", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME)
	this:RegisterCommand("debug", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME)
-- ====================== НАЛАШТУВАННЯ ======================
	AlarmStatus     = false
	CheckInterval   = 5000      --  (в мілісекундах)

	msgDelay        = 15		-- 15 секунд для звичайних гравців
	WarMsgDelay     = 8
	
	-- Дистанції для небезпечних гравців
	DangerRadiusNormal = 2500   -- для Red, Enemy, Clan War
	DangerRadiusPvP    = 1000   -- тільки для PvP Flag / Blink

	-- Звуки
	SirenaSound     = GetDir() .. "\\sound\\sirena.wav"
	PlayerSound     = GetDir() .. "\\sound\\PlayerAlarm.wav"
	FoundSound      = GetDir() .. "\\sound\\found.wav"
	AlarmSound      = GetDir() .. "\\sound\\alarm.wav"
	
	-- Лог
--- ====================== ШЛЯХ ДО ЛОГІВ ======================
	-- Скрипт знаходиться в /plugins - піднімаємося на рівень вище і створюємо папку logs
	--local baseDir = GetDir() .. "\\..\\logs"
	local baseDir = "C:\\Users\\xan\\Documents\\tools\\l2tower\\logs"

	MyName    = GetMe():GetId() or "---"
	--local rawMyName = GetMe():GetName() or "---"
	--local MyName = Translit(rawMyName)
	LogFile   = baseDir .. "\\AlarmLog_" .. MyName .. ".txt"

	-- Таймер і таблиці
	LastCheckTime   = 0
	NearbyPlayers   = {}
	DangerousPlayers= {}
end
 
function ClearT()
	ClearTargets();
	CancelTarget(false);
	Sleep(123);
	ClearTargets();
end

function OnCommand_debug(vCommandChatType, vNick, vCommandParam)
    Debugmode = not Debugmode

    if Debugmode then
        ShowToClient(tostring(os.date("%X")), "DEBUG MODE ON", 20)
    else
        ShowToClient(tostring(os.date("%X")), "DEBUG MODE OFF", 20)
    end
end

function OnCommand_aaa(vCommandChatType, vNick, vCommandParam)
    AlarmStatus = not AlarmStatus
    if AlarmStatus then
        ShowToClient(tostring(os.date("%X")), "Alarm: FULL MODE (All players)", 20)
        LogToFile("=== ALARM FULL MODE ACTIVATED ===")
    else
        ShowToClient(tostring(os.date("%X")), "Alarm: SILENT MODE (Only dangerous players)", 20)
        LogToFile("=== ALARM SILENT MODE ACTIVATED ===")
    end
    Sound(AlarmSound)
end
-- ====================== ПОБАЙТОВА ТРАНСЛІТЕРАЦІЯ НА ОСНОВІ ТВОЇХ ДАНИХ ======================
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

-- ====================== ДОПОМІЖНІ ФУНКЦІЇ ======================
function LogToFile(text)
    local file = io.open(LogFile, "a")
    if file then
        file:write("[" .. os.date("%Y-%m-%d %X") .. "] " .. text .. "\n")
        file:close()
    else
        -- Якщо не вдалося відкрити файл — пишемо в чат (рідкісний випадок)
        ShowToClient(tostring(os.date("%X")), "ERROR: Cannot write to log file!", 20)
    end
end

function Sound(alarm)
    PlaySound(alarm)
end


-- ====================== ОПТИМІЗОВАНА ЛОГІКА (виконується кожні 5 сек) ======================
function OnLTick1s()
    local currentTime = GetTime()

    if (currentTime - LastCheckTime) < CheckInterval then
        return
    end

    LastCheckTime = currentTime

    --if GetZoneType() == L2ZoneType.PEACEFUL then return end

    local isPaused = IsPaused()
    local fullMode = not isPaused

    local playerList = GetPlayerList()
    if not playerList or not playerList.list then return end
	
    for player in playerList.list do
        if player:IsMe() or player:IsMyPartyMember() then goto continue end

        local pDist = player:GetDistance()
        if pDist > 1500 then
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


      

        -- ==================== ЗВИЧАЙНИЙ ГРАВЕЦЬ ====================
        if fullMode then
			LogToFile( playerName.. " | Clan: " .. clanName .. " R: " .. pDist)
			if debugMode then
				debugText(rawName)
				debugText(rawClan)
			end
        end
	::continue::

    end
	if fullMode then
		SetPause(true);
		ShowToClient(tostring(os.date("%X")), "Done", 20)
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
