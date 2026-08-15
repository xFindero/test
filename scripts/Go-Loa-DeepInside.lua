-----------------
moveDistance	= 80;
HardMarch		= 479	-- Hard March
-----------------

function ClickAndWait(link,name)
	QuestReply(link);
	Sleep(421)
end;

function UseSkillH(skill)
	if ( skill ~= nil ) then
		local UseSkill = GetSkills():FindById(skill);
		if (UseSkill ~= nil) and (UseSkill:CanBeUsed() and not GetMe():IsBlocked(true)) then		
				UseSkillRaw(skill, false, false);
				--Sleep(200);
		else
			if (UseSkill == nil) then
				ShowToClient(tostring(os.date("%X")), "Skill " .. skill .. " not found", 20);
			end
		end;
	else
		ShowToClient(tostring(os.date("%X")), "Skill " .. tostring(skill) .. " is nil", 20);
	end

end;

function ClearT()
	ClearTargets();
	CancelTarget(true);
	Sleep(123);
	ClearTargets();
end

ClickAndWait("_bbshome", "");
ClickAndWait("voice .teleporterservice h scl", "");
ClickAndWait("voice .teleporterservice h sl STC_TOWN_AREAS", "");
ClickAndWait("voice .teleporterservice t s S_HUNTERS STC_TOWN_AREAS", "");
Sleep(5000)
MoveTo(117240, 76802, -2695, moveDistance);
TargetNpc("Separated Soul", 32864);
Talk();
ClickAndWait("Quest SeparatedSoul 6", "Deep inside Antharas' Lair");
Sleep(5000)
MoveTo(148452, 110577, -3950, moveDistance);
UseSkillH(HardMarch);
MoveTo(148440, 110559, -3950, moveDistance);
MoveTo(147963, 110281, -3950, moveDistance);
MoveTo(146880, 109678, -3950, moveDistance);
MoveTo(145888, 109158, -3950, moveDistance);
MoveTo(145390, 108722, -3950, moveDistance);
MoveTo(145371, 108706, -3950, moveDistance);
MoveTo(145371, 108706, -3950, moveDistance);
MoveTo(144959, 108372, -3941, moveDistance);
MoveTo(144264, 107725, -3950, moveDistance);
MoveTo(143780, 107365, -3950, moveDistance);
MoveTo(143153, 107214, -3950, moveDistance);
MoveTo(143113, 107215, -3950, moveDistance);
MoveTo(143085, 107215, -3950, moveDistance);
MoveTo(143085, 107215, -3950, moveDistance);
MoveTo(142574, 107224, -3949, moveDistance);
MoveTo(142446, 107226, -3950, moveDistance);
MoveTo(141178, 107251, -3950, moveDistance);
MoveTo(140801, 107349, -3950, moveDistance);
MoveTo(140645, 107599, -3950, moveDistance);
MoveTo(140691, 108018, -3950, moveDistance);
MoveTo(140905, 108182, -3950, moveDistance);
MoveTo(141126, 108465, -3950, moveDistance);
MoveTo(141136, 108477, -3950, moveDistance);
MoveTo(141136, 108477, -3950, moveDistance);
MoveTo(141450, 108875, -3950, moveDistance);
MoveTo(141834, 109322, -3950, moveDistance);
MoveTo(142169, 109530, -3950, moveDistance);
MoveTo(142169, 109530, -3950, moveDistance);
MoveTo(142401, 109862, -3941, moveDistance);
MoveTo(142452, 110058, -3950, moveDistance);
MoveTo(142627, 111187, -3950, moveDistance);
MoveTo(142921, 111411, -3950, moveDistance);
ClearT()
Sleep(3000)
UseSkillH(HardMarch);