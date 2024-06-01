-- Function to move and focus window based on application name
function assign_to_workspace(app_name_pattern, workspace)
	local app_name_lower = string.lower(get_application_name())
	if string.find(app_name_lower, app_name_pattern:lower(), 1, true) then
		set_window_workspace(workspace)
	end
end

-- Main execution block
debug_print("Window class: " .. get_window_class())
debug_print("Application name: " .. get_application_name())

-- Assign applications to workspaces
assign_to_workspace("rambox", 1)
assign_to_workspace("libreoffice", 2)
assign_to_workspace("obsidian", 3)
assign_to_workspace("kitty", 3)
assign_to_workspace("draw.io", 4)
assign_to_workspace("postman", 4)
assign_to_workspace("obs", 4)
assign_to_workspace("gimp", 4)
assign_to_workspace("google-chome", 5)
assign_to_workspace("org.wezfurlong.wezterm", 6)
assign_to_workspace("code", 6)
assign_to_workspace("bitwarden", 7)
assign_to_workspace("org.remmina.Remmina", 8)
assign_to_workspace("vmware", 8)
assign_to_workspace("gnome-control-center", 9)
