-- ====================== НАЛАШТУВАННЯ ======================
SpoilInterval   = 14
LastCheckTime   = 0
SweepRange		= 400
massSweep		= 444	-- SweeperFestival 
SpoilBomb		= 537	-- Spoil Bomb
SpoilFestival	= 302	-- Spoil Festival
-- ====================== НАЛАШТУВАННЯ ======================

function GetNPCinTarget()
	ShowToClient(os.date("%X"),  "Get some target")
	targetNPC = FindNPC(1200)
	if targetNPC then
		ShowToClient(os.date("%X"),  "NPC is Near - target IT!")
		Target(targetNPC)
		Sleep(500)
		local target = GetTarget()
		if target then 
			ShowToClient(os.date("%X"),  "attackforce")
			Command("/attackforce")
		end
	else
		ShowToClient(os.date("%X"),  "No any NPC Near - take OFF!")
		farm = false
	end
end

function FindNPC(range)
    local mobNPC = nil
    --local monsterlist = GetMonsterList()
    local monsterlist = GetNpcList()
    for mob in monsterlist.list do
        if mob:GetDistance() < range and not mob:IsAlikeDeath() then
            if mob:GetName() == "Triol's Revelation" then
				mobNPC = mob
			end
        end
    end
    return mobNPC
end

function FindMob(range)
    local mobNPC = nil
    local monsterlist = GetMonsterList()
    for mob in monsterlist.list do
        if mob:GetDistance() < range and not mob:IsAlikeDeath() then
            if mob:GetName() == "Ritual Sacrifice" then
				mobNPC = mob
			end
        end
    end
    return mobNPC
end

function SpoilMob()
	local currentTime = GetTime()
	local result = false
	local targetMob
    if (currentTime - LastCheckTime) > SpoilInterval*1000 then
		LastCheckTime = currentTime
		targetMob = FindMob(600)
		if targetMob then
			ShowToClient(os.date("%X"),  "Mob is Near - target IT!")
			Target(targetMob)
			Sleep(500)
			if not UseSkillH(SpoilBomb) then 
				UseSkillH(SpoilFestival)
			end
			result = true
		end
    end
	return result
end

function AttackForce()
	local target = GetTarget()
	if target and target:IsNpc() then 
		ShowToClient(os.date("%X"),  "attackforce")
		Command("/attackforce")
	elseif target:IsMonster() then
		Command("/attack")
	end
end

function ClearT()
	ClearTargets();
	CancelTarget(false);
	Sleep(123);
	ClearTargets();
end


function SweepDrop(range)
	local monsterlist = GetMonsterList();
	local count = 0;
	local corps = 0;
	for mob in monsterlist.list do
		if (mob:GetDistance() < range) then
			if ( mob:IsAlikeDeath() and mob:IsSpoiled() ) then -- mass sweep has range 200-300
				corps = corps + 1
			else
				count = count + 1;
			end;
		end;
	end;
	if ( count > 15 ) then 
		ShowToClient(os.date("%X") .. " mobs around ", "..." .. count, 20);
	end
	if ( corps >= 1 ) then 
		UseSkillH(massSweep)
	end
	return 0
end;

function UseSkillH(skill)
local UseSkill = GetSkills():FindById(skill);
	if (UseSkill ~= nil) and (UseSkill:CanBeUsed() and not GetMe():IsBlocked(true)) then		
			UseSkillRaw(skill, false, false);
			Sleep(300);
	else
		return false
	end;
	return true
end;


function deltaMove(target) 	-- move to the front of the target
	local range = 100;
	if target ~= nil and target:IsValid() then
		--ShowToClient(os.date("%X"), "Back step...",20);
		--local Yaw = RUUToRadiant(target:GetRotation().Yaw) + math.pi;
		--local loc =target:GetLocation();
		--loc.Y = loc.Y + range * math.sin( Yaw )
		--loc.X = loc.X + range * math.cos( Yaw )
		--MoveToNoWait(loc);
		--Sleep(500)
	--else
		ShowToClient(os.date("%X"), "Random step...",20);
		local tx = target:GetLocation().X + math.random(-200, 200)
		local ty = target:GetLocation().Y + math.random(-200, 200)
		MoveToNoWait(tx, ty, GetMe():GetLocation().Z);
		Sleep(1000)
	end;
end;

function RUUToRadiant(x) --0 to 2*pi
return (math.pi/180) * (360/math.pow(2,16)) * x;
end;

-- =============================================
--- MAIN LOOP ---
ShowToClient(os.date("%X"), "Spoil in Pagan", 20)
SetPause(true)
farm = true
while farm	do
	local target = GetTarget()
	if target then 
		if  target:GetName() ~= "Triol's Revelation" then
			ShowToClient(os.date("%X"),  "Target is NOT `Triol's Revelation`")
			ClearT()
			GetNPCinTarget()
			AttackForce()
		else
			ShowToClient(os.date("%X"),  "Target is `Triol's Revelation`", 20 )
			ShowToClient(os.date("%X"),  "Lets spoil someone!", 20 )
			if SpoilMob() then 
				ShowToClient(os.date("%X"),  "Mob spoiled - target NPC", 20 )
				GetNPCinTarget()
				deltaMove(target)
				AttackForce()
			end
		end
	else
		ShowToClient(os.date("%X"),  "We have no target")
		GetNPCinTarget()
		AttackForce()
	end
	Sleep(5000)
	SweepDrop(SweepRange)
	AttackForce()
	Sleep(5000)
	SweepDrop(SweepRange)
	AttackForce()
end

ShowToClient(os.date("%X"), "Exit, no NPC Near", 20);
SetPause(true);