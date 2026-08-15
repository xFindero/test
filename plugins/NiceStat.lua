statEnabled			= false			-- enable|disable stat at startup
autoDump			= 600;		 	-- do autodump of extended statistics to file every N seconds (minimum 60 seconds), set 0 to disable
drop_file			= GetDir() .. "\\stats\\Capitan_drop.txt"
statDirectory		= GetDir() .. "\\stats\\";		-- relative path to directory there stats will be dumped
-------------------------------------
dropTable			= {}
adenaGained			= 0
monstersTable		= {}
monstersKilled		= 0
monstersSpoiled		= 0
startDate			= {}
allInfoRecieved		= false
charName			= ""			-- to save charname on login, cuz in OnLogout hook GetMe():GetName()==""
lastDumpTime		= 0
dmgTable			= { Dealt=0, Recieved=0 };
deal				= 0;
-------------------------------------

function OnCreate()
	this:RegisterCommand("statshow", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("statdump", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("statreset", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("stat", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("stathelp", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("rbsstart", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("rbsstop", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("rbsdmp", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	-- start time of collecting stats
	startDate = os.date("*t");
	lastDumpTime = os.time();
end

function OnCommand_rbsstart(vCommandChatType, vNick, vCommandParam)
		statEnabled = true;
		ShowToClient("STAT", "Stats collecting Enabled.");
end;
function OnCommand_rbsstop(vCommandChatType, vNick, vCommandParam)
		statEnabled = false;
		ShowToClient("STAT", "Stats collecting Disabled.");
end;

function OnCommand_rbsdmp(vCommandChatType, vNick, vCommandParam)
	local filename = drop_file
	ShowToClient("*", "Dump statistics to file ");
	rbDumpStat(filename);
end;

function OnCommand_stat(vCommandChatType, vNick, vCommandParam)
	if statEnabled then
		statEnabled = false;
		ShowToClient("STAT", "Stats collecting PAUSED.");
	else
		statEnabled = true;
		ShowToClient("STAT", "Stats collecting RESUMED.");
	end
end;

function OnCommand_stathelp(vCommandChatType, vNick, vCommandParam)
		ShowToClient("/stat", "Pause/Resume stats collecting.");
		ShowToClient("/statreset", "Resets current statistics.");
		ShowToClient("/statshow", "Show current statistics in system chat.");
		ShowToClient("/statdump", "Dump extended statistics to file "..GetMe():GetName()..".txt. File will be placed in L2Tower folder.");
		ShowToClient("/stathelp", "Show this help.");
end;

function OnCommand_statshow(vCommandChatType, vNick, vCommandParam)
	local timeStart = os.time(startDate);
	local timeNow = os.time();
	local timeDiff = os.difftime(timeNow, timeStart);
	
	local eHours = math.floor(timeDiff/3600);
	timeDiff = timeDiff - eHours*3600;
	local eMins = math.floor(timeDiff/60);
	local eSecs = timeDiff - eMins*60;
	
	ShowToClient("Start time", os.date("%x %X", timeStart));
	ShowToClient("Now time", os.date("%x %X", timeNow));
	ShowToClient("Elapsed time", string.format("%d:%02d:%02d", eHours, eMins, eSecs));
	ShowToClient("Adena gained", FormatNumber(adenaGained));
	ShowToClient("Damage dealt", FormatNumber(dmgTable.Dealt));
	ShowToClient("Damage recieved", FormatNumber(dmgTable.Recieved));
	ShowToClient("Monsters killed/spoiled", tostring(monstersKilled).."/"..tostring(monstersSpoiled));
end;

-- Converts 1234567890 → "1 234 567 890"
function FormatNumber(num)
    if not num then return "0" end
    
    local formatted = tostring(math.floor(num))
    formatted = formatted:reverse()
    formatted = formatted:gsub("(%d%d%d)", "%1 ")
    formatted = formatted:reverse()
    
    -- Remove possible leading space
    formatted = formatted:gsub("^ ", "")
    
    return formatted
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

function FillUserTable(df)
	local userTable = {};
	local userCount = 0;
	local inParty = 0;
	
	uList = GetPlayerList();
	
	for user in uList.list do
		if user:IsPlayer() then
			userTable[user:GetName()] = {};
			
			userTable[user:GetName()].ClanName = user:GetClanName();
			if user:IsPvPFlag() or user:IsPvPFlagBlink() then
				userTable[user:GetName()].PvPFlag = "-";
			else
				userTable[user:GetName()].PvPFlag = "";
			end
			userTable[user:GetName()].Distance = user:GetDistance();
			
			userCount = userCount + 1;

			if user:IsMyPartyMember() then
				inParty = inParty + 1;
			end;
		end;
	end;

	df:write(" Total users near:\t\t"..tostring(userCount).."\n");
	df:write(" Your party users:\t\t"..tostring(inParty).."\n");
	df:write("┌───────────────────────┬───────────────────┬─────┬──────────┐\n");
	df:write("│     Character         │     Clan          │ PvP │ Distance │\n");
	df:write("├───────────────────────┼───────────────────┼─────┼──────────┤\n");

		for name, data in pairs(userTable) do
			df:write(string.format("│ %21s │ %17s │  %1s  │ %8s │\n", TranslitCoded(name), TranslitCoded(data.ClanName), data.PvPFlag, data.Distance));
		end
	df:write("└───────────────────────┴───────────────────┴─────┴──────────┘\n");
	df:write("\n");
end;

function rbDumpStat(filename)
	local df = io.open(filename, "a+")
	
	local timeStart = os.time(startDate);
	local timeNow = os.time();
	local timeDiff = os.difftime(timeNow, timeStart);	
	local eHours = math.floor(timeDiff/3600);
	local tempDiff = timeDiff - eHours*3600;
	local eMins = math.floor(tempDiff/60);
	local eSecs = tempDiff - eMins*60;
	
	if df~=nil then

		for character, drop in pairs(dropTable) do
			for item, count in pairs(drop) do
				df:write(os.date("%Y-%m-%d : %X ") .. "\t" .. string.format("%10s [time: %02d:%02d] %45s [%3s]", TranslitCoded(character),eMins, eSecs, item, count).."\n")
			end
			--df:write("\n");
		end
		if dropTable[GetMe():GetName()] == nil then
			item = "no Item"
			count = 0
			df:write(os.date("%Y-%m-%d : %X ") .. "\t" .. string.format("%10s [time: %02d:%02d] %45s [%3s]", TranslitCoded(GetMe():GetName()),eMins, eSecs, item, count).."\n")
		end
		df:close();
	else
		 ShowToClient(os.date("%X"), "no file", 20)
	end;
end

function DumpStat(filename)
	local df = io.open(filename, "wt");
	
	if df~=nil then
		--ShowToClient("STAT", "Dumped to file ["..filename.."]");

		local timeStart = os.time(startDate);
		local timeNow = os.time();
		local timeDiff = os.difftime(timeNow, timeStart);
		
		local eHours = math.floor(timeDiff/3600);
		local tempDiff = timeDiff - eHours*3600;
		local eMins = math.floor(tempDiff/60);
		local eSecs = tempDiff - eMins*60;

		df:write(" Stats for:\t\t"..TranslitCoded(GetMe():GetName()).."\n");
		df:write(" Start time:\t\t"..os.date("%x %X", timeStart).."\n");
		df:write(" Now time:\t\t\t"..os.date("%x %X", timeNow).."\n");
		df:write(" Elapsed time:\t\t"..string.format("%d:%02d:%02d", eHours, eMins, eSecs).."\n");
		df:write("------------------------ Adena Info ------------------------\n");
		df:write(" Adena gained:\t\t"..FormatNumber(adenaGained).."\n");
		df:write(" Adena per hour:\t"..FormatNumber(math.floor(3600*adenaGained/(timeDiff+1))).."\n");
		df:write("------------------------ Damage Info ------------------------\n");
		df:write(" Damage inflict:\t"..FormatNumber(dmgTable.Dealt).."\n");
		df:write(" Damage per sec:\t"..string.format("%.2f", dmgTable.Dealt/(timeDiff+1)).."\n");
		df:write(" Damage recieve:\t"..FormatNumber(dmgTable.Recieved).."\n");
		df:write("------------------------ Drop Info ------------------------\n");

		for character, drop in pairs(dropTable) do
		df:write("┌────────────────────────────────────────────────────────────┐\n");

		df:write(string.format("|\t%-57s", TranslitCoded(character)).."|\n");
		df:write("├────────────────────────────────────────────────────────────┤\n");
		for item, count in pairs(drop) do
			df:write(string.format("|%52s: %6s", item, count).."|\n");			--60 для довгих імен речей було
		end
		df:write("└────────────────────────────────────────────────────────────┘\n");
		end
		
		df:write("------------------------ Monster Info ------------------------\n");
		df:write(" Mons killed:\t\t"..tostring(monstersKilled).."\n");
		df:write(" Mons spoiled:\t\t"..tostring(monstersSpoiled).."\n");
		df:write("┌────────────────────────────────────────────────────────────┐\n");
		for monster, count in pairs(monstersTable) do
			df:write(string.format("|%47s\t: %6s", monster, count).."|\n");
		end
		df:write("└────────────────────────────────────────────────────────────┘\n");
		df:write("\n");
		df:write("------------------------ Users near ------------------------\n");
		FillUserTable(df);
		df:close();
	end;
end

function OnCommand_statdump(vCommandChatType, vNick, vCommandParam)
	local filename = statDirectory..TranslitCoded(GetMe():GetName())..".txt";
	ShowToClient("STAT", "Current stats dumpd to file.");
	DumpStat(filename);
end;

function OnCommand_statreset(vCommandChatType, vNick, vCommandParam)
	ShowToClient("STAT", "Current stats resetted.");
	-- start time of collecting stats
	startDate = os.date("*t");
	-- reset last dump time to current time
	lastDumpTime = os.time();

	-- clear drop
	for k,v in pairs(dropTable) do dropTable[k]=nil end;
	adenaGained = 0;
	-- clear monsters
	for k,v in pairs(monstersTable) do monstersTable[k]=nil end;
	monstersKilled = 0;
	monstersSpoiled = 0;
	dmgTable = { Dealt=0, Recieved=0 };
	allInfoRecieved = false;

end;

function AddItemToStat(character, item, count)
	--ShowToClient("debug", "item: " .. item .. " count: " .. count .. " user: " .. character);
	if item=="adena" then
		adenaGained = adenaGained + count;
		return;
	end
	
	if dropTable[character]==nil then
		dropTable[character] = {};
	end
	
	if dropTable[character][item]==nil then
		dropTable[character][item] = count;
	else	
		dropTable[character][item] = dropTable[character][item] + count;
	end	
	
end;

function OnChatSystemMessage(id, msg)
	if GetMe()==nil then
		return;
	end;
	
	if not statEnabled then
		return;
	end;
	
	-- store all needed startup info
	if not allInfoRecieved then
		charName = TranslitCoded(GetMe():GetName());
		allInfoRecieved = true;
	end;
	
	local character = GetMe():GetName();
	local cnt = "1";
	local name = "";

	if id==52 then	-- You have earned $s1 Adena.
		msg = string.gsub(msg, ",", "");
		cnt = string.match(msg, "You have earned (%d+) adena.");
		name = "adena";
	end;

	if id==53 then	-- You have earned $s2 $s1(s).
		msg = string.gsub(msg, ",", "");
		cnt, name = string.match(msg, "You have earned (%d+) (.+)%(s%)%.");
	end;

	if id==54 then	-- You have earned $s1.
		name = string.match(msg, "You have earned (.+)%.");
	end;
	
	if id==28 then	-- You have obtained $s1 Adena.
		msg = string.gsub(msg, ",", "");
		cnt = string.match(msg, "You have obtained (%d+) adena%.");
		name = "Adena";
	end;

	if id==29 then	-- You have obtained $s2 $s1.
		msg = string.gsub(msg, ",", "");
		cnt, name = string.match(msg, "You have obtained (%d+) (.+)%.");
	end;

	if id==30 then	-- You have obtained $s1.
		name = string.match(msg, "You have obtained (.+)%.");
	end;
	
	if id==299 then	-- $c1 has obtained $s3 $s2.
		msg = string.gsub(msg, ",", "");
		character, cnt, name = string.match(msg, "(.+) has obtained (%d+) (.+)%.");
		--ShowToClient("debug", " character: " .. character .. " name: " .. name .. " cnt: " .. cnt);
	end;
	
	if id==300 then	-- $c1 has obtained $s2.
		character, name = string.match(msg, "(.+) has obtained (.+)%.");
		--ShowToClient("debug", " character: " .. character .. " name: " .. name);
	end;
	if id==369 then	-- $c1 has obtained $s2.
		name = string.match(msg, "You have obtained a (.+)%.");
		--ShowToClient("debug", " character: " .. character .. " name: " .. name);
	end;

	if id==1661 then	-- $c1 has obtained $s3 $s2(s).
		msg = string.gsub(msg, ",", "");
		character, cnt, name = string.match(msg, "(.+) has obtained (%d+) (.+)%(s%)%.");
		--ShowToClient("debug", " character: " .. character .. " name: " .. name .. " cnt: " .. cnt);
	end;

	if id==608 then	-- $c1 has obtained $s3 $s2(s) by using sweeper.
		msg = string.gsub(msg, ",", "");
		character, cnt, name = string.match(msg, "(.+) has obtained (%d+) (.+) by using sweeper%.");
		if not cnt then
			ShowToClient("debug", "ID:" .. id .. " cnt not valid!");
			cnt = 0
		end
		if not name then
			ShowToClient("debug", "ID:" .. id .. " name not valid!");
			name = "ItemName"
		end
		if not character then
			ShowToClient("debug", "ID:" .. id .. " character not valid!");
			character = "J.DOU"
		end
		--ShowToClient("debug", "ID:" .. id ..  " character: " .. character .. " name: " .. name .. " cnt: " .. cnt);
	end;

	if id==609 then	-- $c1 has obtained $s2 by using sweeper.
		character, name = string.match(msg, "(.+) has obtained (.+) by using sweeper%.");
		if not name then
			ShowToClient("debug", "ID:" .. id .. " name not valid!");
			name = "---"
		end
		--ShowToClient("debug", "ID:" .. id .. " character: " .. character .. " name: " .. name);
	end;

	if name~="" then
		AddItemToStat(character, name, tonumber(cnt));
	end;
	
-- Damage stats	
	if id==2261 then	-- $c1 has inflicted $s3 damage on $c2.
		msg = string.gsub(msg, ",", "");
		deal = string.match(msg, ".+ has done (%d+) points of damage to .+%.");
		if ( deal == nil ) then
			deal = 0
		end
		dmgTable.Dealt = dmgTable.Dealt + deal;
	end;

	if id==2262 then	-- $c1 has inflicted $s3 damage on $c2.
		msg = string.gsub(msg, ",", "");
		recieve = string.match(msg, ".+ has received (%d+) damage from .+%.");
		dmgTable.Recieved = dmgTable.Recieved + recieve;
	end;
end;

-- some replacement for IsAttacked() function (is it premium?)
function IsTargetedByParty(id)
	-- check party targets
	local ptList = GetPartyList();
	for user in ptList.list do
		if user:GetTarget() == id then
			-- ShowToClient("STAT", "Targeted by "..user:GetName());
			return true;
		end
	end;
	-- check my target
	if GetMe():GetTarget() == id then
		-- ShowToClient("STAT", "Targeted by "..GetMe():GetName());
		return true;
	end

	return false;
end;

function OnDie(user, spoiled)
	if not statEnabled then
		return;
	end;

	if user:IsMe() then
		local filename = statDirectory..TranslitCoded(GetMe():GetName()).."_death.txt";
		DumpStat(filename);
		return;
	end;
	
--	if user~=nil and user:IsMonster() and user:IsAttacked() then
	if user~=nil and user:IsMonster() and ( IsTargetedByParty(user:GetId()) or user:GetDistance() < 200 ) then
		if monstersTable[user:GetName()]~=nil then
			monstersTable[user:GetName()] = monstersTable[user:GetName()] + 1;
		else
			monstersTable[user:GetName()] = 1;
		end;
		
		monstersKilled = monstersKilled + 1;

		if spoiled then
			monstersSpoiled = monstersSpoiled + 1;
		end;
	
	end
end;

function OnLTick1s()
	if not statEnabled or autoDump==0 or GetMe():IsAlikeDeath() then
		return;
	end;
	
	if autoDump<60 then
		autoDump = 60;
	end;
	
	if (os.time()-lastDumpTime) >= autoDump then
		local filename = statDirectory..TranslitCoded(GetMe():GetName())..".txt";
		DumpStat(filename);
		lastDumpTime = os.time();
	end;
end;

function OnLogout()
	if not statEnabled then
		return;
	end;
	
	local filename = statDirectory..charName..".txt";
	DumpStat(filename);
end;

function OnDisconnect(mode)
	if not statEnabled then
		return;
	end;
	
	local filename = statDirectory..charName..".txt";
	DumpStat(filename);
end;