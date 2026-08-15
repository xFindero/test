SCONFIG = L2TConfig.GetConfig();
SCONFIG_FILE = GetDir() .. '\\scripts\\sep2.l2b';
L2TConfig.SaveConfig(SCONFIG_FILE);
moveDistance = 30;

MoveTo(178256, -85495, -7218, moveDistance);
MoveTo(178267, -85528, -7218, moveDistance);
MoveTo(176436, -85603, -7221, moveDistance);
MoveTo(175743, -85687, -7221, moveDistance);
MoveTo(175459, -88023, -7220, moveDistance);
MoveTo(173218, -87909, -7221, moveDistance);
TargetNpc("Great Sages' Sepulcher Manager", 31923);
Talk();
ClickAndWait("npc_268476601_Quest", "Quest");
MoveTo(173170, -86991, -7221, moveDistance);
L2TConfig.LoadConfig(SCONFIG_FILE);
