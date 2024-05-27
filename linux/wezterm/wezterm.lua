-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.font = wezterm.font_with_fallback({
	"Fira Code",
	"JetBrains Mono",
})

-- For example, changing the color scheme:
config.color_scheme = "One Dark (Gogh)"

-- and finally, return the configuration to wezterm
return config
