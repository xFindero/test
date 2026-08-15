function OnCreate()
	this:RegisterCommand("RB", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	farmRB = false;
	AlarmSound = GetDir() .. "\\sound\\alarm.wav";
	DCSound = GetDir() .. "\\sound\\dc.wav";
	DieSound = GetDir() .. "\\sound\\die.wav";
	FoundSound = GetDir() .. "\\sound\\found.wav";
	GMSound = GetDir() .. "\\sound\\gm.wav";
	GoodSound = GetDir() .. "\\sound\\Good.wav";
	HPSound = GetDir() .. "\\sound\\hp.wav";
	MsgSound = GetDir() .. "\\sound\\msg.wav";
	PlayerSound = GetDir() .. "\\sound\\PlayerAlarm.wav";
	SirenaSound = GetDir() .. "\\sound\\sirena.wav";
end;


function OnCommand_RB(vCommandChatType, vNick, vCommandParam)
	if (farmRB == false) then
		farmRB = true;
		ShowToClient(tostring(os.date("%X")),"RB farm Is Activated.", 20);
	else
		farmRB = false;
		ShowToClient(tostring(os.date("%X")),"RB farm Is Deactivated.", 20);	
	end;
end

function Sound(alarm)
	local result = false;
	if ( PlaySound(alarm)) then
		--ShowToClient("#", "Succes!")
		result = true;
	else
		ShowToClient("#", " Sound Failed!")
	end
	return result
end

function OnChatUserMessage(chatType, nick, msg)
	local Message = nil
	if (chatType == 10) then		--Announcements: Blackbite was spotted in the Mimirs Forest! 
		Message = string.lower(msg);						-- Converts message to lower case letters.
		local tmpMsg = string.find(Message, "mimir")				-- сповіщення про РБ в Мід - "Mimirs", GM - тимчасова заглушка
		if tmpMsg == nil then
			tmpMsg = string.find(Message, "elit")				-- сповіщення про РБ в Elit Envoi
			ShowToClient(tostring(os.date("%X")), tostring(Message));
		end
		if ( tmpMsg ~= nil and tmpMsg > 0) then
			ShowToClient(tostring(os.date("%X")), tostring(Message));
			Sound(FoundSound);
			if (farmRB) then
				SetPause(true);
				ShowToClient(tostring(os.date("%X")), "Stop all Acripts",20);
				ProcessCommand("/scriptStopAll");
				ProcessCommand("/scriptStart 1.FarmNorn-MID-RB.lua");
			end
		--else
			--ShowToClient(tostring(os.date("%X")), "tmpMsg is nil");
		end
	-- else
		-- Message = string.lower(msg);
		-- ShowToClient(tostring(os.date("%X")), "Chat: " .. chatType .. " Msg: " .. tostring(Message), 20);
	end;
	Message = nil
end;


-- function OnChatSystemMessage(msgId,message)
	-- ShowToClient(tostring(os.date("%X")), "Sys. [" .. msgId .. "] Msg: " .. tostring(message), 20);
-- end;