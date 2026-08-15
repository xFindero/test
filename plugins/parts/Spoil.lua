spoilMsg1 = "The Spoil condition has been activated.";
spoilMsg2 = "                   <<< SPOIL SUCCESSFUL!!! >>>";
spoilMsg3 = "It has already been spoiled.";
cantSpoilMsg1 = "There are no priority rights on a sweeper.";
cantSpoilMsg2 = "Sweeper failed, target not spoiled.";
cantSpoilMsg3 = "cannot be used due to unsuitable terms.";

SpoilMsg = {"The Spoil condition has been activated." ,"It has already been spoiled." , "                   <<< SPOIL SUCCESSFUL!!! >>>"};
cantSpoilMsg = {"There are no priority rights on a sweeper.", "Sweeper failed, target not spoiled.","cannot be used due to unsuitable terms."};

SpoilSkillCommand = "/useskill Spoil";
--------------------------------------------------------------------------------
SpoilStatus = false;
Spoiled = false;
tempId = 0;
--------------------------------------------------------------------------------
function OnCreate()
	this:RegisterCommand("spoil", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
end;
--------------------------------------------------------------------------------
function OnCommand_spoil(vCommandChatType, vNick, vCommandParam)
	if (SpoilStatus == false) then
		SpoilStatus = true;
		ShowToClient("Plugin","Automatic Spoil Mode ACTIVATED.");
	else
		SpoilStatus = false;
		ShowToClient("Plugin","Automatic Spoil Mode DEACTIVATED.");	
	end;
end;
--------------------------------------------------------------------------------
function CheckIfInsideList(Smsg,Rmsglist)
	for x,y in pairs(Rmsglist) do
		if (y == Smsg) then
			return true;
		end;
	end;
	return false;
end;
--------------------------------------------------------------------------------
function OnChatSystemMessage(id, msg)
	if (((msg == spoilMsg1) or (msg == spoilMsg2)or (msg == spoilMsg3)) and (SpoilStatus == true)) then
		Spoiled = true;
		if (GetTarget() ~= nil)then
			tempId = GetTarget():GetId();
		end;
	end;
	if (((msg == cantSpoilMsg1) or (msg == cantSpoilMsg2)or (msg == cantSpoilMsg3)) and (SpoilStatus == true)) then
		ClearTargets();
		CancelTarget(false);
		CancelTarget(false);
		CancelTarget(false); 
	end;
end;
--------------------------------------------------------------------------------
function IfDeadAndSpoiledInRange(range)
	local l = GetMonsterList();
	for monst in l.list do 
		if ((monst:IsAlikeDeath() == true) and (monst:IsSpoiled() == true) and (monst:GetRangeTo(GetMe()) < range)) then
			return monst:GetId();
		end;		
	end;
	return nil;
end;
--------------------------------------------------------------------------------
function OnLTick1s()
	if(SpoilStatus) and (IsPaused() == false)then
		
		local Me = GetMe();
		if (Me:IsAlikeDeath() == false) and (Me ~= nil) then
			----------------------------------- spoil
			if (GetTarget() ~= nil)then
				if(GetTarget():IsMonster()) 
					and (Me:GetRangeTo(GetTarget()) < 100) 
					and (Spoiled == false) and (Me:GetMpPercent() > 10 ) 
					and (GetTarget():GetId() ~= tempId)then
					Command(SpoilSkillCommand);
				else
					Spoiled = false;
				end;
			end;
			----------------------------------- Seeper
			TempIdOfSpoiledMob = IfDeadAndSpoiledInRange(300);
			if(TempIdOfSpoiledMob ~= nil)then
				TargetRaw(TempIdOfSpoiledMob); --target mob witch is spoiled
				Command("/useskill Sweeper"); --Sweeper
			end;			
		end;
	end;
end;