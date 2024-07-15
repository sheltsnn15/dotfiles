local wezterm = require 'wezterm'

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.default_domain = 'WSL:WLinux'
config.default_prog = { "wsl.exe", "--distribution", "Pengwin" }
config.set_environment_variables = {
  SHELL = "/bin/bash",
  TERM = "xterm-256color"
}

config.color_scheme = 'One Dark (Gogh)'
config.font = wezterm.font('FiraCode Nerd Font')
config.font_size = 11.0
config.enable_tab_bar = true
config.window_padding = {
  left = 2,
  right = 2,
  top = 2,
  bottom = 2,
}

config.keys = {
  { key = "h",          mods = "CTRL",       action = wezterm.action { ActivatePaneDirection = "Left" } },
  { key = "j",          mods = "CTRL",       action = wezterm.action { ActivatePaneDirection = "Down" } },
  { key = "k",          mods = "CTRL",       action = wezterm.action { ActivatePaneDirection = "Up" } },
  { key = "l",          mods = "CTRL",       action = wezterm.action { ActivatePaneDirection = "Right" } },
  { key = "c",          mods = "CTRL|SHIFT", action = wezterm.action { CopyTo = "Clipboard" } },
  { key = "v",          mods = "CTRL|SHIFT", action = wezterm.action { PasteFrom = "Clipboard" } },
  { key = "t",          mods = "CTRL|SHIFT", action = wezterm.action { SpawnTab = "CurrentPaneDomain" } },
  { key = "w",          mods = "CTRL|SHIFT", action = wezterm.action { CloseCurrentTab = { confirm = true } } },
  { key = "LeftArrow",  mods = "CTRL|SHIFT", action = wezterm.action { ActivateTabRelative = -1 } },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action { ActivateTabRelative = 1 } },
}

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = wezterm.action { CompleteSelection = "PrimarySelection" },
  },
  {
    event = { Down = { streak = 1, button = "Middle" } },
    mods = "NONE",
    action = wezterm.action { PasteFrom = "PrimarySelection" },
  },
}

wezterm.on("update-right-status", function(window, pane)
  local cells = {}
  local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")
  table.insert(cells, date)
  for _, b in ipairs(wezterm.battery_info()) do
    table.insert(cells, string.format("Battery %.0f%%", b.state_of_charge * 100))
  end
  window:set_right_status(wezterm.format(cells))
end)

config.initial_rows = 40
config.initial_cols = 120

return config
