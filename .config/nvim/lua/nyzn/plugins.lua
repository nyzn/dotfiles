-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
-- Packer can manage itself
use 'wbthomason/packer.nvim'

-- File Browsing
use 'junegunn/fzf'
use 'junegunn/fzf.vim'
use 'mhinz/vim-grepper'
use 'francoiscabrol/ranger.vim'
use 'rbgrouleff/bclose.vim'
use 'nvim-lua/plenary.nvim'
use 'nvim-lua/popup.nvim'
use {
	'nvim-telescope/telescope.nvim', tag = '0.1.5',
	-- or                            , branch = '0.1.x',
	requires = { {'nvim-lua/plenary.nvim'} }
}
use 'nvim-telescope/telescope-fzy-native.nvim'
use("theprimeagen/harpoon")

-- use 'nvim-tree/nvim-web-devicons'
use {
  'nvim-tree/nvim-tree.lua',
  requires = {
    'nvim-tree/nvim-web-devicons', -- optional
    -- 'ryanoasis/vim-devicons'
  },
  config = function()
    require("nvim-tree").setup {}
  end
}
-- use ('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
use {'nvim-treesitter/nvim-treesitter', 
run = ':TSUpdate'
-- Note: :TSUpdate will cause Packer to fail upon the first installation. It will run correctly when updating. To avoid this, call nvim-treesitter.install.update() directly:
  -- run = function()
  --   local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
  --   ts_update()
  -- end, 
}

-- This plugin is deprecated since the functionality is included in Neovim: Use
-- :Inspect to show the highlight groups under the cursor
-- :InspectTree to show the parsed syntax tree ("TSPlayground")
-- :EditQuery to open the Live Query Editor (Nvim 0.10+)
-- use ('nvim-treesitter/playground' )

-- TypeScript
-- use 'HerringtonDarkholme/yats.vim'
-- use 'evanleck/vim-svelte'

-- Color themes
use { "ellisonleao/gruvbox.nvim", as = 'gruvbox' }
use 'savq/melange-nvim'

-- Git
use 'tpope/vim-fugitive'
use 'mhinz/vim-signify'

-- Editing
use 'kshenoy/vim-signature'
use 'junegunn/limelight.vim'
use 'Asheq/close-buffers.vim'
use 'tpope/vim-surround'
use 'mustache/vim-mustache-handlebars'

use {"neoclide/coc.nvim", branch = 'release'}

-- lsp zero comment for CoC
-- -- use 'neovim/nvim-lspconfig'
-- use {
-- 	'VonHeikemen/lsp-zero.nvim',
-- 	branch = 'v1.x',
-- 	requires = {
-- 		-- LSP Support
-- 		{'neovim/nvim-lspconfig'},
-- 		{'williamboman/mason.nvim'},
-- 		{'williamboman/mason-lspconfig.nvim'},

-- 		-- Autocompletion
-- 		{'hrsh7th/nvim-cmp'},
-- 		{'hrsh7th/cmp-buffer'},
-- 		{'hrsh7th/cmp-path'},
-- 		{'saadparwaiz1/cmp_luasnip'},
-- 		{'hrsh7th/cmp-nvim-lsp'},
-- 		{'hrsh7th/cmp-nvim-lua'},

-- 		-- Snippets
-- 		{'L3MON4D3/LuaSnip'},
-- 		{'rafamadriz/friendly-snippets'},
-- 	}
-- }

-- Other stuff
use 'mhinz/vim-startify'
use 'tpope/vim-commentary'

-- Tool for web development
use { 'mattn/emmet-vim' ,
  setup = function() -- load stuff before the plugin is loaded
    vim.g.user_emmet_leader_key = ','
    vim.g.user_emmet_mode = 'a'
  end
}

-- Test
use 'vim-test/vim-test'
end)
