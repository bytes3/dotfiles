-- Pull in the wezterm API
local wezterm = require("wezterm")
local theme = require("theme")

local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

config.window_background_opacity = 0.8
config.kde_window_background_blur = true

config.initial_cols = 130
config.initial_rows = 35

config.font_size = 12
config.font = wezterm.font("operatormono")
config.colors = theme.colors

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- Multiplexing
config.disable_default_key_bindings = true
config.enable_tab_bar = false

config.keys = {
	{ key = "v", mods = "ALT", action = act.PasteFrom("Clipboard") },
}

return config
