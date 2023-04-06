call plug#begin()

" Filebrowsing
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-grepper'
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

Plug 'preservim/nerdtree'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update

" TypeScript
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'HerringtonDarkholme/yats.vim'
Plug 'evanleck/vim-svelte'

" Color themes
Plug 'gruvbox-community/gruvbox'

" Git
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'

" Editing
Plug 'kshenoy/vim-signature'
Plug 'junegunn/limelight.vim'
Plug 'Asheq/close-buffers.vim'
Plug 'tpope/vim-surround'
Plug 'mustache/vim-mustache-handlebars'
Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'MunifTanjim/prettier.nvim'

" Other stuff
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-commentary'
Plug 'ryanoasis/vim-devicons'

" Tool for web development
Plug 'mattn/emmet-vim'

" Test
Plug 'vim-test/vim-test'

Plug 'ryanoasis/vim-devicons'
call plug#end()

colorscheme gruvbox

" Enable real colors in tmux
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Set leader
" let mapleader = ","
nnoremap <SPACE> <Nop>
let mapleader = "\<Space>"

" Some global configuration stuff
set shell=zsh
set nobackup
set nowritebackup
set noswapfile
set backspace=2   " Backspace deletes like most programs in insert mode
set number
set relativenumber
set cursorline
set list
set listchars=tab:▸\ ,trail:\· " ,space:·
set laststatus=2
set updatetime=250
set tabstop=2
set shiftwidth=2
set expandtab
set nocompatible
set hidden
set hlsearch
set autoread
set scrolloff=8
set smartindent
set cindent
set shortmess+=c
set signcolumn=yes
set mouse=a " enable mouse
set autoindent

filetype plugin on

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Disable case sensitive search
set ignorecase

" Show invisivles
" set list
" set listchars=tab:»-,trail:·,eol:¬

set clipboard+=unnamedplus

set guifont=hack
set encoding=UTF-8 


set showcmd
" Mac stuff
" set fileformats=mac


" Save file
nnoremap <leader>w :w<cr>

" jump between buffers
nnoremap <Tab> :bnext<cr>
nnoremap <S-Tab> :bprevious<cr>

nnoremap <leader>bd :Bdelete menu<CR>
nnoremap <leader>bh :Bdelete hidden<CR>

" Use Tab to navigate in the completion list
" inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction


inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
inoremap <silent><expr> <C-x><C-z> coc#pum#visible() ? coc#pum#stop() : "\<C-x>\<C-z>"
" remap for complete to use tab and <cr>
inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#pum#next(1):
        \ <SID>check_back_space() ? "\<Tab>" :
        \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <c-space> coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction


" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

inoremap <silent><expr> <cr> coc#pum#visible() && coc#pum#info()['index'] != -1 ? coc#pum#confirm() :
        \ "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" reload nvim with new init.vim
nnoremap <leader>r :source $MYVIMRC<CR>

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

command! CodeAction :call CocActionAsync('codeAction', '')

nnoremap <leader><CR> :CodeAction<CR>
nnoremap <M-CR> :CocAction<CR>

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nnoremap <leader>ff <cmd>Telescope find_files hidden=true<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files() hidden=true<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

au FileType javascript setlocal formatprg=prettier
au FileType javascript.jsx setlocal formatprg=prettier
au FileType typescript setlocal formatprg=prettier\ --parser\ typescript
au FileType html setlocal formatprg=js-beautify\ --type\ html
au FileType scss setlocal formatprg=prettier\ --parser\ css
au FileType css setlocal formatprg=prettier\ --parser\ css

" NerdTree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
nmap <Leader>R :NERDTreeFocus<cr>R<c-w><c-p>

"""" COC
" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Remap for rename current word
omap <leader>rn <Plug>(coc-rename)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Jump to diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

function! LightlineCocCoverageStatus() abort
  let status = get(g:, 'coc_coverage_lines_pct', '')
  if empty(status)
    return ''
  endif

  return '☂ ' . status . '% Lines Covered'
endfunction

let g:lightline = {
  \ 'active': {
  \   'left': [
  \     [ 'mode', 'paste' ],
  \     [ 'readonly', 'filename' ]
  \   ],
  \   'right':[
  \     [ 'coccoverage', 'lineinfo', 'percent', 'cocstatus' ],
  \     [ 'cocapollo' ]
  \   ],
  \ },
  \ 'component_function': {
  \   'coccoverage': 'LightlineCocCoverageStatus'
  \ }
\ }

" Test
nmap <silent> <leader>t :TestNearest<CR>

" Emmet
let g:user_emmet_mode='a'    "enable all function in all mode.
 " emmet trigger key"
let g:user_emmet_leader_key=','

" LSP
  " require("nvim-lsp-installer").setup({
  "   automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
  "   ui = {
  "       icons = {
  "           server_installed = "✓",
  "           server_pending = "➜",
  "           server_uninstalled = "✗"
  "       }
  "   }
" })

let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-pairs',
  \ 'coc-tsserver',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-json',
  \ 'coc-stylelint',
  \ 'coc-css',
  \ 'coc-html',
  \ 'coc-prisma',
  \ 'coc-java',
  \ 'coc-java-debug',
  \ 'coc-angular',
  \ 'coc-actions',
  \ 'coc-cssmodules',
  \ 'coc-html-css-support'
  \ ]
