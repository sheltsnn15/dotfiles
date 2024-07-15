" BASIC SETUP
set nocompatible              " Use Vim's own defaults instead of emulating vi
syntax enable                 " Enable syntax highlighting
filetype plugin on            " Enable filetype detection and load filetype plugins

" FINDING FILES
set path+=**                  " Search in subdirectories for files
set wildmenu                  " Improve command line completion with a navigable menu

" TAG JUMPING
command! MakeTags !ctags -R . " Custom command to create tags for source code navigation
                              " (ctags needs to be installed separately)

" AUTOCOMPLETE
" The following settings configure different types of autocompletion:
" - ^x^n: Autocomplete from current file
" - ^x^f: Autocomplete filenames
" - ^x^]: Autocomplete tags
" - ^n: Autocomplete from various sources

" FILE BROWSING
" These settings tweak Netrw, Vim's built-in file explorer:
let g:netrw_banner=0          " Disable the banner at the top of Netrw
let g:netrw_browse_split=4    " Open files in the previous window
let g:netrw_altv=1            " Open new splits to the right
let g:netrw_liststyle=3       " Use a tree-style listing
" The next two lines configure hiding files in Netrw:
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

" SNIPPETS
" This is a simple snippet example. It reads an HTML template and moves the cursor:
nnoremap ,html :-1read $HOME/.vim/.skeleton.html<CR>3jwf>a

" BUILD INTEGRATION
" These settings are for integrating a build system (RSpec in this case):
set makeprg=bundle\ exec\ rspec\ -f\ QuickfixFormatter " Set the make program to RSpec
" The following commands are used to navigate RSpec errors:
" - :make: Run the make program
" - :cl: List errors
" - :cc#: Jump to a specific error
" - :cn and :cp: Navigate through errors

set number            " Show line numbers
set relativenumber    " Show relative line numbers
set showcmd           " Show command in bottom bar
set cursorline        " Highlight current line
set wrap              " Enable line wrap
set scrolloff=10      " Keep 10 lines visible when scrolling
set ignorecase        " Case insensitive searching
set smartcase         " Case sensitive if uppercase is used
set incsearch         " Show search matches as you type
set hlsearch          " Highlight search results
set autoindent        " Copy indent from current line on new line
set smartindent       " Smart autoindenting for new lines
set expandtab         " Convert tabs to spaces
set tabstop=4         " Set tab width to 4 spaces
set shiftwidth=4      " Set indent width to 4 spaces
set softtabstop=4     " Set soft tab width to 4 spaces
set backspace=indent,eol,start  " Make backspace key more powerful

nnoremap <C-j> :bnext<CR>       " Ctrl+j to go to next buffer
nnoremap <C-k> :bprevious<CR>   " Ctrl+k to go to previous buffer

nnoremap <C-h> <C-w>h           " Ctrl+h to move left in splits
nnoremap <C-j> <C-w>j           " Ctrl+j to move down in splits
nnoremap <C-k> <C-w>k           " Ctrl+k to move up in splits
nnoremap <C-l> <C-w>l           " Ctrl+l to move right in splits

set undofile          " Save undos after file closes
set undodir=~/Appdata/Local/nvim/undodir  " Set directory for undo files

set background=dark   " Set background to dark (use 'light' for light background)
hi Normal guibg=NONE ctermbg=NONE

set laststatus=2      " Always display the status line

set noswapfile        " Disable swap file creation



" Setting the Leader Key
let mapleader = " "

" File explorer
nnoremap <leader>pv :Ex<CR>

" Move lines up and down in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Join lines without moving cursor
nnoremap J mzJ`z

" Center screen on navigation
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv

" Clipboard integration
vnoremap <leader>y :w !clip<CR><CR>
nnoremap <leader>Y :.w !clip<CR><CR>
nnoremap <leader>d :w !clip<CR><CR>

" Cancel operation in insert mode
inoremap <C-c> <Esc>

" Disable Q in normal mode
nnoremap Q <nop>

" Quickfix and location list navigation
nnoremap <C-k> :cnext<CR>zz
nnoremap <C-j> :cprev<CR>zz
nnoremap <leader>k :lnext<CR>zz
nnoremap <leader>j :lprev<CR>zz

" Search and replace helper
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" Change file permissions
nnoremap <leader>x :!chmod +x %<CR>

" Edit specific configuration file
nnoremap <leader>vpp :e ~/.vimrc<CR>
