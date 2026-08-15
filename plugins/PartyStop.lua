PartyStop = false;
--------------------------------------------------------------------------------
function OnCreate()
	this:RegisterCommand("party", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
end;
--------------------------------------------------------------------------------

function ClearT()
	ClearTargets();
	CancelTarget(false);
	Sleep(123);
	ClearTargets();
end

function StopB(status)
	SetPause(status);
	Sleep(100);
	ShowToClient("#", " Stop ALL: " .. tostring(status));
end;

function OnCommand_party(vCommandChatType, vNick, vCommandParam)
	if (PartyStop == false) then
		PartyStop = true;
		ShowToClient("-", "-------------------------");
		ShowToClient("#", tostring(os.date("%X")), 20);
		ShowToClient("#", "[Party Stop Enabled]", 20);
	else
		PartyStop = false;
		ShowToClient("-", "-------------------------");
		ShowToClient("#", tostring(os.date("%X")), 20);
		ShowToClient("#", "[Party Stop Disabled]", 20);
	end;
end;
--------------------------------------------------------------------------------



function OnChatUserMessage(chatType, nick, msg)
	 if (chatType == L2ChatType.CHAT_PARTY) then
	 Message = string.lower(msg); -- Converts message to lower case letters.
	 Message = Message:gsub("^%s*(.-)%s*$", "%1"); -- Trimming message of spaces on start.
	 
		 if (Message == "+" and PartyStop ) then
			StopB(false);
			ClearT();
			ShowToClient("[Party]", "<------- Start -------->", 20);
			--ProcessCommand("/scriptStart 111.lua");
		 end;
		 if (Message == "-") then
			StopB(true);
			ClearT();
		 	ShowToClient("[Party]", "AFK mode", 20);
			me = GetMe();
			CurrentLoc = me:GetLocation();
			CurrentLoc.X = (CurrentLoc.X + 25);
			MoveToNoWait(CurrentLoc.X,CurrentLoc.Y,30);
			Sleep(255);
			CurrentLoc.Y = (CurrentLoc.Y + 25);
			MoveToNoWait(CurrentLoc.X,CurrentLoc.Y,30);
			--ProcessCommand("/scriptStart 222.lua");
		 end;
		if (Message == "blya" and PartyStop) then
			StopB(true);
			ClearT();
			ShowToClient("[Party]", "Go to safe place!", 20);
			ProcessCommand("/scriptStart MoveToSafeNornil.lua");
		end;
		if ( Message == "soe" ) then
			StopB(true);
			ClearT();
			ShowToClient("[Party]", "Go to Town", 20);
			ProcessCommand("/scriptStart soe.lua");
		end;
		if ( Message == "box" ) then
			ClearT();
			ShowToClient("[Party]", "start [Find my Box]", 20);
			ProcessCommand("/scriptStart FindMyBox.lua");
		end;
		if (Message == "zil" and PartyStop) then
			StopB(true);
			ClearT();
			ShowToClient("[Party]", "Use Zil", 20);
			ProcessCommand("/scriptStart Destr-ZIL.lua");
		end;
		if ( Message == "afk" ) then
			StopB(true);
			ClearT();
			ShowToClient("[Party]", "Stop all Acripts", 20);
			ProcessCommand("/scriptStopAll");
		end;
		if ( Message == "zak" ) then
			ShowToClient("[Party]", "go fight Zaken!",20);
			StopB(true);
			ClearT();
			ProcessCommand("/scriptStopAll");
			ProcessCommand("/scriptStart ZakenIn.lua");
		end;
	 end;
end;