" 判断当前环境 {{{
" 判断操作系统
let s:is_windows = has("win32") || has("win64")
let s:is_cygwin = has('win32unix')
let s:is_macvim = has('gui_macvim')

" 判断是终端还是gvim
let s:is_gui = has("gui_running")

" 当前脚本路径
let s:vimrc_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

if s:is_windows " windows下把vimrc目录下的win32加入到路径中，以便使用该目录下的工具
    let $PATH = $PATH . ";" . s:vimrc_path . '\win32'
endif
" }}}

" 设置encoding {{{
if !s:is_windows
    set encoding=utf-8
endif

scriptencoding utf-8
" }}}

" 插件组命名及选择要使用的插件及插件组 {{{
" Impacted by https://github.com/bling/dotvim

" 读入用户本地设置 {{{
" 如果~下有vimrc.local则使用
if filereadable($HOME . "/vimrc.local")
    exec "source " . $HOME . "/vimrc.local"
elseif filereadable($HOME . "/.vimrc.local")
    exec "source " . $HOME . "/.vimrc.local"
endif

if !exists('g:dotvim_user_settings')
    let g:dotvim_user_settings = {}
endif
" }}}

" 设置缺省值 {{{
let g:dotvim_settings = {}
let g:dotvim_settings.mapleader = ' '
" 把<Leader>m映射为“,”，方便使用
let g:dotvim_settings.map_mainmode = ','
let g:dotvim_settings.default_indent = 4
if v:version >= '703' && has('lua')
    let g:dotvim_settings.autocomplete_method = 'neocomplete'
else
    let g:dotvim_settings.autocomplete_method = ''
endif

" marching有三种backend，不指定则自动选一种
let g:dotvim_settings.cpp_complete_method = 'marching'
" let g:dotvim_settings.cpp_complete_method = 'marching.snowdrop'
" let g:dotvim_settings.cpp_complete_method = 'marching.sync'
" let g:dotvim_settings.cpp_complete_method = 'marching.async'

" let g:dotvim_settings.cpp_complete_method = 'clang_complete'
" let g:dotvim_settings.cpp_complete_method = 'vim-clang'
let g:dotvim_settings.enable_cursorcolumn = 0
let g:dotvim_settings.background = 'dark'
let g:dotvim_settings.colorscheme = 'solarized'
let g:dotvim_settings.cache_dir = '~/.vim_cache'
" airline的几种模式：powerline/unicode/ascii，分别使用powerline专有字符、
" UNICODE字符、和普通ASCII字符，根据使用的字体进行选择
let g:dotvim_settings.airline_mode = 'unicode'

" 一些工具的路径
let g:dotvim_settings.commands = {}
let g:dotvim_settings.commands.ag = ''
if executable("ag")
    let g:dotvim_settings.commands.ag = 'ag'
endif

let g:dotvim_settings.commands.ctags = ''
if executable("ctags")
    let g:dotvim_settings.commands.ctags = 'ctags'
endif

let g:dotvim_settings.commands.global = $GTAGSGLOBAL
if g:dotvim_settings.commands.global == ''
    let g:dotvim_settings.commands.global = "global"
endif
if !executable(g:dotvim_settings.commands.global)
    let g:dotvim_settings.commands.global = ""
endif
" global的版本。6以上可以使用新的选项
let g:dotvim_settings.global_version = 5

let g:dotvim_settings.commands.git = ''
if executable("git")
    let g:dotvim_settings.commands.git = 'git'
endif

" 确定libclang的位置 {{{
let g:dotvim_settings.libclang_path = ""

if s:is_windows
    if filereadable(s:vimrc_path . "/win32/libclang.dll")
        let g:dotvim_settings.libclang_path = s:vimrc_path . "/win32"
    endif
else
    if filereadable(expand("~/libexec/libclang.so"))
        let g:dotvim_settings.libclang_path = expand("~/libexec")
    elseif filereadable(expand("/usr/lib/libclang.so"))
        let g:dotvim_settings.libclang_path = expand("/usr/lib")
    elseif filereadable(expand("/usr/lib64/libclang.so"))
        let g:dotvim_settings.libclang_path = expand("/usr/lib64")
    endif
endif

let g:dotvim_settings.clang_include_path = fnamemodify(finddir("include",  g:dotvim_settings.libclang_path . "/clang/**"), ":p")
" }}}

if v:version >= '704' && (has('python') || has('python3'))
    let g:dotvim_settings.snippet_engine = 'ultisnips'
else
    let g:dotvim_settings.snippet_engine = 'neosnippet'
endif

let g:dotvim_settings.neobundle_max_processes = '8'
" }}}

" {{{ 使用用户本地设置覆盖缺省设置
" override defaults with the ones specified in g:dotvim_user_settings
for key in keys(g:dotvim_settings)
    if has_key(g:dotvim_user_settings, key)
        if type(g:dotvim_settings[key]) == type({})
            call extend(g:dotvim_settings[key], g:dotvim_user_settings[key])
        else
            let g:dotvim_settings[key] = g:dotvim_user_settings[key]
        endif
    endif
endfor

" plugin_groups_include/plugin_groups_exclude列表中存放的是正则表达式
" exclude all language-specific plugins by default
let g:dotvim_settings.plugin_groups_exclude = get(g:dotvim_user_settings, 'plugin_groups_exclude', [])
let g:dotvim_settings.plugin_groups_include = get(g:dotvim_user_settings, 'plugin_groups_include', [])
let g:dotvim_settings.disabled_plugins = get(g:dotvim_user_settings, 'disabled_plugins', [])
" }}}
" }}}

" Helper Functions {{{
function! s:RemoveTrailingSpace() "{{{
    if $VIM_HATE_SPACE_ERRORS != '0' && index(['c', 'cpp', 'vim', 'python'], &filetype) >= 0
        normal m`
        silent! :%s/\s\+$//e
        normal ``
    endif
endfunction
" }}}

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
" }}}

" Find SVN branch " {{{
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

        if url =~ ".*/trunk\\($\\|/.*\\)"
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
" }}}

function! s:path_join(...) "{{{
    if a:0 <= 0
        return ""
    endif

    let path = a:000[0]
    let i = 1
    while i < a:0
        let path = path . '/' . a:000[i]
        let i = i + 1
    endwhile

    return path
endfunction "}}}

function! s:get_cache_dir(...) "{{{
    let i = 0
    let path = resolve(expand(g:dotvim_settings.cache_dir))
    if !isdirectory(path)
        call mkdir(path)
    endif

    while i < a:0
        let d = a:000[i]
        let path = resolve(s:path_join(path, d))
        if !isdirectory(path)
            call mkdir(path)
        endif
        let i = i + 1
    endwhile

    return path
endfunction "}}}

function! s:buffer_dir_exe(args) "{{{ 在当前缓冲区目录下执行命令
    let olddir = getcwd()
    try
        exe 'cd' fnameescape(expand("%:p:h"))
        exe join(a:args)
    finally
        exe 'cd' fnameescape(olddir)
    endtry
endfunction
command! -nargs=* -complete=command BufferDirExe :call s:buffer_dir_exe([<f-args>])
"}}}

function! s:match_group(group_name, pattern)
    return '.' . a:group_name . '.' =~ '\.' . substitute(a:pattern, '\.', '\\.', 'g') . '\.'
endfunction

function! s:is_plugin_group_enabled(group_name)
    " group_name中可以用.进行分层。支持部分匹配
    for name in ["_plugin_groups", "_enabled_plugin_groups", "_disabled_plugin_groups"]
        if !has_key(g:dotvim_settings, name)
            let g:dotvim_settings[name] = []
        endif
    endfor

    " 之前已经处理过了
    if index(g:dotvim_settings._enabled_plugin_groups, a:group_name) >= 0
        return 1
    endif

    " 形成一份包含目前支持的所有组的列表
    if index(g:dotvim_settings._plugin_groups, a:group_name) < 0
        call add(g:dotvim_settings._plugin_groups, a:group_name)
    endif

    " 在include中的优先级最高。include列表中，可以使用正则表达式
    for pattern in g:dotvim_settings.plugin_groups_include
        if s:match_group(a:group_name, pattern)
            call add(g:dotvim_settings._enabled_plugin_groups, a:group_name)
            return 1
        endif
    endfor

    " 在exclude中的组被禁用
    for pattern in g:dotvim_settings.plugin_groups_exclude
        if s:match_group(a:group_name, pattern)
            call add(g:dotvim_settings._disabled_plugin_groups, a:group_name)
            return 0
        endif
    endfor

    " 没在两个列表中的被启用
    call add(g:dotvim_settings._enabled_plugin_groups, a:group_name)
    return 1
endfunction

" s:VisualSelection(): 返回当前被选中的文字 {{{
" Thanks to xolox!
" http://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
func! s:VisualSelection() abort
    " Why is this not a built-in Vim script function?!
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
    return join(lines, "\n")
endf
" }}}

" }}}

" General {{{
if has('vim_starting') && &compatible
    set nocompatible " disable vi compatibility.
endif

set history=256 " Number of things to remember in history.
set autowrite " Writes on make/shell commands
set autoread     " 当文件在外部被修改时，自动重新读取
"set timeoutlen=250 " Time to wait after ESC (default causes an annoying delay)
"set clipboard+=unnamed " Yanks go on clipboard instead.
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

" 设置各种目录 {{{
" backups
set backup
let &backupdir = s:get_cache_dir('backup')

" swap files
let &directory = s:get_cache_dir('swap')
set noswapfile

if has("persistent_undo")
    let &undodir = s:get_cache_dir('undo')
    set undofile
endif
" }}}

if (s:is_windows)
    set shellpipe=2>&1\ \|\ tee
    set shellslash
endif

set noshelltemp

set sessionoptions-=options
set sessionoptions+=tabpages,globals
set viewoptions-=options

" Buffers
set hidden " The current buffer can be put to the background without writing to disk

" Match and search {{{
set hlsearch " highlight search
set ignorecase " Do case in sensitive matching with
set smartcase " be sensitive when there's a capital letter
set incsearch "
set diffopt+=iwhite
" }}}
" }}}

" Formatting {{{
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
set wildignore+=.hg,.git,.svn                    " Version control
" set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.spl                            " compiled spelling word lists
set wildignore+=*.pyc                            " Python byte code
set wildignore+=*.luac                           " Lua byte code
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=.idea,.DS_Store                  " others

set backspace=indent,eol,start " more powerful backspacing
set whichwrap+=b,s,<,>,h,l " 退格键和方向键可以换行

let &tabstop=g:dotvim_settings.default_indent "number of spaces per tab for display
let &softtabstop=g:dotvim_settings.default_indent "number of spaces per tab in insert mode
let &shiftwidth=g:dotvim_settings.default_indent "number of spaces when indenting

set shiftround   " <</>>等缩进位置不是+/-4空格，而是对齐到下个'shiftwidth'位置
set expandtab " Make tabs into spaces (set by tabstop)
set smarttab " Smarter tab levels

set autoindent
set nosmartindent
set cindent
set cinoptions=:s,ps,ts,cs
set cinwords=if,else,while,do,for,switch,case
" }}}

" Visual {{{
let &termencoding = &encoding
if (s:is_windows)
    set guifont=Menlo_for_Powerline:h12,Powerline_Consolas:h12,Bitstream\ Vera\ Sans\ Mono\ 12,Fixed\ 12,Consolas:h12,Courier_New:h12
    set guifontwide=Microsoft\ Yahei\ 12,WenQuanYi\ Zen\ Hei\ 12,NSimsun:h12

    "解决菜单乱码
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
    "解决consle输出乱码
    "language messages zh_CN.utf-8
    language messages en_US
else
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
set nostartofline " 翻页时保持光标的水平位置

set nolist " Don't display unprintable characters
"let &listchars="tab:\u2192 ,eol:\u00b6,trail:\u00b7,extends:\u00bb,precedes:\u00ab"
"let &listchars="tab:\u21e5 ,eol:\u00b6,trail:\u00b7,extends:\u00bb,precedes:\u00ab"
"let &listchars="tab:\u21e5 ,trail:\u00b7,extends:\u00bb,precedes:\u00ab"
"let &listchars="tab:\u21e2\u21e5,trail:\u00b7,extends:\u00bb,precedes:\u00ab"
"set listchars=tab:>-,eol:<,trail:-,nbsp:%,extends:>,precedes:<
if &encoding != "utf-8"
    set listchars=tab:>-,trail:-,nbsp:%,extends:>,precedes:<
else
    let &listchars="tab:\u25b8 ,trail:\u00b7,extends:\u00bb,precedes:\u00ab"
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
" }}}

" Syntax Highlight {{{
let g:vimsyn_folding = ''
let g:vimsyn_folding .= 'a' " augroups
let g:vimsyn_folding .= 'f' " fold functions
let g:vimsyn_folding .= 'm' " fold mzscheme script
let g:vimsyn_folding .= 'p' " fold perl     script
let g:vimsyn_folding .= 'P' " fold python   script
let g:vimsyn_folding .= 'r' " fold ruby     script
let g:vimsyn_folding .= 't' " fold tcl      script

let g:load_doxygen_syntax = 0 " 启用源代码中的doxygen注释高亮
let g:doxygen_enhanced_color = 0    " 对Doxygen注释使用非标准高亮

let g:is_bash	   = 1  " 如果没有#!行，缺省认为shell脚本用的是bash

let g:sh_fold_enabled = 0      " default, no syntax folding
let g:sh_fold_enabled += 1     " enable function folding
let g:sh_fold_enabled += 2     " enable heredoc folding
let g:sh_fold_enabled += 4     " enable if/do/for folding
" }}}

" Coding {{{
set tags+=./tags;/ " walk directory tree upto / looking for tags

set completeopt=menuone,menu,longest,preview
set completeopt-=longest
set showfulltag

if filereadable(s:vimrc_path . "/win32/words.txt")
    if len(&dictionary) > 0
        let &dictionary .= "," . s:vimrc_path . "/win32/words.txt"
    else
        let &dictionary = s:vimrc_path . "/win32/words.txt"
    endif
elseif filereadable("/usr/share/dict/words")
    set dictionary+=/usr/share/dict/words
endif

" Highlight space errors in C/C++ source files (Vim tip #935)
let c_space_errors=1
let java_space_errors=1

if g:dotvim_settings.commands.ag != ""
    exec 'set grepprg=' . g:dotvim_settings.commands.ag . '\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow'
    set grepformat=%f:%l:%c:%m
endif
" }}}

" Auto commands " {{{

" define a group `vimrc` and initialize. {{{
augroup vimrc
  autocmd!
augroup END
" }}}

" Misc {{{
if (s:is_windows)
    autocmd vimrc GUIEnter * simalt ~x " 启动时自动全屏
endif

autocmd vimrc BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal g'\"" | endif " restore position in file

" automatically open and close the popup menu / preview window
autocmd vimrc CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
" }}}

" Filetype detection " {{{
autocmd vimrc BufRead,BufNewFile {Gemfile,Rakefile,Capfile,*.rake,config.ru} setf ruby
autocmd vimrc BufRead,BufNewFile {*.md,*.mkd,*.markdown} setf markdown
autocmd vimrc BufRead,BufNewFile {COMMIT_EDITMSG}  setf gitcommit
autocmd vimrc BufRead,BufNewFile TDM*C,TDM*H       setf c
autocmd vimrc BufRead,BufNewFile *.dox             setf cpp    " Doxygen
autocmd vimrc BufRead,BufNewFile *.cshtml          setf cshtml

"" Remove trailing spaces for C/C++ and Vim files
autocmd vimrc BufWritePre *                  call s:RemoveTrailingSpace()

autocmd vimrc BufRead,BufNewFile todo.txt,done.txt           setf todo
autocmd vimrc BufRead,BufNewFile *.mm                        setf xml
autocmd vimrc BufRead,BufNewFile *.proto                     setf proto
autocmd vimrc BufRead,BufNewFile Jamfile*,Jamroot*,*.jam     setf jam
autocmd vimrc BufRead,BufNewFile pending.data,completed.data setf task
autocmd vimrc BufRead,BufNewFile *.ipp                       setf cpp
" }}}

" Filetype related autosettings " {{{
autocmd vimrc FileType diff  setlocal shiftwidth=4 tabstop=4
" autocmd vimrc FileType html  setlocal autoindent indentexpr= shiftwidth=2 tabstop=2
autocmd vimrc FileType changelog setlocal textwidth=76
" 把-等符号也作为xml文件的有效关键字，可以用Ctrl-N补全带-等字符的属性名
autocmd vimrc FileType {xml,xslt} setlocal iskeyword=@,-,\:,48-57,_,128-167,224-235
if executable("tidy")
    autocmd vimrc FileType xml        exe 'setlocal equalprg=tidy\ -quiet\ -indent\ -xml\ -raw\ --show-errors\ 0\ --wrap\ 0\ --vertical-space\ 1\ --indent-spaces\ 4'
elseif executable("xmllint")
    autocmd vimrc FileType xml        exe 'setlocal equalprg=xmllint\ --format\ --recover\ --encode\ UTF-8\ -'
endif

autocmd vimrc FileType qf setlocal wrap linebreak
autocmd vimrc FileType vim nnoremap <silent> <buffer> K :<C-U>help <C-R><C-W><CR>
autocmd vimrc FileType man setlocal foldmethod=indent foldnestmax=2 foldenable nomodifiable nonumber shiftwidth=3 foldlevel=2
autocmd vimrc FileType cs setlocal wrap

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
    autocmd vimrc FileType xml call s:jing_settings("xml")
    autocmd vimrc FileType rnc call s:jing_settings("rnc")
endif

"autocmd vimrc BufRead,BufNewFile *.adoc,*.asciidoc  set filetype=asciidoc
function! MyAsciidocFoldLevel(lnum)
    let lt = getline(a:lnum)
    let fh = matchend(lt, '\V\^\(=\+\)\ze\s\+\S')
    if fh != -1
        return '>'.fh
    endif
    return '='
endfunction

autocmd vimrc BufNewFile *.adoc,*.asciidoc setlocal fileencoding=utf-8
autocmd vimrc FileType asciidoc setlocal shiftwidth=2
            \ tabstop=2
            \ textwidth=0 wrap formatoptions=cqnmB
            \ makeprg=asciidoc\ -o\ numbered\ -o\ toc\ -o\ data-uri\ $*\ %
            \ errorformat=ERROR:\ %f:\ line\ %l:\ %m
            \ foldexpr=MyAsciidocFoldLevel(v:lnum)
            \ foldmethod=expr
            \ foldlevel=1
            \ nospell
            \ isfname-=#
            \ isfname-=[
            \ isfname-=]
            \ isfname-=:
            \ suffixesadd=.asciidoc,.adoc
            \ formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\\|^\\s*<\\d\\+>\\s\\+\\\\|^\\s*[a-zA-Z.]\\.\\s\\+\\\\|^\\s*[ivxIVX]\\+\\.\\s\\+
            \ comments=s1:/*,ex:*/,://,b:#,:%,:XCOMM,fb:-,fb:*,fb:+,fb:.,fb:>

" 启用XML文件语法折叠，在打开大XML时可能会慢一些。参见:help xml-folding
let g:xml_syntax_folding = 1
autocmd vimrc FileType xml setlocal foldmethod=syntax
" }}}

" 根据不同的文件类型设定g<F3>时应该查找的文件 {{{
autocmd vimrc FileType *             let b:vimgrep_files=expand("%:e") == "" ? "**/*" : "**/*." . expand("%:e")
autocmd vimrc FileType c,cpp         let b:vimgrep_files="**/*.cpp **/*.cxx **/*.c **/*.h **/*.hpp **/*.ipp"
autocmd vimrc FileType php           let b:vimgrep_files="**/*.php **/*.htm **/*.html"
autocmd vimrc FileType cs            let b:vimgrep_files="**/*.cs"
autocmd vimrc FileType vim           let b:vimgrep_files="**/*.vim"
autocmd vimrc FileType javascript    let b:vimgrep_files="**/*.js **/*.htm **/*.html"
autocmd vimrc FileType python        let b:vimgrep_files="**/*.py"
autocmd vimrc FileType xml           let b:vimgrep_files="**/*.xml"
autocmd vimrc FileType jam           let b:vimgrep_files="**/*.jam **/Jam*"
" }}}

" 与vim-dispatch冲突，禁用。 https://github.com/tpope/vim-dispatch/issues/145
" " 自动打开quickfix窗口 {{{
" " Automatically open, but do not go to (if there are errors) the quickfix /
" " location list window, or close it when is has become empty.
" "
" " Note: Must allow nesting of autocmds to enable any customizations for quickfix
" " buffers.
" " Note: Normally, :cwindow jumps to the quickfix window if the command opens it
" " (but not if it's already open). However, as part of the autocmd, this doesn't
" " seem to happen.
" autocmd vimrc QuickFixCmdPost [^l]* nested botright cwindow
" autocmd vimrc QuickFixCmdPost    l* nested botright lwindow
" " }}}

" python autocommands {{{
" 设定python的makeprg
if executable("python2")
    autocmd vimrc FileType python setlocal makeprg=python2\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
else
    autocmd vimrc FileType python setlocal makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
endif

"autocmd vimrc FileType python set errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
autocmd vimrc FileType python setlocal errorformat=%[%^(]%\\+('%m'\\,\ ('%f'\\,\ %l\\,\ %v\\,%.%#
autocmd vimrc FileType python setlocal smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
" }}}

" Text file encoding autodetection {{{
autocmd vimrc BufReadPre  *.gb               call SetFileEncodings('gbk')
autocmd vimrc BufReadPre  *.big5             call SetFileEncodings('big5')
autocmd vimrc BufReadPre  *.nfo              call SetFileEncodings('cp437') | set ambiwidth=single
autocmd vimrc BufReadPre  *.php              call SetFileEncodings('utf-8')
autocmd vimrc BufReadPre  *.lua              call SetFileEncodings('utf-8')
autocmd vimrc BufReadPost *.gb,*.big5,*.nfo,*.php,*.lua  call RestoreFileEncodings()

autocmd vimrc BufWinEnter *.txt              call CheckFileEncoding()

" 强制用UTF-8打开vim文件
autocmd vimrc BufReadPost  .vimrc,*.vim nested     call ForceFileEncoding('utf-8')

autocmd vimrc FileType task call ForceFileEncoding('utf-8')
" }}}

" }}}

" 用于各插件的热键前缀 {{{
let mapleader = g:dotvim_settings.mapleader
if g:dotvim_settings.map_mainmode != ''
    exec "nmap ".g:dotvim_settings.map_mainmode." <Leader>m"
    exec "vmap ".g:dotvim_settings.map_mainmode." <Leader>m"
endif
" }}}

" Plugins {{{

" Brief help
" :NeoBundleList          - list configured bundles
" :NeoBundleInstall(!)    - install(update) bundles

" Loading NeoBundle {{{
filetype off                   " Required!

if has('vim_starting') && match("neobundle", &runtimepath) < 0
    let &runtimepath .= "," . fnamemodify(finddir("bundle/neobundle.vim", &runtimepath), ":p")
endif

call neobundle#begin()

let g:neobundle_default_git_protocol = 'https'
let g:neobundle#install_process_timeout = 1500
let g:neobundle#install_max_processes = g:dotvim_settings.neobundle_max_processes
if executable(g:dotvim_settings.commands.git)
    let g:neobundle#types#git#command_path = g:dotvim_settings.commands.git
endif

" 使用submodule管理NeoBundle
" " Let NeoBundle manage NeoBundle
" NeoBundle 'Shougo/neobundle.vim'    " 插件管理软件
" }}}

if s:is_plugin_group_enabled('core') "{{{
    " vimproc: 用于异步执行命令的插件，被其它插件依赖 {{{
    if (s:is_windows)
        " Windows下需要固定为与dll对应的版本
        " 可到 https://github.com/koron/vim-kaoriya/releases 下载编译好的DLL
        NeoBundle 'Shougo/vimproc', { 'rev' : '9269f38' }
        if has("win64") && filereadable(s:vimrc_path . "/win32/vimproc_win64.dll")
            let g:vimproc_dll_path = s:vimrc_path . "/win32/vimproc_win64.dll"
        elseif has("win32") && filereadable(s:vimrc_path . "/win32/vimproc_win32.dll")
            let g:vimproc_dll_path = s:vimrc_path . "/win32/vimproc_win32.dll"
        endif
    else
        NeoBundle 'Shougo/vimproc', {
                    \ 'build' : {
                    \     'windows' : 'tools\\update-dll-mingw',
                    \     'cygwin' : 'make -f make_cygwin.mak',
                    \     'mac' : 'make -f make_mac.mak',
                    \     'linux' : 'make',
                    \     'unix' : 'gmake',
                    \     'others' : 'make',
                    \    },
                    \ }
    endif
    " }}}
    " vim-projectroot: 在项目根目录执行或找出项目的根目录 {{{
    NeoBundleLazy 'dbakker/vim-projectroot', {
                \ 'on_cmd' : [
                \     {'name' : 'ProjectRootExe', 'complete' : 'command'},
                \     {'name' : 'ProjectRootCD', 'complete' : 'file'},
                \     {'name' : 'ProjectRootLCD', 'complete' : 'file'},
                \     {'name' : 'ProjectBufArgs', 'complete' : 'file'},
                \     {'name' : 'ProjectBufFirst', 'complete' : 'file'},
                \     {'name' : 'ProjectBufLast', 'complete' : 'file'},
                \     {'name' : 'ProjectBufDo', 'complete' : 'command'},
                \     {'name' : 'ProjectBufNext', 'complete' : 'file'},
                \     {'name' : 'ProjectBufPrev', 'complete' : 'file'},
                \ ],
                \ 'on_func' : [
                \     'projectroot#get',
                \     'projectroot#guess',
                \     'projectroot#exe',
                \     'projectroot#cd',
                \     'projectroot#buffers',
                \     'projectroot#bufnext',
                \ ]}
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('unite') "{{{
    " unite.vim: Unite主插件，提供\f开头的功能 {{{
    NeoBundleLazy 'Shougo/unite.vim', {
                \ 'on_cmd' : [
                \     {'name' : 'Unite', 'complete' : 'customlist,unite#complete#source'},
                \     {'name' : 'UniteWithCurrentDir', 'complete' : 'customlist,unite#complete#source'},
                \     {'name' : 'UniteWithBufferDir', 'complete' : 'customlist,unite#complete#source'},
                \     {'name' : 'UniteWithProjectDir', 'complete' : 'customlist,unite#complete#source'},
                \     {'name' : 'UniteWithInputDirectory', 'complete' : 'customlist,unite#complete#source'},
                \     {'name' : 'UniteWithCursorWord', 'complete' : 'customlist,unite#complete#source'},
                \     {'name' : 'UniteWithInput', 'complete' : 'customlist,unite#complete#source'},
                \     {'name' : 'UniteResume', 'complete' : 'customlist,unite#complete#buffer_name'},
                \     {'name' : 'UniteClose', 'complete' : 'customlist,unite#complete#buffer_name'},
                \     {'name' : 'UniteNext', 'complete' : 'customlist,unite#complete#buffer_name'},
                \     {'name' : 'UnitePrevious', 'complete' : 'customlist,unite#complete#buffer_name'},
                \     {'name' : 'UniteFirst', 'complete' : 'customlist,unite#complete#buffer_name'},
                \     {'name' : 'UniteLast', 'complete' : 'customlist,unite#complete#buffer_name'},
                \     {'name' : 'UniteBookmarkAdd', 'complete' : 'file'},
                \ ]}
    if neobundle#tap('unite.vim')
        function! neobundle#hooks.on_post_source(bundle)
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

            call unite#filters#matcher_default#use(['matcher_context'])
            call unite#filters#sorter_default#use(['sorter_rank'])
            " let g:unite_source_rec_max_cache_files = 0
            " call unite#custom#source('file_rec,file_rec/async', 'max_candidates', 0)
        endfunction

        let g:unite_enable_start_insert = 1
        "let g:unite_enable_short_source_names = 1

        let g:unite_enable_ignore_case = 1
        let g:unite_enable_smart_case = 1

        let g:unite_data_directory = s:get_cache_dir('unite')
        let g:unite_source_session_path = s:get_cache_dir('session')
        let g:unite_source_grep_default_opts = "-iHn --color=never"

        let g:unite_winheight = winheight("%") / 2
        " let g:unite_winwidth = winwidth("%") / 2
        let g:unite_winwidth = 40

        if g:dotvim_settings.commands.ag != ""
            " Use ag in unite grep source.
            let g:unite_source_grep_command = g:dotvim_settings.commands.ag
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

        autocmd! vimrc FileType unite call s:unite_my_settings()

        call neobundle#untap()
    endif
    function! s:unite_my_settings() "{{{
        imap <silent><buffer><expr>     <C-s>  unite#do_action('split')
        imap <silent><buffer><expr>     <C-v>  unite#do_action('vsplit')
        imap <silent><buffer>           jj     <Plug>(unite_insert_leave)
        imap <silent><buffer><expr>     j      unite#smart_map('j', '')

        nnoremap <silent><buffer>       <ESC> <Plug>(unite_exit)
        nnoremap <silent><buffer><expr> cd     unite#do_action('lcd')
        nnoremap <silent><buffer><expr> v      unite#do_action('vsplit')
        nnoremap <silent><buffer><expr> s      unite#do_action('split')

        nnoremap <silent><buffer><expr> S      unite#mappings#set_current_filters(
                    \ empty(unite#mappings#get_current_filters()) ?
                    \ ['sorter_reverse'] : [])
    endfunction "}}}
    " }}}
    " unite-outline: 提供代码的大纲。通过\fo访问 {{{
    NeoBundleLazy 'Shougo/unite-outline', {
                \ 'on_source': ['unite.vim'],
                \ }
    nnoremap <silent> <Leader>fo  :<C-U>Unite outline -buffer-name=outline -no-quit -no-start-insert -vertical -toggle -winwidth=45<CR>
    " }}}
    " neoyank.vim: unite的history/yank源，提供历史yank缓冲区。通过\fy访问 {{{
    NeoBundle 'Shougo/neoyank.vim', {
                \ 'on_source': ['unite.vim'],
                \ 'on_path' : '.*',
                \ }
    let g:neoyank#file = s:path_join(s:get_cache_dir('neoyank'), 'history_yank')
    " }}}
    " unite-mark: 列出所有标记点 {{{
    NeoBundleLazy 'tacroe/unite-mark', {
                \ 'on_source': ['unite.vim'],
                \ }
    " }}}
    " unite-help: 查找vim的帮助 {{{
    NeoBundleLazy 'shougo/unite-help', {
                \ 'on_source': ['unite.vim'],
                \ }
    nnoremap <silent> <Leader>h<Space> :<C-U>Unite -buffer-name=helps -start-insert help<CR>
    " }}}
    " unite-apropos: 用apropos查找man pages {{{
    NeoBundleLazy 'blindFS/unite-apropos'
    if executable('apropos')
        call neobundle#config('unite-apropos', {
                    \ 'on_source': ['unite.vim'],
                    \ })

        nnoremap <silent> <Leader>ha :<C-U>Unite -buffer-name=helps -start-insert apropos<CR>
        nnoremap <silent> <Leader>hA :<C-U>UniteWithCursorWord -buffer-name=helps apropos<CR>
    endif
    " }}}
    " unite-unicode: 根据unicode名称找字符 {{{
    NeoBundleLazy 'MaryHal/unite-unicode', {
                \ 'on_source': ['unite.vim'],
                \ }
    nnoremap <silent> <Leader>iu :<C-U>Unite -default-action=append unicode<CR>
    nnoremap <silent> <Leader>iU :<C-U>Unite -default-action=insert unicode<CR>
    " }}}
    " unite-colorscheme: 列出所有配色方案 {{{
    NeoBundleLazy 'ujihisa/unite-colorscheme', {
                \ 'on_source': ['unite.vim'],
                \ }
    nnoremap <silent> <Leader>Ts :<C-U>Unite colorscheme<CR>
    " }}}
    " unite-quickfix: 过滤quickfix窗口（如在编译结果中查找） {{{
    NeoBundleLazy 'osyo-manga/unite-quickfix', {
                \ 'on_source': ['unite.vim'],
                \ }
    " }}}
    " vim-unite-history: 搜索命令历史 {{{
    NeoBundleLazy 'thinca/vim-unite-history', {
                \ 'on_source': ['unite.vim'],
                \ }
    " }}}
    " unite-tselect: 跳转到光标下的tag。通过g]和g<C-]>访问 {{{
    NeoBundleLazy 'eiiches/unite-tselect', {
                \ 'on_source': ['unite.vim'],
                \ }
    nnoremap <silent> g<C-]> :<C-U>Unite -immediately tselect:<C-R>=expand('<cword>')<CR><CR>
    nnoremap <silent> g] :<C-U>Unite tselect:<C-R>=expand('<cword>')<CR><CR>
    " }}}
    " unite-gtags: Unite下调用gtags {{{
    NeoBundleLazy 'thawk/unite-gtags'
    if g:dotvim_settings.commands.global != ''
        call neobundle#config('unite-gtags', {
                    \ 'on_source': ['unite.vim'],
                    \ })

        " 旧版本global需要设置一些兼容选项
        if g:dotvim_settings.global_version < 6
            let g:unite_source_gtags_ref_option = 'rse'
            let g:unite_source_gtags_def_option = 'e'
            let g:unite_source_gtags_result_option = 'ctags-x'
            let g:unite_source_gtags_enable_nearness = 1
        endif

        autocmd vimrc FileType c,cpp,java,php
                    \   nnoremap <silent><buffer> <Leader>s] :<C-U>Unite -immediately gtags/context<CR>
                    \ | nnoremap <silent><buffer> <Leader>sR :<C-U>Unite -immediately gtags/ref<CR>
                    \ | nnoremap <silent><buffer> <Leader>sr :<C-U>Unite gtags/completion -default-action=list_refereces<CR>
                    \ | nnoremap <silent><buffer> <Leader>sD :<C-U>Unite -immediately gtags/def<CR>
                    \ | nnoremap <silent><buffer> <Leader>sd :<C-U>Unite gtags/completion -default-action=list_definitions<CR>
                    \ | nnoremap <silent><buffer> <Leader>pg :<C-U>Unite gtags/completion -default-action=list_definitions<CR>
                    \ | nnoremap <silent><buffer> <Leader>s/ :<C-U>Unite gtags/file<CR>
                    \ | nnoremap <silent><buffer> <Leader>sn :<C-U>Unite gtags/path::<CR>
                    \ | nnoremap <silent><buffer> <Leader>sN :<C-U>UniteWithCursorWord -immediately gtags/path<CR>
                    "\ | nnoremapap <silent><buffer> <Leader>st :<C-U>UniteWithCursorWord -immediately gtags/grep<CR>
                    "\ | nnoremapap <silent><buffer> <Leader>sT :<C-U>Unite gtags/grep:
                    "\ | nnoremapap <silent><buffer> <Leader>se :<C-U>UniteWithCursorWord -immediately gtags/grep<CR>
                    "\ | nnoremapap <silent><buffer> <Leader>sE :<C-U>Unite gtags/grep:
    endif
    " }}}
    " tabpagebuffer.vim: 记录一个tab中包含的buffer {{{
    NeoBundle 'Shougo/tabpagebuffer.vim'
    " }}}
    " neomru.vim: 最近访问的文件 {{{
    NeoBundle 'Shougo/neomru.vim'
    let g:neomru#file_mru_path = s:path_join(s:get_cache_dir('neomru'), 'file')
    let g:neomru#directory_mru_path = s:path_join(s:get_cache_dir('neomru'), 'directory')

    nnoremap <silent> <Leader>fr :<C-U>Unite -buffer-name=files -start-insert file_mru<CR>
    " }}}
    " unite-fold: fold {{{
    NeoBundle 'osyo-manga/unite-fold'
    nnoremap <silent> <Leader>fO  :<C-U>Unite fold -buffer-name=outline -no-quit -no-start-insert -vertical -toggle -winwidth=45<CR>

    " }}}
    " unite的menu {{{
    let g:unite_source_menu_menus = get(g:,'unite_source_menu_menus',{})
    let leader_str = substitute(mapleader, ' ', '<Space>', '')
    let g:unite_source_menu_menus.leader_bindings = {
                \ 'description' : '快捷键'
                \ }
    let g:unite_source_menu_menus.leader_bindings.command_candidates = [
                \ ['<Leader>?  →           列出可用的按键', 'Unite  mapping'],
                \ ['<Leader>au →             切换UndoTree', 'normal <Leader>au'],
                \ ['<Leader>b  →              +缓冲区相关', 'Unite  mapping -input='.leader_str.'b'],
                \ ['<Leader>c  →                    +编译', 'Unite  mapping -input='.leader_str.'c'],
                \ ['<Leader>d  →                    +调试', 'Unite  mapping -input='.leader_str.'d'],
                \ ['<Leader>f  →                +文件相关', 'Unite  mapping -input='.leader_str.'f'],
                \ ['<Leader>g  →                +版本控制', 'Unite  mapping -input='.leader_str.'g'],
                \ ['<Leader>h  →              +文档和帮助', 'Unite  mapping -input='.leader_str.'h'],
                \ ['<Leader>i  →                +插入内容', 'Unite  mapping -input='.leader_str.'i'],
                \ ['<Leader>j  →                    +跳转', 'Unite  mapping -input='.leader_str.'j'],
                \ ['<Leader>mg →                +代码跳转', 'Unite  mapping -input='.leader_str.'mg'],
                \ ['<Leader>ms →                    +REPL', 'Unite  mapping -input='.leader_str.'ms'],
                \ ['<Leader>p  →                +项目相关', 'Unite  mapping -input='.leader_str.'p'],
                \ ['<Leader>q  →                    +退出', 'Unite  mapping -input='.leader_str.'q'],
                \ ['<Leader>r  → +Resume/Rename/Registers', 'Unite  mapping -input='.leader_str.'r'],
                \ ['<Leader>s  →        +搜索和Symbol查找', 'Unite  mapping -input='.leader_str.'s'],
                \ ['<Leader>t  →                +切换开关', 'Unite  mapping -input='.leader_str.'h'],
                \ ['<Leader>u  →                   +Unite', 'Unite  mapping -input='.leader_str.'u'],
                \ ['<Leader>w  →                +窗口相关', 'Unite  mapping -input='.leader_str.'w'],
                \ ['<Leader>x  →                +文本相关', 'Unite  mapping -input='.leader_str.'x'],
                \ ]
    " }}}
    " unite的key binding {{{
    nnoremap <silent> <Leader>? :<C-U>Unite -auto-resize -buffer-name=mappings mapping<CR>
    nnoremap <silent> <Leader>hdb :<C-U>Unite -auto-resize -buffer-name=mappings mapping<CR>
    nnoremap <silent> <Leader>hdf :<C-U>Unite -auto-resize -buffer-name=functions function<CR>
    nnoremap <silent> <Leader>hdv :<C-U>Unite -auto-resize -buffer-name=variables output:let<CR>
    nnoremap <silent> <Leader>rl :<C-U>UniteResume -no-start-insert -toggle<CR>
    nnoremap <silent> <Leader>ry :<C-U>Unite -buffer-name=yanks -default-action=append history/yank<CR>
    nnoremap <silent> <Leader>rY :<C-U>Unite -buffer-name=yanks -default-action=insert history/yank<CR>
    nnoremap <silent> <Leader>rm :<C-U>Unite -buffer-name=registers -default-action=append register<CR>
    nnoremap <silent> <Leader>rM :<C-U>Unite -buffer-name=registers -default-action=insert register<CR>

    nnoremap <silent> <Leader>pf :<C-U>UniteWithProjectDir -buffer-name=files -start-insert file file/new<CR>
    nnoremap <silent> <Leader>pd :<C-U>UniteWithProjectDir -buffer-name=direectories -start-insert directory directory/new<CR>

    nnoremap <silent> <Leader>bb :<C-U>Unite -buffer-name=buffers -start-insert buffer_tab<CR>
    nnoremap <silent> <Leader>bB :<C-U>Unite -buffer-name=buffers -start-insert buffer<CR>

    nnoremap <silent> <Leader>ff :<C-U>UniteWithBufferDir -buffer-name=files -start-insert file buffer file/new<CR>
    nnoremap <silent> <Leader>fF :<C-U>Unite -buffer-name=files -start-insert file buffer file/new<CR>
    nnoremap <silent> <Leader>fb :<C-U>Unite -buffer-name=files bookmark directory_mru<CR>

    nnoremap <silent> <Leader>fp :<C-U>UniteWithProjectDir -immediately -input=<C-R>expand('<cword>')<CR> file_rec<CR>
    nnoremap <silent> <Leader>fP :<C-U>UniteWithProjectDir file_rec<CR>

    nnoremap <silent> <Leader>f? :<C-U>Unite line -buffer-name=search -start-insert -input=<C-R><C-W><CR>
    nnoremap <silent> <Leader>f/ :<C-U>Unite line -buffer-name=search -start-insert<CR>

    nnoremap <silent> <Leader>us :<C-U>Unite source<CR>

    nnoremap <silent> <Leader>un :<C-U>UniteNext<CR>
    nnoremap <silent> <Leader>up :<C-U>UnitePrevious<CR>
    nnoremap <silent> <Leader>uc :<C-U>UniteClose<CR>
    nnoremap <silent> <Leader>ur :<C-U>UniteResume -no-start-insert -toggle<CR>
    nnoremap <silent> <Leader>um :<C-U>Unite output:message<CR>

    nnoremap <silent> <Leader> :Unite -silent -start-insert menu:leader_bindings<CR>
    " 误按<Leader>后可以马上按<Esc>取消
    nnoremap <silent> <Leader><Esc> <Nop>
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('editing') "{{{
    " vim-easy-align: 代码对齐插件。普通模式下通过ga启动，visual模式通过回车启用{{{
    NeoBundleLazy 'junegunn/vim-easy-align', {
                \ 'on_map' : ['<Plug>(EasyAlign)', '<Plug>(LiveEasyAlign)', '<Plug>(EasyAlignRepeat)'],
                \ 'on_cmd' : ['EasyAlign', 'LiveEasyAlign'],
                \ }
    if neobundle#tap('vim-easy-align')
        " 对齐过程中禁用foldmethod，以免拖慢速度
        let g:easy_align_bypass_fold = 1
        let g:easy_align_ignore_groups = ['.*Comment.*', 'doxygen.*', 'String']

        if !exists('g:easy_align_delimiters')
            let g:easy_align_delimiters = {}
        endif

        " 对齐各类注释。如//、///、///<、/*、/**、/**<、#、#:、"
        let g:easy_align_delimiters['/'] = {
                    \ 'pattern': '\/\/\+<\?\|\/\*\+<\?\|#\+:\?\|"\+',
                    \ 'delimiter_align': 'l',
                    \ 'ignore_groups': ['!.*Comment.*\|doxygen.*'],
                    \ 'left_margin': 2,
                    \ 'right_margin': 1,
                    \ }

        " 用于定义C++变量声明、函数声明的对齐规则。变量前、注释前的空白字符都
        " 要进行对齐
        " 为易于维护，先定义一个数组，每种形式定义一行，再join起来
        let kw = []
        call add(kw, '\([*&]\+\|\s\)\ze\w\+[*&]*\(\[[^]]*\]\)*\s*[,;=]')                                   " ,;=前的单词。变量前后可以有*和&，可以是数组
        call add(kw, '\([*&]\+\|\s\)\ze\w\+\s*)\(\s*const\)\?\(\s*=\s*0\)\?\s*;\?\s*$') " 函数声明的最后一个参数，行末有可选的const和=0（纯虚函数）
        call add(kw, '\s\ze\/\/.*\|\/\*.*')                                 " 注释

        " 对齐C++变更声明。*d会把后面的注释也一起对齐
        let g:easy_align_delimiters['d'] = {
                    \ 'pattern': '\(' . join(kw, '\|') . '\)',
                    \ 'left_margin': 0, 'right_margin': 0
                    \ }

        " Start interactive EasyAlign in visual mode
        vmap <silent> <Enter> <Plug>(EasyAlign)

        " Start interactive EasyAlign for a motion/text object (e.g. <Leader>xaip)
        nmap <silent> <Leader>xa <Plug>(EasyAlign)
        vmap <silent> <Leader>xa <Plug>(EasyAlign)

        vmap <silent> <Leader>xad <Plug>(EasyAlign)*dgv<Plug>(EasyAlign)/
        vmap <silent> <Leader>xa= <Plug>(EasyAlign)*=<CR>
        vmap <silent> <Leader>xa: <Plug>(EasyAlign):<CR>
        vmap <silent> <Leader>xa. <Plug>(EasyAlign).<CR>
        vmap <silent> <Leader>xa, <Plug>(EasyAlign)*,<CR>
        vmap <silent> <Leader>xa& <Plug>(EasyAlign)&<CR>
        vmap <silent> <Leader>xa# <Plug>(EasyAlign)#<CR>
        vmap <silent> <Leader>xa" <Plug>(EasyAlign)"<CR>
        vmap <silent> <Leader>xa{ <Plug>(EasyAlign){<CR>
        vmap <silent> <Leader>xa} <Plug>(EasyAlign)}<CR>
        vmap <silent> <Leader>xa/ <Plug>(EasyAlign)/<CR>
        vmap <silent> <Leader>xa<Bar> <Plug>(EasyAlign)*<Bar><CR>
        vmap <silent> <Leader>xa<Space> <Plug>(EasyAlign)*<Space><CR>

        call neobundle#untap()
    endif
    " }}}
    " vim-operator-replace: 双引号x_{motion} : 把{motion}涉及的内容替换为register x的内容 {{{
    NeoBundleLazy 'kana/vim-operator-replace', {
                \ 'depends' : 'kana/vim-operator-user',
                \ 'on_map' : [
                \     ['nx', '<Plug>(operator-replace)']
                \ ]}
    nmap <silent> _  <Plug>(operator-replace)
    xmap <silent> _  <Plug>(operator-replace)
    " }}}
    " vim-operator-surround: sa{motion}/sd{motion}/sr{motion}：增/删/改括号、引号等 {{{
    NeoBundleLazy 'rhysd/vim-operator-surround', {
                \ 'depends' : 'kana/vim-operator-user',
                \ 'on_map' : [
                \     ['nxo', '<Plug>(operator-surround'],
                \ ]}
    " operator mappings
    nmap <silent>sa <Plug>(operator-surround-append)
    nmap <silent>sd <Plug>(operator-surround-delete)
    nmap <silent>sr <Plug>(operator-surround-replace)
    omap <silent>sa <Plug>(operator-surround-append)
    omap <silent>sd <Plug>(operator-surround-delete)
    omap <silent>sr <Plug>(operator-surround-replace)
    xmap <silent>sa <Plug>(operator-surround-append)
    xmap <silent>sd <Plug>(operator-surround-delete)
    xmap <silent>sr <Plug>(operator-surround-replace)
    " }}}
    " vim-pairs: ci/, di;, yi*, vi@, ca/, da;, ya*, va@ ... {{{
    NeoBundle 'kurkale6ka/vim-pairs'
    " }}}
    " DrawIt: 使用横、竖线画图、制表。\di和\ds分别启、停画图模式。在模式中，hjkl移动光标，方向键画线 {{{
    NeoBundleLazy 'DrawIt', {
                \ 'on_map' : [['n', '<Leader>di']],
                \ 'on_cmd' : ['DIstart', 'DIsngl', 'DIdbl', 'DrawIt'],
                \ }
    " }}}
    " vim-multiple-cursors: 同时编辑多处。<C-n>选择当前word并跳到下一个相同word；<C-p>取消当前word，跳回上个；<C-x>跳过当前word到下一个 {{{
    NeoBundleLazy 'terryma/vim-multiple-cursors', {
                \ 'on_map' : [ '<C-N>' ],
                \ 'on_cmd' : [ 'MultipleCursorsFind' ],
                \ }
    " 进入multiple cursors时禁用neocomplete
    " Called once right before you start selecting multiple cursors
    function! Multiple_cursors_before()
        if exists(':NeoCompleteLock')==2
            exe 'NeoCompleteLock'
        endif
    endfunction

    " Called once only when the multiple selection is canceled (default <Esc>)
    function! Multiple_cursors_after()
        if exists(':NeoCompleteUnlock')==2
            exe 'NeoCompleteUnlock'
        endif
    endfunction
    " }}}
    " 为函数插入Doxygen注释。在函数名所在行输入 :Dox 即可 {{{
    NeoBundleLazy 'DoxygenToolkit.vim', {
                \ 'on_cmd' : ['Dox', 'DoxLic', 'DoxAuthor', 'DoxUndoc', 'DoxBlock'],
                \ }
    let g:DoxygenToolkit_briefTag_pre="@brief "
    let g:DoxygenToolkit_paramTag_pre="@param[in] "
    let g:DoxygenToolkit_returnTag="@return "
    " }}}
    " 记录代码走查意见，\ic激活。可通过 cfile <文件名> 把记录走查意见的文件导入 quickfix 列表 {{{
    NeoBundleLazy 'CodeReviewer.vim', {
                \ 'on_cmd' : ['CheckReview'],
                \ 'on_map' : ['<Leader>ic'],
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
    " }}}
    " tcomment_vim: 注释工具。gc{motion}/gcc/<C-_>等 {{{
    NeoBundleLazy 'tomtom/tcomment_vim', {
                \ 'on_map': '<Plug>TComment',
                \ 'on_func': ['tcomment#Complete', 'tcomment#CompleteArgs'],
                \ 'on_cmd': [
                \     { 'name': 'TComment', 'complete':'customlist,tcomment#CompleteArgs' },
                \     { 'name': 'TCommentAs', 'complete':'customlist,tcomment#Complete' } ,
                \     { 'name': 'TCommentRight', 'complete':'customlist,tcomment#CompleteArgs' },
                \     { 'name': 'TCommentBlock', 'complete':'customlist,tcomment#CompleteArgs' },
                \     { 'name': 'TCommentInline', 'complete':'customlist,tcomment#CompleteArgs' },
                \     { 'name': 'TCommentMaybeInline', 'complete':'customlist,tcomment#CompleteArgs' },
                \ ]}
    nnoremap <silent> <Leader>cl :TComment<CR>
    vnoremap <silent> <Leader>cl :TCommentMaybeInline<CR>
    xmap <silent> <Leader>c <Plug>TComment_gc
    nmap <silent> <Leader>c <Plug>TComment_gc
    " }}}
    " syntastic: 保存文件时自动进行合法检查。:SyntasticCheck 执行检查， :Errors 打开错误列表 {{{
    NeoBundle 'scrooloose/syntastic'
    " let g:syntastic_mode_map = {
    "             \ 'mode': 'active',
    "             \ 'active_filetypes': ['ruby', 'php', 'python'],
    "             \ 'passive_filetypes': ['cpp'] }

    let g:syntastic_html_tidy_ignore_errors=[
                \ " proprietary attribute ",
                \ "trimming empty <",
                \ "unescaped &",
                \ "lacks \"action",
                \ "attribute \"href\" lacks value",
                \ "is not recognized!",
                \ "discarding unexpected"]

    let g:syntastic_mode_map = {
                \ "mode": "active",
                \ "active_filetypes": [],
                \ "passive_filetypes": ["asciidoc"] }

    let g:syntastic_cpp_checkers = ['cpplint']
    " 0: 不会自动打开、关闭 1: 自动打开及关闭 2: 没错误时自动关闭，但不会自动打开
    let g:syntastic_auto_loc_list=2
    " if executable('python2')
    "     let g:syntastic_python_python_exec = 'python2'
    " endif
    " }}}
    " vim-repeat: 把.能重复的操作扩展到一些插件中的操作 {{{
    NeoBundleLazy 'tpope/vim-repeat', {
                \ 'on_map' : ['n', '.', 'u', 'U', '<C-R>'],
                \ 'function_prefix' : 'repeat',
                \ }
    " }}}
    " visualrepeat: visual下使用.重复上次操作 {{{
    NeoBundleLazy 'visualrepeat', {
                \ 'on_map' : ['x', '.'],
                \ 'function_prefix' : 'visualrepeat',
                \ }
    " }}}
    " vinarise: Hex Editor {{{
    NeoBundleLazy 'Shougo/vinarise', {
                \ 'on_cmd' : ['Vinarise', 'VinariseDump', 'VinariseScript2Hex'],
                \ }
    " }}}
    " undotree: 列出修改历史，方便undo到一个特定的位置 {{{
    NeoBundleLazy 'mbbill/undotree', {
                \ 'on_cmd' : ['UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus'],
                \ }
    nnoremap <silent> <Leader>au :UndotreeToggle<CR>
    " }}}
    " FastFold: 编辑时不自动更新折叠，在保存或手工进行折叠操作时才更新。zuz刷新{{{
    NeoBundleLazy 'Konfekt/FastFold', {
                \ 'on_path' : ['.*'],
                \ }
    let g:fastfold_savehook = 0
    " }}}
    " vim-fakeclip: 为vim在终端等场合提供&/+/"寄存器，其中&支持tmux/screen缓冲区 {{{
    NeoBundle 'kana/vim-fakeclip'
    " }}}
    " vim-bracketed-paste: 支持bracketed paste mode，在支持此功能的终端下，自动进入paste模式 {{{
    NeoBundle 'ConradIrwin/vim-bracketed-paste'
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('snippet') "{{{
    " ultisnips: 以python实现的代码模板引擎 {{{
    NeoBundleLazy 'SirVer/ultisnips', {
                \ 'depends' : 'honza/vim-snippets',
                \ }
    call neobundle#config('ultisnips', {
                \ 'on_i' : 1,
                \ 'lazy' : 0,
                \ })

    let g:UltiSnipsSnippetsDir = s:vimrc_path . '/mysnippets'
    let g:UltiSnipsSnippetDirectories=['UltiSnips', 'mysnippets']

    let g:UltiSnipsEnableSnipMate = 0

    " let g:UltiSnipsExpandTrigger       = '<TAB>'
    " let g:UltiSnipsListSnippets        = '<C-TAB>'
    "
    " inoremap <silent><expr> <TAB>
    "     \ pumvisible() ? "\<C-n>" :
    "     \ (len(keys(UltiSnips#SnippetsInCurrentScope())) > 0 ?
    "     \ "<C-R>=UltiSnips#ExpandSnippet()<CR>" : "\<TAB>")

    let g:ulti_expand_or_jump_res = 0
    function! ExpandSnippetOrJumpForwardOrReturn(next)
        " 如果可以展开就展开，可以跳转就跳转，否则返回参数指定的值
        let snippet = UltiSnips#ExpandSnippetOrJump()
        if g:ulti_expand_or_jump_res > 0
            return snippet
        else
            return a:next
        endif
    endfunction

    " let g:UltiSnipsJumpForwardTrigger="<TAB>"
    " let g:UltiSnipsJumpForwardTrigger="<NOP>"
    " inoremap <silent><expr> <TAB>
    "             \ pumvisible() ? "\<C-n>" :
    "             \ "<C-R>=ExpandSnippetOrJumpForwardOrReturn('\<TAB>')<CR>"

    " let g:UltiSnipsJumpBackwordTrigger = "<S-TAB>"
    " " previous menu item, jump to previous placeholder or do nothing
    " let g:UltiSnipsJumpBackwordTrigger = "<NOP>"
    " inoremap <expr> <S-TAB>
    "             \ pumvisible() ? "\<C-p>" :
    "             \ "<C-R>=UltiSnips#JumpBackwards()<CR>"
    "
    " " jump to previous placeholder otherwise do nothing
    " snoremap <buffer> <silent> <S-TAB>
    "             \ <ESC>:call UltiSnips#JumpBackwards()<CR>

    call neobundle#untap()

    " 回车直接展开当前选中的snippet
    inoremap <silent><expr> <CR>
                \ pumvisible() ?
                \ "\<C-y><C-R>=ExpandSnippetOrJumpForwardOrReturn('')<CR>" :
                \ "\<CR>"
    nnoremap <silent> <Leader>is :<C-U>Unite ultisnips<CR>
    "}}}
endif
"}}}

if s:is_plugin_group_enabled('navigation.searching') "{{{
    " vim-abolish: :%S/box{,es}/bag{,s}/g进行单复数、大小写对应的查找 {{{
    NeoBundleLazy 'tpope/vim-abolish', {
                \ 'on_map' : [
                \   ['n', '<Plug>Coerce'],
                \   ['n', 'cr'],
                \ ],
                \ 'on_cmd' : [ 'Abolish', 'Subvert', 'S' ],
                \ }
    " }}}
    " ack.vim: 用ack/ag快速查找文件 "{{{
    NeoBundleLazy 'mileszs/ack.vim', {
                \ 'on_cmd' : [
                \     {'name': 'Ack', 'complete': 'file'},
                \     {'name': 'AckAdd', 'complete': 'file'},
                \     {'name': 'AckFromSearch', 'complete': 'file'},
                \     {'name': 'LAck', 'complete': 'file'},
                \     {'name': 'LAckAdd', 'complete': 'file'},
                \     {'name': 'AckFile', 'complete': 'file'},
                \     {'name': 'AckHelp', 'complete': 'help'},
                \     {'name': 'LAckHelp', 'complete': 'help'},
                \     'AckWindow', 'LAckWindow',
                \ ]}
    if g:dotvim_settings.commands.ag != ""
        let g:ackprg = g:dotvim_settings.commands.ag . " --vimgrep --nogroup --column --smart-case --follow"
    endif

    " let g:ackhighlight = 1
    " let g:ack_autoclose = 1
    " let g:ack_autofold_results = 1
    " let g:ackpreview = 1
    " let g:ack_use_dispatch = 1

    " 在项目目录下找，可能退化为当前目录
    vmap <silent> <Leader>sP :ProjectRootExe Ack! <C-R>=g:CtrlSFGetVisualSelection()<CR><CR>
    nmap <silent> <Leader>sP :<C-U>ProjectRootExe Ack! <C-R>=expand('<cword>')<CR><CR>
    nmap <silent> <Leader>sp :<C-U>ProjectRootExe Ack!<SPACE>
    nmap <silent> <Leader>/  :<C-U>ProjectRootExe Ack!<SPACE>

    " 在当前文件目录下找
    vmap <silent> <Leader>sF :BufferDirExe Ack! <C-R>=g:CtrlSFGetVisualSelection()<CR><CR>
    nmap <silent> <Leader>sF :<C-U>BufferDirExe Ack! <C-R>=expand('<cword>')<CR><CR>
    nmap <silent> <Leader>sf :<C-U>BufferDirExe Ack!<SPACE>

    " 在当前目录下找
    vmap <silent> <Leader>sB :Ack! <C-R>=g:CtrlSFGetVisualSelection()<CR><CR>
    nmap <silent> <Leader>sB :<C-U>Ack! <C-R>=expand('<cword>')<CR><CR>
    nmap <silent> <Leader>sb :<C-U>Ack!<SPACE>
    "}}}
    " ctrlsf.vim: 快速查找及编辑 {{{
    NeoBundleLazy 'dyng/ctrlsf.vim', {
                \ 'on_map' : [ '<Plug>CtrlSF' ],
                \ 'on_cmd' : [
                \     {'name': 'CtrlSF', 'complete': 'customlist,ctrlsf#comp#Completion'},
                \     'CtrlSFOpen', 'CtrlSFUpdate', 'CtrlSFClose', 'CtrlSFClearHL', 'CtrlSFToggle',
                \ ]}
    if g:dotvim_settings.commands.ag != ""
        let g:ctrlsf_ackprg = g:dotvim_settings.commands.ag
    endif

    " let g:ctrlsf_default_root = 'project+fw'
    let g:ctrlsf_default_root = 'cwd'

    " 在project下找
    vmap <silent> <Leader>sfP :CtrlSF <C-R>=g:CtrlSFGetVisualSelection()<CR> <C-R>=projectroot#guess()<CR><CR>
    nmap <silent> <Leader>sfP :<C-U>CtrlSF <C-R>=expand('<cword>')<CR> <C-R>=projectroot#guess()<CR><CR>
    nmap <silent> <Leader>sfp :<C-U>ProjectRootExe CtrlSF -regex<SPACE>

    " 在当前文件目录下找
    vmap <silent> <Leader>sfB :CtrlSF <C-R>=g:CtrlSFGetVisualSelection()<CR> <C-R>=expand('%:p:h')<CR><CR>
    nmap <silent> <Leader>sfB :<C-U>CtrlSF <C-R>=expand('<cword>')<CR> <C-R>=expand('%:p:h')<CR><CR>
    nmap <silent> <Leader>sfb :<C-U>ProjectRootExe CtrlSF<SPACE>

    " 在当前目录下找
    vmap <silent> <Leader>sfC :CtrlSF <C-R>=g:CtrlSFGetVisualSelection()<CR> <C-R>=getcwd()<CR><CR>
    nmap <silent> <Leader>sfC :<C-U>CtrlSF <C-R>=expand('<cword>')<CR> <C-R>=getcwd()<CR><CR>
    nmap <silent> <Leader>sfc :<C-U>CtrlSF<SPACE>

    nmap <silent> <Leader>sfr <Plug>CtrlSFPwordPath
    nmap <silent> <Leader>sfR <Plug>CtrlSFPwordExec

    nnoremap <silent> <Leader>sfo :CtrlSFOpen<CR>
    nnoremap <silent> <Leader>sft :CtrlSFToggle<CR>
    " }}}
    " Mark--Karkat: 可同时标记多个mark。\M显隐所有，\N清除所有Mark。\m标识当前word {{{
    NeoBundleLazy 'vernonrj/Mark--Karkat'
    if v:version >= '701'
        call neobundle#config('Mark--Karkat', {
                \ 'on_cmd' : ['Mark', 'MarkClear', 'Marks', 'MarkLoad', 'MarkSave', 'MarkPalette'],
                \ 'on_map' : [
                \     '<Plug>Mark',
                \ ],
                \ })

        nmap <silent><unique> <Leader>mm <Plug>MarkSet
        xmap <silent><unique> <Leader>mm <Plug>MarkSet
        nmap <silent><unique> <Leader>mr <Plug>MarkRegex
        xmap <silent><unique> <Leader>mr <Plug>MarkRegex
        nmap <silent><unique> <Leader>mc <Plug>MarkClear
        nmap <silent><unique> <Leader>mM <Plug>MarkToggle
        nmap <silent><unique> <Leader>mC <Plug>MarkAllClear

        nmap <silent><unique> <Leader>mn <Plug>MarkSearchCurrentNext
        nmap <silent><unique> <Leader>mp <Plug>MarkSearchCurrentPrev
        nmap <silent><unique> <Leader>mN <Plug>MarkSearchAnyNext
        nmap <silent><unique> <Leader>mP <Plug>MarkSearchAnyPrev
        nmap <silent><unique> <Plug>IgnoreMarkSearchNext <Plug>MarkSearchNext
        nmap <silent><unique> <Plug>IgnoreMarkSearchPrev <Plug>MarkSearchPrev

        " 在插件载入后再执行修改颜色的操作
        autocmd vimrc VimEnter *
                    \ highlight MarkWord1 ctermbg=DarkCyan    ctermfg=Black guibg=#8CCBEA guifg=Black |
                    \ highlight MarkWord2 ctermbg=DarkMagenta ctermfg=Black guibg=#FF7272 guifg=Black |
                    \ highlight MarkWord3 ctermbg=DarkYellow  ctermfg=Black guibg=#FFDB72 guifg=Black |
                    \ highlight MarkWord4 ctermbg=DarkGreen   ctermfg=Black guibg=#FFB3FF guifg=Black |
                    \ highlight MarkWord5 ctermbg=DarkRed     ctermfg=Black guibg=#9999FF guifg=Black |
                    \ highlight MarkWord6 ctermbg=DarkBlue    ctermfg=Black guibg=#A4E57E guifg=Black
    endif
    " }}}
    " vim-easymotion: \\w启动word motion，\\f<字符>启动查找模式 {{{
    if v:version >= '703'
        NeoBundleLazy 'Lokaltog/vim-easymotion', {
                    \ 'on_map' : [['n'] + map(
                    \     ['f', 'F', 's', 't', 'T', 'w', 'W', 'b', 'B', 'e', 'E', 'ge', 'gE', 'j', 'k', 'n', 'N'],
                    \     '"<Leader><Leader>" . v:val'),
                    \     '<Plug>(easymotion-',
                    \ ],
                    \ }
        let g:EasyMotion_startofline = 0
        let g:EasyMotion_smartcase = 1
        let g:EasyMotion_do_shade = 1

        let g:EasyMotion_use_upper = 1
        let g:EasyMotion_keys = 'ASDGHKLQWERTYUIOPZXCVBNMFJ;'

        hi link EasyMotionTarget Search
        hi link EasyMotionTarget2First IncSearch
        hi link EasyMotionTarget2Second IncSearch
        hi link EasyMotionShade Comment

        nmap <Leader>jl <Plug>(easymotion-bd-jk)
        xmap <Leader>jl <Plug>(easymotion-bd-jk)
        omap <Leader>jl <Plug>(easymotion-bd-jk)

        nmap <Leader>jw <Plug>(easymotion-s2)
        xmap <Leader>jw <Plug>(easymotion-s2)
        omap <Leader>jw <Plug>(easymotion-s2)
    endif
    " }}}
    " vim-highlight-cursor-words: 高亮与光标下word一样的词 {{{
    NeoBundle 'pboettch/vim-highlight-cursor-words'

    let g:HiCursorWords_delay = 200
    " let g:HiCursorWords_hiGroupRegexp = ''
    " let g:HiCursorWords_hiGroupRegexp = 'Identifier\|vimOperParen'
    let g:HiCursorWords_debugEchoHiName = 0
    let g:HiCursorWords_visible = 1
    " let g:HiCursorWords_style = ''
    let g:HiCursorWords_linkStyle = 'Underlined'

    nmap <Leader>tha :call HiCursorWords_toggle()<CR>
    " }}}
    " ExtractMatches: 可以拷贝匹配pattern的内容 {{{
    NeoBundleLazy 'ExtractMatches', {
                \ 'on_cmd' : [
                \     'GrepToReg', 'YankMatches', 'YankUniqueMatches',
                \     'PrintMatches', 'PrintUniqueMatches', 'SubstituteAndYank ',
                \     'SubstituteAndYankUnique', 'PutMatches', 'PutUniqueMatches',
                \ ],
                \ }
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('navigation.jumping') "{{{
    " FSwitch: 在头文件和CPP文件间进行切换。用:A调用。\ol在右边分隔一个窗口显示，\of当前窗口 {{{
    NeoBundleLazy 'derekwyatt/vim-fswitch', {
                \ 'on_func' : ['FSwitch'],
                \ 'on_cmd' : ['FSHere','FSRight','FSSplitRight','FSLeft','FSSplitLeft','FSAbove','FSSplitAbove','FSBelow','FSSplitBelow'],
                \ }
    let g:fsnonewfiles=1
    " 可以用:A在.h/.cpp间切换
    command! A :call FSwitch('%', '')
    autocmd! vimrc BufEnter *.h,*.hpp
                \  let b:fswitchdst='cpp,c,ipp,cxx'
                \| let b:fswitchlocs='reg:/include/src/,reg:/include.*/src/,ifrel:|/include/|../src|,reg:!\<include/\w\+/!src/!,reg:!\<include/\(\w\+/\)\{2}!src/!,reg:!\<include/\(\w\+/\)\{3}!src/!,reg:!\<include/\(\w\+/\)\{4}!src/!,reg:!sscc\(/[^/]\+\|\)/.*!libs\1/**!'
    autocmd! vimrc BufEnter *.c,*.cpp,cxx,*.ipp
                \  let b:fswitchdst='h,hpp'
                \| let b:fswitchlocs='reg:/src/include/,reg:|/src|/include/**|,ifrel:|/src/|../include|,reg:|libs/.*|**|'
    autocmd! vimrc BufEnter *.xml
                \  let b:fswitchdst='rnc'
                \| let b:fswitchlocs='./'
    autocmd! vimrc BufEnter *.rnc
                \  let b:fswitchdst='xml'
                \| let b:fswitchlocs='./'

    " Switch to the file and load it into the current window >
    nmap <silent> <Leader>mga :FSHere<CR>
    " Switch to the file and load it into a new window split on the right >
    nmap <silent> <Leader>mgA :FSSplitRight<CR>
    " Switch to the file and load it into the window on the right >
    nmap <silent> <Leader>mgl :FSRight<CR>
    " Switch to the file and load it into a new window split on the right >
    nmap <silent> <Leader>mgL :FSSplitRight<CR>
    " Switch to the file and load it into the window on the left >
    nmap <silent> <Leader>mgh :FSLeft<CR>
    " Switch to the file and load it into a new window split on the left >
    nmap <silent> <Leader>mgH :FSSplitLeft<CR>
    " Switch to the file and load it into the window above >
    nmap <silent> <Leader>mgk :FSAbove<CR>
    " Switch to the file and load it into a new window split above >
    nmap <silent> <Leader>mgK :FSSplitAbove<CR>
    " Switch to the file and load it into the window below >
    nmap <silent> <Leader>mgj :FSBelow<CR>
    " Switch to the file and load it into a new window split below >
    nmap <silent> <Leader>mgJ :FSSplitBelow<CR>
    " }}}
    " vim-bufsurf: :BufSurfForward/:BufSurfBack跳转到本窗口的下一个、上一个buffer（增强<C-I>/<C-O>） {{{
    NeoBundleLazy 'ton/vim-bufsurf', {
                \ 'on_cmd' : ['BufSurfForward', 'BufSurfBack'],
                \ }
    " g<C-I>/g<C-O>直接跳到不同的buffer
    nnoremap <silent> g<C-I> :BufSurfForward<CR>
    nnoremap <silent> g<C-O> :BufSurfBack<CR>
    " }}}
    " vim-gf-user: 扩展gf {{{
    NeoBundleLazy 'kana/vim-gf-user', {
                \ 'on_cmd' : 'GfUserDefaultKeyMappings',
                \ 'on_map' : [['nv', '<Plug>(gf-user-']],
                \ 'depends' : [
                \     'sgur/vim-gf-autoload',
                \     'kana/vim-gf-diff',
                \     'hujo/gf-user-vimfn',
                \ ]}
    " }}}
    " vim-ref: 按K查找各种资料 {{{
    NeoBundleLazy 'thinca/vim-ref', {
                \ 'on_cmd' : [
                \   { 'name' : 'Ref', 'complete' : 'customlist,ref#complete' },
                \ ],
                \ 'on_map' : ['nv', 'K', '<Plug>(ref-keyword)'],
                \ 'on_source': ['unite.vim'],
                \ }
    let g:ref_man_cmd = executable('man') ? 'man' : ''
    nnoremap <silent> <Leader>hm :<C-U>Unite -buffer-name=helps -start-insert ref/man<CR>
    nnoremap <silent> <Leader>hM :<C-U>UniteWithCursorWord -buffer-name=helps ref/man<CR>
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('navigation.tagging') "{{{
    " tagbar: 列出文件中所有类和方法。用<F9>调用 {{{
    NeoBundleLazy 'majutsushi/tagbar', {
                \ 'on_cmd' : [
                \     'TagbarToggle', 'TagbarCurrentTag', 'Tagbar',
                \     'TagbarOpen', 'TagbarOpenAutoClose', 'TagbarClose',
                \     'TagbarSetFoldlevel', 'TagbarShowTag', 'TagbarGetTypeConfig',
                \     'TagbarDebug', 'TagbarDebugEnd', 'TagbarTogglePause',
                \ ]}
    let g:tagbar_left = 1

    nnoremap <silent> g<F9> :<C-U>TagbarCurrentTag fs<CR>
    nnoremap <silent> <F9> :<C-U>TagbarToggle<CR>

    let g:tagbar_ctags_bin = g:dotvim_settings.commands.ctags

    let g:tagbar_type_jam = {
                \ 'ctagstype' : 'jam',
                \ 'kinds' : [
                \ 's:Table of Contents:1:1',
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
                \ 'deffile' : s:vimrc_path . '/ctags/neosnippet.cnf',
                \ }
    let g:tagbar_type_asciidoc = {
                \ 'ctagstype' : 'asciidoc',
                \ 'kinds' : [
                \   'h:Table of content',
                \   'a:anchors:1',
                \   't:titles:1',
                \   'n:includes:1',
                \   'i:images:1',
                \   'I:inline images:1'
                \ ],
                \ 'sort' : 0,
                \ 'deffile' : s:vimrc_path . '/ctags/asciidoc.cnf',
                \ }
    let g:tagbar_type_markdown = {
                \ 'ctagstype' : 'markdown',
                \ 'kinds' : [
                \   'h:Table of content',
                \ ],
                \ 'sort' : 0,
                \ 'deffile' : s:vimrc_path . '/ctags/markdown.cnf',
                \ }
    " }}}
    " gtags.vim: 直接调用gtags查找符号 {{{
    if g:dotvim_settings.commands.global != ''
        NeoBundleLazy 'harish2704/gtags.vim'
        call neobundle#config('gtags.vim', {
                    \ 'on_cmd' : [
                    \     { 'name' : 'Gtags', 'complete' : 'custom,GtagsCandidate' },
                    \     { 'name' : 'Gtagsa', 'complete' : 'custom,GtagsCandidate' },
                    \     "GtagsCursor","Gozilla","GtagsUpdate","GtagsCscope"
                    \ ],
                    \ 'on_func' : [
                    \     'GtagsCandidate',
                    \ ],
                    \ })

        let g:Gtags_Auto_Update = 1
        let g:Gtags_Auto_Map = 0
        let g:Gtags_No_Auto_Jump = 0
        let g:GtagsCscope_Auto_Load = 0

        nmap <silent> <Leader>p<C-g> :GtagsUpdate<CR>
    endif
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('navigation.moving') "{{{
    " 启用内置的matchit插件 {{{
    if filereadable($VIMRUNTIME . "/macros/matchit.vim")
        source $VIMRUNTIME/macros/matchit.vim
    endif
    "}}}
    " vim-tmux-navigator: 使用ctrl+i/j/k/l在vim及tmux间切换 {{{
    NeoBundleLazy 'christoomey/vim-tmux-navigator', {
                \ 'on_cmd' : ['TmuxNavigateLeft', 'TmuxNavigateDown', 'TmuxNavigateUp', 'TmuxNavigateRight', 'TmuxNavigatePrevious'],
                \ }
    " 需要在tmux.conf中加入下列内容
    " # Smart pane switching with awareness of vim splits
    " is_vim='echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(view|n?vim?)(diff)?$"'
    " bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
    " bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
    " bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
    " bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
    " bind -n C-\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"

    " 不希望map <C-\>，因此自行map
    let g:tmux_navigator_no_mappings = 1
    nnoremap <silent> <c-h> :TmuxNavigateLeft<CR>
    nnoremap <silent> <c-j> :TmuxNavigateDown<CR>
    nnoremap <silent> <c-k> :TmuxNavigateUp<CR>
    nnoremap <silent> <c-l> :TmuxNavigateRight<CR>
    " }}}
    " vim-niceblock: 增强对块选操作的支持 {{{
    NeoBundleLazy 'kana/vim-niceblock', {
                \ 'on_map' : ['v', 'I', 'A'],
                \ }
    " }}}
    " vim-expand-region: 选择模式下，按+/_扩展和收缩选区 {{{
    NeoBundleLazy 'terryma/vim-expand-region', {
                \ 'on_map' : [['nv', '<Plug>(expand_region_']],
                \ }
    nmap <silent> + <Plug>(expand_region_expand)
    vmap <silent> + <Plug>(expand_region_expand)
    vmap <silent> _ <Plug>(expand_region_shrink)
    nmap <silent> _ <Plug>(expand_region_shrink)
    " }}}
    "" vis: 在块选后（<C-V>进行选择），:B cmd在选中内容中执行cmd {{{
    "NeoBundleLazy 'vis', {
    "    \ 'on_cmd' : ['B'],
    "    \ }
    "" }}}
endif
"}}}

if s:is_plugin_group_enabled('navigation.autocomplete') "{{{
    if g:dotvim_settings.autocomplete_method == 'neocomplete' && v:version >= '703' && has('lua')
        NeoBundleLazy 'Shougo/neocomplete' " {{{
        call neobundle#config('neocomplete', {
                    \ 'on_i' : 1,
                    \ })

        "let g:neocomplete_enable_debug = 1
        let g:neocomplete#enable_at_startup = 1
        " Disable auto completion, if set to 1, must use <C-x><C-U>
        let g:neocomplete#disable_auto_complete = 0
        " Use smartcase.
        let g:neocomplete#enable_smart_case = 1
        " Set minimum syntax keyword length.
        let g:neocomplete#sources#syntax#min_syntax_length = 3
        let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
        let g:neocomplete#enable_auto_select = 0
        let g:neocomplete#auto_completion_start_length = 3
        let g:neocomplete#data_directory=s:get_cache_dir('neocomplete')

        if v:version == '704' && !has("patch-7.4.633")
            " neocomplete issue #332
            let g:neocomplete#enable_fuzzy_completion = 0
        endif

        " Define dictionary.
        let g:neocomplete#sources#dictionary#dictionaries = {
                    \ 'default' : '',
                    \ 'vimshell' : expand(g:dotvim_settings.cache_dir.'/.vimshell_hist'),
                    \ 'scheme' : expand(g:dotvim_settings.cache_dir.'/.gosh_completions')
                    \ }

        " 安装neocomplete后才进行相关的map
        if neobundle#tap('neocomplete')
            function! neobundle#hooks.on_source(bundle)
                " Plugin key-mappings.
                inoremap <silent><expr><C-g>     neocomplete#undo_completion()
                inoremap <silent><expr><C-l>     neocomplete#complete_common_string()

                " Recommended key-mappings.
                " <CR>: close popup and save indent.
                inoremap <silent><expr><CR>  pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
                " " <TAB>: next.
                " inoremap <silent><expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
                " " <S-TAB>: prev.
                " inoremap <silent><expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"
                " <C-h>, <BS>: close popup and delete backword char.
                inoremap <silent><expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
                inoremap <silent><expr><BS> neocomplete#smart_close_popup()."\<C-h>"
                inoremap <silent><expr><C-y>  neocomplete#close_popup()
                inoremap <silent><expr><C-e>  neocomplete#cancel_popup()
            endfunction

            call neobundle#untap()
        endif

        " Enable omni completion.
        autocmd vimrc FileType css setlocal omnifunc=csscomplete#CompleteCSS
        autocmd vimrc FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
        autocmd vimrc FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
        autocmd vimrc FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
        if neobundle#is_installed("jedi-vim")
            autocmd vimrc FileType python setlocal omnifunc=jedi#completions
            let g:jedi#completions_enabled = 0
            let g:jedi#auto_vim_configuration = 0 " 解决neocomplete下自动补第一个候选项的问题
        else
            autocmd vimrc FileType python setlocal omnifunc=pythoncomplete#Complete
        endif

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
        " }}}
    endif

    if neobundle#tap('neocomplete')
        call neobundle#untap()

        " neoinclude.vim: 对include进行补全 {{{
        NeoBundleLazy 'Shougo/neoinclude.vim', {
                    \ 'on_i' : 1,
                    \ }
        " }}}
        " echodoc: 代码补全插件 {{{
        NeoBundleLazy 'Shougo/echodoc', {
                    \ 'on_cmd' : ['EchoDocEnable', 'EchoDocDisable'],
                    \ 'on_i' : 1,
                    \ }
        " }}}
        " neco-syntax: 利用syntax文件进行补全 {{{
        NeoBundleLazy 'Shougo/neco-syntax', {
                    \ 'on_i' : 1,
                    \ }
        " }}}
        " neco-vim: 对vim文件进行补全 {{{
        NeoBundleLazy 'Shougo/neco-vim', {
                    \ 'on_ft' : ['vim',],
                    \ 'on_i' : 1,
                    \ }
        " }}}
        " tmux-complete.vim: 可以补全其它tmux窗口中出现过的词 {{{
        NeoBundleLazy 'wellle/tmux-complete.vim'
        if executable('tmux')
            call neobundle#config('tmux-complete.vim', {
                        \ 'on_i' : 1,
                        \ })
            let g:tmuxcomplete#trigger = ''
        endif
        " }}}
    endif
endif
"}}}

if s:is_plugin_group_enabled('navigation.textobj') "{{{
    " vim-textobj-indent: 增加motion: ai ii（含更深缩进） aI iI（仅相同缩进） {{{
    NeoBundle 'kana/vim-textobj-indent', {
               \ 'depends' : 'kana/vim-textobj-user',
               \ }
    " }}}
    " vim-textobj-line: 增加motion: al il {{{
    NeoBundle 'kana/vim-textobj-line', {
               \ 'depends' : 'kana/vim-textobj-user',
               \ }
    " }}}
    " vim-textobj-function: 增加motion: if/af/iF/aF 选择一个函数 {{{
    NeoBundle 'kana/vim-textobj-function', {
               \ 'depends' : 'kana/vim-textobj-user',
               \ }
    " }}}
    " CamelCaseMotion: 增加,w ,b ,e 可以处理大小写混合或下划线分隔两种方式的单词 {{{
    NeoBundle 'bkad/CamelCaseMotion'
    " }}}
    " vim-textobj-comment: 增加motion: ac ic {{{
    NeoBundle 'thinca/vim-textobj-comment', {
               \ 'depends' : 'kana/vim-textobj-user',
               \ }
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('scm') "{{{
    " vc.vim {{{
    NeoBundleLazy 'juneedahamed/vc.vim', {
                \ 'on_cmd' : [
                \     {'name' : 'VCAdd',                  'complete' : 'customlist,vc#cmpt#Add'},
                \     {'name' : 'VCBlame',                'complete' : 'customlist,vc#cmpt#Blame'},
                \     {'name' : 'VCBrowse'},
                \     {'name' : 'VCBrowseBookMarks'},
                \     {'name' : 'VCBrowseBuffer'},
                \     {'name' : 'VCBrowseMyList'},
                \     {'name' : 'VCBrowseRepo',           'complete' : 'customlist,vc#cmpt#BrowseRepo'},
                \     {'name' : 'VCBrowseWorkingCopy',    'complete' : 'dir'},
                \     {'name' : 'VCBrowseWorkingCopyRec', 'complete' : 'dir'},
                \     {'name' : 'VCClearCache'},
                \     {'name' : 'VCCommit',               'complete' : 'customlist,vc#cmpt#Commit'},
                \     {'name' : 'VCCopy',                 'complete' : 'customlist,vc#cmpt#Copy'},
                \     {'name' : 'VCDefaultrepo',          'complete' : 'customlist,vc#cmpt#Repos'},
                \     {'name' : 'VCDiff',                 'complete' : 'customlist,vc#cmpt#Diff'},
                \     {'name' : 'VCFetch',                'complete' : 'customlist,vc#cmpt#Fetch'},
                \     {'name' : 'VCIncoming',             'complete' : 'customlist,vc#cmpt#Incoming'},
                \     {'name' : 'VCInfo',                 'complete' : 'customlist,vc#cmpt#Info'},
                \     {'name' : 'VCLog',                  'complete' : 'customlist,vc#cmpt#Log'},
                \     {'name' : 'VCMove',                 'complete' : 'customlist,vc#cmpt#Move'},
                \     {'name' : 'VCOutgoing',             'complete' : 'customlist,vc#cmpt#Outgoing'},
                \     {'name' : 'VCPull',                 'complete' : 'customlist,vc#cmpt#Pull'},
                \     {'name' : 'VCPush',                 'complete' : 'customlist,vc#cmpt#Push'},
                \     {'name' : 'VCRevert',               'complete' : 'customlist,vc#cmpt#Revert'},
                \     {'name' : 'VCStatus',               'complete' : 'customlist,vc#cmpt#Status'},
                \ ],
                \ }
    let g:vc_allow_leader_mappings = 0

    nnoremap <silent> <Leader>ga :<C-U>VCAdd<CR>
    nnoremap <silent> <Leader>gb :<C-U>VCBlame<CR>
    nnoremap <silent> <Leader>gc :<C-U>VCCommit<CR>
    nnoremap <silent> <Leader>gd :<C-U>VCDiff<CR>
    nnoremap <silent> <Leader>gD :<C-U>VCDiff!<CR>
    nnoremap <silent> <Leader>gh :<C-U>VCLog<CR>
    nnoremap <silent> <Leader>gi :<C-U>VCInfo<CR>
    nnoremap <silent> <Leader>gn :<C-U>VCBlame<CR>
    nnoremap <silent> <Leader>gp :<C-U>VCDiff PREV<CR>
    nnoremap <silent> <Leader>gr :<C-U>VCRevert<CR>
    nnoremap <silent> <Leader>gs :<C-U>ProjectRootExe VCStatus<CR>
    nnoremap <silent> <Leader>gsp :<C-U>ProjectRootExe VCStatus<CR>
    nnoremap <silent> <Leader>gsb :<C-U>VCStatus .<CR>
    nnoremap <silent> <Leader>gsq :<C-U>VCStatus -qu<CR>
    nnoremap <silent> <Leader>gsu :<C-U>VCStatus -u<CR>
    " }}}
    " " vcscommand.vim: SVN前端。\cv进行diff，\cn查看每行是谁改的，\cl查看修订历史，\cG关闭VCS窗口回到源文件 {{{
    " NeoBundleLazy 'vcscommand.vim', {
    "             \ 'on_map' : [
    "             \     '<Plug>VCS',
    "             \ ],
    "             \ 'on_cmd' : ['VCSAdd', 'VCSAnnotate', 'VCSBlame', 'VCSCommit', 'VCSDelete', 'VCSDiff', 'VCSGotoOriginal', 'VCSInfo', 'VCSLock', 'VCSLog', 'VCSRemove', 'VCSRevert', 'VCSReview', 'VCSStatus', 'VCSUnlock', 'VCSUpdate', 'VCSVimDiff', 'VCSCommandDisableBufferSetup', 'VCSCommandEnableBufferSetup', 'VCSReload'],
    "             \ }
    " let g:VCSCommandDisableMappings = 1
    "
    " nnoremap <silent> <Leader>ga :<C-U>VCSAdd<CR>
    " nnoremap <silent> <Leader>gb :<C-U>VCSAnnotate! -g<CR>
    " nnoremap <silent> <Leader>gc :<C-U>VCSCommit<CR>
    " nnoremap <silent> <Leader>gD :<C-U>VCSDelete<CR>
    " nnoremap <silent> <Leader>gd :<C-U>VCSVimDiff<CR>
    " nnoremap <silent> <Leader>gG :<C-U>VCSGotoOriginal!<CR>
    " nnoremap <silent> <Leader>gg :<C-U>VCSGotoOriginal<CR>
    " nnoremap <silent> <Leader>gh :<C-U>VCSLog<CR>
    " nnoremap <silent> <Leader>gi :<C-U>VCSInfo<CR>
    " nnoremap <silent> <Leader>gL :<C-U>VCSLock<CR>
    " nnoremap <silent> <Leader>gn :<C-U>let tmp_lnum=line('.')<CR>:VCSAnnotate -g<CR>:keepjumps execute <C-R>=tmp_lnum<CR><CR>:unlet tmp_lnum<CR>
    " nnoremap <silent> <Leader>gp :<C-U>VCSVimDiff PREV<CR>
    " nnoremap <silent> <Leader>gq :<C-U>VCSRevert<CR>
    " nnoremap <silent> <Leader>gr :<C-U>VCSReview<CR>
    " nnoremap <silent> <Leader>gs :<C-U>VCSStatus<CR>
    " nnoremap <silent> <Leader>gU :<C-U>VCSUnlock<CR>
    " nnoremap <silent> <Leader>gu :<C-U>VCSUpdate<CR>
    " " }}}
    " " vim-fugitive: GIT前端 {{{
    " NeoBundleLazy 'tpope/vim-fugitive'
    " if executable('git')
    "     call neobundle#config('vim-fugitive', {
    "             \ 'lazy' : 0,
    "             \ })
    " endif
    " " }}}
endif
" }}}

if s:is_plugin_group_enabled('development.cpp') "{{{
    " clang_complete: 使用clang编译器进行上下文补全 {{{
    NeoBundleLazy 'Rip-Rip/clang_complete'
    if (g:dotvim_settings.cpp_complete_method == 'clang_complete'
                \ && !(g:dotvim_settings.libclang_path == "" && !executable('clang')))
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

        if neobundle#tap('clang_complete')
            call neobundle#config({
                        \ 'on_ft' : ['c', 'cpp'],
                        \ })

            function! neobundle#hooks.on_source(bundle)
                " 使用NeoComplete触发补全
                let g:clang_complete_auto = 0
                let g:clang_auto_select = 0
                let g:clang_complete_copen = 0  " open quickfix window on error.
                let g:clang_hl_errors = 1       " highlight the warnings and errors the same way clang
                "let g:clang_jumpto_declaration_key = '<C-]>'
                "let g:clang_jumpto_back_key = '<C-T>'
                let g:clang_default_keymappings = 0
                let g:clang_user_options = '-std=c++11 -stdlib=libc++'
                let g:clang_complete_macros = 1

                if g:dotvim_settings.libclang_path != ""
                    let g:clang_use_library = 1
                    let g:clang_library_path = g:dotvim_settings.libclang_path
                endif
            endfunction

            call neobundle#untap()
        endif
    endif
    " }}}
    " vim-clang: 使用clang编译器进行上下文补全 {{{
    NeoBundleLazy 'justmao945/vim-clang'
    if g:dotvim_settings.cpp_complete_method == 'vim-clang' && executable('clang')
        if neobundle#tap('vim-clang')
            call neobundle#config({
                        \ 'on_ft' : ['c', 'cpp'],
                        \ })

            function! neobundle#hooks.on_source(bundle)
                " 使用NeoComplete触发补全
                let g:clang_auto = 0
                " default 'longest' can not work with neocomplete
                let g:clang_c_completeopt = 'menuone,preview'
                let g:clang_cpp_completeopt = 'menuone,preview'

                " disable diagnostics
                let g:clang_diagsopt = ''

                if !exists('g:clang_cpp_options')
                    let g:clang_cpp_options = ''
                endif
                let g:clang_cpp_options .= ' -std=c++11 -stdlib=libc++'

                if g:dotvim_settings.clang_include_path != ""
                    let g:clang_cpp_options .= " -I " . g:dotvim_settings.clang_include_path
                endif
            endfunction

            call neobundle#untap()
        endif
    endif
    " }}}
    " vim-marching: 使用clang进行补全 {{{
    NeoBundleLazy 'osyo-manga/vim-marching', {
                    \ 'depends' : ['osyo-manga/vim-reunions', ],
                    \ }
    if g:dotvim_settings.cpp_complete_method =~ 'marching.*'
                \ && !(g:dotvim_settings.libclang_path == "" && !executable('clang'))
        if g:dotvim_settings.cpp_complete_method == 'marching' " 自动选择方式
            if g:dotvim_settings.libclang_path != ""
                let g:dotvim_settings.cpp_complete_method = 'marching.snowdrop'
            else
                let g:dotvim_settings.cpp_complete_method = 'marching.async'
            endif
        endif

        if neobundle#tap('vim-marching')
            call neobundle#config({
                        \ 'on_ft' : ['c', 'cpp'],
                        \ 'on_cmd' : [
                        \     'MarchingBufferClearCache', 'MarchingDebugLog'],
                        \ 'on_map' : [['i', '<Plug>(marching_']],
                        \ })

            let g:marching_enable_neocomplete = 1
            let g:marching_clang_command_option = ' -std=c++11 -stdlib=libc++'

            " 选择一个backend
            if g:dotvim_settings.cpp_complete_method == 'marching.snowdrop'
                " 使用vim-snowdrop
                function! neobundle#hooks.on_post_source(bundle)
                    NeoBundleSource "vim-snowdrop"
                endfunction
                let g:marching_backend = 'snowdrop'             " 通过vim-snowdrop调用libclang
            elseif g:dotvim_settings.cpp_complete_method == 'marching.async'
                let g:marching_backend = 'clang_command'        " 异步
            else
                let g:marching_backend = 'sync_clang_command'   " 同步
            endif

            " call extend(s:neocompl_force_omni_patterns, {
            "             \ 'marching#complete' : '\%(\.\|->\|::\)\h\w*'})

            call neobundle#untap()
        endif
    endif
    " }}}
    " vim-snowdrop: libclang的python封装 {{{
    NeoBundleLazy 'osyo-manga/vim-snowdrop'
    if g:dotvim_settings.libclang_path != ""
        if neobundle#tap('vim-snowdrop')
            call neobundle#config({
                        \ 'on_cmd' : [
                        \     'SnowdropVerify', 'SnowdropEchoClangVersion',
                        \     'SnowdropLogs', 'SnowdropClearLogs',
                        \     'SnowdropEchoIncludes', 'SnowdropErrorCheck',
                        \     'SnowdropGotoDefinition', 'SnowdropEchoTypeof',
                        \     'SnowdropEchoResultTypeof', 'SnowdropFixit',
                        \ ],
                        \ 'on_source': ['unite.vim'],
                        \ })

            function! neobundle#hooks.on_source(bundle)
                let g:snowdrop#libclang_directory = fnamemodify(g:dotvim_settings.libclang_path, ':p:h')
                let g:snowdrop#libclang_file      = fnamemodify(g:dotvim_settings.libclang_path, ':p:t')

                " Enable code completion in neocomplete.vim.
                let g:neocomplete#sources#snowdrop#enable = 1

                let g:snowdrop#command_options = {
                            \ "cpp" : "-std=c++1y",
                            \ }

                " Not skip
                let g:neocomplete#skip_auto_completion_time = ""
            endfunction

            call neobundle#untap()
        endif
    endif
    " }}}
    " vim-clang-format: 使用clang编译器进行上下文补全 {{{
    NeoBundleLazy 'rhysd/vim-clang-format', {
                    \ 'depends' : 'kana/vim-operator-user',
                    \ }
    if executable('clang-format')
        call neobundle#config('vim-clang-format', {
                    \ 'on_cmd' : ['ClangFormat'],
                    \ 'on_map' : ['<Plug>(operator-clang-format'],
                    \ })

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
        autocmd vimrc FileType c,cpp,objc nnoremap <silent><buffer><Leader>j= :<C-U>ClangFormat<CR>
        autocmd vimrc FileType c,cpp,objc vnoremap <silent><buffer><Leader>j= :ClangFormat<CR>
        " if you install vim-operator-user
        autocmd vimrc FileType c,cpp,objc map <silent><buffer><LocalLeader>x <Plug>(operator-clang-format)
    endif
    " }}}
    " wandbox-vim: 在http://melpon.org/wandbox/上运行当前缓冲区的C++代码 {{{
    NeoBundleLazy 'rhysd/wandbox-vim', {
                \ 'on_cmd' : [
                \    {'name' : 'Wandbox',      'complete' : 'customlist,wandbox#complete_command'},
                \    {'name' : 'WandboxAsync', 'complete' : 'customlist,wandbox#complete_command'},
                \    {'name' : 'WandboxSync',  'complete' : 'customlist,wandbox#complete_command'},
                \    'WandboxAbortAsyncWorks',
                \    'WandboxOpenBrowser',
                \    'WandboxOptionList',
                \    'WandboxOptionListAsync',
                \ ],
                \ 'function_prefix' : 'wandbox',
                \ }
    let g:wandbox#echo_command = 'echomsg'
    noremap <silent> [make]w :<C-U>Wandbox<CR>

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
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('development.arduino') "{{{
    " arduvim: 提供了更多的Arduino关键字，并且可以根据需要生成自己的库的关键字 {{{
    NeoBundleLazy 'z3t0/arduvim', {
                \ 'on_ft' : ['arduino'],
                \ }
    " }}}
    " vim-compiler-arduino: 利用Arduino IDE的命令行作为Arduino的compiler {{{
    NeoBundle 'thawk/vim-compiler-arduino'
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('development.python') "{{{
    " jedi-vim: 强大的Python补全、pydoc查询工具。 \g：跳到变量赋值点或函数定义；\d：函数定义；K：查询文档；\r：改名；\n：列出对使用一个名称的所有位置 {{{
    NeoBundleLazy 'davidhalter/jedi-vim', {
                \ 'on_ft' : ['python', 'python3'],
                \ }
    if neobundle#tap('jedi-vim')
        let g:jedi#popup_select_first = 0   " 不要自动选择第一个候选项
        let g:jedi#show_call_signatures = 2 " 在cmdline显示函数签名
        let g:jedi#popup_on_dot = 1

        let g:jedi#goto_command = "<Leader>s]"
        let g:jedi#goto_assignments_command = "<Leader>sD"
        let g:jedi#completions_command = ""
        let g:jedi#usages_command = "<Leader>sR"
        let g:jedi#rename_command = "<Leader>rr"
        let g:jedi#documentation_command = "K"

        call neobundle#untap()
    endif
    " }}}

    NeoBundleLazy 'hynek/vim-python-pep8-indent', {
                \ 'on_ft' : ['python', 'python3'],
                \ }

    " SimpylFold: python语法折叠 {{{
    NeoBundleLazy 'tmhedberg/SimpylFold', {
                \ 'on_ft' : ['python', 'python3'],
                \ }
    if neobundle#tap('SimpylFold')
        let g:SimpylFold_docstring_preview = 1

        call neobundle#untap()
    endif
    " }}}

    " vim-behave: 对behave测试框架的支持 {{{
    NeoBundleLazy 'rooprob/vim-behave', {
                \ 'on_ft' : ['behave'],
                \ 'on_path' : ['.*\.feature', '.*\.story'],
                \ 'on_cmd' : ['Behave', 'BehaveJump'],
                \ }
    " }}}

endif
" }}}

if s:is_plugin_group_enabled('development.haskell') "{{{
    " neco-ghc: 结合neocomplete补全haskell {{{
    NeoBundleLazy 'eagletmt/neco-ghc'
    if executable('ghc-mod')
        call neobundle#config('neco-ghc', {
                    \ 'on_ft' : ['haskell'],
                    \ 'on_cmd'  : ['NecoGhcDiagnostics'],
                    \ })

        let g:necoghc_enable_detailed_browse = 0
        let g:necoghc_debug = 0
    endif
    " }}}
    " haskell-vim: Haskell的语法高亮和缩进 {{{
    NeoBundleLazy 'neovimhaskell/haskell-vim', {
                \ 'on_ft' : ['haskell', 'cabal'],
                \ }

    if neobundle#tap('haskell-vim')
        " 控制部分功能的启用与否
        " let g:haskell_enable_quantification = 1   " enable highlighting of forall
        " let g:haskell_enable_recursivedo = 1      " enable highlighting of mdo and rec
        " let g:haskell_enable_arrowsyntax = 1      " enable highlighting of proc
        " let g:haskell_enable_pattern_synonyms = 1 " enable highlighting of pattern
        " let g:haskell_enable_typeroles = 1        " enable highlighting of type roles
        " let g:haskell_enable_static_pointers = 1  " enable highlighting of static

        " 控制haskell缩进
        " let g:haskell_indent_if = 3
        " let g:haskell_indent_case = 2
        " let g:haskell_indent_let = 4
        " let g:haskell_indent_where = 6
        " let g:haskell_indent_do = 3
        " let g:haskell_indent_in = 1

        " 控制cabal缩进
        " let g:cabal_indent_section = 2

        call neobundle#untap()
    endif
    " }}}
    " ref-hoogle: 让vim-ref插件支持hoogle {{{
    NeoBundleLazy 'ujihisa/ref-hoogle'
    if !neobundle#tap('vim-ref') && executable('hoogle')
        call neobundle#config('ref-hoogle', {
                    \ 'on_ft' : ['haskell'],
                    \ })

        call neobundle#untap()
    endif
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('development.csharp') "{{{
    " vim-csharp: C#文件的支持 {{{
    NeoBundleLazy 'OrangeT/vim-csharp', {
                \ 'on_ft' : ['csharp'],
                \ }
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('development.viml') "{{{ VimL，Vim的编程语言
    " vim-scriptease: 辅助编写vim脚本的工具 {{{
    NeoBundleLazy 'tpope/vim-scriptease', {
                \ 'on_ft' : ['vim'],
                \ 'on_map' : ['<Plug>Scriptease'],
                \ 'on_cmd' : [
                \     { 'name' : 'PP', 'complete' : 'expression' },
                \     { 'name' : 'PPmsg', 'complete' : 'expression' },
                \     { 'name' : 'Verbose', 'complete' : 'command' },
                \     { 'name' : 'Time', 'complete' : 'command' },
                \     'Console ', 'Disarm', 'Messages', 'Runtime', 'Scriptnames',
                \     'Ve', 'Vedit', 'Vopen', 'Vpedit', 'Vread', 'Vsplit', 'Vtabedit', 'Vvsplit',
                \ ],
                \ }
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('development.web') "{{{ 前端开发
    " Emmet.vim: 快速编写XML文件。如 div>p#foo$*3>a 再按 <C-Y>, {{{
    NeoBundleLazy 'mattn/emmet-vim', {
                \ 'on_ft' : ['xml','html','css','sass','scss','less'],
                \ 'on_map' : ['<Plug>(Emmet'],
                \ 'on_cmd' : ['EmmetInstall'],
                \ }
    " }}}
    " xml.vim: 辅助编写XML文件 {{{
    NeoBundleLazy 'othree/xml.vim', {
                \ 'on_ft' : ['xml'],
                \ }
    " }}}
    " vim-json: 对JSON文件提供语法高亮 {{{
    NeoBundleLazy 'elzr/vim-json', {
                \ 'on_ft' : ['json'],
                \ 'on_path' : ['.*\.jsonp\?'],
                \ }
    " }}}
    " vim-jinja: jinja2语法支持 {{{
    NeoBundleLazy 'lepture/vim-jinja', {
                \ 'on_path': '\.\(htm\|html\|jinja2\|j2\|jinja\)$',
                \ }
    " }}}
    " vim-bundle-mako: python的mako模板支持 {{{
    NeoBundleLazy 'sophacles/vim-bundle-mako', {
                \ 'on_ft' : ['mako'],
                \ 'on_path' : ['.*\.mako'],
                \ }
    " }}}
    " javascript-libraries-syntax.vim: Javascript语法高亮 {{{
    NeoBundleLazy 'othree/javascript-libraries-syntax.vim', {
                \ 'on_ft' : ['javascript', 'js'],
                \ }
    " let g:used_javascript_libs = 'jquery,angularjs,react,flux'
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('development.shell') "{{{
    " Conque-GDB: 在vim中进行gdb调试 {{{
    NeoBundleLazy 'Conque-GDB'
    if executable("gdb") && has('python')
        call neobundle#config('Conque-GDB', {
                    \ 'on_cmd' : [
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
                    \ })
        " ,dr - run
        " ,dc - continue
        " ,dn - next
        " ,ds - step
        " ,dp - print 光标下的标识符
        " ,db - toggle breakpoint
        " ,df - finish
        " ,dt - backtrace
        let g:ConqueGdb_Leader = ',d'
    endif
    " }}}
    " vimshell: Shell，:VimShell {{{
    NeoBundleLazy 'Shougo/vimshell', {
                \ 'on_cmd' : [
                \    { 'name' : 'VimShell', 'complete' : 'customlist,vimshell#complete'},
                \    { 'name' : 'VimShellCreate', 'complete' : 'customlist,vimshell#complete'},
                \    { 'name' : 'VimShellPop', 'complete' : 'customlist,vimshell#complete'},
                \    { 'name' : 'VimShellTab', 'complete' : 'customlist,vimshell#complete'},
                \    { 'name' : 'VimShellCurrentDir', 'complete' : 'customlist,vimshell#complete'},
                \    { 'name' : 'VimShellBufferDir', 'complete' : 'customlist,vimshell#complete'},
                \    { 'name' : 'VimShellExecute', 'complete' : 'customlist,vimshell#helpers#vimshell_execute_complete'},
                \    { 'name' : 'VimShellInteractive', 'complete' : 'customlist,vimshell#helpers#vimshell_execute_complete'},
                \    'VimShellSendString', 'VimShellSendBuffer', 'VimShellClose',
                \ ],
                \ 'on_map' : ['<Plug>(vimshell_'],
                \ 'on_source': ['unite.vim'],
                \ }
    if neobundle#tap('vimshell')
        let g:vimshell_data_directory=s:get_cache_dir('vimshell')

        " 下面的键如果slimux/vim-tbone启用则会被这两个插件覆盖，因此vimshell
        " 应在那两个插件前

        " 以项目目录打开vimshell窗口
        map <silent> <Leader>p' :<C-U>ProjectRootExe VimShellPop<CR>
        " 以当前目录打开vimshell窗口
        map <silent> <Leader>j' :<C-U>VimShellPop<CR>
        " 以当前缓冲区目录打开vimshell窗口
        map <silent> <Leader>f' :<C-U>BufferDirExe VimShellPop<CR>

        " 关闭最近一个vimshell窗口
        map <silent> <Leader>msq :<C-U>VimShellClose<CR>

        " 执行当前行
        map <silent> <Leader>msl :<C-U>VimShellSendString<CR>
        map <silent> <Leader>msr :<C-U>VimShellSendString<CR>
        " 执行所选内容
        vmap <silent> <Leader>msr :'<,'>VimShellSendString<CR>
        vmap <silent> <Leader>msr :'<,'>VimShellSendString<CR>

        " 提示执行命令
        map <silent> <Leader>msn :<C-U>VimShellSendString<SPACE>

        call neobundle#untap()
    endif
    " }}}
    " slimux: 配合tmux的REPL工具，可以把缓冲区中的内容拷贝到tmux指定pane下运行。\rs发送当前行或选区，\rp提示输入命令，\ra重复上一命令，\rk重复上个key序列 {{{
    NeoBundleLazy 'epeli/slimux'
    if executable("tmux")
        call neobundle#config('slimux', {
                    \ 'on_cmd' : [
                    \     'SlimuxREPLSendLine', 'SlimuxREPLSendSelection', 'SlimuxREPLSendLine', 'SlimuxREPLSendBuffer', 'SlimuxREPLConfigure',
                    \     'SlimuxShellRun', 'SlimuxShellPrompt', 'SlimuxShellLast', 'SlimuxShellConfigure',
                    \     'SlimuxSendKeysPrompt', 'SlimuxSendKeysLast', 'SlimuxSendKeysConfigure' ],
                    \ 'on_func': ['SlimuxConfigureCode', 'SlimuxSendCode', 'SlimuxSendCommand', 'SlimuxSendKeys',],
                    \ })

        " 执行当前行
        map <silent> <Leader>msl :<C-U>SlimuxREPLSendLine<CR>
        map <silent> <Leader>msr :<C-U>SlimuxREPLSendLine<CR>
        " 执行所选内容
        vmap <silent> <Leader>msr :SlimuxREPLSendSelection<CR>
        vmap <silent> <Leader>msr :SlimuxREPLSendSelection<CR>

        " 提示执行命令
        map <silent> <Leader>msn :<C-U>SlimuxShellPrompt<CR>
        " 执行上一条命令
        map <silent> <Leader>mse :<C-U>SlimuxShellLast<CR>
    endif
    " }}}
    " vim-tbone: 可以操作tmux缓冲区，执行tmux命令 {{{
    NeoBundleLazy 'tpope/vim-tbone'
    if executable("tmux")
        call neobundle#config('vim-tbone', {
                    \ 'on_cmd' : [
                    \   { 'name' : 'Tattach', 'complete' : 'custom,tbone#complete_sessions' },
                    \   { 'name' : 'Tmux', 'complete' : 'custom,tbone#complete_command' },
                    \   { 'name' : 'Tput', 'complete' : 'custom,tbone#complete_buffers' },
                    \   { 'name' : 'Tyank', 'complete' : 'custom,tbone#complete_buffers' },
                    \   { 'name' : 'Twrite', 'complete' : 'custom,tbone#complete_panes' },
                    \ ],
                    \ })

        " 以项目目录打开tmux窗口
        map <silent> <Leader>p' :<C-U>silent ProjectRootExe !tmux split-window -p 30 -d<CR>
        " 以当前目录打开tmux窗口
        map <silent> <Leader>j' :<C-U>silent !tmux split-window -p 30 -d<CR>
        " 以当前缓冲区目录打开tmux窗口
        map <silent> <Leader>f' :<C-U>silent BufferDirExe !tmux split-window -p 30 -d<CR>
    endif
    " }}}
    " vim-dispatch: 可以用:Make、:Dispatch等，通过tmux窗口、后台窗口等手段异步执行命令 {{{
    NeoBundleLazy 'tpope/vim-dispatch', {
                \ 'on_cmd' : [
                \     { 'name' : 'Dispatch', 'complete' : 'customlist,dispatch#command_complete' },
                \     { 'name' : 'FocusDispatch', 'complete' : 'customlist,dispatch#command_complete' },
                \     { 'name' : 'Make', 'complete' : 'customlist,dispatch#make_complete' },
                \     { 'name' : 'Spawn', 'complete' : 'customlist,dispatch#command_complete' },
                \     { 'name' : 'Start', 'complete' : 'customlist,dispatch#command_complete' },
                \     'Copen',
                \ ],
                \ }
    " }}}
    " neossh.vim: 支持ssh://协议 {{{
    NeoBundleLazy 'Shougo/neossh.vim', {
                \ 'on_ft' : ['vimfiler', 'vimshell'],
                \ 'on_source': ['unite.vim'],
                \ }
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('doc') "{{{ 文档编写，如OrgMode、AsciiDoc等
    " context_filetype.vim: 在文件中根据上下文确定当前的filetype，如识别出html中内嵌js、css {{{
    NeoBundleLazy 'Shougo/context_filetype.vim', {
                \ }
    " }}}
    " SyntaxRange: 在一段文字中使用特别的语法高亮 {{{
    NeoBundleLazy 'SyntaxRange', {
                \ 'depends': ['ingo-library'],
                \ 'on_ft': ['asciidoc', 'markdown', 'mkdc'],
                \ 'on_cmd': [
                \     'SyntaxIgnore',
                \     {'name': 'SyntaxInclude', 'complete': 'syntax'},
                \ ]}
    let g:my_sub_syntaxes = []
    for lang in ['bat', 'c', 'cpp', 'cucumber', 'java', 'javascript', 'json', 'python', 'ruby', 'sh', 'typescript', 'vim', 'xml', 'yaml']
        if !empty(findfile("syntax/" . lang . ".vim", &runtimepath))
            call add(g:my_sub_syntaxes, lang)
        endif
    endfor
    " }}}
    " " vim-orgmode: 对emacs的org文件的支持 {{{
    " NeoBundleLazy 'jceb/vim-orgmode', {
    "             \ 'depends' : [
    "             \   'NrrwRgn',
    "             \   'speeddating.vim',
    "             \ ],
    "             \ 'on_ft' : ['org'],
    "             \ }
    " autocmd vimrc BufRead,BufNewFile *.org setf org
    " " }}}
    " vim-asciidoc: AsciiDoc的语法高亮 {{{
    NeoBundleLazy 'asciidoc/vim-asciidoc', {
                \ 'on_ft' : ['asciidoc'],
                \ }
    " }}}
    " " vim-markdown-concealed: markdown支持，并且利用conceal功能隐藏不需要的字符 {{{
    " NeoBundleLazy 'prurigro/vim-markdown-concealed', {
    "             \ 'on_ft' : ['markdown'],
    "             \ }
    " " }}}
    " vim-markdown: 正确支持markdown文件 {{{
    NeoBundleLazy 'plasticboy/vim-markdown', {
                \ 'on_ft' : ['markdown'],
                \ }
    " }}}
    " wmgraphviz.vim: 提供对Graphviz dot的支持，包括编译、snippet等 {{{
    NeoBundleLazy 'wannesm/wmgraphviz.vim', {
                \ 'on_ft' : 'dot',
                \ 'on_path' : '.*\.\(gv\|dot\)$',
                \ 'on_cmd' : [
                \     'GraphvizCompile', 'GraphvizCompilePS', 'GraphvizCompilePDF',
                \     'GraphvizCompileDot', 'GraphvizCompileNeato', 'GraphvizCompileCirco',
                \     'GraphvizCompileFdp', 'GraphvizCompileSfdp', 'GraphvizCompileTwopi',
                \     'GraphvizCompileToLaTeX',
                \     'GraphvizShow', 'GraphvizInteractive'
                \ ]}
    let g:WMGraphviz_output = 'png'

    autocmd vimrc FileType dot
                \   nnoremap <silent><buffer> <Leader>cc :<C-U>GraphvizCompile<CR>
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('syntax') "{{{ 为一些文件提供语法高亮
    " csv.vim: 增加对CSV文件（逗号分隔文件）的支持 {{{
    NeoBundleLazy 'chrisbra/csv.vim', {
                \ 'on_ft' : ['csv'],
                \ 'on_path' : '.*\.csv$',
                \ }
    " }}}
    " wps.vim: syntax highlight for RockBox wps file {{{
    NeoBundleLazy 'wps.vim', {
                \ 'on_ft' : ['wps'],
                \ }
    autocmd vimrc BufRead,BufNewFile *.wps,*.sbs,*.fms setf wps
    " }}}
    " po.vim: 用于编辑PO语言包文件。 {{{
    NeoBundleLazy 'po.vim', {
                \ 'on_ft' : ['po'],
                \ 'on_path' : ['.*\.pot\?'],
                \ }
    " }}}
    " vim-drake-syntax: Drake的语法高亮（命令行workflow工具） {{{
    NeoBundleLazy 'bitbucket:larsyencken/vim-drake-syntax.git', {
                \ 'on_ft' : ['po'],
                \ }
    " }}}
    " vim-diff-fold: 折叠diff/patch文件 {{{
    NeoBundleLazy 'sgeb/vim-diff-fold', {
                \ 'on_ft' : ['diff', 'patch'],
                \ }
    " }}}
    " pcet: 转换引擎pcet_*.xml的语法高亮和unite-outline支持 {{{
    NeoBundleLazy 'thawk/vim-pcet', {
                \ 'on_source': ['unite-outline'],
                \ }
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('visual') "{{{ 界面增强
    " vim-airline: 增强的statusline {{{
    NeoBundle 'vim-airline/vim-airline', {
                \ 'depends': ['vim-airline/vim-airline-themes', 'unicode.vim'],
                \ }
    nmap <Leader>tw :AirlineToggleWhitespace<CR>

    let bundle = neobundle#get('vim-airline')
    function! bundle.hooks.on_post_source(bundle)
        " 把section a的第1个part从mode改为bufnr() + mode
        if executable("svn")
            call airline#parts#define_function('mybranch', 'AirLineMyBranch')
            let g:airline_section_b = airline#section#create(['hunks', 'mybranch'])
        endif

        let g:airline_section_a = '%{bufnr("%")} ' . g:airline_section_a
        " let g:airline_section_y = g:airline_section_y . '%{&bomb ? "[BOM]" : ""}'
    endfunction

    " if neobundle#is_installed("vcscommand.vim")
    "     let g:airline#extensions#branch#use_vcscommand = 1
    " endif

    " let g:airline_left_sep = '\u25ba'
    " let g:airline_right_sep = '\u25c4'

    if !exists('g:airline_symbols')
        let g:airline_symbols = {}
    endif

    if g:dotvim_settings.airline_mode == 'powerline'
        " 使用powerline字符
        " https://github.com/abertsch/Menlo-for-Powerline 比较合适
        " https://github.com/Lokaltog/powerline-fonts 有更多免费的字体
        if &encoding ==? "utf-8"
            " encoding是utf-8时，直接使用airline内置的字符即可，不需要特殊处理
            let g:airline_powerline_fonts=1
        else
            " encoding不是utf-8，目前vim-airline中的设置方式有问题，因此自行设置
            " 这里没有设置的字符，采用比较安全的ascii
            let g:airline_symbols_ascii=1

            let g:airline_left_sep = ""
            let g:airline_left_alt_sep = ""
            " 由于在非utf-8时，这些特殊字符都只占半个字符宽度，右半是空白，因此右
            " 边的分隔符变成三角加空白，得不到想要的效果。所以只保留左边的
            let g:airline_right_sep = ""
            let g:airline_right_alt_sep = "|"
            " let g:airline_right_sep = ""
            " let g:airline_right_alt_sep = ""

            let g:airline_symbols.branch = ""
            let g:airline_symbols.readonly = ""
            let g:airline_symbols.linenr = "Ξ"
            let g:airline_symbols.maxlinenr = ""
            " let g:airline_symbols.paste = "∥"
            let g:airline_symbols.paste = "PASTE"
            " let g:airline_symbols.paste = 'ρ'
            " let g:airline_symbols.whitespace = " "
            let g:airline_symbols.spell = 'SPELL'
            let g:airline_symbols.modified = '+'
            let g:airline_symbols.space = ' '
        endif
    elseif g:dotvim_settings.airline_mode == 'unicode'
        " 这里没有设置的字符，采用比较安全的ascii
        let g:airline_symbols_ascii=1

        let g:airline_left_sep = ""
        let g:airline_left_alt_sep = ""
        let g:airline_right_sep = ""
        let g:airline_right_alt_sep = ""

        let g:airline_symbols.readonly = ""
        let g:airline_symbols.linenr = "Ξ"
        let g:airline_symbols.maxlinenr = "㏑"
        " let g:airline_symbols.paste = "∥"
        let g:airline_symbols.paste = "PASTE"
        " let g:airline_symbols.paste = 'ρ'
        " let g:airline_symbols.whitespace = " "
        let g:airline_symbols.spell = 'SPELL'
        let g:airline_symbols.modified = '+'
        let g:airline_symbols.space = ' '
    else
        " 直接使用vim-airline内置的ascii即可
        let g:airline_symbols_ascii=1
    endif

    set noshowmode

    let g:airline_solarized_normal_green = 0

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

    let g:airline#extensions#tabline#formatter = 'default'
    let g:airline#extensions#tabline#buffer_nr_show = 0
    let g:airline#extensions#tabline#buffer_nr_format = '%s: '
    let g:airline#extensions#tabline#fnamemod = ':p:t'

    let g:airline#extensions#taboo#enabled = 1
    " show tab number instead of number of splits
    let g:airline#extensions#tabline#tab_nr_type = 1

    let g:airline#extensions#csv#column_display = 'Name'

    let s:path_branch = {}

    function! UrlDecode(str)
        let str = substitute(substitute(substitute(a:str,'%0[Aa]\n$','%0A',''),'%0[Aa]','\n','g'),'+',' ','g')
        return substitute(str,'%\(\x\x\)','\=nr2char("0x".submatch(1))','g')
    endfunction

    function! AirLineMyBranch()
        if !exists('*airline#extensions#branch#get_head')
            return ''
        endif

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
    " }}}
    " taboo.vim: 为TAB起名 {{{
    NeoBundle 'gcmt/taboo.vim', {
                \ 'on_cmd': [
                \     'TabooRename', 'TabooOpen', 'TabooReset',
                \ ]}
    if neobundle#tap('vim-airline')
        let g:taboo_tabline = 0 " 使用vim-airline进行显示
        call neobundle#untap()
    endif
    " }}}
    " GoldenView.Vim: <F8>/<S-F8>当前窗口与主窗口交换 {{{
    NeoBundle 'zhaocai/GoldenView.Vim'

    if neobundle#tap('GoldenView.Vim')
        function! neobundle#hooks.on_post_source(bundle)
            " 忽略CodeReviewer窗口
            call add(g:goldenview__ignore_urule['filetype'], 'rev')
        endfunction

        let g:goldenview__enable_default_mapping = 0
        " nmap <silent> <C-N>  <Plug>GoldenViewNext
        " nmap <silent> <C-P>  <Plug>GoldenViewPrevious

        nmap <silent> <F8>   <Plug>GoldenViewSwitchMain
        nmap <silent> <S-F8> <Plug>GoldenViewSwitchToggle

        " nmap <silent> <C-L>  <Plug>GoldenViewSplit

        call neobundle#untap()
    endif
    " }}}
    " indentLine: 以竖线标记各缩进块 {{{
    NeoBundleLazy 'Yggdroot/indentLine'

    " gvim下经常出现一个空格占两个字符的宽度
    if !s:is_gui
        call neobundle#config('indentLine', {
                    \ 'on_cmd': [
                    \   'IndentLinesReset',   'IndentLinesToggle',   'IndentLinesEnable', 'IndentLinesDisable',
                    \   'LeadingSpaceEnable', 'LeadingSpaceDisable', 'LeadingSpaceToggle',
                    \ ],
                    \ 'on_path' : ['.*'],
                    \ })

        let g:indentLine_enabled = 1

        " " 打开特定文件类型时，自动启用本插件。空表示应用于所有文件类型
        " let g:indentLine_fileType = ['python']
        " " 打开某些文件类型时，自动禁用本插件。空表示不自动禁用
        " let g:indentLine_fileTypeExclude = []
        " " 对于特定名称的缓冲区自动禁用
        " let g:indentLine_bufNameExclude = []

        " let g:indentLine_color_term = 0
        " let g:indentLine_color_gui = '#03303c'
        " let g:indentLine_color_tty_light = 7
        " let g:indentLine_color_tty_dark = 0

        " let g:indentLine_faster = 1
        " let g:indentLine_showFirstIndentLevel = 1

        " let g:indentLine_char = '|'
        let g:indentLine_char = '┆'
        " let g:indentLine_char = '│'
        " 首个缩进使用的字符
        let g:indentLine_first_char = '┆'

        " 行首空格
        let g:indentLine_leadingSpaceEnabled = 0
        " let g:indentLine_leadingSpaceChar = '·'
        " let g:indentLine_leadingSpaceChar = iconv(nr2char(0x02F0，1), "utf-8", &encoding) " '?'

        nmap <silent> <Leader>ti :<C-U>IndentLinesToggle<CR>
    endif
    " }}}
endif
" }}}

if s:is_plugin_group_enabled('misc') "{{{
    " vim-hugefile: 打开大文件时，禁用一些功能，提供打开速度 {{{
    NeoBundle 'mhinz/vim-hugefile'
    " let g:hugefile_trigger_size = 2 " MiB
    " }}}
    " vimfiler: 文件管理器 {{{
    NeoBundleLazy 'Shougo/vimfiler', {
                \ 'depends' : 'Shougo/unite.vim',
                \ 'on_cmd' : [
                \               { 'name' : 'VimFiler',
                \                 'complete' : 'customlist,vimfiler#complete' },
                \               { 'name' : 'VimFilerTab',
                \                 'complete' : 'customlist,vimfiler#complete' },
                \               { 'name' : 'VimFilerExplorer',
                \                 'complete' : 'customlist,vimfiler#complete' },
                \               { 'name' : 'VimFilerEdit',
                \                 'complete' : 'customlist,vimfiler#complete' },
                \               { 'name' : 'VimFilerWrite',
                \                 'complete' : 'customlist,vimfiler#complete' },
                \               { 'name' : 'VimFilerRead',
                \                 'complete' : 'customlist,vimfiler#complete' },
                \               { 'name' : 'VimFilerSource',
                \                 'complete' : 'customlist,vimfiler#complete' },
                \              ],
                \ 'on_map' : ['<Plug>(vimfiler_'],
                \ 'explorer' : 1,
                \ 'on_source': ['unite.vim'],
                \ }
    " 文件管理器，通过 :VimFiler 启动。
    " c : copy, m : move, r : rename,
    let g:vimfiler_as_default_explorer = 1
    let g:vimfiler_define_wrapper_commands = 0
    let g:vimfiler_data_directory = s:get_cache_dir('vimfiler')

    " 切换侧边栏
    nnoremap <silent> <Leader>pD :<C-U>VimFiler -project<CR>
    nnoremap <silent> <Leader>pt :<C-U>VimFiler -project -explorer -parent -direction=rightbelow<CR>
    nnoremap <silent> <Leader>fd :<C-U>VimFilerBufferDir<CR>
    nnoremap <silent> <Leader>fD :<C-U>VimFilerBufferDir -split<CR>
    nnoremap <silent> <Leader>ft :<C-U>VimFilerBufferDir -explorer -parent -direction=rightbelow<CR>
    nnoremap <silent> <Leader>bt :<C-U>VimFilerCurrentDir -explorer -parent -direction=rightbelow<CR>
    nnoremap <silent> <Leader>jd :<C-U>VimFilerCurrentDir<CR>
    nnoremap <silent> <Leader>jD :<C-U>VimFilerCurrentDir -split<CR>
    " }}}
    " unicode.vim: ga会显示当前字符的更多信息，<C-X><C-G>/<C-X><C-Z>进行补全 {{{
    NeoBundleLazy 'chrisbra/unicode.vim', {
                \ 'on_map' : [
                \   ['nxo','<Plug>'],
                \   ['nx','<F4>'],
                \   ['i', '<C-X><C-G>', '<C-X><C-Z>'],
                \   ['n','<Leader>un'],
                \ ],
                \ 'on_cmd' : ['UnicodeName', 'Digraphs', 'SearchUnicode', 'UnicodeTable', 'DownloadUnicode'],
                \ 'on_func' : ['unicode#FindDigraphBy', 'unicode#FindUnicodeBy', 'unicode#Digraph', 'unicode#Download', 'unicode#UnicodeName'],
                \ }
    nmap <silent> <Leader>hdc <Plug>(UnicodeGA)
    " }}}
    " vim-eunuch: Remove/Unlink/Move/SudoEdit/SudoWrite等UNIX命令 {{{
    NeoBundleLazy 'tpope/vim-eunuch', {
                \ 'on_cmd' : [
                \   'Unlink', 'Remove', 'Rename', 'Chmod', 'SudoWrite', 'Wall', 'W',
                \   { 'name' : 'Move', 'complete' : 'file' },
                \   { 'name' : 'File', 'complete' : 'file' },
                \   { 'name' : 'Locate', 'complete' : 'file' },
                \   { 'name' : 'Mkdir', 'complete' : 'dir' },
                \   { 'name' : 'SudoEdit', 'complete' : 'file' },
                \ ],
                \ }
    " }}}
    " " quickrun.vim: 快速运行代码片段 {{{
    " NeoBundleLazy 'quickrun.vim', {
    "             \ 'on_map' : [['nxo', '<Plug>(quickrun)']],
    "             \ 'on_cmd' : ['QuickRun'],
    "             \ }
    " nmap <silent> ,r <Plug>(quickrun)
    " " }}}
    " scratch.vim: 打开一个临时窗口。gs/gS/:Scratch {{{
    NeoBundleLazy 'mtth/scratch.vim', {
                \ 'on_cmd' : ['Scratch','ScratchInsert','ScratchSelection'],
                \ 'on_map' : [['nx'], '<Plug>(scratch-'],
                \ }
    let g:scratch_no_mappings = 1
    nmap <leader>bs <Plug>(scratch-insert-reuse)
    nmap <leader>bS <Plug>(scratch-insert-clear)
    xmap <leader>bs <Plug>(scratch-selection-reuse)
    xmap <leader>bS <Plug>(scratch-selection-clear)
    " }}}
    " AutoFenc: 自动判别文件的编码 {{{
    NeoBundle 'AutoFenc'
    " }}}
    " vim-unimpaired: 增加]及[开头的一系列快捷键，方便进行tab等的切换 {{{
    NeoBundle'tpope/vim-unimpaired'
    " [a     :previous  ]a     :next   [A :first  ]A : last
    " [b     :bprevious ]b     :bnext  [B :bfirst ]B : blast
    " [l     :lprevious ]l     :lnext  [L :lfirst ]L : llast
    " [<C-L> :lpfile    ]<C-L> :lnfile
    " [q     :cprevious ]q     :cnext  [Q :cfirst ]Q : clast
    " [t     :tprevious ]t     :tnext  [T :tfirst ]T : tlast
    " [<C-Q> :cpfile (Note that <C-Q> only works in a terminal if you disable
    " ]<C-Q> :cnfile flow control: stty -ixon)
    " }}}
endif
" }}}

" Colors {{{
" vim-colors-solarized: Solarized配色方案 {{{
NeoBundle 'altercation/vim-colors-solarized'
" 可以使用:SolarizedOptions生成solarized所需的参数
" let g:solarized_visibility="low"    "default value is normal
" Xshell需要打开termtrans选项才能正确显示
let g:solarized_termtrans=1
" let g:solarized_degrade=0
" let g:solarized_bold=0
" let g:solarized_underline=1
" let g:solarized_italic=1
" let g:solarized_termcolors=16
" let g:solarized_contrast="normal"
" let g:solarized_diffmode="normal"
" let g:solarized_hitrail=1
" let g:solarized_menu=1

if !s:is_gui " 在终端模式下，使用16色（终端需要使用solarized配色方案才能得到所要的效果）
    " set t_Co=16
end
" let g:solarized_termcolors=256
" }}}
" Zenburn: Zenburn配色方案 {{{
NeoBundle 'Zenburn'
" }}}
" molokai: Molokai配色方案 {{{
NeoBundle 'tomasr/molokai'
let g:molokai_original = 1
let g:rehash256 = 1
" }}}
" base16-vim: Base16配色方案 {{{
NeoBundle 'chriskempson/base16-vim'
let g:base16_shell_path=s:vimrc_path . '/bundle/base16-shell/scripts'
if !s:is_gui
    let g:base16colorspace=256
endif
" }}}
" base16-shell: Base16配色方案配套使用的shell脚本 {{{
NeoBundle 'chriskempson/base16-shell', {
            \ }
" }}}
" }}}

" 载入manual-bundles下的插件 {{{
"call neobundle#local(fnamemodify(finddir("manual-bundles", &runtimepath), ":p"), {}, ['asciidoc', 'my_config'])
let g:local_bundles_path = fnamemodify(finddir("manual-bundles", &runtimepath), ":p")
" my_config: 其它的设置 {{{
NeoBundle 'my_config', {
            \ 'type' : 'nosync',
            \ 'base' : g:local_bundles_path,
            \ }
" }}}
" }}}

" 禁用部分插件 {{{
for plugin in g:dotvim_settings.disabled_plugins
    exec 'NeoBundleDisable '.plugin
endfor
" }}}

" 完成neobundle {{{
call neobundle#end()

filetype plugin indent on     " Required!
syntax enable
" }}}

" 检查有没有需要安装的插件 {{{
" Installation check.
NeoBundleCheck

if !has('vim_starting')
    " Call on_source hook when reloading .vimrc.
    call neobundle#call_hook('on_source')
endif
" }}}
" }}}

" Key mappings " {{{

" 支持alt键 {{{
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
" }}}

" 简化对常用目录的访问 {{{
" "用,cd进入当前目录
" nmap ,cd :cd <C-R>=expand("%:p:h")<CR><CR>
" "用,e可以打开当前目录下的文件
" nmap ,e :e <C-R>=escape(expand("%:p:h")."/", ' \')<CR>
" "在命令中，可以用 %/ 得到当前目录。如 :e %/
" cmap %/ <C-R>=escape(expand("%:p:h")."/", ' \')<CR>
" }}}

" 光标移动 {{{
" Key mappings to ease browsing long lines
nnoremap <Down>      gj
nnoremap <Up>        gk
inoremap <Down> <C-O>gj
inoremap <Up>   <C-O>gk
" }}}

" 操作tab页 {{{
" Ctrl-Tab/Ctrl-Shirt-Tab切换Tab
nmap <silent> <C-S-tab> :tabprevious<CR>
nmap <silent> <C-tab>   :tabnext<CR>
map  <silent> <C-S-tab> :tabprevious<CR>
map  <silent> <C-tab>   :tabnext<CR>
imap <silent> <C-S-tab> <ESC>:tabprevious<CR>i
imap <silent> <C-tab>   <ESC>:tabnext<CR>i
" }}}

" 查找 {{{
" <F3>自动在当前文件中vimgrep当前word，g<F3>在当前目录下，vimgrep_files指定的文件中查找
"nmap <silent> <F3> :execute "vimgrep /\\<" . expand("<cword>") . "\\>/j **/*.cpp **/*.c **/*.h **/*.php"<CR>:botright copen<CR>
"nmap <silent> <S-F3> :execute "vimgrep /\\<" . expand("<cword>") . "\\>/j %" <CR>:botright copen<CR>
"map <silent> <F3> <ESC>:execute "vimgrep /\\<" . expand("<cword>") . "\\>/j **/*.cpp **/*.cxx **/*.c **/*.h **/*.hpp **/*.php" <CR><ESC>:botright copen<CR>
nmap <silent> g<F3> <ESC>:<C-U>exec "vimgrep /\\<" . expand("<cword>") . "\\>/j " . b:vimgrep_files <CR><ESC>:botright copen<CR>
"map <silent> <S-F3> <ESC>:execute "vimgrep /\\<" . expand("<cword>") . "\\>/j %" <CR><ESC>:botright copen<CR>
nmap <silent> <F3> <ESC>:<C-U>exec "vimgrep /\\<" . expand("<cword>") . "\\>/j %" <CR><ESC>:botright copen<CR>

" V模式下，搜索选中的内容而不是当前word
vnoremap <silent> g<F3> :exec "vimgrep /" . substitute(escape(s:VisualSelection(), '/\.*$^~['), '\_s\+', '\\_s\\+', 'g') . "/j " . b:vimgrep_files <CR><ESC>:botright copen<CR>
vnoremap <silent> <F3> :exec "vimgrep /" . substitute(escape(s:VisualSelection(), '/\.*$^~['), '\_s\+', '\\_s\\+', 'g') . "/j %" <CR><ESC>:botright copen<CR>
" }}}

" 在VISUAL模式下，缩进后保持原来的选择，以便再次进行缩进 {{{
vnoremap > >gv
vnoremap < <gv
" }}}

" folds {{{
" zJ/zK跳到下个/上个折叠处，并只显示该折叠的内容
nnoremap zJ zjzx
nnoremap zK zkzx
nnoremap zr zr:echo 'foldlevel: ' . &foldlevel<CR>
nnoremap zm zm:echo 'foldlevel: ' . &foldlevel<CR>
nnoremap zR zR:echo 'foldlevel: ' . &foldlevel<CR>
nnoremap zM zM:echo 'foldlevel: ' . &foldlevel<CR>
" }}}

" 一些方便编译的快捷键 {{{
if exists(":Make")  " vim-dispatch提供了异步的make
    nnoremap <silent> <Leader>pc :<C-U>Make<CR>
    nnoremap <silent> <Leader>cc :<C-U>Make<CR>
    nnoremap <silent> <Leader>pT :<C-U>Make unittest<CR>
    nnoremap <silent> <Leader>pC :<C-U>Make clean<CR>
    nnoremap <silent> <Leader>ps :<C-U>Make stage<CR>
    nnoremap <silent> [make]d :<C-U>Make doc<CR>
else
    nnoremap <silent> <Leader>pc :<C-U>make<CR>
    nnoremap <silent> <Leader>pT :<C-U>make unittest<CR>
    nnoremap <silent> <Leader>pC :<C-U>make clean<CR>
    nnoremap <silent> <Leader>ps :<C-U>make stage<CR>
    nnoremap <silent> [make]d :<C-U>make doc<CR>
endif
" }}}

" 用jk/kj退出编辑模式和命令模式 {{{
inoremap jk <Esc>
cnoremap jk <Esc>

inoremap kj <Esc>
cnoremap kj <Esc>
" }}}

" 其它 {{{
nmap <silent> <Leader>bd :bdelete<CR>
nmap <silent> <Leader>bn :bnext<CR>
nmap <silent> <Leader>bp :bprevious<CR>
nmap <silent> <Leader>bR :e<CR>
nmap <silent> <Leader>bw :set readonly!<CR>

nmap <silent> <Leader><Tab> <C-^>
nmap <silent> <Leader>ww <C-W><C-W>

nmap <silent> <Leader>sc :<C-U>set nohlsearch<CR>

nmap <silent> <Leader>fs :w<CR>
nmap <silent> <Leader>fS :wa<CR>

nmap <silent> <Leader>fy :<C-U>echo expand("%:p")<CR>

nmap <silent> <Leader>en :<C-U>lnext<CR>
nmap <silent> <Leader>ep :<C-U>lprevious<CR>

nmap <silent> <Leader>qq :<C-U>qa<CR>
nmap <silent> <Leader>qQ :<C-U>qa!<CR>
nmap <silent> <Leader>qs :<C-U>xa<CR>

nmap <silent> <Leader>tn :<C-U>set number!<CR>
nmap <silent> <Leader>tr :<C-U>set relativenumber!<CR>

nmap <silent> <Leader>xdw :<C-U>%s/\s\+$//<CR>
nmap <silent> <Leader>j= mzgg=G`z

" Split line(opposite to S-J joining line)
" nnoremap <silent> <C-J> gEa<CR><ESC>ew

" map <silent> <C-W>v :vnew<CR>
" map <silent> <C-W>s :snew<CR>

" nnoremap * :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>
" }}}

" }}}

" 自定义命令 {{{
"   Output {{{
function! OutputSplitWindow(...)
  " this function output the result of the Ex command into a split scratch buffer
  let cmd = join(a:000, ' ')
  let temp_reg = @"
  redir @"
  silent! execute cmd
  redir END
  let output = copy(@")
  let @" = temp_reg
  if empty(output)
    echoerr "no output"
  else
    new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
    put! =output
  endif
endfunction
command! -nargs=+ -complete=command Output call OutputSplitWindow(<f-args>)
" }}}

" SyntaxId {{{
function! s:syntax_id()
      return synIDattr(synID(line('.'), col('.'), 0), 'name')
  endfunction
  command! SyntaxId echo s:syntax_id()
" }}}

" diff commands --- {{{
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
command! -bar ToggleDiff if &diff | execute 'windo diffoff'  | else
      \                           | execute 'windo diffthis' | endif
" }}}
" }}}

" color scheme and statusline {{{
if !empty(globpath(&rtp, 'colors/'.g:dotvim_settings.colorscheme.'.vim'))
    " 只有在colorscheme存在时才载入
    if g:dotvim_settings.colorscheme =~ '^base16-'
        " base16时，把airline的theme设置为base16，否则显示不对
        let g:airline_theme = 'base16'

        if filereadable(expand("~/.vimrc_background"))
            " base16使用~/.vimrc_background指定的、最后一次使用的配色
            let base16colorspace=256
            source ~/.vimrc_background
        else
            let &background=g:dotvim_settings.background
            execute "silent! colorscheme " . g:dotvim_settings.colorscheme
        endif
    else
        let &background=g:dotvim_settings.background
        execute "silent! colorscheme " . g:dotvim_settings.colorscheme
    endif
else
    " 找不到需要的配色时，使用内置的配色
    let &background=g:dotvim_settings.background
    colorscheme desert
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
" }}}

if filereadable(s:vimrc_path . "/project_setting")
    exec "source " . s:vimrc_path . "/project_setting"
endif

" vim: fileencoding=utf-8 foldmethod=marker foldlevel=0:
