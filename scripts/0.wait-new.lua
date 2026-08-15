while ( true ) do
	ShowToClient(os.date("%X"), "Start to wait for new Dialog: ");
	if ( WaitForNewDialog() ) then
		ShowToClient(os.date("%X"), "new dialog! ");
		local msg = tostring(GetDialogHtml());		-- get last dialog
		ShowToClient(os.date("%X"), msg ,20);
	else
		ShowToClient(os.date("%X"), "no new dialog! ");
	end
ShowToClient(os.date("%X"), "end wait and repeat");
Sleep(5000)
end
ShowToClient(os.date("%X"), "Exit");