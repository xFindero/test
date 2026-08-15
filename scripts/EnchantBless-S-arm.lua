-- SCRIPT CONFIGURATION!
EnchantArmor		= true
EnchantWeapon		= false
max_enchant 		= 25
--------------------------------
max_safe_enchant	= 3
max_bless			= 12
max_divine			= 20
startFrom			= 10
--------------------------------
--item_to_Enchant = {"Elegia Breastplate",  "Elegia Gaiter", "Elegia Boots", "Elegia Gauntlet", "Elegia Helmet", "Elegia Shield"}
--item_to_Enchant = {"Moirai Boots", "Moirai Gaiter",  "Moirai Gauntlet", "Moirai Helmet", "Moirai Breastplate"}
--item_to_Enchant = {"Vorpal Breastplate", "Vorpal Gaiter", "Vorpal Shield", "Vorpal Boots", "Vorpal Gauntlet", "Vorpal Helmet"}
--item_to_Enchant = {"Sealed Vesper Gaiters", "Sealed Vesper Shield", "Sealed Vesper Boots", "Sealed Vesper Helmet", "Sealed Vesper Gauntlet", "Sealed Vesper Breastplate"}
--item_to_Enchant = {"Elegia Circlet", "Elegia Tunic", "Elegia Stockings", "Elegia Gloves", "Elegia Shoes", "Elegia Sigil", "Mithril Belt", "Blessed Earring of Zaken", "Earring of Antharas", "Necklace of Valakas",  "Ring of Baium", "Ring of Beleth"}
--item_to_Enchant = {"Sealed Vesper Shield", "Sealed Moirai Sigil", "Sealed Moirai Shield"}
--item_to_Enchant = {"Blessed Earring of Zaken", "Earring of Antharas", "Necklace of Valakas",  "Ring of Baium", "Ring of Beleth"}
--item_to_Enchant = {"Earring of Zaken", "Necklace of Freya"}	--, "Sealed Vesper Shield", "Sealed Moirai Sigil", "Sealed Moirai Shield"}
--item_to_Enchant = {"Sealed Dynasty Leather Armor", "Sealed Dynasty Leather Leggings", "Sealed Dynasty Leather Helmet", "Sealed Dynasty Leather Gloves", "Sealed Dynasty Leather Boots", "Sealed Dynasty Gaiter", "Sealed Vesper Gaiters", "Sealed Vesper Shield", "Sealed Moirai Leather Boots", "Sealed Vesper Boots", "Sealed Vesper Helmet", "Sealed Moirai Helmet", "Sealed Vesper Helmet", "Sealed Vesper Gauntlet", "Sealed Vesper Breastplate", "Sealed Moirai Gauntlet"}
item_to_Enchant = {"Top-grade Magic Ornament Mithril Belt", "Dynasty Leather Armor", "Dynasty Jeweled Leather Armor", "Dynasty Leather Leggings", "Dynasty Leather Boots", "Dynasty Leather Helmet", "Dynasty Leather Gloves", "Elegia Leather Helmet",  "Elegia Leather Breastplate", "Elegia Leather Legging", "Elegia Leather Gloves", "Elegia Leather Boots", "Blessed Earring of Zaken", "Earring of Antharas", "Necklace of Valakas",  "Ring of Baium", "Ring of Beleth"}
--item_to_Enchant = {"Elegia Leather Helmet",  "Elegia Leather Breastplate", "Elegia Leather Legging", "Elegia Leather Gloves", "Elegia Leather Boots", "Blessed Earring of Zaken", "Earring of Antharas", "Necklace of Valakas",  "Ring of Baium", "Ring of Beleth"} --, "Mithril Belt"}
--item_to_Enchant = {"Recurve Thorne Bow", "Thorne Crossbow"}
--item_to_Enchant = {"Vesper Noble Leather Helmet", "Vesper Noble Leather Breastplate", "Vesper Noble Leather Legging", "Vesper Noble Leather Gloves", "Vesper Noble Leather Boots", "Blessed Earring of Zaken", "Earring of Antharas", "Necklace of Valakas",  "Ring of Baium"}
--item_to_Enchant = { "Elegia Breastplate",  "Elegia Gaiter", "Elegia Boots", "Elegia Gauntlet", "Elegia Helmet", "Elegia Shield"}
--item_to_Enchant = {"Sealed Vesper Circlet", "Sealed Vesper Tunic", "Sealed Vesper Shoes", "Sealed Vesper Sigil", "Sealed Vesper Stockings","Sealed Vesper Stockings","Sealed Vesper Gloves"}
--item_to_Enchant = {""Sealed Vesper Circlet", "Vesper Noble Circlet", "Sealed Vesper Tunic", "Vesper Noble Tunic", "Sealed Vesper Shoes", "Sealed Vesper Sigil", "Sealed Vesper Stockings","Vesper Noble Stockings", "Sealed Vesper Gloves", "Vesper Noble Gloves", "Vesper Shoes", "Vesper Noble Shoes""}
--item_to_Enchant = {"Vorpal Leather Breastplate", "Vorpal Leather Legging", "Vorpal Leather Gloves", "Vorpal Leather Helmet", "Vorpal Leather Boots"}
--item_to_Enchant = {"Draconic Leather Armor", "Draconic Leather Boots", "Draconic Leather Helmet", "Draconic Leather Gloves"};
--item_to_Enchant = {"Skull Edge Dual Daggers"}
--item_to_Enchant = {"Sealed Dynasty Leather Armor", "Sealed Dynasty Leather Leggings", "Sealed Dynasty Leather Helmet", "Sealed Dynasty Leather Gloves", "Sealed Dynasty Leather Boots"}

-- END OF SCRIPT CONFIGURATION
 
-- HELPER FUNCTIONS
stats = {}
------
function enchantResult()
  return GetEnchantManager():getLastResult()
end
 
function getItemByName(name, maxenchant)
	invList = GetInventory();
	local result = nil;
	
	for item in invList.list do
		if item.Name == name and item.Enchanted < maxenchant then
			result = item
		end
	end
	return result
end
 
function registerSuccess(base)
	if stats[base] == nil then
		stats[base] = { success = 0, failure = 0 }
	end
	stats[base].success = stats[base].success + 1
end
 
function registerFailure(base)
	if stats[base] == nil then
		stats[base] = { success = 0, failure = 0 }
	end
	stats[base].failure = stats[base].failure + 1
end
 
function printStatistics()
	for i,v in ipairs(stats) do
		ShowToClient(tostring(os.date("%X")), " [" .. 	i - 1 .. "->" .. i .. "] Rate: success: " .. v.success .. " / fail: " .. v.failure .." (" .. ( v.success  * 100 )/ ( v.success + v.failure ) .. "%)")
	end
end

--- main ---
function main()
	ShowToClient(tostring(os.date("%X")), "-------------------------");
	
	
	if ( EnchantArmor ) then
		ShowToClient(tostring(os.date("%X")), " [Enchant with Bless - Armor from " .. startFrom .. " ]", 20);
	else
		ShowToClient(tostring(os.date("%X")), " [Enchant with Bless - Weapon from +" .. startFrom .. " ]", 20);
	end
	
	local stopScr = false;
	for enchantCounter = startFrom, max_enchant do
		if (stopScr) then
			ShowToClient (tostring(os.date("%X"))," Divine scrolls ends or else ", 20);
			break;
		end;
		for itemCounter = 1, #item_to_Enchant do
			me = GetMe();
			if ( me:IsAlikeDeath() ) then
				ShowToClient (tostring(os.date("%X")), " Murdered!", 20);
				stopScr = true;
			elseif ( max_enchant > 17 ) then
				if ( getItemByName(divine_arm, 20) == nil ) then
					stopScr = true;
				elseif ( getItemByName(divine_arm, 20).ItemNum <= 1 ) then
					ShowToClient (tostring(os.date("%X"))," Divine scrolls ends", 20);
					stopScr = true;
				end
			end;
	 
			while ( not stopScr ) do
				-- find item for enchanting
				item = getItemByName(item_to_Enchant[itemCounter], enchantCounter)
				Sleep(435)
				if ( item == nil ) then
					-- ShowToClient(tostring(os.date("%X")), "Out of items - Enchant" )
					break;
				end
				-- find proper enchant scroll
				enchant = nil
				if ( item.Enchanted >= max_safe_enchant ) then  -- { >3 }
					--ShowToClient(tostring(os.date("%X")), "item.Enchanted: " .. item.Enchanted , 20);
					if ( item.Enchanted >= max_bless and item.Enchanted < max_divine) then  -- { <19 } use Divine
						--ShowToClient(tostring(os.date("%X")), "item.Enchanted >= max_bless and item.Enchanted <= max_divine. Use Divine ", 20);
						enchant = getItemByName(divine_arm, 20)
						--Sleep (15000)
					else
						--ShowToClient(tostring(os.date("%X")), "item.Enchanted < max_bless or item.Enchanted > max_divine. Use Bless", 20);
						enchant = getItemByName(blessed_enchant_name, 20)
						--Sleep (15000)
					end
				else
					--ShowToClient(tostring(os.date("%X")), "Use no Bless ", 20);
					enchant = getItemByName(enchant_name, 20)
				end
			 
				if ( enchant == nil ) then
					ShowToClient(tostring(os.date("%X")), " Out of enchants",20)
					Sleep ( 50000 )
					break;
				end
				if ( enchantCounter <= 4 ) then
					delay = 2000 + 1*(math.random(500,1000)) -- from 2s to 7s
				elseif ( enchantCounter > 4 and enchantCounter <= 9) then
					delay = 2000+1*(math.random(500,1200)) -- from 2s to 8.5s
				else
					delay = 2000+1*(math.random(500,3000)) -- from 2s to 10s
				end;
				GetEnchantManager():setDelay(delay)
				GetEnchantManager():setEnchantId(enchant.objectId)
				GetEnchantManager():setItemId(item.objectId)
				GetEnchantManager():Enchant()
				EnchantStarted = GetTime()
				timeNow = GetTime()
				retryCounter = 0
	
				while ( enchantResult() == Enchant.ENCHANT_PENDING ) do
					--ShowToClient(tostring(os.date("%X")),  " timeNow - EnchantStarted " .. ((timeNow - EnchantStarted)/1000), 20);
					if (timeNow - EnchantStarted > 15000 ) then
						ShowToClient(tostring(os.date("%X")),  " retry Enchant after " .. ((timeNow - EnchantStarted)/1000) .. "s. Retry: " .. retryCounter, 3);
						EnchantStarted = GetTime()
						GetEnchantManager():Enchant()
						retryCounter = retryCounter +1
					end
					Sleep ( 1000 +1*(math.random(100,200)) ) -- sleep so item data is updated
					timeNow = GetTime()
					---
				if ( enchantResult() == Enchant.ENCHANT_ERROR ) then	
					ShowToClient(tostring(os.date("%X")), " ENCHANT_ERROR  " .. item.Name .. " " .. item.Enchanted, 20);
				end
					---
				end
			 
				if ( enchantResult() == Enchant.ENCHANT_SUCCESS ) then	
					Sleep ( 1500 +1*(math.random(100,200)) ) -- sleep so item data is updated
					item = GetInventory():FindById(item.objectId)
					ShowToClient(tostring(os.date("%X")), " " .. item.Name .. " is now +" .. item.Enchanted, 20);
					registerSuccess ( item.Enchanted )
				elseif ( enchantResult() == Enchant.ENCHANT_FAILURE ) then
					ShowToClient(tostring(os.date("%X")), " " .. item.Name .. " failed on " .. item.Enchanted .. " -> " .. item.Enchanted+1, 19);
					Sleep ( 1500 +1*(math.random(100,500)) ) -- sleep so item data is updated
					registerFailure ( item.Enchanted + 1)
				end
				if ( enchantResult() == Enchant.ENCHANT_ERROR ) then	
					ShowToClient(tostring(os.date("%X")), " ENCHANT_ERROR  " .. item.Name .. " " .. item.Enchanted, 20);
				end
				--printStatistics()
			end

		end
		if ( enchantCounter < max_divine ) then 
			RndSleep = 1500 + 3*(math.random(50,1300));
		else
			RndSleep = 1000 + 3*(math.random(50,1300));
		end;
		
		--ShowToClient(tostring(os.date("%X")), RndSleep .."# Random pause after " .. enchantCounter .. " lvl" , 20);
		Sleep(RndSleep);
	end
	Sleep ( 1000 )
	printStatistics()
end

------------------
if ( EnchantArmor ) then
	---- Armor ---
	enchant_name = "Scroll: Enchant Armor (S-Grade)"
	blessed_enchant_name = "Blessed Scroll: Enchant Armor (S-Grade)"
	divine_arm = "Divine Armor Enchant Crystal (S-Grade)"
	main()
elseif ( EnchantWeapon ) then
	---- Weapon ---
	enchant_name = "Scroll: Enchant Weapon (S-Grade)"
	blessed_enchant_name = "Blessed Scroll: Enchant Weapon (S-Grade)"
	divine_arm = "Divine Weapon Enchant Crystal (S-Grade)"
	main()
else
	ShowToClient(tostring(os.date("%X")), " Wrong Enchant A/W settings") 
end

ShowToClient(tostring(os.date("%X")), "Enchant script finished", 20);

--- Enchants library ---
-- --- S Arm ---
-- Scroll: Enchant Armor (S-Grade)
-- Blessed Scroll: Enchant Armor (S-Grade)
-- Divine Armor Enchant Crystal (S-Grade)
-- --- S Weap ---
-- Scroll: Enchant Weapon (S-Grade)
-- Blessed Scroll: Enchant Weapon (S-Grade)
-- Divine Weapon Enchant Crystal (S-Grade)
-- --- B Arm ---
-- Scroll: Enchant Armor (B-Grade)
-- Blessed Scroll: Enchant Armor (B-Grade)
-- Divine Armor Enchant Crystal (B-Grade)
---
-- --- A Weap ---
-- Scroll: Enchant Weapon (A-Grade)
-- Blessed Scroll: Enchant Weapon (A-Grade)
-- Divine Weapon Enchant Crystal (A-Grade)
---
-- --- A Arm ---
-- Scroll: Enchant Armor (A-Grade)
-- Blessed Scroll: Enchant Armor (A-Grade)
-- Divine Armor Enchant Crystal (A-Grade)
---