" Enable syntax highlighting
syntax on

" Show line numbers
set number
set relativenumber

" Enable mouse support
set mouse=a

" Set tabs to have 4 spaces
set tabstop=4
set shiftwidth=4
set expandtab

" Enable line wrapping
set wrap

" Show matching brackets
set showmatch

" Enable incremental search
set incsearch

" Highlight search results
set hlsearch

" Make backspace key more powerful
set backspace=indent,eol,start

" Enable file type detection
filetype plugin indent on

" Set default encoding to UTF-8
set encoding=utf-8

" Use spaces instead of tabs
set expandtab

" Improve command line completion
set wildmenu

" Remember last position in file
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" Set a nicer status line
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%04l,%04v]\ [LEN=%L]

" Enable line highlighting
set cursorline

" Set the colorscheme (if you have one installed)
" colorscheme your_colorscheme_name
