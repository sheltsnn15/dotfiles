local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Font settings
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12.0

-- Scrollback settings
config.scrollback_lines = 8000

-- Hyperlink settings
config.hyperlink_rules = {
	{
		regex = "\\b\\w+://[\\w.-]+\\S*\\b",
		format = "$0",
	},
}

-- Mouse configuration
config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = "OpenLinkAtMouseCursor",
	},
}

-- Window and layout settings
config.initial_cols = 80
config.initial_rows = 24
config.enable_scroll_bar = false

-- Background and appearance
config.window_background_opacity = 1.0
config.window_background_image = nil

-- Startup command
config.default_prog = { "/bin/bash" }

-- Key mappings
config.keys = {
	{ key = "Enter", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
	{ key = "F11", action = "ToggleFullScreen" },
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
}

-- Cursor customization
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.cursor_blink_rate = 500
config.cursor_thickness = "1px"

-- Tab bar settings
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Color scheme
config.color_scheme = "Catppuccin Macchiato"

-- Miscellaneous
config.audible_bell = "Disabled"
config.enable_wayland = false

return config
