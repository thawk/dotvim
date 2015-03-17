scriptencoding utf-8

" 判断当前环境 {{{1
" 判断操作系统
let s:is_windows = has("win32") || has("win64") || has("win32unix")
let s:is_cygwin = has('win32unix')
let s:is_macvim = has('gui_macvim')

" 判断是终端还是gvim
let s:is_gui = has("gui_running")

" 当前脚本路径
let s:vimrc_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" 确定libclang的位置
let s:libclang_path = ""
let s:ag_path = ""

if executable("ag")
    let s:ag_path = "ag"
endif

let s:global_command = $GTAGSGLOBAL
if s:global_command == ''
    let s:global_command = "global"
endif
if executable(s:global_command)
    let s:has_global = 1
else
    let s:has_global = 0
endif

if s:is_windows
    if filereadable(s:vimrc_path . "\\win32\\libclang.dll")
        let s:libclang_path = s:vimrc_path . "\\win32"
    endif

    if !s:ag_path && executable(s:vimrc_path . "\\win32\\ag")
        let s:ag_path = s:vimrc_path . "\\win32\\ag"
    endif
else
    if filereadable(expand("~/libexec/libclang.so"))
        let s:libclang_path = expand("~/libexec")
    elseif filereadable(expand("/usr/lib/libclang.so"))
        let s:libclang_path = expand("/usr/lib")
    elseif filereadable(expand("/usr/lib64/libclang.so"))
        let s:libclang_path = expand("/usr/lib64")
    endif
endif

if s:ag_path
    exec 'set grepprg=' . s:ag_path . '\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
    set grepformat=%f:%l:%c:%m
endif
" }}}1

" General {{{1
set nocompatible " disable vi compatibility.
set history=256 " Number of things to remember in history.
set autowrite " Writes on make/shell commands
set autoread     " 当文件在外部被修改时，自动重新读取
"set timeoutlen=250 " Time to wait after ESC (default causes an annoying delay)
set clipboard+=unnamed " Yanks go on clipboard instead.
"set pastetoggle=<F10> " toggle between paste and normal: for 'safer' pasting from keyboard
set helplang=cn
"set viminfo+=! " Save and restore global variables

set fileencodings=ucs-bom,utf-8,cp936,taiwan,japan,korea,latin1

" Modeline
set modeline
set modelines=5 " default numbers of lines to read for modeline instructions

" Backup
set nowritebackup
set nobackup

" 设置各种目录 {{{2
" 设置swap-file保存路径
if (s:is_windows)
    let &directory='$TEMP//,$TMP//,' . &directory
    let &backupdir='$TEMP//,$TMP//,' . &backupdir
else
    let &backupdir='$HOME/bak//,' . &backupdir
endif

if has("persistent_undo")
    set undodir='~/.vim_undodir/'
    set undofile
endif
" }}}2

if (s:is_windows)
    set shellpipe=\|\ tee
    set shellslash
endif

set noshelltemp

set sessionoptions-=options
set viewoptions-=options

" Buffers
set hidden " The current buffer can be put to the background without writing to disk

" Match and search {{{2
set hlsearch " highlight search
set ignorecase " Do case in sensitive matching with
set smartcase " be sensitive when there's a capital letter
set incsearch "
set diffopt+=iwhite
" }}}2
" }}}1

" Formatting {{{1
"set fo+=o " Automatically insert the current comment leader after hitting 'o' or 'O' in Normal mode.
"set fo-=r " Do not automatically insert a comment leader after an enter
set fo-=t " Do no auto-wrap text using textwidth (does not apply to comments)
" 打开断行模块对亚洲语言支持
set fo+=m " 允许在两个汉字之间断行， 即使汉字之间没有出现空格
set fo+=B " 将两行合并为一行的时候， 汉字与汉字之间不要补空格

set nowrap
set textwidth=0 " Don't wrap lines by default
"set wildmode=list:longest,full  " 先列出所有候选项，补全候选项的共同前缀，再按wildchar就出现菜单来选择候选项
set wildmode=longest:full,full  " 补全候选项的共同前缀，出现菜单来选择候选项
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
set nosmartindent
set cindent
set cinoptions=:s,ps,ts,cs
set cinwords=if,else,while,do,for,switch,case

syntax on " enable syntax
filetype plugin on " 使用filetype插件
filetype plugin indent on " Automatically detect file types.
" }}}1

" Visual {{{1
let &termencoding = &encoding
if (s:is_windows)
    "set encoding=ucs-4
    "set encoding=utf-8
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
"set listchars=tab:>-,eol:<,trail:-,nbsp:%,extends:>,precedes:<
if &encoding != "utf-8"
    set listchars=tab:>-,trail:-,nbsp:%,extends:>,precedes:<
else
    let &listchars="tab:|-,trail:\u00b7,extends:\u00bb,precedes:\u00ab"
endif

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
if (s:is_gui)
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

" }}}1

" Coding {{{1
set tags+=./tags;/ " walk directory tree upto / looking for tags

set completeopt=menuone,menu,longest,preview
set completeopt-=longest
set showfulltag

if filereadable(s:vimrc_path . "\\win32\\words.txt")
    if len(&dictionary) > 0
        let &dictionary .= "," . s:vimrc_path . "\\win32\\words.txt"
    else
        let &dictionary = s:vimrc_path . "\\win32\\words.txt"
    endif
elseif filereadable("/usr/share/dict/words")
    set dictionary+=/usr/share/dict/words
endif

" Highlight space errors in C/C++ source files (Vim tip #935)
let c_space_errors=1
let java_space_errors=1
" }}}1

" Helper Functions {{{1
" Coding Helper Functions {{{2
function! s:RemoveTrailingSpace()
    if $VIM_HATE_SPACE_ERRORS != '0' &&
                \(&filetype == 'c' || &filetype == 'cpp' || &filetype == 'vim')
        normal m`
        silent! :%s/\s\+$//e
        normal ``
    endif
endfunction
" }}}2

" Encoding Helper Utilities " {{{2
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
" }}}2

" Find SVN branch " {{{2
let s:path_svnbranchinfo = {}
let s:svn_command = 'svn'

function! GetSvnBranchOfPath(path)
    if has_key(s:path_svnbranchinfo, a:path)
        return s:path_svnbranchinfo[a:path]
    endif

    let command = s:svn_command . ' info --xml --non-interactive "' . a:path . '"'
    let result = system(command)
    let branch_info = {}

    let m = matchlist(result, ".*<url>\\(.\\+\\)</url>.*")
    if len(m)
        let url = m[1]

        if url =~ ".*/trunk\\($\\|.*\\)"
            let branch_info["type"] = "trunk"
            let branch_info["branch"] = ""
        else
            let m = matchlist(url, ".*/\\(tags\\|branches\\)/\\([^/]\\+\\).*")
            if len(m)
                if m[1] =~ "tags"
                    let branch_info["type"] = "tag"
                else
                    let branch_info["type"] = "branch"
                endif

                let branch_info["branch"] = m[2]
            endif
        endif
    endif

    let s:path_svnbranchinfo[a:path] = branch_info
    return branch_info
endfunction
" }}}2

" }}}1

" Command and Auto commands " {{{1
" Sudo write
comm! W exec 'w !sudo tee % > /dev/null' | e!

"Auto commands

if (s:is_windows)
    au GUIEnter * simalt ~x " 启动时自动全屏
endif

au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal g'\"" | endif " restore position in file

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif

" Filetype detection " {{{2
au BufRead,BufNewFile {Gemfile,Rakefile,Capfile,*.rake,config.ru} setf ruby
au BufRead,BufNewFile {*.md,*.mkd,*.markdown} setf markdown
au BufRead,BufNewFile {COMMIT_EDITMSG}  setf gitcommit
au BufRead,BufNewFile TDM*C,TDM*H       setf c
au BufRead,BufNewFile *.dox             setf cpp    " Doxygen
au BufRead,BufNewFile *.cshtml          setf cshtml

"" Remove trailing spaces for C/C++ and Vim files
au BufWritePre *                  call s:RemoveTrailingSpace()

au BufRead,BufNewFile todo.txt,done.txt           setf todo
au BufRead,BufNewFile *.mm                        setf xml
au BufRead,BufNewFile *.proto                     setf proto
au BufRead,BufNewFile Jamfile*,Jamroot*,*.jam     setf jam
au BufRead,BufNewFile pending.data,completed.data setf task
au BufRead,BufNewFile *.ipp                       setf cpp
" }}}2

" Filetype related autosettings " {{{2
au FileType diff  setlocal shiftwidth=4 tabstop=4
" au FileType html  setlocal autoindent indentexpr= shiftwidth=2 tabstop=2
au FileType changelog setlocal textwidth=76
" 把-等符号也作为xml文件的有效关键字，可以用Ctrl-N补全带-等字符的属性名
au FileType {xml,xslt} setlocal iskeyword=@,-,\:,48-57,_,128-167,224-235
if executable("tidy")
    au FileType xml        exe 'setlocal equalprg=tidy\ -quiet\ -indent\ -xml\ -raw\ --show-errors\ 0\ --wrap\ 0\ --vertical-space\ 1\ --indent-spaces\ 4'
elseif executable("xmllint")
    au FileType xml        exe 'setlocal equalprg=xmllint\ --format\ --recover\ --encode\ UTF-8\ -'
endif

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
" }}}2

" 根据不同的文件类型设定g<F3>时应该查找的文件 {{{2
au FileType *             let b:vimgrep_files=expand("%:e") == "" ? "**/*" : "**/*." . expand("%:e")
au FileType c,cpp         let b:vimgrep_files="**/*.cpp **/*.cxx **/*.c **/*.h **/*.hpp **/*.ipp"
au FileType php           let b:vimgrep_files="**/*.php **/*.htm **/*.html"
au FileType cs            let b:vimgrep_files="**/*.cs"
au FileType vim           let b:vimgrep_files="**/*.vim"
au FileType javascript    let b:vimgrep_files="**/*.js **/*.htm **/*.html"
au FileType python        let b:vimgrep_files="**/*.py"
au FileType xml           let b:vimgrep_files="**/*.xml"
" }}}2

" 自动打开quickfix窗口 {{{2
" Automatically open, but do not go to (if there are errors) the quickfix /
" location list window, or close it when is has become empty.
"
" Note: Must allow nesting of autocmds to enable any customizations for quickfix
" buffers.
" Note: Normally, :cwindow jumps to the quickfix window if the command opens it
" (but not if it's already open). However, as part of the autocmd, this doesn't
" seem to happen.
autocmd QuickFixCmdPost [^l]* nested botright cwindow
autocmd QuickFixCmdPost    l* nested botright lwindow
" }}}2

" python autocommands {{{2
" 设定python的makeprg
if executable("python2")
    au FileType python setlocal makeprg=python2\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
else
    au FileType python setlocal makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
endif

"au FileType python set errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
au FileType python setlocal errorformat=%[%^(]%\\+('%m'\\,\ ('%f'\\,\ %l\\,\ %v\\,%.%#
au FileType python setlocal smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
" }}}2

" Text file encoding autodetection {{{2
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
" }}}2

" }}}1

" Plugins {{{1

" Brief help
" :NeoBundleList          - list configured bundles
" :NeoBundleInstall(!)    - install(update) bundles
" :NeoBundleClean(!)      - confirm(or auto-approve) removal of unused bundles

" Loading NeoBundle {{{2
filetype off                   " Required!

if has('vim_starting') && match("neobundle", &runtimepath) < 0
    let &runtimepath .= "," . fnamemodify(finddir("bundle/neobundle.vim", &runtimepath), ":p")
endif

call neobundle#begin()

let g:neobundle_default_git_protocol = 'https'

" 使用submodule管理NeoBundle
" " Let NeoBundle manage NeoBundle
" NeoBundle 'Shougo/neobundle.vim'    " 插件管理软件
" }}}2

" Misc {{{2
" vimproc: 用于异步执行命令的插件，被其它插件依赖 {{{3
NeoBundle 'Shougo/vimproc', {
            \ 'build' : {
            \     'windows' : 'echo "Sorry, cannot update vimproc binary file in Windows."',
            \     'cygwin' : 'make -f make_cygwin.mak && touch -t 200001010000.00 autoload/vimproc_unix.so',
            \     'mac' : 'make -f make_mac.mak && touch -t 200001010000.00 autoload/vimproc_unix.so',
            \     'unix' : 'make -f make_unix.mak && touch -t 200001010000.00 autoload/vimproc_unix.so',
            \ },
            \ }
if has("win32") && filereadable(s:vimrc_path . "\\win32\\vimproc_win32.dll")
    let g:vimproc_dll_path = s:vimrc_path . "\\win32\\vimproc_win32.dll"
elseif has("win64") && filereadable(s:vimrc_path . "\\win32\\vimproc_win64.dll")
    let g:vimproc_dll_path = s:vimrc_path . "\\win32\\vimproc_win64.dll"
endif
" }}}3
" }}}2

" Unite {{{2
" unite.vim: Unite主插件，提供\f开头的功能 {{{3
NeoBundleLazy 'Shougo/unite.vim', {
            \ 'commands' : [
            \     { 'name' : 'Unite',
            \       'complete' : 'customlist,unite#complete_source',
            \     },
            \     'UniteWithCursorWord', 'UniteWithInput'],
            \ }
let bundle = neobundle#get('unite.vim')
function! bundle.hooks.on_source(bundle)
    call unite#custom#source(
                \ 'file_rec,file_rec/async,grep',
                \ 'ignore_pattern',
                \ join([
                \ '\%(^\|/\)\.$',
                \ '\~$',
                \ '\.\%(o\|a\|exe\|dll\|bak\|DS_Store\|zwc\|pyc\|sw[po]\|class\|gcno\|gcda\|gcov\)$',
                \ '\%(^\|/\)gcc-[0-9]\+\%(\.[0-9]\+\)*/',
                \ '\%(^\|/\)doc/html/',
                \ '\%(^\|/\)stage/',
                \ '\%(^\|/\)boost\%(\|_\w\+\)/',
                \ '\%(^\|/\)\%(\.hg\|\.git\|\.bzr\|\.svn\|tags\%(-.*\)\?\)\%($\|/\)',
                \ ], '\|'))

    call unite#filters#matcher_default#use(['matcher_fuzzy'])
    call unite#filters#sorter_default#use(['sorter_rank'])
    " let g:unite_source_rec_max_cache_files = 0
    " call unite#custom#source('file_rec,file_rec/async', 'max_candidates', 0)
endfunction

" The prefix key.
nnoremap [unite] <Nop>
xnoremap [unite] <Nop>
nmap <Leader>f [unite]
xmap <Leader>f [unite]

nnoremap [unite2] <Nop>
xnoremap [unite2] <Nop>
nmap <C-\>f [unite2]
xmap <C-\>f [unite2]

let g:unite_enable_start_insert = 1
"let g:unite_enable_short_source_names = 1

let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1

let g:unite_source_session_path = expand('~/.vim/session/')
let g:unite_source_grep_default_opts = "-iHn --color=never"

let g:unite_source_history_yank_enable = 1

let g:unite_winheight = winheight("%") / 2
let g:unite_winwidth = winwidth("%") / 2

if s:ag_path != ""
    " Use ag in unite grep source.
    let g:unite_source_grep_command = s:ag_path
    let g:unite_source_grep_default_opts =
                \ '--line-numbers --nocolor --nogroup --hidden --ignore ''.hg''' .
                \ ' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr''' .
                \ ' --ignore ''gcc-[0-9]+(\.[0-9]+)*'''
    let g:unite_source_grep_recursive_opt = ''
elseif executable('ack-grep')
    " Use ack in unite grep source.
    let g:unite_source_grep_command = 'ack-grep'
    let g:unite_source_grep_default_opts =
                \ '--no-heading --no-color -a -H'
    let g:unite_source_grep_recursive_opt = ''
endif

nnoremap [unite]S :<C-U>Unite source<CR>

nnoremap <silent> [unite]y :<C-U>Unite -buffer-name=yanks history/yank register<CR>
nnoremap <silent> [unite]w :<C-u>UniteWithCursorWord -buffer-name=register buffer file_mru bookmark file<CR>
" nnoremap <silent> [unite]c :<C-u>Unite change jump<CR>
" nnoremap <silent> [unite]R :<C-u>Unite -buffer-name=resume resume<CR>
" nnoremap <silent> [unite]d :<C-u>Unite -buffer-name=files -default-action=lcd directory_mru<CR>
nnoremap <silent> [unite]G :<C-u>Unite grep -buffer-name=search -no-quit<CR>
nnoremap <silent> [unite2]G :<C-u>Unite grep:<C-R>=expand("%:p:h")<CR> -buffer-name=search -no-quit<CR>
" nnoremap <silent> [unite]G :<C-u>UniteWithCursorWord grep -buffer-name=search -no-quit<CR>
"nnoremap <silent> [unite]g :<C-u>Unite grep:<C-R>=expand("%:p:h")<CR> -buffer-name=search -no-quit -start-insert -input=<C-R><C-W><CR>
nnoremap <silent> [unite]g :<C-u>Unite grep:! -buffer-name=search -no-quit -start-insert -input=<C-R><C-W><CR>
nnoremap <silent> [unite2]g :<C-u>Unite grep:<C-R>=expand("%:p:h")<CR> -buffer-name=search -no-quit -start-insert<CR>

nnoremap <silent> [unite]/ :<C-U>Unite -buffer-name=search -start-insert line<CR>
"nnoremap <silent> [unite]B :<C-U>Unite -buffer-name=bookmarks bookmark<CR>
nnoremap <silent> [unite]b :<C-u>Unite -buffer-name=files buffer file:<C-R>=expand("%:p:h")<CR> file/new:<C-R>=expand("%:p:h")<CR> -start-insert<CR>
nnoremap <silent> [unite]c :<C-u>Unite -buffer-name=files file buffer file/new -start-insert<CR>
nnoremap <silent> [unite]C :<C-u>UniteClose<CR>
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
nnoremap <silent> [unite]v :<C-u>UniteVersions status<CR>
nnoremap <silent> [unite]l :<C-u>UniteVersions log<CR>

nnoremap <silent> [unite]r :<C-u>UniteResume<CR>
" nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=files buffer file_rec:! file_mru bookmark<cr><c-u>

nnoremap <silent> [unite]d :<C-u>Unite -buffer-name=files -default-action=lcd directory_mru<CR>
nnoremap <silent> [unite]ma :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
nnoremap <silent> [unite]me :<C-u>Unite output:message<CR>

if s:is_windows
    nnoremap <silent> [unite]f
                \ :<C-u>Unite -buffer-name=files -multi-line
                \ jump_point file_point buffer
                \ file_rec:! file file_mru file/new<CR>
else
    nnoremap <silent> [unite]f
                \ :<C-u>Unite -buffer-name=files -multi-line
                \ jump_point file_point buffer
                \ file_rec/async:! file file_mru file/new<CR>
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
" }}}3
" unite-outline: 提供代码的大纲。通过\fo访问 {{{3
NeoBundleLazy 'Shougo/unite-outline', {
            \ 'unite_sources' : ['outline'],
            \ }
" }}}3
" unite-mark: 列出所有标记点 {{{3
NeoBundleLazy 'tacroe/unite-mark', {
            \ 'unite_sources' : ['mark'],
            \ }
" }}}3
" unite-help: 查找vim的帮助 {{{3
NeoBundleLazy 'shougo/unite-help', {
            \ 'unite_sources' : ['help'],
            \ }
" }}}3
" unite-tag: 跳转到光标下的tag。通过\fT访问 {{{3
NeoBundleLazy 'tsukkee/unite-tag', {
            \ 'unite_sources' : ['tag', 'tag/include', 'tag/file']
            \ }
" }}}3
" unite-colorscheme: 列出所有配色方案 {{{3
NeoBundleLazy 'ujihisa/unite-colorscheme', {
            \ 'unite_sources' : ['colorscheme'],
            \ }
" }}}3
" unite-quickfix: 过滤quickfix窗口（如在编译结果中查找） {{{3
NeoBundleLazy 'osyo-manga/unite-quickfix', {
            \ 'unite_sources' : ['quickfix'],
            \ }
" }}}3
" vim-unite-history: 搜索命令历史 {{{3
NeoBundleLazy 'thinca/vim-unite-history', {
            \ 'unite_sources' : ['history/command', 'history/search']
            \ }
" }}}3
" unite-tselect: 跳转到光标下的tag。通过g]和g<C-]>访问 {{{3
NeoBundleLazy 'eiiches/unite-tselect', {
            \ 'unite_sources' : 'tselect',
            \ }
nnoremap g<C-]> :<C-u>Unite -immediately tselect:<C-r>=expand('<cword>')<CR><CR>
nnoremap g] :<C-u>Unite tselect:<C-r>=expand('<cword>')<CR><CR>
" }}}3
" vim-versions: 支持svn/git，\fv 看未提交的文件列表，\fl 看更新日志 {{{3
NeoBundleLazy 'hrsh7th/vim-versions', {
            \ 'commands' : ['UniteVersions'],
            \ 'unite_sources' : ['versions', 'versions/svn/branch', 'versions/svn/log', 'versions/svn/status', 'versions/svn/branch', 'versions/svn/log', 'versions/svn/status'],
            \ }
" }}}3
" unite-gtags: Unite下调用gtags {{{3
NeoBundleLazy 'hewes/unite-gtags', {
            \ "unite_sources" : ["gtags/completion","gtags/context","gtags/def","gtags/grep","gtags/ref"],
            \ }
if !s:has_global
    NeoBundleDisable 'unite-gtags'
else
    nnoremap <C-\><C-\>s :<C-u>Unite gtags/context<CR>
    nnoremap <C-\><C-\>S :<C-u>Unite gtags/ref:
    nnoremap <C-\><C-\>g :<C-u>Unite gtags/def<CR>
    nnoremap <C-\><C-\>G :<C-u>Unite gtags/def:
    nnoremap <C-\><C-\>t :<C-u>UniteWithCursorWord gtags/grep<CR>
    nnoremap <C-\><C-\>T :<C-u>Unite gtags/grep:
    nnoremap <C-\><C-\>e :<C-u>UniteWithCursorWord gtags/grep<CR>
    nnoremap <C-\><C-\>E :<C-u>Unite gtags/grep:
endif
" }}}3
" }}}2

" Editing {{{2
" vim-alignta: 代码对齐插件。通过\fa访问 {{{3
NeoBundleLazy 'h1mesuke/vim-alignta', {
            \ 'commands' : ['Alignta'],
            \ 'unite_sources' : 'alignta',
            \ }
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
nnoremap <silent> [unite]a :<C-u>Unite alignta:options -no-start-insert<CR>
xnoremap <silent> [unite]a :<C-u>Unite alignta:arguments -no-start-insert<CR>
" }}}3
" YankRing.vim: 在粘贴时，按了p之后，可以按<C-P>粘贴存放在剪切板历史中的内容 {{{3
"NeoBundle 'YankRing.vim'
"    let g:yankring_persist = 0              "不把yankring持久化
"    let g:yankring_share_between_instances = 0
"    let g:yankring_manual_clipboard_check = 1
" }}}3
"" vis: 在块选后（<C-V>进行选择），:B cmd在选中内容中执行cmd {{{3
"NeoBundleLazy 'vis', {
"    \ 'commands' : ['B'],
"    \ }
"" }}}3
" vim-operator-user: 被多个vim-operator插件依赖的插件 {{{3
NeoBundleLazy 'kana/vim-operator-user', {
            \ 'functions' : 'operator#user#define',
            \ }
" }}}3
" vim-operator-replace: 双引号x_{motion} : 把{motion}涉及的内容替换为register x的内容 {{{3
NeoBundleLazy 'kana/vim-operator-replace', {
            \ 'depends' : 'vim-operator-user',
            \ 'mappings' : [
            \     ['nx', '<Plug>(operator-replace)']
            \ ],
            \ }
map _  <Plug>(operator-replace)
" }}}3
" vim-operator-surround: sa{motion}/sd{motion}/sr{motion}：增/删/改括号、引号等 {{{3
NeoBundleLazy 'rhysd/vim-operator-surround', {
            \ 'depends' : 'vim-operator-user',
            \ 'mappings' : ['<Plug>(operator-surround'],
            \ }
" operator mappings
map <silent>sa <Plug>(operator-surround-append)
map <silent>sd <Plug>(operator-surround-delete)
map <silent>sr <Plug>(operator-surround-replace)
" }}}3
" DrawIt: 使用横、竖线画图、制表。\di和\ds分别启、停画图模式。在模式中，hjkl移动光标，方向键画线 {{{3
NeoBundleLazy 'DrawIt', {
            \ 'mappings' : [['n', '<Leader>di']],
            \ 'commands' : ['DIstart', 'DIsngl', 'DIdbl', 'DrawIt'],
            \ }
" }}}3
" vim-easymotion: \\w启动word motion，\\f<字符>启动查找模式 {{{3
if v:version >= '703'
    NeoBundleLazy 'Lokaltog/vim-easymotion', {
                \ 'mappings' : [['n'] + map(
                \     ['f', 'F', 's', 't', 'T', 'w', 'W', 'b', 'B', 'e', 'E', 'ge', 'gE', 'j', 'k', 'n', 'N'],
                \     '"<Leader><Leader>" . v:val')],
                \ }
else
    NeoBundleLazy 'Lokaltog/vim-easymotion', {
                \ 'rev' : 'e41082',
                \ 'mappings' : [['n'] + map(
                \     ['f', 'F', 's', 't', 'T', 'w', 'W', 'b', 'B', 'e', 'E', 'ge', 'gE', 'j', 'k', 'n', 'N'],
                \     '"<Leader><Leader>" . v:val')],
                \ }                                 " \\w启动word motion，\\f<字符>启动查找模式
endif
let g:EasyMotion_startofline = 0
let g:EasyMotion_smartcase = 1
let g:EasyMotion_do_shade = 1

if v:version >= '703'
    let g:EasyMotion_use_upper = 1
    let g:EasyMotion_keys = 'ASDGHKLQWERTYUIOPZXCVBNMFJ;'
endif

hi link EasyMotionTarget Search
hi link EasyMotionTarget2First IncSearch
hi link EasyMotionTarget2Second IncSearch
hi link EasyMotionShade Comment
" }}}3
" " clever-f.vim: 用f/F代替;来查找下一个字符 {{{3
" NeoBundleLazy 'rhysd/clever-f.vim', {
"             \ 'mappings' : [['n', 'f', 'F', 't', 'T']],
"             \ }
" " }}}3
" " glowshi-ft.vim: 增强的f/t {{{3
" NeoBundleLazy 'saihoooooooo/glowshi-ft.vim', {
"             \ 'mappings' : [
"             \     ['n', '<Plug>', 'f', 'F', 't', 'T', ';', ','],
"             \ ],
"             \ }
" " }}}3
" neocomplete: 代码补全插件 {{{3
NeoBundleLazy 'Shougo/neocomplete', {
            \ 'insert' : 1,
            \ }
if !(v:version >= '703' && has('lua'))
    NeoBundleDisable 'neocomplete'
else
    "let g:neocomplcache_enable_debug = 1
    let g:neocomplete#enable_at_startup = 1
    " Disable auto completion, if set to 1, must use <C-x><C-u>
    let g:neocomplete#disable_auto_complete = 0
    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_syntax_length = 3
    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
    let g:neocomplete#enable_auto_select = 0
    let g:neocomplete#auto_completion_start_length = 3

    " Define dictionary.
    let g:neocomplete#sources#dictionary#dictionaries = {
                \ 'default' : '',
                \ 'vimshell' : $HOME.'/.vimshell_hist',
                \ 'scheme' : $HOME.'/.gosh_completions'
                \ }

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplete#undo_completion()
    inoremap <expr><C-l>     neocomplete#complete_common_string()

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <expr><CR>  neocomplete#smart_close_popup() . "\<CR>"
    " <TAB>: completion.
    "inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y>  neocomplete#close_popup()
    inoremap <expr><C-e>  neocomplete#cancel_popup()

    " Enable omni completion.
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    if neobundle#is_installed("jedi-vim")
        autocmd FileType python setlocal omnifunc=jedi#completions
        let g:jedi#completions_enabled = 0
        let g:jedi#auto_vim_configuration = 0 " 解决neocomplete下自动补第一个候选项的问题
    else
        autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    endif

    " 使得neocomplete能和clang_complete共存，见neocomplete帮助的FAQ
    if !exists('g:neocomplete#force_omni_input_patterns')
        let g:neocomplete#force_omni_input_patterns = {}
    endif
    let g:neocomplete#force_overwrite_completefunc = 1
    let g:neocomplete#force_omni_input_patterns.c =
                \ '[^.[:digit:] *\t]\%(\.\|->\)\w*'
    let g:neocomplete#force_omni_input_patterns.cpp =
                \ '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
    let g:neocomplete#force_omni_input_patterns.objc =
                \ '[^.[:digit:] *\t]\%(\.\|->\)\w*'
    let g:neocomplete#force_omni_input_patterns.objcpp =
                \ '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
    let g:neocomplete#force_omni_input_patterns.python =
                \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
endif
" }}}3
" neocomplcache: 代码补全插件 {{{3
NeoBundleLazy 'Shougo/neocomplcache', {
            \ 'insert' : 1,
            \ }
if v:version >= '703' && has('lua')
    NeoBundleDisable 'neocomplete'
else
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
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    if neobundle#is_installed("jedi-vim")
        autocmd FileType python setlocal omnifunc=jedi#completions
        let g:jedi#completions_enabled = 0
        let g:jedi#auto_vim_configuration = 0 " 解决neocomplete下自动补第一个候选项的问题
    else
        autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    endif

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
    let g:neocomplcache_force_omni_patterns.python =
                \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
endif
" }}}3
" context_filetype.vim: 在文件中根据上下文确定当前的filetype，如识别出html中内嵌js、css {{{3
NeoBundleLazy 'Shougo/context_filetype.vim', {
            \ }
" }}}3
" neosnippet: 代码模板引擎 {{{3
NeoBundleLazy 'Shougo/neosnippet', {
            \ 'insert' : 1,
            \ 'filetypes' : 'neosnippet',
            \ 'depends' : ['context_filetype.vim'],
            \ 'commands' : ['NeoSnippetEdit'],
            \ 'mappings' : ['<Plug>(neosnippet_'],
            \ 'unite_sources' : ['snippet', 'neosnippet/user', 'neosnippet/runtime'],
            \ }
let g:neosnippet#snippets_directory = fnamemodify(finddir("snippets", &runtimepath), ":p")
let g:neosnippet#snippets_directory .= "," . fnamemodify(finddir("/neosnippet/autoload/neosnippet/snippets", &runtimepath), ":p")

imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" " SuperTab like snippets behavior.
" imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
"             \ "\<Plug>(neosnippet_expand_or_jump)"
"             \: pumvisible() ? "\<C-n>" : "\<TAB>"
" smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
"             \ "\<Plug>(neosnippet_expand_or_jump)"
"             \: "\<TAB>"

" For snippet_complete marker.
if has('conceal')
    set conceallevel=2 concealcursor=i
endif
" }}}3
" neomru.vim: 最近访问的文件 {{{3
NeoBundle 'Shougo/neomru.vim'
" }}}3
" neosnippet-snippets: 代码模板 {{{3
NeoBundle 'Shougo/neosnippet-snippets'
" }}}3
" vim-bufsurf: :BufSurfForward/:BufSurfBack跳转到本窗口的下一个、上一个buffer（增强<C-I>/<C-O>） {{{3
NeoBundleLazy 'ton/vim-bufsurf', {
            \ 'commands' : ['BufSurfForward', 'BufSurfBack'],
            \ }
" g<C-I>/g<C-O>直接跳到不同的buffer
nnoremap <silent> g<C-I> :BufSurfForward<CR>
nnoremap <silent> g<C-O> :BufSurfBack<CR>
" }}}3
"NeoBundle 'VimIM'                                   " 中文输入法
" vim-indent-guides: 标记出各缩进块。\ig切换 {{{3
NeoBundleLazy 'nathanaelkane/vim-indent-guides', {
            \ 'commands':['IndentGuidesToggle','IndentGuidesEnable','IndentGuidesDisable'],
            \ 'mappings':['<Leader>ig'],
            \ }
let g:indent_guides_auto_colors = 0
let g:indent_guides_start_level = 2
"let g:indent_guides_guide_size = 1
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=black
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=darkgray ctermbg=8
" }}}3
" vim-niceblock: 增强对块选操作的支持 {{{3
NeoBundleLazy 'kana/vim-niceblock', {
            \ 'mappings' : ['v', 'I', 'A'],
            \ }
" }}}3
" Mark--Karkat: 可同时标记多个mark。\M显隐所有，\N清除所有Mark。\m标识当前word {{{3
NeoBundleLazy 'vernonrj/Mark--Karkat', {
            \ 'mappings' : ['<Plug>(Mark', '<Leader>m', '<Leader>r', '<Leader>n', '<Leader>*', '<Leader>#', '<Leader>/', '<Leader>?', '*', '#'],
            \ }
if !(v:version >= '701')
    NeoBundleDisable 'Mark--Karkat'
else
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
" }}}3
" vim-abolish: :%S/box{,es}/bag{,s}/g进行单复数、大小写对应的查找 {{{3
NeoBundleLazy 'tpope/vim-abolish', {
            \ 'mappings' : [
            \   ['n', '<Plug>Coerce'],
            \   ['n', 'cr'],
            \ ],
            \ 'commands' : [ 'Abolish', 'Subvert', 'S' ],
            \ }
" }}}3
" }}}2

" Text object {{{2
" vim-textobj-user: 可自定义motion {{{3
NeoBundle 'kana/vim-textobj-user'
" }}}3
" vim-textobj-indent: 增加motion: ai ii（含更深缩进） aI iI（仅相同缩进） {{{3
NeoBundle 'kana/vim-textobj-indent'
" }}}3
" vim-textobj-line: 增加motion: al il {{{3
NeoBundle 'kana/vim-textobj-line'
" }}}3
" vim-textobj-function: 增加motion: if/af/iF/aF 选择一个函数 {{{3
NeoBundle 'kana/vim-textobj-function'
" }}}3
" CamelCaseMotion: 增加,w ,b ,e 可以处理大小写混合或下划线分隔两种方式的单词 {{{3
NeoBundle 'bkad/CamelCaseMotion'
" }}}3
" vim-textobj-comment: 增加motion: ac ic {{{3
NeoBundle 'thinca/vim-textobj-comment'
" }}}3
" }}}2

" Programming {{{2
" NeoBundle 'tyru/current-func-info.vim'

" echofunc: 在插入模式下输入(时，会在statusline显示函数的签名，对于有多个重载的函数，可通过<A-->/<A-=>进行切换 {{{3
NeoBundleLazy 'mbbill/echofunc', {
            \ 'filetypes' : ['c', 'cpp'],
            \ }
if s:has_global
    " 启用global后，将不用ctags，因此echofunc.vim会失效
    NeoBundleDisable 'echofunc'
endif
" }}}3
" 为函数插入Doxygen注释。在函数名所在行输入 :Dox 即可 {{{3
NeoBundleLazy 'DoxygenToolkit.vim', {
            \ 'commands' : ['Dox', 'DoxLic', 'DoxAuthor', 'DoxUndoc', 'DoxBlock'],
            \ }
let g:DoxygenToolkit_briefTag_pre="@brief "
let g:DoxygenToolkit_paramTag_pre="@param[in] "
let g:DoxygenToolkit_returnTag="@return "
" }}}3
" 记录代码走查意见，\ic激活。可通过 cfile <文件名> 把记录走查意见的文件导入 quickfix 列表 {{{3
NeoBundleLazy 'CodeReviewer.vim', {
            \ 'commands' : ['CheckReview'],
            \ 'mappings' : ['<Leader>ic'],
            \ }
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
" }}}3
" HiCursorWords: 高亮与光标下word一样的词 {{{3
NeoBundle 'OrelSokolov/HiCursorWords'
let g:HiCursorWords_delay = 200
let g:HiCursorWords_hiGroupRegexp = ''
let g:HiCursorWords_debugEchoHiName = 0
" }}}3
" tcomment_vim: 注释工具。gc{motion}/gcc/<C-_>等 {{{3
NeoBundle 'tomtom/tcomment_vim'
" }}}3
" gtags.vim: 直接调用gtags查找符号 {{{3
NeoBundleLazy 'gtags.vim', {
            \ "commands" : ["Gtags","GtagsCursor","Gozilla"],
            \ }
if !s:has_global
    NeoBundleDisable 'gtags.vim'

    " 不使用gtags的话，如果有cscope就使用cscope
    if has("cscope") " {{{
        " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
        set cscopetag

        " check cscope for definition of a symbol before checking ctags: set to 1
        " if you want the reverse search order.
        set csto=0

        set nocscopeverbose

        " add any cscope database in current directory
        if filereadable("cscope.out")
            cs add cscope.out
            " else add the database pointed to by environment variable
        elseif $CSCOPE_DB != ""
            cs add $CSCOPE_DB
        endif

        " show msg when any other cscope db added
        set cscopeverbose

        set cscopequickfix=s-,c-,d-,i-,t-,e-

        " <C-\>小写在当前窗口打开光标下的符号
        nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
        nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
        nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
        nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
        nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
        nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
        nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
        nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

        " <C-\>大写在当前窗口打开命令行
        nmap <C-\>S :cs find s<SPACE>
        nmap <C-\>G :cs find g<SPACE>
        nmap <C-\>C :cs find c<SPACE>
        nmap <C-\>T :cs find t<SPACE>
        nmap <C-\>E :cs find e<SPACE>
        nmap <C-\>F :cs find f<SPACE>
        nmap <C-\>I :cs find i ^
        nmap <C-\>D :cs find d<SPACE>
    endif " }}}
else
    " <C-\>小写在当前窗口打开光标下的符号
    nmap <C-\>s :Gtags -sr <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :Gtags --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :Gtags -g --literal --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :Gtags -g --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=expand("<cword>")<CR><CR>
    " 如果光标在定义上，就找引用，如果在引用上就找定义
    nmap <C-\><C-]> :GtagsCursor<CR>

    " <C-\>大写在当前窗口打开命令行
    nmap <C-\>S :Gtags -sr<SPACE>
    nmap <C-\>G :Gtags<SPACE>
    nmap <C-\>T :Gtags -g --literal<SPACE>
    nmap <C-\>E :Gtags -g<SPACE>

    function! s:GtagsAutoUpdate()
        let l:result = system(s:global_command . " -u --single-update=\"" . expand("%") . "\"")
    endfunction

    autocmd! BufWritePost * call s:GtagsAutoUpdate()
endif
" }}}3
" slimux: 配合tmux的REPL工具，可以把缓冲区中的内容拷贝到tmux指定pane下运行。\ss发送当前行或选区，\sp提示输入命令，\sa重复上一命令，\sk重复上个key序列 {{{3
NeoBundleLazy 'epeli/slimux', {
            \ 'commands' : [
            \ 'SlimuxREPLSendLine', 'SlimuxREPLSendSelection', 'SlimuxREPLSendLine', 'SlimuxREPLSendBuffer', 'SlimuxREPLConfigure',
            \ 'SlimuxShellRun', 'SlimuxShellPrompt', 'SlimuxShellLast', 'SlimuxShellConfigure',
            \ 'SlimuxSendKeysPrompt', 'SlimuxSendKeysLast', 'SlimuxSendKeysConfigure' ],
            \ }
if !executable("tmux")
    NeoBundleDisable 'slimux'
else
    nnoremap [slimux] <Nop>
    xnoremap [slimux] <Nop>
    nmap <Leader>s [slimux]
    xmap <Leader>s [slimux]

    map  [slimux]s :SlimuxREPLSendLine<CR>
    vmap [slimut]s :SlimuxREPLSendSelection<CR>
    map  [slimux]p :SlimuxShellPrompt<CR>
    map  [slimux]a :SlimuxShellLast<CR>
    map  [slimux]k :SlimuxSendKeysLast<CR>
endif
" }}}3
"" Intelligent_Tags: 自动为当前文件及其包含的文件生成tags {{{3
"NeoBundle 'bahejl/Intelligent_Tags'
"
"    let g:Itags_Depth=3    " 缺省是1，当前文件及其包含的文件。-1表示无穷层
"    let g:Itags_Ctags_Flags="--c++-kinds=+p --fields=+iaS --extra=+q -R"
"    let g:Itags_header_mapping= {'h':['c', 'cpp', 'c++']}
"if executable("ctags")
"    NeoBundle 'thawk/Intelligent_Tags'              " 自动扫描所依赖的头文件，生成tags文件
"    "NeoBundle 'AutoTag'
"endif
"" }}}3
" tagbar: 列出文件中所有类和方法。用<F9>调用 {{{3
NeoBundleLazy 'majutsushi/tagbar', {
            \ 'commands' : ['TagbarToggle','TagbarCurrentTag'],
            \ }
let g:tagbar_left = 1

nnoremap <silent> g<F9> :<C-U>TagbarCurrentTag fs<CR>
nnoremap <silent> <F9> :<C-U>TagbarToggle<CR>

let g:tagbar_type_jam = {
            \ 'ctagstype' : 'jam',
            \ 'kinds' : [
            \ 's:Table of Contents',
            \ ],
            \ 'sort' : 0,
            \ 'deffile' : expand('<sfile>:p:h') . '/ctags/jam.cnf',
            \ }

let g:tagbar_type_neosnippet = {
            \ 'ctagstype' : 'neosnippet',
            \ 'kinds' : [
            \ 's:snippet',
            \ ],
            \ 'sort' : 1,
            \ 'deffile' : expand('<sfile>:p:h') . '/ctags/neosnippet.cnf',
            \ }
let g:tagbar_type_asciidoc = {
            \ 'ctagstype' : 'asciidoc',
            \ 'kinds' : [
            \ 's:Table of Contents'
            \ ],
            \ 'sort' : 0,
            \ 'deffile' : expand('<sfile>:p:h') . '/ctags/asciidoc.cnf',
            \ }
let g:tagbar_type_markdown = {
            \ 'ctagstype' : 'markdown',
            \ 'kinds' : [
            \ 's:Table of Contents'
            \ ],
            \ 'sort' : 0,
            \ 'deffile' : expand('<sfile>:p:h') . '/ctags/markdown.cnf',
            \ }
" }}}3
" vcscommand.vim: SVN前端。\cv进行diff，\cn查看每行是谁改的，\cl查看修订历史，\cG关闭VCS窗口回到源文件 {{{3
NeoBundleLazy 'vcscommand.vim', {
            \ 'mappings' : [
            \     '<Plug>VCS',
            \     [ 'n', '<Leader>ca', '<Leader>cc', '<Leader>cD', '<Leader>cd', '<Leader>cG', '<Leader>cg', '<Leader>ci', '<Leader>cL', '<Leader>cl', '<Leader>cN', '<Leader>cn', '<Leader>cq', '<Leader>cr', '<Leader>cs', '<Leader>cU', '<Leader>cu', '<Leader>cv'],
            \ ],
            \ 'commands' : ['VCSAdd', 'VCSAnnotate', 'VCSBlame', 'VCSCommit', 'VCSDelete', 'VCSDiff', 'VCSGotoOriginal', 'VCSInfo', 'VCSLock', 'VCSLog', 'VCSRemove', 'VCSRevert', 'VCSReview', 'VCSStatus', 'VCSUnlock', 'VCSUpdate', 'VCSVimDiff', 'VCSCommandDisableBufferSetup', 'VCSCommandEnableBufferSetup', 'VCSReload'],
            \ }
nnoremap <Leader>cp :VCSVimDiff PREV<CR>
" }}}3
" vim-fugitive: GIT前端 {{{3
NeoBundle 'tpope/vim-fugitive'
" }}}3
"" vim-snowdrop: {{{3
"NeoBundleLazy 'osyo-manga/vim-snowdrop', {
"    \ 'filetypes' : ['c', 'cpp'],
"    \ }
"    " set libclang directory path
"    let g:snowdrop#libclang_directory = s:libclang_path
"
"    " Enable code completion in neocomplete.vim.
"    let g:neocomplete#sources#snowdrop#enable = 1
"
"    " Not skip
"    let g:neocomplete#skip_auto_completion_time = ""
" }}}3
" clang_complete: 使用clang编译器进行上下文补全 {{{3
NeoBundleLazy 'Rip-Rip/clang_complete', {
            \ 'filetypes' : ['c', 'cpp'],
            \ }
if s:libclang_path == "" && !executable('clang')
    NeoBundleDisable 'clang_complete'
else
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

    " 使用NeoComplete触发补全
    let g:clang_complete_auto = 0
    let g:clang_auto_select = 0
    let g:clang_complete_copen = 0  " open quickfix window on error.
    let g:clang_hl_errors = 1       " highlight the warnings and errors the same way clang
    "let g:clang_jumpto_declaration_key = '<C-]>'
    "let g:clang_jumpto_back_key = '<C-T>'

    if s:libclang_path != ""
        let g:clang_use_library = 1
        let g:clang_library_path = s:libclang_path
    endif
endif
" }}}3
"" vim-clang: 使用clang编译器进行上下文补全 {{{3
" if executable('clang')    " vim-clang比使用clang_complete慢
"     NeoBundleLazy 'justmao945/vim-clang', {
"                 \ 'filetypes' : ['c', 'cpp'],
"                 \ }
"     " 使用NeoComplete触发补全
"     let g:clang_auto = 0
"     if s:libclang_path != ""
"         if !exists('g:clang_cpp_options')
"             let g:clang_cpp_options = ''
"         endif
"         let g:clang_cpp_options .= " -I " . s:libclang_path . "/clang/3.4/include/"
"         echomsg g:clang_cpp_options
"     endif
" endif
"" }}}3
" vim-clang-format: 使用clang编译器进行上下文补全 {{{3
NeoBundleLazy 'rhysd/vim-clang-format', {
            \ 'commands' : ['ClangFormat'],
            \ 'mappings' : ['<Plug>(operator-clang-format'],
            \ }
if !executable('clang-format')
    NeoBundleDisable 'clang-format'
else
    let g:clang_format#code_style = 'google'
    let g:clang_format#style_options = {
                \ "AccessModifierOffset" : -4,
                \ "AllowShortIfStatementsOnASingleLine" : "false",
                \ "AllowShortLoopsOnASingleLine" : "false",
                \ "BreakBeforeBinaryOperators" : "true",
                \ "BinPackParameters" : "false",
                \ "BreakBeforeBraces" : "Allman",
                \ "ColumnLimit" : "90",
                \ "DerivePointerBinding" : "false",
                \ "IndentCaseLabels" : "false",
                \ "IndentWidth" : "4",
                \ }

    " map to <Leader>cf in C++ code
    autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
    autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
    " if you install vim-operator-user
    autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
endif
" }}}3
" syntastic: 保存文件时自动进行合法检查。:SyntasticCheck 执行检查， :Errors 打开错误列表 {{{3
NeoBundle 'scrooloose/syntastic'
" let g:syntastic_mode_map = {
"             \ 'mode': 'active',
"             \ 'active_filetypes': ['ruby', 'php', 'python'],
"             \ 'passive_filetypes': ['cpp'] }

let g:syntastic_mode_map = {
            \ "mode": "active",
            \ "active_filetypes": [],
            \ "passive_filetypes": ["asciidoc"] }

let g:syntastic_cpp_checkers = ['cpplint']
" 0: 不会自动打开、关闭 1: 自动打开及关闭 2: 没错误时自动关闭，但不会自动打开
let g:syntastic_auto_loc_list=2
if executable('python2')
    let g:syntastic_python_python_exec = 'python2'
endif
" }}}3
" vim-csharp: C#文件的支持 {{{3
NeoBundleLazy 'OrangeT/vim-csharp', {
            \ 'filetypes' : ['csharp'],
            \ }
" }}}3
" vim-cpplint: <F7>执行cpplint检查（要求PATH中能找到cpplint.py） {{{3
NeoBundleLazy 'funorpain/vim-cpplint', {
            \ 'filetyhpes' : ['c', 'cpp'],
            \ 'disabled' : !executable("cpplint.py"),
            \ }
" }}}3
" jedi-vim: 强大的Python补全、pydoc查询工具。 \g：跳到变量赋值点或函数定义；\d：函数定义；K：查询文档；\r：改名；\n：列出对使用一个名称的所有位置 {{{3
NeoBundleLazy 'davidhalter/jedi-vim', {
            \ 'filetypes' : ['python', 'python3'],
            \ }
let g:jedi#popup_select_first = 0   " 不要自动选择第一个候选项
" }}}3
" wandbox-vim: 在http://melpon.org/wandbox/上运行当前缓冲区的C++代码 {{{3
NeoBundleLazy 'rhysd/wandbox-vim', {
            \ 'commands' : [
            \    {'name' : 'Wandbox',      'complete' : 'customlist,wandbox#complete_command'},
            \    {'name' : 'WandboxAsync', 'complete' : 'customlist,wandbox#complete_command'},
            \    {'name' : 'WandboxSync',  'complete' : 'customlist,wandbox#complete_command'},
            \    'WandboxAbortAsyncWorks',
            \    'WandboxOpenBrowser',
            \    'WandboxOptionList',
            \    'WandboxOptionListAsync',
            \ ],
            \ 'functions' : 'wandbox#',
            \ }
let g:wandbox#echo_command = 'echomsg'
noremap <Leader>wb :<C-u>Wandbox<CR>

" Set default compilers for each filetype
let g:wandbox#default_compiler = get(g:, 'wandbox#default_compiler', {
            \ 'cpp' : 'gcc-head,clang-head',
            \ 'ruby' : 'mruby'
            \ })

" Set default options for each filetype.  Type of value is string or list of string
let g:default_options = get(g:, 'wandbox#default_options', {
            \   'cpp' : 'warning,optimize,boost-1.56,c++1y',
            \   'haskell' : [
            \     'haskell-warning',
            \     'haskell-optimize',
            \   ],
            \ })

" Set extra options for compilers if you need
let g:wandbox#default_extra_options = get(g:, 'wandbox#default_extra_options', {
            \   'clang-head' : '-O3 -Werror',
            \ })
" }}}3
" vim-scriptease: 辅助编写vim脚本的工具 {{{3
NeoBundleLazy 'tpope/vim-scriptease', {
            \ 'filetypes' : ['vim', 'help'],
            \ 'commands' : [
            \     { 'name' : 'PP', 'complete' : 'expression' },
            \     { 'name' : 'PPmsg', 'complete' : 'expression' },
            \     { 'name' : 'Verbose', 'complete' : 'command' },
            \     { 'name' : 'Time', 'complete' : 'command' },
            \     'Scriptnames', 'Runtime', 'Disarm', 'Ve', 'Vedit', 'Vopen', 'Vsplit', 'Vvsplit', 'Vtabedit', 'Vpedit', 'Vread', 'Console',
            \ ],
            \ }
" }}}3
" Conque-GDB: 在vim中进行gdb调试 {{{3
NeoBundleLazy 'Conque-GDB', {
            \ 'disabled' : !executable("gdb"),
            \ 'commands' : [
            \     { 'name' : 'ConqueGdb', 'complete' : 'file' },
            \     { 'name' : 'ConqueGdbSplit', 'complete' : 'file' },
            \     { 'name' : 'ConqueGdbVSplit', 'complete' : 'file' },
            \     { 'name' : 'ConqueGdbTab', 'complete' : 'file' },
            \     { 'name' : 'ConqueGdbExe', 'complete' : 'file' },
            \     { 'name' : 'ConqueGdbDelete', 'complete' : '' },
            \     { 'name' : 'ConqueGdbCommand', 'complete' : '' },
            \     { 'name' : 'ConqueTerm', 'complete' : 'shellcmd' },
            \     { 'name' : 'ConqueTermSplit', 'complete' : 'shellcmd' },
            \     { 'name' : 'ConqueTermVSplit', 'complete' : 'shellcmd' },
            \     { 'name' : 'ConqueTermTab', 'complete' : 'shellcmd' },
            \ ],
            \ }
" ,r - run
" ,c - continue
" ,n - next
" ,s - step
" ,p - print 光标下的标识符
" ,b - toggle breakpoint
" ,f - finish
" ,t - backtrace
let g:ConqueGdb_Leader = ','
" }}}3
" }}}2

" Language {{{2
" csv.vim: 增加对CSV文件（逗号分隔文件）的支持 {{{3
NeoBundleLazy 'csv.vim', {
            \ 'filetypes' : ['csv'],
            \ }
" }}}3
" vim-orgmode: 对emacs的org文件的支持 {{{3
NeoBundleLazy 'jceb/vim-orgmode', {
            \ 'depends' : [
            \   'NrrwRgn',
            \   'speeddating.vim',
            \ ],
            \ 'filetypes' : ['org'],
            \ }
" }}}3
" Emmet.vim: 快速编写XML文件。如 div>p#foo$*3>a 再按 <C-Y>, {{{3
NeoBundleLazy 'Emmet.vim', {
            \ 'filetypes' : ['xml','html','css','sass','scss','less'],
            \ 'mappings' : ['<Plug>(Emmet'],
            \ 'commands' : ['EmmetInstall'],
            \ }
augroup custom_Emmet
    autocmd FileType {xml,html,css,sass,scss,less} imap <buffer> <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")
augroup END
" }}}3
" wps.vim: syntax highlight for RockBox wps file {{{3
NeoBundleLazy 'wps.vim', {
            \ 'filetypes' : ['wps'],
            \ }
if !(has("win32") || has("win64"))
    NeoBundleDisable 'wps.vim'
else
    au BufRead,BufNewFile *.wps,*.sbs,*.fms setf wps
endif
" }}}3
NeoBundleLazy 'lbdbq', {
            \ 'mappings' : ['<LocalLeader>lb'],
            \ }                                             " 支持lbdb
NeoBundleLazy 'othree/xml.vim', {
            \ 'filetypes' : ['xml'],
            \ }                                             " 辅助编写XML文件
"NeoBundle 'tmhedberg/SimpylFold'
NeoBundleLazy 'hynek/vim-python-pep8-indent', {
            \ 'filetypes' : ['python', 'python3'],
            \ }
NeoBundleLazy 'gprof.vim', {
            \ 'filetypes' : ['gprof'],
            \ }                                             " 对gprof文件提供语法高亮
NeoBundleLazy 'elzr/vim-json', {
            \ 'filetypes' : ['json'],
            \ 'filename_patterns' : ['.*\.jsonp\?'],
            \ }                                             " 对JSON文件提供语法高亮
NeoBundleLazy 'othree/javascript-libraries-syntax.vim', {
            \ 'filetypes' : ['javascript', 'js'],
            \ }                                             " Javascript语法高亮
NeoBundleLazy 'po.vim', {
            \ 'filetypes' : ['po'],
            \ 'filename_patterns' : ['.*\.pot\?'],
            \ }                                             " 用于编辑PO语言包文件。
" }}}3
" timl: VimL编写的Clojure语言 {{{3
NeoBundleLazy 'tpope/timl', {
            \ 'filetypes' : ['timl'],
            \ 'filename_patterns' : ['.*\.tim\?'],
            \ 'commands' : [
            \     'TLrepl', 'TLscratch', 'TLcopen',
            \     { 'name' : 'TLinspect', 'complete' : 'expression' },
            \     { 'name' : 'TLeval', 'complete' : 'customlist,timl#interactive#input_complete' },
            \     { 'name' : 'TLsource', 'complete' : 'file' },
            \ ],
            \ }
if has('win32') && !exists('$APPCACHE')
    " 设置缓存目录
    let $APPCACHE=$HOME . '/.cache'
endif
" }}}3
" }}}2

" Colors {{{2
" vim-colors-solarized: Solarized配色方案 {{{3
NeoBundle 'altercation/vim-colors-solarized'
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

if !s:is_gui " 在终端模式下，使用16色（终端需要使用solarized配色方案才能得到所要的效果）
    set t_Co=16
end

syntax enable
if $COLORFGBG == ""
    " 如果没有设置环境变量COLORFGBG，使用深色
    set background=dark
endif
" let g:solarized_termcolors=256
" }}}3
" Zenburn: Zenburn配色方案 {{{3
NeoBundle 'Zenburn'
" }}}3
" }}}2

" Files {{{2
" FSwitch: 在头文件和CPP文件间进行切换。用:A调用。\ol在右边分隔一个窗口显示，\of当前窗口 {{{3
NeoBundleLazy 'FSwitch', {
            \ 'functions' : ['FSwitch'],
            \ 'commands' : ['FSHere','FSRight','FSSplitRight','FSLeft','FSSplitLeft','FSAbove','FSSplitAbove','FSBelow','FSSplitBelow'],
            \ }
let g:fsnonewfiles=1
" 可以用:A在.h/.cpp间切换
command! A :call FSwitch('%', '')
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
" }}}3
" LargeFile: 在打开大文件时，禁用语法高亮以提供打开速度 {{{3
NeoBundle 'LargeFile'
" }}}3
" vinarise: Hex Editor {{{3
NeoBundleLazy 'Shougo/vinarise', {
            \ 'commands' : ['Vinarise','VinariseDump','VinariseScript2Hex'],
            \ }
" }}}3
" }}}2

" Utils {{{2
" vimfiler: 文件管理器 {{{3
NeoBundleLazy 'Shougo/vimfiler', {
            \ 'depends' : 'Shougo/unite.vim',
            \ 'commands' : [
            \               { 'name' : 'VimFiler',
            \                 'complete' : 'customlist,vimfiler#complete' },
            \               { 'name' : 'VimFilerTab',
            \                 'complete' : 'customlist,vimfiler#complete' },
            \               { 'name' : 'VimFilerExplorer',
            \                 'complete' : 'customlist,vimfiler#complete' },
            \               { 'name' : 'Edit',
            \                 'complete' : 'customlist,vimfiler#complete' },
            \               { 'name' : 'Write',
            \                 'complete' : 'customlist,vimfiler#complete' },
            \               'Read', 'Source'],
            \ 'mappings' : ['<Plug>(vimfiler_'],
            \ 'explorer' : 1,
            \ }
" 文件管理器，通过 :VimFiler 启动。
" c : copy, m : move, r : rename,
let g:vimfiler_as_default_explorer = 1
" }}}3
" vimshell: Shell，:VimShell {{{3
NeoBundleLazy 'Shougo/vimshell', {
            \ 'commands' : [{ 'name' : 'VimShell',
            \                 'complete' : 'customlist,vimshell#complete'},
            \               'VimShellExecute', 'VimShellInteractive',
            \               'VimShellTerminal', 'VimShellPop'],
            \ 'mappings' : ['<Plug>(vimshell_'],
            \ }
" }}}3
" vim-eunuch: Remove/Unlink/Move/SudoEdit/SudoWrite等UNIX命令 {{{3
NeoBundleLazy 'tpope/vim-eunuch', {
            \ 'commands' : [
            \   'Unlink', 'Remove', 'Rename', 'Chmod', 'SudoWrite', 'Wall', 'W',
            \   { 'name' : 'Move', 'complete' : 'file' },
            \   { 'name' : 'File', 'complete' : 'file' },
            \   { 'name' : 'Locate', 'complete' : 'file' },
            \   { 'name' : 'Mkdir', 'complete' : 'dir' },
            \   { 'name' : 'SudoEdit', 'complete' : 'file' },
            \ ],
            \ }
" }}}3
" quickrun.vim: 快速运行代码片段 {{{3
NeoBundleLazy 'quickrun.vim', {
            \ 'mappings' : [['nxo', '<Plug>(quickrun)']],
            \ 'commands' : ['QuickRun'],
            \ }
nmap ,r <Plug>(quickrun)
" }}}3
" scratch.vim: 打开一个临时窗口。gs/gS/:Scratch {{{3
NeoBundleLazy 'mtth/scratch.vim', {
            \ 'commands' : ['Scratch','ScratchInsert','ScratchSelection'],
            \ 'mappings' : [['v','gs'], ['v','gS']],
            \ }
" }}}3
" undotree: 列出修改历史，方便undo到一个特定的位置 {{{3
NeoBundleLazy 'mbbill/undotree', {
            \ 'commands' : ['UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus'],
            \ }
nnoremap <silent> <F5> :UndotreeToggle<CR>
" }}}3
" vim-repeat: 把.能重复的操作扩展到一些插件中的操作 {{{3
NeoBundleLazy 'tpope/vim-repeat', {
            \ 'mappings' : ['.'],
            \ }
" }}}3
" AutoFenc: 自动判别文件的编码 {{{3
NeoBundle 'AutoFenc'
" }}}3
"" vim-sleuth: 自动检测文件的'shiftwidth'和'expandtab' {{{3
"NeoBundle 'tpope/vim-sleuth'
"" }}}3
" vim-dispatch: 可以用:Make、:Dispatch等，通过tmux窗口、后台窗口等手段异步执行命令 {{{3
NeoBundleLazy 'tpope/vim-dispatch', {
            \ 'commands' : [
            \     { 'name' : 'Dispatch', 'complete' : 'customlist,dispatch#command_complete' },
            \     { 'name' : 'FocusDispatch', 'complete' : 'customlist,dispatch#command_complete' },
            \     { 'name' : 'Make', 'complete' : 'customlist,dispatch#make_complete' },
            \     { 'name' : 'Spawn', 'complete' : 'customlist,dispatch#command_complete' },
            \     { 'name' : 'Start', 'complete' : 'customlist,dispatch#command_complete' },
            \     'Copen',
            \ ],
            \ }
" }}}3
" vim-airline: 增强的statusline {{{3
NeoBundle 'bling/vim-airline'
let bundle = neobundle#get('vim-airline')
function! bundle.hooks.on_source(bundle)
    " 把section a的第1个part从mode改为bufnr() + mode
    call airline#parts#define_raw('bufnr_mode', '%{bufnr("%") . " " . airline#parts#mode()}')
    let g:airline_section_a = airline#section#create_left(['bufnr_mode', 'paste', 'iminsert'])
    if executable("svn")
        call airline#parts#define_function('mybranch', 'MyBranch')
        let g:airline_section_b = airline#section#create(['hunks', 'mybranch'])
    endif
endfunction

" if neobundle#is_installed("vcscommand.vim")
"     let g:airline#extensions#branch#use_vcscommand = 1
" endif

" let g:airline_left_sep = '\u25ba'
" let g:airline_right_sep = '\u25c4'

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

if &encoding == "utf-8"
    " 开启powerline字体，可在 https://github.com/runsisi/consolas-font-for-powerline
    " 找到增加了特定字符的Consolas字体。
    " https://github.com/Lokaltog/powerline-fonts 在更多免费的字体
    let g:airline_powerline_fonts=1

    if s:is_windows
        let g:airline_symbols.whitespace = " "
    else
        let g:airline_symbols.whitespace = "\u039e"
        let g:airline_symbols.paste = "\u2225"
    endif
else
    let g:airline_left_sep = " "
    let g:airline_left_alt_sep = "|"
    let g:airline_right_sep = " "
    let g:airline_right_alt_sep = "|"
    let g:airline_symbols.branch = ""
    let g:airline_symbols.readonly = "RO"
    let g:airline_symbols.linenr = "LN"
    let g:airline_symbols.paste = "PASTE"
    let g:airline_symbols.whitespace = " "

    " let g:airline_left_sep = "\ue0b0"
    " let g:airline_left_alt_sep = "\ue0b1"
    " let g:airline_right_sep = "\ue0b2"
    " let g:airline_right_alt_sep = "\ue0b3"

    " let g:airline_symbols.branch = "\ue0a0"
    " let g:airline_symbols.readonly = "\ue0a2"
    " let g:airline_symbols.linenr = "\ue0a1"
    " let g:airline_symbols.paste = "\u22256"
endif

set noshowmode

let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0
let g:vimshell_force_overwrite_statusline = 0

" 显示tabline
let g:airline#extensions#tabline#enabled = 1
" 只在有多于两个tab时显示tabline，不利用tabline来显示buffer
let g:airline#extensions#tabline#tab_min_count = 2
let g:airline#extensions#tabline#show_buffers = 0
" 不在tabline上显示关闭按钮
let g:airline#extensions#tabline#show_close_button = 0

let s:path_branch = {}

function! UrlDecode(str)
    let str = substitute(substitute(substitute(a:str,'%0[Aa]\n$','%0A',''),'%0[Aa]','\n','g'),'+',' ','g')
    return substitute(str,'%\(\x\x\)','\=nr2char("0x".submatch(1))','g')
endfunction

function! MyBranch()
    let result = airline#extensions#branch#get_head()
    if len(result)
        return result
    endif

    let path = expand("%:p:h")
    if has_key(s:path_branch, path)
        return s:path_branch[path]
    endif

    let branch = ""
    let branch_info = GetSvnBranchOfPath(path)
    if len(branch_info)
        let b = ""
        if branch_info["type"] == "trunk"
            let b = "trunk"
        elseif branch_info["type"] == "tag"
            let b = "tag:" . branch_info["branch"]
        else
            let b = branch_info["branch"]
        endif

        if len(b)
            let b = iconv(UrlDecode(b), "utf-8", &enc)
            let branch = g:airline_symbols.branch . ' ' . b
        endif
    endif

    let s:path_branch[path] = branch
    return branch
endfunction
" }}}3
" GoldenView.Vim: <F8>/<S-F8>当前窗口与主窗口交换，<C-P>/<C-N>上一个/下一个窗口 {{{3
NeoBundle 'zhaocai/GoldenView.Vim'
let g:goldenview__enable_default_mapping = 0
nmap <silent> <C-N>  <Plug>GoldenViewNext
nmap <silent> <C-P>  <Plug>GoldenViewPrevious

nmap <silent> <F8>   <Plug>GoldenViewSwitchMain
nmap <silent> <S-F8> <Plug>GoldenViewSwitchToggle

" nmap <silent> <C-L>  <Plug>GoldenViewSplit
" }}}3
" vim-unimpaired: 增加]及[开头的一系列快捷键，方便进行tab等的切换 {{{3
NeoBundle'tpope/vim-unimpaired'
" [a     : previous  ]a     : next   [A : first  ]A : last
" [b     : bprevious ]b     : bnext  [B : bfirst ]B : blast
" [l     : lprevious ]l     : lnext  [L : lfirst ]L : llast
" [<C-L> : lpfile    ]<C-L> : lnfile
" [q     : cprevious ]q     : cnext  [Q : cfirst ]Q : clast
" [t     : tprevious ]t     : tnext  [T : tfirst ]T : tlast
" }}}3
" vim-tmux-navigator: 使用ctrl+i/j/k/l在vim及tmux间切换 {{{3
NeoBundleLazy 'christoomey/vim-tmux-navigator', {
            \ 'mappings' : [['n', '<C-H>', '<C-J>', '<C-K>', '<C-L>', '<C-\>']],
            \ }
" 需要在tmux.conf中加入下列内容
" # Smart pane switching with awareness of vim splits
" is_vim='echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(view|n?vim?)(diff)?$"'
" bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
" bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
" bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
" bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
" bind -n C-\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"
" }}}3
" capture.vim: Capture命令，把Ex命令的结果捕捉到窗口中 {{{3
NeoBundleLazy 'tyru/capture.vim', {
            \ 'commands' : [ { 'name' : 'Capture', 'complete' : 'command' } ],
            \ }
" }}}3
" }}}2

" 载入manual-bundles下的插件 {{{2
"call neobundle#local(fnamemodify(finddir("manual-bundles", &runtimepath), ":p"), {}, ['asciidoc', 'my_config'])
let g:local_bundles_path = fnamemodify(finddir("manual-bundles", &runtimepath), ":p")
" asciidoc: 增加对asciidoc的支持 {{{3
NeoBundleLazy 'asciidoc', {
            \ 'type' : 'nosync',
            \ 'base' : g:local_bundles_path,
            \ 'filetypes' : ['asciidoc'],
            \ }
"au BufRead,BufNewFile */viki/*.txt,*/pkm/*.txt,*/blog/*.txt,*.asciidoc  set filetype=asciidoc
function! MyAsciidocFoldLevel(lnum)
    let lt = getline(a:lnum)
    let fh = matchend(lt, '\V\^\(=\+\)\ze\s\+\S')
    if fh != -1
        return '>'.fh
    endif
    return '='
endfunction

au FileType asciidoc      setlocal shiftwidth=2
            \ tabstop=2
            \ textwidth=80 wrap formatoptions=cqnmB
            \ makeprg=asciidoc\ -o\ numbered\ -o\ toc\ -o\ data-uri\ $*\ %
            \ errorformat=ERROR:\ %f:\ line\ %l:\ %m
            \ foldexpr=MyAsciidocFoldLevel(v:lnum)
            \ foldmethod=expr
            \ formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\\|^\\s*<\\d\\+>\\s\\+\\\\|^\\s*[a-zA-Z.]\\.\\s\\+\\\\|^\\s*[ivxIVX]\\+\\.\\s\\+
            \ comments=s1:/*,ex:*/,://,b:#,:%,:XCOMM,fb:-,fb:*,fb:+,fb:.,fb:>
" }}}3
" my_config: 其它的设置 {{{3
NeoBundle 'my_config', {
            \ 'type' : 'nosync',
            \ 'base' : g:local_bundles_path,
            \ }
" }}}3
" }}}2

" 检查有没有需要安装的插件 {{{2
" Installation check.
NeoBundleCheck

syntax on
filetype plugin indent on     " Required!

call neobundle#end()
" }}}2
" }}}1

" color scheme and statusline {{{1

if neobundle#is_installed("vim-colors-solarized")
    colorscheme solarized
endif

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
" }}}1

" Key mappings " {{{1

" 支持alt键 {{{2
" 使用Kitty后，不再需要映射Alt键
" if !s:is_windows && !s:is_gui
"     " 修改对Alt/Meta键的映射
"     for i in range(33, 126)
"         let c = nr2char(i)
"         exec "\"map \e".c." <M-".c.">\""
"         exec "\"map! \e".c." <M-".c.">\""
"         exec "\"imap \e".c." <M-".toupper(c).">\""
"     endfor
"     set ttimeoutlen=10  " 缩短keycode的timeout
" endif
" }}}2

" 简化对常用目录的访问 {{{2
"用,cd进入当前目录
nmap ,cd :cd <C-R>=expand("%:p:h")<CR><CR>
" "用,e可以打开当前目录下的文件
" nmap ,e :e <C-R>=escape(expand("%:p:h")."/", ' \')<CR>
" "在命令中，可以用 %/ 得到当前目录。如 :e %/
" cmap %/ <C-R>=escape(expand("%:p:h")."/", ' \')<cr>
" }}}2

" 光标移动 {{{2
" 正常模式下，空格及Shift-空格滚屏
noremap <SPACE> <C-F>
noremap <S-SPACE> <C-B>

" Key mappings to ease browsing long lines
nnoremap <Down>      gj
nnoremap <Up>        gk
inoremap <Down> <C-O>gj
inoremap <Up>   <C-O>gk
" }}}2

" 操作tab页 {{{2
" Ctrl-Tab/Ctrl-Shirt-Tab切换Tab
nmap <C-S-tab> :tabprevious<cr>
nmap <C-tab> :tabnext<cr>
map <C-S-tab> :tabprevious<cr>
map <C-tab> :tabnext<cr>
imap <C-S-tab> <ESC>:tabprevious<cr>i
imap <C-tab> <ESC>:tabnext<cr>i
" }}}2

" Key mappings for the quickfix commands {{{2
nmap <F11> :cn<CR>
nmap <F12> :cp<CR>
nmap g<F11> :cnf<CR>
nmap g<F12> :cpf<CR>
" }}}2

" 查找 {{{2
" <F3>自动在当前文件中vimgrep当前word，g<F3>在当前目录下，vimgrep_files指定的文件中查找
"nmap <F3> :exec "vimgrep /\\<" . expand("<cword>") . "\\>/j **/*.cpp **/*.c **/*.h **/*.php"<CR>:botright copen<CR>
"nmap <S-F3> :exec "vimgrep /\\<" . expand("<cword>") . "\\>/j %" <CR>:botright copen<CR>
"map <F3> <ESC>:exec "vimgrep /\\<" . expand("<cword>") . "\\>/j **/*.cpp **/*.cxx **/*.c **/*.h **/*.hpp **/*.php" <CR><ESC>:botright copen<CR>
nmap g<F3> <ESC>:<C-U>exec "vimgrep /\\<" . expand("<cword>") . "\\>/j " . b:vimgrep_files <CR><ESC>:botright copen<CR>
"map <S-F3> <ESC>:exec "vimgrep /\\<" . expand("<cword>") . "\\>/j %" <CR><ESC>:botright copen<CR>
nmap <F3> <ESC>:<C-U>exec "vimgrep /\\<" . expand("<cword>") . "\\>/j %" <CR><ESC>:botright copen<CR>

" V模式下，搜索选中的内容而不是当前word
vnoremap g<F3> :<C-U>
            \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
            \gvy
            \:exec "vimgrep /" . substitute(escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g') . "/j " . b:vimgrep_files <CR><ESC>:botright copen<CR>
            \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <F3> :<C-U>
            \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
            \gvy
            \:exec "vimgrep /" . substitute(escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g') . "/j %" <CR><ESC>:botright copen<CR>
            \gV:call setreg('"', old_reg, old_regtype)<CR>
" }}}2

" 在VISUAL模式下，缩进后保持原来的选择，以便再次进行缩进 {{{2
vnoremap > >gv
vnoremap < <gv
" }}}2

" folds {{{2
" zJ/zK跳到下个/上个折叠处，并只显示该折叠的内容
nnoremap zJ zjzx
nnoremap zK zkzx
nnoremap zr zr:echo 'foldlevel: ' . &foldlevel<cr>
nnoremap zm zm:echo 'foldlevel: ' . &foldlevel<cr>
nnoremap zR zR:echo 'foldlevel: ' . &foldlevel<cr>
nnoremap zM zM:echo 'foldlevel: ' . &foldlevel<cr>
" }}}2

" 一些方便编译的快捷键 {{{2
if exists(":Make")  " vim-dispatch提供了异步的make
    nnoremap <Leader>tm :<C-U>Make<CR>
    nnoremap <Leader>tt :<C-U>Make unittest<CR>
    nnoremap <Leader>ts :<C-U>Make stage<CR>
    nnoremap <Leader>tc :<C-U>Make clean<CR>
    nnoremap <Leader>td :<C-U>Make doc<CR>
else
    nnoremap <Leader>tm :<C-U>make<CR>
    nnoremap <Leader>tt :<C-U>make unittest<CR>
    nnoremap <Leader>ts :<C-U>make stage<CR>
    nnoremap <Leader>tc :<C-U>make clean<CR>
    nnoremap <Leader>td :<C-U>make doc<CR>
endif
" }}}2

" 其它 {{{2
" Split line(opposite to S-J joining line)
" nnoremap <silent> <C-J> gEa<CR><ESC>ew

" map <silent> <C-W>v :vnew<CR>
" map <silent> <C-W>s :snew<CR>

" nnoremap * :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>
" }}}2

" }}}1

" 启用内置的matchit插件
runtime! macros/matchit.vim

if filereadable(s:vimrc_path . "/project_setting")
    exec "source " . s:vimrc_path . "/project_setting"
endif

" vim: fileencoding=utf-8 foldmethod=marker foldlevel=0:
