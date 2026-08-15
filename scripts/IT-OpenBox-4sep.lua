ItemsToCreate	=	10000
--ItemName	=	"Sealed Box"

------------------------------------
function exchangeItem()
	Talk();
	--ClickAndWait("npc_268476481_Quest", "Quest");
	--ClickAndWait("Quest Q00620_FourGoblets 31454-07.html", "\"Please open the boxes.\"");
	ClickText("Quest")
	Sleep(354)
	ClickText("box")
	Sleep(354)
	Talk();
	RndSleep = 300 + 3*(math.random(1,50));
	--ShowToClient("Delay", RndSleep .."# Random pause ", L2ChatType.CHAT_HERO);
	Sleep(RndSleep);
	return 0
end

function ClickAndWait(link, name)
	QuestReply(link)
	Sleep(421)
end

---------------------------------------
ItemCounter=0
MyTarget = GetTarget();
-- MAIN --
ShowToClient("-", "-------------------------");
ShowToClient("#", tostring(os.date("%X")), 20);
ShowToClient("#", "Items to exchange: " .. ItemsToCreate, 20);


while ( ItemCounter < ItemsToCreate and MyTarget~=nil ) do
		if ( (ItemCounter % 100) == 0 ) then
			ShowToClient("[*]", "ItemCounter " .. ItemCounter, 20);
		end
		exchangeItem()
		MyTarget = GetTarget();
		ItemCounter = ItemCounter + 1
end

ShowToClient("[Finished]", "We made " .. ItemCounter .. " exchanges.", 20);


