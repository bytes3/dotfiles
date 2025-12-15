-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

config.window_background_opacity = 0.8

config.initial_cols = 130
config.initial_rows = 35

config.font_size = 12
config.font = wezterm.font("operatormono")

config.enable_tab_bar = false
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

config.disable_default_key_bindings = true

config.keys = {
	{ key = "k", mods = "ALT", action = act.PasteFrom("Clipboard") },
	{ key = "v", mods = "ALT", action = act.PasteFrom("Clipboard") },
}

-- config.color_scheme = "Apple System Colors"
config.colors = {
	foreground = "#c5c9c5",
	background = "#181616",

	cursor_bg = "#C8C093",
	cursor_fg = "#C8C093",
	cursor_border = "#C8C093",

	selection_fg = "#C8C093",
	selection_bg = "#2D4F67",

	scrollbar_thumb = "#16161D",
	split = "#16161D",

	ansi = {
		"#0D0C0C",
		"#C4746E",
		"#8A9A7B",
		"#C4B28A",
		"#8BA4B0",
		"#A292A3",
		"#8EA4A2",
		"#C8C093",
	},
	brights = {
		"#A6A69C",
		"#E46876",
		"#87A987",
		"#E6C384",
		"#7FB4CA",
		"#938AA9",
		"#7AA89F",
		"#C5C9C5",
	},
}

return config
