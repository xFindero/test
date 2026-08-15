function FindBox(range)
    local count = 0
    local mobBox = nil
    local monsterlist = GetMonsterList()
    for mob in monsterlist.list do
        if mob:GetDistance() < range and not mob:IsAlikeDeath() then
            if mob:GetName() == "Treasure Chest" then
				mobBox = mob
			end
        end
    end
    return mobBox
end

function GetBoxinTarget()
	ShowToClient(os.date("%X"),  "Have NO target! Get some one")
	targetBox = FindBox(500)
	if targetBox then
		ShowToClient(os.date("%X"),  "Box is Near - target IT!")
		Target(targetBox)
	else
		ShowToClient(os.date("%X"),  "No any Box Near - take OFF!")
		farm = false
	end
end

function ClearT()
    ClearTargets()
    CancelTarget(true)
    Sleep(150)
    ClearTargets()
end

function ClickAndWait(link,name)
	QuestReply(link);
	Sleep(521)
end;
-- =============================================
--- MAIN LOOP ---
ShowToClient(os.date("%X"), "Spoil Boxes in LOA", 20)

farm = true
while farm	do
	local target = GetTarget()
	if target then 
		if  target:GetName() ~= "Treasure Chest" then
			ShowToClient(os.date("%X"),  "Target is NOT Treasure Chest")
			SetPause(true)
			ClearT()
			GetBoxinTarget()
			Sleep(500)
			SetPause(false)
		end
	else
		GetBoxinTarget()
	end
	--ShowToClient(os.date("%X"),  "We have Box in target, next...")
	Sleep (5000)
end

ShowToClient(os.date("%X"), "Exit, no Box Near", 20);
SetPause(true);

while GetMe():IsInCombat() do
        Sleep(2500)
end

if GetMe():IsAlikeDeath() then
	ShowToClient(os.date("%X"), "Return to town")
	RequestRestartPoint(2) -- To Village
	Sleep(5000)
else
	ClickAndWait("_bbshome", "");
	ClickAndWait("voice .teleporterservice h scl", "");
	ClickAndWait("voice .teleporterservice h sl STC_TOWN_AREAS", "");
	ClickAndWait("voice .teleporterservice t s S_HUNTERS STC_TOWN_AREAS", "");
end