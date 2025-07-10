" Vim Configuration - Dotf Single Repository Design
" 这个文件是示例配置，实际使用时会被符号链接到 ~/.vimrc

set nocompatible
set number
set ruler
set showmatch
set ignorecase
set smartcase
set incsearch
set hlsearch
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set backspace=indent,eol,start
set history=1000
set wildmenu
set title
set visualbell
set noerrorbells

" 语法高亮
syntax on
filetype plugin indent on
set background=dark
colorscheme default

" 显示空白字符
set list
set listchars=tab:>·,trail:·,extends:>,precedes:<

" 自动换行
set wrap
set linebreak
set nolist

" 搜索高亮
set hlsearch
set incsearch

" 文件编码
set encoding=utf-8
set fileencoding=utf-8

" 备份设置
set nobackup
set noswapfile

" 鼠标支持
set mouse=a

" 状态栏
set laststatus=2
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}

" 映射
map <C-n> :set invnumber<CR>
map <C-h> :nohl<CR>
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
map <C-h> <C-w>h 