return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        transparent = true, -- 透明背景（WezTerm と合わせるなら推奨）
        theme = "wave",      -- "wave" | "dragon" | "lotus"
      })

      vim.cmd("colorscheme kanagawa")
    end,
  },
}

