-----------------------
timeToStart = "15:30"		-- 7:48  or 11:35   4 or 5 symbols
-----------------------
moveDistance = 80
Finished = false
me = GetMe();
MyID = me:GetId();
CheckSoundDC = GetDir() .. "\\sound\\found.wav";

function Sound()
	local result = false;
	if ( PlaySound(CheckSoundDC)) then
		--ShowToClient("#", "Succes!")
		result = true;
	else
		ShowToClient("#", "Fail to play sound!")
	end
	return result
end

function deltaMove()
	--ShowToClient(tostring(os.date("%X")), "Delta step...",20);
	local tx = GetMe():GetLocation().X + math.random(-50, 50)+ ((string.sub(MyID,-2)))
	local ty = GetMe():GetLocation().Y + math.random(-50, 50)
	MoveToNoWait(tx, ty, GetMe():GetLocation().Z);
end

function GoToBattleField()
	if ( GetMe():GetRangeTo(18886, 190933, -2841) < 1000 ) then
		MoveTo(18930, 190950, -2861, moveDistance);
		MoveTo(18876, 190862, -2810, moveDistance);
		MoveTo(18810, 190747, -2780, moveDistance);
		MoveTo(18457, 190428, -2935, moveDistance);
		MoveTo(17991, 190189, -2935, moveDistance);
		MoveTo(17737, 190094, -2926, moveDistance);
		MoveTo(17612, 190346, -2921, moveDistance);
		deltaMove()
	else
		ShowToClient(tostring(os.date("%X")), "We not near Hive Fortess", 20);
		Sound();
	end
	Finished = true
end

----------- main -------------

TimeVarLen = string.len(timeToStart)

ShowToClient(tostring(os.date("%X")), "Time: " .. string.sub(os.date("%X"),1,TimeVarLen), 20);
ShowToClient(tostring(os.date("%X")), "TimeToStart: " .. timeToStart, 20);
if ( GetMe():GetRangeTo(18886, 190933, -2841) < 1000 ) then
	ShowToClient(tostring(os.date("%X")), "We near Hive Fortess - move to BF at time", 20);
	while ( not Finished ) do
		
		if ( (string.sub(os.date("%X"),1,TimeVarLen)) == timeToStart ) then
			ShowToClient(tostring(os.date("%X")), "Time to move.", 20);
			--Sound();
			GoToBattleField();
			Sleep(500)
		else
			--ShowToClient(tostring(os.date("%X")), "Waiting ...", 20);
			Sleep(15000)
		end
	end
else
	ShowToClient(tostring(os.date("%X")), "We not near Hive Fortess", 19);
end
ShowToClient(tostring(os.date("%X")), "Finished.", 20);