local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Pull files
local keybinds = require("keybinds")

-- 自動読み込み
config.automatically_reload_config = true

-- PowerShellをデフォルトに
config.default_prog = { "pwsh.exe" }

-- 色設定
config.color_scheme = "Kanagawa (Gogh)"

-- ウィンドウ設定
config.window_decorations = "TITLE | RESIZE"
config.window_background_opacity = 0.9
config.initial_cols = 204
config.initial_rows = 48

-- フォントサイズ
config.font_size = 9.0
config.font = wezterm.font("HackGen Console NF")

-- イタリック（斜体）で日本語が小さくなる問題への対策
-- Neovimのコメント等でイタリックが指定された際、HackGenにイタリック体がないため
-- 別のフォントがフォールバックとして選ばれ、文字サイズが崩れるのを防ぎます。
config.font_rules = {
	{
		italic = true,
		font = wezterm.font("HackGen Console NF", { italic = false }),
	},
}

-- 右側ステータス
wezterm.on("update-right-status", function(window, pane)
	local date = wezterm.strftime("%H:%M:%S")
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#DCD7BA" } },
		{ Text = "  " .. date .. "  " },
	}))
end)

-- キー設定
config.leader = { key = ",", mods = "CTRL", timeout_milliseconds = 1500 }
config.keys = keybinds.keys
config.key_tables = keybinds.key_tables

return config
