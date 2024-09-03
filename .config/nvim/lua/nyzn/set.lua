vim.opt.encoding="utf-8"

vim.opt.termguicolors = true

-- vim.o.background = "dark" -- or "light" for light mode
-- vim.cmd([[colorscheme gruvbox]])
-- vim.cmd.colorscheme 'melange'

vim.g.neoformat_try_node_exe = 1

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.ignorecase = true

vim.opt.wrap = false

vim.opt.swapfile = false

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50
vim.opt.statusline = "%t"

vim.opt.guifont = "Hack"

-- backspace feature
-- https://vi.stackexchange.com/questions/2162/why-doesnt-the-backspace-key-work-in-insert-mode
vim.opt.backspace = {'indent', 'eol', 'start'}

vim.api.nvim_command('set hlsearch')
-- vim.opt.nofoldenable="false"
-- vim.opt.foldmethod = 'expr'
-- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

-- set foldmethod=expr
-- set foldexpr=nvim_treesitter#foldexpr()
-- set nofoldenable = false 
