-- test antibot system
CheckSound = GetDir() .. "\\sound\\found.wav";
PrevCode	=	""	--previous captcha

function Sound()
	local result = false;
	if ( PlaySound(CheckSound)) then
		--ShowToClient(os.date("%X"), "Succes!")
		result = true;
	else
		ShowToClient(os.date("%X"), "Failed to Play sound")
	end
	return result
end

function info(msg)
	local result = ""

	for color, code in string.gmatch(msg, "<font color=([%d%a]-)>([%d%a]?)<") do
		if color ~= "LEVEL" then
			ShowToClient(os.date("%X"),color .. " : " .. code,20);
			result = result .. code
		end
	end

	ShowToClient(os.date("%X"), " " .. result,20);

	return	result
end


function SendCode(code)
	local captchaCode = code
	local result = "_captcha " .. captchaCode

	--QuestReply(result);
	ShowToClient(os.date("%X"), "result: " .. result);
end

function SaveCaptcha(msg)
	ShowToClient(os.date("%X"), "date:" .. tostring(os.date("%Y-%m-%d_%H%M%S.txt")),20);
	ShowToClient(os.date("%X"), "GetTime:" .. GetTime(),20);


	local fileName = tostring(os.date("%Y-%m-%d_%H%M%S.txt"))
	ShowToClient(os.date("%X"), "Save to file :" .. GetDir() .. "antibot\\" .. fileName);
	local file = io.open(GetDir() .. "antibot\\" .. fileName, "w");
	file:write(msg.. "\n");
	file:close();
end

--------------------- Main --
ShowToClient(os.date("%X"), "-------------------------");
ShowToClient(os.date("%X"), "[ Alarm system ] ",20);

local msg = tostring(GetDialogHtml());		-- get last dialog
ShowToClient(os.date("%X"), msg ,20);
msgTitleStart 	= 0 					--якщо позиція "слова 0" - значить нічого не знайдено
msgTitleEnd 	= 0 					--якщо позиція "слова 0" - значить нічого не знайдено

msgTitleStart, msgTitleEnd = string.find(msg, "Antibot");		-- Captcha
if ( msgTitleStart ~= nil and msgTitleStart > 0 ) then 			-- перевірка чи знайдено слово
	ShowToClient(os.date("%X"), "pos from: " .. msgTitleStart .. " to: " .. msgTitleEnd);
	tmpMsg = string.sub(msg,msgTitleStart,msgTitleEnd)
	ShowToClient(os.date("%X"), "Title: " .. tmpMsg);
	Sound()
	local code = info(msg)
	if	( code ~= PrevCode ) then
		PrevCode = code			--save first capthca
		ShowToClient(os.date("%X"), "save first capthca", 20);
		SendCode(code)
		SaveCaptcha(msg)
	else
		ShowToClient(os.date("%X"), "This is the same Captcha!", 20);
		-- wait for new
	end
else
	ShowToClient(os.date("%X"), "no Captcha", 20);
	ShowToClient(os.date("%X"), "msgTitleStart: " .. tostring (msgTitleStart), 20);

end