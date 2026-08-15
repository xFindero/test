AlarmSound = GetDir() .. "\\sound\\alarm.wav";
DCSound = GetDir() .. "\\sound\\dc.wav";
DieSound = GetDir() .. "\\sound\\die.wav";
FoundSound = GetDir() .. "\\sound\\found.wav";
GMSound = GetDir() .. "\\sound\\gm.wav";
GoodSound = GetDir() .. "\\sound\\Good.wav";
HPSound = GetDir() .. "\\sound\\hp.wav";
MsgSound = GetDir() .. "\\sound\\msg.wav";
PlayerSound = GetDir() .. "\\sound\\PlayerAlarm.wav";
SirenaSound = GetDir() .. "\\sound\\sirena.wav";
----------------------------------
FrasesPVP 	= {"a.","ee","34444aaass","7d77","bla","lol",":)",")~"};
FrasesPVE 	= {"b.","ui","2222sss","333rr","blat","lolo",":(","arr~"};
----------------------------------
AlarmStatus = false;
msgTime		=	0
warMsgTime	=	0
msgTime1	=	0
msgTime2	=	0
msgDelay	=	15		-- in sec, delay betwen messages
WarMsgDelay	=	10		-- in sec, delay betwen messages
----------------------------------

 
function OnCreate()
	this:RegisterCommand("aa", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	LastAlarmTime = 0;
	LastAlarmT = 10;
end;

function ClearT()
	ClearTargets();
	CancelTarget(false);
	Sleep(123);
	ClearTargets();
end
 
function OnCommand_aa(vCommandChatType, vNick, vCommandParam)
	msgCounter = 0
	if (AlarmStatus == false) then
		AlarmStatus = true;
		ShowToClient(tostring(os.date("%X")),"Alarm Is Activated.", 20);
		alarmDone	=	false
		firstAttack	=	true
	else
		AlarmStatus = false;
		ShowToClient(tostring(os.date("%X")),"Alarm Is Deactivated.", 20);	
	end;
end;

function SaySomething()
	local say = 0
	say = tonumber(string.sub(os.time(),-1))
	ShowToClient(tostring(os.date("%X")), "number0: " .. say, 20)
	
	if ( GetMe():GetCpPercent() <= 90 ) then
		ShowToClient(tostring(os.date("%X")), "CP not full");
		Sleep(500)
		-------------
		if ( say > #FrasesPVP or say == 0 ) then
			say = math.random(0,#FrasesPVP)
		--else
			-- use last sign of time
		end
		
		ShowToClient(tostring(os.date("%X")), "number: " .. say, 20)
		ShowToClient(tostring(os.date("%X")), "txt: " .. FrasesPVP[say], 20)
		-------------
		Command(FrasesPVP[say]);
	else
		ShowToClient(tostring(os.date("%X")), "CP - full");
		Sleep(500)
		if ( say > #FrasesPVE or say == 0 ) then
			say = math.random(0,#FrasesPVE)
		--else
			-- use last sign of time
		end
		
		ShowToClient(tostring(os.date("%X")), "number: " .. say, 20)
		ShowToClient(tostring(os.date("%X")), "say: " .. FrasesPVE[say], 20)
		-------------
		Command(FrasesPVE[say]);
	end
	
end

function Sound(alarm)
	local result = false;
	if ( PlaySound(alarm)) then
		--ShowToClient("#", "Succes!")
		result = true;
	else
		ShowToClient("#", " Sound Failed!")
	end
	return result
end

function OnDisconnect(mode)
	local nick = GetMe():GetName();
	ShowToClient(tostring(os.date("%X")), " " .. nick .. " DISCONNECTED!");
	Sound(AlarmSound)
	Sleep(100)
end;
 
function OnDie(user, spoiled)
	if ( user:GetName() == GetMe():GetName() )  then
		if ( GetMe():GetCpPercent() < 70 ) then
			ShowToClient(tostring(os.date("%X")), "Killed by Player");
			Sound(SirenaSound);
			local playersNear = GetPlayerList();
			for player in playersNear.list do
				if ( not player:IsMyPartyMember()  and  player:GetDistance() < 2500 ) then
					ShowToClient(tostring(os.date("%X")), "Near us was:");
					ShowToClient("", player:GetName() .. " Dist [" .. player:GetDistance()  .. "], PVP status: " .. tostring(player:IsPvPFlag()) .. ", Clan: " .. tostring(player:GetClanName()) );			
				end;
			end;
		else
			Sound(DieSound)
			ShowToClient(tostring(os.date("%X")), "Killed by monsters?");
		end
		Sleep(100)
	end;
end;

function OnChatUserMessage(chatType, nick, msg)
	if ( not IsPaused() and AlarmStatus ) then
		if (chatType == 2) then		--PM
			Sound(MsgSound)
		end;
		if (chatType == 0) then		--General chat
			Sound(MsgSound)
			---------
			if ( msgCounter < 1 ) then
				local MyPL = GetPartyMaster();
				if ( MyPL and MyPL:GetName() == GetMe():GetName() ) then
					ShowToClient(tostring(os.date("%X")), "I'm PL",20);
					Sleep(5000)			--замінити на щось, вікно завмирає
					SaySomething()
				else
					ShowToClient(tostring(os.date("%X")), "PL not found",20);
					Sleep(5000)
					SaySomething()
				end
				msgCounter = msgCounter + 1
			end
		end;
	--else
		--ShowToClient(tostring(os.date("%X")), "msg no active");
	end
end;

function OnAttack(user, target) -- On Attack to usser
	if ( (GetTime() - msgTime1) > msgDelay * 1000 and AlarmStatus == true) then -- enable only 1 toon, to not make mass noise
		if (target:IsMe() or target:IsMyPartyMember()) and (user:IsPlayer()) then -- if target is me or my pt member and attacker is player
			Sound(SirenaSound)
			ShowToClient(tostring(os.date("%X")), "Attackker: " .. user:GetName(),20);
			ShowToClient(tostring(os.date("%X")), "Attackker Clan: " .. tostring(user:GetClanName()), 20);
			msgTime1 = GetTime();
		end; 
	end; 
end;

function OnMagicSkillLaunched(user, target, skillId)
	if ( (GetTime() - msgTime2) > msgDelay * 1000 and AlarmStatus == true) then
		if (user == nil ) then
			ShowToClient(tostring(os.date("%X")), "user NotDefined")
		end
		-- if (target == nil ) then
			-- ShowToClient(tostring(os.date("%X")), "target NotDefined")
		-- end
		if ( user ~= nil and target ~= nil ) then
			if (target:IsMe() or target:IsMyPartyMember()) and (user:IsPlayer() and not user:IsMyPartyMember() and not user:IsMe() ) then -- if target is me or my pt member and attacker is player
				Sound(SirenaSound)
				ShowToClient(tostring(os.date("%X")), "Player: " .. user:GetName() .. " Clan: " .. tostring(user:GetClanName()) .. " target: " .. target:GetName() .. " ID: " .. skillId,20);
				msgTime2 = GetTime();
			end;
		end
	end;
end;

function OnLTick1s()
	if	((GetTime() - msgTime) > msgDelay * 1000 and AlarmStatus and not ( GetZoneType() == L2ZoneType.PEACEFUL )) then
		local playerList = GetPlayerList()	
		for player in playerList.list do
			pDist	=	player:GetDistance()
				if ( not player:IsMyPartyMember() and not IsPaused() ) then
					--------------
					--ShowToClient(tostring(os.date("%X")), "player: Party.M. " .. tostring(player:IsMyPartyMember()) .. " Clan.M: " .. tostring(player:IsMyClanMember()) .. " Ali.M: " .. tostring(player:IsMyAllianceMember()),20);
					if ( ( not player:IsMyClanMember() or not IsMyAllianceMember()) and ( player:IsEnemy() or player:GetReputation() < 0 or player:IsPvPFlag() or player:IsPvPFlagBlink())) then
						if ( pDist < 2000 ) then
							if ( pDist < 1500 ) then
								Sound(SirenaSound)
								chatType = 2
								-- if firstAttack then
									-- ProcessCommand("/scriptStopAll");
									-- ClearT();
									-- ShowToClient(tostring(os.date("%X")), "Defend against: " .. player:GetName(),20);
									-- firstAttack	=	false
								-- else
									-- ShowToClient(tostring(os.date("%X")), "defend already started...",20);
								-- end
								-- Target(player)
								-- Sleep(300)
								-- Command("/attack");
								-- Sleep(300)
								-- Command("/attack");
							else
								Sound(FoundSound)
								chatType = 20
							end
						ShowToClient(tostring(os.date("%X")), "W or PVP: " .. player:GetName() .. " Clan: " .. tostring( player:GetClanName()) .. " [" .. pDist .. "]",chatType);
						msgTime = GetTime();
						end
					else
					--------------
						if ( pDist < 1000 ) then
							if ( pDist < 500 ) then
								Sound(PlayerSound)
								chatType = 2
							else
								Sound(FoundSound)
								chatType = 20
							end
							ShowToClient(tostring(os.date("%X")), "PVE: " .. player:GetName() .. " Clan: " .. tostring(player:GetClanName()) .. " [" .. pDist .. "]",chatType);
							msgTime = GetTime();
						end
					end
				--else
					--ShowToClient(tostring(os.date("%X")), "Stopped. Dont Attack!",20);
				end
				
		end
	end
end