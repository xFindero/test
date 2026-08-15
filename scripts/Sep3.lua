moveDistance = 80;

function ClickAndWait(link, name)
	QuestReply(link)
	Sleep(821)
end

function EnterRoom1()
	TargetNpc("Emperors' Sepulcher Manager", 31922);
	Talk();
	ClickAndWait("npc_268503725_Quest", "Quest");
	ClickAndWait("Quest Q00620_FourGoblets ENTER", "Place your hand on the stone statue and concentrate.");
end

function GoToRoom3()
	MoveTo(178313, -85554, -7221, moveDistance);
	MoveTo(178314, -85557, -7221, moveDistance);
	MoveTo(178311, -87287, -7221, moveDistance);
	MoveTo(178447, -88766, -7224, moveDistance);
	MoveTo(178882, -88934, -7224, moveDistance);
end

function tpTo4Sep()
	while ( GetMe():IsInCombat() ) do
		ShowToClient("[Escape] ", " InCombat: ".. tostring(GetMe():IsInCombat()),20);
		Sleep(5432)
	end
	ClickAndWait("_bbshome", "");
	ClickAndWait("voice .teleporterservice h scl", "");
	ClickAndWait("voice .teleporterservice h sl STC_WORLD_AREAS_GODDARD", "");
	ClickAndWait("voice .teleporterservice t s S_FOUR_SEPULCHERS STC_WORLD_AREAS_GODDARD", "");
		while ( GetMe():GetRangeTo(178132, -84440, -7217) > 500 ) do
			Sleep(1500)
			ShowToClient(tostring(os.date("%X")), "wait", 20);
		end
		ShowToClient(tostring(os.date("%X")), "In 4 sepulchers! GO", 20);
	MoveTo(178132, -84440, -7217, moveDistance);
	-- на ТП 4 sepulchers
	MoveTo(178277, -85354, -7218, moveDistance);
	-- біля НПС
end

if GetMe():GetRangeTo(178313, -85554, -7221) < 600 then	--near start
	GoToRoom3()
else
	if GetMe():GetRangeTo(178882, -88934, -7224) < 500 then	--near 3rd stone
		EnterRoom1()
	else
		tpTo4Sep()
		GoToRoom3()
	end
end