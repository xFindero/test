SCONFIG = L2TConfig.GetConfig();
SCONFIG_FILE = GetDir() .. '\\scripts\\002.l2b';
L2TConfig.SaveConfig(SCONFIG_FILE);
moveDistance = 30;


L2TConfig.LoadConfig(SCONFIG_FILE);
