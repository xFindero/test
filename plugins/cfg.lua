function OnCreate()
	this:RegisterCommand("a", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("c", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("s", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("m", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("h", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("w", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("z", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("zak", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("x", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("ap", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("cp", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("sk", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("sh", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("sh1", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("kama", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("cap", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("ins", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("mid", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("lsk", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("fortH", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("fortW", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("fortHBF", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("fortWBF", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("spoil", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("spoilLOA", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("spoil2", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("spoilp", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("pika", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("4sep", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	-- not used
	--this:RegisterCommand("cat", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	--this:RegisterCommand("b", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	--this:RegisterCommand("f", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
end;

function ClearT()
	ClearTargets();
	CancelTarget(false);
	Sleep(123);
	ClearTargets();
end

function OnCommand_c(vCommandChatType, vNick, vCommandParam)
    ProcessCommand("/cfg");
end;

function OnCommand_m(vCommandChatType, vNick, vCommandParam)
    SetPause(true);
	ClearT();
	ShowToClient(tostring(os.date("%X")), "Nornil - Mid",20);
	ProcessCommand("/scriptStart 2.MID.lua");
end;

function OnCommand_h(vCommandChatType, vNick, vCommandParam)
    SetPause(true);
	ShowToClient(tostring(os.date("%X")), "Nornil - Hard",20);
	ProcessCommand("/scriptStart 2.HARD.lua");
end;

function OnCommand_s(vCommandChatType, vNick, vCommandParam)
    SetPause(true);
	ClearT();
	ShowToClient(tostring(os.date("%X")), "SOE",20);
	ProcessCommand("/scriptStart bsoe.lua");
end;

function OnCommand_w(vCommandChatType, vNick, vCommandParam)
    SetPause(true);
	ClearT();
	ShowToClient(tostring(os.date("%X")), "Kamael - WH",20);
	ProcessCommand("/scriptStart KamaelWH.lua");
end;

function OnCommand_x(vCommandChatType, vNick, vCommandParam)
    SetPause(true);
	ClearT();
	ShowToClient(tostring(os.date("%X")), "Stop all Acripts",20);
	ProcessCommand("/scriptStopAll");
end;

function OnCommand_z(vCommandChatType, vNick, vCommandParam)
    SetPause(true);
	ClearT();
	ShowToClient("Destr", "Zil",20);
	ProcessCommand("/scriptStart Destr-ZIL.lua");
	SetPause(false);
end;

function OnCommand_zak(vCommandChatType, vNick, vCommandParam)
    SetPause(true);
	ClearT();
	ShowToClient(tostring(os.date("%X")), "go fight Zaken!",20);
	ProcessCommand("/scriptStart ZakenIn.lua");
end;

function OnCommand_cp(vCommandChatType, vNick, vCommandParam)
	ShowToClient(tostring(os.date("%X")), "Create CP potions - in [Pause] mode");
	ProcessCommand("/scriptStart CP-potions.lua");
end;

function OnCommand_ap(vCommandChatType, vNick, vCommandParam)
	ShowToClient(tostring(os.date("%X")), "Create Arba potions - in [Pause] mode");
	ProcessCommand("/scriptStart Arba-potions.lua");
end;


function OnCommand_sk(vCommandChatType, vNick, vCommandParam)
    SetPause(false);
	ClearT();
	ShowToClient(tostring(os.date("%X")), "start Shillen Templar",20);
	ProcessCommand("/scriptStart 1.Shilen-InParty.lua");
end;

function OnCommand_sh(vCommandChatType, vNick, vCommandParam)
	ShowToClient(tostring(os.date("%X")), "Storm Screamer",20);
	ProcessCommand("/scriptStart 1.SH-HARD.lua");
end;

function OnCommand_sh1(vCommandChatType, vNick, vCommandParam)
	ShowToClient(tostring(os.date("%X")), "Storm Screamer",20);
	ProcessCommand("/scriptStart 1.SH-HARD-1.lua");
end;

function OnCommand_ins(vCommandChatType, vNick, vCommandParam)
    Command("/instancezone")
end;

function OnCommand_kama(vCommandChatType, vNick, vCommandParam)
	ProcessCommand("/scriptStart TP_Kamael.lua");
end;

function OnCommand_cap(vCommandChatType, vNick, vCommandParam)
	ShowToClient(tostring(os.date("%X")), "Goto Kamaloka",20);
	--ProcessCommand("/scriptStart GO_Kamaloka.lua");
	ProcessCommand("/scriptStart 1.Farm-Capitan.lua");
end;

function OnCommand_mid(vCommandChatType, vNick, vCommandParam)
	ProcessCommand("/scriptStart 1.FarmNorn-MID.lua");
end;

function OnCommand_lsk(vCommandChatType, vNick, vCommandParam)
	ProcessCommand("/scriptStart LearnSubSkill.lua");
end;
--------
function OnCommand_fortH(vCommandChatType, vNick, vCommandParam)
	ProcessCommand("/scriptStart GO-Fort-Hive.lua");
end;
function OnCommand_fortW(vCommandChatType, vNick, vCommandParam)
	ProcessCommand("/scriptStart GO-Fort-Western.lua");
end;
function OnCommand_fortHBF(vCommandChatType, vNick, vCommandParam)
	ProcessCommand("/scriptStart GO-Fort-Hive-BF.lua");
end;
function OnCommand_fortWBF(vCommandChatType, vNick, vCommandParam)
	ProcessCommand("/scriptStart GO-Fort-Western-BF.lua");
end;
--------
function OnCommand_4sep(vCommandChatType, vNick, vCommandParam)
	ShowToClient("DEBUG", "Param count: " .. vCommandParam:GetCount(), 20)

	if vCommandParam:GetCount() > 0 then
		ShowToClient("DEBUG", "Param raw: " .. vCommandParam:GetParam(0):GetString(), 20)
	end
	if (vCommandParam:GetCount() == 0) then 
		ShowToClient(tostring(os.date("%X")), "IT 4Sep. No params - Room 1",20);
		ProcessCommand("/scriptStop GO-IT-4sep-1.lua");
		Sleep(300)
		ProcessCommand("/scriptStart GO-IT-4sep-1.lua");
	else
		if (vCommandParam:GetCount() == 1) then   --- alarm with xxx range /alarm_xxx
			local roomNumber = tonumber(vCommandParam:GetParam(0):GetString())
			ShowToClient(os.date("%X"), "IT 4Sep. Param = " .. tostring(roomNumber), 20)

			if roomNumber == 1 then
				ProcessCommand("/scriptStart GO-IT-4sep-1.lua");
			elseif	roomNumber == 2 then
				ProcessCommand("/scriptStart GO-IT-4sep-2.lua");
			elseif	roomNumber == 3 then
				ProcessCommand("/scriptStart GO-IT-4sep-3.lua");
			elseif	roomNumber == 4 then
				ProcessCommand("/scriptStart GO-IT-4sep-4.lua");
			else
				ShowToClient(tostring(os.date("%X")), "IT 4Sep. Wrong params! " .. roomNumber);
			end
		end;
	end
	ShowToClient(tostring(os.date("%X")), "IT 4Sep.plugin finished",20);
end;



function OnCommand_spoil(vCommandChatType, vNick, vCommandParam)
	ClearT();
	ShowToClient(tostring(os.date("%X")), "Spoil in HARD",20);
	ProcessCommand("/scriptStart Spoil-HARD.lua");
end;

function OnCommand_spoilLOA(vCommandChatType, vNick, vCommandParam)
	ClearT();
	ShowToClient(tostring(os.date("%X")), "Spoil in LOA - Hunt for Karik's",20);
	ProcessCommand("/scriptStart Spoil-LOA.lua");
end;

function OnCommand_spoil2(vCommandChatType, vNick, vCommandParam)
    SetPause(false);
	ClearT();
	ShowToClient(tostring(os.date("%X")), "start [spoil assistant]",20);
	ProcessCommand("/scriptStart 1.Spoil.lua");
end;

function OnCommand_spoilp(vCommandChatType, vNick, vCommandParam)
    SetPause(false);
	ClearT();
	ShowToClient(tostring(os.date("%X")), "spoil with polearm",20);
	ProcessCommand("/scriptStart 1.Spoil-pika.lua");
end;

function OnCommand_pika(vCommandChatType, vNick, vCommandParam)
	ShowToClient(tostring(os.date("%X")), "use Trident for stun",20);
	ProcessCommand("/scriptStart Pika-Icarus-Trident.lua");
end;

-- function OnCommand_cat(vCommandChatType, vNick, vCommandParam)		-- Halloween event in Kamael village
    -- SetPause(false);
	-- ClearT();
	-- ShowToClient(tostring(os.date("%X")), "Camael go to Cat",20);
	-- ProcessCommand("/scriptStart KamaelPussCat.lua");
-- end;

-- function OnCommand_b(vCommandChatType, vNick, vCommandParam)
    -- SetPause(true);
	-- ClearT();
	-- ShowToClient(tostring(os.date("%X")), "Kamael, Go to Buff");
	-- ShowToClient(tostring(os.date("%X")), "path 1 ", L2ChatType.CHAT_HERO);
	-- ProcessCommand("/scriptStart KamaelBuff.lua");
-- end;

-- function OnCommand_f(vCommandChatType, vNick, vCommandParam)
    -- SetPause(true);
	-- ClearT();
	-- ShowToClient(tostring(os.date("%X")), "Find Box - started");
	-- ProcessCommand("/scriptStart FindMyBox.lua");
-- end;