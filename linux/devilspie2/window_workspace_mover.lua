-- Function to move and focus window based on application name
function assign_to_workspace(app_name, workspace)
	if string.lower(get_application_name()) == string.lower(app_name) then
		set_window_workspace(workspace)
	end
end
-- Main execution block
debug_print("Window class: " .. get_window_class())
debug_print("Application name: " .. get_application_name())

-- Assign applications to workspaces
assign_to_workspace("rambox", 1)
assign_to_workspace("libreoffice", 2)
assign_to_workspace("libreoffice-writer", 2)
assign_to_workspace("libreoffice-calc", 2)
assign_to_workspace("libreoffice-impress", 2)
assign_to_workspace("libreoffice-draw", 2)
assign_to_workspace("libreoffice-math", 2)
assign_to_workspace("libreoffice-base", 2)
assign_to_workspace("obsidian", 3)
assign_to_workspace("alacritty", 3)
assign_to_workspace("draw.io", 4)
assign_to_workspace("postman", 4)
assign_to_workspace("firefox", 5)
assign_to_workspace("google-chome", 5)
assign_to_workspace("kitty", 6)
assign_to_workspace("pycharm-community", 6)
assign_to_workspace("bitwarden", 7)
assign_to_workspace("spotify", 7)
assign_to_workspace("remmina", 8)
