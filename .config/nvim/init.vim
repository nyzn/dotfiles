call plug#begin()

" Filebrowsing
Plug 'ryanoasis/vim-devicons'
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

" Other stuff
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-commentary'

" Test
Plug 'vim-test/vim-test'

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
set list
set listchars=tab:»-,trail:·,eol:¬

set clipboard+=unnamedplus

" Save file
nnoremap <leader>w :w<cr>

" jump between buffers
nnoremap <Tab> :bnext<cr>
nnoremap <S-Tab> :bprevious<cr>

nnoremap <leader>bd :Bdelete menu<CR>

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


" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" reload nvim with new init.vim
nnoremap <leader>r :source $MYVIMRC<CR>

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

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

" Test
nmap <silent> <leader>t :TestNearest<CR>

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


let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-pairs',
  \ 'coc-tsserver',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-json',
  \ 'coc-stylelint',
  \ 'coc-css',
  \ 'coc-prisma',
  \ 'coc-java',
  \ 'coc-java-debug'
  \ ]
