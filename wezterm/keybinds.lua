local wezterm = require("wezterm")
local act = wezterm.action

return {
	keys = {
		-- タブ

		-- タブ追加
		{ key = "t", mods = "CTRL", action = act({ SpawnTab = "CurrentPaneDomain" }) },
		-- タブを閉じる
		{ key = "w", mods = "CTRL", action = act({ CloseCurrentTab = { confirm = false } }) },
		-- タブを移動
		{
			key = "PageUp",
			mods = "CTRL|SHIFT",
			action = wezterm.action.MoveTabRelative(-1),
		},
		{
			key = "PageDown",
			mods = "CTRL|SHIFT",
			action = wezterm.action.MoveTabRelative(1),
		},

		-- ペイン

		-- 水平分割
		{ key = "+", mods = "ALT|SHIFT", action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
		-- 垂直分割
		{ key = ">", mods = "ALT|SHIFT", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
		-- ペインを閉じる
		{ key = "=", mods = "ALT|SHIFT", action = act({ CloseCurrentPane = { confirm = false } }) },
		-- ペイン間移動
		{ key = "phys:LeftArrow", mods = "ALT", action = act({ ActivatePaneDirection = "Left" }) },
		{ key = "phys:RightArrow", mods = "ALT", action = act({ ActivatePaneDirection = "Right" }) },
		{ key = "phys:UpArrow", mods = "ALT", action = act({ ActivatePaneDirection = "Up" }) },
		{ key = "phys:DownArrow", mods = "ALT", action = act({ ActivatePaneDirection = "Down" }) },
		-- ペインサイズ調整
		{ key = "phys:LeftArrow", mods = "ALT|SHIFT", action = act({ AdjustPaneSize = { "Left", 1 } }) },
		{ key = "phys:RightArrow", mods = "ALT|SHIFT", action = act({ AdjustPaneSize = { "Right", 1 } }) },
		{ key = "phys:UpArrow", mods = "ALT|SHIFT", action = act({ AdjustPaneSize = { "Up", 1 } }) },
		{ key = "phys:DownArrow", mods = "ALT|SHIFT", action = act({ AdjustPaneSize = { "Down", 1 } }) },
		
		-- コピーモードに入る
		{ key = "c", mods = "LEADER", action = act.ActivateCopyMode },
		{ key = "x", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
	},

	-- WezTerm はデフォルトで強力なコピーモード（Vimライクな移動・選択・ヤンク）を持っています。
	-- copy_mode = {} のように空のテーブルを指定するとデフォルトが上書きされて何もできなくなるため、
	-- 削除してデフォルトを活かします。
	key_tables = {},
}
