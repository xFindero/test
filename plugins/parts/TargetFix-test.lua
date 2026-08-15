TargetFix = false;
--------------------------------------------------------------------------------
function OnCreate()
	this:RegisterCommand("test", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
end;
--------------------------------------------------------------------------------
function OnCommand_test(vCommandChatType, vNick, vCommandParam)
	if (TargetFix == false) then
		TargetFix = true;
		ShowToClient("TF","TargetFix ACTIVATED.");
	else
		TargetFix = false;
		ShowToClient("TF","TargetFix DEACTIVATED.");	
	end;
end;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function OnLTick1s()
	if(TargetFix) and (IsPaused() == false)then
		
		local Me = GetMe();
		Mob = GetTarget();
		if (Me:IsAlikeDeath() == false) then
			----------------------------------- spoil
			if (Mob ~= nil)then
				if(Mob:IsMonster() and Mob:IsAlikeDeath() ) then
					ShowToClient("[Fix]", tostring(os.date("%X")) .. "My dead mob" , L2ChatType.CHAT_HERO);
					ClearTargets();
					CancelTarget(false);
					Command("/useshortcut 1 1");
				end;
			else
					ShowToClient("TF","no action need");
			end;
		end;
		
	end;
end;


ShowToClient("-", "-------------------------");
ShowToClient("#", tostring(os.date("%X")), L2ChatType.CHAT_HERO);
ShowToClient("#", "[Target Fix]", L2ChatType.CHAT_HERO);