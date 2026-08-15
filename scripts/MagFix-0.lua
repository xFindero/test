--- v.4.3
--- v.4.1 + Fast Mage Nuke Logic (Necro + Spellhowler)
-- ====================== SETTINGS ======================
-- ====================== SKILL IDs ======================
-- Necromancer
SKILL_CURSE_GLOOM     = 1263   -- Curse Gloom
SKILL_CURSE_ABYSS     = 1337   -- Curse of Abyss
SKILL_DEATH_SPIKE     = 1148   -- Death Spike
SKILL_CURSE_DEATHLINK = 1159   -- Curse Death Link (adjust if different on your chronicle)
-- Spellhowler
SKILL_SURRENDER_WIND  = 1074   -- Surrender to Wind
SKILL_HURRICANE       = 1239   -- Hurricane
IAmNecr				=	false
IAmSH				=	false
stopScr = false
debug	= true  -- Зміни на false щоб вимкнути дебаг
-- ====================== GLOBALS ======================
mytargetid          = 0

function init()
    local classId = GetMe():GetClass()
	whoIAm(classId)
	-- New: per-target debuff tracking
    DebuffApplied = {}
end

-- Helper functions to detect class
function whoIAm(classId)
	if debug then ShowToClient(os.date("%X"), "Our class: " .. classId, 20) end
	if classId == 13 or classId == 93 or classId == 95 then     -- Necromancer
        if debug then ShowToClient(os.date("%X"), "We are a Necromancer: " .. classId, 20) end
        if GetSkills():FindById(SKILL_DEATH_SPIKE) ~= nil and GetSkills():FindById(SKILL_CURSE_GLOOM) ~= nil then
            if debug then ShowToClient(os.date("%X"), "We have needed skills for Necromancer: ", 20) end
            IAmNecr	=	true
            IAmSH   =	false
		else
			if debug then ShowToClient(os.date("%X"), "We don't have needed skills for Necromancer!") end
			IAmNecr	=	false
			IAmSH   =	false
        end
    elseif classId == 40 or classId == 110 then   -- Spellhowler
        if debug then ShowToClient(os.date("%X"), "We are a Spellhowler: " .. classId, 20) end
        if GetSkills():FindById(SKILL_HURRICANE) ~= nil and GetSkills():FindById(SKILL_SURRENDER_WIND) ~= nil then
            --if debug then ShowToClient(os.date("%X"), "We have needed skills for Spellhowler: ", 20) end
            IAmNecr	=	false
            IAmSH   =	true
        else
			if debug then ShowToClient(os.date("%X"), "We don't have needed skills for Spellhowler!") end
			IAmNecr	=	false
			IAmSH   =	false
		end
    else
        if debug then ShowToClient(os.date("%X"), "Our class: " .. classId .. " Who are you?", 20) end
        IAmNecr = false
        IAmSH	= false
    end
end

function magSkillUse(skillID)
	-- додати перевірку чи можемо ми взагалі кастувати... блок сало смерть не бачимо моба
	--if debug then ShowToClient(os.date("%X"), "magSkillUse " .. skillID, 20) end
	for count=1,5 do
		UseSkillRaw(skillID,false,false)	-- UseSkill тупить і невідомо чого чекає...зупиняється каст
		Sleep(300)
		--if debug then ShowToClient(os.date("%X"), " " .. count, 20) end
    end
end


-- ====================== FAST SKILL CASTING (High frequency) ======================
function MagAttack()
	-- add time and qtty for each skill
	local me = GetMe()
    if ( me:IsAlikeDeath() or me:IsBlocked(true) ) then return end

    local hpPercent = me:GetHpPercent()
    local target = GetTarget()

    -- Only act on valid monster targets
    if not target or not target:IsMonster() or target:IsAlikeDeath() or me:GetTarget() == 0 then
		--if debug then ShowToClient(os.date("%X"), "invalid target, exit MagAttack", 20) end
        return
    end

    local tid = target:GetId()

    -- Reset debuff flag on target change
    if mytargetid ~= tid then
		if debug then ShowToClient(os.date("%X"), "new target - clean old debuffs", 20) end
        mytargetid = tid
        -- Optional: clean old debuffs if you want (or keep them)
        DebuffApplied = {}
    end



    -- === PRIORITY 2: Normal rotation (HP > 30) ===
    

    if IAmNecr then
		if debug then ShowToClient(os.date("%X"), "IAmNecr, use magick", 20) end
        -- First: Curse Gloom (only once per target)
        if not DebuffApplied[tid] then
			--if debug then ShowToClient(os.date("%X"), "use debuff on new target", 20) end 
            if UseSkillRaw(SKILL_CURSE_GLOOM, false, false) then
				UseSkillRaw(SKILL_CURSE_ABYSS, false, false)
                DebuffApplied[tid] = true
                return
			--else
				--if debug then ShowToClient(os.date("%X"), "use SKILL_CURSE_GLOOM failed") end
            end
        else
			-- === PRIORITY 1: Low HP - Curse Death Link ===
			if hpPercent <= 30 then
				--if debug then ShowToClient(os.date("%X"), "PRIORITY 1: use CURSE_DEATHLINK", 20) end
				magSkillUse(SKILL_CURSE_DEATHLINK)
				return
			else
				--if debug then ShowToClient(os.date("%X"), "PRIORITY 1: use DEATH_SPIKE", 20) end
				magSkillUse(SKILL_DEATH_SPIKE)
			end
        end

    elseif IAmSH then
        -- First: Surrender To Wind (only once per target)
        if not DebuffApplied[tid] then
            if UseSkillRaw(SKILL_SURRENDER_WIND, false, false) then
                DebuffApplied[tid] = true
                return
            end
        else
			-- === PRIORITY 1: Low HP - Curse Death Link ===
			if hpPercent <= 30 then
				--if debug then ShowToClient(os.date("%X"), "PRIORITY 1: use CURSE_DEATHLINK", 20) end
				magSkillUse(SKILL_CURSE_DEATHLINK)
				return
			else
				magSkillUse(SKILL_HURRICANE)
			end
        end
    end
end

function CancelTargets()
	ClearTargets()
	CancelTarget(true)
	Sleep(123)
	ClearTargets()
end

-- ====================== MAIN ======================
ShowToClient(os.date("%X"), "Fast Mage Nuke Script v.4.3", 20)
local msgCounter = 	0			-- counter to send msg only for 1 time

init()

while not stopScr do
    while ( GetMe():IsAlikeDeath() or IsPaused() or GetZoneType() == L2ZoneType.PEACEFUL) do
		if ( msgCounter < 1 ) then
			if ( not IsPaused() ) then
				Command("#pi...");
			else
				ShowToClient(os.date("%X"), "Wait to bee ON/Ressurection", 20);
			end
			msgCounter = msgCounter + 1
		end
		Sleep (4500 + math.random(150,1505));	-- чекаємо 4-6сек і повторно перевіряємо
	end
	msgCounter = 0
	MagAttack()	
	Sleep(1000 + math.random(-200, 300))
 end

ShowToClient(os.date("%X"), "Script finished.", 20)
SetPause(true)