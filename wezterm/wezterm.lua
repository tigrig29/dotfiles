local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Pull files
local keybinds = require("keybinds")

-- 自動読み込み
config.automatically_reload_config = true

-- PowerShellをデフォルトに
config.default_prog = { 'pwsh.exe' }

-- 色設定
config.color_scheme = 'Kanagawa (Gogh)'

-- ウィンドウ設定
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.initial_cols = 120
config.initial_rows = 30

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
