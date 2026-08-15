------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
--Features: Balance Heal, Brilliant Heal, Panic Heal, Recharge Single and Party, Rebirth, Noblesse, Salvation;			
--Celestial Party, Resurrection Single and Party, Lumi On PL or chosen MA, Purge Single and Party.						
------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------Client Text----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
																														
																														
ShowToClient("PvE", "iHealer On");																						
																														
																														
------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------Conditions----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
																														
PanicHealAmount = 3; -- Number of executed panic heals if needed;														
NRecharge = 2; -- Number of Party members who have below MP limit For Brilliant Recharge 								
BRecharger = false; -- Brilliant Recharge ON or OFF																		
amountOfDeadForPartyRess = 1; -- if more than the selected amount are dead it will cast party resurrection				
																														
																														
LumiOn = false; -- Lumi Feature ON or OFF																				
MainAssist = "main assist"; -- Main Assist for de-buffs																	
HealerLumiOnMa = false; -- Lumi on Main Assist or else Lumi on party leader's target									
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------De-buffs-----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
																														
																														
DebuffList = {16365,16366,16367,16368,16372,16375,16382}; -- De-buff IDs												
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------MP Conditions---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
																														
																														
RebirthMP = 10; --MP percentage for REBIRTH																				
MinHealerMP = 5; -- MP percentage to stop RECHARGE																		
MinLumiMP = 300; -- MP percentage to stop LUMI																			
CrystalRegenMP = 10; --MP percentage for CRYSTAL REGENERATION (SAME AS REBIRTH)											
SingleCelestialMP = 40; --MP percentage for SINGLE CELESTIAL															
RadiantRechargeMP = 40; --MP percentage for RADIANT RECHARGE															
BrilliantRechargeMP = 40; --MP percentage for BRILLIANT RECHARGE														
MentalRechargeMP = 40; --MP percentage for MENTAL RECHARGE																
ManaRange = 1200; --Range for MP RECHARGE																				
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------HP Conditions---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
																														
																														
CrystalRegenHP = 15; --HP for CRYSTAL REGENERATION																		
MonsterLumiHp = 99; --HP percentage of monster to lumi																	
PartyCelestialHP = 25; --HP percentage for PARTY CELESTIAL																
SingleCelestialHP = 40; --HP percentage for SINGLE CELESTIAL															
BalanceHealHP = 60; --HP percentage for BALANCE HEAL																	
BrilliantHealHP = 80;--HP percentage for BRILLIANT HEAL																	
GiantsFavorHP = 50; --HP percentage for GIANT'S FAVOR																	
PanicHealHP = 40; --HP percentage for PANIC HEAL																		
HealRange = 1200; --Range for HEAL																						
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------IDS--------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
																														
																														
RebirthSkillID = 1271; -- Benediction -- when MP < 25% - full restore party HP											
PartyCelestialSkillID = 1505; -- Sublime Self-Sacrifice 																
CelestialSkillID = 1418; -- Celestial Shield																			
BalanceHealSkillID = 1335; --Balance Heal ID																			
BrilliantHealSkillID = 1217; -- Greater Heal																			
RadiantRechargeSkillID = 1553; -- Chain Heal																			
LumiSkillID = 1360; -- Mass Block Shield																				
SalvationSkillID = 1410; -- Salvation	-- Перо																			
ResSkillID = 1016; -- Resurrection																						
NoblesseSkillID = 1353;  -- Divine Protection			-- Зробити нубл бішу!!!											
CrystalRegenSkillID = 1426; -- Miracle	full HP recovery for nearby clan 												
PartyResSkillID = 1254; -- Mass Resurrection																			
BrilliantRechargeSkillID = 1553; -- Chain Heal																			
GiantsFavorSkillID = 1258; -- Restore Life																				
SustainSkillID = 11752; -- Sustain ID																					
PanicHealSkillID = 1401; -- Major Heal																					
MentalRechargeSkillID = 1553; -- Chain Heal																				
ChainHealSkillID = 1553; -- Chain Heal																				
RadiantPurgeSkillID = 1425; -- Purification Field																				
BrilliantPurgeSkillID = 1409; -- Cleanse	-- Remove de-bufs															
DivinePrayerSkillID = 1307; -- Prayer																					

------------------------------------------------------------SKILLS------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
																														
																														
RebirthSkill = GetSkills():FindById(RebirthSkillID);																	
PartyCelestialSkill = GetSkills():FindById(PartyCelestialSkillID);														
CelestialSkill = GetSkills():FindById(CelestialSkillID);																
BalanceHealSkill = GetSkills():FindById(BalanceHealSkillID);															
BrilliantHealSkill = GetSkills():FindById(BrilliantHealSkillID);														
RadiantRechargeSkill = GetSkills():FindById(RadiantRechargeSkillID);													
LumiSkill = GetSkills():FindById(LumiSkillID);																			
SalvationSkill = GetSkills():FindById(SalvationSkillID);																
ResSkill = GetSkills():FindById(ResSkillID);																			
NoblesseSkill = GetSkills():FindById(NoblesseSkillID);																	
CrystalRegenSkill = GetSkills():FindById(CrystalRegenSkillID);															
PartyResSkill = GetSkills():FindById(PartyResSkillID);																	
BrilliantRechargeSkill = GetSkills():FindById(BrilliantRechargeSkillID);												
GiantsFavorSkill = GetSkills():FindById(GiantsFavorSkillID);															
SustainSkill = GetSkills():FindById(SustainSkillID);																	
PanicHealSkill = GetSkills():FindById(PanicHealSkillID);																
MentalRechargeSkill = GetSkills():FindById(MentalRechargeSkillID);														
RadiantPurgeSkill = GetSkills():FindById(RadiantPurgeSkillID);															
BrilliantPurgeSkill = GetSkills():FindById(BrilliantPurgeSkillID);														
DivinePrayerSkill = GetSkills():FindById(DivinePrayerSkillID);	
ChainHealSkill = GetSkills():FindById(ChainHealSkillID);	
ShowToClient("PvE", "#1");														
																														

-------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------FUNCTIONS-------------------------------------------------------------------
function ClearT()
	ClearTarget()
	ClearTargets()
	CancelTarget(false)
	Sleep(123)
	ClearTargets()
end
------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------CASTING FUNCTIONS--------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------CAST AOE-------------------------------------------------------------------     CAST MASS SKILLS WITH NO NEED FOR TARGET FUNCTION
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function Cast(skill,id)																									
	ShowToClient(os.date("%X"), "#CAST AOE");
	if id then																											
		if skill and skill:CanBeUsed() then																				
			UseSkillRaw(id,false,false);																				
			ClearT()																																			
		end;																											
	end;																												
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------CAST ON TARGET----------------------------------------------------------------     CAST SINGLE TARGET SKILLS FUNCTION
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function CastOnTarget(skill,id,target)
	ShowToClient(os.date("%X"), "#CAST ON TARGET -start");																					
	if id then																											
		if skill and skill:CanBeUsed() then																				
			ShowToClient(os.date("%X"), "#CAST ON TARGET: " .. id);
			Target(target);																								
			UseSkillRaw(id,false,false);																				
			Sleep(500);																								
			ClearT()																						
		end;																											
	end;																												
end;																													
																														

----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------HEALING FUNCTIONS------------------------------------------------------------------------------


------------------------------------------------#BALANCE HEAL--------------------------------------------------------------------------------#
--------------------------------------------CHECK FOR BALANCE HEAL----------------------------------------------------------------------------     CHECK CONDITIONS

function CheckForBalanceHeal()																											
	local PartyList = GetPartyList();																									
	local me = GetMe();																													
	for member in PartyList.list do
		ShowToClient(os.date("%X"), " " .. member:GetName() .. " HP%: " .. member:GetHpPercent() .. " Dist: " .. member:GetDistance() .. " Dead: "  .. tostring(member:IsAlikeDeath()) );
		if ((me:GetHpPercent() < BalanceHealHP) or ((member:GetHpPercent() < BalanceHealHP)) and not(member:IsAlikeDeath())) then		
			ShowToClient(os.date("%X"), "#CHECK FOR BALANCE HEAL - True");
			return true;																												
		end;																															
	end;																																
	return false;																														
end;																																	
																																		
																																		
------------------------------------------------BRILLIANT HEAL----------------																										
-----------------------------------------------CAST BALANCE HEAL------------------------------------------------------------------------------     CHECK FOR REUSE AND CAST
------------------------------------------------BRILLIANT HEAL--------------------------------------------------------------------------------
																																		
																																		
function BalanceHeal()																													
	ShowToClient(os.date("%X"), "#CAST BALANCE HEAL");
	if (BalanceHealSkill:CanBeUsed()) then																								
		Cast(BalanceHealSkill,BalanceHealSkillID);																						
	end;																																
end;																																	

function ChainHeal()																													
	ShowToClient(os.date("%X"), "#CAST ChainHeal");
	if (ChainHealSkill:CanBeUsed()) then																								
		Cast(ChainHealSkill,ChainHealSkillID);																						
	end;																																
end;																																		
																																		
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------BRILLIANT HEAL--------------------------------------------------------------------------------
-------------------------------------------CHECK FOR BRILLIANT HEAL---------------------------------------------------------------------------     CHECK CONDITIONS
----------------------------------------------------------------------------------------------------------------------------------------------
																																		
																																		
function CheckForBrilliantHeal()																										
	ShowToClient(os.date("%X"), "#CHECK FOR BRILLIANT HEAL");
	local PartyList = GetPartyList();																									
	local me = GetMe();																													
	for member in PartyList.list do																										
		if (me:GetHpPercent() < BrilliantHealHP) or (((member:GetHpPercent() < BrilliantHealHP)) and not (member:IsAlikeDeath())) then	
			return true;																												
		end;																															
	end;																																
	return false;																														
end;																																	
																																		
																																		
----------------------------------------------------------------------------------------------------------------------------------------------		
------------------------------------------------------------------------------------------------------------------------------																																
----------------------------------------------CAST BRILLIANT HEAL-------------------------------------------------------------     CHECK FOR REUSE AND CAST
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function BrilliantHeal()																								
	ShowToClient(os.date("%X"), "#CAST BRILLIANT HEAL");
	if (BrilliantHealSkill:CanBeUsed()) then																			
		Cast(BrilliantHealSkill,BrilliantHealSkillID);																	
	end;																												
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------PANIC HEAL------------------------------------------------------------------
---------------------------------------------CHECK FOR PANIC HEAL-------------------------------------------------------------     CHECK AND RETURN 
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function CheckForPanicHeal()																							
	local PartyList = GetPartyList();																					
	local me = GetMe();																									
	for member in PartyList.list do																						
		if (member:GetHpPercent() < PanicHealHP) or (me:GetHpPercent() < PanicHealHP) then								
			ShowToClient(os.date("%X"), "#CHECK FOR PANIC HEAL - True");
			return true;																								
		end;																											
	end;																												
	return false;																										
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------		
------------------------------------------------------------------------------------------------------------------------------																								
-------------------------------------------------CAST PANIC HEAL--------------------------------------------------------------     CAST X USER SET DONE
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function PanicHeal()																									
	ShowToClient(os.date("%X"), "#CAST PANIC HEAL");
	local PartyList = GetPartyList();																					
	local me = GetMe();																									
	if (me:GetHpPercent() < PanicHealHP) then																			
		for counter = 0, PanicHealAmount do																				
			CastOnTarget(PanicHealSkill,PanicHealSkillID,me);															
			CastOnTarget(ChainHealSkill,ChainHealSkillID,me);															
			counter = counter + 1;																						
		end;																											
	else																												
		for member in PartyList.list do																					
			if (member:GetHpPercent() < PanicHealHP) and not (member:IsAlikeDeath()) then								
				for counter = 0, PanicHealAmount do																		
					CastOnTarget(PanicHealSkill,PanicHealSkillID,member);												
					CastOnTarget(ChainHealSkill,ChainHealSkillID,me);	
					counter = counter + 1;																				
				end;																									
			end;																										
		end;																											
	end;																												
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------RECHARGE FUNCTIONS-------------------------------------------------------------

----------------------------------------------------REBIRTH------------------------------------------------------------------#
-----------------------------------------------CHECK FOR REBIRTH--------------------------------------------------------------     CHECK 
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function CheckForRebirth()																								
	local PartyList = GetPartyList();																					
	local me = GetMe();																									
	local counter = 0;																									
	if (me:GetMpPercent() < RebirthMP) then 																			
		ShowToClient(os.date("%X"), "#CHECK FOR REBIRTH - True");
		return true;																									
	else																												
		for member in PartyList.list do																					
			if (not (member:IsAlikeDeath())) and (member:GetMpPercent() < GiantsFavorHP) then	-- Restore only HP		
				counter = counter + 1;																					
			end;																										
		end;																											
		if (counter >1) then																							
			ShowToClient(os.date("%X"), "#CHECK FOR REBIRTH - Member need it - True");
			return true;																								
		end;																											
	end;																												
	return false;																										
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------																										
--------------------------------------------------CAST REBIRTH----------------------------------------------------------------     CHECK FOR REUSE AND CAST
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function Rebirth()																										
	ShowToClient(os.date("%X"), "#CAST REBIRTH");
	if (RebirthSkill:CanBeUsed()) then																					
		Cast(RebirthSkill,RebirthSkillID);																				
	end;																												
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------#RECHARGE------------------------------------------------------------------#
----------------------------------------------CHECK FOR RECHARGE--------------------------------------------------------------     CHECK FOR RECHARGE
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function CheckForRecharge()																								
	local PartyList = GetPartyList();																					
	local counter = 1;																										
	for member in PartyList.list do 																					
		if (member:GetMpPercent() < BrilliantRechargeMP) then 															
			counter = counter + 1;																						
		end;																											
	end;																												
	if (counter > NRecharge) and (BrilliantRechargeSkill:CanBeUsed()) and (BRecharger == true) then						
		return "koss";																									
	else																												
		for member in PartyList.list do 																				
			if (member:GetMpPercent() < RadiantRechargeMP) and (not IsHealer(member)) then 								
				return member;																							
			end;																										
		end;																											
	end;																												
end;																													
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------CAST RECHARGE----------------------------------------------------------------     CHECK FOR REUSE AND CAST
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function RechargeMp()																									
	ShowToClient(os.date("%X"), "#CAST RECHARGE");
	--local me = GetMe();																								
	if (CheckForRecharge() == "koss") then																				
		Cast(BrilliantRechargeSkill,BrilliantRechargeSkillID);															
	else																												
		CastOnTarget(RadiantRechargeSkill,RadiantRechargeSkillID,CheckForRecharge());									
	end;																												
end;																													
																														
																														
																														
function IsHealer(member)																								
	ShowToClient(os.date("%X"), "#IsHealer");
	if (member:GetClass() == 97) or (member:GetClass() == 180) or (member:GetClass() == 181) then						
		return true;																									
	end;																												
	return false;																										
end;																													
																														
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------OTHER FUNCTIONS------------------------------------------------------

--------------------------------------------------#NOBLESSE------------------------------------------------------------------#	
-----------------------------------------------CHECK FOR NOBLESS--------------------------------------------------------------     CHECK + CAST DONE
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function CheckForNobless()																								
	local PartyList = GetPartyList();																					
	local me = GetMe();																									
	if (not me:GotBuff(NoblesseSkillID)) and (not (me:IsAlikeDeath())) then												
			ShowToClient(os.date("%X"), "#CHECK FOR NOBLESS-solo");
			CastOnTarget(NoblesseSkill,NoblesseSkillID,me);																
			Sleep(50);																									
	end;																												
--	for member in PartyList.list do				-- tem block :( no nobles																		
--		if not member:GotBuff(NoblesseSkillID) and not(member:IsAlikeDeath())  then										
--			ShowToClient(os.date("%X"), "#CHECK FOR NOBLESS-party");
--			CastOnTarget(NoblesseSkill,NoblesseSkillID,member);															
--			Sleep(50);																									
--		end;																											
--	end;																												
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------#DIVINE PRAYER--------------------------------------------------------------	
-----------------------------------------------CHECK FOR PRAYER---------------------------------------------------------------     CHECK + CAST DONE
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function CheckForDivine()																								
	local PartyList = GetPartyList();																					
	local me = GetMe();																									
	if (not me:GotBuff(DivinePrayerSkillID)) and (not (me:IsAlikeDeath())) then											
			ShowToClient(os.date("%X"), "#CHECK FOR PRAYER - True");
			Cast(DivinePrayerSkill,DivinePrayerSkillID);																
			Sleep(50);																									
	end;	
--	for member in PartyList.list do																						
--		if not member:GotBuff(NoblesseSkillID) and not(member:IsAlikeDeath())  then										
--			Cast(DivinePrayerSkill,DivinePrayerSkillID);																
--			Sleep(50);																									
--		end;																											
--	end;																												
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------#SALVATION------------------------------------------------------------------	
----------------------------------------------CHECK FOR SALVATION-------------------------------------------------------------     CHECK + CAST DONE
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function CheckForSalvation()																							
	local me = GetMe();																									
	if (not me:GotBuff(SalvationSkillID)) then																			
		if (not (me:IsAlikeDeath())) and (SalvationSkill:CanBeUsed()) then												
			ShowToClient(os.date("%X"), "#We need SALVATION");
			CastOnTarget(SalvationSkill,SalvationSkillID,me);															
		end;																											
	ShowToClient(os.date("%X"), "#We have SALVATION");
	end;																												
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
	
	
------------------------------------------------PARTY CELESTIAL--------------------------------------------------------------#		
-------------------------------------------CHECK FOR PARTY CELESTIAL----------------------------------------------------------     CHECK
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function CheckForPartyCelestial()																						
	local PartyList = GetPartyList();																					
	local me = GetMe();																									
	local counter = 0;																									
	for member in PartyList.list do																						
		if (member:GetHpPercent() < PartyCelestialHP) then																
			counter = counter + 1;																						
		end;																											
		if (me:GetHpPercent() < PartyCelestialHP) then																	
			counter = counter + 1;																						
		end;																											
	end;																												
	if (counter >= 1) then																								
		ShowToClient(os.date("%X"), "#Need! PARTY CELESTIA");
		return true;																									
	end;																												
	return false;																										
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------																										
----------------------------------------------CAST PARTY CELESTIAL------------------------------------------------------------     CHECK FOR REUSE + CAST DONE
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function PartyCelestial()																								
	ShowToClient(os.date("%X"), "#PARTY CELESTIAL needed");
	if (CheckForPartyCelestial()) and (PartyCelestialSkill:CanBeUsed()) then											 
		ShowToClient(os.date("%X"), "#CAST PARTY CELESTIAL");
		Cast(PartyCelestialSkill,PartyCelestialSkillID);																
	end;																												
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
	

--------------------------------------------------#PARTY RESS----------------------------------------------------------------		
----------------------------------------------CHECK FOR PARTY RESS------------------------------------------------------------     CHECK
------------------------------------------------------------------------------------------------------------------------------
																														
																															
function CheckForPartyRess()																		
	ShowToClient(os.date("%X"), "1.#CHECK FOR PARTY RESS");
	local PartyList = GetPartyList();
	local counter = 0;																		
	WeInParty = false;
	Massress = false;
	RessMember = nil;
	for member in PartyList.list do																
		ShowToClient(os.date("%X"), "1.1# chek party members");
		WeInParty = true;
		if (member:IsAlikeDeath()) and (GetMe():GetRangeTo(member) < 900) then 															
			ShowToClient(os.date("%X"), "2.#1 or x Dead members :( - " .. member:GetName());
			counter = counter + 1;																	
			RessMember = member;
		end;																						
	end;																							
	ShowToClient(os.date("%X"), "3.#" .. counter .. " Murdered");
	if (counter > amountOfDeadForPartyRess ) and (PartyResSkill:CanBeUsed()) then						
		ShowToClient(os.date("%X"), "4.#We need Mass ress!!!, "..counter.."murdered.");
		Massress = true;
		return RessMember;														
	else																			
		if ( WeInParty ) then
			ShowToClient(os.date("%X"), "5.#Not need party Ress. We have " .. counter .." dead members");
			if (counter <= amountOfDeadForPartyRess ) and (counter > 0 )then 															
				ShowToClient(os.date("%X"), "6.#1 or more Dead members :(");																
				for member in PartyList.list do 										
					ShowToClient(os.date("%X"), "7.#Check: " .. member:GetName());
					if (member:IsAlikeDeath()) and (GetMe():GetRangeTo(member) < 1200) then 									
						ShowToClient(os.date("%X"), "8.#dead member - " .. member:GetName());
						return member;													
					else
						ShowToClient(os.date("%X"), "9.#Member " .. member:GetName().." is OK");
					end;																
					ShowToClient(os.date("%X"), "10.#end of Check: " .. member:GetName() .." ...");	
				end;
			else 
				ShowToClient(os.date("%X"), "11.#Counter !> 0: " .. counter);
				return "All-ok";
			end;																	
			ShowToClient(os.date("%X"), "We not in party.");
		end;
	end;																		
end;																													
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------CAST PARTY RESS---------------------------------------------------------------     CHECK FOR REUSE + CAST DONE
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function PartyRess()															
	local me = GetMe();															
	local MurderedMember = CheckForPartyRess();
	if (WeInParty) then
		if (Massress) then										
			ShowToClient(os.date("%X"), "11.#CAST PARTY RESS");
			CastOnTarget(PartyResSkill,PartyResSkillID,MurderedMember);									
		else																		
			if (MurderedMember == "All-ok") then
				ShowToClient(os.date("%X"), "12.# All-Ok");
			else
				ShowToClient(os.date("%X"), "13.#Need Res!! for " .. MurderedMember:GetName());
				CastOnTarget(ResSkill,ResSkillID,MurderedMember);					
			end;
		end;																		
	else
		ShowToClient(os.date("%X"), "We not in party.");
	end;
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------#CHECK FOR LUMI--------------------------------------------------------------
-------------------------------------------------CHECK FOR LUMI---------------------------------------------------------------     CHECK + CAST DONE
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function CheckForLumi()																									
	if LumiOn then																										
		ShowToClient(os.date("%X"), "#LUMI ON");
		local me = GetMe();																								
		local PartyLeader = GetPartyMaster();																			
		local MA = GetUserByName(MainAssist);																			
		local monster = nil;																							
		local teras = nil;																								
		if HealerLumiOnMa == true then																					
			if not me:IsUsingMagic() then																				
				teras = GetUserById(MA:GetTarget());																	
				if (teras ~= nil) then																					
					if teras:IsMonster() and not teras:IsAlikeDeath() then												
						if (not teras:GotBuff(LumiSkillID)) and (teras:GetHpPercent() <= MonsterLumiHp) then			
							CastOnTarget(LumiSkill,LumiSkillID,teras);													
						end;																							
					end;																								
				end;																									
			end;																										
		else																											
			if not me:IsUsingMagic() and (PartyLeader:GetTarget() ~= nil) then											
				monster = GetUserById(PartyLeader:GetTarget());															
				if (monster ~= nil) then																				
					if (monster:IsMonster()) and not (monster:IsAlikeDeath()) then										
						if (not monster:GotBuff(LumiSkillID)) and (monster:GetHpPercent() <= MonsterLumiHp) then		
							CastOnTarget(LumiSkill,LumiSkillID,monster);												
						end;																							
					end;																								
				end;																									
			end;																										
		end;																											
	end;																												
end;																													
																														
																														
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------PURGE------------------------------------------------------------------
-------------------------------------------------CHECK FOR PURGE--------------------------------------------------------------     CHECK
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function NeedPurge(target)																								 
	local MyBuffs = {} ;																								
	for x=1,50 do																										
		local value = nil;																								
		value = target:GetBuffByIdx(x);																					
		if value ~= nil then																							
			MyBuffs[#MyBuffs+1] = value.skillId;																		
		end;																											
	end;																												
	for x=1,#DebuffList do																								
		for t=1,#MyBuffs do																								
			if (MyBuffs ~= nil) and (MyBuffs[t] == DebuffList[x]) then													
				ShowToClient(os.date("%X"), "#need to use Purge!");
				return true;																							
			end;																										
		end;																											
	end;																												
	--ShowToClient(os.date("%X"), "#Don't need to use Purge!");
	return false;																										
end;																													
																														
------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------CAST PURGE------------------------------------------------------------------  CHECK FOR REUSE AND CAST
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function Purge()																										
	local me = GetMe();																									
	local PartyList = GetPartyList();																					
	local counter = 0;																									
	if (me ~= nil) then																									
		for member in PartyList.list do																					
			if NeedPurge(member) then																					
				counter = counter + 1;																					
			end;																										
		end;																											
		if (counter > 1) and (BrilliantPurgeSkill:CanBeUsed()) then														
			ShowToClient(os.date("%X"), "#CAST PURGE-mass");
			Cast(RadiantPurgeSkill,RadiantPurgeSkillID);																
		else																											
			for member in PartyList.list do																				
				if NeedPurge(member) then																				
					if (not member:IsAlikeDeath()) and (member:GetDistance() < 1000) then								
						ShowToClient(os.date("%X"), "#CAST PURGE-on target");
						CastOnTarget(BrilliantPurgeSkill,BrilliantPurgeSkillID,member);										
					end;																								
				end;																									
			end;																										
		end;																											
	end;																												
end;																													
																														
																														
------------------------------------------------------PURGE------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------MAIN-----------------------------------------------------------------
																														
																														
function HealParty()																									
	ShowToClient(os.date("%X"), "#HealParty", 20)
	local me = GetMe(); 																								
	if (me:GetHpPercent() < CrystalRegenHP) and (CrystalRegenSkill:CanBeUsed()) then									
		CastOnTarget(CrystalRegenSkill,CrystalRegenSkillID,me);															
	elseif (me:GetHpPercent() < GiantsFavorHP) and (GiantsFavorSkill:CanBeUsed()) then									
		CastOnTarget(GiantsFavorSkill,GiantsFavorSkillID,me);															
	end;																												
	--CheckForLumi();																										
	Purge();																											
	if (CheckForPartyCelestial()) then																					
		PartyCelestial();																								
	end;																												
	if (CheckForBalanceHeal()) and (BalanceHealSkill:CanBeUsed()) then													
		BalanceHeal();																									
		Sleep(250);																										
		ChainHeal();
		Sleep(250);
		BrilliantHeal();																								
		Sleep(250);																										
		--RechargeMp();			--for SE EE only																		
		return true;																									
	elseif (not BalanceHealSkill:CanBeUsed()) and (CheckForBrilliantHeal()) and (BrilliantHealSkill:CanBeUsed()) then	
		BrilliantHeal();																								
		return true;																									
	elseif (CheckForPanicHeal()) then																					
		if (not BalanceHealSkill:CanBeUsed()) and (not BrilliantHealSkill:CanBeUsed()) then								
			PanicHeal();																								
			return true;																								
		end;																											
	else																												
		return false;																									
	end;																												
end;																													
																														
																														
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
																														
																														
function Healer()																										
	local me = GetMe();																									
	if not HealParty() then																								
		if CheckForRebirth() then																						
			Rebirth();																									
		end;																											
		-- CheckForDivine();		-- dont need Prayer																	
		-- CheckForLumi();																									
		Purge();																										
		ShowToClient(os.date("%X"), "#CheckForPurge - end");
		-- RechargeMp();	-- for EE SE only																			
		CheckForSalvation();																							
		ShowToClient(os.date("%X"), "#CheckForSalvation - end");
		CheckForNobless();																								
		ShowToClient(os.date("%X"), "#CheckForNobless - end");
		PartyRess();																									
		ShowToClient(os.date("%X"), "#PartyRessCheck - end");
	end;																												
end;																													

------------------------------------------------------------------------------------------------------------------------------
if (GetMe():GetClass() == 97) or (GetMe():GetClass() == 180) or (GetMe():GetClass() == 181) then
	ShowToClient(os.date("%X"), "I am Healer, lets start", 20);
	repeat																													
		if not IsPaused() then																								
			if not (GetMe():IsBlocked(true)) then 																		
				Healer();	
				if GetTarget() then 
					ClearT();
				end
				Sleep(5000);																						
			end;																											
		end;																									
	until false;
else
	ShowToClient(os.date("%X"), "We is not a Healer!")
end

----------------------------------------------------END-----------------------------------------------------------------------