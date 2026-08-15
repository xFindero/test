-- Antibot Captcha Alarm + Extract
-- Автоматично ловить діалог з "Antibot" / "antibot"

--CheckSound      = GetDir() .. "\\sound\\found.wav"
SirenaSound     = GetDir() .. "\\sound\\sirena.wav"
PrevCode        = ""
LastCheck       = 0
CheckInterval   = 15000
-- Human delay (неблокуюча затримка відправки коду, щоб не спамити сервер)
HumanDelay      = 15000          -- 15 секунд
PendingCode     = nil
SendAt          = 0
MyNickname      = "Unknown" --if not set, will be set on OnLogin event

function Sound()
    if PlaySound(SirenaSound) then
        return true
    else
        ShowToClient(os.date("%X"), "Failed to Play sound")
        return false
    end
end

function GetCode(msg)
    local result = ""
    for color, code in string.gmatch(msg, "<font color=([%d%a]-)>([%d%a]?)<") do
        if color ~= "LEVEL" then
            --ShowToClient(os.date("%X"), color .. " : " .. code, 20)
            result = result .. code
        end
    end
    return result
end

function SendCode(code)
    -- Не відправляємо одразу — ставимо в чергу
    PendingCode = code
    SendAt = GetTime() + HumanDelay
    ShowToClient(os.date("%X"), "Code: " .. code .. " will be sent in " .. (HumanDelay/1000) .. "s")
end

function SaveCode(code)
    local fileName = os.date("1.codes.txt")
    local path = GetDir() .. "antibot\\" .. fileName
    local file = io.open(path, "a+")
    if file then
        file:write(code .. "\t\t| " .. TranslitCoded(MyNickname) .. "\t\t| " .. os.date("%X") .. "\n")
        file:close()
    end
end

function SaveCaptcha(msg)
    local fileName = os.date("%Y-%m-%d_%H%M%S.txt")
    local path = GetDir() .. "antibot\\" .. fileName
    local file = io.open(path, "w")
    if file then
        file:write(msg .. "\n")
        file:close()
        ShowToClient(os.date("%X"), "Saved: " .. path, 20)
    end
end

function CheckCaptcha()
    local msg = tostring(GetDialogHtml() or "")
    if msg == "" or msg == "nil" then return end

    -- шукаємо Antibot / antibot (регістронезалежно)
    local lower = string.lower(msg)
    if not string.find(lower, "antibot") or not string.find(lower, "captcha") then return end

    local code = GetCode(msg)

    if code ~= "" and code ~= PrevCode then
        ShowToClient(os.date("%X"), "=== Captcha detected ===")
        Sound()
        PrevCode = code
        ShowToClient(os.date("%X"), "Pause!")
        SetPause(true)
        SaveCode(code)
        SendCode(code)
        SaveCaptcha(msg)
    --elseif code == PrevCode and code ~= "" then
        --ShowToClient(os.date("%X"), "Same Captcha (ignored)", 20)
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
-- ========== Plugin Events ==========
 function OnLogin(username)
    MyNickname = username
    ShowToClient(os.date("%X"), "Antibot Plugin loaded. Watching for Antibot dialog for " .. TranslitCoded(MyNickname), 20)
end

function OnLTick()
    local now = GetTime()
-- Спочатку перевіряємо відкладену відправку
    if PendingCode and now >= SendAt then
        local result = "_captcha " .. PendingCode
        ShowToClient(os.date("%X"), "Sending: " .. PendingCode)
        QuestReply(result)
        PendingCode = nil
        SendAt = 0
        ShowToClient(os.date("%X"), "Resumed!", 3)
        SetPause(false)
    end

    -- Далі звичайна перевірка капчі
    if now - LastCheck >= CheckInterval then
        LastCheck = now
        CheckCaptcha()
    end
end