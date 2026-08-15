local me = GetMe()
ShowToClient(os.date("%X"), "IsAlikeDeath: " .. tostring( me:IsAlikeDeath() ), 20)
ShowToClient(os.date("%X"), "IsBlocked: " .. tostring( me:IsBlocked(true) ), 20)
ShowToClient(os.date("%X"), "IsBlock: " .. tostring( me:IsBlock() ), 20)

target = GetTarget()
ShowToClient(os.date("%X"), "mob buff count: " .. tostring(target:GetBuffsCount()), 20)
ShowToClient(os.date("%X"), "mob GetStatPhysicalDefense: " .. tostring(target:GetStatPhysicalDefense()), 20)
ShowToClient(os.date("%X"), "Zone : " .. tostring(GetZoneType()), 20)
