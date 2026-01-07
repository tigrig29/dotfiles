--------------
-- 基本設定 --
--------------

-- 文字コード
vim.scriptencoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- 見た目系
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a' --マウス操作を有効化
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.scrolloff = 3

-- インデント系
vim.opt.expandtab = true
vim.opt.breakindent = true
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.wrap = true
vim.opt.cindent = true

-- move the cursor to the previous/next line across the first/last character
vim.opt.whichwrap = 'b,s,h,l,<,>,[,],~'

-- エディタ挙動系
-- vim.opt.backspace = 'indent,eol,start' -- デフォルトなので無効化

-- その他
vim.opt.helplang = 'ja', 'en'
