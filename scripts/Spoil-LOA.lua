----------------------------------
-- SPOIL HUNTER v3.2 - High Five (L2Tower)
-- Пріоритет Bloody Karinness + жорстка прив'язка до PartyMaster
-- Фінальна версія за твоїми правками
----------------------------------

-- Skills
Rush        = 998   -- Blazing Boost
Sweep       = 42    -- Sweeper
MassSweep   = 444   -- Sweeper Festival

-- Config
IdleCheckTime     = 15
MaxDistFromLeader = 400
CombatRange       = 350
MassSweepRange    = 250

----------------------------------
-- Helpers
----------------------------------
function RUUToRadians(x)
    return (math.pi / 180) * (360 / math.pow(2, 16)) * x
end

function GetBackPosition(target, distance)
    if not target or not target:IsValid() then return nil end
    local yaw = RUUToRadians(target:GetRotation().Yaw) + math.pi
    local loc = target:GetLocation()
    loc.X = loc.X + distance * math.cos(yaw)
    loc.Y = loc.Y + distance * math.sin(yaw)
    return loc
end

function ClearTargetSafe()
    ClearTargets()
    CancelTarget(false)
    Sleep(150)
    ClearTargets()
end

function UseSkillSafe(skillId)
    local sk = GetSkills():FindById(skillId)
    if sk and sk:CanBeUsed() and not GetMe():IsBlocked(true) then
        UseSkillRaw(skillId, false, false)
        Sleep(180)
        return true
    end
    return false
end

----------------------------------
-- Mass Sweep
----------------------------------
function MasSweepCheck()
    local monsterlist = GetMonsterList()
    for mob in monsterlist.list do
        if mob:GetDistance() < MassSweepRange and mob:IsAlikeDeath() and mob:IsSpoiled() then
            UseSkillSafe(MassSweep)
            Sleep(250)
            return true
        end
    end
    return false
end

----------------------------------
-- Target Selection
----------------------------------
function FindBestTarget()
    local monsters = GetMonsterList()
    local best = nil
    local bestScore = -1
    local partyMaster = GetPartyMaster() or GetMe()

    for mob in monsters.list do
        local distToMe = mob:GetDistance()
        local distToLeader = mob:GetRangeTo(partyMaster)

        if distToLeader > MaxDistFromLeader or distToMe > CombatRange or mob:IsAlikeDeath() then
            goto continue
        end

        local score = 10000 - distToMe * 3

        -- Найвищий пріоритет
        if mob:GetName() == "Bloody Karinness" then
            score = score + 100000
        end

        if not mob:IsSpoiled() then
            score = score + 8000
        end

        if mob:IsAttacking() then
            score = score + 1500
        end

        if score > bestScore then
            bestScore = score
            best = mob
        end

        ::continue::
    end

    if best and (GetTarget() == nil or GetTarget():GetId() ~= best:GetId()) then
        Target(best)
        Sleep(250)
    end
end

----------------------------------
-- Handle Target
----------------------------------
function HandleTarget()
    local target = GetTarget()
    if not target then return false end

    local partyMaster = GetPartyMaster() or GetMe()
    local distToLeader = target:GetRangeTo(partyMaster)

    -- Forget target if too far from PartyMaster
    if distToLeader > MaxDistFromLeader then
        ShowToClient(tostring(os.date("%X")), "Forget target - too far from PartyMaster", 20)
				
        SetPause(true)
        if target:IsValid() then
            target:SetBlock(true)
        end
        ClearTargetSafe()
        AntiIdle()
        Sleep(1000)
        SetPause(false)
				
        return false
    end

    if target:IsAlikeDeath() then
        if target:IsSpoiled() then
            UseSkillSafe(Sweep)
        else
            ClearTargetSafe()
        end
        return true
    end

    if target:IsMonster() and not target:IsAlikeDeath() then
        local dist = target:GetDistance()

        if dist > 280 and dist < 900 then
            UseSkillSafe(Rush)
        end	  
    end
    return true
end

----------------------------------
-- Anti-Idle
----------------------------------
function AntiIdle()
    local now = GetTime()
    if now - lastLocCheck < IdleCheckTime * 1000 then return end

    lastLocCheck = now
    local master = GetPartyMaster() or GetMe()
    local dist = GetMe():GetRangeTo(master)

    if dist > 320 then
        MoveToNoWait(master:GetLocation())
        Sleep(450)
    else
        local meLoc = GetMe():GetLocation()
        MoveToNoWait(meLoc.X + math.random(-40,40), meLoc.Y + math.random(-40,40), meLoc.Z)
        Sleep(320)
    end
end

----------------------------------
-- Main Variables
----------------------------------
lastLocCheck = 0
isPausedState = false

----------------------------------
-- MAIN LOOP
----------------------------------
ShowToClient(tostring(os.date("%X")), "[Spoil Hunter v3.4 - Bloody Karinness Priority] Loaded", 20)

while true do
    -- === ПЕРСОНАЖ ПОМЕР ===
    if GetMe():IsAlikeDeath() then
        if not isPausedState then
            isPausedState = true
            ShowToClient(tostring(os.date("%X")), "[STOP] Character died - paused", 20)
            SetPause(true)
        end
        Sleep(2000)
    
    -- === Звичайна пауза або Peace zone ===
    elseif IsPaused() or GetZoneType() == L2ZoneType.PEACEFUL then
        if not isPausedState then
            isPausedState = true
            ShowToClient(tostring(os.date("%X")), "[STOP] Script paused (manual / peaceful zone)", 20)
        end
        Sleep(2500)
    
    -- === ВІДНОВЛЕННЯ ===
    else
			 
        if isPausedState then
            isPausedState = false
            SetPause(false)
            ShowToClient(tostring(os.date("%X")), "[RESUME] Character resurrected - Script resumed", 20)
            Sleep(800)
        end

        AntiIdle()
        FindBestTarget()
        HandleTarget()
        MasSweepCheck()

        Sleep(650 + math.random(-150, 450))
    end
end