-- =============================================
--  Debug All Messages Logger для L2Tower
--  Логує: User Chat, System Chat, Screen Messages (якщо ловиться)
--  Запусти і просто грай/роби enchant — дивись у вікні ShowToClient
-- =============================================

function OnCreate()
	this:RegisterCommand("ttt", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	testOn = false
    ShowToClient("DEBUG", "=== Log All Messages ===")
    ShowToClient("DEBUG", "do something...")
    
    -- Запускаємо таймер для перевірки "екранних" повідомлень, які не ловляться events
    -- SetTimer(250)  -- перевірка кожні 250 мс
end

function OnCommand_ttt(vCommandChatType, vNick, vCommandParam)
	if (testOn == false) then
		testOn = true;
		ShowToClient(tostring(os.date("%X")),"Log is Activated.", 20);
	else
		testOn = false;
		ShowToClient(tostring(os.date("%X")),"Log is Deactivated.", 20);	
	end;
end

-- =============================================
-- 1. Повідомлення від гравців (включаючи Region/Shout)
-- =============================================
function OnChatUserMessage(chatType, nick, msg)
    if (msg == nil or not testOn) then return end
    
    local typeStr = tostring(chatType)
    ShowToClient("USER_CHAT", 
        string.format("[Type: %s] %s: %s", typeStr, nick or "?", msg))
    
    -- Додатковий детальний лог для region
    if string.find(string.upper(typeStr), "REGION") or 
       string.find(string.upper(typeStr), "SHOUT") or 
       chatType == 15 or chatType == 1 then
        ShowToClient("REGION", "[REGION/SHOUT] " .. (nick or "?") .. ": " .. msg)
    end
end

-- =============================================
-- 2. Системні повідомлення (звичайні system messages)
-- =============================================
function OnChatSystemMessage(id, msg)
    if (msg == nil or not testOn) then return end
    ShowToClient("SYSTEM_MSG_ON_CHAT", 
        string.format("[ID: %s] %s", tostring(id), msg))
end

-- =============================================
-- 3. Системні повідомлення з текстом (деякі версії Tower)
-- =============================================
function OnSystemMessage(id, msg)
    if (msg == nil or not testOn) then return end
    ShowToClient("ON_SYSTEM_MSG", string.format("[System ID: %s] %s", tostring(id), msg))
end

-- =============================================
-- 4. Таймер — ловимо те, що не приходить в events (On-Screen / ExShowScreenMessage)
-- =============================================
local lastScreenMsg = ""

-- function OnTimer()
    -- -- Спроба отримати останнє системне повідомлення (працює не на всіх серверах)
    -- local currentMsg = GetSystemMessage() or GetLastSystemMessage() or ""
    
    -- if currentMsg ~= "" and currentMsg ~= lastScreenMsg then
        -- lastScreenMsg = currentMsg
        -- ShowToClient("SCREEN_POSSIBLE", "Знайдено можливе екранне повідомлення: " .. currentMsg)
    -- end
    
    -- -- Додатково можна перевіряти інші функції, якщо вони є в твоїй версії:
    -- -- local lastChat = GetLastChatMessage() or ""
-- end

-- =============================================
-- 5. Інші корисні events (на всяк випадок)
-- =============================================
-- function OnNpcSay(npcId, npcName, chatType, msg)
	-- if msg then
		-- ShowToClient("NPC_SAY", string.format("[NPC: %s] %s", npcName or npcId, msg))
	-- end
-- end

-- function OnCreatureSay(creatureId, creatureName, chatType, msg)
	-- if msg then
		-- ShowToClient("CREATURE_SAY", string.format("[Creature: %s] %s", creatureName or "?", msg))
	-- end
-- end

-- =============================================
-- Додаткові функції для дебагу
-- =============================================
function OnL2TChatGlobalMsg(username,message,connectionId)
	if message then
		ShowToClient("GlobalMsg ", string.format("[user: %s] %s id: %s", username or npcId, message, connectionId))
	end
end

function OnL2TChatHiddenMsg(username,message,connectionId)
	if message then
		ShowToClient("HiddenMsg ", string.format("[user: %s] %s id: %s", username or npcId, message, connectionId))
	end
end

function OnL2TChatPersonalMsg(username,message,connectionId)
	if message then
		ShowToClient("PersonalMsg ", string.format("[user: %s] %s id: %s", username or npcId, message, connectionId))
	end
end

function OnL2TChatServerMsg(username,message,connectionId)
	if message then
		ShowToClient("ServerMsg ", string.format("[user: %s] %s id: %s", username or npcId, message, connectionId))
	end
end

function OnL2TChatSystemMsg(message,isError)
	if message then
		ShowToClient("SystemMsg ", string.format("[user: %s] %s id: %s", username or npcId, message, connectionId))
	end
end
-- =============================================
function OnDestroy()
    ShowToClient("DEBUG", "Скрипт логування зупинено.")
end
