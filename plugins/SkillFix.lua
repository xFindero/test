--- v.1 WL togle Focus Attack
-- ====================== SETTINGS ======================
TimeTillRequestChangeTarget = 1000 * 3   -- 5 sec no activity - change target

-- ====================== GLOBALS ======================
TargetFixStatus     = false
LastActivityTime    = GetTime()
LastUnstuckTime     = GetTime()
LastAwayTime        = GetTime()          -- For limiting MoveAwayFromTarget
IsUnstucking        = false
UnstuckAttempts     = 0
mytargetid          = 0
LastCord            = {X=0, Y=0, Z=0}
CurrentTargetId     = 0

-- ====================== ON CREATE ======================
function OnCreate()
    this:RegisterCommand("sf", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME)
end

function OnCommand_sf(vCommandChatType, vNick, vCommandParam)
    TargetFixStatus = not TargetFixStatus
    
    if TargetFixStatus then
        LastCord = GetMe():GetLocation()          -- Initialize only when activating
        LastActivityTime = GetTime()
        LastUnstuckTime = GetTime()
        LastAwayTime = GetTime()
        UnstuckAttempts = 0
        ShowToClient(tostring(os.date("%X")), "Mage Target Fix ACTIVATED", 20)
    else
        ShowToClient(tostring(os.date("%X")), "Mage Target Fix DEACTIVATED", 20)
    end
end

-- ====================== CANNOT SEE TARGET ======================
function OnChatSystemMessage(id, msg)
    if id == 181 and TargetFixStatus and GetTarget() then
        ShowToClient(tostring(os.date("%X")), "Cannot see target - trying to change position", 20)
        if UnstuckAttempts < MaxUnstuckAttempts then
            UnstuckAttempts = UnstuckAttempts + 1
            TryChangePosition()
        end
    end
end

-- ====================== MAIN TICK ======================
function OnLTick1s()
    if not TargetFixStatus then return end

    local me      = GetMe()
    local target  = GetTarget()
    local now     = GetTime()
    local currentLoc = me:GetLocation()

    local isMoving = GetDistanceVector(currentLoc, LastCord) > 80
    LastCord = currentLoc

    --avoid dead monsters
	if ( target and target:IsMonster() and target:IsAlikeDeath() ) then
		--ShowToClient("[Fix]", "Clear Dead mob ")
		CancelTargets()
	end;
	
	-- Reset activity
    if isMoving or (target and me:GetTarget() ~= 0 and me:IsInCombat()) then
        LastActivityTime = now
        UnstuckAttempts = 0
    end

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

    -- Keep minimum distance from monster (max once per 5 seconds)
    if distToTarget < MinDistanceToMonster and (now - LastAwayTime > 3000) then
        --ShowToClient(tostring(os.date("%X")), "Too close to monster (" .. math.floor(distToTarget) .. ") - moving away", 20)
        MoveAwayFromTarget(target)
        LastAwayTime = now
        return
    end

    -- 1. Normal timeout - change target
    if idleTime > TimeTillRequestChangeTarget then
        ShowToClient(tostring(os.date("%X")), "No activity for " .. math.floor(idleTime/1000) .. "s - changing target", 20)
        target:SetBlock(true)
        CancelTargets()
        LastActivityTime = now
        UnstuckAttempts = 0
        CurrentTargetId = 0
        return
    end

    -- 2. Try to change position
    if idleTime > TimeTillTryFixMovement and not IsUnstucking and UnstuckAttempts < MaxUnstuckAttempts then
        ShowToClient(tostring(os.date("%X")), "Cannot reach target - position change attempt " .. (UnstuckAttempts + 1) .. "/" .. MaxUnstuckAttempts, 20)
        IsUnstucking = true
        UnstuckAttempts = UnstuckAttempts + 1
        LastUnstuckTime = now
        TryChangePosition()
        return
    end

    -- 3. Last resort
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
        MoveToNoWait(meLoc.X + dx + math.random(-safeDist,safeDist),
                     meLoc.Y + dy + math.random(-safeDist,safeDist),
                     meLoc.Z)
    -- end
end

-- ====================== GET NEAREST PARTY MEMBER (Fixed) ======================
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
    if user:IsMe() then
        LastActivityTime = GetTime()
        UnstuckAttempts = 0
    end
end

function OnAttack(user, target)
    if user:IsMe() or target:IsMe() then
        LastActivityTime = GetTime()
        UnstuckAttempts = 0
    end
end

function CancelTargets()
    ClearTargets()
    CancelTarget(true)
end