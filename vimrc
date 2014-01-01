scriptencoding utf-8

" 判断当前环境 "{{{
" 判断操作系统
if (has("win32") || has("win64") || has("win32unix"))
    let s:is_windows = 1
else
    let s:is_windows = 0
endif

" 判断是终端还是gvim
if has("gui_running")
    let g:isGUI = 1
else
    let g:isGUI = 0
endif
" "}}}

" General "{{{
set nocompatible " disable vi compatibility.
set history=256 " Number of things to remember in history.
set autowrite " Writes on make/shell commands
set autoread     " 当文件在外部被修改时，自动重新读取
"set timeoutlen=250 " Time to wait after ESC (default causes an annoying delay)
set clipboard+=unnamed " Yanks go on clipboard instead.
set pastetoggle=<F10> " toggle between paste and normal: for 'safer' pasting from keyboard
set helplang=cn
"set viminfo+=! " Save and restore global variables

set fileencodings=ucs-bom,utf-8,cp936,taiwan,japan,korea,latin1

" Modeline
set modeline
set modelines=5 " default numbers of lines to read for modeline instructions

" Backup
set nowritebackup
set nobackup
" 设置swap-file保存路径
if (s:is_windows)
    let &directory='$TEMP//,$TMP//,' . &directory
    let &backupdir='$TEMP//,$TMP//,' . &backupdir
else
    let &backupdir='$HOME/bak//,' . &backupdir
endif
if (s:is_windows)
    set shellpipe=\|\ tee
    set shellslash
endif

" Buffers
set hidden " The current buffer can be put to the background without writing to disk

" Match and search
set hlsearch " highlight search
set ignorecase " Do case in sensitive matching with
set smartcase " be sensitive when there's a capital letter
set incsearch "
set diffopt+=iwhite
" "}}}

" Formatting "{{{
"set fo+=o " Automatically insert the current comment leader after hitting 'o' or 'O' in Normal mode.
"set fo-=r " Do not automatically insert a comment leader after an enter
set fo-=t " Do no auto-wrap text using textwidth (does not apply to comments)
" 打开断行模块对亚洲语言支持
set fo+=m " 允许在两个汉字之间断行， 即使汉字之间没有出现空格
set fo+=B " 将两行合并为一行的时候， 汉字与汉字之间不要补空格

set nowrap
set textwidth=0 " Don't wrap lines by default
set wildmode=list:longest,full  " 先列出所有候选项，补全候选项的共同前缀，再按wildchar就出现菜单来选择候选项
set wildmenu    " 用一行菜单显示候选项。<C-P>/<C-N>或<Left>/<Right>为选择上一个/下一个，<Up>返回父目录，<Down>进入子目录
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store

set backspace=indent,eol,start " more powerful backspacing
set whichwrap+=b,s,<,>,h,l " 退格键和方向键可以换行

set tabstop=4 " Set the default tabstop
set softtabstop=4
set shiftwidth=4 " Set the default shift width for indents
set shiftround   " <</>>等缩进位置不是+/-4空格，而是对齐到下个'shiftwidth'位置
set expandtab " Make tabs into spaces (set by tabstop)
set smarttab " Smarter tab levels

set autoindent
set cindent
set cinoptions=:s,ps,ts,cs
set cinwords=if,else,while,do,for,switch,case

syntax on " enable syntax
filetype plugin on " 使用filetype插件
filetype plugin indent on " Automatically detect file types.
" "}}}

" Visual "{{{
set number " Line numbers on
set showmatch " Show matching brackets.
set cursorline " 高亮当前行
set matchtime=5 " Bracket blinking.
set novisualbell " No blinking
set noerrorbells " No noise.
set laststatus=2 " Always show status line.
set vb t_vb= " disable any beeps or flashes on error
set ruler " Show ruler
set showcmd " Display an incomplete command in the lower right corner of the Vim window
set cmdheight=1
set winminheight=0  " 最小化窗口的高度为0
"set shortmess=atI " Shortens messages

" 状态栏里显示文字编码和换行符等信息
" 获取当前路径，将$HOME转化为~
function! CurDir()
    let curdir = substitute(getcwd(), "^".$HOME, "~", "")
    return curdir
endfunction

set nolist " Don't display unprintable characters
"let &listchars="tab:\u2192 ,eol:\u00b6,trail:\u00b7,extends:\u00bb,precedes:\u00ab"
"let &listchars="tab:\u21e5 ,eol:\u00b6,trail:\u00b7,extends:\u00bb,precedes:\u00ab"
"let &listchars="tab:\u21e5 ,trail:\u00b7,extends:\u00bb,precedes:\u00ab"
"let &listchars="tab:\u21e2\u21e5,trail:\u00b7,extends:\u00bb,precedes:\u00ab"
let &listchars="tab:|-,trail:\u00b7,extends:\u00bb,precedes:\u00ab"
"set listchars=tab:>-,eol:<,trail:-,nbsp:%,extends:>,precedes:<

set foldenable " Turn on folding
set foldmethod=marker " Fold on the marker
set foldlevel=100 " Don't autofold anything (but I can still fold manually)
set foldopen=block,hor,mark,percent,quickfix,search,tag " what movements open folds
"set foldlevelstart=1 " Auto fold level 1 or more

"set mouse-=a " Disable mouse
set mouse+=a
set mousehide " Hide mouse after chars typed

if &ttymouse == "xterm"
    set ttymouse=xterm2
endif

" 指定在选择文本时， 光标所在位置也属于被选中的范围。 如果指定 selection=exclusive 的话， 可能会出现某些文本无法被选中的情况
set selection=inclusive

set splitbelow
set splitright

" 在listchars中用到可能是双倍宽度的字符时，不能设置ambiwidth=double
"" 如果 Vim 的语言是中文（zh）、日文（ja）或韩文（ko）的话，将模糊宽度的 Unicode 字符的宽度（ambiwidth）设为双宽度（double）
"if has('multi_byte') && v:version > 601
"  if v:lang =~? '^\(zh\)\|\(ja\)\|\(ko\)'
"    set ambiwidth=double
"  endif
"endif

" gui相关设置
if (g:isGUI)
    set guioptions-=m " 不显示菜单
    set guioptions-=T " 不显示工具栏
    set guioptions-=b " 不显示水平滚动条
    set guioptions-=r " 不显示垂直滚动条
endif

" 在不同IME状态下使用不同的光标颜色。只在Windows下有效
if has('multi_byte_ime')
    highlight Cursor guifg=NONE guibg=Green
    highlight CursorIM guifg=NONE guibg=Purple
endif

let &termencoding = &encoding
if (s:is_windows)
    "set encoding=ucs-4
    set encoding=utf-8
    "set guifont=Bitstream_Vera_Sans_Mono\ 12
    "set guifont=Courier_New:h12
    set guifont=Powerline_Consolas:h12,Consolas:h12,Courier_New:h12
    set guifontwide=NSimsun:h12
    "解决菜单乱码
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
    "解决consle输出乱码
    "language messages zh_CN.utf-8
    language messages en_US
else
    set encoding=utf-8
    set guifont=DejaVu\ Sans\ Mono\ 14
    set guifontwide=WenQuanYi\ Bitmap\ Song\ 14
endif

" "}}}

" Coding "{{{
set tags+=./tags;/ " walk directory tree upto / looking for tags

set completeopt=menuone,menu,longest,preview
set completeopt-=longest
set showfulltag

" Doxygen的出错信息
set errorformat+=Generating\ code\ for\ file\ %f:%l:%m
set errorformat+=Generating\ docs\ for\ compound\ %f:%l:%m
set errorformat+=Generating\ docs\ Error:\ %f:%l:%m
set errorformat+=Generating\ annotated\ compound\ ind%f:%l:%m
set errorformat+=Generating\ docs\ %f:%l:%m
set errorformat+=Generating\ docs\ for\ page\ %\\w%\\+...%f:%l:%m
set errorformat+=Generating\ Error:\ %f:%l:\ %m
set errorformat+=Error:\ %f:%l:\ %m
set errorformat^=Parsing\ file\ %f:%l:%m

" Boost.Assert: common-test_stream_reader: include/common/stream_reader.h:306:...
set errorformat^=%[a-zA-Z0-9_-]%\\+:\ %f:%l:%m

" 忽略2012-01-18 13:14:15之类的日志行
set errorformat^=%+G20%\[0-9]%\[0-9]-%\[0-9]%\[0-9]-%\[0-9]%\[0-9]\ %\[0-9]%\[0-9]:%\[0-9]%\[0-9]:%\[0-9]%\[0-9]%m

" xgettext出错信息
set errorformat+=xgettext:\ %m\ at\ %f:%l.

" Highlight space errors in C/C++ source files (Vim tip #935)
let c_space_errors=1
let java_space_errors=1
" "}}}

" Helper Functions "{{{
" Coding Helper Functions "{{{
function! RemoveTrailingSpace()
    if $VIM_HATE_SPACE_ERRORS != '0' &&
          \(&filetype == 'c' || &filetype == 'cpp' || &filetype == 'vim')
        normal m`
        silent! :%s/\s\+$//e
        normal ``
    endif
endfunction

function! MyAsciidocFoldLevel(lnum)
    let lt = getline(a:lnum)
    let fh = matchend(lt, '\V\^\(=\+\)\ze\s\+\S')
    if fh != -1
        return '>'.fh
    endif
    return '='
endfunction

" "}}}

" Encoding Helper Utilities " {{{
function! ForceFileEncoding(encoding)
    if a:encoding != '' && &fileencoding != a:encoding
        exec 'e! ++enc=' . a:encoding
    endif
endfunction

function! SetFileEncodings(encodings)
    let b:my_fileencodings_bak=&fileencodings
    let &fileencodings=a:encodings
endfunction

function! RestoreFileEncodings()
    let &fileencodings=b:my_fileencodings_bak
    unlet b:my_fileencodings_bak
endfunction

function! CheckFileEncoding()
    if &modified && &fileencoding != ''
        exec 'e! ++enc=' . &fileencoding
    endif
endfunction
" "}}}

" "}}}

" Command and Auto commands " {{{
" Sudo write
comm! W exec 'w !sudo tee % > /dev/null' | e!

"Auto commands

if (s:is_windows)
  au GUIEnter * simalt ~x " 启动时自动全屏
endif

au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal g'\"" | endif " restore position in file

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif

" Filetype detection " {{{
au BufRead,BufNewFile {Gemfile,Rakefile,Capfile,*.rake,config.ru} setf ruby
au BufRead,BufNewFile {*.md,*.mkd,*.markdown} setf markdown
au BufRead,BufNewFile {COMMIT_EDITMSG}  setf gitcommit
au BufRead,BufNewFile TDM*C,TDM*H       setf c
au BufRead,BufNewFile *.dox             setf cpp    " Doxygen
au BufRead,BufNewFile *.cshtml          setf cshtml

"" Remove trailing spaces for C/C++ and Vim files
au BufWritePre *                  call RemoveTrailingSpace()

au BufRead,BufNewFile todo.txt,done.txt setf todo
au BufRead,BufNewFile *.mm              setf xml
au BufRead,BufNewFile *.proto           setf proto
au BufRead,BufNewFile Jamfile*,Jamroot* setf jam
au BufRead,BufNewFile pending.data,completed.data setf task
au BufRead,BufNewFile *.ipp             setf cpp
" "}}}

" Filetype related autosettings " {{{
au FileType jam   set makeprg=b2

au FileType diff  setlocal shiftwidth=4 tabstop=4
au FileType html  setlocal autoindent indentexpr= shiftwidth=2 tabstop=2
au FileType changelog setlocal textwidth=76
" 把-等符号也作为xml文件的有效关键字，可以用Ctrl-N补全带-等字符的属性名
au FileType {xml,xslt} setlocal iskeyword=@,-,\:,48-57,_,128-167,224-235
au FileType xml        exe 'setlocal equalprg=xmllint\ --format\ --recover\ -'

au FileType qf setlocal wrap linebreak
au FileType vim nnoremap <silent> <buffer> K :<C-U>help <C-R><C-W><CR>
au FileType man setlocal foldmethod=indent foldnestmax=2 foldenable nomodifiable nonumber shiftwidth=3 foldlevel=2
au FileType cs setlocal wrap

" 如果系统中能找到jing（RELAX NG验证工具）
if executable("jing")
    function! s:jing_settings(filetype)
        if a:filetype == "rnc"
            " 如果存在与rnc文件同名的xml文件，把makeprg设为jing，以rnc文件来验证相应的xml文件
            if filereadable(expand("%:r") . ".xml")
                setlocal makeprg=jing\ %\ %:r.xml
            endif
        else
            " 如果存在与xml文件同名的rnc文件，把makeprg设为jing，以相应的rnc文件来验证xml文件
            if filereadable(expand("%:r") . ".rnc")
                setlocal makeprg=jing\ %:r.rnc\ %
            endif
        endif
    endfunction
    augroup jing
        au FileType xml call s:jing_settings("xml")
        au FileType rnc call s:jing_settings("rnc")
    augroup END
endif
" "}}}

" 根据不同的文件类型设定<F3>时应该查找的文件 "{{{
au FileType *             let b:vimgrep_files=expand("%:e") == "" ? "**/*" : "**/*." . expand("%:e")
au FileType c,cpp         let b:vimgrep_files="**/*.cpp **/*.cxx **/*.c **/*.h **/*.hpp **/*.ipp"
au FileType php           let b:vimgrep_files="**/*.php **/*.htm **/*.html"
au FileType cs            let b:vimgrep_files="**/*.cs"
au FileType vim           let b:vimgrep_files="**/*.vim"
au FileType javascript    let b:vimgrep_files="**/*.js **/*.htm **/*.html"
au FileType python        let b:vimgrep_files="**/*.py"
au FileType xml           let b:vimgrep_files="**/*.xml"
" "}}}


" 自动打开quickfix窗口 "{{{
" Automatically open, but do not go to (if there are errors) the quickfix /
" location list window, or close it when is has become empty.
"
" Note: Must allow nesting of autocmds to enable any customizations for quickfix
" buffers.
" Note: Normally, :cwindow jumps to the quickfix window if the command opens it
" (but not if it's already open). However, as part of the autocmd, this doesn't
" seem to happen.
autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow
" "}}}

" python autocommands "{{{
" 设定python的makeprg
au FileType python setlocal makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
"au FileType python set errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
au FileType python setlocal errorformat=%[%^(]%\\+('%m'\\,\ ('%f'\\,\ %l\\,\ %v\\,%.%#
au FileType python setlocal smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
" "}}}

" Text file encoding autodetection "{{{
  au BufReadPre  *.gb               call SetFileEncodings('gbk')
  au BufReadPre  *.big5             call SetFileEncodings('big5')
  au BufReadPre  *.nfo              call SetFileEncodings('cp437')
  au BufReadPre  *.php              call SetFileEncodings('utf-8')
  au BufReadPre  *.lua              call SetFileEncodings('utf-8')
  au BufReadPost *.gb,*.big5,*.nfo,*.php,*.lua  call RestoreFileEncodings()

  au BufWinEnter *.txt              call CheckFileEncoding()

  " 强制用UTF-8打开vim文件
  au BufReadPost  .vimrc,*.vim nested     call ForceFileEncoding('utf-8')

  au FileType task call ForceFileEncoding('utf-8')
" "}}}

" " }}}

" Key mappings " {{{

" 使用Kitty后，不再需要映射Alt键
" if !s:is_windows && !g:isGUI
"     " 修改对Alt/Meta键的映射
"     for i in range(33, 126)
"         let c = nr2char(i)
"         exec "\"map \e".c." <M-".c.">\""
"         exec "\"map! \e".c." <M-".c.">\""
"         exec "\"imap \e".c." <M-".toupper(c).">\""
"     endfor
"     set ttimeoutlen=10  " 缩短keycode的timeout
" endif

"用,cd进入当前目录
nmap ,cd :cd <C-R>=expand("%:p:h")<CR><CR>
"用,e可以打开当前目录下的文件
nmap ,e :e <C-R>=escape(expand("%:p:h")."/", ' \')<CR>
"在命令中，可以用 %/ 得到当前目录。如 :e %/
cmap %/ <C-R>=escape(expand("%:p:h")."/", ' \')<cr>

"正常模式下，空格及Shift-空格滚屏
noremap <SPACE> <C-F>
noremap <S-SPACE> <C-B>

"Ctrl-Tab/Ctrl-Shirt-Tab切换Tab
nmap <C-S-tab> :tabprevious<cr>
nmap <C-tab> :tabnext<cr>
map <C-S-tab> :tabprevious<cr>
map <C-tab> :tabnext<cr>
imap <C-S-tab> <ESC>:tabprevious<cr>i
imap <C-tab> <ESC>:tabnext<cr>i

" Key mappings to ease browsing long lines
nnoremap  <C-J>       gj
nnoremap  <C-K>       gk
nnoremap  <Down>      gj
nnoremap  <Up>        gk
inoremap <Down> <C-O>gj
inoremap <Up>   <C-O>gk

" Key mappings for the quickfix commands
nmap <F11> :cn<CR>
nmap <F12> :cp<CR>
nmap g<F11> :cnf<CR>
nmap g<F12> :cpf<CR>

" F3自动vimgrep当前word
"nmap <F3> :exec "vimgrep /\\<" . expand("<cword>") . "\\>/j **/*.cpp **/*.c **/*.h **/*.php"<CR>:copen<CR>
"nmap <S-F3> :exec "vimgrep /\\<" . expand("<cword>") . "\\>/j %" <CR>:copen<CR>
"map <F3> <ESC>:exec "vimgrep /\\<" . expand("<cword>") . "\\>/j **/*.cpp **/*.cxx **/*.c **/*.h **/*.hpp **/*.php" <CR><ESC>:copen<CR>
nmap g<F3> <ESC>:exec "vimgrep /\\<" . expand("<cword>") . "\\>/j " . b:vimgrep_files <CR><ESC>:copen<CR>
"map <S-F3> <ESC>:exec "vimgrep /\\<" . expand("<cword>") . "\\>/j %" <CR><ESC>:copen<CR>
nmap <F3> <ESC>:<C-U>exec "vimgrep /" . expand("<cword>") . "/j %" <CR><ESC>:copen<CR>

" 在VISUAL模式下，缩进后保持原来的选择，以便再次进行缩进
vnoremap > >gv
vnoremap < <gv

" Tabs
nnoremap <silent> <LocalLeader>[ :tabprev<CR>
nnoremap <silent> <LocalLeader>] :tabnext<CR>
" Split line(opposite to S-J joining line)
nnoremap <silent> <C-J> gEa<CR><ESC>ew

" map <silent> <C-W>v :vnew<CR>
" map <silent> <C-W>s :snew<CR>

" nnoremap * :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>

" zJ/zK跳到下个/上个折叠处，并只显示该折叠的内容
nmap zJ zjzx
nmap zK zkzx

"map <S-CR> A<CR><ESC>

" 一些方便编译的快捷键
nnoremap <Leader>tm :<C-U>make<CR>
nnoremap <Leader>tt :<C-U>make unittest<CR>
nnoremap <Leader>ts :<C-U>make stage<CR>
nnoremap <Leader>tc :<C-U>make clean<CR>
nnoremap <Leader>td :<C-U>make doc<CR>
" " }}}

" NeoBundle -- load plugins {{{

" Brief help
" :NeoBundleList          - list configured bundles
" :NeoBundleInstall(!)    - install(update) bundles
" :NeoBundleClean(!)      - confirm(or auto-approve) removal of unused bundles

" Loading NeoBundle {{{
filetype off                   " Required!

if has('vim_starting')
    let &runtimepath .= "," . fnamemodify(finddir("bundle/neobundle.vim", &runtimepath), ":p")
endif

call neobundle#rc()

let g:neobundle_default_git_protocol = 'https'

" Let NeoBundle manage NeoBundle
NeoBundle 'Shougo/neobundle.vim'    " 插件管理软件
" }}}

" Help {{{
NeoBundle 'fs111/pydoc.vim'                         " 对python文件，可以按K取得帮助
NeoBundle 'Python-2.x-Standard-Library-Reference'   " 可通过 :help py2stdlib 获得python的帮助文件
" }}}

" Unite {{{
NeoBundle 'Shougo/unite.vim'                        " Unite主插件，提供\f开头的功能
"NeoBundle 'Shougo/unite-build'
"NeoBundle 'h1mesuke/unite-outline'
NeoBundle 'Shougo/unite-outline'                    " 提供代码的大纲。通过\fo访问
NeoBundle 'tacroe/unite-mark'                       " 列出所有标记点
NeoBundle 'tsukkee/unite-help'                      " 查找vim的帮助
NeoBundle 'tsukkee/unite-tag'                       " 跳转到光标下的tag。通过\fT访问
NeoBundle 'ujihisa/unite-colorscheme'               " 列出所有配色方案
NeoBundle 'osyo-manga/unite-quickfix'               " 过滤quickfix窗口（如在编译结果中查找）
NeoBundle 'eiiches/unite-tselect'                   " 跳转到光标下的tag。通过g]和g<C-]>访问
NeoBundle 'hrsh7th/vim-unite-vcs'                   " \fv 看未提交的文件列表，\fl 看更新日志
" }}}

" Editing {{{
NeoBundle 'h1mesuke/vim-alignta'                    " 代码对齐插件。通过\fa访问
NeoBundle 'matchit.zip'                             " 将%的功能扩展到多种语言（如对于XML，可以在开始tag和结束tag之间进行跳转）
NeoBundle 'YankRing.vim'                            " 在粘贴时，按了p之后，可以按<C-P>粘贴存放在剪切板历史中的内容
NeoBundle 'vis'                                     " 在块选后（<C-V>进行选择），:B cmd在选中内容中执行cmd
NeoBundle 'surround.vim'                            " 增加s?的motion，可用于快速替换括号、引号等。:help surround.txt 可查看其帮助
NeoBundle 'DrawIt'                                  " 使用横、竖线画图、制表。\di和\ds分别启、停画图模式。在模式中，hjkl移动光标，方向键画线
NeoBundle 'Lokaltog/vim-easymotion'                 " \\w启动word motion，\\f<字符>启动查找模式
NeoBundle 'Shougo/neocomplcache'                    " 代码补全插件
NeoBundle 'Shougo/neosnippet'                       " 代码模板
"NeoBundle 'othree/eregex.vim'                       " 支持Perl风格的正则表达式。:M、:S、:G、:V

"NeoBundle 'VimIM'                                   " 中文输入法

if v:version >= '701'
    NeoBundle 'Mark--Karkat'                        " 可同时标记多个mark。\M显示隐，\N清除所有Mark。\m标识当前word
endif
" }}}

" Text object {{{
NeoBundle 'kana/vim-textobj-user'                   " 可自定义motion
NeoBundle 'lucapette/vim-textobj-underscore'        " 增加motion: a_ i_
NeoBundle 'kana/vim-textobj-indent'                 " 增加motion: ai ii（含更深缩进） aI iI（仅相同缩进）
NeoBundle 'kana/vim-textobj-line'                   " 增加motion: al il
NeoBundle 'thinca/vim-textobj-comment'              " 增加motion: ac ic
" }}}

" Programming {{{
" NeoBundle 'tyru/current-func-info.vim'
NeoBundle 'echofunc.vim'                            " 在插入模式下输入(时，会在statusline显示函数的签名，对于有多个重载的函数，可通过<A-->/<A-=>进行切换
NeoBundle 'DoxygenToolkit.vim'                      " 为函数插入Doxygen注释。在函数名所在行输入 :Dox 即可
NeoBundle 'CodeReviewer.vim'                        " 记录代码走查意见，\ic激活。可通过 cfile <文件名> 把记录走查意见的文件导入 quickfix 列表
NeoBundle 'OrelSokolov/HiCursorWords'               " 高亮与光标下word一样的词
NeoBundle 'tComment'                                " 注释工具。gc{motion}/gcc/<C-_>等
" \\\ to comment a line, \\ to comment a motion, \\u to uncomment
"NeoBundle 'tpope/vim-commentary'
"NeoBundle 'bahejl/Intelligent_Tags'
if executable("ctags")
    NeoBundle 'thawk/Intelligent_Tags'              " 自动扫描所依赖的头文件，生成tags文件
    "NeoBundle 'AutoTag'
endif
NeoBundle 'majutsushi/tagbar'                       " 列出文件中所有类和方法。用<F9>调用
NeoBundle 'vcscommand.vim'                          " SVN前端。\cv进行diff，\cn查看每行是谁改的，\cl查看修订历史，\cG关闭VCS窗口回到源文件
NeoBundle 'tpope/vim-fugitive'                      " GIT前端

if executable("clang") || filereadable(expand("~/libexec/libclang.so")) || filereadable(expand("/usr/lib/libclang.so")) || filereadable(expand("/usr/lib64/libclang.so"))
    NeoBundle 'Rip-Rip/clang_complete'              " 使用clang编译器进行上下文补全
    NeoBundleLazy 'thawk/OmniCppComplete'           " 使用tags进行上下文补全
else
    NeoBundleLazy 'Rip-Rip/clang_complete'          " 使用clang编译器进行上下文补全
    NeoBundle 'thawk/OmniCppComplete'               " 使用tags进行上下文补全
endif
NeoBundle 'scrooloose/syntastic'                    " 保存文件时自动进行合法检查。:SyntasticCheck 执行检查， :Errors 打开错误列表
if (s:is_windows)
    NeoBundle 'OrangeT/vim-csharp'                  " C#文件的相关
endif
if executable("cpplint.py")
    NeoBundle 'funorpain/vim-cpplint'               " <F7>执行cpplint检查（要求PATH中能找到cpplint.py）
endif
NeoBundle 'rkulla/pydiction'                        " Python的补全
" }}}

" Language {{{
NeoBundle 'csv.vim'                                 " 增加对CSV文件（逗号分隔文件）的支持
NeoBundle 'jceb/vim-orgmode', {
    \ 'depends' : [
    \   'NrrwRgn',
    \   'speeddating.vim',
    \ ]}
NeoBundle 'Emmet.vim'                               " 快速编写XML文件。如 div>p#foo$*3>a 再按 <C-Y>,
if (s:is_windows)
    NeoBundle 'wps.vim'                             " syntax highlight for RockBox wps file
else
    NeoBundle 'lbdbq'                               " 支持lbdb
endif
NeoBundle 'othree/xml.vim'                          " 辅助编写XML文件
NeoBundle 'indentpython.vim--nianyang'              " Python的代码缩进插件
"NeoBundle 'tmhedberg/SimpylFold'
NeoBundle 'gprof.vim'                               " 对gprof文件提供语法高亮
" }}}

" Colors {{{
NeoBundle 'altercation/vim-colors-solarized'        " Solarized配色方案
NeoBundle 'Zenburn'                                 " Zenburn配色方案
" }}}

" Files {{{
NeoBundle 'FSwitch'                                 " 在头文件和CPP文件间进行切换。用:A调用。\ol在右边分隔一个窗口显示
"NeoBundle 'jceb/vim-editqf'
NeoBundle 'LargeFile'                               " 在打开大文件时，禁用语法高亮以提供打开速度
NeoBundle 'rbtnn/hexript.vim'                       " to generate binary file
NeoBundle 'Shougo/vinarise'                         " Hex Editor
" }}}

" Utils {{{
NeoBundle 'renamer.vim'                             " 可对当前目录下的文件进行批量改名，:Renamer
NeoBundle 'Shougo/vimfiler'                         " 文件管理器，:VimFiler
NeoBundle 'Shougo/vimshell'                         " Shell，:VimShell
NeoBundle 'sudo.vim'                                " 通过sudo读、写文件。:SudoRead/:SudoWrite
NeoBundle 'quickrun.vim'                            " 快速运行代码片段
NeoBundle 'mtth/scratch.vim'                        " 打开一个临时窗口。gs/gS/:Scratch
" }}}

" Misc {{{
NeoBundle 'sjl/gundo.vim'                           " 列出修改历史，方便undo到一个特定的位置
NeoBundle 'tpope/vim-repeat'                        " 把.能重复的操作扩展到一些插件中的操作
NeoBundle 'AutoFenc.vim'                            " 自动判别文件的编码
NeoBundle 'Shougo/vimproc', {
      \ 'build' : {
      \ 'windows' : 'echo "Sorry, cannot update vimproc binary file in Windows."',
      \ 'cygwin' : 'make -f make_cygwin.mak && touch -t 200001010000.00 autoload/vimproc_unix.so',
      \ 'mac' : 'make -f make_mac.mak && touch -t 200001010000.00 autoload/vimproc_unix.so',
      \ 'unix' : 'make -f make_unix.mak && touch -t 200001010000.00 autoload/vimproc_unix.so',
      \ },
      \ }
NeoBundle 'thinca/vim-prettyprint'                  " PP variable_name，以用户友好的方式打印变量值，调试vim脚本用
NeoBundle 'bling/vim-airline'                       " 增强的statusline

" very slow ?
"NeoBundle 'xolox/vim-easytags'
"NeoBundle 'https://bitbucket.org/abudden/taghighlight'

" }}}

" 载入manual-bundles下的插件
call neobundle#local(fnamemodify(finddir("manual-bundles", &runtimepath), ":p"), {})

" Installation check {{{
syntax on
filetype plugin indent on     " Required!

" Installation check.
if neobundle#exists_not_installed_bundles()
  echomsg 'Not installed bundles : ' .
        \ string(neobundle#get_not_installed_bundle_names())
  echomsg 'Please execute ":NeoBundleInstall" command.'
  "finish
endif
" }}}

" }}}

" Plugins settings (After load plugins) {{{

" Plugin 'FSwitch' {{{
if neobundle#is_installed("FSwitch")
    let g:fsnonewfiles=1
    cabbrev A FSHere " 可以用:A在.h/.cpp间切换
    augroup fswitch_hack
        au! BufEnter *.h
                    \  let b:fswitchdst='cpp,c,ipp,cxx'
                    \| let b:fswitchlocs='reg:/include/src/,reg:/include.*/src/,ifrel:|/include/|../src|,reg:!\<include/\w\+/!src/!,reg:!\<include/\(\w\+/\)\{2}!src/!,reg:!sscc\(/[^/]\+\|\)/.*!libs\1/**!'
        au! BufEnter *.c,*.cpp,*.ipp
                    \  let b:fswitchdst='h,hpp'
                    \| let b:fswitchlocs='reg:/src/include/,reg:|/src|/include/**|,ifrel:|/src/|../include|,reg:|libs/.*|**|'
        au! BufEnter *.xml
                    \  let b:fswitchdst='rnc'
                    \| let b:fswitchlocs='./'
        au! BufEnter *.rnc
                    \  let b:fswitchdst='xml'
                    \| let b:fswitchlocs='./'
    augroup END

    " Switch to the file and load it into the current window >
    nmap <silent> <Leader>oo :FSHere<cr>
    " Switch to the file and load it into the window on the right >
    nmap <silent> <Leader>ol :FSRight<cr>
    " Switch to the file and load it into a new window split on the right >
    nmap <silent> <Leader>oL :FSSplitRight<cr>
    " Switch to the file and load it into the window on the left >
    nmap <silent> <Leader>oh :FSLeft<cr>
    " Switch to the file and load it into a new window split on the left >
    nmap <silent> <Leader>oH :FSSplitLeft<cr>
    " Switch to the file and load it into the window above >
    nmap <silent> <Leader>ok :FSAbove<cr>
    " Switch to the file and load it into a new window split above >
    nmap <silent> <Leader>oK :FSSplitAbove<cr>
    " Switch to the file and load it into the window below >
    nmap <silent> <Leader>oj :FSBelow<cr>
    " Switch to the file and load it into a new window split below >
    nmap <silent> <Leader>oJ :FSSplitBelow<cr>
endif
" }}}

" Plugin 'quickrun.vim' {{{
if neobundle#is_installed("quickrun.vim")
    nmap ,r <Plug>(quickrun)
endif
" }}}

" Plugin 'echofunc.vim' {{{
" }}}

" Plugin 'LargeFile' {{{
" 在打开大文件时，自动禁用一些功能，保证大文件可以快速打开
" }}}

" Plugin 'vim-easymotion' {{{
if neobundle#is_installed("vim-easymotion")
    " \\{motion}
    hi link EasyMotionTarget ErrorMsg
    hi link EasyMotionShade  Comment
endif
" }}}

" Plugin 'YankRing.vim' {{{
if neobundle#is_installed("YankRing.vim")
    let g:yankring_persist = 0              "不把yankring持久化
    let g:yankring_share_between_instances = 0
    let g:yankring_manual_clipboard_check = 1
endif
" }}}

" Plugin 'vim-alignta' {{{
if neobundle#is_installed("vim-alignta")
    " 对齐
    " :[range]Alignta [arguments] 或 [range]Align [arguments]
    " 参数：
    " g/regex 或 v/regex 过滤行
    "
    " :Alignta = 对齐等号
    " :Alignta = 对齐等号，
    " :Alignta <- b 对齐b字符

    let s:comment_leadings = '^\s*\("\|#\|/\*\|//\|<!--\)'

    let g:unite_source_alignta_preset_arguments = [
                \ ["Align at ' '", '\S\+'],
                \ ["Declaration", 'v/^\w\+:\|' . s:comment_leadings . ' <<1:2 \(\S\+;\|\w\+()\(\s*const\)\?\s*;\|\w\+,\|\w\+);\?\) \(\/\/.*\|\/\*.*\)\?'],
                \ ["Align at '='", '=>\='],
                \ ["Align at ':'", '01 :'],
                \ ["Align at ','", '10 \(,\s*\)\@<=\S'],
                \ ["Align at '|'", '|'   ],
                \ ["Align at ')'", '0 )' ],
                \ ["Align at ']'", '0 ]' ],
                \ ["Align at '}'", '}'   ],
                \]

    let g:unite_source_alignta_preset_options = [
                \ ["Not in comment ".s:comment_leadings, 'v/' . s:comment_leadings],
                \ ["Justify Left",      '<<' ],
                \ ["Justify Center",    '||' ],
                \ ["Justify Right",     '>>' ],
                \ ["Justify None",      '==' ],
                \ ["Shift Left",        '<-' ],
                \ ["Shift Right",       '->' ],
                \ ["Shift Left  [Tab]", '<--'],
                \ ["Shift Right [Tab]", '-->'],
                \ ["Margin 0:0",        '0'  ],
                \ ["Margin 0:1",        '01' ],
                \ ["Margin 1:0",        '10' ],
                \ ["Margin 1:1",        '1'  ],
                \ ["In comment ".s:comment_leadings, 'g/' . s:comment_leadings],
                \]
    unlet s:comment_leadings

    " 在没选中文本时，按[unite]a选择需要用的选项，再选中要操作的文本，[unite]a进行操作
    nnoremap <silent> [unite]a :<C-u>Unite alignta:options<CR>
    xnoremap <silent> [unite]a :<C-u>Unite alignta:arguments<CR>
endif
" }}}

" Plugin 'OmniCppComplete' {{{
if neobundle#is_installed("OmniCppComplete")
    let OmniCpp_NamespaceSearch = 1
    let OmniCpp_GlobalScopeSearch = 1
    let OmniCpp_DisplayMode = 0
    let OmniCpp_ShowAccess = 1
    let OmniCpp_ShowPrototypeInAbbr = 1
    let OmniCpp_ShowScopeInAbbr = 0
    let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]

    let OmniCpp_MayCompleteDot = 0
    let OmniCpp_MayCompleteArrow = 0
    let OmniCpp_MayCompleteScope = 0

    let OmniCpp_SelectFirstItem = 0 " 0 = don't select first popup item
    " 1 = select first popup item (inserting it to the text)
    " 2 = select first popup item (without inserting it to the text)

    let OmniCpp_LocalSearchDecl = 1
endif
" }}}

" Plugin 'clang_complete' {{{
"
" clang编译方法：
"
" svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm
" svn co http://llvm.org/svn/llvm-project/cfe/trunk llvm/tools/clang
" mkdir -p llvm/build && cd llvm/build
" ../configure
" make -j9 ENABLE_OPTIMIZED=1 DISABLE_ASSERTIONS=1
"
" 要把Release/lib/libclang.so和Release/lib/clang目录拷贝到g:clang_library_path
" 指向的位置，这样clang就可以比较快速地进行补全了。
if neobundle#is_installed("clang_complete")
    let g:clang_complete_auto = 0
    let g:clang_auto_select = 0
    let g:clang_complete_copen = 0  " open quickfix window on error.
    let g:clang_hl_errors = 1       " highlight the warnings and errors the same way clang
    let g:clang_jumpto_declaration_key = '<C-S-]>'
    let g:clang_jumpto_back_key = '<C-S-T>'
    if filereadable(expand("~/libexec/libclang.so"))
        let g:clang_use_library = 1
        let g:clang_library_path=expand("~/libexec")
    elseif filereadable(expand("/usr/lib/libclang.so"))
        let g:clang_use_library = 1
        let g:clang_library_path=expand("/usr/lib")
    elseif filereadable(expand("/usr/lib64/libclang.so"))
        let g:clang_use_library = 1
        let g:clang_library_path=expand("/usr/lib64")
    endif
endif
" }}}

" Plugin 'pydoc.vim' {{{
let pydoc_perform_mappings = 1

"au FileType python nnoremap <silent> <buffer> <Leader>pw :<C-U>Pydoc <C-R><C-W><CR>
"au FileType python nnoremap <silent> <buffer> <Leader>pW :<C-U>Pydoc <C-R><C-A><CR>
"au FileType python nnoremap <silent> <buffer> <Leader>pk :<C-U>PydocSearch <C-R><C-W><CR>
"au FileType python nnoremap <silent> <buffer> <Leader>pK :<C-U>PydocSearch <C-R><C-A><CR>
"
"" remap the K (or 'help') key
"au FileType python nnoremap <silent> <buffer> K :<C-U>Pydoc <C-R><C-W><CR>
"  }}}

" Plugin 'Python-2.x-Standard-Library-Reference' {{{
" Python2的标准库帮助文件
" :help py2stdlib 显示帮助
" :help py2stdlib<tab>
" :help py2stdlib-os
" }}}

" Plugin 'pydiction' {{{
if neobundle#is_installed("pydiction")
    let g:pydiction_location = fnamemodify(findfile("complete-dict",&runtimepath), ":p")
endif
"  }}}

" Plugin 'csv.vim' {{{
"  }}}

" Plugin 'ZenCoding.vim' {{{
" }}}

" Plugin 'Mark--Karkat' {{{
" 代替了 MultipleSearch
if neobundle#is_installed("Mark--Karkat")
    nmap <Leader>M <Plug>MarkToggle
    nmap <Leader>N <Plug>MarkAllClear

    " 在插件载入后再执行修改颜色的操作
    augroup Mark
    au VimEnter *
                \ highlight MarkWord1 ctermbg=DarkCyan    ctermfg=Black guibg=#8CCBEA guifg=Black |
                \ highlight MarkWord2 ctermbg=DarkBlue    ctermfg=Black guibg=#A4E57E guifg=Black |
                \ highlight MarkWord3 ctermbg=DarkYellow  ctermfg=Black guibg=#FFDB72 guifg=Black |
                \ highlight MarkWord4 ctermbg=DarkMagenta ctermfg=Black guibg=#FF7272 guifg=Black |
                \ highlight MarkWord5 ctermbg=DarkGreen   ctermfg=Black guibg=#FFB3FF guifg=Black |
                \ highlight MarkWord6 ctermbg=DarkRed     ctermfg=Black guibg=#9999FF guifg=Black
    augroup END
endif
" }}}

" Plugin 'neocomplcache' {{{
if neobundle#is_installed("neocomplcache")
    " Use neocomplcache.
    "let g:neocomplcache_enable_debug = 1
    let g:neocomplcache_enable_at_startup = 1
    " Disable auto completion, if set to 1, must use <C-x><C-u>
    let g:neocomplcache_disable_auto_complete = 0
    " Use smartcase.
    let g:neocomplcache_enable_smart_case = 1
    " Use camel case completion.
    let g:neocomplcache_enable_camel_case_completion = 1
    " Use underbar completion.
    let g:neocomplcache_enable_underbar_completion = 1
    " Set minimum syntax keyword length.
    let g:neocomplcache_min_syntax_length = 3
    let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
    let g:neocomplcache_enable_auto_select = 0
    let g:neocomplcache_auto_completion_start_length = 3

    " Define dictionary.
    let g:neocomplcache_dictionary_filetype_lists = {
                \ 'default' : '',
                \ 'vimshell' : $HOME.'/.vimshell_hist',
                \ 'scheme' : $HOME.'/.gosh_completions'
                \ }

    inoremap <expr><C-x><C-f>  neocomplcache#manual_filename_complete()

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplcache#undo_completion()
    inoremap <expr><C-l>     neocomplcache#complete_common_string()

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
    " <TAB>: completion.
    "inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y>  neocomplcache#close_popup()
    inoremap <expr><C-e>  neocomplcache#cancel_popup()

    " Enable omni completion.
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

    " Enable heavy omni completion.
    if !exists('g:neocomplcache_force_omni_patterns')
        let g:neocomplcache_force_omni_patterns = {}
    endif
    let g:neocomplcache_force_overwrite_completefunc = 1
    let g:neocomplcache_force_omni_patterns.c =
                \ '[^.[:digit:] *\t]\%(\.\|->\)'
    let g:neocomplcache_force_omni_patterns.cpp =
                \ '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
    let g:neocomplcache_force_omni_patterns.objc =
                \ '[^.[:digit:] *\t]\%(\.\|->\)'
    let g:neocomplcache_force_omni_patterns.objcpp =
                \ '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
endif
" }}}

" neosnippet {{{
if neobundle#is_installed("neosnippet")
    let g:neocomplcache_snippets_dir = fnamemodify(finddir("snippets", &runtimepath), ":p")
    let g:neocomplcache_snippets_dir .= "," . fnamemodify(finddir("/neosnippet/autoload/neosnippet/snippets", &runtimepath), ":p")

    imap <C-k>     <Plug>(neosnippet_expand_or_jump)
    smap <C-k>     <Plug>(neosnippet_expand_or_jump)
    xmap <C-k>     <Plug>(neosnippet_expand_target)

    " SuperTab like snippets behavior.
    imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                \ "\<Plug>(neosnippet_expand_or_jump)"
                \: pumvisible() ? "\<C-n>" : "\<TAB>"
    smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                \ "\<Plug>(neosnippet_expand_or_jump)"
                \: "\<TAB>"

    " For snippet_complete marker.
    if has('conceal')
        set conceallevel=2 concealcursor=i
    endif
endif
" }}}

" Plugin 'vinarise' {{{ " Hex Editor
" }}}

" unite {{{
if neobundle#is_installed("unite.vim")
    " 类似Fuzzyfinder的插件
    " The prefix key.
    nnoremap [unite] <Nop>
    xnoremap [unite] <Nop>
    nmap <Leader>f [unite]
    xmap <Leader>f [unite]

    let g:unite_enable_start_insert = 1
    "let g:unite_enable_short_source_names = 1

    let g:unite_enable_ignore_case = 1
    let g:unite_enable_smart_case = 1

    let g:unite_source_session_path = expand('~/.vim/session/')
    let g:unite_source_grep_default_opts = "-iHn --color=never"

    let g:unite_winheight = winheight("%") / 2
    let g:unite_winwidth = winwidth("%") / 2

    let g:unite_source_file_rec_ignore_pattern =
                \'\%(^\|/\)\.$\|\~$\|\.\%(o\|exe\|dll\|bak\|DS_Store\|zwc\|pyc\|sw[po]\|class\|gcno\|gcda\|a\)$'.
                \'\|gcc-[0-9]\+\%(\.[0-9]\+\)*/'.
                \'\|\%(^\|/\)\%(\.hg\|\.git\|\.bzr\|\.svn\|tags\%(-.*\)\?\)\%($\|/\)'

    nnoremap [unite]S :<C-U>Unite source<CR>

    nnoremap <silent> [unite]y :<C-U>Unite -buffer-name=yanks history/yank register<CR>
    nnoremap <silent> [unite]w :<C-u>UniteWithCursorWord -buffer-name=register buffer file_mru bookmark file<CR>
    " nnoremap <silent> [unite]c :<C-u>Unite change jump<CR>
    " nnoremap <silent> [unite]R :<C-u>Unite -buffer-name=resume resume<CR>
    " nnoremap <silent> [unite]d :<C-u>Unite -buffer-name=files -default-action=lcd directory_mru<CR>
    nnoremap <silent> [unite]G :<C-u>Unite grep -buffer-name=search -no-quit<CR>
    " nnoremap <silent> [unite]G :<C-u>UniteWithCursorWord grep -buffer-name=search -no-quit<CR>
    nnoremap <silent> [unite]g :<C-u>Unite grep:<C-R>=expand("%:p:h")<CR> -buffer-name=search -no-quit -start-insert -input=<C-R><C-W><CR>

    nnoremap <silent> [unite]/ :<C-U>Unite -buffer-name=search -start-insert line<CR>
    "nnoremap <silent> [unite]B :<C-U>Unite -buffer-name=bookmarks bookmark<CR>
    nnoremap <silent> [unite]B :<C-U>Unite -buffer-name=files buffer<CR>
    nnoremap <silent> [unite]b :<C-u>UniteWithBufferDir -buffer-name=files buffer bookmark file file_mru -start-insert<CR>
    nnoremap <silent> [unite]c :<C-u>UniteWithCurrentDir -buffer-name=files buffer bookmark file file_mru -start-insert<CR>
    " nnoremap <silent> [unite]f :<C-U>UniteWithBufferDir -buffer-name=files -start-insert file<CR>
    nnoremap <silent> [unite]h :<C-U>Unite -buffer-name=helps -start-insert help<CR>
    nnoremap <silent> [unite]H :<C-U>UniteWithCursorWord -buffer-name=helps help<CR>
    nnoremap <silent> [unite]M :<C-U>Unite mark<CR>
    " nnoremap <silent> [unite]m :<C-U>wall<CR><ESC>:Unite -buffer-name=build -no-quit build<CR>
    nnoremap <silent> [unite]Q :<C-u>Unite poslist<CR>
    nnoremap <silent> [unite]q :<C-u>Unite quickfix -no-quit<CR>
    " nnoremap <silent> [unite]r :<C-U>Unite -buffer-name=mru -start-insert file_mru<CR>
    " nnoremap <silent> [unite]s :<C-u>Unite -start-insert session<CR>
    "nnoremap <silent> [unite]T :<C-U>Unite -buffer-name=tabs -start-insert tab<CR>
    "nnoremap <silent> [unite]T :<C-U>UniteWithCursorWord -buffer-name=tags tag tag/include<CR>
    nnoremap <silent> [unite]T :<C-U>UniteWithCursorWord -buffer-name=tags tag<CR>
    nnoremap <silent> [unite]t :<C-U>wall<CR><ESC>:Unite -buffer-name=build -no-quit build::test<CR>
    " nnoremap <silent> [unite]U :<C-u>UniteResume -no-quit<CR>
    " nnoremap <silent> [unite]u :<C-u>UniteResume<CR>
    nnoremap <silent> [unite]v :<C-u>Unite vcs/status<CR>
    nnoremap <silent> [unite]l :<C-u>Unite vcs/log<CR>

    nnoremap <silent> [unite]r :<C-u>UniteResume<CR>
    " nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=files buffer file_rec:! file_mru bookmark<cr><c-u>

    nnoremap <silent> [unite]d :<C-u>Unite -buffer-name=files -default-action=lcd directory_mru<CR>
    nnoremap <silent> [unite]ma :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
    nnoremap <silent> [unite]me :<C-u>Unite output:message<CR>

    if s:is_windows
        nnoremap <silent> [unite]f
                    \ :<C-u>Unite -buffer-name=files -no-split -multi-line
                    \ jump_point file_point buffer
                    \ file_rec:! file file/new file_mru<CR>
    else
        nnoremap <silent> [unite]f
                    \ :<C-u>Unite -buffer-name=files -no-split -multi-line
                    \ jump_point file_point buffer
                    \ file_rec/async:! file file/new file_mru<CR>
    endif

    if neobundle#is_installed("unite-outline")
        nnoremap <silent> [unite]o  :<C-u>Unite outline -start-insert<CR>
    endif

    autocmd! FileType unite call s:unite_my_settings()
    function! s:unite_my_settings() "{{{
        nmap <buffer> <ESC>      <Plug>(unite_exit)
        imap <buffer> jj      <Plug>(unite_insert_leave)

        imap <buffer><expr> j unite#smart_map('j', '')
        imap <buffer> <TAB>   <Plug>(unite_select_next_line)
        imap <buffer> <S-TAB>   <Plug>(unite_select_previous_line)
        imap <buffer> <C-w>     <Plug>(unite_delete_backward_path)
        imap <buffer> '     <Plug>(unite_quick_match_default_action)
        nmap <buffer> '     <Plug>(unite_quick_match_default_action)
        imap <buffer><expr> x
                    \ unite#smart_map('x', "\<Plug>(unite_quick_match_choose_action)")
        nmap <buffer> x     <Plug>(unite_quick_match_choose_action)
        nmap <buffer> <C-z>     <Plug>(unite_toggle_transpose_window)
        imap <buffer> <C-z>     <Plug>(unite_toggle_transpose_window)
        imap <buffer> <C-y>     <Plug>(unite_narrowing_path)
        nmap <buffer> <C-y>     <Plug>(unite_narrowing_path)
        nmap <buffer> <C-j>     <Plug>(unite_toggle_auto_preview)
        nmap <buffer> <C-r>     <Plug>(unite_narrowing_input_history)
        imap <buffer> <C-r>     <Plug>(unite_narrowing_input_history)
        nnoremap <silent><buffer><expr> l
                    \ unite#smart_map('l', unite#do_action('default'))

        let unite = unite#get_current_unite()
        if unite.profile_name ==# 'search'
            nnoremap <silent><buffer><expr> r     unite#do_action('replace')
        else
            nnoremap <silent><buffer><expr> r     unite#do_action('rename')
        endif

        nnoremap <silent><buffer><expr> cd     unite#do_action('lcd')
        nnoremap <buffer><expr> S      unite#mappings#set_current_filters(
                    \ empty(unite#mappings#get_current_filters()) ?
                    \ ['sorter_reverse'] : [])

        " Runs "split" action by <C-s>.
        imap <silent><buffer><expr> <C-s>     unite#do_action('split')
    endfunction "}}}
endif
" }}} " unite

" Plugin 'CodeReviewer.vim' {{{
if neobundle#is_installed("CodeReviewer.vim")
    " Typical review session:
    " 1. A reviewer open the code to review, positions the cursor on the line he/she wants to comment on and types "\ic" - this puts the file name, the line number, the reviewer's initials and the defect type in the review file
    " 2. The comment is typed next to the line number and can span multiple lines
    " 3. Send the comments to the author of the code
    " 4. The author collates the inputs from various reviewers into one file (by simply concatenating them) and sorts it. Now the comments are arranged per file, in the order of line numbers (in a file called say, all_comments.txt)
    " 5. Using the :cfile all_comments.txt (or :CheckReview) the author can now navigate through all the comments.
    if $USER != ""
        let g:CodeReviewer_reviewer = $USER
    elseif $USERNAME != ""
        let g:CodeReviewer_reviewer = $USERNAME
    else
        let g:CodeReviewer_reviewer = "Unknown"
    endif
    let g:CodeReviewer_reviewFile="review.rev"
endif
" }}}

" Plugin 'sudo.vim' {{{
"   (command line): vim sudo:/etc/passwd
"   (within vim):   :e sudo:/etc/passwd
" }}}

" Plugin 'Intelligent_Tags' {{{
if neobundle#is_installed("Intelligent_Tags")
    " 自动为当前文件及其包含的文件生成tags
    let g:Itags_Depth=3    " 缺省是1，当前文件及其包含的文件。-1表示无穷层
    let g:Itags_Ctags_Flags="--c++-kinds=+p --fields=+iaS --extra=+q -R"
    let g:Itags_header_mapping= {'h':['c', 'cpp', 'c++']}
endif
"
"}}}

" Plugin 'DoxygenToolkit.vim' {{{
if neobundle#is_installed("DoxygenToolkit.vim")
    let g:DoxygenToolkit_briefTag_pre="@brief "
    let g:DoxygenToolkit_paramTag_pre="@param[in] "
    let g:DoxygenToolkit_returnTag="@return "
endif
" }}}

" Plugin 'vim-easytags' {{{
if neobundle#is_installed("vim-easytags")
    let g:easytags_updatetime_autodisable = 1
    let g:easytags_updatetime_min = 10000
    let g:easytags_on_cursorhold = 0
endif
" " }}}

" Plugin 'vim-easytags' {{{
if neobundle#is_installed("unite-tselect")
    nnoremap g<C-]> :<C-u>Unite -immediately tselect:<C-r>=expand('<cword>')<CR><CR>
    nnoremap g] :<C-u>Unite tselect:<C-r>=expand('<cword>')<CR><CR>
endif
" " }}}

" Plugin 'vim-editqf' {{{
if neobundle#is_installed("vim-editqf")
    " 重新定义两个映射，把缺省的<leader>n空出来给mark插件
    nmap <leader>nn <Plug>QFAddNote
    nmap <leader>nN <Plug>QFAddNotePattern
endif
" " }}}

" Plugin 'vcscommand.vim' {{{
if neobundle#is_installed("vcscommand.vim")
    nnoremap <Leader>cp :VCSVimDiff PREV<CR>
endif
" " }}}

" Indents & Foldings" {{{
" Plugin 'indentpython.vim--nianyang'
" Plugin 'SimpylFold'
" " }}}

" Syntaxes " {{{
" Plugin 'asciidoc.vim' "{{{
"au BufRead,BufNewFile */viki/*.txt,*/pkm/*.txt,*/blog/*.txt,*.asciidoc  set filetype=asciidoc
au FileType asciidoc      setlocal shiftwidth=2
                               \ tabstop=2
                               \ textwidth=80 wrap formatoptions=cqnmB
                               \ makeprg=asciidoc\ -o\ numbered\ -o\ toc\ -o\ data-uri\ $*\ %
                               \ errorformat=ERROR:\ %f:\ line\ %l:\ %m
                               \ foldexpr=MyAsciidocFoldLevel(v:lnum)
                               \ foldmethod=expr
                               \ formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\\|^\\s*<\\d\\+>\\s\\+\\\\|^\\s*[a-zA-Z.]\\.\\s\\+\\\\|^\\s*[ivxIVX]\\+\\.\\s\\+
                               \ comments=s1:/*,ex:*/,://,b:#,:%,:XCOMM,fb:-,fb:*,fb:+,fb:.,fb:>
" "}}}

" Plugin 'wps.vim' {{{syntax highlight for RockBox wps file
au BufRead,BufNewFile *.wps,*.sbs,*.fms setf wps
" }}}
"
" " }}}

" Plugin 'vim-colors-solarized' {{{
if neobundle#is_installed("vim-colors-solarized")
    " 可以使用:SolarizedOptions生成solarized所需的参数
    " let g:solarized_visibility="low"    "default value is normal
    " Xshell需要打开termtrans选项才能正确显示
    let g:solarized_termtrans=1
    " let g:solarized_degrade=0
    " let g:solarized_bold=1
    " let g:solarized_underline=1
    " let g:solarized_italic=1
    " let g:solarized_termcolors=16
    " let g:solarized_contrast="normal"
    " let g:solarized_diffmode="normal"
    let g:solarized_hitrail=1
    " let g:solarized_menu=1

    if !g:isGUI " 在终端模式下，使用16色（终端需要使用solarized配色方案才能得到所要的效果）
        set t_Co=16
    end

    syntax enable
    set background=dark
    " let g:solarized_termcolors=256
    colorscheme solarized
else
    if version >= 700 && &term != 'cygwin' && &term != 'linux' && !(g:isGUI)
        set t_Co=256
    endif

    colorscheme desert
endif
" }}}

" " Plugin 'Zenburn' {{{
" if neobundle#is_installed("Zenburn")
"     set background=dark
"     colorscheme zenburn
" endif
" " }}}

" Plugin 'gundo' {{{
if neobundle#is_installed("gundo.vim")
    nnoremap <F5> :GundoToggle<CR>
endif
" }}}

" Plugin 'vim-csharp' {{{
if neobundle#is_installed("vim-csharp")
endif
" }}}

" Plugin 'tagbar' {{{
if neobundle#is_installed("tagbar")
    let g:tagbar_left = 1

    nnoremap ff :<C-U>TagbarCurrentTag fs<CR>
    augroup TagbarMappings
        au! FileType c,cpp,php,cs,vim,javascript,python nnoremap <silent> <buffer> <F9> :TagbarToggle<CR>
    augroup END
endif
" }}}

" Plugin 'HiCursorWords' {{{
if neobundle#is_installed("HiCursorWords")
    let g:HiCursorWords_delay = 200
    let g:HiCursorWords_hiGroupRegexp = ''
    let g:HiCursorWords_debugEchoHiName = 0
endif
" " }}}

" Plugin 'syntastic' {{{
if neobundle#is_installed("syntastic")
    " let g:syntastic_mode_map = {
    "             \ 'mode': 'active',
    "             \ 'active_filetypes': ['ruby', 'php', 'python'],
    "             \ 'passive_filetypes': ['cpp'] }

    let g:syntastic_cpp_checkers = ['cpplint']
    " 0: 不会自动打开、关闭 1: 自动打开及关闭 2: 没错误时自动关闭，但不会自动打开
    let g:syntastic_auto_loc_list=2
endif

" Plugin 'vimfiler' {{{
if neobundle#is_installed("vimfiler")
    " 文件管理器，通过 :VimFiler 启动。
    " c : copy, m : move, r : rename,
    let g:vimfiler_as_default_explorer = 1
endif
" }}}

" Plugin 'vim-airline' {{{
if neobundle#is_installed("vim-airline")
    if neobundle#is_installed("vcscommand.vim")
        let g:airline#extensions#branch#use_vcscommand = 1
    endif

    " let g:airline_left_sep = '►'
    " let g:airline_right_sep = '◄'

    " 开启powerline字体，可在 https://github.com/runsisi/consolas-font-for-powerline
    " 找到增加了特定字符的Consolas字体。
    " https://github.com/Lokaltog/powerline-fonts 在更多免费的字体
    let g:airline_powerline_fonts=1

    " let g:airline_left_sep = ''
    " let g:airline_left_alt_sep = ''
    " let g:airline_right_sep = ''
    " let g:airline_right_alt_sep = ''

    if !exists('g:airline_symbols')
        let g:airline_symbols = {}
    endif

    " let g:airline_symbols.branch = ''
    " let g:airline_symbols.readonly = ''
    " let g:airline_symbols.linenr = ''
    " let g:airline_symbols.paste = '∥'

    if s:is_windows
        let g:airline_symbols.whitespace = ' '
    else
        let g:airline_symbols.whitespace = 'Ξ'
        let g:airline_symbols.paste = '∥'
    endif

    set noshowmode
endif
" }}}

" Plugins depend settings {{{

"set statusline=%<%n:\ %f\ %h%m%r\ %=%k%y[%{&ff},%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]\ %-14.(%l,%c%V%)\ %P
set statusline=%<%n:                " Buffer number
set statusline+=\                   " 空格
set statusline+=%f                  " 文件名
set statusline+=\                   " 空格
set statusline+=%h                  " Help buffer flag
set statusline+=%m                  " Modified flag
set statusline+=%r                  " Readonly flag
set statusline+=\                   " 空格

if neobundle#is_installed("syntastic")
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
endif

set statusline+=%=                  " 左右对齐部分的分界
set statusline+=%k                  " Value of "b:keymap_name" or 'keymap'
set statusline+=%y                  " filetype
set statusline+=[%{&ff},%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]    " 文件编码
set statusline+=\                   " 空格
set statusline+=%-14.(%l,%c%V%)     " 行号、列号等
set statusline+=\                   " 空格
set statusline+=%P
" " }}}

if filereadable($HOME . "/.vim/project_setting")
    source $HOME/.vim/project_setting
endif

" vim: fileencoding=utf-8 foldmethod=marker:
