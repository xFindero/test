--- v.6 Final - Plugin (Movement + Control only)
-- ====================== SETTINGS ======================
debug                       = true  -- - Зміни на false щоб вимкнути весь дебаг
TimeTillRequestChangeTarget = 1000 * 5     -- 5 сек без активності - зміна цілі
TimeTillTryFixMovement      = 1000 * 3     -- 3 сек - спроба змінити позицію
MaxUnstuckAttempts          = 3
MinDistanceToMonster        = 250
moveDist                    = 110
ForgetRange                 = 700
-- ====================== GLOBALS ======================
TargetFixStatus             = false
LastActivityTime            = 0
LastUnstuckTime             = 0
LastAwayTime                = 0
IsUnstucking                = false
UnstuckAttempts             = 0
mytargetid                  = 0
CurrentTargetId             = 0
LastCord                    = {X=0, Y=0, Z=0}

-- ====================== ON CREATE ======================
function OnCreate()
    this:RegisterCommand("mtf", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME)
end

function OnCommand_mtf(vCommandChatType, vNick, vCommandParam)
    TargetFixStatus = not TargetFixStatus
    
    if TargetFixStatus then
        ShowToClient(os.date("%X"), "[Plugin] Mage Target Fix STARTED", 20)
        ProcessCommand("/scriptStart MagFix.lua")
        
        local me= GetMe()
        LastCord = me:GetLocation()
        LastActivityTime = GetTime()
        LastUnstuckTime = GetTime()
        LastAwayTime = GetTime()
        UnstuckAttempts = 0
        mytargetid = 0
    else
        ShowToClient(os.date("%X"), "[Plugin] Mage Target Fix STOPPED", 20)
        ProcessCommand("/scriptStop MagFix.lua")
    end
end

function OnLogout()
    TargetFixStatus = false
    ProcessCommand("/scriptStop MagFix.lua")
end

-- ====================== EVENTS ======================
function OnChatSystemMessage(id, msg)
    if id == 181 and TargetFixStatus then
        if debug then ShowToClient(os.date("%X"), "[Plugin] Cannot see target - trying position fix", 20) end
        if UnstuckAttempts < MaxUnstuckAttempts then
            UnstuckAttempts = UnstuckAttempts + 1
            TryChangePosition()
        end
    end
end

function OnMagicSkillUse(user, target, skillId, skillvl, skillHitTime, skillReuse)
    if user:IsMe() and TargetFixStatus then
        LastActivityTime = GetTime()
        UnstuckAttempts = 0
    end
end

function OnAttack(user, target)
    if (user:IsMe() or target:IsMe()) and TargetFixStatus then
        LastActivityTime = GetTime()
        UnstuckAttempts = 0
    end
end

-- ====================== MAIN TICK ======================
function OnLTick1s()
    if ( not TargetFixStatus or IsPaused()) then return end
    local me = GetMe()
    local target = GetTarget()
    local now = GetTime()
    local currentLoc = me:GetLocation()

    local isMoving = GetDistanceVector(currentLoc, LastCord) > 80
    LastCord = currentLoc

    if isMoving or (target and me:GetTarget() ~= 0 and me:IsInCombat()) then
        LastActivityTime = now
        UnstuckAttempts = 0
    end

    -- Dead target cleanup
    -- if target and target:IsMonster() and target:IsAlikeDeath() then
    --    if debug then ShowToClient("[Fix]", "Clear Dead mob") end
    --    CancelTargets()
    -- end

    if not target or not target:IsMonster() or target:IsAlikeDeath() or me:GetTarget() == 0 then
        LastActivityTime = now
        mytargetid = 0
        return
    end

    -- New target
    if mytargetid ~= target:GetId() then
        mytargetid = target:GetId()
        CurrentTargetId = target:GetId()
        LastActivityTime = now
        UnstuckAttempts = 0
        if debug then ShowToClient(os.date("%X"), "[Plugin] New target detected",20) end
    end

    local idleTime = now - LastActivityTime
    local dist = target:GetDistance()

    -- Safe distance
    if dist < MinDistanceToMonster and (now - LastAwayTime > 2000) then
        if debug then ShowToClient(os.date("%X"), "[Plugin] Too close - moving away",20) end
        MoveAwayFromTarget(target)
        LastAwayTime = now
        return
    end

    -- Change target
    if idleTime > TimeTillRequestChangeTarget then
        if debug then ShowToClient(os.date("%X"), "[Plugin] Idle too long - changing target", 20) end
        target:SetBlock(true)
        CancelTargets()
        LastActivityTime = now
        return
    end

    -- Position fix
    if idleTime > TimeTillTryFixMovement and not IsUnstucking and UnstuckAttempts < MaxUnstuckAttempts then
        if debug then ShowToClient(os.date("%X"), "[Plugin] Position change attempt " .. (UnstuckAttempts + 1), 20) end
        IsUnstucking = true
        UnstuckAttempts = UnstuckAttempts + 1
        LastUnstuckTime = now
        TryChangePosition()
        return
    end

    -- Last resort
    if idleTime > TimeTillTryFixMovement and UnstuckAttempts >= MaxUnstuckAttempts then
        if debug then ShowToClient(os.date("%X"), "[Plugin] Last resort move", 20) end
        TryLastResortMove()
        LastActivityTime = now
        UnstuckAttempts = 0
        return
    end

    if IsUnstucking and (now - LastUnstuckTime > 2600) then
        IsUnstucking = false
    end
end

-- ====================== MOVEMENT FUNCTIONS ======================
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

    MoveToNoWait(meLoc.X + dx + math.random(-40,40),
                 meLoc.Y + dy + math.random(-40,40),
                 meLoc.Z)
end

function TryChangePosition()
    local me = GetMe()
    local PartyLeader = GetPartyMaster()

    if PartyLeader == nil or PartyLeader:IsMe() then
        MovePerpendicularlySimple(me, moveDist)
    else
        MovePerpendicularlySimple(PartyLeader, moveDist)
    end
end

function TryLastResortMove()
    local PartyLeader = GetPartyMaster()

    if PartyLeader == nil or PartyLeader:IsMe() then
        deltaMove()
        BlockCurrentTarget()
        return
    end

    local myDist = PartyLeader:GetDistance()
    if myDist >= ForgetRange and myDist <= 2000 then
        SetPause(true)
        ClearTargets()
        moveToNext(PartyLeader)
        SetPause(false)
        BlockCurrentTarget()
    else
        MovePerpendicularlySimple(PartyLeader, moveDist)
        BlockCurrentTarget()
    end
end

function deltaMove()
    local me = GetMe()
	local MyID = me:GetId();
    local tx = me:GetLocation().X + math.random(-30, 30) + ((string.sub(MyID, -2)) / 2)
    local ty = me:GetLocation().Y + math.random(-30, 30)
    MoveToNoWait(tx, ty, me:GetLocation().Z)
end

function BlockCurrentTarget()
    local target = GetTarget()
    if target and target:GetId() == CurrentTargetId then
        target:SetBlock(true)
        if debug then ShowToClient(os.date("%X"), "[Plugin] Target blocked", 20) end
    end
    CancelTargets()
    CurrentTargetId = 0
end

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

function CancelTargets()
    ClearTargets()
    CancelTarget(true)
end