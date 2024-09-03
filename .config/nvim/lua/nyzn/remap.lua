vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })

-- save file 
vim.keymap.set("n", "<leader>w", vim.cmd.w)

-- vmap <leader>f  <Plug>(coc-format-selected)
-- nmap <leader>f  <Plug>(coc-format-selected)

vim.keymap.set("n", "<leader>f", "<Plug>(coc-format-selected)")
vim.keymap.set("v", "<leader>f", "<Plug>(coc-format-selected)")

-- buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>")
vim.keymap.set("n", "<leader>bd" , ":Bdelete menu<CR>")
vim.keymap.set("n", "<leader>bh" , ":Bdelete hidden<CR>")

-- Coc Restart
vim.keymap.set("n", "<leader>br" , ":CoCRestart<CR>")

-- move highlighted code
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")


-- cursor stay in place by input
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- save current buffer by pasting 
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
-- yank into the system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set("n", "Q", "<nop>")

-- reload nvim
vim.keymap.set("n", "<leader>sv", ":source $MYVIMRC<CR>")

-- disable netrw at the very start of your init.lua (strongly advised)
-- for nvim-tree
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

-- vim.opt.foldmethod     = 'expr'
-- vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
---WORKAROUND
-- vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
--   group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
--   callback = function()
--     vim.opt.foldmethod     = 'expr'
--     vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
--   end
-- })
---ENDWORKAROUND
