----------------------------------
-- Fear All - Nornil Cave Farmer (High Five)
-- v.5 2026-04-30 - Fixed GetLocation() + Reduced Dancing
-- v.3 2026-04-29 - Safe Pause + Movement Fix
----------------------------------
DebugMode			= true
msgCounter			= 0
lastLocCheck		= 0
idleTime			= 5		-- 5 seconds inactivity
fightTime			= 45	-- in munites, time to fight
LastRestTime		= GetTime()		-- Global variable for timer (do not delete)
minPartyMembers		= 2			-- minimum members in party without PL
bonusHat			= {31303, 31302, 31301}
FightRange			= 850
FearRange			= 800
ForgetRange			= 950
FearSkill			= 1169
AlarmSound			= GetDir() .. "\\sound\\alarm.wav"

-- =============================================
function Log(text)
    if DebugMode then
        ShowToClient(os.date("%X"), " [FearAll] " .. text, 20)
    end
end

function Sound(alarm)
    if not PlaySound(alarm) then
        ShowToClient("#", "Sound Failed!", 20)
    end
end

function ClearT()
    ClearTargets()
    CancelTarget(true)
    Sleep(150)
    ClearTargets()
end

function BonusHatOn()
	if GetTime() - LastHatCheck < 60000 then return end
	--Log("Bonus Hat check: Last " .. LastHatCheck .. " Now " .. GetTime() .. " Diff " .. (GetTime() - LastHatCheck))
    local invList = GetInventory()
    LastHatCheck = GetTime()
    for item in invList.list do
        for i = 1, #bonusHat do
            if item.displayId == bonusHat[i] then
                if item.IsEquipped then
                    Log("Bonus Hat already equipped: " .. item.Name)
                    return
                elseif not item.IsEquipped then
                    UseItem(bonusHat[i])
                    Log("Trying to equip hat: " .. item.Name)
                    Sleep(800)
                    return
                end
            end
        end
    end
end

function UseSkillH(skill)
    if skill == nil then return false end
    local sk = GetSkills():FindById(skill)
    if sk ~= nil and sk:CanBeUsed() and not GetMe():IsBlocked(true) then
        UseSkillRaw(skill, false, false)
        return true
    else
        if DebugMode and sk == nil then
            Log("Skill " .. skill .. " not found!")
        end
        return false
    end
end

-- Count monsters in range (used in idle check and movement safety)
function MobsAround(range)
    local count = 0
    local monsterlist = GetMonsterList()
    for mob in monsterlist.list do
        if mob:GetDistance() < range and not mob:IsAlikeDeath() then
            count = count + 1
        end
    end
    return count
end

-- =============================================
function NearestMonster(range)
    local monsterlist = GetMonsterList()
    local nearest = nil
    local minDist = 999999

    for mob in monsterlist.list do
        local dist = mob:GetDistance()
        if dist < range and not mob:IsAlikeDeath() then
            if dist < minDist then
                minDist = dist
                nearest = mob
            end
        end
    end
    return nearest
end

-- =============================================
function FearAllAttacking(range)
    local fearedAny = false
    local monsterlist = GetMonsterList()

    for mob in monsterlist.list do
        if mob:GetDistance() < range and not mob:IsAlikeDeath() and mob:IsAttacking() then
            Target(mob)
            Sleep(150)

            if GetTarget() and GetTarget():GetId() == mob:GetId() then
                if UseSkillH(FearSkill) then
                    --Log("Feared attacking mob: " .. mob:GetName())
                    Sleep(220)
                    fearedAny = true

                    if GetTarget() and not GetTarget():IsAttacking() then
                        --Log("Fear confirmed on " .. mob:GetName())
                    end
                end
            end
        end
    end
    return fearedAny
end

-- =============================================
function CombatCycle()
    local me = GetMe()

    -- 1. Fix broken / dead / far target
    local myTarget = GetTarget()
    if myTarget then
        if myTarget:GetDistance() > ForgetRange then
            ClearT()
        elseif myTarget:IsMonster() and myTarget:IsAttacking() and myTarget:GetDistance() < FearRange then
            --Log("Current target attacking us - Fear!")
            UseSkillH(FearSkill)
            Sleep(350)
        end
    end

    -- 2. Highest priority: Fear ALL attacking monsters in range
    FearAllAttacking(FightRange)

    -- 3. Target nearest safe monster (short range only) and let L2Tower kill it
    local nearest = NearestMonster(FightRange)
    if nearest then
        local dist = nearest:GetDistance()

        if dist > 500 then
            MoveToNoWait(nearest:GetLocation().X + math.random(-80,80),
                         nearest:GetLocation().Y + math.random(-80,80),
                         nearest:GetLocation().Z)
            Sleep(250)
        end

        Target(nearest)
        Sleep(250)

        local newTarget = GetTarget()
        if newTarget and newTarget:IsAttacking() then
            --Log("New target attacking - Fear immediately")
            UseSkillH(FearSkill)
            Sleep(300)
		--else
            --Log("Targeting: " .. nearest:GetName() .. " | Dist: " .. math.floor(dist))
        end
    else
        if not me:IsInCombat() then
            --Log("No valid targets in range")
        end
    end
end

-- =============================================
function CheckIdle()
    if GetTime() - lastLocCheck > idleTime*1000 then
        lastLocCheck = GetTime()

        local mobsNear = MobsAround(FightRange)

        if not GetMe():IsInCombat() or mobsNear < 1 then
            Log("Idle detected - Starting ChangePoint")
            SetPause(true)
            ClearT()
            ChangePoint()          -- Safe version below
            SetPause(false)
            Log("ChangePoint finished - re-enabled")
        end
    end
	return
end

----------------------------------
-- Advanced ChangePoint() with 60-min Return Timer
----------------------------------
function ChangePoint()
    Log("=== ChangePoint() STARTED ===")
    
    local wasPaused = IsPaused()
    if not wasPaused then 
        SetPause(true) 
    end

    local status, err = pcall(function()
        local me = GetMe()
        local moveRadius = 85
        local checkInterval = 650

        -- ================== WAYPOINTS ==================
        local RestPoint = {x = -85062, y = 53661, z = -4625, tolerance = 200, name = "Rest Point"}

        local Points = {
			{x = -84585, y = 54748, z = -4792, tolerance = 200, name = "Point 1"},
			{x = -84218, y = 54819, z = -4792, tolerance = 200, name = "Point 2"},
			{x = -83541, y = 54860, z = -4888, tolerance = 200, name = "Point 3"},
			{x = -82760, y = 54753, z = -4888, tolerance = 200, name = "Point 4"},
			{x = -82083, y = 54791, z = -4792, tolerance = 200, name = "Point 5"},
			{x = -82583, y = 54862, z = -4888, tolerance = 200, name = "Point 6"},
			{x = -83348, y = 54834, z = -4888, tolerance = 200, name = "Point 7"},
			{x = -84100, y = 54760, z = -4792, tolerance = 200, name = "Point 8"}
        }

        -- ================== TIMER & PARTY CHECK ==================
        local shouldGoRest = false
        local reason = ""

        -- 60 minutes forced return to Rest Point
        if GetTime() - LastRestTime > fightTime * 60 * 1000 then
            shouldGoRest = true
            reason = fightTime .. "minutes timer reached"
            LastRestTime = GetTime()   -- reset timer
        end

        -- Party check
        if not shouldGoRest then
            local master = GetPartyMaster()
            if master == nil then
                shouldGoRest = true
                reason = "No party master (not in party)"
            else
                local distToMaster = me:GetRangeTo(master)
                if distToMaster > 2000 then
                    shouldGoRest = true
                    reason = "Party master too far (" .. math.floor(distToMaster) .. ")"
                elseif GetPartyList() and GetPartyList():GetCount() < minPartyMembers then
                    shouldGoRest = true
                    reason = "Party member lost, in paty: " .. tostring(GetPartyList():GetCount())
                end
            end
        end

        -- ================== CHOOSE DESTINATION ==================
        local targetWP

        if shouldGoRest then
            targetWP = RestPoint
            Log("RETURNING TO REST POINT. Reason: " .. reason)
        else
            -- Normal cycle
            if me:GetRangeTo(RestPoint.x, RestPoint.y, RestPoint.z) < 650 then
                targetWP = Points[1]
                Log("At Rest Point - Moving to Point 1")
            else
                -- Find current point
                local currentIdx = 0
                local closestDist = 999999

                for i, wp in ipairs(Points) do
                    local dist = me:GetRangeTo(wp.x, wp.y, wp.z)
                    if dist < closestDist then
                        closestDist = dist
                        currentIdx = i
                    end
                end

                if currentIdx == 0 then
                    targetWP = Points[1]
                else
                    local nextIdx = currentIdx % #Points + 1
                    targetWP = Points[nextIdx]
                    Log("Cycling: " .. Points[currentIdx].name .. " -> " .. targetWP.name)
                end
            end
        end

        -- ================== PERFORM MOVEMENT ==================
        local attempts = 0
        local maxAttempts = 3

        while attempts < maxAttempts do
            attempts = attempts + 1

            local rx = targetWP.x + math.random(-moveRadius, moveRadius)
            local ry = targetWP.y + math.random(-moveRadius, moveRadius)

            MoveToNoWait(rx, ry, targetWP.z)
            Log("MoveToNoWait to " .. (targetWP.name or "Rest") .. " -> " .. rx .. ", " .. ry)

            Sleep(550 + math.random(150, 300))

            local startTime = GetTime()
            local arrived = false

            while (GetTime() - startTime) < 10000 do
                me = GetMe()

                -- Safety checks
                -- if me:GetHpPercent() < 45 then
                    -- Log("LOW HP during movement! Aborting.")
                    -- ClearT()
                    -- return
                -- end

                if me:IsInCombat() or MobsAround(700) > 1 then
                    Log("Monsters detected during movement! Aborting.")
                    ClearT()
                    return
                end

                -- Arrival check
                if me:GetRangeTo(targetWP.x, targetWP.y, targetWP.z) < targetWP.tolerance then
                    arrived = true
                    Log("Successfully arrived at " .. (targetWP.name or "Rest Point"))
                    break
                end

                -- Random micro-move (fixed for your L2Tower version)
                -- if math.random(1, 100) <= 35 then
					-- Log("Random micro-move started")
                    -- local loc = me:GetLocation()
                    -- local mx = loc.X + math.random(-70, 70)
                    -- local my = loc.Y + math.random(-70, 70)
                    -- MoveToNoWait(mx, my, loc.Z)
                    -- Sleep(300)
                -- end

                Sleep(checkInterval)
            end

            if arrived then
                Sleep(1200 + math.random(400, 1300))
                break
            else
                Log("Attempt " .. attempts .. " failed")
                Sleep(1000)
            end
        end

        if not arrived and attempts >= maxAttempts then
            Log("Failed to reach destination after max attempts!")
            --Sound(AlarmSound)
        end

    end)

    if not status then
        Log("ERROR in ChangePoint(): " .. tostring(err))
        Sound(AlarmSound)
    end

    -- ALWAYS re-enable L2Tower
    if IsPaused() then
        SetPause(false)
    end

    --Log("=== ChangePoint() FINISHED (Bot re-enabled) ===")
end

-- =============================================
--- MAIN LOOP ---
ShowToClient(os.date("%X"), "[Fear All] Script Started - Debug: " .. tostring(DebugMode), 20)
LastHatCheck = GetTime()

while true do
    -- Resurrection / Pause handling
    while GetMe():IsAlikeDeath() or IsPaused() do
        if msgCounter < 1 then
            if not IsPaused() then
                SetPause(true)
            else
                Log("Waiting for resurrection or unpause...")
            end
            msgCounter = msgCounter + 1
        end
        Sleep(4500 + math.random(300, 1200))
    end
    msgCounter = 0

    BonusHatOn()
    CheckIdle()
    CombatCycle()

    Sleep(800 + math.random(80, 220))
end

ShowToClient(os.date("%X"), "[Fear All] Script Stopped", 20)