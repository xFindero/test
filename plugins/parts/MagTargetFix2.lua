--- v.4.3 + add debug
--- v.4.1 + Fast Mage Nuke Logic (Necro + Spellhowler)
-- ====================== ON CREATE ======================
function OnCreate()
	ShowToClient(tostring(os.date("%X")), "Fast Mage Nuke Plugin v.4.3", 20)
    this:RegisterCommand("mtf", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME)
	-- ====================== SETTINGS ======================
	TimeTillRequestChangeTarget = 1000 * 3   -- 5 sec no activity - change target
	TimeTillTryFixMovement      = 1000 * 2   -- 4 sec no activity - try position change
	MaxUnstuckAttempts          = 2
	MinDistanceToMonster        = 250        -- Minimum safe distance from monster
	moveDist                    = 100        -- Distance to move when trying to unstuck / change position
	ForgetRange                 = 700

	-- ==================== NEW: ATTACK TIMER ====================
    MagAttackInterval		= 2000
    LastMagAttackTime		= 0
	-- ====================== SKILL IDs ======================
	-- Necromancer
	SKILL_CURSE_GLOOM     = 1263   -- Curse Gloom
	SKILL_DEATH_SPIKE     = 1148   -- Death Spike
	SKILL_CURSE_DEATHLINK = 1159   -- Curse Death Link (adjust if different on your chronicle)

	-- Spellhowler
	SKILL_SURRENDER_WIND  = 1074   -- Surrender to Wind
	SKILL_HURRICANE       = 1239   -- Hurricane
	IAmNecr				=	false
	IAmSH				=	false

	-- ====================== GLOBALS ======================
	TargetFixStatus     = false
	IsUnstucking        = false
	UnstuckAttempts     = 0
	mytargetid          = 0
	CurrentTargetId     = 0
	LastCord			= nil
	useItOnce			= false		-- test mode. use skiils caster once
end

function OnCommand_mtf(vCommandChatType, vNick, vCommandParam)
    TargetFixStatus = not TargetFixStatus
	local me = GetMe()
    local classId = me:GetClass()
	whoIAm(classId)
	
    if TargetFixStatus then
        LastCord = me:GetLocation()	 -- Initialize only when activating
        LastActivityTime = GetTime()
        LastUnstuckTime = GetTime()
        LastAwayTime = GetTime()
        UnstuckAttempts = 0
	-- New: per-target debuff tracking
        DebuffApplied = {}
        ShowToClient(tostring(os.date("%X")), "Mage Target Fix + Fast Nuke ACTIVATED", 20)
    else
        ShowToClient(tostring(os.date("%X")), "Mage Target Fix + Fast Nuke DEACTIVATED", 20)
    end
end

-- Helper functions to detect class
function whoIAm(classId)
	--ShowToClient(tostring(os.date("%X")), "Our class: " .. classId, 20)
	if classId == 13 or classId == 93 or classId == 95 then     -- Necromancer
        ShowToClient(tostring(os.date("%X")), "We are a Necromancer: " .. classId, 20)
        if GetSkills():FindById(SKILL_DEATH_SPIKE) ~= nil and GetSkills():FindById(SKILL_CURSE_GLOOM) ~= nil then
            --ShowToClient(tostring(os.date("%X")), "We have needed skills for Necromancer: ", 20)
            IAmNecr	=	true
            IAmSH   =	false
		else
			ShowToClient(tostring(os.date("%X")), "We don't have needed skills for Necromancer!")
			IAmNecr	=	false
			IAmSH   =	false
        end
    elseif classId == 40 or classId == 110 then   -- Spellhowler
        ShowToClient(tostring(os.date("%X")), "We are a Spellhowler: " .. classId, 20)
        if GetSkills():FindById(SKILL_HURRICANE) ~= nil and GetSkills():FindById(SKILL_SURRENDER_WIND) ~= nil then
            --ShowToClient(tostring(os.date("%X")), "We have needed skills for Spellhowler: ", 20)
            IAmNecr	=	false
            IAmSH   =	true
        else
			ShowToClient(tostring(os.date("%X")), "We don't have needed skills for Spellhowler!")
			IAmNecr	=	false
			IAmSH   =	false
		end
    else
        ShowToClient(tostring(os.date("%X")), "Our class: " .. classId .. " Who are you?", 20)
        IAmNecr = false
        IAmSH	= false
    end
end

function magSkillUse(skillID)
	--Log(os.date("%X").." magSkillUse " .. skillID)
	for count=1,5 do
		UseSkill(skillID,false,false)
		--Sleep(350)
    end
end


-- ====================== FAST SKILL CASTING (High frequency) ======================
function MagAttack()
	local startTime = GetTime()
    if not TargetFixStatus or GetMe():IsAlikeDeath() then return end

    local me = GetMe()
    --if not me then return end

    local hpPercent = me:GetHpPercent()
    local target = GetTarget()

    -- Only act on valid monster targets
    if not target or not target:IsMonster() or target:IsAlikeDeath() or me:GetTarget() == 0 then
		ShowToClient(tostring(os.date("%X")), "invalid target, exit MagAttack", 20)
        return
    end

    local tid = target:GetId()

    -- Reset debuff flag on target change
    if mytargetid ~= tid then
		ShowToClient(tostring(os.date("%X")), "new target - clean old debuffs", 20)
        mytargetid = tid
        -- Optional: clean old debuffs if you want (or keep them)
        DebuffApplied = {}
    end

    -- === PRIORITY 1: Low HP - Curse Death Link ===
    if hpPercent <= 30 and (IAmNecr or IAmSH) then
		ShowToClient(tostring(os.date("%X")), "PRIORITY 1: use CURSE_DEATHLINK", 20)
		magSkillUse(SKILL_CURSE_DEATHLINK)
        return
    end

    -- === PRIORITY 2: Normal rotation (HP > 30) ===
    

    if IAmNecr then
		ShowToClient(tostring(os.date("%X")), "IAmNecr, use magick", 20)
        -- First: Curse Gloom (only once per target)
        if not DebuffApplied[tid] then
			ShowToClient(tostring(os.date("%X")), "use debuff on new target", 20)
            if UseSkill(SKILL_CURSE_GLOOM) then
				ShowToClient(tostring(os.date("%X")), "use CURSE_GLOOM", 20)
                DebuffApplied[tid] = true
                return
			else
				ShowToClient(tostring(os.date("%X")), "use SKILL_CURSE_GLOOM failed")
            end
        else
			ShowToClient(tostring(os.date("%X")), "use DEATH_SPIKE", 20)
			magSkillUse(SKILL_DEATH_SPIKE)
        end

    elseif IAmSH then
        -- First: Surrender To Wind (only once per target)
        if not DebuffApplied[tid] then
            if UseSkill(SKILL_SURRENDER_WIND) then
                DebuffApplied[tid] = true
                return
            end
        else
			magSkillUse(SKILL_HURRICANE)
        end
    end
	ShowToClient(os.date("%X"), "out f.MagAttack")
	local elapsedTime = GetTime() - startTime
	ShowToClient(os.date("%X"), "Function executed in " .. elapsedTime .. " ms", 20)
	
end

-- ====================== ORIGINAL 1s TICK (Movement / Unstuck logic) ======================
function OnLTick1s()
    if not TargetFixStatus or GetMe():IsAlikeDeath() or IsPaused() then return end

    local me      = GetMe()
    local target  = GetTarget()
    local now     = GetTime()
    local currentLoc = me:GetLocation()

    local isMoving = GetDistanceVector(currentLoc, LastCord or currentLoc) > 80
    LastCord = currentLoc

    -- Reset activity					 
    if isMoving or (target and me:GetTarget() ~= 0 and me:IsInCombat()) then
        LastActivityTime = now
        UnstuckAttempts = 0
    end
	
    --avoid dead monsters
	if ( target ~= nil and (target:IsMonster() and target:IsAlikeDeath()) ) then
		ShowToClient("[Fix]", "Clear Dead mob ")
		CancelTargets()
	end;
	
    -- No valid monster target							  
    if not target or not target:IsMonster() or target:IsAlikeDeath() or me:GetTarget() == 0 then
        LastActivityTime = now
        mytargetid = 0
        UnstuckAttempts = 0
        CurrentTargetId = 0
        return
    end

    -- New target				 
    if mytargetid ~= target:GetId() then
        mytargetid = target:GetId()
        CurrentTargetId = target:GetId()
        LastActivityTime = now
        UnstuckAttempts = 0
    end

    local idleTime = now - LastActivityTime
    local distToTarget = target:GetDistance()

    -- Keep minimum distance from monster (max once per 3 seconds)																  
    if distToTarget < MinDistanceToMonster and (now - LastAwayTime > 1500) then
        --ShowToClient(tostring(os.date("%X")), "Too close to monster - moving away", 20)
        MoveAwayFromTarget(target)
        LastAwayTime = now
        return
    end
----
    local skillTime = now - LastActivityTime

    -- test start skill use (max once per 5 seconds)																  
    if (now - LastMagAttackTime >= MagAttackInterval) and not useItOnce then
		ShowToClient(tostring(os.date("%X")), "Try fix Mag atk", 20)
        MagAttack()
        LastMagAttackTime = now
		useItOnce = true
    end
----

    -- Change target logic
    if idleTime > TimeTillRequestChangeTarget then
        ShowToClient(tostring(os.date("%X")), "No activity - changing target", 20)
        target:SetBlock(true)
        CancelTargets()
        LastActivityTime = now
        UnstuckAttempts = 0
        CurrentTargetId = 0
        return
    end

    --  Try to change position
    if idleTime > TimeTillTryFixMovement and not IsUnstucking and UnstuckAttempts < MaxUnstuckAttempts then
        ShowToClient(tostring(os.date("%X")), "Position change attempt " .. (UnstuckAttempts + 1), 20)
        IsUnstucking = true
        UnstuckAttempts = UnstuckAttempts + 1
        LastUnstuckTime = now
        TryChangePosition()
        return
    end

	 -- Last resort																				   
    if idleTime > TimeTillTryFixMovement and UnstuckAttempts >= MaxUnstuckAttempts then
		ShowToClient(tostring(os.date("%X")), "Still cannot access target - last resort", 20)				   
        TryLastResortMove()
        LastActivityTime = now
        UnstuckAttempts = 0
        return
    end

    if IsUnstucking and (now - LastUnstuckTime > 2500) then
        IsUnstucking = false
    end
end

-- ====================== MOVE AWAY FROM TARGET ======================
function MoveAwayFromTarget(target)
    local me = GetMe()
    local tgtLoc = target:GetLocation()
    local meLoc = me:GetLocation()

    local dx = meLoc.X - tgtLoc.X
    local dy = meLoc.Y - tgtLoc.Y
    local len = math.sqrt(dx*dx + dy*dy)

    local safeDist = 90

    if len > 0 then
        dx = (dx / len) * safeDist
        dy = (dy / len) * safeDist
    else
        dx = math.random(-safeDist, safeDist)
        dy = math.random(-safeDist, safeDist)
    end

    -- local nearestParty = GetNearestPartyMember()
    -- if nearestParty and nearestParty:GetDistance() < 1200 then
        -- moveToNext(nearestParty)
    -- else
        MoveToNoWait(meLoc.X + dx, meLoc.Y + dy, meLoc.Z)
    -- end
end

-- ====================== GET NEAREST PARTY MEMBER (Fixed) ======================
--[[
function GetNearestPartyMember()
    local me = GetMe()
    local nearest = nil
    local minDist = 99999
    local party = GetPartyList()

    if party then
        for member in party.list do
            if member and not member:IsMe() and not member:IsAlikeDeath() then
                local dist = member:GetDistance()
                if dist < minDist then
                    minDist = dist
                    nearest = member
                end
            end
        end
    end
    return nearest
end
]]

-- ====================== TRY CHANGE POSITION ======================
function TryChangePosition()
    local me = GetMe()
    local PartyLeader = GetPartyMaster()

    if PartyLeader == nil or PartyLeader:IsMe() then
        ShowToClient(tostring(os.date("%X")), "Party Leader - sideways step", 20)
        MovePerpendicularlySimple(me, moveDist)
    else
        ShowToClient(tostring(os.date("%X")), "Moving perpendicular to Party Leader", 20)
        MovePerpendicularlySimple(PartyLeader, moveDist)
    end
end

-- ====================== LAST RESORT MOVE ======================
function TryLastResortMove()
    local PartyLeader = GetPartyMaster()

    if PartyLeader == nil or PartyLeader:IsMe() then
        ShowToClient(tostring(os.date("%X")), "We are party leader - doing delta step", 20)
        deltaMove()
        BlockCurrentTarget()
        return
    end

    local myDist = PartyLeader:GetDistance()
    if myDist >= ForgetRange and myDist <= 2000 then
        ShowToClient(tostring(os.date("%X")), "Moving toward party leader", 20)
        SetPause(true)
        ClearTargets()
        moveToNext(PartyLeader)
        SetPause(false)
        BlockCurrentTarget()
    else
        ShowToClient(tostring(os.date("%X")), "Party leader not in range - sideways step", 20)
        MovePerpendicularlySimple(PartyLeader, moveDist)
        BlockCurrentTarget()
    end
end

-- ====================== DELTA MOVE ======================
function deltaMove()
    local me = GetMe()
    local tx = me:GetLocation().X + math.random(-30, 30) + ((string.sub(MyID or "00", -2)) / 2)
    local ty = me:GetLocation().Y + math.random(-30, 30)
    MoveToNoWait(tx, ty, me:GetLocation().Z)
end

-- ====================== BLOCK CURRENT TARGET ======================
function BlockCurrentTarget()
    local target = GetTarget()
    if target and target:GetId() == CurrentTargetId then
        target:SetBlock(true)
        ShowToClient(tostring(os.date("%X")), "Target blocked after all attempts", 20)
    end
    CancelTargets()
    CurrentTargetId = 0
end
-- ====================== PERPENDICULAR MOVE ======================
function MovePerpendicularlySimple(user, dist)
    local meLoc  = GetMe():GetLocation()
    local refLoc = user:GetLocation()

    local dx = refLoc.X - meLoc.X
    local dy = refLoc.Y - meLoc.Y

    local px = -dy
    local py = dx

    local len = math.sqrt(px*px + py*py)
    if len > 0 then
        px = (px / len) * dist
        py = (py / len) * dist
    else
        px = math.random(-dist, dist)
        py = math.random(-dist, dist)
    end

    if math.random(0,1) == 1 then
        px = -px
        py = -py
    end

    MoveToNoWait(meLoc.X + px + math.random(-35,35),
                 meLoc.Y + py + math.random(-35,35),
                 meLoc.Z)
end

-- ====================== MOVE TO NEXT ======================
function moveToNext(targetUser)
    local locTMP = targetUser:GetLocation()
    local choise = math.random(1,10)

    if choise < 5 then
        if choise <= 3 then
            MoveToNoWait(locTMP.X + math.random(25,50), locTMP.Y + math.random(25,50), locTMP.Z)
        else
            MoveToNoWait(locTMP.X + math.random(25,50), locTMP.Y - math.random(25,50), locTMP.Z)
        end
    else
        if choise <= 8 then
            MoveToNoWait(locTMP.X - math.random(25,50), locTMP.Y - math.random(25,50), locTMP.Z)
        else
            MoveToNoWait(locTMP.X - math.random(25,50), locTMP.Y + math.random(25,50), locTMP.Z)
        end
    end
end
-- ====================== ACTIVITY RESET ======================
function OnMagicSkillUse(user, target, skillId, skillvl, skillHitTime, skillReuse)
    if user:IsMe() and not GetMe():IsAlikeDeath() and TargetFixStatus then
        LastActivityTime = GetTime()
        UnstuckAttempts = 0
    end
end

function OnAttack(user, target)
    if (user:IsMe() or target:IsMe()) and not GetMe():IsAlikeDeath() and TargetFixStatus  then
        LastActivityTime = GetTime()
        UnstuckAttempts = 0
    end
end

function CancelTargets()
    ClearTargets()
    CancelTarget(true)
end

---------------
-- UseSkill(1129, false, false); -- Summon Reanimated Man
-- UseSkill(1263, false, false); -- Curse Gloom
-- UseSkill(1148, false, false); -- Death Spike
-- UseSkill(1159, false, false); -- Curse Death Link
-- UseSkill(1343, false, false); -- Dark Vortex
-- UseSkill(1337, false, false); -- Curse of Abyss
--------------
-- UseSkill(1074, false, false); -- Surrender To Wind
-- UseSkill(1239, false, false); -- Hurricane
-- UseSkill(1341, false, false); -- Wind Vortex