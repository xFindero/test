timeToStart = "14:41"	-- 7:48  or 11:35   4 or 5 symbols
-----------------------
me				= GetMe();
MyID			= me:GetId();
moveDistance	= 80
Finished		= false
CheckSoundDC	= GetDir() .. "\\sound\\found.wav";

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
	local tx = GetMe():GetLocation().X + math.random(-50, 50)+ ((string.sub(MyID,-2))/2)
	local ty = GetMe():GetLocation().Y + math.random(-50, 50)
	MoveToNoWait(tx, ty, GetMe():GetLocation().Z);
end

function GoToBattleField()
	if ( GetMe():GetRangeTo(152477, 57389, -3286) < 1000 ) then
		MoveTo(152477, 57389, -3286, moveDistance);
		MoveTo(152816, 57203, -3282, moveDistance);
		MoveTo(153142, 57228, -3246, moveDistance);
		MoveTo(153511, 57361, -3257, moveDistance);
		MoveTo(154433, 57739, -3245, moveDistance);
		MoveTo(154780, 57755, -3207, moveDistance);
		MoveTo(155151, 57611, -3221, moveDistance);
		MoveTo(155326, 57439, -3251, moveDistance);
		MoveTo(155326, 57445, -3250, moveDistance);
		deltaMove()
	else
		ShowToClient(tostring(os.date("%X")), "We not near Narsel Fortess", 19);
		Sound();
	end
	Finished = true
end

----------- main -------------

TimeVarLen = string.len(timeToStart)

ShowToClient(tostring(os.date("%X")), "Time: " .. string.sub(os.date("%X"),1,TimeVarLen), 20);
ShowToClient(tostring(os.date("%X")), "Var: " .. timeToStart, 20);
if ( GetMe():GetRangeTo(152477, 57389, -3286) < 1000 ) then
	ShowToClient(tostring(os.date("%X")), "We near Narsel Fortess - move to BF at time", 20);
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
	ShowToClient(tostring(os.date("%X")), "We not near Narsel Fortess", 19);
end
ShowToClient(tostring(os.date("%X")), "Finished.", 20);