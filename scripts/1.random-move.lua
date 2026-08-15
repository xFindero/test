function deltaMove(target)
	--ShowToClient(os.date("%X"), "Delta step...",20);
	local tx = target:GetLocation().X + math.random(-100, 100)
	local ty = target:GetLocation().Y + math.random(-100, 100)
	MoveToNoWait(tx, ty, GetMe():GetLocation().Z);
end
MoveDelayTime = 25	--sec

ShowToClient(os.date("%X"), "lets start some move", 20);
repeat
	local me = GetMe();
	local MyTarget = GetTarget();
	if MyTarget and MyTarget:IsMonster() and not MyTarget:IsAlikeDeath() then
		if not IsPaused() and not GetMe():IsAlikeDeath() and me:IsInCombat() then																																									
			
			local target = GetTarget()
			if target then
				deltaMove(target)
				Sleep(250)
				--ShowToClient(os.date("%X"), "Attack target ID: " .. target:GetId(),20);
				Attack(target:GetId(),false)
			else
				deltaMove(me)
				Sleep(250)
				ShowToClient(os.date("%X"), "No target, use Nxtg-1.1",20);
				Command("/useshortcut 1 1")
			end
			local SleepTime = MoveDelayTime*1000 + math.random(-5000, 25000);
			--ShowToClient(os.date("%X"), "SleepTime:" .. SleepTime/1000, 20);
			Sleep(SleepTime);
		else
			ShowToClient(os.date("%X"), "IsPaused or Dead", 20);
			Sleep(10000);
		end;
	else
		ShowToClient(os.date("%X"), "No target", 20);
		Sleep(10000);
	end
	Sleep(1000);	
until false;