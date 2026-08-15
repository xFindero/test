
function GotoSpot(spotX,spotY,spotZ, dist)
		ShowToClient("#", "to Spot: " .. spotX .. ": Radius = " .. dist, L2ChatType.CHAT_HERO);
		ShowTrace(FVector(spotX, spotY, spotZ));
		--MoveTo(spotX, spotY, spotZ, dist);
		Sleep(5000)
end;


ShowToClient("#", "-----------");

moveDistance = 50;

	--ShowTrace(FVector(52121, 219153, -3224));
	--Sleep(5000)
	
--GotoSpot

	--GotoSpot(146185, 111288, -3570, moveDistance);
	--GotoSpot(146649, 111625, -3540, moveDistance);
	--GotoSpot(147229, 111977, -3720, moveDistance);
	--GotoSpot(147996, 112013, -3720, moveDistance);
	--GotoSpot(148591, 112211, -3717, moveDistance);
	--GotoSpot(149017, 113122, -3720, moveDistance);
	--GotoSpot(149237, 113946, -3720, moveDistance);
	--GotoSpot(149367, 115146, -3720, moveDistance);
	--GotoSpot(149456, 115712, -3699, moveDistance);
	--GotoSpot(149700, 116195, -3701, moveDistance);	-- з кола на місточок до Серця
	--GotoSpot(149932, 116537, -3701, moveDistance);
	--GotoSpot(150217, 117070, -3695, moveDistance);
	--GotoSpot(150669, 117863, -3690, moveDistance);
	--GotoSpot(150998, 118130, -3721, moveDistance);
	--GotoSpot(151563, 118464, -3894, moveDistance);
	--GotoSpot(151749, 118786, -3866, moveDistance);
	--GotoSpot(151967, 118943, -3811, moveDistance);
	GotoSpot(152440, 119314, -3788, moveDistance);
	GotoSpot(152579, 119524, -3787, moveDistance);
		
		
ShowToClient("#", "End",20);