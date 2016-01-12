scriptencoding utf-8

" 判断当前环境 {{{
" 判断操作系统
let s:is_windows = has("win32") || has("win64")
let s:is_cygwin = has('win32unix')
let s:is_macvim = has('gui_macvim')

" 判断是终端还是gvim
let s:is_gui = has("gui_running")

" 当前脚本路径
let s:vimrc_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" 确定libclang的位置
let s:libclang_path = ""

if s:is_windows " windows下把vimrc目录下的win32加入到路径中，以便使用该目录下的工具
    let $PATH = $PATH . ";" . s:vimrc_path . '\win32'
endif

" 确定ag可执行程序
let s:ag_path = ""
if executable("ag")
    let s:ag_path = "ag"
endif

let s:ctags_path = ""
if executable("ctags")
    let s:ctags_path = "ctags"
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
    if filereadable(s:vimrc_path . "/win32/libclang.dll")
        let s:libclang_path = s:vimrc_path . "/win32"
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

let s:clang_include_path = fnamemodify(finddir("include",  s:libclang_path . "/clang/**"), ":p")

if s:ag_path != ""
    exec 'set grepprg=' . s:ag_path . '\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow'
    set grepformat=%f:%l:%c:%m
endif
" }}}

" 插件组命名及选择要使用的插件及插件组 {{{
" Impacted by https://github.com/bling/dotvim
" 如果~下有vimrc.local则使用
if filereadable($HOME . "/vimrc.local")
    exec "source " . $HOME . "/vimrc.local"
elseif filereadable($HOME . "/.vimrc.local")
    exec "source " . $HOME . "/.vimrc.local"
endif

if !exists('g:dotvim_user_settings')
    let g:dotvim_user_settings = {}
endif

let s:cache_dir = get(g:dotvim_user_settings, 'cache_dir', '~/.vim_cache')

let g:dotvim_settings = {}
let g:dotvim_settings.default_indent = 4
if v:version >= '703' && has('lua')
    let g:dotvim_settings.autocomplete_method = 'neocomplete'
elseif filereadable(expand(s:vimrc_path . "/bundle/YouCompleteMe/python/ycm_core.*"))
    let g:dotvim_settings.autocomplete_method = 'ycm'
else
    let g:dotvim_settings.autocomplete_method = 'neocomplcache'
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
let g:dotvim_settings.notes_directory = ['~/vim-notes']

if v:version >= '704' && has('python')
    let g:dotvim_settings.snippet_engine = 'ultisnips'
else
    let g:dotvim_settings.snippet_engine = 'neosnippet'
endif

if exists('g:dotvim_user_settings.plugin_groups')
    let g:dotvim_settings.plugin_groups = g:dotvim_user_settings.plugin_groups
else
    let g:dotvim_settings.plugin_groups = []
    call add(g:dotvim_settings.plugin_groups, 'core')
    call add(g:dotvim_settings.plugin_groups, 'unite')
    call add(g:dotvim_settings.plugin_groups, 'editing')
    call add(g:dotvim_settings.plugin_groups, 'navigation')
    call add(g:dotvim_settings.plugin_groups, 'snippet')
    call add(g:dotvim_settings.plugin_groups, 'autocomplete')
    call add(g:dotvim_settings.plugin_groups, 'textobj')
    call add(g:dotvim_settings.plugin_groups, 'scm')
    call add(g:dotvim_settings.plugin_groups, 'doc')
    call add(g:dotvim_settings.plugin_groups, 'syntax')
    call add(g:dotvim_settings.plugin_groups, 'visual')
    call add(g:dotvim_settings.plugin_groups, 'misc')

    call add(g:dotvim_settings.plugin_groups, 'cpp')
    call add(g:dotvim_settings.plugin_groups, 'python')
    call add(g:dotvim_settings.plugin_groups, 'haskell')
    call add(g:dotvim_settings.plugin_groups, 'csharp')
    call add(g:dotvim_settings.plugin_groups, 'web')
    call add(g:dotvim_settings.plugin_groups, 'shell')

    " exclude all language-specific plugins by default
    if !exists('g:dotvim_user_settings.plugin_groups_exclude')
        let g:dotvim_user_settings.plugin_groups_exclude = ['cpp' , 'python' , 'haskell' , 'csharp' , 'web' , 'shell']
    endif
    for group in g:dotvim_user_settings.plugin_groups_exclude
        let i = index(g:dotvim_settings.plugin_groups, group)
        if i != -1
            call remove(g:dotvim_settings.plugin_groups, i)
        endif
    endfor
    if exists('g:dotvim_user_settings.plugin_groups_include')
        for group in g:dotvim_user_settings.plugin_groups_include
            call add(g:dotvim_settings.plugin_groups, group)
        endfor
    endif
endif
if exists('g:dotvim_user_settings.disabled_plugins')
    let g:dotvim_settings.disabled_plugins = g:dotvim_user_settings.disabled_plugins
else
    let g:dotvim_settings.disabled_plugins = []
endif
" override defaults with the ones specified in g:dotvim_user_settings
for key in keys(g:dotvim_settings)
    if has_key(g:dotvim_user_settings, key)
        let g:dotvim_settings[key] = g:dotvim_user_settings[key]
    endif
endfor
" }}}

" Helper Functions {{{
function! s:RemoveTrailingSpace() "{{{
    if $VIM_HATE_SPACE_ERRORS != '0' &&
                \(&filetype == 'c' || &filetype == 'cpp' || &filetype == 'vim')
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
    let path = resolve(expand(s:cache_dir))
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

function! FindVcsRoot(path) " {{{
    let vcs_folder = ['.git', '.hg', '.svn', '.bzr', '_darcs']

    let path = a:path
    if empty(path)
        let path = expand('%:p:h')
    else
        let path = fnamemodify(path, ':p')
    endif

    let vcs_dir = ''
    for vcs in vcs_folder
        let vcs_dir = finddir(vcs, path.';')
        if !empty(vcs_dir)
            if vcs == '.svn' " 对于旧svn版本，可能连续多层目录都有.svn，以最上层的为根
                let root = fnamemodify(vcs_dir, ':p:h')
                let parent = fnamemodify(root, ':h')
                while parent != root
                    if !isdirectory(parent . "/" . vcs) " 上层目录没有.svn子目录
                        break
                    endif
                    let root = parent
                    let parent = fnamemodify(root, ':h')
                endwhile
                return root
            else
                return fnamemodify(vcs_dir, ':h')
            endif
        endif
    endfor

    return path
endfunction " }}}


" s:VisualSelection() {{{
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
    set shellpipe=\|\ tee
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
    "set encoding=ucs-4
    "set encoding=utf-8
    " set encoding=utf-8
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
" }}}

" Auto commands " {{{

" Misc {{{
if (s:is_windows)
    autocmd GUIEnter * simalt ~x " 启动时自动全屏
endif

autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal g'\"" | endif " restore position in file

" automatically open and close the popup menu / preview window
autocmd CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
" }}}

" Filetype detection " {{{
autocmd BufRead,BufNewFile {Gemfile,Rakefile,Capfile,*.rake,config.ru} setf ruby
autocmd BufRead,BufNewFile {*.md,*.mkd,*.markdown} setf markdown
autocmd BufRead,BufNewFile {COMMIT_EDITMSG}  setf gitcommit
autocmd BufRead,BufNewFile TDM*C,TDM*H       setf c
autocmd BufRead,BufNewFile *.dox             setf cpp    " Doxygen
autocmd BufRead,BufNewFile *.cshtml          setf cshtml

"" Remove trailing spaces for C/C++ and Vim files
autocmd BufWritePre *                  call s:RemoveTrailingSpace()

autocmd BufRead,BufNewFile todo.txt,done.txt           setf todo
autocmd BufRead,BufNewFile *.mm                        setf xml
autocmd BufRead,BufNewFile *.proto                     setf proto
autocmd BufRead,BufNewFile Jamfile*,Jamroot*,*.jam     setf jam
autocmd BufRead,BufNewFile pending.data,completed.data setf task
autocmd BufRead,BufNewFile *.ipp                       setf cpp
" }}}

" Filetype related autosettings " {{{
autocmd FileType diff  setlocal shiftwidth=4 tabstop=4
" autocmd FileType html  setlocal autoindent indentexpr= shiftwidth=2 tabstop=2
autocmd FileType changelog setlocal textwidth=76
" 把-等符号也作为xml文件的有效关键字，可以用Ctrl-N补全带-等字符的属性名
autocmd FileType {xml,xslt} setlocal iskeyword=@,-,\:,48-57,_,128-167,224-235
if executable("tidy")
    autocmd FileType xml        exe 'setlocal equalprg=tidy\ -quiet\ -indent\ -xml\ -raw\ --show-errors\ 0\ --wrap\ 0\ --vertical-space\ 1\ --indent-spaces\ 4'
elseif executable("xmllint")
    autocmd FileType xml        exe 'setlocal equalprg=xmllint\ --format\ --recover\ --encode\ UTF-8\ -'
endif

autocmd FileType qf setlocal wrap linebreak
autocmd FileType vim nnoremap <silent> <buffer> K :<C-U>help <C-R><C-W><CR>
autocmd FileType man setlocal foldmethod=indent foldnestmax=2 foldenable nomodifiable nonumber shiftwidth=3 foldlevel=2
autocmd FileType cs setlocal wrap

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
        autocmd FileType xml call s:jing_settings("xml")
        autocmd FileType rnc call s:jing_settings("rnc")
    augroup END
endif

"autocmd BufRead,BufNewFile *.adoc,*.asciidoc  set filetype=asciidoc
function! MyAsciidocFoldLevel(lnum)
    let lt = getline(a:lnum)
    let fh = matchend(lt, '\V\^\(=\+\)\ze\s\+\S')
    if fh != -1
        return '>'.fh
    endif
    return '='
endfunction

autocmd BufNewFile *.adoc,*.asciidoc setlocal fileencoding=utf-8
autocmd FileType asciidoc setlocal shiftwidth=2
            \ tabstop=2
            \ textwidth=0 wrap formatoptions=cqnmB
            \ makeprg=asciidoc\ -o\ numbered\ -o\ toc\ -o\ data-uri\ $*\ %
            \ errorformat=ERROR:\ %f:\ line\ %l:\ %m
            \ foldexpr=MyAsciidocFoldLevel(v:lnum)
            \ foldmethod=expr
            \ nospell
            \ isfname-=#
            \ isfname-=[
            \ isfname-=]
            \ isfname-=:
            \ suffixesadd=.asciidoc,.adoc
            \ formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\\|^\\s*<\\d\\+>\\s\\+\\\\|^\\s*[a-zA-Z.]\\.\\s\\+\\\\|^\\s*[ivxIVX]\\+\\.\\s\\+
            \ comments=s1:/*,ex:*/,://,b:#,:%,:XCOMM,fb:-,fb:*,fb:+,fb:.,fb:>
" }}}

" 根据不同的文件类型设定g<F3>时应该查找的文件 {{{
autocmd FileType *             let b:vimgrep_files=expand("%:e") == "" ? "**/*" : "**/*." . expand("%:e")
autocmd FileType c,cpp         let b:vimgrep_files="**/*.cpp **/*.cxx **/*.c **/*.h **/*.hpp **/*.ipp"
autocmd FileType php           let b:vimgrep_files="**/*.php **/*.htm **/*.html"
autocmd FileType cs            let b:vimgrep_files="**/*.cs"
autocmd FileType vim           let b:vimgrep_files="**/*.vim"
autocmd FileType javascript    let b:vimgrep_files="**/*.js **/*.htm **/*.html"
autocmd FileType python        let b:vimgrep_files="**/*.py"
autocmd FileType xml           let b:vimgrep_files="**/*.xml"
autocmd FileType jam           let b:vimgrep_files="**/*.jam **/Jam*"
" }}}

" 自动打开quickfix窗口 {{{
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
" }}}

" python autocommands {{{
" 设定python的makeprg
if executable("python2")
    autocmd FileType python setlocal makeprg=python2\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
else
    autocmd FileType python setlocal makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
endif

"autocmd FileType python set errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
autocmd FileType python setlocal errorformat=%[%^(]%\\+('%m'\\,\ ('%f'\\,\ %l\\,\ %v\\,%.%#
autocmd FileType python setlocal smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
" }}}

" Text file encoding autodetection {{{
autocmd BufReadPre  *.gb               call SetFileEncodings('gbk')
autocmd BufReadPre  *.big5             call SetFileEncodings('big5')
autocmd BufReadPre  *.nfo              call SetFileEncodings('cp437') | set ambiwidth=single
autocmd BufReadPre  *.php              call SetFileEncodings('utf-8')
autocmd BufReadPre  *.lua              call SetFileEncodings('utf-8')
autocmd BufReadPost *.gb,*.big5,*.nfo,*.php,*.lua  call RestoreFileEncodings()

autocmd BufWinEnter *.txt              call CheckFileEncoding()

" 强制用UTF-8打开vim文件
autocmd BufReadPost  .vimrc,*.vim nested     call ForceFileEncoding('utf-8')

autocmd FileType task call ForceFileEncoding('utf-8')
" }}}

" }}}

" 用于各插件的热键前缀 {{{
nnoremap [unite] <Nop>
xnoremap [unite] <Nop>
nmap <Leader>f [unite]
xmap <Leader>f [unite]

nnoremap [unite2] <Nop>
xnoremap [unite2] <Nop>
nmap <Leader>F [unite2]
xmap <Leader>F [unite2]

nnoremap [repl] <Nop>
xnoremap [repl] <Nop>
nmap <Leader>r [repl]
xmap <Leader>r [repl]

nnoremap [tag] <Nop>
nmap <C-\> [tag]
nnoremap [tag] <C-\>

nnoremap [unite-tag] <Nop>
nmap <C-\><C-\> [unite-tag]

nnoremap [ctrlsf] <Nop>
vnoremap [ctrlsf] <Nop>
nmap \s [ctrlsf]
vmap \s [ctrlsf]

nnoremap [grep] <Nop>
vnoremap [grep] <Nop>
nmap \S [grep]
vmap \S [grep]

nnoremap [code] <Nop>
nmap <Leader>c [code]

nnoremap [fswitch] <Nop>
nmap <Leader>o [fswitch]

nnoremap [make] <Nop>
nmap <Leader>t [make]

nnoremap [mark] <Nop>
vnoremap [mark] <Nop>
nmap <Leader>m [mark]
vmap <Leader>m [mark]
" }}}

" Plugins {{{

" Brief help
" :NeoBundleList          - list configured bundles
" :NeoBundleInstall(!)    - install(update) bundles
" :NeoBundleClean(!)      - confirm(or auto-approve) removal of unused bundles

" Loading NeoBundle {{{
filetype off                   " Required!

if has('vim_starting') && match("neobundle", &runtimepath) < 0
    let &runtimepath .= "," . fnamemodify(finddir("bundle/neobundle.vim", &runtimepath), ":p")
endif

call neobundle#begin()

let g:neobundle_default_git_protocol = 'https'
let g:neobundle#install_process_timeout = 1500

" 使用submodule管理NeoBundle
" " Let NeoBundle manage NeoBundle
" NeoBundle 'Shougo/neobundle.vim'    " 插件管理软件
" }}}

if count(g:dotvim_settings.plugin_groups, 'core') "{{{
    " vimproc: 用于异步执行命令的插件，被其它插件依赖 {{{
    if (s:is_windows)
        " Windows下需要固定为与dll对应的版本
        NeoBundle 'Shougo/vimproc', { 'rev' : '725de1a' }
        if has("win64") && filereadable(s:vimrc_path . "/win32/vimproc_win64.dll")
            let g:vimproc_dll_path = s:vimrc_path . "/win32/vimproc_win64.dll"
        elseif has("win32") && filereadable(s:vimrc_path . "/win32/vimproc_win32.dll")
            let g:vimproc_dll_path = s:vimrc_path . "/win32/vimproc_win32.dll"
        endif
    else
        NeoBundle 'Shougo/vimproc', {
                    \ 'build' : {
                    \     'windows' : 'echo "Sorry, cannot update vimproc binary file in Windows."',
                    \     'cygwin' : 'make -f make_cygwin.mak && touch -t 200001010000.00 autoload/vimproc_cygwin.dll',
                    \     'mac' : 'make -f make_mac.mak && touch -t 200001010000.00 autoload/vimproc_unix.so',
                    \     'unix' : 'make -f make_unix.mak && touch -t 200001010000.00 autoload/vimproc_unix.so',
                    \ },
                    \ }
    endif
    " }}}
    " vim-misc: xolox的插件依赖的库 {{{
    NeoBundleLazy 'xolox/vim-misc', {
                \ 'function_prefix' : 'xolox',
                \ }
    " }}}
    " ingo-library: Ingo Karkat的插件依赖的库 {{{
    NeoBundleLazy 'ingo-library'
    " }}}
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'unite') "{{{
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

    autocmd! FileType unite call s:unite_my_settings()
    function! s:unite_my_settings() "{{{
        unmap <buffer> <c-l>

        nmap <buffer> <ESC>      <Plug>(unite_exit)
        imap <buffer> jj      <Plug>(unite_insert_leave)

        imap <buffer><expr> j unite#smart_map('j', '')
        imap <buffer> <TAB>   <Plug>(unite_select_next_line)
        imap <buffer> <S-TAB>   <Plug>(unite_select_previous_line)

        imap <buffer> <C-w>     <Plug>(unite_delete_backward_path)
        imap <buffer> '     <Plug>(unite_quick_match_default_action)
        nmap <buffer> '     <Plug>(unite_quick_match_default_action)
        imap <buffer><expr> x
                    \ unite#smart_map('x', "\<Plug>(unite_choose_action)")
        nmap <buffer> <C-n>	<Plug>(unite_rotate_next_source)
        nmap <buffer> <C-p>	<Plug>(unite_rotate_previous_source)
        nmap <buffer> x     <Plug>(unite_choose_action)
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

        nnoremap <silent><buffer><expr> v     unite#do_action('vimfiler')

        " Runs "split" action by <C-s>.
        imap <silent><buffer><expr> <C-s>     unite#do_action('split')
    endfunction "}}}
    " }}}
    " unite-outline: 提供代码的大纲。通过\fo访问 {{{
    NeoBundleLazy 'Shougo/unite-outline', {
                \ 'on_unite' : ['outline'],
                \ }
    " }}}
    " neoyank.vim: unite的history/yank源，提供历史yank缓冲区。通过\fy访问 {{{
    NeoBundle 'Shougo/neoyank.vim', {
                \ 'on_unite' : ['history/yank'],
                \ }
    let g:neoyank#file = s:path_join(s:get_cache_dir('neoyank'), 'history_yank')
    " }}}
    " unite-mark: 列出所有标记点 {{{
    NeoBundleLazy 'tacroe/unite-mark', {
                \ 'on_unite' : ['mark'],
                \ }
    " }}}
    " unite-help: 查找vim的帮助 {{{
    NeoBundleLazy 'shougo/unite-help', {
                \ 'on_unite' : ['help'],
                \ }
    " }}}
    " unite-tag: 跳转到光标下的tag。通过\fT访问 {{{
    NeoBundleLazy 'tsukkee/unite-tag', {
                \ 'on_unite' : ['tag', 'tag/include', 'tag/file']
                \ }
    " }}}
    " unite-colorscheme: 列出所有配色方案 {{{
    NeoBundleLazy 'ujihisa/unite-colorscheme', {
                \ 'on_unite' : ['colorscheme'],
                \ }
    " }}}
    " unite-quickfix: 过滤quickfix窗口（如在编译结果中查找） {{{
    NeoBundleLazy 'osyo-manga/unite-quickfix', {
                \ 'on_unite' : ['quickfix'],
                \ }
    " }}}
    " vim-unite-history: 搜索命令历史 {{{
    NeoBundleLazy 'thinca/vim-unite-history', {
                \ 'on_unite' : ['history/command', 'history/search']
                \ }
    " }}}
    " unite-tselect: 跳转到光标下的tag。通过g]和g<C-]>访问 {{{
    NeoBundleLazy 'eiiches/unite-tselect', {
                \ 'on_unite' : 'tselect',
                \ }
    " }}}
    " vim-versions: 支持svn/git，\fv 看未提交的文件列表，\fl 看更新日志 {{{
    NeoBundleLazy 'hrsh7th/vim-versions', {
                \ 'on_cmd' : ['UniteVersions'],
                \ 'on_unite' : ['versions', 'versions/svn/branch', 'versions/svn/log', 'versions/svn/status', 'versions/svn/branch', 'versions/svn/log', 'versions/svn/status'],
                \ }
    " }}}
    " unite-gtags: Unite下调用gtags {{{
    NeoBundleLazy 'hewes/unite-gtags', {
                \ "on_unite" : ["gtags/ref","gtags/def","gtags/context","gtags/completion","gtags/grep","gtags/file"],
                \ }
    call neobundle#config('unite-gtags', {
                \ 'disabled' : !s:has_global,
                \ })

    if neobundle#tap('unite-gtags')
        nnoremap [unite-tag]s :<C-u>Unite gtags/context<CR>
        nnoremap [unite-tag]S :<C-u>Unite gtags/ref:
        nnoremap [unite-tag]g :<C-u>Unite gtags/def<CR>
        nnoremap [unite-tag]G :<C-u>Unite gtags/def:
        nnoremap [unite-tag]t :<C-u>UniteWithCursorWord gtags/grep<CR>
        nnoremap [unite-tag]T :<C-u>Unite gtags/grep:
        nnoremap [unite-tag]e :<C-u>UniteWithCursorWord gtags/grep<CR>
        nnoremap [unite-tag]E :<C-u>Unite gtags/grep:
        nnoremap [unite-tag]f :<C-u>Unite gtags/file<CR>
    endif
    " }}}
    " tabpagebuffer.vim: 记录一个tab中包含的buffer {{{
    NeoBundle 'Shougo/tabpagebuffer.vim'
    " }}}
    " neomru.vim: 最近访问的文件 {{{
    NeoBundle 'Shougo/neomru.vim'
    let g:neomru#file_mru_path = s:path_join(s:get_cache_dir('neomru'), 'file')
    let g:neomru#directory_mru_path = s:path_join(s:get_cache_dir('neomru'), 'directory')
    " }}}
    " unite-fold: fold {{{
    NeoBundle 'osyo-manga/unite-fold'
    " }}}
    " unite的key binding {{{
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
    nnoremap <silent> [unite2]g :<C-u>Unite grep:<C-R>=expand("%:p:h")<CR> -buffer-name=search -no-quit -start-insert -input=<C-R><C-W><CR>

    nnoremap <silent> [unite]/ :<C-U>Unite line -buffer-name=search -start-insert -input=<C-R><C-W><CR>
    nnoremap <silent> [unite]? :<C-U>Unite line -buffer-name=search -start-insert<CR>
    "nnoremap <silent> [unite]B :<C-U>Unite -buffer-name=bookmarks bookmark<CR>
    nnoremap <silent> [unite]f :<C-u>Unite -buffer-name=files file:<C-R>=expand("%:p:h")<CR> buffer file/new:<C-R>=expand("%:p:h")<CR> -start-insert<CR>
    nnoremap <silent> [unite]b :<C-u>Unite -buffer-name=files buffer_tab -start-insert<CR>
    nnoremap <silent> [unite]B :<C-u>Unite -buffer-name=files buffer file_mru -start-insert<CR>
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
    " nnoremap <silent> [unite]t :<C-U>wall<CR><ESC>:Unite -buffer-name=build -no-quit build::test<CR>
    nnoremap <silent> [unite]t :<C-U>Unite -buffer-name=tabs tab<CR>
    " nnoremap <silent> [unite]U :<C-u>UniteResume -no-quit<CR>
    " nnoremap <silent> [unite]u :<C-u>UniteResume<CR>
    nnoremap <silent> [unite]r :<C-u>UniteResume -no-start-insert<CR>
    " nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=files buffer file_rec:! file_mru bookmark<cr><c-u>
    nnoremap <silent> [unite]d :<C-u>Unite -buffer-name=files bookmark directory_mru<CR>
    nnoremap <silent> [unite]ma :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
    nnoremap <silent> [unite]me :<C-u>Unite output:message<CR>

    if s:is_windows
        nnoremap <silent> [unite]F
                    \ :<C-u>Unite -buffer-name=files -multi-line
                    \ file jump_point file_point buffer
                    \ file_rec:! file_mru file/new<CR>
    else
        nnoremap <silent> [unite]F
                    \ :<C-u>Unite -buffer-name=files -multi-line
                    \ file jump_point file_point buffer
                    \ file_rec/async:! file_mru file/new<CR>
    endif

    if neobundle#tap('unite-outline') && neobundle#tap('unite-fold')
        nnoremap <silent> [unite]o  :<C-u>Unite fold outline -no-quit -no-start-insert -vertical -toggle -winwidth=40<CR>
    endif

    if neobundle#tap('unite-tselect')
        nnoremap g<C-]> :<C-u>Unite -immediately tselect:<C-r>=expand('<cword>')<CR><CR>
        nnoremap g] :<C-u>Unite tselect:<C-r>=expand('<cword>')<CR><CR>
    endif

    if neobundle#tap('vim-versions')
        nnoremap <silent> [unite]v :<C-u>UniteVersions status<CR>
        nnoremap <silent> [unite]l :<C-u>UniteVersions log<CR>
    endif
    " }}}
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'editing') "{{{
    " vim-alignta: 代码对齐插件。通过\fa访问 {{{
    NeoBundleLazy 'h1mesuke/vim-alignta', {
                \ 'on_cmd' : ['Alignta'],
                \ 'on_unite' : 'alignta',
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
    " }}}
    " YankRing.vim: 在粘贴时，按了p之后，可以按<C-P>粘贴存放在剪切板历史中的内容 {{{
    "NeoBundle 'YankRing.vim'
    "    let g:yankring_persist = 0              "不把yankring持久化
    "    let g:yankring_share_between_instances = 0
    "    let g:yankring_manual_clipboard_check = 1
    " }}}
    "" vis: 在块选后（<C-V>进行选择），:B cmd在选中内容中执行cmd {{{
    "NeoBundleLazy 'vis', {
    "    \ 'on_cmd' : ['B'],
    "    \ }
    "" }}}
    " vim-operator-user: 被多个vim-operator插件依赖的插件 {{{
    NeoBundleLazy 'kana/vim-operator-user', {
                \ 'on_func' : 'operator#user#define',
                \ }
    " }}}
    " vim-operator-replace: 双引号x_{motion} : 把{motion}涉及的内容替换为register x的内容 {{{
    NeoBundleLazy 'kana/vim-operator-replace', {
                \ 'depends' : 'vim-operator-user',
                \ 'on_map' : [
                \     ['nx', '<Plug>(operator-replace)']
                \ ]}
    nmap _  <Plug>(operator-replace)
    xmap _  <Plug>(operator-replace)
    " }}}
    " vim-operator-surround: sa{motion}/sd{motion}/sr{motion}：增/删/改括号、引号等 {{{
    NeoBundleLazy 'rhysd/vim-operator-surround', {
                \ 'depends' : 'vim-operator-user',
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
    " DrawIt: 使用横、竖线画图、制表。\di和\ds分别启、停画图模式。在模式中，hjkl移动光标，方向键画线 {{{
    NeoBundleLazy 'DrawIt', {
                \ 'on_map' : [['n', '<Leader>di']],
                \ 'on_cmd' : ['DIstart', 'DIsngl', 'DIdbl', 'DrawIt'],
                \ }
    " }}}
    " " vim-notes: :Note创建新的笔记 {{{
    " NeoBundleLazy 'xolox/vim-notes', {
    "             \ 'on_cmd' : [
    "             \     {'name': 'Note', 'complete': 'customlist,xolox#notes#cmd_complete'},
    "             \     {'name': 'DeleteNote', 'complete': 'customlist,xolox#notes#cmd_complete'},
    "             \     {'name': 'SearchNotes', 'complete': 'customlist,xolox#notes#keyword_complete'},
    "             \     'RelatedNotes', 'RecentNotes', 'MostRecentNote', 'ShowTaggedNotes', 'IndexTaggedNotes',
    "             \     'NoteToMarkdown', 'NoteToMediawiki', 'NoteToHtml', 'NoteFromSelectedText',
    "             \     'SplitNoteFromSelectedText', 'TabNoteFromSelectedText',
    "             \ ],
    "             \ 'on_ft' : ['notes'],
    "             \ 'depends' : [
    "             \     'vim-misc',
    "             \ ],
    "             \ }
    " " let g:notes_suffix = '.markdown'
    " if exists('g:dotvim_settings.notes_directory')
    "     if type(g:dotvim_settings.notes_directory) == type([])
    "         let g:notes_directories = g:dotvim_settings.notes_directory
    "     else
    "         let g:notes_directories = [g:dotvim_settings.notes_directory]
    "     endif
    " endif
    " " }}}
    " vim-multiple-cursors: 同时编辑多处 {{{
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
    " echofunc: 在插入模式下输入(时，会在statusline显示函数的签名，对于有多个重载的函数，可通过<A-->/<A-=>进行切换 {{{
    NeoBundleLazy 'mbbill/echofunc', {
                \ 'on_ft' : ['c', 'cpp'],
                \ }
    " 启用global后，将不用ctags，因此echofunc.vim会失效
    call neobundle#config('echofunc', {
                \ 'disabled' : s:has_global,
                \ })
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
    " HiCursorWords: 高亮与光标下word一样的词 {{{
    NeoBundle 'OrelSokolov/HiCursorWords'
    let g:HiCursorWords_delay = 200
    let g:HiCursorWords_hiGroupRegexp = ''
    let g:HiCursorWords_debugEchoHiName = 0
    " }}}
    " tcomment_vim: 注释工具。gc{motion}/gcc/<C-_>等 {{{
    NeoBundle 'tomtom/tcomment_vim'
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
    if executable('python2')
        let g:syntastic_python_python_exec = 'python2'
    endif
    " }}}
    " vim-scriptease: 辅助编写vim脚本的工具 {{{
    NeoBundleLazy 'tpope/vim-scriptease', {
                \ 'on_ft' : ['vim', 'help'],
                \ 'on_cmd' : [
                \     { 'name' : 'PP', 'complete' : 'expression' },
                \     { 'name' : 'PPmsg', 'complete' : 'expression' },
                \     { 'name' : 'Verbose', 'complete' : 'command' },
                \     { 'name' : 'Time', 'complete' : 'command' },
                \     'Scriptnames', 'Runtime', 'Disarm', 'Ve', 'Vedit', 'Vopen', 'Vsplit', 'Vvsplit', 'Vtabedit', 'Vpedit', 'Vread', 'Console',
                \ ],
                \ }
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
    " vimple: :View查看ex命令输出等辅助功能 {{{
    NeoBundleLazy 'dahu/vimple', {
                \ 'on_map': [
                \     ['n',
                \       '<plug>vimple_ident_search', '<plug>vimple_ident_search_forward',
                \       '[I', ']I',
                \       '<plug>vimple_spell_suggest', 'z=',
                \       '<plug>vimple_filter',
                \     ],
                \ ],
                \ 'on_cmd': [
                \     'G', 'StringScanner', 'Mkvimrc', 'BufTypeDo', 'BufMatchDo',
                \     'QFargs', 'QFargslocal', 'LLargs', 'LLargslocal',
                \     'QFbufs', 'LLbufs', 'QFdo', 'LLdo', 'Filter',
                \     {'name': 'ReadIntoBuffer', 'complete': 'file'},
                \     {'name': 'View', 'complete': 'command'},
                \     {'name': 'ViewExpr', 'complete': 'command'},
                \     {'name': 'ViewSys', 'complete': 'command'},
                \     'Collect', 'Silently',
                \ ]}
    " }}}
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'navigation') "{{{
    " vim-easymotion: \\w启动word motion，\\f<字符>启动查找模式 {{{
    if v:version >= '703'
        NeoBundleLazy 'Lokaltog/vim-easymotion', {
                    \ 'on_map' : [['n'] + map(
                    \     ['f', 'F', 's', 't', 'T', 'w', 'W', 'b', 'B', 'e', 'E', 'ge', 'gE', 'j', 'k', 'n', 'N'],
                    \     '"<Leader><Leader>" . v:val')],
                    \ }
    else
        " NeoBundleLazy 'Lokaltog/vim-easymotion', {
        "             \ 'rev' : 'e41082',
        "             \ 'on_map' : [['n'] + map(
        "             \     ['f', 'F', 's', 't', 'T', 'w', 'W', 'b', 'B', 'e', 'E', 'ge', 'gE', 'j', 'k', 'n', 'N'],
        "             \     '"<Leader><Leader>" . v:val')],
        "             \ }                                 " \\w启动word motion，\\f<字符>启动查找模式
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
    " }}}
    " " clever-f.vim: 用f/F代替;来查找下一个字符 {{{
    " NeoBundleLazy 'rhysd/clever-f.vim', {
    "             \ 'on_map' : [['n', 'f', 'F', 't', 'T']],
    "             \ }
    " " }}}
    " " glowshi-ft.vim: 增强的f/t {{{
    " NeoBundleLazy 'saihoooooooo/glowshi-ft.vim', {
    "             \ 'on_map' : [
    "             \     ['n', '<Plug>', 'f', 'F', 't', 'T', ';', ','],
    "             \ ],
    "             \ }
    " " }}}
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
    if s:ag_path != ""
        let g:ackprg = s:ag_path . " --nogroup --column --smart-case --follow"
    endif

    " let g:ackhighlight = 1
    " let g:ack_autoclose = 1
    " let g:ack_autofold_results = 1
    " let g:ackpreview = 1
    " let g:ack_use_dispatch = 1

    " 在项目目录下找，可能退化为当前目录
    vmap     [grep]s :<C-U>Ack! <C-R>=g:CtrlSFGetVisualSelection()<CR> <C-R>=FindVcsRoot('')<CR><CR>
    nmap     [grep]s :<C-U>Ack! <C-R>=expand('<cword>')<CR> <C-R>=FindVcsRoot('')<CR><CR>
    nmap     [grep]S :<C-U>Ack!<SPACE>

    " 在当前文件目录下找
    vmap     [grep]b :<C-U>Ack! <C-R>=g:CtrlSFGetVisualSelection()<CR> <C-R>=expand('%:p:h')<CR><CR>
    nmap     [grep]b :<C-U>Ack! <C-R>=expand('<cword>')<CR> <C-R>=expand('%:p:h')<CR><CR>

    " 在当前目录下找
    vmap     [grep]c :<C-U>Ack! <C-R>=g:CtrlSFGetVisualSelection()<CR> <C-R>=getcwd()<CR><CR>
    nmap     [grep]c :<C-U>Ack! <C-R>=expand('<cword>')<CR> <C-R>=getcwd()<CR><CR>
    "}}}
    " ctrlsf.vim: 快速查找及编辑 {{{
    NeoBundleLazy 'dyng/ctrlsf.vim', {
                \ 'on_map' : [ '<Plug>CtrlSF' ],
                \ 'on_cmd' : [
                \     {'name': 'CtrlSF', 'complete': 'customlist,ctrlsf#comp#Completion'},
                \     'CtrlSFOpen', 'CtrlSFUpdate', 'CtrlSFClose', 'CtrlSFClearHL', 'CtrlSFToggle',
                \ ]}
    if s:ag_path != ""
        let g:ctrlsf_ackprg = s:ag_path
    endif

    let g:ctrlsf_default_root = 'project'

    " 在project下找
    vmap     [ctrlsf]s :<C-U>CtrlSF <C-R>=g:CtrlSFGetVisualSelection()<CR> <C-R>=FindVcsRoot('')<CR><CR>
    nmap     [ctrlsf]s :<C-U>CtrlSF <C-R>=expand('<cword>')<CR> <C-R>=FindVcsRoot('')<CR><CR>
    nmap     [ctrlsf]S <Plug>CtrlSFPrompt -regex<SPACE>

    " 在当前文件目录下找
    vmap     [ctrlsf]b :<C-U>CtrlSF <C-R>=g:CtrlSFGetVisualSelection()<CR> <C-R>=expand('%:p:h')<CR><CR>
    nmap     [ctrlsf]b :<C-U>CtrlSF <C-R>=expand('<cword>')<CR> <C-R>=expand('%:p:h')<CR><CR>

    " 在当前目录下找
    vmap     [ctrlsf]c :<C-U>CtrlSF <C-R>=g:CtrlSFGetVisualSelection()<CR> <C-R>=getcwd()<CR><CR>
    nmap     [ctrlsf]c :<C-U>CtrlSF <C-R>=expand('<cword>')<CR> <C-R>=getcwd()<CR><CR>

    nmap     [ctrlsf]p <Plug>CtrlSFPwordPath
    nmap     [ctrlsf]P <Plug>CtrlSFPwordExec
    nnoremap [ctrlsf]o :CtrlSFOpen<CR>
    nnoremap [ctrlsf]t :CtrlSFToggle<CR>
    " }}}
    " Mark--Karkat: 可同时标记多个mark。\M显隐所有，\N清除所有Mark。\m标识当前word {{{
    NeoBundleLazy 'vernonrj/Mark--Karkat', {
                \ 'on_cmd' : ['Mark', 'MarkClear', 'Marks', 'MarkLoad', 'MarkSave', 'MarkPalette'],
                \ 'on_map' : [
                \     '<Plug>MarkSet', '<Plug>MarkRegex', '<Plug>MarkClear', '<Plug>MarkToggle',
                \     '<Plug>MarkAllClear',
                \     '<Leader>n', '<Leader>*', '<Leader>#', '<Leader>/', '<Leader>?',
                \ ],
                \ 'disabled' : v:version < '701',
                \ }
    if neobundle#tap('Mark--Karkat')
        nmap <unique> [mark]m <Plug>MarkSet
        xmap <unique> [mark]m <Plug>MarkSet
        nmap <unique> [mark]r <Plug>MarkRegex
        xmap <unique> [mark]r <Plug>MarkRegex
        nmap <unique> [mark]c <Plug>MarkClear
        nmap [mark]M <Plug>MarkToggle
        nmap [mark]C <Plug>MarkAllClear

        " 在插件载入后再执行修改颜色的操作
        augroup Mark
            autocmd VimEnter *
                        \ highlight MarkWord1 ctermbg=DarkCyan    ctermfg=Black guibg=#8CCBEA guifg=Black |
                        \ highlight MarkWord2 ctermbg=DarkMagenta ctermfg=Black guibg=#FF7272 guifg=Black |
                        \ highlight MarkWord3 ctermbg=DarkYellow  ctermfg=Black guibg=#FFDB72 guifg=Black |
                        \ highlight MarkWord4 ctermbg=DarkGreen   ctermfg=Black guibg=#FFB3FF guifg=Black |
                        \ highlight MarkWord5 ctermbg=DarkRed     ctermfg=Black guibg=#9999FF guifg=Black |
                        \ highlight MarkWord6 ctermbg=DarkBlue    ctermfg=Black guibg=#A4E57E guifg=Black
        augroup END
    endif
    " }}}
    " vim-abolish: :%S/box{,es}/bag{,s}/g进行单复数、大小写对应的查找 {{{
    NeoBundleLazy 'tpope/vim-abolish', {
                \ 'on_map' : [
                \   ['n', '<Plug>Coerce'],
                \   ['n', 'cr'],
                \ ],
                \ 'on_cmd' : [ 'Abolish', 'Subvert', 'S' ],
                \ }
    " }}}
    " vim-bufsurf: :BufSurfForward/:BufSurfBack跳转到本窗口的下一个、上一个buffer（增强<C-I>/<C-O>） {{{
    NeoBundleLazy 'ton/vim-bufsurf', {
                \ 'on_cmd' : ['BufSurfForward', 'BufSurfBack'],
                \ }
    " g<C-I>/g<C-O>直接跳到不同的buffer
    nnoremap <silent> g<C-I> :BufSurfForward<CR>
    nnoremap <silent> g<C-O> :BufSurfBack<CR>
    " }}}
    " vim-indent-guides: 标记出各缩进块 {{{
    NeoBundleLazy 'nathanaelkane/vim-indent-guides', {
                \ 'on_cmd':['IndentGuidesToggle','IndentGuidesEnable','IndentGuidesDisable'],
                \ 'on_map':['<Plug>IndentGuides'],
                \ }
    let g:indent_guides_default_mapping = 0
    let g:indent_guides_auto_colors = 0
    let g:indent_guides_start_level = 2
    let g:indent_guides_guide_size = 1
    augroup IndentGuides_hack
        autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#073642 ctermbg=0
        autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#03303c ctermbg=0
        autocmd filetype python :IndentGuidesEnable
    augroup END
    " }}}
    " vim-niceblock: 增强对块选操作的支持 {{{
    NeoBundleLazy 'kana/vim-niceblock', {
                \ 'on_map' : ['v', 'I', 'A'],
                \ }
    " }}}
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

    let g:tagbar_ctags_bin = s:ctags_path

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
    NeoBundleLazy 'harish2704/gtags.vim', {
                \ 'on_cmd' : [
                \     { 'name' : 'Gtags', 'complete' : 'custom,GtagsCandidate' },
                \     { 'name' : 'Gtagsa', 'complete' : 'custom,GtagsCandidate' },
                \     "GtagsCursor","Gozilla","GtagsUpdate","GtagsCscope"
                \ ],
                \ 'on_func' : [
                \     'GtagsCandidate',
                \ ]}
    call neobundle#config('gtags.vim', {
                \ 'disabled' : !s:has_global,
                \ })

    if !neobundle#tap('gtags.vim')
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
            nmap [tag]s :cs find s <C-R>=expand("<cword>")<CR><CR>
            nmap [tag]g :cs find g <C-R>=expand("<cword>")<CR><CR>
            nmap [tag]c :cs find c <C-R>=expand("<cword>")<CR><CR>
            nmap [tag]t :cs find t <C-R>=expand("<cword>")<CR><CR>
            nmap [tag]e :cs find e <C-R>=expand("<cword>")<CR><CR>
            nmap [tag]f :cs find f <C-R>=expand("<cfile>")<CR><CR>
            nmap [tag]i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
            nmap [tag]d :cs find d <C-R>=expand("<cword>")<CR><CR>

            " <C-\>大写在当前窗口打开命令行
            nmap [tag]S :cs find s<SPACE>
            nmap [tag]G :cs find g<SPACE>
            nmap [tag]C :cs find c<SPACE>
            nmap [tag]T :cs find t<SPACE>
            nmap [tag]E :cs find e<SPACE>
            nmap [tag]F :cs find f<SPACE>
            nmap [tag]I :cs find i ^
            nmap [tag]D :cs find d<SPACE>
        endif " }}}
    else
        let g:Gtags_Auto_Update = 1
        let g:Gtags_Auto_Map = 0
        let g:Gtags_No_Auto_Jump = 0
        let g:GtagsCscope_Auto_Load = 1

        " 如果光标在定义上，就找引用，如果在引用上就找定义
        nmap [tag]<C-]> :GtagsCursor<CR>
        nmap [tag]f :Gtags -f %<CR>

        " <C-\>小写在当前窗口打开光标下的符号
        nmap [tag]s :Gtags -sr <C-R>=expand("<cword>")<CR><CR>
        nmap [tag]g :Gtags --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=expand("<cword>")<CR><CR>
        nmap [tag]t :Gtags -g --literal --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=expand("<cword>")<CR><CR>
        nmap [tag]e :Gtags -g --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=expand("<cword>")<CR><CR>
        nmap [tag]p :Gtags -P <C-R>=expand("<cfile>:t")<CR><CR>

        " <C-\>c小写在当前窗口打开光标下的符号，限定在当前目录下的文件
        nmap [tag]cs :Gtags -l -sr <C-R>=expand("<cword>")<CR><CR>
        nmap [tag]cg :Gtags -l --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=expand("<cword>")<CR><CR>
        nmap [tag]ct :Gtags -l -g --literal --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=expand("<cword>")<CR><CR>
        nmap [tag]ce :Gtags -l -g --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=expand("<cword>")<CR><CR>
        nmap [tag]cp :Gtags -l -P <C-R>=expand("<cfile>:t")<CR><CR>

        " <C-\>小写在当前窗口打开选中的符号
        vmap [tag]s :Gtags -sr <C-R>=s:VisualSelection()<CR><CR>
        vmap [tag]g :Gtags --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=s:VisualSelection()<CR><CR>
        vmap [tag]t :Gtags -g --literal --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=s:VisualSelection()<CR><CR>
        vmap [tag]e :Gtags -g --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=s:VisualSelection()<CR><CR>
        vmap [tag]p :Gtags -P <C-R>=s:VisualSelection()<CR><CR>

        " <C-\>c小写在当前窗口打开选中的符号，限定在当前目录下的文件
        vmap [tag]cs :Gtags -l -sr <C-R>=s:VisualSelection()<CR><CR>
        vmap [tag]cg :Gtags -l --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=s:VisualSelection()<CR><CR>
        vmap [tag]ct :Gtags -l -g --literal --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=s:VisualSelection()<CR><CR>
        vmap [tag]ce :Gtags -l -g --from-here="<C-R>=line('.')<CR>:<C-R>=expand("%")<CR>" <C-R>=s:VisualSelection()<CR><CR>
        vmap [tag]cp :Gtags -l -P <C-R>=s:VisualSelection()<CR><CR>


        " <C-\>大写在当前窗口打开命令行
        nmap [tag]S :Gtags -sr<SPACE>
        nmap [tag]G :Gtags<SPACE>
        nmap [tag]T :Gtags -g --literal<SPACE>
        nmap [tag]E :Gtags -g<SPACE>
        nmap [tag]P :Gtags -P<SPACE>

        " <C-\>大写在当前窗口打开命令行，限定在当前目录下的文件
        nmap [tag]cS :Gtags -l  -sr<SPACE>
        nmap [tag]cG :Gtags -l<SPACE>
        nmap [tag]cT :Gtags -l  -g --literal<SPACE>
        nmap [tag]cE :Gtags -l  -g<SPACE>
        nmap [tag]cP :Gtags -l  -P<SPACE>
    endif
    " }}}
    "" Intelligent_Tags: 自动为当前文件及其包含的文件生成tags {{{
    "NeoBundle 'bahejl/Intelligent_Tags'
    "
    "    let g:Itags_Depth=3    " 缺省是1，当前文件及其包含的文件。-1表示无穷层
    "    let g:Itags_Ctags_Flags="--c++-kinds=+p --fields=+iaS --extra=+q -R"
    "    let g:Itags_header_mapping= {'h':['c', 'cpp', 'c++']}
    "if executable("ctags")
    "    NeoBundle 'thawk/Intelligent_Tags'              " 自动扫描所依赖的头文件，生成tags文件
    "    "NeoBundle 'AutoTag'
    "endif
    "" }}}
    " FSwitch: 在头文件和CPP文件间进行切换。用:A调用。\ol在右边分隔一个窗口显示，\of当前窗口 {{{
    NeoBundleLazy 'derekwyatt/vim-fswitch', {
                \ 'on_func' : ['FSwitch'],
                \ 'on_cmd' : ['FSHere','FSRight','FSSplitRight','FSLeft','FSSplitLeft','FSAbove','FSSplitAbove','FSBelow','FSSplitBelow'],
                \ }
    let g:fsnonewfiles=1
    " 可以用:A在.h/.cpp间切换
    command! A :call FSwitch('%', '')
    augroup fswitch_hack
        au! BufEnter *.h,*.hpp
                    \  let b:fswitchdst='cpp,c,ipp,cxx'
                    \| let b:fswitchlocs='reg:/include/src/,reg:/include.*/src/,ifrel:|/include/|../src|,reg:!\<include/\w\+/!src/!,reg:!\<include/\(\w\+/\)\{2}!src/!,reg:!sscc\(/[^/]\+\|\)/.*!libs\1/**!'
        au! BufEnter *.c,*.cpp,cxx,*.ipp
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
    nmap <silent> [fswitch]o :FSHere<cr>
    " Switch to the file and load it into the window on the right >
    nmap <silent> [fswitch]l :FSRight<cr>
    " Switch to the file and load it into a new window split on the right >
    nmap <silent> [fswitch]L :FSSplitRight<cr>
    " Switch to the file and load it into the window on the left >
    nmap <silent> [fswitch]h :FSLeft<cr>
    " Switch to the file and load it into a new window split on the left >
    nmap <silent> [fswitch]H :FSSplitLeft<cr>
    " Switch to the file and load it into the window above >
    nmap <silent> [fswitch]k :FSAbove<cr>
    " Switch to the file and load it into a new window split above >
    nmap <silent> [fswitch]K :FSSplitAbove<cr>
    " Switch to the file and load it into the window below >
    nmap <silent> [fswitch]j :FSBelow<cr>
    " Switch to the file and load it into a new window split below >
    nmap <silent> [fswitch]J :FSSplitBelow<cr>
    " }}}
    " undotree: 列出修改历史，方便undo到一个特定的位置 {{{
    NeoBundleLazy 'mbbill/undotree', {
                \ 'on_cmd' : ['UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus'],
                \ }
    nnoremap <silent> <F5> :UndotreeToggle<CR>
    " }}}
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
    nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
    nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
    nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
    nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
    " }}}
    " 启用内置的matchit插件 {{{
    runtime! macros/matchit.vim
    "}}}
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
                \ 'on_unite' : 'ref',
                \ 'on_map' : ['nv', 'K', '<Plug>(ref-keyword)'],
                \ }
    " }}}
endif
"}}}

if count(g:dotvim_settings.plugin_groups, 'autocomplete') "{{{
    if g:dotvim_settings.autocomplete_method == 'ycm' "{{{
        " " " YouCompleteMe: 代码补全 {{{
        " NeoBundleLazy 'Valloric/YouCompleteMe', {
        "             \ 'build' : {
        "             \     'unix' : './install.sh --clang-completer',
        "             \    }
        "             \ }
        " " " }}}
        " }}}
    elseif g:dotvim_settings.autocomplete_method == 'neocomplete' " {{{
        NeoBundleLazy 'Shougo/neocomplete', {
                    \ 'on_i' : 1,
                    \ 'disabled' : !(v:version >= '703' && has('lua')),
                    \ }
        if neobundle#tap('neocomplete')
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
            let g:neocomplete#data_directory=s:get_cache_dir('neocomplete')

            if v:version == '704' && !has("patch-7.4.633")
                " neocomplete issue #332
                let g:neocomplete#enable_fuzzy_completion = 0
            endif

            " Define dictionary.
            let g:neocomplete#sources#dictionary#dictionaries = {
                        \ 'default' : '',
                        \ 'vimshell' : expand(s:cache_dir.'/.vimshell_hist'),
                        \ 'scheme' : expand(s:cache_dir.'/.gosh_completions')
                        \ }

            " Plugin key-mappings.
            inoremap <expr><C-g>     neocomplete#undo_completion()
            inoremap <expr><C-l>     neocomplete#complete_common_string()

            " Recommended key-mappings.
            " <CR>: close popup and save indent.
            inoremap <expr><CR>  neocomplete#smart_close_popup() . "\<CR>"
            " <TAB>: completion.
            inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
            " <S-TAB>: completion.
            inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"
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
        " }}}
    elseif g:dotvim_settings.autocomplete_method == 'neocomplcache' " {{{
        NeoBundleLazy 'Shougo/neocomplcache', {
                    \ 'on_i' : 1,
                    \ 'disabled' : v:version >= '703' && has('lua'),
                    \ }
        if neobundle#tap('neocomplcache')
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
            let g:neocomplcache_temporary_dir=s:get_cache_dir('neocomplete')

            " Define dictionary.
            let g:neocomplcache_dictionary_filetype_lists = {
                        \ 'default' : '',
                        \ 'vimshell' : expand(s:cache_dir.'/.vimshell_hist'),
                        \ 'scheme' : expand(s:cache_dir.'/.gosh_completions')
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
        endif " }}}
    else
        let g:dotvim_settings.autocomplete_method = ''  " 不支持的补全方式，清空
    endif

    if neobundle#tap('neocomplete') || neobundle#tap('neocomplcache')
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
        NeoBundleLazy 'wellle/tmux-complete.vim', {
                    \ 'on_i' : 1,
                    \ 'external_commands' : 'tmux',
                    \ }
        let g:tmuxcomplete#trigger = ''
        " }}}
    endif
endif
"}}}

if count(g:dotvim_settings.plugin_groups, 'snippet') "{{{
    if g:dotvim_settings.snippet_engine == 'neosnippet' "{{{
        " neosnippet: 代码模板引擎 {{{
        NeoBundleLazy 'Shougo/neosnippet', {
                    \ 'on_i' : 1,
                    \ 'on_ft' : 'neosnippet',
                    \ 'depends' : ['context_filetype.vim'],
                    \ 'on_cmd' : ['NeoSnippetEdit'],
                    \ 'on_map' : ['<Plug>(neosnippet_'],
                    \ 'on_unite' : ['neosnippet', 'neosnippet/user', 'neosnippet/runtime'],
                    \ }
        let g:neosnippet#snippets_directory = fnamemodify(finddir("snippets", &runtimepath), ":p")
        let g:neosnippet#snippets_directory .= "," . fnamemodify(finddir("/neosnippet/autoload/neosnippet/snippets", &runtimepath), ":p")

        let g:neosnippet#data_directory = s:get_cache_dir('neosnippet')

        if !exists('g:neosnippet#scope_aliases')
            let g:neosnippet#scope_aliases = {}
        endif

        let g:neosnippet#enable_snipmate_compatibility = 1

        " mako模板也可以使用html
        let g:neosnippet#scope_aliases['mako'] = 'html'

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
        " if has('conceal')
        "     set conceallevel=2 concealcursor=i
        " endif

        if neobundle#tap('neocomplete')
            " 回车直接展开当前选中的snippet
            " 不知为何，用inoremap时，是<Plug>(neosnippet_expand_or_jump)的文
            " 字，而不是执行这个map。所以使用imap代替
            imap <silent><expr> <CR> pumvisible() ?
                        \ (neosnippet#expandable_or_jumpable() ?
                        \ neocomplete#close_popup()."\<Plug>(neosnippet_expand_or_jump)" :
                        \ neocomplete#close_popup()) : "\<CR>"
            call neobundle#untap()
        endif
        " }}}
        " neosnippet-snippets: 代码模板 {{{
        NeoBundle 'Shougo/neosnippet-snippets'
        " }}}
    " }}}
    elseif g:dotvim_settings.snippet_engine == 'ultisnips' "{{{
        " ultisnips: 以python实现的更强大的代码模板引擎 {{{
        NeoBundle 'SirVer/ultisnips'
        if neobundle#tap('ultisnips')
            let g:UltiSnipsSnippetsDir = s:vimrc_path . '/mysnippets'
            let g:UltiSnipsSnippetDirectories=['UltiSnips', 'mysnippets']

            let g:UltiSnipsExpandTrigger       = '<NOP>'
            let g:UltiSnipsListSnippets        = '<C-tab>'

            let g:UltiSnipsEnableSnipMate = 1

            " inoremap <silent><expr> <TAB>
            "     \ pumvisible() ? "\<C-n>" :
            "     \ (len(keys(UltiSnips#SnippetsInCurrentScope())) > 0 ?
            "     \ "<C-R>=UltiSnips#ExpandSnippet()<CR>" : "\<TAB>")

            let g:UltiSnipsJumpForwardTrigger="<NOP>"
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
            inoremap <silent><expr> <TAB>
                        \ pumvisible() ? "\<C-n>" :
                        \ "<C-R>=ExpandSnippetOrJumpForwardOrReturn('\<TAB>')<CR>"

            " previous menu item, jump to previous placeholder or do nothing
            let g:UltiSnipsJumpBackwordTrigger = ""
            inoremap <expr> <S-TAB>
                        \ pumvisible() ? "\<C-p>" :
                        \ "<C-R>=UltiSnips#JumpBackwards()<CR>"

            " jump to previous placeholder otherwise do nothing
            snoremap <buffer> <silent> <S-TAB>
                        \ <ESC>:call UltiSnips#JumpBackwards()<CR>

            call neobundle#untap()

            " 回车直接展开当前选中的snippet
            if exists('*neocomplete#close_popup')
                " 如果存在neocomplete，就用neocomplete#close_popup来关闭popup
                " menu
                inoremap <silent><expr> <CR>
                            \ pumvisible() ?
                            \ neocomplete#close_popup()."<C-R>=ExpandSnippetOrJumpForwardOrReturn('')<CR>" :
                            \ "\<CR>"
            else
                inoremap <silent><expr> <CR>
                            \ pumvisible() ?
                            \ "<C-R>=ExpandSnippetOrJumpForwardOrReturn('\<C-y>')<CR>" :
                            \ "\<CR>"
            endif
        endif
        " }}}
        " vim-snippets: 代码模板 {{{
        NeoBundle 'honza/vim-snippets'
        " }}}
    endif "}}}
endif
"}}}

if count(g:dotvim_settings.plugin_groups, 'textobj') "{{{
    " vim-textobj-user: 可自定义motion {{{
    NeoBundle 'kana/vim-textobj-user'
    " }}}
    " vim-textobj-indent: 增加motion: ai ii（含更深缩进） aI iI（仅相同缩进） {{{
    NeoBundle 'kana/vim-textobj-indent'
    " }}}
    " vim-textobj-line: 增加motion: al il {{{
    NeoBundle 'kana/vim-textobj-line'
    " }}}
    " vim-textobj-function: 增加motion: if/af/iF/aF 选择一个函数 {{{
    NeoBundle 'kana/vim-textobj-function'
    " }}}
    " CamelCaseMotion: 增加,w ,b ,e 可以处理大小写混合或下划线分隔两种方式的单词 {{{
    NeoBundle 'bkad/CamelCaseMotion'
    " }}}
    " vim-textobj-comment: 增加motion: ac ic {{{
    NeoBundle 'thinca/vim-textobj-comment'
    " }}}
    " vim-pairs: ci/, di;, yi*, vi@, ca/, da;, ya*, va@ ... {{{
    NeoBundle 'kurkale6ka/vim-pairs'
    " }}}
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'scm') "{{{
    " vcscommand.vim: SVN前端。\cv进行diff，\cn查看每行是谁改的，\cl查看修订历史，\cG关闭VCS窗口回到源文件 {{{
    NeoBundleLazy 'vcscommand.vim', {
                \ 'on_map' : [
                \     '<Plug>VCSAdd', '<Plug>VCSAnnotate', '<Plug>VCSCommit', '<Plug>VCSDelete', '<Plug>VCSDiff',
                \     '<Plug>VCSGotoOriginal', '<Plug>VCSClearAndGotoOriginal', '<Plug>VCSInfo', '<Plug>VCSLock',
                \     '<Plug>VCSLog', '<Plug>VCSRevert', '<Plug>VCSReview', '<Plug>VCSSplitAnnotate', '<Plug>VCSStatus',
                \     '<Plug>VCSUnlock', '<Plug>VCSUpdate', '<Plug>VCSVimDiff',
                \ ],
                \ 'on_cmd' : ['VCSAdd', 'VCSAnnotate', 'VCSBlame', 'VCSCommit', 'VCSDelete', 'VCSDiff', 'VCSGotoOriginal', 'VCSInfo', 'VCSLock', 'VCSLog', 'VCSRemove', 'VCSRevert', 'VCSReview', 'VCSStatus', 'VCSUnlock', 'VCSUpdate', 'VCSVimDiff', 'VCSCommandDisableBufferSetup', 'VCSCommandEnableBufferSetup', 'VCSReload'],
                \ }
    let g:VCSCommandDisableMappings = 1

    nnoremap <silent> [code]p :<C-U>VCSVimDiff PREV<CR>
    nnoremap <silent> [code]a :<C-U>VCSAdd<CR>
    nnoremap <silent> [code]c :<C-U>VCSCommit<CR>
    nnoremap <silent> [code]D :<C-U>VCSDelete<CR>
    nnoremap <silent> [code]d :<C-U>VCSDiff<CR>
    nnoremap <silent> [code]G :<C-U>VCSGotoOriginal!<CR>
    nnoremap <silent> [code]g :<C-U>VCSGotoOriginal<CR>
    nnoremap <silent> [code]i :<C-U>VCSInfo<CR>
    nnoremap <silent> [code]L :<C-U>VCSLock<CR>
    nnoremap <silent> [code]l :<C-U>VCSLog<CR>
    nnoremap <silent> [code]N :<C-U>VCSAnnotate! -g<CR>
    nnoremap <silent> [code]n :<C-U>let tmp_lnum=line('.')<CR>:VCSAnnotate -g<CR>:keepjumps execute <C-R>=tmp_lnum<CR><CR>:unlet tmp_lnum<CR>
    nnoremap <silent> [code]q :<C-U>VCSRevert<CR>
    nnoremap <silent> [code]r :<C-U>VCSReview<CR>
    nnoremap <silent> [code]s :<C-U>VCSStatus<CR>
    nnoremap <silent> [code]U :<C-U>VCSUnlock<CR>
    nnoremap <silent> [code]u :<C-U>VCSUpdate<CR>
    nnoremap <silent> [code]v :<C-U>VCSVimDiff<CR>
    " }}}
    " vim-fugitive: GIT前端 {{{
    NeoBundle 'tpope/vim-fugitive', {
                \ 'external_commands' : 'git',
                \ }
    " }}}
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'cpp') "{{{
    " clang_complete: 使用clang编译器进行上下文补全 {{{
    NeoBundleLazy 'Rip-Rip/clang_complete', {
                \ 'on_ft' : ['c', 'cpp'],
                \ }
    call neobundle#config('clang_complete', {
                \ 'disabled' : (g:dotvim_settings.cpp_complete_method != 'clang_complete'
                \           || (s:libclang_path == "" && !executable('clang'))),
                \ })
    if neobundle#tap('clang_complete')
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
        let g:clang_default_keymappings = 0
        let g:clang_user_options = '-std=c++11 -stdlib=libc++'
        let g:clang_complete_macros = 1

        if s:libclang_path != ""
            let g:clang_use_library = 1
            let g:clang_library_path = s:libclang_path
        endif
    endif
    " }}}
    " vim-clang: 使用clang编译器进行上下文补全 {{{
    NeoBundleLazy 'justmao945/vim-clang', {
                \ 'on_ft' : ['c', 'cpp'],
                \ }
    call neobundle#config('vim-clang', {
                \ 'disabled' : g:dotvim_settings.cpp_complete_method != 'vim-clang'
                \           || !executable('clang'),
                \ })
    if neobundle#tap('vim-clang')
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

        if s:clang_include_path != ""
            let g:clang_cpp_options .= " -I " . s:clang_include_path
        endif
    endif
    " }}}
    " vim-marching: 使用clang进行补全 {{{
    NeoBundleLazy 'osyo-manga/vim-marching', {
                \ 'on_ft' : ['c', 'cpp'],
                \ 'on_cmd' : [
                \     'MarchingBufferClearCache', 'MarchingDebugLog'],
                \ 'on_map' : [['i', '<Plug>(marching_']],
                \ 'depends' : ['osyo-manga/vim-reunions', ],
                \ }
    call neobundle#config('vim-marching', {
                \ 'disabled' : g:dotvim_settings.cpp_complete_method !~ 'marching.*'
                \           || (s:libclang_path == "" && !executable('clang')),
                \ })
    if neobundle#tap('vim-marching')
        let g:marching_enable_neocomplete = 1
        let g:marching_clang_command_option = ' -std=c++11 -stdlib=libc++'

        if g:dotvim_settings.cpp_complete_method == 'marching' " 自动选择方式
            if s:libclang_path != ""
                let g:dotvim_settings.cpp_complete_method = 'marching.snowdrop'
            else
                let g:dotvim_settings.cpp_complete_method = 'marching.async'
            endif
        endif

        " 选择一个backend
        if g:dotvim_settings.cpp_complete_method == 'marching.snowdrop'
            " 使用vim-snowdrop
            function! neobundle#tapped.hooks.on_post_source(bundle)
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
    endif
    " }}}
    " vim-snowdrop: libclang的python封装 {{{
    NeoBundleLazy 'osyo-manga/vim-snowdrop', {
                \ 'on_cmd' : [
                \     'SnowdropVerify', 'SnowdropEchoClangVersion',
                \     'SnowdropLogs', 'SnowdropClearLogs',
                \     'SnowdropEchoIncludes', 'SnowdropErrorCheck',
                \     'SnowdropGotoDefinition', 'SnowdropEchoTypeof',
                \     'SnowdropEchoResultTypeof', 'SnowdropFixit',
                \ ],
                \ 'on_unite' : ['snowdrop/includes', 'snowdrop/outline'],
                \ }
    call neobundle#config('vim-snowdrop', {
                \ 'disabled' : s:libclang_path == "",
                \ })
    if neobundle#tap('vim-snowdrop')
        let g:snowdrop#libclang_directory = fnamemodify(s:libclang_path, ':p:h')
        let g:snowdrop#libclang_file      = fnamemodify(s:libclang_path, ':p:t')

        " Enable code completion in neocomplete.vim.
        let g:neocomplete#sources#snowdrop#enable = 1

        let g:snowdrop#command_options = {
                    \ "cpp" : "-std=c++1y",
                    \ }

        " Not skip
        let g:neocomplete#skip_auto_completion_time = ""
    endif
    " }}}
    " vim-clang-format: 使用clang编译器进行上下文补全 {{{
    NeoBundleLazy 'rhysd/vim-clang-format', {
                \ 'on_cmd' : ['ClangFormat'],
                \ 'on_map' : ['<Plug>(operator-clang-format'],
                \ 'external_commands' : 'clang-format',
                \ }
    if neobundle#tap('vim-clang-format')
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
        autocmd FileType c,cpp,objc nnoremap <buffer>[code]f :<C-u>ClangFormat<CR>
        autocmd FileType c,cpp,objc vnoremap <buffer>[code]f :ClangFormat<CR>
        " if you install vim-operator-user
        autocmd FileType c,cpp,objc map <buffer><LocalLeader>x <Plug>(operator-clang-format)
    endif
    " }}}
    " " vim-cpplint: <F7>执行cpplint检查（要求PATH中能找到cpplint.py） {{{
    " NeoBundleLazy 'funorpain/vim-cpplint', {
    "             \ 'filetyhpes' : ['c', 'cpp'],
    "             \ 'external_commands' : 'cpplint.py',
    "             \ }
    " " }}}
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
    noremap [make]w :<C-u>Wandbox<CR>

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

if count(g:dotvim_settings.plugin_groups, 'python') "{{{
    " jedi-vim: 强大的Python补全、pydoc查询工具。 \g：跳到变量赋值点或函数定义；\d：函数定义；K：查询文档；\r：改名；\n：列出对使用一个名称的所有位置 {{{
    NeoBundleLazy 'davidhalter/jedi-vim', {
                \ 'on_ft' : ['python', 'python3'],
                \ }
    let g:jedi#popup_select_first = 0   " 不要自动选择第一个候选项
    " }}}
    "NeoBundle 'tmhedberg/SimpylFold'
    NeoBundleLazy 'hynek/vim-python-pep8-indent', {
                \ 'on_ft' : ['python', 'python3'],
                \ }
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'haskell') "{{{
    " neco-ghc: 结合neocomplete补全haskell {{{
    NeoBundleLazy 'eagletmt/neco-ghc', {
                \ 'on_ft' : ['haskell'],
                \ 'on_cmd'  : ['NecoGhcDiagnostics'],
                \ 'external_commands' : 'ghc-mod',
                \ }

    if neobundle#tap('neco-ghc')
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
    endif
    " }}}
    " ref-hoogle: 让vim-ref插件支持hoogle {{{
    NeoBundleLazy 'ujihisa/ref-hoogle', {
                \ 'on_ft' : ['haskell'],
                \ }
    call neobundle#config('ref-hoogle', {
                \ 'disabled' : !neobundle#tap('vim-ref'),
                \ 'external_commands' : 'hoogle',
                \ })
    " }}}
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'csharp') "{{{
    " vim-csharp: C#文件的支持 {{{
    NeoBundleLazy 'OrangeT/vim-csharp', {
                \ 'on_ft' : ['csharp'],
                \ }
    " }}}
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'web') "{{{
    " Emmet.vim: 快速编写XML文件。如 div>p#foo$*3>a 再按 <C-Y>, {{{
    NeoBundleLazy 'mattn/emmet-vim', {
                \ 'on_ft' : ['xml','html','css','sass','scss','less'],
                \ 'on_map' : ['<Plug>(Emmet'],
                \ 'on_cmd' : ['EmmetInstall'],
                \ }
    augroup custom_Emmet
        autocmd FileType {xml,html,css,sass,scss,less} imap <buffer> <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")
    augroup END
    " }}}
    NeoBundleLazy 'othree/xml.vim', {
                \ 'on_ft' : ['xml'],
                \ }                                             " 辅助编写XML文件
    NeoBundleLazy 'elzr/vim-json', {
                \ 'on_ft' : ['json'],
                \ 'on_path' : ['.*\.jsonp\?'],
                \ }                                             " 对JSON文件提供语法高亮
    NeoBundleLazy 'othree/javascript-libraries-syntax.vim', {
                \ 'on_ft' : ['javascript', 'js'],
                \ }                                             " Javascript语法高亮
    NeoBundleLazy 'sophacles/vim-bundle-mako', {
                \ 'on_ft' : ['mako'],
                \ 'on_path' : ['.*\.mako'],
                \ }                                             " python的Mako模板支持

endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'shell') "{{{
    " Conque-GDB: 在vim中进行gdb调试 {{{
    NeoBundleLazy 'Conque-GDB', {
                \ 'disabled' : !executable("gdb"),
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
                \ 'on_unite' : ['bookmark', 'directory', 'directory_mru', 'directory_rec',],
                \ }
    if neobundle#tap('vimshell')
        let g:vimshell_data_directory=s:get_cache_dir('vimshell')

        " 下面的键如果slimux/vim-tbone启用则会被这两个插件覆盖，因此vimshell
        " 应在那两个插件前

        " 以当前目录开始vimshell窗口
        map  [repl]c :<C-U>VimShellPop<CR>
        " 以当前缓冲区目录打开vimshell窗口
        map  [repl]b :<C-U>VimShellPop <C-R>=expand("%:p:h")<CR><CR>
        " 关闭最近一个vimshell窗口
        map  [repl]x :<C-U>VimShellClose<CR>
        " 执行当前行
        map  [repl]s :<C-U>VimShellSendString<CR>
        " 执行所选内容
        vmap [repl]s :<C-U>'<,'>VimShellSendString<CR>
        " 提示执行命令
        map  [repl]p :<C-U>VimShellSendString<SPACE>
    endif
    " }}}
    " slimux: 配合tmux的REPL工具，可以把缓冲区中的内容拷贝到tmux指定pane下运行。\rs发送当前行或选区，\rp提示输入命令，\ra重复上一命令，\rk重复上个key序列 {{{
    NeoBundleLazy 'epeli/slimux', {
                \ 'on_cmd' : [
                \     'SlimuxREPLSendLine', 'SlimuxREPLSendSelection', 'SlimuxREPLSendLine', 'SlimuxREPLSendBuffer', 'SlimuxREPLConfigure',
                \     'SlimuxShellRun', 'SlimuxShellPrompt', 'SlimuxShellLast', 'SlimuxShellConfigure',
                \     'SlimuxSendKeysPrompt', 'SlimuxSendKeysLast', 'SlimuxSendKeysConfigure' ],
                \ 'on_func': ['SlimuxConfigureCode', 'SlimuxSendCode', 'SlimuxSendCommand', 'SlimuxSendKeys',],
                \ 'disabled' : !executable("tmux"),
                \ }
    if neobundle#tap('slimux')
        map  [repl]s :<C-U>SlimuxREPLSendLine<CR>
        vmap [repl]s :<C-U>SlimuxREPLSendSelection<CR>
        map  [repl]p :<C-U>SlimuxShellPrompt<CR>
        map  [repl]r :<C-U>SlimuxShellLast<CR>
        map  [repl]k :<C-U>SlimuxSendKeysLast<CR>
    endif
    " }}}
    " vim-tbone: 可以操作tmux缓冲区，执行tmux命令 {{{
    NeoBundleLazy 'tpope/vim-tbone', {
                \ 'on_cmd' : [
                \   { 'name' : 'Tattach', 'complete' : 'custom,tbone#complete_sessions' },
                \   { 'name' : 'Tmux', 'complete' : 'custom,tbone#complete_command' },
                \   { 'name' : 'Tput', 'complete' : 'custom,tbone#complete_buffers' },
                \   { 'name' : 'Tyank', 'complete' : 'custom,tbone#complete_buffers' },
                \   { 'name' : 'Twrite', 'complete' : 'custom,tbone#complete_panes' },
                \ ],
                \ 'disabled' : !executable("tmux"),
                \ }
    if neobundle#tap('vim-tbone')
        map  [repl]c :<C-U>silent !tmux split-window -p 30 -d<CR>
        map  [repl]b :<C-U>silent !tmux split-window -p 30 -d -c "<C-R>=expand("%:p:h")<CR>"<CR>
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
                \ 'on_unite' : ['ssh'],
                \ }
    " }}}
    " vimshell-ssh: 在vimshell中iexe ssh连接服务器 {{{
    NeoBundleLazy 'ujihisa/vimshell-ssh', {
                \ 'on_ft' : ['vimshell'],
                \ }
    " }}}
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'doc') "{{{
    " vim-orgmode: 对emacs的org文件的支持 {{{
    NeoBundleLazy 'jceb/vim-orgmode', {
                \ 'depends' : [
                \   'NrrwRgn',
                \   'speeddating.vim',
                \ ],
                \ 'on_ft' : ['org'],
                \ }
    autocmd BufRead,BufNewFile *.org setf org
    " }}}
    " timl: VimL编写的Clojure语言 {{{
    NeoBundleLazy 'tpope/timl', {
                \ 'on_ft' : ['timl'],
                \ 'on_path' : ['.*\.tim\?'],
                \ 'on_cmd' : [
                \     'TLrepl', 'TLscratch', 'TLcopen',
                \     { 'name' : 'TLinspect', 'complete' : 'expression' },
                \     { 'name' : 'TLeval', 'complete' : 'customlist,timl#interactive#input_complete' },
                \     { 'name' : 'TLsource', 'complete' : 'file' },
                \ ],
                \ }
    if has('win32') && !exists('$APPCACHE')
        " 设置缓存目录
        let $APPCACHE=s:get_cache_dir('timl')
    endif
    " }}}
    " vim-markdown-concealed: markdown支持，并且利用conceal功能隐藏不需要的字符 {{{
    NeoBundleLazy 'prurigro/vim-markdown-concealed', {
                \ 'on_ft' : ['markdown'],
                \ }
    " }}}
    " vim-asciidoc: AsciiDoc的语法高亮 {{{
    NeoBundleLazy 'asciidoc/vim-asciidoc', {
                \ 'on_ft' : ['asciidoc'],
                \ }
    " }}}
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'syntax') "{{{
    " SyntaxRange: 在一段文字中使用特别的语法高亮 {{{
    NeoBundleLazy 'SyntaxRange', {
                \ 'depends': ['ingo-library'],
                \ 'on_ft': ['asciidoc', 'markdown', 'mkdc'],
                \ 'on_cmd': [
                \     'SyntaxIgnore',
                \     {'name': 'SyntaxInclude', 'complete': 'syntax'},
                \ ]}
    " }}}
    " csv.vim: 增加对CSV文件（逗号分隔文件）的支持 {{{
    NeoBundleLazy 'csv.vim', {
                \ 'on_ft' : ['csv'],
                \ 'on_path' : '.*\.csv',
                \ }
    " }}}
    " wps.vim: syntax highlight for RockBox wps file {{{
    NeoBundleLazy 'wps.vim', {
                \ 'on_ft' : ['wps'],
                \ }
    autocmd BufRead,BufNewFile *.wps,*.sbs,*.fms setf wps
    " }}}
    NeoBundleLazy 'lbdbq', {
                \ 'on_map' : ['<LocalLeader>lb'],
                \ }                                             " 支持lbdb
    NeoBundleLazy 'gprof.vim', {
                \ 'on_ft' : ['gprof'],
                \ }                                             " 对gprof文件提供语法高亮
    NeoBundleLazy 'po.vim', {
                \ 'on_ft' : ['po'],
                \ 'on_path' : ['.*\.pot\?'],
                \ }                                             " 用于编辑PO语言包文件。
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'visual') "{{{
    " taboo.vim: 为TAB起名 {{{
    NeoBundle 'gcmt/taboo.vim', {
                \ 'on_cmd': [
                \     'TabooRename', 'TabooOpen', 'TabooReset',
                \ ]}
    let g:taboo_tabline = 0 " 使用vim-airline进行显示
    " }}}
    " vim-airline: 增强的statusline {{{
    NeoBundle 'bling/vim-airline'
    let bundle = neobundle#get('vim-airline')
    function! bundle.hooks.on_post_source(bundle)
        " 把section a的第1个part从mode改为bufnr() + mode
        if executable("svn")
            call airline#parts#define_function('mybranch', 'AirLineMyBranch')
            let g:airline_section_b = airline#section#create(['hunks', 'mybranch'])
        endif

        let g:airline_section_a = '%{bufnr("%")} ' . g:airline_section_a
        let g:airline_section_y = g:airline_section_y . '%{&bomb ? "[BOM]" : ""}'
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
    " GoldenView.Vim: <F8>/<S-F8>当前窗口与主窗口交换 {{{
    NeoBundle 'zhaocai/GoldenView.Vim'

    let g:goldenview__enable_default_mapping = 0
    " nmap <silent> <C-N>  <Plug>GoldenViewNext
    " nmap <silent> <C-P>  <Plug>GoldenViewPrevious

    nmap <silent> <F8>   <Plug>GoldenViewSwitchMain
    nmap <silent> <S-F8> <Plug>GoldenViewSwitchToggle

    " nmap <silent> <C-L>  <Plug>GoldenViewSplit
    " }}}
endif
" }}}

if count(g:dotvim_settings.plugin_groups, 'misc') "{{{
    " LargeFile: 在打开大文件时，禁用语法高亮以提供打开速度 {{{
    NeoBundle 'LargeFile'
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
                \               { 'name' : 'Edit',
                \                 'complete' : 'customlist,vimfiler#complete' },
                \               { 'name' : 'Write',
                \                 'complete' : 'customlist,vimfiler#complete' },
                \               { 'name' : 'Read',
                \                 'complete' : 'customlist,vimfiler#complete' },
                \               { 'name' : 'Source',
                \                 'complete' : 'customlist,vimfiler#complete' },
                \              ],
                \ 'on_map' : ['<Plug>(vimfiler_'],
                \ 'explorer' : 1,
                \ 'on_unite' : ['bookmark', 'directory', 'directory_mru', 'directory_rec',],
                \ }
    " 文件管理器，通过 :VimFiler 启动。
    " c : copy, m : move, r : rename,
    let g:vimfiler_as_default_explorer = 1
    let g:vimfiler_define_wrapper_commands = 1
    let g:vimfiler_data_directory = s:get_cache_dir('vimfiler')

    " 切换侧边栏
    nnoremap <silent> [unite]ee :<C-u>VimFilerExplorer<CR>
    nnoremap <silent> [unite]ec :<C-u>VimFiler<CR>
    nnoremap <silent> [unite]eb :<C-u>VimFiler <C-R>=expand("%:p:h")<CR><CR>
    " }}}
    " tpope/vim-characterize: ga会显示当前字符的更多信息 {{{
    NeoBundleLazy 'tpope/vim-characterize', {
                \     'on_map' : ['<Plug>'],
                \ }
    nmap ga <Plug>(characterize)
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
    " nmap ,r <Plug>(quickrun)
    " " }}}
    " scratch.vim: 打开一个临时窗口。gs/gS/:Scratch {{{
    NeoBundleLazy 'mtth/scratch.vim', {
                \ 'on_cmd' : ['Scratch','ScratchInsert','ScratchSelection'],
                \ 'on_map' : [['v','gs'], ['v','gS']],
                \ }
    " }}}
    " AutoFenc: 自动判别文件的编码 {{{
    NeoBundle 'AutoFenc'
    " }}}
    "" vim-sleuth: 自动检测文件的'shiftwidth'和'expandtab' {{{
    "NeoBundle 'tpope/vim-sleuth'
    "" }}}
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
    " context_filetype.vim: 在文件中根据上下文确定当前的filetype，如识别出html中内嵌js、css {{{
    NeoBundleLazy 'Shougo/context_filetype.vim', {
                \ }
    " }}}
    " NeoBundle 'tyru/current-func-info.vim'
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
" let g:solarized_bold=1
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
let g:base16_shell_path=s:vimrc_path . '/bundle/base16-shell'
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
"用,cd进入当前目录
nmap ,cd :cd <C-R>=expand("%:p:h")<CR><CR>
" "用,e可以打开当前目录下的文件
" nmap ,e :e <C-R>=escape(expand("%:p:h")."/", ' \')<CR>
" "在命令中，可以用 %/ 得到当前目录。如 :e %/
" cmap %/ <C-R>=escape(expand("%:p:h")."/", ' \')<cr>
" }}}

" 光标移动 {{{
" 正常模式下，空格及Shift-空格滚屏
noremap <SPACE> <C-F>
noremap <S-SPACE> <C-B>

" Key mappings to ease browsing long lines
nnoremap <Down>      gj
nnoremap <Up>        gk
inoremap <Down> <C-O>gj
inoremap <Up>   <C-O>gk
" }}}

" 操作tab页 {{{
" Ctrl-Tab/Ctrl-Shirt-Tab切换Tab
nmap <C-S-tab> :tabprevious<cr>
nmap <C-tab> :tabnext<cr>
map <C-S-tab> :tabprevious<cr>
map <C-tab> :tabnext<cr>
imap <C-S-tab> <ESC>:tabprevious<cr>i
imap <C-tab> <ESC>:tabnext<cr>i
" }}}

" 查找 {{{
" <F3>自动在当前文件中vimgrep当前word，g<F3>在当前目录下，vimgrep_files指定的文件中查找
"nmap <F3> :execute "vimgrep /\\<" . expand("<cword>") . "\\>/j **/*.cpp **/*.c **/*.h **/*.php"<CR>:botright copen<CR>
"nmap <S-F3> :execute "vimgrep /\\<" . expand("<cword>") . "\\>/j %" <CR>:botright copen<CR>
"map <F3> <ESC>:execute "vimgrep /\\<" . expand("<cword>") . "\\>/j **/*.cpp **/*.cxx **/*.c **/*.h **/*.hpp **/*.php" <CR><ESC>:botright copen<CR>
nmap g<F3> <ESC>:<C-U>exec "vimgrep /\\<" . expand("<cword>") . "\\>/j " . b:vimgrep_files <CR><ESC>:botright copen<CR>
"map <S-F3> <ESC>:execute "vimgrep /\\<" . expand("<cword>") . "\\>/j %" <CR><ESC>:botright copen<CR>
nmap <F3> <ESC>:<C-U>exec "vimgrep /\\<" . expand("<cword>") . "\\>/j %" <CR><ESC>:botright copen<CR>

" V模式下，搜索选中的内容而不是当前word
vnoremap g<F3> :<C-U>:exec "vimgrep /" . substitute(escape(s:VisualSelection(), '/\.*$^~['), '\_s\+', '\\_s\\+', 'g') . "/j " . b:vimgrep_files <CR><ESC>:botright copen<CR>
vnoremap <F3> :<C-U>:exec "vimgrep /" . substitute(escape(s:VisualSelection(), '/\.*$^~['), '\_s\+', '\\_s\\+', 'g') . "/j %" <CR><ESC>:botright copen<CR>
" }}}

" 在VISUAL模式下，缩进后保持原来的选择，以便再次进行缩进 {{{
vnoremap > >gv
vnoremap < <gv
" }}}

" folds {{{
" zJ/zK跳到下个/上个折叠处，并只显示该折叠的内容
nnoremap zJ zjzx
nnoremap zK zkzx
nnoremap zr zr:echo 'foldlevel: ' . &foldlevel<cr>
nnoremap zm zm:echo 'foldlevel: ' . &foldlevel<cr>
nnoremap zR zR:echo 'foldlevel: ' . &foldlevel<cr>
nnoremap zM zM:echo 'foldlevel: ' . &foldlevel<cr>
" }}}

" 一些方便编译的快捷键 {{{
if exists(":Make")  " vim-dispatch提供了异步的make
    nnoremap [make]m :<C-U>Make<CR>
    nnoremap [make]t :<C-U>Make unittest<CR>
    nnoremap [make]s :<C-U>Make stage<CR>
    nnoremap [make]c :<C-U>Make clean<CR>
    nnoremap [make]d :<C-U>Make doc<CR>
else
    nnoremap [make]m :<C-U>make<CR>
    nnoremap [make]t :<C-U>make unittest<CR>
    nnoremap [make]s :<C-U>make stage<CR>
    nnoremap [make]c :<C-U>make clean<CR>
    nnoremap [make]d :<C-U>make doc<CR>
endif
" }}}

" 其它 {{{
" Split line(opposite to S-J joining line)
" nnoremap <silent> <C-J> gEa<CR><ESC>ew

" map <silent> <C-W>v :vnew<CR>
" map <silent> <C-W>s :snew<CR>

" nnoremap * :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>
" }}}

" }}}

" color scheme and statusline {{{
let &background=g:dotvim_settings.background
execute "colorscheme " . g:dotvim_settings.colorscheme

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
