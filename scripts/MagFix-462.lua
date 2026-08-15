--- v.4.6.1 Fixed
-- ====================== SETTINGS ======================
-- Necromancer
SKILL_CURSE_GLOOM     = 1263
SKILL_DEATH_SPIKE     = 1148
SKILL_CORPSE_BURST    = 1155

-- Spellhowler
SKILL_SURRENDER_WIND  = 1074
SKILL_HURRICANE       = 1239

-- Common
SKILL_CURSE_DEATHLINK = 1159
SKILL_CURSE_FEAR      = 1169
SKILL_VAMPIRIC_CLAW   = 1234

SkillNames = {
    [SKILL_CURSE_GLOOM]     = "CURSE_GLOOM",
    [SKILL_DEATH_SPIKE]     = "DEATH_SPIKE",
    [SKILL_CORPSE_BURST]    = "CORPSE_BURST",
    [SKILL_SURRENDER_WIND]  = "SURRENDER_WIND",
    [SKILL_HURRICANE]       = "HURRICANE",
    [SKILL_CURSE_DEATHLINK] = "CURSE_DEATHLINK",
    [SKILL_CURSE_FEAR]      = "CURSE_FEAR",
    [SKILL_VAMPIRIC_CLAW]   = "VAMPIRIC_CLAW",
}

IAmNecr = false
IAmSH   = false
stopScr = false
debug   = true

-- ====================== GLOBALS ======================
mytargetid = 0
DebuffApplied = {}          -- [targetId] = true

local lastStatusCheck = 0
local STATUS_CHECK_INTERVAL = 5000

-- ====================== INIT ======================
function init()
    ShowToClient(os.date("%X"), "Fast Mage Nuke v.4.6.1 started", 20)
    
    local classId = GetMe():GetClass()
    whoIAm(classId)
    
    if validateSkills() then
		if debug then ShowToClient(os.date("%X"), "Class and skills validated successfully", 20) end
        return true
    else
        ShowToClient(os.date("%X"), "skills Validation failed!")
        return false
    end
end

function CancelTargets()
    ClearTargets()
    CancelTarget(true)
    Sleep(123)
    ClearTargets()
end

function whoIAm(classId)
    if debug then ShowToClient(os.date("%X"), "Class detected: " .. classId, 20) end

    if classId == 13 or classId == 93 or classId == 95 then
        IAmNecr = true
        if debug then ShowToClient(os.date("%X"), "Necromancer mode", 20) end
    elseif classId == 40 or classId == 110 then
        IAmSH = true
        if debug then ShowToClient(os.date("%X"), "Spellhowler mode", 20) end
    else
        ShowToClient(os.date("%X"), "Unknown class!")
    end
end

function validateSkills()
    local skills = GetSkills()
    if IAmNecr then
        if not skills:FindById(SKILL_DEATH_SPIKE) or not skills:FindById(SKILL_CURSE_GLOOM) then
            ShowToClient(os.date("%X"), "ERROR: Missing Necromancer skills!")
            IAmNecr = false
            return false
        end
    elseif IAmSH then
        if not skills:FindById(SKILL_HURRICANE) or not skills:FindById(SKILL_SURRENDER_WIND) then
            ShowToClient(os.date("%X"), "ERROR: Missing Spellhowler skills!")
            IAmSH = false
            return false
        end
    end
    return true
end

-- ====================== magSkillUse ======================
function magSkillUse(skillID, times)
    if skillID == 0 or times < 1 then return false end
	if debug then
        local name = SkillNames[skillID] or ("ID:" .. skillID)
        ShowToClient(os.date("%X"), "Casting " .. name .. " x" .. times, 20)
    end

    if times > 1 then
        for i = 1, times do
            UseSkillRaw(skillID, false, false)
            Sleep(650)
        end
    else
        UseSkill(skillID, false, false)
    end
    
    return true
end

-- ====================== STATUS ======================
function shouldContinue()
    local now = os.time() * 1000
    if now - lastStatusCheck < STATUS_CHECK_INTERVAL then return true end

    lastStatusCheck = now
    local me = GetMe()
    return not (me:IsAlikeDeath() or me:IsBlocked(true))
end

-- ====================== SHARED STATE ======================
local function GetCombatState()
    local me = GetMe()
    local target = GetTarget()
    return {
        me = me,
        target = target,
        hp = me:GetHpPercent(),
        tid = target and target:GetId() or 0,
        isLeader = me:IsMyPartyMemberMaster()
    }
end

-- ====================== CURSE FEAR (без goto) ======================
function TryApplyCurseFear(state)
    local radius = state.isLeader and 900 or 600
    if debug then ShowToClient(os.date("%X"), "[TryApplyCurseFear] Checking for monsters to apply Curse Fear within radius: " .. radius, 20) end
    local monsters = GetMonsterList()

    for mob in monsters.list do
        local tid = mob:GetId()

        -- Перевіряємо умови і пропускаємо, якщо не підходить
        if mob:GetDistance() <= radius and not mob:IsAlikeDeath() then
            if mob:IsAttacking() then
                if not DebuffApplied[tid] then
                    for attempt = 1, 3 do
                        if UseSkillRaw(SKILL_CURSE_FEAR, false, false) then
                            if debug then ShowToClient(os.date("%X"), "Fear [" .. attempt .. "] on " .. tid, 20) end
                            DebuffApplied[tid] = true
                            break
                        end
                        Sleep(800)
                    end
                end
            end
        end
    end
end

-- ====================== VAMPIRIC CLAW ======================
function TryVampiricClaw(state)
    if debug then ShowToClient(os.date("%X"), "[TryVampiricClaw] Checking if Vampiric Claw should be used. HP: " .. state.hp .. "%", 20) end
    if IAmSH then
        if state.hp < 60 then
            if debug then ShowToClient(os.date("%X"), "[TryVampiricClaw] HP below 60% - casting Vampiric Claw", 20) end
            return magSkillUse(SKILL_VAMPIRIC_CLAW, 1)
        end
    elseif IAmNecr then
        local isSoloMage = IsSoloMageInParty()
        if isSoloMage and state.hp < 60 then
            return magSkillUse(SKILL_VAMPIRIC_CLAW, 1)
        elseif not state.isLeader and state.hp < 30 and HasAggroMonsterNearby(600) then
            if debug then ShowToClient(os.date("%X"), "[TryVampiricClaw] HP below 30% with aggro monster nearby - casting Vampiric Claw", 20) end
            return magSkillUse(SKILL_VAMPIRIC_CLAW, 1)
        elseif not state.isLeader and state.hp < 10 then
            if debug then ShowToClient(os.date("%X"), "[TryVampiricClaw] HP below 10% - casting Vampiric Claw", 20) end
            return magSkillUse(SKILL_VAMPIRIC_CLAW, 1)
        end
    end
    return false
end

-- ====================== HELPER FUNCTIONS ======================
function IsSoloMageInParty()
    local party = GetPartyList()
    if party:GetCount() <= 1 then
        if debug then ShowToClient(os.date("%X"), "Solo mage InParty", 20) end
        return true
    end

    local mageCount = 0
	for member in party.list do
		local cls = member:GetClass()
		if cls == 13 or cls == 93 or cls == 95 or cls == 40 or cls == 110 then
			mageCount = mageCount + 1
            if debug then ShowToClient(os.date("%X"), "Mage detected in party: " .. member:GetName() .. " (Class ID: " .. cls .. ") Total in party: " .. party:GetCount() .. " Mages: " .. mageCount, 20) end
		end
	end
    return mageCount <= 1
end

function HasAggroMonsterNearby(radius)
    local monsters = GetMonsterList()
    for mob in monsters.list do
        if mob:GetDistance() <= radius and mob:IsMonster() and not mob:IsAlikeDeath() and mob:IsAttacking() then
            return true
        end
    end
    return false
end

-- ====================== MAIN ATTACK ======================
function MagAttack()
    local startTime = 0
    if debug then startTime = os.clock() end

    if not shouldContinue() then return end

    local state = GetCombatState()

    -- Corpse Burst
    if state.target and state.target:IsAlikeDeath() and state.target:GetDistance() <= 450 and not state.target:IsSpoiled() then
        if IAmNecr then
            magSkillUse(SKILL_CORPSE_BURST, 1)
            if debug then ShowToClient(os.date("%X"), "Corpse Burst on dead target", 20) end
        else
            if debug then ShowToClient(os.date("%X"), "Clear target for non-Necromancer", 20) end
            CancelTargets()
        end
        return
    end

    -- Normal target validation
    if not state.target or not state.target:IsMonster() or state.target:IsAlikeDeath() or state.me:GetTarget() == 0 then
        return
    end

    -- New target
    if mytargetid ~= state.tid then
        if debug then ShowToClient(os.date("%X"), "New target: " .. state.tid, 20) end
        mytargetid = state.tid
    end

    -- Additional skills
    TryApplyCurseFear(state)
    TryVampiricClaw(state)

    -- Main rotation
    if IAmNecr then
        if not DebuffApplied[state.tid] then
            if UseSkill(SKILL_CURSE_GLOOM, false, false) then  --+RAW забиває на каст скіла якщо таргет далеко
                DebuffApplied[state.tid] = true
                if debug then ShowToClient(os.date("%X"), "Gloom applied", 20) end
            end
            return
        end

        if state.hp <= 30 then
            magSkillUse(SKILL_CURSE_DEATHLINK, 2)
        else
            magSkillUse(SKILL_DEATH_SPIKE, 3)
        end

    elseif IAmSH then
        if not DebuffApplied[state.tid] then
            if UseSkill(SKILL_SURRENDER_WIND, false, false) then
                DebuffApplied[state.tid] = true
                if debug then ShowToClient(os.date("%X"), "Surrender to Wind applied", 20) end
            end
            return
        end

        if state.hp <= 30 then
            magSkillUse(SKILL_CURSE_DEATHLINK, 1)
        else
            magSkillUse(SKILL_HURRICANE, 3)
        end
    end

    if debug then
        local elapsed = (os.clock() - startTime) * 1000
        ShowToClient(os.date("%X"), string.format("MagAttack took %.1f ms", elapsed), 20)
    end
end

-- ====================== MAIN LOOP ======================
if init() then
    while not stopScr do
        MagAttack()
        Sleep(500 + math.random(0, 180))
    end
else
    ShowToClient(os.date("%X"), "Script initialization failed. Stopping.", 20)
end