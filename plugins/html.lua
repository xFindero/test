HtmlStatus = false;
--------------------------------------------------------------------------------
function OnCreate()
	this:RegisterCommand("html", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
end;
--------------------------------------------------------------------------------
function OnCommand_html(vCommandChatType, vNick, vCommandParam)
	if (HtmlStatus == false) then
		HtmlStatus = true;
		ShowToClient("Plugin","HTML saved.");
	end;
end;
--------------------------------------------------------------------------------
function OnLTick1s()
	if(HtmlStatus)then
		local file = io.open(GetDir() .. "html.txt", "w");
		file:write(tostring(GetDialogHtml()).. "\n");
		file:close();
		HtmlStatus = false;
	end;
end;