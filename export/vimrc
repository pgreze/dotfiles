""" TRASH
" python autocomplete
"let g:pydiction_location = '~/.vim/after/ftplugin/complete-dict'
"imap <c-e> <c-x><c-o>
"inoremap <c-x><c-o> <c-space>

" pour syntax/python.vim
"let python_highlight_all = 0

" insert 2010/12/02
" from http://theclimber.fritalk.com/post/2009/02/11/Ma-configuration-Vi-/-Vim-/-gVim

""
"" GENERAL
""

set nocompatible               " breaks compatibility with original vi
set encoding=utf-8
" selected line
"set cursorline
highlight CursorLine guibg=#001000

" edit
set expandtab
set tabstop=4                  " number of spaces in a tab
set shiftwidth=4               " as above
set autoindent                 " text indenting
"set smartindent                " as above
"set softtabstop=4              " as above

" color
syntax on                      " syntaxic coloration

" allow ftplugins
filetype plugin indent on
" pour l'autocompletion avec python: ctrl+x + ctrl+o


""
"" FROM https://github.com/hdima/vim-scripts/blob/master/vimrc
""

" GUI options
if has("gui_running")
    " Make gvim looks more like vim
    set guioptions+=acghi
    set guioptions-=e
    set guioptions-=mrLtT

    set guifont=DejaVu\ Sans\ Mono\ 9

    " Disable pasting text on mouse middle button click
    map <MiddleMouse> <Nop>
    imap <MiddleMouse> <Nop>
    map <2-MiddleMouse> <Nop>
    imap <2-MiddleMouse> <Nop>
    map <3-MiddleMouse> <Nop>
    imap <3-MiddleMouse> <Nop>
    map <4-MiddleMouse> <Nop>
    imap <4-MiddleMouse> <Nop>

    set columns=169
    set lines=999
endif

" Highlight and autocomplete search
set hlsearch
set incsearch

" preserve column where cursor is positioned during motion commands
set nostartofline

" Don't make chaos on my display
set nowrap
set backspace=indent,eol,start
set nojoinspaces

" Some information is always good...
set showfulltag
set showcmd
set wildmode=list:longest
set laststatus=2
set statusline=%f%=\ %Y\ %c%V,%l/%L\ %P\ [%M%n%W]:%{tabpagenr()}/%{tabpagenr('$')}
set showtabline=1
set showmode

" ...but not too much
set report=0
set shortmess+=asWAI

set helpheight=12
set winminheight=0

set sidescroll=15

" Nice :list and :set list
set listchars=tab:>-,trail:.,extends:+,eol:$,precedes:+

set fillchars="vert: ,fold: "

" Fold options
set foldmethod=syntax
set foldnestmax=1
set nofoldenable

" Diff options
set diffopt=filler,context:3

set virtualedit=block

" Always save some info for next time
set history=100
set viminfo='100,h,%
set sessionoptions+=winpos
" Don't save options to session file - it's possibly buggy
set sessionoptions-=options

" Pretty select with mouse and shifted special keys
behave mswin
" ...but not reset selection with not-shifted special keys
set keymodel-=stopsel
set selection=inclusive

"set number
"set numberwidth=4

set wildignore=*.swp,*.swo,*.beam,*.pyc,*.*~

" Turn off backup files
set nobackup
" Turn off swap files
set updatecount=0

" It's not an MS Word clone
set secure

" Color scheme
color peachpuff

" Highlight syntax
syntax enable

" Indent commands
com SpaceIndent :set tabstop=4| set shiftwidth=4| set expandtab
com TabIndent :set tabstop=8| set shiftwidth=8| set noexpandtab
" 4 space indent by default
SpaceIndent

" GUI options
if has("gui_running")
    vsplit
else
    set bg=dark
endif

" template for new python file
autocmd BufNewFile *.py,*.pyw 0read ~/.vim/templates/python.txt

" add pythogen extension
call pathogen#infect() 

